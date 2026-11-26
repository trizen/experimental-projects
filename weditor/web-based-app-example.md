Here is a working sketch of a local Perl web app (`HTTP::Daemon` + `JSON::PP` + HTML/CSS) for creating, listing, and cancelling medical appointments, backed by a JSON file on disk that is loaded on startup and updated whenever appointments change.

### 1. Project Layout

Create a folder with two files (the JSON data file `appointments.json` is created automatically on first save):

* `appointments_app.pl` — Localhost HTTP server + JSON file persistence.
* `public/index.html` — Web interface for adding and viewing appointments.

---

### 2. Backend (`appointments_app.pl`)

Loads existing appointments from `appointments.json` at startup, serves the UI and JSON API on `127.0.0.1`, validates basic fields, and writes updates atomically (write to `.tmp` then rename) so partial writes do not corrupt local appointment data.

```perl
#!/usr/bin/env perl
use strict;
use warnings;
use HTTP::Daemon;
use HTTP::Response;
use JSON::PP qw(encode_json decode_json);
use Encode qw(encode decode);
use File::Spec;
use FindBin;

my $DATA_FILE = File::Spec->catfile($FindBin::Bin, 'appointments.json');
my $HTML_FILE = File::Spec->catfile($FindBin::Bin, 'public', 'index.html');

my @appointments = load_appointments($DATA_FILE);
my $next_id      = compute_next_id(\@appointments);

my $daemon = HTTP::Daemon->new(
    LocalAddr => '127.0.0.1',
    LocalPort => 0,
    ReuseAddr => 1,
) or die "Cannot start server: $!\n";

my $url = $daemon->url;
$url =~ s{/$}{};
print "Medical Appointments app running at $url\n";
print "Data file: $DATA_FILE (loaded " . scalar(@appointments) . " appointments)\n";

system(1, 'cmd', '/c', 'start', '', $url) if $^O eq 'MSWin32';

while (my $c = $daemon->accept) {
    while (my $r = $c->get_request) {
        my $path   = $r->uri->path;
        my $method = $r->method;

        if (($path eq '/' || $path eq '/index.html') && $method eq 'GET') {
            my $html = slurp_utf8($HTML_FILE);
            if (!defined $html) {
                $c->send_error(500, 'Missing public/index.html');
                next;
            }
            my $resp = HTTP::Response->new(200, 'OK');
            $resp->header('Content-Type' => 'text/html; charset=utf-8');
            $resp->content(encode('UTF-8', $html));
            $c->send_response($resp);
        }
        elsif ($path eq '/api/appointments' && $method eq 'GET') {
            my @sorted = sort {
                ($a->{date} // '') cmp ($b->{date} // '')
                    || ($a->{time} // '') cmp ($b->{time} // '')
                    || ($a->{id}   <=> $b->{id})
            } @appointments;
            send_json($c, { ok => JSON::PP::true, appointments => \@sorted });
        }
        elsif ($path eq '/api/appointments' && $method eq 'POST') {
            my $data = eval { decode_json($r->content) };
            if ($@ || ref $data ne 'HASH') {
                send_json($c, { ok => JSON::PP::false, error => 'Invalid JSON payload' });
                next;
            }

            my $patient = trim($data->{patient});
            my $doctor  = trim($data->{doctor});
            my $date    = trim($data->{date});
            my $time    = trim($data->{time});
            my $notes   = trim($data->{notes});

            if (!length $patient || !length $doctor || !length $date || !length $time) {
                send_json($c, {
                    ok    => JSON::PP::false,
                    error => 'Patient name, doctor/specialty, date, and time are required.',
                });
                next;
            }

            my $appt = {
                id      => $next_id++,
                patient => $patient,
                doctor  => $doctor,
                date    => $date,
                time    => $time,
                notes   => $notes,
                status  => 'Scheduled',
            };

            push @appointments, $appt;
            save_appointments($DATA_FILE, \@appointments);
            send_json($c, { ok => JSON::PP::true, appointment => $appt });
        }
        elsif ($path =~ m{^/api/appointments/(\d+)/cancel$} && $method eq 'POST') {
            my $id = $1;
            my $found;
            for my $a (@appointments) {
                if (($a->{id} // -1) == $id) {
                    $a->{status} = 'Cancelled';
                    $found = $a;
                    last;
                }
            }
            if (!$found) {
                send_json($c, { ok => JSON::PP::false, error => 'Appointment not found' });
            }
            else {
                save_appointments($DATA_FILE, \@appointments);
                send_json($c, { ok => JSON::PP::true, appointment => $found });
            }
        }
        else {
            $c->send_error(404);
        }
    }
    $c->close;
    undef($c);
}

sub load_appointments {
    my ($file) = @_;
    return () unless -f $file;

    my $raw = slurp_utf8($file);
    return () unless defined $raw && $raw =~ /\S/;

    my $decoded = eval { decode_json(encode('UTF-8', $raw)) };
    if ($@ || ref $decoded ne 'ARRAY') {
        warn "Warning: could not parse $file; starting with empty list.\n";
        return ();
    }
    return @$decoded;
}

sub save_appointments {
    my ($file, $list_ref) = @_;
    my $tmp = "$file.tmp.$$";
    my $json_text = JSON::PP->new->utf8->pretty->canonical->encode($list_ref);

    open my $fh, '>:raw', $tmp or die "Cannot write $tmp: $!\n";
    print {$fh} $json_text;
    close $fh or die "Cannot close $tmp: $!\n";

    rename $tmp, $file or die "Cannot replace $file with $tmp: $!\n";
}

sub compute_next_id {
    my ($list_ref) = @_;
    my $max = 0;
    for my $item (@$list_ref) {
        my $id = $item->{id} // 0;
        $max = $id if $id > $max;
    }
    return $max + 1;
}

sub slurp_utf8 {
    my ($file) = @_;
    return undef unless -f $file;
    open my $fh, '<:encoding(UTF-8)', $file or return undef;
    local $/;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub trim {
    my ($s) = @_;
    return '' unless defined $s;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}

sub send_json {
    my ($conn, $payload) = @_;
    my $resp = HTTP::Response->new(200, 'OK');
    $resp->header('Content-Type' => 'application/json; charset=utf-8');
    $resp->content(encode_json($payload));
    $conn->send_response($resp);
}

```

---

### 3. Web Interface (`public/index.html`)

Provides a form to create an appointment (patient name, doctor/specialty, date, time, notes) and a table showing all stored appointments with a **Cancel** action.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Medical Appointments</title>
  <style>
    body {
      font-family: Segoe UI, Arial, sans-serif;
      max-width: 900px;
      margin: 24px auto;
      padding: 0 16px;
      background: #f4f6f9;
      color: #1e293b;
    }
    h1 { margin-bottom: 16px; }
    .card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      padding: 16px;
      margin-bottom: 20px;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 12px;
      margin-bottom: 12px;
    }
    label { display: block; font-size: 13px; margin-bottom: 4px; font-weight: 600; }
    input, textarea {
      width: 100%;
      box-sizing: border-box;
      padding: 8px;
      border: 1px solid #cbd5e1;
      border-radius: 4px;
      font-size: 14px;
    }
    button {
      padding: 8px 14px;
      border: none;
      border-radius: 4px;
      background: #0f766e;
      color: #fff;
      font-size: 14px;
      cursor: pointer;
    }
    button.cancel-btn {
      background: #b91c1c;
      padding: 5px 10px;
      font-size: 12px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      background: #fff;
    }
    th, td {
      text-align: left;
      padding: 10px;
      border-bottom: 1px solid #e2e8f0;
      font-size: 14px;
    }
    th { background: #f8fafc; }
    .status-Cancelled { color: #b91c1c; font-weight: 600; }
    .status-Scheduled { color: #15803d; font-weight: 600; }
    #msg { margin-left: 12px; font-size: 13px; color: #334155; }
  </style>
</head>
<body>
  <h1>Medical Appointments</h1>

  <div class="card">
    <form id="appt-form" onsubmit="createAppointment(event)">
      <div class="grid">
        <div>
          <label for="patient">Patient Name</label>
          <input id="patient" type="text" required placeholder="e.g. Elena Popescu" />
        </div>
        <div>
          <label for="doctor">Doctor / Specialty</label>
          <input id="doctor" type="text" required placeholder="e.g. Dr. Ionescu - Cardiology" />
        </div>
        <div>
          <label for="date">Date</label>
          <input id="date" type="date" required />
        </div>
        <div>
          <label for="time">Time</label>
          <input id="time" type="time" required />
        </div>
      </div>
      <div style="margin-bottom: 12px;">
        <label for="notes">Notes (optional)</label>
        <input id="notes" type="text" placeholder="Reason for visit, lab results, etc." />
      </div>
      <button type="submit">Save Appointment</button>
      <span id="msg"></span>
    </form>
  </div>

  <div class="card">
    <table>
      <thead>
        <tr>
          <th>Date</th>
          <th>Time</th>
          <th>Patient</th>
          <th>Doctor / Specialty</th>
          <th>Notes</th>
          <th>Status</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody id="appt-body"></tbody>
    </table>
  </div>

  <script>
    async function loadAppointments() {
      const res = await fetch('/api/appointments');
      const data = await res.json();
      const tbody = document.getElementById('appt-body');
      tbody.innerHTML = '';

      for (const a of (data.appointments || [])) {
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td>${escapeHtml(a.date)}</td>
          <td>${escapeHtml(a.time)}</td>
          <td>${escapeHtml(a.patient)}</td>
          <td>${escapeHtml(a.doctor)}</td>
          <td>${escapeHtml(a.notes || '')}</td>
          <td class="status-${escapeHtml(a.status)}">${escapeHtml(a.status)}</td>
          <td>${a.status === 'Scheduled'
            ? `<button class="cancel-btn" onclick="cancelAppointment(${a.id})">Cancel</button>`
            : ''}</td>
        `;
        tbody.appendChild(tr);
      }
    }

    async function createAppointment(ev) {
      ev.preventDefault();
      const payload = {
        patient: document.getElementById('patient').value,
        doctor:  document.getElementById('doctor').value,
        date:    document.getElementById('date').value,
        time:    document.getElementById('time').value,
        notes:   document.getElementById('notes').value,
      };

      const res = await fetch('/api/appointments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      const msg = document.getElementById('msg');

      if (data.ok) {
        msg.textContent = 'Appointment saved.';
        document.getElementById('appt-form').reset();
        await loadAppointments();
      } else {
        msg.textContent = data.error || 'Could not save appointment.';
      }
    }

    async function cancelAppointment(id) {
      const res = await fetch(`/api/appointments/${id}/cancel`, { method: 'POST' });
      const data = await res.json();
      if (data.ok) {
        document.getElementById('msg').textContent = 'Appointment cancelled.';
        await loadAppointments();
      }
    }

    function escapeHtml(str) {
      return String(str).replace(/[&<>"']/g, c => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
      }[c]));
    }

    loadAppointments();
  </script>
</body>
</html>

```

---

### 4. Practical Notes for Local Storage & Medical Data

* **Where `appointments.json` lives:** Using `$FindBin::Bin` places `appointments.json` next to the script. If you pack into a `.exe` with `PAR::Packer`, store user data in a writable user folder (such as `$ENV{LOCALAPPDATA}` on Windows) rather than inside temporary/packed directories.
* **Conflict & validation checks:** This sketch checks required fields and assigns sequential IDs; in a real clinic workflow, you will likely want double-booking checks (same doctor/date/time), editing/rescheduling support, and date/time formatting rules.
* **Local privacy:** Keep the server bound to `127.0.0.1`, and consider permissions or encryption if storing sensitive patient details locally on a shared computer.
