#!/usr/bin/perl

use 5.014;
use strict;
use warnings;
use Math::AnyNum;
use ntheory qw(vecmax);

my @files = sort glob("*.txt");

#say for @files;

my $k = 3;
open my $out_fh, '>', 'felix_output.txt';

foreach my $file(@files) {

    $file =~ m{\d+\.txt\z} or next;

    open my $fh, "<", $file;
    chomp(my @terms = <$fh>);
    @terms = map{Math::AnyNum->new($_)}@terms;
    say  $out_fh "$k ", vecmax(@terms);
    ++$k;

    close $fh;
}

close $out_fh;
say "Total records: ", $k-1;
