#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use Storable;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniq);

eval { require GDBM_File };

my $cache_db      = "factors.db";
my $storable_file = "factors-lucas-carmichael.storable";

dbmopen(my %cache_db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

sub is_lucas_carmichael ($n, $factors) {
    my $np1 = Math::GMPz->new($n) + 1;
    return if not vecall { Math::GMPz::Rmpz_divisible_p($np1, Math::GMPz->new($_) + 1) } @$factors;
    scalar(uniq(@$factors)) == scalar(@$factors);
}

sub is_lucas_carmichael_fast ($n, $factors) {
    my $np1 = Math::Prime::Util::GMP::addint($n, 1);
    return if not vecall {
        Math::Prime::Util::GMP::modint($np1, Math::Prime::Util::GMP::addint($_, 1)) eq '0'
    }
    @$factors;
    scalar(uniq(@$factors)) == scalar(@$factors);
}

{
    my $np1 = Math::GMPz::Rmpz_init();
    my $pp1 = Math::GMPz::Rmpz_init();

    sub is_lucas_carmichael_faster ($n, $factors) {
        Math::GMPz::Rmpz_set_str($np1, $n, 10);
        Math::GMPz::Rmpz_add_ui($np1, $np1, 1);
        return if not vecall {
            ($_ + 1 < ~0) ? Math::GMPz::Rmpz_divisible_ui_p($np1, $_ + 1) : do {
                Math::GMPz::Rmpz_set_str($pp1, $_, 10);
                Math::GMPz::Rmpz_add_ui($pp1, $pp1, 1);
                Math::GMPz::Rmpz_divisible_p($np1, $pp1);
            }
        }
        @$factors;
        scalar(uniq(@$factors)) == scalar(@$factors);
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

    my @factors = split(' ', $value);
    if (scalar(@factors) >= 3 and is_lucas_carmichael_faster($key, \@factors)) {

        $table->{$key} = $value;

        if (Math::Prime::Util::GMP::is_pseudoprime($key, 2)) {
            say "# Found a psp-2 Lucas-Carmichael number: $key";
        }
    }
}

say "# Storing data...";
store($table, $storable_file);

dbmclose(%cache_db);
