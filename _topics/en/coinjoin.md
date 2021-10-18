---
title: Coinjoin

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Coinjoin** is a trustless protocol for mixing UTXOs from multiple
  owners in order to make it difficult for outside parties to use the
  block chain's transaction history to determine who owns which coin.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: "Coinjoin: Bitcoin privacy for the real world"
    link: https://bitcointalk.org/index.php?topic=279249.0

  - title: "Zerolink: the Bitcoin fungibility framework"
    link: https://github.com/nopara73/ZeroLink

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: CoinjoinXT presentation
    url: /en/newsletters/2018/07/10/#coinjoinxt-and-other-techniques-for-deniable-transfers

  - title: BLS signatures library possibly useful for non-interactive coinjoins
    url: /en/newsletters/2018/08/07/#library-announced-for-bls-signatures

  - title: Sighash updates that can help hardware wallets participate in coinjoins
    url: /en/newsletters/2018/09/04/#proposed-sighash-updates

  - title: Question about Wasabi coinjoin mixing and exchange blacklisting
    url: /en/newsletters/2018/09/25/#how-likely-are-you-to-get-blacklisted-by-an-exchange-if-you-use-wasabi-wallet-s-coinjoin-mixing

  - title: Fidelity bonds for imporoved sybil resistance in distributed coinjoin
    url: /en/newsletters/2019/07/31/#fidelity-bonds-for-improved-sybil-resistance

  - title: "Simple Non-Interactive Coinjoin with Keys for Encryption Reused (SNICKER)"
    url: /en/newsletters/2019/09/04/#snicker-proposed

  - title: "2019 year-in-review: SNICKER"
    url: /en/newsletters/2019/12/28/#snicker

  - title: Evaluation of coinjoins without equal value inputs or outputs
    url: /en/newsletters/2020/01/08/#coinjoins-without-equal-value-inputs-or-outputs

  - title: "Wormhole: a protocol for sending payments as part of a chaumian coinjoin"
    url: /en/newsletters/2020/01/22/#new-coinjoin-mixing-technique-proposed

  - title: "Allowing hardware wallets to safely sign automated coinjoin transactions"
    url: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment

  - title: "Comparison of coinjoin privacy to coinswap privacy"
    url: /en/newsletters/2020/06/03/#design-for-a-coinswap-implementation

  - title: "WabiSabi: a protocol for coordinated coinjoins with arbitrary output values"
    url: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values

  - title: Candidate set based block templates may help fee bumping large coinjoins
    url: /en/newsletters/2021/06/02/#candidate-set-based-csb-block-template-construction

  - title: "JoinMarket 0.9.0 released with implementation of fidelity bonds for coinjoin sybil resistance"
    url: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds

  - title: "Sparrow 1.5.0 adds coinjoin suport"
    url: /en/newsletters/2021/10/20/#sparrow-adds-coinjoin-support

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Payjoin
    link: topic payjoin
  - title: "Coinjoin (Bitcoin Wiki: Privacy)"
    link: https://en.bitcoin.it/Privacy#CoinJoin
---
Named after a 2013 [proposal][gmaxwell coinjoin] by Gregory Maxwell,
several independent implementations have provided support for various
forms of coinjoin.

{% include references.md %}
[gmaxwell coinjoin]: https://bitcointalk.org/index.php?topic=279249.0
