\\ Optimized solver
a(n) = {
  local(min_val = +oo);
  local(lo = vecprod(primes(n)));
  local(hi = 2*lo); \\ Initial range
  local(update=0);

  \\ Logic to solve m = q^2 - p^2 directly for a given m
  my(process_m(m) =
    \\ Since m = (q-p)(q+p), let d1 = q-p and d2 = q+p.
    \\ We find d1 such that d1*d2 = m and d1 < d2.
    fordiv(m, d1,
      if(d1^2 >= m, break);
      my(d2 = m / d1);

      \\ q-p and q+p must have the same parity (both even for q,p > 2)
      if((d2 - d1) % 2 != 0, next);

      my(p = (d2 - d1) / 2);
      my(q = (d2 + d1) / 2);

      if(p >= min_val, next); \\ Only check if p is a potential improvement
      if(!ispseudoprime(p), next);
      if(!ispseudoprime(q), next);

      \\ Verify q is the next prime after p
      if(nextprime(p + 1) == q,
        print("a(", n, ") <= ", p);
        min_val = p;
        update=1;
      );
    );
  );

  \\ Optimized generator: processes m immediately instead of building a list
  my(find_omega(A, B, k) =
    local(f);
    (f = (m, p, j) ->
      forprime(q = p, sqrtnint(B \ m, j),
        my(v = m * q);
        while(v <= B,
          if(j == 1,
            if(v >= A, process_m(v))
          ,
            if(v * (q + 1) <= B, f(v, q + 1, j - 1))
          );
          v *= q;
        );
      );
    );
    f(1, 2, k);
  );

  while(1,
    update=0;
    find_omega(lo, hi, n);

    \\ If a value was found in this range, return the minimum
    if(min_val < +oo && update == 0, return(min_val));

    lo = hi + 1;
    hi = 2 * lo;
  );
}
