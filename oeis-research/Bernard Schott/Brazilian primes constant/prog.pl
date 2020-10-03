#!/usr/bin/perl

# Decimal expansion of the sum of reciprocals of Brazilian primes, also called the Brazilian primes constant.
# https://oeis.org/A306759

use 5.014;
#~ use Math::AnyNum qw(:overload float);

#~ my $sum = float(0);
use Math::MPFR;
my $sum = Math::MPFR::Rmpfr_init2(92);
Math::MPFR::Rmpfr_set_ui($sum, 0, 0);

open my $fh, '<', 't5.txt';

my $str = do {
    local $/;
    <$fh>;
};

#my $data = eval( do {
#    local $/;
#    <$fh>;
#} );
close $fh;
my $t = Math::MPFR::Rmpfr_init2(92);

while ($str =~ /(\d+)/g) {
    #$sum += Math::AnyNum->new($1)->inv;
    Math::MPFR::Rmpfr_set_ui($t, $1, 0);
    Math::MPFR::Rmpfr_ui_div($t, 1, $t, 0);
    Math::MPFR::Rmpfr_add($sum, $sum, $t, 0);

    #~ Math::MPFR::Rmpfr_add_d($sum, $sum, 1/$1, 0);
}

say $sum;

# B(10^19) ~ 0.33175446666446018177571079766533

# 10^12 = 0.331754390677227426801521850173028607337819345774
# 10^14 = 0.331754460113696752705452670945987494053288903943
# 10^15 = 0.331754464735448520879667677495078712564872109224
# 10^16 = 0.331754466101486907998310205443082093679034303966
# 10^17 = 0.33175446650734519516960638465

#~ 0.33175446473544852087966761101
#~ 0.33175446473544851633795978262e-1
#~ 0.331754464735448520879667677495078712564872109224
#~ 0.331754464735448516337959901210319518853745198367
#~ 0.33175446473544851633795984906e-1
#~
# Sum of reciprocals of Brazilian primes <~ 10^k, for k=14: 0.33175446011..., k=15: 0.33175446473..., k=16: 0.331754466101..., and k=17: 0.331754466507... (using Maximilian's PARI program from A085104).


__END__
while (<>) {
    /^#/ and next;
    my ($n, $p) = split(' ');
    $p || next;
    $p = Math::AnyNum->new($p);

    $sum += 1/$p;
    say $sum;
}

say $sum;
