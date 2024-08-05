---
title: Fee estimation

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Fee Management

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Bitcoin Core Fee Estimation Algorithm (2017)"
      link: https://gist.github.com/morcos/d3637f015bc4e607e1fd10d8351e9f41

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "LND #4078 adds an `estimatemode` configuration setting for configuring its fee estimation"
    url: /en/newsletters/2020/04/01/#lnd-4078

  - title: "Bitcoin Core #18766 disables the ability to get fee estimates when using blocks-only mode"
    url: /en/newsletters/2020/12/16/#bitcoin-core-18766

  - title: "Bitcoin Core #22539 includes replacement transactions seen by the local node in fee estimates"
    url: /en/newsletters/2021/10/20/#bitcoin-core-22539

  - title: "ECDSA signature grinding helps with fee estimation"
    url: /en/newsletters/2022/01/26/#what-is-signature-grinding

  - title: "Rust Bitcoin #2213 amends the weight prediction for P2WPKH inputs during fee estimation"
    url: /en/newsletters/2023/11/29/#rust-bitcoin-2213

  - title: "BTCPay Server #5490 begins using fee estimates from mempool.space"
    url: /en/newsletters/2023/12/13/#btcpay-server-5490

  - title: "Cluster fee estimation to improve accuracy in a world with CPFP fee bumping"
    url: /en/newsletters/2024/01/03/#cluster-fee-estimation

  - title: "Discussion of incorporating live mempool data into Bitcoin Core's feerate estimation"
    url: /en/newsletters/2024/03/27/#mempool-based-feerate-estimation

  - title: Discussion about weak blocks helping with feerate estimation
    url: /en/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation

  - title: "LND #8730 introduces an RPC command `lncli wallet estimatefee`"
    url: /en/newsletters/2024/06/21/#lnd-8730

  - title: "Bitcoin Core #30275 updates `estimatesmartfee` RPC default from conservative to economical"
    url: /en/newsletters/2024/08/02/#bitcoin-core-30275

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Coin selection
    link: topic coin selection

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Fee estimation** is the process of estimating the feerate a
  transaction will need to pay to have a high probability of being
  confirmed within a certain number of blocks.

---

{% include references.md %}
{% include linkers/issues.md issues="" %}
