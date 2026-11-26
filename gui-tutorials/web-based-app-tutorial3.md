To make the Perl process exit automatically when the user closes the browser tab or window, combine two pieces:

1. **Client-side (`index.html`):** Send a periodic heartbeat (`setInterval`) every ~2 seconds to `/api/heartbeat`, and send a non-blocking `navigator.sendBeacon('/api/unload')` (plus a `fetch(..., { keepalive: true })` fallback) inside `pagehide` / `beforeunload`.
2. **Server-side (`app.pl`):** Track `last_seen` and `unloaded` timestamps, run a short `select()` / non-blocking poll loop instead of blocking blindly in `accept`, and exit cleanly after a short grace window (e.g., 2.5–4 seconds without a heartbeat or immediately after unload + grace) so page refreshes do not kill the server mid-reload.

### Why a Grace Period Matters

When the user refreshes the page or clicks a link, the browser briefly unloads the document before starting the new load. A short grace delay (such as 3 seconds of missed heartbeats) prevents accidental shutdown during reloads while still closing the app promptly after tab close.

---

### 1. Update `public/index.html` with Heartbeat + Unload Ping

Add this `<script>` block inside `index.html`:

```html
  <script>
    function sendHeartbeat() {
      fetch('/api/heartbeat', {
        method: 'POST',
        cache: 'no-store'
      }).catch(() => {});
    }

    function sendUnloadPing() {
      const payload = JSON.stringify({ reason: 'unload' });
      if (navigator.sendBeacon) {
        const blob = new Blob([payload], { type: 'application/json' });
        if (navigator.sendBeacon('/api/unload', blob)) {
          return;
        }
      }
      fetch('/api/unload', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: payload,
        keepalive: true
      }).catch(() => {});
    }

    // Start heartbeat immediately and repeat every 2 seconds
    sendHeartbeat();
    setInterval(sendHeartbeat, 2000);

    // Fire unload ping when tab/window closes or navigates away
    window.addEventListener('pagehide', sendUnloadPing);
    window.addEventListener('beforeunload', sendUnloadPing);
  </script>

```

---

### 2. Update `app.pl` to Poll and Auto-Exit Cleanly

In `HTTP::Daemon`, `$daemon->accept` blocks until a client connects. By checking `$daemon->can_read(0.25)` (using `IO::Select` or `$daemon->fileno` with `select`) in a loop, Perl can still monitor heartbeat timeouts even when the browser has already closed its connection.

Replace the server loop in `app.pl` with this polled lifecycle loop:

```perl
use IO::Select;

my $last_seen      = time();
my $unload_seen    = 0;
my $grace_seconds  = 3;
my $should_exit    = 0;
my $sel            = IO::Select->new($daemon);

while (!$should_exit) {
    my @ready = $sel->can_read(0.25);

    if (@ready) {
        my $c = $daemon->accept;
        if ($c) {
            while (my $r = $c->get_request) {
                my $path = $r->uri->path;

                if ($path eq '/' || $path eq '/index.html') {
                    $last_seen   = time();
                    $unload_seen = 0;

                    my $resp = HTTP::Response->new(200, 'OK');
                    $resp->header('Content-Type' => 'text/html; charset=utf-8');
                    $resp->content(encode('UTF-8', $html_content));
                    $c->send_response($resp);
                }
                elsif ($path eq '/api/heartbeat') {
                    $last_seen   = time();
                    $unload_seen = 0;
                    send_json($c, { ok => JSON::PP::true });
                }
                elsif ($path eq '/api/unload') {
                    $unload_seen = time();
                    send_json($c, { ok => JSON::PP::true });
                }
                elsif ($path eq '/api/pick-file') {
                    $last_seen = time();
                    my %q = $r->uri->query_form;
                    my $mode    = ($q{mode} // 'open') eq 'save' ? 'save' : 'open';
                    my $initial = $q{initial} // '';
                    send_json($c, pick_windows_file($mode, $initial));
                    $last_seen = time(); # Reset timer after modal dialog blocks
                }
                elsif ($path eq '/api/read') {
                    $last_seen = time();
                    my %q = $r->uri->query_form;
                    send_json($c, read_local_file($q{path} // ''));
                }
                elsif ($path eq '/api/write' && $r->method eq 'POST') {
                    $last_seen = time();
                    my $payload = eval { decode_json($r->content) };
                    if ($@ || ref $payload ne 'HASH') {
                        send_json($c, { ok => JSON::PP::false, error => 'Invalid JSON request' });
                    }
                    else {
                        send_json($c, write_local_file($payload->{path} // '', $payload->{content} // ''));
                    }
                }
                elsif ($path eq '/api/quit' && $r->method eq 'POST') {
                    send_json($c, { ok => JSON::PP::true });
                    $should_exit = 1;
                    last;
                }
                else {
                    $c->send_error(404);
                }
            }
            $c->close;
            undef($c);
        }
    }

    my $now = time();
    # Exit if unload ping occurred and no new heartbeat arrived within grace window,
    # or if heartbeats stopped completely for longer than grace window.
    if (($unload_seen && ($now - $unload_seen) >= $grace_seconds && ($now - $last_seen) >= $grace_seconds)
        || (($now - $last_seen) >= ($grace_seconds + 2)))
    {
        $should_exit = 1;
    }
}

$sel->remove($daemon);
$daemon->close if $daemon;

if ($ENV{PAR_TEMP} && -d $ENV{PAR_TEMP}) {
    eval { remove_tree($ENV{PAR_TEMP}, { safe => 1 }) };
}

exit(0);

```

---

### 3. Edge Cases to Watch For

* **Modal dialogs block the Perl event loop:** While `Win32::GUI::GetOpenFileName` or `GetSaveFileName` is open, Perl is paused inside the dialog call. Resetting `$last_seen = time()` right after `pick_windows_file(...)` prevents a false timeout if the user takes more than a few seconds browsing folders.
* **Browser background throttling:** Some browsers throttle background timers slightly when a tab is hidden, though `2000ms` with a `3s` grace period (`5s` total heartbeat timeout) handles normal tab switching cleanly.
* **Multiple open tabs:** If a user opens two tabs to the same local URL, a single tab closing would trigger `/api/unload` unless you track client/session IDs. For a single-window desktop workflow, the grace-period check above works directly.

### Verification Steps

1. Start `perl app.pl` (or `FileApp.exe`), confirm the browser opens, and watch `/api/heartbeat` requests arrive every 2 seconds.
2. Refresh the browser page (`F5` / `Ctrl+R`) and verify the Perl process stays running.
3. Close the browser tab/window completely and verify the Perl / `.exe` process exits within ~3–5 seconds without manual intervention.
