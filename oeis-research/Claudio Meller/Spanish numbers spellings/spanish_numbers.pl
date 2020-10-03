#!/usr/bin/perl

# a(n) is the smallest number such that with the letters of the name of that number we can spell the name of n numbers smaller than a(n) in Spanish.
# https://oeis.org/A317423

# First 50 terms:
#   16, 18, 23, 34, 44, 45, 42, 84, 128, 116, 54, 133, 132, 159, 196, 136, 134, 124, 250, 145, 144, 149, 261, 153, 143, 148, 147, 154, 142, 263, 275, 273, 146, 252, 233, 269, 278, 236, 369, 224, 286, 237, 238, 574, 241, 242, 398, 257, 258, 353

use 5.010;
use strict;
use warnings;

use Lingua::SPA::Numeros;

my (%c1, %c2);
my $obj = Lingua::SPA::Numeros->new(GENERO => 'o', ACENTOS => 0);

sub count_letters {
    my ($n) = @_;
    return $c1{$n} if exists($c1{$n});
    my $s = $obj->cardinal($n);
    $s =~ tr/a-z//dc;
    my %h; ++$h{$_} for split(//, $s); $c1{$n} = \%h;
}

sub check_letters {
    my ($n, $k) = @_;

    my $key = "$n $k";
    return $c2{$key} if exists($c2{$key});

    my $h = count_letters($n);
    my $t = count_letters($k);

    foreach my $k (keys %$t) {
        if (not(exists($h->{$k}) and $h->{$k} >= $t->{$k})) {
            $c2{$key} = 0;
            return 0;
        }
    }

    $c2{$key} = 1;
    return 1;
}

sub a {
    my ($i) = @_;

    for (my $n = 1 ; ; ++$n) {

        my $c = 0;
        my @numbers;

        foreach my $k (1 .. $n - 1) {
            if (check_letters($n, $k)) {
                push @numbers, [$k, $obj->cardinal($k)];
                last if ++$c > $i;
            }
        }

        if ($c == $i) {
            say "a($i) = $n, where the letters of $n (", $obj->cardinal($n), ") can form the following numbers:\n\t",
              join("\n\t", map { "$_->[0] -> $_->[1]" } @numbers), "\n";
        }
        return $n if ($c == $i);
    }
}

my @terms;
foreach my $n (1 .. 50) {
    my $t = a($n);

    #print "a($n) = $t\n";
    push @terms, $t;
}

print "\nFirst ", scalar(@terms), " terms: ";
print join(', ', @terms), "\n";
