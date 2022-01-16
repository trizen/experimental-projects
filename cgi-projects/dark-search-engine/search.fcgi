#!/usr/bin/perl

# Author: Trizen
# Date: 08 January 2022
# Edit: 15 January 2022
# https://github.com/trizen

# A private search engine, with its own crawler running over Tor (respecting robots.txt).

# Using some HTML and CSS code from the searX project (++):
#   https://github.com/searx/searx

# To crawl an website, pass it as an argument to this script.
# By default, depth = 0. Use --depth=i to increase the crawling depth.

# Example:
#   perl search.fcgi --depth=i [URL]

# Other script options:
#   --recrawl           : activate recrawl mode
#   --fix-index         : fix the index in case it gets messed up (slow operation)
#   --sanitize-index    : sanitize the index and show some stats

# To repair a database, in case it gets corrupted, use:
#   $ gdbmtool [filename.db]
#   gdbmtool> recover summary
#   gdbmtool> quit

# The index database grows quite large over time. To optimize its size, run:
#   $ gdbmtool [filename.db]
#   gdbmtool> reorganize
#   gdbmtool> quit

# Limitations:
#   - the search engine cannot be used while the crawler is being used
#   - the crawler cannot be used while the search engine is being used

use utf8;
use 5.020;
use strict;
use warnings;

#use autodie;

no warnings qw(once);
use experimental qw(signatures);

use CGI::Fast;
use CGI qw/:standard *table -utf8/;

#use CGI::Carp qw(fatalsToBrowser);

#use IO::Compress::Zstd qw(zstd);
#use IO::Uncompress::UnZstd qw(unzstd);
#use URI::Escape qw(uri_escape_utf8);

use WWW::Mechanize;
use File::Basename qw(dirname);
use File::Spec::Functions qw(rel2abs catdir);
use Text::Unidecode qw(unidecode);
use HTML::Entities qw(encode_entities);
use WWW::RobotRules;
use LWP::Simple qw(get);
use Time::HiRes qw(gettimeofday tv_interval);

use ntheory qw(forcomb);
use List::Util qw(uniq max);

#use JSON::XS qw(decode_json encode_json);

use Storable qw(freeze thaw);
use Encode qw(decode_utf8 encode_utf8);
use Digest::xxHash qw(xxhash32_hex);

use constant {

    # Cache HTML content (using CHI and WWW::Mechanize::Cached)
    CACHE => 0,

    # Use Tor proxy for crawling (127.0.0.1:9050)
    USE_TOR => 1,

    # Compress the values of the content database with Zstandard
    # When enabled, the content database will be ~3x smaller
    USE_ZSTD => 1,

    # xxHash seed (don't change it)
    XXHASH_SEED => 42,

    # Minimum and maximum number of characters for words stored in the index
    WORD_MIN_LEN => 3,
    WORD_MAX_LEN => 45,

    # Maximum number of top best search results to return
    MAX_SEARCH_RESULTS => 100,

    # Show the description of each website in search results (if available)
    # When disabled, a snippet of the content will be shown instead
    SHOW_DESCRIPTION => 1,

    # Respect the rules from robots.txt
    RESPECT_ROBOT_RULES => 1,

    # Rank the results based on content of the pages (better ranking, but it's much slower)
    RANK_ON_CONTENT => 1,

    # Rank the results based on boundary matches (with \b)
    RANK_ON_BOUNDARY_MATCH => 1,

    # Rank the results based on non-boundary matches (without \b)
    RANK_ON_NON_BOUNDARY_MATCH => 0,

};

# Ignore these words in search requests, as too many websites contain them
my %too_common_words;
@too_common_words{
    qw(
      and for you not the this with are about
      that from can all more have what your they
      )
} = ();

# List of tracking query parameters to remove from URLs
my @tracking_parameters = qw(

  yclid fbclid gclsrc

  utm_source utm_medium utm_term
  utm_content utm_campaign utm_referrer

  __hssc __hstc __s _hsenc _openstat dclid fb_ref gclid
  hsCtaTracking igshid mc_eid mkt_tok ml_subscriber ml_subscriber_hash
  msclkid oly_anon_id oly_enc_id rb_clickid s_cid vero_conv vero_id wickedid

);

binmode(STDOUT, ':utf8');
binmode(STDIN,  ':utf8');
binmode(STDERR, ':utf8');

if (USE_ZSTD) {
    require IO::Compress::Zstd;
    require IO::Uncompress::UnZstd;
}

my %hostname_alternatives = (
                             youtube => 'yewtu.be',
                             reddit  => 'teddit.net',
                             medium  => 'scribe.rip',
                             twitter => 'nitter.net',
                            );

my $cookie_file     = 'cookies.txt';
my $crawled_db_file = "crawled.db";
my $index_db_file   = "index-content.db";

$index_db_file   = xxhash32_hex($index_db_file,   XXHASH_SEED) . ".db";
$crawled_db_file = xxhash32_hex($crawled_db_file, XXHASH_SEED) . ".db";

use GDBM_File;

#my $GDBM_OPTIONS = &GDBM_WRCREAT | &GDBM_SYNC;
#my $GDBM_OPTIONS = &GDBM_WRCREAT;

my $GDBM_OPTIONS = &GDBM_READER;

if (@ARGV) {

    #$GDBM_OPTIONS = &GDBM_WRCREAT | &GDBM_SYNC;
    $GDBM_OPTIONS = &GDBM_WRCREAT;
}

tie(my %CONTENT_DB, 'GDBM_File', $crawled_db_file, $GDBM_OPTIONS, 0777)
  or die "Can't create/access database <<$crawled_db_file>>: $!";

tie(my %WORDS_INDEX, 'GDBM_File', $index_db_file, $GDBM_OPTIONS, 0777)
  or die "Can't create/access database <<$index_db_file>>: $!";

#eval { require GDBM_File };
#~ eval { require DB_File };

#~ dbmopen(my %CONTENT_DB, $crawled_db_file, 0777)
#~ or die "Can't create/access database <<$crawled_db_file>>: $!";

#~ dbmopen(my %WORDS_INDEX, $index_db_file, 0777)
#~ or die "Can't create/access database <<$index_db_file>>: $!";

#~ use DB_File;

#~ tie(my %CONTENT_DB, 'DB_File', $crawled_db_file, O_CREAT|O_RDWR, 0777)
#~ or die "Can't create/access database <<$crawled_db_file>>: $!";

#~ tie(my %WORDS_INDEX, 'DB_File', $index_db_file, O_CREAT|O_RDWR, 0777)
#~ or die "Can't create/access database <<$index_db_file>>: $!";

my $mech;
my %mech_options = (
                    timeout       => 20,
                    autocheck     => 0,
                    show_progress => 1,
                    stack_depth   => 10,
                    cookie_jar    => {},
                    agent         => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0",
                   );

if (CACHE) {

    require CHI;
    require WWW::Mechanize::Cached;

    my $cache = CHI->new(driver   => 'BerkeleyDB',
                         root_dir => catdir(dirname(rel2abs($0)), 'cache'));

    $mech = WWW::Mechanize::Cached->new(%mech_options, cache => $cache);

}
else {
    $mech = WWW::Mechanize->new(%mech_options);
}

if (USE_TOR) {    # set Tor proxy
    $mech->proxy(['http', 'https'], "socks://127.0.0.1:9050");
}

# Support for cookies from file
if (defined($cookie_file) and -f $cookie_file) {

    ## Netscape HTTP Cookies

    # Firefox extension:
    #   https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/

    # See also:
    #   https://github.com/ytdl-org/youtube-dl#how-do-i-pass-cookies-to-youtube-dl

    require HTTP::Cookies::Netscape;

    my $cookies = HTTP::Cookies::Netscape->new(
                                               hide_cookie2 => 1,
                                               autosave     => 1,
                                               file         => $cookie_file,
                                              );

    $cookies->load;
    $mech->cookie_jar($cookies);
}

my $robot_rules = WWW::RobotRules->new($mech->agent);

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

sub extract_words ($text) {
    grep { length($_) >= WORD_MIN_LEN and length($_) <= WORD_MAX_LEN and /[[:alnum:]]/ }
      uniq(split(/[_\W]+/, CORE::fc($text)));
}

sub encode_content_entry ($entry) {

    if (USE_ZSTD) {
        my $json_data = freeze($entry);

        IO::Compress::Zstd::zstd(\$json_data, \my $zstd_data)
          or die "zstd failed: $IO::Compress::Zstd::ZstdError\n";

        return $zstd_data;
    }

    freeze($entry);
}

sub decode_content_entry ($entry) {

    if (USE_ZSTD) {

        IO::Uncompress::UnZstd::unzstd(\$entry, \my $json_data)
          or die "unzstd failed: $IO::Uncompress::UnZstd::UnZstdError\n";

        return thaw($json_data);
    }

    thaw($entry);
}

sub surprise_me {

    while (my ($word, $value) = each %WORDS_INDEX) {
        if (length($word) >= 5 and rand() < 0.1) {
            my $ref_count = ($value =~ tr/ //);
            if ($ref_count >= 10 and $ref_count <= 1000) {
                return $word;
            }
        }
    }

    return undef;
}

sub sanitize_url ($url) {

    # Replace some bad hostnames with better alternatives

    my $protocol = '';

    if ($url =~ m{^(https?://)(.+)}s) {
        $protocol = $1;
        $url      = $2;
    }

    # Normalize the URL
    ## $url = normalize_url($protocol . $url);

    # YouTube
    $url =~ s{^(?:www\.)?youtube\.com(?=[/?])}{$hostname_alternatives{youtube}};
    $url =~ s{^(?:www\.)?youtu\.be(?=[/?])}{$hostname_alternatives{youtube}};

    # Reddit (doesn't work for comments)
    ## $url =~ s{^(?:www\.)?reddit\.com(?=[/?])}{$hostname_alternatives{reddit}};

    # Twitter
    $url =~ s{^(?:www\.)?twitter\.com(?=/\w+\z)}{$hostname_alternatives{twitter}};
    $url =~ s{^(?:www\.)?twitter\.com(?=/\w+/status/)}{$hostname_alternatives{twitter}};

    # Medium
    $url =~ s{^(?:www\.)?medium\.com(?=[/?])}{$hostname_alternatives{medium}};

    return ($protocol . $url);
}

sub normalize_url ($url) {

    #$url =~ s/#.*//sr =~ s{^https?://(?:www\.)?}{}r =~ s{/+\z}{}r;

    require URL::Normalize;

    my $normalizer = URL::Normalize->new(url => $url);

    # Remove tracking query parameters
    $normalizer->remove_query_parameters(\@tracking_parameters);

    my $normalize = sub ($url, $method) {
        my $obj = URL::Normalize->new(url => $url);
        $obj->$method;
        $obj->url;
    };

    my $normalized_url = $normalizer->url;

    foreach my $method (
                        qw(
                        remove_directory_index
                        remove_empty_query
                        remove_fragment
                        remove_fragments
                        remove_duplicate_slashes
                        make_canonical
                        sort_query_parameters
                        remove_empty_query_parameters
                        )
      ) {
        $normalized_url = $normalize->($normalized_url, $method);
    }

    # Remove the protocol
    $normalized_url =~ s{^https?://}{};

    return $normalized_url;
}

sub add_to_database_index ($text, $key) {

    foreach my $word (extract_words($text)) {
        if (exists $WORDS_INDEX{$word}) {
            $WORDS_INDEX{$word} .= ' ' . $key;
        }
        else {
            $WORDS_INDEX{$word} = $key;
        }
    }

    return 1;
}

sub readd_to_database_index ($text, $key) {

    foreach my $word (extract_words($text)) {
        if (exists $WORDS_INDEX{$word}) {
            $WORDS_INDEX{$word} = join(' ', uniq(split(' ', $WORDS_INDEX{$word}), $key));
        }
        else {
            $WORDS_INDEX{$word} = $key;
        }
    }

    return 1;
}

sub valid_content_type {
    $mech->is_html() or (lc($mech->content_type) eq 'text/plain');
}

sub crawl ($url, $depth = 0, $recrawl = 0) {

    # Must be http:// or https://
    $url =~ m{^https?://} or return;

    # Sanitize url
    $url = sanitize_url($url);

    # Check if we're allowed to crawl this URL
    if (RESPECT_ROBOT_RULES and not $robot_rules->allowed($url)) {
        warn "Not allowed to crawl: $url\n";
        return;
    }

    my $id = xxhash32_hex(encode_utf8(normalize_url($url)), XXHASH_SEED);

    if ($depth == 0 and exists $CONTENT_DB{$id}) {
        if (not $recrawl) {
            return 1;
        }
    }

    my $resp = $mech->head($url);

    if ($resp->is_success) {
        valid_content_type() || return;
    }

    $url = $mech->uri;
    $url = "$url";

    $resp = $mech->get($url);
    $resp->is_success or return;

    if (not valid_content_type()) {
        $mech->invalidate_last_request() if CACHE;
        return;
    }

    $url = $mech->uri;
    $url = "$url";

    my $normalized_url = normalize_url($url);
    my $protocol = (($url =~ m{^https://}) ? 'https://' : 'http://');

    if ($recrawl or not exists $CONTENT_DB{$id}) {

        my %info;
        my $decoded_content = $resp->decoded_content;

        if ($mech->is_html) {
            if (not exists $INC{'HTML::TreeBuilder'}) {
                require HTML::TreeBuilder;
                HTML::TreeBuilder->VERSION(5);
                HTML::TreeBuilder->import('-weak');
            }

            my $tree = HTML::TreeBuilder->new();
            $tree->parse($decoded_content);
            $tree->eof();
            $tree->elementify();    # just for safety

            require HTML::FormatText;
            my $formatter = HTML::FormatText->new(leftmargin  => 0,
                                                  rightmargin => 1000);

            $info{content} = $formatter->format($tree);
        }
        else {
            $info{content} = $decoded_content;
        }

        $info{title} = $mech->title // $normalized_url;

        # Convert Unicode to ASCII
        $info{content} = unidecode($info{content});

        if ($mech->is_html) {

            # Parse HTML header for extracting metadata
            my $html_head_parser = HTML::HeadParser->new;
            $html_head_parser->parse($decoded_content);

            $info{keywords}    = $html_head_parser->header('X-Meta-Keywords');
            $info{description} = $html_head_parser->header('X-Meta-Description');
        }

        $info{id}  = $id;
        $info{url} = $protocol . $normalized_url;

        warn "Adding: $info{title}\nURI: $info{url}\n";

        my $relevant_content = join(' ', unidecode($normalized_url), unidecode($info{title}), $info{content},);

        if ($recrawl) {
            readd_to_database_index($relevant_content, $id);
        }
        else {
            add_to_database_index($relevant_content, $id);
        }

        $CONTENT_DB{$id} = encode_content_entry(\%info);
    }

    if ($depth >= 1) {

        my $host = $normalized_url =~ s{/.*}{}sr;
        ## my $host = URI->new($url)->host;

        my $robots_url = $protocol . join('/', $host, 'robots.txt');
        my $robots_txt = get($robots_url);

        $robot_rules->parse($robots_url, $robots_txt) if defined($robots_txt);

        my @links = $mech->find_all_links(text_regex => qr/\w/);

        foreach my $link (@links) {
            crawl(join('', $link->url_abs), $depth - 1, $recrawl);
        }
    }

    return 1;
}

sub add_match_text_to_value ($text, $value, $i, $j) {

    my $prefix_len = 50;
    my $suffix_len = 200;

    my $match_content = substr($text, $i, $j - $i);

    if ($j + $suffix_len > length($text)) {
        $prefix_len += $j + $suffix_len - length($text);
    }

    if ($i - $prefix_len < 0) {
        $prefix_len = $i;
    }

    my $prefix_content = substr($text, $i - $prefix_len, $prefix_len);
    my $suffix_content = substr($text, $j,               $suffix_len);

    foreach ($match_content, $prefix_content, $suffix_content) {
        s/\s+/ /g;
        s/(\W)\1{2,}/$1/g;
    }

    $value->{match} =
      encode_entities($prefix_content) . '<b>' . encode_entities($match_content) . '</b>' . encode_entities($suffix_content);

    return 1;
}

sub set_intersection ($sets) {

    my @sets = @$sets;
    @sets || return;

    my $intersection = {};
    @{$intersection}{@{shift(@sets)}} = ();

    while (@sets) {

        my %curr;
        @curr{@{shift(@sets)}} = ();

        my %tmp;

        foreach my $key (keys %$intersection) {
            if (exists $curr{$key}) {
                undef $tmp{$key};
            }
        }

        $intersection = \%tmp;
    }

    return keys %$intersection;
}

sub search ($text) {

    $text = unidecode($text);

    my %seen;
    my %matches;

    my @words       = extract_words($text);
    my @known_words = grep { !exists($too_common_words{$_}) and exists($WORDS_INDEX{$_}) } @words;

    my @ref_sets;
    my %counts;

    foreach my $word (@known_words) {

        my @refs = uniq(split(' ', $WORDS_INDEX{$word}));

        ++$seen{$_} for @refs;
        $counts{$word} = scalar(@refs);

        push @ref_sets, \@refs;
    }

    foreach my $key (set_intersection(\@ref_sets)) {
        $matches{$key} = eval { decode_content_entry($CONTENT_DB{$key}) } // next;
    }

    #my $max_score = max(values %seen);
    my @original_words = map { quotemeta($_) } grep { length($_) >= 2 } split(/[_\W]+/, $text);

    my @regexes;

    foreach my $k (1 .. scalar(@original_words)) {

        last if ($k > 15);

        forcomb {
            my @subset = @original_words[@_];

            my $regex   = join('.{0,10}',     @subset);
            my $b_regex = join('\b.{0,10}\b', @subset);

            #my $regex   = join('\W*+',     @subset);
            #my $b_regex = join('\b\W*+\b', @subset);

            unshift @regexes,
              scalar {
                      (RANK_ON_NON_BOUNDARY_MATCH ? (re   => qr/$regex/si)       : ()),
                      (RANK_ON_BOUNDARY_MATCH     ? (b_re => qr/\b$b_regex\b/si) : ()),
                      factor => $k,
                     };
        }
        scalar(@original_words), $k;
    }

    my $words_len = scalar(@known_words);

    foreach my $key (keys %matches) {

        my $value = $matches{$key};

        $value->{score} = $seen{$value->{id}} - $words_len;

        # Don't keep partial results that don't match all keywords
#<<<
        #~ if ($value->{score} < 0) {
            #~ delete($matches{$key});
            #~ next;
        #~ }
#>>>

        if ($value->{url} !~ m{^https?://}) {
            $value->{url} = 'https://' . $value->{url};
        }

        my $content     = $value->{content} // '';
        my $title       = unidecode($value->{title}       // '');
        my $description = unidecode($value->{description} // '');
        my $keywords    = unidecode($value->{keywords}    // '');
        my $url         = unidecode($value->{url}         // '');

        foreach my $regex (@regexes) {

            foreach my $re_type (qw(b_re re)) {

                my $re     = $regex->{$re_type} // next;
                my $factor = $regex->{factor} * ($re_type eq 'b_re' ? 1 : 0.5);

                if ($title =~ $re) {
                    $value->{score} += 2 * $factor;
                }

                if ($description =~ $re) {

                    ## $value->{score} += 1 * $factor;

                    if (    SHOW_DESCRIPTION
                        and $re_type eq (RANK_ON_BOUNDARY_MATCH ? 'b_re' : 're')
                        and not exists $value->{match}) {
                        add_match_text_to_value($description, $value, $-[0], $+[0]);
                    }
                }

                if (RANK_ON_CONTENT and $content =~ $re) {

                    $value->{score} += $factor;

                    if ($re_type eq (RANK_ON_BOUNDARY_MATCH ? 'b_re' : 're')
                        and not exists $value->{match}) {
                        add_match_text_to_value($content, $value, $-[0], $+[0]);
                    }
                }

                if ($keywords =~ $re) {
                    $value->{score} += 2 * $factor;
                }

                if ($url =~ $re) {
                    $value->{score} += 4 * $factor;
                }
            }
        }

        delete $value->{content};
    }

    my %seen_url;
    my @sorted = sort { $b->{score} <=> $a->{score} } values %matches;

    my $results_count = scalar(@sorted);

    # Keep only the top best entries
    $#sorted = MAX_SEARCH_RESULTS- 1 if (scalar(@sorted) > MAX_SEARCH_RESULTS);

    # Prefer shorter URLs for results with the same score
    @sorted = map { $_->[0] }
      sort { ($b->[1] <=> $a->[1]) || ($a->[2] <=> $b->[2]) }
      map { [$_, $_->{score}, length($_->{url})] } @sorted;

    # Keep entries with score > 0
    @sorted = grep { $_->{score} > 0 } @sorted;

    # Fix some ArchWiki links
    foreach my $entry (@sorted) {
        $entry->{url} =~ s{^https://wiki\.archlinux\.org//}{https://wiki.archlinux.org/title/};
    }

    # Remove duplicated entries
    @sorted = grep { !$seen_url{(($_->{url} =~ s{^https?://(?:www\.)?}{}r) =~ s{#.*}{}sr) =~ s{/\z}{}r}++ } @sorted;

    return {
            results => \@sorted,
            counts  => \%counts,
            words   => \@known_words,
            count   => $results_count,
           };
}

sub repair_index {    # very slow operation
    while (my ($key, $value) = each %CONTENT_DB) {
        my $info = eval { decode_content_entry($value) } // next;
        readd_to_database_index(unidecode($info->{title}) . ' ' . $info->{content}, $info->{id});
    }
    return 1;
}

sub sanitize_index {

    my @for_delete_keys;
    my $index_len = 0;
    my $uniq_refs = 0;

    while (my ($key, $value) = each %WORDS_INDEX) {

        ++$index_len;

        my $ref_count = 1 + ($value =~ tr/ //);

        if ($ref_count > 5000) {
            say "$ref_count: $key";
        }

        if ($ref_count == 1) {
            ++$uniq_refs;
        }

        if (length($key) < WORD_MIN_LEN or length($key) > WORD_MAX_LEN) {
            push @for_delete_keys, $key;
        }
    }

    say ":: The words index contains $index_len entries.";
    say ":: The words index contains $uniq_refs entries with only one reference.";

    foreach my $key (@for_delete_keys) {
        delete $WORDS_INDEX{$key};
    }

    return 1;
}

if (@ARGV) {

    my $depth   = 0;
    my $recrawl = 0;

    require Getopt::Long;
    Getopt::Long::GetOptions(

        "depth=i"    => \$depth,
        "r|recrawl!" => \$recrawl,

        "sanitize-index" => sub {
            warn "Sanitzing index...\n";
            sanitize_index();
            exit;
        },

        "fix-index|recover-index|repair-index" => sub {
            warn "Recovering index...\n";
            repair_index();
            exit;
        },
    );

    foreach my $url (@ARGV) {
        warn "Crawling: $url\n";
        crawl($url, $depth, $recrawl);
    }

    exit;
}

while (my $c = CGI::Fast->new) {

    my $query    = $c->param('q');
    my $id       = $c->param('text');
    my $surprise = $c->param('surprise');

    print header(-charset => 'UTF-8'), start_html(
        -class => 'results_endpoint',
        -title => 'DarkSearch - ' . encode_utf8($query // $id // 'Surprise'),
        -meta  => {
            'keywords' => 'dark search, search engine, private, secure',

            #'viewport' => 'width=device-width, initial-scale=1.0',
            'viewport' => 'width=device-width, initial-scale=1, maximum-scale=2.0, user-scalable=1',
            'referrer' => 'no-referrer',
                 },
        -style => [
            {
             src => 'css/logicodev-dark.min.css',
            },
            {
             src => 'css/bootstrap.min.css',
            },
            {
             src => 'css/pre.css',
            },

            #~ {
            #~ src => 'css/popup.css',
            #~ },
                  ],
        -head => Link(
                      {
                       -rel  => 'shortcut icon',
                       -type => 'image/png',
                       -href => 'img/favicon.png',
                      }
                     ),
    );

    if (defined($id)) {

        my $info = decode_content_entry($CONTENT_DB{$id});

        say h4(
               {-class => "result_header"},
               a(
                  {
                   -href   => encode_utf8($info->{url}),
                   -target => "_blank",
                   -rel    => "noopener noreferrer",
                  },
                  b(encode_utf8(encode_entities($info->{title}))),
                )
              );

        print pre(encode_entities($info->{content}));
        print end_html();
        next;
    }

    print <<"EOT";
<div class="searx-navbar"><span class="instance pull-left"><a href="/search">Home</a></span><span class="pull-right"><a href="$ENV{SCRIPT_NAME}?surprise=1">Surprise me</a></span></div>
    <div class="container">

<form method="post" action="$ENV{SCRIPT_NAME}" id="search_form" role="search">
  <div class="row">
    <div class="col-xs-12 col-md-8">
      <div class="input-group search-margin">
        <input type="search" autofocus name="q" class="form-control" id="q" placeholder="Search for..." aria-label="Search for..." autocomplete="off" value="${\encode_entities($query // '')}" accesskey="s">
        <span class="input-group-btn">
            <button type="submit" class="btn btn-default" aria-label="Search"><span>Search</span></button>
        </span>
      </div>
    </div>
    <div class="col-xs-6 col-md-2 search-margin"><label class="visually-hidden" for="time-range">Time range</label></div>
    <div class="col-xs-6 col-md-2 search-margin"><label class="visually-hidden" for="language">Language</label></div>
  </div>
</form><!-- / #search_form_full -->
    <div class="row">

        <div class="col-sm-4 col-sm-push-8" id="sidebar_results">

        </div><!-- /#sidebar_results -->

        <div class="col-sm-8 col-sm-pull-4" id="main_results">
            <h1 class="sr-only">Search results</h1>
EOT

    if ($surprise) {
        $query = surprise_me();
    }

    say q{<div class="result result-default">};

    my $t0 = [gettimeofday];

    my @results;
    my $search_results = ((($query // '') =~ /\S/) ? search($query) : ());

    my $elapsed = tv_interval($t0, [gettimeofday]);

    if ($search_results) {

        @results = @{$search_results->{results}};
        my @words = @{$search_results->{words}};

        if (@words) {
            ## say p("Results found: ", b($search_results->{count}));
            say p("Term frequencies: " . join(", ", map { b($_) . ': ' . $search_results->{counts}{$_} } @words));
            say p(small(sprintf("Search took %.5f seconds", $elapsed)));
        }
    }

    foreach my $result (@results) {

        my $url = $result->{url};

        if ($url !~ m{^https?://}) {
            $url = 'https://' . $url;
        }

        $url = sanitize_url($url);

        my $title = $result->{title} // $url;

        if ($title !~ /\S/) {
            $title = $url;
        }

        say h4(
            {-class => "result_header"},
            a(
               {
                -href   => encode_utf8($url),
                -target => "_blank",
                -rel    => "noopener noreferrer",

                #(defined($result->{description}) ? (-class => 'popup') : ()),
               },

               #(defined($result->{description}) ? small(span(encode_utf8(encode_entities($result->{description})))) : ()),
               #small(span($result->{content} =~ s/(\R)\1{2,}/$1/gr =~ s{\R}{<br/>}gr)),
               b(encode_utf8(encode_entities($title))),
             )
        );

        say q{<p class="result-content">};
        say $result->{match};
        say q{</p>};
        say q{<div class="clearfix"></div>};
        say q{<div class="pull-right">};

        # Web archive
        say small(
            a(
               {
                -href   => encode_utf8('https://web.archive.org/web/' . $url),
                -class  => 'text-info',
                -target => '_blank',
                -rel    => 'noopener noreferrer',

               },
               "cached",
             ),
        );

        say q{<b> | </b>};

        # Text only cached version
        say small(
                  a(
                    {
                     -href   => "$ENV{SCRIPT_NAME}?text=" . $result->{id},
                     -class  => 'text-info',
                     -target => '_blank',
                     -rel    => 'noopener noreferrer',
                    },
                    "text",
                   )
                 );

        # Proxy (currently disabled)
        if (0) {
            say q{<b> | </b>};

            say small(
                a(
                   {
                    -href   => 'https://searx.webheberg.info/morty/?mortyurl=' . uri_escape_utf8($url),
                    -class  => 'text-info',
                    -target => '_blank',
                    -rel    => 'noopener noreferrer',

                   },
                   "proxy",
                 ),
            );
        }

        say q{<b> | </b>};
        say small("rank: $result->{score}");

        say "</div>";    # end of 'pull-right' div

        say div({-class => "external-link"}, encode_utf8($url));
    }

    say "</div>";

    print <<'EOT';

            <div class="clearfix"></div>
            <div class="clearfix"></div>

        </div><!-- /#main_results -->
    </div>
   </div>
EOT

    print end_html;
}
