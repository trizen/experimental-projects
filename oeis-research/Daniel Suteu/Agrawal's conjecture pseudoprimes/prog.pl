#!/usr/bin/perl

# Poulet numbers (Fermat pseudoprimes to base 2) that are congruent to {3,27} mod 80 and each prime factor is congruent to 3 mod 80.

# 51962615262396907, 330468624532072027, 2255490055253468347, 18436227497407654507

# If a term of this sequence is also a Carmichael number (A002997) and a Lucas-Carmichael number (A006972), then it would be a counterexample to Agrawal's conjecture, as Lenstra and Pomerance showed.

# 330468624532072027 is the only Carmichael number bellow 2^64 that is a term of this sequence.

# The sequence also includes: 68435117188079800987, 164853581396047908970027, 522925572082528736632187, 1820034970687975620484907, 4263739170243679206753787, 4360728281510798266333387, 28541906071781213329174507, 33833150661360980271172507, 84444874320158644422192427, 175352076630428496579381067, 270136290676063386556053067, 615437738523352001584590187, 3408560627000081376639770587, 11260257876970792445537580187.

# Are all terms also strong pseudoprimes to base 2 (A001262)?

# (PARI) isok(n) = ((n%80==3) || (n%80==27)) && (Mod(2, n)^(n-1) == 1) || return(0); my(f=factor(n)[,1]); #f > 1 && #select(p->p%80==3, f) == #f;

# Agrawal's Conjecture and Carmichael Numbers

use 5.020;
use warnings;
use experimental qw(signatures);

use List::Util qw(shuffle);
use ntheory qw(forcomb forprimes kronecker divisors lucas_sequence factor_exp factor primes divisor_sum powmod);
use Math::Prime::Util::GMP qw(is_frobenius_pseudoprime vecprod binomial is_pseudoprime);

my %common_divisors;

forprimes {
    if (($_ % 80 == 3) ) {
        foreach my $d (divisors($_ - 1)) {
            #next if ($d+1 == $_);
            if (powmod(2, $d, $_) == 1) {
                push @{$common_divisors{$d}}, $_;
            }
        }
    }
} 1e10;

my $k = 3;
foreach my $arr (values %common_divisors) {

    my @nums = @$arr;
    next if (@nums < $k);

    forcomb {
        my $n = vecprod(@nums[@_]);

        if ($n > ~0) {
            say $n;
        }
    }
    scalar(@nums), $k;
}

__END__

If a term of this sequence is also a Carmichael number (A002997) and a Lucas-Carmichael number (A006972), then it would be a counterexample to Agrawal's conjecture, as Lenstra, H. W. and Carl Pomerance showed.
330468624532072027 is the only Carmichael number bellow 2^64 that is a term of this sequence. However, it is not a Lucas-Carmichael number.
The sequence also includes: 68435117188079800987, 164853581396047908970027, 522925572082528736632187, 1820034970687975620484907, 4263739170243679206753787, 4360728281510798266333387, 28541906071781213329174507, 33833150661360980271172507, 84444874320158644422192427, 175352076630428496579381067, 270136290676063386556053067, 615437738523352001584590187, 3408560627000081376639770587, 11260257876970792445537580187.
No term with 5 prime factors (which would be congruent to 3 mod 80) is known to the author.
Are all terms also strong pseudoprimes to base 2 (A001262)?

Lenstra, H. W.; Pomerance, Carl (2003), <a href="http://www.aimath.org/WWN/primesinp/primesinp.pdf">Remarks on Agrawal's conjecture</a>, American Institute of Mathematics (2003), pp. 30-32.
Tomáš Váňa, <a href="http://web.ics.upjs.sk/svoc2009/prace/7/Vana.pdf">Agrawal's Conjecture and Carmichael Numbers</a>, student scientific conference, pp. 13-22.
Wikipedia, <a href="https://en.wikipedia.org/wiki/Agrawal%27s_conjecture">Agrawal's conjecture</a>
