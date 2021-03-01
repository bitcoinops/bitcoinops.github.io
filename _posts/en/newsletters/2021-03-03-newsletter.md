---
title: 'Bitcoin Optech Newsletter #138'
permalink: /en/newsletters/2021/03/03/
name: 2021-03-03-newsletter
slug: 2021-03-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes discussion about a desired replacement
for some of the features of the BIP70 payment protocol and summarizes
proposals for a standardized way to exchange fraud proofs for Discreet
Log Contracts (DLCs).  Also included are our regular sections describing
new software releases, available release candidates, and notable changes
to popular Bitcoin infrastructure software.

## News

- **Discussion about a BIP70 replacement:** Thomas Voegtlin started a
  [thread][voegtlin bip70 alt] on the Bitcoin-Dev mailing list about a replacement for
  some of the features of the [BIP70][] payment protocol, specifically
  the ability to receive a signed payment request.  Voegtlin wants to be
  able to prove that the address he paid was actually the address
  provided to him by the receiver (e.g. an exchange).  Charles Hill and
  Andrew Kozlik each replied with information about protocols they're
  working on.  Hill's [scheme][hill scheme] is intended for use with
  [LNURL][] but could be repurposed to serve Voegtlin's intended use
  case.  Kozlik's [scheme][kozlik scheme] is closer in spirit to BIP70
  but drops its use of [X.509 certificates][] and adds features for
  exchange-based coin swaps (e.g. trading BTC for an altcoin or
  vice-versa).

- **Fraud proofs in the v0 Discreet Log Contract (DLC) specification:**
  Thibaut Le Guilly started a [discussion][le guilly post] on the
  DLC-dev mailing list about the [goal][dlcv0 fraud proofs] to include
  fraud proofs in the version 0 DLC coordination specification.  Two
  types of fraud were discussed:

    - *Equivocation:* where an oracle signs for the same event more than
      once, producing conflicting results.  A proof of equivocation can
      be automatically verified by software without third-party trust.

    - *Lying:* where an oracle signs for an outcome that users know is
      wrong.  This will almost always depend on evidence not available
      to the user's contract software, so this type of fraud proof must
      be verified manually by the user, who can compare the original
      contract to the outcome signed by the oracle.

    Discussion participants seemed to all favor providing an
    equivocation proof, although there was some concern that it could be
    too much work for the v0 specification.  As an intermediate
    solution, it was suggested to focus on proofs of lying.  When the
    format of those proofs has been established, software can then be
    updated to take two separate proofs for the same oracle and event
    to create a proof of equivocation.

    One concern with proofs of lying was that users could be spammed by
    fake proofs, forcing users to either waste their time verifying
    false proofs or give up checking fraud proofs altogether.
    Counterarguments included being able to get part of the proof from
    an onchain transaction (which requires that someone paid an onchain
    fee) and also that users could choose where they download fraud
    proofs from, preferring to get them from a source that was known for
    only propagating accurate information.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #16546][] introduces a new signer interface, allowing Bitcoin
  Core to interact with external hardware signing devices through the
  [HWI][topic hwi] or any other application which implements the same interface.

    Bitcoin Core has been able to interface with hardware signers using HWI
    [since Bitcoin Core version 0.18][hwi release]. Until this PR, however, [the
    process][hwi old process] required use of the command line to transfer
    data between Bitcoin Core and HWI. This PR simplifies the user experience
    by enabling Bitcoin Core to directly communicate with HWI. The PR includes
    [full documentation][hwi new process] on how to use the new signer interface
    along with HWI.

    The new signer interface is currently only accessible through RPC methods. A
    [draft PR][signer gui] adds support for the signer interface to the GUI,
    allowing the use of hardware signers with Bitcoin Core without any use of
    the command line.

- [Rust-Lightning #791][] SPV client utility for syncing a lightning node FIXME:dongcarl

- [Rust-Lightning #794][] Add support for `opt_shutdown_anysegwit` feature #780 FIXME:jonatack

- [HWI #413][], [#469][hwi #469], [#463][hwi #463], [#464][hwi #464],
  [#471][hwi #471], [#468][hwi #468], and [#466][hwi #466] significantly
  update and extend HWI's documentation.  Particularly notable changes
  include a link to the documentation on [ReadTheDocs.io][hwi rtd], new
  and updated [examples][hwi examples], and a new [policy][hwi policy]
  that describes the criteria new devices must meet for HWI to consider
  supporting them.

- [Rust Bitcoin #573][] adds a new method
  `SigHashType::from_u32_standard` that ensures the provided sighash
  byte is one of [standard values][sighash types] that Bitcoin Core will
  relay and mine by default.  Each signature's sighash byte indicates
  what parts of the transaction need to be signed.  Bitcoin's consensus
  rules dictate that non-standard sighash values are treated as
  equivalent to `SIGHASH_ALL`, but the fact that they aren't relayed or
  mined by default can theoretically be used to trick software using
  offchain commitments into accepting an unenforceable payment.
  Developers of such software using Rust-Bitcoin may which to switch to
  this new method from the `SigHashType::from_u32` method that accepts
  any consensus-valid sighash byte.

- [BIPs #1069][] updates [BIP8][] to allow for a configurable activation threshold
  and to include 90% as a recommendation, down from 95% previously, based on the
  most recent [taproot activation discussion][news137 taproot activation].

{% include references.md %}
{% include linkers/issues.md issues="16546,573,791,794,413,469,463,464,471,468,466,1069" %}
[voegtlin bip70 alt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018443.html
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[hill scheme]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018446.html
[kozlik scheme]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018448.html
[le guilly post]: https://mailmanlists.org/pipermail/dlc-dev/2021-February/000020.html
[dlcv0 fraud proofs]: https://github.com/discreetlogcontracts/dlcspecs/blob/master/v0Milestone.md#simple-fraud-proofs-in-progress
[hwi old process]: https://github.com/bitcoin-core/HWI/blob/7b34fc72c5b2c5af216d8b8d5cd2d2c92b6d2457/docs/examples/bitcoin-core-usage.rst
[hwi release]: /en/newsletters/2019/05/07/#basic-hardware-signer-support-through-independent-tool
[hwi new process]: https://github.com/bitcoin/bitcoin/blob/master/doc/external-signer.md
[signer gui]: https://github.com/bitcoin-core/gui/pull/4
[hwi rtd]: https://hwi.readthedocs.io/en/latest/?badge=latest
[hwi examples]: https://hwi.readthedocs.io/en/latest/examples/index.html
[hwi policy]: https://hwi.readthedocs.io/en/latest/devices/index.html#support-policy
[X.509 certificates]: https://en.wikipedia.org/wiki/X.509
[sighash types]: https://btcinformation.org/en/developer-guide#signature-hash-types
[news137 taproot activation]: /en/newsletters/2021/02/24/#taproot-activation-discussion
