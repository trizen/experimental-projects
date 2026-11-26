To run your Perl localhost web app on Windows without a visible command prompt (`cmd.exe`) window, use a GUI subsystem entry point or launcher so Windows does not allocate a console for the process: **`wperl.exe`** when running `.pl` scripts directly, or **`pp --gui`** (plus avoiding `system(1, 'cmd', '/c', 'start', ...)` which spawns a console) when packing an `.exe`.

### Why a Console Window Currently Appears

1. Running `perl app.pl` or double-clicking a `.pl` script associated with `perl.exe` launches a console subsystem executable (`perl.exe`).
2. Calling `system(1, 'cmd', '/c', 'start', '', $url)` spawns `cmd.exe`, which briefly flashes or opens a console window on Windows.

---

### Method 1: Launch `.pl` Directly with `wperl.exe` (Simplest for Script Mode)

1. Open a command prompt or create a shortcut pointing to `wperl.exe` (located in your Perl `bin` folder, such as `C:\Strawberry\perl\bin\wperl.exe`).
* *Verification:* Confirm `wperl.exe` exists in your Perl `bin` directory.


2. Launch your script using `wperl.exe` instead of `perl.exe`:
```bat
wperl.exe app.pl

```


* *Verification:* Your browser opens to `[http://127.0.0.1](http://127.0.0.1):<port>/` and no new `cmd.exe` or Perl console window appears.


3. For a one-click desktop/folder shortcut without a console, create a Windows shortcut whose **Target** is:
```bat
"C:\Strawberry\perl\bin\wperl.exe" "C:\path\to\app\app.pl"

```


and set **Start in** to `C:\path\to\app`.
* *Verification:* Double-clicking the shortcut starts the app silently and opens the UI without flashing a terminal window.



---

### Method 2: Build a Console-Free `.exe` with `PAR::Packer` (`pp --gui`)

When building a standalone `.exe` for other Windows machines, pass `--gui` to `pp` so the packed executable uses the Windows GUI subsystem instead of the console subsystem.

1. Build the executable with `--gui` and include your required modules and `index.html`:
```bat
pp --gui -M HTTP::Daemon -M HTTP::Response -M JSON::PP -M Win32::GUI -M IO::Select -a "public\index.html;index.html" -o FileApp.exe app.pl

```


* *Verification:* `FileApp.exe` is created in your project directory.


2. Replace `system(1, 'cmd', '/c', 'start', '', $url)` in `app.pl` with a browser launch that does not spawn `cmd.exe`, such as `Win32::ShellExecute` or `ShellExecuteEx` via `Win32::API` / `Win32`:
```perl
use Win32;

# Opens default browser/handler without spawning cmd.exe
Win32::ShellExecute('open', $url, '', '', 1);

```


* *Verification:* Running `FileApp.exe` opens the default browser directly with no `cmd.exe` window popping up.


3. Double-click `FileApp.exe` from Windows Explorer or run it from a shortcut.
* *Verification:* The browser opens the app and no console window stays open; closing the browser tab triggers `/api/unload` and exits `FileApp.exe` cleanly.



---

### Practical Notes on Windows

* **Debugging without a console:** Because `STDOUT` and `STDERR` have no console window under `wperl.exe` or `pp --gui`, any `print` or `warn` output goes nowhere unless you log errors to a file (for example, opening a log file in `app.pl` or redirecting in a wrapper).
* **Clean process exit:** Because there is no console window to close manually, keep your `/api/quit` button and heartbeat/unload auto-exit working so `wperl.exe` or `FileApp.exe` never remains running invisibly in the background.
