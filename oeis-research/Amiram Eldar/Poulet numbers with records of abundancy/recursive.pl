#!/usr/bin/perl

use 5.014;

use Math::GMPz;
use List::Util qw(uniq);
use ntheory qw(forsemiprimes forprimes factor forsquarefree random_prime divisors gcd next_prime primes);
use Math::Prime::Util::GMP qw(mulint is_pseudoprime vecprod divint sqrtint vecprod is_carmichael sigma);

use experimental qw(signatures);

my @primes = grep{$_ > 257}factor("93665736194361706290316525877947121434159238044887616153549475393018809779683526688115110040263063154457311074239226112571535724853272104087510616984592710415200871852031984070007895559451233459062578077");

sub abundancy ($n) {
    sigma($n)/$n;
}

my %seen;

sub generate ($root) {

    return if $seen{$root}++;

    if (length($root) > 40) {
        return;
    }

    my @abundant;
    foreach my $p (@primes){

        gcd($p, $root) == 1 or next;

        my $t = mulint($root, $p);
        my $ab = abundancy($t);

        if (length($t) <= 40 and $ab > 1.9 and $ab < 2.1) {

            push @abundant, $t;

            if (is_pseudoprime($t, 2)) {
                say abundancy($t), " -> ", $t;
            }
        }
    }

    #say "Generation: ", scalar(@abundant);

    foreach my $t(uniq @abundant) {
        generate($t);
    }
}

#generate(vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 127));
generate(vecprod(3, 5, 17, 23, 29, 43, 53, 89, 113, 127, 157, 257));
