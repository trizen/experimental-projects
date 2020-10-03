
// a(n) is the least integer k > 2 such that the remainder of -k modulo p is strictly increasing over the first n primes.
// https://oeis.org/A306612

// a(16) = 118867612
// a(17) = 4968215191
// a(18) = 31090893772
// a(19) = 118903377091

#include <set>
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {

    long long int p = 71;
    long long int primes[19] = {67, 61, 59,  53, 47, 43, 41, 37, 31, 29, 23, 19, 17, 13, 11, 7, 5, 3, 2};

    for (  long long int k = 118903377091LL; ; ++k) {

        //cout << k << endl;

        auto max = (-k) % p;

        //cout << max << " -- " << max + p << endl;

        if (max < 0) {
            max += p;
        }

        bool ok = true;

        //cout << max << endl;

        for (auto q : primes) {
            auto t = (-k) % q;

            if (t < 0) {
                t += q;
            }

            if (t < max) {
                max = t;
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
