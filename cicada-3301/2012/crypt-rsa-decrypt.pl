#!/usr/bin/perl

# Using Crypt::RSA with a specific private key.

use 5.014;
use Crypt::RSA;

my $rsa = Crypt::RSA->new;
my $key = Crypt::RSA::Key->new;

my ($public, $private) =
  $key->generate(
                 p => "80411114232571782218163489375797613948878398942588985417",
                 q => "98007492061325958997349177934627388613835953553459586261",
                 e => 65537,
                )
  or die "error";

my $cyphertext = <<'EOT';
-----BEGIN COMPRESSED RSA ENCRYPTED MESSAGE-----
Version: 1.99
Scheme: Crypt::RSA::ES::OAEP

eJwBzQAy/zEwADE4OABDeXBoZXJ0ZXh0Ca4y//uzl/HvFoP9Klf53nEFH0T4c+ui5de8+vqGOnZc
9DlrsWQe+xxVaPaYgKAD9Wn9VWQ6A5o254r5pa4hkDIY5RRmVfqOm88HJpGdbGGTckyEwJapCLDT
tHzZWAZ0FIVj6fH2whErHoVmZ82zQJ64OLtzr1gYk+2kIZuqtLclV9RDhs6j7meTaod2BDrF26tY
d33awv0txxrgXRhd/FDFVtKb0K84cQs2xtO/9A0yLs5GEK2xpG2yM4AeWWft
=I1r6Wtzf/29vTggAK+ELEA==
-----END COMPRESSED RSA ENCRYPTED MESSAGE-----
EOT

#~ my $cyphertext = $rsa->encrypt(
                               #~ Message => "Hello world!",
                               #~ Key     => $public,
                               #~ Armour  => 1,
                              #~ )
  #~ || die $rsa->errstr();

#~ say $cyphertext;

my $plaintext = $rsa->decrypt(
                              Cyphertext => $cyphertext,
                              Key        => $private,
                              Armour     => 1,
                             )
  || die $rsa->errstr();

say $plaintext;

__END__
33521494043430258676
