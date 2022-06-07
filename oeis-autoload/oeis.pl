#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 06 March 2019
# Edit: 07 June 2022
# https://github.com/trizen

# Check and use formulas defined in terms of OEIS sequences.

# usage:
#   perl oeis.pl "formula" [from=1] [to=10]

# Examples:
#   perl oeis.pl 'A033676(5)^2 + A033677(5)^2'              # 5-th term
#   perl oeis.pl 'A033676(n)^2 + A033677(n)^2'              # first 10 terms
#   perl oeis.pl 'A033676(n)^2 + A033677(n)^2' 5 20         # terms 5..20

# Sum example:
#   perl oeis.pl 'sum(map{ A048994(n, $_) * A048993(n+$_, n)} 0..n)'

use 5.020;
use strict;
use warnings;
use lib qw(.);

no warnings qw(once redefine);

BEGIN {
    $SIG{__WARN__} = sub { print $_[0] if ($_[0] !~ /^Prototype/) };
}

BEGIN {    # support for executing the script locally from everywhere
    require File::Spec;
    require File::Basename;
    unshift @INC,
      File::Basename::dirname(
                                File::Spec->file_name_is_absolute(__FILE__)
                              ? __FILE__
                              : File::Spec->rel2abs(__FILE__)
                             );
}

require OEIS;

use ntheory qw(:all);
use experimental qw(signatures);

use Math::AnyNum qw(
  PREC 4096
  :overload :all
  );

*Im  = \&imag;
*Re  = \&real;
*Pi  = \&pi;
*Tau = \&tau;

*arccos = \&acos;
*arcsin = \&asin;
*arctan = \&atan;
*arccsc = \&acsc;
*arcsec = \&asec;
*arccot = \&acot;

*arccosh = \&acosh;
*arcsinh = \&asinh;
*arctanh = \&atanh;
*arccsch = \&acsch;
*arcsech = \&asech;
*arccoth = \&acoth;

*Bernoulli  = \&bernoulli;
*BernoulliB = \&bernoulli;
*Euler      = \&euler;
*Catalan    = \&catalan;
*Fibonacci  = \&fibonacci;
*Lucas      = \&lucas;

*mu       = \&moebius;
*phi      = \&euler_phi;
*sigma    = \&divisor_sum;
*bigomega = \&prime_bigomega;
*Omega    = \&prime_bigomega;
*omega    = \&prime_omega;
*prime    = \&nth_prime;

sub rad ($n) {
    prod(map { $_->[0] } factor_exp($n));
}

sub gpf ($n) {
    (factor($n))[-1] // 1;
}

sub lpf ($n) {
    (factor($n))[0] // 1;
}

if (@ARGV) {
    my $formula = $ARGV[0];

    my @range = (1..10);

    if (@ARGV == 2) {
        @range = ($ARGV[1]);
    }
    elsif (@ARGV == 3) {
        @range = ($ARGV[1] .. $ARGV[2]);
    }
    elsif (@ARGV > 3) {
        @range = map { tr/,//dr } (@ARGV[1..$#ARGV]);
    }

    $formula =~ s/\^/**/g;
    $formula =~ s/\b\d+\Kn\b/*n/g;
    $formula =~ s/!!/->dfactorial/g;
    $formula =~ s/!/->factorial/g;

    $formula = join(' ', split(' ', $formula));
    $formula =~ s/\xC2//g;
    $formula =~ s/ = / == /g;

    if ($formula =~ /\bn\b/) {

        $formula =~ s/\bn\b/\$n/g;

        my @terms;
        foreach my $n (@range) {
            $n = Math::AnyNum->new($n);
            push @terms, eval($formula) // last;
        }

        say join(", ", @terms);
        exit;
    }

    say eval $formula;
    exit;
}

sub f1($n) {
    A063655($n)**2 - 2 * $n;
}

sub f2 ($n) {
    A056737($n)**2 + 2 * $n;
}

sub f3 ($n) {
    A033676($n)**2 + A033677($n)**2;
}

say join(' ', map { f1($_) } 1 .. 30);
say join(' ', map { f2($_) } 1 .. 30);
say join(' ', map { f3($_) } 1 .. 30);
