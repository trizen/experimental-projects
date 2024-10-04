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

use constant {
              USE_TOR_PROXY => 0,    # true to use the Tor proxy (127.0.0.1:9050)
             };

my $cache_dir = 'cache';

if (not -d $cache_dir) {
    mkdir($cache_dir);
}

my $lwp = LWP::UserAgent::Cached->new(
    timeout       => 60,
    show_progress => 1,
    agent         => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0',
    cache_dir     => $cache_dir,
    ssl_opts      => {verify_hostname => 1, SSL_version => 'TLSv1_3'},

    nocache_if => sub {
        my ($response) = @_;
        my $code = $response->code;
        return 1 if ($code >= 500);                           # do not cache any bad response
        return 1 if ($code == 401);                           # don't cache an unauthorized response
        return 1 if ($response->request->method ne 'GET');    # cache only GET requests
        return;
    },
);

my $lwp_uc = LWP::UserAgent->new(
                                 timeout       => 60,
                                 show_progress => 1,
                                 agent         => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0',
                                 ssl_opts      => {verify_hostname => 1, SSL_version => 'TLSv1_3'},
                                );

{
    state $accepted_encodings = HTTP::Message::decodable();

    $lwp->default_header('Accept-Encoding' => $accepted_encodings);
    $lwp_uc->default_header('Accept-Encoding' => $accepted_encodings);

    require LWP::ConnCache;
    my $cache = LWP::ConnCache->new;
    $cache->total_capacity(undef);    # no limit

    $lwp->conn_cache($cache);
    $lwp_uc->conn_cache($cache);
}

if (USE_TOR_PROXY) {
    $lwp->proxy(['http', 'https'], "socks://127.0.0.1:9050");
    $lwp_uc->proxy(['http', 'https'], "socks://127.0.0.1:9050");
}

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
    if (   $content =~ m{<div class=sectname>KEYWORD</div>\s*<div class=sectbody>\s*.*?<span title="(.*?)">more</span>}
        or $content =~ m{<div class=sectname>KEYWORD</div>\s*<div class=sectbody>\s*.*?<span title="(.*?)">hard</span>}) {
        $more = 1;
    }

    my $author = '';
    my $name   = '';

#<<<
    if (   $content =~ m{.*<div class=sectname>NAME</div>\s*<div class=sectbody>\s*<p class="diffs"><tt><span style="color: #\d+;">(.*?)</span>}s
        or $content =~ m{.*<div class=sectname>NAME</div>\s*<div class=sectbody>\s*<p class="diffs"><tt><del>.*?</del></tt></p>\s*<p class="diffs"><tt>(.*?)</tt></p>}s
        or $content =~ m{.*<div class=sectname>NAME</div>\s*<div class=sectbody>\s*<p class="diffs"><tt><span style="color: #\d+;">(.*?)</span></tt></p>}s
        or $content =~ m{.*<div class=sectname>NAME</div>\s*<div class=sectbody>\s*<p class="diffs"><tt>(.*?)</tt></p>}s) {
        $name = remove_tags($1);
    }
    else {
        warn "Failed to extract name for ID: $id\n";
    }
#>>>

#<<<
    if (   $content =~ m{.*<div class=sectname>AUTHOR</div>\s*<div class=sectbody>\s*<p class="diffs"><tt><span style="color: #\d+;"><a href="/wiki/User:.*?">(.*?)</a>}s
        or $content =~ m{.*<div class=sectname>AUTHOR</div>\s*<div class=sectbody>\s*<p class="diffs"><tt><ins><a href="/wiki/User:.*?">(.*?)</a>}s
        or $content =~ m{.*<div class=sectname>AUTHOR</div>\s*<div class=sectbody>\s*<p class="diffs"><tt><span style="color: #\d+;">(.*?)</span></tt></p>}s
        or $content =~ m{.*<div class=sectname>AUTHOR</div>\s*<div class=sectbody>\s*<p class="diffs"><tt>(.*?)</tt></p>}s
    ) {
        $author = remove_tags($1);
    }
    else {
        warn "Failed to extract author for ID: $id\n";
    }
#>>>

    my $tname = $name;

    if ($more) {
        $tname = "<big><b>$tname</b></big>";
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
