#!/usr/bin/python

# Source: https://web.archive.org/web/20121227150759/http://ideone.com/UNPRU

# Execute the script with the "song.csv" argument.

book = """Let the Priests of the Raven of dawn,
no longer in deadly black, with hoarse note
curse the sons of joy. Nor his accepted
brethren, whom, tyrant, he calls free lay the
bound or build the roof. Nor pale religious
letchery call that virginity, that wishes
but acts not.

For every thing that lives is Holy."""

craw = [
    'a;43_24',
    'b;44_24',
    'c;46_24',
    'd;48_24',
    'e;49_24',
    'f;51_24',
    'g;53_24',
    'h;55_24',
    'i;43_96',
    'j;44_96',
    'k;46_96',
    'l;48_96',
    'm;49_96',
    'n;51_96',
    'o;53_96',
    'p;55_96',
    'q;43_192',
    'r;44_192',
    's;46_192',
    't;48_192',
    'u;49_192',
    'v;51_192',
    'w;53_192',
    'x;55_192',
    'y;43_384',
    'z;44_384',
    ' ;-12_24',
    ', ;-12_240',
    '\n;-12_384',
    ':\n;-12_768',
    '. ;-12_960']
chars = {}
for cline in craw:
    char = cline.split(';')
    chars[char[1]] = char[0]

import sys
book = book.replace(' ', '')
book = book.replace('\n', '')

f = open(sys.argv[1], 'r')

tracks = {}

while 1:
        line = f.readline()
        if not line:
                break
        line = line.strip('\n').split(', ')
        try:
                tracks[int(line[0])]
        except KeyError:
                tracks[int(line[0])] = []
        tracks[int(line[0])].append(line[1:])

#print(tracks)


notes = {}
for tid in tracks.keys():
    track = tracks[tid]
    notelist = []
    lasttime = 0
    for event in track:
    #    print(event)
        note = None
        if event[1] == 'Note_on_c':
            if int(event[0]) != lasttime:
                #there was a delay
                d = int(event[0])-lasttime
                note = 0
        elif event[1] == 'Note_off_c':
            d = int(event[0]) - lasttime
            note = int(event[3])
        if note != None:
            d = d
            #num = note+d
            #print('Note:\t%d\tDur:\t%d\tNum:\t%d' % (note, d, num))
            notelist.append([lasttime, note, d])
        lasttime = int(event[0])
    notes[tid] = notelist

message = ''

for notenum in range(len(notes[2])):
    note = notes[2][notenum]
    key = str(note[1]-12)+'_'+str(note[2])
    try:
        message += chars[key]
    except KeyError:
        message += key
            #print("oops: "+key)
#    try:
#        message += book[num]
#    except IndexError:
#        message += '_'

print(message)
#print(len(book))
