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

- **Preparing LN for PTLCs:** Bastien Teinturier started a
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

## FIXME:bitschmidty special sections

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
