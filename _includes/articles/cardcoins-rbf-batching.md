{:.post-meta}
*by [Justin D][justin], FIXME:bitschmidty at [CardCoins][]*

RBF (BIP-125) and batching are two important tools for any enterprise which
directly interacts with Bitcoin's mempool. Fees go up, fees go down, but always
must the business fight for fee efficiency.

Each tool, while powerful, has its own complexities and nuances. For example,
batching customer withdrawals may save the enterprise fees, but will likely make
CPFP uneconomical for a customer who wishes to speed up the transaction.
Similarly, RBF is useful for an enterprise who takes a fee-underbidding strategy
(their initial transaction broadcast starts at a low fee, and is slowly bid
upwards), but it exposes their customers to potential confusion as their
withdrawal transaction updates in their wallet. It also would be messy for the
customer to spend from this transaction while it remains unconfirmed, as the
enterprise will have to account for this child spend when attempting to replace
the parent. Even worse, the enterprise may have a withdrawal pinned by another
service that the customer withdrew their funds directly to.

When combining these two tools, a service provider unlocks new functionality but
is similarly exposed to novel forms of complexity. In the base case, combining
RBF and a single, static batch carries a simple combination of the complexities
that RBF and batching carry discretely. However, when you combine RBF and
"additive batching," emergent edge cases and dangerous failure scenarios present
themselves.

Additive RBF batching is a transaction construction protocol that leverages the
rules of BIP-125 to allow a transactor to introduce new outputs (and confirmed
inputs) to a transaction in the mempool. This enables an enterprise to give
users the experience of an instantaneous withdrawal while still retaining much
of the fee savings from doing large batches of customer withdrawals at once. As
each customer requests a withdrawal, an output is added to the transaction in
the mempool. This transaction continues to be updated until it confirms or
reaches some other local optimum.

There are many strategies to this type of additive RBF batching. At CardCoins we
took a safety-first approach to our implementation (with the help of Matthew
Zipkin), the nuances of which we detailed in a more detailed blog post, RBF
Batching at CardCoins: Diving into the Mempool's Dark Reorg Forest.

{% include references.md %}
[justin]: FIXME:bitschmidty
[CardCoins]: https://www.cardcoins.co/
