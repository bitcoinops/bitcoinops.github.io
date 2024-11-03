---
title: 'Bitcoin Optech Newsletter #126'
permalink: /en/newsletters/2020/12/02/
name: 2020-12-02-newsletter
slug: 2020-12-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for using fidelity bonds on
LN to prevent denial of service attacks, summarizes a PR to address a
fee siphoning attack that could affect LN channels using anchor outputs,
and links to a proposed specification for miniscript.  Also included are
our regular sections with releases, release candidates, and recent code
changes in popular Bitcoin infrastructure software.

## Action items

*None this week.*

## News

- **Fidelity bonds for LN routing:** Gleb Naumenko and Antoine Riard
  [posted][gnar post] a to the Lightning-Dev mailing list to use *stake
  certificates* (another name for fidelity bonds) to prevent a type of
  channel jamming attack [first described in 2015][russell loop].
  These are attacks where a malicious user sends a payment to themselves
  or a confederate through a series of channels and then delays either
  accepting or rejecting the payment.  Until the payment eventually
  times out, each channel used to route the payment is unable to use
  those funds to route other user's payments.  Since a route may cross
  more than a dozen channels, that means every bitcoin controlled by the
  attacker can prevent more than a dozen bitcoins belonging to honest
  nodes from being used for honest routing. <!-- "more than a dozen" is conservative, I
  think 25 is the actual max:
  http://gnusha.org/lightning-dev/2020-11-30.log 04:42 -->

  Previously proposed solutions for this problem (and related
  problems) mostly involved upfront fees, see Newsletters
  [#72][news72 upfront], [#86][news86 upfront], [#119][news119
  upfront], [#120][news120 upfront], and [#122][news122 upfront].
  This week, Naumenko and Riard proposed that each payment include
  proof that its spender controlled some amount of bitcoin.  Each
  routing node could then publicly announce its policy on how much
  value it would route given proof of a certain stake value.  For
  example, Alice's node could announce that it would route payments up
  to 0.01 BTC from anyone who could prove they controlled at least
  1.00 BTC.  This would allow someone to route a payment through
  Alice's node but limit how much of her capital they could tie up.

  The mailing list post does note that a significant amount of work
  would need to be done to implement the idea, including the
  development of a privacy-preserving cryptographic proof.  Discussion
  of the idea is still ongoing as of this writing.

- **Proposed intermediate solution for LN `SIGHASH_SINGLE` fee theft:**
  as described in [Newsletter #115][news115 siphoning], a recent update
  to the LN specification that has not yet been widely deployed makes it
  possible for an attacker to steal a portion of the bitcoins allocated
  to paying onchain fees for LN payments (HTLCs).  This is a consequence
  of spending HTLCs with signatures using the [sighash flag][]
  `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`.

  The preferred solution to that problem is to simply not include any
  fees in HTLCs, eliminating the ability to steal fees and making the
  party who wants to claim the HTLC responsible for paying any
  necessary fees.  However, this requires an additional change to the
  LN specification that would need to be adopted by all
  implementations of [anchor outputs][topic anchor outputs].  In the
  meantime, Johan Halseth
  [posted][halseth post] to the Lightning-Dev mailing list this week
  about a [PR][LND #4795] he opened to LND that will only accept a
  payment if the maximum amount of fees a peer can steal from that
  payment (and all previously accepted pending payments) is less than the
  *channel reserve*---the minimum amount that must be kept in each
  side of a channel to serve as a penalty in case an old state is
  broadcast.  This doesn't eliminate the problem, but it does
  significantly limit the maximum loss possible.  A downside is that
  channels with only small amounts of value (and thus small reserves)
  will be limited to only forwarding a small number of HTLCs
  simultaneously.  Halseth's PR attempts to mitigate this by not
  requesting feerate increases above 10 sat/vbyte, keeping HTLC fees
  low so that the fees from several HTLCs are less likely to exceed
  reserves.

- **Formal specification of miniscript:** Dmitry Petukhov
  [published][petukhov post] a [formal specification][miniscript spec]
  of [miniscipt][topic miniscript] based on the documentation written by
  other developers.  This could help with testing implementations or in
  extending miniscript in the future.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 1.2.1][] is a maintenance release that provides compatibility
  with a recent version of Ledger's firmware and improves compatibility
  with the BitBox02.

- [Rust-Lightning 0.0.12][] is a release that updates several APIs to
  make them easier to use and adds "beta status" C/C++ bindings (see
  [Newsletter #115][news115 rl bindings]).

- [Bitcoin Core 0.21.0rc2][Bitcoin Core 0.21.0] is a release candidate
  for the next major version of this full node implementation and its
  associated wallet and other software.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #4752][] prevents the node from releasing a local payment
  preimage without a [payment secret][payment secret], contained in a
  field that is not available for passthrough payments.  The patch
  requires adding payment secrets to the invoices that LND produces.
  Payment secrets were added as part of [multipath payments][topic
  multipath payments] and requiring them provides additional protection
  against [improper preimage revelation][CVE-2020-26896] for passthrough
  payments as described in [Newsletter #121][news121 preimage] and
  [#122][news122 preimage].

{% include references.md %}
{% include linkers/issues.md issues="4752,4795" %}
[hwi 1.2.1]: https://github.com/bitcoin-core/HWI/releases/tag/1.2.1
[rust-lightning 0.0.12]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.12
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[gnar post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-November/002884.html
[russell loop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2015-August/000135.html
[news115 siphoning]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[sighash flag]: https://btcinformation.org/en/developer-guide#signature-hash-types
[halseth post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-November/002882.html
[petukhov post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-November/018281.html
[miniscript spec]: https://github.com/dgpv/miniscript-alloy-spec
[news115 rl bindings]: /en/newsletters/2020/09/16/#rust-lightning-618
[news72 upfront]: /en/newsletters/2019/11/13/#ln-up-front-payments
[news86 upfront]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[news119 upfront]: /en/newsletters/2020/10/14/#ln-upfront-payments
[news120 upfront]: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[news122 upfront]: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[CVE-2020-26896]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26896
[news121 preimage]: /en/newsletters/2020/10/28/#cve-2020-26896-improper-preimage-revelation
[news122 preimage]: /en/newsletters/2020/11/04/#c-lightning-4162
[payment secret]: https://github.com/lightningnetwork/lightning-rfc/commit/5776d2a7
