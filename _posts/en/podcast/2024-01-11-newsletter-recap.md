---
title: 'Bitcoin Optech Newsletter #284 Recap Podcast'
permalink: /en/podcast/2024/01/11/
reference: /en/newsletters/2024/01/10/
name: 2024-01-11-recap
slug: 2024-01-11-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao, Gregory
Sanders, Dave Harding, and Stéphan Vuylsteke to discuss [Newsletter #284]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-0-11/7f48a86d-c5ac-b8df-813c-f1b908270b20.MP3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #284 on Twitter
Spaces.  Today we're going to be talking about v3 relay policy and fees,
LN-Symmetry, a Bitcoin Core PR Review Club, and more.  I'm Mike Schmidt, I'm a
contributor at Optech and also Executive Director at Brink, where we fund
Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch and I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Dave?

**Dave Harding**: I'm Dave, I'm co-author of the Optech Newsletter and of
Mastering Bitcoin Third Edition.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Hello, I'm Gloria, I work on Bitcoin Core, mostly mempool and
transaction relay stuff.

**Mike Schmidt**: Greg?

**Greg Sanders**: I'm Greg or instagibbs.  I'm with Spiral and I do research,
which is a kind of cross between mempool policy work and I've also done
Lightning work, so kind of the intersection of smart contracts and mempools.

_Discussion about LN anchors and v3 transaction relay proposal_

**Mike Schmidt**: Well, thank you all for joining us.  We have some interesting
discussions this week.  We'll go through the newsletter sequentially, starting
with Discussion about LN anchors and v3 transaction relay proposal.  So, last
week we discussed v3 transaction relay in the context of transaction pinning and
pinning costs, and the fact that v3 could drastically cut down on the maximum
fee costs that an attacker can force upon an honest user, something like from
100X to only about 1.5X to 2X to 3X.  This week, some of that discussion has
continued, and in the newsletter we've split the discussion into five different
parts.  Gloria, maybe you can provide a quick elevator pitch on v3 policy for
folks that aren't familiar, and then we can tie that into this discussion of
endogenous, exogenous, and out-of-band fees.

**Gloria Zhao**: Sure, yeah, and feel free to jump in, Greg.  We were actually
discussing rebranding v3 to priority transactions; credit to Greg for coming up
with that.  It kind of stems from a multiyear-long discussion about RBF pinning,
especially in LN.  So, there were quite a few posts by BlueMatt and Greg and
t-bast and Antoine about the various pinning attacks that plague LN users, that
kind of weaken at security when they try to go onchain.  And so, we spent some
time collecting all the grievances and limitations and trying to categorize them
and come up with solutions.  And so, that's kind of where the discussion
started.  And one of the categories of solutions was to try to create an opt-in
policy, where users could be like, "This is a transaction in which I'm not
interested in spending the outputs before they're confirmed, but I am very, very
interested in getting this confirmed in a timely manner".  And this stems from
the idea that we have these pretty permissive package limits, like ancestor and
descendant limits in mempool policy, and they're not always suitable for the use
case.

So, the biggest pinning problem that priority transactions are trying to address
is, well, you have 101 vbytes of descendants that you can have.  In LN, you're
not actually really trying to spend these unconfirmed outputs before they
confirm, and that permissive descendant limit can sometimes really, really hurt
you because an attacker can attach a very big, low feerate, but high fee
transaction to increase the amount of money you might have to spend in order to
replace that, much more than what you were planning on spending just to fee bump
your transaction.  So, yeah, that's where v3 priority transactions comes from.
This discussion, I think it started with Peter Todd posting on the PR itself
with a number of issues, and I think Antoine's idea was, some of these are kind
of general design questions that maybe are better suited for Delving instead of
the PR, and some of these are just about LN anchors in general.

Some of the discussion is just like, "CPFP is more exogenous fees compared to
RBF.  Does that --" or I guess now I'm starting to summarize; I don't know if
you wanted Harding to talk about this instead.  Yeah, just like, "Is CPFP good?
Is LN Anchors a good design?  Can it be better?" etc, and so starting to zoom
out a bit and talk about more broader things than just the v3 proposal itself.
Anything I missed?

**Mike Schmidt**: No, that was great, that's great, and that leads into my
question for Dave here to frame up these parts of the newsletter, these five
different parts of the discussion, all kind of involving these terms.  And,
Dave, we have endogenous fees, exogenous fees, and out-of-band fees.  How would
you summarize each of those terms before we jump into some of the parts of the
discussion?

**Dave Harding**: Well, credit to Greg for the exogenous and endogenous fees.
He's the first person I saw using those terms and I like them, so I used them in
the newsletter.  So, exogenous fees would be fees that are paid outside of the
core of the transaction you want to put onchain.  So there's some data you want
to put onchain and you have to pay a fee, of course, to miners to encourage them
to put that in their blocks and put it onchain.  And how do you pay that fee?
Well an endogenous fee, that starts with EN, that would be a fee that's
fundamental to the transaction itself.  So, for our normal transactions that we
spend every day on Bitcoin, we're paying endogenous fees.  We're just including
a fee, an implicit fee, in that transaction and sending it to the relay network,
and relay network is sending it to miners, and miners are looking at that fee
and deciding whether they want to include that transaction in their blocks.

However, Bitcoin provides a number of different methods that allow you to decide
what fee you want to use after the fact to create the core of your transaction,
without having that fee included, and then include it later.  A really simple
one is CPFP.  That would be, you send the transaction you want to get confirmed,
and then you send a second transaction that spends one of its outputs, a child
transaction, and you make that child transaction pay extra fees in order to
encourage miners to also mine its parent, which is required by the protocol.  If
you want to cut the child fees, you also have to mine the parent.  But another
way to do that is using the signature hash (sighash) flags, changing what inputs
the transaction commits to, allowing you to add an input later on.  So, you have
the core of your transaction, the data that you want to put onchain, but you
also allow someone to add extra transactions to it, extra inputs to it later,
and those extra inputs can pay a fee.  You also allow them to add extra outputs
later so they can get their change back if they have any.  And those are the two
main methods, although you can think of other methods for paying fees
exogenously, so again, outside of the core of the protocol.

Finally, Mike alluded to the out-of-band fees.  And this is the difference
between paying a miner in a transaction using the implicit fee mechanism versus
paying an individual miner or a small group of miners independently not using a
transaction.  So, a good example of this is, for example, the mining pool,
ViaBTC, allows you to I think use a credit card to pay them to what they call
accelerate transactions.  So, you tell them the txid of a transaction and you
use your credit card to pay them $10, and they will use their hash power to
confirm that transaction regardless of what fee it pays through the protocol.
And out-of-band fees are really bad for mining decentralization because it's
easy for a large mining pool to offer that as a service and grab those fees, for
example via credit card, but it's very hard for small mining pools to offer the
same service.  ViaBTC, I don't know, they're at like 20% hashrate right now.  So
within 12 blocks, you're almost guaranteed to have that transaction confirmed,
maybe it's 15 blocks; whereas somebody with 1% of hashrate probably can't offer
that guarantee for about 200 or 250 blocks.  So, you're not likely to go out and
find a small miner and offer to pay them $10 via a credit card transaction just
so you can wait 250 blocks for your transaction to be confirmed.  And if small
miners are making less money than large miners proportionately to their
hashrate, then there's a very strong incentive to be a large miner and not a
small miner.  We drive all the small miners out of Bitcoin and there's only a
few large miners who need to be corrupted in order to begin censoring Bitcoin
transactions at a protocol level, which again, that breaks Bitcoin censorship
resistance, which breaks a whole bunch of properties in Bitcoin that we either
like or absolutely depend on.

So, I'll get to the first bullet point here and then I'll hand it back to you,
Mike, to decide who's to talk next.  But I think the really interesting insight
from Peter Todd's post, and it's something that I haven't heard before, is that
if we depend too much on exogenous fees, fees that are added to the core of a
transaction after the fact, we create an incentive for people to pay fees out of
band.  Because if the core of a transaction can be broadcast and can be
confirmed without the extra data necessary to add extra fees, whether that's a
child transaction or that's extra inputs being added through a sighash flag,
then it would be more efficient for miners to not include the extra fee
information and collect fees out of band.  So, if you can imagine two different
versions of a transaction, we'll think of the CPFP example, there's one version
where you only send the version with the parent to the miner and you pay the
miner fees using your credit card; and there's a version you send both the
parent and the child to the miner and you use the regular transaction fee
mechanism in Bitcoin to pay the fees.  And in the second example, you could be
using a fair bit more block space, than the first version.

So, in the first version, the miner could, say, include twice as many
transactions in theory in a block, parent-style transactions, as a different
miner who has to include both the parent and the child transaction in their
blocks.  And that creates an incentive for a large miner, who can guarantee
relatively fast confirmation, to offer a discount to people who are willing to
pay fees out of band because they can include twice as many transactions in
their block.  They can offer, for example, Peter gives the example of a 25%
discount on fees to have you pay using a credit card rather than using bitcoins
in the transactions.  And this is a really interesting idea, it's something I
haven't seen before.  People talk about this potential risk of exogenous as
fees, but I think it is worth noting that even in Peter's post and even more so
I think in follow-up discussions, this is clearly on a spectrum, how much extra
space in a block is taken up by the extra transactions or inputs or whatever it
takes to pay the exogenous fees, relative to again that core of the transaction,
the data that you absolutely need to go onchain.

Peter focuses on an example where the extra data to pay the fees roughly doubles
the size of a transaction over that fundamental core, and he thinks that's
really bad.  But on the other hand, there's examples where he thinks, it seems
in his posts, where he feels comfortable with that, when it only represents say
10% of the data; the fee-paying data only adds an extra 10% to the size of the
transaction.  And so there's a spectrum here.  I don't see anywhere in this
discussion anybody drawing a bright line and saying, "This is an unsafe level
and this is a safe level".  So, I think it's something that needs to be
discussed and thought about.  And yeah, that's it, I'll hand it back to you,
Mike.

**Mike Schmidt**: Dave, if I'm to sort of paraphrase or summarize, I think maybe
folks would have thought, if you're paying the transaction fee in bitcoin,
that's good and fine, and maybe if there's something being paid on a credit card
out of band, that's a little funky.  And it sounds like this discussion is maybe
saying, well, maybe not every fee paid in bitcoin is kosher, maybe there's some
risk; if you're bringing external, exogenous, outside-of-the-transaction fees,
that is potentially introducing some risk as well.  That's how I'm understanding
it.  Is that right, Dave?

**Dave Harding**: Yeah.  Basically, if we build protocols that handle this type
of behavior, and we create an incentive for people to pay out-of-band fees, then
there's a risk that people will pay out-of-band fees.  And if too many people
pay out-of-band fees, then it puts Bitcoin's mining decentralization at risk.

**Mike Schmidt**: Instagibbs, the next point here mentions ephemeral anchors,
and I also see you have your hand up, so maybe you want to comment generally or
specific to ephemeral anchors?

**Greg Sanders**: More generally.  First, I would say this writeup is great, I
just read it while you guys were talking.  So, I think this is a pretty fair
representation of the arguments.  One point that I don't see here is this major
point that I think I've made elsewhere, that in a number of smart contract
cases, it's really a strange credulity that you're going to have endogenous
fees, right?  I guess this leaks into LN-Symmetry as well, but there's many
cases where you just simply can't do it, or maybe you need really, really heavy
covenants and state machine logic to do it, maybe you could.  But I think that
makes it really difficult to think about.  And then, second is that exogenous
fees can also happen -- or I guess, sorry, out of band is a form of exogenous.
So, let's say out-of-band fees can also happen in a bunch of scenarios like
mempool.space transaction accelerator, which most people are going to be using
for simple payments that can't RBF.  So, I think there's also a danger in
saying, "Let's not improve RBF today", for general usage, where if we're too
focused on one protocol, exactly how LN has specced up today, exactly, we might
lose some of the bigger picture.

So, I just caution a little bit focusing too much on LN.  It is an important use
case, but there's also other use cases.  Alright, I'll cede my time.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Yeah, basically very similar to what Greg said, I think the
argument of incentivize -- yes, out-of-band payments are pretty toxic to
decentralization, but this argument of incentivizing it, like when we're talking
about I guess in a market sense, it's like, okay, we have this decentralized way
of communicating to miners your priority and paying them fees, and it's
inefficient.  We've spent a lot of time talking about how fee bumping mechanisms
today are not useful enough and not expressive enough and not efficient enough,
and that's why people might be interested in using something much more efficient
and more centralized, which is very natural.  But this is also something that we
can improve, right?  Like with ephemeral anchors, one of the biggest
improvements there is reducing dramatically the size and bytes of that kind of
output/input step of doing that CPFP, and that should take away a lot of the
friction of using these in-band, whatever the opposite of out-of-band is, ways
of paying miners.  And so, I think the solution is to make our decentralized
thing more efficient instead of demonizing these various ways of doing it.

**Mike Schmidt**: Murch, I saw you had your hand up.

**Mark Erhardt**: Yeah, I wanted to sort of approach this from a different angle
in saying that there is this incentive, but there are also a few disincentives
of using out-of-band payments.  First, you always pay, whether the miner
actually succeeds or not at finding a block, and you only pay the ones that you
choose to hire.  So, if you are paying any miner out of band to get your
transaction accelerated, you need to pay upfront and that money is gone,
whatever success or not.  And I know that mempool.space is trying to sort of be
a middleman there and gives you back the fees, so that would be slightly
different.  But in general, this is only an interesting product to sell for
miners if they make more money that way.

However, if you do an in-band bump, a reprioritization where you offer more fees
on the network itself, you bid on everybody's block space; while if you only
hire a single mining pool, you only bid on their block space.  So, you'll have
to wait longer, you pay more, and you have the additional friction of needing to
go out of band instead of communicating directly in network.  So, there's also a
few things that push back on this incentive of, yeah, saving a little bit of box
space.

**Mike Schmidt**: A quick disclaimer here, obviously we're talking about some of
Peter Todd's ideas and Peter Todd is not here.  Same thing with last week.  I've
asked Peter to join both weeks and I think he wants to join but it's just been
bad timing for him.  I think he was traveling during both of these Spaces, so
we're trying to represent his ideas as best we can.  Another point brought up in
the newsletter here was the necessity to keep an extra UTXO in your wallet and
the downsides of that, and having that UTXO essentially sitting around waiting
for fee bumping.  Does anybody have any comments on that particular criticism?
Go ahead, Murch.

**Mark Erhardt**: Yes.  So, the alternative that Peter proposes is that we
assign 50 different versions of higher feerate replacements of each other.  So
we have to sign a lot more, manage a lot more state, especially if we have
multiple transactions that build on top of each other with splicing; I think
that could be more complicated.  And if you have to have the funds for larger
commitment transactions on hand for your RBFs to remain valid, then you also
have to tie up funds here, because if you have a commitment transaction in which
you do not have to tie up the funds upfront but can deliver them upon trying to
close the channel, you do not have to tie up funds for the larger RBFs during
the signing of 50 variants.  But I just don't see how it's that significantly
different, to be honest.

**Greg Sanders**: Yeah, I'll just say the whole topic is complicated and there's
actually very few right answers and wrong answers.  So, it's like a lot of
judgment calls and design goals that are competing.  This is why I would say we
don't stop methods of investigation just because we have an opinion about one
specific instantiation of one specific smart contract.  That's my big point, I
guess.

**Mike Schmidt**: Greg, one of the bullets here harkens back to last week's
discussion, where Peter Todd describes a pinning attack against uses of
ephemeral anchors.  Maybe you can summarize that briefly and comment on it.

**Greg Sanders**: Is this the one that I had in the BIP for a while?  So, okay,
we'll talk about pinning in general, I guess.  The pinning problem, to recap, is
that the overall transaction package that you might have to RBF can be up to 101
kilo-vbytes (kvB).  This is more than two orders of magnitude larger than what
you typically need to do to make a small payment, right?  So, if you do like a
-- let's see, do I have a calculator?  I'll get the Optech calculator out.  If
you have like two inputs, one output, that's, you know, 200 vB, or something
like that, versus 101 kvB.  That's one, two, two orders of magnitude plus 5X.
So basically, you've got 500x pinning, right, something like that.

The v3 idea is basically that we can't really get around the free relay problem,
which means we can't just toss absolute fees out of the mempool safely.  What we
can do is kind of have prior restraints.  So instead, this child transaction can
be small, and we picked an arbitrary number, 1 kvB, which is 100 times smaller
than the maximum, and so you still have this wiggle room, this 200 vB, let's say
as an example, 200 vB to 1,000 vB wiggle room.  And that's where, in my
ephemeral anchors BIP, I say it's about 500X pinning to 5X pinning.  So you
still have, depending on the mempool weather and how things are shaking out, you
have about up to 5X pinning possible.  The practical pinning is probably
smaller.  Peter Todd, and Gloria were arguing about these numbers.  I'm not too
interested in that personally since they're hyper-focusing on one protocol.
It's fine to talk about, but that's kind of the upper limits, and there's
practical lower limits.  It's more like, you know, it really depends on what
you're doing, I guess.  So it gets smaller, depending on what you're doing.  I
don't know if it's satisfactory, but…

**Mike Schmidt**: Any comments from our other guests?  Dave says good.  Is there
any other feedback about what Peter Todd suggests in terms of pre-signed fee
bumps?  We kind of touched on it, but does anybody have any further commentary
there?  Go ahead, Dave.

**Dave Harding**: First of all, I think we want to qualify the worst case.  So
the LN protocol currently allows 983 Hash Time Locked Contracts (HTLCs) in a
channel.  And every one of these has to be pre-signed.  And if we do 50
variations of incremental RBF fee bumps, which I guess I should take a step back
and explain.  Peter Todd's suggestion for changing exogenous fees into
endogenous fees is just when two people in an LN Channel or another protocol are
negotiating the transactions, they're offchain transactions, they sign the fees
on that transaction at 50 different feerates, each about 10% difference, which
will give them a range between 10 satoshis per vbyte (sat/vB) to 1,000 sat/vB.
And they can go outside that range, they can go higher if they need to with just
a small increase in the number of different versions.  So, we'll use 50
different versions as a rough sketch there.  But if you have 50 different
versions of your main commitment transaction and you also have to sign for each
of those a different version of the spend from the output, you're looking at
tens of thousands of different signatures you have to generate for a completely
full channel.

Now, Peter Todd has argued that a completely full channel is not something we
see in the wild on LN right now, and I believe that's a reasonable criticism.
But that's what this spec allows, and I think that's worth considering, that
this is a completely unreasonable number of signatures.  Using the examples that
Peter Todd offered in his post, it would take about 12 seconds to sign every
different version of that transaction, and that's for a single hop.  So, we're
looking at possibly several minutes to relay a transaction across the latent
network if every channel had all of its HTLC slots full.  Again, that's not
entirely realistic, but I think it's worth thinking about as the cost of this.
And then, I was looking at this and thinking, even in the best case, which Peter
analyzes to be about 5 milliseconds per hop, which is really short, right,
that's a really small additional time to be able to do these pre-signed feed
bumps, I think that as LN improves and as people find techniques to reduce the
amount of time it takes to relay transactions across LN, 5 milliseconds might
end up looking like a big difference.  There's ideas out there, one of them I'm
a big fan of, it's called stockless payments.  And that could make it so that
somebody who takes an extra 5 milliseconds to route a payment, a forwarding node
in LN, would earn much less revenue than a node that used exogenous fees and
didn't require those extra 50 signing sessions.

So, I just think that there's reasons to believe that exogenous fees, even if
they're not strictly necessary, they might be preferable.  So, this is something
we're going to have to design for.  I think it's coming back to Greg's earlier
point.  I think he's got his hand up too.

**Greg Sanders**: Yeah, I agree.  So, one point is, this is where it's helpful
to make a spec, right?  You don't really know where the pain points are unless
you try to implement it, which will circle back to LN-Symmetry on that.  Second,
or there's two points I can make and kind of mitigate and/or help here, is that
in practice, HTLCs are capped by nodes.  So, maybe the spec would want to
revisit the total number.  I think Core Lightning (CLN), Eclair do 30 tops.  I'm
guessing LND does something similar.  And also, reducing this HTLC max also
reduces another pin where, in either case, with endogenous or exogenous, RBF,
CPFP, where a revoked commitment transaction can be larger, because let's say
you cap 30 HTLCs, then if the current commitment transaction has no HTLCs, you
have to compete against that larger transaction at any number of feerates that
are pre-signed.

So, there's still a pinning vector there, and I would call it a bug in the LN
spec because there are other ways of designing the transaction that would have
avoided this.  The key problem here is that your adversary gets to pick the size
of the transaction you're competing against, which is a problem.  But that's
kind of one note, is that this is like another pin that you have to handle, and
in practice it looks like you get something like 1.3 kvB, I think.  You can
doublecheck my math; I used your transaction size calculator on Optech.  This is
something to think about.

Then last is that for the HTLC pre-signing problem.  This is where something
like ANYPREVOUT (APO) or CHECKTEMPLATEVERIFY (CTV) plus CHECKSIGFROMSTACK (CSFS)
really simplifies things because the spec -- basically what you can do is have
the pre-signed transaction be unbound to any specific txid.  And so in the LN
spec, you'd basically say, "Add this HTLC, add this HTLC", and you'd include the
signatures up front.  And then the signatures would live for the entire lifetime
of each HTLC or Point Time Locked Contract (PTLC).  And so, I think that's
something that people also overlook that would greatly simplify these protocols,
regardless of how we want to go.

**Mike Schmidt**: In wrapping up, there was one portion of the conclusion
section of the newsletter which linked to Rusty Russell's blogpost recently
about stacking transactions.  Admittedly, I have not read this blogpost, but
Dave, I saw you and Greg both responded to his tweet about this.  Is there
something that either of you feel comfortable summarizing with regards to
stacking transactions and potentially covenants?

**Greg Sanders**: You want to try, David?

**Dave Harding**: I think rusty is just thinking about this idea of how to
minimize the size difference between, again, that core of the transaction that
contains the data that you need to put onchain, and the part of the transaction
that carries the fees that you might need to decide on afterwards.  I didn't
look too closely at his blogpost, so I can't summarize it effectively, but I
just felt like some brainstorming that he's putting out there for other people
to read and think about in context of this and in context of the other
protocols.  Maybe Greg has more.

**Greg Sanders**: Yeah, so I think if you followed any of these flexible sighash
proposals like SIGHASH_GROUP or anything, TXHASH or things like that, basically
it allows you to, let's say, combine commitment transactions, you could stack
them together, right?  You can imagine this.  So, if we had sighashes flexible
enough, we could get rid of a bunch of this overhead and then pay exogenous
fees, but you could maybe just have one extra input, one extra output for
change, pay for n smart contracts at the same time.  So, he's kind of thinking
about what would be the best and what's a safe way of doing this; and what's the
most compact way of doing this to reduce the amount of effect you get from this
exogenous fee kind of incentives misalignment?

My only other comment to that was like, yeah, that'd be great, but we still have
to figure out how to do anti pinning, because as soon as you batch these smart
contracts, then you can think of an attacker that, let's say everyone's going to
get paid 0.1 bitcoin, or something in the smart contract, if they can stick
together 100 of these, pay 1 bitcoin in fees, no one single contract user is
going to pay more than 0.1 bitcoin fees.  So, they'd have to collaboratively RBF
it, and that seems this is kind of a hostage problem.  So, that's something we
have to figure out too, and I would love to solve it, so I've been thinking more
about this stuff.  But right now, I'd say smart contracting needs to be
unbatched to be unpinnable, for now.

**Mike Schmidt**: Dave did a great job of breaking down this discussion into
these different parts for the newsletter.  But there's also a lot of additional
information available linking off linking off to Delving Bitcoin, linking off to
previous discussions on GitHub, and then obviously the Rusty Russell post.  So,
if you're curious about any of this, feel free to dig into that, because I think
we've really only scratched the surface here in a summary fashion.  Gloria?

**Gloria Zhao**: I just wanted to pre-shill.  I'm working on a gigantic document
to index all of the discussions that have happened over the years.  It's taking
way longer than I thought it would.  Big props to Harding who does this all the
time.  But I'll try to post that sometime in the next few days.

_LN-Symmetry research implementation_

**Mike Schmidt**: Awesome.  Moving on to the second news item this week,
LN-Symmetry research implementation.  Greg, you've posted to Delving Bitcoin
about an LN-Symmetry, previously known as eltoo, proof of concept in CLN.  I
know this is something you've been working on for some time now.  We noted five
highlights from your work that you've posted about, and we can get into those,
but maybe you can just provide a quick overview of the project to start.

**Greg Sanders**: Right, so the original proposal was, "Hey, there's this eltoo
paper, sounds good, but there's a bit of script pseudocode and there's no actual
discussion about what the nitty-gritty details will look like".  So I, with
Rusty Russell, we kind of came up with this plan.  So, I rejoined Blockstream at
the time and started working on this.  Along the way, I wanted to get to a point
where all the major technical hurdles have been cleared so we can have a better
idea of what works, what doesn't work, what software changes would we need,
would we need mempool changes.  And that's where maybe I didn't express this
properly in my writeup, but a lot of the anti-pinning work was reflected in this
because I realized with without penalty transactions, you really need to get
that part of the story right; and actually, if it wasn't made clear, that
LN-Symmetry also uses v3 and ephemeral anchors, or priority transactions,
whatever you want to call it, as a key component.  So, this kind of smart
contract doesn't have endogenous fees almost by definition.

**Mike Schmidt**: I saw in your post that you noted that you broadcasted channel
opens and closes using LN-Symmetry on Bitcoin Inquisition signet.  Is
LN-Symmetry something currently that you're running there or that other folks
can run there or can be expected to be run there?

**Greg Sanders**: So, what prompted this was, AJ was aware of my work, AJ Towns,
and he's like, "Hey, did you not tell anyone else about it?"  And I was like,
"Oh, yeah, I probably should put a post together or something, recapping a
project".  So, I ran it.  I spun up two nodes on the Inquisition signet, I did
all the transactions and then closed them normally, well, not normally,
unilaterally, because the interesting part is when things fall apart and you
have to have the smart contracts execute.  So, you have the channel opening, the
update period, meaning the claims, the challenge, and then the response as well;
challenge, response and then settlement.  And then I don't think I had HTLC's
auto-settle, but the code is there to do it and it's got test coverage.  So, I
would expect that to work.

Yeah, so once I finished the implementation, I got more sucked into the mempool
side of things because I was like, okay, we have to we have to make things
easier to RBF and CPFP and all of the above, so I put that down.  But it looks
like there's some more current interest by AJ Towns himself.  He's started
running nodes and showing me crashes, because it's stuff I didn't fix.  And
then, he tried a cooperative close and I did not implement that, so it hung.
And also others too, they're talking about future soft forks, whether you need
APO, or can you use CTV plus CSFS, those kind of conversations.  So, that's kind
of the current state of things.  We got code that should work, it has functional
tests with the HTLC state machine coverage and all those goodies.  If you want
me to dive in any more, let me know.

**Mike Schmidt**: Yeah, to piggyback on what you just mentioned there about soft
forks, you noted, "I hope this work helps de-risk conversations about future
soft forks and channel designs".  Maybe unpack that a little bit for us.

**Greg Sanders**: Right.  So, if we want to do a soft fork, we should be sure
it's actually the thing we want.  I think that'd be such a catastrophic mistake
if we had a soft fork that wasn't actually usable.  So, proving out these
designs is the most important thing, I think.  So, that's the soft fork side of
things.  The channel design side of things is, I looked at the LN spectrum top
to bottom, I said, "What would I change?"  And so, a lot of it was
simplifications.  So, there's this concept in today's LN where the commitment
transaction is what we call -- I think this is an AJ word that he made --
layered transactions.  So, the commitment transaction has all the HTLCs right
there.

So, during this challenge and response period, all this stuff is being exposed.
And so, as a knock-on result, your node should probably remember all the
previous HTLCs forever, because if an HTLC was in a revoked transaction that
your adversary wants to play, you need to be able to open the commitment to that
scripthash and spend it with your revocation key.  There's also this pinning
thing I talked about, that lets your adversary pick the size of a transaction,
which isn't great.  The big benefit you get there is that you can reduce the
delta, the expiry delta, meaning the latency to going onchain, if it fails, per
hop significantly, because the current design allows you to essentially commit
onchain instantly that the HTLC timed out or succeeded, while still allowing a
revocation period where you can be challenged.  So you can say, "Hey, this
commitment transaction was legit, this HTLC success transaction was legit", but
then it sits there and has to wait for the counterparty to respond to say, "Hey,
this is revoked, I'm taking the funds".

So, this kind of layered setting is, I think, kind of a mistake.  I would say
this is my most opinionated thing, is I think that was a mistake.  I think we're
optimizing for something people don't actually optimize for in reality.  Like
Eclair, when they're doing route finding, they don't really, as far as I know,
they don't even wait in their objective function, they don't even put the expiry
delta in their function, as far as I know.  They have like a hard cutoff, and
then they don't worry about it.  Versus something like spec simplicity, like how
simple is the spec to read; how can we think about what hits the chain; what is
the adversary allowed to put on the chain?  These things become a lot simpler.
So for example, if we didn't have this commitment transaction the way it is,
waving away pinning for now, you could get rid of all the pre-signed HTLC
transactions.  So, you'd have one signature per commitment transaction and it's
a constant size.  I think you can see where some benefits show up here.

Now, I put an asterisk here because you do, for pinning reasons, we need to
somehow fix the case where the success direction doesn't pin the timeout
direction.  So, like OP_EXPIRE would fix this as an example, if you somehow got
that to work.  But we've got to figure out how to stop that pinning direction.
But if you just ignore pinning for now, for the HTLC resolution, that's what we
get.  I think that's pretty powerful as an idea.  I'll stop ranting there!

**Mike Schmidt**: One of the other highlights from your post was around
penalties and the conclusion that penalties do not seem necessary.  But I guess
folks were not sure that that was the case.  Maybe you want to drill in on that
a little bit, I thought that was interesting.

**Greg Sanders**: So, I'm not sure what I wrote.  I think penalties are more
important when things don't work correctly, right?  So, when we're not good at
RBFing, not good at propagating transactions, the penalty is sort of like a wild
card, I would call it.  But in reality, this penalty is essentially 1% of
channel balance.  This is the default reserve value that each participant can't
actually spend.  So, there's this value you can't actually spend, called a
channel reserve.  That's reserved for the case where an adversary drains all
your value into HTLCs through circular routing and then plays a revoked
commitment.  So, really what you're getting is a 1% penalty against the
attacker, no matter how much more they're putting through and stealing from you.
So, they could steal 99% of your liquidity in HTLCs, but aha, I burned their 1%.
Well, congratulations, I guess.  It's kind of, I think our time is probably
better spent making things work correctly instead of trying to penalize things
for working incorrectly.

So, that was kind of my design ethos when building this.  I'd rather RBFing and
bumping and paying fees be reliable, so the chance of theft is zero if you're
online.  There is an argument about, if you go offline and you're never going to
go online anymore, your counterparty kind of has no interest in trying to cheat.
So, maybe they will.  That's the remaining argument there, which there's no
right or wrong answers.  But philosophically speaking, I'd rather we simplify
the spec, make it easy to reason about and don't add punishments that they don't
actually punish what we want to.  But when you're saying like LN-Penalty, you
take all their balance, a confident adversary will only lose 1% of the balance
getting caught.  So, I think designing for 100% is kind of silly.  It's going to
punish simple bugs and people that didn't actually want to do the thing they
did.

**Mike Schmidt**: Murch, Dave or Gloria, any questions or comments on
LN-Symmetry and what Greg's talking about?

**Dave Harding**: First, I just want to say a huge thank you for working on a
proof-of-concept implementation.  It sounds like you learned a lot and that we
are all, the rest of us, learning a lot as proxies through your learning, and
it's just amazing having this software out there.  And the other thing I wanted
to say is that I did miss something important in my writeup that I didn't
realize until I was going back to the post again yesterday, that Greg also, in
addition to doing proof-of-concept implementation, he did a rough revision of
the BOLTs, the LN specification, to match his implementation.  So, you can
actually go through the BOLTs and see the amazing simplifications that are, at
least in theory, possible from eltoo.  I think it's a really strong validation
of the idea here.  So, I'm sorry for not writing that out.

**Greg Sanders**: Yeah, go check.  I mean, are you talking about the eltoo spec,
the Symmetry spec?

**Dave Harding**: Yes.

**Greg Sanders**: Yeah, the first thing I did was write the spec.  And then I
went and implemented and then I came back and fixed the spec.  And I think this
is very important, right?  We have ideas.  Make the ideas concrete, try to think
through it, and then -- so, I mentioned the expiry delta stacking issue.  It was
actually worse than I thought.  The trade-off's larger than I thought, and this
is something that no one actually worked through until you actually try to
program the state machine.  And it's like, oh, there's this actual gotcha here.
And people that thought much harder about it than me didn't catch it because
they didn't actually try to make it.

**Mike Schmidt**: Instagibbs, thanks for joining us.  You're welcome to stay on
as we wrap up the newsletter.  Any call to action for the audience?  Do you want
people playing with this yet, or what would you have folks do or not do based on
your proof of concept?

**Greg Sanders**: Well, it looks like a couple of people who are interested --
so, a couple of people seem to be picking it back up again now that I published
this, which I should have done a while ago.  My bad.  So, they're taking a look
at what's there.  I know I think AJ wants to get this running, like nodes
running constantly.  I know I'm getting pinged by people who are interested in
CTV plus CSFS, so I suggested, "Hey, if you think it's a substitute for APO, I
mean it's pretty, I mean I don't want to say easy, but I can show you the spots
where you'd switch out the thing for what you need".  And so, at least in an
idea perspective, it's simple to switch out, but the important thing is, yeah,
validation.  So, I think if you're interested, ping me, personally DM me, I can
put you in connection with other people who are interested.  I don't want to dox
people who have been damning me.

**Mike Schmidt**: We have a question from the audience.  Chris, thanks for
joining us.

**Chris Guida**: Hey, what's up, guys?  Thanks for having me.  I think, Greg,
you pretty much already answered this, but just to be clear, so there's this new
soft fork possibly proposal called LNHANCE, which is CTV plus CSFS plus internal
key.  It sounds like you'd be okay with that change because it sounds like it
would work pretty well with LN-Symmetry.  Do you think it would work better than
APO or would you be equally happy with either APO or LNHANCE?

**Greg Sanders**: I don't weigh too much in it.  I just say I'm not too
opinionated, I guess.  I think people have been thinking about this stuff more
than me recently.  So, if it works it works and it might simplify a couple
things.  It's also nice that you just get these knock-on effects, right?  So, in
LN-Symmetry, I end up doing a CTV emulation, so you could save a few bytes there
by using actual CTV, which is kind of nice.  It does what's on the tin, it's
just easier to analyze.  In the spec, that's actually kind of an annoying part
because if you're doing the APO covenant, you have to pick a nonce scheme and my
nonce scheme is a lot of words for things that should be simple.  So, it'd be
nice to remove some of that complexity.  And then even if we don't do
LN-Symmetry, or whatever, either one of those would give you the re-attachable
HTLCs or PTLCs.  And if you've looked at my PTLC writeup, it makes things so
much simpler.  So, anything that fixes that problem would fix a lot of smart
contract spec work, I think.

**Chris Guida**: Cool, thanks.

**Greg Sanders**: And if you want to look up alternative specs, or not specs, I
guess designs of channels that use APO-like structure, you can look up Daric.
It's by Pedro, I forget his last name; Pedro Moreno-Sanchez, I think, that uses
that and that's like a penalty-based one.  So, you know, there's a lot of things
you could do, and I think these general covenant-like primitives or detachable
signatures and commitments to tech structure is quite useful in general.

**Mike Schmidt: **Thanks again for joining us, Greg.  You're welcome to stay on
if you have things to do.

**Greg Sanders**: I got to hop though, thank you.

_Nuke adjusted time (attempt 2)_

**Mike Schmidt**: All right.  Cheers.  Next segment from the newsletter is our
monthly segment on a Bitcoin Core PR Review Club.  This month we've highlighted
Nuke adjusted time (attempt 2), which is a PR by Nikas, which was hosted, this
PR Review Club was hosted by stickies-v, who's joined us.  Stéphan, you didn't
get a chance to introduce yourself earlier, so maybe you want to introduce
yourself now and we can talk about why we would want to nuke adjusted time.

**Mark Erhardt**: Well, how about we talk a little bit about median time passed
and general restrictions on block times so far.

**Mike Schmidt**: Okay, yeah.  Murch, why don't you start with that and I will
try to coordinate with Stéphan.

**Mark Erhardt**: Yeah, so generally blocks are restricted in their timestamp.
We need that because we use the timestamp to adjust difficulty every 2,016
blocks.  So, we require that generally the timestamps go up.  And to that end,
we look at something we call the median time passed, which is the median
timestamp of the last 11 blocks, which generally means it's about 60 minutes of
the current time if blocks come every 10 minutes.  And we require that a block
must be bigger than the median time passed, which means that the timestamp of
blocks generally has to move forward.  Now, lying by putting your blocks in the
past isn't super-useful, because that'll make the difficulty explode over time.
And the other variant is -- oh, and we can make this a consensus rule.  So, we
do require this in blocks for blocks to be valid in the first place.

On the other side, maybe somebody's time on the computer is off, they had a time
shift, or the data is wrong on their computer, and therefore they're in
summertime instead of wintertime.  So, it can occasionally happen that a
computer system is off by an hour or, well, usually not too much.  So, we do
permit blocks to be slightly set in the future and still accept them.  But we
don't want people to be able to set the time extremely far into the future,
because if they were able to keep increasing the timestamps on blocks, they
would actually be able to affect a difficulty decrease.  So, if they can just
keep having the timestamp run away into the future, they might be able to mine a
lot more blocks than they're supposed to.  So, we have this restriction on the
timestamp that it has to be roughly, at most, one hour in the past and no more
than two hours of your network-adjusted time, because we don't know which
computer's clock is off.  It might be your own clock, it might be your peers'
clocks, so we actually do not trust our own clock alone, but we also look at the
timestamps that our peers attach to their messages on the network.  So, every
P2P message has a timestamp, and we look at our peers' times and adjust our own
guess at what the correct time is by our peers' message times.  Yeah, Dave, did
I miss anything?

**Dave Harding**: Two things is that in the original protocol, we also didn't
want miners setting their block times forward because they could also take
transactions that were timelocked in the future.  We've mostly fixed that with
BIP113, median time passed using for timelocks.  But still, if we could get six
or more miners moving their time forward too far, they could start taking
transactions that were timelocked in the future, which would be problematic in
all sorts of ways.  And the other thing is, it sounded to me like you said that
all P2P messages have timestamps, but I think it's only version messages that
have a node's current time in it.  But besides that, I think you've been doing
great.

**Mark Erhardt**: Thanks for the correction.

**Mike Schmidt**: Let's do a quick check and see if stickies-v can speak;
stickies-v?

**Stéphan Vuylsteke**: Hello, does it work now?

**Mike Schmidt**: Yeah, we got you.  Who are you?  Introduce yourself.

**Stéphan Vuylsteke**: Sorry for the earlier issues.  So, my name is Stéphan, or
stickies-v.  I'm a Bitcoin Core contributor and I also co-host the Review Club
along with Gloria.  And, yeah, I'm funded by a Brink grant as well, and that's
pretty much me.  So, yeah, I hosted last week's Review Club.  It's a very
sensational title.  We're trying to not make it too sensational of a change.  I
might have missed some of the things that you said, Murch, so apologies if I'm
repeating.  But I figured also maybe I wanted to give a quick recap on why it's
important that we have this concept of time in the first place, and I think the
main requirement that we have is difficulty adjustment.  Without time, we can't
actually do difficult adjustments so the blockchain wouldn't be able to run
reliably.  And then, because we already have these hard requirements, we've also
been able to add functionality, like timelocks that also use time.

Now time is also difficult, it's inherently relative, and we also have usual
problems of clocks drifting, synchronizing being difficult, and so forth.  And
it's also exogenous to the blockchain, it's not an inherent concept within
Bitcoin.  So, we need to come to consensus on it, and essentially it's like an
Oracle problem to fix.  So, because we need it, because there's not a single
source of truth, we commit to it and that's why time is in the block header.
And that's also why we need to deal with this whole validating time in the first
place and why this PR is relevant.

I think the explanation of network resistance time is already pretty complete.
I think a couple of good points to add is that, like Harding said, it's only
done on the handshake.  So, it's only used for whenever we connect to a new
peer, we calculate the offset with that peer at connection time or at handshake
time, and then afterwards there's no more corrections.  There's also been a
couple of bugs with it in the past.  For example, it was meant to be on a
rolling 200-peers basis; for the past 200 pairs, it would keep that offset to
calculate the network adjustment.  But actually, it turned out that we only
stored the first 200 peers, and then as soon as the cache was full, it basically
stopped updating it.  That was one issue.  It was never fixed because it did
allow for a different vulnerability, which was never disclosed, so I don't have
too much detail on that.  And also, it's actually 199 as opposed to 100 nodes,
but that's not, I guess, a huge problem.

Then finally, in the initial version of this network-adjusted time, we look at
both inbound and outbound peers.  But obviously, given that inbound peers can be
spammed quite easily, that makes it much easier for an attacker to manipulate
that.  But I think three years ago, Martin fixed this by only having the network
adjustment be based on ad-hoc peers, which makes it much more robust than we
have now.

So, basically the goal of this PR is you just nuke adjusted timing from the
codebase.  The initial goal was to remove it completely, I think, but based on
reviewer feedback, basically what Niklas did was remove it from everything
except from a warning system.  So, we removed the dependency on things like
block validity, block template generation, but also some checks like whether or
not we're still in IBD, and for calculating how many block header commits to
store, and so forth.  He replaced all of those network-adjusted time checks with
local system clock checks, and then we still show a warning to the user whenever
we observe that their clock is out of sync with network too much.  And this, of
course, remains relevant because if a user's local system clock is too much out
of sync, then that means that they can fall out of consensus with network, which
is potentially a very big problem.

I think this PR has a lot of benefits, it has some drawbacks as well.  Benefits
are, for example, it's cleaner codebase.  We can remove some dependencies on
code we no longer need.  We also remove the attack vector where Bitcoin nodes
can make you fall out of consensus by manipulating your time maliciously.  But
then it also increases dependency on your local system clock, because if you
happen to be wrong, if your own clock is wrong, then you may fall out of
consensus and your benevolent peers will not be able to help you get on the
correct time anymore.  And then your local system clock, of course, can be
vulnerable through various ways, including NTP attacks, but then of course
you're in charge of hardening your own system in theory, so maybe that's not
really a responsibility that Core needs to take on.

Then finally, we have this common security assumption in Bitcoin, that we don't
require a majority of honest nodes, we just require a single honest node.  For
example, when it comes to validating what the current chain with the most proven
work is, we just need a single node to tell us that.  But in this case, we
actually did need a majority of honest outbound nodes in order not to fall out
of sync, which I think is a pretty big breach with the rest of the assumptions.
So, cleaning it up, in my view, is a pretty big win.  So, we're still keeping
the network-adjustment time logic around, but only to warn.

But I think one of the main topics in reviewing this was, we are in some ways
touching consensus logic, because having a wrong view of time can make you fall
out of sync with the network.  So then naturally the question comes up, is this
a soft fork or a hard fork?  But essentially, it is neither.  We're not really
changing consensus, this is purely a network acceptance rule.  And even though
it touches consensus, it's not a consensus rule.

**Mike Schmidt**: Interesting, okay, so the validity of a block header's
timestamp is now not based on this network-adjusted time, which was sort of this
algorithm that used peer time to come up with what would be compared to the
median time past for the block's timestamp.  Now instead, we're just only using
system time of the local nodes, of that node's system time to compare validity
of the timestamp.  So then you point out that since you're relying on that and
that could be wrong or could be updated maliciously or unintentionally, that you
could cause some blocks that are valid to the rest of the network to not be
valid to your particular node because your system time is off.

**Stéphan Vuylsteke**: Yes, exactly.  We use a combination of median time past
for the lower bounds of block validity and system time for the upper bounds, or
depending on the direction you look at.

**Mike Schmidt**: Murch?

**Mark Erhardt**: So, if your system time were running low by two hours, as in
you think it's earlier than it is, you would perhaps reject blocks that are
valid.  Would it be right to assume that these blocks are only temporarily
rejected and would get accepted as soon as your local time has caught up fast
enough?

**Stéphan Vuylsteke**: Yes, exactly.  We have different ways of classifying when
our node finds an invalid block, and there's a special label also to indicate
that it is because of time being too far apart.  And if we see it again, when it
does match with our own clock, then we will exit the block again, so it's not a
permanent fork.

**Mike Schmidt**: Murch or Dave, any questions for stickies-v?  Go ahead, Dave.

**Dave Harding**: Not so much a question, but I thought this was really, really
interesting particularly for the item that stickies-v highlighted, the question
we have on the newsletter, "Does this PR change consensus behavior?  Is it a
soft fork, a hard fork, or neither?"  And this was just kind of a mind-bender to
me because I've been telling people for years that one of Bitcoin's consensus
rules is that blocks could not be more than two hours in the future, according
to your local clock, and I was just ignoring adjusted time.  I knew about it,
it's always been kind of a weird, icky thing.  I'm glad it's hopefully going
away.

But there's an argument here by Pieter Wuille that this is not a consensus rule.
And I remember when I was reviewing this PR, this writeup was done by Larry
Ruane, and I saw this and I was just like, "What?  No, that's a consensus rule,
I swear, I know it is", and you carefully think about this logic and Pieter is
of course right; this isn't a consensus rule, this is a local node local node
acceptance policy, and I'm still kind of grappling with this in my head.  It's
just an interesting way to think about things, is that consensus can only be
about things where we all have the same data and we're all using the same rules.
But when it comes to our individual clocks and our nodes, we don't all have the
same data.  Every clock is unique and so we can't have consensus about what time
it is currently.  And so, any rule that depends on our current clocks isn't
consensus and there's no way to make this fully a consensus rule that we know
of.  So, it's just it's just a really interesting thing.  I think it's something
I'm going to be pointing out for years to come, you know, think about this rule
and think about why this isn't consensus.  So, I really enjoyed reading this PR
Review Club write-up.

**Mike Schmidt**: Well, stickies-v, thanks for joining us; Larry, thanks for
doing the writeup; and, Niklas, thanks for the PR and great points on the
discussion.  Stickies-v, thanks for joining us, you're welcome to stay on.
We're just going to talk about one LND PR.  Appreciate you joining us last
minute to walk us through this.

**Stéphan Vuylsteke**: My pleasure, thanks for having me.

**Mark Erhardt**: If there are any other people that want to ask questions or
comment, now is a good time to start looking for the request speaker access
button, because we'll be done after just a single PR.

_LND #8308_

**Mike Schmidt**: No releases or release candidates highlighted in the
newsletter this week, and just one Notable code change, and this is to the LND
repository, LND #8308.  This PR mostly smoothens out some of the issues between
CLN and LND, some of the interoperability, having to do with the
min_final_cltv_expiry_delta field.  And from the BOLT, the
min_final_cltv_expiry_delta is the minimum difference between HTLC CLTV
(CHECKLOCKTIMEVERIFY) timeout and the current block height.  And we talked a
little bit about this last week, in #283, on the CLN side of things, where CLN
was rejecting CLTV deltas of 9 from LND, and the remedy on the CLN side was to
explicitly start requesting that value to be 18 instead of 9.  And now, on the
LND side of things, they are bumping one of their previous CLTV delta defaults
that was previously 9 to 18.

One note from the PR says, "This only affects external invoices which do not
supply the min_final_cltv_expiry_delta parameter.  LND has not allowed the
creation of invoices with a lower min_final_cltv_expiry_delta value less than 18
blocks since LND 0.11.0.  I think there was some commentary from the LND team
back in 2020 that says, "We still retain the behavior of using 9 if no CLTV is
present for backwards compatibility on both sender and receiver side".  That was
the genesis of this, is they left that default a few years ago at 9, and then
CLN was not requesting specifically 18, and so now they've both sort of amended
some of their defaults to make sure that this interoperability doesn't happen
any further.  I'm sure an LN person would butcher that summary, but Murch or
Dave, any commentary?

**Dave Harding**: I can't wait for BOLT12 offers to hopefully make all of this
go away.  The reason not to include a parameter in a BOLT11 invoice for this is
it makes the invoice a little bit smaller, it saves some space.  But if we have
BOLT12 offers, the size of the offer, the text you need to copy and paste, or
the QR code that you need to scan, that remains constant, and then your node can
go out and request all the details from the remote node and get all this
information in the background.  So, these sort of minor compatibility issues,
hopefully a lot of them go away.  So, I'm really looking forward to that.

**Mike Schmidt**: I don't see any questions from the audience or speaker
requests, so I think we can wrap up.  Thank you to Dave and Gloria and Greg and
stickies-v for joining us as special guests this week, and thanks always to my
co-host, Murch, and thank you all for joining.  Cheers.

**Mark Erhardt**: Cheers, hear you next week.

{% include references.md %}
