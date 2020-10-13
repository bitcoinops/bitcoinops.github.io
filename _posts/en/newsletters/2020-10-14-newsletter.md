---
title: 'Bitcoin Optech Newsletter #119'
permalink: /en/newsletters/2020/10/14/
name: 2020-10-14-newsletter
slug: 2020-10-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter relays a security warning for LND users,
summarizes discussion about LN upfront payments, describes a mailing
list thread about updating bech32 addresses for taproot, and links to an
updated proposal for an alternative way to secure LN payments.  Also
included are our regular sections with summaries of a Bitcoin Core PR
Review Club meeting, releases and release candidates, and notable
changes to popular Bitcoin infrastructure software.

## Action items

- **Upgrade LND to 0.11.x:** the LND development team posted
  [announcements][lnd warning] to the Lightning-Dev and LND Engineering
  mailing lists warning users about the planned disclosure on 20 October
  2020 of vulnerabilities affecting LND versions 0.10.x and earlier.
  The team "strongly urge[s] the community to upgrade to lnd 0.11.0 or
  above [as soon as possible]."  (Note: the mailing list archive
  software slightly alters the text of the announcement, so anyone
  wanting to verify the PGP signature on the announcement should follow
  some [additional steps][lnd pgp].)

## News

- **LN upfront payments:** in the current LN protocol, the attempt to
  route a payment can lock part of a routing node's funds for hours or
  days.  Since routing fees are only paid if a payment succeeds, an
  attacker can use payments designed to fail in order to prevent routing nodes
  from earning income on the capital they store in their channels.  One
  previously discussed option that may better align incentives is to
  charge a non-refundable fee upfront when a routing request is received
  (see [Newsletter #72][news72 upfront payments]).

    This week on the Lightning-Dev mailing list, a
    [discussion][teinturier dynamic] about a proposed minor protocol
    change transformed into a conversation about upfront fees:

    - *Incremental routing:* ZmnSCPxj [described][zmnscpxj tunneling]
      a nested encrypted tunneling protocol where routes would be
      built incrementally, with the spender being able to pay each
      successive routing hop independently.  This would ensure routing
      fees couldn't be stolen by an earlier hop that deliberately failed
      a route.  A downside to this approach is that it would require a
      significant number of network round trips, which could make even
      successful payments take a long time.  A spy node that kept track
      of routed message timing and HTLC duration could also
      estimate how many hops away the spender or receiver are
      from it, reducing the amount of privacy users would receive from
      LN.

    - *Trusted upfront payment:* Antoine Riard [promoted][riard trust]
      the idea of simply paying the upfront fees and, if your peer
      steals them, downgrade their score so that your routing
      algorithm prefers not to use them again.  Assuming a single
      upfront fee is much smaller than the aggregate amount of fees a
      peer could earn over weeks or months of routing, there should be
      an incentive to behave honestly.

- **Bech32 addresses for taproot:** Rusty Russell [resumed][russell
  bech32] a previous discussion (see [Newsletter #107][news107 bech32])
  about revising the [BIP173][] rules for [bech32][topic bech32]
  addresses in order to prevent the [bech32 extension bug][] from
  affecting users of [taproot][topic taproot] and future similar
  upgrades.  Russell proposed using a backwards-incompatible format
  based on a [revised bech32 encoding scheme][wuille new bech32]
  previously described by Pieter Wuille.  This would eliminate the bug
  but also require wallets to upgrade in order to be able to pay taproot
  users.

    A [previously proposed alternative][news107 bech32] would be a
    backwards-compatible restriction on bech32 address lengths.  This
    only directly provides safety to taproot users receiving payments
    from spenders who upgraded their wallets to enforce the new length
    restrictions.  In the discussion, it was proposed that broader
    safety could be provided by also enforcing length restrictions at
    either the [consensus layer][harding bech32] or the [transaction
    relay policy layer][o'connor bech32].

    Russell concluded his post by noting that "the sooner a decision is
    reached on this, the sooner we can begin upgrading software for a
    taproot world."  Feedback would be especially appreciated from
    authors of wallets and bitcoin-sending services as they will be
    asked to implement whatever change is decided upon.

- **Updated witness asymmetric payment channel proposal:** Lloyd
  Fournier [posted][fournier update] to a thread from several weeks ago
  about witness asymmetric payment channels (see [Newsletter
  #113][news113 witasym]).  The idea behind this proposal is to change
  how LN users get the evidence they need to prove their channel
  counterparty cheated.  Currently the evidence is placed in separate
  transaction for each channel participant; Fournier proposes placing
  the evidence in separate signatures ("witnesses") for each
  participant by using [signature adaptors][topic adaptor signatures].
  Advantages of this approach are that it provides a protocol that
  should be easier to integrate with hoped-for improvements to Bitcoin
  (e.g. [schnorr signatures][topic schnorr signatures] with and without
  [MuSig][topic musig] aggregation) and hoped-for improvements to LN
  (e.g. a switch from [HTLCs][topic htlc] to [PTLCs][topic ptlc]).  The approach
  may also be conceptually simpler, which could help attract more
  security review of LN's basic operations.

    This week, Fournier linked to an [updated version][fournier v2] of
    his proposed protocol.  The main difference from the original
    version is that a party who broadcasts a revoked signature reveals
    the primary private key they use in the channel's multisig spends.
    The other party to the channel can use that key combined with their
    own key to immediately claim all funds in the channel.  Along
    with another change, <!-- I think it also needs something like
    Russell's shachain; emailed Fournier 2020-10-11 to confirm --> this
    should allow storing an entire channel's penalty data in a small
    number of bytes.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[BIP-325: Signet][review club #18267] is a PR ([#18267][Bitcoin Core #18267]) by
Kalle Alm that implements a new kind of Bitcoin test network. The PR has since
been merged (see [Newsletter #117][news117 signet]), and the upcoming v0.21
release will support [signet][topic signet].

The review club discussion covered general concepts before diving into the
deeper technical aspects. Participants with good answers were rewarded with
signet coins. Here is a mini-quiz on general signet concepts:

{% include functions/details-list.md
  q0="What is signet?"
  a0="Signet is defined by [BIP325][bip325] and is a mechanism to build
      stable, centralized, and custom proof-of-work networks.  It's also
      the name of a specific global testnet."
  a0link="https://bitcoincore.reviews/18267#l-94"

  q1="Is signet intended to replace existing Bitcoin testing networks like
      testnet or regtest?"
  a1="They are complementary. Signet was conceived as a centralized, stable
      improvement for cases where the current testnet isn't ideal."

  q2="What problems do we have with the current testnet?"
  a2="Testnet is unreliable due to disruptive reorgs, highly variable
      block production, and a skewed incentive model: testnet coins don't have
      value, but testnet mining is not free and the difficulty fluctuates."
  a2link="https://bitcoincore.reviews/18267#l-149"

  q3="What is the difference between signet and regtest (Bitcoin Core's
      regression test framework)?"
  a3="Regtest is a sandboxed environment with entirely manual network topology
      and block generation that is suitable for local testing, but its
      permissionless nature that allows anyone to mine means that regtest
      cannot be used publicly with third-party peers in a stable fashion. Signet
      is an actual network with public nodes, suitable for testing network
      effects like finding peers, transaction selection, and transaction and
      block propagation."

  q4="What is the default signet challenge script in the PR?"
  a4="Multisig 1-of-2 addresses. This may be modified with the `-signetchallenge`
      configuration option."
  a4link="https://bitcoincore.reviews/18267#l-252"

  q5="In the `CreateGenesisBlock()` method, which parameter determines the
      difficulty?"
  a5="Difficulty is set by the [nBits][] parameter, a custom compressed
      representation of the proof of work target whose human-readable representation is
      difficulty."
  a5link="https://bitcoincore.reviews/18267#l-474"

  q6="Is the difficulty for the signet genesis block lower than the difficulty
      for the mainnet genesis block?"
  a6="Yes, signet has a higher default `nBits` and therefore a lower difficulty target:
      [mainnet 1d00ffff, signet 1e0377ae][compare difficulty].
      However, it's just a minimum target; the signer
      [may set it to be higher][signet difficulty]."
  a6link="https://bitcoincore.reviews/18267#l-481"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 1.2.0][] is a new release that adds support for a new hardware
  device (the BitBox02) and contains multiple bug fixes.

- [Eclair 0.4.2][] is a new release that gives more capabilities to
  Eclair plugins, adds experimental support for [anchor outputs][topic
  anchor outputs], and lets users send and receive [spontaneous
  payments][topic spontaneous payments].  Also included are several API
  changes and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19954][] completes the [BIP155][] implementation, also referred
  to as [addr v2][topic addr v2]. As previously covered in
  [Newsletter #110][news110 addrv2], this upgrade supports Tor v3 and makes it
  possible to add support for I2P and other networks with longer endpoint
  addresses that do not fit in the 16 bytes/128 bits of Bitcoin’s current addr
  message. Tor v2 was [deprecated][tor v3 retirement schedule] in September
  2020 and will be obsolete in July 2021.

- [Eclair #1537][] extends the `sendtoroute` API call to allow specifying a
  list of channel IDs for the payment with the `--shortChannelIds` flag. This
  finer-grain control over the payment is especially useful when two
  nodes have more than one channel between them and so listing the node
  IDs is not specific
  enough (e.g. when consolidating and rebalancing channels).

{% include references.md %}
{% include linkers/issues.md issues="19954,1537,18267" %}
[hwi 1.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/1.2.0
[eclair 0.4.2]: https://github.com/ACINQ/eclair/releases/tag/v0.4.2
[lnd warning]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002819.html
[lnd pgp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002822.html
[news72 upfront payments]: /en/newsletters/2019/11/13/#ln-up-front-payments
[teinturier dynamic]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002803.html
[zmnscpxj tunneling]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002811.html
[riard trust]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002817.html
[russell bech32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018236.html
[news107 bech32]: /en/newsletters/2020/07/22/#bech32-address-updates
[bech32 extension bug]: https://github.com/sipa/bech32/issues/51
[harding bech32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018239.html
[o'connor bech32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018240.html
[fournier update]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-October/002812.html
[news113 witasym]: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels
[fournier v2]: https://github.com/LLFourn/witness-asymmetric-channel
[wuille new bech32]: https://gist.github.com/sipa/a9845b37c1b298a7301c33a04090b2eb#improving-detection-of-insertion-errors
[bip325]: https://github.com/bitcoin/bips/blob/master/bip-0325.mediawiki
[compare difficulty]: https://bitcoincore.reviews/18267#l-478
[signet difficulty]: https://bitcoincore.reviews/18267#l-485
[news117 signet]: /en/newsletters/2020/09/30/#bitcoin-core-18267
[nbits]: https://btcinformation.org/en/developer-reference#target-nbits
[tor v3 retirement schedule]: https://blog.torproject.org/v2-deprecation-timeline#:~:text=retirement
[news110 addrv2]: /en/newsletters/2020/08/12/#bitcoin-core-pr-review-club
