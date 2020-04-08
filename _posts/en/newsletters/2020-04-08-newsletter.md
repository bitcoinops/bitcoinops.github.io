---
title: 'Bitcoin Optech Newsletter #92'
permalink: /en/newsletters/2020/04/08/
name: 2020-04-08-newsletter
slug: 2020-04-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes work on simplified ECDSA adaptor
signatures and includes our regular sections for Bitcoin Core PR Review
Club discussion summaries, release announcements, and notable changes to
popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

<!-- Sources like BOLT0 and BIP199 expand the "H" in HTLC to "Hashed",
but I think it makes more sense to drop the suffix here for congruency
with "Point" in PTLC. -->

- **Work on PTLCs for LN using simplified ECDSA adaptor signatures:**
  Point Time Locked Contracts (PTLCs) are an alternative to the Hash
  Time Locked Contracts (HTLCs) currently used to enable routable
  payments in LN.  A problem with the existing HTLC mechanism is that
  every hop along a payments path secures its conditional payment with
  the same hash digest.  This means that a user who controls two nodes
  along the same path knows that any hops between those nodes were not
  the ultimate spender or receiver of the payment.  This not only
  reduces the amount of privacy provided by LN's onion routing but it
  also allows a malicious user to steal the routing fees paid to the
  in-between hops (this is known as the [wormhole attack][]).  For
  example, in the following route, Mallory can steal Bob and Carol's
  routing fees as well as conclude that neither of them is the spender
  or receiver of the ultimate payment.

      Alice → Mallory → Bob → Carol → Mallory' → Dan

    PTLCs make it possible for each hop to use a different identifier
    for the payment by using adaptor signatures (which represent
    *points* on an elliptic curve) rather than hashes.  Adaptor
    signatures were originally described for use with the [schnorr
    signature scheme][topic schnorr signatures].  It's known to be
    possible to use them with Bitcoin's current ECDSA signature scheme
    (see [Newsletter #16][news16 2pecdsa scriptless]) but the process
    relies on two-party ECDSA signing (2pECDSA) which is complex and
    requires security assumptions beyond those normally required for
    Bitcoin-style ECDSA signatures.  However, more recently, Lloyd
    Fournier published a [paper][fournier otves] describing how to
    securely use adaptor signatures with just regular 2-of-2 Bitcoin
    multisig (e.g.  `OP_CHECKMULTISIG`) and simple discrete log
    equivalence (DLEQ); this was summarized in a [post][uSEkaCIO email]
    to the Lightning-Dev mailing list last November.

    Last week during the [Lightning HackSprint][], several developers
    [worked][ptlc challenge] on these 2-of-2 multisig adaptor
    signatures.  The results were an excellent [blog post][gibson blog]
    about the subject and proof-of-concept implementations
    for the C-language [libsecp256k1][jonasnick otves] and Scala [bitcoin-s][nkohen otves] libraries.
    That code is currently unreviewed and possibly unsafe, but it can help
    developers begin experimenting with the use of adaptor signatures on
    mainnet, both for PTLCs in LN and for use in other trustless
    contract protocols.

## Bitcoin Core PR Review Club

_In this section, we summarize a recent Bitcoin Core PR Review Club meeting,
highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting._

[Retry notfounds with more urgency][review club 18238] is a PR
([#18238][Bitcoin Core #18238]) by Anthony Towns that would change peer-to-peer
behavior so that when nodes receive a `notfound` message in response to a request for a
transaction, they would skip the current time-out period and instead try
to obtain the transaction as fast as possible from another peer.

Discussion began with fundamental reasons for the PR:

{% include functions/details-list.md
  q0="Why could retrying `notfound` more quickly be helpful?"
  a0="DoS prevention, transaction propagation speed, privacy, and future
      `mapRelay` removal."

  q1="What is a potential DoS attack concern?"
  a1="Nodes with small mempools could inadvertently slow transaction relay to
      peers by announcing a transaction and then not being able to deliver it."

  q2="Why is transaction propagation speed important?"
  a2="Short delays in seconds aren't an issue (and can even be desirable for
      privacy), but larger delays in minutes can hurt propagation of transactions and
      relay of [BIP152][] compact blocks."

  q3="When and why was `mapRelay` originally added?"
  a3="`mapRelay` was present in the first version of Bitcoin. It ensures that if
     a node announced a transaction, it can be downloaded even if it is confirmed in
     a block between being announced and the peer requesting it."

  q4="Describe one issue with removing `mapRelay`?"
  a4="It could cause requested transactions in honest situations to more often be
      `notfound` with delays of up to 2 minutes, hurting propagation."
%}

Later in the meeting, the `TxDownloadState` data structure was discussed:

{% include functions/details-list.md
  q0="Describe the role of the `TxDownloadState` struct?"
  a0="A per-peer state machine, with timers, to coordinate requesting transactions
      from peers."

  q1="How could we improve `TxDownloadState` to make it less likely to
      introduce transaction relay bugs in future?"
  a1="Add internal consistency checks to the structure, or replace it with a
      class with a well-defined interface."
%}

Discussion then delved deeply into the PR implementation, potential
issues, and future improvements and their interactions with the
[wtxid transaction relay][] proposal. For more details, see the the
[study notes and meeting log][review club 18238].

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair 0.3.4][] was released with support for opening channels over
  0.168 BTC in value (see [Newsletter #88][news88 eclair1323]) and
  [reproducible builds][topic reproducible builds] (see [Newsletter
  #87][eclair determ]).  Also included are bug fixes and many other
  improvements.  See their [release notes][eclair 0.3.4] for details.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #3612][] adds startup parameters `--large-channels` and
  `--wumbo` (which are equivalent).  If used, the node will advertise
  support for `option_support_large_channel` in its `init` message,
  meaning it will accept channel opens with a value higher than the
  previous limit of about 0.168 BTC.  If the remote peer also supports
  this option, C-Lightning's `fundchannel` RPC will allow the user to
  create channels over the previous limit.  See also Eclair's support
  for this option described in [Newsletter #88][news88 eclair1323].

- [C-Lightning #3600][] adds experimental support for *onion messages*
  using *blinded paths*:

    - *Onion messages* (called "LN direct messages" in
      [Newsletter #86][news86 ln dm]) allow a node to send an encrypted
      message across the network without using the LN payments
      mechanism.  This can replace the mechanism of
      messages-over-payments used by apps such as [Whatsat][].  Compared
      to messages-over-payments, onion messages have several advantages:

        1. They have a [draft specification][onion messages draft spec]
           which, if adopted, will make it easier for multiple
           implementations to support them.

        2. They don't need the security of an onchain-enforceable payment
           channel so onion messages can be routed even between peers
           that don't share an established payment channel.  <!-- BOLT7
           draft PR: "SHOULD accept onion messages from peers without an
           established channel." -->

        3. They don't require the bidirectional transmission of
           information like HTLCs or error messages, so once a node has
           forwarded a message, it doesn't need to keep any information
           related to that message.  This statelessness minimizes the memory
           requirements for nodes.  If the sending node wants to receive
           a reply, the draft specification allows it to include a
           blinded `reply_path` field that the receiving node can use to
           send a reply in a new message.

    - *Blinded paths* (called "lightweight rendez-vous routing" in
      [Newsletter #85][news85 lw rv] and now a [draft proposal][blinded path
      gist]) make it possible to route a payment or a message without the originator
      learning the destination's network identity or the full path used.
      This is accomplished through several steps:

        1. The destination node chooses a path from an intermediate node
           to itself and then onion-encrypts that path information so
           that each hop in the path will only be able to decrypt the
           identifier for the next node that should receive the message.
           The destination node gives this encrypted ("blinded") path
           information to the sending node (e.g. via a field in a
           [BOLT11][] invoice or using the previously-mentioned onion
           message `reply_path` field).

        2. The sending node relays its message using normal onion
           routing to the intermediate node.

        3. The intermediate node decrypts the next hop to use from the
           blinded path and sends the message to it.  The next node
           decrypts its own next hop field and further relays the
           message; this process continues until the message reaches the
           destination node.

      Just as with normal onion routing, no routing node should learn
      more about the blinded path than which node sent them the message
      and which node should receive the message after them.  Unlike with
      normal routing, neither the origination nor destination node needs
      to learn the identity of the other node or what exact path it
      used.  This improves not just the privacy of those endpoints but
      also the privacy of any unannounced nodes along the blinded paths.

    As the PR notes, "there are no contents defined yet [for the
    messages], except for those required for routing and replies, but
    the intent is to use this mechanism for offers."  Offers would allow
    nodes to request and send invoices through the LN; see [Newsletter
    #72][news72 offers] for details.

- [LND #4087][] adds support for automatically creating a watchtower tor
hidden service if enabled at [the command line][watchtower tor].

- [LND #4079][] adds support for funding channels with [Partially Signed
  Bitcoin Transactions][topic psbt] (PSBTs), allowing any
  PSBT-compatible wallet to fund a channel open. Previously, channel
  funding was only possible with LND's internal wallet. Once a channel
  has been funded, LND manages all other operations like normal.  Users
  can supply the `--psbt` flag to `lncli openchannel` to start an
  interactive dialog for completing the funding flow; see the
  [documentation][lnd psbt] for details.

- [LND #3970][] adds support for [multipath payments][topic multipath
  payments] to the LND's payment lifecycle system, which is the part of
  LND that tracks "all information about the current state of a payment
  needed to resume it from any point". <!-- routing/payment_lifecycle.go
  -->  This brings LND much closer to its goal for version 0.10 of being
  able to fully support multipath payments. <!-- Alex Bosworth email,
  "In 0.10.0 I think the main new feature will be the ability to
  multipath." -->

{% include references.md %}
{% include linkers/issues.md issues="3612,3600,4087,4079,3970,18238" %}
[news86 ln dm]: /en/newsletters/2020/02/26/#ln-direct-messages
[news85 lw rv]: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news88 eclair1323]: /en/newsletters/2020/03/11/#eclair-1323
[news72 offers]: /en/newsletters/2019/11/13/#proposed-bolt-for-ln-offers
[whatsat]: https://github.com/joostjager/whatsat
[onion messages draft spec]: https://github.com/lightningnetwork/lightning-rfc/pull/759
[blinded path gist]: https://github.com/lightningnetwork/lightning-rfc/blob/route-blinding/proposals/route-blinding.md
[ptlc challenge]: https://wiki.fulmo.org/index.php?title=Challenges#Point_Time_Locked_Contracts_.28PTLC.29
[gibson blog]: https://joinmarket.me/blog/blog/schnorrless-scriptless-scripts/
[wormhole attack]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/privacy-preserving-multi-hop-locks/
[lightning hacksprint]: https://wiki.fulmo.org/index.php?title=Main_Page
[fournier otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
[news16 2pecdsa scriptless]: /en/newsletters/2018/10/09/#multiparty-ecdsa-for-scriptless-lightning-network-payment-channels
[uSEkaCIO email]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002316.html
[jonasnick otves]: https://github.com/jonasnick/secp256k1/pull/14/
[nkohen otves]: https://github.com/bitcoin-s/bitcoin-s/pull/1302
[lnd psbt]: //github.com/lightningnetwork/lnd/blob/master/docs/psbt.md
[review club 18238]: https://bitcoincore.reviews/18238.html
[wtxid transaction relay]: https://bitcoincore.reviews/18044
[watchtower tor]: https://github.com/lightningnetwork/lnd/blob/master/docs/watchtower.md#tor-hidden-services
[eclair 0.3.4]: https://github.com/ACINQ/eclair/releases/tag/v0.3.4
[eclair determ]: /en/newsletters/2020/03/04/#eclair-1307
