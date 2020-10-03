
#include <gmp.h>
#include <iostream>

using namespace std;

typedef unsigned long long int u64;

static const bool primality_pretest(u64 k) {

    if (!(k%3) || !(k%5) || !(k%7) || !(k%11) || !(k%13) || !(k%17) || !(k%19) || !(k%23)) {
        return (k <= 23);
    }

    return true;
}

static const bool probprime(u64 k, mpz_t n) {
    mpz_set_ui(n, k);
    return mpz_probab_prime_p(n, 0);
}

static const bool is_chernick( int n, u64 m, mpz_t z) {

    u64 t = (9 * m);

    for (int i = 2; i <= n-2; i++) {
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

    if (!probprime(18*m + 1, z)) {
        return false;
    }

    for (int i = 2; i <= n-2; i++) {
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

    //~ Tested up to k = 91000000000

    cout << is_chernick(10, 3208386195840LL, z) << endl;
    cout << is_chernick(11, 31023586121600LL, z) << endl;

    cout << "\n";

    cout << is_chernick(11, 3208386195840LL, z) << endl;
    cout << is_chernick(12, 31023586121600LL, z) << endl;

    cout << "\n";

    u64 from = 48474353315;

    int n = 11;
    int t = n-4;

    // Make sure we don't overflow
    cout << "Test: " << (from * 5 * (1<<(n-4)) * 9 * (1 << (n-2)) + 1) << endl;
    cout << "Test: " << (((((from * 5LL) << t) * 9) << (n-2)) + 1) << endl;

    // Make sure mpz works
    mpz_set_ui(z, (((((from * 5LL) << t) * 9) << (n-2)) + 1));
    cout << "Tmpz: " << mpz_get_ui(z) << endl;
    cout << "\n";

    u64 multiplier = 5*(1 << t);

    //~ for (u64 k = from; ; k++) {
    for (u64 k = from - 100000000; k <= 48474353315; k++) {

        if (k % 500000000LL == 0LL) {
            cout << "Tested up to k = " << k << endl;
        }

        u64 m = k * multiplier;

        if (primality_pretest(6*m + 1) && primality_pretest(12*m+1) && primality_pretest(18*m+1) && is_chernick(n, m, z)) {

            //~ if (m%5 != 0) {
                //~ cout << "Counter-example: " << m << endl;
                //~ break;
            //~ }

            //else {
                cout << "k = " << k << " and m = " << m << endl;
                break;
           // }
            //break;
        }
    }

    return 0;
}
