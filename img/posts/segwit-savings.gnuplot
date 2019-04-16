#!/usr/bin/gnuplot

set style line 1 lc rgb '#8b1a0e' pt 4 ps 0.25 lt 1 lw 2
set style line 2 lc rgb '#5e9c36' pt 4 ps 0.25 lt 1 lw 2
set style line 3 lc rgb '#0025ad' pt 4 ps 0.25 lt 1 lw 2

set terminal pngcairo size 800,200 font "Sans,12"

set grid
set tics nomirror
unset border
#unset key
set key horizontal tmargin Left reverse
set samples 1000

set output './2019-04-segwit-multisig-size-p2sh-to-p2sh-p2wsh.png'
#set xtics (1,2,3,4,5,10,15,20,25)
set xtics ("1" 0, "2" 15, "3" 29, "4" 42, "5" 54, "6" 65, "7" 75, "8" 84, "9" 92, "10" 99, "11" 105, "12" 110, "13" 114, "15" 119)
set ytics 600
set ylabel "Vbytes"
set xlabel "Transactions with x signatures for x to 15 pubkeys"
#plot for [sigs=1:3] for [pks=sigs:3] p2sh_vbytes(sigs, pks) with points
plot "<python3 2019-04-segwit-savings.py" u 0:2 title "P2SH" ls 1 \
   , "<python3 2019-04-segwit-savings.py" u 0:3 title "P2SH-P2WSH" ls 2 \

set output './2019-04-segwit-multisig-size-p2sh-p2wsh-to-p2wsh.png'
plot "<python3 2019-04-segwit-savings.py" u 0:3 title "P2SH-P2WSH" ls 2 \
   , "<python3 2019-04-segwit-savings.py" u 0:4 title "P2WSH" ls 3
