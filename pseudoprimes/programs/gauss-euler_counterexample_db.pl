#!/usr/bin/perl

# Try to find a counter-example to the following 26+4 test:
#   https://arxiv.org/pdf/2311.07048.pdf

# See also:
#   https://www.mersenneforum.org/showthread.php?t=27288&page=3

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

sub is_ok($n, $z) {

    Math::Prime::Util::GMP::is_strong_pseudoprime($n, $z) || return;
    Math::GMPz::Rmpz_sub_ui($z, $z, 2);
    Math::Prime::Util::GMP::is_strong_pseudoprime($n, $z) || return;
    Math::GMPz::Rmpz_add_ui($z, $z, 1);
    Math::Prime::Util::GMP::is_strong_pseudoprime($n, $z) || return;
    Math::GMPz::Rmpz_add_ui($z, $z, 2);
    Math::Prime::Util::GMP::is_strong_pseudoprime($n, $z) || return;
    Math::GMPz::Rmpz_add_ui($z, $z, 1);
    Math::Prime::Util::GMP::is_strong_pseudoprime($n, $z) || return;

    return 1;
}

my $z = Math::GMPz::Rmpz_init();

while (my ($n, $value) = each %db) {

    Math::Prime::Util::GMP::is_strong_pseudoprime($n, 2) || next;

    Math::GMPz::Rmpz_set_str($z, "$n", 10);
    Math::GMPz::Rmpz_sqrt($z, $z);
    is_ok($n, $z) || next;

    say "Strong candidate: $n";

    my $ok = 1;
    foreach my $k (2, 3, 5, 7) {
        Math::GMPz::Rmpz_set_str($z, "$n", 10);
        Math::GMPz::Rmpz_div_ui($z, $z, $k);
        Math::GMPz::Rmpz_sqrt($z, $z);
        if (not is_ok($n, $z)) {
            $ok = 0;
            last;
        }
    }

    if ($ok) {
        die "Counter-example: $n";
    }
}

dbmclose(%db);

__END__
Strong candidate: 21799679499855951440790695653
Strong candidate: 414775787512777289605001428392961
Strong candidate: 1240231697100669301580000053153
Strong candidate: 47358126264277687729736538260640361
Strong candidate: 1196372393510837715901
Strong candidate: 197734612396517932861
Strong candidate: 202278967333409551940317
Strong candidate: 21298066960797290008315675981
Strong candidate: 17382942756591571116689204567251
Strong candidate: 9278429690310147005187985717030752794327663339521
Strong candidate: 188464763337512904668161
Strong candidate: 53746997020689787957114446770698223988181
Strong candidate: 331283599542836714881
Strong candidate: 4736959538130074753976271501
Strong candidate: 366561981379415638100780135641
Strong candidate: 17549634678726794947542331
Strong candidate: 5831377063293410935741
Strong candidate: 4808909621762460059206771635409661401
Strong candidate: 4619825290614895285579776001
Strong candidate: 2547824360659482079150411
Strong candidate: 115244331850772213443201
Strong candidate: 12307392018216273778381
Strong candidate: 75257154388706023071521
Strong candidate: 2736700706799799817698981
Strong candidate: 55134316712426407837214653
Strong candidate: 421388268445534102651
Strong candidate: 1676991107224649318761789260301
Strong candidate: 2087523327838745971351
Strong candidate: 29459595391587275041
Strong candidate: 27393967090456157700880458957419898348001
Strong candidate: 19619535851111080779494491
