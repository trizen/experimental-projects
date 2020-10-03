#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 27 February 2019
# https://github.com/trizen

# Compute the Riemann prime counting function for 10^n.

use 5.014;
use ntheory qw(logint prime_count);
use Math::AnyNum qw(:overload iroot ipow ilog2);
use Memoize qw(memoize);

memoize('primepi');

# numerator(sum(k=1, logint(10^n, 2), primepi(sqrtnint(10^n, k))/k));

my %primepi_lookup;
while (<DATA>) {
    my ($k, $pi) = split(' ');
    $pi = Math::AnyNum->new($pi);
    $primepi_lookup{ipow(10, $k)} = $pi;
}

foreach my $k(sort keys %primepi_lookup) {
    say "pi($k) = $primepi_lookup{$k}";
}

sub primepi {
    my ($n) = @_;
    say "computing pi($n)";

    if (exists($primepi_lookup{$n})) {
        say "found in lookup -> ", $primepi_lookup{$n};
        return $primepi_lookup{$n};
    }

    #chomp(my $pi = `../primecount $n`);
    #Math::AnyNum->new($pi);
    Math::AnyNum->new(prime_count($n));
}

sub a {
    my ($n) = @_;

    my $sum = Math::AnyNum->new(0);
    foreach my $k(1..logint(ipow(10, $n), 2)) {
        $sum += primepi(iroot(ipow(10, $n), $k))/$k;
    }

    $sum->nude;
}

use IO::Handle;

open my $num_fh, '>', 'num_3.txt';
open my $den_fh, '>', 'den_3.txt';

$num_fh->autoflush(1);
$den_fh->autoflush(1);

foreach my $n(0..27) {
    my ($nu, $de) = a($n);

    say "a($n) = $nu / $de";

    say $num_fh "$n $nu";
    say $den_fh "$n $de";
}

close $num_fh;
close $den_fh;

__END__
0 0
1 4
2 25
3 168
4 1229
5 9592
6 78498
7 664579
8 5761455
9 50847534
10 455052511
11 4118054813
12 37607912018
13 346065536839
14 3204941750802
15 29844570422669
16 279238341033925
17 2623557157654233
18 24739954287740860
19 234057667276344607
20 2220819602560918840
21 21127269486018731928
22 201467286689315906290
23 1925320391606803968923
24 18435599767349200867866
25 176846309399143769411680
26 1699246750872437141327603
27 16352460426841680446427399
