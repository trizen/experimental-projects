To add **double-booking checks**, **rescheduling/editing**, and **search filtering** to the medical appointments app, extend the Perl backend with a conflict helper and an update route (`PUT /api/appointments/<id>`), and add filter controls plus an edit form in `public/index.html`.

### 1. Backend Updates (`appointments_app.pl`)

Key additions in the backend:

* **`has_conflict(\@appointments, $doctor, $date, $time, $ignore_id)`:** Checks active (`status ne 'Cancelled'`) appointments for the same doctor (case-insensitive trimmed match), date, and time. Passing `$ignore_id` when editing lets you update notes or time without falsely conflicting with the appointment itself.
* **`GET /api/appointments?q=...&date=...&status=...`:** Filters appointments server-side (or returns all matching records) by search text (`patient`, `doctor`, `notes`), exact `date`, or `status`.
* **`PUT /api/appointments/<id>`:** Updates `patient`, `doctor`, `date`, `time`, `notes`, and optionally `status` (such as restoring a `Cancelled` appointment back to `Scheduled`), re-checking conflicts and saving atomically.

Add/update these sections in `appointments_app.pl`:

```perl
        elsif ($path eq '/api/appointments' && $method eq 'GET') {
            my %q      = $r->uri->query_form;
            my $q_text = lc(trim($q{q}      // ''));
            my $q_date = trim($q{date}     // '');
            my $q_stat = trim($q{status}   // '');

            my @filtered = grep {
                my $a = $_;
                my $match_stat = (!length $q_stat || $q_stat eq 'All')
                    ? 1
                    : (($a->{status} // '') eq $q_stat);

                my $match_date = (!length $q_date)
                    ? 1
                    : (($a->{date} // '') eq $q_date);

                my $haystack = lc(join ' ',
                    $a->{patient} // '',
                    $a->{doctor}  // '',
                    $a->{notes}   // ''
                );
                my $match_text = (!length $q_text)
                    ? 1
                    : (index($haystack, $q_text) >= 0);

                $match_stat && $match_date && $match_text;
            } @appointments;

            my @sorted = sort {
                ($a->{date} // '') cmp ($b->{date} // '')
                    || ($a->{time} // '') cmp ($b->{time} // '')
                    || ($a->{id}   <=> $b->{id})
            } @filtered;

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

            if (my $conflict = has_conflict(\@appointments, $doctor, $date, $time, undef)) {
                send_json($c, {
                    ok    => JSON::PP::false,
                    error => "Double-booking conflict: $doctor already has an appointment at $date $time "
                           . "(ID #$conflict->{id}, $conflict->{patient}).",
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
        elsif ($path =~ m{^/api/appointments/(\d+)$} && $method eq 'PUT') {
            my $id   = $1;
            my $data = eval { decode_json($r->content) };
            if ($@ || ref $data ne 'HASH') {
                send_json($c, { ok => JSON::PP::false, error => 'Invalid JSON payload' });
                next;
            }

            my $appt;
            for my $a (@appointments) {
                if (($a->{id} // -1) == $id) {
                    $appt = $a;
                    last;
                }
            }
            if (!$appt) {
                send_json($c, { ok => JSON::PP::false, error => 'Appointment not found' });
                next;
            }

            my $patient = trim($data->{patient} // $appt->{patient});
            my $doctor  = trim($data->{doctor}  // $appt->{doctor});
            my $date    = trim($data->{date}    // $appt->{date});
            my $time    = trim($data->{time}    // $appt->{time});
            my $notes   = defined $data->{notes} ? trim($data->{notes}) : ($appt->{notes} // '');
            my $status  = trim($data->{status}  // $appt->{status} // 'Scheduled');

            if (!length $patient || !length $doctor || !length $date || !length $time) {
                send_json($c, {
                    ok    => JSON::PP::false,
                    error => 'Patient name, doctor/specialty, date, and time are required.',
                });
                next;
            }

            if ($status ne 'Scheduled' && $status ne 'Cancelled') {
                send_json($c, { ok => JSON::PP::false, error => 'Invalid status value.' });
                next;
            }

            if ($status eq 'Scheduled') {
                if (my $conflict = has_conflict(\@appointments, $doctor, $date, $time, $id)) {
                    send_json($c, {
                        ok    => JSON::PP::false,
                        error => "Double-booking conflict: $doctor already has an appointment at $date $time "
                               . "(ID #$conflict->{id}, $conflict->{patient}).",
                    });
                    next;
                }
            }

            $appt->{patient} = $patient;
            $appt->{doctor}  = $doctor;
            $appt->{date}    = $date;
            $appt->{time}    = $time;
            $appt->{notes}   = $notes;
            $appt->{status}  = $status;

            save_appointments($DATA_FILE, \@appointments);
            send_json($c, { ok => JSON::PP::true, appointment => $appt });
        }

```

Add the `has_conflict` helper subroutine:

```perl
sub has_conflict {
    my ($list_ref, $doctor, $date, $time, $ignore_id) = @_;
    my $target_doc = lc(trim($doctor));

    for my $a (@$list_ref) {
        next if defined $ignore_id && ($a->{id} // -1) == $ignore_id;
        next if ($a->{status} // '') eq 'Cancelled';

        my $a_doc  = lc(trim($a->{doctor} // ''));
        my $a_date = trim($a->{date} // '');
        my $a_time = trim($a->{time} // '');

        if ($a_doc eq $target_doc && $a_date eq $date && $a_time eq $time) {
            return $a;
        }
    }
    return undef;
}

```

---

### 2. Frontend Updates (`public/index.html`)

Add a **Search & Filter** bar above the table and an **Edit / Reschedule** panel/form that loads an existing appointment into the inputs, switches submission to `PUT /api/appointments/<id>`, and lets you cancel editing or clear filters:

```html
  <div class="card">
    <div class="grid">
      <div>
        <label for="filter-q">Search (Patient, Doctor, Notes)</label>
        <input id="filter-q" type="text" placeholder="Type name or specialty..." oninput="loadAppointments()" />
      </div>
      <div>
        <label for="filter-date">Filter by Date</label>
        <input id="filter-date" type="date" onchange="loadAppointments()" />
      </div>
      <div>
        <label for="filter-status">Status</label>
        <select id="filter-status" onchange="loadAppointments()" style="width:100%;padding:8px;border:1px solid #cbd5e1;border-radius:4px;">
          <option value="All">All</option>
          <option value="Scheduled">Scheduled</option>
          <option value="Cancelled">Cancelled</option>
        </select>
      </div>
      <div style="display:flex;align-items:flex-end;">
        <button type="button" onclick="clearFilters()" style="background:#475569;">Clear Filters</button>
      </div>
    </div>
  </div>

```

Update the form button and `<script>` in `public/index.html` to support editing/rescheduling (`editingId`) and query parameters:

```html
      <button id="submit-btn" type="submit">Save Appointment</button>
      <button id="cancel-edit-btn" type="button" onclick="resetForm()" style="display:none;background:#64748b;margin-left:6px;">Cancel Edit</button>
      <span id="msg"></span>

```

```javascript
    let editingId = null;
    let currentRows = [];

    function clearFilters() {
      document.getElementById('filter-q').value = '';
      document.getElementById('filter-date').value = '';
      document.getElementById('filter-status').value = 'All';
      loadAppointments();
    }

    function resetForm() {
      editingId = null;
      document.getElementById('appt-form').reset();
      document.getElementById('submit-btn').textContent = 'Save Appointment';
      document.getElementById('cancel-edit-btn').style.display = 'none';
    }

    function startEdit(id) {
      const appt = currentRows.find(item => item.id === id);
      if (!appt) return;

      editingId = appt.id;
      document.getElementById('patient').value = appt.patient || '';
      document.getElementById('doctor').value  = appt.doctor || '';
      document.getElementById('date').value    = appt.date || '';
      document.getElementById('time').value    = appt.time || '';
      document.getElementById('notes').value   = appt.notes || '';
      document.getElementById('submit-btn').textContent = `Update Appointment #${appt.id}`;
      document.getElementById('cancel-edit-btn').style.display = 'inline-block';
      document.getElementById('msg').textContent = `Editing appointment #${appt.id}.`;
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    async function loadAppointments() {
      const params = new URLSearchParams();
      const q      = document.getElementById('filter-q').value.trim();
      const date   = document.getElementById('filter-date').value;
      const status = document.getElementById('filter-status').value;

      if (q) params.set('q', q);
      if (date) params.set('date', date);
      if (status && status !== 'All') params.set('status', status);

      const url = '/api/appointments' + (params.toString() ? '?' + params.toString() : '');
      const res = await fetch(url);
      const data = await res.json();
      currentRows = data.appointments || [];

      const tbody = document.getElementById('appt-body');
      tbody.innerHTML = '';

      for (const a of currentRows) {
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td>${escapeHtml(a.date)}</td>
          <td>${escapeHtml(a.time)}</td>
          <td>${escapeHtml(a.patient)}</td>
          <td>${escapeHtml(a.doctor)}</td>
          <td>${escapeHtml(a.notes || '')}</td>
          <td class="status-${escapeHtml(a.status)}">${escapeHtml(a.status)}</td>
          <td>
            <button type="button" onclick="startEdit(${a.id})" style="background:#1d4ed8;padding:5px 10px;font-size:12px;margin-right:4px;">Edit</button>
            ${a.status === 'Scheduled'
              ? `<button type="button" class="cancel-btn" onclick="cancelAppointment(${a.id})">Cancel</button>`
              : ''}
          </td>
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

      const isEdit = editingId !== null;
      const url    = isEdit ? `/api/appointments/${editingId}` : '/api/appointments';
      const method = isEdit ? 'PUT' : 'POST';

      const res  = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      const msg  = document.getElementById('msg');

      if (data.ok) {
        msg.textContent = isEdit ? 'Appointment updated.' : 'Appointment saved.';
        resetForm();
        await loadAppointments();
      } else {
        msg.textContent = data.error || 'Could not save appointment.';
      }
    }

```

### Verification Steps

1. Create an appointment for a doctor at a specific date and time, then attempt to create a second `Scheduled` appointment for the same doctor, date, and time—verify the UI displays the double-booking conflict message and does not save a duplicate.
2. Click **Edit** on an existing row, change the time or date, submit, and verify `appointments.json` reflects the updated values and sorting.
3. Type a patient name, doctor name, or select a date in the filter bar and verify matching rows update immediately.
