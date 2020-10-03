#!/usr/bin/perl

# Copyright (c) 2013 Daniel "Trizen" Șuteu

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 26 January 2013
# https://github.com/trizen

use 5.010;
use strict;
use warnings;

use Gtk2 qw(-init);
use open IO => ':utf8';

use lib qw(.);
use autouse 'Cwd'             => qw(getcwd);
use autouse 'File::Path'      => qw(make_path);
use autouse 'File::Basename'  => qw(basename);
use autouse 'Sort::Naturally' => qw(nsort);
use autouse 'File::Copy'      => qw(copy);

use Image2TextOO qw();
use File::HomeDir qw();
use Config::Simple qw();
use File::Spec::Functions qw(catdir catfile);

my $interface_path = 'interface.glade';

my $home      = File::HomeDir->my_home;
my $conf_dir  = catdir($home, '.img2text');
my $conf_file = catfile($conf_dir, 'config.ini');

if (not -d $conf_dir) {
    make_path($conf_dir)
      or die "Can't create config dir '$conf_dir': $!";
}

my %Config = (
              default => {
                          tolerance   => 5,
                          review_text => 1,
                         },
              resize => {
                         resize     => 1,
                         keep_ratio => 1,
                         height     => 8,
                         width      => 8,
                        },
             );

my $cfg = Config::Simple->new($conf_file);
{
    if (not defined $cfg) {
        $cfg = Config::Simple->new(syntax => 'ini');
    }

    my $updated = 0;
    my %tmp     = $cfg->vars();
    while (my ($key, $val) = each %Config) {
        while (my ($name, $num) = each %{$val}) {
            if (not exists $tmp{"$key.$name"}) {
                $cfg->param("$key.$name", $num);
                $updated ||= 1;
            }
        }
    }

    $cfg->write($conf_file) if $updated;
}

tie %Config, "Config::Simple", $conf_file or die "$conf_file: $!";
tied(%Config)->autosave(1);

# Defining GUI
my $gui = 'Gtk2::Builder'->new;
$gui->add_from_file($interface_path);
$gui->connect_signals(undef);

my $img2txt = Image2TextOO->new();

# Apply the configuration
sub apply_config {

    state $resize = $gui->get_object('checkbutton1');
    $resize->set_active($Config{'resize.resize'});

    state $spin_width = $gui->get_object('spinbutton2');
    $spin_width->set_value($Config{'resize.width'});

    state $spin_height = $gui->get_object('spinbutton3');
    $spin_height->set_value($Config{'resize.height'});

    state $keep_ratio = $gui->get_object('checkbutton2');
    $keep_ratio->set_active($Config{'resize.keep_ratio'});

    state $tolerance = $gui->get_object('spinbutton1');
    $tolerance->set_value($Config{'default.tolerance'});

    state $review = $gui->get_object('checkbutton3');
    $review->set_active($Config{'default.review_text'});
}

apply_config();

sub spin_tolerance_changed {
    my ($spin) = @_;
    my $tolerance = $spin->get_value;
    $img2txt->set_tolerance($tolerance);
    $Config{'default.tolerance'} = $tolerance;
}

sub spin_height_changed {
    my ($spin) = @_;
    my $height = $spin->get_value;
    $img2txt->set_height_size($height);
    $Config{'resize.height'} = $height;
}

sub spin_width_changed {
    my ($spin) = @_;
    my $width = $spin->get_value;
    $img2txt->set_width_size($width);
    $Config{'resize.width'} = $width;
}

sub toggled_resize_letters {
    my ($check) = @_;

    state $frame = $gui->get_object('frame3');

    if ($check->get_active) {
        $frame->show;
        $img2txt->set_resize(1);
        $Config{'resize.resize'} = 1;
    }
    else {
        $frame->hide;
        $img2txt->set_resize(0);
        $Config{'resize.resize'} = 0;
    }
}

sub toggled_review_text {
    my ($check) = @_;

    my $bool = $check->get_active() || 0;
    $Config{'default.review_text'} = $bool;
}

sub hide_window {
    $_[0]->hide;
}

sub _get_file_chooser_from_button {
    $_[0]->parent->parent->parent;
}

sub hide_filechooser_win {
    hide_window(&_get_file_chooser_from_button);
}

sub _show_fc_object {
    my ($obj_name) = @_;
    my $obj = $gui->get_object($obj_name);
    $obj->set_current_folder(getcwd());
    $obj->show;
    return $obj;
}

sub choose_input_folder {
    _show_fc_object('input_file_dialog');
}

sub choose_output_folder {
    _show_fc_object('output_file_dialog');
}

sub _selected_file {
    my $entry_name = shift;

    my $fc   = ref $_[0] eq 'Gtk2::Button' ? &_get_file_chooser_from_button : shift;
    my $file = $fc->get_filename // $fc->get_current_folder_uri;

    if (defined($file) and -e $file) {
        $gui->get_object($entry_name)->set_text($file);
        hide_window($fc);
    }
}

sub input_file_selected {
    _selected_file('input_file_entry', @_);
}

sub output_file_selected {
    _selected_file('output_file_entry', @_);
}

sub toggled_keep_img_ratio {
    my ($check) = @_;
    my $bool = $check->get_active() || 0;

    $img2txt->set_keep_img_ratio($bool);
    $Config{'resize.keep_ratio'} = $bool;
}

# Get text from a 'textview' object
sub get_text {
    my ($object)      = @_;
    my $object_buffer = $object->get_buffer;
    my $start_iter    = $object_buffer->get_start_iter;
    my $end_iter      = $object_buffer->get_end_iter;
    return $object_buffer->get_text($start_iter, $end_iter, undef);
}

sub unknown_char {
    my ($img_file, $hash, $context) = @_;

    state $dialog = $gui->get_object('dialog1');
    state $img    = $gui->get_object('image1');
    state $entry  = $gui->get_object('entry1');
    state $label  = $gui->get_object('label7');

    $label->set_text($context);
    $img->set_from_file($img_file);

    my $button_apply = $dialog->add_button('gtk-save' => "apply");
    my $button_ok    = $dialog->add_button("gtk-ok"   => "ok");

    my $resp = $dialog->run;
    my $text = $entry->get_text();
    $entry->set_text('');

    if ($resp eq 'apply') {
        $img2txt->add_hash_to_database($hash, $text);
        my $name = length($text) == 1 ? $text : "=$text";

        my $dir         = $img2txt->get_letters_dir;
        my $rand        = int(rand(9999));
        my $letter_file = catfile($dir, $name . $rand);

        while (-e $letter_file) {
            ++$rand;
            $letter_file = catfile($dir, $name . $rand);
        }

        $letter_file .= '.png';
        copy($img_file, $letter_file);
    }

    $button_apply->destroy;
    $button_ok->destroy;
    $dialog->hide;

    return $text;
}

sub decoded_char {
    my ($char) = @_;

    state $textview = $gui->get_object('textview2');
    my $buf      = $textview->get_buffer;
    my $end_iter = $buf->get_end_iter;
    $buf->insert($end_iter, $char);
}

sub image_to_text {
    my ($file) = @_;
    my $text = $img2txt->get_text($file, \&decoded_char, \&unknown_char);
    return $text;
}

sub review_text {
    my ($text) = @_;

    state $dialog   = $gui->get_object('dialog2');
    state $textview = $gui->get_object('textview2');

    my $buf = $textview->get_buffer();
    $buf->set_text($text);

    my $button_ok = $dialog->add_button("gtk-ok" => "ok");

    $dialog->run;
    my $reviewed_text = get_text($textview);

    $button_ok->destroy();
    $dialog->hide;

    return $reviewed_text;
}

sub start_conversion {
    my ($input_file)  = $gui->get_object('input_file_entry')->get_text;
    my ($output_file) = $gui->get_object('output_file_entry')->get_text;

    my @input_files;

    if (-d $input_file) {
        opendir(my $dir_h, $input_file) or die "$input_file: $!";

        @input_files =
          map { catfile($input_file, $_) }
          nsort(grep { /\.(?:png|gif|bmp|jpe?g|svg|tiff?|ppm|ico|x[bp]m)\z/i } readdir($dir_h));

        closedir($dir_h);
    }
    elsif (-f $input_file) {
        @input_files = $input_file;
    }
    else {
        die "Invalid input file: <$input_file>\n";
    }

    my $create_files = 0;
    if (-d $output_file) {
        $create_files = 1;
    }
    elsif (-f $output_file) {
        ## ok
    }
    else {
        die "Invalid output file: <$output_file>\n";
    }

    my @thrs_loaders;
    foreach my $file (@input_files) {
        state $label = $gui->get_object('label8');
        $label->set_text($file);

        my $text          = image_to_text($file);
        my $reviewed_text = $Config{'default.review_text'} ? review_text($text) : $text;

        my $fh = $create_files
          ? do {
            my $txt_file = basename($file);
            $txt_file =~ s{\.\w+\z}{.txt};
            my $abs_txt_file = catfile($output_file, $txt_file);
            open my $file_h, '>', $abs_txt_file
              or die "Can't create file '$abs_txt_file': $!";
            $file_h;
          }
          : do {
            open my $file_h, '>>', $output_file
              or die "Can't append to file '$output_file': $!";
            $file_h;
          };

        print {$fh} $reviewed_text;
    }
}

sub main_quit {
    'Gtk2'->main_quit();
}

'Gtk2'->main;
