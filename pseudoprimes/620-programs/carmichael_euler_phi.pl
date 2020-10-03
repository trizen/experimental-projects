#!/usr/bin/perl

use 5.014;
use strict;
use warnings;

use Math::GMPz;
use Math::Prime::Util::GMP qw(totient is_carmichael);
use experimental qw(signatures);

sub big_euler_phi ($n) {

    if (length("$n") > 50) {

        say "Big input: ", length($n), " digits";

        my $res = eval {
            local $SIG{ALRM} = sub { die "alarm\n" };
            alarm 30;
            chomp(my $test = `$^X -MMath::Prime::Util::GMP=totient -E 'say totient("$n")'`);
            alarm 0;
            return Math::GMPz->new($test);
        };

        return $res if defined($res);
        return undef;
    }

    say "Small input: $n";

    Math::GMPz->new(totient($n));
}


my %seen;
while (<>) {
    /\S/ || next;

  #  /Fermat/ or next;

    if (/: (\d+)$/) {

        next if $seen{$1}++;

        my $n = Math::GMPz->new($1);

        is_carmichael($n) || next;
        my $phi = big_euler_phi($n) // next;

        say "phi($n) = $phi";

        if (($n-1)% $phi == 0) {
            die "Found counter-example: $n";
        }
    }
}
