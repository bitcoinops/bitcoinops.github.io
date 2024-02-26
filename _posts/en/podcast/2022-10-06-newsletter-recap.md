---
title: 'Bitcoin Optech Newsletter #220 Recap Podcast'
permalink: /en/podcast/2022/10/06/
reference: /en/newsletters/2022/10/05/
name: 2022-10-06-recap
slug: 2022-10-06-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao and Rene
Pickhardt to discuss [Newsletter #220]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-15/347178522-44100-2-4bc3661db1e5e.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Recap #220 Newsletter, and
I've shared quite a few different tweets, some from our announcement of the
newsletter, and also the BitMEX research piece that René put together, and also
some materials to test the Bitcoin Core RC as well.  So, feel free to follow
along with some of those tweets that are part of this Space.  Quick
introductions, Mike Schmidt, contributor to Bitcoin Optech and also Executive
Director at Brink, where we fund open-source developers working on Bitcoin and
Lightning stuff.  Murch.

**Mark Erhardt**: Hey, I'm Murch, I work at Chaincode Labs doing Bitcoin-y
stuff.

**Mike Schmidt**: Gloria, do you want to introduce yourself?

**Gloria Zhao**: Sure, hello, I work on Bitcoin Core and the Bitcoin Core PR
Review Club, and I guess Optech.  I'm sponsored by Brink.

**Mike Schmidt**: René?

**René Pickhardt**: Okay, so I'm René Pickhardt, LN Researcher and Developer,
currently working at Norwegian University and partially sponsored by BitMEX.

**Mike Schmidt**: Great, and thank you both for joining us today to talk about
some of your mailing list posts, which we can jump right into, I guess.  We have
two news items this week.

_Proposed new transaction relay policies designed for LN-penalty_

The first one is proposed new transaction relay policies, and that's based on
some work that Gloria has done, and then most recently, a post to the mailing
list about some of that work and some updated discussion there.  Gloria, it
might make sense for you to set the context a bit for the listeners of why there
needs to be any change to relay policies, and how that fits into some of the
work that you're doing on packages, etc.

**Gloria Zhao**: Yeah, sure.  So, I spend a lot of time thinking about mempool
policy and package relay.  Part of it is just to have mempool policy that works
for a base layer.  But I also spend a lot of time thinking about what works for
our L2 ecosystem.  So, we have a lot of transactions in these contracting
protocols, such as the LN, and they have essentially this unique pattern, which
is you have a contract where you and your counterparty have locked yourself into
some spending conditions, and then you have some kind of time-sensitive
transaction that you need to broadcast and confirm in order to make sure that
your spending path is executed.

So, for example, let's say your counterparty tries to cheat you with an old
Lightning channel state.  You have within, I don't know, a day or a week to
broadcast your transaction that gets your money back.  And that's kind of the
general problem that we're trying to solve.  In general, it's like, okay, what
we have is the time at which we sign this transaction and therefore decide on
the fees of the transaction, is different from our broadcast time.  The signing
time and broadcast time are sometimes weeks or months apart.  And so, you either
need to have fortune-telling abilities to be able to see what feerate you're
going to need to broadcast at, or you need a way to adjust the feerate at the
time of broadcast.  So, hopefully that's clear.

I guess there's two kind of flavors of doing this.  So, one is what LN-penalty,
which is the current, I might say the wrong word here, settlement or transaction
format used by Lightning, where you use anchor outputs on your pre-signed
transaction, and then at broadcast time, you adjust the fees by attaching a
child to that anchor output.  And the other flavor is, I think, not used by
anyone because it doesn't work, is to sign your transaction with ANYONECANPAY,
which means that at broadcast time, you're able to bring in more fees by adding
inputs to the transactions.  And these two flavors each have their own
challenges and their own pinning attacks.  It's probably easier, I say this may
be easier, to do the first version, which is anchor uploads and CPFP and package
relay.  And so that's what we're trying to work on.

Last September, I posted to the mailing list a set of mempool policies that
should work, and it included a BIP125-based RBF policy for packages.  And then
we realized, actually, RBF is pretty broken for this particular use case.  So in
January, I posted, "Hey, RBF's broken.  Here are some pinning attacks, and
here's where it really hurts".  And then we went around in circles trying to
figure out a way to fix them, but it's very difficult.  And so this policy is
kind of like, instead of fixing RBF, which is a whole can of worms, why don't we
just add a tiny little carve out, essentially, very similar to the CPFP carve
out, if you know what that is, where you just add a very, very simple set of
rules that only LN and these types of transactions will ever use, and it's not
super-invasive, but it fixes the pinning attacks.  And so that's what this
proposal is, and we carve it out of v3, which is a currently non-standard
version.  So right now, if you were to broadcast a transaction within v3, it
would just get rejected.

So, the idea here is we're not restricting the current set of rules.  It's a
relaxation of the current policy.  When I say standard, I mean default Bitcoin
Core policy.  And so basically, it solves this one pinning attack, which is the
replacement needs to pay "new fees", as in essentially, we're going to evict the
original transaction, but we won't count those fees because we're trying to be
DoS resistant.  And so we're like, "Okay, you need to pay new fees for us to
consider this transaction".  However, the pinning attack is, let's say your
counterparty broadcasts this transaction that you're going to need to replace,
aka like their commitment transaction, which conflicts with your commitment
transaction, and theirs represents an old Lightning channel state.  And then
they attach this gigantic child to it, and it's high fee, but low feerate,
because it's huge.  And so it's not CPFPing their commitment transaction, it's
not helping it get confirmed, but it is hugely increasing the amount of fees
that you need to pay in order to replace these two transactions.

So, the fix is this, it's extremely simple.  It's literally just, you're not
allowed to have a big descendent, that's it.  And so the idea is, you make your
commitment transactions v3, these pre-signed transactions, and then nobody's
allowed to attach anything large or any more than one child to that transaction.
And then, so when you go to broadcast your commitment transaction, you know that
you're not going to need to replace some gigantic descendent.  And so now you
have kind of an upper bound on what possible fees you might need to pay in order
to get a replacement to happen, if there so happens to be a conflicting
commitment in the mempool already.  Hopefully that makes sense.

**Mark Erhardt**: Yeah, it does.  I was wondering, it was a very interesting
read, and I really enjoyed also the expected questions section at the bottom
because you answered some of my questions immediately.  Maybe let me get into
one of them.  So, now that we explicitly label transactions as being something
completely different that nobody else uses, isn't that a privacy fingerprint?

**Gloria Zhao**: Yeah, exactly.  Sorry, can you hear me?  Yeah, you can, okay.
So, the first thing I probably should have plastered in big, bold letters is,
not everyone is supposed to be using these versions.  It's very restrictive for
a reason.  This is basically only to be used for LN, and not just only in LN,
but also just the commitment transactions for unilateral closes.  And then the
question is like, "Okay, but then isn't it like really easy to tell that these
transactions are LN transactions?" because we care about privacy.  The whole
point is, you've got some privacy when you're when you're using something that's
offchain.  If you come onchain and it's very obvious that it was LN, that's a
problem.  So, if you're broadcasting unilateral close, you're like exposing your
Hash Time Locked Contract (HTLC) scripts, etc, and that's very obviously an LN
transaction.

So, whatever fingerprints that you're getting from v3 is no worse than the
fingerprint you already get from the fact that you're revealing the script which
contains HTLCs and stuff.  So, yeah, I expected that to be the first question.

**Mark Erhardt**: Yeah.  Also, what I should have maybe done.  So basically, you
introduce a new version format, v3, and it has a whole different set of
replacement rules than what we currently use.  But it has a few caveats, which
is the child can only be small, there can only be one child, v3 transactions are
always replaceable and they can only have v3 children.  And what this allows us
to do is to basically, now we have only a single child on the commitment
transactions and it will always be small, and plus it's really easy for the two
counterparties to replace each other.  And it doesn't matter that we have to
label them, because they are already obviously closing transactions.  That's my
read so far, at least.

**Gloria Zhao**: Yeah.

**Mark Erhardt**: Could you maybe also go a little bit into why we would want to
maybe have OP_TRUE or ephemeral dusting packages?  Is that related to this
directly?

**Gloria Zhao**: Yes.  So essentially, if we have package relay, when you're
signing this transaction, you just put zero fees on it, or like 1 satoshi per
vbyte (sat/vbyte) or something.  And that can be pretty powerful, because I mean
you'll never overestimate fees, because you don't have to put any when you're
signing them.  And then there's this idea of like -- okay, so let me backtrack.

So right now, we already use anchor outputs in the event that you need to fee
bump your commitment transactions at broadcast time, right?  And you have two
anchor outputs, because each counterparty needs to be able to fee bump any
commitment transaction.  So, even if it's your commitment transaction and you
broadcast it, right now, since there's no way for the counterparty to replace
it, if they want that to confirm faster, they need to be able to attach a child
for CPFP.  But in the package relay world where they can replace each other, you
only need one anchor output.  And also, if the commitment transaction is going
to be zero fee, then you're always going to be using this anchor output.

Then they're like, "Okay, well, why don't we make this anchor output as cheap as
possible?" because you're always going to spend it, you're always going to eat
the cost of creating an output and then spending it, so an OP_TRUE is really,
really tiny.  And also, either counterparty can just spend it.  So it's very
easy, I guess, to do it this way.

**Mark Erhardt**: Right.  So, let me just recap a little bit.  The commitment
transaction is a unilaterally broadcast transaction that is pre-signed by the
counterparty, and it allocates the current balance of the channel to each party.
So, there's two outputs that transport the value, and then there's a third and
fourth output right now, the anchor outputs, that allow each of the two
counterparties to attach a child transaction to bump this commitment
transaction.

In this proposal, instead, we would have a single anchor output, which uses an
OP_TRUE as the scriptPubKey, which means that the scriptPubKey is tiny, it's a
single byte, I guess, maybe 2 bytes, and the amount, which would probably be
zero, I guess.  And then in the input, you do not need witness data, you do not
need a signature, because the script is true by itself, so you don't need an
unlocking script, no input script that satisfies the scriptPubKey because
OP_TRUE is already a true statement.  So, the input itself would only reference
which UTXO you are spending for 36 bytes, and that would make the bumping less
expensive; and since you always would use the anchor output, because the
commitment transaction itself would no longer have any fees, you don't add
useless data because nobody wants to spend this zero value OP_TRUE output,
except if they want to bump the transaction to pay more fees.

**Gloria Zhao**: Yeah, exactly.  And then hopefully, this is not me revealing
any top-secret stuff, but I think Greg is also interested in the eltoo scenario,
where there's a bit of trickery that needs to happen, not trickery, you need to
do some tricks in order to add fees.  There's no way I'm going to do this
justice, so just look up "leaking amounts from the channel".  And so, it would
be nice to be able to have this output just be zero in value, and then you
attach a spending transaction at broadcast time.  You're going to have to do
this, especially if there's zero fees on the transaction.  But right now, if you
were to do that, if it's a spendable output, you can't be below the dust limit,
which is where the leaking problem comes in.

So it's like, "Okay, what if we can guarantee that this output is going to be
spent within the same block?"  And I think I should also give credit to Ruben,
who also suggested this to me a year ago, I think, where it's kind of this neat
trick to be able to have dust, but not really have dust.  So, the ephemeral
output is the zero-value output that you put on the pre-signed transaction that
you guarantee is going to be spent within the same block.  Why can you guarantee
that?  Because it's needed in order to CPFP this zero-value transaction.  Yeah,
so that answers the question there.

**Mark Erhardt**: Yeah, one of the big criticisms with the anchor outputs was,
since you needed an anchor output for both sides, every time a unilateral close
happened for a commitment transaction with anchor outputs, one of those two
anchor outputs would remain and would pollute the UTXO set.  And by having a
single OP_TRUE ephemeral output that is used as an anchor and that always is
used to pay the fees, you no longer have this pollution of the UTXO set.

**Gloria Zhao**: Yeah, and I think actually it can be one or two of them that
don't get spent, because right now they tend to slightly overestimate on the
feerates.  And so, sometimes you just won't even use those anchor outputs, and
then now you have these like really low-value anchor output UTXOs just hanging
out in the UTXO set.

**Mark Erhardt**: Cool, thanks.  René, since you also do some stuff with LN, do
you have some thoughts on this proposal?

**René Pickhardt**: No, I don't, to be frank.  I was just listening to Gloria,
and I mean I listened to the works that she's doing before and I was thinking, I
really need to understand Bitcoin better and not only focus on second-layer
stuff and reliability of payments, to actually more carefully understand what's
going on.  But this entire Bitcoin space is so complex, so no, I don't.

**Mark Erhardt**: All right, cool, thanks.  Back to you, Mike, I guess.

**Mike Schmidt**: Yeah, I had just one more follow-up question for Gloria, which
is, I see there's been a few replies to your mailing list posts, and I'm sure
you've spoken with people out of band as well.  What has the feedback been from
folks that have given you either public or private feedback on this idea?

**Gloria Zhao**: So, this proposal kind of is the result of feedback.  So
really, most of this stuff is not invented by me.  It's just me shooting down 99
ideas and then being like, "Oh, this one might work".  And so, I have kind of
the opposite feeling of René, where he's like, "Oh, I want to understand Bitcoin
better", and I'm like, "I want to understand Lightning better", because
essentially what I run into all the time is like, "Well, the main users need to
be okay with this".  So, this was kind of born out of everyone being like,
"Well, there's no solution for this RBF problem".  And then I think BlueMatt and
Suhas suggested like, "Well, why don't you just like limit the descendents?
That should fix it".  And then, I kind of iterated on that.  I was like, "Okay,
this is even simpler".  And then I think AJ, Greg, and t-bast, there's this big
thread on that package RBF PR, where it's slowly narrowed down to this.

So, just to give credit where it's due, and it's not like me cooking up this
idea.  It's me being like, "Well, this might work", based on a lot of things
that a lot of people have said.  But I think the feedback so far is like, "Yeah,
I think this could work".  We should still go for a long-term solution, but I
don't even see the general outline of one yet.  And so, I think it's mostly
positive, it's like, yeah, this should solve things for us.

**Mark Erhardt**: With long-term solution, you're talking about RBF in general?

**Gloria Zhao**: Yeah, like a general RBF overhaul, because to solve this
generally, we have to completely throw out the current paradigm, which is like,
"Oh, the replacement needs to pay new fees"; that's like why we have this
pinning attack, right?  It's like, "Oh, if we have to pay new fees then that fee
might be really high".  And so, we need a different way of thinking about how
we're thinking about the incentive compatibility plus the DoS resistance of our
current RBF policy.  And so, it's not just like, "Oh, what if we just use
ancestor feerate instead?"  This is like, we need to kind of reinvent the
framework.

**Mark Erhardt**: And it's so simple, full-RBF for everything.

**Gloria Zhao**: That's a signaling problem, right?

**Mark Erhardt**: Just kidding!  Let's not open that can of worms!

**Gloria Zhao**: All right, yeah.

**Mike Schmidt**: Great.  Gloria, thank you for walking us through that.  It's
always great to hear from the folks that are crafting these proposals, the
problem, the solution, and the considerations that went into it, so thanks for
jumping on.  If you have time, it would be great to have you opine on a couple
of other items from the newsletter later.

**Gloria Zhao**: Yeah, I'll stick around for Erlay and for the RC.  Sorry, I
just interrupted, didn't I?

_LN flow control_

**Mike Schmidt**: No, that's great.  Thank you for sticking around.  René, I
know you have a Lightning-Dev mailing list summary of some of the research
you've done, which I think the bulk of the research was outlined in a BitMEX
research article.  I guess I'll leave it to you of where you want to provide an
overview and maybe some background on the research you've done, what you're
trying to achieve, and then some of the conclusions of your research.

**René Pickhardt**: Sure, yeah.  So, the research basically starts at payment
delivery, right?  When you have an LN node and you want to make a payment on the
LN, you have to somehow find a flow through the network that hopefully settles
the payment.  And as we all know, we have a certain amount of uncertainty about
the liquidity in remote channels.  So what this means is, if you decide to send,
let's say, 100 satoshis through the network and use the channel that, for
example, Gloria and I maintain, and you ask me to forward the 100 satoshis,
maybe that would not work because maybe all the liquidity is currently on
Gloria's side.  And this is a problem.

So, what happened about one-and-a-half years ago is that I published two papers,
where we provided a probabilistic framework to conduct payments.  And one of the
main criticisms that people had with our research is that we assumed that the
liquidity in the payment channel is uniformly distributed.  So, what this means
is that every split of the balance in our channel has the same likelihood.  And
using this distribution, the math turned out to be really simple, and we could
solve the problems, but people running LN nodes kind of know that this is not
true; if you observe your channels and you don't particularly care for them, you
will realize that a lot of the times, the liquidity is either on one side or on
the other side of the channel, which is a phenomenon that we call "drain".  So,
the question that I was basically asking myself is, can I be more precise and
can I more precisely predict what the distribution of funds would look like?

I was starting this research mainly in the beginning of this year, and I had
this blog article about Price of Anarchy where I tried to model this with random
walks but I couldn't find a mathematically closed formula.  So, over the summer,
I started looking into Markov models and Markov chains, and with those I was
actually able to create a fairly simple mathematical model that would predict
how the liquidity in a payment chain is being distributed.  And it seemed to, as
far as I could tell, confirm what you could observe in the network, and I was
actually trying to write down that piece of math and research in a blog article.
And while doing so, I realized that there is one parameter inside these Markov
models that we tune, which is the htlc_maximum_msat, which basically defines the
size of payments that we allow ourselves to have in the channel.  And already in
the blog article in May, I realized that when you change this value, the payment
failure rate will either increase or drop depending on how you select this
value.

But the big mistake that I did at that time is that I always assumed that this
value would be the same in both directions.  And when I actually had the blog
article finished, I made a note in the abstract and said it would actually be
interesting to investigate what happens if I select this value differently in
both directions.  So, instead of publishing the blog article, I nerd-sniped
myself and said, "Well, I really should investigate this first".  And then I
realized, well, the payment failure rates on the LN could potentially drop quite
a bit if node operators could start doing that.  So yeah, and then I was
basically trying to make sense of this, and I very quickly realized that
basically what I built there is a valve.  And a valve is something that in fluid
networks we have been using for, I would say, a century, right?  I mean, if you
have a water pipe in your home, you don't want the water to flow all the time
and drain, so you close the valve and then the water cannot flow.  And a similar
concept can be applied to the liquidity in the LN, which just in general should
give us a better flow control.

So, yeah, this is basically the context of how these results emerged.  I'm not
sure if that answered your question, or if I just opened too many topics!

**Mark Erhardt**: No, that sounds great.  Let us dig into that a little bit.  So
if we, for example, have a channel with a very well-connected big node, and most
people want to send through that node, we might expect that more money goes
towards that big node.  So, my understanding is that maybe we would allow, say,
1000 sats in the direction from that big node through us, but only 500 sats in
the other direction to that big node; is that sort of the general idea?

**René Pickhardt**: Yes, that's pretty much the idea.  So, what you could assume
is that all the requests that you are -- imagine you have a pipe network of
fluids, right, so all the payment requests that you receive on a channel, you
could pretty much draw the picture as this is something like pressure.  So, if
there's a lot of pressure, what you basically do is you throttle the throughput
to the network so that you don't deplete.  So, exactly as you said, if you more
or less statistically see twice as much traffic going in the direction of your
peer, you would basically set your max HTLC parameter half the amount than the
peer would set in your direction.  When you look in the details, there's a
little bit more to it, like it's not that easy, but it's a problem that is
certainly solvable depending on your particular taste of how you want to choose
this.

Generally, the smaller these valves are, the smaller the expected error rate is,
but that also makes a lot of sense.  If you have your valve open with the
capacity of the channel, then one single payment can already drain everything
and the second payment that comes cannot be forwarded.  Whereas, if you only,
let's say, allow 1% of the channel capacity at a time, well, you can at least
make 100 payments before the channel is being depleted.  But since there will be
some payments flowing back in the other direction, there's a high chance that
the channel becomes balanced.  So, yeah, that's the general idea.

One of the things that I was able to observe is that when you set up your valves
properly, the liquidity distribution actually starts to be uniform, which is
also very nice, because then people who want to send payment flows can actually
use this in their probabilistic payment delivery schemes.  Because as I
discussed before, this is a very easy distribution where the math actually works
out pretty well.  So it has a lot of advantages.

**Mike Schmidt**: René used the analogy of the valves and if I'm filling up a
gallon jug and I could have the tap open all the way or I could have the tap
open just a little bit, this sort of leads to ZmnSCPxj's, I guess, criticism in
response to this, which is, "Well, I guess I'll just leave my gallon jug there
for a longer period of time and just let it drip to fill that gallon, as opposed
to filling it up quickly with a higher throughput".  I know that there was some
discussion on that, so maybe you can take that analogy and how that could
potentially be addressed?

**René Pickhardt**: Yes, so I would say my main argument, or my main
counterargument on this, is that a person who wants to pay somebody wants to pay
quickly.  And let's say you close your valve to only allow 1 satoshi payments at
a time and somebody wants to send a bitcoin, well, they would have to basically,
for more than a day, send out HTLCs and hope that I will forward them to
eventually have the bitcoin being sent.  So, the reason why we currently do
multipart payments, which are nothing else than payment flows, is because you
want concurrently across several paths to send out the money.  So, if you close
your valve, the sender will most likely choose a lot of other paths for the
residual amount of what they can actually get through your channel, because
otherwise they're going to have to wait a lot.

That being said, if your channel is the cheapest and they bring a lot of time,
they can certainly use these kinds of mechanisms to drain your channel.  That
would be possible, yes.  But I mean, channels can already be drained, right, so
it's not getting worse.

**Mike Schmidt**: Is it the natural latency of the quantity of HTLCs that would
be needed, or is there some sort of rate limiting that would also be applied on
top of that to slow things down?

**René Pickhardt**: Well, I think that depends on implementations and how they
want to do certain things, right?  It's not defined in the protocol.  That's why
I was actually a little bit hesitant if I wanted to put this on the mailing
list, because to some sense, it's not like any protocol change that is being
directly related to this.  I mean, any node operator can right now take the
implementation of their choice and can decide if they want to include some rate
limiting or if they want to include some other mechanisms.  But yeah, so I mean
that really depends on your taste, I would say.

But if you like, the main assumption here is that payments usually want to be
atomic, right?  So what this would mean is that somebody who wants to drain your
channel in this way would have to actually include all HTLCs into your channel
before they can settle the payment.  And what you could do in your node is if
you see a second HTLC with the same payment hash, you could basically say, "No,
you already got your stuff".  So, then they would already have to start doing
something differently.  So, they do some kind of magic where maybe the shards
change the payment hashing preimage, but then again, you only have 483 HTLC
slots in your channel anyway.  So, if your valve is closed enough, they won't be
able to drain a large amount of liquidity.  And again, they could ask
themselves, do they really want to go through this hassle of overusing your
channel?

So, yeah, there is certainly the possibility to game this, but I would argue
that congestion attacks and spamming and DoS attacks are something that people
can already do, so as I just said, I don't think it's getting worse.

**Mark Erhardt**: So basically, there's two ways of limiting the forwarding
capacity.  On the one hand, there is a limit of how many HTLCs can be open in
parallel.  On the other hand, there is also a maximum amount of the sum that the
HTLCs can be worth, so either of those could of course be used to limit how much
-- I'm getting a little background noise.  Okay.  Either of those could be used
to limit how much can be opened at the same time.  And if you want to make an
AMP payment or a multipath payment, and they could have a couple of maybe HTLCs
through you at the same time, until your limit is reached either in the count,
in the number of parallel HTLCs that you're allowed to have the same hash, and
in the total sum of HTLCs that are open, the value of those.  And then, they
might just use other paths additionally in order to route their payment, right?

So, I saw that AJ also had an idea that you could combine that with the feerate
cards proposal from last week where you say, "Well, I'm going to allow bigger
payments, but they have to pay a higher feerate".  What did you think about
that?

**René Pickhardt**: Yeah, so I think that was actually my proposal in the
feerate card thread.  So, that came from talking to some of the node operators.
They basically said they have certain channels where they still have drain in a
certain direction, but the drain comes from a very few, very large payments.
And they are literally afraid that if they would install a smaller valve, that
currently the software would just not route the payment, it would just choose a
different channel to send the payment.  So, one of their skepticisms was
basically, "Would I actually route anything at all if I don't have, let's say, 5
million sats for forwarding?

Then I was basically thinking and saying, it makes sense to have actually the
ability to break the valve open, to basically open it up and say, "Hey, I really
want your liquidity right now because, for whatever reasons, I'm willing to pay
the premium for your cost that you have with the channel being unbalanced.  So
you have to rebalance, you have to do offchain swaps, you have to do whatever
you need to do in your liquidity management strategies to fix this issue, but
I'm willing to give you a bounty for doing so".  And since the feerate proposal
was out there anyway and AJ had a certain amount of concerns and questions which
I do share, especially the fact that it's kind of not clear in which feerate I
am currently in if I'm requesting a payment on this channel, I thought it would
actually be much more natural to have various feerates for various different max
HTLC msats amounts.  So, yeah, I think AJ and I agree that this is a good idea.

**Mark Erhardt**: Sorry for the misattribution!

**René Pickhardt**: So, I think AJ agreed, so I hope I didn't put words in his
mouth now!

**Mark Erhardt**: No, all good.  So, I think the concern was basically with the
feerate cards, which we talked about last week, for people that listened, that
you could basically treat it as four different channels that had separate
feerates and once each of them was exhausted, you'd have to switch to the higher
feerate in order to be able to still pay.  And the problem with that was, if you
anticipated the wrong feerate, your payment would not get routed because the
capacity was no longer available.  And you could circumvent that by just paying
the highest feerate in the first place, but otherwise you might get a higher
failure rate.

Here, with this proposal, since the amounts are absolute and you would basically
know exactly, "Oh, I want to pay this much, so I fall into that category of
feerate", you would be able to plan ahead and you wouldn't get failures because
of using the wrong feerate; but you might still, of course, fail if there wasn't
enough liquidity available.

**René Pickhardt**: Yeah, I mean, if you make a payment larger, the chance for
it to fail is increasing anyway.  But just to be clear, this model of four
parallel channels, I mean, it has some drawbacks.  I mean, as of right now, if I
want to pay you, Murch, I have an infinite amount of paths through the network.
But most pathfinding algorithms that are currently being implemented try to
optimise for cheaper fees.  So, if you have parallel channels, the pathfinding
algorithm will initially take the lower feerate.  I mean, of course you can
tweak this, but then by choosing this channel anyway, I could already tell the
pathfinding algorithm to a random path that has high fees, right, that may be
more reliable, because not everybody is trying to use this.  So, there are
certain problems with these kinds of considerations of trying to basically pull
all the liquidity at a certain price --

**Mark Erhardt**: Right.  So, that sounds pretty interesting.  Sorry, go on.

**René Pickhardt**: -- which very much goes back to the blog article that I
published in May, which is about the Price of Anarchy questions, right?  So what
we do have in the LN is we have this network, this P2P network, and everybody
who wants to make a payment will selfishly try to optimize for their particular
goals, which currently seems to be to have cheap fees.  Reliability might be
another goal, which is coming more and more.  But what this means is, people
will fight for a certain amount of resources.  So, you have congestion games
where you basically have to ask yourself, how bad is this for the network?

So already, as of now, and I think these ideas are not new, people have
suggested this already a couple of years ago, you could have payment algorithms
where you basically exclude all the cheap channels and just search on the more
expensive channels, because probably liquidity is there because others are not
doing this.  And so, with the feerate card, this kind of mechanism, I mean it's
already there right now, right?  So, by doing this in a particular channel and
just blowing up the size of the graph on which I do my computations, it seems a
little bit complicated to me.

**Mark Erhardt**: Thank you for your thoughts.  Mike, do you have something else
or should we…?

**Mike Schmidt**: Yeah, just maybe one more thing to wrap up.  René, what are
you hoping to get from publishing this research; like, what would you look
forward to as a next step in furthering this conversation, and how can
potentially some people listening here on this audience, or listening once we
get this in podcast format, what can they do to help you achieve your goals
here?

**René Pickhardt**: Well, I mean for the last years, my main goal was always to
increase the reliability of the payment process on the LN.  And as I wrote in
the article in the beginning of the year, I was rather skeptical if we can
actually achieve a certain reliability on the network, and I think with the
valves, this is becoming much more realistic.  So, I think one goal would be
that node operators just try to play with it a little bit.  And I have to say
this with a little warning and a little bit of caution, because a lot of the
pathfinding algorithms that are currently being used are not cost-flow-based as
of now.  What this means is they will basically, at a certain point in time,
decide into what amounts they will split the payment amount, and then they will
basically exclude all channels that don't have the necessary htlc_maximum_msat
amount.

So, I mean similar to the argument that I mentioned before by the LN node
operators and the reason why I thought about if we could have various feerates,
currently people will basically either say, "Oh, yeah, my payment is small
enough, I can use this".  But if the payment is too large, they will not split
and basically accept the liquidity that I'm offering.  That would certainly
change if more min-cost-flow-based payment delivery algorithms are being
implemented and I'm currently seeing the teams working on that, so I think that
is a good thing.  But we basically have to kind of shift more to the flow-based
payment delivery algorithms to extract the full power of this.

So yes, while we can already play around with this, I mean for example, there is
one node on the network I think I mentioned in the article that is technically
already using a valve, which is whenever the liquidity has gone and the channel
is depleted, they set the amount to 1 satoshi.  And then, they basically wait
for the liquidity to be back, and then they open the valve again.  And I mean,
of course you can do this, but by the end of the day, it's a very -- I mean, you
can automate this, but it's kind of a very mechanical process, and you cannot
send channel update messages too often on the protocol, because that would be
spam.  So, the mechanism that I propose seems to be a much more stable
mechanism, where once you have your valve opened at the right amount, it should
hopefully be stable for quite some time.  I mean, of course supply and demand on
the network can change over time, but it shouldn't happen that quickly.

**Mark Erhardt**: So, do I understand right that you basically would need a new
gossip message type that allows people to have multiple different feerates per
channel for different HTLC amounts, and that is currently not present?  Would it
be possible to simulate this by basically having multiple parallel channels,
where one channel has a small amount of HTLCs and a low fee and the other
channel has a larger allowed amount and a higher feerate, but then to sort of
collaborate with your channel partner to route through either of them to use the
whole liquidity?

**René Pickhardt**: Yeah, I think that would be possible.  I don't see what
speaks against this.  And yes, as you said, if we would want to go for multiple
htlc_maximum_msat values, we would have to basically update the channel updates,
similar as we would have to do with the feerate card proposal.  But yeah, I mean
the feerate cards could currently also be simulated by basically having four
parallel channels and agree with your channel partner to, well, do whatever you
want there.  And in a similar way, you could probably do that, but I mean of
course, this would take quite some effort.  So, I'm not sure if it's maybe
better to do that instead of just fixing the protocol directly.

_Bitcoin Core 24.0 RC1_

**Mike Schmidt**: Thanks, René, for walking us through all that and answering
our questions.  I'd like to move on to the Bitcoin Core 24.0 release candidate.
Gloria, we had Andreas on last week to walk through the testing guide that's
available, and we've included that link in this week's newsletter as well for
folks to walk through some guidance about how to do the testing and some ideas
of testing.  But I have some thoughts on motivating people to actually do the
testing, and perhaps as one of the Core developers and maintainers, how you see
the results of that testing or how you look upon that testing.  I think some
folks might say, "Hey, the developers already tested all this and I'm not going
to participate in this testing because it's just maybe for show", but maybe you
want to outline how that thought might be incorrect and why people should
consider testing.

**Gloria Zhao**: Yeah, so it's not the developers are testing it for you.  We
don't know that it works unless you test it.  And the sooner everybody tests it,
the sooner we can find the bugs and patch the bugs, have a new release, and get
back to work doing stuff on master.  Like, we have a big Erlay PR that we can't
merge yet because we're not sure if we're going to need to backport something
into net processing.  But yeah, so the way the release process works is there's
no leader.  Wlad is not deciding what to do with the release, it's people from
the community opening PRs to update docs and update seeds and chain params and
stuff, and it's people in the community testing what we're all relying upon as
bitcoiners.

I would really, really highly recommend Andreas' guide because it's really,
really comprehensive.  There's some interesting things to check out like wallet
migration from legacy to descriptors, the pre-syncing headers bit of IBD, we've
got watch-only miniscript descriptors, there's all kinds of really cool stuff,
and it's really, really well documented and put together by Andreas.  And we did
a Review Club, I guess you already covered this last week, we used a Review Club
on it last week, and people are welcome to ask questions or comment on issue
#26175 if you find any problems.

Oh, and another thing is, please submit Guix attestations.  So, the RC was
tagged on September 19 and we only have, last time I checked, 17 Guix
attestations which, I don't know, to me doesn't sound like a lot.  We're all
this big, decentralized community, we all love Bitcoin, and we all have an equal
responsibility in making sure that the code is working.  So, yeah.

**Mike Schmidt**: Gloria, what's a Guix attestation?  That sounds hard.

**Gloria Zhao**: It's not.  I think it's like ten commands total, and almost all
of it is just automated.  So, the Bitcoin release process is quite unique.  I've
been saying "decentralized community" many times, but one kind of concrete
manifestation of that is, usually how software works is one dude builds from
source and then signs the binaries with his team, and then you download those
binaries, and you download, I don't know, Michael Pappas' key or some person's
key that everyone has on their GPG keychain, and you verify that the signature
is good.

But the way it works in Bitcoin Core is, everybody builds from source using this
lovely, beautiful, wonderful, deterministic build tool, called Guix.  And we all
end up with the same result, and we all, as a community, sign with our GPG keys.
And then hopefully, you and your friends, and maybe some people in the Bitcoin
community who we trust, have also done this process, so we can all verify, "Hey,
we all got the same results, so we're running the same Bitcoin node software".
And 17 is not a lot of people.  I think it's a lot better than one, but it'd be
great if we actually do what we say we're going to do and be a decentralized
community that all works together to help produce and use and review the
software that we don't trust, verify; that's kind of the spirit that we should
all follow.

So, go to the GitHub repository, we have a contrib folder, and within that we
have a Guix folder.  And there's a readme with pretty good instructions, it's
literally like, "Install Guix, and then … happens".  And then you make a folder,
and then it should be less than ten commands, it should be really, really
simple.  I'm done now, thanks.

**Mark Erhardt**: Yeah, so basically what people attest to is, "I have checked
out this source code, and building from the source code, I got a certain
checksum on a binary in the end.  Here's a signature".  And if a lot of people
do this, you can probably rely that they all built from the same source code,
and if you directly connected to some of them, you can trust the binary to
actually include exactly the code that these people claim to have built from.
That's what we're going for.

**Mike Schmidt**: Gloria, I think that's a great call to action.  Hopefully some
people can act on that, and Andreas did a great job putting that guide together.
So hopefully, it's as easy as possible for folks.  Before we jump into Notable
code and documentation changes, of which we have quite a few this week, this
would be the opportunity as we go through these, at the end when we're done
going through the code changes, we'll take questions.  So, if you do have a
question, feel free to raise your hand or request speaker access and just be
patient while we go through the rest of these updates and then we can go through
questions at the end there.

_Eclair #2435_

The first PR is an Eclair PR, #2435, which is part of a series of efforts on the
Eclair project to implement async payments.  And an async payment allows paying
an offline node, so for example if you had a mobile wallet, in doing so without
trusting a third party with the funds.  And so there's been some discussion
previously about how this could be done with Point Time Locked Contracts
(PTLCs), but it's just currently Eclair implementing this using trampoline
relay.  There's a series of PRs and this is just the first one in that.  I was
hoping, René, if you're comfortable talking about maybe not the internals of
Eclair, per se, but this idea of what is an async payment and how does that play
into trampoline relay.

**René Pickhardt**: So, I think the last time I looked at this, the idea was
basically to say, when you make a payment, like let's say you send the payment
across a single path.  So, you have a path of channels, and you lock in HTLCs to
all of the channels.  And then the problem is that if the last node is offline,
you cannot connect the circuit.  And then usually what the second last node
would do is they would basically say, "Well, I can't reach the last node", and
they would kill the payment.  And the question here is, if the second last node
is, for example, your Lightning Service Provider (LSP) to whom you might already
have like a certain trusted relationship, if you can with them do something that
the payment service provider can already settle the payment, even though you are
offline, later on you would basically get this.  But you just mentioned that
this would work in a completely trustless manner, so I'm a little bit confused
right now.

**Mark Erhardt**: My understanding is that it's sort of similar to a hodl
invoice where, yes, the second last hop just holds on to the unsettled HTLC
until you come back online.  But I don't know if I'm mixing this up; I think
that instead of keeping all these HTLCs open across the whole path, it is held
at the first hop.  So, the trampoline that is instructed to find a path for the
payer is basically keeping in mind that they're still supposed to route this
payment, but they only do the pathfinding and the building up the HTLCs once
they learn that the recipient is online, and then they forward the multi-hop
payment at that point.

**René Pickhardt**: That makes much more sense because in this way, the chain of
HTLCs doesn't have to be locked in.

_BOLTs #962_

**Mike Schmidt**: Great.  Next PR here is a BOLTs repo PR, #692, and we've
covered the different implementations already adopting the variable length onion
format.  And so this is just, I guess, a formal change to the spec that retires
that original fixed length onion data format from the spec, and it sounds like
almost nobody was using that anymore anyways in favor of the variable length
format.  So, I don't think there's too much to jump in with this one, since
we've covered it with the different implementations in previous recap
discussions.  Murch, you okay moving on?

**Mark Erhardt**: Yeah, that's good.

_BIPs #1370_

**Mike Schmidt**: Okay, great.  The next PR here is to the BIPs repo, #1370 and
it's an update to BIP330, which is Erlay, and since we have Gloria on, I thought
it would make sense for her to, if she chooses to, jump into this particular PR,
but I don't think that we have covered Erlay in any detail on one of these
recaps, so it might be nice to get an overview of what problem Erlay is trying
to solve, and I think Gloria is great for that.  So, Gloria, take it away.

**Gloria Zhao**: Okay, sure.  So, Erlay is reconciliation-based transaction
announcements.  So, the goal there is to use less bandwidth to announce
transactions, essentially.  But the real goal goal is once connections are not
using as much bandwidth to announce transactions, then we can have outbound
connections per node.  So that's the goal goal.  But so, back to Erlay Erlay, is
currently the way transaction relay works is you're not just going to forward
the transaction data, right?  You're going to send everyone the hash of the
transaction that you've just received.  And then, if they don't have it in their
mempools already, then they'll ask you to send it to them.  And that's more
bandwidth efficient than just sending the transaction data, but it's still
inefficient if everyone is telling everyone about every transaction, because
surely, if you think about it in a perfect world, each person would only need to
receive the announcement once as well.

So, the idea is rather than as soon as you receive your transaction, you go to
broadcast it and you tell everyone, is you hold off and then periodically you
and your peers will do a set reconciliation, meaning you send a sketch of what
it was you were going to announce, and then you take that sketch and you do
magic, essentially, to see what the difference is, and then you only announce
the txids of the ones that they're missing and the same the other way.  That's
the general overview of what I mean by reconciliation-based.  And so, obviously,
there is some overhead every time you do a sketch and a reconciliation session,
but minisketch is this wonderful, beautiful, magical protocol that makes this
process quite communication efficient.  And so, the amount of data that you
exchange is on the scale of what this metric difference is, rather than what the
set of things -- hopefully this makes sense -- instead of the set of things that
you're going to say.  So, the amount of data increases if you have a large
difference between your set of announcements and the peer set of announcements.
And that's the beautiful, beautiful part.

But yeah, so Erlay in summary is reconciliation-based transaction announcement
protocol.  And this BIPs PR is just making a few updates to it.  So, one is
removing the truncated txids.  I can't tell you exactly why they were using
truncated txids beforehand instead of just wtxids, but that's gone now along
with the associated protocol messages, and then a few of them are renamed.
Then, there's some details for how to negotiate support for Erlay during your
version handshake.  So that's what the PR is doing.  Sorry, I think I saw Murch
raise his hand.

**Mark Erhardt**: Yeah, I wanted to paraphrase something you said just for
better understandability.  You talked about sketches, but really it's just sort
of a list of content of what you have announced, and then you can think of it as
people just printing it on transparent papers and holding it behind each other
and seeing where it differs and then announcing that.  So, yeah, otherwise just
instead of announcing everything to each other, people are I think also only
synchronizing the top of the mempool.  Was that true, or do you remember how
that works?

**Gloria Zhao**: No, so it's not mempool reconciliation.  As far as I
understand, that would be a privacy issue.  You are reconciling the transactions
you would have announced to this peer, that's it.  So, if you got transactions
in your mempool before they connected to you, you're not going to try to send
those.  You're only sending the ones that you would have announced to them
anyway.

**Mark Erhardt**: Cool, super, thanks for clarifying.

**Mike Schmidt**: It does seem every time the details of the sketch come up, the
word "magic" comes in!  But yeah, thanks for providing that overview, Gloria,
and I think, yeah, you really got at the motivation is a better, well-connected
P2P network, and by having more efficient ways of communicating, you can
facilitate that end goal.

**Mark Erhardt**: Maybe just one word on the magic.  As far as I understand, it
uses basically a different set of coefficients for every single txid it
announces, and basically as soon as you have announced enough sub-data that
would have been enough to encode the txids of the transactions that you would
have to announce to make the set complete, you can calculate exactly those
txids.  So, it's information theoretically perfect.  You only need exactly as
many bytes as the txids that you would have announced in order to complete the
other side set.  And yes, that is kind of magic!

**Gloria Zhao**: It's really fun if you like abstract algebra, it's pretty cool,
it's pretty magical.  It's like you have your sketches are polynomials and to
merge them, you just like XOR, and then it's like magic.  I have notes on it if
anyone wants to see.

_BIPs #1367_

**Mike Schmidt**: Similar to Erlay here, so this last PR was a change to the
Erlay BIP, changing some of the internals; similar, this BIP #1367 is just some
simplification of BIP118, the description of SIGHASH_ANYPREVOUT, or APO.  And
instead of maybe jumping into the details of that simplification of the
documentation, I'm not sure that we've done an overview of SIGHASH_ANYPREVOUT.
I know we had AJ on, I think it was last week.  We got into it briefly, but
maybe, Murch, just for anybody who missed that or could use a quick overview,
maybe you can describe what is a sighash (signature hash), and then what is
SIGHASH_ANYPREVOUT supposed to do?

**Mark Erhardt**: All right, let me try.  So, when we sign transactions, our
input data includes a signature, and the signature commits to the whole
transactions in general.  So, it looks at what inputs are there, what outputs
are there, what amounts are there, and it hashes all that up as the input to the
signature, the message that the signature commits to.  So, cryptographic
signatures, they always require a message that they commit to, and the signature
is only valid in the context of that message.  It's not like a signature with a
pen that you could cut out and paste on something else, it is only valid in the
context of that message.

So, we have a few different sighash types, so you can commit to different parts
of the transaction with your signature, which allows us, for example, to do
multiparty transactions more easily, because other people can later add more
inputs and things like that.  SIGHASH_ANYPREVOUT is special in the way that the
signature does not commit to one specific UTXO that is being spent.  That is
usually always the case.  You at least commit to the specific UTXO you're
signing.  But in this case, you're only committing to a specific public key that
the funds belong to, but you could attach the signature to different UTXOs.  And
what this allows is, instead of using the LN-penalty update mechanism for LN
payments, you can for example do the eltoo, and if they ever rename it, I think
that 118 will get adopted much faster.

The new update mechanism, instead of being based on asymmetric information and a
penalty mechanism if somebody cheats, it is based on being able to overwrite any
previous instances of that output.  And you can only increase in the order; you
can jump from the third output to the sixth version of it, but you cannot then
after that publish the fifth.  And what this SIGHASH_ANYPREVOUT allows is for an
output that has a specific amount and can be spent by a specific public key, I
can attach the signature to any version of that.  I hope that made some sense.
Perhaps, Gloria, if you have ideas how you could better explain it?

**Gloria Zhao**: I think it was good.  For me, the main selling point is not
needing to store old states and just you can always rebind whatever state it is
you want to broadcast to whatever the counterparty said.

**Mark Erhardt**: Yeah, so eltoo, the update mechanism is symmetric and all
parties have the same information.  There is no longer this toxic information
that we have in the LN-penalty mechanism, where if you broadcast accidentally an
old state, the other party will broadcast the justice transaction and take all
the money in the channel, which on the one hand is of course the security
mechanism for LN-penalty, but on the other hand makes it really hard to keep
backups of LN channels.  And yeah, so with the eltoo mechanism, we would have
symmetric information, it would be much smaller for backups and much safer.  And
then in the worst case, basically, you can have some game theoretic approaches
that encourage the counterparty to broadcast the last version, where everybody
gets what balance they were due.

**Gloria Zhao**: Yeah, Greg is here.  So, if you want to give him speaking, he
can also explain to us, I'm sure.

**Mike Schmidt**: Yeah, hi, instagibbs.

**Greg Sanders**: Hello.

**Mark Erhardt**: We were just talking about APO and the BIPs #1367 PR, and we
were blundering through a couple of tries of explaining APO.  So, if you had
been listening, do you want to add something?

**Greg Sanders**: I just joined, but for me, when it comes to eltoo incentives,
the lack of penalty is more that now the incentive would be to have your node
up.  You want to be online so that you and your counterparties can do a
cooperative close, which is actually cheaper and more private.  So, that's
really what I'd say the incentive is, instead of a penalty transaction.  If you
have any specific questions about APO, I can try to answer, but I just joined.

**Mike Schmidt**: Murch, anything specific?

**Mark Erhardt**: No, I think then we'll just leave it at that and go on to the
next one.  Maybe I'll just take it on, I wrote that summary.

_BIPs #1349_

So, this was also a BIPs PR; this is BIPs #1349, and it adds a new BIP, the
BIP351, Private Payments, and it describes a new cryptographic protocol that is
similar to BIP47, and an earlier proposal by Ruben Somsen, Silent Payments.  And
for those that are familiar, this is a similar idea to the paynyms, which is
BIP47.  Basically, you publish a payment code where other participants can use
that public information to create a shared secret.  So, a potential sender finds
your payment code and between this payment code and their own information, they
can create a chain of basically an extended pubkey that they communicate to you
in a notification transaction.

This notification transaction uses an OP_RETURN with the search key, PP, for
"Private Payments", I assume, and then a notification code that is unique to the
sender and receiver pair.  And now anybody that participates in the private
payment scheme can just look at the outputs, the OP_RETURN outputs that have
this PP label, and then see whether they can recognize the notification code
from the public key that follows it and their own payment code that they have
published.  And if so, the receiver can then use this public information to
spend the outputs, and the sender can use these derived addresses that follow to
basically increment a counter and generate a new address every single time they
pay the recipient.  And the scheme could, for example, be used for private
donations or generally where two very privacy-minded folk want to establish a
shared chain of keys so that they can conduct numerous payments without anybody
else being able to tell that these payments are connected.

The big advantage over BIP47, which has a little bit of adoption already, is in
BIP47, the notification transaction needs to pay to the notification address of
the receiver.  So, this address is reused every time a new sender starts setting
up a shared secret with the receiver.  So, it's super easy to see that there's a
BIP47 payment situation being set up, and the different sets of keys are being
recognizable, or just the setup thereof is recognizable as going to the same
recipient; and with the new Private Payments proposal, BIP351, they cannot be
either recognized as belonging to a specific payment code, nor can they be
correlated with each other.

_BIPs #1293_

**Mike Schmidt**: Great overview, Murch.  There's another BIPs PR, which is BIPs
#1293, which adds another new BIP, which is BIP372, and that is titled
Pay-to-contract tweak fields for PSBT.  And we've covered this in a previous
newsletter and it's referenced here in #184, but there's been some discussion on
the mailing list previously, and this BIP essentially proposes additional fields
to be added to PSBTs, that you could utilize those fields to provide the
commitment data required in order to participate in a pay-to-contract protocol.
So, if you have a signing device and you want to participate in these
pay-to-contract protocols, you need that additional commitment or tweak data in
order to provide a signature.  And so, this simply augments the PSBT with these
additional fields that you need in order to sign.  Murch, anything to add on
pay-to-contract tweak fields for PSBT?

**Mark Erhardt**: Yeah, maybe what pay-to-contract means.  So, the general idea
of a pay-to-contract is, let's say I have a business partner, I want to pay them
for some work done, and we write a contract that specifies how much they'll
receive for what services.  And together, they make an offer to me, and I want
to accept that offer.  So, I hash their proposal, and then in my pay-to-contract
payment, I tweak the payment with the hash of the document that we agreed upon.
And then, when the payment goes through, I can later use this payment itself as
proof that (a) I paid, and (b) that I paid to the conditions of the document
that we agreed upon.

It requires the cooperation of the recipient, so basically it's a formal proof
that the two of us had agreed on the content of the contract, because the hash
is right there.

_BIPs #1364_

**Mike Schmidt**: Excellent, thanks, Murch.  The last PR this week, and if
anybody has questions, feel free to request speaker access or raise your hand
now as we go through this last item, but this last PR is another BIPs PR that
was merged, and this is an update to BIP300 and 301, collectively known as the
drivechain BIP.  And actually, it looks like there were some code updates from
Paul that he's referencing, deleting some old material, and then there were some
clarifications on some of the documentation that he's provided.  And if you look
through the PRs here, there's actually quite a bit of changes here.  I think a
lot of it is more informational and less foundational.

But for those curious about drive chains, we had Paul on one of our recap
discussions on Twitter Spaces a few weeks ago, and feel free to review that to
get the bigger picture drivechain vision that he has.  This is just some updates
to the documentation and referencing some of the new code that he wrote.  Murch,
anything more on drivechains?

**Mark Erhardt**: No, I think probably best just to jump into our episode.  I
think it was two weeks ago, and we had Paul on himself to explain basically what
it's about.

**Mike Schmidt**: Okay.

**Mark Erhardt**: We also got Dusty as a speaker request just now.

**Mike Schmidt**: Oh, yeah.

**Dusty Daemon**: What's up, man?  Yeah, I just wanted to say, Gloria, I'm
excited about this new proposal for the mempool with the ephemeral updates, I'm
presuming that's the name of it.  It sounds like a lot of the pinning
discussions in LN get really convoluted really fast.  This feels like it's going
to be a really simple solution, to which I'm excited about.  I did have a really
basic question, which is that I presume for this to work, the child's
transaction will have to have RBF enabled.  And I was just curious if it's going
to be a requirement that flag's on, or it will be implied RBF, or if all v3s
will have RBF turned on by default, or something like that?

**Gloria Zhao**: Yeah, so I -- can you hear me?  Yes, you can hear me.  V3 is
opt-in RBF, and then because v3 is inherited, that form of signaling is also
inherited.  So, the child will always be signaling RBF --

**Dusty Daemon**: Oh, awesome!

**Gloria Zhao**: -- and that was intentional, because that means we have
inherited signaling without ever needing to ask mempool for ancestors or
descendents.

**Mark Erhardt**: So to clarify, I think v3 is always replaceable, right?

**Gloria Zhao**: Yes.

**Dusty Daemon**: Oh, so all v3 transactions have RBF by default, is that right?

**Gloria Zhao**: Yes.

**Dusty Daemon**: Got it, thanks.

**Mike Schmidt**: Thanks, Dusty.  Last chance if anybody has any questions,
otherwise we'll wrap up for this week.

**René Pickhardt**: I will just add one more thing, because I think I misspoke
when I said that feerate cards can currently also be simulated by having four
parallel channels.  One part of the feerate card proposal is to also include
negative fees, and I think that would not be possible to simulate currently.

**Mark Erhardt**: Cool, thank you.  All right, I don't see any other speaker
requests.  Thank you for your questions, we love to be able to keep it
interactive here.  And I hope to see a bunch of you next week at TABConf, and
thank you all for coming.  Do you all have something to wrap up with, René
maybe?

René Pickhardt: No, I don't.  Thanks for inviting us and for doing what you're
doing.  I think that's very important to educate people.

**Mark Erhardt**: Super, thank you.  Gloria?

**Gloria Zhao**: Thank you, looking forward to seeing your Guix attestations!

**Mike Schmidt**: Very good!  Thank you, Gloria and René for joining, and thanks
for the questions.  Thanks always to Murch, and we'll see you all next week same
time.

**Mark Erhardt**: Cheers.

**Gloria Zhao**: Thank you.

**Mike Schmidt**: Cheers.

{% include references.md %}
