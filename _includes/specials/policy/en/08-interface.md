So far in this series, we have explored the [motivations][policy01]
and challenges associated with decentralized transaction relay,
leading to a [local][policy05] and [global][policy07] need for
transaction validation rules more restrictive than consensus. Since
transaction relay policy changes to Bitcoin Core can impact whether an
application’s transactions relay, they require socialization with the
wider Bitcoin community prior to consideration. Similarly,
applications and second layer protocols that utilize transaction relay
must be designed with policy rules in mind to avoid creating
transactions that are rejected.

Contracting protocols are even more intimately dependent on policies
related to prioritization because enforceability on-chain depends on
being able to get transactions confirmed quickly. In adversarial
environments, cheating counterparties may have an interest in delaying
a transaction’s confirmation, so we must also think about how quirks
in the transaction relay policy interface can be used against a user.

Lightning Network transactions adhere to the standardness rules
mentioned in earlier posts. For example, the peer-to-peer protocol specifies a
`dust_limit_satoshis` in its
`open_channel` message to specify a dust threshold.
Since a transaction containing an output with a
value lower than the dust threshold would not relay due to nodes’ dust
limits, those payments are considered “not enforceable on-chain” and
trimmed from commitment transactions.

Contracting protocols often use timelocked spending paths to give each
participant the opportunity to contest the state published on-chain.
If the affected user cannot get a transaction confirmed within that
frame of time, they may suffer loss of funds. This makes fees
extremely important as the primary mechanism for boosting confirmation
priority, but also more challenging. [Feerate estimation][policy04] is
complicated by the fact that transactions will be broadcast at some
unknown later time, nodes often operate as thin clients, and some
fee-bumping options are unavailable. For example, if an LN channel
participant goes offline, the other party may unilaterally broadcast a
presigned commitment transaction to settle the distribution of their
shared funds on-chain. Neither party can unilaterally spend the shared
UTXO, so when one party is offline, signing a [replacement][topic rbf]
transaction to fee-bump the commitment transaction is not possible.
Instead, LN commitment transactions may include [anchor outputs][topic
anchor outputs] for channel participants to attach a [fee-bumping child][topic cpfp]
at broadcast time.

However, this fee-bumping method also has limitations. As mentioned in
a [previous post][policy06], adding a CPFP transaction is not
effective if mempool minimum feerates rise higher than the commitment
transaction’s feerate, so they must still be signed with a slightly
overestimated feerate in case mempool minimum feerates rise in the
future. Additionally, the development of anchor outputs included a
number of considerations for the fact that one party may have an
interest in delaying confirmation. For example, a party (Alice) may broadcast
their own commitment transaction to the network prior to going
offline. If this commitment transaction’s feerate is too low for
immediate confirmation and if Alice's counterparty (Bob) doesn't receive her transaction,
he may be confused when his broadcasts of his version of the
commitment transaction aren't successfully relayed.
Each commitment transaction has two anchor outputs so that either party
may CPFP any of the commitment transactions, e.g. Bob may try to blindly
broadcast a CPFP fee bump of Alice's version of the commitment
transaction even if he isn't sure that she previously broadcast her
version. Each anchor output is assigned a small value
above the dust threshold and claimable by anyone after some time to
avoid bloating the UTXO set.

However, guaranteeing each party’s ability to CPFP a transaction is
more complicated than giving each party an anchor output. As mentioned
in a [previous post][policy05], Bitcoin Core limits the number and
total size of descendant transactions that can be attached to an
unconfirmed transaction as a DoS protection. Since each counterparty
has the ability to attach descendants to the shared transaction, one
could block the other’s CPFP transaction from relaying by exhausting
those limits.  The presence of these descendants consequently “pins”
the commitment transaction to its low-priority status in mempools.

To mitigate this potential attack, the LN anchor outputs proposal
locks all non-anchor outputs with a relative timelock, preventing
them from being spent while the transaction is unconfirmed, and
Bitcoin Core’s descendant limit policy was [modified to allow one
extra descendant][topic cpfp carve out] when this new descendant was
small and had no other ancestors. This combination of changes to both
protocols ensured that at least two participants in a shared transaction could make
feerate adjustments at broadcast time, while not significantly
increasing the transaction relay DoS attack surface.

CPFP prevention through domination of the descendant limit is an
example of a [pinning attack][topic transaction pinning].  Pinning attacks take advantage of
limitations in mempool policy to prevent incentive-compatible
transactions from entering mempools or getting confirmed. In this
case, mempool policy has made a tradeoff between
[DoS-resistance][policy05] and [incentive compatibility][policy02].
Some tradeoff must be made – a node should consider fee bumps but
cannot process infinitely many descendants. CPFP carve out refines
this tradeoff for a specific use case.

Beyond exhausting the descendant limit, there are other pinning
attacks that [altogether prevent use of RBF][full rbf pinning], make
RBF [prohibitively expensive][rbf ml], or leverage RBF to delay
confirmation of an ANYONECANPAY transaction. Pinning is only an issue
in scenarios where multiple parties collaborate in creating a
transaction or when there is otherwise room for an untrusted party to
interact with the transaction. Minimizing a transaction’s exposure to
untrusted parties is generally a good way to avoid pinning.

These points of friction highlight not just the importance of policy
as an interface for applications and protocols in the Bitcoin
ecosystem, but where it needs to improve. Next week’s post will
discuss policy proposals and open questions.

[full rbf pinning]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003033.html
[rbf ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019817.html
[n25038 notes]: https://bitcoincore.reviews/25038
[policy01]: /en/newsletters/2023/05/17/#waiting-for-confirmation-1-why-do-we-have-a-mempool
[policy02]: /en/newsletters/2023/05/24/#waiting-for-confirmation-2-incentives
[policy04]: /en/newsletters/2023/06/07/#waiting-for-confirmation-4-feerate-estimation
[policy05]: /en/newsletters/2023/06/14/#waiting-for-confirmation-5-policy-for-protection-of-node-resources
[policy06]: /en/newsletters/2023/06/21/#waiting-for-confirmation-6-policy-consistency
[policy07]: /en/newsletters/2023/06/28/#waiting-for-confirmation-7-network-resources
