#!/usr/bin/perl

# Carmichael numbers (A002997) n such that n-1 is a perfect power (A001597).
# https://oeis.org/A265328

# Numbers k such that k^3+1 is a Carmichael number:
#   22934100, 59553720, 74371320, 242699310, 3190927740, 9214178820, 84855997590

# There is only one k such that k+1 is a composite number up to 10^10: 14700. - Altug Alkan, Mar 27 2016
# Open problem: are there other k, beside 14700, such that k^3+1 is a Carmichael number and k+1 is composite?

# Carmichael numbers C such that C-1 is a cube:
#   12062716067698821000001, 211215936967181638848001, 411354705193473163968001, 14295706553536348081491001, 32490089562753934948660824001, 782293837499544845175052968001, 611009032634107957276386802479001

use 5.014;
use ntheory qw(:all);
use Math::GMPz;
use Math::Prime::Util::GMP;

my $t = Math::GMPz::Rmpz_init();

# Power-2 from: 18716862864
# Power-3 from: 84855997590
# Power-4 from: 24631492
# Power-5 from: 17690329

#foreach my $k (84855997590 .. 1e11) {
forprimes {

    my $k = $_-1;

    say "Testing: $k" if ($k % 1e6 == 0);

    Math::GMPz::Rmpz_ui_pow_ui($t, $k, 3);
    Math::GMPz::Rmpz_add_ui($t, $t, 1);

    if (Math::Prime::Util::GMP::is_carmichael(Math::GMPz::Rmpz_get_str($t,10))) {
        die "Found: $k";
    }
} 84789000000, 1e11; #84855997590+2, 1e11;

# a(17) <= 12062716067698821000001. For each k in {22934100, 59553720, 74371320, 242699310, 3190927740, 9214178820, 84855997590}, which is a subset of A270840, k^3+1 is a Carmichael number.

__END__
...
Testing: 84789000000
Testing: 84801000000
Testing: 84810000000
Testing: 84814000000
Testing: 84816000000
Testing: 84822000000
Testing: 84834000000
Found: 84855997590 at x.pl line 34.
perl x.pl  10767.85s user 12.46s system 99% cpu 3:00:59.11 total
