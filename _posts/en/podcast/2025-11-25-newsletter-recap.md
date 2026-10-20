---
title: 'Bitcoin Optech Newsletter #381 Recap Podcast'
permalink: /en/podcast/2025/11/25/
reference: /en/newsletters/2025/11/21/
name: 2025-11-25-recap
slug: 2025-11-25-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Antoine Poinsot and ZmnSCPxj to discuss [Newsletter #381]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-10-25/413163791-44100-2-7f551e2003f07.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Optech Recap #381.  Today, we're going to
be talking about modeling stale rates and block propagation delay and its
relation to mining centralization concerns; we're going to talk about a
technique called private key handover for collaborative closure; we have six, I
believe, updates to Services and client software; and then we have our Notable
code segment.  This week, Murch, Gustavo and I are joined by a couple of special
guests.  First one, Antoine, you want to introduce yourself?

**Antoine Poinsot**: Hey, my name is Antoine, I work on Bitcoin Core at
Chaincode Labs.

**Mike Schmidt**: ZmnSCPxj?

**ZmnSCPxj**: Hi, I'm ZmnSCPxj, I'm some random guy on the internet, and I work
mostly on Lightning, and yeah, that.

_Modeling stale rates by propagation delay and mining centralization_

**Mike Schmidt**: Good to have you, random guy.  We're going to go in order of
the newsletter.  If you're following along, we're jumping into the News section.
First news item titled, "Modeling stale rates by propagation delay and mining
centralization".  Antoine, you posted to Delving Bitcoin about modeling stale
block rates and how block propagation time can affect a miner's revenue as a
function of its hashrate.  Maybe to start the topic, can you define what a stale
block is for us?  And then, we can get into the effect of propagation times.

**Antoine Poinsot**: Sure.  A stale block is a block that is found by a miner
but does not end up being included in the most-worked chain, which means that
the miner does not end up getting paid for mining this block.

**Mike Schmidt**: Is a stale block an orphan block?

**Antoine Poinsot**: It has been described as orphan block in the past, but it's
a mistake.  Orphan blocks are blocks for which a full node is missing the
parent, and mostly a thing of the past.  They were a thing before header-first
synchronization, whereby you could receive a block, but you didn't have its
parent yet.  But now that the full nodes are synchronizing the header chain
first and then downloading the blocks, they're always downloaded in order.  So,
we don't have orphan blocks anymore.  Stale blocks are really a different thing.
You have the parent, it's just that essentially your block does not have child.
Nobody built on top of your block.  They built on top of a competing block at
the same height.

**Mark Erhardt**: Nit, of course there could be two stale blocks if we had a
two-block reorg, and then the first of them would have a child.  But generally,
they're just not part of the best chain.  It means there's a second block at the
same height, because obviously the chain will have exactly one block at every
height, and it's not part of the most-worked chain.  And usually, or actually
always in our history so far, they do not have enough successor blocks to get
paid out after the maturity of the coinbase.  So, you can only spend coinbase
outputs after 100 blocks and usually these stale blocks never reach 100
successors, so they cannot be paid out.

**Mike Schmidt**: Antoine, do you want to bring in block propagation here into
the stale block conversation?

**Antoine Poinsot**: Maybe one more thing to say on the stale blocks, which is I
said that what matters is that the miner does not end up getting paid for it.
Another thing that matters is that those stale blocks, because they're not part
of the most-worked chain, are not taken into account when readjusting the
difficulty.  And this is a mechanism that can be exploited with selfish mining.
And that is the root issue for the, I was going to say 'unfair', but the
disproportional advantage that big miners get over small miners with large
propagation times, which is a good segue.  Did you want to say something, Murch,
or should I go into propagation?

**Mark Erhardt**: I was just going to say, obviously, that the UTXO set also is
only calculated from the best chain, so confirmations in stale blocks don't
matter, only whatever is confirmed.  But the part about the difficulty
adjustment is much more pertinent.  So, go right ahead.

**Antoine Poinsot**: But it's very related.  It's wasted work.  It's bad for the
network, because we waste the security of the poor work by having stale blocks
for everybody.  And the fact that it's not taken into account in difficulty
adjustment means that it's going to advantage bigger miners.  So, just to take a
step back, mining centralization has been talked about a lot recently and it's
always been talked a lot, it's always a concern that we had.  But it's sometimes
used to make design decisions in Bitcoin node software.  And it's important to
be able to have an idea of the quantify of how much centralization are we
talking about?  How strong are the pressures that we're talking about?  There
are various centralization pressures, financial ones, volumes, etc.  But one of
them has to do with stale blocks and the fact that the higher the probability of
the network having stale blocks, the bigger the advantage of big miners, because
essentially, a friend of mine gives the intuition this way.

Assume that there is a stale block, which means that there is a race.  There are
two miners that are competing for a block at the same high, and essentially the
one that is going to win is the one that is going to be able to find a second
block on top of it.  If two miners happen to be finding the same block at the
same height, which of the 1% miner or the 40% miner is going to find the next
one?  Obviously, the large miner has a tremendous advantage of just reaping all
benefits from this situation.  And it's actually even worse than that in the
presence of block propagation times, because block propagation times make this
dynamic more probable, which is a small miner, that is even assuming that
everybody is running stock Bitcoin Core and nobody's trying to play small games
of continuing to mine on top of your block, even if you heard about another
block, just the fact that it takes time for one miner's block to reach everybody
else, it's as much time as everybody else is going to continue mining a
competing block, essentially.  And even before the miner found their own block,
there could have been another block that they didn't hear about.  And you're
already in this situation where there's two situations.

Either given the event where you just found a block, you're a miner, you just
found a block, the proof of work (PoW) is valid.  If the average propagation
time is like 10 seconds, there might have been, in the 10 seconds prior to your
finding a block, someone else found a block, but you didn't hear about it.  And
what's going to happen is that you're going to publish your block, but you're
going to be X seconds later than the previous person.  So, most likely, the
entire network is going to be mining on top of a competing block to yours.  So,
unless you're a very big miner, most likely your block is going to go stale.

**Mark Erhardt**: Yeah.  So, there's two problems here.  One is, if there's two
competing blocks, obviously there's a likelihood for either of them to be part
of the best chain, and the authors of each block are working on their own block.
So, the work that the author of the block that loses is doing towards the next
block is basically going into the void.  We always split the hashrate at that
point to some degree, where a portion of the hashrate is just mining on a chain
that will not be the best chain.  And we don't know which of the two it will be,
but the overall hashrate working towards the next block is split, and therefore
the perceived hashrate of the network is reduced for some time.  And the second
problem is due to blocks actually taking time to propagate on the network and
bigger miners usually being better connected and having more hashrate in the
first place, bigger miners are much more likely than their hashrate would
indicate to win the next block or to be ratified by another miner that hears
about their block first.  So, if a small miner at home with just eight
connections finds a block and propagates them, that has less of a head start
than if a huge miner with 20 border nodes and 160 peers finds a block and
immediately sends it out to other mining pools, and so forth.

So, little miners are in trouble twice here.  And because the overall hashrate
is perceived to be lower in that event that there are two competing blocks, the
bigger miners that are more likely to win are perceived to have a bigger portion
of the remaining reduced hashrate.  So, their perceived hashrate of the total
hashrate increases, whereas the perceived hashrate of the smaller miner that is
on the competing chain is reduced because of the likelihood to win and the
overall hashrate going towards the next block being reduced.

**Antoine Poinsot**: It's more than perceived, it's effective.  The effective
hashrate of smaller miners is smaller than their stated controlled portion of
the hashrate of the network; and the effective hashrate, which means the
proportion of blocks found by bigger miners, is higher than their nominal value
of hashrate.

**Mark Erhardt**: Yeah, I think we established why those style blocks are bad.
Mike, what's up?

**Mike Schmidt**: Oh, I was going to say when I was going to ask a question
earlier, I think you touched on it in that, I don't know if this is true, but I
suspect, like Murch said, that larger miners or pools have potentially more
connections to more hash power than somebody who's maybe running on a smaller
pool with less connectivity.  And obviously then, the assumption that it's a
10-second block propagation, maybe it's 12 for them and 8 for the larger pool,
or something like this.  Is that a right way to think about it?

**Mark Erhardt**: Yeah, I think that just imagine you're pushing out a new block
to 160 peers and they propagate it to all of their peers versus you're a home
miner and you have 8 outbound peers and then maybe you have 50 inbound peers as
well.  Your first hop will still reach fewer -- actually, sending to all your
peers and them sending it forward basically gives you a similar reach as the big
mining pool would have in the first place, right?  So, it's a small difference,
but you're basically one hop further away from reaching everyone in the network.
And also, to be clear, the 10 seconds is an example.  I think the actual block
propagation times are significantly lower right now.  We're more looking at 1,
1.5 seconds, 2 seconds maybe to reach most of the listening nodes.  They were
around 6 seconds 10 years ago, when we really had a lot more stale blocks, when
we would see competing blocks once per day, roughly.  And now, it's more like
once every 10 days, once every 2 weeks.  It used to be once every 18 days, but
now with so many non-standard transactions, it's come down a little bit, I
think.  But maybe Antoine can tell us more about that because he's been looking
into those statistics.

**Antoine Poinsot**: Yes, so there is two.  So, coming from the previous step
of, we designed node implementations in order to avoid stale blocks, one of the
ways to avoid stale blocks is to decrease block propagation time such as we
reduce the probability that the hashrate is going to be split, as Murch
explained before, on competing blocks.  And how much of an effect does it have
and how much does it justify some design decisions in the software is going to
be a product of two things.  First of all, how much the design decision affects
the block propagation time.  This is a question that is left for different
research, but I tried to answer the second one.  Given an increase in block
propagation time, how much of an advantage is it going to give to bigger miners?
You cannot answer this question definitively because you do not know what games
the miners might be playing, but you can define a realistic model to give you
more information than just shooting in the dark.

So, my model assumes uniform block propagation time, so it's probably an
understatement of the advantage of big miners, because big miners are more
likely to be more well-connected, but it is not integrated in my model.  And
then, it assumes a distribution of the hashrate that is similar to what we have
today.  Essentially, you have two miners around 30% of the hashrate, then you
have something like 4 or 5 at around 10%, and that's about it, like 3 around
10%.  I know it doesn't add up, but that's about that because then the rest is
like 1, and then point-something.  Because the hashrate of the distribution
matters itself, like the distribution on the network matters for the probability
of an individual miner, so if everybody else is more centralized, you're more
likely to get more stale blocks, and it's completely out of your control.  And
given this model, I'm trying to answer what is the advantage of a given miner in
function of block propagation times.  Currently, the block propagation time is
around 1, 1.5 seconds, as Murch said, and I've put some graphs for up to 10
seconds or something, which is not unrealistic, it's what we had before compact
blocks in 2015.  But it's very much realistic today.  But it gives us an idea of
where we come from.

What I ended up with, from the top of my head, was like 15 basis points'
advantage in revenue for a bigger minor under something like a 5-second
propagation time, which might be possible today, I don't know.  That's part of
the other question to answer in function of what's the effect of design of the
net software on the block propagation time.  But let's say a 5-seconds, on
average, propagation time would give an advantage of the bigger miners over the
smaller ones in the order of 15 basis points -- a basis point is a percentage of
a percentage -- in revenue, which is non-trivial in multiple aspects.  It's
non-trivial because we're talking about a lot of money.  15 basis points can be
quickly $1 million, depending on your mining operation, and $1 million revenue a
year, when you have employees, you have salaries to pay, you have debts that you
need to pay.  And by connecting to the bigger pool instead of the smaller pool,
you can make $1 million more a year.

It has clear incentives in the real world.  And then, it's also the case that in
any case, it's a bigger, much bigger fraction of the profits of the miners,
because miners run on tight margins.  And if they have, let's say 1% of profits,
then quickly it's going to be 15% more profits to just switch to the bigger
pool.  So, it's a much bigger fraction in both respects.  So, yeah, I think it's
substantial.  It's not like 10 times more revenue if you're going to switch to a
bigger pool, but I think it's very clear, especially as the network gets bigger
and the amounts get bigger, that it's a non-trivial amount of centralization
pressure due to stale blocks.

**Mark Erhardt**: I wanted to repeat and summarize again the point why even
these small increases matter so much.  So, the costs of running mining
operations with the overhead, the employees, the electricity, the hardware that
you buy, and so forth, they come fairly close to what they're earning on the
Bitcoin mining with, of course, some safety and so on.  They have to actually
make money, otherwise it wouldn't be worth pursuing this business.  But if
there's a lot of money coming in and a lot of money going out, the actual profit
is just a tiny portion of the revenue.  So, if you have a small revenue
increase, it will be added 100% to the profit.  And a small revenue increase can
be a huge profit increase, and I think that's the very important point here.  If
there's a very thin margin, let's say you make 1%, or I think it might be more
because that would be a scarily thin margin, especially with the volatility,
anyway if it's a small portion of your revenue that's your profit, an increase
in the revenue will be a huge increase in profit.  That's all.

**Antoine Poinsot**: And also, maybe to just drive this point home, it's not a
static thing.  It's just that if one miner tries to, let's say, hire less
people, pay his shareholders less, and therefore continue to exist with smaller
profits, then it's just going to incentivize new mining operations to join the
network that do not care about this thing of mining centralization, join the
larger pool, drive the hashrate up, lower the profit margin of everybody, and
just drive out of business the small miners.  So, it cannot be altruistic.  The
economies need to be right and a small divergence can make a huge difference.

**Mike Schmidt**: So, what do we do about this?  We sort of have a prisoner's
dilemma or a miner's dilemma where if I'm a small miner right now and I'm
listening to this podcast, I'm like, "Oh, I should switch to a larger pool.  But
I want everybody else to not, and I don't want larger pools to exist, but I'm
going to be in the larger one if there is one".

**Antoine Poinsot**: Murch, do you want to take this?

**Mark Erhardt**: Yeah, sure.  I wanted to say that's why we want mining to be
as fair as possible.  So, if blocks go through more quickly and everybody is
able to get roughly the same latencies, there is still going to be a small
advantage for bigger mining pools; but as the latency goes down, the hashrate
proportion will match the revenue proportion most closely.  And that is how
mining becomes fair.  If small operations earn the same proportion of the
revenue as the hashrate they provide to the network, they are not financially as
disincentivized.  Obviously, there's advantages of scale.  Having one person fix
100 ASICs is a lot less overhead than having a couple of ASICs at home, and
every time you have to fix something, you have to do a few hours of research
because you need to look it up.  But then, on the other hand, larger operations
have to do a lot more heat management, or heat might even be one of the side
products that you explicitly want in your home operation, because you're using
it to heat your glasshouse, or whatever.

So, there's of course nuance.  And if you're producing your own electricity via
solar or something, you might actually have less cost per hashrate at home.  But
overall, big mining operations have huge advantages.  And the one advantage that
we can affect at all at the protocol level is the latency of the block
propagation.  And if the latency is as small as possible, it'll improve the
fairness of mining.

**Antoine Poinsot**: Just to answer directly your question, Mike, this is not an
issue today for small miners, because block propagation times today are so
small, with an asterisk: it seems that the current stale block rate is like one
every two weeks, which is probably as small as we could get.  It needs to be
verified because it's hard to actually estimate the number of stale blocks on
the network, because they do not get propagated, the headers do not get
propagated.  It might be worth modifying the protocol so we can get good tabs on
the stale rate.  But assuming that the stale rate is what we think it is
currently, which is one stale block every two weeks, the profit increase of
switching from a small pool to a big pool is minimal right now.  So, it's not a
big incentive for small miners.  Small miners, you do not need to switch pool
right now.  But it's important that we keep this situation of low block
propagation times. and it's really paramount to the Bitcoin Network functioning
correctly.

**Mike Schmidt**: You mentioned communicating maybe about these stale blocks.  I
think, was there some commentary between you and Greg Maxwell on the Delving
thread?  Was that about that or something else, Some sort of P2P message or
something, I thought it was?

**Antoine Poinsot**: Yeah, so we discussed it during Bitcoin Research Week with
a group of people as well, and Greg Maxwell just made exactly the same point on
Delving.  So, it might be something worth following up on.

**Mark Erhardt**: So, the idea here would be, what if we just propagate at least
the headers of all the stale blocks that are found, even if we have a different
-- so, maybe to explain what nodes do today.  When a node receives a block
announcement, they will check whether the header fits the chain.  And if it
makes a new best chain tip, they will download the block and switch to that
chain tip.  When they receive a second announcement for a block at the same
height, I think they will still retrieve the block and store it, but they will
not propagate it.  So, whenever you have two competing blocks in the network,
you sort of get them only reach at the borderline of the two distributions.  So,
let's say A and B are mined at the same height.  A gets propagated to 50% of the
nodes before they hear about B.  And then, as B is propagated to the network
from some other origin, at some point they bump into each other.  And if a node
already knows about A, it'll learn about B from its peer, but not forward B.
And vice versa, the nodes that first learned about B will maybe hear the
announcement of A from their peers, but then not forward it.  So, neither of the
two propagates all the way until one of them pulls ahead.  As soon as a chain
tip pulls ahead, everyone will propagate all the blocks they need that are
needed to reach that best chain tip.

So, the idea would be, what if we just propagate the headers at least, or even
the whole blocks for stale chain tips, because they are protected by PoW anyway.
They are very expensive to create, yes, they're lost work, but you can easily
DoS them, right?  You can just create transactions and send them, they're not
protected in any way.  But blocks, you actually have to find a header with a
nonce that will fit the difficulty requirement, and only those would be
propagated.  And that might be interesting information for the network as a
whole to get a sense of how much work is wasted right now and how good the
decentralization is right now, how much stale blocks we are getting.

**Mike Schmidt**: Antoine, maybe a question.  I know this wasn't part of your
research, but you did mention this tangential protocol design, or sort of policy
decision-making and how it can take this into effect.  We had the sub-sat summer
with a lot of nodes not having maybe up to half of the transactions that were
eventually confirmed in a block before they were confirmed.  How did that affect
stale rates, if at all?

**Antoine Poinsot**: That's a good question.  I don't want to give numbers
because I don't think we have any reliable numbers.  I heard some people having
estimates and giving some numbers, but I think we would need something like the
protocol modification that Murch described in order to have good metrics.  It
seems to have affected block propagation times less than I would have expected.
It's like twice slower blocks during the sub-sat-per-vB (satoshi per vByte)
summer, maybe at worst 2.5, 3 times as worse.  I would have expected it to be
more, but it would be nice to corroborate these measurements with actual
measurements of the effective stale rate, because we might be missing some.

**Mark Erhardt**: Yeah, generally the stale rate is really hard to measure,
because if we get one stale block in two weeks, it is very hard to distinguish
if we get a block after 10 days, whether that's just randomness, or whether
actually we have an increased stale block rate.  So, it's only something we can
actually measure over months.

**Antoine Poinsot**: And something maybe interesting to mention, sorry to hijack
the session with my topic, but maybe something interesting to mention is that
the improvements in block propagation time over the network have made more
obvious the time delays in the infrastructure on the mining sites themselves,
such as using protocols like Stratum v1.  And moneyball, Steve Lee, shared a
blog post of the Stratum v2 team, who made measurements of the improvements of
block propagation time using Stratum v2 instead of Stratum v1, and it's
non-trivial.  It's pretty substantial as well, at least what they claim in the
blog post.  I didn't verify it myself, but if that's the case, that might be the
next best area to look for to reduce the stale rate.

**Mark Erhardt**: So, you're saying there might actually be other reasons than
being able to build block templates at home to switch to Stratum v2, because
actually your miner and mining pool communication will be faster and you'll get
fewer stale blocks?

**Antoine Poinsot**: Yeah, not getting your hashrate stolen because you
communicate over clearnet, less stale rates, and long-term decentralization
benefits.

**Mike Schmidt**: Antoine, anything else you'd like to leave the audience with
before we wrap up this news item?

**Antoine Poinsot**: No, thank you for sharing my feedback, and just to be
clear, yes, it's not fearmonger.  The current situation is fine, we just need to
make sure it doesn't get worse.

_Private key handover for collaborative closure_

**Mike Schmidt**: Thanks for joining us, Antoine.  We appreciate your time.
Second news item titled, "Private key handover for collaborative closure".
ZmnSCPxj, you posted to Delving Bitcoin about private key handover, which is an
optimization for protocols where funds that were jointly controlled by two
parties ultimately are resolved by being refunded to a single party.  The
approach can be used with ECDSA, but what you've written up here uses taproot
and MuSig2 for efficiency.  Can you explain your protocol?  And I don't know if
you think the best way is to walk through the HTLC (Hash Time Locked Contract)
example, or where would you like to begin, ZmnSCPxj?

**ZmnSCPxj**: Basically, it's probably best to consider it in terms of an HTLC,
because an HTLC is a single UTXO.  And what we want here to happen is that the
offeror wants to pay the acceptor if and only if the acceptor is able to reveal
the preimage to the offeror.  And this entire fund, this entire UTXO is then
handed over, or is semantically now controlled solely by the acceptor in this
protocol.  So, that's what the idealized flow of an HTLC would be.  So, in
exchange for the preimage, the acceptor is paid.

So, the core of this optimization is simply that we have a branch which is a
2-of-2 of these two.  So, in an HTLC, you have two branches.  You have a
hashlock branch, which the acceptor is able to key in, it gets the acceptor key,
and the preimage to the hash; and a timelock branch, where the offeror is able
to recover the entire fund at the end of the timeout.  So, we're adding a third
branch, which is a 2-of-2 between them, and then depending on what happens, like
if the acceptor says, "Oh, there is no way for me to learn this preimage", then
it can hand over its private key in this 2-of-2 to the offeror, or vice versa,
"Okay, here's the preimage", and they can use a private communications channel
instead of broadcasting it over the blockchain, and then the offeror hands over
its private key.  So, those are the two parts of this private key handover.

So, basically, this idea, I've actually had this even before COVID, and I posted
it on a coinswap project, and I can't find it anymore so I'm assuming that
coinswap project is lost to history.  So, that's why I posted it in Delving
Bitcoin so it won't get lost.

**Mark Erhardt**: Could you maybe put this into the perspective or in the
context of other proposals?  How does this compare to, say, a statechain or an
LN channel?  It seems like you're talking about transferring whole UTXOs, which
makes me more think of statechains, but you put it in the context of HTLCs.
Could you clarify that?

**ZmnSCPxj**: Okay, so one of the things that you have to zoom out of is that
the LN requires onchain activity.  You can't transfer.  There are some payments
that are impossible, simply because of liquidity reasons, without having an
onchain activity.  So, that's the thing that René Pickhardt has been researching
about.  He's been blasting about this for quite a bit already.  There are
payments that are simply not possible on the LN.  These payments are small, they
would not be feasible to do on the blockchain, but they still cannot pass
through the LN because of liquidity reasons.  We need onchain operations to
reconfigure LN in order to get those payments through the door, get those
payments out, get those payments routing.

So, what are the things that we can do to change the state of the LN?  We can
open channels, we can splice in channels, and we can use swaps.  So, we can swap
an onchain amount for some Lightning amount, and it's this operation that I want
to focus on.  Because I actually computed it and it turns out swapping is
smaller than splicing using an onchain swap, even if it's an HTLC.  It is still
smaller than splicing-in.  And the good thing here about the swap is that a
single onchain HTLC can change the state of multiple channels, and it's still
the same size.  This is unlike a splice.  Splicing has the ability to batch
multiple channels in a single splice transaction.  The protocol can do that.
There are no implementations that support this yet, because this is ridiculously
complicated, but it is still theoretically possible in the protocol.  Nobody
will implement this anytime soon.  But it's theoretically possible in the
protocol.  Even with that, swapping still wins.  Why?  Because the transaction
has to have one input and one output per affected channel.  Whereas if it's an
onchain HTLC swap, this HTLC is constant size.  It doesn't matter how many
channels it went through, it will still be the same constant size.  We are
talking about O(n) size versus O(1) size.  So, swaps are actually much more
efficient than splicing.

So, in terms of the LN, we should probably be focusing on swaps and we should be
considering stuff like onchain HTLCs.  And again, private key handover is
another advantage.  When we're splicing, after the splice operation, the channel
is still controlled by two operators, right?  So, they can't use private key
handover.  But an onchain swap, the HTLC-UTXO is transferred as a whole, so we
can use private key handover.  So, again, one of the reasons why splicing is
taking a long time in order to actually get deployed is because we needed to
support RBF, and that RBF support needed to come in the protocol design.  So,
even if initial implementations don't intend to do RBF, we need to design the
protocol from the start to have RBF.  This is unlike an onchain HTLC, where with
private key handover, we don't even need to consider RBF.  Were you wanting to
say something, Murch?

**Mark Erhardt**: Yeah, I was trying to wrap my head around what you're
proposing and I was ready for an attempt to try to summarize it back to you.
So, I'm understanding that we're looking at a situation where Alice and Bob have
a number of different channels with each other.  And essentially, to settle or
rebalance multiple of their channels, instead of splicing-in and having inputs
for each of those channels and creating new channels with different balances, we
would hand over a single UTXO onchain.  And then we could, for example, route
any excess on those other channels to rebalance them.  Is that what you're
proposing?

**ZmnSCPxj**: Okay.  The drawback of splicing as well is that it is very local.
It needs that the person that is batching the splice has to have channels to
each of those peers.  With a swap, you can have a longer line, a longer series
of channels, so that this Alice and Bob don't need to be directly neighbors to
each other on the graph.  They can be very far from each other and they would
still be able to use the swap in order to rebalance all the channels between
them.

**Mark Erhardt**: Right, but the swap would basically be also a 2-of-2 multisig
construction that gets resolved to a single sig eventually, but the setup is
like creating a channel.  So, isn't it kind of funny to say that they don't have
a channel relationship when the swap is sort of like a channel?

**ZmnSCPxj**: Yes, and now we are going to segue into forwardable peer swaps.
Okay, so what is a forwardable peer swap?  So, a peer swap is a swap that I
perform with my direct peer over our channel.  So, what we do actually is, like
you said, we create a temporary channel, we move all those funds to the other
side, and then we reset our persistent channel, the state of this persistent
channel.  Now, this operation can be done locally, but the thing is, you can
also forward this exact same request to your own peer.  So, for example, your
peer is making this request to you.  You can forward it to another peer.  So,
for example, the peer says, "I have this onchain fund and I intend to send out
more funds to you via this existing channel, persistent channel that we have in
the future.  This is why I am performing this peer swap with you".  Now you can
go and look at your own channels and see, "Hey, are there any other peers that I
have that I probably will be sending out to, and therefore I would want to also
forward the same peer swap to them?  And this intermediate node is performing
this decision.  It's using only its own local view of the network without
requiring continuous feedback, like the way payments are.  If a forwarding
payment fails, it has to go back all the way to the source.

Instead, we can look at the state of your own channels to figure out, "Do I want
to forward it to somebody else?"  And it ends up still having just this single
HTLC onchain, even though multiple nodes on the network can benefit from this.

**Mark Erhardt**: Okay, I think I better understand now what you're trying to
say.  So, essentially, I want to pay some other random Bitcoin user and they are
LN participants as well.  So, I'm essentially offering to pay them onchain, and
any excess of the UTXO that I'm intending to use to pay them onchain, we settle
on the LN in the opposite direction.  So, it's basically an onchain payment
where the change output, instead of sending it back to myself, becomes a
Lightning rebalancing amount.  And because the recipient, the acceptor, is
really only interested in getting paid, they don't have to receive the onchain
payment themselves necessarily.  They could also allow someone else to receive
it, as long as this other person then pays them in the LN.  So, they get paid
and they can use either themselves or another peer to do the onchain payment,
and we don't need the change output and we can use the excess funds to rebalance
in the LN.

**ZmnSCPxj**: Yes, that's basically it.  We can do this and this gets forwarded
on the network in a packet-routing sense, not in a source-routing sense.  So,
that's a drawback of the LN, is that because we want it to be private, we are
source routing.  We do not want to display the destination, the final
destination, on the packet that we are sending out, which makes packet routing
on its face impossible.  But because there is no destination here, there's no
final destination here, it can be forwarded, or you can just settle it on your
own node if you want to, it doesn't matter.  There's no privacy loss to retain
packet routing here.  And packet routing is the basis of the internet.  It's how
the internet has worked.  It's one of the things that we've found difficult, is
that the LN is not actually quite compatible with the internet protocol.  For
example, we are used to having a proxy that can load-balance between multiple
back-end servers.  We can't actually do that on the LN, because when they're
going to send a payment through, the payment encodes which specific back end
it's going to go through, and you can't actually load-balance it to a different
backend when you're doing proxying.  So, that sort of thing.

**Mark Erhardt**: Okay, two follow up questions.  Question one is, if the
intended recipient can sort of pedal this construction to its peers, what if
more than one of them accepts?

**ZmnSCPxj**: They would offer it to just one of them at a time.  And if they
reject it, then that's when you move to your next.  So, I've actually figured
out an algorithm to sort your peers on which is the best one to try first.

**Mark Erhardt**: Okay.  But if they just don't respond, you'd sort of be stuck?

**ZmnSCPxj**: Yeah, in which case you can either just reject it yourself, or you
just service it at your own note.  Or you can give up and forward it to the next
candidate.  And if they respond faster, then that's what you continue with the
protocol with.  Because obviously, you need to request this and then they need
to respond back that, "I'm okay with it, and these are my onchain keys, blah,
blah, blah".  And then, they agree on the swap.

**Mark Erhardt**: Right, so basically just offering it doesn't set them up yet
to receive it.  So, you could show it to a few people, and then whoever
responds, you actually set up the HTLCs with and communicate the onchain receive
address back to the sender?

**ZmnSCPxj**: Yes.  So, basically, my opinion here is that we got nerd-sniped
with splicing, but we should probably have focused on swapping first, because it
turns out if you go down to it, it's actually much smaller in block space to use
swapping than splicing; even this mythical batched splicing, which is
theoretical but which is probably not going to be implemented anytime soon.

**Mark Erhardt**: I must admit I haven't thought it through fully yet, but I
wonder whether there is more of an issue by having a third party involved here.
The splice of course has the nice advantage that it's just you and your channel
partner, and here, you're getting a third party involved and they are receiving
the onchain payment.  So, I wonder whether there's some things that really
changed the dynamic there.  There might be other trade-offs to compare with
splicing.

**ZmnSCPxj**: Yeah, there probably are, but I don't think there are.

**Mark Erhardt**: So, back to my second question.  It sounds like this has very
different privacy trade-offs than a splice, because now you're involving a third
party, they don't necessarily learn who the sender is, because the receiver
facilitates the material and information exchange, I guess.  But you tell
potentially a lot more people that you're trying to do this onchain payment and
the sender, or maybe actually the receiver, learns a lot more about the onchain
wallets of their peer.  And so, there might be some privacy implications here.

**ZmnSCPxj**: It might not be their first, like just because you received it
from your peer doesn't mean that they're the ones who will source it.  They
might have forwarded it from somebody else too.  So, the privacy cuts both ways,
right?

**Mark Erhardt**: Okay, all right.  I think I'd have to think more about this to
get a full sense of all of the trade-offs.  It seems like a very different
beast.

**ZmnSCPxj**: Yeah.  So, the forwardable peer swaps thing is something I've
written about before.  It's on Lightning Dev, so you'll probably need to dig
through archives to get it.  But yeah, it should be on one of the Lightning Dev
archives available.

**Mike Schmidt**: ZmnSCPxj, what do your LN friends think about swap versus
splice?

**ZmnSCPxj**: Like I said, I think we got nerd-swiped with splicing.

**Mike Schmidt**: What do they think?  Do they agree?

**ZmnSCPxj**: I don't know, man, they just want to do splicing.  They just want
to keep focusing on splicing.  But basically, in 2018, I was already bringing up
the possibility of using swaps.  Even before submarine swaps were supposedly
invented, I was already describing how we could use an onchain HTLC to rebalance
out the multiple one or more LN channels.  There's this really old 2018 post on
Lightning Dev, yeah, it's so long ago, man, come on.  And then, after that, I
went into coinswap a little bit, and that's when I figured out, "Hey, we can
actually exchange the private keys, and we can even use something like, we can
just add the private keys together to create a single key, which is basically
what you would be able to do with MuSig2 now, and taproot".  And remember, this
is, pre-taproot activation.  This is ECDSA.  But because you are working on the
private keys directly, you can actually use ECDSA.  You don't need taproot
signatures.  You can work it with ECDSA's signatures.

So, that was the context at that time because taproot wasn't activated yet.  And
I was already proposing this private key handover to reduce the protocol
complexity, like we don't need an RBF capability afterwards.  We just need to
give this key over and then the owner of the fund can RBF that transaction
directly.  They can use endogenous fees rather than exogenous fees instead of
CPFP RBF with a P2A, right?  And with these endogenous fees, it's still cheaper,
it's still smaller block space, because you don't have an extra transaction plus
an extra P2A output and P2A input.  So, those are the advantages of having
private key handover and it also ends up being an advantage of swapping over
splicing.

Splicing does also use endogenous fees, but now it's complicated.  The protocol
is complicated because now you have to keep track of multiple possible splice
transactions, because all of them have different RBF feerates, and because
they're different RBF feerates, blah, blah, blah, the protocol needs to be
updated to them.  Whereas with private key handover, it's only the one that
implements RBF that needs to worry about RBF.  The other one, if they don't
implement RBF, they don't even care.  They already handed over to private key.

**Mike Schmidt**: ZmnSCPxj, I think we covered that one pretty good.  That was
actually more interesting than I had initially thought.  I appreciate you coming
on and explaining that for us.  And, Murch, thank you for translating some of
that for us to understand a bit better.  Anything else before we wrap up,
ZmnSCPxj?

**ZmnSCPxj**: Swaps are better than splicing, yeah!

**Mike Schmidt**: He comes in with this right when we're getting splicing across
the line, and then everyone's been waiting for it.  But okay, we won't be too
mad at you, ZmnSCPxj.  Thanks for your time.  Cheers.

**ZmnSCPxj**: Bye.

_Arkade launches_

**Mike Schmidt**: Moving to our monthly segment on Changes to services and
client software.  First one, Arkade launching.  Arkade is an ARC protocol
implementation, and along with that implementation, Arkade also ships with a
bunch of different language development kits.  There's a wallet, there's a
plugin for BTCPay Server, and there's some other tooling around doing Ark-style
offchain payments.  I haven't played with it yet, but I know a lot of folks have
been highly anticipating these implementations coming out, so it's great to see.
Murch or Gustavo, any thoughts?

**Mark Erhardt**: Yeah, I've been seeing some wallet developers teasing
potential Ark integrations for LN.  There seem to be a number of people already
participating in the open beta to try out Ark.  I have a follow-up question to
you two.  Is either of you able to enumerate all the different groups that are
working on Ark at this point, because I'm losing the overview.  So, this Arkade
is from Ark Labs; and then there's, of course, the Ark project by Second; is
there third one now?

**Mike Schmidt**: Those were the two that I would have said.

**Mark Erhardt**: Okay.  I thought there was a third one for a while, but maybe
they discontinued.  Okay, just those two then.

**Gustavo Flores Echaiz**: Yeah.  I guess what might have been confusing was
also that Arkade was rebranded.  So, initially, they were just Ark Labs and then
they rebranded as Arkade.  I think there's going to be an interesting follow-up
to this topic, which is the programmable narrative around Arkade.  Because Ark
initially was simply about payment efficiency, and now Arkade is actually
presenting it as a programmable layer too.  I don't know how advanced they are
on that part of the protocol.  That's maybe an interesting topic to dig in.  But
I guess that's the differentiator and would be interesting to follow up on that.

**Mark Erhardt**: Yeah, I briefly skimmed their blog post, I didn't read it in
full, to be honest.  And I wanted to point out one more thing that they said
there.  So, they have their open beta starting.  They're especially looking at
wallet developers to play around with it, to join their chat, and to develop the
ideas for it.  And just to be clear, they also very explicitly say it's not
ready to store your life savings.  So, it's time to play around with it with
pocket money, not life savings.

_Mempool monitoring mobile application_

**Mike Schmidt**: This is the Ark reckless moment, it sounds like.  Mempool
monitoring mobile application.  This is a little one but I thought it was
interesting.  It's called Mempal, it's an Android app that surfaces metrics and
alerts about the Bitcoin Network pulling data potentially from a self-hosted
mempool server instance.  It could be interesting for node operators or
transactors who want push notifications or graphs on their mobile device.

**Mark Erhardt**: Yeah, I looked at the screenshot there and it looks like you
get easy access to the mempool size and the feerates that are projected.  So, it
might be a good way for getting very quick access to feerates without pulling up
a website and looking at it manually.  And yeah, you said it already, but by
default it integrates with mempool.space.  But if you run your own instance, it
looks like there's configuration options to instead point it at your own
instance.

_Web-based policy and miniscript IDE_

**Mike Schmidt**: Web-based policy in Miniscript IDE.  This covers a tool called
Miniscript Studio, which is a web interface for experimenting with miniscript,
and the higher-level language called Policy, confusingly called Policy.  And
there's also a blog post that walks through the features.  It's pretty well
documented, and there's provided a link to the source code for folks to run on
their own or contribute to.  Could be useful for wallet or protocol developers
designing more complex spending policies.  Murch?

**Mark Erhardt**: Yeah, so this seems to be based on Rust Miniscript in the
background.  And Ady wrote that he used sipa's miniscript page as the source of
truth.  But then also, it has already support for tap miniscript, which I think
is exciting and has been a hot-button topic lately.  So, if you want to play
around with some miniscripts and try them out, maybe keep track of how many
OP_IFs are being used by such things that you generate.

_Phoenix Wallet adds taproot channels_

**Mike Schmidt**: All right, next one.  Phoenix Wallet adds taproot channels.  A
lot of people reacting to this on social media I saw.  Phoenix mobile wallet
adding taproot channel support.  Also, a migration workflow for people who have
Phoenix wallet and existing channels.  So, it'll migrate you to these new
taproot channels in the new version, and also a cool feature for multi-wallet
support.  So, if you don't have a business wallet and you want to segregate
those funds and expenses from your personal, they have that ability.  Good to
see this trend towards further taproot adoption in LN.  Moving along.

**Mark Erhardt**: I was trying to figure out who now all has taproot channel
support.  And I think if I'm correct, it's LND and Phoenix so far, but I was
curious whether I'm missing any.

**Mike Schmidt**: LND and then Eclair/Phoenix were the ones that I knew more off
the top of my head.  If we're missing something, somebody can correct us on
Twitter, I suppose.

**Mark Erhardt**: Of course, that means Phoenix has a lot of potential channel
partners that can use taproot channels now, because my understanding is that the
vast majority of nodes on the LN are still LND.  So, anyone that joins this now
will already be able to basically use this widely from day one.

_Nunchuk 2.0 launches_

**Mike Schmidt**: Nunchuk 2.0 launches.  We've covered a few of Nunchuk's
features in this section over the years.  This is a big 2.0 release.  I think
some of these features were supported before, but specifically they have wallet
setups that can use multisig, timelocks, miniscript altogether.  I think you can
provide your own versions of these things, although I think they have some
things out of the box.  There's also this notion of degrading multisig, where
over time, the spending conditions change and broaden letting policies change
for things like inheritance setups that we've talked about before, I think, with
Liana and things like that.  So, good combination of Bitcoin tech being released
here.

**Mark Erhardt**: Yeah, again.  So, the comment, maybe to put it in context, was
there is a proposal that is trying to forbid OP_IF and tapscript for some time.
And we recently saw transactions on the network that explicitly tested in the
mainnet setups with multiple keys and decaying multisigs, and they used OP_IF in
that construction.  So, I'm not sure if this is Nunchuk, but it could, for
example, be Nunchuk final testing on mainnet and then rolling out this feature
widely to their wallet users, and that definitely clashes with this proposal to
make OP_IF consensus-invalid.  If you've ever programmed IF statements, they're
kind of pretty central to programming.  Now, with tapscript of course, you can
have many different leaves and these different leaves could encode what you
would otherwise put into IF branches.  But with something like a dozen different
projects having support for miniscript at this point, and a subset of those
having support for tap miniscript, it just seems like there would at least have
to be a lot of research and explaining of why it's the right trade-off to forbid
OP_IF.  Just saying.

_LN gossip traffic analysis tool announced_

**Mike Schmidt**: Last piece of software, LN gossip traffic analysis tool being
announced.  I think I saw this on Delving, it's called Gossip Observer, and it
collects LN gossip from multiple nodes and then produces some metrics around
that gossip.  And it sounds like, from the post, that the author is trying to
inform a potential minisketch-like set reconciliation protocol for LN, similar
to what bitcoiners may be familiar with, with the idea of Erlay, where you're
reconciling sets of transactions between nodes, as opposed to just broadcasting
all of them out.  Something similar can be done for LN gossip.  And so, I guess
step zero in that would be determine what is happening in the gossip network
now.  And so, this person has begun collecting that information.  And I believe
there was also a call to action if people also want to start collecting that
data and start sharing it, similar to what 0xB10C's done with some of the
monitoring work that he's done.  So, check out that Delving discussion, see more
about the thread and the approach there.

**Mark Erhardt**: Just a small comment, but other than you might expect at this
moment when you hear something Observer, it's not a 0xB10C project.  And this is
from JHB.  Anyway, not a 0xB10C project, but apparently his idea of what to name
things is taking a foothold in the broader developer community.

**Mike Schmidt**: Observer, so hot right now!  That wraps up our monthly
Services and clients segment.  We'll move to Notable code and documentation
changes.  I think folks are aware now since Gustavo's been making appearances on
the podcast, and I think we announced it, but he's been authoring these changes
every week for what, has it been a year-and-a-half now, Gustavo, something like
that?  So, really, not only summarizing these items, but even sourcing these
items is a lot of work.  So, we're glad to have him on to walk us through this
slew of a lot of LN changes this week.

**Gustavo Flores Echaiz**: Thank you, Mike.  Thank you for the introduction.
Thank you, Murch, for all your valuable contributions.  So, yeah, let's get
started.  A big focus on Lightning this week, specifically Core Lightning (CLN).

_Bitcoin Core #33745_

But the first one is about Bitcoin Core #33745.  Here, there's an improvement to
the new inter- process communication (IPC) for external Stratum v2 clients to
connect to Bitcoin Core.  So, basically, when an external client connects to
Bitcoin Core, it receives a template from Bitcoin Core, and then it works on the
solution.  And once it wants to submit the solution to Bitcoin Core, it
communicates through the IPC submitSolution() interface.  However, previously,
before this PR, when it did this, Bitcoin Core wouldn't revalidate the witness
commitment of this block solution.  So, if there was an issue at the witness
commitment level, for example it was invalid or it was missing, Bitcoin Core
wouldn't notice this issue, because it would only check for this during the
original template construction before shipping the template to the external
client.

So, this PR, what it does is that Bitcoin Core will now revalidate that the
witness commitment is present and is valid, once it receives the solution from
the external client.  So, it will not only validate this in the beginning when
it creates a template, but also when it receives a solution.  And this fixes an
issue where, theoretically, Bitcoin Core could accept a block that had an
invalid or missing witness commitment as its best chain tip block.  And while
this would fail to propagate, obviously, but it would still accept it in its
current chain and local chain.  So, interesting improvement here.  We've been
covering the IPC for external Stratum v2 clients for a couple of newsletters
now, but the submitSolution() interface was specifically covered because it was
added in Newsletter #325.  Any comments here?

**Mark Erhardt**: Yeah, so the witness commitment is a mandatory OP_RETURN in
the coinbase transaction that commits.  It builds basically another merkle root
over all of the witness txids in the block, and it is mandatory if you have any
segwit transactions in your block.  So, you can think of it as something of
similar importance as the merkle root in the header.  And if it were not present
and you have any segwit transactions in the block, your block is simply invalid
and will be rejected.  And so, it seems to me that someone having discovered
this either is very solid testing or someone had a bug in their block template
creation logic on the hash hashing side, not the template creation, but how the
coinbase is being constructed for the hashing operation.  And so, yeah, it
sounds like someone had a bug there and that's how they discovered that their
node locally would accept this block, and actually accept it to the best chain
tip, to be on that chain tip and start working on top of it.  So, if someone had
this bug locally, it would only hurt themselves, but they would be stuck on an
invalid chain tip and work on top of the invalid chain tip; basically forked
himself off the network until the rest of the network pulls ahead for another
two blocks, right, until someone else finds the competing block and then one
more.  So, they might lose 10 or 20, or whatever, over an hour of work until
it's discovered.

So, good that it's found this early in the experimental phase.  And we will not
accept a locally presented block in our own local chain.

**Mike Schmidt**: I'm glad you expanded on that, Murch.  I guess I just thought
that that was going to be broadcast and immediately rejected.  I didn't really
follow through that.  Yes, that local node would then continue to build on that.
Okay, good to know.  All right, that's all I had.

**Gustavo Flores Echaiz**: Thank you guys.

**Mark Erhardt**: I'm only riffing off of Gustavo's explanation here though, so
I have not fully investigated this.  So, if I'm wrong, please feel free to
correct us in this Twitter thread.

_Core Lightning #8537_

**Gustavo Flores Echaiz**: Please do.  Next one, Core Lightning #8537.  Here,
there's a limit called maxparts, which we talked about two newsletters ago, that
basically determines in how many parts a payment using multipart payments (MPP)
would split into.  So, I think the default is 100, so CLN could split a payment
into multiple parts.  However, when CLN is paying Phoenix-based nodes, there's a
limit of 6 HTLCs, or 6 parts, when a Phoenix node receives a transaction for an
on-the-fly funding, which is a type of Just-In-Time (JIT) channel.  So,
basically, this PR, what it does is that CLN sets the maxparts limit
specifically on xpay to 6, xpay being a plugin that CLN uses to pay using more
advanced pathfinding methods.  So, the limit is now set to 6 when it pays a
non-publicly reachable node, which applies to Phoenix nodes.

So, this is applied to all non-publicly reachable notes, but really the goal is
to fix an issue when paying Phoenix nodes, because the limit is inherent to them
on a specific type of transaction, which is on-the-fly funding.  However, if
routing fails under that cap, xpay removes the limit and retries.  So, in case
it wouldn't be able to do it in 6 parts, it will just retry with more parts.
Any comments here?  Perfect, let's move on.

_Core Lightning #8608_

Core Lightning 8608.  Here, node-level biases are introduced to askrene.
Askrene is the pathfinding algorithm that xpay uses when paying nodes, alongside
existing channel biases.  So, basically, what was found in an issue that this PR
fixes was that a node was unable to make a payment and it would try different
channels to succeed that payment.  And then, someone in the comments suggested,
"Can you run this command where you basically just disable a specific node?"
And once they ran that command, the problem was fixed.  So, what was found here
is that previously, CLN would try a channel, and if that channel failed, it
would try another channel.  Even if the problem was inherent to the node, it
wouldn't penalize that note, it would just penalize that channel.  So, it would
go through multiple channels without understanding that the problem was that
peer node.

So, what this PR does is that it allows CLN, through a new RPC command called
askrene-bias-node, this command is added to favor or disfavor all outgoing or
incoming channels of a specified node.  So, once CLN noticed that the issue is
the node not the channel, it will just disfavor all of the node's channels.
Also, a timestamp field is added to the biases so that they expire after a
certain period.  It's just normal that when, let's say, you had an issue with a
channel or a node a month ago, well, it expires because the network is in
constant evolution.  So, an interesting fix here, very much into the details,
but interesting still.  Any other comments here?  Perfect.

_Core Lightning #8646_

Core Lightning #8646.  Here the reconnection logic of spliced channels is
updated to align with the proposed specific changes in BOLTs #1160 and BOLTs
#1289.  So, here the goal is to improve how peers synchronize splice state when
they disconnect and reconnect and communicate what needs to be transmitted.  For
example, if a node disconnects before communicating something, but he thinks he
communicated that to the other node, when they reconnect, they specifically
share all what they communicated or what they received.  And that allows a node
to know, "Hey, I actually didn't receive this, which you assume that you sent
me, but I didn't receive it because you disconnected at that moment, so please
resend it to me".  So, basically, these proposed specific changes in the BOLTs
repository propose these new TLVs (Type-Length-Value) attached to the
channel_reestablish communication so that nodes can reliably synchronize state
and communicate what needs to be retransmitted.

This is a breaking change for splice channels, so it's important that both sides
update at the same time to avoid disruptions.  Also, in Newsletter #374, we
covered a very similar change to LDK.  Yes, Murch?

**Mark Erhardt**: Yeah, so I looked at this one a little bit because 'both sides
must update simultaneously' sounds kind of bad.  And I was wondering whether you
know, does this affect only peers that have currently a splice channel, so
they're in the process of a splicing operation, or does it affect any channels
where both sides agree that the splicing feature is active?  So, what I was
concerned about specifically is, let's say you have the node, Alice, and Alice
has a peer, Bob, and Bob has another peer, Carol.  And if Alice and Bob have to
upgrade in order to update a channel, it might propagate because Bob and Carol
might also have a spliced channel.  And now, Alice wants to update and Alice and
Bob have to update and Bob and Carol have to update.  And then, whoever has
spliced channel peers with Carol also has to update.  And it's sort of would
maybe have this chain of infection of people that all have to update at the same
time, or it causes some issue.  So, have you looked further into this
simultaneous update?

**Gustavo Flores Echaiz**: So, from what I read on the BOLTs PR, basically it
says that, well, Eclair and CLN are the only ones that have support for
dual-funding, so it would only affect those implementations, and they are
incompatible on the reconnection implementation.  So, what it says here is this
edge case only creates an issue when nodes disconnect after exchanging
transaction complete, but before receiving signatures, which should happen very
infrequently.  So, I guess this is just an edge case that isn't much to worry
about.  But yeah, this is as much as I can tell you.

**Mark Erhardt**: Okay, good.  It sounds then that you actually have to be in
the process of splicing, which usually should be resolved within a few minutes.
And only if you disconnect right during that and you disagree on the version of
what should happen then to recover from that, then you have an issue.  So, this
sounds a lot less scary now that we've talked about it.

_Core Lightning #8569_

**Gustavo Flores Echaiz**: Yeah, thank you for digging into that question.  That
was definitely important to get into more detail.  Core Lighting #8569 adds
experimental support for JIT channels, as specified in LSPS2 or BLIP52.  It adds
it in the mode where the LSP trusts the client and it also adds it without MPP
support.  So, this feature is gated behind experimental flags and represents the
first step towards providing full support for JIT channels.  So, I think a few
newsletters ago, we covered how LDK expanded their implementation from
lsp-trusts-client to client-trusts-lsp.  And basically, what this means is that
in the lsp-trusts-clients mode, basically the problem is that the LSP trusts the
client to actually claim their payment once the channel is opened and the
payment is forwarded.  So, the LSP will open a channel that the client might
never claim the payment for, and the LSP will reserve liquidity and pay onchain
fees for a channel that might never get used.  And that is the mode which CLN
has implemented now, but like the note suggests, there will be a follow-up where
the other mode will be implemented as well.

**Mark Erhardt**: Just to remind ourselves, I believe JIT channels are channels
that are created because the cost of an onchain payment to create the channel is
less than the expected revenue of having that channel.  So, for example, when
someone is asked to forward a multi-hop HTLC for a substantial amount and they
can't route it because they don't have enough liquidity, it might be attractive
to the LN node operator to open another channel just in time for routing this
payment to collect the fee on that payment.  And I think that's where originally
the idea comes from.  And now, that might be actually very interesting with the
onchain fees minimum having recently been slashed by a factor 10.  So, I wonder
whether that would lead to more interest in JIT channels right now.

**Mike Schmidt**: I just clicked into BLIP52 because I thought I remembered
something different, "Allows a client with no Lightning channels to start
receiving on Lightning, and have the cost of their inbound liquidity be deducted
from their first received payment", which I think is maybe another way of saying
what you said, Murch?

**Mark Erhardt**: Okay, maybe I misremembered.  I remember maybe the original
idea for JIT channels, where nodes would basically create new channels to better
relay, and it looks like this channel being created to receive funds also falls
under the broader umbrella of JIT channels.  So, what Mike said sounds
plausible.  Forget what I said.

**Mike Schmidt**: Well, I think what you're saying is the parent set of use
cases, and this is one specific case in which it's the initial funding that a
client wants for their LN balance.  And so, maybe it's a subset of that
technique.

**Gustavo Flores Echaiz**: Yeah, well, I think it's also important to note the
difference between JIT routing and JIT channels.  And JIT routing, I think, is
specifically what you said, Murch.  And JIT channels are the channels you open
to receive on LN when you have no LN channels in advance.

**Mark Erhardt**: Yeah, I think you're right.  JIT routing is what I was
thinking of and it was not opening channels, but it was rebalancing in order to
make a payment.  You rebalance, you pay cost to rebalance, but maybe routing a
second payment to yourself through a cycle to rebalance a channel, so you'll be
able to forward an HTLC, and rebalancing just in time at a cost for you because
you get more fees.  That makes more sense too, because routing is usually on the
order of seconds.  And if you need to open a channel in order to route, that
wouldn't open up until a few confirmations later, which is the whole point of
BLIP52, "Oh, we can make this payment because the LSP trusts the client to
eventually come online and do the other side of this channel that the LSP holds
on for the recipient".

_Core Lightning #8558_

**Gustavo Flores Echaiz**: Totally.  So, Core Lightning #8558 adds a new RPC
command called listnetworkevents, which displays the history of peer
connections, connection attempts, disconnections, failures, and ping latencies.
It also introduces a config option called autoclean-networksevents-age that
controls how long network event logs are kept.  The default is 30 days.  So,
this is useful to know the ping latencies with your peer nodes.  So, peer
latency, there's another method called gossipd.  So, combined with gossipd
connecting to random peers, what the PR description says, "This gives us an
indication of peer latency", will be useful for those that like to analyze just
network behavior and peer behavior in general, but overall useful to have a
better view of your peer communications and latencies.  Any comments here?

**Mike Schmidt**: Seems pretty straightforward.  I guess it's just sort of like
a long specific to network activity, P2P activity, so makes sense to me.

_LDK #4126_

**Gustavo Flores Echaiz**: Yes, exactly that.  So, now we move on to LDK.  LDK
#4126 introduces a new authentication verification on blinded payment paths,
called ReceiveAuthKey, which replaces the older per-hop HMAC/nonce scheme that
was covered in Newsletter #335.  So, from what I understand here, because it's
actually quite complex, now when you want to verify a blended payment path,
instead of attaching a per-hop HMAC, this only does like a whole payment path
verification that has a way smaller payload.  So, the final received TLVs are
reduced considerably in size and this makes blinded paths lighter.  This is also
something that was implemented already to message blinded paths.  And this is
also the basis to introduce dummy payment hops, which are additional either
message hops or payment hops to even further obfuscate the blinded payment path,
because this minimizes the per-hop authentication data.  So, it allows to offer
dummy hops in a compact manner.  Overall, it just reduces the size required to
authenticate blinded payment paths.  Any comments here?

**Mark Erhardt**: So, basically, I think the onion is limited in size, like the
whole package that you might use to propagate a multi-hop payment.  And it is
also padded.  So, it's always the same size, which is why you would want it to
be a limited size.  And if you use less of it for each hop, you have more space
to do dummies, to do obfuscation.

**Gustavo Flores Echaiz**: Exactly, that's how I understand it too.  So, yeah,
interesting improvement here that opens new use cases, because of the data
shrinking and the payload being more efficient.

_LDK #4208_

So, we move on to LDK #4208.  Here, this is a follow-up to something we talked
to two newsletters ago, where the weight estimation in LDK will now consistently
assume 72-byte DER-encoded signatures instead of using 72 in some places and 73
in others.  The logic behind this is that 73-byte signatures are non-standard
and LDK never produces them.  However, this contradicts the change that Eclair
did two newsletters ago, that actually their motivation was to sync with LDK on
73 bytes, but now LDK went the other direction and went from 73 to 72.  The spec
says 73 because you always have to assume the highest amount to be able that
you're never underpaying fees.  But yeah, we discussed this, like we said I
think in that episode.  They should talk to each other and this update should
also be made at the spec level instead of at the implementation level.  Any
comments here?  Awesome.

_LND #9432_

We move on with LND #9432.  Here, a new global configuration option is added,
called upfront-shutdown-address, which allows you to specify a default Bitcoin
address for cooperative channel closures.  This can also be overridden when
opening or accepting a specific channel and specifying an address for that
channel.  So, this builds on a feature that has long existed in LND and other
implementations that are specified in BOLT2, where you just specify an address
where your cooperative channel closure will send the bitcoin to.  But here, this
is brought as a new global configuration option, so you don't have to specify it
per channel now.  You can just have it on your config once, inserting your
config once, and it applies to all your channels.  Any comments here?

**Mark Erhardt**: I'm a little confused at this feature.  If you have a single
address that you would close multiple channels to in case of a shutdown, that
leads to address reuse.  So, is this just an address that is used to generate
more addresses from, or is actually what they're intending to do here is, if you
shut down a bunch of channels, you always use the same address?  I must be
misunderstanding that because that sounds terrible.

**Gustavo Flores Echaiz**: Yeah, it does when you put it that way.  I don't see
any indication that it would be otherwise, from what I understand.  It's exactly
that.  But yeah, you can always override with another address.  I guess this is
just an emergency address that you ship your channel closures to, but definitely
important to consider that channel address reuse is an issue.

**Mark Erhardt**: So, hopefully every time you do open a channel, you actually
override it and set a different unique address per channel.  But this is just
sort of a node identifier then.  Wouldn't that also mean that if you ever
communicate that, all of your peers would always know if one of your other
channels closed?  But yeah, okay, I have questions, but I don't want to dig into
it right now because that will take time.  But yeah, as usual, you can explain
that to me below.

**Mike Schmidt**: Yeah, I think there's a discussion in the referenced issue in
the PR, which is LND #7964.  And it does note what you say, the privacy
implications, but I think they're talking about, "A fundee needs to set up a
channel acceptor to specify a custom address.  This can be cumbersome,
especially in the case where a remote signer is used for a hot-cold wallet set
up.  We could instead config this shutdown address in lnd.conf".  So, I'm sure
there's more information in these threads, but maybe folks can get some more
information there digging into the issue that's closed by that particular PR.

_BOLTs #1284_

**Gustavo Flores Echaiz**: Yeah, perfect recommendation.  Thank you, Mike, and
thank you, Murch, for pointing that out.  We move on with the last two of this
section, which are BOLTs updates.  The first is BOLTs #1284, which updates
BOLT11 to clarify that when an n field is present, which I think it's the public
key field, the signature must be in a normalized lower-S form.  However, when
the n field is absent, so the public key is absent, and you wish to do public
key recovery, then you have to either accept high-S or low-S signatures to be
able to derive the public key from those signatures.  This has been covered in
Newsletter #371 and #373 because LDK and Eclair took a step ahead and actually
implemented this before it was merged in the BOLTs repository.  So, just a
clarification on this end that implementations had already taken a step forward
on.  Any comments here?  Go ahead, Murch.

**Mark Erhardt**: Yeah, I think we covered the high-S and low-S signatures when
we talked about this a couple of weeks ago.  But just a reminder, high-S is just
not happening very often at all and shouldn't be done.  It just wastes a byte at
the cost of trying a second signature in case it happens.  So, everybody at this
point should do signature grinding.  Well, actually, signature grinding usually
refers to the R-value, but the S-value had been non-standard for almost a decade
now.  If you're still doing high-S you're, you're doing something weird.

_BOLTs #1044_

**Gustavo Flores Echaiz**: Thanks for pointing that out.  Last PR, BOLTs #1044.
Here, the attributable failures feature is finally merged in the BOLTs
repository.  So, this is actually a big achievement.  How this protocol works is
that attribution data is added to failure message so that the hops can commit to
the message they send.  And if a node corrupts a failure message, which they
obviously can, then the sender can identify and penalize the node later.  So,
this just allows for better attribution of failure messages and attribution of
whoever corrupts a failure message, trying to hide the history of the failure
message or that they are behind it.  So, Eclair and LDK have already started
work or have already implemented this.  We covered that in a couple of
newsletters ago already, specifically #249 and #256.  But if you want to learn
more about the attributable failure topic, well, we have a topic page, but it
was also covered in Newsletter #224.  Any comments here?

**Mark Erhardt**: Yeah, so attributable failures is something that we've
reported on a lot.  And as you can see, it being described in Newsletter #224,
this has been an ongoing effort for over 160 weeks, so, that's almost three
years.  And the PR to the BOLTs repository that got merged was opened in
November 2022.  So, this has been a super-long-running process and it's kind of
cool that it finally got in.  At times, it seemed like there might be too much
pushback or people didn't see the sufficient value in it, but it's awesome that
it's now in the BOLTs spec.

**Gustavo Flores Echaiz**: Agreed.  Thank you for that extra context.  And that
covers this section and the whole newsletter.

**Mark Erhardt**: I kind of want to leak one that we'll probably cover next
week.

**Mike Schmidt**: I know what you're going to leak.

**Mark Erhardt**: Did you see this this morning?

**Mike Schmidt**: Seven hours ago.

**Mark Erhardt**: Yeah, cluster mempool got merged.  So, that's pretty cool.
We'll talk about that next time.  So, you'd better rejoin us then.

**Mike Schmidt**: Gustavo will have that fully covered for the newsletter coming
up Friday.  Gustavo, thanks for walking us through on the podcast those PRs for
this week.  We want to thank also Antoine and ZmnSCPxj for joining us for the
News section earlier.  Murch, thanks for co-hosting as well, and we'll hear you
all next week.

**Mark Erhardt**: Hear you soon.

**Gustavo Flores Echaiz**: Thank you guys.

{% include references.md %}
