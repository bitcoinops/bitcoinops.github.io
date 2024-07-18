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

- **ZEUS adds BOLT12 offers and BIP353 support:**
  The [v0.8.5][zeus v0.8.5] release leverages the [TwelveCash][twelve cash
  website] service to support [offers][topic offers] and [BIP353][] (see
  [Newsletter #307][news307 bip353]).

- **Phoenix adds BOLT12 offers and BIP353 support:**
  The [Phoenix 2.3.1][phoenix 2.3.1] release added offers support and [Phoenix
  2.3.3][phoenix 2.3.3] added [BIP353][] support.

- **Stack Wallet adds RBF and CPFP support:**
  Stack Wallet's [v2.1.1][stack wallet v2.1.1] release added support for fee bumping using
  [RBF][topic rbf] and [CPFP][topic cpfp] as well as [Tor][topic anonymity
  networks] support.

- **BlueWallet adds silent payment send support:**
  In the [v6.6.7][bluewallet v6.6.7] release, BlueWallet added the ability to send to
  [silent payment][topic silent payments] addresses.

- **BOLT12 Playground announced:**
  Strike [announced][strike bolt12 playground] a testing environment for BOLT12
  offers. The project uses Docker to initiate and automate wallets, channels, and payments
  across different LN implementations.

- **Moosig testing repository announced:**
  Ledger has published a Python-based testing [repository][moosig github] for using
  [MuSig2][topic musig] and [BIP388][] wallet [policies for descriptor wallets][news302 bip388].

- **Real-time Stratum visualization tool released:**
  The [stratum.work website][stratum.work], based on [previous research][b10c
  nostr] displays real-time Stratum messages from a variety of Bitcoin mining
  pools, with [source code available][stratum work github].

- **BMM 100 Mini Miner announced:**
  The [mining hardware][braiins mini miner] from Braiins comes with a subset of [Stratum V2][topic
  pooled mining] features enabled by default.

- **Coldcard publishes URL-based transaction broadcast specification:**
  The [protocol][pushtx spec] enables broadcasting of a Bitcoin transaction
  using an HTTP GET request and can be used by NFC-based hardware signing
  devices, among other use cases.

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
[zeus v0.8.5]: https://github.com/ZeusLN/zeus/releases/tag/v0.8.5
[twelve cash website]: https://twelve.cash/
[news307 bip353]: /en/newsletters/2024/06/14/#bips-1551
[phoenix 2.3.1]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.3.1
[phoenix 2.3.3]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.3.3
[stack wallet v2.1.1]: https://github.com/cypherstack/stack_wallet/releases/tag/build_235
[bluewallet v6.6.7]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.6.7
[strike bolt12 playground]: https://strike.me/blog/bolt12-playground/
[moosig github]: https://github.com/LedgerHQ/moosig
[news302 bip388]: /en/newsletters/2024/05/15/#bips-1389
[stratum.work]: https://stratum.work/
[stratum work github]: https://github.com/bboerst/stratum-work
[b10c nostr]: https://primal.net/e/note1qckcs4y67eyaawad96j7mxevucgygsfwxg42cvlrs22mxptrg05qtv0jz3
[braiins mini miner]: https://braiins.com/hardware/bmm-100-mini-miner
[pushtx spec]: https://pushtx.org/#url-protocol-spec
