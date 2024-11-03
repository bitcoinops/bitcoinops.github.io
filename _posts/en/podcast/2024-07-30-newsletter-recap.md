---
title: 'Bitcoin Optech Newsletter #313 Recap Podcast'
permalink: /en/podcast/2024/07/30/
reference: /en/newsletters/2024/07/26/
name: 2024-07-30-recap
slug: 2024-07-30-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt discuss [Newsletter #313]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-6-30/384054809-44100-2-147dd2c2c83ef.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #313 Recap on
Twitter Spaces.  Today, we're going to talk about several discussions around
free relay and fee bumping; we have nine interesting Stack Exchange questions
and answers; and then we have our regular weekly segments on releases and
notable PRs.  No special guests this week, just Murch and I.

_Varied discussion of free relay and fee bumping upgrades_

We have one news item that has four lengthy bullet points associated with it.
The news item is titled, "Varied discussion of free relay and fee bumping
upgrades".  And there was a series of mailing list posts on the Bitcoin-Dev
mailing list talking about free relay.  We can start with the first one here
titled, the first bullet anyways titled, "Free relay attacks".  Murch, I think
maybe it makes sense to define free relay first, and maybe the simplest example
would be me broadcasting a transaction that pays zero transaction fees to the
entire Bitcoin P2P Network, which was actually something that was allowed pretty
early on in Bitcoin.  So, I broadcast my transaction with no transaction fee and
I'm able to broadcast that for free.  If I can, I can tie up thousands or tens
of thousands of nodes, resources, including bandwidth, all at no cost to
myself.

So, more recent versions of Bitcoin Core, and I believe other Bitcoin node
softwares, prevent that sort of DoS attack by requiring transaction fees of at
least 1 satoshi for each 1 virtual byte (1 sat/vB) of relayed data.  So at that
point, there's at least some payment and thus some defence against this sort of
bandwidth-wasting attack, that the person broadcasting this needs to pay
something now, so it's some deterrent.  And then, the same applies to
transaction replacements that must pay 1 sat/vB more in fees than the
transactions that they replace.  Murch, I'll pause there as you may have some
clarifying context as well before we move on.

**Mark Erhardt**: I would actually argue that when you were allowed to broadcast
zero fee transactions, you weren't wasting bandwidth, because they would also
get mined.  So you weren't wasting bandwidth, because people would need to have
that transaction eventually anyway.  But in general, the gist seems right.  So
free relay attacks are a form of bandwidth-wasting attacks.  The general idea is
that you're able to broadcast data to the network that gets relayed but never
gets mined, or pays significantly less than what we consider to be the minimum
relay fee.  And so, well, that wouldn't be a free relay in the sense, but you
get leverage on the money you pay.  Yeah, so far so good, I think.  Back to you.

**Mike Schmidt**: All right.  Yeah, I'm just going to try to guide us through
these bullets, but I'll be leaning on you as well.  So, the mailing list post
and disclosure that we covered this week from Peter Todd is an attack that takes
advantage of differences in mempool policy between minor nodes and other node
operators on the network.  The observation here is that many miners seem to be
running with mempoolfullrbf, while Bitcoin Core's default and thus many other
users on the network are not running mempoolfullrbf.  Murch, I'll pause here and
maybe you can explain what mempoolfullrbf is for the audience, and then we can
move along.

**Mark Erhardt**: Sure.  So, I think about eight years ago, opt-in full RBF was
introduced.  It was first implemented in Bitcoin Core, then later a BIP was
written.  The two never quite 100% matched up, but that's beside the point.  The
idea is, you would be able to signal whether or not you intend to be allowed to
replace a transaction.  And only transactions that opted-in to be replaced by
nodes that implemented BIP125.  So, this was sort of an unstable gentleman's
agreement because naturally, it would be preferable for miners to always take
whatever the best transactions are that are being offered to it.  So at some
point, people were like, "Why do we even do this opt-in?  It's a fingerprint, it
is also not enforceable, we should always be accepting the best available
transactions".

So, there was a lobbying effort about, well, it resurged some two,
two-and-a-half years ago, and eventually Bitcoin Core added a startup option to
the node, which is mempoolfullrbf, which means if you start your node with that
configuration option activated, it will accept any replacement, even if the
original did not signal replaceability.  It will still enforce the minimum relay
transaction fee requirements.  So, a transaction to oust a predecessor would
still need to pay more absolute fee and a higher fee rate in order to be
replaced, accepted into the mempool and forwarded.  Well, replace the original,
not be replaced.  Yeah, so mempoolfullrbf was added in Bitcoin Core 24, And
there was a huge amount of drama around then with people exclaiming that this is
destroying zero-conf, which had been very controversial before, as in something
that you shouldn't be able or shouldn't rely on, but also seemed to work for a
long time.

So, it turned out that a bunch of people configured their nodes to support
mempoolfullrbf, and especially the miners appeared to have adopted
mempoolfullrbf with over 90% of the hashrate.  And this has been replicated
meanwhile, people have just been broadcasting transactions, wait two minutes,
replace it with a newer transaction; both of them had been paying enough fees to
be in the next block; and then the measurement was that across a day with, I
think, 120 transactions, about 118 of them, the replacement got mined instead of
the original.  So, there's evidence that almost all miners are using
mempoolfullrbf.  They accept any replacement, and therefore we have a strange
situation where now a significant portion of the nodes on the network have a
different mempool policy than the miners.

The funny thing is, if it were just split evenly across the entire population,
including miners and relay nodes, it would depend on who finds the next block to
see who of them behaved correctly in that sense.  Because what relay nodes want
to do is they anticipate the block that will be published in order to do good
feerate estimation and be most effective at relaying that block; they want to
have the things that are most likely to be mined, right?  And so, if half the
miners had one policy and half the miners had another policy, and half the nodes
on the network that are not mining had one and half had the other, half the time
either side would be right.

In this case, though, it looks like there's almost full adoption among miners of
one policy and partial adoption among nodes in the network, and this leads to a
bandwidth-wasting vulnerability in that you can broadcast a transaction that
gets relayed by -- well, the first transaction gets relayed across the entire
network, and then after that, you stage a full RBF replacement with the miners
that they will eventually mine.  And meanwhile, you can set off a series of
replacements among everyone else that doesn't do full RBF.  They will relay all
of these replacements and waste some bandwidth, but eventually miners will mine
the original full RBF transaction that you had already previously broadcast.  So
this is a little funny in the sense that among the miners, you only send them a
single update and it improves their block template.  And among everyone else,
you send them several updates and each of them pays for itself and improves
their block template.  But then, of course, you obsolete what they have in their
mempool by getting the miners to mine a different block.  So it's a fairly weak
bandwidth-wasting attack.

I feel like it's pretty obvious that if there's two different mempool policies
on the network, that you can send transactions that only propagate among one or
the other part of the population.  That doesn't seem too astonishing.  So, yeah,
anyway, I think at this point, I, for example, am convinced that we should
probably turn on mempoolfullrbf on Bitcoin Core by default, because that is what
we expect in blocks to happen, so we should be following by default the same as
the miner population.  I think that's most what I wanted to say about that.  Did
I miss anything?  Any follow-up questions?

**Mike Schmidt**: I have a follow-up question, probably just my own clarity
here.  So, the attack involves broadcasting a non-RBF-signaling transaction
initially, and then help me understand, there's a mempoolfullrbf, so there's a
replacement transaction that's sent to miners, and the miners are happy to get
that because they're not relying on BIP125 to replace a transaction, so they
take that.  Now, what transaction is then relayed to relaying nodes that don't
support mempoolfullrbf that would be discarded?  I don't understand that part.

**Mark Erhardt**: Right, okay, so let's call the first initial transaction,
transaction A.  Transaction A, the original, does not signal replaceability.
And then a transaction A', with a higher feerate conflicting with transaction A,
is broadcast.  So, nodes that do not have mempoolfullrbf active will reject that
as an invalid replacement.  Nodes that do have mempoolfullrbf active will accept
that, so it is propagated to the miners, and miners now have A'.  And the series
of transactions that you can now broadcast to the rest of the node population
is, you create a child B of transaction A, not A', but A, the original, and
since the non-full-RBF nodes have transaction A in their mempool, they will
accept the child of transaction B, whereas the miners don't know the input and
will reject it.

So now, you can replace transaction B with B', B2', what is that, secundus?!
B<sup>2</sup>, B<sup>3</sup> and so forth.

**Mike Schmidt**: Okay, that makes a lot of sense.

**Mark Erhardt**: However, of course, if the parent and child become juicier
than A', the miners that run mempoolfullrbf will eventually oust A' that way,
right?  So you can only increase it to some extent until you catch up with
whatever you staged with the miners.  So in a way, you're still, at least in one
dimension, not able to pay more or send more data than what was staged with the
miners.  But you could have a very large transaction fee, so there's a big
factor involved here.

**Mike Schmidt**: Okay, thanks for explaining that.  I understand.  So, that
covers the first bullet titled, "Free relay attacks.  And the second bullet from
the newsletter was, "Free relay and replace-by-feerate", and this covers a
proposed idea from Peter Todd of replace-by-feerate (RBFr), which we covered in
Newsletter and Podcast #288.  The proposal had the goal to escape pinning
attacks by using a new set of transaction replacement policies.  I think there
was two variants.  One was pure RBFr, and one was one-shot RBFr.  And one
criticism of RBFr was that it enabled free relay.  But Peter Todd points out
that a similar amount of free relay is possible through the attack that we just
talked about in the previous bullet.  So, he argued that concerns about free
relay should not block adding his RBFr feature that could be useful for
mitigating these types of transaction pinning attacks.  Murch, did I set the
stage right there; and if so, what are your thoughts on that?

**Mark Erhardt**: Well, I looked at a previous version of the proposal and I
found that it has a completely new source of free relay.  That original proposal
allowed to create a cycle of transaction that you could infinitely replay
without anything ever getting mined, except for maybe a very small transaction
occasionally.  I think that has been addressed by follow-ups of this proposal,
but it still seems to me that this introduces a new source, a different new type
of free relay and it's baked into its design, and it's also there if everybody
has the same mempool policy.  Clearly, we do not standardize mempool policy in
the sense that we force everyone to have exactly the same mempool policy.  It's
impossible for everyone to have the same mempool; we would need a consensus
mechanism to sync up all the mempools.  And the consensus mechanism that we use
in Bitcoin is actually after the mempool when we publish blocks.  So, it would
be like bootstrapping your consensus mechanism with a consensus mechanism ahead
of it, which is not something that we're pursuing.

So, my criticism of RBFr would be that you can reduce the overall fees in the
mempool by replacing a bigger transaction with a smaller transaction at a higher
feerate.  So, the transaction with the higher feerate might be higher up in the
list of priority, but overall the fees in the mempool would have gotten reduced.
It overall just doesn't seem like a convincing proposal to me, especially with
cluster mempool being on the horizon, which seems to me a much more holistic
revisit of the same sort of problematic.  So, I'm just very unconvinced by the
whole RBFr approach.  And just because there's some free relay that is very hard
to address, like people having different mempool policies or being able to
broadcast a low feerate transaction that times out or gets evicted before it
gets mined, these are vulnerabilities or behaviors that we afford ourselves for
the network or us to be able to see what transactions are being promised or
announced on the network.

However, that doesn't seem like a good reason to just throw the whole concern
out in the wind and allow any type of free relay, just because we already have
some other issues that are not simple to address.

**Mike Schmidt**: Murch mentioned his comments on Peter Todd's RBFr proposal
that was also in #288, where Murch responded there.  It sounds like some of the
criticism there was potentially addressed.  Also, Murch mentioned in his
comments there that RBFR has free relay sort of built into its design versus
other free relay problems that could be solvable in Bitcoin Core.  And Peter
Todd disagrees with that and I encourage folks to click on the link in the
newsletter; Todd "disagreed" to get his perspective on things.

All right, moving on to the third bullet of this news item which is titled,
"TRUC utility", and in this part of the writeup, Peter Todd contrasts, RBFR with
TRUC (Topologically Restricted Until Confirmation) transactions, previously
known as v3 transaction relay.  And it seems, Murch, from my reading here that
the crux of this part of the discussion is that RBFR relies on a reliably sorted
mempool, which in our current mempool data structure, the sorting is not
reliable, which is why folks are working on the cluster mempool which you
alluded to earlier, which would allow for a reliable sort order to the mempool.
Do I have that right?

**Mark Erhardt**: My understanding is that one-shot RBFr, which is a variant
proposed by Todd later, only accepts RBFr replacements in the top block or maybe
the top two blocks, and that is not inherently something that we can just read
off of the mempool data structure right now.  We would have to build a block
template each time when we evaluate a replacement, and building block templates
is not very cheap.  In the cluster mempool proposal, once we have that, each
transaction is sorted in its cluster in a specific position, because we track
transactions in the context of everything that is related, which is the cluster,
and we remember in what order we would mine every transaction in each cluster.
And that allows us basically to do a merge sort on the clusters and makes it
very easy for us to read off what the top block would be and what the feerate
would be of every transaction where it gets mined.

So, I think it would be fairly expensive to evaluate whether or not replacement
only replaces transactions that are not in the top block.  And, well, if we are
doing cluster mempool anyway, then I would suggest that we just do TRUC
transaction, which seems way more compatible.  We do have a question from the
audience.

**Mike Schmidt**: BitPetro, do you have a question?

**BitPetro**: No, I'm just joining and listening.

**Mike Schmidt**: Okay, you had requested speaker access.  If you have
something, let us know.  We're going to move on with the newsletter though.

Murch, we talked about cluster mempool and RBFr and TRUC transactions, which
sort of leads to the fourth bullet from this news item, which is titled, "Path
to cluster mempool", which discusses replacing the CPFP carve-out rule
(CPFP-CO), which is used in Lightning via anchor outputs.  I don't know, Murch,
if you want to get into what carve-out is, if that's germane to this bullet
point?

**Mark Erhardt**: Sure, I can give it a try.  As most of you hopefully know, the
mempool policy of Bitcoin Core, by default, limits the size of ancestries and
descendant constructions.  When you add a new transaction to the mempool, if it
has already more than 25 ancestors, it will not be accepted.  And here, ancestor
counts the transaction itself.  So really, if there are 24 ancestors already, it
will get accepted; if it's 25, it will be rejected.  Vice versa, if it causes an
existing transaction in the mempool to have more than 25 descendants, it will be
rejected.  The same is true for ancestries and descendants with a limit of 101
kilovbyte in the mempool.

Now, there is a problem here for smart contract protocols like Lightning, where
you have a counterparty that is potentially interested in making it impossible
for you to broadcast your own child transaction in order to CPFP the
confirmation of something.  You could, for example, as the counterparty that is
attacking here now, just chain off 25 transactions from a commitment
transaction, make some of them maybe large, but all of them low feerate, and it
would prevent the defender from CPFP-ing the commitment.  So there's a carve-out
that a single time another child transaction can be added to the top of the
chain, like the commitment transaction directly, only if there's a single
ancestor and only if there's no more than one child transaction to that
transaction already, you can add a 26th transaction and it can have up to 10
kilobytes, which I think, funnily enough, was proposed to be 1 kilobyte, but
somehow was implemented with a 10x.

This carve-out is a bit of an ugly hack because it breaks the limit that is
established in other ways, and it just allows this extra transaction in order to
give both parties the ability to always have a say in commitment transactions.
So, the problem with cluster mempool is, clusters are limited in all ways, like
either child or parent relationships, and then transitively, their children and
parents, and their children and parents, and their children and parents.  So,
establishing a carve-out like that would always break the cluster limit, and it
would be, like, which of the ancestor transactions that don't have any parents
gets a carve-out, and how often is sort of -- it just doesn't translate to
cluster mempool, the carve-out.  So, there is a concern here that Lightning
commitment transactions in cluster mempool would no longer enable both parties
to have a say in the transition phase.  And that's why, well, if the carve-out
goes away, we need a different mechanism intermittently, because we can't have
the carve-out before we roll cluster mempool out.  Or, once cluster mempool
rolls out, the carve-out is gone, but it'll not be adopted 100% by the network
overnight, so we need a transition phase solution.  Sorry, that was very
complicated!

**Mike Schmidt**: No, that was great.  And so, this last bullet point covers how
you might transition away from carve-out and the two different approaches.  One
is discussion around RBFr and one-shot RBFr, combined with package relay, might
be able to replace carve-out without requiring changes to Lightning software.
But one-shot RBFr depends on this learning the top portion of the mempool
feerates from something like cluster mempool.  So, those would both have to be
deployed at the exact same time, in order for one-shot RBFr to be the solution
for carve-out that you mentioned.  And yeah, go ahead, Murch, and then we'll
jump to the TRUC version.

**Mark Erhardt**: Yeah, I think it's sort of the other side doesn't hear.  There
are people that have been working for four years on proposals here.  They're
heavily networked up with LN developers and have discussed back and forth which
solutions would be acceptable.  And then there's also one person that is
publishing an alternative idea that doesn't seem to be working with other people
on their idea and constructively contributing to the debate.  I think we
sometimes have to call out that just incessantly reposting your idea over and
over again, and then making drama around small problems in order to get
attention to it, is not perceived as constructive by other participants in this
discussion.  It feels like an unconstructive way of going about this and it
seems to be wasting a lot of time.  I don't think that these two ideas have an
equivalent pedigree and effort, and I wish we wouldn't spend as much time on it.

**Mike Schmidt**: Maybe we can contrast the one-shot RBFr replacement for
carve-out with TRUC's potential approach to phase out carve-out, which is
potentially through imbued TRUC transactions.  We talked about some of this in
previous newsletters.  I think we had #286, #287, and #289 listed.  I don't know
exactly which one talks about imbued truck transactions, but Murch, maybe you
want to touch on that approach briefly, and then we can wrap up this news item.

**Mark Erhardt**: So, the idea behind TRUC transactions is that you opt into
limiting your topology while your transaction is unconfirmed.  So, you only
allow a single child and single parent, and they are restricted in size, and
this is perfectly acceptable to the Lightning use case and endorsed by the
Lightning implementers as a good way forward.  And then, you use package relay
on this two-transaction package in order to ensure that the best variant of this
propagates, including that we use sibling eviction on the child.  If there's a
second child posted that is higher feerate and higher fee and should oust, like
it's more attractive than the first child, even if they might not conflict
directly, we accept the better child into our TRUC transaction package.

So, this solves broadly most of the pinning concerns around commitment
transactions.  It opens the door to a better anchor design and it limits the
amount of data that can be broadcast by very severely limiting these
transactions in weight.  Yeah, I think that's the main points.

**Mike Schmidt**: Excellent.  Well, I think we can wrap up the news section then
and move along to our monthly segment on selected questions and answers from the
Bitcoin Stack Exchange.  We have nine this month.

_Why is restructure of mempool required with cluster mempool?_

The first one is, "Why is restructure of mempool required with cluster mempool?"
And I think folks should click into the newsletter and look at, Murch, your
answer here.  But part of our discussion in the first news item actually covered
a lot of this, in that the data structure is not symmetrical in terms of block
template building versus eviction.  And my favourite thing, I think it was
Pieter Wuille last week, and he said it before, that the best transaction, in
terms of what should be in a block for a miner in the current mempool data
structure, actually might not even get mined, and if I recall correctly, may
even be evicted from the mempool.  So, Murch, maybe do you want to explain any
more of that, or do you think we've talked enough about cluster mempool?

**Mark Erhardt**: Yeah, I think, well, it's heavily related to the previous
section of the newsletter, but it's also different in the sense that, so the
current data structure, we haven't really gotten into what the current data
structure does.  The current data structure is based around ancestor sets.  So,
for each single transaction, we track the transaction in the context of its
ancestry.  Now, there can only be a single leaf in this data structure, right?
You're looking at the transaction and its ancestors, so there can only be
parents of it and grandparents and so forth, no cousins or siblings, right?

So, one of the issues, for example, that should be pretty obvious is, if there's
two CPFPs that are trying to bump the same parent transaction, think for example
a big batch transaction from an exchange with a ton of withdrawals paying out to
200 customers at once, and some of them were withdrawing because they
immediately wanted to spend.  So when they see the transaction, they attach a
child transaction to make the payment that they were withdrawing the money for.
And now, if there's like five CPFPs, each of these will form a separate ancestor
set, and these ancestor sets will queue in competition to each other in the
mempool.  The one with the highest ancestor set feerate will get mined first,
and then suddenly all the other children that had been paying more than the
parent transaction have humongous feerates in the context, because they are
unburdened from the parent.  And so, cluster mempool would treat all of these
children and the parent transaction as a single cluster, and it would recognize
that all of these children together collaborate in bumping the parent and would
queue the chunk, we would call it in the context of cluster mempool, at a higher
feerate.

Also, the other problem here is if you pick the first ancestor set with the
highest feerate child into the block, you have to update all of the other
ancestor sets of the other children that also had the parent transaction, the
batch withdrawal in their ancestry, right?  So, the ancestor sets in the current
data structure, they overlap, and to clean that up, every time you pick into the
block, you have to update all of the other related transactions and reduce their
ancestor sets to the remaining constellations.  In cluster mempool, because the
clusters are already linearized and you know which parts of the cluster will be
picked into the block together, you do not have to update any of the rest of the
cluster, you have already calculated their effective feerates.

So, maybe also to be clear, cluster mempool is by no means a necessary update.
It's just a way better abstraction that people came up with that simplifies a
lot of problems, and especially makes it possible for the first time to properly
evaluate bigger packages in comparison to each other. Previously, it was
extremely complicated to consider whether a package of transactions should
replace some other package of transactions, because in the ancestor set context,
they might affect a bunch of different ancestor sets that might sort differently
before and after the replacement and it was complicated and computationally
expensive to comprehensively evaluate whether something was actually improving
the mempool.

In cluster mempool, when we have essentially a total order on the mempool, we
know exactly in what order the replacement and the original would sort, and then
we can define them in a so-called feerate diagram, which seems like a very
useful metric.  And maybe if I may, this ties closely into what you said
earlier.  In the ancestor set model, when we evict, we use the descendant-set
feerate as a heuristic to judge what might be mined last.  But if a transaction
has a number of terrible children, it might have a very low descendant feerate,
even though maybe one of the children has a very high fee, and that child might
have a great ancestor set.  So, you can indeed have an ancestor set that is up
for being in the next block due to a very high feerate child, but its parents
are part of a descendant set that has a terrible descendant set feerate and gets
evicted.

So, with cluster mempool, this just goes away because we actually sort the
cluster in a linearization, and then this parent and child with the high feerate
would be at the start of the cluster, all the low feerate children would be at
the back of the cluster, and we would treat the high feerate prefix of the
cluster as a high feerate chunk, and the other things would be low feerate
chunks, and we can now cleanly discover what we would be mining last and evict
only them.

**Mike Schmidt**: Amazing.  Thank you, Murch.  I'm glad you're so well-versed in
cluster mempool.

**Mark Erhardt**: Also, come to TABConf.  I'll give a talk on cluster mempool in
two months!

_DEFAULT_MAX_PEER_CONNECTIONS for Bitcoin Core is 125 or 130?_

**Mike Schmidt**: Awesome.  Next question from the Stack Exchange was,
"DEFAULT_MAX_PEER_CONNECTIONS for Bitcoin Core is 125 or 130?" and this was
actually a question that spurned from an Optech Newsletter, Newsletter #310,
that in the write-up we said, "About 130 connections", as the max peer
connections, and the person couldn't find that 130 number anywhere and so posted
to the Stack Exchange about that.  and Lightlike clarified for the person asking
that question, that the number of automatic peer connections is limited to 125
in Bitcoin Core, but somebody may manually add up to an additional eight
connections.  So that "about 130" is accurate.  Anything to add, Murch?

**Mark Erhardt**: Well, there's also the point that Jon Atack raised here in
another answer, which is that we also have temporary connections like feeler
connections, and so temporarily the limit might be raised there as well.  Yeah,
but by default, you'll have about 125 stable connections if you're fully
connected.  And then, there might be some more churn or additional manual
connections, which wouldn't be established by default.  So maybe, well, "about
130" is surely correct, but 125 would be the expected default really.

**Mike Schmidt**: I did not see Jon Atack's answer.  I think I did the writeup
and published the newsletter before that was in there, so thanks for adding
that, Jon.  And, Murch, is Jon Atack really a new contributor to the Stack
Exchange?

**Mark Erhardt**: It looks like it, unless he made a new account and had one
prior.

_Why do protocol developers work on maximizing miner revenue?_

**Mike Schmidt**: Okay, all right.  Well, great person to be there.  Next
question from the Stack Exchange, "Why do protocol developers work on maximizing
miner revenue?"  And I cheated in the writeup by quoting Dave's answer in the
writeup here for the newsletter, and I'm going to cheat again by reading what he
mentioned.  He says, he notes there's several advantages of being able to
predict the transactions that get into a block.  Murch, I think you even
mentioned this earlier in our discussion, with the quote is, "This allows
spenders to make reasonable feerate estimates, volunteer relay nodes to operate
with a modest amount of bandwidth and memory, and small decentralized miners to
earn just as much fee revenue as large miners".  Murch, I think this
philosophical question here is something I see surfacing on Twitter often.  Do
you have anything that you'd add to Dave's answer?

**Mark Erhardt**: Yeah, I want to jump in a little more into the third point you
mentioned here.  So, I would say that a large part of the censorship resistance
that we expect from the Bitcoin Network comes from block publishing being well
distributed.  Unfortunately, right now, there are very few mining pools that
actually build block templates for most of the hashrate.  And if it is extremely
complicated to get the highest feerate block, A miner with a better financial
situation would be able to throw more computational power on always having the
highest feerate block template on hand.  So, it is actually an implicit goal of
the Bitcoin consensus rule design and protocol design to ensure that it is not
super-complicated to get the highest feerate block template.  And this is also
why dark pools, dark mempools, like submitting directly to miners, and some
miners dropping all mempool policies or behaving very differently than the
entire network, is a little scary in the sense that it might give them an unfair
advantage over new entrants in the mining market.

So, by having an extremely efficient and effective block template build in
Bitcoin Core, we are providing tools to all miners so that they hopefully can
compete as well as possible with existing miners, even though they might not be
able to employ a team of engineers to write an optimal block template builder.
And one of the things that Cluster Mempool also does, I didn't mention this
earlier, by having a perfect ordering of the mempool, it becomes extremely easy
to build a very, almost optimal block template.  There's the knapsack problem
obviously, when you get at the tail end of a block, it becomes a question of
what is the best composition of transactions to fill the tail and eke the
highest fee out at the end.  So far we only use a greedy algorithm there.  You
could, for example, use a linear solver, but that would be computationally way
more expensive.  Either way, with cluster mempool, this problem gets way easier,
and hopefully no miner will need to be writing custom software to get the
highest possible fees out of a block, but they can just get it directly from
their Bitcoin Core node.

_Is there an economic incentive to use P2WSH over P2TR?_

Next question from the Stack Exchange, "Is there an economic incentive to use
P2WSH over P2TR?"  And Vojtěch answered this one, pointing out that there are
some cases that a P2WSH could be cheaper than P2TR outputs, but in most cases,
most users of P2WSH, including multisig or Lightning-related transactions, would
benefit from a fee perspective by using P2TR, reduced fees, and also hiding
unused scripts.  Also, with schnorr signatures, we have key aggregation schemes,
like FROST or MuSig2, so that you have less on-chain data.  Anything that you'd
add there, Murch?

**Mark Erhardt**: Yeah, I think I want to actually get into the one case that
was brought up there and seems to make sense.  So, if you have a single leaf
script that doesn't benefit from splitting up, for example if you have a 2-of-3
multisig, you could make three 2-of-2 multisigs out of that, right?  But if you
have a single leaf script, and you never expect to be able to use the keypath
spend, then you should absolutely use P2WSH.  Because if you use P2TR with the
scriptpath, revealing the scriptpath requires a control block.  The control
block adds 34 bytes, which is witness data, so 8.5 gigabytes.  But if you always
want to use the scriptpath and you only have a single option for a script, you
should use P2WSH.  It'll be cheaper.

The main design that P2TR is built around is the idea that, usually if you have
a complex spending policy, you usually can negotiate with the other participants
or the situation, like you can essentially say, "Well, you can work with me and
we can spend it cheaply with more privacy, or I'm going to force my will by
fulfilling the leaf script", and that can often, at least among participants
that are already willing to collaborate, lead to the keypath being used, which
is way cheaper than P2WSH for most scripts.  So, yeah, as long as this design is
fulfilled where you expect that you'll usually be able to use the keypath, but
sometimes you might need to fall back to the scriptpath and it provides you more
options, or if you have a large amount of possible outcomes or ways of spending
it, then you should prefer P2TR.  If you always want to use the script and have
only a single leaf script, you should use P2WSH.

_How many blocks per second can sustainably be created using a time warp attack?_

**Mike Schmidt**: Next question is, "How many blocks per second can sustainably
be created using a time warp attack?"  We've talked about time warp attacks a
few times recently: testnet4 talking about fixing the time warp attack, and also
with the consensus cleanup soft fork proposal fixing the time warp attack.  And
Dave Harding asked this question, and, Murch, you and sipa both answered that
you could sustainably create 6 blocks per second without increasing the
difficulty.  So, do you want to elaborate on that answer?

**Mark Erhardt**: Sure.  So, the question, as you said, came up in the context
of testnet4, and there was a line in there on how quickly a block storm could
happen, and that made me think about it and drop this calculation.  So, the
timestamp of a new block has to be bigger than the median of the 11 previous
blocks.  And the median of the 11 previous blocks is just, you take the last 11
blocks' timestamps, sort them, and take the middle object.  So, assuming that
each of these 11 blocks were found 10 minutes apart, that would be roughly 50
minutes ago.  So you could have a timestamp of minus 50 minutes plus 1 second,
because you have to actually be bigger, not equal bigger.

So, if you have attacked a network with a time warp attack already, you would do
that by keeping the original, the first block's timestamp back in the past, and
by giving the last block in the difficulty period the highest possible
timestamp.  And if that's greater than 14 days apart, you can reduce the
difficulty.  I think that Antoine described the attack in his great consensus
cleanup proposal, and he calculates that in less than 40 days, you can reduce
the difficulty to minimum difficulty, and at that point basically create
infinite blocks.  So originally, I thought that you would be able to only create
1 block per second at that point, but actually if you create blocks always with
the minimum timestamp, it will eventually lead to you being able to create 6
blocks with the same timestamp, by the second, and only then you need to
increment it by one, because the median element now has that timestamp, and you
need to increment from that.

Yeah, anyway, so after you've reduced the difficulty to the minimum and have
kept the block timestamp at least 14 days in the past, you can now, at minimum
difficulty, create 2,016 blocks in, what is that, something that's less than an
hour, right?  So 2,016 seconds would be 40-ish minutes, and I would divide that
by 6.  So, like six-and-a-half minutes per difficulty period, so that kind of
sucks.

_pkh() nested in tr() is allowed?_

**Mike Schmidt**: Next question from the Stack Exchange is around pkh() and tr()
descriptors, and the person asking this is saying, "In BIP386, pkh() nested in
tr() is invalid.  However, in the Bitcoin Core test cases, it is valid.  Which
one is the correct specification?"  So, this involves both BIP386 and BIP379.
And BIP386 is the tr() Output Script Descriptors BIP, and BIP379 is the
Miniscript BIP.  And sipa pointed out that such a construction is allowed, but
it's really up to the application developer to decide which specific BIPs they
adhere to, that there's not one right answer here.  Maybe, Murch, you can
explain for me why I would want a pkh(), like what's the use case of a pkh()
being nested in a taproot() descriptor?

**Mark Erhardt**: I don't think that you should ever do that.  But the nice
thing about standards is there's so many to pick from.  But generally, a
standard is simply a description of a set of rules that you can be compliant
with.  And if you implement it and are compliant with it, you implement that
standard.  And if you tell other people that you implement that standard, other
people will know what to expect from your software.  That's the point of a
standard, is you can adopt it or not adopt it, but when you adopt it, you can be
compliant with it by implementing all of its rules as written.  So, in this case
specifically, there's two different standards, BIP379 and BIP386, and they give
different recommendations in this point.  And I assume, if you use this P2PKH,
nested in P2TR, you would on the one hand have a valid miniscript, but an
invalid output script descriptor.

Yeah, anyway, pick your standards and implement them as you wish.  Just tell
people what you're doing.

_Can a block more than a week old be considered a valid chain tip?_

**Mike Schmidt**: Next question, "Can a block more than a week old be considered
a valid chain tip?"  And Bolton Bailey is asking this question and in his
writeup he notes, "Is there not any safeguard in place in typical Bitcoin
clients that prevents a relatively old block, say one week old, from being
accepted by a Bitcoin client as the most recent block and the current accepted
state of the chain?"  And, Murch, you answered this question, as you do many of
these this this month, and you concluded that, "It would be valid, but that the
node would remain in the initialblockdownload (IBD) state as long as that chain
tip is more than 24 hours in the past, according to that node's local time".
What are the implications of this, if any?

**Mark Erhardt**: I mean, the main point, or one of the main security
assumptions on why Bitcoin nodes work in the first place, is you have at least
one peer that is part of the actual Bitcoin Network.  Essentially, the only way
that this situation could come about is by someone having eclipsed you, as in
they control all of your peer connections and they serve you outdated data.  And
in that case, the assumption that you have a single valid or a single connection
to the actual Bitcoin Network no longer holds true, because the actual Bitcoin
Network would of course not be one week in the past, would not have the latest
block that is older than one week.

So, really we're talking about an eclipse attack here, and I think you sort of
get a partial defence here in the sense that your node does a lot of things in
order to try to protect itself against eclipse attacks.  We make connections in
different autonomous systems, that's like regions in the internet; we churn
nodes if their chain tips don't move, because we assume that we're on a stale
part of the network; you can connect to multiple different networks, there's Tor
connections, I2P connections, and mainnet connections, of course, or Clearnet, I
should say, and there's a fourth one that currently alludes me; you could
connect via satellite; or someone can bring you a disk with the actual
blockchain, and you can just copy it into your full node's data.  So, if the
assumption doesn't hold that even with all these protections connected to a
single peer, your node will at least still be IBD state, because the newest
block it has is more than 24 hours old, I think that our GUI might actually
throw an alert in that case, or at least show you that you're still syncing, but
I'm not 100% sure.

Yeah, anyway, if that's the best blockchain that you learn about, your node will
absolutely try to sync with it as far as it can go.  It's very expensive to make
fake blockchains, so probably this is part of the best chain, just very old.
Maybe there's a few blocks at the top that are fake, but hopefully the node not
being caught up and signaling that it's not caught up with the best chain tip is
enough of a warning for most users to not fall for a chain tip with, I don't
know, some weird U2XOs that they're trying to send you a transaction for, that
you then accept unconfirmed.

**Mike Schmidt**: We talk about eclipse attacks and the potential for someone to
be maybe feeding you fake blocks, but this is probably the more likely scenario
that you're eclipsed and then people just aren't feeding you the new blocks, the
attacker.  What does it mean that I'm in an IBD state, other than the alerts
that you mentioned that may be there?  Are there any other node operations that
are affected by being in that state versus not being in that state?

**Mark Erhardt**: Yeah, so for example, a node that is in IBD doesn't get
connected to it by other peers.  I think that's mostly something other peers do
by noticing that their best chain tip is behind other nodes.

**Mike Schmidt**: So, doesn't that exacerbate the problem then, because that
person would in theory be starving for new connections and honest peers, right?

**Mark Erhardt**: We do make eight connections, outbound connections, that are
fully functional; two blocks-only connections that only request blocks from
their peer.  And then we also have the feeler connection that keeps churning
through the other potential nodes that we could connect to, in order to find
better peers.  So, with 11 peers, I think we're already pretty well set up.  And
then work on erlay has been picking up a little bit again.  When we get erlay,
which allows us to basically sync up on all of the transaction announcements
that we would be making with our peers, and instead of announcing the
transactions separately, we would just sort of compare the list of things that
we would tell each other about, then it might be cheap enough for us to have
even more outbound connections.

So, yes, in a way, having some inbound connections would help, but inbound
connections more often than not are not full nodes, but light clients, so they
wouldn't be relaying as blocks anyway.  So, I think we're not really hurt by
that too much, but there's always more we can do to make eclipse attacks even
harder.

_SIGHASH_ANYONECANPAY mediated tx modification_

**Mike Schmidt**: Next question is titled, "SIGHASH_ANYONECANPAY mediated tx
modification".  It appears, Murch, that the person asking this question was sort
of exploring the idea of some sort of on-chain crowdfunding scheme that people
could contribute funds to.  And you pointed out some of the challenges for using
such a scheme.  Maybe I'll let you elaborate on your answer.

**Mark Erhardt**: Dude, this is over a month old, I don't remember what I wrote!

**Mike Schmidt**: Okay, well, you mentioned that SIGHASH_ANYPREOUT, if that were
activated, it could help with such a crowdfunding scheme.  But you pointed out
that the issue was that, "Inputs commit to a specific UTXO explicitly per the
outpoint (txid:vout).  Since the addition of an input would create a new
transaction that has a new txid, the input to the original transaction’s
descendant transaction would cease to be expected to exist and as the original
transaction is dropped from the mempool --

**Mark Erhardt**: Yeah, I remember now.  They were trying to enable the original
creator of the transaction to make an incomplete transaction, but have their
signature carry over to the complete transaction.  So, the idea was that another
party would later add another output to the transaction, but the signature of
the first transaction, partial transaction creator, would be valid for that.
And so, essentially it got what sort of sighash -- okay, I should probably say
what a sighash flag is at this point.

So, there's three different, or really six different ways in how inputs can
commit to data from the transaction: they can commit to all of the other inputs
and all of the outputs; they can commit to only their own input and all outputs;
they can only commit to their own input and the output at the same index; and
there's a little more.  There's a bunch of good blog posts about this.  But
either way, if you create a transaction that commits to all of the outputs, and
then if another person adds another output later, that of course invalidates
your original signature, because you didn't commit to the new output and this
new transaction is not signed by you.

**Mike Schmidt**: I encourage folks to check out the answer here, because
there's sort of a follow-up question that you put in your answer that I don't
think was originally asked, but might be interesting for folks, which was, "How
do nodes know which transaction to drop? Why does the descendant transaction not
have two different choices what to use as input?  And I think that's a little
bonus reading activity for folks, even if I don't think it was part of the
original question.

_Why does RBF rule #3 exist?_

Last question from the Stack Exchange, "Why does RBF rule #3 exist?"  And the
person asking this question is pointing out that the RBF rule writeup, the text
writeup of the rule, for rule #4, "Replacement transaction pays additional fees
above the original transaction's absolute fees", is a stronger rule than the
writeup of rule #3 for RBF, which is that, "Replacement pays absolute fees of at
least the sum paid by the original transaction".  And I believe Dave did the
writeup and he explains that he was going through the code checks and using
those as a guide for the writeup, and there were two separate checks in the code
for that and that's why the writeup then has these two different rules, even if
one is stronger than the other one.  And, Murch, I don't know if you're
familiar, but I think that the reason that there's two checks is that one was
maybe more computationally easier to do than the other.  So, doing one before
the other one could have some performance improvement.

**Mark Erhardt**: That absolutely sounds plausible.  And after reading this
again, I finally get why Gloria's writeup of the RBF rules only has five rules.

_BDK 1.0.0-beta.1_

**Mike Schmidt**: Well, that wraps up the Stack Exchange segment for this week.
we have one release, which is BDK 1.0.0-beta 1.  I think the biggest thing here,
and my plan is to get one of the BDK contributors to come on and walk us through
when this is officially released in more detail, but I think the biggest thing
for listeners is that there is a stable API.  And in talking with some of the
BDK folks this past week, it sounds like that was a very high in-demand feature
of the software, was to solidify the API so that it's not shifting as much
beneath the builders on top of BDK.  So, if you're using BDK check out the 1.0.0
API and this beta release to see if it does what you think it does.

_Bitcoin Core #30320_

Moving to Notable code and documentation changes, Bitcoin Core #30320, which
adds a new check in the Bitcoin Core code to see if a header's chain with more
work than the chain with a snapshot-based block header exists.  So, this is
around assumeUTXO, you can load snapshots into Bitcoin Core now.  But if you
load a snapshot and that snapshot is not part of the header's chain with more
work than the chain, if the snapshot is not part of the most PoW chain, syncing
will continue, but it will continue on the non-assumeUTXO snapshot chain.  This
isn't something that would be expected to be a common occurrence.  It would
really fall under situations of large forks or reorganizations.  And the check
that was added to the code uses this m_best_header to evaluate the assumeUTXO
snapshot and whether it's part of the best chain.  Murch, can you explain what
the m_best_header is?

**Mark Erhardt**: So, when we try to sync up with the best chain tip, we ask all
of our peers, what is the best header that they have and what is the total work
of that header chain?  And then, we first will sync up with the header chain of
the peer that offers us the best header.  I assume that m_best_header refers to
this, well, best header among our peers that gives us the current chain tip.
So, in this case really, or in the context here, if you had a snapshot that is
not part of the history, the best blockchain, which is single file obviously at
each height, there is exactly one block that is part of the best chain, so you
load a snapshot and this is a different chain than the one that leads to the
best header we have heard from our peers about, then we would ignore it and
instead sync up to the best header offered by our peers that has more work.

I think, so usually this shouldn't be able to happen with the regular Bitcoin
Core release.  The idea is that there would be a hard-coded hash of a snapshot
that is a few thousand blocks back from the release date.  So, when you spin up
your new full node and you do get the snapshot, it checks against what was
released in the source code, whether the snapshot fits the commitment; and then,
that obviously hopefully should be part of the best chain, which we've since
proceeded several thousand blocks from.  So, I think this might be a protection
against people making custom releases with snapshots that are closer to the
current chain tip.  And that would, of course, if people start downloading other
releases with custom snapshots, that would potentially lead to the snapshot that
is being committed to being actually an attack vector that gives you a fake
chain, and might be used to eclipse attack you or split you from the network, or
otherwise bamboozle you.  And here, if your Bitcoin Core node sees a better
header, it will ignore this attacker's snapshot.

Obviously, if you download a custom release that is signed by whoever released
that, you're already at the whim of that releaser; they can have changed
anything else in the codebase and release that and sign that, and you're
trusting them that they're giving you legit software.  So overall, I'm not sure
if this would save you, or it would make it harder for the attacker to craft a
release that you would accept, and would make you end up on their custom chain
tip.  But otherwise, I think it's sort of a very out-there scenario.

**Mike Schmidt**: Yeah, I was going to ask that.  I'm glad you addressed that.
If folks are trying to be more aggressive about where the snapshot is being
loaded, a more recent snapshot, potentially from a third party, that could be a
scenario that this check would be more likely to be activated.  But thanks for
elaborating on that.

_Bitcoin Core #29523_

Bitcoin Core 29523, which adds a max_tx_weight option to transaction funding RPC
commands, fundrawtransaction, walletcreatefundedpsbt, and send.  Murch, this is
a PR that you reviewed and was also referenced as a motivation from a Delving
comment that you made.  Do you want to break this one down for us?

**Mark Erhardt**: Okay.  So, well, as some of you notice, our feerates have been
a little more variable in the last one-and-a-half years, and especially they've
been going extremely high, for example, around the halving.  Now, if you're
building a transaction and you have a very fragmented wallet, you might want to
ensure that you're not building a huge-ass transaction at 1,000 sat/vB.  So,
this new parameter that you can put on your transaction funding call would
prevent you from having a transaction that exceeds a certain amount of weight.
So for example, if you anticipate that you should be able to craft a transaction
with no more than three inputs, you could calculate how big that transaction
might end up with the outputs, the three inputs, and the header, and then limit
your transaction weight to some, well, the resulting number, and that might
prevent you from extremely overspending at high feerates.

This is hopefully not super-necessary because since the last release, we also
have CoinGrinder as a coin selection strategy, which at high feerates, which is
higher than 30 sat/vB, will try to find the minimum input weight, and that
should also be the most attractive transaction according to the waste metric.
So, hopefully you will not need to manually specify your maximum transaction
weight.  But if you want to have a belt-and-suspender approach, or just
generally want to even limit your transactions at low feerates, then this is
your tool to do so.

_Core Lightning #7461_

**Mike Schmidt**: Core Lightning #7461, this PR is titled, "Part 4, offers for
non-public nodes, and handling self-pay".  The "Part 4" in the title here refers
to Core Lightning's (CLN's) ongoing efforts to support BOLT12 offers.  And this
PR handles some corner cases of self-pay, which we covered in Newsletter #62,
which was originally implemented in CLN in PR #6399, so refer back to that about
self-pay.  And this change handles invoice blinded paths, which start from the
CLN node itself.  And additionally, unannounced nodes can also now create offers
by adding blinded paths, whose second-to-last hop is one of the CLN node's
channel peers.

_Eclair #2881_

We're going to jump into our last PR here.  If you have any questions for Murch
or I on the News section, Stack Exchange, or any of these Notable code changes,
now's the time to ask.  Eclair #2881 titled, "Reject new static_remote_key
channels".  So, Eclair will now not allow remote peers to open a new
static_remote_key channel.  And in the PR, I believe it was t-bast that noted,
"These channels are obsolete.  Node operators should use anchor output channels
now.  And anchor channels, I think we mentioned them briefly earlier, are
channels that have an anchor output on the commitment transaction, and that
allows for fee bumping after a force close transaction has been broadcast.

Static_remote_key channel types are, I think I also saw it referred to as
tweakless channels.  I didn't see that they were obsolete in the BOLTs
repository, but t-bast is noting that that they're obsolete here and I think
we've all encouraged folks to use anchor channels, anchor-based channels, as
well in previous discussions.  Also in Eclair here, the existing
static_remote_key channels will continue to work, it's just about not creating
or allowing new static_remote_key channels.

I don't see any questions or comments on the thread.  Murch, I think this might
be the longest that you and I have done just us, going an hour and 16 minutes
here.

**Mark Erhardt**: Yeah, it might be!

**Mike Schmidt**: And if this were an in-person live audience, I would offer for
everyone to applaud you sort of driving the entire podcast show this week.  So,
thank you for all your knowledge here and getting us through this newsletter,
and for being my co-host as always.

**Mark Erhardt**: Happy to help.  I must admit, it was very nice.  So, I was in
Nashville last week and a bunch of people came up to me and said that they
listened to our podcast.  So, that was awesome and it was nice to hear that
people really got a use out of it.

**Mike Schmidt**: And thank you all for listening and we'll see you next week.
Cheers.

{% include references.md %}
