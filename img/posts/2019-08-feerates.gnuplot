#!/usr/bin/gnuplot

set style line 1 lc rgb '#8b1a0e' pt 4 ps 0.25 lt 1 lw 2
set style line 2 lc rgb '#5e9c36' pt 4 ps 0.25 lt 1 lw 2
set style line 3 lc rgb '#0025ad' pt 4 ps 0.25 lt 1 lw 2
set style line 4 lc rgb '#d95319' pt 4 ps 0.25 lt 1 lw 2
set style fill transparent solid 0.5 noborder

set terminal pngcairo size 800,200 font "Sans,12" transparent

set grid
set tics nomirror
unset border

CONF_RANGE=40
USDBTC=12000
## Byte size of typical 1-in-2-out tx from https://bitcoinops.org/en/bech32-sending-support/#fee-savings-with-native-segwit
p2pkh=220
p2sh_p2wpkh=167
p2wpkh=141

fee(vbytes) = vbytes/1000.*USDBTC

set yrange [2:CONF_RANGE]
set ylabel "Estimated wait time\n(blocks)"
set xlabel "Fee in USD (1 BTC = $" . USDBTC / 1000 . "k USD)"
set format x '$%.2f'
set xtics 0.25
set output './2019-08-time-over-rate.png'
# Data generated using: for i in $( seq 2 1008 ) ; do bitcoin-cli estimatesmartfee $i ; done > fees.$( date +%s )
plot '<sed -n "s/.*feerate...//p" ~/fees.1565306099' u ($1*fee(p2pkh)):($0+2) with lines ls 1 title "Legacy P2PKH" \
  , '' u ($1*fee(p2sh_p2wpkh)):($0+2) with lines ls 2 title "Hybrid P2SH-P2WPKH" \
  , '' u ($1*fee(p2wpkh)):($0+2) with lines ls 3 title "Segwit P2WPKH" \


unset yrange
set xrange [2:CONF_RANGE]
set ylabel "Fee in USD\n(1 BTC = $" . USDBTC / 1000 . "k USD)"
set xlabel "Estimated wait time (blocks)"
set xtics 5
set ytics 0.5
set format y '$%.2f'
unset format x
set output './2019-08-rate-over-time.png'
plot '<sed -n "s/.*feerate...//p" ~/fees.1565306099' u ($0+2):($1*fee(p2pkh)) with lines ls 1 title "Legacy P2PKH" \
  , '' u ($0+2):($1*fee(p2sh_p2wpkh)) with lines ls 2 title "Hybrid P2SH-P2WPKH" \
  , '' u ($0+2):($1*fee(p2wpkh)) with lines ls 3 title "Segwit P2WPKH" \

system("optipng -o7 ./2019-08-time-over-rate.png")
system("optipng -o7 ./2019-08-rate-over-time.png")
