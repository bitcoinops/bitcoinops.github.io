#!/usr/bin/gnuplot

set style line 1 lc rgb '#8b1a0e' pt 4 ps 0.25 lt 1 lw 2
set style line 2 lc rgb '#5e9c36' pt 4 ps 0.25 lt 1 lw 2
set style line 3 lc rgb '#0025ad' pt 4 ps 0.25 lt 1 lw 2
set style line 4 lc rgb '#d95319' pt 4 ps 0.25 lt 1 lw 2

set terminal pngcairo size 800,200 font "Sans,12" transparent

set grid
set tics nomirror
unset border
set key horizontal tmargin Left reverse
unset key
#set samples 1000

set output './2019-06-p2sh-vs-segwit-aggregate.png'

set xrange [0:1900]
set ytics 10
set xtics 500

set ylabel "Outputs"
set format y "%.0f%%";
set xlabel "Days since soft fork activation"

set label 1 "P2SH" at 1400,25 tc ls 1
set label 2 "Native segwit" at 500,10 tc ls 2

plot "<sed '1,/2012-03-31/d; s/[^ ]*e-[^ ]*/0/g' $HOME/foo" u 0:($11*100) ls 1 with lines \
   , "<sed '1,/2017-08-24/d; s/[^ ]*e-[^ ]*/0/g' $HOME/foo" u 0:($14*100) ls 2 with lines \

set output './2019-06-p2sh-vs-segwit-separate.png'
unset label 2

set label 1 "P2SH" at 800,1 tc ls 1
set label 3 "Native P2WPKH" at 420,7 tc ls 4
set label 4 "Native P2WSH"  at 420,1.5 tc ls 3

set xrange [0:900]
set xtics 200
set ytics 2.5

plot "<sed '1,/2012-03-31/d; s/[^ ]*e-[^ ]*/0/g' $HOME/foo" u 0:($11*100) ls 1 with lines \
   , "<sed '1,/2017-08-24/d; s/[^ ]*e-[^ ]*/0/g' $HOME/foo" u 0:($12*100) ls 4 with lines \
   , "<sed '1,/2017-08-24/d; s/[^ ]*e-[^ ]*/0/g' $HOME/foo" u 0:($13*100) ls 3 with lines \
