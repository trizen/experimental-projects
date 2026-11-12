// Least Carmichael number with exactly n distinct prime factors, all 3 mod 4.
// Tested with GCC 13/14: g++ -O3 -march=native -std=c++20 carmichael_3mod4.cpp -o carmichael_3mod4
// Run: ./carmichael_3mod4 14

// a(14) = 103553044590361066454428218181
// a(15) = 20891743923413642298849094659031
// a(16) = 5812384771337633634105801467466841
// a(17) = 752567111346187811246229990677758051
// a(18) = 461989623348544171457304879927675763501
// a(19) = 185300067279433233269124874580422022903251

#include <bits/stdc++.h>
using namespace std;

using u64  = uint64_t;
using u128 = unsigned __int128;
using i128 = __int128;

static string to_string_u128(u128 x) {
    if (x == 0) return "0";
    string s;
    while (x) {
        s.push_back(char('0' + x % 10));
        x /= 10;
    }
    reverse(s.begin(), s.end());
    return s;
}

static u128 gcd128(u128 a, u128 b) {
    while (b) {
        u128 t = a % b;
        a = b;
        b = t;
    }
    return a;
}

static bool power_leq(u64 a, int e, u128 x) {
    u128 v = 1;
    for (int i = 0; i < e; ++i) {
        if (a && v > x / a) return false;
        v *= a;
    }
    return true;
}

// Exact floor(x^(1/e)); used for the PARI sqrtnint bound.
static u64 integer_root(u128 x, int e) {
    u64 lo = 1, hi = (1ULL << 63);
    while (lo < hi) {
        u64 mid = lo + (hi - lo + 1) / 2;
        if (power_leq(mid, e, x)) lo = mid;
        else hi = mid - 1;
    }
    return lo;
}

static u64 mul_mod(u64 a, u64 b, u64 mod) {
    return (u128)a * b % mod;
}

static u64 pow_mod(u64 a, u64 e, u64 mod) {
    u64 r = 1;
    while (e) {
        if (e & 1) r = mul_mod(r, a, mod);
        a = mul_mod(a, a, mod);
        e >>= 1;
    }
    return r;
}

// Deterministic Miller-Rabin for all 64-bit integers.
static bool is_prime64(u64 n) {
    if (n < 2) return false;
    for (u64 p : {2ULL, 3ULL, 5ULL, 7ULL, 11ULL, 13ULL,
                  17ULL, 19ULL, 23ULL, 29ULL, 31ULL, 37ULL}) {
        if (n % p == 0) return n == p;
    }

    u64 d = n - 1, s = 0;
    while ((d & 1) == 0) {
        d >>= 1;
        ++s;
    }

    for (u64 a : {2ULL, 325ULL, 9375ULL, 28178ULL,
                  450775ULL, 9780504ULL, 1795265022ULL}) {
        if (a % n == 0) continue;
        u64 x = pow_mod(a % n, d, n);
        if (x == 1 || x == n - 1) continue;

        bool composite = true;
        for (u64 r = 1; r < s; ++r) {
            x = mul_mod(x, x, n);
            if (x == n - 1) {
                composite = false;
                break;
            }
        }
        if (composite) return false;
    }
    return true;
}

// Inverse modulo m. In this search m < 2^127, so signed __int128 is enough
// for the extended-Euclidean coefficients.
static u128 inverse_mod(u128 a, u128 m) {
    i128 t = 0, new_t = 1;
    i128 r = (i128)m, new_r = (i128)(a % m);

    while (new_r != 0) {
        i128 q = r / new_r;
        i128 tmp = t - q * new_t;
        t = new_t;
        new_t = tmp;
        tmp = r - q * new_r;
        r = new_r;
        new_r = tmp;
    }

    if (r != 1) throw runtime_error("modular inverse does not exist");
    if (t < 0) t += (i128)m;
    return (u128)t;
}

// Brent-Pollard rho, for factoring the 64-bit forced-completion products.
static u64 pollard_rho64(u64 n) {
    if (n % 2 == 0) return 2;
    if (n % 3 == 0) return 3;

    static u64 seed = 0x9e3779b97f4a7c15ULL;
    auto random_u64 = [&]() {
        seed ^= seed << 7;
        seed ^= seed >> 9;
        return seed;
    };

    for (;;) {
        u64 y = random_u64() % (n - 1) + 1;
        u64 c = random_u64() % (n - 1) + 1;
        constexpr u64 batch = 128;
        u64 g = 1, r = 1, q = 1, x = 0, ys = 0;

        auto f = [&](u64 z) -> u64 {
            return (u64)(((u128)mul_mod(z, z, n) + c) % n);
        };

        while (g == 1) {
            x = y;
            for (u64 i = 0; i < r; ++i) y = f(y);

            u64 k = 0;
            while (k < r && g == 1) {
                ys = y;
                u64 count = min(batch, r - k);
                for (u64 i = 0; i < count; ++i) {
                    y = f(y);
                    u64 diff = (x > y) ? x - y : y - x;
                    q = mul_mod(q, diff, n);
                }
                g = gcd(q, n);
                k += count;
            }

            r <<= 1;
            if (r > (1ULL << 22)) break;
        }

        if (g == n) {
            do {
                ys = f(ys);
                u64 diff = (x > ys) ? x - ys : ys - x;
                g = gcd(diff, n);
            } while (g == 1);
        }
        if (g > 1 && g < n) return g;
    }
}

static void factor64(u64 n, vector<u64>& factors) {
    if (n == 1) return;
    if (is_prime64(n)) {
        factors.push_back(n);
        return;
    }
    u64 d = pollard_rho64(n);
    factor64(d, factors);
    factor64(n / d, factors);
}

static const vector<u64> SMALL_PRIMES = [] {
    vector<u64> v;
    for (u64 x = 2; x <= 1000; ++x) {
        bool prime = true;
        for (u64 p : v) {
            if (p * p > x) break;
            if (x % p == 0) {
                prime = false;
                break;
            }
        }
        if (prime) v.push_back(x);
    }
    return v;
}();

static vector<u64> primes_3mod4;
static u128 lower_bound_N, upper_bound_N, best_N;
static int target_n;
static unsigned long long visited_nodes, forced_nodes, terminal_nodes, factorizations;

// Verify that Q is a product of exactly rem distinct primes, all 3 mod 4
// and greater than the previous chosen prime. Then test Korselt's criterion
// using the lcm of every p_i-1.
static void test_forced_product(u128 m, u128 old_lcm, u64 Q,
                                int rem, u64 smallest_allowed) {
    if (Q == 0) return;

    ++factorizations;
    vector<u64> factors;
    factors.reserve(rem);
    u64 residual = Q;

    // Cheap trial division handles small factors before Pollard rho is needed.
    for (u64 p : SMALL_PRIMES) {
        if (p * p > residual) break;
        if (residual % p == 0) {
            if (p % 4 != 3 || p < smallest_allowed) return;
            residual /= p;
            if (residual % p == 0) return; // repeated prime factor
            factors.push_back(p);
            if ((int)factors.size() > rem) return;
        }
    }

    if (residual > 1) {
        vector<u64> tail;
        factor64(residual, tail);
        for (u64 p : tail) {
            if (p % 4 != 3 || p < smallest_allowed) return;
            factors.push_back(p);
            if ((int)factors.size() > rem) return;
        }
    }

    if ((int)factors.size() != rem) return;
    sort(factors.begin(), factors.end());
    for (int i = 1; i < rem; ++i)
        if (factors[i] == factors[i - 1]) return;

    u128 full_lcm = old_lcm;
    for (u64 p : factors) {
        u64 d = p - 1;
        u128 g = gcd128(full_lcm, d);
        u64 multiplier = d / (u64)g;
        if (full_lcm > (upper_bound_N - 1) / multiplier) return;
        full_lcm *= multiplier;
    }

    u128 N = m * Q;
    if (N < lower_bound_N || N > upper_bound_N) return;
    if ((N - 1) % full_lcm != 0) return;
    if (!best_N || N < best_N) best_N = N;
}

// For the remaining product Q, the old Korselt conditions require
//     m*Q == 1 (mod old_lcm).
// If only a small number of such Q fit in the interval, factor them directly
// instead of branching on the remaining primes one at a time.
static bool try_forced_completion(u128 m, u128 old_lcm, u64 smallest_allowed,
                                  int rem, u128 Qmin, u128 Qmax) {
    if (Qmax == 0 || old_lcm <= 1) return false;

    u128 from_A = (lower_bound_N + m - 1) / m;
    if (Qmin < from_A) Qmin = from_A;
    if (Qmin > Qmax) return true; // no completion lies in this interval

    // old_lcm has exactly one factor 2: every chosen p is 3 mod 4,
    // so p-1 is 2 mod 4. The product Q has a fixed residue modulo 4.
    u128 step = 2 * old_lcm;
    unsigned wanted_mod4 = (rem & 1) ? 3 : 1;
    u128 residue = inverse_mod(m % old_lcm, old_lcm);
    if (residue == 0) residue = old_lcm;
    if ((residue & 3) != wanted_mod4) residue += old_lcm;

    u128 first = residue;
    if (first < Qmin) {
        u128 delta = Qmin - first;
        u128 jumps = delta / step + (delta % step != 0);
        first += jumps * step;
    }
    if (first > Qmax) return true; // no Q in the required residue class

    u128 count = (Qmax - first) / step + 1;
    // Direct 64-bit factorization is used only when it is cheaper than DFS.
    if (Qmax > numeric_limits<u64>::max() || count > 24) return false;

    ++forced_nodes;
    for (u128 q = first; q <= Qmax;) {
        if (best_N && m * q >= best_N) break;
        test_forced_product(m, old_lcm, (u64)q, rem, smallest_allowed);
        if (step > Qmax - q) break;
        q += step;
    }
    return true; // every possible Q in this small residue class was examined
}

static void search_dfs(u128 m, u128 old_lcm, u64 smallest_allowed, int rem) {
    ++visited_nodes;

    if (rem == 1) {
        ++terminal_nodes;
        u128 pmax = upper_bound_N / m;
        if (pmax > m) pmax = m; // p-1 | m-1 implies p <= m.
        u128 pmin = (lower_bound_N + m - 1) / m;
        if (pmin < smallest_allowed) pmin = smallest_allowed;
        if (pmin > pmax) return;

        u128 residue = inverse_mod(m % old_lcm, old_lcm);
        if (residue == 0) residue = old_lcm;
        if ((residue & 3) != 3) residue += old_lcm;
        u128 step = 2 * old_lcm;
        if (residue < pmin) {
            u128 delta = pmin - residue;
            u128 jumps = delta / step + (delta % step != 0);
            residue += jumps * step;
        }
        if (residue > pmax) return;

        // p is at most sqrt(upper_bound_N), hence fits in uint64_t here.
        for (u128 pp = residue; pp <= pmax;) {
            if (best_N && m * pp >= best_N) break;
            u64 p = (u64)pp;
            // (m*p - 1) % (p - 1) == 0 iff (m - 1) % (p - 1) == 0.
            if ((m - 1) % (p - 1) == 0 && is_prime64(p)) {
                u128 N = m * p;
                if (N >= lower_bound_N && N <= upper_bound_N &&
                    (!best_N || N < best_N)) {
                    best_N = N;
                }
            }
            if (step > pmax - pp) break;
            pp += step;
        }
        return;
    }

    auto first_it = lower_bound(primes_3mod4.begin(), primes_3mod4.end(), smallest_allowed);

    // Minimum possible product of the rem remaining primes.
    u128 qmin = 1;
    auto suffix_it = first_it;
    for (int i = 0; i < rem; ++i, ++suffix_it) {
        if (suffix_it == primes_3mod4.end() || qmin > upper_bound_N / *suffix_it)
            return;
        qmin *= *suffix_it;
    }

    u128 qmax = upper_bound_N / m;
    if (qmin > qmax) return;

    // If old_lcm > qmax, the remaining product Q is uniquely determined
    // (Q is the least positive inverse residue, since 0 < Q < old_lcm).
    if (old_lcm > qmax && qmax <= numeric_limits<u64>::max()) {
        try_forced_completion(m, old_lcm, smallest_allowed, rem, qmin, qmax);
        return;
    }

    if (try_forced_completion(m, old_lcm, smallest_allowed, rem, qmin, qmax))
        return;

    u64 pmax = integer_root(qmax, rem);
    if (pmax < smallest_allowed) return;

    for (auto it = first_it; it != primes_3mod4.end() && *it <= pmax; ++it) {
        u64 p = *it;
        if (gcd128(m, p - 1) != 1) continue;

        u128 mp = m * p;
        u64 g = (u64)gcd128(old_lcm, p - 1);
        u64 multiplier = (p - 1) / g;
        if (old_lcm > (upper_bound_N - 1) / multiplier) continue;
        u128 new_lcm = old_lcm * multiplier;
        if (new_lcm >= upper_bound_N) continue;

        // Minimum completion after choosing p: use the next rem-1 primes.
        u128 min_completion = mp;
        auto next_it = it + 1;
        bool impossible = false;
        for (int i = 0; i < rem - 1; ++i, ++next_it) {
            if (next_it == primes_3mod4.end() ||
                min_completion > upper_bound_N / *next_it) {
                impossible = true;
                break;
            }
            min_completion *= *next_it;
        }
        if (impossible || min_completion > upper_bound_N) break;

        search_dfs(mp, new_lcm, p + 1, rem - 1);

        // Later p only increase the minimum possible completion.
        if (best_N && min_completion >= best_N) break;
    }
}

static vector<u64> sieve_primes_3mod4(u64 limit) {

    vector<uint8_t> composite(limit + 1, 0);
    for (u64 i = 2; i * i <= limit; ++i) {
        if (!composite[i]) {
            for (u64 j = i * i; j <= limit; j += i) composite[j] = 1;
        }
    }

    vector<u64> result;
    for (u64 p = 3; p <= limit; p += 4)
        if (!composite[p]) result.push_back(p);
    return result;
}

int main(int argc, char** argv) {
    target_n = (argc > 1) ? atoi(argv[1]) : 14;

    if (target_n < 3) {
        cerr << "Usage: " << argv[0] << " [n], with 3 <= n <= 14\n";
        return 2;
    }

    try {
        vector<u64> first_primes;
        for (u64 x = 3; (int)first_primes.size() < target_n; x += 2) {
            if (x % 4 == 3 && is_prime64(x)) first_primes.push_back(x);
        }

        // Every admissible number is at least the product of the first n
        // primes congruent to 3 mod 4.
        vector<u128> min_prefix(target_n + 1, 1);
        for (int i = 1; i <= target_n; ++i)
            min_prefix[i] = min_prefix[i - 1] * first_primes[i - 1];

        lower_bound_N = min_prefix[target_n];
        upper_bound_N = 2 * lower_bound_N;
        cerr << "minimum possible product = " << to_string_u128(lower_bound_N) << '\n';

        for (;;) {
            // Signed __int128 is used by extended Euclid, so keep bounds below 2^127.
            if (upper_bound_N >= ((u128)1 << 127)) {
                throw runtime_error("search range exceeded the signed 128-bit limit");
            }

            // Global upper bound for every non-terminal prime loop.
            u64 sieve_limit = max<u64>(3, first_primes.back());
            for (int d = 0; d <= target_n - 2; ++d) {
                int rem = target_n - d;
                sieve_limit = max(sieve_limit,
                                  integer_root(upper_bound_N / min_prefix[d], rem));
            }

            // Add target_n+2 more primes after sieve_limit. They are needed
            // to calculate the smallest possible suffix after a loop-bound prime.
            u64 sieve_max = sieve_limit;
            int extra = 0;
            u64 x = sieve_limit + 1;
            while ((x & 3) != 3) ++x;
            for (; extra < target_n + 2; x += 4) {
                if (is_prime64(x)) {
                    sieve_max = x;
                    ++extra;
                }
            }

            primes_3mod4 = sieve_primes_3mod4(sieve_max);
            best_N = 0;
            visited_nodes = forced_nodes = terminal_nodes = factorizations = 0;

            auto start = chrono::steady_clock::now();
            search_dfs(1, 1, 3, target_n);
            double elapsed = chrono::duration<double>(chrono::steady_clock::now() - start).count();

            cerr << "[" << to_string_u128(lower_bound_N) << ", "
                 << to_string_u128(upper_bound_N) << "]"
                 << " sieve=" << sieve_limit
                 << " nodes=" << visited_nodes
                 << " forced=" << forced_nodes
                 << " factorizations=" << factorizations
                 << " terminal=" << terminal_nodes
                 << " time=" << fixed << setprecision(3) << elapsed << " s";

            if (best_N) {
                cerr << " FOUND " << to_string_u128(best_N) << '\n';
                cout << to_string_u128(best_N) << '\n';
                return 0;
            }
            cerr << " none\n";

            // The intervals are contiguous and disjoint, so the first interval
            // containing a solution contains the global minimum.
            lower_bound_N = upper_bound_N + 1;
            upper_bound_N *= 2;
        }
    } catch (const exception& e) {
        cerr << "Error: " << e.what() << '\n';
        return 1;
    }
}
