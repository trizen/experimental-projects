#!/usr/bin/perl

# Reverse the given input stream data

use 5.014;
use strict;
use warnings;

binmode(STDIN,  ':raw');
binmode(STDOUT, ':raw');

my $data = do {
    local $/;
    <>;
};

print scalar reverse $data;
