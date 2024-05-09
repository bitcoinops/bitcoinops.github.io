---
title: Duplicate transactions

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Block 1,983,702 problem

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Security Problems
  - Soft Forks

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: BIP30
    - title: BIP34

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: Description of Block 1,983,702 Problem added to testnet documentation
    url: /en/newsletters/2022/01/12/#bitcoin-core-23882

  - title: "What is the Block 1,983,702 Problem?"
    url: /en/newsletters/2023/12/13/#what-is-the-block-1-983-702-problem

  - title: Updated consensus cleanup proposal to address Block 1,983,702 problem
    url: /en/newsletters/2024/04/03/#revisiting-consensus-cleanup

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Consensus cleanup soft fork
    link: topic consensus cleanup

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Duplicate transactions** are more than one transaction that are
  identical and have identical txids.  Bitcoin's consensus rules use
  txids to uniquely identify transactions, so duplicate transactions can
  cause unwanted behavior.

---
Each regular Bitcoin transaction spends at least one output of a
previous transaction, identifying that output by a hash digest of the
transaction that contains it (a _txid_) and an index number indicating
the output's location in the previous transaction.  Cryptographically
secure hash functions should effectively always return a unique hash
digest for unique data, so as long as each transaction is unique, this
mechanism allows the Bitcoin protocol to uniquely identify outputs.
That's essential because a critical consensus rule forbids any output
from being spent more than once on a given blockchain, preventing
unwanted inflation by ensuring that each user can only spend a
particular set of bitcoins once.

The first transaction in a block (a _coinbase transaction_) is not a
regular transaction.  It is forbidden from referring to any previous
transaction.  In the original Bitcoin protocol, it was easy to construct
two coinbase transactions in different blocks that were identical to
each other, leading to them having identical txids.

At least one person who discovered this potential problem did create
duplicate transactions onchain.  Because the situation was
unanticipated, the behavior was unspecified, but nearly everyone at the
time ran the same full node software, so we can describe what it did: a
later transaction overwrote an identical earlier transaction in the
output-tracking database.  Both transactions paid the same output
script, but only one of them was now spendable, meaning the transaction
creator lost money.

However, if the creator had spent the
output of the first transaction before creating the duplicate transaction, they (or anyone else)
could have also spent the duplicate output by simply rebroadcasting the
first spend.  If their spends had multiple outputs, they could quickly
multiply the number of potential duplicate transactions on the network
and could use this to confuse and (likely) attack full nodes and wallets
that were built on the assumption that valid duplicate transactions were
impossible.

The [BIP30][] soft fork limited the damage by forbidding any transaction
in a new block from having the same txid as a partly unspent previous
transaction.  A later soft fork [BIP34][] attempted to fix the problem
entirely by requiring each coinbase transaction include unique data,
ensuring it was a unique transaction with a unique txid.  Unfortunately,
it was later discovered that some pre-BIP34 blocks contained the unique
data necessary for a later block to pass the BIP34 rule, called the
**block 1,983,702 problem** for the first block which can circumvent the
intended BIP34 protection.

Recent versions of the proposed [consensus cleanup][topic consensus
cleanup] soft fork has proposed to fix the eventual problem by requiring
slightly more unique data be included in coinbase transactions.

For reference, the txids of two different historic duplicate
transactions (four transactions total) are
[d5d2...8599][] (in blocks 91,812 and 91,842)
and
[e3bf...b468][] (in blocks 91,722 and 91,880).

{% include references.md %}
{% include linkers/issues.md issues="" %}
[d5d2...8599]: https://blockstream.info/tx/d5d27987d2a3dfc724e359870c6644b40e497bdc0589a033220fe15429d88599
[e3bf...b468]: https://blockstream.info/tx/e3bf3d07d4b0375638d5f1db5255fe07ba2c4cb067cd81b84ee974b6585fb468
