set terminal pngcairo size 800,200

set style line 1 lc rgb 'black' lt 1 lw 3    # Black line style
set style line 2 lc rgb 'grey' lt 1 lw 3     # Grey line style

set key off  # Turn off the legend

unset xtics
unset ytics
set xlabel "Accumulated weight (vbytes)"
set ylabel "Accumulated fees"

set output '2023-12-comparable-chunkings.png'
plot '2023-12-clusterings.data' using 1:2 with linespoints linestyle 1, \
     '2023-12-clusterings.data' using 3:4 with linespoints linestyle 2

set output '2023-12-incomparable-chunkings.png'
plot '2023-12-clusterings.data' using 1:2 with linespoints linestyle 1, \
     '2023-12-clusterings.data' using 5:6 with linespoints linestyle 2
