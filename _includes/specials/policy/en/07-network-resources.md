A previous post discussed protecting node resources, which may be unique to
each node and thus sometimes configurable. We also made our case for why it is best
to converge on one policy, but what should be part of that policy? This post
will discuss the concept of network-wide resources, critical to things like
scalability, upgradeability and accessibility of bootstrapping and maintaining
a full node.

As discussed in [previous posts][policy01], many of the Bitcoin network’s
ideological goals are embodied in its distributed structure. Bitcoin's peer-to-peer
nature allows the rules of the network to emerge from rough
consensus of the individual node operators’ choices and curbs attempts to
acquire undue influence in the network. Those rules are then enforced by each
node individually validating every transaction. A diverse and healthy node
population requires that the cost of operating a node is kept low. It is hard
to scale any project with a global audience, but doing so without sacrificing
decentralization is akin to fighting with one hand tied to your back. The
Bitcoin project attempts this balancing act by being fiercely protective of its
shared network resources: the UTXO set, the data footprint of the blockchain
and the computational effort required to process it, and upgrade hooks to
evolve the Bitcoin protocol.

There is no need to reiterate the entire blocksize war to realize that a limit
on blockchain growth is necessary to keep it affordable to run your own node.
However, blockchain growth is also dissuaded at the policy level by the
`minRelayTxFee` of 1 sat/vbyte, ensuring a minimum cost to express some of the
“[unbounded demand for highly-replicated perpetual storage][unbounded]”.

Originally, the network state was tracked by keeping all transactions that
still had unspent outputs. This much bigger portion of the blockchain got
reduced significantly with the [introduction of the UTXO set][ultraprune] as
the means of keeping track of funds. Since then, the UTXO set has been a
central data structure. Especially during IBD, but also generally, UTXO lookups
represent a major portion of all memory accesses of a node. Bitcoin Core
already uses a [manually optimized data structure for the UTXO cache][pooled
resource], but the size of the UTXO set determines how much of it cannot fit in
a node’s cache. A larger UTXO set means more cache misses which slows down
block validation, IBD, and transaction validation speed. The dust limit is an
example of a policy that restricts the creation of UTXOs, specifically curbing
UTXOs that might never get spent because their amount [falls short][topic uneconomical outputs] of the cost
for spending them. Even so, [“dust storms” with thousands of transactions
occurred as recently as 2020][lopp storms].

When it became popular to use bare multisig outputs to publish data onto the
blockchain, the definition of standard transactions was amended to permit a
single OP_RETURN output as an alternative. People realized that it would be
impossible to prevent users from publishing data on the blockchain, but at
least such data would not need to live in the UTXO set forever when published
in outputs that could never be spent. Bitcoin Core 0.13.0 introduced a start-up
option `-permitbaremultisig` that users may toggle to reject unconfirmed
transactions with bare multisig outputs.

While the consensus rules allow output scripts to be freeform, only a few
well-understood patterns are relayed by Bitcoin Core nodes. This makes it
easier to reason about many concerns in the network, including validation costs
and protocol upgrade mechanisms. For example, an input script that contains
op-codes, a P2SH input with more than 15 signatures, or a P2WSH input whose
witness stack has more than 100 items each would make a transaction
non-standard. (Check out this [policy overview][instagibbs policy zoo] for more
examples of policies and their motivations.)

Finally, the Bitcoin protocol is a living software project that will need to
keep evolving to address future challenges and user needs. To that end, there
are a number of upgrade hooks deliberately left consensus valid but unused,
such as the annex, taproot leaf versions, witness versions, OP_SUCCESS, and a
number of no-op opcodes. However, just like attacks are hindered by the lack of
central points of failure, network-wide software upgrades involve a coordinated
effort between tens of thousands of independent node operators. Nodes will not
relay transactions that make use of any reserved upgrade hooks until their
meaning has been defined. This discouragement is meant to dissuade applications
from independently creating conflicting standards, which would make it
impossible to adopt one application’s standard into consensus without
invalidating another’s. Also, when a consensus change does happen, nodes that
do not upgrade immediately—and thus do not know the new consensus rules—cannot
be “tricked” into accepting a now-invalid transaction into their mempools. The
proactive discouragement helps nodes be forward-compatible and enables the
network to safely upgrade consensus rules without requiring a completely
synchronized software update.

We can see that using policy to protect shared network resources aids in
protecting the network’s characteristics, and keeps paths for future protocol
development open. Meanwhile, we are seeing how the friction of growing the
network against a strictly limited blockweight has been driving adoption of
best practices, good technical design, and innovation: next week’s post
will explore mempool policy as an interface for second-layer protocols and
smart contract systems.

[policy01]: /en/newsletters/2023/05/17/#waiting-for-confirmation-1-why-do-we-have-a-mempool
[unbounded]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-December/011865.html
[lopp storms]: https://blog.lopp.net/history-bitcoin-transaction-dust-spam-storms/
[ultraprune]: https://github.com/bitcoin/bitcoin/pull/1677
[pooled resource]: /en/newsletters/2023/05/03/#bitcoin-core-25325
[instagibbs policy zoo]: https://gist.github.com/instagibbs/ee32be0126ec132213205b25b80fb3e8
