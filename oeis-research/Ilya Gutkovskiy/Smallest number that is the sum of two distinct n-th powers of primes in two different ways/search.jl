#!/usr/bin/julia

# Smallest number that is the sum of two distinct n-th powers of primes in two different ways.
# https://oeis.org/A338800

# Smallest number that is the sum of two n-th powers of primes in two different ways.
# https://oeis.org/A338799

# Known terms for A338800:
#   16, 410, 6058655748, 3262811042

# Currently, no upper-bound for a(5) is known, assuming that a(5) exists.

using Primes

function search()

    a = 2
    upto1 = 10000
    upto2 = 50000
    k = 5

    table = Dict{BigInt, Int64}()

    while (a <= upto1)

        u = big(a)^k
        #b = nextprime(a+1)
        b = a

        while (b <= upto2)

            key = u + big(b)^k

            if (haskey(table, key))
                println(a, " ", b, " -> ", key)
                table[key] += 1
            else
                table[key] = 1
            end

            b = nextprime(b+1)
        end
        a = nextprime(a+1)
    end

    #~ for (k,v) in (table)
        #~ if (v >= 2)
            #~ println(k)
        #~ end
    #~ end

    return 0
end

search()
