#!/usr/bin/perl

use 5.020;
use warnings;
use Math::GMPz;

my $file = shift(@ARGV) || die "usage: perl $0 [file]\n";

open my $fh, '<', $file or die "Can't open `$file` for reading: $!";

my %seen;
my @terms;

while (<$fh>) {
    next if /^\h*#/;
    /\S/ or next;

    my $n = (split(' ', $_))[-1];
    $n =~ /^[0-9]+\z/ || next;

    next if $seen{$n}++;
    push @terms, Math::GMPz->new("$n");
}

close $fh;

@terms = sort { $a <=> $b } @terms;

open my $out_fh, '>', $file or die "Can't open `$file` for writing: $!";

foreach my $term (@terms) {
    say {$out_fh} $term;
}

close $out_fh;
