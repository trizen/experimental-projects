#!/usr/bin/julia

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

using Primes

function big_prod(arr)
    r = big"1"
    for n in (arr)
        r *= n
    end
    return r
end

function omega_palindromes(A, B, n::Int64)

    A = max(A, big_prod(primes(prime(n))))

    F = function(m, lo::Int64, j::Int64)

        lst = []
        hi = round(Int64, fld(B, m)^(1/j))

        if (lo > hi)
            return lst
        end

        for q in (primes(lo, hi))

            if (q == 5 && iseven(m))
                continue
            end

            v = m*q

            while (v <= B)
                if (j == 1)
                    if (v >= A)
                        s = string(v)
                        if (reverse(s) == s)
                            println("Found upper-bound: ", v)
                            B = min(v, B)
                            push!(lst, v)
                        end
                    end
                elseif (v*(q+1) <= B)
                    lst = vcat(lst, F(v, q+1, j-1))
                end
                v *= q
            end
        end

        return lst
    end

    return sort(F(big"1",2,n))
end

function a(n::Int64)
    if (n == 0)
        return 1
    end
    #x = big_prod(primes(prime(n)))
    x = big"7875626394231654969634815"
    y = 2*x
    while (true)
        println("Sieving range: ", [x,y]);
        v = omega_palindromes(x, y, n)
        if (length(v) > 0)
            return v[1]
        end
        x = y+1
        y = 2*x
    end
end

for n in 17:17
    println([n, a(n)])
end
