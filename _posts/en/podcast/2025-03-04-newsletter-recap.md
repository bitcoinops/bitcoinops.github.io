---
title: 'Bitcoin Optech Newsletter #343 Recap Podcast'
permalink: /en/podcast/2025/03/04/
reference: /en/newsletters/2025/02/28/
name: 2025-03-04-recap
slug: 2025-03-04-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt discuss [Newsletter #343]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-2-4/395955759-44100-2-b822dc1b09fa.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #343 Recap.
Today, Dave and I are going to be talking about ignoring unsolicited
transactions on the Bitcoin P2P Network, eight questions from the Bitcoin Stack
Exchange, and our weekly Releases and Notable code segments with all LN releases
and PRs this week.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink.  Dave?

**Dave Harding**: I'm Dave Harding.  I'm co-author of the Optech Newsletter and
co-author of the third edition of Mastering Bitcoin.

_Ignoring unsolicited transactions_

**Mike Schmidt**: We have one news item this week titled, "Ignoring unsolicited
transactions".  And this was motivated by a Bitcoin mailing list post from
Antoine Riard.  He posted two draft BIPs for a node to be able to signal that it
would no longer accept unsolicited transactions.  Unsolicited transactions are
tx messages in the P2P protocol that have not been requested by the node itself
using an inv message.  So, there's a couple of different things going on here.
Riard has a new Bitcoin transaction relay protocol proposal in the form of a
BIP, and then, building on top of that BIP, is a second BIP for the unrequested
transaction processing mechanism itself.  And it looks like he initially had
Bitcoin Core PRs open for each of these, but both were eventually closed in
favor of documenting the changes in BIPs and implementing the changes in a
potentially new Rust-based libbitcoinkernel-based node.  I'll pause there.
Maybe, Dave, what's the problem?  I mean, I need transactions.  Why wouldn't I
want my peer to just send me a transaction if they have it?

**Dave Harding**: Yeah, so the regular flow for both blocks and transactions in
Bitcoin Core, the way we expect it to work and the way it has worked since 2009,
is that when I have, say, a block that I want to send to Mike, I send Mike an
inv (inventory) message with a hash of the block.  And then, Mike looks to see
if he already has that block from somebody else.  Because if he already received
it from somebody else, he doesn't want it from me.  And if he needs it, he sends
me a getdata message with again the hash of the block.  And these hashes are of
course very small compared to the size of a block.  And then, I send it back
with a block message.  And this is a bandwidth-saving mechanism because Mike's
going to have peers, a lot of peers, and they're all going to be trying to send
him new blocks and new transactions, and a lot of them are going to be duplicate
requests.

However, it's always been the case in Bitcoin, ever since 2009, that the Bitcoin
implementation has accepted both block messages and transaction messages that
you didn't request.  We don't know if Satoshi intentionally allowed this or if
he just didn't write the code to say, "No, only accept block messages and
transaction messages that I've previously requested".  It's just simpler code to
just accept it if somebody sends it.  And it's long been the case that miners
who discovered new blocks would actually send unsolicited block messages.  They
discover a new block, they would know, because they discovered the new block,
that nobody else has that block.  They could send you a block message and skip a
round-trip communication step here.

Now, for almost 10 years now, we've had compact blocks, which are actually an
even more efficient way of doing this.  And I believe, but I'm not absolutely
sure, that Bitcoin Core no longer accepts unsolicited block messages.  Because
it is kind of spam if you're not the miner who discovered the block.  If
somebody else discovered the block and sent it to me, I should not send an
unsolicited block message, because that's a very high probability that's going
to waste a lot of bandwidth, because blocks are big.  We had the same situation
with transaction messages.  Now transactions aren't as big as blocks but they're
certainly bigger than a 32-byte hash.  And we don't want people sending
unsolicited transaction messages.  And there are several reasons people might do
that, send an unsolicited transaction message.  Now, there's a good reason.
Again, if you're the person who created the transaction, you know nobody else
has it.  So, you can send an unsolicited transaction message that is guaranteed
not to waste any bandwidth.  It's a little bit faster, it's a little bit more
efficient in bandwidth because you're avoiding that round trip, the overhead of
that round trip.  And there is software that has done this for a long time.  The
main one is bitcoinj.

Bitcoinj is a library written in Java that's been around since 2011, I think.
It's widely used and has been even more widely used in the past.  And it's long
had in it a code that just sends unsolicited transaction messages.  And part of
the idea there is, bitcoinj is software for a lightweight client.  And a
lightweight client can't really hide from the full node peers that it connects
to that it is a lightweight client.  A lightweight client does relay
transactions for other peers.  So, it's not really a privacy loss for it to send
unsolicited transaction messages to the nodes that it connects to.  That last
point might be a bit debatable today, I don't know, but this is existing
software that's out there.

However, there's also bad reasons people are sending unsolicited transaction
messages today.  If you're a spy node, for example, maybe you're run by the
company Chainalysis, you might run hundreds of nodes across the network.  You
might be one of the first nodes to receive a new transaction.  You can take
that, send it to all your other nodes and propagate it across the network really
fast, faster than the decentralized network can do it, by sending unsolicited
transaction messages to other peers because again, you're avoiding that round
trip, you can do it faster than everybody else.  And this will allow you to kind
of measure how that transaction propagates across the network and help you just
figure out how nodes on the network are connected to their peers.  It'll allow
you to map the topology of the network just by doing something that the
network's going to do eventually on its own anyway.  And with that knowledge,
you might be able to disrupt the network.  You might be able to map how
transactions naturally propagate, and then use that information to track back to
which node might have originated a transaction, which again, that's a privacy
loss.  Did you have a question?

**Mike Schmidt**: Yeah, maybe help connect the dots for me.  My understanding is
that the spy nodes are mostly passive in watching the flows of these
transactions.  So, tie that in with the fact that if they're mass connecting and
then unsolicited transaction propagating to all of their peers, how is that
helping the spying?  Would that be the same entity, the spying that's blasting
to everybody?

**Dave Harding**: Yeah.  So, they don't have a connection to everybody.  I send
in that transaction, they can see it went into Alice's node, but it came out of
Carol's node.  Those nodes are probably connected to somebody else, let's call
them Bob.  And so, we know there's a connection in there that they don't have
and they can maybe look for that connection.  I'm a little unsure about this
myself.  If you look into the PR that we linked in the newsletter item, there's
some discussion about this.  But it does appear that there is software out there
that is relaying transactions using unsolicited transaction messages, that that
is not the creator of the transaction.  On top of that, another bad reason you
can do this is, we talked about some vulnerabilities in a previous newsletter,
#332 I guess, where the attacker could fill up the victim's basically queue of
transactions, which is a global queue, and prevent that node from receiving
transactions from its peers, which could be used to censor that node from
learning about unconfirmed transactions, which can have negative effects if that
node is connected to like an LN or another contract protocol.

So, there are definite downsides in the modern era of a node accepting
unsolicited transactions.  So, Antoine has previously proposed several years ago
that we stop doing that.  However, because we know there is widely-used software
out there, like bitcoinj, that uses this mechanism, Antoine has been looking for
an upgrade mechanism, some way to say to clients, "Hey, I'm not going to accept
unsolicited transactions anymore", and that's why this proposal has been split
into two parts.  He has an upgrade mechanism, a way for nodes to say to other
nodes, but also client software, "These are the capabilities I support", and the
base protocol is going to be the same as what Bitcoin Core has done since 2009,
and they accept unsolicited transaction messages, unsolicited block messages.
The next v1 of the protocol or v2, however it numbers it, is going to say, "No",
and no longer accept unsolicited messages.

Speaking for myself, I don't know that we need this upgrade mechanism for this
particular proposal.  We do need to communicate to legacy clients using old
versions of bitcoinj that this will no longer be supported at some point in the
future.  And this is why we wrote about it back in Newsletter #136, when this
idea was kind of being kicked around literally, and that's why we're writing
about it today.  We want to tell developers of lightweight clients, "If you use
bitcoinj, if you use another library of your own code that sends unsolicited
transaction messages, this will not be supported at some point in the future.
These messages will be ignored, and if you use them exclusively, your
transactions will not propagate".  I think that's it.

Something like this, because it takes a long time for people to upgrade to new
nodes, like even if in the next version of Bitcoin Core, we stopped accepting
unsolicited transaction messages, it probably wouldn't have a negative effect on
the network for years to come.  Because if you're a lightweight client and
you're using unsolicited transaction messages, you only need one message to get
to one node, and then that node is going to use the regular inv getdata tx
message protocol for all of its peers, so your transaction will still propagate.
You just need one peer who runs old software for your transaction to propagate.
It'll be a little bit slower, but it'll still work.  And so, this is why I don't
think we need an upgrade mechanism because we have an upgrade mechanism.  It's
just people upgrading slowly over time and your lightweight client software will
see the amount of time it takes for a transaction to appear on mempool.space, or
whatever people are using to monitor their transactions, will take a little bit
longer and a little bit longer and a little bit longer, and you might have to
shut down your wallet and then restart it and get a new set of peer connections.
It'll slowly degrade over time, and that is your upgrade mechanism.  I'm
rambling now.  I hope that kind of explained what's going on.

**Mike Schmidt**: It makes a lot of sense, Dave.  And, Dave, you mentioned the
PR that there was some discussion on, and that's Bitcoin Core #30572, where you
have people like Greg Maxwell, AJ, Lightlike, 0xB10C, all discussing this idea,
which I thought was interesting to read through.  And I'll note that in one of
the PRs, Antoine Riard noted the three problems that he's hoping to improve on,
which are transaction relay as a DoS vector; transaction propagation
deanonymisation vector; and transaction relay throughput overflow attacks on
contracting protocols.  So, at some point he outlined that as sort of the things
that he's hoping to remedy.  Dave, I'm curious, are there other ideas that
you're aware of that would benefit from a v2 P2P Network or protocol?  Maybe
this particular proposal doesn't meet your threshold and there's other ways to
do it without having a second version.  Are there other things that are being
discussed that would benefit and this could tag along with it?

**Dave Harding**: We do need signaling mechanisms for other things, like Erlay.
Erlay is a proposal that would allow nodes that have transactions in their
mempool to communicate with each other whether or not they both have the same
set of transactions, and if they don't, which transactions each one has so they
can share them back and forth.  And that requires both nodes to know that the
other one uses Erlay.  I don't think that the way we've done this in the past,
for example, or upgrading nodes to prefer witness txid relay versus traditional
txid relay, we've just been adding new messages to the protocol to say, "Hey, I
use wtxids".  And it might be a little bit more eloquent to have a version
protocol, like what Antoine is proposing here.  We also have this established
mechanism of just adding messages to the P2P protocol to say, "Hey, this is what
I support".

I did not dig into Antoine's versioning message here.  It's a little different
than the wtxid thing, because he's turning off features, right?  He's turning
off this feature/anti-feature of unsolicited tx messages from the past, whereas
before, we only added features.  We're talking about adding Erlay, we added
wtxid relay.  But because I didn't think it was really necessary here, I didn't
dig into it in depth.

**Mike Schmidt**: One interesting tangent that resulted from this, and I
mentioned it earlier, is that Antoine is now looking to implement some of these
changes in some form using a libbitcoinkernel-based node.  We mentioned
Py-bitcoinkernel and Rust-bitcoinkernel as Rust and Python API wrappers around
the kernel library, which is encapsulating Bitcoin Core's validation logic.  And
I don't know if Antoine's motivation is more experimental, or more, "Maybe this
isn't going to work in Bitcoin Core, I'm going to start my own thing over here
using kernel".  But that seems increasingly likely to happen in the future if
people have things that they would like to implement, that they fire up some
kernel-based node and make changes to that.  Do you have thoughts on that?

**Dave Harding**: Yeah, so Antoine has previously worked on -- he had a PR to
open to Bitcoin Core.  I don't have that number handy, but for a plugin-based
relay module.  The idea was he wanted to experiment and he wanted to allow other
people to experiment with different relay policies, not just small changes to
the policy like you can do with changing Bitcoin Core's command line flags, like
you can turn off RBF or you can decide how large of a package you'll accept in
bytes and number of child transactions.  He wanted to experiment with even
larger changes to policy.  And I think everyone thought that was a good idea,
but also that it was kind of hard to get that to Bitcoin Core.  It would be a
maintenance burden to have a plugin-based architecture, and that it's already
hard enough to reason about relay policy in Bitcoin Core.  It's a little scary
making everything pluggable.

So, anyway, he had a PR open for this and did some initial development on this.
And I think this is a continuation of his efforts there, is that he wants to
experiment with different relay policies, like just this example here of no
longer accepting unsolicited transaction messages.  He can experiment with that
in a new node faster than he can get it to Bitcoin Core, and he can see what
effect that has on the node, you know, how does it interact with the network,
and are people really inconvenienced by it?  And I think he has other more
significant changes that he wants to make.  For example, he previously reported
a vulnerability in LN, where transactions can be replacement-cycled out of the
mempool.  And his idea for fixing that at the Bitcoin Core node level was for
the node to keep kind of a cache of transactions that it had previously seen and
go back periodically and look at that cache to see if any of those transactions
could be re-included in the mempool now and would make it more profitable.  And
again, I mean that's a good idea, it's something worth experimenting with to see
how it works out in practice, because there's trade-offs there.  Cache takes
more space, it's more CPU, it could be a new DoS factor.  On the other hand, it
could also help mitigate this existing DoS factor of replacement cycling.

So, there's a lot of trade-offs there to be considered and having your own node
to experiment with, it sounds like a great idea to me.

_What’s the rationale for how the loadtxsoutset RPC is set up?_

**Mike Schmidt**: Moving on to our monthly segment on Selected Q&A from the
Bitcoin Stack Exchange. First one, "What's the rationale for how the
loadtxsoutset RPC is set up?" The person asking this question wonders why, for
assumeUTXO, the block height and the UTXO hash are hardcoded into the Bitcoin
Core software.  So, why not just make that stuff something you could parse via
the RPC or something.  And Pieter Wuille explained that because of the
transparency and the highly active Bitcoin Core code review culture and Bitcoin
Core's reproducible builds, it allows for a more credible assumeUTXO UTXO set.
And that would be contrasted with, you could imagine that if someone creates
maybe a fly-by-night website that does something like daily UTXO sets for faster
sync, but that would be something that would potentially be more easily
compromised by an attacker.

**Dave Harding**: So, the problem here is when you get the UTXO set for
assumeUTXO, you have no way of verifying it's correct.  That's the whole point,
until you go with the assumeUTXO background validation sync.  And up until that
point, you're completely trusting it.  And if somebody gives you a bad set, they
can trick you into accepting bitcoins that don't exist.  They can add an entry
to that database that says, "Dave has 1,000,000 bitcoins".  So, I can send Mike
1,000 bitcoins and Mike can send me $1 million, and now Mike has 1,000 fake
bitcoins and I have his cash, and we just don't want that to happen.  So, by
hardcoding that hash into Bitcoin Core, we ensure that you only get that UTXO
set that has been reviewed through the Bitcoin Core process.  And we're really
hoping that process will ensure that it is the actual UTXO set.  And the idea
there is you're already trusting Bitcoin Core for everything else, you're
already trusting the Bitcoin Core review process to give you code that won't
steal your bitcoins.  If you're willing to trust it, you should also trust it
that it's not giving you a fake UTXO set that will steal your bitcoins.

**Mike Schmidt**: And then the second question is along those lines, the person
follows up to ask, "Why assumeUTXO, why is the height currently 840,000, and why
isn't it the same height as assumevalid, for example?"  Pieter also answered
this, pointing out that the original plan for assumeUTXO was to have a sort of
predefined schedule of block heights at which there would be a snapshot made and
then distributed, and actually distributed over the Bitcoin P2P Network.  So, in
that case, the snapshot height wouldn't be tied to Bitcoin Core releases.  So,
that is how the process was set up, even though there hasn't to date been
progress on such a predefined schedule and distribution.

Then the last question that was part of this question was around self-signing
UTXO sets.  And Pieter noted that, "Hey, if you're doing this just for yourself,
the easiest way to do this is actually just back up the chainstate directory",
and that assumeUTXO's features are mostly tailored for a wider non-local
distribution model of the UTXO set.  So, there's better options, if you get a
new machine, for you to copy it over.  But the point of assumeUTXO is
distributing that set to a broader user base.  So, it maybe doesn't make sense
to do that for yourself locally.

_Are there classes of pinning attacks that RBF rule #3 makes impossible?_

Second question from the Bitcoin Stack Exchange, "Are there classes of pinning
attacks that RBF rule #3 makes impossible?"  Dave, part of this question
involves BIP125's description of rule #3 and rule #4, which I think you have
some familiarity with.

**Dave Harding**: I wrote it, but I've mostly forgotten it at this point.  I had
to read the documentation like everybody else.  So, it looks like we just have
an answer here from Murch saying that that's not what rule #3 is for.  So, sorry
I'm not more useful on this, but I did write it over ten years ago!

**Mike Schmidt**: I think we covered something like this in a previous Stack
Exchange exchange, and I think the conclusion, and I don't want to tell you what
you did, but I think the conclusion was that BIP125 mirrored the checks in
Bitcoin Core and there were multiple checks, which then resulted in rule #3 and
#4 being in there, even though they somewhat covered the same bases.  And I
think that was something that Murch touched on in his answer before, I guess,
when he really got to answer the question, which was rule #3 isn't about
preventing pinning, it aims to prevent free relay.

**Dave Harding**: I mean, that's absolutely correct.  When I wrote it, I didn't
develop RBF, RBF was developed, but it was championed by Peter Todd in
consultation with other Bitcoin developers.  I just wrote the documentation, and
I wrote the documentation by reading the code and just seeing the rules and
writing them out in order.  And the reason there's this overlap between the
rules is one of the checks was easy to do, it's really cheap to do, so they did
that one earlier, and then they did a more comprehensive check later on.  But I
wrote them out as separate rules just because that's what I saw in the code.

_Unexpected locktime values_

**Mike Schmidt**: Makes sense.  Next question from the Stack Exchange,
"Unexpected locktime values".  The person asking this question, Domènec, was
running their own Bitcoin Network for testing, and noticed when generating a
bunch of transactions, that the locktimes varied in a way that he couldn't
determine, and so he asked about it on Stack Exchange.  And user, polespinasa,
explained how Bitcoin Core sets specific locktimes in certain scenarios, and we
outline those in the newsletter, but they are setting the nLockTime to the block
height, which discourages miners from fee-sniping or going back and remining
previous blocks to capture large transaction fees.  A second scenario, and this
is 10% of the time, randomly, Bitcoin Core will pick a random number between 0
and 99, and that number will be subtracted from the block height, and that will
be used for the nLockTime, to add some randomness there.  And then the last
scenario is, if that local node is not on the current chain, or not up to date,
Bitcoin Core will see that and then set the nLockTime to zero to avoid
generating a weird locktime that could leak some privacy in the form of
fingerprinting.  Seeing some weird value in there may be detrimental from a
privacy perspective to that node.  So, those are the three scenarios.

**Dave Harding**: Yeah, I'll just add to them on the privacy side for those last
two values is that your node doesn't know when it's at the tip of the chain.  It
has no way of knowing for absolute sure that it is at the tip of the chain.  And
so, if it always used the block height of what it thought was the tip of the
chain, somebody who was monitoring the network very carefully to see what block
height all nodes would be on, it could tell that you created a transaction if it
knew your node was a little bit behind the chain.  And all nodes are behind the
tip at some point when a new block is relaying across the network.  And
sometimes, it can be two or three blocks behind when a bunch of blocks have been
found in quick succession, or when that node was briefly interrupted from
processing for some reason, or whatever happened.  And so, by 10% of the time
randomly selecting a value, I think it's a value in the last 100 blocks, we just
reduce that.  It now becomes a credible reason that you have an old block.  It's
not because your node was behind, but because that node randomly selected a
value.

Then Bitcoin Core does have detection code to tell it that it's probably more
than 100 blocks behind the tip.  And in that case, that's when we use the 0.  A
locktime of 0 is always correct, it means the transaction is always valid, so it
can relay immediately.  But yeah, that's just it for privacy.  We don't want
monitors to be able to use this information here to figure out which node
created a transaction.

_Why is it necessary to reveal a bit in a script path spend and check that it matches the parity of the Y coordinate of Q?_

**Mike Schmidt**: Great points.  Thanks, Dave.  "Why is it necessary to reveal a
bit in a script path spend and check that it matches the parity of the Y
coordinate of Q?  This user is trying to understand why it's necessary to store
the parity bit of the taproot_tweak_pubkey in the witness' control block and why
it's necessary during batch verification.  And I'm going to tag in Dave on this
one.

**Dave Harding**: Okay, I believe I understand what's going on here, but I do
want to qualify that this is not my specialty.  However, as many frequent
listeners will know, in taproot, we have x-only public keys.  So, the point on
the curve that identifies your public key, we have the full X coordinate and
there's two valid Y coordinates, a positive value and negative value, or a
parity value and an unparity, I don't think we'll call it, and we know what
those two points are, but we don't know which one it is because we only have the
X value.  This saves us basically a byte every time we use a public key in the
protocol.  And when we're validating a transaction, one easy way to do it is to
just try to validate it on one of those Y coordinates and 50% of the time that's
going to succeed.  For the other 50% of transactions, we just validate to the
other and it'll succeed.  So, this very naïve algorithm we have only adds 50% to
the runtime to check one and then if it fails, checks the other.

However, if we want to do batch validation, basically what we do is we add all
the public keys together, we add all the public nonce values from the signature
to the public keys, and then separately we add all of the scalar values from the
signature together and we just check equality on those.  If we do that and we
guess wrong on the Y coordinate, the whole equation fails.  And if you're doing
batch validation, you're validating to, well, a typical block, 8,000 signatures
at the same time.  That's 2<sup>8,000</sup> times 50%, whatever.  It guarantees
certainty that it's going to fail, and you don't know which one it failed on, so
you can't just keep retrying it and expect it to complete in a reasonable amount
of time.  So, we need to know what Y coordinate was used so that we always add
together the correct values, the intended values.  And then, if the equation
returns equality, then we know all the signatures and block match all the public
keys; and if it doesn't, the block is invalid.  We don't have to go back and
retry again.

So, I hope that makes sense.  That's a little bit different than what the person
asked.  They do have an algorithm that works a little bit more efficiently than
what I described, but it does not work for aggregation because it will fail the
first time you guess wrong.

**Mike Schmidt**: That makes a lot of sense, and I'm glad that you're here to
explain it.  And maybe just to be clear, there is no batch validation or batch
verification currently, but the protocol was arranged in a way such that that
could be added and there are people working on that for the future.

_Why does Bitcoin Core use checkpoints and not the assumevalid block?_

"Why does Bitcoin Core use checkpoints and not the assumevalid block?"  Someone
saw an answer from Pieter Wuille from 2017, when he noted that checkpoints are
legacy and going to be removed.  But they noted that it's eight years later and
the checkpoints are still here.  And I think we covered this in a previous Stack
Exchange segment, but the low-difficulty header spam attack was something that
was known to be somewhat protected by blockchain checkpoints in the code,
although that protection was weakening over time.  But we've also talked about
the potential, and I think it was in that same discussion, that there could be
unknown attacks that checkpoints are protecting us from.  And Pieter outlined
this history around checkpoints and header spam as well in his answer.  And then
he went on to outline a bit of his philosophy on checkpoints, and I'll quote a
couple of segments here.

He said, "If somehow a chain existed which actually forked off from right after
genesis block and was valid and had more work than the chain that we consider
real today, the software should accept it, as drastic as it is.  Bitcoin's
security model relies on proof of work, which means accepting the most
work-valid chain, even if it's perhaps not the chain we want".  He also went on
to say, "If deep reorgs happen, some of the very core assumption underlying
proof of work are broken, and we should consider fixing it.  Checkpoints are not
a fix for this".  I think he's saying that because I think he's seeing a lot of
people reference that checkpoints are enhanced security.  And I think he's just
clarifying that it's, you know, security against what?  We should make sure that
the underlying assumptions and proof of work are solid and we should fix that
before relying on checkpoints.  Dave, do you have thoughts on checkpoints?

**Dave Harding**: I think it absolutely makes sense to keep the checkpoints that
are already there, which is all that's being proposed, or all that we have been
doing.  We update the checkpoints in eight years, nine years, a long time,
because like Pieter says, we need to depend on proof of work.  Either the system
works or it doesn't, and if you were to rely on checkpoints going forward, you
are relying on Bitcoin Core maintainers to decide which chain is the proper
chain.  And they don't want to be that authority, and we don't want them to be
that authority.  So, we rely on proof of work, and I think it works.  I'm pretty
happy with it.  So, let's keep going, I think.

**Mike Schmidt**: So, would you take that even further then and remove the
checkpoints?

**Dave Harding**: Like you said earlier, they may be providing some protection
at this point against something we don't know.  So, what the checkpoints do at
this point is require a certain minimum amount of proof of work in order -- you
have to do the same amount of proof of work as at the highest checkpoint, which
is I think is at block 300,000, it's at 333,333, or something like that; you
need to do all the proof of work that was done in the chain up into block
300,000 in order to make any sort of attack against Bitcoin Core that uses
reorgs and chain problems.  And so, if somebody discovers an attack, they have a
little bit more incentive to tell Bitcoin Core developers than to try to exploit
it, because to exploit it, they would need to buy a few hundred thousand dollars
probably of mining hardware to do enough proof of work in a reasonable amount of
time.  So, yes, I would keep them.

**Mike Schmidt**: So, there is an open PR as of January this year, Bitcoin Core
#31649 titled, "Consensus: Remove checkpoints (take 2)".  So, Dave is a NACK.
But if you're curious about the discussion going on there, check out #31649.

_How does Bitcoin Core handle long reorgs?_

"How does Bitcoin Core handle long reorgs?"  We have a lot of checkpoint reorg
discussion going on today.  Pieter also answered, and this was actually a
four-year-old Stack Exchange question about how Bitcoin Core handles long
blockchain reorganizations.  He explains that for every block that is part of
the active mainchain in Bitcoin Core, there is undo data that is maintained,
which contains all of the UTXOs that are spent by that block, and that undo data
is used during a reorg.  He also goes on to explain that any reorg down to the
last checkpoint, which we mentioned earlier, should be handled correctly,
although deeper reorgs may result in different behavior, since Bitcoin Core
won't re-add transactions back to the mempool since that would be an unbounded
operation.  And I think sipa mentioned something like ten blocks' worth would be
the trigger for not doing that.

_What is the definition of discard feerate?_

"What is the definition of discard feerate?"  The person asking this question I
think saw some references to discard feerate in some of the Bitcoin Core
codebase.  Murch answered the question, defining discard feerate as the maximum
feerate for discarding change.  And then he went on to point to the code in
Bitcoin Core for calculating discard feerate, summarizing it as, "The 100-block
target feerate".  And then that value is cropped to 3-10 sats/vB (satoshis per
vbyte) if it falls outside of the 3--10 range.  Dave, do you want to elaborate
there?  I feel like the question is answered, but the question remains.

**Dave Harding**: It does sound a bit scary, like we're throwing away money
here.  But the idea there is when you're creating a transaction, you usually
create a change output.  So, if I have a bitcoin and I want to pay Mike half a
bitcoin, I also send half a bitcoin back to myself as change.  But if what I'm
sending to Mike is, say, 0.999 bitcoin, am I really going to send 0.001 bitcoin
back to myself as change?  That's actually a lot of money, but at some point the
amount of money is so small that I probably don't want to create the change
output.  It will cost me more money to create the change output.  And also, by
not creating a change output, I can confuse Chainalysis-based heuristics that
try to guess who's sending money to who.  So, when there's a small amount of
money, we discard it.  We pay it to fees instead of paying it back to ourselves
as change.  And that's the discard rate we're talking about here; what is the
amount of money that we are willing to give up to actually possibly save money
and also improve our privacy.

**Mike Schmidt**: And to be clear, this is a different value than what the dust
or uneconomical output limit may be, right?

**Dave Harding**: Correct.  This has nothing to do with relay, this is
everything to do with Bitcoin Core's internal wallet.  So, this is not a node
policy, this has no effect on anybody else in the network, this is your wallet,
your Bitcoin wallet, deciding how it is going to potentially save you money and
enhance your privacy.

_Policy to miniscript compiler_

**Mike Schmidt**: Last question from the Bitcoin Stack Exchange, "Policy to
miniscript compiler".  The person asking this question asks if policy is still a
thing, if it's still being used, and if there are any implementations of policy
compilers, to which Bruno points out that the Liana wallet actually uses the
policy language and that both sipa and the Rust Bitcoin project have policy
compilers.  What are we compiling policy to?

**Dave Harding**: We compile policy to miniscript and miniscript compiles to
actual Bitcoin Script.  And I mean, I'm going to say here I use policy stuff
several times a year, particularly, min.sc is a miniscript-inspired policy
language.  And if I want to wrap the Bitcoin Script really quickly, I just go in
there and type in my policy that I want and it gives me a nice miniscript and a
nice actual script that I can look at it and I can say, "Look how smart I am.  I
just described this in a very natural way, what I want my script to do".  And
now I have this very low-level assembly-style language that will actually do it
on Bitcoin.

So, when we first started to cover miniscript, I thought policy language was the
real innovation.  That's not correct.  The real innovation is miniscript itself
and its ease of being analyzed and dealt with by various programs, but that
policy language is just a really powerful tool if you're someone who develops
new contracts and new ways to secure your Bitcoin.  For example, in Liana, I'm
sure you're using it for scaling up how many keys are used for securing their
vaults.

**Mike Schmidt**: Am I right that I believe that somewhere in the Blockstream
GitHub somewhere, there's a repository for collections of policies?  I may be
right, I may be wrong on that.  Maybe it's collections of miniscript scripts?
Do you recall?

**Dave Harding**: I do not.  I think maybe I saw something like that, but I
don't remember where I saw it.

_Core Lightning 25.02rc3_

**Mike Schmidt**: Okay.  Exercise for the reader.  Releases and release
candidates.  We have Core Lightning 25.02rc3, which is the third release
candidate in the last week or so, and I believe the first one that we've
discussed in the newsletter.  It contains some changes to channel backups,
BOLT12 splicing, and other changes.  We can consider having on a Core Lightning
(CLN) dev at some point when this is actually released, but in the meantime, if
you're using CLN, please check out this RC and test it and provide feedback.

_Core Lightning #8116_

Notable code and documentation changes.  Core Lightning #8116 titled, "Fix test
flake, improve close handling".  The PR author noted that his machine started
failing pretty regularly on a number of the tests, so this PR fixes that… we
have a different sort of explanation in the writeup; Dave, what did you see?

**Dave Harding**: So, it looks like if you get disconnected from your peer while
using CLN and you start closing the transaction and it gets finalized, the
mutual close, but you get disconnected before your node has fully seen the
broadcast of that transaction and has recorded it in its database as, "We're
probably done with this", when it reconnects to the other node after the
connection was dropped, whenever it connects to that node, that node is going to
say, "Hey, what channel are you talking about?  I don't have that channel
anymore, it's been closed".  Well, it doesn't say it's been closed, it just
says, "I don't know what you're talking about".  And your node is like, "Well,
hey, I had a channel with you".  So, your node is like, "Well, like I said, that
channel doesn't exist anymore.  I'm going to do a unilateral close".  And these
are both spending the same funding transaction and they're racing each other in
the mempool, which is going to get confirmed.  Is it going to be the mutual
close?  That's a smaller transaction, it saves you on fees, it has a final
channel state; or is it going to be the unilateral close, which is a much larger
transaction and it's designed with much higher feerates, because it's assuming
that the counterparty might be malicious?

You don't want to have that race, you want to go for the mutual close.  And your
node may already have all the information it needs for that mutual close to be
fine, it just has to look at the mempool and say, "Go find that funding
transaction and if you see it being spent in a mutual close, well then, hey,
it's a mutual close.  I was happy enough that I signed it in the past".  So,
that's what this PR is doing.  It's saying that if we connect to a peer, that
peer says, "I don't know about that channel, I don't know what you're talking
about", just go check, see if it's been mutually closed and you've forgotten
about it.  And if that mutual close is in the mempool, if it stays in the
mempool, and if it gets into a block, be happy.  Don't send the unilateral
close, that's gonna cost us more money in the long term.

_Core Lightning #8095_

**Mike Schmidt**: Core Lightning #8095 fixes an issue that causes CLN to crash
when setting a configuration variable.  There was an issue that was tied to this
PR and the issue was explained as, "On my system, the user that runs lightningd
does not have permission to write to the directory containing the config file.
I tried to use the setconfig RPC to change a dynamic config setting, and CLN
straight up crashed".  So, that's not great.  So, the change in this PR adds a
transient flag to the setconfig RPC to set variables that are applied
temporarily and do not actually modify that configuration file, so therefore it
won't crash your CLN node.  That also means that any of those transient changes
would be reverted if you restarted your node.

**Dave Harding**: We saw, it's not linked here, but we saw a change to Bitcoin
Core several years ago that did something similar.  Now they never had to crash
Bitcoin Core, but it's a very common thing we see, is that people want to apply
a configuration change or just one run.  And they can do it with configuration
flags.  But in Bitcoin Core's case, people were setting stuff with the GUI that
was having the choice, "Do you want to write this to the configuration file?"
Do we really want a configuration file that will manually edit it to
automatically edit it from the GUI?  And CLN has kind of faced the same problem
in the past.  So, they have this setconfig command, and now they have this
transient flag for setting stuff just for their current session, which like I
said, is something people often want to do.

_Core Lightning #7772_

**Mike Schmidt**: Core Lightning #7772, which is a PR that extends CLN's peer
storage functionality, which already contained a static channel backup used for
node recovery.  In this PR, that functionality is extended to allow CLN nodes to
create penalty transactions when the PR publishes an old revoked state using the
emergency.recover file.  And the PR achieves this by adding a hook to the
chanbackup plugin that will update that emergency recover file whenever a new
revocation secret is received.

_Core Lightning #8094_

Core Lightning #8094 adds an xpay-slow-mode configuration.  This change resolves
an issue that outlined inconsistency around handling pending HTLCs (Hash Timed
Lock Contact) between other CLN commands.  The issue that motivated this noted,
"Xpay has cases in which it exits, despite it still having pending HTLCs.
That's different to pretty much all other commands to pay invoices and makes a
reliable implementation to not accidentally overpay, by starting another attempt
with a different command or node, incredibly difficult".  So, this new
configuration option will make xpay wait for all parts to either fail or succeed
before returning.  We should note that the default of this value is false and
the docs note, "Usually this is unnecessary, as xpay will return on the first
success or failure".

**Dave Harding**: My understanding for the motivation for this, so the top of
the issue there is for any sort of payment, but particularly multipath payment,
we're sending multiple payment parts that all have the same hashed preimage.
And if you only have a single Lightning node, when you pay your thing, xpay will
work just fine and it's completely safe.  The case that's being addressed here
is, what if you have multiple Lightning nodes, and I try to pay Mike using my
first node, and some of the multipath payments get stuck; and xpay returns, even
though the payment wasn't a success, but I don't realize that it wasn't a
success, I don't realize that it's still stuck?  And then, I go to my other node
and I say, "Well, the first one didn't work, but I need to pay Mike right now".
So, I'm going to go to my other node, I'm going to try to pay him from that.
And I pay him, I pay the same invoice, I use the same hash and same preimage,
and that payment goes through and Mike settles it and releases the preimage.

Some of those nodes that have the stuck payments see that preimage, well they're
able to settle the payments from the original node, and so I'm now overpaid,
I've paid using both nodes.  And Mike doesn't actually get that money.  So, not
only have I overpaid, but I haven't even overpaid the person I wanted to pay in
the first place.  This is a pretty rare situation that people are going to have
two nodes and they're going to switch between them, in the case of a payment
failure on one, but it is a situation that they want to address in CLN.  This
xpay-slow-mode, like Mike says, it just won't return until the payment has
actually been a success, as in all the parts have gone through and the recipient
has revealed the preimage; or it's been a failure, all parts have been failed
back to the sending node, at which point it's safe to go and try to send it
again from a different node.

_Eclair #2993_

**Mike Schmidt**: Eclair #2993 is a PR titled, "Allow recipient to pay from
blinded route fees".  Before this PR, the sender paid all the fees along a
blinded path.  This allowed the sender to potentially use that information to
infer the path and even unblind the path with that additional information.  So,
after this change, the sender pays the fee for the non-blinded part of the path,
and the receiver pays for the blinded part of the path-related fees.  So, not
only is that more private because you're giving less information to the sender,
but also more fair, as the PR notes saying, "The sender chooses the non blinded
part of the path and pays the corresponding fees, the recipient chooses the
blinded part of the path and pays the corresponding fees".  So, it's both fair
and more private.

**Dave Harding**: Yeah, I think this works because basically, it's telling the
sender that all the fees on the blinded parts are going to be 0.  However, when
that part of the onion is unwrapped, it is paying a fee.  So, the sender is
ultimately accepting less money and then claiming the fees are 0 for the blinded
part of the path; whereas, when those parts of the path are unblinded by the
last few hops, they see actual fees and they deduct that from the amount that
the recipient is ultimately going to receive.  So, it's of course compatible
with the protocol and it accomplishes everything that Mike just described.

_LND #9491_

**Mike Schmidt**: Last PR, LND #9491 entitled, "Allow coop closing a channel
with HTLCs on it via lncli".  This PR makes two changes to LND's channel closing
functionality.  The first one is that the max_fee_rate is now respected during a
cooperative close, whereas before this PR, max_fee_rate would only be applied
for the remote party in the channel close negotiations, and not the actual node
itself obeying that max_fee_rate.  And then secondly, in the cooperative channel
close case, LND will now handle active HTLCs.  And the way it does that is that
LND will disable the channel for new HTLCs and then kick off the cooperative
close flow automatically when the channel has no HTLCs left.

All right, that wraps up Newsletter #343 Recap.  Dave, thanks for joining as
co-host this week.  No special guests.  We'll hear you all next week.  Cheers.

{% include references.md %}
