#!/usr/bin/perl

# Using Crypt::RSA to decrypt a message, using an explicitly given private key.

use 5.014;
use Crypt::RSA;

my $rsa = Crypt::RSA->new;
my $key = Crypt::RSA::Key->new;

my ($public, $private) =
  $key->generate(
                 p => "99554414790940424414351515490472769096534141749790794321708050837",
                 q => "104593961812606247801193807142122161186583731774511103180935025763",
                 e => 65537,
                )
  or die "error";

my $cyphertext = <<'EOT';
-----BEGIN COMPRESSED RSA ENCRYPTED MESSAGE-----
Version: 1.99
Scheme: Crypt::RSA::ES::OAEP

eJwBRgC5/zEwADU0AEN5cGhlcnRleHTCFSi7dhQG4Pgmh50LyX1mGRFKbuZmdMkJW/iL5YJZHnww
ECaj7l2udOqtc9L8qlsvZh24DSzKYh3A
=+3dVm5h8VAg/3eTrYvDjNw==
-----END COMPRESSED RSA ENCRYPTED MESSAGE-----
EOT

#~ my $cyphertext = $rsa->encrypt(
                               #~ Message => $message,
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

say $plaintext;     # the game
