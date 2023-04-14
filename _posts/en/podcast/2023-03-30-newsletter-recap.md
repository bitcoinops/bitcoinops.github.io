---
title: 'Bitcoin Optech Newsletter #244 Recap Podcast'
permalink: /en/podcast/2023/03/30/
reference: /en/newsletters/2023/03/29/
name: 2023-03-30-recap
slug: 2023-03-30-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Dave Harding to discuss [Newsletter #244]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/68149014/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-3-7%2F51c41810-d746-d516-29e7-b72c6ee34788.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #244 Recap on
Twitter Spaces.  I'm Mike Schmidt, contributor at Optech and also Executive
Director at Brink, where we fund Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs and apparently I host
BitDevs events, or help hosting them.

**Mike Schmidt**: Dave?

**David Harding**: I'm Dave Harding, I co-write the newsletter every week, and
I'm also currently working on an update of the book, Mastering Bitcoin.

**Mike Schmidt**: Yeah, looking forward to that, and I think Dave is somewhat
underselling himself.  He is the primary author of the Optech Newsletter and has
been since the very first edition, and is also the primary author of the Topics
Index, which is becoming increasingly valuable.  So, thank you for both having
that idea for the Topics Index, as well as executing on it a growing number of
topics every month.  So, thank you for that, Dave.

**David Harding**: You're welcome.

_Preventing stranded capital with multiparty channels and channel factories_

**Mike Schmidt**: We have one news item this week, which is about channel
factories, and there are quite a few illustrations, so I've shared in the Spaces
here a link to the different sections of the newsletter.  And if you are able to
pull that up, it may help in some of the discussion here, especially with this
first news item.  Dave, you volunteered, in John Law's stead, to maybe
articulate some of the ideas as well as benefits of what he's proposed in terms
of multiparty channels and channel factories.

For folks that aren't familiar, John Law is an anonymous contributor and posts
ideas on the mailing list and has a GitHub where he has some of his ideas, but
for privacy reasons does not want to join in and speak on the Spaces, so Dave is
going to articulate his ideas in his stead.  So, thank you for jumping in to do
that, Dave.  Do you want to set the stage here, maybe a quick overview of what
the idea of channel factories are, and then we can go through the post this
week, which I think does a good job of walking through not just this individual
post about preventing stranded capital, but the architecture of what John Law
has in mind with respect to channel factories?

**David Harding**: Sure.  First of all, I think it's really cool that John Law
is contributing.  I'm glad to see people do that and I'm also glad that we can
help by trying to explain their ideas, those of us who already have our real
names out there and already have our real voices out there, although Murch has a
super-sexy voice this week!

So, channel factories are this idea that several people can combine their funds
together.  So, you can take say ten people and they can combine their funds
together, and with those ten people, they can open four to five channels
offchain without putting a single funding transaction onchain.  So, they put a
single transaction onchain that pools all their funds, and from there they can
do all this fancy stuff offchain.

So, one of the ways I like to describe it is that a channel factory is kind of
like LN for LNs.  So, it's an offchain payment system for offchain payment
systems, and it has this really powerful efficiency boost.  It doesn't scale
perfectly.  One of the problems you get is that if one participant in the
factory becomes unavailable, then the other people in the factory are limited in
what they can do and may need to go onchain and then lose a lot of the
efficiency benefits.  So, there are some trade-offs there, but it's this really
powerful idea.

Taking a step back, one of the things John Law did, it was about a
year-and-a-half ago, he proposed a consensus change, called Inherited
Identifiers (IIDs).  This was an interesting idea, but when developers reviewed
it, they had a few pieces of feedback for him.  First of all, all consensus
changes are hard.  We think we could probably do IIDs as a soft fork, but even
then it would be a particularly hard type of soft fork to do, because it would
change what state we tracked for the UTXO database.  And doing that is hard for
nodes that upgrade long after the soft fork happens.  It was a challenging
change to even think about and we think we can probably do a lot of the things
that he proposed with a different soft fork, the ANYPREVOUT (APO) soft fork,
which doesn't require any invasive changes to the UTXO set, so it's an easier
soft fork to contemplate.  Also, it had some development behind it at that
point.

So, John Law, I think he took that feedback at heart, I don't know for sure, I
don't have a lot of conversations with him.  But he came back with a way to
accomplish a lot of the benefits that he had proposed for the IIDs, to
accomplish those benefits without a soft fork.  And the mechanism he used for
that is something he developed, called tunable penalties.  We did cover this in
the newsletter, but I don't think I gave it enough attention back then when he
first proposed it.  A lot of this stuff is just really hard for me to think
about.  You kind of need to have a state machine in your head to consider all
these possible outcomes in any sort of channel design.

I remember reading the first LN paper and it just really hurt my head!  It
wasn't because of Joseph Poon and Tadge Dryja's writing, it was just because
considering different potential outcomes is not something I think the human
brain, or at least my human brain, is good at.  So anyway John Law came back
with this tunable penalties mechanism and the main feature of it is the fact
that the penalties in any particular state can be tuned or adjusted by the
participants.  So, if you want to have one state that has a small penalty if you
put it onchain, when it becomes an outdated state, you can do that; or you can
tune the penalties and make a really high penalty.

When we first covered it, I didn't really see a huge benefit of that.  I think
there is a benefit and maybe we'll cover it a little bit later, but what he also
did in this mechanism, and he didn't build it into the name and so maybe it
didn't get enough attention, was that he separated the transaction that pays the
penalty from the transaction that controls the shared funds in the channel; this
is actually a really powerful feature, because it means that unlike the current
LN mechanism, it can scale to more than two participants quite easily.

In the current LN mechanism, the penalty for putting an old state online is that
you lose your share of the channel funds.  And to do that with two people is
really easy, because one person messed up, the other person gets all the funds,
so it's winner takes all.  But to do that with say three people, it's a lot
harder, because you don't want the one person screwing it up to mean that an
innocent party loses funds to the other party, the third person.  So, Law's
tunable penalty mechanism, with what he calls separate control and funding
transactions, has this nice advantage of allowing multiple participants.

Now, this week, what he described was an additional benefit of this, which is
that in existing LN channels, if you have a channel with somebody who is
unavailable, you can't route funds through that channel; offline, there's
nothing you can do.  And this also applies to channels open within a channel
factory.  And we expect a lot of LN users to be offline, they're going to be
people using self-sovereign mobile wallets, and so they're just not going to be
online when their cell phone is offline, or is doing some other task, or
whatever.  That kind of sucks for people who always have online routing nodes,
as they can't use their capital efficiency, and it means that they're going to
have to charge higher fees when they do route with those channels.

So, what this week John Law described was that if you open channels in the
channel factory based on tunable penalties, you get those nice, offchain
efficiencies.  Again, ten people can open four to five channels for only
slightly higher than the cost of opening one channel.  But you can also combine
the channels within that channel factory into these multiparty channels, so say
three party channels.  You could have a channel between Alice and Bob and Carol.
And if Alice and Bob are always online, they can continue routing funds between
them, even when Carol is offline, allowing them to forward funds across the LN
at all times.  So, it's just this really nifty idea here for improving capital
efficiency on the LN.

Now, I don't think this is actually specific to John Law's construction of
tunable penalties.  I think you could also get this efficiency with something
like eltoo, which is another proposal for changing LN's design to allow multiple
parties to cooperate.  The thing about eltoo is that it requires a soft fork,
something like SIGHASH_ANYPREVOUT; whereas, John Law's design for tunable
penalties doesn't require any consensus changes to Bitcoin, it's something you
could theoretically do today.

So, that's basically the idea in the newsletter this week.  Because we didn't
give tunable penalties enough coverage when it first came out, I've actually
gone through and tried to explain how the basic mechanism works, and then tried
to show these advantages, although it gets really hard to illustrate that when
you have a whole bunch of participants in the channel; the number of states
there are, it just grows a lot.  It doesn't grow crazy in John Law's design
compared to say just taking the current LN design and extending it to multiple
participants, but it grows a lot.  So, I'll stop talking now and see if you guys
have any questions.

**Mike Schmidt**: I have a question that folks may be thinking, listening to
this, which is we're using the term "channels" and "LN" and "channel factories".
Are these channels that are being created within this multiparty contract the
same thing as -- is there interaction between this multiparty contract and its
channels and the broader LN channel ecosystem?

**David Harding**: Yes, absolutely.  So, John Law's mechanism supports both the
current mechanism used to route funds through the LN, which is called HTLCs,
Hashed Time Locked Contracts, and I don't see any reason why it wouldn't support
the proposed future mechanism for LN, which is PTLCs, Point Time Locked
Contracts.

So, if you today had a channel outside a channel factory, so Alice and Bob have
a channel today and Bob and Carol have a channel today, just your standard
channels today, Alice can route a payment to Carol through Bob, because both of
them have channels, Bob knows all his funds within his two channels; he can
forward a payment for Alice to Carol.  So now, if one of those channels is in a
factory, let's say the channel between Bob and Carol is opened in one of these
factory channels, and it uses Law's construction, or it uses eltoo, or it uses
something else, as long as Bob trusts Bob, he can forward payments from Alice to
Carol.  So, the functionality of the LN at its core is exactly the same.

There are some changes that would need to be made.  Right now, the LN protocol
expects all channel announcements to correspond to a specific UTXO in the UTXO
set.  There are proposals for a version 2 channel announcement protocol, and in
particular Law calls out in his paper a proposal by Rusty Russell that would
break that link between a single onchain UTXO having to exactly correspond to a
channel funding, and that would be necessary for any type of channel factories
and for several other proposed improvements to LN.  So, there would need to be a
few changes to the LN protocol to support this, but it's basically compatible
with the existing LN protocol.

**Mike Schmidt**: Excellent, Dave, and thank you for walking us through the
overview.  Murch, I want to give you an opportunity to ask any questions as
well.

**Mark Erhardt**: I was just thinking about how the asymmetry that is being
introduced here at the starting of the unilateral closure, rather than in the
funding transaction is interesting and reminds me of something that AJ Towns
wrote in December, I think.  So, for eltoo, there is this alternative variant
that is being proposed, called Daric and there's some discussion which parts of
that are necessary, and it will prove the idea of LN symmetry.

So, with the thing that AJ mentioned in that context was that you could have a
commitment transaction where the outputs of the commitment transaction are
larger than the inputs for the predefined part, so that the initiator, the one
that actually publishes the commitment transaction to the chain, would have to
bring another input to raise the input side of the transaction to the level that
it can actually only create the output.  Then there would be an attached
mechanism at the end that makes sure that if it was an honest closure, the
additional money that went into the commitment transaction goes to the right
party.

I'm wondering, maybe this is too deep, but is there a big benefit with having
these separate state transactions versus having a mechanism where you just need
to add more funds on the input side to a commitment transaction; because having
more funds added was still a symmetric design?

**David Harding**: I'm not sure I have a complete answer for that, it's
obviously something I would need to think about, we probably all would need to
think about.  But my gut reaction here is that it sounds like one of the
problems trying to be solved by both of these things is that eltoo by itself
doesn't have a strong penalty mechanism.  It has a cost in the form of
transaction fees that need to be paid by somebody putting an old state on chain
which they will not recover if the correct state is put on chain.

But besides that, eltoo by itself doesn't have a penalty mechanism and some
people think it should.  The current LN protocol has a very strong penalty
mechanism.  And for eltoo, if you're talking about a channel with a lot of funds
in it, and if transaction fees are low at that time, it's possibly rational to
try to put an old state online, just in case your channel counterparty or
counterparties just aren't paying attention.  So, you might want to have a
stronger penalty mechanism.

As for making the state symmetric or asymmetric, depending on how many state
transactions you want to manage, I think the advantages here are the same.
Eltoo is a lot better at minimising the number of states that need to be tracked
by parties than tunable penalties.  But tunable penalties is something that can
be done today without a soft fork.  So, I think the trade-offs there are, do you
want to wait for something like SIGHASH_ANYPREVOUT, or do you want to start
playing with this today; do you want to have something closer to the ideal
construction; or, are you willing to just manage multiple states more?  That's
my quick thinking on that.

**Mark Erhardt**: Yeah, I think two points there.  One is of course, while on
chain when we change the protocol, everybody needs to upgrade and there is
almost never an opportunity to get rid of things that were allowed previously
because people might have pre-signed transactions that depend on some mechanism
that was permitted at that time.  And if we forbid things that were popular or
fathomably used, we might essentially make people unable to access their funds.

But on Lightning, the protocol is more live because all of the primitive
building blocks of the LN are just the channels between two people, and if both
of those users have upgraded their software, they can use a different mechanism
to update between each other, maybe even while participating in an overarching
multi-hub payment that uses an older protocol.  So, there is an argument to be
made here that you could have this intermediate step with tunable penalties
before even APO can play around with channel factories, without actually making
everybody needing to commit to supporting this forever; that's one thought I had
here.

The second one, it took me a while to figure that out, but with LN symmetry and
the cost of closing a channel unilaterally, if a channel partner is trying to
close the channel, they will need to broadcast an update transaction either way.
And whether they broadcast an old one or a new one for them, is the cost the
same, because they're forcing the other party to broadcast another update
transaction to overwrite the state?  So, by broadcasting an old state, they
exactly have to broadcast one update transaction and the other party is also
forced to pay something.

So, originally I thought that we don't really need a penalty mechanism, because
there are the fees that need to be paid by the parties.  But after realising
that, I noticed that there is absolutely no extra cost for the attacker and
that's an area to broadcast an old state, except for the social cost of being
recognized as someone that tried to cheat.  So, in that regard, I came around to
there needing to be maybe at least a small penalty in order to incentivize good
behaviour.

**David Harding**: That all sounds correct to me.  I think we could probably
make the minutiae of whether or not there's a cost for the attacker.  Some of
that is opportunity cost, so if you expected a channel to close in the mutual
closed state, so not a unilateral state, and the expectation that the fees would
be shared there, but the attacker closes in a unilateral state and pays extra
fees, then they are paying some fees.  But we're talking half of the fees there
maybe, or maybe something more than half, I don't know.  And again, the fee
rates are low, it's just not a big cost.  So, I think there's a chance that
we're going to want penalties.

Just for context here for the listeners, there are a number of other mechanisms
being built on LN today that kind of expect there to be penalties, for example
stateless backups and whatnot.  So, one of the things LN nodes are experimenting
with now is that every time you reconnect, you re-establish a connection to
another LN node, it sends you a copy of your backup state.  And if there's no
penalty in the protocol for closing a channel in an old state, then there's also
perhaps no strong incentive for them to send you a correct backup state, because
you're not going to just close the channel.  The longer we go with the current
mechanism of LN penalty, the more we might depend on penalties in the protocol.

As for your comments on upgrade, I think those are just spot on.  Is a pretty
strong live protocol the way we think everybody is using it today?  I'm not sure
that would be the case long term.  One of the other benefits that John Law has
proposed for tunable penalties is what he calls a watchtower-free design.  And
the way he accomplishes watchtower-free is that he allows the enforcement
mechanism to only be used perhaps months or even longer after a channel is
closed onchain.  So, if you're a mobile user, all you need to do is remember to
start your phone, open your Lightning app once every say three months, and that
way you don't need to have a watchtower that's constantly monitoring your
channels for you.  And if we get to a design like that, which is a very nice
design feature, then Lightning becomes less of a live protocol, especially if
people start pulling that out to years, we might have to think a lot harder
about changing the protocol in a way that prevents old nodes from being able to
fulfill their duties.

**Mark Erhardt**: One thing that comes to mind here is of course that there is
an opportunity cost attached to having funds locked up into a multiparty
construct for a long time that cannot move.  So, one of the downsides that comes
up in the context of mobile client wallets for Lightning in general is that they
are less useful for routing, and thus may be more expensive for LSPs to
maintain, because they're putting up some of their funds in order to maintain
this channel that they can't use for other things, although the counterparty is
essentially offline most of the time.

So, that's one thing that pops into my mind when I hear about multi-month
periods in which a channel owner doesn't even come online; who would be the
counterparty of them and how would they need to be reimbursed for their
opportunity cost in order to make that happen; and is that then still an
attractive offer to the mobile client?  I think there's a few interesting
thoughts.  There's more to think about in the long term whether that's going to
be adopted, in what form and for what use cases.

**David Harding**: So, it's kind of interesting in the context of this week's
news item, which you just raised.  I've actually sent John Law an email off the
mailing list to try to confirm this, but I believe that his watchtower-free
design, so the design that allows a channel to only be settled, to finally be
settled, months after the closing has started onchain, so allowing your mobile
node to stay offline for potentially months, is compatible with the multiparty
channel design that he's described in the item from this week's newsletter;
which means that you could have a channel between dedicated user, Alice,
dedicated user, Bob, and mobile user, Carol, that would allow Carol to
potentially be offline for months, but allow Alice and Bob to continue routing
their funds during that multi-month period when they're offchain, because Alice
and Bob wouldn't know the whole channel state and they would be able to route
between those, even though Carol was offline.  So, I think it could
significantly reduce the opportunity cost of a channel being offline for a long
time.

Now, while Carol's offline, Alice and Bob wouldn't be able to rebalance their
funds with other channels, they wouldn't be able to initiate onchain spends, so
it wouldn't be perfect, but they would be able to continue forwarding funds over
LN for their portion of the channel.  So, I think it could significantly reduce
the opportunity cost, and maybe partially address your concern here.

**Mark Erhardt**: Yeah, I hadn't actually considered that we now would be in a
multiparty universe where we don't have a bilateral string of beads, where we're
just pushing the beads back and forth, and even if there's a bunch of beads on
my end, I can't use them.  But there's a two-dimensional allocation on a
triangle, and that's a very good and interesting point.  I think my brain's not
quite hurting yet, but I haven't thought about it enough yet!

**Mike Schmidt**: Murch, you mentioned you haven't thought a lot about this yet,
and we did note in the newsletter that so far, this proposal as well as some of
the other proposals that John Law has put out, while creative, haven't
necessarily garnered a ton of feedback from the community.  I realize they're
creative ideas and maybe take some time to digest, but I'm wondering if either
of you can think what the reason is for the lack of dialogue is this?

**David Harding**: I can start on that, which is that writing this section of
this week's newsletter took me about 20 hours.  For me, it was a really hard
idea to really wrap my head around.  And I don't think this is something about
John Law's writing style, I think this is just a fundamental feature, at least
for me, of payment channel design, which is that you have to think through all
these states and it's just not how my brain works, and I think that John Law's
putting these ideas out there to a bunch of people who are already busy building
LN.  They're working on short-term things, things that are going to have big
advantages to users in the short term.

What John Law's talking about here is something that could be huge, but is also
very long term.  So, I just think this is a matter of people being busy and this
being something that's hard to understand.

**Mark Erhardt**: Yeah, I can second that, in the sense that I was pretty busy
with BitDevs and things like that this week and when I saw on Monday the size of
our newsletter, I actually realized that I wouldn't be able to get around to
review it this week, especially with these further out-there ideas, the amount
of time that you have to put in to even enter the conversation; and then also,
the amount of time and effort it would take to put it into the framework of the
existing things make it sometimes hard for things to be considered.

So for example, we are talking a lot about mempool in the last years with v3 and
package relay and ephemeral anchors, and so forth.  In the end, those ideas are
fairly simple, but to implement them in Bitcoin Core and to update the network,
the transaction propagation and things like that, is still a multiyear effort
already, just because mempool is such a central part of how the Bitcoin software
is put together.  Something like this proposal that fundamentally changes how we
set up channels, how we think about channel state, how we think about
announcements, how we manage backups and communication around them, I think
we're now, what, eight years into getting Lightning up and running, five years
or so since clients have been published and at least been on testnet, and the
complexity of LN is way higher than onchain, but it's still I think quite a bit
simpler than what we're talking about here with John Law's proposal.

It's just a huge, upfront cost, a steep investment, before you gain all these
benefits, and that might make it not the first priority item for people to
review.

**Mike Schmidt**: That's fair.  I think what you guys are trying to say is that
there's a complete lack of innovation and ideas in the Bitcoin development
ecosystem.  Dave, thanks for joining us for that.  You're welcome to stay on and
help us with the remaining sections of the newsletter, which would be great; but
if you have other things to do, you're welcome to drop off as well.

**David Harding**: I'll stick around for a bit.

**Mike Schmidt**: Great.  The next section of the newsletter this week involves
selected questions and answers from the Bitcoin Stack Exchange.  So monthly, we
go through the Bitcoin Stack Exchange and look for interesting questions and
answers to highlight for the Optech audience, and this week we have five of
those.

_Why isn't the taproot deployment buried in Bitcoin Core?_

The first one is, "Why isn't the taproot deployment buried in Bitcoin Core?" and
this was actually a question that I asked on the Bitcoin Stack Exchange that
came about as a result of some discussion that Murch and I had on a previous
Spaces, where we were covering Inquisition.  And one of the changes that was
part of a PR was burying taproot, and that was being done presumably because
taproot hadn't been buried in Bitcoin Core.  So, I was curious why the taproot
deployment wasn't buried in Bitcoin Core, and there was a PR that at some point
was opened to do that, but then was since closed, so I was curious what was
going on there and what was the rationale for not doing that yet.

Murch, maybe it would make sense to define what is "burying taproot"; what does
that mean to bury a deployment?

**Mark Erhardt**: When we make a soft fork change of the consensus rules, we're
making the rules tighter.  We are enforcing more rules about what can be done
with blocks, so essentially the possible space of what blocks can be is made
smaller.  If all blocks that preceded the activation of the new rules actually
already complied to those rules, we can just say, "What if we pretend that this
rule has been around forever?"  And if we do that, we can just enforce the same
ruleset from genesis, instead of having many blocks along the history of the
block chain where we start enforcing new rules.  From _that_ rule on, we are
enforcing that blocks have to have version _this_; from _this_ height on we're
enforcing segwit rules; from _this_ height on, we're enforcing taproot rules.

So, we would have way more complex block validation if we had all these special
cases; we have to check what the height is, which of the rules are active.  So
instead, we bury deployments and we just say, "All of these rules count from
genesis, but if there are any violations of the rules we hardcode, at that
single height there's a special rule, and we allow the transaction anyway".  So
for example, for taproot, I believe there are exactly four transactions that
were spending the segwit v1 outputs before taproot activation, and they were
spent in an anyone-can-spend (ACS) style, because the rules of taproot weren't
enforced yet.  OxB10C has a great article on those transactions.  So, I think
those transactions are hardcoded as exceptions, but otherwise we're now
pretending that taproot was always active.

**Mike Schmidt**: Since taproot is not planned to be buried, at least based on
Andrew Chow's answer to my question, why are the deployments of segwit,
CHECKSEQUENCEVERIFY (CSV), etc, buried but not taproot then?

**Mark Erhardt**: I can disagree with the premise of that question.  I think
that what is not buried is, if you call getdeploymentinfo, you're still learning
the activation height from taproot and the deployment parameters, but we're
actually enforcing the rules since genesis.  So I would say that it is buried,
it's just that we're not also pretending that the activation date was genesis.
For other stuff, so for example with CSV, I think you need to have version 4
blocks and actually every single block before that was not version 4, or not
every single, but most blocks were not version 4.

So, burying it in that case doesn't make sense, because a rule actually was
broken a lot before it got introduced, and then just starting to enforce it at
that height where it started being active makes more sense.  I hope I addressed
your question.

**Mike Schmidt**: Dave, do you have any thoughts on buried deployments?

**David Harding**: No, I think I'm actually more confused about the state of
taproot being buried or not than I was when we started.  I'm going to look into
this more myself.

**Mark Erhardt**: Thanks, and please report back, because I think I'm a little
confused now too.

_What restrictions does the version field in the block header have?_

**Mike Schmidt**: The next question from the Stack Exchange that we highlighted
this week is, "What restrictions does the version field in the block header
have?" and, Murch, I believe you asked this and answered this, so maybe I'll let
you explain the question and some interesting titbits from your answer.

**Mark Erhardt**: Somebody was asking me why the blocks in general have such
weird versions, and they were asking how they could make the version of Bitcoin
blocks human readable.  I was confused by that question, because it seemed sort
of like an XY question, and the more underlying question is, why are the
versions so weird in the first place; and what version field values are
permitted?

To extend a little more on that, miners are using a technology called overt
ASICBoost and they are basically using the version field as an additional source
of entropy.  So, as hopefully many of you know, when we are asking the miners to
find a new valid block, what they do is they build a block template where they
decide what transactions are going to be in that block, the relevant fields of
the block header from that.  The difficulty statement is fixed, they have a
merkle root now at this point because they've built the whole tree of
transactions, and there are other fields that are flexible that they can change
in order to have many different variants of the same block template, so-called
block candidates, and each of those they flow through the hash function.  If
they find a very low hash, they might have found a valid block.

So, the nonce field that was originally intended to be the main source of
entropy in the block header is slightly over 4 billion possible values.  And
with the network doing something like a few hundred sextillion tries per block
being found, you can imagine that they're exhausting a range of just a few
billion very quickly, and single machines actually do this in I think less than
a second now, so they need additional sources of entropy.  One of the first
approaches to do that was, "How about we just fiddle with the timestamp on the
block, so every time we exhaust a nonce, we do time-rolling and we increment the
timestamp by a second?"  Or alternatively, people started putting different data
into the coinbase transaction.  So, there's a field that we refer to as the
extraNonce in the coinbase input where people are putting arbitrary data,
because as soon as you change even one bit in the transaction data, the hash
changes.  But then they have to rebuild the whole left flank of the merkle tree
to get a new merkle root.

Another field that is relatively unconstrained is the version field.  So, people
that use overt boost are essentially just using the version field as another
nonce where they can have arbitrary bits flipping around.  And every bit that
they gain access to additionally doubles the amount of block candidates that
they can get out of a template.  And if they change the version field, they
don't have to recalculate any of the merkle tree to get a new merkle root.

So, in this answer, I look at what values are permitted in the version.  So
first nVersion is a 4-byte little-endian signed integer, which means that the
numbers in the integer are presented, or I should say that the bytes in the
integer are presented in a confusing order maybe for some people.  And the most
significant byte is the last one and the least significant byte is the first
one, so I explain that a little in my answer.

Then I explain what a version 4 block would have as a value.  So, in the first
byte out of the 4, because it's the least significant byte, you would have the
third bit from the end set to 001 to express a 4.  But then, I also look at
which bits are set for BIP9 and what it would look like if you are using the
version field to introduce more entropy into the block header, and have an
example from a block that was mined presumably using overt ASICBoost with a
bunch of bits set.

If you're interested in that sort of thing and how the version field is
restricted and what values appear, you can look at this one.

**Mike Schmidt**: Excellent walkthrough, Murch.  Dave, anything to add?

**David Harding**: The only thing I would add is that I think there's actually
two different things happening here.  One is that there could be covert
ASICBoost going on using the version bits field, I think that's possible; but
there's also just using version bits as an extended nonce, and those are
actually two different things.

So, the way ASICBoost, whether it's covert or overt, works is by kind of, I
don't know how to describe this, but rearranging how you build the hash, the
order of operations you need to perform to pull in the hash in a way that can be
done in hardware more efficiently in some cases.  But you can also mine without
using ASICBoost, and it can be more efficient to do that just putting all of
your nonce into the header, rather than using a change to the merkle root, which
would require updating the coinbase transaction.

There actually is a BIP, BIP320, that specifies which version bits are
recommended for -- it calls it general purpose use, but really for miners to
adjust.  So, that's a subset of the bits that Murch identified as being possible
to use.  The reason we have BIP320 is so that the other bits don't get modified
when we're trying to do soft forks, or whatnot.  To be fair, BIP320 is not
universally agreed-upon by Bitcoin developers, some people don't like that it's
used.  I don't know, I'm not going to get into that debate.  But I just wanted
to say that there's using the version field as an extra nonce, as an additional
nonce field, or you can use it for overt ASICBoost.

**Mark Erhardt**: Thank you, yes, you are completely correct of course.  So,
ASICBoost requires you to sort of have a collusion I think in coinbases, or let
me not try to explain ASICBoost right now, I'd have to brush up on it.  But
yeah, thank you for correcting me, is all what I'm trying to say!

_What is the relation between transaction data and ids?_

**Mike Schmidt**: The next question from the Stack Exchange is about the
relation between transaction data and ids, and this was something that came up
in two different questions in the past month on the stack exchange.  So, I
thought if folks were having questions about that, that we could highlight that
here.  And Pieter Wuille answered both of them, explaining that the legacy
transaction serialization format is covered by the txid identifier, which does
not include any witness data; and the witness extended serialization format is
covered by wtxid as well as the hash field.  If folks are using RPCs, you may
see these fields.

Then sipa also pointed out in a separate answer that in the future, if there was
additional data beyond the witness extended serialization data, that
hypothetical data would also be covered by the hash, so you could potentially,
in that future hypothetical scenario, have three different types of identifiers
for a transaction.  Murch?

**Mark Erhardt**: Yeah, I wanted to tie this back to something that we talk
about in the context of segwit.  So, one of the main motivations to do segwit in
the first place was something called third-party transaction malleability.  So,
what Lightning requires you to be able to do is to write a chain of transactions
that build on top of each other before they're confirmed.  You need to be able
to have a commitment transaction whose output can be spent by the penalty
transaction in case it gets used out of order.  And, in order to be able to have
a reliability penalty transaction, you need to know that the txid of the
commitment transaction does not change.

Before we had segwit, there were various ways how third parties could malleate
transactions without changing the meaning.  For example, one of the simplest
things was you could flip the S-value in one of the signatures, because the
negative and the positive value both corresponded to the same coordinate in the
signature.  So, both were valid, but one of them was standard and one of them
was non-standard, so a miner could do this and still include the transaction.
The transaction still sends the funds to the same recipients, but the txid of
the transaction was different than before, so it would break all the downstream
children and descendants of that transaction, which would not have allowed for
us to have penalty constructions like we're used to now with Lightning.

So, segwit introduced specifically that the data that could get malleated by
miners, or anybody that could get a non-standard transaction, would not be
covered by the txid anymore, and actually split off into the witness structure
of the transaction.  But we still need a way to be able to commit to the
complete transaction, because if people were to malleate data in the witness, we
might still have, for example, an invalid malleated transaction, and we don't
want users to be able to poison other users, "Oh, I've seen that txid, it has an
invalid witness so I'll never accept that txid again".  And then, when it comes
with a block, we might, for example, have a DoS attack.  So, we have those
separate commitments.

The txid commits to the torso of the transaction, the non-witness data, which
specifies which funds get consumed and which funds get created, in the sense of
which UTXOs get used up and created.  And we have a separate commitment that
commits to the whole transaction, including the witness structure, so that there
can be no shenanigans with what is being propagated on the network, what is
included in blocks, and we commit to the wtxids of all transactions included in
a block in the so-called witness commitment, which is an OP_RETURN output on the
coinbase transaction.

**Mike Schmidt**: Murch, the "torso" of a transaction, I don't know if I've
heard that term before; I like it.

**Mark Erhardt**: Yeah, I made that up just now!

**Mike Schmidt**: Oh, okay, I wasn't sure is that was formal jargon.

_Can I request tx messages from other peers?_

The next question from the Stack Exchange is, "Can I request tx messages from
other peers?" and this person asking on the Stack Exchange was trying to use the
bitcoin-cli to request transaction information from peers.  Murch, I thought the
whole reason I'm running a node here is to connect to the P2P network and get
transaction and block information from my peers.  Why can't I request a
transaction?

**Mark Erhardt**: Well, so it turns out that it is costly to look up arbitrary
transactions from the block chain if you don't have a transaction index.  So,
most nodes don't run with the transaction index, it's an optional feature.  And
if we also look at unconfirmed transactions, not every node might have every
unconfirmed transaction.

So, if you permit other users to ask for arbitrary transactions (a) you would be
leaking whether or not you have a transaction index, if you can reply easily,
(b) it puts an onus of additional work on the full node that you're requesting
data from, and (c) it might be another privacy leak in being able to fingerprint
nodes by giving transactions only to specific nodes and then checking whether
they've got them already.  So you could, for example, try to get a read on what
the topology of the network is, who's propagating what transaction to whom, and
so forth.

So generally, we only permit peers to ask for transaction data that we have
previously announced to them, either in the form of an inventory announcement,
or in the form of a block announcement.  I think Dave might actually have some
good takes on that one.

**David Harding**: Well, first of all, this is actually what a number of other
protocols that are built on top of Bitcoin do.  The main one I'm familiar with
is the Electrum Server protocol.  Basically, Electrum Server is backed by a
Bitcoin full node and it goes through every block and it indexes every
transaction by several pieces of data, namely what address it pays to, or
arguably spends from.  But in the context of Bitcoin Core, there was actually a
protocol a number of years ago, BIP64, that allowed the retrieval over the P2P
network of any UTXO stored in the Bitcoin Core's UTXO database, which is
something it has to store; Bitcoin has to have a UTXO database say in something
like Utreexo, which I think we talked about on this show a few weeks ago.

One of the arguments against that was that it was untrusted data.  Now, it
doesn't have to be untrusted in the case of transactions, because you can also
send a merkle proof for the block that includes the transactions, and in fact
Electrum Server protocol does this for every transaction it sends back to the
user.  But in general, we don't want to serve data to users that they can't
trust, so there's just some more complexity to serving transactions, in addition
to the points that Murch raised about it requiring a lot more storage on full
nodes.  And even full nodes that agreed to that would potentially be able to
collect privacy-sensitive information about the people who've requested those
transactions.

**Mark Erhardt**: Yeah, I wanted to add one more point to the UTXO example.  So,
it's easy to prove that a UTXO was created, by showing the transaction that
created the UTXO and providing the merkle proof.  But it's actually really
difficult to prove that it has not been spent since, and that actually ties back
to a conversation we had two weeks ago, with Calvin Kim, about Utreexo, which is
a protocol that essentially is doing exactly these sort of proofs, which UTXOs
still exist, which that transaction can validly spend, and all that.  So, if
you're interested in that topic, check out our Recap two weeks ago.

_Eltoo: Does the relative locktime on the first UTXO set the lifetime of the channel?_

**Mike Schmidt**: Last question from the Stack Exchange involves eltoo, and the
person asking the question asked, "Does the relative timelock on the first UTXO
set the lifetime of an eltoo channel?" and this person includes a diagram from
Richard Myers, which is a nice visual.  But the question I guess is, due to the
fact that there is this example construction of a transaction that has a timeout
that essentially would cap the duration of the channel itself in eltoo, would
that mean that all channels in eltoo have a finite lifespan, based on what that
locktime is?  Murch, you answered the question, so I'll let you answer the
question.

**Mark Erhardt**: In the first diagram, or the description of how the LN
symmetry protocol would work, they indeed have a transaction that has a limited
lifetime, because the output of the setup transaction is spendable by the
settlement transaction that belongs to the setup, and there is a CSV, so a
relative timelock there, that eventually makes the settlement valid.  And
actually, if you continue reading the eltoo paper, in section 4.2 it improves
upon its initial naïve design and adds another trigger step.  The trigger step
basically allows you to have the relative timelock of the settlement transaction
be tied to the previous publication of the trigger transaction.  So, the trigger
transaction is always valid, but it has to be explicitly broadcast, and then the
relative timelock only starts after the trigger.

The trade-offs here are, to perform a unilateral closure with this LN symmetry
design, you first have to publish a second additional transaction, a trigger
transaction; but the benefit you gain is that your channel no longer has a
limited lifespan in the first place, because the settlement transaction
eventually will become valid and the original channel opener will be able to
reclaim their funds.  So, all the updates that happen to the channel since would
at that point need to have been written to the block chain, or otherwise the
channel initiator would be able to take back their funds.  So, trade-off is
additional transaction, but unlimited lifetime on the channel.

**Mike Schmidt**: This term "LN symmetry", came up in discussion of the news
item this week.  It came up here and I think it comes up later in one of the
notable code and documentation changes.  Murch, what is LN symmetry?

**Mark Erhardt**: Yeah, that's a fair question.  My understanding is that while
people were working on eltoo, internally they just had codenamed their project
with the two letters, or characters, L2, and it was pointed out to them by
colleagues that this is not a very distinct name for what they're working on,
because we already refer to Lightning as an L2, a Layer 2, technology.  So, they
changed the name to eltoo, the five-letter word, eltoo, which is homophone to
L2.  And I think personally that this is one reason why talking about eltoo as a
protocol is very confusing.  I mean, I guess it's clear from the context, but it
makes it harder to search for, it makes people maybe first think about Layer 2
technologies in general.

So, the Core Lightning (CLN) engineer, Greg Sanders, that is now working on APO
and is trying to really make eltoo happen, has requested that people start
referring to it as LN symmetry.  And LN symmetry is basically the juxtaposition
of LN penalty, so the channel update mechanism that is prevalent on the LN right
now, where if you broadcast an old state, the counterparty can do the justice
transaction and take all funds.  LN symmetry is the eltoo construction update
mechanism, where the commitment transaction is symmetric; you only need to keep
the latest commitment transaction in order to enforce the accurate outcome of
the channel, and there is no toxic state, no toxic backups.

Basically, it's a request by the people that are currently working on trying to
bring about eltoo to call it LN symmetry instead, because they feel that it's a
more distinct name.

**Mike Schmidt**: Understood; same technology, different name, rebranding.  The
next section in the newsletter this week is releases and release candidates.

_Rust Bitcoin 0.30.0_

The first one noted here is Rust Bitcoin 0.30.0, and this release actually is
accompanied by a new website, rust-bitcoin.org, which as part of its content the
other day has a blogpost about release 0.30.0, which is quite informative and it
goes through a bunch of suggested steps when upgrading to this version and walks
through some of the changes in blogpost format, in addition to the release notes
that we link to in the newsletter as well, which include a bunch of API changes.
Murch or Dave, any comments on Rust Bitcoin?

**David Harding**: Not from me.

**Mark Erhardt**: Yeah, I was also just going to point out that in the release
notes section that we link to it, there's a link to a blogpost that sort of goes
into the details.  If you're using Rust Bitcoin, you should take a look at the
blogpost, because it calls out a bunch of things if you're using certain API
calls, how to upgrade or amend your use of those API calls with sometimes new
parameters or a superseding API call.  So, I think that blogpost is probably the
most helpful thing to look at if you're using it.

_LND v0.16.0-beta.rc5_

**Mike Schmidt**: The next release that we highlighted here is the LND
v0.16.0-beta.rc5, which we've had various release candidates for this LND
release over the last couple of months, and we do have folks from the LND team
that do want to come on and give us the nitty-gritty of this release, but they
are waiting for the release to actually be official in order to jump on and
discuss with us.

_BDK 1.0.0-alpha.0_

So, we'll punt for another week on that, which will lead us to the next release,
which is BDK 1.0.0-alpha.0, and Murch and I had on last week Alekos, who is
instrumental in working on the BDK project and some of the bdk-core work that's
been done there recently, that we highlighted in the newsletter last week.  So,
if folks are curious about the details there, I would encourage you to revisit
the Recap from last week, for newsletter #243, to get the details.

_Bitcoin Core #27278_

**Mike Schmidt**: The first PR that we covered this week was Bitcoin Core
#27278, and we referenced a few different tweets which sort of surfaced the lack
of some logging that could be potentially useful in the future.  Murch, I don't
know if you followed along with those tweets as that was happening and some of
the discussions that went around that?  Did you follow that as it was happening;
and if not, maybe we could just walk through the scenario that happened and how
logging could potentially help with identifying some of these potential selfish
mining attacks, theoretical?

**Mark Erhardt**: Unfortunately, I only learned about these circumstances in
hindsight when I saw this appear in the newsletter.  I know that there was
something about a reorg that James observed with bmon, and he noticed that I
believe three blocks were processed at almost the same second.  And what this
ties back to is the timestamp field in the block header is not very reliable.

We are in a distributed network and we cannot make sure that all the clocks are
synced across all nodes in the network.  Some other networks have tried that
before and there's been some downtimes because of that.  So, Bitcoin is actually
very lenient on the timestamps of blocks.  We generally just require that the
timestamp of a new block is higher than the median of the last 11 blocks, the
so-called median time passed, and as a node, we permit a block to be up to two
hours in the future of our local computer's time; maybe it's also two hours in
the future of the median time passed of our peers.  Maybe one of you knows what
the accurate term is.

Anyway, for example, that led to the time-rolling that I mentioned previously,
where miners would just try different values for the timestamp in order to have
more entropy in their block template.  But it also means that even though
timestamps may say a thing, that may not correlate to the exact time that a
block was crafted.  So, one miner a while back would, for example, always have a
30-minute-off timestamp when they found an empty block.  When they found blocks
with transaction data, the timestamp was generally accurate; but when they found
blocks with an empty transaction corpus, because they were still mining on an
empty block right after a new block was found and they had learned about it,
then I think the timestamp was off by 30 minutes.  But that's acceptable to the
network, but weird.

So, there is a distinction between the time that we receive a block, so our node
first learns about a new block in the block chain, and the timestamp that's
actually in the block header.  And I think the main point around the PR here is,
"How about we make our node also keep the information when they first learned
about a block, rather than the claimed time that it was crafted at that is given
in the block?"

**Mike Schmidt**: Dave, do you have anything to augment that?  I know you did
the write-up for this week; maybe some commentary?

**David Harding**: I would take a step back and quickly describe what a selfish
mining attack is.  So, if you're a miner and let's say, just by lucky
happenstance, you create two blocks in a row, so you create the second block
before you've even tried to broadcast the first block.  Well, then you're in
this privileged position, because you know anybody else who creates one block,
you can beat them, you can outrace them, if you just wait to send your blocks
because you have two.  They publish their one, you can send your two blocks and
you can win.

Now, this kind of thing can happen by accident, especially if we have larger
miners on the network.  Once you get above 10%, 15%, you're going to start
creating two blocks in a row some percentage of the time.  And if you
deliberately delay sending those blocks, it's a selfish mining attack.  And this
can also happen accidentally, again because sometimes miners do produce two
blocks close together and a third miner could produce a block at the same time.
But if you deliberately do this, what you do is you're kind of denying other
miners fee revenue.  And even though it seems like a small percentage of fee
revenues being denied to miners, because this is a fairly rare occasion, even if
you're a 30% miner, it can slowly drive the other miners out of the network.  It
increases your relative success rate to theirs, and mining is supposed to be a
low-margin business.

So, selfish mining attacks are really kind of dangerous to Bitcoin and they're
something that we want to detect, whether they happen accidentally, or they
happen on purpose.  So again, what this PR is doing, like Murch said, is trying
to better capture the time when blocks, or the information about blocks, arrives
at our nodes.  So, if we see a lot of nodes receiving multiple blocks in a row
at the same time, especially if they're received at the same time that another
block by an apparently different miner is received, then we have some evidence
that there are selfish mining attacks going on in the network and we can start
trying to take steps to fix that.  What those steps are to fix that, I'm not
really sure.  Selfish mining is not necessarily something that's easy to fix or
we would have fixed it already but again, we just want to have the tools in
place to collect that data.

**Mark Erhardt**: It will just cover another item.

_Bitcoin Core #26531_

**Mike Schmidt**: Yeah, Bitcoin Core #26531.  In the last item that we just
covered, we were talking about logging when a header for a new block is
received, and this is about tracepoints for monitoring events, and specifically
this adds tracepoints for the mempool, which USDT, Statically Defined
Tracepoints were, as a framework, added I think last year or the year before,
and I think it was focused on P2P work, and now there are tracepoints for
monitoring events associated with a mempool.

Murch, maybe a basic question to lead into this is, we're logging certain
information via traditional logging and some information, like here, via
tracepoints; why would we choose one or the other?

**Mark Erhardt**: I guess traditional logging has a couple of issues which is,
if you have too much logging, you'll produce just enormous files at all times
and it can actually slow down the execution of programmes.  So, you definitely
want to give people the ability to modify how much they're logging, depending on
what their needs are.  So, we already have levels of logs for certain areas of
the software, and I think you would need to recompile in order to change what
level you're logging to every time you want to do it.

With the tracepoints, and I'm really a little bit -- well, I'm going from the
top of my head here.  With tracepoints, you have to activate tracepoints once
and you need to have certain other packages installed in order to be able to use
them.  But after that, tracepoints are always present in the code without
getting executed.  And then, you can basically have a hook in your kernel code
and subscribe to certain tracepoints, and only if they're subscribed to, you get
data-logged out.  For other tracepoints, you can have very specific needs
covered and just log certain items.

So for example, if you're interested in coin selection, there might be some
tracepoints that you can just get some information about specific decisions that
your wallet made when it's building transactions; or, with mempool, some people
that are really interested in what the mempool does and what transactions are
propagating when stuff gets replaced, they might be subscribing to only those
mempool tracepoints.  So, they're generally only slowing down the code when you
actually subscribe to them and other than that, they don't write tons of
logging.  You can directly funnel it to other software more easily, you don't
have to parse the log back in.

So, they're a useful tool for people that really want to learn what's going on
with certain aspects of Bitcoin Core.

**Mike Schmidt**: I think that's a good summary.  Thanks, Murch.

_Core Lightning #5898_

Next PR this week is Core Lightning #5898, and it's updating its dependency on
libwally to a more recent version.  We actually covered libwally in our client
and service section of the newsletter last week, in that libwally, I think it
was 0.8.8 release, and its support for taproot, version 2 PSBT, and it sounds
like CLN is now inheriting those capabilities in this latest merge.  Then
there's also a note about support for Lightning on Elements-style sidechains,
like Liquid.  I think there's some nuance in some of the versioning there.  So,
if you're using Elements or Liquid, perhaps look in Lightning as well, perhaps
look into that.  Murch, anything on this CLN PR?

**Mark Erhardt**: I must admit, I'm not intimately familiar.  I know that the
last time I specifically encountered libwally was when they introduced sending
support for P2TR outputs, so support for bech32m, so that was about 0.8.4.  I
guess they must have added a few things since, and I guess Greg would also be
the right person to ask here, but I'm just babbling now, sorry!

**Mike Schmidt**: Yeah, I think there were some new items around BIP340,
taghashes and additional sighash support for APO.  Those are at least a couple
of the items related to the 0.8.8 release that we noted last week.

**Mark Erhardt**: So, I guess this is just stuff that needs to happen in order
to have CLN be able to receive funds to P2TR outputs, and eventually things that
I'm very excited about, like P2TR-based channels, which look like single sig to
everyone else, and maybe also PTLCs.  Yeah, so anyway, I think this is just part
of the schnorrification of Lightning.

_Core Lightning #5986_

**Mike Schmidt**: There's another Core Lightning PR, #5986, which updates RPCs
which return values in millisatoshis (msats) no longer include the literal
string "msat" as part of the result.  So, instead of those RPC fields being
strings, they're integers now, and I guess this is something they've been
working on deprecating for a while.  So, hopefully folks are following the
release notes and adjusting accordingly.  Murch, any thoughts on msats and CLN?

**Mark Erhardt**: A fairly orthogonal one.  So, we had Tadge on the Chaincode
podcast a couple of weeks ago and he brought up how weird msats are, because
they obviously only exist on LN.  We cannot write them to the chain, because we
can only write full sat amounts.  And how they sort of introduce a second class
of Lightning payments, where if you have a very, very small amount of bitcoin
getting routed on LN, we don't actually create the HTLCs, we just sort of
pretend that the HTLC is there and we sort of have a gentlemen's agreement with
our channel partner that this tiny, little amount that we can't even express in
bitcoin transactions actually exists and it's there.

So, there were some efforts at some point to just go by sats, not msats, but I
guess the msat adoption had already started, or progressed far enough that
Lightning ended up using msats, which are purely virtual on this second layer.

**Mike Schmidt**: And for anybody who is listening to the Optech Recap podcast
that we're doing, this show, you would definitely benefit from also listening to
the Chaincode podcast as well, high-quality content there, so I would plug that
for sure.

**Mark Erhardt**: Yeah, thank you.  I must admit, our audience is expected to
have a pretty good technical understanding, but I do hear that people are
enjoying the podcast, so please also let us know when you enjoy our podcast.
Sometimes it feels a little bit like you're talking to an empty room, because of
course we're mostly talking to ourselves up here.  So, if you have reactions,
let us know what you like and that would be appreciated.

_Eclair #2616_

**Mike Schmidt**: Next PR is Eclair #2616, adding support for opportunistic
zero-conf channels, which is a situation where if you peer sends the
channel_ready message before your expected number of confirmations, Eclair will
actually just make sure that the funding transaction looks good and start
treating it as a zero-conf channel.  Murch, one thing that maybe you could help
clarify for me is, if you dug into this, what is Eclair doing to verify that,
that funding transaction is good to go in order to treat it as a zero-conf
channel?

**Mark Erhardt**: I'm afraid I have not dug into this one.  I am reminded of the
news item we had a few months ago, with the swap-in-potentiam.  So if you had,
for example, a situation in which someone had already received funds that are
conditionally linked to the LSP as well as their own wallet, you could have a
construction in which you safely create a zero-conf channel.  Maybe that would
be a use case in which you could have an early channel_ready.  I'm afraid I
haven't read this yet, so I don't want to guess more than this.

**Mike Schmidt**: Dave, do you have comments on this Eclair #2616 opportunistic
zero-conf?

**David Harding**: Yeah, basically what they're doing to check, they're just
making sure that they created the transaction.  So, currently in LN, everybody
who isn't using a dual funding protocol, the channels are created by a single
party, so it can be created by you or it can be created by your counterparty.
And in this PR, Eclair is making sure they create the transaction which means
the other node can't double-spend it.  In that case, there's not necessarily a
good reason the other node would accept that channel early.  In a single funded
channel, all the funds are coming from, as the name implies, a single party, so
the other node is accepting all the risk.  The way they mitigate that risk is by
waiting for six confirmations, or however many confirmations they want to wait
for.

For the local node, for Eclair, if they created the transaction and the other
party chooses to accept it, there's no downside for Eclair, because Eclair can
start sending money through that channel, paying other people, and if the
channel gets unconfirmed, then Eclair can in theory take back that money, so
there's no downside for the Eclair user from accepting these channels early.
This is kind of just an optimisation, if you will, for cases where the other
node is, for some reason, being extra-trusting.

**Mike Schmidt**: Okay, so really the remote peer who's sending this
channel_ready message is the one who's assuming the risk here, because in this
example the Eclair user is the one who can double-spend, not the remote peer, so
there's really no risk to the Eclair user, it would be the remote peer?

**David Harding**: Exactly.

_LDK #2024_

**Mike Schmidt**: Next PR is LDK #2024, including route hints for channels which
have been opened, but which are too immature to have been publicly announced;
again, referencing a potential zero-conf channel here.  And as a reminder to the
audience on what routing hints are for, traditionally is to provide information
to find non-advertised or private channels, you provide some information.  In
the case of a private channel you include that hint in the invoice generated by
the receiver that you've sent to the payer.  So, it sounds like they're using
those routing hints not for a private channel in this scenario, but channels
which haven't been announced yet, which I guess are somewhat like private
channels then in the zero-conf case.  Dave?

**David Harding**: Yeah, I'll just pop in.  We've actually kind of talked about
this a little earlier during the part about John Law and the tunable penalties,
which is that in the current LN protocol, in order to prevent the channel
announcements from being spammed to nodes.  This is how nodes figure out what
routes are available is that everybody announces their channels to all the other
nodes.  In order to prevent spam there, every announcement has to be tied to the
UTXO that created that channel, and there are proposals to kind of reduce that
link.  We still need an anti-spam mechanism, we can't just have everybody
claiming to have a channel with no proof or no cost to them, but we want to
reduce that link and one of the proposals for that is just by still tying them
to _a_ UTXO, but not necessarily _the_ UTXO that funded the channel, which also
has privacy advantages.

But in this case, the protocol says that in order to prevent spam, in order to
announce a channel, it has to be tied to a UTXO with a confirmation depth of six
or more.  And for a zero-conf channel, as the name implies, they don't have six
confirmations.  So, this allows an LDK node to receive a payment through a
channel which can't yet be announced, but which they're probably planning to
announce in the future.

_Rust Bitcoin #1737_

**Mike Schmidt**: Thanks, Dave.  Next PR is Rust Bitcoin #1737, adding a
security reporting policy for the project.  I think a few months ago, Optech had
encouraged best practices with regards to disclosures and it seems like a few
projects in the last month have put up their security reporting policy, which is
good to see.

_BTCPay Server #4608_

Next PR is BTCPay Server #4608, allowing plugins to expose their features as an
app in BTCPay.  I am not a BTCPay user, but I dug into this a little bit and it
sounds like there's two classes of ways to provide functionality to end users,
one is via these plugins, and also apps, and this enables these plugins to
surface to the UI in a "BTCPay app way".  Murch, I don't think you're a BTCPay
user either.  Dave, are you familiar with the distinction between plugins and
apps and how this PR melds the two of it?

**David Harding**: I'm not really that familiar with it, but I'm just going to
make something up and hope it's correct, which is that I think an app is the way
in BTCPay Server of enabling a set of related features.  So, they try to give
you a base user interface that's clean and covers everything your typical user
wants to do.  But then if you want to add more advanced features, you enable an
app and it adds more options and features to the user interface to allow you to
customize how your BTCPay Server works.

This PR allows a plugin to create an app, so it looks like this was created to
allow BTCPay Server to begin cooperating in coinjoins.  So, at the coinjoin
plugin, actually I think there's two of them out there, one for the Wasabi
protocol, and one for, I don't remember what it's called, the one that Samourai
uses.  So, you add a coinjoin plugin and it surfaces an app that allows you to
customize how you participate in coinjoins.

**Mark Erhardt**: Just while you guys were talking, I googled and found the
documentation of BTCPay Server apps, and I thought that maybe I can give a few
examples of what they consider apps.  So, BTCPay Server of course is a tool to
manage merchant functionality to accept Lightning payments, and also onchain
payments, and to manage the invoices and funds around that.  So for example,
they have a Point of Sale (PoS) app, they have a Crowdfunding app, they have a
Payment Button.  It sounds to me like those are larger modifications of how
BTCPay Server runs for a specific setup according to the needs of the merchant.

Some merchants only have an online presence, so they don't need a PoS app; some
people might be using it as a mechanism to receive donations, so maybe they want
the Crowfunding app.  That's just for color, I don't know more than this either.

_BIPs #1425_

**Mike Schmidt**: Next PR is to the BIPs repository, BIPs #1425, assigning the
number BIP93 to the codex32 scheme, and that's the scheme for encoding BIP32
recovery words using Shamir's Secret Sharing Scheme (SSSS), and we had Russell
O'Connor on a few weeks ago, so if you want to dig into what exactly is codes32
and what is BIP93, go back and listen to that show.  I think it was our Recap of
Newsletter #239 that we had him on going into all of the details there, which is
an interesting topic.

**Mark Erhardt**: Also last week, we had the update with the discussion around
having a faster checksum 4, the codex32 scheme that Peter Todd initiated, I
think.

**Mike Schmidt**: That's right.  And as we jump into the last PR here, I'll
solicit any questions from the audience.  Feel free to add either a text
question or comment to the thread that's associated with this Spaces, or feel
free to raise your hand and request speaker access if you have a question or
comment on our discussion today.

_Bitcoin Inquisition #22_

The last PR is to Bitcoin Inquisition, and that's Bitcoin Inquisition #22, which
adds an -annexcarrier option and it allows you to push some data to the
taproot's annex field.  And we note that the use case behind this is the author
trying to do some eltoo work, and also I think ephemeral anchors is part of this
PR, or this PR is a prerequisite for some of the ephemeral anchors that the
eltoo work is depending on.  These are both Greg Sanders' initiatives.  Maybe
one quick question for Dave: I see Bitcoin Inquisition in the notable code and
documentation changes section.  Does that mean Optech is now covering Bitcoin
Inquisition moving forward?

**David Harding**: We are now covering it moving forward.  I've actually been
covering for about a month now.  So, the way that we do this section is I go
through all the commits in the listed projects every week and look for anything
notable.  So, I added Inquisition to my script for doing that about a month ago.
They don't have a lot of merges over there, which is probably okay, but this was
the first one that came up that I thought was notable.  And I think some of the
discussion on this PR was about, "Oh my goodness, we can also push data in the
annex, and wouldn't that be terrible if people start putting their, what do they
call those; NFT things into the annex?"

**Mike Schmidt**: Inscriptions.

**David Harding**: Inscriptions, yeah.  So, that was a concern for the audience.
Bitcoin Inquisition is a fork of Bitcoin Core that focuses just on signet, the
test network.  This is not an immediate concern for Bitcoin, if you will.  It's
not clear to me we'll even ever carry the -annexcarrier option over to Bitcoin;
it might just be there for testing.  But yeah, that's what's going on, and it's
the setup for some additional work that they're planning to get into Bitcoin
Inquisition to health-test the SIGHASH_ANYPREVOUT change and maybe some other
changes to the network.

**Mike Schmidt**: Murch, perhaps you and I can get together and start a company
that is competing to the ordinals inscriptions, and we can use the annex in the
future; what do you think?

**Mark Erhardt**: I've done a lot of research about that topic in the last 48
hours, so I'm well set up, but maybe not very enthusiastic!

**Mike Schmidt**: Murch, it sounds like you have something to say before we sign
out?

**Mark Erhardt**: It's mean, but I kind of want to spoiler something for next
week; I assume it's going to be in next week's newsletter.  So, the MuSig2 BIP
finally got merged to the BIPs repository and it now has the name BIP327, and I
think it's final.  So, all of those magical things that we've long been talking
about for taproot, with the aggregated public keys, where we have a k-of-k
setup, there is now a formal specification that's been adopted and merged.  I
think we will be seeing more awesome wallet features that are based on that.

I've had this conversation a few times in the last month where people are like,
"Nothing cool ever came out after taproot got merged", and I think just the
amount of time that goes into those things, getting them ready, getting them
really tested rigorously, and then downstream projects, wallets and products
adopting that sort of change, it just takes a little longer than the immediate
attention span that one might have when they first hear, "Oh, taproot will get
the multisig".  This is now actually the spec for how to exactly do that.

I wanted to also point out there was an interesting blog post by OxB10C, who's
been looking at some patterns of interesting IP addresses that appear on a ton
of different nodes' connection lists.  And if you're curious about network
topology topics, if you haven't seen it swim through your Twitter stream yet,
you might find that an interesting blog post; check it out.

**Mike Schmidt**: Yeah, thanks for calling those to our attention.  The Recap
Podcast is now a breaking news outlet; we're breaking news: MuSig2 has been
merged!  All right, well thank you all for joining us for this Newsletter #244
Recap.  Thank you to my co-host, Murch, thank you to Dave Harding for joining
us, and we'll see you next week for Newsletter #245 Recap.  Thank you all.

**Mark Erhardt**: Yeah, thank you very much for joining, Dave, that was very
nice.

**David Harding**: Thanks for having me, guys.

{% include references.md %}
