#!/usr/bin/perl


use 5.014;
use strict;
use warnings;

use ntheory qw(:all);
use Math::AnyNum qw(iroot);

sub isok{
    my ($n, $k) = @_;

 #   $k-$n >= 0 or return 0;

    #return 0 if is_square($k);
    is_power($n+$k,3) || return 0;
    is_power($k-$n,3) || return 0;

    #foreach my $j($k-$n+1 .. $n+$k-1) {
    #    is_square($j) && return 0;
    #}

    return 1;
}

sub is_my_prime {
    my ($n) = @_;

    for my $k(1..$n*$n) {
        if (isok(2*$n, $k)) {
            return 0;
        }
    }

    return 1;
}

#~ foreach my $n(1..10000) {

    #~ if (is_my_prime($n)) {

        #~ if ($n > 1 and not is_prime($n)) {
            #~ die "error for n=$n";
        #~ }

        #~ say $n;
    #~ }

    #~ #if(isok(2*$n, $n*$n+1)) {



        #~ my $k = $n+1;

        #~ if (isok($n, $k)) {
                #~ say $n;
        #~ }

        #~ #say $n;
    #~ #}
#~ }



#~ __END__


$|=1;
my $max = 0;
foreach my $n(1..1000) {

    #$n = nth_prime($n);
#    $n = $n**3;

    my $k = 1;
    while (!isok($n, $k)) {
        ++$k;
        last if ($k >= 1e4);
    }

    isok($n, $k) || next;

    #if (not ($k >= 2*$n)) {
    #    die "error!! n=$n";
    #}

    #say "$n -> $k -> ", 2*$n + $k, ' -- ', $k - 2*$n;
    #print "$k, ";
    #~ say "$n -- $k -> [", ($n+$k)**(1/3), ", ", iroot(($k-$n), 3), "]";
    #~ say  iroot(($k-$n), 3);
    #say $k; #(($n+$k)**(1/3));
    if ($k > $max) {
        $max = $k;
        say $n, ' -> ', join(", ", factor($n+$k));
    }

    #if ($k != 2*$n) {
    #    die "Conjecture failed for n=$n";
    #}

  #  if (is_square($n) and is_prime(sqrtint($n))) {
   #     say "$n -> $k -> ", join(', ', factor($k));
  #  }

    #if ($k > $max) {
    #    $max = $k;
    #    say "$n -> $max -> ", join(", ", factor($max-1));
    #    #say $n , ' -> ', $max, ' -> ', join(', ', factor($max-1));
    #}
    #say "$n -> $k";
    #say $k;
    #say $k;

    #say "a($n) = $k";
    #print "$k, ";
    #say $k;
}
