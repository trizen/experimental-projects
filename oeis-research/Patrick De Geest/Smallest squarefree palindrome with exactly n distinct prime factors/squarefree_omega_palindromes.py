#!/usr/bin/python

# Smallest squarefree palindrome with exactly n distinct prime factors.
# https://oeis.org/A046399

# Known terms:
#   1, 2, 6, 66, 858, 6006, 222222, 22444422, 244868442, 6434774346, 438024420834, 50146955964105, 2415957997595142, 495677121121776594, 22181673755737618122, 8789941164994611499878

# Corrected term:
#   a(15) = 5521159517777159511255

# New term found by Michael S. Branicky:
#   a(16) = 477552751050050157255774

# Lower-bounds:
#   a(17) > 63005011153853239757078527

# Install sympy for pypy3:
#   pip --python=/usr/bin/pypy3 install sympy

from sympy import primorial, primerange, integer_nthroot

def cond(n):
    s = str(n)
    return s == s[::-1]

def ceildiv(a, b):
    return -(a // -b)

def squarefree_omega_cond(A, B, n):
    A = max(A, primorial(n))
    def f(m, p, j):
        lst = []
        s = integer_nthroot(B//m, j)[0]+2
        if j == 1:
            for q in primerange(max(p, ceildiv(A, m)), s):
                if cond(m*q):
                    print("Found upper-bound: ", m*q)
                    lst.append(m*q)
        else:
            for q in primerange(p, s):
                if q == 5 and m%2 == 0:
                    continue
                lst += f(m*q, q+1, j-1)
        return lst

    return sorted(f(1, 2, n))

def a(n):
    if n == 0:
        return 1
    x = primorial(n)
    y = 2*x
    while True:
        print("Sieving range: ", [x,y]);
        v = squarefree_omega_cond(x, y, n)
        if len(v) > 0:
            return v[0]
        x = y+1
        y = 2*x

for n in range(15):
    print([n, a(n)])
