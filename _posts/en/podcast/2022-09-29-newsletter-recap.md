---
title: 'Bitcoin Optech Newsletter #219 Recap Podcast'
permalink: /en/podcast/2022/09/29/
reference: /en/newsletters/2022/09/28/
name: 2022-09-29-recap
slug: 2022-09-29-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Anthony Towns and Andreas
Kouloumos to discuss [Newsletter #219]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-15/347188941-22050-1-43e68ae4d2c99.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody, Bitcoin Optech Newsletter #219 Recap.  I
should share the tweets so that you can all see it, if you don't already have it
up in front of you, but bitcoinops.org.  I am Mike Schmidt, contributor to
Optech and also Executive Director at Brink, where we help support and fund
Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs, I'm a moderator on
Bitcoin Stack Exchange, and I try to contribute to various education stuff in
the Bitcoin Core codebase.

**Mike Schmidt**: Stickies-v, I also sent a speaker invite to you if you want to
jump in at any point, feel free.  All right, so we've got a couple of
interesting news items this week.

_LN fee ratecards_

The first one is LN fee ratecards, and this is an idea from Lisa from
Blockstream about changing the way that indicated feerates are transmitted on
the LN.  Right now, if you have a channel, you can just keep the default feerate
or you can somehow plug in your own dynamic feerate, or set it manually for that
channel.  But this notion of fee ratecards sort of stratifies the feerate so you
can provide potentially four different feerates depending on the capacity
available in that channel.  And so, it gives you a little bit more granularity
on how you price your fees, and also introduces the notion of potentially
negative fees if, for whatever reason, you want to incentivize channel capacity
going a different way to provide liquidity on network.  So, there's been some
discussion on the mailing list about this.

ZmnSCPxj actually described it in what Dave Harding thought was a simple way,
and I think it's a simple way too, which is you can think of, I'll quote him
here briefly, "You can model a rate card as four separate channels between the
same two nodes, so instead of treating it as just one channel, there's four
channels.  And then from a routing perspective, there'd be different costs for
each.  If the path at the lowest cost fails, you can try another route that may
have more hops but a lower effective cost, or else try the same channel again at
a higher cost".  So, I thought that was a good mental model, at least for me, to
wrap my mind around it.  Murch, what are your thoughts about ratecards?

**Mark Erhardt**: I think that's a pretty decent and cool proposal.  So, you
said that you can set a dynamic feerate for a channel.  Maybe let's look at that
a little more specifically.  A channel currently has a feerate in each
direction.  So, if there's Alice and Bob as the channel owners, there is the
direction where Alice forwards through Bob or the direction where Bob forwards
through Alice.  And they own the feerates for the direction which they forward,
and the person that forwards collects the fee in that direction.  So, if
somebody routes through Bob, through Alice to somewhere else, the step Bob to
Alice collects a fee for Bob.

So, when you dynamically price your channel, what you really do is every time
you go past some certain threshold or with some timeout, you do a channel update
and you announce to the network a new feerate for your channel.  So, that is not
very dynamic, you actually have to tell the whole network every time you want to
change the feerate.  And with these fee ratecards, you can basically have set
feerates whenever your channel goes into certain capacity ranges, or I should
say balance ranges, because the capacity stays the same, and it's separated into
four parts, so one-quarter, half, and three-quarters.  So, for example, if you
had more than 75% of the balance on your side, you might want to give a negative
fee to incentivize someone to send through you.  So, you'd pay them sats to
forward a payment for you because it shifts the balance towards the middle.

So, I think it's pretty cool, and it should actually reduce the number of
announcements on the network.  That's, I think, the main point here.

**Mike Schmidt**: Hey, AJ.

**Anthony Towns**: Hi.

**Mike Schmidt**: Do you want to give a quick introduction of yourself and what
you're doing in the Bitcoin space, and then maybe you can also comment on fee
ratecards as well as I know you had some points?

**Anthony Towns**: So, I'm AJ, Anthony Towns, I work on Bitcoin stuff at DCI and
I like Lightning and Bitcoin and Core and everything else, and I find it hard to
not be interested in stuff so I tend to work on everything.  I'm super-skeptical
about the fee ratecard stuff, because as far as I'm concerned, all you're doing
is saying that, "Okay, my feerate depends on my channel balance", but how are
you going to know the channel balance, which is meant to be private anyway,
without gossiping the channel balance.  And if you're gossiping the channel
balance, then you might as well just gossip the feerate in the first place.  I
haven't seen it implemented, so maybe it actually works out and I'm just crazy
to be skeptical, but I still am, I guess.

**Mike Schmidt**: And I think one of the concerns that you brought up, and
perhaps Dave Harding brought up on the mailing list as well, was this potential
perverse incentive that since that channel balance information wouldn't be
gossiped currently, that there would be centralized providers that would be
collecting that information and then that's potentially a bad thing happening on
the network.  Did I get that right?

**Anthony Towns**: Yeah.  I mean, if you're saying that you're going to be
paying people to forward through your channel sometimes, then that's
super-useful information for people who run other channels to have.  And so,
maybe that means that you get some secret consortium of people who are
constantly probing channels to find out when they're in this low-balance state
and are going to be offering you these huge payouts, do the rebalancing, and
then, I don't know, secretly pass that information on, so that these people who
are doing all this stuff in secret can make more profit running tunnels and
start pushing other people out of the LN.  I mean, maybe none of that happens,
but it all doesn't really sound like the kind of open, decentralized, you fire
up a Raspberry Pi and start making money, and that's all you have to do to be
just as good as everyone else, kind of concept that I have in my head.

**Mike Schmidt**: What do you think, Murch?

**Mark Erhardt**: Hmm, so I think that the secret cabal of people collecting the
channels that are currently in the I pay it forward for me mode seems a little
unlikely, because the best thing they could do is to act on that information to
collect that payment.  And what they're doing then is rebalance the channel,
which (a) closes the opportunity, and (b) balances out at least that channel.
Maybe unbalances another one.  But it sort of feels like it might increase the
throughput and the reliability of most routing attempts because channels would
be more likely to be in the center of their capacity or have balanced capacity.
I don't know.  We'll have to see.

It would certainly increase the number of attempts you might need to route
through channels, because you would have to maybe try twice in a channel before
you realize what feerate you need to use on a channel.  But we already try a ton
of times until we find a good route.  So, I don't know.  We'd have to try it
out, I guess.  And maybe while we're talking about trying out things, we could
start talking about inquisition, unless AJ has another thought on the fee
ratecards.

**Anthony Towns**: Well, I will just say that I am skeptical, but I'd much
rather see people try stuff out and prove me wrong than just say, "Oh, AJ's
skeptical", or, "There's negative opinions, so let's not even try anything".  I
think trying stuff's always better.

**Mike Schmidt**: AJ, you brought up a point as well that pricing based on
channel capacity might not be the only reason that someone would vary the fee
pricing.  I think you mentioned the idea of a use case based on time of day, or
day of week, or something like that.

**Anthony Towns**: Yeah, if you're trying to make the most money by pricing
something, then you want to be able to kind of discriminate that pricing so that
when people are willing to pay a lot of money, they will pay a lot of money
because that's what you set the price at; and when people aren't, then you set
lower prices to still kind of make the most profit.  And in an ideal world,
maybe that's the sort of thing that varies by time of day, or time of month, or
maybe it's not.  The problem with varying it by time of day is that we just
can't afford to have gossip go out that frequently.  So, one of the things in a
discussion with ZmnSCPxj earlier this year, I guess, is that I thought a
ratecard that specifies feerates by time of day rather than by channel balance
could be interesting, particularly because time of day isn't private information
in the first place, so you're not adding any weird perverse incentive potential.

But I mean, countering that is, if you're trying to compete with Visa or
something, then Visa doesn't discriminate by time of day.  They're just giving
you a percentage fee all the time.  And maybe that's better to encourage more
payments in the first place, just having something simple that works all the
time.  I don't know.  There's lots of interesting ideas in that kind of area.

**Mark Erhardt**: Maybe one more thought.  I guess you could just simulate the
fee ratecard already by having multiple channels between two nodes and having
separate feerates for them.  And then, sometimes if requests come in or even
during certain times of the day, you could just decline to forward them on a
cheaper channel.  So, I guess you wouldn't even need to communicate about this
to be able to implement it.  Is that right?

**Anthony Towns**: I thought C-Lightning (CLN) might have problems with that,
and it would certainly be like four times as much gossip compared to just adding
the data in a single gossip message.  But yeah, otherwise yeah.

**Mark Erhardt**: Well, at least you wouldn't have to make updates.  So, there's
maybe four times the initial announcement but a few updates later.

**Anthony Towns**: Sure.

**Mark Erhardt**: Okay, back to you Mike.

_Bitcoin implementation designed for testing soft forks on signet_

**Mike Schmidt**: Sure.  So, the next item from the newsletter was one proposed
by AJ himself on the Bitcoin dev mailing list, and I think it would make most
sense for him to outline his idea.  And perhaps one way to introduce the idea,
AJ, would be maybe get into the background of the motivation for this and then
what is this software fork, and then we can go from there?

**Anthony Towns**: Sure.  So, the reason I started thinking about it was in the
context of consensus upgrades, like ANYPREVOUT (APO) and CHECKTEMPLATEVERIFY
(CTV).  And I mean, Jeremy's been pushing for, I don't know, two years or
something now to try and figure out how to get CTV merged under the idea that
it's the simplest sort of covenant thing that you could possibly do.  So, if
it's simple and it's well reviewed, let's do it.  And there's been a lot of
confusion about what doing it would actually involve.  So, he's posted a PR to
Core to try and get that merge just so that, even without activation, just get
it merged so that it's in core and that way he doesn't have to continually
rebase the changes.  People can test things on regtest or maybe testnet, and he
can get some movement on it.

But the problem with merging stuff into Core is that then it's an extra code
path that everyone running mainnet has that code path in their bitcoind.  And if
there's bugs in that code path, then maybe that somehow affects mainnet, even
though you haven't actually deployed CTV, and causes a consensus split and
everyone loses all their money.  So, obviously we're really reluctant to merge
changes to Core that are going to affect consensus code and cause all those
risks.  But if you can't even merge a PR, then how can you test it and get
better progress and get the community involved and better understand what's
going on?  And so Jeremy's been pushing that.

I mean, I've been listening to him and watching him do things and trying to come
up with a better suggestion.  And in, I guess, April or so this year, I thought
about it in the context of the thing called linux-next, which when people are
adding drivers and stuff to Linux, often they'll get it merged into linux-next
first and can then do some testing and stuff there, before going through all the
possible pain of getting Linux to accept it into Linux proper.  And so, I
thought about the same sort of thing for consensus changes in Bitcoin, where you
just have a fork of Bitcoin that no one runs against mainnet, so it doesn't
introduce any risks of real money getting lost, but it is a place where you
actually can see forward progress by getting things merged.  And that then makes
it easier for people to test against and see that, yes, this is an actual thing
that is making progress, so it is worth spending my time on.

For things like APO, the purpose of APO isn't just to have a new signature
thing, it's to make new applications possible, like Eltoo, so that we can have
an LN that is easier if you lose data so that doesn't cause you to lose money,
or so that you don't have to have as many resources to maintain a channel by
having to keep all the data around forever.  The idea is to make an actual
application more efficient, not just to have some new feature that nobody uses.
And if you want to say APO is actually worthwhile, then you should really
implement those features and see them working, rather than just have a
whiteboard theory that says, "Yeah, this is possible and maybe someday it'll
actually happen".

So, the idea of Inquisition then is you have a fork of Core and you merge these
PRs and then have them active on a real network.  And then you can build these
applications, demo the applications and see them working in something
approximating real life.  And so, that's the idea.  And then the practical thing
for that is, once you have some new feature that you want to try out, maybe that
new feature doesn't actually work out the way you expected it to, and you have
to roll it back.  And then that, with the soft fork model, means that you have
to do something a little bit cleverer because soft forks can't be rolled back.
Rolling back a soft fork is a hard fork and we don't like hard forks because
that forces people to upgrade.  And so there's a bit of work in Inquisition to
make a deployment mechanism where that works.  And yeah, so that's the technical
side of things.

Then, I think Bitcoin Knots was originally Bitcoin Next, or so I'm told, so I
didn't want to call it Bitcoin Next because that'd be a bit confusing and a
little bit presumptuous to actually assume any of this is ever going to make it
into Bitcoin.  And so, after seeing the reaction to Jeremy trying to activate
CTV, the first thing that came to mind was an Inquisition, so I jumped on that
thread, and that's the naming theme for stuff.  So, yeah, I think that's the
introduction.

**Mike Schmidt**: So currently, this is a repository under your GitHub; is that
correct?

**Anthony Towns**: So, I made a GitHub organization called Bitcoin Inquisition,
and forked Bitcoin into that organization.  And so, I think I'm currently the
owner of the organization and I've made Kalle a member, so I think he should
also be able to merge PRs and stuff.  I haven't really looked into how it works.
Kalle is the other signet global network signer.  I haven't really figured out
how to run that organization or add other mergers, or whatever.  That's on the
to-do list, I guess.

**Mark Erhardt**: I was wondering, one of the things that CTV had done in the
proposal to activate it was that it had its own signet.  What's the advantage of
having one Inquisition network rather than a signet for each soft fork proposal?

**Anthony Towns**: So, first of all, there's moderate disadvantages to setting
up a custom signet for a particular thing, in that it's a bunch of effort and
you have to set up a whole bunch of other services, like a faucet and explorer,
kind of at a minimum.  So, the first advantage of having it apply to a single
existing signet is that all that stuff already exists, so you don't have to set
it up again.  A second moderate advantage maybe is that at least the global
signet has some traffic on it, so you're not setting up a signet where no one
ever actually uses it.  At least, when I had a look earlier this year, despite
having set up the signet and talked about it in public, the CTV signet basically
had zero transactions that use CTV.  So, that didn't really prove anything and
kind of made it seem like a bit of a waste of time setting it up.  Since then
it's had some transactions; it still hasn't had any in I think the last month or
so.

But the advantage of having all these ideas on one signet is that it means you
can compare them more directly.  So, if you're writing an application that tries
to make Lightning channel opens non-interactive, which is one of the proposed
advantages of CTV, but would also work with APO, is that you're able to, once
you modify the code to do it one way, you can then modify the application to do
it the other way and compare the two more directly, which I think is worth
trying out.

**Mark Erhardt**: Super, thanks.

**Mike Schmidt**: How has reception been both on the mailing list, as well as
any feedback that you've gotten outside of public channels that you're willing
to talk about so far?

**Anthony Towns**: So, the frustrating thing is that people are often much more
happy to give positive constructive feedback in private than in public, which is
something I'd really like to change, but I haven't figured out a way of doing
that.  And I always hate it when people say, "Oh, I've had private feedback
that's positive, so just ignore the public feedback"; that's ridiculous.  But
yeah, there's been some good private feedback.  It's great.  At the moment,
where I'm up to is I've got the PRs merged for the deployment stuff so that you
can undo a soft fork, or so that soft forks are temporary and you can have a
signal that triggers their deactivation; and I've merged the CTV backport, so
it's included in the repo; and I've got the APO PR open that's now being updated
to work compatibly with CTV, because they touch similar lines of the code, so
the PRs aren't compatible unless you do one first and then the other second.

In doing that, I had a look at rebasing APO over CTV.  There's some change in
CTV that made that incompatible that I had to look through, and that turns out
there's a little bug in CTV that we're discussing in that PR as well now.  So,
yeah, we found a bug in CTV already.  That's exactly what we want to have as an
outcome of this sort of thing.  So, that has the functionality kind of ready to
go.  I've got a couple of bitcoind nodes running that against the global signet
now.  I've also mined a couple of blocks on the global signet to trigger those
nodes, treating those forks as active; and I've also mined a couple of APO
transactions on signet using those nodes to generate a block template, so that
there are now some APO transactions on signet, which is pretty cool.  And I've
successfully managed to steal money from myself by doing signature replay
against APO addresses, which I think is fun.  And I've lost my train of thought!
What was the question?

**Mark Erhardt**: Yeah.  So, you mentioned a few times that you've done signet
transactions, but in the context of Inquisition, I thought those two are two
separate signets.  Are they going to be merged?  So is the regular signet going
to run these experimental soft forks at the same time; or, how are the two
related?

**Anthony Towns**: So, one of the advantages of the soft fork approach is that
if you introduce a soft fork, you can still follow the chain that enforces the
soft fork with old software that doesn't enforce the soft fork.  That's the
definition of what a soft fork is.  And so, the approach I like, which is under
discussion on the mailing list, is to just have a single signet which is
compatible with Core, because any additions from Inquisition are just soft
forks, and is compatible with Inquisition because the miners are enforcing the
soft fork rules.

So, the big question about that is, what happens if there's a bug in one of the
soft forks and it's not actually a soft fork, it's a hard fork, and so Core
won't follow the chain?  And so, what I've been doing and haven't published or
PRd is changes to the signet miner code, so that instead of just pointing the
signet miner at a single bitcoind node, you can point it at two nodes.  So, the
idea there is to have it primarily point at a Core node, which just guarantees
that all the blocks that the signet miner produces or sees or publishes are
compatible with Core, but to give it the option of getting block templates from
an Inquisition node, so that the Inquisition node can generate a block template
that includes transactions that match the soft fork or relay, or whatever rules.
And then once it has signed that block generated from the template, applied
proof of work to the block, and generated a valid block as far as Inquisition is
concerned, it then takes that block and doesn't submit it to the Inquisition
node, but submits it to the Core node, which then verifies that the block is
compatible with the original rules, isn't a hard fork, doesn't cause a chain
split.  And then the Core node publishes the block via PDP to the network, and
then that makes its way back to any Inquisition nodes.

So, that is what I'm currently running on my miner, which gets about 10% of
blocks, and I think is a sufficient design to avoid any bugs in the Inquisition
code, Inquisition node, whatever, from making signet incompatible with Bitcoin
Core.  Does that make sense?

**Mark Erhardt**: Yeah, that sounds like a nifty setup.  So basically, you build
the Inquisition blocks, but then you funnel them out through a Bitcoin Core
filter so that most blocks on the network are not actually doing Inquisition
stuff, but there's some portion of it.  And so, you get the global traffic of
people just testing their apps against signet, and you still keep it all
compatible for the regular users or enterprises that want to try out stuff
before they launch it on mainnet.

**Anthony Towns**: Yeah, and so the advantage of that approach is also that if
you're already on signet, there's a little LN building up.  And so, once you've
got that, if you're then implementing Eltoo with APO, or something similar, if
they're on the same signet, then you can take advantage of the existing extra
infrastructure there too and connect your Eltoo nodes up to the regular signet
LN and verify that that's compatible, and then make use of maybe some of the
transaction paths insofar as Eltoo Lightning and regular Lightning are
compatible, which they're supposed to be.

**Mark Erhardt**: Super.  So, what are you looking for in people besides
positive feedback that's public?  Would you like people to go jump in and test
it; or, what's the stage of your project?

**Anthony Towns**: So, as with everything Bitcoin related, more review is
encouraged and welcome.  So, there's been a few people that have picked up the
APO PR against Inquisition and started reviewing it, which is absolutely
awesome, and some of the first review that APO has actually seen.  So that's
fantastic, and more of that is absolutely brilliant.  So, the next step for me
is to get these changes actually PRd and published and usable by Kalle, and
whatever else, so that we've got a consistent view of things and it's not just
me testing stuff.  And so, once those PRs are merged into Inquisition, at least,
the idea is to publish a Guix build or something, and at that point I think
people running the code and building up little tests, whether that's something
complicated like Eltoo or running CTV vaults, or re-implementing a CTV vault
with APO and seeing what the actual difference between the two is, I think is a
cool thing to do.

**Mark Erhardt**: All right.  So, we'll stay tuned until we see some Guix builds
from you, and then we will encourage people to build their prototypes on
Inquisition.

**Anthony Towns**: Yeah, and I've talked a little bit with Gloria about getting
some of the package relay, or some of the v3 transaction relays with ephemeral
outputs and whatever possibly going on Inquisition.  I'm not sure how that will
work out, but reviews of those PRs, if they make it, and trying that stuff out,
that'd be cool too.

**Mike Schmidt**: AJ, is there any feedback yet, or any reason that this
wouldn't continue?  It sounds like you've made good progress, not only on
posting your thoughts on the mailing list, but also creating the supporting
infrastructure and deploying it, and people can start using it soon.

**Anthony Towns**: Yeah, one of the things I was most surprised by was how easy
it was to set up a fork and actually have the CI testing stuff work.  So I had
to, I don't know, configure GitHub or something, but as soon as I'd done that, a
simple setting change, all my PRs were getting full CI coverage, which was
pretty cool.  Yeah, I think there is maybe a question of whether it's -- so, I
think it's pretty clear to me that the best idea is to try it on the global
signet because I think that this approach should keep it stable against Core.
If that turns out to have more problems than I hope it does, then we'll want to
switch it to a separate Inquisition signet, but I think that would work fine
too.  Yeah, then it's just a matter of firing up nodes and trying stuff with it
and doing cool things.

I mean, then there's all the other soft fork ideas that aren't as progressed as
far as CTV or APO are.  So, there's the OP_TX alternative to APO and CTV, and
there's doing annex stuff, and there's the great consensus cleanup stuff that I
think we could all test all that stuff out.  I think it'd be pretty easy to add
OP_CAT to Inquisition, so that at least people can build experiments with it,
even if we don't have any plans on adding that as a soft fork to Core; having it
available on Inquisition for experiments might still be worthwhile.  And I'm
pretty hopeful that once we get these first couple of steps done, there's a
whole plethora of ideas we can play around with later.

**Mike Schmidt**: AJ, you may have already mentioned it during this chat, but
what's the plan for if you wanted to roll back one of these soft forks if, for
whatever reason, folks decided that that wasn't valuable, and how do you pull
that out then?

**Anthony Towns**: Right, so the Bitcoin Inquisition GitHub has a wiki which
explains a little bit about this, but the activation approach is completely
different to how it works on mainnet, because obviously signet is a permission
system, so all blocks are signed by a few people, whoever runs the signet.  And
so, there isn't really a question of whether activation is by voting for signet,
its activation is whatever the miners of the signet choose it to be.  And so,
there's still a question of how users of the signet realise that a soft fork has
been activated or not by the miners.

So, the way I've got it set up is that each soft fork has an identifier.  So,
for APO, it's the BIP number, which is 118, and then there's a subversion of
zero for it.  So, you take those two numbers together, shift them a bit, and
that comes up with a particular 32-bit version number, which is I think
0x607700.  And so, what Inquisition does is it looks for a single block in a
particular timeframe that has the block version as that particular number, and
that's the activation signal, at which point there's the usual lock-in delay.
And after that lock-in delay, the soft fork is enforced.  And to go the other
way, we just have a slightly different number, one that starts with 4 instead of
6.  That triggers the soft fork to stop being enforced.  And so, once the signet
miners issue a block with one or the other of those versions, that's what
changes the enforcement rules for all the nodes that are running Inquisition.
That make sense?

**Mike Schmidt**: Yeah, that makes sense.  Thanks for clarifying.  Murch, any
other questions about Inquisition?

**Mark Erhardt**: Nope, I think all my questions have been answered.

**Mike Schmidt**: AJ, you're welcome to stay on and opine as we go through the
rest of the newsletter.  I know it's late where you're at, so if you need to
drop off we understand, but thanks for walking us through that.  Great.  All
right, so every month we have a week that we cover selected questions and
answers from the Bitcoin Stack Exchange.  And so, we have four different
questions that we thought were interesting this month, and we can go through
those now.

_Is it possible to determine whether an HD wallet was used to create a given transaction?_

The first one is, "Is it possible to determine whether an HD wallet was used to
create a given transaction?"  And so, this is a question of if there's anything
about a particular transaction that you can look at and say, "Oh, this was
either an HD wallet or a particular wallet software".  And the answer here was
from Pieter, who answered the question simply by saying that there's no way to
identify UTXOs created using an HD wallet.

But he did go on to list ways in which fingerprinting wallets using other
aspects of the transaction can be done using onchain data.  So, that would be
the types of inputs used, the types of outputs that are created, the order of
the inputs and outputs in the transaction, the coin selection algorithm, and
also the use and type of use of timelocks.  And certain wallet software has
certain behavior which you can look onchain and have a pretty good idea that it
was created by this type of wallet software and not that type of wallet
software.  And so, the term "fingerprinting" is used often in this regard.
Murch, I know this is something you're a bit familiar with.  Do you want to
elaborate on any of that?

**Mark Erhardt**: Yeah, I mean, this is pretty much it.  You can't really tell
who created a key because the keys should be uniformly random.  But you can see
or identify a wallet from its patterns in the blockchain and the pedigree of the
UTXOs, and things like that.  So basically, all the things that you would do to
try and identify whether a cluster of addresses pertains to a specific wallet
and all the fingerprints that a software might have that corresponds to that
wallet, those apply to identify whether or not it was an HD wallet, because a
lot of specific software was only created after HD wallets came to pass.  And
it's basically, I would say, not all, but most wallets today should be using HD.
And so, you can just tell whether or not that applies.

**Mike Schmidt**: Is there, Murch, a publicly known wallet fingerprinting that
you can use as an example of a certain wallet software doing certain things that
ends up identifying itself onchain?

**Mark Erhardt**: Yeah, there's for example a wallet that sets a block height
for all of the transactions, and basically has the first step of anti-fee
sniping set up, but then it doesn't enforce that locktime.  So that, for
example, would stand out a little bit among other transactions.  Then there is
just a combination of whether you enforce locktime, whether you use RBF, whether
your inputs are sorted compatibly, or whether you enforce BIP69, which is the
canonical ordering of inputs and outputs.  Sometimes you can tell from amounts.
Some wallets will always create change that is smaller than recipient outputs,
sometimes some wallets do not.  Things like that.

If you have enough data that you have been able to cluster together, you might
be able to tell what wallet the cluster is created by, what wallets they're
from.

_Why is there a 5-day gap between the genesis block and block 1?_

**Mike Schmidt**: Makes sense.  The next question from the Stack Exchange this
month was, "Why is there a 5-day gap between the genesis block and block 1?"
And, Murch, you answered this question, so maybe you want to give an overview of
the answer here.  I thought there was a good bit of Bitcoin trivia that at least
I was not aware of previously.

**Mark Erhardt**: Sure.  So, as most people might know, the mailing list first
saw the announcement of the whitepaper, I think it was on October 31 in 2008.
And then in January, Satoshi actually released the software.  And while the
genesis block is timestamped January 3, and uses the headline from the London
Times with the bailout of the Chancellor on the brink of a second bailout,
right, the first block could not have been created after January 1, because it
obviously refers to the newspaper, but we don't know when it was created
exactly.  It could have been created a few days later, especially since it seems
that the genesis block has a very low hash, a surprisingly low hash.  It might
be that Satoshi set himself a higher difficulty to mine the genesis block.

So then, after that, the announcement was only at 7.27pm UTC on January 8.  So,
while the genesis block refers to a public datum in January 3, the mailing list
announcement with the release of the 0.1 version was only the 8th.  And the
first Bitcoin Core version -- sorry, it wasn't even called Bitcoin Core then;
the first version of Bitcoin would not mine unless it had found a second peer on
the network.  So, even after it was announced to the mailing list, it would have
taken someone to be interested enough to start running it, and then, I'm not
sure if Satoshi had a node running.  He must have had one node running.  And
then, when a second node came online and discovered it as a peer, it would have
started mining.

But remember, the difficulty one is so difficult that the first difficulty
increase was only in December 2009.  So, even if there were maybe the first
laptop or desktop at home, maybe with CPU mining also, not GPU mining, no ASICs,
nothing like that, it might have taken a significant amount of time until the
first block was found after that.  So, that's why even though the genesis block
is dated on January 3, the first block was found on January 9.

**Mike Schmidt**: I think there's a good amount of Bitcoin trivia in there.  I
suppose Satoshi may have been running more than one node as well, such that it
could have progressed, even without a separate individual running a second node
as well.

**Mark Erhardt**: It looks like, I think, Jameson Lopp had the deep dive
recently, but I've seen that argument somewhere before.  But it looks like he
actually might have not mined for the first five minutes after a block was found
to give other people a chance to have a head start.  So, he must have thought
very deeply about the dynamics of mining and incentivizing others to get coins,
and things like that.  Yeah, anyway, it's fascinating, those early mining
histories.

_Is it possible to set RBF as always-on in bitcoind?_

**Mike Schmidt**: Yeah, absolutely.  The next question is about RBF.  This is a
more general question, "Is it possible to set RBF as always-on in bitcoind?"
And Murch, both you and Michael Folkson chimed in on a couple of different
points here, one noting the wallet RBF configuration option is one way to enable
that, and then a series of related changes around RBF, including defaulting it
in the GUI, then defaulting it to RBF when you're using RPCs, and then finally
using mempoolfullrbf, which allows replacements without signaling.  So, I think
the question was relatively basic, but I think it's interesting to see the
progression of RBF as you and Michael Folkson outlined.

**Mark Erhardt**: Yeah, I think the RBF discussion has changed a little bit
since the BIP125, or actually the very end of BIP125 that Bitcoin Core uses has
been implemented.  So back then, that was, I want to say 2015, and the
discussion was around whether or not we need to protect zero-conf transactions,
and there were quite a few businesses that were sort of relying on quick
throughput and insisting on that being a valid business use case for them, or an
important business use case.  And on the other hand, there is the argument that
we can never really enforce that the policy is followed.

So, when somebody broadcasts a transaction, there is no guarantee that this
version of the transaction is actually what gets included in a block, because we
have neither relay guarantees for transactions, nor do we have guarantees that
anything gets included; miners do their own transaction selection, right?  So, a
lot of developers for a long time have favored an approach where replaceability
is easier, and we do not have this sort of fake promise that a zero-conf
transaction will remain unchanged.  And so, it would actually align the mining
incentives better, it would help with a bunch of pinning attacks, and it would
make it easier to replace transactions on a network when there is, for example,
a lot of transactions waiting to be confirmed to reprioritize them.

So, I think there's been a bit of a shift towards more people wanting just
full-RBF without the opt-in.  And yeah, the 24.0 release will include the new
option, mempoolfullrbf, for configuring your node to allow replacements, even if
the original transaction had not opted in to replaceability.  So, some people
are running that already with the pre-release version from master.  If enough
people adopt that, we would see that replaceability will happen without
signaling.  And yeah, well, enough nodes and some miners would have to adopt it
for that to work.

_Why would I need to ban peer nodes on the Bitcoin network?_

**Mike Schmidt**: Our last question from the Stack Exchange is, "Why would I
need to ban peer nodes on the Bitcoin network?"  I thought this was a good
opportunity to contrast the discouraging of a peer with manually banning a peer
yourself either, I guess, using the RPC.  So, you might want to ban a peer if,
by your standards, it is misbehaving or it's a suspected malicious or
surveillance node or part of a cloud provider.  There's a bunch of reasons you
may want to choose to ban certain nodes, and you can do that using the PC.  But
there's also this discouraging of a peer, which is not something that is done
manually, that's something that's sort of baked into the software.  Murch, do
you want to talk a little bit about discouraging a peer versus banning a peer?

**Mark Erhardt**: Actually, you're catching me a little off-guard, I must admit.
I get the point, if you're running a node, you're paying for the bandwidth of
the upload, right, or usually not paying, you usually have some big package.
But you might want to choose who you spend your bandwidth on, and then banning
peers that you do not support seems just like a customization of where you want
to redirect your resources.  The discouragement, I think, is sort of, are you
getting at preferential peering and things like that?

**Mike Schmidt**: Yeah, essentially discouraging a peer, meaning there's some
sort of behavior in the code that is identified as this peer is not a great
peer, and then they're discouraged, which essentially pushes them for eviction.
Essentially it doesn't ban them, it just says that, "We don't prefer to be
interacting with this peer if there are better peers on the network", which is
different from manually saying, "Hey, I want to ban the peer with this address",
or whatnot.

**Mark Erhardt**: Yeah, there's a bunch of mechanisms where Bitcoin Core will
sort of keep a connection open with a peer, but if they're slow to respond or if
they haven't given us a block announcement in a long time, they're basically in
the position of the peers that gets replaced next if we get a new connection.
So, we try to rather keep around the nodes that often give us good data, or
quickly give us data, and the ones that are not as useful to us get disconnected
earlier.  This was, for example, relevant in the antecedent of the Bitcoin Cash
fork, where we introduced preferential peering, and would preferentially
disconnect nodes that signaled that they would be supporting the Bitcoin Cash
fork.  And yeah, I think that might have smoothed a little bit the topology
reorganization when they actually split the two networks.

_Core Lightning 0.12.1_

**Mike Schmidt**: Great.  Release and release candidates, so there's a
maintenance release for Core Lightning (CLN), which I don't think that there's
anything important that we should talk about in that regard.

_Bitcoin Core 24.0 RC1_

But we do have an interesting one, which is the Bitcoin Core 24.0 RC1, for
testing changes to the latest version of Bitcoin Core, yay!  And Andreas, I'm
not sure if you're here or if you accepted the speaker invite, but I was
thinking it would be nice if you could outline some of the testing work that
you've done in facilitating people to be able to test, and then the PR Review
Club yesterday as well.  I see you took speaker access.  Do you want to maybe
provide a quick overview of 24.0, as well as the Testing Guide and how the PR
Review Club went yesterday?

**Andreas Kouloumos**: Yeah, hello, I hope you can hear me.  It's my first time
talking to a Space.

**Mike Schmidt**: We can.

**Andreas Kouloumos**: Great.  So, maybe we can give a bit of context for people
not familiar with the process first of the RC, and then get into what we are
testing.

**Mike Schmidt**: Yeah, go ahead.

**Andreas Kouloumos**: Two major versions of Bitcoin Core are released every six
to eight months.  And when all of the PRs for a release have been merged, the
RC1 is tagged.  And then this RC is tested, the issues are found, fixes are
merged into the branch, and a new RC is tagged.  And this continues until no
major issues are found in the RCs.  So, for a robust release, it is essential
that the RCs are thoroughly tested.  And anybody can help on that, either you're
a developer or not, either you're familiar with the command line or not, and
that was the point of the Review Club yesterday.  The goal is to get more people
involved with testing and help address any issues.  And although the Review Club
was yesterday, you can continue if you go through the Testing Guide.  And I will
now talk a bit about the Testing Guide.  You can do the Testing Guide and keep
posting questions into the IRC channel.

So, the Testing Guide is something that is created since the last four releases,
and it outlines some of the upcoming changes and provides steps to help people
test them.  Some of the changes that this release has is the new headers,
pre-synchronization phase during IBD, which is an important change, because
actually, the logic for downloading the headers from peers has been reworked to
address a potential DoS, which further opens the path for removing checkpoints.
There are some changes in Bitcoin-Qt, in the GUI; those are changes that people
which are not familiar with the command line can easily test, so it's encouraged
for people to test them.  We have a change in the I2P outbound logic, and all of
those things, you can see them in the Testing Guide.  I'm not sure we have a
link here, and I think it's not in the newsletter, but you will easily find a
link around if you want to go through the guide.

**Mike Schmidt**: I just shared your tweet in this Space.  So, you should be
able to at least find it there, I think.

**Andreas Kouloumos**: Yeah, there is also the link for the Testing Guide and
also for the yesterday's PR Review Club, because there is a log, so you can also
go through that log.  So, another important change is the transient addresses
for I2P outbound connections.  You can read also, just to know, that all the
sections in the Testing Guide include a gist of each change and if needed, a few
extra details.  And my goal writing the Testing Guide was, by going through the
Testing Guide, you will get the context of each change and help you understand
it.  So, that goes for the I2P outbound connections, the new logic there.

Also another important change that has to do with the wallet.  As the legacy
wallet type will soon be unsupported, there is a new migration mechanism.  So,
part of the Testing Guide is testing the migration mechanism to migrate your
legacy wallet to descriptor wallets.  And talking about descriptor wallets,
another interesting change with the new release is the support of the watch-only
Miniscript output descriptors.  So, the Testing Guide also includes that,
together with added context for Miniscripts and external links, if you want to
dive deeper into those changes.  Those are the main changes that the Testing
Guide has.

I just want to emphasize that this guide is meant to be the starting point to
get you started with testing.  Most of the individual changes are well tested
during the review phase, when the code is introduced to the codebase.  What's
more complicated to test is how everything behaves together on different
configurations and different user patterns.  Therefore, it's encouraged to do
your own testing and experimentations.  And in the bottom of the Testing Guide,
you will find a link for the version 24 testing issue where you can report your
findings, and also report that everything works well in your system.  It's not
just to report issues.  I don't know if there's something else that I didn't
cover.  If anybody has questions or I can add something else.

**Mark Erhardt**: Yeah, there's a new RPC to do sendall and it's not in the
Testing Guide!  I'm teasing.

**Andreas Kouloumos**: Yeah, I would like to apologize for that.  It didn't make
it through.

**Mark Erhardt**: No, sorry, your Testing Guide is awesome, I really like it.
So, there's a bunch of new things coming in the 24.0.  I think that also not in
the Testing Guide is another thing that we mentioned earlier, is the
mempoolfullrbf, which might be interesting to get tested more.  So, if you are a
power user, aspiring Bitcoin developer, or otherwise really interested in this
process, check out Andreas' Testing Guide and just maybe find one or two things
that you're interested in and just try to run through that, or look through the
release notes.  There's a release note draft up for the 24.0 release that might
give you a few more ideas of things that need to be tested more, and just play
around with them.  Just maybe try to do the things that you usually do with your
Bitcoin Core wallet on signet and see if everything works the same way it used
to.  And whatever weird things happen, don't forget to file an issue with the
Bitcoin Core codebase afterwards.

**Mike Schmidt**: Andreas, thank you for putting that together and thank you for
hosting the PR Review Club.  I was watching along yesterday and I think it's a
good way for folks to get acquainted with how to use some of these components,
how to test some of these components, and so thank you again.  And thanks for
joining us as an impromptu guest last minute when I sent you a message a minute
ago!

**Andreas Kouloumos**: Yeah, thank you.  And I'm now thinking that because
yesterday's meeting was, I mean, at least for me, it was kind of fun, so maybe
because the process with the RC will go, I believe, I think for a few weeks, I'm
thinking that maybe we could repeat that, how we talked with PR Club
maintainers.  But even if we don't repeat something like that, which is just to
get more people involved, please, for anyone that wants to get involved with the
testing, if you have questions, the IRC channel is open.  Just ask questions all
day, and we'll go through them if you have any issues.  And thank you for having
me.

**Mike Schmidt**: Absolutely.  We have a few code and documentation changes to
go through really quick.  I know we're a bit over time already, but I also
wanted to take this opportunity to solicit any questions that the audience may
have for us or AJ or Andreas.  You can request speaker access, and while we run
through these PRs, at the end of that I'll grant speaker access.

_Bitcoin Core #26116_

Okay, so Bitcoin Core #26116 is a change to the importmulti RPC, and it'll allow
a watch-only item to be imported even if the wallet's private keys are
encrypted.  I don't really know that too much of the history behind that but
that seems fairly straightforward.  Murch, I don't know if you have a comment on
that?

**Mark Erhardt**: No, pretty much that.  You don't need to unlock your wallet to
add watch-only data because it's only public keys.  So, your history and
everything is actually not encrypted, so the wallet data, your balances, your
transaction history would be visible if somebody gets access to your wallet;
it's only the key material that's encrypted.  So, just make sure that you can
actually write to that even without de-encrypting your wallet, because it's only
affecting unencrypted data.

_Core Lightning #5594_

**Mike Schmidt**: Great.  The next two are Core Lightning PRs.  So, #5594 is
essentially beefing up this autoclean plugin.  So CLN is a plugin-based
extensibility, and there's this autoclean plugin that is deleting old invoices,
payments and forward payments, which is I guess particularly useful for larger
nodes that may be bogged down by some of that extra data.  And I think there's
some additional optimizations that were made as well.  Murch, any thoughts on
that one?

**Mark Erhardt**: I heard some legends about big nodes having hundreds of
megabytes of database entries, and yeah, I think that was a different
implementation, but it sounds useful.  Also, what would help really would be if
APO came out, and with APO we can keep much less state per channel.

_Core Lightning #5315_

**Mike Schmidt**: I wonder if anybody's working on that!  The next PR here is
Core Lightning #5315, which adds a feature for allowing the user to choose the
channel reserve for a particular channel, and I'll read a bit from the
newsletter here, "The reserve is the amount a node will normally not accept from
a channel peer as part of a payment or forward.  If the peer later attempts to
cheat, the honest node can spend the reserve".  So previously, CLN was
defaulting to 1% of the channel balance, so penalizing by that amount if there's
an attempt to cheat, and this PR allows someone to customize the reserve for a
specific channel.  And so you could, in theory, take that 1% reserve that you
were using and drop that to zero; although there's all sorts of reasons you
shouldn't do that, you can now do that.  Murch, do you want to comment on
channel reserves and the ability to reduce it to potentially zero?

**Mark Erhardt**: Well, in the penalty update mechanism, really we want to be
sure that if somebody broadcasts an old state that is already revoked, that we
can punish them and take all their money.  And that is, of course, only an
effective threat if they do have money left.  So, if we allow them to have a
balance of zero in our channel, they can broadcast an old state with a high
balance without any danger of losing any money.  So, this is certainly not
something that everybody would want to do.  And it's also often a criticism of
APO that Eltoo channels are not APO, but Eltoo channels do not have a penalty
mechanism, and people think that channel ownership dynamics might be very
different if there's no penalty, no sword that people can bring down if there's
cheating going on.

Now, it turns out that there's a bunch of different things people do on the LN
and maybe in some relationships, it is more useful to be able to use the full
balance of the channel than it is to be able to punish them.  If you, for
example, have a pre-existing relationship with the other party, where all the
parties are known, they have other contracts or business relationships already,
and this channel balance is just a small drop in the big pond of what they do
together, then they might not care to maintain an amount that they can penalize
with, but rather would just have the lower friction of having a zero reserve.
In other cases, maybe if the channel balance is very low, you might want to set
a higher reserve so that there's always an amount left that you can penalize
with.  So, I guess that's sort of what this panders to.

_Rust Bitcoin #1258_

**Mike Schmidt**: Great.  Thanks, Murch, that was a good explanation.  The last
PR in this newsletter was Rust Bitcoin #1258, and I think we've been covering a
bunch of Rust Bitcoin PRs that have to do with timelocks, and this is another
timelock-related PR.  And this allows a method for comparing two different
timelocks to determine if essentially one satisfies the other one, so if they're
somewhat overlapping so that one locktime will be satisfied if the other one is.
And so, there's some redundancy, I guess, then that you could identify.  The
example here is that if you have two CHECKLOCKTIMEVERIFY (CLTV) operations
within a script, you can essentially optimize by removing the smaller values
since the other one, the larger value, would make that smaller value redundant.
So, Rust Bitcoin provides that comparison functionality with this PR.  Murch,
are you excited to talk about Rust Bitcoin locktimes again?

**Mark Erhardt**: No, I think you've covered it well.  So, do we have any
questions from the audience?  Now's your last chance to ask for speaker.  Maybe
I can talk meanwhile while people find the "request speaker" button.

We launched this week something that I've been working on for about a month on
and off that I'm pretty excited about.  So, I'm one of the people that helped
bring about the whentaproot.org page.  So, people have been asking why we only
focus on Bech32m sending support and what exactly our goals are with that, and
how we're going about this.  Our idea is, taproot activated in November and we
would like to see all wallet services, Lightning apps, and whoever, ready to
send to Bech32m first.  It's a super-simple change, especially if you already
support sending to Bech32m addresses.  In the reference implementation, it's a
two-line code change to add support for Bech32m addresses, if you already can
decode Bech32 addresses.

If there is broad support across the ecosystem to create P2TR outputs, I think
we'll have less support requests, less headaches, less people worrying about
just releasing software that only uses P2TR in the future.  And I know already
about a couple of cool wallet projects that want to do taproot only.  So, this
is our push to help people encourage and test participants in the network,
whether they are already ready to create P2TR outputs and understand Bech32m
addresses.  So, if you haven't seen it yet, check out whentaproot.org, and you
might see that some of the bigger businesses and exchanges are still on the list
of people or entities that don't support it yet.  But we'd actually like to see
that tested maybe also.  So, if you have a very small amount of Bitcoin on one
of those, you might want to try and see what happens if you send that to a
Bech32m address, and that would help us.

**Mike Schmidt**: Excellent, yeah, Murch, I think you somewhat doxed yourself a
few weeks ago when you had to join this recap with your whentaproot handle, so
we knew it was coming!  Yeah, great job with the website.  The design looks
really great.  Yeah, I saw that yesterday.  I did have a question.  Is the plan
to raise awareness and hope that folks either at these organizations that aren't
supporting it yet see it and circulate it internally, or that the community sees
these actors that haven't supported it yet and reach out to them; and/or do you
and some of the folks behind this effort plan to reach out to these services to
try to let them know that they should be doing that?

**Mark Erhardt**: All of the above.  So, we've had some people reach out.
Sometimes they even respond and they ask like, "Hey, where can I read up on this
in a one-pager?  So, I think that our site gives a pretty decent overview of
what we're asking.  I think that it's spiffy enough, as Stephen DeLorme did a
great job with the art, he made all the bunnies and things like that.  So, it's
spiffy enough that when people have questions about it, they just get linked to
it and it might just circulate on Bitcoin, Twitter and elsewhere.  And
hopefully, it's also a good enough talking point if, say, an engineer at, say,
Coinbase were interested in Coinbase supporting it, that he can just take that
and show it to the relevant decision-makers and say, "Hey, we should be doing
this".

So, yeah, we just wanted to give tools to people that want to help their
organizations adopt it.  And, yeah, that's it.  And I think maybe as Bech32m
support grows, we might evolve the website to help with other topics.  But
first, if everybody consented, it'll be easier to use them.

**Mike Schmidt**: I see you went with the capital B, Bech32m.

**Mark Erhardt**: Yeah, clearly it's a proper noun, and proper nouns are
capitalized in English.

**Mike Schmidt**: You're violating the Bitcoin Optech style guide!

**Mark Erhardt**: Harding sometimes like small-cap words a little too much!
Okay, we are getting a request here.

**Mike Schmidt**: I see.  Okay, Seardsalmon.

**Vivek Kasarabada**:  What's up?  I wanted to ask Murch, how difficult is it to
get people to switch from Bech32 to Bech32m; or are we trying to get them to go
from like P2SH still to Bech32m all the way; are we going to leapfrog them?

**Mark Erhardt**: Well, obviously legacy must die.  It's all taking more block
space.  Yeah, no, I'm not being entirely serious, but there's a scalability when
quadratic hashing goes away once you use native segwit, and or even wrapped
segwit already.  And the wrapper for wrapped segwit is just an extra 32 bytes
that we could get rid of.  So, I would love to encourage people to just use
native segwit in general.  I think that P2WPKH, which is the v0 native segwit,
is already a big improvement over previous output types.  And P2TR, I think,
will have some benefits for a lot of people for a single-sig, maybe not
immediately.

But one of the things that I'm, for example, really excited about is bequesting
bitcoins.  So, if you have bitcoin and you are worried that someday you won't be
there for your loved ones anymore, you might have a leaf in your taptree that
they can spend already with keys they hold already, but don't know about yet.
And then, you only have to communicate the descriptor of how to find those
leaves in your will, but they have the keys already and no man-in-the-middle can
take the money and pretend that it never was there.  And all of that you can do
in what looks like a single-sig under the hood with every single output that you
receive.  So, stuff like that I think will also provide benefits to single-sig
users really early on, or not early on, maybe not quite that early on,
unfortunately.

Then there's cool projects that are coming up, where we are going to see
multisig applications even with threshold signatures, and that will give people
some benefits of hardware security, even while they are very flexible with their
spending.  So, yeah, as we see those projects come up, I hope that we will have
prepared the way for them that they can launch with all those features out of
the get-go, and don't have to support legacy ways of receiving funds in order to
appeal to the broader space.

**Mike Schmidt**: Thanks for putting that together, Murch, Murch and team.
Anything else before we wrap up?

**Mark Erhardt**: That's all I have.  I hope to see a bunch of you at TABConf in
two weeks.

**Mike Schmidt**: Yeah, that's right, we have TABConf in a couple of weeks.  A
bunch of us will be there.  AJ, thank you for joining us and commenting on fee
ratecards, as well as presenting your Bitcoin Inquisition idea.  I think it's
valuable for folks to hear it from the source.  And thank you for joining us at
1.00 in the morning.

**Anthony Towns**: 2.00 in the morning now!  Thanks for having me.

**Mike Schmidt**: Absolutely.  And thanks, Andreas, for putting the guide
together and jumping on with us.  And we'll see everybody next week after
they're done testing the 24.0 RC.

**Mark Erhardt**: Cheers, it was fun.  See you.

**Mike Schmidt**: Cheers, bye.

{% include references.md %}
