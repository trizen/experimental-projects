#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 09 December 2019
# https://github.com/trizen

# Extract factors from factordb.com for a given number, by scrapping the website.
# Do NOT use this script! Use "get_factordb.pl" instead, which uses FactorDB's API.

use 5.020;
use warnings;
use experimental qw(signatures);

use CHI;
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

sub extract_from_id ($id) {

    my $resp = $mech->get("http://factordb.com/index.php?showid=$id");

    if ($resp->decoded_content =~ m{<td align="center">Number</td>\s*<td align="center">(.*?)</td>}s) {

        my $number = $1;

        $number =~ s/<(.*?)>//g;
        $number = join('', split(' ', $number));

        return $number;
    }

    $mech->invalidate_last_request;
    die "Failed to extract number from ID = $id\n";
}

my $expr = $ARGV[0] || die "usage: perl $0 [NUMBER | EXPR | URL]\n";
$expr = join('', split(' ', $expr));    # remove any whitespace

my $main_url = "http://factordb.com/index.php?query=" . uri_escape($expr);

if ($expr =~ m{^http://factordb\.com/}) {
    $main_url = $expr;
}

my $resp    = $mech->get($main_url);
my $content = $resp->decoded_content;

if ($content =~ m{ = \(?(<a href=".*?</td>)}) {
    my $factor_data = $1;

    # Invalidate request if `n` is not fully factorized.
    if (   $content =~ m{<td>(?:CF|C|U)\s*(?:<font color="#FF0000">\*</font>)?</td>}
        or $factor_data =~ m{<font color="#002099">}) {
        $mech->invalidate_last_request;
    }

    my @factors;
    while ($factor_data =~ m{<a href="index\.php\?id=(\d+)"><font color="#(\d+)">([\d.^]+)</font></a>}g) {
        my ($id, $color, $n) = ($1, $2, $3);

        my $is_prime = ($color eq '000000');

        my $pow = 1;
        if ($n =~ s/\^(\d+)\z//) {
            $pow = $1;
        }

        if ($n =~ /\./) {
            push @factors, (extract_from_id($id)) x $pow;
        }
        else {
            if ($is_prime) {
                push @factors, ($n) x $pow;
            }
            else {
                require Math::Prime::Util;
                my @f = Math::Prime::Util::factor($n);
                push @factors, (@f) x $pow;
            }
        }
    }

    if ($content =~ m{\)\^(\d+)</td>}) {
        @factors = (@factors) x $1;
    }

    say for @factors;
}
else {
    $mech->invalidate_last_request;
    die "Failed: $main_url\n";
}
