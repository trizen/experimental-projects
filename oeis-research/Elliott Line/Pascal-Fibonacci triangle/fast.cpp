/*
    Daniel "Trizen" Suteu
    Date: 26 March 2019
    https://github.com/trizen

    Compute terms of the A307069 OEIS sequence.

    Defintion by Elliott Line, Mar 22 2019:
        Given a special version of Pascal's triangle where only Fibonacci numbers are
        permitted, a(n) is the row number in which the n-th Fibonacci number first appears.

*/

#include <set>
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main(int argc, char **argv) {

    set <int> is_fib;
    set <int> seen;

    is_fib.insert(0);
    is_fib.insert(1);
    is_fib.insert(1);
    is_fib.insert(2);
    is_fib.insert(3);
    is_fib.insert(5);
    is_fib.insert(8);
    is_fib.insert(13);
    is_fib.insert(21);
    is_fib.insert(34);
    is_fib.insert(55);
    is_fib.insert(89);
    is_fib.insert(144);
    is_fib.insert(233);
    is_fib.insert(377);
    is_fib.insert(610);
    is_fib.insert(987);
    is_fib.insert(1597);
    is_fib.insert(2584);
    is_fib.insert(4181);
    is_fib.insert(6765);
    is_fib.insert(10946);

    vector <int> row;
    row.push_back(1);

    auto end_of_fib = is_fib.end();
    auto end_of_seen = seen.end();

    bool printed_row = false;

    for (int n = 1; n < 10000000 ; ++n) {

        if (n % 10000 == 0) {
            printf("Processing row %d...\n", n);
        }

        vector <int> t;
        vector <int> fibs;

        int upper = ((n - (n % 2)) >> 1) - 1;

        for (int j = 0; j <= upper; ++j) {

            int v = row[j] + row[j + 1];

            if ((v == 1) || (v == 2) || (v == 3) || (v == 5) || (is_fib.find(v) != end_of_fib)) {

                if (seen.find(v) == end_of_seen) {
                    seen.insert(v);
                    fibs.push_back(v);
                    end_of_seen = seen.end();
                }

                t.push_back(v);
            }
            else {
                t.push_back(1);
            }
        }

        vector <int> v;
        v.resize(t.size());
        reverse_copy(t.begin(), t.end(), v.begin());

        if (n % 2 == 0) {
            v.erase(v.begin());
        }

        for (int k : fibs) {
            printf("%d -> first appears in row %d\n", k, n);

            if (n > 2544 && !printed_row) {
                printf("The row is: \n");
                for (int z : row) {
                    printf("%d ", z);
                }
                printf("\n");
                printed_row = true;

                printf("%d -> first appears in row %d\n", k, n);
            }
        }

        row.clear();
        row.reserve(t.size() + v.size() + 2);
        row.insert(row.end(), t.begin(), t.end());
        row.insert(row.end(), v.begin(), v.end());

        row.push_back(1);
        row.insert(row.begin(), 1);
    }

    return 0;
}
