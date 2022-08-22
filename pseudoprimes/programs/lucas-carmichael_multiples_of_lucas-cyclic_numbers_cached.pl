#!/usr/bin/perl

# a(n) = least Lucas-Carmichael number which is divisible by b(n), where {b(n)} (A255602) is the list of all numbers which could be a divisor of a Lucas-Carmichael number.
# https://oeis.org/A253598

# See also:
#   https://oeis.org/A255602

# Couldn't find values for the following multiples: 471 489 579 633 831 849 939 993 997

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $lucas_carmichael_file = "cache/factors-lucas-carmichael.storable";
my $lucas_carmichael      = retrieve($lucas_carmichael_file);

my @lucas_cyclic = grep {
    my $n = $_;
    vecall { gcd($n, $_ + 1) == 1 } factor($n)
} grep { is_square_free($_) } grep { $_ > 469 } grep { $_ % 2 == 1 } (1 .. 2000);

@lucas_cyclic = qw(1191 1623);
my $lucas_cyclic_lcm = Math::Prime::Util::GMP::lcm(@lucas_cyclic);

my $z = Math::GMPz::Rmpz_init();

my %table;

while (my ($n, $value) = each %$lucas_carmichael) {

    if (Math::Prime::Util::GMP::gcd($n, $lucas_cyclic_lcm) eq '1') {
        next;
    }

    Math::GMPz::Rmpz_set_str($z, $n, 10);

    foreach my $c (@lucas_cyclic) {
        if (Math::GMPz::Rmpz_divisible_ui_p($z, $c)) {
            if (not exists $table{$c} or Math::GMPz::Rmpz_cmp($z, $table{$c}) < 0) {
                $table{$c} = Math::GMPz::Rmpz_init_set($z);
            }
        }
    }
}

foreach my $key (sort { $a <=> $b } keys %table) {
    printf("%4d: %25s\n", $key, $table{$key});
}

my @unknown;

foreach my $c (@lucas_cyclic) {
    if (not exists $table{$c}) {
        push @unknown, $c;
    }
}

if (@unknown) {
    say "\nCouldn't find values for the following multiples: @unknown";
}

__END__
1191:     116301812274074491239
1623:     127460742488347071999
