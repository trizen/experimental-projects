To package a Perl + `Wx` application into a standalone Windows `.exe` using **`PAR::Packer`** (`pp`), bundle the Perl runtime, your `.pm` modules (`DemoUI.pm`), and the `Wx` / `Alien::wxWidgets` shared libraries into a single executable.

### 1. Install `PAR::Packer`

In a Windows command prompt (with your Strawberry Perl environment active):

```bat
cpan PAR::Packer

```

*(Or `cpanm PAR::Packer` if you use `App::cpanminus`.)*

---

### 2. Build a Standalone Windows `.exe` with `pp`

Run `pp` from the directory containing `app.pl` and `DemoUI.pm`:

```bat
pp --gui -M DemoUI -M Wx -M Wx::Event -o DemoApp.exe app.pl

```

* **`--gui`**: Prevents Windows from popping up a blank console window behind your GUI frame.
* **`-M DemoUI -M Wx -M Wx::Event`**: Explicitly includes local modules (`DemoUI.pm`) and dynamic/event modules that static dependency scanning sometimes misses.
* **`-o DemoApp.exe`**: Sets the output `.exe` filename.

---

### 3. Important Caveats for "Any Windows Computer"

* **First-run startup delay:** `PAR::Packer` extracts packed modules and DLLs into a temporary directory on first launch, so startup takes noticeably longer than running `perl app.pl` directly—especially with heavy `Alien::wxWidgets` DLLs.
* **Architecture & Windows version:** A 64-bit `.exe` built on 64-bit Windows requires 64-bit Windows (x86_64); if you need to support 32-bit Windows targets, build from a 32-bit Perl installation.
* **Antivirus false positives:** Packed `.exe` files that unpack code/DLLs at runtime frequently trigger heuristic flags on Windows Defender or third-party antivirus scanners; test on a clean Windows VM and sign or whitelist as needed.
* **Runtime DLLs & `Wx` constants:** Because `Wx` uses `Wx qw[:everything]` and loads XS/C++ wxWidgets libraries dynamically, test the resulting `DemoApp.exe` on a clean Windows machine that **does not** have Perl installed to catch any missing `Wx::*` submodules (such as `Wx::ArtProvider` or `Wx::Html` if added later).
