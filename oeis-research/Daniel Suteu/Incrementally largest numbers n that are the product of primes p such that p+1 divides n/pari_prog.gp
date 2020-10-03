b(n) = my(d=divisors(n)); prod(k=1, #d, if(ispseudoprime(d[k]-1), d[k]-1, 1));
lista(n) = { my(m=0); for(k=1, n, my(d=b(2*k)); if(d>m, m=d; print(d))); }
lista(10^8);
