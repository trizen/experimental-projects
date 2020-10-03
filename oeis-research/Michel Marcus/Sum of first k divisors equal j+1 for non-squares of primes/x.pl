#!/usr/bin/perl

# Terms of A194269 that are not squares of primes.
# https://oeis.org/A307137

# Where A194269 is:
#   Numbers j such that Sum_{i=1..k} d(i)^i = j+1 for some k where d(i) is the sorted list of divisors of j.

use 5.014;
use ntheory qw(:all);
use experimental qw(signatures);
use Math::AnyNum qw(ipow sum);
use List::Util qw(shuffle uniq);

# Also in the sequence are 122918945808 and 63602175290616. - ~~~~

sub isok ($n) {

    if (is_square($n) and is_prime(sqrtint($n))) {
        return;
    }

    return if length("$n") > 30;
    #return if (scalar(divisors($n)) > 100);

    my @d = divisors($n);

    my $s = 0;
    foreach my $k(0..$#d) {

        $s += $d[$k]**($k+1);

        if ($s == $n+1) {
            return 1;
        }

        if ($s > $n+1) {
            return;
        }
    }

    return;
}

sub construct($d) {
    ${sum(map { ipow($d->[$_], $_+1) } 0..$#$d)};
}

#my @terms = (1, 2, 17, 2*17, 79);
#while (1) {
#for (1..1e6) {
my $p = next_prime(ipow(10, 100));

for my $t(1..500) {

   my @terms = (
        grep{ $_ < $p } divisors($t)
   );

   @terms = uniq(@terms);
   @terms = sort { $a <=> $b } @terms;
   @terms = grep{$_>1} @terms;

   say "@terms";

   #unshift(@terms, 1..10);

   #$#terms = 11;
   #unshift(@terms, 1);
   #lcm(@terms) < 500 or next;

foreach my $k(5..scalar(@terms)) {

    say "Testing: $k -- ", binomial(scalar(@terms), $k);

    forcomb {
        my @d = (1, @terms[@_]);
        my $n = construct(\@d);

        if ($n > 3079148398 and isok($n-1)) {
            say "\t\t\tFound: ", $n-1;
        }

    } scalar(@terms), $k;
}
}


__END__

 isok1(n) = {my(d=divisors(n), s=0); for(k=1, #d, s += d[k]^k; if (s == n+1, return (1)); if (s > n+1, break); ); } \\ A194269

isok2(n) = issquare(n) && isprime(sqrtint(n));

isok(n) = isok1(n) && !isok2(n);
