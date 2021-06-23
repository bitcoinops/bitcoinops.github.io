---
title: Bech32
aliases:
  - Bech32m
  - BIP173
  - Native segwit address

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Bech32** is an address format used to pay native segwit outputs.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP173
    - title: Bech32 reference code
      link: https://github.com/sipa/bech32
    - title: BIP350

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Bech32 sending support (24-part series)"
    url: /en/bech32-sending-support/
    date: 2019-03-19
    feature: true

  - title: Bech32 security update for C implementations
    url: /en/newsletters/2018/11/06#bech32-security-update-for-c-implementation

  - title: How does the bech32 length-extension mutation weakness work?
    url: /en/newsletters/2019/11/27/#how-does-the-bech32-length-extension-mutation-weakness-work

  - title: Impact of bech32 length-change mutability on v1 segwit script length
    url: /en/newsletters/2019/11/13/#taproot-review-discussion-and-related-information

  - title: "LND #3767 rejects malformed BOLT11 invoices with a valid bech32 checksum"
    url: /en/newsletters/2019/12/11/#lnd-3767

  - title: Proposed plan to deal with bech32 malleability in variable-length addresses
    url: /en/newsletters/2019/12/18/#review-bech32-action-plan

  - title: Analysis of bech32 error detection capability
    url: /en/newsletters/2019/12/18/#analysis-of-bech32-error-detection

  - title: "2019 year-in-review: bech32 mutability"
    url: /en/newsletters/2019/12/28/#bech32-mutability

  - title: Proposed updates to BIP173 bech32 to address mutability concerns
    url: /en/newsletters/2020/07/22/#bech32-address-updates

  - title: Discussion about updates to BIP173 bech32 to address mutability concerns
    url: /en/newsletters/2020/10/14/#bech32-addresses-for-taproot

  - title: Bech32 algorithm revision research and proposal
    url: /en/newsletters/2020/12/09/#bech32-addresses-for-taproot-and-beyond

  - title: Problems with QR-encoded bech32 BIP21 invoices with uppercase schema
    url: /en/newsletters/2020/12/09/#thwarted-upgrade-to-uppercase-bech32-qr-codes

  - title: "Q&A: What is the difference between 'native segwit' and 'bech32'?"
    url: /en/newsletters/2020/12/16/#what-is-the-difference-between-native-segwit-and-bech32

  - title: "2020 year in review: taproot's need for a modified bech32 address format"
    url: /en/newsletters/2020/12/23/#taproot

  - title: "Draft BIP for bech32m"
    url: /en/newsletters/2021/01/13/#bech32m

  - title: "BIPs #1056 adds BIP350 for bech32m"
    url: /en/newsletters/2021/02/10/#bips-1056

  - title: "BTCPay Server #2181 uppercases bech32 addresses in QR codes"
    url: /en/newsletters/2021/03/10/#btcpay-server-2181

  - title: "Bitcoin Core #20861 implements support for bech32m addresses"
    url: /en/newsletters/2021/03/24/#bitcoin-core-20861

  - title: "BitMEX exchange announces support for bech32 deposit addresses"
    url: /en/newsletters/2021/03/24/#bitmex-announces-bech32-support

  - title: Blockchain.com adds support for bech32 receiving and spending
    url: /en/newsletters/2021/05/19/#blockchain-com-supports-segwit

  - title: Electrum 4.1.0 adds support for bech32m
    url: /en/newsletters/2021/05/19/#electrum-4-1-0-enhances-lightning-features

  - title: C-Lightning #4591 adds support for sending to bech32m addresses
    url: /en/newsletters/2021/06/16/#c-lightning-4591

  - title: "Preparing for taproot #1: bech32m sending support"
    url: /en/newsletters/2021/06/23/#preparing-for-taproot-1-bech32m-sending-support

  - title: "Rust Bitcoin #601 adds support for parsing bech32m addresses"
    url: /en/newsletters/2021/06/23/#rust-bitcoin-601

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Javascript bech32 demo decoder
    link: http://bitcoin.sipa.be/bech32/demo/demo.html
---
Using only 32 letters and numbers, the bech32 address format does not use
mixed case and includes an error-correction code that can catch
almost all address typos (and even identify where the typos occur in
some cases).  Addresses encode a segwit version, making them forward
compatible with a large range of conceivable upgrades.

After a [problem][bech32 weakness] was discovered with bech32 error
detection for future upgrades under some rare circumstances, a new
bech32 modified (**bech32m**) format was proposed.
It is expected that bech32m will be used for
[taproot][topic taproot] and future segwit-based script upgrades,
requiring wallets and services that implemented support for paying the
original bech32 address format to upgrade if they want to support
paying taproot addresses and future upgrades.  No upgrade is required to
continue paying the original (version 0) segwit addresses for P2WPKH
and P2WSH scripts.

{% include references.md %}
[bech32 weakness]: /en/newsletters/2019/11/13/#taproot-review-discussion-and-related-information
