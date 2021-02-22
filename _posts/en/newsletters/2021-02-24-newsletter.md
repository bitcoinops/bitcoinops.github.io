---
title: 'Bitcoin Optech Newsletter #137'
permalink: /en/newsletters/2021/02/24/
name: 2021-02-24-newsletter
slug: 2021-02-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes the results of discussion about
choosing activation parameters for a taproot soft fork and includes our
regular sections with selected questions and answers from the Bitcoin
StackExchange, releases and release candidates, and notable changes to
popular Bitcoin infrastructure software.

## News

- **Taproot activation discussion:** Michael Folkson [summarized][folkson
  lot] a second meeting about activation parameters for [taproot][topic
  taproot], concluding that "there wasn’t overwhelming consensus for
  either LOT=true or LOT=false", the LockinOnTimeout (LOT) parameter
  from [BIP8][] that determines whether or not nodes will require
  mandatory signaling for activation of the fork.
  However, there was nearly universal agreement on other
  activation parameters, most notably reducing the amount of hash rate
  that needs to signal for the fork to activate from 95% to 90%.

    Discussion continued about the LOT parameter on the mailing list,
    mainly about the effect of encouraging users to choose the option
    themselves, either via a command line option or by choosing what
    software release to use.  No clear agreement was
    reached as of this writing and there does not seem to be a widely
    supported path forward to activating taproot---even though taproot
    itself appears to be almost entirely desired.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.12.1-beta][LND 0.12.1-beta] is the latest maintenance
  release of LND.  It fixes an edge case that could lead to accidental
  channel closure and a bug that could cause some payments to fail
  unnecessarily, plus some other minor improvements and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #19136][] extends the `getaddressinfo` RPC with a new
  `parent_desc` field that contains an [output script descriptor][topic
  descriptors] for a wallet containing the address's public
  key.  The wallet's [BIP32][] path will have all hardened prefixes
  stripped so that only public derivation steps remain, allowing the
  descriptor to be imported into other wallet software which can monitor
  for bitcoins received to the address and its sibling addresses.

- [Bitcoin Core #15946][] makes it possible to simultaneously use both
  configuration options `prune` and `blockfilterindex` to maintain
  [compact block filters][topic compact block filters] on a pruned node
  (also serving them if the `peerblockfilters` configuration option is
  used). An LND developer [indicated][osuntokun request] that this would
  be beneficial for their software, and it could also allow a future
  update that allows the wallet logic to use the block filters to
  determine which historic blocks the pruned node needs to re-download
  in order to import a wallet.

- [Eclair #1693][] and [Rust-Lightning #797][] change how node address
  announcements are handled.  The current [BOLT7][] specification
  requires the sorting of addresses within an announcement, however some
  implementations were not using or enforcing this rule.  Eclair updated
  their implementation to begin sorting and Rust-Lightning updated their
  implementation to stop requiring the sorting.  A [PR][bolts #842] is
  open to update the specification but it is still under discussion
  exactly what change should be made.

- [HWI #454][] updates the `displayaddress` command to add support for
  registering multisig addresses on a BitBox02 device.

- [BIPs #1052][] assigns [BIP338][] to the proposal to add a `disabletx`
  message to the Bitcoin P2P protocol.  A node that sends this message
  during connection establishment signals to its peer that it will never
  request or announce transactions on that connection.  As described in
  [Newsletter #131][news131 disabletx], this allows peers to use
  different limits for disabled relay connections, such as accepting
  additional connections beyond the current 125 connection maximum.  See
  also the [discussion summary][2021-01-12 p2p summary] from the January
  12th P2P developers meeting.

{% include references.md %}
{% include linkers/issues.md issues="1052,454,19136,15946,1693,797,842,798" %}
[LND 0.12.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.1-beta
[folkson lot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018425.html
[2021-01-12 p2p summary]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/P2P-IRC-meetings#topic-disabletx-p2p-message-sdaftuar
[osuntokun request]: https://github.com/bitcoin/bitcoin/pull/15946#issuecomment-571854091
[news131 disabletx]: /en/newsletters/2021/01/13/#proposed-disabletx-message
