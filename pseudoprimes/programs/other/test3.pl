#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(powmod rootint next_prime);

# [359505020161, 1121414775001, 1682253492481, ]

my $max = 0;

use 5.020;
use strict;
use warnings;

no warnings 'recursion';

use ntheory qw(is_prime valuation powmod);
use experimental qw(signatures);

use Math::MPFR;

sub is_probably_prime {
    my ($n) = @_;

    return 1 if $n == 2;
    return 0 if $n < 2 or $n % 2 == 0;

    return 1 if $n == 5;
    return 1 if $n == 7;
    return 1 if $n == 11;
    return 1 if $n == 13;

    my $d = $n - 1;
    my $s = valuation($d, 2);

    $d >>= $s;

    my $bound = ref($n) eq 'Math::GMPz'
      ? do {
        my $r = Math::MPFR::Rmpfr_init2(64);
        Math::MPFR::Rmpfr_set_z($r, $n, 0);
        Math::MPFR::Rmpfr_log($r, $r, 0);
        2 * Math::MPFR::Rmpfr_get_d($r, 0)**2;
      }
      : 2 * log($n)**2;

  LOOP: for my $k (1 .. $bound) {

        my $x = powmod($k, $d, $n);

        if (ref($x) or $x >= (~0 >> 1)) {
            $x = Math::GMPz->new("$x");
        }

        next if $x == 1 or $x == $n - 1;

        for (1 .. $s - 1) {
            $x = ($x * $x) % $n;
            return 0  if $x == 1;
            next LOOP if $x == $n - 1;
        }
        return 0;
    }
    return 1;
}

# Find counter-examples
foreach my $n (1 .. 3000) {
    if (is_probably_prime($n)) {

        if (not is_prime($n)) {
            warn "Counter-examples: $n\n";
        }
    }
    elsif (is_prime($n)) {
        warn "Missed a prime: $n\n";
    }
}

foreach my $n (
    qw(

    790623289
    530443201
    151813201
    10024561
    1507746241
    1825568641
    1330655041
    5385832561
    9294465601

    6189121
    90698401
    888700681
    772727356801
    459572555521
    766015436161
    24783645601
    61615404001
    310449770401
    1887933601
    30680814529
    38069223721

    1414273150081
    43674868591201
    328420730229121
    348475822294081
    615482316860401
    1412368404878881
    1489873293627841

    484662529
    212680023361
    262396677543001
    1425631483865161
    1973944203788899
    2518825754955511
    4139764902984481

    221306864032801
    359505020161
    1121414775001
    1682253492481
    24400777040641
    38989474716193
    40977671331601
    46668334332673
    54080321943649
    106309139227201
    195449862688081
    224530340357233
    240723140898241
    320247762202369
    372402596837701
    443372888629441
    596657267497201
    712424619363601
    1444302789209281
    1514208533704777
    1961656420426561
    1984323150552601
    2161556745579001
    2256137288796301
    2427442746677521
    3198224171193481
    3448064239362601
    3716673343381441
    4002924544218601
    4025380496726161
    5085501271868161
    5606301981821641
    5819114530600801
    39671149333495681

    )
  ) {
    say(is_probably_prime(Math::GMPz->new($n)) ? "failed: $n" : "WOW ($n)");
}

say "=========";

my %seen;
my @nums;
while (<>) {
    next if /^\h*#/;
    my ($n) = (split(' '))[-1];

    $n || next;
    next if $seen{$n}++;

    #say $. if $. % 10000 == 0;

    if ($n >= (~0 >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    #   push @nums, $n;

    is_probably_prime($n) && warn "error: $n\n";

    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_aks_prime($n) && die "error: $n\n";
    #ntheory::miller_rabin_random($n, 7) && die "error: $n\n";
}

#@nums = sort {$a <=> $b} @nums;

#foreach my $n(@nums) {
#    is_probably_prime($n) && warn "error: $n\n";
#}
