---
title: 'Bitcoin Optech Newsletter #71'
permalink: /en/newsletters/2019/11/06/
name: 2019-11-06-newsletter
slug: 2019-11-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests help testing a Bitcoin Core release
candidate, summarizes continued discussion of LN anchor outputs, and
describes a proposal for allowing full nodes and lightweight clients to
signal support for IP address relay.  Also included is our regular
section about notable changes to popular Bitcoin infrastructure
projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Help test Bitcoin Core release candidate:** experienced users are
  encouraged to help test the latest release candidates for the upcoming
  version of [Bitcoin Core][Bitcoin Core 0.19.0].

## News

- **Continued discussion of LN anchor outputs:** as described in [last
  week's newsletter][news70 simplified commitments], LN developers are
  working on allowing either party to a channel to CPFP fee bump
  settlement transactions, taking advantage of the CPFP carve-out
  mempool policy that's expected to be released as part of Bitcoin Core
  0.19.0.  Topics discussed this week on both the [mailing list][jager
  anchor] and the [BOLTs repository][bolts #688] included:

    - Whether both the party unilaterally closing the channel (the
      "local" party) and the other party ("remote") should experience
      the same delay before being able to claim their funds, or whether
      they should each be able to negotiate during the channel creation
      process for the delay duration to use when they're the remote
      party.  Currently, only the local party is delayed and there's
      concern that this may result in some people trying to manipulate
      the other party to close the channel so that the manipulator will
      receive their funds faster.

    - What script to use for the anchor outputs.  It was previously
      proposed that the script should contain a clause that allows
      anyone to spend it after a suitable delay in order to prevent
      polluting the UTXO set with many small-value outputs.  However,
      this is complicated by the script possibly needing to contain a
      unique pubkey which won't be known by third parties, preventing
      them from being able to independently generate the witness script
      necessary to spend the P2WSH output.

    - What amount of bitcoin value to use for the anchor outputs.  The
      person who initiates channel opening is responsible for paying
      this amount (as they are responsible for paying all fees in the
      current protocol), so they would probably like to keep it
      low---but the amount must be greater than most node's minimum
      output amount ("dust limit").  There was discussion about whether
      or not this should be a configurable amount.

    - Whether each LN payment should pay different public keys (using
      pubkey tweaking).  Removing key tweaking was proposed to reduce
      the amount of state tracking necessary, but a concern was raised that
      this would make the channel state too deterministic.  This could
      allow a watchtower that received a series of encrypted breach
      remedy transactions from one side of a channel to be able to
      decrypt not just the needed breach remedy transaction but all
      other breach remedy transactions from that channel---allowing the
      watchtower to reconstruct the amounts and hash locks used for each
      payment in that channel, significantly reducing privacy.

    Discussion remains ongoing as solutions to the above concerns are
    suggested and the proposal receives additional review.

- **Signaling support for address relay:** full nodes share the IP
  addresses of other full nodes they've heard about with their peers
  using the P2P protocol's `addr` (address) message, enabling fully
  decentralized peer discovery.  SPV clients can also use this mechanism
  to learn about full nodes, although most clients currently use some
  form of centralized peer discovery and so `addr` messages sent to those
  clients are wasted bandwidth.

    Gleb Naumenko sent an [email][naumenko addr relay] to the
    Bitcoin-Dev mailing list suggesting that nodes and clients should
    signal to their peers whether or not they want to participate in
    address relay.  This will avoid wasting bandwidth on clients that
    don't want the addresses and can make it easier to determine the
    consequences of certain network behavior related to address relay.

    Two methods are proposed for allowing nodes to indicate whether or
    not they want to participate in address relay---a per-node method
    and a per-connection method.  The per-node method could easily build
    on top of work already being done for addrv2 messages (see [Newsletter
    #37][news37 addrv2]), but it would be less flexible than the
    per-connection method.  In particular, the per-connection method
    could allow a node to dedicate some connections to transaction relay
    and other connections to address relay, producing possible privacy
    advantages.  Naumenko's email requests feedback on which method would
    be preferred by implementers of both full nodes and lightweight
    clients.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #16943][] adds a `generatetodescriptor` RPC that allows
  new blocks generated during testing (e.g. in regtest mode) to pay a
  script represented by an [output script descriptor][].  Prior to this
  change, only the `generatetoaddress` RPC was available and it can only
  pay P2PKH, P2SH, or P2WSH addresses.

- [C-Lightning #3220][] begins always creating signatures with a low *r*
  value, reducing the maximum size of the signature by one byte and
  saving about 0.125 vbytes on average per C-Lightning peer in onchain
  transactions.  Bitcoin Core also previously adopted this change to its
  wallet's signature-generation code (see [Newsletter #8][news8 lowr]).

- [LND #3558][] synthesizes a unified policy for any case where two
  particular nodes have multiple channels open between them and then
  uses this unified policy when considering routing through any of
  those channels.  [BOLT4][bolt4 non-strict rec] recommends that multiple channels
  between the same nodes should all use the same policy, but this
  doesn't always happen, so this change tries to determine "the greatest
  common denominator of all policies" between the nodes.  Using a single
  policy reduces the number of routes the node needs to evaluate when
  making a payment.

- [LND #3556][] adds a new `queryprob` RPC that returns the expected
  probability that a payment would succeed given a particular
  source node, destination node, and payment amount.  This replaces functionality previously
  removed from the `querymc` RPC.

- [BOLTs #660][] updates [BOLT1][] to reserve Type-Length-Value (TLV)
  type identifiers less than 2<sup>16</sup> for types defined in the
  LN specification (the BOLT documents).  The remaining values may be
  used freely as custom records by any LN implementation.  The updated
  specification also now provides guidance on how to select numbers for
  custom record types.

{% include linkers/issues.md issues="16943,3558,3556,660,3220,688" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[bolt4 non-strict rec]: https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#recommendation
[news37 addrv2]: /en/newsletters/2019/03/12/#version-2-addr-message-proposed
[news8 lowr]: /en/newsletters/2018/08/14/#bitcoin-core-wallet-to-begin-only-creating-low-r-signatures
[naumenko addr relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017428.html
[news70 simplified commitments]: /en/newsletters/2019/10/30/#ln-simplified-commitments
[jager anchor]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002264.html
