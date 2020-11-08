---
title: 'Bitcoin Optech Newsletter #123'
permalink: /en/newsletters/2020/11/11/
name: 2020-11-11-newsletter
slug: 2020-11-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter shares the announcement of a marketplace for
incoming LN channels and also includes our regular sections with updates
about various projects.

## Action items

*None this week.*

## News

- **Incoming channel marketplace:** Olaoluwa Osuntokun [announced][pool
  announce] a new *Lightning Pool* marketplace for buying incoming LN channels.  Users and
  merchants need channels with incoming capacity in order to allow
  quickly receiving funds over LN.  Some existing node operators already
  provide incoming channels, either for free or as a paid service, but
  Lightning Pool hopes to make this service more
  standardized and competitive.  The initial focus is a contract for
  highly ranked [nodes][node rankings] to provide an incoming
  channel for a period of 2,016 blocks (about two weeks).  Additional
  contract lengths and other features are planned for the future.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/18267#l-94FIXME"
%}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [BOLTs #807][] Fail channel in case of high-S remote signature reception FIXME:dongcarl

- [Eclair #1545][] Add blockchain watchdog FIXME:Xeyko

- [LND #4735][] adds a `max_local_csv` configuration parameter that
  will reject channels from peers who require the local node to wait for more
  than the indicated number of blocks before spending its
  funds if it unilaterally closes the channel.  The default maximum is
  10,000 blocks, and there's also a minimum of 144 blocks to ensure users
  don't set the value lower than is reasonable.

- [LND #4701][] adds the `assumechanvalid` (assume channels are
  valid) configuration option to default builds.  For nodes using the Neutrino
  client to retrieve [compact block filters][topic compact block
  filters], this allows the node to assume the channels it learns about via LN
  gossip are available rather than by expending additional bandwidth
  checking for related transactions in recent blocks.  If the assumption
  is wrong and the channels are actually not available (e.g. they've
  been closed recently), any payments LND attempts to route through
  those channels will fail.  This may cause delays or unnecessary
  payment failures but not the loss of funds.

{% include references.md %}
{% include linkers/issues.md issues="807,1545,4735,4701" %}
[node rankings]: https://nodes.lightning.computer/availability/v1/btc.json
[pool announce]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-November/002874.html
