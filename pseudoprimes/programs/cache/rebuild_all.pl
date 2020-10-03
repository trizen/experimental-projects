#!/usr/bin/perl

# Rebuild the Storable database.

use 5.020;
use warnings;

foreach my $script (glob("dbm2perl*.pl")) {
    say ":: Executing: $script";
    system($^X, $script);
}
