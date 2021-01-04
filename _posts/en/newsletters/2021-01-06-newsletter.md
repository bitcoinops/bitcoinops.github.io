---
title: 'Bitcoin Optech Newsletter #130'
permalink: /en/newsletters/2021/01/06/
name: 2021-01-06-newsletter
slug: 2021-01-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed update to BIP322 generic
message signing and links to a specification for LN trampoline routing.
Also included are our regular sections with announcements of releases,
release candidates, and notable changes to popular Bitcoin
infrastructure software.

## News

- **Proposed updates to generic signmessage:** Andrew Poelstra
  [posted][poelstra post] a partial rewrite of the [BIP322][]
  generic message signing proposal.  The rewrite mainly clarifies the
  signing and verification procedures, but it now also allows wallets
  that don't implement a complete set of checks to return an
  "inconclusive" state for signatures that use scripts they don't
  understand.  For example, a developer who wants to quickly implement
  generic signmessage may choose to only implement signature verification for
  P2PKH, P2WPKH, and P2SH-P2WPKH scripts, which covers a large
  percentage of all current and historic outputs.  For anything else,
  the wallet can return "inconclusive" and maybe direct the user to a
  more comprehensive verification tool.

- **Trampoline routing:** Bastien Teinturier [posted][teinturier post]
  to the Lightning-Dev mailing list a new [specification][tramp spec]
  for [trampoline routing][topic trampoline payments] that allows a
  spender to pay a receiver without calculating a route between their
  nodes.  Instead, the spender routes their money to a nearby trampoline
  node that calculates the next part of the route---getting the money
  either to the receiver or to the next trampoline node.  This is useful
  for spenders with lightweight LN clients that are often offline or
  otherwise unable to keep track of network gossip in order to calculate
  routes themselves.

    Teinturier notes that ACINQ has been running a single-bounce
    trampoline node for users of their Phoenix wallet.  This provides
    the route-finding benefit but, as described in a [blog post][acinq
    post], it means ACINQ can see the destination of all its users'
    payments.  The solution to this problem is allowing routing nodes
    to advertise the ability to accept onion-wrapped trampoline routes
    where spender Alice sends her money first to one trampoline (e.g.
    ACINQ's node), then possibly to other trampolines, and finally to
    the receiver node.  This prevents any individual trampoline from
    learning the node identifier for both the spender and receiver.  The
    proposed specification would provide a standardized way to achieve
    this.

    It's Teinturier opinion that "the code changes are very reasonable
    as it reuses a lot of components that are already part of every
    lightning implementation and doesn't introduce new assumptions."

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair 0.5.0][] is a new major version that adds support for a
  scalable cluster mode (see [Newsletter #128][news128 akka]), block
  chain watchdogs ([Newsletter #123][news123 watchdog]), and additional plugin
  hooks, among many other features and bug fixes.

- [Bitcoin Core 0.21.0rc5][Bitcoin Core 0.21.0] is a release candidate
  for the next major version of this full node implementation and its
  associated wallet and other software.  This latest RC has not yet been
  uploaded as of this writing, but we hope it will be available shortly
  after publication.

- [LND 0.12.0-beta.rc3][LND 0.12.0-beta] is the latest release candidate
  for the next major version of this LN node.  It makes [anchor
  outputs][topic anchor outputs] the default for commitment transactions
  and adds support for them in its [watchtower][topic watchtowers]
  implementation, reducing costs and increasing safety.  The release also adds generic
  support for creating and signing [PSBTs][topic psbt] and includes
  several bug fixes.

{% comment %}<!--
- Bitcoin Core 0.20.2rc1 and 0.19.2rc1 are expected to be
  [available][bitcoincore.org/bin] sometime after the publication of
  this newsletter.  They contain several bug fixes, such as an
  improvement described in [Newsletter #110][news110 bcc19620] that will
  prevent them from redownloading future taproot transactions that they
  don't understand.
-->{% endcomment %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19137][] and [Bitcoin Core #20365][] wallettool new features FIXME:bitschmidty

- [Bitcoin Core #20599][] updates the message handling code to process
  `sendheaders` and `sendcmpct` messages received before the peer has sent its
  `verack` message. The BIPs for `sendheaders` ([BIP130][]) and `sendcmpct`
  ([BIP152][]) do not specify that those messages must be sent after the `verack`
  message, and the original implementations ([Bitcoin Core #7129][] and
  [Bitcoin Core #8068][]) allowed the messages to be received and processed
  before the `verack` message. A later PR ([Bitcoin Core #9720][]) prevented
  Bitcoin Core from processing those messages if they were received before the
  `verack`. This PR restores the original behavior.

- [Bitcoin Core #18772][] updates the `getblock` RPC when used with the
  `verbosity=2` parameter to return a new `fee` field containing the
  total fee for each transaction in the block.  This depends on
  additional block undo data that nodes store in order to handle block
  chain reorganizations.  Undo data is stored separately from other
  block transaction data and nodes with pruning enabled may delete undo
  data before deleting other data, so it's possible for pruned nodes to
  sometimes return results without a `fee` field.

- [Bitcoin Core GUI #162][] adds a new sortable Network column to the GUI Peers
  window and a new Network row to the peer details area. In both, the GUI
  displays to the user the type of network the peer is connected through: IPv4,
  IPv6, or Onion, with the ability to display two potential future additions,
  I2P and CJDNS. The PR also renames the NodeId and Node/Service column headers
  to Peer Id and Address.

- [C-Lightning #4207][] adds extensive [new documentation][cl
  doc/backup.md] about backing up your node data.

- [Eclair #1639][] enables [BOLT3][] `option_static_remotekey` by
  default, allowing Eclair to honor the request from a channel peer to
  always send payments to the same public key.  This makes it easy for
  the remote peer to locate and spend those payments onchain even if it
  loses some channel state.  The PR description indicates Eclair developers are
  enabling this option now because the 0.12.0-beta release of LND will
  make it mandatory.

- [Rust Bitcoin #499][] New PSBT global keys, maybe describe the overall effect of all the work mentioned in #473 FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="19137,20365,20651,20660,20616,20599,20624,18772,162,4207,4256,4257,1639,1630,499,7129,8068,9720" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta.rc3
[eclair 0.5.0]: https://github.com/ACINQ/eclair/releases/tag/v0.5.0
[cl doc/backup.md]: https://github.com/ElementsProject/lightning/blob/master/doc/BACKUP.md
[poelstra post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-December/018313.html
[teinturier post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-December/002928.html
[tramp spec]: https://github.com/lightningnetwork/lightning-rfc/pull/829
[acinq post]: https://medium.com/@ACINQ/phoenix-wallet-part-4-trampoline-payments-fb1befd027c8
[news128 akka]: /en/newsletters/2020/12/16/#eclair-1566
[news123 watchdog]: /en/newsletters/2020/11/11/#eclair-1545
