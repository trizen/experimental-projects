#!/usr/bin/perl

# a(n) is the least number k such that A048105(k) = A048105(k+1) = 2*n, and 0 if it does not exist.
# https://oeis.org/A344315

# Known terms:
#   1, 27, 135, 2511, 2295, 6975, 5264, 12393728, 12375, 2200933376, 108224, 257499, 170624

# The sequence continues with ?, 4402431, ?, 126224, 41680575, 701443071, 46977524, 1245375, 2707370000, 4388175, 3129761024, 1890944. a(13) and a(15) > 4*10^10, if they exist. (Amiram Eldar)

# Upper-bounds:
#   a(13) <= 3684603215871
#   a(15) <= 2035980763136
#   a(25) <= 1965640805422351777791
#   a(26) <= 1350757416697856

# Some larger upper-bounds:
#   a(13) <= 23742854217728
#   a(26) <= 6085737708051120128
#   a(26) <= 176974592054955188682752

# a(13) and a(15) were confirmed by Martin Ehrenstein (May 20 2021).

# In general, a(n) <= A215199(n+1). Proof: tau(p*q^n) = (1+1)*(n+1), 2^omega(p*q^n) = 2^2, tau(p*q^n) - 2^omega(p*q^n) = 2*(n-1).

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

sub nu($n) {
    divisors($n) - (1 << prime_omega($n));
}

sub a($n) {
    for (my $k = 1; ; ++$k) {
        if (nu($k) == 2*$n and 2*$n == nu($k+1)) {
            return $k;
        }
    }
}

my $n = 25;
my $v = $n+1;

my $pow = powint(2, $v);

forprimes {

    my $k = mulint($_,  $pow);

    if (nu($k) == 2*$n and 2*$n == nu($k+1)) {
        die "Found: $k";
    }

    #~ if (nu($k) == 2*$n and 2*$n == nu($k-1)) {
        #~ die "Found: ", $k-1;
    #~ }

} 3, 1e10;


__END__

# Pari program 1
A048105(n) = numdiv(n) - 2^omega(n);
isok(n,k) = A048105(k) == 2*n && A048105(k+1) == 2*n;
a(n) = for(k=1, oo, if(isok(n, k), return(k)));

# Pari program 2
A048105(n)=my(f=factor(n)[, 2]); prod(i=1, #f, f[i]+1)-2^#f;
isok(n,k) = A048105(k) == 2*n && A048105(k+1) == 2*n;
a(n) = for(k=1, oo, if(isok(n, k), return(k)));
