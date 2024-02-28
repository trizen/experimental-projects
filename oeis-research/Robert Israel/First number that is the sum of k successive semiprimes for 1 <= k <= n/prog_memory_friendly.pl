#!/usr/bin/perl

# a(n) is the first number that is the sum of k successive semiprimes for 1 <= k <= n.
# https://oeis.org/A370687

use 5.036;
use ntheory qw(:all);

sub is_sum_of_successive_semiprimes ($n, $k) {

    if ($k == 1) {
        return is_semiprime($n);
    }

    my $v = divint($n, $k);
    my $arr = semi_primes(vecmax(0, $v - 4*$k*$k), $v + 4*$k*$k);     # faster, but may give wrong results

    #my $sv = semiprime_count($v);
    #my $arr = semi_primes(nth_semiprime(vecmax(1, $sv - $k)), nth_semiprime($sv + $k));

    my @list = splice(@$arr, 0, $k);

    foreach my $r (@$arr) {

        my $sum = vecsum(@list);

        if ($sum > $n) {
            return 0;
        }

        if ($sum == $n) {
            return 1;
        }

        shift @list;
        push @list, $r;
    }

    return 0;
}

foreach my $k (1..6) {
    if ($k <= 5) {
        is_sum_of_successive_semiprimes(2705, $k) or die "error for k = $k";
    }
    if ($k <= 4) {
         is_sum_of_successive_semiprimes(2045, $k) or die "error for k = $k";
    }
    if ($k <= 3) {
        is_sum_of_successive_semiprimes(134, $k) or die "error for k = $k";
    }
    if ($k <= 2) {
        is_sum_of_successive_semiprimes(10, $k) or die "error for k = $k";
    }
    is_sum_of_successive_semiprimes(16626281, $k) or die "error for k = $k";
}

sub a($k, $from = 1, $to = 1e6) {

    my $result = -1;

    forsemiprimes {

        if (is_sum_of_successive_semiprimes($_, $k)) {
            my $ok = 1;
            for(my $j = $k-1; $j >= 2; $j--) {
                if (not is_sum_of_successive_semiprimes($_, $j)) {
                    $ok = 0;
                    last;
                }
                say "Candidate: a($k) >= $_" if ($k >= 6);
            }
            if ($ok) {
                $result = $_;
                lastfor;
            }
        }

    } $from, $to;

    return $result;
}

a(2) == 10 or die "error for a(2)";
a(3) == 134 or die "error for a(3)";
a(4) == 2045 or die "error for a(4)";
a(5) == 2705 or die "error for a(5)";

#say "a(6) = ", a(6, 1, 16626281);
say "a(7) = ", a(7, 5*1e8, 1e10);

__END__
Candidate: a(6) >= 16595159
Candidate: a(6) >= 16600877
Candidate: a(6) >= 16608299
Candidate: a(6) >= 16614691
Candidate: a(6) >= 16617142
Candidate: a(6) >= 16626281
Candidate: a(6) >= 16626281
Candidate: a(6) >= 16626281
Candidate: a(6) >= 16626281
a(6) >= 16626281
perl x.sf  52.49s user 0.12s system 98% cpu 53.252 total
