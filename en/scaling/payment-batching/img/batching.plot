#!/usr/bin/gnuplot -p

load '../../lib/settings.plot'  ## Shared settings

set terminal pngcairo size 800,200 font "Sans,12"

set grid
set tics nomirror
unset border
unset key
set samples 1000

savings(original, alternative) = (1 - (alternative / original))*100

## Deconstructed transaction for confirming vbyte calculations
# Weight x4
# |  Weight x1
# |  |  Serialized bytes & description
# |  |  | ## Version and witness flag
# | 4|  | 01000000 ... version
# |  | 2| 0001 ... flag
#
# |  |  | ## Inputs
# | 1|  | 01 ... num inputs
# |36|  | 95109ede0d9c9841eb3a7206b0bfdcfeda563199110e1cb0b156a442333bf5eb00000000 ... outpoint
# | 1|  | 00 ... scriptSig len
# | 4|  | ffffffff ... nSequence
#
# |  |  | ## Outputs
# | 1|  | 02 ... num outputs
# |  |  | ## P2PKH output
# | 8|  | e067350000000000 ... nAmount
# | 1|  | 19 ... scriptPubKey len
# |25|  | 76a91498471635b0ef4bc198746f43993b0dfaa3bcb7d688ac ... scriptPubKey
# |  |  | ## P2WPKH output
# | 8|  | ea44375100000000 ... nAmount
# | 1|  | 16 ... scriptPubKey len
# |22|  | 00147b98a381e0347c3dff2802fd27c48ce4b27f969d ... scriptPubKey
#
# |  |  | ## Witnesses
# |  | 1| 02 ... num witness elements
# |  | 1| 47 ... element #1 len
# |  |71| 30440220300c83b4f1bd73b233646efd
#       | 5169d9b0d000f3a58ff9f7184d336366
#       | d6af9da7022069d919552ca44a61708f
#       | 1e2caba6d1f042613ea42eebb2c8354e
#       | 7986256962c501 ... element #1 (sig)
# |  | 1| 21 ... element #2 len
# |  |33| 0216e225529e9b107ce4c2009779a194
#       | 88acff26b65db3bc14871229bb786ecc3f ... element 2 (pubkey)
#
# | 4|  | 00000000 ... nLockTime

# Input: outpoint + scriptSig_size + nSequence + (witness_elements_count + size + signature + size + pubkey)/4
p2wpkh_input = 36 + 1 + 4
# Input witness (size + signature + size + pubkey)
p2wpkh_input_witness = (1 + 71 + 1 + 33)/4.0
# Output: nValue + size + scriptPubKey(OP_0 OP_PUSH20 <hash160>)
p2wpkh_output = 8 + 1 + (1 + 1 + 20)
# Tx: nVersion + witness(marker + flag) + input_count + inputs*n + output_count + outputs*n + witness_elements + witnesses*inputs + nLockTime
p2wpkh_vbytes(inputs, outputs) = 4 + 2/4.0 + 1 + p2wpkh_input*inputs + 1 + p2wpkh_output*outputs + 1/4.0 + p2wpkh_input_witness*inputs + 4
# Repeated single-payment txes for comparison
unbatched_payments(inputs, repeats) = p2wpkh_vbytes(inputs, 2)*repeats

######################
## Best-case vbytes ##
######################
set output './p2wpkh-batching-best-case.png'
set xtics (1,2,3,4,5,10,15,20,25)
set ytics 50
set ylabel "Vbytes per\npayment"
set xlabel "Number of payments"
# x is the number of payments; the number of outputs is x + 1 change output
plot [1:25] p2wpkh_vbytes(1, x+1)/x ls 1

########################
## Savings comparison ##
########################
set output './p2wpkh-batching-cases-combined.png'
unset yrange
set ytics 20
set ylabel "Savings"
set format y "%.0f%%"
set label 1 "Best case: 1 input, x payments" at 10,82 textcolor ls 1
#> we can imagine [...] requiring at least 10 inputs for
#> every output added.
set label 2 "Unoptimized typical case: x inputs, x payments" at 10,35 textcolor ls 2

plot [1:25] savings(unbatched_payments(1, x)/x, p2wpkh_vbytes(1, x+1)/x) ls 1 \
    , savings(unbatched_payments(1, x)/x, p2wpkh_vbytes(x, x+1)/x) ls 2 \

###########################
## Consolidation savings ##
###########################
set output './p2wpkh-batching-after-consolidation.png'
## Cost to consolidate 100 inputs at 20% the normal spend feerate
consolidation100 = p2wpkh_vbytes(100, 1)*0.2

set label 1 "Best case" at 20,84 textcolor ls 1
set label 2 "Optimized typical case" at 10,50 textcolor ls 2

## 1. best case: we already have large inputs.
## 2. one consolidated input pays for 100 payments
plot [1:25] savings(unbatched_payments(1, x)/x, p2wpkh_vbytes(1, x+1)/x) ls 1 \
    , savings(unbatched_payments(1, x)/x, (x*(consolidation100/100) + p2wpkh_vbytes(1, x+1))/x) ls 2 \

