---
title: 'Bitcoin Optech Newsletter #298'
permalink: /en/newsletters/2024/04/17/
name: 2024-04-17-newsletter
slug: 2024-04-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an analysis of how a node with cluster
mempool behaved when tested with all transactions seen on the network in 2023.
Also included are our regular sections describing recent updates to
clients and services, announcing new releases and release candidates, and
summarizing notable changes to popular Bitcoin infrastructure software.

## News

- **What would have happened if cluster mempool had been deployed a year ago?**
  Suhas Daftuar [posted][daftuar cluster] to Delving Bitcoin that he
  recorded every transaction his node received in 2023 and has now run
  them through a development version of Bitcoin Core with [cluster
  mempool][topic cluster mempool] enabled to quantify differences
  between the existing version and the development version.  Some of his findings include:

  - *The cluster mempool node accepted 0.01% more transactions:* "In
    2023, [the baseline node's] ancestor/descendant limits caused over
    46k txs to be rejected at some point. [...] Only ~14k transactions
    were rejected due to a cluster size limit being hit."  About 10k
    of the transactions rejected by the cluster mempool node initially
    (70% of the rejected 14k) would have later been accepted if they
    were rebroadcast after some of their ancestors were confirmed, which
    is expected wallet behavior.

  - *RBF differences were negligible:* "The RBF rules enforced in the two
    simulations are different, but this turned out to produce a
    negligible effect on the aggregate acceptance numbers here."  See
    below for more details.

  - *Cluster mempool was just as good for miners as legacy transaction selection:*
    Daftuar noted that it is currently the case that nearly every
    transaction ends up in a block eventually, so both Bitcoin Core's
    current transaction selection and cluster mempool transaction
    selection would actually capture about the same amount in fees.
    However, in an analysis that Daftuar warns likely overstates
    results, cluster mempool captured more fees than legacy transaction
    selection about 73% of the time.  Legacy transaction selection was
    better about 8% of the time.  Daftuar concluded, "While it may be
    inconclusive as to whether cluster mempool is materially better than
    baseline based on network activity in 2023, it strikes me as very
    unlikely that cluster mempool is materially worse."

  Daftuar also considered the effect of cluster mempool on [RBF transaction
  replacement][topic rbf].  He starts with an excellent summary of the
  difference between Bitcoin Core's current RBF behavior and how RBF
  would work under cluster mempool (emphasis and links from original):

  > The cluster mempool RBF rules are centered around whether the
  > [feerate diagram of the mempool would improve][feerate diagram] after the replacement
  > takes place, while Bitcoin Core’s existing RBF rules are roughly
  > what is described in BIP125 and [documented here][rbf doc].
  >
  > Unlike BIP125, the proposed [cluster mempool] RBF rule is focused on
  > the _result_ of a replacement. A tx can be better in theory than in
  > practice: maybe it “should” be accepted based on a theoretical
  > understanding of what should be good for the mempool, but if the
  > resulting feerate diagram is worse for any reason (say, because the
  > linearization algorithm is not optimal), then we’ll reject the
  > replacement.

  We'll also repeat his conclusion from that section of the report,
  which we feel was well substantiated by the data and analysis he
  provided:

  > Overall, the RBF differences between cluster mempool and existing
  > policy were minimal. Where they differed, the proposed new RBF rules
  > were largely protecting the mempool against replacements which were
  > not incentive compatible---a good change. Yet it’s important to also
  > be aware that in theory, we could see replacements prevented that in
  > an ideal world would be accepted [now], because sometimes seemingly
  > good replacements can trigger suboptimal behavior, which was
  > previously undetected (by BIP125 policy) but would be detected and
  > prevented in the new rules.

  There were no replies to the post as of this writing. {% assign timestamp="0:42" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Phoenix for server announced:**
  Phoenix Wallet announced a simplified, headless Lightning node,
  [phoenixd][phoenixd github], focused on sending and receiving payments.
  phoenixd targets developers, is based on the existing Phoenix Wallet software,
  and automates channel, peer, and liquidity management. {% assign timestamp="19:26" %}

- **Mercury Layer adds Lightning swaps:**
  The Mercury Layer [statechain][topic statechains] uses [hold invoices][topic
  hold invoices] to enable swapping a statechain coin for a Lightning payment. {% assign timestamp="21:32" %}

- **Stratum V2 Reference Implementation v1.0.0 released:**
  The [v1.0.0 release][sri blog] "is a result of improvements in the Stratum V2
  specification through the working group collaboration and rigorous testing". {% assign timestamp="22:46" %}

- **Teleport Transactions update:**
  A fork of the [original Teleport Transactions][news192 tt] repository was
  [announced][tt tweet] along with several completed updates and improvements. {% assign timestamp="25:09" %}

- **Bitcoin Keeper v1.2.1 released:**
  The [v1.2.1 release][bitcoin keeper v.1.2.1] adds support for [taproot][topic
  taproot] wallets. {% assign timestamp="28:10" %}

- **BIP-329 label management software:**
  The version 2 release of [Labelbase][labelbase blog] includes a self-hosted
  option and [BIP329][] import/export capabilities among other features. {% assign timestamp="29:02" %}

- **Key agent Sigbash launches:**
  The [Sigbash][] signing service allows users to purchase an xpub for use
  in a multisig setup that will only [PSBT][topic psbt]-sign if certain
  user-specified conditions (hashrate, Bitcoin price, address balance, after a
  certain time) are met. {% assign timestamp="31:37" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 27.0][] is the release of the next major
  version of the network's predominant full node implementation.
  This new version deprecates libbitcoinconsensus (see Newsletters
  [#288][news288 libconsensus] and [#297][news297 libconsensus]),
  enables [v2 encrypted P2P transport][topic v2 p2p transport] by
  default (see [Newsletter #288][news288 v2 p2p]), allows the use of
  opt-in topologically restricted until confirmation ([TRUC][topic v3
  transaction relay]) transaction policy (also called _v3 transaction
  relay_) on test networks (see [Newsletter #289][news289 truc]), and
  adds a new [coin selection][topic coin selection] strategy to be used
  during high feerates (see [Newsletter #290][news290 coingrinder]).
  For a complete list of major changes, please see the [release
  notes][bcc27 rn]. {% assign timestamp="35:19" %}

- [BTCPay Server 1.13.1][] is the latest release of this
  self-hosted payment processor.  Since we last covered a BTCPay Server
  update in [Newsletter #262][news262 btcpay], they've made webhooks
  [more extensible][btcpay server #5421], added support for [BIP129][]
  multisig wallet import (see [Newsletter #281][news281 bip129]),
  improved plugin flexibility and begun migrating all altcoin support to
  plugins, and added support for BBQr-encoded [PSBTs][topic psbt] (see
  [Newsletter #295][news295 bbqr]), among numerous other new features
  and bug fixes. {% assign timestamp="41:50" %}

- [LDK 0.0.122][] is the latest release of this library for building
  LN-enabled applications; it follows the [0.0.121][ldk 0.0.121] release
  that fixes a denial-of-service vulnerability.  The latest release
  also fixes several bugs. {% assign timestamp="42:55" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [LDK #2704][] significantly updates and extends its documentation
  about its `ChannelManager` class.  The channel manager is "a lightning
  node's channel state machine and payment management logic, which
  facilitates sending, forwarding, and receiving payments through
  lightning channels." {% assign timestamp="44:40" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2704,5421" %}
[Bitcoin Core 27.0]: https://bitcoincore.org/bin/bitcoin-core-27.0/
[feerate diagram]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553/1
[rbf doc]: https://github.com/bitcoin/bitcoin/blob/0de63b8b46eff5cda85b4950062703324ba65a80/doc/policy/mempool-replacements.md
[daftuar cluster]: https://delvingbitcoin.org/t/research-into-the-effects-of-a-cluster-size-limited-mempool-in-2023/794
[bcc27 rn]: https://github.com/bitcoin/bitcoin/blob/c7567d9223a927a88173ff04eeb4f54a5c02b43d/doc/release-notes/release-notes-27.0.md
[news288 libconsensus]: /en/newsletters/2024/02/07/#bitcoin-core-29189
[news297 libconsensus]: /en/newsletters/2024/04/10/#bitcoin-core-29648
[news288 v2 p2p]: /en/newsletters/2024/02/07/#bitcoin-core-29347
[news289 truc]: /en/newsletters/2024/02/14/#bitcoin-core-28948
[news290 coingrinder]: /en/newsletters/2024/02/21/#bitcoin-core-27877
[news281 bip129]: /en/newsletters/2023/12/13/#btcpay-server-5389
[news295 bbqr]: /en/newsletters/2024/03/27/#btcpay-server-5852
[news262 btcpay]: /en/newsletters/2023/08/02/#btcpay-server-1-11-1
[ldk 0.0.122]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.122
[ldk 0.0.121]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.121
[btcpay server 1.13.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.13.1
[phoenixd github]: https://github.com/ACINQ/phoenixd
[sri blog]: https://stratumprotocol.org/blog/sri-1-0-0/
[news192 tt]: /en/newsletters/2022/03/23/#coinswap-implementation-teleport-transactions-announced
[tt tweet]: https://twitter.com/RajarshiMaitra/status/1768623072280809841
[bitcoin keeper v.1.2.1]: https://github.com/bithyve/bitcoin-keeper/releases/tag/v1.2.1
[labelbase blog]: https://labelbase.space/ann-v2/
[Sigbash]: https://sigbash.com/
