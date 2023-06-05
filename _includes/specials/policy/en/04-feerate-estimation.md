Last week, we explored techniques for minimizing the fees paid on a
transaction given a feerate. But what should that feerate be? Ideally,
as low as possible to save money, but high enough to secure a spot in
a block suitable for the user's time preference.

The goal of _fee(rate) estimation_ is to translate a target timeframe for
confirmation to a minimal feerate the transaction should pay.

One complication of fee estimation is the irregularity of block space
production. Let's say a user needs to pay a merchant within one hour
to receive their goods. The user may expect a block to be mined every
10 minutes, and thus aim for a spot within the next 6 blocks. However,
it's entirely possible for one block to take 45 minutes to be found.
Fee estimators must translate between a user’s desired urgency or
timeframe (something like “I want this to confirm by the end of the
work day”) and a supply of block space (a number of blocks). Many fee
estimators address this challenge by denominating confirmation targets
in the number of blocks in addition to time.

With no information about transactions prior to their confirmation,
one can build a naive fee estimator that uses historical data about
what transaction feerates tend to land in blocks. As this estimator is
blind to the transactions awaiting confirmation in mempools, it would
become very inaccurate during unexpected fluctuations in block space demand
and the occasional long block interval. Its other weakness is its
reliance on information controlled wholly by miners, who would be able
to drive feerates up by including fake high-feerate transactions in
their blocks.

Fortunately, the market for block space is not a blind auction. We
mentioned in our [first post][policy01] that keeping a mempool and participating
in the peer-to-peer transaction relay network allows a node to see
what users are bidding. The Bitcoin Core fee estimator also uses
historical data to calculate the likelihood of a transaction at
feerate `f` confirming within `n` blocks, but specifically tracks the
height at which the node first sees a transaction and when it
confirms.  This method works around activity that happens outside the
public fee market by ignoring it. If miners include artificially
high-feerate transactions in their own blocks, this fee estimator
isn't skewed because it only uses data from transactions that were
publicly relayed prior to confirmation.

We also have insights into the way transactions are selected for blocks.
In a [previous post][policy02], we mentioned that nodes emulate miner
policies in order to keep incentive-compatible transactions in their
mempools. Expanding on this idea, instead of looking only at past
data, we could build a fee estimator that simulates what a miner would
do. To find out what feerate a transaction would need to confirm in
the next `n` blocks, the fee estimator could use the block assembly
algorithm to project the next  `n` block templates from its mempool
and calculate the feerate that would beat the last transaction(s) that
make it into block `n`.

Clearly, the efficacy of this fee estimator's approach depends
on the similarity between the contents of its mempool and the
miners', which can never be guaranteed. It is also blind to
transactions a miner might include due to exterior motivations, e.g.
transactions that belong to the miner or paid out-of-band fees to be
confirmed. The projection must also account for additional transaction
broadcasts between now and when the projected blocks are found. It can
do so by decreasing the size of its projected blocks to account for
other transactions – but by how much?

This question once again highlights the utility of historical data. An
intelligent model may be able to incorporate patterns of activity and
account for external events that influence feerates such as typical
business hours, a company's scheduled UTXO consolidation, and activity
in response to changes in Bitcoin's trading price. The problem of
forecasting block space demand remains ripe for exploration, and is
likely to always have room for innovation.

Fee estimation is a multi-faceted and difficult problem. Bad fee
estimation can waste funds by overpaying fees, add friction to the use
of Bitcoin for payments, and cause L2 users to lose money by missing a
window within which a timelocked UTXO had an alternate spending path.
Good fee estimation allows users to clearly and precisely communicate
transaction urgency to miners, and [CPFP][topic cpfp] and [RBF][topic rbf] allow users to update
their bids if initial estimates undershoot. Incentive-compatible
mempool policies, combined with well-designed fee estimation tools and [wallets][policy03],
enable users to participate in an efficient, public auction for block
space.

Fee estimators typically never return anything below 1sat/vB,
regardless of how long the time horizon is or how few transactions are
pending confirmation. Many consider 1sat/vB as the de facto floor
feerate in the Bitcoin network, due to the fact that most nodes on the
network (including miners) [never accept][topic default minimum transaction relay feerates] anything below that feerate,
regardless of how empty their mempools are. Next week's post will
explore this node policy and another motivation for utilizing feerate
in transaction relay: protection from resource exhaustion.

[policy01]: /en/newsletters/2023/05/17/#waiting-for-confirmation-1-why-do-we-have-a-mempool
[policy02]: /en/newsletters/2023/05/24/#waiting-for-confirmation-2-incentives
[policy03]: /en/newsletters/2023/05/31/#waiting-for-confirmation-3-bidding-for-block-space
