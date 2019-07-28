#!/bin/bash -eu

## Requires 'jq' and 'pee' from the jq and moreutils Debian packages,
## plus a running bitcoind and its companion bitcoin-cli

TOP=587172
BOTTOM=$(( TOP - 99999 ))
CORES=$( nproc )

_tx_types() {
  ID=$1

  for i in $( seq $BOTTOM $TOP | tac )
  do
    if [ $(( i % CORES )) -ne $ID ]; then continue ; fi

    echo -n "$i "
    bitcoin-cli getblock $( bitcoin-cli getblockhash $i ) 2 \
      | jq '.tx[].vout[].scriptPubKey.type' \
      | pee 'grep -c pubkeyhash | tr "\n" " "' \
            'grep -c scripthash | tr "\n" " "' \
            'grep -c witness_v0_keyhash | tr "\n" " "' \
            'grep -c witness_v0_scripthash | tr "\n" " "' \
            'grep -c nulldata | tr -d "\n"'
    echo
  done
}

for proc in $( seq 0 $(( CORES - 1 )) ); do _tx_types $proc > 2019-07-tx-types.$proc & done
wait

## After completion, the output files can be sorted into a single
## ordered file
