---
title: 'Bitcoin Optech Newsletter #314'
permalink: /en/newsletters/2024/08/02/
name: 2024-08-02-newsletter
slug: 2024-08-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the disclosure of two vulnerabilities
affecting older versions of Bitcoin Core and summarizes a proposed
approach to optimizing miner transaction selection when cluster mempool
is in use.  Also included are our regular sections announcing new releases
and release candidates and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Disclosure of vulnerabilities affecting Bitcoin Core versions before 22.0:**
  Niklas Gögge [posted][goegge disclosure] to the Bitcoin-Dev mailing
  list a link to announcements of
  two vulnerabilities affecting versions of Bitcoin Core that have been
  past their end of life since at least October 2022.  This follows a
  previous disclosure last month of older vulnerabilities (see
  [Newsletter #310][news310 disclosure]).  We summarize the disclosures
  below:

  {% assign timestamp="0:56" %}

  - [Remote crash by sending excessive `addr` messages][]: before
    Bitcoin Core 22.0 (released September 2021), a node that was told about
    more than 2<sup>32</sup> other possible nodes would crash due to
    exhaustion of a 32-bit counter.  This could be accomplished by an
    attacker sending a large number of P2P `addr` messages (at least 4
    million messages). <!-- assuming 1,000 addresses per addr message -->
    Eugene Siegel [responsibly disclosed][topic responsible disclosures]
    the vulnerability and a fix was included in Bitcoin Core 22.0.  See
    [Newsletter #159][news159 bcc22387] for our summary of the fix,
    which was written without us knowing that it patched a
    vulnerability.

  - [Remote crash on local network when UPnP enabled][]: before Bitcoin Core
    22.0, nodes that enabled [UPnP][] for automatically configuring [NAT
    traversal][] (disabled by default due to previous vulnerabilities,
    see [Newsletter #310][news310 miniupnpc]) were vulnerable to a
    malicious device on the local network repeatedly sending variants
    of a UPnP message.  Each message could result in the allocation of
    additional memory until the node crashed or was terminated by the
    operating system.  An infinite loop bug in Bitcoin Core's dependency
    miniupnpc was reported to the miniupnpc project by Ronald Huveneers,
    with Michael Ford discovering and responsibly disclosing how it
    could be used to crash Bitcoin Core.  A fix was included in Bitcoin
    Core 22.0.

  Additional vulnerabilities affecting later versions of Bitcoin Core
  are expected to be disclosed in a few weeks.

- **Optimizing block building with cluster mempool:** Pieter Wuille
  [posted][wuille selection] to Delving Bitcoin about ensuring that
  miner block templates can include the best set of transactions when
  using [cluster mempool][topic cluster mempool].  In the design for
  cluster mempool, _clusters_ of related transactions are divided into
  an ordered list of _chunks_, with each chunk obeying two constraints:

  1. If any transactions within the chunk depend on other unconfirmed
     transactions, those other transactions must either be a part of
     that chunk or appear in a chunk earlier in the ordered list of
     chunks.

  2. Each chunk must have an equal or higher feerate than the chunks
     that come after it in the ordered list.

  This allows every chunk from every cluster in the mempool to be placed
  into a single list in feerate order---highest feerate to lowest
  feerate.  Given a chunked mempool in feerate order, a miner can
  construct a block template by simply iterating over each chunk and
  including it in their template until they reach a chunk that will not
  fit their desired maximum block weight (which is usually a bit below
  the 1 million vbyte limit to leave room for the miner's coinbase
  transaction).

  However, clusters and chunks vary in size, with the default upper
  limit for a cluster in Bitcoin Core expected to be about 100,000
  vbytes.  That means a miner constructing a block template that is
  targeting 998,000 vbytes, and which already has 899,001 vbytes filled,
  may encounter a 99,000 vbyte chunk that doesn't fit, leaving roughly
  10% of their block space unused.  That miner can't simply skip that
  99,000-vbyte chunk and try to include the next chunk because the next
  chunk might include a transaction that depends on the 99,000-vbyte
  chunk.  If a miner fails to include a dependent transaction in their
  block template, any block they produce from that template will be
  invalid.

  To work around this edge case problem, Wuille describes how large
  chunks can be broken down into smaller _sub-chunks_ that can
  considered for inclusion in the remaining block space based on their
  feerates.  A sub-chunk can be created by simply removing the last
  transaction in any existing chunk or sub-chunk that has two or more
  transactions.  This will always produce at least one sub-chunk that is
  smaller than its original chunk and it may sometimes result in several
  sub-chunks.  Wuille demonstrates that the number of chunks and
  sub-chunks equals the number of transactions, with each
  transaction belonging to a unique chunk or sub-chunk.  That makes it
  possible to precompute each transaction's chunk or sub-chunk, called
  its _absorption set_, and associate that with the transaction.  Wuille
  shows how the existing chunking algorithm already calculates each
  transaction's absorption set.

  When a miner has filled a template with all of the full chunks
  possible, it can take the precomputed absorption sets for all
  transactions not yet included in the block and consider them in feerate
  order.  This only requires a single sort operation on a list with the
  same number of elements as there are transactions in the mempool
  (almost always less than a million with current defaults).  The best
  feerate absorption sets (chunks and sub-chunks) can then be used to
  fill the remaining block space.  This requires tracking the number of
  transactions from a cluster that have been included so far and
  skipping any sub-chunks that don't fit or which have already had some
  of their transactions included.

  However, although chunks can be compared with each other to provide the best
  order for block inclusion, the individual transactions within a chunk
  or sub-chunk are not guaranteed to be in the best order for only
  including some of those transactions.  That can lead to non-optimal
  selection when a block is nearly full.  For example, when only 300
  vbytes remain, the algorithm might select a 200-vbyte transaction at
  5 sats/vbyte (1,000 sats total) instead of two 150-vbyte transactions
  at 4 sats/vbyte (1,200 sats total).

  Wuille describes how precomputed absorption sets are especially useful
  in this case: because they only require tracking the number of
  transactions from each cluster that have been included so far, they
  make it easy to restore to an earlier state in the template-filling
  algorithm and replace the previously made choice with an alternative
  to see if it results in collecting more total fees.  This
  allows implementing a [branch-and-bound][] search that can try many
  combinations of filling the last bit of block space in the hopes of
  finding a better result than the simple algorithm. {% assign timestamp="11:23" %}

- **Hyperion network event simulator for the Bitcoin P2P network:**
  Sergi Delgado [posted][delgado hyperion] to Delving Bitcoin about
  [Hyperion][], a network simulator he's written that tracks how data
  propagates through a simulated Bitcoin network.  The work is initially
  motivated by a desire to compare Bitcoin's current method for relaying
  transaction announcements (`inv` inventory messages) to the proposed
  [Erlay][topic erlay] method. {% assign timestamp="14:30" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 1.0.0-beta.1][] is a release candidate for "the first beta version of
  `bdk_wallet` with a stable 1.0.0 API". {% assign timestamp="41:01" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30515][] adds a UTXO's block hash and confirmation count as
  additional fields to the `scantxoutset` RPC command response. This provides a
  more reliable identifier for the UTXO's block than just the block height,
  especially since chain reorganizations can occur. {% assign timestamp="41:36" %}

- [Bitcoin Core #30126][] introduces a [cluster linearization][wuille
  cluster] function `Linearize` that operates on clusters of related
  transactions to create or improve linearizations, as part of the
  [cluster mempool][topic cluster mempool] project. Cluster
  linearizations suggest a fee-maximizing order in which a cluster's
  transactions could be added to block templates (or a minimal-fee-loss
  order in which they can be evicted from a full mempool).  These functions
  are not yet integrated into the mempool, so there's no behavior change
  in this PR. {% assign timestamp="43:00" %}

- [Bitcoin Core #30482][] improves parameter validation for REST endpoint
  `getutxos` by rejecting truncated or overlarge txids and throwing an
  `HTTP_BAD_REQUEST` parse error. Previously this would also fail, but would be
  handled silently. {% assign timestamp="44:18" %}

- [Bitcoin Core #30275][] changes the default mode of the `estimatesmartfee` RPC
  command from conservative to economical. This change is based on user and
  developer observations that the conservative mode often leads to overpayment
  of transaction fees because it is less responsive to short-term fee market
  drops than the economical mode when [estimating fees][topic fee estimation]. {% assign timestamp="45:18" %}

- [Bitcoin Core #30408][] replaces the use of the wording "public key script" to
  "output script" to refer to a `scriptPubKey` in the help text for the following
  RPC commands `decodepsbt`, `decoderawtransaction`, `decodescript`, `getblock`
  (if verbosity=3), `getrawtransaction` (if verbosity=2,3),  and `gettxout`.
  This is the same wording used in the proposed BIP for transaction
  terminology (See Newsletter [#246][news246 bipterminology]). {% assign timestamp="47:29" %}

- [Core Lightning #7474][] updates the [offers][topic offers] plugin to allow
  for the newly defined experimental ranges for Type-Length-Value (TLV) types
  used in offers, invoice requests, and invoices. This was recently added to the
  unmerged [BOLT12 pull request][bolt12 pr] in the BOLTs repository. {% assign timestamp="49:27" %}

- [LND #8891][] adds a new `min_relay_fee_rate` field to the expected response
  from an  external [fee estimation][topic fee estimation] API source, allowing
  the service to specify the minimum relay fee rate. If not specified, the
  default `FeePerKwFloor` of 1012 sats/kvB (1.012 sats/vbyte) will be used. The PR also improves
  startup reliability by returning an error from `EstimateFeePerKW` if called
  before the fee estimator has fully initialized. {% assign timestamp="51:21" %}

- [LDK #3139][] improves the security of BOLT12 [offers][topic offers] by
  authenticating the use of [blinded paths][topic rv routing].  Without
  this authentication, attacker Mallory can take Bob's offer and request
  an invoice from each node on the network to determine which one of
  them belongs to Bob, negating the privacy benefit of using a blinded
  path.  To fix this, a 128-bit nonce
  is now included in each offer's encrypted blinded path, rather than in the offer's
  unencrypted metadata. This change invalidates outbound
  payments and refunds with non-empty blinded paths created
  in prior versions. On the other hand, offers created in prior versions are
  still valid but are vulnerable to de-anonymization attacks, so users
  may want to regenerate them after they update to a version of LDK that
  includes this patch. {% assign timestamp="51:57" %}

- [Rust Bitcoin #3010][] introduces a length field to `sha256::Midstate`,
  allowing for more flexible and accurate tracking of the hash state
  when incrementally generating a SHA256 digest. This
  change may affect existing implementations that rely on the previous
  `Midstate` structure. {% assign timestamp="52:48" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30515,30126,30482,30275,30408,7474,8891,3139,3010" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[wuille selection]: https://delvingbitcoin.org/t/cluster-mempool-block-building-with-sub-chunk-granularity/1044
[branch-and-bound]: https://en.wikipedia.org/wiki/Branch_and_bound
[delgado hyperion]: https://delvingbitcoin.org/t/hyperion-a-discrete-time-network-event-simulator-for-bitcoin-core/1042
[hyperion]: https://github.com/sr-gi/hyperion
[news310 disclosure]: /en/newsletters/2024/07/05/#disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-before-0-21-0
[Remote crash by sending excessive `addr` messages]: https://bitcoincore.org/en/2024/07/31/disclose-addrman-int-overflow/
[news159 bcc22387]: /en/newsletters/2021/07/28/#bitcoin-core-22387
[news310 miniupnpc]: /en/newsletters/2024/07/05/#remote-code-execution-due-to-bug-in-miniupnpc
[Remote crash on local network when UPnP enabled]: https://bitcoincore.org/en/2024/07/31/disclose-upnp-oom/
[upnp]: https://en.wikipedia.org/wiki/Universal_Plug_and_Play
[nat traversal]: https://en.wikipedia.org/wiki/NAT_traversal
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[goegge disclosure]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bf5287e8-0960-45e8-9c90-64ffc5fdc9aan@googlegroups.com/
[news246 bipterminology]: /en/newsletters/2023/04/12/#proposed-bip-for-transaction-terminology
[bolt12 pr]: https://github.com/lightning/bolts/pull/798
