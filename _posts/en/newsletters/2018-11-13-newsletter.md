---
title: "Bitcoin Optech Newsletter #21"
permalink: /en/newsletters/2018/11/13/
name: 2018-11-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a few discussions on the Lightning-Dev
mailing list and suggests an opportunity to develop a new tool some
users would find helpful.  Several notable code changes in popular
Bitcoin infrastructure projects are also described.

## Action items

None this week.

## News

- **LN developer summit and mailing list activity:** before, during, and
  after a planned meeting among Lightning Network protocol developers,
  the [Lightning-Dev mailing list][] saw a surge of new proposals and
  discussion about earlier proposals.  Below are some highlights:

    - **Advertising node liquidity:** Lisa Neigut [proposes][neigut
      liquidity] allowing LN nodes advertise that they're willing to
      provide incoming capacity in exchange for a certain level of fees.
      Merchants need their payment channels to have incoming capacity in
      order to be able receive secure offchain payments from
      customers---the current alternatives are either requiring some of
      their customers to wait for several onchain confirmations to open
      a new channel or making manual channel liquidity arrangements with
      other merchants.  Although solving this problem would be highly
      advantageous for merchant adoption of LN, it does pose some
      technical challenges that discussion participants attempt to solve
      both in this thread and in a [related thread][zmn liquidity].

    - **Making path probing more convenient:** Anthony Towns
      [proposes][probe cancel] a method for allowing all the nodes along
      a path to forget about a small-value payment if one of the nodes
      on the path is offline.  This reduces the resources required in
      the case of a routing failure by a node that proactively probes
      its available payment paths to determine which are the fastest and
      most reliable for sending payments.

- **Opportunity available for providing utility functions outside of
  Bitcoin Core:** Bitcoin Core's RPC interface currently provides over
  100 methods and there are often proposals to add even more for utility
  functions that don't require access to the internal state of the node
  or wallet.  During last week's developer IRC [meeting][core dev
  meeting], members of the project reaffirmed their commitment to not
  provide any new utility functions for things that can just as easily
  be done outside Bitcoin Core and that are unrelated to normal user
  workflows.  This will help keep the project focused on its main
  objectives.

    This does provide a nice opportunity for an independent developer or
    other third-party to create a separate project for a library, local
    program, or RPC interface that provides a stable interface to
    utility functions that work well in conjunction with Bitcoin Core,
    and which perhaps even provides some of the utility functions that
    Bitcoin Core already supports for users not running a node.  Some
    ideas for how to implement such a tool were discussed both during
    and [after][core dev log] the meeting.

## Notable code changes

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], [C-lightning][cl commits], and [libsecp256k1][secp
commits].*

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="742ee213499194f97e59dae4971f1474ae7d57ad"
  end="e70a19e7132dac91b7948fcbfac086f86fec3d88"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="6b19df162a161079ab794162b45e8f4c7bb8beec"
  end="d4b042dc1946ece8b60d538ade8e912f035612fe"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="d5bb536ef0c08a813f767b3fb016eb20292de4dd"
  end="62e6a9ff542e40364b67a7aa419e33ed72b96a42"
%}
{% include linkers/github-log.md
  refname="secp commits"
  repo="bitcoin-core/secp256k1"
  start="1086fda4c1975d0cad8d3cad96794a64ec12dca4"
  end="1086fda4c1975d0cad8d3cad96794a64ec12dca4"
%}

- [Bitcoin Core #14410][] adds an `ischange` field to the
  [getaddressinfo][rpc getaddressinfo] RPC indicating whether the wallet
  used the address in a change output.

- [Bitcoin Core #14060][] makes configurable the maximum number of
  messages the [ZeroMQ][] (ZMQ) interface will queue for a client.  The
  default High-Water Mark (HWM) allows up to 1,000 messages to be queued
  before some messages are dropped.  A new HWM may be chosen by setting
  one of the following configuration options to the desired maximum
  number of queued messages (or the maximum queue size may be made
  unlimited by setting it to `0`): `zmqpubhashtxhwm`,
  `zmqpubhashblockhwm`, `zmqpubrawblockhwm`, and `zmqpubrawtxhwm`.
  The greater the queue size, the more memory the program will use.

- [LND #1782][] adds a `num_inactive_channels` field to the `getinfo` RPC
  with the number of the node's inactive channels (similar to the
  existing counts of pending and active channels).

- [LND #1944][] adds a `pub_key` field to the `sendtoroute` RPC so that
  LND doesn't need to get the pubkey from an external source.  This
  allows routing payments through private channels that are not listed
  on the public network.

{% include references.md %}
{% include linkers/issues.md issues="14410,14060,1782,1944" %}

[lightning-dev mailing list]: https://lists.linuxfoundation.org/mailman/listinfo/lightning-dev
[neigut liquidity]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001532.html
[zmn liquidity]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[walletless opens]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001539.html
[eltoo protocol]: https://blockstream.com/eltoo.pdf
[probe cancel]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001554.html
[core dev meeting]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2018/bitcoin-core-dev.2018-11-08-19.00.log.html#l-49
[core dev log]: http://www.erisian.com.au/bitcoin-core-dev/log-2018-11-08.html#l-668
[zeromq]: http://zeromq.org/
