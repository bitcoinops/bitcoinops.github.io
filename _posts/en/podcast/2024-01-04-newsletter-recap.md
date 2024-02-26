---
title: 'Bitcoin Optech Newsletter #283 Recap Podcast'
permalink: /en/podcast/2024/01/04/
reference: /en/newsletters/2024/01/03/
name: 2024-01-04-recap
slug: 2024-01-04-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Niklas Gögge, Antoine Riard,
Abubakar Sadiq Ismail, Gloria Zhao, Salvatore Ingala, Johan Torås Halseth and
SeedHammer Team to discuss [Newsletter #283]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-0-4/fbc70141-4a55-8ccd-2a08-597b395ffb64.MP3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #283 Recap on
Twitter Spaces.  Today we have nine news items.  We're going to be discussing
disclosure of past LND vulnerabilities, with Niklas Gögge; fee-dependent
timelocks, with hopefully Antoine Riard; cluster fee estimation, with Abubakar
and Gloria; how to specify unspendable keys in descriptors, with Salvatore
Ingala; v3 transaction pinning costs, with Gloria; descriptors in PSBT draft
BIP, with the SeedHammer team; verification of arbitrary programs using proposed
opcode from MATT, with Johan Halseth; pool exit payment batching with delegation
using fraud proofs, with Salvatore again; and new coin selection strategies,
with our very own Murch.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch and I'm worried that we'll get through all this
stuff today!

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core at Brink.

**Mike Schmidt**: Johan?

**Johan Halseth**: Hi, I'm Johan, I do Bitcoin research and development at NYDIG
in open source.

**Mike Schmidt**: SeedHammer?

**SeedHammer**: Hello, I'm from the SeedHammer team.  We produce and sell
automatic engravers for Bitcoin backups.

**Mike Schmidt**: Salvatore?

**Salvatore Ingala**: Hello, I'm Salvatore, I like Bitcoin and I like trees,
let's put it like that.

**Mike Schmidt**: Abubakar?

**Abubakar Ismail**: Hello everyone, I am Abubakar Sadiq Ismail.  I contribute
to Bitcoin Core, supported by Btrust.

**Mike Schmidt**: And Niklas?

**Niklas Gögge**: Hi, I'm Niklas, I also work on Bitcoin Core, also at Brink.

**Mike Schmidt**: Well, let's jump into it.  We're going to go through the
newsletter sequentially.  I've shared some tweets in the Space for you to follow
along, but the best place to go is bitcoinops.org to follow along with
Newsletter #283.

_Disclosure of past LND vulnerabilities_

First news item this week is Disclosure of past LND vulnerabilities.  Niklas,
you posted to the Delving Bitcoin Forum about a couple of vulnerabilities you
had found previously, both of which are in the LND Lightning implementation.
How would you walk listeners through those bugs, how you found them, how you
disclosed them?

**Niklas Gögge**: Yeah, so at the time, I was still in uni doing some research
for my bachelor thesis on the gossip protocol that's used in LN, and I was
looking at the various implementations and specifically LND, because most nodes
are LND, or at least at the time, I'm not sure what the current status is.  And
yeah, I was looking at the gossiping code in LND and found two issues.  The
first one is a DoS bug, where an LND node is basically at risk of running out of
memory and then crashing.  These types of bugs in LN nodes are bad because if
your node isn't online, it can't broadcast penalty transactions, so you are at
risk of losing funds.  And this bug in particular, so whenever you establish a
new channel, you and your channel partner will broadcast three messages.  The
first one is a channel announcement, and then there's two channel updates, one
for each channel edge, which in the channel update holds channel routing
policies, like the fees you're going to charge.  And while these messages
propagate through the network, a race can occur where a node will see the
channel update before the channel announcement, but you can only check the
signatures in the channel update if you've seen the channel announcement.  So,
if you've seen the channel update before the announcement, you have two choices:
either you throw it away, or you keep it around in hopes that you'll see the
announcement a bit later.  And that's what LND used to do and still does.

But it used to do that with a buffer that's unbounded.  So, it would just store
these general updates that it couldn't validate in a buffer that's unlimited in
size.  So, if an attacker just spams you with invalid updates, you'll just
eventually run out of memory.  And they fix that by introducing a cache for
these premature updates that is limited in size.  So now, yeah, now you can't
run out of memory from this anymore.

**Mike Schmidt**: And maybe talk about the responsible disclosure along with the
timing of when you brought this up versus when it was fixed and all that.  Oh,
we lost him.

**Mark Erhardt**: Your question scared him!

**Mike Schmidt**: That was an easy pitch.  Welcome back, Niklas.

**Niklas Gögge**: Yeah, hi.  My time limit for Twitter just ran out!

**Mike Schmidt**: That's funny!  I was asking, maybe talk a little bit about
responsibly disclosing and then maybe some of the timeline as well.

**Niklas Gögge**: Yeah, should I get into the second bug first?

**Mike Schmidt**: Oh yeah, we can do the timing together after.  Yeah, why don't
you get into the second bug.

**Niklas Gögge**: It's the same for both, so it probably makes more sense.
Yeah, all right, so the second bug is related also to channel update gossiping.
So all LN implementations basically rate limit how many channel updates they
will relay per a given timeframe.  All implementations have different parameters
for what the exact rate limit is.  But LND basically used to rate limit channels
before checking the signatures on the channel updates, which means an attacker
can just spam invalid updates and rate limit a specific channel without valid
signatures, so a subsequent valid channel update would not propagate, because
the rate limit has been exceeded.  And this was just fixed by checking the
signatures before rate limiting.

I guess in theory, the second one could have been used to get some advantage in
the routing, like in the transaction routing market, where you rate limit the
channel updates for your competitors maybe, and their updates won't propagate
anymore, so people would tend to route through you.  But that's, I mean, a bit
theoretical, I'm not sure how easy that would actually be to pull off.  Okay,
then for disclosure, I emailed Lightning Labs.  They fixed both these issues
fairly quickly, later released this, and then I took a lot of time to publicly
disclose this basically, mostly because I was a little lazy.  I should have or
could have done this sooner as well.  Yeah, any other questions?

**Mike Schmidt**: I think if folks are interested, they should jump into the
post on Delving Bitcoin, for some more details there.  I think you provided a
good overview.  Murch, or any of our other guests, do you have a question for
Niklas; or, from the audience?

**Niklas Gögge**: Also, one thing I can add is that basically no one needs to do
anything like upgrade their nodes, because these bugs were superseded by
different other bugs, for example the bug that Burak exploited.  So, nobody can
even run a version that's affected by these bugs.

**Mike Schmidt**: Excellent.  Well, thanks for your great work even in
university on finding these, reporting these.  Obviously, being a Brinkee and
getting a grant from Brink, we love to see this sort of work and testing and
securing the underlying software and protocols.  So, a thank you from me
personally, and look forward to more bugs being mined by Niklas.

**Niklas Gögge**: Thanks.

_Cluster fee estimation_

**Mike Schmidt**: Shall we move on to cluster fee estimation?  All right.
Antoine, while you work on that, we're going to jump to Abubakar's item here on
Cluster fee estimation.  Abubakar, you also posted to Delving Bitcoin about some
insights that you had from the design of cluster mempool, and how specifically
cluster mempool can improve fee estimation in Bitcoin Core.  Do you want to
maybe outline some context on how it's done now versus how it could be done in a
cluster mempool world, and what the benefits might be of that?

**Abubakar Ismail**: Yes, thank you, Mike.  So, there is a known issue currently
in Bitcoin Core's fee estimator, which is it currently considers only the
feerates of a transaction when it's confirmed.  And sometimes, some transactions
are going to be CPFP’d and they are not confirmed based on their feerates, they
are confirmed as a package with the ancestor and its descendant, so it does not
consider the ancestor's score of that package.  And also, it ignores all
transactions that have in mempool a parent.  So it has some incorrect data
points and ignores some data points.  So with cluster mempool, we are going to
have only the linearization of the mempool, which means at each point we will
know the mining score of every transaction.  So, whenever transactions are added
to the mempool, a single transaction is a single chunk.  So, the fee estimator
will now track transactions in chunks instead of tracking them individually.
So, whenever a chunk's feerate is updated, the fee estimator is also going to
track that, which is going to fix the two issues that we have currently, which
is incorrect data point and ignoring some data points.

There are some concerns about this also, which is there may be some mempool
difference between users' node and the new block, which will mean that after you
get a new block with lots of transactions, some of the chunks that you track
might not correspond with what is in the block.  After I posted this, some
contributors commented, and what we are going to do about this is we are going
to ignore these discrepancies.  Whenever a chunk field did not match what is in
the block, we are just going to ignore that data point.  So, this is briefly
about the first.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: Could you go into a little more detail how you would
distinguish whether the chunk feerate was used to pick a transaction into the
block versus it being in a different spot?

**Abubakar Ismail**: Okay, so when we are tracking the chunks, for example, a
particular chunk might have two transactions, but when the new block arrives,
maybe only the parent is confirmed.  The parent transaction is incentivized
minus enough and only receives the payment transaction, so the chunk feerate may
differ in this case.  And if the mempool also differs from the current node with
what miners has, maybe in my own mempool, I have maybe three transactions in a
package and the node does not see the two transactions, it only sees one
transaction.  And when it confirms that it will only be one transaction, and
what I have in my mempool, fee estimator mempool will be two transactions, so
the chunk feerate may differ from what the block has.

**Mark Erhardt**: Right, so basically you're looking at whether the transactions
that belong to the same chunk reappear in the same order at the feerate that we
would have picked transactions with the chunk feerate into the block, otherwise
you know that you can ignore it because it might have been there for other
reasons; or if they're split up, they might not have been treated as a chunk by
the miner that picked them?

**Abubakar Ismail**: Exactly.  We also don't want miners to influence our
estimates.  Maybe miners might be removing one transaction from each chunk and
then you are tracking it incorrectly.  So, we want a situation whereby we are
tracking only what we see in our mempool.  If it does not match the new block,
then we will just ignore that.

**Mike Schmidt**: Did you have another comment, Murch?

**Mark Erhardt**: No, I just have too big fingers and hit the wrong button!

**Mike Schmidt**: All right.  Gloria, do you have any thoughts on what
Abubakar's outlined here?

**Gloria Zhao**: Not much to add.  I think we looked at this a couple of years
ago, kind of before cluster mempool was as fleshed out as it is today, and it
was like, yeah, there's not really a way to do this because we can only really
look at static ancestor descendant scores.  And really, anytime a chunk theory
changes, it's like a brand new bid.  So really, one transaction can correspond
to multiple bids for block space, right?  It can get CPFPd, it can get CPFPd
again, it can be CPFPing something that gets CPFPd by something else.  And so,
having cluster mempool really naturally solves this, along with other issues of
a very similar nature, of course.

**Mark Erhardt**: I find it remarkable that people are already talking about
cluster mempool as being here because we've been thinking about it so much, but
I need to caution the audience that cluster mempool is still in draft stage.

**Mike Schmidt**: Yeah, maybe a quick clarification there, maybe Murch, Gloria
or Abubakar, whoever feels like they want to take it.  Is there something with
cluster mempool that can be played with from a code perspective right now; and
is that how this sort of experimentation or theorization of how fees could be
estimated better came from code, or more theoretical?  Go ahead, Murch.

**Mark Erhardt**: So, there's a bunch of writeups on Delving Bitcoin already
that detail the concepts in a very large depth.  And I believe there is an open
PR by Suhas, which is a draft, not actually proposed for merging, but more as a
discussion point for talking about the design space of cluster mempool.  I don't
think that there's more than that yet.  Gloria?

**Gloria Zhao**: Yeah, I guess for me, so prior to cluster mempool, when it
hadn't begun to enter my imagination as something that could be done, what I was
trying to advocate for was having a persistent block template built, just so we
have an idea of what the next block looks like and what the miner, ie chunk
feerates, of those transactions are using today's vocabulary.  So, I had a list
of things where it's like, okay, if you know the miner score, ie the chunk
feerate again, of this transaction...  I mean, we kind of had this when we were
talking about ancestor-aware funding, right, Murch, where we were like, okay, if
you had some kind of black box that could tell you what the chunk feerate or
incentive compatibility score or mining score, all the terms that we use to talk
about this type of feerate, then we could solve this whole list of problems.
And so for me, I guess this black box has existed in my brain for years, and now
it feels concrete.  I mean, there's code, right?  It's bread that's been eaten,
it's done, we have it today!

**Mark Erhardt**: Well, it is happening.

**Gloria Zhao**: Yeah, it's happening.

**Mike Schmidt**: Well, I think normally we'd want to spend a little bit more
time on some of these items, but in the interest of nine news items, I think we
can move on.

_How to specify unspendable keys in descriptors_

Antoine said he connected to a different Wi-Fi but now we have lost him, so we
will continue with the next news item, which is How to specify unspendable keys
in descriptors, and we have Salvatore here who started the discussion, also on
Delving Bitcoin, about how to allow descriptors to specify a key for which no
private key is known.  Maybe, Salvatore, let's just start.  What's an
unspendable key; and then, why do we want it in descriptors?

**Salvatore Ingala**: Yeah, sure.  So, an unspendable key is just a key for
which we are pretty much sure that nobody knows the private key.  So, that makes
it useless in the sense that you cannot spend by using that key, right?  So, it
sounds a stupid idea to put unspendable keys in general, but in the world of
taproot, that's actually something that we might need to do in some situations,
because a P2TR output has these two components, which is the internal key, which
is just a public key, and three of the older scripts.  And so ideally, taproot
is designed in such a way that you want to spend with the internal key as much
as possible, because that's the cheapest way of spending it and it's also the
most private, because nobody even knows that there are scripts if you spend in
that way.  But there might be situations where you don't want to have an
internal key, because you don't want to be able to spend just with a public key,
because you use some complicated miniscript policies, and so we need a solution
for that.

There are many known ways of creating manually an unspendable key.  Some of them
are also specified in some BIPs, like BIP341, if I remember.  But there is no
codified way to encode these things in descriptors yet, which is what you want
to use to create these wallets with a software or a hardware signing device.
And that will make it difficult for the users who are not very experienced to
use this kind of situation, these kinds of wallet policies.  And so, in the
context of making these things easier to use, I think it's important to define a
standard sooner rather than later so that all the software wallets can get up to
speed with these kinds of things.

So, there are two things that are important in this.  One is just having a
standard, and I did some brainstorming on how the standard could look like.
Actually, Pieter Wuille and other people had done already some brainstorming
that I had forgotten about.  I didn't find the GitHub gist initially, but more
or less it's very similar to what I was proposing, I think.  And another thing
that it's a little bit beyond that is an attempt that I was discussing on
minimizing the amount of information that needs to be stored in the backup of
the policy, because when you use these kinds of scripts with a hardware signing
device, currently the biggest point of friction for the users is to have to
verify when they create this new wallet; they have to verify on the screen of
the device the script that they're using, so the descriptor actually matches
what they have in their backup.

So, the more information is there, the more it becomes difficult, especially
because often these devices have a very small screen.  So, if we show more
information, people are more likely to skip this security step, which actually
makes them vulnerable to some attacks, because if someone replaces some keys
without telling them, for example, then they would end up not having a backup of
their policy, which can be used to attack them, to ransom them, or so forth.
And so, yeah, I was discussing an approach where actually you would be able to
avoid having any additional entropy on the wallet policy itself, because what
matters for this unspendable key is that you have enough entropy to an external
observer so that people cannot guess that that's an unspendable key.  This is
just a useful thing to avoid fingerprinting.  But you actually don't need this
entropy to be unknown to people who actually know the descriptor.

So, one approach that I was proposing was to actually derive this entropy from
the rest of the keys in the descriptor, because those are known to whoever knows
the descriptor.  And so, that will avoid to have any entropy at all that needs
to be shown to the user, because it's not part of the backup.  I hope I didn't
go too fast.

**Mike Schmidt**: No, I think that was good.  I think one of the points of
discussion was this just having something hardcoded or not.  Maybe you touched
on that a bit, but maybe elaborate on that discussion.

**Salvatore Ingala**: Yeah, so the simplest solution would be to just have one
known public key that is known to be unspendable, and that works, would be very
easy to do, would not require even any change to descriptors, because at that
point that key becomes easy to identify for software or hardware signing
devices.  But the problem is that every time you spend from that policy, from
any UTXO that uses this kind of script, external observers will know that that
key was not spendable, which is not a terrible thing because it does not reveal
a lot, but it still reveals something, like allows you to distinguish from other
wallets that actually have a real key, so it is some amount of fingerprinting.
And so, any fingerprinting is bad because once you combine different bits of
information here and there, you can combine them and you end up actually being
able to fingerprint more.  So, if we can avoid fingerprinting, it's always a
good thing.

So, the idea of both the approaches I was proposing, and also the approach from
Pieter Wuille, is that we can use an xpub, so an extended public key, that has
the known unspendable public key, but put the entropy in the chain code, because
that guarantees that if the chain code has enough entropy, once you derive keys
from this public key, the child public keys are also guaranteed to be
unspendable, but nobody can know that they are derived from this original public
key.  So, that's basically the gist of the idea.

**Mike Schmidt**: Murch, did you have a question?

**Mark Erhardt**: I do not, thank you.

**Mike Schmidt**: Salvatore, thanks for walking us through that.  I know we have
an item that we're going to talk with you about shortly, so hopefully you can
stay on.

**Salvatore Ingala**: Yeah, of course.

**Mike Schmidt**: And obviously, if any folks have questions or comments on any
of these Delving Bitcoin posts or discussions, feel free to request speaker
access or comment in the Twitter thread.

_Fee-dependent timelocks_

We'll jump back quickly to the second item from the new section, which is
Fee-dependent timelocks.  And Antoine, we lost you a little bit in the audio
earlier, so maybe start your framing of this discussion over.

**Antoine Riard**: Do you hear me better?

**Mike Schmidt**: Yes.

**Antoine Riard**: Okay, cool.  So fee-dependent timelock, it's a new proposal,
it's a new consensus change, and it's aiming to solve a longstanding problem in
the offchain space, the Bitcoin offchain space.  This longstanding problem has
been formalized for the first time in the Lightning white paper, in underscoring
the risk of mass force close.  So, let's say you have millions of offchain LN
channels open and everyone goes onchain at the same time, the blocks become full
and the fees are spiking and you start to have an issue in the sense of all the
values in your LN channel funds might not be enough to pay onchain fees to get
in the blocks before the timelocks are expiring.  And if you are like millions
of LN users reacting the same and force closing at the same time, we might start
to have this massive forced closure.  And that's quite concerning, because if
you cannot confirm an LN channel before the channel expires, your funds are
going to be jeopardized and you are not going to be able to recover your funds
before your counterparty might be able, and your counterparty might be able to
escape the punishment or your counterparty might be able to double spend an
offchain Hash Time Locked Contract (HTLC).

So, feerate-dependent timelocks aims to solve this by introducing a new logic
where you do have a feerate upper bound encoded in a transaction's nSequence
field.  And there is a new median feerate, which is computed from windows of
size n, and this size n is going to be on the last block.  So, you're going to
look on each block, you're going to compute a median feerate, take the 4 MB of
weight unit of the blocks and look at half of them, and compute this per-block
feerate for the n blocks of your windows.  And if the transaction's encoded
feerate is under this median feerate, it can confirm; if it's above, it won't
confirm.

So what is enabled?  In case of onchain congestion, your LN option transactions,
the confirmation of them are going to be delayed until the block congestion is
slowing down.  So, we start to have these dynamic mechanisms where people might
be able to delay confirmation of their option states until they can confirm at
an acceptable feerate.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: So, let's say there are a million LN channels that all need to
go onchain at 50 sat/vB (satoshis per vbyte) and their transactions are locked
with your new described mechanism.  So, transactions with 50 bytes remain locked
because feerates are too high.

**Antoine Riard**: Yes.

**Mark Erhardt**: Then after some time, the feerate comes back down, and now all
those 1 million transactions all want to get into the block and the block does
include transactions that are 50 sat/vB, but there's still not enough room.  So
wouldn't they still become valid to include?

**Antoine Riard**: There is not enough room in the sense of the block is still
full?

**Mark Erhardt**: Yeah, because a million transactions can't fit in one block.

**Antoine Riard**: Well, you're still in competition, but what this mechanism is
enabling you is, it's putting the responsibility on the users to determine the
fee level, the fee bumping reserve level that you should keep, in the sense of
at 25 sat/vB, my understanding of John Law's proposal is your transaction should
be able to confirm.  There are no more under delayed timelock.

**Mark Erhardt**: So, if the median feerate of the blocks is lower than your own
feerate, you should have been included, so at that point you become --

**Antoine Riard**: Yes, yes --

**Mark Erhardt**: Okay, I see, yeah.

**Antoine Riard**: -- a block withholding transactions, because your
transactions are being above the median block.

**Mark Erhardt**: Right, okay.  How likely do you think that this can be
actually put into the protocol?

**Antoine Riard**: So, I think I made the comments, because John Law's proposal
is adding this in the nSequence field, and I made the counterproposal that you
can -- does everyone know about the taproot annex which has been added by
BIP341?

**Mike Schmidt**: Perhaps, maybe we can just assume that knowledge for now.

**Antoine Riard**: Yeah, so it's some kind of new data space, which is part of
the transaction for P2TR spends.  And it's been left as some kind of web chat
for developers for, let's say, when we want to add more features into protocol
at the consensus level.  And I made a contract proposal, we might add this in
the annex, in the sense of we can encode bigger values and we can encode more
granularity in the mechanism.  So, if something fits, it fits well there.  My
biggest concern is more like median feerates and how we could do this and not
introducing a new DoS vector.  It doesn't sound it's no more complicated, code
level than something like median time passed and all the timelocks logic, but
they are quite complex technical issues in themselves.

So to answer the question, I think the proposal is still early.  I think we are
still understanding better how it solves a lot of LN security issues and how it
can solve also other time-sensitive second layer technical issues.  And also,
how you could combine this with other proposals to solve many more new security
issues.  Because as soon as you start to have median feerates in blocks, you can
introduce some upper bounds on the level of fees that people are going to burn.
And based on this, we move a lot of games, spinning games, so yeah, and things
like this.  But in my opinion, it's more like an add-on that we could have on
top of this.

**Mark Erhardt**: The other question that comes to mind right now is, have you
seen any discussion of what happens when this minimum feerate never gets reached
again; the funds are just locked up indefinitely and neither side can exit?

**Antoine Riard**: You mean like -- yes, that's a very good question.  Your
funds should stay locked.  I did propose to introduce some kind of cross delay
or some kind of, let's say we introduce relative timelocks but the end point of
your relative timelocks is the latest block of the feerate windows.  And based
on this, you might say you might introduce a new spending branch where you're
burning the fees or where you're giving 50% back to the miners, or… it's a good
question.  It has not been raised yet as a concern.  Yeah, but funds might stay
locked in a way.  The hard thing is you don't want to screw miners sometimes,
and you don't want to introduce some kind of advantage or any kind of games at
the advantage of one of the counterparties.  So, yeah.

**Mike Schmidt**: Any other questions from Murch or our special guests?  All
right.

**Mark Erhardt**: I'm good, thanks.

**Mike Schmidt**: Hey, Antoine, thanks for jumping on and joining us.

**Antoine Riard**: Thanks.  And look on the proposal, it's very interesting.

**Mike Schmidt**: You're welcome to stay on, but if you have other things to do,
you can drop as well, Antoine.  Thanks for joining.  Cheers.

**Antoine Riard**: Yeah, thanks.

_V3 transaction pinning costs_

**Mike Schmidt**: Next news item, V3 transaction pinning costs, which was a
discussion initiated by Peter Todd on the Bitcoin-Dev mailing list, talking
about transaction pinning v3 transaction relay policy for different contracting
protocols, like LN.  Peter was unable to join us today to represent his idea,
but the good news is we have Gloria here, who I think will do a good job of at
least explaining what Peter's trying to get across, and maybe some of her
thoughts on it.  Gloria, how would you frame up what Peter's trying to say here?

**Gloria Zhao**: Yeah, sure.  I think there are two main things that he started
with, with his reviews that he posted, and then there's more recent stuff that
we can talk about.  So, the main thing I think is that pinning still exists, is
the assertion there, and we're talking about rule #3 pinning which is, with a
replacement, you have to pay at least the fees of everything that you're
replacing.  And of course, that can include the transaction that you share with
your counterparty as well as any descendants that they would have attached to
that.  And so today, due to current descendant limits, which are 101,000 virtual
bytes across 25, sometimes 26 transactions, today there is a lot of room to
attach a very large transaction that doesn't pay a necessarily high feerate, but
does pay a lot in absolute fees.  And so, for you to need to replace that, let's
say you're thinking, "Okay, I want to fee bump my transaction to x feerate, so
I'm willing to pay this much in fees", the pin is that you might need to pay
more than that in order to replace things that have been maliciously placed
there to make it more costly for you to pull off your fee bump.

So, Peter Todd's analysis, where he looks at the lower and upper bounds of what
these transaction sizes can be with v3, he's pointed out that it is still
possible for an attacker to pin you and make you pay up to, I think his number
was 1.5 times more than what you would have wanted to pay in order to do your
CPFP.  And so, that is true, though because this is basically due to kind of the
worst-case scenario ratio between the share transaction and the size of the
descendants, the ratio with v3 is a lot closer to, let's say 2 or 3, whereas the
ratio today, worst case, is more than 100.  And so, we played around with some
ranges of transaction sizes that were given where we said, "Okay, here's a worst
case, here are some feerates, obviously all of these numbers are configurable
depending on what the feerate market is and depending on, let's say, how many
HTLCs are in that commitment transaction that you share and you're trying to
bring onchain".  And we did the math and I was like, "Look, the worst case in v3
is correct.  You might have to pay a few thousand extra satoshis".  And this is
as promised in the v3 proposal.  We help mitigate pinning attacks because today
the worst case is you might have to pay extra millions of satoshis in this same
scenario.

Hopefully I've represented this in a fair/objective way, where it's like yes,
congrats, pinning is still possible, but if you are talking about quantifying
the actual damage that you can do in this case, our goal or at least the promise
was not you're never going to need -- it's zero, right?  It's been worded as,
"This is a 100X improvement", because the ratio, let's say the descendant size,
that you can add has been brought down by a hundred times.  And so, hopefully
that makes sense where basically the gripe is, "Oh, there's still a small window
of opportunity to do bad", and it's like, okay, we've brought that down by a
magnitude of hundreds.

**Gloria Zhao**: Murch, do you have a question?

**Mark Erhardt**: No, I wanted to comment.  I've glanced at the discussion
around this analysis, and in a way, it feels like Peter is doing you a favor by
steelmanning just how much better v3 transactions will be in pinning situations
than the current situation.

**Gloria Zhao**: Yeah.  So I think essentially, I don't know, I'm not trying to
misrepresent anything, but yeah, he gives, "Okay, what if your transaction has
this size?"  And I'm like, "Okay, let's do the math of what would happen today
and what would happen in a v3 world".  And the numbers, I think, speak for
themselves.  And it's not this like magic number, it's not like sneaky magic
with numbers, it makes sense because we are severely reducing the ratio of
worst-case amount of descendant size attached to your transaction.

**Mike Schmidt**: So, it sounds like the discrepancy here is under the terms
"significant" or "substantial" mitigation and "insufficient", these sort of more
subjective things, which through these discussions has turned into more
quantified savings that, well, I guess if you don't value the decrease in 100X
or the fact that we went from having to pay 100X to 1.5X, we all agree that
that's still there, but it's obviously a substantial improvement, even if some
folks may think that that's not enough.

**Gloria Zhao**: Yeah, and of course these numbers depend on what the
restriction is set at.  So, with the numbers that we played with, v3 restricts
your child's size to 1,000 virtual bytes.  And so, one of the things that Peter
Todd recommended was to shrink that even further, so to reduce that ratio, to
squeeze that down as much as possible.  But I think I'm not super-convinced of
that because the smaller you make that number, also the more difficult it is for
LN wallets to always be able to fund those transactions, those fee bumping
children, with a smaller number of UTXOs.  So, we could reduce it further, but I
think this is a good trade-off between what's the pinning maximum damage and how
usable and feasible is it to expect people to keep their transactions this
small.

**Mike Schmidt**: Gloria, while we have you and we're talking v3, how would you
summarize the current state of v3 relay and policy stuff?

**Gloria Zhao**: Is Antoine still here?  No, I don't see him.

**Mike Schmidt**: He jumped off.

**Gloria Zhao**: Yeah, so obviously, I don't know, Murch, you said you were
following it.  I'm going to try to be objective, of course, on you said the
question of how people are receiving it.  So, the other kind of two main
criticisms that Peter Todd presented, one was kind of a general criticism of
using CPFP instead of RBF in these protocols and in general, because of how
efficient it is.  So, I think the tagline that a lot of people latched on to was
that CPFP hurts mining decentralization.  And the argument is, well, CPFP is not
very efficient, right?  You have an output in the LN anchors construction, it's
a script and it takes up space in both the scriptPubKey and when you go to spend
it, and all those extra bytes need to go on chain and obviously you need to pay
the fees for that as well.  And so, this is less efficient than, say, if you
could create an RBF to replace that transaction.  Or of course, nothing as
efficient as if you could hand a lot of cash to a miner and have them just
include it for you, obviously.

So, I guess the argument is that because the protocol is writing that you need
to use CPFP in LN, this creates a reason for people to -- actually, I'm sorry, I
don't know how -- it's inefficient!  So therefore, it's better to -- I don't
know.  I don't know how you get to the hurting decentralization.  Okay, Murch,
you have the argument?

**Mark Erhardt**: I don't know about how this would hurt decentralization.  I
think I wanted to respond to the, "You should be using RBF instead of CPFP".  I
guess, yeah sure, you could have a 20X-fold or some sort of exponentially spaced
set of RBF transactions for every commitment transaction, but this has been not
well received from LN developers at all, as far as I can tell, simply because
all of the state management in LN is already super-complicated, and if you
create many different variations of the commitment transactions that everybody
has to keep track of, you have all these punishment transactions that you need
to keep track of.  If you have, for example, splicing or other things going on
in parallel, you need to also branch off all of the future transactions of each
variant of your transaction.  Maybe that's not entirely true, but it sounds
super-complicated from the state management.

So, I think that there is a lot of attractive simplicity here.  You have an
anchor that can be spent by each side, it only adds 50 bytes because you need
only an OP_TRUE and an empty input script; and just referencing the UTXO is 40
bytes, plus an empty input script is 1 byte, plus an OP_TRUE is, I guess that
would be 2 bytes, so 51 bytes.  51 bytes is so nothing that I just don't follow
the argument that it's extremely inefficient.

**Gloria Zhao**: Yeah, I think maybe it's definitely more efficient than how it
is today.  That's kind of one of the reasons for ephemeral anchors, is to kind
of cut out some of this fat; you reduce it down to just one anchor instead of
two as well.  But yeah, I don't know if somebody else is able to articulate why
this hurts decentralization.  To be honest, I don't think it makes any sense.

**Mike Schmidt**: Johan?

**Johan Halseth**: Yeah, I guess the argument goes, since it's cheaper to just
not include the child, you can go to the miner and pay him a little bit extra
instead of having it, and he can use that extra few bytes for some other
transaction.  So you would never go to a small miner, right, you would go to the
big pools and pay them out of that.

**Gloria Zhao**: Sure!

**Johan Halseth**: It's a theory, right, so it's very --

**Gloria Zhao**: Yeah, okay, yeah.

**Johan Halseth**: -- non-practical, in my opinion.

**Gloria Zhao**: Yeah.  I think when designing a decentralized protocol, I don't
think you can really use, "Just talk to your miner buddy to get the fees to get
it mined".  I don't think that's a feasible option.

**Mark Erhardt**: Yeah, I think, well, if you look at the effect, yes, there's
50 bytes that the miner could use for another transaction, but overall I think
that the incentives between just the out-of-band communication and the overhead
of that, I don't think that whatever fees get collected with 50 extra bytes
would make a measurable impact on just looking at the time cost.  So, I see in
the tendency that this is a correct argument, but not in practice, I think.  All
right.  Gloria, I think you got to wrap up the topic nicely and I think it was a
good overview of the discussion here.  Did you have anything else?

**Gloria Zhao**: No.

**Mike Schmidt**: Gloria, thanks for joining us.  You're welcome to stay on, or
you can drop if you need to.

_Descriptors in PSBT draft BIP_

Next item from the newsletter, Descriptors in PSBT draft BIP.  So, this is a
Bitcoin-Dev mailing list post from the SeedHammer team for including descriptors
in PSBTs.  SeedHammer, why would we want that?

**SeedHammer**: Yeah, so the background for our case is that we want to back up
descriptors as well as the private keys on steel plates.  And because it's on
steel plates, we do both, we print or we engrave both the descriptor in textual
format and the descriptor in the QR code format.  And to do that in a
trustworthy way, the format of the descriptor has to be both stable in years to
come, and also rather compact so it doesn't take up too much space on the
plates.  And what we're doing right now is that we're using the Blockchain
Commons format for that.  That's pretty compact.  But the backside, the
drawbacks of that format is it's quite rigid, it can't support general
descriptors.  And secondly, it is based on the CBOR encoding, which adds quite a
lot of complexity, especially for constrained devices, embedded devices, and so
on.  And it was also recently deprecated or superseded by Blockchain Commons,
among other things, because of this these problems.  Another thing you can do is
just to engrave or back up the descriptor in text as you would see it in Bitcoin
Core or in other wallets.  The problem with that is that the text itself is not
very efficient to be encoded in QR codes, and the xpubs are pretty long in their
native Base58 encoding.

So, to solve that, we've discussed with a few wallet developers in the
community, and the idea came up that maybe we could just use the PSBT existing
format for efficient binary transfer of data, which is the PSBT, which of
course, given from the name, is made for unsigned or partially signed
transactions.  But the format itself has a pretty general purpose, so it is
very, very straightforward and easy to squeeze in also a descriptor.  And the
idea is then to make the PSBTs with descriptors the way to communicate
descriptors among wallet devices, wallet software coordinators and signers, and
so on.  And the idea of course is that the PSBT format itself is simple to
encode and decode, but also you pretty much have to have a codec for PSBT to do
Bitcoin transactions, to sign Bitcoin transactions at all.  That's the headline
of the motivation of this BIP.  Yeah, that's about it.

Now that Salvatore is on, I do have a question, because I think he or someone
from the Liana team brought up the idea of proof of registration, which is
another extension of that.  We could go into that if you want, but otherwise the
BIP is pretty much pretty simple.  It's just adding an extra field to PSBTs.

**Mike Schmidt**: Salvatore, did you have a comment on the proof of registration
that was mentioned?

**Salvatore Ingala**: Well, I don't know what's the question about the proof of
registration.

**SeedHammer**: Well so just to also motivate that, the idea with the proof of
registration is that just the descriptor itself is untrusted.  I think we had
this previously in this call.  You can't really know whether this descriptor is
trustworthy just by having it, just by having your, say xpub, your signing
device's perspective, having your key as part of the descriptor; you don't
really know whether this is the intended one from the user's perspective.  So,
with proof of registration, the idea is that you add a little bit of extra data
that tells that something, a device with access to the private keys of, say if
it's a multisig setup of course, say signer number one has had access to the
private keys of the xpub corresponding to the signer number one, and has signed
it or Hash-based Message Authentication Coded (HMACd) it, or done something to
the descriptor to say, "Yes, the user, or at least this device has supposedly
gotten consent from the user that this is the descriptor that's intended for
this wallet".  And that's also something I want to add to this proposal.  I
don't know if it needs to be in the proposal itself, or as another extension
decided.

My question would be -- I think Salvatore mentioned on a GitHub issue somewhere,
that HMAC would be enough to do -- you pretty much serialize the descriptor and
then add an HMAC with a key from the wallet.  My question would be, why not do
the signing so that other software can actually verify that this has been
signed?  And also, if you do signing, I think there's a possibility to not have
one proof of registration per cosigner, and thus adding more data to the
descriptor, backup the descriptor information in total, but have one if you do
aggregated signing.

**Salvatore Ingala**: So, yeah, there's definitely some overlap with the fact
that it's in the wallet policies BIP.  The concept of the proof of registration
is not part of the BIP, although it's part of the approach that I use in the
implementation of wallet policies in Ledger devices.  So, the HMAC that Ledger
uses is not just on the descriptor, but it also includes the name of the wallet
policy, which is something that is shown on screen.  That's because this allows
to identify, in a named way, what of your wallet accounts you are receiving or
sending from.  And so, the HMAC makes it immutable.  So, the key that is used
for the HMAC is derived from the seed.  It internally actually uses the BIP21,
which is from Trezor's guys.  But yeah, it's derived from the seed, so it
actually persists even if you load your seed on a new, future, different device;
it will persist and it makes it immutable.

The reason of an HMAC instead of a signature is that, well it's symmetric, so
it's faster, and here the secret never leaves the device.  So, in the first
implementation, I actually used a signature, but then I changed it with an HMAC.
I don't know if there were more questions.

**Mike Schmidt**: Murch, I saw you had a question about the proposal, or you had
your hand up earlier.  Did you want to ask something?

**Mark Erhardt**: Yeah, I wanted to drill in a little bit on, is it just the
PSBT format, or is it inside of the PSBTs, because it wasn't quite clear to me
yet whether this is a way to deliver the descriptor to someone that is receiving
a PSBT or whether it's just reusing the PSBT format to exchange information?

**SeedHammer**: So, the original proposal was just reusing the PSBT format but
having a different header and so on, but I brought it up as an issue in my first
draft and was also suggested and confirmed on the Bitcoin-Dev mailing list that
maybe it should just be part of the PSBT.  So, the actual proposal, the next
draft proposal, is proposing adding a field to the PSBT format itself.  And one
of the reasons is, of course, to not have more matched numbers and headers in a
different file type but with the same format, but also to make it very easy to
take a PSBT with a descriptor and turn it into a PSBT proper that includes an
unsigned transaction.  And another reason is that actually, I didn't know that
when I did the first draft, there's actually an xpub field already in PSBT.  I
suppose that's for if you have just a single-signature wallet with just a single
extended key, you can actually provide that with the PSBT.  So, the proposal is
actually building on top of that and extending it to allow several xpubs, and
then of course the descriptor field itself, where it can express general
descriptors and miniscripts and so on.

**Mike Schmidt**: SeedHammer, thank you for joining us and representing your
draft BIP to the audience.  You're welcome to stay on as we progress through the
newsletter, or if you have other things to do, you can drop.

**SeedHammer**: Thank you.

_Verification of arbitrary programs using proposed opcode from MATT_

**Mike Schmidt**: Next item from the newsletter is Verification of arbitrary
programs using proposed opcode from MATT.  And we have the Delving Bitcoin post
author here, Johan, to talk about elftrace and the proof of concept that he's
put together with OP_CHECKCONTRACTVERIFY, which is from the MATT software
proposal from Salvatore, who's also here.  Johan, that'll be the intro that I
give, but how would you frame up the discussion to try to get people familiar
with what you've put together here in this proof of concept?

**Johan Halseth**: Yeah, so this post was more or less a follow-up to a demo I
did earlier on the mailing list, I believe, where I showed how you could
basically run through this MATT challenge protocol with some arbitrary program
that you could write from sort of an assembly-like language in Bitcoin Script.
So, what I did in this case was to actually use a real assembly language,
RISC-V, and create a kind of compiler that can take this RISC-V assembly and
then convert that to Bitcoin Script that's compatible with this MATT challenge
protocol.  So, it's just like a rough proof of concept, but it shows that as
long as you have the compilers in order, in my case I use a regular GCC RISC-V
compiler to compile a C function down to these Bitcoin Scripts, and these
Bitcoin Scripts can be used to verify the memory as it transitions through the
RISC-V virtual machine that you can run offchain.  So, the point here is that
you don't actually run the program onchain, you only post a trace of the
computation, or a hash of the trace, and then you can use these scripts that's
generated by this compiler to verify every step of the computation.

Together with the challenge protocol that Salvatore laid out in the original
post and that I also demoed earlier, you can in theory compile any program down
to this format and verify it onchain as a multiparty protocol or contract.

**Mike Schmidt**: How would you compare what you've outlined here to what we
also point out is a similar concept, which is the BitVM?  How would you, at a
high level, compare and contrast those?

**Johan Halseth**: Yeah, I think they're based on the exact same ideas.  The
main difference is that OP_CHECKCONTRACTVERIFY is kind of made to support this
exact use case, which makes it much simpler to work with.  It also makes it easy
to create protocols that you don't have to pre-sign any transaction to, you
don't have to pre-determine who can take part in this protocol.  You don't have
to hardcode public keys or pre-sign transactions.  You can also commit very
efficiently to the memory of the machine.  Since you're working on merkle trees
or merklized memory, the memory this virtual machine can access can be very,
very large, while in BitVM, it's a bit more unclear to me how practical it will
be if you have to challenge the BitVM execution onchain, since you're working
essentially with bits that itself takes a full hash to represent onchain.  So,
the theory is based on the same theory.  This is obviously very practical to do,
but still this requires a soft fork; BitVM does not require a soft fork.

**Mike Schmidt**: How would you categorize feedback that you've gotten on the
idea?  I know on the Delving Bitcoin post, it doesn't look like there's yet any
responses, but potentially you've gotten commentary offline or on other avenues
that have either been supportive or more maybe pointing out optimizations that
could be made.  What has the feedback been like?

**Johan Halseth**: Yeah, the main feedback has been positive, and I think it's
been eye-opening for some people that you can do this with
OP_CHECKCONTRACTVERIFY, which is a very simple covenant proposal.  I also got
the question whether this can be done with some of the other common proposals
that's on the table, and that's something I'm working on now, trying to figure
out if any of the other common proposals can be used to make this practical as
well, since it's more or less just checking state from one transaction to the
next.  You don't need a lot to be able to do this, and obviously you get a lot
of power from being able to do this.

**Mike Schmidt**: Salvatore, we mentioned some of your work here.  Do you have
any commentary on what Johan's put together?

**Salvatore Ingala**: Great stuff, Johan.  Thanks for working on this part while
I'm not doing that!  The idea of compiling arbitrary computation was always kind
of like the completeness theorem that I was very proud of in the proposal.  But
at this time, I'm actually working more on basic tooling and basic stuff.  So, I
look forward definitely to combine Johan's work with the stuff I'm doing to get
a framework to basically make it easy to define and use these kind of contracts
and make demos out of.

**Johan Halseth**: Yeah, I can add to that as well.  That's the main challenge
right now, is making this actually developer-friendly.  And now we have to go
through several steps and work with pretty low-level details to be able to make
this work, and that's something I hope to be able to improve on.

**Salvatore Ingala**: Yeah, the challenge, I'm prototyping stuff in Python and
Johan doesn't like Python; that's the main!

**Johan Halseth**: Yeah, that summarizes it pretty well!

**Mike Schmidt**: Johan, thanks for hanging on, I know it's a big newsletter
today, and thanks for presenting your idea here.  Any call to action for the
audience before we move along?

**Johan Halseth**: Try it out and pitch me ideas for example programs I can
implement using this.  That's kind of what I'm looking for now, some really cool
use cases that I can use to actually prototype this.

_Pool exit payment batching with delegation using fraud proofs_

**Mike Schmidt**: Thanks, Johan.  Eighth item from the news section this week,
Pool exit payment batching with delegation using fraud proofs.  Salvatore, this
is a post that you put on the Delving Bitcoin forum.  I think maybe to calibrate
the discussion, the audience is probably familiar conceptually with joinpools or
channel factories and concepts, and I think probably also familiar with the idea
of payment batching with respect to Optech and our harping on exchanges in years
past to implement payment batching for their systems, but you're somewhat
elaborating and marrying the two here.  Maybe you want to take that intro in
whatever direction you think makes sense to get the idea across.

**Salvatore Ingala**: Yeah, thank you.  So, yeah, this post was about some other
aspects of what this challenge response protocol can do.  So, the original idea
in the writeup of the MATT proposal was exactly to do what Johan has been
demoing, which is taking some computation which is too expensive or too large to
do it directly in Bitcoin Script, and using this challenge response protocol so
that you avoid actually doing the computation.  But the key is that all the
inputs and all the outputs and what is the computation, it's all known, so there
is no hidden stuff.  Everything is known, the computation could be onchain if
you were able to do it.  And in this post, I'm exploring something which is a
little different, which is actually avoiding putting the witness onchain at all.

The idea is that if you have a protocol where multiple parties are involved, you
could just have a commitment onchain to some stuff, and then you can make claims
about this commitment.  And as long as you're not lying, you don't need to
reveal anything about the actual data that is part of your commitment.  And in
the context of these pools, which are all these constructions where there are
many users and each user has a balance, basically for all of them, somewhere in
your UTXO, you have some merkle tree where you have for each user a public key
and the balance.  Of course, it could be on the top tree or it could be
somewhere else.  If you do it with math, probably it would be in the hidden data
inside the UTXO.  And so, when you want to unilaterally withdraw from these
protocols, you need to reveal the merkle proof somehow.  That kind of puts a
limit to how small your balance could be if you are able to do a unilateral
withdrawal because that's really a problem in LN, where just a single
transaction of 300 bytes could be too expensive if your balance is just 300
sats, for example.  And this problem gets bigger if you do UTXO sharing, so if
it becomes more expensive to actually put the proof onchain.

The idea here is that, well, instead of putting a merkle proof, you could just
claim, "Hey, my balance is 10,000 sats, and I'm taking it out".  And so, the
idea is that since the balance of all users in this system will be known to all
the other users, if you're lying, people can prove that you're lying.  And so,
as long as there is a way for them of challenging you, you avoid putting the
merkle proof at all onchain.  And so, that's the first step of the idea, but it
becomes more interesting when you generalize that to multiple users at the same
time, because if you have many users with a small balance, maybe their aggregate
balance is large enough to be worth actually withdrawing, right?  And so the
idea is that you could have some intermediary that takes the job of withdrawing
for a bunch of users.  So basically, all these users will delegate to this
intermediary, and then this intermediary just claims, "I have the permission to
withdraw this amount of sats from all these users".

To make this protocol work, you need to have different ways of challenging,
because of course the intermediary could lie and not actually have the
delegation.  And so, you need to be able to challenge them if they actually
don't have the permission.  And also the intermediary could lie on the total
balance of the users.  And so, you need the other users who are in the pool, if
the intermediary is lying, you need to be able to challenge them on the correct
information and halt the withdrawal basically.  And the kind of challenge
response protocols are very similar to the ones that would be used in the MATT
proposal, like similar to the ones that Johan has been building.  And the cool
thing is that compared to other ways of doing unilateral withdrawal, the amount
of bytes per user is a lot smaller.  Ideally it could be just a few bytes per
user and actually I sketched an approach where if most of the users are
withdrawing, you could actually bring that to just a few bits per user perhaps.

So, this kind of approach could be interesting for any kind of construction that
has this property that all the users' balances are known to all the participants
in the system.  And so, that could be useful for something like Arc, could be
useful for coinpools, could be useful for an optimistic rollup in the future if,
for example, the operator is non-cooperative or stops responding.  And so, it
could be plugged as a plugin to all these kinds of existing constructions,
because you can create this UTXO where the only allowed action is to take your
money out.  So, you would use this UTXO as a disaster recovery where, for
example, if the operator stops responding, you embed the mechanism in this layer
2 protocol so that the UTXO can be spent to this unwinding contract.  And so, on
this contract, then you can do these kind of proofs.

**Mike Schmidt**: There's been a lot of discussion in the current environment
lately about things like joinpools and sharing UTXOs.  Am I right in
understanding from the writeup that what would be required here is a few
different opcodes, including OP_CAT, OP_CHECKCONTRACTVERIFY, and some
introspection opcode as well; and then potentially it would be easier with
OP_CHECKSIGFROMSTACK?  Is that the right, or is there a more MVP version of this
that could get out with less of the opcodes?

**Salvatore Ingala**: Well, I think you basically need to be able to do
challenge response protocols, which is what I call MATT.  So, you could get
challenge response protocols in different ways.  So, OP_CHECKCONTRACTVERIFY plus
OP_CAT is the most direct way, but you could actually get the same functionality
of MATT with other proposals, other different opcodes; unclear how efficient, of
course, but it should be possible.  But here, the only additional thing compared
to the core MATT proposal is that you need to be able to check, at least with
equality, the amount of outputs.  So, you could just add one opcode to put in
the stack, for example, the amount of an output, which anyway will be needed for
something like a coinpool.

Yeah, also I mentioned some nice-to-haves, because for the current semantics
that I implement in OP_CHECKCONTRACTVERIFY, you could do it without in
principle.  So, I mentioned OP_CHECKSIGFROMSTACK and I mentioned 64-bit
arithmetic.  64-bit arithmetic, if you have OP_CAT, you can actually simulate
it.  It's awkward, so we would like not to do it, but it's possible.  And
OP_CHECKSIGFROMSTACK, I mentioned that there is a trick to simulate the
functionality of OP_CHECKSIGFROMSTACK with a workaround where you use some
pre-signed transactions, basically.  So, if you have OP_CHECKSIGFROMSTACK it
becomes nicer because you can just verify signature on signed data.  That's
needed basically for signing the delegations.

**Mike Schmidt**: We have a requested speaker from the audience.  And Adrian,
I've given you speaker access.  Did you have a question or comment for
Salvatore?

**Adrien Laco**: No, sorry.

**Mike Schmidt**: Murch or Johan, any questions or comments for Salvatore on the
proposal he posted to Delving Bitcoin?  Murch says he's good.  Johan, any
comments?  All right.  Salvatore, thanks for joining us.  Any calls to action
for the audience on any of the items we discussed today pertaining to your
proposals?

**Salvatore Ingala**: Not really.  Just think about cool stuff we can do with
covenants.  We are just at the beginning.

**Mike Schmidt**: Thanks for joining us.  You're welcome to stay on, but if you
have other things, you're free to drop.

_New coin selection strategies_

We have one more news item for this week, New coin selection strategies, and
this was authored by co-host of our show, Murch, posting to the Delving Bitcoin
Forum.  Murch, I'll let you introduce and elaborate on your discussion on
Delving Bitcoin.

**Mark Erhardt**: Yes, so some of you might have noticed that we've had slightly
higher feerates recently.  And in July, I thought that it might be time that
Bitcoin Core finally -- the wallet gets in a coin selection algorithm that
actually minimizes the weight at high feerates because none of the existing
three coin selection algorithms guarantee to minimize the weight.  So, Branch
and Bound (BnB) obviously will find the least wasteful solution, but there is
not always a changeless solution.  And then Knapsack will find the solution that
uses the least overshoot over the target.  And SRD is just a Single Random Draw,
so it'll just randomly bumble around in your UTXO pool until you have enough
funds.

So, I wrote CoinGrinder, which is basically a re-implementation of the same idea
as BnB, but it minimizes the input weight for an input set that creates a change
output.  And yeah, that doesn't have so much review yet, but I just got a good
review from one of my colleagues and I'm restructuring my PR.  But generally,
the idea is I can just actually search the entire combination space of my UTXOs
for the input set with the smallest weight and use that, especially at feerates
like 300 sat/vB.  So, hopefully next week when this PR is open again, I would
love for people to take a look at both my simulation results, which I posted
about in Delving Bitcoin, or my PR, because if that ships in the next release,
maybe if the BRC-20 nonsense hasn't tapered off completely by then, we would
have at least a tool in the Bitcoin Core wallet to build the minimal weight
input sets of transactions.

**Mike Schmidt**: Yeah, there's a lot of data in that Delving Bitcoin post, two
different simulations with tons of graphs and tables for folks to look at.  It
sounds like there'll be a new PR open soon, so if you're curious about coin
selection, take a look at both of those.  Anything else you'd call for folks to
do, Murch?

**Mark Erhardt**: Well, I've got zero responses on my Delving Bitcoin post, so
if coin selection is your sort of jam and you're looking for an interesting
read, maybe have a look and let me know what I'm missing to convince people to
review my PR.

**Mike Schmidt**: Murch, thanks for walking us through that.  Normally I offer
for guests to be able to jump off, but you have to stay on now and go through
the Releases and release candidates and Notable code and documentation changes
with me.

_Core Lightning 23.11.2_

Releases and release candidates.  Core Lightning 23.11.2.  We cover the PR
that's part of this release below, so we'll punt on that for the moment.  I
think it's just that PR that's part of this change in Core Lightning (CLN).

_Libsecp256k1 0.4.1_

The next release is to libsecp, and this change makes some performance
improvements.  Quote, "The point multiplication algorithm used for ECDH
operations was replaced with a slightly faster one".  And also another quote,
"Optional handwritten x86_64 assembly for field operations was removed because
modern C compilers are able to output more efficient assembly".  So, it sounds
like folks were hardcoding some assembly for performance reasons that the
compiler wasn't able to compete with, and now the compiler is such a state that
that handwritten assembly is no longer needed for the efficient operation, and
in fact is slower than what the compiler is doing.  So, libsecp has these
performance improvements.

_Bitcoin Core #28349_

Moving on to Notable code and documentation changes.  Bitcoin Core #28349,
beginning requiring the use of C++20-compatible compilers, which allows future
PRs to use those C++20 features.  And the PR description states, "C++20 allows
to write safer code, because it allows to enforce more stuff at compile time".
Murch, you may have many more insights to that than I do.  It sounds like this
is a good improvement that will help.  I don't know the details of things that
will be caught at compile time that currently aren't.  I don't know if you have
a comment on that or insight there.

**Mark Erhardt**: I'm certainly not among the best C++ experts among the Bitcoin
Core contributors, but one thing that I've heard is that C++20 enables modules,
and modules may enable us to have a slightly faster compile time for Bitcoin
Core in the long run when we get that.  But that would be lovely because every
time you build Bitcoin Core to run the tests again with your new changes, if
that were a little faster, that would be super-cool.

_Core Lightning #6957_

**Mike Schmidt**: Core Lightning #6957.  So, in LN, you have this
min_final_cltv_expiry value, which specifies the max number of blocks that a
receiver has in order to claim a payment.  BOLT2 of the LN spec suggests this
value to be a default of 18, but LND is using a value of 9, about half of that.
9 is lower than what CLN will accept by default, so there were some issues
there, and CLN now includes a field specifically requesting that cltv_expiry to
be 18, which mitigates the issue and is part of that Core Lightning 23.11.2
release that we mentioned earlier.

_Core Lightning #6869_

Another Core Lightning PR, #6869, updating the RPC listchannels to no longer
include unannounced or private channels.  And the PR noted, "It turns out that
we relied on private gossip in many places, particularly in our tests".  So, if
you're looking to list unannounced or private channels, there's a different RPC
called listpeerchannels, which will provide that information for users or
developers who need that.

_Eclair #2796_

Eclair #2796 updates its dependency on a particular logging library called
logback-classic, which had a CVE bug.  The PR noted that, "While Eclair isn't
affected since we don't use logback receivers, but if there are applications or
plugins that depend on Eclair and its use of logback receivers, it's better to
use the logback version containing the fix".  So, proactive, defensive move by
the Eclair team of a potential issue.

_Eclair #_2787

_Eclair #2787, _upgrading its support of header retrieval from the
BitcoinHeaders.net service to the latest API.  BitcoinHeaders.net is a service
for providing another source of Bitcoin blockchain data.  It uses DNS to provide
that information.  It supports full Bitcoin headers or neutrino filter headers,
and that service updated to a new version 2 and Eclair is now using that newer
version for its additional source of header data.  Murch, I'm curious, have you
ever heard of BitcoinHeaders.net before; I don't think I have?

**Mark Erhardt**: I have not.  This is a first for me, to be honest.  I guess
it's an improvement over people being able to download the full blockchain from
websites.

_LDK #2781 and #2688_

**Mike Schmidt**: LDK #2781 and LDK #2688.  We've covered LDK and other
implementations' work towards offers, including blinded hops and blinded
payments, and I think last LDK that we covered, related PR, was just a
single-hop blinded payment, whereas these two PRs update that support for
sending and receiving now multi-hop blinded payments, as well as complying with
the requirements from the offers protocol that there's always at least one
blinded hop.  We did a recap of 2023 at the end of last year, and we talked a
lot about onion messages, blinded paths, and offers.  So if you're curious about
that stack of technology, jump back to that.  We had some fun at the end of the
year, and also hopefully some of that is educational for folks on this
particular topic.

_LDK #2723_

LDK 2723, adding support for sending onion messages using direct connections.
And as part of the writeup this week, we included an example where a sender
can't find a pass to the receiver, but knows the receiver's network address, for
example like IP address.  So, the sender can actually open up a direct peer
connection to that receiver and send onion messages, which would allow onion
messages to work well, even if it's not highly supported on the network, which
is the case today.

_BIPs #1504_

And final PR this week, if anybody has a burning question or comment, last
chance to request speaker access or comment in the tweet thread.  This PR is to
the BIPs repository #1504, and it updates BIP2 to allow any BIP to be written in
Markdown.  Previously, everything had to be written in the Mediawiki markup, so
somewhat of a meta/plumbing change, but now you can write your BIPs in Markdown
instead of just Mediawiki markup.

**Mark Erhardt**: I'm sure that's going to vastly increase the BIPs being
suggested, not!

**Mike Schmidt**: Yes, maybe there's a slew of new covenant proposals that were
just waiting to be written in Markdown only.

**Mark Erhardt**: Well, maybe the 13th, we'll finally manage to combine all the
things people want out of introspection and also be palatable to everyone and
super-simple.

**Mike Schmidt**: Checking our comments.  Abubakar, sorry, I missed your
question to Antoine, sorry about that.  I don't think there's anything else that
we should address from the comments for this podcast, another over
one-and-a-half hours of great Bitcoin technical content.  Thanks to all of our
special guests for taking time to join us and discuss their proposals, ideas,
projects, proof of concepts.  Thanks always to my co-host Murch, and thank you
all for listening.  See you next week.

**Mark Erhardt**: Thanks and Happy New Year.

**Mike Schmidt**: Cheers, you too.

{% include references.md %}
