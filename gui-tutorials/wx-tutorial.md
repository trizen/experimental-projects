Building a Windows GUI app in Perl with **`Wx`** (`wxPerl`) and **`wxGlade`** is doable, but it differs substantially from a `Gtk2`/`Gtk3` + `Glade` workflow—both in how UI definitions are generated and in the current state of `Wx` bindings on modern Perl and Windows.

### 1. Crucial Reality Check Before You Start

* **Maintenance & build friction:** Upstream `Wx` on CPAN stalled around 2017, and building `Alien::wxWidgets` + `Wx` on Windows with newer Perl versions or modern GCC/MinGW toolchains often runs into macro/compiler issues or `PATH` conflicts during CPAN builds. Active forks (such as `sciurius/wxPerl`) and prebuilt/patched builds are worth checking if vanilla CPAN `Wx` fails to compile.
* **Code generation vs. runtime XML:** Unlike Glade + `Gtk3::Builder` (which typically loads a `.ui` XML file at runtime and connects signals by name), `wxGlade` primarily **generates Perl source code** directly from its `.wxg` project file (though wxWidgets also has an XML resource format, XRC, code generation is the standard `wxGlade` path for Perl).

---

### 2. How `Wx` + `wxGlade` Differs from `Gtk2`/`Gtk3` + `Glade`

| Aspect | `Gtk2` / `Gtk3` + `Glade` | `Wx` + `wxGlade` |
| --- | --- | --- |
| **Native look & feel** | GTK theme engine (often feels non-native or heavy on Windows). | **Native OS controls** (`wxMSW` uses real Win32 controls on Windows). |
| **UI loading model** | Usually runtime XML parsed via `Gtk3::Builder` (`get_object`, `signal_autoconnect`). | Usually **code generation** into `.pm`/`.pl` files from `.wxg`; you subclass or hook events in code. |
| **Layout containers** | `GtkBox`, `GtkGrid`, `GtkPaned`, margins/hexpand/vexpand properties. | **Sizers** (`wxBoxSizer`, `wxFlexGridSizer`, `wxGridBagSizer`) with `proportion` and `wxEXPAND` / `wxALL` flags. |
| **Event wiring** | GObject signals (`signal_connect`, `clicked`, `destroy`). | `Wx::Event::EVT_*` macros/functions bound to a window/event handler (`EVT_BUTTON`, `EVT_CLOSE`, etc.). |
| **Main loop** | `Gtk3->main` / `Gtk2->main`. | `Wx::App->new(...)` -> `$app->MainLoop`. |
| **Subclassing style** | Often procedural or flat object references from Builder. | Strongly **object-oriented subclassing** (`Wx::Frame`, `Wx::Panel`, `Wx::Dialog`). |

---

### 3. Step-by-Step Tutorial: Perl + `Wx` + `wxGlade` on Windows

#### Step 1: Set Up Your Environment on Windows

1. Install a Windows Perl distribution with a C/C++ compiler (such as **Strawberry Perl**), and ensure `PATH` is clean (`C:\Windows\system32`, `C:\Windows`, and Strawberry's `c\bin` / `perl\bin`) so build tools don't collide with other utilities.
2. Install `Wx` (and `Wx::Perl::ProcessStream` or `Wx::Demo` if desired):
```bat
cpan Alien::wxWidgets Wx

```


*(If `Wx` fails to compile due to a `calloc` macro conflict on newer Perl headers, check `cpp/wxapi.h` for `#undef calloc` or use an updated `wxPerl` fork.)*
3. Download `wxGlade` (Windows binary archive such as `wxglade-...-win_amd64.zip` from SourceForge) and extract it.

#### Step 2: Design the UI in `wxGlade`

1. Launch `wxglade.exe` or `wxgladew.exe`.
2. In the **Properties** panel on the right, set **Language** to **`perl`**, and choose an **Output path** (for example, `generated_ui.pm`).
3. Add a **Frame** (`wxFrame`), place a `wxPanel` inside it (recommended on Windows so tab traversal and background colors behave natively), and add a `wxBoxSizer` (vertical).
4. Drop in a `wxTextCtrl` and a `wxButton`, setting meaningful **Name** attributes (e.g., `txt_input`, `btn_greet`) so generated accessors/attributes are easy to find.
5. For each widget inside a sizer, configure **Proportion** (`0` for fixed height/width, `1` to stretch along the sizer's axis) and **Flag** (`wxEXPAND`, `wxALL`, etc.).
6. Save the project as `hello_app.wxg` and click **Generate code** in `wxGlade`.

#### Step 3: Keep Generated Code Separate from App Logic

Because regenerating from `.wxg` can overwrite generated files, keep `wxGlade`'s generated module clean and put your application logic in a separate subclass or controller module/script.

Suppose `wxGlade` generates a frame class `HelloFrame` in `HelloFrame.pm` with `$self->{txt_input}` and `$self->{btn_greet}`:

```perl
package MyAppFrame;
use strict;
use warnings;
use parent 'HelloFrame'; # Inherits from wxGlade-generated frame
use Wx qw(:everything);
use Wx::Event qw(EVT_BUTTON);

sub new {
    my ($class, $parent, $id, $title) = @_;
    my $self = $class->SUPER::new($parent, $id, $title);

    # Wire events in your subclass constructor instead of editing generated code
    EVT_BUTTON($self, $self->{btn_greet}, \&on_greet_click);

    return $self;
}

sub on_greet_click {
    my ($self, $event) = @_;
    my $name = $self->{txt_input}->GetValue;
    $name = 'World' unless defined $name && length $name;

    Wx::MessageBox(
        "Hello, $name!",
        "Greeting",
        wxOK | wxICON_INFORMATION,
        $self
    );
}

1;

```

#### Step 4: Write the Application Entry Point (`app.pl`)

```perl
#!/usr/bin/env perl
use strict;
use warnings;
use Wx;
use lib '.';
use HelloFrame;
use MyAppFrame;

package HelloWxApp;
use parent 'Wx::App';

sub OnInit {
    my ($self) = @_;
    my $frame = MyAppFrame->new(undef, -1, "Perl + Wx + wxGlade");
    $frame->Show(1);
    $self->SetTopWindow($frame);
    return 1;
}

package main;
HelloWxApp->new->MainLoop;

```

---

### 4. Practical Gotchas When Coming from GTK + Glade

* **No automatic signal name lookup:** In Glade, you often type a handler name in the UI editor and let signal autoconnection bind it. In `Wx`, event binding is explicit in code via `EVT_*($target_or_handler, $source_id_or_widget, \&handler)`.
* **Sizer borders need explicit flags:** Adding border spacing in `wxGlade` only takes effect if `wxALL` (or `wxTOP`, `wxBOTTOM`, `wxLEFT`, `wxRIGHT`) is checked in the sizer item's flags.
* **Modal dialogs & cleanup:** Dialogs (`Wx::Dialog`) typically use `ShowModal()` and return `wxID_OK` / `wxID_CANCEL`, followed by `$dialog->Destroy()` rather than just hiding them.
* **Thread & UI updates:** Like GTK, all `Wx` UI calls must happen on the main GUI thread; long-running Perl tasks should avoid blocking `MainLoop` (use timers `Wx::Timer`, non-blocking pipes/processes, or background workers that post events back).
