---
title: 'Bitcoin Optech Newsletter #139'
permalink: /en/newsletters/2021/03/10/
name: 2021-03-10-newsletter
slug: 2021-03-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes continued discussion about proposed
methods for activating taproot and links to an effort to document
existing software building on top of taproot.  Also included are our
regular sections with the summary of a Bitcoin Core PR Review Club
meeting, announcements of releases and release candidates, and
descriptions of notable changes to popular Bitcoin infrastructure
projects.

## News

- **Taproot activation discussion:** the previous weeks' discussions
  about activation saw different groups of people opposing either
  [BIP8][] `LockinOnTimeout=true` (`LOT=true`) or `LOT=false`, so most
  discussion on the mailing list this week focused on alternative
  activation mechanisms.  Some proposals included:

    - *User Activated Soft Fork (UASF):* a plan being [discussed][uasf
      discussion] to implement BIP8 `LOT=true` in a software fork of
      Bitcoin Core that mandates miners signal for activation of taproot
      by July 2022 (as widely proposed), but which also allows miners to
      activate it earlier.

    - *Flag day:* several proposals ([1][flag day corallo], [2][flag day
      belcher]) to program into nodes a specific block height or time
      roughly 18 months from now (as proposed) where taproot activates.
      Miner signaling is not required to cause activation and cannot
      cause earlier activation.  Anthony Towns wrote a [draft
      implementation][bitcoin core #21378].

    - *Decreasing threshold:* several proposals ([1][decthresh guidi],
      [2][decthresh luaces]) to gradually decrease over time the number
      of blocks that must signal readiness for miners to enforce
      taproot before the new consensus rules lock in.  See also Anthony
      Town's proposal from last year described in [Newsletter
      #107][news107 decthresh].

    - *A configurable `LOT`:* in addition to previously-discussed
      proposals to make BIP8's `LOT` value a configuration option (see
      [Newsletter #137][news137 bip8conf]), rough code was
      [posted][rubin invalidateblock] showing how `LOT=true` could be
      enforced via an external script calling RPC commands.  Additional
      code was [created][towns anti-lot] showing how `LOT=true` could
      also be opposed by node operators who were worried about it
      creating block chain instability.

    - *A short-duration attempt at miner activation:* an [updated
      proposal][harding speedy] to give miners approximately three
      months to lock in taproot, starting from soon after the release of
      a full node implementing the activation logic.  If the attempt
      failed, the community would be encouraged to move on to a
      different activation method.  If the attempt succeeded, there
      would still be a several month delay before taproot activated to
      allow most of the economy to upgrade their nodes.  A [draft
      implementation][bitcoin core #21377] for this proposal based on
      Bitcoin Core's existing [BIP9][] implementation was also written
      by Anthony Towns.  Andrew Chow created an [alternative draft
      implementation][bitcoin core #21392] based on the previously
      proposed BIP8 implementation.

    It seemed unlikely any of the proposals would ever become almost
    everyone's first choice, but it appeared that a large number of
    people were [willing to accept][folkson gist] the short-duration
    attempt under the name *Speedy Trial*.  There were still a few
    concerns with it, including:

    - *Could be co-opted for mandatory activation:* even though the
      proposal explicitly encourages making other activation attempts if
      miners don't quickly signal sufficient support for taproot, a
      concern was [expressed][corallo not speedy enough] that it could
      be co-opted by a group of users seeking fast mandatory activation,
      although it was [noted][##taproot-activation log 3/5] that no
      group has previously expressed the desire to attempt mandatory
      activation on such a dangerously short timeline.

    - *Using time-based or height-based parameters:* the proposal
      describes the tradeoffs between setting its `start`, `timeout`,
      and `minimum_activation` parameters using either times (based on
      the median of the previous 11 blocks) or block heights.  Using
      times would result in the smallest and easiest to review patch to
      Bitcoin Core.  Using heights would provide a bit more
      predictability, especially for miners, and would be compatible
      with other attempts using BIP8.

    - *Myopic:* there was [concern][russell concern] that the proposal
      is too focused on the short term: "Speedy Trial fully prepares for
      the (likely) case where miners activate taproot, but it does
      nothing to codify lessons learned from Segwit's failure to
      activate in a timely manner.  We have an opportunity with the
      activation of taproot to create a template for future activations
      that will clearly define the roles and responsibilities for
      developers, miners, merchants, investors, and end users in all the
      ways an activation can progress, not just the best-case outcomes;
      in particular enabling and enshrining the final arbiter role held
      by Bitcoin's economic users.  Defining this will only get more
      difficult in the future, both because we'll only do so when we're
      already in crisis, and because Bitcoin's growth means future
      agreement will need to be done at greater scale and so with
      greater difficulty."  <!-- statement written by me trying to
      summarize Rusty Russell's concerns, then revised by him -->

    - *Speed:* the proposal, based on initial discussion from the
      ##taproot-activation IRC channel, proposes giving miners about
      three months to lock in taproot and waiting a fixed six months
      from the start of signal measuring before activation (if lock in
      is achieved).  Some people have sought either slightly shorter or
      slightly longer timelines.

    We'll continue tracking the discussion around the various proposals
    and will summarize any significant progress in future newsletters.

- **Documenting the intention to use and build upon taproot:** In
  discussion about activation methods, Chris Belcher [noted][flag day
  belcher] that a large list of software was compiled whose developers
  stated their intention to implement segwit during the debate around
  activating that soft fork.  He suggested that a similar list could be
  created to document for posterity the amount of support taproot has.
  That way it could be clear that taproot was desired by a large segment
  of the economy no matter how it ends up being activated.

    Jeremy Rubin [posted][rubin building] to the Bitcoin-Dev mailing
    list a link to a somewhat related [wiki page][taproot uses] where
    developers can post links to projects they're building on top of
    taproot's new proposed features.  This can provide assurance that
    taproot provides solutions people actually want and is designed in
    such a way that its features will get used.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:jonatack or jnewbery

{% include functions/details-list.md
  q0="FIXME"

  a0="FIXME"

  a0link="http://example.com/FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair 0.5.1][] is the latest release of this LN node, containing
  improvements to startup speed, reduced bandwidth consumption when
  syncing the network graph, and a series of small improvements in
  preparation for supporting [anchor oututs][topic anchor outputs].

- [HWI 2.0.0RC2][hwi 2.0.0] is a release candidate for the next major
  version of HWI.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #20685][] Add I2P support using I2P SAM FIXME:adamjonas

- [C-Lightning #4407][] updates the `listpeers` RPC with new fields
  that provide information about each channel's current unilateral close
  transaction, including its fee (both in total fee terms and as a
  feerate).

- [Rust-Lightning #646][] adds the ability to find multiple paths for a
  payment so that it will be possible to add [multipath payment][topic
  multipath payments] support.

- [BOLTs #839][] Add 2016 blocks channel funding timeout (#839) FIXME:dongcarl

- [BTCPay Server #2181][] uppercases bech32 addresses when presenting [BIP21][bip21]
  URIs as QR codes. This results in [less dense QR codes][bech32 uppercase qr]
  as uppercase substrings can be encoded more
  efficiently. The change was preceded by an extensive [compatibility
  survey][btcpay uri survey] of wallets with the BIP21 URI scheme.

{% include references.md %}
{% include linkers/issues.md issues="20685,4407,646,839,2181,21378,21377,21392" %}
[uasf discussion]: http://gnusha.org/uasf/2021-03-02.log
[flag day corallo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018495.html
[flag day belcher]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018538.html
[decthresh guidi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018476.html
[decthresh luaces]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018587.html
[rubin invalidateblock]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018514.html
[towns anti-lot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018512.html
[harding speedy]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018583.html
[folkson gist]: https://gist.github.com/michaelfolkson/92899f27f1ab30aa2ebee82314f8fe7f
[corallo not speedy enough]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018596.html
[##taproot-activation log 3/5]: http://gnusha.org/taproot-activation/2021-03-06.log
[rubin building]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018604.html
[taproot uses]: https://en.bitcoin.it/wiki/Taproot_Uses
[news107 decthresh]: /en/newsletters/2020/07/22/#mailing-list-thread
[news137 bip8conf]: /en/newsletters/2021/02/24/#taproot-activation-discussion
[eclair 0.5.1]: https://github.com/ACINQ/eclair/releases/tag/v0.5.1
[hwi 2.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.0-rc.2
[russell concern]: https://twitter.com/rusty_twit/status/1368325392591822848
[btcpay uri survey]: https://github.com/btcpayserver/btcpayserver/issues/2110
[bech32 uppercase qr]: /en/bech32-sending-support/#creating-more-efficient-qr-codes-with-bech32-addresses
[bip21]: https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
