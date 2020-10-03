#!/usr/bin/perl

use 5.014;
use Math::Prime::Util::GMP qw(is_prob_prime);
use Math::AnyNum qw(fibonacci ipow);
use ntheory qw(forprimes divisor_sum);

my $max = 0;
++$|;

forprimes {
    my $n = ipow($_, 2)+1;
    my $d = divisor_sum($n, 0) ;
    if ($d > $max) {
        $max = $d;
        print "$n, ";
    }
} 238690;


__END__

#foreach my $k(1..100) {
for(my $k = 150000; $k <= 1e6; ++$k) {

    say "Testing: $k";
    my $t = 6*fibonacci($k)-1;

    if (is_prob_prime($t)) {

        say "Prime for $k";

        if (is_prob_prime($t+2)) {

            if ($t > 63661259146337) {
                die "Found new term: $t";
            }
        }
    }
}
