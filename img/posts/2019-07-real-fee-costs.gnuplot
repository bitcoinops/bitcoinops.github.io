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

set output './2019-07-real-cost-p2pkh-p2wpkh.png'
#set xtics (1,2,3,4,5,10,15,20,25)

#set ytics 600
set ylabel "Savings for\ntypical-sized txn"
set xlabel "USD/BTC price"
#set logscale y
set style fill transparent solid 0.5 noborder

set format x '$%hk'
set format y '$%h'

set yrange [1:220]

# 1 sat to 1000 sat, 1 thousand to 1 million

# P2PKH 226 to P2WPKH 141 = 85 vbytes
# 2-of-3 P2SH 366 to P2WSH 177 = 189(see ./2019-04-segwit-savings.py)

set x2label "Single-sig legacy P2PKH versus segwit P2WPKH"
plot '<save=85 ; for i in `seq 10000 1000 100000` ; do echo $i $( echo $i \* $save \* 0.00000001 | bc -l ) $( echo $i \* $save \* 0.00001000 | bc -l ) ; done' u ($1/1000):2:3 w filledcurves \

set output './2019-07-real-cost-p2sh-p2wsh.png'

set x2label "2-of-3 multisig legacy P2SH versus segwit P2WSH"
plot '<save=189 ; for i in `seq 10000 1000 100000` ; do echo $i $( echo $i \* $save \* 0.00000001 | bc -l ) $( echo $i \* $save \* 0.00001000 | bc -l ) ; done' u ($1/1000):2:3 w filledcurves
