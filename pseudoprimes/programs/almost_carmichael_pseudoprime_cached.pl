#!/usr/bin/perl

# Smallest weak pseudoprime to all natural bases up to prime(n) that is not a Carmichael number.
# https://oeis.org/A285549

# Version with terms > 2^64.

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $fermat_file     = "cache/factors-fermat.storable";
my $carmichael_file = "cache/factors-carmichael.storable";

my $carmichael = retrieve($carmichael_file);
my $fermat     = retrieve($fermat_file);

my @terms;

while (my ($n) = each %$fermat) {

    next if length($n) > 100;
    next if exists $carmichael->{$n};

    push @terms, Math::GMPz->new($n);
}

@terms = sort { $a <=> $b } @terms;

my $p     = 2;
my @bases = ($p);

foreach my $n (@terms) {
    while (is_pseudoprime($n, @bases)) {
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
a( 5) <= 18479446505090544961
a( 6) <= 18785283139452669841
a( 7) <= 18785283139452669841
a( 8) <= 18872942465780679457
a( 9) <= 18872942465780679457
a(10) <= 18872942465780679457
a(11) <= 29782535170930902361
a(12) <= 44212062084973544161
a(13) <= 110098481668555259881
a(14) <= 110098481668555259881
a(15) <= 110098481668555259881
a(16) <= 183404635770837594961
a(17) <= 183404635770837594961
a(18) <= 1543267864443420616877677640751301
a(19) <= 1543267864443420616877677640751301

# Very large term:

a(20) <= 8038374574536394912570796143419421081388376882875581458374889175222974273765333652186502336163960045457915042023603208766569966760987284043965408232928738791850869166857328267761771029389697739470167082304286871099974399765441448453411558724506334092790222752962294149842306881685404326457534018329786111298960644845216191652872597534901
