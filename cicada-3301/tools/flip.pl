#!/usr/bin/perl

# Flip the bits of a given input data stream

use 5.014;
use strict;
use warnings;

binmode(STDIN, ':raw');
binmode(STDOUT, ':raw');

while (<>) {
    print pack("C*", map{ $_ ^ 255 } unpack("C*", $_))
}
