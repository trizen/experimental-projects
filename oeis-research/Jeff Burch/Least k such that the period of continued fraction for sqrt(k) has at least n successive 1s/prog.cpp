/*
    Daniel "Trizen" Suteu
    Date: 24 September 2019
    https://github.com/trizen

    Least a(n) such that the period of continued fraction for sqrt(a(n)) has at least n successive 1's.
    https://oeis.org/A060215

    Known terms are: 2, 3, 7, 7, 13, 58, 58, 135, 461, 819, 2081, 13624, 13834, 35955, 95773, 244647, 639389, 1798800, 4374866, 11448871, 30002701, 78439683, 205337953, 541653136, 1407271538
*/

#include <cmath>
#include <iostream>
#include <vector>
#include <string>
#include <sstream>

using namespace std;

int isqrt(int n) {
    return static_cast<int>(std::sqrt((double) n));
}

vector<int> cfrac_sqrt(int n) {

    int x = isqrt(n);
    int y = x;
    int z = 1;
    int r = 2 * x;

    vector<int> cfrac = {x};

    if (x * x == n) {
        return cfrac;
    }

    do {
        y = r * z - y;
        z = (n - y * y) / z;
        r = (x + y) / z;
        cfrac.push_back(r);
    }
    while (z != 1);

    return cfrac;
}

string join_vector(vector<int> v) {
    stringstream ss;
    for (size_t i = 0; i < v.size(); ++i) {
        if (i != 0) {
            ss << " ";
        }
        ss << v[i];
    }
    string s = ss.str();
    return s;
}

bool isok(int n, int k, string ones) {
    vector<int> v = cfrac_sqrt(k);

    if (v.size() <= n) {
        return false;
    }

    string s = join_vector(v);

    if (s.find(ones) != std::string::npos) {
        return true;
    }

    return false;
}

int a(int n, int from) {

    stringstream ss;

    for (int t = 1; t <= n; ++t) {
        ss << " 1";
    }

    ss << " ";
    string ones = ss.str();

    for (int k = from; ; ++k) {
        if (isok(n, k, ones)) {
            return k;
        }
    }
}

int main(int argc, char **argv) {
    int from = 1;
    for (int n = 1; n <= 30; ++n) {
        int k = a(n, from);
        cout << "a(" << n << ") = " << k << endl;
        from = k;
    }
}
