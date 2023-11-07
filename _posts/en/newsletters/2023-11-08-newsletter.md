---
title: 'Bitcoin Optech Newsletter #276'
permalink: /en/newsletters/2023/11/08/
name: 2023-11-08-newsletter
slug: 2023-11-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces an upcoming change to the Bitcoin-Dev
mailing list and briefly summarizes a proposal to allow aggregating
multiple HTLCs together.  Also included are our regular sections with
the summary of a Bitcoin Core PR Review Club, announcements of new
releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Mailing list hosting:** administrators for the Bitcoin-Dev mailing
  list [announced][bishop lists] that the organization hosting the list
  plans to cease hosting any mailing lists after the end
  of the year.  The archives of previous emails are expected to
  continue being hosted at their current URLs for the foreseeable
  future.  We assume that the end of email relay also affects the
  Lightning-Dev mailing list, which is hosted by the same organization.

    The administrators sought feedback from the community about options,
    including migrating the mailing list to Google Groups.  If such a
    migration happens, Optech will begin using that as one of our [news
    sources][sources].

    We're also aware that,
    in the months prior to the announcement, some well-established
    developers had begun experimenting with discussions on the
    [DelvingBitcoin][] web forum.  Optech will begin monitoring that
    forum for interesting or important discussions effective
    immediately.

- **HTLC aggregation with covenants:** Johan Torås Halseth
  [posted][halseth agg] to the Lightning-Dev mailing list a suggestion
  for using a [covenant][topic covenants] to aggregate multiple
  [HTLCs][topic htlc] into a single output that could be spent all at
  once if a party knew all the preimages.  If a party only knew some of
  the preimages, they could claim just those and then the remaining
  balance could be refunded to the other party.  Halseth notes that this
  would be more efficient onchain and could make it more difficult to
  perform certain types of [channel jamming attacks][topic channel
  jamming attacks].

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:LarryRuane

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/28107#l-FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.0rc2][] is a release candidate for the next major
  version of the predominant full node implementation. There's a brief overview to [suggested
  testing topics][26.0 testing] and a scheduled meeting of the [Bitcoin
  Core PR Review Club][] dedicated to testing on 15 November 2023.

- [Core Lightning 23.11rc1][] is a release candidate for the next
  major version of this LN node implementation.

- [LND 0.17.1-beta.rc1][] is a releases candidate for a maintenance
  release for this LN node implementation.

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6824][] updates the implementation of the
  [interactive funding protocol][topic dual funding] to "store state
  when sending `commitment_signed`, and [add] a `next_funding_txid`
  field to `channel_reestablish` to ask our peer to retransmit
  signatures that we haven't received."  It is based on an
  [update][36c04c8ac] to the proposed [dual funding PR][bolts #851].

- [Core Lightning #6783][] deprecates the `large-channels` configuration
  option, making [large channels][topic large channels] and large
  payment amounts always enabled.

- [Core Lightning #6780][] improves support for fee bumping onchain transactions
  associated with [anchor outputs][topic anchor outputs].

- [Core Lightning #6773][] allows the `decode` RPC to verify that the
  contents of a backup file are valid and contain the latest information
  necessary to perform a full recovery.

- [Core Lightning #6734][] updates the `listfunds` RPC to provide
  information users need if they want to [CPFP][topic cpfp] fee bump a
  channel mutual close transaction.

- [Eclair #2761][] allows forwarding a limited number [HTLCs][topic
  htlc] to a party even if they're below their channel reserve
  requirement.  This can help resolve a _stuck funds problem_ that might
  occur after [splicing][topic splicing] or [dual funding][topic dual
  funding].  See [Newsletter #253][news253 stuck] for another mitigation
  by Eclair for a stuck funds problem.

<div markdown="1" class="callout">
## Want more?

For more discussion about the topics mentioned in this newsletter, join
us for the weekly Bitcoin Optech Recap on [Twitter
Spaces][@bitcoinoptech] at 15:00 UTC on Thursday (the day after the
newsletter is published).  The discussion is also recorded and will be
available from our [podcasts][podcast] page.

</div>

{% include references.md %}
{% include linkers/issues.md v=2 issues="6824,6783,6780,6773,6734,2761,851" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta.rc1
[sources]: /internal/sources/
[bishop lists]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022134.html
[delvingbitcoin]: https://delvingbitcoin.org/
[halseth agg]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-October/004181.html
[36c04c8ac]: https://github.com/lightning/bolts/pull/851/commits/36c04c8aca48e04d1fba64d968054eba221e63a1
[news253 stuck]: /en/newsletters/2023/05/31/#eclair-2666
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Testing-Guide-Topics
