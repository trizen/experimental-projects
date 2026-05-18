
\\ Author: Daniel Suteu, 18 May 2026
\\ Number of k <= 2^(n-1) such that tau(k) = n
\\ https://oeis.org/A393179

\\ Generate unique permutations of a multi-set (array)
unique_perms(v) = {
    my(res = List());
    local backtrack;
    (backtrack = (items, current_perm, ~res_ref) ->
        if(#items == 0,
            listput(res_ref, current_perm);
            return;
        );
        for(i=1, #items,
            \\ Skip duplicate elements in the same level
            if(i > 1 && items[i] == items[i-1], next);
            my(new_items = vecextract(items, Str("^", i)));
            backtrack(new_items, concat(current_perm, [items[i]]), ~res_ref);
        );
    );
    backtrack(vecsort(v), [], ~res);
    return(Vec(res));
}

count_prime_signature_numbers(n, p_sig) = {
    my(k = #p_sig);
    if(k == 0, return(if(n >= 1, 1, 0)));
    if(n < 1, return(0));

    my(sum_e = vecsum(p_sig));
    if(sum_e > logint(n, 2), return(0));

    \\ Recursive generator implementation
    local generate;
    (generate = (m, lo_p, k_idx, P, rem_sum_e, j) ->
        my(local_count = 0);
        my(e = P[k_idx]);
        my(hi_p = sqrtnint(n \ m, rem_sum_e));

        if(lo_p > hi_p, return(0));

        if(k_idx == 1,
            return(primepi(hi_p) - j);
        );

        if(k_idx == 2,
            my(e2 = P[1]);
            forprime(p = lo_p, hi_p,
                my(t = m * p^e);
                my(u = sqrtnint(n \ t, e2));
                j++;
                local_count += primepi(u) - j;
            );
            return(local_count);
        );

        my(p = lo_p);
        while(p <= hi_p,
            my(t = m * p^e);
            my(r = nextprime(p + 1));
            j++;
            local_count += generate(t, r, k_idx - 1, P, rem_sum_e - e, j);
            p = r;
        );

        return(local_count);
    );

    my(count = 0);
    my(perms = unique_perms(p_sig));

    for(i=1, #perms,
        count += generate(1, 2, k, perms[i], sum_e, 0);
    );

    return(count);
}

multiplicative_partitions(n, max_value) = {
    my(res = List());
    my(D = divisors(n));
    my(divs = vector(#D - 1, i, D[i+1])); \\ remove divisor '1'

    local recurse;
    (recurse = (target, min_idx, path, ~res_ref) ->
        if(target == 1,
            listput(res_ref, path);
            return;
        );
        for(i = min_idx, #divs,
            my(d = divs[i]);
            \\ Prune branch if the divisor exceeds bounds
            if(d > target, break);
            if(d > max_value, break);

            if(target % d == 0,
                recurse(target \ d, i, concat(path, [d]), ~res_ref)
            );
        );
    );

    recurse(n, 1, [], ~res);
    return(Vec(res));
}

count_inverse_tau(upto, n) = {
    my(max_s = logint(upto, 2) + 1);
    my(parts = multiplicative_partitions(n, max_s));
    my(total_count = 0);

    for(i=1, #parts,
        my(sig = vector(#parts[i], j, parts[i][j] - 1));
        total_count += count_prime_signature_numbers(upto, sig);
    );

    return(total_count);
}

a(n) = count_inverse_tau(2^(n-1), n);
for(n=1, 60, print1(a(n), ", "));
