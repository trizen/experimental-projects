#!/usr/bin/perl

use 5.020;
use autodie;
use warnings;

use Math::GMPz;
use Storable;
use ntheory qw(:all);

my $storable_file = "factors.storable";
my $table         = retrieve($storable_file);

my $count = 0;

while (my ($key, $value) = each %$table) {
    if (is_pseudoprime($key, 2)) {

        #say "$key -> [@$value]";
        ++$count;
    }
}

say "There are $count Fermat pseudoprimes to base 2";
