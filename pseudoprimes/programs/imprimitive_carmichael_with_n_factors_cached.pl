#!/usr/bin/perl

# Least imprimitive Carmichael number (A328935) with n prime factors.
# https://oeis.org/A328938

# Imprimitive Carmichael numbers, are Carmichael numbers m such that if m = p_1 * p_2 * ... *p_k is the prime factorization of m then g(m) = gcd(p_1 - 1, ..., p_k - 1) > sqrt(lambda(m)), where lambda is the Carmichael lambda function.

# Known terms:
#   294409, 167979421, 1152091655881, 62411762908817281, 1516087654274358001

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $storable_file = "cache/factors-carmichael.storable";
my $numbers       = retrieve($storable_file);

my %table;

sub is_imprimitive_carmichael ($factors) {
    my @df = map { ($_ < ~0) ? ($_ - 1) : Math::Prime::Util::GMP::subint($_, 1) } @$factors;

    my $gcd = Math::GMPz->new(Math::Prime::Util::GMP::gcd(@df));
    my $lcm = Math::GMPz->new(Math::Prime::Util::GMP::lcm(@df));

    Math::GMPz::Rmpz_sqrt($lcm, $lcm);
    $gcd > $lcm;
}

foreach my $n (
               294409,   399001,   488881,   512461,   1152271,  1461241,   3057601,   3828001,  4335241,  6189121,
               6733693,  10267951, 14676481, 17098369, 19384289, 23382529,  50201089,  53711113, 56052361, 64377991,
               68154001, 79624621, 82929001, 84350561, 96895441, 115039081, 118901521, 133800661
  ) {
    is_imprimitive_carmichael([factor($n)]) || die "error: $n";
}

while (my ($key, $value) = each %$numbers) {

    my @factors = split(' ', $value);
    my $omega   = scalar(@factors);

    next if ($omega < 8);

    my $n = Math::GMPz::Rmpz_init_set_str($key, 10);

    if (not exists $table{$omega}) {
        if (is_imprimitive_carmichael(\@factors)) {
            $table{$omega} = $n;
            printf("a(%2d) <= %s\n", $omega, $n);
        }
    }
    elsif ($n < $table{$omega}) {
        if (is_imprimitive_carmichael(\@factors)) {
            $table{$omega} = $n;
            printf("a(%2d) <= %s\n", $omega, $n);
        }
    }
}

say "\nFinal results:";

foreach my $k (sort { $a <=> $b } keys %table) {
    printf("a(%2d) <= %s\n", $k, $table{$k});
}

__END__

a( 8) <= 1717329690048308373193368241
a( 9) <= 3267914929260691848833226795711841
a(10) <= 16412975107923138847512341751620644377601
a(11) <= 325533792014488126487416882038879701391121
a(12) <= 1605045791181700950034233564955898780122791301414374937801
a(13) <= 1802188215375086135161896807172372148518756613537876342449815601
a(14) <= 37301957856686414877340399600312307212530668530569712518803959550606029812859921
a(15) <= 111752741147928878460543122185614013584493764844954493341714777557828905006762368931787841
