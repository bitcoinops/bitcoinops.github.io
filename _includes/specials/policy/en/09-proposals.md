[Last week’s post][policy08] described [anchor outputs][topic anchor outputs] and [CPFP carve
out][topic cpfp carve out], ensuring either channel party can fee-bump their shared
commitment transactions without requiring collaboration. This approach
still contains a few drawbacks: channel funds are tied up to create
anchor outputs, commitment transaction feerates typically overpay
to ensure they meet mempool minimum feerates, and CPFP carve out only
allows one extra descendant. Anchor outputs cannot ensure the same
ability to fee-bump for transactions shared between more than two
parties, such as [coinjoins][topic coinjoin] or multi-party contracting protocols. This
post explores current efforts to address these and other limitations.

[Package relay][topic package relay] includes P2P protocol and policy
changes to enable the transport and validation of groups of
transactions. It would allow a commitment transaction to be fee-bumped
by a child even if the commitment transaction does not meet a mempool’s
minimum feerate.  Additionally, _Package RBF_ would allow
the fee-bumping child to pay for [replacing][topic rbf] transactions its parent
conflicts with. Package relay is designed to remove a general limitation
at the base protocol
layer. However, due to its utility in fee-bumping of shared
transactions, it has also spawned a number of efforts to eliminate [pinning][topic transaction pinning] for
specific use cases. For example, Package RBF would allow commitment
transactions to replace each other when broadcast with their
respective fee-bumping children, removing the need for multiple anchor
outputs on each commitment transaction.

A caveat is that existing RBF rules require the replacement
transaction to pay a higher absolute fee than the aggregate fees paid
by all to-be-replaced transactions. This rule helps prevent DoS
through repeated replacements, but allows a malicious user to increase
the cost to replace their transaction by attaching a child that is
high fee but low feerate. This hinders the transaction from being
mined by unfairly preventing its replacement by a high-feerate
package, and is often referred to as “Rule 3 pinning.”

Developers have also proposed entirely different ways of adding fees
to presigned transactions. For example, signing inputs of the
transaction using `SIGHASH_ANYONECANPAY | SIGHASH_ALL` could allow the
transaction broadcaster to provide fees by appending additional inputs
to the transaction without changing the outputs. However, as RBF does
not have any rule requiring the replacement transaction to have a
higher “mining score” (i.e. would be selected for a block faster), an
attacker could pin these types of transactions by creating
replacements encumbered by low-feerate ancestors. What complicates
the accurate assessment of the mining score of transactions and
transaction packages is that the existing ancestor and descendant
limits are insufficient to bound the computational complexity of this
calculation. Any connected transactions can influence the
order in which transactions get picked into a block. A fully-connected
component, called a _cluster_, can be of any size given current
ancestor and descendant limits.

A long term solution to address some mempool deficiencies and RBF
pinning attacks is to [restructure the mempool data structure to track
clusters][mempool clustering] instead of just ancestor and descendant
sets. These clusters would be limited in size. A cluster limit would
restrict the way users can spend unconfirmed UTXOs, but make it
feasible to quickly linearize the entire mempool using the ancestor
score-based mining algorithm, build block templates extremely quickly,
and add a requirement that replacement transactions have a
higher mining score than the to-be-replaced transaction(s).

Even so, it’s possible that no single set of policies can meet the
wide range of needs and expectations for transaction relay. For
example, while recipients of a batched payment transaction benefit
from being able to spend their unconfirmed outputs,
a relaxed descendant limit leaves room for pinning package RBF of a shared
transaction through absolute fees. A proposal for [v3 transaction
relay policy][topic v3 transaction relay] was developed to allow
contracting protocols to opt in to a more restrictive set of package
limits. V3 transactions would only permit packages of size two (one
parent and one child) and limit the weight of the child. These limits
would mitigate RBF pinning through absolute fees, and offer some of
the benefits of cluster mempool without requiring a mempool
restructure.

[Ephemeral Anchors][topic ephemeral anchors] builds upon the
properties of v3 transactions and package relay to improve anchor
outputs further. It exempts anchor outputs
belonging to a zero-fee v3 transaction from the [dust limit][topic
uneconomical outputs], provided the anchor output is
spent by a fee-bumping child.  Since the zero-fee transaction must be
fee-bumped by exactly one child (otherwise a miner would not be
incentivized to include it in a block), this anchor output is
“ephemeral” and would not become a part of the UTXO set. The ephemeral
anchor proposal implicitly prevents non-anchor outputs from being
spent while unconfirmed without `1 OP_CSV` timelocks, since the only
allowed child must spend the anchor output.
It would also make [LN symmetry][topic eltoo] feasible with [CPFP][topic cpfp] as the fee
provisioning mechanism for channel closing transactions. It also makes
this mechanism available for transactions shared between more than two
participants. Developers have been using [bitcoin-inquisition][bitcoin inquisition repo] to deploy
Ephemeral Anchors and proposed soft forks to build and test these
multi-layer changes on a [signet][topic signet].

The pinning problems highlighted in this post, among others, spawned a
[wealth of discussions and proposals to improve RBF
policy][2022 rbf] last year across mailing lists, pull requests,
social media, and in-person meetings. Developers proposed and
implemented solutions ranging from small amendments to a complete
revamp. The `-mempoolfullrbf` option, intended to address pinning
concerns and a discrepancy in BIP125 implementations, illuminated the
difficulty and importance of collaboration in transaction relay
policy. While a genuine effort had been made to engage the community
using typical means, including starting the bitcoin-dev mailing list
conversation a year in advance, it was clear that the existing
communication and decision-making methods had not produced the
intended result and needed refinement.

Decentralized decision-making is a challenging process, but necessary
to support the diverse ecosystem of protocols and applications that
use Bitcoin’s transaction relay network. Next week will be our final
post in this series, in which we hope to encourage our readers to
participate in and improve upon this process.

[mempool clustering]: https://github.com/bitcoin/bitcoin/issues/27677
[policy08]: /en/newsletters/2023/07/05/#waiting-for-confirmation-8-policy-as-an-interface
[2022 rbf]: /en/newsletters/2022/12/21/#rbf
