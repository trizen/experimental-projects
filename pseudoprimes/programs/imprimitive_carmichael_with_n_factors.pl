#!/usr/bin/perl

# Least imprimitive Carmichael number (A328935) with n prime factors.
# https://oeis.org/A328938

# Imprimitive Carmichael numbers, are Carmichael numbers m such that if m = p_1 * p_2 * ... *p_k is the prime factorization of m then g(m) = gcd(p_1 - 1, ..., p_k - 1) > sqrt(lambda(m)), where lambda is the Carmichael lambda function.

# Known terms:
#   294409, 167979421, 1152091655881, 62411762908817281, 1516087654274358001

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures);
use Math::Prime::Util::GMP;
use Math::AnyNum qw(is_smooth);

my %table;

sub is_imprimitive_carmichael ($n, @factors) {
    my $gcd = gcd(map { $_ - 1 } @factors);
    $gcd > sqrtint(carmichael_lambda($n));
}

foreach my $n (
               294409,   399001,   488881,   512461,   1152271,  1461241,   3057601,   3828001,  4335241,  6189121,
               6733693,  10267951, 14676481, 17098369, 19384289, 23382529,  50201089,  53711113, 56052361, 64377991,
               68154001, 79624621, 82929001, 84350561, 96895441, 115039081, 118901521, 133800661
  ) {
    is_imprimitive_carmichael($n, factor($n)) || die "error: $n";
}

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if ($n < ~0);
    next if (length($n) > 50);

    Math::Prime::Util::GMP::is_pseudoprime($n, 2) || next;

    $n = Math::GMPz::Rmpz_init_set_str($n, 10);

    is_smooth($n, 1e6) || next;
    is_carmichael($n) || next;

    my @factors = factor($n);
    my $omega   = scalar(@factors);

    next if ($omega < 8);

    if (not exists $table{$omega}) {
        if (is_imprimitive_carmichael($n, @factors)) {
            $table{$omega} = $n;
            say "a($omega) <= $n";
        }
    }
    elsif ($n < $table{$omega}) {
        if (is_imprimitive_carmichael($n, @factors)) {
            $table{$omega} = $n;
            say "a($omega) <= $n";
        }
    }
}

say "\n=> Final results:\n";

foreach my $n (sort { $a <=> $b } keys %table) {
    say "a($n) <= $table{$n}";
}

__END__

# New upper-bounds:

a(8)  <= 1717329690048308373193368241
a(9)  <= 21593590390253023722267234622513201
a(10) <= 16412975107923138847512341751620644377601
a(11) <= 325533792014488126487416882038879701391121
a(12) <= 132732327554333385101305659953103545953317505224547845315912001
a(14) <= 3421617881400140801930783805956554463943425366913528629583821415430815065123979759824141204067273553921

# Old upper-bounds:

a(8)  <= 42310088783100741554666880481
a(8)  <= 80005770784027020716348038561
a(8)  <= 179218381771169301154897163521
a(8)  <= 426568164600384245711552367601
a(8)  <= 739837461421980120064468068001
a(8)  <= 138536512748666054320844743023601
a(8)  <= 4588992863037092252007674629441201
a(8)  <= 153569624553607235525378750020077225001

a(9)  <= 2264649016727957907990967078579136641
a(9)  <= 1364656632212215504220263653642019484401
a(9)  <= 1609735755339126374297573011093753340361601
a(9)  <= 1134542679725174129575608955067867959814045881
a(9)  <= 46114738035350134199537804308315602549161544001

a(10) <= 35979890186226374474381052269640798043441
a(10) <= 921597968302274500375558210323060459233318163841
a(10) <= 10049453662632401998927673193640365140195738936088001
a(10) <= 78795366985518847358434670904461300131946346031853032801

a(11) <= 6026860872604484507945379403536852236099464801
a(11) <= 16545701621667214205126525402642300195474776622944801

a(12) <= 226225912894658708366011763139396936344435704491467758589715851687280001
