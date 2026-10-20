---
title: 'Bitcoin Optech Newsletter #377 Recap Podcast'
permalink: /en/podcast/2025/10/28/
reference: /en/newsletters/2025/10/24/
name: 2025-10-28-recap
slug: 2025-10-28-recap
type: podcast
layout: podcast-episode
lang: en
---
Gustavo Flores Echaiz and Mike Schmidt are joined by Abubakar Sadiq Ismail and Carla Kirk-Cohen to discuss [Newsletter #377]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-9-29/410193424-44100-2-e89aed24d449a.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #377 recap.
This week, we're going to be covering an idea to use the cluster mempool project
to detect block template feerate increases; we also have a news item that covers
simulation results from channel jamming mitigation testing; and we have our
monthly segment on Changes to services and client software, and our weekly
segment on Releases and Notable code changes.  This week, Gustavo and I are
co-hosting and we're joined by two special guests.  Abubakar, you want to
introduce yourself?

**Abubakar Sadiq Ismail**: Sure, Mike.  Hi, I'm Abubakar Sadiq, I am a Bitcoin
Core contributor.

**Mike Schmidt**: And Carla.

**Carla Kirk-Cohen**: Hi, I'm Carla, I work at Chaincode Labs focused on LN
protocol things implementing in LDK, and particularly on mitigating channel
jamming attacks.

_Detecting block template feerate increases using cluster mempool_

**Mike Schmidt**: Awesome.  Thank you both for joining us this week.  If you're
following along with the newsletter, we're going to go in order, starting with
the News section.  The first news item is titled, "Detecting block template
feerate increases using cluster mempool".  Abubakar, you recently posted to
Delving Bitcoin about tracking mempool updates using cluster mempool, so that
nodes can quickly rebuild block templates only when feerate improvement exceeds
some threshold.  Maybe to give us some background, you can explain how does
block template building and feerate increases work now, and what's wrong with
that, and then we can get into your proposed approach?

**Abubakar Sadiq Ismail**: Sure.  So, currently when miners want to determine
whether there is enough fee increase in the block template they are mining, they
repeatedly pull getblocktemplate RPC.  They maintain a delta that they obviously
want the fee increase in the new block template they are building to pass before
they submit to the miners that are working on the block template.  So, that is
inefficient.  And Bitcoin Core v30 has recently introduced a new mining
interface that allows miners to instead subscribe to block templates fee
increase basically, or when the chain tip changes.  It's called waitnext().  And
when we build a block template, they can just call the waitnext().  And whenever
there is enough feerate increase that surpasses the delta, we return the block
template to the miner.

Internally, how waitnext() works is also similar to the approach that miners are
currently using, which is basically rebuilding a block template every second.
So, when the waitnext() is introduced, we had lots of discussion with other
contributors on how to improve on that, because it's inefficient.  Whenever we
generate a block template, it's expensive and it locks some critical mutexes,
like cs_main and mempool.cs, which delays transaction processing for the nodes
and sharing to peers.  So, that's how the idea came about, and with discussion
in-person with the main authors of cluster mempool.

**Mike Schmidt**: Okay, so I can understand why the polling would be inefficient
and so it sounds like in v30, there's now a push.  So, I can essentially
subscribe to these sorts of updates and then I only get updates when they occur.
But behind the scenes in v30, it's still done the inefficient way of just
continuously, every second, rebuilding the block, and then sending it out at
specific deltas; and then, you've now spoken with the cluster mempool folks and
you have a different approach?

**Abubakar Sadiq Ismail**: Yes, a cluster mempool is going to introduce a total
ordering of the mempool.  And whenever we want to build a block template, we
just select from the order until you fill the desired weights.  The main idea is
to basically track mempool updates in the background.  I recently posted on
Bitcoin Core issues about Block Template Manager which is going to handle that.
We maintain a scheduler thread that basically executes all notifications, like
when transaction is added, when transaction is removed.  So, post-cluster
mempool, I plan to add a new notification that whenever we update the mempool,
we are going to have the previous ordering and the new ordering, and the Block
Template Manager can just subscribe to that notification.  And if the mempool
update affects the previously built block templates, it will just copy the
feerates of the transactions that we updated.  And whenever you want to
determine whether there is enough increase, you can just calculate the delta by
subtracting what is removed from the block template and adding what is added
until you reach the desired weight, calculate the cumulative fees of the new
built block template, and compare it with the threshold that the miner wants.
If it's enough, then you regenerate block template.

You can do it even more efficiently, but without building a block template.  If
the update is small, like a couple of transactions, you can just naively add
them to the weight and see whether it's enough.  If it is not enough, you don't
have to look through and select between the newly-added and the previously-built
block template.  So, the post is all about discussing the idea and seeing what
is the better approach to implement that.  The Block Template Manager's PR to
core, it's not yet in, so all this is currently a work in progress, and looking
for feedback from other contributors.

**Mike Schmidt**: If you said it, I missed it.  Are there quantifiable
improvements?  I mean, I think it makes sense the way you've described it, but
I'm wondering if there's numbers behind this.

**Abubakar Sadiq Ismail**: Yeah, so each miner has their own threshold.  So,
whenever they subscribe to waitnext(), they will provide the threshold they
want.

**Mike Schmidt**: In terms of performance, though?

**Abubakar Sadiq Ismail**: Yeah, the performance is obvious.  We are not locking
cs_main, everything is running in the background in the scheduler thread.  So,
it's non-blocking, it's efficient.  So, there is no bottleneck that we
previously have, which is a good win for us in resource management.

**Mike Schmidt**: Makes sense.  And so, I suppose you're looking for feedback.
I think you mentioned that a minute ago, feedback on the idea.  Gustavo, I'm not
sure if you have any questions for Abubakar?

**Gustavo Flores Echaiz**: No, I mean, my question was similar to yours.  I was
wondering if there was any quantifiable performance improvements.  But I guess
it's very relative to the threshold that a miner chooses.  I think this is
pretty cool.  I mean, it sounds very clear once you explain it.  It sounds like
a simple idea.  But now that I looked at the Delving post, there are some
complex calculations, so I'm just excited to see this.  Thank you.

**Mike Schmidt**: Abubakar, do you have any indication of when cluster mempool?
Yeah, we are hopeful that it's going to be in by v31 because the milestone has
been added, so reviewing the PR alongside other people that are working on the
project.  So, most of the work has been already done.  I think what is left now
is integration between the low-level TxGraph and high-level mempool interface
that other components of the node interact with, which is TxMemPool.  So, yeah,
I'm bullish on that and hopefully it's going to be in the next release.

**Mike Schmidt**: Excellent.  Well, I suppose the call to action here is if
listeners are curious about this topic and want to provide feedback, jump over
to that Delving Bitcoin post and take a look at the details that Abubakar got
into beyond what we discussed today.  Anything else, Abubakar?

**Abubakar Sadiq Ismail**: No, you have said it all.  Thank you for having me.

**Mike Schmidt**: All right, thanks for joining us.  We appreciate your time,
Abubakar.  Cheers.

**Abubakar Sadiq Ismail**: Cheers.

_Channel jamming mitigation simulation results and updates_

**Mike Schmidt**: Our second news item from the newsletter this week is titled,
"Channel jamming mitigation simulation results and updates".  Carla, you posted
to Delving about some channel jamming simulation results, based on your work
along with Clara and also elnosh.  The simulation involved a reputation-based
algorithm to mitigate channel jamming, that we've discussed previously.  These
types of channel jamming attacks can affect the LN.  Maybe, Carla, quickly, you
can remind us about what channel jamming attacks are, and then we can get into
the mitigation and how you did the simulations.

**Carla Kirk-Cohen**: Sure.  A channel jamming attack is a DoS attack against
the LN.  This is something that we have long known about.  I think it was posted
about in the mailing list for the first time in 2016, but it's remained an open
vulnerability in the protocol since then.  And you can go about this attack in
various ways, but the summary of it is that you're aiming to exhaust the
resources in a channel.  So, a channel only has so much bitcoin in it, so you
try and use up that bitcoin and hold it in in-flight HTLCs (Hash Time Locked
Contracts), because we add HTLCs in one step and we remove them in a second one,
so you are able to hold things in this in-between state.  Or you can do the same
thing and try to take up the slots available on a channel, which is just the
number of HTLCs that we allow you to create outputs for on our commitment
transaction.

So, we have these two scarce resources and we have attackers who can pretty
cheaply consume them.  So, right now in LN, we do not charge any fees for failed
payments.  So, I think the easiest way to attack the network would just to be,
pick a few channels and send an endless stream of failing payments through,
right?  You're using up all of the slots, all of the liquidity, and you can fail
them back to yourself and it costs you absolutely nothing in fees.  So, that's
quite a trivial way to do it.  And then, the other way you can do it is sort of
a more sophisticated way, although I'd still argue it's pretty easy, which is to
send a bunch of HTLCs through the network, hold on to them for about two weeks
because we allow HTLCs to have quite long CLTV (CHECKLOCKTIMEVERIFY) values so
that they can resolve onchain if need be, and then release them again paying
absolutely no fees.

This is a very difficult problem to get around in LN.  I think the issue of no
fees on failure isn't that complicated, it's just a UX challenge.  But there are
various properties of LN that make this difficult to address, right?  It's
onion-routed, meaning you don't know where payments come from or go to, so it's
very difficult to attribute blame without compromising privacy.  We need to have
these CLTV deltas, because we have to be able to enforce these contracts on
chains.  So, we have this massive orders-of-magnitude difference between the
good case of an LN payment, which succeeds in less than a second, and the worst
case, which can be held for up to two weeks.  So, accounting for that range is
kind of difficult.  And then finally, we also have multi-hop payments.  So,
typically a LN payment will take three or four hops to get from the sender or
the receiver, and that's a very nice scalability property because without this,
you'd have to open up an LN channel to every single person you want to send to,
and that's not very scalable on the base layer.  But a side effect of this is
that an attacker can create these big loops of payments going through the same
people, trying to use up more resources than they would otherwise be able to.

**Mike Schmidt**: Okay, that makes sense.  I would actually point listeners as
well, for more background, we've had Carla on several times and highlighted her
and her team's work over the years.  So, go to the channel jamming attacks topic
on the Bitcoin Optech website and you'll see an overview of what Carla's
explained here, as well as some of the progression over time leading to where we
are today.  Carla, anything you'd fill in between then and now that you think
folks would need some background information to understand the simulation you
ran?

**Carla Kirk-Cohen**: I'll talk briefly about the mitigation, just because this
has been a problem that's been evolving over time.  And our work is by far not
the first work that people have looked into solving this.  That Optech topic
page is stacked with posts and different ideas and things that people have tried
to solve this difficult problem.  And I think that the insight that our work is
based on is from Clara's original paper, which came out a few years, which was
looking at characterizing this problem.  So, in the past, you can take all of
this great work that's been done by various people, and we can classify it into
monetary solutions, so solutions where you try and make the attacker pay, and
reputation-based solutions, where you sort of look at the way that someone's
behaved in the past, and based on that behavior, you perhaps grant them access
to more or less resources.  And none of that is new, this is just a
classification of these types of solutions that we've had.

But I think the insight from Clara's paper is that while in the past, we've
looked at one or the other, it's actually most suitable to look at both of these
types of solutions together to mitigate this sort of broad problem.  Because in
isolation, neither really fills the gap.  So, we've looked at monetary solutions
in the past, but where they always seem to fall apart is that it's very easy to
attach an unconditional fee on a payment that resolves in a second.  You can
make it a hundredth of a cent, and that seems reasonable enough UX to say, "Gey,
you're going to send this payment, but if it fails, you have to pay a hundredth
of a cent".  But then you have to account for the fact that in the worst case,
this payment could be held for two weeks.  And if you scale that hundredth of a
cent up, that means that you'd end up paying $120 upfront to cover the
worst-case scenario where this takes two weeks, and that's just like untenable
for LN, which is supposed to be tiny scalable payments.  So, monetary solutions
are really good at the happy case and the fast case, but they really fall apart
at the long-hold, slow-jamming case.

Then by contrast, reputation-based solutions are really good at looking at that
long-hold, slow-jamming side of things.  If someone has held on to a bunch of
HTLCs for two weeks, it's pretty sure that something not great is going on.  But
right now, reputation algorithm, any sort of reputation rule that you have is
going to have some threshold, even if it's moving, even if it's very
intelligent, you're going to say, "Okay, well if it resolves under a minute,
then maybe it's okay, I'm not really sure".  And so, that type of solution gets
very weak for the fast jamming case, when these payments are just flowing,
because you can't really classify them.  Any attacker you have would just fall
just underneath that rule, and you're more likely to catch honest people than
you are to catch people who are misbehaving.

So, our solution is what we call a hybrid solution, where we say, okay, we're
going to have to suck it up and have some unconditional fees, some really,
really small fees.  And the goal of this is to address that spam case, when
someone's just sending and sending and sending payments constantly, like a tidal
wave of payments to fill up the network.  If you're doing that and you're paying
a tenth of a cent, eventually that will add up over time, and that will
compensate the nodes that are being scammed like this.  So, we deploy a monetary
solution for the fast-jamming end of the spectrum, and then for the slow jamming
side of it, where we can't really deal with the fast things but we can more
easily identify long-held misbehaviors, we deploy this local-only reputation
system.  And we believe that by deploying both of these things together, we're
able to fill the gaps and comprehensively address this problem that has really
only been looked at in one way or the other, up until Clara's paper a few years
ago.

**Mike Schmidt**: And when you mention reputation, I think we've seen Eclair PRs
recently talking about HTLC endorsement.  Is that synonymous, or how do I think
about HTLC endorsement versus reputation?  Is that the same thing?

**Carla Kirk-Cohen**: There's a new name for it, because God forbid we do
something simple.  But when we first started thinking about this, we were
thinking about everything from the incoming direction.  So, we'd say, okay,
here's a peer that I have, they're sending me an HTLC.  They have good
reputation and they've sent me this signal saying they endorse it, which means I
don't think that this HTLC is going to mess you up.  So, it's all kind of
incoming-facing.  And then, if you've got an endorsed HTLC from a peer that you
think has good reputation, you would allow them full access to your resources,
because sort of like a friend of a friend, you say, "This thing is okay and I
think that you're okay, so I'm going to hand it on to you".  But what this
solution was missing, and this is the changes that we've made in this iteration
of the work, is that if you're only looking at the incoming side, you're kind of
forgetting that in LN, your downstream peer is the one that can hold onto
things.  So, an HTLC arrives and you forward it on.  The person down the line is
the person that you actually need to be worried about.  The person up the line
has very little control over how quickly this thing will resolve.

We ran an event.  When we had this first iteration of it, we asked people to
attack it.  And Matt Morehouse, who's an excellent security researcher who works
on the LN, had this idea of an attack where, "Hey, okay, if you're focused on
the incoming, I'm going to sit downstream and I'm going to hold on to HTLCs and
jam you, and your reputation isn't thinking about that".  So, in this new
iteration of the proposal, it's very similar.

**Mike Schmidt**: Is that sync attack?

**Carla Kirk-Cohen**: That's a sync attack, exactly.

**Mike Schmidt**: Okay, got it.

**Daniela Brozzoni**: Yeah, so he kind of syncs these HTLCs.  So, after that, we
were looking at our solution.  We realized that because the reputation element
is to address slow-jamming attacks and the person that is responsible for
solution jamming is downstream, we actually took the entire thing and flipped it
on its head.  So, now, rather than thinking about the reputation of the incoming
peer, we think about the reputation of the outgoing peer instead, because this
is the person that can actually mess you up.  And so, instead of having someone
send you something and say, "Hey, I think this is okay", we now look at our peer
and we say, "Hey, you have good reputation.  I've given you full access to my
resources, which I only need to do if my resources are jammed up and scarce.
I'm going to send you what I call an accountability signal instead of an
endorsement, and it says, 'Hey, I'm going to hold your reputation accountable
for this'.  So, if you do something funny with it, I am going to dock you".  So,
it's sort of a switch in direction.  And there are similar concepts, just take
everything you knew and flip it backwards and invert your entire implementation,
which is a fun piece of coding to do.

**Mike Schmidt**: Is that conditional?  Do you conditionally send those
accountability tokens, or you would always do it?

**Carla Kirk-Cohen**: Yeah, so it's just a 1 or a 0 that goes with the HTLC,
it's a signal.  And what I think is really neat about this is that with the
incoming version, we'd always set it to endorsed and then send it all the way
along, which was the worst case of like, "Hey, we're going to use all the
resources all the time".  But with this accountability change, which I think is
really nice, is that a sender can set it to 0, because they're like, "I'm
forwarding this HTLC, it's not using up any of my resources, I'm all good".  And
then, the next person receives the signal with 0, and they look at their channel
resources, and if it's wide open, green skies, nothing's going on, they can
forward it on with 0 as well, because like, "Oh, we're just using it, nothing's
congested, nothing's jammed up".  So, in the regular operation of the network,
we won't even notice this is there.  We'll just send it on, be like, "Hey, it's
not accountable it's fine".

But say I'm actually being targeted by a jamming attack, I'll receive something
which is not accountable and I'll look at my channel and I'll be like, "My
channel is really full.  But you, my peer, have good reputation with me.  So, I
want you to be able to use my last remaining resources, like you've built this
reputation with me over time".  So, then I can say, "Okay, I'm going to put you
in this special bucket of resources for my high-reputation peers, but I'm going
to forward it on to you and set this accountable signal.  So, now, you know that
you've received an HTLC and I have given you this special access.  So, tread
lightly with it.  Don't hold onto it, don't forward it onto someone who you're
not familiar with, because they don't have reputation, because then they might
hold onto it because you don't know them, and then I'm going to dock your
reputation".  So, it's kind of changing the direction, but I really like that
it's a sort of opportunistic upgrade.  Normally, obviously, our dream is that
none of this work ever comes into play, but the signal will almost never be
used.  And if it does, it's because the network or a channel is under attack.

**Mike Schmidt**: And for nodes that don't support that bit, I guess they would
just treat it how they would any other HTLC coming through and best effort, kind
of thing?

**Carla Kirk-Cohen**: Yeah.  So, we're pretty lucky with the way that we design
things in LN that we have this rule called, "Okay to be odd", meaning that any
message, TLV (Type-Length-Value), any field that has an odd number, you can
safely ignore.  But what I think we would do for this is, if this is the
solution that we choose to go forward with to mitigate channel jamming, is that
we would start by deploying a feature bit.  So, everyone advertises to the
network, "Hey, I know what this thing is, I'm able to relay it".  And then, we'd
wait some time to make sure the full network is upgraded and understands it, and
then eventually we would flip it to required.  Because you don't want people to
not be relaying this signal.  It only hurts them.  If I pass it on to you as
accountable and you ignore it, it's just going to hurt your reputation with me.
So, you're kind of an unknowing victim.  But if this is what we go with, we want
it to be a mandatory feature eventually.

**Mike Schmidt**: Okay, so that basically gave us all of the history here.  And
now, we want to hear about how you did the simulation and what came out of this.

**Carla Kirk-Cohen**: Sure.  This is the short bit, I think, which is nice for
once for me, that this isn't much news, but we've written a Rust simulator.
It's based on LDK and a project that I maintain, called SimLN.  So, we're able
to spin up an LN with made up channels that just maintain channel state and
orchestrate attacks against it.  And we have rerun the attacks that people like
Matt Morehouse came up with in that first iteration of this.  So, we've taken
the sink attack, which previously would defeat our mitigation, and rerun it, and
found that now our mitigation is able to very quickly cut off the reputation of
someone downstream who's attacking us.  And then, just to be sure that this all
still behaves the way that we think it will, we've also rerun basic what I call
resource attacks, so when someone just tries to saturate the full channel in a
really traditional channel jamming way.  And with those, we found that as
before, the amount that you have to pay to bootstrap reputation to saturate the
channel is many times over what the channel would have otherwise been earning
from forwards.  So, that we also consider to be a success for this mitigation.

**Mike Schmidt**: I see that you link to your repository, jam-ln.  That sets up
the simulation that you're outlining here, and then it's executed on SimLN?  Do
I have that right?

**Carla Kirk-Cohen**: There's a few pieces, but essentially, yes.  I use SimLN
as a library, I pull it in, I add some custom actions, and then what I really
like about the way we've implemented the simulator is that we just have a trait
in Rust, which is an interface in any other language.  And it's saying, "Hey,
here are the actions you can take, write any attack", and then that will be run
against our simulation environment.

**Mike Schmidt: **Okay, cool.  Well, I mean I think listeners are probably
curious about that, even separate from your particular research here.  Being
able to spin up and tinker around with a simulated LN is probably interesting
for folks.  I've sort of monopolized the questions here.  I don't know if
Gustavo or Abubakar have anything that they'd like to say as well.

**Gustavo Flores Echaiz**: Well, I'd just like to start by saying that this was
the clearest explanation I've ever heard from someone on this topic, so thank
you for that.  My first question was, is there any difference between the
implementations?  I know that Eclair and LDK have taken maybe a step further in
implementing HTLC endorsement, or whatever the new name is.  But maybe if you
know of any difference between the implementations and how they're mitigating
this, or how your simulation ran through different implementations, or maybe
this is not an important question, but if you have any insight on that, I'd
appreciate it.

**Carla Kirk-Cohen**: Sure.  So, the state of things at the moment is that the
relay of the signal is implemented in LND.  So, LND will just relay the signal
without changing the value or looking at it.  And it's implemented in Eclair
where they will both relay and set the value.  I'm currently working on
implementing it in LDK because then we'll have some good support across the
board.  And in the simulation, we are not yet running with real nodes.  So, we
do have another tool that one of my coworkers works on, called warnet, I'm sure
it's come up in Optech before, where you're able to deploy this big cluster of
nodes and you can actually plug in the LN implementations.  But this simulator,
because we want to be able to move fast and we want to be able to run large
networks without blowing up the Chaincode credit card too much, which I've been
guilty of in the past with some large LN networks, this is just a virtual LN.

It's really simple.  You provide us with a graph which tells us the topology
that you want, and then we will just maintain a channel state right we just have
a little map that says, "Here's my channel, here's my policy, here are my
HTLCs", and it implements forwarding without any of the networking messages, any
of the clunky pieces of the LN.  So, it's really good I'd say for thinking about
routing and payment-related things like channel jamming.  If you wanted to A/B
test a pathfinding algorithm, I think this would be really good, but it's not
suitable for something like say, if you're interested in a network-level
attacker who sniffs networking messages, because we don't even have networking
messages, we just have this really simple thing.  But what I think is great
about this is that I haven't run it in a while, but a few months ago, I was
like, "Oh, I'll just run the whole mainnet graph".  And I could run the whole
mainnet graph on my laptop, sending payments around with like 300 MB of memory
used.  So, it's very, very lightweight, it's very, very easy to iterate on.

Then the next step, I'd say you can work in this for a while, then the next step
would be, okay, now go spin up your warnet and run your larger simulation.

**Mike Schmidt**: Yeah, Abubakar?

**Abubakar Sadiq Ismail**: Yeah, I have a question.  Thank you for the
explanation.  How do you actually punish the person who holds on to the HTLC,
because you don't know who it is in the route?

**Carla Kirk-Cohen**: Sure, great question.  So, this is a key feature of our
mitigation.  It's strictly, strictly local only, right?  You are only concerned
with yourself and your peers, because any kind of global state or shared
information just opens us up to centralization and censorship and all the things
that we don't want in LN.  But the way that it works, I guess that you can think
about it applies along a chain.  So, our reputation algorithm very simply is, I
take a look at what my outgoing peer has paid me in fees, because that's not
forgeable, right, they've given me money for forwards to them over the last six
months, and I compare it to what my incoming link, which is the link or the
channel that I would lose if they do jam me, has paid me over the last two
weeks.  And then, I apply a costing function for the HTLC itself, assuming that
this will resolve at the worst case, right?  So, if it's got 50 blocks' expiry,
I assume it's going to take 50 blocks to expire.  And I will consider you to
have reputation if your revenue that you've paid me, your reputation, less that
HTLC cost, because I'm docking you pre-emptively to make sure that you don't
attack me, is greater than the revenue that I've earned on this incoming
channel, right?

I know you need that written down to grok it a little bit.  But what that means
is that I'll only give someone reputation if they have paid me already what I
seek to lose if they jam me, right?  So, you will only gain this reputation and
you have a longer period of time to pay it to me.  So, it's not like no one will
get reputation, but I will make that decision that like, okay, you as an
outgoing peer have been worth it for me.  So, I'm going to forward it on to you.
And then, the next node along the chain has the same kind of thing.  They say,
"Okay, well, what is this incoming channel worth to me?  Is the next outgoing
thing worth it to me?"  And maybe they're not, and that's like, "Well, then you
don't get reputation, because I would lose my incoming channel if you actually
end up attacking me".  So, it's a series of local decisions where everyone makes
a financial-esque decision about their best interests and they sort of line up
along the route.

Then, you asked how we dock it; it's quite simple.  We take that costing
function of the HTLC, which is essentially like, if you jam me, how much could I
have earned?  What's my opportunity cost of this having been held for five
blocks, ten blocks?  And we subtract that from what you've paid us, because
maybe you were doing a really good job, and then you turned around and started
being nasty, so we just start subtracting it off.  So, in that sink attack,
where someone sits in the network and they forward payments very nicely and it's
all very good and they build up reputation, then they turn around and try and
attack us, we quickly start docking their reputation because they're holding on
to these HTLCs.  And then they lose all of that "goodwill", and they're unable
to jam us because we docked them down so quickly.

**Abubakar Sadiq Ismail**: Yeah, nice.  I'm just seeing a scenario where an
attacker can sit in the middle and make some people in the hops also lose
reputation because it's local decision.  So, you have to make a very good
channel with someone, but because he is connected to the attacker then the good
channel is not the person attacking you, but that channel is losing reputation
because they are connected to an attacker.

**Carla Kirk-Cohen**: Yeah, I mean great point.  So, the way that this works is
that you only lose reputation on accountable HTLCs.  And I think that's really
important.  So, you only lose reputation at all if I have actually used my
protected resources and then you have screwed me.  You know, I said, "Hey, be
careful with this", and then you weren't careful with it.  So, when we're not
under attack, no one is ever losing reputation and they're only able to build
it.  But in your example where you have, say, an honest node, Alice, an honest
node, Bob, and then a mean node, Mallory, who's messing with Bob; and Alice and
Bob have this really good channel.  And Alice forwards a payment from Alice to
Bob, Bob will accept it, and Alice will have reputation because they've been a
really good channel.  And say Bob needs to upgrade that to accountable because
Bob's being channel-jammed.  When Bob turns around and looks at Mallory, he will
only forward that accountable HTLC on if they have built reputation.

If that next node doesn't have reputation and an HTLC has been handed to me and
I'm like, "Hey, be careful with this, this one used up my last slots, my last
resources", you actually will need to drop it.  And this is something that we
don't love about this, that we have to drop some traffic, but we believe it will
happen very, very seldomly.  But because I'll only forward this payment onto
Mallory if she's built reputation with me, and if she's built reputation with
me, then she has paid me what I seek to lose in my channel with Alice.  So, it
kind of balances that she can't get it unless she's paid me a lot.  And if she's
paid me a lot, I don't actually suffer the loss financially, because she's had
to pay up all this reputation for me to hand her this very precious, accountable
HTLC that could hurt my reputation with my great peer, Alice, who I care for so
much.  So, it kind of chains.

But you are right that there are some scenarios where people can try and mess
with reputation.  They can build up reputation and then try and sabotage people.
But mostly we have found, well, in all of our simulation, we have found that the
amount they have to pay will more than compensate you for that bad behavior.

**Abubakar Sadiq Ismail**: Last question.  Can peer gain back reputation or it's
just decreasing?

**Carla Kirk-Cohen**: Yeah, you can definitely gain back.  So, we will award you
reputation for any unaccountable HTLC that succeeds, right?  We'll give you the
fees, and then any accountable HTLC that succeeds quickly, I think is the -- so,
yeah, if you're just regularly forwarding payments, you should be racking up
reputation all the time.

**Abubakar Sadiq Ismail**: Thanks.

**Mike Schmidt**: Great.  That was a good segment.  Anything else that you'd
leave, Carla, as sort of a call to action for listeners, other than reading your
whole Delving thread?

**Carla Kirk-Cohen**: You don't even have to read the Delving thread, I know no
one likes reading long threads.  But I think my call to action is like, if you
are someone who likes breaking things, or you think, "Hey, she said something
and I think I can break it", simulator's up on GitHub.  It's called jam-ln, it's
linked in the post.  Just go and try and mess with it.  That's kind of the fun
part of doing security research, is that you put something out there, and then
you think, "Oh, is anyone going to break it?"  So, really, we're looking for
folks who are adversarially-minded or interested in this type of thing to see if
they can break what we've got here.

**Mike Schmidt**: Great.  Well, Abubakar had some prodding questions.  Maybe
he's going to spin up something.  We'll see.

**Carla Kirk-Cohen**: Yeah, he's going to wreck me!

**Mike Schmidt**: All right.  Carla and Abubakar, thank you both for joining us,
we appreciate your time.

**Carla Kirk-Cohen**: Thanks so much, Mike.  I'm going to drop off.

**Mike Schmidt**: Cheers.

**Abubakar Sadiq Ismail**: Thank you.

**Carla Kirk-Cohen**: Cheers, bye.

_BULL wallet launches_

**Mike Schmidt**: We have our monthly segment highlighting Changes to services
and client software in the ecosystem.  We picked out two for this month that we
covered this week.  First one is BULL wallet launching, and that is an
open-source mobile wallet, and it builds on BDK, so the Bitcoin Dev Kit, and it
supports a bunch of goodies that we talk about here on Optech, like descriptors,
labelling, coin selection; it supports the LN, the Liquid Network; it actually
has support for payjoin already, and hardware wallet support, and can also have
watch-only wallet functionality.  And there's a bunch of other features that
folks may be interested in as well.  Fairly comprehensive launch for a new
wallet, so I think that was pretty impressive and I think folks, from what I've
seen on social media, are supportive of the initiative.  Anything you'd add,
Gustavo?

**Gustavo Flores Echaiz**: No, really cool.  I think they are taking a good
approach with the focus on UX and at the same time privacy.  Their next plans
are to also add silent payments, Ark integration, which they already started
working on and announced.  Just to explain how it works, it uses the Liquid
Network to abstract the complexity of Lightning.  So, when you receive a
Lightning payment, it will do a swap with BOLTs to receive on Lightning or to
send Lightning payments.  And behind the scenes, it uses Liquid for that.  So,
that's a clever trick that other wallets, such as AQUA, are doing as well.  It
simplifies the user experience, but important to be aware of what's happening
behind the scenes there, but definitely very cool.

**Mike Schmidt**: Is that optional, or can I have a non-Liquid Lightning wallet
in BULL?

**Gustavo Flores Echaiz**: From what I understand, you cannot.  You can have an
onchain wallet and you can do onchain stuff, you don't have to use Liquid.  But
if you want to use Lightning, you have to use Liquid, because there's no it's
not a Lightning node, there's no channel complexity built in, which provides a
better user experience, but it's important to understand.

_Sparrow 2.3.0 released_

**Mike Schmidt**: Next piece of software was Sparrow 2.3.0 being released, and
that release for Sparrow added support for BIP353 human-readable Bitcoin payment
instructions, which is sort of the mike@bitcoinops.org-looking,
email-address-looking identifier that can then look up payment related
information.  So, I could, for example, have something like a silent payment
address in there, then people can pay me through that, or I can have a BOLT12,
etc.  And so, that's the BIP353 piece.  And they've also, along with that, added
support for sending to silent payment addresses.  So, if a silent payment
address is found through BIP353 lookup, you can pay it that way as well.  So, a
couple of interesting pieces of Bitcoin tech in there.  Gustavo, anything to
add?  You're good?  Okay, well I will turn it over to you for the Releases and
release candidates segment.

_Core Lightning 25.09.1_

**Gustavo Flores Echaiz**: Yes.  So, on the releases this week, we have two.
The first one, Core Lightning 25.09.1, also called the Hot Wallet Guardian
release, or the Hot Wallet Guardian release II.  And it has a couple of bug
fixes related to the bookkeeper and JSON-RPC listchainmoves, and a few other
fixes.  You can check the release notes for that.  It's mostly a maintenance
release, so no big news there.

_Bitcoin Core 28.3_

Then, we follow with Bitcoin Core 28.3, which is a maintenance release similar
to the one we covered last week of 29.2, which are all releases that backport
the important pieces of the 30 release, but not the extra features, just the
essential parts.  So, it has the multiple bug fixes.  However, it also includes
the new defaults for blockmintxfee, incrementalrelayfee, and minrelaytxfee.  So,
all those new defaults to the feerates that were added in Bitcoin Core v30 are
also backported to Bitcoin Core 28.3.  If you want to learn more about the
details of these releases, you can check out their release notes.  Anything to
add here, Mike?  Awesome.

**Mike Schmidt**: No, well maybe not directly on that topic, but I did see that
there were some posts from bitcoincore.org about the recent vulnerability
disclosures.  So, if folks are curious, check out their blog.  I think there's
four that are outlined.  I think they're all low at this point, but if folks are
curious about those, check that out.  And I think it does also, in each
blogpost, identify the releases that they were backported to as well.

_Bitcoin Core #33157_

**Gustavo Flores Echaiz**: Definitely.  Thank you for adding that.  Very
important.  Okay, we move on to the Notable code and documentation changes
section.  So, this week we got seven PRs we covered.  The first one, Bitcoin
Core #33157.  This one optimizes the memory usage in cluster mempool by
introducing a new type for SingletonClusterImpl and by compacting several
TxGraph internals.  This PR also adds a function GetMainMemoryUsage() that
estimates TxGraph's memory usage.  So, here, what was done first is just general
optimization of the memory usage that cluster mempool uses.  But also, it was
discovered that through just the existence of one type abstract called cluster,
that fit both instances of clusters with multiple transactions and instances
with just one transaction clusters, where you were losing a lot of memory on the
one-transaction clusters, because you were just using the same type as the other
clusters.  And it had just a couple fields that were non-essential.  So, this PR
introduces a new type for one-transaction clusters that removes all those
non-essential fields so that it can just reduce in memory usage, it can be more
efficient.

It also introduces that new function so that he can compute the reduction in
size that all these improvements do.  So, basically, the conclusion is that once
he runs the function, this overall amounts to 200 bytes per cluster, plus 64
bytes per chunk, plus 128 bytes per transaction, but only 224 bytes per
singleton cluster.  So, let's say you were using the previous type, you'd have
200 plus 64 plus 128, but creating this new single transaction cluster reduces
that to 224.  So, basically a savings of 150 per singleton cluster, 150 bytes of
savings, and just general savings overall.  So, anything to add here, Mike?

**Mike Schmidt**: I would just add that there seems to be a lot of activity
around cluster mempool.  We talked with Abubakar earlier in getting his thoughts
on using it for something that isn't directly the mempool itself.  And it seems
like, yeah, there's a lot of work to get this out, potentially for the next
version of Bitcoin Core.  So, exciting to see.

**Gustavo Flores Echaiz**: Yeah, it seems so finally.  At the same time, I've
been telling myself that a couple of newsletters ago, but it seems to finally be
getting to that point.

_Bitcoin Core #29675_

Bitcoin Core #29675 introduces support for receiving and spending taproot
outputs controlled by MuSig2 aggregate keys on wallets with imported musig(0)
descriptors.  So, on Newsletter #366, we covered that Bitcoin Core was
implementing the parsing of MuSig2 descriptors, which was required for this.
And now, on this newsletter, we see that the support for receiving and spending
these outputs controlled by MuSig2 aggregate keys is now added.  So, very cool
development.  This is one of the things I was looking the most forward to, so
it's exciting to see.  Anything to add here?

**Mike Schmidt**: It always takes longer than you think, right?

**Gustavo Flores Echaiz**: Yeah, it's easy to focus on.  Like, this is a simple
PR, but you always forget that there's all these groundwork pieces that have to
be built first.

**Mike Schmidt**: Exactly.

_Bitcoin Core #33517 and Bitcoin Core #33518_

**Gustavo Flores Echaiz**: Bitcoin Core #33517 and #33518 both together reduce
the CPU consumption of multiprocess logging by adding log levels and categories
to avoid the serialization of discarded log messages related to inter-process
communication (IPC).  So, basically, before these PRs, there was a lot of
unnecessary logging related to multiprocess.  Particularly, there was a lot of
unnecessary serialization of log messages that would eventually get discarded.
So, it was the node, the Bitcoin Core process, and the client that would attach
to the IPC interface that were just consuming a lot of CPU time unnecessarily.
So, the author found that before this PR, logging accounted for 50% of his
Stratum v2 client application CPU time and 10% of the Bitcoin node process.  But
it has now dropped to near 0% after this improvement.  So, just something you
could easily miss.  But once you look into integrating these log levels and
categories that are present in other type of logins in Bitcoin Core, then you
see a considerable improvement in CPU time consumption.  Any thoughts here?

**Mike Schmidt**: It makes sense.  I mean, IPC, it's been worked on for like a
decade under the multiprocess project.  But yeah, of course, when it gets out
into the wild, there will be things like these performance improvements and
whatnot.

**Gustavo Flores Echaiz**: Yeah, exactly.  Just I want to clarify that this was
hoped to be added in Bitcoin Core 30, but it failed to get added there.  So, it
will hopefully be on 30.1.

_Eclair #2792_

We move on with Eclair #2792, which adds a new MPP (multipart payments)
splitting strategy called max-expected-amount, which not only considers each
route's capacity, but it also factors in the success probability of using that
route with that amount.  So, previously, you would have two strategies, one
called full-capacity and one called randomize, which full-capacity would only
consider a route's capacity.  It would see the capacity of each route and push
it to each route's capacity limit.  And randomize would randomize the splitting
to save on space, to improve on privacy, but also just for a simplification
calculation process.  The new strategy not only considers the capacity, but also
the success probability.  A new configuration option is added,
mpp.splitting-strategy with these three options.  The old configuration related
to this is kept, which is called randomize-route-selection, and is a Boolean
config.  But this new configuration option is added.  So, now users could
technically use both configuration options.

This PR also adds the enforcement of HTLC maximum limits on remote channels.
You'd think this was already there, but this is probably like a fail safety
improvement to make sure that you never allocate more than the HTLC maximum
limit on those channels.  Anything to add here?  All good.

_LDK #4122_

We move on to LDK #4122, which enables the queuing of a splice request while the
peer is offline, starting negotiation upon reconnection.  So, basically, there's
no reason for a node not to be able to queue a splice request while the peer is
offline, although it wasn't allowed previously.  So, now you could, if your
peer's offline, you could wait and queue a splice request and then as soon as he
comes online, you start the negotiation.  There's also, for zero-conf splices,
LDK now sends a splice_locked message to the peer immediately after
tx_signatures are exchanged.  And finally, LDK will now also queue a splicing
during a concurrent splice and attempt it as soon as the other one locks.  So,
if two peers are, let's say, one starts the request of a splice a couple seconds
before the other one wants to start another splice request, previously the node
that failed to be first would simply stash away that request and not queue it,
but now he's going to queue it, wait until this first splice request from his
peer ends, to then start the negotiation of the other splice request.  Any
thoughts here?  Cool.

_LND #9868_

We move on with LND #9868, which defines a new type for onion messages, and adds
two new RPC endpoints.  First, SendOnionMessage, which sends an onion message to
a specific peer; and SubscribeOnionMessages, which subscribes to a stream of
incoming onion messages.  So, these are the first steps required to support
BOLT12 offers, which seem to finally be coming to LND.  It's just the basic
groundworks you need to support.  There's not much additional context to that.
Any thoughts here?

**Mike Schmidt**: It's good to see LND moving in that direction.

**Gustavo Flores Echaiz**: Yeah, definitely.  Honestly, I didn't think it would
happen, but here we are.  That's great to see.  Also, maybe important that LND
also has added support for blinded paths on BOLT11 invoices, but that's
different from their BOLT12 implementation.

_LND #10273_

LND, the final one we have is LND #10273, which fixes an issue where LND would
crash when its legacy sweeper, called utxonursery, would attempt to sweep an
HTLC that had a locktime or height hint of 0.  Why did an HTLC have a locktime
of 0?  This was an early-on bug that made that HTLCs could have that locktime.
It's not an intended use case, it's just something that could happen through a
bug, which doesn't exist, but someone found out that if it existed still and
that HTLC was created with a locktime of 0, then LND would crash when it would
try to sweep it.  Now instead, LND will successfully sweep those HTLCs by
ignoring that height hint of 0 and deriving the height hint from the channel's
close height.  So, LND is just like, "This is clearly not intended, so I'll look
for the height hint somewhere else".  Any additional thoughts?

**Mike Schmidt**: Yeah, no additional thoughts, that makes sense.

**Gustavo Flores Echaiz**: Perfect.  So, we're done for this week.

**Mike Schmidt**: Great, awesome.  Well, I want to thank Abubakar for joining us
and hanging on throughout the newsletter, and also Carla for joining us.  She
dropped a bit ago.  And Gustavo, thanks for again co-hosting and for everyone
for listening.  Cheers.

**Gustavo Flores Echaiz**: Thank you, Mike.

{% include references.md %}
