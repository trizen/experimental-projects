#!/usr/bin/perl

# Generate Fermat pseudoprimes to a given base, that can potentially be strong pseudoprimes to multiple bases.

use 5.036;
use ntheory qw(:all);
use Math::GMPz;

sub fermat_pseudoprimes_from_multiple ($base, $bases, $m, $callback) {

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();
    my $w = Math::GMPz::Rmpz_init_set_ui($base);

    #my $L = znorder($base, $m);
    my $L = lcm(map { znorder($_, $m) } @{$bases});

    $m = Math::GMPz->new("$m");
    $L = Math::GMPz->new("$L");

    Math::GMPz::Rmpz_invert($v, $m, $L) || return;

    my $count = 0;
    for (my $p = Math::GMPz::Rmpz_init_set($v) ; ++$count < 1e4 ; Math::GMPz::Rmpz_add($p, $p, $L)) {

        Math::GMPz::Rmpz_mul($v, $m, $p);
        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
        Math::GMPz::Rmpz_powm($u, $w, $u, $v);

        if (Math::GMPz::Rmpz_cmp_ui($u, 1) == 0) {
            $callback->(Math::GMPz::Rmpz_init_set($v));
        }
    }
}

my %table;
my @primes = @{primes(nth_prime(11))};

forprimes {

    my $p = $_;
    #my $sig = join(' ', map{ kronecker($_,$p) } @primes);
    my $sig = join(' ', map { valuation(znorder($_, $p), 2) } @primes);
    push @{$table{$sig}}, $p;

} $primes[-1]+1, 1e6;

foreach my $key(sort { scalar(@{$table{$a}}) <=> scalar(@{$table{$b}})} keys %table) {
    #say "$key -> @{$table{$key}}" if scalar(@{$table{$key}} > 1);

    my @values = @{$table{$key}};

    scalar(@values) > 1 or next;

    say "# Generating for $key with ", scalar(@values), " primes";

    forcomb {

        my @comb = @values[@_];
        my $m = vecprod(@comb);

        fermat_pseudoprimes_from_multiple(2, \@primes, $m, sub ($n) { say $n if ($n > ~0) });
    } scalar(@values), 2;
}
