---
title: "Bitcoin Optech Newsletter #20"
permalink: /en/newsletters/2018/11/06/
name: 2018-11-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter contains a security notice about the C
implementation of bech32 address decoding, an analysis of a temporary
reduction in the number of segwit blocks, a link to an interesting
discussion about future features for LN payments, and a few notable code
changes in popular Bitcoin infrastructure projects.

## Action items

- **Bech32 security update for C implementation:** if you use the
  [reference implementation][bech32 c] of bech32 address decoding for
  the C programming language, you need to [update][bech32 patch] to fix
  a potential overflow bug.  Other reference implementations are
  unaffected; see the News section below for details.

## News

- **Temporary reduction in segwit block production:** Optech
  investigated reports that a mining pool had stopped producing blocks
  that included segwit transactions.  We found that the number of segwit
  blocks decreased suddenly around October 20th and began rebounding
  towards normal a few days ago.

    ![Percentage of blocks including segwit transactions, last several weeks](/img/posts/segwit-blocks-2018-11.png)

    A simple explanation for this sudden decrease and rebound could be a
    minor misconfiguration.  By default, Bitcoin Core does not produce
    segwit-including blocks in order to maintain [getblocktemplate][rpc
    getblocktemplate] (GBT) compatibility with older pre-segwit mining
    software.  When miners change their software or configuration, it's
    easily possible to forget to pass the extra flag to enable segwit.
    To illustrate how easy it is to make this mistake, the example below
    calls GBT with its default parameter and its segwit parameter---and
    then compares the results by the total potential block reward
    (subsidy + fees) each block template could earn.

    ```bash
    $ ## GBT with default parameters
    $ bitcoin-cli getblocktemplate | jq '.coinbasevalue / 1e8'
    12.54348709

    $ ## GBT with segwit enabled
    $ bitcoin-cli getblocktemplate '{"rules": ["segwit"]}' | jq '.coinbasevalue / 1e8'
    12.56368175
    ```

    As you can see, a miner who enabled segwit would've earned more
    income than a non-segwit miner if one of those example block
    templates had been mined.  Although a small difference in absolute
    terms  due to currently almost-empty mempools (about 0.02 BTC or
    $100 USD), in relative terms the segwit-including example block
    template receives almost 50% more fee income than the legacy-only
    template.  As mining is expected to be a commodity service with thin
    profit margins, this seems to be enough of an incentive to get miners to
    create segwit-including blocks---and it will only become more
    important in the future as more users switch to using segwit, the
    block subsidy decreases, and perhaps fees increase.

    [Bitcoin Core 0.17.0.1][] updated bitcoind's built-in documentation
    for GBT to mention the need to enable segwit, and it has been proposed
    in developer discussion to enable segwit GBT by default in some
    future version (but still provide a backwards-compatible option to
    disable it).

- **Overflow bug in reference C-language bech32 implementation:** Trezor
  [publicly disclosed][bech32 overflow blog] a bug they discovered in
  the [reference implementation][bech32 c] of the bech32 address
  function for the C programming language.  A [patch][bech32 patch] has
  been released fixing the bug.  The bug does not affect users of the
  other [reference implementations][bech32 refs] written in other
  programming languages ([source][achow bech32]).

    As Trezor responsibly disclosed the bug to multiple other projects,
    they learned from Ledger about an additional bug in the
    [trezor-crypto][] library for Bitcoin Cash-style addresses that use
    the same basic structure as Bitcoin bech32 addresses.  A
    [patch][cashaddr patch] for that has also been released.

- **Discussion about improving Lightning payments:** in advance of an
  upcoming meeting between LN protocol developers, Rusty Russell started
  a [discussion][ln bolt11 ss] about two problems he thinks could
  potentially be solved using scriptless scripts as described in
  [Newsletter #16][].

    1. An invoice can only be paid a maximum of one time.  It'd be nice
       for multiple people to be able to pay the same invoice, such as a
       static donation invoice or a monthly recurrent payment.

    2. The protocol doesn't provide proof of payment by a particular spender.  You can prove that
       a particular invoice was paid, and that invoice could commit to
       the identity of the person who was supposed to pay it, but both
       the spender and the nodes who help route the payment to the
       recipient all have the same data about the payment, so any one of
       them could claim to have sent the payment themselves.

## Optech recommends

If you're looking for more news about Lightning, check out Rene
Pickhardt's new weekly collection of the best tweets about LN and what
people are building with it.  Follow [@renepickhardt][] on Twitter to
get the latest news and check out the previously published issues:
[1][lwil41], [2][lwil42], and [3][lwil43].

## Notable code changes

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], [C-lightning][cl commits], and [libsecp256k1][secp
commits].*

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="f1e2f2a85962c1664e4e55471061af0eaa798d40"
  end="742ee213499194f97e59dae4971f1474ae7d57ad"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="e5b84cfadab56037ae3957e704b3e570c9368297"
  end="6b19df162a161079ab794162b45e8f4c7bb8beec"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="22b8a88b488faa94a009b2c58415ae825152f709"
  end="d5bb536ef0c08a813f767b3fb016eb20292de4dd"
%}
{% include linkers/github-log.md
  refname="secp commits"
  repo="bitcoin-core/secp256k1"
  start="1086fda4c1975d0cad8d3cad96794a64ec12dca4"
  end="1086fda4c1975d0cad8d3cad96794a64ec12dca4"
%}

- [Bitcoin Core #14454][] adds support to the [importmulti][rpc
  importmulti] RPC for segwit addresses and scripts (P2WPKH, P2WSH, and
  P2SH-wrapped segwit).  A new `witnessscript` parameter fulfills the
  same role for segwit as the `redeemscript` parameter for P2SH.  Also a
  `solvable` parameter is added to the [getaddressinfo][rpc
  getaddressinfo] RPC to let the user know whether the wallet knows the
  redeemScript or witnessScript for a P2SH or P2WSH address, i.e.
  whether it knows how to create an unsigned input for spending payments
  sent to that address.

- [LND #2027][] adds a configuration option that allows a node to reject
  new channels being opened with an initial "push" of funds.  This
  eliminates an occasional problem merchants are seeing where
  inexperienced users receive a [BOLT11][] invoice for some amount of
  money, realize they don't have a channel open, and so manually open a
  channel with an initial payment for the invoiced amount.  This
  manually-issued payment is not associated with the unique invoice, so
  the user doesn't receive the product or service they attempted to
  purchase and the merchant needs to manually issue a refund (if they
  can).  Merchants who enable the new configuration option provided by
  this PR will be able to automatically prevent users from making this
  mistake.

- [C-Lightning #2061][] fixes the overflow bug in bech32 decoding as
  described in the *News* section.

{% include references.md %}
{% include linkers/issues.md issues="14454,2027,2061" %}

[achow bech32]: https://twitter.com/achow101/status/1058370040368644097
[@renepickhardt]: https://twitter.com/renepickhardt
[lwil41]: https://twitter.com/i/moments/1051149970026442753
[lwil42]: https://twitter.com/i/moments/1051399582662443009
[lwil43]: https://twitter.com/i/moments/1055475460816228354

[bech32 c]: https://github.com/sipa/bech32/tree/master/ref/c
[bech32 patch]: https://github.com/sipa/bech32/commit/2b0aac650ce560fb2b2a2bebeacaa5c87d7e5938
[Bitcoin Core 0.17.0.1]: https://bitcoincore.org/en/releases/0.17.0.1/
[bech32 overflow blog]: https://blog.trezor.io/details-about-the-security-updates-in-trezor-one-firmware-1-7-1-5c34278425d8
[bech32 refs]: //github.com/sipa/bech32/tree/master/ref/
[trezor-crypto]: https://github.com/trezor/trezor-crypto/
[cashaddr patch]: https://github.com/trezor/trezor-crypto/commit/2bbbc3e15573294c6dd0273d2a8542ba42507eb0
[ln bolt11 ss]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001489.html
