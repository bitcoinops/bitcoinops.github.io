In [last week's column][p4tr sig adaptors], we looked at [signature
adaptors][topic adaptor signatures] and how the activation of
[taproot][topic taproot] with [schnorr signatures][topic schnorr
signatures] will make it easier to use adaptors privately and
efficiently.  There are several ways signature adaptors can be used on
Bitcoin but one of the most immediately beneficial will be Point Time
Locked Contracts ([PTLCs][topic ptlc]), which can replace the
[venerable][htlc history] Hash Time Locked Contracts ([HTLCs][topic htlc])
used for years.  This will bring several advantages, but it also comes
with some challenges.  To understand both, we first start with a
simplified example of HTLCs in use; the example below could be offchain
LN payments, onchain coinswaps, or a hybrid onchain/offchain system like
Lightning Loop---it's this flexibility that makes HTLCs so widely used.

Alice wants to pay Carol by routing a payment through Bob, who neither
Alice nor Carol wants to trust.  Carol creates a random preimage and hashes
it with the SHA256 algorithm.  Carol gives the hash to Alice and keeps
the preimage secret.  Alice initiates a payment
to Bob which he can claim with a signature for his public key plus the
preimage; alternatively, Alice can receive a refund after 10 blocks by
spending the transaction back to herself with a signature for her public
key.  Here's that [policy][htlc1 minsc] described in the Minsc language:

```hack
(pk($bob) && sha256($preimage)) || (pk($alice) && older(10))
```

Bob can now initiate a payment for the same amount (perhaps minus fees) to
Carol with basically the same script, only with the parties
[updated][htlc2 minsc] and a lower refund time out.

```hack
(pk($carol) && sha256($preimage)) || (pk($bob) && older(5))
```

Now Carol can claim her payment from Bob within five blocks by using the preimage, which
reveals the preimage to Bob and allows him to claim the payment from
Alice, also within five blocks.

### Privacy problems with HTLCs

If the scripts above are published onchain, the reuse of the same hash
and preimage makes it immediately clear that A paid C via
B.  This can be a significant problem for same-chain and cross-chain
coinswaps.  Less obviously, this is also a problem for offchain routing
protocols like LN.  If we imagine a longer routing path where one person
controls multiple hops along the path, they can see the reuse of
the same hash and preimage to determine that some nodes are routing
nodes, increasing the probability that the remaining nodes are either
the spender or the receiver.   This is one part of the *linkability
problem* that may be LN's greatest current privacy weakness.

![Illustration of HTLC linkability problem](/img/posts/2021-07-ln-linkability1.dot.png)

Although [multipath payments][topic multipath payments] partially
mitigate other aspects of LN's linkability problem, e.g. payment amount
linkability, it may make worse the hash linkability problem by giving
surveillance routing nodes more opportunity to correlate hashes.

An additional problem with HTLCs today is that any scripts which need to
go onchain are obviously distinct from normal spender scripts.  This
makes it easier for surveillants to identify usage
patterns and, perhaps, make effective guesses about information specific
to individual users.

### The PTLC solution

In the previous Minsc-style scripts, we had a function that would only
return true if it was passed a particular value chosen in advance (the
preimage).  A [signature adaptor][topic adaptor signatures] is similar
in that it can only be transformed into a valid signature if a function is passed a
revealed value (the *scalar*).  If we ignore [multisignatures][topic
multisignature] for the moment, this allows us to transform the HTLC
scripts from earlier into the following PTLCs:

```hack
(pk($bob) && pk($alice_adaptor)) || (pk($alice) && older(10))
```

```hack
(pk($carol) && pk($bob_adaptor)) || (pk($bob) && older(5))
```

In short, Carol gives Alice the EC *point* for her hidden scalar, Alice
uses that with a public key she chooses and creates a signature adaptor
that she gives to Bob; Bob can use the same point with a public key
he chooses and creates an adaptor he gives to Carol.  Carol reveals the
scalar by transforming Bob's adaptor into a valid signature, claiming
Bob's coins.  Bob recovers the scalar from the valid signature, allowing
him to transform Alice's adaptor into its own valid signature, claiming
her coins.

This solves the linkability problem against onchain surveillance because
all that anyone sees when they look at the block chain are a bunch of valid
signatures for distinct public keys.  Third parties can't know that
adaptors were used, much less what scalar those adaptors were based upon.

However, the procedure above doesn't prevent surveillance nodes who participate
in the routing from linking together the payments.  If all the payments
are based on the same scalar, then all the payments are just as linked
as if they used a hashlock and preimage.  This can be fixed by each
routing node choosing their own scalar and then removing its
corresponding point as the payment passes through its node.  Let's
revise our example:

As before, Carol gives Alice the point for her scalar, but this time
Alice also requests a point from Bob.  Alice constructs the adaptor she
gives Bob using the aggregation of both Carol's point and Bob's point.
Bob knows his point, so he's able to subtract that out from the adaptor
he receives from Alice.  Using the resultant point (which Bob doesn't
know is now just the point Alice originally received from Carol), Bob
constructs the adaptor he gives to Carol.  Carol knows the scalar for
that final point and so converts Bob's adaptor into a valid signature.
As before, Bob recovers Carol's scalar from her signature and uses it
and his own scalar to convert Alice's adaptor into a valid signature.

In the two hops in this path, Alice→Bob and Bob→Carol, two different
EC points and scalars were used, eliminating linkability.  We can extend
this to the longer path we examined when considering HTLCs and see how
this improves privacy:

![Illustration of PTLC lack of linkability problem](/img/posts/2021-07-ln-linkability2.dot.png)

As mentioned last week, schnorr signatures make it easy to compose
adaptor signatures with multisignatures.  For the case of generic PTLCs, this allows us to reduce our
onchain scripts to:

```hack
pk($bob_with_alice_adaptor) || (pk($alice) && older(10))
```

```hack
pk($carol_with_bob_adaptor) || (pk($bob)   && older(5) )
```

With taproot, the left branch can become a keypath and the right branch
can become a tapleaf.  If the payment routes successfully, Bob and Carol
can settle their parts onchain without further cooperation
from their counterparties, making this routed payment indistinguishable
from single-sig payments, normal multisignature payments, and
cooperatively resolved contracts.  It also minimizes the use of block
space.  If one of the refund conditions needs to be executed,
that's still fairly efficient and fairly private---`pk(x) && older(n)`
is indistinguishable from [degrading multisig][], [enforced hodling][],
and a variety of other possible scripts.

In next week's column, a guest post from one of our favorite LN
developers will discuss some of the changes necessary for LN to adopt
keypath spends, multisignatures, PTLCs, and other features enabled by
taproot.

[p4tr sig adaptors]: /en/preparing-for-taproot/#signature-adaptors
[htlc history]: /en/topics/htlc/#history
[htlc1 minsc]: https://min.sc/#c=%2F%2F%20Traditional%20preimage-based%20HTLC%0A%24alice%20%3D%20A%3B%0A%24bob%20%3D%20B%3B%0A%24carol%20%3D%20C%3B%0A%24preimage%20%3D%20H%3B%0A%0A%28pk%28%24bob%29%20%26%26%20sha256%28%24preimage%29%29%20%7C%7C%20%28pk%28%24alice%29%20%26%26%20older%2810%29%29
[htlc2 minsc]: https://min.sc/#c=%2F%2F%20Traditional%20preimage-based%20HTLC%0A%24alice%20%3D%20A%3B%0A%24bob%20%3D%20B%3B%0A%24carol%20%3D%20C%3B%0A%24preimage%20%3D%20H%3B%0A%0A%28pk%28%24carol%29%20%26%26%20sha256%28%24preimage%29%29%20%7C%7C%20%28pk%28%24bob%29%20%26%26%20older%285%29%29
[degrading multisig]: https://github.com/bitcoinops/taproot-workshop/blob/master/3.1-degrading-multisig-case-study.ipynb
[enforced hodling]: https://bitcoin.stackexchange.com/questions/69809/op-checklocktimeverify-op-hodl-script
