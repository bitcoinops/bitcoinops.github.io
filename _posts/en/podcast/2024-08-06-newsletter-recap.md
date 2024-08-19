---
title: 'Bitcoin Optech Newsletter #314 Recap Podcast'
permalink: /en/podcast/2024/08/06/
reference: /en/newsletters/2024/08/02/
name: 2024-08-06-recap
slug: 2024-08-06-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Sergi Delgado to discuss [Newsletter #314]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-7-6/384387483-44100-2-14e50098a717e.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #314 Recap on
Twitter Space.  We have a few news items this week; there's two recently
disclosed Bitcoin Core vulnerabilities before 22.0; there's some discussion
about block building with cluster mempool; we have Sergi and his network event
simulator for the Bitcoin P2P Network; and we have our usual releases and
notable code segments.  I'm Mike Schmidt, I'm a contributor at Optech and
Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on all sorts of
Bitcoin stuff.

**Mike Schmidt**: Sergi?

**Sergi Delgado**: Hey, folks, I'm Sergi, I also work at Chaincode Labs, mostly
on networking things and research-related activities and events.  So that's
basically it.

**Mike Schmidt**: Thanks for joining us.

**Sergi Delgado**: Thank you for inviting me again.  It's always nice to be
talking with you guys.

_Disclosure of vulnerabilities affecting Bitcoin Core versions before 22.0_

**Mike Schmidt**: First item from the newsletter here is titled, "Disclosure of
vulnerabilities affecting Bitcoin Core versions before 0.21.0", but Murch, you
and I were chatting before this, I think that should say before 22.0; is that
right?

**Mark Erhardt**: Yeah, I think we'll have to correct that.

**Mike Schmidt**: Yeah, okay.  Last month, we covered ten vulnerabilities that
were affecting pre-0.21.0 versions of Bitcoin Core, and that was in Newsletter
and Podcast #310.  So, if you're curious about those, jump back to that.  This
week, we're covering two vulnerabilities that affected the versions before 22.0.
So, there's two vulnerabilities here.  Niklas Gögge posted to the Bitcoin-Dev
mailing list and linked to those different announcements that you can read
about.  We can recap those here.

The first one is a disclosure of a remote crash due to addr message spam, and
this disclosure was classified as a high-severity issue.  And what could happen
here is that an attacker could send a bunch of addr messages to a victim node,
and then eventually overflow a counter used by Bitcoin Core that keeps track of
each new address announcement.  And it puts that in the address manager data
structure, and you could essentially overflow that counter.  Folks are probably
familiar with Bitcoin nodes gossiping transactions and blocks to peers but
additionally, nodes also gossip to their peers addresses of other nodes that
they know about on the network, so for example, the IP address of another
Bitcoin node.  And so, if you did that, I think it's 2<sup>32</sup> times.

**Mark Erhardt**: 4 billion.

**Mike Schmidt**: 4 billion?

**Mark Erhardt**: No, no.  So, you have to send over 4 billion addresses and you
can send, I think, 1,000 per message.  So, you'd have to send at least 4 million
messages and, well, I don't want to steal your thunder, but the fix is basically
just we don't process more than ten messages per second from a peer.  So, it'll
take very long to send 4 billion addresses.

**Mike Schmidt**: Is it ten per second or one per ten seconds?  I have it as one
per ten seconds.

**Mark Erhardt**: I might have mixed that up.  You might be right.

**Mike Schmidt**: So, ten times longer, potentially.  Yeah, that was the fix.
And actually, we, Optech, covered the fix in Newsletter #159, but at the time we
didn't know that it was a bug fix.

**Mark Erhardt**: So, yeah, at least in the old news, we said one per ten
seconds.  So, that would mean if you send an addr message with 1,000 addresses,
we wouldn't accept any more for about three hours.  And yeah, that's 100 times
slower than I claimed, and one per ten seconds, 40 billion seconds, so it's a
very, very long time.  So, I think that's a million hours roughly, and, yeah.

**Mike Schmidt**: Well, we got to fix that.  I mean, we're low time preference,
so someone might just be slowly attacking us over millions of years!

**Sergi Delgado**: I think you're right, by the way.  The PR description says
0.1 addresses per second, so that would check out.

**Mark Erhardt**: Okay, so we should probably also fix the newsletter from --
that's a long time ago; 2021?

**Mike Schmidt**: No, I think that's right.  If it's 0.1 per second, that's one
per ten seconds.

**Mark Erhardt**: Oh, okay, I'm still wrong, okay!  I think we could have also
been a factor 100 faster and it would still have been safe probably, because a
million hours is, what, like 40,000 days?

**Mike Schmidt**: Sergi, you mentioned in your intro that you do Bitcoin
Networking stuff.  This is a networking thing.  Do you have anything to add on
this vulnerability?

**Sergi Delgado**: I mean, not much.  This predates me contributing to Core.
But I think this is basically the good way of solving it.  The issue with addr
messages, or anything that are not transactions or blocks in the network, they
are basically free to send.  So, the main issue with this is that you can just
create fake addr messages and just continue spamming a note with them, right?
And apart from wasting their bandwidth with that, if you could also crash them
remotely without spending anything, that's as high severity as I would.  I mean,
it's not critical, but it's high enough.  So, yeah, I like the fix.

**Mark Erhardt**: There's also, of course, the concern of overtaking someone's
address book, the AddrMan.  If you can flood it with all sorts of junk you might
be able to more easily eclipse attack them.  So, there's multiple reasons why we
might not want to accept too much from a single peer.

**Sergi Delgado**: Yeah, that's true.  I mean, if that was the only thing that
this attack was doing, I think the severity would be lower, because poisoning
the AddrMan of someone, I mean it's a severe thing, but still requires -- it's
kind of like an intro to all attacks, like eclipse attacks, or stuff like that.
If you could crash the node too, that's only worse, which is the case here.

**Mike Schmidt**: Is there any sort of penalty mechanism in place?  I mean, even
now, if I'm getting one bogus gossip to message from a peer every 10 seconds, is
there any point where I just say, you know, "I'm done with you as a peer"?

**Sergi Delgado**: Not really, or not that I know about, at least.  Actually, a
lot of these penalty things have been dropped recently, because it's hard to
tell, you know.  I can just send you a bunch of addresses I've learned from
other peers, and then who should I punish?  Maybe the moment I got them, they
were reachable, and now I am sending them to you, and now they are not.  And if
I have to retest every single address I'm going to send you every time I'm
sending to you, that's adding more competition to my side.  So, in the end,
there are mechanisms to avoid you just filling your whole AddrMan with addresses
from the same group or that may belong to the same entity, and so on, in the
same way that there are ways of preventing you picking more than one address
from a small group, and so on.  But no penalty for just broadcasting that
information, as far as I can tell.

**Mike Schmidt**: The second vulnerability this week was the disclosure of the
impact of an infinite loop bug in the miniupnp dependency.  This vulnerability
was classified as a low-severity issue.  Miniupnp is an optional library
dependency in Bitcoin Core for helping, I think, essentially set up port
forwarding within a network when you're setting up your Bitcoin node.  All
right, Murch gave me 100, so pat myself on the back for that.  That library
itself had an infinite loop bug, which was reported to that repository.  And it
just so happened that Fanquake was checking activity on some of Bitcoin Core's
dependencies and happened to see that vulnerability, and then he found a way
that that particular vulnerability could be exploited within Bitcoin Core.
Essentially, it allows an attacker on a local network to pretend to be a UPnP
device, and then keep sending data to the Bitcoin Core node until it runs out of
memory.  Murch or Sergi?

**Mark Erhardt**: Yeah, not much to add there, but just a reminder.  So, some
Bitcoin Core contributors are actively working on going through all of the old
disclosures that are standing out, and there will be another announcement at the
end of the month with all the issues affecting nodes up to version 22.  We will
continue these disclosures every month until we have caught up to the last
version that is end of life.  And yeah, so if you're running a very old version,
that's your prerogative, but you might want to consider upgrading if you are
concerned about disclosures coming out, especially maybe if you're running your
business off of that node.

**Mike Schmidt**: This miniupnp dependency vulnerability example, it's
interesting because I think it's easy to say, "Hey, as a project, it would be
nice to minimize dependencies because there could be an issue", and a lot of
that talk seems to be theoretical when it's being discussed, and it's
interesting to have an example here.  I'm sure the library is great and all, but
these things happen.  And yeah, I think it's a good example of that.

**Mark Erhardt**: That brings me back to us removing Berkeley DB recently.  I
mean, we just have some stuff in there that's really old, and it's great to get
rid of as much as possible.

_Optimizing block building with cluster mempool_

**Mike Schmidt**: All right, we can move to the second news item this week
titled, "Optimizing Block Building with cluster mempool".  Murch and Sergi,
you're both in the office with Pieter, who's been doing a lot of the posting
about cluster mempool.  So, fortunately for me, I have no notes on this item,
and I'm going to punt it over to, Murch, you and, Sergi, if you want to chime in
as well.

**Sergi Delgado**: I'm going to leave it to Murch, to be honest.  I work by
Pieter, but this is Galaxy brain stuff that I haven't discussed that much with
him, and I think Murch has.

**Mark Erhardt**: Yeah, I've been part of a few conversations there.  So, I
think we've talked a bunch about cluster mempool recently.  The main idea is
that by looking at all transactions in the context of their relatives in the
mempool, we can figure out in which order we would process a cluster.  So, as a
reminder, a cluster is starting from any transaction, walking all of the
available paths to the parents and children, like parent transactions and child
transactions that are all unconfirmed.  And whenever you transitively keep doing
that and reach an end, you have found a cluster.  So, what cluster mempool
basically does is it just looks at all transactions in the context of their
relatives and then decides in which order it would mine those in a block.

So, as you're aware, block size is limited and when you reach the end of 4
million weight units, eventually you won't be able to fit whole clusters and
maybe not even whole chunks.  So, instead of only looking at chunks and at the
borders of chunks, where chunks are subsets of clusters that would be added to a
block template as a group, Pieter came up with a way how to efficiently consider
even sub-chunks.  So if, let's say, you're looking at a cluster and the best
chunk of that cluster would have the highest feerate that's available in the
mempool right now, but it doesn't fit into the block template anymore, you might
consider its sub-chunks, as in just cutting off the last transaction or the last
two transactions and looking at what feerates would be available if you pick a
prefix of the chunk.  And that allows us to greedily pick a block template tail
end that is, well, greedily a good score; or you could even use this to do a
branch-and-bound search to not only consider the greedy first option, but search
for a better composition of the tail altogether.

All of this is pretty far in the weeds.  I was actually a bit surprised that it
got such a big writeup in the newsletter this time.  But yeah, Pieter came up
with some little tweaks to the data structure and basically computationally,
it'll cost the same searching at the chunk borders or even searching sub-chunk
borders to compose detail end of the block.

**Mike Schmidt**: Thanks, Murch.  If you're curious, we spoke with Pieter, I
think it was in #312, about some other cluster mempool stuff, so feel free to
dive into that.  There's tons of Delving posts on cluster mempool as well to
level yourself up.

_Hyperion network event simulator for the Bitcoin P2P network _

All right, next news item, Hyperion network event simulator for the Bitcoin P2P
Network.  Sergi, you posted to Delving about Hyperion, which is a network event
simulator for Bitcoin.  It sounds like you've picked up the torch on Erlay and
that motivated the need for a simulator.  Maybe you can help tell the story for
us here.

**Sergi Delgado**: Yeah, that's exactly how it went.  So, as some may have
noticed, I picked up the torch for Erlay, around three months ago or so.  I was
helping review it back in the day, when I started working on networking stuff
here at Chaincode.  And then, eventually it looked like the whole thing stopped.
So, I talked to Gleb at some point, asking him if he would mind me continue
working on this.  It looked like he was happy, so I started looking to the code,
seeing what comments were outstanding, and what was the state of the
implementation.  Because minisketch has been a part of our library for a while,
but only little bits of Erlay were actually part of the codebase, or are part of
the codebase right now.

So, I started adding the things that were outstanding in the PR that Gleb had
opened, and then started talking with Pieter about some of the things that were
pointed out and were pending.  Also, I had like the luck of talking to Greg
Maxwell about it at some point, and some of the things were just to be decided.
Gleb did a bunch of simulations, picked some parameters that he thought were
good for the approach he was going for.  But addressing some of the outstanding
comments made things slightly different.  So, at some point, I was at least
unsure to what extent the results of the simulation were still relevant, or if
new things needed to be simulated.  And one thing led to another, and we ended
up changing substantial parts of how we decide what to relay and who to relay
it, what timers are we using, how many peers we do reconciliation with, and how
many peers we still do the normal inv / getdata transaction flow.

Just as a side note for those that don't know about it, I was one of them when I
started working on this, even if you have an early peer, that doesn't mean that
you're going to be doing set reconciliation with that peer all the time.  Like,
every now and then you pick some of those peers as normal fanout peers,
basically because Erlay works the best if there's a small percentage of normal
transaction flow.  If everyone has to reconcile everything with everyone, that
means that the reconciliation sets become big and the differences become big,
and Erlay works best when the difference are small.

So, I was kind of back into the benchmarks/simulation bench and thinking about
how to do this.  And Gleb had a simulator that was a fork of a general purpose
simulator in Java.  And I could have done some simulations there, but I had to
change part of the implementation to match what we were thinking about.  And to
be honest, I was not feeling maintaining a Java simulator, especially if this
was just a first step into having to keep changing it and going back and forth.
So I thought, well, if I'm going to end up rewriting it in Rust anyway, why
don't I start writing it in Rust from the first place, right?  So, I did.  I
mean, initially, I started working on the transaction, the inv / getdata
transaction flow, and that has been there for at least a couple of weeks.  And
right now, I'm finishing the Erlay flow, so I can have simulations with all
nodes being Erlay, and then with all nodes being non-Erlay and see how things
change.

Then the whole point of this is, we could have used all the stuff to simulate
this.  There's warnet, for example, which is great to test things that are, I
would say, further in the development cycle.  And you can test that with smaller
networks, but running actual Bitcoin code.  This is completely different.  We
are implementing here part of the logic that Core has for sending transactions
and invs, and so on and so forth, but you're not running the node at any moment.
And that means that you can actually run simulations of thousands, hundreds of
thousands, even millions of nodes, and it takes almost no time.  Like, I think
for the normal transaction flow, I ran a simulation of a million non-reachable
nodes and 100,000 reachable, and it takes around 50 seconds to simulate the
propagation of one single transaction.  So, for what we are doing, you don't
need more than that.  You want to see what's the bandwidth use of sending a
transaction that reaches the whole network, like how much -- or that bandwidth
is actually wasted or could be safe, if you were using like central
conciliation, and how it scales depending on the size of the network.  So, those
are the things that we are mostly interested in at this point.

So, yeah, I ended up posting it on Delving, mainly to see if someone can find
something that is not right.  I think the codebase is pretty easy to read, and
if you're familiar with how things work in Core, with respect to how often do
you send invs to a peer, and how do you group these things, like the difference
between inbound and outbound connections, and so on, it should be pretty easy to
follow.  And yeah, if someone has any recommendations, suggestions, like a
feature request, finds that something is wrong, which may be, just ping me and
I'll try to fix it.

**Mark Erhardt**: Cool, I think you pre-empted a lot of our questions already,
but let me try to recap a little bit what I understood in order to get everybody
in the boat that might not have followed all details right here.  So, Erlay is a
proposal to, instead of broadcasting every single transaction separately to your
peers, you would sync up what you wanted to share with your peers with what they
wanted to share with you.  And that way, if you were going to announce the same
things to each other, you don't need to actually announce it.  But you said that
that could be inefficient because the sets could diverge too much if everybody
only does set reconciliation.  Could you repeat what the concern there is and
what the solution was?

**Sergi Delgado**: Right, so pre-Erlay what did you do?  Just send, as you were
saying, like inventory messages containing the transaction caches of all the
things that you want to announce to a peer.  So, basically how it works is, if
you have knowledge of a transaction, whether you have created it or received it
from someone else, and you have knowledge of a certain peer knowing that
transaction, and we can define what that means, what you would do is announce
that transaction to a peer.  Normally, you don't do this on a one-to-one basis,
you create an inventory message that can hold multiple hashes at the same time,
and then you send that to a peer every now and then, depending on whether this
peer is inbound or outbound.

**Mark Erhardt**: So, you're saying that we remember for each peer which
transactions they told us about and which transactions we told them about in
order to de-duplicate our announcement.  So, we'll never tell them about stuff
they told us about and vice versa, and we'll never tell them about stuff we told
them about already.

**Sergi Delgado**: Exactly, that's how it goes, assuming that peers are honest
and there's no misbehaviour, and stuff like that.  But that's how Core would do
it.  The issue with this, and why Erlay was proposed, is that actually most of
these announcements are redundant, because you're connected to eight peers if
you're unreachable, right?  So, you're going to be receiving inventory messages
from potentially all these eight peers once you receive one transaction, or
you're going to be sending them to eight peers.  So, at some point, most of the
inventories that you receive are going to be redundant, because you are either
downloading that transaction or you already know it, but you still haven't
synced with that peer, and that's a lot of wasted bandwidth.

The ideal world for this would be every single peer just sends an inv message to
one peer, and then magically, the whole network becomes aware of this
transaction and they can all download it.  This obviously doesn't work because,
I mean it depends on the topology of the network.  It could be the case that you
pick a sync node, that we can call it, a node that will receive that transaction
and not send it to anyone else, so it means that you're wasting propagation
there.  But that would be the most efficient thing to do in terms of bandwidth;
you only send a transaction to a single node, and that node sends it to a single
node, and if there's no collision, then everyone in the network will get it.
That's impossible to do.  I mean, that's marvellous in theory, but it cannot be
done without whole knowledge of the network topology, which is not known by
design.

**Mark Erhardt**: So, if everybody only propagates every transaction to a single
peer, it would form a chain and a snake through the whole network.  But if
anyone drops it along the route, it would never get to half or more of the
nodes.  So, we clearly have to announce it to more than one peer.

**Sergi Delgado**: Exactly.  An in the current approach, we do it to all the
peers, right?  So, we could scale this down and be like, "Oh, I'm only going to
do it to half of my peers", something like that, and then you will save some
bandwidth.  But you will start running into these issues.  Like, if the network
has a specific topology that it's connecting a subset of the network only
through a certain low amount of peers, it could be the case that they never
receive it, right?  Plus, you will be scaling this, like 20%, 30%, 40%,
whatever, until you start reaching a point where you're not broadcasting this
enough.

So, a better way of solving this was Erlay.  That's the proposal that, I don't
remember when it was proposed by Gleb, Greg Maxwell, Pieter, and I don't know if
anyone else.

**Mark Erhardt**: Probably five years or so.

**Sergi Delgado**: But it was like, yeah, it was a long time ago.  And the idea
is, what if instead of having to tell you about every single transaction
independently, we can work with set differences?  So, I build a set of things
that I want to send you, you build a set of things that you want to send me.
Instead of using normal transaction IDs, we use shorter IDs, and we build this
in a way that is efficient to send.  So, when I want to tell you about the
things that I know, I send you these compact sets of things.  And then when you
receive it, you have your compact set of things that you are keeping track of
for me. You compute the difference of these two sets, and then you send me the
difference.  And then at that point I know, based on the set that I had and the
difference, I know the things that you're missing and you know the things that
I'm missing, and then we only send invs.  I mean, we default to the normal flow
with the things that we already know that we are missing, like you are missing
or I am missing, without having to send you all the stuff.

But again, this works good when the difference is small, like the heaviest
computation part in this whole flow is computing the difference.  So, if the
difference is big, it means that it's going to take you a "long time", to
compute that difference, plus the set of things that you're sending through the
wire, the reconciliation set, also scales with the size of the difference.  So,
if the expected difference is big, the data that I'm going to send you is going
to be big, which is going to affect the amount of bandwidth that you're saving.

**Mark Erhardt**: Right.  So, if I remember correctly, minisketch is sort of
information theoretically-wise black magic.  You have to send exactly as much
data as the amount of difference between the two peers, and they will be able to
recover it from this multi-variable, what is it, like an equation set?  They'll
be able to calculate exactly the differences as soon as you've sent enough data?

**Sergi Delgado**: Exactly.  The thing is, you can send it like as big as you
want, but then you're going to be wasting bandwidth, and the whole point of the
protocol is saving bandwidth, right?  So, the thing is, being able to predict
what this difference is going to be is where the whole magic happens.  And in
the end, if this difference is small, then the size of the set of things that
I'm sending you is going to be small, which is kind of the whole point.  So,
it's better to reconcile often than to just wait for several minutes or hours.
I mean, you're going to be reconciling on the second.  But yeah, just going for
minutes and minutes and hours wouldn't be a good approach for this.

**Mark Erhardt**: Right, so the difference between our reconciliation sets
should be very small, and that means that we will have to propagate some
transactions to our peers and then do the reconciliation with the other
transactions.  How do we pick the transactions that we regularly broadcast, or
do we send some transactions to some people and not others?  What's your
approach?

**Sergi Delgado**: You see, that's exactly what we're trying to simulate.  So, I
can tell you about what the current approach is for the open PR, but there are
some bits that actually motivated building the simulator.  So, right now what we
do is we pick what peer to fanout with.  Fanout is the way we call the normal
transaction, instead of reconcile.  We pick them on a transaction basis
randomly.  So, for every single transaction we receive, we pick a random peer
among the peers that we are connected to, and then we select that to do fanout
with.  Sorry, not a single one; right now, we do one peer from our outbound list
and 10% of the inbound peers, in case we have any.

So, we do that on a transaction basis, but there are some quirks here.  It could
be the case that that transaction that we're trying to send has dependencies,
right, mempool dependencies.  And if that's the case, then things start being
tricky, because if you have transactions with dependencies, you have to pick one
way of solving this.  You're either going to find out all the things, or you're
going to reconcile all the things, but you shouldn't be doing half and half.
Because if you do, it could be the case that by the time you send the invs, for
example, some of the transactions that you're trying to send are orphaned and
the missing part is part of the reconciliation set, or the other way around; you
reconcile and then some of those transactions are orphaned, because the parents
of those transactions were scheduled to be sent via fanout, right?  So, that's
something that you have to take into consideration.

It could also be the case that since we are using short IDs here, which are
shorter than the usual SHA256 hashes, there are collisions.  And if there's
collisions, then you have to end up sending both transactions using fanout,
because if a transaction in your end collides, you don't know if that's the one
that collided in the other end or it's the other way around.  So, it could be
the case that you add one of the colliding parts to the set, but your peer adds
the other one, and then that's going to make the reconciliation fail; not fail,
but not being as efficient.

**Mark Erhardt**: All right, so when you speak of fanout, that's the regular
old-style announcement, and reconciliation is, of course, the whole set of
changes you would announce.  And you're saying, if there are dependencies for
the transaction that you're about to announce, you would either put the whole
ancestor set into the fanout or the whole ancestor set into the reconciliation?

**Sergi Delgado**: Exactly.

**Mark Erhardt**: Go on.

**Sergi Delgado**: What we do actually is send all of them using fanout, because
otherwise we could get to the kind of, what's the word for this?  We could get
into the pathological case where everything is a dependency of everything else,
and then you'll end up adding all the transactions to the reconciliation set,
which is something you shouldn't be doing, because if you do, then Erlay doesn't
work in an efficient way.  And apart from that, right now the way we are picking
this is, as I said, one from the

outbound and 10% of the inbound.  But part of the motivation of Erlay was
actually being able to scale the amount of inbound connections that a node can
accept.  And if the amount of fanout that you do is dependent in any way,
linearly or even if it's like logarithmically, but if it depends on the amount
of connections you have, then it means that it's not going to scale free, based
on the number of peers that you have, right?

We are trying to simulate here, if there's a sweet number that you could use
that even if you scale the amount of connections that you have inbound in this
case, it still works properly.  Because if that's not the case, I mean it's fine
to have to pick a small number that scales with the amount of inbound
connections that you have, but that's also going to limit the amount of growth
or scale that you're going to be able to do with your inbounds.  It would be
real nice if we could find a number that is not proportional of the amount of
inbound connections that you have and allows you to reconcile at a good rate,
because if that's the case, then you could just increase the amount of inbound
connections that your node accepts without putting them into a high-bandwidth
burden.  But that's also something that we need to simulate.  There are some
simulations from Gleb doing that.  But again, we changed the approach slightly.

**Mark Erhardt**: Right.  So, for example, if you have an inbound connection
that is a light client that only connects to four peers, if only 10% of the
inbound connections hear about transactions, probably most light clients
wouldn't hear about unconfirmed transactions until the reconciliation right?
Sorry, I saw that Mike was jumping in.

**Sergi Delgado**: I missed that.

**Mark Erhardt**: I think it's all good.  Maybe we'll keep that for the next
time when you have some simulation results to talk about.  But it sounds very
interesting.  Thanks for the long-form explanation.

**Mike Schmidt**: I have a couple of questions.  Sergi, you mentioned the goal
with Erlay was to save bandwidth, and obviously you're still working on
fine-tuning some of these parameters, so maybe we don't know exactly yet, but
what are the ballpark bandwidth savings in such a future?

**Sergi Delgado**: Oh, I think that's, I don't want to say controversial, but
that's a challenge at least.  If you go to the original PR, or even in the open
PR that I have right now, most of the description and resources are the ones
that Gleb pointed out.  And different people have tested this in different
setups and have come with different numbers.  I think, if I remember correctly,
the theoretical maximum savings were around 40%.  And take this with a grain of
salt, because I'm talking completely out of memory, but I think some people
tested it and only got like around 10%.  So, again, I think this is going to be
best known once we find the parameters we're looking for and test it in that
sense.  This is just the first kind of iteration of retesting and re-simulating
all this like this.  This would need to even be, as I was saying, tested in
warnet, which once you're able to have an implementation that makes sense, is a
better benchmark environment, I would say; even simnet, and whatever.  But yeah,
I would say for the research that has been done so far, between 10 and 40.  I
would hope it's more on the 40 side than on the 10 side, but yeah.

**Mike Schmidt**: Jumping back to the library, the simulation library, Hyperion,
outside of Erlay, where else might this simulation tool be useful?

**Sergi Delgado**: I guess it depends on what we made out of it.  Right now, the
only thing that is implemented is transaction flow, but doing block flow, for
example, shouldn't be too crazy.  And then that would allow us to do block
propagation to see, I don't know, maybe compact block propagation versus normal
block propagation, or what percentages, I mean depending on how many peers that
you pick.  Martin was mentioning something recently that I thought, "Oh, that
would be a nice application for a block data simulation".  And of course, now I
don't remember it.  But anything that is about sending data through the network
and tries to analyze what's the bandwidth use of that and what's the propagation
time of that could be suited for this, but it will need to be coded on the spot.
Right now, it's just transaction stuff.

**Mark Erhardt**: Another thing that might be interesting to research here would
be transaction broadcast back pressure.  So, if someone is doing a lot of
replacements and transaction announcements, there's been long the thought that
-- so, block data is safe because it's hashed and therefore expensive to create,
but transaction data is basically free and therefore more of a DoS vector.  But
if we also just allowed every peer to only broadcast so much transaction data
per moment, that sort of thing might be something that could be simulated here.

**Sergi Delgado**: Yeah, that shouldn't be too hard to simulate.  I would say
the scaffolding for all that is already in place.  I guess, I mean there are
things that right now are simple and are kept simple on purpose.  But if we
start doing that, maybe we will need to add some random delays on like how long
a transaction takes to verify, and stuff like that.  Right now, we just don't.
It's like, you receive a transaction, the transaction is valid, that's it.  But
if we start playing with conflicts and how long something may take to verify and
stuff, then sure.  Right now, I think -- no, I don't think I actually know,
right now, the only things that have delays purposely put in place are messages
that are sent through the wire.  So, we try not to make it that I send something
and you receive that something at the same moment in time.  There's some random
network delays that are out there.  But you could also make it so you know
exactly what's the bandwidth of every link, and then you add a delay based on
the bandwidth, and so on and so forth.

**Mike Schmidt**: Sergi, anything else you'd leave the audience with before we
wrap up?

**Sergi Delgado**: No, not much.  If this is something you're interested in,
just try it out and break it, and tell me it was completely unnecessary, or not.

**Mike Schmidt**: Awesome.  Thanks for joining us this week.  You're welcome to
stay on, or if you have other things to do, we understand, you're free to drop.

**Sergi Delgado**: Thank you, folks.

_BDK 1.0.0-beta.1_

**Mike Schmidt**: Releases and release candidates.  We have BDK 1.0.0-beta.1.
We are not going to jump into this much, other than encouraging people to check
out the API, because I think they're trying to stabilize that as part of this
release.  We are going to have a contributor come on once this is officially
released to walk us through some of the details.  Notable code and documentation
changes.  If you have a question for Murch, Sergi or I, feel free to drop that
in the discussion or request speaker access.  We'll try to get that by the end
of these PRs.

_Bitcoin Core #30515_

Bitcoin Core #30515 adds a UTXO's block hash and confirmation count as
additional fields to the scantxoutset RPC.  When using the scantxoutset RPC, the
block height of the UTXO is shown, but because the block height can be
ambiguous, especially in the case of reorgs, that could be potentially
problematic.  So, with this PR, the RPC now also includes a response field for
block hash, which is the block hash of the UTXO.  Murch, anything to add there?

**Mark Erhardt**: No, I think that covers it.  It's just information that was
implicitly there already, but is now explicitly stated.  And in the case of it
being in the most recent block, for example, it might be unreliable in case
there are two competing chain tips, or yeah.  Anyway, so scantxoutset RPC now
adds these two fields, both block hash and a confirmation count, which was also
implicitly there because the scantxoutset response tells you the height at which
it was called as well as the height of the UTXOs it found, so you could just
calculate that from the difference.

_Bitcoin Core #30126_

**Mike Schmidt**: Bitcoin Core #30126, which introduces a function Linearize as
part of the cluster mempool project.  I know we had Pieter on, I mentioned in
#312, and we covered some cluster mempool stuff this week and also in #312.
Murch, is there anything particular about this PR that you'd like to highlight?

**Mark Erhardt**: Maybe just to clarify again, cluster mempool is an in-progress
project, and none of this is hooked up yet.  Once all the helpers and functions
and data structures are in there, I think we'll start to reframe the mempool and
the interface of mempool, or rather the interface will stay the same, but the
underpinnings of how the mempool internally works will then be adapted to use
cluster mempool.  So, Linearize is the implementation of all the theory we've
been talking about.  It finds an order in which transactions from a cluster
would be included in a block template.  And, yeah, so this is sort of a core
piece of the cluster mempool code.

_Bitcoin Core #30482_

**Mike Schmidt**: Bitcoin Core #30482, which involves a few different things,
but what we highlighted here was improvements to the getutxos REST endpoint.
There you could, instead of passing valid txids, you could actually, I think
there was an example of just sending like aa, and that endpoint wouldn't give
you an error, it would just fail silently, even though it was a clearly invalid
txid.  So, now there's additional validation for those parameters and it will no
longer silently fail, it will give you an error.  The PR also noted, "This also
starts a major refactor to rework hex parsing in Bitcoin Core".  Murch, do you
know anything about this hex parsing rework initiative?

**Mark Erhardt**: I do not, but it sounds good.

_Bitcoin Core #30275_

**Mike Schmidt**: Okay.  Some more to come on that, I assume.  Bitcoin Core
#30275.  This changes the estimatesmartfee RPC.  It changes the estimate mode
setting default from conservative to economical and, Murch, I'm sure you have
some things to say about that.  But conservative estimate mode is, it considers
a longer history of blocks, and then as a result potentially returns higher
feerates and it's also less responsive to short-term drops in fees; whereas,
economical mode can result in potentially lower fee estimates and is more
responsive to short-term drop in fees.  I saw that there was also a Delving post
on this topic titled, "Bitcoind Policy Estimator modes Analysis".  That was by
Abubakar, who was also the author of this PR, and it provides a lot of analysis
on fee estimation data that compares these economical and conservative
estimation modes.  So, check that out if you're curious.

**Mark Erhardt**: Yeah, so one thing that is well known in this space, I think,
is that the Bitcoin Core fee estimation is extremely conservative.  It tends to
lag behind; when there was a feerate spike and you want to send a transaction,
it can take a long time for it to recognize that a lower transaction feerate
would be plenty.  So, I think even with the economic mode, it's still fairly
conservative.  So, I'm not anticipating that this will cause a lot of trouble
for people, especially with RBF getting easier these days.  So, yeah, I think
probably most people that send transactions that are not with very high block
targets, they already look at other sources of feerate estimations.  If not, I
would encourage you to compare those, or looking at a mempool monitor for a
moment before sending a transaction.

_Bitcoin Core #30408_

**Mike Schmidt**: Bitcoin Core #30408 is an update to various documentation that
replaces the use of the wording, "public key script" to, "output script".  This
is based on the transaction terminology BIP.  Murch, that's your BIP.  What are
the details here?

**Mark Erhardt**: My BIP draft, yeah.  So basically, the way that presumably
Satoshi thought about terminology here is that you pack a public identifier of
your asymmetric key material into the output script, and he called that field in
Bitcoin Core, "scriptPubKey", and the input script he called, "scriptSig", which
for just a key-based output makes sense, P2PK, you had a pubkey in the output
and a signature in the input, and that was it, right?  And this sort of
translates to more complex output scripts, where you can still think of the
output script as in the abstract sense of public key and the input script as a
witness or a signature that approves that you're allowed to spend.  But I think,
especially with many of the more complex scripts that have come up in the last
few years, and multisig and whatever, a more generic term fits better.

So, I was proposing to call it output script, and apparently that's starting to
get picked up.  I mean, I'm sure I was not the only person that liked output
script, but apparently it's making it back into the codebase that originally led
to people thinking of this field as scriptPubKey.

_Core Lightning #7474_

**Mike Schmidt**: Core Lightning #7474.  This is part of Core Lightning's
(CLN's) offers implementation, part 5 of it.  I think we did parts 1 through 4
previously.  This one is titled, "Experimental range".  It's related to
experimental ranges that were added to the open PR to the BOLTs repo for the
offers protocol spec last month.  That commit in that open PR reserves certain
Type-Length-Value (TLV) fields, specifically TLV fields outside of certain
inclusive ranges, will result in a rejection of the offer and CLN, via its
offers plug-in, now has support for these experimental ranges.  I wish I could
explain more, but I quite frankly don't exactly understand what these
experimental ranges are for.  So, if Murch or Surgi do, feel free.

**Mark Erhardt**: Well, I'm going out on a limb here guessing, but a couple
years ago, they made the onion construction a lot more flexible with the TLV
fields, where you could basically pack arbitrary information into invoices, and
I guess now also offers, to leave a message for the sender or other things like
that.  However, if you do not define that at all, you may not be able to use it
as an upgrade hook in the future, so it seems that certain field names have now
been reserved and cannot just arbitrarily be used, because they are considered
to be a good place to upgrade the protocol at a later time.  That's just my
guess, though, from a very superficial read of this.

_LND #8891_

**Mike Schmidt**: LND #8891, which adds a new field min_relay_fee_rate to the
expected response from an external fee estimation API source.  So, in LND, when
requesting information regarding fee estimation, you can use an external API to
get that fee estimation information, and previously it was including fees by
block target, a few different block targets and corresponding fees.  Now, it
also includes an additional field, min_relay_fee_rate.

_LDK #3139_

LDK #3139, which was titled, "Authenticate use of offer blinded paths".  And
this PR was motivated from an issue on the repo that noted blinded paths are
probeable.  And the example we gave from the newsletter was a potential
attacker, Mallory, taking Bob's offer and requesting an invoice from each node
on the network to determine which of those belongs to Bob, and that would
obviously negate the privacy benefit of using a blinded path.  So now, LDK
includes a nonce in the offer's encrypted blinded path, instead of including it
in the offer's unencrypted metadata, as was the case before this PR.

_Rust Bitcoin #3010_

And last PR this week, Rust Bitcoin #3010, a PR titled, "Add length field to
sha256::Midstate".  An alternative proposed description for this PR was,
"Overhaul the Midstate API".  So, the Midstate type in Rust Bitcoin is an
obscure type that they recommend only should be used when you know what you're
doing.  It actually represents partially-hashed data, but it doesn't itself have
the properties of what you'd be used to with SHA256, or other cryptographic
hashes.  This Midstate is typically used to optimize the computation of full
hashes, and I see Murch has his hand up.

**Mark Erhardt**: So, we use SHA256d usually, which is double.  So, we hash
twice with SHA256.  The Midstate is the result of the first hash before the
second hash is applied.  And this, for example, was relevant for the ASICboost
discovery a while back, I guess, what is it now, ten years?  So anyway,
ASICboost used the Midstate to optimize hashing, I think, by 20%, and I have no
idea what Rust Bitcoin would use the Midstate for, maybe for mining.  But
anyway, the Midstate is the result of the first hashing step out of both.

**Mike Schmidt**: Yes, so it's an optimization in Rust Bitcoin.  And the example
of when you'd use that when you're not doing mining or ASICboost would be BIP340
tagged hashes, which always begin by hashing the same prefix.  And so, it makes
sense to hash that prefix once and then store the Midstate, and then hash any
future data starting from that constant from the prefix hash, rather than having
to do the whole thing over again.

**Mark Erhardt**: Thanks, I'm glad you jumped in that far because that totally
makes sense!

**Mike Schmidt**: Sure.  Yeah, and tagged hashes are essentially hash functions
that are used in schnorr and taproot specifications, essentially to make sure
that the hashes used in one context can't be used in another context.  So,
there's like this literal string which is the tagged hash name, and that's used
as a prefix to prevent collisions.

**Mark Erhardt**: Right, for example, that would have prevented this potential
attack with 64-byte-long transactions, where the txid can be confused for a node
inside of the merkle tree in the merkle tree for the transaction hashes.  So, if
there were tweaked hashes here that are tagged, then those two couldn't be
confused because the tag would be different, of course.

**Mike Schmidt**: That's right.  So, if you're using Rust Bitcoin's
Midstate-related APIs, make sure you review the changes to the functionality
here to make sure it doesn't break your usage of that API.  Murch, I don't see
any questions, so I think we can wrap up.

**Mark Erhardt**: Sounds good to me.

**Mike Schmidt**: Sergi, thanks for joining us.

**Sergi Delgado**: Thank you.

**Mike Schmidt**: Murch, thanks for being co-host this week and thank you all
for joining.  We'll see you next week.

**Mark Erhardt**: See you next week.

**Sergi Delgado**: See you.

{% include references.md %}
