---
title: Replace-by-fee (RBF)
shortname: rbf

aliases:
  - BIP125
  - Opt-in Replace-by-Fee

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

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Different node software can use different RBF rules, so there have
  been several variations.  The most widely-used form of RBF today is
  [BIP125][] opt-in RBF as
  implemented in [Bitcoin Core 0.12.0][core12 rbf] and subsequent
  versions; this allows the creator of a transaction to signal that
  they're willing to allow it to be replaced by a higher-paying version.
  An alternative form of RBF is full-RBF that allows any transaction to
  be replaced whether or not it signals BIP125 replacability.

  BIP125 requires a replacement transaction to pay both higher feerate
  (BTC/vbyte) and a higher absolute fee (total BTC).  This can make
  multiparty transactions that want to use RBF vulnerable to
  [transaction pinning][] attacks, and so an occasional discussion
  topic is proposals to allow RBF to operate solely on a feerate basis.

  [core12 rbf]: https://bitcoincore.org/en/releases/0.12.0/#opt-in-replace-by-fee-transactions
  [transaction pinning]: https://bitcoin.stackexchange.com/questions/80803/what-is-meant-by-transaction-pinning

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

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Opt-in RBF FAQ
    link: https://bitcoincore.org/en/faq/optin_rbf/

  - title: "Optech Dashboard: BIP125 usage"
    link: https://dashboard.bitcoinops.org/d/ZsCio4Dmz/rbf-signalling?orgId=1
---
