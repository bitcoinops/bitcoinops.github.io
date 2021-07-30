#!/usr/bin/gnuplot


set style line 1 lc rgb '#8b1a0e' pt 4 ps 0.25 lt 1 lw 2
set style line 2 lc rgb '#5e9c36' pt 4 ps 0.25 lt 1 lw 2
set style line 3 lc rgb '#0025ad' pt 4 ps 0.25 lt 1 lw 2
set style line 4 lc rgb '#d95319' pt 4 ps 0.25 lt 1 lw 2

set terminal pngcairo size 800,220 font "Sans,12" enhanced transparent

set grid
set tics nomirror
unset border
#unset key
set key horizontal tmargin Left reverse
set samples 1000

set output './2019-04-segwit-multisig-size-p2sh-to-p2sh-p2wsh.png'
#set xtics (1,2,3,4,5,10,15,20,25)
set x2tics ("k1" 0, "2" 15, "3" 29, "4" 42, "5" 54, "6" 65, "7" 75, "8" 84, "9" 92, "10" 99, "11" 105, "12" 110, "13" 114, "15" 119) font "default,10" offset 0,graph -0.05
set xtics ("n1" 0, "2" 1, "3" 2, "4" 3, "5" 4, "6" 5, "7" 6, "8" 7, "9" 8, \
  "2" 15, "3" 16, "4" 17, "5" 18, "6" 19, "7" 20, "8" 21, "9" 22, \
  "3" 29, "4" 30, "5" 31, "6" 32, "7" 33, "8" 34, "9" 35, \
  "4" 42, "5" 43, "6" 44, "7" 45, "8" 46, "9" 47, \
  "5" 54, "6" 55, "7" 56, "8" 57, "9" 58, \
  "6" 65, "7" 66, "8" 67, "9" 68, \
  "7" 75, "8" 76, "9" 77, \
  "8" 84, "9" 85, \
  "9" 92 \
  ) font "default,6" offset 0,graph 0.15

set ytics 200
set ylabel "Vbytes"
set xlabel "Transactions with k signatures for n to 15 pubkeys (n>=k)"

set yrange [-10:410]
set output './2021-07-multisignature-savings.png'
plot "<python3 2021-taproot-savings.py" u 0:2 title "P2WSH" ls 1 \
   , "<python3 2021-taproot-savings.py" u 0:3 title "P2TR multisignatures" ls 2

