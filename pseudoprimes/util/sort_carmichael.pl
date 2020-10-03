#!/usr/bin/perl

use 5.020;
use ntheory qw(:all);
use IO::Uncompress::Bunzip2;

my $z = IO::Uncompress::Bunzip2->new($ARGV[0] // die "usage: perl script.pl [bz2-file]\n");

while (defined(my $line = $z->getline())) {

    if ($. % 100_000 == 0) {
        warn "[$. of 118968378] Processing: ", sprintf('%.2f', ($. / 118968378) * 100), "% done\n";
    }

    chomp($line);

    #~ if (substr($line, 0, 1) eq 'C') {
    #~ say ((split(' ', $line))[1]);
    #~ }

    last if $. == 1000;
}
