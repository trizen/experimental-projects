#!/usr/bin/perl
#!/usr/bin/ruby

# Daniel "Trizen" Șuteu
# Date: 10 July 2017
# https://github.com/trizen

# A collection of formulas for common mathematical constants.

include('/home/swampyx/Other/Programare/Modules/bacovia/lib/bacovia.sf')

const n = (ARGV ? Num(ARGV[0]) : 30)       # number of iterations

define ℯ = Num.e
define π = Num.pi
define γ = Num.Y
define C = Num.C

func display(r, t) {
    say "#{t}: #{r}"
}

#
## zeta(3)
#


# Formula due to Cezar Lupu and Derek Orr, involving zeta(2n)
#display( map(1..n, {|n|
#    zeta(2*n) / n / (2*n + 1) / 4**n
#}), π)

# Formula due to Cezar Lupu and Derek Orr, involving zeta(2n)
#display(sqrt(8 * (1/2 + map(1..n, {|n|
#    zeta(2*n) * (2*n - 1) / 4**n
#}))), π)

# Formula due to Cezar Lupu and Derek Orr, involving zeta(2n)
#display(sqrt(16 * map(1..n, {|n|
#    zeta(2*n) * n / 4**n
#})), π)

# Formula due to Cezar Lupu and Derek Orr, involving zeta(2n)
#display(sqrt(32/3 * map(1..n, {|n|
#    zeta(2*n) * n**2 / 4**n
#})), π)

# Formula due to Cezar Lupu and Derek Orr, involving zeta(2n)
#display(2*sqrt(2)*exp(map(1..n, {|n|
#    zeta(2*n) / n / 16**n
#})), π)

# Formula due to Cezar Lupu and Derek Orr, involving zeta(2n)
#display(sqrt(16 * (1/2 + map(1..n, {|n|
#    zeta(2*n) * (2*n - 1) / 16**n
#}))), π)

# Formula due to Cezar Lupu and Derek Orr, involving zeta(2n) (corrected by the author)
#display(cbrt(32 * (1 - map(1..n, {|n|
#    zeta(2*n) * (2*n - 1) * (2*n - 2) / 16**n
#}))), π)

# Formula due to Cezar Lupu and Derek Orr, involving zeta(2n)
#display(4 - (8 * map(1..n, {|n|
#    zeta(2*n) / 16**n
#})), π)


for n in (0..20) {

    var f = map(0..n, {|n|
        Fraction((-1)**n, (2*n + 1)**3)
    }).reduce('+')

    print(f.num, ', ')
}


__END__

# Based on Stirling's asymptotic formula for n!
#display((n!)**2 * exp(2*n) / n**(2*n + 1) / 2, π)

# Limit derived by the author from gamma(1/2).
#display(4 * 16**n * n * (n!)**4 / ((2*n + 1)!)**2, π)

# Limit derived by the author from gamma(1/2).
#display(4 * 2**(4*n - 1) * (n!)**4 / (2*n + 1) / ((2*n)!)**2, π)

# Limit derived by the author from gamma(1/2).
#display(2 * 4**n * (n!)**2 / ((2*n - 1)!!) / ((2*n + 1)!!), π)

# Limit derived by the author from gamma(1/2).
#display(4 * 16**n * (n!)**3 * ((n+1)!) / ((2*n + 1)!)**2, π)

# Limit derived by the author from gamma(1/2).
#display(16**n * (n!)**3 * ((n-1)!) / ((2*n)!)**2, π)

# Limit derived by the author from gamma(1/2).
#display(sqrt(16 * 256**n * n * ((n+1)!) * (n!)**7 / ((2*n + 1)!)**4), π)

# Limit derived by the author from gamma(1/2).
#display(sqrt(128 * 256**n * (n + 1)**4 * ((2 * n**2) + 2*n + 1) * (n!)**8 / ((2*n + 2)!)**4), π)

# Formula due to S. M. Abrarov and B. M. Quine.
# Described in their paper: "A reformulated series expansion of the arctangent function"
#display( map(1..n, {|n|
#    map(1..(2*n - 1), {|k|
#        (-1)**k / (2*n - 1) / (1 + (1**2 / 4))**(2*n - 1) * (1/2)**(4*n - 2*k - 1) * binomial(2*n - 1, 2*k - 1)
#    })
#}), π)

# Formula (re?)discovered by the author.
display(map(1..n, {|n|
    1 / n**2 / 2**n
}), π)

# Formula (re?)discovered by the author (equivalent with the above formula).
display(map(1..n, {|n|
    1 / n**2 / 2**(n-1)
}), π)

# The gamma function at 1/2, which is sqrt(π).
#display((exp(γ/2)/2 * prod(1..n, {|n|
#    (1 + 1/(2*n)) * exp(-1/(2*n))
#}))**(-2), π)

# Formula due to Abraham Sharp (1699)
display(map(0..^n, {|n|
    (-1)**n / 3**n / (2*n + 1)
}), π)

# Formula due to John Machin (1706)
#display(4*(4*map(0..^n, {|n|
#    (-1)**n / (2*n + 1) / 5**(2*n + 1)
#}) - map(0..^n, {|n|
#    (-1)**n / (2*n + 1) / 239**(2*n + 1)
#})), π)

# Formula due to Matsunaga Yoshisuke (1739)
display(map(0..^n, {|n|
    n!**2 / (2*n + 2)!
}), π)

# Formula due to Karl Heinrich Schellbach (1832)
display(map(0..^n, {|n|
    (-1)**n * (1/(2**(2*n + 1)) + 1/(3**(2*n + 1))) / (2*n + 1)
}), π)

# Formula due to Louis Comtet (1974)
display(map(1..n, {|n|
    1 / n**4 / binomial(2*n, n)
}), π)

# Formula due to Jonathan Borwein and Peter Borwein (1988)
#display(map(0..^n, {|n|
#    (-1)**n * (6*n)! * ((212175710912*sqrt(61) + 1657145277365) + (13773980892672*sqrt(61) + 107578229802750)*n) / n!**3 / ((3*n)!) / (5280 * (236674 + 30303*sqrt(61)))**(3*n + 3/2)
#}), π)

# Formula due to David Bailey, Peter Borwein and Simon Plouffe (1995)
display(map(0..^n, {|n|
    (4/(8*n + 1) - 2/(8*n + 4) - 1/(8*n + 5) - 1/(8*n + 6)) / 16**n
}), π)

# Formula due to Fabrice Bellard (1997)
display(map(0..^n, {|n|
    (-1)**n / 2**(10*n) * (-32/(4*n + 1) - 1/(4*n + 3) + 256/(10*n + 1) - 64/(10*n + 3) - 4/(10*n + 5) - 4/(10*n + 7) + 1/(10*n + 9))
}), π)

# Formula due to Fabrice Bellard (1997)
display(map(1..n, {|n|
    3 * (-(885673181 * n**5) + (3125347237 * n**4) - (2942969225 * n**3) + (1031962795 * n**2) - (196882274 * n) + 10996648) / binomial(7*n, 2*n) / 2**(n-1)
}), π)

# Formula due to Cetin Hakimoglu-Brown (2009)
display(map(0..^n, {|n|
    ((4*n)!)**2 * ((6*n)!) / 9**(n+1) / ((12*n)!) / ((2*n)!) * (127169/(12*n + 1) - 1070/(12*n + 5) - 131/(12*n + 7) + 2/(2*n + 11))
}), π)

# Formual due to Cetin Hakimoglu-Brown (2009)
display(map(0..^n, {|n|
    1 / binomial(8*n, 4*n) / 9**n * (5717/(8*n + 1) - 413/(8*n + 3) - 45/(8*n + 5) + 5/(8*n + 7))
}), π)

#
## exp(1)
#

say "\n=> exp(1)"

# Formula (re?)discovered by the author.
display(map(0..^n, {|n|
    ((2*n + 1)!!) / (2*n + 1)!
}), ℯ)

# Basic formula for `e`, due to Euler
display(map(0..^n, {|n|
    1/n!
}), ℯ)

# Definition of e
#display((1 + 1/n)**n, ℯ)

# Binomial expansion (1 + 1/n)^n
display(map(0..n, {|k|
    n! * n**(k-n) / (k!) / (n-k)!
}), ℯ)

# Limit_{n->Infinity} (n-1)^(-n) * (n+1)^n = exp(2)
#display(sqrt((n - 1)**(-n) * (n+1)**n), ℯ)

#
## Euler-Mascheroni constant
#

say "\n=> Euler-Mascheroni"

# Euler-Mascheroni constant, involving zeta(n)
#display(1 - map(2..(n+1), {|n|
#    (zeta(n) - 1) / n
#}), γ)

# Limit_{n->Infinity} zeta((n+1)/n) - n} = gamma
#display(zeta((n+1)/n) - n, γ)

# Series due to Euler (1731).
#display(map(2..(n+1), {|n|
#    (-1)**n * zeta(n) / n
#}),  γ)

# Original definition of the Euler-Mascheroni constant, due to Euler (1731)
#display(map(1..n, {|n|
#    1/n
#}) - log(n), γ)

# Original definition of the Euler-Mascheroni constant,
# with an additional correction term (re)discovered by the author.
display(map(1..n, {|n|
    1/n
}), γ)

# Original definition of the Euler-Mascheroni constant, with additional correction terms.
#display(map(1..n, {|n|
#    1/n
#}) - log(n) - 1/(2*n) + 1/(12 * n**2) - 1/(120 * n**4) + 1/(252 * n**6) - 1/(240 * n**8) +, γ)

# Formula due to Euler
display(map(1..n, {|k|
    -bernfrac(2*k) / (2*k) / n**(2*k)
}), γ)

# Formula derived by the author from the above formula of Euler
#display(map(1..n, {|k|
#    (-1)**k * 4 * sqrt(π*k) * (π * ℯ)**(-2*k) * k**(2*k) / (2*k) / n**(2*k)
#}), γ)

# Formula derived by the author from the above formula of Euler
#display( map(1..n, {|k|
#    (-1)**k * 2 / (2*π)**(2*k) * ((2*k)!) / (2*k) / n**(2*k)
#}), γ)

# Formula due to Euler in terms of log(2) and the odd zeta values
#display( map(1..n, {|n|
#    (1 - 1/(2*n + 1)) * (zeta(2*n + 1) - 1)
#}), γ)

# Formula due to Euler in terms of log(2) and the odd zeta values (VII)
#display(log(2) - map(1..n, {|n|
#    zeta(2*n + 1) / (2*n + 1) / 2**(2*n)
#}), γ)

# Formula due to Vacca (1910)
display(map(1..n, {|n|
    (-1)**n * ilog2(n) / n
}), γ)

#
## Catalan constant
#

say "\n=> Catalan constant"

#display(π/2 * (map(1..n, {|n|
#    zeta(2*n) / n / (2*n + 1) / 16**n
#}) - log(π/2) + 1), C)

# Formula from the paper "Fast multiprecision evaluation of series of rational numbers"
display(map(0..^n, {|n|
    1 / binomial(2*n, n) / (2*n + 1)**2
}), C)

#
## log(2)
#

say "\n=> log(2)"

# The log(2) constant involving zeta(2n)
#display(map(1..n, {|n|
#    (zeta(2*n) - 1) / n
#}), log(2))

# A geometric series for log(2)
display(map(1..n, {|n|
    1 / n / 2**n
}), log(2))

# Formula reformulated by the author based on the above formula.
display(map(0..^n, {|n|
    (n!) / (2*n + 2)!!
}), log(2))

# Formula reformulated by the author (equivalent with the above one)
display(map(0..^n, {|n|
    1 / (2*n + 2) / 2**n
}), log(2))

# Formula (re?)discovered by the author.
display(map(0..^n, {|n|
    1 / ((2*n + 1) * (2*n + 2))
}), log(2))

# Formula based on: log(x) = 2*Sum_{n>=0} ((x-1)/(x+1))^(2n+1)/(2n+1)
display(map(0..^n, {|n|
    (1 / 3)**(2*n + 1) / (2*n + 1)
}), log(2))

# Formula used by the MPFR library
display(map(0..^n, {|n|
    (-1)**n * n!**2 / 2**n / (2*n + 1)!
}), log(2))

# Formula from Wikipedia
display(map(0..^n, {|n|
    (-1)**n / (n+1) / (n+2)
}), log(2))

# Formula from Wikipedia
display(map(1..n, {|n|
    1 / n / (8 * n**2 - 2)
}), log(2))

# Formula from Wikipedia
display(map(1..n, {|n|
    (-1)**n / n / (4 * n**2 - 1)
}) + 1, log(2))

# Formula from Wikipedia
display(map(1..n, {|n|
    (-1)**n / (2*n) / (3*n - 1) / (3*n + 1)
}), log(2))

# Formula from Wikipedia
#display(map(2..(n+1), {|n|
#    (zeta(n) - 1) / 2**n
#}), log(2))

# Formula from Wikipedia
#display(map(1..n, {|n|
#    zeta(2*n) / 2**(2*n - 1) / (2*n + 1)
#}), log(2))

# Formula from Wikipedia
display(map(1..n, {|n|
    (3**(-n) + 4**(-n)) / n
}), log(2))

# Formula from Wikipedia
display(map(1..n, {|n|
    (1/(2*n) + 1/(4*n + 1) + 1/(8*n + 4) + 1/(16*n + 12)) / 16**n
}), log(2))

# Formula from Wikipedia
display(map(0..^n, {|n|
    14/(31**(2*n + 1) * (2*n + 1)) + 6/(161**(2*n + 1) * (2*n + 1)) + 10/(49**(2*n + 1) * (2*n + 1))
}), log(2))
