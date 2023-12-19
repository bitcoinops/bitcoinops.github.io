---
title: 'Bitcoin Optech Newsletter #280 Recap Podcast'
permalink: /en/podcast/2023/12/07/
reference: /en/newsletters/2023/12/06/
name: 2023-12-07-recap
slug: 2023-12-07-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Pieter Wuille
and Matthew Zipkin to discuss [Newsletter #280]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-11-7/84225464-0806-15de-1abd-c477d8564245.MP3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #280 Recap on
Twitter Spaces.  Today we're going to be discussing cluster mempool; we're also
going to be discussing a new Bitcoin Network testing tool called warnet, and
some recent simulation testing results from that; and the Bitcoin Core 26.0
release and associated PR Review Club.  I'm Mike Schmidt, I'm a contributor at
Optech and Executive Director at Brink, where we fund Bitcoin open-source
developers.  Murch?

**Mark Erhardt**: Hey, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Pieter?

**Pieter Wuille**:  Hi, I'm Pieter, I also work at Chaincode Labs on Bitcoin
stuff.

**Mike Schmidt**: And Matthew?  Let's keep the trend going.

**Matthew Zipkin**: Hi there, my name is Matthew and I also work on Bitcoin
stuff at Chaincode, research development and education.

_Cluster mempool discussion_

**Mike Schmidt**: Awesome.  Well, thank you both for joining us.  We're going to
go through the newsletter sequentially, starting with Cluster mempool
discussion.  Now, we've mentioned cluster mempool tangentially in the
newsletters and our podcast.  I think we mentioned it when we talked about the
Waiting for Confirmation series, and I think there was a Stack Exchange question
that referenced cluster mempool, but we haven't covered it directly head on.  So
luckily, we have Pieter Wuille with us today who's been deeply involved with an
effort to reinvent the mempool under the name cluster mempool.  And I think many
people, or many listeners, are familiar with the idea of a mempool as maybe a
big list of valid bitcoin transactions that aren't yet in a block.  And maybe
sometimes mempools fill up and transaction feerates spike and sometimes users
need to use fee bumping techniques to move their feerates, their transaction
feerate within the mempool.  And sometimes low-feerate transactions maybe get
dropped from certain mempools.  And maybe it's not perfect, but it seems to
work.  So what's the issue with the mempool today?

**Pieter Wuille**: Well, just to scope things out, cluster mempool is really
about dealing with some of the complexities involved that result from having
dependent transactions in the mempool.  So, I think the typical example that
people are most familiar with is CPFP, Child Pays for Parent, where it is
possible you receive a transaction from someone that pays a low fee, you want to
get that transaction confirmed, something you can do is spend that output, even
though it is unconfirmed yet, in a transaction yourself at a higher fee.  And
the correct behavior you expect, and one that has been implemented since, I
don't know, 2015 or something is that if you have this low-fee parent
unconfirmed transaction and a high-fee child unconfirmed transaction, the mining
code in Bitcoin Core or related projects will consider them as a single package
together that has sort of the sum of the fees paying for both because a minor
can't include the parent anyway without the child.

Now, that's all great, we've had that for years but there are some issues with
that.  Even though cluster mempool ended up being -- well, ended up, I shouldn't
say it's finished, we don't even have a concrete proposal yet.  It's a work in
progress idea that's crystallizing as we go along and it'll be a while before
we're there.  But really, the initial motivation for it is the fact that
eviction really doesn't work as we want it to.  Let me go into that briefly.
So, what the mining code -- and when I say mining code, I really mean the code
that decides which transactions get taken from the mempool to put into a
prospective block to give to the hashers that miners are using, so it's really
about transaction selection.

How that works is, we compute for every transaction the sets of all its
unconfirmed ancestors.  So in the case of a CPFP, that would for the child
include also the parents.  And then we compute the average feerate for that
ancestor set as we call it.  So that's the sum of the fees divided by the sum of
the sizes.  And then, we just look at the entire mempool, sort it this way, pick
the one with the highest ancestor feerate, include that in the block template
and start over.  This is an approximation, this is far from optimal, but it is
good enough to deal with CPFP.

Now sometimes, as people are undoubtedly aware, the mempool can fill up, so
every node in Bitcoin Core has a limitation on how big the mempool can get, and
if it starts using more memory than that, we have to evict some things.  We want
to evict the things that are least likely to be confirmed in the near future.
So, really what we would want to do is evict the thing that would be mined last
by our own metric.  That's unfortunately really not computationally feasible.
To do mining algorithm, as I described, it's computing these ancestor sets or
taking and picking the best one, we can't just run that over the entire mempool;
we run it just on one block worth of data and it would be way too slow, anytime
you want to evict something, to run it to the very end.

So instead, what we do is do exactly the opposite.  Namely, for every
transaction in the mempool, we compute what its descendant set feerate is.  That
is the set of all its children, the sum of the fees divided by the sum of the
sizes, and then find the lowest of that.  It sounds like this is exactly the
opposite of what we're doing in mining cases.  Turns out it isn't.  You can
construct examples and they're really not all that outrageous, where the first
thing you would evict is really the first thing you would want to mine, and
that's not a good situation.  Clearly, we don't want to evict the best
transaction we would want to mine.  And so cluster mempool started as an attempt
to fix this problem.

The idea is really, as I said, we would want to run the mining algorithm on the
whole mempool, but we can't do that because it's too slow.  Instead, what we're
going to do is just precompute things.  So you precompute the sets of
transactions that would be mined together.  This is hard to do without having
some diagrams or a wipe board.  But in short it boils down to, we try to compute
how things would be mined.  This gives us a very efficient data structure to
find out the order that transactions would be mined in at block mining time.  We
can reverse that so eviction becomes the exact opposite of block building, but
this only works if the amount of transactions that can be affected by a new
transaction is bounded.  Sadly, it's possible today that really one new
transaction completely changes the order of every other transaction in the
mempool, and that's not a good situation.

So, cluster mempool is likely going to be a proposal for a change in the relay
policies that Bitcoin Core uses that involves limiting the size of clusters, and
I should define what a cluster is.  A cluster is the set of transactions a
transaction is connected to, through either parent of or child of relation.  So,
it is the set of all your parents and the set of all their parents, but also the
set of all their children and then all the parents of those children and all the
children of those parents, and so forth, everything that's connected.  And so,
the proposal will likely be that we limit how big those things can get.  And by
limiting how big those things can get, we can run the mining algorithm on really
just the clusters.  Anytime a transaction changes, we just run the mining
algorithm on just that one cluster, and that gives us enough information to use
at mining time.  And I'll stop there as an introduction.

**Mike Schmidt**: Maybe further defining, this is something I'm trying to wrap
my head around, is the difference between a cluster and a chunk.

**Pieter Wuille**: Yes, so chunks are -- cluster is clear.  It's a set of all
transactions you are connected to.  Chunks are groups of transaction within a
cluster that you would want to mine together.  Again, CPFP, the parent and the
child would form one chunk.  Even though maybe you have more dependencies, even
though there are other things dangling off somewhere, that tree.  So, more
procedurally, the way we do it is you take a cluster, set of transactions, we
run the normal mining algorithm, or maybe even in the future a better one, on
just that cluster.  The output of that is the order in which you would want to
mine just those transactions, ignoring anything else in the mempool, ignoring
anything else that goes into your block.  Just those transactions, what order
would you want to mine them in?  And then think of every transaction as being
its own little chunk.  Start out that way and any time you have a chunk whose
feerate is higher than the chunk before it, merge the two together.  And do this
in any order and keep doing it until you have none left.

Those are the chunks of a cluster, and they're really the things you would want
to mine together because clearly if you have a transaction followed by a
higher-feerates transaction, you would never want to include just the first of
the two, you'll always want the second one too.  And so, a cluster can be just
one chunk, it's possible that a cluster consists of chunks each of a single
transaction.  And a nice observation is that the feerates of the chunks within a
cluster always have to be monotonically decreasing.  This just follows from the
construction, because whenever you have a higher-feerate chunk following a
lower-feerate one, you merge them together, so this means that the chunk
feerates go down.  And this also immediately leads to what the mining algorithm
becomes, is just take the set of all the chunks and include them in decreasing
feerate order.  And because the chunks in the clusters individually are sorted
in decreasing feerate order, you'll never include a child before its parent.
Yes, I see someone raising their hand.

**Mark Erhardt**: Yeah, I just wanted to jump in here briefly to reiterate how
people can think of chunks.  It was a little abstract how you explained it just
now.  So, I think many people should be aware of CPFP as a mechanism for
reprioritizing the parent transaction.  So, you have a low-feerate parent
transaction, you add a high-feerate child that depends on the parent being mined
first.  And because miners want to get the child, or rather the fee attached to
the child, they are now incentivized to include the parent in order to be able
to include the child.  So, when we look at a cluster, which is just the complete
group of transactions that are connected through child and parent relationships,
we would want to include from a cluster first, whatever set of transactions
gives us the highest feerate.  So if you were approaching this naively, you
would do a power set search and look at each subset of the cluster and compare
all of their feerates, and then pick the one that is the highest feerate.  So,
that might be just the aforementioned parent and child, and some other
transactions in that cluster might not get picked first.

If you find the optimal sets of what we would pick into a block, we would call
that the chunks of a cluster.  So, we get a complete order of the transactions
in the cluster, and they would be grouped into sets of one to the entire cluster
of transactions of what we would pick as one piece into the mempool.  I know
that was a repetition of what Pieter said, but maybe that will help.

**Pieter Wuille**: Yeah, okay.

**Mike Schmidt**: We have a question here.  Larry asks, "Will this change also
simplify the mempool code?  It's fairly complex currently".

**Pieter Wuille**: That's a great question.  So, I think the answer is nuanced.
One thing it will do is, I think it will help us abstract away a whole part of
the complexity.  So, a significant -- let me start over.  So, I think that a
large part of what we are trying to do, and I haven't touched on this yet, I've
only talked about block building and eviction, but there are lots of other
things that Bitcoin Core does that effectively involve guessing how good is a
transaction, getting some metric on that.  And really what cluster mempool does,
it gives us a number for every transaction, how good is this, taking into
account the fact that children can pay for parents, and so forth.  It is the
chunk feerates of your transaction, period.

Having that notion, I think, simplifies a whole lot of reasoning, but it really
becomes different.  So, today we have the BIP125 RBF rules, and at least some of
those rules are really trying to guess heuristically, making sure that the
mempool gets better when these rules are satisfied.  It doesn't achieve that.
So, the BIP125 permits accepting things that are actually not incentive
compatible, and it rejects a whole bunch of things that are incentive
compatible.  And part of the cluster mempool proposal will almost certainly be,
"Replace that with just actually checking incentive compatibility", because we
can compute that directly.  And conceptually that will be, I think, a lot
simpler.

In terms of code, I don't know if it gets all that -- in number of lines, it's
almost certainly not going to be a reduction.  But I do think you'll get a much
cleaner abstraction between those because everything related to computing, the
clusters, the linearizations, the chunks, can be sort of split off to a module
like, "Here are a bunch of transactions, sort them for me and tell me their
chunk feerates", and then everything just becomes a function of those chunk
feerates.  So, I think the answer is really, it allows us to do more complex
things, and as a result, things will get more complex, but it'll be organized
better.  And it'll be cleaner to think about.  And to make that a bit more
concrete, okay, Mark, go ahead.

**Mark Erhardt**: I just wanted to briefly jump in there and explain what you
meant with, "Children can pay for parents".  So, in the old mempool approach and
the old block building template method, we would find ancestor sets and compare
the feerates of ancestor sets, pick the best ancestor set, update all the
remaining transactions, pick the next best, and so forth.  So, for example, if
you have a transaction, a parent transaction that has two children that are both
attempting to bump the parent, they would be competing per the old rules for
having the better ancestor set feerate, because there are two ancestor sets
here, child one with the parent and child two with the parent, and they would
not be considered together.  In cluster mempool, because things get chunked
together the way we should be picking them, adding a second child that also
tries to bump the parent will lead to an overall better feerate for the set of
all three.  And cluster mempool will discover this as a chunk.

So, we will get into a situation where not just one child can pay for one
parent, but a set of descendants can pay for an entire ancestry together, if
that leads to a higher set feerate together.  And that's really one of the main
benefits, is that we can discover more complex sets like that, that actually are
more attractive to pick into a block before each of their sub-ancestor sets.

**Pieter Wuille**: Right, so I think this ties in nicely with the abstraction.
So, by having this abstraction layer for, "I have a bunch of transactions,
what's the order I want to mine them in?" we can substitute that algorithm with
something better and we almost certainly will, as Murch explained.  And as a
result, just everything gets better, like this immediately makes the mining
better, it makes replacements better, it makes eviction better because
everything is just a function of that mining question and it's nicely packaged
away.

I also wanted, Larry, to give another example of what I meant earlier with,
"It'll allow us to do more complex things".  So, there is ongoing discussion
about package relay, a complex topic that's sort of progressing in parallel to
cluster mempool.  The one thing that I think we've considered largely impossible
to tackle is package RBF, the combination of replacements with package relay.
And with cluster mempool, probably whatever we come up with for RBF will
generalize much more easily to packages, and I think that's also one of the
great advantages.  Yes, things get more complicated, but by simplifying the
reasoning, it also lets us reason about more complex things that we actually
want.

**Mike Schmidt**: We have another question from the audience.  Abubakar says,
"So, the mempool is arranged in clusters and chunks that are built over time as
transactions are added to the mempool.  After a new block is connected, we have
to evict lots of transactions from several clusters.  This will make us
linearize several clusters in the mempool.  Is that efficient?"

**Pieter Wuille**: Yes, very good question.  So, that is actually the
bottleneck.  We're trying to design the code in such a way that that operation
is acceptably efficient because indeed, suddenly you need to re-linearize,
re-chunk, re-cluster, a whole lot of things.  Now, it is really easy in the case
that what is mined in a block is a suffix of the linearization of a particular
cluster, then you just chop it off.  But in case it is not, in case the miner
did something else than what we expected them to do basically, you need to
re-linearize and that costs some time.  But to give concrete numbers, we're
hoping to set or propose a cluster limit of somewhere between 50 and 100 maybe,
in such a way that a simple mining algorithm, better than the one we have today,
but not a lot better, runs in the order of tens of microseconds, maybe 100
microseconds per cluster.  And so it's possible that you have tons and tons of
clusters affected by a new block, but even if you add those up, it remains a
reasonable amount of time.  Does that answer your question?

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: Yeah, I wanted to pick up something that you mentioned and
that was, because we run the mining algorithm no longer on the entire mempool --
maybe you could mute yourself while you're not talking -- we no longer have to
run the mining algorithm on the entire mempool in order to compare things, but
rather we only have to run the mining algorithm on a cluster in order to find
the order of the transactions in that cluster.  And the clusters are completely
independent, they don't affect each other's order, other than that they might
have components that go ahead of something or after something, but they don't
interact on the feerates of the subcomponents of clusters.  So, by having a
perfect order in each cluster, we can basically get a total order on the mempool
by just looking, "Okay, across all clusters, let's look at the best element in
each cluster, the best chunk, and just pick that" and then pick the next best
chunk across all clusters, and so forth.

So, building a new block template will just be taking a prefix from each, or
taking prefixes from clusters; and mining a block, if people or if miners
essentially mine such prefixes from clusters, will also just be taking away the
prefixes from the clusters, leaving the rest of the cluster intact.  And since
the chunks were already considering that they would be mined just in that order,
if we take off prefixes at chunk borders, the rest of the cluster is already
perfectly linearized.  It doesn't get changed by the remainder or, well
actually, I'm not 100% sure.  There might be some things that you could reorder
afterwards to make it even better, but it'll be a valid topology and we don't
necessarily have to change anything about the clusters that remain.

**Pieter Wuille**: Yeah, so exactly right.  So specifically actually, it is
possible that by removing a prefix, a cluster splits in two, because now they're
no longer connected.  But even that is a very simple operation.  You just take
the existing linearization and split it.  And apart from, well, now maybe those
things are smaller and you can run a better algorithm, you don't actually need
to re-linearize.  So basically, if miners pick the transactions in the order
that we have them, there is no work to us.  Of course, we can't assume that a
malicious miner doesn't do that, but it does do that.

**Mark Erhardt**: There's another question from the audience, which was, "Do we
know how many miners actually use Bitcoin Core's block templates or run their
own?"  And last I checked, or for example, if you look at mempool.space, which
builds a block template according to Bitcoin Core's method and compares that to
what miners mine, essentially, all miners appear to be using Bitcoin Core's
block template plus some prioritized transactions that they may have picked, due
to acceleration or receiving them out of band or having a vested interest in
them themselves.

**Pieter Wuille**: Yeah, I think we've seen evidence a while ago of miners
running their own custom code, which resulted in an invalid block a couple of
months ago.  But even that, I think the theory is that they started from what
Bitcoin Core gave them and made some changes on top.  So, I agree.

**Mark Erhardt**: I think they only added the coinbase after Bitcoin Core and
they hadn't accounted for the sigops in the coinbase transaction?  Is that it?

**Pieter Wuille**: Exactly, yeah.

**Mike Schmidt**: Well, there was one instance of that and then there was
another instance of just the transaction ordering not being compliant as well.
I think that was a different miner though, right?

**Mark Erhardt**: Oh yeah, you're right.

**Mike Schmidt**: Pieter, question for you on the policy side of this.  The way
I'm thinking about it is, cluster mempool is operating on clusters, and so the
restriction here is cluster size, whereas previously the algorithms were
operating on ancestor and descendant limits, so there were some limits on
ancestors and descendants.  What does a limit on cluster size look like in terms
of an end user?  Is that something that is easily determined by a wallet, or
what would the feedback mechanism be for somebody who violates that policy?

**Pieter Wuille**: Good question.  So this touches on, I think, a potential
concern people could have with cluster mempool in that it makes some of the
policy more black box.  I don't think it's meaningfully different than what we
have today.  In particular, the descendant limit is also something you, as a
wallet, generally don't have control over, because if you spend some outputs
that pays to you, you have no control over what others attach to other outputs
of the same transaction, and those all feed into the descendant limit of that
parent.  And generally, the ancestor limit you have a control over, because
obviously whenever you create a transaction, you know what unconfirmed ancestors
it has.  But the descendant limit you don't, and I think conceptually a cluster
size limit is very similar to a descendant size limit in that regard.

We do aim for larger numbers, but clusters are bigger sets than just descendant
sets, so that inevitably means that some things, at least in theory, that were
acceptable before under an ancestor and descendant limit are no longer
acceptable under cluster limits.  You could today, it happens that you see
clusters in the mempool of 200-plus up to 1,000 transactions that are all
connected, even though none individually violates the descendant and ancestor
size limit.

**Mike Schmidt**: Murch, what do you think is a good way to wrap up here?  Or
maybe before we do that, while you think of the answer to that, Pieter, I think
there were some slides from a presentation of yours around this topic.  Is that
presentation something that was recorded that people can look forward to
watching?

**Pieter Wuille**: Yeah, so I did a talk at Bitcoin Research Day that Chaincode
hosted here, I don't know, a month, maybe a month or two ago here, and that
presentation was recorded.  I don't think the video is available yet, but it
will be.  My slides are linked in the Optech summary website on cluster mempool.

**Mike Schmidt**: Murch or Pieter, what if any call to action for the listeners
would there be at this point, other than the curious people who want to follow
along and just be aware of these developments; is there something that you're
looking for help on or that the general broader Bitcoin ecosystem should be
aware of with respect to cluster mempool?

**Pieter Wuille**: Yeah, so right now there is a PR by Suhas to Bitcoin Core
that's a work in progress implementation of cluster mempool that is functionally
complete, so it'll keep track of clusters, it linearizes, it replaces all the
places where feerates are computed with cluster-mempool-based things.  That is
not what we expect the eventual implementation to look like at all, but it does
give something to experiment with and it does give something that allows you to
think about how this might interact with other pieces of infrastructure.  And I
think that that's the big question I think that people can help with today, is
reason about use cases that might be affected by this.  And so, there's a
demonstration you can look at.

**Mike Schmidt**: Pieter, thank you for joining us and walking us through this.
Your time is valuable and I think we had a great discussion.  You're welcome to
stay on as we progress through the rest of the newsletter, or if you have
linearizations to get to, then ...

**Pieter Wuille**: No, I'll stay on.  Yeah, thanks for having me.

**Mark Erhardt**: For the 26 release later, we might also tap you as a resource.

_Testing with warnet_

**Mike Schmidt**: Next item from the newsletter, Testing with warnet.  Matthew,
in the newsletter this week, we spoke about some of the simulations that you've
been running using warnet and the resulting extra memory usage that could result
from some proposed peer management code changes in Bitcoin Core.  But maybe to
take a step back, while we would love to get into some of the specific
simulation details eventually, maybe we could start off with what is warnet?  We
haven't discussed warnet in Optech materials previously.

**Matthew Zipkin**: Yeah, thanks.  So, Warnet is a new project.  We haven't even
really released v1 yet, but we are already starting to use it.  This is a
project sponsored by Chaincode that started over the summer with myself,
josibake, Will Clark, Extheoisah, a few other contributors; oh, Max Edwards is
on the crew now.  And the goal of Warnet is to create a P2P Bitcoin Network
simulator.  So, we're taking some basic ideas from the Bitcoin Core test
framework.  If you've ever written a functional test for Bitcoin Core, you've
seen these Python scripts that can manage nodes and send RPC commands to them.
We're taking that and trying to scale it up in the Docker and/or Kubernetes sets
to hundreds or even thousands of nodes.

We're still using regtest for these networks, but one of the interesting
features we've been able to add is actual routable IP addresses, which is
something you can't get from the Bitcoin Core test framework.  And what that
allows us to do is actually gossip matter messages between Bitcoin nodes and set
up a network where they can actually discover each other, because the nodes are
routable.  And then ideally, at the scale of hundreds or thousands of nodes with
something like Kubernetes, we'll be able to test the emergent behaviors,
emergent features of complicated scenarios on the network.

**Mike Schmidt**: You mentioned "we", so who is the target audience?  Obviously,
there's a group of you working on this, but I guess when you release v1, what
sorts of users would you anticipate using this software?

**Matthew Zipkin**: Yeah, great question.  So, our users are Bitcoin Core
developers and also LN client developers because we also have some LN
compatibility.  I think you guys have already touched on the SimLN project,
which has had a release, and they were also born out of that summer tooling
workshop with Carla and Sergei.  And so, the idea is for people who are
experimenting with Bitcoin Core or have a question about the Bitcoin Core
Network, or want to see what kind of things happen to Bitcoin Core or LN at
scale.  So for example, one of the first test cases we were able to use was a PR
opened by Vasil over the summer, called sensitive relay, where Bitcoin nodes
will create short-term Tor connections just to send out their own transactions,
so that the transaction relay is private.  And that was actually a bit of a hard
thing to test in the functional test framework, but we were able to do it in
warnet because we actually have a Tor network inside of Warnet.  We have an
internal onion router using a local directory authority, and so we were able to
actually run that test, which was cool.

The next use, and this is one that I think has kind of let the cat out of the
bag about the project, is that we're trying to study the emergent effects of
increasing the connection count on the Bitcoin Core Relay Network, on the
Bitcoin Core network.  There's work by Amiti and Martin to increase the amount
of connections that a node can take, inbound connections, particularly if those
extra inbound connections are block relay only.  And so, what I posted on
Delving Bitcoin last week was an experiment I ran with 250 nodes plus a control
node, which was just running the release version 25.1, and then a compiled
version of Martin and Amiti's branch.  And so, we had a control node and a test
node, and both of those nodes received inbound connection attempts from all 250,
let's call them MPC nodes.  And we can see how much memory is being used by
those two nodes over time and compare their behavior.  We have Grafana
installed, which can make some RPC requests and report time series data about
the replies from those RPC commands, so we can see what memory is being used and
monitor the connection count between the control node and the experiment node
over time.

So, it was a cool demonstration of warnet.  The result was not really
super-duper interesting, or perhaps it was, because it indicated that the PR
wasn't especially harmful.  Basically memory increased linearly along with the
number of nodes that were added; that's basically expected.  But warnet would
have been a great place to see if there was something wrong, and we were using
exponentially more memory.  And then I'm interested to try out other scenarios
that we can run inside that simulation to see just what other sort of things we
can bang on with this proposal to the improvements of P2P.

**Mike Schmidt**: So, you can use warnet in the instance that you mentioned here
to either test or confirm certain assumptions about how the software will
perform at scale under certain scenarios.  And I guess scenarios is an
appropriate word, because there's other types of scenarios that you can
architect in warnet as well.  Maybe if you're not targeting the effect of a
certain PR, you could also just kind of create interesting or pathological
scenarios within your own warnet simulation as well and see how that plays out.
Do you see that as a different use case, or is that a similar use case?

**Matthew Zipkin**: No, that's definitely part of it.  I mean, part of the
inspiration for the project was the memory leak discovered a few months ago in,
I guess it was v25.  That was sort of nailed down by AJ, where in debug mode,
the message handler thread blew up in memory usage.  One of the ideas for warnet
was that we would catch that kind of thing before it happened.  So, it would be
cool to see warnet running different types of simulations over long periods of
time, kind of like a miniature test net, I guess, where we can really control
everything, including transaction activity, and monitor for those things.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: I guess it's already been said, but I wanted to break it down
a little more.  Basically, what you cannot do when you run the regular framework
is look at behavior between multiple nodes.  That's generally just difficult to
get in unit tests or in functional tests.  So, what warnet gives us access to is
all of the behaviors that emerge from multiple nodes on a network, how do
addresses propagate; how does the P2P communication affect memory; how do
messages propagate on the network; and so forth.

**Matthew Zipkin**: Yeah.

**Mike Schmidt**: Matthew, given that you guys are working towards a 1.0
release, are there things that people should be aware of both before that to
provide feedback or testing, or after that once you guys release it, that would
be valuable for either individual developers or the broader Bitcoin ecosystem of
projects and businesses?  What would you want them to know or do?

**Matthew Zipkin**: Yeah, sure.  So, all the features I've described so far we
have working in Docker, meaning if you have one machine with a Docker daemon,
you can run as many containers as your poor little machine can handle.  All the
guys that I mentioned working on the project, we're pretty much focused right
now on adding Kubernetes as an optional backend.  So, you should be able to run
all the features of warnet in either Docker, which we could see like SimLN
users, maybe an LN developer running ten nodes on one machine just to do some
learning experience experiments.  They can use Docker for the larger stuff like
hundreds and thousands of nodes.  You could deploy that on Kubernetes where you
have more machines, more physical machines available.  The Kubernetes is
piecemeal right now, I think that's kind of what we're waiting for.  We were
going to try to sneak in a v1 release before adding Kubernetes.  Now Kubernetes
is sort of half in there and half not, so we'll probably wait until that's all
done.  So, that's one heads up I'd say, if you're going to use it, stick to the
Docker mode, which is the default anyway.

Then, yeah, we tried really hard to make the documentation very clear, and I've
handed off the project just without any handholding or guidance to developers
like Carla and Martin, even Pieter Wuille took a look.  And so, hopefully the
documentation is enough that you can just look at the repo and get started.  And
of course, if you run into any problems, just open an issue and let us know,
it's probably a documentation error.  But at this point, I'm pretty proud of the
features that we have at least running in Docker mode, and I can't wait to see
what we can do once we can scale to Kubernetes.

**Mike Schmidt**: And just to maybe bat the point home here, that this is not a
product or service that is for sale, this is an open-source set of tools that
anybody can run and improve on and run within their own bespoke environment.

**Matthew Zipkin**: Yeah, definitely, of course.  Again, our target audience is
Bitcoin Core developers and Lightning Core developers.  If you're just making a
wallet app or something, I'm not sure if this is the right tool for you, but
maybe if you want to see how some protocol you're writing affects hundreds of
nodes at the same time, you might find that kind of interesting.  We have also
considered in the future maybe hosting a single massive warnet instance that we
can allow multiple users, maybe Core devs or something like that could get
permission to use one big shared warnet.  But yeah, everything's open source, of
course, and anyone can run it locally.

**Mike Schmidt**: Very cool project.  Thanks for coming on and explaining that
to us, Matthew.

**Matthew Zipkin**: Hey, thanks for having me.  It's always great to hear from
you, Schmidty.

**Mike Schmidt**: You're welcome to stay on and hang out for the rest of the
recap, or if you have anything to get to or any children to get to, you're
welcome to drop!

**Matthew Zipkin**: Yeah, thank you.  I'll stick around if I can, thanks.

_Testing Bitcoin Core 26.0 Release Candidates_

**Mike Schmidt**: All right, thanks again.  Next section from the newsletter is
our weekly coverage of a Bitcoin Core PR Review Club.  This month we covered the
testing Bitcoin Core 26.0 Release Candidate Review Club Meeting, which is a
little bit different in that it didn't review any particular PR this go around,
but was a group testing effort.  If you recall, we had Max Edwards on our
podcast, and that was in #277.  He is also the author of the testing guide and
also one of the hosts of the Bitcoin Core PR Review Club on this topic.  So, if
you're curious about how Max framed the structure of the testing guide, the
motivation and the goals of the testing guide, check out Podcast #277, where we
had him on.

The Review Club session that we covered in the newsletter focused on a subset of
the testing guide items, in particular including getprioritisedtransactions RPC,
the importmempool RPC, and V2 transport (BIP324).  Murch, any color you would
add there?  And Larry, I also sent you an invite if you wanted to jump on and
discuss some of this.

**Mark Erhardt**: Yeah, I read over the details of our Review Club.  I think we
don't have to really jump into the responses.  I think it's interesting maybe to
play around with features if you want to see what has been released with the new
release, because it's out now since two days or so.  But yeah, so for example,
it's just not super-relevant that the V2 transport node that they were testing
with happened to have all slots full and therefore they didn't get very far with
testing them.  Maybe we can just go on to talk about the features that are going
to be in 26, which is our next topic anyway, and has large overlap.

_Bitcoin Core 26.0_

**Mike Schmidt**: Yeah, I think that sounds good.  Maybe I'll frame it and you
can jump off where you think is valuable.  We're jumping to the Bitcoin Core
26.0 release.  We talked about the Testing Guide just a second ago, which is a
good way to play around with some of the new features if you want to be hands-on
with it.  But additionally, Murch did a nice verbal run-through in our Optech
Recap Podcast #274 of all the major items from the release notes for 26.0, if
you're curious to read about it, as opposed to being hands-on with the Testing
Guide.  But Murch, maybe you have more to augment about this release.

**Mark Erhardt**: Well, I'm probably not the only one, but I'm really excited
about the V2 transport protocol.  So, whenever two nodes connect to each other
and do their handshake and figure out that they both support the new V2
transport protocol and have it enabled, obviously, because it's going to be
disabled by default, they are going to start using the V2 protocol to
communicate with each other.  This has a new set of P2P messages, which
basically just means that they're encoded differently, but do mostly the same
things.  And especially the communication between two nodes will be encrypted,
so this has some funny effects.  One is, this is actually more
bandwidth-efficient for compression reasons and stuff, which is a little funny
and not the main reason we're doing this.  The other one is, previously
everything was sent in cleartext, so any node along the route would be able to
see, "Oh, here's some Bitcoin traffic", and they could listen in what people are
sending.

So, for example, if you were the first one to broadcast a transaction and your
IT was somewhat invested in passively listening in on your Bitcoin traffic, they
might notice that you were the first one to send that transaction.  With it
being encrypted, you still can listen in because there's no authentication yet,
but you'd have to run a Bitcoin node in order to intercept and read the traffic.
Otherwise, it basically just looks like white noise to you, completely random
strings of data.  Pieter's been working on this quite a bit, so he can jump in
at this point if I'm ...

**Pieter Wuille**: Great summary.

**Mark Erhardt**: Okay, cool.

**Mike Schmidt**: Maybe, Murch, one plug again.  We had a PR Review Club
discussion in our Recap Podcast #268, in which we covered BIP324, and we also
had Pieter on as a guest to talk about BIP324, some of the benefits of that.
So, if you're curious about this topic, which a lot of people are, maybe jump
back and listen to #268 as well.  Sorry, Murch, go ahead.

**Mark Erhardt**: Oh, I was out that week, so I didn't even know.  Cool.  So,
next is taproot miniscript.  People are maybe aware of miniscript in general as
a way of writing more complex scripts, but having a human-readable input, so
you're basically just abstractly telling what you want, and it produces the
Bitcoin Script for you.  So far, we have that for P2WSH output scripts, and now
we also have that for taproot, P2TR script trees.  So, that's going to be new,
and I think that's going to maybe be a first step for people that want to do
cooler stuff for their wallets.  Now that we have that for descriptors, we have
ways of exporting and importing very simply complex scripts.  And that makes it
easy for people to, for example, formulate a decaying multisig policy, or like
I've seen a GUI that clicks together a more complex policy for outputs.  And you
would just have new ways of interacting and constructing the conditions for
which outputs are spendable, and it all gets just shuffled away into a taproot
tree and you don't have to deal with the details of it, it hopefully should just
automatically work in your wallet.

**Mike Schmidt**: I'm going to plug again here our Recap Podcast #273 where for
a unique situation, we actually brought on Antoine, who's the author of Bitcoin
Core #27255, which is porting miniscript to tapscript.  We had him on to talk
about that particular PR, because it was interesting enough to jump into a
discussion with him, even though it wasn't a news item.  So, we're excited that
these folks can jump on and talk about these particular ideas, so I feel like I
should be plugging those discussions.  So, that was #273 to talk about mini
tapscript.

**Mark Erhardt**: Yeah, then we have all the plumbing working for assumeUTXO.
AssumeUTXO will be a way of more quickly bootstrapping a node so you can use the
wallet quickly.  Basically, you're jumping in with a more recent snapshot of the
UTXO set and then just process the blockchain starting from that height to the
current chain tip, and that way you're completely caught up with the current
UTXO set.  You can unilaterally on your node evaluate whether transactions are
valid, you could mine or do other things.  So, you'd have a node that is caught
up with the network and synchronized with the chain tip much quicker, because
you're just going to have to process a couple of months or a few months of data.

In the background, the node will perform a full validation of the remainder of
the chain, starting from genesis block to the height of the UTXO snapshot that
you input, and once it has finished that, it will verify that the UTXO snapshot
that it started with was correct.  This is hardcoded in the client, so you can
provide your own UTXO snapshot.  All this plumbing is working now, and this
release does not yet have such a snapshot hash, I think, but we'll probably have
one next; or Pieter, do you remember?

**Pieter Wuille**: I haven't followed up on this project in detail, but I think
the big missing piece is a question of where will you get the snapshot?  And
that's just an unanswered question at this point.  Everything that's in is the
framework for importing them, but the next big question is still open.

**Mark Erhardt**: Yeah, I think we don't have a hash for a snapshot yet in this
release, and the mechanism by which the snapshots would be distributed or made
available is also a work in progress, so we'll probably see that in the next
major release, or maybe the second next.

Finally, we have a new experimental RPC for submitting packages of transactions
to your node.  This is, for example, useful if you want to close an LN channel
that was created at way lower feerates and currently cannot be closed because
you just can't broadcast the commitment transaction, and you have a child
transaction that provides more fees, but the parent transaction is under the
minimum feerate of your node.  You can now submit a package of a single parent
and a single child to your own node, and that way add it to your own mempool,
allowing it to be mined.  We do not have in place relay yet for these packages,
but work on that is progressing.  Yeah, this is the submitpackage RPC.

Oh, yeah, we have the importmempool RPC too, which allows you to import a
mempool snapshot, which is sort of just a similar feature to what we had
already.  When you shut down your node, we write out our current mempool and we
also import it when we start up the node again.  So, now we can also import
mempools from other sources.  So, for example, if you had a running node and you
want to bootstrap a second node that you're just starting up with the running
node's mempool, you could export the mempool on the node that was online and
import it in the freshly starting node.  That's mostly useful for doing stuff
with your own nodes.  You should not accept mempool snapshots from other users
because they can bypass the transaction validation that way, or change the
priority on transactions.  So, for example, if you set a custom feerate per
which a transaction should be prioritized into a block, that would propagate
with an exported mempool.  So, don't let someone give you a funky mempool, but
if you want to trade mempools between some of your nodes, you could do that, for
example.  Anything that I missed, Peter?

**Pieter Wuille**: I don't think so.

**Mike Schmidt**: Great overview, great release.  Thanks to everybody who put
their time and attention towards authoring code that went into that release,
testing it, discussing on the mailing list, going through the Testing Guide.  It
takes a lot of effort and I want to thank everybody for that.

**Mark Erhardt**: Oh, I wanted to say something about something that's cropped
up on social media recently.  I just wanted to mention something about the
Bitcoin Core release cycle.  So, Bitcoin Core always maintains the branches of
the last two major releases.  So currently, we would consider v26 and v25
maintained.  So, bug fixes will be released in minor releases, like maybe we'll
put out a 26.1 that fixes issues with 26, and we might backport some of those
fixes also to the 25 branch, which then would be, I think, 25.2 at this point.
However, older branches are not maintained.  24 is now in end of maintenance.
So, once 26 is released, we will no longer backport fixes to 24, except if
there's a critical security issue, depending on the severity, it might still be
backported.  23 is end of life.  So, 23 does not get any patches anymore.

If you're running an old node, and you want to take advantage of current bug
fixes and so forth, you should consider to run releases from the last two major
branches, or at least look at what bug fixes get released for those branches if
you're running an older version, so you might be able to backport specific
things that you want to fix in your older version, if you have some special
reason why you're still on an older version.  Otherwise, I would heavily
recommend that you run one of the maintained versions.

_LND 0.17.3-beta.rc1_

**Mike Schmidt**: Thanks for that call out, Murch.  We have one other release
from the newsletter this week, LND 0.17.3-beta.rc1.  There are three bug fixes
in the release notes at the moment.  Some of those, I think we covered one of
the concurrency issues previously; there's an issue with an old version of Go;
and there's also a bug that could cause LND to hang during shutdown.  And then
there's one performance improvement listed in the release notes, optimizing the
memory usage of the BTC wallet dependency and the use of BTC wallets mempool,
which requires folks to be using bitcoind v25.0 and above to take advantage of
that optimization.  Anything to add there, Murch?  Okay.

_Bitcoin Core #28848_

Moving on to notable code and documentation changes.  I'll take this opportunity
to solicit any questions or comments from the audience.  Feel free to reply in
the Twitter thread here, as some of you have already done, or request speaker
access.  We have two PRs this week.  First one is Bitcoin Core #28848, which
changes the submitpackage RPC error handling to make it more helpful when any
transaction fails.  Murch kind of went through the usage of submitpackage
earlier when going through 26.0 release.  The PR author, who is here, noted,
"Rather than make judgment calls on what error is important (which is currently
just return the 'first' error), we simply return all of the errors and let the
caller of the submit RPC function determine what's best".  I think there was
maybe some confusion with if you just get the "first" error and there's a bunch
of other ones, it's maybe harder to debug.  There's also a couple bug fixes that
are also in this PR in addition to the better error handling that I've
mentioned.

_LDK #2540_

Last PR this week is to the LDK repository, LDK #2540, and this adds to LDK's
blinded path support by supporting forwarding node as the intro node in a
blinded path.  The PR notes, "The next PR, which is LDK #2688, adds support for
receiving to a multi-hop blinded path".  Then after that, they're going to
follow up with complete blinded forwarding support.  So, they will not be
advertising route blinding support in their feature bits just yet until some of
those other PRs are merged.  And this blinded path PR is also part of LDK's
BOLT12 offers project tracking issue, which lists all of the tasks and PRs that
are required to implement BOLT12 offers in LDK.

**Mark Erhardt**: So, can you tell us what an intro node is?  I'm not sure
that's clear from the text.

**Mike Schmidt**: My interpretation of that, because I saw that it was the
terminology used in the PR, but the way I interpreted it is that it's the first
node in a blinded path, so the initial node.  And right now, I believe LDK only
supports single hops, which is why they need to add the multi-hop there.  So, if
you're the first node in that blinded path, you can be supported if it's a
single hop, and they need to add the multi-hop after that.  So, I don't know.
Oh, sorry, go ahead.

**Mark Erhardt**: Oh, no, I see!

**Mike Schmidt**: Murch, I don't see any request for speaker access or any
additional comments in the Twitter thread.  Anything you'd like to say before we
jump off?

**Mark Erhardt**: No, all good.  I hope you have a nice vacation or trip.  And
next week will be Dave and me hosting.  And then, I think we'll see you back in
two weeks, right?

**Mike Schmidt**: Yeah, yeah, thanks for that.  It'll be good to have some time
off.  And I think we did a dry run today, and you should be good with Dave, and
I think listeners are in for a real treat with you two powerhouses riffing on
Newsletter #281.  Pieter, thanks for joining us; Matthew Zipkin, thank you for
joining us.  Thanks for the questions from Larry and Abubakar.

**Pieter Wuille**: Thanks for having me.  Bye.

**Mike Schmidt**: Cheers.

{% include references.md %}
