#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 07 April 2019
# https://github.com/trizen

# Get the list of OEIS drafts and generate an HTML file, highlighting the sequences that need more terms.

use 5.014;
use strict;
use warnings;

use LWP::UserAgent::Cached;
use HTML::Entities qw(decode_entities encode_entities);

require LWP::UserAgent;
require HTTP::Message;

my $cache_dir = 'cache';

if (not -d $cache_dir) {
    mkdir($cache_dir);
}

my $lwp = LWP::UserAgent::Cached->new(
    timeout       => 60,
    show_progress => 1,
    agent     => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36',
    cache_dir => $cache_dir,

    nocache_if => sub {
        my ($response) = @_;
        my $code = $response->code;
        return 1 if ($code >= 500);                               # do not cache any bad response
        return 1 if ($code == 401);                               # don't cache an unauthorized response
        return 1 if ($response->{_request}{_method} ne 'GET');    # cache only GET requests
        return;
    },
);

my $lwp_uc = LWP::UserAgent->new(
           timeout       => 60,
           env_proxy     => 0,
           show_progress => 1,
           agent => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36",
           ssl_opts => {verify_hostname => 1, SSL_version => 'TLSv1_2'},
);

state $accepted_encodings = HTTP::Message::decodable();

$lwp->default_header('Accept-Encoding' => $accepted_encodings);
$lwp_uc->default_header('Accept-Encoding' => $accepted_encodings);

require LWP::ConnCache;
my $cache = LWP::ConnCache->new;
$cache->total_capacity(undef);    # no limit

$lwp->conn_cache($cache);
$lwp_uc->conn_cache($cache);

my @all_ids;
my $start = 0;

while (1) {
    my $content = $lwp_uc->get("https://oeis.org/draft?start=$start")->decoded_content;

    my @ids;
    while ($content =~ m{<td><a href="/draft/(A\d+)">A\d+</a>}g) {
        push @ids, $1;
    }

    @ids || last;
    push @all_ids, @ids;
    $start += 100;
}

say "Found: ", scalar(@all_ids), " ids";

open my $fh, '>:utf8', 'links.html';

print $fh <<'EOF';

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>

  <head>
  <style>
  tt { font-family: monospace; font-size: 100%; }
  p.editing { font-family: monospace; margin: 10px; text-indent: -10px; word-wrap:break-word;}
  p { word-wrap: break-word; }
  </style>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <title>OEIS links</title>
  </script>
  </head>
  <body bgcolor=#ffffff>

EOF

#~ say $fh "<ul>";

sub remove_tags {
    my ($str) = @_;
    $str =~ s/<.*?>//gs;
    join(' ', split(' ', $str));
}

my $k = 1;
foreach my $id (@all_ids) {
    my $url     = "https://oeis.org/draft/$id";
    my $content = $lwp->get($url)->decoded_content;

    my $more = 0;
    if (
           $content =~ m{<span title="(.*?)">more</span>}
        or $content =~ m{<span title="(.*?)">hard</span>}
      ) {
        $more = 1;
    }

    my $author = '';
    my $name   = '';

    if ($content =~ m{.*<font size=-2>NAME</font>.*?(?!<tt>\s*<del>)<tt>(.*?)</tt>}s) {
        $name = remove_tags($1);
    }

    if ($content =~ m{.*<font size=-2>AUTHOR</font>.*?<ins>(.*?)</ins>}s) {
        $author = remove_tags($1);
    }

    my $tname = $name;

    if ($more) {
        $tname = "<b>$tname</b>";
    }

    say $fh "<pre>" . $tname . " -- $author</pre>";
    say $fh "<ul>";
    say $fh "<li> [$k] <a href=$url>$url</a> </li>";
    say $fh "</ul>";

    #say $fh "<li>[$k] <a href=$url>$url</a><br> -- $name -- $author</li>";
    ++$k;
}

#~ say $fh "</ul>";
say $fh "</body></html>";
