#!/usr/bin/perl

# Copyright (c) 2013 Daniel "Trizen" Șuteu

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 05 January 2013
# Last edit: 24 January 2013
# https://github.com/trizen

# Image to TEXT conversion.

package Image2TextOO;

use 5.010;
use strict;
use autodie;
use warnings;

use utf8;
use open IO => ':utf8';

use GDBM_File;
use Image::Magick qw();
use File::Temp qw(tempdir);

use List::Util qw(sum min max shuffle);
use autouse 'File::Spec::Functions' => qw(catfile);

no if $] >= 5.018, warnings => 'experimental::smartmatch';

#use Memoize qw(memoize);
#memoize('get_appropriate_char');

my $text = '';
my @widths;

our $db_filename = 'database.db';

tie my %DB, 'GDBM_File', $db_filename, &GDBM_WRCREAT, 0640
  or die "Can't tie to database `$db_filename': $!";

# Get the hash key for a faster lookup
my @hash_keys = keys %DB;

my %valid_options = (
    tolerance => {valid => [0 .. 50], default => 0},
    resize      => {valid => [1, 0],       default => 0},
    height_size => {valid => [qr/^\d+\z/], default => 8},
    width_size  => {valid => [qr/^\d+\z/], default => 8},
    keep_img_ratio => {valid => [1, 0], default => 1},
    tmp_dir     => {valid => [qr/^./], default => tempdir(CLEANUP => 1)},
    letters_dir => {valid => [qr/^./], default => "Alphabet"},
                    );

{
    no strict 'refs';

    foreach my $key (keys %valid_options) {

        # Create the 'set_*' subroutines
        *{__PACKAGE__ . '::set_' . $key} = sub {
            my ($self, $value) = @_;
            $self->{$key} =
                $value ~~ $valid_options{$key}{valid}
              ? $value
              : $valid_options{$key}{default};
        };

        # Create the 'get_*' subroutines
        *{__PACKAGE__ . '::get_' . $key} = sub {
            my ($self) = @_;
            return $self->{$key};
        };
    }
}

sub new {
    my ($class, %opts) = @_;

    my $self = bless {}, $class;

    foreach my $key (keys %valid_options) {
        my $code = \&{"set_$key"};
        $self->$code(delete $opts{$key});
    }

    foreach my $invalid_key (keys %opts) {
        warn "Invalid key: '${invalid_key}'";
    }

    return $self;
}

{
    my $x = 0;
    my $i = 0;
    my %seen;

    sub get_character {
        my $self = shift;
        my $img  = shift()->Clone();
        $x = shift() if @_;

        my $err;
        my $start = $self->get_next_char_pos($img, $x + 1, 0);
        my $space_width = ($start || 0) - $x;

        #warn "UNDEFINED \$start\n" if not defined $start;

        $x = $start // return;
        my $end = $self->get_next_char_boundary($img, $start, 0);
        $x += ($end - $start);

        #say "X: $x ; START: $start ; END: $end";
        my $rows = $img->Get('rows');

        $err = $img->Set(page => "0x0+0+0");
        $err && die $err;

        $err = $img->Crop(x => $start, y => 0, geometry => ($end - $start) . "x" . $rows . "+0+0");
        $err && die $err;

        $err = $img->Set(page => "0x0+0+0");
        $err && die $err;

        my ($top, $bottom) = $self->get_top_and_bottom_boundary($img);
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
        my $self = shift;
        my $img  = shift()->Clone();
        $y = shift() if @_;

        my $start = $self->get_next_black_row($img, 0, $y);
        $y = $start // return;
        my $end = $self->get_next_blank_row($img, 0, $start);
        $y += ($end - $start);

        $img->Crop(x => 0, y => $start, geometry => 0 . "x" . ($end - $start) . "+0+0");
        return wantarray ? ($img, $y) : $img;
    }
}

{
    my $i = int(rand(2000));
    my %seen;

    sub get_and_append_letter {
        my ($self, $char, $found_char_code, $unknown_char_code) = @_;

        my $hash      = $self->get_img_hash($char);
        my $text_char = $DB{$hash} // $self->get_appropriate_char($hash);

        if (not defined $text_char) {

            my $char_file = catfile($self->get_tmp_dir(), ++$i . ".png");
            $char->Write($char_file);

            if (ref $unknown_char_code eq 'CODE') {
                my $rin = rindex($text, "\n");
                if ($rin == -1 or $rin == length($text)) {
                    $rin = -32;
                }
                $text_char = $unknown_char_code->($char_file, $hash, substr($text, $rin));
            }
            else {
                return;
            }

        }

        if (ref $found_char_code eq 'CODE') {
            $found_char_code->($text_char);
        }

        $text .= $text_char;

=for comment
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
=cut

        #if(not exists $DB{$hash}){
        #    $char->Write("/tmp/Alpha/" . substr($text, -length($text_char)) . ++$i . ".png") if not $seen{$hash}++;
        #}

        return 1;
    }
}

sub get_text {
    my ($self, $image, $found_char_code, $unknown_char_code) = @_;

    $text   = '';
    @widths = ();

    my $p     = Image::Magick->new;
    my $error = $p->Read(filename => $image);
    $error && die $error;

    my (%seen, $row, $y);
    while (
           do { ($row, $y) = $self->get_text_rows($p); defined $row }
      ) {

        if ($#widths > 300) {
            @widths  = shuffle(@widths);
            $#widths = 100;
        }

        if (defined(my $char = $self->get_character($row, 0))) {
            $self->get_and_append_letter($char, $found_char_code, $unknown_char_code);
        }
        else {
            next;
        }

        while (defined(my $char = $self->get_character($row))) {
            $self->get_and_append_letter($char, $found_char_code, $unknown_char_code);
        }

        #$code->(substr($text, rindex($text, "\n") + 1)) if ref $code eq 'CODE';
        #$text_code->($text) if ref $text_code eq 'CODE';
        $found_char_code->("\n") if ref $found_char_code eq 'CODE';
        $text .= "\n";

        last if $y == 0;
    }

    return $text;
}

sub get_colors {

    # my($img,$x,$y) = @_;
    # return map{int($_+0.5) } $img->GetPixel(x=>$x, y=>$y);

    map int($_ + 0.5), $_[1]->GetPixel(x => $_[2] || 0, y => $_[3] || 0);    # faster
}

sub get_next_black_row {
    my ($self, $img, $start_x, $start_y) = @_;

    my $width  = $img->Get('columns');
    my $height = $img->Get('rows');

    foreach my $y ($start_y .. $height - 1) {
        foreach my $x ($start_x .. $width - 1) {
            if ([$self->get_colors($img, $x, $y)] ~~ [0, 0, 0]) {
                return $y;
            }
        }
    }

    return;
}

sub get_next_blank_row {
    my ($self, $img, $start_x, $start_y) = @_;

    my $width  = $img->Get('columns');
    my $height = $img->Get('rows');

    foreach my $y ($start_y .. $height - 1) {
        my $is_white = 1;
        foreach my $x ($start_x .. $width - 1) {
            if ([$self->get_colors($img, $x, $y)] ~~ [0, 0, 0]) {
                $is_white = 0;
                last;
            }
        }
        return $y if $is_white;
    }

    return 0;
}

sub get_next_char_pos {
    my ($self, $img, $start_x, $start_y) = @_;

    my $width  = $img->Get('columns');
    my $height = $img->Get('rows');

    foreach my $x ($start_x .. $width - 1) {
        foreach my $y ($start_y .. $height - 1) {
            if ([$self->get_colors($img, $x, $y)] ~~ [0, 0, 0]) {
                return $x;
            }
        }
    }

    return;
}

sub get_next_char_boundary {
    my ($self, $img, $start_x, $start_y) = @_;

    my $width  = $img->Get('columns');
    my $height = $img->Get('rows');

    #my $sep_pixels = 2;

    foreach my $x ($start_x .. $width - 1) {
        my $is_white = 1;
        foreach my $y ($start_y .. $height - 1) {
            if ([$self->get_colors($img, $x, $y)] ~~ [0, 0, 0]) {
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
    my ($self, $img) = @_;

    my $height = $img->Get('rows');
    my $width  = $img->Get('columns');

    for (my $y = $height - 1 ; $y >= 0 ; $y--) {
        foreach my $x (0 .. $width - 1) {
            if ([$self->get_colors($img, $x, $y)] ~~ [0, 0, 0]) {
                return $y + 1;
            }
        }
    }

    return 0;
}

sub get_top_and_bottom_boundary {
    my ($self, $img) = @_;

    my $height = $img->Get('rows');

    my $top_pos    = $self->get_next_black_row($img, 0, 0) || 0;
    my $bottom_pos = $self->get_char_bottom_boundary($img);

    if ($bottom_pos < $height / 3) {    # for "i"
        if (defined(my $new_top = $self->get_next_black_row($img, 0, $bottom_pos))) {
            if (defined(my $new_bottom = $self->get_next_blank_row($img, 0, $new_top))) {
                $bottom_pos = $new_bottom;
            }
        }
    }

    #say "$top_pos -- $bottom_pos";

    return ($top_pos, $bottom_pos);
}

sub get_img_hash {
    my $self = shift;
    my $img  = shift()->Clone();

    my $height = $img->Get('rows');
    my $width  = $img->Get('columns');

    #until($height <= 16){
    #    $height /= 2;
    #    $width /= 2;
    #}

    if ($self->get_resize()) {
        if ($self->get_keep_img_ratio()) {
            my $def_height = $self->get_height_size();
            my $ratio      = $height / $def_height;
            $height = $def_height;
            $width  = int($width / $ratio) + 1;
        }
        else {
            $height = $self->get_height_size();
            $width  = $self->get_width_size();
        }
        my $err;
        $err = $img->Resize(width => $width, height => $height);
        $err && die $err;
    }

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
    (scalar grep $_ > 0, unpack('C*', '' . $_[1] ^ '' . $_[2])) + abs(length($_[1]) - length($_[2]));
}

# straight copy of Wikipedia's "Levenshtein Distance"
sub editdist {
    my $self = shift;

    my @a = split //, shift;
    my @b = split //, shift;

    # There is an extra row and column in the matrix. This is the
    # distance from the empty string to a substring of the target.
    my @d;
    $d[$_][0] = $_ for (0 .. @a);
    $d[0][$_] = $_ for (0 .. @b);

    for my $i (1 .. @a) {
        for my $j (1 .. @b) {
            $d[$i][$j] = (
                            $a[$i - 1] eq $b[$j - 1]
                          ? $d[$i - 1][$j - 1]
                          : 1 + min($d[$i - 1][$j], $d[$i][$j - 1], $d[$i - 1][$j - 1])
                         );
        }
    }

    return $d[@a][@b];
}

sub get_appropriate_char {
    my ($self, $hash) = @_;

    my @diffs;
    foreach my $db_hash (@hash_keys) {

        #my $diff = cmp_diff($db_hash, $hash);
        #return $DB{$db_hash} if $diff == 1;    # performance boost
        #push @diffs, [$diff, $db_hash];

        my $diff = $self->editdist($db_hash, $hash);
        push @diffs, [$diff, $db_hash];
    }

    #my $appropriate_hash = (sort { $a->[0] <=> $b->[0] } @diffs)[0]->[1];
    my $appropriate_hash = (sort { $a->[0] <=> $b->[0] } @diffs)[0];

    #if($self->editdist($hash, $appropriate_hash) > $self->get_tolerance()){
    if (not defined $appropriate_hash or $appropriate_hash->[0] > $self->get_tolerance()) {
        return;
    }

    #$DB{$appropriate_hash};
    $DB{$appropriate_hash->[1]};
}

sub add_char_img_to_database {
    my ($self, $img_file, $char) = @_;

    my $p     = new Image::Magick;
    my $error = $p->Read(filename => $img_file);
    $error && die $error;

    my $hash = $self->get_img_hash($p);
    $DB{$hash} = $char;

    return 1;
}

sub add_hash_to_database {
    my ($self, $hash, $char) = @_;
    $DB{$hash} = $char;
    return 1;
}

sub update_database {
    my ($self) = @_;

    my %dups;
    my $letters_dir = $self->get_letters_dir();

    opendir(my $dir_h, $letters_dir);
    while (defined(my $file = readdir($dir_h))) {

        next if $file eq q{.} or $file eq q{..};
        my $image = catfile($letters_dir, $file);
        utf8::decode($image);

        my $p     = new Image::Magick;
        my $error = $p->Read(filename => $image);
        $error && die $error;

        utf8::decode($file);
        my $char = $file =~ /^(\X)\d*\.(?:png|jpg)\z/    # single char (e.g.: f42.png == f)
          ? $1
          : $file =~ /^=(\X{2,}?)\d*\.(?:png|jpg)\z/s    # multiple chars (e.g.: =if13.png == if)
          ? $1
          : die "Can't get char: $file";

        my $hash = $self->get_img_hash($p);
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
