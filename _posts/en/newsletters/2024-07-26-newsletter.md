---
title: 'Bitcoin Optech Newsletter #313'
permalink: /en/newsletters/2024/07/26/
name: 2024-07-26-newsletter
slug: 2024-07-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a wide-ranging discussion about free
relay and fee-bumping upgrades in Bitcoin Core.  Also included are our
regular sections sharing popular questions and answers from the Bitcoin
Stack Exchange, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.

## News

- **Varied discussion of free relay and fee bumping upgrades:** Peter
  Todd [posted][todd fr-rbf] to the Bitcoin-Dev mailing list a summary
  of a free relay attack that he previously [responsibly
  disclosed][topic responsible disclosures] to Bitcoin Core developers.
  This led to an entangled discussion of multiple issues and proposed
  improvements.  Some of the topics discussed included:

  - *Free relay attacks:* [free relay][topic free relay] occurs when a
    full node relays unconfirmed transactions without the amount of
    fee revenue in its mempool increasing by at least
    the minimum relay rate (by default, 1 sat/vbyte).  Free relay often
    costs some money, so it's not technically free, but the
    cost is far below what honest users pay for relay.

    Free relay allows an attacker to greatly increase the
    bandwidth used by relaying full nodes, which may reduce the number
    of relay nodes.  If the number of independently operated relay nodes
    drops too low, spenders are essentially sending transactions
    directly to miners, which has the same centralization risks as
    [out-of-band fees][topic out-of-band fees].

    Todd's described attack exploits differences in mempool policy
    between miners and users.  Many miners appear to enable
    [full-RBF][topic rbf] but Bitcoin Core does not enable it by default
    (see [Newsletter #263][news263 full-rbf]).  This allows an attacker
    to craft different versions of a transaction which will be treated
    differently by full-RBF miners and non-full-RBF relay nodes.  Relay
    nodes can end up relaying multiple versions of a transaction that
    have minimal chance of confirming, wasting the bandwidth of the
    relaying nodes.

    Free relay attacks do not directly allow attackers to steal other
    users' funds, although a sudden or prolonged attack may be used to
    disrupt the network and make other types of attacks easier.  To the
    best of our knowledge, no disruptive free relay attack has ever been
    performed.

  - *Free relay and replace-by-feerate:* Peter Todd has previously
    proposed two forms of replace-by-feerate (RBFR); see [Newsletter
    #288][news288 rbfr].  One criticism of RBFR was that it enabled free
    relay.  A similar amount of free relay is already possible through
    the attack he described this week and similar attacks, so he
    argued that concerns about free relay should not block adding a
    feature useful for mitigating [transaction pinning attacks][topic
    transaction pinning].

    One [reply][harding rbfr fundamental] argued that free
    relay created by RBFR was fundamental to its design, but other free
    relay problems in the design of Bitcoin Core might be solvable.
    Todd [disagreed][todd unsolvable].

  - *TRUC utility:* Peter Todd argued that [TRUC][topic v3 transaction
    relay] was a "bad proposal".  He previously criticized the protocol
    (see [Newsletter #283][news283 truc pin]) and specifically criticized
    the specification of TRUC, [BIP431][], which uses concerns about
    free relay to advocate for TRUC over his own RBFR proposal.

    However, BIP431 also argues against versions of RBFR, such as
    Todd's one-shot RBFR, that depend on the replacement paying a high
    enough feerate that it becomes one of the most profitable
    transactions to mine in the next few blocks, described as entering
    the top part of the mempool.  Both Todd and others agreed that
    would be much easier to do once Bitcoin Core begins using [cluster
    mempool][topic cluster mempool], although Todd also suggested
    alternative methods that are available now.  TRUC does not need
    information about the top part of the mempool, so it does not depend
    on cluster mempool or alternatives.

    A longer form of this criticism was summarized in [Newsletter
    #288][news288 rbfr], with subsequent research (summarized in
    [Newsletter #290][news290 rbf]) illustrating how difficult it is for
    any set of transaction replacement rules to always make a choice
    that will improve miner profitability.  Compared to RBFR,
    TRUC does not change Bitcoin Core's replacement rules (except to
    always allow replacements to be considered for TRUC transactions),
    so it should not make any existing problems with replacement
    incentive compatibility worse.

  - *Path to cluster mempool:* as described in [Newsletter #285][news285
    cluster cpfp-co], the [cluster mempool][topic cluster mempool]
    proposal requires disabling [CPFP carve-out][topic cpfp carve out]
    (CPFP-CO), which is currently used by LN [anchor outputs][topic
    anchor outputs] to protect a large amount of money in payment
    channels.  In combination with [package relay][topic package relay]
    (specifically package replace by fee), one-shot RBFR may be able to
    replace CPFP-CO without requiring changes to any LN software that
    already repeatedly RBF fee bumps its anchor output spends.  However,
    one-shot RBFR depends on learning top-mempool feerates from
    something like cluster mempool, so both RBFR and cluster mempool
    would need to be deployed simultaneously or an alternative method
    for determining top-mempool feerates would need to be used.

    By comparison, TRUC also provides an alternative to CPFP-CO, but it
    is an opt-in feature.  All LN software would need to upgrade to
    support TRUC and all existing channels would need to undergo a
    [channel commitment upgrade][topic channel commitment upgrades].
    That could take a significant amount of time and CPFP-CO couldn't be
    disabled until there was strong evidence that all LN users had
    upgraded.  Until CPFP-CO was disabled, cluster mempool could not
    safely be widely deployed.

    As mentioned in previous Optech newsletters [#286][news286 imbued],
    [#287][news287 sibling], and [#289][news289 imbued], a slow adoption
    of TRUC and fast availability of cluster mempool could be addressed
    through _imbued TRUC_, which would automatically apply TRUC and
    [sibling eviction][topic kindred rbf] to anchors-style LN commitment
    transactions.  Several LN developers and contributors to the imbued
    TRUC proposal [said][teinurier hacky] that they would
    [prefer][daftuar prefer not] to avoid that outcome---explicitly
    upgrading to TRUC is better in many ways, and there are multiple
    other reasons for LN developers to work on channel upgrade
    mechanisms---but it seems plausible that imbued TRUC may be
    considered again if cluster mempool development outpaces the
    development of LN commitment upgrades.

    Although both imbued TRUC and widespread adoption of opt-in TRUC
    allow disabling CPFP-CO and thus make it possible to deploy cluster
    mempool, neither TRUC system depends on cluster mempool or other new
    methods of calculating transaction incentive compatibility.  This
    makes it easier to analyze TRUC independently of cluster mempool
    than it is to analyze RBFR.

  As of this writing, discussion on the mailing list is ongoing.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 1.0.0-beta.1][] is a release candidate for "the beta first version of
  `bdk_wallet` with a stable 1.0.0 API".

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

- [Bitcoin Core #30320][] assumeutxo: Don't load a snapshot if it's not in the best header chain

- [Bitcoin Core #29523][] Wallet:  Add `max_tx_weight` to transaction funding options (take 2)

- [Core Lightning #7461][]
    - offers: add self-fetchinvoices for offers, and self-pay for the resulting invoice. <!-- maybe related to https://bitcoinops.org/en/newsletters/2023/08/02/#core-lightning-6399 -->
    - plugins/offers: create blinded path if necessary.
    - plugin/pay: Handle paying to blinded path starting with us.

- [Eclair #2881][] Reject new `static_remote_key` channels

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30320,29523,7461,2881" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[news263 full-rbf]: /en/newsletters/2023/08/09/#full-rbf-by-default
[news288 rbfr]: /en/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning
[news283 truc pin]: /en/newsletters/2024/01/03/#v3-transaction-pinning-costs
[news288 rbfr]: /en/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning
[news290 rbf]: /en/newsletters/2024/02/21/#pure-replace-by-feerate-doesn-t-guarantee-incentive-compatibility
[news285 cluster cpfp-co]: /en/newsletters/2024/01/17/#cpfp-carve-out-needs-to-be-removed
[news286 imbued]: /en/newsletters/2024/01/24/#imbued-v3-logic
[news287 sibling]: /en/newsletters/2024/01/31/#kindred-replace-by-fee
[news289 imbued]: /en/newsletters/2024/02/14/#what-would-have-happened-if-v3-semantics-had-been-applied-to-anchor-outputs-a-year-ago
[todd fr-rbf]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zpk7EYgmlgPP3Y9D@petertodd.org/
[harding rbfr fundamental]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d57a02a84e756dbda03161c9034b9231@dtrt.org/
[todd unsolvable]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zp1utYduhnWf4oA4@petertodd.org/
[teinurier hacky]: https://github.com/bitcoin/bitcoin/issues/29319#issuecomment-1968709925
[daftuar prefer not]: https://github.com/bitcoin/bitcoin/issues/29319#issuecomment-1968709925
