---
title: 'Bitcoin Optech Newsletter #309 Recap Podcast'
permalink: /en/podcast/2024/07/02/
reference: /en/newsletters/2024/06/28/
name: 2024-07-02-recap
slug: 2024-07-02-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by René Pickhardt to discuss [Newsletter #309]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-6-2/382247155-44100-2-8ec5be493a7fa.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #309 Recap on
Twitter Spaces.  Today, we're going to be talking about some research into
estimating the likelihood of a Lightning payment; we have ten interesting
Bitcoin questions and answers from the Bitcoin Stack Exchange; and we have a
potpourri of notable code PRs from a bunch of different repositories that we'll
jump into.  We're going to go through the newsletter sequentially today,
starting with the news section, but first, we'll do introductions.  I'm Mike
Schmidt, contributor at Optech and Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: René?

**René Pickhardt**: Yes, I'm René Pickhardt, Lightning Network Researcher and
currently grantee with OpenSats.

_Estimating the likelihood that an LN payment is feasible_

**Mike Schmidt**: Great, thanks for joining us this week.  Your news item is the
first and only news item this week, which is titled in the newsletter,
"Estimating the likelihood that an LN payment is Feasible".  René, you posted to
Delving a post titled similarly, "Estimating Likelihood for Lightning Payments
to be (in)feasible".  Why don't you talk about a little bit of the work that
you've done previously and how that feeds into what you've posted at Delving so
we can all catch up on the research you've been doing?

**René Pickhardt**: Yeah, so just stop me if I'm giving maybe too much context,
but when I first discovered the LN, I thought it's a very interesting piece of
technology, because obviously there is the network name in the technology, and
payments are being routed through the network.  And at that time, there was the
onion routing transport layer implemented through the protocol, but it wasn't
quite clear how the payments should actually be delivered.  And I pretty much,
in 2018, 2019, started working on delivering payments, routing payments, from
the sending nodes to the recipient node.  And I think in 2021, 2022, we had some
major breakthroughs where we understood that we can quantify the uncertainty
about the liquidity in channels, and we can use this to make optimal decisions
in order to deliver payments.  However, when you talk with people in the LN
community, you realize that some people still have issues delivering payments.
Some payments still always fail no matter how often the node retries.

So, maybe just to give a little bit more context, when you try, when you scan an
invoice and you try to make a payment, what your node does is it uses some of
the algorithms to decide where to route the payment, and it tries, it makes an
attempt; it tries it, and if the attempt is not successful, it will use this
information and select a different route and try again.  And statistically
speaking, with enough retries, the payment should eventually arrive at the
destination.  However, in practice, what we see is that some payments just don't
reach the destination.  And I started to become interested in why this is
happening and what could be done about this.  So, yeah, this is pretty much what
I very extensively started doing around the beginning of the year, and yes, I
have currently a paper.  Actually today, I finally got the last proof that I
needed completely written down.  I mean I knew before that the theory was
correct, but finally I have the proof.  So, I'm currently writing a paper
titled, "A mathematical theory of payment channel networks", where I think I can
provide the mathematics that we need to describe what is going on with liquidity
and payment channel networks.  And this can actually be used to explain why
certain payments, at least statistically, are infeasible on the LN.

While writing down the paper, I thought there's this nice little example that I
use in the paper, and I decided to post this on Delving Bitcoin.  And yes, you
guys covered it on the newsletter.

**Mike Schmidt**: Why don't we drill into -- oh sorry, Murch, I see your hand
up.  Go ahead.

**Mark Erhardt**: You're probably going to ask the same thing, but I'm curious.
So, my understanding was that the minimum cost flows or the payment flows that
you previously, I think what's colloquially called as Pickhardt Payments, was
already using this assumption that liquidity in payment channels has an unknown
distribution.  Let's assume that it's at the halfway point for starters.  So,
that seems extremely similar.  Could you maybe highlight where the differences
really are between what you are writing now versus your prior work?

**René Pickhardt**: Yes.  There are certainly relations to these topics.  The
situation is this.  If you have the LN, you know what's going on in the channels
that your node maintains, but what you usually don't know is what's going on in
all the other channels.  And what people have been doing and what you have
described, what is known to the methods that we have introduced, is that we can
try to use probability theory to estimate the likelihood that enough liquidity
in remote channels is available.  But of course, our estimates could be wrong.
What I was trying to do now is to say, let's assume I know everything about the
network.  I mean, I could simulate this, I could just study this.  I mean, even
though I don't know everything, technically the channels have a certain state.
And if the network is in a certain state, then I can ask the question, what
payments are possible and which payments are not possible?  And when you have
the network in a certain state with respect to liquidity, what you can do is you
can, for every pair of nodes, compute a minimum cut or a max flow.  And that
number gives you the maximum number of satoshis that these two nodes can pay
each other.

So, Murch, if I have a node and you have a node and I compute the minimum cut
from me to you, then this number gives me the number that I can send you when
the network is in a certain state.  Of course, the network could be in a
different state and then I might be able to send you a little bit more.  So, to
make this concrete, if I have, let's say, ten payment channels, but I don't have
any liquidity in my channels, they are all on the other side, well, then the
minimum cut from my node to every other node is zero, I cannot send anybody
anything.  However, if I had received some payments, well then I have more
liquidity in my channels.  Maybe you also have some inbound liquidity, and under
the assumption that the rest of the network is in a somewhat good state,
hopefully the min cut from me to you is a little bit higher.  And very
importantly, the number is not symmetrical, right?  So I, in a certain
situation, could be able to send you a certain amount of money, but you could
maybe be able to send me a larger amount of money or a lower amount of money.
And again, in reality, we don't know the state of the network, but this research
started from the assumption, "Let's assume for a moment we know the state of the
network", and then ask ourselves what is actually possible and what is not
possible.

The main observation is that a minimum cut through the liquidity network gives
us a number of how many sats one node can pay to another node for a given state
in the network.  And I think it was in March that I published the first
notebook.  I think I didn't share it on Delving Bitcoin, I just put it on my Git
repository, but it's in the same repository where this research is going on,
where basically a simulated network computed curves and showed how the min-cut
distribution looks like.  So, it gave us a statistic of what number of satoshis
the network would statistically at least be expected to support.  So, I don't
recall the right numbers, but you could see that in 99.9% of the cases, people
could pay 100 satoshis.  But if you increase the amount, then at least
statistically speaking, the network sometimes is in a state that the amount is
only supported maybe in 99% of all cases ,or sometimes even lower, depending on
how large the amount costs.  So technically, the larger the amounts are, then
the number of payments that are feasible declines.

**Mark Erhardt**: Sorry, if I may jump in.  So, I gather the difference is that
your original research was about evaluating a single route and comparing
singular routes and looking at the likelihood that that route would succeed;
whereas, this one is taking a more broader view and looking at the cut, probably
every possible cut, between you and the destination to estimate the maximum
amount that can be sent.  Did I get that roughly right?

**René Pickhardt**: Yes.  So, the former research is exactly how you said, is
about how can I make the best decisions that are possible given the uncertainty
that I have about all the liquidity, right?  So, it's really about selecting the
first attempt, selecting the next attempt, selecting the third attempt.  But the
current research is basically turning it in the other direction and saying,
well, let's take a few random states that the network could be in and then
decide for these states, what is the amount that I could send?  And when I look
at this distribution, it gives me a rough estimate of how much I can probably
send, right?  Because still I don't know what state the network is in, but it
gives me a certain bound, like depending if the network is in the best possible
state for me, there's still a maximum number that I can send or that I can
receive.  So, this gives me basically an estimate of what is possible for me in
order to send to you or to Mike.

**Mark Erhardt**: Thanks, super.  Please, carry on.

**René Pickhardt**: So, while looking at this, what I realized is, when I
further wanted to understand the situation about the network state, is that it
really makes sense to actually start looking at wealth distributions; that's at
least the term that I'm using.  So, if you have nodes on the network, those
nodes own bitcoins in all of their channels.  So, from a certain network state,
you can actually go to assign how many coins are owned by which nodes.  And the
first thing that you realize is, let's say you have 100 users and 1,000 coins,
and you would just have this as an onchain system, then there are a lot of
wealth distributions possible.  So for example, Murch, you could have all the
1,000 coins, or I could have all the 1,000 coins.  But if we create a payment
channel network that is supposed to help us to let the coins flow more quickly,
because we don't want to wait for our onchain confirmations in order to make a
payment or so, then maybe not all wealth distributions are possible.  Yeah,
Murch, you have a question.

**Mark Erhardt**: Oh, I was wondering what happened, but that was previously
that I used the hand symbol.  It shouldn't be showing now.

**René Pickhardt**: Okay, sorry.

**Mark Erhardt**: Just for my research, are you on a computer or on a mobile
phone?

**René Pickhardt**: I'm on a computer.

**Mark Erhardt**: Because, yeah, the hand symbol was weird at least a few months
ago on computers.  Maybe that's what's going on!  Go ahead, please.

**René Pickhardt**: So, in Bitcoin basically, if you see it as an onchain
system, there are a lot of wealth distributions among the users possible;
whereas, when you create a payment channel network like the LN, the fact that
let's say, Murch, you and I have a channel, those satoshis can never leave that
channel.  They're either all on your side, all on my side, or we split them
somehow, and we can transfer value, as in I can send you a few satoshis and you
forward some satoshis in another channel, but still the satoshis in our channel
will never leave that channel.  And this gives us a rather strong restriction on
the number of possible wealth distributions that we can actually see in the LN.

**Mark Erhardt**: Well, yeah, I was just thinking about that.  So, if I open two
channels and obviously I put in the starting funds, so all the capacities on my
side in those two channels, and then someone else opens one channel to me,
overall, as long as I'm only routing, my amount of bitcoin stays roughly the
same, slightly growing by the fees that I'm collecting.

**René Pickhardt**: Yes.

**Mark Erhardt**: But if I transact directly with one of my channel partners, as
in let's say the two of us have a channel, and I opened it, it started with 1
bitcoin on my side, but I pay you a few times, eventually my wealth, if I'm
paying the counterparty, can go lower.  Routing basically maintains it, but if I
pay someone directly on my own channel, it just shifts wealth, right?

**René Pickhardt**: Absolutely.  So, for this research, what I'm currently doing
is just for simplicity, I'm ignoring the routing fees because stuff becomes
really, really complicated and the fees are kind of neglectable.  So, in that
setting, it means if you route a payment, your wealth is conserved; but if you
make a payment, it's a change in the wealth distribution.  And this is, I mean
generally a concept, right?  I mean, if somebody pays somebody else, the wealth
distribution changes.  And in Bitcoin, as long as I have the money, I can make
any payment to anyone onchain.  But on the LN, there are certain changes in the
wealth distribution that just become infeasible because of the topology of the
network.

So, if I go back to March this year when I created the curves with the min-cut
distribution that showed what payment sizes are usually possible on average on
the network, what I realised is that if I took the network that was basically a
subnetwork with only professionally-maintained nodes, the supported payment
amounts really grew.  And it grew further than the average liquidity per node.
So, what this indicated to me is that when we have a good topology, well, then
maybe we can make higher payments and we can use liquidity more efficiently.
So, this entire research that I'm providing right now about payment feasibility
goes into the direction of liquidity management and deciding on where to open a
channel, why to maintain a channel, and where to allocate liquidity.

**Mark Erhardt**: Cool, yeah.  So basically, by making educated guesses on what
capacities people might have started out with and how the capacity may slosh
around in the LN, you might be able to make a more educated guess on what a good
channel to add would be and where to allocate new channels for improving the
situation?

**René Pickhardt**: So, yes, of course.  Given the current gossip protocol and
the onchain data, I can make rather educated guesses about who opened channels
and who has the initial liquidity on channels.  But then of course, I don't know
what payments take place and I don't know how the wealth distribution changes in
the channel.  But what you can do is, the set of possible or feasible wealth
distributions as a geometric object, you can randomly sample points from them.
The difficulty is, you have to sample them uniformly, but there are geometrical
methods to make this possible in this high-dimensional space.  It's not as easy
as just sampling for every payment channel uniformly how the liquidity is,
because as most people know, in payment channels, usually the channel is
depleted either on one side or on the other side.

So, if I take a few random wealth distributions, uniformly distributed feasible
random wealth distributions, then I can check how often a payment between you
and me of a certain amount would have been possible, and this gives me an
estimate of how likely it is that a payment between you and me is possible, and
that should be statistically rather sound.  And I hear some critics saying,
"Yes, but assuming wealth distributions are uniformly distributed is like a poor
assumption, because wealth usually is power-law distributed, so it's skew
distributed.  You have a few very rich people and a few not so rich people".
But that is already reflected in the topology of the LN, right, because we're
not sampling from all wealth distributions that exist uniformly, but from those
that are feasible on the topology of the network.  So, if you have like a large
node, like River or Bitfinex, of course we often assume that they have a lot of
coins.  It's rather unlikely that they are in the state where all the coins are
not somewhere in their channels.

But yes, so the core observation here, and I think that's an observation that
has been posted to the mailing list already in 2018, is that making a payment or
the ability of the network to route and conduct or fulfill a payment request
does not depend on the channel states, but it really only depends on the
min-cuts, and the min-cut depends on the wealth distribution.  That is
something, when the paper drops, that I can show within that paper.  And yes, I
mean in this small example that I shared, I used the same methodology.

**Mike Schmidt**: René, for the research that you've been doing, I know that
this paper is just about to drop or just did drop, but are LN implementations
aware of this new research and are they planning to use this research in their
LN Node software at this time?  Have you had any interactions with them at all?

**René Pickhardt**: Yes, I do.  So, let's talk about the caveats of research.
The research, in some sense, indicates that the two-party channel design is a
strong restriction on how liquidity can flow.  So, one thing that we can show,
and there's already a notebook online on my Git repository, is that if we create
multi-party channels, then we actually have a much better flow of liquidity.  So
for example, in the past, people thought of multiparty channels as an
improvement to save some onchain space, because with one transaction, now you
can create a channel factory and provide more channels, like second-stage
commitment transactions offchain.  But what I'm able to at least statistically
show is that depletion occurs much less frequently and that more routing
abilities are there.  So, the reliability of payments and the supported payment
amounts increase when you go for multiparty channels.

So, I have been discussing this with some of the implementations, and they're
interested in this because it gives a different argument to going down this
road.  But yeah, of course, I mean multiparty channels have a whole bunch of
different challenges for us to implement them.  But this would be at least a
protocol level consequence.  The other one is in decision-making, and this is
usually something that happens in application land.  So for example, if you look
at the Delving Bitcoin discussion, David Harding asked, "Can you use this as,
for example, a service provider, because you know you want to receive a certain
amount of payments, and you can estimate, is this currently possible? Should I
require more liquidity, and from whom should I get a channel in order to
increase my chances?"  Or in the other way, if you want to in the future pay a
certain amount of people, you can use this for decision-making.  I'm not sure if
this will be a standard implementation to all of the node software
implementations, I mean that's obviously up to the teams.  But so far, the
feedback was at least kind of like everybody was very interested in the
research.

**Mike Schmidt**: You touched on at the end there some of the feedback from the
Delving post.  Perhaps you've circulated some of this research around privately
as well.  If so, what's the feedback been that we can't see?

**René Pickhardt**: Well, one of the feedback was that it's really time to get
the paper finished and to have a more public discussion about these things.  And
I mean, obviously that's something I'm working on.  But in research, it's often
like you already have kind of a result, you have a preview and you kind of want
to circle it around and want to get exactly that feedback.  And the other
feedback is, as I just said, it's very interesting to have this additional
argument for multiparty channels and, yeah, the question of how you can fix some
of the LN payment feasibility issues that we have, because we see that often
only small payments are working with high reliability or with a sufficient
service level guarantee.

**Mike Schmidt**: I can see that the research portion in the paper that you're
releasing would be interesting for people to analyze theoretically and think
about.  I think you mentioned, and I know it was in your post, that you have
these IPython notebooks as well.  Maybe that would be interesting for a
different set of people to sort of play around with.  What sort of things are in
there that people might want to jump into and tinker with?

**René Pickhardt**: So, I mean from my perspective, I can show that the set of
feasible LN states and the set of feasible wealth distributions are so-called
convex polytopes.  And these are high-dimensional objects, and the geometry of
them explains why channels are often depleted.  There are some deeper
mathematical reasons behind them, which I would actually refer to for the paper.
But in these notebooks, I, in some sense, visualize them, and then I show how to
solve some of the problems with integer linear programming.  So, these are
standard optimization techniques that are also used to solve max flow problems
or minimum cost flow problems.  So, it gives us an overview of how to address
these kinds of questions.

There is this one professor, I think he's in Chicago, and I'm probably horribly
mispronouncing the name now, Sidiropoulos, and he already saw some of the
results.  And I mean, he is working in algorithmic geometry and he kind of could
connect the dots of what I'm doing.  And he just last week sent me a draft of a
follow-up paper that he was writing, where he says he can calculate or estimate
the capital efficiency in the LN.  So, what I expect from this research is,
because it provides us the right tools, that we can apply them and answer a
bunch of different questions that are of interest for the LN community.  And the
notebooks, of course, will help people to get started because they see some
examples being calculated through.

**Mike Schmidt**: So, we have the notebooks, we have the delving posts, and we
now have the paper as all different calls to action for the audience.  Any final
words that you'd have on the topic, René?

**René Pickhardt**: So, for the paper, I hope to really, really finalize at
least the next draft that I will release this week.  There is a very old and
early version of the paper in the Git repository right now, but I will put out a
tweet or at least say something on Delving when the paper is in the next
version, because the very old version is nothing I would currently recommend
people to look at.  No, but once the next version is out, I would kindly ask for
community feedback and, yes, it would be really interesting to hear thoughts of
what people can do with this and how this is useful for people.  Obviously,
testing feasibility of payments is something that can also be tested on mainnet.
So, if people have their own data and they can test against these models, this
would be very interesting.

**Mark Erhardt**: One follow-up question.  So, you said that your colleague had
a potential follow-up paper, and you said that you could show why channels are
often depleted in one direction and how that could be addressed.  Could you give
an example, like what leads to channels being depleted, and how it could be
fixed?

**René Pickhardt**: Yes.  So there is, not always, but often in mathematics,
there are examples that are hopefully easy to follow, but maybe not too
practical.  But I will give that example to you.  When you take a topology of
the LN that forms the tree, then every state of the LN corresponds uniquely to
one wealth distribution.  And if you assume that the wealth distributions within
the topology are uniformly distributed, well, then the channel states are
uniformly distributed.  But as soon as you create redundancy in the network, as
in you have circles, well then circular rebalancing becomes possible; this is a
circulation.  And when you have those circulations, what this means is that one
wealth distribution has several states in the network that lead to the same
wealth distribution.

So for example, Murch, if you have a few channels and you just make a circular
payment to yourself, again assuming no routing fees apply, well then no wealth
has changed hands, but you have a different state in the network.  And what you
can see actually is that the geometric object that is the polytope of wealth
distributions, you can show an embedding that it's on the rim of the polytope of
states, and the rim means that some channels are always depleted.  So, yes, you
can just show, and I have a notebook already in my Git repository, where I show
how I can derive these bimodal liquidity distributions, just from the pure fact
that I assume that the wealth distributions are equally distributed.  But all
circulations that lead to the same wealth distributions are also equally likely,
and then you can just count how often a channel is in a certain state.  And as
soon as you introduce circles to the network, depletion starts to occur.  And
obviously, we don't want a spanning tree as a network, because as soon as one
channel would break, well then you couldn't make the payment.

**Mark Erhardt**: Yeah, it took me a moment to follow why a tree had only one
distribution.  So, it is because the leaf, of course, in the tree has only one
channel.  Therefore, a wealth indicates how much capacity in the channel is
allocated to both sides.  And from there, going up to the root, you arrive at a
fixed distribution.  Yeah, so I see that part.  I think I'd have to noodle a bit
on the circles causing depletion, but that kind of makes sense.  So, the idea
would be to raise fees on certain channels in order to make it less economic to
deplete channels, or…?  You said you had an example, but what would be the
solution; I think that was part of what I asked earlier?

**René Pickhardt**: Well, so I mean depletion, I mean depletion is one thing,
right?  I mean, even if some channels are depleted theoretically, it's still a
question of, "Can I go from this wealth distribution to the other wealth
distribution?  Are both of them feasible?" and then I just have to make
sufficiently attempts to find the route that actually follows this min cut.  So,
it's two different questions.  Depletion is kind of annoying if I want to be
certain that my payment attempts quickly settle a payment that should be
feasible, so that is why we would try to avoid depletion.  But the fact that
channels deplete does not change anything about the fact whether a payment is
feasible or not.

**Mark Erhardt**: Okay, I think I'll have to noodle more on this to ask better
questions, but that was very interesting.  Thank you very much.

**René Pickhardt**: Sure, you're welcome.

**Mike Schmidt**: Thanks for joining us, René.  You're welcome to stay on for
the rest of the recap or if you have other things to do, we understand.

**René Pickhardt**: I will stay, but I will mute myself.

**Mike Schmidt**: Feel free to chime in.  Next section from the newsletter is
our monthly segment highlighting questions and answers that we think are
interesting from the Bitcoin Stack Exchange.

_How is the progress of Initial Block Download (IBD) calculated?_

First question is, "How is the progress of IBD calculated?"  And the person
asking is referencing the debug.log file messages during IBD.  And there is a
progress value in that log, and he is wondering how that is calculated or
estimated.  And Pieter Wuille points to Bitcoin Core's GuessVerificationProgress
function, and goes on to explain that the estimated total transactions remaining
in the chain actually uses hard-coded statistics that are updated in Bitcoin
Core as part of each major release.  That was news to me; I didn't know that.
Murch, do you have any familiarity with the topic?

**Mark Erhardt**: Yeah, I mean, it's kind of hard to guess how big the
blockchain is and how much work you still have to do if you only have seen the
first few blocks, right?  So, when we release a client, we know, of course, how
many transactions exist up to the release time, and we can use that as a fixed
value that we just encode in the software itself.  And then we can, from there,
just extrapolate based on how much transactions exist in a block and what the
best block header chain indicates the best height is.  And then, well obviously
transactions have different sizes, so sometimes a very big transaction might
indicate incorrectly only the same amount of work to be done as any other
average transaction.  But then, of course, the average also implies that there
are smaller transactions.

So, while it's not a perfect metric and it sort of also underestimates the total
work, because prior transactions were simpler, and as you progress over time,
transactions get bigger and more complex, then also at some point, if you're
running with default values, assumevalid runs out, which we only do up to the
release height, slightly lower height than the release was crafted at, then
yeah, it kind of underestimates a little bit towards the end.  But yeah, it's a
somewhat decent first estimate.

_What is `progress increase per hour` during synchronization?_

**Mike Schmidt**: Second question is somewhat related, also talking about
synchronization.  The person asking is wondering, well the question is, "What is
progress increase per hour during synchronization?"  And the person is
wondering, "Why wouldn't the syncing rate be constant?"  And Pieter Wuille also
answered this question, and I think he looked into maybe what the person was
getting at with their question, that progress increase per hour is the
percentage of the blockchain synced per hour and not an increase in progress
rate itself.  And then he goes on to note some of the reasons, some of which
Murch just mentioned actually, of why progress during synchronization is not
constant and can vary.

**Mark Erhardt**: Yeah, frankly that naming is a little ambiguous!

_Should an even Y coordinate be enforced after every key-tweak operation, or only at the end?_

**Mike Schmidt**: Yeah.  Next question from the Stack Exchange, "Should an even
Y coordinate be enforced after every key-tweak operation, or only at the end?  I
think, Murch, there's potentially some context that needs to be given before we
jump into the answer to this, but I'll punt this one to you.

**Mark Erhardt**: Yeah, so this is a question about the x-only keys that were
introduced with P2TR.  So usually, an ECDSA key, of course, has an x value and a
y value.  And I'm going a bit off the cuff here, but the y values appear in
pairs, so the negative y value and the positive y value form two valid public
keys, and they're actually two public keys that correspond to the same private
key, I believe.  And anyway, so you can encode these as x-only if you have a
convention on which of the two y values it should resolve to, in case it is
unclear.  So, we use that trick to save 1 byte for P2TR output scripts, and this
leads to some slight headaches whenever people are using any sort of key
aggregation or multisig, or things in which multiple keys are involved that
eventually lead to a single resulting key.  And it was not quite clear when
people implemented some of the stuff, like FROST and MuSig, whether they should
at each step go back to x-only keys, or whether they should keep the x and y
values of keys throughout and only in the end do the steps.

So, this person is presumably working on implementing some protocol that makes
use of key tweaking or aggregated keys, and they wanted to have a recommendation
on when to apply the x-only keys.  And the answer is, I think, you just need to
define whatever you do in your protocol, and people then need to adhere to the
defined protocol.  And in some cases, it might be better this way or that way.
But well, generally do it as late as possible.

_Signet mobile phone wallets?_

**Mike Schmidt**: Thanks, Murch.  Next question, "Signet mobile phone wallets?"
The person asking this question was having some trouble using testnet and heard
about signet and was wondering if there were similarities there, if they could
use their same wallet, etc, but also if there were signet-compatible mobile
wallets.  And, Murch, you did a little poll on Twitter and found Nunchuck, Lava,
Envoy, and Xverse as signet-compatible mobile wallets, which is good to see.
Did any other wallets come in since we published?

**Mark Erhardt**: I don't think I saw another one.  I did update this answer a
couple times when more answers came in, but maybe just the other crux here.
Signet is a testnet in the sense that the coins don't have any value and should
be freely available, and it just simulates an organic network.  It has slightly
different restrictions than testnet, in that blocks are signed into existence by
authorized signers, which in our case are just two people, AJ and Kalle.  And,
yeah, so using signet is just simply a different blockchain than using testnets,
just like testnet3 is a different network than testnet2 or testnet4.  So, in
case you're wondering why you can't send testnet coins to signet, it's because
they're free in different blockchains.

_What block had the most transaction fees? Why?_

**Mike Schmidt**: What block had the most transaction fees?  Why?  Murch, you
actually answered this one, uncovering for everybody that block 409,008 actually
had the most bitcoin-denominated fees, with 291.533 bitcoin; but that the
highest US-denominated fees was actually just under $3.2 million, which was in
block 818,087.

**Mark Erhardt**: Sorry, go ahead.

**Mike Schmidt**: Oh, I was just going to say, you presume both to be caused by
missing change output as well, and maybe you want to talk about that.

**Mark Erhardt**: Yeah, so this is actually a question from 2013, but I randomly
stumbled on it and the other answer was outdated and not that useful, so I wrote
a new one.  So, I looked at these two blocks because obviously they were easy to
find and had these enormous transaction fees collected.  And the interesting
thing is that both of these have a transaction that pays an outrageous amount of
fees and they both look like someone used createrawtransaction probably to make
a test transaction or something, and they didn't realize that they needed to
create a change output.  Because if you create raw transactions, none of the
funds are automatically allocated.  So, if you only make a recipient output, all
the rest will go to fees.

So, maybe the thing that is to be learned here, if you use createrawtransaction,
(a) try it out on testnet, learn how it works first; (b) read the docs, because
it says so there; and (c) maybe don't experiment with inputs that have over 200
bitcoin in them, especially these days, because yeah, that just hurts to see.

**Mike Schmidt**: Murch, question about tooling: what tools did you use to
surface these two blocks?

**Mark Erhardt**: Oh, Blockchair is a block explorer that sort of gives you
direct access to the database, and you can sort the queries by fields.  And in
this case, I just used the Block Overview on Blockchair and sorted by highest
fee in Bitcoin and highest fee in dollar, and it just basically spit out
directly the results.

_bitcoin-cli listtransactions fee amount is way off, why?_

**Mike Schmidt**: Next question, "bitcoin-cli's listtransactions fee amount is
way off, why?"  The person asking this is doing a payjoin transaction and
wonders why the listtransactions RPC shows a fee that is 2,000 times larger than
the fee in reality, which he references on mempool.space.  Ava Chow noted that
this can occur when one of the inputs is unknown to the Bitcoin Core wallet.
And Ava used the example of coinjoin as another example of when this can occur,
essentially when one of the inputs is unknown to the wallet.  And Ava noted in a
follow-up comment, "The wallet really shouldn't be returning the fee here since
it can't accurately determine it".  Murch, I saw you participate in this
discussion as well.  What do you think about it?

**Mark Erhardt**: Yeah.  So, it took me a moment to realize how this could even
happen, because obviously when you see a transaction on the network, you must
have the UTXOs still in your UTXO set.  And then when the wallet realizes that
it belongs to your wallet, it will store a copy of the UTXOs along with the
transaction in your wallet data.  So, Bitcoin Core does not have a complete
index of all transactions and especially not all addresses.  So, the wallet
itself will take note of the transactions that are relevant to the wallet, and
that is what enables us to still remember what UTXOs were used to create a
transaction, because you have to remember in an input, you only reference which
transaction output was spent per the outpoint.  So, you know the txid and the
output index, but you don't actually know the script or the amount that that txo
had.

So, the way you can even arrive at this point is if you import a key, or at a
later time look at a transaction that was associated with your wallet but you
didn't see when it was unconfirmed or appeared in a block, you wouldn't know the
transaction inputs anymore.  And then, if you don't reindex in order to
reassociate, like find the entire history and see all the transactions that
belong to you, you might have an incomplete set of the inputs for the
transaction that is relevant to your wallet.  Your wallet sees though that it
knows some of the inputs, and therefore makes this mistake that it thinks it can
calculate the fee because it knows some of the inputs, but really with
incomplete information it just shouldn't serve that field.  So, yeah, I don't
know if a bug's been filed yet, but that probably should be fixed.

_Did uncompressed public keys use the `04` prefix before compressed public keys were used?_

**Mike Schmidt**: Next question, "Did uncompressed public keys use the 04 prefix
before compressed public keys were used?"  Pieter Wuille answered this one,
"Yes, indeed, uncompressed keys did use the 04 prefix before compressed keys
were used".  And then he actually went on to explain that there actually is
support, not only for uncompressed keys with the 04 prefix, compressed keys
which use 02 and 03 prefixes for negative and positive y values, but also this
thing that I haven't heard of before called hybrid public keys, which use the 06
and 07 prefixes; and sipa can't figure out what the 06 and 07 hybrid public keys
are for, but Murch, do you know?

**Mark Erhardt**: I think my understanding is that OpenSSL had just some very,
very weird support for stuff that nobody should ever do.  I believe that
compressed keys, let me remember.  I think they only store the x value and
remember which y value belongs to it because you can calculate the y value from
the x value; and uncompressed keys just store x and y value; and hybrid keys
store x and y value and tell you whether to use the positive or negative y
value, which makes absolutely no fucking sense!

_What happens if an HTLC's value is below the dust limit?_

**Mark Erhardt**: Thanks for elaborating, Murch.  Next question, "What happens
if an HTLC's (Hash Time Lock Contract's) value is below the dust limit?"  And
Antoine Poinsot noted in his answer that, "Any output in an LN commitment
transaction could have a value below the dust limit", and that that would result
in the value in those outputs, the satoshis in those outputs, being used instead
for fees, instead of an output below that dust limit being created.  We also
referenced the topic on Optech.  It goes into trimmed HTLCs, and that covers
some of that in more detail.

_How does subtractfeefrom work?_

Next question, "How does subtractfeefrom work?"  Murch, I saw that you answered
this one, so I'll punt this one over to you.

**Mark Erhardt**: All right.  So, very early on, there was a way implemented in
Bitcoin Core Wallet how the fees that you need to submit a transaction to the
network and get it mined are not deducted from the change output, but rather are
deducted from the recipient output, and this was called subtractfeefrom on
sendmany; but there's also subtract_fee_from_outputs on send and
subtractfeefromamount on sendtoaddress, which is not confusing at all.  So, the
issue with this is that since then, we came to the realization that if you look
for a changeless input set on wallets, and especially if you use the effective
value of inputs rather than their actual value, and effective value in this
context means you know at what feerate you're building a transaction, so you
calculate for an input how much block space it'll take to add it to the
transaction, and deduct fees per the feerate times the input size from the
input's value, and therefore you know if you add that input to the transaction,
it has paid for itself already.

Previously, Bitcoin Core had to build it, try to fund a transaction, realize,
"Oh, I don't have enough money left to pay for fees", do it again and again
until it had a big enough change output that it could deduct all the fees for
the inputs.  So sometimes, Bitcoin Core would use multiple rounds of funding in
order to find sufficient inputs, which had quirky, terrible behavior.  I wrote
about this in my master thesis in 2016 if you want to read it.  Anyway, there is
an issue here when you deduct the fee from the recipient output and you create a
changeless transaction.  If you create a changeless transaction, it is allowed
to drop a little bit of overshoot to the fees.

So, a very unreasonable example, if you want to pay 0.99 bitcoin to someone and
you find a 1-bitcoin input and you pay a bunch of fees, the remainder might not
be big enough to make a change output, and you then just drop the remainder to
the fees, makes the transaction have a slightly higher feerate, the recipient
gets paid, and you don't have to pay for creating a change output with a tiny
amount.  However, if this amount that you are dropping to the fees affects the
fees taken from the recipient output, you might actually increase the amount
that you're sending to the recipient, if the amount that you're dropping is
slightly higher than what you were actually paying in fees.  And (a) that could
lead to confusion when the recipient gets more money; (b) it breaks some other
assumptions in Bitcoin Core.

Anyway, subtract_fee_from_outputs is a huge mess.  It's like this quirky
historical artifact in the code base.  We can do this sort of stuff better now.
Please use sendall if you're trying to clear out a wallet and please know if
you're using subtract_fee_from_outputs, it'll not create changes outputs because
it's just easier.

_What's the difference between the 3 index directories blocks/index/, bitcoin/indexes and chainstate?_

**Mike Schmidt**: Awesome context there.  Thank you, Murch.  Last question from
the Stack Exchange, "What’s the difference between the 3 index directories for
Bitcoin Core: "blocks/index/", "bitcoin/indexes" and "chainstate"?  And the
person asking this saw that there were these three directories used by Bitcoin
Core, some of which can take up a lot of space, and asked about the purpose of
each.  And actually, Ava Chow answered.  Ava Chow answered and described each of
the three index directories: blocks/index/, which is mandatory and contains the
database from block index; the chainstate directory, which contains the database
for the UTXO set; and the indexes directory, which can contain the optional
indexes for txindex, coinstatsindex, and blockfilterindex, all three of which
are optional.

_LND v0.18.1-beta_

Moving to Releases and release candidates, we have two this week.  First one,
LND v0.18.1-beta.  This is a minor hotfix release that includes one bug fix.
The bug fix resolves an issue that came up when handling an error after
attempting to broadcast transactions.  So, the error actually has to do with
btcwallet, which LND uses, and btcwallet does some text matching on error
message text which comes from btcd.  And those error message strings, or those
pieces of text, conflict between btc versions, causing issues for LND.  So, this
hotfix resolves that.

_Bitcoin Core 26.2rc1_

Bitcoin Core 26.2rc1.  Murch, the only thing I had in my notes here was
encouraging folks to test it.  Did you have any other calls to action on this
one?

**Mark Erhardt**: I did not, no.

**Mike Schmidt**: Great.  Notable code and documentation changes.  If you have a
question for René, Murch, or myself on this newsletter, or anything Bitcoin,
feel free to request speaker access.  We'll try to get to your question.

_Bitcoin Core #29575_

Bitcoin Core #29575.  Murch, you're our resident Bitcoin Core dev, so have at
it.

**Mark Erhardt**: Yeah, so this is a refactor.  It deals with the P2P behavior.
So, we used to have a scoring system where we sort of kept track of the score of
peers that misbehaved and slowly incremented it depending on what sort of
shenanigans they were doing.  And Pieter here took the stance that really, we're
just telling exactly to a potential griever how much grievances we'll accept of
each type so they can bug us and then stop doing it before they actually get
discouraged.  So, this behavior used to potentially lead to a ban where we would
just no longer accept connections from a specific peer.  And for example,
sending a block that wasn't connected to our graph would increase the score by
ten.  So, he changed the behavior here that it will either always accept
behaviour if it's not really that detrimental, or it will immediately discourage
a peer when they engage in this detrimental behavior.  So, it gets rid of the
whole score tracking; it increments the score attributed for misbehavior either
to 100 for each of the behaviors, or sets it to zero to make it acceptable.  And
then, so once a peer misbehaves now, and that is only the things that we still
consider misbehavior, we immediately disconnect them.  And, yeah, so it's just
sort of a cleanup.

There's a list of the things, the actual behaviors that are now immediately
punished with disconnect.  If you maintain a different Bitcoin implementation
that was previously using any of those behaviors, you might want to look over
the list to see whether you'll get a lot of disconnects.  I don't assume that
this actually affects anyone because previously, this would already lead to
disconnects just after several uses of misbehavior.  Yeah, anyway, it just
cleans up some code, removes 70 lines of code or so, and that's it.

**Mike Schmidt**: It sounds like a clear win here, Murch, but are there any
potential objections or downsides to going this route?

**Mark Erhardt**: No, it just seems like a simplification code cleanup and makes
it clearer what behavior is acceptable and not acceptable to Bitcoin Core nodes.

_Bitcoin Core #28984_

**Mike Schmidt**: Bitcoin Core #28984, adding support for a limited version of
RBF for packages with cluster sizes of two.

**Mark Erhardt**: Yeah, we've been talking a ton about package relay and also a
little bit about cluster mempool.  All of this is starting to slowly come
together into stuff that will be in the next release.  So, we can now submit
packages to our own node already, and in the next release, we'll also be able to
propagate packages with up to two transactions per this orphanage hack that we
talked about a while back.  And this PR now also addresses replacements for
packages.  So, while we propagate packages with up to two transactions already,
and support for tracked transactions is in 28, or the current master branch from
which 28 will be cut.  This also allows replacing transactions when you send a
package.  It will so far only permit replacements of packages with up to two
transactions by packages with up to two transactions, however you can replace
multiple packages.

So, for example, if there's two different transactions that spend some inputs
and you make a replacement that spends inputs that conflict with both of those
original transactions, you could replace up to 100 transactions, just like
before.  So, this is largely compatible with how replacements were restricted
previously.  It just makes it slightly more lenient in that now when we consider
a package of up to two transactions, it can also replace stuff.  Now, it wasn't
super clear how replacements should be evaluated in regard to whether or not
they actually make the mempool better, and that's where cluster mempool comes
in.  This PR borrows the feerate diagram metric from cluster mempool, where we
basically draw a feerate diagram of the transactions that are being replaced and
overlay it with the feerate diagram of the transactions that we replace it with.
And we require that the feerate diagram is higher or equal in each and every
point of the diagram for the replacement in order to accept it.

This makes it way easier to think about how to evaluate which portions of a
package to replace, because there's an explosion of complexity here.  If you
have a ton of transactions in a package, you could only replace subsets, maybe
only the conflicting subset, or anyway, it would be very complicated to evaluate
whether something makes the mempool actually better or not.  And this feerate
diagram sort of gives a clear metric per which we can evaluate it.

**Mike Schmidt**: We talked about that feerate diagram in Newsletter #296 and
also Podcast #296, if you're curious more about those feerate diagrams that
Murch mentioned.

**Mark Erhardt**: Also, unabashed shill, if you're coming to TABConf, I plan to
give a talk on cluster mempool.

_Core Lightning #7388_

**Mike Schmidt**: Excellent.  Core Lightning #7388, a PR titled BOLT catchups
for v24.08.  And this PR simplifies Core Lightning's (CLN's) codebase, since
many old LN features can now be assumed.  We covered those simplifications and
those assumptions in Newsletter #259 and Newsletter #305.  One thing that we
noted in the writeup for this PR was CLN removing the ability to create
non-zero-fee anchor-style transactions.  This is actually from BOLT #824 that
made a change to anchor outputs to mitigate fee stealing attacks, and it
specified that all re-signed HTLCs, those spent should use zero fee, so no fees
could be stolen.  And we talked about this potential fee-stealing attack in
Newsletter #165 and #115.  CLN was the only LN implementation that added support
for non-zero-fee anchor channels.  And so, as part of this PR, that support was
moved moving forward.  Oh, Murch, sorry.

**Mark Erhardt**: No, that's good.  I was confused by the term "non-zero-fee
anchor transaction".  It is slightly unclear to me because up to now, actually
as far as I know, no Bitcoin implementations propagate any zero-fee transactions
on the network, even if there is a child transaction that pays enough fees.  So,
is this non-zero fee actually non-minimum fee, or was there actually a use of a
zero-fee transaction here anywhere?  René, do you happen to know this maybe?
Actually, I see a request here.

**René Pickhardt**: Yeah, I mean I agree.  If you don't have any fees, the
transaction would not be relayed.  I'm not sure if it's already part of the
package, because the HTLCs are part of the commitment transaction which usually
has quite some fees with the anchor.  So, I'm not sure how that would be
working, but probably it's just a minimum, but I haven't looked at it, I don't
know, sorry.

**Mark Erhardt**: Greg, enlighten us.

**Greg Sanders**: So, this is referring to the fee in the contract itself.  So,
zero-fee HTLCs means you have one input, one output, you're using
SIGHASH_SINGLE, and the input and output amounts should match.  So, there's zero
fee inherent.  But you can do exogenous fees by bringing your own input and
change output.  So, that's the difference.  The experimental version that was
never taken up had fees built into it already.

**Mark Erhardt**: I see.  So, it refers only to a pair consisting of an input
and an output, and they have to match in the node.  Thank you.

_LND #8734_

**Mike Schmidt**: Thanks, Greg.  LND #8734 makes an improvement to the
estimateroutefee RPC, specifically if an LND user stops that RPC command while
it's running, which can be used for doing payment probes, previously the client
side of the program would stop immediately, but the server which was processing
the command would continue probing unnecessarily.  So, LND added a cancellable
flag that would now cancel the background payment loop if the user cancels on
the front end.

_LDK #3127_

LDK #3127, which implements non-strict forwarding.  This allows LDK to forward
an HTLC along a channel other than the one specified by the short_channel_ID in
the onion message.  This can improve payment reliability if there's multiple
channels with the same peer.  So, LDK would now choose the channel with the
least amount of outbound liquidity that can forward the HTLC, and that would
maximize the probability of being able to successfully forward a subsequent
HTLC.  BlueMatt noted, in an issue that motivated this PR, "I believe we're now
the only major LN implementation that insists on forwarding HTLCs over the same
channel as described in the short channel ID in the onion.  Instead, all other
implementations will happily forward over a different channel if another one is
available to the same counterparty node and it doesn't have enough liquidity in
the first channel.  We should do the same".  Murch?

**Mark Erhardt**: Something you said just made me stumble, and that is you said,
"The least amount of outbound liquidity".  I think it must be, "The least amount
of outbound liquidity that is sufficient to forward the payment", right?  So, it
takes the smallest amount of capacity that is enough, which means that bigger
pieces of capacity on the router's side remain intact.

**Mike Schmidt**: Yeah, that's correct.  The least amount of outbound liquidity
that can forward the HTLC, yeah.

_Rust Bitcoin #2794_

We have a Rust Bitcoin PR, Rust Bitcoin #2794, which adds enforcement of the
P2WSH witness script sizes.  Well, maybe stepping back, there's two script size
limit checks in Bitcoin.  First, P2SH, the redeemed script must be less than 520
bytes, which was defined in BIP16; and then second, P2WSH, witness script must
be less than 10,000 bytes, which was defined in BIP141.  Previously, Rust
Bitcoin was only enforcing the P2SH limit and not the P2WSH limit, and this PR
adds enforcement of that second limit.  And to paraphrase a couple pieces of the
PR, well I guess it's not a quote, it's a paraphrase, but, "Our APIs assume the
script that was hashed is valid.  Therefore, there is the potential for users to
get burned by creating addresses that cannot be spent".  Any comments there,
Murch?

**Mark Erhardt**: Yeah, it's funny, you can create outputs that require an input
script that actually will not be accepted onchain.  And it's good when
implementations catch this if you're trying to do it.  I'm wondering what may
have led to people finding out that they're trying to build input scripts that
are too large.  Maybe people are experimenting with CatVM or something.

_BDK #1395_

**Mike Schmidt**: BDK #1395 removes a dependency on rand, like random, from BDK.
Rand is a Rust library for Random Number Generation (RNG), and rand is being
replaced with rand-core, which can allow for BDK users to implement their own
RNG, or they can also choose to use the existing rand implementation.  This
simplifies dependencies and I think there's some thread considerations there as
well.  For BDK, rand was previously used in signing and also when shuffling
inputs and outputs during transaction building, and also in their
single-random-draw coin selection.

**Mark Erhardt**: I don't know enough about Rust to actually understand the
motivation here.  It's kind of normal for programming languages to have some
source of randomness built in.  If you're just shuffling transactions, you
probably are fine with pseudo-randomness, sorry, transaction inputs, right?
Sure, you want it to be somewhat random, but at most you leak a little privacy
if someone finds out how it was shuffled.  But that is just fairly absurd
because you don't know what implementation created a transaction in the first
place.  So, I'm a little wondering whether this has to do with cleaning up
pseudo-randomness versus cryptographically-safe randomness in the code base, but
yeah, I don't know anything about Rust.

**Mike Schmidt**: Yeah, and there's also that threading consideration as well
that I didn't get into, that was mentioned in the PR.  So, maybe something
performance-related there, not sure.

_BIPs #1620 and BIPs #1622_

BIPs #1620 and #1622 both changed the silent payments BIP.  Mert, you're also
our in-house BIP maintainer.  What do you think?

**Mark Erhardt**: Yeah, so it seems to me that a bunch of people are working on
implementing silent payments and improving the -- so, I know there's already
some existing implementations, but the Bitcoin Core implementation is actually
still in the works.  So, this is just edge cases being discovered and surfacing
while people are very carefully thinking about everything that needs to go into
a safe implementation.  Here specifically, my understanding is that people
noticed that it could happen that the sum of private keys could become zero or
the sum of pubkeys could sum up to the point at infinity, and both of those edge
cases had not been handled.  I believe that that would have to be actively
caused by one of the participants to happen, otherwise it would just be
astronomically unlikely.  But yeah, the BIP now explicitly specifies what to do
in those cases.

Then there was also a slight simplification notice by the stack.  There is just
something about the order in which the input hash, which acts essentially as a
salt on how the -- sorry, let me give a little more context.  In silent
payments, the output script of the recipient is produced by doing an elliptic
curve Diffie-Hellman between the input keys and the silent payment address of
the recipient.  And if an input had the same output script as a prior silent
payment that you made to the same recipient, you would reuse the same address.
So, there is a hash in here that is based on the outpoint of the inputs that are
being used, which is unique and therefore we will never create the same output
script with silent payments.  And this input hash was calculated twice in how
the BIP describes the reference implementation reference of steps, how to
implement it, and the stack realized that you could turn around the order and
therefore only calculate it once, which simplifies the explanation slightly and
removes the calculation.  The spec did not change though, the outcome is the
same, it's just a refactor.

_BOLTs #869_

**Mike Schmidt**: Last PR this week to the BOLTs repository, #869, introduces a
new channel quiescence protocol on BOLT2.  Quiescent is defined as, "A state or
period of inactivity or dormancy".  So, there's this specific introduction of
this state of dormancy in a channel protocol.  This is a simple protocol for
upgrades and splices and other things which are easier when there's no updates
that are in flight.  So essentially, this is a way for two nodes to communicate
with each other like, "Hey, let's stop sending HTLCs around, let's make some
changes to the channel".  It adds an option-quiesce feature to the BOLT2 spec,
which nodes use to identify support for the stfu message, which is defined as
SomeThing Fundamental is Underway, "Various fundamental changes, in particular
protocol upgrades, are easiest on channels where both commitment transactions
match and no pending updates are in flight.  We define a protocol to quiesce the
channel by indicating that SomeThing Fundamental is Underway".  And then, it's
actually up to the dependent protocols to specify termination conditions of the
quiescence to prevent the need for disconnection in order to resume normal
channel traffic.

So, in the example of splicing, the splicing protocol would then have to say
like, "Let's resume normal communication".  And one final note here was that
that this PR was originally opened in May of 2021.  Any thoughts on that one,
Murch or René?

**Mark Erhardt**: Yeah, I think I just wanted to jump in to say why something
like this would be useful.  So, while nodes are active, obviously they would, at
irregular intervals, just receive a request to create an HTLC.  And then there's
this dance back and forth to update the channel state, where first the sender
offers a new state where they have less money and the recipient has more money,
the recipient then accepts that new state and therefore can release its hold on
the old state because the new state is better for it, and so forth.  There is
this, I think it's like a five-step process to update channels.  And while the
channel is being updated, the two channel partners may be at different steps of
the commitment transaction sequence.  So if you, for example, want to splice-in
funds or splice-out funds or adjust other channel parameters, it is useful to
sort of settle at the same state for a moment, and this apparently happens by
saying stfu and something fundamental is about to happen, right?  Anyway!

**Mike Schmidt**: René, thanks for sticking on.  We actually do have a question
for you.  Vincent commented in the Twitter thread here, "René, I only caught the
tail end of your talk, but I was wondering how you would use the DRS library to
sample feasible wealth distributions".  I don't know if that's DRS or how you
pronounce that, but are you familiar with that library?

**René Pickhardt**: Yeah, that's the library that works to sample uniformly from
those geometric objects, in particular hyperplanes.  So, yes, that's actually a
little bit tricky.  For Bitcoin wealth distribution, that's an easy one, because
you literally just create a random vector there.  The problem is, on the LN,
when you randomly sample from this polytope, what could happen is that the
result is not a feasible wealth distribution.  So, one way of achieving this is
to just sample several times and then conduct the test.  I have an open PR on
this repository that shows the linear program with which you can test if the
sampled wealth distribution is actually a feasible one.  So, let's say you want
to have 100 feasible wealth distribution, what could happen is that you have to
sample, let's say 1,000 times, and only every 10th time you get a wealth
distribution that was feasible on the LN.  But then you take those and they are
randomly from the LN polytope of wealth distribution.  So, that is possible.

Another way in this DRS library is that you can set bounds to the values.  And
what you would do is you could set the upper bound for each node to be the total
capacity that the node is allocated to, because other wealth distributions are
very obviously not feasible.  So, you can tweak the library a little bit.  But
what we show on the network is the larger the network gets, the less likely it
is that a sample point is actually in the LN polytope.  So, what you would have
to do then is, instead of using the DRS library to sample from the LN polytope,
you would have to conduct a random walk in order to create a few states or a few
wealth distributions.  So, yes, those are details that I hope to elaborate on in
the future.

**Mike Schmidt**: Thanks, René.  And René, thank you for joining us today and
hanging on.

**René Pickhardt**: Thank you for doing this every week.

**Mike Schmidt**: Yeah, you're welcome.  Thank you all for listening and to my
co-host, Murch.  We'll see you all next week.

**Mark Erhardt**: See you next week.

**René Pickhardt**: See you next week.  Thank you.

{% include references.md %}
