#!/usr/bin/perl

func hello(n) {
    sum(1..n, {|k|
        #moebius(k)
        liouville(k)
    })
}

func foo(n) {
    sum(1..n, {|k|
        #hello(floor(n/k))
       # k.divisors.sum{|d|
            #moebius(d)
            liouville(k)
      #  }
    })
}

func bar(n) {
    sum(1..n, {|k|
        k.divisors.sum{|d|
            #(-1)**omega(d)
            moebius(d.rad)
        }
    })
}

func hi(n) {
    (-1)**(n+1) * n.divisors.sum{|d|
        (-1)**omega(d)
    }
}

func baz(n) {
        sum(1..n, {|k|
             #(-1)**bigomega(k) * faulhaber(floor(n/k), 0)
             k.divisors.sum{|d|
                liouville(k/d) * d
             }
        })
}

#Sum_{n=1..30000} a(n)/n = 1.31897
#                          1.31896

say sum(1..3000, {|k|
    hi(k)/k
})

# 0.530710843791156208843791156208843791156208843791
# 0.53071182047204479497294377247    - https://oeis.org/A065469 (-1)^omega(k)
# 0.813663587902956288339028461627423933983881428108

# 0.65797362673929       - https://oeis.org/A182448 (-1)^bigomega(k)
#

#say 30.of(bar)
#say 30.of(baz)

#~ say prod(1..1000, {|k|
    #~ (1 - 1/(prime(k)**3 - 1))
#~ })

__END__
#say 20.of(baz)
#say 80.of(hi) #.map_kv{|k,v| (-1)**(k+1) * v }
for n in (1..2500) {
    say (n, " ", hi(n))
}


__END__

for n in (1..7) {
    var t = baz(10**n)
    say (n, ' -> ', t, ' -> ', t / faulhaber(10**n, 1))
}

__END__
for k in (1..5) {
    say ("L(10^#{k}) = ", foo(10**k))
}


__END__
#say 100.of(foo).accumulate
for n in (1..1e4) {
    say foo(n)
}
