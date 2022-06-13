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

  - title: Upcoming relay policy workshop to discuss package relay and other topics
    url: /en/newsletters/2021/04/28/#call-for-topics-in-layer-crossing-workshop

  - title: "Bitcoin Core #20833 allows `testmempoolaccept` to evaluate descendant transaction chains"
    url: /en/newsletters/2021/06/02/#bitcoin-core-20833

  - title: "Bitcoin Core #21800 implements ancestor and descendant limits for mempool package acceptance"
    url: /en/newsletters/2021/08/18/#bitcoin-core-21800

  - title: Proposal of initial rules for mempool package acceptance before implementing package relay
    url: /en/newsletters/2021/09/22/#package-mempool-acceptance-and-package-rbf

  - title: "2021 year-in-review: mempool package acceptance and package relay"
    url: /en/newsletters/2021/12/22/#mpa

  - title: "Bitcoin Core #22674 adds logic for validating packages of transactions against relay policy"
    url: /en/newsletters/2022/01/05/#bitcoin-core-22674

  - title: "BIP proposed for package relay"
    url: /en/newsletters/2022/05/25/#package-relay-proposal

  - title: "Continued discussion of proposed package relay BIP"
    url: /en/newsletters/2022/06/15/#continued-package-relay-bip-discussion

## Optional.  Same format as "primary_sources" above
see_also:
  - title: CPFP fee bumping
    link: topic cpfp

  - title: LN anchor outputs
    link: topic anchor outputs
---
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

{% include references.md %}
