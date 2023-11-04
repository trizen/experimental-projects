#!/usr/bin/perl

# Try to factorize a given list of pseudoprimes.

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

my %seen;
my @numbers;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    if (!$seen{$n}++) {
        push @numbers, $n;
    }
}

@numbers || die "Found no valid numbers to factors!";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my @numbers_to_factor;

foreach my $n (@numbers) {

    my $z = Math::GMPz->new($n);

    if (exists $db{$z}) {
        my $value = $db{$z};
        say "$n = ", join(" * ", split(' ', $value));
        next;
    }

    if (is_prime($z)) {
        say "$n = $z\n";
        next;
    }

    if ($z <= Math::GMPz->new(2)**64) {
        say "$n = ", join(" * ", factor($z));
        next;
    }

    push @numbers_to_factor, [$n, $z];
}

@numbers_to_factor || do {
    say ":: Done!";
    exit;
};

my %factors;
my $g = Math::GMPz::Rmpz_init();
my $t = Math::GMPz::Rmpz_init();

while (my ($key, $value) = each %db) {

    length($key) >= 40 or next;
    Math::GMPz::Rmpz_set_str($t, $key, 10);

    foreach my $pair (@numbers_to_factor) {
        my ($n, $z) = @$pair;

        Math::GMPz::Rmpz_gcd($g, $t, $z);

        if (Math::GMPz::Rmpz_cmp_ui($g, 1) > 0) {

            my @list = map { Math::GMPz::Rmpz_init_set_str($_, 10) } split(' ', $value);

            foreach my $p (@list) {
                while (Math::GMPz::Rmpz_divisible_p($z, $p)) {
                    Math::GMPz::Rmpz_divexact($z, $z, $p);
                    push @{$factors{$n}}, $p;
                    say "$n = ", join(" * ", @{$factors{$n}});
                }
            }
        }
    }
}

dbmclose(%db);

say "\nFinal results:";

foreach my $n (keys %factors) {
    say "$n = ", join(' * ', @{$factors{$n}});
}
