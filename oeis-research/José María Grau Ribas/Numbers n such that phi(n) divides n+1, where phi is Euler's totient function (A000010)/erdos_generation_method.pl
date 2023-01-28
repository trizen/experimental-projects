#!/usr/bin/perl

# Erdos construction method for Carmichael numbers:
#   1. Choose an even integer L with many prime factors.
#   2. Let P be the set of primes d+1, where d|L and d+1 does not divide L.
#   3. Find a subset S of P such that prod(S) == 1 (mod L). Then prod(S) is a Carmichael number.

# Alternatively:
#   3. Find a subset S of P such that prod(S) == prod(P) (mod L). Then prod(P) / prod(S) is a Carmichael number.

use 5.020;
use warnings;
use ntheory qw(:all);
use List::Util qw(shuffle);
use experimental qw(signatures);

# Modular product of a list of integers
sub vecprodmod ($arr, $mod) {

    #~ if ($mod > ~0) {
        #~ my $prod = Math::GMPz->new(1);
        #~ foreach my $k(@$arr) {
            #~ $prod = ($prod * $k) % $mod;
        #~ }
        #~ return $prod;
    #~ }

    if ($mod < ~0) {
        my $prod = 1;
        foreach my $k(@$arr) {
            $prod = mulmod($prod, $k, $mod);
        }
        return $prod;
    }

    my $prod = 1;

    foreach my $k (@$arr) {
        $prod = Math::Prime::Util::GMP::mulmod($prod, $k, $mod);
    }

    #Math::GMPz->new($prod);
    Math::GMPz::Rmpz_init_set_str($prod, 10);
}

# Primes p such that p-1 divides L and p does not divide L
sub lambda_primes ($L) {
    #grep { ($L % $_) != 0 } grep { $_ > 2 and is_prime($_) } map { $_ + 1 } divisors($L);
     grep { ($_ > 2) and (($L % $_) != 0) and is_prime($_) } map { ($_ >= ~0) ? (Math::GMPz->new($_)+1) : ($_ + 1) } divisors($L);
}

my @prefix = (3, 5, 17);
my $prefix_prod = Math::GMPz->new(vecprod(@prefix));

sub method_1 ($L) {     # smallest numbers first

    (vecall { ($L % ($_-1)) == 0 } @prefix) or return;

    my @P = lambda_primes($L);

    #say "@P";

    #~ @P = grep {
        #~ (($prefix_prod % $_) == 0)
            #~ ? 1
            #~ : Math::Prime::Util::GMP::gcd(Math::Prime::Util::GMP::totient(Math::Prime::Util::GMP::mulint($prefix_prod, $_)), Math::Prime::Util::GMP::mulint($prefix_prod, $_)) eq '1'
    #~ } @P;

    # Collect only primes p such that gcd(k*p, DedekindPsi(k*p)) = 1
    @P = grep {
        gcd(mulint($prefix_prod, $_), subint($_,1)) == 1
    } @P;

    #vecprodmod(@P, 3*5*17*23) == 0 or return;
    #vecprodmod(\@P, 3*5*17*23*29) == 0 or return;
    if (@prefix) {
        $prefix_prod = gcd($prefix_prod, vecprod(@P));
        if ($prefix_prod > ~0) {
            $prefix_prod = Math::GMPz->new($prefix_prod);
        }
    }

    #return if (vecprod(@P) < ~0);

    my $lucas_L = lcm(map{ subint($_,1) } factor($prefix_prod));

    # Prime p must not divide the Lucas lambda value
    @P = grep{ ($lucas_L % $_) != 0} @P;

    #@P = grep{ ($lucas_L % addint($_,1)) == 0} @P;

    # Keep only primes p such that p+1 is B-smooth
    #my $max_p = vecmax(map{ factor($_-1) } @P);
    #@P = grep{ is_smooth(addint($_, 1), $max_p) } @P;

    if (@prefix) {
        $prefix_prod = gcd($prefix_prod, vecprod(@P));
        if ($prefix_prod > ~0) {
            $prefix_prod = Math::GMPz->new($prefix_prod);
        }
    }

    #@P = grep { $_ > $prefix[-1] } @P;
    @P = grep { gcd($prefix_prod, $_) == 1 } @P;

    if (@P) {
        say "# Testing: $L -- ", scalar(@P);
    }
    else {
        return;
    }

    my $n = scalar(@P);
    my @orig = @P;

    my $max = 1e4;
    my $max_k = scalar(@P);

    #my $L_rem = invmod($prefix_prod, $L);
    my $L_rem = modint(-Math::GMPz->new(invmod($prefix_prod, $L)), $_);

    foreach my $k (1 .. @P) {
        #next if (binomial($n, $k) > 1e6);

        next if ($k > $max_k);

        @P = @orig;

        my $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L_rem) {
                say vecprod(@P[@_], $prefix_prod);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L_rem) {
                say vecprod(@P[@_], $prefix_prod);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L_rem) {
                say vecprod(@P[@_], $prefix_prod);
            }
            lastfor if (++$count > $max);
        } $n, $k;
    }

    #my $B = vecprodmod([@P, $prefix_prod], $L);
    my $B = modint(-Math::GMPz->new(vecprodmod([@P, $prefix_prod], $L)), $L);
    my $T = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P));

    foreach my $k (1 .. @P) {
        #next if (binomial($n, $k) > 1e6);

        last if ($k > $max_k);

        @P = @orig;

        my $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;
    }
}

use Math::GMPz;

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 68;
    }

    #~ if ($p == 11) {
        #~ return valuation($n, $p) < 4;
    #~ }

    #~ if ($p == 29) {
        #~ return valuation($n, $p) < 4;
    #~ }

   # if ($p == 157) {
        return valuation($n, $p) < 4;
  #  }

    #($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (Math::GMPz->new(1));
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

foreach my $p(@{primes(30, 500)}) {

my $h = smooth_numbers(Math::GMPz->new(10)**15, [2, 11, 29, $p]);

for (@$h) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    $n =~ /^[0-9]+\z/ || next;
    #$n < ~0 or next;
    length($n) <= 45 or next;
    $n % 2 == 0 or next;

     #~ @prefix = factor($n);
     #~ @prefix = grep { gcd($n, subint($_,1)) == 1 } @prefix;
     #~ @prefix = grep { gcd($n, addint($_,1)) == 1 } @prefix;
     #~ #$#prefix = 20;
     #~ $prefix_prod = vecprod(@prefix);

     #~ if ($prefix_prod > ~0) {
         #~ $prefix_prod = Math::GMPz->new($prefix_prod);
     #~ }

     #~ my $L = carmichael_lambda($prefix_prod);

     my $L = $n;

    if ($L > ~0) {
        $L = Math::GMPz->new("$L");
    }

    #next if $seen{$L}++;
    method_1($L);
}
}
