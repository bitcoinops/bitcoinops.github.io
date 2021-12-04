---
title: 'Bitcoin Optech Newsletter #178'
permalink: /en/newsletters/2021/12/08/
name: 2021-12-08-newsletter
slug: 2021-12-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a post about fee-bumping research and
contains our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, the latest releases and release candidates for Bitcoin software,
and notable changes to popular infrastructure projects.

## News

- **Fee bumping research:** Antoine Poinsot [posted][darosior bump] to
  the Bitcoin-Dev mailing list a detailed description of several concerns
  developers need to consider when choosing how to fee-bump presigned
  transactions used in [vaults][topic vaults] and contract protocols
  such as LN.  In particular, Poinsot looked at schemes for multiparty
  protocols with more than two participants, for which the current [CPFP
  carve out][topic cpfp carve out] transaction relay policy doesn't
  work, requiring them to use [transaction replacement][topic rbf]
  mechanisms that may be vulnerable to [transaction pinning][topic
  transaction pinning].  Also included in his post is the result of
  [research][revault research] into some of the ideas described earlier.

    Ensuring that fee bumping works reliably is a requirement for the
    safety of most contract protocols, and it remains a problem without any
    comprehensive solution yet.  It is encouraging to see continuing
    research into the problem.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:glozow

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/23173#l-FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 0.14.0][] is the latest release of this library for wallet
  developers.  It simplifies adding an `OP_RETURN` output to a
  transaction and contains improvements for sending payments to
  [bech32m][topic bech32] addresses for [taproot][topic taproot].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23155][] extends the `dumptxoutset` RPC with the hash
  of the chainstate snapshot (UTXO set) along with the number of
  transactions in the entire chain up until that point.  This
  information can be published alongside the chainstate so that others
  can verify it using the `gettxoutsetinfo` RPC, allowing it to be used
  with the proposed [assumeUTXO][topic assumeutxo] node bootstrapping.

- [Bitcoin Core #22513][] rpc: Allow walletprocesspsbt to sign without finalizing FIXME:adamjonas

- [C-Lightning #4921][] updates the implementation of [onion
  messages][topic onion messages] to match the latest updates to the
  draft specifications for [route blinding][bolts #765] and [onion
  messages][bolts #759].

- [C-Lightning #4829][] adds experimental support for the proposed
  LN protocol change in [BOLTs #911][] that will allow nodes to advertise
  their DNS address rather than their IP address or Tor onion service
  address.

- [Eclair #2061][] Relay onion messages FIXME:dongcarl

- [Eclair #2073][] adds support for the optional channel type negotiation
  feature bit as specified in draft [BOLTs #906][].  This corresponds
  to LND's implementation of the same draft feature [last week][news177
  lnd6026].

- [Rust-Lightning #1163][] allows the remote party to set their channel
  reserve below the dust limit, even all the way down to zero.  In the
  worst case, this allows the local node to costlessly attempt to steal
  funds from a fully-spent channel---although such a theft attempt will
  still fail if the remote party is monitoring their channels.  By
  default, most remote nodes discourage such attempts by setting a
  reasonable channel reserve, but some Lightning Service Providers
  (LSPs) use low or zero channel reserves order to provide users with a
  better experience---allowing them to spend 100% of the funds in the
  channel.  Since only the remote node is taking any risk, there's no
  problem allowing the local node to accept such channels.

{% include references.md %}
{% include linkers/issues.md issues="23155,22513,4921,4829,2061,2073,906,1163,765,759,911" %}
[bdk 0.14.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.14.0
[news177 lnd6026]: /en/newsletters/2021/12/01/#lnd-6026
[darosior bump]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019614.html
[revault research]: https://github.com/revault/research
