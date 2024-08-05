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
  the only data the user needs to keep private is their seed. {% assign timestamp="1:37" %}

- **Introduction to cluster linearization:** Pieter Wuille
  [posted][wuille cluster] to Delving Bitcoin a detailed description of
  all the major parts of cluster linearization, the basis for [cluster
  mempool][topic cluster mempool].  Previous Optech newsletters have
  attempted to introduce the subject as its key concepts were being
  developed and published, but this overview is much more comprehensive.
  It takes readers in <!-- linear :-) --> order from fundamental
  concepts to the specific algorithms being implemented.  It ends with
  links to several Bitcoin Core pull requests that implement parts of
  cluster mempool. {% assign timestamp="28:45" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **ZEUS adds BOLT12 offers and BIP353 support:**
  The [v0.8.5][zeus v0.8.5] release leverages the [TwelveCash][twelve cash
  website] service to support [offers][topic offers] and [BIP353][] (see
  [Newsletter #307][news307 bip353]). {% assign timestamp="56:15" %}

- **Phoenix adds BOLT12 offers and BIP353 support:**
  The [Phoenix 2.3.1][phoenix 2.3.1] release added offers support and [Phoenix
  2.3.3][phoenix 2.3.3] added [BIP353][] support. {% assign timestamp="57:02" %}

- **Stack Wallet adds RBF and CPFP support:**
  Stack Wallet's [v2.1.1][stack wallet v2.1.1] release added support for fee bumping using
  [RBF][topic rbf] and [CPFP][topic cpfp] as well as [Tor][topic anonymity
  networks] support. {% assign timestamp="57:42" %}

- **BlueWallet adds silent payment send support:**
  In the [v6.6.7][bluewallet v6.6.7] release, BlueWallet added the ability to send to
  [silent payment][topic silent payments] addresses. {% assign timestamp="57:59" %}

- **BOLT12 Playground announced:**
  Strike [announced][strike bolt12 playground] a testing environment for BOLT12
  offers. The project uses Docker to initiate and automate wallets, channels, and payments
  across different LN implementations. {% assign timestamp="59:10" %}

- **Moosig testing repository announced:**
  Ledger has published a Python-based testing [repository][moosig github] for using
  [MuSig2][topic musig] and [BIP388][] wallet [policies for descriptor wallets][news302 bip388]. {% assign timestamp="59:56" %}

- **Real-time Stratum visualization tool released:**
  The [stratum.work website][stratum.work], based on [previous research][b10c
  nostr], displays real-time Stratum messages from a variety of Bitcoin mining
  pools, with [source code available][stratum work github]. {% assign timestamp="1:01:01" %}

- **BMM 100 Mini Miner announced:**
  The [mining hardware][braiins mini miner] from Braiins comes with a subset of [Stratum V2][topic
  pooled mining] features enabled by default. {% assign timestamp="1:01:57" %}

- **Coldcard publishes URL-based transaction broadcast specification:**
  The [protocol][pushtx spec] enables broadcasting of a Bitcoin transaction
  using an HTTP GET request and can be used by NFC-based hardware signing
  devices, among other use cases. {% assign timestamp="1:02:32" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #26596][] uses the new read-only legacy database for migrating
  legacy wallets to [descriptor][topic descriptors] wallets. This change does
  not deprecate legacy wallets or the legacy `BerkeleyDatabase`. A new
  `LegacyDataSPKM` class has been created that contains only the essential data
  and functions needed to load a legacy wallet for migration. See Newsletter
  [#305][news305 bdb] for an introduction to the `BerkeleyRODatabase`. {% assign timestamp="1:09:38" %}

- [Core Lightning #7455][] enhances `connectd`'s [onion message][topic onion
  messages] handling by implementing forwarding via both `short_channel_id`
  (SCID) and `node_id` (see [Newsletter #307][news307 ldk3080] for
  discussion about a similar change to LDK). Onion messages are now
  always enabled, and incoming messages are rate limited to 4 per
  second. {% assign timestamp="1:11:27" %}

- [Eclair #2878][] makes the [route blinding][topic rv routing] and channel
  quiescence features optional, since they're now fully implemented and part
  of the BOLT specification (see Newsletters [#245][news245 blind] and
  [#309][news309 stfu]). An Eclair node advertises support for these
  features to its peers, but has `route_blinding` disabled by default because it
  will not forward [blinded payments][topic rv routing] that do not use
  [trampoline routing][topic trampoline payments]. {% assign timestamp="1:11:58" %}

- [Rust Bitcoin #2646][] introduces new inspectors for script and witness
  structures such as `redeem_script` to ensure compliance with [BIP16][];
  rules regarding P2SH spending, `taproot_control_block`, and `taproot_annex` to
  ensure compliance with [BIP341][] rules; and `witness_script` to ensure
  P2WSH witness scripts comply with [BIP141][] rules. See Newsletter
  [#309][news309 p2sh]. {% assign timestamp="1:13:03" %}

- [BDK #1489][] updates `bdk_electrum` to use merkle proofs for simplified
  payment verification (SPV). It fetches merkle proofs and block headers alongside
  transactions, validates that transactions are in confirmed blocks before
  inserting anchors, and removes reorg handling from `full_scan`. The PR also
  introduces `ConfirmationBlockTime` as a new anchor type, replacing previous
  types. {% assign timestamp="1:13:55" %}

- [BIPs #1599][] adds [BIP46][] for a derivation scheme for HD wallets that
  create [timelocked][topic timelocks] addresses used for [fidelity
  bonds][news161 fidelity] as used for JoinMarket-style [coinjoin][topic coinjoin] market matching. Fidelity
  bonds improve the sybil resistance of the protocol by creating a reputation
  system where makers prove their intentional sacrifice of the time value of
  money by timelocking bitcoin. {% assign timestamp="1:15:22" %}

- [BOLTs #1173][] makes the `channel_update` field optional in failure [onion
  messages][topic onion messages]. Nodes now ignore this field outside the
  current payment to prevent fingerprinting of [HTLC][topic htlc] senders. The change aims to
  discourage payment delays due to outdated channel parameters while still
  allowing nodes with stale gossip data to benefit from updates when needed. {% assign timestamp="1:17:50" %}

- [BLIPs #25][] adds [BLIP25][] describing how to allow forwarding HTLCs that
  underpay the encoded onion value. For example, Alice provides a lightning
  invoice to Bob but she has no payment channels, so when Bob pays, Carol
  (Alice’s LSP) creates a channel on the fly. To allow Carol to take a fee from
  Alice to cover the cost of the initial onchain fee that creates a [JIT channel][topic jit channels],
  this protocol is used, and Alice is forwarded an HTLC that underpays the
  encoded onion value.  For previous discussion about an implementation
  of this in LDK, see [Newsletter #257][news257 jit htlc]. {% assign timestamp="1:18:50" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26596,7455,2878,2646,1489,1599,1173,25" %}
[ruffing nick post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8768422323203aa3a8b280940abd776526fab12e.camel@timruffing.de/T/#u
[chilldkg bip]: https://github.com/BlockstreamResearch/bip-frost-dkg
[chilldkg ref]: https://github.com/BlockstreamResearch/bip-frost-dkg/tree/master/python/chilldkg_ref
[nick follow-up]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7084f935-0201-4909-99ff-c76f83572a7c@gmail.com/
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
[news305 bdb]: /en/newsletters/2024/05/31/#bitcoin-core-26606
[news309 p2sh]: /en/newsletters/2024/06/28/#rust-bitcoin-2794
[news161 fidelity]: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[news257 jit htlc]: /en/newsletters/2023/06/28/#ldk-2319
[news307 ldk3080]: /en/newsletters/2024/06/14/#ldk-3080
[news245 blind]: /en/newsletters/2023/04/05/#bolts-765
[news309 stfu]: /en/newsletters/2024/06/28/#bolts-869
