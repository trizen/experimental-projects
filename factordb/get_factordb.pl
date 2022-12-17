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

use constant {
              USE_TOR_PROXY => 1,    # true to use the Tor proxy to connect to factorDB (127.0.0.1:9050)
             };

my $cache = CHI->new(driver   => 'BerkeleyDB',
                     root_dir => catdir(dirname(rel2abs($0)), 'cache'));

my $mech = WWW::Mechanize::Cached->new(
                                     autocheck     => 1,
                                     show_progress => 0,
                                     stack_depth   => 10,
                                     cache         => $cache,
                                     agent => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0",
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

if (USE_TOR_PROXY) {
    $mech->proxy(['http', 'https'], "socks://127.0.0.1:9050");
}

my $expr = $ARGV[0] || die "usage: perl $0 [NUMBER | EXPR]\n";
$expr = join('', split(' ', $expr));    # remove any whitespace

my $main_url = "http://factordb.com/api?query=" . uri_escape($expr);

my $resp = $mech->get($main_url);

if (not $resp->is_success) {
    $mech->invalidate_last_request;
    $resp = $mech->get($main_url);
}

if (not $resp->is_success) {
    $mech->invalidate_last_request;
    die "Failed to get factors...\n";
}

my $data = eval { from_json($resp->decoded_content) } // do {
    $mech->invalidate_last_request;
    die "Failed to get factors...\n";
};

if ($data->{status} =~ /^(?:C|CF|U|PRP)\z/i) {
    $mech->invalidate_last_request;
}

my @factor_exp = @{$data->{factors}};

foreach my $pp (@factor_exp) {
    foreach my $k (1 .. $pp->[1]) {
        say $pp->[0];
    }
}
