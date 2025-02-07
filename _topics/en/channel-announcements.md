---
title: Channel announcements

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - "Gossip (LN)"

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "BOLT7: P2P node and channel discovery"
      link: bolt7

    - title: "Proposed taproot gossip (AKA, gossip v1.5)"
      link: https://github.com/lightning/bolts/pull/1059

    - title: "V2 gossip protocol"
      link: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003470.html

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Gossip update proposed
    url: /en/newsletters/2019/07/17/#gossip-update-proposal

  - title: Updated gossip proposal
    url: /en/newsletters/2022/02/23/#updated-ln-gossip-proposal

  - title: Continued discussion about updated gossip proposal
    url: /en/newsletters/2022/03/30/#continued-discussion-about-updated-ln-gossip-protocol

  - title: LN developer meeting discussion about gossip updates
    url: /en/newsletters/2022/06/15/#gossip-network-updates

  - title: LN developer discussion about updated channel announcements
    url: /en/newsletters/2023/07/26/#updated-channel-announcements

  - title: New anonymous usage tokens proposed that could be used to improve channel announcement privacy
    url: /en/newsletters/2024/05/17/#anonymous-usage-tokens

  - title: "Proving UTXO set inclusion in zero knowledge for more private channel announcement messages"
    url: /en/newsletters/2024/09/20/#proving-utxo-set-inclusion-in-zero-knowledge

  - title: "LND #2690 puts more gossip traffic in a queue to allow prioritizing urgent information"
    url: /en/newsletters/2019/03/12/#lnd-2690

  - title: "LND #2740 implements a new gossiper subsystem which puts its peers into two buckets"
    url: /en/newsletters/2019/04/09/#lnd-2740

  - title: "LND #2985 waits to relay gossip announcements until there are there are at least ten"
    url: /en/newsletters/2019/06/05/#lnd-2985

  - title: "LND #3359 adds an `ignore-historical-filters` configuration option for ignoring some gossip filters"
    url: /en/newsletters/2019/08/07/#lnd-3359

  - title: "Eclair #899 implements extended gossip queries as proposed in BOLTs #557"
    url: /en/newsletters/2019/09/04/#eclair-899

  - title: "Eclair #954 adds a gossip sync whitelist"
    url: /en/newsletters/2019/09/04/#eclair-954

  - title: "Request for comments on limiting LN gossip updates to once per day"
    url: /en/newsletters/2019/09/11/#request-for-comments-on-limiting-ln-gossip-updates-to-once-per-day

  - title: "C-Lightning #3064 begins limiting gossip updates to once per day"
    url: /en/newsletters/2019/10/02/#c-lightning-3064

  - title: "Blockstream Satellite begins broadcasting LN gossip data"
    url: /en/newsletters/2021/02/17/#blockstream-satellite-broadcasting-ln-data-and-bitcoin-core-source

  - title: "C-Lightning #4639 adds experimental support for gossiping liquidity advertisements"
    url: /en/newsletters/2021/07/28/#c-lightning-4639

  - title: LN gossip rate limiting for use with Erlay-like set reconciliation
    url: /en/newsletters/2022/05/04/#ln-gossip-rate-limiting

  - title: "Core Lightning #5239 improves its gossip handling code"
    url: /en/newsletters/2022/07/13/#core-lightning-5239

  - title: LN fee rate cards proposed to reduce fee-related channel update gossip
    url: /en/newsletters/2022/09/28/#ln-fee-ratecards

  - title: "LDK #2198 increases the amount of time before gossiping that a channel is down"
    url: /en/newsletters/2023/04/26/#ldk-2198

  - title: "LDK #2222 allows accepting gossip without verifying it first"
    url: /en/newsletters/2023/05/03/#ldk-2222

  - title: Disclosure of two past vulnerabilities in LND gossip handling
    url: /en/newsletters/2024/01/03/#disclosure-of-past-lnd-vulnerabilities

  - title: "LND #8044 adds new message types for the new v1.75 gossip protocol compatible with taproot channels"
    url: /en/newsletters/2024/09/27/#lnd-8044

  - title: "LN developers discuss upgrades to the gossip protocol"
    url: /en/newsletters/2024/10/18/#gossip-upgrade

  - title: "Updates to the version 1.75 channel announcements proposal"
    url: /en/newsletters/2024/10/25/#updates-to-the-version-1-75-channel-announcements-proposal

  - title: "Utreexo-based zero-knowledge gossip for LN channel announcements compatible with MuSig2 STCs"
    url: /en/newsletters/2025/02/07/#zero-knowledge-gossip-for-ln-channel-announcements

  - title: "Eclair #2983 only synchronizes channel announcements with the node's top peers on reconnection"
    url: /en/newsletters/2025/02/07/#eclair-2983

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Unannounced channels
    link: topic unannounced channels

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Channel announcements** are advertisements that a channel is
  available to forward payments.  The advertisements are relayed through
  the LN gossip network.
---
Many LN nodes choose to announce their existence and their channels to
encourage other nodes to use them for routing payments.  Other nodes
choose to remain private, using [unannounced channels][topic unannounced
channels].

As of this writing, many developers call the currently deployed
[BOLT7][] announcement protocol "gossip v1".  One key feature of gossip v1
is that channel announcements and updates must be signed by a key
belonging to a P2WSH UTXO corresponding to a 2-of-2 multisig script (the
type of script used for v1 LN funding transactions).  This means that a
channel announcement or update message can only be created after someone
has paid the onchain fees necessary to get a P2WSH output confirmed,
providing built-in denial-of-service (DoS) protection against fake
channel announcements that would waste bandwidth and potentially result
in failed routing attempts across non-existent channels.

This approach has two major downsides:

- *Restricts upgrades:* the requirement in v1 gossip to use P2WSH UTXOs
  with a specific script prevents announced LN channels from using
  alternative scripts and output types.  Anyone experimenting with new
  ideas for LN, such as [simple taproot channels][topic simple taproot
  channels], is forced to use unannounced channels.

- *Linkability:* it's expected that channels will be announced using the
  specific UTXO that is jointly controlled by the two nodes.  Although
  this provides DoS protection through an efficient reuse of something
  the nodes already need to pay for, it reduces privacy by publicly
  linking node and channel activity to a specific UTXO.

A proposed upgrade to LN gossip, sometimes called "v1.5 gossip", would
allow using [P2TR][topic taproot] outputs with keypath-signed channel
announcements and updates, addressing the problem of restricted
upgrades.

A more ambitious proposed upgrade to LN gossip, sometimes called "v2
gossip", proposes to address both linkability and restricted upgrades by
allowing signatures for a broad range of UTXOs to be used---not just UTXOs
that match an LN template.  This would allow breaking the connection
between channels and UTXOs in several ways, including allowing owners
of UTXOs to sell non-spending signatures for them to LN node operators
who want maximal privacy.  It would also allow some non-LN UTXO owners
to broadcast fake channel announcements as part of a potential DoS
attack, but the amount of gossip that could be created would still be
limited by the cost to create and hold a UTXO.

A version of gossip v2 was first proposed in 2019, with an updated
version being proposed in 2022 that allowed using a wide range of UTXOs.
Concerns about the use of non-LN UTXOs have been debated since then,
with gossip v1.5 being proposed as a less ambitious alternative.  A
compromise version called v1.75 was [proposed][v1.75 gossip] at an LN developer
meeting.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[v1.75 gossip]: /en/newsletters/2023/07/26/#updated-channel-announcements
