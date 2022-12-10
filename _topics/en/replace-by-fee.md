---
title: Replace-by-fee (RBF)
shortname: rbf

aliases:
  - BIP125
  - Opt-in Replace-by-Fee
  - Full-RBF

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
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

## Optional.  Same format as "primary_sources" above
see_also:
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
be replaced whether or not it signals BIP125 replacability.

BIP125 requires a replacement transaction to pay both higher feerate
(BTC/vbyte) and a higher absolute fee (total BTC).  This can make
multiparty transactions that want to use RBF vulnerable to
[transaction pinning][] attacks, and so an occasional discussion
topic is proposals to allow RBF to operate solely on a feerate basis.

{% include references.md %}
[core12 rbf]: https://bitcoincore.org/en/releases/0.12.0/#opt-in-replace-by-fee-transactions
[transaction pinning]: https://bitcoin.stackexchange.com/questions/80803/what-is-meant-by-transaction-pinning
