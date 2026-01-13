---
title: 'Bitcoin Optech Newsletter #388'
permalink: /en/newsletters/2026/01/16/
name: 2026-01-16-newsletter
slug: 2026-01-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a discussion of incremental mutation testing in
Bitcoin Core and announces deployment of a new BIP process.  Also included are
our regular sections announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.

## News

- **An overview of incremental mutation testing in Bitcoin Core**: Bruno Garcia
  [posted][mutant post] to Delving Bitcoin about his current work on improving
  [mutation testing][news320 mutant] in Bitcoin Core. Mutation testing is a technique that allows
  developers to assess the effectiveness of their tests by intentionally adding
  systemic bugs, called mutants, to the codebase. If a test fails, the mutant is
  considered "killed", signaling that the test is able to catch the fault; otherwise,
  it survives, revealing a potential issue in the test.

  Mutation testing has provided significant results, leading to PRs being opened
  to address some reported mutants. However, the process is resource-intensive,
  taking more than 30 hours to complete on a subset of the codebase.
  This is the reason why Garcia is currently focusing on incremental mutation
  testing, a technique that applies mutation testing progressively, focusing only on
  parts of the codebase that have changed since the last analysis.
  While the approach is faster, it still takes too much time.

  Thus, Garcia is working on improving the efficiency of Bitcoin Core's incremental
  mutation testing, following a [paper][mutant google] by Google. The approach is based on the
  following principles:

  - Avoiding bad mutants, such as those syntactically different from
    the original program but semantically identical. This means those that will always behave in
    the same way regardless of the input.

  - Collecting feedback from developers to refine mutant generation, to understand where
    mutations tend to provide unhelpful results.

  - Report only a limited number of unkilled mutants (7, according to Google's
    research), to not overwhelm developers with possibly low-informative mutants.

  Garcia tested his approach on eight different PRs, gathering feedback and suggesting
  changes to address mutants.

  To conclude, Garcia asked Bitcoin Core contributors to notify him on their PRs in case they
  wanted a mutation test run and to report feedback on the provided mutants.


## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-01-20 17:30" %}
{% include references.md %}
[mutant post]: https://delvingbitcoin.org/t/incremental-mutation-testing-in-the-bitcoin-core/2197
[news320 mutant]:/en/newsletters/2024/09/13/#mutation-testing-for-bitcoin-core
[mutant google]: https://research.google/pubs/state-of-mutation-testing-at-google/
