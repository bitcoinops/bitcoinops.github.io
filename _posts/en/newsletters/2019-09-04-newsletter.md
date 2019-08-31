---
title: 'Bitcoin Optech Newsletter #62'
permalink: /en/newsletters/2019/09/04/
name: 2019-09-04-newsletter
slug: 2019-09-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter relays a security announcement for LN
implementations, describes a non-interactive coinjoin proposal, and
notes a few changes in popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Upgrade LN implementations:** one or more issues that are scheduled
  to be disclosed at the end of this month affect older LN
  implementations.  If you are using any of the following software
  versions, upgrading to a more recent version is [strongly
  recommended][cve ln]:

    - C-Lightning < 0.7.1
    - LND < 0.7
    - Eclair <= 0.3

## News

- **SNICKER proposed:** Adam Gibson [posted][snicker email] to the Bitcoin-Dev mailing
  list with a [proposal][snicker] for *Simple Non-Interactive Coinjoin
  with Keys for Encryption Reused* (SNICKER), a method for
  allowing wallets to create coinjoins non-interactively in two steps, a
  *proposer step* and a *receiver step*.  In the proposer step,
  Alice's wallet uses the block chain and UTXO set to find UTXOs for
  which she knows (or can infer) the owner's public key.
  She selects one of those UTXOs whose value is less than the amount
  controlled by her wallet and creates a proposed coinjoin between that
  UTXO and her wallet's UTXOs, producing three outputs:

  1. Coinjoin output to Alice

  2. Coinjoin output to the owner of the selected UTXO (Bob).  Both
     coinjoin outputs pay the same amount to make them indistinguishable
     to third parties looking at the block chain

  3. Change output to Alice returning any of her money in excess of the
     coinjoin amount

  Addresses that already have transaction history can't be reused or the
  privacy benefits of coinjoin are lost, so Alice generates new unique
  addresses for her two outputs.  However, Bob has no way in this
  non-interactive protocol to tell Alice what addresses to use for his
  output.  Instead, Alice can use Bob's public key and [Elliptic Curve
  Diffie-Hellman][ECDH] (ECDH) to derive a shared secret that Bob will
  also be able to derive from Alice's public key.  With the shared
  secret and Bob's public key, Alice is able to create a new public key
  that only Bob can sign for.  That new public key is used to create the
  new address for Bob's coinjoin output.  No one besides Alice and Bob
  can tell the difference between the addresses, ensuring privacy for
  the coinjoin.

  With information about the inputs and the outputs, Alice creates a
  [BIP174][] Partially-Signed Bitcoin Transaction (PSBT) containing the
  signatures for her UTXO or UTXOs.  She can then upload this PSBT to a
  public server (and she can encrypt it so that only Bob can decrypt it).
  This completes the proposer step in SNICKER.

  If Bob participates in the scheme, his wallet can begin the
  receiver step by periodically checking the server to see if
  anyone like Alice has sent him a proposed PSBT.  If so, Bob can
  evaluate the PSBT to ensure it's correct, add his signature for his
  UTXO to finalize it, and broadcast the transaction to complete the
  coinjoin.

  The key advantage of this proposal is that no interaction is required
  between Alice and Bob.  They each perform their steps independently
  and aren't limited by having each other as potential partners.  Alice
  can create as many proposals as she wants at no cost (except server
  storage space) and Bob can receive multiple proposals from different
  people via a variety of servers, selecting whichever proposal he
  prefers (or none at all).  Either party can also spend their UTXO
  normally at any time, automatically invalidating any pending proposals
  without any harm done.  The PSBTs can be exchanged using any medium that doesn't require users to identify themselves,
  such as a via a simple FTP server over Tor, making it easy for anyone to host a
  SNICKER exchange server.

  The main downside of the proposal is that it requires the proposer
  (Alice) know the public key of the receiver (Bob).  Almost all
  transaction outputs today pay addresses that don't directly include public keys,
  although that may change if the proposed [taproot][bip-taproot]
  soft fork is activated and becomes widely adopted.  In the meantime,
  the SNICKER proposal suggests scanning for reused addresses where public keys
  have been revealed via the block chain, or by using a public key
  from the input of a transaction that creates a UTXO.  For a more
  detailed overview of the proposal, see [Gibson's blog post][snicker
  blog].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #3002][] makes several small changes to comply with
  recent updates to the [LN specification][BOLTs], including the
  [BOLT4][] update to remove the `final_expiry_too_soon` error message
  as described in [last week's newsletter][bolts608].

- [Eclair #899][] implements extended queries as proposed in [BOLTs
  #557][], allowing an LN node to request only gossip updates that
  arrived after a certain time or which have a different checksum than
  those the node has already seen.

- [Eclair #954][] adds a sync whitelist.  If empty, the node will sync
  its gossip store with any peer. If not empty, the node will only sync
  with the specified peers.

{% include linkers/issues.md issues="3002,899,557,954" %}

[cve ln]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-August/002130.html
[bolts608]: /en/newsletters/2019/08/28/#bolts-608
[bolts]: https://github.com/lightningnetwork/lightning-rfc/
[snicker]: https://gist.github.com/AdamISZ/2c13fb5819bd469ca318156e2cf25d79
[ecdh]: https://en.wikipedia.org/wiki/Elliptic_curve_Diffie-Hellman
[snicker email]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017283.html
[snicker blog]: https://joinmarket.me/blog/blog/snicker/
