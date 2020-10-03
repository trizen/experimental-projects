#!/usr/bin/perl

use utf8;
use 5.014;
use strict;
use warnings;

use Gtk2 qw(-init);
use File::Spec::Functions qw(catfile);

use constant {
              LICHESS  => 1,
              CHESSCOM => 0,
             };

my $interface_file = 'teach_me.glade';

my $pieces_dir = 'Pieces';
my $output_dir = 'Lichess';

if (LICHESS && CHESSCOM) {
    die "Select either LICHESS or CHESSCOM";
}

if (LICHESS) {
    $output_dir = 'Lichess';
}

if (CHESSCOM) {
    $output_dir = 'ChessCom';
}

binmode(STDOUT, ':utf8');

# Defining GUI
my $gui = 'Gtk2::Builder'->new;
$gui->add_from_file($interface_file);
$gui->connect_signals(undef);

my %pieces = (
    '♔' => 'K',
    '♕' => 'Q',
    '♖' => 'R',
    '♗' => 'B',
    '♘' => 'N',
    '♙' => 'P',

    '♚' => 'k',
    '♛' => 'q',
    '♜' => 'r',
    '♝' => 'b',
    '♞' => 'n',
    '♟' => 'p',

    'e' => 'e',    # empty square (black)
    'E' => 'E',    # empty square (white)
             );

my $current_file;
my $font = Pango::FontDescription->from_string('Monospace 32');

foreach my $key (keys %pieces) {
    my $button = $gui->get_object($key);

    if (lc($key) ne 'e') {
        my $label = $button->get_child;
        $label->modify_font($font);
    }

    $button->signal_connect(
        'clicked' => sub {
            say "$key was clicked -- $current_file";
            my $new_name = $pieces{$key} . join('', map { int(rand(10)) } 1 .. 32) . '.png';
            my $new_file = catfile($output_dir, $new_name);
            say "Renaming: `$current_file` -> `$new_file`";
            rename($current_file, $new_file);
            start();
        }
    );
}

opendir(my $dir_h, $pieces_dir) or die "Can't open `$pieces_dir`: $!";

sub start {

    my $file = readdir($dir_h);

    defined($file) || do {
        say "No more file to processs...";

        #return main_quit();
        exit;
    };

    return start() if ($file =~ /^\.\.?\z/);

    say "Processing: $file...";

    $current_file = catfile($pieces_dir, $file);
    my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file_at_size($current_file, 100, 100);
    $gui->get_object('square')->set_from_pixbuf($pixbuf);
}

start();

sub main_quit {
    'Gtk2'->main_quit();
}

'Gtk2'->main;
