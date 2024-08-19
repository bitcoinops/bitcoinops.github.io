---
title: Pooled mining

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Betterhash
  - Braidpool
  - Stratum
  - Stratum v2

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Mining

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Betterhash specification (draft)"
      link: https://github.com/TheBlueMatt/bips/blob/betterhash/bip-XXXX.mediawiki

    - title: Stratum v2 specification
      link: https://stratumprotocol.org/specification/

    - title: Braidpool specification
      link: https://github.com/braidpool/braidpool/blob/main/docs/braidpool_spec.md

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Betterhash mining protocol draft specification published
    url: /en/newsletters/2018/06/08/#betterhash-mining-protocol-betterhash-spec

  - title: Transcript of developer discussion about Stratum v2 and Braidpool
    url: /en/newsletters/2022/10/26/#stratum-v2

  - title: Stratum v2 reference implementation update announced
    url: /en/newsletters/2023/04/19/#stratum-v2-reference-implementation-update-announced

  - title: Stratum v2 mining pool launches
    url: /en/newsletters/2023/12/13/#stratum-v2-mining-pool-launches

  - title: "Announcement of BraidPool, a P2Pool alternative"
    url: /en/newsletters/2021/09/08/#braidpool-a-p2pool-alternative

  - title: "How does the TIDES payout scheme work?"
    url: /en/newsletters/2024/02/28/#how-does-ocean-s-tides-payout-scheme-work

  - title: "Bitcoin Core #30200 adds a new mining interface to better support Stratum v2 in the future"
    url: /en/newsletters/2024/07/05/#bitcoin-core-30200

  - title: "Stratum.work website with real-time visualization of Stratum messages from several mining pools"
    url: /en/newsletters/2024/07/19/#real-time-stratum-visualization-tool-released

  - title: "Stratum v2 benchmarking tool released"
    url: /en/newsletters/2024/08/23/#stratum-v2-benchmarking-tool-released

## Optional.  Same format as "primary_sources" above
#see_also:
#  - title:
#    link:

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Pooled mining** occurs when two or more independent miners
  collaborate on finding proof of work for new blocks, with them fairly
  dividing the rewards of any blocks they find.  **Betterhash**,
  **Braidpool**, **Stratum**, and **Stratum v2** are protocols for
  coordinating pooled mining.

---
Hashing a block header will produce a value that can be interpreted as a
number.  Hashing many unique block headers using double-SHA256 will
produce a uniform distribution of numbers within the range 0 to
2<sup>256</sup>-1.  For example, approximately 1% of the numbers will
have values less than 1% of the range's maximum value.  For a block to
contain enough proof of work to be valid, its header must hash to a
value below a _target_ value that is dynamically set by the
protocol.  For example, if the target value is 1% of the range maximum,
each hash of a unique header has a 1% chance of being below the target.

A corollary of the above is that each hash that is below
the target value will belong to a set of hashes that is below some
higher target.  For example, if the primary target value is 1%, we would
expect every hash below that value to have resulted in finding an
average of 9 other hashes that are all below a secondary target of 10%.
A header hash below a secondary target is called a _share_ in pooled
mining.  Only shares below the primary target can produce a valid block,
but each share demonstrates an amount of proof of work in the same
proportion as the primary target to the secondary target.  For example,
if the primary target is 1% and the secondary target is 10%, each share
proves an amount of work equal to 10% of the average work needed to
create a block.

The use of shares allows pools to efficiently and equitably track how
much work is contributed by each member of a pool.  In a simple payout
scheme, such as _pay per share_ (PPS), a pool may pay Alice 10% of a
typical block reward for each 10% share she submits.  This allows Alice
to profit even if she doesn't personally find a hash with the 10x higher
amount of proof of work needed for a valid block.  If Alice does find
a proof of work demonstrating that required 10x higher value, a pure PPS
scheme will still only pay her for one share (e.g. 10%).  PPS schemes
face various problems in practice, some of which we'll describe later in
this article, but PPS provides a simple framework for understanding how
miners can equitably divide the rewards from producing blocks.

Shares are a type of _weak block_.  They need to follow at least two
rules:

- A share must be either a valid block or what would have been a valid
  block if it had a header hash below the primary target.

- The coinbase transaction must follow a template provided by the pool.
  For example, all pools we know of use the coinbase transaction to pay
  either the pool operator (who later distributes rewards to pool
  members) or to pay pool members directly.

Pools may impose additional requirements on their members, either
explicitly or by using a pool protocol that does not give members the
flexibility to make certain choices.

## Pool protocols

The earliest pool protocol was built around transmitting block header
templates in the format used by the early Bitcoin Core RPC `getwork`.
When the speed of mining equipment made that impractical, an early
attempt at creating a distributed mining protocol was specified in BIPs
[22][BIP22] and [23][BIP23], with a partial implementation in Bitcoin
Core as the `getblocktemplate` RPC.  GetBlockTemplate never saw
widespread usage as a pool protocol itself, although many centralized
pool servers have used it for the past decade in the background to obtain
a good set of transactions to mine from their local Bitcoin Core node.

As the GetWork-based protocol became problematic, most mining pools
switched to the Stratum protocol (v1).  Stratum v1 allows pools to
only send their members a template for a block header and a coinbase
transaction, which can be less than 200 bytes.  When a member finds a
share, they can send back roughly the same information.  This very
compact information minimizes the overhead of the pool protocol.  The
downside of the way GetWork and Stratum v1 are typically used is that
pool members have no insight or direct control over what they mine.  They
aren't directly informed about which transactions are included in the
template block (or excluded from it) and the pool may reject any attempt they make to change
those transactions.  They are (by necessity) informed of what their
block claims is the previous block header, but few Stratum v1 users
ensure that is what their own full nodes think should be the previous
block header; this lack of independent validation has allowed pools in
the past to [steal][betcoindice] from website operators and lose money
accidentally [violating consensus rules][jul2015 chainsplits].  Although
BIPs [40][bip40] and [41][bip41] were reserved for Stratum v1,
documentation for them has never been provided.

[Betterhash][] was a proposed mining pool protocol that allowed pool
members to select which transactions to include in the blocks they
create.  The protocol also made it easy for pool members who found a
new block to submit it directly to the network through their Bitcoin
full node, which could reduce propagation times and improve the chance
of that block becoming a permanent part of the block chain.  Additional
improvements in Betterhash focused on security and efficiently
distributing work across multiple mining hardware devices.  Although the
proposal has not been withdrawn, it does appear that development of it
has been replaced by development on Stratum v2.

[Stratum v2][] is an entirely new protocol developed by several of the
same people who contributed to Stratum v1.  It provides several of the
same advantages as Betterhash, although sometimes using different
mechanisms.  Like Betterhash, one of its key advantages is that it can
allow individual pool members to choose which transactions to include in
their blocks.  Stratum v2 is used in production as of this writing,
although some advanced features are not fully supported by any widely
deployed mining software.

[BraidPool][] is a proposed design for a fully decentralized mining
pool.  Unlike a typical centralized mining pool managed with Stratum v1
or v2, members of a BraidPool must all chose their own transactions and
funds will be paid for any valid share, preventing the pool from
interfering with each individual member's choices about what transactions to mine.
BraidPool is inspired by the former [P2Pool][] decentralized mining pool
but attempts to mitigate some of P2Pool's problems, including its
reduced ability to capture fee income due to its large typical
coinbase transactions and the frequency of P2Pool shares becoming stale.
BraidPool is under active development as of this writing.

## Pool payout schemes

Previously in this article, we've describe a single idealized payout:
a miner who creates a 1/100th share for a block template with a block
reward of 12.3456789 BTC will receive a payout of 0.1234567890 BTC.  In
practice, no pool we're aware of pays exactly that way, and they use
slightly different jargon.  The following describes general types of
payouts, although each pool's implementation of them may differ from our
descriptions and from other pools.

- **Pay per share (PPS)** pays an amount proportional to each share's
  PoW.  For example, each
  share might be proportional to the block subsidy.  If the subsidy is
  3.25 BTC and a miner creates a 1/100th share, the miner receives a
  payment of 0.0325 BTC.  PPS has the advantage of being extremely
  simple.  A miner can compare all PPS pools and choose the one that
  pays the most per share; the miner can then simply count how many
  shares they submit (at a constant PoW) and determine whether the pool
  is paying them appropriately.  However, PPS does have downsides:

  - *Excludes transaction fees:* as originally used, most pools paid a
    fixed rate based on the block subsidy and kept for themselves any
    excess in the block reward that came from the transaction fees.

  - *Subject to variance:* a 1% pool would be expected to find about
    1.44 blocks per day and so would need to pay out rewards for about
    1.44 blocks worth of shares every day.  However, that pool might go
    days without actually finding a block, requiring them to maintain a
    significant amount of capital.  Additionally, even a slight [block
    withholding attack][topic block withholding] could reduce pool profitability below a
    sustainable level.

- **Full pay per share (FPPS)** works like PPS but includes transaction
  fees (or a proxy for them) in share payouts.  The idealized form of
  FPPS is the same as the idealized pool we've described in the first
  paragraph of this section.  However, in practice, pools almost always
  use a proxy for the amount of fees in a block, such as an average of
  the amount of fees collected over a 24 hour period, sometimes with
  very high feerate transactions excluded (possibly because pools
  sometimes refund those fees).  This makes paying out shares much
  simpler but it still leaves the pool subject to variance.

- **Pay per last n shares (PPLNS)** only pays out the actual amount
  earned by the pool, eliminating problems for the pool with variance
  and block withholding attacks, but potentially leaving miners unpaid.
  In PPLNS, only the last _n_ shares are paid.  For example, in a 0% fee
  pool with shares equal to 1/100th of full-block PoW, the pool might
  pay each of the last 200 shares 0.5% of the reward for each block
  found by the pool.

  This allows the pool to operate without holding any capital, however
  it transfers the risk of variance to the individual miners.  If more
  than 200 shares are submitted before a block is found, the miners who
  submitted the earliest shares won't be rewarded for them.  This is
  theoretically compensated for by the case where a block being found
  before 200 shares are submitted rewarding some miners twice.  It also
  transfers the risk of block withholding attacks to the individual
  miners: they are not paid until a block is found by the pool.

  PPLNS also makes it easy to calculate proportional transaction fees,
  as each share can be rewarded from the actual amount of transaction
  fees collected in a block found by the pool.  However, all miners in
  the pool are rewarded equally whether they mainly worked on high
  feerate blocks for the pool or low feerate blocks for the pool.

At the time of writing, many miners seem to prefer FPPS pools, possibly
due to it being easy to determine in advance how much they'll be paid
for contributing a particular amount of hashrate.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[betcoindice]: https://bitcointalk.org/index.php?topic=327767.0
[jul2015 chainsplits]: https://en.bitcoin.it/wiki/July_2015_chain_forks
[betterhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016077.html
[stratum v2]: https://stratumprotocol.org/
[braidpool]: https://github.com/braidpool/braidpool
[p2pool]: https://bitcointalk.org/index.php?topic=18313.0
