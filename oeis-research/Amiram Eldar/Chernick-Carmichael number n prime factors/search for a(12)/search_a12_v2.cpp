
// Compilation:
//  g++ -march=native -Ofast -lgmp search_a12_v2.cpp -o x

#include <gmp.h>
#include <iostream>

using namespace std;

typedef unsigned long long int u64;

static bool primality_pretest(u64 k) {

    if (!(k %  3) || !(k %  5) || !(k %  7) || !(k % 11) ||
        !(k % 13) || !(k % 17) || !(k % 19) || !(k % 23)
    ) {
        return false;
    }

    return true;
}

static bool probprime(u64 k, mpz_t n) {
    mpz_set_ui(n, k);
    return mpz_probab_prime_p(n, 0);
}

static bool is_chernick(int n, u64 m, mpz_t z) {

    u64 t = 9 * m;

    for (int i = 2; i <= n - 2; i++) {
        if (!primality_pretest((t << i) + 1)) {
            return false;
        }
    }

    if (!probprime(6 * m + 1, z)) {
        return false;
    }

    if (!probprime(12 * m + 1, z)) {
        return false;
    }

    if (!probprime(18 * m + 1, z)) {
        return false;
    }

    for (int i = 2; i <= n - 2; i++) {
        if (!probprime((t << i) + 1, z)) {
            return false;
        }
    }

    return true;
}

int main() {
    mpz_t z;
    mpz_inits(z, NULL);

    // k = 24237176657 (for n = 12)

    // when done, check the range from k = 38637176656 to 40237176657 (checked)

    // m = 31023586121600        (for n = 11)
    // m = 3208386195840         (for n = 10)

    //~ Tested up to k = 25000000000
    //~ Tested up to k = 26000000000
    //~ Tested up to k = 27000000000

    //      ....

    //~ Tested up to k = 5384481556571

    // For all n > 5, m is a multiple of 5.

    cout << is_chernick(10, 3208386195840, z) << endl;
    cout << is_chernick(11, 31023586121600, z) << endl;
    cout << is_chernick(11, 2138939853538560, z) << endl;

    cout << "\n";

    // sanity checks (all three must be 0)
    cout << is_chernick(11, 3208386195840, z) << endl;
    cout << is_chernick(12, 31023586121600, z) << endl;
    cout << is_chernick(12, 2138939853538560, z) << endl;

    cout << "\n";

    //~ u64 from = 6269000000000+1;
    //~ u64 from = 1;
    //~ u64 from = 3481312975;
    //u64 from = 145454545454545;
    //~ u64 from = 145466000000000;
    u64 from = 13046621432;

    int n = 12;
    int t = n - 5;

    u64 mul = (128*9*5*11);

    // Make sure we don't overflow
    cout << "Test: " << (from * mul * (1 << (n - 5)) * 9 * (1 << (n - 5)) + 1) << endl;
    cout << "Test: " << (((((from * mul) << t) * 9) << (n - 5)) + 1) << endl;

    // Make sure mpz works
    mpz_set_ui(z, (((((from * mul) << t) * 9) << (n - 5)) + 1));
    cout << "Tmpz: " << mpz_get_ui(z) << endl;
    cout << "\n";

    u64 multiplier = mul << t;

    // Maximum value of k is about  1563750000000 (n = 12)
    // Maximum value of k is about  3127500000000 (n = 11)
    // Maximum value of k is about  6255000000000 (n = 10)
    // Maximum value of k is about 12510000000000 (n =  9)

    for (u64 k = from ; ; k++) {
        //~ for (u64 k = 48474353315LL - 200000000; ; k++) {

        if (k % 1000000000LL == 0LL) {
            cout << "Tested up to k = " << k << " -- where largest p = " << (((multiplier * k * 7LL) << (n - 8)) + 1) << endl;
        }

        u64 m = k * multiplier;

        if (primality_pretest(6 * m + 1) && primality_pretest(12 * m + 1) && primality_pretest(18 * m + 1) && is_chernick(n-6, m, z)) {
            cout << "Found k = " << k << " and m = " << m << endl;
            //break;
        }
    }

    return 0;
}
