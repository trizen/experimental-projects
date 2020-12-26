#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use Storable;
use ntheory qw(:all);
use experimental qw(signatures);
use Math::Prime::Util::GMP;

eval { require GDBM_File };

my $cache_db      = "factors.db";
my $storable_file = "factors-superpsp.storable";

dbmopen(my %cache_db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

sub is_super_pseudoprime ($n, $factors) {
    my $gcd =
      Math::Prime::Util::GMP::gcd(map { ($_ < ~0) ? ($_ - 1) : Math::Prime::Util::GMP::subint($_, 1) } split(' ', $factors));
    Math::Prime::Util::GMP::powmod(2, $gcd, $n) eq '1';
}

{
    my $g = Math::GMPz::Rmpz_init();
    my $u = Math::GMPz::Rmpz_init();
    my $t = Math::GMPz::Rmpz_init();

    sub is_super_pseudoprime_fast ($n, $factors) {

        Math::GMPz::Rmpz_set_ui($g, 0);

        foreach my $q (split(' ', $factors)) {

            ($q < ~0) ? Math::GMPz::Rmpz_gcd_ui($g, $g, $q - 1) : do {
                Math::GMPz::Rmpz_set_str($t, $q, 10);
                Math::GMPz::Rmpz_sub_ui($t, $t, 1);
                Math::GMPz::Rmpz_gcd($g, $g, $t);
            };

            Math::GMPz::Rmpz_cmp_ui($g, 1) == 0 and return;
        }

        Math::GMPz::Rmpz_set_ui($t, 2);
        Math::GMPz::Rmpz_set_str($u, $n, 10);
        Math::GMPz::Rmpz_powm($t, $t, $g, $u);
        Math::GMPz::Rmpz_cmp_ui($t, 1) == 0;
    }
}

my $table = {};

if (-e $storable_file) {
    say "# Loading data...";
    $table = retrieve($storable_file);
}

say "# Checking database...";

while (my ($key, $value) = each %cache_db) {

    next if exists $table->{$key};
    Math::Prime::Util::GMP::is_pseudoprime($key, 2) || next;

    if (is_super_pseudoprime_fast($key, $value)) {
        $table->{$key} = $value;
    }
}

say "# Storing data...";
store($table, $storable_file);

dbmclose(%cache_db);
