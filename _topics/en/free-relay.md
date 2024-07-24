---
title: Free relay

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - P2P Network Protocol
  - Transaction Relay Policy

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Node operator goals include maximizing miner revenue without allowing free relay
    url: /en/newsletters/2024/01/31/#kindred-replace-by-fee

  - title: Concern about replace by feerate allowing free relay
    url: /en/newsletters/2024/02/07/#proposal-for-replace-by-feerate-to-escape-pinning

  - title: Disclosure of a free relay attack against Bitcoin Core and some other nodes
    url: /en/newsletters/2024/03/27/#disclosure-of-free-relay-attack

  - title: "Disclosure of a free relay attack exploiting differences in RBF policy"
    url: /en/newsletters/2024/07/26/#free-relay-attacks

  - title: "Discussion of free relay related to replace-by-feerate proposals"
    url: /en/newsletters/2024/07/26/#free-relay-and-replace-by-feerate

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Free relay** was a policy on early Bitcoin full nodes to allow some
  unconfirmed transactions to be relayed even if they didn't pay
  transaction fees.  That policy allowed an attacker to waste the
  bandwidth of full nodes without paying any cost, so modern full nodes
  generally try to forbid operations which don't allow miners to claim
  fees that are proportionate to the amount of relay bandwidth used.

---
Relaying full nodes relay unconfirmed transactions between each other,
consuming the bandwidth of both the sending and receiving nodes.  For
example, if there are 50,000 nodes on the P2P network, every byte of an
unconfirmed transaction is expected to consume a minimum of 50,000 bytes
of network-wide data (twice that if you count outbound and inbound data
separately).  If full nodes simply relay anything that looks like a
transaction, it would be easy for an attacker to send data to a single
node and cause the rest of the network to consume about 50,000 times as
much data.

Bitcoin Core and most other relaying full node implementations attempt
to prevent this by only relaying unconfirmed transactions if miners can
immediately include those transactions in a block and earn at least 1
sat in fees for every 1 vbyte of relayed data.  This also applies to
[replacements][topic rbf] of unconfirmed transactions: they typically
must pay at least 1 sat/vbyte more in fees than the transactions they
replace (in addition to following other rules).

{% include references.md %}
{% include linkers/issues.md issues="" %}
