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
              USE_TOR_PROXY      => 1,     # true to use the Tor proxy to connect to factorDB (127.0.0.1:9050)
              COMPRESS_FACTORS   => 1,     # compress small factors into slightly larger composite factors
              COMPRESSION_DIGITS => 45,    # the compressed composite factors will have <= this many digits
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
my $slice_len  = 500;

GetOptions('s|slice=i'  => \$from_slice,
           'l|length=i' => \$slice_len,)
  or die("Error in command line arguments\n");

say ":: Collecting factors...";

my %factors;

while (<>) {

    my @f;
    my $value;

    if (/^(\d+)\s*=\s*(.+)/) {
        my ($n, $factors) = ($1, $2);

        $n = Math::AnyNum->new($n);
        $n > 1 or next;

        $value = "$n";

        my %seen;
        @f = grep { $_ > 1 } map { Math::AnyNum->new($_) } grep { !$seen{$_}++ } split(/\s*\*\s*/, $factors);

        (all { is_div($n, $_) } @f)
          or do {
            warn "error in factors (@f) for n = $n\n";
            @f = grep { $_ > 1 } map { gcd($n, $_) } @f;
          };
    }
    elsif (/^(.+?)\s*=\s*(.+)/) {    # the number is an expression
        my ($expr, $factors) = ($1, $2);

        $value = $expr;

        my %seen;
        @f = grep { $_ > 1 } map { Math::AnyNum->new($_) } grep { !$seen{$_}++ } split(/\s*\*\s*/, $factors);
    }
    else {
        warn "[WARN] Invalid line: $_";
        next;
    }

    @f || next;

    if (COMPRESS_FACTORS) {
        my @compressed;

        while (@f) {
            my $prod = shift(@f);

            while (@f and length(lcm($prod, $f[0])) <= COMPRESSION_DIGITS) {
                $prod = lcm($prod, shift(@f));
            }

            push @compressed, $prod;
        }

        @f = @compressed;
    }

    push @{$factors{$value}}, @f;
}

my @list;

foreach my $n (sort keys %factors) {
    my %seen;
    push @list, ("$n = " . join(" * ", grep { !$seen{$_}++ } @{$factors{$n}}));
}

say ":: Reporting factors...";

my $count       = 0;
my $total_count = sprintf('%.0f', 0.5 + scalar(@list) / $slice_len);

if ($from_slice > 0) {
    say ":: Starting from slice number $from_slice...";
}

my $url = "http://factordb.com/search.php";

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
