#!/usr/bin/gnuplot

########################################################
## Begin code used to generate the data for this plot ##
########################################################
# #!/bin/bash -eu
# 
# block=$1
# 
# ## Number of inputs (should be one more than our later results, since we drop the coinbase witness)
# # bitcoin-cli getblock $( bitcoin-cli getblockhash $block ) 2 | jq .tx[].vin[].sequence | wc -l
# 
# ## Get basic multisig inputs for P2SH and P2WSH
# ## Doesn't handle complex scripts, e.g. HTLCs
# bitcoin-cli getblock $( bitcoin-cli getblockhash $block ) 2 | # Get a complete block dump
#   jq '.tx[].vin[] | .scriptSig.asm, .txinwitness[-1]' |       # Extract scriptSig asm and final witness element (witness script when P2WSH)
#   sed 's/^".* /"/' |                                          # Extract final scriptSig element (redeemScript when P2SH)
#   grep -v 'null' | grep -v '""' |                             # Ignore empty scriptSigs (we'll use their witnesses)
#   grep -v '^"0020.\{64\}"$' |                                 # Ignore 00 plus push plus 32-byte (64-hex) elements (templated P2SH-P2WSH; we'll use their witnesses)
#   grep -v '^"0014.\{40\}"$' |                                 # Ignore 00 plus push plus 20-byte (40-hex) elements (templated P2SH-P2WPKH; see P2WPKH below)
#   grep -v '^"0\{64\}"$' |                                     # Ignore coinbase witness
# 
#   sed 's/^".\{66\}"$/single-sig/' |                           # 33-byte (66-hex) elements are templated P2WPKH
#   sed 's/^"04.\{128\}"$/single-sig/' |                        # P2PKH uncompressed WHO IS STILL CREATING THIS WTF IS WRONG WITH YOU
#   sed 's/^"76a914.\{40\}88ac"$/single-sig/' |                 # P2PKH in P2WSH in P2SH.  I CAN DIE NOW IVE SEEN EVERYTHING
# 
#   sed 's/".\(.\).*5\(.\)ae"/\1-of-\2/' |                      # Extract 1-f for the k of n parameters
# 
#   sed '/-/!s/.*/exotic &/'                                    # Everything we didn't program for
##############
## End code ##
##############


set style line 1 lc rgb 'black' pt 4 ps 0.25 lt 1 lw 2
set style line 2 lc rgb '#5e9c36' pt 4 ps 0.25 lt 1 lw 2
set style line 3 lc rgb '#0025ad' pt 4 ps 0.25 lt 1 lw 2
set style line 4 lc rgb '#d95319' pt 4 ps 0.25 lt 1 lw 2
set style line 5 lc rgb '#8b1a0e' pt 4 ps 0.25 lt 1 lw 2
set style line 6 lc rgb 'yellow' pt 4 ps 0.25 lt 1 lw 2

set terminal pngcairo size 400,180 font "Sans,12" enhanced transparent


unset border
#unset key
set key bmargin horizontal
unset xtics
unset ytics
#set key horizontal tmargin Left reverse
#set samples 1000

set style fill transparent solid 0.5 noborder

mywidth = 641

set output './2021-07-multisig-unfungible.png'
plot "<nl 2021-07-692039-scripts.txt | grep single-sig" u (int($1) % mywidth):(floor($1 / mywidth)) title "Single-sig" ls 2 \
   , "<nl 2021-07-692039-scripts.txt | grep 1-of-1" u (int($1) % mywidth):(floor($1 / mywidth)) title "1-of-1" ls 3 \
   , "<nl 2021-07-692039-scripts.txt | grep 2-of-2" u (int($1) % mywidth):(floor($1 / mywidth)) title "2-of-2" ls 4 \
   , "<nl 2021-07-692039-scripts.txt | grep 2-of-3" u (int($1) % mywidth):(floor($1 / mywidth)) title "2-of-3" ls 5 \
   , "<nl 2021-07-692039-scripts.txt | grep 3-of-4" u (int($1) % mywidth):(floor($1 / mywidth)) title "3-of-4" ls 6 \
   , "<nl 2021-07-692039-scripts.txt | egrep -v '(single-sig|-of-)'" u (int($1) % mywidth):(floor($1 / mywidth)) title "Other" ls 1 \


## Slightly reduce height to compensate for smaller key
set terminal pngcairo size 400,140 font "Sans,12" transparent

set output './2021-07-multisignature-fungible.png'
plot "<nl 2021-07-692039-scripts.txt | egrep '(single-sig|-of-)'" u (int($1) % mywidth):(floor($1 / mywidth)) title "Keypath" ls 2 \
   , "<nl 2021-07-692039-scripts.txt | egrep -v '(single-sig|-of-)'" u (int($1) % mywidth):(floor($1 / mywidth)) title "Scriptpath" ls 1 \
