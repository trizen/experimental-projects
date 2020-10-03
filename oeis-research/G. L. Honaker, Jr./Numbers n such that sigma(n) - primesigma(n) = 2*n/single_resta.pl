#!/usr/bin/perl

# Integers k such that k is equal to the sum of the nonprime proper divisors of k.
# https://oeis.org/A331805

# 9*10^12 < a(4) <= 72872313094554244192 = 2^5 * 109 * 151 * 65837 * 2101546957. - Giovanni Resta, Jan 28 2020

# Notice that:
#   65837 = 2^2 * 109 * 151 + 1
#   sigma(2^5 * 109 * 151 * 65837) / 2101546957 =~ 33.00003145254488 =~ 2^5 + 1

# Also:
#   log_3(72872313094554244192) =~ 41.6300098  (coincidence?)

use 5.014;
use ntheory qw(:all);
use List::Util qw(uniq);
use Math::GMPz;
#use Math::AnyNum qw(:overload);

sub prime_sigma {
    my ($n) = @_;
    vecsum(uniq(factor($n)));
}

sub isok {
    my ($n) = @_;
    divisor_sum($n) - $n - prime_sigma($n) == $n;
}

#say isok(72872313094554244192);

forsquarefree {

    my $r = $_;

    foreach my $k(1..10) {

        my $v = (1<<$k) * $r;
        my $s = divisor_sum($v);

        $s/$v < 2 or next;
        #$s/$v > 1.9999 or next;
        $s/$v > (2 - 1/$v**(2/3)) or next;

        #(s/v < 2) && (s/v > (2 - 1/v.pow(2/3))) || next
        say "$r, $v, $k -> ", $s - (2 + prime_sigma($r)), " with ", $s/$v;

        foreach my $p(factor($s - (2 +  prime_sigma($r)))) {

                my $u = ($v * $p);

                if ($u > ~0) {
                    $u = Math::GMPz->new($v)*$p;
                }

                if ($u > 1e13 && isok($u)) {
                    say "Found: $u";

                    if ("$u" ne "72872313094554244192") {
                        die "New term: $u";
                    }
                }
        }
    }
} 1083611183,1083611183+1e9;

__END__
1083611183, 34675557856, 5 -> 69351049581 with 1.99999999907716
Found: 72872313094554244192
1083644101, 34676611232, 5 -> 69353156299 with 1.99999999815438
1083709937, 34678717984, 5 -> 69357369735 with 1.99999999630898
1083841609, 34682931488, 5 -> 69365796607 with 1.99999999261885
1084104953, 34691358496, 5 -> 69382650351 with 1.99999998524128
1084335379, 34698732128, 5 -> 69397397377 with 1.99999997878885
1084631641, 34708212512, 5 -> 69416357839 with 1.9999999704969
1084981189, 138877592192, 7 -> 277755175339 with 1.99999996843263
1084993739, 34719799648, 5 -> 69439531737 with 1.99999996036843
1085092493, 34722959776, 5 -> 69445851891 with 1.9999999576073
1085125411, 34724013152, 5 -> 69447958609 with 1.99999995668703
1085325674, 69460843136, 6 -> 138921679937 with 1.99999994655982
