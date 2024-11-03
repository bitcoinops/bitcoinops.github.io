---
title: 'Bitcoin Optech Newsletter #279 Recap Podcast'
permalink: /en/podcast/2023/11/30/
reference: /en/newsletters/2023/11/29/
name: 2023-11-30-recap
slug: 2023-11-30-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Lisa Neigut
and Bastien Teinturier to discuss [Newsletter #279]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-10-30/357884283-22050-1-11be98280172c.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #279 Recap on
Twitter Spaces.  Today, we're going to be talking about updates to the liquidity
ads specification; we have six questions from the Bitcoin Stack Exchange that we
highlighted; and then we have our normal Releases and release candidates and
Notable code changes to go over.  I'm Mike Schmidt, I'm a contributor at Bitcoin
Optech and Executive Director at Brink, funding Bitcoin open-source developers.
Murch?

**Mark Erhardt**: Hi, I'm Murch and I'm back from vacation.

**Mike Schmidt**: We have two LN experts in the space this week.  Lisa.

**Lisa Neigut**: Hey, I'm Lisa, also known as niftynei, a longtime contributor
to the Core Lightning (CLN) project and author of the original liquidity ad
specification.

**Mike Schmidt**: Bastien?

**Bastien Teinturier**: Hi, I'm Bastien, I've been working at ACINQ on the LN
specification and Eclair, and implementing and thinking about liquidity ads for
a while as well.

_Update to the liquidity ads specification_

**Mike Schmidt**: We'll jump into the newsletter and talk about some of the
liquidity ad specification discussion.  Liquidity ads are a set of proposed
changes, I think initially in the middle of 2021, to the BOLT specs that allow
peers to signal fees that they would charge for committing liquidity to a
dual-funded channel.  Lisa, how would you add to that definition; and then maybe
also explain the use case a bit for the audience of why we would want such a
thing?

**Lisa Neigut**: Yeah, I think that's a great way to summarize it.  I think the
reason why you would want something like this, so one of the general problems
that an LN Node has when it joins the network is, that if it wants to receive
payments, it needs to convince another node on the network to take Bitcoin that
it owns and set it into an account for its own personal use.  So, you sort of
need to figure out one who has bitcoin that they could put in an account that I
could use so that I could then receive payments over LN.  You need to figure out
who's able to do that, and then typically the way that this has worked up until
today would be kind of informally through friend networks, or you'd hop on to a
website and make like rings of fire, I think they called them, to all open a
channel to each other so you all can receive a payment from each other.

Or the general idea was like, okay, what if this has the looks of a market
problem?  Some people need to receive payments, other people have bitcoins that
they want to make available for others so that they can receive payments.  What
if we use the existing LN protocol to build a decentralized bulletin board
system that would let people negotiate in a P2P manner; so, there's no central
marketplace, all the negotiations about the buys and sells of inbound liquidity
could happen directly between two LN nodes, so what would we need to make that
happen?  What kind of signaling would we want to have so you would know who to
go talk to?  So, it really takes some ability that we added with the dual-funded
channels and makes it such that you can now use that to actually sell or buy
liquidity if you're a node.  That was a long explanation.  Anyways...

**Mike Schmidt**: No, that's great.  And this is specific to dual-funding, so
this isn't a marketplace for people to open channels to me, but to join in on a
dual-funded channel.

**Lisa Neigut**: Yeah, exactly.  And so, the way I like characterizing it or how
these two things kind of build on each other is, dual-funding made it possible
that, you know, channels are two sided objects, you've two parties on one side;
the v1 of LN channel opens, only one side had an opportunity really to put funds
in the channel at start, and then the other side would just be like, "Okay,
cool, you're going to open up a channel and I'll be able to receive your money,
that's great".  Dual-funding changed that, so the v2 of LN opens lets both sides
put money into a channel at start, so that's new and exciting.  But then you run
into a problem if you're on the side of someone who's like, "Hey, I want to open
a channel with you".  It's deciding whether or not when that other person opens
a channel, whether or not you want to put money in it.

So, liquidity ads, the way I think about it, also a coordination kind of
mechanism, right?  It's a way that you can coordinate like, "Hey, I want to open
a channel, you should also put some funds in it".  And the way that you
coordinate is like, "Hey, I'm opening a channel, I'll pay you some money to put
some funds in it".  So, yeah, they go together, they build on top of each other.
You can't really do liquidity ads without that dual-funding, that ability to
basically negotiate a bitcoin transaction with two parties, because we use that
as basically our contract for opening it, and you get a signature from both
sides on that opening transaction, and that kind of serves as your signatures on
the contract of who's paying how much for the inbound.  It's cool because you
can see that the other party has actually put the money they said that they
would into the channel open contracts.  If you think of it as a funding
transaction now as a contract between two parties that becomes real and live as
soon as you get both parties' signature on it, all of a sudden you can set up
cool, new relationships where both parties are able to bring money to the table,
and you can basically negotiate the terms of that new opening funding
transaction because we're using the v2 opens, which we've been calling
"dual-funding".

**Mike Schmidt**: And so, some of this discussion or some of the negotiation for
doing this previously, you mentioned, was just outside of the LN, whether that's
me signal messaging somebody and encouraging them and providing my reputation in
some way.  But the proposal is to move that mechanism to being gossiped within
the LN, you're providing some information there, which is basically
pricing-related or fee-related information, but it's still on the node operator
to vet any non-fee-related things, like reputation of the node or things like
that; is that right?

**Lisa Neigut**: Exactly, yeah.  So, you're still operating in a marketplace,
there might be people that buying from wouldn't be very beneficial to you, maybe
they don't have any other channels, and so buying their liquidity inbound would
be great only if you want to get a payment from them.  So, yeah, I think there's
definitely other things you'd want to consider when you're looking at all the
candidates, the people that you can buy inbound liquidity from, for sure.  The
protocol itself, we don't really deal with that in a protocol.  The protocol is
mostly about, "Okay, I've already decided that I want to make this trade, so who
can I make the trade to?"  So, it helps you identify people to consider with
other heuristics, like how much inbound liquidity they have or other channels
they've opened or how long they've been on, etc.  So, it provides you with a set
to start with that extra filtering around who your partners are.  And then once
you've decided who that you think you would like to at least attempt to open a
channel, maybe go into the negotiations with them, so to speak, it's how does
that negotiation happen.

**Mike Schmidt**: And you've had a PR open for some time, and I believe CLN has
implemented the original proposal.  What's the impetus for your mailing list
posts and these changes to the proposal?

**Lisa Neigut**: Yeah, great question.  So, our initial draft went out, I want
to say in 2021.  It's been up on CLN.  I think LN-Router has the marketplace
where you can see all the CLN nodes that are advertising, and I think there's
about like 12 to 15 nodes on any given day that are basically participating in
that market.  So, the impetus of the change from the first version is first,
there's a couple of things that I put in the first version that I'm unhappy
with, so I wanted to make some changes in that place.  The second reason that
I'm spending more time on it now than I have in the last few years is, we're
getting really close to getting that initial v2 channel open dual-funding
protocol into the spec, so that really provides us with an opportunity like,
"Okay, dual-funding is here".  We've spent a lot of time, especially Bastien in
particular has been a huge champion of this v2 opens, the dual-funding stuff,
and splicing, etc.

So, because of all the time, energy, and effort that he and his team have
dedicated to that proposal, we're basically now at the point where dual-funding
is done, that's almost in the bag, we're really hoping we'll have that merged
into specs soon.  That means that all these new proposals being built on that
original spec proposal, like splicing builds on it, the liquidity ad proposal
builds on it, it's like okay, let's get back to these other proposals now that
the foundational layer that we needed is looking like it's really solid.  Okay,
what's next?  Let's get liquidity ads updated to a point where I'm happy with
it, Bastien's looked at it and is happy with it, the larger LN community has
looked at it and weighed in on what they think are important things to consider
or add or how to change how that protocol works.  So, yeah, the impetus is
basically dual-funding's almost here and almost done, and we're ready to move on
to the next things that that unlocks for us.

**Mike Schmidt**: Go ahead, Bastien.

**Bastien Teinturier**: And another impetus is the high fees because one of the
great, great benefits of liquidity ads for one example, one scenario for mobile
users, is that they can buy inbound liquidity in advance when the fees are not
too high so that when the fees get high like they do today, they already have
inbound liquidity and don't have to make any onchain transactions to be able to
receive more funds, stack or send out.  And since many users have been beaten by
that, trying to stack money and having to make some spliced transactions all the
time in a high-fee environment, they really want the opportunity to be able to
prepare ahead and buy liquidity when o-chain fees are cheap, so that they don't
waste too much money on onchain fees later.

**Mike Schmidt**: That makes sense.  And am I correct in understanding that in
addition to your work, Bastien, on the dual funding proposal, that you and the
team at Eclair are also looking at integrating liquidity ads into ACINQ?

**Bastien Teinturier**: Yeah, actually I had a draft PR for liquidity ads and a
draft branch in Eclair that has been up for, I'm not sure how long, but at least
a year, maybe two.  And I've updated it recently to match the latest spec.  And
I now have a branch both on the Eclair side and on the Phoenix side to have both
the seller and buyer code, which is not fully spec-compliant yet, because we
were still discussing a lot of details with Lisa on things that should maybe
change in the spec.  But that's a good opportunity to experiment, to prototype,
to have real users play with the feature and see what works and what doesn't, to
make sure that we come up with a spec that works for as many scenarios as we can
think of.

**Mike Schmidt**: Maybe we can get into it a bit.  So, what does need to be
changed?  Lisa, you mentioned you had your own opinions on things you didn't
like about your initial draft.  We talked about dual-funding getting close;
okay, so that was sort of the impetus.  We talked about the high fees as another
motivation.  So, maybe pick a few of the most impactful potential changes to the
spec that are being discussed.

**Lisa Neigut**: Yeah, so I think the one that Bastian and I are still trying to
figure out where we land on is this idea of having a lease.  So right now, the
way that the spec is written -- if you have a lease, how does that get enforced
in the contracts, and the contracts being these bitcoin transactions that you
have about a channel, right?  So, the current proposal, we're like, okay, every
single lease that you buy has a fixed duration.  That duration is 4,032 blocks;
that's roughly about a month.  So, the way that we've enforced that duration of
the lease is that on the seller's money in the channel, we put basically what
amounts to a timelock on it, and if that channel closes before the lock is over,
then the seller's funds aren't really -- basically that liquidity becomes locked
up and unusable to them.

We do this as an incentive for them to keep the channel open as much as possible
and keep that liquidity available to the person who's bought it, because if they
keep it up and available, there's always a possibility they could earn routing
fees on that liquidity.  They go to chain, it's just going to sit there until
the end of the lease anyway, so there's no incentive for a seller to sell you,
let's say, a million-sat channel, and then ten blocks later, decide to splice it
out of the channel into a new channel where someone is paying them for a million
sats.  The point of the duration -- I think, yeah, Bastien's raising his hand.
He has, I think, some really good points though about some of the downsides of
locking your funds up into a duration.  So, I'm going to kick it over to Bastien
to chime in here.

**Bastien Teinturier**: Yeah, one issue for example with that is that it looks
like it works, but actually you can enter into a cat-and-mouse game where each
side tries to blackmail the other, because for example you buy liquidity from me
for a month so that I cannot take that liquidity out.  So, if I want to splice
it out, you should just reject that splice-out attempt.  But if you want to
splice-in some funds and take the opportunity of your splice-in to try to add
outputs on my side to splice things out, then either you accept it and I just
took funds out disregarding the lease, or you reject it but then I'm preventing
you from splicing-in funds into the channel.  So, both sides can harm the other
side and try to work around basically the lease duration.

The main issue I have with the lease duration is that it protects the buyer, but
it creates issues on the seller side.  Because if, for example, you have a
channel where the buyer of liquidity initially has all the money on their side,
for example 1 bitcoin, and wants to buy a very small amount of inbound liquidity
for one month, they're going to pay a very small fee because they're buying a
small amount.  But then using LN, they push all of the liquidity on the other
side of the channel, which means that the seller has moved some of their
outbound liquidity in other channels to their own counterparties.  So, now the
seller has a large amount of liquidity in that channel that is locked for a
whole month, but the buyer only paid for a very small amount of money.  So, then
you can enter into a blackmail game where the buyer can say, "Okay, I'm going to
let you get your funds back, but only if you pay me a fee".  And I think that
can be exploited to grief all the sellers, and I think this is an issue, so I'm
not sure yet what we should do.

I think that what we discussed recently with Lisa is to make that lease duration
optional, so some people, if as a seller you are afraid of being griefed by
that, you don't offer lease duration at all, you don't really lock your output
and the buyer only relies on incentives from you not to cheat.  And if you are
not a reputable seller, then you're going to offer that guarantee to buyers, but
you are taking a risk that the buyers lock your liquidity, lock more liquidity
than they have paid for, for a potentially long duration.  So, there's a
trade-off here that is hard to navigate.  And I plan on making a mailing link
post to see how people think about this issue and if people have ideas on how we
could work around this.  But I think this is really hard, because protecting the
buyer means giving them a griefing opportunity on the seller.

**Mark Erhardt**: Would it work to -- sorry, you go ahead.

**Lisa Neigut**: Yeah, I was going to say, this is where Bastien and I were
talking earlier is, I was trying to make the point that this is why I think a
marketplace is a good thing and having different options for different cases is
maybe the best we can do as a protocol designer, where sellers that are worried
about the duration risk, being they get their money locked up and they're unable
to reuse it otherwise, one, either they should price it -- well, splicing I
think added some new wrinkles to this which didn't really exist before, because
you used to have to completely close the channel.  Splicing offers new
opportunities which I think the interaction with liquidity ads is something that
we're still working through.  So, I think that's definitely a really important
thing that Bastien has raised for us to consider.

But one thing about it is, really when you're pricing -- so, the original
proposal for liquidity ads, we were asking you, we were saying, "Hey, there's
one duration, it's about a month of this contract.  So, when you're pricing it,
think in terms of what you want as a node who's selling that liquidity, what
would it take for you to lock up funds, guarantee that these funds might be
locked up for a month, no guarantee they get used, what would you price that
at?"  Now we're saying, "Hey, this duration is variable, so your node probably
needs to have a way of repricing the liquidity based on the duration that the
person who's buying it requests".  Maybe they request a zero lease, which is
what Bastien thinks is maybe the best for big sellers who are worried about a
node that wants to just lock their liquidity up into these contracts, and then
they can't really move it around because they get stuck.  Suddenly you end up in
this kind of interesting price curve, almost like the US Treasuries, so to
speak, right?  You know, you lock your money up in a 30-year, you're supposed to
get paid more than if you lock it up in a 10-year, etc.

So, yeah, this question of duration is, again, from the seller perspective, it's
a risk on their side that their funds might actually get locked for that
duration.  And as Bastien is explaining, now with splicing, there's an
opportunity that maybe a malicious buyer on the other side, channel
counterparty, would decide that for whatever reason, they really wanted to make
as much of your liquidity as possible locked into this contract.  So, they do
some things with adding more funds than the original lease and use the onchain
stuff that we've got in the protocol to keep the funds from being able to be
moved elsewhere.  Yeah, but anyways, so these are the things that we're kind of
rethinking through.  And that big one, I think the biggest difference one is,
the duration in the original proposal was fixed and known, and this new proposal
we're like, "Okay, do we even need a duration?"  If we need a duration, maybe we
should make it a flexible variable number.

This makes the marketplace a little harder to figure out, because now all of a
sudden you would assume different rates for different durations.  The old
protocol, it was a fixed rate, everyone advertised rates for the same duration,
the market was uniform.  Now it's like, okay, duration is up in the air, maybe
it's negotiable, maybe there's no duration.  And so we're trying to figure out,
okay, how do we help people figure out how to price that; what kind of protocol
do we need?  Suddenly there's like a little bit of variability in it, that sort
of thing.

**Mike Schmidt**: We have a speaker request from Chris.  Chris, you have a
question or comment?

**Chris Guida**: Yeah, hey guys.  I was basically just going to say what Lisa
said.  Basically, my thinking was that the initial lease fee would basically
contain all the information as to the risk to the seller.  So, if they have to
put their liquidity in for three months, presumably that would be a much higher
initial lease fee than just a week or something.

**Bastien Teinturier**: Yeah, but the issue with that is that the seller does
not know how much capacity is going to end up being locked.  Because you sell,
the buyer buys from you three months of 10,000 sats and you take a proportional
fee on those 10,000 sats.  But then by splicing-in and moving funds to your side
using LN, you end up locking, for example, 1 bitcoin or 2 bitcoin for three
months, and you cannot price that in beforehand because you --

**Mike Schmidt**: T-bast, I think you've cut out.

**Mark Erhardt**: Oh, I thought it was my desktop here.

**Lisa Neigut**: No, so really I think what Bastien is focusing on, and I think
it's worth thinking about, really has to do I think with, you know, LN liquidity
is liquid, which is kind of cool.  I could have a balance of, let's say, 5
million bitcoin in a channel, my peer has a whole bitcoin, they've bought that 5
million, right?  But then I have on my other channels more balances that I'm
able to push out to the other side.  I think what Bastien's worried about is
that your channel peer is going to buy some liquidity from you at a low rate and
then push their side of the channel over to you, which then pushes out the
liquidity all of your other channels.  So, I think you are going to get paid for
that movement of funds, whatever you're charging in a channel fee to move it.

But the downside then is that until or unless those payments get pushed back to
the other side of the channel, now you have bitcoin which maybe in those other
channels was unencumbered and didn't have a duration lock on it.  Now you've
basically exchanged that unencumbered bitcoin for this encumbered bitcoin that's
under this lease duration and basically I think the point is, there was no point
at which you were compensated minus those channel fees, which presumably you're
charging at whatever the routing market rate is, and doesn't include maybe an
extra benefit of now basically moving those funds from unencumbered channels
into holding that balance in an encumbered UTXO, which I think is valid.

Some of the things we've considered is, maybe there's a way we could change the
way that the duration is held in that channel contract with the original buyer
of the liquidity lease, such that now there's two UTXOs, one of them is
encumbered, an encumbered one is never more than the amount of the lease.  But
then, Bastien was making some, I think, very, very good valid points that when
you start adding that kind of construction, you end up with questions of like,
"Well, we offered this Hash Time Locked Contract (HTLC) to our peer, but it got
bailed back.  Which of these two buckets do we put it into?" etc.  So, yeah, I
think we've still got, in terms of protocol design space, a few more things to
figure out exactly around this duration question.  So, I think, yeah, this is a
great forum to bring these questions up.  So, Mike, thanks for having us on and,
Bastien, thanks for joining and bringing up all these great issues.

Then, I think the mailing list, hopefully I think Bastien said he's going to do
a good writeup of this for the mailing list so we can get it out there.  I don't
know if Bastien's back or not.  Maybe he can talk us through, like I think
Bastien's proposal was we just get rid of duration and so you no longer pay for
duration.  The downside for that is if you're a buyer, you no longer really have
an option to get a guarantee that you pay one basis point for a million sats in
your channel, and then now with splicing, someone could splice that money out
immediately, the next block basically, to another channel, where someone's now
paying them another basis point for those funds, so you had access to them for
maybe a block before it got reallocated away.  Again, this is kind of where I
think one of the nice things about it being an open marketplace and different
nodes, and being able to have a pricing curve around duration is, maybe as a
buyer you would see ACINQ's offering a zero-duration lease for a cheaper price
than maybe another node that you don't know as well, who will give you a
thousand-block duration on that on that liquidity as a guarantee, but they're
going to charge you a little more for it.

**Mark Erhardt**: Could you clarify something?  You only pay a lease on the
amount that the counterparty provides, right?  There's no contribution to the
lease price based on the total capacity of the channel; is that right?

**Lisa Neigut**: That's right, yeah.  So currently, the way that the protocol is
organized is that you, as the buyer, pay for the counterparty's funds that they
initially contribute, or at the time that you're -- we're talking about adding
this protocol to splicing, so you'd be able to use a splice to ask your peer to
basically put more funds in the channel.  So, at whatever point you're doing
this liquidity, it would be for whatever capital the person that's selling it is
adding to the channel; that's right.  Another thing about the protocol that I
think -- oh, go ahead.

**Mark Erhardt**: So, follow-up question maybe.  Doesn't that mean that the
original liquidity ad is sort of mispriced because it doesn't cater to how much
the buyer wants to add?  And so, what t-bast said with, if you splice-in more
funds you might have a higher risk as the liquidity ad provider because now more
funds on your side could be locked up for the duration, but don't you already
have that based on who might take your offer in the market in the first place,
because if someone with a small amount takes it or someone with a huge amount
takes it, you have completely different outcomes?

**Lisa Neigut**: I think, yes, I think that's true.  I think the general
understanding of the protocol has been that the reason someone is paying you for
that in the first place is that they want to receive it on their side.  So, I
would expect in general, most liquidity ad buys would be fairly one-sided, but I
might be wrong about that.  Maybe you're paying someone so you can get a balance
channel, so the channel opens with balance and you've paid them for their half
of the liquidity.  So in that case, yeah, there's this risk, so to speak, that
2X of your original capital, depending on how the flows go, might end up
basically encumbered under the duration.

**Mark Erhardt**: Okay.

**Lisa Neigut**: Bastien had his hand up.

**Mark Erhardt**: Oh yeah, sorry, I can't see that!

**Bastien Teinturier**: Yeah, so I think that the really interesting thing is
that, as Lisa said, since balance in LN channels is liquid, what you buy when
you buy a liquidity ad is quite subtle, basically.  If there's no lease
duration, no CHECKLOCKTIMEVERIFY (CLTV) that are being added, then you only buy
the fact that the other side, at this exact moment, is going to be adding that
amount to the channel, and then you don't know what happens to that amount
later.  If you add a CLTV, what you are buying is that the seller is going to
add right now some amount, and then for the duration of a channel, they won't be
able to take any of their balance out of a channel.  But that balance could be
anything between the amount that they're adding now and the whole channel
capacity, and the channel capacity in itself is something that can change due to
splices.  So, it's a bit fuzzy what exactly you are buying.

From the buyer side, the case where there's a CLTV is really great because you
are actually buying more than what you think you are buying.  But from the
seller side, it's a bit dangerous because you don't know exactly how much you're
selling.  Does that make sense?

**Mark Erhardt**: Yes.

**Lisa Neigut**: Yeah, it totally makes sense.  Oh, I'm sorry.  I think, yeah, I
think Murch brings up an interesting point.  Maybe there's a way we could add a
residual cost or an additional pricing on the total balance of the channel, so
there's some way that the total balance gets kind of priced into the liquidity
buy.  So, it's not just the funds that the person's putting up, but some risk
factor of the total balance maybe being put under that duration that would be
added as a cost to the buyer, is a thought of one way of approaching this
particular risk.  So, that would mean that the seller of liquidity would be
compensated for the additional risk of a total balance of funds being basically
committed to that duration.

**Mark Erhardt**: Yes, and if you have that concept already, you could also
reprice the lease at the moment that someone wants to splice-in more funds,
because now they're changing the capacity and the capacity is already part of
the pricing model.  But yeah, you get a multidimensional lease cost now.

**Bastien Teinturier**: Yeah, exactly.  It's really hard to constantly repay
fees whenever a splice happens, because there are even cases where the splice
makes it so that you don't even have enough funds to keep paying the fee.  Or it
creates an explosion of cases where I'm pretty sure there's going to be edge
cases that just don't work if we start doing that, because repricing and
repaying a fee every time you do a splice sounds a bit dangerous.  Especially,
for example, if you're splicing-out, then should you get back some of the fees
that you paid before?

**Lisa Neigut**: Yeah, these are all great questions about contract setting.  I
think this is why the original version of liquidity ads, we had one duration and
splicing didn't exist.  And so it was like, okay, that contract is a little
easier to negotiate.  It still has this risk I think, that Bastien pointed out,
of the funds on the other side of the channel moving into it.  But overall, it
was a little bit of a simpler landscape to navigate.  I think now, we've
definitely got a lot more -- we're trying to make the protocol as flexible and
be as useful as possible for as many use cases as possible.  And there's
definitely, I think, some edge cases where we end up in places where, I wouldn't
call it undefined behavior, but you start running into cases where it's like,
okay, this isn't simple to navigate anymore in terms of a contract, and I think
that's difficult.

I think this is one of the things that we're working on as protocol designers
and why we're having these conversations, is because we do get to bring up
things like, "Oh no, there's all these edge cases, how do we how do we figure
this out?"  And then, yeah, the greater question is like, I think I think in
general liquidity ads are a good idea.  That good idea is like, "Okay, I have
liquidity I want to sell and someone out there is probably willing to pay me for
it".  The details that we're getting, it's going to take some time, I think, for
us to figure out.  Like Bastien was saying, being able to experiment and try out
different things is probably a good place, and I think that's really where we're
at with the protocol.  But to figure out how do all these different -- because
now we're really talking about, what are you buying; what's that worth; what are
you willing to pay for it?  And those are all more economic questions that I
think sometimes there aren't really exactly straightforward answers to.  Okay, I
think Chris has his hand up.

**Chris Guida**: Hey, yeah, just one thing to clarify.  When you guys talk about
splicing from a channel lease, that's after the original timelock expires,
right, because if you tried to splice before the timelock expires, then that
just wouldn't be spendable, right?

**Bastien Teinturier**: No, you could, it depends.  We can just choose that.
But the issue is that if you are inside the lease and the seller's main output
has a CLTV, if a seller tries to splice-out, then obviously the buyer should
reject the splice-out.  But then the seller can also reject all the splicing and
splice-outs that the buyer tries to do.  So, do you want to allow something?
And if you want to allow, for example, because it would make sense to allow the
buyer to splice some funds out because the buyer has not sold liquidity, so the
buyer should be able to splice-in and splice-out.  But if we use dynamic fees
depending on the channel capacity, what happens then when the buyer changes the
capacity of a channel, especially if they reduce the capacity of a channel;
should they get some of the fees they paid before back?  It becomes hard, I'm
not sure what to do here.

**Lisa Neigut**: Sometimes when I think things are getting complicated, I find
it useful to go back to the original design goal, right?  So, I think Bastien
said it really well at the beginning, what you want is you want people who want
to receive payments over LN, give them an opportunity to secure that capacity to
receive a payment in LN ahead of maybe when they need it.  So, maybe there's a
low-fee environment, you want to know maybe -- I tend to think from the vendor
use case on LN, like I've got a little shop, or I'm an Amazon, and I'm going to
be making sales over LN; I am going to have a constant need for inbound
liquidity, basically the ability to receive payments over LN.  And it's
worthwhile for me to basically pay upfront to ensure that ability to get
payments.

So, as a protocol, what we want to do is we want to enable people who know that
they're going to need, or have an expectation of receiving payments over LN, the
ability to basically for a price, get that ability, have that ability and have
that assurance and they're willing to pay for it.  So ideally, that inbound, you
start looking at it, it's like, okay, well, they're only paying for so many
sats, and generally they probably want an assurance that they're going to be
able to receive that much in LN for a time period.  As a buyer, you're probably
going to want an assurance that you're able to receive a million stats over like
the next week, and that's what that's what you're paying for.  So when you start
getting it, it's like, okay, how can we design a protocol where that desire to
be able to receive a million sats over an LN channel is something that we can
guarantee?  We're not guaranteeing that they're able to receive it and then send
it back and then receive it again, it's like a first time receipt.  So, maybe
there's a way that we could redesign the contract such that they have that
million stats available, I don't know.

All these edge cases of like the money's gotten pushed back and now it's gotten
bigger, etc, is really a result of the initial design that we came up with of
how to, as much as possible, guarantee that that seller is going to leave that
million sats available for them.  Yeah, so maybe there are some other ways we
could structure these in-channel, onchain, bitcoin transaction output contracts
that are able to more nuancedly, I think, express that, because it's not a
design goal that they're able to push back a bitcoin, and suddenly the seller
has a bitcoin that's been encumbered, right, that's not something that we're
trying to design for.

**Mike Schmidt**: It sounds like there's still some discussion that's going on
here for sure.  So, if folks are listening or reading the transcript of this
discussion, obviously if you feel like you want to contribute to that
discussion, it sounds like that feedback would be valuable from the proposal
authors.  So, feel free to jump into either the PR, I guess, or the mailing list
to provide your feedback.  Lisa or Bastien, any other calls to action or parting
words?

**Bastien Teinturier**: No.  Just stay tuned for more changes and more feedback
on the mailing list.

**Lisa Neigut**: Yeah, I think Bastien said he's going to, and correct me if I'm
wrong, is going to have a new update summarizing a lot of his discussion and
some of the downsides he's come up with, with the most recent protocol design
that I've put out.  So, I think that would probably be the best thing to respond
to once that gets out, unless I'm wrong about that, Bastien.

**Bastien Teinturier**: Yeah, exactly.

**Mike Schmidt**: Well, thank you both for joining.  You're welcome to stay on
to talk about the Bitcoin Stack Exchange questions and PRs this week, but if
you're busy, you're free to drop as well, we understand.  Next segment from the
newsletter is selected Q&A from the Bitcoin Stack Exchange.  I'm going to
re-invite Murch since she left, so one second.  Okay, Murch, you should have
been invited.  So, the Stack Exchange Q&A is a monthly segment that we do, where
we go through the Bitcoin Stack Exchange and find interesting questions and
answers and try to highlight them for the community here.  We have six this
month.

_Is the Schnorr digital signature scheme a multisignature interactive scheme, and also not an aggregated non-interactive scheme?_

The first one is, "Is the Schnorr digital signature scheme a multisignature
interactive scheme, and also not an aggregated non-interactive scheme?  So,
there's quite a few things going on here.  Each of these could probably have its
own Twitter Space about, but sipa, Pieter Wuille, described the differences
between some of these terms, including what is key aggregation, what is
signature aggregation, what is multisignature, and what is this thing in Bitcoin
that we call multisig.  And then he also, based on the definitions of those
terms, jumped into a bunch of related schemes that are applicable in Bitcoin,
including schnorr signatures as defined in BIP340, MuSig2, Frost, and I don't
think this one is actually applicable to Bitcoin, but the Bellare--Neven 2006
scheme.  I don't know, Murch, how much you want to dig into any of those, or if
that's an exercise for the listener.  What do you think?

**Mark Erhardt**: Maybe more meta.  We've had a very active new user on our site
lately, and they have been extremely inquisitive, especially digging down into
the details of a lot of questions.  And Pieter's been very generous with his
time to answer a lot of their questions.  So, I think the product of this,
they've also added like 30 comments below where they continue to iterate on the
topic.  I think we're getting a bunch of really comprehensive answers out of
this.  So, if you have ever been wondering about this, we had previously already
a page on Optech to go into the details between some of these terms, especially
in the context of multisignature versus multisig.  But yeah, what we call
schnorr sigs is not that well defined in Bitcoin.  We actually use BIP340
signatures.  And schnorr signatures, as defined, might be most clearly what was
proposed in that paper some, what is it now, 30-odd years or 40-odd years ago.

**Mike Schmidt**: Yeah, Murch, you mentioned a great resource.  If folks want to
look into Pieter's answer as maybe a first pass on Pieter's explanation of these
terms, and then we also do have a great multisignature page on the Optech Topics
wiki, where you can kind of compare and contrast what is FROST and how does that
fit in versus MuSig, etc, threshold signatures, etc.

_Is it advisable to operate a release candidate full node on mainnet?_

Next question from the Stack Exchange is, "Is it advisable to operate a release
candidate full node on mainnet?"  And I suspect, well I think we're talking
about Bitcoin Core, which makes a lot of sense because we do have Bitcoin Core
RC2, and now 3, that we've covered in the Twitter Spaces.  So, it sounds like
this user is considering running that on mainnet.  And I think the specific
question was, is this a risk to the Bitcoin Network?  Murch, you were one of the
people that answered this question.  So, what's your take on whether it's a risk
to Bitcoin Network and what risks there may be, if it's not, to the Bitcoin
Network?

**Mark Erhardt**: Yeah, so I would generally not consider it a risk to the
Bitcoin Network.  The Bitcoin Network is composed of a number of nodes that
operate under different rules.  We're supposed to be compatible with any version
of Bitcoin Core node that's been ever published.  We're also supposed to be --
well, that's not entirely true.  The P2P message has changed in 0.3 or so, so
any since then.  But there's also a bunch of other implementations of the
Bitcoin protocol that we also have to be able to communicate with.  So, whatever
a malicious attacker could do to us by misbehaving inside or outside of the
protocol is probably going to be much worse than whatever an almost finished,
final candidate for release would be doing to us.  So, the danger here is not
that great.  You should absolutely go ahead and run RCs in production, as long
as you do not depend on the node operating continuously and well, because all of
your business back end is attached to it.

So, I would say if you are a significant economic actor in the network, if
you're running your own wallet off of that Bitcoin Core node, if you, for
example, have an indexer or other services attached to that Bitcoin node or
maybe an LN node, then you might not want to switch to a release candidate.  You
might even want to hold off on switching to a new release for a month or two to
let other more adventurous spirits test it further.  But if you do run a full
node just for the heck of it, or if you even run multiple full nodes to be
abreast of recent changes, or if this is your testing setup because you do run
business infrastructure running on a full node, you should absolutely run an RC
and test it and report anything that is strange or unexpected about it.

_What is the relation between nLockTime and nSequence?_

**Mike Schmidt**: Next question was, "What is the relation between nLockTime and
nSequence?"  And really I just used this particular question as a jumping-off
point for six related questions from the Stack Exchange this month.  Murch, you
mentioned that active user, LeaBit, I think it's pronounced, who joined the
Stack Exchange in the last month, and I think this person asked all six of these
questions, really digging into timelocks.  And it's kind of encouraging to see
somebody new on the Bitcoin Stack Exchange that is asking fairly intense
technical questions.  Oftentimes, as a person who authors a section of the
newsletter, you can see that there's new people joining and asking questions and
sometimes they're not as in-depth as this, so it's encouraging.  Hopefully,
LeaBit can continue to level up their knowledge and maybe even start
contributing at some point.

I don't know, Murch, if you want to jump into each one of these six questions or
if it would make sense to just maybe summarize nLockTime and nSequence, and if
people are curious about the nuances, they can jump into these answers.

**Mark Erhardt**: I think let's go with a summarized approach, because six
questions is going to take a lot of time.  NSequence is a field on every input.
It was originally intended as a way to make sure that transactions could iterate
through multiple versions, and it was supposed to sort of demark inputs with an
increasing sequence number, and a transaction with a higher sequence number was
supposed to be preferred over a transaction with a lower sequence number.
However, there was never a mechanism that could actually enforce that behavior.
So, people would have always been incentivised to simply accept whatever
transaction pays more fees in order to collect a higher total revenue in their
block.  So, that mechanism was removed at some point, or never really worked.
And later, that field that was required by consensus rules got changed in its
definition and is now used to generally signal finality of transactions.

So, if all inputs on a transaction have a max value sequence that signals that
the transaction is final then the LockTime will be disregarded.  If at least one
input has a value that is lower than the maximum, the LockTime in the
transaction header, so transaction-wide, will be respected.  So, that is either
a block height or an absolute time defined in chunks of 512 seconds times
whatever you set in this value since the Unix time epoch.  And yeah, so the
LockTime is a transaction global value of a single field on a transaction.  It
can tell us that a transaction cannot be included in a block up to the height
that the number defines, and similarly for median time past.  So, if the
LockTime were block 100, the first block that a transaction can be included in
is block 101.  And the sequence, as I said, can be used to either enforce or not
enforce the LockTime.  And then for even lower values, first we get
replaceability.  So, for max-minus-two or lower, a transaction is considered
replaceable per the BIP125 rules.  And then for even lower numbers, we get the
behaviors for CHECKSEQUENCEVERIFY (CSV), which I don't want to get into detail
now unless you make me!

**Mike Schmidt**: I won't make you.  I'll just comment maybe at a high level
that the constraints within Bitcoin have spurred some creativity in this, and
timelocks is one example of that, of using these scarce fields that may not be
being used for certain purposes, because you can't just add new fields
willy-nilly in Bitcoin.  So, the creativity is admirable, but it does add to
some complexity when trying to explain what exactly these fields are.  So, if
you're curious about some of the interplay between these fields, check out the
newsletter where we link off to these different interactions between things like
CLTV, BIP68, etc.

**Mark Erhardt**: Maybe one small addition still here.  So, it's pretty funny
that since we have CSV both with the absolute time and a block height, and also
CLTV with an absolute time and a block height, and I think I'm actually not 100%
sure whether LockTime can only define a block height or a median time passed,
but I think it should also be congruent in that, so you actually get an
explosion of possible combinations, and you cannot use some of these together.
So, for example, if you have an input that defines a relative number of blocks
that a UTXO is locked, it cannot be used together with a relative time passed,
because both of those have requirements on sequences.  And I think the sequence
system downstream causes a requirement for LockTimes.

So, we have a Bitcoin Core contributor that's been looking into automatically
distinguishing which inputs can be spent together that are using different types
of LockTimes.  And yeah, it's pretty complicated and interesting!

**Mike Schmidt**: And doesn't RBF come into play there as well, too, right?

**Mark Erhardt**: Yeah, but RBF is just, is this considered replaceable or not
replaceable?  And basically anything that is below max-minus-one is replaceable.
So, if it has a single sequence that is below max-minus-one, it's replaceable.
So, yeah, the whole LockTime interactivity, where the absolute times with the
relative times, and relative times defined in height, block height, or in time
passed, and also absolute times and height or time, they have funky interactions
where some of them cannot be used together.

**Mike Schmidt**: We have a question from the audience.  Larry is asking, "Would
that be a consensus violation or non-standard?"

**Mark Erhardt**: The main issue is, you cannot have -- so, the absolute times
are defined in the upper half of the range, and the block heights are defined in
the lower half of the range, and you can't have both of those at the same time.
You can't have a value that's both in the lower half of the range or the higher
half of the range.

_What would happen if we provide to OP_CHECKMULTISIG more than threshold number (m) of signatures?_

**Mike Schmidt**: Next question is, "What would happen if we provide to
OP_CHECKMULTISIG more than threshold number (m) of signatures?"  The person
asking this question wonders, what would happen if you had, I think in the
example it was a 3-of-6 multisig, but then during signing, you passed five
signatures to OP_CHECKMULTISIG?  Sipa answered that currently this would fail,
but also noted that previously you could have had additional signatures passed
to OP_CHECKMULTISIG due to a bug in the initial implementation of the
OP_CHECKMULTISIG opcode.  So originally, well I guess currently, the
OP_CHECKMULTISIG opcode has a bug where n, of the public keys, and m, of the
signatures, are popped from the stack, but that opcode also pops an extra
unnecessary item off of the stack, which forces all the multisig transactions to
have a dummy value at the beginning of the unlocking script.

So, because of that bug, you could have potentially provided in the past an
extra signature in that extra dummy value slot, and it would have been consensus
compliant.  But in 2017, there was a soft fork to not allow arbitrary data in
that dummy slot.  That dummy slot has to have a value of zero, and that was done
in a soft fork, BIP147.  Anything to add there, Murch?

**Mark Erhardt**: Yeah, also leaving an element on the stack would also make the
transaction non-standard.  And I think if a zero is left on the stack, it's
actually going to fail validation.  You only can have positive elements left on
the stack for it to be valid.  Sorry, so to clarify, if there were a positive
value left on the stack in the end, I think that would be fine.  If there's a
zero left on the stack, I think that would fail.  So, if you had multiple
signatures added, it might actually pass, but be non-standard because there's
multiple elements left.  But this is just spur of the moment.  I'm happy to be
corrected.

_What is (mempool) policy?_

**Mike Schmidt**: You mentioned non-standard there, which is a good segue to the
next question, which is, "What is (mempool) policy?  And Antoine actually went
and started his answer with defining both policy and standardness.  And Murch,
I'm curious, as an educator and somebody who thinks about terminology, including
being the author of the transaction terminology BIP, which doesn't cover these
terms, maybe how would you define policy versus standardness?

**Mark Erhardt**: That is an excellent question.  Well, I would say that they
are somewhat used interchangeably.  When we talk about a standard transaction,
we're talking about what a default node would accept into their mempool.
Standardness generally is a more restrictive rule set than consensus validity.
So, we will accept stuff in blocks that we would not accept into our mempool.
And what we don't accept into our mempool, we do not relay on the network.  I
think for the most part, policy is referring to mempool policy.  And what gets
into our mempool, we consider to be standard transactions.  But I think more
strictly, standard is a specific function in the Bitcoin Core code that checks
some of the mempool policies, but there might be further mempool policies that
also restrict what we accept into the mempool.  So, policy might actually be a
little more restrictive even than what standard transactions are.  So, yeah, I'd
have to stare at that a little more.  I haven't read that answer yet.

**Mike Schmidt**: How about two examples from the answer that Antoine gave?
One, he gives an example saying, "A transaction is invalid by Bitcoin Core
standardness rules if it has a fee lower than 1 sat/vbyte".  And the second
example is, "Sending an unconfirmed transaction which has 25 or more unconfirmed
ancestors violates Bitcoin Core policy rules".  Would you categorize those
examples as he had in standardness versus policy?

**Mark Erhardt**: Yes, this is actually exactly an example of how the policy
might be even more restrictive than just the standardness.  So, standardness
here is something that applies to a single transaction that we can determine by
just looking at that transaction isolation, whereas the policy that is being
failed here is something that applies to a set of transactions.  Concretely
here, if a transaction has already too many descendants, we might not accept
another descendant/if there's too many ancestors already, we might not accept
another transaction from that set into our mempool.

_What does Pay to Contract (P2C) mean?_

**Mike Schmidt**: Next question from the Stack Exchange is, " What does Pay to
Contract (P2C) mean?" and Vojtěch describes the P2C protocol, and we link off to
our Topic wiki on P2C, and he also linked to the original proposal, P2C being a
way that a public key can be created that commits to the text of a contract that
a sender and receiver both agree on, which then allows the sender to later prove
that the payment committed to that specific text or contract.  Murch, would you
care to augment that or does that satisfy the answer?

**Mark Erhardt**:  That is satisfying.

_Can a non-segwit transaction be serialized in the segwit format?_

**Mike Schmidt**: Okay.  Last question from the Stack Exchange, " Can a
non-segwit transaction be serialized in the segwit format?"  The short answer is
that you could do this, but in BIP144 that specifies serialization formats for
propagating transactions that commit to witness structures, that part of the BIP
states, "If the witness is empty, the old serialization format must be used".
And I think that maybe on its own is less interesting for the audience, but I
did think it was interesting that Pieter, in answering this, also pointed out
some interesting history, that Bitcoin Core version 0.14 through 0.18
unintentionally allowed using the extended newer serialization format even for
transactions that didn't have a witness.  That didn't cause any issues in
particular, but it was interesting that that was there for quite a few versions.
I don't know if you were familiar with that, Murch?

**Mark Erhardt**: I was not, but I also want to clarify the answer states, it
would accept it in deserializing.  So, if it got a transaction relayed that had
serialized a non-segwit transaction with the segwit format, aka it added the
witness stack even though there were no witness items, then it would have
deserialized it and accepted it, but it would never create those.

**Mike Schmidt**: Yeah, it would accept the old, but when it sends it out to
peers it would use the new again.  So, no I guess attack vectors there per se.
That wraps up the Stack Exchange.

_Core Lightning 23.11_

Moving on to Releases and release candidates.  Core Lightning 23.11 is out.
Some things that I found interesting, I know we've talked about some of these
and we've had PR discussions about these over the last month or so, but I'll run
through a few things I found interesting from the notes.  More powerful access
control for the rune authorization mechanism; improvements to the check command
in CLN, and the check RPC is a command that verifies another command without
actually making any changes.  So, it's a way to, I guess, check that your call
to a particular RPC is doing what you want it to do, or would do what you want
it to do; the ability to verify the validity of existing emergency backups using
the decode command; large/wumbo channels; changes to the dual-funding process;
new features for CLN plugins; and, "A whole lot of cleanups to stay on track
with small specification changes".

But this is just what I picked out, so obviously check the release notes for
more.  Murch, I don't know if you had anything to add?

**Mark Erhardt**: No, but I was wondering whether nifty has something to add.

**Mike Schmidt**: Oh, good point.  Lisa, if you're still with us, do you have
any comments on this CLN release?

**Lisa Neigut**: Hey, I think the biggest, exciting thing for me is the
dual-funding interop that we got working with Bastien's Eclair project, so
that's really exciting for us.  It's still under experimental and we'll probably
keep it there until it gets merged into the spec, which hopefully will be fairly
soon.  And so, I would expect in the next release of CLN, dual-funding will be
out of experimental and something that will be able to be widely available
without having to do any special configuration on your node.

Chris Guida is also reminding me that there's a really cool new feature that got
added to this version of CLN that I'm really excited about building on top of,
something called, I think it's called Unified Invoices, which basically now
there's a feature in CLN that whenever you make an invoice, it'll give you an
onchain address as well.  And then if a payment gets made to either the invoice
over LN or onchain, it'll go ahead and mark that invoice as paid.  This is
really, I think, a really great way to make onchain and LN payments basically
through the same CLN node, which is great.  I think the feature to look for for
that is invoices-onchain-fallback.  It looks like Bastien's got some stuff to
add, so I'm going to toss it to him.

**Bastien Teinturier**: Yeah, it's just regarding dual-funding.  There's one
comment I made on the PR that we didn't think about adding a Type-Length-Value
(TLV) for the required confirmed input to the RBF messages.  And if we use the
same TLV bit as in open and accept channel, this is an even TLV bit, so it would
be backward-incompatible.  So, it's nice that you are still flagging
dual-funding as experimental so that we can do this thing in the spec PR and in
our implementation, before actually shipping it and saying that it's not
experimental anymore.  So, if you have time to look at that comment on the spec
PR, maybe we can discuss it during the next meeting.

_Bitcoin Core 26.0rc3_

**Mike Schmidt**: Excellent.  Thank you both for chiming in.  We also covered
the Bitcoin Core 26.0rc.  And, Murch, you linked me to the 26 branch, and it
looks like there are a few commits since the last RC based on timing.  There
were some around memory usage, some around compatibility with some Microsoft
tooling, and some changes around the CI.  And you also noticed something with
regards to the ARM architecture in particular as well.  Anything else you think
folks should be aware of in this latest RC?

**Mark Erhardt**: No, as I said, I was out of the loop for two weeks, but it
looks like a bunch of issues were fixed.  So, if you've been testing or if you
want to test the current RC, just pull it down from the website.  There's a
binary, there's of course the source code to compile yourself and give it a
spin, we also have a guide for testing.  There's a bunch of suggestions of what
you could try out or starting points.  Please feel free to further take it for a
spin if you find any of the testing topics interesting.  And as always, if you
find any bugs, please raise an issue in the Bitcoin Core repository.

_Rust Bitcoin #2213_

**Mike Schmidt**: Two notable PRs this week.  First one is Rust Bitcoin #2213.
Murch, you authored the summary of this PR for the newsletter, so maybe how
would you summarize that for the audience?

**Mark Erhardt**: Yeah, so it looks like Rust Bitcoin changed the worst-case
input size estimate.  So, when you serialize an ECDSA signature, the r and s
values actually have a non-fixed size.  The way the DER rules work, if you have
an r value or an s value in the upper half of the range, you have to add an
additional byte in the front, because I think that's how they make sure that the
signed integers don't get interpreted as negative.  But anyway, so the
signatures for ECDSA are actually not a fixed length.  And high-s signatures got
made non-standard in BIP66, or some of the cases at least -- I think I said that
wrong actually, sorry.  In the 0.10.3 and 0.11.1 releases, people started
enforcing stricter rules on how signatures should be serialized in Bitcoin.
Before that, it was a little more Wild West.  That's especially related to how
ECDSA signatures were implemented in the then used libraries.  And then after
that, I think Bitcoin Core especially, and other Bitcoin projects, started using
libsecp for that sort of stuff.

So, anyway, high-s signatures have been non-standard for a long time, so we can
assume that any wallet that tries to use Rust Bitcoin to build a transaction
will only use low-s signatures, and therefore we can assume that a signature
only has 72 bytes in the worst case instead of 73 bytes, and we can slightly
reduce our estimate for the maximum size of the transaction and therefore use
less fees to achieve a specific feerate.

**Mike Schmidt**: Is the saving of that byte the reason that those high-s
signatures are now nonstandard and not really used?

**Mark Erhardt**: No, the main reason is that this was a vector of transaction
malleability.  So, a signature, the r value cannot really be modified by third
parties because that would just break the signature.  However, the s value can
be mirrored along the axis.  Plus-s or minus-s are both a valid signature for
the same transaction.  This has most notably been called out in the context of
Mt. Gox because it, for a legacy transaction, changes the txid.  So supposedly,
Mt. Gox lost a bunch of money by not noticing that they paid withdrawals
multiple times, because they built the transaction then tracked only the txid,
but not the payment itself.  And when someone malleated the signatures by
turning around the s value, the txid changed and they never saw the transaction
confirm and then made the withdrawal again.

So, supposedly that's how Mt. Gox lost a lot of their funds.  There may have
been other issues.  Also, you can, I think, WizSec wrote up a huge thing about
that.  So, if you're interested in the history of how Mt. Gox got emptied out,
you can read that.  But anyway, the main issue is that being able to malleate
the s value in the signature changes the txid.

_BDK #1190_

**Mike Schmidt**: Yeah, that's a great bit of history there with Mt. Gox.
Thanks for adding that.  Last PR this week, BDK #1190.  So, previously in BDK,
it was easy to get a list of unspent outputs, but harder to get a list of spent
outputs.  So, this PR adds a new method, called list_output, for listing all
spent and unspent outputs all in one place.  So, I think pretty straightforward.
Murch, anything to add before we wrap up?  It's good to have you back.  It was
also good having Dave, so I hope you enjoyed your time off, but now we're going
to bother you every week.

**Mark Erhardt**: Yeah, I have nothing to add.  Thanks for having me.

**Mike Schmidt**: Thanks, Lisa and Bastien, for joining.  Thanks for Chris for
jumping on and asking a question and Larry for asking a question, and for
everybody listening.  Have a good week.  Cheers.

**Bastien Teinturier**: Thanks everyone.

**Mark Erhardt**: Oh, Chris has raised his hand.

**Chris Guida**: Hey, yeah, I just have two really quick points.  The first is
I'm going to answer my own question from earlier when I talked about how it
seems like it's impossible to splice-out of a channel lease.  My understanding
was that the timelock goes on the funding transaction, but it actually goes on
the commitment transaction.  And so, since those don't go onchain, it makes
sense that you should be able to renegotiate those timelocks.  Thanks, Lisa!
The second thing I wanted to do is talk about a project I worked on when I was
with Start9 about a year ago.  If you guys want to test liquidity ads, you can
use CLN on Start9, and that has a liquidity ads feature.  It's kind of buried in
the experimental section, but I'm interested to see if people try that out.

**Mike Schmidt**: All right, cool.  Yeah, thanks for bringing that up.  And
thanks for speaking on the Space today.

**Chris Guida**: Yeah, glad to be here, thanks.

**Mike Schmidt**: Have a good week, everyone.

{% include references.md %}
