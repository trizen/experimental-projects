
\\ PARI/GP program for efficiently computing terms of the following OEIS sequences:
\\     https://oeis.org/A082997
\\     https://oeis.org/A082998

\\ Execute as: gp -f prog.gp

\\ Author: Daniel Suteu, Jul 21 2021

omega_prime_count(n, k = 2, m = 1, p = 2, s = sqrtnint(n\m, k), j = 1) = {

    my(count = 0);

    if (k==2,
        while(p <= s,
            my(r = nextprime(p+1)); my(t = m*p);
            while (t <= n,
                my(w = n\t); if(r > w, break); count += primepi(w) - j; my(r2 = r);
                while(r2 <= w,
                    my(u = t*r2*r2); if(u > n, break);
                    while (u <= n, count += 1; u *= r2);
                    r2 = nextprime(r2+1)
                );
                t *= p
            );
            p = r; j += 1
        );
        return(count)
    );

    while(p <= s, my(r = nextprime(p+1)); my(t = m*p);
        while(t <= n,
            my(s = sqrtnint(n\t, k-1));
            if(r > s, break);
            count += omega_prime_count(n, k-1, t, r, s, j+1); t *= p
        );
        p = r; j += 1
    );

    count;
};

print("A082997: ", vector(100, n, omega_prime_count(n, 2)))
print("A082998: ", vector(100, n, omega_prime_count(n, 3)))
