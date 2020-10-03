#!/usr/bin/perl

# Under development...

# maim --geometry=770x770+530+155
# maim --geometry=775x775+530+155 > /dev/stdout
# maim --geometry=772x772+530+155

# https://metacpan.org/pod/Chess::Play
# https://metacpan.org/pod/Games::Chess

use 5.014;
use strict;
use warnings;
no warnings 'uninitialized';

use constant {
              LICHESS        => 1,
              CHESSCOM       => 0,
              SAVE_PIECES    => 1,
              FIND_BEST_MOVE => 0,
             };

use GD;
use GDBM_File;
use List::Util qw(sum min);
use Encode qw(decode_utf8);
use File::Spec::Functions qw(catfile);

use experimental qw(bitwise);
use Games::Chess qw(:constants);

my $pieces_dir = "Lichess";

if (LICHESS && CHESSCOM) {
    die "Select either LICHESS or CHESSCOM!";
}

if (LICHESS) {
    $pieces_dir = "Lichess";
}

if (CHESSCOM) {
    $pieces_dir = "ChessCom";
}

my $square_size_resized = 8;
my $edit_dist_tolerance = 30;

my $db_filename;

if (LICHESS) {
    $db_filename = 'lichess.db';
}
else {
    $db_filename = 'chesscom.db';
}

tie my %DB, 'GDBM_File', $db_filename, &GDBM_WRCREAT, 0640
  or die "Can't tie to database `$db_filename': $!";

# Get the hash key for a faster lookup
my @hash_keys = keys %DB;

#say "@hash_keys";

update_database() if @ARGV;

my %unicode_pieces = (
    'k' => '♔',
    'q' => '♕',
    'r' => '♖',
    'b' => '♗',
    'n' => '♘',
    'p' => '♙',

    'K' => '♚',
    'Q' => '♛',
    'R' => '♜',
    'B' => '♝',
    'N' => '♞',
    'P' => '♟',
                     );

my %unicode_reverse;
@unicode_reverse{values %unicode_pieces} = keys %unicode_pieces;
$unicode_reverse{' '} = 'e';

#if (not @hash_keys) {
#    update_database();
#}

sub diff {
    max(@_) - min(@_);
}

sub avg {
    int(sum(@_) / @_);
}

sub get_pixel {
    my ($img, @pos) = @_;
    $img->rgb($img->getPixel(@pos));
}

my $tolerance = 100;

if (CHESSCOM) {
    $tolerance = 80;
}

{
    my %cache;

    sub is_background {
        my ($img, $index, $bg_rgb) = @_;

        my $rgb = ($cache{$index} //= [$img->rgb($index)]);
        abs($rgb->[0] - $bg_rgb->[0]) <= $tolerance
          and abs($rgb->[1] - $bg_rgb->[1]) <= $tolerance
          and abs($rgb->[2] - $bg_rgb->[2]) <= $tolerance;
    }
}

sub img2ascii {
    my ($img) = @_;

    my $size = 32;
    my ($width, $height) = $img->getBounds;

    if ($size != 0) {
        my $scale_width  = $size;
        my $scale_height = int($height / ($width / ($size / 2)));

        my $resized = GD::Image->new($scale_width, $scale_height);
        $resized->copyResampled($img, 0, 0, 0, 0, $scale_width, $scale_height, $width, $height);

        ($width, $height) = ($scale_width, $scale_height);
        $img = $resized;
    }

    my $avg = 0;
    my @averages;

    foreach my $y (0 .. $height - 1) {
        foreach my $x (0 .. $width - 1) {
            my $index = $img->getPixel($x, $y);
            push @averages, avg($img->rgb($index));
            $avg += $averages[-1] / $width / $height;
        }
    }

    join("\n", unpack("(A$width)*", join('', map { $_ < $avg ? 1 : 0 } @averages)));
}

sub square_is_empty {
    my ($square) = @_;

    #if (CHESSCOM) {
    #    return 0;
    #}

    foreach my $y (0 .. $square_size_resized - 1) {
        foreach my $x (0 .. $square_size_resized - 1) {
            if (avg(get_pixel($square, $x, $y)) <= 50) {
                return 0;
            }
        }
    }

    return 1;
}

sub piece_is_white {
    my ($square) = @_;

    my @averages;
    foreach my $y (0 .. $square_size_resized - 1) {
        foreach my $x (0 .. $square_size_resized - 1) {
            push @averages, avg(get_pixel($square, $x, $y));
        }
    }

    my $avg = sum(@averages) / @averages;

    my $white = 0;
    my $black = 0;

    my $str = join('', map { $_ < $avg / 2 ? 1 : 0 } @averages);

    foreach my $v (@averages) {
        if ($v < $avg / 2) {
            ++$white;
        }
        else {
            ++$black;
        }
    }

    return ($black > 450);

    #say for unpack("(A$square_size_resized)*", $str);

    # exit;

    #~ foreach my $k(@averages) {

    #~ #if ($k < $avg) {
    #~ #    ++$white;
    #~ #}
    #~ #else {
    #~ #    ++$black;
    #~ #}
    #~ }

    #~ $white > $black;
    #~ exit;

    #return ($white > ($square_size_resized**2)/5);
}

# straight copy of Wikipedia's "Levenshtein Distance"
sub editdist {

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

sub read_square {
    my ($square) = @_;

    my $hash = get_square_hash($square);

    my $piece = $DB{$hash};

    return $piece;

    #return $piece if defined($piece);

    my @diffs;
    foreach my $db_hash (@hash_keys) {

        #my $diff = cmp_diff($db_hash, $hash);
        #return $DB{$db_hash} if $diff == 1;    # performance boost
        #push @diffs, [$diff, $db_hash];

        push @diffs, [($db_hash ^. $hash) =~ tr/\0//, $db_hash];

        #my $diff = editdist($db_hash, $hash);
        #push @diffs, [$diff, $db_hash];
    }

    #my $appropriate_hash = (sort { $a->[0] <=> $b->[0] } @diffs)[0]->[1];
    my $appropriate_hash = (sort { $a->[0] <=> $b->[0] } @diffs)[0];

    say "diff: $appropriate_hash->[0]";

    if (not defined $appropriate_hash or $appropriate_hash->[0] > $edit_dist_tolerance) {
        return;
    }

    #$DB{$appropriate_hash};
    $DB{$appropriate_hash->[1]};
}

sub find_chess_board_pos {
    my ($screen) = @_;

    my $bg_rgb = [0, 0, 0];

    my $img = GD::Image->new($screen);
    my ($width, $height) = $img->getBounds();

    {
        open my $fh, '>:raw', "orig-test.png";
        print $fh $img->png;
        close $fh;
    }

    $width  -= 1;
    $height -= 1;

    my $top;
    my $bottom;
  TB: foreach my $y (1 .. $height) {
        foreach my $x (1 .. $width) {

            if (not defined $top) {
                if (not is_background($img, $img->getPixel($x, $y), $bg_rgb)) {
                    $top = $y - 1;
                }
            }

            if (not defined $bottom) {
                if (not is_background($img, $img->getPixel($x, $height - $y), $bg_rgb)) {
                    $bottom = $height - $y + 1;
                }
            }

            if (defined $top and defined $bottom) {
                last TB;
            }
        }
    }

    if (not defined $top or not defined $bottom) {
        say " - fail!";
        next;
    }

    my $left;
    my $right;
  LR: foreach my $x (1 .. $width) {
        foreach my $y (1 .. $height) {
            if (not defined $left) {
                if (not is_background($img, $img->getPixel($x, $y), $bg_rgb)) {
                    $left = $x;
                }
            }

            if (not defined $right) {
                if (not is_background($img, $img->getPixel($width - $x, $y), $bg_rgb)) {
                    $right = $width - $x + 1;
                }
            }

            if (defined $left and defined $right) {
                last LR;
            }
        }
    }

    say "$top $bottom -- $left $right";

    while ($right - $left < $bottom - $top) {
        if ($bottom > 0) {
            --$bottom;
        }
        else {
            --$top;
        }
    }

    while ($right - $left > $bottom - $top) {
        if ($right > 0) {
            --$right;
        }
        else {
            --$left;
        }
    }

    say "$top $bottom -- $left $right";

    my $cropped = GD::Image->new($right - $left, $bottom - $top);

    $cropped->copyResampled(
                            $img,
                            0,          # destX
                            0,          # destY
                            $left,      # srcX
                            $top,       # srcY
                            $right,     # destW
                            $bottom,    # destH
                            $right,     # srcW
                            $bottom,    # srcH
                           );

    $img = $cropped;

    {
        open my $fh, '>:raw', "/tmp/crop-test.png";
        print $fh $img->png;
        close $fh;
    }

    say "$width $height";

    ($width, $height) = $cropped->getBounds;

    my $square_size = int($width / 8);

    say "Square size: $square_size";

    my @alpha = ('a' .. 'h');
    my %coordinates = (
        map {
            my $x = "$_";
            map { ; "$_ $x" => "$alpha[$_]" . ($x + 1) } 0 .. 7
          } 0 .. 7
    );

    #use Data::Dump qw(pp);
    #pp \%coordinates;

    my %pieces;
    my @board;

    my $fails = 0;

    foreach my $y (0 .. 7) {
        foreach my $x (0 .. 7) {

            my $square = GD::Image->new($square_size_resized, $square_size_resized);

            $square->copyResampled(
                                   $img,
                                   0,                       # destX
                                   0,                       # destY
                                   $x * $square_size,       # srcX
                                   $y * $square_size,       # srcY
                                   $square_size_resized,    # destW
                                   $square_size_resized,    # destH
                                   $square_size,            # srcW
                                   $square_size,            # srcH
                                  );

            $pieces{"$x $y"} = $square;

            if (square_is_empty($square)) {
                $board[$y][$x] = ' ';

                #~ #say "$x $y is empty";
            }
            else {
                #my $is_white = piece_is_white($square);
                #say "$x $y -- ", $is_white ? "is white" : "is black";
                $board[$y][$x] = $unicode_pieces{read_square($square)} // '?';
            }

            #say "\n$board[$y][$x]\n", img2ascii($square);

            if ($board[$y][$x] eq '?') {
                ++$fails;
            }

            if (SAVE_PIECES and $board[$y][$x] eq '?') {
                my $name = "Pieces/$x $y.png";
                open my $fh, '>:raw', $name or die "Can't create file `$name': $!";
                print $fh $square->png;
                close $fh;
            }
        }
    }

    if ($fails > 0) {
        say "\n[x] Failed to identify $fails squares...";
    }

    foreach my $i (0 .. $#board) {
        my $row = $board[$i];
        say join(' ', map { $row->[$_] eq ' ' ? (($_ + ($i % 2)) % 2 == 0 ? ' ' : '·') : $row->[$_] } 0 .. $#{$row});
    }

    say "\nSize: $width x $height";

    my $p = Games::Chess::Position->new;

    my $im_white = 1;
    $p->player_to_move(WHITE);

    #~ $p->player_to_move(WHITE);

    #$p->can_castle(WHITE, QUEEN, 1);
    #$p->can_castle(BLACK, KING, 1);

    my %table = (
                 n => KNIGHT,
                 b => BISHOP,
                 k => KING,
                 q => QUEEN,
                 r => ROOK,
                 p => PAWN,
                );

    foreach my $y (0 .. 7) {
        foreach my $x (0 .. 7) {
            my $square = $unicode_reverse{$board[$im_white ? (7 - $y) : $y][$im_white ? $x : (7 - $x)]};

            if ($square eq '0' or $square eq 'e' or $square eq '') {
                $p->at($x, $y, EMPTY);
            }
            else {
                $p->at($x, $y, (lc($square) eq $square) ? BLACK : WHITE, $table{lc $square});
            }
        }
    }

    #$p->at(0,0,BLACK,ROOK);
    #$p->at(7,7,WHITE,ROOK);

    say $p->to_text;
    my $FEN = $p->to_FEN;
    say $FEN;

    if (FIND_BEST_MOVE) {
        use Chess::Play;

        my $cp = Chess::Play->new();

        #$cp->reset();
        $cp->import_fen($FEN);
        $cp->set_depth(2);

        say for $cp->best_move();
    }

    {
        my $name = "crop-test.png";
        open my $fh, '>:raw', $name or die "Can't create file `$name': $!";
        print $fh $img->png;
        close $fh;
    }

    #~ die 1;
    #~ foreach my $y (1 .. $height - 2) {
    #~ foreach my $x (1 .. $width - 2) {

    #~ #my @up   = get_pixel($img, $x, $y - 1);
    #~ #my @down = get_pixel($img, $x, $y + 1);

    #~ my @pixel = get_pixel($img, $x, $y);
    #~ print (((avg(@pixel))[0]), " ");

    #~ }
    #~ print "\n";
    #~ }
}

sub get_square_hash {
    my ($square) = @_;

    my ($width, $height) = $square->getBounds();

    if ($width != $square_size_resized or $height != $square_size_resized) {

        say "Resizing square...";

        my $copy = GD::Image->new($square_size_resized, $square_size_resized);

        $copy->copyResampled(
                             $square,
                             0,                       # destX
                             0,                       # destY
                             0,                       # srcX
                             0,                       # srcY
                             $square_size_resized,    # destW
                             $square_size_resized,    # destH
                             $width,                  # srcW
                             $height,                 # srcH
                            );

        $square = $copy;
    }

    my @averages;
    foreach my $y (0 .. $square_size_resized - 1) {
        foreach my $x (0 .. $square_size_resized - 1) {
            push @averages, avg(get_pixel($square, $x, $y));
        }
    }

    my $avg = sum(@averages) / @averages;

    my $i    = 0;
    my $hash = q{};
    foreach my $v (@averages) {
        vec($hash, $i++, 1) = $v < $avg / 2 ? 1 : 0;    # set the bits
    }

    scalar unpack("H*", $hash);
}

sub update_database {

    my %dups;

    opendir(my $dir_h, $pieces_dir);
    while (defined(my $file = readdir($dir_h))) {

        next if $file eq q{.} or $file eq q{..};
        my $image = decode_utf8(catfile($pieces_dir, $file));

        #my $p = new Image::Magick;
        #my $error = $p->Read(filename => $image);
        #$error && die $error;
        my $p = GD::Image->new($image);

        #$file = decode_utf8($file);

        my $char = $file =~ /^(\X)\d*\.(?:png|jpg)\z/    # single char (e.g.: f42.png == f)
          ? $1
          : die "Can't get char: $file";

        my $hash = get_square_hash($p);
        eval { $DB{$hash} = $char };

        # print "$hash - <$char> - $file\n";

        #~ push @{$dups{$hash}}, $image;
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

                #~ unlink $file;
            }
            print "\n";
        }
    }

    return 1;
}

#~ update_database();

if (!@ARGV) {

    if (LICHESS) {
        `maim --geometry=774x774+530+155 > /tmp/3.png`;
    }

    if (CHESSCOM) {
        `maim --geometry=728x728+405+113 > /tmp/3.png`;
    }
}

say for find_chess_board_pos(shift(@ARGV) // "/tmp/3.png");
