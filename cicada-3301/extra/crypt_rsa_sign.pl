#!/usr/bin/perl

# Using Crypt::RSA to sign a message, using an explicitly given private key.

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

my $message = "Hello world!";

my $signature = $rsa->sign(
                           Message => $message,
                           Key     => $private,
                           Armour  => 1,
                          )
  || die $rsa->errstr();

say $signature;

my $plaintext = $rsa->verify(
                             Signature => $signature,
                             Message   => $message,
                             Key       => $public,
                             Armour    => 1,
                            )
  || die $rsa->errstr();

say ("Valid signature: ", ($plaintext ? "yes" : "no"));

#~ $public->write ( Filename => 'cicada.public' );
#~ $private->write ( Filename => 'cicada.private' );

__END__
-----BEGIN RSA SIGNATURE-----
Version: 1.99
Scheme: Crypt::RSA::SS::PSS

OQA1NABTaWduYXR1cmXV7WLmAUf4OxAMgmi7zg+29Mkp01JE3wrrBFoycR4q5WuaHyahJUwugSW/
84TmB5IZ2Z3TPEw=
=8zvlSo9cU7Merm4hrEJboQ==
-----END RSA SIGNATURE-----
