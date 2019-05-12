#!/usr/bin/python3

# Input: outpoint + scriptSig_size + scriptSig + nSequence
# P2SH scriptSig: (OP_PUSH72 <sig>)*signatures + OP_PUSHDATA <size>
#                 <redeemScript(OP_<k> + (OP_PUSH33 <pubkey>)*pubkeys
#                 + OP_<n> + OP_CHECKMULTISIG)>
def p2sh_input(sigs, pks):
  return 36 + 1 + ((72+1)*sigs + 2 + (1 + ((33+1)*pks + 2)) + 4)

## P2SH-P2WSH scriptSig: PUSH32 <commitment>
p2sh_p2wsh_input = 36 + 1 + 35 + 4
p2wsh_input = 36 + 1 + 0 + 4
# Input witness (size + signature + size + pubkey)
## P2WSH input witness: number_elements + (element_size + <sig>)*signatures
#                       + (element_size + <pubkey>)*pubkeys +
#                       (element_size <OP_<k> OP_<n> OP_CHECKMULTISIG>)
def p2wsh_input_witness(sigs, pks):
  return (1 + (1+72)*sigs + (1+33)*pks + (1 + 3))/4.0

# Output: nValue + size + scriptPubKey(OP_0 OP_PUSH20 <hash160>)
p2wpkh_output = 8 + 1 + (1 + 1 + 20)

# Legacy: nVersion + input_count + inputs*n + output_count + outputs*n + nLockTime
def p2sh_vbytes(sigs, pks):
  return 4 + 1 + p2sh_input(sigs, pks) + 1 + p2wpkh_output*2 + 4
# Native: nVersion + witness(marker + flag) + input_count + inputs*n + output_count + outputs*n + witness_elements + witnesses*inputs + nLockTime
def p2wsh_vbytes(sigs, pks):
  return 4 + 2/4.0 + 1 + p2wsh_input + 1 + p2wpkh_output*2 + 1/4.0 + p2wsh_input_witness(sigs, pks) + 4
# Wrapped
def p2sh_p2wsh_vbytes(sigs, pks):
  return 4 + 2/4.0 + 1 + p2sh_p2wsh_input + 1 + p2wpkh_output*2 + 1/4.0 + p2wsh_input_witness(sigs, pks) + 4
## Taproot
               #out  ss  seq    sig
taproot_input = 36 + 1 + 4   + (1+64)/4
taproot_vbytes = 4 + 1 + taproot_input + 1 + p2wpkh_output*2 + 4


for sigs in range(1,16):
  for pks in range(sigs,16):
      print("{}-of-{}".format(sigs, pks), p2sh_vbytes(sigs, pks), p2sh_p2wsh_vbytes(sigs, pks), p2wsh_vbytes(sigs, pks), taproot_vbytes)
