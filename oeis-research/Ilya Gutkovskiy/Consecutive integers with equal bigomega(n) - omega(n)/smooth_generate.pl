#!/usr/bin/perl

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    #~ if ($p == 2) {
    #~ return valuation($n, $p) < 5;
    #~ }

    #~ if ($p == 3) {
    #~ return valuation($n, $p) < 3;
    #~ }

    #~ if ($p == 7) {
    #~ return valuation($n, $p) < 3;
    #~ }

    (($n % $p) != 0) and scalar(factor($n)) <= 3;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

#my @primes = map { @{primes($_->[0], $_->[1])} } ([800, 900], [3300,  3400],  [66400, 66500]);  # finds 190851413537 * 1331 - 1
#my @primes = map { @{primes($_->[0], $_->[1])} } ([0,   50],  [15500, 16000], [36300, 37000]);  # finds 49752064594 * 6859 - 2
#my @primes = map { @{primes($_->[0], $_->[1])} } ([0, 2], [40, 50], [33_000, 34_000], [70_000, 71_000]);

#my @primes = (@{primes(0, 50)}, @{primes(100, 150)});

# 43, 15919, 36341
# 863, 3329, 66431

#my @primes = (863, 3329, 66431);
my @primes = (2, 43, 15919, 36341);

#my $h = smooth_numbers(341249411050244 / 2**3 + 10, \@primes);
my $h = smooth_numbers(254023231417746 / 2**3 + 10, \@primes);

say "\nFound: ", scalar(@$h), " terms";

# [8, 2] Found: 49752064594 * 6859 - 2
# [7, 0] Found: 190851413537 * 1331 - 0
# [8, 1] Found: 190851413537 * 1331 - 1

sub excess ($n) {
    scalar(factor($n)) - scalar(factor_exp($n));
}

sub score ($n) {
    my $t = excess($n);
    foreach my $k (1 .. 100) {
        if (excess($k + $n) != $t) {
            return $k;
        }
    }
}

my $count = 0;
@$h = sort { $b <=> $a } @$h;

my @array = map { $_**3 } @{primes(29)};

push @array,
  (
    2**2 * 3**2,
    2**2 * 5**2,
    2**2 * 7**2,
    2**2 * 11**2,
    2**2 * 13**2,
    2**2 * 17**2,
    2**2 * 19**2,
    2**2 * 23**2,
    2**2 * 29**2,
    3**2 * 5**2,
    3**2 * 7**2,
    3**2 * 11**2,
    3**2 * 13**2,
    3**2 * 17**2,
    3**2 * 19**2,
    3**2 * 23**2,
    3**2 * 29**2,
    5**2 * 7**2,
    5**2 * 11**2,
    5**2 * 13**2,
    5**2 * 17**2,
    5**2 * 19**2,
    5**2 * 23**2,
    5**2 * 29**2,
    7**2 * 11**2,
    7**2 * 13**2,
    7**2 * 17**2,
    7**2 * 19**2,
    7**2 * 23**2,
    7**2 * 29**2,
    11**2 * 13**2,
    11**2 * 17**2,
    11**2 * 19**2,
    11**2 * 23**2,
    11**2 * 29**2,
    13**2 * 17**2,
    13**2 * 19**2,
    13**2 * 23**2,
    13**2 * 29**2,
    17**2 * 19**2,
    17**2 * 23**2,
    17**2 * 29**2,
    19**2 * 23**2,
    19**2 * 29**2,
    23**2 * 29**2
  );

@array = grep { $_ < 10_000 } @array;

foreach my $n (@$h) {

    #  $n > 254023231417746 / 7**3 / 1.2 || next;

    $n > 1e9 || next;
    $n <= 341249411050244 / 2**3 || next;

    say "Testing: $n" if (++$count % 1e3 == 0);

    foreach my $k (0 .. 7) {

        foreach my $m (@array) {

            next if ($n * $m - $k < 1e9);
            next if ($n * $m - $k > 341249411050244);

            my $p = score($n * $m - $k);

            if ($p >= 7) {

                say "[$p, $k] Found: $n * $m - $k";

                if ($n * $m - $k < 254023231417746) {
                    die "New upper-bound found: $n * $m - $k\n";
                }
            }
        }
    }
}
