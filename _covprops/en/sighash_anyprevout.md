---
title: "SIGHASH_ANYPREVOUT"
shorttitle: "APO"
uid: apo
topic_page_or_best_reference: /en/topics/sighash_anyprevout/

implementations:

covenant_based_apps:
  channel_factories:
    enabled: "true"

  congestion_control:
    enabled: "unknown"

  dlc_efficiency:
    enabled: "unknown"

excerpt: >
  The `SIGHASH_ANYPREVOUT` (APO) proposal allows the signature for
  taproot transactions to omit committing to the outpoint, scriptPubKey,
  and tapleaf tree position for the UTXO the signature is authorizing
  spending.  This can allow the same signature to spend from different
  UTXOs that all have the same amount and a functionally equivalent
  script, eliminating the need to store a different signature for every
  possible transaction in an offchain contract protocol.
---
## Advantages 

- **Simple:** the direct behavior of APO is simple to understand---it
  just commits to less data than normal signatures.

- **Flexible:** although designed primarily to enable [eltoo][topic
  eltoo], APO has also been found to enable a number of other
  covenant-based applications

## Disadvantages

- **Replayable:** although using the same signature to spend different
  UTXOs enables new protocols on Bitcoin, it must be used carefully.
  For example, if Alice sends two payments for the same amount to Bob,
  with both payments using the same address, and Bob use APO to spends
  one of those payments to Carol, anyone can *replay* Bob's signature
  and send the second payment to Carol also.

## Alternative approaches

Both before and since the proposals for `SIGHASH_NOINPUT` and APO, there
have been proposals to allow much more fine-grained specification of
what parts of a transaction a signature commits to.  Some of these
proposals would allow a signer to omit the commitment to the same things
APO omits, enabling equivalent functionality.

{% include references.md %}
