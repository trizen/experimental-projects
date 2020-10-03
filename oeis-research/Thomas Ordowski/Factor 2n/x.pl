#!/usr/bin/perl

#~ I was not able to find any such number bellow 220729.

#~ The search was done using Fermat pseudoprimes to base 2 and the observation that if 2^n-1 has a prime factor < n, we can safely skip it, since p = p (mod n) for p < n.

#~ When 2^n - 1 has only prime factors > n, we try to find the first prime that is not p = 1 (mod n).

#~ Bellow I included a list with one such prime factor p | 2^n-1, p > n, for which p != 1 (mod n), listed under the form: p = k (mod n):

#~ 535006138814359 = 2314   (mod   4369)
          #~ 18121 = 4078   (mod   4681)
 #~ 16937389168607 = 332    (mod  10261)
          #~ 80929 = 1125   (mod  19951)
         #~ 931921 = 20828  (mod  31417)
       #~ 85798519 = 10746  (mod  31621)
       #~ 10960009 = 1566   (mod  49141)
         #~ 104369 = 16012  (mod  88357)
        #~ 1504073 = 38931  (mod 104653)
         #~ 179951 = 56700  (mod 123251)
       #~ 13821503 = 53269  (mod 129889)
         #~ 343081 = 81959  (mod 130561)
      #~ 581163767 = 26248  (mod 162193)
        #~ 2231329 = 162702 (mod 188057)
        #~ 2349023 = 18371  (mod 194221)
         #~ 326023 = 106242 (mod 219781)

#~ Strong candidate: n = 220729
   #~ 2^n - 1 has no factors bellow 10^9


func my_trial_factor(n, b) {
    b.primes.any {|p| n %% p }  #%
}

func trivial_factor(from, n) {
    for (var p = from.next_prime; true; p.next_prime!) {
        if (n %% p) { #%
            return p
        }
    }
}

#or n in (8935..1e6) {
DATA.each {|line|

    var n = line.nums[-1]

    #next if ((n == 4369) || (n == 10261))
    #next if n.is_prime
    say "Testing: #{n}"
    var t = (ipow2(n) - 1)

    #if (2**n - 1 -> factor.all { |p| p % n == 1 }) {

    #if (powmod(2, t-1, t) == 1) {
  #  if (is_fermat_pseudoprime(t, 2)) {
        #var f = t.trial_factor(n)
         if (my_trial_factor(t, n)) {
          #  say "Found a small prime factor..."
            next
         }

        #say "Factor: 2^#{n} - 1"

        #if (f[0] <= n) {
        #    next
        #}

        #~ say "p+1 factoring..."
        #~ var r = t.pplus1_factor

        #~ if (r.len == 2) {
            #~ say "p+1 found factor: #{r[0]}"
            #~ if (r[0].factor.any { |p| p % n != 1 }) {
                #~ say "p+1: Some factor of #{r[0]} != 1 (mod #{n})"
                #~ next
            #~ }
        #~ }

        #say "Trial factoring..."
        var copy = t
        var all_one = true
        var from = 0

        #~ 100.times {
           #~ # say "Trial factoring: #{_}"
            #~ var p = trivial_factor(from, copy)

            #~ if (p % n != 1) {
                #~ say "Trial counter-example: #{p} = #{p % n} (mod #{n})"
                #~ all_one = false
                #~ break
            #~ }

            #~ from = p
            #~ copy /= p
        #~ }

        #~ all_one || next

        var copy = t
        var all_one = true
        var from = 0

        100.times {
            var r = copy.trial_factor(1e7)

            if (r.len == 2) {
              #  say "Trial division found factor: #{r[0]}"
                if (r[0].factor.any {|p| p % n != 1 }) {
                    say "Counter-example: #{r[0]} = #{r[0] % n} (mod #{n})"
                    all_one = false
                    break
                }
            }
            else {
                break
            }

            copy /= r[0]
        }

        all_one || next

        copy = t
        all_one = true

        100.times {
          #  say "ECM factoring: #{_}"
            var r = copy.ecm_factor

            if (r.len == 2) {
                say "ECM found factor #{r[0]}"
                if (r[0].factor.any {|p| p % n != 1 }) {
                    say "Rho: #{r[0]} = #{r[0] % n} (mod #{n})"
                    all_one = false
                    break
                }
            }
            else {
                break
            }

            copy /= r[0]
        }

        all_one || next

        say "Final factoring"

        if (t.factor.all { |p| p % n == 1} ) {
            die "Found: #{n}"
        }
   # }
}

__DATA__
1 341
2 561
3 645
4 1105
5 1387
6 1729
7 1905
8 2047
9 2465
10 2701
11 2821
12 3277
13 4033
14 4369
15 4371
16 4681
17 5461
18 6601
19 7957
20 8321
21 8481
22 8911
23 10261
24 10585
25 11305
26 12801
27 13741
28 13747
29 13981
30 14491
31 15709
32 15841
33 16705
34 18705
35 18721
36 19951
37 23001
38 23377
39 25761
40 29341
41 30121
42 30889
43 31417
44 31609
45 31621
46 33153
47 34945
48 35333
49 39865
50 41041
51 41665
52 42799
53 46657
54 49141
55 49981
56 52633
57 55245
58 57421
59 60701
60 60787
61 62745
62 63973
63 65077
64 65281
65 68101
66 72885
67 74665
68 75361
69 80581
70 83333
71 83665
72 85489
73 87249
74 88357
75 88561
76 90751
77 91001
78 93961
79 101101
80 104653
81 107185
82 113201
83 115921
84 121465
85 123251
86 126217
87 129889
88 129921
89 130561
90 137149
91 149281
92 150851
93 154101
94 157641
95 158369
96 162193
97 162401
98 164737
99 172081
100 176149
101 181901
102 188057
103 188461
104 194221
105 196021
106 196093
107 204001
108 206601
109 208465
110 212421
111 215265
112 215749
113 219781
114 220729
115 223345
116 226801
117 228241
118 233017
119 241001
120 249841
121 252601
122 253241
123 256999
124 258511
125 264773
126 266305
127 271951
128 272251
129 275887
130 276013
131 278545
132 280601
133 282133
134 284581
135 285541
136 289941
137 294271
138 294409
139 314821
140 318361
141 323713
142 332949
143 334153
144 340561
145 341497
146 348161
147 357761
148 367081
149 387731
150 390937
151 396271
152 399001
153 401401
154 410041
155 422659
156 423793
157 427233
158 435671
159 443719
160 448921
161 449065
162 451905
163 452051
164 458989
165 464185
166 476971
167 481573
168 486737
169 488881
170 489997
171 493697
172 493885
173 512461
174 513629
175 514447
176 526593
177 530881
