#!/usr/bin/perl




func f(n) {
    #moebius(rad(n))
    (-1)**omega(n)
}

func g(n) {
    n.divisors.sum{|d|
        f(d)
    }
}

func g2(n) {
    n.divisors.sum {|d|
        moebius(rad(d))
    }
}

func g3(n) {

    #if (n.is_perfect_power) {
        #return (n.factor.lcm / n.factor_exp{.tail}.lcm)
        #return n.factor_exp.map{.tail}.max
        #assert_eq(n.perfect_root, n.perfect_root.rad)
    #}

    #n.is_perfect_power ? (moebius(n.rad) * ((n.perfect_power - 1) ** omega(n.rad))) : 0

    #moebius(n.perfect_root) *
    #(n.perfect_power-1)**omega(n) *
    (n.perfect_power - 1)**omega(n) * moebius(n.rad)
}

func gsum(n) {
    sum(1..n, {|k|
        (-1)**bigomega(k) * faulhaber(floor(n/k), 1)
       #k.divisors.sum {|d|
       # d**2 * liouville(d)
       #}
    })
}

func gsum2(n) {
    sum(1..n, {|k|
        moebius(k)**2 * faulhaber(floor(n/k), 1)
       #k.divisors.sum {|d|
       # d**2 * liouville(d)
       #}
    })
}

say g(2**3 * 3**3)
say g3(2**3 * 3**3)

for n in (2..100) {

    say "Testing: #{n}"
    #assert_eq(g3(n), g(n), "Failed for: n = #{n}")

   # next if n.is_squarefree

    #~ if (n.is_squarefree) {
        #~ assert_eq(g(n), 0)
    #~ }

    #~ next

    #n.is_prime_power || next
    #n.is_perfect_power || next

    #n.perfect_root == n.perfect_root.rad || next

    #n = n.pn_primorial
    #n.is_squarefree || next

    if (g3(n) != g(n)) {
        say "Not matching for #{n} -- #{g(n)} != #{g3(n)} -> #{n.factor_exp}"
    }
}

__END__

#say 20.of(g)
#say 20.of(g2)
#var n = (43*13)**5

say g(n)
say g2(n)
say g3(n)

__END__
# 282488053

#say 20.of { gsum(_) }
#say 20.of { gsum(_) }.map_cons(2, {|a,b| b-a })

#say 20.of(g)

for n in (1..1e4) {
    #var k = 1e20.irand
    #if (k.is_squarefree) {
        #say "Testing: #{k}"
     #   assert_eq(g(k), euler_phi(k))
    #}

    if (g(n) != euler_phi(n)) {
        say n.factor
    }
}

#If n is squarefree (A005117), then a(n) = A000010(n) where A000010 is the Euler totient function.


__END__
var n = 10000

say gsum(n)
say gsum2(n)

say ''

say (n**3 * zeta(6)/(3*zeta(3)))
say (n**3 * zeta(3)/(3*zeta(6)))

say ''

say (faulhaber(n, 2) * zeta(6)/(zeta(3)))
say (faulhaber(n, 2) * zeta(3)/(zeta(6)))

#Sum_{k=1..n} |a(k)| ~ n^3 * zeta(6)/(3*zeta(3)).

#(n^3 * zeta(6)) / (3 * zeta(3))
#say 60.of { gsum(_) } #.map_cons(2, {|a,b| b-a })
#1, 4, 12, 25, 49, 73, 121, 172, 245, 317, 437, 541, 709, 853, 1045, 1250, 1538, 1757, 2117, 2429, 2813, 3173, 3701, 4109, 4710, 5214, 5870, 6494, 7334, 7910, 8870, 9689, 10649, 11513, 12665, 13614, 14982, 16062, 17406, 18630, 20310, 21462, 23310, 24870, 26622, 28206, 30414, 32054, 34407, 36210
#1, 4, 12, 25, 49, 73, 121, 172, 245, 317, 437, 541, 709, 853, 1045, 1250, 1538, 1757, 2117, 2429, 2813, 3173, 3701, 4109, 4710, 5214, 5870, 6494, 7334, 7910, 8870, 9689, 10649, 11513, 12665, 13614, 14982, 16062, 17406, 18630, 20310, 21462, 23310, 24870, 26622, 28206, 30414, 32054, 34407, 36210, 38514, 40698, 43506, 45474, 48354, 50802, 53682, 56202, 59682
