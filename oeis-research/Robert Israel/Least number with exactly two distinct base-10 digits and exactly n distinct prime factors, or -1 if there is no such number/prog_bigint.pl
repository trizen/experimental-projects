#!/usr/bin/perl

# a(n) is the least number with exactly two distinct base-10 digits and exactly n distinct prime factors, or -1 if there is no such number.
# https://oeis.org/A386761

# Known terms:
#   13, 10, 30, 330, 6006, 30030, 1111110, 200222022, 1001110110, 955559599995, 1000110001000110, 11011101101110110, 11111100000101111010

use 5.036;
use Sidef                    qw();
use Math::Sidef              qw();
use Algorithm::Combinatorics qw(variations_with_repetition);

sub a($n, $from = 2) {

    $n = Sidef::Types::Number::Number->new($n);

    for (my $d = $from ; ; $d++) {

        say ":: Searching for a($n) with $d digits...";

        for my $f ('1' .. '9') {

            my $min = undef;

            for my $r ('0' .. '9') {
                next if $f eq $r;
                my $iter = variations_with_repetition([$f, $r], $d - 1);
                while (my $suffix = $iter->next) {

                    my $t = join('', $f, @$suffix);

                    if (length($t =~ tr/0-9/0-9/sr) != 1) {
                        $t = Math::GMPz::Rmpz_init_set_str($t, 10);
                        if ((!defined($min) or $t < $min) and (bless(\$t, 'Sidef::Types::Number::Number'))->is_omega_prime($n)) {
                            $min = $t;
                            say "Candidate: $t";
                        }
                    }
                }
            }

            return $min if defined($min);
        }
    }
}

foreach my $n (1 .. 10) {
    say "a($n) = ", a($n);
}

# Search for a(14)
say a(14, 18);

__END__
a(1) = 13
a(2) = 10
a(3) = 30
a(4) = 330
a(5) = 6006
a(6) = 30030
a(7) = 1111110
a(8) = 200222022
a(9) = 1001110110
a(10) = 955559599995
a(11) = 1000110001000110
a(12) = 11011101101110110
a(13) = 11111100000101111010
a(14) = 200220200202022022022

:: Searching for a(14) with 20 digits...
:: Searching for a(14) with 21 digits...
Candidate: 200220200202022022022
200220200202022022022
perl prog_bigint.pl  1819.55s user 0.79s system 59% cpu 51:13.77 total
