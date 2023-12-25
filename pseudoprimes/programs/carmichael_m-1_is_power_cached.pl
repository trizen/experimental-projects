#!/usr/bin/perl

# Carmichael numbers n such that n-1 is a perfect power.
# https://oeis.org/A265328

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);

#use Math::Sidef qw(is_fibonacci);
#use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $carmichael_file = "cache/factors-carmichael.storable";
my $carmichael = retrieve($carmichael_file);

my $t = Math::GMPz::Rmpz_init();

while(my($key, $value) = each %$carmichael) {

    Math::GMPz::Rmpz_set_str($t, $key, 10);
    Math::GMPz::Rmpz_sub_ui($t, $t, 1);
    if (Math::GMPz::Rmpz_perfect_power_p($t)) {
        say $key;
    }
}

__END__
12062716067698821000001
20717489165917230086401
211215936967181638848001
411354705193473163968001
14295706553536348081491001
520417541686202544384000001
32490089562753934948660824001
782293837499544845175052968001
611009032634107957276386802479001
26079495962445633235872174137208001
2612444951766966131992650907329921024001
