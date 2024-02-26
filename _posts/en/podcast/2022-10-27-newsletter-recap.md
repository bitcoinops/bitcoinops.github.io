---
title: 'Bitcoin Optech Newsletter #223 Recap Podcast'
permalink: /en/podcast/2022/10/27/
reference: /en/newsletters/2022/10/26/
name: 2022-10-27-recap
slug: 2022-10-27-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao, Gregory
Sanders, and Sergej Kotliar to discuss [Newsletter #223]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-11/346583329-22050-1-6b6beccd57fcc.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to the Bitcoin Optech Newsletter #223 Recap
Twitter Space.  We have a big one today again.  Hopefully, we can try to
condense everything to keep it somewhat under our 90 minutes of last week.
Quick introductions, we can introduce Murch when he gets here, but Mike Schmidt,
Optech contributor and Executive Director at Brink, where we fund open-source
Bitcoin developers.  Gloria, you want to introduce yourself?

**Gloria Zhao**: Sure.  I work on Bitcoin Core mostly in mempool and P2P.

**Mike Schmidt**: Sergej?

**Sergej Kotliar**: Yeah, hi, I am the CEO of Bitrefill.  We help people buy
stuff with bitcoin, because what kind of internet money is it if you can't use
it to buy stuff?

**Mike Schmidt**: Instagibbs, I know you might be chiming in later, do you want
to introduce yourself now?

**Greg Sanders**: Sure, I'm instagibbs, I've been working lately on some mempool
policy stuff with Gloria and others.

**Mark Erhardt**: Hi.

**Mike Schmidt**: Hi, Murch, who are you?!

**Mark Erhardt**: I'm Murch, I work at Chaincode Labs, I do a lot of education
talking about Bitcoin sort of stuff.

_Continued discussion about full RBF_

**Mike Schmidt**: Well, welcome everybody.  Like I mentioned, we have a pretty
packed newsletter this week.  I think the only pertinent announcement really
applies to the first news item here, which is still getting feedback from
Bitcoin businesses that have opinions on the mempoolfullrbf discussion, so I
guess we can just jump right into that.  Gloria, I know you had sort of a great,
I guess you would call it a tl;dr note on what's been going on in this
discussion and who is saying what, and pointing to relevant mailing list posts
and PRs on the topic.  Maybe, for folks that didn't read your note, is there a
tl;dr of the tl;dr that you can give to sort of frame this discussion before we
jump in?

**Gloria Zhao**: Sure.  Let me know if I'm going too slowly.  We've had RBF for
seven-ish years, but one of the rules is for something to be replaced, it needs
to signal BIP125 replaceability, where you set the nSequence of an input to be
below a certain amount, so it's opt-in.  And then now we're talking about
full-RBF, as in we will allow replacements, as long as they're
incentive-compatible and not DoS, etc, even if the original were not signaling.
This has been talked about for a long time.  A year ago, Antoine Riard posted
about adding an option to 24, where individual users could turn full-RBF on, and
then it was merged.  And now, we're going to release 24 potentially with that
option.

There are some concerns that having this option can make it more likely for
full-RBF to happen on the network, I think reasonable concerns from businesses
saying, "Well, if full-RBF happens, we are in trouble", notably people that are
accepting unconfirmed transactions as final payments.  And so, there has been a
request to remove this option from 24 and either place it back in 25 or sometime
in the future.  Okay, apparently my mic is having issues.  Let me know if I
should repeat anything.

**Mike Schmidt**: I think you're okay so far.

**Gloria Zhao**: Okay.  Maybe it's someone's speaker.

**Mike Schmidt**: I'm hearing it too, but it's good enough, but yeah, it's
cutting out slightly.

**Gloria Zhao**: Okay.  Sorry about that.  And so, there are some discussions
about the option, whether or not we should have that in 24 and when we would add
it back, for example, if you reverted it.  There's discussion about full-RBF in
general, if we should have it, if we should, when we should have it, should it
be years from now, or should we try to prevent it completely?  And then there's
also discussions about replacements in general, and whether having replacement
policies is good for Bitcoin. There are posts about like, "Oh, is economic
rationality a thing that we should encourage on the network", you know.  But
yeah, so there's kind of, I think, three kinds of discussions going on, which is
full-RBF option, full-RBF and RBF.

**Mike Schmidt**: What is the contingent of folks who are saying there should
never be full-RBF; is that a large percentage of the feedback that's been given?
It seems to me like that's a small minority.

**Gloria Zhao**: So, yeah, so to be honest, I've only heard one person actually
voice this opinion, representing what you said.  But from what I understand from
our conversation is like, yes, maybe full-RBF is the natural equilibrium, but if
we were to move there more naturally, then that might look like a several-year
timeline instead of a several-month timeline.  I only know of one person who
says full-RBF should be prevented completely.

**Mike Schmidt**: Okay.  So, that's a largely dissenting voice.  It seems like
the bigger debate, at this moment, is in terms of the option going into 24.0, or
if it is, and then there's default surrounding it, and there's some discussion
of having it be default on instead in the future, and potentially a future date.
And it seems like that is sort of where the biggest discussion is.

**Mark Erhardt**: I think we can focus this discussion a little bit.  I don't
think that we need to talk about what exactly the RBF rule should be at this
time, and whether there should be any possibility of RBF.  I think those are
separate discussions and sort of out of the scope.  I think we can focus more
specifically on mempoolfullrbf right now, whether or not it should be released
with 24.0, and whether full-RBF should happen, and I think we'll have enough to
do with that.

**Gloria Zhao**: Yeah.

**Mike Schmidt**: Yeah, that's fair.  Maybe that's a good opportunity then to
bring in Sergej.  I know you had some comments and concerns about the free
option problem.  Do you want to illustrate that particular issue and your
thoughts around that with regards to the mailing list posts?

**Sergej Kotliar**: Sure.  But I mean, we can go into that as well.  It's not
the whole of the problem, but I would also, I guess, add to Gloria's point that
not so many have voiced concerns but Bitrefill, we do zero-conf payments and so
on, and I've done that for eight years, but there's a lot of companies that
allow people to pay with bitcoin.  And as far as I know from talking to them,
everybody does something very similar to what we do and have similar levels of
success.  So, it's not the case that it's a few people complaining, it's just
that it's a large set of people, company services and so on that are using
bitcoin that aren't actively engaging in the mailing list discussion, which I
guess we can discuss what to do about that.

But I guess, actually this conversation started by Dario from Muun Wallet, that
does something a little bit different than pure payments.  Anyways, I mean
there's a lot of issues with RBF and even in its current form, it's a big source
of customer complaints because Bitcoin is unpredictable.  You know, the blocks
come in at random intervals, so there's no way of saying your transaction will
confirm at point whatever, right?  And so even today, when a relatively small
minority of Bitcoin users use RBF, there are still people that actually end up
using RBF by mistake, because they installed a wallet that does this and didn't
know better and end up in problematic situations.

In terms of the call option problem, I mean fundamentally somebody who accepts
payments in bitcoin for things that are priced in fiat, for example, or
something like that, take a certain FX risk, right, because by the time we need
to tell the customer you need to pay this many, 0.01643 BTC, and by the time
that they do pay, and by the time that the transaction confirms, the price of
bitcoin can change.  And you can also imagine a transaction that can sit in the
mempool for very long periods of time, and I think it's important to keep in
mind that the RBF discussions are mostly relevant for a situation in which the
mempool doesn't clear out very fast and very often, but rather there's a big
backlog of transactions, right?  And so it becomes an abuse vector, because
somebody can create a transaction, set a low fee and then maybe wait for days,
weeks, whatever to see maybe the bitcoin price moves, and if bitcoin went up,
they can cancel the transaction, which strips the merchant side of the
reliability of knowing that this amount of bitcoin is going to come in.

It may take a little while, but it's going to come in for sure.  And that kind
of ruins the basic premise of you set the price in BTC for what BTC is now, and
BTC can go up, it can go down, but in the end, it kind of evens out.  But if it
becomes easily accessibly abusable to potentially large numbers of users, then
we should expect there to be opportunistic abuse of this, which will sort of
impact companies offering payments with onchain BTC.  Because if you look at,
for example, an open node that charges 1%, that means if they get abused for 1%
or more, then they need to rethink how that business operates.

So, the alternative is, of course, to do different kinds.  There's a lot of
different options, but they're all quite costly and will tax also the people
that aren't using these things, and it will tax the good citizens of bitcoin.
There's also all kinds of other UX issues that are known, but maybe not enough
discussed that I think we should actually discuss here, because we're discussing
policies on the Bitcoin Network and user experience as a factor, even though
it's not as algorithmic as certain abuse vectors.  But maybe I'll pause here.

**Mark Erhardt**: I would like to jump in here.  I fundamentally disagree with
the characterization of what's going on here as a call option.  What is
happening here is that a business is offering a service, and it is making a
proposal at a certain time to offer a specific service for a specific price.
And while that offer stands, the user has the option to accept or reject that
proposal, and that is dependent on whether the service has been delivered
already, at which point the contract has been triggered, and it is dependent on
how long that offer is open.  And if you allow people to make low fee payments
and keep the offer open for weeks, that's on the company that is offering a very
long window.

**Sergej Kotliar**: But not with everyone though, that's the point.

**Mark Erhardt**: Well, exactly.  So, what is the problem here?  I don't see a
problem here.

**Sergej Kotliar**: Normally, somebody like Bitrefill will set a price and fix
it for 15 minutes or half hour, or whatever, and we kind of eat that small
volatility; that if bitcoin moves within that, okay, whatever.  But with RBF,
that means that the customer has optionality.  They can potentially wait for a
week or at least days, maybe more than a week, they set a low fee transaction
and they just wait.

**Mark Erhardt**: Yeah, but if you still accept the payment a week later, then
you have made an offer that lasts a week.  And that is your problem, not really
a problem of RBF.

**Sergej Kotliar**: Exactly.  But that's the programmatic way of seeing it.  But
given that it's difficult, we can definitely make it the customer's problem.
And the solution will be that the customer feedback will be so overwhelmingly
negative that we will have to end up not offering this particular service
anymore.

**Mark Erhardt**: So, you're saying that you don't want to offer that service
anymore if you actually price it correctly?

**Sergej Kotliar**: What I'm saying is, well, yes, in effect, yes.  And by you,
we're not talking about Bitrefill specific, but we're talking about any company
that offers you to pay in bitcoin for things that have a price in fiat.

**Mark Erhardt**: But if the people have already gotten the return service, then
the contract has already been triggered, you should make them pay in time and
the payment amount is clear already.  So, I don't see a call option any more.
If they don't pay you later, they're stealing from you.  That's not a call
option, that's theft.

**Sergej Kotliar**: No, it's not that we would deliver the product to them and
let them steal, I mean that would just be dumb.  But abusing -- bitcoin
volatility can go up and down.  Bitcoin has days when it goes up 20%, for
example, it has days when it goes down 20%.  This is part of the game in
offering bitcoin payments, that some transactions will end up being
unprofitable, some end up being profitable.  And in this case, you remove half
of it; you remove those that end up being more profitable and only keep the ones
that end up being unprofitable.  It's basically an easy way to game the system.

**Mark Erhardt**: So, what you're saying is you need a way to limit how long an
offer stands in order for your business to work as intended?

**Sergej Kotliar**: Correct, yeah.  And with Bitcoin blocks coming in in an
unpredictable fashion, there is no set amount of time that is appropriate for
such a thing, which makes it difficult.  Because if we say that you have to get
a transaction confirmed within 30 minutes, for example, there's going to be a
lot of people that are very upset, there's going to be refunds, there's going to
be support tickets, there's going to be not great user experience, and we end up
punishing a lot of people that had no ill intent and just did what they have
always done, which is scan a QR code to pay with bitcoin, and now suddenly they
didn't get their thing, even with the waiting period.

**Mark Erhardt**: I feel like I'm repeating myself, and I also don't find the
American call option...  I think I've made my point that I don't find that
compelling.  And I think it's also a very small part of the whole RBF story.
So, maybe we can step back a little bit and look at the larger picture.

**Sergej Kotliar**: Should we talk about UX?

**Mike Schmidt**: Sergej, what did you have in terms of UX in addition to what
you've already alluded to here?

**Sergej Kotliar**: Well, I mean if we ignore the call option thing, which I
don't even know if it's a security hole or not.  But like, the status of things
is that most wallets that Bitcoin users are using do not offer any functionality
to do anything with RBF whatsoever.  There's a small number of wallets that do,
Bitcoin Core, Electrum, and there's a couple of smaller wallets out there that
do that.  But anybody that has any of the more common wallets or uses a
custodial exchange, or something like that, don't currently have any option to
control.  They get all of the bad of it, which is that their bitcoin payments
are failing, and none of the good.  And this far, RBF has been opt-in flag,
which is mainly available in power user wallets, again, Bitcoin Core, Electrum,
and so on.  If you imagine the stereotype of a person using such a wallet, then
many of them are going to be people that sort of know what RBF is, what it means
to bump fees and so on, and can kind of deal with it, right?

So, the issue isn't currently, from the UX standpoint, all that big.  But
suddenly changing the behavior of Bitcoin to be like that for everybody is going
to cause a very big storm in terms of how people perceive Bitcoin onchain as a
way of buying things.

**Mike Schmidt**: Gloria, did you have a comment or question?

**Gloria Zhao**: I don't think it's true that RBF is not well supported.  Just
in my experience, every wallet I've seen has given me the option to use RBF.

**Sergej Kotliar**: Let's go through the biggest Bitcoin wallets out there.
Blockchain.com, no RBF;  Exodus, no RBF; Trust Wallet, no RBF; Binance,
Coinbase, all exchanges, no RBF.  And these aren't some niche wallets.  I mean,
this is the vast majority of Bitcoin users that don't have any usability.

**Gloria Zhao**: But like, is them not being able to send an RBF payment the
issue here?  Isn't the issue that you're a zero-conf business and you need to
handle RBF?

**Sergej Kotliar**: Sure, but the issue for buying stuff we can discuss, but
nobody has proposed, which I think is also remarkable, that nobody in the
mailing list has thought about, here is how somebody would buy something with
bitcoin in a world where RBF is the norm.  It's all very theoretical examples,
but in practice, everybody who actually does this is relying on it not being the
case.  And so, the attitude becomes a little bit that, "Hey, let's change this
thing, and you guys will have to figure it out, we don't know".

**Gloria Zhao**: I don't know, I think people have considered how to use bitcoin
on the mailing list.  I use bitcoin to buy things pretty much on a weekly basis,
which is not super-often, but I've found wallets to be quite usable.  And I know
this is anecdotal, and I don't think it's fair to say like, "Oh, these people
don't know how to use bitcoin.  They only talk about things in theoretical
terms".

**Sergej Kotliar**: Well, have you reached out to the companies that you've
bought things with bitcoin to ask them what they think about this policy?

**Gloria Zhao**: I have spoken to some people, but I really...  There's also a
question of like, is the Bitcoin Network, is the protocol responsible for
ensuring that someone's business model -- like, does it owe someone a business
model?  Is it responsible for ensuring that other people can receive payments
that are guaranteed to not conflict with other payments?  And is the network
responsible; and then, is Bitcoin Core responsible?  Because coming back to this
question of, is it bad to have this option in a Bitcoin Core release, it's like,
okay, we haven't changed any default behavior.  So, if full-RBF happens, if you
receive a non-signaling payment as a merchant and that gets double-spent and
that double-spending payment propagates through the network and a miner mines
that, is that Bitcoin Core's responsibility to prevent that from happening if it
was someone's choice, like all of these people's choices?  There would have been
a bunch of people on the network that chose to enable this option, it would have
been a miner who decided to enable this option; why is it that Bitcoin Core has
to go and talk to every single person who ever used bitcoin and say, "Hey, are
you okay with this?"

I think one of the arguments being made is, Bitcoin Core hasn't made the effort
to give notice and to make sure that everyone's okay with it.  And then you look
at what posts have been made and what efforts have been made and it's like,
okay, this was over a year ago that we posted full-RBF in Bitcoin Core 24.0.
That's the title of Antoine's post from June 2021.  And Optech covered that,
Optech has an RBF compatibility dashboard, it covered when the PR was open, it
covered when the PR was merged.  And then the argument is like, "Well, one
business or two businesses had a problem with it and you didn't ask them, and
you have the responsibility to make sure they're okay".  And this is just, I
think, a prime example of the impossible standard that people set Bitcoin Core
to, where you have to have responsibility for everything that happens on the
network, including users' individual choices and miners' decisions and every
business that has built a business model that may or may not be sound.

**Sergej Kotliar**: I don't think anybody made that argument, to be fair.  I
think the argument that has been made, yes, people were slow to notice and
that's a problem and so on.  Companies aren't engaging with the mailing list
enough, I agree.  I mean, I think fundamentally, like what is Bitcoin Core's
responsibility, I don't know, to be honest, and you make good points.  I mean,
currently the system works in a certain way, and it has certain properties that
to some are a bug, and to others are a feature.  So, the absence of RBF is like
that.  It's a bug from the perspective of pinning attacks and things like that,
against different kinds of smart contracts and so on, because it actually
doesn't work, whereas other people rely on it not working in order to ensure
certain models.  And so what is being suggested here is changing the policy
from, the Bitcoin Network works in X fashion to it now will work in not-X
fashion, right?

**Gloria Zhao**: Well, no, that's not what's being proposed.  What's being
proposed is, "Okay, we'll let users individually decide what their policy is
going to be, right?  Just so we're clear on what the facts are.

**Sergej Kotliar**: But today we have opt-in RBF, which lets users decide.

**Gloria Zhao**: Oh, so okay, so we're talking about opt-in RBF and full-RBF.

**Sergej Kotliar**: Exactly.

**Gloria Zhao**: So, with the policy...  Okay.  So, are we talking about
full-RBF being the choice, or the opting in to replaceability being the
decision?

**Sergej Kotliar**: Well, there are two different decisions here, of course.
And, I mean from my standpoint, sure, enabling functionality in a piece of
software, who can argue against that?  And it was always possible to run Bitcoin
Knots or something else, or change how a node works, and just having the flag
itself might not ruin everything, it might, I'm actually not sure, maybe I
should ask you here.  But in order to achieve the goals of having full-RBF as a
flag of some sort to prevent the pinning attacks and all of that, isn't it
required that a significantly large share of the Bitcoin Network actually runs
with that flag?

**Gloria Zhao**: Yeah, so for full-RBF to actually happen, you need -- okay, so
there's different --

**Sergej Kotliar**: No, but it's not enough to prevent the pinning attack that
just your Bitcoin Core has the flag flipped, right?  It's required that there
are enough nodes that will propagate this transaction and that there are going
to be miners that run with that flag.  So, in essence, what we have is a goal
conflict, basically, because we want opposite things.  And so I'm trying to
present sort of the counter side of why it might not be as desirable, given the
significant downsides to it, to move ahead with such a policy, or at least to
have a fair discussion, even though it seems companies have missed the
conversations repeatedly and some are still missing them.

**Gloria Zhao**: Yeah, so maybe just to backtrack, if we were to reverse back to
a year-and-a-half ago, before Antoine posted anything, before the PR was open to
have the option, what would be your recommendation for how Bitcoin Core could
have done this the right way, or what you would have been comfortable with, or
what you think businesses would have been comfortable with?

**Sergej Kotliar**: I don't know if the meta-discussion of what Bitcoin Core
should have been doing is the most interesting for this call, because it goes
into all kinds of political things.  And I think the more interesting
conversation is like, do we want this or not, given that we are where we are?
But I guess from my side, yeah, making sure that entities that might be
negatively affected get to weigh in and that their opinions are represented.
How?  I don't know.  But on the other hand, the RBF discussion is very old, and
so there isn't that much new.  These things have been going back and forth for
years.

**Mark Erhardt**: Yeah, I think it is good that people are chiming in and that
they're making themselves heard.  I actually don't even fundamentally disagree
with people being able to have a social signal that they do not intend to
replace a transaction and other nodes acting on that.  I do think it is a
problem if that is the default behavior and the majority of services and big
wallets on the network, after seven years of the policy being in place, still
don't even correctly interpret RBF and basically deny the fundamentally natural
flow of how transactions gossip on the network.

So, in a way, if we came from everything was replaceable, and we added a
nSequence signal to signal finality of a transaction, and that the sender does
not intend to replace it, I think I would be good with that, actually.  But the
assumption that RBF is not going to be the natural state of the network, and we
shouldn't be moving towards that, I find problematic, and it is slowing down
multiparty protocol development.

**Mike Schmidt**: Sergej, I see your hand up.

**Sergej Kotliar**: Yeah, if I can share, I think fundamentally there is an even
deeper issue here that's a little bit uncomfortable for us to talk about, but
that the pace of uptake of Bitcoin Network participants of new features, good
practices, and so on, as suggested by the Core devs or the Bitcoin Optech group,
and so on, is frankly slow, right?  It took segwit five years, I think, to get a
majority of transactions using it, even though there's economic incentives, and
so on; and we had Lightning, that probably everybody on this call would be like,
"Yeah, well, why don't they just use Lightning", right?  Yeah, but then we see
in practice that again, the vast majority of bitcoin users are actually still,
also five years later, still not paying with Lightning.

There is this ossification that I personally think is very unfortunate in the
sense that new things are not getting adopted fast enough, and the question is
what to do about it.  Traditionally, the Bitcoin Core project has had a
conservative approach, which is introduce a new thing, give people time, it will
take people a long time to adopt it, but that's okay.  But it is also causing
frustrations, and so now things are suggested to be like, "Okay, let's change
how the network works and everybody will just have to set a date, and people
have to rethink their business models, user experience flows, and so on in time
for that".  I don't know, I think it's something that maybe also we should be
discussing on a philosophical level, given the state of things, that a lot of
good things are being proposed but not getting adopted fast enough.

**Mike Schmidt**: I think that's probably a conversation for another day.  We do
have an audience comment or question.  Brad?

**Brad Mills**: Hey, I'm just curious, what's the benefit for adding full-RBF by
default?  Because it seemed like we already had this debate four years ago and
we decided that opt-in RBF was the best of both worlds.  So, I wonder what's
causing this need to want to add full-RBF?

**Mike Schmidt**: I think we alluded to it a bit.

**Gloria Zhao**: So, I think the most important response I would say first is
that it is not being proposed to add full-RBF by default.  It is just being
proposed to add an option for individual users to turn that on, on their
individual nodes, and the default has not changed.  But the tl;dr for why
full-RBF could make sense for the network to move to as a default is, one, to
fix certain pinning attacks.  So, right now, if you are receiving a payment that
does not signal, you can maybe reasonably assume that it won't be replaced.  On
the other hand if you are creating a channel, or you're creating a multiparty
contract with somebody, and they've brought in an input and they've actually
already spent that in a different transaction that didn't signal, not being able
to replace that hurts you.  The pinning is basically someone can not signal RBF,
place that into people's mempools, and then you are unable to evict it with a
transaction that's more incentive compatible.

Another is, if you're a miner, and let's say fees matter to you, maybe not
today, but when the block subsidy is lower, and fees are the vast majority of
what you get from mining a block, and you see two conflicting transactions, and
one of them pays higher fees, and the other one doesn't signal RBF, it would be
totally within your right to say, "Hey, I kind of want the one with more fees".
That's the economically rational thing to do.  And we probably should not be
building a lot of the Bitcoin ecosystem on top of the assumption that, "No,
actually, the miners are going to decide not to take those fees".  And again,
maybe this is something that happens far into the future, but we should not move
closer and closer towards assuming that they're not economically rational.

I think another one is, we're kind of observing non-signaled replacements
happening at a very, very low rate.  But if one miner decides, "Hey, I'm going
to run a patch where I do full-RBF", I think it's much, much safer for users to
have the option to adopt that policy on their own mempools as well, because
otherwise your mempool is not giving you a very good view of what miners are
likely to mine.  You're going to not have compact block reconstruction very
quickly, you're not going to have a good idea of what transactions are out
there, you might even get double spent because you've assumed that it's not
replaceable.  And so I think having the option makes sense if, for example,
right now, various miners and people on the network decide that they want
full-RBF.  And again, that's not Bitcoin Core's choice, that's not Bitcoin
Core's responsibility to decide they're not allowed to do that.  Nobody can stop
them from doing that, but it would be nice to have the option if you're like,
"Hey, full-RBF is happening, I should probably make sure my mempool is telling
me some accurate information.

So, those are the three things: pinning attacks; it's the natural state of the
network; and if it happened, we should probably have the option to align our
mempool policy with what's happening.

**Brad Mills**: And could I ask Sergej his similar summary of that, like why, if
this is not a consensus rule change and it's just like a UX change or something
like that, that miners are able to do this anyways, what's going to be the main
problem?  I've been listening and I don't get the main problem with merchants if
this is enabled.

**Sergej Kotliar**: Sure, I mean sort of Bitcoin is a Wild West, and I think
from our standpoint, we take a very, very conservative approach with zero-conf
payments.  And if it happens once or twice, we're probably going to stop doing
it entirely, which will open up this entire question of, what does the user
experience of paying with bitcoin look like in the future when what we're doing
now is no longer working?  And that's a big thing.  I would actually be very
interested in discussing ways of solving that, even today for the 20% to 30% of
transactions, depending on how you count, that actually do signal RBF.  I'd like
to, when I raise my hand, just ask a follow-up question to Gloria, if you know,
what's the rate currently that non-RBF transactions are being replaced a day?
And about the pinning attack, what's the best solution that we can achieve
without enabling full-RBF on the network?

**Gloria Zhao**: So, sorry, what was the first question?

**Mike Schmidt**: The rate of replacements that don't signal.

**Sergej Kotliar**: Yeah, the replacements happening.

**Gloria Zhao**: Oh, right.  Yes, very few.  Very, very few.  I agree.

**Sergej Kotliar**: I mean, I said one in a million somewhere, but I don't know,
is it more than that?

**Gloria Zhao**: More like maybe one in a few thousand.  A few orders of
magnitude difference, but yes, still rare.

**Brad Mills**: Does that mean that somebody can actually do RBF without
signaling that it's an RBF transaction?

**Sergej Kotliar**: If you're a miner, you can do that today.

**Gloria Zhao**: Yeah, if you're a miner, yes.  The question is if you or if
you're connected to a miner, you can have a path to that miner.  So, Peter
Todd's OpenTimestamps, I think, is a pretty good metric for this.  Basically, I
can link to it, and it's in my doc as well.  It's like, it "attempts" to do an
unsignaled replacement constantly, and there's thousands of transactions listed
on that page, and two of them are non-signaled replacements.  So, it exists.
And obviously you can attribute it to other factors, like maybe that miner
wasn't online when the first transaction was broadcast or something.  But all
I'm saying is you can look at that.

**Sergej Kotliar**: Cool, thanks.

**Gloria Zhao**: Yeah, and then the second question about the pinning attacks, I
don't know if there's a solution other than full-RBF, because I think
essentially, I would consider it like pinning attacks of the class of
non-signaling, essentially, where you're pinned because someone put a
non-signaling conflicting transaction in someone's mempool ahead of you.  And
like, I don't know if there's a way to replace it if it's non-signaling, other
than that node allowing the replacement without signaling.  Does that make
sense?

**Sergej Kotliar**: Could it be done with the package relay stuff that you're
working on to get us somewhat --

**Mark Erhardt**: No, it can't, because the problem is that we are respecting
the non-signaling, the finality of the transaction that we've seen first, even
though we have more than one person that can...  So, we have two potential
senders that can either replace or enforce non-replacement, and one of the two
can force the other party to be unable to act.  And in this case, the honest
party has no recourse.

**Sergej Kotliar**: But the recourse is, if I understand correctly, to evict the
funding transaction from their own mempool.

**Mark Erhardt**: No, because they would have to be able to evict it from other
people's mempools and per policy, that is currently not allowed.

**Sergej Kotliar**: Right.

**Mark Erhardt**: I actually have a question for you, Sergej.  So currently,
your business relies on making a reasonable assessment of whether a payment
promise is going to turn into a payment, and extending on back credit at that
point for UX reasons.

**Sergej Kotliar**: It's not credit.

**Mark Erhardt**: It is credit.  You're accepting a promise for payment, but you
have not received the payment yet.  So, just a sec, please.  So, wouldn't it be
possible to just, if you want to accept unconfirmed payments, to at least
encumber them with spending their outputs to yourself in a consolidation
transaction, and thus making it much more expensive to send a financial signal
to replace it?

**Sergej Kotliar**: Yeah, so that's a possibility.  Generally, the issue with
doing CPFP on the receiving side is that if you're a known entity that is known
to do CPFP, then it can be abused by doing consolidations of a wallet UTXO,
which can be somewhat expensive.  Again, we're talking about time periods when
fees are high here.  And so if it's known --

**Mark Erhardt**: I'm not talking about CPFP, I'm talking about sending a
transaction that spends the output that has been promised to you, and thus
making a second transaction that also is in the mempool that has to be paid over
in order to replace the original.  It doesn't even have to be a CPFP, it just is
a second transaction that changed off of the first.

**Sergej Kotliar**: But isn't that just a bidding war then against the sender?
I mean, I pay 100 sats, they pay 101 sats and so on.

**Mark Erhardt**: No, you have to both pay over the fee as well as the feerate.
So, yes, they can pay easily over the feerate of their original payment, but by
consolidating all the payments to your wallet, you make a larger payment that
they also have to pay over.  And I'm just asking, would that not also increase
the assurances that you have, that the payment promise will not be retracted?

**Sergej Kotliar**: Yeah, I mean it's stuff that we can do.  We don't mainly
because it's quite costly, like spending outputs in an environment where fees
are high is costly, and so spending many outputs when fees are high is costly
and usually when we do consolidations, we do them nights and weekends where fees
are low.  So, I guess this isn't a binary question of whether or not this can
actually be done, but the question of, how much does it cost; what are the
actual benefits in terms of, as you say, increased reliability and so on?  So, I
think this needs to be evaluated more thoroughly, but I think currently with the
payments that are signaling RBF, it's not something that we do today.

But it was proposed, I think one of the more interesting proposals from the
mailing list, was to sort of have a policy of like, we will bid on this
transaction and we will scorch the earth, we will burn that bitcoin to the
ground just so that the abuser can't get the coins.  That's something I want to
evaluate whether or not it's actually feasible.  It sounds interesting.

**Mark Erhardt**: Yeah, so it sounds to me that there's a lot more design space
than it is made to seem if you're saying that this breaks your use case.  And
this design space has not been fully explored, and it feels like by denying
other people to do full-RBF, you're saying, "Hey, the network should bear the
cost for me to keep my use case the same without exploring the full design
space".  If this is the only option how your use case works, fine.  I agree you
should be miffed, but I don't think it is.  There's other ways of making your
use case and UX work that does not depend on RBF working the same way it works
today, and nobody using it.

**Sergej Kotliar**: There very well might be, and I think it should be explored.
But just granularity again, it's not my use case.  It's everybody that accepts
payments from people who scan our Bitcoin QR code.

**Mark Erhardt**: Yeah, that's fair.

**Sergej Kotliar**: But absolutely, I think we should explore this.  And I think
that even today, when there is 20%, 30% of people that actually do use RBF, it's
already meaningful to start exploring it.  And I'm all for, I want to start
exploring it.  I think I would love to have Gloria and the Core devs, and so on,
be part of exploring it, maybe even as a result publishing some kind of like,
"Here's what we found and this actually works", and so on.  And that might even
make this issue theoretically go away.  We can imagine such a scenario.

**Mike Schmidt**: Stacie, did you have a comment?

**Gloria Zhao**: I think it would be nice if we all worked together to figure
out a way to maintain fast payments, hopefully through Lightning or something
else, that doesn't rely on onchain discount stuff.  This is what Bitcoin was
for, right?  If we had a way to figure out ensuring double-spends don't happen
before we put in a block and do proof of work and stuff like that, we wouldn't
need Bitcoin, right?  Maybe that's too simplified.  But anyway, yes, I think
it'd be great if we can come up with a solution for merchants to still receive
fast payments and then for commerce to happen, and then still have that figured
out and then not be relying on signaling for RBF.  And then, once that adoption
reaches a certain point, okay, maybe we turn the default for RBF on.  I think
that is the best-case scenario for everyone, I think, and hopefully we can get
to that point.

**Stacie**: Can I just ask a quick question about the upcoming 24.0 release?  Is
opt-in full-RBF for sure pulled from it, or is the release waiting to see if it
maybe will make it back in?

**Mark Erhardt**: So again, this is just, currently as it is being proposed, the
release candidate has a new option that allows the full node user to set at
startup a different mempool policy, which essentially removes a single line from
Bitcoin Core, and then it will treat all transactions as if they had signaled
RBF instead of just the ones that do signal RBF.  And I honestly do not expect
this to have any significant change in how transactions propagate on the network
for the next probably half year, even year, because miners have had for many
years the option to run their mining operations in this way, and we currently do
not see a significant portion of the hashrate to do this.  I think that maybe
actually --

**Sergej Kotliar**: If it doesn't change, it doesn't fix a pinning attack.

**Mark Erhardt**: Correct.  I agree, you're right.  If it doesn't change, it
doesn't fix the pinning attack.  It introduces the option.  It sort of is
fishing for, "Okay, is this something people want to use or not?  We've been
debating it for seven years".  And I know that some people do want to use it,
it's mostly on the user side so far, but it does not, per se, immediately remove
it.  And even if a small portion of the hashrate adopts it, I think it would be
a degraded experience for the merchants that rely on unconfirmed transactions,
but it wouldn't immediately crush them financially because for this to be a big
problem, high feerate transactions have to be replaced before they make it into
the next block.  And if only a small portion of the hashrate runs with this
patch, this will only happen occasionally.

**Mike Schmidt**: This might be a good opportunity to wrap up the first bullet
point of the newsletter.  I think Gloria is rejoining.  Hold on a second.  Okay,
Gloria should be back.  Thanks Brad and Stacie for chiming in on the topic.  Not
surprisingly, we didn't come to a resolution, but it did seem like we sort of
ended on an optimistic note there with the full-RBF discussion.

_CoreDev.tech transcripts_

I think we should move on to the next item in the newsletter, which is the
CoreDev transcripts.  There was a meeting of Core developers that happened
before the Atlanta Bitcoin Conference in Atlanta, and Bryan Bishop was kind
enough to provide anonymized transcripts for a handful of the meetings that
occurred there, I'd say about half of those meetings.  And myself and Adam Jonas
and Caralie from Superlunar were co-organizers for that meeting, and like I
said, Bryan Bishop was kind enough to transcribe some of those meetings so that
we can provide some context of what some items that were discussed at that
meeting were.  And we can kind of jump into those, I think, briefly, given that
we're already at the hour mark here, and just maybe give an overview of the
types of things that were discussed.

The first one here involves transport encryption, and this essentially
references BIP324 and encrypting traffic that is on the P2P Network, which is
currently unencrypted and in plain text.  And there are a lot of benefits of
encrypting that traffic, and there's also a lot of engineering that went into
this proposed BIP.  And I think if you're curious about that, jump into the
transcription.  And there may have also been a presentation at TabConf about
this.  I don't recall, but I think maybe that would be a good, high-level
summary.  Murch, I don't know if you want to augment that or if we should move
on to the next item from CoreDev?

**Mark Erhardt**: Maybe we can say one or two words about CoreDev itself.  So,
this is a meeting of people that contribute to Bitcoin Core.  So, it's basically
a working group meeting of regular contributors.  And what we tried to achieve
here is just get people in the same room and build some personal relationships
between people that usually only interact on a text basis with each other.  And
in our experience, it is that people who have seen each other and get to know
each other better just extend a little more understanding and goodwill to each
other, and it makes it easier to work together when we don't see each other for
most of the year.

So, what we talked about was just a range of topics that are currently
interesting to Bitcoin Core contributors.  There's of course the version 2
transport protocol for the network, which we just talked about, but it's also
been covered in a few newsletters already, and talked about quite a bit.

**Mike Schmidt**: Yeah, it might be worth noting that some of these topics for
these meetings were suggested before the meeting, but largely the majority of
the topics that were discussed, in an organized fashion and scheduled for the
meeting, were done so by the attendees and somewhat in a conference style, where
they pick the topics that are most interesting to them and an audience can show
up and contribute; or, there was a variety of spaces for groups to get together
and just review code, or have a whiteboarding discussion on a particular topic
as well.  Should we jump to the fee discussion, Murch?

**Mark Erhardt**: Yes, we can talk about the block space market.

**Mike Schmidt**: I don't know how much we want to get into that exactly, but
yeah, there was, as stated in the newsletter, a wide-ranging discussion about
transaction fees and interesting observation that the blocks are seemingly
almost always full but the mempool isn't; a debate about how long the fee market
would take to develop and associated concerns with that, and solutions that
could be deployed if a problem was deemed to exist in the future.

**Mark Erhardt**: Yeah, I think that's mostly stuff that's also been on Bitcoin
Twitter in the last year or so, where people are just pointing out that there
are potential issues in the long term future if there's not enough reward for
miners, and there's a linearity that appears when blocks become full and
suddenly people start bidding on being in blocks, whereas before blocks are
full, people can basically always just pay minimum feerate and wait it out.  And
we talked a little bit about that mostly phenomenologically.  I don't think that
we're currently working on any ways of influencing that significantly.

**Mike Schmidt**: The next transcription was from a discussion about FROST.  And
FROST is a threshold signature scheme using schnorr signatures.  If you think
about a more traditional Bitcoin script, a multisig where you can have a 3-of-5,
or something like that, but with schnorr signatures, so onchain, that 3-of-5
threshold just looks like a single signature.  And so there's been some research
into this FROST scheme and related, there was a presentation at TabConf about
ROAST, which is another sort of threshold signature scheme.  And so, if you're
curious about the details of either of those, there's a transcription for FROST,
and there's also a transcription for ROAST, and I think there may be videos
coming out from the TabConf team on ROAST.  I'm not sure if that one was
recorded or not.  Murch, any comments on FROST?

**Mark Erhardt**: Not really, I think we've covered it already a bit in the
past.  There should be a topic on the Bitcoin Optech page.  Generally, it's a
way of doing m-of-n in a way that looks like single-sig now.

**Mike Schmidt**: The next discussion item was about GitHub, and I think what
really prompted this was the fact that Tornado Cash was essentially deleted and
shut down from GitHub, and a lot of concern about if that were to happen for
whatever reason to the Bitcoin project on GitHub, if there was a plan for
backing up all of the data that isn't in the repository itself, but it is sort
of stored in GitHub.  That would be things like issues, comments, and other
materials that aren't actually part of the Git repo itself; is there a concern
there, and should there be a contingency plan; what would something like GitLab
look like, etc?  So, I don't know if there's any strong conclusions there, other
than it's worth pursuing looking into what contingency plan might be, should the
Bitcoin Core GitHub repository be shut down in some capacity.

**Mark Erhardt**: It's just generally uncomfortable that our main focal point
for development is controlled by a third party, and we're essentially at the
whim of that.  And if GitHub is down, we have issues.  Sometimes really long
threads with hundreds of comments on PRs just don't load properly.  And it would
be nice if we were able to control that better ourselves.  But honestly, there
is so much knowledge just in the comments on PRs and issues that are not easy to
reimport to other things, that it would be possible to archive everything we
have right now, but it would be very hard to recreate what we have.  Yeah, so
anyway, we're just thinking about what if, and trying to have some things in
place if we were to need to.

**Mike Schmidt**: The next item here was provable specifications in BIPS.  I
think the high level here is that something like a BIP is essentially lightly
formatted text currently with maybe some pseudocode specifying some details of
the BIP or the proposal or the specification.  And there's the potential to have
a more formalized way of documenting the BIP and having a specification that the
BIP itself could be provably correct, by being able to execute some of the
specification, as opposed to being just pseudocode or plain text.  Murch,
thoughts on provable specs?

**Mark Erhardt**: No, let's just move on.

**Mike Schmidt**: Okay, great.  There was a session, or a couple sessions, on
package and v3 transaction relay.  I think we covered this in a recent
newsletter and also Optech Recap, and Gloria's sort of represented some of that
today as well.  I don't know if it's worth getting into that too much since
we've covered it previously and we're somewhat short on time.  But, Murch, do
you have anything you'd like to say about that?

**Mark Erhardt**: No, I think we've talked about mempool policy enough today
already.

**Mike Schmidt**: Okay, Stratum v2.  So, this CoreDev meeting happened right
around the time that there was an announcement of progress along the Stratum v2
with open-sourcing some of the software and announcing that.  Essentially,
Stratum v2 is a software that essentially miners and mining pools run to
facilitate the mining of Bitcoin in a pooled environment.  And what we had
before, there was a proposal by BlueMatt, that was BetterHash, that enabled
individual miners to do transaction selection for a block.  And then there was
this other protocol that was being developed around the same time, which is
called Stratum v2, that had some other benefits in terms of authentication and
encryption between the miners and the pools.  And essentially, those groups got
together and now what we're calling Stratum v2 has come out of that.  So,
BetterHash is no longer but essentially those features, if you will, were rolled
into the Stratum v2 protocol.

The discussion here was a bit about Stratum v2 but also about the interplay
between Bitcoin Core and Stratum v2, and the advantages of moving some of the
logic in the pool servers to live in Bitcoin Core.  And so, there's a bunch of
interesting details you can jump into in the transcript.

**Mark Erhardt**: I think the most interesting point here is, so mining and
deciding what the content of blocks is, is one of the maybe most prevalent
centralization points in Bitcoin still.  There's very few mining pools and
essentially, we've had situations in the past where five or six people were on
stage at a conference and they represented 90% of the blocks being built and
content of those blocks.  And in the context of the Tornado Cash controversy and
also maybe the flash bots happening on Ethereum, we're seeing that it might be
interesting for mining pools to have a plausible deniability that they do not
decide the content of blocks, but they're just facilitating the collaboration of
many individual miners, and those individuals decide what they want to have in
their blocks.  And that could potentially be a valid reasoning in the context of
governments or other entities demanding that certain transactions are not
included in blocks, and the mining pools saying, "We don't decide what is the
content of blocks, but rather this individual, who we don't even know what
country they're living in, decided that".

**Mike Schmidt**: Yeah, I think that was the most interesting benefit.  And it's
interesting that the Tornado Cash controversy somewhat is motivating this
decentralization push within Stratum v2's adoption, although I think the
anticipation is that Stratum v2 would be adopted in a somewhat conservative
rate.  I think the quote estimated 10% at the end of next year being sort of a
success.

Then the last item that we have a transcription for from the Core developers'
meeting is strategies to getting your code merged.  And so this was a somewhat
less technical discussion, but involved some advice and successes from people
who have gotten larger projects merged and what worked or did not work for them.
You can see in the newsletter, there's some high-level summaries about breaking
bigger changes into smaller PRs and putting motivation and some context to the
PRs.  There's a bunch more from the transcription too, if you want to jump into
that.  Murch, anything you took away from the merging transcription?

**Mark Erhardt**: I think the underlying problem is just that in a volunteer-run
project, everybody is mostly scratching their own itches and working on the
things that they're interested in.  And of course, there is some collaboration
where people that are working on similar stuff have a short path to other people
that are working on it and asking, "Hey, how about you review this, I'll review
that for you".  But then there's also just things that fewer people are
interested in, or maybe not as pressing and urgent, and sometimes they can
linger for a long time.  And it is of course frustrating to the authors of such
work, especially if it's just important work but low urgency work, to get
review.  Yeah, I think that we might have made good progress on just giving
everyone a platform to talk about what they're experiencing and maybe just
communicating that there is no mal-intent there, but it's just sort of an
emergent experience of what everybody is working on.

**Mike Schmidt**: So, that wraps up the CoreDev transcripts.

_Ephemeral anchors_

The next item in the news section is ephemeral anchors, and so, instagibbs?

**Greg Sanders**: Oh, I'm here.

**Mike Schmidt**: Oh, he's present, good.  All right.  I know we talked about
this briefly when we were talking about v3 transaction relay a few weeks back,
but I know that you've come up with a post to the mailing list with a little bit
more meat for that proposal.  Do you want to give us a quick overview of that?

**Greg Sanders**: Yeah, I'll give it a shot.  So, Gloria's been doing some good
work on basically making transaction replacement, especially package RBF in that
context, reliable.  So, this is post if we have package relay, where you can
send multiple transactions in a package where the child pays for parent, then we
can do some basic package RBF where your version of the parent and child
replaces a prior version of the parent, right, so it double-spends this.  And
this is useful for a bunch of situations.  The primary situation people talk
about is the Lightning Network, with what are called the commitment
transactions, which is what has to get onchain in a fast time, otherwise
payments can essentially get robbed from your node if you can't get to chain
fast enough.

Let's see, from there, so if you've looked at and talked about the v3 proposal,
which is basically a way of saying, "Hey, transactions should be able to opt
into a smaller kind of package size, something easier to reason about", and also
a key point is that the replacer doesn't have to pay for a giant transaction
being replaced in certain circumstances.  And when you replace a giant
transaction that's maybe low feerate, you'll have to pay for all those fees in
an absolute sense even if it doesn't make sense incentive-wise for the miner to
not pick up something smaller at a higher feerate, but less total fee.

So basically, the package RBF seems to be more robust under this new v3 regime
that's being talked about, and there's a PR open.  But there are certain
circumstances where this isn't enough.  So, let's say that you both have the
same parent transaction in your mempool, and you want to fee bump.  So, under
the proposed rules, if the parent is the same, then the fee-paying child is the
thing that needs to get into the mempool, right, to bump the fee.  But in
certain circumstances, if it's a different child, like spending from a different
output from the parent, then it might hit what are called package limits.  So,
for example, in the v3 regime, a parent is allowed one child, one descendant,
and so if it's a different output being spent by you, it just can't get into the
mempool because it's not double-spending the other output spend, the other child
spend, so it can't even be evaluated, it's just tossed.  This generalizes, so in
general you're allowed 25 descendants for normal transactions, or 24
descendants, 25 including yourself, but this problem exists at all these levels,
essentially.

So, after a bit of thinking and kind of looking at what we can do in a
cost-effective way from an engineering perspective at least, this is one answer,
one potential answer, is where we can essentially add what I think Lisa from
Core Lightning (CLN) called a mutex lock.  So essentially, you have this output
that's special, let's call it an OP_TRUE output, an ANYONECANSPEND output, and
this output must be spent in the relay package.  So basically, any transaction
that's spending from the parent transaction must spend this output as well.  And
since this is like a mutex lock, where anyone spending from this transaction
must spend from this output, this allows us to do RBF again, right?  So,
basically, the child transaction can now RBF other child transactions
guaranteed.  And this gets around this package limit issue.

There's a bunch of nice properties of this, but one key that I think people
overlook is that if we can do this, then things like in the Lightning Network,
where we have to lock up all the outputs to make sure they're not spendable for
one block, we can unlock these again.  So, you can do things like, we can do
much better kind of smart contract composability, where we can send funds from
our smart contract straight to normal looking outputs, like merchants, like
Bitrefill, instead of having to worry about, "Oh, what if Bitrefill --" stand
in, because you're here, Sergej, but, what if the destination decides to spend
this output and make pinning a problem again, right?  So, this is one way of
getting around it.  So, I'll stop here and see if I butchered it horribly.
Murch, did this make any sense to you this time around?

**Mark Erhardt**: Yes, it did make sense to me.

**Greg Sanders**: Okay.  I think the mutex lock thing really helps.  It's a good
analogy, right, that computer scientists might understand.  It's essentially a
lock on being able to spend this parent output, parent transaction.  So, another
part of this, there's some restrictions on it.  Oh, the other nice thing here is
that this, I call it ephemeral anchors, because it's essentially taking this
anchor concept that Lightning Network and other people use to the extreme, where
instead of this output being bound to a single person, it's like an OP_TRUE
output essentially, which can be spent by anyone.  So, basically a watchtower or
anyone in the world could fee bump your transaction; as long as they increase
the feerate and they're helping you out, they can do it.  So, this is also a
nice kind of layer of separation.

For example, if inside the contract you don't want to have the same -- you know,
inside the kind of signing set up, you have, let's say, cold funds and you can't
efficiently RBF it, because you have to get these keys online again multiple
times, instead, you can bring outside funds to fee bump, without any key
material being required or passed around internally or externally.

**Mark Erhardt**: So basically, to summarize, this is an improved proposal to
replace anchor outputs and generally make sure that commitment transactions that
are used for any unilateral closing of channels gets streamlined so that the
commitment transactions can always be low feerate and the actual fees are
brought with the anchor transaction.  And since unilateral transactions are
already recognizable, we don't mind that they're labeled separately with the v3
label, and we always have a tiny, tiny transaction that we can create in order
to spend it.

**Greg Sanders**: Yeah, so thinking more about it, such as fingerprinting
argument, for example, Lightning Network splices, this has been a topic.  It's
that, how can we splice out funds or in funds from a channel and not get stuck,
right?  So, it turns out that you actually, I think, only need v3 transactions
to make this safe, which is great, because as long as you can bring the
commitment transaction to chain fast, then splices can be low, maybe they get
too low fee or something like that, you either RBF with your partner or just
wait.  And you can just take it, you can take your commitment transaction to
chain and it's safe.

The other kind of use case, I would say, is perhaps batched payouts.  If you
have a merchant just doing, 50, 100 payments or something like that at a time,
it's really annoying that if you send -- let's say you had 200 outputs.  You
send a transaction and then if a small subset of those users ends up spending
their coins in the mempool, or maybe one does it in a very large transaction,
you can't actually RBF and it's quite annoying that happens, or CPFP.  So, in
this context maybe it'd be useful, because then you could, as a batched wallet,
you can kind of just assume that you'll be able to RBF at any point.

**Mark Erhardt**: Sergej seems to have a point.

**Sergej Kotliar**: This sounds very interesting.  I mean, it sounds like it
does the same stuff as the ANYPREVOUT stuff, but am I understanding correctly
that this doesn't actually require any soft fork?

**Greg Sanders**: Oh yeah.  So, this is kind of all backup for some context,
right?  So, I've been working on a proposal eltoo using ANYPREVOUT, just as like
a prospective implementation.  So, I've been writing the spec for it and an
implementation in CLN.  And while I was doing this, I was like, "Man, eltoo is
going to be hosed if we can't actually RBF things or pay for fees, because the
symmetrical state makes them even more dangerous not to have this fixed".  So,
basically it motivated this use case here.  But the good news is, as I think
Murch noted, that it's all applicable today.  If somehow I waved a wand and I
got v3 and ephemeral anchors in policy-wise, then we could redo how Lightning
transactions are formed.  And there's a splicing proposal going on now and that
would just become more robust, essentially, in place.

**Sergej Kotliar**: So, this is bigger than Lightning.  I mean, this sounds like
an anyone-can-bump type of output, which I would argue almost all transactions
should have because you never know if you're going to want to bump it, for
example, for an external transaction bumper service.

**Greg Sanders**: Exactly.  So, it's like a watchtower system on steroids, so to
speak.  You as the wallet user can spend your own ephemeral output with the
other outputs, it's fine.  But you can also use an entirely external system to
bump.  Yeah, and so here's a caveat.  So, under this proposal, it still doesn't
work if you want to do something like ANYONECANPAY, but that's kind of an
obscure use case.  So, I would say for a normal --

**Sergej Kotliar**: What's the difference?

**Greg Sanders**: So, the problem is you can still get pinned if additional
inputs can be added to your transaction without your say-so, so to speak.  So,
for example, if you're doing a coinjoin, it still doesn't help completely,
because other people can do stuff with their inputs and get you stuck.  So, this
is not orthogonal, but only tangentially related to the full-RBF discussion.

**Sergej Kotliar**: So, ANYONECANPIN, basically!

**Greg Sanders**: Yeah, so it's because if you have a coinjoin-like scenario,
even if we had full-RBF, I'm waving a wand, full-RBF everywhere, you still have
the issue where, let me think about this, that the counterparty double-spends
their input, and then you have to basically RBF or CPFP to overcome it, right?
So, there's still pinning vectors, even if it's smaller or different, and so
it's harder to reason about it as a wallet person.  But as we know, there's
coinjoin, there's --

**Mark Erhardt**: But you said generally, if you're doing a -- go ahead.

**Sergej Kotliar**: I'm sorry, maybe I was lagging.  I was saying that outside
of pinning, this would be very useful just for bumping.  I mean, we call it an
ANYONECANBUMP transaction, and it's actually very useful, because very often you
have transactions that you need to bump.  Somebody else paid you, they paid you
from Coinbase or whatever, or Alice is paying Bob and Carol wants to bump it.  I
mean, there's a lot of different use cases for this.

**Greg Sanders**: Yeah, so think of it like an opt-in version of transaction
sponsors, which is Jeremy Rubin's proposal that was at the consensus layer.
It's also useful, I mean, you can look at like the Core wallet code.  When it
comes to RBF, because it's so hard to think about, that if one of your outputs
is already swept somehow or spent, you're not allowed to RBF it because it's
hard to reason about what exactly it's going to cost you as a user.  And convey
that to the user, I have very complex settings on this.  But with this, under
this regime, you'd have a bound, thanks to v3, you'd have -- sorry I'm
conflating, these are complementary things here.

The v3 allows you to RBF more confidently from a fee perspective, which is very
nice.  And then if you have this ephemeral anchor, then it allows this external
bumping regime, as you mentioned.

**Mike Schmidt**: All right.

**Greg Sanders**: To be clear, v3 is awesome by itself; it's just complementary.

**Mark Erhardt**: Cool.  Did you wrap up; is this all you wanted to say about
it?

**Greg Sanders**: Sorry, could you say that again?

**Mark Erhardt**: Okay, I think we're through with this, right?  So, I think
we're moving on to the Selected Q&A from Bitcoin Stack Exchange, and given that
we're already 90 minutes in, we're probably going to move a little more quickly.
But also, these are short topics, and we're almost through, because only Release
candidates and Notable code changes are left, and they are small to run.

**Mike Schmidt**: Do you want to do rapid-fire, Murch?

_Why would someone use a 1-of-1 multisig?_

**Mark Erhardt**: Okay, sure.  So, on Stack Exchange, we recently had a question
about a crazy 1-of-1, and somebody asked, "Why would anyone ever want to do
multisig 1-of-1?"  And we still cannot answer that, but we may or may not have
identified one service that is using that.  So, there was a question about that.

_Why would a transaction have a locktime in the year 1987?_

Next, there was a question on why a transaction would have a locktime set to
1987.  It probably stems from how the Lightning Network BOLT3 spec allocates the
locktime field.  And so, there's potentially a little bit of a fingerprint here
for certain Lightning interactions, but the mystery seems to have been resolved.

_What is the size limit on the UTXO set, if any?_

Somebody asked, a very long time ago actually, what the size limit of the UTXO
set is.  And Pieter mentioned that the UTXO set is actually not limited, but we
also found out that the UTXO set growth is essentially limited by the block
space.  Do you want to continue?

**Mike Schmidt**: And that you calculated with some assumptions that it would
also take 11 years for everybody on Earth to have their own UTXO!

**Mark Erhardt**: Which altogether is a terrible idea, because they wouldn't be
able to spend them anytime soon either!

_Why is `-blockmaxweight` set to 3996000 by default?_

**Mike Schmidt**: The next question here is, "Why is the -blockmaxweight set to
3,996,000 by default?" instead of the 4 million weight units that is the limit
according to the segwit rules.  And sipa explained that that buffer difference
was for space to allow a miner to add a larger coinbase transaction essentially
with additional outputs.  So, there's a dummy coinbase transaction that's
created by the block template, and the miner can essentially add additional
stuff into that transaction and not worry about hitting that weight limit.

**Mark Erhardt**: Yeah, it's arguably a little big because most coinbase
transactions are less than 200 vbytes.  But back in the day, some mining
services would pay out their miners directly with coinbase transactions, and
then there was a little more space.  So, if you want to make more efficient
blocks as a miner, you might want to set that a little higher.

_Can a miner open a Lightning channel with a coinbase output?_

**Mike Schmidt**: Murch, here's a question you can answer, "Can a miner open a
Lightning channel with a coinbase output?" and if so, what are the
considerations?

**Mark Erhardt**: Theoretically, yes, but it would be a terrible idea because a
Lightning channel depends on having a backout strategy signed by your
counterparty.  So, if your txid changes, you have to renegotiate with the
channel partner.  And since in coinbase transactions, we very frequently change
the content of the coinbase transaction, because every time we change what
transactions are in a block or increment the extra amounts, or other things like
that, we change the txid of the coinbase transaction, so we would invalidate the
reversion of the channel open that allows us to take out our own money; and
especially with a coinbase reward, that's a fairly big amount of money.  So, I
would not recommend anybody try this.

_What is the history on how previous soft forks were tested prior to being considered for activation?_

**Mike Schmidt**: And then the last question from the Stack Exchange this month
was, "What is the history on how previous soft forks were tested prior to being
considered for activation?"  And so, this is essentially a quote of a post on
the mailing list from AJ, which sort of synthesizes what testing happened before
activation of P2SH, some of the locktime stuff, segwit, taproot, etc.  So, if
you're curious about that, jump into the details of AJ's post and he sort of
outlines all of that, which is somewhat interesting from a Bitcoin history
perspective.

_LDK 0.0.112_

In terms of releases and release candidates, LDK 0.0.112 is released.  I didn't
see anything super-noteworthy for our discussion there, but feel free to jump
into the release notes to see if there's a fix or an API addition that's
interesting to you.

_Bitcoin Core 24.0 RC2_

We've talked about Bitcoin Core 24.0, the RC1 for a few weeks, and RC2 now for a
few weeks, and the testing guide.  And then we also put in the disclaimer about
mempoolfullrbf, which we beat to death the first hour of this discussion.
Murch, any comments on releases?

**Mark Erhardt**: Well, no.  Let's move on!

_Bitcoin Core #23443_

**Mike Schmidt**: And just a couple PRs from this newsletter this week.  The
first one, Bitcoin Core #23443, which is an exciting new P2P message that is the
first of a few that will be involved to in order to support erlay.  I think
we've talked about erlay a couple of different times, but it's essentially a way
to propagate transactions on the network in a more efficient manner, by sort of
batching those together and reconciling that with your peers instead of right
when you get the transaction, propagating it, you sort of batch that and then
send sort of a --

**Mark Erhardt**: Yeah, instead of telling everyone about the new transaction
that you heard about unilaterally, or individually, you compare the table of
contents of your mempool with the table of contents of somebody else's mempool,
and then just reconcile the differences.  Gloria?

**Gloria Zhao**: Yeah, I just wanted to say erlay is not in yet.  So, this is
only signaling, and the rest of the erlay -- I've seen hundreds of people on
Twitter who thought that erlay was in.  And I think it's very dangerous for you
to pull from master right now and start running what you think is an erlay node,
because it's not an erlay node.  It's just going to say send transaction
reconcile (sendtxrcncl), but it doesn't actually do transaction reconciliation.
So, do not pull it from master and run it right now.  It is not doing erlay.
Just wanted to say that.

**Mike Schmidt**: It's essentially the handshake of saying, "I support erlay and
I support sending and receiving" and then nothing happens.

**Gloria Zhao**: Yes, exactly.  Please wait until there's a release where erlay
is all in there.  So, it can be enabled, and then you're signaling that you can
do erlay, but you can't actually, and then you get disconnected.  So, please
don't do this.

**Mark Erhardt**: There were some gaps in what you were saying.  But basically,
this is just saying it can do erlay but doesn't actually have all the
functionality, so don't run it with that parameter right now.

_Eclair #2463 and #2461_

**Mike Schmidt**: All right, and then the last PR, which is two PRs, they're
both from Eclair, and it's updating Eclair to require funding inputs to opt-in
to RBF, that those inputs also be confirmed.  And the purpose of that is to
ensure RBF can be used, and that essentially Eclair users can't be burned of any
of the fees contributed.  This is related to the dual-funding stuff we've been
talking about the last few weeks.  Murch, any feedback on these Eclair PRs?

**Mark Erhardt**: No, it seems pretty reasonable to require that all the
participants of multiparty transactions only use confirmed inputs, but if we had
full-RBF, that might be easier!

**Mike Schmidt**: We should have a discussion on that sometime!

**Mark Erhardt**: Maybe one day!

**Mike Schmidt**: All right, well thanks everybody for hanging in there for an
hour and 40 minutes, I think our new record for a duration of an Optech Recap
session.  And thanks to Gloria for joining us, Sergej, instagibbs, and questions
from Brad and Stacie.  And if anybody has a question, you have ten seconds to
request speaker access.

**Mark Erhardt**: Well, let's make it 30, but yeah, right now, otherwise I'm
going for lunch!

**Mike Schmidt**: Yeah, I guess it's past lunchtime there.

**Mark Erhardt**: Yeah, we got our lunch at 12.00pm.  It's getting cold and
waiting for me.  See the sacrifices I'm making for this?

**Mike Schmidt**: It's for Bitcoin!

**Mark Erhardt**: Oh, okay.

**Mike Schmidt**: Okay, maybe not then.  All right, thanks everybody for joining
and we'll talk to you next week.

**Alexandra933**: Sorry, I was muted.  Super-quick, because I know everyone
wants to wrap up.  Just referring back to GitHub, I think it's a really good
idea to do something in terms of backup.  I can tell you from experience, a
group that I work with has used Gitea and it's actually pretty good.  So, if
people are already looking at GitLab, maybe consider Gitea as well.  As far as I
know, it's fully free and open source, but it's a good one.  That's it.

**Mike Schmidt**: Excellent.  Thanks for that recommendation.  All right, thanks
for joining, Murch; thanks, Gloria; thanks, Sergej.

**Mark Erhardt**: All right, see you all next week.

{% include references.md %}
