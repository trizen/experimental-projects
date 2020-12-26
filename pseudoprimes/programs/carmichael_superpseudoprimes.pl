#!/usr/bin/perl

# Carmichael numbers (A002997) that are super-Poulet numbers (A050217).
# https://oeis.org/A291637

# Terms:
#   294409, 1299963601, 4215885697, 4562359201, 7629221377, 13079177569, 19742849041, 45983665729, 65700513721, 147523256371, 168003672409, 227959335001, 459814831561, 582561482161, 1042789205881, 1297472175451, 1544001719761, 2718557844481, 3253891093249, 4116931056001, 4226818060921, 4406163138721, 4764162536641, 4790779641001, 5419967134849, 7298963852041, 8470346587201

# Let a(n) be the smallest Carmichael number with n prime factors that is also a super-Poulet to base 2.

# See also:
#   https://oeis.org/A178997

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;
use Math::AnyNum qw(is_smooth);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

sub is_super_poulet ($n, @factors) {
    Math::Prime::Util::GMP::powmod(2, Math::Prime::Util::GMP::gcd(map { $_ - 1 } @factors), $n) eq '1';
}

my %table;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n < ~0;
    next if length($n) > 65;

    Math::Prime::Util::GMP::is_pseudoprime($n, 2) || next;

    #$n = Math::GMPz::Rmpz_init_set_str($n, 10);

    #is_smooth($n, 16681005) || next;
    #is_smooth($n, 68897953) || next;

    #is_smooth($n, 1e6) || next;
    is_carmichael($n) || next;

    #say "Testing: $n";

    my @factors = Math::Prime::Util::GMP::factor($n);
    my $count   = scalar(@factors);

    next if ($count <= 4);

    if (exists $table{$count}) {
        next if ($table{$count} < $n);
    }

    if (is_super_poulet($n, @factors)) {
        $table{$count} = $n;
        say "a($count) <= $n";
    }
}

__END__

a(3) = 294409
a(4) = 3018694485093841

# Upper-bounds:

a(5) <= 521635331852681575100906881
a(5) <= 550180447449012638429789436307921
a(5) <= 35778149512351027337147882195727361
a(5) <= 13437343415614309506502995150745826689
a(5) <= 1137930883041518528992206409946572127569
a(5) <= 1399786309689339771001926183358352665729
a(5) <= 19965160652694035855750309072402341791405361489
a(5) <= 10464366490159633131542150792465458011092765539001716234470260163510406781445889413121
a(5) <= 17297277359791057885568510483893853579524220822207783474098518027858220995619492392961

# Several terms greater than 2^64, with more than 3 prime factors:

58089692384746519537
208477911353609164609
663454757323367231041
3848248138278053555713
521635331852681575100906881
