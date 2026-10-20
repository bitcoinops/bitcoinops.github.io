---
title: 'Bitcoin Optech Newsletter #409'
permalink: /en/newsletters/2026/06/12/
name: 2026-06-12-newsletter
slug: 2026-06-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a draft BIP to replace the testnet4 test
network with a successor. Also included are our regular sections announcing
new releases and release candidates and describing notable changes to popular
Bitcoin infrastructure software.

## News

- **Draft BIP for testnet5**: Pol Espinasa [posted][testnet5 ml] to the
  Bitcoin-Dev mailing list a [draft BIP][testnet5 BIP], co-authored with Fabian
  Jahr, to replace [testnet4][topic testnet] with testnet5.
  The proposal is motivated by testnet4's low reliability, which stems from
  sustained exploitation of the difficulty exception (also known as the
  20-minute rule). This rule allows CPU miners to mine blocks at difficulty `1` once 20
  minutes have passed since the previous block, enabling "block storms" in which
  large numbers of low-difficulty blocks can be mined in a short time (see
  [Newsletter #311][news311 block storm]).

  The draft BIP proposes removing the difficulty exception rule so that testnet
  matches mainnet behavior as closely as possible. Testnet5 would follow the
  same consensus rules as mainnet except for two changes: activating [BIP54][]
  (the [consensus cleanup soft fork][topic consensus cleanup]) from block `1`,
  and setting the maximum proof-of-work target to `0x1a0fffff`
  (a lower maximum target than testnet4, i.e. a higher minimum difficulty).

  Espinasa invited other developers to provide feedback on the proposal.
  Discussion on the mailing list thread centered on applying patches to testnet4
  instead of spinning up a new one, the possibility of pre-mining testnet coins,
  and the best minimum difficulty for the new network. {% assign timestamp="0:31" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.21.0-beta][] is a release of the next major version of this popular
  LN node implementation. It adds basic [onion message][topic onion messages]
  forwarding, production-ready simple [taproot][topic taproot] channels with support
  for [RBF][topic rbf] cooperative closes, reorg protection for channel closes,
  faster initial sync for [Neutrino][topic compact block filters]-backed nodes,
  an optional native-SQL payment store migration, plus multiple bug fixes. {% assign timestamp="17:25" %}

- [Core Lightning 26.06.1][] is a maintenance release for the current major
  version of this popular LN node. It fixes a `bwatch` plugin registration
  failure after running `make install`. {% assign timestamp="20:19" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #35410][] fixes a bug that could cause a [private transaction
  broadcast][topic transaction origin privacy] retry to connect directly to an
  IPv4 or IPv6 peer instead of using [Tor or I2P][topic anonymity networks].
  When `sendrawtransaction` was used with `-privatebroadcast=1` (see
  [Newsletter #388][news388 private broadcast]), Bitcoin Core forces
  transaction broadcast connections through a Tor or I2P proxy. If one of those
  connections attempts [BIP324][] v2 transport but fails, it retries v1
  transport. Previously, the retry could forget the private broadcast proxy
  override on nodes that otherwise made direct IPv4/IPv6 connections. The proxy
  override is now stored and carried through v2-to-v1 reconnections. {% assign timestamp="21:28" %}

- [Bitcoin Core #34779][] implements [BIP323][], reserving block header
  `nVersion` bits 5 through 28 as extra nonce space for miners (see
  [Newsletter #405][news405 bip323]). Previously, these bits were part of the
  range monitored by the [BIP9][] version bits warning logic for unknown soft
  fork signaling. Bitcoin Core now excludes the [BIP323][]-reserved bits from
  that warning logic, preventing miners who use them for nonce rolling from
  triggering unknown soft fork warnings. {% assign timestamp="38:00" %}

- [Bitcoin Core #32150][] rewrites the [branch-and-bound][] [coin
  selection][topic coin selection] algorithm to avoid walking back through
  parts of the search tree that only reproduce equivalent input sets. Instead
  of repeatedly backtracking and retesting the same selection prefixes, the new
  search tracks the next UTXO to try, cuts branches that can't reach the
  target, shifts directly to the next useful candidate, and skips duplicate or
  more wasteful UTXOs with the same effective value. This allows the wallet to
  use its iteration budget on more distinct candidate selections. {% assign timestamp="41:36" %}

- [LDK #4647][] stops using remote introduction nodes for [BOLT12][topic
  offers] [blinded message paths][topic rv routing] to avoid incompatibility
  with LND's opt-in [onion message][topic onion messages] support, which may
  receive but not forward messages from non-channel peers. LDK now uses the
  announced recipient itself as the introduction point, improving
  interoperability but reducing receiver privacy. {% assign timestamp="45:14" %}

- [BTCPay Server #7218][] adds a guided setup flow for BTC multisig wallets.
  Store owners can choose a signing policy, invite store users to submit signer
  keys manually or through BTCPay Server Vault, review generated addresses, and
  create the wallet once the necessary keys are collected. {% assign timestamp="51:34" %}

- [BIPs #2186][] updates [BIP77][] to specify how a [payjoin v2][topic payjoin]
  receiver replies to a [BIP78][]-compatible sender. [BIP77][]'s normal
  response path uses a reply key provided by the sender to encrypt the proposal
  [PSBT][topic psbt] and deliver it to a sender-derived reply mailbox, but
  [BIP78][] senders do not provide reply keys. Instead, the receiver writes the
  base64-encoded proposal PSBT back to the receiver's mailbox where the sender
  posted the original PSBT. The receiver uses an OHTTP-encapsulated PUT request
  to the directory. This documents the backwards-compatible response path used
  by implementations. {% assign timestamp="53:07" %}

{% include snippets/recap-ad.md when="2026-06-16 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35410,34779,32150,4647,7218,2186" %}

[testnet5 ml]: https://groups.google.com/g/bitcoindev/c/kGUMTxOvdJA/m/Eyx5FxQeAAAJ
[testnet5 BIP]: https://github.com/bitcoin/bips/pull/2196
[news311 block storm]: /en/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[LND 0.21.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.0-beta
[Core Lightning 26.06.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.1
[news388 private broadcast]: /en/newsletters/2026/01/16/#bitcoin-core-29415
[news405 bip323]: /en/newsletters/2026/05/15/#bips-2116
[branch-and-bound]: https://en.wikipedia.org/wiki/Branch_and_bound
