---
title: 'Bitcoin Optech Newsletter #189'
permalink: /en/newsletters/2022/03/02/
name: 2022-03-02-newsletter
slug: 2022-03-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a new proposed `OP_EVICT` opcode and
includes our regular sections with summaries of new releases and release
candidates and notable changes to popular Bitcoin infrastructure
software.

## News

- **Proposed opcode to simplify shared UTXO ownership:** developer
  [[ZmnSCPxj]] [posted][zmnscpxj op_evict] to the Bitcoin-Dev mailing list a
  proposal for an `OP_EVICT` opcode as an alternative to the
  [previously proposed][news166 tluv] `OP_TAPLEAF_UPDATE_VERIFY` (TLUV)
  opcode.  Like TLUV, `OP_EVICT` is focused on use cases where more than
  two users share ownership of a single UTXO, such as [joinpools][topic
  joinpools], [channel factories][topic channel factories], and certain
  [covenants][topic covenants].  To understand how `OP_EVICT` works,
  imagine a joinpool where a single UTXO is controlled by four users:
  Alice, Bob, Carol, and Dan.

  Today, these four users can create a P2TR (taproot) output whose
  keypath spend allows them to use a protocol like [MuSig2][topic musig]
  to efficiently spend that output if they all participate in creating a
  signature.  But, if user Dan becomes unavailable or malicious, the
  only way for Alice, Bob, and Carol to maintain the privacy and
  efficiency advantages of remaining part of the joinpool is to have
  prepared in advance with Dan a tree of presigned transactions---not
  all of which need to be used, but all of which need to be ready to use
  to ensure complete fault tolerance.

  {:.center}
  [![Illustration of combinatorial blowup when using presigned
  transactions to ensure trustless withdrawal from a
  joinpool](/img/posts/2022-03-combinatorial-txes.dot.png)](/img/posts/2022-03-combinatorial-txes.dot.png)

  As the number of users sharing a UTXO increases, the number of
  presigned transactions that need to be created increases
  combinatorially, making the arrangement highly unscalable (just ten
  users requires presigning over a million transactions).  Other
  proposed opcodes such as TLUV and [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] can eliminate the combinatorial explosion.
  `OP_EVICT` accomplishes the same but ZmnSCPxj suggests it could be
  a superior option to those opcodes (for this usecase) because it uses
  less onchain data when removing members of the shared UTXO ownership
  group.

  If `OP_EVICT` were added in a soft fork, each member of the group
  could share a public key with the other members along with a
  signature for that key over an output paying the member the expected
  amount (e.g. 1 BTC for Alice, 2 BTC for Bob, etc).  Once each member
  had the pubkeys and signatures for all other members, they could
  trustlessly construct an address allowing spending the funds in either
  of two different ways:

    1. Using the taproot keypath spend, as described above.
    2. Using a scriptpath spend for a [tapscript][topic tapscript] using
       the `OP_EVICT` opcode

  <br>In the case of evicting Dan, the opcode would accept the following
  parameters:

  - **Shared pubkey:** the shared pubkey of the whole group, which could
    be efficiently provided using a single byte reference to a template

  - **Number of evictions:** the number of joinpool exit outputs to
    create (one in this case)

  - **Eviction outputs:** for the one output to Dan in this example, the
    data would provide its index position and Dan's signature for it.
    Dan's public key would be the same key used in the output he signed

  - **Unevicted signature:** a signature for a public key corresponding
    to the shared public key of the whole group minus the public keys
    used in the eviction outputs.  In other words, a signature from the
    remaining members of the group (Alice, Bob, and Carol in this
    example)

  This would allow Alice, Bob, and Carol to spend the group UTXO at any
  time without Dan's cooperation by creating a transaction with the
  output Dan previously signed, providing Dan's signature for that
  output, and providing a signature Alice, Bob, and Carol dynamically
  created over the entire spending transaction (which would cover the
  fees they chose to pay and allocate the remaining funds however they
  chose).

  `OP_EVICT` received a moderate amount of discussion on the mailing
  list as of this writing, with no major concerns noted but also roughly
  the same seemingly low level of enthusiasm which greeted the TLUV
  proposal last year.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BTCPay Server 1.4.6][] is this payment processing software's latest
  release.  Since the last release covered by Optech<!-- 1.4.2 -->, support
  has been added for [CPFP][topic cpfp] fee bumping, the ability to use
  additional features of LN URLs, plus multiple UI improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [HWI #550][] adds support for the latest loadable Bitcoin firmware for Ledger
  hardware signing devices, which natively supports version 2 [PSBT][topic psbt] and a
  subset of [output script descriptors][topic descriptors].

{% include references.md %}
{% include linkers/issues.md v=1 issues="550" %}
[btcpay server 1.4.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.4.6
[zmnscpxj op_evict]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019926.html
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
