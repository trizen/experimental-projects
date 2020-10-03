#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use ntheory qw(:all);

eval { require GDBM_File };

my $cache_db = "factors.db";

dbmopen(my %cache_db, $cache_db, 0666)
  or die "Can't create/access database <<$cache_db>>: $!";

while (my ($key, $value) = each %cache_db) {

    my $n = Math::GMPz::Rmpz_init_set_str($key, 10);
    my @factors = map { Math::GMPz::Rmpz_init_set_str($_, 10) } split(' ', $value);

    if (scalar(@factors) <= 1) {
        die "Error for n = $n with [@factors]";
    }

    if (vecprod(@factors) != $n) {
        die "Error for n = $n with [@factors]";
    }

    if (not vecall { is_provable_prime($_) } @factors) {
        die "Composite factor for n = $n with [@factors]";
    }

    @factors = sort { $a <=> $b } @factors;

    if ($value ne join(' ', @factors)) {
        say "Factors not in order for n = $n with [@factors]";
        $cache_db{$key} = join(' ', @factors);
    }
}

dbmclose(%cache_db);
