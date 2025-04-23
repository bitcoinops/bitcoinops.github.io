---
title: 'Bitcoin Optech Newsletter #341 Recap Podcast'
permalink: /en/podcast/2025/02/18/
reference: /en/newsletters/2025/02/14/
name: 2025-02-18-recap
slug: 2025-02-18-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt discuss [Newsletter #341]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-1-18/395115335-44100-2-8c90660c884d.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #341 Recap on
Riverside.  It's just going to be Murch and I today talking about probabilistic
payments, ephemeral anchors in Lightning again, statistics on orphan evictions,
updates to the updated BIP process and a cluster mempool PR Review Club.  Like I
mentioned, we won't have any guests today, so the pendulum has swung from eight
guests last week to just us today, so we can jump right into the news.

_Continued discussion about probabilistic payments_

First item titled, "Continued discussion about probabilistic payments".  This
news item is actually a follow-up on last week's discussion about emulating a
potential OP_RAND opcode for introducing randomness into Bitcoin Script, which
is not something possible today.  We had Oleksandr on the show last week, so
check out both News and Pod #340 for the mechanics of his scheme to add
randomness.  This week's discussion continued that thread with three different
items.  One was our very own Dave Harding wondering if this randomness could be
used as an alternative to trimmed HTLCs (Hash Time Locked Contracts), which are
very small Lightning payments that might not be economic to be resolved in an
onchain transaction.  And currently, the value of those trimmed HTLCs are lost
if they're pending during a channel force closure.  Murch, what's Dave getting
at here?  How is randomness going to solve this, or do something different with
these trimmed HTLCs?

**Mark Erhardt**: Right, so when you make payments on Lightning, you build up a
multi-hop smart contract and that first adds an HTLC to each commitment
transaction along the hops.  And then, when it's settled, you receive back the
resolution and fold out the HTLCs again.  Now an HTLC adds an output with a
complex script to the transaction.  And if you're making very small Lightning
payments with just, I don't know, a few sats, that is not worth putting on the
blockchain, because it'll cost a lot more to add that output than it would ever
resolve in money.  So, what currently happens is basically, it's a gentleman
system.  The two nodes both remember that there was a tiny payment in flight and
when the HTLC resolves back, they just remember and put it back.  And if one of
the two parties disagrees or forgets to their benefit, or something like that,
you close the channel and just never work with them again.  But it's like a few
sats and it works.

I guess that's where I'm a little skeptical about whether putting an OP_RAND,
opcode into your commitment transaction and probabilistically resolving those
tiny amounts would make sense, because I don't know for sure, but I assume that
the construction would be a lot more complicated and it would make the
commitment transaction bigger.  So, if it's not worth adding an HTLC output,
would it be worth making the commitment transaction bigger to resolve this?  So,
it's not entirely clear to me.  It might work because you can fold all of the
in-flight HTLCs into one probabilistic resolution, but you'd probably have to
standardize that in the BOLTs, and so forth, so just seems a little unlikely.

**Mike Schmidt**: Okay, so in a proposed world where this is implemented,
there's going to be cost to implement it.  You're mentioning additional script
to handle this, and the effect is what?  That those trimmed HTLCs
probabilistically what, like randomly what would happen in the future?

**Mark Erhardt**: Right.  I guess that if you have a lot of these tiny HTLCs,
you'd add a random resolution and it 50/50 either goes to one party or the other
party instead of being dropped to the miners.  But overall, the cost of adding
this additional random resolution would be one output across the whole set of
HTLCs.  So, I assume that it's still only worth it if you have a lot of them,
and I'm not sure if it's worth the effort in the standards process.  I think
OP_RAND could be an important component if someone wants to go Satoshi Dice on
us again and build a provably fair gambling system or something.  But I think we
hopefully learned ten years ago that that is not a good use of blockspace,
although looking at the mempool, apparently people also don't have other use for
it either.

**Mike Schmidt**: Yeah, and we'll touch a little bit on that later with the
orphan statistics that 0xB10C got into.  But there were two more points on this
randomness discussion.  The second one was a discussion item that popped up
around the originally proposed setup in the protocol missing a step.  And AJ
Towns called that out with some notation that just turns off my brain.  So, if
you're curious about that, jump into what AJ pointed out.  But the conclusion
there is that Oleksandr, the original author of this thread and protocol,
basically agreed with AJ.  So, I guess that will be implemented in whatever
comes out of this protocol.  And then a third discussion item in this thread was
around an idea by Adam Gibson, who suggested that by using taproot and schnorr
instead of hashed public keys, there could be a speedup in both the creation and
verification of the associated zero-knowledge proof.  And then Adam and AJ went
back and forth a little bit on this.  Murch, I don't know if you dug into that
last discussion item, or if you have anything to add there?

**Mark Erhardt**: I did not, but now that I'm thinking about it, if you're
talking about using OP_RAND for commitment transactions only in taproot
resolutions, then you might just have -- no, I haven't thought enough about
this.  But yeah, I stand by what I said earlier.  I think it's not obvious to me
that this is a good resolution for fixing up the trimmed HTLC stuff.  And
simpler knowledge proof definitely sounds good.  It might be cheaper that way
than the original construction.  That's why it's nice if you throw out an idea
like that, you get people like Waxwing and AJ looking at it, and they can just
follow through these complex constructions and tell you exactly where the
problem is.

_Continued discussion about ephemeral anchor scripts for LN_

**Mike Schmidt**: Our next news item titled, "Continued discussion about
ephemeral anchor scroops for LN".  This news item is also a follow-on discussion
from last week's news item.  Last week, we had on t-bast from Eclair, who does a
lot of work on the LN spec as well.  And t-bast walked us through why LN might
want to take advantage of ephemeral anchors in LN commitment transactions, and
that would be a replacement to the existing anchor outputs in LN.  And the
question last week that t-bast proposed in his post was, "Hey, which of these
four potential options for how LN could use ephemeral anchors is the best?"  And
it sounds like maybe quickly out of there, they came to a conclusion and t-bast
walked through those different options and the thinking behind that.  So, that's
all to recap last week.  But if you're curious, go back to Newsletter and Pod
#340 and hear Bastien talk about that, because he's great at explaining these
things.

So, this week, we covered Matt Morehouse's reply to that discussion.  And Matt
Morehouse has actually been on our show and also featured in the newsletter
twice in the last few weeks, both around griefing attacks that he disclosed.
And so, I guess it's not totally surprising that he expressed concerns this week
about third-party griefing of transactions with pay-to-anchor (P2A) outputs.
There's a couple more points here from the newsletter, but Murch, do you have a
strong enough grasp on his objections to double-click a little bit further into
that?

**Mark Erhardt**: So, with P2A, you get an ANYONECANSPEND output.  It's
literally just an OP_TRUE script.  And what that means is you don't need to
provide any evidence in the input script in order to be allowed to spend it, and
that enables any party in the Bitcoin Network to attach a transaction to this
output that spends it.  So, my understanding is that Matt is pointing out that
this would enable third parties to attach transactions with low feerate but high
fee, or other shenanigans, and that might frustrate or grief, cost extra money
to people that are trying to use the anchors to close their transactions.  And
while that is true, it seems unlikely to me that they would have an economic
benefit from doing that.  So, unless somebody is burning money just to see the
world burn, that probably doesn't make a whole lot of sense.  Now, there's
people like that out there but overall, if people just want to burn money to
make Bitcoin less usable for everyone else, they could also just buy all the
blockspace or do a ton of other things.  So, maybe this is not the main concern
that we need to design around.

**Mike Schmidt**: Well, that was sort of AJ's response, is that, "Hey, yeah,
there's third-party griefing, but in this setup, there's two parties that are
maybe more likely, your counterparty being the one".  You have a relationship
with them, there's maybe more to be gained there, right?

**Mark Erhardt**: Right.  The counterparty has a direct interest in how the
channel gets resolved.  So, if they are delaying the channel closure or
something, they might have direct financial benefit.  Now, if a miner, for
example, can force you to pay more by griefing your Lightning close, they might
have an indirect benefit.  But even then, the miner that sends the transaction
has only some proportion of chance to mine the block, so, yeah.  The other thing
is adding keys to the anchor output would increase the cost of the output
because right now it's tiny, of course, given that it's ANYONECANSPEND without
an input script.  But with a key, then it would need a signature on the input
side as well, so you're adding data to the output and to the input.  So, if
every single channel closure is 10% more expensive -- this is Greg Sanders'
argument.  If you pay 10% more on every single channel closure because you're
worried that occasionally you might get third-party griefed, is that really
worth avoiding an occasional increase in 50% to close the channel if that
happens very seldomly.

**Mike Schmidt**: That sort of harkens back to your analysis of trade-offs in
the last news item, which is none of these mitigations are "free".  There's
going to be additional space taken up by these mitigations.  And yeah, you
mentioned Greg's probabilistic thinking on this.  It seems to make a lot of
sense.

**Mark Erhardt**: Right.  I mean, generally, we've designed a lot of Lightning
around being trust-minimized, and maybe the counterparty can cost you a little
fees or delay you slightly.  But overall, you can always unilaterally reclaim
your funds.  But then, we don't see any penalty transactions on the network
basically.  Occasionally, somebody resolves a channel incorrectly because they
have loaded in a backup, or some such.  I think probably we've seen less than
100 or so in total on the network.  So, (a) this mechanism does work, but (b)
would we even see all that much more if it were a little less strict?  So,
there's this whole debate that's related to this, is LN-Symmetry going to work
without having a penalty to replace LN-penalty?  And I think right now, the
evidence would be, yes, it would work, but maybe I'd get an unpleasant surprise
when we do go for LN-Symmetry and people always close incorrectly, but it just
doesn't make a lot of sense to me.

**Mike Schmidt**: Well, both this discussion, follow-on discussion, and the
previous news item's follow-on discussion is ongoing.  So, if there's more
interesting things, we'll continue to surface those here.  And obviously, if you
have a comment on these discussion items, jump in to Delving, where both of
these discussions are happening.

_Stats on orphan evictions_

Next news item, "Stats on orphan evictions".  I think maybe it makes sense to
recap what orphan transactions are first.  So, if your node is participating in
transaction relay, at some point you might learn about a transaction that is
spending an output from a parent transaction that you don't know about.  And
that child transaction, if you will, that doesn't have a parent is known as an
orphan transaction.  I know we talk about naming being difficult, but that seems
fairly straightforward here.  And it's important to note that it may be an
orphan to your node, but other nodes may know about that parent.  In fact, if
it's a real series of chain of transactions, someone does know about that
parent.  Yeah, go ahead, Murch.

**Mark Erhardt**: Specifically, Bitcoin Core nodes will only announce an orphan
transaction to you if they first know about the parent.  Nobody will ever
announce orphans to you and relay them, because they are waiting for the parent.
Only after they have the parent, they would announce it to you.  So, you can
always ask whoever announced an orphan to you, and they should have the parent,
and they should give it to you.

**Mike Schmidt**: And I think we covered in a recent newsletter, I don't
remember if it was PR Review Club or if it was one of the Notable code PRs, but
some changes to that orphan resolution to make sure that the person is not
withholding the parent from you, you could ask other peers for that same parent.

**Mark Erhardt**: Right.  There's several improvements in flight for orphan
resolution.  So far, Bitcoin Core had been handling that by having a shared
orphanage with up to 100 transactions.  So, whoever announced an orphan to you,
you would pack it into the orphanage.  And if there's more, if there's 100
transactions in the orphanage already, you would randomly evict another one and
then put this orphan in.  Back to you.

**Mike Schmidt**: Yeah, Murch sort of went through the next few points here,
which is, yeah, there's a data structure called the orphanage.  By default,
that's set to 100.  And that's a way to keep these orphans.  You don't just get
rid of them when you don't know the parent.  You sort of have this little data
structure to wait for a while and see if you can find the parent so that you
don't have to re-request those orphan transactions later.  And there's an
element of randomness to the eviction once you get above the 100 limit.  And
then, getting back to this news item, 0xB10C, who runs a bunch of monitoring
nodes on the Bitcoin Network, ran some analysis on what some of his nodes see
regarding orphans, recently.  And he found that one of his nodes, who he has
named Alice, saw more than 100,000 orphans being removed from this 100-limit
orphanage per minute.  And he comments, "This feels like someone flooding us
with orphans.  Something like this is probably pretty effective at clearing our
orphanage from orphans received from other peers".  Yeah, go ahead, Murch.

**Mark Erhardt**: Yeah, so that's one of the things that are getting improved
right now.  Previously, we were using this whole orphanage across all of our
peers together.  So, if one of our peers is flooding us with orphans, they would
randomly evict previous inhabitants of the orphanage.  And eventually, if they
flood us enough, they'd probably have churned out the whole orphanage.  But one
of the improvements that we're making is that we track who announced orphans to
us.  And if we're getting a lot of orphans, we will only evict from the orphans
that they announced to us.  So, that would mean that the flooding party would
just churn out the other stuff they told us about rather than orphans announced
to us by other people.  And that would, for example, mean when we use the
orphanage now to do a simple form of package relay, where we support CPFP, and
we first learn about a high-feerate child, and then we ask back, "Hey, so what's
the parent here?" and we get the parent, and then we can add these two
transactions as a package to our mempool, that would still continue to work of
getting these organic natural orphans resolved, while this crazy person sending
us runestones, 100,000 evictions per minute, would just be churning their own
butter.

**Mike Schmidt**: Yeah, the runestone point was something that 0xB10C added
further in his analysis later on, which he noticed that the types of
transactions -- 0xB10C indicated that they were similar to an example of
runestone mint transaction, runestone being a meta protocol that uses Bitcoin to
create NFT-like things on Bitcoin.  And 0xB10C then also noticed that many of
the same orphan transactions were actually repeatedly requested, then evicted a
bit later due to the 100 limit, and then requested again.  And I'm curious, and
I actually tagged Casey Rodarmor, who I think is involved with that project, as
part of our Optech Twitter thread, to see if he had maybe some insights as to
the gamification of why that sort of churning might be going on?

**Mark Erhardt**: I have a couple of ideas too.  So, as far as I know, runes
unlock at certain block heights for different lengths.  So, when you hit a date
where suddenly, I don't know, rune lengths of 11 characters become available,
probably a lot of people are trying to get these rune transactions right into
that block.  And they use services to do the etching, they call it.  But if,
say, more than 100 people are trying to get their runestone into the next block,
and I think you have to pre-commit to the runestone a few blocks in advance, so
they've committed to a transaction already and they might be reliant on CPFP,
because the feerate is going up because so many people are trying to get
something into this block.

So, this probably custom implementation of a service is trying to announce more
than 100 organic orphans to us.  And by the time they get through the last of
the 100, they kick out the first announcements of their own, and maybe in that
way, well, it doesn't make any sense how they're going about this, in the sense
that if you're announcing more than 100,000 per minute, that's more than 1,666
transactions per second, which means that we can do something like 10 per second
that actually end up in blocks.  If you're sending us 160 times that, clearly
not all of that's going to be in the next block.  So, I guess that's just dumb
behavior on behalf of this custom client.  But yeah.

**Mike Schmidt**: Is that because it's that all these orphans, you would think
very quickly you'd grab the parent; is the parent, as part of this protocol, for
whatever reason, being withheld, like there's certain information about this
parent that the transaction's not actually broadcast, so that everyone's
referencing this sort of unknown parent for this period of time?  Otherwise, it
would seem after a few orphans referencing that parent, you would get the
parent, right?

**Mark Erhardt**: I'm not 100% sure.  I assume, well, don't attribute to malice
what can be explained with ineptitude, right?  So, if they're just announcing,
say, 200 orphans in a single inventory message, you might start grabbing them,
request a parent, and keep grabbing them from the inventory message.  And as you
go over the 100, you kick out one of the earlier ones, and maybe by the time you
get the response with the parent, you don't even have the orphan anymore.  And
then you're like, "Well, this parent is too low feerate", and throw it away
again.  But then you would reconsider the parent in the context of it being a
parent to an orphan, because that's how CPFP is allowed.  So, I think just there
might be an argument of this custom client just with its strange behavior doing
something dumb rather than malicious.  But either way, the solution on our end
would probably be something like tracking how much CPU we spend on each peer,
and then requesting fewer transactions from them because they're using too much
of our resources and slowing them down.

There will probably also be an improvement with the recent improvements of the
orphan resolution to this scenario specifically, but I think also probably the
custom client would be able to perform much better if it slowed down and gave
us, like, no more than 50 transactions, then waited until all of the parents had
flown and then gave us more, if that's what's happening; or, there's
replacements in there too because they're trying to bid each other up very
quickly; or, who knows.  But either way, what they're doing doesn't seem smart.
That seems at least likely.

**Mike Schmidt**: One thing that I don't think I saw in 0xB10C's analysis, and
I'm not sure if it's something you're familiar with, Murch, is this sounds bad,
like spamming the orphanage, or whatnot, but it doesn't seem like it's
negatively impacting the nodes, right, or at least to a degree that people are
complaining about their node crashing or something like this?  And 0xB10C didn't
seem to indicate that there was issues with performance or anything, so it's
more of like a nuisance than something that's actually having an impact on node
runners, is that right?

**Mark Erhardt**: Well, in this case, the description of the transaction was
that it was something like 500 bytes, and the CPU load of that would probably
not be super-high.  You're always loading the same inputs probably, because it's
just a handful of inputs, or maybe a couple of thousand, so they'll be in your
cache after the first round.  So, it's just, I'm getting data, I'm looking at
it, and I'm throwing away other data, and I'm doing that so quickly that I end
up just churning through data.  I don't think, like, we wouldn't get memory
problems or CPU problems or something.  It's just wasteful and ineffective.  If
they maliciously did this with really big transactions or complex-to-evaluate
transactions, or something, that would be more concerning.

The good part about orphans is also, we don't relay them until we know about the
parent when they're no longer orphans.  So, this will only ever affect anyone
that is a peer to the client that announces all these orphans.  So, it's not
behavior that spreads immediately across the entire network.  Sure, they might
have more peers or something, but yeah, I don't think that it's hugely dangerous
right now.  But if the person that is responsible for this client's behavior is
listening, maybe look at how you make that more efficient!

_Updated proposal for updated BIP process_

**Mike Schmidt**: Our final news item this week is titled, "Updated proposal for
updated BIP process".  And we said we had no special guests this week, but we
sort of have a special guest.  Murch, you can put on your special guest hat for
this one.  What is going on with the updated BIP process and how are you
involved?

**Mark Erhardt**: Yeah, so last year, we saw quite a bit of discussion on the
mailing list about where the BIP process doesn't work well for us, how generally
BIPs have been moving very slowly.  And one part of that got better in spring
when we added five more BIP editors and the BIP repository started moving
faster.  The other part was that we thought we should maybe have an updated BIP
process.  The BIP2 was written eight years ago, in 2016, I think, and there's a
few things in there that never got broad adoption.  There's a few complexities,
there's some things that are unclear, there's a lot of judgment calls on the BIP
editors.  So, I had been looking into what people wanted from an improved
process, like what feedback had been provided to that point, was trying to
basically streamline the process a little bit and I've been writing up a
proposal for a new process.  This recently got numbered, so the number 3 was
assigned to this BIP proposal.

**Mike Schmidt**: It's a cool digit!

**Mark Erhardt**: Yeah, the first few are reserved for purpose.

**Mike Schmidt**: Yeah, right.

**Mark Erhardt**: Yeah, so the first BIP process was BIP1; the second BIP
process, which is the one that's currently active is BIP2; and this proposal got
BIP3, became BIP3.  So, I'm pretty much done with the planned work that I had
for this proposal.  I have gotten a smattering of review recently again, but it
seems to be mostly on smaller details.  I'm feeling confident that eventually,
we might actually arrive at a complete proposal.  The overview would be that the
old system had nine BIP statuses, and they're being reduced to four in the new
proposal.  The comment system, where people would add some assessments or
comments to BIPs on Wiki pages is being removed, because if you look at how the
comments and the comment summaries and the preambles got together, I think the
most comments anything ever got was three, but most of them got one or two, and
then that got summarized into things like, "Unilateral recommendation for
implementation".  And then, you look and there's two one-sentence comments,
"Yeah, this is a good idea", or something!  So, I don't think that it was used
to an extent that it should be in the preamble, and the summarizing of these
very small comments sometimes skewed the perception of some BIPs.  So, my
proposal proposes to remove that.

I introduce a change log, where if BIPs have been open for a while, you
summarize updates to it, like when there's a bug fix or test vectors added, or
stuff like that.  You add that in a section, and that makes it easier for people
that only are casually keeping track of a BIP to see how it changed, without
going through the Git log.  Yeah, and I guess the other points are, we're trying
not to keep track of who implemented what BIP, and all these other
implementation sections that were very noisy for the BIP authors are being
removed.  The only point is, is this in draft status; is this a complete
proposal; is this deployed on the network; or is this inactive and nobody's
working on it in the closed status?  And yeah, so I opened this against the main
repository a while back.  There are another, I don't know, 100 comments on it
now.  If you have strong feelings about whether, for example, the discussions
header should be a header or a section, that is one thing that is still open and
being discussed.  The other one is about whether or not we need a closed status
at all, or BIP should always just stay open.  And finally, whether we need a
deployed status at all, because clearly it's hard to determine whether something
is in active use or not.

So, if you have feelings on that and maybe have suggestions on how to move
forward with this, please feel free to chime in sooner rather than later,
because I'm ready to be done with this project, and I'd like to wrap up.  So, if
I get your comments earlier, I hope to get this done sometime soon.

**Mike Schmidt**: If I'm a listener, and I just hear, "Oh, there's going to be a
new BIP process", I might think, "Oh, jeez, this could be dangerous, this is
Bitcoin".  But it sounds like from what you're saying, simplification in certain
aspects of the process, and this is not some completely new overhaul to the
process.  And so, I guess people's hackles that may be up at the thought of this
can take solace in that.  And of course, like you mentioned, there's 100
comments on this thing, lots of eyes on this thing, so there's no kind of
shenanigans.  It's really a strictly better improvement, it sounds like,
although maybe some of the points are being debated?

**Mark Erhardt**: Yeah, I think it's a lot of the usual suspects that have
looked at it now.  Some of the people that engaged in the debate haven't looked
that much at it yet, so if they had opinions or wanted to give it a read, that
would be nice.  For the most part, the process is very similar as before.  I'm
hoping that people also perceive it as just being a little simplified.  So, for
example, previously basically all sections were mandatory for every BIP, but
some sections just don't make sense for every BIP.  So now, the phrasing is
like, "The author and the audience of the repository decide whether stuff has
been sufficiently addressed, and if not, they should leave a comment or question
on the BIP to make sure that their concerns and issues are being addressed in
full before a BIP moves forward".  It's basically just trying to get rid of the
requirement that BIP editors need to understand a BIP to the last dot, because
that's not something we can do with 30 BIPs open at the same time and, like, ten
of them getting updates per week.  Nobody has that kind of time.

So, the people that are interested in topics, they need to read it and they need
to give feedback.  And I mean, if nobody's interested, then clearly a BIP's not
going to happen anyway.  So, I guess it's just sort of trying to be simpler and
putting more of the obligations on the authors and the audience, because those
are the two that mainly matter, while the BIP editors just make sure that these
guidelines are implemented and reasonable stuff, like the quality, is high
enough that people need to spend time on it.  We're trying to be more efficient
on the time of the audience and the authors.

_Cluster mempool: introduce TxGraph_

**Mike Schmidt**: That's fair.  I think we can wrap up the News section there.
Thanks for handling that one, Murch.  We have a monthly segment, the Bitcoin
Core PR Review Club.  And this month, the PR that was covered was titled,
"Cluster mempool: introduce TxGraph".  Not surprisingly, this is one PR of many
associated with the cluster mempool project within Bitcoin Core, to improve upon
Bitcoin Core's mempool behavior to better assess transactions that would be the
most incentive-compatible to keep and/or mine.  And incentive-compatibility here
means the transactions would earn a miner the most in transaction fees.  So, at
first you might think, "Hey, that's easy.  Just sort all the transactions by
feerate and boom, done".  But the complexity here comes in because Bitcoin
allows you to spend from an unconfirmed transaction, which means you can end up
with transaction dependencies, where one transaction spends another, which can
spend from another, etc.  And this results also in the orphan transaction issues
we discussed earlier as well, since you have a child transaction that's spending
from an unconfirmed parent.

So, as part of cluster mempool, you need to somehow represent the relations
between these dependent transactions in some sort of a data structure, so that
you can execute some sort of computation over the collections of those grouped
transactions.  And that's what this PR does.  It introduces a new data
structure, called TxGraph, and this transaction graph data structure contains a
collection of transaction data.  But the transaction data is actually highly
simplified, in that it doesn't have fields for transaction inputs, outputs,
txids, or transaction priorities, transaction validity, policy rules, etc.  It
really strips that data structure down to really just knowing about the
effective fees, the size of the transaction, and the dependencies between the
different transactions.  And so, by having this simplified data structure, it
allows other components of cluster mempool, like the logic and the algorithms
that operate over that data structure, to more efficiently operate on those
groups of transactions, so that cluster mempool can achieve that end goal of
improving the mempool's incentive-compatibility.  So, this is, like I said, one
piece of many.

You can check out the reference to this PR in the cluster mempool tracking issue
#30289, and you can see how this is one piece of many to get this project out
the door.  Murch, you have probably more cluster mempool familiarity than most
people.  What would you add to that?

**Mark Erhardt**: Maybe a little on how it compares to the previous organization
of the code.  So, my understanding is that previously, the mempool was organized
based on the ancestors and descendants, and the big problem there was of course
if you pick an ancestor into a block, you have to update the ancestors of all
the descendants of this transaction, and that's quadratic computational cost.
So, cluster mempool makes this easier by first grouping all of the transactions
that belong together into clusters, and then calculating in which packages they
would make sense to be picked into blocks.  So, when one of those packages gets
picked into a block, all the rest of the cluster is already pre-computed
correctly and you don't have to update anything.

So, a lot of that logic is directly in TxGraph, because that only depends on how
big are the transactions, how much fees are they offering, and what other
transactions do they depend on?  So, where in the old implementation, all of
that recalculations of the ancestors and descendants and block-building, and so
forth, was on basis of the mempool entries, which was like the whole transaction
with ID, with all that data attached, this is boiled down to really only the
components or the properties that are relevant to how the graph spans in memory
and with efficient data structures, so we can very, very quickly calculate the
clusters, linearize them, do block-building on them, do eviction on them, do
replacements and combine clusters or split clusters.  So, this data structure is
literally only for the graph in the mathematical sense operations and makes that
very efficient.

**Mike Schmidt**: Some people may think, "Oh, this is the Bitcoin Core
developers tinkering and maybe something that was, you know, number three
candidate transaction goes to number four, and it's just being pedantic about
this.  But I recall, I don't know if it was Gloria or sipa, illustrating an
example of actually the transaction that would be most profitable to mine was
actually the first one that was evicted, or some such, so that's basically as
extreme as you can get.  Maybe, Murch, you have more color on that.

**Mark Erhardt**: Yeah, right.  So, in the old mempool design, we were using the
descendant score to determine which transaction should be evicted next and the
ancestor score to determine which transaction should be picked into a block.
And because they are not perfect opposites, you could construct examples in
which a parent transaction with a feerate that is very low itself, that has tons
of really bad descendants, would have such a bad descendant score that it would
be up for eviction.  But on the other hand, if it had one really good child that
bumped it very high, it would also be perhaps in the set of these two
transactions to be picked into the next block.

So, one of the big benefits of cluster mempool is we get a total order on all
transactions in the mempool, first by splitting up what cluster each transaction
belongs to, then by knowing the order inside of the cluster.  And then
essentially, we know the order in the entire mempool by looking at all the best
transactions across the clusters, which one of them is the very best that's
going to go into the next block first, and so forth.  So, we actually know
exactly what the last thing is that we're going to mine, and that's the thing we
would be evicting now.  So, where we had that asymmetry in eviction and block
building before, that's gone.  We now actually know exactly in what order we
would mine everything, and what we evict is the last thing we would mine, and
what we put into blocks is the first thing we want.

**Mike Schmidt**: I mentioned this last week when we had sipa on, but I thought
that the writeup that Gloria did for this particular PR Review Club was quite
informative.  So, if you're somebody who's heard about these PR Review Clubs and
you're a bit intimidated, or you don't want to attend or you can't attend based
on the schedule, first of all, it's all in text and captured so you can go back
and revisit it.  But secondly, you can always just go and read the introductory
writeup without jumping even into much, if any, of the code and still get some
takeaways.  So, I would encourage folks to jump into the write-up for this
particular Peer Review Club if you're curious.

_LND v0.18.5-beta_

Notable code and documentation changes is not next, so I shouldn't have read
that.  Releases and release candidates!  LND v0.18.5-beta.  We spoke about the
RC for this beta last week, so for some details, check out that summary last
week for an overview, or better yet, the final release notes that are linked on
the GitHub release page that we linked to in the writeup this week.

_Bitcoin Inquisition 28.1_

Bitcoin Inquisition 28.1.  As a reminder, Bitcoin Inquisition is a signet node
based on Bitcoin Core, so when Bitcoin Core upgraded to 28.1 and was released
last month, so too was Inquisition updated to keep update with those fixes and
improvements in the 28.1 release, so that's a chunk of the update.  The other
piece of the update, which is more bespoke to Inquisition is, in addition to
keeping up with Bitcoin Core changes, this Inquisition release also adds support
for ephemeral dust, which is slated to be in the forthcoming Bitcoin 29.0
release.  Okay, so that's going to be in Inquisition, but maybe, Murch, we
talked about ephemeral anchors and now we have this other ephemeral thing called
ephemeral dust.  So, what is this ephemeral dust that's in Inquisition?

**Mark Erhardt**: Right.  So, we usually do not allow outputs that are below a
certain value, because we're worried about the outputs being of so little value
that they can't pay for themselves being spent later.  And so, the dust rule is
a standardness rule by Bitcoin Core nodes.  They simply will not accept
transactions that create dust outputs, so outputs with very small value.  Those
transactions are non-standard, they don't get relayed by default.  Miners don't
include them in their block template if they run Bitcoin Core, obviously.  So,
ephemeral anchors is a change in the standardness rules, and it combines the
ideas of P2A and ephemeral dust.

So, currently, even if you have a P2A output, it would have to adhere to the
dust rules and would have to have enough sats so it is worth it to be spent by
itself.  Of course, for an anyone-can-spend output, that might make it
attractive for miners to collect, which isn't a huge problem because it still
means that your transaction gets included, but it might interfere with
expectations like, "Oh, I attached a transaction to this and I really expected
that attached transaction to also get into the block", which might not happen
because the miner grabs the output value instead.  So, the idea behind ephemeral
anchors and ephemeral dust is now, if you have an output that is being spent in
the same block, it may be under the dust limit.  So, you can create it and
destroy it in the same block, but only if it's being spent immediately in the
same package, we allow it into our mempools.

So, this is interesting in the construction for Lightning.  Now you could have
an anchor output that has zero sats, so there's no incentive for anyone else to
grab that output except for the two channel participants that might want to see
their commitment transaction to be confirmed.  And the transaction itself is not
allowed to pay any fees if there is an ephemeral output.  So, the commitment
transaction itself would have a fee of zero; the anchor output would have an
amount of zero; and you would only be able to bring fees to get the commitment
transaction confirmed in a child transaction that attaches to the ephemeral
anchor, spends it in the same block, and incentivizes the inclusion of both the
commitment transaction and the child.

**Mike Schmidt**: Murch, why is there the restriction that in this case, the
parent transaction cannot pay any transaction?

**Mark Erhardt**: So, if the parent transaction itself brings fees, at very low
feerates it might be attractive to just include the parent, even if there is no
child transaction.  And then, you would create an output with an amount of zero
that nobody ever has an incentive to spend because there's no value to be
captured, and cleaning it up just costs money.  But it could be spent, so
everybody needs to keep it in their UTXO set forever because otherwise, if
someone down the road at some point spends it and we cannot forget about it, we
would fork the network.  So, the idea here is if the parent transaction is
paying zero fees, a miner has no incentive to include it into their block.  And
hopefully, the creation of these ephemeral dust outputs that live in the UTXO
set forever is curbed, because the only output that is allowed to be spendable
is the P2A output with zero fee and that one has to have -- sorry, I think the
specific rule is, if a transaction has the anchor output, it has to be spent in
the same package.  You can of course spend more than one output from the
transaction, but they all have to be spent in the same child transaction, and
the child transaction has to bring the fees.

**Mike Schmidt**: So, similar to the motivation for preventing dust, which is
you want to protect the size of the UTXO set and have it be as small as
possible, ephemeral anchors and ephemeral dust is doing that while allowing the
creation of a dust output that's never actually put into the UTXO set, because
it must be spent.  I guess this is an advantage of spending from unconfirmed
transactions enables this, as we talked about some downsides to it previously,
because it's never actually added to the UTXO set.  Now, of course, a miner,
there's no consensus rule, right?  So, a miner could decide to still
back-channel and have a zero-value UTXO, right?  But that's possible today.

**Mark Erhardt**: Right, yeah, so it could happen, and we can't prevent it.
They could do it today already.  We have a bunch of dust once that output's in
the UTXO set already, but hopefully the incentive design around this mempool
policy rule would be that in the organic use at least, this never happens.

**Mike Schmidt**: So, Inquisition 28.1 would be a good place for people to test
some of their constructions that may use some of these mechanisms in the future
because you're seeing it on a signet test network that's live now, as opposed to
waiting for Bitcoin Core to release 29.0.  So, a little playground for those
folks then.

_Bitcoin Core #25832_

Now notable code and documentation changes.  Bitcoin core #25832 is a PR titled,
"Tracing: network connection tracepoints".  As I mentioned earlier 0xB10C, who
is actually the author of this PR that we're talking about, does a lot of
analysis of activity on the Bitcoin Network.  The more data that he has
available, and others doing similar analysis, the more and better insights he
and these monitoring folks can provide.  So, one way to add more data is to log
that data within Bitcoin Core so it can be queried.  So, in this PR, 0xB10C adds
five tracepoints, which are sort of an internal mechanism to log these sorts of
metrics, to provide that additional data from Bitcoin Core.  Those tracepoints,
not logs, Murch is going to correct me in a second, include when connections are
established, both inbound and outbound connections; when a connection is closed,
whether that's by the local node or a peer; inbound connections that the node
has chosen to evict; and a tracepoint also around connections that are
misbehaving.  I'll pause to get my slap on the wrist.

**Mark Erhardt**: Yeah, I was just going to say, tracepoints are essentially a
point in the code that you can attach external listeners to, so they don't
create log messages unless you hook into them with your package filter software.
And so, yeah, they're not logged in that sense.  As far as I know, it only works
under Linux.  You need to install some special packages if you're interested in
this.  You can obviously only do it with your own node on your local machine,
but what it allows you to do is whenever you hit one of those tracepoints and
you've compiled your Bitcoin Core to enable that tracepoint, you can get direct
access from, like, when that line of code is executed to output some logging via
this external package that hooks into it.  And that makes it very useful for
getting exact details on what's going on, in this case in the P2P and net
processing.  And so, for example, if you're doing orphan research, you might
want to take a look at these user space-defined tracepoints.

**Mike Schmidt**: USDT, not to be confused with Tether.  Because of the
open-source nature of the Bitcoin Core codebase, this is something that 0xB10C
or other folks could have just put in these tracepoints and used them
themselves.  And in fact, that's exactly what 0xB10C did.  He notes, "I've been
using these tracepoints for a few months now to monitor connection lifetimes,
re-connection frequency by IP and netgroup, misbehavior, peer discouragement,
and eviction and more.  Together with the two existing P2P message tracepoints,
they allow for a good overview of local P2P network activity".  But he took
those changes that he was using and testing out locally and put them into
Bitcoin Core with this PR, so that other folks can also turn these on and get
their own analysis and data to potentially provide additional insights.  So,
thank you, 0xB10C, for these.

**Mark Erhardt**: Also, you will notice when you look at this number of this PR,
#25832, this has been open for almost two years!

_Eclair #2989_

**Mike Schmidt**: I did not notice that tidbit.  Thanks for adding that.  Eclair
#2989 is a PR titled, "Add router support for batched splices".  This allows
Eclair to track multiple channels spent in a single splice transaction.  I saw a
comment in one of the files of this PR that I think helps explain.  The comment
says, "A single transaction may splice multiple channels, batching, in which
case we have multiple parent channels.  We cannot know which parent channel this
announcement corresponds to, but it doesn't matter.  We only need to update one
of the parent channels between the same set of nodes to correctly update our
graphs".  I didn't have anything else to add there, Murch.  I don't know if you
have more to unpack.

**Mark Erhardt**: No, I don't.

_LDK #3440_

**Mike Schmidt**: LDK #3440, this completes LDK support for receiving async
payments, which are payments that are made when the receiver is offline.  We
covered a series of related PRs, as LDK has been progressing on this async
payment feature, which you can see under our Async Payments Topic page.  Just
look for LDK-related PRs there at the bottom.  A quote from this PR, "The last
piece after this for async-receive side is support for being the async
receiver's LSP and serving invoices on their behalf".

_LND #9470_

LND #9470 is a PR titled, "Make BumpFee RPC user inputs more stricter".  The
BumpFee RPC in LND bumps the fee of a transaction.  One change in this PR is to
the existing conf target parameter, which is redefined and now specifies the
number of blocks for which the fee estimator will be queried to obtain the
current feerate.  And another change in this PR is a new parameter to BumpFee,
named deadline_delta, that specifies the number of blocks that the specified
input should be spent within.  And that value that you specify is used along
with an associated budget value.  And when the deadline is reached, all of that
budget will be spent as fee.  So, if you're using BumpFee RPC in LND, check this
out because something's changed, something's added, you should be aware of it.

_BTCPay Server #6580_

BTCPay Server #6580 is a PR titled, "Remove LNURL description hash check".  And
this change to BTCPay Server is motivated by an according proposed change to the
LNURL specification, and that proposed spec change was opened in 2023 and
remains open, although it seems to have support.  The LNURL spec folks had
concluded that the check in question, which is being proposed to be removed,
this description hash check, offered minimal security benefits while posing a
significant implementation challenge.  So, that's why they're proposing to
remove it.  Back to the trade-offs discussion that we referenced earlier, yes,
you can do this additional thing, but there's cost to that, and so that's what
this LNURL spec folks have concluded here on this particular check as well.

That wraps it up.  We have no special guests to thank, no audience questions.
So, I will just simply thank co-host, Murch, for always, almost always, maybe
not the next two weeks, always joining.  And we'll hear you all next week.

**Mark Erhardt**: See you.

{% include references.md %}
