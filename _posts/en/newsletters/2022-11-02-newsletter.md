---
title: 'Bitcoin Optech Newsletter #224'
permalink: /en/newsletters/2022/11/02/
name: 2022-11-02-newsletter
slug: 2022-11-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes continued discussion about optionally
allowing nodes to enable full RBF, relays a request for feedback on a
design element of the BIP324 version 2 encrypted transport protocol,
summarizes a proposal for reliably attributing LN failures and delays to
particular nodes, and links to a discussion about an alternative to
using anchor outputs for modern LN HTLCs.  Also included are our regular
sections with the announcements of new software releases and release
candidates---including a security critical update for LND---and
descriptions of notable changes to popular Bitcoin infrastructure
software.


## News

- **Mempool consistency:** Anthony Towns started a [discussion][towns
  consistency] on the Bitcoin-Dev mailing list about the consequences of
  making it easier to configure Bitcoin Core's policies for transaction
  relay and mempool acceptance, such as was done by the addition of the
  `mempoolfullrbf` option to Bitcoin Core's development branch (see
  Newsletters [#205][news205 rbf], [#208][news208 rbf], [#222][news222
  rbf], and [#223][news223 rbf]).  He claims that "this differs from
  what core has done in the past, in that previously we've tried to
  ensure a new policy is good for everyone (or as nearly as it can be),
  and then enabled it as soon as it's implemented.  Any options that
  have been added have either been to control resource usage in ways
  that don't significantly [affect] tx propagation, to allow people to
  revert to the old behaviour when the new behaviour is controversial
  (eg the -mempoolreplacement=0 option from 0.12 to 0.18), and to make
  it easier to test/debug the implementation.  Giving people a new relay
  behaviour they can opt-in to when we aren't confident enough to turn
  on by default doesn't match the approach I've seen core take in the
  past."

    Towns then contemplates whether this is a new direction for
    development: "full [RBF][topic RBF] has been controversial for ages,
    but widely liked by devs [...] so maybe this is just a special case
    and not a precedent, and when people propose other default false
    options, there will be substantially more resistance to them being
    merged, despite all the talk about users having options that's going
    on right now."  But, assuming it is a new direction, he evaluates
    some potential consequences of that decision:

    - *It should be easier to get default-disabled alternative relay options merged:*
      if giving users more options is seen as better, there are many
      aspects of relay policy that can be made configurable.  For
      example, Bitcoin Knots provides a script pubkey reuse
      (`spkreuse`) option for configuring a node to refuse to relay
      any transactions which [reuse an address][topic output linking].

    - *More permissive policies require widespread acceptance or better peering:*
      A Bitcoin Core node by default relays transactions with eight peers via outbound connections,
      so at least 30% of the network needs to support a more
      permissive policy before a node has a 95% chance of finding at
      least one randomly-selected peer that supports the same policy.
      The fewer nodes that support a policy, the less likely it is
      that a node will find a peer supporting that policy.

    - *Better peering involves tradeoffs:* Bitcoin nodes can announce
      their capabilities using the services field of the P2P `addr`,
      [`addrv2`][topic addr v2], and `version` messages, allowing nodes
      with common interests to find each other and form sub-networks
      (called *preferential peering*).  Alternatively, full node
      operators with common interests can use other software to form
      independent relay networks (such as a network among LN nodes).
      This can make relay effective even when just a few nodes
      implement a policy, but nodes implementing a rare policy are
      easier to identify and censor.  It also requires miners to
      join these sub-networks and alternative networks, raising the
      complexity and cost of mining.  That increases the pressure to
      centralize transaction selection, which also makes censorship
      easier.

        Additionally, nodes implementing different policies from some
        of their peers won't be able to take full advantage of
        technologies like [compact block relay][topic compact block
        relay] and [erlay][topic erlay] for minimizing latency and
        bandwidth when two peers already have some of the same
        information.

    Towns's post received multiple insightful responses, with discussion
    ongoing as of this writing.  We will provide an update in next
    week's newsletter.

- **BIP324 message identifiers:** Pieter Wuille [posted][wuille bip324]
  to the Bitcoin-Dev mailing list a response to the update of the
  [BIP324][bips #1378] draft specification for the [version 2 P2P encrypted
  transport protocol][topic v2 p2p transport] (v2 transport).  To save
  bandwidth, v2 transport allows replacing the existing protocol's
  12-byte message names with identifiers as short as 1 byte.  For
  example, the `version` message name, which is padded out to 12 bytes,
  could be replaced with 0x00.  However, shorter message names increase
  the risk of conflict between different future proposals to add
  messages to the network.  Wuille describes the tradeoffs between four
  different approaches to this problem and requests opinions about the
  subject from the community.

- **LN routing failure attribution:** LN payment attempts can end in
  failure for a variety of reasons, from the ultimate receiver refusing
  to release the payment preimage to one of the routing nodes
  temporarily being offline.  Information about which nodes caused a
  payment to fail would be extremely useful to spenders for avoiding
  those nodes for near-future payments, but the LN protocol today
  doesn't provide any authenticated method for routing nodes to
  communicate that information to a spender.

    Several years ago, Joost Jager proposed a solution (see [Newsletter
    #51][news51 attrib]), which he has now [updated][jager attrib] with
    improvements and additional details.  The mechanism would ensure
    identification of the pair of nodes between which a payment failed
    (or between which one of them an earlier failure message was
    censored or became garbled).  The main downside of Jager's proposal
    is that it would significantly increase the size of LN onion
    messages for failures if other LN properties remained the same,
    although the size of onion messages for failures wouldn't need to be
    as large if the maximum number of LN hops was decreased.

    Alternatively, Rusty Russell [suggested][russell attrib] that a
    spender could use a mechanism similar to [spontaneous
    payments][topic spontaneous payments] where each routing node is paid
    one sat even if the ultimate payment fails.  The spender could then
    identify which hop the payment failed at by comparing how many
    satoshis it sent to how many satoshis it received back.

- **Anchor outputs workaround:** [[Bastien Teinturier]] [posted][teinturier
  fees] to the Lightning-Dev mailing list a [proposal][bolts #1036] for using
  [anchor outputs][topic anchor outputs] with multiple presigned
  versions of each [HTLC][topic htlc] at different feerates.  Anchor
  outputs were introduced with the development of the [CPFP
  carve-out][topic cpfp carve out] rule for allowing fees to be added to
  a transaction via the [CPFP][topic cpfp] mechanism in a way that
  wouldn't be [pinnable][topic transaction pinning] for LN's two-party
  contract protocol.  However, Teinturier [notes][bolts #845] that using
  CPFP requires every LN node keep a pool of non-LN UTXOs ready to spend
  at any moment.  By comparison, presigning multiple versions of HTLCs
  each with different fees allows those fees to be paid directly from
  the HTLC's value---no additional UTXO management is required, except in
  cases where none of the presigned feerates was high enough.

    He's seeking support from other LN developers for the idea of providing
    multiple feerate HTLCs.  All discussion as of this writing has
    occurred on Teinturier's [PR][bolts #1036].

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.15.4-beta][] and [0.14.4-beta][lnd 0.14.4-beta] are **security
  critical** releases containing a bug fix for a problem processing
  recent blocks.  All users should upgrade.

- [Bitcoin Core 24.0 RC2][] is a release candidate for the
  next version of the network's most widely used full node
  implementation.  A [guide to testing][bcc testing] is available.

  **Warning:** this release candidate includes the `mempoolfullrbf`
  configuration option which several protocol and application developers
  believe could lead to problems for merchant services as described
  in newsletters [#222][news222 rbf] and [#223][news223 rbf].  Optech
  encourages any services that might be affected to evaluate the RC and
  participate in the public discussion.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23927][] restricts `getblockfrompeer` on pruned nodes
  to heights below the node's current synchronization progress. This
  prevents a footgun arising from retrieving future blocks making the
  node's block-files ineligible for pruning.

  Bitcoin Core stores blocks in files of about 130 MB in whatever order
  it receives them. Pruning will discard entire block files, but will not
  discard any file containing a block not processed by synchronization.
  The combination of a small data allowance and repeated use of the
  `getblockfrompeer` RPC could cause multiple block-files ineligible for
  pruning, and cause a pruned node to exceed its data allowance.

- [Bitcoin Core #25957][] improves the performance of rescans for
  descriptor wallets by using the [block filter index][topic compact block filters] (if enabled)
to skip blocks that don't spend or create UTXOs relevant to the wallet.

- [Bitcoin Core #23578][] uses [HWI][topic hwi] and recently merged support for
  [BIP371][] (see [Newsletter #207][news207 bc22558]) to allow external signing
  support for [taproot][topic taproot] keypath spends.

- [Core Lightning #5646][] updates the experimental implementation of
  [offers][topic offers] to remove [x-only public keys][news72 xonly]
  (instead using [compressed pubkeys][], which contain an extra byte).
  It also implements forwarding of [blinded payments][], another
  experimental protocol.  The PR description warns it "does not include
  generating and actually paying invoices with blinded payments."

- [LND #6517][] adds a new RPC and event that allow a user to monitor
  when an incoming payment ([HTLC][topic htlc]) is fully locked in by
  the commitment transaction being updated to reflect the new channel
  balance distribution.

- [LND #7001][] adds new fields to the forwarding history RPC
  (`fwdinghistory`) indicating which channel partner forwarded a payment
  (HTLC) to us and the partner to whom we relayed the payment.

- [LND #6831][] updates the HTLC interceptor implementation (see
  [Newsletter #104][news104 intercept]) to automatically reject an
  incoming payment (HTLC) if the client connected to the interceptor
  hasn't finished processing it within a reasonable amount of time.  If
  an HTLC isn't accepted or rejected before its expiry draws near, the
  channel partner will need to force close the channel to protect its
  funds.  This merged PR's automatic rejection before that expiry
  ensures the channel stays open.  The spender can always try to send
  the payment again.

<!-- The commit below appears to be a direct push to LND's master branch -->
- [LND 609cc8b][] adds a [security policy][lnd secpol], including
  instructions for reporting vulnerabilities.

- [Rust Bitcoin #957][] adds an API for signing [PSBTs][topic psbt].
  It does not support signing [taproot][topic taproot] spends yet.

- [BDK #779][] adds support for [low-r grinding][topic low-r grinding]
  of ECDSA signatures, which allows reducing the size for about half of
  all signatures by one byte.

{% include references.md %}
{% include linkers/issues.md v=2 issues="23927,25957,5646,6517,7001,6831,957,779,1036,845,1378,23578,22558" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[lnd 609cc8b]: https://github.com/LightningNetwork/lnd/commit/609cc8b883c7e6186e447e8d7e6349688d78d4fd
[lnd secpol]: https://github.com/lightningnetwork/lnd/security/policy
[towns consistency]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021116.html
[news205 rbf]: /en/newsletters/2022/06/22/#full-replace-by-fee
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[wuille bip324]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021115.html
[news72 xonly]: /en/newsletters/2019/11/13/#x-only-pubkeys
[compressed pubkeys]: https://developer.bitcoin.org/devguide/wallets.html#public-key-formats
[blinded payments]: /en/topics/rendez-vous-routing/
[news104 intercept]: /en/newsletters/2020/07/01/#lnd-4018
[news51 attrib]: /en/newsletters/2019/06/19/#authenticating-messages-about-ln-delays
[jager attrib]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003723.html
[russell attrib]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003727.html
[teinturier fees]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003729.html
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[lnd 0.15.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.4-beta
[lnd 0.14.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.5-beta
[news207 bc22558]: /en/newsletters/2022/07/06/#bitcoin-core-22558
