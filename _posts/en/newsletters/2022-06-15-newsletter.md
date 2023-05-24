---
title: 'Bitcoin Optech Newsletter #204'
permalink: /en/newsletters/2022/06/15/
name: 2022-06-15-newsletter
slug: 2022-06-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes continued discussion about adding
package relay to the Bitcoin P2P network, shares a summary of the recent
LN developers meeting, and describes an argument for how spenders and
routing nodes on LN can optimize for both reliability and low fees in a
way that benefits both groups.  Also included are our regular sections
with summaries of recent releases and release candidates plus notable
changes to popular Bitcoin infrastructure software.

## News

- **Continued package relay BIP discussion:** a recent draft BIP for
  [package relay][topic package relay] (see [Newsletter #201][news201
  relay]) has received additional comments in the past several weeks:

    - *Policy limits:* Anthony Towns [asked][towns relay] if the
      negotiation between two peers to support package relay should
      include information about each peer's package maximum size and
      depth limits, otherwise nodes with non-default settings could
      receive repeated notifications about packages they did not
      want, wasting bandwidth.  BIP author Gloria Zhao [suggests][zhao
      negotiation] using the first version of the package relay
      protocol should imply a maximum package size of 25 transactions
      and 101,000 vbytes.

    - *Package graph announcement only:* Eric Voskuil
      [recommends][voskuil graph] that a peer who learns about a
      high-feerate descendant of a low-feerate ancestor should simply
      inform its peers of the relationships between those two
      transactions, called the package graph.  A receiving peer can then
      request any transactions it doesn't have.  In a separate part of
      the thread, Towns [notes][towns graph] that a graph can't be
      validated until all transactions have been received, so care must
      be taken to ensure a peer can't lie about a graph in order to
      prevent a transaction from being relayed by other peers.

    - *Using short ids:* several developers suggested using
      [BIP152][]-style short identifiers (ids).  Zhao [explained][zhao
      sids] that short ids make sense for block relay where nodes first
      validate a new block's proof of work (which is expensive to
      create), so it would be expensive for an attacker to abuse the
      mechanism to waste node resources.  But, for relay of data that is
      cheap to create, short ids can be abused over and
      over again to potentially create a denial-of-service attack.

    - *Non-standard parents:* Suhas Daftuar [describes][daftuar repeat]
      a scenario where a node implementing package relay can end up
      repeatedly requesting the same data.  This would be
      especially likely to happen when relay policy differs between
      older and newer nodes, such as after a soft fork is activated.

    - *Challenges of a block hash beacon:* Daftuar also notes that one
      feature of the proposal may cause problems for other software.
      The current draft BIP includes the node's current hash of the
      latest block on the block chain in each package annoucement.  This
      allows the receiving
      peer to ignore a package if it's from an earlier block (or
      alternative chain), in which case the package may not work with
      the receiving peer's current mempool.  However, Daftuar notes that
      there's probably a lot of software that sends transactions---and
      which may eventually like to send packages---which doesn't keep
      track of the current chain tip hash.

- **Summary of LN developer meeting:** Olaoluwa Osuntokun provided a
  [detailed summary][osuntokun summary] of the LN dev meeting in Oakland
  last week.  Topics covered included:

    - *Taproot-based LN channels:* participants discussed the first
      steps for moving LN to full use of [taproot's][topic taproot]
      features.  Later steps will likely include support for
      [PTLCs][topic ptlc] (see also
      [Newsletter #164][news164 taproot ln]).

    - *Tapscript and MuSig2:* as part of the switch to taproot-based
      channels, there is a need to convert existing scripts to tapscript
      in the way that makes the most efficient use of block space.
      There's also a desire to use [MuSig2][topic musig] for creating
      signatures in all the places where both signers are expected to
      act cooperatively.  Both of these need to be implemented and
      tested to ensure they work as expected.

    - *Recursive MuSig2:* a simple implementation of MuSig2 can allow
      Alice and Bob to jointly create a single signature.  Recursive
      MuSig2 would allow, for example, Alice to create her part of the
      signature using both her hot wallet and a hardware signing
      device without Bob performing any special steps or even knowing
      that Alice was signing with more than one key.
      It was discussed how to design LN's use of MuSig2 to
      ensure recursive MuSig2 was available.  Also the security of
      recursive MuSig2 was discussed.

    - *Extension BOLTs:* an alternate way to specify changes to the LN
      protocol specification.  Currently, changes to the specification
      are made as a patch (diff) to the existing specification.
      However, some developers prefer the method used for BIPs where
      major changes to the protocol are specified in one or more
      documents specific to those changes.  Those developers believe
      separate documents are easier to write and read, and so may
      simplify and speed up development.

    - *Gossip network updates:* the meeting continued the existing
      discussion about updating LN gossip (see [Newsletter #188][news188
      gossip]), which is used to relay announcements about new and
      updated channels.  According to the summary, participants would
      prefer to focus in the short term on a small upgrade to the
      protocol to support MuSig2-based taproot channels and also upgrade
      the protocol to fully use [TLV][news55 tlv] semantics.

    - *Minisketch-based efficient gossip:* as mentioned in
      [Newsletter #198][news198 minisketch], research is continuing into
      using [minisketch][topic minisketch] to reduce the amount of
      bandwidth used to sync LN gossip between nodes, which may also
      allow for reducing the minimum allowed time between updates.

    - *Onion message DoS:* several LN implementations already support
      [onion messages][topic onion messages] as both an alternative to
      using [keysend][topic spontaneous payments] payments for messaging
      and as a communications layer for the proposed [BOLT12 offers
      protocol][topic offers].  However, as mentioned in [Newsletter
      #190][news190 onion], some developers remain concerned that onion
      messages may be vulnerable to several different types of
      denial-of-service attacks.  Several methods of preventing DoS
      attacks were discussed.

    - *Blinded paths:* a technique proposed several years ago (see
      [Newsletter #85][news85 blinded]) and now used for onion messages
      is also seeing experimentation for use with regular payments to
      allow users to receive payments without disclosing the identity of
      their LN node.  A challenge faced by this approach is that it
      requires communicating more routing information, so larger
      invoices are required.  That may make effective implementation of
      blinded paths dependent on newer invoice-management protocols such
      as BOLT12 offers or [LNURL][].  Several other concerns were also
      discussed.

    - *Probing and balance sharing:* using a variety of techniques, it's
      possible for a node to *probe* the balance of channels on the
      network.  Such probing is effectively free for the node performing
      the probing but it can cause problems for regular users of the
      network in addition to reducing privacy.  Mitigations for the
      separate [channel jamming attack][topic channel jamming attacks]
      may help limit probing, but it remains a concern at the present
      time, so participants discussed some quick changes to node
      settings that could make probing more difficult.

      Additionally, one previously-discussed thought experiment is to
      take the information that a probing node would learn and have
      nodes share it freely without requiring any probing.  If that was
      done by every node, the bandwidth requirements and loss of
      privacy would negate LN's key advantages---but it would also make
      routing payments much more efficient.  Nobody is proposing that
      idea, but a previous research topic was discussed of each node
      sharing with only its direct channel peers some of the information
      they could learn through probing.  It was claimed that this could
      significantly improve payment routing success, such as by
      supplementing [Just-In-Time (JIT) channel rebalancing][topic jit
      routing].

    - *Trampoline routing and mobile payments:*
      [trampoline routing][topic trampoline payments] allows a spender
      to outsource pathfinding to another node on the network,
      optionally in a way that maintains LN's usual privacy of
      preventing any intermediate node from learning the network
      identity of either the spender or receiver.  This outsourcing is
      especially useful for mobile LN clients who aren't attempting to
      route other payments for other nodes.  As mentioned in the meeting summary,
      trampoline payments can be combined with *first hop payment holds*
      (see [Newsletter #171][news171 ln offline]) where a payment is
      held by a spender's direct channel peer until the receiving node
      is next online, allowing an often-offline mobile node to reliably
      receive payments from other often-offline mobile nodes.

    - *LNURL plus BOLT12:* the LNURL protocol allows a node to request a
      [BOLT11][] invoice from a webserver; the BOLT12 [offers][topic
      offers] protocol allows requesting an invoice from a node on the
      network.  Among other aspects of these protocols, participants
      discussed how the two protocols could be made compatible with each other so
      that nodes could use either or both of them.

- **Using routing fees to signal liquidity:** developer [[ZmnSCPxj]]
  [posted][zmnscpxj hilolohi] to the Lightning-Dev mailing list an
  argument for how optimally cheap and reliable payments could be
  obtained through game theoretic behavior between spenders and routing
  nodes:

    - Spenders should choose paths that charge less in routing fees.

    - Routing nodes should charge more to use a channel as its capacity
      decreases.  E.g., if most of the balance in a channel is owned by
      Alice, she can reliably forward payments to Bob and so she
      shouldn't charge much; but, as more balance is forwarded towards
      Bob, Alice's ability to forward additional payments decreases, so
      she should charge higher fees.

  ZmnSCPxj frames this argument using supply and demand economics---as
  demand increases for routing payments in one direction, e.g. from
  Alice to Bob, the supply of additional satoshis which can be routed in
  that direction naturally decreases.  Raising the price of routing fees
  can lower demand until the supply again increases through people
  routing payments in the other direction (e.g. from Bob to Alice).

  Spenders are already naturally incentivized to use lower fees (all
  other things being equal), so ZmnSCPxj argues that any routing node
  that adopts the strategy of high-supply/low-fees and
  low-supply/high-fees will automatically keep its channels reasonably
  balanced and so be able to process a greater number of successful
  payments over its channel lifetime than nodes which do not adopt this
  strategy.  Because routing nodes only get paid for successful payment
  routing, this could make nodes adopting the high-low/low-high strategy
  more competitive.

  A key benefit of this approach is that it makes pathfinding for
  spenders very easy---they just attempt paying along the cheapest
  routes, within capacity limits.  A drawback is that each change to a routing
  nodes fee under the high-low/low-high strategy implies a corresponding
  change to channel's balance, disclosing information about the size of
  payments which may have flowed across that channel recently.  For
  example, if the channels Alice→Bob, Bob→Carol, and Carol→Dan have
  all recently decreased in capacity by about 1 BTC, it's reasonable to
  infer that either Alice or one of her channel partners routed a 1 BTC
  payment to Dan or one of his channel partners.  An additional problem
  is that each change to a channel's fees needs to be gossiped across
  the network, which increases bandwidth requirements and which can also
  cause spurious routing failures (e.g. because spender Sally hasn't
  heard about Alice's new higher feerate and so attempts routing a
  payment across the channel from Alice to Bob using an older and lower
  fee that Alice rejects).

  ZmnSCPxj addresses these issues by describing several mitigation
  strategies, some of which can be implemented by nodes now with no
  changes to the LN protocol, and some of which would require seemingly
  minor updates to the LN gossip protocol.  The mitigation strategies
  described have not received any discussion on the mailing list as of
  this writing, although they appear to be mentioned in Olaoluwa
  Osuntokun's summary of the LN developer's meeting (as further
  summarized by Optech in the previous bullet point).

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.0-beta.rc6][] is a release candidate for the next major
  version of this popular LN node.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24171][] amends the Initial Block Download (IBD) behavior to request block data from
  inbound peers if no outbound peer is serving block data. Previously, a node
  would only request data from inbound peers if it did not have any outbound
  peers at all. This behavior could cause a stall if a node had only outbound
  peers that did not serve blocks. Nodes still request data only from outbound
  peers as soon as any outbound peer serves blocks.

- [BDK #593][] begins using [rust bitcoin][rust bitcoin repo] 0.28,
  which includes support for [taproot][topic taproot] and taproot
  [output script descriptors][topic descriptors].

{% include references.md %}
{% include linkers/issues.md v=2 issues="24171,1505,628,593" %}
[lnd 0.15.0-beta.rc6]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc6
[news201 relay]: /en/newsletters/2022/05/25/#package-relay-proposal
[towns relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020496.html
[zhao negotiation]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020512.html
[voskuil graph]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020518.html
[towns graph]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020520.html
[zhao sids]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020539.html
[daftuar repeat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020542.html
[osuntokun summary]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003600.html
[news164 taproot ln]: /en/newsletters/2021/09/01/#preparing-for-taproot-11-ln-with-taproot
[news188 gossip]: /en/newsletters/2022/02/23/#updated-ln-gossip-proposal
[news55 tlv]: /en/newsletters/2019/07/17/#bolts-607
[news198 minisketch]: /en/newsletters/2022/05/04/#ln-gossip-rate-limiting
[news190 onion]: /en/newsletters/2022/03/09/#paying-for-onion-messages
[news85 blinded]: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[news171 ln offline]: /en/newsletters/2021/10/20/#paying-offline-ln-nodes
[zmnscpxj hilolohi]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003598.html
