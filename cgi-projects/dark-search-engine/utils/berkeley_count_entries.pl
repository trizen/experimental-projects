#!/usr/bin/perl

# Author: Trizen
# Date: 04 April 2023
# https://github.com/trizen

# Count the number of entries in a Berkeley database.

use 5.036;
use DB_File;

scalar(@ARGV) == 1 or die "usage: $0 [input.dbm]";

my $input_file  = $ARGV[0];

if (not -f $input_file) {
    die "Input file <<$input_file>> does not exist!\n";
}

tie(my %input, 'DB_File', $input_file, O_RDONLY, 0555, $DB_HASH)
  or die "Can't access database <<$input_file>>: $!";

my $count = 0;

while (my ($key, $value) = each %input) {
    ++$count;
}

say "Total entries: $count";

untie(%input);
