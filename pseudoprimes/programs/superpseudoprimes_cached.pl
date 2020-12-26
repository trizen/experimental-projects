#!/usr/bin/perl

# a(n) is the smallest super-pseudoprime to all bases <= prime(n).

# Except for a(19) (and possibly other temrs), this sequence is similar with:
# https://oeis.org/A285549

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-superpsp.storable";
my $numbers       = retrieve($storable_file);

sub is_super_pseudoprime ($n, @bases) {

    Math::Prime::Util::GMP::is_pseudoprime($n, @bases) || return 0;

    my @factors = split(' ', $numbers->{$n});
    foreach my $base (@bases) {
        powmod($base, gcd(map { Math::GMPz->new($_) - 1 } @factors), $n) == 1
          or return 0;
    }

    return 1;
}

my @terms;

foreach my $n (keys %$numbers) {
    push @terms, Math::GMPz->new($n);
}

@terms = sort { $a <=> $b } @terms;

my $p     = 2;
my @bases = ($p);

foreach my $n (@terms) {
    while (is_super_pseudoprime($n, @bases)) {
        printf("a(%2d) <= %s\n", scalar(@bases), $n);
        $p = next_prime($p);
        unshift @bases, $p;
    }
}

__END__
a( 1) <= 18446744073709551617
a( 2) <= 18446752100793694681
a( 3) <= 18446752100793694681
a( 4) <= 18446752100793694681
a( 5) <= 18785283139452669841
a( 6) <= 18785283139452669841
a( 7) <= 18785283139452669841
a( 8) <= 23961832273816038001
a( 9) <= 27993399715886948281
a(10) <= 29782535170930902361
a(11) <= 29782535170930902361
a(12) <= 43954374856221729901
a(13) <= 43954374856221729901
a(14) <= 110098481668555259881
a(15) <= 110098481668555259881
a(16) <= 183404635770837594961
a(17) <= 183404635770837594961
a(18) <= 1543267864443420616877677640751301
a(19) <= 1543267864443420616877677640751301
a(20) <= 8038374574536394912570796143419421081388376882875581458374889175222974273765333652186502336163960045457915042023603208766569966760987284043965408232928738791850869166857328267761771029389697739470167082304286871099974399765441448453411558724506334092790222752962294149842306881685404326457534018329786111298960644845216191652872597534901
