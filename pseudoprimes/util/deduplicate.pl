#!/usr/bin/perl

use 5.014;

my @files = glob("*.txt");

my %seen;

foreach my $file (@files) {

    next if $file =~ /other\.txt\z/;
    next if $file =~ /large_super_psp\.txt\z/;

    say "Processing: $file";

    my @content;

    do {
        open my $fh, '<', $file;

        while (<$fh>) {
            chomp;

            if (/^#/) {

                if (/^# A\d+ \(b-file synthesized from sequence entry\)/) {
                    next;
                }

                push @content, $_;
                next;
            }

            if (not /\S/) {
                push @content, '';
                next;
            }

            my ($n) = (split(' '))[-1];
            $n || next;

            next if $seen{$n}++;

            push @content, $n;
        }

        close $fh;
    };

    do {
        open my $fh, '>', $file;

        foreach my $line (@content) {
            say $fh $line;
        }

        close $fh;
    };
}
