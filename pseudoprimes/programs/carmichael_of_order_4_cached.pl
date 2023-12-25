#!/usr/bin/perl

# Are there any examples of p^2+1|N^2+1 for all p|n?

# Problem from:
#   https://math.stackexchange.com/questions/3513820/carmichael-numbers-of-order-4

use 5.036;
use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;

my $storable_file = "cache/factors-carmichael.storable";
#my $storable_file = "cache/factors-lucas-carmichael.storable";
my $table         = retrieve($storable_file);

my $n = Math::GMPz::Rmpz_init();
my $p = Math::GMPz::Rmpz_init();

my $one = Math::GMPz::Rmpz_init_set_ui(1);

while (my ($key, $value) = each %$table) {

    Math::GMPz::Rmpz_set_str($n, $key, 10);
    Math::GMPz::Rmpz_mul($n, $n, $n);
    Math::GMPz::Rmpz_add_ui($n, $n, 1);

    if (
        vecall {
            ($_ < ~0)
                ? Math::GMPz::Rmpz_set_ui($p, $_)
                : Math::GMPz::Rmpz_set_str($p, "$_", 10);
            Math::GMPz::Rmpz_mul($p, $p, $p);
            Math::GMPz::Rmpz_add_ui($p, $p, 1);
            #Math::GMPz::Rmpz_mul($p, $p, $p);
            #Math::GMPz::Rmpz_sub_ui($p, $p, 1);
            #Math::GMPz::Rmpz_congruent_p($n, $one, $p);
            Math::GMPz::Rmpz_divisible_p($n, $p);
        }
        split(' ', $value)
      ) {
        say $n;
    }
}

__END__

# No such number is known...
