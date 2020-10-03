
#include <gmp.h>
#include <iostream>

using namespace std;

bool fermat_test(unsigned long long int num) {

    __uint128_t power = 2;
    __uint128_t result = 1;
    __uint128_t mod = num;

    unsigned long long int n = num-1;

    while (n)
    {
        if (n & 1)
            result = (result * power) % mod;
        power = (power * power) % mod;
        n >>= 1;
    }
    return (result == 1);
}

bool is_fermat_prime(unsigned long long int n) {
    return (fermat_test(n) == 1);
}

bool probprime(unsigned long long int k, mpz_t n) {
    mpz_set_ui(n, k);
    return mpz_probab_prime_p(n, 0);
}

bool is_chernick(int n,  unsigned long long int m, mpz_t z) {

    if (6*m + 1 < 9223372036854775807LL) {
        if (!is_fermat_prime((6*m + 1))) {
            return false;
        }
    }

    if (12*m + 1 < 9223372036854775807LL) {
        if (!is_fermat_prime((12*m + 1))) {
            return false;
        }
    }

    for (unsigned long long int i = 1; i <= n - 2; i++) {
        if ((1 << i) * 9 * m + 1 < 9223372036854775807LL) {
            if (!is_fermat_prime( ((1 << i) * 9 * m + 1))) {
                return false;
            }
        }
        else {
            break;
        }
    }

    if (!probprime(6 * m + 1, z)) {
        return false;
    }

    if (!probprime(12 * m + 1, z)) {
        return false;
    }

    for (unsigned long long int i = 1; i <= n - 2; i++) {
        if (!probprime((1 << i) * 9 * m + 1, z)) {
            return false;
        }
    }

    return true;
}

int main() {
    mpz_t z;
    mpz_inits(z, NULL);

    // k = 24237176657 (for n = 12)

    // when done, check the range from k = 38637176656 to 40237176657

    // m = 31023586121600        (for n = 11)
    // m = 3208386195840         (for n = 10)

    //~ Tested up to k = 25000000000
    //~ Tested up to k = 26000000000
    //~ Tested up to k = 27000000000

    //      ....

    //~ Tested up to k = 41000000000
    //~ Tested up to k = 41500000000
    //~ Tested up to k = 42000000000
    //~ Tested up to k = 42500000000
    //~ Tested up to k = 43000000000
    //~ Tested up to k = 46000000000
    //~ Tested up to k = 46500000000

    int n = 11;
    unsigned long long int multiplier = 5 * (1 << (n - 4));

    for (unsigned long long int k = 48474353315-1000000; k <= 48474353315; k++) {

        if (k % 500000000 == 0) {
            cout << "Tested up to k = " << (unsigned long long int)k << endl;
        }

        if (is_chernick(n, k * multiplier, z)) {
            cout << (unsigned long long int)(k * multiplier) << endl;
            break;
        }
    }

    return 0;
}
