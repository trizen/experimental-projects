
// Compilation:
//  g++ -Ofast -march=native --std=c++23 -lgmp lucas-carm-a4.cpp -o prog

#include <gmp.h>
#include <iostream>
#include <fstream>
#include <vector>

using namespace std;

typedef unsigned long long int u64;

const u64 small_primes[] = {31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97};
const u64 divisors[] = {1, 2, 4, 8, 16, 32, 64, 127, 254, 508, 1016, 2032, 4064};
const u64 perfect_n = 8128;

mpz_t z;

static bool isok(u64 m) {

    u64 t1 = (m * perfect_n - 1);

    for (auto p : small_primes) {
        if (t1 % p == 0) {
            return false;
        }
    }

    for (auto d : divisors) {

        if (d == 1) {
            continue;
        }

        mpz_set_ui(z, d * perfect_n);
        mpz_mul_ui(z, z, m);
        mpz_sub_ui(z, z, 1);

        for (auto v : small_primes) {
            if (mpz_divisible_ui_p(z, v)) {
                return false;
            }
        }
    }

    for (auto d : divisors) {

        mpz_set_ui(z, d * perfect_n);
        mpz_mul_ui(z, z, m);
        mpz_sub_ui(z, z, 1);

        if (!mpz_probab_prime_p(z, 0)) {
            return false;
        }

        if (d >= 127) {
            cout << "Almost: " << m << endl;
        }
    }

    return true;
}

int main() {

    mpz_inits(z, NULL);
    vector<u64> deltas;
    ifstream in("deltas.txt", ios::in);

    u64 number;
    while (in >> number) {
        deltas.push_back(number);
    }

    in.close();

    int n = 4;
    u64 j = 449540000000;
    u64 m = 1476397972931805;

    // [230550000000] Searching for a(4) with m = 757181902797855
    // [251170000000] Searching for a(4) with m = 824902965002625
    // [267910000000] Searching for a(4) with m = 879881169217350
    // [291790000000] Searching for a(4) with m = 958308859164690
    // [297030000000] Searching for a(4) with m = 975518285037285
    // [333500000000] Searching for a(4) with m = 1095294576463230
    // [350340000000] Searching for a(4) with m = 1150601205206115
    // [389470000000] Searching for a(4) with m = 1279113579606870
    // [421640000000] Searching for a(4) with m = 1384767631945815
    // [449540000000] Searching for a(4) with m = 1476397972931805

    u64 d_len  = deltas.size();

    cout << "Deltas count: " << d_len << endl;

    for (; ; ++j) {

        if (isok(m)) {
            cout << "Found term: " << m << endl;
            return 0;
        }

        if (j % 10000000 == 0) {
            cout <<  "[" << j << "] Searching for a(" << n << ") with m = " << m << endl;
        }

        m += deltas[j % d_len];
    }

    return 0;
}

/*

[267910000000] Searching for a(4) with m = 879881169217350
^C
./prog  16350.10s user 14.18s system 97% cpu 4:39:55.87 total

[338720000000] Searching for a(4) with m = 1112438317539615
^C
./prog  31071.15s user 43.78s system 96% cpu 8:59:57.51 total

[350340000000] Searching for a(4) with m = 1150601205206115
^C
./prog  6231.55s user 10.03s system 96% cpu 1:47:57.61 total

[421640000000] Searching for a(4) with m = 1384767631945815
^C
./prog  38925.48s user 33.57s system 98% cpu 11:02:26.52 total

[449540000000] Searching for a(4) with m = 1476397972931805
^C
./prog  15259.69s user 11.43s system 97% cpu 4:19:48.07 total
 %

*/
