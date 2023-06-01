---
title: 'Bitcoin Optech Newsletter #179'
permalink: /en/newsletters/2021/12/15/
name: 2021-12-15-newsletter
slug: 2021-12-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to allow relay of
transactions with zero-value outputs in some cases and summarizes a
discussion about preparing LN for the adoption of PTLCs.  Also included
are our regular sections with a list of recent changes to services and
client software, popular questions on the Bitcoin Stack Exchange, and
notable changes to popular Bitcoin infrastructure software.

## News

- **Adding a special exception for certain uneconomical outputs:**
  since our description in [Newsletter #162][news162 unec], Jeremy Rubin
  has [renewed][rubin unec] discussion on the Bitcoin-Dev mailing list
  about allowing transactions to create outputs with values below the
  [dust limit][topic uneconomical outputs].  The dust limit is a
  transaction relay policy that nodes use to discourage users from
  creating UTXOs that don't make economic sense to spend.  UTXOs need to
  be stored by at least some full nodes until spent, and in some cases
  be able to be retrieved quickly, so allowing *uneconomical outputs*
  may create problems for no good reason.

    However, there may be a use for zero-value outputs in [CPFP][topic
    cpfp] fee bumping where none of the funds from the transaction
    being fee bumped can be spent---all the funds used for fee bumping
    need to come from separate UTXOs, such as in [eltoo][topic eltoo].
    Ruben Somsen also [provided][somsen unec] an example of how zero-fee
    outputs would be useful for spacechains (a type of one-way pegged
    sidechain).

    No clear conclusion was reached in the discussion as of this
    writing.

- **Preparing LN for PTLCs:** [[Bastien Teinturier]] started a
  [thread][teinturier post] on the Lightning-Dev mailing list about
  making the minimal [set of changes][ln docs 16] to the LN
  communication protocol necessary to allow nodes to begin upgrading to
  using [PTLCs][topic ptlc].  PTLCs are more private than the
  currently-used [HTLCs][topic htlc] and use less block space.

    Teinturier is trying to produce a set of changes that can be made at
    the same time as the proposed `option_simplified_update`
    [protocol change][bolts #867] (see [Newsletter #120][news120
    opt_simp_update]).  A secondary goal is trying to make the
    communication protocol compatible with the fast-forwards based PTLC
    protocol described in [Newsletter #152][news152 ff].  This will allow
    nodes to upgrade in stages, first to `option_simplified_update` with
    HTLCs, then to PTLCs, then to fast forwards.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Simple Bitcoin Wallet adds taproot sends:**
  SBW version [2.4.22][sbw 2.4.22] allows users to send to taproot addresses.

- **Trezor Suite supports taproot:**
  [Trezor announced][trezor taproot blog] that the 21.12.2 version of Trezor
  Suite supports [taproot][topic taproot]. After downloading the latest client
  and firmware, users can create a new taproot account.

- **BlueWallet adds taproot sends:**
  BlueWallet [v6.2.14][bluewallet 6.2.14] adds send support for taproot addresses.

- **Cash App adds taproot sends:**
  As of [December 1, 2021][cash app bech32m], Cash App users can send to
  [bech32m][topic bech32] addresses.

- **Swan adds taproot sends:**
  Swan [announced][swan taproot tweet] taproot withdrawal (send) support.

- **Wallet of Satoshi adds taproot sends:**
  [Wallet of Satoshi][wallet of satoshi website], a mobile Bitcoin and Lightning
  wallet, [announced][wallet of satoshi tweet] taproot send support.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What is the script assembly and execution in P2TR spend (spend from Taproot)?]({{bse}}111098)
  Pieter Wuille provides a detailed walk-through of a simplified [BIP341][]
  example of constructing a taproot output, spending using the keypath, spending
  using the scriptpath, and validating spends.

- [How can I find samples for P2TR transactions on mainnet?]({{bse}}110995)
  Murch provides [block explorer][topic block explorers] links for: the first P2TR
  transaction, the first transaction with a scriptpath and keypath input, the first
  transaction with multiple keypath inputs, the first scriptpath 2-of-2 multisig
  spend, and the first use of the new [tapscript][topic tapscript] opcode `OP_CHECKSIGADD`.

- [Does a miner adding transactions to a block while mining reset the block's PoW?]({{bse}}110903)
  Pieter Wuille explains that mining is [progress free][oconnor blog]. Each hash
  attempt to solve a block is independent from what work has been done so far,
  including if new transactions are added to a block currently being mined.

- [Can schnorr aggregate signatures be nested inside other schnorr aggregate signatures?]({{bse}}110862)
  Pieter Wuille describes the feasibility of a key-aggregation scheme using
  [schnorr signatures][topic schnorr signatures], where "keys can be aggregated
  hierarchically without signers having knowledge about their 'niece/nephew'
  keys". He notes that [MuSig2][topic musig] was designed to be compatible with
  nesting and that it could be modified for this use case, although no security
  proof exists.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23716][] adds a native Python implementation of
  RIPEMD-160 to Bitcoin Core's test code.  This allows Bitcoin Core to
  no longer use the RIPEMD-160 function from Python `hashlib` library
  which wraps the OpenSSL implementation of RIPEMD-160.  Newer versions
  of OpenSSL no longer provide RIPEMD-160 support by default, requiring
  it to be enabled separately.

- [Bitcoin Core #20295][] adds a new RPC `getblockfrompeer` which permits
  requesting a specific block from a specific peer manually. The intended use
  is acquisition of stale chaintips for fork monitoring and research purposes.

- [Bitcoin Core #14707][] updates several RPCs to also include bitcoins
  received via miner coinbase transaction outputs.  A new
  `include_immature_coinbase` option to the RPCs allows toggling
  the inclusion of coinbase transactions before they are mature (have
  100 confirmations, the earliest they can be spent according to
  consensus rules).

- [Bitcoin Core #23486][] updates the `decodescript` RPC to only return
  the P2SH or P2WSH addresses for a script if that script can be used,
  respectively, with P2SH or P2WSH.

- [BOLTs #940][] deprecates the announcement and parsing of Tor
  v2 onions in `node_announcements`. [Rust-Lightning #1204][], also
  merged this week, updates that implementation to follow this updated
  specification.

- [BOLTs #918][] removes the rate limiting of ping messages. `ping` messages
  are mainly used to check if the peer connection is still alive. Prior to
  this merge `ping` messages were supposed to be sent at most once every 30
  seconds. For many nodes it is useful to send heart beat messages via `ping`
  more frequently to assure a high quality of service. As other Lightning
  messages are not rate limited the 30 seconds rate limit for `ping` messages
  was also dropped.

- [BOLTs #906][] adds a new feature bit for the `channel_type` feature
  described in [Newsletter #165][news165 channel_type].  By adding a
  bit, it will become easier for future nodes to only choose peers that
  understand the new feature.

## Holiday publication schedule

Happy holidays! This issue is our final regular newsletter for the year.
Next week we’ll publish our annual special year-in-review issue. We’ll
return to regular publication on Wednesday, January 5th.

{% include references.md %}
{% include linkers/issues.md issues="867,23716,20295,14707,23486,940,906,1204,918" %}
[news162 unec]: /en/newsletters/2021/08/18/#dust-limit-discussion
[rubin unec]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-December/019635.html
[somsen unec]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-December/019637.html
[teinturier post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-December/003377.html
[ln docs 16]: https://github.com/t-bast/lightning-docs/pull/16
[news120 opt_simp_update]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[news152 ff]: /en/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key
[news165 channel_type]: /en/newsletters/2021/09/08/#bolts-880
[sbw 2.4.22]: https://github.com/btcontract/wallet/releases/tag/2.4.22
[bluewallet 6.2.14]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.2.14
[cash app bech32m]: https://cash.app/help/us/en-us/20211114-bitcoin-taproot-upgrade
[trezor taproot blog]: https://blog.trezor.io/trezor-suite-and-firmware-updates-december-2021-d1e74c3ea283
[swan taproot tweet]: https://twitter.com/SwanBitcoin/status/1468318386916663298
[wallet of satoshi website]: https://www.walletofsatoshi.com/
[wallet of satoshi tweet]: https://twitter.com/walletofsatoshi/status/1459782761472872451
[oconnor blog]: http://r6.ca/blog/20180225T160548Z.html
