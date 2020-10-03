#!/usr/bin/perl

# S(23382529) = 23001598

use 5.014;
use ntheory qw(:all);
use Math::AnyNum qw(is_smooth);

sub S {
    my ($n) = @_;

    my $sum = 0;
    my $t = ($n-1);

   # my %table;

    foreach my $k(1..$n-1) {
        $sum = addmod($sum, powmod($k, $t, $n), $n);

            # and powmod($k, $t, $n) == 154) {
            #say "$k -> ", powmod($k, $t, $n), ' -> ', join(', ' ,factor($k));
        #}
    }

    if ($sum == 1){
        die "Counter-example: $n";
    }

    $sum
    #(vecall {($n/$_-1) % ($_-1) ==  0 }factor($n))
}

sub optimizedS {
    my ($n) = @_;

    my @d = divisors($n);

    my $sum = 0;
    my $t = ($n-1);

    my $count = 0;
    foreach my $d(divisors($n)) {
      #  if ($d > 1) {
            $sum = addmod($sum, mulmod(powmod($d, $t, $n), euler_phi($n/$d), $n), $n);
       # }
    }

    if ($n > ~0) {
        say ref $sum;
    }

    ($sum  ) %$n;
}


#~ foreach my $n(3..1e3) {
    #~ next if is_prime($n);
    #~ next if $n%2 == 0;
    #~ next if is_power($n);
    #~ if (S($n) == optimizedS($n)) {
        #~ #say "$n";
        #~ print($n, ", ");
    #~ }
#~ }


#~ __END__

use Math::GMPz;

while (<>) {

    next if /^#/;
    my $n = (split(' '))[-1];
    #my $n = next_prime int rand 1e6;

    $n || next;

    #is_smooth($n, 1e7) || next;
    #next if ($n < 1e9);
   # $n < 1e10 || next;

    #next if $n > 1e9;
    #~ next if $n < ~0;
    #~ next if length($n) > 30;

    #~ is_carmichael($n) || next;

    #~ $n = Math::GMPz->new("$n");

    my $x = optimizedS($n);
   #~ my $y = S($n);

    #~ if ($x != $y){
        #~ die "$n -- error $x != $y";
    #~ }
        #~ say "Error for $n: $x != $y -> ", join(', ', factor($n));

        #~ if (is_carmichael($n)) {
            #~ die "Fatal error!!!";
        #~ }
    #~ }

    say "S($n) = $x";

    if ($x == $n-1 or $x == 1) {

        #if (S($n) == $n-1) {
        die "Counter-example: $n with x = $x";
        #}
    }

    #my $x = S($n);
    #my $y = optimizedS($n);

    #say "S($n) = $x -- $y";

    #if ($x != $y) {
    #    die "Counter-example: $n";
    #}
}


__END__

say S(43);
say S(541);
say S(561);
#say S(1024651);
say 961792;
say S(362879);

say '';

say optimizedS(43);
say optimizedS(541);

say '';

say optimizedS(561), ' == ', 290, ' -> ', optimizedS(561) == 290;
say optimizedS(1024651), ' == ', 961792, ' -> ', optimizedS(1024651) == 961792;

say '';

say optimizedS(16046641), ' == ', 14123661, ' -> ', optimizedS(16046641) == 14123661;
say optimizedS(16778881), ' == ', 12009864, ' -> ', optimizedS(16778881) == 12009864;
say optimizedS(23382529);
#S(16046641) = 14123661

__END__

foreach my $n(3..1e6) {
    say "S($n) = ", S($n);
}

__END__

S(16046641) = 14123661
S(16778881) = 12009864
S(17098369) = 16858238
S(17236801) = 17009098
S(17316001) = 16870670
S(17586361) = 15629649
S(17812081) = 14481769
S(18162001) = 13384248
S(18307381) = 17004481
S(18900973) = 14643537
S(19384289) = 19080158
S(19683001) = 17433969
S(20964961) = 18167065
S(21584305) = 15871469
S(22665505) = 16557229
S(23382529) = 23001598


while (<>) {
    my (undef, $n) = split(' ');
    say "S($n) = ", S($n);
}

__END__


__END__
# and ($n/$_-1) % $_ == 0

foroddcomposites {
    say $_ if isok($_);
} 1e3;

__END__

sub S {
    my ($n) = @_;

    my $sum = 0;
    my $t = ($n-1);

    foreach my $k(1..$n-1) {
        $sum = addmod($sum, powmod($k, $t, $n), $n);
    }

    #if ($sum == 1 or $sum == $n-1) {
    #    die "Counter-example: $n";
    #}

    $sum;
}

foreach my $n(1..10) {
    my $p = nth_prime($n);
    say "S($p) = ", S($p);
}

while (<>) {
    my (undef, $n) = split(' ', $_);

    $n || next;
    ($n+0) || next;

    #next if $n < 4903921;

    say "S($n) = ", S($n);
}

__END__
#~ #say S(976873);

#~ #__END__

#~ S(976873) = 0
#~ S(983401) = 980430
#~ S(997633) = 724137

foroddcomposites {
    my $k = $_;
    if (is_euler_pseudoprime($k,2)) {
        say "S($k) = ", S($k);
    }
} 1e6;
