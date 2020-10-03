
// a(n) is the least integer k such that the remainder of k modulo p is strictly increasing over the first n primes.
// https://oeis.org/A306582

// a(16) = 483815692
// a(17) = 483815692
// a(18) = 5037219688
// a(19) = 18517814158
// a(20) = 18517814158

#include <set>
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {

    long long int p = 73;
    long long int primes[20] = { 71, 67, 61, 59, 53, 47, 43, 41, 37, 31, 29, 23, 19, 17, 13, 11, 7, 5, 3, 2 };

    for (long long int k = 18517814158LL; ; ++k) {

        //cout << k << endl;

        auto max = k % p;
        bool ok = true;

        for (auto q : primes) {
            if (k % q < max) {
                max = k % q;
            }
            else {
                ok = false;
                break;
            }
        }

        if (ok) {
            cout << "Found\n";
            cout << k << "\n";
            break;
        }
    }
}
