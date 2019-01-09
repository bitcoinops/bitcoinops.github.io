---
title: 'Bitcoin Optech Newsletter #10'
permalink: /en/newsletters/2018/08/28/
name: 2018-08-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes information about the first published
release candidate for Bitcoin Core, news about BIP151 P2P protocol
encryption and a potential future soft fork, top questions and answers
from Bitcoin StackExchange, and some notable merges in popular Bitcoin
infrastructure projects.

## Action items

- **Allocate time to test Bitcoin Core 0.17RC2:** Bitcoin Core has
  uploaded [binaries][bcc 0.17] for 0.17 Release Candidate (RC) 2.
  Testing is greatly appreciated and can help ensure the quality of the
  final release.

## News

- **PR opened for initial BIP151 support:** Jonas Schnelli opened a pull
  request to Bitcoin Core providing an [initial implementation][Bitcoin
  Core #14032] of [BIP151][] encryption for the peer-to-peer network
  protocol.  He also has an [updated draft][bip151 update] of the BIP151
  specification that incorporates changes he's made in the development
  of the implementation.  If accepted, this will allow both full nodes
  and lightweight clients to communicate blocks, transactions, and
  control messages without ISPs being able to eavesdrop on the
  connections, which can make it harder to determine which program
  originated a transaction (especially in combination with Bitcoin
  Core's existing transaction origin protection or future proposals such
  as the [Dandelion protocol][]).

    Schnelli is also working with other developers to implement and test
    the [NewHope key exchange protocol][newhope] which is believed to be
    resistant to attacks by quantum computers so that an eavesdropper who
    records communication between two peers today won't be able to
    decrypt that data in a future where they posses a fast quantum
    computer.

- **Requests for soft fork solutions to the time warp attack:** Bitcoin
  blocks include the time the block was supposedly created by a miner.
  These timestamps are used to adjust the difficulty of mining blocks so
  that a block is produced on average every 10 minutes.  However, the
  time warp attack allows miners representing a large fraction of the
  network hash rate to consistently lie about when blocks were created
  over a long period of time in order to lower difficulty even as blocks
  are being produced more frequently than once every 10 minutes.

    Gregory Maxwell has [asked][timewarp maxwell] the Bitcoin protocol
    development mailing list for proposed soft fork solutions to the
    attack before he proposes his own solution.  So far, Johnson Lau has
    [proposed][timewarp lau] one technique.

    Note: anyone monitoring the block chain for this type of attack
    would have at least one month's notice before any significant damage
    was done.  For that reason and because there are multiple known
    methods of countering the attack (with varying tradeoffs), fixing
    the time warp attack has never been considered urgent.  However, if
    the attack risk can be mitigated fully or partly by a
    non-controversial soft fork, that would certainly be nice.

## Selected Q&A from Bitcoin StackExchange

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help answer other people's questions.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.*

- [Can you pay 0 bitcoins?][bse 78355] Andrew Chow explains that not
  only can you pay a zero-value amount to an address or other script,
  you can also spend from a zero-value output---but only if you find a
  miner who doesn't use the default settings in Bitcoin Core.

- [Can you create an SPV proof of the absence of a transaction?][bse 77764]
  Simplified Payment Verification (SPV) uses a merkle tree to prove a
  transaction exists in a block that itself belongs to the best block
  chain---the block chain with the most proof of work.  But could you
  create the reverse?  Could you prove that a transaction is not in a
  particular block or in any block on the best block chain?

    Gregory Maxwell explains that it's possible, and it would also
    involve using merkle trees, but that it would likely require
    computationally expensive (but bandwidth efficient) zero-knowledge
    proofs (ZKPs).

- [Can you convert a P2PKH address to P2SH or segwit?][bse 72775] **Don't do this.**
  Pieter Wuille explains why this is a very bad idea and likely to
  result in lost money.  Note: this is an older answer that saw
  increased attention this month after some users attempted to convert
  other people's addresses to segwit and lost money as a result.

## Notable commits

*Notable commits this week in [Bitcoin Core][core commits], [LND][lnd
commits], and [C-lightning][cl commits].  Reminder: new merges to
Bitcoin Core are made to its master development branch and are unlikely
to become part of the upcoming 0.17 release---you'll probably have to
wait until version 0.18 in about six months from now.*

{% comment %}<!-- I didn't notice anything interesting in LND this week -harding -->{% endcomment %}

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="df660aa7717a6f4784e90535a13a95d82244565a"
  end="427253cf7e19ed9ef86b45457de41e345676c88e"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="3f5ec993300e38369110706ac83301b8875500d6"
  end="26f68da5b2883885fcf6a8e79b3fc9bb12cc9eef"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="80a875a9a54e26c2ea4c90aee8fe606ddcc27c55"
  end="77d3ca3ea3ba607e0b08c7921c41bfc0a9658ed2"
%}

- [Bitcoin Core #12254][] adds the functions necessary to allow Bitcoin
  Core to generate [BIP158][] compact block filters.  This code isn't
  currently used by Bitcoin Core, but future work is expect to use these
  functions to provide two features:

    1. [BIP157][] support for sending filters to light clients over the
       peer-to-peer (P2P) network protocol.  This can allow P2P
       lightweight wallets to find blocks with transactions that affect
       their wallet much more privately than currently possible with
       BIP37 bloom filters.

    2. Faster rescans for Bitcoin Core's built-in wallet.
       Occasionally users of Bitcoin Core need to rescan the block
       chain to see if any historic transactions affected their
       wallet---for example, when they import a new private key, public
       key, or address.  This currently takes over an hour even on
       modern desktops, but users with local BIP157 filters will be able
       to perform the rescan much faster and still with [information
       theoretic perfect privacy][] (which lightweight clients don't
       have).

- [Bitcoin Core #12676][] adds a field to the `getrawmempool`,
  `getmempoolentry`, `getmempoolancestors`, and `getmempooldescendants`
  RPC results to display whether or not a transaction opts-in to
  signaling its spender wants it to be replaced by a transaction
  spending any of the same inputs with a higher fee as described by
  [BIP125][].

- C-Lightning tagged its first release candidate for version 0.16.1.

- C-Lightning reduced the number of places where it refers to 1,000
  weight units as "sipa" and began calling them by the more widely
  accepted term "kiloweights" (kw).

- C-Lightning made multiple improvements to how it handles fees,
  both for on-chain transactions to open and close channels where
  C-Lightning outsources fee estimation to Bitcoin Core, and also for
  fees in payment channels.

- C-Lightning implemented additional parts of [BOLT2][], particularly
  related to the `option_data_loss_protect` field, to improve handling
  of cases where your node appears to have lost essential data---a
  commitment value---or the remote node is sending invalid commitment
  data and possibly deliberately lying.

---
{% include references.md %}
{% include linkers/issues.md issues="14032,12254,12676" %}

[dandelion protocol]: https://arxiv.org/abs/1701.04439
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[timewarp maxwell]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016316.html
[timewarp lau]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016320.html
[BOLT2]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 78355]: {{bse}}78355
[bse 77764]: {{bse}}77764
[bse 72775]: {{bse}}72775
[information theoretic perfect privacy]: https://en.wikipedia.org/wiki/Information-theoretic_security
[bip151 update]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[newhope]: https://newhopecrypto.org/
