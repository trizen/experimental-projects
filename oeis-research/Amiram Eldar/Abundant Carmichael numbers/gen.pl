#!/usr/bin/perl

use 5.014;

use Math::GMPz;
use List::Util qw(uniq);
use ntheory qw(forsemiprimes rootint forprimes factor forsquarefree random_prime divisors gcd next_prime primes);
use Math::Prime::Util::GMP qw(mulint is_pseudoprime vecprod divint sqrtint vecprod is_carmichael sigma);
use Math::AnyNum qw(is_smooth);
use experimental qw(signatures);

#my @primes = factor("10009685197802534744715443494313482401091152723738784642121192679144375616651382814529624339577570705844012088914133917719807197736865507002985078061634472737208255577814479534145444128867519953253569526071446513841337155357225747799360717260975395516046192486881165626392939090421114988200970405960905903");
my @primes = grep { is_smooth($_-1, rootint($_,3)>>1) } @{primes(1000)};
#my @primes = @{primes(1086989-1000, 1086989+1000)};

sub abundancy ($n) {
    sigma($n)/$n;
}

my %seen;

sub generate ($root) {

    return if $seen{$root}++;

    if (length($root) > 45) {
        return;
    }

    my @abundant;
    foreach my $p (@primes){

        gcd($p, $root) == 1 or next;

        my $t = mulint($root, $p);

        if (length($t) <= 45 and abundancy($t) > 1.89) {

            if (abundancy($t) < 2.1) {
                push @abundant, $t;
            }

            if (is_carmichael($t)) {
                say abundancy($t), " -> ", $t;
            }
        }
    }

    #say "Generation: ", scalar(@abundant);

    foreach my $t (@abundant) {
        generate($t);
    }
}

#generate(vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 127));
#generate(vecprod(3, 5, 17, 23, 29, 53, 89));
#generate("171800042106877185");
generate(vecprod(3, 5, 17, 23, 29, 53, 89, 197));
