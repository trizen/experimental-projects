#!/usr/bin/perl

# Find prime gap records, from the factors of pseudoprimes.

use 5.036;
use Storable;
use POSIX qw(ULONG_MAX);

use Math::GMPz;
use List::Util qw(uniq);
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

use constant {
    USE_MPFR => 0,  # true to check primes greater than 300
};

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my $z = Math::GMPz::Rmpz_init();

my @results;
my $max_merit = 0;

use Math::MPFR;
my $f = Math::MPFR::Rmpfr_init2(128);

while (my ($key, $value) = each %db) {

    my @factors = split(' ', $value);

    $factors[-1] > 18361375334787046697 or next;

    foreach my $p (@factors) {
        if ($p > 18361375334787046697 and (USE_MPFR ? 1 : (length($p) <= 300))) {

            #$p = Math::Prime::Util::GMP::next_prime($p);
            #$p = Math::Prime::Util::GMP::prev_prime($p);

            my $gap = Math::Prime::Util::GMP::subint(Math::Prime::Util::GMP::next_prime($p), $p);
            my $merit = USE_MPFR ? do {
                Math::MPFR::Rmpfr_set_str($f, $p, 10, 0);
                Math::MPFR::Rmpfr_log($f, $f, 0);
                Math::MPFR::Rmpfr_ui_div($f, $gap, $f, 0);
                Math::MPFR::Rmpfr_get_d($f, 0);
            } : do { $gap / log($p) };

            if ($merit > $max_merit) {
                say "Merit: $merit with g = $gap for p = $p";
                $max_merit = $merit;
            }
        }
    }
}

__END__
Merit: 1.25577454904363 with g = 88 for p = 2714804953442921912706470542501
Merit: 3.05208217232875 with g = 148 for p = 1147056470270532373861
Merit: 3.53787442283434 with g = 210 for p = 60077339080249258834663873
Merit: 3.95233801271049 with g = 274 for p = 1282102862013350567377590730597
Merit: 4.11829942456146 with g = 226 for p = 680435527254568598106721
Merit: 4.38561379855734 with g = 220 for p = 6108790953688828846561
Merit: 5.82605203757676 with g = 300 for p = 23070597828321430685567
Merit: 6.14519150536919 with g = 678 for p = 823725213912413947530390077834174890593144661261
Merit: 7.36779003891085 with g = 406 for p = 854427865432681725179473
Merit: 8.57040810150965 with g = 462 for p = 257786279140373792788201
Merit: 10.397727286833 with g = 700 for p = 172881565818578615860856969761
Merit: 11.5899202566782 with g = 586 for p = 9087403522138538233297
Merit: 14.5130453759809 with g = 798 for p = 758032929981873202950721
