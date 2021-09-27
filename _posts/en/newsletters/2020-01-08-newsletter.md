---
title: 'Bitcoin Optech Newsletter #79'
permalink: /en/newsletters/2020/01/08/
name: 2020-01-08-newsletter
slug: 2020-01-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the final week of the organized
taproot review, describes a discussion about coinjoin mixing without
either equal value inputs or outputs, and mentions a proposal to encode
output script descriptors in end-user interfaces.  Also included is our
regular section about notable changes to popular Bitcoin infrastructure
projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- Bitcoin Optech is planning to hold a third Schnorr and Taproot
  seminar workshop in London on February 5th 2020. This will cover
  the same material as the previous two [Schnorr/Taproot workshops][],
  which is available on this website for home study.

  **Member companies who would like to send engineers to the workshop should
  [email Optech][optech email]**.

## News

- **Final week of organized taproot review:** December 17th was the
  final scheduled [meeting][taproot meeting] of the taproot review
  group.  Pieter Wuille posted the [slides][wuille slides] from a
  presentation he gave summarizing progress, including text indicating
  he thought the proposal was "nearly ready".  Wuille also proposed a
  [minor change][wuille suggestion] to the tapleaf versioning.  Also
  briefly mentioned was the [discussion][zmn post] started by ZmnSCPxj
  on the Lightning-Dev mailing list about how precisely taproot could be
  integrated with LN to provide improved privacy and scalability.

- **Coinjoins without equal value inputs or outputs:** Adam Ficsor
  (nopara73) started a [discussion][ficsor non-equal] on the Bitcoin-Dev
  mailing list about two previously-published papers ([1][cashfusion],
  [2][knapsack]) describing coinjoins that didn't use either equal-value
  inputs or outputs.  Previous attempts at non-equal mixes were [easy to
  compromise][coinjoin sudoku], but if an improved method was found, it
  could significantly improve the privacy of coinjoins by making their
  transactions look like [payment batching][topic payment batching].  This seemed especially
  relevant after reports that a popular exchange was investigating users
  participating in the chaumian-style coinjoins created by Wasabi
  Wallet.  Although several ideas were discussed, we think the [summary][ontivero summary]
  by Lucas Ontivero captures the essence of the overall conclusion: "In
  summary, unequal inputs/outputs coinjoins [knapsack][] is the best we
  have at the moment ([but] it is not as effective as equal-outputs
  transactions)."

- **Encoded descriptors:** Chris Belcher [asked][belcher descriptors]
  for feedback from the Bitcoin-Dev mailing list about base64 encoding
  [output script descriptors][topic descriptors] so that they're easier
  to copy and paste (and also so that regular users aren't exposed to
  their code-like syntax).  At least one reply was opposed to the idea
  and other replies which did support the idea each proposed a different
  encoding format.  The discussion to date did not come to any
  clear conclusion.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #3351][] extends the `invoice` RPC with a new
  `exposeprivatechannels` parameter that allows the user to request
  the addition of route hints for private channels to a generated [BOLT11][]
  invoice.  The user may optionally specify which channels they want to
  advertise in the invoice, including both public and private channels.

- [LND #3647][] switches from using base64 to hex for the display of
  binary data in the `listinvoices` RPC.  This is a breaking API change for users of any
  of the updated fields.

- [LND #3814][] allows the UTXO sweeper to add wallet inputs to a
  sweep transaction in order to ensure its output meets the dust limit.
  This is designed to help support the proposed anchor outputs feature
  (see [Newsletter #70][news70 anchor]) which will need to add inputs to
  a transaction in order to be able to spend low-value UTXOs.

{% include linkers/issues.md issues="3647,3814,3351" %}
[Schnorr/Taproot workshops]: /en/schorr-taproot-workshop/
[wuille slides]: https://prezi.com/view/AlXd19INd3isgt3SvW8g/
[wuille suggestion]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-12-17-19.01.log.html#l-8
[zmn post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002375.html
[ficsor non-equal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017538.html
[cashfusion]: https://github.com/cashshuffle/spec/blob/master/CASHFUSION.md
[knapsack]: https://www.comsys.rwth-aachen.de/fileadmin/papers/2017/2017-maurer-trustcom-coinjoin.pdf
[coinjoin sudoku]: http://www.coinjoinsudoku.com/
[belcher descriptors]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017529.html
[news70 anchor]: /en/newsletters/2019/10/30/#ln-simplified-commitments
[taproot meeting]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-12-17-19.01.html
[ontivero summary]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017544.html
