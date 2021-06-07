{:.post-meta}
*by [CardCoins][]*

[Replace By Fee][topic rbf] (RBF, BIP125) and [batching][payment batching] are two important tools for any enterprises
directly interacting with Bitcoin's mempool. Fees go up, fees go down, but
the business must always fight for fee efficiency.

Each tool, while powerful, has its own complexities and nuances. For example,
batching customer withdrawals may save on fees for the enterprise, but will likely make
[child pays for parent][topic cpfp] (CPFP) uneconomical for a customer who wishes to speed up the transaction.
Similarly, RBF is useful for an enterprise who takes a fee-underbidding strategy
(their initial transaction broadcast starts at a low fee, and is slowly bid
upwards), but it exposes their customers to [potential confusion][rbf blog] as their
withdrawal transaction updates in their wallet. It would also be messy for the
customer to spend from this transaction while it remains unconfirmed, as the
enterprise will have to pay for this child spend when attempting to replace
the parent. Even worse, the enterprise may have a withdrawal [pinned][pinning] by another
service which received the customer's withdrawal.

When combining these two tools, a service provider unlocks new functionality but
is similarly exposed to novel forms of complexity. In the base case, combining
RBF and a single, static batch carries a simple combination of the complexities
that RBF and batching carry discretely. However, when you combine RBF and
"additive batching," emergent edge cases and dangerous failure scenarios present
themselves.

Additive RBF batching is a transaction construction protocol that leverages the
rules of BIP125 to allow a transactor to introduce new outputs (and confirmed
inputs) to a transaction in the mempool. This enables an enterprise to give
users the experience of an instantaneous withdrawal while still retaining much
of the fee savings from doing large batches of customer withdrawals at once. As
each customer requests a withdrawal, an output is added to the transaction in
the mempool. This transaction continues to be updated until it confirms or
reaches some other local optimum.

There are many strategies to this type of additive RBF batching. At [CardCoins][] we
took a safety-first approach to our implementation (with the help of [Matthew
Zipkin][]), the nuances of which we detailed in a blog post, [RBF
Batching at CardCoins: Diving into the Mempool's Dark Reorg Forest][cardcoins
rbf blog].

{% include references.md %}
[CardCoins]: https://www.cardcoins.co/
[payment batching]: /en/payment-batching/
[rbf blog]: /en/rbf-in-the-wild/#some-usability-examples
[pinning]: /en/topics/transaction-pinning/
[Matthew Zipkin]: https://twitter.com/MatthewZipkin
[cardcoins rbf blog]: FIXME:bitschmidty
