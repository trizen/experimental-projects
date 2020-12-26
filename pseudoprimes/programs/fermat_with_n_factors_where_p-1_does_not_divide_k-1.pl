#!/usr/bin/perl

# a(n) is the smallest k with n prime factors such that 2^(k-1) == 1 (mod k) and p-1 does not divide k-1 for every prime p dividing k.
# https://oeis.org/A316908

# Known terms:
#   7957, 617093, 134564501, 384266404601, 8748670222601, 6105991025919737, 901196605940857381

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;
use Math::AnyNum qw(is_smooth);

my %seen;
my %table;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if (length($n) > 40);

    is_pseudoprime($n, 2) || next;
    is_smooth($n, 1e5)    || next;

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    my @f = factor($n);
    my $t = $n - 1;

    my $key = scalar(@f);

    if (exists $table{$key}) {
        next if ($n >= $table{$key});
    }

    if (vecany { $t % ($_ - 1) == 0 } @f) {
        next;
    }

    if ($key >= 9) {
        say "a($key) <= $n";
    }

    if (exists $table{$key}) {
        if ($n < $table{$key}) {
            $table{$key} = $n;
        }
    }
    else {
        $table{$key} = $n;
    }
}

say '';

foreach my $n (sort { $a <=> $b } keys %table) {
    say "a($n) <= $table{$n}";
}

__END__
a(2) = 7957
a(3) = 617093
a(4) = 134564501
a(5) = 384266404601
a(6) = 8748670222601
a(7) = 6105991025919737
a(8) = 901196605940857381

# New upper-bounds:

a(9)  <= 797365221484475174021
a(10) <= 1315856103949347820015303981
a(11) <= 6357507186189933506573017225316941
a(12) <= 77822245466150976053960303855104674781
a(13) <= 42864570625001423761497389323695509974049581
a(14) <= 34015651529746754841597629769101132590516759547941
a(15) <= 53986954871543199290951271756765558658193549930487667861

# Old upper-bounds:

a(9) <= 521957994426556057126261
a(9) <= 35092334596330107098253061
a(9) <= 519733504158090289696355563896841
a(9) <= 3929067709870830008475826012909048255937

a(10) <= 520194865399874183191033279741
a(11) <= 6367705347359859876441438377309581
