#!/usr/bin/perl

# Carmichael numbers (A002997) that are super-Poulet numbers (A050217).
# https://oeis.org/A291637

# Terms:
#   294409, 1299963601, 4215885697, 4562359201, 7629221377, 13079177569, 19742849041, 45983665729, 65700513721, 147523256371, 168003672409, 227959335001, 459814831561, 582561482161, 1042789205881, 1297472175451, 1544001719761, 2718557844481, 3253891093249, 4116931056001, 4226818060921, 4406163138721, 4764162536641, 4790779641001, 5419967134849, 7298963852041, 8470346587201

# Let a(n) be the smallest Carmichael number with n prime factors that is also a super-Poulet to base 2.

# See also:
#   https://oeis.org/A178997

use 5.020;
use strict;
use warnings;

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my $carmichael_file = "cache/factors-carmichael.storable";
my $super_psp_file = "cache/factors-superpsp.storable";

my $carmichael = retrieve($carmichael_file);
my $super_psp = retrieve($super_psp_file);

my %table;

foreach my $n( sort {$a <=> $b } map{Math::GMPz->new($_)}  grep { exists $carmichael->{$_} } keys %$super_psp) {

    my @factors = split(' ', $super_psp->{$n});
    my $count = scalar(@factors);

    next if ($count <= 4);
    next if (exists $table{$count});

    $table{$count} = $n;
}

foreach my $count (sort { $a <=> $b } keys %table) {
    say "a($count) <= $table{$count}";
}


__END__

a(5) <= 521635331852681575100906881
a(6) <= 2835402730651853232634509813787097410561
a(7) <= 165784025660216242122027716057592895796242004385542265601
