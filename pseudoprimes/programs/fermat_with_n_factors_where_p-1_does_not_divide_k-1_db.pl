#!/usr/bin/perl

# a(n) is the smallest k with n prime factors such that 2^(k-1) == 1 (mod k) and p-1 does not divide k-1 for every prime p dividing k.
# https://oeis.org/A316908

# Known terms:
#   7957, 617093, 134564501, 384266404601, 8748670222601, 6105991025919737, 901196605940857381

use 5.020;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use POSIX qw(ULONG_MAX);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my %table;

while (my ($key, $value) = each %db) {

    my @f     = split(' ', $value);
    my $omega = scalar(@f);

    next if ($omega < 9);

    Math::Prime::Util::GMP::is_pseudoprime($key, 2) || next;

    my $n = Math::GMPz::Rmpz_init_set_str($key, 10);

    if (exists $table{$omega}) {
        next if ($table{$omega} < $n);
    }

    my $t = $n - 1;
    if (vecany {
            ($_ < ULONG_MAX)
                ? Math::GMPz::Rmpz_divisible_ui_p($t, $_ - 1)
                : Math::GMPz::Rmpz_divisible_p($t, Math::GMPz::Rmpz_init_set_str($_, 10) - 1)
    } @f) {
        next;
    }

    printf("a(%2d) <= %s\n", $omega, $n);
    $table{$omega} = $n;
}

dbmclose(%db);

say "\n=> Final results:\n";

foreach my $omega (sort { $a <=> $b } keys %table) {
    printf("a(%2d) <= %s\n", $omega, $table{$omega});
}

__END__
a( 9) <= 797365221484475174021
a(10) <= 1315856103949347820015303981
a(11) <= 6357507186189933506573017225316941
a(12) <= 77822245466150976053960303855104674781
a(13) <= 42864570625001423761497389323695509974049581
a(14) <= 34015651529746754841597629769101132590516759547941
a(15) <= 53986954871543199290951271756765558658193549930487667861
a(16) <= 372211648843530869309478857182933471340610763411260434889155250677395352719381
a(17) <= 110427674685927437817108251497693094618902101198115134640353672735578105723970886861
a(18) <= 361479302451078400254021057855931623278127324876622232946965482634473798228711263079246406052520856251316847512044390325279891860463605666138516582749771938719374800326247719703433981603248230018947627615518839888643424257
a(20) <= 50955937792672203508292419415695998424906653280935138075185150337054596635006794774907903405224183133830574863769274386123787911690833969968135567473330627306191443239487364467841338373858422112098400996697177300676521
