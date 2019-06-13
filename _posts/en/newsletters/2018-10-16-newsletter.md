---
title: "Bitcoin Optech Newsletter #17"
permalink: /en/newsletters/2018/10/16/
name: 2018-10-16-newsletter
slug: 2018-10-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter briefly describes a proposal for splicing
Lightning Network payment channels, links to videos and transcripts of
talks from the Edge Dev++ training sessions, and summarizes some
transcripts made during last week's CoreDev.tech event.

## Action items

None this week.

## News

- **Proposal for Lightning Network payment channel splicing:** splicing
  is an idea for allowing users to either add or remove funds from an
  existing payment channel without the delay of closing and reopening a
  completely new channel.  Rusty Russell posted a [technical
  proposal][complex splice] for allowing a single splice at a time,
  although he notes that the proposal is complex.   René Pickhardt
  described an [alternative][simpler splice] that would likely be easier
  to implement and reason about but which could require more onchain
  transactions.  It was suggested that the simpler but more expensive
  solution could be version 1, and the more complex but less expensive
  solution could be version 2.

- **Edge Dev++ talks published:** a two-day series of presentations from
  leading Bitcoin contributors aimed at developers has been published
  as [videos][dev vids] and [transcripts][dev transcripts].  The talks
  cover the full range of topics, from introductory to advanced.  Three
  talks may be especially interesting to Optech members:

    1. *Exchange security* by Warren Togami.  Describes the causes
       behind several notable major thefts from Bitcoin and altcoin
       exchanges and lists a number of techniques businesses can use to
       reduce their risk of loss.  ([Video][warren vid],
       [transcript][warren transcript])

    2. *Wallet Security, Key Management & Hardware Security Modules
       (HSMs)]* by Bryan Bishop.  Suggests methods for decreasing the
       risk that private keys will be stolen or misused.
       ([Video][kanzure wallet vid], [transcript][kanzure wallet
       transcript])

    3. *Handling reorgs and forks* by Bryan Bishop.  Describes how to
       secure your transactions against changes in the Bitcoin block
       chain or consensus rules, including suggestions for how to test
       your systems.  ([Video][kanzure reorg vid], [transcript][kanzure
       reorg transcript])

## CoreDev.tech

CoreDev.tech is an invite-only event for well-known contributors to
Bitcoin infrastructure projects such as Bitcoin Core and Lightning
Network.  Discussions are not recorded, but Bryan Bishop helpfully
writes rough and non-authoritative transcripts of some of the
discussions during the events.  The following short summaries are based
on some of the transcripts for the event in Tokyo last week:

- **[Bitcoin Optech][optech transcript]:** Bitcoin Optech is introduced
  and briefly discussed, followed by discussion of common problems
  Bitcoin-using businesses encounter when using Bitcoin Core and other
  open source infrastructure projects.

- **[Using UTXO accumulators to reduce data storage
  requirements][utreexo]:** Tadge Dryja describes work he's been doing
  on UTXO accumulators that are similar in function to those described
  in last week's newsletter but which have a different construction
  based on hashes.  He further describes how they could be combined with
  something like Cory Field's [UTXO Hash Set (UHO)][UHO] idea for full
  nodes to store hashes of UTXOs instead of full UTXOs in order to
  significantly reduce the amount of storage pruned full nodes would use
  without necessarily requiring any changes to the consensus rules.

- **[Script descriptors and DESCRIPT][]:** the backwards-compatible way
  wallets such as Bitcoin Core default to watching for transaction
  outputs paying them "is ambiguous, inflexible, and scales badly".
  [Output script descriptors][] are a simple language for describing
  scripts to the wallet that makes it easier for the wallet to handle
  many normal cases (including imports of HD extended private and public
  keys).

    Somewhat related is DESCRIPT, a language that uses a subset of the
    full Bitcoin Script language to make it easy to construct some
    simple policies.  "We have a DESCRIPT compiler that takes something
    we're calling a policy language (AND, OR, threshold, public key,
    hashlock, timelock) together with probabilities for each OR to tell
    whether it's 50/50 or whether one side of the OR is more likely than
    the right, and it will find [...] the optimal script in this subset
    of script that we have defined."  For example, it could allow you
    "to do something like a multisig that after some time degrades into
    a weaker multisig---like a 2-of-3 but after a year I can spend it
    with just one of those keys."

## Notable code changes

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], and [C-lightning][cl commits].*

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="c9327306b580bb161d1732c0a0260b46c0df015c"
  end="be992701b018f256db6d64786624be4cb60d8975"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="79ed4e8b600e4834f058cbf3cb8b93f5aa5ab3d4"
  end="e5b84cfadab56037ae3957e704b3e570c9368297"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="d6fcfe00c722f7e6f4b691cd47743ed593aeea0e"
  end="a44491fff0ccd7bde20661eecf88bf136db5f6e6"
%}
{% comment %}<!-- last secp256k1 commit checked: 1e6f1f5ad5e7f1e3ef79313ec02023902bf8175c -->{% endcomment %}

- [LND #1970][]: The AbandonChannel RPC method (only available in the
  developer debug mode) now provides additional information when users
  tell their node to abandon a payment channel (a method that can cause
  monetary loss if used carelessly).  The additional information is
  enough to allow either restarting an open payment channel later or to
  prove that the program had enough information to make additional
  commitments to a now-closed payment channel.

- [C-Lightning #2000][]: This provides a large number of fixes and
  safety-related improvements how hash-timelocked-contracts (HTLCs) are
  stored in the database.

{% include references.md %}
{% include linkers/issues.md issues="1970,2000" %}

[complex splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[simpler splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001437.html
[script descriptors and descript]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-08-script-descriptors/
[utreexo]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-08-utxo-accumulators-and-utreexo/
[optech transcript]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2018-10-09-bitcoin-optech/
[dev vids]: https://www.youtube.com/channel/UCywSzGiWWcUG1gTp45YdPUQ/videos
[dev transcripts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/
[warren transcript]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/protecting-yourself-and-your-business/
[warren vid]: https://youtu.be/iPt2ekHoEy8
[kanzure wallet transcript]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/wallet-security/
[kanzure wallet vid]: https://youtu.be/WcOIXsOLJ3w?t=3552
[kanzure reorg transcript]: http://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/reorgs/
[kanzure reorg vid]: https://youtu.be/EUUQbveGF5E?t=4
[UHO]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-May/015967.html
