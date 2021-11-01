Less than two weeks after the publication of this post, taproot is
expected to activate at block {{site.trb}}.  We know what we expect to
happen, and we also know about a few possible failure modes.

The best and most likely outcome is that everything goes fine.  Nothing
that happens should be visible to normal users.  Only those carefully
monitoring their nodes or trying to create taproot transactions should
notice anything.  At block 709,631 nearly all full nodes we're aware of
will be enforcing the same consensus rules.  One block later, nodes
running Bitcoin Core 0.21.1, 22.0, or related releases will be enforcing
the additional [taproot][topic taproot] rules not enforced by earlier
software releases.

This carries a risk that earlier and later versions of node software
will accept different blocks.  This happened during the activation of
the [BIP66][] soft fork in 2015, resulting in a six-block chain split and
several shorter chain splits.  Significant engineering effort has been
invested in preventing a repeat of that problem.  A similar problem
should only happen with taproot if a miner either deliberately mines a
taproot-invalid block or has disabled safety measures hardcoded into
Bitcoin Core and related node software.

Specifically, to create a chain split, a miner would need to create or
accept a transaction that spends from a taproot output (segwit v1
output) without following taproot's rules.  If a miner did that, they
would lose at least 6.25 BTC (about $400,000 USD at the time of writing) if
the economic consensus of Bitcoin node operators rejects the
taproot-invalid blocks.

We can't know for sure without creating an invalid block what those node
operators will do---nodes can be run entirely privately---but [proxy
measures][bitnodes] indicate that perhaps more than 50% of node
operators are running taproot-enforcing versions of Bitcoin Core.
That's probably more than sufficient to ensure any miner who creates a
taproot-invalid block will see it rejected by the network.

Although very unlikely, a temporary chain split is theoretically possible.  It should be possible to
monitor for it using services such as [ForkMonitor.info][] or using the
`getchaintips` RPC in Bitcoin Core.  If it does happen, lightweight
clients may receive false confirmations.  Although it is theoretically
possible to get 6 confirmations, like in the 2015 chain split, that would
imply miners had lost almost $2.5 million in value (compared to losses
of about $50,000 in 2015).  We can hope with values that large at stake,
miners will actually enforce the taproot rules they signaled
preparedness for six months ago.

In almost any failure circumstance we can imagine, a simple but
effective temporary response is to raise your confirmation limit.  If
you normally wait for 6 confirmations before accepting a payment, you
can quickly raise that 30 confirmations for a few hours until the
problem has been resolved or it becomes clear that an even higher
confirmation limit is required.

For users and services that are convinced the economic consensus of full
node operators will enforce taproot's rules, an even simpler solution is
to only get information about which transactions are confirmed from
Bitcoin Core 0.21.1 or later (or a compatible alternative
node implementation).

Optech expects taproot activation to proceed smoothly, but we do
encourage exchanges and anyone accepting large values around block
{{site.trb}} to either upgrade their node or be prepared to temporarily
raise their confirmation limit if there are any indications of problems.

[forkmonitor.info]: https://forkmonitor.info/nodes/btc
[bitnodes]: https://bitnodes.io/nodes/
