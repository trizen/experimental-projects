#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 28 August 2019
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

use File::Temp qw(tempdir);
use File::Spec::Functions qw(catfile);

use Math::GMPz;
use ntheory qw(vecmin);
use experimental qw(signatures);

use Math::Prime::Util::GMP qw(
  lucas_sequence gcd pminus1_factor is_prime
  pplus1_factor holf_factor logint vecprod
);

use WWW::Mechanize;
use Getopt::Std qw(getopts);
use List::Util qw(shuffle uniq);

use constant {
              USE_TOR_PROXY   => 1,     # true to use the Tor proxy to connect to factorDB (127.0.0.1:9050)
              PREFER_YAFU_ECM => 0,     # true to prefer YAFU's ECM implementation
              PREFER_ECMPI    => 1,     # true to prefer ecmpi, which uses GMP-ECM (this is faster)
              ECM_MIN         => 65,    # numbers > 10^ECM_MIN will be factorized with ECM
              SIQS_MAX        => 70,    # numbers < 10^SIQS_MAX will be factorized with SIQS, if ECM fails
              ECM_TIMEOUT     => 10,    # number of seconds allocated for ECM
              YAFU_TIMEOUT    => 60,    # number of seconds allocated for YAFU on small numbers < 10^ECM_MIN
             };

local $SIG{INT} = sub {
    say ":: Exiting...";
    exit 1;
};

chdir(my $cwd = tempdir(CLEANUP => 1));
getopts('d:s:', \my %opt);

sub fermat_find_factor ($n, $max_iter) {

    my $p = Math::GMPz::Rmpz_init();    # p = floor(sqrt(n))
    my $q = Math::GMPz::Rmpz_init();    # q = p^2 - n

    Math::GMPz::Rmpz_sqrtrem($p, $q, $n);
    Math::GMPz::Rmpz_neg($q, $q);

    for (my $j = 1 ; $j <= $max_iter ; ++$j) {

        Math::GMPz::Rmpz_addmul_ui($q, $p, 2);

        Math::GMPz::Rmpz_add_ui($q, $q, 1);
        Math::GMPz::Rmpz_add_ui($p, $p, 1);

        if (Math::GMPz::Rmpz_perfect_square_p($q)) {
            Math::GMPz::Rmpz_sqrt($q, $q);

            my $r = Math::GMPz::Rmpz_init();
            Math::GMPz::Rmpz_sub($r, $p, $q);

            return $r;
        }
    }

    return;
}

sub fast_fibonacci_check ($n, $upto) {

    foreach my $k (2 .. $upto) {
        foreach my $P (3, 4) {

            my ($U, $V) = map { Math::GMPz::Rmpz_init_set_str($_, 10) } lucas_sequence($n, $P, 1, $k);

            foreach my $f (
                           sub { gcd($U,     $n) },
                           sub { gcd($U - 1, $n) },
                           sub { gcd($V,     $n) },
                           sub { gcd($V - 1, $n) },
                           sub { gcd($V - 2, $n) },
              ) {
                my $g = Math::GMPz->new($f->());
                return $g if ($g > 1 and $g < $n);
            }
        }
    }

    return;
}

sub fast_power_check ($n, $upto) {

    state $t = Math::GMPz::Rmpz_init_nobless();
    state $g = Math::GMPz::Rmpz_init_nobless();

    my $base_limit = vecmin(logint($n, 2), 150);

    foreach my $base (2 .. $base_limit) {

        Math::GMPz::Rmpz_set_ui($t, $base);

        foreach my $exp (2 .. $upto) {

            Math::GMPz::Rmpz_mul_ui($t, $t, $base);
            Math::GMPz::Rmpz_sub_ui($g, $t, 1);
            Math::GMPz::Rmpz_gcd($g, $g, $n);

            if (Math::GMPz::Rmpz_cmp_ui($g, 1) > 0 and Math::GMPz::Rmpz_cmp($g, $n) < 0) {
                return Math::GMPz::Rmpz_init_set($g);
            }

            Math::GMPz::Rmpz_add_ui($g, $t, 1);
            Math::GMPz::Rmpz_gcd($g, $g, $n);

            if (Math::GMPz::Rmpz_cmp_ui($g, 1) > 0 and Math::GMPz::Rmpz_cmp($g, $n) < 0) {
                return Math::GMPz::Rmpz_init_set($g);
            }
        }
    }

    return undef;
}

sub special_form_factor ($n) {

    my $len = length("$n");

    if (ref($n) ne 'Math::GMPz') {
        $n = Math::GMPz->new("$n");
    }

    my @factors;

    if (defined(my $p = fermat_find_factor($n, 1e4))) {
        say ":: Fermat difference of squares...";
        return $p;
    }

    if (defined(my $p = fast_power_check($n, 500))) {
        say ":: Power fast-check found factor...";
        return $p;
    }

    if (defined(my $p = fast_fibonacci_check($n, 5000))) {
        say ":: Fibonacci fast-check found factor...";
        return $p;
    }

    my $pm1_limit  = 1e5;
    my $pp1_limit  = 1e5;
    my $holf_limit = 1e5;

    @factors = holf_factor($n, $holf_limit);

    if (@factors > 1) {
        say ":: HOLF found factor...";
        return @factors;
    }

    @factors = pplus1_factor($n, $pp1_limit);

    if (@factors > 1) {
        say ":: p+1 found factor...";
        return @factors;
    }

    @factors = pminus1_factor($n, $pm1_limit);

    if (@factors > 1) {
        say ":: p-1 found factor...";
        return @factors;
    }

    return;
}

sub validate_factors ($n, @factors) {

    if (ref($n) ne 'Math::GMPz') {
        $n = Math::GMPz->new("$n");
    }

    @factors || return;
    @factors = map  { (ref($_) eq 'Math::GMPz') ? $_ : Math::GMPz::Rmpz_init_set_str("$_", 10) } @factors;
    @factors = grep { ($_ > 1) and ($_ < $n) } @factors;
    @factors || return;

    @factors = grep { $n % $_ == 0 } @factors;

    if (@factors) {
        push @factors, ($n / Math::GMPz->new(vecprod(@factors)));
    }

    @factors = grep { ($_ > 1) and ($_ < $n) } @factors;
    @factors = sort { $a <=> $b } @factors;
    return uniq(@factors);
}

sub parse_yafu_output ($n, $output) {
    my @factors;
    while ($output =~ /^[CP]\d+\s*=\s*(\d+)/mg) {
        push @factors, Math::GMPz->new($1);
    }
    return validate_factors($n, @factors);
}

sub parse_ecmpi_output ($n, $output) {
    my @factors;
    while ($output =~ /found factor (\d+)/g) {
        push @factors, Math::GMPz->new($1);
    }
    return validate_factors($n, @factors);
}

sub parse_mpu_output ($n, $output) {
    my @factors;
    while ($output =~ /^(\d+)/mg) {
        push @factors, Math::GMPz->new($1);
    }
    return validate_factors($n, @factors);
}

sub trial_division ($n, $k = 1e5) {    # trial division, using cached primorials + GCD

    state %cache;

    # Clear the cache when there are too many values cached
    if (scalar(keys(%cache)) > 100) {
        Math::GMPz::Rmpz_clear($_) for values(%cache);
        undef %cache;
    }

    my $B = (
        $cache{$k} //= do {
            my $t = Math::GMPz::Rmpz_init_nobless();
            Math::GMPz::Rmpz_primorial_ui($t, $k);
            $t;
        }
    );

    state $g = Math::GMPz::Rmpz_init_nobless();
    state $t = Math::GMPz::Rmpz_init_nobless();

    Math::GMPz::Rmpz_gcd($g, $n, $B);

    if (Math::GMPz::Rmpz_cmp_ui($g, 1) > 0) {
        Math::GMPz::Rmpz_set($t, $n);

        my %factor;
        foreach my $f (Math::Prime::Util::GMP::factor(Math::GMPz::Rmpz_get_str($g, 10))) {
            Math::GMPz::Rmpz_set_ui($g, $f);
            $factor{$f} = Math::GMPz::Rmpz_remove($t, $t, $g);
        }

        my @factors = keys %factor;

        if (Math::GMPz::Rmpz_cmp_ui($t, 1) > 0) {
            push @factors, Math::GMPz::Rmpz_init_set($t);
        }

        return validate_factors($n, @factors);
    }

    return;
}

sub ecm_one_factor ($n) {

    my @factors;

    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm ECM_TIMEOUT;

        if (PREFER_YAFU_ECM) {
            say ":: Trying YAFU's ECM...";
            my $curves = 2 * ECM_TIMEOUT;
            my $output = qx(yafu 'ecm($n, $curves)' -B1ecm 60000);
            push @factors, parse_yafu_output($n, $output);
        }

        if (PREFER_ECMPI) {
            say ":: Trying ECMPI with GMP-ECM...";
            my $curves = 2 * ECM_TIMEOUT;
            my $output = qx(ecmpi -N $n -B1 180000 -nb $curves);
            push @factors, parse_ecmpi_output($n, $output);
        }

        if (!@factors) {
            say ":: Trying MPU's ECM...";
            my $output = `$^X -MMath::Prime::Util::GMP=ecm_factor -E 'say for ecm_factor("$n")'`;
            ## my $output = `$^X -MMath::Prime::Util=factor -E 'say for factor("$n")'`;
            push @factors, parse_mpu_output($n, $output);
        }

        alarm 0;
    };

    if ($@ eq "alarm\n") {
        `pkill -P $$`;

        if (length("$n") < 1000) {
            say ":: Trying to find factors of special form...";
            push @factors, special_form_factor($n);
        }
    }

    if (@factors and $factors[0] <= 1e8 and !PREFER_ECMPI and !is_prime($factors[-1])) {
        pop(@factors) if (scalar(@factors) >= 2);
        say ":: Trial division up to 10^8...";
        push @factors, trial_division($n / Math::GMPz->new(vecprod(@factors)), 1e8);
        push @factors, $n / Math::GMPz->new(vecprod(@factors));
    }

    if (!@factors and length("$n") <= SIQS_MAX) {
        say ":: Trying YAFU SIQS...";
        my $output = qx(yafu 'siqs($n)');
        push @factors, parse_yafu_output($n, $output);
    }

    return validate_factors($n, @factors);
}

sub yafu_factor ($n) {

    $n = Math::GMPz->new($n);    # validate the number

    if (length($n) >= ECM_MIN) {
        return ecm_one_factor($n);
    }

    my @factors;

    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm YAFU_TIMEOUT;
        my $output = qx(yafu 'factor($n)');
        @factors = parse_yafu_output($n, $output);
        alarm 0;
    };

    if ($@ eq "alarm\n") {
        `pkill -P $$`;
        say ":: YAFU timeout...";
        unlink(catfile($cwd, 'siqs.dat'));
        return ecm_one_factor($n);
    }

    if (!@factors) {
        say ":: YAFU failed...";
        unlink(catfile($cwd, 'siqs.dat'));
        return ecm_one_factor($n);
    }

    return @factors;
}

my $mech = WWW::Mechanize->new(
                               autocheck     => 1,
                               show_progress => 0,
                               stack_depth   => 10,
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

    my $resp  = $mech->get($main_url);
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

        my $resp = $mech->get($link);

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
            $resp  = $mech->follow_link(text_regex => qr/\(show\)/);

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

        printf(":: Factorization success: %.2f%% (%d out of %d)\n",
               100 * $success / ($failure + $success),
               $success, $failure + $success);

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

        if (scalar(@factors) >= 2) {
            pop @factors;
        }

        $resp = $mech->submit_form(
                                   form_number => 1,
                                   fields      => {
                                       'report' => join(' ', @factors),
                                       'format' => 7,
                                             }
                                  );

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
