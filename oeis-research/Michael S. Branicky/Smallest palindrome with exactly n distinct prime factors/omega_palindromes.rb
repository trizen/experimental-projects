#!/usr/bin/ruby

# Smallest palindrome with exactly n distinct prime factors.
# https://oeis.org/A335645

# Known terms:
#   1, 2, 6, 66, 858, 6006, 222222, 20522502, 244868442, 6172882716, 231645546132, 49795711759794, 2415957997595142, 495677121121776594, 22181673755737618122

# New term found:
#   a(15) = 5521159517777159511255     (took 3h, 40min, 22,564 ms.)

# New term found by Michael S. Branicky:
#   a(16) = 477552751050050157255774

# Lower-bounds:
#   a(17) > 7875626394231654969634815

require 'prime'

def iroot(n,k)
    (n**(1.0/k)).to_i
end

def f(m, p, j, a, b)

    lst = []
    s = iroot(b/m, j)

    (p..s).each do |q|

        q.prime? || next

        if (q == 5 && m%2 == 0)
            next
        end

        v = m*q
        while (v <= b)
            if (j == 1)
                if (v >= a && v.to_s.reverse == v.to_s)
                    print("Found upper-bound: ", v, "\n")
                    b = [b, v].min
                    lst << v
                end
            elsif (v*(q+1) <= b)
                lst += f(v, q+1, j-1, a, b)
            end
            v *= q
        end
    end

    return lst
end

def omega_palindromes(a, b, n)
    a = [a, Prime.first(n).reduce(:*)].max
    return f(1,2,n,a,b).sort
end

def a(n)
    if (n == 0)
        return 1
    end
    x = Prime.first(n).reduce(:*)
    y = 2*x
    while (true) do
        print("Sieving range: ", [x,y], "\n")
        v = omega_palindromes(x, y, n)
        if (v.size > 0)
            return v[0]
        end
        x = y+1
        y = 2*x
    end
end

(12..12).each {|n|
    p([n, a(n)])
}
