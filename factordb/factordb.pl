#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 28 August 2019
# Edit: 18 January 2024
# https://github.com/trizen

# Automatically factorize composite numbers without known factors from factordb.com and report the factorizations.

# For small numbers, YAFU program is used, which fully factorizes the numbers.
# For large numbers, the `ecm_factor` function from Math::Prime::Util::GMP is used, which finds only one factor using the ECM method.

# The script also has support for `ecmpi`:
#   https://gite.lirmm.fr/bouvier/ecmpi

# Usage:
#   perl factordb.pl             # factorize the smallest numbers without known factors
#   perl factordb.pl -d n        # factorize only numbers with at least n digits
#   perl factordb.pl -d n -s k   # factorize only numbers with at least n digits, skipping the first k numbers

use 5.020;
use warnings;
use experimental qw(signatures);

use Cwd         qw(cwd);
use File::Temp  qw();
use Getopt::Std qw(getopts);
use List::Util  qw(shuffle uniq);

use WWW::Mechanize;
use Math::BigInt try => 'GMP';

use constant {

    USE_TOR_PROXY => 1,    # true to use the Tor proxy to connect to factorDB (127.0.0.1:9050)
    USE_SIDEF     => 0,    # true to use Math::Sidef for finding factors of special form

    ECM_MIN      => 65,    # numbers > 10^ECM_MIN will be factorized with ECM
    SIQS_MAX     => 70,    # numbers < 10^SIQS_MAX will be factorized with SIQS, if ECM fails
    YAFU_TIMEOUT => 60,    # number of seconds allocated for YAFU on small numbers < 10^ECM_MIN

    PREFER_YAFU_ECM => 0,  # true to prefer YAFU's ECM implementation
    PREFER_ECMPI    => 1,  # true to prefer ecmpi, which uses GMP-ECM (this is faster)

    ECM_TIMEOUT       => 10,    # number of seconds allocated for ECM
    ECM_CURVES_FACTOR => 2,     # how many ECM curves to try: int(ECM_CURVES_FACTOR * ECM_TIMEOUT)

    YAFU_ECM_B1 => 60000,       # B1 value for YAFU ECM (with `PREFER_YAFU_ECM`)
    GMP_ECM_B1  => 180000,      # B1 value for GMP-ECM (with `PREFER_ECMPI`)
};

local $SIG{INT} = sub {
    say ":: Exiting...";
    exit 1;
};

getopts('d:s:', \my %opt);

sub execute_in_tmpdir ($cmd) {

    my $cwd = cwd();                              # current dir
    my $tmp = File::Temp->newdir(CLEANUP => 1);

    chdir($tmp);

    my $output    = `$cmd`;
    my $exit_code = $?;

    chdir($cwd);

    return ($output, $exit_code);
}

sub prod (@list) {
    my $prod = Math::BigInt->new(1);
    foreach my $n (@list) {
        $prod *= Math::BigInt->new("$n");
    }
    return $prod;
}

sub validate_factors ($n, @factors) {

    if (ref($n) ne 'Math::BigInt') {
        $n = Math::BigInt->new("$n");
    }

    @factors || return;
    @factors = map  { Math::BigInt->new("$_") } @factors;
    @factors = grep { ($_ > 1) and ($_ < $n) } @factors;
    @factors || return;

    @factors = grep { $n % $_ == 0 } @factors;

    if (@factors) {
        push(@factors, $n / prod(@factors));
    }

    @factors = grep { ($_ > 1) and ($_ < $n) } @factors;
    @factors = sort { $a <=> $b } @factors;
    return uniq(@factors);
}

sub parse_yafu_output ($n, $output) {
    my @factors;
    while ($output =~ /^[CP]\d+\s*=\s*(\d+)/mg) {
        push @factors, Math::BigInt->new($1);
    }
    return validate_factors($n, @factors);
}

sub parse_ecmpi_output ($n, $output) {
    my @factors;
    while ($output =~ /found factor (\d+)/g) {
        push @factors, Math::BigInt->new($1);
    }
    return validate_factors($n, @factors);
}

sub parse_mpu_output ($n, $output) {
    my @factors;
    while ($output =~ /^(\d+)/mg) {
        push @factors, Math::BigInt->new($1);
    }
    return validate_factors($n, @factors);
}

sub ecm_one_factor ($n) {

    my @factors;

    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm ECM_TIMEOUT;

        if (PREFER_YAFU_ECM) {
            say ":: Trying YAFU's ECM...";
            my $curves = int(ECM_CURVES_FACTOR * ECM_TIMEOUT);
            my ($output, $exit_code) = execute_in_tmpdir("yafu 'ecm($n, $curves)' -B1ecm ${\YAFU_ECM_B1}");
            push @factors, parse_yafu_output($n, $output);
        }

        if (PREFER_ECMPI) {
            say ":: Trying ECMPI with GMP-ECM...";
            my $curves = int(ECM_CURVES_FACTOR * ECM_TIMEOUT);
            my $output = qx(ecmpi -N $n -B1 ${\GMP_ECM_B1} -nb $curves);
            push @factors, parse_ecmpi_output($n, $output);
        }

        if (!@factors) {
            say ":: Trying MPU's ECM...";
            my $output = `$^X -MMath::Prime::Util::GMP=ecm_factor -E 'say for ecm_factor("$n")'`;
            push @factors, parse_mpu_output($n, $output);
        }

        alarm 0;
    };

    if ($@ eq "alarm\n") {
        `pkill -P $$`;

        if (USE_SIDEF and length("$n") < 1000) {
            say ":: Trying to find factors of special form...";
            require Math::Sidef;
            my @f = Math::Sidef::special_factors($n);
            pop @f;
            push @factors, @f;
        }
    }

    if (!@factors and length("$n") <= SIQS_MAX) {
        say ":: Trying YAFU SIQS...";
        my ($output, $exit_code) = execute_in_tmpdir("yafu 'siqs($n)'");
        push @factors, parse_yafu_output($n, $output);
    }

    return validate_factors($n, @factors);
}

sub yafu_factor ($n) {

    $n = Math::BigInt->new("$n") || return;    # validate the number

    if (length("$n") >= ECM_MIN) {
        return ecm_one_factor($n);
    }

    my @factors;

    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm YAFU_TIMEOUT;
        my ($output, $exit_code) = execute_in_tmpdir("yafu 'factor($n)'");
        @factors = parse_yafu_output($n, $output);
        alarm 0;
    };

    if ($@ eq "alarm\n") {
        `pkill -P $$`;
        say ":: YAFU timeout...";
        return ecm_one_factor($n);
    }

    if (!@factors) {
        say ":: YAFU failed...";
        return ecm_one_factor($n);
    }

    return @factors;
}

my $mech = WWW::Mechanize->new(
                               autocheck     => 1,
                               show_progress => 0,
                               stack_depth   => 10,
                               agent         => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
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
    require LWP::Protocol::socks;
    $mech->proxy(['http', 'https'], "socks://127.0.0.1:9050");
}

my $start   = 0;
my $digits  = 0;
my $perpage = 100;

if (defined($opt{s}) and $opt{s} > 0) {
    $start = $opt{s};
}

if (defined($opt{d}) and $opt{d} > 0) {
    $digits = $opt{d};
}

my $failure = 0;
my $success = 0;

my $time        = time;
my $old_time    = $time;
my $interval    = 60;      # seconds
my $factor_size = 0;       # average factor size

sub factordb {

    my $main_url = "http://factordb.com/listtype.php?t=3";
    $main_url .= "&start=$start&perpage=$perpage";

    say ":: Start value = $start (page ", 1 + int($start / $perpage), ")";

    if ($digits > 0) {
        $main_url .= "&mindig=$opt{d}";
    }

    my $resp  = eval { $mech->get($main_url) } // return;
    my @links = $mech->find_all_links(url_regex => qr/index\.php\?id=\d+/);

    if ($digits > 0) {
        @links = shuffle(@links);
    }

    foreach my $link (@links) {

        my $expr   = $link->text;
        my $digits = 0;

        next if $expr =~ /##/;    # ignore numbers that are formed from primorials
        ##next if $expr !~ /\^/;    # ignore numbers that are not formed from powers
        ##next if $expr !~ /[LI]/;  # ignore numbers that are not formed from Fibonacci or Lucas numbers

        my $resp = eval { $mech->get($link) } // next;

        if ($resp->decoded_content =~ m{<font color="#002099">(.*?)</font></a><sub>&lt;(\d+)&gt;</sub>}) {
            $expr   = $1;
            $digits = $2;
        }

        say "\n:: Factoring: $expr ($digits digits)";

        if ($resp->decoded_content =~ m{<td>FF</td>}) {
            say ":: Already factorized...";
            next;
        }

        my $reget  = 0;
        my $number = $expr;

        if ($number !~ /^[0-9]+\z/) {

            $reget = 1;
            $resp  = eval { $mech->follow_link(text_regex => qr/\(show\)/) } // next;

            if ($resp->decoded_content =~ m{<td align="center">Number</td>\s*<td align="center">(.*?)</td>}s) {
                $number = $1;
                $number =~ s/<(.*?)>//g;
                $number = join('', split(' ', $number));
            }
            else {
                warn ":: Can't extract digits of <<$number>>\n";
                next;
            }
        }

        my @factors = yafu_factor($number);

        if ((time - $old_time) >= $interval) {

            my $total_time        = (time - $time) || 1;
            my $predicted_success = int($success / $total_time * 3600);
            my $predicted_total   = int(($success + $failure) / $total_time * 3600);

            if ($predicted_total > 0) {
                printf(":: Predicted success: %.2f%% (%d out of %d) per hour...\n",
                       100 * $predicted_success / $predicted_total,
                       $predicted_success, $predicted_total);
            }

            $old_time = time;
        }

        if (!@factors) {
            say ":: Failed to factorize...";
            $failure += 1;
            next;
        }

        $success     += 1;
        $factor_size += length("$factors[0]");

        say ":: Factors: @factors";

        printf(":: Average factor size found: %d digits...\n", int($factor_size / $success));
        printf(":: Factorization success: %.2f%% (%d out of %d)\n", 100 * $success / ($failure + $success), $success, $failure + $success);

        if ($reget) {
            for my $i (1 .. 5) {
                say ":: Retrying to connect ($i out of 5)..." if ($i > 1);
                $resp = eval { $mech->get($link) } // next;
                $resp->status_line =~ /Server closed connection/ or last;
            }
        }

        if ($resp->decoded_content =~ m{<td>FF</td>}) {
            say ":: Already factorized...";
            next;
        }

        say ":: Sending factors...";

        $resp = eval { $mech->submit_form(form_number => 1, fields => {'report' => join(' ', @factors), 'format' => 7}) } // next;

        if ($resp->decoded_content =~ /Thank you/i) {
            say ":: New prime factors submitted!";
        }
    }
}

while (1) {
    factordb();
    $start += $perpage;
    say "\n:: Getting the next page of results...";
}
