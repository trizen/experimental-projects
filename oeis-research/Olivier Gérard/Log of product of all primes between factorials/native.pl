#!/usr/bin/perl

# Floor of log of product of all primes between n!+1 and (n+1)!.
# https://oeis.org/A294196

use 5.014;
use Math::GMPz qw();
use Math::MPFR qw(MPFR_RNDZ);
use ntheory qw(forprimes factorial);

for my $n (2..100) {

    my $f = 0;

    forprimes {
        $f += log($_);
    } factorial($n)+1, factorial($n+1);

    say "floor($f) = ", int($f);
}

__END__
floor(2.70805020110221) = 2
floor(15.821901318467) = 15
floor(87.846705739409) = 87
floor(579.092934941327) = 579
floor(4276.65691765426) = 4276
floor(35103.7037849562) = 35103
floor(322168.829509598) = 322168
floor(3264471.9003149) = 3264471
floor(36285842.9959193) = 36285842
floor(439070392.951992) = 439070392
floor(5747983086.45772) = 5747983086

floor(2.70805020110221007) = 2
floor(15.8219013184670268) = 15
floor(87.8467057394090264) = 87
floor(579.092934941326837) = 579
floor(4276.65691765426939) = 4276
floor(35103.7037849562028) = 35103
floor(322168.82950959723) = 322168
floor(3264471.90031498688) = 3264471
floor(36285842.9959180593) = 36285842
floor(439070392.95186203) = 439070392
floor(5747983086.4605573) = 5747983086
