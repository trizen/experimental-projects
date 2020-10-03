#!/usr/bin/perl

use 5.014;
use ntheory qw/divisor_sum/;

# https://oeis.org/A302992

# a(9)  = 247610954
# a(10) = 2476238920

# from 1e9 to 1e10-1: 2228627966
# from 1 to 1e10-1: 2228627966 + 247610954 = 2476238920

#~ [1e9, 2e9-1] = 247612766
#~ [2e9, 3e9-1] = 247620064
#~ [3e9, 4e9-1] = 247623004
#~ [4e9, 5e9-1] = 247624779
#~ [5e9, 6e9-1] = 247626636
#~ [6e9, 7e9-1] = 247628856
#~ [7e9, 8e9-1] = 247629308
#~ [8e9, 9e9-1] = 247630742
#~ [9e9, 1e10-1] = 247631811

#~ The number of abundant numbers in the range [1e9, 1e10-1] is 2228627966. The number of abundant numbers in the range [1, 1e10-1] is: a(9) + 2228627966 = 247610954 + 2228627966 = 2476238920


# from 1e9 to 2e9-1: 247612766
# from 2e9 to 3e9-1: 247620064
# from 3e9 to 4e9-1: 247623004
# from 4e9 to 5e9-1: 247624779
# from 5e9 to 6e9-1: 247626636
# from 6e9 to 7e9-1: 247628856
# from 7e9 to 8e9-1: 247629308
# from 8e9 to 9e9-1: 247630742
# from 9e9 to 1e10-1: 247631811

# from 1e9 - 9e9-1 = 1980996155
# from 1 - 9e9-1 = 2228607109

my $count = 0;

foreach my $i(9e9..10e9-1) {
    if (divisor_sum($i) - $i > $i) {
        ++$count;
    }
}

say $count;

__END__
my %h;
$h{divisor_sum($_)-$_ <=> $_}++ for 1..10**6;
say "Perfect: $h{0}    Deficient: $h{-1}    Abundant: $h{1}";

__END__
 ✘  /tmp  perl z.pl
247612766
perl z.pl  1331.83s user 0.77s system 99% cpu 22:17.25 total

 /tmp  perl z.pl
247620064
perl z.pl  1412.94s user 0.66s system 99% cpu 23:40.46 total

ARCH% time perl A302992_abundant.pl
247624779
perl A302992_abundant.pl  1467.47s user 0.67s system 99% cpu 24:33.10 total

ARCH% time perl A302992_abundant.pl
247626636
perl A302992_abundant.pl  1543.66s user 0.77s system 99% cpu 25:49.27 total

ARCH% time perl A302992_abundant.pl
247628856
perl A302992_abundant.pl  1571.68s user 0.80s system 99% cpu 26:16.93 total

ARCH% time perl A302992_abundant.pl
247629308
perl A302992_abundant.pl  1604.38s user 1.40s system 99% cpu 27:00.37 total

ARCH% time perl A302992_abundant.pl
247630742
perl A302992_abundant.pl  1648.81s user 0.96s system 99% cpu 27:42.33 total

ARCH% time perl A302992_abundant.pl
247631811
perl A302992_abundant.pl  1711.20s user 0.70s system 99% cpu 28:39.66 total


___END__

Verification data for a(10):

[1e9, 2e9-1] = 247612766
[2e9, 3e9-1] = 247620064
[3e9, 4e9-1] = 247623004
[4e9, 5e9-1] = 247624779
[5e9, 6e9-1] = 247626636
[6e9, 7e9-1] = 247628856
[7e9, 8e9-1] = 247629308
[8e9, 9e9-1] = 247630742
[9e9, 1e10-1] = 247631811

(where [x,y] means the number of abundant numbers in the range [x,y]):

The number of abundant numbers in the range [1e9, 1e10-1] is 2228627966. Using the a(9) term, we find the number of abundant numbers in the range [1, 1e10-1]: a(9) + 2228627966 = 247610954 + 2228627966 = 2476238920
