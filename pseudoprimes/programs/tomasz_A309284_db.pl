#!/usr/bin/perl

# a(n) is the smallest odd composite k such that prime(n)^((k-1)/2) == -1 (mod k) and b^((k-1)/2) == 1 (mod k) for every natural b < prime(n).
# https://oeis.org/A309284

# Known terms:
#   3277, 5173601, 2329584217, 188985961, 5113747913401, 30990302851201, 2528509579568281, 5189206896360728641, 12155831039329417441

# Upper-bounds:
#   a(10) <= 41154189126635405260441

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

        if ($count > 20) {
            return undef;
        }

        if (Math::GMPz::Rmpz_congruent_p($z, $ONE, $n)) {
            ++$count;
        }
        elsif (Math::GMPz::Rmpz_congruent_p($z, $u, $n)) {
            return $count + 1;
        }
        else {
            return undef;
        }
        $p = next_prime($p);
    }

    return $count;
}

my @tests =
  qw(3277 5173601 2329584217 188985961 5113747913401 30990302851201 2528509579568281 5189206896360728641 12155831039329417441 41154189126635405260441);

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

    if (defined $table[$v]) {
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
a( 1) <= 18446745108099184741
a( 2) <= 18593798498357421751
a( 3) <= 18985891658519533177
a( 4) <= 18729456153928277761
a( 5) <= 18710926304524861681
a( 6) <= 27611200272517646401
a( 7) <= 18785283139452669841
a( 8) <= 23636463607454449953601
a( 9) <= 33420814186701090241
a(10) <= 41154189126635405260441
