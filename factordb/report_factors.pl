#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 20 December 2019
# https://github.com/trizen

# Report factorizations to factordb.

# The factorizations must be specfied in the "factors.txt" and "numbers.txt" files, using the following format:
#   index number

# Example for "numbers.txt":
#   1 340282366920938463463374607431768211457
#   2 115792089237316195423570985008687907853269984665640564039457584007913129639937

# Example for "factors.txt":
#   1 5704689200685129054721
#   2 93461639715357977769163558199606896584051237541638188580280321

use 5.020;
use autodie;
use warnings;

use WWW::Mechanize;
use Math::AnyNum qw(:overload :all);
use experimental qw(signatures);

use constant {
              USE_TOR_PROXY => 1,    # true to use the Tor proxy to connect to factorDB (127.0.0.1:9050)
             };

my $mech = WWW::Mechanize->new(
                               autocheck     => 1,
                               show_progress => 1,
                               stack_depth   => 10,
                               timeout       => 600,
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

sub collect_kv ($line, $hash) {
    chomp $line;
    if ($line =~ /^\s*(\d+)\s+(\d+)/) {
        $hash->{$1} = Math::AnyNum->new($2);
    }
    else {
        warn ":: Cannot parse: <<$line>>\n";
    }
}

my $url = "http://factordb.com/search.php";

my %factors;
my %numbers;

open my $factor_fh, '<', 'factors.txt';
open my $number_fh, '<', 'numbers.txt';

while (<$factor_fh>) {
    collect_kv($_, \%factors);
}

while (<$number_fh>) {
    collect_kv($_, \%numbers);
}

my @list;

foreach my $n (sort { $a <=> $b } keys %factors) {

    my $m = $numbers{$n};
    my $f = $factors{$n};

    $m > 1 or next;
    $f > 1 or next;

    say "$m -> $f";
    is_div($m, $f) or die "error factor $f for n = $n";
    push @list, "$m = $f";
}

my $factor_table = join("\n", @list);

$mech->get($url);

my $resp = $mech->submit_form(
                              form_number => 1,
                              fields      => {
                                         'msub' => $factor_table,
                                        }
                             );

if ($resp->is_success) {
    say ":: Done...";
}
else {
    die ":: There was an error...\n";
}
