---
title: Block explorers

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Privacy Problems
  - Developer Tools

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Block explorers** are tools that maintain an index of transactions
  and their relationships to each other, allowing fast look up of
  information useful to wallets, users, and developers.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
  - title: Esplora open source block explorer
    link: https://github.com/Blockstream/esplora

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Modern open source block explorer
    url: /en/newsletters/2018/12/11/#modern-block-explorer-open-sourced

  - title: Esplora updated
    url: /en/newsletters/2019/03/19/#esplora-updated

  - title: "BTCPay Server #2655 improves privacy by not sending HTTP referer field to explorers"
    url: /en/newsletters/2021/07/14/#btcpay-server-2655

  - title: "Idea to use transaction lookup servers to serve unused wallet addresses"
    url: /en/newsletters/2022/10/12/#recommendations-for-unique-address-servers

  - title: "Launch of block explorer with private information retrieval capability"
    url: /en/newsletters/2022/10/19/#address-explorer-spiral-launches

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:
---
Although many users find block explorers to be a convenient way to
look up information about their own transactions, their searches may
be logged and used to associate their transactions with their IP
address, browser cookies, and other identifying information.  The
large indexes block explorers keep also aren't expected to scale well
as the size and complexity of the block chain grows.

{% include references.md %}
