#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# Date: 11 June 2019
# https://github.com/trizen

# Generate the smallest extended Chernick-Carmichael number with n prime factors.

# OEIS sequence:
#   https://oeis.org/A318646 -- The least Chernick's "universal form" Carmichael number with n prime factors.

# See also:
#   https://oeis.org/wiki/Carmichael_numbers
#   http://www.ams.org/journals/bull/1939-45-04/S0002-9904-1939-06953-X/home.html

using Primes

function primality_pretest(k::UInt64)

    if (
        (k %  3)==0 || (k %  5)==0 || (k %  7)==0 || (k % 11)==0 ||
        (k % 13)==0 || (k % 17)==0 || (k % 19)==0 || (k % 23)==0
    )
        return false;
    end

    return true
end

function gcd_test(k::UInt64)
    gcd(35224440615606707, k) == 1
end

function is_chernick(n::Int64, m::UInt64)

    t = 9*m

    if (!primality_pretest(6*m + 1))
        return false
    end

    if (!primality_pretest(12*m + 1))
        return false
    end

    for i in 1:n-2
        if (!primality_pretest((t << i) + 1))
            return false
        end
    end

    if (!gcd_test(6*m + 1))
        return false
    end

    if (!gcd_test(12*m + 1))
        return false
    end

    for i in 1:n-2
        if (!gcd_test((t << i) + 1))
            return false
        end
    end

    if (!isprime(6*m + 1))
        return false
    end

    if (!isprime(12*m + 1))
        return false
    end

    for i in 1:n-2
        if (!isprime((t << i) + 1))
            return false
        end
    end

    return true
end

function chernick_carmichael(n::Int64, m::UInt64)
    prod = big(1)

    prod *= 6*m + 1
    prod *= 12*m + 1

    for i in 1:n-2
        prod *= ((9*m)<<i) + 1
    end

    prod
end

function main()

    for n in 3:10

        multiplier = 1

        if (n > 4)
            multiplier = 1 << (n-4)
        end

        if (n > 5)
            multiplier *= 5
        end

        m = UInt64(multiplier)

        while true

            if (is_chernick(n, m))
                println("a(", n, ") = ", chernick_carmichael(n, m))
                break
            end

            m += multiplier
        end
    end
end

main()
