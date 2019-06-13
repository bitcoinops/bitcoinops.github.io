---
title: 'Bitcoin Optech Newsletter #2'
permalink: /en/newsletters/2018/07/03/
name: 2018-07-03-newsletter
slug: 2018-07-03-newsletter
type: newsletter
layout: newsletter
lang: en
version: 1
excerpt: >
  Continued discussion over graftroot safety, BIP174 Partially-Signed
  Bitcoin Transactions (PSBT) officially marked as proposed, and
  discussion of Dandelion transaction relay.

---
### Unsubscribing

We’ve moved to a new platform for distributing this week’s newsletter. If you’re not interested in receiving weekly updates on what’s happening in the Bitcoin open source community, please click on the unsubscribe link at the bottom of this email.

Don’t hesitate to contact us at [info@bitcoinops.org](mailto:info@bitcoinops.org) if you have any questions or comments about what we’re doing!

## Welcome

Welcome to the second Bitcoin Optech Group newsletter! As a member of our new organization, you can expect to see regular newsletters from us covering Bitcoin open source development and protocol news, Optech announcements, and member company’s case studies. These newsletters are also available on [our web site][newsletter page].

As always, please feel free to contact us if you have feedback or comments on this newsletter.

A reminder to companies that haven’t yet become an official member yet. We ask that you pay a nominal contribution of $5,000 to help fund our expenses.

[newsletter page]: https://bitcoinops.org/en/newsletters/

## First Optech workshop!

As announced previously, Bitcoin Optech Group is organizing our first workshop **July 17 in San Francisco**. Participants will be 1-2 engineers from SF Bay area Bitcoin companies. We will have roundtable discussions covering 3 topics:

- Coin selection best practices;
- Fee estimation, RBF, CPFP best practices;
- Optech community and communication - optimizing Optech for business’ needs.

Please contact us if you would like to be involved in this or future workshops in other regions.

## Open Source News

A summary of relevant action items, dashboard items, and news from the broader Bitcoin open source community.

### Action items

No new action items, but follow-up related to the following previously-published items is still recommended.

- Pending DoS vulnerability disclosure for Bitcoin Core 0.12.0 and earlier.  Altcoins may be affected.  See [newsletter #1][]

- Upgrade to [Bitcoin Core 0.16.1][], released 15 June 2018.  Upgrade especially recommended for miners.  See [newsletter #1][]

[Bitcoin Core 0.16.1]: https://bitcoincore.org/en/download/
[newsletter #1]: https://bitcoinops.org/en/newsletters/2018/06/26/

### Dashboard items

- **Transaction fees remain very low:** as of this writing, fee estimates for confirmation 2 or more blocks in the future remain at roughly the level of the default minimum relay fee in Bitcoin Core.  It's a good time to [consolidate inputs][].

  **UPDATE (July 2)**: The estimated [network hash rate decreased][hash rate graph] in the last 3-4 days, initially by as much as 10%, but rebounding a bit since then. Some have speculated that flooding in south western China has destroyed a significant amount of mining equipment. Note, however, that due to the natural variance in the rate of block discovery, it’s only possible to make a rough estimate of the current amount of network hash rate over short periods of time. Lower network hash rate implies a slower rate of block discovery, which can lead to mempool congestion and potentially higher fees. So far, mempool congestion does not appear to have increased significantly and fees remain low. However, it is recommended to keep monitoring block discovery rate and mempool congestion before sending large transactions.

[consolidate inputs]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

[hash rate graph]: https://bitcoinwisdom.com/bitcoin/difficulty

- **Testnet high block production rate:** late last week, a miner produced a large number of blocks in rapid succession on testnet, sometimes several blocks per second, leading to a degradation of service from some testnet providers.  This is a recurrent problem on testnet that is the result of the deliberate lack of economic incentive to mine there.  If you to need test your software, it's more reliable to build your own private testent using Bitcoin Core's [regtest mode][].

[regtest mode]: https://bitcoin.org/en/developer-examples#regtest-mode

### News

- **Continued discussion over graftroot safety:** [Graftroot][] is a proposed opt-in alternative to [taproot][], which is a proposed enhancement of [MAST][], which is itself a proposed enhancement of the current Bitcoin script.  MAST improves scalability, privacy, and fungibility by allowing unused conditional branches in Bitcoin scripts to be left out of the block chain.  Taproot further improves MAST scalability, privacy, and fungibility by allowing even the used conditional branch in a script to be left out of the block chain in the common case.  Graftroot improves taproot's flexibility and scalability by allowing participants in the script to delegate their spending authority to other parties, including allowing the existing participants to impose additional script-based conditions on the delegates---all done offchain and without reducing the scalability, privacy, and fungibility benefits.

  In a slowly-progressing [discussion][graftroot discussion], members of the bitcoin-dev mailing list have been attempting to construct an informally-worded security proof that enabling graftroot delegation by default doesn't reduce the security of users who don't need it (e.g.  who just want to use taproot without delegation or even just plain MAST).  Although more peer review is needed, the effort seems to be proceeding positively with experts currently agreeing that it's safe to enable graftroot by default.

[graftroot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[MAST]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[graftroot discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016049.html

- **[BIP174][] discussion:** as mentioned in [last week's newsletter][newsletter #1], mailing list [discussion][bip174 discussion] continues surrounding this proposed BIP for an industry standard to make it easier for wallets to communicate with each other in the case of online/offline (hot/cold) wallets, software/hardware wallets, multisig wallets, and multi-user transactions (e.g.  CoinJoin).  However, the BIP proposer has now opened a [pull request][bip174 update] requesting the BIP's status be changed from "draft" to "proposed".  That means it is unlikely to be changed unless a significant problem with implementation is found.  If your organization produces or makes critical use of one of the aforementioned interoperating wallets, you may wish to evaluate the current proposal ASAP before it is finalized.

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[BIP174 update]: https://github.com/bitcoin/bips/pull/694
[BIP174 discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016150.html

- **[Dandelion][] transaction relay:** this proposed privacy-enhancing improvement to the way new transactions are initially relayed was [briefly discussed][dandelion discussion] on the bitcoin-dev mailing list this week. The main concern was how it selects which peers to route transactions through, which could be abused to reduce privacy temporarily during the initial deployment when only a few nodes support Dandelion.  Two mitigations for this problem were discussed.

[Dandelion]: https://github.com/mablem8/bips/blob/master/bip-dandelion.mediawiki
[dandelion discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016162.html
