---
title: 'Bitcoin Optech Newsletter #57'
permalink: /en/newsletters/2019/07/31/
name: 2019-07-31-newsletter
slug: 2019-07-31-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes fidelity bonds for JoinMarket-style
decentralized coinjoin, mentions a PR for BIP322 signmessage support
(including the ability to sign for bech32 addresses), and summarizes a
discussion about bloom filters.  Also included are our regular sections
about bech32 sending support, popular Q&A from the Bitcoin
StackExchange, and notable changes to popular Bitcoin infrastructure
projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Help test Bitcoin Core 0.18.1 release candidates:** this upcoming
  maintenance release fixes several bugs that affected some RPC
  commands and caused unnecessarily high CPU use in certain cases.
  Production users are encouraged to test the current [release
  candidate][core rc] to ensure that it operates as expected.

## News

- **Fidelity bonds for improved sybil resistance:** JoinMarket developer
  Chris Belcher [posted][fidelity coinjoin] to the Bitcoin-Dev mailing
  list about a possible solution to a previously-known problem that
  affects decentralized coinjoin implementations.  Users of JoinMarket
  operate as either *makers* advertising their willingness to
  participate in a coinjoin or as *takers* who initiate mixes with
  the makers they select.
  It's possible for a single [sybil attacker][sybil attack]
  to pose as enough different makers that one or more of their
  sockpuppets is selected in almost every coinjoin, giving them the
  ability to eliminate or significantly reduce the privacy benefits of
  coinjoining.

    Belcher proposes that makers create a persistent cryptographic
    identity by either destroying ("burning") bitcoins or by timelocking
    bitcoins for an extended period of time.  These sacrifices would be
    accompanied by a public key that the maker could use to sign
    their ephemeral identity in JoinMarket.  Takers would then randomly
    select qualifying makers for coinjoins weighted by the size of their
    sacrifice (as determined by a formula).

    On the upside, this would require attackers to sacrifice significant
    amounts of bitcoins or the ability to sell bitcoins, making sybil
    attacks more expensive.  On the downside, honest makers would likely
    charge more for coinjoins in order to receive compensation for their
    sacrifices, raising the cost of JoinMarket coinjoins.

- **PR opened for BIP322 generic signed message format:** Kalle Alm
  [opened a PR][Bitcoin Core #16440] to Bitcoin Core with an
  implementation of [BIP322][] that updates the `signmessage`,
  `signmessagewithprivkey`, and `verifymessage` RPCs to support signing for
  P2WPKH and P2SH-P2WPKH addresses in addition to legacy P2PKH
  addresses.
  The PR is currently
  seeking feedback and conceptual review.  Although this PR only
  provides a basic implementation of BIP322 support, future extensions
  could allow Bitcoin Core to sign and verify messages for
  any spendable script, with such support easily upgradable for future
  changes in the scripting language such as [taproot][bip-taproot].
  Hopefully other wallets would then consider implementing BIP322
  themselves to provide flexible forward-compatible message signing
  support.  See Optech's previous [bech32 section][signmessage bech32]
  where we lamented the lack of a BIP322 implementation.

    Based on early feedback on the PR, BIP322 has also been updated so
    that signing and verifying messages with legacy P2PKH keys uses the
    old signmessage format.  This allows BIP322 tools to be fully backwards
    compatible with the existing and widely-implemented signmessage standard
    (which only supports P2PKH).

- **Bloom filter discussion:** in the *notable changes* section of [last
  week's newsletter][Newsletter #56], we mentioned a [merged PR][Bitcoin
  Core #16152] that disabled bloom filters in Bitcoin Core's default
  configuration.  The author of the PR [announced][bloom announce] this
  unreleased change to the Bitcoin-Dev mailing list and several people
  replied with questions or concerns.  Some takeaways from the
  discussion include:

    - *No urgent action required:* as of this writing, over 20% of nodes
      accepting incoming connections (listening nodes) are running a
      version of Bitcoin Core that's over a year old [according to
      BitNodes][bitnodes dashboard].  At least 5% are running a version
      that's over two years old.  Extrapolating to the future, that
      means there will still be over 500 listening nodes providing
      bloom filters at the beginning of 2022.  So, even with no further
      action, wallet developers may have a significant amount of time in
      which to adapt their programs.

    - *Spies likely to run their own nodes:* additional to non-upgraded
      nodes, it's possible that block chain analysis companies will
      continue to run their own nodes providing bloom filter support in
      the future so that they can collect statistics from wallets whose
      filters [leak information][filter privacy] about what addresses
      they contain.

    - *DNS seeds can return only nodes signaling BIP111:* most P2P light
      wallets query one or more Bitcoin DNS seeds for a list of nodes to
      use.  Some seeds allow filtering which nodes they return by what
      service bits that node has configured[^dns-query], with the
      service bit for bloom filter support being specified by
      [BIP111][].

    - *BIP157 would use more bandwidth than BIP37:* it was suggested
      that some users of [BIP37][] bloom filters will be unable to
      switch to [BIP157][] compact block filters because of the later's
      higher bandwidth usage.  Optech briefly investigated filter size
      in [Newsletter #43][] and found the filters themselves to use less
      than 100 MB a month.  Clients would also need to download matching
      blocks, which would vary depending on their activity (roughly one
      block for every sent or received transaction for typical users; most
      blocks are less than 2 MB in size).  It's unclear how many users
      would be significantly affected by having to download that amount
      of data.

    - *Interested parties can run their own nodes:* the change to
      Bitcoin Core only disables serving bloom filters by default.  It
      doesn't remove the feature.  Authors of wallets depending on bloom
      filter support can easily operate their own nodes, and they can
      also try to persuade other node operators who aren't worried about
      the DoS vulnerability to set the configuration option to true,
      e.g.  `peerbloomfilters=1`.

## Bech32 sending support

*Week 20 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% include specials/bech32/20-percentage-loss.md %}

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help curious or confused users.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why does the `importmulti` RPC not support zpub and ypub?]({{bse}}89261) Fontaine
  asks why Bitcoin Core's `importmulti` RPC supports the xpub public key
  derivation format but not ypub or zpub formats. Pieter Wuille explains that
  the xpub format was specified in BIP32 and was used to generate
  P2PKH addresses types which were the most common at the time. Pieter goes on to
  describe Bitcoin Core's [output script descriptors][descriptor] as a more sustainable
  approach to address generation.

- [Is Bitcoin PoW actually SHA256 + Merkle tree generation?]({{bse}}89296) User ascendzor
  wonders about the consequences of miners needing to recompute the merkle root
  as part of proof of work mining and why the nonce cannot be increased to 64
  bits. Pieter Wuille explains that not only is the overhead in computing the
  merkle root negligible, but an increase in the nonce size would require a hard
  fork.

- [What is the difference between bytes and virtual bytes
  (vbytes)?]({{bse}}89385) Ugam Kamat and Murch note the differences between
  virtual size (vsize, denominated in vbytes) and size (denominated in bytes)
  and go on to explain the block weight limit and segwit discount.

- [To what extent does asymmetric cryptography secure bitcoin
  transactions?]({{bse}}89262) RedGrittyBrick and Pieter Wuille explain that
  while asymmetric cryptography was not used in Bitcoin to prevent a bug or
  attack, it is the mechanism by which an individual's coins are secured from
  others.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [BIPs #800][] updates [BIP174][] to note that wallets must only sign
  with the signature hash (sighash) type requested in a Partially Signed
  Bitcoin Transaction (PSBT) if the wallet considers that sighash type to
  provide acceptable security.  Most wallets dealing with common
  transaction types should reject anything besides `SIGHASH_ALL`.

- [BIPs #766][] assigns [BIP155][] to the `addr` v2 proposal described
  in [Newsletter #37][].  This proposal will allow nodes to share their
  Tor hidden service (onion) version 3 addresses with each other, as
  well as provide compatibility with other network address protocols.

- [BIPs #643][] adds [BIP301][] about blind merge mining as previously
  [discussed][drivechain discussion] on the Bitcoin-Dev mailing list in
  late 2017.  Blind merge mining is intended to be used with the type of
  decentralized sidechains called "drivechains".  Similar to other
  decentralized sidechain proposals, drivechains have SPV security,
  meaning miners with enough hashrate are able to steal funds from the
  users of the sidechain.

- [C-Lightning #2842][] triggers a reconnection attempt instead of
  failing a channel when a "sync error" is received from a channel peer.
  This is a deliberate decision to deviate from the [LN
  specification][bolt1 error] because LND nodes seem to be generating
  this error quite frequently and C-Lightning maintainers are worried
  that if C-Lightning properly fails channels "at this rate, we risk
  bifurcating the network."

## Footnotes

[^dns-query]:
    For example, here we query a seeder for nodes that have the service
    bits enabled for complete chain history (`NODE_NETWORK`) and bloom
    filter support (`NODE_BLOOM`):

    ```text
    $ python3
    >>> NODE_NETWORK = 1 << 0  ## Original Bitcoin 0.1 protocol
    >>> NODE_BLOOM = 1 << 2    ## BIP111
    >>> hex(NODE_NETWORK | NODE_BLOOM)
    '0x5'

    $ dig x5.seed.bitcoin.sipa.be
    [...]

    ;; ANSWER SECTION:
    x5.seed.bitcoin.sipa.be. 3118	IN	A	84.77.52.0
    x5.seed.bitcoin.sipa.be. 3118	IN	A	165.227.110.22
    x5.seed.bitcoin.sipa.be. 3118	IN	A	52.163.63.49
    [...]
    ```

{% include linkers/issues.md issues="800,766,2842,643,16440,16152" %}
[bech32 series]: /en/bech32-sending-support/
[bolt1 error]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#requirements-2
[drivechain discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-December/015339.html
[core rc]: https://bitcoincore.org/bin/bitcoin-core-0.18.1/
[fidelity coinjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017169.html
[bitnodes dashboard]: https://bitnodes.earn.com/dashboard/
[sybil attack]: https://en.wikipedia.org/wiki/Sybil_attack
[bloom announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017145.html
[signmessage bech32]: /en/bech32-sending-support/#message-signing-support
[filter privacy]: https://jonasnick.github.io/blog/2015/02/12/privacy-in-bitcoinj/

