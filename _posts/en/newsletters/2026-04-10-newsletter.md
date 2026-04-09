---
title: 'Bitcoin Optech Newsletter #400'
permalink: /en/newsletters/2026/04/10/
name: 2026-04-10-newsletter
slug: 2026-04-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections summarizing a Bitcoin Core
PR Review Club meeting and describing notable changes to popular Bitcoin
infrastructure projects.

## News

*No significant news this week was found in any of our [sources][].*

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33908][] adds `btck_check_block_context_free` to the
  `libbitcoinkernel` C API (see [Newsletter #380][news380 kernel]) for
  validating candidate blocks with context-free checks: block size/weight
  limits, coinbase rules, and per-transaction checks that do not depend on
  chainstate, the block index, or the UTXO set. Callers can optionally enable
  proof-of-work verification and merkle-root verification in this endpoint.

- [Eclair #3283][] adds a `fee` field (in msats) to the full-format responses
  of the `findroute`, `findroutetonode`, and `findroutebetweennodes` endpoints
  used for pathfinding. This field provides the route's total
  [forwarding fee][topic inbound forwarding fees], eliminating the need for
  callers to compute it manually.

- [LDK #4529][] enables operators to set different limits for announced and
  [unannounced channels][topic unannounced channels] when configuring the total
  value of inbound [HTLCs][topic htlc] in flight, as a percentage of channel
  capacity. The defaults are now 25% for announced channels and 100% for
  unannounced channels.

- [LDK #4494][] updates its internal [RBF][topic rbf] logic to ensure compliance
  with [BIP125][]'s replacement rules at low feerates. Instead of only applying
  the 25/24 feerate multiplier specified in [BOLT2][], LDK now uses whichever is
  larger: that multiplier or an additional 25 sat/kwu. A related specification
  clarification is being discussed in [BOLTs #1327][].

- [LND #10666][] adds a `DeleteForwardingHistory` RPC and an `lncli
  deletefwdhistory` command, enabling operators to selectively delete forwarding
  events older than a chosen cutoff timestamp. A minimum age guard of one hour
  prevents the accidental removal of recent data. This feature enables routing
  nodes to delete historical forwarding records without resetting the database
  or taking the node offline.

- [BIPs #2099][] publishes [BIP393][], which specifies an optional annotation
  syntax for output script [descriptors][topic descriptors], enabling wallets to
  store recovery hints, such as a birthday height to speed up wallet scanning
  (including for [silent payment][topic silent payments] scanning). See [Newsletter
  #394][news394 bip393] for initial coverage of this BIP with additional
  details.

- [BIPs #2118][] publishes [BIP440][] and [BIP441][] as Draft BIPs in the Great
  Script Restoration (or Grand Script Renaissance) series (see [Newsletter #399][news399 bips]).
  [BIP440][] proposes the Varops Budget for Script Runtime Constraint (see
  [Newsletter #374][news374 varops]); [BIP441][] describes a new
  [tapscript][topic tapscript] version that restores opcodes disabled in 2010
  such as [OP_CAT][topic op_cat] (see [Newsletter #374][news374 tapscript]) and
  limits script evaluation costs per the varops budget introduced in BIP440.

- [BIPs #2134][] updates [BIP352][] ([silent payments][topic silent payments]) to
  warn wallet developers not to let policy filtering, such as for
  [dust][topic uneconomical outputs], affect whether scanning continues after a
  match is found. Treating a filtered-out output as if there were no match can
  cause the wallet to prematurely stop scanning and miss later outputs from the
  same sender.

{% include snippets/recap-ad.md when="2026-04-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33908,3283,4529,4494,10666,2099,2118,2134,1327" %}
[sources]: /en/internal/sources/
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news394 bip393]: /en/newsletters/2026/02/27/#draft-bip-for-output-script-descriptor-annotations
[news399 bips]: /en/newsletters/2026/04/03/#varops-budget-and-tapscript-leaf-0xc2-aka-script-restoration-are-bips-440-and-441
[news374 varops]: /en/newsletters/2025/10/03/#first-bip
[news374 tapscript]: /en/newsletters/2025/10/03/#second-bip
[BIP393]: https://github.com/bitcoin/bips/blob/master/bip-0393.mediawiki
[BIP440]: https://github.com/bitcoin/bips/blob/master/bip-0440.mediawiki
[BIP441]: https://github.com/bitcoin/bips/blob/master/bip-0441.mediawiki
