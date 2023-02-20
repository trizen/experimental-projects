#!/usr/bin/julia

# Smallest base-2 even pseudoprime (A006935) with exactly n prime factors, or 0 if no such number exists.
# https://oeis.org/A270973

# Known terms:
#   161038, 215326, 209665666, 4783964626, 1656670046626, 1202870727916606

# New terms:
#   a(9)  = 52034993731418446
#   a(10) = 1944276680165220226
#   a(11) = 1877970990972707747326

using Primes

function divisors(n)

    d = Int64[1]

    for (p,e) in factor(n)
        t = Int64[]
        r = 1

        for i in 1:e
            r *= p
            for u in d
                push!(t, u*r)
            end
        end

        append!(d, t)
    end

    sort!(d)
    return d
end

function prime_znorder(a, n)
    for d in divisors(n-1)
        if (powermod(a, d, n) == 1)
            return d
        end
    end
end

function big_prod(arr)
    r = big"1"
    for n in (arr)
        r *= n
    end
    return r
end

function squarefree_fermat_pseudoprimes_in_range(A, B, k, base, callback)

    A = max(A, big_prod(primes(prime(k))))

    F = function(m, L, lo::Int64, k::Int64)

        hi = round(Int64, fld(B, m)^(1/k))

        if (lo > hi)
            return nothing
        end

        if (k == 1)

            lo = round(Int64, max(lo, cld(A, m)))

            if (lo > hi)
                return nothing
            end

            for p in primes(lo, hi)
                t = m*p
                if ((t-1) % L == 0 && (t-1) % prime_znorder(base, p) == 0)
                    println("Found upper-bound: ", t)
                    if (t < B)
                        B = t
                    end
                    callback(t)
                end
            end

            return nothing
        end

        for p in primes(lo, hi)

            if (base % p != 0)

                t = lcm(L, prime_znorder(base, p))

                if (gcd(t, m) == 1)
                    F(m*p, t, p+1, k-1)
                end
            end
        end
    end

    F(big"2", 1, 3, k-1)
end

function a(n::Int64)
    if (n == 0)
        return 1
    end
    #x = big_prod(primes(prime(n)))
    x = big"2095835631761410005771849"
    y = 2*x
    while (true)
        println("Sieving range: ", [x,y]);
        v = []
        squarefree_fermat_pseudoprimes_in_range(x, y, n, 2, function (t) push!(v, t) end)
        v = sort!(v)
        if (length(v) > 0)
            return v[1]
        end
        x = y+1
        y = 2*x
    end
end

for n in 12:12
    println([n, a(n)])
end
