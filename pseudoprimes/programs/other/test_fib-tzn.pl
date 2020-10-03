#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 02 August 2017
# Edit: 30 November 2019
# https://github.com/trizen

# A very strong primality test (v4), inspired by Fermat's Little Theorem and the AKS test.

# Known counter-example to the weak version:
#   83143326880201568435669099604552661

# When combined with a strong Fermat base-2 primality test, no counter-examples are known.

use 5.020;
use strict;
use warnings;

no warnings 'recursion';

use ntheory qw(is_prime powmod random_prime urandomm is_strong_pseudoprime);
use experimental qw(signatures);

sub mulmod {
    my ($n, $k, $mod) = @_;

    ref($mod)
      ? ((($n % $mod) * $k) % $mod)
      : ntheory::mulmod($n, $k, $mod);
}

#~ Three counter-examples only:

#~ [1, 1, -503, 13],
#~ [2, 1, 233, -103],
#~ [3, 1, 107, -857],
#~ [4, 1, -29, 359],
#~ [5, 1, -373, -2],

# One large counter-example:

#~ [1, 1, 617, -127],
#~ [2, 1, -647, 163],
#~ [3, 1, -967, 953],
#~ [4, 1, -263, -691],
#~ [5, 1, -743, 241],

# Two large counter-examples:

#~ [1, 1, 17, -547],
#~ [2, 1, -137, 359],
#~ [3, 1, 157, -31],
#~ [4, 1, -7, -467],
#~ [5, 1, 947, 373],

# Two large counter-examples:

#~ [1, 1, -421, -149],
#~ [2, 1, 647, 223],
#~ [3, 1, -859, -61],
#~ [4, 1, -691, 149],
#~ [5, 1, 359, 397],

# One very large counter-example:

#~ [1, 1, 271, 191],
#~ [2, 1, -983, -911],
#~ [3, 1, 149, 83],
#~ [4, 1, -353, -829],
#~ [5, 1, -461, -491],

#~ Original:

#~ [1, 1,  4,   5],
#~ [2, 1,  2, -93],
#~ [3, 1,  -11, 19],
#~ [4, 1,  23, -101],
#~ [5, 1, -23, -29],

#my @list = ([1, 1, 4, 5]);

my @list;
foreach my $k (1 .. 5) {
    push @list, [$k, 1, (-1)**urandomm(2) * random_prime(1e3), (-1)**urandomm(2) * random_prime(1e3)];
}

say "";

foreach my $entry (@list) {
    local $" = ", ";
    say "[@{$entry}],";
}

say "";

#
## Creates the `modulo_test*` subroutines.
#
foreach my $g (

    #@list
    [1, 1, 271,  191],
    [2, 1, -983, -911],
    [3, 1, 149,  83],
    [4, 1, -353, -829],
    [5, 1, -461, -491],

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
                    ? (mulmod(__SUB__->($k), __SUB__->($k),   $mod) - mulmod(mulmod($g->[3], __SUB__->($k-1), $mod), __SUB__->($k-1), $mod)) % $mod
                    : (mulmod(__SUB__->($k), __SUB__->($k+1), $mod) - mulmod(mulmod($g->[3], __SUB__->($k-1), $mod), __SUB__->($k),   $mod)) % $mod
            );
#>>>

          }
          ->($n - 1);
    };
}

sub is_probably_prime($n) {

    $n <= 1 && return 0;

    foreach my $p (2, 3, 5, 7, 11, 17, 19, 23, 43, 79, 181, 1151, 6607, 14057) {
        if ($n == $p) {
            return 1;
        }
    }

    is_strong_pseudoprime($n, 2) || return 0;

    my $r1 = modulo_test1($n, $n);

    #(($n % 4 == 3) ? ($r1 == $n-1) : ($r1 == 1)) or return 0;
    ($r1 == 1) or ($r1 == $n - 1) or return 0;

    my $r2 = modulo_test2($n, $n);
    ($r2 == 1) or ($r2 == $n - 1) or return 0;

    my $r3 = modulo_test3($n, $n);
    ($r3 == 1) or ($r3 == $n - 1) or return 0;

    my $r4 = modulo_test4($n, $n);
    ($r4 == 1) or ($r4 == $n - 1) or return 0;

    my $r5 = modulo_test5($n, $n);
    ($r5 == 1) or ($r5 == $n - 1) or return 0;
}

say ":: Testing small numbers...";

foreach my $n (1 .. 1000) {
    if (is_probably_prime($n)) {
        if (not is_prime($n)) {
            say "Counter-example: $n";
        }
    }
    elsif (is_prime($n)) {
        say "Missed a prime: $n";
    }
}

say ":: Testing large composites...";

use Math::GMPz;

foreach my $n (
    sort { $a <=> $b }
    map  { Math::GMPz->new($_) }
    qw(
    1027334881
    208969201
    260245228321
    359505020161
    30304281601
    30680814529
    373523673601
    377555665201
    120871699201

    83143326880201568435669099604552661

    5902446537594114481

    13938032454972692851
    176639720841995571276421

    8273838687436582743601
    5057462719726630861278061

    1543272305769601
    25214682289344970125061
    594984649904873169943321

    986308202881
    11674038748806721

    9049836479041
    52451136349921
    122570307044209
    5151560903656250449
    10021721082510591541
    64296323802158793601
    99270776480238208441

    1574601601
    3711456001

    58891472641
    860293156801
    9173203300801

    774558925921
    40395626998273

    27192146983681
    539956339242241
    1428360123889921

    360570785364001
    26857102685439041

    9599057610241
    598963244103226621

    6615533841841
    512617191379440810961

    32334452526861101
    39671149333495681
    934216077330841537
    9610653088766378881

    74820786179329
    227291059980601

    7954028515441
    1738925896140049

    23562188821
    3226057632001
    6477654268801
    46843949912257
    5539588182853381
    1352358402913
    443372888629441
    921259517831137
    842526563598720001
    2380296518909971201
    3188618003602886401

    843347325974413121
    883253991797747461
    229386598589242644481
    3104745148145953757281
    407333160866845741098841
    1107852524534142074314801
    )
  ) {
    say "Known counter-example: $n" if is_probably_prime(Math::GMPz->new("$n"));
}

say ":: Pre-test done...";

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    if ($n >= ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    if (is_probably_prime($n)) {
        warn "New counter-example: $n\n";
    }
}
