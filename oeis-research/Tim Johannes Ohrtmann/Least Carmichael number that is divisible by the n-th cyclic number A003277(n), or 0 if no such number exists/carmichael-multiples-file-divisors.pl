#!/usr/bin/env perl

use 5.036;
use strict;
use warnings;

use Math::GMPz;
use Math::Prime::Util qw(is_square_free euler_phi gcd divisors factor_exp);
use Math::Prime::Util::GMP;

# Path to your sorted file of Carmichael numbers
my $filename = $ARGV[0];
my $LIMIT    = 32753;

# 1. Pre-collect all valid odd m <= 32753 as native integers
my %active_m;
my $M_LCM = Math::GMPz::Rmpz_init_set_ui(1);

say "Collecting valid m values up to $LIMIT...";

for (my $m_val = 3 ; $m_val <= $LIMIT ; $m_val += 2) {

    # Check conditions:
    # 1. m is squarefree
    # 2. gcd(m, euler_phi(m)) == 1

    if (is_square_free($m_val)) {

        my $phi = euler_phi($m_val);
        my $g   = gcd($m_val, $phi);

        if ($g == 1) {
            $active_m{$m_val} = 1;
            Math::GMPz::Rmpz_mul_ui($M_LCM, $M_LCM, $m_val);
        }
    }
}

say "Found " . keys(%active_m) . " valid m values to check. Starting single-pass file scan...";

sub divisors_mpz ($n, $limit) {
    state $g = Math::GMPz::Rmpz_init_nobless();
    Math::GMPz::Rmpz_gcd($g, $n, $M_LCM);

    # No relevant small prime factors shared with M_LCM
    return () if Math::GMPz::Rmpz_cmp_ui($g, 1) <= 0;

    # Factor the small co-factor $g using Math::Prime::Util (backed by MPU::GMP)
    # Since all m in M_LCM are squarefree, we only care about distinct primes ($pp->[0])
    my @primes = map { $_->[0] } factor_exp(Math::GMPz::Rmpz_get_str($g, 10));

    # Build all squarefree divisors <= $limit
    my @d = (1);
    foreach my $p (@primes) {
        my @t;
        foreach my $u (@d) {
            my $val = $u * $p;
            push @t, $val if $val <= $limit;
        }
        push @d, @t;
    }

    return @d;
}

# 2. Single pass over the file
open my $fh, '<', $filename or die "Could not open '$filename': $!";

sub log_term ($multiple, $term) {
    open my $fh, '>>', 'final_carm_multiples.txt';
    print $fh "$multiple $term\n";
    close $fh;
}

my $c_gmp = Math::GMPz::Rmpz_init();

while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/;    # Skip empty lines

    #last if $line > 1e16;
    # 1e16 -- 1.7s
    # 1e17 -- 4.9s

    if ($line < 1e16) {

        # Generate only the divisors of C that are <= 32753
        my @divs = divisors($line, $LIMIT);

        foreach my $d (@divs) {
            if ($active_m{$d}) {
                say "m = $d -> Smallest multiple in file: $line";
                log_term($d, $line);
                # Since the file is sorted, the first multiple we find is the smallest.
                # Remove it from active list so we don't overwrite it.
                delete $active_m{$d};
                Math::GMPz::Rmpz_divexact_ui($M_LCM, $M_LCM, $d);
                #recompute_lcm();
            }
        }
    }
    else {

        Math::GMPz::Rmpz_set_str($c_gmp, $line, 10);

        my @divs = divisors_mpz($c_gmp, $LIMIT);

        foreach my $d (@divs) {
            if ($active_m{$d}) {
                say "m = $d -> Smallest multiple in file: $c_gmp";
                log_term($d, $line);

                # Since the file is sorted, the first multiple we find is the smallest.
                # Remove it from active list so we don't overwrite it.
                delete $active_m{$d};
                Math::GMPz::Rmpz_divexact_ui($M_LCM, $M_LCM, $d);
            }
        }
    }

    # Early exit if we have found multiples for all active m values
    last unless keys %active_m;
}

close $fh;

__END__
# Report any valid m values that did not find a multiple in the file
foreach my $m_val (sort { $a <=> $b } keys %active_m) {
    say "m = $m_val -> No multiple found in file.";
}
