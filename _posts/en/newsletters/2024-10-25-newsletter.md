---
title: 'Bitcoin Optech Newsletter #326'
permalink: /en/newsletters/2024/10/25/
name: 2024-10-25-newsletter
slug: 2024-10-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes updates to a proposal for new LN
channel announcements and describes a BIP for sending silent payments
with PSBTs.  Also included are our regular sections with popular
questions and answers from the Bitcoin Stack Exchange, announcements of
new releases and release candidates, and descriptions of notable changes
to popular Bitcoin infrastructure software.

## News

- **Updates to the version 1.75 channel announcements proposal:** Elle
  Mouton [posted][mouton chanann] to Delving Bitcoin a description of
  several proposed changes to the [new channel announcements][topic
  channel announcements] protocol that will support advertising [simple
  taproot channels][topic simple taproot channels].  The most
  significant planned change is to allow the messages to also announce
  current-style P2WSH channels; this will allow nodes to later "start
  switching off the legacy protocol [...] when most of the network seems
  to have upgraded".

  Another addition, recently discussed (see [Newsletter #325][news325
  chanann]), is to allow announcements to include an SPV proof so that
  any client that has all of the headers from the most-proof-of-work
  blockchain can verify that the channel's funding transaction was
  included in a block.  Currently, lightweight clients must download an
  entire block to perform the same level of verification of a channel
  announcement.

  Mouton's post also briefly discusses allowing opt-in announcement of
  existing simple taproot channels.  Due to the current lack of support
  for announcements of non-P2WSH channels, all existing taproot channels
  are [unannounced][topic unannounced channels].  A possible feature
  that can be added to the proposal will allow nodes to signal to their
  peers that they want to convert an unannounced channel to a public
  channel.

- **Draft BIP for sending silent payments with PSBTs:** Andrew Toth
  [posted][toth sp-psbt] to the Bitcoin-Dev mailing list a draft BIP for
  allowing wallets and signing devices to use [PSBTs][topic psbt] to
  coordinate the creation of a [silent payment][topic silent payments].
  This continues the previous discussion about an earlier iteration of the
  draft BIP, see Newsletters [#304][news304 sp] and [#308][news308 sp].
  As mentioned in those earlier newsletters, a special requirement of
  silent payments over most other PSBT-coordinated transactions is that
  any change to a not-fully-signed transaction's inputs requires
  revising the outputs.

  The draft only addresses the expected most common situation where a
  signer has access to the private keys for all inputs in a transaction.
  For the less common situation of multiple signers, Toth writes that
  "this will be specified in a following BIP".

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

- [Core Lightning 24.08.2][] is a maintenance release of this popular LN
  implementation that contains a "few crash fixes and includes an
  enhancement to remember and update channel hints for payments".

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Eclair #2925][] Add support for RBF-ing splice transactions (#2925)

- [LND #9172][] cmd: allow deterministic macaroon derivation with `lncli`

- [Rust Bitcoin #2960][] Add the ChaCha20Poly1305 AEAD algorithm

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2925,9172,2960" %}
[mouton chanann]: https://delvingbitcoin.org/t/updates-to-the-gossip-1-75-proposal-post-ln-summit-meeting/1202/
[news325 chanann]: /en/newsletters/2024/10/18/#gossip-upgrade
[toth sp-psbt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cde77c84-b576-4d66-aa80-efaf4e50468fn@googlegroups.com/
[news304 sp]: /en/newsletters/2024/05/24/#discussion-about-psbts-for-silent-payments
[news308 sp]: /en/newsletters/2024/06/21/#continued-discussion-of-psbts-for-silent-payments
[core lightning 24.08.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08.2
