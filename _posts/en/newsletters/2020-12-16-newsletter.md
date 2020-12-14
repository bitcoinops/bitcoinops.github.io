---
title: 'Bitcoin Optech Newsletter #128'
permalink: /en/newsletters/2020/12/16/
name: 2020-12-16-newsletter
slug: 2020-12-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes two suggested improvements to LN static
backups and links to a proposal for a new version of PSBTs.  Also
included are our regular sections with summaries of changes to services
and client software, popular questions and answers from the Bitcoin
StackExchange, new releases and release candidates, and notable changes
to popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **Proposed improvements to static LN backups:** anyone receiving money
  in a payment channel, including those currently used by LN, needs to
  keep track of the channel's latest state---all the details that make
  it possible to close the channel and receive the correct share of the
  channel's funds onchain.  Unfortunately, computers have a bad habit of
  losing data and regular periodic backups don't help much when a
  channel's state could have changed just milliseconds before a disk drive
  fails.

    LN has always provided some robustness against this type of problem:
    if your node is offline, your channel counterparty will eventually
    close the channel so that they can start spending their funds again.
    This will send your funds to the onchain part of your LN
    wallet, which you hopefully backed up using a normal [BIP32][] seed.
    This should be reasonably safe: LN's regular penalty mechanism
    encourages your counterparty to close the channel in its latest
    state---if they use an old state, they could lose all their money
    from the channel.

    The downside of the above approach is that you have to wait for your
    counterparty to decide that you're not coming back.  This wait can be
    eliminated if you back up some static information about your channel
    (e.g. the ID of your peer), reconnect to the peer after you lose
    data, and request that the peer immediately close the channel.  This does
    seem to indicate that you've lost data and so your peer could close the
    channel in an old state---but, if they try that and
    you still have your old data, you can penalize them.

    This week, Lloyd Fournier started two threads on the Lightning-Dev
    mailing list about possible improvements to the above mechanisms:

    - **Fast recovery without backups:** the static per-channel backups
      that allow fast recovery of funds require you to create a new backup
      each time you open a new channel.  If you fail to make a backup,
      your only option is to wait until your channel counterparty
      decides to close the channel on their own.  Fournier instead
      [proposed][really static backups] a deterministic key derivation method that would allow a
      node to search through the list of public LN nodes, combine
      information about its private keys derived from its HD wallet with
      information about each node's main public key, and determine
      whether or not it had a channel with that node.  This backup strategy would only
      work for channels opened with public nodes, which are expected
      to be the most common type of channel for typical users.

    - **Covert request for mutual close:** the existing mechanism for
      closing a channel requires that your counterparty broadcast their
      unilateral commitment transaction.  It would be better to use a
      mutual close transaction---this uses less space onchain, requires
      paying less fees, is not identifiable onchain as having belonged
      to an LN channel, and allows both parties to spend their funds
      immediately.  However, mutual close transactions don't contain any
      penalty mechanism, so if you request a channel be closed and your
      counterparty gives you an inaccurate mutual close transaction,
      there's no way for you to penalize them.  In the normal protocol,
      this isn't an issue---you'd just broadcast the latest state, but
      if you've lost your state, then you have no remedy.

        Fournier proposed a [solution][oblivious mutual close] using a
        cryptographic primitive called [oblivious transfer][] that
        allows your counterparty to send you the mutual close
        transaction encrypted in a way that allows you to either use it
        (closing the channel) or prove that you can't decrypt it
        (allowing them to safely continue accepting payments in the
        channel).  If you use this procedure every time
        you reconnect, you don't reveal to them that you lost any data
        until after they've provided you all the information you need to
        recover.

- **New PSBT version proposed:** Andrew Chow, author of the [BIP174][]
  specification of [Partially Signed Bitcoin Transactions][topic psbt]
  (PSBTs), [proposed][psbt2] a new version of PSBTs that will contain
  several backwards incompatible features, although it'll be largely the
  same as the current version 0 PSBT.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.21.0rc3][Bitcoin Core 0.21.0] is a release candidate
  for the next major version of this full node implementation and its
  associated wallet and other software.  Note, the macOS version of the
  [signed binary][macos signed] will not run due to a problem with the
  code signing tool.  The [unsigned version][macos unsigned] (which can
  still be [verified][pgp verification] with PGP) should run if opened
  using the right-click (or control-click) context menu.  Developers are
  working on fixing this problem for future release candidates and the
  final relase.

- [LND 0.12.0-beta.rc1][LND 0.12.0-beta] is the first release candidate
  for the next major version of this LN node.  It makes [anchor
  outputs][topic anchor outputs] the default for commitment
  transactions and adds support for them in its [watchtower][topic
  watchtowers] implementation, reducing costs and increasing safety, and
  adds generic support for creating and signing [PSBTs][topic psbt].
  Also included are several bug fixes.

- Bitcoin Core 0.20.2rc1 and 0.19.2rc1 are expected to be
  [available][bitcoincore.org/bin] sometime after the publication of
  this newsletter.  They contain several bug fixes, such as an
  improvement described in [Newsletter #110][news110 bcc19620] that will
  prevent them from redownloading future taproot transactions that they
  don't understand.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #20564][] makes two changes to the way that Bitcoin Core
  signals support for `addrv2` messages ([BIP155][]):

  - *Protocol version:* Bitcoin Core will only negotiate support for `addrv2` messages with peers that signal
    they are using P2P version 70016 or higher. This restriction isn't required by BIP155,
    but release testing has revealed that some other implementations will disconnect
    from Bitcoin Core if they receive any unknown message, including
    `sendaddrv2`. This change may be reverted in future versions of Bitcoin Core,
    so other implementations are advised to tolerate unknown P2P messages at any time in the connection.

  - *Updated BIP:* The `sendaddrv2` message will now be sent between the `version` and
    `verack` message, as required by the latest version of BIP155. See [BIPs
    #1043](#bips-1043) below for more information about that change to the BIP.

    This PR was backported to [the latest V0.21 release candidate][Bitcoin
    Core 0.21.0] in [Bitcoin Core #20612][].

- [Bitcoin Core #19776][] net, rpc: expose high bandwidth mode state via getpeerinfo FIXME:moneyball

- [Bitcoin Core #19858][] adds a new method for finding high-quality peers with
  the goal of making [eclipse attacks][topic eclipse attacks] more difficult.
  It opens an outbound connection every five minutes on average to a new peer
  and syncs headers with it. If the peer tells the node about new blocks, the
  node disconnects an existing block-relay-only peer and gives that connection
  slot to the new peer; otherwise, the new peer is dropped.  Provided the node
  knows the IP address of at least one other honest node, this peer rotation should raise the cost of
  sustaining a partitioning attack against it, as the node should always
  eventually find the valid chain with the most work. The increased rotation and
  security will slightly reduce the number of open
  listening sockets on the network, but it is expected to help bridge the network
  as a whole via more frequent connections, add edges to the network
  graph, and provide more security against partitioning attacks in general.

- [Bitcoin Core #18766][] disables the ability to get fee estimates when
  using the `blocksonly` configuration option.  This bandwidth-saving
  option stops Bitcoin Core from requesting and relaying unconfirmed
  transactions.  However, Bitcoin Core's fee estimates are also
  dependent on tracking how long it takes transactions to become
  confirmed.  Previously, when `blocksonly` was enabled, Bitcoin Core
  stopped updating its estimates but continued to return the
  estimates it had already generated, producing increasingly out of date
  estimates.  After this change, it won't return any estimates at all
  when `blocksonly` mode is enabled.

- [C-Lightning #4255][] is the first of a series of pull requests for an
  initial version of *offers*---the ability to request and receive invoices
  over the LN.  A common use of this feature would be that a
  merchant generates a QR code, the customer scans
  the QR code, the customer's LN node sends some of the details from the
  QR code (such as an order ID number) to the merchant's node over LN,
  the merchant's node returns an invoice (also over LN), the invoice is
  displayed to the user (who agrees to pay), and the payment is sent.
  Although this use case is already addressed today using [BOLT11][]
  invoices, the ability for the spending and receiving nodes to
  communicate directly before attempting payment provides much more flexibility.  It
  also enables features that aren't possible with BOLT11's one-time-use
  hashlocks, such as recurring payments for subscriptions and donations.
  See the [BOLT12 draft][] for more information.

- [Eclair #1566][] Distribute connection-handling on multiple machines using akka-cluster FIXME:dongcarl

- [Eclair #1610][] allows overriding the default relay fees when
  opening a new channel using the new `feeBaseMsat` and
  `feeProportionalMillionths` options.

- [LND #4779][] allows the node to claim payments (HTLCs) that weren't
  yet settled at the time a channel using [anchor outputs][topic anchor
  outputs] was closed.

- [BIPs #1043][] changes the way that support for [BIP155][] is negotiated between
  peers. Previously, the BIP specified that a node should send a `sendaddrv2` message
  to signal support for BIP155 after receiving a `verack` message from its peer.
  The BIP now specifies that the node must send the `sendaddrv2` message
  earlier in connection establishment, between sending its `version` and `verack`
  messages. This is consistent with how [BIP339][] negotiates [wtxid relay][] support
  and also with [a generic method for negotiating features][feature negotiation]
  proposed to the mailing list earlier this year.

    John Newbery posted [a summary of all the changes to BIP155][jnewbery
    bip155] since it was proposed in February 2019 to the Bitcoin-dev mailing list.

- [BOLTs #803][] updates [BOLT5][] with recommendations for preventing
  a [transaction pinning][topic transaction pinning] attack.  The recent
  [anchor outputs][topic anchor outputs] update to the LN specification
  allows multiple payments (HTLCs) that were pending at the time a
  channel was unilaterally closed to all be settled in the same
  transaction.  A potential problem is that some of those outputs may
  pay your channel counterparty, giving them the ability to pin the
  transaction and prevent the other HTLCs in the batch from confirming
  until after their timelocks expire.  The recommendation is to allow
  batching the HTLCs for maximum efficiency when there's plenty of time
  left but to split each HTLC into a separate transaction when the
  timelock expiration is approaching so that pinning isn't a problem.

## Correction

[Newsletter #87][news87 negotiation] incorrectly claimed that "previous versions of Bitcoin
Core would terminate a new connection if certain messages didn’t appear
in a particular order".  We were alluding to a belief that the `version`
message needed to be immediately followed by the `verack` message
introduced in Bitcoin 0.2.9 (May 2010).  Subsequent code review and
testing of old versions of Bitcoin Core by Optech contributors did not
substantiate this statement and we've added a correction to the original
text.  We apologize for the error.

## Holiday publication schedule

Happy holidays!  This issue is our final regular newsletter for the
year.  Next week we'll publish our annual special year-in-review issue.
We'll return to regular publication on Wednesday, January 6th.

{% include references.md %}
{% include linkers/issues.md issues="20564,20612,19776,19858,18766,4255,1566,1610,1608,1043,803,4779" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta.rc1
[news87 negotiation]: /en/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[bolt12 draft]: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md
[news115 fee stealing]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[really static backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-December/002911.html
[oblivious mutual close]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-December/002912.html
[psbt2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-December/018300.html
[oblivious transfer]: https://en.wikipedia.org/wiki/Oblivious_transfer
[macos signed]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/test.rc3/bitcoin-0.21.0rc3-osx.dmg
[macos unsigned]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/test.rc3/bitcoin-0.21.0rc3-osx64.tar.gz
[pgp verification]: https://bitcoincore.org/en/download/#verify-your-download
[bitcoincore.org/bin]: https://bitcoincore.org/bin/
[news110 bcc19620]: /en/newsletters/2020/08/12/#bitcoin-core-19620
[wtxid relay]: /en/newsletters/2020/07/29/#bitcoin-core-18044
[feature negotiation]: /en/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[jnewbery bip155]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-December/018301.html
