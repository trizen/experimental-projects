#!/usr/bin/perl

# Poulet numbers (Fermat pseudoprimes to base 2) k that have an abundancy index sigma(k)/k that is larger than the abundancy index of all smaller Poulet numbers.
# https://oeis.org/A328691

# Known terms:
#   341, 561, 645, 18705, 2113665, 2882265, 81722145, 9234602385, 19154790699045, 43913624518905, 56123513337585, 162522591775545, 221776809518265, 3274782926266545, 4788772759754985

use 5.020;
use strict;
use warnings;

use experimental qw(signatures);
use List::Util qw(uniq shuffle);
use ntheory qw(forsquarefree forprimes divisor_sum primes valuation is_prime binomial forcomb);
use Math::AnyNum;
use Math::Prime::Util::GMP qw(gcd mulint is_pseudoprime divisors vecprod);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 8;
    }

    if ($p == 3) {
        return valuation($n, $p) < 2;
    }

    if ($p == 5) {
        return valuation($n, $p) < 1;
    }

    if ($p == 7) {
        return valuation($n, $p) < 1;
    }

    if ($p == 11) {
        return valuation($n, $p) < 2;
    }

    ($n % $p) != 0;
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

my @squarefree;

foreach my $n (@{smooth_numbers(~0, primes(13))}) {
    if (is_prime($n+1)) {
        push @squarefree, $n+1;
    }
}

push @squarefree, (3, 5, 11, 17, 23, 29, 31, 43, 47, 53, 83, 89, 113, 127, 257, 1093, 2113, 9439, 9623, 29569, 47741, 18029009);
push @squarefree, (15, 33, 51, 69, 87, 93, 129, 141, 159, 249, 267, 339, 381, 771, 3279, 6339, 28317, 28869, 88707, 143223, 54087027, 55, 85, 115, 145, 155, 215, 235, 265, 415, 445, 565, 635, 1285, 5465, 10565, 47195, 48115, 147845, 238705, 90145045, 187, 253, 319, 341, 473, 517, 583, 913, 979, 1243, 1397, 2827, 12023, 23243, 103829, 105853, 325259, 525151, 198319099, 391, 493, 527, 731, 799, 901, 1411, 1513, 1921, 2159, 4369, 18581, 35921, 160463, 163591, 502673, 811597, 306493153, 667, 713, 989, 1081, 1219, 1909, 2047, 2599, 2921, 5911, 25139, 48599, 217097, 221329, 680087, 1098043, 414667207, 899, 1247, 1363, 1537, 2407, 2581, 3277, 3683, 7453, 31697, 61277, 273731, 279067, 857501, 1384489, 522841261, 1333, 1457, 1643, 2573, 2759, 3503, 3937, 7967, 33883, 65503, 292609, 298313, 916639, 1479971, 558899279, 2021, 2279, 3569, 3827, 4859, 5461, 11051, 46999, 90859, 405877, 413789, 1271467, 2052863, 775247387, 2491, 3901, 4183, 5311, 5969, 12079, 51371, 99311, 443633, 452281, 1389743, 2243827, 847363423, 4399, 4717, 5989, 6731, 13621, 57929, 111989, 500267, 510019, 1567157, 2530273, 955537477, 7387, 9379, 10541, 21331, 90719, 175379, 783437, 798709, 2454227, 3962503, 1496407747, 10057, 11303, 22873, 97277, 188057, 840071, 856447, 2631641, 4248949, 1604581801, 14351, 29041, 123509, 238769, 1066607, 1087399, 3341297, 5394733, 2037278017, 32639, 138811, 268351, 1198753, 1222121, 3755263, 6063107, 2289684143, 280901, 543041, 2425823, 2473111, 7599233, 12269437, 4633455313, 2309509, 10316827, 10517939, 32318917, 52180913, 19705706837, 19944607, 20333399, 62479297, 100876733, 38095296017, 90831497, 279101791, 450627299, 170175815951, 284542487, 459411643, 173493153607, 1411653629, 533099767121, 860722918669);

@squarefree = uniq(@squarefree);

#say "Squarefree numbers: @squarefree";

my @new;
my @large_primes = grep { ($_ > 1e3 and $_ < 1e5) } @squarefree;

foreach my $k (2..@large_primes) {

    last if ($k > 10);

    my $count =  binomial(scalar(@large_primes), $k);

    say "Combinations with k = $k: $count";

    next if ($count > 2e6);

    forcomb {
        push @squarefree, vecprod(@large_primes[@_]);
    } scalar(@large_primes), $k;
}

@squarefree = uniq(@squarefree);
@squarefree = shuffle(@squarefree);

my %seen;

sub abundancy ($n) {
    (Math::AnyNum->new(divisor_sum($n)) / $n)->float;
}

sub generate ($root, $limit = 1.8) {

    my $abundancy = abundancy($root);
    $abundancy > $limit or return;

    return if $seen{$root}++;

    my @new;

    foreach my $s (@squarefree) {
        my $psp = mulint($s, $root);
        if (is_pseudoprime($psp, 2)) {
            say $psp, "\t-> ", abundancy($psp);
            push @new, $psp;
        }
    }

    if (@new) {
        say "# Found: ", scalar(@new), " new pseudoprimes";
    }

    foreach my $n(grep { abundancy($_) > $abundancy } @new) {
        generate($n, 1.8);
    }
}

#generate(vecprod(3, 5, 17, 23, 29, 43));
#generate(vecprod(3, 5, 17, 23, 29, 43, 53));
#generate(vecprod(3, 5, 17, 23, 29, 43, 53, 89));
#generate(vecprod(3, 5, 17, 23, 29, 43));

generate(4788772759754985);
#generate("38353281032877674865");
#generate("24773130788808935997465");
#generate("198408004487570768403697185");
#generate("4125799098581345329437336507465");
#generate("33043524980537994743463628088287185");
#generate("63507044574120563395352359559068994882385");
#generate("38689509652590150458521510396538683610190394830465");

#~ foreach my $d (@divisors) {
    #~ if (is_pseudoprime($d, 2)) {
        #~ say "# Divisor $d";
        #~ generate($d);
    #~ }
#~ }
