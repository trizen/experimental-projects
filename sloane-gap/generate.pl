#!/usr/bin/perl

use 5.020;
use strict;
use warnings;

use IO::Uncompress::Unzip qw();

my %seen;

foreach my $file (glob('*.zip')) {

    say STDERR "Processing: $file";

    my $z = IO::Uncompress::Unzip->new($file);

    while ($z->nextStream) {
        while (defined(my $line = $z->getline)) {
            if ($line =~ /^\h*"data":\s*"(.*?)"/) {
                my $data = $1;

                foreach my $n (split(/,/, $data)) {
                    if ($n >= 1 and $n <= 10000) {
                        ++$seen{$n};
                    }
                }

                last;
            }
        }
    }
}

foreach my $k (1 .. 10000) {
    say($seen{$k} // 0);
}
