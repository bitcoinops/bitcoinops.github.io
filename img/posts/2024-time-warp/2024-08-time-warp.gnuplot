#!/usr/bin/gnuplot

set style line 1 pt 5 ps 1 lc rgb "black"
set style line 2 pt 5 ps 1 lc rgb "grey"
set style line 3 pt 5 ps 1 lc rgb "blue"
set style line 4 pt 5 ps 1 lc rgb "orange"

set style fill transparent solid 0.5 noborder

set terminal pngcairo size 800,200 font "Sans,8" transparent
#set terminal pngcairo size 00,200 font "Sans,12" transparent

set grid
set tics nomirror
unset border

set xlabel "Time (block header)"
set ylabel "Difficulty\n(log scale)"
unset xtics
unset ytics
#unset key
set key box
set key bottom left

set logscale y
set tmargin at screen 0.8

set output 'new-time-warp.png'
set title "New time warp\n " font "Sans Bold,8"
plot './new-time-warp.data' every ::0::4 ls 1 title "Period 1", \
  '' every ::5::9 ls 2 title "Period 2", \
  '' every ::10::14 ls 3 title "Period 3", \
  '' every ::15::19 ls 4 title "Period 4", \
  '' using 1:2:(sprintf("%d", $0+1)) with labels offset char 0,1 notitle, \

set output 'classic-time-warp.png'
set title "Classic time warp"
plot './classic-time-warp.data' every ::0::4 ls 1 title "Period 1", \
  '' every ::5::9 ls 2 title "Period 2", \
  '' every ::10::14 ls 3 title "Period 3", \
  '' every ::15::19 ls 4 title "Period 4", \
  '' using 1:2:(sprintf("%d", $0+1)) with labels offset char 0,1 notitle, \

set output '50p-attack.png'
set title "51% attack"
plot './50p-attack.data' every ::0::4 ls 1 title "Period 1", \
  '' every ::5::9 ls 2 title "Period 2", \
  '' every ::10::14 ls 3 title "Period 3", \
  '' every ::15::19 ls 4 title "Period 4", \
  '' using 1:2:(sprintf("%d", $0+1)) with labels offset char 0,1 notitle, \

set output 'reg-blocks.png'
set title "Honest mining\n(constant hashrate)"
plot './reg-blocks.data' every ::0::4 ls 1 title "Period 1", \
  '' every ::5::9 ls 2 title "Period 2", \
  '' every ::10::14 ls 3 title "Period 3", \
  '' every ::15::19 ls 4 title "Period 4", \
  '' using 1:2:(sprintf("%d", $0+1)) with labels offset char 0,1 notitle, \
