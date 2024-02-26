<!--
  300 to 1000 words
  put title in main newsletter
  put links in this file
  for any subheads use h3 (i.e., ###)
  illustrations welcome (max width 800px)
  if uncertain about anything, just do what seems best and harding will edit
-->

Many nodes on the Bitcoin network store unconfirmed transactions in an
in-memory pool, or _mempool_. This cache is an important resource
for each node and enables the peer-to-peer transaction relay network.

Nodes that participate in transaction relay
download and validate blocks gradually rather than in spikes.
Every ~10 minutes when a block is found, nodes without a mempool
experience a bandwidth spike, followed by a computation-intensive
period validating each transaction.  On the other hand, nodes with a
mempool have typically already seen all of the block's transactions and
store them in their mempools. With [compact block relay][topic compact
block relay], these nodes just download a block header along with shortids,
and then reconstruct the block using transactions in their mempools.
The amount of data used to relay compact blocks is tiny compared to
the size of the block. Validating the transactions is
also much faster: the node has already verified (and cached)
signatures and scripts, calculated the timelock requirements, and
loaded relevant UTXOs from disk if necessary. The node can also
forward the block onto its other peers promptly, dramatically
increasing network-wide block propagation speed and thus reducing the
risk of stale blocks.

Mempools can also be used to build an independent fee estimator. The
market for block space is a fee-based auction, and keeping a mempool
allows users to have a better sense of what others are bidding and
what bids have been successful in the past.

However, there is no such thing as "the mempool"---each node may
receive different transactions. Submitting a transaction to one node
does not necessarily mean that it has made its way to miners. Some
users find this uncertainty frustrating, and wonder, "why don't we
just submit transactions directly to miners?"

Consider a Bitcoin network in which all transactions are sent directly
from users to miners. One could censor and surveil financial activity
by requiring the small number of entities to log the IP addresses
corresponding to each transaction, and refuse to accept any
transactions matching a particular pattern. This type of Bitcoin may
be more convenient at times, but would be missing a few of Bitcoin's
most valued properties.

Bitcoin's censorship-resistance and privacy come from its peer-to-peer
network. In order to relay a transaction, each node may connect to
some anonymous set of peers, each of which could be a miner or
somebody connected to a miner. This method helps obfuscate which node
a transaction originates from as well as which node may be responsible
for confirming it. Someone wishing to censor particular entities may
target miners, popular exchanges, or other centralized submission
services, but it would be difficult to block anything completely.

The
general availability of unconfirmed transactions also helps minimize
the entrance cost of becoming a block producer---someone who is
dissatisfied with the transactions being selected (or excluded)
may start mining immediately.
Treating each node as an equal candidate for transaction broadcast
avoids giving any miner privileged access to transactions and their
fees.

In summary, a mempool is an extremely useful cache that allows nodes
to distribute the costs of block download and validation over time,
and gives users access to better fee estimation. At a network level,
mempools support a distributed transaction and block relay network.
All of these benefits are most pronounced when everybody sees all
transactions before miners include them in blocks - just like any
cache, a mempool is most useful when it is "hot" and must be limited in size
to fit in memory.
Next week's section will explore the use of incentive compatibility as
a metric for keeping the most useful transactions in mempools.

