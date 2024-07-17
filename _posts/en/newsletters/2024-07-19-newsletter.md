---
title: 'Bitcoin Optech Newsletter #312'
permalink: /en/newsletters/2024/07/19/
name: 2024-07-19-newsletter
slug: 2024-07-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a distributed key generation protocol
for the FROST scriptless threshold signature scheme and links to a
comprehensive introduction to cluster linearization.  Also included are
our regular sections describing recent changes to clients, services, and
popular Bitcoin infrastructure projects.

## News

- **Distributed key generation protocol for FROST:** Tim Ruffing and
  Jonas Nick [posted][ruffing nick post] to the Bitcoin-Dev mailing list
  a [BIP draft][chilldkg bip] with a [reference implementation][chilldkg
  ref] of ChillDKG, a protocol for securely generating keys to be used
  with [FROST][]-style [scriptless threshold signatures][topic threshold
  signature] that are compatible with Bitcoin's [schnorr
  signatures][topic schnorr signatures].

  Scriptless threshold signatures are compatible with the creation of
  `n` keys, any `t` of which can be used cooperatively to create a valid
  signature.  For example, a 2-of-3 scheme creates three keys, any two
  of which can produce a valid signature.  Being _scriptless_, the
  scheme relies entirely on operations external to consensus and the
  blockchain, unlike Bitcoin's built-in scripted threshold signature
  operations (e.g., using `OP_CHECKMULTISIG`).

  Similar to generating a regular Bitcoin private key, each person
  creating a key for scriptless threshold signatures must generate
  a large random-like number without disclosing that number to anyone
  else.  However, each person must also distribute derived shares of
  that number across the other users so that a threshold number of
  them can create a signature if that key is unavailable.  Each user
  must verify that the information they received from every other user
  was generated correctly.  Several key generation protocols for
  performing these steps exist, but they assume the key-generating users
  have access to a communication channel that is encrypted and
  authenticated between individual pairs of users and that also allows
  uncensorable authenticated broadcast from each user to all other
  users.  The ChillDKG protocol
  combines a well-known key generation algorithm for FROST with
  additional modern cryptographic primitives and simple algorithms to
  provide the necessary secure, authenticated, and provably uncensored
  communication.

  Encryption and authentication between participants starts with an
  [elliptic curve diffie-hellman][ecdh] (ECDH) exchange.  Proof of
  non-censorship is created by each participant using their base key to
  sign a transcript of the session from its start until the
  scriptless threshold public key is produced (which is the end of the
  session).  Before accepting the
  threshold public key as correct, each participant verifies every other
  participant's signed session transcript.

  The goal is to provide a fully generalized protocol that is
  usable in all cases where people want to generate keys for
  FROST-based scriptless threshold signatures.  Additionally, the
  protocol helps keep backups simple: all a user needs is their private
  seed and some recovery data that is not security sensitive (but does
  have privacy implications).  In a [follow-up message][nick follow-up],
  Jonas Nick mentioned that they're considering extending the protocol
  to encrypt the recovery data by a key derived from the seed so that
  the only data the user needs to keep private is their seed.

- **Introduction to cluster linearization:** Pieter Wuille
  [posted][wuille cluster] to Delving Bitcoin a detailed description of
  all the major parts of cluster linearization, the basis for [cluster
  mempool][topic cluster mempool].  Previous Optech newsletters have
  attempted to introduce the subject as its key concepts were being
  developed and published, but this overview is much more comprehensive.
  It takes readers in <!-- linear :-) --> order from fundamental
  concepts to the specific algorithms being implemented.  It ends with
  links to several Bitcoin Core pull requests that implement parts of
  cluster mempool.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #26596][] wallet: Migrate legacy wallets to descriptor wallets without requiring BDB

- [Core Lightning #7455][] ideally all these commits:

  - "config: onion messages are now always enabled."
  - "connectd: ratelimit onion messages"
  - "connectd: forward onion messages by scid as well as node_id."

- [Eclair #2878][] Activate route blinding and quiescence features

- [Rust Bitcoin #2646][] Some additional inspectors on Script and Witness

- [BDK #1489][] feat(electrum)!: Update `bdk_electrum` to use merkle proofs <!-- what!  they didn't do this before?  WTF was their security model? -->

- [BIPs #1599][] bip-0046: Address Scheme for Timelocked Fidelity Bonds

- [BIPs #1173][] Drop the required `channel_update` in failure onions

- [BLIPs #25][] valentinewallace/2023-05-forward-less-than-onion

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26596,7455,2878,2646,1489,1599,1173,25" %}
[ruffing nick post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8768422323203aa3a8b280940abd776526fab12e.camel@timruffing.de/T/#u
[chilldkg bip]: https://github.com/BlockstreamResearch/bip-frost-dkg
[chilldkg ref]: https://github.com/BlockstreamResearch/bip-frost-dkg/tree/master/python/chilldkg_ref
[nick follow-up]: https://groups.google.com/g/bitcoindev/c/HE3HSnGTpoQ/m/DC90IMZiBgAJ
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[frost]: https://eprint.iacr.org/2020/852.pdf
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
