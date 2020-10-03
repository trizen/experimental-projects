#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 06 March 2019
# https://github.com/trizen

# Generalized algorithm for generating numbers that are smooth over a set A of primes, bellow a given limit.

#~ var a = [1729, 46657, 2433601, 2628073, 19683001, 67371265, 110592000001, 351596817937, 422240040001, 432081216001, 2116874304001, 3176523000001, 18677955240001, 458631349862401, 286245437364810001, 312328165704192001, 12062716067698821000001, 211215936967181638848001, 411354705193473163968001, 14295706553536348081491001, 32490089562753934948660824001, 782293837499544845175052968001, 611009032634107957276386802479001]
#~ say a.map{.dec.icbrt.factor_exp.grep{_[1] > 1}.grep{_[0] == 1828399}}

# [2,4]
# [3,3]
# [5,2]
# [11,2]
# [17,2]

# 2, 3, 5, 7, 11, 13, 17, 19, 23, 31, 37, 43, 53, 67, 83, 107, 131, 163, 181, 257, 263, 2837, 53129, 1828399

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 4;
    }

    if ($p == 3) {
        return valuation($n, $p) < 3;
    }

    if ($p == 5) {
        return valuation($n, $p) < 2;
    }

    if ($p == 11) {
        return valuation($n, $p) < 2;
    }

    if ($p == 17) {
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

my $z = Math::GMPz::Rmpz_init();

my $t2 = Math::GMPz::Rmpz_init_set_str("286245437364810001", 10);
my $t3 = Math::GMPz::Rmpz_init_set_str("611009032634107957276386802479001", 10);

sub isok ($n) {
    $n % 2 == 0 or return;

    #return if ($n <= 84855997590);

    foreach my $k(2..3) {

        Math::GMPz::Rmpz_ui_pow_ui($z, $n, $k);
        Math::GMPz::Rmpz_add_ui($z, $z, 1);

        #Math::GMPz::Rmpz_fits_ulong_p($z) && return;

        is_pseudoprime($z, 2) || next;
        is_prime($z) && next;

        if (is_carmichael($z)) {

            if ($k == 3 and Math::GMPz::Rmpz_cmp($z, $t3) > 0) {
                die "New term found: a^3+1 = $z";
            }

            if ($k == 2 and Math::GMPz::Rmpz_cmp($z, $t2) > 0) {
                die "New term found: a^2 + 1 = $z";
            }

            return $z;
        }
    }

    undef;
}

my @smooth_primes;

#@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 31, 37, 43, 53, 67, 83, 107, 131, 163, 181, 257, 263, 2837, 53129, 1828399);
#@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 31, 37, 43, 53, 67, 83);

#@smooth_primes = @{primes(100)};

@smooth_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 31, 37, 43, 67, 83, 107, 131, 163, 257, 263, 2837, 53129, 1828399);

my $h = smooth_numbers(84855997590, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms";

my %seen;
my @primes = @{primes(1e4,2e6)};

foreach my $n (sort {$a <=> $b} @$h) {

    #~ say "Testing: $n";
    #~ next if ($n <= 1e6);

    #~ if ($n%2 == 0) {
        #~ forprimes {
            #~ my $p = $_;
            #~ if (defined(my $z = isok($n*$p))) {
                #~ say "$n*$p -> $z" if !$seen{$z}++;
                #~ sleep 3;
            #~ }
        #~ } int(84855997590 / $n), 3e5;
    #~ }

    #~ if ($n%2 == 0) {
        #~ foreach my $k(int(84855997590/$n)..3e5) {
            #~ if (defined(my $z = isok($n*$k))) {
                #~ say "$n*$k -> $z" if !$seen{$z}++;
                #~ sleep 3;
            #~ }
        #~ }
    #~ }

    if(defined(my $z = isok($n))) {
        say "$n -> $z";
    }
}

__END__
12 -> 1729
36 -> 46657
138 -> 2628073
216 -> 46657
270 -> 19683001
1560 -> 2433601
7560 -> 432081216001
8208 -> 67371265
12840 -> 2116874304001
678480 -> 312328165704192001
22934100 -> 12062716067698821000001
59553720 -> 211215936967181638848001
74371320 -> 411354705193473163968001
242699310 -> 14295706553536348081491001
3190927740 -> 32490089562753934948660824001
9214178820 -> 782293837499544845175052968001
84855997590 -> 611009032634107957276386802479001
