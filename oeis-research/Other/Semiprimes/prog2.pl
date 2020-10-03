#!/usr/bin/perl


use 5.014;
use ntheory qw(:all pn_primorial);
use Math::AnyNum qw(ipow factorial );

use experimental qw(signatures);

# https://oeis.org/A072381


# Numbers n such that 3^n-2 is a semiprime.
# https://oeis.org/A080892
# 3^658-2

my $ONE = Math::GMPz->new(1);
my $ten = Math::GMPz->new(10);
my $four = Math::GMPz->new(4);

my %cache;

sub S ($n) {
    return 0 if ($n == 0);
    return $ONE if ($n == 1);
    $cache{$n} //= (3 * (2*$n - 3) * S($n-1) - ($n-3) * S($n-2)) / $n;
}

foreach my $n(353+1 .. 1e6) {
    #say "Testing:  $n! - 1  ->  $n";
    #my $t = S($n+1);

    #my $t = lucasu(2, -1, $n);
    my $t = $four**$n - $n;

    say "[$n] Testing: 4^$n - $n";

    if (is_semiprime( $t )) {
        die "\nFound: $n\n";

        #~ if ($n > 263) {
            #~ die "\n\n\t\tFound: $n\n\n";
        #~ }
    }
}

# https://oeis.org/A252657
# a(10) >= 483                  -- http://factordb.com/index.php?id=1100000000251223208

# https://oeis.org/A252663
# 107, 117, 143, 149, 177,

# https://oeis.org/A216378
# 111, 117, 123, 181, 184, 187,

# https://oeis.org/A085725
# 76,
