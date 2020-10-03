#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 10 August 2019
# https://github.com/trizen

# !!! UPDATE !!! a(5) does NOT exist!
# https://www.primepuzzles.net/puzzles/puzz_970.htm

# Various techniques to search for an upper-bound for a(5), which is currently unknwon.

# Useful primes:
#   67, 757, 859, 937, 971, 2273, 3547, 3581, 6689, 7187, 7451, 7529, 8537, 8999, 9629, 9929, 9931, 44651, 55441, 59393, 75577, 79283, 84649, 87739, 91463, 943541, 1135279, 3993233, 4197877, 7388959, 11778479, 15943621, 18361487, 28117237, 34615781, 44432767, 45384431, 49368719, 53796121, 61847197, 78489641, 92524849, 124737689, 149638949, 168169357, 195833413, 231394981, 265882147, 322462867, 376177831, 448218431, 574451989, 648468883, 676455331, 724914977, 727495261, 739632529, 861769663, 862519859, 931838381, 939861431, 1111195733, 1155918319, 1177237253, 1178872679, 1182958529, 1189653967, 1292719489, 1457243267, 1799684429, 1839745723, 1895697247, 1954662769, 1968654439, 2145543341, 2152365997, 2165179769, 2178129677, 2253616523, 2288882293, 2295824591, 2327256487, 2441923313, 2447371181, 2518794379, 2531921143, 2546383691, 2569151371, 2658516691, 2664968561, 2694431827, 2892176921, 2987542799, 2987953469, 3149392669, 3232359679, 3321633949, 3485272669, 3535822427, 3543451649, 3557839499, 3625387553, 3678833863, 3713719873, 3743375543, 3776442829, 3819438431, 3847334419, 4145783927, 4155662341, 4185898931, 4412629751, 4413671183, 4497569459, 4582316261, 4612953677, 4617997669, 4648733281, 4656646153, 4685654327, 4777645351, 4786396423, 4796844497, 4855251839, 4955262413, 4956514699, 4974732487, 4998545977, 5153632573, 5372856263, 5431212799, 5529636187, 5615457971, 5623794551, 5684525131, 5711529463, 5931943657, 5955849883, 5968874537, 5999166773, 6241989631, 6242295517, 6245391527, 6358249819, 6382762187, 6526556789, 6583929259, 6654259489, 6658976791, 6746361221, 6848988989, 6866269967, 6938881751, 6986548411, 6989455589, 7122788221, 7246299163, 7285746269, 7395477611, 7539562873, 7736514671, 7834559687, 7886749931, 7926759851, 7967599427, 7981916339, 7988647943, 8175449237, 8178367697, 8189735963, 8191822957, 8221416341, 8415448829, 8458183249, 8458618691, 8915549471, 8982713933, 9248453351, 9318383653, 9399351769, 9434487233, 9518676359, 9644488991, 9717514817, 9845444879, 9913134263, 9924527273, 9976817113, 9991984789

# These are primes p such that "30p", "p03" and "30p03" are all prime.

# Useful small primes:
#   67, 757, 859, 937, 971, 2273, 3547, 3581, 6689, 7187, 7451, 7529, 8537, 8999, 9629, 9929, 9931

# The a(5) term is expected to have around 40 digits (+/- 5 digits).

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniq shuffle);

my @examples_a4;

{
    open my $fh, '<', 'examples_for_a(4).txt';

    while (<$fh>) {
        while (/(\d+)/g) {
            push @examples_a4, $1;
        }
    }

    close $fh;
}

@examples_a4 = uniq(@examples_a4);

say "Total number of a(4) examples: ", scalar(@examples_a4);

sub isok ($p) {

    # is_prob_prime($p) || return;

    my @P   = split(/0/, $p);
    my $end = $#P;

    foreach my $i (0 .. $end - 1) {
        foreach my $j ($i + 1 .. $end) {
            is_prob_prime(join('0', @P[$i .. $j])) || return;
        }
    }

    vecall { is_prob_prime($_) } @P;
}

sub check_small_primes {

    my @primes;

    forprimes {
        if (!/0/) {
            push @primes, $_;
        }
    } 1, 1e6;

    say "Total number of primes: ", scalar(@primes);

    foreach (@primes) {
        say "Testing: $_";

        if (is_prob_prime('30' . $_)) {
            foreach my $p (@examples_a4) {
                my $t = $p . '0' . $_;
                if (is_prob_prime($t) and isok($t)) {
                    die "Found: $p 0 $_";
                }
            }
        }

        if (is_prob_prime($_ . '03')) {
            foreach my $p (@examples_a4) {
                my $t = $_ . '0' . $p;
                if (is_prob_prime($t) and isok($t)) {
                    die "Found: $_ 0 $p";
                }
            }
        }
    }
}

#~ check_small_primes();

say "Performing sanity check...";

foreach my $p (@examples_a4) {
    isok($p) || die "error for p = $p";
}

say "Sanity check passed!";

#my @primes = grep { $_ != 2 } grep { $_ != 5 } grep { !/0/ } @{primes(1e5)};

my @primes;
my %seen;

sub extract_special_primes ($p) {
    if ($p =~ /^30([^0]+)030/) {
        push(@primes, $1) if !$seen{$1}++;
    }

    if ($p =~ /030([^0]+)03\z/) {
        push(@primes, $1) if !$seen{$1}++;
    }
}

foreach my $p (@examples_a4) {
    extract_special_primes($p);
}

#<<<
#~ forprimes {

    #~ if (!/0/) {
        #~ if (is_prime('30' . $_) and is_prime($_ . '03') and is_prime("30" . $_ . '03')) {
            #~ push(@primes, $_) if !$seen{$_}++;
        #~ }
    #~ }

#~ } 1e7;
#>>>

$seen{3} = 2;
@primes = uniq(3, @primes);

#~ @primes = grep { $_ > 1e10 } @primes;
#~ @primes = grep { $seen{$_} == 1 or $_ == 3 } @primes;

say "Total number of primes: ", scalar(@primes);

#my @prefix_primes = grep { is_prime("30${_}") } @primes;
#my @suffix_primes = grep { is_prime("${_}03") } @primes;

#~ my @prefix_primes = @special_primes;
#~ my @suffix_primes = @special_primes;

#~ unshift @prefix_primes, 3;
#~ unshift @suffix_primes, 3;

#~ @prefix_primes = uniq(@prefix_primes);
#~ @suffix_primes = uniq(@suffix_primes);

#~ say "Total number of prefix primes: ", scalar(@prefix_primes);
#~ say "Total number of suffix primes: ", scalar(@suffix_primes);

my @prefix_primes = grep { !/0/ } grep { is_prime($_ . '03') } @{primes(1e7)};
my @suffix_primes = grep { !/0/ } grep { is_prime('30' . $_) } @{primes(1e7)};

#~ push @prefix_primes, @primes;
#~ push @suffix_primes, @primes;

@prefix_primes = grep { not exists $seen{$_} } uniq(@prefix_primes);
@suffix_primes = grep { not exists $seen{$_} } uniq(@suffix_primes);

say "Total number of prefix primes: ", scalar @prefix_primes;
say "Total number of suffix primes: ", scalar @suffix_primes;

sub generate_from_prefix ($root, $k) {

    #~ say "$k -> $root";

    if ($k >= 4) {
        say "k = $k -> $root";

        extract_special_primes($root);

        if ($root =~ /^30/) {
            foreach my $p (@prefix_primes) {
                if (is_prob_prime($p . '0' . $root) and isok($p . '0' . $root)) {
                    die "Found: $p 0 $root";
                }
            }
        }

        if ($k >= 5) {
            die "Found: $root";
        }
    }

    foreach my $p (@primes) {

        my $x = join('0', $root, $p);

        if (is_prob_prime($x)) {

            if ($k >= 4) {
                if (isok($x)) {
                    die "Found: $x";
                }
                else {
                    next;
                }
            }

            if (is_prob_prime($x . '03') and isok($x . '03')) {
                __SUB__->($x . '03', $k + 2);
            }
        }
    }
}

sub generate_from_suffix ($root, $k) {

    #~ say "$k -> $root";

    if ($k >= 4) {
        say "k = $k -> $root";

        extract_special_primes($root);

        if ($root =~ /03\z/) {
            foreach my $p (@suffix_primes) {
                if (is_prob_prime($root . '0' . $p) and isok($root . '0' . $p)) {
                    die "Found: $root 0 $p";
                }
            }
        }

        if ($k >= 5) {
            die "Found: $root";
        }
    }

    foreach my $p (@primes) {
        my $x = join('0', $p, $root);

        if (is_prob_prime($x)) {

            if ($k >= 4) {
                if (isok($x)) {
                    die "Found: $x";
                }
                else {
                    next;
                }
            }

            if (is_prob_prime('30' . $x) and isok('30' . $x)) {
                __SUB__->('30' . $x, $k + 2);
            }
        }
    }
}

# Prefix/Suffix small prime from 1123
# Tested from p = 2 up to 2159793272 with k = 2
#<<<

#~ foreach (shuffle grep { $_ > 1e10 } @primes) {
    #~ if (is_prob_prime($_ . '03') and is_prob_prime('30' . $_)) {
        #~ say "Testing prefix: $_";
        #~ generate_from_prefix('30' . $_ . '03', 2);
    #~ }

    #~ if (is_prob_prime('30' . $_) and is_prob_prime($_ . '03')) {
        #~ say "Testing suffix: $_";
        #~ generate_from_suffix('30' . $_ . '03', 2);
    #~ }
#~ }

#~ foreach my $p(shuffle @prefix_primes) {
    #~ say "Testing prefix: $p";
    #~ generate_from_prefix($p .'03', 1);
#~ }

#~ foreach my $p(shuffle @suffix_primes) {
    #~ say "Testing suffix: $p";
    #~ generate_from_suffix('30' . $p, 1);
#~ }

#~ foreach my $p(@{primes(3,100)}) {
    #~ next if $p =~ /0/;
    #~ say "Generating from p = $p";
    #~ generate_from_prefix($p, 0);
    #~ generate_from_suffix($p, 0);
#~ }

#>>>

# Lost some primes in the range 23398179383 to 26425741597.

forprimes {

    if (index($_, '0') == -1) {

        #my $t = "302811723703";

        # 30281172370306703
        # 3067030332163394903

        if (is_prob_prime('30' . $_) and is_prob_prime($_ . '03') and is_prob_prime('30' . $_ . '03')) {
            my $t = "30${_}03";
            generate_from_prefix($t, 2);
            generate_from_suffix($t, 2);
        }

#<<<
        #~ if (is_prob_prime($_ . '03')) {
            #~ say "Testing: $_";
            #~ generate_from_prefix($_ . '03', 1);
        #~ }

        #~ if (is_prob_prime('30' . $_)) {
            #~ say "Testing: $_";
            #~ generate_from_suffix('30' . $_, 1);
        #~ }
#>>>

    }
} 39398226941, 1e11;    # from 39398226941
