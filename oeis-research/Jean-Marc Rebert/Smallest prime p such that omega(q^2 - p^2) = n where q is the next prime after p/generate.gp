\\ Helper function to generate numbers with exactly k-prime factors
omega_numbers(A, B, n) = {
  A = max(A, vecprod(primes(n)));
  local(f);
  (f = (m, p, j) ->
    my(list = List());
    forprime(q = p, sqrtnint(B\m, j),
      my(v = m * q);
      while(v <= B,
        if(j == 1,
          if(v >= A, listput(list, v))
        ,
          if(v * (q + 1) <= B, list = concat(list, f(v, q + 1, j - 1)))
        );
        v *= q;
      );
    );
    list;
  );
  vecsort(Vec(f(1, 2, n)));
};

\\ Main function
a(n) = {
  my(min_val = +oo);
  my(lo = 1);
  my(hi = 2 * lo);

  while (1,
    my(update = 0);
    my(m_list = omega_numbers(lo, hi, n));

    for (i = 1, #m_list,
      my(m = m_list[i]);
      my(p_aprox = (m - 4) \ 4);

      \\ Guard against log(0) or negative values
      if (p_aprox > 0,
        my(max_gap = ceil(log(p_aprox)^2));

        forstep (gap = 2, max_gap, 2,
          my(p = m - gap^2);
          if (p % (2 * gap) != 0, next);

          p = p \ (2 * gap);
          if (p >= min_val, next);
          if (!isprime(p), next);

          \\ q represents the next prime strictly greater than p
          my(q = nextprime(p + 1));
          if (q - p != gap, next);

          if (q^2 - p^2 == m,
            print("a(", n, ") <= ", p);
            min_val = p;
            update++;
          );
        );
      );
    );

    if (min_val < +oo && update == 0,
      return(min_val);
    );

    lo = hi + 1;
    hi = 2 * lo;
  );
};
