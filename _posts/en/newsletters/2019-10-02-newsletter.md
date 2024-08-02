---
title: 'Bitcoin Optech Newsletter #66'
permalink: /en/newsletters/2019/10/02/
name: 2019-10-02-newsletter
slug: 2019-10-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter notes a proposed BIP that would allow nodes to
implement the Erlay transaction relay protocol, announces full
disclosure of vulnerabilities that affected earlier versions of LN
implementations, links to a transcript from a recent Optech schnorr
and taproot workshop, and includes a field report about some of the
technology Bitcoin exchange BTSE uses to conserve block chain
space while ensuring the safety of user deposits.  We also
describe several notable changes to popular Bitcoin infrastructure
projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*None this week.*

## News

- **Draft BIP for enabling Erlay compatibility:** a draft [BIP for
  transaction relay through set reconciliation][bip-reconcil] has been
  [posted][reconcil post] to the Bitcoin-Dev mailing list by [Erlay][]
  co-author Gleb Naumenko.  Currently, Bitcoin nodes send each of their
  peers the txids for all newly-seen transactions, resulting in each
  node receiving many duplicate txid announcements.  This can be quite
  bandwidth inefficient for Bitcoin's tens of thousands of nodes and
  several hundred thousand transactions a day.  Alternatively, as [described
  previously][erlay paper], minisketch-based set reconciliation allows
  nodes to send a *sketch* of a set of short txids that can be combined
  with the short txids the receiving peer already knows about to allow the
  receiver to recover the short txids it hasn't seen yet.  The size of the
  sketch is roughly equal to the expected size of the short txids that need to
  be recovered, reducing txid-announcement bandwidth.  Erlay is a
  proposal that suggests how to use this mechanism to achieve the best
  mix of bandwidth efficiency and network robustness.  This draft BIP
  describes the proposed implementation of the minisketch-based set
  reconciliation between nodes, laying the foundation for the
  implementation of Erlay.  We encourage anyone with feedback to contact
  the BIP authors either privately or on the mailing list.

- **Full disclosure of fixed vulnerabilities affecting multiple LN implementations:**
  several weeks ago, the developers of C-Lightning,
  Eclair, and LND announced the previous discovery of an undisclosed
  issue in each of their implementations, which they had each fixed in a
  recent release.  At that time, they strongly encouraged their users to
  upgrade (a message which Optech [relayed][optech ln warning]) and
  promised a full disclosure in the future, which they have now done
  with an [email][russell disclosure] by vulnerability discoverer and
  C-Lightning developer Rusty Russell and a [blog post][lnd stay safe]
  by LND developers Olaoluwa Osuntokun and Conner Fromknecht.

  Briefly, the issue appears to have been that the implementations did not
  confirm that channel open transactions paid the correct script,
  amount, or both.  Because of this, the implementations would accept
  payments within the channel which they would later be unable to get
  confirmed onchain, allowing them to be defrauded.  As of this writing,
  Optech is not aware of any reports that this issue was exploited
  prior to the warning last month.  Now that the issue has
  been disclosed, a [PR][BOLTS #676] has been opened to update the
  specification to note that this check is needed.

- **Optech taproot and schnorr workshop:** last week, Optech held workshops in
  both San Francisco and New York City teaching developers about the
  schnorr signature scheme and other parts of the proposed
  [taproot][bip-taproot] soft fork.  We thank Bryan Bishop for typing an
  excellent [transcript][workshop transcript] of the NYC workshop.  We
  are preparing videos and other educational material for release via a
  blog post in the near future.

## Field report: exchange operation using Bitcoin technologies at BTSE

{% include articles/dong-btse-operation.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #15558][] changes the number of DNS seeds Bitcoin Core
  typically queries.  DNS seeds are servers hosted by well-known
  contributors that return the IP addresses of listening peers (peers
  that accept incoming connections).  Newly-started nodes query the DNS
  seeds to find an initial set of peers; then those peers tell the node
  about other possible peers, with the node saving this information to
  disk for use later (including after restarts).  Ideally, nodes only
  ever query DNS seeds once---when they're first started.  Practically,
  though, they may also query on subsequent startups if none of the
  saved peers they select responds quickly enough.

  This merge causes Bitcoin Core to only query three DNS seeds at a
  time rather than all of them.  Three seeds should be enough
  diversity in sources to ensure the node connects to at least one
  honest peer (a requirement for Bitcoin security), but it's few enough
  that not every seed will learn about the querying node if it uses
  direct DNS resolution.  Which seeds to query are selected randomly
  from the list hardcoded into Bitcoin Core.

- [LND #3523][] allows users to update the maximum millisat value of
  HTLCs they'll accept in a particular open channel or across all of
  their open channels.

- [LND #3505][] limits invoices to 7,092 bytes, the maximum size that
  will fit in a single QR code.  Larger invoices could cause large
  amounts of memory to be allocated.  For example, a 1.7 MB invoice
  tested by the patch author produced about 38.0 MB in allocations.

- [Eclair #1097][] begins deriving channel keys from the funding pubkey,
  allowing Eclair to use the Data Loss Protection (DLP) scheme described
  in [Newsletter #31][dlp footnote] even if all data has been lost.
  This does require the user recall the node they opened their channel
  with and find the channel id (which is public information for public
  channels).
  This only applies to new channels
  opened after updating to a version of the software implementing this
  change; old channels are unaffected.  *(Note: an earlier version of
  this bullet mistakenly claimed this merged PR would make it possible
  for Eclair to add DLP support.  Instead, Eclair already had DLP
  support and this PR changed how the channel keys are derived in order
  to make that support useful even if all data is lost.  Optech thanks
  Fabrice Drouin for reporting our error.)*

- [C-Lightning #3057][] makes it possible to use postgres as
  C-Lightning's database manager.

- [C-Lightning #3064][] makes the changes described in [Newsletter
  #63][ln daily updates] for reducing how often a C-Lightning node will
  relay channel update announcements from other nodes.  This reduces the
  amount of gossip bandwidth a node uses.

{% include linkers/issues.md issues="15558,3523,3505,1097,3057,3064,676" %}
[lnd stay safe]: https://blog.lightning.engineering/security/2019/09/27/cve-2019-12999.html
[dlp footnote]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[ln daily updates]: /en/newsletters/2019/09/11/#request-for-comments-on-limiting-ln-gossip-updates-to-once-per-day
[bip-reconcil]: https://github.com/naumenkogs/bips/blob/bip-reconcil/bip-reconcil.mediawiki
[reconcil post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017323.html
[erlay paper]: /en/newsletters/2019/06/05/#erlay-proposed
[optech ln warning]: /en/newsletters/2019/09/04/#upgrade-ln-implementations
[workshop transcript]: http://diyhpl.us/wiki/transcripts/bitcoinops/schnorr-taproot-workshop-2019/notes/
[russell disclosure]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002174.html
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
