#!/usr/bin/perl

# a(n) = beginning of a run of at least n primes when x -> 3*x - 2 is iterated.
# https://oeis.org/A323713

# Terms:
#   2, 3, 3, 5, 61, 1171241, 1197631, 25451791, 25451791, 9560914721, 9560914721, 860964705721, 185133795875771

use 5.014;
use ntheory qw(:all);

my %table;

use 5.014;
use ntheory qw(:all);

{
my $x = 9560914721;

for my $k (1..15) {
    say "[$k] $x -> ", is_prime($x);
    $x = 3*$x - 2;
}
}

forprimes {

    my $k = $_;
    my $count = 2;
    my $x = 3*$k - 2;

    while (is_prime($x)) {

        if (not exists $table{$count}) {
            $table{$count} = $k;
            say "a($count) = $k";
        }

        $x = 3*$x - 2;
        ++$count;
    }

        #if ($count > 11) {
        #    say "a($count) = $k";
        #}

        #if ($count == 10) {
        #    die "Found -- $k";
        #}

} 1000000000;

use Data::Dump qw(pp);
pp \%table;
