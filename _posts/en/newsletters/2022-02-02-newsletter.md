---
title: 'Bitcoin Optech Newsletter #185'
permalink: /en/newsletters/2022/02/02/
name: 2022-02-02-newsletter
slug: 2022-02-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes an analysis of the proposed
`OP_CHECKTEMPLATEVERIFY` (CTV) opcode's effect on discreet log contracts
and summarizes a discussion about alternative changes to tapscript to
enable CTV and `SIGHASH_ANYPREVOUT`.  Also included are our regular
sections with announcements of new releases and notable changes to
popular Bitcoin infrastructure software.

## News

- **Improving DLC efficiency by changing script:** Lloyd Fournier
  [posted][fournier ctv dlc] to the DLC-Dev and Bitcoin-Dev mailing
  lists about how the proposed [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV) opcode could radically reduce the number
  of signatures required to create certain Discreet Log Contracts
  ([DLCs][topic dlc]), as well as reduce the number of some other
  operations.

  In brief, for each possible terminal state of a contract---e.g., Alice
  gets 1 BTC, Bob gets 2 BTC---DLCs currently require creating a
  separate [signature adaptor][topic adaptor signatures] for that state.
  Many contracts define a large number of possible terminal states, such
  as a contract about the future price of bitcoins which specify prices
  rounded to the nearest dollar and need to cover several thousand
  dollars worth of price range even for a relatively short-term
  contract.  That requires the participants to create, exchange, and store
  thousands of partial signatures.

  Instead, Fournier suggests that the thousands of possible states be
  created using CTV in a [tapleaf][topic tapscript] which commits to the
  outputs to put onchain.  CTV commits to outputs using hashes, so
  parties can compute all the possible state hashes themselves quickly
  and on-demand, minimizing computation, data exchange, and data
  storage.  Some signatures are still used, but the number is greatly
  reduced.  In the case of contracts using multiple oracles (e.g.
  multiple price data providers for an exchange rate contract), there's
  a further simplification and reduction in the amount of data required.

  Jonas Nick [noted][nick apo dlc] that a similar optimization is also
  possible using the proposed [SIGHASH_ANYPREVOUT][topic
  sighash_anyprevout] signature hash mode (and we'll note that the same
  optimization is also available using the alternatives described in the
  following news item).

- **Composable alternatives to CTV and APO:** Russell O'Connor
  [posted][oconnor txhash] to the Bitcoin-Dev mailing list the idea for
  a soft fork to add two new opcodes to Bitcoin's [Tapscript][topic
  tapscript] language.  A tapscript could use the new `OP_TXHASH` opcode
  to specify which parts of a spending transaction should be serialized
  and hashed, with the hash digest being put on the evaluation stack for
  later opcodes to use.  A new [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack] (CSFS) opcode (as previously proposed) would
  allow a tapscript to specify a public key and require a corresponding
  signature over particular data on the stack---such as the computed
  digest of the transaction created by `OP_TXHASH`.

    O'Connor explained how these two opcodes would allow emulation of
    two earlier soft fork proposals, [SIGHASH_ANYPREVOUT][topic
    sighash_anyprevout] (APO, specified in [BIP118][]) and
    [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV,
    specified in [BIP119][]).  For some purposes, the emulation might be
    less efficient than using CTV or APO directly, but `OP_TXHASH` and
    `OP_CSFS` would keep the Tapscript language simpler and provide more
    flexibility for future script writers, especially if combined
    with other simple additions to tapscript such as [OP_CAT][].

    In a [reply][towns pop_sigdata], Anthony Towns suggested a similar
    approach using other alternative opcodes.

    The ideas were still being actively discussed as this summary was
    being written.  We expect to revisit the topic in a future
    newsletter.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BTCPay Server 1.4.2][] is the latest release in the new 1.4.x series,
  which includes improvements in login authentication and a number of
  [user interface improvements][btcpay ui blog].

- [BDK 0.16.0][] is a release that includes a number of bug fixes and
  small improvements.

- [Eclair 0.7.0][] is a new major release that adds support for [anchor
  outputs][topic anchor outputs], relaying [onion messages][topic onion
  messages], and using the PostgreSQL database in production.

- [LND 0.14.2-beta.rc1][lnd 0.14.2-beta] is the release candidate for a
  maintenance version that includes several bug fixes and a few minor
  improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23201][] improves the ability of wallet users to fund
  transactions with external inputs (previously mentioned in [Newsletter
  #170][news170 external inputs]) by allowing them to specify maximum
  weights instead of solving data.  This enables applications to use
  `fundrawtransaction`, `send`, and `walletfundpsbt` RPCs to fee bump
  transactions with nonstandard outputs such as [HTLCs][topic htlc] (a requirement for
  LN clients described in [Newsletter #184][news184 eclair auto bump]).

- [Eclair #2141][] improves the automatic fee bumping mechanism (previously
  covered in [Newsletter #184][news184 eclair auto bump]) by choosing a more
  aggressive confirmation target when the wallet is low on UTXOs. In such
  situations, it is important to have the fee bump transaction confirm quickly
  to preserve the wallet's UTXO count in case of further force-closes. More
  details on the anchor outputs-style fee bumping used by Eclair can be found
  [here][topic anchor outputs].

- [BTCPay Server #3341][] Add configurable BOLT11Expiration for refunds (Fix #3281) FIXME:bitschmidty

{% include references.md %}
{% include linkers/issues.md issues="23201,2141,3341" %}
[btcpay server 1.4.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.4.2
[bdk 0.16.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.16.0
[eclair 0.7.0]: https://github.com/ACINQ/eclair/releases/tag/v0.7.0
[lnd 0.14.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.2-beta.rc1
[btcpay ui blog]: https://blog.btcpayserver.org/btcpay-server-1-4-0/
[fournier ctv dlc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019808.html
[nick apo dlc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019812.html
[oconnor txhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019813.html
[towns pop_sigdata]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019819.html
[news184 eclair auto bump]: /en/newsletters/2022/01/26/#eclair-2113
[news170 external inputs]: /en/newsletters/2021/10/13/#bitcoin-core-17211
