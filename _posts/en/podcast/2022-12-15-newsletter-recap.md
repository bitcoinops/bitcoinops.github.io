---
title: 'Bitcoin Optech Newsletter #230 Recap Podcast'
permalink: /en/podcast/2022/12/15/
reference: /en/newsletters/2022/12/14/
name: 2022-12-15-recap
slug: 2022-12-15-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Ben Carman and
Joost Jager to discuss [Newsletter #230]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-6-19/339916080-44100-2-7b23acf80a2fd.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #230 Twitter
Spaces Recap, thank you all for joining us.  This will actually be our last
regular newsletter for the year.  Next week, we'll actually be publishing our
Year-in-Review, and I've taken a quick look at that in draft mode, and it's
going to be another great one.  If you want to catch up on all the progress
that's been happening in the Bitcoin ecosystem over the last few years, it could
actually be fun to go back and look at those previous year-end reviews to pat
the community on the back a bit about how much progress has been made over these
last several years.  So, look forward to that coming out Wednesday.

Then, we will actually be doing the Optech Recap Twitter Space at the same day
and time next week, our usual time, and we'll actually have a special guest,
Dave Harding, and it looks like we actually have a special guest, Dave Harding,
today.  So, Dave, I'll invite you to speak if you care to, otherwise you can
hang out and listen to some of the smart folks that we have as guest speakers
today, which we'll introduce shortly.  First, I'll introduce myself, Mike
Schmidt, contributor to Bitcoin Optech, as well as Executive Director at Brink,
where we support Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.  I do a bunch of
education stuff, co-host BitDevs in New York, and sometimes also try to
contribute to open-source software.

**Mike Schmidt**: Benthecarman?

**Ben Carman**: Hey, what's up guys?  I'm the lead dev at The Bitcoin Company,
but work on a way to make free, open-source projects in my free time.  I also
co-host Austin BitDevs, which is tonight.

**Mike Schmidt**: Thanks for joining us, Ben.  And Joost?

**Joost Jager**: Hello, I'm Joost.  I work at NYDIG, and I'm active in the
Lightning development sphere, mostly LND and some protocol, VR's, which you
might have seen.

**Mike Schmidt**: Well, thanks for Ben and Joost joining us today.  0xB10C is
here and just setting up on his mobile device, since that's the only way that
you can speak in Twitter Spaces currently.  So let's jump into it.

_Factory-optimized LN protocol proposal_

First item under the news section for this week is factory-optimized LN protocol
proposal.  And we've attempted to get John Law on previously, but he is a
privacy-focused individual and doesn't wish to communicate verbally, but he does
communicate on the mailing list as we see.  So he's posted a proposal to the
Lightning-Dev mailing list with a protocol for channel factories, and it's
probably good, I don't think we've covered channel factories at least on these
Twitter Spaces.  I guess the high-level description or idea of a channel factory
is to allow multiple users to open multiple channels in a single transaction
onchain.  So, you'd have a single transaction and then from that output, there
would actually be offchain channel opens as opposed to onchain channel opens,
and it greatly increases the number of channels that you could create in an
individual onchain transaction, which is great.  And you hear a lot of folks
throw out channel factories sort of vaguely as a way to scale Bitcoin usage to 8
billion people.  So, it's nice to see some research in this sphere.

In terms of this exact proposal, I know, Murch, you had some questions or
considerations about the feasibility of this particular proposal.  Go ahead.

**Mark Erhardt**: Yeah, so I tried to make head and toe from it, or figure out
how useful it would be in practice.  And I think that generally, I would sort of
cast this more as an academic, theoretic experiment where you look into what you
could do with a channel factory and what trade-offs you'd have to make if you
were basing it on an LN penalty update mechanism.  So, the big problem of course
is the asymmetry in LN penalty, and that means that you have to keep separate
states for each possible outcome.  So, every member of the channel factory
dropping off has to give every other member of the channel factory the chance
to, in this case, close down the whole channel factory.  So, it seems extremely
brittle to set up, and the other trade-off that was listed in the proposal, as
far as I understand it, is the Hash Time Locked Contract (HTLC) timeouts had to
be extremely long, because it has to allow for every single participant to
closed down the channel factory together.

So, I think that we will not have channel factories before we get eltoo, or
something like it, and in a way, this proposal on how to do a channel factory
that would do it highlights that, because it sounds very complex and brittle.
So, the point of having a channel factory where you onboard multiple users into
a construct, where each of them has a channel to each other member, but as soon
as one person becomes unresponsive, the whole construct has to be played out
onchain with all the sub-transactions, seems like a very poor scalability
trade-off.

**Mike Schmidt**: John Law, he pointed out two problems for opening channels
within a factory, at least as can be done today.  And then he proposed three
different protocols as ways to address those concerns that he outlined, and
those protocols are all somewhat derived from a proposal that he put to the
mailing list in October about tunable penalties, and that involves separating
the management of the penalty from the management of the funds that would
actually be in in the channel.  Murch, I don't know if you reviewed that tunable
penalties proposal and have thoughts on that outside of channel factories, or
any of the details of the protocol?  We can jump into it if so, otherwise maybe
if Joost has any feedback on this.  I know this isn't necessarily his domain in
Lightning, but perhaps you have some comments.

**Mark Erhardt**: Yeah, I must admit, I read the summary that Dave wrote for us,
and then I looked at the mailing list post a little bit to see what questions
people asked, and it didn't seem to generate a lot of discussion yet on the
mailing list.  So, I did not look too much into it further after seeing that the
HTLC timeout was set to one day.  That seemed so prohibitive in practice.  I
think it's more of, if you're into channel factories and channel factory
research, you might want to talk the finer details of how that could come about
and what you need to think of, but I just don't think that this is a practical
proposal.

**Mike Schmidt**: Joost, do you have any thoughts on this, or is this just far
removed from the work you've done on Lightning that you can't comment on it?

**Joost Jager**: Yeah, the latter indeed.  I've mostly been active in the
offchain part of Lightning, trying to solve problems that might be much more
mundane than this, so I can't really comment on it, sorry.

**Mike Schmidt**: Well, hopefully these proposals get a little bit more rigorous
responses on the Lightning-Dev mailing list and we can cover that in a future
newsletter.  For now, I think we can move on to, as Joost you say, maybe some
more of the more mundane, maybe practical challenges on the LN currently.

_Local jamming to prevent remote jamming_

I know we've had you on previously to discuss fat errors, I believe.  And now
you have a project called CircuitBreaker.  Do you want to maybe quickly
introduce the problem that CircuitBreaker was attempting to solve, and then how
CircuitBreaker was originally created and now this modification that you've made
to sort of address some of the jamming concerns on the LN?

**Joost Jager**: Yeah, definitely.  So, to start with the problem, it has been
known for a long time that there is a vulnerability in Lightning with jamming
and spamming.  And spamming, you could define this as HTLCs that your node has
to forward which fail eventually, for whatever reason, meaning that you don't
collect any routing fees, but it did take up resources, it did take up disk
space, money has been locked in your outgoing HTLCs that resolves in a failure
eventually.  And jamming is similar in a way, but the difference is that the
HTLCs really get locked for a long time.  So, these are also forwards that most
of the time don't result in any routing fees earned, but they lock up a lot of
liquidity.

For these problems, a lot of brainstorming has happened into possible solutions
like this, for example, paying upfront fees to discourage people from doing
this, or maybe reputation tokens is something that has been discussed more
lately.  And CircuitBreaker is another way to try to fix this, and it's much
more conventional really.  You could look at this as a firewall for Lightning.
So, if you're running a routing node, you can set limits for your nodes, you can
set limits for your peers as to how many HTLCs you want to forward for a
particular peer per second.  You can have all kinds of variations there.
Currently in CircuitBreaker, it's a leaky-bucket algorithm to limit the rate of
HTLCs to a set number.  And the second limit that Circuit Breaker offers is the
maximum number of in-flight HTLCs, and this is to prevent the damage from
channel jamming, because with channel jamming, if you've got an outgoing channel
and there's a lot of HTLCs stuck on there, a lot of money can't be used for
anything else.  And also, if that channel would go through a forced closure, it
can be very expensive because there's a lot of spent paths that need to be
resolved onchain.

So, yeah, CircuitBreaker is a very low-tech way, very traditional way to solve
this, just put those limits on your node.  And the theory is that if everyone
would do this, everyone would run CircuitBreaker, it becomes much more difficult
for an attacker to jam or spam, because everywhere they open channels to, they
run into low limits, so they need a lot more channels to achieve the same
effects.  Just to illustrate this, currently if you open a channel to a node,
there's generally no limit applied, and this means that you can send HTLCs as
fast as both of your nodes can process that traffic, create signatures and so
on; and also the maximum number of in-flight HTLCs, for LND at least, is set to
483, which is a really, really high number by default.

So, that's the theory.  If a lot of nodes run CircuitBreaker and they apply low
limits to peers that they don't really trust or peers that are new, or maybe
it's peers that didn't pay a loyalty bond or peers that didn't show proof of
UTXO, you can come up with all kinds of ideas how to figure out what limits to
apply to your peer.  But if everyone is doing that, the network as a whole
should become much more resilient against jamming and spamming.  But that's
basically the background, and the CircuitBreaker Project exists, I think, for
more than two years now already.

The change that I made here is in a way that's in the actions that are executed
once limits are exceeded.  So, in the original implementation, the action that
was executed was to fail the HTLC.  So if an HTLC comes in and exceeds the rate
limit or exceeds the maximum pending HTLC limit, it's just failed back, and it's
failed back all the way to the sender of the payment, and they can try again if
they want to.  And what's new now is that they added an additional mode, which
doesn't cancel the HTLCs, but they put them in a queue.  So, from the
perspective of the sender, the payment becomes very slow because the HTLC is
sitting in a queue there and only when its time has come, when the rate limit
opens up again, another HTLC is processed.

It's debatable whether this is an improvement or not compared to failing it.
But I think one interesting characteristic of holding the HTLCs is that you are
in a way causing pain to your peers.  You are holding their money too.  Every
node upstream is seeing the HTLCs locked on the outgoing channels, and they
might not like this for the reasons mentioned before, for example, force
closures can be expensive and also the money can't be used for anything else.
So, it's a way to signal that the traffic that they facilitated, the traffic
that they forwarded, that there was something wrong with that, and maybe they
should think more carefully about the traffic that they forward.  Maybe they
should also install something like CircuitBreaker to clamp down on their peers.
And that's the theory here behind holding HTLCs, trying to send a clear signal
to move your upstream peers, all of them, to also be more careful about where
they accept channels from and what kind of limits they initially apply there.

But I have to say, it's very difficult to predict how this is going to play out
on a large scale.  So, I just added the option there for people to experiment
with, see how it works.  I can also totally imagine that you're saying, "Okay,
this whole idea of causing pain to my peers does not appeal to me.  Maybe
there's no problem at the moment on the LN, so why would I do that?"  I can
totally see that point too.  So, it's a very ongoing thing.  But I did want to
put it out there just for people to at least think about and make up their mind
about what this would mean if this would be the general mode of operation of
Lightning firewalls.

**Mike Schmidt**: There's a graphic that we included with this segment of the
newsletter this week, and it has a visual representation of the two types of
jamming attacks, the liquidity jamming attack as well as HTLC jamming attacks.
And you mentioned the 483 HTLC default.  Does CircuitBreaker also handle the
liquidity jamming attack scenario directly, or is this just for HTLC slot
jamming?

Yeah, so currently, max spending HTLCs are independent of the amount.  So, you
could say it's only handling the HTLC jamming attack, as it's called in the
newsletter.  But I am thinking also about different types of limits, for
example, limiting the total value locked, for example.  So it's a lot of smaller
HTLCs are still allowed, but if you cross a certain limit, then the node stops
forwarding.  There's a fairly large design space in these limits, things that
you can do.  Perhaps it's also possible to not have a limit on the maximum
pending number of HTLCs, but more on the average number of slots occupied, so
that you also take into account like how long were those slots locked.  So,
yeah, you probably need more feedback from routing node operators as to what
kind of limits really make sense to get their traffic patterns under control.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: This reminds me a lot of the proposal that Clara and Sergei
put out a few weeks ago, with allowing your peers only to have access to part of
your resources if you don't trust them yet, and then increasing it to the full
capacity and slots of your channel if you trust them or think that they are
well-behaved peers.  This seems to have a little different trade-offs.  Would
you say that it is compatible or a replacement of that proposal?

**Joost Jager**: Well, I think both of them are -- their proposal has two
components.  They have an unconditional fee component, which is not part of
CircuitBreaker, and the other component is a local reputation between you and
your peers, and I think that's in a way very comparable here, you can make a lot
of decisions about how to establish that reputation.  I think what they add to
this is that as a node, you're also able to endorse certain types of traffic.
So you can tell your peer, "I'm forwarding you this, but I'm not sure if this is
coming from a source that is well-behaving, so you might want to treat this in a
different way".  So, that's something that they add to there, but I think both
of these solutions fall in the same category of local reputation systems.

**Mark Erhardt**: Cool, thanks.

**Mike Schmidt**: Go ahead.

**Joost Jager**: Yeah, so I wanted to add one thing.  So, something I'm also
thinking about is how would this work out if there would be like a very
accessible UI for this that also helps in providing insight in how much of that
spamming and jamming is actually happening on this node?  Because I've been
talking to a few node operators and asked them, "Okay, HTLC spam, is that a
problem for you?"  And some said, "I'm not sure, really, how can I find this
out?"  And if you use LND, it's not so easy to find this out.  There's a
particular streaming API that sends you HTLC events, and not many node UIs that
surface that data in a very accessible way, if at all.

If you would have a UI that shows you, imagine like a dashboard, you see all
your peers, you see what they did in the past five minutes, in the past hour, in
the past 24 hours in terms of failed HTLCs, routing revenue earns, total
liquidity locked up or, whatever metrics you think are important.  And then next
to that, there are like sliders that you can use to set those limits.  So if you
see patterns in your traffic that you don't like, you can just pull those
sliders and just adjust what they can do, and then over time observe what it
looks like now, because I traveled down a particular pair.  Maybe slots opened
up on the outgoing slide that I then used by traffic coming in through another
pair that is of higher quality, something like that.  So I think I can imagine a
very fun and almost gamified interface for routing node operators to control
those flows and also optimize their operation.

**Mark Erhardt**: So some of the interesting statistics might be how many HTLCs
were requested by a peer, how many of them closed successful, how much funds
were held for how much time in total, things like that, right?  And so, you're
saying that LND currently does not really habitually present that data?

Well, it presents the raw data, so there's a stream of all the events that
happen, like events that HTLCs are forwarded, agencies that resolve if a success
or a failure.  But I'm talking about a UI that presents this in an accessible
way.  Like, not every node operator is able to write their own custom tooling to
interpret that stream and then draw appropriate conclusions from that.  So, I
think that's definitely something to gain there in making the information
accessible and combining it with controls to directly influence those limits,
all in the same view.

**Mark Erhardt**: Right.  Is there other software that does this at all yet,
like BTCPay Server or a different Lightning implementation?

**Joost Jager**: I'm not sure.  I looked at a few, like I saw LNDg, which
apparently is used by a few node operators to look at this, and it does
subscribe to this stream that I mentioned, but it seems to only surface the
failures that your own node generated, whereas in the case of spam, it's very
often HTLCs that you forward and they fail somewhere downstream.  So, this
particular tool wouldn't display those statistics, whereas those are actually
quite interesting to see, like, "Okay, how much load is my load seeing that led
to nothing, to no routing revenue at all?"  Sorry, go ahead.

**Mark Erhardt**: Sorry, go on, I thought you were finished.

**Joost Jager**: No, I wanted to say, there's another tool I looked at as well,
it's called Torque.  And with Torq, it stores all those events, but there's no
UI yet there to service it, but they commented on the issue that it created
there, that they were planning to release a UI to surface those insights in the
web interface that they offer soon.  So, there's some movement there, but
there's also a difference between some of those tools which are mainly to get
insights, and they are not necessarily something like CircuitBreaker or a
firewall.

So, I'm also wondering if that's the direction where it's going, like these UI
tools that now are more like one-on-one interface to LND's, or whatever node
implementation you use, functionality versus adding functionality to it, such as
CircuitBreaker, which is really something new.  It's not controlling
functionality in LND, but it's living outside of LND or outside of another node
implementation and actively doing something.  So, just interested to see where
the development of those tools is going, those UI tools.

**Mark Erhardt**: Right.  So, what's your gut feeling?  I've seen a lot of
research and discussion of jamming and quick jamming and slow jamming.  Is the
problem that we currently can't measure it happening and that's why people don't
know whether it exists; or is it perhaps that it isn't happening that much yet?

**Joost Jager**: Yeah, well, that's a good question.  It seems to me, but this
is also an impression from talking to people because, of course, nothing is
really visible on a LN for an external observer, I think the channel jamming,
and especially intentional channel jamming, it doesn't seem to happen so often,
and it's also quite easy to see.  Like a lot of these tools, they show the
number of pending HTLCs, and if you have channels with 480 pending HTLCs, your
channel jams.  And I would think there would be more noise about it if that
would be a common thing to happen to you.

But spamming it is different because, as I mentioned, it doesn't seem so.  There
are definitely node operators that have no way to even answer that question.
And also, people have been complaining about the growth of the size of the
database, for example, because there was a lot of activity happening and it
didn't all translate directly to routing fees earned.  So, I think if you had to
pick between the two, it seems that spamming is a more prevalent thing at the
moment.  And it doesn't need to be like an attacker, just spamming to disrupt or
whatever, grief nodes.  Yeah, you could also say that rebalance tools that
continuously look for opportunities to rebalance in along a favorable path to
resell that liquidity at a later point in time.  And they are continuously
probing paths to find those opportunities.  You could say there's a functional
reason for doing that, but it's also perhaps too spammy for the likes of route
node operators.

**Mark Erhardt**: So, maybe an unconditional fee that people have to pay for
probing would be helpful in just at least monetizing that information.

**Joost Jager**: Yeah, that's the other great direction to explore to see if
that could help.  But it's difficult to do this in a way without hurting the
user experience of legitimate users.  You have to explain to them that it costs
you money to try payments that fail in the end.  So, yeah, I'm not sure that's
going to make it.

**Mark Erhardt**: I just want to very slightly push back on this, because I
think that, at least how Clara explained it to me, if you allocate a tiny bit of
the budget for the payment to make the failed attempts and just say, "I estimate
this to be, whatever, 10% higher than actual payment that you need to do for the
working multi-hub payment, then if it is less than the initial estimate, you're
good".  And usually, because the upfront fees would be so much smaller than the
actual fees, even if you allocate a little portion only, you would overestimate
most of the time and I think the UX would be fine, sorry!

**Joost Jager**: Yeah, maybe, but I also think we should not estimate the
psychological difference between free and a tiny amount of money.  Suppose you
would need to pay for everything you tweet on Twitter, but it's like 1 cent, for
example.  So if you add it all up, unless you're crazy tweeting a lot every day,
it's negligible, but still it feels psychologically different for some people, I
can imagine.  So, I'm not sure if that will also be the case on Lightning if you
introduce this.  Maybe there's no problem with that and the advantages far
outweigh this slight downside, but it's just difficult to say, I think, without
actually deploying it and forcing users to pay this if they want to make a
payment.

**Mark Erhardt**: That's fair enough.  Okay, what do you think, Mike?  I think
we might have covered this pretty well.

**Mike Schmidt**: I think we covered it pretty well.  I did have one more
question before we move on, which is, we covered CircuitBreaker and this recent
change to CircuitBreaker, but as you mentioned, this tool has been around and
open-sourced for a while.  I'm curious if you're aware of any other
implementations adopting a version of this in their software.

**Joost Jager**: You mean to integrate this in Lightning node software?

**Mike Schmidt**: Yeah, outside of LND.

**Joost Jager**: Yeah.  So I think the hooks exist also for other node software
to do stuff like this.  I'm not 100% sure, but I've seen like Interception APIs
also for the other node software.  But I don't think any of those is integrating
this directly into the software.  So, regardless of which implementation you
use, it seems that it needs to be an external process that does this limitation
of HTLC forwarding.  And that's also interesting, because if the goal is to get
everyone to run this, one way or the other, whether it's through annoying your
peers by holding the HTLCs if they spam you, or different means, it seems the
goal is to get everyone to run this, and maybe a very straightforward way to
accomplish that is to make it available by default inside a node implementation
that they need to run anyway.

So, perhaps this is a good way to go, to try to get it completely integrated.
Otherwise, it's going to live outside, similar to CircuitBreaker, or if there's
different projects for other node implementations that do roughly the same.  But
I'm not really aware of anything that does the same for C-Lightning (CLN), for
example, or LDK.

**Mike Schmidt**: All right.  Well thanks, Joost, for walking us through your
thought process there, and I think it's really valuable to have you on.  So,
thanks for hanging out.  I think we may need your help a bit later in the
newsletter, your Lightning expertise, so you're welcome to hang around for that.

**Joost Jager**: All right, I will.

_Monitoring of full-RBF replacements_

**Mike Schmidt**: Unfortunately, 0xB10C wasn't able to get to the point where he
can speak on the Spaces, but he's here listening.  He is the author of the
Bitcoin-Dev mailing list post that we're covering next, which is a monitoring
tool for full-RBF replacements.  Murch?

**Mark Erhardt**: Yeah, I've looked a little at this!

**Mike Schmidt**: He's mentioned that you may be familiar enough with the tool
to represent it.  Do you feel comfortable talking about that a bit?

**Mark Erhardt**: Yeah, sure.  So, as you all know, before we were talking about
SBF, we were talking about RBF.  And so, the big discussion was whether or not
the network will immediately move to full-RBF once this option is released in
24.01.  And one of the ways of finding out what's actually happening on the
network is by running a mempoolfullrbf=1 node and seeing which replacements the
node gets from the network, and whether those replacements or the originals then
are included in blocks.  So, we know that Peter Todd is offering full-RBF
replacement transactions on a network with substantial fees.  One of the two
OpenTimestamp servers that he is running has switched to making transactions
that do not signal replaceability, but sending replacements for those original
transactions in order to vie for block space.

So, 0xB10C has created a website that tracks when the node he is running sees
replacement transactions and whether or not the originals or the replacements
are put into blocks.  I've looked this morning a little bit at the website and
it looks like it very occasionally happens.  There was one ten hours ago, there
was a couple three days ago.  It looks like either one small mining pool has
enabled a mempoolfullrbf or they were, for example, when you restart a node, you
might not have heard about transaction announcements, and then it might look
like you are accepting a replacement because you only hear about the newer
version rather than the older original.  But so far, I think the tool has been
helpful in showing that it does not happen at large scale yet on the network.

**Mike Schmidt**: Question about discoverability, is there a way to figure out
if a peer is running mempoolfullrbf configuration option or not?  And if not,
how would the P2P network get to the point where these things would actually be
relayed, unless you knew that a certain node that you put on Twitter, or
whatever publicly, is accepting those sorts of replacements?

**Mark Erhardt**: That's an excellent question.  So no, we do not signal whether
or not your node is running mempoolfullrbf.  There is a patch, I believe, that
has been out since 2015, where I think Peter Todd either created it or is
maintaining it, that has a preferable attachment in the sense that nodes that
have this option will preferably find peers that also have it.  I don't think
that that is deployed widely, it's not released in Bitcoin Core.  So generally,
the network would only create paths to propagate the full-RBF replacements if
most full-RBF nodes have at least two peers.  If, in average, mempoolfullrbf
nodes see two other peers that also have mempoolfullrbf, then we would have a
pathway for transactions to be broadcast and reach miners.  That would generally
lead to a fully connected subnet.

I also see a message from 0xB10C where he mentions that he has seen multiple
blocks mined by Luxor, Luxor Mining, which did claim three bounties in total,
which may indicate that at least part of their mining operation runs
mempoolfullrbf.

**Mike Schmidt**: If I'm a mempoolfullrbf champion, I've downloaded the latest
Bitcoin Core and I toggled that default option to true and I start relaying
these replacements that aren't signaling the 125, are my non-mempoolfullrbf
peers going to punish me in some way for relaying those transactions?

**Mark Erhardt**: No, because they cannot know whether or not you saw the
original before it, unless you happen to also show the original.  And that's
also the only way without the patch to discover whether a peer of yours is
mempoolfullrbf.  If a peer offers you an original transaction and right later
offers you the replacement transaction, then you could surmise, of course,
especially if that happens multiple times, that that peer is running an
mempoolfullrbf.  Other than that, I don't think that you would be able to tell.

**Mike Schmidt**: So, there may be some interesting incentives then if this
miner Luxor is mining these transactions and accepting these transactions on the
network; is there then an incentive for node operators to connect directly to
their node?  And is that a bad thing for the Bitcoin Network for nodes to want
to be connecting directly to a certain miner to propagate their transactions?

**Mark Erhardt**: Yes, I think that if there were known miners that did full-RBF
and also advertised the service widely, and also told people how to submit
transactions to them directly, I think it would be detrimental if we had these
back channels to the miners directly.  The problem with that is we want mempools
to be as indicative of the next block that is going to be mined for better block
propagation and also for nodes to know what they can expect to see in the next
block.  So, for example, if a replacement is propagating on the network, we
would want nodes to be in the know about that; we wouldn't want them to continue
to think that the original is going to make it into a block, but rather learn as
soon as possible that the replacement is going to be accepted.

I think it's sort of a chicken-and-egg problem.  If the behavior happens on the
network, we want nodes to be able to run it in order to be in the know and
aware.  If it doesn't happen on the network, it might be better if everybody
doesn't do it, because then the few oddballs that do propagate mempoolfullrbf
would actually tell you a false impression and make you aware that there is a
replacement propagating, but that never gets included.  So it's sort of, well, I
don't know how it will play out yet!

**Mike Schmidt**: We'll see.  I wanted to just point out that in addition to the
tool that 0xB10C has put out there that we covered in the newsletter, there's
also just mempool.observer that provides a lot of interesting information and
statistics, as well as there's a Bitcoin transaction monitor subpage on that
site as well.  So, there's a variety of tools that 0xB10C has put out there and
thank you for creating those for the community.  So, I just wanted to point
folks to that as well.  Go ahead, Murch.

**Mark Erhardt**: One more comment, this is also from 0xB10C.  The page would
also be helpful for people that depend on zero-conf right now to monitor and see
what replacements are going on and when they should stop relying on it, because
they see that replacements are happening more often.  So in a way, the tool
itself is neutral in that it informs everyone about what's going on.

**Mike Schmidt**: I think we can move to the next segment of the newsletter,
which we actually have two of our monthly segments this week due to the
Year-in-Review being next week.  So, the first one is Changes to services and
client software, and we have four entries there.

_Lily Wallet adds coin selection_

The first one is about Lily Wallet adding coin selection.  So, among other
updates in their v1.2.0 release, there are manual coin selection features.  And
this is a desktop wallet that can facilitate multisig and hardware wallet usage.
And so, you can build your own 3-of-5, or whatever, multisig and you can use
hardware devices and things like that.  And this change adds manual coin
selection.  So, if for some reason, there's certain coins that you want to use
and not want to use certain UTXOs, you can have that manual coin selection.
Murch, I think you were looking at Lily Wallet, do you have comments?

**Mark Erhardt**: Yeah, with that tag I could of course not resist, and I looked
what they are actually doing.  So, it looks like they implemented coin control.
That's maybe a little bit of a pet peeve terminology-wise.  When you manually
select the inputs, I call that coin control.  And that's what it's called in
Bitcoin Core.  Coin selection, I would describe as the general methodologies of
doing automatic input selection for the benefit of the overall wallet health.
So they added both.  They added manual selection and I think there were some
changes to how the automatic coin selection works, although it looks to me like
it's largest-first selection, which I think overall is long-term going to build
up a pool of dust UTXOs.  So, I'm probably going to reach out to them!

**Mike Schmidt**: Okay, that's good.  I want to just confirm the terminology
there.  So, coin control is when I, as a user, am selecting particular UTXOs to
spend in a transaction; and coin selection would be a class of algorithms to do
coin selection for me.  Am I thinking about that right?

**Mark Erhardt**: That's how I use it at least, but I've seen a lot of people
refer to manual coin selection as coin selection too.  So I don't know, I guess
it'll emerge over time.

**Mike Schmidt**: Okay, well, let's move on to the next two changes, I guess.
Our guest, benthecarman, who we've kept on for almost an hour now, but can now
sort of maybe take the spotlight and describe each of these projects, maybe some
of the background of the project, and then what we've highlighted for the
newsletter.

_Vortex software creates LN channels from a coinjoin_

So the first one here is Vortex creating Lightning channels from a coinjoin.
So, Ben, talk about that a little bit.

**Ben Carman**: Yeah, if you want to invite Paul up too, he just joined the
listening queue because he helped on the other one, Mutiny.  But yeah, for
Vortex, it kind of originated where I run this service, OP_RETURN Bot, where
people can pay me a Lightning invoice and I'll do an OP_RETURN for them.  And
basically, I realized anyone can dox my wallet by just paying a dollar to do an
OP_RETURN, and do that a few times, they'll find all my UTXOs.  So, not the best
for privacy, so I thought it'd be cool if you could coinjoin on LND, and then
eventually went further into realizing it'd be really cool to open Lightning
channels in a coinjoin and I've been working on it as a side project for about a
year now.

We did our first mainnet one recently.  It works pretty well.  There's a few
bugs that we found, but nothing too hard to fix.  But over development as well,
I had a tweet thread the other day about it, saying it works on the coinjoin
aspect, the problem is that LND and CLN as well, they don't really provide you
with the best onchain privacy tools that you could have without having to create
a whole separate wallet.  So, that's kind of where Mutiny comes in, or might be
integrating Vortex straight into Mutiny, where we have full control of the
wallet because of things like LDK.

**Mike Schmidt**: So, is Vortex specifically for that use case, or is Vortex
more broad than just getting Lightning channels out of a coinjoin?

**Ben Carman**: The original intention was Lightning channels in a coinjoin, but
it's more than that now.  It's the only coinjoin implementation that supports
taproot right now and the idea is like, with taproot, you can eventually have
all use cases under taproot, where today if you open a Lightning channel or do
multisig or any sort of fancy thing on Bitcoin that's not just P2PK or P2PKH,
then you're kind of doxing what you're doing a little bit by having a different
address type.  So with Vortex, if we have taproot everything, then we can put
all these things in the coinjoin and they all look the same.  So, you're kind of
merging all these anonymity sets.

**Mark Erhardt**: So, could you clarify, is this a regular coinjoin operation of
which some people -- or, are you joining another coinjoin operation, you use one
output to open a channel, or does this tool require a bunch of people to get
together that all want to open channels that all then do a coinjoin to open
multiple channels?

**Ben Carman**: The latter there where you have a bunch of people queue up to
open a channel, and then after X number of minutes, once everyone's queued up,
then everyone will open a channel at the same time in one big transaction.

**Mike Schmidt**: I'm not sure that, if I understood, do I have to open a
channel, or can I just use this for coinjoining if I would like?

**Ben Carman**: You don't have to, yeah.  So right now, there's two different
pools, one's for opening channels and ones for just doing normal taproot
coinjoins, just because they're different output types so you could kind of
delineate what's going on.  But once we have taproot channels, then they should
be merged together, so you could have Lightning coinjoins and just normal
onchain coinjoins all in the same transaction.  Soon™, but yeah.  Right now,
there is support for just doing normal onchain coinjoins.

**Mike Schmidt**: Now, I had heard rumblings that this sort of project was
underway and then I saw that you had provided a tweet showing it in action, and
I thought it was just a rough proof of concept.  But it does seem like this is
something that people can use now.  Is this officially released; is this an
alpha; are you calling for people to use this on mainnet; or, what's the status?

**Ben Carman**: I wouldn't use it on mainnet yet, there's still a few bugs, and
it's not officially released.  I kind of did a tweet thread about why I haven't
really released it yet, mostly because I'm not sure that you can give actually
good privacy assurances with it.  Because the coinjoin part of it works well,
where you get all these equal amount of coinjoins and your stuff is hard to tell
who got which output.  But the problem is, any post-mix tools are really hard to
implement because we don't have full control over the wallet.  So, I could do a
bunch of coinjoins and then I just open up ThunderHub and open a channel in
there, and then it just merges all my coins that it shouldn't have and ruins my
privacy.

So, I think there's either one or two ways to do this, where either we create
and start maintaining a separate wallet on top of LND, or we have to make the
Vortex client feature parody of something like ThunderHub, and so then you can
have all those tools there without the privacy-watching aspect of it.  So, it's
still not totally ready, but I mean it's nearly there.  It's just the mainnet
proof of concept now is done, and we can start iterating on it more.

**Mike Schmidt**: Very cool.  Anything else that you guys would like to talk
about with Vortex before we move on to LN node in a browser?

**Ben Carman**: I don't think so.  I mean, we'll probably talk about it in there
as well because we have some plans for integrations, but yeah.

**Future Paul**: Can you explain the limitation around the coinjoining out of a
channel?  That's something I kind of learned from you in this process.

**Ben Carman**: Oh yeah, yeah.  So right now, we can open Lightning channels in
a coinjoin, but we can't close a Lightning channel in a coinjoin.  This isn't my
fault, it's the BOLT spec's fault, where today when you close a channel, you
just tell your peer, "Here's an address, let's close this channel", and they
say, "Okay, here's my address", and then the two Lightning nodes construct the
channel close; versus with the channel open, you kind of do this back-and-forth
flow where you say, "Here's a transaction, I'm going to open a channel to you".
So, in that transaction, you can build a custom coinjoin thing.  However, for
the closes, you can't, because you're just sending an address that you want to
close to.  So it's not really currently supported.

There are plans to kind of "fix this", with right now, Lisa and the CLN team
have been working on dual-funded channels for a while now.  And basically
they're going to use that same protocol to do channel closes.  Once we have
that, then we could construct fancy transactions to close the Lightning channel.
So we could have coinjoined Lightning channel closes, which would be really cool
with taproot, because once we have taproot channels, you can have it open in a
coinjoin, close in a coinjoin, and it'll look just like a normal onchain payment
or something.  So, it would be really enhancing the people's privacy in that
way.

_Mutiny demonstrates LN node in a browser PoC_

**Mike Schmidt**: Excellent.  Thanks, Ben and Paul.  Let's jump to Mutiny.
Maybe talk a little bit about what you're doing with Mutiny and then how this
proof of concept that we covered fits into that?

**Ben Carman**: Yeah, I mean Mutiny, it's kind of been a year-long project, not
really.  Me, Paul, and Tony Giorgio, who's not here, kind of had the idea of
building a privacy-first Lightning wallet about a year ago.  Tony and Paul built
pLN at the Bitcoin++ Hackathon here in Austin, and then kind of realized the
shortcomings of it with building on top of Sensei and a couple of things.  And
then Tony got censored by the Apple App Store, where they wouldn't let him make
an account because they said he was sanctioned.  So he said, "Screw it", and
there's one platform they can't censor wallets on, which is the web.

So, we tried to build a Lightning wallet in the web and as part of the bolt.fun
Hackathon, we did that and kind of released an alpha.  I wouldn't put money in
it yet, but it works for the most part.

**Future Paul**: The biggest privacy preserving thing that we've got so far, or
at least that was in pLN and we can definitely design Mutiny to be able to do,
is each channel can be a separate node logically, so you get some privacy best
practices just by not having multiple channels per node.  That's kind of the
hook, that's what we managed to build at the hackathon with pLN, and we can
definitely do that with Mutiny, although right now I think it's just one node.
But yeah, it is a whole node in the browser, that's kind of the accomplishment
here, is we have LDK and BDK and all of our logic in rust, and we compile that
to WebAssembly, so we get just a really great software stack, but it's in the
browser.

**Mike Schmidt**: What's the usability like?  I'm an end user.  I guess I could
be on a mobile as well as a desktop browser.  Walk me through, like, I'm
restarting my computer, or I close the tab, persistence and maybe a few things
like that and how a user would deal with that.

**Future Paul**: You've lost all your fonts!  Yeah, it's definitely very alpha
right now.  We have a lot of ideas and plans and that's kind of the next big
stage of what we need to look into for how this works across devices.  And
that's kind of hard to do in any -- I mean right now, in most notable mutations,
your database state is not very portable.  I think Phoenix has it so that you
can remove your node "across device" between different phones, but that's a
pretty manual process.  So ideally, we have some sort of syncing and some sort
of continual backup, but right now it's just in local storage, and it would be
just that one device is the node, and if you try to spin it up on your phone and
your desktop with the same key, you would be basically fighting yourself and end
up in a bad state.  So, that's going to be a big hurdle to figure out.

But we have some ideas and I think we can end up with a pretty cool solution.
But yeah, if you restart your computer, it just tries to reconnect to the peers
and it's fine.  Going offline is not a big problem in Lightning, but having
multiple devices that are managing this one state is kind of a problem in
Lightning, so we need to solve that.

**Ben Carman**: Yeah, I mean it's been kind of a cool learning process, because
when we were testing it on iPhone, the second you close, not even fully close,
but minimize the app, it stops all connections to outbound peers.  Whereas with
Android, we found you can totally lock your phone and it'll still keep the
connection open for ten minutes.  So, different environments we had to work with
there, but it is interesting where we found that you can literally still receive
payments while your phone's locked with Android, but with iOS it's a lot more
constrained there.

**Mike Schmidt**: All right, gentlemen.  Well, thanks for walking us through
those two projects, and you guys are doing some very interesting things.  Keep
up the good work.  Anything else you would like to say before we move on?

**Ben Carman**: Don't put your money in it yet.  You are going to get forced
closes and we don't know why yet; it is almost there.

**Mike Schmidt**: All right, cool.  You guys, Paul and Ben, you guys are welcome
to stay on if you'd like as we go through the rest of the newsletter.
Otherwise, we appreciate your time joining us today.

_Coinkite launches BinaryWatch.org_

Coinkite launched BinaryWatch.org.  So Coinkite actually has two sites that are
doing some work on binaries.  This one that we're talking about primarily for
this week is BinaryWatch.org, which is a website that looks at binaries from a
bunch of Bitcoin-related projects and looks for any changes that may occur in
those binaries that could signal some malicious activity going on with those
binaries.  So, that's the first site.  And then, there's another site that
Coinkite operates, which is bitcoinbinary.org and that's a separate service that
archives a bunch of reproducible builds.  So, for certain Bitcoin projects, you
can reproduce the build and they have an archive of all of those on that site.
And I think that site's actually been around for a year or two or more.  So,
cool projects from Coinkite helping the community.  Murch, any thoughts on those
two different services from Coinkite?

**Mark Erhardt**: A few weeks ago, I think we reported on another similar
project, and I think this is a little bit of a response to that because the
methodology is a bit different.  So, if you're interested in binary and -- or
sorry, in rebuildable -- okay, I don't know what I want to say, just move on!
Reproducible builds is what I meant.  Okay, if you're interested in reproducible
builds, there seems to be a discrepancy in what people think is reproducible and
what isn't.  And I think it essentially focuses around Google Play Store and, I
don't know, also maybe the App Store for iOS.  And you might want to look at
both sites, and I think the other one was WalletWatch, or what is it called?
WalletSecurity-something?

**Mike Schmidt**: Yeah, something like that, I don't recall.

**Ben Carman**: WalletScrutiny.

**Mark Erhardt**: Yeah, WalletScrutiny, thank you, Leo Wandersleb's project.
So, they seem to disagree on what is rebuildable or not.  So, if you're
interested in it, look at both.  That's what I wanted to say.

**Mike Schmidt**: Thanks, Murch.  The next monthly segment that we have for this
week's recap is the Stack Exchange, and we have five questions from there.

_Why is connecting to the Bitcoin network exclusively over Tor considered a bad practice?_

The first one is, "Why is connecting to the Bitcoin Network exclusively over Tor
considered a bad practice?" and this is maybe counterintuitive to folks who are
privacy-conscious and may be thinking, "Oh, I'll just only do Tor because Tor is
more private".  But while you may be able to get a bunch of Clearnet IP
addresses, doing that across different subnets is probably cost prohibitive
versus getting just a block and consecutive IP addresses.  With Tor, you can
generate addresses fairly easily and there's no rhyme or reason with those
addresses, you can't associate those as part of a different partition of the
network or not.

The whole point of all this is to say there's a type of attack, called eclipse
attack, where if I'm cut off from the rest of the network, potentially an
attacker could feed me bogus information, because they're the sole source of
potentially transactions and blocks if they're my only peer, and it just looks
like I'm connected to 20 different peers, but it's really the same person;
there's this type of attack called eclipse attack.  So, the networks that we're
talking about here, in terms of Tor and Clearnet, it's easier to spoof a bunch
of Tor addresses and try to eclipse attack somebody than it is to spoof a bunch
of IP6 or IP4 addresses that are in different subnets and then try to eclipse
attack somebody.  Murch, maybe you could help elaborate on how Bitcoin Core
handles IP addresses from different subnets or non-consecutive IP addresses, and
how that factors into this.  Are you familiar with how Bitcoin Core handles
that?

**Mark Erhardt**: Yeah, so Bitcoin Core learns about other peers by
announcements, and whenever a new peer is announced to Bitcoin Core, it checks
whether it already is tracking a node in that sort of section of its memory.
So, it does not have a single list of peers, but it has sort of slots that are
separated by different ASNs and different IP ranges.  So for example, if you
spun up 1,000 nodes on Amazon, you would only fall into the buckets that fall
into the Amazon ASN and IP ranges, and you could only displace nodes that are in
that range.  So, on Clearnet, basically in order to do a cyber attack or an
eclipse attack, you would have to spin up nodes in all possible IP ranges and
all possible ASN ranges, so you would have to get some nodes in Hetzner in
Germany, in Amazon in the US, in various other countries, and just getting all
of those IP addresses would be a challenge.

Since Bitcoin Core chooses peers from a variety of different network ranges, it
would be more resistant on Clearnet to this sort of attack.  While on Tor, the
goal is to make everybody look the same so you cannot tell where they are
sitting globally.  And that way, if you just spin up a shit ton of nodes, you
will actually have an easier time of filling up all connection slots of a peer.

_Why aren't 3 party (or more) channels realistically possible in Lightning today?_

**Mike Schmidt**: Excellent.  Thanks, Murch.  The next question from the Stack
Exchange is, "Why aren't three-party or more channels realistically possible in
Lightning today?  And Murch, I believe you answered this question, so I won't
try to paraphrase you, you can answer it yourself here.

**Mark Erhardt**: Right, so in the LN penalty update mechanism, whenever
somebody broadcasts a unilateral close that is outdated, they have already given
up on that state by providing a breach remedy to the other party.  So, the other
party can use that commitment to spend the whole outputs, all of the outputs
from that channel close and take all the money.  So this is called a justice
transaction usually.

The problem here is of course, if you have two peers in the channel, two channel
owners, one of them having already given up on the earlier state to the other,
it makes it a clear-cut thing.  If they still use that old state, the other one
gets to punish them and takes all the money.  And in a multiparty channel, this
is a lot harder, because if you had, say, Alice, Bob and Carol open a channel
together, and then Alice closes the channel, who of Bob and Carol gets to claim
the funds of the outdated close, right?  Does Bob just get all the money in the
channel?  Why is Carol punished now when Alice does something wrong?  If the
funds then go to Bob and Carol at the same time and they have to figure out how
to split it, how do you make sure that both of them get at least what they were
owning in the latest state?  So, do you have to update the punishment
transactions every time the channel state is updated?

So, what I'm essentially trying to say is, if you were trying to build up an
update mechanism that works for multi-party from an LN penalty, you would be
challenged by the asymmetry of the protocol to make it fair for the other
participants at all times and to make sure that each of them gets at least as
much money as they owned in the last state, and especially under the point of
view that you don't want to enable two of the channel owners to shortchange the
third.  So, you could also get into situations where, say, the other two parties
are collaborating, one of them closes unilaterally, the other claims all the
funds, and then pays out the big portion that will belong to the third
uninvolved party to the two attackers.

I think that just the penalty mechanism is built around the whole notion that
there is one other party in the channel and therefore it is clear-cut who should
get the damages rewarded; whereas, if you have multiparty, it becomes very
difficult.  You might have a lot of overhead by updating the closing
transactions for each channel update, you then need three parties to sign off on
everything, you have an asymmetry in three different states instead of in two
different viewpoints.  So, I don't think that this is going to be viable or
attractive until we get eltoo, which can have a symmetric state for the update
transactions.  Sorry, long rant!

**Mike Schmidt**: No, I think that was a good explanation.  So, it's possible,
but there's just a lot of complexity and overhead involved when compared to
something like eltoo?

**Mark Erhardt**: I'm not sure it is possible.  I don't think that anybody has
so far come up with a construction that shows that it is possible.
Theoretically, you could construct a protocol that updates everyone for every
single update mechanism with correct closing transactions for all the previous
states, but then you would also have to invalidate all the previous penalty
mechanisms for every single update, and I'm not sure if it is possible in a
reasonable manner at all.

_With legacy wallets deprecated, will Bitcoin Core be able to sign messages for an address?_

**Mike Schmidt**: Okay, that's fair.  Moving to the next question from the Stack
Exchange, the user asks, "With legacy wallets deprecated, will Bitcoin Core be
able to sign messages for an address?"  So, there's a few things here that
probably warrant some definition.  So, signing messages with an address, we can
sort of illustrate that.  For example, if you are an early miner and you want to
prove that you have the private keys to an address, you could sign a message,
for example, "Craig Wright is a fraud", and publish that message and folks can
see that you hold the keys to an address that received some bitcoins from ten
years ago.

The question on the stack exchange here is about the deprecation of legacy
wallets and the ability to sign those messages, and I think there's just a
little bit of a misconception between the meaning of deprecating legacy wallets
and the deprecation of legacy "addresses" like P2PKH.  So right now, you can
only sign messages with P2PKH addresses, and this user is confusing the
deprecation of legacy wallets with legacy "addresses".  Murch, perhaps you can
illustrate why Bitcoin Core is deprecating legacy wallets and what is the future
of wallets in Bitcoin Core?

**Mark Erhardt**: So, newer wallets now are based on descriptors.  A descriptor
is basically an updated take on extended pub keys (xpubs).  A descriptor,
additionally to an xpub, has also the derivation path, and it can hold more
complex output scripts.  So, for example, you can have many script-based
descriptors that have more complex conditions, or multisig setups defined, even
though your general wallet would previously have been only single-sig.  The
thing is, you can still have a descriptor for a P2PKH key set, and those would
still be able to sign, of course.

I think anybody that is interested in signing should also look at BIP322.  There
is an effort to generically implement signing for all output types.  I think
that for the amount of people that say that they miss the ability to sign
messages, that BIP certainly hasn't gotten enough attention.  So, maybe those
people that are super-interested in signing should look at the BIP that proposes
to do that.

_How do I set up a time-decay multisig?_

**Mike Schmidt**: Excellent.  Next question is, "How do I set up a time-decay
multisig?", and this user is asking about how to set up a multisig in which a
UTXO is spendable with a certain threshold, or a certain set of signers, let's
say, and then after a period of time, that set of signers changes and
potentially includes additional signers or a different quorum.  "Over time", is
the key there.  And Michael Folkson provided an answer which included an example
using the policy language and miniscript, and then he linked to some resources
about policy and miniscript.  He noted that, yes, this is possible, but there's
not a lot of user-friendly options currently.

Just as a slight addition to the detail there, policy is a language in which
humans can write spending conditions in a more human readable way, which sort of
compiles down into the lower-level language of miniscript, which is then itself
turned into Bitcoin script.  Murch, any thoughts on time-decaying multisigs?

**Mark Erhardt**: Yeah, I think that this covers it pretty well.  We can see on
the horizon how this is becoming more doable and useful, but for example,
Bitcoin Core itself only has watch-only support for miniscript so far.  I think
that the tooling for doing this sort of stuff is a little too far away to
actually recommend people to do that yet.  So, maybe on signet or testnet, but
certainly not mainnet yet, unless you know what you're doing and have figured it
out.

_When is a miniscript solution malleable?_

**Mike Schmidt**: And speaking of miniscripts, the last question from the Stack
Exchange this month is, "When is a miniscript solution malleable?"  Murch, when
is a miniscript solution malleable; and what does a malleable miniscript even
mean?

**Mark Erhardt**: I think the exact example of what we were looking at is maybe
a little too tough to suss out here in audio only.  But generally, the problem
is that we want to avoid any scripts that are third-party malleable.  So, if
another person that sees your transaction can change the binary representation
of the transaction and forward something else that still is valid to the
network, we can have some slight issues.  So, one of them is, of course, that
Lightning requires you to have a chain of unconfirmed transactions that build on
top of each other.  So, if one of those were malleated, the whole tail of the
transaction set would become invalid, because they build on something that
commits to a prior txid that might no longer be valid.

So, for Lightning, we removed the malleability in the signatures that could have
cause to change the txids, and something similar is happening here with the
miniscript stuff.  So, if you were to build a miniscript that has multiple ways
of how it can be valid, but a third party can change one script to another
script and still produce a valid representation of the transaction, you could
have multiple versions of the transaction propagate on the network, and nodes
might disagree on which one was in their mempool.  And when one of them then
gets included in a block, they would need to re-download the transaction from a
peer, or if you, for example, make the script bigger, it could fail the min
relay policy in that version, and people would say, "Oh, I don't need to get
that transaction any more, because I've already seen a representation of that
transaction and it didn't pass my min relay criteria".

So, this is the general background and context of the question and Antoine
Poinsot wrote a beautiful answer sussing out exactly why the specific script the
asker was inquiring about is malleable.  And if you're more interested in that,
if you look to write your own miniscripts and want to understand how that works,
I encourage you to read it, but I don't want to get into more details.

_Bitcoin Core 24.0.1_

**Mike Schmidt**: Moving on to Releases and release candidates, Bitcoin Core
24.0.1.  Murch, I think we've covered a lot of this in the release candidates
over the last month or so, and given our time constraint, I guess I'll defer to
you on how much you want to jump in to talking about this release or not.

**Mark Erhardt**: No, I think people should listen to our Spaces the last three
weeks if they want to hear more!

_libsecp256k1 0.2.0_

**Mike Schmidt**: Okay, sounds good.  The next release here is libsecp256k1
0.2.0, and essentially this is the first tagged release of libsecp.  And as a
reminder, libsecp is a C library for ECDSA signatures with a focus on Bitcoin.
I don't think there's anything we need to jump into there; do you, Murch?

**Mark Erhardt**: No, maybe just as a point, so libsecp has been used in Bitcoin
Core for a long time, but it was basically just picking whatever was in the
master branch, the latest commit, and released that as a dependency for Bitcoin
Core.  And now, we actually have a tagged release, so people are getting a
little more in the habit of pointing at specific releases for the pending
software.  So, I guess libsecp will become a little more mature in the release
process, but that's all.

_Core Lightning 22.11.1_

**Mike Schmidt**: Core Lightning 22.11.1 is just a minor release and in the
release notes they mentioned, "We reintroduced a number of deprecated features
since some integrations had missed the deprecation window and asked for some
more time to update their apps".  So, I don't think there's anything too crazy.

**Mark Erhardt**: Yeah, I think it was about the DNS names.  They changed how
nodes are referred to in the gossip and that broke some software.  So in
22.11.1, it's rolled back.

**Mike Schmidt**: This is the point in the recap where I solicit any questions
or comments from anybody on the Spaces who wants to speak.  You can request
speaker access, and after we complete the Notable code and documentation changes
section, we can get to those if you have questions or comments.

_Bitcoin Core #25934_

The first PR here is Bitcoin Core #25934, which adds an optional label argument
to the listsinceblock RPC.  And essentially the listsinceblock RPC gets all the
transactions that affect the wallet, which have occurred since a particular
block.  And so this PR adds a label argument, which is really just a filter for
transactions that fit that label, as opposed to returning all transactions that
are applicable to that wallet.  Murch, any thoughts on #25934?

**Mark Erhardt**: No.

_LND #7159_

**Mike Schmidt**: Saw the thumbs up.  A similar filtering PR here for LND #7159.
There are two different RPCs, ListInvoiceRequest and ListPaymentsRequest RPCs,
that now have creation_date_start and creation_date_end fields that can be used
to filter out those respective invoices and payments based on the creation time.
So, another filter change to the RPCs.

_LDK #1835_

All right, LDK #1835.  I think that since we have Joost on, even though this
isn't his PR or necessarily his project, he has a bit more familiarity with what
this PR does and how to explain it than Murch or I do.  So, Joost, if you're
still with us, do you want to maybe give a quick overview of what's being done
here in LDK?

**Joost Jager**: Yes, I can give that a try.  So, this PR is about the HTLC
interceptor API, which we spoke about also in the context of CircuitBreaker.
And generally speaking, this is a very useful API to have.  You can do
CircuitBreaker, but what is mentioned in this PR is that you can do zero-conf
channels, meaning that you intercept an HTLC bound for a channel that does not
yet exist, open it just in time, and then forward over the just-opened channel.
And another application of HTLC interception is creating those phantom payments
that are also mentioned here.  This is similar to what we also do, for example,
with Lightning Multiplexer, where you can have multiple nodes that all recognize
payments to the same destination key, allowing you to do a failover.

So generally speaking, this is a very useful API to have to get external
applications to intercept the HTLCs and change the course of action that is
taken by the nodes, based on a response that they give.  And as far as I
understand, just going from the description, this is what this does.  It adds a
way to signal that specific HTLCs need to be intercepted.  So, if those HTLCs
are bound for a channel in a specific range, a number range, they are offered to
an external interceptor; and if not, they are just processed without offering
them first.  And this is something that at least I recognize very much from LND,
because an LND HTLC interceptor API is intercepting everything.  So, that means
that even if you want to do a very particular thing, let's say you have a
virtual channel that you want to intercept traffic for, but all the regular
forwards of your routing node you don't want to touch, in LND that's currently
not possible because you would have to handle everything.

LDK solved this, at least that's what it appears to do by defining a specific
range for HTLCs to intercept.  And I guess, there's also other ways to solve
this.  For example, in LND, we have to think about explicitly specifying certain
identifiers that you want to intercept and the others not.  So, that's all a
little bit in the same area, making the HTLC interceptor API, which is very
usable already, even better by allowing more fine-tuned control over what is
being intercepted and what not.

**Mark Erhardt**: So the problem with something being intercepted would be that
it slows down the processing and forwarding, or…?

**Joost Jager**: Yeah, there's that, but it also depends on, like, that's
another parameter; what happens if the interceptor is not there?  Is the node
just forwarding everything at that point, or maybe is it failing everything if
there's no interceptor present?  Or a third option is, it's queuing everything,
because sometimes for some applications that's also necessary, that you want to
be sure that the interceptor sees everything that passes through the node, and
you want to just hold them in a queue.  So it can be very useful to filter the
HTLCs to which you want to apply these policies just to prevent issues if there
is downtime, for example.

**Mark Erhardt**: Super, thanks, yeah.

_BOLTs #1021_

**Mike Schmidt**: Thanks, Joost.  And fortunately, we have you on for this last
PR as well, which is BOLTs PR #1021, of which you are the author, so maybe I'll
let you explain it.  And I think we've covered some of this, but maybe if you
just want to give an overview of how this all ties together with what we've
discussed previously in fat errors.

**Joost Jager**: Yeah, so Lightning is interesting because it's not just a
payment system, but it's like a complete platform with a lot of extension
points.  For example, in the P2P messages, there's always like a TLV space at
the end of the message where you can put in arbitrary data.  So, if there's two
peers, they can agree on an extension to a specific message.  For example, if
they add an HTLC, let's say they can pay an unconditional fee.  This is
something that you could place in this TLV extension.  And the same is true for
the onion packets that the sender generates, like the onion packet that is
delivered at each hop can contain extensions in the form of TLV records to
signal specific data to a node that the rest of the network doesn't need to be
aware of.  This data is also relayed, so in gossip, if you have a gossip
message, such as a node announcement, you can extend that message with whatever
data you want and people relay this and store this.

So, that's a really cool thing because it allows for a lot of experimentation,
people trying out new stuff and they don't need everyone to cooperate to just
try it out.  There's only one area where this extension point was missing, and
this was in the failure message.  So, if you forward an HTLC and it stops
somewhere because there's no liquidity in the channel, or maybe if you reach the
final destination but something is wrong with the payment details, a failure is
returned all the way back to the sender.  So, the failure is encrypted for the
sender, the intermediate nodes just transform, basically obfuscate the failure
message all the way back so that there can be no correlation between the
different packages on its way back by an external observer.  And this was always
a fixed data packet, like a very rigid structure with a number of error codes.
And for every error code, there were a few predefined fields.

What this PR does is it allows these fixed messages that already exist, and
we're also not going to change them, with another TLV record, a set of TLV
records, so people can add their own custom data to the failure.  So, suppose
you would try to deposit into an exchange and your deposit is going to exceed
your account limits, or something like that, I'm just making this up right now,
the exchange could not just send you back an invalid payment details error
message, which is what you would normally do in this case, but accompany that by
a few other fields that show you, for example, okay, how much is left of your
limit; what is it that you can deposit still now?  So, that's one application of
what you can do with TLV extension.

Another application of that, I would say, is the inbound routing fees.  I'm not
sure if this has been covered in Optech before, I don't know, but with inbound
routing fees, what you want to do there, if there is a node that can't forward a
payment because the fee is insufficient, currently you're sending back a
payment, a channel update for the outgoing channel.  So, you send the most
up-to-date fee policy for the outgoing channel back to the sender so they can
try again for up-to-date fees.  And with inbound fees, you would add to that the
channel policy for the incoming channel as well, because not paying sufficient
fees might be because the inbound fee policy is not up to date or the outbound
fee policy is not up to date.  So, this could leverage this TLV extension to
include another fee policy for nodes who understand this.

So, generally speaking, this just increases the flexibility of the protocol
further and allows for even more experimentation than what was already possible.

**Mark Erhardt**: Is it a problem that the fat errors might substantially
increase the size of messages being passed around on the Lightning Network?
Could this increase the bandwidth used for running a Lightning node, for
example?

**Joost Jager**: Yeah, so the fat errors is actually something different.  The
fat errors, they add failure attribution information, we talked about that last
time.  And this is an additional block independent of the addition of the TLV
records.  So, those two things can happen both.  So, you could have a failure
with an extension block, TLV records, and then also signed over by all the nodes
on the way back, making it a fat error.  And the constraint is really the
message size in the Lightning protocols, 65 kB.  So fat errors, depending on how
we do it, are probably going to add something like between 2 kB and 12 kB.  So,
there's still a lot of space remaining for TLV records if you really want to
return that much data.

**Mark Erhardt**: Okay, sorry, I was mixing that up!

**Joost Jager**: Yeah, so these are two changes.  And this might be the case,
like we've been talking about this in the spec meeting last week, that we might
also combine the two.  Because in both cases, the sender needs to signal support
for these different formats for failures.  And to not get too many different
versions that are being signaled, it might be that those two are going to be
combined, so that you can do TLV failures and fat errors, and those capabilities
together make up a new format that the sender signals to the nodes on the route.

**Mike Schmidt**: Joost, thank you for hanging out and explaining these last two
PRs.  I think you did a much better job than I would.  So thank you for hanging
on for an hour-and-a-half.

**Joost Jager**: That's okay.

**Mike Schmidt**: And thank you to Ben for joining us as well, and Paul and the
attempt from 0xB10C to join us.  It was a chunky newsletter this week, and thank
you to my co-host, Murch, for joining as well.  Murch, any final parting words?

**Mark Erhardt**: Well, thank you for doing this experiment with me.  I think
we've been having a lot of fun with the newsletter.  And maybe if you're a
regular listener or a first-time listener, let us know what you think about the
audio recap, because we have a few weeks of break.  Or actually, we'll do the
annual recap next week, right?

**Mike Schmidt**: Yeah, special edition next week with yourself, myself, and Mr
Dave Harding.  So, that should be a fun one.

**Mark Erhardt**: Very cool.

**Mike Schmidt**: All right, thanks everybody.  Thanks for tuning in, thanks for
hanging out, thanks for the guest speakers, and see you next week.

{% include references.md %}
