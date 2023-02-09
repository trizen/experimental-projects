#!/usr/bin/julia

# Smallest squarefree palindrome with exactly n distinct palindromic prime factors.

# See also:
#   http://www.worldofnumbers.com/assign3.htm
#   https://oeis.org/A046379

# Known terms:
#   1, 2, 6, 66, 6666, 334826628433, 15710977901751, 329443151344923

# It took 5min, 39,015 ms to find a(5).
# It took 5min, 27,260 ms to find a(6).
# It took 3min, 57,612 ms to find a(7).

using Primes

function big_prod(arr)
    #r = big"1"
    r = 1
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

                if (reverse(string(q)) != string(q))
                    q = nextprime(q+1)
                    continue
                end

                if (q == 5 && m%2 == 0)
                    q = nextprime(q+1)
                    continue
                end

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

                if (reverse(string(q)) != string(q))
                    q = nextprime(q+1)
                    continue
                end

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

    #return sort(F(big"1",2,n))
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
        v = squarefree_omega_palindromes(x, y, n)
        if (length(v) > 0)
            return v[1]
        end
        x = y+1
        y = 2*x
    end
end

for n in 1:17
    println([n, a(n)])
end
