#!/usr/bin/perl
use 5.014;
use ntheory qw(:all);

my $n = 12;

# a(11) > 10^9
# a(11) = 2690757467
# a(12) = 36906080234

my $from = 24300000000+1e8+1e9+1e9 + 1e9+1e9+1e9+1e9+1e9+1e9+1e9+1e9+1e9+1e9;

# a(13) <= 848839845911, a(14) <= 1697679691826, a(15) <= 28860554761331, a(16) <= 57721109522666, a(17) <= 634932204749447. - ~~~~

say "From: $from";

forsemiprimes {

    if (not is_square($_)) {

        my ($x, $y) = factor($_);
        my $d     = $y - $x;
        my $count = 0;

        for (; $count < $n and is_semiprime($d) and not is_square($d) ; ++$count) {
            ($x, $y) = factor($d);
            $d = $y - $x;
        }

        if ($count >= $n) {
            say "a($n) = $_ (ended at $d)";
            exit;
            ++$n;
        }
    }

} $from, $from+1e9;

# 21408927,158279834;

# Check 20690757467-1e8, 24300000000-1e8-1e8

__END__
a(0) = 6 (ended at 1)
a(1) = 34 (ended at 2)
a(2) = 82 (ended at 3)
a(3) = 226 (ended at 2)
a(4) = 687 (ended at 2)
a(5) = 4786 (ended at 2)
a(6) = 14367 (ended at 2)
a(7) = 28738 (ended at 2)
a(8) = 373763 (ended at 2)
a(9) = 21408927 (ended at 11)
a(10) = 158279834 (ended at 5)
a(11) = 2690757467 (ended at 5)
