# Riard's numbers: "Default setting: Eclair 144, Core-Lightning 34, LND
# 80 and LDK 72."

unset key


set terminal pngcairo size 800,400
set output "output.png"

set style line 1 lt 1 lc rgb "black" lw 2
set style line 2 dashtype 2 linewidth 2 lc rgb "gray"



set arrow from 144, graph 0 to 144, graph 1 nohead ls 2
set label "Eclair" at 140, graph 0.82 rotate left

set arrow from 80, graph 0 to 80, graph 1 nohead ls 2
set label "LND" at 84, graph 0.77 rotate left

set arrow from 72, graph 0 to 72, graph 1 nohead ls 2
set label "LDK" at 68, graph 0.77 rotate left

set arrow from 34, graph 0 to 34, graph 1 nohead ls 2
set label "Core Lightning" at 30, graph 0.40 rotate left

set label "30 seconds" at 150, graph 0.95 font "Courier-Italic"
set label "6 seconds" at 150, graph 0.76 font "Courier-Italic"
set label "Average time\nper block that\nany HTLC spend is\nin miner mempools" at 150, graph 0.56 font "Courier-Italic"
set label "0.6 seconds" at 150, graph 0.12 font "Courier-Italic"

set xlabel "Blocks (CLTV expiry delta)"
set ylabel "Probability attack will fail within x blocks"

set format y "%.0f%%"
set ytics 20
set xtics 40

plot [1:200] 100*(1 - 0.999**x) ls 1, 100*(1 - 0.99**x) ls 1, 100*(1 - 0.95**x) ls 1

