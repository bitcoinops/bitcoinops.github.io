#!/usr/bin/env python3

## Calculate a simple moving average with a specified window over a
## specified space-delimited field in a pipeline

import sys
import csv

WINDOW=int(sys.argv[1])
FIELD=int(sys.argv[2]) - 1

data = sys.stdin.readlines()

ringbuf = [];

for line in csv.reader(data, delimiter=' '):
    ringbuf.append(float(line[FIELD]))
    if len(ringbuf) > ( WINDOW - 1 ):
        print(' '.join(line), end=' ')
        print(sum(ringbuf) / len(ringbuf))
        ringbuf.pop(0)
    else:
        print(' '.join(line))


