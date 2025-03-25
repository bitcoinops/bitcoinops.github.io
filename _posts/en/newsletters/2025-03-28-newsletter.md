---
title: 'Bitcoin Optech Newsletter #347'
permalink: /en/newsletters/2025/03/28/
name: 2025-03-28-newsletter
slug: 2025-03-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to allow LN to support
upfront and hold fees based on burnable outputs, summarizes discussion
about testnets 3 and 4 (including a hard fork proposal), and announces a
plan to begin relaying certain transactions containing taproot annexes.
Also included are our regular sections summarizing selected questions
and answers from the Bitcoin Stack Exchange, announcing new releases and
release candidates, and describing notable changes to popular Bitcoin
infrastructure projects.

## News

- **LN upfront and hold fees using burnable outputs:** John Law
  [posted][law fees] to Delving Bitcoin the summary of a [paper][law fee
  paper] he's written about a protocol nodes can use to charge two
  additional types of fees for forwarding payments.  An _upfront fee_
  would be paid by the ultimate spender to compensate forwarding nodes
  for temporarily using an _HTLC slot_ (one of the limited number of
  concurrent allocations available in a channel for enforcing
  [HTLCs][topic htlc]).  A _hold fee_ would be paid by any node that
  delays the settlement of an HTLC; the amount of this fee would scale with
  the length of the delay up until the maximum amount was reached at the
  time the HTLC expired.  His post and paper cite several prior
  discussions about upfront and hold fees, such as those summarized in
  Newsletters [#86][news86 reverse upfront], [#119][news119 trusted
  upfront], [#120][news120 upfront], [#122][news122 bi-directional],
  [#136][news136 more fee], and [#263][news263 dos philosophy].

  The proposed protocol builds on the ideas of Law's _offchain payment
  resolution_ (OPR) protocol (see [Newsletter #329][news329 opr]), which
  has channel co-owners each allocate 100% of the amount of funds at stake
  (so 200% total) to a _burnable output_ that either of them can
  unilaterally destroy.  The funds at stake in this case are the upfront
  fee plus the maximum hold fees.  If both parties are later satisfied
  that the protocol has been followed correctly, e.g. that all fees were
  paid correctly, they remove the burnable output from future versions
  of their offchain transactions.  If either party is unsatisfied, they
  close the channel and destroy the burnable funds.  Although the
  unsatisfied party loses funds in this case, so does the other party,
  preventing either party from benefiting from violating the protocol.

  Law describes the protocol as a solution for [channel jamming
  attacks][topic channel jamming attacks], a weakness in LN first
  described [almost a decade ago][russell loop] that allows an attacker
  to almost costlessly prevent other nodes from using some or all of
  their funds.  In a [reply][harding fee], it was noted that the
  addition of hold fees might make [hold invoices][topic hold invoices]
  more sustainable for the network.

- **Discussion of testnets 3 and 4:** Sjors Provoost [posted][provoost
  testnet3] to the Bitcoin-Dev mailing list to ask whether anyone was
  still using testnet3 now that testnet4 has been available for about
  six months (see [Newsletter #315][news315 testnet4]).  Andres
  Schildbach [replied][schildbach testnet3] with an intention to
  continue using testnet3 in the testnet version of his popular wallet
  for at least a year.  Olaoluwa Osuntokun [noted][osuntokun testnet3]
  that testnet3 has recently been much more stable than testnet4.  He
  illustrated his point by including screenshots of the
  block trees for both testnets taken from the [Fork.Observer][]
  website.  Below find our own screenshot showing the state of testnet4
  at the time of writing:

  ![Fork Monitor showing the tree of blocks on testnet4 on 2025-03-25](/img/posts/2025-03-fork-monitor-testnet3.png)

  After Osuntokun's post, Antoine Poinsot started a [separate
  thread][poinsot testnet4] to focus on the testnet4 issues.  He argues
  that the testnet4 problems are a consequence of the difficulty reset
  rule.  This rule, which only applies to testnet, allows a block to be
  valid with minimum difficulty if its header time is 20 minutes later
  than its parent block.  Provoost goes into more [detail][provoost
  testnet4] about the problem.  Poinsot proposes a testnet4 hard fork
  to remove the rule.  Mark Erhardt [suggests][erhardt testnet4] a date
  for the fork: 2026-01-08.

- **Plan to relay certain taproot annexes:** Peter Todd [announced][todd
  annex] to the Bitcoin-Dev mailing list his plan to update his Bitcoin
  Core-based node, Libre Relay, to begin relaying transactions
  containing taproot [annexes][topic annex] if they follow particular
  rules:

  - _0x00 prefix:_ "all non-empty annexes start with the byte 0x00, to
    distinguish them from [future] consensus-relevant annexes."

  - _All-or-nothing:_ "All inputs have an annex. This ensures that use
    of the annex is opt-in, preventing [transaction pinning][topic
    transaction pinning] attacks in multi-party protocols."

  The plan is based on a 2023 [pull request][bitcoin core #27926] by
  Joost Jager, which was itself based on a prior discussion started by
  Jager (see [Newsletter #255][news255 annex]).  In Jager's words, the
  previous pull request also "limit[ed] the maximum size of unstructured
  annex data to 256 bytes [...] somewhat protect[ing] participants in a
  multi-party transaction that uses the annex against annex inflation."
  Todd's version does not include this rule; he believes "the
  requirement to opt-in to annex usage should be sufficient".  If it's
  not, he describes an additional relay change that could prevent
  counterparty pinning.

  As of this writing, nobody in the current mailing list thread has
  described how they expect the annex to be used.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.0rc2][] is a release candidate for the next major
  version of the network's predominate full node.  Please see the
  [version 29 testing guide][bcc29 testing guide].

- [LND 0.19.0-beta.rc1][] is a release candidate for this popular LN
  node.  One of the major improvements that could probably use testing
  is the new RBF-based fee bumping for cooperative closes described
  below in the notable code changes section.

<!-- FIXME:harding to update Thursday -->

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31603][] descriptor: check whitespace in keys within fragments

- [Eclair #3044][] Remove amount-based confirmation scaling

- [Eclair #3026][] Support p2tr bitcoin wallet

- [LDK #3649][] Add BOLT12 support to bLIP-51 / LSPS1

- [LDK #3665][] lightning-invoice: explicitly enforce a 7089 B max length on BOLT11 invoice deser

- [LND #9610][] multi: integrate rbf changes from staging branch

- [BIPs #1792][] BIP119 language overhaul & cleanup

- [BIPs #1782][] BIP94: reformat specification section for clarity and readability

{% include snippets/recap-ad.md when="2025-04-01 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31603,3044,3026,3649,3665,9610,1792,1782,27926,8453,9559,9575,9568,1205" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[news255 annex]: /en/newsletters/2023/06/14/#discussion-about-the-taproot-annex
[news315 testnet4]: /en/newsletters/2024/08/09/#bitcoin-core-29775
[fork.observer]: https://fork.observer/
[law fees]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/
[law fee paper]: https://github.com/JohnLaw2/ln-spam-prevention
[news329 opr]: /en/newsletters/2024/11/15/#mad-based-offchain-payment-resolution-opr-protocol
[harding fee]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/4
[provoost testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9FAA7EEC-BD22-491E-B21B-732AEA15F556@sprovoost.nl/
[schildbach testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c28f8e9-d221-4633-8b71-53b4db07fa78@schildbach.de/
[osuntokun testnet3]: https://groups.google.com/g/bitcoindev/c/jYBlh24OB-Y/m/vbensqcZAwAJ
[poinsot testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/hU75DurC5XToqizyA-vOKmVtmzd3uZGDKOyXuE_ogE6eQ8tPCrvX__S08fG_nrW5CjH6IUx7EPrq8KwM5KFy9ltbFBJZQCHR2ThoimRbMqU=@protonmail.com/
[provoost testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2064B7F4-B23A-44B0-A361-0EC4187D8E71@sprovoost.nl/
[erhardt testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c6800f0-7b77-4aca-a4f9-2506a2410b29@murch.one/
[todd annex]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z9tg-NbTNnYciSOh@petertodd.org/
[russell loop]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2015-August/000135.txt
[news263 dos philosophy]: /en/newsletters/2023/08/09/#denial-of-service-dos-protection-design-philosophy
[news136 more fee]: /en/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees
[news122 bi-directional]: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[news86 reverse upfront]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[news119 trusted upfront]: /en/newsletters/2020/10/14/#trusted-upfront-payment
[news120 upfront]: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[news342 closev2]: /en/newsletters/2025/02/21/#bolts-1205
