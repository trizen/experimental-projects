#!/usr/bin/perl

# usage: perl prog.pl [main_file.txt] [extra_file.txt]

use 5.036;
use ntheory qw(:all);

my %smallest;

{
    open my $fh, '<', $ARGV[0];
    while (defined(my $line = <$fh>)) {
        my ($d, $term) = split(' ', $line);
        $smallest{$d} = $term;
    }
    close $fh;
}

{
    open my $fh, '<', $ARGV[1];
    while (defined(my $line = <$fh>)) {
        my ($d, $term) = split(' ', $line);

        if (not exists $smallest{$d}) {
            $smallest{$d} = $term;
        }
        else {
            my $value = $smallest{$d};
            my $cmp = cmpint($term, $value);
            if ($cmp < 0) {
                die "The value is smaller than expected: [$term, $value] for d = $d\n";
            }
            elsif ($cmp == 0) {
                if (cmpint($term, powint(10, 22)) > 0) {
                    say STDERR "Equal term: $term"
                }
            }
            else {
                if (cmpint($term, powint(10, 22)) > 0) {
                    say STDERR "[!] Not the smallest: $term -- $value for d = $d";
                }
            }
        }
    }
    close $fh;
}

foreach my $n (3..1e6) {

    $n % 2 == 0 and next;
    is_square_free($n) or next;
    gcd($n, euler_phi($n)) == 1 or next;

    exists $smallest{$n} or last;
    say "$n $smallest{$n}";
}
