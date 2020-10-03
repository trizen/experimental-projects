#!/usr/bin/perl

use 5.014;

my %fermat;
my %lucas;
my %fib;

use Math::GMPz;

while (<>) {

    chomp;

    if (/^Fermat: (\d+)/) {
        my $n = Math::GMPz->new($1);
        if ($n > 1e15) {
            $fermat{$n} = $n;
        }
    }
    elsif (/^Lucas: (\d+)/) {
        my $n = Math::GMPz->new($1);
        if ($n > 1e15) {
            $lucas{$n} = $n;
        }
    }
    elsif (/^Fibonacci: (\d+)/) {
        my $n = Math::GMPz->new($1);
        if ($n > 1e15) {
            $fib{$n} = $n;
        }
    }
    else {
        die "Error for: $_";
    }
}

open my $fer_fh,   '>', 'fermat.txt';
open my $fib_fh,   '>', 'fib.txt';
open my $lucas_fh, '>', 'lucas.txt';

my @lucas  = values %lucas;
my @fib    = values %fib;
my @fermat = values %fermat;

@fermat = grep { !exists($lucas{$_}) } @fermat;
@fib    = grep { !exists($lucas{$_}) } @fib;
@fib    = grep { !exists($fermat{$_}) } @fib;

foreach my $n (@fermat) {
    say {$fer_fh} $n;
}

foreach my $n (@lucas) {
    say {$lucas_fh} $n;
}

foreach my $n (@fib) {
    say {$fib_fh} $n;
}
