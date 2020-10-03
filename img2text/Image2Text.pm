#!/usr/bin/perl

# Copyright (c) 2013 Daniel "Trizen" Șuteu

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 05 January 2013
# https://github.com/trizen

# Image to TEXT conversion.

package Image2Text;
use parent qw(Exporter);

our @EXPORT    = qw(get_text);
our @EXPORT_OK = qw(
  cmp_diff
  get_and_append_letter
  get_appropriate_char
  get_character
  get_colors
  get_char_bottom_boundary
  get_img_hash
  get_next_black_row
  get_next_blank_row
  get_next_char_boundary
  get_next_char_pos
  get_text_rows
  get_top_and_bottom_boundary
  update_database
  );

use 5.010;
use strict;
use autodie;
use warnings;
use Encode qw(decode_utf8);

use utf8;
use open IO => ':utf8', ':std';

use GDBM_File;
use Image::Magick;
use Memoize qw(memoize);
use List::Util qw(sum min max shuffle);
use autouse 'File::Spec::Functions' => qw(catfile);

no if $] >= 5.018, warnings => 'experimental::smartmatch';

memoize('get_appropriate_char');

my $text = '';
my @widths;

our $letters_dir = 'Alphabet';
our $db_filename = 'database.db';
my $first_time = not -e $db_filename;

tie my %DB, 'GDBM_File', $db_filename, &GDBM_WRCREAT, 0640
  or die "Can't tie to database `$db_filename': $!";

$first_time && update_database();

# Get hash key for a faster lookup
my @hash_keys = keys %DB;

{
    my $x = 0;
    my $i = 0;
    my %seen;

    sub get_character {
        my $img = shift()->Clone();
        $x = shift() if @_;

        my $err;
        my $start = get_next_char_pos($img, $x + 1, 0);
        my $space_width = ($start || 0) - $x;

        #warn "UNDEFINED \$start\n" if not defined $start;

        $x = $start // return;
        my $end = get_next_char_boundary($img, $start, 0);
        $x += ($end - $start);

        #say "X: $x ; START: $start ; END: $end";
        my $rows = $img->Get('rows');

        $err = $img->Set(page => "0x0+0+0");
        $err && die $err;

        $err = $img->Crop(x => $start, y => 0, geometry => ($end - $start) . "x" . $rows . "+0+0");
        $err && die $err;

        $err = $img->Set(page => "0x0+0+0");
        $err && die $err;

        my ($top, $bottom) = get_top_and_bottom_boundary($img);
        my ($width) = $img->Get('columns');

        push @widths, $width;
        {
            my $avg_width = (sum(@widths) / @widths);

            #if($width * 5 < $avg_width or $width / 5 > $avg_width){
            #    $avg_width = $width;
            #    @widths = $width;
            #}

            if ($space_width * 2 >= $avg_width) {
                $text .= " ";
            }
        }

        $err = $img->Crop(x => 0, y => $top, geometry => $width . "x" . ($bottom - $top) . "+0+0");
        die $err if $err;

        #$img->Write("/tmp/Alpha/" . ++$i . ".png") if not $seen{get_img_hash($img)}++;

        return $img;
    }
}

{
    my $y = 0;

    sub get_text_rows {
        my $img = shift()->Clone();
        $y = shift() if @_;

        my $start = get_next_black_row($img, 0, $y);
        $y = $start // return;
        my $end = get_next_blank_row($img, 0, $start);
        $y += ($end - $start);

        $img->Crop(x => 0, y => $start, geometry => 0 . "x" . ($end - $start) . "+0+0");
        return wantarray ? ($img, $y) : $img;
    }
}

{
    my $i = int(rand(2000));
    my %seen;

    sub get_and_append_letter {
        my ($char) = @_;

        my $hash      = get_img_hash($char);
        my $text_char = $DB{$hash} // get_appropriate_char($hash);
        my $last_char = substr($text, -1);

        if ($text_char =~ /^\p{Upper}\z/) {
            if ($last_char =~ /^\p{Lower}\z/) {
                $text .= lc($text_char);
            }
            else {
                $text .= $text_char;
            }
        }
        elsif ($last_char =~ /^\p{Letter}\z/ and $text_char eq '0') {
            $text .= 'o';
        }
        elsif ($last_char =~ /^\d\z/ and $text_char eq 'o') {
            $text .= '0';
        }
        else {
            $text .= $text_char;
        }

        #if(not exists $DB{$hash}){
        #    $char->Write("/tmp/Alpha/" . substr($text, -length($text_char)) . ++$i . ".png") if not $seen{$hash}++;
        #}

        return 1;
    }
}

sub get_text {
    my ($image, $code) = @_;

    $text   = '';
    @widths = ();

    my $p     = new Image::Magick;
    my $error = $p->Read(filename => $image);
    $error && die $error;

    my (%seen, $row, $y);
    while (
           do { ($row, $y) = get_text_rows($p); defined $row }
      ) {

        if ($#widths > 300) {
            @widths  = shuffle(@widths);
            $#widths = 100;
        }

        if (defined(my $char = get_character($row, 0))) {
            get_and_append_letter($char);
        }
        else {
            next;
        }

        while (defined(my $char = get_character($row))) {
            get_and_append_letter($char);
        }

        $code->(substr($text, rindex($text, "\n") + 1)) if ref $code eq 'CODE';
        $text .= "\n";

        last if $y == 0;
    }

    return $text;
}

sub get_colors {

    # my($img,$x,$y) = @_;
    # return map{int($_+0.5) } $img->GetPixel(x=>$x, y=>$y);

    map int($_ + 0.5), $_[0]->GetPixel(x => $_[1] || 0, y => $_[2] || 0);    # faster
}

sub get_next_black_row {
    my ($img, $start_x, $start_y) = @_;

    my $width  = $img->Get('columns');
    my $height = $img->Get('rows');

    foreach my $y ($start_y .. $height - 1) {
        foreach my $x ($start_x .. $width - 1) {
            if ([get_colors($img, $x, $y)] ~~ [0, 0, 0]) {
                return $y;
            }
        }
    }

    return;
}

sub get_next_blank_row {
    my ($img, $start_x, $start_y) = @_;

    my $width  = $img->Get('columns');
    my $height = $img->Get('rows');

    foreach my $y ($start_y .. $height - 1) {
        my $is_white = 1;
        foreach my $x ($start_x .. $width - 1) {
            if ([get_colors($img, $x, $y)] ~~ [0, 0, 0]) {
                $is_white = 0;
                last;
            }
        }
        return $y if $is_white;
    }

    return 0;
}

sub get_next_char_pos {
    my ($img, $start_x, $start_y) = @_;

    my $width  = $img->Get('columns');
    my $height = $img->Get('rows');

    foreach my $x ($start_x .. $width - 1) {
        foreach my $y ($start_y .. $height - 1) {
            if ([get_colors($img, $x, $y)] ~~ [0, 0, 0]) {
                return $x;
            }
        }
    }

    return;
}

sub get_next_char_boundary {
    my ($img, $start_x, $start_y) = @_;

    my $width  = $img->Get('columns');
    my $height = $img->Get('rows');

    #my $sep_pixels = 2;

    foreach my $x ($start_x .. $width - 1) {
        my $is_white = 1;
        foreach my $y ($start_y .. $height - 1) {
            if ([get_colors($img, $x, $y)] ~~ [0, 0, 0]) {
                $is_white = 0;

                #$sep_pixels = 2;
                last;
            }
        }
        return $x if $is_white    #and --$sep_pixels == 0;
    }

    return $width;
}

sub get_char_bottom_boundary {
    my ($img) = @_;

    my $height = $img->Get('rows');
    my $width  = $img->Get('columns');

    for (my $y = $height - 1 ; $y >= 0 ; $y--) {
        foreach my $x (0 .. $width - 1) {
            if ([get_colors($img, $x, $y)] ~~ [0, 0, 0]) {
                return $y + 1;
            }
        }
    }

    return 0;
}

sub get_top_and_bottom_boundary {
    my ($img) = @_;

    my $height = $img->Get('rows');

    my $top_pos    = get_next_black_row($img, 0, 0) || 0;
    my $bottom_pos = get_char_bottom_boundary($img);

    if ($bottom_pos < $height / 3) {    # for "i"
        if (defined(my $new_top = get_next_black_row($img, 0, $bottom_pos))) {
            if (defined(my $new_bottom = get_next_blank_row($img, 0, $new_top))) {
                $bottom_pos = $new_bottom;
            }
        }
    }

    #say "$top_pos -- $bottom_pos";

    return ($top_pos, $bottom_pos);
}

sub get_img_hash {
    my $img = shift()->Clone();

    my $height = $img->Get('rows');
    my $width  = $img->Get('columns');

    #until($height <= 16){
    #    $height /= 2;
    #    $width /= 2;
    #}

    state $def_height = 8;
    my $ratio = $height / $def_height;
    $height = $def_height;
    $width  = int($width / $ratio) + 1;

    #$height = 8;
    #$width = 8;

    my $err;
    $err = $img->Resize(width => $width, height => $height);
    $err && die $err;

    my @colors;
    my $avg = 0;
    foreach my $y (0 .. $height - 1) {
        foreach my $x (0 .. $width - 1) {
            push @colors, [$img->GetPixel(x => $x, y => $y)];

            # Average of the most prominent and least prominent colors:
            #my $value = (max(@{$colors[-1]}) + min(@{$colors[-1]})) / 2;

            # Average of the colors
            my $value = sum(@{$colors[-1]}) / 3;
            $avg += $value;
        }
    }
    $avg /= $width * $height;

    my $i    = 0;
    my $hash = q{};
    foreach my $color (@colors) {
        vec($hash, $i++, 1) = sum(@{$color}) / 3 < $avg ? 1 : 0;    # set the bits
    }

    scalar unpack("H*", $hash);
}

sub cmp_diff {
    (scalar grep $_ > 0, unpack('C*', '' . $_[0] ^ '' . $_[1])) + abs(length($_[0]) - length($_[1]));
}

sub get_appropriate_char {
    my ($hash) = @_;

    my @diffs;
    foreach my $db_hash (@hash_keys) {
        my $diff = cmp_diff($db_hash, $hash);
        return $DB{$db_hash} if $diff == 1;    # performance boost
        push @diffs, [$diff, $db_hash];
    }

    @diffs || return '';
    $DB{(sort { $a->[0] <=> $b->[0] } @diffs)[0]->[1]};
}

sub update_database {

    my %dups;

    opendir(my $dir_h, $letters_dir);
    while (defined(my $file = readdir($dir_h))) {

        next if $file eq q{.} or $file eq q{..};
        my $image = decode_utf8(catfile($letters_dir, $file));

        my $p     = new Image::Magick;
        my $error = $p->Read(filename => $image);
        $error && die $error;

        $file = decode_utf8($file);
        my $char = $file =~ /^(\X)\d*\.(?:png|jpg)\z/    # single char (e.g.: f42.png == f)
          ? $1
          : $file =~ /^=(\X{2,}?)\d*\.(?:png|jpg)\z/s    # multiple chars (e.g.: =if13.png == if)
          ? $1
          : die "Can't get char: $file";

        my $hash = get_img_hash($p);
        eval { $DB{$hash} = $char };

        # print "$hash - <$char> - $file\n";

        push @{$dups{$hash}}, $image;
    }
    closedir $dir_h;

    #use Data::Dump qw(pp);
    #pp \%dups;

    while (my (undef, $array) = each %dups) {
        if ($#{$array} > 0) {
            print "Duplicate file: $array->[0]\n";
            foreach my $i (1 .. $#{$array}) {
                my $file = $array->[$i];
                warn "Duplicate file: $file\n";
                unlink $file;
            }
            print "\n";
        }
    }

    return 1;
}

1;
