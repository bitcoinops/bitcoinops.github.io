---
title: 'Bitcoin Optech Newsletter #98'
permalink: /en/newsletters/2020/05/20/
name: 2020-05-20-newsletter
slug: 2020-05-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter relays a request for comments on a proposed
change to the BIP341 taproot transaction digest and briefly summarizes
discussion about a new and more concise protocol for atomic swaps.  Also
included are our regular sections describing changes to services and
client software, new releases and release candidates, and notable
changes to popular Bitcoin infrastructure software.

## Action items

- **Evaluate proposed changes to BIP341 taproot transaction digest:** as
  described in [last week's newsletter][news97 spk commit], there has
  been a request for [taproot][topic taproot] signatures to make an
  additional commitment to the scriptPubKeys of all the UTXOs being
  spent in a transaction.  Anthony Towns has [suggested][towns
  suggestion] how [BIP341][] might be updated for this change and Pieter
  Wuille has [asked][wuille rfc] whether anyone has any objections.  If
  you have any questions or concerns about the proposed transaction
  digest revision, we suggest either replying to the mailing list or
  contacting the BIP341 authors directly.

## News

- **Two-transaction cross chain atomic swap or same-chain coinswap:**
  Ruben Somsen [posted][somsen post] to the Bitcoin-Dev mailing list and
  [created a video][somsen video] describing a procedure for a trustless
  exchange of coins using only two transactions, named Succinct Atomic
  Swaps (SAS).  The [previous standard protocol][nolan swap] uses four
  transactions.  Somsen's SAS protocol leaves each party holding coins
  that they can spend at any time---but which they may need to spend on
  short notice if their counterparty attempts theft (similar to how LN
  channels need to be monitored).  Additionally the keys necessary to
  spend the coins won't be contained in the user's [BIP32][] HD wallet,
  so additional backups may be required.

  Advantages of the protocol are that it requires less block space
  than existing protocols, it saves on transaction fees (both by using
  less block space and potentially by requiring less urgency for its
  settlement transactions), it only requires consensus-enforced
  timelocks on one of the chains in a cross-chain swap, and it
  doesn't depend on any new security assumptions or Bitcoin consensus
  changes.  If taproot is adopted, swaps can be made even more privately
  and efficiently.

  Commenting on the protocol, Lloyd Fournier [noted][fournier
  elegance] the "elegance" of a simplified version of the protocol
  that uses three transactions.  Dmitry Petukhov [posted][petukhov
  tla+] about a [specification][sas tla+ spec] he'd written for the
  protocol in the [TLA<sup>+</sup> formal specification language][tla+
  lang], helping to test the correctness of the protocol.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Lightning-based messenger application Juggernaut launches:**
  In a [blog post][juggernaut blog] announcing the first release of Juggernaut,
  John Cantrell describes how the messaging and wallet features are built using
  [keysend payments][topic spontaneous payments].

- **Lightning Loop using multipath payments:**
  The latest [upgrade][lightning loop mpp blog] from Lightning Labs
  now uses [multipath payments][topic multipath payments] to convert onchain
  funds into funds within LN channels.

- **Blockstream Satellite 2.0 supports initial block download:**
  Blockstream [outlines version 2.0 upgrades][blockstream satellite v2 blog] to
  their satellite service which include expanded Asia-Pacific coverage,
  additional bandwidth, and an updated protocol that enables a full node to complete an initial sync
  using only the satellite feed.

- **Breez wallet enables spontaneous payments:**
  [Version 0.9][breez 0.9] of Breez wallet adds the ability to send spontaneous
  payments to Lightning nodes that support keysend.

- **Copay enables CPFP for incoming transactions:**
  Version 9.3.0 adds the ability for the user to
  [speed up an incoming transaction][copay cpfp] using [child-pays-for-parent][topic cpfp].
  The feature is only enabled after the wallet observes the transaction
  remaining unconfirmed for four hours.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.20.0rc2][bitcoin core 0.20.0] is the newest release
  candidate for the next major version of Bitcoin Core.  It
  [contains][Bitcoin Core #18973] several bug fixes and improvements
  since the first release candidate.

- [LND 0.10.1-beta.rc1][] is the first release candidate for the next
  maintenance release of LND.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until version 0.21, about six months after the release of the upcoming
version 0.20.*

- [Bitcoin Core #18877][] is the first step towards support for serving
  [compact block filters][topic compact block filters] on the P2P
  network, as specified in [BIP157][].  Nodes that enable the compact block filter index
  with the `-blockfilterindex` configuration parameter can now respond to
  `getcfcheckpt` requests with a `cfcheckpt` compact block filters checkpoint
  response.   The `getcfheaders` and `getcfilters` messages are not yet supported, and the
  node won't advertise support for BIP157 with `NODE_COMPACT_FILTERS` in its
  version message.

  The feature is disabled by
  default and can be enabled with the `-peerblockfilters` configuration parameter.

- [Bitcoin Core #18894][] fixes a UI bug that affected people who
  simultaneously used multi-wallet mode in the GUI and manual coin
  control.  The bug was described as a [known issue][coin control bug]
  in the Bitcoin Core 0.18 release notes.  This is included in the
  second release candidate for Bitcoin Core 0.20 linked in the
  preceding section.

- [Bitcoin Core #18808][] causes Bitcoin Core to ignore any P2P protocol
  `getdata` requests that specify an unknown type of data.  The new
  logic will also ignore requests for types of data that aren't expected
  to be sent over the current connection, such as requests for
  transactions on block-relay-only connections.

- [C-Lightning #3614][] adds a new notification type named `coin_movements` that
  is triggered by finalized ledger updates. Clients subscribed to these
  notifications will receive updates on both definitively resolved HTLCs and
  confirmed bitcoin transactions, allowing them to construct a canonical ledger
  for coin movements through their C-Lightning node.  See its
  [documentation][coin_movement] for details.

- [Eclair #1395][] updates the route pathfinding used by Eclair to
  factor in channel balances and to use [Yen's algorithm][].
  The PR description says that "the new algorithm consistently
  finds more routes and cheaper ones. The route prefixes are more diverse,
  which is good as well (especially for MPP).  [...] and the new [code]
  is consistently 25% faster on my machine (when looking for 3 routes)."

{% include references.md %}
{% include linkers/issues.md issues="18877,18894,3614,18808,1395,18973,18962" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.1-beta.rc1
[coin control bug]: https://bitcoincore.org/en/releases/0.18.0/#wallet-gui
[yen's algorithm]: https://en.wikipedia.org/wiki/Yen's_algorithm
[getheaders]: https://btcinformation.org/en/developer-reference#getheaders
[headers]: https://btcinformation.org/en/developer-reference#headers
[headers first sync]: https://btcinformation.org/en/developer-guide#headers-first
[news97 spk commit]: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[towns suggestion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017813.html
[wuille rfc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017849.html
[somsen post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017846.html
[somsen video]: https://www.youtube.com/watch?v=TlCxpdNScCA
[petukhov tla+]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017866.html
[tla+ lang]: https://en.wikipedia.org/wiki/TLA%2B
[sas tla+ spec]: https://github.com/dgpv/SASwap_TLAplus_spec
[fournier elegance]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017851.html
[nolan swap]: https://bitcointalk.org/index.php?topic=193281.msg2224949#msg2224949
[juggernaut blog]: https://medium.com/@johncantrell97/announcing-juggernaut-5bda48d34a18
[lightning loop mpp blog]: https://lightning.engineering/posts/2020-05-13-loop-mpp/
[blockstream satellite v2 blog]: https://blockstream.com/2020/05/04/en-announcing-blockstream-satellite-2/
[breez 0.9]: https://github.com/breez/breezmobile/releases/tag/0.9.keysend
[copay cpfp]: https://github.com/bitpay/copay/pull/10746
[coin_movement]: https://github.com/niftynei/lightning/blob/bc803006351a079596b086465246626d3d5e4828/doc/PLUGINS.md#coin_movement
