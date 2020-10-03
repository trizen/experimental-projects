#!/usr/bin/julia

# Numbers which when chopped into one, two or more parts, added and squared result in the same number
# https://oeis.org/A104113

# Generate terms of the sequence.

# See also:
#   https://projecteuler.net/problem=719

function isok(n::Int64, m::Int64)

    (m  < n) && return false
    (m == n) && return true

    t = 10
    while (t < m)
        q,r = divrem(m, t)
        if (r < n)
            if (isok(n - r, q))
                return true
            end
        end
        t *= 10
    end

    return false
end

for n in 0:10^8
    if isok(n, n*n)
        println(n*n)
    end
end
