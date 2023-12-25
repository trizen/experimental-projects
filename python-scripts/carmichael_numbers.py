#!/usr/bin/python

from sympy.ntheory import sieve, isprime, prime
from sympy.core import integer_nthroot
from math import lcm, gcd, isqrt

def carmichael(A, B, n):
    max_p = 1+((1 + isqrt(8*B + 1)) >> 2)

    def f(m, l, lo, k):

        if k == 1:

            lo = max(lo, A // m + (1 if A % m else 0))
            hi = min(B // m + 1, max_p)

            u = pow(m, -1, l)
            while u < lo: u += l
            if u > hi: return

            for p in range(u, hi, l):
                if (m*p - 1) % (p - 1) == 0 and isprime(p):
                    yield m*p

        else:
            hi = (integer_nthroot(B // m, k))[0]+1
            for p in sieve.primerange(lo, hi):
                if gcd(m, p-1) == 1:
                    yield from f(m*p, lcm(l, p-1), p + 2, k - 1)

    return sorted(f(1, 1, 3, n))

def carmichael_with_n_primes(n):
    x = 2
    y = 2*x
    while True:
        C = carmichael(x, y, n)
        if len(C) >= 1: return C[0]
        x = y+1
        y = 2*x

def carmichael_count(A, B):
    k = 3
    l = 3*5*7
    count = 0
    while l < B:
        count += len(carmichael(A, B, k))
        k += 1
        l *= prime(k+1)
    return count

print("Least Carmichael number with n prime factors:")

for n in range(3, 12+1):
    print("%2d: %d" % (n, carmichael_with_n_primes(n)))

print("\nNumber of Carmichael numbers less than 10^n:")

for n in range(1, 10+1):
    print("%2d: %d" % (n, carmichael_count(1, 10**n)))
