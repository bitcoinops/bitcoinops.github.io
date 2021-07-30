#!/usr/bin/python3

## P2WSH
def p2wsh(sigs, pks):
    ## Could be +/- a couple bytes due to PUSH_n vs PUSHDATA2
    ##                        |--->witness script<---|
    # OP_0 size sig     size  m  PUSH  pk        n  OP_CMS
    return ( 1 + (1 + 72)*sigs + 1 + 1 + (1 + 33)*pks + 1 + 1 )/4.0

## Taproot
def multisignature():
    #       size sig
    return ( 1 + 64 )/4.0

for sigs in range(1,16):
  for pks in range(sigs,16):
      print("{}-of-{}".format(sigs, pks), p2wsh(sigs, pks), multisignature())
