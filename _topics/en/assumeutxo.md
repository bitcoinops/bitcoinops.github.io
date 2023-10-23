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

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: AssumeUTXO proposal
      link: https://github.com/jamesob/assumeutxo-docs/tree/2019-04-proposal/proposal

    - title: AssumeUTXO project tracker
      link: https://github.com/bitcoin/bitcoin/pull/27596

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Assume valid discussion
    url: /en/newsletters/2019/04/09/#discussion-about-an-assumed-valid-mechanism-for-utxo-snapshots

  - title: CoreDev.tech demo and discussion of assumeutxo
    url: /en/newsletters/2019/06/12/#assume-utxo-demo

  - title: "2019 year-in-review: AssumeUTXO"
    url: /en/newsletters/2019/12/28/#assumeutxo

  - title: Review Club summary of MuHash implementation for quickly hashing UTXO set
    url: /en/newsletters/2020/11/11/#bitcoin-core-pr-review-club

  - title: MuHash function added in preparation for tracking UTXO state hashes
    url: /en/newsletters/2021/01/13/#bitcoin-core-19055

  - title: "Bitcoin Core #19521 simplifies generating UTXO set hashes for old blocks"
    url: /en/newsletters/2021/05/05/#bitcoin-core-19521

  - title: "Bitcoin Core #23155 extends the `dumptxoutset` RPC with new information"
    url: /en/newsletters/2021/12/08/#bitcoin-core-23155

  - title: "Bitcoin Core #25740 allows background validation of bootstrapped UTXO state"
    url: /en/newsletters/2023/03/15/#bitcoin-core-25740

  - title: Summaries of Bitcoin Core developers in-person meeting
    url: /en/newsletters/2023/05/17/#summaries-of-bitcoin-core-developers-in-person-meeting

  - title: "Bitcoin Core #27596 adds assumedvalid snapshot chainstate and full validation sync in the background"
    url: /en/newsletters/2023/10/11/#bitcoin-core-27596

  - title: Bitcoin Core bug found in computation of UTXO set hash
    url: /en/newsletters/2023/10/25/#bitcoin-utxo-set-summary-hash-replacement

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "Bitcoin Core issue #15605: AssumeUTXO discussion"
    link: https://github.com/bitcoin/bitcoin/issues/15605

  - title: "[bitcoin-dev] assumeutxo and UTXO snapshots"
    link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
---
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

{% include references.md %}
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
