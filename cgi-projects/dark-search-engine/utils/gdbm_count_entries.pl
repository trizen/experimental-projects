#!/usr/bin/perl

# Author: Trizen
# Date: 03 April 2023
# https://github.com/trizen

# Count the number of entries in a GDBM database.

use 5.036;
use GDBM_File;

scalar(@ARGV) == 1 or die "usage: $0 [input.dbm]";

my $input_file  = $ARGV[0];

if (not -f $input_file) {
    die "Input file <<$input_file>> does not exist!\n";
}

tie(my %input, 'GDBM_File', $input_file, &GDBM_READER, 0555)
  or die "Can't access database <<$input_file>>: $!";

my $count = 0;

while (my ($key, $value) = each %input) {
    ++$count;
}

say "Total entries: $count";

untie(%input);
