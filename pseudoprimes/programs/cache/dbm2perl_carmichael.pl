#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use Storable;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniq);
use Math::Prime::Util::GMP;

eval { require GDBM_File };

my $cache_db = "factors.db";
my $storable_file = "factors-carmichael.storable";

dbmopen(my %cache_db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

sub my_is_carmichael ($n, $factors) {
    my $nm1 = Math::GMPz->new($n)-1;
    return if not vecall { Math::GMPz::Rmpz_divisible_p($nm1, Math::GMPz->new($_)-1) } @$factors;
    scalar(uniq(@$factors)) == scalar(@$factors);
}

sub my_is_carmichael_fast ($n, $factors) {
    my $nm1 = Math::Prime::Util::GMP::subint($n, 1);
    return if not vecall {
        Math::Prime::Util::GMP::modint($nm1, ($_ < ~0) ? ($_-1) : Math::Prime::Util::GMP::subint($_, 1)) eq '0'
    } @$factors;
    scalar(uniq(@$factors)) == scalar(@$factors);
}

my $table = {};

if (-e $storable_file) {
    say "# Loading data...";
    $table = retrieve($storable_file);
}

say "# Checking database...";

while (my ($key, $value) = each %cache_db) {

    next if exists $table->{$key};
    Math::Prime::Util::GMP::is_pseudoprime($key,2) || next;

    my @factors = split(' ', $value);
    if (scalar(@factors) >= 3 and my_is_carmichael_fast($key, \@factors)) {
        $table->{$key} = $value;
    }
}

say "# Storing data...";
store($table, $storable_file);

dbmclose(%cache_db);
