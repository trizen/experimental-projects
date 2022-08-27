#!/usr/bin/perl

# Erdos construction method for Carmichael numbers:
#   1. Choose an even integer L with many prime factors.
#   2. Let P be the set of primes d+1, where d|L and d+1 does not divide L.
#   3. Find a subset S of P such that prod(S) == 1 (mod L). Then prod(S) is a Carmichael number.

# Alternatively:
#   3. Find a subset S of P such that prod(S) == prod(P) (mod L). Then prod(P) / prod(S) is a Carmichael number.

use 5.020;
use warnings;
use ntheory qw(:all);
use List::Util qw(shuffle);
use experimental qw(signatures);

# Modular product of a list of integers
sub vecprodmod ($arr, $mod) {

    #~ if ($mod > ~0) {
        #~ my $prod = Math::GMPz->new(1);
        #~ foreach my $k(@$arr) {
            #~ $prod = ($prod * $k) % $mod;
        #~ }
        #~ return $prod;
    #~ }

    if ($mod < ~0) {
        my $prod = 1;
        foreach my $k(@$arr) {
            $prod = mulmod($prod, $k, $mod);
        }
        return $prod;
    }

    my $prod = 1;

    foreach my $k (@$arr) {
        $prod = Math::Prime::Util::GMP::mulmod($prod, $k, $mod);
    }

    #Math::GMPz->new($prod);
    Math::GMPz::Rmpz_init_set_str($prod, 10);
}

# Primes p such that p-1 divides L and p does not divide L
sub lambda_primes ($L) {
    #grep { ($L % $_) != 0 } grep { $_ > 2 and is_prime($_) } map { $_ + 1 } divisors($L);
     grep { ($_ > 2) and (($L % $_) != 0) and is_prime($_) } map { ($_ >= ~0) ? (Math::GMPz->new($_)+1) : ($_ + 1) } divisors($L);
}

#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89);
#my @prefix = (3,5,17,23, 29);

#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89);
#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 353, 617, 2003, 2549);
#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 353, 617);
#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 419, 449, 617);

#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 257, 353, 449, 617, 1409, 2003);
#my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 1409, 2003);

#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 257, 353, 617, 1409, 2003, 2549, 3137, 9857, 10193, 16073, 68993, 202049, 275969, 1500929, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 2003, 2297, 2549, 3137, 9857, 10193, 68993, 88397, 93809, 5850209, 8044037, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 2003, 2549, 3137, 4019, 4289, 10193, 16073, 21977, 38459, 50513, 52529, 76649, 93809, 97553]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 1409, 2003, 2549, 8009, 9857, 23297, 50513, 68993, 275969, 375233, 1500929, 3232769, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 1409, 2003, 2297, 2549, 3329, 8009, 10193, 16073, 23297, 50177, 93809, 202049, 275969, 656657, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 257, 353, 449, 617, 1409, 2003, 2297, 2549, 3137, 3329, 4019, 7547, 9857, 10193, 16073, 17837, 23297, 68993, 88397, 93809, 202049, 896897, 1500929, 2475089, 8044037, 18386369]

my @prefix = (3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 257, 353, 449, 617, 1409, 2003, 2297, 2549, 3137, 3329, 4019);
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 2003, 2297, 2549, 3137, 9857, 10193, 68993, 88397, 93809, 5850209, 8044037, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 2003, 2549, 3137, 4019, 4289, 10193, 16073, 21977, 38459, 50513, 52529, 76649, 93809, 97553]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 1409, 2003, 2549, 8009, 9857, 23297, 50513, 68993, 275969, 375233, 1500929, 3232769, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 197, 353, 449, 617, 1409, 2003, 2297, 2549, 3329, 8009, 10193, 16073, 23297, 50177, 93809, 202049, 275969, 656657, 18386369]
#~ [3, 5, 17, 23, 29, 53, 83, 89, 113, 257, 353, 449, 617, 1409, 2003, 2297, 2549, 3137, 3329, 4019, 7547, 9857, 10193, 16073, 17837, 23297, 68993, 88397, 93809, 202049, 896897, 1500929, 2475089, 8044037, 18386369]

#my @prefix = (3, 5, 17, 23, 29);
my $prefix_prod = Math::GMPz->new(vecprod(@prefix));

sub isok ($prefix_prod, $p) {
    (($prefix_prod % $p) == 0)
            ? 1
            : Math::Prime::Util::GMP::gcd(Math::Prime::Util::GMP::totient(Math::Prime::Util::GMP::mulint($prefix_prod, $p)), Math::Prime::Util::GMP::mulint($prefix_prod, $p)) eq '1';
}

sub method_1 ($L) {

    (vecall { ($L % ($_-1)) == 0 } @prefix) or return;

    my @P = lambda_primes($L);

    @P = grep {
        isok($prefix_prod, $_)
    } @P;

    #vecprodmod(@P, 3*5*17*23) == 0 or return;
    #vecprodmod(\@P, 3*5*17*23*29) == 0 or return;
    if (@prefix) {
        vecprodmod(\@P, $prefix_prod) == 0 or return;
    }
    #return if (vecprod(@P) < ~0);

    @P = grep { $_ > $prefix[-1] } @P;
    #~ @P = grep { gcd($prefix_prod, $_) == 1 } @P;

    say "# Testing: $L -- ", scalar(@P);

    my $n = scalar(@P);
    my @orig = @P;

    my $max = 1e5;
    my $max_k = scalar(@P)>>1;

    my $L_rem = invmod($prefix_prod, $L);

    foreach my $k (1 .. @P>>1) {
        #next if (binomial($n, $k) > 1e6);

        next if ($k > $max_k);

        @P = @orig;

        my $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L_rem) {
                say vecprod(@P[@_], $prefix_prod);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L_rem) {
                say vecprod(@P[@_], $prefix_prod);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L_rem) {
                say vecprod(@P[@_], $prefix_prod);
            }
            lastfor if (++$count > $max);
        } $n, $k;
    }

    my $B = vecprodmod([@P, $prefix_prod], $L);
    my $T = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P));

    foreach my $k (1 .. @P>>1) {
        #next if (binomial($n, $k) > 1e6);

        last if ($k > $max_k);

        @P = @orig;

        my $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;
    }
}

use Math::GMPz;

my %seen;


foreach my $n(

#~ 125067215
#~ 7378965685
#~ 8379503405
#~ 494390700895
#~ 611703748565
#~ 36090521165335
#~ 54441633622285
#~ 8873986280432455
#~ 11440695209411195
#~ 3132517156992656615
#~ "22331714812200649008335"
#~ "2981979290957543061700035521"
#~ "3804631920839812370901025615"
#~ "450278872934589002316705363671"
#~ "685938843816243059603953030639"
#~ "124154930730739993788315498545659"
#~ "2663278599434746232204172675190229413374378164374136375059"
#~ "2000122228175494420385333679067862289444158001444976417669309"
#~ "1538093993466955209276321599203186100582557503111186865187698621"
#~ "1247394228701700674723096816953783927572454135023172547667223581631"
#~ "1438245545693060877955730629947712868491039617681717947460308789620543"
#~ "1727332900377366114424832486567203155057738580835743254899830856334272143"
#~ "2240350771789443850409007735077662492109886939343959001605080620665550969471"
#~ "562119408266512625797415127440913486421059303057986587120893756048196298403865200212378105189386871279"
#~ "1686920344207804390018042797450181372749598968477017747949802161900637091509999465837346693673350000708279"
#~ 5831683629926379776292373950785277005595363634025050354662466073690502425350068153399707520028770952448520503
#~ 22679417636783690950001042294603942274760369172723420829282330560582363932186415048571462545391890234072296236167
#~ 90740349964771547490954170220710373041316237060066406737958604572890038092677846609334421644112952826523257240904167
#~ 367589157707289538885855343564097721190372076330329013695470307124777544313437956614413742080301571900245715082902780517
#~ 1764795546152697076190991504451233159434976338461909594751952944506056990248815629705800375727527846693079678113016249262117
#~ "8578671149848260487364409703137444388013419981263342540089243263243943029599492775999895626411512862775060315307371987663150737"
#~ "55598367722166576218608739286033777078714974898567723002318385589083994774834312681255323554773014863645165903507077852044879926497"

6601

) {

    gcd(euler_phi($n), $n) == 1 or next;

     @prefix = factor($n);
     $prefix_prod = vecprod(@prefix);

     if ($prefix_prod > ~0) {
         $prefix_prod = Math::GMPz->new($prefix_prod);
     }

    foreach my $k(1..1e6) {

        my $m = vecprod($k, $prefix_prod);
        my $L = lcm(map { subint($_, 1) } factor($m));

        if ($L > ~0) {
            $L = Math::GMPz->new("$L");
        }

        $L % 2 == 0 or next;

        next if $seen{$L}++;
        method_1($L);
    }
}

__END__
my $count = 0;

while (<>) {
    chomp(my $n = $_);

    #$n > 1e5 or next;

    #$n *= 656656;
    #$n *= 78848;
    #$n *= 1232;

    #$n = lcm($n, 29586292736);
    #$n = lcm($n, 1232);
    #$n = lcm($n, 5789168, 147090944);
    #$n = lcm($n, 78848);
    #$n = lcm($n, 656656);
    #$n = lcm($n, 9193184);

    #$n = lcm($n, 10506496);
    #$n = lcm($n, 36772736);

    #~ next if ($n < 707981814540);
    #~ next if ($n > 44351949725003712);

    #next if ($n < 1e6);

    #next if ($n < 1e8);
    #next if ($n < 7813080);        # for 2^64

    #next if ($n < ~0);

    #next if ($n < 17125441200);
    #next if (length($n) > 45);

   # if (++$count % 1000 == 0) {
        #say "Testing: $n";
       # $count = 0 ;
   # }

    #say "Testing: $n";

    if ($n > ~0) {
        $n = Math::GMPz->new($n);
    }

    next if $seen{$n}++;
    method_1($n);
}
