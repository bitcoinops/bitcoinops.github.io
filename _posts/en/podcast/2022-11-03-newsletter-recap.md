---
title: 'Bitcoin Optech Newsletter #224 Recap Podcast'
permalink: /en/podcast/2022/11/03/
reference: /en/newsletters/2022/11/02/
name: 2022-11-03-recap
slug: 2022-11-03-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Bastien Teinturier and Joost Jager to discuss [Newsletter #224]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-7/346123728-22050-1-90d8a780fb771.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to the Optech Newsletter #224 Recap Twitter
Space.  I'll introduce myself, Mike Schmidt, contributor to Optech and also
Executive Director at Brink, where we fund open-source Bitcoin developers.
Murch?

**Mark Erhardt**: Hi, I'm Murch.  I work on Bitcoin-y stuff, mostly explaining
it and sometimes even writing code.

**Mike Schmidt**: Joost, am I pronouncing your name right?

**Joost Jager**: Yeah, my name is Joost.  So, yeah, I'm a Lightning developer,
mostly working on LND and related spec issues.

**Mike Schmidt**: T-bast, do you want to introduce yourself for the group?

**Bastien Teinturier**: Hi, I'm Bastien.  I'm working on the Lightning
specification and one of its implementations, Eclair, and also on the Phoenix
mobile wallet.

**Mike Schmidt**: Excellent, well thank you both for joining us today.  I know
there's a couple of news items that you guys both had ideas and posts around, so
it would be good to hear straight from the horse's mouth what you guys are
thinking.  We'll just go in order of the newsletter, but first a couple of
announcements.  This is in the newsletter a bit later, but you should be, if you
haven't already, considering upgrading LND, your BTCD node, LDK, any Rust
Bitcoin, pre-0.28.2, and I believe Electrs as well.  Yeah, Murch, you want to
comment?

**Mark Erhardt**: Yeah, I just wanted to say, yes, do upgrade your Lightning
software.  But if you have questions and comments, we will be taking those in
the last ten minutes or so of our Spaces.  Please hold your questions until
then.

**Mike Schmidt**: Yeah, that sounds good.  And I think we can maybe get into why
you should upgrade all that in a bit.  I think folks are probably already
familiar with some of the chatter on Twitter about this, but we can kind of jump
into that in the software release section, get into some of the nitty-gritty
there of what broke with these particular pieces of software and why.  One more
quick announcement.  I didn't mention this in our last couple of Twitter spaces,
but in terms of conferences, BTC++, Lisa and crew, are putting on in Mexico City
an onchain privacy conference, and that's just a little over a month from now,
December 9 through 11.  So, if you're interested in onchain privacy, you should
look into that.  BTC++ is the Twitter handle and you can search for CDMX for
that particular conference.

**Mark Erhardt**: Did you just say December 9?

**Mike Schmidt**: I think so.

**Mark Erhardt**: I thought it was on the 2nd; we should verify that.  Oh, no, I
may have seen something incorrect.  So, I guess we can google that while we're
chatting here and correct ourselves.  All right, let's jump into the newsletter.

_Mempool consistency_

Mempool consistency.  So, I think we've had a few weeks of discussing this, but
I think it might be prudent to frame the discussion slightly, and then we can
jump into AJ's post on the mailing list.  So as a quick overview, for the last
number of years, you've been able to fee bump a transaction using RBF and you
have to opt in and signal that you are maybe going to replace that transaction.
Currently, you can't just do that with any transaction, and that's been the case
for several years.  There's now an option that has been added, and that's the
mempoolfullrbf option, and that's currently slated to go in 24.0.  It's default
off, but it allows you to turn on relaying transaction replacements that are not
signaling.  So, assuming a somewhat large percentage of the network enables that
option, in theory you would not need to signal that you're going to replace or
might replace a transaction; you can replace any transaction.  And so there's
been a bunch of chatter.  You can see previous newsletters and previous Optech
recaps that we've done with discussion on this, especially last week, a bit of a
debate on this topic.

AJ started a discussion on the mailing list a bit more philosophical about this
sort of approach.  And he starts off by going through a bunch of different ways
that currently you can modify policy in different ways, especially mempool
policy.  He sort of extrapolates those different ways that you can tinker with
your own mempool policy on your own node.  As we know, there is no "the"
mempool; everybody has different mempools on their node based on latency and
other small settings that can be tweaked.  But he's sort of framing that in a
way that when we're talking about this mempoolfullrbf, he sees a bit of a
philosophical divergence in adding to that option as a default off, versus
having it as a default on, and he gets into some potential ramifications of if
there's a philosophical change in Bitcoin Core, what are some considerations
moving forward with that sort of a philosophy.

We can jump into some of his considerations, but I just wanted to pause there to
see, Murch, if you wanted to help frame that discussion any more before we jump
into some of the points that he made in his mailing list post.

**Mark Erhardt**: I thought that that was a pretty cogent email, and I also
especially liked Suhas' response to it.  I've changed my own position on the
discussion a bit since.  So originally, I was very much in favor of moving to a
full-RBF regime, where basically any transaction is treated as replaceable at
all times.  But especially, Suhas made the point to me that it's not entirely
clear what benefit we have, except for being able to better steal from
businesses that rely on zero-conf by turning on full-RBF.  And we are currently
working on a separate proposal, v3 transactions, to facilitate a specific use
case on the network and have separate relay policy for that.  And if that is a
valid use case, and we would argue that it should be used as intended, then we
could make a similar case for being able to opt out of replaceability.

So, I think that the debate has actually gotten a lot better in quality.  I'm
not sure if it's trivial to summarize all the nuances correctly right now, but
check out our newsletter and if you want, also the mailing list directly, and
there's three or four PRs on Bitcoin Core by now that have different ideas on
how to diverge from this situation.  So, yeah, there's a lot going on.  I think
we already have basically a draft for the next week update on the matter because
the discussion is already moving on.

**Mike Schmidt**: Now, you mentioned you changed your mind in response to Suhas'
response to AJ's post, and you sort of outlined a bit what that is.  But in
summary, he pointed out that one of the benefits of enabling mempoolfullrbf was
not maybe fully thought through or it's not a total fix, that there's still some
edge cases that can still allow for that particular attack, if you will.  Is
that what convinced you, that it doesn't completely solve that use case?

**Mark Erhardt**: Yeah, I think that the benefits of introducing full-RBF were
overstated previously.  So, the main disputant that was saying that full-RBF
fixes important things was Antoine.  And he basically said, there are situations
when you craft a multiparty transaction where the existence of transactions that
signal finality can get other participants in the multiparty transaction stuck,
so that they have basically a transaction that is signed that they can't take
back, that they have put into their own mempool, but that doesn't propagate
because a conflicting transaction has already been broadcast to the network.
And I don't think that is super-convincing at this point anymore, because
essentially you're saying you're going to have a bad time if you're trying to
craft a multiparty transaction with a user that actually is trying to sabotage
you.  And they have so many different ways of sabotaging the multiparty protocol
that this particular need of you having to flush a transaction that didn't make
it to the network from your mempool just isn't that huge of a benefit.

**Mike Schmidt**: Okay, thanks for elaborating on that.  I know, yeah, that the
next newsletter already has some content around this and there has been some
discussion since this current newsletter was drafted.  I think maybe it is just
worth noting some points from AJ's post even outside of this particular
mempool-related option with full-RBF.  I wanted to get your thoughts on his
points around allowing optional features surrounding the mempool, and potential
downsides with allowing a high degree of customizability, in terms of mempool
policy.  He points out a few different points that could be concerning in
allowing folks to do that.

His first point, or one point is, at least that we highlighted in the
newsletter, is that if more options are better, then there's a lot more options
that could theoretically be added, which segues --

**Mark Erhardt**: Yeah!  So, the whole point of the mempool is that there is not
a single mempool, but there are many mempools.  Every node has their own mempool
and we cannot guarantee that the content across all of the nodes' mempools is
consistent.  That's why we need a blockchain in the first place, because we need
to find a way to canonically order transactions on the network.  So, we cannot
make any promises about every node having the same mempool, that's silly.

But the idea is we want the mempools to overlap as much as possible, because if
mempools overlap then the transactions that we're expecting to go into the block
are actually being mined by miners and the block propagation gets faster,
because what the miners send to the network can be forwarded with compact
blocks.  So, also we don't want all these balkanized little networks that have
different mempool policies and different mempools, where then every minor needs
to connect to each of them to get the whole picture, because that will make it
just so much harder for new mining entrants to become competitive.  We want to
de-mempool, or every node's mempool to overlap with other nodes' mempools as
much as possible.  So actually, more options is bad.

**Mike Schmidt**: Yeah, I think you touched on a couple of his points, which is,
yes, having a variety of different mempool policies is going to require either
more broad support for those policies on the network or this notion of
preferential peering, where you sort of end up with, as you said, these sort of
balkanized sections of the network, where I'm only talking to peers that support
XYZ feature or policy, and that can be bad for the network for a variety of
reasons.  And then you also mentioned, if you end up in that situation, then
Bitcoin miners need to support, in some capacity, trying to peer into all these
different subnetworks or balkanized networks in order to find transactions that
are most profitable to mine.  And if that's happening in a bunch of different
subnetworks, or in the example I think AJ gave of relaying things along the
Lightning Gossip Network, then now you're adding a bunch of overhead to miners
and that would point towards bigger miners being able to do that versus smaller
miners, since you're adding a bunch of overhead to the mining process, and
that's bad for decentralization.

**Mark Erhardt**: Yeah, you will introduce a centralization issue, and actually
we have a live example of how that is terrible.  If we just look at Ethereum
right now with the whole MEV debate, they essentially have privatized mempools,
and that's not a slippery slope we want to get on.

**Mike Schmidt**: Yeah, I thought it was a good discussion.  It was a good post
to run through, so I highly recommend if folks have read the newsletter, but
haven't jumped into the original mailing list post and some of the responses,
that it would be advantageous for you to do so.  Anything else on mempool
consistency, Murch?

**Mark Erhardt**: Just one more thought.  That is, I think that at this point, I
would not be sure when to recommend to a miner to turn it on.  Right now, I
don't think I would recommend to a miner to turn on mempoolfullrbf.  I would
only recommend that if it were already the status quo on the network, or there
were at least a few miners that are doing it.  If a few miners start doing it, I
think that we should have the option very quickly out in Bitcoin Core and allow
nodes to see exactly what is going on on the network, and then I would also
recommend to all miners to turn it on.  But just because I think that once the
unstable equilibrium falls, I don't think that we should be the first one to
throw a stone at that glasshouse.

It seems to be stable right now, it seems to be useful to a few businesses that
have quite elaborately discussed with us why they are using it and how they're
mitigating their risks and all that.  So, if it's stable and it seems to be
useful to people and there's little benefit of activating it right now, then
it's just not clear to me why we should be releasing it.  So, at this point I'm
thinking that we should remove it from 24.  T-bast, you might also have thoughts
on mempool, or Joost.  Does one of you want to chime in?

**Bastien Teinturier**: I don't have a really strong opinion right now.  Before
we introduced v3, I had a very strong opinion that we needed to do full-RBF.
But now that there is work on v3, transaction v3, that will kind of fix the RBF
issues we have for eltoo contracts, I'm not so sure we actually need to activate
full-RBF.  So, I think I'm a bit like you and change my mind because of recent
development.

**Mike Schmidt**: Joost, any thoughts?

**Joost Jager**: No, not really.  I don't really have a strong opinion on this.
Just that's like incentive compatibility, that would be my initial thought, that
if there's more fees to be earned, it's probably going to happen anyway, one way
or the other.  But obviously there's a lot more nuance to it in these recent
discussions.

**Mike Schmidt**: And we will have more of this ongoing discussion, I presume,
in future newsletters.  So, I think that's probably good to leave it there for
today.

_BIP324 message identifiers_

The next item in the newsletter is a discussion from Pieter Wuille about BIP324,
message identifiers.  We talked a bit about BIP324 in a previous newsletter, but
essentially it's a design for allowing nodes to communicate encrypted instead of
using plain text, and there's a bunch of advantages to doing that, which we've
got into previously.  But this particular discussion that Pieter's brought up is
that as a part of that change, the BIP also proposes optimizing the existing P2P
message command strings.

Currently, those command strings are fixed-length 12-byte ASCII strings, and
they need to be 12 bytes, so even if it's a shorter message, you pad it with a
bunch of null bytes.  So, these messages that you're sending around the P2P
Network all have these 12-byte identifiers, called command strings.  And it's
probably way overkill for it to be in 12 bytes.  And so, as part of BIP324's
design, they've decided to try to optimize that a bit by mapping this 12-byte
command string into a 1-byte message type ID.  And so the discussion that Pieter
brings up on the mailing list is when you're mapping a 12-byte string into a
1-byte ID, you obviously have less space for those different types of messages.
And the mailing list post outlines how that mapping from 1-byte message types to
the original command strings could be done, and there's four different ideas
that he throws out to the mailing list that they're unsure and are seeking
feedback on how to do that mapping.  Murch, did you have thoughts on these
message identifiers?

**Mark Erhardt**: Not too many.  I think that the first that he describes just
seems reasonable to me.  So, there's no reason why we should use 12 bytes.  I
think there's about 27 message types right now on the network.  One byte allows
us to express 256 values, so being able to grow 10X seems like a lot of
headroom, and we don't really need to have much more.  And if so, I think that
we could probably build in some extensibility by just reserving, say, 0xFF, the
maximum value of 255, and saying, "All right, if this comes first, then we'll do
something else later, and we'll tell you what it is later".

Anyway, it seems reasonable to have a 1-byte message and save 11 bytes on every
message on the network.

**Mike Schmidt**: Yeah, it seems like a good improvement to put in, along with
the work that they're doing on encrypting communications.

_LN routing failure attribution_

All right, LN routing failure attribution.  And so, we have one of our guests
today, Joost, who proposed a version of this solution quite a long time ago,
which is now updated.  And so, Joost, do you want to provide a quick motivation
for what is the problem that you're trying to solve, and then maybe get into the
proposed solution you have here?

**Joost Jager**: Yeah, definitely.  So, within Lightning, payments can fail.
And if a payment fails, it's really important for the sender to know where it
failed.  Because suppose you've got a route consisting of 10 hops and there's a
failure, you need to know which part of that route you want to avoid for the
next attempt.  And if you don't know where it failed, what will your next
attempt look like?  Like, are you going to avoid all of those nodes?  Maybe then
you will quickly run out of nodes on the network; or maybe you can try to
triangulate where the error is.  It's just quite difficult to do.  And
fortunately, within Lightning, there is in the protocol the possibility to
identify the source of an error.

The only problem is there that you need cooperation from all the nodes on the
path to actually be able to decode that.  So, if a node generates a failure,
this failure is relayed back to the sender, but any of those nodes along the
path, including the origin of the failure, can corrupt that failure message, and
then the sender has no information at all on where things went wrong.  And then,
depending on which Lightning implementation you are running, your behavior
varies between analyzing all the nodes on the path, this is what LND does; I
think Core Lightning (CLN) penalizes none of the nodes on the path; in Eclair, I
believe, Bastien can correct me there, we are penalizing nodes, but only for
this particular payment.  So, for the next payment, every node is available
again.  But in general, there's not really a good way to deal with that if you
don't know where the failure happens.

The proposal attempts to fix that by creating a chain of Hash-based Method
Authentication Codes (HMACs), where each node on the path adds its own HMAC to
the failure message so that if one of the nodes modified the failure message
somehow along the path, the sender is able to point out that node and apply the
appropriate penalty there.  So, that's roughly the idea there.

**Mike Schmidt**: And it applies to failures as well as, I guess, looped in
there would be delays as well, right?

**Joost Jager**: Yeah, that's a good thing indeed, I guess, garbling failures,
but it's also that it knows just the delay along the path.  So, they just relay
the failure message back, okay, but they insert a delay there.  And for the
sender, they just see when they send out the Hash Time Locked Contract (HTLC)
and when they receive the resolution, but they don't know how the time is
attributed between all the nodes on the path in between those two points.  So,
in this proposal, I also tried to address that by letting each node, not just
add an HMAC, but add a timestamp as well when they received the HTLC and passed
back the resolution, so that the sender can also use that information to point
out slow nodes.  And I think even if a node is not maliciously doing this, it's
still interesting because if you are a payment system and you want to compete
with card payments, it needs to be really fast, and you also want to penalize
notes that are just too slow.  So, even if there's no malicious intent there, if
the node has a slow internet connection, it's great if you can detect that and
then avoid that node.

**Mike Schmidt**: It sounds like a great feature.  What are the downsides to
implementing something like this; what are the drawbacks?

**Joost Jager**: Yeah, so the main challenge really is the fixed size of the
failure message.  So, in order to not give away the position of all the nodes in
the path to the routing nodes, the failure message always has the same length,
so they can't infer from the length where they are in the path.  But this also
makes it difficult to add those HMACs because you can't just add HMACs.  If you
would do that, the failure message would grow on the way back, and they could
learn something from the size of the message.  So, some data needs to be
replaced.  So, when a node adds its HMAC and adds its timestamp somewhere,
before that can be done, all that data needs to go.  And this is what makes it
complicated to solve this problem.

Basically, the chosen solution in this proposal is that the node is going to add
a series of HMACs for every possible position that it could have within the
path.  So, if there's like 27 positions possible, each node will add 27 HMACs
for each of the positions that it could have in the path, and only the sender
really knows which position that node actually has.  So, the sender also knows
which of those HMACs they should look at, and the other ones can be discarded.
And this seems to work, at least in my prototypes it works, but the obvious
downside of that is the size of the message, because you are adding this 27
HMACs per hops and you can reduce the total number of HMACs by 50%, but still
you end up with a failure message size of around 12 kB, which is a lot bigger
than what we currently have.  And the question obviously is then whether that's
worth the benefits of being able to always identify the source of an error.

**Mike Schmidt**: So, in order to preserve some of the privacy, you essentially
add some additional data to these messages, and therefore this large message
size is a potential downside.

**Mark Erhardt**: I think the important point here is we get these failure
messages for every single routing attempt we make.  And since we don't know
where the balances are in channels that we haven't interacted with recently, and
whether they'll be able to forward a payment that we're trying to put through
their channel, we will usually get a large number of failures before the payment
succeeds.  And currently, I think that is fairly small, but then now every
single attempt to make a payment would incur these, what, 12 kB of error
message, unless it succeeds.  On the other hand, we will get much better at
routing much more quickly, so maybe the number of failure messages goes down.
Is that about right, Joost?

**Joost Jager**: Yeah, I'm not sure because the data is not public, but the
bigger senders on the network sometimes publicize the statistics, and they
generally have very high success rates, like 89%, 99%, 99.5% success rates.  So,
I would say that failures are just a minority of all the attempts made.
Although, well actually, this is not correct because obviously they're reporting
the eventual success of a payment.  We don't really know how many attempts have
preceded the final successful payment.  So actually, I don't know.  But I do
hope that over time, we go towards a network that is good enough to keep the
number of attempts very low, preferably almost always one, because otherwise,
there's a lot of latency on those payments, and it's not really comparable to
card payments.

**Mark Erhardt**: That's a fair point.  T-bast, since you also work on
Lightning, do you have some thoughts on this?

**Bastien Teinturier**: Yeah, actually I remember that we brainstormed on that
exact issue with Joost in 2019 in Amsterdam, and we weren't able to find a
satisfying solution back then, but we already knew that this was an issue and
something we hopefully wanted to fix.  So, I haven't had time yet to thoroughly
analyze the proposal, but I'm really interested in seeing if it works, because
that's something we definitely want.  I don't have yet an opinion on the size
issue, because if a number of retries and the reliability goes up, maybe it's
okay to have those bigger failures.  I don't know yet, to be honest, but that's
an important feature to add.  And if we have attributable errors, that would be
really a great improvement to Lightning.  So, it's an important thing to work
on.

**Joost Jager**: Yeah, it would also be interesting.  Of course, we have been
thinking about the solution for a long time, as t-bast says.  And now at this
point, I thought, okay, maybe this is the best thing we came up with, so just
let's go ahead and see what happens if we try to implement it, if there's any
other surprises showing up.  But perhaps it's also possible for someone to
provide proof that it's not possible to do this chain of HMACs in a fixed size
message in a compact way.  That would be useful as well, so then we know that we
can stop looking for a better solution.

**Mark Erhardt**: I also saw that there was an alternative proposal by Rusty.
Have you had a chance to think about that a little bit?

**Joost Jager**: Yeah, that's an alternative proposal, but I don't think it
addresses the timing issue.  It's very different from the failure message thing,
it doesn't fix the timing thing with the timestamps.  And also it's, yeah, you
could say it's more invasive because there's actually money involved there.  You
need to forward extra sats that you're not getting back, so it is also a little
bit of a blend with certain anti-DoS mechanisms that have been proposed.  So,
yeah, to me it seems that just changing the encoding, relaying, and decryption
of the failure message is a smaller, more contained change that is probably
easier to agree with, I guess.  But yeah.

**Mark Erhardt**: I think to briefly summarize Rusty's idea, was that you attach
extra sats that get spent to every hop, and that way you would be able to tell
how far the message has propagated, because only once the full HTLC has been
forwarded to the next peer, and they peel back the onion, they see the payment
to them.  So, when you get back a failure, you would see how many of the sats
along the way have been collected, and like a sort of breadcrumb, you know which
one was the last honest host that unpacked it and collected the money.

All right, I think we'll have to follow this proposal and see what other people
think when they've had a good look at it, but that sounds like an interesting
way how we can get routing even more reliable on the Lightning Network.

**Mike Schmidt**: Joost, if you're up for sticking around, we have some other
Lightning-related discussions, but also I think a few of your PRs are covered
later on in the newsletter, if you care to outline those for us.

**Joost Jager**: Yeah, I will be here.

_Anchor outputs workaround_

**Mike Schmidt**: Great.  All right, the next item from the newsletter is titled
Anchor outputs workaround, although I think we did make some change to the
wording here; it's not necessarily a workaround.  But luckily, we have t-bast to
help clarify that for us, and it's his idea that he posted to the Lightning-Dev
mailing list, so I'll let him outline the motivation for this pre-signed
different feerates and maybe outline the motivation, and then get into the
proposed solution.

**Bastien Teinturier**: Sure, thanks.  So, basically what we've changed with
anchor outputs is that we changed the signature hash (sighash) flags we use to
sign the HTLC transaction to use SIGHASH_SINGLE, SIGHASH_ANYONECANPAY and pay
zero fee.  So, the idea is that you will set the fees at broadcast time and
because that transaction right now pays zero fee, you have to add a new input,
you just have to bring a wallet input to be able to make those transactions
confirm.  The issue though is that a channel can have potentially a bit less
than 1,000 pending HTLCs, which means that an attacker can fill your channel
with almost 1,000 HTLC outputs, and then force close the channel, and you have
1,000 transactions that you need to fee bump onchain.  And you cannot easily use
only one input to fee bump to create one transaction that uses all those outputs
because they may not have the same timelocks.  And especially if the attacker is
malicious, and they are, they will make it so that the timelocks used are
different.

So, you will have to use potentially a lot of inputs or at least use a tree of
unconfirmed transactions and unconfirmed inputs to be able to pay the fees for
your HTLC transactions, which is far from trivial and forces you to reserve
UTXOs in your onchain wallet in case something bad happens.  But the issue is
that it's really hard to dimension how bad things could go and how much you
should reserve without sacrificing too much capital that you just keep idle.
So, that is really frustrating because the HTLC output conceptually contains all
the value that you want to claim.  So, ideally, you would just want to decrease
the output to pay the fee.  You should not have to add any new inputs to pay the
fee.  It's just because we don't have a good mechanism to do it correctly that
we have to do this work around.

So, what I'm proposing is a very unsatisfying solution because it's ugly and
inefficient, but is just to instead of only giving a signature for
SIGHASH_SINGLE, SIGHASH_ANYONECANPAY, paying zero fee for the HTLC transaction,
to also give other signatures for each of the HTLC transactions that pay the
transaction at various feerates, so that hopefully when broadcast time comes,
you have one of those signatures that signs the transaction at a feerate that is
okay for inclusion in the next n blocks, for example, and you don't have to use
the SIGHASH_SINGLE, SIGHASH_ANYONECANPAY version.  You still have it in case
none of the pre-signed transactions pay the fee you want to pay, so you still
have everything that you currently have with anchors, but also some redundant
signatures that may alleviate the requirements that you have on your wallet
available UTXOs.

So, it's also especially useful for mobile wallets, who will generally not have
a lot of UTXOs and not want to manage a big pool of UTXOs to protect their
channels.  So, if they already have pre-signed transactions at acceptable
feerates, even if sometimes it overshoots, it's probably better than not having
anything at all.  So, it wastes some bandwidth because you have to send a lot of
redundant signatures and you don't even know if you're going to use them, most
of them you're just going to throw them away, but we didn't find a better
solution; and I don't think that the sighash flags and the utilities that
Bitcoin provides today let us correctly fix that issue.  So, in the future, I
would like to have some sighash magic that makes this whole problem completely
go away more elegantly.  But right now, I'm just looking for a pragmatic,
short-term approach to make sure that we somewhat mitigate this issue on
mainnet.

**Mike Schmidt**: Excellent.  So, instead of, well I guess in addition to the
current anchor output model and having to bring your own inputs in the situation
that you mentioned, and all the overhead and risk mitigation that goes along
with trying to evaluate how many inputs to have on hand, you can still do that,
but in addition to that, you have these pre-signed paying the fee out of the
actual HTLC itself, so that you can free up more capital to doing other things,
including in Lightning channels, as opposed to sitting waiting to potentially
fee bump.

**Bastien Teinturier**: Exactly.  So, for example, you would still have what you
have today, is the HTLC transaction at 0 sats/byte, for which you need to add
new inputs, but you would also have a version at 1 sat/byte, 5 sats/byte, 20
sats/byte, and maybe one at 40 sats/byte, something like that.  And among all of
those, at broadcast time, you would choose which one you broadcast.  Or, if you
want to use the 0 sats/byte one and add inputs because you have available inputs
in your wallet, you would do that.  But it gives you more options at broadcast
time to make sure that you get your HTLCs back onchain.

**Mike Schmidt**: I know one thing that you were looking for out of this mailing
list post was to get support from other Lightning implementations, other
Lightning developers on the idea.  So, how has that feedback gone; are folks
supportive; is it too early to tell; are there concerns that folks have brought
up?

**Bastien Teinturier**: I think it's too early to tell, but I'm happy because I
was looking for -- I kept the proposal quite high level because there are a lot
of details where we can do things in many different ways.  We can tweak that in
many different ways and that's quite a big design space once we open the door to
potentially signing multiple feerates for every commitment.  And I've already
got good feedback from Matt and from the Electrum guys, because obviously the
Electrum guys are interested in that as well because they don't want mobile
wallet users to have to reserve a pool of UTXOs, but they still want to benefit
from anchor outputs.  So, there's been some discussion.

There's been already some discussions around the different ways we could do that
and it's interesting, but I'm still waiting for more feedback, more ideas, what
trade-offs people find acceptable or not, and I'm not sure I have yet a good
answer on whether the high-level idea would be desirable or not.  So, the
discussion is still ongoing for that and we'll see in the next couple of weeks
if it makes progress.  But I think we're still going to go ahead and implement
it in Eclair, and maybe experiment with it in Phoenix to see how it works
end-to-end, and what potential issues may arise, and that will give us
real-world feedback to bring back to the discussion.

**Mark Erhardt**: I especially like with this proposal that it would also be
more block space efficient, because the transaction doesn't need to have a
second follow-up transaction that spends the anchor output.  I was just
wondering, because it's on my mind this week, I assume that all of these
transactions would be signaling replaceability, so even if you first choose to
use the transaction at 20 sats/vbyte, and then it sits around for a while and
you want to bump it, you could use the 40 after that, and then potentially even
broadcast the 0 anchor output one to make a 60 sat/vbyte transaction if the 40
one doesn't go through either, once we get package relay.  Is that about right?

**Bastien Teinturier**: Yes, that's exactly it.

**Mark Erhardt**: It's a little hacky, but sounds pretty good to me.  I also
find it kind of funny that both of you have found solutions to some Lightning
issues by just adding more bandwidth requirement to it!

**Joost Jager**: I was just about to say the same thing, like I've got the fat
errors and now Bastien has the fat commitments, so yeah!

**Bastien Teinturier**: Yeah, we have bandwidth, let's use it!

**Joost Jager**: 2022, we don't need to do 8-bits anymore.

**Mike Schmidt**: Well, thanks t-bas, for outlining that for us.  If anybody has
questions, feel free to raise your hand towards the end of the discussion and we
can answer any of those or any comments that you may have.

_LND 0.15.4-beta and 0.14.4-beta_

Moving on to Releases and release candidates, we talked about this in the
announcements portion earlier in this discussion, but the LND security releases
that contain the bug fix for processing recent blocks, some detail around that,
the emergency hot fix.  So, there was a BTCD among other, I think Electrs and
Rust Bitcoin were unable to parse certain transactions that have a large number
of witness inputs.  And I believe it was Burak that made a P2TR spend that had
an OP_SUCCESS opcode, and it included 500,001 empty pushes, which caused a
consensus conflict between BTCD and Bitcoin Core.  The fix there is to change
the max witness items from 500,000 to the correct number, which is 4 million,
and that that solved the issue.

One interesting thing about this transaction was that in an OP_RETURN message,
it somewhat made clear that the transaction was crafted to break LND, as I think
it said something like, "You will use CLN and you will be happy".  And one other
interesting thing about the transaction is I believe that it needed cooperation
from a miner to exploit.  So, that was another interesting piece.  Murch, have
you been following this?

**Mark Erhardt**: I think it was non-standard in three ways.  It used
OP_SUCCESS, the witness item count was non-standard, and it used 125,000 vbytes,
where standard transactions may only use up to 100,000.  I have since learned
that the creator of the transaction does actually not work at Blockstream, which
I thought, because I saw him speak at conferences about very Blockstream-y
topics, such as Simplicity and Liquid.  But also I thought, just to be fair,
that Christian Decker of the CLN team has disavowed of any sponsoring of this
sort of behavior on the network, because it was widely regarded as, at least
slightly, irresponsible.

**Mike Schmidt**: I think that, yeah, it was a large transaction.  I think I saw
something like $750 in fees.  Is that right?  Yeah, something like that.  I
think that is, let me think, so the transaction was 125,000 vbytes, so that's
1.25 millibitcoin if you pay 1 sat/vbyte, so he must have paid something like 5
sats/vbyte or so; is that right?  Oh wait, no, $700, not 700...  Okay, I'm not
going to do this calculation right now.  But yeah, he paid something like $700
for it.

**Mike Schmidt**: So, I guess in summary, make sure you're updated to the latest
version of LND, BTCD, and these potentially other affected softwares, like LDK;
I think I read it was 0.28.2.  Anything before that is vulnerable, and I think
I've seen that Electrs is also vulnerable.  I'm not sure which versions of
Electrs.

**Mark Erhardt**: Yeah, it's funny.  It actually broke the Liquid peg as well!

_Bitcoin Core 24.0 RC2_

**Mike Schmidt**: I missed that!  Okay, that's funny.  The other release we had
listed in the newsletter this week was one we've had for the last few weeks,
which is Bitcoin core 24.0 RC2.  There's a nice testing guide that --

**Mark Erhardt**: RC3 was out yesterday night.  Bastien?

**Bastien Teinturier**: Yeah, I'd like to chime in on the issue of BTCD bug, I
must admit that we were implementing taproot in our own library and we were
wondering why Bitcoin Core doesn't have exhaustive tests on all the limits,
because it sounds like they are not that hard to build; to create a test for all
the limits wouldn't require too many test cases and they can be generated
semi-automatically.  And if we had that in the standard test vectors, that would
ensure that anyone implementing a library that parses and validates a
transaction would not run into those issues.  So, do you guys have any idea on
why that has never been done in bitcoind?

**Mark Erhardt**: I am not sure that's true.  So, I think that at least for the
previous -- so there was another non-standard transaction a few weeks ago that
also broke LND.  And the problem there was -- or actually that was standard, but
problematic.  The test cases in Bitcoin Core and the test vectors included a
test for that, but LND passed the test on the transaction level, it did not pass
the test at the block parsing level, which is sort of like all the things that
can happen to transactions are also tested in custom-built blocks that include
all the special behaviors, and I think that's the test cases that are missing.
So, the test vectors for transactions were fine, and I think also passed for
this transaction.

**Bastien Teinturier**: Okay, interesting, because while we were implementing
taproot in our library, we realized that we actually had a bug or something
unrelated where we didn't count an operation wait on one opcode, I think, one
very not often used opcode, but still that made it so that we actually accepting
transactions that would use one more of these opcodes than standardness would
allow.  And we just grabbed the test vectors from bitcoind and there was no test
vector for that, so we had to generate more, and we were surprised that the test
vectors were not exhaustive on the standardness checks.

**Mark Erhardt**: Oh, thanks, I stand corrected.  But okay, so what Bitcoin Core
does as well is fuzz testing, and fuzz testing does a lot of this sort of limit
exploration automatically, because it just generates all possible values and
plugs them into tests.  And I think for fuzz testing, we don't have vectors
directly, but whenever we do find failures, we create vectors from it.  So, I'm
not sure if there's fuzz testing for block parsing yet.  Maybe that would be
something that we could get someone to work on and then create a set of test
vectors from the results with.  But thanks for pointing out that the tests are
not exhaustive.

**Bastien Teinturier**: Yeah, so ideally, any implementation that wants to
reimplement something like script validation and standardness rules, we need to
also rely on their own fuzzing that mimics what bitcoind does to ensure that
they catch potential standardness issues, right?

**Mark Erhardt**: That would be lovely if everybody did that.  I mean, if you
just sort of generate all sorts of random behaviors and see that your software
reacts exactly the same to it as Bitcoin Core, that would ensure or help that
you are bug-for-bug compatible.  So, maybe just take a whole step back here.
One of the problems is that there is no specification for Bitcoin because it's a
fairly complicated protocol.  So, de facto, the dominant network behavior is
established by the dominant client on the network, which is Bitcoin Core.  And
Bitcoin Core, therefore, is sort of the spec.  And that means that if there is a
bug in Bitcoin Core that has behavior that wasn't intended, but is de facto the
behavior on the network, other implementations have to not implement the
intended behavior, but have to implement the buggy behavior to match the
behavior of Bitcoin Core.  So, that's the issue you run into when you're trying
to write your own parser for Bitcoin blocks and transactions; you have to match
the behavior of Bitcoin.

In this specific case, it was a gratuitous additional limit in the wire library,
I think, of, what is it, BTCD, and that was just incorrect.  The limit was much
lower than what was allowed on the network, and that caused it to fail a block
that was allowed.  And that's how we got to the situation where LND just got
stuck on a certain block height.

**Mike Schmidt**: Bitcoin Core RC2 for 24.0 is actually RC3 apparently, as of
last night.  I know we have a "guide to testing" link here.  Murch, I don't know
if you have any comments you'd like to make on RC3 and what maybe changed there
that could use some additional testing?

**Mark Erhardt**: Sorry, I'm not completely up to date.  I know that there were
a couple bugs found, just things that hadn't been tested fully or that were like
a new feature didn't work in special cases, like preset inputs or with hardware
wallets, so there were some small fixes in that regard.  Obviously, we're long
beyond adding new features, and I think that we more or less certainly will have
an RC4.  So, depending on where the whole mempoolfullrbf debate goes, that might
also be an item on the next release candidate, so that it gets rolled back if
that happens.

_Bitcoin Core #23927_

**Mike Schmidt**: Great.  Under our PR section for this week's newsletter, this
first one is Bitcoin Core #23927 and, Murch, I think you did the writeup for
this PR.  Do you want to provide an overview of what was changed here?

**Mark Erhardt**: Sure.  So, Bitcoin Core allows you to get a block from peer
while you're still synchronizing.  And when you do that, it skips ahead and just
gets a block that you tell it to hash from, from one of its peers.  When Bitcoin
Core downloads blocks, it just stores them in big files that hold block data for
its blockchain database, and these files go up to 130 MB.  So, if you request a
block explicitly and add it to your blockchain database, it just sits there, and
we keep everything in exactly the order we downloaded it, not in the order of
the height.

So, an interaction with pruned nodes here is, if you do this while you're
running a pruned node, you would usually throw away these blockchain database
files after you have sufficiently progressed beyond a file.  But if you have one
of those blocks that have a much higher height in it, you can't throw it away
because the Bitcoin Core node hasn't synchronized past that height yet.  So, it
sees that the blockchain database file still has data it hasn't processed for
the synchronization and keeps the block.  And that actually breaks pruning
because if you, say, limit your pruning to a very small amount, say 500 MB, 550
MB, the limit, and then you get a bunch of blocks from peers for future heights
and thus pollute your blockchain database files with high-height blocks, then
you stop being able to throw them away and you run out of block space.

So, what this bug fix does is when you're running pruning, it disallows you from
getting blocks from peers that are higher height than the current
synchronization.  It only allows you to get blocks from lower heights, which is
still useful because once you've pruned and you don't have that block anymore
and you want to get it back, you might just want to get it back.  And that's
what it allows you to do in the first place.

_Bitcoin Core #25957_

**Mike Schmidt**: Great summary.  Thanks, Murch.  The next PR this week was
Bitcoin Core as well, #25957, which, "Improves the performance of rescans for
descriptor wallets by using the block filter index".  This is, I guess, similar
to one we covered a couple of weeks ago that added the scanblocks RPC that
identified blocks in a given range for a provided set of descriptors, and that
was an RPC call.  And this one similarly uses BIP157 if you're using a
descriptor wallet and you need to do a wallet rescan, and instead of going
through all of those blocks and looking for transactions, it's actually using
the filter, and then there's some great performance gains that are done by using
that block filter instead of going through every block.  So, performance
improvement here if you're using descriptor wallet and you need to do a wallet
rescan.

**Mark Erhardt**: Yeah, this is just faster because if you have tables of
contents for each block already, you can just look at, "Hey, is there anything
relevant in this block?" instead of going through this full block.  And yeah, so
that's where the, whatever, 10X or even faster improvement comes from, ie just
scan the table of contents instead of the whole blocks for what blocks are
relevant when you're rescanning.

_Bitcoin Core #23578_

**Mike Schmidt**: Next PR on the list is also a Bitcoin Core PR, #23578.  And
that is a change that allows external signing support for taproot keypath
spends, not scriptpath but keypath spends, and that's due to the latest HWI as
well as recently merged support for BIP371, which includes additional taproot
fields to PSBTs.  So, now that you have these additional fields in the PSBTs to
support taproot and HWI supports it, you can now do an external signing device
for your taproot keypath spend.  So, that's great for the hardware wallet users
out there.  Murch, any thoughts on that one?

**Mark Erhardt**: So, from what I understand, with the newer Trezors and
Ledgers, you can now use taproot keypath spins where the Ledger or Trezor is the
actual signing device for a descriptor that lives on your computer.

_Core Lightning #5646_

**Mike Schmidt**: Next PR here is Core Lightning #5646, and there's a few
different things in here.  Their implementation of offers removes x-only pubkeys
and uses compressed pubkeys.  And it also implements forwarding of blinded
payments, but not yet generating and paying invoices with blinded payments.  I
didn't dive too deep into this one, but Murch, do you have any thoughts on that?

**Mark Erhardt**: Let's throw it to the Lightning desk!  T-bast, you know
something about this?

**Bastien Teinturier**: Yes, so basically blinded payments, blinded paths, onion
messages, and offers are three features that stack on top of each other.  Offers
depend on onion messages, and onion messages depend on blinded paths.  So, we've
been able to make a lot of progress on those.  We have almost finished
implementing blinded paths and blinded payments in Eclair and CLN.  So, we
should be able to have an interop test, I hope, in the next weeks or months.
Onion messages has already been interop tested between Eclair and LDK, and I
think with CLN as well.  And recently, Rusty made a lot of changes to offers to
take into account a lot of feedback that had been added over the last six
months, I guess.

So, we are making progress on all of those PRs.  It's really a long feature.
It's been a while since we started working on those, but they are making
progress and they will eventually land in the next, hopefully, month.

**Mark Erhardt**: Super-cool.  So, specifically about x-only public key, this
only refers to the usage on the wire for Lightning, right; or does this also
bleed over into onchain use of how Lightning uses it?

**Bastien Teinturier**: No, I think it's only for the signatures of wire content
of offers.  The offers are not signed, but the invoices are signed.  At first,
Rusty started using x-only pubkeys, but it was a while ago.  I think the first
version when he introduced that was more than a year ago.  More recently,
everyone realized that x-only pubkeys create potentially a lot of issues for
protocols that build on top.  So, we moved away from them and went back to
compressed pubkeys because we actually didn't really need to use x-only pubkeys.
It's not worth saving one byte for messages that are sent on the wire and that
are ephemeral.  It's not like we store them in a blockchain or something.  So,
it really was a premature optimization that was unnecessary, and that's why it
was reverted.

**Mark Erhardt**: Super, thanks.

**Mike Schmidt**: All right, we have three LND PRs here, two of which are
authored by Joost.  So, Joost, do you have the newsletter up in front of you to
follow along here?

**Joost Jager**: Yeah, I've got it.

**Mike Schmidt**: Okay, great.  Well, I'll let you maybe provide summaries of
each of these three since you're the author of two of them and involved with the
other.  So, go for it.

_LND #6517_

**Joost Jager**: Yeah.  So, the first PR is a so-called final settle signal.
So, in LND, there's an API to query the state of your invoices, and at some
point an invoice moves to where the state is settled.  And this suggests that
you're safe, that you've got the money, nothing can happen anymore besides the
online requirement that you always have in Lightning that you need to keep
watching your channels, but you can use a watchtower for that.  But it doesn't
actually work like that.  If LND reports an invoice as being settled, it
actually only means that settle has been requested.  So, the HTLCs have been
accepted by LND and then we request it to settle them, but it may not have
happened yet.  In most of the cases, it has happened already, but it doesn't
necessarily need to have happened at that point.

It does mean that if at that point you bring down your node for an extended
period of time, it might be so that HTLC isn't successfully claimed by your
node.  At some point, you exceed the HTLC expiry height and then your
counterparty might claim back the funds with a timeout transaction.  And all of
that time, your invoice remains in the settled state; it's not leaving that
settled state anymore, it's the final state there.  So, for small amounts, it's
probably not a problem.  But as the amounts go up on the Lightning Network, it
could be that some users want to have extra guarantees there as to whether the
HTLC has really been resolved on the commitment transaction as well.  So, not
just the intention is probably settled to LND to settle, but they want to wait
for it to actually happen.

So, what this PR does is it adds a new API to query the ultimate outcome of an
HTLC if there's already an ultimate outcome.  And what you could, for example,
do is just wait for all the HTLCs that are paying to an invoice -- in the case
of an MPP payment, it might be multiple HTLCs paying to that invoice -- wait for
all of them to reach their terminal state where they are settled, and only then,
for example, send out the goods to the user or maybe credit something or
complete a swap, or whatever you want to do at that point.

**Mike Schmidt**: It's really great to have Lightning experts on the recap to
help us with these Lightning PRs.  Thank you.  Sorry, continue.  We can do
#7001, I suppose.

_LND #7001_

**Joost Jager**: Yeah, so #7001 is one I'm not particularly a fan of.  I think
this is like a decoration of an RPC response with additional fields where if I
can get this correct, I think originally you could query the list of forwarded
HTLCs and for every HTLC it showed incoming and outgoing channel ID, something
like that.  Yeah, I think the channel ID, right?  And what this PR does is, like
a previous PR, extended that with also the alias of the pair.  And then there
was a performance hit by doing that.  And this PR allows you to disable that
automatic lookup of the alias for each pair.  But yeah, I'm not so sure that
it's a good idea to decorate those RPC responses with additional data.
Personally, I'd rather solve that on the client level, let the client do another
call or maybe cache some things in memory, because there are so many responses
that you could wish for extra properties that you can also look up through
another RPC, and where do you stop adding those?

**Mike Schmidt**: That makes sense.

**Joost Jager**: So, yeah, but I guess it's good now that by default it's not
happening, so there's no performance impact for people who don't need this
feature.

**Mark Erhardt**: It does sound pretty interesting, though, to get more
information about who you're transacting the most with and who is forwarding
payments through you, so you know what channels to foster relationships with.

**Joost Jager**: Yeah, definitely.  But that information is all available
already, so this is just about designing the API and how do you split up the
various sources where you can get that information, and is it necessary to add
additional fields to not do another RPC call?

**Mark Erhardt**: Cool, thanks.

**Joost Jager**: Yeah, so there's no new information, it's just the way it is
served.

_LND #6831_

So, the final one is interceptor watchdog.  So, in LND, there is a so-called
HTLC interceptor API.  What you can do with that is when your node forwards an
HTLC, you have the option to intercept the HTLC and decide whether you really
want to forward that.  And this is like an external process connecting to LND,
receiving all these HTLCs that are about to be forwarded, and then you need to
send back replies that instruct the node what to do with that forward.  You can
do forward, you can fill, and I think you can also settle.  So, if you already
have the preimage, you can shortcut this forwarding, just skip that and just
settle with the preimage right away.  So, there's three different ways of
resolving those HTLCs.

The only problem is that if your application is down that does the interception,
LND will just hold on to those HTLCs until the application comes back.  And if
it never comes back for whatever reason, the HTLC will timeout, the counterparty
will see this, and they will try to timeout the HTLC onchain.  So, you will lose
the HTLC in any case if you don't answer really.  But this allows you to act
before your counterparty is going through the chain to prevent the force
closure.  Because if the counterparty goes to chain, there's a few more blocks
going through, but in the end you don't have it anyway.  So, with this, we
recognize it's probably better to act before that happens and just fill the HTLC
offchain while still possible, and prevent the force close from happening.

So, it's basically like a safety valve around the HTLC interceptor API.  And I
think it happened before with some users that they had a problem with the HTLC
interceptor and then triggered a mass force closure of channels, because all
those HTLCs stacked up and were just waiting for a resolution signal that never
came.

**Mike Schmidt**: Excellent, thank you for summarizing those for us.  I think
you did a much, much better job than we would have.  As we have a couple more
PRs remaining in the newsletter, it would be a good time to let you all know
that if you have a question or a comment that you'd like us to address at the
end of this Spaces, feel free to raise your hand or request speaker access now
so we have that ready to go as we wrap up here.

_LND 609cc8b_

The next PR was actually not a PR, it's actually a commit to LND that adds a
security policy for providing instructions if there is a vulnerability to who to
contact and how, which unfortunately was not utilized per our discussion earlier
about that large taproot transaction.  But there is a security policy now for
LND, and I hope folks use that.

_Rust Bitcoin #957_

There's a Rust Bitcoin PR here, #957, and that adds an API for signing PSBTs.
It does not yet support signing taproot spends just yet.  Murch, I don't know if
you have any comments on that; that one seems pretty straightforward?

**Mark Erhardt**: No, I'm just generally super-excited that PSBTs are getting a
lot of love in the last year or so.  I think just creating multiparty
transactions was so much harder when everybody had their own standards for how
to express PSBTs; and there just being an open, good enough standard that serves
everyone, that everyone implements, and now everybody speaks the same language,
it's making all of this so much easier.

_BDK #779_

**Mike Schmidt**: Agreed.  And the last PR this week is BDK implementing low-r
grinding, which is a way to generate multiple signatures until you get one that
is slightly smaller, one byte fewer than other signatures that you could
generate using ECDSA, and so it saves a bit of space there.  Murch, I'm sure you
have an improvement on that summary!

**Mark Erhardt**: This is one of my pet peeves.  So, ECDSA signatures are not
stable in length, because if you have an r-value that is in the upper half of
the space, then it's encoded with one more byte.  So, this is an issue, for
example, for transaction fee estimation.  When you don't know whether a
signature's going to be 71 or 72 bytes, you need to always pay for 72 bytes in
order, for example, to hit minimum relay fees, or if you're using something like
the damn BIP70 that BitPay proposed, where it required minimum transaction fees
or minimum transaction feerates on payments, then you might undershoot such
requirements if you use the average, or like 71.5 bytes.

So, you always have to basically estimate with the maximum length signature in
order to be safe, and this has caused issues in the past.  Now everybody is just
trying signatures multiple times, which usually takes an expected two attempts
to get a signature that is of the smaller variety and then uses that end.  So,
this (a) saves one byte on your transaction size, (b) allows you to have better
estimation of your feerate because the length of the transaction is always what
it expected to be, and yeah, everybody should be doing this.  So, great on BDK
for having this.

**Mike Schmidt**: I had a feeling I would set you off with that!  Good
explanation, Murch.  I don't see anybody with their hand up or speaker requests,
so I guess we could end by thanking our guests, Joost and t-bast, for joining us
and providing some insights on their proposals, as well as some commentary on
some of the PRs.  So, thank you guys for your time.

**Bastien Teinturier**: Thank you.  And thank you for all the work Optech always
does.  It's a really great, great job, thanks.

**Joost Jager**: Definitely, it's a great newsletter.

**Mike Schmidt**: Thanks for saying that, guys, and we'll hopefully have you on
a future episode so you can explain some of the other cool things that you guys
are working on.  Murch?

**Mark Erhardt**: Yeah, thanks everyone for coming.  I hope you had fun and
learned something, and see you all next week.

**Mike Schmidt**: Thanks, everybody.

{% include references.md %}
