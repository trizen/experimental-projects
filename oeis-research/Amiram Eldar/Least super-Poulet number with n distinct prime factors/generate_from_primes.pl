#!/usr/bin/perl

# Least super-Poulet number (A050217) with n distinct prime factors.
# https://oeis.org/A328665

# Knwon terms:
#       341, 294409, 9972894583, 1264022137981459, 14054662152215842621

# Upper-bounds for larger values of n:
#   a(7)  <= 1842158622953082708177091
#   a(8)  <= 192463418472849397730107809253922101
#   a(9)  <= 1347320741392600160214289343906212762456021
#   a(10) <= 70865138168006643427403953978871929070133095474701
#   a(11) <= 3363391752747838578311772729701478698952546288306688208857
#   a(12) <= 132153369641266990823936945628293401491197666138621036175881960329
#   a(13) <= 9105096650335639994239038954861714246150666715328403635257215036295306537
#   a(14) <= 7605797846771738682631804190686245080923244102451432651379391224410677241944951032625821
#   a(15) <= 583462829118063997969288097919745382615830384751374654220121121241714767909343250691740938345627581
#   a(16) <= 60336189146110862914155339141650141023642367463340114622477941803849166521055266080449847939541683178584955319081
#   a(17) <= 1757355226500841223659870454576529894860951006141889161871625859966497942441821484750753972233062628818635290051142468511809849201
#   a(18) <= 6754107901853819944350053986104388539892890204497789916481187058214883754639305421999027297202025756314839340897683129744120640068065743521869215861
#   a(19) <= 167946969608834169877913135159828049806545760374416799353477261496612130833838405226686018959622833493253679804273965793463080063696925244340176652378080346414872915901
#   a(20) <= 9708313763566334271624198961083374088566726632347407983984499475757338713079447635544836399943858166687758436571932433665323759985226040303213703595321251004470911786242937492097281349359966481
#   a(21) <= 94829000232162970728932192532610253068751281755820291957919564777258604337747645076103608237122204812058699821474619632576369303656642018110700291067868297416822275868685985274652730713750523550615124254853446956559005581
#   a(22) <= 88634726633751946518804015691149343188239105616726287463105436088616088288551840348174104329943343314927485060648515392894556759032875448954219692758047162875036406382966768007183914346242400413613822431301166739889850650088850198179554239597342350108161409385047526181

use 5.020;
use warnings;
use experimental qw(signatures);

use IO::Handle;
use ntheory qw(forcomb forprimes divisors powmod vecmax);
use Math::Prime::Util::GMP;
use Math::GMPz;

sub super_poulet_pseudoprimes ($from, $callback) {

    my %common_divisors;

    warn ":: Sieving...\n";

    open my $primes_fh, '<', 'primes.txt';
    chomp(my @primes = <$primes_fh>);
    close $primes_fh;

    warn "There are a total number of ", scalar(@primes), " primes in the list...\n";

    warn ":: Processing primes from prime-list...\n";

    my %seen_prime;

    foreach my $p (@primes) {
        $p =~ /^\d+\z/ or next;
        $seen_prime{$p} = 1;

        if ($p > ((~0)>>1)) {
            $p = Math::GMPz->new($p);
        }

        foreach my $d (divisors($p - 1)) {
            if (powmod(2, $d, $p) == 1) {
                push @{$common_divisors{$d}}, $p;
            }
        }
    }

    my $range_width = 1e8;

    warn ":: Processing primes in the range [$from, $from + $range_width]...\n";

    forprimes {
        my $p = $_;
        if (not exists $seen_prime{$_}) {
            foreach my $d (divisors($p - 1)) {
                if (powmod(2, $d, $p) == 1) {
                    push @{$common_divisors{$d}}, $p;
                }
            }
        }
    } $from, $from + $range_width;

    warn ":: Creating combinations...\n";

    open my $new_primes_fh, '>', 'new_primes.txt';

    $new_primes_fh->autoflush(1);

    #foreach my $arr (values %common_divisors) {
    while (my ($key, $arr) = each %common_divisors) {

        my $nf = 8;             # minimum number of prime factors
        next if @$arr < $nf;

        my $l = $#{$arr} + 1;

        foreach my $k ($nf .. $l) {

            forcomb {
                my $n = Math::Prime::Util::GMP::vecprod(@{$arr}[@_]);

                foreach my $p (@{$arr}[@_]) {
                    if (!$seen_prime{$p}++) {
                        say $new_primes_fh $p;
                    }
                }

                $callback->($n, $k);
            } $l, $k;
        }
    }

    close $new_primes_fh;
}

open my $fh, '>', 'psp_super_poulet_2.txt';

$fh->autoflush(1);

super_poulet_pseudoprimes(
    1,
    sub ($n, $k) {
        if ($n > ~0) {       # report only numbers greater than 2^64
            warn "$k $n\n";
            say $fh "$k $n";
        }
    }
);

close $fh;
