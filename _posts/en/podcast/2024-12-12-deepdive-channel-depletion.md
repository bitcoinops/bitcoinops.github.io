---
title: 'Channel Depletion Research Deep Dive Podcast'
permalink: /en/podcast/2024/12/12/
name: 2024-12-12-deepdive-channel-depletion
slug: 2024-12-12-deepdive-channel-depletion
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by René Pickhardt and Christian Decker
to discuss Pickhardt's [Lightning Network channel depletion research][channel depletion delving].

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-11-12/391433590-44100-2-59eab6a20b947.m4a" %}

<br />
<ul>
    {% include functions/podcast-bullet.md timestamp="1:01" slug="#summary" podcast_slug="#summary" title="Summary of Pickhardt's research" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="5:45" slug="#distributions" podcast_slug="#distributions" title="Why look at wealth distributions?" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="11:38" slug="#depletion" podcast_slug="#depletion" title="What can be learned from depletion?" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="13:33" slug="#rebalancing" podcast_slug="#rebalancing" title="Circular rebalancing" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="15:28" slug="#spanningtree" podcast_slug="#spanningtree" title="What determines where the spanning tree is?" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="20:14" slug="#options" podcast_slug="#options" title="Mitigating depletion" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="26:39" slug="#adjacent" podcast_slug="#adjacent" title="Adjacent channels and their impact" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="29:52" slug="#multiparty" podcast_slug="#multiparty" title="Multiparty channels, channel factories, and Ark" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="41:06" slug="#hubandspoke" podcast_slug="#hubandspoke" title="Hub-and-spoke topology discussion" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="54:54" slug="#data" podcast_slug="#data" title="What real world data would inform the theoretical?" has_transcript_section=true %}
</ul>

## Transcription

**Mike Schmidt**: Welcome everyone to our Optech deep dive on channel depletion
research.  Today, we have René Pickhardt and Christian Decker joining myself and
Dave Harding to dig in on René's recent Delving Bitcoin post.  René, you posted
to Delving a post titled, "Channel depletion, LN Topology, Cycles, and rational
behavior of nodes".  In it, you present evidence to explain the high rates of
channel depletion that we see on the LN.  We had you on in Podcast #309 and you
mentioned you were writing a paper titled, "A mathematical theory of payment
channel networks", and it looks like since then you've published that paper, or
a version of that paper at least.  And in this Delving post, you reference that
paper along with two Python notebooks that support your research.  I know this
is a deep dive and Christian and Dave will have some deeper astute questions,
but maybe summarize briefly for the audience your recent work to give the
audience a bit of context.

{:#summary-transcript}
_Summary of Pickhardt's research_

**René Pickhardt**: Yeah, sure.  Thanks for the invitation.  So, what I have
been doing is, I was trying to understand why payments on the LN occasionally
fail, even though nodes doing really good and smart work to try making attempts
of payments over and over.  And I was trying to understand the mathematics of
the LN topology.  And one new angle to look at this is to study wealth
distributions.  So, every node and every participant in the LN has a certain
amount of bitcoins that they bring to the LN, and they allocate this to payment
channels.  And then, within the payment channels, the money can be split among
participants and it can be routed through the network.  But the bottom line is
whenever a payment has been conducted successfully, the wealth distribution in
the entire network has changed.  And it turns out that studying just the set of
feasible wealth distributions is a much more natural way to looking at this, to
express things mathematically, and from that, we can derive certain things.  And
yes, one thing that turned out that was possible for us to study is why channels
actually deplete on the network.  And I think that's what I posted on Delving
Bitcoin and why we're doing the deep dive today.

**Dave Harding**: Yeah.  So, it seems like the real headline of this post is you
found a very interesting correlation that you didn't expect, a very strong
correlation.  Can you tell us a little bit about that?

**René Pickhardt**: Yes.  So, a couple of years ago there was a paper dropped on
the Lightning-Dev mailing list that already said, if the network has a somewhat
stable state and they derived a Markov model, there should be a spanning tree of
channels that have a uniform distribution of liquidity and the rest of the
channels should be depleted.  And when I did my research from a very different
perspective, from this geometric perspective, I basically reproduced the same
finding at the same result.  And that I found very, very interesting because at
that time, the Markov-model-based paper, I found interesting, but I thought the
assumptions in there were not perfectly fitting what is happening in the
dynamics of the network.  But now we have a situation where we can see this.
And again, it starts with studying the wealth distributions.

If you have the smallest possible LN that you could have, which is just one
payment channel, and you assume every wealth distribution is equally likely,
well then every state in the payment channel is equally likely, because every
state corresponds exactly one wealth distribution.  And the same holds true if
you don't do one payment channel but a tree of payment channels, because the
argument basically follows true.  But as soon as I include a circle into the
network, what happens is that I can do a circular rebalancing, so I have several
states that now belong to the same wealth distribution.  So, what this shows us
already is that the existence of circles allow us to have more network states
than we have wealth distributions.  And then the question is, "What is the
liquidity state that is most likely to occur given a certain wealth
distribution?" because payments are, as said before, always a change in wealth
distribution.

One part that is in the paper that is very fundamental was the observation that,
when I present the topology of the LN, just what you see from gossip, and a
given wealth distribution, you can solve an integer linear program that gives
you the liquidity state.  But it just, at that time, gave me one particular
liquidity state, and that was proof enough to say this wealth distribution is
feasible.  But when you then say you want the liquidity state that optimizes the
fee potential of the network, which I showed in the blogpost is a reasonable
assumption, well then it encodes the dynamics that goes on when people make
payments.  So, for example, people who want to send a payment, they try to find
a cheap payment route, and what happens is that money in the network starts to
circulate around.  So, for example, Dave, if I want to send money to you, it
could very well happen that my node decides to find a path routing through
Christian.  But when Christian wants to send me back the same sats, if we have
circles, Christian might find a route that goes over Mike to you.  So, in that
sense, we four people interacting with each other, we might all go in a circular
direction, and then all the channels deplete.  Whereas, again, if we had a
spanning tree, well, Christian would be forced to use the same path back to me
or to you.

So, the existence of circles and the fact that the fees are asymmetric on
channels, they said money circulates around the network and the circulations
produce the depletion.

{:#distributions-transcript}
_Why look at wealth distributions?_

**Christian Decker**: So, I guess we're already pretty much into the results
themselves.  For my own understanding, I had to chew on this quite a few times.
So, my question was mostly to maybe take a step back and argue, why are we
looking at wealth distributions in the first place?  What are these wealth
distributions?  Are they constant?  Are we moving between these?  And what
characteristics are they showing of the underlying graph, is maybe something
that we should address first before extrapolating stuff from it.

**René Pickhardt**: I'm not entirely sure if I understand everything about your
question, but maybe I start and then you could ask me back!  The wealth
distribution is basically the amount of satoshis every user on the LN owns.

**Christian Decker**: So, it's an equivalence class of different states, where
every person has a fixed number of satoshis.  But it's an equivalence class
because we don't really care about, it's on channel A or channel B.  All we
actually care about is the total sum, I guess, right?

**René Pickhardt**: Yes, so it's the total sum of outbound liquidity that a node
has and this is computed for every node.  And again, if you do a circular
rebalancing, that's exactly the equivalence class that you mentioned, that I
also described in the paper that I used in the proof of saying something is
going on there.  Yes.

**Christian Decker**: So, why are we looking at them?  Are we staying in the
same wealth distributions, or are we looking how we move from one wealth
distribution to another?

**René Pickhardt**: So, the observation is, whenever you want to make a payment,
it's a change in wealth distribution.  So, I have a certain wealth and if I want
to pay you, that means my wealth decreases by the payment amount and your wealth
increases by the payment amount.  And for this calculation, I ignore the routing
fees, because they are neglectable in comparison to the payment amounts usually.
And what this also means is that the wealth of the routing nodes stays the same,
because some satoshis flow in on one channel and they are flowing out on another
channel.  So, the observation is, every payment that is being conducted is a
change in wealth distribution.  And then the question to decide whether a
payment is feasible or not can be decided by understanding, is a wealth
distribution feasible given the topology of the network, which puts constraints
on how wealth can actually be distributed on the network?

I think the example that I brought last time in the podcast is where I
mentioned, Christian, if you and I have a channel, yes, I can forward some
satoshis to you by transferring some of my wealth to your channel and you can
conserve your wealth by forwarding the satoshis on another channel.  But the
satoshis in our channel always stay between you and me, unless we do an onchain
transaction.  Whereas, if you do onchain transactions, well, then I can send my
satoshis to anybody.

**Christian Decker**: Yeah, exactly.  So, essentially, what we are doing is we
are in a certain wealth distribution, then some payments are performed, changing
the wealth distribution in which we are.  And your research is all around
looking at what is feasible inside of these graphs, what the extreme limits are
and what the stables of the situations are.  Circles, for example, are one such
stable situation where if we all send around the same circle, then we stay in
the same wealth distribution.

**René Pickhardt**: Yes.

**Christian Decker**: Some wealth distributions, I expect, are impossible to
achieve.  Why would that, for example, be?

**René Pickhardt**: Well, if you and I maintain a payment channel, the wealth
distribution in which David gets all the bitcoins in the world is impossible,
because the satoshis in our channel can't move to David.

**Christian Decker**: Exactly.

**René Pickhardt**: In the offchain payment channel network, of course, right?
If you do onchain transactions, it's different.  But onchain, technically,
everybody could just send their bitcoins to David.

**Christian Decker**: Exactly.  Onchain, we don't have these limitations, but
offchain, with this tool of wealth distributions, we can actually find what the
limits of the network are, and that's very much what you're looking at.  And the
whole depletion and cycles and spanning trees, those are essentially networks
thought forward for hundreds of years or hundreds of operations, until they
reach a certain stable situation, right?

**René Pickhardt**: And maybe to just make the last example not so extreme is,
Christian, if you and I have a channel, it's impossible that we both sent away
all our money.  Because if I want to send away all my money, then you have to
have some.  And if you also want to send away all your money, well then I have
to have some.  And I mean it's very reasonable that two users, just at least for
a moment, want to send away all their money, but that's impossible if they
maintain a channel.  And yes, then the question is, what kind of phenomena
emerge across these channels?  And can we make use of the fact that these
phenomena emerge?  So, for example, the entire point about depletion is that a
lot of people assume that it exists because money flows from source nodes to
sink nodes through the network.

But what I showed in the Delving Bitcoin post is that if you have a network
where you assume that every node receives and sends the same amount of bitcoins
over time, so a perfect circular economy, then in this particular graph that I
showed, all channels will deplete.  It's still possible that everybody can pay
each other, because everybody still has some satoshis, right?  The wealth
distribution allows that money can flow from one person to another, but all the
channels and network are, depleted because the regular channels that people will
try first are the cheap ones.  Well, you won't find a payment route on this
channel, then you have to basically go the other way around.  You un-deplete the
channel a little bit, but the next payment that's being made will just deplete
the channel again, right?  So, channels will just stagger again.

{:#depletion-transcript}
_What can be learned from depletion?_

**Christian Decker**: Yeah.  So, depletion sounds relatively negative, right?
But is it a signal for us that we need to change some things as node operators?
Do we need to add more funds, because evidently funds were being sent one
direction rather than the other?  Or is it a sign of inefficient allocation of
funds and we should close those channels?  Or what can we read into depletion
itself?

**René Pickhardt**: So, I mean, of course there could be various reasons for
depletion to occur.  I'm talking about a very fundamental reason which is given
through cycles that exist, right?  So, I mean, two very obvious solutions to the
problem are, we could create a LN that is just a spanning tree.  There are
plenty of reasons why we do not want that, because if one channel breaks, well
then the tree departs and a lot of people couldn't pay each other.  Another
thing that would certainly help is if we would change the protocol in a way that
the fees are symmetrical.  So, that means that forwarding costs the same in both
directions, which incentivizes money to basically flow back and forth if we make
a payment between two users, but there's also reasons why that is not
necessarily desirable.  And then you come to the point where you say, well
actually, depletion is something that has to occur.  Now I can be smarter about
this.  I could, for example, say, well people route and make payments by
optimizing their fees.  I can predict where the depletion is, and I can just be
really, really smart and change my cost objective in routing and route against
that direction.  But the problem is, as soon as everybody changes their cost
function in routing, well then other channels will deplete.  So, I do have a
formal proof where I can just show that as soon as a cost function exists along
those circles, depletion will be there, unless a very rare, very unlikely
condition occurs, which is basically probability zero.  So, what this shows is
that it's a very natural phenomenon that channels will deplete.

{:#rebalancing-transcript}
_Circular rebalancing_

So then the question is, can we do something else about this?  And you,
Christian, actually reminded me of one of my early researches, where an early
idea was, why don't we do circular rebalancing?  And at that time, I proposed an
optimization goal to do this, and a lot of people rejected this idea and said,
"Well, we actually earn money with routing and we wait for somebody else to undo
this".  But let's imagine we can find a circle in the network where money always
flows in the same direction on the circle.  Well then, those node operators do
have an incentive to just cost-free un-deplete this channel, make the circular
payment in the other direction, because statistically given, the money will flow
in this direction again and they can earn the money, and yes, just be happy node
operators, provide good reliability.  So, yeah, that is one consequence of this,
because even though with depletion payments are possible, usually if channels
are depleted, we find longer to find the liquidity.

One of the things that my research also indicates is channels deplete, yes, but
the side on which the channel depletes depends on the overall state and wealth
distribution in the network.  So, it's not obvious that just because the fees
are high on one end of the channel and low on the other side of the channel,
that the money flows to the expensive side of the channel.  I provided an
example where I showed, look, in this particular graph, we expect that the money
actually is on the cheap end of the channel.  And when you run more simulations,
what you see is that a channel could, for example, have 75% of the time the
liquidity on one end, and 20% of the time the liquidity on the other end, and
then there's 5% of the times where it's actually in the spanning tree that
survives.  So, neither the location of the spanning tree is stable, so this is
also an argument against just making a spanning tree, nor the site on which the
channel depletes is stable.  And that is interesting to observe.

{:#spanningtree-transcript}
_What determines where the spanning tree is?_

**Christian Decker**: So, that sort of brings up a very natural question, right?
What determines where that spanning tree is?  And if I'm a node operator, how do
I get on it?  Because obviously, there's lots of fees to be made there.

**René Pickhardt**: Yeah, so again, what I showed is that the location of the
spanning tree is not stable.  It would seem that if you have, like, a really
large channel, there's a higher chance that your channel just never depletes,
because there's something left over.  So, I saw in my experiments, if I allow
larger channels, then maybe that the channel has just, like, some liquidity
over, while all the other channels deplete.  But yeah, it's not quite clear,
because as I just said, if you have an un-depletion protocol, then other node
operators still can earn a lot of money because there's a lot of demand on their
channels.  And as I said before, the demand could even be on the expensive side
of the channel.

**Christian Decker**: So, the large channel in this case is pretty much a budget
that allows you to have an imbalance for prolonged periods in one direction
rather than the other, right?  But does that still have an effect if you
continue running it for longer, or is size really an indicator for routing
quality, so to speak?

**René Pickhardt**: No, not necessarily.  So, it really depends on the… so one
of the consequences of this research is when I, in 2021, published my initial
results about uncertainty of liquidity, a lot of people criticized that work and
said, "You assume that the probability distributions of liquidity in each
channel are independent of each other".  So, by studying the wealth
distribution, you actually break this assumption and now everything connects to
each other.  So, the question whether a certain channel has a lot of demand
really depends on the global topology, the global fees on the network.  Your
particular channel size doesn't have that much of an impact.  And as I said
before, the natural phenomenon that occurs is, there is a circle where the
liquidity flows around, so it hits the end of the channel.  Well, sometimes
maybe, a payment flows in the other direction, because all the channels are
depleted and the sending node has to then find another route.  But then, the
next time the liquidity is available again, it hits the end.  This is an
argument to have small channels.

Your question about, everybody wants to be on the spanning tree, well, the
spanning tree could actually be the residual, because everything else is already
depleted.  Like, everywhere else is where the demand was.  So, it doesn't even
say that the spanning tree, just because the liquidity is uniformly distributed
there, has really drained in both directions.  That is exactly one of the things
that I was unhappy about in the other paper, where it says, "People will learn
where demand is and the demand will become uniform and those channels will be
back and forth".  I would say the spanning tree is a little bit like a leftover,
because everything else was already used.  So, it's not even clear, just because
your channels are un-depleted, that they are economically perfect.  I mean, in
these ideal scientific scenarios, of course.

**Christian Decker**: So, there is very little you can actually read out of just
looking at your own channels, can you?  You can't really read whether you're on
a cycle, whether it's a temporary shift in spanning tree and I happen to be in
it for a couple of minutes.  You're working with global data, aren't you?

**René Pickhardt**: Yes.

**Christian Decker**: You're simulating the entire network and as an individual,
there's as much information that you can extract, I guess.

**René Pickhardt**: So, generally, I'm looking at the global graph and I'm
solving this integer linear program that gives me an expected value of how my
view locally looks like.  And then, of course, I could compare my local data and
knowledge and create the conditional probability and learn something about the
network.  I think that's computationally very heavy.  So, I'm not too sure how
sustainable that route would be.  But I mean, obviously, there's an opportunity
or a chance.  But yeah, that's currently something I can only speculate on.

**Christian Decker**: Yeah, no, I'm just wondering about whether me as a node
operator can make any inference from the data that I have available locally.
And from what I hear you say, is that we might be able to simulate all of the
different situations.  That's computationally expensive.  And then, even trying
to find the probability of one of these situations to be truthful, and combining
them all, doesn't really give you a clear picture, because all of these wealth
distributions will essentially mix together and not give you a clear signal,
right?

{:#options-transcript}
_Mitigating depletion_

**René Pickhardt**: That's at least my current understanding of the situation.
So, maybe we can look at the various options that we have when we look at
depletion.  So, when you look at a network like this in the field of logistics,
there is basically three different ways of mitigate the depletion.  The first
would be dynamic pricing, the second would be load balancing, and the third
would be reverse logistics.  And I think a lot of people on the LN have been
thinking about dynamic pricing, which is basically the idea of saying, "I can
adopt my routing fees and I can make my channel more attractive, or less
attractive.  Or if it's already attractive, I can try to earn more on this".
This is also where ideas like feerate cards or negative fees or inbound fees do
something, because it changes also the price on the other side.  My intuition
and my feeling always is that since it's a global problem, if you change your
prices, it affects everyone else and it becomes like a very, very dynamic
problem, and it's not really clear where the equilibrium is and if there's ever
an equilibrium to be found.

The other option was load balancing.  This is already what sending nodes do,
because they try to make a payment and if it fails, they have to exclude those
channels and they have to try another route and another route and another route.
So, this basically is already some form of load balancing.  You could do a much
better load balancing if you had a central coordinator, right, where you say,
"Yes, I really uniformly use payment paths and I distribute the traffic across
all of them".  And then reverse logistics basically means, yeah, push some of
the satoshis back.  This is basically the circular rebalancing thing that you
brought up again that might work.  And I think those are the three known methods
that we can use.  And my feeling is, have the prices to become stable and use
reverse logistics in order to provide the liquidity and have a system that has a
somewhat stable state, seems more preferable to me.  I'm not sure if the market
and all the users will do this, I mean that's not clear.  But the load balancing
in particular is difficult because it forces people to use more expensive
routes, and why would they do that?

**Dave Harding**: I think in the Delving thread, AJ linked to a previous mailing
list post you had made about htlc_maximum_msat, which I believe, I didn't have a
chance to look that up, but I believe that is the maximum number of pending
payments.  No, it's not.

**René Pickhardt**: No.

**Dave Harding**: Go ahead.

**René Pickhardt**: It's the maximum amount that an HTLC (Hash Time Locked
Contract) is allowed to have.  So, the idea is you use this as a control valve
for load balancing, right?  So, this goes in the load balancing direction.  When
you make a payment, your node would usually decide how much of the payment
amount they allocate either to a certain path, or in a payment flow across
several paths.  But what nodes can do is they can say, "I have a 1-bitcoin
channel, but I don't accept payments larger than, let's say, 100,000 satoshis".
So, even though I would really want to use that channel, I could only lock in 1
HTLC of 100,000 satoshis.  This is, of course, gameable because I could just
directly afterwards lock in a second HTLC of 100,000 satoshis.  I have to pay
the base fee twice then, of course, but I was already willing to pay the base
fee and it's an economical thing, right?  So, it's kind of like hard to really
use this as load balancing.  This is one of the criticisms that was presented to
me before when I proposed the idea.

But yeah, I mean it goes in the direction of flow control and load balancing.
Yeah.  But still, I mean what would happen is you use the most preferable route,
then the second most preferable route, the third most preferable route.  The
un-depletion works when you use one of the really bad ends.  So, my current
intuition is it would just not deplete the first circle quickly and then the
second circle, but all the circles would simultaneously deplete once the
liquidity is there.  So, yeah, even though it's my own idea, I'm not that sure
if it's really, really helping, given the newer insights that we have.

**Dave Harding**: So, to come back at this from a bit of a higher level, what I
understood, which could be wrong, is we have a graph of connected channels, of
nodes connected by channels.  And in many cases, there's circuits.  There's
multiple ways to get between the same thing.  You can go from A to B to C back
to A.  And basically, the network, just through normal operation, prunes these
circuits by depleting them, depleting at least one of the channels in that
circuit, until we have a spanning tree.  We have a single set of connections
between some of the nodes in this graph and their channels.  Is that basically
what happens?  Is it just, like, just through rational behavior, it's pruning
out these circuits?

**René Pickhardt**: Yeah.

**Dave Harding**: Okay.

**René Pickhardt**: And it prunes out the smallest channel, right?  This is the
question again from before, whether capacity makes a difference or not.  But
it's the smallest channel that depletes and then the circle cannot operate in
the direction of the circle anymore.

**Dave Harding**: It's the smallest channel?  Or does it have anything to do
with fees?  Because you talk a lot here about, you know, trying to maximize
fees.  So, even if it's a small channel with high fees, does it necessarily get
depleted faster than a large channel with a low PPM feerate?

**René Pickhardt**: So, as soon as a circle exists, there is a direction in
which payments usually flow across this circle.  Of course, the fees make a
difference, but if the fees are too high, then maybe on this circle, the money
flows in the other direction, and then it just depletes on the other way.  I
mean, one thing that people always thought and where people, when they try to do
machine learning of predicting liquidity, is they always had this intuition that
the liquidity should be on the higher fee end of the channel.  While this is
somewhat working, the correlation was never perfect, like, it was never really a
perfectly good working predictive model.  I mean, there's plenty of research
papers out where people have tried this and, yeah, you get some result with it,
but you never get like a perfect result.  My research explains why the liquidity
could be on the other end, because it's really the difference of fees on every
edge on the circle and the sum of those that decide in which direction the
circle circulates.  So, what really could happen is somewhere else in the
network changes their fees and it changes how, in your circle, the money starts
to flow.

{:#adjacent-transcript}
_Adjacent channels and their impact_

**Christian Decker**: It's very similar to this idea that I'm in charge of my
local street, right?  I sweep it every day, I keep it well maintained.  But I
won't get more visitors if the adjacent streets are filthy and drug-riddled, and
whatever; my street won't get touched, right?  The adjacent streets are as
important, the adjacent channels, the channels that bring payments to me and
through me, those are as impactful as my own fee policy and therefore, when
adjusting my local fee policy for a certain goal, I will always need to take a
look around and look at my vicinity and take that into consideration. Otherwise,
my adjustment might not be effective, or not as effective as it could be and
what I wanted it to be.

**René Pickhardt**: And just to double down, it's not only the adjacent streets
and adjacent channels, but also the next adjacent channels.  And the LN is very
densely connected in comparison to a road network.  So, I mean with five hops
you are everywhere and five hops is not really far away to build a circle.

**Christian Decker**: Yeah, effectively you're transitively dependent on the
entirety of the network and, yeah, the computations get accordingly more
difficult, and harder to even grok for operators to make such an informed
decision and make such a targeted decision towards a certain goal.

**René Pickhardt**: And of course, if you dissect the network into circles, but
maybe that's a little bit too detailed now, one circle could move, let's say,
clockwise, and our channel could be part of a different circle that moves
counterclockwise, right?  So, it could cancel each other out a little bit.  But
by the end of the day, I'm part of, let's say, 100 circles or even more, and
there's a certain majority direction into which the liquidity on my channel will
move.  And yes, that depends on the fees that you and I charge, but again, it
depends on all these other circles.  So, yeah, but this gives also an indication
of is it really the smallest channel across one circle that depletes first?  It
could be another one, because another one could be on many other circles that
all have the same direction.

But I think the important bottom line here is that even in a circular economy,
where all nodes receive and send over time the same amount of bitcoins, channels
will deplete and there's hardly anything we can do about it.  Because I think
currently, just to be very clear, a lot of people operate under the assumption
we're just not smart enough with liquidity management and dynamic pricing and
fees.  And if we become smarter, then we finally get rid of depletion.  And I'm
very confident to say that this won't happen.

**Christian Decker**: So, what other directions, if not the control of our local
policies; what other directions could help us improve the sort of expressivity,
the states that we can represent inside of the LN?  Do we have other knobs that
we can tweak for that kind of stuff, or are we doomed never to exceed those
limits that you came up with for the LN of today?

{:#multiparty-transcript}
_Multiparty channels, channel factories, and Ark_

**René Pickhardt**: So, one knob that interestingly we can switch around with is
a proposal that also came from you, which is channel factories.  And the
interesting observation from my research here is, it's my understanding,
Christian, when you presented channel factories, you used them as an onboarding
mechanism to save onchain footprint and to basically say, "With one UTXO, create
this multiparty channel construct and then provide more smaller channels".  And
it's good for scaling.  I think that was your main question and concern.

**Christian Decker**: I think that's correct.  But in a certain sense, there is
a bit of overlap with your work, actually, right?

**René Pickhardt**: Exactly.

**Christian Decker**: Because I was speaking about expressivity of these
constructions when it comes to who can get how much, something that I much later
learned that is essentially your wealth distributions.  If the two of us open a
channel and we put 1 bitcoin in it, Dave can't own it, right?  But if we have a
system where, without touching the chain, we can have Dave also in the group,
and then without touching the chain, move funds between them, all of a sudden
the expressivity becomes much better.

**René Pickhardt**: I mean, that's always my example.  When you have three
channels between three people and each channel has a capacity of two, so let's
say David and I have a channel, Dave and Christian you have a channel, and
Christian and I have a channel, well, I can at most have 4 bitcoins, because I
can have all the bitcoins between Christian and me, and I can have all the
bitcoins between Dave and me.  But if we put all of these bitcoins in a channel
factory or in a 3-of-3 channel, a multiparty channel, then I could technically
have 6 bitcoins, and the same holds true for you, Christian, and the same holds
true for Dave.  So, a multiparty channel gives us way more wealth distributions
that we can achieve, and this increases the reliability.  So, I think when you
look at the paper, a mathematical theory of payment channel networks, I think
it's section 4.4 or 4.3, I'm not entirely sure, but it's formula 12 at this
point in time.  It estimates the bandwidth of payments per second that we can
achieve on the LN.

What I'm basically saying is, look, we have a bandwidth of transactions that we
can do onchain, and then we have an expected rate of infeasible payments.  And
whenever a payment on the LN is infeasible, the only thing that we can currently
do, because the circular rebalancing doesn't change the fact that the liquidity
cannot move between Christian and me, for example.  The only thing we can do and
must do is an onchain transaction somehow.  So, every time we need this onchain
transaction, well, we use some of the onchain bandwidth up.  So, the offchain
payment bandwidth is the onchain payment bandwidth divided by the expected rate
of infeasible payments.  And what I can show is that the expected rate of
infeasible payments really drops exponentially when we have multiparty channels
with the party size, and that's nice.

To bring this in a much broader context, I think this is where ideas like Ark
and all these timeout-tree ideas come in, because people intuitively understand
it would be really good if we have a lot of people in one UTXO.

**Dave Harding**: Yeah, that's definitely kind of a hidden advantage of that,
because like you said, when Christian first published about channel factories, I
also thought the main advantage there was UTXO-sharing reducing the onchain
footprint.  But its ability to make more wealth distributions feasible and
therefore improve routability and decrease the risk of channel depletion are not
things that I would have expected from that work.  Do you have a sense for how
much gain you get there in preventing channel depletions from just modest
increases in multiparty?  I assume at some point channel depletion is inevitable
no matter how many people you have in a channel, as long as everybody isn't
sharing one.  If everybody shares one, then everything's feasible, right?  But
is this a major gain, is this a modest gain; do you have a sense for that?

**René Pickhardt**: No, so let's stick with your example first.  I mean, you're
exactly right.  If everybody is in the same channel, then you're back to the
Bitcoin onchain case where every wealth distribution is feasible.  You just
don't need onchain transactions anymore, because you resolve everything
offchain, but you have a lot of communication overhead.  I mean, this is one of
the criticisms about these multiparty channel protocols.  And I mean it's like,
so to speak, it's nice that I provide a theoretical sound insight of saying,
"Hey, multiparty channel constructs are great".  And then all the engineers are
yelling at me.  It's like, "Yeah, René, we know that already intuitively, but
the engineering is a mess".  I'm like, "Yeah, that's on you, right?"  So, I
mean, that's a little bit sad, right?

But then again, if you just take the example that I just provided with just
three people, you already have so many more wealth distributions that are
feasible.  And as I said, it somehow grows exponentially.  I don't know what a
good number is for multiparty channels.  Currently, with the simulations that I
made, it seemed like when we allow ourselves like 100, it's like really, really
sufficient.  Like, we get basically practically everything that we need.  But I
mean, that's more in speculation terms right now.  Yeah, that's ongoing
research, so to speak.

One thing that I should mention is that this formula in the paper, in the next
version of the paper, I will correct this and provide one more section to
discuss this a little bit more precisely, because you basically have to reduce
the onchain bandwidth that you have with the expected bandwidth that you consume
for force closes and unilateral exits.  Unilateral exits become more likely and
more expensive the larger your multiparty construct becomes.  So, while the
numerator becomes smaller, your reliability gets better, you also have less
onchain footprint available, statistically speaking.  So, I assume this is an
optimization problem, again, similar to the question of, how do you split
payments in a multiparty payment?  So, I would assume there is an optimal
channel size that gives you a good trade-off between the likelihood that you get
forced closes, the cost of the forced closes, but the gain that you get on the
other side of using this.  I think everybody already understands intuitively a
full multiparty channel with everyone is just too crazy.

**Christian Decker**: Oh, absolutely, and I think this is worth highlighting
once again.  Your research looks very much at the efficiency and at the
feasibility and at the optimizations.  There are other aspects that will cause
us to not go full Monty with a multiparty channel.  Like you said, having
everybody in the same channel is probably the worst idea we could have.  Having
just two parties, well, then we're back to the Lightning penalty, Lightning
current analysis, right?  So, somewhere in between, I guess, is the right place.
And there are operational aspects to this as well, some of which have given rise
to Ark, for example, right?

Ark's whole reason to exist is essentially to have a shared UTXO from which you
can unilaterally back out, that does not require every party to be online when
changes are being performed.  And it's this online requirement that gives me the
most headaches, so to speak.  Because ultimately, you have to have a certain
certainty that your other parties in the multiparty channels will be there when
you need a signature from them.  Otherwise, your nice multiparty channel, which
has several outputs and whose footprint therefore is quite considerable, will
have to go onchain and consume some of that costly onchain bandwidth that we're
trying to conserve, which we're trying to make better use of.  So, by going too
big, you might actually be going in the wrong direction and adding loads to the
onchain network, rather than relieving it from the onchain.

**René Pickhardt**: Yeah.

**Christian Decker**: So, it's always important in these kinds of discussions to
keep in mind that we're sort of shining a light from one angle, but there are
other considerations that we need to look at as well.

**René Pickhardt**: Absolutely.

**Christian Decker**: And yeah, that's just a caveat that bears repeating, I
guess.

**René Pickhardt**: Yeah, absolutely, fully agree with you on this one.  I mean,
it took me quite some time to understand that too, because when I first had
those results, I was like, "Yeah, multiparty channels, we do them and everything
is happy".  And I was like, "Yes, but they come at a cost", you know.  I think
there is this covenants research blogpost by Peter Todd, where he also points
out that timeout-trees and all these things bear, like, a cost.  And his
analysis is very qualitative.  But what I'm currently lacking is to see a
quantitative study where you really express this in numbers and say, "Look, this
is how many force closes I can allow myself and this would still be possible,
and this is where I hit the boundary".

Yes, I mean you mentioned in the beginning that my paper now seems to be like
finished, but as I said, it's still a work in progress.  And this is exactly the
one section that is still missing that I want to provide a quantitative analysis
and study of how many onchain force clauses can we allow ourselves, given a
certain multiparty channel size, so that we could probably, hopefully, find the
sweet spot of what is possible there.

**Christian Decker**: That does depend, however, on the construction of the
multiparty channel, correct?

**René Pickhardt**: Exactly, yes, but you can make certain assumptions.  So, for
example, the onchain costs usually are logarithmic in size.  I mean, all those
tree constructions produce the fact that you drop down the root and drop down
the path of the tree.

**Christian Decker**: Okay.  So, I mean the least strong assumption is
essentially that every participant will have to have an onchain output at some
point, right?  You might also have the requirement that every participant has to
provide some funds to the contract, although that is less strict.  So, n outputs
and at least one input is sort of the minimum footprint you can think of.  If
you consider trees now, you're right.  Assuming that only an individual
participant needs to leave, then your onchain footprint is log in, transactions
onchain.  But if you have multiple people leaving, or the contract just not
continuing, or the coordinator just disappearing, then you're actually adding
overhead through the tree constructions, right?

**René Pickhardt**: Yeah, absolutely.

**Christian Decker**: So, again, also here it very much depends on the behavior
of the actors in the system and no analysis will give you the number, but they
will give you numbers that will tell you what works better in one case or
another.

{:#hubandspoke-transcript}
_Hub-and-spoke topology discussion_

**Dave Harding**: It seems interesting to me, you describe a spanning tree as
being basically the same thing as a hub-and-spoke topology.  And when we look at
the design for a lot of these timeout-tree style factories with, you know, one,
maybe two large parties who control the thing, and a bunch of small end users in
it, we basically get a hub-and-spoke topology.  It implies that it deals with
depletion.  If we had a hub-and-spoke topology, we wouldn't have depletion as a
problem.  And we are kind of moving in that direction, maybe, with timeout-tree
style channel factories.

**René Pickhardt**: Yes, I agree.  And I would kind of like to add, I think it's
even more.  So, I think a lot of these like Ark style timeout-tree SuperScalar
ideas and systems are for LSPs to onboard their users like as the last mile,
kind of thing.  So, it's basically for them, not only the question of depletion,
but also the question of capital efficiency.  I think it's known that the
Phoenix Wallet and Eclair always had to open channels for the users to get on
board.  So, there was a lot of liquidity just stuck in those channels, even
though if users provide sometimes the liquidity, often enough, Eclair had to
provide the liquidity.  And even though users paid for it, I mean if the users
then didn't receive payments, the liquidity was there and they couldn't just
close the channel, because I mean it was a service that they wanted to have,
right?  So, there's a lot of overhead.

Whereas if such a construct, if the ACINQ node would be able to have all those
users in one of those timeout-tree style constructs, I mean then they could just
be much more capital efficient among their users.  I think that is one end,
right?  But what we could understand is that those users that before formed a
star, now form this multiparty channel factory.  And of course, a multiparty
channel factory allows for more wealth distributions than just a star.  Because
let's make this very explicit.  Let's assume you have ACINQ in the middle and
they have, let's say, 10,000 channels with every user, 1 bitcoin every user.
Well, then every user can at most have 1 bitcoin.  ACINQ at most can have 10,000
Bitcoins.  I mean, all the money could be there.  But if you had a 10,000-people
multiparty channel, well then every user there could have those 10,000 Bitcoins.
Is it likely that every user there would become that state eventually?  No,
probably not, because ACINQ is still the middle.  But why should ACINQ have so
many bitcoins if they are just a service provider?

So, I mean this gives you the intuition of why these multiparty channel
constructs are somewhat reasonable.  And then the hub and spoke is basically the
residual LN between those service providers.  And you could think of this
basically as a hierarchical routing system, whereas the last mile routing is
within this community, and then you have like a hub-and-spoke model that is on
top with the two-party channels between the LSPs that provide settlement on
larger quantities, similar to how internet traffic has this Tier 1, Tier 2, Tier
3 networks.  And I mean, that's very often in logistics the case, that you have
different kind of traffic and links.

**Dave Harding**: I know this goes beyond your research, but does that concern
you in any way?  When LN was first being proposed and built out, trying to
design it to avoid a hub-and-spoke topology was something that was important to
a lot of people, a lot of the early contributors.  How do you feel about this
research that indicates that we kind of default to a hub-and-spoke topology?
Sorry, go ahead, Christian.

**René Pickhardt**: Okay, I think I have to start there first.  There is a
concern about a hub-and-spoke topology, as I said before, because if a channel
breaks or if a channel becomes un-operational, then the entire network falls
apart.  But the hub-and-spoke or the tree is only the residual of all the
depletion that is there.  So, what I said before is the location of the tree is
not stable.  Given how a certain wealth distribution is and how money flows in
the network, the residual tree could be somewhere else.  In that sense, having
additional channels, yes, the depletion phenomenon occurs and yes, that forces
us to have more retries unless we have smart reverse logistics protocols.  But
those additional channels are like a battery, like redundancy.  They give us a
certain opportunity to still make payments.  So, it's not that the network in
itself just stays with channels that are a spanning tree.  It's just the uniform
distributed component that is a spanning tree.  The network still is
decentralized and resembles very much of a small-world network.

I mean, as you know, I'm not a Bitcoin OG.  I came to this entire field because
I did a lot of work in networks and it was really the LN part that attracted me
to this.  I was like, "Hey, you guys have problems there, let me help".  I was
very excited about that.  And one of the intuitions that I had very early was
the LN topology should be a small-world network kind of structure, and I think a
lot of people knew this too.  And I think those networks are very resilient and
very strong and very good.  And we saw exactly that kind of network to emerge,
yet we still see a lot of channels deplete and at a certain point of time, a
spanning tree that is un-depleted where we have this uniform distribution.  In
that sense, I don't think it's a particular concern.

**Christian Decker**: So, I'll just add the historical context for this, because
when we spoke about designing the LN, the question of, "Hey, what structure
should it have?" definitely came up.  And hub-and-spoke was sort of what
everybody globbed onto because it was the simplest form of network structure,
the one that everybody understood, because they have a PayPal account and they
can send through PayPal.  So, why shouldn't the LN work the same, right?  And to
be fair, there are a couple of protocols that tried to go down that road, and
they failed miserably.  Probably exactly because of one of our concerns was that
the hub-and-spoke system, where you're only ever allowed to have a single
central hub, is a very brittle system, as René just pointed out.  It's one where
a single connection breaking down disconnects one participant.  The hub breaking
down breaks the entire system, right?  So, there is no resilience, there is no
recovery, there is no redundancy whatsoever, making for a very efficient
network, but a very brittle one.

With the depletion, those depleted channels, they are still there, right?
They're not being torn down.  And if it happens that on a spanning tree, some
channel dies, this redundancy that we might have considered an inefficiency
comes back into the game, and now ensures that we're not partitioning the
network, we're not creating two islands that can't talk to each other anymore.
But the redundancy of the depleted channels still hanging around enables us to
resume our operation, despite one of our participants, whether it's a big hub or
a single channel, disappearing; we can still survive that downside.  And we
definitely did not want to have anything coercive in the protocol, right?  Sort
of making one node in the network the king of the network is something that goes
very much against our ethos.  It's the single point of failure, yes, but also a
perfect place to put in censorship, put in auditing, putting all of the fun
regulation that we don't actually need, because we are more secure than the fiat
currency system.

So, by not going for a hub-and-spoke system, we wanted to create a more
resilient, a more egalitarian system, where every single participant can become
any role they desire to become.  If you want to be a big node operator, well,
it's up to you to put in the work, but there is no license you have to acquire,
for example.  And at the same time, the depletion making the LN network look
like a hub-and-spoke system isn't actually bad, because the edges are still
there, that redundancy is still there, that safety net is still there.  And so,
it's a bit different depending on which context you look at.  But I think it was
a good choice not to go for hub-and-spoke, and I'm very happy that it's not sort
of coming in through the back door now.  Yes, René?

**René Pickhardt**: Maybe I can add, in my time before I joined the LN
community, I was a researcher at the Institute for Web Science and Technologies.
We studied the structure of the web quite a bit.  On a protocol level, the World
Wide Web is a very decentralized system.  Everybody is allowed to spin up a web
server, everybody has a web client, and it just forms a web, it forms a network.
That being said, on a decentralized structure like this, you have central
players emerging.  You have those Googles, you have those Amazons.  You don't
have to like them, but they're still there and they're providing a good service
for a lot of users, and it's part of the decentralized structures that those
centralization tendencies, on a user level, can emerge, and I don't think that's
necessarily a bad thing.  Because even if everybody, or a lot of people start to
use the World Wide Web because it's so convenient with these central players, I
mean yes, then you have a lot of people having a web browser.  Now, I can come
as a hacker and have my web server and can do the Snowden leaks, or whatsoever,
right?  So, even those centralized players strengthen the decentralized
technology that underlies it, because they're using it.

I think a similar argument can be made in the case of the LN, where you say the
technology has to be decentralized, the technology has to be permissionless.
Yes, the economic, rational behavior can force certain players to have
centralization forces, but that doesn't make the underlying technology central,
right?  I mean, it's a question whether you, as a protocol designer, say, "I
want to create a protocol that is centralized by design because, you know,
spanning tree protocols and hub-and-spoke is like really good in logistics", or
if you have a technology that is decentralized.  But yeah, certainly user
behavior centralizes it a little bit, but users have the option to use a
different service provider and to make their choices.

**Christian Decker**: As always in Bitcoin, I think this mobility of people
being able to take on whatever role they decide they want to take on, right,
become your own bank, become a Lightning Node operator, become a payment service
provider for your friends back in your home country, all of these you can do as
a Bitcoin community member, because you have all of the technology, you have all
of the regulations, and you have all of the help, hopefully, that you need to
set that up.

You were mentioning the technology is open, but just as a reminder, we also need
the regulatory bodies to maintain that freedom of movement between roles, right?
Because the regulator is the one that it might be tempted to push towards a
centralized structure, because it's easier to govern these centralized
structures.  And they are then going to play kingmakers, right, and that's where
we need to resist.  I think we need to maintain the flexibility of those roles.
I'm not a lawyer, and that's how much I'm going to say, but I just wanted to
mention that technology, yes, is one part, and we're definitely doing our best
to give you the opportunity of having the chance of becoming whatever you want,
you dream up of, but there's other aspects, like finances.  Dave mentioned
before that there are financial limits to your personal goals, but there are
also regulatory limits, and that's where we need to stay alert and maintain that
flexibility.

**Dave Harding**: Okay, it looks like we're coming up on an hour.  René,
anything important we haven't covered yet?

**René Pickhardt**: I don't think so.  I mean, I have a list of notes that I've
made myself and I think you have done an excellent job asking me all those
questions.  I have to state that the work is ongoing research and as with every
research, it uses certain assumptions, right?  I mean, I'm trying to uncover
certain phenomena and try to give explanations of why certain things happen and
occur.  So, obviously, within my work, I also have to make certain assumptions
that may or may not be accurate, given the reality.  So, those results always
have to be taken with a little bit grain of salt.  I think that's important to
mention.  That being said, I think the explanations for the phenomenon itself,
even though my assumptions may not be accurate, I think those explanations are
somewhat safe, hopefully, who to say.  But research always, I mean better
evidence wins.  If somebody comes up with better evidence -- yeah, sorry.

**Dave Harding**: Well, I mean, thank you so much for researching this and all
of your research.  There's been a lot of really interesting, to me at least,
conclusions and insights that you've come up with over the last couple of years.
It's been really fun for me, as someone who doesn't have to do the work, just
has to read it, to learn about all this stuff.  Mike, Christian, anything you
guys want to add?

{:#data-transcript}
_What real world data would inform the theoretical?_

**Christian Decker**: I just have one last question.  Of course, René, your work
is excellent and, yes, it's ongoing, but it's already at a level that I would
have probably published it a couple of months ago.  But I wanted to ask if your
work being theoretical, it could probably use some real-world data that could be
used to verify those findings?  What would be your ideal data source?  Do you
have any concerns as to privacy for that data as well, just so we cover that as
well?  But is there a way for you to get some small bit of data and verify that
things are actually looking like they are today, so that we can exclude your
assumptions as a cause for problems?

**René Pickhardt**: Yeah, so that's a very excellent point.  Thanks for bringing
this up.  Most of my results stem from -- I mean, of course, I'm operating a
Lightning node and I have a little bit of data myself, but I talk to people, but
then I try to really become theoretical and just really study the math and study
what happens.  And then I see I can derive certain patterns and behaviors that
people are telling me about.  But of course, making the exact comparison or
using not some priors, like I'm always using a uniform distribution, but you
could use payment pairs that are really more realistic.  So, yes, if an LSP or a
bunch of LSPs would be willing to share their data in a certain timeframe with
me, so that I have a view of the network of where the liquidity is and how the
fees were, of course, we could have a much better verification of those results
and make experiments.

That being said, I'm trying to predict the global wealth distribution and just
missing one channel already could change a lot of these things, because as I
said before, it's a global problem.  So, it's a little bit tricky.  I'm
currently actually talking to some people how we can set up experiments in order
to verify these things.  And yes, it's very tricky, but yes, I'm open to
collaborations and to verify some of these findings with real-world data, and to
also see how real-world assumptions would change the predictive values of some
of these results, because that's always how I justify my work.  I'm saying,
"Hey, it's open source, and you can plug in your data and your knowledge and you
can use the same mechanisms to derive your results".  But I think with these
kinds of topics that I have, our community should have a good incentive to have
this more open source, because I think everybody benefits from understanding how
liquidity is on the LN.

As we explained in this podcast, for example, this free, circular rebalancing is
something that is most likely economical for the entire network, because by the
end of the day, the reliability goes up, this is good for users, the network
will be used more along those routes that are already profitable for people,
because they have selected their fees in this way.  So, yes, I think there is a
reasonable argument to be made to have this kind of research in the open.

**Mike Schmidt**: Thank you very much.  René, Christian, Dave, great discussion.
Thank you all for joining.

**Christian Decker**: Thanks for having us.

**René Pickhardt**: Thanks for having us, exactly, and for the kind words,
David.

{% include references.md %}
[channel depletion delving]: https://delvingbitcoin.org/t/channel-depletion-ln-topology-cycles-and-rational-behavior-of-nodes/1259
