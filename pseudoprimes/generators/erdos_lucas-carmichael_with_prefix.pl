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
    my @divisors = divisors($L);
    if (ref $L) {
        @divisors = map{Math::GMPz->new($_)} @divisors;
    }
    grep { ($L % $_) != 0 } grep { $_ > 2 and is_prime($_) } map { $_ - 1 }  @divisors;
}

my @prefix = factor(471);
my $prefix_prod = Math::GMPz->new(vecprod(@prefix));

sub isok ($prefix_prod, $p) {
    (($prefix_prod % $p) == 0)
            ? 1
            : Math::Prime::Util::GMP::gcd(
            # Note: sigma(n) = DedekindPsi(n), when n is squarefree
            Math::Prime::Util::GMP::sigma(Math::Prime::Util::GMP::mulint($prefix_prod, $p)),
            Math::Prime::Util::GMP::mulint($prefix_prod, $p)
        ) eq '1';
}

sub method_1 ($L) {

   (vecall { ($L % ($_+1)) == 0 } @prefix) or return;

    my @P = lambda_primes($L);

    @P = grep {
        isok($prefix_prod, $_)
    } @P;

    if (@prefix) {
        #~ $prefix_prod = gcd($prefix_prod, vecprod(@P));
        #~ if ($prefix_prod > ~0) {
            #~ $prefix_prod = Math::GMPz->new($prefix_prod);
        #~ }
        vecprodmod(\@P, $prefix_prod) == 0 or return;
    }

    @P = grep { gcd($prefix_prod, $_) == 1 } @P;

    my $n = scalar(@P);
    my @orig = @P;

    my $max = 1e5;
    my $max_k = @P>>1;

    my $L_rem = invmod(-$prefix_prod, $L);

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
            if (vecprodmod([@P[@_]], $L) == $L-$B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        next if (binomial($n, $k) < $max);

        @P = reverse(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L-$B) {
                my $S = Math::GMPz->new(Math::Prime::Util::GMP::vecprod(@P[@_]));
                say vecprod($prefix_prod, $T / $S) if ($T != $S);
            }
            lastfor if (++$count > $max);
        } $n, $k;

        @P = shuffle(@P);

        $count = 0;
        forcomb {
            if (vecprodmod([@P[@_]], $L) == $L-$B) {
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

    # 579 633 831 939 993
    # 471 489 579 633 831 849 939 993 997
    # 1011 1191 1263 1299 1371 1569 1623 1641 1731 1803 1839 1983
    #"6129808992374767344930533023281723644735"
    #"949345608369235381501270412185"
    #"4433176618644502422330768777221231465169661313213350633114707186944405"
    #"127466063752826626324435698484540540558295"
    #"106653733772365052643166285665180547235"
    #"119024709829745330011481322067838705"
    #"46959971109945694430499962276105606663529719792044602335"
    #"1294274990131688023696493933140236381455"
    #"8799790266329193440224926938725171796106819393467506141512515"
    #"38030534297754067685"
    #"23377842423989657076602266569873101952013003504685"
    #"772179967364902960050618202156261415"
    #"194602156386224629422552469787952346372498846530682289766253612669"
    #"36132677625950010937561463013714222491519325355"
    #"3542836771466567999860458329480884827088068308135"
    #"8914187539791472954947850988928599029456208045582583721352177695"
    #"42234031537459802832396752081596353633218790964930635162242005"
    #"85503937166438882248863699301498021031999539215858124013108319656635"
    #"20864706932178785769917898828869523357817136902558894449789452472928979874601533310644145"
    #"1902297977801930015025944798668484422031845"
    #"66266715510015661319570176140423050370668804770560256135"
    #"234654549136285265933061171738168939714130942284339894585402033882355"
    #"3397999184681623808612078197077715654790193013496329658488604896631594512825115"
    #"7091624298430548888573407197301192571547132819166839997265718419270137748266015005"
    #"996237336944266637684131177655932042052540541708236568160506508712562155"
    #"584429907085032853259228054432854994454835411128998925961399569005"
    #"672678823054872814101371490652216098617515558209477763781570903924755"
    #"112802298561224695246100457357784567481908143295"
    "176636948880029775945137896712998315847845"
    #"123822501164900872937541665595811819409339345"
    #"12842840413387450039118922094150507198373150341080498833706488673768451737215"
    #"1339507056334249374254866105459537342347229669520638067448048963935"
    #"178911053337017413417238694465010998042904991254259124809409505"
    #"24310698014160010310749313013068622919013802712267027259077787135"
    #"31425289217027351639987581502487222669785151702187074325045"
    #"1012591408428327888883952080728349448745451794025524955777432246705535"
    #"3729600465492886035713190910355240492580651955624733123395115"
    #"1552617717262956290883155669454007199664570320354223395"
    #"4909509710014502243130071334918614879080498219285"
) {

     @prefix = factor($n);
     #@prefix = grep { gcd($n, subint($_,1)) == 1 } @prefix;
     #@prefix = grep { gcd($n, addint($_,1)) == 1 } @prefix;
     #$#prefix = 20;
     $prefix_prod = vecprod(@prefix);

     if ($prefix_prod > ~0) {
         $prefix_prod = Math::GMPz->new($prefix_prod);
     }

    foreach my $k(1..1e6) {

         my $L = lcm(map { addint($_, 1) } factor(vecprod($k, $prefix_prod)));

        if ($L > ~0) {
            $L = Math::GMPz->new("$L");
        }

        $L % 2 == 0 or next;

        next if $seen{$L}++;
        method_1($L);
    }
}
