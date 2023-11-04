#!/usr/bin/perl

# CYF NO. 54: Find the smallest positive integer n such that Eulers Trinomial   n*n + n + 41  gives a Strong Pseudoprime (base-2).
# https://shyamsundergupta.com/canyoufind.htm

# As far as I know, no such numbers are known.
# Not even a regular base-2 pseudoprime of this form is known.

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use Math::Sidef qw(iquadratic_formula);

my %seen;
my $z = Math::GMPz::Rmpz_init();
my $t = Math::GMPz::Rmpz_init();

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];
    $n > ~0 or next;

    $n || next;

    # Check if `4*(n-41) + 1` is a square
    Math::GMPz::Rmpz_set_str($t, "$n", 10);
    Math::GMPz::Rmpz_sub_ui($t, $t, 41);
    Math::GMPz::Rmpz_mul_2exp($t, $t, 2);
    Math::GMPz::Rmpz_add_ui($t, $t, 1);
    Math::GMPz::Rmpz_perfect_square_p($t) || next;

    say "Passes the square test: $n";

    Math::Prime::Util::GMP::is_pseudoprime($n, 2) || next;

    #Math::Prime::Util::GMP::is_strong_pseudoprime($n, 2) || next;

    Math::GMPz::Rmpz_set_str($z, "$n", 10);

    my @solutions = iquadratic_formula(-1, -1, $z - 41);
    my $x         = $solutions[-1];

    say "Testing: $n with x = $x";

    if ($x * $x + $x + 41 == $z) {
        die ":: Found: $n with x = $x";
    }
}

__END__

# Some other data:

     1388903 with n =   1178  (Fibonacci pseudoprime)
     4090547 with n =   2022  (Pell pseudoprime)
    65682961 with n =   8104  (base-3 pseudoprime)
  6778640597 with n =  82332  (base-4 pseudoprime)
       16297 with n =    127  (base-5 pseudoprime)
      601441 with n =    775  (base-6 pseudoprime)
   296717891 with n =  17225  (base-7 pseudoprime)
510153776791 with n = 714250  (base-11 pseudoprime)
       54097 with n =    232  (base-13 pseudoprime)
      601441 with n =    775  (base-14 pseudoprime)
  6877467871 with n =  82930  (base-15 pseudoprime)
