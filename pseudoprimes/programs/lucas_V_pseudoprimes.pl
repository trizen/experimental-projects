#!/usr/bin/perl

# Try to find large Lucas V pseudoprimes, as defined in the "STRENGTHENING THE BAILLIE-PSW PRIMALITY TEST" paper.

# See also:
#   https://arxiv.org/pdf/2006.14425.pdf -- STRENGTHENING THE BAILLIE-PSW PRIMALITY TEST

# All the known terms are:
#   913, 150267335403, 430558874533, 14760229232131, 936916995253453

use 5.036;
use Math::GMPz;
use ntheory qw(forprimes foroddcomposites);
use Math::Prime::Util::GMP qw(:all);

sub findQ ($n) {

    # Find first D for which kronecker(D, n) == -1
    for (my $k = 2 ; ; ++$k) {
        my $D = (-1)**$k * (2 * $k + 1);
        my $K = Math::GMPz::Rmpz_si_kronecker($D, $n);

        if ($K == 0) {
            my $g = gcd($D, $n);
            if ($g > 1 and $g < $n) {
                return undef;
            }
        }

        if ($k == 20 and Math::GMPz::Rmpz_perfect_square_p($n)) {
            return undef;
        }

        if ($K == -1) {
            return divint((1 - $D), 4);
        }
    }
}

sub is_lucas_V_pseudoprime ($n) {

    if (ref($n) ne 'Math::GMPz') {
        $n = Math::GMPz->new("$n");
    }

    if (Math::GMPz::Rmpz_even_p($n)) {
        return 1 if (Math::GMPz::Rmpz_cmp_ui($n, 2) == 0);
        return 0;
    }

    my $P = 1;
    my $Q = findQ($n) // return 0;

    if ($Q == -1) {
        $P = 5;
        $Q = 5;
    }

    state $t = Math::GMPz::Rmpz_init();
    state $u = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_add_ui($t, $n, 1);

    my ($U, $V, $Qk) = lucas_sequence($n, $P, $Q, $t);
    Math::GMPz::Rmpz_set_str($t, $V, 10);
    Math::GMPz::Rmpz_set_si($u, 2*$Q);
    Math::GMPz::Rmpz_congruent_p($t, $u, $n);
}

is_lucas_V_pseudoprime(913)             or die "error";
is_lucas_V_pseudoprime(150267335403)    or die "error";
is_lucas_V_pseudoprime(430558874533)    or die "error";
is_lucas_V_pseudoprime(14760229232131)  or die "error";
is_lucas_V_pseudoprime(936916995253453) or die "error";

say "Sanity check...";

forprimes {
    if (is_strong_pseudoprime($_, 2) and !is_lucas_V_pseudoprime($_)) {
        die "Missed prime: $_";
    }
} 1e6;

foroddcomposites {
    if (is_strong_pseudoprime($_, 2) and is_lucas_V_pseudoprime($_)) {
        die "Counter-example: $_";
    }
} 1e6;

say "Done...";
say "Beginning the test...";

my %seen;
my $z = Math::GMPz::Rmpz_init();

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];
    $n || next;
    $n > 1e15 or next;

    # say "Testing: $n";

    Math::GMPz::Rmpz_set_str($z, "$n", 10);
    if (is_lucas_V_pseudoprime($z)) {
        say $n if !$seen{$n}++;
    }
}
