---
title: 'Bitcoin Optech Newsletter #131'
permalink: /en/newsletters/2021/01/13/
name: 2021-01-13-newsletter
slug: 2021-01-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a new proposed Bitcoin P2P protocol
message, a BIP for the bech32 modified address format, and an idea for
preventing UTXO probing in proposed dual-funded LN channels.  Also
included are our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, a list of releases and release candidates, and
descriptions of notable changes to popular Bitcoin infrastructure
software.

## News

- **Proposed `disabletx` message:** in 2012, [BIP37][] was published,
  giving lightweight clients the ability to request that peers not
  relay to the client any unconfirmed transactions until the client
  had loaded a [bloom filter][topic transaction bloom filtering].
  Bitcoin Core [later][bitcoin core #6993] reused this mechanism for its
  bandwidth-saving `-blocksonly` mode where a node requests that its
  peers don't send it any unconfirmed transactions at all.  Last year,
  Bitcoin Core with default settings began opening a few
  block-relay-only connections as an efficient way to improve [eclipse
  attack][topic eclipse attacks] resistance without significantly
  increasing bandwidth or reducing privacy (see [Newsletter #63][news63
  bcc15759]).  However, the BIP37 mechanism being used to suppress
  transaction relay allows the initiating node to request full
  transaction relay at any time.  Transaction relay consumes node
  resources such as memory and bandwidth, so nodes need to set their
  connection limits with the assumption that each
  BIP37-based low-bandwidth blocks-relay-only connection could suddenly
  become a full transaction relay connection.

    This week, Suhas Daftuar [posted][daftuar disabletx] to the
    Bitcoin-Dev mailing list a new proposed BIP for a `disabletx`
    message that could be sent during connection negotiation.  A peer
    that understands the message and which implements all of the BIP's
    recommendations won't send the node requesting
    `disabletx` any transaction announcements and won't request any
    transactions from the node.  It also won't send some other gossip
    messages such as `addr` messages used for IP address announcements.
    The `disabletx` negotiation persists for the lifetime of the
    connection, allowing peers to use different limits for disabled
    relay connections, such as accepting additional connections beyond
    the current 125 connection maximum.

- **Bech32m** Pieter Wuille [posted][wuille bech32m post] to the
  Bitcoin-Dev mailing list a [draft BIP][bech32m bip] for a modified
  version of the [bech32][topic bech32] address encoding that increases the
  chance that the accidental addition or removal of characters in one of
  these *bech32m* addresses will be detected.  If no problems are found
  with the proposal, it is expected that bech32m addresses will be used
  for [taproot][topic taproot] addresses and possibly future new script
  upgrades.  Wallets and services implementing support for paying
  bech32m addresses will automatically support paying all those future
  improvements (see [Newsletter #45][news45 bech32 upgrade] for
  details).

- **LN dual funding anti UTXO probing:** a long-term goal for LN has
  been dual funding, the ability to open a new channel with funds from
  both the node initiating the channel and the peer receiving their
  request.  This will allow payments to travel in either direction in
  the channel from the moment it's fully opened.  Before the initiator
  can sign the dual funding transaction, they need the identities
  (outpoints) of all of the UTXOs the other party wants to add to the
  transaction.  This creates a risk that an abuser will attempt to
  initiate dual-funded channels with many different users, learn their
  UTXOs, and then refuse to sign the funding transaction---harming those
  users' privacy at no cost to the abuser.

    This week, Lloyd Fournier [posted][fournier podle] to the Lightning-Dev
    mailing list an evaluation of two previous proposals to deal
    with this problem, [one][zmn podle] using Proofs of Discrete Log
    Equivalency (PoDLEs, see [Newsletter #83][news83 podle]) and the
    [other][darosior sighash] using dual funding transactions
    half-signed with `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`.  Fournier
    extended the previous half-signed proposal and then provided his own
    proposal that was equivalently effective but simpler.  The new
    proposal has the initiator create and sign (but not broadcast) a
    transaction that spends their UTXO back to themselves.  They give
    this to the other party as a proof of good faith---if the initiator
    later fails to sign the actual funding transaction, the respondent
    can broadcast the good-faith transaction, forcing the initiator to
    pay an onchain fee.  Fournier concludes his post with a summary of
    the tradeoffs between the different approaches.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:jonatack

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="http://FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.21.0rc5][Bitcoin Core 0.21.0] is a Release Candidate (RC)
  for the next major version of this full node implementation and its
  associated wallet and other software.  Jarol Rodriguez has written an
  [RC testing guide][] that describes the major changes in the release
  and suggests how you can help test them.

- [LND 0.12.0-beta.rc5][LND 0.12.0-beta] is the latest release candidate
  for the next major version of this LN node.  It makes [anchor
  outputs][topic anchor outputs] the default for commitment transactions
  and adds support for them in its [watchtower][topic watchtowers]
  implementation, reducing costs and increasing safety.  The release
  also adds generic support for creating and signing [PSBTs][topic psbt]
  and includes several bug fixes.

{% comment %}<!--
- Bitcoin Core 0.20.2rc1 and 0.19.2rc1 are expected to be
  [available][bitcoincore.org/bin] sometime after the publication of
  this newsletter.  They contain several bug fixes, such as an
  improvement described in [Newsletter #110][news110 bcc19620] that will
  prevent them from redownloading future taproot transactions that they
  don't understand.
-->{% endcomment %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #18077][] net: Add NAT-PMP port forwarding support FIXME:Xeyko

- [Bitcoin Core #19055][] muhash FIXME:adamjonas

- [C-Lightning #4320][] invoice: add ctlv option.  FIXME:dongcarl

- [C-Lightning #4303][] updates `hsmtool` to take its passphrase on
  standard input (stdin) and begins ignoring any passphrase provided on
  the command line.

{% include references.md %}
{% include linkers/issues.md issues="18077,19055,4320,4303,6993" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta.rc5
[news63 bcc15759]: /en/newsletters/2019/09/11/#bitcoin-core-15759
[daftuar disabletx]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018340.html
[wuille bech32m post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018338.html
[bech32m bip]: https://github.com/sipa/bips/blob/bip-bech32m/bip-bech32m.mediawiki
[news83 podle]: /en/newsletters/2020/02/05/#podle
[zmn podle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002476.html
[darosior sighash]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002475.html
[fournier podle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-January/002929.html
[news45 bech32 upgrade]: /en/bech32-sending-support/#automatic-bech32-support-for-future-soft-forks
[rc testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/0.21-Release-Candidate-Testing-Guide
