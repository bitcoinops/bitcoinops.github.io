Last week’s post introduced policy, a set of transaction validation
rules applied in addition to consensus rules. These rules are not
applied to transactions in blocks, so a node can still stay in
consensus even if its policy differs from that of its peers. Just like
a node operator may decide to not participate in transaction relay,
they are also free to choose any policy, up to none at all (exposing
their node to the DoS risk). This means we cannot assume complete
homogeneity of mempool policies across the network. However, in order
for a user’s transaction to be received by a miner, it must travel
through a path of nodes that all accept it into their mempool –
dissimilarity of policy between nodes directly affects transaction
relay functionality.

As an extreme example of policy differences between nodes, imagine a
situation in which each node operator chose a random `nVersion` and
only accepted transactions with that `nVersion`.  As most peer-to-peer
relationships would have incompatible policies, transactions would not
propagate to miners.

On the other end of the spectrum, identical policies across the
network help converge mempool contents. A network with matching
mempools relays transactions the most smoothly, and is also ideal for
[fee estimation][policy04] and [compact block relay][policy01] as
mentioned in previous posts.

Given the complexity of mempool validation and the difficulties that
arise from policy disparities, Bitcoin Core has [historically been
conservative][aj mempool consistency] with the configurability of
policies. While users are able to easily tweak the way sigops are
counted (`bytespersigop`) and limit the amount of data embedded
in `OP_RETURN` outputs (`datacarriersize` and `datacarrier`), they
cannot opt out of the 400,000 weight-unit maximum standard weight or apply a
different set of fee-related RBF rules without changing the source
code.

Some of Bitcoin Core’s policy configuration options exist to
accommodate the difference in node operating environments and purposes
for running a node. For example, a miner’s hardware resources and
purpose for keeping a mempool differ from a day-to-day user running a
lightweight node on their laptop or Raspberry Pi. A miner may opt to
increase their mempool capacity (`maxmempool`) or expiration timeline
(`mempoolexpiry`) to store low feerate transactions during peak
traffic, and then mine them later when traffic dies down. Websites
providing visualizations, archives, and network statistics may run
multiple nodes to collect as much data as possible and also display
default mempool behavior.

On an individual node, the choice of mempool capacity affects the
availability of fee-bumping tools.  When the mempool minimum feerates
rise due to transaction submissions exceeding the default mempool
size, transactions purged from the “bottom” of the mempool and new
ones that are below this feerate can no longer be fee-bumped using
[CPFP][topic cpfp].

On the other hand, since the inputs used by the purged transactions
are no longer spent by any transactions in the mempool, it may be
possible to fee-bump via [RBF][topic rbf] when it wasn’t before. The new
transaction isn’t actually replacing anything in the node’s mempool,
so it doesn’t need to consider the usual RBF rules. However, nodes
that haven’t evicted the original transaction (because they have a
larger mempool capacity) treat the new transaction as a proposed
replacement and require it to abide by the RBF rules. If the purged
transaction was not signaling BIP125 replaceability, or the new
transaction’s fee does not meet RBF requirements despite being high
feerate, the miner may not accept their new transaction. Wallets must
handle purged transactions carefully: the transaction’s outputs cannot
be considered available for spending, but the inputs are similarly
unavailable to reuse.

At quick glance, it may seem that a node with larger mempool capacity
makes CPFP more useful and RBF less useful. However, transaction relay
is subject to emergent network behavior and there might not be a path
of nodes accepting the CPFP from the user to the miner. Nodes
typically only forward transactions once upon accepting it to their
mempool and ignore announcements of transactions that already exist in
their mempools—nodes that store more transactions [act as
blackholes][se maxmempool] when those transactions are rebroadcast to
them. Unless the entire network increases their mempool capacities –
which would be a sign to change the default value – users should
expect little benefit from increasing the capacity of their own
mempools. The mempool minimum feerate set by default mempools limits
the utility of using CPFP during high-traffic times. A user who
managed to submit a CPFP transaction to their own increased-size
mempool might fail to notice that the transaction did not propagate to
anyone else.

The transaction relay network is composed of individual nodes which
dynamically join and leave the network, each of whom must protect
themselves against exploitation. As such, transaction relay can only
be a best-effort and we cannot guarantee that every node learns about
every unconfirmed transaction. At the same time, the Bitcoin network
performs best if nodes converge on one set of transaction relay
policies that makes mempools as homogeneous as possible. The next post
will explore what policies have been adopted in order to fit the
network’s interests as a whole.

[policy01]: /en/newsletters/2023/05/17/#waiting-for-confirmation-1-why-do-we-have-a-mempool
[policy04]: /en/newsletters/2023/06/07/#waiting-for-confirmation-4-feerate-estimation
[aj mempool consistency]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021116.html
[se maxmempool]: https://bitcoin.stackexchange.com/questions/118137/how-does-it-contribute-to-the-bitcoin-network-when-i-run-a-node-with-a-bigger-th

