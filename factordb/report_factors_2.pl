#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 03 May 2022
# https://github.com/trizen

# Report factorizations to factordb.

# The factorizations must be in the following format:
#   n = p1 * p2 * ...

use 5.020;
use autodie;
use warnings;

use WWW::Mechanize;
use List::Util qw(all);
use Math::AnyNum qw(:overload :all);
use experimental qw(signatures);
use Getopt::Long qw(GetOptions);

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

my $from_slice = 0;

GetOptions(
    's|slice=i' => \$from_slice,
) or die("Error in command line arguments\n");

my $url = "http://factordb.com/search.php";

say ":: Collecting factors...";

my @list;

while (<>) {
    if (/^(\d+)\s*=\s*(.+)/) {
        my ($n, $factors) = ($1, $2);

        $n = Math::AnyNum->new($n);
        $n > 1 or next;

        my @f = map { Math::AnyNum->new($_) } split(/\s*\*\s*/, $factors);

        (all { is_div($n, $_) } @f)
          or die "error in factors (@f) for n = $n";

        push @list, ("$n = " . join(" * ", @f));
    }
    else {
        warn "[WARN] Invalid line: $_";
    }
}

say ":: Reporting factors...";

my $count       = 0;
my $slice_len   = 500;
my $total_count = int(0.5 + scalar(@list) / $slice_len);

if ($from_slice > 0) {
    say ":: Starting from slice number $from_slice...";
}

while (@list) {

    ++$count;

    my @slice        = splice(@list, 0, $slice_len);
    my $factor_table = join("\n", @slice);

    next if ($count < $from_slice);

    say "\n:: Sending slice $count of $total_count with ", scalar(@slice), " entries...";

    $mech->get($url);

    my $resp = $mech->submit_form(
                                  form_number => 1,
                                  fields      => {
                                             'msub' => $factor_table,
                                            }
                                 );

    if ($resp->is_success) {
        say ":: Success!";
        sleep 1;
    }
    else {
        die ":: There was an error...\n";
    }
}
