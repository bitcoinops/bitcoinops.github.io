<!--
  300 to 1000 words
  put title in main newsletter
  put links in this file
  for any subheads use h3 (i.e., ###)
  illustrations welcome (max width 800px)
  if uncertain about anything, just do what seems best and harding will edit
-->

Last week we mentioned that transactions pay fees for the used
blockspace rather than the transferred amount, and established that
miners optimize their transaction selection to maximize collected fees.
It follows that only those transactions get confirmed that reside in the
top of the mempool when a block is found. In this post, we will discuss
practical strategies to get the most for our fees. Let’s assume we have
a decent source of feerate estimates—we will talk more about feerate
estimation in next week’s article.

While constructing transactions, some parts of the transaction are more
flexible than others. Every transaction requires the header fields, the
recipient outputs are determined by the payments being made, and most
transactions require a change output. Both sender and receiver should
prefer blockspace-efficient output types to reduce the future cost of
spending their transaction outputs, but it’s during the [input
selection][topic coin selection] that there is the most room to change
the final composition and weight of the transaction. As transactions
compete by feerate [fee/weight], a lighter transaction requires a lower
fee to reach the same feerate.

Some wallets, such as the Bitcoin Core wallet, try to combine inputs
such that they avoid needing a change output altogether. Avoiding change
saves the weight of an output now, but also saves the future cost of
spending the change output later. Unfortunately, such input combinations
will only seldom be available unless the wallet sports a large UTXO pool
with a broad variety of amounts.

Modern output types are more blockspace-efficient than older output
types. E.g. spending a P2TR input incurs less than 2/5ths of a P2PKH
input’s weight. (Try it with our [transaction size
calculator][]!) For multisig wallets, the recently
finalized [MuSig2][topic musig] schema and FROST protocol chalk out huge
cost savings by permitting multisig functionality to be encoded in what
looks like a single-sig input. Especially in times when blockspace
demand goes through the roof, a wallet using modern output types by
itself translates to big cost savings.

{:.center}
![Overview of input and output weights](/img/posts/specials/input-output-weights.png)

Smart wallets change their selection strategy on the basis of the
feerate: at high feerates they use few inputs and modern input types to
achieve the lowest possible weight for the input set. Always selecting
the lightest input set would locally minimize the cost of the current
transaction, but also grind a wallet’s UTXO pool into small fragments.
This could set the user up for transactions with huge input sets at high
feerates later. Therefore, it is prescient for wallets to also select
more and heavier inputs at low feerates to opportunistically consolidate
funds into fewer modern outputs in anticipation of later blockspace
demand spikes.

High-volume wallets often batch multiple payments into a single
transaction to reduce the transaction weight per payment. Instead of
incurring the overhead of the header bytes and the change output for
each payment, they only incur the overhead cost once shared across all
payments. Even just batching a few payments quickly reduces cost per
payment.

![Savings from payment batching with
P2WPKH](/img/posts/payment-batching/p2wpkh-batching-cases-combined.png)

Still, even while many wallets estimate feerates erring on overpayment,
on a slow block or surge in transaction submissions, transactions
sometimes sit unconfirmed longer than planned. In those cases, either
the sender or receiver may want to reprioritize the transaction.

Users generally have two tools at their disposal to increase their
transaction’s priority, child pays for parent ([CPFP][topic cpfp]) and
replace by fee ([RBF][topic rbf]). In CPFP, a user spends their
transaction output to create a high-feerate child transaction. As
described in last week’s post, miners are incentivized to pick the
parent into the block in order to include the fee-rich child. CPFP is
available to any user that gets paid by the transaction, so either
receiver or sender (if they created a change output) can make use of it.

In RBF, the sender authors a higher-feerate replacement of the original
transaction. The replacement transaction must reuse at least one input
from the original transaction to ensure a conflict with the original and
that only one of the two transactions can be included in the blockchain.
Usually this replacement includes the payments from the original
transaction, but the sender could also redirect the funds in the
replacement transaction, or combine multiple transactions’ payments into
one upon replacement. As described in last week’s post, nodes evict the
original transaction in favor of the more incentive-compatible
replacement transaction.

While both demand for and production of blockspace are outside our
control, there are many techniques wallets can use to bid for blockspace
effectively. Wallets can save fees by creating lighter transactions
through eliminating the change output, spending native segwit outputs,
and defragmenting their UTXO pool during low feerate environments.
Wallets that support CPFP and RBF can also start with a conservative
feerate and then update the transaction’s priority using CPFP or RBF if
needed.

[transaction size calculator]: /en/tools/calc-size