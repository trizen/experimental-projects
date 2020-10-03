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

use ntheory qw(is_prime);
use experimental qw(signatures);

sub mulmod {
    my ($n, $k, $mod) = @_;

    ref($mod)
      ? ((($n % $mod) * $k) % $mod)
      : ntheory::mulmod($n, $k, $mod);
}

# Creates the `modulo_test*` subroutines.
foreach my $g (
    [1, 1, 4,  29],
    [2, 1, 61, 3 * 41 * 17],

    #[3, 1,  5,  3],
    [4, 1, 53, 10 * 31 * 71],
    [5, 1, 23, 43],
  ) {

    no strict 'refs';
    *{__PACKAGE__ . '::' . 'modulo_test' . $g->[0]} = sub ($n, $mod) {
        my %cache;

        sub ($n) {

            $n == 0 && return $g->[1];
            $n == 1 && return $g->[2];

            if (exists $cache{$n}) {
                return $cache{$n};
            }

            my $k = $n >> 1;

#<<<
            $cache{$n} = (
                $n % 2 == 0
                    ? (mulmod(__SUB__->($k), __SUB__->($k),     $mod) - mulmod(mulmod($g->[3], __SUB__->($k - 1), $mod), __SUB__->($k - 1), $mod)) % $mod
                    : (mulmod(__SUB__->($k), __SUB__->($k + 1), $mod) - mulmod(mulmod($g->[3], __SUB__->($k - 1), $mod), __SUB__->($k),     $mod)) % $mod
            );
#>>>

          }
          ->($n - 1);
    };
}

sub is_probably_prime($n) {

    $n <= 1  && return 0;
    $n == 2  && return 1;
    $n == 3  && return 1;
    $n == 11 && return 1;
    $n == 13 && return 1;
    $n == 17 && return 1;
    $n == 59 && return 1;

    powmod(2, $n - 1, $n) == 1 or return 0;

    my $r5 = modulo_test5($n, $n);
    ($r5 == 1) or ($r5 == $n - 1) or return 0;

    my $r4 = modulo_test4($n, $n);
    ($r4 == 1) or ($r4 == $n - 1) or return 0;

    #  my $r3 = modulo_test3($n, $n);
    #  ($r3 == 1) or ($r3 == $n-1) or return 0;

    my $r2 = modulo_test2($n, $n);
    ($r2 == 1) or ($r2 == $n - 1) or return 0;

    my $r1 = modulo_test1($n, $n);
    (($n % 4 == 3) ? ($r1 == $n - 1) : ($r1 == 1)) or return 0;

    #my $r6 = modulo_test6($n, $n);
    #($r6 == 1) or ($r6 == $n-1) or return 0;
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

__END__

Known counter-examples:

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
    443372888629441
    39671149333495681
