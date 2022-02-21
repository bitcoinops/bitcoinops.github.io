---
title: Signet

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Developer Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Signet** is both a tool that allows developers to create networks
  for testing interactions between different Bitcoin software and the
  name of the most popular of these testing networks.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP325

    - title: Signet
      link: https://en.bitcoin.it/wiki/Signet

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Feedback requested on signet
    url: /en/newsletters/2019/03/12/#feedback-requested-on-signet

  - title: "CoreDev.tech discussion: signet"
    url: /en/newsletters/2019/06/12#signet

  - title: Progress on signet
    url: /en/newsletters/2019/07/24/#progress-on-signet

  - title: C-Lightning adds support for signet
    url: /en/newsletters/2019/07/24/#c-lightning-2816

  - title: C-Lightning 0.7.2.1 released with support for signet
    url: /en/newsletters/2019/08/21/#upgrade-to-c-lightning-0-7-2-1

  - title: Eltoo demo implementation using custom signet
    url: /en/newsletters/2019/09/11/#eltoo-sample-implementation-and-discussion

  - title: Signet protocol published as BIP325
    url: /en/newsletters/2019/11/13/#bips-803

  - title: "2019 year-in-review: signet"
    url: /en/newsletters/2019/12/28/#signet

  - title: "BIP325 updated: all signets to use same genesis block but different magic"
    url: /en/newsletters/2020/05/06/#bips-900

  - title: BIP325 updated for new signet block signing method
    url: /en/newsletters/2020/08/05/#bips-947

  - title: Will the availability of signet eliminate the need for a new testnet?
    url: /en/newsletters/2020/08/26/#will-there-be-a-testnet4-or-do-we-not-need-a-testnet-reset-once-we-have-signet

  - title: Discussion about the parameters for a default signet
    url: /en/newsletters/2020/09/02/#default-signet-discussion

  - title: Discussion about the design decisions for signet
    url: /en/newsletters/2020/09/02/#signet

  - title: "BIPs #983 updates BIP325 to omit signet commitments when unnecessary"
    url: /en/newsletters/2020/09/09/#bips-983

  - title: "Bitcoin Core #18267 and #19993 add support for signet"
    url: /en/newsletters/2020/09/30/#bitcoin-core-18267

  - title: "C-Lightning #4068 and #4078 update C-Lightning’s signet implementation"
    url: /en/newsletters/2020/09/30/#c-lightning-4068

  - title: Summary of Bitcoin Core PR Review Meeting on adding signet support
    url: /en/newsletters/2020/10/14/#bitcoin-core-pr-review-club

  - title: "Bitcoin Core #20145 adds script for requesting signet coins"
    url: /en/newsletters/2020/11/25/#bitcoin-core-20145

  - title: "2020 year in review: signet"
    url: /en/newsletters/2020/12/23/#signet

  - title: "Bitcoin Core 0.21.0 released with support for signets"
    url: /en/newsletters/2021/01/20/#bitcoin-core-0-21-0

  - title: "Bitcoin Core #19937 adds utilities for mining signet blocks"
    url: /en/newsletters/2021/01/20/#bitcoin-core-19937

  - title: "Discussion about multiple signet compatibilty with soft fork activation"
    url: /en/newsletters/2021/04/14/#taproot-activation-discussion

  - title: "LND #5025 adds basic support for using signet"
    url: /en/newsletters/2021/06/02/#lnd-5025

  - title: "Discussion about adding regular reorgs to the default signet"
    url: /en/newsletters/2021/09/15/#signet-reorg-discussion

  - title: "Preparing for taproot: testing on signet"
    url: /en/newsletters/2021/09/22/#preparing-for-taproot-14-testing-on-signet

  - title: "2021 year-in-review: signet"
    url: /en/newsletters/2021/12/22/#signet

  - title: "Parameters published for `OP_CHECKTEMPLATEVERIFY` signet"
    url: /en/newsletters/2022/02/23/#ctv-signet

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Bitcoin Core #16411: signet support"
    link: https://github.com/bitcoin/bitcoin/pull/16411
---
Blocks on signets are only valid if they're signed by a key used to
create that signet.  This gives the creator complete control over
block production, allowing them to choose the rate of block production
or when forks occur.  This can provide a much better controlled
network environment than proof-of-work testnets where adversarial
miners can use various tricks to make the network practically unusable
for long periods of time.

{% include references.md %}
