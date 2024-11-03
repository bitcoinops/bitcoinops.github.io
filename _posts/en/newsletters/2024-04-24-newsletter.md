---
title: 'Bitcoin Optech Newsletter #299'
permalink: /en/newsletters/2024/04/24/
name: 2024-04-24-newsletter
slug: 2024-04-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to relay weak blocks to
improve compact block performance in a network with multiple divergent
mempool policies and announces the addition of five BIP editors.  Also
included are our regular sections with selected questions and answers
from the Bitcoin Stack Exchange, announcements of new releases and
release candidates, and summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **Weak blocks proof-of-concept implementation:** Greg Sanders
  [posted][sanders weak] to Delving Bitcoin about using _weak blocks_ to
  improve [compact block relay][topic compact block relay], particularly
  in the presence of divergent policies for transaction relay and mining.
  A weak block is a block with insufficient proof-of-work (PoW) to
  become the next block on the blockchain but which otherwise has a
  valid structure and set of valid transactions.  Miners produce weak
  blocks in proportion to each weak block's percentage of the required
  PoW; for example, miners will produce (on average) 9 weak blocks at
  10% of the required PoW for every full-PoW block they produce.

  Miners don't know when they'll produce a weak block.  Each block
  candidate they attempt has an equal chance of achieving full-PoW, with
  some of those candidates ending up becoming weak blocks instead.  The only
  way to create a weak block is by doing exactly the same work necessary
  to produce a full-PoW block, meaning a weak block accurately reflects
  the transactions a miner was attempting to mine at the time the weak
  block was created.  For example, the only way to include an invalid
  transaction in a weak block is by risking creating a full-PoW block
  with the same invalid transaction---an invalid block that full nodes
  would reject and which would prevent the miner from receiving any
  block reward.  Of course, a miner who didn't want to advertise what
  transactions they were attempting to mine could simply refuse to
  broadcast their weak blocks.

  The high difficulty of creating a 10% weak block and the high cost of
  creating a weak block with invalid transactions make weak blocks
  strongly resistant to denial-of-service attacks that might attempt to
  waste large amounts of node bandwidth, CPU, and memory.

  Because a weak block is just a regular block with slightly insufficient
  PoW, they're the same size as regular blocks.  When relaying weak
  blocks was first described over a decade ago, that would mean relaying
  10% weak blocks would increase the bandwidth nodes used for block
  relay by up to 10x.  However, many years ago Bitcoin Core began using
  compact block relay that substitutes the transactions in blocks with
  short identifiers, allowing the receiving node to only request any
  transactions it hasn't previously seen.  This typically reduces the
  bandwidth required to relay a block by over 99%.  Sanders notes
  that this would work just as well for weak blocks.

  For full-PoW blocks, compact block relay not only saves bandwidth but
  it helps new blocks propagate much faster.  The less data (fewer full
  transactions) you need to send, the faster the remaining data can be
  sent.  Faster propagation of new blocks is important for mining
  decentralization: a miner who finds a new block can begin working on a
  successor block immediately, but other miners can only begin working
  on a successor after they receive the new block through relay.  This
  can give an advantage to large mining pools, creating an unintentional
  type of selfish mining attack (see [Newsletter #244][news244 selfish]).
  This problem was common before compact block relay was introduced and
  it led to both the centralization of mining into large pools and the use
  of problematic techniques, such as the spy-mining that resulted in the
  [July 2015 chain forks][].

  Compact block relay only saves bandwidth and speeds up block
  propagation when a node receives a new block mainly consisting of
  transactions it has already seen.  But, Sanders notes, some miners
  today are creating blocks with many transactions that aren't being
  relayed between nodes, reducing the benefits of compact relay and
  putting the network at risk of the problems that existed before
  compact block relay.  He proposed weak block relay as a solution:

  - Miners who create a weak block (for example, a 10% weak block) would
    casually relay it to nodes.  By casually, we mean that the relay
    would be treated like regular P2P network traffic, such as the relay
    of new unconfirmed transactions, rather than high-priority traffic
    like new blocks.

  - Nodes would casually accept the weak blocks and validate them.  PoW
    validation is trivial and would occur immediately; then the weak
    block would be temporarily stored in memory as its transactions were
    validated.  Any new transactions from the weak block that passed
    Bitcoin Core's policy rules would be added to the mempool.  Any that
    didn't pass would be stored in a special cache, similar to existing
    caches Bitcoin Core uses for temporarily storing transactions that
    can't be added to the mempool (e.g. the orphan transaction cache).

  - Additional weak blocks received later could update the mempool and
    cache.

  - When a new full-PoW block was received using compact block relay, it
    could be used with transactions from both the mempool and the
    weak-block cache---minimizing the need for additional relay time and
    bandwidth.  This could allow a network with many divergent node and
    miner policies to continue to benefit from compact blocks.

  Additionally, Sanders points to a previous discussion about weak
  blocks (see [Newsletter #173][news173 weak]) for how weak blocks could
  be used to help address [pinning attacks][topic transaction pinning]
  and improve [feerate estimation][topic fee estimation].  The use of
  weak block relay was also previously mentioned in a discussion about
  transaction relay over the Nostr protocol (see [Newsletter
  #253][news253 weak]).

  Sanders has written a "basic [proof-of-concept][sanders poc] with
  light tests to demonstrate the high-level idea".  Discussion of the
  idea was ongoing at the time of writing. {% assign timestamp="0:56" %}

- **BIP editors update:** after public discussion (see Newsletters
  [#292][news292 bips], [#296][news296 bips], and [#297][news297 bips]), the
  following contributors have been [made][chow editors] BIP editors:
  Bryan "Kanzure" Bishop,
  Jon Atack,
  Mark "Murch" Erhardt,
  Olaoluwa "Roasbeef" Osuntokun, and
  Ruben Somsen. {% assign timestamp="20:08" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Where exactly is the "off-by-one" difficulty bug?]({{bse}}20597)
  Antoine Poinsot explains the off-by-one error in Bitcoin's difficulty retargeting
  calculation that enables the [time warp attack][topic time warp] which the
  [consensus cleanup][topic consensus cleanup] proposal aims to address (see
  [Newsletter #296][news296 cc]). {% assign timestamp="26:44" %}

- [How is P2TR different than P2PKH using opcodes from a developer perspective?]({{bse}}122548)
  Murch concludes that the example Bitcoin Script provided as a P2PKH output
  script would be non-standard, more expensive than P2TR, but consensus valid. {% assign timestamp="32:10" %}

- [Are replacement transactions larger in size than their predecessors and than non-RBF transactions?]({{bse}}122473)
  Vojtěch Strnad notes that [RBF][topic rbf]-signaling transactions are the same
  size as non-signaling transactions and gives scenarios of when replacement
  transactions could be either the same size, larger, or smaller than the
  original transaction being replaced. {% assign timestamp="34:15" %}

- [Are Bitcoin signatures still vulnerable to nonce reuse?]({{bse}}122621)
  Pieter Wuille confirms that both the ECDSA and [schnorr][topic schnorr
  signatures] signature schemes, including their [multisignature
  variants][topic multisignature], are vulnerable to [nonce reuse][taproot nonces]. {% assign timestamp="36:59" %}

- [How do miners manually add transactions to a block template?]({{bse}}122725)
  Ava Chow outlines different approaches that a miner could use to include
  transactions in a block that wouldn't otherwise be included in Bitcoin Core's
  `getblocktemplate`:

  - use `sendrawtransaction` to include the transaction in the miner's mempool
    and then adjust the transaction's [perceived absolute
    fee][prioritisetransaction fee_delta] using `prioritisetransaction`
  - use a modified `getblocktemplate` implementation or separate block-building software

  {% assign timestamp="39:48" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.17.5-beta][] is a maintenance release that makes LND
  compatible with Bitcoin Core 27.x.

  As [reported][lnd #8571] to the LND developers, older versions of
  LND depended on an older version of [btcd][] that intended to set
  its maximum feerate to 10 million sat/kB (equivalent to 0.1 BTC/kB).
  However, Bitcoin Core accepts feerates in BTC/kvB, so the maximum
  feerate was actually being set to 10 million BTC/kvB.  Bitcoin Core
  27.0 included a [PR][bitcoin core #29434] that limited maximum
  feerates to 1 BTC/kvB in order to prevent certain problems and under
  the assumption that anyone setting a higher value was likely making
  a mistake (if they really wanted a higher maximum value, they could
  simply set the parameter to 0 to disable the check).  In this case,
  LND (via btcd) was indeed making a mistake, but the modification to
  Bitcoin Core prevented LND from being able to send onchain
  transactions, which can be dangerous for an LN node that sometimes
  needs to send time-sensitive transactions.  This maintenance release
  correctly sets the maximum value to 0.1 BTC/kvB, making LND
  compatible with new versions of Bitcoin Core. {% assign timestamp="41:40" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #29850][] limits the maximum number of IP addresses
  accepted from an individual DNS seed to 32 per query.  When querying
  DNS over UDP, the maximum packet size limited the number to 33, but
  alternative DNS querying over TCP can now return a much larger number
  of results.  New nodes connect to multiple DNS seeds to build a set of
  IP addresses.  They then randomly select some of those IP addresses
  and connect to them as peers.  If the new node gets roughly the same
  number of IP addresses from each seed it connects to, then it's
  unlikely that all of the peers its selects will have come from the
  same seed node, helping to ensure that it has a diverse perspective on
  the network and is not vulnerable to [eclipse attacks][topic eclipse
  attacks].

  However, if one seed returned a much larger number of IP addresses
  than any other seed, there would be a significant probability that the
  new node would randomly select a set of IP address that all came from
  that seed.  If the seed was malicious, that could allow it to isolate
  the new node from the honest network.  [Testing][bitcoin core #16070]
  showed that all seeds at that time returned 50 or fewer results, even
  though the maximum allowed was 256. This merged PR reduces the maximum
  number down to an amount similar to what seed nodes are currently
  returning. {% assign timestamp="46:35" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8571,29434,29850,16070" %}
[sanders weak]: https://delvingbitcoin.org/t/second-look-at-weak-blocks/805
[news173 weak]: /en/newsletters/2021/11/03/#feerate-communication
[news253 weak]: /en/newsletters/2023/05/31/#transaction-relay-over-nostr
[sanders poc]: https://github.com/instagibbs/bitcoin/commits/2024-03-weakblocks_poc/
[july 2015 chain forks]: https://en.bitcoin.it/wiki/July_2015_chain_forks
[selfish mining attack]: https://bitcointalk.org/index.php?topic=324413.msg3476697#msg3476697
[news244 selfish]: /en/newsletters/2023/03/29/#bitcoin-core-27278
[btcd]: https://github.com/btcsuite/btcd/pull/2142
[chow editors]: https://gnusha.org/pi/bitcoindev/CAMHHROw9mZJRnTbUo76PdqwJU==YJMvd9Qrst+nmyypaedYZgg@mail.gmail.com/T/#m654f52c426bd5696d88668b3bff25197846e14af
[news292 bips]: /en/newsletters/2024/03/06/#discussion-about-adding-more-bip-editors
[news296 bips]: /en/newsletters/2024/04/03/#choosing-new-bip-editors
[news297 bips]: /en/newsletters/2024/04/10/#updating-bip2
[LND v0.17.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.5-beta
[news296 cc]: /en/newsletters/2024/04/03/#revisiting-consensus-cleanup
[prioritisetransaction fee_delta]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html#argument-3-fee-delta
[taproot nonces]: /en/preparing-for-taproot/#multisignature-nonces
