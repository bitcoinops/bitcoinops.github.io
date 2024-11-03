---
title: 'Bitcoin Optech Newsletter #164'
permalink: /en/newsletters/2021/09/01/
name: 2021-09-01-newsletter
slug: 2021-09-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a new web-based tool for decoding and
modifying PSBTs and links to a blog post and proof-of-concept
implementation of an eltoo-based LN payment channel.  Also included are
our regular sections with information about preparing for taproot,
announcements of new software release candidates, and summaries of
notable changes to popular Bitcoin infrastructure projects.

## News

- **BIP174.org:** Alekos Filini [posted][filini bip174.org] to the Bitcoin-Dev mailing
  list about a [website][bip174.org] he and Daniela Brozzoni have
  created that decodes [PSBTs][topic psbt] into a human-readable listing of their
  fields.  The contents of the fields can be edited and re-encoded back
  into a serialized PSBT, helping developers quickly create tests for
  their BIP174 implementations.  Christopher Allen [replied][allen
  qr174] with a suggestion for the tool to also support creating QR
  codes (either standard QR codes or alternatives for handling PSBTs
  larger than 3 KB; see [Newsletter #96][news96 qr codes]).

- **Eltoo example channel:** Richard Myers previously implemented an
  example of an [eltoo][topic eltoo] channel using the Bitcoin Core
  integration tests based on AJ Towns's implementation of
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (see [Newsletter
  #63][news63 eltoo]).  As [mentioned][myers list] on the Bitcoin-Dev mailing
  list, he's now also written a [detailed blog post][myers blog] describing the
  transactions an eltoo channel could use and which, combined with his
  integration tests, allows anyone interested in eltoo to begin
  experimenting with it.  Several possible improvements to eltoo are
  also described for anyone interested in further research.

## Preparing for taproot #11: LN with taproot

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/10-ln-with-taproot.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 22.0rc3][bitcoin core 22.0] is a release candidate
  for the next major version of this full node implementation and its
  associated wallet and other software. Major changes in this new
  version include support for [I2P][topic anonymity networks] connections,
  removal of support for [version 2 Tor][topic anonymity networks] connections,
  and enhanced support for hardware wallets.

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] is a release candidate
  for a maintenance version of Bitcoin Core.  It contains several bug
  fixes and small improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core GUI #384][] adds a context menu option to copy the IP/Netmask of a peer in the
  Banned Peers Table. This helps GUI users share individual addresses from their ban list more
  easily.

  ![Screenshot of GUI Copy IP/Netmask Context Menu Option](/img/posts/2021-09-gui-copy-banned-peer.png)

- [C-Lightning #4674][] adds `datastore`, `deldatastore`, and `listdatastore`
  commands for plugins to store and manage data in the C-Lightning database.
  Also included were manual pages detailing the semantics of each command.

- [LND #5410][] allows nodes to establish direct connections to services not
  running behind [Tor][topic anonymity networks], bridging Tor-only and
  clearnet-only segments of the network.

- [LND #5621][] includes the block header of the most-work block as part
  of the `ignored` field in [ping messages][lightning ping]. The peer node
  can use this information as an additional check that their view of the block
  chain is up to date and that they haven't been [eclipsed][topic eclipse attacks] from the Bitcoin
  network. Future work could use this data source to alert the user or
  automatically take action to recover.

## Footnotes

{% include references.md %}
{% include linkers/issues.md issues="384,4674,5410,5621" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[pickhardt richter paper]: https://arxiv.org/abs/2107.05322
[news96 qr codes]: /en/newsletters/2020/05/06/#qr-codes-for-large-transactions
[bip174.org]: https://bip174.org/
[news63 eltoo]: /en/newsletters/2019/09/11/#eltoo-sample-implementation-and-discussion
[filini bip174.org]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019355.html
[allen qr174]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019356.html
[myers list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019342.html
[myers blog]: https://yakshaver.org/2021/07/26/first.html
[lightning ping]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#the-ping-and-pong-messages
