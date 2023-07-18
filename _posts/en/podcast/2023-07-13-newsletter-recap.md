---
title: 'Bitcoin Optech Newsletter #259 Recap Podcast'
permalink: /en/podcast/2023/07/13/
reference: /en/newsletters/2023/07/12/
name: 2023-07-13-recap
slug: 2023-07-13-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao, Bastien
Teinturier, and Martin Zumsande to discuss [Newsletter #259]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-6-13/339158167-22050-1-c98be5e7d1208.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #259, Recap on
Twitter Spaces.  It's Thursday, July 13th, and we'll be talking about LN spec
changes, new developments and policy in our transaction relay and mempool
series, a PR Review Club about P2P, and then we have a release and just one PR
to cover this week.  By way of introductions, I'm Mike Schmidt, a contributor at
Bitcoin Optech and Executive Director at Brink, where we fund Bitcoin
open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Hi, I'm Gloria, I work at Brink on Bitcoin stuff.

**Mike Schmidt**: T-bast?

**Bastien Teinturier**: Hi, I'm Bastien.  I work at ACINQ on Lightning stuff.

**Mike Schmidt**: Awesome.  Well, Martin will be joining us shortly and he can
introduce himself before we talk about the PR Review Club segment.

_LN specification clean up proposed_

First item from the newsletter is LN specification clean up proposed, and this
is based on a mailing list post to the Lightning-Dev mailing list, from Rusty
Russell, and a PR as well, where he's proposing to remove some features that are
no longer supported, and in addition, assuming four other features are
supported.  Luckily, we have t-bast here to talk about the specification clean
up proposal.  T-bast, is this something that came out of the recent Lightning
Summit, or is this something separate?

**Bastien Teinturier**: Yeah, it's actually both.  It prompted us to act; we
were prompted to act during the Summit.  It's something we've always said that
since the BOLT specifications are moving documents that keep getting things
added, and hopefully at some point removed, so that we don't have too much older
legacy stuff that keeps hanging around, we've been very good at adding things,
but we haven't been very good at removing things.  Someone who comes in now and
looks at the spec sees that there are a lot of features, a lot of places in the
specification where we have a, "How to parse; if-else statement; if you have
that feature, you should do that; if you have that feature, you should do that",
and it makes it really hard for newcomers, who just want to see the latest state
of Lightning and what is currently deployed on the network and how it works.  It
makes it harder for them to read the specification, or even implement something
and see what's happening.

So, we decided that everything that all implementations support and have
supported for more than a year, we're just going to assume that those exist, and
we'll stop specifying different cases for when it's turned off.  So, that's what
Rusty did here.  He made a lot of features assumed that every node has to
implement, so that we don't have to handle the case where the remote does not
implement that feature, and we don't even have to specify what happens when
someone does not support that feature.  In the long run, there are other things
we want to clean up from the specification to make it smaller, easier to
understand, and remove the need to know what happened in the legacy channels for
newcomers.  This is going to take a while, but it's an ongoing effort that we
need to be better at.

**Mike Schmidt**: Is it correct to say that for these two unused features, that
you're not necessarily removing functionality, but you're removing certain ways
of implementing certain functionality?  So for example, this looks like initial
routing sync piece is replaced already by something that's been in the specs for
a while, called gossip queries; and similar for option anchor outputs, just
option anchors.  I just want to make sure people are clear that not necessarily
removing functionality, but removing ways of achieving certain functionality; is
that right to say?

**Bastien Teinturier**: Yeah, it's a good way to explain it.  For example,
initial routing sync is a very dumb way of bootstrapping a new node when you
connect to someone.  Initially, a long time ago, when you connected to someone
and you are a completely new node, you would say, "Initial routing sync" to tell
the other node to just dump all of the gossip data to you, and they would just
send a lot of things directly to you.  But that has been replaced with a
slightly better mechanism, called gossip queries, that has been shipped three or
four years ago by every implementation.  So now, we can just remove a very
inefficient thing that we used before, since everybody supports the new thing
that is more efficient.

For anchor outputs, the story is a bit different.  When we first implemented
anchor output, the first version of it actually had an issue.  It had an issue
where someone could siphon off the fees of Hash Time Locked Contract (HTLC)
transactions.  So, a small tweak on that anchor output mechanism was created
that we called anchor output zero-fee HTLC transactions, where the HTLC
transactions pay zero fee and are signed with SIGHASH_SINGLE,
SIGHASH_ANYONECANPAY, so that you can add fees later.  So, since we already had
a version of anchor output that was specified, but was actually vulnerable to
attacks, we kept it in the spec, but we always said you probably never want to
use that version, you always want to use the zero-fee HTLC transaction version.
So now, we just removed the old version because it's insecure, there's no good
reason to use it instead of the other one, and it was creating a lot of
confusion for people who were reading that spec.

**Mike Schmidt**: That makes sense.  And then on the flip side here, when
there's these four features that are assumed, I guess maybe a couple of
questions that I'll bundle, and you can take it however you'd like.  What does
it mean to assume a feature?  And then the follow-up question would be, based on
Rusty's results of probing around the network, he mentioned that there are still
some nodes that don't support some of those assumed features, and what would
happen, obviously we want folks to upgrade their node to the latest software,
but some of these folks haven't, what are the consequences to those nodes that
don't upgrade and don't support those assumed features?  So maybe two questions
there.

**Bastien Teinturier**: Yeah, so assumed features are really part of the minimal
set of features you have to support to be a node in the network right now, which
means that right now we are not going to actively disconnect you if you connect
to us without those features.  But in the future, if you are a very old node
that connects and does not support those features, we're just going to
disconnect you from the start.  So, you won't even be able to join the network
at all if you haven't implemented those features.

It's true that there are a few nodes out there that still have not activated
those features, but I'm not sure we really want to care about those people,
because that means they haven't upgraded in potentially three years, and if they
haven't upgraded their implementation in three years, they have a lot of things
to worry about because a lot of important bug fixes have been fixed.  Some of
them have even been publicly announced, and those nodes could potentially be
under attack and could easily lose all their funds if they don't do anything.
So, I suspect that all of these nodes are nodes that are just forgotten
somewhere on the cloud or something like that, or someone doing some tests, but
it makes no sense to keep running those nodes without the new features.  So, I
hope they just update or just start getting dropped off the network.

**Mike Schmidt**: And we noted in the newsletter those four features and
explained them in a bit more detail.  And as you mentioned, they've been part of
the specification since 2019, 2018, 2017, and 2019.  So yeah, I guess you're
several years behind if you're still not supporting those pieces.

**Bastien Teinturier**: Yeah, and and Lightning implementations before 2019 were
quite reckless.  A lot of things have been fixed since then, a lot of things
have been improved.  So, if you're running Lightning software that is more than
three or four years old, you're going to have issues, so you really should
update.

**Mike Schmidt**: Murch, did you have questions about these changes?

**Mark Erhardt**: Not necessarily.  I think there's a good overview of what
Rusty exactly proposed in the newsletter.  All of these have been, well, they're
really old changes, so I think we've covered them dozens of times.  So, no.

**Mike Schmidt**: T-Best, this is a little off topic, and I suspect that we'll
be covering it in our monthly segment on Changes to client and service software,
but there was a recent announcement of a new version of Phoenix Wallet, and I
suspect that we probably won't bother you with bringing you on when we cover
that in the future, but I wanted to give you a chance to explain that release
and any notable important features.

**Bastien Teinturier**: Sure, thanks.  So this is really a very big release.
We've been working on some of the features for that release for a year or so.
When we initially launched Phoenix, it was already quite a dramatic change
compared to what other Lightning wallets were doing at the time, because it was
the first wallet that introduced dynamic liquidity management so that people did
not have to care about their liquidity, and could just get liquidity on the fly
when they received payments, which was a huge boost in user experience.

But the issue with that is that when users end up with multiple channels on a
mobile wallet, it creates a lot of issues because they don't really know how
much they can receive, because the amount that they can receive is theoretically
the sum of the receiving capacity of each of the channels.  But that only works
if the sender is able to have that information and potentially split the HTLCs
perfectly across all the channels, which is impractical because you cannot share
all your channels in a BOLT11 invoice, and you definitely cannot share the
balance in real time.

So in practice, what happened is that people thought they were able to
potentially receive, for example, 100,000 stats.  They were asking someone to
send them 100,000 stats, but it actually could not be relayed entirely over
Lightning, so it ended up creating a new channel to relay that amount.  And it
made the problem even worse, because then the user has even one more channel.
And having more channels also is an issue for the wallet provider, because that
means that you have more UTXOs that are used for only one user, and all those
channels can potentially force close at a later time at a very high feerate and
will incur high costs for the wallet provider.  So, it's really much better to
have only one channel per user from a scalability point of view.

That's something that splicing, which is a big tech protocol change that has
been discussed since 2018, is allowing us to finally do.  So, we've been working
on that for a long time.  We now have something that is really ready, we're just
testing it out right now during the beta to make sure that people don't find any
unexpected issues, but we think it's really going to help the UX and also help
the pricing model to be much easier to understand for users.  So, it's really a
huge release.  And the goal is that people won't actually really see that things
have changed a lot under the hood, but actually they have and everything is more
efficient and should cost less.

Also, we previously had the swaps that we previously had in Phoenix were
trusted.  You would just pay us and then we would do the swap, which is
definitely not something we wanted to keep on doing for long.  Now that we have
splicing, the swaps are really entirely controlled by the user.  We have
nothing, we don't hold the funds at any time, so they are finally fully
trustless, which is really a good thing.  There are still a lot of other things
we need to add in the next wave of features, but this is really a big
improvement.  So, I hope people will try it out and people will be happy with
the changes.

**Mike Schmidt**: But t-bast, I thought splicing wasn't active on Lightning yet.

**Bastien Teinturier**: That's why it's interesting because in Phoenix, Phoenix
gives us a nice test bed for things that we want to try out on a small part of a
network.  Since Phoenix only connects to our node and splicing is only a feature
that is important for pairs of nodes, we activated it on our node, at least a
prototype version of splicing that maybe is not the final spec version, but it's
something that works and that we want to be able to try in the wild.  Phoenix
has the same code, so Phoenix and our node are able to negotiate splice
transactions.  And our goal is ideally to start testing cross-compat with Core
Lightning (CLN) as soon as possible.

But for that, we still need to first finalize, at least merge, the dual-funding
specification that has some protocol changes that are then reused for splicing.
And the dual-funding specification is still not fully implemented, at least not
the latest version in CLN.  So, we're still waiting for that to happen before we
can start moving on to cross-compat test for splicing.  But I hope that we will
get splicing merged and deployed on the network with two implementations, at
least by the end of this year, hopefully.

**Mike Schmidt**: Murch, do you have any questions or comments about Phoenix
Wallet, other than loving the fact that it minimizes the amount of UTXOs used?

**Mark Erhardt**: I thought that it's super-interesting that you're using the
swap-in-potentium idea, or a variant of that.  We covered that a while back and
had ZmnSCPxj and I think Jesse on for that.  I was just wondering, so that would
mean that you sort of staged the funds in an output that is controlled by the
user, but locked to the Lightning Service Provider (LSP) and the user for some
time; and then, eventually it would go back to the user, but it can be spliced
into the UTXO.  Is that sort of the same concept you're using, or is it always
locked to both of you because you expect that it will -- or is it locked to
ACINQ directly?

**Bastien Teinturier**: No, it's exactly what the swap-in-potentium proposal
describes.  So, the funds are first sent to an address that has two script
paths.  One is a 2-of-2 multisig between the user and our node, and the other is
a single sig from the user after a relative delay.  And the goal is that the
issue we have, the reason we use that, is that we want to make all channel
operations be able to use zero-conf, because otherwise the user's balance really
becomes a mess, especially when you start using splicing, because you have a
chain of funding transactions, and the user doesn't know what they can actually
use if you're not using zero-conf here.  So, we needed a safe way to use
zero-conf.

The issue is that whenever the user splices in, they are using one of their
inputs and adding that input directly into the channel, and we cannot trust them
to not double spend.  So, that made one of the operations, the splicing one, one
that could not use zero-conf, whereas all the other operations could use
zero-conf that could potentially be stacked after a splicing, which made the UX
really horrible.  So, using swap-in-potentium here is a way to correlate the
confirmation count from the channel operation.  You first send to a
swap-in-potentium address.  It has nothing to do with your channel yet, and you
wait for confirmations there.  And once this is confirmed, then we can splice
those into the channel, and this can use zero-conf, because the user cannot
double spend it by himself; he would also need a signature from the wallet
provider from our node.

So, this makes sure that we can make all operations on the channel use
zero-conf, which makes it much easier to track, much easier to understand from a
balanced point of view for the user, and much safer.  There's still the risk
that we could double spend, but at least we could double spend our inputs.  But
in the zero-conf scenario, the user is trusting us to not double spend anyway.
That doesn't change the business model, the security model here.

**Mark Erhardt**: Right, cool.  May I ask a pointy question, too?  I was
wondering if your channel balance is now all, or sorry, not just your channel
balance, but basically your balance with ACINQ is now always stored in a single
UTXO, doesn't that have some sort of privacy implications?

**Bastien Teinturier**: Right now, it does, mostly also because we don't use
taproot yet.  Once we start using taproot, this will be better because all those
splices, first of all people will not see that this is a channel and every time
you splice, people shouldn't be able to tell which of the output is the
remaining channel and which of the output was an outgoing payment.  But right
now, it's true that the onchain privacy is not great.  But onchain privacy on
Lightning is generally not great, and it's only going to get better once we move
to taproot.

**Mark Erhardt**: Thanks.

**Mike Schmidt**: If you're curious about this technique that we're talking
about here in Phoenix, there was a Newsletter #233, where we talked with
ZmnSCPxj and Jesse Posner about the swap-in-potentium proposal, and I've linked
to that in the Twitter Spaces here, so you can go right to that segment of the
newsletter, or our discussion with them on the podcast.  T-bast, any final words
before we wrap up this section?

**Bastien Teinturier**: No, nothing in particular.  We had a great Lightning
Summit in New York a few weeks ago.  We ironed out a lot of potential issues
with all the big features that everyone is working on.  So, I think we're all
set to deliver a lot of things this year around splicing, dual funding, taproot,
BOLT12.  So, it's finally time where a lot of those big features we've been
working on for years are going to start being shipped, so it's going to be
really exciting.

**Mike Schmidt**: Thank you for joining us.  Of course, of all the newsletters
that we have you on, we have you on today in which there are no Lightning PRs.
Sometimes we have ten Lightning PRs and it would be great to have you on, help
explain some of them, but we have one Bitcoin Core PR here today.  So, if you
need to drop to work on other things, we understand.  Thank you for your time,
t-bast.

**Bastien Teinturier**: No, I'll stay, this is going to be interesting.  Thanks.

_Waiting for confirmation #9: Policy Proposals_

**Mike Schmidt**: Excellent.  Moving on in the newsletter, we have our Waiting
for confirmation series #9 on policy proposals.  Last week, we talked about
second-layer protocols interfacing with transaction relay policy and including
examples of existing anchor output and CPFP carve out techniques.  And this
week, we build on some of the drawbacks to those techniques and explore some
in-progress efforts to address some of the limitations of those techniques and
other limitations.  We have Gloria and Murch, who are co-authors of this series,
and so I guess I'll throw it out to either one of you.  What are the issues that
we're referencing with these previous techniques, and what sort of solutions are
being worked on for the future?

**Gloria Zhao**: Yeah, so the last post introduced the concept of pinning
attacks, as well as other issues, and wanted to kind of give some hope in this
post.  And so, we talk about five different policy proposals.  I was trying to
kind of introduce them in a linear manner so that you can see it from the point
of view of like, "Oh, this problem exists.  Okay, we have this proposal to
address it, but we still have these problems left, so this next proposal
addresses some of them", and then so on and so forth.  And so it goes from
package relay to v3 and cluster and until the thermal anchors at the end, which
I think addresses most issues and enables cool things like LN symmetry.

So yeah, I think we can start with the anchor outputs model that we introduced
in the post last week, where it still has a number of limitations.  Let's say
some are very annoying, and then maybe some of them are just kind of cosmetic.
So, I think probably the worst one is that you end up overpaying on fees on
commitment transactions for unilateral closes because you have to overestimate,
because if it were to fall below the minimum feerate, then suddenly it's not
going to get into any mempool and you won't be able to get it relayed,
regardless of the child that you put on there to fee bump.  Then you have funds
tied up into your anchor outputs, you have to put some value on them to meet the
dust threshold, and then carve out is quite ugly from a layer 1 perspective, and
it only works with one extra descendant.

So, for example, if you wanted to guarantee that n parties of a more than
two-party channel in some hypothetical contracting protocol, or let's just say a
coinjoin, the carve out which allows one extra descendant only guarantees that
there will be at least two people who can attach a child to one of the outputs
of their shared transaction.  So, it doesn't quite solve the general problem of,
"Oh, we always want to make sure that any of the participants can fee bump their
shared transaction".

Then, on the more cosmetic side maybe, but Greg says that this is a
composability issue, is that you have to put the one block relative timelock on
all of the non-anchor outputs to prevent them from being spent.  It goes back to
the descendant pinning problem.  And then, that brings us to package relay and
package RBF, which solves, from what I hear, some of the more painful ones, like
not being able to bump something below a minimum feerate, a mempool feerate,
when congestion is higher.  And so, hopefully that will save people money, since
you won't have to overpay on the commitment transactions in the future, and you
can also get rid of the multiple anchor outputs.  Oh, I forgot to mention this,
you need one anchor output per participant so that they can each spend it,
right?  But if you have packaged RBF, for example, you just need one on each
person's commitment transaction and they can just replace each other.  So you
don't need to ever bump the commitment transaction that somebody else broadcast.
.

But of course, we still have RBF pinning, because we have these very generous
descendant limits in mempool policy, where that leaves room for someone to
broadcast a commitment transaction and add a very large, high fee but low
feerate child, which is not CPFPing being anything, but it does add to the cost
to replace that transaction.  And that variance is very, very high, so it could
be, I don't know, let's say 90,000 virtual bytes (vbytes).  And even at 10
satoshis per vbyte (sats/vB), that's quite a bit of money to potentially have to
pay to replace that.  And so that's quite annoying, and so this is combined with
some just general RBF terribleness.

I have a little paragraph, we wrote a little paragraph in there about the fact
that replacements don't need to necessarily confirm faster.  They have to pay
more fees, but they don't necessarily need to have a higher "mining score".  So,
if you were to build a new block template, this replacement transaction could
potentially come later than the original.  And this is a pinning problem for
ANYONECANPAY transactions, where you can imagine they're able to malleate this
transaction to essentially confirm slower by making it the descendant of a, say,
huge low-feerate ancestor in the mempool.

So, this brings us to cluster mempool.  This is where I might tag Murch in,
because you did write this portion, and because the problem with solving this is
the fact that our ancestor doesn't have limits.  We've talked about this in
multiple newsletters in the past couple months, just are way too permissive, and
it just makes it infeasible to assess the mining score of transactions in
mempools.  And so, yeah, Murch, you have your hand up.  Do you want to jump in
and talk about cluster mempool?

**Mark Erhardt**: Sure.  So, cluster mempool is an idea on how we would
differently structure the data in the mempool data structure for keeping track
of what's up for the next block.  The current proposal will keep information on
the entire ancestor set of each transaction.  And so, that has a problem that we
will never discover if there is multiple children that are all trying to bump
the same ancestors, because we would only pick the one that has the highest
ancestor set feerate out of those into the block first and then look at the
other ones, which then surprisingly have great feerates.

But with cluster mempool, what we would do is we would rather keep track of all
related transactions.  Anything that has transitively a connection through child
or parent relations would be part of the same data that is relevant for
transactions.  And in these clusters, we would linearize the order.  We would
look at a cluster as a set of transactions and say, "Okay, if I just had this
cluster and built a block from it, in which order would I pick all of these
transactions?" and we make that the order of the cluster.  And then we can group
those transactions inside of the cluster into chunks, that are essentially
packages, with the best possible feerate that is available by grouping more.

So for example, if you had a cluster that is just a child and a parent, and the
child has a higher feerate, you would discover that you first have to pick the
parent, of course, so it's in the linear order in front of the child, but the
child has a higher feerate, so you would chunk them together and treat them as
one package.  And the same thing would also work if you have two children that
have higher feerates.  So, we would sort of get the ability for descendants to
pay for ancestors rather than just children paying for a single parent to
reprioritize.

The cool thing about this approach is it would make it way simpler to build
blocks and faster.  It would also make displacement out of the mempool symmetric
to -- sorry, when the mempool is full and we try to evict stuff, we would know
exactly what the last transactions are that we would need to drop from the
mempool, because they would be the last thing that we'd mine ever, and that
becomes symmetrical.  Previously, it was easy for us to tell what the best thing
is, what the transactions are that we would mine into a block first.  But
eviction was complicated and eviction becomes a lot easier.

So, this is a little bit more on the research side still.  There's a lot of
exploration on what the algorithms would be for this and how it exactly would
work.  There's an issue in Bitcoin Core so far, but no implementation.  So, this
is on a long timeline, but it would make a lot of things way easier surrounding
faster block-building and more correct blocks in the sense of maximizing the
fees collected by miners- and generally faster and cleaner eviction.  Yeah, did
I cover that completely, Gloria; am I missing something?

**Gloria Zhao**: I think so, yeah.  And we talked about this before.  I mean, I
think you went into more detail this time, so maybe there's no need to link a
past one.  But Newsletter, let me see, I think it was #251 we also talked about
this.  Yeah.  So should I continue off of the --

**Mark Erhardt**: Yeah, I think v3 transactions, right?

**Gloria Zhao**: Sure, yeah.  So, as Murch mentioned, it's a bit long term.  I
think if we were to wait for that to be done, we might be waiting a little bit
of time.  And it also doesn't quite solve the rule #3, for absolute fees pinning
problem that I just mentioned right before this.  And two very general insights,
or takeaways, that I would say for the past year of discussions about RBF, one
is our limits are too permissive and they're not very effective at controlling
what we want to control; and the other one is perhaps different use cases
require different kinds of package limits.

So for example, you can imagine a batched withdrawal from an exchange sending to
a lot of different customers.  It would be kind of unfair if only one of them
got to spend their output from that unconfirmed transaction.  So, it does make
sense.  You can definitely say there are times where it makes sense to have
multiple descendants allowed from an unconfirmed transaction.  But in this case,
we're hurt by that because there's so much room for one of the participants of
the channel to attach a bunch of stuff to this commitment transaction, where
really the only use case that we care about is being able to fee bump that
transaction.

So, v3 is kind of this dead simple policy where you could opt in to a more
restrictive set of package limits.  And those limits are, you get one
unconfirmed parent and one unconfirmed child, and that's it.  You have a cluster
size too, essentially, and that child is only allowed to be 1,000 vbytes.  And
so that limits the cost of replacement essentially, right, because if you want a
commitment transaction to confirm and your fee estimator says that it needs to
be, let's say, 50 sats/vB to make it into the next block or next two blocks or
something, then you can just calculate, okay, the maximum cost of replacement is
going to be that fee plus up to 1,000 vbytes times this feerate to bring that to
that.  That's going to be much better than if, for example, the child could be
potentially 100,000 vbytes.

The idea here is to kind of limit the, Greg calls this "economical damage" that
your counterparty could do to you by kind of abusing the descendant limit
looseness.  Murch has his hand up.

**Mark Erhardt**: Yeah, I just wanted to reiterate and sort of describe from a
different angle.  Essentially by limiting -- you know what use case you have
with commitment transaction.  You just want to enable someone to bump it, and by
limiting yourself to always having only this cluster of two transactions, you
get rid of the options of having additional parent transactions that have a high
weight that might bog down the transaction, you limit yourself from having
additional children that might increase the package size and make an RBF really
expensive.  And really it's in the interest of both parties to delimit
themselves, because it just makes it dead simple and obvious how much cost there
might be eventually to bump the commitment.  That's all.

**Gloria Zhao**: Yeah.  And then I mentioned that this is cluster size two
because you can essentially get some of the benefits of the cluster mempool
stuff.  Like you can calculate what a mining score is of a cluster, size two
cluster, without having the entire restructuring of the mempool simply because
there's only two transactions.  So that's nice, we get kind of a shortcut to
some of the things that we want from cluster mempool.  It's still far better to
do this larger effort of restructuring it, but it's nice that we have both a
short-term solution and a long-term solution, and we need v3 either way.  So,
cool.

Then the final proposal that's discussed in this post builds on top of v3 and
the properties you have with it, to eliminate the requirement of putting value
into your anchor output.  So, I think this comes up in the context of LN
symmetry, where you're hoping that these update transactions, which represent
the state of the channel balance, to be able to be chained off of each other.
But the problem with anchor outputs and needing value in them is you have to
shave off some amount of the funding input into these anchor outputs, so I think
it's 320 satoshis or so.  But if you think about, okay, let's say we want to
chain like 100 update, hopefully not, but update transactions off of each other,
at every step you have to shave off 300-something satoshis, and so you're like
leaking channel balance at each update, which is just a little bit less useful
then.  So it'd be nice to not have that problem, but still be able to fee bump.

So, ephemeral anchors essentially says, okay, let's add almost like a carve out
rule, where if you have a v3 transaction, it has exactly zero fees on it, and it
has this anchor-shaped output, that output gets to be below the dust threshold;
it can be, it doesn't need to be, but it can be.  And the idea there is that
this anchor output will be spent immediately by a fee bumping child, and it will
never actually make it to a UTXO set.  So, it's zero fees, so you've got to bump
it, and this transaction's only allowed to have one child because it's v3, and
that child is not allowed to have any other parents, so it can't be bumping
anything else, and so this output "has to be spent".

Now, of course, it's not consensus enforced, but it is just incentive
incompatible for this just to not happen, right?  And so in that sense, the
anchor output is ephemeral, hence the name ephemeral anchors, which I think is a
very cool name as well, I think it's very, very nice sounding.  Murch, you have
your hand up?

**Mark Erhardt**: If you want me to, I would jump in a little bit if that's
fine?

**Gloria Zhao**: Yeah, fine.

**Mark Erhardt**: So, as we heard earlier, the current anchor output proposal
that is already live on the network requires one anchor for each side, and
ephemeral anchors especially, since they are forced to be spent because the
parent has zero fees, so it wouldn't even make it into the mempool unless there
is a child that bumps it.  We can use an OP_TRUE output here.  So the output is
tiny, there's an amount and like 1 byte, just OP_TRUE.  And the input of that is
also tiny because it can be empty, the input script is completely empty.  So,
you sort of get the benefits of the anchor output, but you have the minimum
possible extra data to link those two transactions, but you can decouple the fee
paying from the commitment transaction.  And because it's an OP_TRUE output,
either party can use the anchor output, so you don't need two anymore, and the
mechanism for how the second one gets cleaned up after the transaction is there.

Since we would use the v3 transactions and we can only have a single cloud, you
don't have to worry about any of the other outputs getting spent and pinning
attacks, or larger RBF packages that you need to replace because something gets
attached.  The only way to spend it, for it to be policy valid, would be to
attach to this ephemeral anchor with altogether an overhead of 50 vbytes or so;
50 bytes.  And yeah, so that's really, really cool.  Anyway, sorry.

**Gloria Zhao**: Yeah, I mean I was at the end, really.  It's pretty exciting.
I think it'll take a few years to build all of it.  Sorry, I shouldn't say that;
it'll take a short amount of time, we're working really hard to get everything
done, hopefully we'll have it soon, TM.  So, yeah, it's cool.  I sent this to my
mom because I was really excited and wanted her to know about what we're working
on!

**Mike Schmidt**: We have one of the protocols that consumes some of these
potential transaction relay network improvements here.  I see t-bast is giving
thumbs up and clapping and "100".  T-bast, what's your take?  Do you have
anything to add to what Gloria and Murch have outlined in terms of improvements
on the policy front?

**Bastien Teinturier**: Yeah, I just want to highlight that this is amazing
work, this is really useful.  This is going to simplify Lightning and any layer
2 protocol by an incredible margin.  So this is very, very important work for
any protocol that builds on top of Bitcoin, and I'm really happy that we've been
able to find the solutions that only require policy changes and require a lot of
work for sure.  But Gloria has been amazing working on that one for so long and
getting things merged and accepted, and making sure that the discussion was
continuously moving forward in the right direction.  So, yeah, I'm really happy
to see all of this making progress and I just can't wait to be able to use it in
Lightning.

**Mike Schmidt**: Gloria, do you want to tease our next and final post in the
series for next week?

**Gloria Zhao**: It's going to be a wrap-up.  It's been a long, long journey.
I'm very proud of all the work that we've done.  Murch and I have been spending
lots of time on these posts.  Next week will be a concluding wrap-up post.

**Mike Schmidt**: Excellent.  Moving on in the newsletter, we have Bitcoin Core
PR Review Club segment, which is a monthly segment highlighting a particularly
interesting Bitcoin Core PR that was reviewed at the weekly PR Review Club
meeting.

_Stop relaying non-mempool txs_

This month's coverage is a P2P PR called Stop relaying non-mempool txs.  And we
are fortunate enough to have Martin here who hosted this PR Review Club, which
covered Bitcoin Core 27.6.25 from Marco.  Martin, do you want to introduce
yourself and then we can jump into this PR?

**Martin Zumsande**: Sure.  Can you understand me?

**Mike Schmidt**: Yeah.

**Martin**: Okay.  Yeah, I'm Martin, I work at Chaincode Labs, mostly on P2P,
but also other aspects on Bitcoin Core.  Yeah, and I was hosting this PR at the
club about this PR.

**Mike Schmidt**: Excellent.  Well, thanks for joining us.  Maybe it would make
sense for you to take the lead on maybe summarizing some of the background
behind this PR, and then we can get into some of the details.

**Martin Zumsande**: Sure.  Yeah, I mean, this is all about removal of this
so-called mapRelay.  And what I find really interesting about this is that this
is a very old thing.  It was already present in the first GitHub commit, so it's
really a Satoshi thing.  And back in the old times, it was basically the only
way that we would relay transactions to others.  So, I mean if someone asks us
for a transaction, then we need to get it from somewhere, and what we do now is
we get it mostly from the mempool.  But back in the time, we didn't do this, we
just saved all transactions that we relayed to someone for like 15 minutes, and
during this time, if someone else asked us for this transaction, we would get it
from there and send it to them.  But yeah, that was the ancient behavior, I
would say.

Then at some point, this wasn't needed that much anymore because at some point,
we'd start fetching the transaction from the mempool directly.  So, in that
case, yeah, the question is, why do we still have it?  Why do we still need this
mapRelay, which continued to exist, beside the mempool?  And the reason for that
was several strange corner cases in which a transaction that used to be in the
mempool but isn't in the mempool anymore, for some reason we would still want to
relay it to our peers.  And yeah, that's why the mapRelay basically still
existed until 2023.

But I would say one by one, all these corner cases why we would still need this
map were fixed in other PRs.  And as a result of that, now I think we are in a
place where we can finally get rid of this map, because it's not necessary to
have this additional data structure and just getting rid of it would make it
easier to reason about transaction relay and also save some memory.

**Mike Schmidt**: So this data structure, in the way that it was originally
created, has been removed, but as part of this PR there was a smaller, more
bounded memory data structure that was added to handle a remaining use case for
relaying non-mempool transactions; is that right?

**Martin Zumsande**: That's exactly true.  So the PR, it tries to list all of
the cases where we might still use it, and the one case that we thought we might
still want to have this transaction is if transactions leave the mempool because
they were included in a block.  In that case, yeah, they are no longer in the
mempool and we wouldn't relay them anymore just from the mapRelay.  But if we
remove that too, we wouldn't be able to relay them anymore at all.  That would
have some negative consequences on compact block relay because in that case,
some of our peers who are just about to ask us for this transaction and they
don't know, they haven't received the new block yet.  So, in order to be able to
serve those peers, we still keep all of those transactions that were included in
the most recent block and keep them in a map in place of the mapRelay.

But it's important to note that this is a much smaller scope for the new map,
because these transactions, we save them anyway because the newest block, we
store it anyway in memory so that we can send it to our peers faster.  So
basically, all the overhead this introduces is a couple of pointers to the
transaction in this block that we have in memory anyway.  So, yeah, basically we
have a new map or new true data structure that is a replacement for mapRelay,
but it's much smaller and much more bounded in scope.

**Mike Schmidt**: If I'm understanding the use of this new structure correctly,
if I'm running a node and I tell a peer that I'm aware of a transaction and they
say, "Hey, give me that transaction", and before they ask for it from me, I've
actually received a block with that transaction in it and thus that transaction
has been removed from my mempool, there are advantages to still providing that
transaction to that peer, even though the transaction for me has been cleared
from the mempool because it's in a block.  And the advantages of that is, if I
provide them with that transaction, when the block that I just got eventually
gets to that peer, compact block relay would benefit that peer because they
would already then have that transaction; is that right?

**Martin Zumsande**: Yeah, I think it's basically a timing issue because I mean,
if that peer was just about to ask that from us and we got the block and then we
can't send it to them anymore, that would add a little bit of overhead.  But if
we still have it, we can just send it to them.  I mean otherwise, transactions
are also included in the compact block.  So let's imagine we don't have this
transaction anymore in the mapRelay, they could still get it from us with a
compact block, but this would possibly require another round trip and make
compact block relay a little bit slower.

I think just to be on the safe side, in the event of some strange timing issues,
we still have this.  The good thing is that it's very cheap to have because the
transactions are saved anyway, so we just need to have a pointer to this
transaction, basically.  So we have these shared pointers for transactions that
means that the actual transaction data is saved only in one place, but there are
multiple pointers that share, basically, the ownership over this transaction,
and the transaction will only get deleted after the last pointer is removed,
basically.  So, yeah, I think it's basically like a mechanism just in case, in
some timing issues, to still have it.  But, I mean I was arguing in the PR
Review Club that maybe it wouldn't even be necessary to have this replacement
structure.  But yeah, we have it and I think it's good.

**Mike Schmidt**: Gloria, did you have any comments on this PR or the PR Review
Club discussion?

**Gloria Zhao**: It's one of those things to get rid of.  It's great to get rid
of mapRelay.

**Mike Schmidt**: Excellent.  Martin, any final thoughts before we move on?

**Martin Zumsande**: Not really, no.

**Mike Schmidt**: All right.  Well, thanks for walking us through that PR.  And
folks, if you're interested, you can see some of the questions and answers from
the PR Review Club in the newsletter, and you can also link to the full
transcript of that PR Review Club meeting that was hosted by Martin.  Thanks for
joining us, Martin.  You're welcome to stay on.

**Martin Zumsande**: Thanks for having me.

_LND v0.16.4-beta_

**Mike Schmidt**: We have one release that we covered in the newsletter this
week, which is LND v0.16.4-beta, which is a maintenance release, and it fixes a
memory leak that may affect some users.  We actually had been covering a series
of these related issues.  I think v0.16.3, which was the release before this,
was a fix to optimize the mempool management feature that LND had just added
because it was using too much CPU, which was causing issues.  And it seems that
that optimization that was put in place to minimize the CPU issue is now causing
a using-too-much-RAM issue.  Murch, have you been following along with these;
did I get that right?

**Mark Erhardt**: I have not been following along.  I still think we need to get
some Lightning people on this podcast every week!

_Bitcoin Core #27869_

**Mike Schmidt**: We have one notable code change this week, which is to Bitcoin
Core, Bitcoin Core #27869.  Bitcoin Core will now give a deprecation warning
when loading a legacy wallet.  So, the wallet will still load, the legacy wallet
will still load, there's just a new warning message that when you load such a
legacy wallet, that support for creating or opening such wallets will be removed
in the future.  And also notes that the user should use the migratewallet RPC to
transition their wallet to a descriptor wallet.  Murch?

**Mark Erhardt**: Yeah, I was going to say, Mike, what's a legacy wallet?

**Mike Schmidt**: The roles are reversed!  So, there are actually four types of
wallets, right?  There's legacy-bdb, there's descriptor-bdb, legacy-sqlite and.
And I think that the goal of the project that achow is working on is removing
support for legacy-bdb, descriptor-bdb and legacy-sqlite, leaving just
descriptor-sqlite.

So, descriptors I think we've gone over a few times in the podcast, but
essentially is the new version of how to keep your wallet data using these
output script descriptors, as opposed to having a whole bag of keys and
addresses.  And so there's this long-term issue, project issue, that achow has
this roadmap for how to go about sunsetting support for not only Legacy wallets
but Berkeley DB (BDB) as well.  I believe that those are two of the goals of the
project, and so this is just one step in that series of multi-year-related
issues to phase out that support.

**Mark Erhardt**: I have nothing to add.  That's exactly right!

**Mike Schmidt**: If you're curious, I think it's a useful context.  If you
click into Bitcoin Core #20160, this tracking issue, it helps give you
perspective on PRs like the one we just covered and its context in a broader
effort within the Bitcoin Core project to achieve something.  I know Gloria has
some similar tracking issues with some of the work that she's doing.  I find it
helpful, as a consumer of this information, to put things in perspective using
those tracking issues.  So, thanks for putting those together so we have an idea
of where we're going.

**Mark Erhardt**: Actually, let me jump in a little bit here.  People often ask
why it takes so long for Bitcoin Core to do stuff.  Essentially, the idea is
that you're fixing an airplane while it's in flight and nobody is allowed to
lose any funds or lose capability of doing any of the things that they ever were
able to do before.  So, any of the wallets ever created with Bitcoin Core since
the release in 2009 still need to be able to be parsed by Bitcoin Core even
today.  And even when we remove support for loading the wallets and using them
directly, we will always have to maintain the ability to transfer them to a new
format that we can read.  So, we will always have a translator that is able to
import the old wallets and create a current descriptor wallet from them.  So,
you will always be able to spend any old Bitcoin Core wallet, or use and recover
funds from any old Bitcoin Core wallet in a new Bitcoin Core.

So, we've had this BDB for, well, ever since Bitcoin Core existed, and it has
various issues.  I think it's basically unmaintained and old.  And we're moving
just to something that is newer, lighter, better maintained, which is SQLite.
And then, of course, I think we've talked a lot about descriptors.  The
descriptor format is a much more explicit way of referring to the entire body of
scriptPubKeys that a wallet consists of.  And it's the way forward how I think
wallet exchange formats and multisig and all sorts of more complex wallets are
going to express their backups in the future, and also probably their wallet
format.

If you look at #20160 that Mike just referenced, it is a project that has
started in 2020 and it's had some changes to the Bitcoin Core in every release
since 0.21 and it's scheduled out to 28.0 to actually finally remove all the
parts.  And being able to juggle all these pieces and keep everything working at
every point in time is what makes this fairly complex.  If you're making a
commercial product where you can just say, "Well, this version is no longer
supported, you have to upgrade", and don't really need to cater to any users
that have old versions any more, that's way easier, but we have higher
standards.  We want to make sure that nobody ever loses funds from just having
an old version.

**Mike Schmidt**: Any announcements, Murch, before we wrap up?

**Mark Erhardt**: I'm going to be at TABConf.  You should also come to TABConf,
we'll have a great conference.

**Mike Schmidt**: Do you think we could record a live Optech Recap session
there?

**Mark Erhardt**: I think we might, yeah.  Are you going to be there too?

**Mike Schmidt**: Oh, well, now that you're going, maybe I will go.

**Mark Erhardt**: Let's do it.

**Mike Schmidt**: Thanks everybody for joining us.  Thank you to Martin, t-bast,
Gloria, and my co-host, Murch, and everybody who listened to the podcast.  We'll
see you next week when we recap Newsletter #260.

**Bastien Teinturier**: Thanks for having me.

**Gloria Zhao**: Thank you, see you guys.

**Mike Schmidt**: Cheers

**Mark Erhardt**: See you.

{% include references.md %}
