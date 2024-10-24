---
title: 'Bitcoin Optech Newsletter #326'
permalink: /en/newsletters/2024/10/25/
name: 2024-10-25-newsletter
slug: 2024-10-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME

## News

- **Updates to the version 1.75 channel announcements proposal:** Elle
  Mouton [posted][mouton chanann] to Delving Bitcoin a description of
  several proposed changes to the [new channel announcements][topic
  channel announcements] protocol that will support advertising [simple
  taproot channels][topic simple taproot channels].  The most
  significant planned change is to allow the messages to also announce
  current-style P2WSH channels; this will allow nodes to later "start
  switching off the legacy protocol [...] when most of the network seems
  to have upgraded".

  Another addition, recently discussed (see [Newsletter #325][news325
  chanann]), is to allow announcements to include an SPV proof so that
  any client that has all of the headers from the most-proof-of-work
  blockchain can verify that the channel's funding transaction was
  included in a block.  Currently, lightweight clients must download an
  entire block to perform the same level of verification of a channel
  announcement.

  Mouton's post also briefly discusses allowing opt-in announcement of
  existing simple taproot channels.  Due to the current lack of support
  for announcements of non-P2WSH channels, all existing taproot channels
  are [unannounced][topic unannounced channels].  A possible feature
  that can be added to the proposal will allow nodes to signal to their
  peers that they want to convert an unannounced channel to a public
  channel.

- **Draft BIP for sending silent payments with PSBTs:** Andrew Toth
  [posted][toth sp-psbt] to the Bitcoin-Dev mailing list a draft BIP for
  allowing wallets and signing devices to use [PSBTs][topic psbt] to
  coordinate the creation of a [silent payment][topic silent payments].
  This continues previous discussion about an earlier iteration of the
  draft BIP, see Newsletters [#304][news304 sp] and [#308][news308 sp].
  As mentioned in those earlier newsletters, a special requirement of
  silent payments over most other PSBT-coordinated transactions is that
  any change to a not-fully-signed transaction's inputs requires
  revising the outputs.

  The draft only addresses the most common expected situation where a
  signer has access to the private keys for all inputs in a transaction.
  For the less common situation of multiple signers, Toth writes that
  "this will be specified in a following BIP".

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Duplicate blocks in blk*.dat files?]({{bse}}124368)
  Pieter Wuille explains that, in addition to the current best chain of blocks,
  the block data files can also include stale blocks or duplicate block data.

- [How was the structure of pay-to-anchor decided?]({{bse}}124383)
  Antoine Poinsot describes the structure of the [pay-to-anchor (P2A)][topic
  ephemeral anchors] outputs included as part of Bitcoin Core 28.0's [policy
  changes][bcc28 guide]. The [bech32m][topic bech32] encoded, 2-byte length, v1
  witness program was chosen as a `bc1pfeessrawgf` vanity address.

- [What are the benefits of decoy packets in BIP324?]({{bse}}124301)
  Pieter Wuille outlines design decisions around the [inclusion of decoy
  packets][bip324 decoy packets] in the [BIP324][] specification. The optional
  decoy packets can be used to obfuscate traffic pattern recognition by
  observers during the key exchange, application, and version negotiation phases
  of the protocol.

- [Why is the opcode limit 201?]({{bse}}124465)
  Vojtěch Strnad points out code changes by Satoshi during 2010 that intended to
  introduce an opcode limit of 200, but due to an implementation error, actually
  introduced a limit of 201.

- [Will my node relay a transaction if it is below my minimum tx relay fee?]({{bse}}124387)
  Murch notes that a node will only relay transactions that it accepts into its
  own mempool. While a user could decrease their node's `minTxRelayFee` value to
  allow local mempool acceptance, inclusion of a lower relay feerate transaction
  in a block would still ultimately require a miner running a similar setting
  and for average feerates to decrease toward that lower feerate.

- [Why doesnt the Bitcoin Core wallet support BIP69?]({{bse}}124382)
  Murch agrees that universal implementation of [BIP69][]'s transaction
  input/output ordering specification would help mitigate [wallet
  fingerprinting][ishaana fingerprinting], but points out that given the
  unlikelihood of universal adoption, implementing BIP69 is itself a
  fingerprinting vulnerability.

- [How can I enable testnet4 on Bitcoin Core 28.0?]({{bse}}124443)
  Pieter Wuille mentions two configuration options that enable [BIP94][]'s
  [testnet4][topic testnet]: `chain=testnet4` and `testnet4=1`.

- [What are the risks of broadcasting a transaction that reveals a `scriptPubKey` using a low-entropy key?]({{bse}}124296)
  User Quuxplusone links to a recent transaction associated with a series of
  Bitcoin key-grinding ["puzzles"][puzzle bitcointalk] from 2015 that is
  [theorized][puzzle stackernews] to have been [replaced][topic rbf] by a bot
  monitoring the mempool for low-entropy keys.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- Core Lightning 24.08.2 FIXME:harding

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Eclair #2925][] introduces support for using [RBF][topic rbf] with
  [splicing][topic splicing] transactions via the new `rbfsplice` API command,
  which triggers a `tx_init_rbf` and `tx_ack_rbf` message exchange for peers to
  agree to replace the transaction. This feature is only enabled for
  non-[zero-conf channels][topic zero-conf channels], to prevent potential theft
  of funds on zero-conf channels. Chains of unconfirmed splice transactions are
  allowed on zero-conf channels, but not on non-zero-conf channels. In addition,
  RBF is blocked on liquidity purchase transactions via the [liquidity
  advertisement][topic liquidity advertisements] protocol, to avoid edge cases
  where sellers might add liquidity to a channel without receiving payment.

- [LND #9172][] adds a new `mac_root_key` flag to the `lncli create` and `lncli
  createwatchonly` commands for deterministic macaroon (authentication token)
  generation, allowing external keys to be baked into an LND node before it's
  even initialized. This is particularly useful in combination with the reverse
  remote signer setup suggested in [LND #8754][]. See Newsletter [#172][news172
  remote].

- [Rust Bitcoin #2960][] turns the [ChaCha20-Poly1305][rfc8439] authenticated
  encryption with associated data (AEAD) algorithm into its own crate, allowing
  it to be used beyond just the [v2 transport protocol][topic v2 p2p transport]
  specified in [BIP324][], such as for [payjoin V2][topic payjoin]. The code has
  been optimized for Single Instruction, Multiple Data (SIMD) instruction
  support to improve performance across various use cases. See Newsletter
  [#264][news264 chacha].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2925,9172,2960,8754" %}
[mouton chanann]: https://delvingbitcoin.org/t/updates-to-the-gossip-1-75-proposal-post-ln-summit-meeting/1202/
[news325 chanann]: /en/newsletters/2024/10/18/#gossip-upgrade
[toth sp-psbt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cde77c84-b576-4d66-aa80-efaf4e50468fn@googlegroups.com/
[news304 sp]: /en/newsletters/2024/05/24/#discussion-about-psbts-for-silent-payments
[news308 sp]: /en/newsletters/2024/06/21/#continued-discussion-of-psbts-for-silent-payments
[news172 remote]: /en/newsletters/2021/10/27/#lnd-5689
[rfc8439]: https://datatracker.ietf.org/doc/html/rfc8439
[news264 chacha]: /en/newsletters/2023/08/16/#bitcoin-core-28008
[bcc28 guide]: /en/bitcoin-core-28-wallet-integration-guide/
[bip324 decoy packets]: https://github.com/bitcoin/bips/blob/22660ad3078ee9bd106e64d44662a59a1967c4bd/bip-0324.mediawiki?plain=1#L126
[ishaana fingerprinting]: https://ishaana.com/blog/wallet_fingerprinting/
[puzzle bitcointalk]: https://bitcointalk.org/index.php?topic=1306983.0
[puzzle stackernews]: https://stacker.news/items/683489
