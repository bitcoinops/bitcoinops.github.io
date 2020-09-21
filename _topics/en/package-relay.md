---
title: Package relay

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Fee Management
  - Transaction Relay Policy

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Package relay** is a proposed feature for Bitcoin relay nodes that
  would allow them to send and receive packages of related transactions
  which would be accepted or rejected based on the feerate of the
  overall package rather than having each individual transaction in the
  package accepted or rejected based only on its own feerate.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Without package relay, it's not possible to effectively [CPFP][topic
  cpfp] fee bump a transaction that's below the minimum feerate nodes
  accept.  Nodes will reject the parent transaction for its too low
  feerate and then ignore the fee-bumping child transaction because the
  parent transaction is needed in order to validate the child.  This is
  especially problematic because the minimum feerate that a node accepts
  depends on the contents of its mempool, so a parent transaction that
  could previously be fee bumped might not be bumpable now.
  This has significant security implications for LN and other
  time-sensitive contract protocols that want to depend on CPFP fee
  bumping.

  The main obstacle to adding package relay support to the Bitcoin P2P
  protocol is ensuring that an implementation of it doesn't create any
  new vectors for denial-of-service attacks.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Package relay strawman proposal
      link: https://gist.github.com/sdaftuar/8756699bfcad4d3806ba9f3396d4e66a

    - title: Package relay design questions
      link: https://github.com/bitcoin/bitcoin/issues/14895

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: CPFP carve out suggested but package relay needed for completeness
    url: /en/newsletters/2018/12/04/#cpfp-carve-out

  - title: "Bitcoin Core #16400 refactors code in anticipation of package relay"
    url: /en/newsletters/2019/09/25/#bitcoin-core-16400

  - title: New LN attack; full solution requires package relay
    url: /en/newsletters/2020/04/29/#fn:package-relay

  - title: New BIP339 wtxid transaction announcements simplifies package relay
    url: /en/newsletters/2020/07/01/#bips-933

  - title: Discussion of solutions for attacks against LN, including package relay
    url: /en/newsletters/2020/08/05/#chicago-meetup-discussion

  - title: Change to orphan parent fetching, may be replaced by package relay
    url: /en/newsletters/2020/08/05/#bitcoin-core-19569

## Optional.  Same format as "primary_sources" above
see_also:
  - title: CPFP fee bumping
    link: topic cpfp

  - title: LN anchor outputs
    link: topic anchor outputs
---
