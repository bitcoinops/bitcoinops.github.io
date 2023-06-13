We [started off][policy01] our series by stating that much of Bitcoin's privacy and
censorship resistance stems from the decentralized nature of the
network. The practice of users running their own nodes reduces central points of
failure, surveillance, and censorship. It follows that one
primary design goal for Bitcoin node software is high accessibility of
running a node. Requiring each Bitcoin user to purchase expensive
hardware, use a specific operating system, or spend hundreds of
dollars per month in operational costs would very likely reduce the
number of nodes on the network.

Additionally, a node
on the Bitcoin network is a computer with internet connections to
unknown entities that may launch a Denial of Service (DoS) attack by
crafting messages that cause the node to run out of memory and crash,
or spend its computational resources and bandwidth on meaningless data
instead of accepting new blocks. As these entities are anonymous by
design, nodes cannot predetermine whether a peer will be honest or
malicious before connecting, and cannot effectively ban them even after an
attack is observed. Thus, it is not just an ideal to implement policies
that protect against DoS and limit the cost of
running a full node, but an imperative.

General DoS protections are built into node implementations to
prevent resource exhaustion. For example, if a Bitcoin Core node
receives many messages from a single peer, it only processes the first
one and adds the rest to a work queue to be processed after other
peers' messages. A node also typically first downloads a block header
and verifies its Proof of Work (PoW) prior to downloading and validating the
rest of the block. Thus, any attacker wishing to exhaust this node's resources
through block relay must first spend a
disproportionately high amount of their own resources computing a
valid PoW. The asymmetry between the huge cost for PoW
calculation and the trivial cost of verification provides a natural way to build DoS resistance into
block relay.
This property does
not extend to _unconfirmed_ transaction relay.

General DoS protections don't provide enough attack resistance to allow a node’s consensus
engine to be exposed to input from the peer-to-peer network. An attacker attempting
to [craft a maximally computationally-intensive][max cpu tx], consensus-valid
transaction may send one like the 1MB
[“megatransaction”][megatx mempool space] in block #364292,
which took an abnormally long time to validate due
to [signature verification and quadratic sighashing][rusty megatx]. An
attacker may also make all but the last signature valid, causing the
node to spend minutes on their transaction, only to find that it is
garbage. During that time, the node would delay processing a new
block. One can imagine this type of attack being
targeted at competing miners to gain a “head start” on the next block.

In an effort to avoid working on very computationally expensive transactions,
Bitcoin Core nodes impose a maximum standard size and a
maximum number of signature operations (or "sigops") on each
transaction, more restrictive than the block consensus limit. Bitcoin Core nodes also
enforce limits on both ancestor and descendant package sizes, making
block template production and eviction algorithms more effective and
[restricting the computational
complexity][se descendant limits] of mempool insertion and deletion
which require updating a transaction’s ancestor and descendant sets.
While
this means some legitimate transactions may not be accepted or
relayed, those transactions are expected to be rare.

These rules are
examples of _transaction relay policy_, a set of validation rules in
addition to consensus which nodes apply to unconfirmed transactions.

By default, Bitcoin Core nodes do not accept transactions below the 1sat/vB minimum relay feerate
("minrelaytxfee"), do not verify any signatures before checking this requirement, and do not forward
transactions unless they are accepted to their mempools.
In a sense, this feerate rule sets a minimum "price" for network validation and relay.
A non-mining node doesn’t ever receive fees – they are
only paid to the miner who confirms the transaction.
However, fees represent a cost to the attacker. Somebody who "wastes" network resources by sending an
extremely high amount of transactions
eventually runs out of money to pay the fees.

The [Replace by Fee][topic rbf] policy [implemented by Bitcoin Core][bitcoin core
rbf docs] requires that the replacement transaction pay a higher
feerate than each transaction it directly conflicts with, but also
requires that it pay a higher total fee than all of the transactions it displaces. The additional fees
divided by the replacement transaction's
virtual size must be at least 1sat/vB.
In other words, regardless of the feerates of the original
and replacement transactions, the new transaction must pay "new" fees
to cover the cost of its own bandwidth at 1sat/vB.
This fee policy is not
primarily concerned with incentive compatibility. Rather, this incurs
a minimum cost for repeated transaction replacements to curb
bandwidth-wasting attacks, e.g. one that adds just 1 additional
satoshi to each replacement.

A node that fully validates blocks and transactions requires resources
including memory, computational resources, and network bandwidth. We
must keep resource requirements low in order to
make running a node accessible and to defend the node
against exploitation. General DoS protections are not enough, so
nodes apply transaction relay policies in addition to consensus rules
when validating unconfirmed transactions. However, as policy is not
consensus, two nodes may have different policies but still agree on
the current chain state. Next week’s post will discuss policy
as an individual choice.

[policy01]: /en/newsletters/2023/05/17/#waiting-for-confirmation-1-why-do-we-have-a-mempool
[max cpu tx]: https://bitcointalk.org/?topic=140078
[megatx mempool space]: https://mempool.space/tx/bb41a757f405890fb0f5856228e23b715702d714d59bf2b1feb70d8b2b4e3e08
[rusty megatx]: https://rusty.ozlabs.org/?p=522
[bitcoin core rbf docs]: https://github.com/bitcoin/bitcoin/blob/v25.0/doc/policy/mempool-replacements.md
[pr 6722]: https://github.com/bitcoin/bitcoin/pull/6722
[se descendant limits]: https://bitcoin.stackexchange.com/questions/118160/whats-the-governing-motivation-for-the-descendent-size-limit
