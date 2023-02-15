#!/usr/bin/julia

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

using Primes

function big_prod(arr)
    r = big"1"
    for n in (arr)
        r *= n
    end
    return r
end

function squarefree_omega_palindromes(A, B, n::Int64)

    A = max(A, big_prod(primes(prime(n))))

    F = function(m, lo::Int64, j::Int64)

        lst = []
        hi = round(Int64, fld(B, m)^(1/j))

        if (lo > hi)
            return lst
        end

        if (j == 1)

            lo = round(Int64, max(lo, cld(A, m)))

            if (lo > hi)
                return lst
            end

            for q in (primes(lo, hi))
                v = m*q
                s = string(v)
                if (reverse(s) == s)
                    println("Found upper-bound: ", v)
                    B = min(v, B)
                    push!(lst, v)
                end
            end
        else
            for q in (primes(lo, hi))

                if (q == 5 && iseven(m))
                    ## ok
                else
                    lst = vcat(lst, F(m*q, q+1, j-1))
                end
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
    x = big"63005011153853239757078527"
    y = 2*x
    while (true)
        println("Sieving range: ", [x,y]);
        v = squarefree_omega_palindromes(x, y, n)
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
