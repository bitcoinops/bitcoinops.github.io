---
title: 'Bitcoin Optech Newsletter #428'
permalink: /en/newsletters/2026/10/23/
name: 2026-10-23-newsletter
slug: 2026-10-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
FIXME:bitschmidty

## News

- **Trust-minimized exits from a single-issuer layer 2:** Adam Gibson
  [posted][lichen ml] to the Bitcoin-Dev mailing list a [paper][lichen paper]
  and proof-of-concept [code][lichen repo] for Lichen, a design in which a
  single issuer, which Gibson calls a hub, mints tokens redeemable one-to-one
  for bitcoin on a layer 2 ledger run by a server called the sequencer. Each
  user holds a 2-of-2 contract with the hub that lets them redeem their tokens
  even if the hub refuses or is offline, so users trust the sequencer to run the
  ledger honestly but not the hub to return their bitcoin. The design builds on
  LN-GAP (see [Newsletter #427][news427 lngap]) but replaces its honest-majority
  attestation committee with a dispute settled entirely onchain.

  Each user locks bitcoin in their own 2-of-2 output with the hub and receives
  the same amount of tokens on the layer 2 ledger, where users pay each other
  without touching the chain. To exit, a user hands tokens back to the hub and
  collects bitcoin from their own output. Because that output is the only one a
  user can draw on, the hub also locks some of its own bitcoin in each output up
  to a negotiated cap, like LN inbound liquidity, so that the user can redeem
  tokens received from others. Tokens received beyond the cap are redeemable
  only at the hub's discretion.

  In the cooperative case, the hub simply signs a settlement of the output
  paying the user. If it refuses or does not respond, the user generates a
  Groth16 proof that the sequencer signed a state recording the returned tokens.
  Since Script cannot verify such a proof, the user instead claims onchain that
  a fixed verifier program accepts it, and if the hub disputes that, presigned
  [BitVMX][topic acc] transactions narrow the disagreement to a single execution
  step that Script can check. Each side locks a reserve that it forfeits by
  losing a dispute, deterring false claims and refusals. Gibson acknowledges
  that a sequencer that omits a user's return, or signs a state it never validly
  reached, can still cost the user or the hub funds, and lists validity proofs
  and a committee of sequencers as future work.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Ibis Wallet v5.0-beta released:** [Ibis Wallet v5.0-beta][ibis v5.0] (see
  [Newsletter #406][news406 ibis]) adds [Ark][topic ark] support built on Bark,
  unilateral exits from the Spark [statechain][topic statechains], and receiving
  to [silent payment][topic silent payments] addresses.

- **Landfall wallet for Lightning mining payouts:** [Landfall][landfall gh] is a
  proof-of-concept wallet that derives from a single seed the payout address,
  [BOLT12 offer][topic offers], and [BIP322][topic generic signmessage]
  signature that the OCEAN mining pool requires to pay rewards over LN, using a
  Lexe-hosted node (see [Newsletter #419][news419 lexe]). It is not intended for
  production use.

- **rbitcoin 0.8.0 released:** [rbitcoin 0.8.0][rbitcoin 0.8.0] is a Bitcoin
  full node in Rust, described as entirely AI-written, for wallet and Lightning
  backends that replaces the UTXO set with a relational archive, serves Electrum
  and Esplora-style APIs, and uses [BIP324][topic v2 p2p transport] exclusively.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-10-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[lichen ml]: https://groups.google.com/g/bitcoindev/c/yZEZ5P1lj5E
[lichen paper]: https://github.com/AdamISZ/lichen/blob/master/papers/lichen-v0.1.pdf
[lichen repo]: https://github.com/AdamISZ/lichen
[news427 lngap]: /en/newsletters/2026/10/16/#offchain-contracts-in-lightning-channels
[ibis v5.0]: https://github.com/aeonBTC/IbisWallet/releases/tag/v5.0.1-beta
[news406 ibis]: /en/newsletters/2026/05/22/#ibis-wallet-announced
[landfall gh]: https://github.com/vincenzopalazzo/landfall
[news419 lexe]: /en/newsletters/2026/08/21/#lexe-adds-human-readable-addresses-and-lnurl-withdraw
[rbitcoin 0.8.0]: https://github.com/reardencode/rbitcoin/releases/tag/v0.8.0
