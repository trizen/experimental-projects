#!/usr/bin/julia

# Let k = A000396(n) be the n-th perfect number, a(n) is the least number m such that k*d*m - 1 is prime for all of the proper divisors d of k so their product is a Lucas-Carmichael number.

# Lucas-Carmichael version of:
#   https://oeis.org/A319008

# Known terms:
#   1, 219, 10405375365

# Inspired by the PARI program by David A. Corneth from OEIS A372238.

# See also:
#   https://oeis.org/A372238/a372238.gp.txt

using Primes

const PERFECT_N = 496
const DIVISORS = [1, 2, 4, 8, 16, 31, 62, 124, 248]

function isrem(m::UInt128, p, n)
    return all(d -> (PERFECT_N*m*d-1) % p != 0, DIVISORS)
end

function remaindersmodp(p, n)
    filter(m -> isrem(m |> UInt128, p, n), 0:p-1)
end

function mulmod(a::UInt128, b::UInt128, m::Integer)

    # https://discourse.julialang.org/t/modular-multiplication-without-overflow/90421/4

    magic1 = (UInt128(0xFFFFFFFF) << 32)
    magic2 = UInt128(0x8000000000000000)

    if iszero(((a | b) & magic1))
        return (a * b) % m
    end

    d = zero(UInt128)
    mp2 = m >> 1

    if a >= m; a %= m; end
    if b >= m; b %= m; end

    for _ in 1:64
        (d > mp2) ? d = ((d << 1) - m) : d = (d << 1)
        if !iszero(a & magic2)
            d += b
        end
        if d >= m
            d -= m
        end
        a <<= 1
    end

    return d
end

function mulmod(a::Integer, b::Integer, m::Integer)
    sa, sb = UInt128.(unsigned.((a,b)))
    return mulmod(sa, sb, m)
end

function chinese(a1, m1, a2, m2)
    M = lcm(m1, m2)
    return [
         (mulmod(mulmod(a1, invmod(div(M, m1), m1), M), div(M, m1), M) +
          mulmod(mulmod(a2, invmod(div(M, m2), m2), M), div(M, m2), M)) % M, M
    ]
end

function remainders_for_primes(n, primes)

    res = [[0, 1]]

    for p in primes

        rems = remaindersmodp(p, n)

        if (length(rems) == 0)
            rems = [0]
        end

        nres = []
        for r in res
            a = r[1]
            m = r[2]
            for rem in rems
                push!(nres, chinese(a, m, rem, p))
            end
        end
        res = nres
    end

    res = map(x -> x[1], res)
    sort!(res)
    return res
end

function deltas(arr)
    prev = 0
    D = []
    for k in arr
        push!(D, k - prev)
        prev = k
    end
    return D
end

function generate(n)

    maxp = 11

    n >= 3 && (maxp = 19)
    n >= 4 && (maxp = 29)
    n >= 5 && (maxp = 37)

    P = primes(maxp)

    R = remainders_for_primes(n, P)
    D = deltas(R)
    s = prod(P)

    while (D[1] == 0)
        popfirst!(D)
    end

    push!(D, R[1] + s - R[length(R)])

    m      = R[1] |> UInt128
    D_len  = length(D)

    for j in 0:10^18

        if (all(d -> isprime(PERFECT_N*m*d-1), DIVISORS))
            return m |> Int128
        end

        if (j % 10^7 == 0 && j > 0)
            println("[$j] Searching for a($n) with m = $m")
        end

        m += D[(j % D_len) + 1]
    end
end

const n = 3
println(generate(n))
