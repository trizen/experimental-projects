#!/usr/bin/perl

# Using Crypt::RSA with a specific private key.

use 5.014;
use Crypt::RSA;

my $rsa = Crypt::RSA->new;
my $key = Crypt::RSA::Key->new;

my ($public, $private) =
  $key->generate(
                 p => "77506098606928780021829964781695212837195959082370473820509360759",
                 q => "97513779050322159297664671238670850085661086043266591739338007321",
                 e => 65537,
                )
  or die "error";

my $cyphertext = <<'EOT';
-----BEGIN COMPRESSED RSA ENCRYPTED MESSAGE-----
Version: 1.99
Scheme: Crypt::RSA::ES::OAEP

eJwBswBM/zEwADE2MgBDeXBoZXJ0ZXh0LE2jxJS1EzMc80kOK+hra1GKnXgQKQgVitIy8NgA7kxn
2u8jNQDvlu0uymNNiu6XVCCn66axGH0IZ9w4Af3K/yRgjObsfA1Q7QqpXNALJ9FFPgYl5rh07cBP
M9kbSH6DynU/5cYgQod2KymjWcIvKx3FkjV4UOGakDnBf1eQp1uwvn3KxDVwTyzPqbMnZvOA06Ec
AfKtyz1hEK/UBXkeMeVrnV5SQQ==
=yTUshDMKN65aPaKAR0OU8g==
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

# Output:

cu343l33nqaekrnw.onion
