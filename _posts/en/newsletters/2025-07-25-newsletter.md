---
title: 'Bitcoin Optech Newsletter #364'
permalink: /en/newsletters/2025/07/25/
name: 2025-07-25-newsletter
slug: 2025-07-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a vulnerability affecting old versions
of LND, describes an idea for improving privacy when using co-signer
services, and examines the impact of switching to quantum-resistant
signature algorithms on HD wallets, scriptless multisig, and silent
payments.  Also included are our regular sections summarizing popular
questions and answers on the Bitcoin Stack Exchange, announcing new
releases and release candidates, and describing notable changes to
popular Bitcoin infrastructure software.

## News

- **LND gossip filter DoS vulnerability:** Matt Morehouse
  [posted][morehouse gosvuln] to Delving Bitcoin about a vulnerability
  affecting past versions of LND that he previously [responsibly
  disclosed][topic responsible disclosures].  An attacker could
  repeatedly request historic gossip messages from an LND node until it
  ran out of memory and was terminated.  The vulnerability was fixed in
  LND 0.18.3, released September 2024.

- **Chain code withholding for multisig scripts:** Jurvis Tan
  [posted][tan ccw] to Delving Bitcoin about research he performed with
  Jesse Posner into improving the privacy and security of multisig
  collaborative custody.  In a typical collaborative custody service, a
  2-of-3 multisig may be used with the three keys being:

  - A user _hot key_ that is stored on a networked device and signs
    transactions for the user (either manually or through software
    automation).

  - A provider hot key that is stored on a separate networked device
    under the exclusive control of the provider.  The key only signs
    transactions according to a policy previously defined by the user,
    such as only allowing spending up to _x_ BTC a day.

  - A user _cold key_ that is stored offline and is only used if either
    the user hot key is lost or the provider ceases signing authorized
    transactions.

  Although the above configuration can provide a significant boost to
  security, the setup method almost always used involves the user
  sharing with the provider the [BIP32 extended public keys][topic
  bip32] for the user's hot and cold wallets.  This allows the
  provider to detect all funds received by the user's wallet and to track
  all spends of those funds even if the user spends without provider
  assistance.  Several ways to mitigate this privacy loss have
  previously been described, but they are either incompatible with
  typical use (e.g. using separate tapleaves) or complex (e.g. requiring
  [MPC][]).  Tan and Posner describe a simple alternative:

  - The provider generates half of a BIP32 HD extended key (just
    the key part).  They give the public key to the user.

  - The user generates the other half (the chain code).  They keep this
    private.

  When receiving funds, the user can combine the two halves to create an
  extended public key (xpub) and then derive multisig addresses as
  usual.  The provider doesn't know the chain code, preventing them
  from deriving the xpub or discovering the address.

  When spending funds, the user can derive from the chain code the
  necessary _tweak_ that the provider needs to combine with their
  private key to create a valid signature.  They simply share
  this tweak with the provider.  The provider can't learning anything
  from the tweak except that it's valid for spending from the specific
  scriptPubKey that received funds.

  Some providers may require that the change output for a spending
  transaction sends the money back to the same script template.  Tan's
  post describes how this can easily be accomplished.

- **Research indicates common Bitcoin primitives are compatible with quantum-resistant signature algorithms:**
  Jesse Posner [posted][posner qc] to Delving Bitcoin several links to
  research papers that indicate that [quantum-resistant][topic quantum
  resistance] signature algorithms provide comparable primitives to
  those currently used in Bitcoin for [BIP32 HD wallets][topic bip32],
  [silent payment addresses][topic silent payments], [scriptless
  multisignatures][topic multisignature], and [scriptless threshold
  signatures][topic threshold signature].

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [How does Bitcoin Core handle reorgs larger than 10 blocks?]({{bse}}127512)
  TheCharlatan links to Bitcoin Core code that handles chain reorganizations by
  only re-adding a maximum of 10 blocks worth of transactions to the mempool.

- [Advantages of a signing device over an encrypted drive?]({{bse}}127596)
  RedGrittyBrick points out that data on an encrypted drive can be extracted
  while the drive is unencrypted whereas hardware signing devices are designed to
  prevent this data extraction attack.

- [Spending a taproot output through the keypath and scriptpath?]({{bse}}127601)
  Antoine Poinsot details how the use of merkle trees, key tweaks, and leaf
  scripts achieves taproot's keypath and scriptpath spending capabilities.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Libsecp256k1 v0.7.0][] is a release of this library containing
  cryptographic primitives compatible with Bitcoin.  It contains a few
  small changes that break API/ABI compatibility with previous releases.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32521][] makes legacy transactions with more than 2500
  signature operations (sigops) non-standard in preparation for a potential
  [consensus cleanup soft fork][topic consensus cleanup] upgrade that would
  enforce the limit at the consensus level. If the softfork took place without
  this change, miners who don’t upgrade could become targets of trivial DoS
  attacks. See Newsletter [#340][news340 sigops] for additional details on the
  legacy input sigops limit.

- [Bitcoin Core #31829][] adds resource limits to the orphan transaction
  handler, `TxOrphanage` (See Newsletter [#304][news304 orphan]), to preserve
  opportunistic one-parent-one-child (1p1c) [package relay][topic package relay]
  in the face of DoS spam attacks. Four limits are enforced: a global cap
  of 3,000 orphan announcements (to minimize CPU and latency cost), a proportional per‑peer
  orphan announcements cap, a per‑peer weight reservation of 24 × 400 kWU, and a
  variable global memory cap. When any limit is exceeded, the node evicts the
  oldest orphan announcement from the peer that has used the most CPU or memory
  relative to its allowance (highest Peer DoS Score). The PR also deletes the
  `‑maxorphantxs` option (default 100), whose policy of evicting random
  announcements allowed attackers to replace the entire orphan set and render
  [1p1c relay][1p1c relay] useless.  See also [Newsletter #362][news362
  orphan].

- [LDK #3801][] extends [attributable failures][topic attributable failures] to
  the payment success path by recording how long a node holds an [HTLC][topic
  htlc] and propagating those hold‑time values upstream in the attribution
  payload. Previously, LDK only tracked hold times for failed payments (see
  Newsletter [#349][news349 attributable]).

- [LDK #3842][] extends its [interactive transaction construction][topic dual
  funding] state machine (See Newsletter [#295][news295 dual]) to handle the
  signing coordination for shared inputs in [splicing][topic splicing]
  transactions. The `prevtx` field of the `TxAddInput` message is made optional
  to reduce memory usage and simplify validation.

- [BIPs #1890][] changes the separator parameter from `+` to `-` in [BIP77][]
  because some HTML 2.0 URI libraries treat `+` as if it is a blank space. In
  addition, fragment parameters must now be ordered lexicographically, rather
  than in reverse, to simplify the async [payjoin][topic payjoin] protocol.

- [BOLTs #1232][] makes the `channel_type` field (see Newsletter [#165][news165
  type]) mandatory when opening a channel because every implementation enforces
  it. This PR also updates [BOLT9][] by adding a new context type `T` for
  features that can be included in the `channel_type` field.

{% include snippets/recap-ad.md when="2025-07-29 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32521,31829,3801,3842,1890,1232" %}
[morehouse gosvuln]: https://delvingbitcoin.org/t/disclosure-lnd-gossip-timestamp-filter-dos/1859
[tan ccw]: https://delvingbitcoin.org/t/chain-code-delegation-private-access-control-for-bitcoin-keys/1837
[mpc]: https://en.wikipedia.org/wiki/Secure_multi-party_computation
[posner qc]: https://delvingbitcoin.org/t/post-quantum-hd-wallets-silent-payments-key-aggregation-and-threshold-signatures/1854
[Libsecp256k1 v0.7.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.7.0
[news340 sigops]: /en/newsletters/2025/02/07/#introduce-legacy-input-sigops-limit
[news304 orphan]: /en/newsletters/2024/05/24/#bitcoin-core-30000
[1p1c relay]: /en/bitcoin-core-28-wallet-integration-guide/#one-parent-one-child-1p1c-relay
[news349 attributable]: /en/newsletters/2025/04/11/#ldk-2256
[news295 dual]: /en/newsletters/2024/03/27/#ldk-2419
[news165 type]: /en/newsletters/2021/09/08/#bolts-880
[news362 orphan]: /en/newsletters/2025/07/11/#bitcoin-core-pr-review-club
