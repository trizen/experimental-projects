#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 08 March 2023
# https://github.com/trizen

# Generate Fermat pseudoprimes from a given multiple, to a given base.

# See also:
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub fermat_pseudoprimes_from_multiple ($base, $m, $callback) {

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();
    my $w = Math::GMPz::Rmpz_init_set_ui($base);

    my $L = znorder($base, $m);

    $m = Math::GMPz->new("$m");
    $L = Math::GMPz->new("$L");

    Math::GMPz::Rmpz_invert($v, $m, $L) || return;

    my $p = Math::GMPz::Rmpz_init_set($v);

    for (my $count = 0; $count < 1e5; ++$count) {

        Math::GMPz::Rmpz_mul_ui($v, $p, $count);
        Math::GMPz::Rmpz_mul($v, $v, $L);
        Math::GMPz::Rmpz_add($v, $v, $p);

        Math::GMPz::Rmpz_mul($v, $v, $m);
        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
        Math::GMPz::Rmpz_powm($u, $w, $u, $v);

        if (Math::GMPz::Rmpz_cmp_ui($u, 1) == 0) {
            $callback->(Math::GMPz::Rmpz_init_set($v));
        }
    }
}

#fermat_pseudoprimes_from_multiple(2, 11*17, sub ($n) { say $n });

my @list;

while (<>) {
    next if /^#/;
    my $n = (split(' '))[-1];
    $n || next;
    $n > 0 or next;
    push @list, $n;
}

forcomb {

    my @nums = @list[@_];
    my $n = vecprod(@nums);

    say "# Processing: $n";
    my @new_terms;
    fermat_pseudoprimes_from_multiple(2, $n, sub($k) {
        if ($k > ~0 and $k != $n) {
            say $k;
        }
        if ($k != $n) {
            push @new_terms, $k;
        }
    });

    foreach my $n (@new_terms) {
        fermat_pseudoprimes_from_multiple(2, $n, sub($k) {
            if ($k > ~0 and $k != $n) {
                say $k;
            }
        });
    }

} scalar(@list), 1;
