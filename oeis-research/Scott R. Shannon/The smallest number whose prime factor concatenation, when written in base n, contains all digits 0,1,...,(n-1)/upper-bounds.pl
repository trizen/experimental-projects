#!/usr/bin/perl

# The smallest number whose prime factor concatenation, when written in base n, contains all digits 0,1,...,(n-1).
# https://oeis.org/A372309

# Known terms:
#   2, 6, 38, 174, 2866, 11670, 135570, 1335534, 15618090, 155077890, 5148702870

# This program computes upper-bounds.

# New upper-bounds:
#   a(14) <= 774841780230
#   a(15) <= 11924858870610
#   a(16) <= 256023548755170
#   a(17) <= 4286558044897590

use 5.036;
use ntheory qw(:all);
use List::Util qw(uniq shuffle);

sub f ($arr, $p, $n, $value, $max_value, $callback) {

    if (scalar(@$arr) == $n and $value >= factorial($n)) {
        my @D = map { todigits($_, $n) } factor($value);
        if (scalar(@D) == $n) {
            $callback->($value);
            $max_value = $value if ($value < $max_value);
        }
        return $max_value;
    }

    my $limit = divint($max_value, $value);
    $limit = vecmin($limit, 1e6);

    my %arr_lookup;
    @arr_lookup{@$arr} = ();

    for(; $p <= $limit; $p = next_prime($p)) {
        if ($value*$p <= $max_value) {
            my @D = todigits($p, $n);
            if ((vecnone { exists $arr_lookup{$_} } @D) and join(' ', @D) eq join(' ', uniq(@D))) {
                $max_value = f([@$arr, @D], $p, $n, $value * $p, $max_value, $callback);
            }
        }
    }

    return $max_value;
}

my $n = 9;
my $max = 2;

#~ $n = 12;
#~ $max = 5148702870;

#~ $n = 13;
#~ $max = 31771759110;

#~ $n = 14;
#~ $max = 774841780230;

#~ $n = 15;
#~ $max = 11924858870610;

#~ $n = 16;
#~ $max = 256023548755170;

#~ $n = 17;
#~ $max = 4286558044897590;

say ":: Computing an upper-bound for a($n)";

while (1) {
    my @terms;
    say ":: Computing terms <= $max";

    f([2], 3, $n, 2, $max, sub($k) {
        say "a($n) <= $k";
        push @terms, $k;
    });

    if (@terms) {
        say "\n:: Final upper-bound:\na($n) <= ", vecmin(@terms);
        last;
    }
    $max *= 2;
}

__END__
:: Computing terms <= 524288
:: Computing terms <= 1048576
:: Computing terms <= 2097152
a(9) <= 1458870
a(9) <= 1414590
a(9) <= 1335534

:: Final upper-bound:
a(9) <= 1335534
perl upper-bounds.pl  0.98s user 0.00s system 99% cpu 0.988 total
