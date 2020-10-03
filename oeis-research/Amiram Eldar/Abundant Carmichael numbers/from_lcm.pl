#!/usr/bin/perl

use 5.014;

use Math::GMPz;
use List::Util qw(uniq);
use Math::AnyNum qw(is_smooth);
use ntheory qw(forsemiprimes is_square_free forprimes divisor_sum factor forsquarefree random_prime forcomb );
use Math::Prime::Util::GMP qw(mulint is_carmichael vecprod divint sqrtint divisors gcd);

my %seen;
#my $psp = "4788772759754985";
#my $psp = "728017010426459878356936705";
#my $psp = "1370862939340854730059272985";
#my $psp = "45737634436431198836267992527251680040385";
#my $psp = "772459017179480479061611372132330246001039753130436193419524315193543873326133868681083905";
my $psp = "37839385943068863406967633413004957540054532539686888463944906014566240419460804270776358938980032660929917901837033235462145";

#my $psp = "19948738964527549499432007591778845447137932958457586625953063419475941273954097665";
my $lcm = "125627734423978564599155144945225043810910864034881259108837007586928399580842775728597058180217416271320372031434373586786386765336286990826250428173851715663371995737469498702100674661510998130990182331496689289311793735528364441073271";

my @psp_factors = factor($psp);
my @lcm_factors = factor($lcm);

#say "@psp_factors";

@psp_factors = grep{$_ > 1e2} @psp_factors;

my $lp = vecprod(@psp_factors);
say "Sigma = ", divisor_sum($lp, 0);

my @squarefree = grep{gcd($_, $psp) == 1 and is_square_free($_)}3..1e6;

    foreach my $k(1..2) {
       say "[1] Combination: $k";
       forcomb {
           if (is_carmichael(vecprod(@lcm_factors[@_], $psp))) {
               my $v = vecprod(@lcm_factors[@_], $psp);
               if (!$seen{$v}++ and $v ne $psp) {
                   die "Found: $v";
               }
           }
       }scalar(@lcm_factors), $k;
    }

foreach my $k(3..scalar(@psp_factors)) {

    say "[2] Combination: $k";

    forcomb {
        my $p = vecprod(@psp_factors[@_]);
        say "Factor: $p";
        my $n = divint($psp, $p);

    foreach my $v (@squarefree) {
        if (is_carmichael(mulint($v, $n))) {
               my $v = mulint($v, $n);
            if (!$seen{$v}++ and $v ne $psp) {
                die "Found: $v";
            }
        }
    }

}scalar(@psp_factors), $k;
}

__END__

if (is_carmichael($psp)) {
    say $psp;
}

my $limit = sqrtint($psp);

#my $gcd = 7313655;
#my $gcd = 4381310850645;
#my $gcd = 174766108521378405;
#my $gcd = 77728835801292945;
#my $gcd = 113375180882140665;
#my $gcd = 495088126122885;
#my $gcd = 34498510635;
#my $gcd = "19976310800932286865";       # record
#my $gcd = "7051637712729097263345";
my $gcd = "7524686773155";

my @squarefree;

forprimes {
    if ($_ % 2 ==1 and gcd($_, $gcd) == 1 and is_smooth($_-1, 41)) {
        push @squarefree, $_;
    }
} 1e6;

#~ forsquarefree {
    #~ if ($_ % 2 == 1 and $_ > 1 and gcd($_, $psp) == 1) {
        #~ push @squarefree, $_;
    #~ }
#~ } 1e6;

#push @squarefree, grep{ $_>1 } divisors("6283365899669117794965");
#push @squarefree, grep{ $_>1 } divisors("19976310800932286865");
#push @squarefree, grep{$_>1} divisors("7051637712729097263345");

@squarefree = uniq(@squarefree);

my @factors = factor($psp);
@factors = grep{gcd($gcd, $_) == 1} @factors;

foreach my $k(1..scalar(@factors)>>1) {

    say "Combination: $k";

    forcomb {
        my $d = vecprod(@factors[@_]);
        my $n = divint($psp, $d);

        for (@squarefree) {
            if (is_carmichael(mulint($n, $_))) {
                say mulint($n, $_) if !$seen{mulint($n, $_)}++;
            }
        }

        } scalar(@factors), $k;
}

__END__
foreach my $p(divisors($psp)) {

    $p > 1 or next;
    last if ($p > $limit);
    next if (gcd($p, $gcd) > 1);

    my $n = divint($psp, $p);

    for (@squarefree) {
        if (is_pseudoprime(mulint($n, $_), 2)) {
            say mulint($n, $_) if !$seen{mulint($n, $_)}++;
        }
    }
}

__END__
foreach my $n(1..1e6) {

    my @copy = @factors;
    #$copy[-1] =  3*$n+1;
    #$copy[-1] =  2*$n+1;
    #$copy[-2] =  4*$n+1;

    #$copy[-2] =  2*$n+1;
    $copy[rand @copy] =  random_prime(1e4);
    $copy[rand @copy] =  random_prime(1e4);

    #$copy[rand @copy] =  random_prime(1e4);
    #$copy[rand @copy] =  2*int(rand(1e3))+1;

    #$copy[-3] =  2*int(rand(1e9))+1;
    #$copy[-2] = 3*$n+1;
    #$copy[-1] = 1;
    #$copy[rand(@copy-9)+8] =

    if (is_pseudoprime(vecprod(@copy), 2)) {
        if (vecprod(@copy) ne $psp) {
            say vecprod(@copy);
        }
    }

}

exit;

my @psp = qw(

4788772759754985
38353281032877674865
2638294879881771254145
24773130788808935997465
39898386437874778336787265
85866492509341408342261785
198408004487570768403697185

);

forsquarefree {
    #if ($_ % 80 == 9) {

    if ($_ % 2 == 1 and $_ > 1) {
        foreach my $n(@psp) {
            if (is_pseudoprime(mulint($n, $_), 2)) {
                say mulint($n, $_);
            }

            #~ my ($p, $q) = factor($_);
            #~ $n = Math::GMPz->new($n);

            #~ if ($n % $p == 0) {
                #~ if (is_pseudoprime(($n/$p)*$q, 2)) {
                    #~ say (($n/$p)*$q);
                #~ }
            #~ }

            #~ if ($n % $q == 0) {
                #~ if (is_pseudoprime(($n/$q)*$p, 2)) {
                    #~ say (($n/$q)*$p);
                #~ }
            #~ }
        }
    }

} 1e7;

__END__
