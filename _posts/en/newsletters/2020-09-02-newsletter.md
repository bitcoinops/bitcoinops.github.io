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
conversations and notable changes to popular Bitcoin infrastructure projects.

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

## Recently transcribed talks and conversations

*[Bitcoin Transcripts][] is the home for transcripts of technical
Bitcoin presentations and discussions. In this monthly feature, we
highlight a selection of the transcripts from the previous month.*

FIXME:michaelfolkson

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19797][] Remove old check for 3-byte shifted IP addresses from pre-0.2.9 nodes FIXME:dongcarl

- [Bitcoin Core #19731][] extends the `getpeerinfo` RPC results with two new
  fields: `last_block` FIXME:asked question of jonatack

- [LND #4527][] adds a new `default-remote-max-htlcs` configuration
  option that allows the user to specify the default maximum number of
  unresolved HTLCs (payments) allowed in a channel.  This can minimize
  the amount of onchain fees the user will have to pay if they need to
  unilaterally close their channel, such as because of a fee ransom attack
  (see [Newsletter #103][news103 fee ransom]).

- [BIPs #982][] BIP340 updates: even R, new tags, small fixups, clarifications FIXME:adamjonas

{% include references.md %}
{% include linkers/issues.md issues="19797,19731,4527,982" %}

[witness asymmetric payment channels]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002785.html
[zmn reply]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002786.html
[default signet post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018145.html
[temporarily trusted channels]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-August/002780.html
[bitcoin core default signet]: https://github.com/bitcoin/bitcoin/issues/19787#issuecomment-679836225
[news103 fee ransom]: /en/newsletters/2020/06/24/#ln-fee-ransom-attack
[news92 ptlcs]: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
