---
title: 'Bitcoin Optech Newsletter #281'
permalink: /en/newsletters/2023/12/13/
name: 2023-12-13-newsletter
slug: 2023-12-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about griefing liquidity
advertisements and includes our regular sections describing changes to
services and client software, summarizing popular questions and answers
of the Bitcoin Stack Exchange, announcing new software releases and
release candidates, and examining recent changes to popular Bitcoin
infrastructure software.

## News

- **Discussion about griefing liquidity ads:** Bastien Teinturier
  [posted][teinturier liqad] to the Lightning-Dev mailing list about a
  potential problem with timelocks on [dual-funded channels][topic dual
  funding] created from [liquidity advertisements][topic liquidity
  advertisements].  This was also previously mentioned in [Recap
  #279][recap279 liqad]. For example, Alice advertises that, for a fee, she's
  willing to commit 10,000 sats of her funds to a channel for 28 days.
  The 28-day timelock prevents Alice from simply closing the channel
  after she receives payment and using her funds for something else.

  Continuing the example, Bob opens the channel with an additional
  contribution of 100,000,000 sats (1 BTC) of his funds.  He then
  sends almost all of his funds through the channel.  Now Alice's
  balance in the channel isn't the 10,000 sats she received a fee
  for---it's almost 10,000 times higher than that amount.  If Bob is
  malicious, he won't allow those funds to move again until the
  expiration of the 28-day timelock to which Alice committed.

  A mitigation suggested by Teinturier and discussed by him and others
  was to only apply the timelock to the liquidity contribution
  (e.g., only Alice's 10,000 sats).  This introduces
  complexities and inefficiencies, although it may solve the problem.
  An alternative that Teinturier proposed was simply dropping the
  timelock (or making it optional) and letting liquidity buyers take
  the risk that providers may close channels shortly after receiving
  their liquidity fees.  If channels opened through liquidity ads
  typically generate significant forwarding fee income, there would be
  an incentive to keep channels open. {% assign timestamp="0:46" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Stratum v2 mining pool launches:**
  [DEMAND][demand website] is a mining pool built off of the [Stratum v2
  reference implementation][news247 sri] initially allowing for solo mining, with
  pooled mining planned for the future. {% assign timestamp="15:43" %}

- **Bitcoin network simulation tool warnet announced:**
  The [warnet software][warnet github] allows for specifying node topologies,
  running [scripted scenarios][warnet scenarios] across that network, and
  [monitoring][warnet monitoring] and analyzing resulting behaviors. {% assign timestamp="16:31" %}

- **Payjoin client for Bitcoin Core released:**
  The [payjoin-cli][] is a rust project that adds command line [payjoin][topic payjoin] sending
  and receiving capabilities for Bitcoin Core. {% assign timestamp="17:30" %}

- **Call for community block arrival timestamps:**
  A contributor to the [Bitcoin Block Arrival Time Dataset][block arrival github]
  repository [called][b10c tweet] for node operators to submit their block arrival
  timestamps for research. There is a similar repository for collecting [stale
  block data][stale block github]. {% assign timestamp="18:44" %}

- **Envoy 1.4 released:**
  Bitcoin wallet Envoy’s [1.4 release][envoy v1.4.0] adds [coin control][topic
  coin selection] and [wallet labeling][topic wallet labels] ([BIP329][]
  coming soon), among other features. {% assign timestamp="21:41" %}

- **BBQr encoding scheme announced:**
  The [scheme][bbqr github] can efficiently encode larger files, for example [PSBTs][topic
  psbt], into an animated QR series for use in air-gapped wallet configurations. {% assign timestamp="22:09" %}

- **Zeus v0.8.0 released:**
  The [v0.8.0][zeus v0.8.0] release contains an embedded LND node, additional
  [zero conf channel][topic zero-conf channels] support, and support for simple taproot channels,
  among other changes. {% assign timestamp="22:45" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What are all the rules related to CPFP fee bumping?]({{bse}}120853)
  Pieter Wuille points out that contrary to the [RBF][topic rbf] fee bumping
  technique that has a list of associated policy rules, the [CPFP][topic cpfp]
  fee bumping technique has no additional policy rules. {% assign timestamp="25:16" %}

- [How is the total number of RBF replaced transactions calculated?]({{bse}}120823)
  Murch and Pieter Wuille walk through some examples of RBF replacements in the
  context of [BIP125][]’s rule 5: “The number of original transactions to be
  replaced and their descendant transactions which will be evicted from the
  mempool must not exceed a total of 100 transactions”. Readers may also be
  interested in the [Add BIP-125 rule 5 testcase with default
  mempool][review club 25228] PR Review Club meeting. {% assign timestamp="29:41" %}

- [What types of RBF exist and which one does Bitcoin Core support and use by default?]({{bse}}120749)
  Murch provides some of Bitcoin Core’s transaction replacement history and in a
  [related question]({{bse}}120773), a summary of RBF replacement rules and
  links to Bitcoin Core’s [Mempool Replacements][bitcoin core mempool
  replacements] documentation and one developer's ideas for [RBF
  improvements][glozow rbf improvements]. {% assign timestamp="31:37" %}

- [What is the Block 1,983,702 Problem?]({{bse}}120834)
  Antoine Poinsot gives an overview of the issues that led to [BIP30][]
  restricting duplicate txids and [BIP34][] mandating the inclusion of the
  current block height in the coinbase field. He then points out that there are
  numerous blocks whose random coinbase field content happens to match the
  mandatory height prefix of a later block. Block 1,983,702 being the first
  for which it would be practically possible to repeat the coinbase transaction
  of the prior block. In a [related question]({{bse}}120836), Murch and
  Antoine Poinsot evaluate that possibility in greater detail.  See also
  [Newsletter #182][news182 block1983702]. {% assign timestamp="34:48" %}

- [What are hash functions used for in bitcoin?]({{bse}}120418)
  Pieter Wuille lists over thirty different instances across consensus rules,
  peer-to-peer protocol, wallet and node implementation details that make use
  of no less than 10 different hash functions. {% assign timestamp="45:12" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.17.3-beta][] is a release that contains several bug fixes,
  including a reduction in memory when used with the Bitcoin Core
  backend. {% assign timestamp="51:59" %}

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LDK #2685][] adds the ability to obtain block chain data from an
  Electrum-style server. {% assign timestamp="52:22" %}

- [Libsecp256k1 #1446][] removes some x86_64 assembly code from the
  project, switching to using existing C language code that has always
  been used for other platforms.  The assembly code was human-optimized
  several years ago to improve performance but, in the meantime, compilers
  improved and recent versions of both GCC and LLVM (clang) now produce
  even more performant code. {% assign timestamp="53:04" %}

- [BTCPay Server #5389][] adds support for [BIP129][] secure multisig
  wallet setup (see [Newsletter #136][news136 bip129]).  This allows
  BTCPay server to interact with multiple software wallets and hardware
  signing devices as part of a simple coordinated multisig setup
  procedure. {% assign timestamp="53:36" %}

- [BTCPay Server #5490][] begins using [fee estimates][ms fee api] from
  [mempool.space][] by default, with a fallback on fee estimates from
  the local Bitcoin Core node.  Developers commenting on the PR noted
  that they felt Bitcoin Core's fee estimates fail to respond quickly to
  changes in the local mempool.  For previous related discussion about
  the challenges to improving fee estimation accuracy, see [Bitcoin Core
  #27995][]. {% assign timestamp="59:54" %}

## Happy holidays!

This is Bitcoin Optech's final regular newsletter of the year.  On
Wednesday, December 20th, we'll publish our sixth annual year-in-review
newsletter.  Regular publication will resume on Wednesday, January 3rd.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2685,5389,5490,1446,27995" %}
[LND 0.17.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.3-beta
[teinturier liqad]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004227.html
[ms fee api]: https://mempool.space/docs/api/rest#get-recommended-fees
[mempool.space]: https://mempool.space/
[news136 bip129]: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[recap279 liqad]: /en/podcast/2023/11/30/#update-to-the-liquidity-ads-specification-transcript
[news182 block1983702]: /en/newsletters/2022/01/12/#bitcoin-core-23882
[demand website]: https://dmnd.work/
[news247 sri]: /en/newsletters/2023/04/19/#stratum-v2-reference-implementation-update-announced
[warnet github]: https://github.com/bitcoin-dev-project/warnet
[warnet scenarios]: https://github.com/bitcoin-dev-project/warnet/blob/main/docs/scenarios.md
[warnet monitoring]: https://github.com/bitcoin-dev-project/warnet/blob/main/docs/monitoring.md
[payjoin-cli]: https://github.com/payjoin/rust-payjoin/tree/master/payjoin-cli
[block arrival github]: https://github.com/bitcoin-data/block-arrival-times
[b10c tweet]: https://twitter.com/0xb10c/status/1732826609260872161
[stale block github]: https://github.com/bitcoin-data/stale-blocks
[envoy v1.4.0]: https://github.com/Foundation-Devices/envoy/releases/tag/v1.4.0
[bbqr github]: https://github.com/coinkite/BBQr
[zeus v0.8.0]: https://github.com/ZeusLN/zeus/releases/tag/v0.8.0
[review club 25228]: https://bitcoincore.reviews/25228
[bitcoin core mempool replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md
[glozow rbf improvements]: https://gist.github.com/glozow/25d9662c52453bd08b4b4b1d3783b9ff
