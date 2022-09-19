---
title: 'Bitcoin Optech Newsletter #218'
permalink: /en/newsletters/2022/09/21/
name: 2022-09-21-newsletter
slug: 2022-09-21-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about using
`SIGHASH_ANYPREVOUT` to emulate aspects of drivechains.  Also included
are our regular sections describing recent changes to services, client
software, and popular Bitcoin infrastructure software.

## News

- **Creating drivechains with APO and a trusted setup:** Jeremy Rubin
  [posted][rubin apodc] to the Bitcoin-Dev mailing list a description
  for how a trusted setup procedure could be combined with the proposed
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] opcode to implement
  behavior similar to that proposed by [drivechains][topic sidechains].
  Drivechains are a type of sidechain where miners are normally
  responsible for keeping the sidechain funds secure (in contrast to full nodes
  which are responsible for securing funds on Bitcoin's mainchain).  Miners
  attempting to steal drivechain funds must broadcast their
  malicious intentions days or weeks in advance, giving users a chance
  to change their full nodes to enforce the rules of the sidechain.
  Drivechains are primarily proposed for inclusion into Bitcoin as a
  soft fork (see BIPs [300][bip300] and [301][bip301]), but a previous
  post to the mailing list (see [Newsletter #190][news190 dc]) described
  how some other flexible proposed additions to Bitcoin's contracting
  language could also allow the implementation of drivechains.

    In this week's post, Rubin described yet another way drivechains
    could be implemented using a proposed addition to Bitcoin's
    contracting language, in this case using `SIGHASH_ANYPREVOUT` (APO)
    as proposed in [BIP118][].  The described APO-based drivechains have
    several drawbacks compared to BIP300 but perhaps provides similar
    enough behavior that APO can be considered as enabling drivechains,
    which some individuals may consider a benefit and others may consider
    a problem.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Mempool Project launches Lightning Network explorer:**
  Mempool's open source [Lightning dashboard][mempool lightning] shows aggregate
  network statistics as well as individual node liquidity and connectivity data.

- **Federation software Fedimint adds Lightning:**
  In a recent [blog post][blockstream blog fedimint], Blockstream outlines
  updates to the [Fedimint][] federated Chaumian e-cash project, including
  Lightning Network support. The project also [announced][fedimint signet tweet]
  a public [signet][topic signet] and faucet are available.

- **Bitpay wallet improves RBF support:**
  Bitpay [improves][bitpay 12051] its [existing][bitpay 11935] support for
  sending [RBF][topic rbf] transactions by better handling bumping of
  transactions with multiple receivers.

- **Mutiny Lightning wallet announced:**
  Mutiny (previously pLN), a privacy-focused Lightning wallet that uses separate
  nodes for each channel, was [announced][mutiny wallet].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Core Lightning #5581][] adds a new event notification topic
  "block_added". Subscribing plugins get notified each time a new block
  is received from bitcoind.

- [Eclair #2418][] and [#2408][eclair #2408] add support for receiving
  payments sent with [blinded routes][topic rv routing].  A spender
  creating a blinded payment isn't provided with the identity of the
  node receiving the payment.  This may improve privacy, especially when
  used with [unannounced channels][topic unannounced channels].

- [Eclair #2416][] adds support for receiving payments requested using the
  [offers][topic offers] protocol as defined in the [proposed BOLT12][].
  This uses the recently-added support for receiving blinded payments
  (see the previous list item for Eclair #2418).

- [LND #6335][] adds a `TrackPayments` API that allows subscribing to a
  feed of all local payment attempts.  As described in the PR
  description, this can be used to collect statistical information about
  payments to help better send and route payments in the future, such as
  for a node performing [trampoline routing][topic trampoline payments].

- [LDK #1706][] adds support for using [compact block filters][topic
  compact block filters] as specified in [BIP158][] for downloading
  confirmed transactions.  When used, if the filter indicates that a block may contain
  transactions affecting the wallet, the full block of up to 4 megabytes
  is downloaded.  If it's certain the block doesn't contain any
  transactions affecting the wallet, no additional data is
  downloaded.

{% include references.md %}
{% include linkers/issues.md v=2 issues="5581,2418,2408,2416,6335,1706" %}
[rubin apodc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020919.html
[news190 dc]: /en/newsletters/2022/03/09/#enablement-of-drivechains
[proposed bolt12]: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md
[mempool lightning]: https://mempool.space/lightning
[blockstream blog fedimint]: https://blog.blockstream.com/fedimint-update/
[bitpay 12051]: https://github.com/bitpay/wallet/pull/12051
[bitpay 11935]: https://github.com/bitpay/wallet/pull/11935
[mutiny wallet]: https://bc1984.com/make-lightning-payments-private-again/
[Fedimint]: https://github.com/fedimint/fedimint
[fedimint signet tweet]: https://twitter.com/EricSirion/status/1572329210727010307
