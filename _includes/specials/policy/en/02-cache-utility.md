[Last week’s post][policy01] discussed mempool as a cache of unconfirmed
transactions that provides a decentralized method for users to send
transactions to miners. However, miners are not obligated to confirm
those transactions; a block with just a coinbase transaction is valid
by consensus rules. Users can incentivize miners to include their
transactions by increasing total input value without changing total
output value, allowing miners to claim the difference as transaction
_fees_.

Although transaction fees are common in traditional financial systems,
new Bitcoin users are often surprised to find that on-chain fees are
paid not in proportion to the transaction amount but by the weight of
the transaction. Block space, instead of liquidity, is the limiting
factor. _Feerate_ is typically denominated in satoshis per virtual
byte.

Consensus rules limit the space used by transactions in each block.
This limit keeps block propagation times low relative to the block
interval, reducing the risk of stale blocks. It also helps restrict
the growth of the block chain and UTXO set, both of which directly
contribute to the cost of bootstrapping and maintaining a full node.

As such, as part of their role as a cache of unconfirmed transactions,
mempools also facilitate a public auction for inelastic block space:
when functioning properly, the auction operates on free-market
principles, i.e., priority is based purely on fees rather than
relationships with miners.

Maximizing fees when selecting transactions for a block (which has
limits on total weight and signature operations) is an [NP-hard problem][]. This problem
is further complicated by transaction relationships: mining a
high-feerate transaction may require mining its low-feerate parent.
Put another way, mining a low-feerate transaction may open up the
opportunity to mine its high-feerate child.

The Bitcoin Core mempool computes the feerate for each entry and its
ancestors (called _ancestor feerate_), caches that result, and uses
a greedy block template building algorithm. It sorts the mempool in
_ancestor score_ order (the minimum of ancestor feerate and individual
feerate) and selects ancestor packages in that order, updating
the remaining transactions' ancestor fee and weight information as it goes.
This algorithm offers a balance between performance and profitability,
and does not necessarily produce optimal results. Its efficacy can be
boosted by restricting the size of transactions and ancestor
packages---Bitcoin Core sets those limits to 400,000 and 404,000 weight
units, respectively.

Similarly, a _descendant score_ is calculated that is used when
selecting packages to evict from the mempool, as it would be
disadvantageous to evict a low-feerate transaction that has a
high-feerate child.

Mempool validation also uses fees and feerate when dealing with
transactions that spend the same input(s), i.e. double-spends or
conflicting transactions. Instead of always keeping the first
transaction it sees, nodes use a set of rules to determine which
transaction is the more incentive compatible to keep. This behavior is
known as [Replace by Fee][topic rbf].

It is intuitive that miners would maximize fees, but why should a
non-mining node operator implement these policies? As mentioned in
last week's post, the utility of a non-mining node's mempool is
directly related to its similarity to miners' mempools. As such, even
if a node operator never intends to produce a block using the contents
of its mempool, they have an interest in keeping the most
incentive-compatible transactions.

While there are no consensus rules requiring transactions to pay fees,
fees and feerate play an important role in the Bitcoin network as a
"fair" way to resolve competition for block space.  Miners use feerate
to assess acceptance, eviction, and conflicts, while non-mining nodes
mirror those behaviors in order to maximize the utility of their
mempools.

The scarcity of block space exerts a downward pressure on the size of
transactions and encourages developers to be more efficient in
transaction construction. Next week's post will explore practical
strategies and techniques for minimizing fees in on-chain
transactions.

[policy01]: /en/newsletters/2023/05/17/#waiting-for-confirmation-1-why-do-we-have-a-mempool
[np-hard problem]: https://en.wikipedia.org/wiki/NP-hardness
