#!/usr/bin/julia

# Number of primitive abundant numbers (A071395) < 10^n.
# https://oeis.org/A306986

# Known terms:
#   0, 3, 14, 98, 441, 1734, 8667, 41653, 213087, 1123424

using Primes

function divisor_sum(n)

    sigma = 1
    for (p,e) in factor(n)
        s = 1
        q = p
        for j in 1:e
            s += q^j
        end
        sigma *= s
    end

    return sigma
end

function f(n, q, limit)

    # ~ if (rem(n,6) == 0 || rem(n, 28) == 0 || rem(n, 496) == 0 || rem(n, 8128) == 0)
        # ~ return 0
    # ~ end

    count = 0

    p = q
    while true

        t = n*p
        (t >= limit) && break

        ds = divisor_sum(t)

        if (ds > 2*t)
            ok = true
            for (p,e) in factor(t)
                w = div(t,p)
                if (divisor_sum(w) >= 2*w)
                    ok = false
                    break
                end
            end
            if ok
                count += 1
            end
        elseif (ds < 2*t)
            count += f(t, p, limit)
        end

        p = nextprime(p+1)
    end

    return count
end

println(f(1, 2, 10^4))
println(f(1, 2, 10^5))
println(f(1, 2, 10^6))

println(f(1, 2, 10^11))
