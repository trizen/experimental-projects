#!/usr/bin/perl

# a(n) is the smallest prime number whose a056240-type is n (see Comments).
# https://oeis.org/A293652

use 5.014;
#use Math::AnyNum qw(:overload);
use ntheory qw(is_prime is_square_free next_prime vecprod prev_prime vecmin vecmax prime_count vecsum forprimes forcomposites factor lastfor forpart formultiperm);
use experimental qw(signatures);

#{forprime(p=5, , ip = primepi(p); if (ip > n, x = scompo(p); fmax = vecmax(factor(x)[, 1]); ifmax = primepi(fmax); if (ip - ifmax == n, y = fmax*snumbr(p - fmax; ); if (y == x, return (p); ); ); ); ); }

#~ isok(k, n) = my(f=factor(k)); sum(j=1, #f~, f[j, 1]*f[j, 2]) == n;

#~ snumbr(n) = my(k=2); while(!isok(k, n), k++); k; /* A056240 */

#~ scompo(n) = forcomposite(k=4, , if (isok(k, n), return(k))); /* A288814 */

#~ a(n) = {forprime(p=5, , ip = primepi(p); if (
#~ ip > n, x = scompo(p); fmax = vecmax(factor(x)[, 1]); ifmax = primepi(fmax); if (ip - ifmax == n, y = fmax*snumbr(p - fmax; ); if (y == x, return (p); ); ); ); ); }

#sub isok ($k, $n) {
#my @f = factor($k);
#vecsum(factor($k)) == $n;
#}

sub find_partitions ($diff) {

    my @part;

    forpart {
        #say "@_";
        #my $sum = vecsum(@_);
        #if ($p+$sum == $n) {
        #}
        push @part, [@_];

    } $diff, {n => 2, prime => 1};

    return @part;
}

my @table;
my $last_value = 1;

sub snumbr ($n) {

    if (exists $table[$n]) {
        return $table[$n];
    }

    for (my $k = 2; ;++$k) {
        my $sum = vecsum(factor($k));

        if ($sum == $k) {
            #say "Found k = $k";
            return $k;
        }
    }
}

sub scompo2 ($n) {

    for (my $k = $last_value ; ; ++$k) {

        next if is_prime($k);

        my $sum = vecsum(factor($k));

        if (exists $table[$sum]) {
            if ($table[$sum] > $k) {
                $table[$sum] = $k;
            }
        }
        else {
            $table[$sum] = $k;
        }

        if ($sum == $n) {

            #say "n=$n -> found: $k";
            say "Found: n=$n with k = {", join(', ', factor($k)), "}";
            $last_value = $k + 1;
            return $k;
        }
    }
}

sub scompo ($n) {

    #my $k = 2;


    if (exists $table[$n]) {
        #say "Found n=$n with k = {", join(', ', factor($table[$n])), "}";
        return $table[$n];
    }


    if ($n < 300) {
        return scompo2($n);
    }

    #while (1) {
    #say "Trying for n=$n";
    #for (my $k = 1; ;++$k) {

    my $min_value = 'inf';

    for my $k(2.. 10*int sqrt $n) {

        #die 1 if ($k > $n);

        if ($k > $n) {
            die "error for n=$n";
            return undef;
        }

        is_prime($n-$k) or next;

        #say "$n - $k";

        #my $t = $k*($n-$k);
        #my $sum = $n-$k + vecsum(factor($k));

        #~ next if is_prime($t);



        #if (is_prime($n-$k) and $sum == $n) {

        #if ($sum == $n) {
        my @part = find_partitions($k);

        my $sum = $n; #$n-$k + vecsum(@$pair);

        #say "Checking $n - $k";

        foreach my $pair(@part) {

            my $prod = vecprod(@$pair)*($n-$k);

            is_square_free($prod) || next;

            #say "n=$n -> $prod -- @$pair * ", $n-$k;
           # sleep 1;

            #say "$sum == $n";

            if ($sum == $n) {
                #say  "Found: $n with @$pair and k=$k -- $prod\n";
                #sleep 1;

        if (exists $table[$sum]) {
            if ($table[$sum] > $prod) {
                $table[$sum] = $prod;
            }
        }
        else {
            $table[$sum] = $prod;
        }

                if ($prod < $min_value) {
                    $min_value = $prod;
                }

                #return $prod;
            }
        }

            #say "Found: $t for $n";
         #   return \@part;
        #}
    }

    #say "$min_value -> ", join(', ', factor($min_value));
    #die "";

    return $min_value;

   # return vecmin(

    if (exists $table[$n]) {
        #say "Found n=$n with k = {", join(', ', factor($table[$n])), "}";
        return $table[$n];
    }

    for (my $k = $last_value ; ; ++$k) {

        next if is_prime($k);

        my $sum = vecsum(factor($k));

        if (exists $table[$sum]) {
            if ($table[$sum] > $k) {
                $table[$sum] = $k;
            }
        }
        else {
            $table[$sum] = $k;
        }

        if ($sum == $n) {

            #say "n=$n -> found: $k";
            say "Found: n=$n with k = {", join(', ', factor($k)), "}";
            $last_value = $k + 1;
            return $k;
        }
    }
}

sub a($n) {

    for (my $p = 5 ; ; $p = next_prime($p)) {

        my $ip = prime_count($p);

        if ($ip > $n) {
            my $x = scompo($p);
            my $fmax = vecmax(factor($x));
            my $ifmax = prime_count($fmax);

            if ($ip - $ifmax == $n) {

                my $y = $fmax * snumbr($p - $fmax);

                if ($x == $y) {
                    #say "Found: p = $p";
                    return $p;
                }
            }
        }
    }
}

say a(1);
say a(2);
say a(3);
say a(4);
say a(5);
say a(6);

#a(4)
#say a(7);

__END__

 #~ a(n) = {
     #~ if(n <= 5, return(n));

     #~ my(p = precprime(n),
     #~ res = p * (n - p));

      #~ if(p == n, return(p), p = precprime(n - 2); res = p * a(n - p); while(res > (n - p) * p && p > 2, p = precprime(p - 1); res = min(res, a(n - p) * p)); res)}

sub a($n, $cache={}) {

    if ($n <= 5) {
        return $n;
    }

    if (exists $cache->{$n}) {
        #say "cache hit";
        return $cache->{$n};
    }

    my $p = prev_prime($n+1);
    my $res = $p*($n-$p);

    if ($p == $n) {
        return $p;
    }

    $p = prev_prime($n-1);

    $res = $p*a($n-$p, $cache);
    while ($res > ($n-$p)*$p and $p > 2) {
        $p = prev_prime($p);
         $res = vecmin($res, a($n-$p, $cache)*$p);
    }

    return ($cache->{$n} = $res);

}

#say a(int rand 10**9);

#__END__
foreach my $n(1..100) {
    #say "a($n) = ", a($n);
    if (a($n) == $n) {
        say $n;
    }
}


__END__

isok(k, n) = my(f=factor(k)); sum(j=1, #f~, f[j, 1]*f[j, 2]) == n;

snumbr(n) = my(k=2); while(!isok(k, n), k++); k; /* A056240 */

scompo(n) = forcomposite(k=4, , if (isok(k, n), return(k))); /* A288814 */

a(n) = {forprime(p=5, , ip = primepi(p); if (ip > n, x = scompo(p); fmax = vecmax(factor(x)[, 1]); ifmax = primepi(fmax); if (ip - ifmax == n, y = fmax*snumbr(p - fmax; ); if (y == x, return (p); ); ); ); ); }

__END__

a(n) = {

    if(n <= 5, return(n));

    my(p = precprime(n), res = p * (n - p)); if(p == n, return(p), p = precprime(n - 2); res = p * a(n - p); while(res > (n - p) * p && p > 2, p = precprime(p - 1); res = min(res, a(n - p) * p)); res)

}

__END__
use 5.014;
use ntheory qw(:all vecsum);

my $n = 2;

forprimes {

    if (vecsum(factor($_)) == $n) {
        say "a($n) = $_";
        ++$n;
    }

} 5, 1e12;

__END__
var P = primes(1e6.prime)

var sum = 0
for n in (^1e6) {
    sum += P[n]
}

say sum

Cf. A000203, A064987

__END__
use 5.014;
use ntheory qw(forprimes is_prime);

forprimes {


    if ((2*$_ + 1)%5==0 and is_prime((2*$_ + 1)/5)) {
        say $_;
    }

} 6e6;

__END__

#say bern(502)
for n in (500 `downto` 500-100) {
    say bern(n)
}

__END__
#~ func f(n) {

#~ }

#~ func foo(n, k) {
    #~ var sum = 0
    #~ #var prod = 1
    #~ for i in (0..k) {
        #~ var prod = 1
        #~ prod *= binomial(k+1, i)
        #~ #prod *=  n**(k + 1 - i)
        #~ prod *= euler(i)
        #~ sum += prod
    #~ }
    #~ #prod
    #~ sum
#~ }

#var A028296 = [1, -1, 5, -61, 1385, -50521, 2702765, -199360981, 19391512145, -2404879675441, 370371188237525, -69348874393137901, 15514534163557086905, -4087072509293123892361, 1252259641403629865468285, -441543893249023104553682821, 177519391579539289436664789665]

func a(n) {
    sum(0 .. floor((n-1)/2), {|k|
        euler(2*k)
        #A028296[k]
    })
}

for n in (0..500) {
    say (n, ' ', a(n))
}

__END__
var sum = 0.float
var x = -1/4

say log(1 + tanh(x))*exp(x)

for n in (0..400) {

    sum += (x**n * a(n) / n!)

    #say sum

}
say sum

#for n in (0..10) {
    #say 20.of { foo(n, _) }
#}

#say a(100)
#say 100.of(a)
#say 10.of(a)

__END__
#say a(1000)
for n in (0..100) {
    say (n, ' ', a(n))
}

#~ say 20.of(a)

#~ say 20.of { (euler(_, 1/2) + euler(_, 1)) * 2**_ }

#~ a(n) = Sum_{k=0..n-1} binomial(n, k) * euler(k). - ~~~~
