---
title: Generic signmessage

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Signmessage
  - BIP322

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Wallet Collaboration Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Generic signmessage** is a method that allows wallets to sign or
  partially sign a message for any script from which they could
  conceivably spend.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP322
    - title: Bitcoin Core PR#16440
      link: https://github.com/bitcoin/bitcoin/pull/16440

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: BIP322 proposed
    url: /en/newsletters/2018/09/18/#bip322-generic-signed-message-format

  - title: "2018 year-in-review: initial discussion that became BIP322"
    url: /en/newsletters/2018/12/28/#march

  - title: Bitcoin Core PR opened for BIP322 signmessage support
    url: /en/newsletters/2019/07/31/#pr-opened-for-bip322-generic-signed-message-format

  - title: Searching for a bech32 signmessage format
    url: /en/bech32-sending-support/#bip322
    date: 2019-07-10

  - title: Additional request for feedback on BIP322 generic signmessage
    url: /en/newsletters/2020/03/11/#bip322-generic-signmessage-progress-or-perish

  - title: Proposed update to BIP322 generic signmessage
    url: /en/newsletters/2020/04/01/#proposed-update-to-bip322-generic-signmessage

  - title: "Simplified BIP322, only allowing signatures from one script per proof"
    url: /en/newsletters/2020/05/06/#bips-903

  - title: Alternative proposal for generic signmessage using virtual transactions
    url: /en/newsletters/2020/10/07/#alternative-to-bip322-generic-signmessage

  - title: BIP322 updated to use virtual transactions
    url: /en/newsletters/2020/10/28/#bips-1003

  - title: "2020 year in review: generic signmessage"
    url: /en/newsletters/2020/12/23/#generic-signmessage

  - title: "Proposed rewrite of BIP322 to simplify implementation"
    url: /en/newsletters/2021/01/06/#proposed-updates-to-generic-signmessage

  - title: "BIPs #1048 rewrites BIP322 to simplify implementation"
    url: /en/newsletters/2021/02/10/#bips-1048

  - title: "Preparing for taproot: generic signmessage still needed"
    url: /en/newsletters/2021/09/29/#preparing-for-taproot-15-signmessage-protocol-still-needed

  - title: "BIPs #1279 updates BIP322 with clarifications and test vectors"
    url: /en/newsletters/2022/02/16/#bips-1279

  - title: "Proposed BIP for multiformat single-sig message signing"
    url: /en/newsletters/2022/07/27/#multiformat-single-sig-message-signing

  - title: "Sparrow 1.7.8 adds support for BIP322 generic signmessage"
    url: /en/newsletters/2023/08/23/#sparrow-1-7-8-released

  - title: "Bitcoin Knots 28.1 adds support for BIP322 generic signmessage"
    url: /en/newsletters/2025/04/18/

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
The [BIP322][] *generic signed message format* allows a wallet to sign
a text string by producing a
signature for a virtual Bitcoin transaction.  This means a signed message can
be produced for any script or address that a wallet would be able to
spend.  Additionally, two or more wallets can cooperate to create a
BIP322 signed message for multisig scripts.

When signing for legacy P2PKH addresses, BIP322 instead uses the
traditional `signmessage` format that was first implemented in an
early version of the Bitcoin software, making the proposal backwards
compatible with existing software that verifies signed messages for
P2PKH addresses.

{% include references.md %}
