---
title: 'Bitcoin Optech Newsletter #192'
permalink: /en/newsletters/2022/03/23/
name: 2022-03-23-newsletter
slug: 2022-03-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussion about the speedy trial soft
fork activation mechanism and links to an update of an optimized LN
pathfinding algorithm.  Also included are our regular sections with
descriptions of recent changes to services and client software,
announcements of new releases and release candidates, and summaries of
notable changes to popular Bitcoin infrastructure software.

## News

- **Speedy trial discussion:** a mention of the speedy trial [soft fork
  activation method][topic soft fork activation] from the summary of a
  recent meeting about the proposed [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] opcode was spun off into a separate thread
  on the Bitcoin-Dev mailing list for additional discussion after Jorge
  Timón [expressed][timon st] concern about the use of speedy trial for
  a soft fork he thought was controversial.

    Russell O'Connor [explained][oconnor st] how the concerns had been
    previously addressed.  Anthony Towns further [described][towns st]
    how an unwanted soft fork activation using speedy trial could be
    resisted by objecting users.

- **Payment delivery algorithm update:** René Pickhardt [posted][pickhardt
  payment delivery] to the Lightning-Dev mailing list that he'd found a much
  more computationally efficient approximation for his and Stefan
  Richter's pathfinding algorithm published last year.  See [Newsletter
  #163][news163 pp] for earlier discussion about the algorithm.

    Pickhardt's email also suggests ways in which fast payment success
    could be improved, such as through the implementation of [stuckless
    payments][news53 stuckless] and by allowing [refundable
    overpayments][news86 boomerang] as proposed in [several][boomerang]
    academic [papers][spear].

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 2.1.0-rc.1][] is a release candidate for HWI that adds
  [taproot][topic taproot] support for several hardware signing devices,
  among other improvements and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Eclair #2203][] adds additional configuration parameters to allow
  users to specify a different minimum funding for [unannounced
  channels][topic unannounced channels] than the default used for
  announced channels.

- [LDK #1311][] adds support for the Short Channel Identifier (SCID)
  `alias` field proposed in [BOLTs #910][], which allows a node to
  request its peer identify a channel by an arbitrary value rather than
  one derived from the onchain transaction which anchors the channel.
  This can be useful for privacy by preventing the SCID from disclosing
  to third parties which transactions the node created, and it's also
  proposed for use in a specification for opt-in zero-conf channels
  (sometimes called *turbo channels*) as described in [Newsletter
  #156][news156 zcc].

- [LDK #1286][] adds offsets to CLTV (`OP_CHECKLOCKTIMEVERIFY`) values used
  for routing payments as [recommended by BOLT7][bolt7 route rec].  This
  makes it harder for someone observing part of the payment attempt
  (e.g. one of the nodes routing the payment) to correctly guess which
  node might be the intended receiver.

- [HWI #584][] adds support for paying [bech32m][topic bech32] addresses
  when using recent firmware versions with the BitBox02 hardware signing
  device.

- [HWI #581][] disables support for signing transactions with external inputs (e.g. in a [coinjoin][topic coinjoin])
  when using a Trezor with future firmware versions. This PR follows a firmware
  change that broke the workaround HWI was using to achieve support. A
  follow-up PR ([HWI #590][]) seems to indicate that Trezor is looking into
  giving users a way to sign such transactions in the future.

- [BDK #515][] begins retaining spent transaction outputs in the
  internal database.  This can be useful for creating [replacement
  transactions][topic rbf] and simplifies the [ongoing
  implementation][bdk #549] of [BIP47][] reusable payment codes.

{% include references.md %}
{% include linkers/issues.md v=1 issues="2203,1311,910,1286,584,581,515,549,590" %}
[hwi 2.1.0-rc.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.1.0-rc.1
[bolt7 route rec]: https://github.com/lightning/bolts/blob/master/07-routing-gossip.md#recommendations-for-routing
[oconnor st]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020106.html
[timon st]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020102.html
[towns st]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020127.html
[pickhardt payment delivery]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003510.html
[news163 pp]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[news53 stuckless]: /en/newsletters/2019/07/03/#stuckless-payments
[spear]: https://dl.acm.org/doi/10.1145/3479722.3480997
[news156 zcc]: /en/newsletters/2021/07/07/#zero-conf-channel-opens
[boomerang]: https://arxiv.org/pdf/1910.01834.pdf
[news86 boomerang]: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
