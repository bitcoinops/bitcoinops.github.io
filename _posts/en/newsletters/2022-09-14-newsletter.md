---
title: 'Bitcoin Optech Newsletter #217'
permalink: /en/newsletters/2022/09/14/
name: 2022-09-14-newsletter
slug: 2022-09-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular section with the summary of
a Bitcoin Core PR Review Club meeting, a list of new software releases and
release candidates, and summaries of notable changes to popular Bitcoin
infrastructure projects.

## News

*No significant news this week.*

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Reduce bandwidth during initial headers sync when a block is found][review club 25720]
is a PR by Suhas Daftuar that reduces a node's network bandwidth
requirements while synchronizing the blockchain with peers, including
during Initial Block Download (IBD). An important part of the Bitcoin
ethos is minimizing resource demands of running a fully-validating node,
including networking resources, to encourage more users
to run full nodes. Speeding up the sync time furthers this
goal as well.

Blockchain synchronization occurs in two phases: First, the node
receives block headers from peers; these headers are sufficient
to determine the (likely) best chain (the one with the most work).
Second, the node uses this best chain of headers to request and download the
corresponding full blocks.
This PR affects only the first phase (headers download).

{% include functions/details-list.md
  q0="Why do nodes (mostly) receive `inv` block announcements while
  they are doing initial headers sync, even though they indicated
  preference for headers announcements ([BIP 130][])?"
  a0="A node will not announce a new block to a peer using a headers
  message if the peer has not previously sent a header to which the
  new header connects to, and syncing nodes do not send headers."
  a0link="https://bitcoincore.reviews/25720#l-30"

  q1="Why is bandwidth wasted (during initial headers sync) by adding all
  peers that announce a block to us via an `inv` as headers sync peers?"
  a1="Each of these peers will then begin sending us the same stream
  of headers: the `inv` triggers a `getheaders` to the same peer,
  and its `headers` reply triggers another `getheaders` for the
  immediately following range of block headers. Receiving duplicate
  headers is harmless except for the additional bandwidth."
  a1link="https://bitcoincore.reviews/25720#l-62"

  q2="What would be your estimate (lower/upper bound) of how much
  bandwidth is wasted?"
  a2="Upper bound (in bytes): `(number_peers - 1) * number_blocks * 81`;
  lower bound: zero (if no new blocks arrive during headers sync;
  if the syncing peer and the network are fast, downloading all
  700k+ headers takes only a few minutes)"
  a2link="https://bitcoincore.reviews/25720#l-79"

  q3="What’s the purpose of CNodeState’s members `fSyncStarted` and
  `m_headers_sync_timeout`, and `PeerManagerImpl::nSyncStarted`?
  If we start syncing headers with peers that announce a block to
  us via an `inv`, why do we not increase `nSyncStarted` and set
  `fSyncStarted = true` and update `m_headers_sync_timeout`?"
  a3="`nSyncStarted` counts the number of peers whose `fSyncStarted`
  is true, and this number can't be greater than 1 until the
  node has headers close to (within one day of) the current time.
  This (arbitrary) peer will be our initial headers-sync peer. If this
  peer is slow, the node times it out (`m_headers_sync_timeout`) and
  finds another 'initial' headers syncing peer.
  But if, during headers sync, a node sends an `inv` message
  that announces blocks, then without this PR, the node will
  start requesting headers from this peer as well, _without_ setting
  its `fSyncStarted` flag. This is the source of the redundant
  headers messages, and was probably not intended, but has the
  benefit of allowing headers sync to proceed even if the
  initial headers-sync peer is malicious, broken, or very slow.
  With this PR, the node requests headers from only _one_ additional
  peer (rather than from all peers who announced the new block)."
  a3link="https://bitcoincore.reviews/25720#l-102"

  q4="An alternative to the approach taken in the PR would be to add
  an additional headers sync peer after a timeout (fixed or random).
  What is the benefit of the approach taken in the PR over this
  alternative?"
  a4="One benefit is that peers that announce an `inv` to us have a
  higher probability of being responsive. Another is that a peer that
  manages to send us the block `inv` first is often also a very fast peer.
  So we'd not pick another slow peer if for some reason our initial
  peer is slow."
  a4link="https://bitcoincore.reviews/25720#l-135"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.111][] adds support for creating, receiving, and relaying
  [onion messages][topic onion messages], among several other new
  features and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25614][] builds on [Bitcoin Core #24464][], allowing
  the ability to add and trace logs with specific severity levels in
  addrdb, addrman, banman, i2p, mempool, netbase, net, net_processing,
  timedata, and torcontrol.

- [Bitcoin Core #25768][] fixes a bug where the wallet wouldn't always
  rebroadcast unconfirmed transactions' child transactions.  Bitcoin
  Core's built-in wallet periodically attempts to broadcast any of its
  transactions which haven't been confirmed yet.  Some of those
  transactions may spend outputs from other unconfirmed transactions.
  Bitcoin Core was randomizing the order of transactions before sending
  them to a different Bitcoin Core subsystem that expected to receive
  unconfirmed parent transactions before child transactions (or, more
  generally, all unconfirmed ancestors before any descendants).  When a
  child transaction was received before its parent, it was internally
  rejected instead of being rebroadcast.

- [Bitcoin Core #19602][] adds a `migratewallet` RPC that will convert a
  wallet to natively using [descriptors][topic descriptors].  This works for pre-HD wallets (those
  created before [BIP32][] existed or was adopted by Bitcoin Core), HD
  wallets, and watch-only wallets without private keys.  Before calling
  this function, read the [documentation][managing wallets] and be aware
  that there are some API differences between non-descriptor wallets and
  those that natively support descriptors.

<!-- TODO:harding to separate dual funding from interactive funding -->

- [Eclair #2406][] adds an option for configuring the experimental
  [interactive funding protocol][topic dual funding] implementation to
  require that channel open transactions only include *confirmed
  inputs*---inputs which spend outputs that are a part of a confirmed
  transaction.  If enabled, this can prevent an initiator from delaying
  a channel open by basing it off of a large unconfirmed transaction
  with a low feerate.

- [Eclair #2190][] removes support for the original fixed-length onion
  data format, which is also proposed for removal from the LN
  specification in [BOLTs #962][].  The upgraded variable-length format
  was [added to the specification][bolts #619] more than three
  years ago and network scanning results mentioned in the BOLTs #962 PR
  indicate that it is supported by all but 5 out of over 17,000 publicly
  advertised nodes.  Core Lightning also removed support earlier this
  year (see [Newsletter #193][news193 cln5058]).

- [Rust Bitcoin #1196][] modifies the previously-added `LockTime` type
  (see [Newsletter #211][news211 rb994]) to be a `absolute::LockTime`
  and adds a new `relative::LockTime` for representing locktimes used
  with [BIP68][] and [BIP112][].

{% include references.md %}
{% include linkers/issues.md v=2 issues="25614,24464,25768,19602,2406,2190,962,619,1196" %}
[managing wallets]: https://github.com/bitcoin/bitcoin/blob/master/doc/managing-wallets.md
[news193 cln5058]: /en/newsletters/2022/03/30/#c-lightning-5058
[news211 rb994]: /en/newsletters/2022/08/03/#rust-bitcoin-994
[ldk 0.0.111]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.111
[review club 25720]: https://bitcoincore.reviews/25720
[BIP 130]: https://github.com/bitcoin/bips/blob/master/bip-0130.mediawiki
