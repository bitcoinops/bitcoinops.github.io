---
title: Replace-by-fee (RBF)
shortname: rbf

title-aliases:
  - BIP125
  - Opt-in Replace-by-Fee
  - Full-RBF

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Fee Management
  - Transaction Relay Policy
  - Mining

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Replace-By-Fee (RBF)** is a node policy that allows an unconfirmed
  transaction in a mempool to be replaced with a different transaction
  that spends at least one of the same inputs and which pays a higher
  transaction fee.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP125
    - title: "Bitcoin Core PR #6871: nSequence-based Full-RBF opt-in"
      link: https://github.com/bitcoin/bitcoin/pull/6871

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Compatibility matrix---Replace by Fee
    url: /en/compatibility#replace-by-fee-rbf
    date: 2019-08-20

  - title: RBF in the wild (survey of RBF usage)
    url: /en/rbf-in-the-wild/
    date: 2019-02-11

  - title: "2018 year-in-review: transaction statistics"
    url: /en/newsletters/2018/12/28/#opt-in-rbf

  - title: Proposal to override some BIP125 RBF conditions
    url: /en/newsletters/2019/06/12/#proposal-to-override-some-bip125-rbf-conditions

  - title: LND adds support for RBF fee bumping
    url: /en/newsletters/2019/06/19/#lnd-3140

  - title: Bitcoin Core removes `mempoolreplacement` configuration option
    url: /en/newsletters/2019/06/26/#bitcoin-core-16171

  - title: "Bitcoin Core #16373 allows the bumpfee RPC used for RBF to return a PSBT"
    url: /en/newsletters/2020/01/15/#bitcoin-core-16373

  - title: "C-Lightning #3870 implements RBF scorched earth for penalty transactions"
    url: /en/newsletters/2020/09/16/#c-lightning-3870

  - title: Sparrow wallet adds support for RBF fee bumping
    url: /en/newsletters/2020/12/16/#sparrow-adds-replace-by-fee

  - title: "Question: would first-seen-safe prevent confirmed RBF double spends?"
    url: /en/newsletters/2021/01/27/#would-first-seen-prevent-a-double-spend-attack

  - title: Recovering lost LN funding transactions after RBF fee bumping
    url: /en/newsletters/2021/03/17/#rescuing-lost-ln-funding-transactions

  - title: Upcoming relay policy workshop to discuss RBF and other topics
    url: /en/newsletters/2021/04/28/#call-for-topics-in-layer-crossing-workshop

  - title: CVE-2021-31876 discrepancy between BIP125 and Bitcoin Core implementation
    url: /en/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation

  - title: "Continued discussion about CVE-2021-31876's impact on protocols using RBF"
    url: /en/newsletters/2021/05/19/#cve-2021-31876-bip125-implementation-discrepancy-follow-up

  - title: "Proposal to allow any mempool transaction to be replaced by default"
    url: /en/newsletters/2021/06/23/#allowing-transaction-replacement-by-default

  - title: "Trezor wallet software defaults to enabling BIP125 RBF"
    url: /en/newsletters/2021/06/23/#trezor-suite-adds-rbf-support

  - title: Proposal of initial RBF rules for mempool package acceptance before implementing package relay
    url: /en/newsletters/2021/09/22/#package-mempool-acceptance-and-package-rbf

  - title: "2021 year-in-review: BIP125 opt-in replace-by-fee discrepency"
    url: /en/newsletters/2021/12/22/#bip125

  - title: "2021 year-in-review: default transaction replacement by fee"
    url: /en/newsletters/2021/12/22/#default-rbf

  - title: Proposal to briefly allow full RBF before using default opt-in RBF
    url: /en/newsletters/2022/01/05/#brief-full-rbf-then-opt-in-rbf

  - title: "Discussion about RBF policy, including suggested changes"
    url: /en/newsletters/2022/02/09/#discussion-about-rbf-policy

  - title: "Summary of recent proposed changes to RBF policy"
    url: /en/newsletters/2022/03/16/#ideas-for-improving-rbf-policy

  - title: "Discussion about allowing transaction witness replacement without a fee bump"
    url: /en/newsletters/2022/03/30/#transaction-witness-replacement

  - title: "Discussion about enabling full replace by fee in Bitcoin Core (off by default)"
    url: /en/newsletters/2022/06/22/#full-replace-by-fee

  - title: "Bitcoin Core fullrbf setting where the node always allows transaction replacement"
    url: /en/newsletters/2022/07/13/#bitcoin-core-25353

  - title: "Bitcoin Core #25610 opts-in the RPCs and `-walletrbf` to RBF by default"
    url: /en/newsletters/2022/08/10/#bitcoin-core-25610

  - title: "Proposal for relay of v3 transactions allows replacement"
    url: /en/newsletters/2022/10/05/#proposed-new-transaction-relay-policies-designed-for-ln-penalty

  - title: "Concerns raised about configuration option allowing full replace by fee in Bitcoin Core"
    url: /en/newsletters/2022/10/19/#transaction-replacement-option

  - title: 'History of the term "full RBF"'
    url: /en/newsletters/2022/10/19/#fn:full-rbf

  - title: "Continued discussion about `mempoolfullrbf` option for enabling full RBF"
    url: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf

  - title: "Discussion about `mempoolfullrbf` option's effect on mempool consistency"
    url: /en/newsletters/2022/11/02/#mempool-consistency

  - title: "Continued discussion about enabling full-RBF in Bitcoin Core"
    url: /en/newsletters/2022/11/09/#continued-discussion-about-enabling-full-rbf

  - title: "Website to monitor unsignaled transaction replacements"
    url: /en/newsletters/2022/12/14/#monitoring-of-full-rbf-replacements

  - title: "2022 year-in-review: replace-by-fee"
    url: /en/newsletters/2022/12/21/#rbf

  - title: "Continued RBF discussion, including number of full-RBF nodes, RBF-FSS, and RBF motivation"
    url: /en/newsletters/2023/01/04/#continued-rbf-discussion

  - title: "Bitcoin Core #25344 updates the fee-bumping RPCs to allow altering replacement outputs"
    url: /en/newsletters/2023/02/22/#bitcoin-core-25344

  - title: "Suggested best practices for CPFP or RBF fee-bumping a previous CPFP fee bump"
    url: /en/newsletters/2023/04/26/#best-practices-with-multiple-cpfps-cpfp-rbf

  - title: "Question about whether 0 OP_CSV forces the spending transaction to signal BIP125 replaceability?"
    url: /en/newsletters/2023/07/26/#does-0-op-csv-force-the-spending-transaction-to-signal-bip125-replaceability

  - title: "Proposal to enable full-RBF by default"
    url: /en/newsletters/2023/08/09/#full-rbf-by-default

  - title: "Replacement cycle attacks on HTLCs"
    url: /en/newsletters/2023/10/25/#replacement-cycling-vulnerability-against-htlcs

  - title: Proposal for miners to automatically retry previously replaced transactions
    url: /en/newsletters/2023/10/25/#automatic-retrying-of-past-transactions

  - title: Recommendation to RBF fee bump pre-signed transactions with more pre-signed transactions
    url: /en/newsletters/2023/10/25/#presigned-fee-bumps

  - title: "Summary of well-known behavior for wallets to avoid when creating multiple replacements"
    url: /en/newsletters/2023/10/25/#fn:rbf-warning

  - title: "Discussion of cluster mempool for RBF"
    url: /en/newsletters/2023/12/06/#post-cluster-package-rbf

  - title: "Idea to apply RBF rules to v3 transactions to allow removing CPFP carve-out for cluster mempool"
    url: /en/newsletters/2024/01/31/#kindred-replace-by-fee

  - title: "Proposal for replace-by-feerate to avoid transaction pinning"
    url: /en/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning

  - title: "Pure replace by feerate is not guaranteed to be incentive compatible"
    url: /en/newsletters/2024/02/21/#pure-replace-by-feerate-doesn-t-guarantee-incentive-compatibility

  - title: "BitGo adds RBF support"
    url: /en/newsletters/2024/03/20/#bitgo-adds-rbf-support

  - title: "Bitcoin Core #29242 lays the groundwork for package replace by fee"
    url: /en/newsletters/2024/04/03/#bitcoin-core-29242

  - title: "Analysis of how cluster mempool would've affected RBF in 2023"
    url: /en/newsletters/2024/04/17/#rbf-differences-were-negligible

  - title: "Question about the size of transactions that opt-in to RBF, opt-out of RBF, and replacements"
    url: /en/newsletters/2024/04/24/#are-replacement-transactions-larger-in-size-than-their-predecessors-and-than-non-rbf-transactions

  - title: "Bitcoin Core #28984 adds support for a limited version of package replace-by-fee"
    url: /en/newsletters/2024/06/28/#bitcoin-core-28984

  - title: "Question: why does RBF rule #3 exist?"
    url: /en/newsletters/2024/07/26/#why-does-rbf-rule-3-exist

  - title: "Nodes with full-RBF successfully reconstructing more compact blocks than nodes with only opt-in RBF"
    url: /en/newsletters/2024/08/09/#replacement-cycle-attack-against-pay-to-anchor

  - title: "Bitcoin Core #30493 enables full RBF by default"
    url: /en/newsletters/2024/08/09/#bitcoin-core-30493

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Transaction pinning
    link: topic transaction pinning

  - title: Version 3 transaction relay
    link: topic v3 transaction relay

  - title: Opt-in RBF FAQ
    link: https://bitcoincore.org/en/faq/optin_rbf/

  - title: "Optech Dashboard: BIP125 usage"
    link: https://dashboard.bitcoinops.org/d/ZsCio4Dmz/rbf-signalling?orgId=1
---
Different node software can use different RBF rules, so there have
been several variations.  The most widely-used form of RBF today is
[BIP125][] **opt-in RBF** as
implemented in [Bitcoin Core 0.12.0][core12 rbf] and subsequent
versions; this allows the creator of a transaction to signal that
they're willing to allow it to be replaced by a higher-paying version.
An alternative form of RBF is **full-RBF** that allows any transaction to
be replaced whether or not it signals BIP125 replaceability.

BIP125 requires a replacement transaction to pay both higher feerate
(BTC/vbyte) and a higher absolute fee (total BTC).  This can make
multiparty transactions that want to use RBF vulnerable to
[transaction pinning][] attacks, and so an occasional discussion
topic is proposals to allow RBF to operate solely on a feerate basis.

{% include references.md %}
[core12 rbf]: https://bitcoincore.org/en/releases/0.12.0/#opt-in-replace-by-fee-transactions
[transaction pinning]: https://bitcoin.stackexchange.com/questions/80803/what-is-meant-by-transaction-pinning
