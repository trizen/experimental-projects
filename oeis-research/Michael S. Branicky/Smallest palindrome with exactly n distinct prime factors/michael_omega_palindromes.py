#!/usr/bin/python

# Python program for OEIS A335645
# Translation of Daniel Suteu's PARI
# by Michael S. Branicky, Feb 06 2023

# Install sympy for pypy3:
#   pip --python=/usr/bin/pypy3 install sympy

# Timings with pypy3:
# 10 231645546132 77 2.6759650707244873
# 11 49795711759794 93 5.6582934856414795
# 12 2415957997595142 111 11.3309805393219
# 13 495677121121776594 131 52.19296479225159
# 14 22181673755737618122 153 135.02077960968018

# A335645       Smallest palindrome with exactly n distinct prime factors.
data = [1, 2, 6, 66, 858, 6006, 222222, 20522502, 244868442, 6172882716, 231645546132, 49795711759794, 2415957997595142, 495677121121776594, 22181673755737618122, 5521159517777159511255]

from sympy import primorial, primerange, integer_nthroot

def cond(n):
    s = str(n)
    return s == s[::-1]

def omega_cond(A, B, n):
    A = max(A, primorial(n))
    def f(m, p, j):
        lst = []
        for q in primerange(p, integer_nthroot(B//m, j)[0]+2):
            v =  m*q
            if q == 5 and v%2 == 0:
                continue
            while v <= B:
                if j == 1:
                    if v >= A and cond(v):
                        lst.append(v)
                elif v*(q+1) <= B:
                    lst += f(v, q+1, j-1)
                v *= q
        return lst
    return sorted(f(1, 2, n))

def a(n):
    if n == 0:
        return 1
    x = primorial(n)
    y = 2*x
    while True:
        v = omega_cond(x, y, n)
        if len(v) > 0:
            return v[0]
        x = y+1
        y = 2*x

print([a(n) for n in range(0, 12)])

from time import time
time0 = time()

alst = []
for n in range(20):
    an = a(n)
    alst.append(an)
    print(n, an, len(str(alst))-2, time()-time0)
    print("   ", alst)
    print("   ", data)
