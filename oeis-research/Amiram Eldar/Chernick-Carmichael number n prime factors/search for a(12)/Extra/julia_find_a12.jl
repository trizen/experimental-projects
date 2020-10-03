
using Primes

# The "Primes" module can be installed with the following two commands, typed in Julia's interactive mode:
#   using Pkg
#   Pkg.add("Primes")

function primality_pretest(k :: UInt64)

    if (
        (k %  3)==0 || (k %  5)==0 || (k %  7)==0 || (k % 11)==0 ||
        (k % 13)==0 || (k % 17)==0 || (k % 19)==0 || (k % 23)==0
    )
        return false;
    end

    return true;
end

function is_chernick(n::UInt64, m::UInt64)

    t = 9*m

    for i in 2:n-2
        if (!primality_pretest((t << i) + 1))
            return false;
        end
    end

    if (!isprime(6*m + 1))
        return false;
    end

    if (!isprime(12*m + 1))
        return false;
    end

    if (!isprime(18*m + 1))
        return false;
    end

    for i in 2:n-2
        if (!isprime((t << i) + 1))
            return false;
        end
    end

    return true;
end

function extra_checking(n::UInt64, m::UInt64)

    t = big(9)*m

    for i in 2:n-2
        if (!isprime((t << i) + 1))
            return false;
        end
    end

    return true;
end

function main()

    # sanity checks (all three must be true)
    println(is_chernick(UInt64(10), UInt64(3208386195840)));
    println(is_chernick(UInt64(11), UInt64(31023586121600)));
    println(is_chernick(UInt64(11), UInt64(2138939853538560)));

    print("\n");

    # sanity checks (all three must be false)
    println(is_chernick(UInt64(11), UInt64(3208386195840)));
    println(is_chernick(UInt64(12), UInt64(31023586121600)));
    println(is_chernick(UInt64(12), UInt64(2138939853538560)));

    print("\n");

    from = UInt64(6276000000000)+1;

    n = UInt64(12)
    t = UInt64(n-4)

    # Make sure we don't overflow
    println("Test: ", (from * 5 * (1 << (n - 4)) * 9 * (1 << (n - 5)) + 1));
    println("Test: ", (((((from * 5) << t) * 9) << (n - 5)) + 1));

    print("\n");

    multiplier = 5 << t;

    # Maximum value of k is about  1563750000000 (n = 12)
    # Maximum value of k is about  3127500000000 (n = 11)
    # Maximum value of k is about  6255000000000 (n = 10)
    # Maximum value of k is about 12510000000000 (n =  9)

    for k in from:12510000000000

        if (k % 1000000000 == 0)
            println("Tested up to k = ", k, " -- where largest p = ", (((((k * 5) << t) * 9) << (n - 5)) + 1));
        end

        m = k * multiplier;

        if (primality_pretest(6 * m + 1) && primality_pretest(12 * m + 1) && primality_pretest(18 * m + 1) && is_chernick(n-3, m))

            println(":: Candidate for k = ", k, " and m = ", m)

            if (extra_checking(n, m))
                println("\nFound a(12) for m = ", m, "\n");
                break
            end
        end
    end
end

main()
