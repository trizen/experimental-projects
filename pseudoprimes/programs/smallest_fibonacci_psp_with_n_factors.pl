#!/usr/bin/perl

# Smallest Fibonacci pseudoprime (A081264) with n distinct prime factors.
# https://oeis.org/A??????

=for comment

# Known terms:

a(2) = 323
a(3) = 6601
a(4) = 199801
a(5) = 3348961
a(6) = 88174801
a(7) = 10322470081
a(8) = 326853613801
a(9) = 7857271962001
a(10) = 979407603180721
a(11) = 158738531692547521
a(12) = 3006982463231713681
a(13) = 601918600714116172201
a(14) = 20911406891058505508401
a(15) = 6335172243104837566200481
a(16) = 810688644714741737639501521
a(17) = 126300964853108279279458299601
a(18) = 28529024297092847965351965617281

=cut

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;

use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);
use List::Util qw(uniq);

use POSIX qw(ULONG_MAX);

eval { require GDBM_File };

my $cache_db = "cache/factors.db";

dbmopen(my %db, $cache_db, 0444)
  or die "Can't create/access database <<$cache_db>>: $!";

my $n = Math::GMPz::Rmpz_init();

my %table = (
2 => 323,
3 => 6601,
4 => 199801,
5 => 3348961,
6 => 88174801,
7 => 10322470081,
8 => 326853613801,
9 => 7857271962001,
10 => 979407603180721,
11 => 158738531692547521,
12 => 3006982463231713681,
);

while (my ($key, $value) = each %db) {

    my @factors = split(' ', $value);
    my $k = scalar(uniq(@factors));

    $k > 12 or next;

    Math::GMPz::Rmpz_set_str($n, $key, 10);

    if (exists $table{$k} and $n > $table{$k}) {
        next;
    }

    my ($U, $V) = Math::Prime::Util::GMP::lucas_sequence($key, 1, -1, Math::Prime::Util::GMP::subint($key, Math::Prime::Util::GMP::kronecker(5, $key)));

    if ($U eq '0') {
        $table{$k} = Math::GMPz::Rmpz_init_set($n);
        say "a($k) <= $key";
    }
}

say "\n\n=> Final results:\n";

foreach my $k (sort { $a <=> $b } keys %table) {
    printf("a(%3d) <= %s\n", $k, $table{$k});
}

__END__
a(  2) <= 323
a(  3) <= 6601
a(  4) <= 199801
a(  5) <= 3348961
a(  6) <= 88174801
a(  7) <= 10322470081
a(  8) <= 326853613801
a(  9) <= 7857271962001
a( 10) <= 979407603180721
a( 11) <= 158738531692547521
a( 12) <= 3006982463231713681
a( 13) <= 601918600714116172201
a( 14) <= 20911406891058505508401
a( 15) <= 6335172243104837566200481
a( 16) <= 810688644714741737639501521
a( 17) <= 126300964853108279279458299601
a( 18) <= 28529024297092847965351965617281
a( 19) <= 14287665110893845187128087730769081281
a( 20) <= 1135663740519580816271564822375224080961
a( 21) <= 79613473932466820751588115231607675209921
a( 22) <= 7619194083151350296308427059103813641274401
a( 23) <= 7493054514365935533008722786753757974396267469761
a( 24) <= 38913748541484653932587190095110544858654839335201
a( 25) <= 107935822515098188899938642422259596478592756839041
a( 26) <= 138690511476138450211859035926940410021829006465401412077887
a( 27) <= 361016774668915000905912042732290960875805843546251187541216961
a( 28) <= 34059554569661360678634808741244653874653805478082549584030481
a( 29) <= 600966338640336491882445714470014907670475075819709696634761205164342401
a( 30) <= 2734976099551096702016242786666895792561876283208640954225724977107201
a( 31) <= 4637135553376433573648889947691691442534654343014247711674892597190554417501471023
a( 32) <= 101778044544745947283161540102430941341533604552291627727954557775805295922753458475939210925270547128542001
a( 33) <= 301285494122386597382666250099749390117285264344825591662971217367179268017100566274192703
a( 35) <= 241003528049863406849935457757728723753283696783245112036107450121978440608036189258417175424328721663
a( 36) <= 73656898456344320511103446480597304035500189799742710471397220560243496254349673041217856154748419281984951608020989504463
a( 37) <= 89819461310008781856520785573946353654816090372792846380916872498175058901674644073511803955074407697910993663
a( 39) <= 222959470672290520500550005211242424700005392416811560331982400814406312823787399280697052172857739278822551823224761488061698287632133580287
a( 40) <= 108167812349922639998991127465412794042173448580742162916689125790548999234605999585963186551509487225115286722950400721501672287893640878789001343
a( 41) <= 3461247370610557777265887575462112032580615493189025612160913448139744334851567429460467729114077430436010874187836115842526148392447
a( 42) <= 716806704680305877958740915396085382181900263366459502535072219060104572102123034175136407822397358608349797611008800256266013048063
a( 43) <= 10738689565994357858925325603187737597826899265574295415337585740551589413425620108162751960530008653551096211500515285369414340566546808736838951225851939962526454019327
a( 45) <= 12127753150443928669158246271750019778658731038914338311712362491309842027367781740426017390225480298741875714028498819978750463
a( 46) <= 5289317030813845025030136441759313676350437291809581944424604404172556336793009975663443300209602618534779461700271078886792582401