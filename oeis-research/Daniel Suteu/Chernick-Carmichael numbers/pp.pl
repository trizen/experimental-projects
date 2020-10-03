#!/usr/bin/perl

# Generate random Carmichael numbers of the form (6*k+1)*(12*k+1)*(18*k+1), where 6*k+1, 12*k+1 and 18*k+1 are all primes.

# See also:
#   https://oeis.org/A033502 -- Carmichael numbers of the form (6*k+1)*(12*k+1)*(18*k+1)
#   https://oeis.org/A255441 -- Carmichael numbers of the form (60k+41)(90k+61)(150k+101)
#   https://oeis.org/A255514 -- Carmichael numbers of the form (24*k+13)*(72*k+37)*(192*k+97)
#   https://oeis.org/A182085 -- Carmichael numbers of the form (30k+7)*(60k+13)*(150k+31)
#   https://oeis.org/A182088 -- Carmichael numbers of the form (30n-29)*(60n-59)*(90n-89)*(180n-179)
#   https://oeis.org/A182132 -- Carmichael numbers of the form (30n-7)*(90n-23)*(300n-79)
#   https://oeis.org/A182133 -- Carmichael numbers of the form (30n-17)*(90n-53)*(150n-89)
#   https://oeis.org/A182416 -- Carmichael numbers of the form (60k+13)*(180k+37)*(300k+61)

# With 3 mod 5 (few):
#   37*73*(18n+91)

# With 2 mod 5:
#   (24*k+13)*(72*k+37)*(192*k+97)

# With 3 mod 5 (many):
#   (12*k+1)*(24*k+1)(36*k+1)*(72*k+1)


use 5.020;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use Math::Prime::Util::GMP qw(is_prob_prime vecprod random_ndigit_prime is_carmichael random_prime);
use Math::AnyNum qw(fibmod);

sub random_carmichael_number_mod_1_4 ($n = 20) {

    $n = 2 if ($n <= 1);

    while (1) {
        my $p = Math::GMPz::Rmpz_init_set_str(random_ndigit_prime($n), 10);
        my $k = ($p - 1);
        is_prob_prime(2 * $k + 1) && is_prob_prime(3*$k + 1) or next;
        return (3*$k + 1, 2 * $k + 1, $p);
    }
}

sub random_carmichael_number_ord_4 ($n = 20) {

    $n = 2 if ($n <= 1);

    while (1) {
        my $p = Math::GMPz::Rmpz_init_set_str(random_ndigit_prime($n), 10);
        ($p - 1) % 6 == 0 or next;
        my $k = ($p - 1) / 6;
        is_prob_prime(36 * $k + 1) && is_prob_prime(18*$k + 1) && is_prob_prime(12*$k+1) or next;
        return (36*$k + 1, 18 * $k + 1, 12*$k+1, $p);
    }
}

sub random_carmichael_number_ord_5 ($n = 20) {

    $n = 2 if ($n <= 1);

    while (1) {
        my $p = Math::GMPz::Rmpz_init_set_str(random_ndigit_prime($n), 10);
        ($p - 1) % 6 == 0 or next;
        my $k = ($p - 1) / 6;
        is_prob_prime(72*$k+1) && is_prob_prime(36 * $k + 1) && is_prob_prime(18*$k + 1) && is_prob_prime(12*$k+1) or next;
        return (72*$k+1, 36*$k + 1, 18 * $k + 1, 12*$k+1, $p);
    }
}

sub random_carmichael_number_ord_6 ($n = 20) {

    $n = 2 if ($n <= 1);

    while (1) {
        my $p = Math::GMPz::Rmpz_init_set_str(random_ndigit_prime($n), 10);
        ($p - 1) % 6 == 0 or next;
        my $k = ($p - 1) / 6;
        is_prob_prime(144*$k+1) && is_prob_prime(72*$k+1) && is_prob_prime(36 * $k + 1) && is_prob_prime(18*$k + 1) && is_prob_prime(12*$k+1) or next;
        return (144*$k+1, 72*$k+1, 36*$k + 1, 18 * $k + 1, 12*$k+1, $p);
    }
}

sub random_carmichael_number_ord_7 ($n = 20) {

    #$n = 5 if ($n <= 1);
    $n = Math::GMPz->new(10)**($n+2);

    while (1) {
        my $p = Math::GMPz::Rmpz_init_set_str(random_prime($n), 10);
        ($p - 1) % 6 == 0 or next;
        my $k = ($p - 1) / 6;
       is_prob_prime(288*$k+1) && is_prob_prime(144*$k+1) && is_prob_prime(72*$k+1) && is_prob_prime(36 * $k + 1) && is_prob_prime(18*$k + 1) && is_prob_prime(12*$k+1) or next;
        return (288*$k+1, 144*$k+1, 72*$k+1, 36*$k + 1, 18 * $k + 1, 12*$k+1, $p);
    }
}

sub random_carmichael_number_mod3 ($n = 20) {        # c = 3 (mod 5)

    # (12*k+1)*(24*k+1)(36*k+1)*(72*k+1)

    $n = 2 if ($n <= 1);

    while (1) {
        my $p = Math::GMPz::Rmpz_init_set_str(random_ndigit_prime($n), 10);
        ($p - 1) % 12 == 0 or next;
        my $k = ($p - 1) / 12;
        is_prob_prime(72*$k+1) && is_prob_prime(36 * $k + 1) && is_prob_prime(24*$k+1)  or next;
        return ( 72*$k + 1, 24 * $k + 1, 36*$k+1, $p);
    }
}

sub random_carmichael_number_mod2 ($n = 20) {   # c = 2 (mod 5)

     # (24*k+13)*(72*k+37)*(192*k+97)

    $n = 2 if ($n <= 1);

    while (1) {
        my $p = Math::GMPz::Rmpz_init_set_str(random_ndigit_prime($n), 10);
        ($p - 13) % 24 == 0 or next;
        my $k = ($p - 13) / 24;
        is_prob_prime(72 * $k + 37) && is_prob_prime(192*$k+97) or next;
        return ( 192*$k + 97, 72 * $k + 37, $p);
    }
}

foreach my $n (5..100) {

    my @factors    = random_carmichael_number_mod_1_4($n);
    my $carmichael = Math::GMPz::Rmpz_init_set_str(vecprod(@factors), 10);

    my $mod = $carmichael % 5;

    say $carmichael;

    say "Generated...";

    if ($mod == 2 or $mod == 3) {
        say "Testing Carmichael: $carmichael";
        if (fibmod($carmichael+1, $carmichael) == 0) {
            say "You just won 620 dollars: $carmichael with factors: (@factors)\n";
            exit;
        }
    }

    #~ is_carmichael($carmichael) || do{
        #~ say "error for $carmichael";
        #~ next;
    #~ };

    #say "$carmichael = ", join(' * ', @factors);
}

__END__
1729 = 7 * 13 * 19
56052361 = 211 * 421 * 631
2301745249 = 727 * 1453 * 2179
37686301288201 = 18451 * 36901 * 55351
17154555468567481 = 141931 * 283861 * 425791
172625673547411622929 = 3064207 * 6128413 * 9192619
268887334431765312001 = 3552001 * 7104001 * 10656001
406078991106987703861441 = 40752391 * 81504781 * 122257171
185064452271678358333448925481 = 3136104931 * 6272209861 * 9408314791
796148645179673860395060249721 = 5100518221 * 10201036441 * 15301554661
12417271831542758905882855276213681 = 127435857631 * 254871715261 * 382307572891
404458949973189777220710199431658009 = 406981248637 * 813962497273 * 1220943745909
135161326936272067463784220784822756192401 = 28242321905401 * 56484643810801 * 84726965716201
12181524234495103905091894468553485205030761 = 126624223279861 * 253248446559721 * 379872669839581
71298564126689489867005287345716693595569239009 = 2281969547060887 * 4563939094121773 * 6845908641182659
93541245228744122809777159766245241374682438462401 = 24981430230294151 * 49962860460588301 * 74944290690882451
2316300192520603844000801920538407356042561438143929 = 72813939895318957 * 145627879790637913 * 218441819685956869
13455692042356238857960502611988280156630782868655655521 = 1308935549344805521 * 2617871098689611041 * 3926806648034416561
124414554917798673366068156861653327748750021435676828389809 = 27473035454730192937 * 54946070909460385873 * 82419106364190578809
