---
title: 'Bitcoin Optech Newsletter #110'
permalink: /en/newsletters/2020/08/12/
name: 2020-08-12-newsletter
slug: 2020-08-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about
`SIGHASH_ANYPREVOUT` and eltoo, includes a field report showing how
57,000 BTC could have been saved in transaction fees using segwit and
batching, and provides our regular sections with the summary of a
Bitcoin Core PR Review Club meeting, releases and release candidates,
and notable changes to popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **Discussion about eltoo and `SIGHASH_ANYPREVOUT`:** Richard Myers
  [resumed][myers anyprevout] a discussion about
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] and provided a nice
  diagram of how its two [signature hash][] (sighash) types would be used
  within [eltoo][topic eltoo].  He also asked several questions about
  minimizing the number of network round trips needed to create eltoo
  state updates.  These questions received [answers from
  ZmnSCPxj][zmnscpxj reply] but also sparked a [second
  discussion][corallo relay] about attacks against LN payment atomicity
  within the context of eltoo.

    The advantage of eltoo over the currently used LN-penalty mechanism
    is that the publication of old eltoo channel states onchain doesn't
    prevent the publication of the ultimate channel state.  This is
    achieved in eltoo by creating signatures using `SIGHASH_ANYPREVOUT`
    so that the signature from the ultimate state can spend bitcoins
    from either the initial state, the penultimate state, or any state
    in between.  However, transactions still need to identify which
    state (previous output) they are attempting to spend.

    One problem with the eltoo mechanism is that both an attacker and an
    honest user could both try spending from the same previous state.
    Miners and relay nodes would only keep one of those transactions in
    their mempool, and there may be ways the attacker could ensure the
    version of the transaction everyone kept was an old state.  Another
    problem is that the attacker could
    possibly trick the honest user into spending from a state that relay
    nodes hadn't seen and so relay nodes would possibly reject the
    unconfirmed transaction because its parent transaction was not
    available.  Although neither of these problems would
    prevent the ultimate state from eventually being confirmed onchain,
    they could be used for [transaction pinning][topic transaction
    pinning] to prevent one of the honest user's time-sensitive
    transactions from confirming in time.  These problems are similar to
    the attack against LN payment atomicity described in [Newsletter
    #95][news95 ln atomicity].  One proposed mitigation would be to have
    special nodes (perhaps part of LN routing software) that looked for
    cases where eltoo was being used and could use their knowledge of
    that protocol to tell miners which transaction would truly be most
    profitable to mine.

## Field report: How segwit and batching could have saved half a billion dollars in fees

{% include articles/veriphi-segwit-batching.md %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Implement ADDRv2 support (part of BIP155)][review club #19031] is a PR
([#19031][Bitcoin Core #19031]) by Vasil Dimov that proposes an
implementation of the [BIP155][] `addrv2` P2P message.

The discussion covered the current `addr` message in Bitcoin Core, the BIP155
`addrv2` message, how to signal support for `addrv2` on the P2P network, and the
necessity of `addrv2` for the Bitcoin network to upgrade to Tor v3. Tor v2
deprecation begins mid-September!

{% include functions/details-list.md
  q0="How does Bitcoin Core handle network addresses?"
  a0="Bitcoin Core currently sees all peer addresses as being more or less in a
      [single][19031 single] IPv6-like space. IPv4 and Tor v2 addresses are
      serialized into [16 bytes][19031 fake] encoded as “fake” IPv6 addresses
      from specific IPv6 networks reserved for them. For instance, Tor v2
      addresses are persisted using the [“onioncat” IPv6 range][19031 onioncat].
      The 16-byte maximum length of IPv6 increasingly limits which endpoints
      Bitcoin nodes can connect to."
  a0link="https://bitcoincore.reviews/19031#l-35"

  q1="How are peer addresses stored?"
  a1="Addresses are saved in the `peers.dat` file in a 16-byte format, which
      corresponds to the length of IPv6 addresses; the smaller-sized
      IPv4 and Tor v2 addresses are therefore [padded][19031 padded] to
      fit. This file can
      be updated to handle larger addresses with backward compatibility
      maintained for older versions."
  a1link="https://bitcoincore.reviews/19031#l-82"

  q2="What is BIP155 and the `addrv2` message?"
  a2="[BIP155 `addrv2`][BIP155] is a new P2P message format proposed in early
      2019 by Wladimir J. van der Laan to gossip variable-length node addresses
      larger than 16 bytes, and up to 512 bytes for future extensibility, with
      separate address spaces for separate networks. `addrv2` would enable
      Bitcoin core to use [next-generation Onion Services][19031 nextgen]
      (Tor v3) and the [I2P (Invisible Internet Project)][19031 i2p], as well as
      other networks with longer endpoint addresses that don't fit in
      the 16 bytes/128 bits of Bitcoin's current `addr` message."

  q3="How is `addrv2` support expected to be signaled?"
  a3="Most likely with a `sendaddrv2` message between peers
      [at handshake or afterwards][19031 handshake], rather than with the
      originally proposed protocol version bump or with a new network service
      bit."
  a3link="https://bitcoincore.reviews/19031#l-99"

  q4="Why is Tor v3 important for Bitcoin?"
  a4="Tor v2 is planned to be [deprecated on Sept 15, 2020][19031 v2 deprecate]
      and obsolete on July 15, 2021 ([schedule][19031 v2 schedule]).  Tor v3
      provides much better security and privacy, since it uses longer,
      56-character addresses. Using Tor v3 on the Bitcoin network
      therefore requires implementation of BIP155 `addrv2`."
  a4link="https://bitcoincore.reviews/19031#l-203"

  q5="Will we need another upgrade, aka `addrv3`, in the near future?"
  a5="Not for some time. The only `addrv2` constraint is that addresses be
      stored in not more than 512 bytes. Any future format within that size,
      including variable-length route descriptions, should be supported."
  a5link="https://bitcoincore.reviews/19031#l-253"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.11.0-beta.rc2][lnd 0.11.0-beta] is a release candidate for the
  next major version of this project.  It allows accepting [large
  channels][topic large channels] (by default, this is off) and contains
  numerous improvements to its backend features that may be of interest
  to advanced users (see the [release notes][lnd 0.11.0-beta]).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #18991][] changes the way that Bitcoin Core responds to
  `getaddr` requests from its peers. Bitcoin nodes learn about potential new
  peers they can connect to in two different ways. Firstly, each node periodically
  announces its own network address to its peers. Those peers re-announce the
  address to some of their own peers, who re-announce to their peers, and so on,
  propagating the address around the network. Secondly, a node can explicitly
  request addresses from a peer using a `getaddr` message. To prevent a peer
  from learning about all of the addresses in its address manager, Bitcoin Core
  only provides a subset of those addresses when a peer sends it a `getaddr`
  message, and only responds to a single `getaddr` message from each peer.
  However, an adversary may still be able to learn all the addresses a peer knows
  by making multiple connections to that peer and sending `getaddr` messages on
  each connection. The adversary could potentially use that information to
  fingerprint the peer or infer network topology. To prevent that, this PR
  changes Bitcoin Core's behavior to cache responses to `getaddr` requests and
  provide the same response to all peers who request addresses in a 24-hour
  rolling window.

- [Bitcoin Core #19620][] prevents Bitcoin Core from re-downloading
  unconfirmed segwit transactions that attempt to spend non-standard
  UTXOs.  A non-standard UTXO is one that uses a currently discouraged
  feature, such as using v1 segwit outputs before those have been
  enabled on the network by a soft fork like [taproot][topic taproot].
  This helps address a concern described in [Newsletter #108][news108
  wtxid] about a potential taproot activation: nodes that don't upgrade
  for the soft fork won't accept unconfirmed taproot transactions, so
  they might end up downloading and rejecting the same unconfirmed
  taproot transactions over and over again.  That won't happen to any
  node running this patch, allowing backports of this patch to serve as
  an alternative to [backporting the wtxid relay feature][Bitcoin Core
  #19606], which would also prevent that wasted bandwidth.

- [C-Lightning #3909][] updates the `listpays` RPC to now return a new
  `created_at` field with a time stamp indicating when the first part of
  the payment was created.

- [Eclair #1499][] adds new `signmessage` and `verifymessage` commands to sign
  messages using your LN node's public key and verify messages using known node
  pubkeys respectively. These new commands are tested to be compatible with
  existing message signing and verification commands found in [LND][LND #192]
  and [C-Lightning][news69 signcheck rpc], differing only in that Eclair's
  signatures are encoded in hex rather than zbase32.

{% include references.md %}
{% include linkers/issues.md issues="18991,19620,3909,1499,19031,19606,192" %}
[lnd 0.11.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.0-beta.rc2
[news69 signcheck rpc]: /en/newsletters/2019/10/23/#c-lightning-3150
[news95 ln atomicity]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[myers anyprevout]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018069.html
[zmnscpxj reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018071.html
[corallo relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018072.html
[news108 wtxid]: /en/newsletters/2020/07/29/#bitcoin-core-18044
[signature hash]: https://btcinformation.org/en/developer-guide#signature-hash-types
[19031 single]: https://bitcoincore.reviews/19031#l-49
[19031 fake]: https://bitcoincore.reviews/19031#l-88
[19031 onioncat]: https://bitcoincore.reviews/19031#l-89
[19031 padded]: https://bitcoincore.reviews/19031#l-68
[BIP155]: https://github.com/bitcoin/bips/blob/master/bip-0155.mediawiki
[19031 nextgen]: https://trac.torproject.org/projects/tor/wiki/doc/NextGenOnions
[19031 i2p]: https://geti2p.net
[19031 handshake]: https://bitcoincore.reviews/19031#l-121
[19031 v2 deprecate]: https://lists.torproject.org/pipermail/tor-dev/2020-June/014365.html
[19031 v2 schedule]: https://blog.torproject.org/v2-deprecation-timeline
