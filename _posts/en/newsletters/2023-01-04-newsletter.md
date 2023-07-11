---
title: 'Bitcoin Optech Newsletter #232'
permalink: /en/newsletters/2023/01/04/
name: 2023-01-04-newsletter
slug: 2023-01-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter warns users of Bitcoin Knots about a release
signing key compromise, announces the release of two software forks of
Bitcoin Core, and summarizes continued discussion about replace-by-fee
policies.  Also included are our regular sections with the announcements
of new software releases and release candidates, plus descriptions of
notable changes to popular Bitcoin infrastructure software.

## News

- **Bitcoin Knots signing key compromised:** the maintainer of Bitcoin
  Knots full node implementation announced the compromise of the PGP key
  they use to sign releases of Knots.  They say, "do not download
  Bitcoin Knots and trust it until this is resolved.  If you already did
  in the last few months, consider shutting that system down for now."
  <!-- https://web.archive.org/web/20230103220745/https://twitter.com/LukeDashjr/status/1609763079423655938 -->
  Other full node implementations are unaffected. {% assign timestamp="1:06" %}

- **Software forks of Bitcoin Core:** last month saw the release of two
  patchsets on top of Bitcoin Core:

    - *Bitcoin Inquisition:* Anthony Towns [announced][towns bci] to the
      Bitcoin-Dev mailing list a version of [Bitcoin Inquisition][], a
      software fork of Bitcoin Core designed to be used on the default
      [signet][topic signet] for testing proposed soft forks and other
      significant protocol changes.  This version contains support for
      the [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] and
      [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] proposals.
      Towns's email also includes additional information that will be
      useful to anyone participating in the signet tests.

    - *Full-RBF peering node:* Peter Todd [announced][todd rbf node] a
      patch on top of Bitcoin Core 24.0.1 that sets a [full-RBF service
      bit][] when it advertises its network address to other nodes,
      although only if the node is configured with `mempoolfullrbf`
      enabled.  Nodes running the patch also connect to up to four
      additional peers which had advertised that they support full-RBF.
      Peter Todd notes that Bitcoin Knots, another full node implementation, also
      advertises the service bit, although it doesn't contain code to
      specifically peer with nodes advertising full-RBF support.  The
      patch is based on Bitcoin Core PR [#25600][bitcoin core #25600]. {% assign timestamp="7:53" %}

- **Continued RBF discussion:** in ongoing discussion about enabling
  [full-RBF][topic rbf] on mainnet, several parallel discussions were
  held last month on the mailing list:

    - *Full-RBF nodes:* Peter Todd probed full nodes which advertised
      that they were running Bitcoin Core 24.x and were accepting
      incoming connections on an IPv4 address.  He [found][todd probe]
      that about 17% relayed a full-RBF replacement: a transaction which
      replaced a transaction that did not contain the [BIP125][]
      signal.  This suggests those nodes were running with
      the `mempoolfullrbf` configuration option set to `true`, even
      though the option defaults to `false`.

    - *Reconsideration of RBF-FSS:*  Daniel Lipshitz [posted][lipshitz
      fss] to the Bitcoin-Dev mailing list an idea for a type of
      transaction replacement called First Seen Safe (FSS) where the
      replacement would pay the original outputs at least the same
      amounts as the original transaction, ensuring the replacement
      mechanism couldn't be used to steal from the receiver of the
      original transaction.  Yuval Kogman [replied][kogman fss] with a
      link to an [earlier version][rbf-fss] of the same idea posted in
      2015 Peter Todd.  In a [subsequent][todd fss] reply, Todd
      described several ways in which the idea is much less preferable
      than opt-in or full RBF.

    - *Full-RBF motivation:* Anthony Towns [replied][towns rbfm] to a
      thread about the motivation for various groups to perform
      full-RBF.  Towns analyzes what economic rationality means---and
      does not mean---in the context of miner transaction selection.
      Miners optimizing for very short term profits would naturally
      prefer full-RBF.  However, Towns notes that miners who have made a
      long-term capital investment in mining equipment might instead
      prefer to optimize fee income over multiple blocks, and that might
      not always favor full-RBF.  He suggests three possible scenarios
      for consideration. {% assign timestamp="23:39" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair 0.8.0][] is a major version release for this popular LN node
  implementation.  It adds support for [zero-conf channels][topic
  zero-conf channels] and Short Channel IDentifier (SCID) aliases.  See
  its [release notes][eclair 0.8 rn] for more information about those
  features and other changes. {% assign timestamp="42:19" %}

- [LDK 0.0.113][] is a new version of this library for building
  LN-enabled wallets and applications. {% assign timestamp="43:48" %}

- [BDK 0.26.0-rc.2][] is a release candidate of this library for
  building wallets. {% assign timestamp="44:45" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26265][] relaxes the minimum permitted non-witness
  serialized size of transactions in transaction relay policy from 82
bytes to 65 bytes. For example, a transaction with a single input and
single output with 4 bytes of OP\_RETURN padding, which previously
would have been rejected for being too small, could now be accepted
into the node's mempool and relayed. See [Newsletter #222][min relay
size ml] for background information and motivation for this change. {% assign timestamp="47:04" %}

- [Bitcoin Core #21576][] allows wallets using an external signer (e.g. [HWI][topic hwi]) to fee bump
  using [opt-in RBF][topic rbf] in the GUI and when using the `bumpfee` RPC. {% assign timestamp="48:47" %}

- [Bitcoin Core #24865][] allows a wallet backup to be restored on a
  node that has been pruned of older blocks as long as the node still
  has all of the blocks produced after the wallet was created.  The
  blocks are needed so that Bitcoin Core can scan them for any
  transactions affecting the wallet's balance.  Bitcoin Core is able to
  determine the age of the wallet because its backup contains the date
  the wallet was created. {% assign timestamp="49:44" %}

- [Bitcoin Core #23319][] updates the `getrawtransaction` RPC to provide
  additional information if the `verbose` parameter is set to `2`.  The
  additional information includes the fee the transaction paid and
  information about each of the outputs from previous transactions
  ("prevouts") which are spent by being used as inputs to this
  transaction.  See [Newsletter #172][news172 prevout] for details about
  the method used to retrieve the information. {% assign timestamp="52:52" %}

- [Bitcoin Core #26628][] begins rejecting RPC requests that include the
  same parameter name multiple times.  Previously, the daemon treated a
  request with repeated parameters as if it only had the last of the repeated
  parameters, e.g. `{"foo"="bar", "foo"="baz"}` was treated as
  `{"foo"="baz"}`.  Now the request will fail.  When using `bitcoin-cli`
  with named parameters, the behavior is unchanged: multiple parameters using the same name
  will not be rejected but only the last of the repeats will be sent. {% assign timestamp="54:25" %}

- [Eclair #2464][] adds the ability to trigger an event when a remote
  peer becomes ready to process payments.  This is especially useful in
  the context of [async payments][topic async payments] where the local
  node temporarily holds a payment for a remote peer, waits for the peer
  to connect (or reconnect), and delivers the payment. {% assign timestamp="56:29" %}

- [Eclair #2482][] allows sending payments using [blinded routes][topic
  rv routing], which are paths whose last several hops are chosen
  by the receiver.  The receiver uses onion encryption to obfuscate the
  hop details and then provides the encrypted data to the spender, along with
  the identity of the first node along the blinded route.  The spender
  then constructs a payment path to that first node and includes the
  encrypted details for the operators of the last several nodes to
  decrypt and use to forward the payment to the receiver.  This allows
  the receiver to accept a payment without disclosing the identity of
  their node or channels to the spender, improving privacy. {% assign timestamp="58:43" %}

- [LND #2208][] begins preferring different payment paths depending on
  the maximum capacity of a channel relative to the amount to be spent.
  As the amount to be sent approaches the capacity of a channel, that
  channel becomes less likely to be selected for a path.  This is
  broadly similar to pathfinding code already used in Core Lightning and
  LDK. {% assign timestamp="59:29" %}

- [LDK #1738][] and [#1908][ldk #1908] provide additional features for handling
  [offers][topic offers]. {% assign timestamp="1:02:42" %}

- [Rust Bitcoin #1467][] adds methods for calculating the size in
  [weight units][] of transaction inputs and outputs. {% assign timestamp="1:03:42" %}

- [Rust Bitcoin #1330][] removes the `PackedLockTime` type, requiring
  downstream code instead use the almost-identical `absolute::LockTime` type.  A
  difference between the two types which may need to be investigated by
  anyone updating their code is that `PackedLockTime` provided an `Ord`
  characteristic but `absolute::LockTime` does not (although the
  locktime will be considered in the `Ord` of the transaction containing
  it). {% assign timestamp="1:04:00" %}

- [BTCPay Server #4411][] updates to using Core Lightning 22.11 (see
  [Newsletter #229][news229 cln]).  Anyone who wants to put a hash of an
  order description inside a [BOLT11][] invoice no longer needs to use the
  `invoiceWithDescriptionHash` plugin but can instead set the
  `description` field and enable the `descriptionHashOnly` option. {% assign timestamp="1:05:52" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="26265,21576,24865,23319,26628,2464,2482,2208,1738,1908,1467,1330,4411,25600" %}
[news172 prevout]: /en/newsletters/2021/10/27/#bitcoin-core-22918
[weight units]: https://en.bitcoin.it/wiki/Weight_units
[towns bci]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021275.html
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin
[todd probe]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021296.html
[lipshitz fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021272.html
[kogman fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021274.html
[todd fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021286.html
[rbf-fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-May/008248.html
[towns rbfm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021276.html
[todd rbf node]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021270.html
[news229 cln]: /en/newsletters/2022/12/07/#core-lightning-22-11
[full-rbf service bit]: https://github.com/petertodd/bitcoin/commit/c15b8d70778238abfa751e4216a97140be6369af
[eclair 0.8.0]: https://github.com/ACINQ/eclair/releases/tag/v0.8.0
[eclair 0.8 rn]: https://github.com/ACINQ/eclair/blob/master/docs/release-notes/eclair-v0.8.0.md
[ldk 0.0.113]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.113
[bdk 0.26.0-rc.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.26.0-rc.2
[min relay size ml]: /en/newsletters/2022/10/19/#minimum-relayable-transaction-size
