#!/usr/bin/perl

use Math::GMPz;

open my $fh, '<', 'data.txt';

my %orig;

while (<$fh>) {
    if (/^a\((\d+)\)\s*=\s*(\d+)/) {
        $orig{$1} = Math::GMPz->new($2);
    }
}

close $fh;

open my $fh2, '<', '/tmp/b.txt';

my %new;
while (<$fh2>) {
    if (/^a\((\d+)\)\s*=\s*(\d+)/) {
        $new{$1} = Math::GMPz->new($2);
    }
}

close $fh2;

foreach my $k (sort { $a <=> $b } keys %new) {
    $orig{$k} //= $new{$k};
    if ($new{$k} < $orig{$k}) {
        $orig{$k} = $new{$k};
    }
}

foreach my $k (sort { $a <=> $b } keys %orig) {
    print "a($k) = $orig{$k}\n";
}
