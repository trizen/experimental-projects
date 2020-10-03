


var arr = []

ARGF.each {|line|
    var n = line.numbers[-1]
    arr << n
}

arr.sort.each_kv {|k,v|
    say "#{k+1} #{v}"
}


__END__
func carmichael_root(n) {


    if (var k = bsearch(1, n, {|k|
       # (6*k + 1) * (12*k + 1) * (18*k + 1) <=> n
       (k + 1)*(2*k + 1)*(3*k + 1) <=> n
    })) {
        #is_prime(6*k + 1) && is_prime(12*k + 1) && is_prime(18*k + 1) && return k
        return k
    }


}



#k = 1/108 ((18 sqrt(729 n^2 - 105 n - 3) + 486 n - 35)^(1/3) + 13/(18 sqrt(729 n^2 - 105 n - 3) + 486 n - 35)^(1/3) - 11)
say carmichael_root(173050936856641955498483819650511969240958578948004818728561)
say carmichael_root(8470346587201)
