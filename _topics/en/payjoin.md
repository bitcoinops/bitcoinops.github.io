---
title: Payjoin

title-aliases:
  - Pay-to-EndPoint
  - Bustapay
  - BIP79

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Payjoin** is a technique for paying someone while including one of
  their inputs in the payment in order to enhance the privacy of the
  spender, the receiver, and Bitcoin users in general.  The general idea
  is also known under the names Pay-to-EndPoint (P2EP) and Bustapay.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP78

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Pay-to-EndPoint (P2EP) proposed
    url: /en/newsletters/2018/08/14/#pay-to-end-point-p2ep-idea-proposed

  - title: Bustapay discussion (simplified alternative to P2EP)
    url: /en/newsletters/2018/09/18/#bustapay-discussion

  - title: "2018 year-in-review: Pay-to-EndPoint (P2EP)"
    url: /en/newsletters/2018/12/28/#p2ep

  - title: Mailing list discussion about BIP79 Bustapay
    url: /en/newsletters/2019/01/29/#post-about-bip79-p2ep-payjoin

  - title: BTCPay adds support for sending and receiving payjoined payments
    url: /en/newsletters/2020/04/22/#btcpay-adds-support-for-sending-and-receiving-payjoined-payments

  - title: Comparison of payjoin privacy to coinswap privacy
    url: /en/newsletters/2020/06/03/#design-for-a-coinswap-implementation

  - title: Discussion about payjoin and its history
    url: /en/newsletters/2020/06/03/#payjoin-p2ep

  - title: New BIP78 specification of payjoin
    url: /en/newsletters/2020/07/01/#bips-923

  - title: Wasabi adds support for BIP78 payjoin
    url: /en/newsletters/2020/08/19/#wasabi-adds-support-for-payjoin

  - title: Joinmarket 0.7.0 adds support for BIP78 payjoin
    url: /en/newsletters/2020/09/23/#joinmarket-0-7-0-adds-bip78-psbt

  - title: BlueWallet 5.6.1 adds support for BIP78 payjoin
    url: /en/newsletters/2020/10/21/#bluewallet-adds-payjoin

  - title: Sparrow Wallet 0.9.7 adds support for BIP78 payjoin
    url: /en/newsletters/2020/11/18/#sparrow-wallet-adds-payment-batching-and-payjoin

  - title: "2020 year in review: payjoin"
    url: /en/newsletters/2020/12/23/#payjoin

  - title: "Discussion about how to increase payjoin adoption"
    url: /en/newsletters/2021/01/20/#payjoin-adoption

  - title: "Coldcard hardware wallet adds support for paying payjoin"
    url: /en/newsletters/2021/01/20/#coldcard-adds-payjoin-signing

  - title: "BTCPay Server #2425 allows receiving payjoin payments without an inovice"
    url: /en/newsletters/2021/04/21/#btcpay-server-2425

  - title: "BTCPay Server #2450 makes generating payjoin-compatible invoices the default for new hot wallets"
    url: /en/newsletters/2021/06/23/#btcpay-server-2450

  - title: "Tradeoffs of WabiSabi as an alternative to payjoin"
    url: /en/newsletters/2022/04/06/#wabisabi-alternative-to-payjoin

  - title: "Serverless payjoin proposal"
    url: /en/newsletters/2023/02/01/#serverless-payjoin-proposal

  - title: "BTCPay Server #4600 updates its payjoin implementation to avoid creating unnecessary inputs"
    url: /en/newsletters/2023/02/15/#btcpay-server-4600

  - title: "Advanced payjoin applications, including transaction cut-through"
    url: /en/newsletters/2023/05/17/#advanced-payjoin-applications

  - title: "Payjoin Dev Kit (PDK) announced to provide a Rust SDK for payjoin"
    url: /en/newsletters/2023/07/19/#payjoin-sdk-announced

  - title: "Discussion about draft BIP for serverless payjoin"
    url: /en/newsletters/2023/08/16/#serverless-payjoin

  - title: "Payjoin client for Bitcoin Core released"
    url: /en/newsletters/2023/12/13/#payjoin-client-for-bitcoin-core-released

  - title: "Mutiny Wallet v0.5.7 adds support for payjoin"
    url: /en/newsletters/2024/02/21/#mutiny-wallet-v0-5-7-released

## Optional.  Same format as "primary_sources" above
see_also:
  - title: BIP79
  - title: Improving Privacy Using Pay-to-EndPoint (P2EP)
    link: https://blockstream.com/2018/08/08/en-improving-privacy-using-pay-to-endpoint/
  - title: Pay To EndPoint
    link: https://medium.com/@nopara73/pay-to-endpoint-56eb05d3cac6
  - title: Payjoin
    link: https://joinmarket.me/blog/blog/payjoin/
  - title: Payjoin (Bitcoin Wiki)
    link: https://en.bitcoin.it/wiki/PayJoin
---
By including inputs from both the spender and the receiver, payjoin
makes it difficult for block chain analysis companies to determine
which inputs and outputs belong to each participant.

{% include references.md %}
