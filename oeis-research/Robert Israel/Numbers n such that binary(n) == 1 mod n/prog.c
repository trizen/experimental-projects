
// Compilation:
//  gcc -march=native -Ofast -lgmp prog.c -o prog

// Numbers n such that A007088(n) == 1 (mod n).
// https://oeis.org/A339567

#include <gmp.h>
#include <stdio.h>
#include <math.h>

typedef unsigned long long int u64;

char *int2bits(u64 answer, char *result) {
    if (answer > 1) {
        result = int2bits(answer >> 1, result);
    }
    *result = '0' + (answer & 0x01);
    return result + 1;
}

int main(int argc, char *argv[]) {

    char s[64];

    mpz_t z;
    mpz_inits(z, NULL);

    for (u64 n = 71050380625; n <= 1000000000000; n += 2) {

        *int2bits(n, s) = '\0';
        mpz_set_str(z, s, 10);

        if (mpz_mod_ui(z, z, n) == 1) {
            printf("%lld\n", n);
        }
    }
}
