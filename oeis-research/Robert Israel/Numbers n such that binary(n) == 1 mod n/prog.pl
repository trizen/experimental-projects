#!/usr/bin/perl

# Numbers n such that A007088(n) == 1 (mod n).
# https://oeis.org/A339567

use 5.014;
use ntheory qw(:all);
use Math::Prime::Util::GMP;

# New terms found:
#  1839399055, 7786281065, 11231388063, 17251448809

use Math::GMPz;

my $t = Math::GMPz::Rmpz_init_nobless();

my $count = 0;

for ($_ = 66439399053;  $_ <= 1e12; $_ += 2) {

   if (++$count >= 1e8) {
       say "Testing: $_";
       $count = 0;
   }

   Math::GMPz::Rmpz_set_str($t, todigitstring($_, 2), 10);

   if (Math::GMPz::Rmpz_mod_ui($t, $t, $_) == 1) {
       say "\nFound: $_\n";
   }

}

=for comment

(PARI) forprime(p=2, 10^9, if(fromdigits(binary(p))%p == 1, print1(p, ", "))); \\ ~~~~

(PARI) isok(n) = Mod(fromdigits(binary(n)), n) == 1;
forstep(k=1, 10^7, 2, if(isok(k), print1(k, ", "))); \\ ~~~~

=cut

__END__
Testing: 65039399053
Testing: 65239399053
Testing: 65439399053
Testing: 65639399053
Testing: 65839399053
Testing: 66039399053
Testing: 66239399053
Testing: 66439399053
^C
perl x.pl  21668.01s user 73.88s system 93% cpu 6:28:36.40 total
