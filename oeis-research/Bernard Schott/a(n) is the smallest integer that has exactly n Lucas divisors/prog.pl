#!/usr/bin/perl

# a(n) is the smallest integer that has exactly n Lucas divisors (A000032).
# https://oeis.org/A356062

# Known terms:
#   1, 2, 4, 12, 36, 252, 2772, 52668, 1211364, 35129556, 1089016236, 44649665676, 2098534286772, 417608323067628, 88115356167269508, 24760415083002731748, 7948093241643876891108, 4140956578896459860267268

use 5.036;
use ntheory qw(:all);

#use Math::Sidef qw(is_lucas);

use constant {
              SHOW_UPPERBOUNDS => 0,    # true to show intermediate upper-bounds (slower)
             };

sub lucas ($n) {
    lucasv(1, -1, $n);
}

sub is_lucas ($n) {
    state $lookup = {2 => undef, 1 => undef, 3 => undef};
    state $x      = 1;
    state $y      = 3;
    while ($y < $n) {
        ($x, $y) = ($y, addint($x, $y));
        undef $lookup->{$y};
    }
    exists($lookup->{$n});
}

sub lucas_sigma0 ($n) {
    scalar grep { is_lucas($_) } divisors($n);
}

sub a ($n) {

    return 2 if ($n == 2);

    my $max = lcm(map { lucas($_) } 0 .. $n - 1);

    my @arr;
    for (my $i = 0 ; ; ++$i) {
        my $t = lucas($i);
        last if ($t > $max);
        if (lucas_sigma0($t) <= $n) {
            push @arr, $t;
        }
    }

    my %tt;
    @tt{@arr} = ();

    foreach my $k (@arr) {

        if ($k > $max) {
            next;
        }

        foreach my $v (keys %tt) {
            my $t = lcm($v, $k);
            if ($t <= $max and !exists($tt{$t})) {
                undef $tt{$t};

                if (SHOW_UPPERBOUNDS and lucas_sigma0($t) == $n) {
                    say "a($n) <= $t";
                    $max = $t;
                }
            }
        }

        if (SHOW_UPPERBOUNDS) {
            foreach my $key (keys %tt) {
                if ($key > $max) {
                    delete $tt{$key};
                }
            }
        }
    }

    foreach my $v (sort { $a <=> $b } keys %tt) {
        if (lucas_sigma0($v) == $n) {
            return $v;
        }
    }

    return -1;
}

foreach my $n (1 .. 20) {
    say "a($n) = ", a($n);
}

__END__
a(1) = 1
a(2) = 2
a(3) = 4
a(4) = 12
a(5) = 36
a(6) = 252
a(7) = 2772
a(8) = 52668
a(9) = 1211364
a(10) = 35129556
a(11) = 1089016236
a(12) = 44649665676
a(13) = 2098534286772
a(14) = 417608323067628
a(15) = 88115356167269508
