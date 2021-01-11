#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 06 March 2019
# https://github.com/trizen

# Check and use formulas defined in terms of OEIS sequences.

# usage:
#   perl main.pl "formula" [from=1] [to=10]

# Examples:
#   perl main.pl 'A033676(5)^2 + A033677(5)^2'              # 5-th term
#   perl main.pl 'A033676(n)^2 + A033677(n)^2'              # first 10 terms
#   perl main.pl 'A033676(n)^2 + A033677(n)^2' 5 20         # terms 5..20

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

*mu       = \&moebius;
*phi      = \&euler_phi;
*sigma    = \&divisor_sum;
*bigomega = \&prime_bigomega;
*Omega    = \&prime_bigomega;
*omega    = \&prime_omega;
*prime    = \&nth_prime;

sub rad ($) {
    prod(map { $_->[0] } factor_exp($_[0]));
}

sub gpf ($) {
    (factor($_[0]))[-1] // 1;
}

sub lpf ($) {
    (factor($_[0]))[0] // 1;
}

if (@ARGV) {
    my $formula = $ARGV[0];

    my $from = 1;
    my $to   = 10;

    if (@ARGV == 2) {
        $from = $ARGV[1];
        $to   = $ARGV[1];
    }
    elsif (@ARGV == 3) {
        $from = $ARGV[1];
        $to   = $ARGV[2];
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
        foreach my $n ($from .. $to) {
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
