#!/usr/bin/python

# Source: https://web.archive.org/web/20121227150745/http://ideone.com/6NwKn

# -*- coding: utf-8 -*-
book = """All Bibles or sacred codes, have been
the causes of the following Errors.
1. That Man has two real existing princi-
ples Viz: a Body & a Soul.
2. That Energy, call'd Evil, is alone from the
Body, & that Reason, call'd Good, is alone from
the Soul.
3. That God will torment Man in Eternity
for following his Energies.
But the following Contraries to these are True.
1. Man has no Body distinct from his Soul;
for that call'd Body is a portion of Soul discern'd
by the five Senses, the chief inlets of Soul in this
age.
2. Energy is the only life and is from the Body
and Reason is the bound or outward circumference
of Energy.
3. Energy is Eternal Delight."""
import sys
locs = """1:22
3:33
3:40
6:19
4:7
4:8
4:7
9:23
12:12
4:16
16:7
11:16
1:7
5:14
3:35
2:2
4:26
1:12
3:11
3:28
4:23
18:18"""

locs = [[int(i) for i in a.split(":")] for a in locs.split()]
book = [i for i in book.split("\n")]

#print(locs)
#print(book)

for i in locs:
    sys.stdout.write(book[i[0]-1][i[1]-1])

print("")
