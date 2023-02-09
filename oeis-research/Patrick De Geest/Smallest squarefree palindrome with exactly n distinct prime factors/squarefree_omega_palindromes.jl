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

    F = function(m, p::Int64, j::Int64)

        lst = []
        s = round(Int64, fld(B, m)^(1/j))

        if (j == 1)
            q = nextprime(max(p, cld(A, m)))

            while (q <= s)
                v = m*q
                if (reverse(string(v)) == string(v))
                    println("Found upper-bound: ", v)
                    push!(lst, v)
                end
                q = nextprime(q+1)
            end
        else
            q = nextprime(p)

            while (q <= s)

                if (q == 5 && m%2 == 0)
                    q = nextprime(q+1)
                    continue
                end

                lst = vcat(lst, F(m*q, q+1, j-1))
                q = nextprime(q+1)
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
