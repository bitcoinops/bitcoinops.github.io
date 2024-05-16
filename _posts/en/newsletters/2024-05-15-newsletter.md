---
title: 'Bitcoin Optech Newsletter #302'
permalink: /en/newsletters/2024/05/15/
name: 2024-05-15-newsletter
slug: 2024-05-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the beta release of a full node
supporting utreexo and summarizes a two proposed extensions to BIP119
`OP_CHECKTEMPLATEVERIFY`.  Also included are our regular sections
announcing new releases and release candidates and describing notable
changes to popular Bitcoin infrastructure software.

## News

- **Release of utreexod beta:** Calvin Kim [posted][kim utreexo] to the
  Bitcoin-Dev mailing list to announce the beta release of utreexod, a
  full node with support for [utreexo][topic utreexo].  Utreexo allows a
  node to store a small commitment to the state of the UTXO set rather
  than the entire set itself; for example, a minimal commitment can be
  32 bytes and the current full set is about 12 GB, making the
  commitment on the order of about a billion times smaller.  To reduce
  bandwidth, utreexo may store additional commitments, increasing its
  use of disk space, but still keeping its chainstate roughly on the
  order of a million times smaller than a traditional full node.
  A utreexo node that also prunes old blocks can run in a small constant
  amount of disk space, whereas even pruned regular full nodes can have
  their chainstate grow beyond the bounds of a device's storage capacity.

  The release notes posted by Kim indicate that the node is compatible
  with [BDK][bdk repo]-based wallets, plus many other wallets through
  support for [Electrum personal server][].  The node supports
  transaction relay with extensions to the P2P network protocol for
  allowing the relay of utreexo proofs.  Both _regular_ and _bridge_ utreexo
  nodes are supported; regular utreexo nodes use the utreexo commitment
  to save disk space; bridge nodes store the complete UTXO state plus
  some additional data and can attach utreexo proofs to blocks and
  transactions created by nodes and wallets that don't support utreexo
  yet.

  Utreexo does not require consensus changes and utreexo nodes do
  not interfere with non-utreexo nodes, although regular utreexo nodes
  can only peer with other regular and bridge utreexo nodes.

  Kim includes several warnings in his announcement: "the code and
  protocol is not peer reviewed [...] there will be breaking changes
  [...] utreexod is based on [btcd][] [which may have] consensus
  incompatibilities". {% assign timestamp="0:56" %}

- **BIP119 extensions for smaller hashes and arbitrary data commitments:**
  Jeremy Rubin [posted][rubin bip119e] to the Bitcoin-Dev mailing list a
  [proposed BIP][bip119e] to extend the proposed
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (`OP_CTV`) with
  two additional features:

  - *Support for HASH160 hashes:* these are the hash digests used for
    P2PKH, P2SH, and P2WPKH addresses.  They are 20 bytes compared to
    the 32-byte hash digests used in the base [BIP119][] proposal.  In
    naive multiparty protocols, a [collision attack][] against a 20-byte
    hash can be performed in about 2<sup>80</sup> brute force
    operations, which is within reach of a highly motivated attacker.
    For this reason, modern Bitcoin opcodes typically use 32-byte
    hash digests.  However, security in single-party protocols or
    well-designed multiparty protocols using 20-byte hashes can be
    increased to make compromise unlikely in less than about
    2<sup>160</sup> brute-force operations, allowing those protocols to
    save about 12 bytes per digest.  One case where that might be useful
    is in implementations of the [eltoo][topic eltoo] protocol (see
    [Newsletter #284][news284 eltoo]).

  - *Support for additional commitments:* `OP_CTV` only succeeds if it
    is executed within a transaction that contains inputs and outputs
    that hash to the same value as a provided hash digest.  One of those
    outputs could be an `OP_RETURN` output that commits to some data
    that the script creator wants to be published to the blockchain, such as
    data necessary to recover LN channel state from a backup.  However,
    putting data in the witness field would be significantly less expensive.
    The proposed updated form of `OP_CTV` allows a script creator to require that an additional piece
    of data from the witness stack be included when the inputs and
    outputs are hashed.  That data will be checked against the hash digest provided by
    the script creator.  This ensures that data is published to the
    blockchain with minimal use of block weight.

  The proposal has not received any discussion on the mailing list as of
  this writing. {% assign timestamp="20:15" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK v0.0.123][] is a release of this popular library for building
  LN-enabled applications.  It includes an update to its settings for
  [trimmed HTLCs][topic trimmed htlc], improvements to [offers][topic
  offers] support, and many other improvements. {% assign timestamp="25:16" %}

- [LND v0.18.0-beta.rc2][] is a release candidate for the next major
  version of this popular LN node. {% assign timestamp="26:08" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #29845][] updates several `get*info` RPCs to change the
  `warnings` field from a string to an array of strings so that several
  warnings can be returned instead of just one. {% assign timestamp="28:16" %}

- [Core Lightning #7111][] makes the `check` RPC command available to
  plugins through the libplugin utility. Usage is also extended by
  enabling `check setconfig` which validates that configuration options
  would be accepted, and the existing `check keysend` now validates if
  hsmd would approve the transaction. A pre-initialization message has
  been added with pre-set HSM development flags. For further references
  on the `check` command, see also Newsletters [#25][news25 cln check]
  and [#47][news47 cln check]. {% assign timestamp="29:34" %}

- [Libsecp256k1 #1518][] adds a `secp256k1_pubkey_sort` function that
  sorts a set of public keys into a canonical order.  This is useful for
  both [MuSig2][topic musig] and [silent payments][topic silent
  payments], and likely many other protocols involving multiple keys. {% assign timestamp="32:04" %}

- [Rust Bitcoin #2707][] updates the API for tagged hashes
  introduced as part of [taproot][topic taproot] to expect the digests in
  _internal byte order_ by default.  Previously, the API expected the
  hashes in _display byte order_, which can now be obtained with code
  like `#[hash_newtype(backward)]`.  For [historical reasons][mb3e byte
  order], the txid and block identifier hash digests appear inside
  transactions and blocks in one byte order (internal byte order) but
  are displayed and called in user interfaces in the reverse order
  (display byte order).  This PR tries to prevent even more hashes from
  having different byte orders for different circumstances. {% assign timestamp="34:30" %}

- [BIPs #1389][] adds [BIP388][] which describes "wallet policies for
  descriptor wallets", a templated set of [output script
  descriptors][topic descriptors] that may be easier for a broad set of
  wallets to support in both code and their user interface.  In
  particular, descriptors can be challenging to implement on hardware
  wallets with limited resources and limited screen space.  The BIP388
  wallet policies allow software and hardware that opts-in to it to
  make simplifying assumptions about how descriptors will be used; this
  minimizes the scope of descriptors, reducing the amount of code needed
  and the number of details that need to be verified by users.  Any
  software needing the full power of descriptors can still use them
  independently of BIP388.  For additional information, see [Newsletter
  #200][news200 policies]. {% assign timestamp="37:29" %}

- [BIPs #1567][] adds [BIP387][] with new `multi_a()` and
  `sortedmulti_a()` descriptors that provide scripted multisig
  capabilities within [tapscript][topic tapscript].  Taking an example
  from the BIP, the descriptor fragment
  `multi_a(k,KEY_1,KEY_2,...,KEY_n)` will produce a script such as
  `KEY_1 OP_CHECKSIG KEY_2 OP_CHECKSIGADD ... KEY_n OP_CHECKSIGADD OP_k
  OP_NUMEQUAL`.  See also Newsletters [#191][news191 multi_a],
  [#227][news227 multi_a], and [#273][news273 multi_a]. {% assign timestamp="42:21" %}

- [BIPs #1525][] adds [BIP347][] which proposes an [OP_CAT][topic
  op_cat] opcode that could be used in [tapscript][topic tapscript] if
  it was [activated][topic soft fork activation] in a soft fork.  See
  also Newsletters [#274][news274 op_cat], [#275][news275 op_cat],
  and [#293][news293 op_cat]. {% assign timestamp="44:08" %}

## Newsletter publication date changes

In the coming weeks, Optech will be experimenting with alternative
publication dates.  Please don't be surprised if you receive the
newsletter a few days early or late.  During the brief experiment
period, our emailed newsletters will include a tracker to help us
determine how many people read the newsletter.  You can prevent tracking
by disabling the loading of external resources before reading the
newsletter.  If you desire even more privacy, we recommend subscribing
to our [RSS feed][] over an ephemeral Tor connection.  We apologize for
any inconvenience. {% assign timestamp="46:05" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1525,1567,1389,2707,1518,7111,29845" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[mb3e byte order]: https://github.com/bitcoinbook/bitcoinbook/blob/6d1c26e1640ae32b28389d5ae4caf1214c2be7db/ch06_transactions.adoc#internal_and_display_order
[news200 policies]: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices
[news191 multi_a]: /en/newsletters/2022/03/16/#bitcoin-core-24043
[news227 multi_a]: /en/newsletters/2022/11/23/#how-do-i-create-a-taproot-multisig-address
[news273 multi_a]: /en/newsletters/2023/10/18/#bitcoin-core-27255
[news274 op_cat]: /en/newsletters/2023/10/25/#proposed-bip-for-op-cat
[news275 op_cat]: /en/newsletters/2023/11/01/#op-cat-proposal
[news293 op_cat]: /en/newsletters/2024/03/13/#bitcoin-core-pr-review-club
[kim utreexo]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d5f47120-3397-4f56-93ca-dd310d845f3cn@googlegroups.com/T/#u
[electrum personal server]: https://github.com/chris-belcher/electrum-personal-server
[btcd]: https://github.com/btcsuite/btcd
[rubin bip119e]: https://mailing-list.bitcoindevs.xyz/bitcoindev/35cba1cd-eb67-48d1-9615-e36f2e78d051n@googlegroups.com/T/#u
[bip119e]: https://github.com/bitcoin/bips/pull/1587
[news284 eltoo]: /en/newsletters/2024/01/10/#ctv
[collision attack]: https://en.wikipedia.org/wiki/Collision_attack
[rss feed]: /feed.xml
[ldk v0.0.123]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.123
[news25 cln check]: /en/newsletters/2018/12/11/#c-lightning-2123
[news47 cln check]: /en/newsletters/2019/05/21/#c-lightning-2631
