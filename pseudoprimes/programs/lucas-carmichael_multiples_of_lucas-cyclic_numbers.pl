#!/usr/bin/perl

# a(n) = least Lucas-Carmichael number which is divisible by b(n), where {b(n)} (A255602) is the list of all numbers which could be a divisor of a Lucas-Carmichael number.
# https://oeis.org/A253598

# See also:
#   https://oeis.org/A255602

# Upper-bounds > 2^64:
#   1191:     116301812274074491239
#   1623:     127460742488347071999

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Storable;
use Math::GMPz;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use experimental qw(signatures);

my @lucas_cyclic = grep {
    my $n = $_;
    vecall { gcd($n, $_ + 1) == 1 } factor($n)
} grep { is_square_free($_) } grep { $_ > 469 } grep { $_ % 2 == 1 } (1 .. 2000);
my $lucas_cyclic_lcm = Math::Prime::Util::GMP::lcm(@lucas_cyclic);

my %table;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    $n =~ /^[0-9]+\z/ or next;
    $n < ~0 or next;

    if (Math::Prime::Util::GMP::gcd($n, $lucas_cyclic_lcm) eq '1') {
        next;
    }

    (vecall { ($n + 1) % ($_ + 1) == 0 } factor($n)) || next;
    is_square_free($n)                               || next;

    foreach my $c (@lucas_cyclic) {
        if ($n % $c == 0) {
            if (not exists $table{$c} or $n < $table{$c}) {
                $table{$c} = $n;
            }
        }
    }
}

foreach my $key (sort { $a <=> $b } keys %table) {
    printf("%4d: %25s\n", $key, $table{$key});
}

my @unknown;

foreach my $c (@lucas_cyclic) {
    if (not exists $table{$c}) {
        push @unknown, $c;
    }
}

if (@unknown) {
    say "\nCouldn't find values for the following multiples: @unknown";
}

__END__
 471:             4131709859199
 479:                   5058719
 481:                 505863371
 485:                    218735
 487:                   1901735
 489:              532100807679
 491:                    966779
 493:                  10260809
 497:                    194327
 499:                  14970499
 503:                    761039
 505:                     20705
 509:                  11682059
 511:                  50168447
 515:                    760655
 517:                     18095
 521:                  31276151
 523:                2316562079
 527:                  43383167
 533:                     29315
 535:                    265895
 541:                4992691535
 543:              377049487359
 547:               96078393179
 551:                     60059
 553:                     12719
 557:                 185551739
 559:                   8421335
 563:                  65094623
 565:                 129477095
 569:                    973559
 571:                  25149695
 577:                5778659039
 579:             1019982346239
 583:                      2915
 587:                   2416679
 589:                 116628479
 593:                  85595399
 595:                     31535
 597:                6304359999
 599:                  11141999
 601:                 434886605
 607:                  50561279
 611:                  22575839
 613:                1645919099
 617:                1100831039
 619:                  49124459
 623:                   1017359
 629:                   2276351
 631:                    798215
 633:        649450807457655279
 635:                  78402815
 641:                1172426819
 643:                 178474295
 647:                   3354695
 649:                     46079
 651:                4962284607
 653:                5022676835
 655:                   8421335
 659:                   6959699
 661:                 193849487
 667:                     51359
 669:                3211164543
 671:                   5669279
 673:                 141070895
 677:                  96850943
 683:                  13081499
 685:                  39003215
 687:               24319371999
 689:                   3700619
 691:                2710757759
 697:                    120581
 701:                  13287455
 707:                 140096999
 709:                 239110959
 713:                      4991
 715:                     29315
 719:                   3106799
 721:                    760655
 723:                  25603599
 727:                  23287991
 731:                    588455
 733:               78372051407
 737:                     22847
 739:                 107732159
 741:             7710848622399
 743:                   1659119
 749:                    265895
 751:                 187498415
 755:                    390335
 757:               49569379679
 761:                  87562943
 763:                1566265799
 767:                   1915199
 769:                   6514199
 773:                  11368511
 777:             1778324753919
 779:                   2150819
 781:                     46079
 785:                  57872555
 787:                   1241099
 791:                  24205391
 793:                  30222023
 797:                   4452839
 799:                     90287
 803:                  16719263
 805:                      8855
 809:                   4587839
 811:                  11195855
 813:                 174550287
 815:                 240080255
 817:                      5719
 821:                 984624479
 823:                 105114383
 827:                   2055095
 829:                2596088939
 831:       3394263983671190271
 835:                   2048255
 839:                  14800799
 849:        261147917637896799
 851:                   6730559
 853:                 759786719
 857:                  13971671
 859:                 126325399
 863:                   9694079
 865:                1116663965
 869:                   6023039
 871:                  23176439
 877:               20271948839
 881:                   6994259
 883:                 603383039
 887:                 501737759
 889:                    162687
 893:                    895679
 899:                  12676799
 901:                     31535
 903:             2215225217919
 905:               45708573455
 907:                 285774839
 911:                  10801727
 913:                     20999
 917:                  42624911
 919:                 487842879
 921:               14970106227
 923:                   7366463
 929:                  33695759
 935:                       935
 937:               35847939959
 939:        160372803283722399
 941:              326947004999
 943:                  30071327
 947:                6613769399
 949:                 306871487
 953:                   7274249
 955:                     73535
 959:                  13971671
 965:                1840311935
 967:                   4681247
 971:                 796578299
 977:               22824172799
 979:                   1097459
 983:                  60939119
 985:                    117215
 989:                    588455
 991:                1218027199
 993:         22306627180026111
 997:               16070342903
1003:                    895679
1007:                   2756159
1009:                  35669159
1011:         69622135643825751
1013:                  90393029
1019:                 115372199
1021:                 142955315
1027:                   9486399
1031:                1759843799
1033:               62778871583
1037:                   3354695
1039:                  77801359
1043:                  54958799
1047:              286306774599
1049:                 135479399
1051:              135470012351
1055:                    760655
1057:                  61947599
1061:                1522283543
1063:                  29407895
1067:                    218735
1069:                  12583199
1073:                   4874639
1079:                    104663
1081:                     76751
1085:                1747955615
1087:                 240080255
1091:                 158453567
1093:                 888437399
1097:                1396023551
1099:                2770408655
1101:           914506843161999
1103:                  59668991
1105:                  49412285
1109:                 129255059
1111:                  13670855
1115:                   2048255
1117:                2291560127
1119:             2215225217919
1121:                     88559
1123:               96250502879
1129:                  29343839
1133:                1612670279
1135:                 461819015
1137:               37348274919
1141:                3075810815
1147:                 381626399
1151:                  25194239
1153:               15997348079
1157:                 939989609
1159:                1922689439
1163:                 565861139
1165:                   9868715
1171:              997794304415
1177:                    196559
1181:                3334906619
1187:                  16923059
1189:                   2581319
1193:               10197581471
1201:              572531110799
1205:               14605403735
1207:                    194327
1209:               84895311423
1211:                1046435999
1213:               20373173183
1217:                  69669599
1219:                    913031
1223:                  37425023
1227:              187243828239
1229:                 105818129
1231:                 295736671
1237:             1245426650579
1241:                 532070063
1243:                  50407379
1247:                 113024339
1249:                 485549999
1253:                   1256759
1255:                  11195855
1259:                   1587599
1261:                    104663
1263:          1707581786703519
1265:                      8855
1271:                  34562303
1273:                  26456759
1277:                 256226219
1279:                  62211839
1281:                    162687
1283:                3695056679
1285:                 102310415
1289:                 256074029
1291:                 178474295
1295:                 461819015
1297:               77924443519
1299:         72775040307526479
1301:                  49124459
1303:               22824172799
1307:                   1710863
1309:                   1710863
1313:                 279173999
1315:                  67418735
1317:              286306774599
1319:                   3483479
1321:               95663965319
1327:                 193849487
1333:                  29010079
1337:                     73535
1343:                   2193119
1349:                   9349919
1351:                1840311935
1355:                 240080255
1357:                  14800799
1361:                1925976959
1363:                   1707839
1367:                   3741479
1371:        714791836281522999
1373:                1439402399
1379:                    117215
1381:              221511111527
1385:           402906875366015
1387:                 850615199
1389:                  99467679
1391:                  57872555
1393:                 128912399
1397:                  54408959
1399:                  95972799
1403:                  30222023
1405:                 900744095
1407:            28050394272159
1409:                 669515939
1411:                      7055
1415:               18209964695
1417:                2906220239
1423:                 239110959
1427:                 279173999
1429:                3032510909
1433:                 310294655
1439:                 343979999
1443:               30073928079
1447:               22695814439
1451:                 250716839
1453:               25578000287
1457:                  38999519
1459:               96403747439
1461:            88330062057663
1463:                  24685199
1465:                4609544855
1469:                 252654779
1471:                 595462271
1477:                    760655
1481:                1501273409
1483:                 270696439
1487:                  73019135
1489:               18234757079
1493:               45598971599
1495:                   8421335
1497:              306307407999
1499:                   2249999
1501:                     88559
1505:                    588455
1507:               11882931599
1511:                 130225535
1513:                     80189
1517:                   7110179
1523:                7947283571
1529:                  10138799
1531:                3586258799
1533:                6587452767
1535:                  67418735
1537:                  35669159
1541:                    214199
1543:               88043680295
1549:                 890753999
1553:                4230625139
1555:                2061639215
1559:                 133763759
1565:             9059114946815
1567:                 130225535
1569:            12084948601239
1571:                 219797039
1577:                   1241099
1579:                  14970499
1583:                  20061359
1585:               30036458495
1589:                 108946607
1591:                   7110179
1597:                 119945879
1601:                  10260809
1603:                   8164079
1607:                  31010279
1609:                1111321819
1613:              208916200349
1619:                 338340239
1621:              143846925641
1627:                2452749683
1631:                 202767551
1633:                     76751
1637:                 356628635
1639:                     67199
1641:        821474220921489687
1643:                 103727519
1645:                     18095
1649:                   7234163
1651:                  32869759
1655:                 196377335
1657:                  30222023
1659:              108992419599
1661:                    390335
1663:                3259800959
1667:                 436548959
1669:               60301722719
1673:                  10210319
1677:             3157956598719
1679:                  81802559
1685:              288733827095
1687:                  25603599
1691:                   1097459
1693:                 306871487
1697:              103264532219
1699:                9667141799
1703:                   3700619
1705:                 287379455
1709:                   2924099
1711:                    152279
1713:            17156013520359
1721:                2723515199
1723:              245754407039
1727:                 696825503
1731:           430717758620799
1733:                5778659039
1735:                  18476015
1739:                   2276351
1741:              315349800479
1747:               19318062203
1751:                 202767551
1753:             5083021278719
1759:                  95972799
1763:                   7110179
1765:              103382437535
1767:                 189099039
1769:                 139098239
1771:                      8855
1777:               13228853399
1781:                 107556371
1783:               75173549759
1787:                 252419111
1789:              404717546519
1793:                3075810815
1799:                 275766911
1801:              207377944199
1803:         53399465726494719
1807:                  66709019
1811:                1834378199
1817:                     12719
1819:                   7234163
1821:             1778324753919
1823:                 282639743
1829:                  12676799
1831:              146348770399
1835:               15389361455
1837:                    196559
1839:         15187052332978239
1841:                 325428047
1843:                2616973379
1847:                1396023551
1853:                 679389479
1855:                     31535
1857:           908414916795399
1861:                  10397407
1865:                4379107655
1867:               53722314491
1871:                  84062159
1873:             2170525568639
1877:              181061935067
1879:                  17664479
1883:                3722941439
1889:                  10712519
1893:           570014742966591
1897:                 108946607
1901:                6345558911
1903:                  19716983
1907:                 800484227
1909:                     20999
1913:               11097953855
1915:                    147455
1919:                 115372199
1921:                     90287
1927:                  64456223
1929:              290679333699
1931:                 406647359
1933:              726969805631
1937:                 271038599
1939:              987831967199
1943:                  36981119
1949:                1181972999
1951:                4962284607
1955:                    588455
1957:                 189099039
1961:                 632648015
1963:                1171355471
1967:               10346390495
1969:                    966779
1973:                1250201315
1979:                  97962479
1981:               22644087935
1983:        128828457866303103
1985:              247545314495
1987:                1915827647
1991:                 677913599
1993:                  43716455
1997:                 107732159
1999:                 103949999

Couldn't find values for the following multiples: 1191 1623