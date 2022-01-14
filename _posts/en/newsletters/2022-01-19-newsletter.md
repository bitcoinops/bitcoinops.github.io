---
title: 'Bitcoin Optech Newsletter #183'
permalink: /en/newsletters/2022/01/19/
name: 2022-01-19-newsletter
slug: 2022-01-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter shares the announcement of a new legal defense
fund for Bitcoin developers and summarizes some recent discussion about
the proposed `OP_CHECKTEMPLATEVERIFY` soft fork.  Also included are our
regular sections with descriptions of some recent changes to services
and client software, plus summaries of notable changes to popular
Bitcoin infrastructure software.

## News

- **Bitcoin and LN legal defense fund:** Jack Dorsey, Alex Morcos, and
  Martin White [posted][dmw legal] to the Bitcoin-Dev mailing list the
  announcement of a legal defense fund for developers working on Bitcoin,
  LN, and related technology.  The fund "is a nonprofit entity that aims
  to minimize legal headaches that discourage software developers from
  actively developing Bitcoin and related projects".

- **OP_CHECKTEMPLATEVERIFY discussion:** the proposed soft fork to add
  an [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) opcode
  to Bitcoin was discussed this week both on the Bitcoin-Dev mailing
  list and in an IRC meeting.

    - *Mailing list discussion:* Peter Todd [posted][todd ctv] several
      concerns with the proposal, including that it doesn't benefit
      nearly all Bitcoin users (as he claims previous feature-adding
      soft forks have done), that it may create new denial-of-service
      vectors, and that many of the proposed usecases for CTV are
      underspecified and (perhaps) too complicated to actually see
      widespread deployment.

        CTV author Jeremy Rubin [referenced][rubin ctv reply] updated
        code and improved documentation that may address the concerns
        about DoS attacks.  He also pointed to at least two wallets, one
        of them widely used, which plan to use at least one of the
        features CTV will provide.  As of this writing, it's unclear
        whether Rubin's reply has substantially satisfied Peter Todd's
        concerns.

    - *IRC meeting:* as announced in [Newsletter #181][news181 ctv
      meets], Rubin also hosted the first of a series of meetings to
      discuss CTV.  The [meeting log][log ##ctv-bip-review] is available
      as is a [summary][rubin meeting summary] provided by Rubin.
      Several participants in the meeting were clearly in favor of the
      proposal, but some others expressed technical skepticism at least
      partly along the same lines as Peter Todd's earlier email.  The
      next meeting is proposed to look closer at some applications for
      CTV, which may help investigate whether it does indeed provide a
      compelling usecase that will benefit a large number of Bitcoin
      users.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

FIXME:harding releases/RCs if any

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Eclair #2063][] adds support for the new `option_payment_metadata`
  invoice field added to the LN protocol in [BOLTs #912][] (see
  [Newsletter #182][news182 bolts912]), allowing invoices created by
  Eclair to now include encrypted payment metadata.  Spenders who
  understand the new field will include its payload in the payments they
  route through the network, allowing Eclair to decrypt the data and use
  it to reconstruct all the information necessary to accept the payment.
  In a future where all spenders support this feature, this will make it
  possible to use [stateless invoices][topic stateless invoices] and run
  Eclair without storing any essential invoice details in its database
  until a payment is received, eliminating wasted storage and preventing
  invoice-creation denial-of-service attacks.

- [LDK #1013][] TheBlueMatt/2021-07-warning-msgs FIXME:dongcarl maybe reference https://bitcoinops.org/en/newsletters/2022/01/12/#bolts-950

- [LND #6006][] drops the need for LND to be connected to a full node or
  a Neutrino lightweight client when all the user wants to do is sign
  transactions.  This allows the signing part of LND to be effectively
  run on a computer that isn't directly connected to the Internet.

- [Rust Bitcoin #590][] makes an API-breaking change that simplifies
  using the same [HD key material][topic bip32] with both ECDSA
  signatures and [schnorr signatures][topic schnorr signatures] (note:
  applications should use different HD keypaths with different signature
  algorithms, see [Newsletter #157][news157 p4tr bip32]).  [Rust Bitcoin
  #591][] continues the work with non-breaking changes.

- [Rust Bitcoin #669][] extends its [PSBT][topic psbt] code to add a data type for holding information about a
  partial signature (a signature that's needed to make a transaction
  valid but which is not sufficient by itself).  Previously, signatures
  were stored as just raw bytes, but the new data facilitates performing
  additional operations on the partial signature.  The PR discussion
  includes some [interesting comments][poelstra nulldummy] about whether
  signers who don't want to sign should put an empty byte vector
  (["nulldummy"][bip147]) in the PSBT.

{% include references.md %}
{% include linkers/issues.md issues="2063,912,1013,6006,590,591,669" %}
[poelstra nulldummy]: https://github.com/rust-bitcoin/rust-bitcoin/pull/669#issuecomment-1008021007
[dmw legal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019741.html
[todd ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019738.html
[rubin ctv reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019739.html
[rubin meeting summary]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019744.html
[news181 ctv meets]: /en/newsletters/2022/01/05/#bip119-ctv-review-workshops
[news182 bolts912]: /en/newsletters/2022/01/12/#bolts-912
[news157 p4tr bip32]: /en/newsletters/2021/07/14/#use-a-new-bip32-key-derivation-path
[log ##ctv-bip-review]: https://gnusha.org/ctv-bip-review/2022-01-11.log
