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
  of the discussion on the mailing list this week focused on alternative
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
      Towns's proposal from last year described in [Newsletter
      #107][news107 decthresh].

    - *A configurable `LOT`:* in addition to previously discussed
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
      allow most of the economy to upgrade their nodes.  Draft implementations
      for this proposal [based on Bitcoin Core's existing BIP9 code][bitcoin
      core #21377] and [based on the previously proposed BIP8 implementation]
      [bitcoin core #21392] were written by Anthony Towns and Andrew Chow,
      respectively.

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
      and `minimum_activation` parameters using either timestamps (based on
      the median of the previous 11 blocks) or block heights.  Using
      timestamps would result in the smallest and easiest-to-review patch to
      Bitcoin Core.  Using heights would provide a bit more
      predictability, especially for miners, and would be compatible
      with other attempts using BIP8.

    - *Myopic:* there was [concern][russell concern] that the proposal
      is too focused on the short term.  As [summarized on IRC][irc speedy]:
      "Speedy Trial fully prepares for
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
      from the start of signal measuring before activation (if lock-in
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
    such a way that its features will be used.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Erlay: bandwidth-efficient transaction relay protocol][review club
#18261] is a PR ([#18261][Bitcoin Core #18261]) by Gleb Naumenko that proposes
to implement [BIP330][] in Bitcoin Core.

The review club discussion focused on the tradeoffs, implementation and
potential new attack vectors involved with [Erlay][topic erlay]. In subsequent
meetings, the review club discussed [Minisketch][topic minisketch], a
[library][minisketch] implementing the PinSketch *set reconciliation* algorithm
that is the basis for the efficient relay protocol in Erlay.

{% include functions/details-list.md
  q0="What is Erlay?"
  a0="A new method of transaction relay based on a combination of *flooding* and
     *set reconciliation* (the current transaction relay is flooding-only) to
     improve bandwidth efficiency, scalability and network
     security. The idea was presented in a 2019 paper, *[Bandwidth-Efficient
     Transaction Relay for Bitcoin][erlay paper]*, and is specified in
     [BIP330][]."

  q1="What advantages does Erlay bring?"
  a1="[Lower bandwidth use for transaction relay][erlay 1], which comprises
     roughly half the bandwidth needed to operate a node, and [scalability of
     peer connections][erlay 2], making the network more robust to partitioning
     attacks and [single nodes more resistant to Eclipse attacks][erlay 3]."

  q2="What are some tradeoffs of Erlay?"
  a2="A marginal increase in transaction propagation latency. It is estimated
     that Erlay would increase the time to relay an unconfirmed transaction
     across all nodes from 3.15s to 5.75s, a small fraction of the overall
     transaction processing time of about 10 minutes. Another tradeoff is
     additional code and computational complexity."
  a2link="https://bitcoincore.reviews/18261#l-94"

  q3="Why can set reconciliation, introduced by Erlay, scale better than
     flooding?"
  a3="Transaction propagation via flooding, where each node announces every
     transaction it receives to each of its peers, has poor bandwidth efficiency
     and high redundancy. This becomes increasingly the case with improved
     network connectivity, which should otherwise be desirable for the growth
     and the security of the network. Erlay improves scalability by reducing the
     transaction data sent via inefficient flooding and replacing it with more
     efficient set reconciliation."

  q4="What would be the change in frequency of the existing peer-to-peer message
     types?"
  a4="With Erlay, `inv` messages would be sent less often; `getdata` and `tx`
     message frequency would be unchanged."
  a4link="https://bitcoincore.reviews/18261#l-140"

  q5="How would 2 peers reach agreement on using Erlay's set reconciliation?"
  a5="Via a new `sendrecon` peer-to-peer message exchanged during the
     version-verack handshake."
  a5link="https://bitcoincore.reviews/18261#l-212"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair 0.5.1][] is the latest release of this LN node, containing
  improvements to startup speed, reduced bandwidth consumption when
  syncing the network graph, and a series of small improvements in
  preparation for supporting [anchor outputs][topic anchor outputs].

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

- [Bitcoin Core #20685][] adds support for the I2P privacy network by using the
  [I2P SAM protocol][I2P SAM protocol].  This feature has
  [long been requested][Bitcoin Core #2091] and was only recently made
  possible by the addition of [addr v2][topic addr v2].
  Though documentation for node operators hoping to run I2P is still
  being created, a [Bitcoin StackExchange Q&A][i2p b.se] provides
  hints on getting started.

- [C-Lightning #4407][] updates the `listpeers` RPC with new fields
  that provide information about each channel's current unilateral close
  transaction, including its fee (both in total fee terms and as a
  feerate).

- [Rust-Lightning #646][] adds the ability to find multiple paths for a
  payment so that it will be possible to add [multipath payment][topic
  multipath payments] support.

- [BOLTs #839][] adds funding transaction timeout recommendations to save
  funding fees when there's a failure to confirm funding transactions, providing stronger
  guarantees for the channel funder and fundee. The new recommendations suggest
  that the funder commit to ensuring the funding transaction confirms in 2016
  blocks and that the fundee forget the pending channel if the funding
  transaction does not confirm within those 2016 blocks.

- [BTCPay Server #2181][] uppercases bech32 addresses when presenting [BIP21][bip21]
  URIs as QR codes. This results in [less dense QR codes][bech32 uppercase qr]
  as uppercase substrings can be encoded more
  efficiently. The change was preceded by an extensive [compatibility
  survey][btcpay uri survey] of wallets with the BIP21 URI scheme.

{% include references.md %}
{% include linkers/issues.md issues="20685,4407,646,839,2181,21378,21377,21392,2091,18261" %}
[uasf discussion]: http://gnusha.org/uasf/2021-03-02.log
[flag day corallo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018495.html
[flag day belcher]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018538.html
[decthresh guidi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018476.html
[decthresh luaces]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018587.html
[rubin invalidateblock]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018514.html
[towns anti-lot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018512.html
[harding speedy]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018583.html
[irc speedy]: http://gnusha.org/taproot-activation/2021-03-08.log
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
[I2P wiki]: https://en.wikipedia.org/wiki/I2P
[I2P SAM protocol]: https://geti2p.net/en/docs/api/samv3
[i2p b.se]: https://bitcoin.stackexchange.com/questions/103402/how-can-i-use-bitcoin-core-with-the-anonymous-network-protocol-i2p
[erlay paper]: https://arxiv.org/abs/1905.10518
[erlay 1]: https://bitcoincore.reviews/18261#l-94
[erlay 2]: https://bitcoincore.reviews/18261#l-97
[erlay 3]: https://bitcoincore.reviews/18261#l-99
[minisketch]: https://github.com/sipa/minisketch
