---
title: 'Bitcoin Optech Newsletter #28'
permalink: /en/newsletters/2019/01/08/
name: 2019-01-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a new maintenance release of Bitcoin
Core, describes continued discussion about new signature hashes, and
links to a post about possible economic barriers to LN payments crossing
different currencies.  Descriptions of notable code changes in popular
Bitcoin infrastructure projects are also provided.

## Action items

- **Upgrade to Bitcoin Core 0.17.1:** this new [minor][maintenance]
  version released December 25th restores some previously-deprecated
  functionality to the `listtransactions` RPC and includes bug fixes and
  other improvements.  Consider reading the [release notes][0.17.1
  notes] and [upgrading][0.17.1 bin].

## News

- **Continued sighash discussion:** as mentioned in the News section of
  [Newsletter #25][], developers on the Bitcoin-Dev mailing list
  discussed how signature hashes could be modified to give transactions
  access to new capabilities.  Sighashes give spenders the ability to
  allow their transactions to be modified in specified ways after they
  are signed---for example, two people who open a payment channel
  together can use a particular type of sighash to allow either one of
  them to unilaterally attach additional transaction fees to a channel
  close transaction.

    The most recent discussion in this thread of almost 70 posts has
    mostly involved edge cases related to new sighash flags,
    particularly a BIP118-like `SIGHASH_NOINPUT_UNSAFE`.  As part of the
    discussion, protocol developer Johnson Lau described an
    [optimization for Eltoo-based payment channels][lau bip68].  Also
    [discussed][rm codesep] is whether the `OP_CODESEPARATOR` opcode
    should be disabled in a script update that supports MAST (e.g. via
    Taproot).  That opcode is not in common use, but if you plan to use
    it in future Script versions, you should comment on the thread.

- **Cross-chain LN as an options contract:** pseudonymous LN
  contributor ZmnSCPxj started a thread on the Lightning-Dev mailing
  list pointing out that users could abuse payments that cross
  currencies to create almost free [short-term options contracts][] by
  delaying payment settlement.  A [previous thread][cjp risk] by Corné
  Plooy in May 2018 described the same thing.

    For example, Mallory learns that Bob is willing to route payments
    from Bitcoin to Litecoin, so she sends a payment from one of her
    Bitcoin nodes through Bob to one of her Litecoin nodes.  If this
    were a normal payment, she'd settle it immediately by releasing the
    preimage for the payment's hashlock---but instead her node delays
    for 24 hours waiting for the exchange rate to change.  If the
    exchange rate increases in Litecoin's favor, Mallory settles the
    payment and receives litecoin today at yesterday's exchange rate.
    If the exchange rate stays the same or increases in Bitcoin's favor,
    Mallory causes the payment to fail and gets her bitcoin back.  Since
    no fees are charged for failed payments, Mallory received an
    opportunity to temporarily lock-in the price of Litecoin for nothing
    but the cost of owning the bitcoins Mallory would've traded.

    There currently aren't any known cross-currency LN nodes, but the
    availability of this trick means that future such nodes could be
    abused for speculation rather than payment routing.  If this turns
    out to be a real problem and if an acceptable solution isn't found,
    it may be the case that payment channel networks for different
    currencies will be isolated from each other.

## Notable code changes

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], [C-lightning][cl commits], and [libsecp256k1][secp
commits].*

- [Bitcoin Core #14565][] significantly improves the error handling for
  the `importmulti` RPC and will return a `warnings` field for each
  attempted import with an array of strings describing any problems with
  the that import (but only if there were any problems).

- [Bitcoin Core #14811][] updates the [getblocktemplate][rpc
  getblocktemplate] RPC to require that the segwit flag be passed.  This
  helps prevent miners from accidentally not using segwit, which reduces
  their fee income.  See [Newsletter #20][] for a recent instance where
  this may have happened to a large mining pool.

- [C-Lightning #2172][] allows `lightningd` to be shutdown normally even
  if it's operating as the primary process (PID 1), which can be useful
  in Docker containers.  This is, for example, how the open source
  [BTCPay][] server runs C-Lightning.

- [C-Lightning #2188][] adds notification subscription handlers that can
  be used by plugins, with initial support for notifications that the
  node has connected to a new peer or disconnected from an existing
  peer.  The [plugin documentation][cl plugin event] and [sample
  plugin][cl helloworld.py] have been updated for these handlers.

- [LND #2374][] increases the maximum size of the gRPC messages the
  `lncli` tool will accept, raising it from 4 MB to 50 MB.  This fixes a problem
  some nodes were encountering where the `describegraph` RPC was failing
  due to the network having grown so large that messages exceeded this
  limit.  Developers using gRPC directly will need to increase their
  client-side maximum message size setting---descriptions of how to do
  this have already been added as comments to the PR for python and nodejs.
  Ultimately it's expected that the network will grow large enough to
  exceed even this new maximum, so developers are planning to revamp the
  relevant RPCs to handle this situation.

- [LND #2354][] adds a new `invoicestate` field and deprecates the former
  `settled` field in RPCs that get information about invoices.  The
  settled field was boolean but the new state field can support multiple
  values.  Currently this is just "open" or "settled", but additional
  future states are planned.

{% include references.md %}
{% include linkers/issues.md issues="14565,14811,2172,2188,2374,2354" %}
{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="34241716852df6ea6a3543822f3bf6f886519d4b"
  end="fe5a70b9fefa0548f497a749746f53f3d7fd0ebb"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="0fafd5e2fd824f38ec6a03a56488de9c0798f34f"
  end="3c950e8f0dc103feeffd9c42c9683e1164b4e8d8"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="2c53572798f78ce2a66aced0627b7b3f2adb0514"
  end="6f027a24a04912859f44c314bf00e9d3fcb27500"
%}
{% include linkers/github-log.md
  refname="secp commits"
  repo="bitcoin-core/secp256k1"
  start="e34ceb333b1c0e6f4115ecbb80c632ac1042fa49"
  end="e34ceb333b1c0e6f4115ecbb80c632ac1042fa49"
%}

[0.17.1 bin]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[0.17.1 notes]: https://bitcoincore.org/en/releases/0.17.1/
[maintenance]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[lau bip68]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016574.html
[rm codesep]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016581.html
[short-term options contracts]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001752.html
[cjp risk]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-May/001292.html
[cl plugin event]: https://github.com/ElementsProject/lightning/blob/master/doc/PLUGINS.md#event-notifications
[cl helloworld.py]: https://github.com/ElementsProject/lightning/blob/master/contrib/plugins/helloworld.py
[btcpay]: https://github.com/btcpayserver/btcpayserver
