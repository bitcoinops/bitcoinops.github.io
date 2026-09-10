---
title: 'Bitcoin Optech Newsletter #422'
permalink: /en/newsletters/2026/09/11/
name: 2026-09-11-newsletter
slug: 2026-09-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed protocol for probabilistic
coinjoins disguised as covert bets and summarizes benchmarks of a silent
payments indexing server against compact block filters for light clients.
Also included are our regular sections announcing new releases and release
candidates and describing notable changes to popular Bitcoin infrastructure
software.

## News

- **A protocol for probabilistic coinjoin and covert betting**: Adam Gibson
  [posted][bab del] to Delving Bitcoin about Babilonia, a proposal for a
  new probabilistic [coinjoin][topic coinjoin] and covert betting protocol.
  The idea behind the proposal is to provide privacy-seeking behavior with
  plausible deniability. Instead of recognizable actions, which can be
  tracked, flagged, and criminalized, Gibson proposes a covert betting protocol,
  where users participate in order to break the common input ownership heuristic.
  The bet resembles an onchain coin flip where money changes hands,
  but to the outside looks like a normal payment.

  The protocol, described in a [paper][bab paper], works like this:
  - Alice and Bob provide their inputs to build a shared UTXO. They also sign
      a refund transaction, that gives the funds back to the owners in case of
      a long timeout, and a payout transaction, to settle the bet.

  - Alice generates two secret numbers `a_1` and `a_2`, picking one as her choice,
      and publishes the corresponding public keys `A_1` and `A_2`.

  - Bob picks one as his guess and constructs a public key `K` that can only be
      spent in case his and Alice's choices are the same.

  - The payout transaction sends the funds to an output spendable by `K`. Alice signs
      that transaction with a partial [adaptor signature][topic adaptor signatures].
      After Bob signs with his partial signature and the funding transaction confirms,
      Alice provides the adaptor's hidden secret out-of-band, letting Bob decrypt her
      chosen number. If he won, he completes and broadcasts the payout transaction
      to claim the funds.

  According to the author, multiple rounds of the protocol would statistically
  allow users to maintain their initial funds, minus fees, while improving their privacy.
  This is true on average, but may deviate for individual users.
  However, in the paper Gibson states that there is still no clear measure of the actual
  efficacy of the protocol. In a follow-up post, Gibson noted that a single bet
  leaks its size, since the winner's payout is an integer multiple of their
  contribution to the pot, and released a second version of the paper that
  splits each bet into several unequal sub-bets.

- **Update on silent payments light clients**: Rob Segers [posted][sp light ml]
  to the Bitcoin-Dev mailing list about updates to an older discussion on Delving
  Bitcoin (see [Newsletter #305][news305 sp light]). That discussion, that stalled
  in June 2024, was focused on providing specifications for
  [silent payments][topic silent payments] light clients and measuring performance
  of different ways to retrieve data from blocks.

  Segers ran an instance of [BlindBit Oracle v2][blindbit gh], an implementation of
  the [BIP352][] indexing server which drops filters completely and instead streams
  per-output data (txid, tweak, and 8-byte output prefix), and compared its performance
  against [BIP158 compact block filters][topic compact block filters] and
  [taproot][topic taproot]-only filters. The comparison was done on unsampled block data
  from taproot activation until block 965,089 (a total of 255,434 blocks).
  [Results][results gh] show that the BlindBit Oracle approach downloads about 2.1x
  as many bytes as a taproot-only filter plus the raw tweak data a filter client still
  needs, not counting the full block a filter client must fetch on each match,
  in exchange for no false positives and no per-match block fetches.

  Segers also noted that a light client currently cannot tell whether a server
  omitted a tweak for a block, which would silently lose the receiver money. His
  server publishes per-block commitments over the sorted tweak set and
  checkpoints them to nostr every six hours, making omissions attributable after
  the fact, although clients should still fetch the full block on a match.

  Finally, Segers noted that the new version of the BlindBit Oracle had drifted severely from
  the original specifications. Thus, the author provided a [convergence draft][sp light draft]
  which is up for discussion.

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

{% include snippets/recap-ad.md when="2026-09-15 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[bab del]: https://delvingbitcoin.org/t/babilonia-probabilistic-coinjoin-and-covert-betting/2704
[bab paper]: https://github.com/AdamISZ/babilonia-paper
[sp light ml]: https://groups.google.com/g/bitcoindev/c/qqDYHnnoM7k
[news305 sp light]: /en/newsletters/2024/05/31/#light-client-protocol-for-silent-payments
[blindbit gh]: https://github.com/setavenger/blindbit-oracle
[results gh]: https://github.com/bitsagarob/silentpayments-measurements
[sp light draft]: https://github.com/bitsagarob/silentpayments-measurements/blob/master/LIGHT-CLIENT-PROTOCOL-DRAFT.md
