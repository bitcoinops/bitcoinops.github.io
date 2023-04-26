---
title: 'Bitcoin Optech Newsletter #248'
permalink: /en/newsletters/2023/04/26/
name: 2023-04-26-newsletter
slug: 2023-04-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter relays a request for feedback about a proposal to
remove support for the BIP35 `mempool` P2P protocol message from Bitcoin
Core and includes our regular sections with popular questions and
answers from the Bitcoin Stack Exchange, announcements of new releases
and release candidates, and summaries of notable changes to popular
Bitcoin infrastructure software.

## News

- **Proposed removal of BIP35 `mempool` P2P message:** Will Clark
  [posted][clark mempool] to the Bitcoin-Dev mailing list about a
  [PR][bitcoin core #27426] he's opened to remove support for the P2P
  `mempool` message originally specified in [BIP35][].  In its original
  implementation, a node receiving a `mempool` message would respond to
  the requesting peer with an `inv` message containing the txids of all
  the transactions in its mempool.  The requesting peer could then send
  a regular `getdata` message containing the txids of any transactions
  it wanted to receive.  The BIP describes three motivations for this
  message: network diagnostics, allowing lightweight clients to poll for
  unconfirmed transactions, and allowing miners who recently restarted
  to learn about unconfirmed transactions (at the time, Bitcoin Core did
  not save its mempool to persistent storage on shutdown).

    However, various privacy-reducing techniques were later developed
    that made it easier to determine which node first broadcast a
    transaction by abusing either the `mempool` message or the ability to
    use `getdata` to request any mempool transaction.  To improve
    [transaction origin privacy][topic transaction origin privacy],
    Bitcoin Core later removed the ability to request unannounced
    transactions from other nodes and restricted the `mempool` message
    to being used with [transaction bloom filters][topic transaction
    bloom filtering] (as specified in [BIP37][]) for lightweight clients.
    Even later, Bitcoin Core disabled bloom filter support by default
    (see [Newsletter #56][news56 bloom]), only allowing it to be used
    with peers configured with the `-whitelist` option (see [Newsletter
    #60][news60 bloom]); this effectively makes BIP35 `mempool` also
    disabled by default.

    Clark's Bitcoin Core PR received support from within the project,
    although some supporters think BIP37 bloom filters should be removed
    first.  On the mailing list, the only [reply][harding mempool] as of
    this writing noted that lightweight clients that connect to their
    own trusted node can currently use BIP35 and BIP37 to learn about
    unconfirmed transactions in a much more bandwidth-efficient manner
    than any other method that's currently easily available through
    Bitcoin Core.  The respondent suggested that Bitcoin Core provide an
    alternative mechanism before removing the current interface.

    Additional feedback is requested from anyone using the BIP35
    `mempool` message for any purpose.  You can reply to either the
    mailing list post or the PR linked previously.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.115][] is a release of this library for building LN-enabled
  wallets and applications.  It includes several new features and bug
  fixes, including more support for the experimental [offers][topic
  offers] protocol and improved security and privacy.

- [LND v0.16.1-beta][] is a minor release of this LN implementation that
  includes several bug fixes and other improvements.  Its release notes
  note that its default CLTV delta has been increased from 40 blocks to
  80 blocks (see [Newsletter #40][news40 cltv] where we covered a
  previous change in LND's default CLTV delta).

- [Core Lightning 23.05rc1][] is a release candidate for the next
  version of this LN implementation.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LND #7564][] now allows users of a backend that provides access to
  the mempool to monitor for unconfirmed transactions containing
  preimages for the HTLCs in the node's channels.  This allows the node
  to resolve the HTLCs faster than waiting for those transactions to
  confirm.

- [LND #6903][] updates the `openchannel` RPC with a new `fundmax`
  option that will allocate all channel funds towards a new channel,
  with the exception of any amount that needs to be kept onchain for
  adding fees to channels using [anchor outputs][topic anchor outputs].

- [LDK #2198][] increases the amount of time LDK waits before sending a
  gossip message announcing that a channel is down (e.g. because the
  remote peer is unavailable).  Previously, LDK announced a channel was
  down after about a minute.  Other LN nodes wait longer and a
  [proposal][bolts #1059] for updating the LN gossip protocol suggests
  replacing timestamp fields with block heights instead of [Unix epoch
  time][], which would only allow updating a gossip message once per
  block (approximately every 10 minutes on average).  Although the PR
  notes that sending slower updates involves tradeoffs, it updates LDK
  to wait about 10 minutes before broadcasting a channel disabled
  message.

- [Bitcoin Inquisition #23][] adds part of the support for [ephemeral
  anchors][topic ephemeral anchors].  It doesn't include support for [v3
  transaction relay][topic v3 transaction relay], which ephemeral anchors
  depends on to stop [transaction pinning attacks][topic transaction
  pinning].

{% include references.md %}
{% include linkers/issues.md v=2 issues="7564,6903,2198,1059,23,27426" %}
[Core Lightning 23.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc1
[news56 bloom]: /en/newsletters/2019/07/24/#bitcoin-core-16152
[news60 bloom]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[clark mempool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021562.html
[harding mempool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021563.html
[unix epoch time]: https://en.wikipedia.org/wiki/Unix_time
[ldk 0.0.115]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.115
[lnd v0.16.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.1-beta
[news40 cltv]: /en/newsletters/2019/04/02/#lnd-2759
