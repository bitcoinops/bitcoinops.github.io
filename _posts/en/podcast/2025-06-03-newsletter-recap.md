---
title: 'Bitcoin Optech Newsletter #356 Recap Podcast'
permalink: /en/podcast/2025/06/03/
reference: /en/newsletters/2025/05/30/
name: 2025-06-03-recap
slug: 2025-06-03-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Carla Kirk-Cohen, Joost
Jager, and Elias Rohrer to discuss [Newsletter #356]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-5-3/401522428-44100-2-77051dca84d02.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #356 Recap on
Riverside.  Today, we're going to be talking about whether attributing LN
failures is bad for privacy; a bunch of Stack Exchange questions, a lot of them
about the Bitcoin P2P Network; and we have our regular Releases and Notable code
segments as well.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch.  I work at Localhost Research.

**Mike Schmidt**: Carla?

**Carla Kirk-Cohen**: Hi, I'm Carla, I work on Lightning Protocol at Chaincode
Labs.

**Mike Schmidt**: Joost?

**Joost Jager**: I'm Joost, I work on Lightning Development at Spiral.

**Mike Schmidt**: Elias?

**Elias Rohrer**: Hi, I'm Elias, I work on LDK and back in 2020, I authored a
paper on Lightning privacy.

_Do attributable failures reduce LN privacy?_

**Mike Schmidt**: Awesome.  Thank you, three special guests, for joining us.
You are all three going to contribute to our news item this week, which is, "Do
attributable failures reduce LN privacy?"  Carla, you posted to Delving a post,
actually about being nerd-sniped after an LN spec meeting.  It sounds like you
dove into some of the interplay between attributing these failures to privacy,
so the interplay between these two things.  Maybe before we jump into the
privacy implications, can you or one of our other esteemed guests explain, what
are attributable failures in LN and why would we want them to begin with?  And
then, we can understand why they're there and then what the implications are
from a privacy perspective.

**Carla Kirk-Cohen**: Sure, I think I'll swing that to Joost because he's the
author of the PR.

**Joost Jager**: Okay, I can comment on that.  So, attributable failures, the
word already says it.  Currently in LN, there are non-attributable failures.
So, if you have a multi-hop path, it is possible for a node to return basically
garbage data to its predecessor and they do all their transformation,
encryption, etc, etc.  But when it ends up at the sender, the sender is just not
able to make anything of it.  So, they know that the HTLC (Hash Time Locked
Contract) failed because it was released, but they don't know where the failure
happened.  And the problem of that is that they also cannot apply a specific
penalty to the node where it failed.  So, there's multiple ways to deal with
that.  Some nodes, they just penalize the whole path, but if you do that, you
quickly run out of nodes.

Yeah, that is the problem, it has existed forever.  It's not widely exploited,
but could be in a way.  Routing nodes could, for example, use this to hide
themselves if they have no liquidity, and then just return random data and then
hope the penalty will be less than when they would have honestly reported what
the problem was.  So, that is attributable failures.  It adds something to the
messages being passed back so that even if one of those nodes returns random
data, the other ones put HMACs (Hash-based Message Authentication Code), so sort
of like signatures on them to allow the sender to identify why the corruption
happened.  And then, when we were getting those nodes to do something more
sophisticated with the failure message anyway, the idea came up to then let them
also add a bit of data into it while they're at it anyway.  And that data is the
HTLC hold time.  So, nodes on the path, each is going to report how long they
held the HTLC.  And this can help the sender to identify the fast nodes and
possibly prefer those in future pathfinding.  So, it's two features bundled
together just because they affect the same area.

**Mike Schmidt**: When reporting the time that they held the HTLC, is that
something that is verifiable, or is that just gentlemen's agreement?

**Joost Jager**: It is verifiable to the point that the sender can take their
own measurements, so they know for sure how long the HTLC was in flight.  And
then all these nodes, they report how long they held it, so there is an upper
bound to that.  And it is in each of these nodes' interests that the sender
applies the penalty properly.  So, they apply either to the incoming or the
outgoing side, and it's in their interest so that it is as realistic as
possible, because if they would report different times, they can report whatever
they want obviously, it's a voluntary thing.  It could be that one channel is
penalized, which they don't want, because that is not the slow channel; the fast
channels could be penalized.  So, the idea is that there is some game theory
around it that makes all these nodes report the actual hold time.

**Mike Schmidt**: Okay, great.  Now we have a little bit of background of why
these things are being worked on, why there's value in attributing these
failures or delays as well.  What's the downside?

**Joost Jager**: I'm going to hand over to someone else, I think.

**Carla Kirk-Cohen**: Yeah, I can pick that up.  So, the reason this Delving
post came about is that we kind of got all the way to the end of the cycle with
attributable failures.  They're implemented in Eclair, they're implemented in
LDK, they've achieved interop, the spec PR is pretty close.  And when we
discussed merging it, this concern about how these reported hold times would
affect privacy on LN came up in the spec meeting.  And the question was, "Should
we report exact hold times or should we change the way that we encode these hold
times, so that we can protect some minimal amounts of latency on the network?"
So, instead of saying, "I held this for 3 milliseconds, I held this for 5
milliseconds", you'd say, "I held it for 100, 200, or 300 milliseconds", so
change that encoding to be buckets of time rather than an exact period of time.

The reason given was that we need to have some degree of forwarding delay in the
network.  So, when you receive an HTLC, you don't just send it on immediately,
you actually hold it for a small period of time to help protect the privacy of
the network.  And I was really interested in this because I'd kind of never
heard of it.  And we threw out this 100-millisecond value, which was a very
upsetting thing to me, because I don't like randomly hand-waved numbers.  So, I
kind of fell down this hole of reading a bunch of papers and really trying to
come to understand the different types of privacy.  I wasted a week, well,
debatably wasted, but I spent a week on it.  Now, I seem to be consuming
everyone else's time with it, so it's a very efficient nerd snipe.

But the idea is that attackers can try to watch payments flowing through the
network, either as an LN node who's making a forward, or as a higher-level
network attacker, someone who's actually responsible for transferring the
messages of the internet layer that the LN exists on top of.  And there's
various types of attacks, which maybe we can get into in more detail, where the
timing of payments plays a role.  And the concern is that, well, if we just
trivially report everyone's latency, it makes some of these attacks easier to
do.

**Mike Schmidt**: Carla, you outlined the two types of attacks that we
highlighted in the newsletter.  One was an attacker operating one or more
forwarding nodes, and maybe a more sophisticated high-level attacker that's at
sort of the IP network level observing some of these attacks, is that right?

**Carla Kirk-Cohen**: Yeah, that's right.  I think I'll throw it to Elias to
talk about the idea of an on-path attacker because this is where he wrote his
paper and it's really nicely explained there.  So, he can walk through on-path
and then I'll chat a bit about off-path after that.

**Elias Rohrer**: Cool.  Yeah, so the idea of an on-path attacker is pretty
simple.  And by the way, it doesn't have to be a forwarding node, it could be
actually the sender, because in the post-BOLT12 world with blinded paths, we
actually have something to protect there, because the sender doesn't always know
the receiver.  That wasn't the case when we wrote that paper back then.  So
basically, the attacker model was a forwarding node on the path that is chosen
by the sender.  And the idea is there that as a first step, basically, the
adversary would create a timing model of the network and basically would measure
out in some way how the hops are interconnected, how long it would take to route
over a certain route.  And you can create arbitrary large datasets by probing,
or there comes the first aspect of attributable failures.  In the current
proposal, a potential adversary might get these timing measurements for free by
these reports, that is one part of it.  And then, based on this timing model,
they could then, when a payment is forwarded over them, take a measurement of
the time from actually sending the updated HTLC message, so the HTLC forward
out, and then receiving a fail or a fulfill message for that message.  And by
doing that, they could learn basically how many hops, or according to their
model basically, how far they are away from the receiver, or according to their
probabilistic model, would do a maximum likelihood estimation, what is the
likeliest endpoint of that payment that was just forwarded.  So, that is the
idea of that attack essentially.

We could show that under certain circumstances, that actually works rather
nicely, and then proposed that forwarding delay would be one vector of
mitigation that we could take to mitigate that attack.

**Carla Kirk-Cohen**: And just to add a little bit on that we spoke about in
this post, I thought it was interesting that we're using a forwarding delay here
because really, the person who is most incentivized to look after their privacy
is the receiver.  But here, you're relying on forwarding nodes to do that for
you, right?  And not only are you relying on forwarding nodes, you also, as a
receiver, don't really know how many hops the sender took to reach you.  That is
by design.  And this kind of delay only works, I hope I've explained this well,
but if you add on sufficient latency that when that attacker goes and looks at
their latency model, they think, "Oh, this person could be two hops away or they
could be three".  It creates an anonymity set by adding this latency ambiguity.
And if the sender happens to be one or two hops away from you, say it's the
sender, one node, and then you, you're not actually able to add enough delay,
because maybe each of these forwarding hops is adding a little bit, but when it
reaches you on a shorter path, it doesn't really add up to something that
creates that ambiguity for the attacker, right?

So, one of the things that's come out of this, I think we spoke about this
yesterday in our latest spec meeting, is the idea of shifting this delay to the
recipient who is much more incentivized to actually hold onto the HTLC, even
though it means there's the tiny possibility that they might have to deal with
an onchain event or their peer going offline.  It seems much more reasonable for
that person, who cares about their privacy, to be the one to hold onto it.  And
Elias has just opened up a draft PR to the spec with some recommendations so
that we can think better about that on-path case and have better privacy for
receivers who choose to add that delay.

**Elias Rohrer**: Yeah, so the idea of that PR is that the receiver could take
basically the large part of that delay and could also make better estimations
how much delay there needs to be, because it's added once basically or the
largest part once.  And then still, we probably need some forwarding delay, some
randomized delay there, for the other attack model that we get later, but also
generally it's still good to introduce some noise into the network in general.
And by the way, it's not only good for privacy reasons, but basically any LN
node does batching of HTLCs and some kind of batch delay anyways for
I/O-efficiency reasons basically.

So, the idea of that is basically, if we add the most part of that delay on the
receiver end, we can reduce the forwarding delay that needs to happen in the
network a bit, but we still want to keep the incentive there to actually add
some forwarding delay, because for at least for the other attack model, we need
that, and also for the on-path attack in some cases.  And that is maybe how the
second part, where this relates back to attributable failures, because the
discussion was mostly around, do we want to incentivize basically dropping any
forwarding delay, or should basically that attribution, when it reports back
forwarding delays, should there be a threshold or some kind of bucketing so that
you would only report forwarding delays over a certain threshold to essentially
allow forwarding nodes to still apply some forwarding delay without fearing to
be penalized for it.  That is basically the discussion that arose.

**Mike Schmidt**: It's amazing how complicated something that's seemingly
straightforward, do it as fast as possible, LN is fast payments.  But yes,
there's always trade-offs.  I guess the trade-off here a bit for the end user,
is it going to be even noticeable, these additionally-reported delays, or do you
think from a UX perspective it's not noticeable?

**Joost Jager**: It depends on how much we're adding.  First we talked about, I
think, 100 milliseconds, but yesterday it was more like 400 milliseconds.  And
if it's a per hop, then yeah, it might be noticeable.  And for me, it is also
important to keep in mind that the future might be different.  Maybe some use
case emerges where people just want to have like a 50-millisecond payment for
some reason.  Yeah, I feel strongly about not adding constraints to the protocol
to make that impossible to measure.  I think that is what we're talking about a
lot, like does it actually matter to have this thresholding; will people notice;
what does it mean for the future?

**Carla Kirk-Cohen**: I can give a few numbers that we threw around in the spec
meeting yesterday.  So, a very badly researched number that represents the
amount of delay you can have before the human eye actually notices that
something is a delay is around 100 milliseconds, which is a pretty small number.
Yesterday, someone threw out that tap-to-pay takes just under a second right
now, or when it originally rolled out rather, but I haven't looked that number
up, so take it as you will.  But in LN, we need three round trips to add and
remove an HTLC, so to do the whole update_add, and send a commitment signature,
and then do the same on the way back and revoke everything; we need three round
trips, three networking round trips.

These are kind of hand-waved numbers, but I think it's reasonable to say that a
very good latency is 15 milliseconds, you're co-located in a data centre in the
same place; a reasonable middling latency is maybe 50 to 100; and then, if
you're running on Tor, you're looking at 300 to 600 milliseconds, and that's per
round trip.  So, this is something I realized looking at this, that this
100-millisecond number isn't real for us, really.  Three round trips, even at
the fastest, fastest latency, that's like 45 milliseconds, that's for a single
hop, right?  So, the minute you have a two-hop payment, which hopefully, most
payments in LN aren't just a single hop, there's not much point to that, you're
already starting to hit that 100 milliseconds.  And then, if you have regular
nodes that are not in the same physical location, think about 50 milliseconds
round trip, that's 150 per hop.  So, even me sending to Mike, if my node's in
Europe and yours is in the US, we're done, it's over 100 milliseconds.

It's not very clear to me what that number should be, which makes this kind of
difficult.  We can't really say what is latency that people will care about.  Is
it just as fast as possible; or is it like, this isn't the Visa network and we
need to pick a more reasonable value?  But I think this whole discussion, it's
just very difficult to design protocols for people that you don't really get
feedback from, and you can't.  And, as it turns out, I'm sure the Bitcoin
developers are pretty familiar with that, but we kind of have this back and
forth of like, "Oh, privacy loves a crowd and we need to design for privacy".
But what if one user wants really fast payments?  The answer is we don't really
know.  So, how do we design the best in between, which is conscious of privacy,
but also doesn't restrict use cases?

I think Joost's comment that he doesn't want to restrict the protocol, that is
that if we go with this block encoding of, say, 100, 200, 300 batches, which
probably isn't the number we'll use, but to roll this out on the network, we
would deploy this, people would have to upgrade their nodes to really use this
feature properly.  Every single node in your route has to be, well, not
everyone, but you want your full route to upgrade.  And it's really not trivial
to change once we've deployed it, I think.  We'd have to add a feature bit, we'd
have to change the TLV (Type-Length-Value), we'd again have to go through this
spec review writing process, everyone has to upgrade.  This is a thing that
would take realistically two years to happen, so we do want to try and get it
right now.  But what right means is difficult to say.

**Elias Rohrer**: So, on what you just said about having no feedback from users,
the issue with privacy is of course always that privacy and security, users
don't care too much about them or even see them as a hindrance in their UX,
because it slows things down or, I don't know, they have to enter passwords and
everything is annoying, until they're gone and they have severe consequences.
And privacy in particular is this hard thing, because you can't really measure
it until you basically see the consequences of the anonymization attacks a few
years down the line.  I mean, there are well-known examples by this where,
before they happened, you wouldn't have thought, and then the whole Snowden Five
Eyes revelation thing comes around and you're like, "Wow, this is not
tinfoil-head material, this actually happened.  And this kind of example happens
over and over again.  That is why it's always hard, basically, to argue also for
privacy preserving technologies, because it's essentially hard to estimate how
much protection you need until you actually know that that you failed at some
point.

**Mike Schmidt**: I have a question about, we talked about the end users and
it's hard to get feedback from them.  One constituency here are also the routing
nodes and I'm curious, I don't run a routing node, so does the topology of the
network change with this sort of introduction of additional latency, or is that
a non-factor for those kind of people?

**Carla Kirk-Cohen**: I think Elias has made the very good point earlier that
for some nodes, you will already want this type of batching, because every time
you add an HTLC, you have to write to disk in LN, so you remember your latest
state and all your signatures, and everything like that.  So, if you're a node
that has HTLCs flying through you, you're probably going to have batching
anyway.  Right now, I think LND has 50 milliseconds.  So, if an HTLC arrives, it
starts a timer of 50 milliseconds.  If a few more arrive in that time, they'll
all be sent out together once the batch is through.  But if nothing arrives in
time, it's just the single one that goes out.  So, for very small delays, people
do have some incentive because they want to batch anyway.  You don't want every
single payment just writing to disk and wearing out your hard drive.  But for
larger values, it's less clear.

This is also another concern that if we create this market for LN fast routing,
is everyone just going to go and patch their LN node and turn off any sort of
privacy preserving delay?  Because it is something that we're saying, "Hey, you
should be doing this", but even leaving pathfinding totally out of it, if you're
an ultra-competitive LN routing node, maybe you just want to turn this batching
off so that stuff clears as fast as humanly possible and you can have the best
return on your capital.  I don't think we're necessarily there in terms of
volume right now, but it is a difficult thing of like, this is a public good,
right?  Privacy is a public good and forwarding nodes would need to not turn off
that public good for these things to work.

**Elias Rohrer**: Yeah, and so the discussion around that, especially given that
the default on LND is a fixed 50 milliseconds, it could be argued that this is
not too far off.  So, if they were to make that randomized and maybe 50 to 100,
or something like that, that could be good enough if we also add receiver-side
delays, which LDK already does.  So, the discussion is not so much, do we want
to tremendously slow down LN more than it already is?  Basically, it's more
about adding a bit more randomness, and then the discussion about attributable
failures is, do we want to create that incentive to push that number down over
time, or is that kind of dangerous because we want to encourage maintaining this
forwarding delay basically?

**Joost Jager**: Yeah, I think something I wanted to say about all this is also
that what we're trying to do or what is being proposed is to push something onto
users through code or through the protocol that they may not want, so trying to
come up with an encoding that doesn't allow you to encode very low values.  And
I have severe doubts whether that will actually succeed in the long run, because
it does resemble to me the whole OP_RETURN thing and the filtering.

**Mike Schmidt**: Don't say it!

**Joost Jager**: I do want to say it, yeah, I think it's very similar.  It's
like trying to accomplish something through that, but there's also workarounds,
and is this a winning strategy in the end?  And in particular in LN, I think, if
you have a way to maybe in a way invite adversaries almost, like let's say we
would do this, we would be totally transparent about latency, it becomes easier
for people to build that latency map, and then we might have a problem.  And if
there's a problem there in terms of privacy, we might try to solve it.  Whereas
if we now just put some tape on it, just do a bit of rounding on the whole times
and move on with the next, more exciting LN topic, maybe it's also a missed
opportunity to fix this in the early stages, and we run into it again at a later
stage, and might regret that we haven't been so inviting from the very start.
And I see the analogy with hodl invoices.  They were also a topic of debate when
we were working on that.  People didn't really want hodl invoices because it was
bad for the network.  But in the end, it could have been done always and
probably would have been built in by users themselves, because it enables cool
use cases.  So, also there, I thought it was much better to just be open about
it, just add it, let them do whatever, and if it's a problem, then fix it in a
more robust way.

**Carla Kirk-Cohen**: And I'll spend three years working on that, fixing it in a
more robust way!

**Joost Jager**: Yeah.  I think here actually, there's a word for this, like in
biology, where continuous stress makes stuff stronger.  I think we're not in the
stage where we should avoid stress because now it's still fairly small.  And
this looks like a great opportunity to find a better way to combine very low
latency with privacy.  And I don't know what the solution looks like, but to me,
this type of filtering is not it.

**Carla Kirk-Cohen**: It definitely stood out to me, reading through all of
this, that we actually do need to know more about the off-path case, right?
Because I'm pretty satisfied, and it seems to be rough-ish consensus in
yesterday's meeting, that if we add these receiver delays, we should be okay,
more or less, with the on-path case.  But the off-path case is a lot more
nebulous and less understood to me.  So, I think I can back it up a bit and talk
about how that works, because we haven't really covered it, and then maybe go
into it a bit.  But the idea of the off-path case is you have someone who can
see the messages that you send over the internet, right?  Typically, this would
be a malicious, autonomous system who's part of the infrastructure of the
internet.  And I think the paper I read, something like 70% of the LN is in the
top five autonomous systems.  So, we're relatively centralized on the internet
layer.  I think Bitcoin has looked at this as well in the past, but as much as
we call ourselves protocol developers, we actually exist on top of another
protocol.

So, if we have this surveilling entity that's sort of on that layer, on the
internet layer, what they do, instead of forwarding HTLCs, is that they look at
the messages that LN nodes are sending each other.  And right now, those are
very identifiable, because we don't pad our messages.  So, the commitment dance
of a few messages going back and forth, you see 1,400 bytes going this way, then
you see 900-odd going that way, and it's an incredibly identifiable dance,
right?  And you're sort of this top-layer network adversary who sees me and
Murch do that dance, and then I turn around and I do it with Elias, and Elias
turns around and does it with Mike.  And it's very clear to this person that
this HTLC has moved through the network.  And I'm not totally sure about this,
but even when we do add padding, so say all of our messages are the same size,
there's still this really distinct direction that these messages flow in.  So,
it's really challenging to hide this from a very high-level network adversary.

The one way that you could do that is through something called constant bitrate,
which is essentially, we're always sending messages to each other and half of
them are fake all the time, but that's incredibly bandwidth expensive, right?
So, that's probably not something LN would do, I would think, but tl;dr, it's
very difficult to hide those messages from that kind of adversary.  And in the
attack that I looked at very specifically, what these adversaries would do, it's
actually really cool, is you find these chains of HTLCs and you're not seeing
the whole payment, but you are seeing all of these chains of messages sort of
ticking through the network, right?  And you use those to establish sort of a
start and end point of your route.  And you do some clever efficiency steps to
wipe out nodes that couldn't possibly have sent this payment.  So, like, if the
minimum value sendable is bigger than someone else's channel, you know they
couldn't possibly have used that channel.  And then, you take your individual
path that you've observed on the network and you run pathfinding between every
single node on every single other side.  So, you do tons and tons of using the
exact pathfinding that LND would have used, for example.  And then if you do
pathfinding between here and here, and the path doesn't go over the route that
you observed, you throw those people away.  And because our pathfinding is very
deterministic, you're able to identify a sender and receiver almost through
their pathfinding rather than through this incomplete path.

This paper does note that if we had a bit more chaos in our pathfinding, so if
between two nodes, we'd return different paths every time, this reduction of
that anonymity set would be much more difficult, because they say, I think the
medium size of those anonymity sets was around 10,000.  So, they really have to
do a lot of work with laying that down from 10,000 to a smaller number.  And
this is the one network level attack that we know of.  I think what was pointed
out yesterday is that even though this is -- because my feeling was like, "Oh,
well, this attack very specifically depends on pathfinding".  So, if we were to
make much more privacy, where it changes to our pathfinding, maybe it wouldn't
matter that people can create these chains so much.  But I've kind of come
around to the opinion raised yesterday that just because this one paper has this
one technique of taking these partial paths and doing a de-anonymization step,
it doesn't mean that there aren't others.  It just means that that paper hasn't
been written and we need a bit more research into these types of attacks to
understand them.

So, it seems to me that if people are able to make these chains, they probably
can do some funny privacy things, but we have no idea what those are right now.
And where the timing feeds back into this, I think, is that when you have that
high-level network adversary, if you have batching, more than one HTLC will be
moving at a time, ideally.  It's like, okay, you send this and you wait 50
milliseconds, and in that time another one arrives, and then they split out at
the same time.  And so, you're much less capable of seeing this sort of ding,
ding, ding through the network without forwarding delays, because it's so
instant that you can just trivially see it.

What I think is really difficult here is that the batching delay that you need
depends on the traffic that you have.  If you have tons of HTLCs arriving all
the time, then it matters much less, because you're covered by all this traffic
going everywhere.  But if you route HTLCs once a day, if you route one payment a
day, there is no delay that will help you, because it's just a single packet
without cover traffic or something made up to protect you.

**Mark Erhardt**: Yeah, I think you mentioned something similar before with
decoy traffic, but what if there were a modicum of decoy traffic?  Every time
you receive an HTLC, you send out packages to two other peers, so it's at least
1-of-3, giving it sort of an exponential growth; and if you get a decoy package,
people throw out one or two decoy packages to others?  Is that
bandwidth-prohibitive, or have you considered that?

**Carla Kirk-Cohen**: I don't know.  Honestly, right before this, I was trying
to remember what was wrong with Dandelion on the Bitcoin layer, because I'm
like, "Can we have, like, DandeLightning?  Maybe that would work, and it just
spreads out and provides a bit more cover without too much bandwidth use.  But I
haven't thought about it more than the five minutes before this call.

**Mark Erhardt**: Yeah.  So, Dandelion, the problem was that you behave
differently whether you have heard the transaction in your regular mempool, or
if you've heard it over Dandelion.  And it would basically mean that you need to
keep track of all of the transactions that you've heard about via Dandelion for
each peer, which would mean that you basically multiply your mempool size,
because you need to have a private mempool for every peer that you have, in
addition of your regular mempool.  And it opened up a dust surface.  But here,
we wouldn't have that problem, because we actually are routing only on a single
path.  So, we would only need to retain the information in that one direction.

**Elias Rohrer**: Yeah, I think the first step for mitigating this is actually
message padding, which we definitely should do, hopefully also soon.  I think
that there will be some research going on how much message padding or what the
best approach to message padding is.  So, do we need to pad all messages to the
same length?  Is random padding enough basically, and also exploring how much
traffic overhead will there be just from introducing message padding?  That's
the first thing, so that an adversary that can only see the message; packet
sizes can't infer the message in the encrypted packets.  And then, the next step
after that will be indeed to explore if some kind of cover traffic basically
will be reasonable.  I mean, if we already do batching, for example, in LND, it
would make sense to even talk about that.  I mean, these basic concepts have
been studied very, very well in the whole Mixnet literature, with different
Poisson mixing and time-mixing approaches, like Loopix, and so on.  So, I think
there could be a lot of lessons that we could learn and just take from that,
basically.

But yeah, I think the first step will actually be message padding, and then see
how much traffic increase that will already introduce.

**Carla Kirk-Cohen**: Do you think that with message padding, we're in a better
place in terms of the direction of those messages, because I fielded that also?
One of the papers hinted at the fact that even that might be enough.

**Elias Rohrer**: Yeah, I mean, yes.  So, this will be an issue.  I think we're
like, if you can't really discern which types of packets you're seeing as an
adversary and they look all the same to you, it will be quite a bit harder for
sure just to classify them.  But yes, you could still see -- I mean, what the
adversary sees is always a three-tuple, right, a sender, receiver, and basically
payload length or encrypted packet data, basically.  So, if you see then bursts
of messages going one way or just a specific exchange of commitment sign, revoke
and ack,, could leak some information, but then again a single HTLC handshake
might not be the only thing going on, even over a single connection at any given
time.  So, just having some additional noise in there, some pings going on, some
gossip being propagated, whatever, could be enough to really throw off,
hopefully, some of these heuristics, but we really don't know how much
mitigation we have.  And if we would, for example, add some additional pings,
that might be already enough once we have message padding.  I shouldn't say
'enough'; might go a long way, because we don't know what adversary we're
talking about basically.

**Carla Kirk-Cohen**: I'd imagine also, once you have padded messages, it makes
covered traffic way easier, because just a few things could throw off detecting
that dance.

**Elias Rohrer**: Yeah, or put it differently, if you don't have padded
messages, there is no reason to even start adding cover traffic.

**Carla Kirk-Cohen**: Correct, yeah.

_Eclair #3065_

**Mike Schmidt**: Any other follow-up questions or discussion for the group?
There's one related PR from later in the newsletter, but it's just tangentially
related.  It's Eclair #3065, which adds support for attributable failures, which
we just spoke about in the news item here.  It's disabled by default because the
spec isn't finalized, but cross compatibility with LDK has been successfully
tested.  I don't think anyone is directly involved with that.  But I guess maybe
to distinguish, the attributable failures is something that is being
implemented, and the question here is the privacy implications and whether
there's delays introduced, right, which is more of a question mark still?

**Carla Kirk-Cohen**: Well, right now the Failures PR has these hold times
expressed in milliseconds, so they're coupled.  So, the question now is, would
we go back and change the spec and then change both of the implementations and
redo interrupt to have this different encoding on the whole time?  And it's
disabled by default because the specification isn't finalized.  Interestingly,
sometimes what we do when we're doing interrupt and we're still wanting to merge
things is we add 100 to values.  So, we have message numbers and TLV numbers.
And when we're working on stuff and the spec is in process, we'll say, "Okay,
instead of this being TLV number 1, it's TLV number 101", and that gives us a
bit of flexibility of like, okay, once we actually hit the button on the spec,
we can then just switch to a new TLV type, and just throw away whatever maybe
needed to change without needing to do a big migration, or something like that.

But I believe that isn't the case here.  So, it is just using the regular number
and has been merged, but it is off by default.  So, hopefully no one runs into
it.  But that would be an implementation detail for Eclair, right, that if there
is a big change and they need to handle it, they need to do some sort of
migration.  But given that this isn't really widely supported work, I wouldn't
see it being much of an issue right now.

**Joost Jager**: But it is interesting that they already did the work that they
merged; LDK merged, LND PR is in progress, and there's also something open for
C-Lightning (CLN).  So, yeah, there seems to be actually, I would say, a lot of
support for the feature.  It's just a discussion about what to do with the
expression of the hold times.  That's something to decide on.  Yeah, they merged
optimistically with TLV type 1, but of course if this is not what we want, they
can just switch to 3 and then it's fine again.  I do remember now where the 100
millisecond came from, right?  This is because it's experimental, isn't it?  No,
I thought it was.  No, it was the old human eye, but yeah.

**Joost Jager**: Everything plus 100 now?

**Carla Kirk-Cohen**: Yeah.

**Mike Schmidt**: Well, excellent.  We will be reporting on any further
discussions on this, I'm sure, in the newsletter, and maybe have you folks back
to discuss further.  But it was great having all three of you on.  I thought it
was a great discussion, even if Murch and I aren't LN experts, it was great to
listen.  So, thank you all for your time.  You guys are welcome to hang on, or
free to drop if you have other things to do.

**Carla Kirk-Cohen**: I'm going to drop.  Nice to see you guys.  Thanks for the
invitation.

**Mike Schmidt**: Moving on to our monthly segment on Bitcoin Stack Exchange
questions, we have a handful, a lot of these P2P this month.

_Which transactions get into blockreconstructionextratxn?_

First one, "Which transactions get into blockreconstructionextratxn?" which is
the flag, I believe, for the size of what I've heard referred to as the
'extrapool data structure'.  And Gloria answered this one, sort of outlining
that that structure caches both rejected and replaced transactions that the
local node has seen.  And she also listed the criteria for exclusion and
eviction from that data structure.  I believe it's 100-transaction size cache
with a max size of 100k, and it's a first-in, first-out data structure.  Murch,
have you played around with the extrapool?

**Mark Erhardt**: I have not played around with the extrapool, but I was just
looking a little bit at the code around there.  And then, I actually had to ask
back because I wanted to know what the size limit is for transactions that we do
allow in the extra cache.  And it turns out that that is 100,000 bytes, which is
actually smaller than the standard transaction weight, and it also doesn't apply
to replace transactions.  So, it's a little odd in several ways.  So, for
example, big transactions just aren't kept in this cache.  It's also only 100.
There were some ideas of people with stricter mempool policies maybe using the
extra cache to retain the transactions, because when you get a block, it does
check in the recent rejects whether transactions are in there, before getting
them again from peers.  Well, it's starting to look like you'll at least have to
touch several different spots in the code in order to implement that.

**Mike Schmidt**: Yeah, I think that's probably why it bubbled up.  I believe
some of the pro filter people were saying that propagation wasn't delayed
because the transactions were held but not relayed, which is, I guess, exactly
what this data structure achieves.  I guess the question is, based on size and
the limit and the eviction criteria, how useful in a day-to-day operation a
cache of that size would actually be?

**Mark Erhardt**: I mean, it also stores invalid transactions.  So, someone
sending you invalid stuff will also churn this filter.  So, since we apparently
have reached a point where node operators are running their nodes in a more
antagonistic manner than ever before, we recently heard that one node
implementation is trying to eclipse another flavor of Bitcoin nodes.  I think if
people are starting to rely on this for better block processing, we might also
see someone churn the extrapool.  I'm not trying to give people ideas here,
please don't do this!

**Mike Schmidt**: So, that part stuck out to me, the invalid.  So, it would make
sense that I would cache something like a replacement transaction, because based
on the time of when a miner might see something, that might include some version
of the replaced transaction, and I have the one that they happened to see, even
if I saw a more recent one, let's say, that makes sense.  And the
restrictiveness on policy also makes sense for the reasons we sort of outlined.
Why would we keep an -- is there an intention behind that, or...?

**Mark Erhardt**: I'm wondering whether it's only invalid transactions that, for
example, had missing inputs, or something like that, so either because the input
was already spent in a larger transaction that we have, so a double spend would
be invalid if it's not a valid replacement.  But other than that, yeah, always
invalid transactions that could never be valid, just it's strange that they
would land in this pool.  So, I think I don't understand this spot in the
codebase well enough to explain that better.

**Mike Schmidt**: One of our listeners after, I think it was you and Sjors, did
the episode that included the OP_RETURN news item.  One of our listeners pointed
out that, I think Sjors had said that a Knots node would drop a transaction on
the floor.  And I guess correctly pointed out, depending on the size of the
transaction, that potentially it's not dropped directly on the floor, maybe it's
just pushed to the edge of a counter until another few transactions come in, and
then it falls on the floor.

**Mark Erhardt**: Right, yeah.  So, I think I heard some people make the
argument, "Oh, we could just increase the size of the extrapool and then keep a
lot more of these transactions.  That way we don't propagate them, we have them
when the block comes in", and that would achieve exactly what they want.  But I
would just point out that it was not designed for that.  So, if you want to do
that, you might want to design an actual data structure that does this.  Or I
think I might just turn off the relay on the transactions you don't want to
relay and keep them in my own mempool.  But I guess if you don't want a
transaction in your mempool, that will not solve your problem.

_Why would anyone use OP_RETURN over inscriptions, aside from fees?_

Next question from the Stack Exchange, related, "Why would anyone use OP_RETURN
over inscriptions, aside from fees?  Okay, so you can stuff data in the witness
which has the witness discount, or you can stuff it in an OP_RETURN which does
not have the discount.  And so, Sjors is sort of taking the fee part of this off
the table.  And he explains that in addition to sometimes being cheaper,
OP_RETURN outputs can also be used for protocols that need data available before
a transaction is spent; whereas if you put things in the witness data, that's
revealed during the spending of the transaction.  Go ahead.

**Mark Erhardt**: Also, it depends on what exactly is in the witness data.  You
could, of course, make a transaction that is equivalent but has a different
witness structure that also satisfies the input.  So, you might not be able to
rely on witness data before the transaction is confirmed.  This is not true for
inscriptions, of course, where the output requires the input to be spent with a
scriptpath that includes the inscription, I think.  I guess it could maybe also
be spent with a keypath spend.  Yeah, right.  So, witness data is malleable
until confirmed, whereas OP_RETURN data is assigned by the signatures and
therefore not malleable, assuming the transaction goes through, which of course
would be another way how witness data doesn't become available permanently.

_Why is my Bitcoin node not receiving incoming connections?_

**Mike Schmidt**: "Why is my Bitcoin node not receiving incoming connections?"
another P2P question.  Lightlike points out that a new node on the network can
take some time to have its address widely advertised in the P2P Network.  I
believe he said that was on the order of potentially hours.  And that also,
nodes will not advertise their address on the P2P network until Initial Block
Download (IBD) has completed.  So, if you fire up a node, I guess you have to
wait till IBD is done until your address is socialized on the network, is that
right?  But, Murch, why would we want that, because isn't that the time where I
really, really want a lot of connections?

**Mark Erhardt**: I mean, we only download stuff from outbound peers.  So, I
think either way, most people will not make outbound connections to nodes that
are not at the chain tip, because they want recent data.  So, we're just, at
that point, not very useful to other peers.  So, advertising ourselves would
just not really serve a purpose.  So, our nodes only advertise their services
once they caught up to the chain tip.

_How do I configure my node to filter out transactions larger than 400 bytes?_

**Mike Schmidt**: "How do I configure my node to filter out transactions larger
than 400 bytes?"  And Antoine Poinsot pointed out that there's no configuration
option or command line option in Bitcoin Core to customize the maximum standard
transaction size.  So, obviously you could do that in the code yourself and
build that.  But he did then went on to outline that if you did want to
customize that in the source code, there's potential downsides for both larger
and smaller maximum value settings.

**Mark Erhardt**: I mean, you're just trying to make your node worse, I guess.
I really don't understand why you would want to do this.  And yeah, I guess it
might be interesting to talk more to this person, because I think there's a
misunderstanding about the goal rather than the approach.  So, the main issue
here is, of course, transactions under 400 bytes are probably a small subset of
what we have in our mempool.  And if you have a few inputs, you get easily over
400 bytes.  I think probably two inputs, three inputs can get you there.  And
so, I think they mentioned somewhere that they want to see LN transactions, but
nothing else, and I'm not sure whether LN transactions would always be under 400
bytes.  Commitment transactions are a little more complicated.  There's 2-of-2
multisig going on there, and so forth.  Even though the v-size might be under
400 bytes, with the signatures and the witness stack, you could probably --
yeah, anyway.

There's a reason why this is not a config option.  I don't think it's a good
idea to play around with it unless you've thoroughly studied what you're trying
to achieve.  And if your concern really is that you need to keep your mempool
small, but you're reliant on seeing LN transactions, I think it would be more
useful to just use a slightly more powerful computer.

**Mike Schmidt**: I think I missed the LN focus of that person.  So, that's an
interesting angle.

**Mark Erhardt**: That was in the comments under Antoine's answer.

_What does not publicly routable node in Bitcoin Core P2P mean?_

**Mike Schmidt**: "What does 'not publicly routable' node in Bitcoin P2P mean?"
And this was answered by Pieter Wuille and Vasil, who provided examples of P2P
connections, such as Tor, that cannot be routed on the global internet and that
appear in Bitcoin Core's netinfo output under an 'npr' or 'not publicly
routable' bucket when viewing your connections.

_Why would a node would ever relay a transaction?_

"Why would a node ever relay a transaction?"  So, we're not talking about
relaying transactions of 400 bytes, just why would my node relay any
transactions?  Pieter Wuille answered this one and he listed a few benefits of
relaying transactions for an individual node operator.  One is privacy when
relaying your own transactions from your own node.  So, if you saw a node that
didn't relay any transactions, and then all of a sudden one came out, you could
maybe infer that that was that node's transaction.  So, there's a privacy
implication there.  Faster block propagation, if the user is using that node and
is mining.  And finally, improved network decentralization with minimal
incremental costs beyond those of just relaying blocks.  I think the implication
there is that with compact blocks, you're already collecting all these
transactions.  And if you're just doing blocks-only and not relaying in the
transactions, it's actually a minimal amount of incremental usage, according to
Pieter.  Go ahead.

**Mark Erhardt**: Right.  So, the first is also a problem if you're running in
blocks-only mode.  You're basically identifying if you send a transaction out,
it's the only transaction ever that comes out of your node, and that indicates
clearly probably you're the originator of that one.  And I think the other one
could be sort of a little bit of a tragedy of the comments.  If you're so keen
on saving a few bytes of bandwidth that you're not forwarding transactions, you
might be able to get away with that.  If everyone does it, we just won't have
transactions propagate through the network anymore.  Then, miners don't get
transactions, then it doesn't work for anyone.  And so, yeah, I guess you don't
get paid for it, but it's understood to be part of what you're trying to do, is
get the best transactions to the miners in order to make sure that the network
works when you want to use it.

_Is selfish mining still an option with compact blocks and FIBRE?_

**Mike Schmidt**: Last question from the Stack Exchange is actually a 2016
question, which is, "Is selfish mining still an option with compact blocks and
FIBRE?"  And Antoine Poinsot followed up to that old question and he noted, and
I'll quote him, "Yes, selfish mining is still a possible optimisation, even with
improved block propagation.  It's not correct to conclude that selfish mining is
now only a theoretical attack".  And I think there's some interesting
information in that quote, but he also pointed to a mining simulation that he
created that can articulate some of this.  I thought that that was worth
mentioning.

**Mark Erhardt**: Yeah, I think the interesting point is, if there are ever two
competing chain tips on the network, of course most miners will build on the one
that they saw first, or, well their own usually.  If they found one they try to
build on their own mining pool's reward in order to make sure that it makes its
way into the longest chain.  But the funny thing about this is if you have, I
think it was 33% of the hashrate, even if you always lose races, so when there's
two chain tips, you always lose, I think at 33%, just building on your own
blocks always generates more revenue than not doing so.  So, yeah, any mining
pool over 33% or any mining pool conglomerate that works on the same block
templates over 33% should be eyed with suspicion.

**Mike Schmidt**: Yeah, I think that's referencing the 2013 paper that was
linked to in Antoine's answer.  So, if you're curious more about what Murch was
talking about there, refer back to that.

**Mark Erhardt**: There's also been a few papers that follow up on this and that
look more at how the exact border shifts, if you assume that they win some of
the races or have other advantages and it's even slightly lower than 33%, I
think.

_Core Lightning 25.05rc1_

**Mike Schmidt**: Releases and release candidates.  Core Lightning 25.05rc1.
This is a CLN release candidate that Dave Harding covered last week in Podcast
#355 with Alex Myers, who's actually a CLN engineer, and they also went through
several of the CLN PRs that went into the release of this release in the Notable
code segment last week.  So, lots of CLN stuff.  Refer back to last week's
podcast I think, unless, Murch, you had anything to add.

_LDK 0.1.3 and 0.1.4_

LDK 0.1.3 and LDK 0.1.4, we mentioned something in the newsletter about this,
but it appears that the timing of the tagging was off here.  So, I guess we're
covering both of these releases today.  0.1.3 included a couple of bug fixes and
a security item.  One bug fix was around BOLT12, where multiple InvoicesReceived
messages were being generated when a sender sends redundant messages to improve
success rates.  But now, only one is generated for each matching a pending
outbound payment.  The second bug was a bug fixed around LDK's router that fixed
some spurious multipath payment failures.  And then, the security item for 0.1.3
was that it fixed a DoS vulnerability, which caused potential crashing of an LDK
node if an attacker had access to a valid BOLT12offer.  So, those are all
security or bug fixes as far as I'm concerned, but they've sort of bucketed them
into two bug fixes and one security item.

Similarly, for the 0.1.4 release for LDK, there were two fixes around LDK's
synchronous persistence feature.  The first fix was a fix for a deserialization
issue.  You're welcome to look into the release notes for the details of that,
but it seemed quite complicated.  I thought I would just leave it at that.  And
then, the second one was a fix also around synchronous persistence, and it was
resulting in channels potentially hanging in some situations when receiving
multipart payments.  And then, the security item related to 0.1.4 was a fix for
a potential, but far-fetched case of fund theft vulnerability.  And I'll read
from the release notes here, " If an LDK-based node funds an anchor channel to a
malicious peer, and that peer sets the channel reserve on the LDK-based node to
zero, the LDK node could overdraw its total balance upon increasing the feerate
of the commitment transaction.  If the malicious peer forwards HTLCs through the
LDK node, this could leave the LDK node with no valid commitment transaction to
broadcast to claim its part of the forwarded HTLC".

So, a lot of bug fixes in LDK over these two versions.  Anything to add, Murch?

_Bitcoin Core #31622_

Notable code and documentation changes.  Bitcoin Core #31622 is a change to
Bitcoin Core's handling of PSBTs.  Previous to this PR, Bitcoin Core wouldn't
add in the sighash (signature hash) field to PSBTs at all.  After this PR,
Bitcoin Core will now add the sighash field to a PSBT when signing with any
sighash, other than SIGHASH_DEFAULT or SIGHASH_ALL.  That's actually required
for folks using MuSig2, because all the signers need to sign using the same
sighash type.  And in addition to that change, there's also a change in this PR
to make sure that the same sighash type is used for signing as was in the PSBT,
a check that was done in some places in the code previously, but not in all
situations.  And what was called out here was descriptorprocesspsbt RPC not
previously doing that check.

Murch, I have a question for you on the BIP side of things.  This is maybe a
little bit in the weeds, but PSBTv2 has a PSBT_GLOBAL_TX_MODIFIABLE, which is a
bit field.  Is that what the sighash is in PSBT, or is there a separate field
for it?

**Mark Erhardt**: No, so the sighash is basically the transaction commitment as
a derivative of all the inputs and outputs and amounts, and so forth, that
compose the transaction.  It is de facto the message that you're signing in the
cryptographic signature triple, which is message, signature, and public key.
So, what we call here the sighash is declaring how you compose the message that
you're signing, which parts of the transaction you used to compose it.  And
yeah, so whether the transaction is still modifiable is a previous step.  As
soon as people start signing it, it's usually not modifiable anymore, or at
least everybody has to sign again.

_Eclair #3065_

**Mike Schmidt**: Thanks, Murch.  The Eclair PR we had discussed earlier in the
newsletter, so refer back to that if you're listening here looking for an Eclair
PR, but that they added attributable failures as specified in BOLTs #1044.

_LDK #3796_

LDK 3796, titled very descriptively, "Do not dip into the funder's reserve to
cover the two anchors".  So, that pretty much sums it up.  But before this PR,
LDK would allow the funder to dip into its channel reserve to pay for the two
330-satoshi anchors.  But now LDK reserves at least 1000 satoshis so that the
two 330 anchors won't overdraw on that reserve.

_BIPs #1760_

We have three BIPs PRs to round off the newsletter.  BIP #1760 which merges
BIP53.  Murch, what is BIP53.  Murch, what is BIP53?

**Mark Erhardt**: So, BIP53 proposes to disallow 64-byte transactions, and
people that have been following along the consensus cleanup discussion will
notice that this is also an item that's in the consensus cleanup BIP.  This BIP
was proposed before the consensus cleanup BIP and got also finished to a
sufficient degree and is now merged.  I think that they have some overlap, and
it's not entirely clear to me which one of the two, or if both of them would
activate, or whether they're 100% compatible.  But this is basically taking a
slice out of the consensus cleanup and proposing, in another way, to disallow
the 64-byte transactions, which of course are related to the merkle tree, well,
under-defined-ness, the vulnerability of merkle trees to fake transactions.

**Mike Schmidt**: It would seem to me if there's a few different changes in a
soft fork, that if maybe one or more were highly controversial, that that would
be a good reason to maybe split off other pieces of that soft fork into smaller
pieces to get activated.  But it doesn't seem to me in this case that the
consensus cleanup, any of the components of that are controversial to that
degree.  Would you agree with that?

**Mark Erhardt**: Yeah, I think there was a little bit of duplicated work here,
and it may have come out of some miscommunication, where someone wanted to help
and was told by third parties that they could do something to help, and then
that actually duplicated other work that was being done.  It may have also
helped get the consensus cleanup BIP out a little quicker.  So, definitely more
people talked about it.  I don't think it's a total loss, but at this point it's
a little unclear to me what's going to happen here next.  But presumably they'll
be wrapped into one and deployed eventually, if we ever manage to deploy the
consensus cleanup stuff.

_BIPs #1850_

**Mike Schmidt**: BIPs #1850 reverts an earlier update to BIP48, which reserved
the script type value 3 for taproot, which I believe it's been just a couple
weeks ago, in Newsletter #353, where we discussed that.  What went wrong here,
Murch, or did something go wrong?

**Mark Erhardt**: So, BIP48 describes a way of constructing multisig outputs,
and it was defined for P2SH and P2WSH, I think, and it uses OP_CHECKMULTISIG
construction.  And what I learned later was that it was more descriptive than
prescriptive.  It was something that was already widely used that finally
someone took and wrote up into a BIP in order to document it.  And so, a couple
of weeks ago, someone said, "Let's also add P2TR to BIP48", which had a passage
that said, "Hey, if you want to add more output types, just amend this BIP and
add them", and that got reviewed and merged.  But then I also reviewed it again
a little later and realized that, well, that doesn't work because tapscript does
not have OP_CHECKMULTISIG.  OP_CHECKMULTISIG would not be stable for the batched
signature validation, and therefore it uses OP_CHECKSIGADD instead.

So, I found that for P2TR, BIP48-style outputs didn't make sense and were
underspecified.  So, I suggested that we actually roll back the addition of P2TR
and move BIP48 to final, because presumably there's not going to be another
output type that would be compatible with BIP48.  And given that it was already
just describing a widely deployed industry, well, standard, I guess, adding to
it later now would make all these implementers of BIP48 incompatible with the
existing standard.  So, really, I think it's at a point where if we added
another one, we should write a new BIP for it.  So, when people declare they're
compatible with BIP48, it's clear and it's not another new question to the old
one, or the new and amended one.  So, anyway, we cleaned that up and returned it
to the prior version and moved the BIP to final.

_BIPs #1793_

**Mike Schmidt**: Last PR this week, BIPs #1793, which merges BIP443, which
specifies OP_CHECKCONTRACTVERIFY (OP_CCV).

**Mark Erhardt**: Yeah, I mean we've had Salvatore on quite a few times here to
talk about OP_CCV.  The BIP has made so much progress that we felt that we
should merge it in draft status.  There's still a couple of open to-dos about
what exactly the sigop costs would be of the CCV opcode, and some other minor
details, minor in the sense that the work is in the research and deciding, and
the writing of it is probably pretty small.  Anyway, I would encourage people
that are interested in covenants and/or vaults that they take a good look at
this and provide feedback so that Salvatore can keep moving forward this BIP if
they're interested in that happening.

**Mike Schmidt**: We have talked with Salvatore a few times, even early on in
MATT, when this was sort of in its MATT phases, now CCV.  I think the most
comprehensive to-date version of the discussion would be in Newsletter, mostly
Podcast #348, where we had Salvatore on, and that was for the Changing consensus
segment.  So, we had a bunch of consensus script people on, going back and forth
about a variety of topics, including one on CCV.  So, check back to that if you
want to learn more about what Salvatore is up to.  Seems like a lot of folks
that I've spoken with are excited about this proposal, even if it's more
immature than some of the other covenants-related software proposals.  So, if
you're curious, check back to that episode and check out the BIP as well.

**Mark Erhardt**: I might say that I think it's one of the covenant proposals
that's worked out pretty far actually.  And it's also one that has been worked
on for years and developed further and further.  So, well, there's a lot of
covenant proposals floating around and some of them may be less mature, but I
think I would categorize this one as actually closer to deployable than some
other ones.

**Mike Schmidt**: I think that's fair.  Thanks for chiming in on that.  Well, we
want to thank our special guests Elias, Joost and Carla for joining us this week
to talk about LN stuff, that was great.  And thank you, Murch, for co-hosting
and everyone else for listening.  Cheers.

**Mark Erhardt**: Thanks for your time.

{% include references.md %}
