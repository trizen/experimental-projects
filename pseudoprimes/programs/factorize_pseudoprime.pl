#!/usr/bin/perl

# Try to factorize a pseudoprime given as a command-line argument.

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

my $n = $ARGV[0];

my $z = Math::GMPz->new($n);

if ($z <= 0) {    # validate number
    die "Invalid number: $n";
}

if (exists $db{$z}) {
    my $value = $db{$z};
    say ":: Lookup factorization:\n", join(", ", split(' ', $value));
    exit;
}

if (is_prime($z)) {
    die "The given number seems to be a prime: $z\n";
}

if ($z <= Math::GMPz->new(2)**64) {
    say ":: Small number:\n", join(", ", factor($z));
    exit;
}

my @factors;

say ":: Factoring: $n";

my $orig = Math::GMPz->new($n);
my $t    = Math::GMPz::Rmpz_init();

while (my ($key, $value) = each %db) {

    Math::GMPz::Rmpz_set_str($t, $key, 10);
    Math::GMPz::Rmpz_gcd($t, $t, $z);

    if (Math::GMPz::Rmpz_cmp_ui($t, 1) > 0) {

        my @list = map { Math::GMPz->new($_) } split(' ', $value);

        foreach my $p (@list) {
            while ($z % $p == 0) {
                $z /= $p;
                say "-> prime factor: $p";
                push @factors, $p;
            }
        }

        last if is_prime($z);
        last if ($z == 1);
    }
}

dbmclose(%db);

if (is_prime($z)) {
    push @factors, $z;
    $z = 1;
}

@factors = sort { $a <=> $b } @factors;

if ($z == 1) {
    say ":: Full factorization:";

    if (Math::GMPz->new(vecprod(@factors)) == $orig and (vecall { is_prime($_) } @factors)) {

        if (scalar(@factors) >= 2) {

            dbmopen(my %cache_db, $cache_db, 0666)
              or die "Can't create/access database <<$cache_db>>: $!";

            $cache_db{"$orig"} = join(' ', @factors);    # store factorization

            dbmclose(%cache_db);
        }
    }
    else {
        warn "[ERROR] The prime factorization seems to be incorrect!\n";
    }
}
else {
    say ":: Partial factorization:";
}

say join(', ', @factors);
