
// Compilation:
//  g++ -march=native -Ofast -lgmp prog.cpp -o prog

// Numbers n such that A007088(n) == 1 (mod n).
// https://oeis.org/A339567

// New terms found:
//  1839399055, 7786281065, 11231388063, 17251448809, 71050380625

#include <gmp.h>
#include <iostream>
//#include <bitset>

using namespace std;

typedef unsigned long long int u64;

int main() {

    char s[64];

    mpz_t z;
    mpz_inits(z, NULL);

    for (u64 n = 71050380625; n <= 1000000000000; n += 2) {

        mpz_set_ui(z, n);
        mpz_get_str(s, 2, z);
        mpz_set_str(z, s, 10);

        //std::string s = std::bitset< 64 >(n).to_string();
        //mpz_set_str(z, s.c_str(), 10);

        if (mpz_mod_ui(z, z, n) == 1) {
            cout << n << endl;
        }
    }
}
