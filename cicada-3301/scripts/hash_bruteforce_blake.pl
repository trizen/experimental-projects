#!/usr/bin/perl

# Try to find an IP address that matches the Cicada LP hash.

use 5.036;
use Digest::BLAKE qw(blake_512_hex);

my $from = 3;   # tested up to this point

foreach my $i ($from .. 255) {
    say "i = $i";
    foreach my $j (0 .. 255) {
        foreach my $k (0 .. 255) {
            foreach my $l (0 .. 255) {
                my $digest = blake_512_hex("$i.$j.$k.$l");
                say "$i.$j.$k.$l";
                die $digest;
                if ($digest eq
                    '36367763ab73783c7af284446c59466b4cd653239a311cb7116d4618dee09a8425893dc7500b464fdaf1672d7bef5e891c6e2274568926a49fb4f45132c2a8b4') {
                    die "Found: $i.$j.$k.$l";
                }
            }
        }
    }
}
