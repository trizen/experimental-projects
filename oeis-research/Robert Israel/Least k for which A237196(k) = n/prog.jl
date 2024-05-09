#!/usr/bin/julia

# a(n) is the least k for which A237196(k) = n.
# https://oeis.org/A372648

# Known terms:
#   4, 10, 43, 1, 2, 26, 3, 28, 13, 2311675, 8396, 12918370, 37697697

import Nemo: is_prime,next_prime

const P = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

function a(n, pn)

    t = 1
    j = 1

    while true
        if (j != n)
            t *= P[j]
        end
        if (!is_prime(t+pn))
            if (j >= n)
                return j-1
            else
                return j
            end
        end
        j += 1
    end

    return -1
end

a(2311675, 37872221)   == 10 || println("error for n = 10")
a(8396, 86351)         == 11 || println("error for n = 11")
a(12918370, 235313357) == 12 || println("error for n = 12")
a(37697697, 729457511) == 13 || println("error for n = 13")

function compute()

    table = Dict{Int64,Bool}()

    k = 1
    p = 2

    while true
        v = a(k, p)
        if haskey(table, v)
            ## ok
        else
            table[v] = true
            println("a($v) = $k")
        end
        p = next_prime(p)
        k += 1
    end
end

compute()
