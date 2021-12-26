# -*- coding: utf-8 -*-

# Source: https://pastebin.com/6v1XC1kV

"""

>>> print sum(lat_to_num("​The Instar Emergence"))
761

>>> run_to_lat(num_to_run(lat_to_num("running")))
'running'

>>> print " ".join(["".join(lat_to_run(x)) for x in "​The Instar Emergence".split(" ")])
ᚦᛖ ᛁᚾᛋᛏᚪᚱ ᛖᛗᛖᚱᚷᛖᚾᚳᛖ

"""

gematriaprimus = (
    (u'ᚠ',   'f',   2),
    (u'ᚢ',   'v',   3),
    (u'ᚢ',   'u',   3),
    (u'ᚦ',   'T',   5), # th
    (u'ᚩ',   'o',   7),
    (u'ᚱ',   'r',   11),
    (u'ᚳ',   'c',   13),
    (u'ᚳ',   'k',   13),
    (u'ᚷ',   'g',   17),
    (u'ᚹ',   'w',   19),
    (u'ᚻ',   'h',   23),
    (u'ᚾ',   'n',   29),
    (u'ᛁ',   'i',   31),
    (u'ᛄ',   'j',   37),
    (u'ᛇ',   'E',   41), # eo
    (u'ᛈ',   'p',   43),
    (u'ᛉ',   'x',   47),
    (u'ᛋ',   's',   53),
    (u'ᛋ',   'z',   53),
    (u'ᛏ',   't',   59),
    (u'ᛒ',   'b',   61),
    (u'ᛖ',   'e',   67),
    (u'ᛗ',   'm',   71),
    (u'ᛚ',   'l',   73),
    (u'ᛝ',   'G',   79), # ing
    (u'ᛝ',   'G',   79), # ng
    (u'ᛟ',   'O',   83), # oe
    (u'ᛞ',   'd',   89),
    (u'ᚪ',   'a',   97),
    (u'ᚫ',   'A',  101), # ae
    (u'ᚣ',   'y',  103),
    (u'ᛡ',   'I',  107), # ia
    (u'ᛡ',   'I',  107), # io
    (u'ᛠ',   'X',  109)  # ea
)

latsimple = (
    ('T','th'),
    ('E','eo'),
    ('G','ing'),
    ('G','ng'),
    ('O','oe'),
    ('A','ae'),
    ('I','ia'),
    ('I','io'),
    ('X','ea'),
)

def gem_map(x, src, dest):
    m = {p[src]:p[dest] for p in gematriaprimus}
    return [m[c] for c in x if c in m]

def lat_to_sim(x):
    for sim in latsimple:
        x = x.replace(sim[1], sim[0])
    return x
def sim_to_lat(x):
    for sim in latsimple:
        x = x.replace(sim[0], sim[1])
    return x

def run_to_lat(x):
    return sim_to_lat("".join(gem_map(x, 0, 1)))
def run_to_num(x):
    return gem_map(x, 0, 2)

def lat_to_run(x):
    return gem_map(lat_to_sim(x.lower()), 1, 0)
def lat_to_num(x):
    return gem_map(lat_to_sim(x.lower()), 1, 2)

def num_to_run(x):
    return gem_map(x, 2, 0)
def num_to_lat(x):
    return sim_to_lat("".join(gem_map(x, 2, 1)))

def count(x):
    return sum(lat_to_num(x))
def count_words(x):
    return [sum(lat_to_num(w)) for w in x.split(" ")]
def count_letters(x):
    return [lat_to_num(w) for w in x.split(" ")]


print(sum(lat_to_num("​The Instar Emergence")))

text = "tunneling"

print(lat_to_num(text))
print(num_to_run(lat_to_num(text)))
print(run_to_lat(num_to_run(lat_to_num(text))))

runes = "ᚦᛗᛗᛇᚩᛗᚪᚱ5ᚢᚫᛝ3ᛠᛗᛇᚠᛡ"

print(run_to_lat(runes))
