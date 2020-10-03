#!/usr/bin/perl

use 5.020;
use strict;
use warnings;

use IO::Uncompress::Unzip qw();

foreach my $file (glob('*.zip')) {

    say STDERR "Processing: $file";

    my $z = IO::Uncompress::Unzip->new($file);

    while ($z->nextStream) {
        while (defined(my $line = $z->getline)) {
            if ($line =~ /^\h*"data":\s*"(.*?)"/) {
                my $data = $1;
                say join "\n", grep { $_ < ~0 } split(/,/, $data);
                last;
            }
        }
    }
}
