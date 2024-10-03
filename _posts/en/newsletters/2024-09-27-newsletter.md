---
title: 'Bitcoin Optech Newsletter #322'
permalink: /en/newsletters/2024/09/27/
name: 2024-09-27-newsletter
slug: 2024-09-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a fixed vulnerability affecting older
versions of Bitcoin Core, provides an update on hybrid channel jamming
mitigation, summarizes a paper about more efficient and private
client-side validation, and announces a proposal to update the BIP
process.  Also included are our regular sections summarizing top
questions and answers from the Bitcoin Stack Exchange, announcing new
releases and release candidates, and describing notable changes to
popular Bitcoin infrastructure software.

## News

- **Disclosure of vulnerability affecting Bitcoin Core versions before 24.0.1:**
  Antoine Poinsot [posted][poinsot headers] to the Bitcoin-Dev mailing
  list a link to the announcement of a vulnerability affecting
  versions of Bitcoin Core that have been past their end of life since
  at least December 2023. This follows previous disclosures of older
  vulnerabilities (see Newsletters [#310][news310 bcc] and
  [#314][news314 bcc]).

  The new disclosure discusses a long-known method for crashing Bitcoin
  Core full nodes: sending them long chains of block headers that will
  be stored in memory.  Each block header is 80 bytes and, if there were
  no protections, could be created at the protocol minimum
  difficulty---allowing an attacker with modern ASIC mining to produce
  millions per second.  Bitcoin Core has had protection for many years
  as a side effect of the checkpoints added in an early version: these
  prevented an attacker from being able to create the initial blocks in
  a chain of headers at minimum difficulty, forcing them to perform
  significant proof of work that they could instead be paid for if they
  created valid blocks.

  However, the last checkpoint was added over 10 years ago <!-- 15 Jul 2014 --> and
  Bitcoin Core developers have been reluctant to add new checkpoints, as
  doing so gives the mistaken impression that transaction finality is
  ultimately dependent on developers creating checkpoints.  As mining
  equipment has improved and the amount of network hashrate increased,
  the cost to create a fake chain of headers has decreased.  As the cost
  decreased, researchers David Jaenson and Braydon Fuller independently
  [responsibly disclosed][topic responsible disclosures] the attack to
  Bitcoin Core developers.  Developers replied that the issue was known to them
  and encouraged Fuller to publicly [post][fuller dos] his
  [paper][fuller paper] about it in 2019.

  In 2022, the cost of the attack having decreased further, a group of
  developers began working on a solution that did not use checkpoints.
  Bitcoin Core PR #25717 (see [Newsletter #216][news216 checkpoints])
  was the result of that work.  Later, Niklas Gögge discovered a bug in
  #25717's logic and opened [PR #26355][bitcoin core #26355] to fix it.
  Both PRs were merged and Bitcoin Core 24.0.1 was released with the
  fix. {% assign timestamp="2:01" %}

- **Hybrid jamming mitigation testing and changes:** Carla Kirk-Cohen
  [posted][kc jam] to Delving Bitcoin details about various attempts to
  defeat an implementation of the mitigation for [channel jamming
  attacks][topic channel jamming attacks] originally proposed by Clara
  Shikhelman and Sergei Tikhomirov.  Hybrid jamming mitigation involves
  a combination of [HTLC endorsement][topic htlc endorsement] and a
  small _upfront fee_ that is paid unconditionally whether a payment
  succeeds or fails.

  Several developers were invited to attempt to [jam a channel for an
  hour][kc attackathon], with Kirk-Cohen and Shikhelman expanding on any
  attacks that seemed promising.  Most of the attacks were failures:
  either the attacker spent more to use the attack than another known
  attack, or the target node earned more in income during the attack
  than it would've earned through normal forwarding traffic on the
  simulated network.

  One attack was successful: a [sink attack][] that "aims to decrease the
  reputation of a targeted node’s peers by creating shorter/cheaper
  paths in the network, and sabotaging payments forwarded through its
  channels to decrease the reputation of all the nodes preceding it in
  the route."  To address the attack, Kirk-Cohen and Shikhelman
  introduced [bidirectional reputation][] to the way HTLC endorsement is
  considered.  When Bob receives a payment from Alice to be forwarded to
  Carol, e.g. `A -> B -> C`, Bob considers both whether Alice tends to
  forward HTLCs that are quickly settled (as with HTLC endorsement
  previously) and whether Carol tends to accept HTLCs that are quickly
  settled (this is new).  Now when Bob receives an endorsed HTLC from
  Alice:

  - If Bob thinks both Alice and Carol are reliable, he'll forward and
    endorse the HTLC from Alice to Carol.

  - If Bob thinks only Alice is reliable, he won't forward an endorsed
    HTLC from Alice.  He'll immediately reject it, allowing the failure
    to propagate back to the original spender, who can quickly resend
    using a different route.

  - If Bob thinks only Carol is reliable, he'll accept an endorsed HTLC
    from Alice when he has extra capacity, but he won't endorse it when
    forwarding it to Carol.

  Given the change to the proposal, Kirk-Cohen and Shikhelman are
  planning additional experiments to ensure it works as expected.  They
  also additionally link to a [mailing list post][posen bidir] by Jim
  Posen from May 2018 that describes a bidirectional reputation system
  to prevent jamming attacks (then called _loop attacks_), an example of
  earlier parallel thinking about solving this problem. {% assign timestamp="17:51" %}

- **Shielded client-side validation (CSV):** Jonas Nick, Liam Eagen, and
  Robin Linus [posted][nel post] to the Bitcoin-Dev mailing list a
  [paper][nel paper] about a new [client-side validation][topic
  client-side validation] protocol.  Client-side validation allows the
  transfer of tokens to be protected by Bitcoin's proof-of-work without
  publicly revealing any information about those tokens or transfers.
  Client-side validation is a key component of protocols such as
  [RGB][topic client-side validation] and [Taproot Assets][topic
  client-side validation].

  One downside of existing protocols is that the amount of data that
  needs to be validated by a client when receiving a token is, in the
  worst case, as large as the history of every transfer of that token
  and every related token.  In other words, for a set of tokens as
  frequently exchanged as bitcoins, a client would need to validate a
  history roughly as large as the entire Bitcoin blockchain.  In
  addition to the bandwidth cost of transferring that data and the CPU
  cost of validating it, transferring the full history weakens the
  privacy of previous receivers of the token.  By comparison, Shielded
  CSV uses zero-knowledge proofs to allow verification with a fixed
  amount of resources and without revealing previous transfers.

  Another downside of existing protocols is that each transfer of a
  token requires including data in a Bitcoin transaction.  Shielded
  CSV allows multiple transfers to be combined together into the same
  64-byte update.  This can allow thousands of token transfers to be
  confirmed each time a new Bitcoin block is found by confirming only a
  single Bitcoin transaction with an extra 64-byte data push.

  The paper goes into details.  We found particularly interesting the
  idea of trustlessly bridging bitcoin from the main blockchain to a
  Shielded CSV (and back) without consensus changes by using [BitVM][topic
  acc], the use of accounts (section 2), the discussion about the effect
  of blockchain reorganization on accounts and transfers (also section
  2), the related discussion about depending on unconfirmed transactions
  (section 5.2), and the list of possible extensions (appendix A). {% assign timestamp="25:28" %}

- **Draft of updated BIP process:** Mark "Murch" Erhardt
  [posted][erhardt post] to the Bitcoin-Dev mailing list to announce
  the availability of a [pull request][erhardt pr] for a draft BIP that
  describes an updated process for the BIP repository.  Anyone
  interested is encouraged to review the draft and leave comments.  If
  the community finds the final version of the draft acceptable, it will
  become the process used by the BIP editors. {% assign timestamp="48:47" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What specific verifications are done on a fresh Bitcoin TX and in what order?]({{bse}}124221)
  Murch enumerates the validity checks done by Bitcoin Core on a new transaction
  when it is submitted to the mempool, including checks done in the
  `CheckTransaction`, `PreChecks`, `AcceptSingleTransaction`, and related
  functions. {% assign timestamp="54:31" %}

- [Why is my bitcoin directory larger than my pruning data limit setting?]({{bse}}124197)
  Pieter Wuille notes that while the `prune` option limits the size of Bitcoin
  Core's blockchain data, the chainstate, indexes, mempool backup, wallet files,
  and other files are not subject to the `prune` limit and can grow in size
  independently. {% assign timestamp="55:42" %}

- [What do I need to have set up to have `getblocktemplate` work?]({{bse}}124142)
  User CoinZwischenzug also asks a [related question]({{bse}}124160) about how
  to calculate the merkle root and coinbase transaction for a block. Answers to
  both questions (from Vojtěch Strnad, RedGrittyBrick, and Pieter Wuille)
  similarly indicate that while Bitcoin Core's `getblocktemplate` can build
  candidate blocks of transactions and block header information, when mining on
  non-test networks, coinbase transactions are created by mining or [mining
  pool][topic pooled mining] software. {% assign timestamp="58:19" %}

- [Can a silent payment address body be brute forced?]({{bse}}124207)
  Josie, referencing [BIP352][], outlines the steps to derive a [silent
  payment][topic silent payments] address, concluding that it is infeasible to
  use brute force techniques to compromise silent payment's privacy benefits. {% assign timestamp="1:00:02" %}

- [Why does a tx fail `testmempoolaccept` BIP125 replacement but is accepted by `submitpackage`?]({{bse}}124269)
  Ava Chow points out that `testmempoolaccept` only evaluates transactions
  individually and, as a result, the [RBF][topic rbf] example from the Bitcoin
  Core 28.0 [testing guide][bcc testing rbf] indicates a rejection. However,
  since [`submitpackage`][news272 submitpackage] evaluates both the parent and
  child example transactions together as a [package][topic package relay], both
  parent and child are accepted. {% assign timestamp="1:01:38" %}

- [How does the ban score algorithm calculate a ban score for a peer?]({{bse}}117227)
  Brunoerg references [Bitcoin Core #29575][new309 ban score] which adjusted peer
  misbehavior scoring for certain behaviors, that he went on to list. {% assign timestamp="1:03:53" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 1.0.0-beta.4][] is a release candidate of this library for
  building wallets and other Bitcoin-enabled applications.  The original
  `bdk` Rust crate has been renamed to `bdk_wallet`, and lower layer
  modules have been extracted into their own crates, including
  `bdk_chain`, `bdk_electrum`, `bdk_esplora`, and `bdk_bitcoind_rpc`.
  The `bdk_wallet` crate "is the first version to offer a stable 1.0.0 API." {% assign timestamp="1:06:41" %}

- [Bitcoin Core 28.0rc2][] is a release candidate for the next major
  version of the predominant full node implementation.  A [testing
  guide][bcc testing] is available. {% assign timestamp="1:06:57" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Eclair #2909][] adds a `privateChannelIds` parameter to the `createinvoice`
  RPC command to add [private channel][topic unannounced channels] pathfinding
  hints to BOLT11 invoices. This fixes a bug that prevented nodes with only
  private channels from receiving payments. To avoid leaking the channel
  outpoint, `scid_alias` should be used. {% assign timestamp="1:10:15" %}

- [LND #9095][] and [LND #9072][] introduce changes to the invoice [HTLC][topic
  htlc] modifier, auxiliary channel funding and closing, and integrate custom
  data into the RPC/CLI as part of the custom channels initiative to enhance
  LND's support for [taproot assets][topic client-side validation]. This
  PR allows custom asset-specific data to be included in RPC commands and
  supports auxiliary channel management via the command line interface. {% assign timestamp="1:11:12" %}

- [LND #8044][] adds new message types `announcement_signatures_2`,
  `channel_announcement_2` and `channel_update_2` for the new v1.75
  gossip protocol (see [Newsletter #261][news261 v1.75]) that allows
  nodes to [announce][topic channel announcements] and verify [taproot
  channels][topic simple
  taproot channels]. In addition, some modifications are made to existing
  messages such as `channel_ready` and `gossip_timestamp_range` to improve the
  efficiency and security of gossiping with taproot channels. {% assign timestamp="1:11:55" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26355,2909,9095,9072,8044" %}
[BDK 1.0.0-beta.4]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.4
[bitcoin core 28.0rc2]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news216 checkpoints]: /en/newsletters/2022/09/07/#bitcoin-core-25717
[poinsot headers]: https://mailing-list.bitcoindevs.xyz/bitcoindev/WhFGS_EOQtdGWTKD1oqSujp1GW-v_ZUJemlNePPGaGBgzpmu6ThpqLwJpUVei85OiMu_xxjEzt_SeOWY7547C72BVISLENOd_qrdCwPajgk=@protonmail.com/
[fuller dos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017354.html
[fuller paper]: https://bcoin.io/papers/bitcoin-chain-expansion.pdf
[posen bidir]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-May/001232.html
[erhardt post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/82a37738-a17b-4a8c-9651-9e241118a363@murch.one/
[erhardt pr]: https://github.com/murchandamus/bips/pull/2
[news310 bcc]: /en/newsletters/2024/07/05/#disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-before-0-21-0
[news314 bcc]: /en/newsletters/2024/08/02/#disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-before-22-0
[kc jam]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147/
[kc attackathon]: https://github.com/carlaKC/attackathon
[sink attack]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[bidirectional reputation]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-bidirectional-reputation-10
[nel post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b0afc5f2-4dcc-469d-b952-03eeac6e7d1b@gmail.com/
[nel paper]: https://github.com/ShieldedCSV/ShieldedCSV/releases/latest/download/shieldedcsv.pdf
[news261 v1.75]: /en/newsletters/2023/07/26/#updated-channel-announcements
[bcc testing rbf]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide#3-package-rbf
[news272 submitpackage]: /en/newsletters/2023/10/11/#bitcoin-core-27609
[new309 ban score]: /en/newsletters/2024/06/28/#bitcoin-core-29575
