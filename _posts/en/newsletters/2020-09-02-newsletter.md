---
title: 'Bitcoin Optech Newsletter #113'
permalink: /en/newsletters/2020/09/02/
name: 2020-09-02-newsletter
slug: 2020-09-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed change to the way LN commitment
transactions are constructed, summarizes discussion of a default signet, and
links to a proposal for standardizing temporarily trusted LN channels. Also
included are our regular sections with recently transcribed talks and
conversations, releases and release candidates, and notable changes to popular
Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **Witness asymmetric payment channels:** Lloyd Fournier [posted][witness asymmetric payment channels] to
  the Lightning-Dev mailing list this week with a request for feedback
  on a proposed change to the way LN commitment transactions are
  created.  Currently, in-channel payments are made by constructing two
  transactions that conflict with each other, meaning Bitcoin's
  consensus rules will only allow one of the transactions to be included
  in the block chain.  Each of these transactions includes the same two
  outputs with the same two amounts---one paying Alice and one paying
  Bob---but with slightly different scripts.

  ![Asymmetric LN commitments](/img/posts/2020-09-ln-commitment-asymmetric.dot.png)

  The script for Alice allows her to unilaterally close the channel, but
  it gives Bob a chance to spend her funds if he knows a revocation key that
  Alice previously created.  Similarly, if Bob unilaterally closes the
  channel, Alice gets a chance to spend his funds using a revocation key he
  created.  Giving your counterparty a private key that allows them to spend
  your money makes it possible to effectively *revoke* that old channel
  state so that you're strongly incentivized to publish the latest
  unrevoked channel state onchain when it comes time to close the
  channel.

  What Fournier proposed this week was only creating a single commitment
  transaction that would be shared between
  Alice and Bob.  When creating the transaction, Alice creates two
  private keys she'll need to spend her output and gives Bob the
  corresponding public keys.  Bob then gives Alice a [signature
  adaptor][topic adaptor signatures] for his half of the 2-of-2 multisig spend in the commitment
  transaction; the adaptor can only be transformed into Bob's signature
  if that signature will reveal one of Alice's private keys to Bob.  The
  other private key Alice created is the revocation private key, which
  she'll give to Bob if she wants to revoke this channel state in favor
  of a later state.  Similarly, Bob generates his own keys and receives
  a signature adaptor from Alice.

  ![Symmetric LN commitments](/img/posts/2020-09-ln-commitment-symmetric.dot.png)

  In this way, even though the commitment transaction is the same for
  both parties, there will be a difference in the signatures (called
  *witnesses*) each of them uses to unilaterally close the channel.
  The difference in the signatures will give the party who didn't close
  the channel a chance to create and broadcast a penalty transaction if
  the channel was closed in an old state.  Otherwise, if the channel was
  closed in its latest state, both parties get their money, just like in
  the current LN.

  The proposal also suggests using basically the same scheme to
  transition from Hash Time Lock Contracts (HTLCs) to Point Time Lock
  Contracts ([PTLCs][news92 ptlcs]), which is a goal several LN contributors
  have voiced support for in the past.

  Advantages of this approach are that it might require less private
  data storage (though this is [debated][zmn reply]), it makes unilateral closes
  a bit smaller onchain, and it describes a path to using PTLCs that
  will provide LN users with additional privacy against routing
  node surveillance as well as bring the protocol a little closer to what it may
  look like when it can take advantage of the benefits of [schnorr
  signatures][topic schnorr signatures].

- **Default signet discussion:** Michael Folkson [posted][default signet post] to the
  Bitcoin-Dev mailing list a question about whether there should be a
  default [signet][topic signet] similar to Bitcoin's existing default testnet.
  Signets are test networks where valid blocks must be
  signed by one or more trusted keys; this allows them to be more
  predictable for testing than fully decentralized test networks that
  are often subject to vandalism.  [BIP325][] describes the signet
  protocol, which anyone can use to create their own signet, but there
  is a [desire][bitcoin core default signet] to include a default signet into
  Bitcoin Core (and possibly other software) that
  users will be able to enable with a single configuration option.
  Folkson's first question was whether anyone has any objection to this.

  If there is to be a default signet, Folkson posted several
  additional questions about how it should be administered.  For
  example, who should control its signing keys?  How many keys should
  there be?  Under what circumstances should the default signet be
  reset?  When should proposed consensus changes to mainnet Bitcoin be
  implemented by the trusted signet block signers?

  Anyone interested in helping answer these questions is encouraged to
  respond.

- **Standardizing temporarily trusted LN channels:** Roei Erez
  [posted][temporarily trusted channels] to the Lightning-Dev mailing list a proposal to standardize
  the way LN implementations deal with new channels when the
  participants are willing to trust an unconfirmed deposit transaction.
  For example, Alice pays Bob's established business to fund a
  channel to her.  In that case, Alice may be willing to trust Bob to not
  double spend his deposit transaction.  Bob can also safely accept
  in-channel payments from Alice because he gets all his money back
  anyway if the deposit transaction doesn't confirm.

  Erez noted that several LN implementations already allow users to
  opt in to trusting certain unconfirmed channels but that the
  different implementations vary in some aspects, such as what
  `short_channel_id` to use until the deposit transaction confirms
  (this value usually identifies the location of the deposit
  transaction in the block chain, which doesn't apply to unconfirmed
  transactions).

  Participants in the mailing list discussion seemed supportive of the
  proposal.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [btcd 0.21.0-beta][] is now released. This is the first major release for
  btcd since 0.20.0-beta in October 2019, and contains numerous improvements
  and bug fixes.

## Recently transcribed talks and conversations

*[Bitcoin Transcripts][] is the home for transcripts of technical
Bitcoin presentations and discussions. In this monthly feature, we
highlight a selection of the transcripts from the previous month.*

- **nix-bitcoin**: nixbitcoindev appeared on the Stephan Livera Podcast to
  discuss nix-bitcoin.  nix-bitcoin is an experimental project
  that aims to improve the security of installing Bitcoin and Lightning nodes. It
  uses the NixOS functional Linux distribution, where upgrading is equivalent to
  installing from scratch due to atomicity. Through minimalism, reproducibility,
  and compartmentalization, nix-bitcoin aims to reduce the attack
  surface of a Bitcoin and Lightning software stack---ensuring programs are unaware of
  other running processes unless they need to be. ([transcript][nixbitcoin
  transcript], [audio][nixbitcoin audio])

- **Taproot activation**: Eric Lombrozo, Luke Dashjr, and Aaron van Wirdum
  discussed the various [taproot][topic taproot] activation proposals (see
  [Newsletter #107][news107 taproot activation]) and gave their opinions
  on what lessons, if any, could be derived from activating the
  segwit soft fork.  Lombrozo and Dashjr both believe that the taproot activation
  process should not be drawn out and that all opposition, criticism, or review of
  the proposed code changes should be completed prior to starting an
  activation process. As a result, they support a single-phase [BIP8][] activation
  method with parameters still to be determined. Community feedback on activation
  proposals continues to be collected. ([transcript][activation transcript],
  [video][activation video])

- **Signet**: Kalle Alm and AJ Towns participated in a discussion on
  [signet][topic signet].  The design decisions of signet were explored as well
  as the mechanics of how testnet and regtest work. For more details, see the
  [_Default signet discussion_ news item](#default-signet-discussion).
  ([transcript][signet transcript], [video][signet video])

- **Bitcoin Core GUI meeting**: Anonymized participants, including designers and
  developers, met to discuss the Bitcoin Core graphical user interface, its
  current state, how it could be improved, and the constraints that
  a revamp would be subject to. For example, one change that has been
  discussed in the past is moving from Qt Widgets to the Qt QML framework, which
  is more flexible and easily customized. ([transcript][bitcoin core gui
  transcript]).

- **Sydney meetup discussion**: Ruben Somsen and Rusty Russell participated in a
  discussion on statechains, upgrading LN channels, and [lnprototest][]. Somsen
  outlined how statechains (see [Newsletter #91][news91 statechains]) could
  potentially be used to swap out your Lightning channel counterparty or, in the
  case of DLCs (see [Newsletter #81][news81 dlc]), swap out a portion of your
  position without closing the channel. With various proposed Lightning channel
  upgrades on the horizon, participants speculated about which upgrades could use dynamic commitments
  (see [Newsletter #108][news108 dynamic commitments]) and which would require
  [splicing][topic splicing]. Finally, Russell explained how the Lightning
  protocol test suite lnprototest could be used to find bugs in existing
  implementations and assist with ensuring interoperability across
  implementations when building out new features.  ([transcript][sydney
  transcript]).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19797][] strays from Satoshi's original vision™ by
  removing an obsolete validity check for IPv6 addresses constructed by
  Bitcoin (Core) 0.2.8 and earlier.  Those early nodes had a bug that
  would produce malformed addresses.
  This change should have no impact on the current P2P network, as
  affected versions are unable to communicate with current software due
  to the introduction of checksums for P2P messages in Bitcoin
  (Core) 0.2.9, which were later made mandatory.

- [Bitcoin Core #19731][] extends the `getpeerinfo` RPC output with two new
  fields: `last_block` and `last_transaction`. `last_block` is the time that
  the peer sent the local node a block which the node had not seen
  before and which passed preliminary validity checks. `last_transaction` is the
  last time that the peer sent the local node a transaction that the node
  accepted to its mempool. Both of these metrics are used when choosing peers
  to disconnect, so it's useful for node operators to be able to access
  the values.

- [LND #4527][] adds a new `default-remote-max-htlcs` configuration
  option that allows the user to specify the default maximum number of
  unresolved HTLCs (payments) allowed in a channel.  This can minimize
  the amount of onchain fees the user will have to pay if they need to
  unilaterally close their channel, such as because of a fee ransom attack
  (see [Newsletter #103][news103 fee ransom]).

- [BIPs #982][] adds changes to [BIP340][] schnorr signatures (which
  also affect [BIP341][] taproot).  BIP340 was previously
  [changed][pk evenness update] to use two different tiebreakers for
  conveying the Y coordinate of points: squaredness for the R point
  inside signatures and evenness for the public keys.  As [described on
  the mailing list][r point evenness update] (see [Newsletter
  #111][news111 proposed tiebreaker]), this update
  changes the R point to use evenness, since the performance gains of using
  squaredness were not observed in practice, and having consistent
  tiebreakers reduces complexity.  Other changes included small fixups,
  clarifications, and typo corrections.

  Similar to [previous revisions][news87 bip 340 updates], the tag for the
  tagged hashes in BIP340 was changed, ensuring that any code written for
  the earlier drafts will generate signatures that fail validation under
  the proposed revisions.

{% include references.md %}
{% include linkers/issues.md issues="19797,19731,4527,982" %}

[witness asymmetric payment channels]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002785.html
[zmn reply]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002786.html
[default signet post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018145.html
[temporarily trusted channels]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002780.html
[bitcoin core default signet]: https://github.com/bitcoin/bitcoin/issues/19787#issuecomment-679836225
[news103 fee ransom]: /en/newsletters/2020/06/24/#ln-fee-ransom-attack
[news92 ptlcs]: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
[nixbitcoin transcript]: https://diyhpl.us/wiki/transcripts/stephan-livera-podcast/2020-07-26-nix-bitcoin/
[nixbitcoin audio]: https://stephanlivera.com/episode/195/
[news107 taproot activation]: /en/newsletters/2020/07/22/#taproot-activation-discussions
[activation transcript]: https://diyhpl.us/wiki/transcripts/bitcoin-magazine/2020-08-03-eric-lombrozo-luke-dashjr-taproot-activation/
[activation video]: https://www.youtube.com/watch?v=yQZb0RDyFCQ
[signet transcript]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-08-19-socratic-seminar-signet/
[signet video]: https://www.youtube.com/watch?v=b0AiucAuX3E
[bitcoin core gui transcript]: https://diyhpl.us/wiki/transcripts/bitcoin-design/2020-08-20-bitcoin-core-gui/
[news91 statechains]: /en/newsletters/2020/04/01/#implementing-statechains-without-schnorr-or-eltoo
[news81 dlc]: /en/newsletters/2020/01/22/#protocol-specification-for-discreet-log-contracts-dlcs
[news108 dynamic commitments]: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news87 bip 340 updates]: /en/newsletters/2020/03/04/#updates-to-bip340-schnorr-keys-and-signatures
[sydney transcript]: https://diyhpl.us/wiki/transcripts/sydney-bitcoin-meetup/2020-08-25-socratic-seminar/
[lnprototest]: https://github.com/rustyrussell/lnprototest
[pk evenness update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017639.html
[r point evenness update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018081.html
[news111 proposed tiebreaker]: /en/newsletters/2020/08/19/#proposed-uniform-tiebreaker-in-schnorr-signatures
[btcd 0.21.0-beta]: https://github.com/btcsuite/btcd/releases/tag/v0.21.0-beta
[hwi]: https://github.com/bitcoin-core/HWI
