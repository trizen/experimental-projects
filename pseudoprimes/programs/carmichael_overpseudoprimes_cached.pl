#!/usr/bin/perl

# Carmichael numbers (A002997) that are also overpseudoprimes to base 2 (A141232).

# First terms of the sequence:
#   65700513721, 168003672409, 459814831561, 13685652197857, 34477679139751, 74031531351121, 92327722290241, 206175669172201, 704077371354601, 1882982959757929, 2901482064497017, 3715607011189609, 5516564718607489, 5636724028491697, 6137426373439681, 14987802403246609

# Let a(n) be the smallest Carmichael number with n prime factors that is also an overpseudoprime to base 2.

# a(3) = 65700513721
# a(4) <= 84286331493236478328609
# a(5) <= 3848515708338676403444146123852434164444641

# Note: all overpseudoprimes to base 2, are also super-pseudoprimes to base 2 (A050217).

# Subsequence of: A291637

# Inspired by:
#   https://oeis.org/A291637
#   https://oeis.org/A063847

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
#use Math::Sidef qw(is_over_psp);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $carmichael_file = "cache/factors-carmichael.storable";
my $super_psp_file  = "cache/factors-superpsp.storable";

my $carmichael = retrieve($carmichael_file);
my $super_psp  = retrieve($super_psp_file);

sub is_over_pseudoprime_fast ($n, $factors) {

    Math::Prime::Util::GMP::is_strong_pseudoprime($n, 2) || return;

    my $gcd = Math::Prime::Util::GMP::gcd(map { ($_ < ~0) ? ($_ - 1) : Math::Prime::Util::GMP::subint($_, 1) } @$factors);

    Math::Prime::Util::GMP::powmod(2, $gcd, $n) eq '1'
      or return;

    my $prev;

    foreach my $p (@$factors) {
        my $zn = znorder(2, $p);
        if (defined($prev)) {
            $zn == $prev or return;
        }
        else {
            $prev = $zn;
        }
    }

    return 1;
}

my %table;

foreach my $n (sort { $a <=> $b } map { Math::GMPz->new($_) } grep { exists $carmichael->{$_} } keys %$super_psp) {

    my @factors = split(' ', $super_psp->{$n});
    my $count   = scalar(@factors);

    next if ($count < 4);
    #is_over_psp($n) || next;
    is_over_pseudoprime_fast($n, \@factors) || next;
    next if (exists $table{$count});

    $table{$count} = $n;
}

foreach my $count (sort { $a <=> $b } keys %table) {
    say "a($count) <= $table{$count}";
}

__END__

a(4) <= 84286331493236478328609
a(5) <= 3157343757823970959759947380425728583752001

# Old upper-bounds:

a(5) <= 3848515708338676403444146123852434164444641
