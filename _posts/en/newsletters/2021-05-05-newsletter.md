---
title: 'Bitcoin Optech Newsletter #147'
permalink: /en/newsletters/2021/05/05/
name: 2021-05-05-newsletter
slug: 2021-05-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter encourages miners to start signaling for taproot
and describes continued discussion about closing lost LN channels using
only a wallet seed.  Also included are our regular sections with
announcements of releases and release candidates, plus notable changes
to popular Bitcoin infrastructure software.

## Action items

- **Miners encouraged to start signaling for taproot:** miners who
  expect to be willing to enforce the new consensus rules for
  [taproot][topic taproot] are encouraged to begin signaling and to
  ensure they'll be able to run Bitcoin Core 0.21.1 (described below) or
  other compatible taproot-enforcing software by the [minimum activation
  block specified in BIP341](https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#deployment).

    Anyone wanting to trustlessly monitor signaling progress can upgrade
    to Bitcoin Core 0.21.1 and use the `getblockchaininfo` RPC.  For
    example, the following command line prints the number of blocks in
    the current retarget period, the number of those blocks which have
    signaled, and whether it's possible for taproot to activate in this
    period (assuming there's no reorg):

    ```text
    $ bitcoin-cli getblockchaininfo \
      | jq '.softforks.taproot.bip9.statistics | .elapsed,.count,.possible'
    353
    57
    false
    ```

    If you prefer a graphical representation with supplementary
    information about miner progress and don't need to use your own
    node, we recommend [taproot.watch][] by Hampus Sjöberg.

## News

- **Closing lost channels with only a BIP32 seed:** as described in [Newsletter
  #128][news128 ln ecdh], Lloyd Fournier proposed a method for creating
  new channels that would allow a user who lost all information except
  for their BIP32 wallet seed to re-discover their peers using only
  public information about the LN network.  Once the user found their
  peers, they could request the peers close their mutual channels using
  the [BOLT2][] data loss protection protocol (see [Newsletter
  #31][news31 data_loss]).  The proposed method isn't perfect---users
  should still create backups[^missing-peer] and replicate them across
  independent systems---but Fournier's proposal provides additional
  redundancy that would be especially useful for everyday users.

    Two weeks ago, Rusty Russell restarted the [thread][russell
    ecdh channels] after trying to [specify][russell ecdh spec] and
    implement the idea.  After some additional mailing list discussion with Fournier
    and a group [conversation][lndev deterministic] in the weekly LN
    protocol development meeting, Russell indicated he was leaning
    against the idea, [saying][russell backups] "I see encrypted backups
    as a more-likely-to-be-implemented solution though.  Because they're
    useful to send to places other than peers, and they can also contain
    HTLC information if you want."  Being able to contain
    [HTLC][topic htlc] information would allow settling payments that
    were pending at that time, which is a capability no recovery
    mechanism based solely on a BIP32 seed could provide.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.21.1][Bitcoin Core 0.21.1] is a new version of Bitcoin
  Core that contains activation logic for the proposed [taproot][topic
  taproot] soft fork.  Taproot uses [schnorr signatures][topic schnorr
  signatures] and allows the use of [tapscript][topic tapscript].  These
  are, respectively, specified by BIPs [341][BIP341], [340][BIP340], and
  [342][BIP342].  Also included is the ability to pay [bech32m][topic
  bech32] addresses specified by [BIP350][], although bitcoins spent to
  such addresses on mainnet will not be secure until activation of a
  soft fork using such addresses, such as taproot.  The release
  additionally includes bug fixes and minor improvements.

    Note: due to a [problem][wincodesign] with the certificate authority
    that provides the code signing certificates for the Windows versions
    of Bitcoin Core, users on Windows will need to click through an
    extra prompt to install.  It is expected that there will be a
    0.21.1.1 release with an updated certificate when the problem is
    fixed.  If you are planning to upgrade anyway, there's no reason to
    delay using 0.21.1 because of this problem.

- [BTCPay 1.1.0][] major release FIXME:bitschmidty https://github.com/btcpayserver/btcpayserver/pull/2480

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #19160][] multiprocess: Add basic spawn and IPC support FIXME:jnewbery

- [Bitcoin Core #21009][] removes the RewindBlockIndex logic triggered when
  updating a pre-segwit node (v0.13.0 or older) to a segwit-enforcing
  version. Pre-segwit nodes only processed stripped blocks that lacked the (segregated) witness
  data. The RewindBlockIndex logic discarded its copies of such blocks,
  re-downloaded them in their complete form, and validated them using segwit's rules. As pre-segwit
  nodes have been end-of-life since 2018, the scenario has become uncommon.
  Future releases will instead prompt the user to reindex for an equivalent
  outcome.

- [LND #5159][] AMP support for SendPaymentV2 FIXME:dongcarl

- [Rust-Lightning #893][] only allows accepting a payment if it includes
  a payment secret.  Payment secrets are created by the receiver and
  included in invoices.  The spender includes the payment secret in
  their payment in order to prevent attempts by third parties to reduce
  the privacy of [multipath payments][topic multipath payments].  Alongside
  this change are several API changes designed to reduce the chance that
  a payment will be accepted incorrectly.

- [BIPs #1104][] updates the [BIP341][] specification of [taproot][topic
  taproot] with activation parameters based on the Speedy Trial proposal
  (see [Newsletter #139][news139 speedy trial]).

## Footnotes

[^missing-peer]:
    The data loss protection protocol, and other proposed methods such
    as [covert requests for mutual channel closes][news128 covert] requires your channel peer to
    still be online and responsive.  If they've become permanently
    unavailable and you don't have a backup, your funds are permanently
    lost.  If, instead, you recover from a backup, you might still lose
    all of your funds if you broadcast an old state, but you have a
    chance to recover your funds if you backed up the latest state or if
    your peer doesn't contest an old state.

{% include references.md %}
{% include linkers/issues.md issues="19160,21009,5159,893,1104" %}
[bitcoin core 0.21.1]: https://bitcoincore.org/bin/bitcoin-core-0.21.1/
[btcpay 1.1.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.1.0
[wincodesign]: https://github.com/bitcoin-core/gui/issues/252#issuecomment-802591628
[russell ecdh channels]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002996.html
[russell ecdh spec]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002998.html
[russell backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/003026.html
[news128 covert]: /en/newsletters/2020/12/16/#covert-request-for-mutual-close
[taproot.watch]: https://taproot.watch/
[news128 ln ecdh]: /en/newsletters/2020/12/16/#fast-recovery-without-backups
[news31 data_loss]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[news139 speedy trial]: /en/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[lndev deterministic]: https://lightningd.github.io/meetings/ln_spec_meeting/2021/ln_spec_meeting.2021-04-26-20.17.log.html#l-115
