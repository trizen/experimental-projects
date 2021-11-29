#!/usr/bin/perl

# Find a given number (along with its position) inside a sorted list of numbers, using the binary search algorithm.
# Code from "Mastering Algorithms with Perl" book derived from code by Nathan Torkington.

# Usage example:
#   perl binary_search_in_file.pl ../psps-below-2-to-64.txt 6363587284141924777

use 5.010;
use strict;
use autodie;
use warnings;

# Using Math::BigInt to work with very large files
use Math::BigInt try => 'GMP,Pari';

# For parsing the command line switches
use Getopt::Std qw(getopts);

my %opts;
getopts('lh', \%opts);

sub usage {
    my ($code) = @_;

    print <<"USAGE";
usage: $0 [options] <file> <line>

example:
        perl $0 bigList.txt 341
USAGE

    exit $code;
}

usage(0)  if $opts{h};
usage(-1) if $#ARGV != 1;

my ($file, $word) = @ARGV;

open(my $fh, '<', $file);
my $position = binary_search_file($fh, $word);

if   (defined $position) { print "$word occurs at position $position\n" }
else                     { print "$word does not occur in $file.\n" }

sub binary_search_file {
    my ($file, $word) = @_;

    my $low  = Math::BigInt->new(0);           # Guaranteed to be the start of a line.
    my $high = Math::BigInt->new(-s $file);    # Might not be the start of a line.

    my $line;
    while ($high != $low) {

        my $mid = ($high + $low) / 2;
        seek($file, $mid, 0);

        # $mid is probably in the middle of a line, so read the rest
        # and set $mid2 to that new position.
        scalar <$file>;
        my $mid2 = Math::BigInt->new(tell($file));

        if ($mid2 < $high) {    # We're not near file's end, so read on.
            $mid  = $mid2;
            $line = <$file>;
        }
        else {                  # $mid plunked us in the last line, so linear search.
            seek($file, $low, 0);
            while (defined($line = <$file>)) {
                last if compare($line, $word) >= 0;
                $low = Math::BigInt->new(tell($file));
            }
            last;
        }

        compare($line, $word) == -1
          ? ($low = $mid)
          : ($high = $mid);
    }

    compare($line, $word) == 0
      ? $low
      : ();
}

sub compare {
    my ($word1, $word2) = @_;

    chomp $word1;
    $word1 <=> $word2;
}
