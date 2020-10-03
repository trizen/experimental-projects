#!/usr/bin/perl

use utf8;
use strict;
use warnings;

die "Usage: $0 <file_name>\n\nOptions:
\t-o   : output name (default: output.txt)
\nExample: $0 list.txt -o new_list.txt\n" unless @ARGV;

my @output = map { $ARGV[$_ + 1] if $ARGV[$_] eq '-o' } 0 .. $#ARGV;

my $outname = $output[1] || 'output.txt';

my $string;
my @file_name = grep -f $_, @ARGV;
sysopen FILE, $file_name[0], 0;
sysread FILE, $string, -s $file_name[0];

=cut
$string = "SI si-am intr-un CERCETATORI valabilitati ingradite implicati gandit
Calarasi cladire eu daca cineva merge
si acasa, acela esti tu sau nu _ESTI? tu? vrajiti? indragostiti.
Codul sursa este pe cale sa sara in aer! Ti-am lasat masina parcata.
Ce masina frumoasa ai! :)
Asta e noua ta masina?
Asa iti tratezi masina?";
=cut

# Ș = \x{0218}
# ș = \x{0219}
# Ț = \x{021A}
# ț = \x{021B}
# Ă = \x{0102}
# ă = \x{0103}
# Â = \x{00C2}
# â = \x{00E2}
# Î = \x{00CE}
# î = \x{00EE}

my %table = (
             'acasa',            'acasă',            'asa',              'așa',
             'acelasi',          'acelaşi',          'acelasi',          'același',
             'sara',             'sară',             'aceleasi',         'aceleași',
             'acestia',          'aceştia',          'actionat',         'acționat',
             'adanc',            'adânc',            'adapost',          'adăpost',
             'adaugat',          'adăugat',          'adevar',           'adevăr',
             'adevarat',         'adevărat',         'adevarate',        'adevărate',
             'adevarul',         'adevărul',         'agatat',           'agățat',
             'aia',              'ăia',              'ajutatoare',       'ajutătoare',
             'ajutator',         'ajutător',         'ala',              'ăla',
             'alaturi',          'alături',          'amanare',          'amânare',
             'amandoi',          'amândoi',          'amandoua',         'amândouă',
             'amani',            'amâni',            'amenintat',        'amenințat',
             'amortit',          'amorțit',          'anunt',            'anunț',
             'anuntari',         'anunțări',         'anuntat',          'anunțat',
             'anunturi',         'anunțuri',         'apartinut',        'aparținut',
             'aparut',           'apărut',           'arat',             'arăt',
             'aratari',          'arătări',          'aratat',           'arătat',
             'arati',            'arăți',            'ascultator',       'ascultător',
             'asemanatoare',     'asemănătoare',     'asemanator',       'asemănător',
             'asta-seara',       'astă-seară',       'asteapta',         'așteaptă',
             'astept',           'aștept',           'astepta',          'aștepta',
             'asteptate',        'aşteptate',        'astia',            'ăștia',
             'atat',             'atât',             'atata',            'atâta',
             'atatea',           'atâtea',           'atatia',           'atâția',
             'ati',              'ați',              'autodistruga',     'autodistrugă',
             'baiat',            'băiat',            'baietel',          'băiețel',
             'baietelul',        'băiețelul',        'baieti',           'băieți',
             'barbat',           'bărbat',           'barbati',          'bărbați',
             'barbatii',         'bărbații',         'barbatul',         'bărbatul',
             'batran',           'bătrân',           'batrane',          'bătrâne',
             'batrani',          'bătrâni',          'batranii',         'bătrânii',
             'batranul',         'bătrânul',         'batut',            'bătut',
             'batute',           'bătute',           'batuti',           'bătuți',
             'baut',             'băut',             'baute',            'băute',
             'bauti',            'băuți',            'beti',             'beți',
             'ca-mi',            'că-mi',            'caine',            'câine',
             'cainele',          'câinele',          'caini',            'câini',
             'cainii',           'câinii',           'cainilor',         'câinilor',
             'calarasi',         'călărași',         'calare',           'călare',
             'calaret',          'călăreț',          'calarete',         'călărețe',
             'calareti',         'călăreți',         'calatoresc',       'călătoresc',
             'calatorie',        'călătorie',        'calatorii',        'călătorii',
             'caldut',           'călduț',           'calmati',          'calmați',
             'camasa',           'cămașa',           'camasi',           'cămași',
             'camile',           'cămile',           'camp',             'câmp',
             'campul',           'câmpul',           'cant',             'cânt',
             'cantare',          'cântare',          'cantari',          'cântări',
             'cantat',           'cântat',           'cantate',          'cântate',
             'cantec',           'cântec',           'cantece',          'cântece',
             'cantecele',        'cântecele',        'cantecul',         'cântecul',
             'capacitati',       'capacități',       'capacitatii',      'capacității',
             'capata',           'căpăta',           'capitane',         'căpitane',
             'carat',            'cărat',            'careia',           'căreia',
             'carora',           'cărora',           'cartite',          'cârtițe',
             'cartitei',         'cârtiței',         'cartitele',        'cârtițele',
             'cartitelor',       'cârtițelor',       'carturar',         'cărturar',
             'casatorit',        'căsătorit',        'casatorite',       'căsătorite',
             'casatoriti',       'căsătoriți',       'castigat',         'câștigat',
             'cat',              'cât',              'cate',             'câte',
             'catea',            'cățea',            'catele',           'cățele',
             'catelelor',        'cățelelor',        'cateodata',        'câteodată',
             'cateva',           'câteva',           'cati',             'câți',
             'cativa',           'câțiva',           'catre',            'către',
             'cautat',           'căutat',           'cauti',            'cauți',
             'cazut',            'căzut',            'ce-ti',            'ce-ți',
             'cercetator',       'cercetător',       'cercetatori',      'cercetători',
             'cheama',           'cheamă',           'chitcan',          'chițcan',
             'chitcani',         'chițcani',         'chitcanii',        'chițcanii',
             'citeste-mi',       'citește-mi',       'citesti',          'citești',
             'cladesc',          'clădesc',          'cladire',          'clădire',
             'coborati',         'coborâți',         'coincidente',      'coincidențe',
             'constanta',        'constanța',        'constiinta',       'conștiința',
             'conversatie',      'conversație',      'convingator',      'convingător',
             'copila',           'copilă',           'copilaros',        'copilăros',
             'creada',           'creadă',           'crede-ma',         'crede-mă',
             'credinciosi',      'credincioşi',      'credinciosii',     'credincioşii',
             'creste',           'crește',           'crestin',          'creștin',
             'crestinii',        'creștinii',        'cumparat',         'cumpărat',
             'cunoaste',         'cunoaşte',         'cunostiinte',      'cunoştiințe',
             'cunostinte',       'cunoștințe',       'cunostintele',     'cunoștințele',
             'cunostintelor',    'cunoștințelor',    'curand',           'curând',
             'cuvant',           'cuvânt',           'da-i',             'dă-i',
             'daca',             'dacă',             'daruit',           'dăruit',
             'dati',             'dați',             'dati-o',           'dați-o',
             'decat',            'decât',            'decedati',         'decedați',
             'deceptie',         'decepție',         'declansate',       'declanşate',
             'definitia',        'definiția',        'definitie',        'definiție',
             'degraba',          'degrabă',          'depaseau',         'depășeau',
             'desi',             'deși',             'destept',          'deștept',
             'destepte',         'deștepte',         'destepti',         'deștepți',
             'devina',           'devină',           'digerati',         'digerați',
             'dimineata',        'dimineața',        'dimineti',         'dimineți',
             'disparut',         'dispărut',         'disperati',        'disperați',
             'domnisoare',       'domnișoare',       'domnisor',         'domnișor',
             'domnisori',        'domnișori',        'doreste',          'dorește',
             'dragut',           'drăguț',           'dragute',          'drăguțe',
             'dragutele',        'drăguțele',        'dragutelor',       'drăguțelor',
             'draguti',          'drăguți',          'dragutii',         'drăguții',
             'dupa',             'după',             'egoisti',          'egoiști',
             'emotie',           'emoție',           'emotii',           'emoții',
             'esti',             'ești',             'evolutie',         'evoluție',
             'examinati',        'examinaţi',        'exercitiul',       'exercițiul',
             'experimentati',    'experimentați',    'experimentatii',   'experimentații',
             'experimentatilor', 'experimentaților', 'fa',               'fă',
             'fa-i',             'fă-i',             'fa-le',            'fă-le',
             'fa-mi',            'fă-mi',            'fa-o',             'fă-o',
             'fa-ti',            'fă-ți',            'faca',             'facă',
             'facand',           'făcând',           'facea',            'făcea',
             'faceam',           'făceam',           'faceau',           'făceau',
             'faceti',           'faceți',           'facilitati',       'facilități',
             'facilitatii',      'facilității',      'facilitatile',     'facilitățile',
             'facut',            'făcut',            'fara',             'fără',
             'fara-ncetare',     'fără-ncetare',     'felatie',          'felație',
             'felatii',          'felații',          'felicitari',       'felicitări',
             'felicitarile',     'felicitările',     'fictiunea',        'ficțiunea',
             'fortele',          'forțele',          'fortos',           'forțos',
             'fractiune',        'fracțiune',        'frati',            'frați',
             'fratii',           'frații',           'fratilor',         'fraților',
             'furiosi',          'furioși',          'gandeasca',        'gândească',
             'gandesti',         'gândești',         'gandire',          'gândire',
             'gandit',           'gândit',           'gasesc',           'găsesc',
             'gaseste',          'gasește',          'gasi',             'găsi',
             'gasim',            'găsim',            'gasire',           'găsire',
             'gasit',            'găsit',            'gasiti',           'găsiți',
             'generati',         'generați',         'glumesti',         'glumești',
             'gramezi',          'grămezi',          'granite',          'granițe',
             'grau',             'grâu',             'gravitatie',       'gravitație',
             'gravitatiei',      'gravitației',      'greseli',          'greșeli',
             'gresit',           'greșit',           'gresite',          'greșite',
             'gresiti',          'greșiți',          'hartia',           'hârtia',
             'hartie',           'hârtie',           'hartii',           'hârtii',
             'hartiile',         'hârtiile',         'hot',              'hoț',
             'hotarator',        'hotărător',        'i-as',             'i-aș',
             'iarta-ma',         'iartă-mă',         'iasi',             'iași',
             'iata',             'iată',             'ii',               'îi',
             'il',               'îl',               'imbat',            'îmbăt',
             'imbratisare',      'îmbrățișare',      'imbratisata',      'îmbrățișată',
             'imbratisez',       'îmbrățișez',       'imi',              'îmi',
             'imperecheat',      'împerecheat',      'imperecheati',     'împerecheați',
             'imperechere',      'împerechere',      'imperecheri',      'împerecheri',
             'impiedicat',       'împiedicat',       'impiedicate',      'împiedicate',
             'impiedicati',      'împiedicați',      'impins',           'împins',
             'implicati',        'implicați',        'implicatiile',     'implicațiile',
             'impotriva',        'împotriva',        'impreuna',         'împreună',
             'in',               'în',               'inafara',          'înafară',
             'inaintare',        'înaintare',        'inaintari',        'înaintări',
             'inainte',          'înainte',          'inalt',            'înalt',
             'inalte',           'înalte',           'inalti',           'înalți',
             'inapoi',           'înapoi',           'inca',             'încă',
             'incalc',           'încalc',           'incapatanare',     'încăpățânare',
             'incapatanarea',    'încăpățânarea',    'incapatanari',     'încăpățânari',
             'incapatanat',      'încăpățânat',      'incapatanate',     'încăpățânate',
             'incat',            'încât',            'incearca',         'încearcă',
             'incoa',            'încoa',            'incoace',          'încoace',
             'inconjurat',       'înconjurat',       'incotro',          'încotro',
             'incununat',        'încununat',        'incununati',       'încununați',
             'indeplinesc',      'îndeplinesc',      'inecat',           'înecat',
             'infrant',          'înfrânt',          'ingerati',         'ingerați',
             'inghetat',         'înghețat',         'inghetate',        'înghețate',
             'inghetati',        'înghețați',        'ingradire',        'îngrădire',
             'ingradit',         'îngrădit',         'ingradite',        'îngrădite',
             'ingraditi',        'îngrădiți',        'ingust',           'îngust',
             'ingustat',         'îngustat',         'inguste',          'înguste',
             'ingusti',          'înguști',          'inlocui',          'înlocui',
             'inlocuieste',      'înlocuiește',      'inlocuit',         'înlocuit',
             'inmormantare',     'înmormântare',     'inmormantat',      'înmormântat',
             'inmormantate',     'înmormântate',     'inmormantati',     'înmormântați',
             'insa',             'însă',             'insangerat',       'însângerat',
             'insangerati',      'însângerați',      'inscris',          'înscris',
             'inseamna',         'înseamnă',         'insemna',          'însemna',
             'insemni',          'însemni',          'insurat',          'însurat',
             'insuti',           'însuți',           'intai',            'întâi',
             'intalni',          'întâlni',          'intalnire',        'întâlnire',
             'intalnit',         'întâlnit',         'intamplare',       'întâmplare',
             'intamplari',       'întâmplări',       'intamplat',        'întâmplat',
             'intarziat',        'întârziat',        'intarziere',       'întârziere',
             'inteleg',          'înteleg',          'inteleg',          'înțeleg',
             'intelegator',      'înțelegător',      'intelegi',         'întelegi',
             'intelegi',         'înțelegi',         'intelese',         'înțelese',
             'intelesi',         'înțeleși',         'interactionari',   'interacționări',
             'interactionarii',  'interacționării',  'interactionarile', 'interacționările',
             'interactioneaza',  'interacționează',  'interfata',        'interfața',
             'intoarcem',        'întoarcem',        'intors',           'întors',
             'intotdeauna',      'întotdeauna',      'intrebandu-ma',    'întrebându-mă',
             'intrebari',        'întrebări',        'intrebarii',       'întrebării',
             'intrebarile',      'întrebările',      'intrebat',         'întrebat',
             'intrebati',        'întrebați',        'intrebi',          'întrebi',
             'intreg',           'întreg',           'intregi',          'întregi',
             'intregul',         'întregul',         'intreguri',        'întreguri',
             'intruna',          'întruna',          'intunecat',        'întunecat',
             'intunecati',       'întunecați',       'intuneric',        'întuneric',
             'intunericului',    'întunericului',    'invatat',          'învățat',
             'invatate',         'învățate',         'invatati',         'învățați',
             'invatatoare',      'învățătoare',      'invatator',        'învățator',
             'isi',              'își',              'iti',              'îți',
             'iubeste',          'iubește',          'iubesti',          'iubești',
             'jurnalisti',       'jurnalişti',       'jurnalisti',       'jurnaliști',
             'jurnalistii',      'jurnaliştii',      'l-ati',            'l-ați',
             'langa',            'lângă',            'largit',           'lărgit',
             'lasandu-te',       'lăsându-te',       'lasat',            'lăsat',
             'lasate',           'lăsate',           'le-ati',           'le-ați',
             'leganare',         'legănare',         'leganari',         'legănări',
             'leganat',          'legănat',          'legaturi',         'legături',
             'liniste',          'liniște',          'linisteste-te',    'liniștește-te',
             'luam',             'luăm',             'lucrator',         'lucrător',
             'lumanare',         'lumânare',         'lumanari',         'lumânări',
             'lumanarii',        'lumânării',        'lumanarile',       'lumânările',
             'lupti',            'lupți',            'luptii',           'lupții',
             'ma',               'mă',               'ma-ncurajezi',     'mă-ncurajezi',
             'maimuta',          'maimuța',          'maimute',          'maimuțe',
             'maimutele',        'maimuțele',        'maimutelor',       'maimuțelor',
             'maimutica',        'maimuțică',        'maimutoi',         'maimuțoi',
             'maine',            'mâine',            'maini',            'mâini',
             'mainii',           'mâinii',           'mainiile',         'mâiniile',
             'mainile',          'mâinile',          'manance',          'mănânce',
             'mancat',           'mâncat',           'mareasca',         'mărească',
             'marit',            'mărit',            'marunt',           'mărunt',
             'marunte',          'mărunte',          'marunteste',       'mărunțește',
             'maruntit',         'mărunțit',         'mentinand',        'menținând',
             'mentinandu-i',     'menținându-i',     'mentinandu-le',    'menținându-le',
             'mentinandu-si',    'menținându-şi',    'mincinosi',        'mincinoşi',
             'mincinosii',       'mincinoşii',       'mincinosiilor',    'mincinoşiilor',
             'mincinosilor',     'mincinoşilor',     'minti',            'minți',
             'miscare',          'mișcare',          'miscari',          'mișcări',
             'miscati',          'mișcați',          'miste',            'miște',
             'modificari',       'modificări',       'modificarile',     'modificările',
             'modificarilor',    'modificărilor',    'morti',            'morți',
             'mostenire',        'moștenire',        'mosteniri',        'moșteniri',
             'mostenitor',       'moștenitor',       'multi',            'mulți',
             'multiile',         'mulțiile',         'multile',          'mulțile',
             'multime',          'mulțime',          'multimi',          'mulțimi',
             'multumesc',        'mulțumesc',        'multumeste',       'mulțumește',
             'multumit',         'mulțumit',         'muste',            'muște',
             'muti',             'muți',             'n-as',             'n-aș',
             'nascut',           'născut',           'nascute',          'născute',
             'nascuti',          'născuți',          'nasti',            'naști',
             'natiuni',          'națiuni',          'natiunilor',       'națiunilor',
             'neagra',           'neagră',           'nepasare',         'nepăsare',
             'niste',            'niște',            'normala',          'normală',
             'norocosi',         'norocoși',         'noteaza',          'notează',
             'notite',           'notițe',           'notitele',         'notițele',
             'nu-si',            'nu-și',            'nu-ti',            'nu-ți',
             'numar',            'număr',            'numeste',          'numește',
             'obisnuia',         'obișnuia',         'obisnuinte',       'obișnuințe',
             'obisnuit',         'obișnuit',         'obisnuite',        'obișnuite',
             'obtinere',         'obținere',         'obtinut',          'obținut',
             'odata',            'odată',            'ofera',            'oferă',
             'omorasera',        'omorâseră',        'omorat',           'omorât',
             'omorate',          'omorâte',          'omorati',          'omorâți',
             'omori',            'omorî',            'operatiuni',       'operațiuni',
             'operatiunile',     'operațiunile',     'operatiunilor',    'operațiunilor',
             'opreasca',         'oprească',         'opreste',          'oprește',
             'opreste-te',       'oprește-te',       'oras',             'oraș',
             'orase',            'orașe',            'organizatie',      'organizație',
             'oricand',          'oricând',          'oricarei',         'oricărei',
             'oricat',           'oricât',           'ovaz',             'ovăz',
             'paduchi',          'păduchi',          'paine',            'pâine',
             'paini',            'pâini',            'painile',          'pâinile',
             'pamant',           'pământ',           'parasesc',         'părăsesc',
             'paraseste',        'părăsește',        'parasit',          'părăsit',
             'parasiti',         'părăsiți',         'parasute',         'parașute',
             'parca',            'parcă',            'parea',            'părea',
             'parere',           'părere',           'parerea',          'părerea',
             'pareri',           'păreri',           'parghie',          'pârghie',
             'parghii',          'pârghii',          'parghiile',        'pârghiile',
             'parghiilor',       'pârghiilor',       'parghile',         'pârghile',
             'parghilor',        'pârghilor',        'parinte',          'părinte',
             'parinti',          'părinți',          'parintii',         'părinții',
             'parti',            'părți',            'particica',        'părticică',
             'pasi',             'paşi',             'pasii',            'paşii',
             'pastrand',         'păstrând',         'pastrandu-i',      'păstrându-i',
             'pastrandu-le',     'păstrându-le',     'pastrandu-si',     'păstrându-si',
             'patruns',          'pătruns',          'perfecti',         'perfecți',
             'perfectie',        'perfecție',        'perfectionari',    'perfecționări',
             'perfectionarii',   'perfecționării',   'perfectionariile', 'perfecționăriile',
             'perfectionarile',  'perfecționările',  'pesti',            'pești',
             'pestii',           'peștii',           'pestisor',         'peștișor',
             'piete',            'piețe',            'pieti',            'pieți',
             'pietii',           'pieții',           'placea',           'plăcea',
             'placere',          'plăcere',          'placinte',         'plăcinte',
             'plaman',           'plămân',           'plamani',          'plămâni',
             'plang',            'plâng',            'plange',           'plânge',
             'plangi',           'plângi',           'platit',           'plătit',
             'plecam',           'plecăm',           'porcarie',         'porcărie',
             'porcarii',         'porcării',         'poti',             'poți',
             'potoleste-te',     'potolește-te',     'povesti',          'povești',
             'pozitie',          'poziție',          'pozitii',          'poziții',
             'pozitiilor',       'pozițiilor',       'pozitilor',        'poziților',
             'pozitionati',      'poziționați',      'prajit',           'prăjit',
             'prajite',          'prăjite',          'prajiti',          'prăjiți',
             'prajituri',        'prăjituri',        'pregati',          'pregăti',
             'pregatit',         'pregătit',         'pregatita',        'pregătită',
             'pregatiti',        'pregătiți',        'prelucrati',       'prelucrați',
             'presedinte',       'președinte',       'pretuit',          'prețuit',
             'pretuite',         'prețuite',         'pretul',           'prețul',
             'preturi',          'prețuri',          'preturile',        'prețurile',
             'print',            'prinț',            'priveste',         'privește',
             'proaspat',         'proaspăt',         'prostut',          'prostuț',
             'protectie',        'protecție',        'protectiei',       'protecției',
             'protectii',        'protecții',        'publicatie',       'publicație',
             'publicatiei',      'publicației',      'puneti',           'puneți',
             'purtator',         'purtător',         'purtatori',        'purtători',
             'pusi',             'puşi',             'putin',            'puțin',
             'putine',           'puține',           'puturosi',         'puturoși',
             'rabdare',          'răbdare',          'rabdator',         'răbdător',
             'racire',           'răcire',           'rahati',           'rahați',
             'rahatii',          'rahații',          'raman',            'rămân',
             'ramane',           'rămâne',           'ramasesem',        'rămăsesem',
             'rand',             'rând',             'randul',           'rândul',
             'rani',             'răni',             'raniri',           'răniri',
             'ranit',            'rănit',            'ranite',           'rănite',
             'raniti',           'răniți',           'raspunde',         'răspunde',
             'raspundere',       'răspundere',       'raspuns',          'răspuns',
             'raspunsuri',       'răspunsuri',       'rasucire',         'răsucire',
             'rasuciri',         'răsuciri',         'rasucit',          'răsucit',
             'ratacit',          'rătăcit',          'rataciti',         'rătăciți',
             'reactie',          'reacție',          'recapata',         'recăpăta',
             'recunoasterea',    'recunoaşterea',    'refugiatilor',     'refugiaților',
             'regasire',         'regăsire',         'relatie',          'relație',
             'relatii',          'relații',          'reprezinta',       'reprezintă',
             'reusesc',          'reușesc',          'reusi',            'reuși',
             'reusim',           'reușim',           'reusit',           'reuşit',
             'reusit',           'reușit',           'reusite',          'reușite',
             'reusiti',          'reușiți',          'revad',            'revăd',
             'reveniti',         'reveniți',         'reveniti-va',      'reveniți-vă',
             'rosesti',          'roșești',          'rosie',            'roșie',
             'rosu',             'roșu',             'sa-i',             'să-i',
             'sa-l',             'să-l',             'sa-mi',            'să-mi',
             'sa-si',            'să-și',            'sa-ti',            'să-ți',
             'sai',              'săi',              'salbatic',         'sălbatic',
             'salbatici',        'sălbatici',        'salveaza',         'salvează',
             'salveaza-ma',      'salvează-mă',      'salveaza-ti',      'salvează-ți',
             'sanatatea',        'sănătatea',        'saptamani',        'săptămâni',
             'sarim',            'sărim',            'sarit',            'sărit',
             'saritura',         'săritura',         'sarituri',         'sărituri',
             'sariturile',       'săriturile',       'saturat',          'săturat',
             'scolar',           'școlar',           'scolari',          'școlari',
             'scoli',            'școli',            'scuza-ma',         'scuză-mă',
             'scuzati',          'scuzați',          'scuzati-i',        'scuzați-i',
             'scuzati-le',       'scuzați-le',       'scuzati-ma',       'scuzați-ma',
             'scuzati-ma',       'scuzați-mă',       'sef',              'șef',
             'sfant',            'sfânt',            'sfantul',          'sfântul',
             'sfarsit',          'sfârşit',          'sfarsit',          'sfârșit',
             'sfarsite',         'sfârşite',         'sfarsitele',       'sfârşitele',
             'sfarsiti',         'sfârşiți',         'sfarsitul',        'sfârşitul',
             'sfarsituri',       'sfârşituri',       'sfatuiesc',        'sfătuiesc',
             'sfiala-n',         'sfială-n',         'si',               'și',
             'si-am',            'și-am',            'si-mi',            'și-mi',
             'si-o',             'și-o',             'si-un',            'și-un',
             'sigura',           'sigură',           'sigurante',        'siguranțe',
             'simte-ma',         'simte-mă',         'slabiti',          'slăbiți',
             'slavesti',         'slăvești',         'soc',              'șoc',
             'soparle',          'şopârle',          'soparlele',        'şopârlele',
             'soparlelor',       'şopârlelor',       'sosea',            'șosea',
             'spalare',          'spălare',          'spalari',          'spălări',
             'spalat',           'spălat',           'spalati',          'spălați',
             'speciala',         'specială',         'spunand',          'spunând',
             'sta',              'stă',              'stalp',            'stâlp',
             'stati',            'stați',            'statiei',          'stației',
             'statii',           'stații',           'stationar',        'staționar',
             'stationeaza',      'staționează',      'sti',              'ști',
             'stia',             'știa',             'stiai',            'știai',
             'stiam',            'știam',            'stiau',            'știau',
             'stie',             'știe',             'stii',             'știi',
             'stiintifica',      'științifică',      'stim',             'știm',
             'stiri',            'știri',            'stirilor',         'știrilor',
             'stiu',             'știu',             'stramosi',         'strămoşi',
             'stramosii',        'strămoşii',        'stramosilor',      'strămoşilor',
             'stramutati',       'strămutați',       'subtitrari',       'subtitrări',
             'supravietui',      'supraviețui',      'supravietuiasca',  'supraviețuiască',
             'supravietuieste',  'supravieţuieşte',  'supravietuire',    'supravieţuire',
             'supravietuit',     'supraviețuit',     'supravietuitor',   'supraviețuitor',
             'surprinsi',        'surprinşi',        'surprinsii',       'surprinşii',
             'surprinsiilor',    'surprinşiilor',    'surprinsilor',     'surprinşilor',
             'sustine',          'susține',          'tacut',            'tăcut',
             'tacuti',           'tăcuți',           'taia',             'tăia',
             'taiam',            'tăiam',            'taiat',            'tăiat',
             'taiate',           'tăiate',           'taiati',           'tăiați',
             'taiem',            'tăiem',            'talhar',           'tâlhar',
             'talhari',          'tâlhari',          'talharul',         'tâlharul',
             'tampite',          'tâmpite',          'tanar',            'tânăr',
             'targ',             'târg',             'targu',            'târgu',
             'targuiai',         'târguiai',         'targul',           'târgul',
             'tari',             'țări',             'tarile',           'țările',
             'tatal',            'tatăl',            'tau',              'tău',
             'te-as',            'te-aș',            'telefonica',       'telefonică',
             'termica',          'termică',          'ti',               'ți',
             'ti-a',             'ți-a',             'ti-ai',            'ți-ai',
             'ti-am',            'ți-am',            'ti-ar',            'ți-ar',
             'ti-as',            'ți-aș',            'ti-e',             'ți-e',
             'tie',              'ție',              'tigan',            'țigan',
             'tiganci',          'țigănci',          'tigani',           'țigani',
             'tigari',           'țigări',           'tigarile',         'țigările',
             'timisoara',        'timișoara',        'tin',              'țin',
             'tinand',           'ținând',           'tine-ti',          'ține-ți',
             'tine-ti-i',        'ține-ți-i',        'tinem',            'ținem',
             'tineti',           'țineți',           'tineti-i',         'țineți-i',
             'tobosar',          'toboșar',          'tobosarului',      'toboșarului',
             'toti',             'toți',             'totii',            'toții',
             'totusi',           'totuşi',           'tradeaza',         'trădează',
             'traiesc',          'trăiesc',          'traieste',         'trăiește',
             'traiesti',         'trăiești',         'traire',           'trăire',
             'trait',            'trăit',            'traita',           'trăită',
             'transplantand',    'transplantând',    'trecatoare',       'trecătoare',
             'trecator',         'trecător',         'trefla',           'treflă',
             'tristi',           'triști',           'tufisuri',         'tufișuri',
             'turnati',          'turnați',          'uita-te',          'uită-te',
             'uiti',             'uiți',             'urasc',            'urăsc',
             'uraste',           'urăște',           'urasti',           'urăști',
             'urgente',          'urgențe',          'urmatoare',        'următoare',
             'urmatoarea',       'următoarea',       'urmatoarele',      'următoarele',
             'uscator',          'uscător',          'usile',            'ușile',
             'usoare',           'ușoare',           'usor',             'ușor',
             'usori',            'ușori',            'usuratice',        'ușuratice',
             'v-ati',            'v-ați',            'vad',              'văd',
             'vada',             'vadă',             'varf',             'vârf',
             'variatie',         'variație',         'variatii',         'variații',
             'variatilor',       'variaților',       'varsator',         'vărsător',
             'varuit',           'văruit',           'vatamat',          'vătămat',
             'vaz',              'văz',              'vazut',            'văzut',
             'veniti',           'veniți',           'venitii',          'veniții',
             'venitilor',        'veniților',        'vesti',            'vești',
             'viata-i',          'viața-i',          'vietati',          'vietăți',
             'vieti',            'vieți',            'vietile',          'viețile',
             'vietuind',         'viețuind',         'vietuitoare',      'viețuitoare',
             'vietuitor',        'viețuitoare',      'visator',          'visător',
             'vreodata',         'vreodată',         'zambesc',          'zâmbesc',
             'zambeste',         'zâmbește',         'zambesti',         'zâmbești',
             'zambet',           'zâmbet',           'zapacit',          'zăpăcit',
             'indragostiti',     'îndrăgostiți',     'politia',          'poliția',
             'zane',             'zâne',             'varcolac',         'vârcolac',
             'varcolaci',        'vârcolaci',        'varcolacii',       'vârcolacii',
             'mos',              'moș',              'indeplineste',     'îndeplinește',
             'dorinte',          'dorințe',          'asteptai',         'așteptai',
             'frumusete',        'frumusețe'
            );

my @words = split(/(\s+)/, $string);

for my $word (@words) {

    next if $word =~ /^\W/o;

    my $wordbk = $word;
    $wordbk =~ s/[^a-zA-Z-]+//go;
    $wordbk = lc $wordbk;

    next unless exists $table{$wordbk};

    my $word_without_diac = $wordbk;
    my $word_with_diac    = $table{$wordbk};

    foreach my $mode (qw(ucfirst uc lowercase)) {
        if ($mode eq 'uc') {
            $word_with_diac    = uc($word_with_diac);
            $word_without_diac = uc($word_without_diac);
        }
        elsif ($mode eq 'ucfirst') {
            $word_with_diac    = ucfirst($word_with_diac);
            $word_without_diac = ucfirst($word_without_diac);
        }
        else {
            $word_with_diac    = lc($word_with_diac);
            $word_without_diac = lc($word_without_diac);
        }

        my @array1 = split(//, $word_without_diac);
        my @array2 = split(//, $word_with_diac);

        my $n = 0;
        my @difference;
        for (@array1) {
            if ($array2[$n] ne $_) {
                push(@difference, $n);
            }
            else {
                s/$_/([\u$_\l$_\E])/;
            }
            ++$n;
        }

        $n = 0;
        my $final;
        for my $i (0 .. $#array1) {
            if (grep { $_ eq $i } @difference) {
                $final .= "-";
            }
            else {
                ++$n;
                $final .= "\$$n";
            }
        }

        for (@difference) {
            $final =~ s/-/$array2[$_]/;
        }

        my $rx = join('', @array1);
        eval qq[\$word =~ s/$rx/$final/;];
    }
}

$string = join('', @words);
$string =~ s/([^ie])a-n\b/$1ă-n/g;                                   #'apa-n vas'-> 'apă-n vas'
$string =~ s/de(\s+)([^\s.]+)a-i\b/de$1$2ă-i/g;                      # 'de trista-i' -> 'de tristă-i'
$string =~ s/\bca\b/că/g;                                            # ca -> că
$string =~ s/\bcă(\s+)([^\s]+(un|o)|o|un|tine)\b/ca$1$2/g;           # că -> ca ('că o floare':replace && 'că nu vreau':ignore)
$string =~ s/a-ti\b/ă-ți/g;                                          # a-ti -> ă-ți
$string =~ s/ince([pra])/înce$1/g;                                   # incercat -> încercat
$string =~ s/Ince([pra])/Înce$1/g;                                   # Incercat -> Încercat
$string =~ s/cand([^aie])/când$1/g;                                  # cand -> când ('scandura':replace && 'scandal':ignore)
$string =~ s/\bdespartiti/depărțiți/g;                               # despartiti -> despărțiți
$string =~ s/\Bsani\b/șani/g;                                        # botosani -> botoșani
$string =~ s/\Baldu\B/ăldu/g;                                        # calduros -> călduros
$string =~ s/\bstang/stâng/g;                                        # stangaci -> stângaci
$string =~ s/\binchi\B/închi/g;                                      # inchis -> închis
$string =~ s/\Bisi\b/iși/g;                                          # admisi -> admiși
$string =~ s/\binfom\B/înfom/g;                                      # infometat -> înfometat
$string =~ s/\bInfom\B/Înfom/g;                                      # Infometat -> Înfometat
$string =~ s/\Btiosi/țioși/g;                                        # pretentiosii -> pretențioșii
$string =~ s/\Btioas/țioas/g;                                        # pretioase -> prețioase
$string =~ s/\Btion\B/țion/g;                                        # evolutionism -> evoluționism
$string =~ s/\Beaza/ează/g;                                          # oxideaza -> oxidează
$string =~ s/\binain/înain/g;                                        # inainte -> înainte
$string =~ s/\bInain/Înain/g;                                        # Inainte -> Înainte
$string =~ s/\binreg/înreg/g;                                        # inregistrez -> înregistrez
$string =~ s/\bInreg/Înreg/g;                                        # Inregistrez -> Înregistrez
$string =~ s/\binn([^\s]{2,})\b/înn$1/g;                             # innebunit -> înnebunit && inna: ignore
$string =~ s/\bInn([^\s]{2,})\b/Înn$1/g;                             # Innebunit -> Înnebunit && Inna: ignore
$string =~ s/\b([Rr])aut\B/$1ăut/g;                                  # rautacios -> răutacios
$string =~ s/\Bltesc\b/lțesc/g;                                      # incoltesc -> incolțesc
$string =~ s/\bincol([tț])/încolț/g;                                 # incolțesc -> încolțesc
$string =~ s/\bIncol([tț])/Încolț/g;                                 # Incoltiti -> Încolțiti
$string =~ s/\bma-/mă-/g;                                            # ma-nsor -> mă-nsor
$string =~ s/\bvraji/vrăji/g;                                        # vrajitoare -> vrăjitoare
$string =~ s/\bster([sg])/șter$1/g;                                  # sters -> șters, sterg -> șterg
$string =~ s/\B([^\s])str(i+)\b/$1ștr$2/;                            # extraterestrii -> extratereștrii
$string =~ s/\B([^\s]{2,})ut(i+|ie|i+lor)\b/$1uț$2/g;                # distributii -> distribuții && cutie: ignore
$string =~ s/\bindra\B/îndră/g;                                      # indragostit -> îndrăgostit
$string =~ s/\bIndra\B/Îndră/g;                                      # Indragostit -> Îndrăgostit
$string =~ s/tiune/țiune/g;                                          # optiune -> opțiune
$string =~ s/\bstra([blz])/stră$1/g;                                 # stralucitor -> strălucitor
$string =~ s/\Bzenta\b/zența/g;                                      # prezenta -> prezența
$string =~ s/([i]{2})(\s+)tai\b/$1$2tăi/g;                           # ochii tai -> ochii tăi
$string =~ s/patruns/pătruns/g;                                      # patruns -> pătruns
$string =~ s/uns(i+)\b/unș$1/g;                                      # ascunsi -> ascunși
$string =~ s/\b(esti|fi|prea|ce|e|[iî]i|)(\s+)blanda\b/$1$2blândă/;  # fi blanda -> fi blândă
$string =~ s/\bbland/blând/g;                                        # bland -> blând
$string =~ s/\brusin/rușin/g;                                        # rusine -> rușine
$string =~ s/\b([iîIÎ])n(\s+)soapta\b/$1n$2șoaptă/g;                 # în soapta -> în șoaptă
$string =~ s/\bsoapta\b/șoapta/g;                                    # soapta -> șoapta
$string =~ s/\bde(\s+)fizica\b/de$1fizică/g;                         # de fizica -> de fizică
$string =~ s/\bindur/îndur/g;                                        # indurare -> îndurare
$string =~ s/\bIndur/Îndur/g;                                        # Indurare -> Îndurare
$string =~ s/\b([Aa])i(\s+)grija\b/$1i$2grijă/g;                     # n-ai grija -> n-ai grijă
$string =~ s/\b([Vv])a(\s+)pot/$1ă$2pot/g;                           # va pot -> vă pot
$string =~ s/intarz/întârz/g;                                        # intarziere -> întârziere
$string =~ s/Intarz/Întârz/g;                                        # Intarziere -> Întârziere
$string =~ s/intampla/întâmpla/g;                                    # intamplare -> întâmplare
$string =~ s/Intampla/Întâmpla/g;                                    # Intamplat -> Întâmplat
$string =~ s/regula(\s*)\./regulă$1./g;                              # in regula. -> in regulă.
$string =~ s/\b([iîÎI])n(\s+)([^\s]*)regula\b/$1n$2$3regulă/g;       # în neregula -> în neregulă
$string =~ s/\blesin/leșin/g;                                        # lesinat -> leșinat

$string =~ s/\Bptia\b/pția/g;                                        # perceptia -> percepția

$string =~ s/\bamet\B/ameț/g;                                        # ametit -> amețit
$string =~ s/\Beste-ti\b/ește-ți/g;                                  # aminteste-ti -> amintește-ți
$string =~ s/\B-ti\b/-ți/g;                                          # fa-ti -> fa-ți
$string =~ s/\bbufnit\B/bufniț/g;                                    # bufnite -> bufnițe
$string =~ s/\Btierea\b/țierea/g;                                    # initiera -> inițierea
$string =~ s/\Ba-m\B/ă-m/g;                                          # asteapta-ma -> asteaptă-ma
$string =~ s/\binto(a)?r\B/înto$1r/g;                                # intoarce-te -> întoarce-te
$string =~ s/\bInto(a)?r\B/Înto$1r/g;                                # Intors -> Întors
$string =~ s/intrerup/întrerup/g;                                    # intrerupere -> întrerupere
$string =~ s/Intrerup/Întrerup/g;                                    # Intrerupere -> Întrerupere
$string =~ s/indepar/îndepăr/g;                                      # indepartat -> îndepărtat
$string =~ s/Indepar/Îndepăr/g;                                      # Indepartat -> Îndepărtat
$string =~ s/(foarte|ă|ce|e|prea)(\s+)frumoasa/$1$2frumoasă/g;       # fată frumoasa -> fată frumoasă
$string =~ s/ingrij/îngrij/g;                                        # reingrijit -> reîngrijit
$string =~ s/Ingrij/Îngrij/g;                                        # Ingrijit -> Îngrijit
$string =~ s/\bbadaran/bădăran/g;                                    # badarani -> bădărani
$string =~ s/\bcala\B/călă/g;                                        # calau -> călău
$string =~ s/\bare(\s+)importanta\b/are$1importanță/g;               # n-are importanta -> n-are importanță
$string =~ s/\Bul(\s+)([^\s.]+)a\b/ul$1$2ă/g;                        # codul sursa -> codul sursă
$string =~ s/\Beaga\b/eagă/g;                                        # leaga -> leagă
$string =~ s/tin(ut|ute)?\b/țin$1/g;                                 # tinute -> ținute
$string =~ s/sina\b/șină/g;                                          # lesina -> leșină
$string =~ s/sin(i+|e|i+le)\b/șin$1/g;                               # masini -> mașini
$string =~ s/\bamag([ie])/amăg$1/g;                                  # amagitor -> amăgitor
$string =~ s/\bsa([\s]+)m[aă]\b/să$1mă/g;                            # sa ma -> să mă
$string =~ s/\Bcit(i+)\b/ciț$1/g;                                    # nenorocitii -> nenorociții
$string =~ s/([Ee])sti\b/$1ști/g;                                    # cuceresti -> cucerești
$string =~ s/\Bă-i([\s]+)([^\s.]+)ata\b/ă-i$1$2ața/g;                # tristă-i viata -> tristă-i viața
$string =~ s/\Btaz(i+)\b/tăz$1/g;                                    # astazi -> astăzi
$string =~ s/\Beste-te\b/ește-te/g;                                  # fereste-te -> ferește-te
$string =~ s/\bde(\s+)([^\s.]{2,})ata/de$1$2ață/g;                   # de viata -> de viață
$string =~ s/carcat/cărcat/g;                                        # incarcat -> incărcat
$string =~ s/inc([aă])r/înc$1r/g;                                    # incărcat -> încărcat
$string =~ s/\bgand/gând/g;                                          # gandire -> gândire
$string =~ s/\B([mnprcoluaei])t(i+lor|i+le|ie|it|i+)\b/$1ț$2/g;
$string =~ s/\bimplini(t)?/împlini$1/g;
$string =~ s/\batragat/atrăgăt/g;
$string =~ s/\bintre(a)?b/între$1b/g;
$string =~ s/([Oo])bisnuit/$1bișnuit/g;
$string =~ s/\binteleg/înteleg/g;
$string =~ s/\bpacat/păcat/g;
$string =~ s/([^Aa]+)(\s+)sa\b/$1$2să/g;
$string =~ s/\bInteleg/Înteleg/g;
$string =~ s/\Barile\b/ările/g;
$string =~ s/\Bati(a|i|ale|e)\b/ați$1/g;
$string =~ s/\B([^p])ari(le|i)?\b/$1ări$2/g;
$string =~ s/\Bandu-ma\b/ându-mă/g;
$string =~ s/\Bndu-ma\b/ndu-mă/g;
$string =~ s/\Band\b/ând/g;
$string =~ s/\B([^oner])st([i]+)/$1șt$2/g;
$string =~ s/\B([^\s])asi\b/$1ași/g;
$string =~ s/\Btati(e|a|i|le)\b/tați$1/g;
$string =~ s/\Bitat([i]+)\b/ităț$1/g;
$string =~ s/\bvei([\s]+)lasa\b/vei$1lăsa/g;
$string =~ s/\Bntat([i]+)\b/ntaț$1/g;
$string =~ s/\b([Ff])ara/$1ără/g;
$string =~ s/\bintr\b/într/g;
$string =~ s/\bIntr\b/Într/g;
$string =~ s/\Bulti\b/ulți/g;
$string =~ s/([Aa])lt([e]+|[i]+)\b/$1lț$2/g;
$string =~ s/\Bieti\b/ieți/g;
$string =~ s/\b([Ss])a([\s-]+)(te|fi|ti|i|î)/$1ă$2$3/g;
$string =~ s/-ma\b/-mă/g;
$string =~ s/\bsi-/și-/g;
$string =~ s/o([\s-]+)([^\s.]+)a([\s-]+)([^\s.]+)a\b/o$1$2ă$3$4ă/g;
$string =~ s/o([\s-]+)([^\s.]+)a\b/o$1$2ă/g;
$string =~ s/a-([^\s.]+)a\b/a-$1ă/g;
$string =~ s/\b([Vv])az/$1ăz/g;
$string =~ s/\b([Tt])raie/$1răie/g;
$string =~ s/\brazâ/râzâ/g;
$string =~ s/\bviata\b/viață/g;
$string =~
  s/([^AaEeIiUuOo])(\s+)mașină(\s+)([^\s.]+)([AaăĂ])\b/$1$2mașina$3$4$5/g;    # lăsat mașină parcata -> lăsat mașina parcata
$string =~ s/([Mm])așin([ăa])(\s+)([^\s.]+)a\b/$1așin$2$3$4ă/g;               # lăsat mașina parcata -> lăsat mașina parcată
$string =~ s/\B([Ii])(\s+)([Mm])așină([^\s])/$1$2$3așina$4/g;

open DEBUG, '>', $outname;
print DEBUG $string;
close DEBUG;
