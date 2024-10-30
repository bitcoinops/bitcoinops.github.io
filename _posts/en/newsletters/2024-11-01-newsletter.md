---
title: 'Bitcoin Optech Newsletter #327'
permalink: /en/newsletters/2024/11/01/
name: 2024-11-01-newsletter
slug: 2024-11-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for timeout tree channel
factories and summarizes a draft BIP for proofs of discrete log
equivalence to be used when generating silent payments.  Also included
are our regular sections with announcements of new software releases and
descriptions of notable changes made to popular Bitcoin infrastructure
software.

## News

- **Timeout tree channel factories:** ZmnSCPxj [posted][zmnscpxj post1]
  to Delving Bitcoin and [discussed][deepdive] with Optech contributors a
  proposal for a new multi-layer [channel factory][topic channel
  factories] design named _SuperScalar_.  A goal of the design is to
  provide a construction that could be easily implemented by a single
  vendor without waiting for large protocol changes that require
  widespread agreement.  For example, a Lightning service provider (LSP)
  that distributes wallet software could allow its users to more cheaply
  open channels and receive inbound liquidity without sacrificing
  LN's trustlessness.

  The overall construction is based on a _timeout tree_, where a
  _funding transaction_ pays to a tree of pre-defined child transactions
  that are ultimately spent offchain into many separate
  payment channels.  After a configurable timeout (e.g. a month), some
  of the parties involved in the timeout tree forfeit any of their funds
  remaining in the tree---this incentivizes them to withdraw or find
  alternative security for those funds before the expiry, which can
  encourage the use of cheap offchain mechanisms rather than publishing
  parts of the tree onchain.  In previously described timeout trees (see
  [Newsletter #270][news270 timeout trees]), user funds that timed out
  became the property of a service provider, but ZmnSCPxj reverses this
  and makes a service provider's timed-out funds become the property of
  the users---this places the burden of getting transactions confirmed
  on the service provider rather than end users.

  The timeout trees used require each involved party to contribute a
  signature.  This avoids the need for consensus changes but limits the
  practical maximum number of users in a factory due to the well-known
  [multi-signer coordination problem][news270 coordination].

  Most of the leaves of the timeout tree are offchain funding
  transactions for the common type of channel used today ([LN-Penalty][]),
  allowing some reuse of existing code for managing LN channels.  The
  counterparties in each channel are an end user and the Lightning
  service provider (LSP) who created the timeout tree.  Some of the
  leaves of the tree may also be exclusively controlled by the LSP for
  the purpose of rebalancing funds.

  Between the root and the leaves are [duplex micropayment
  channels][topic duplex micropayment channels].  Unlike LN-Penalty
  channels, duplex channels allow more than two parties to safely share
  funds; however, they also only allow a relatively small number of
  state updates compared to LN-Penalty's effectively unlimited number of
  updates.  The intermediate duplex channels are used to allow
  rebalances involving the LSP and two end users; these rebalances could
  securely complete at offchain speeds, allowing a user to receive
  an incoming payment almost instantly even if they didn't previously
  have enough capacity in their channel to accept it.

  In a [later post][zmnscpxj post2], ZmnSCPxj described replacing part
  of a duplex channel with a [Spillman-style][spillman channel]
  (simplex) micropayment channel.  This would be more efficient onchain
  in the case of a cooperative close, although it would be less
  efficient onchain in the case of a unilateral close.

  The proposal received a moderate amount of discussion.  The author
  said that one of the weaknesses of the proposal is its technical
  complexity due to the use of multiple different channel types plus the
  inherent challenge in any channel factory design of managing
  additional offchain state.  However, the proposal has the advantage of being
  something that could be implemented by a single team and made
  interoperable with the standard LN without requiring many changes to
  the LN protocol.

- **Draft BIP for DLEQ proofs:** Andrew Toth [posted][toth dleq] to the
  Bitcoin-Dev mailing list a draft BIP and a link to an
  [implementation][dleq imp] for generating and verifying proofs of
  [discrete log equality][topic dleq] (DLEQ) for the elliptic curve used by
  Bitcoin (secp256k1).  A DLEQ allows a party to prove that they know a
  private key without revealing anything about it, such as its
  corresponding public key.  This has been used in the past to allow
  someone to prove that they own a UTXO without revealing which UTXO
  (see Newsletters [#83][news83 podle] and [#131][news131 podle]).

  The current BIP is motivated by support for [silent payments][topic
  silent payments] created using multiple independent signers.  If one
  signer lies or is faulty, it's possible for funds to be lost.  A DLEQ
  allows each signer to prove that they signed correctly without
  revealing their private keys to the other signers.  See [Newsletter
  #308][news308 sp] for previous discussion.

  The proposal received a [reply][gibson dleq] from Adam Gibson, who
  previously implemented a DLEQ proof system for the JoinMarket
  [coinjoin][topic coinjoin] implementation.  He suggested several
  changes that would make the BIP's version of DLEQ more flexible for
  other uses beyond silent payments.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [BTCPay Server 2.0.0][] is the latest release of this self-hosted
  payment processor.  It's new features includes "improved localization,
  sidebar navigation, improved onboarding flow, improved branding
  options, support for pluginable rate providers" and more.  The upgrade
  includes some breaking changes and database migrations; it is
  recommended to read the [announcement][btcpay post] before upgrading.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31130][] Drop miniupnp dependency

- [LDK #3007][] Serialize blinded Trampoline hops

- [BIPs #1676][] scgbckbone/bip85_final

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31130,3007,1676" %}
[news83 podle]: /en/newsletters/2020/02/05/#podle
[news131 podle]: /en/newsletters/2021/01/13/#ln-dual-funding-anti-utxo-probing
[news308 sp]: /en/newsletters/2024/06/21/#continued-discussion-of-psbts-for-silent-payments
[zmnscpxj post1]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[deepdive]: /en/podcast/2024/10/31/
[news270 timeout trees]: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability
[zmnscpxj post2]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143/16
[spillman channel]: https://en.bitcoin.it/wiki/Payment_channels#Spillman-style_payment_channels
[toth dleq]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b0f40eab-42f3-4153-8083-b455fbd17e19n@googlegroups.com/
[dleq imp]: https://github.com/BlockstreamResearch/secp256k1-zkp/blob/master/src/modules/ecdsa_adaptor/dleq_impl.h
[gibson dleq]: https://mailing-list.bitcoindevs.xyz/bitcoindev/77ad84ed-2ff8-4929-b8da-d940c95d18a7n@googlegroups.com/
[news270 coordination]: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability
[ln-penalty]: https://en.bitcoin.it/wiki/Payment_channels#Poon-Dryja_payment_channels
[btcpay post]: https://blog.btcpayserver.org/btcpay-server-2-0/
[btcpay server 2.0.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.0
