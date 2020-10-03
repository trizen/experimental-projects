#!/usr/bin/perl


use 5.014;
use ntheory qw(:all);

my @arr = (3, 7, 23, 71, 311, 479, 1559, 5711, 10559, 18191, 31391, 422231, 701399, 366791, 3818929, 9257329, 22000801, 36415991, 48473881, 175244281, 120293879, 427733329, 131486759, 3389934071, 2929911599, 7979490791, 36504256799, 23616331489, 89206899239, 121560956039,
395668053479,
 196265095009,
 513928659191,
 5528920734431,
 2871842842801,
 4306732833311,
 8402847753431,
 70864718555231,
);

sub isok_orig {
    my ($n, $q) = @_;
    my $t = ($q-1)>>1;
    (powmod(nth_prime($n), $t, $q) == $q-1) || return 0;
    vecall { powmod($_, $t, $q) == 1 } 2..nth_prime($n)-1;
}

sub smallest {
    my($n) = @_;
    for(my $k = 3; ;$k = next_prime($k)) {
        if (isok_orig($n, $k)) {
            return $k;
        }
    }
}

foreach my $n(1..30) {
    my $t = smallest($n);
    say "a($n) = $t";

    if ($t != $arr[$n-1]) {
        say "[$n] Counter-example: $t != $arr[$n-1]";
    }
}

__END__

#~ say $arr[23];

#~ exit;

sub isok {
    my ($n, $q) = @_;
    my $t = ($q-1)>>1;
    vecall { powmod($_, $t, $q) == 1 } 2..nth_prime($n)-1;
}


#~ foreach my $k(3..1e9) {
    #~ if (isok(12, $k)) {
        #~ die "Found: $k";
    #~ }
#~ }


#~ __END__

my $n = 1;

forprimes {

    while (isok_orig($n, $_)) {
        say "a($n) = $_ -- $arr[$n-1]";

        if ($_ != $arr[$n-1]){
            say "Counter-example for n = $n";
        }
        ++$n;
    }
} 3,1e10;



__END__


# a(n) is the smallest odd prime q such that prime(n)^((q-1)/2) == -1 (mod q) and b^((q-1)/2) == 1 (mod q) for every natural base b < prime(n). - Thomas Ordowski, May 02 2019
# a(n) is the smallest odd prime q such that                                      b^((q-1)/2) == 1 (mod q) for every natural base b < prime(n).

func isok(n,q) {

    (powmod(prime(n), (q-1)/2, q) == q-1) || return false

    var bases = (1 .. prime(n)-1)
    bases.all {|b|
        powmod(b, (q-1)/2, q) == 1
    }
}

func isok_conj(n, q) {

    var bases = (1 .. prime(n)-1)

    bases.all {|b|
        powmod(b, (q-1)/2, q) == 1
    }
}

for k in (1..arr.len) {
    say [k, isok(k, arr[k-1])]
}
