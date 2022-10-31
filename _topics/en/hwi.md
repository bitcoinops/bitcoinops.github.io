---
title: Hardware wallet interface (HWI)
shortname: hwi

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Wallet Collaboration Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Hardware Wallet Interface (HWI)** is a Python library and command-line tool used
  to interface with hardware wallets using Partially-Signed Bitcoin
  Transactions (PSBTs) and output script descriptors.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: HWI repository
      link: https://github.com/bitcoin-core/HWI

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Bitcoin Core preliminary hardware wallet support
    url: /en/newsletters/2019/02/19/#bitcoin-core-preliminary-hardware-wallet-support

  - title: Bitcoin Core 0.18 with basic hardware signer support
    url: /en/newsletters/2019/05/07/#basic-hardware-signer-support-through-independent-tool

  - title: "CoreDev.tech discussions: HWI integration into Bitcoin Core"
    url: /en/newsletters/2019/06/12/#hwi

  - title: "2019 year-in-review: HWI"
    url: /en/newsletters/2019/12/28/#core-hwi

  - title: BTCPay Vault using HWI for signing
    url: /en/newsletters/2020/02/19/#btcpay-vault-using-hwi-for-signing

  - title: Fix for segwit fee overpayment attack affects HWI compatibility
    url: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions

  - title: Initial release of Lily Wallet supports HWI
    url: /en/newsletters/2020/07/22/#lily-wallet-initial-release

  - title: "HWI #363 adds support for Bitbox02 hardware wallet"
    url: /en/newsletters/2020/09/09/#hwi-363

  - title: "Significantly updated and extended HWI documentation"
    url: /en/newsletters/2021/03/03/#hwi-413

  - title: "Bitcoin Core #16546 adds external signer interface compatible with HWI"
    url: /en/newsletters/2021/03/03/#bitcoin-core-16546

  - title: "Bitcoin Core GUI #4 adds initial support for using HWI external signers via the GUI"
    url: /en/newsletters/2021/06/16/#bitcoin-core-gui-4

  - title: "HWI #475 adds support for the Blockstream Jade hardware signer"
    url: /en/newsletters/2021/12/01/#hwi-475

  - title: "BDK #682 adds signing capabilities for hardware signing devices using HWI and rust-hwi"
    url: /en/newsletters/2022/09/07/#bdk-682

  - title: "Bitcoin Core #23578 using HWI to add support for externally signing taproot keypath spends"
    url: /en/newsletters/2022/11/02/#bitcoin-core-23578

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Partially-Signed Bitcoin Transactions (PSBTs)
    link: topic psbt
---
Designed primarily by Bitcoin Core developers to allow that software to
use hardware wallets as external signers, HWI is now being used by
other wallets as well.

{% include references.md %}
