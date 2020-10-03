
// Least k such that A296062(k) = n.
// https://oeis.org/A325944

// Known terms:
//  0, 2, 4, 8, 9, 10, 17, 128, 18, 512, 20, 34, 35, 8192, 66, 36, 37, 38, 1025, 40, 41, 42, 69, 514, 70, 132, 1026

// Upper-bound: a(n) <= 2^n

// It's very likely that a(27) = 2^27

// Further terms of the sequence (with question marks where unknown):
//  a(28) = 72
//  a(29) = 2050
//  a(30) = 73
//  a(31) = 134
//  a(32) = 74
//  a(33) = ?
//  a(34) = 76
//  a(35) = 516
//  a(36) = 80
//  a(37) = 136
//  a(38) = 81
//  a(39) = ?
//  a(40) = 82
//  a(41) = 32770
//  a(42) = 84
//  a(43) = 138
//  a(44) = 139
//  a(45) = 518
//  a(46) = 264
//  a(47) = 140
//  a(48) = 141
//  a(49) = 142
//  a(50) = 265
//  a(51) = ?
//  a(52) = 1030
//  a(53) = 144
//  a(54) = 266
//  a(55) = 520
//  a(56) = 145
//  a(57) = ?
//  a(58) = 4101
//  a(59) = 146
//  a(60) = 147

// Probably all a(n) with question marks above, are a(n) = 2^n.

// Compilation:
//  g++ -march=native -Ofast prog.cpp -o compiled

#include <map>
#include <iostream>

using namespace std;

map <unsigned int, unsigned int> cache = {};

unsigned int a(unsigned int n) {

    if (n <= 1) {
        return 0;
    }

    if (cache.find(n) != cache.end()) {
        return cache[n];
    }

    auto t = (n & 1) ? (a((n-1) >> 1) << 1) : (a(n >> 1) + a((n >> 1)-1) + 1);
    cache[n] = t;
    return t;
}

unsigned int f(unsigned int n) {
    for (unsigned int k = 1; ; ++k) {
        if (a(k) == n) {
            return k;
        }
    }
}

int main(int argc, char **argv) {
    for (int n = 1; n <= 1000; ++n) {
        cout << "a(" << n << ") = " << f(n) << endl;
    }
}
