#!/usr/bin/perl

# a(n) is the smallest odd composite k such that prime(n)^((k-1)/2) == 1 (mod k) and q^((k-1)/2) == -1 (mod k) for every prime q < prime(n).
# https://oeis.org/A309285

# Known terms:
#   341, 29341, 48354810571, 493813961816587, 32398013051587

# Upper-bounds:
#   a(6) <= 35141256146761030267
#   a(7) <= 4951782572086917319747

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

my $z   = Math::GMPz::Rmpz_init();
my $t   = Math::GMPz::Rmpz_init();
my $u   = Math::GMPz::Rmpz_init();
my $ONE = Math::GMPz::Rmpz_init_set_ui(1);

sub check {
    my ($n) = @_;

    my $p     = 2;
    my $count = 0;

    Math::GMPz::Rmpz_sub_ui($t, $n, 1);
    Math::GMPz::Rmpz_set($u, $t);
    Math::GMPz::Rmpz_div_2exp($t, $t, 1);

    while (1) {
        Math::GMPz::Rmpz_set_ui($z, $p);
        Math::GMPz::Rmpz_powm($z, $z, $t, $n);
        if (Math::GMPz::Rmpz_congruent_p($z, $u, $n)) {
            ++$count;
        }
        elsif (Math::GMPz::Rmpz_congruent_p($z, $ONE, $n)) {
            return $count + 1;
        }
        else {
            return undef;
        }
        $p = next_prime($p);
    }

    return $count;
}

my @tests = qw(341 29341 48354810571 493813961816587 32398013051587 35141256146761030267 4951782572086917319747);

foreach my $i (0 .. $#tests) {
    check(Math::GMPz->new($tests[$i])) == ($i + 1)
      or die "Error for $tests[$i]";
}

my @table = ();
my $w     = Math::GMPz::Rmpz_init();

while (my ($n, $value) = each %db) {

    Math::Prime::Util::GMP::is_euler_pseudoprime($n, 2) || next;

    Math::GMPz::Rmpz_set_str($w, $n, 10);

    my $v = check($w) // next;

    if (defined($table[$v])) {
        next if ($table[$v] < $w);
    }

    $table[$v] = Math::GMPz->new($n);
    say "a($v) <= $n";
}

dbmclose(%db);

say "\nFinal results:\n";

foreach my $i (0 .. $#table) {
    if (defined($table[$i])) {
        printf("a(%2d) <= %s\n", $i, $table[$i]);
    }
}

__END__
a( 1) <= 18446744073709551617
a( 2) <= 18456397176186985861
a( 3) <= 18512248848925882051
a( 4) <= 137384819210890995547
a( 5) <= 28000000000613222386069826859187
a( 6) <= 35141256146761030267
a( 7) <= 4951782572086917319747
a(11) <= 11968794224604718293549908104759518204343930652759288592987578098131927050572705181539873293848476235393230314654912729920657864630317971562727057595285667
a(12) <= 16293065699588634810831933763781141498750450660078823067
a(17) <= 7901877332421117604277233556001994548174031728058485631926375876865078028180049751981627864304181541061183590498201673009039329539171539230651776950727307
