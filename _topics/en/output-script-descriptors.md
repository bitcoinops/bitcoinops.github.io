---
title: Output script descriptors
shortname: descriptors

title-aliases:
  - Descriptors

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Scripts and Addresses
  - Wallet Collaboration Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Output script descriptors** are strings that contain all the
  information necessary to allow a wallet or other program to track
  payments made to or spent from a particular script or set of related
  scripts (i.e. an address or a set of related addresses such as in an
  HD wallet).

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Output script descriptors
      link: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: First use of descriptors in Bitcoin Core
    url: /en/newsletters/2018/07/24/#first-use-of-output-script-descriptors

  - title: Key origin support
    url: /en/newsletters/2018/10/30/#bitcoin-core-14150

  - title: Descriptor checksum support added
    url: /en/newsletters/2019/02/19/#bitcoin-core-15368

  - title: Descriptors extended with sortedmulti
    url: /en/newsletters/2019/10/16/#bitcoin-core-17056

  - title: "Encoded descriptors (e.g., with base64)"
    url: /en/newsletters/2020/01/08/#encoded-descriptors

  - title: "Bitcoin Core #18032 add `descriptor` field to multisig address RPCs"
    url: /en/newsletters/2020/02/12/#bitcoin-core-18032

  - title: "Bitcoin Core #16528 adds support for native output descriptor wallets"
    url: /en/newsletters/2020/05/06/#bitcoin-core-16528

  - title: "Field Report: Using descriptors at River Financial"
    url: /en/river-descriptors-psbt/
    date: 2020-07-29

  - title: "C-Lightning #4171 allows retrieving the wallet's onchain descriptors"
    url: /en/newsletters/2020/11/18/#c-lightning-4171

  - title: "Q&A about migration from legacy wallets to descriptor wallets"
    url: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work

  - title: "Bitcoin Wallet Tracker (BWT) adds descriptor support"
    url: /en/newsletters/2020/12/16/#bitcoin-wallet-tracker-adds-descriptor-support

  - title: "Bitcoin Core 0.21.0 released with experimental native descriptor wallets"
    url: /en/newsletters/2021/01/20/#bitcoin-core-0-21-0

  - title: "BTCPay Server #2169 adds functions for importing some descriptors"
    url: /en/newsletters/2021/01/20/#btcpay-server-2169

  - title: "BTCPay Server 1.0.6.7 released with support for descriptors in wallet setup"
    url: /en/newsletters/2021/01/20/#btcpay-server-1-0-6-7

  - title: "Bitcoin Core #20226 adds new `listdescriptors` RPC for its wallet"
    url: /en/newsletters/2021/02/03/#bitcoin-core-20226

  - title: "Bitcoin Dev Kit v0.2.0 released with descriptor support"
    url: /en/newsletters/2021/02/17/#bitcoin-dev-kit-v0-3-0-released

  - title: "Bitcoin Core #19136 extends `getaddressinfo` to return parent descriptors"
    url: /en/newsletters/2021/02/24/#bitcoin-core-19136

  - title: Specter v1.2.0 includes support for Bitcoin Core descriptor wallets
    url: /en/newsletters/2021/03/24/#specter-v1-2-0-released

  - title: Specter-DIY v1.5.0 adds full descriptor support
    url: /en/newsletters/2021/04/21/#specter-diy-v1-5-0

  - title: "Bitcoin Core #20867 increases the maximum multisig keys for descriptors to 20"
    url: /en/newsletters/2021/05/12/#bitcoin-core-20867

  - title: "BIPs #1089 assigns BIP87 to a multisig wallet standard using descriptors"
    url: /en/newsletters/2021/05/26/#bips-1089

  - title: "Bitcoin Core #22051 adds support for importing descriptors for taproot outputs"
    url: /en/newsletters/2021/06/09/#bitcoin-core-22051

  - title: "Seven BIPs proposed for standardized output script descriptors"
    url: /en/newsletters/2021/07/07/#bips-for-output-script-descriptors

  - title: "Preparing for taproot: output script descriptors"
    url: /en/newsletters/2021/07/07/#preparing-for-taproot-3-taproot-descriptors

  - title: "Bitcoin Core #19651 adds support for updating descriptors via `importdescriptor`"
    url: /en/newsletters/2021/07/07/#bitcoin-core-19651

  - title: "Output script descriptors versus versioned and unversioned BIP32 seeds"
    url: /en/newsletters/2021/07/14/#fn:electrum-segwit

  - title: "BIPs #1143 introduces BIPs 380-386 specifying output script descriptors"
    url: /en/newsletters/2021/09/08/#bips-1143

  - title: "Coldcard 4.1.3 adds support for descriptor-based wallets"
    url: /en/newsletters/2021/10/20/#coldcard-supports-descriptor-based-wallets

  - title: "Bitcoin Core #23002 makes descriptor-based wallets the default for new wallets"
    url: /en/newsletters/2021/10/27/#bitcoin-core-23002

  - title: "Bitcoin Core #22364 adds support for creating taproot descriptors in the wallet"
    url: /en/newsletters/2021/12/01/#bitcoin-core-22364

  - title: "2021 year-in-review: output script descriptors"
    url: /en/newsletters/2021/12/22/#descriptors

  - title: "HWI #545 adds support for taproot `tr()` descriptors"
    url: /en/newsletters/2022/01/05/#hwi-545

  - title: "Bitcoin Core #24043 adds new `multi_a` and `sortedmulti_a` descriptors for taproot multisig"
    url: /en/newsletters/2022/03/16/#bitcoin-core-24043

  - title: "Adapting descriptors and miniscript for hardware signing devices"
    url: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices

  - title: "PR Review Club about miniscript support for descriptors"
    url: /en/newsletters/2022/06/08/#bitcoin-core-pr-review-club

  - title: "Bitcoin Core #24148 adds watch-only support for descriptors containing miniscript"
    url: /en/newsletters/2022/07/20/#bitcoin-core-24148

  - title: BIP proposed to allow multiple derivation paths in a descriptor
    url: /en/newsletters/2022/08/03/#multiple-derivation-path-descriptors

  - title: "Bitcoin Core #23480 adds a `rawtr()` descriptor"
    url: /en/newsletters/2022/08/17/#bitcoin-core-23480

  - title: "New descriptor proposed for silent payments"
    url: /en/newsletters/2022/08/24/#updated-silent-payments-pr

  - title: "How partial descriptors could help create tapleaf trees"
    url: /en/newsletters/2022/08/31/#why-isn-t-it-possible-to-add-an-op-return-commitment-or-some-arbitrary-script-inside-a-taproot-script-path-with-a-descriptor

  - title: "2022 year-in-review: miniscript descriptors in Bitcoin Core"
    url: /en/newsletters/2022/12/21/#miniscript-descriptors

  - title: "Bitcoin Core #24149 adds signing support for P2WSH-based miniscript-based output descriptors"
    url: /en/newsletters/2023/02/22/#bitcoin-core-24149

  - title: "BIPs #1354 adds BIP389 for multiple derivation path descriptors"
    url: /en/newsletters/2023/07/05/#bips-1354

  - title: "Bitcoin Core #27255 ports miniscript to tapscript, providing tapscript descriptors"
    url: /en/newsletters/2023/10/18/#bitcoin-core-27255

  - title: How to specify unspendable keys in descriptors
    url: /en/newsletters/2024/01/03/#how-to-specify-unspendable-keys-in-descriptors

  - title: Proposed BIP specifying how to include descriptors in PSBTs
    url: /en/newsletters/2024/01/03/#descriptors-in-psbt-draft-bip

  - title: Notes from Bitcoin developer discussion about descriptors for silent payments
    url: /en/newsletters/2024/05/01/#coredev-tech-berlin-event

  - title: "BIP388 added with wallet policies for descriptor wallets"
    url: /en/newsletters/2024/05/15/#bips-1389

  - title: "BIPs #1567 adds BIP387 with new `multi_a()` and `sortedmultia_a()` descriptors"
    url: /en/newsletters/2024/05/15/#bips-1567

  - title: "BIPs 328, 390, and 373 added with specifications for MuSig2 key derivation, descriptors, and PSBTs"
    url: /en/newsletters/2024/07/05/#bips-1540

  - title: "Bitcoin Core #22838 implements multiple derivation path descriptors (BIP389)"
    url: /en/newsletters/2024/09/06/#bitcoin-core-22838

  - title: "Bitcoin Core #30708 adds `getdescriptoractivity` RPC command"
    url: /en/newsletters/2024/12/06/#bitcoin-core-30708

  - title: "Draft BIP for unspendable keys in descriptors"
    url: /en/newsletters/2025/01/24/#draft-bip-for-unspendable-keys-in-descriptors

  - title: "Bitcoin Core #31590 checks parity bits when retrieving privkeys for x-only pubkeys in descriptors"
    url: /en/newsletters/2025/01/31/#bitcoin-core-31590

  - title: "Bitcoin Core #31603 begins rejecting descriptors containing unnecessary whitespace"
    url: /en/newsletters/2025/03/28/#bitcoin-core-31603

  - title: "Proposed standard for backing up wallet descriptors"
    url: /en/newsletters/2025/04/25/#standardized-backup-for-wallet-descriptors

  - title: "New library for encrypting descriptors and miniscript to the included public keys"
    url: /en/newsletters/2025/06/13/#descriptor-encryption-library

  - title: "New library for compressing descriptors and miniscript"
    url: /en/newsletters/2025/07/11/#compressed-descriptors

  - title: "Brainstorming how to use output script descriptors for CTV-style vaults"
    url: /en/newsletters/2025/07/04/#vault-output-script-descriptor

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Miniscript
    link: topic miniscript
  - title: Partially-Signed Bitcoin Transactions (PSBTs)
    link: topic psbt
---
Descriptors combine well with [miniscript][topic miniscript] in
allowing a wallet to handle tracking and signing for a larger variety
of scripts.  They also combine well with [PSBTs][topic psbt] in
allowing the wallet to determine which keys it controls in a multisig
script.

{% include references.md %}
