#!/usr/bin/gnuplot

set style line 1 lc rgb '#8b1a0e' pt 4 ps 0.25 lt 1 lw 2
set style line 2 lc rgb '#5e9c36' pt 4 ps 0.25 lt 1 lw 2
set style line 3 lc rgb '#0025ad' pt 4 ps 0.25 lt 1 lw 2
set style line 4 lc rgb '#d95319' pt 4 ps 0.25 lt 1 lw 2

set terminal pngcairo size 800,200 font "Sans,12" transparent

set grid
set tics nomirror
unset border
unset key
#set key horizontal tmargin Left reverse
#set samples 1000

set style fill transparent solid 0.5 noborder

set format x '%hk'
set format y '%h%%'

## Data generated using scripts in this repository's _contrib/stats/ directory, e.g.:
# tx-types.sh
# AVG=10000
# sort 2019-07-tx-types.* \
# | moving-average.py $AVG 2 \
# | moving-average.py $AVG 3 \
# | moving-average.py $AVG 4 \
# | moving-average.py $AVG 5 \
# | moving-average.py $AVG 6 > 2019-07-all-tx-types-averaged-10000.data

## Type | Raw | Avg
# P2PKH     2   7
# P2SH      3   8
# P2WPKH    4   9
# P2WSH     5   10
# Nulldata  6   11

## Bech32 tx percentage
set ytics 2
set xrange [500:]
set output './2019-07-tx-types-bech32-percentage.png'
set xlabel "Block number"
set ylabel "Bech32 outputs\n "
plot '~/2019-07-all-tx-types-averaged-10000.data' u ($1/1000):(($9+$10)/($7+$8+$9+$10+$11)*100) w line ls 3, \


## Comparative totals
set terminal pngcairo size 800,400 font "Sans,12" transparent
set output './2019-07-tx-types-bech32-all-totals.png'
set format y '%h'
set ytics 1000
set yrange [:5000]
set ylabel "Outputs"

set label 1 "P2PKH" at 520,2500 tc ls 1
set label 2 "P2SH" at 520,1200 tc ls 2
set label 3 "Native segwit (bech32)" at 520,450 tc ls 3
set label 4 "OP_RETURN (nulldata)" at 562,900 tc ls 4 noenhanced

plot '~/2019-07-all-tx-types-averaged-10000.data' u ($1/1000):7 w lines ls 1, \
  '' u ($1/1000):8 w lines ls 2, \
  '' u ($1/1000):($9+$10) w lines ls 3, \
  '' u ($1/1000):11 w lines ls 4 \


## Stacked totals
set output './2019-07-tx-types-bech32-all-totals-stacked.png'
unset yrange
set label 1 "P2PKH" at 510,1500 tc ls 1
set label 2 "P2SH" at 516,2700 tc rgb 'black'
set label 3 "Native segwit (bech32)" at 518,4000 tc ls 3
set label 4 "OP_RETURN (nulldata)" at 540,5500 tc ls 4 noenhanced

plot '~/2019-07-all-tx-types-averaged-10000.data' u ($1/1000):(0):7 w filledcurves ls 1, \
  '' u ($1/1000):7:($7+$8) w filledcurves ls 2, \
  '' u ($1/1000):($7+$8):($7+$8+$9+$10) w filledcurves ls 3, \
  '' u ($1/1000):($7+$8+$9+$10):($7+$8+$9+$10+$11) w filledcurves ls 4\

## Comparative percentages
#plot '~/2019-07-all-tx-types-averaged-10000.data' u 1:($7/($7+$8+$9+$10+$11)) w line, \
#  '' u 1:($8/($7+$8+$9+$10+$11)) w line, \
#  '' u 1:($9/($7+$8+$9+$10+$11)) w line, \
#  '' u 1:($10/($7+$8+$9+$10+$11)) w line, \
#  '' u 1:($11/($7+$8+$9+$10+$11)) w line, \

## Stacked percentages
#plot '~/2019-07-all-tx-types-averaged-10000.data' u 1:(0):($7/($7+$8+$9+$10+$11)) w filledcurves, \
#  '' u 1:($7/($7+$8+$9+$10+$11)):(($7+$8)/($7+$8+$9+$10+$11)) w filledcurves, \
#  '' u 1:(($7+$8)/($7+$8+$9+$10+$11)):(($7+$8+$11)/($7+$8+$9+$10+$11)) w filledcurves, \
#  '' u 1:(($7+$8+$11)/($7+$8+$9+$10+$11)):(($7+$8+$11+$9)/($7+$8+$9+$10+$11)) w filledcurves, \
#  '' u 1:(($7+$8+$11+$9)/($7+$8+$9+$10+$11)):(1) w filledcurves, \
