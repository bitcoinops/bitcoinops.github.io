---
title: Wallet labels

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Backup and Recovery
  - Wallet Collaboration Tools

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP329 wallet labels export format
      link: BIP329

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "LND #4228 adds a new `labeltx` wallet command"
    url: /en/newsletters/2020/06/03/#lnd-4228

  - title: "Bitcoin Core #19651 allows the wallet key manager to edit labels among other data"
    url: /en/newsletters/2021/07/07/#bitcoin-core-19651

  - title: Proposed BIP for a wallet label export format
    url: /en/newsletters/2022/08/31/#wallet-label-export-format

  - title: "BIPs #1383 assigns BIP329 to the proposal for a standard wallet label export format"
    url: /en/newsletters/2023/01/25/#bips-1383

  - title: "Sparrow’s 1.7.2 release adds BIP329 import and export"
    url: /en/newsletters/2023/02/15/#sparrow-wallet-1-7-2-released

  - title: "BTCPay Server #4799 allows export wallet labels as specified in BIP329"
    url: /en/newsletters/2023/04/05/#btcpay-server-4799

  - title: "BIPs #1412 updates BIP329 wallet label export with support for key origin information"
    url: /en/newsletters/2023/05/24/#bips-1412

  - title: "Nunchuk wallet adds BIP329 wallet label export"
    url: /en/newsletters/2023/05/24/#nunchuk-adds-coin-control-bip329-support

  - title: " BIPs #1452 updates BIP329 with a new optional spendable tag"
    url: /en/newsletters/2023/07/05/#bips-1452

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Output script descriptors
    link: topic descriptors

  - title: Output linking
    link: topic output linking

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Wallet labels** are descriptions of addresses, transactions, and
  other information which help a user understand their past transaction
  history.  Labels are not communicated to parties unrelated
  to the address or transaction, and they're not stored in any public
  information source (like the block chain).
---

{% include references.md %}
{% include linkers/issues.md issues="" %}
