To add a **clean app exit button** and **native Windows file open/save dialogs** to your Perl + HTML/CSS desktop app (`127.0.0.1` HTTP server + browser UI), you can add two backend API endpoints (`/api/pick-file` and `/api/quit`) and wire them to buttons in `index.html`.

For native Windows file dialogs from Perl on Windows, **`Win32::GUI::GetOpenFileName` / `Win32::GUI::GetSaveFileName**` (from `Win32::GUI`) is direct and reliable on Windows without adding a heavy GUI framework, though **`Wx::FileDialog`** also works if you already have `Wx` installed. Below is the `Win32::GUI` approach, plus a clean HTTP shutdown response so the Perl process exits cleanly instead of hanging in `accept`.

---

### 1. Install `Win32::GUI` (for Native Windows File Dialogs)

In a Windows command prompt:

```bat
cpan Win32::GUI

```

*(If `Win32::GUI` is not needed or fails to build in your environment, you can fall back to typing paths manually or using `Wx::FileDialog` if `Wx` is installed.)*

---

### 2. Update `public/index.html`

Add **Browse Open...**, **Browse Save...**, and **Quit App** buttons, and hook them to `/api/pick-file` and `/api/quit`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Perl + HTML/CSS File App</title>
  <style>
    body {
      font-family: Segoe UI, Arial, sans-serif;
      margin: 20px;
      background: #f5f7fa;
      color: #1f2937;
    }
    .row { display: flex; gap: 8px; margin-bottom: 12px; flex-wrap: wrap; }
    input { flex: 1; min-width: 220px; padding: 8px; font-size: 14px; }
    button { padding: 8px 14px; font-size: 14px; cursor: pointer; }
    textarea {
      width: 100%;
      height: 240px;
      box-sizing: border-box;
      padding: 10px;
      font-family: Consolas, monospace;
      font-size: 13px;
    }
    #status { margin-top: 8px; font-size: 13px; color: #374151; }
  </style>
</head>
<body>
  <div class="row">
    <input id="filepath" type="text" placeholder="Choose a file or enter a path..." />
    <button onclick="pickFile('open')">Browse Open...</button>
    <button onclick="pickFile('save')">Browse Save...</button>
    <button onclick="quitApp()">Quit App</button>
  </div>
  <div class="row">
    <button onclick="loadFile()">Read File</button>
    <button onclick="saveFile()">Save File</button>
  </div>
  <textarea id="content" placeholder="File contents appear here..."></textarea>
  <div id="status">Ready</div>

  <script>
    async function pickFile(mode) {
      const currentPath = document.getElementById('filepath').value;
      const url = '/api/pick-file?mode=' + encodeURIComponent(mode)
                + '&initial=' + encodeURIComponent(currentPath);
      const res = await fetch(url);
      const data = await res.json();
      if (data.ok && data.path) {
        document.getElementById('filepath').value = data.path;
        setStatus((mode === 'save' ? 'Save target: ' : 'Selected: ') + data.path);
        if (mode === 'open') {
          await loadFile();
        }
      } else if (data.cancelled) {
        setStatus('File dialog cancelled');
      } else {
        setStatus('Error: ' + (data.error || 'Could not open dialog'));
      }
    }

    async function loadFile() {
      const path = document.getElementById('filepath').value;
      const res = await fetch('/api/read?path=' + encodeURIComponent(path));
      const data = await res.json();
      if (data.ok) {
        document.getElementById('content').value = data.content;
        setStatus('Loaded: ' + path);
      } else {
        setStatus('Error: ' + data.error);
      }
    }

    async function saveFile() {
      const path = document.getElementById('filepath').value;
      const content = document.getElementById('content').value;
      const res = await fetch('/api/write', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ path, content })
      });
      const data = await res.json();
      setStatus(data.ok ? 'Saved: ' + path : 'Error: ' + data.error);
    }

    async function quitApp() {
      setStatus('Shutting down application...');
      try {
        await fetch('/api/quit', { method: 'POST' });
      } catch (_) {}
      window.close();
    }

    function setStatus(msg) {
      document.getElementById('status').textContent = msg;
    }
  </script>
</body>
</html>

```

---

### 3. Update `app.pl` with Native File Dialogs & Clean Exit

Key details in this update:

* **`/api/pick-file`:** Uses `Win32::GUI::GetOpenFileName` (`mode=open`) or `Win32::GUI::GetSaveFileName` (`mode=save`), with a text/all-files filter and optional initial directory/filename.
* **`/api/quit`:** Sends a JSON response first, closes the client connection and listening socket (`$daemon->close`), cleans up `PAR_TEMP` if present, and calls `exit(0)`. *(Note: On Windows, `HTTP::Daemon->accept` blocks on the socket until a request arrives, so clicking **Quit App** in the UI triggers `/api/quit` immediately; if the user just closes the browser tab without clicking Quit, you can also add a lightweight UI heartbeat or close the console window.)*

```perl
#!/usr/bin/env perl
use strict;
use warnings;
use HTTP::Daemon;
use HTTP::Response;
use JSON::PP qw(encode_json decode_json);
use Encode qw(encode decode);
use File::Basename qw(dirname basename);
use File::Path qw(remove_tree);
use File::Spec;
use FindBin;
use Win32::GUI ();

sub find_html {
    if ($ENV{PAR_TEMP}) {
        for my $file (glob("$ENV{PAR_TEMP}/inc/*")) {
            if ($file =~ /index\.html$/ && -f $file) {
                open my $fh, '<:encoding(UTF-8)', $file or next;
                local $/;
                return <$fh>;
            }
        }
    }
    my $local = File::Spec->catfile($FindBin::Bin, 'public', 'index.html');
    if (-f $local) {
        open my $fh, '<:encoding(UTF-8)', $local or die $!;
        local $/;
        return <$fh>;
    }
    die "Cannot find index.html\n";
}

my $html_content = find_html();

my $daemon = HTTP::Daemon->new(
    LocalAddr => '127.0.0.1',
    LocalPort => 0,
    ReuseAddr => 1,
) or die "Cannot start local server: $!\n";

my $url = $daemon->url;
$url =~ s{/$}{};
print "App running at $url\n";

system(1, 'cmd', '/c', 'start', '', $url);

my $should_exit = 0;

while (!$should_exit && (my $c = $daemon->accept)) {
    while (my $r = $c->get_request) {
        my $path = $r->uri->path;

        if ($path eq '/' || $path eq '/index.html') {
            my $resp = HTTP::Response->new(200, 'OK');
            $resp->header('Content-Type' => 'text/html; charset=utf-8');
            $resp->content(encode('UTF-8', $html_content));
            $c->send_response($resp);
        }
        elsif ($path eq '/api/pick-file') {
            my %q = $r->uri->query_form;
            my $mode    = ($q{mode} // 'open') eq 'save' ? 'save' : 'open';
            my $initial = $q{initial} // '';
            send_json($c, pick_windows_file($mode, $initial));
        }
        elsif ($path eq '/api/read') {
            my %q = $r->uri->query_form;
            my $target = $q{path} // '';
            send_json($c, read_local_file($target));
        }
        elsif ($path eq '/api/write' && $r->method eq 'POST') {
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

$daemon->close if $daemon;

if ($ENV{PAR_TEMP} && -d $ENV{PAR_TEMP}) {
    eval { remove_tree($ENV{PAR_TEMP}, { safe => 1 }) };
}

exit(0);

sub pick_windows_file {
    my ($mode, $initial) = @_;

    my %opts = (
        title  => ($mode eq 'save' ? 'Save File As' : 'Open File'),
        filter => [
            'Text & Code Files (*.txt;*.md;*.log;*.json;*.csv;*.pl)' => '*.txt;*.md;*.log;*.json;*.csv;*.pl',
            'All Files (*.*)' => '*.*',
        ],
    );

    if (length $initial) {
        my $dir  = dirname($initial);
        my $file = basename($initial);
        $opts{directory} = $dir  if -d $dir;
        $opts{file}      = $file if length $file && $file ne '.';
    }

    my $selected = ($mode eq 'save')
        ? Win32::GUI::GetSaveFileName(%opts)
        : Win32::GUI::GetOpenFileName(%opts);

    if (defined $selected && length $selected) {
        return { ok => JSON::PP::true, path => $selected };
    }
    return { ok => JSON::PP::false, cancelled => JSON::PP::true };
}

sub send_json {
    my ($conn, $data) = @_;
    my $resp = HTTP::Response->new(200, 'OK');
    $resp->header('Content-Type' => 'application/json; charset=utf-8');
    $resp->content(encode_json($data));
    $conn->send_response($resp);
}

sub read_local_file {
    my ($file) = @_;
    return { ok => JSON::PP::false, error => 'No file path provided' } unless length $file;
    return { ok => JSON::PP::false, error => 'File does not exist' } unless -f $file;

    my $ok = open my $fh, '<:encoding(UTF-8)', $file;
    return { ok => JSON::PP::false, error => "Cannot open file: $!" } unless $ok;

    local $/;
    my $text = <$fh>;
    close $fh;
    return { ok => JSON::PP::true, content => $text // '' };
}

sub write_local_file {
    my ($file, $text) = @_;
    return { ok => JSON::PP::false, error => 'No file path provided' } unless length $file;

    my $ok = open my $fh, '>:encoding(UTF-8)', $file;
    return { ok => JSON::PP::false, error => "Cannot write file: $!" } unless $ok;

    print {$fh} $text;
    close $fh;
    return { ok => JSON::PP::true };
}

```

---

### 4. Repackaging with `PAR::Packer` (`pp`)

Include `Win32::GUI` so its XS/DLL bindings are bundled into `FileApp.exe`:

```bat
pp -M HTTP::Daemon -M HTTP::Response -M JSON::PP -M Win32::GUI -a "public\index.html;index.html" -o FileApp.exe app.pl

```

---

### 5. Verification Steps

1. Run `perl app.pl` (or `FileApp.exe`), click **Browse Open...**, pick a `.txt` file in Windows Explorer, and verify the path populates and the file contents load into the text area.
2. Click **Browse Save...**, choose a destination path, click **Save File**, and verify the file is written on disk.
3. Click **Quit App** and verify the status updates and the `perl` / `FileApp.exe` process exits cleanly in Task Manager without leaving a lingering background process.
