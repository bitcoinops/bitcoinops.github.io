---
title: 'Bitcoin Optech Newsletter #172'
permalink: /en/newsletters/2021/10/27/
name: 2021-10-27-newsletter
slug: 2021-10-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections with summaries of
popular questions and answers from the Bitcoin Stack Exchange,
information about preparing for taproot activation, a list of new
releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure projects.

## News

*No significant news this week.*

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Where to find the exact number of hashes required to mine most recent block?]({{bse}}110330)
  Pieter Wuille notes what while a block's attempted number of hashes is not
  published, a formula of 4,295,032,833 times the block's [difficulty][wiki
  difficulty] provides a simple way of estimating the expected number of hashes
  to solve a block.

- [Using a 2-of-3 taproot keypath with schnorr signatures?]({{bse}}110249)
  Pieter Wuille points out that, although [BIP340][] requires 1 key and 1 signature,
  it is also possible to use [threshold signature][topic threshold signature] schemes like
  [FROST][frost whitepaper], [multisignature][topic multisignature] schemes like
  [MuSig][topic musig], and others.

- [Why coinbase maturity is defined to be 100 and not 50?]({{bse}}110085)
  User liorko asks why the constant 100, instead of 50, was chosen for Bitcoin's [coinbase
  maturity][se coinbase maturity] duration. Answers point out the unexplained and
  potentially arbitrary nature of the choice.

- [Why does Bitcoin use double hashing so often?]({{bse}}110065)
  Pieter Wuille lists where the double-SHA256 and SHA256+RIPEMD160 double hash schemes
  were initially used in Bitcoin, notes where new features used the same
  schemes, and hypothesizes that Satoshi used these double hash schemes, mistakenly, to
  mitigate against certain attacks.

## Preparing for taproot #19: future consensus changes

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/19-future.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Rust-Lightning 0.0.102][] is a release that makes several API
  improvements and fixes a bug that prevented opening channels with LND
  nodes.

- [C-Lightning 0.10.2rc1][] is a release candidate that [includes][decker
  tweet] a fix for the [uneconomical outputs security issue][news170
  unec bug], a smaller database size, and an improvement in the
  effectiveness of the `pay` command (see the *notable changes* section
  below).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23002][] Make descriptor wallets by default FIXME:jnewbery

- [Bitcoin Core #22918][] extends the `getblock` RPC and `/rest/block/`
  endpoint with a new level of verbosity (`3`) that includes information
  about each previously-created output ("prevout") being spent in the
  block.

    When a block creates a new unspent transaction output (UTXO),
    Bitcoin Core stores it in a database.  When a later transaction
    attempts to spend that UTXO, Bitcoin Core retrieves it from the
    database and verifies the spend fulfills all required conditions
    (e.g. includes a valid signature for the correct public key).  If
    every spend in a block is valid, Bitcoin Core moves those prevout
    entries out of the UTXO database and into an *undo* file that can be
    used to restore the UTXO database to its previous state if the block
    is later removed from the chain during a reorg.

    This PR retrieves the prevouts from the undo file and includes them
    as part of the information that's actually included in the block or
    computed from its contents.  For users and applications who need
    prevout data, this is much faster and more convenient than directly
    looking up each previous transaction and its outputs.  Full nodes
    that have pruning enabled will delete older undo files and so will
    be unable to use the new verbosity level three for those blocks.

- [C-Lightning #4771][] updates the `pay` command to prefer routes that
  include channels with a larger total amount of funds (channel
  capacity), all other things being equal.  The total amount of funds in
  a channel is publicly known; what's not publicly known is how much
  funding is available in each direction of the channel.  However, if
  two channels each have an [equal probability][prob path] of being in any state,
  then the larger channel's capacity is more likely to be able to handle
  the payment size than the smaller channel.

- [C-Lightning #4685][] adds an experimental [websocket][] transport
  based on the draft specification in [BOLTs #891][].  This will allow
  C-Lightning (and other LN implementations that support the same
  protocol) to advertise an alternative port to use for communication
  with peers.  The underlying LN communication protocol remains the
  same, it is just performed using binary websocket frames rather than
  pure TCP/IP.

- [Eclair #1969][] extends the `findroute*` set of API calls with
  several additional parameters: `ignoreNodeIDs`, `ignoreChannelIDs`,
  and `maxFeeMsat`.  It also adds a `full` format that returns
  all the information known about the found routes.

- [LND #5709][] (originally [#5549][lnd #5549]) adds a new commitment
  transaction format for use between nodes supporting Lightning Pool
  (see [Newsletter #123][news123 pool]), which are currently only LND nodes.
  The new format will prevent the node offering a channel lease from
  being able to spend their funds onchain until the lease period ends.
  This provides them an incentive to keep the channel open for the lease
  period so that they can use their funds (liquidity) to earn routing
  fees.  A channel's commitment transaction format is only seen between
  its two direct peers while a channel is open, so any format can be used
  without affecting other nodes on the network.

- [LND #5346][] adds the ability for an LND node and its peer to
  exchange custom messages---those with a type identifier above 32,767.
  A number of suggested uses for custom messages are suggested in the
  pull request.  The `lncli` command is updated to simplify sending and
  listening for custom peer messages.

- [LND #5689][] Support remote signing over RPC FIXME:dongcarl

- [BTCPay Server #2517][] adds support for issuing payouts or refunds
  via LN.  The administrator can enter an amount to pay, the receiver
  can then enter their node details and have the payment sent to them.

- [HWI #497][] sends additional information to devices using Trezor
  firmware that allows them to verify a change address belongs to a
  multisig federation.  Otherwise, Trezor shows the change as a separate
  payment, requiring the user to manually verify their change address is
  correct.

{% include references.md %}
{% include linkers/issues.md issues="23002,22918,4771,4685,1969,5709,5549,5346,5689,2517,497,891" %}
[rust-lightning 0.0.102]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.102
[c-lightning 0.10.2rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.2rc1
[news123 pool]: /en/newsletters/2020/11/11/#incoming-channel-marketplace
[websocket]: https://en.wikipedia.org/wiki/WebSocket
[prob path]: /en/newsletters/2021/03/31/#paper-on-probabilistic-path-selection
[news170 unec bug]: /en/newsletters/2021/10/13/#ln-spend-to-fees-cve
[decker tweet]: https://twitter.com/Snyke/status/1452260691939938312
[wiki difficulty]: https://en.bitcoin.it/wiki/Difficulty
[se coinbase maturity]: https://bitcoin.stackexchange.com/a/1992/87121
[frost whitepaper]: https://eprint.iacr.org/2020/852.pdf
