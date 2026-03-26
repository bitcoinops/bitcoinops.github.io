---
title: 'Bitcoin Optech Newsletter #398'
permalink: /en/newsletters/2026/03/27/
name: 2026-03-27-newsletter
slug: 2026-03-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections with selected questions
and answers from the Bitcoin Stack Exchange, announcements of new releases and
release candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

*No significant news this week was found in any of our [sources][].*

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What is meant by "Bitcoin doesn't use encryption"?]({{bse}}130576)
  Pieter Wuille distinguishes encryption for purposes concealing data from
  unauthorized parties (which Bitcoin's ECDSA cannot be used for) from the
  digital signatures Bitcoin uses for verification and authentication.

- [When and why did Bitcoin Script shift to a commit–reveal structure?]({{bse}}130580)
  User bca-0353f40e explains the evolution from Bitcoin's original approach of
  users paying directly to public keys toward P2PKH and then to P2SH, [segwit][topic
  segwit] and [taproot][topic taproot] approaches, where spending conditions are
  committed to in the output and only revealed when spent.

- [Does P2TR-MS (Taproot M-of-N multisig) leak public keys?]({{bse}}130574)
  Murch confirms that a single-leaf taproot scriptpath multisig exposes all
  eligible public keys on spend since OP_CHECKSIG and OP_CHECKSIGADD both
  require that the public key corresponding to the signature is present.

- [Does OP_CHECKSIGFROMSTACK intentionally allow cross-UTXO signature reuse?]({{bse}}130598)
  User bca-0353f40e explains that [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack] ([BIP348][]) deliberately does not bind signatures to
  specific inputs which allows CSFS to be combined with other [convenant][topic
  covenants] opcodes to enable re-bindable signatures, the mechanism
  underlying [LN-Symmetry][topic eltoo].

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 28.4][] is a maintenance release for a previous major release
  series of the predominant full node implementation. It primarily contains
  wallet migration fixes and removal of an unreliable DNS seed. See the [release
  notes][bcc 28.4 rn] for details.

- [Core Lightning 26.04rc1][] is a release candidate for the next major version
  of this popular LN node which includes many splicing updates and bug fixes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33259][] adds a `backgroundvalidation` field to the
  `getblockchaininfo` RPC response for nodes using [assumeUTXO][topic
  assumeutxo] snapshots. The new field reports the snapshot height, the current
  block height and hash for background validation, median time, chainwork, and
  verification progress. Previously, `getblockchaininfo`'s response would simply
  indicate that verification and IBD were complete with no information on the
  background validation.

- [Bitcoin Core #33414][] enables Tor [proof of work defenses][tor pow] for
  automatically created onion services when supported by the connected Tor
  daemon. When a Tor daemon has an accessible control port and Bitcoin Core's
  `listenonion` setting is on (default), it will automatically create a hidden
  service. This doesn't apply to manually created onion services, but it's
  suggested that users add `HiddenServicePoWDefensesEnabled 1` to enable proof
  of work defenses.

- [Bitcoin Core #34846][] adds the functions `btck_transaction_get_locktime` and
  `btck_transaction_input_get_sequence` to the `libbitcoinkernel` C API (see
  [Newsletter #380][news380 kernel]) for accessing [timelock][topic timelocks]
  fields: a transaction's `nLockTime` and an input's `nSequence`. This allows
  checking [BIP54][] ([consensus cleanup][topic consensus cleanup]) rules such
  as coinbase `nLockTime` constraints without manually deserializing the
  transaction (other BIP54 rules, such as sigops limits, still require separate
  handling).

- [Core Lightning #8450][] extends CLN's [splice][topic splicing] scripting
  engine to handle cross-channel splices, multi-channel splices (more than
  three), and dynamic fee calculation. A key problem this solves is the circular
  dependency in fee estimation: adding wallet inputs increases transaction
  weight and therefore the required fee, which may in turn require additional
  inputs. This infrastructure underlies the new `splicein` and `spliceout` RPCs.

- [Core Lightning #8856][] and [#8857][core lightning #8857] add `splicein` and
  `spliceout` RPC commands for adding funds from the internal wallet into a
  channel and for removing funds from a channel to the internal wallet, a
  Bitcoin address, or another channel (effectively a cross-splice). The new
  commands avoid operators having to construct [splicing][topic splicing]
  transactions manually with the experimental `dev-splice` RPC.

- [Eclair #3247][] adds an optional peer-scoring system that tracks per-peer
  forwarding revenue and payment volume over time. When enabled, it periodically
  ranks peers by profitability and can optionally auto-fund channels to
  top-earning peers, auto-close unproductive channels to reclaim liquidity, and
  auto-adjust relay fees based on volume, all within configurable bounds.
  Operators can start with visibility only before opting into automation.

- [LDK #4472][] fixes a potential funds-loss scenario during channel funding and
  [splicing][topic splicing] where `tx_signatures` could be sent before the
  counterparty's commitment signature was durably persisted. If the transaction
  confirms and the node then crashes, it would lose the ability to enforce its
  channel state. The fix defers releasing `tx_signatures` until the
  corresponding monitor update completes.

- [LND #10602][] adds a `DeleteAttempts` RPC to the experimental `switchrpc`
  subsystem (see [Newsletter #386][news386 sendonion]) to allow external
  controllers to explicitly delete completed (succeeded or failed, not pending)
  [HTLC][topic htlc] attempt records from LND's attempt store.

- [LND #10481][] adds a `bitcoind` miner backend to LND's integration test
  framework. Previously, `lntest` assumed a `btcd`-based miner even when using
  `bitcoind` as the chain backend. This change allows tests to exercise behavior
  that depends on Bitcoin Core's mempool and mining policy, including [v3
  transaction relay][topic v3 transaction relay] and [package relay][topic
  package relay].

- [BOLTs #1160][] merges the [splicing][topic splicing] protocol into the
  Lightning specification, replacing the draft in [BOLTs #863][] with updated
  flows and test vectors for edge cases that motivated the rewrite (see
  [Newsletter #246][news246 splicing draft] for discussion when that draft was
  under active development). Splicing lets peers add or remove funds without
  closing the channel; negotiation begins from a quiescent state ([BOLTs
  #869][], [Newsletter #309][news309 quiescence]). The merged BOLT2 text covers
  interactive construction of the splice transaction, continuing to operate the
  channel while a splice is unconfirmed, [RBF][topic rbf] of pending splices,
  reconnect behavior, `splice_locked` after sufficient depth, and updated
  [channel announcements][topic channel announcements].

{% include snippets/recap-ad.md when="2026-03-31 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33259,33414,34846,8450,8856,8857,3247,4472,10602,10481,1160,863,869" %}
[sources]: /en/internal/sources/
[Bitcoin Core 28.4]: https://bitcoincore.org/en/2026/03/18/release-28.4/
[bcc 28.4 rn]: https://bitcoincore.org/en/releases/28.4/
[Core Lightning 26.04rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc1
[tor pow]: https://tpo.pages.torproject.net/onion-services/ecosystem/technology/security/pow/
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news386 sendonion]: /en/newsletters/2026/01/02/#lnd-9489
[news246 splicing draft]: /en/newsletters/2023/04/12/#splicing-specification-discussions
[news309 quiescence]: /en/newsletters/2024/06/28/#bolts-869
