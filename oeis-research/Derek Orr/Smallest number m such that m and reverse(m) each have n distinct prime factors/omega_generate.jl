#!/usr/bin/julia

# Smallest number m such that m and reverse(m) each have n distinct prime factors.
# https://oeis.org/A239696

# Known terms:
#   2, 6, 66, 858, 6006, 204204, 10444434, 208888680, 6172882716

# New terms (a(10)-a(..)):
#   231645546132, 49795711759794

using Primes

function big_prod(arr)
    r = 1
    for n in (arr)
        r *= n
    end
    return r
end

function omega_generate(A, B, n::Int64)

    A = max(A, big_prod(primes(prime(n))))

    F = function(m, p::Int64, j::Int64)

        lst = []
        q = nextprime(p)
        s = round(Int64, fld(B, m)^(1/j))

        while (q <= s)

            v = m*q

            while (v <= B)
                if (j == 1)
                    if (v >= A && length(factor(parse(Int64, reverse(string(v))))) == n)
                        println("Found upper-bound: ", v)
                        push!(lst, v)
                    end
                elseif (v*(q+1) <= B)
                    lst = vcat(lst, F(v, q+1, j-1))
                end
                v *= q
            end

            q = nextprime(q+1)
        end

        return lst
    end

    return sort(F(1,2,n))
end

function a(n::Int64)
    if (n == 0)
        return 1
    end
    x = big_prod(primes(prime(n)))
    y = 2*x
    while (true)
        println("Sieving range: ", [x,y]);
        v = omega_generate(x, y, n)
        if (length(v) > 0)
            return v[1]
        end
        x = y+1
        y = 2*x
    end
end

for n in 1:20
    println([n, a(n)])
end
