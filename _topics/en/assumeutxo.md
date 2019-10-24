---
title: AssumeUTXO

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Consensus Enforcement
  - P2P Network Protocol

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **AssumeUTXO** is a proposed mode for bootstrapping new full nodes
  that allows them to postpone verifying old block chain history until
  after the user is able to receive recent transactions.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Embedded in the code of the node would be a hash of the set of all
  spendable bitcoins and the conditions necessary to spend them (the
  UTXO set) as of a certain recent point in time.  Similar to the
  existing [assumevalid][] setting and other parameters used by nodes to
  converge on consensus, revisions of the assumeutxo hash would be
  checked for correctness by developers during code review.  This would
  allow operators of new nodes to
  optionally trust that hash and download a UTXO set that matches that
  hash.  For blocks produced subsequently to the UTXO set hash, the node
  would verify new blocks and update their own UTXO set like any other
  node without further trust.  As currently designed, the node would also
  download and verify older blocks in the background so that it could eventually prove that the
  hash it first started with was correct.

  [assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: AssumeUTXO proposal
      link: https://github.com/jamesob/assumeutxo-docs/tree/2019-04-proposal/proposal

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Assume valid discussion
    url: /en/newsletters/2019/04/09/#discussion-about-an-assumed-valid-mechanism-for-utxo-snapshots
    date: 2019-04-09

  - title: CoreDev.tech demo and discussion of assumeutxo
    url: /en/newsletters/2019/06/12/#assume-utxo-demo
    date: 2019-06-12

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Bitcoin Core issue #15605: AssumeUTXO discussion"
    link: https://github.com/bitcoin/bitcoin/issues/15605
  - title: "[bitcoin-dev] assumeutxo and UTXO snapshots"
    link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
---
