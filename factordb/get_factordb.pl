#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 16 December 2019
# https://github.com/trizen

# Extract factors from factordb.com for a given number, using FactorDB's API.

use 5.020;
use warnings;
use experimental qw(signatures);

use CHI;
use JSON qw(from_json);
use WWW::Mechanize::Cached;
use URI::Escape qw(uri_escape);
use File::Basename qw(dirname);
use File::Spec::Functions qw(rel2abs catdir);

my $cache = CHI->new(driver   => 'BerkeleyDB',
                     root_dir => catdir(dirname(rel2abs($0)), 'cache'));

my $mech = WWW::Mechanize::Cached->new(
          autocheck     => 1,
          show_progress => 0,
          stack_depth   => 10,
          cache         => $cache,
          agent => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36",
);

{
    state $accepted_encodings = HTTP::Message::decodable();
    $mech->default_header('Accept-Encoding' => $accepted_encodings);
};

{
    require LWP::ConnCache;
    my $cache = LWP::ConnCache->new;
    $cache->total_capacity(undef);    # no limit
    $mech->conn_cache($cache);
};

my $expr = $ARGV[0] || die "usage: perl $0 [NUMBER | EXPR]\n";
$expr = join('', split(' ', $expr));    # remove any whitespace

my $main_url = "http://factordb.com/api?query=" . uri_escape($expr);

my $resp = $mech->get($main_url);
my $data = from_json($resp->decoded_content);

if ($data->{status} =~ /^(?:C|CF|U|PRP)\z/i) {
    $mech->invalidate_last_request;
}

my @factor_exp = @{$data->{factors}};

foreach my $pp (@factor_exp) {
    foreach my $k (1 .. $pp->[1]) {
        say $pp->[0];
    }
}
