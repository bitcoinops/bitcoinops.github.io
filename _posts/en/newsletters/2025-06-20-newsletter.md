---
title: 'Bitcoin Optech Newsletter #359'
permalink: /en/newsletters/2025/06/20/
name: 2025-06-20-newsletter
slug: 2025-06-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to limit public
participation in Bitcoin Core repositories, announces a significant
improvements to BitVM-style contracts, and summarizes research into
LN channel rebalancing.  Also included are our regular sections
summarizing recent changes to clients and services, announcing new
releases and release candidates, and describing recent changes to popular
Bitcoin infrastructure software.

## News

- **Proposal to restrict access to Bitcoin Core Project discussion:**
  Bryan Bishop [posted][bishop priv] to the Bitcoin-Dev mailing list to
  suggest that the Bitcoin Core Project limit the public's ability to
  participate in project discussions in order to reduce the amount of
  disruption caused by non-contributors.  He called this
  "privatizing Bitcoin Core",
  points to examples of this privatization already happening on an ad
  hoc basis in private offices with multiple Bitcoin Core contributors,
  and warns that in-person privatization leaves out remote contributors.

  Bishop's post suggests a method for online privatization, but
  Antoine Poinsot [questioned][poinsot priv] whether that method would
  achieve the goal.  Poinsot also suggested that many private
  office discussions might occur not out of fear of public reproach but
  because of "the natural advantages of in-person discussions".

  Several replies suggested that making major changes is
  probably not warranted at this time but that stronger moderation of
  comments on the repository might alleviate the most
  significant type of disruption.  However, other replies noted several
  challenges with stronger moderation.

  Poinsot, Sebastian "The Charlatan" Kung, and Russell Yanofsky---the only highly
  active Bitcoin Core contributors to reply to the thread as of the time
  of writing---[indicated][kung priv] either [that][yanofsky priv]  they don't think a major
  change is necessary or that any changes should be made incrementally
  over time. {% assign timestamp="1:11" %}

- **Improvements to BitVM-style contracts:** Robin Linus [posted][linus
  bitvm3] to Delving Bitcoin to announce a significant reduction in the
  amount of onchain space required by [BitVM][topic acc]-style
  contracts.  Based on an [idea][rubin garbled] by Jeremy Rubin that
  builds on new cryptographic primitives, the new approach "reduces the
  onchain cost of a dispute by over 1,000 times compared to the previous
  design", with disprove transactions being "just 200 bytes".

  However, Linus's paper notes the tradeoff for this approach: it
  "requires a multi-terabyte offchain data setup".  The paper gives an
  example of a SNARK verifier circuit with about 5 billion gates and
  reasonable security parameters requiring a 5 TB offchain setup, 56 kB
  onchain transaction to assert the result, and minimal onchain
  transaction (~200 B) in the case that a party needs to prove the
  assertion was invalid. {% assign timestamp="21:17" %}

- **Channel rebalancing research:** Rene Pickhardt [posted][pickhardt
  rebalance] to Delving Bitcoin thoughts about rebalancing channels
  to maximize the rate of successful payments across
  the whole network.  His ideas can be compared to approaches that look
  at smaller groups of channels, such as [friend-of-a-friend
  rebalancing][topic jit routing] (see [Newsletter #54][news54 foaf
  rebalance]).

  Pickhardt notes that there are several challenges to a global approach and
  asks interested parties to answer a few questions, such as whether
  this approach is worth pursuing and how to address certain
  implementation details. {% assign timestamp="41:57" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Cove v1.0.0 released:**
  Recent Cove [releases][cove github] include coin control support and
  additional [BIP329][] wallet label features. {% assign timestamp="1:03:58" %}

- **Liana v11.0 released:**
  Recent [releases][liana github] of Liana include features for multiple
  wallets, additional coin control features, and more hardware signing device
  support, among other features. {% assign timestamp="1:04:59" %}

- **Stratum v2 STARK proof demo:**
  StarkWare [demonstrated][starkware tweet] a [modified Stratum v2 mining
  client][starkware sv2] using a STARK proof to prove that a block's fees
  belongs to a valid block template without revealing the transactions in the
  block. {% assign timestamp="1:06:48" %}

- **Breez SDK adds BOLT12 and BIP353:**
  Breez SDK Nodeless [0.9.0][breez github] adds support for receiving using
  [BOLT12][] and [BIP353]. {% assign timestamp="1:08:41" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 25.05][] is a release of the next major
  version of this popular LN node implementation.  It reduces the
  latency of relaying and resolving payments, improves fee
  management, provides [splicing][topic splicing] support compatible
  with Eclair, and enables [peer storage][topic peer storage] by
  default.  Note: its [release documentation][core lightning 25.05]
  contains a warning for users of the `--experimental-splicing`
  configuration option. {% assign timestamp="1:09:51" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Eclair #3110][] raises the delay for marking a channel as closed after its
  funding output is spent from 12 (see Newsletter [#337][news337 delay]) to 72
  blocks as specified in [BOLTs #1270][], to allow for the propagation of a
  [splice][topic splicing] update. It was increased because some implementations
  default to 8 confirmations before sending `splice_locked` and allow node
  operators to raise that threshold, so 12 blocks proved too short. The delay is
  now configurable for testing purposes and to allow node operators to wait
  longer. {% assign timestamp="1:11:32" %}

- [Eclair #3101][] introduces the `parseoffer` RPC, which decodes [BOLT12
  offer][topic offers] fields into a human-readable format, allowing users to
  view the amount before passing it to the `payoffer` RPC. The latter is
  extended to accept an amount specified in a fiat currency. {% assign timestamp="1:12:41" %}

- [LDK #3817][] rolls back support for [attributable failures][topic attributable failures] (see Newsletter
  [#349][news349 attributable]) by placing it under a test-only flag. This
  disables the peer penalization logic and removes the feature TLV from failure
  [onion messages][topic onion messages]. Nodes that hadn’t upgraded yet were
  wrongly penalized, showing that broader network adoption is necessary for it
  to work properly. {% assign timestamp="1:13:35" %}

- [LDK #3623][] extends [peer storage][topic peer storage] (see Newsletter
  [#342][news342 peer]) to provide automatic, encrypted peer backups. Each
  block, `ChainMonitor` packages the data from a versioned, timestamped, and serialized
  `ChannelMonitor` structure into an `OurPeerStorage` blob. Then, it encrypts the
  data and raises a `SendPeerStorage` event to relay the blob as a
  `peer_storage` message to every channel peer. Additionally, `ChannelManager`
  is updated to handle `peer_storage_retrieval` requests by triggering a new
  blob send.  {% assign timestamp="1:14:04" %}

- [BTCPay Server #6755][] enhances the coin control
  user interface with new minimum and maximum amount filters, before and after
  creation date filters, a help section for the filters, a "select all" UTXO
  checkbox, and large page size options (100, 200 or 500 UTXOs). {% assign timestamp="1:15:11" %}

- [Rust libsecp256k1 #798][] completes the [MuSig2][topic musig] implementation
  in the library, giving downstream projects access to a robust [scriptless
  multisignature][topic multisignature] protocol. {% assign timestamp="1:15:54" %}

{% include snippets/recap-ad.md when="2025-06-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3110,3101,3817,3623,6755,1270" %}
[Core Lightning 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[bishop priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CABaSBax-meEsC2013zKYJnC3phFFB_W3cHQLroUJcPDZKsjB8w@mail.gmail.com/
[poinsot priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/4iW61M7NCP-gPHoQZKi8ZrSa2U6oSjziG5JbZt3HKC_Ook_Nwm1PchKguOXZ235xaDlhg35nY8Zn7g1siy3IADHvSHyCcgTHrJorMKcDzZg=@protonmail.com/
[kung priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/58813483-7351-487e-8f7f-82fb18a4c808n@googlegroups.com/
[linus bitvm3]: https://delvingbitcoin.org/t/garbled-circuits-and-bitvm3/1773
[rubin garbled]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[pickhardt rebalance]: https://delvingbitcoin.org/t/research-update-a-geometric-approach-for-optimal-channel-rebalancing/1768
[rust libsecp256k1 #798]: https://github.com/rust-bitcoin/rust-secp256k1/pull/798
[news54 foaf rebalance]: /en/newsletters/2019/07/10/#brainstorming-just-in-time-routing-and-free-channel-rebalancing
[yanofsky priv]: https://github.com/bitcoin-core/meta/issues/19#issuecomment-2961177626
[cove github]: https://github.com/bitcoinppl/cove/releases
[liana github]: https://github.com/wizardsardine/liana/releases
[breez github]: https://github.com/breez/breez-sdk-liquid/releases/tag/0.9.0
[starkware tweet]: https://x.com/dimahledba/status/1935354385795592491
[starkware sv2]: https://github.com/keep-starknet-strange/stratum
[news337 delay]: /en/newsletters/2025/01/17/#eclair-2936
[news349 attributable]: /en/newsletters/2025/04/11/#ldk-2256
[news342 peer]:/en/newsletters/2025/02/21/#ldk-3575
