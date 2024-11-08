---
title: 'SuperScalar Deep Dive Podcast'
permalink: /en/podcast/2024/10/31/
name: 2024-10-31-deepdive-superscalar
slug: 2024-10-31-deepdive-superscalar
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by ZmnSCPxj to discuss his [SuperScalar
proposal][superscalar delving].

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-9-31/389033095-44100-2-c3a12b9495a9b.m4a" %}

<br />
<ul>
    {% include functions/podcast-bullet.md timestamp="0:40" slug="#why" podcast_slug="#why" title="Why a deep dive?" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="1:58" slug="#overview" podcast_slug="#overview" title="Proposal overview" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="4:13" slug="#liquidity" podcast_slug="#liquidity" title="Importance of reallocating liquidity" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="9:42" slug="#overloading" podcast_slug="#overloading" title="What about overloading channels with liquidity from the start?" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="13:05" slug="#multi-single" podcast_slug="#multi-single" title="Discussion of multi-LSP vs single LSP approaches" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="15:22" slug="#unilateral" podcast_slug="#unilateral" title="Ensuring unilateral exit is possible" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="20:21" slug="#malicious" podcast_slug="#malicious" title="Malicious users forcing unilateral closes"  has_transcript_section=true%}
    {% include functions/podcast-bullet.md timestamp="27:11" slug="#tunable-penalties" podcast_slug="#tunable-penalties" title="Decker–Wattenhofer channels vs John Law's tunable penalties" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="38:44" slug="#lock-times" podcast_slug="#lock-times" title="Decker–Wattenhofer relative lock times impact on users" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="40:01" slug="#trustless" podcast_slug="#trustless" title="Discussion of trustless non-P2P protocol structure" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="44:08" slug="#ark" podcast_slug="#ark" title="Contrasting SuperScalar with Ark" has_transcript_section=true %}
    {% include functions/podcast-bullet.md timestamp="48:44" slug="#implementation" podcast_slug="#implementation" title="Implementation discussion" has_transcript_section=true %}
</ul>

## Transcription

**Mike Schmidt**: Welcome, everyone.  This is our first deep dive that we're
going to do with Optech.  We have ZmnSCPxj and his SuperScalar proposal, along
with primary author of the Optech newsletter, Dave Harding, who are going to do
some back and forth deep dive on SuperScalar, what it is, what we're trying to
achieve here.  This is the first time we've done that, and so I hope you all
enjoy this discussion.  I'll turn over the questions to Dave.  Dave, do you want
to frame up how you normally do some research for the newsletter, and then we
can get into the intricacies of the proposal?

{:#why-transcript}
_Why a deep dive?_

**Dave Harding**: Yeah.  So, normally, I just read the proposals on the mailing
list or the forum, or wherever they're posted, and do my own research, and I
write a summary for the newsletter and then we publish.  And then, Mike invites
the expert or experts to come on our podcast, our regular recap podcast, and he
interviews them there.  But every once in a while, we get a proposal that is
quite complicated or has got lots of details, and it takes me a lot of time to
research it.  So, one of our friends, Anthony Towns, suggested that we do a sort
of a precap, a pre-recap, where I talk to the expert directly and try to learn
about the proposal from them.  I ask them my questions directly, rather than
researching it and thinking about it myself.  So, that's where we're at.
ZmnSCPxj has posted a complicated proposal to the forum, and I've gone through
it and I tried to read it, and we're here to learn more about it, and then I'll
write it up for the newsletter.  So, we'll give it a try.  I think maybe the
next step is, ZmnSCPxj, if you want to give a high-level overview of the
proposal?

{:#overview-transcript}
_Proposal overview_

**ZmnSCPxj**: Okay.  So, the high-level overview is that this is multiple
Decker-Wattenhofer factories hosting many smaller Decker-Wattenhofer factories
in a tree structure.  So, this tree structure exists so that at some level near
the leaves, we have these tiny child factories with a small number of clients,
and we are able to quickly reallocate liquidity towards any of those small
number of clients without having to wake up all the clients in this tree.  So,
because we have a smaller number of clients here, we only need to wake up a
smaller subset of clients in order to move liquidity between those two amount of
clients.  If necessary, if for example we really, really need lots of liquidity
in a particular leaf of this tree, then we can try to wake up a larger subset of
these clients in order to move liquidity from one leaf to another leaf.  We can
go up a level in this tree, or nearer to the root.

So, the other part of this is that this tree has a timeout.  So, this is similar
to a timeout-tree where it has a lifetime.  Now, the reason why it has a
lifetime is that it allows the LSP to periodically reap all of the funding
output without having to individually close any of the smaller outputs, or any
part of the tree.  So, we have a cadence here that we can periodically change
this tree in order to, for example, add new members or remove members, or remove
clients from this tree.  So, those are the two core parts of this.  These are
the two things that I kind of mashed together in order to make SuperScalar.  Now
we can go into deeper details into this, or we can try to focus more on the
mashup of these two mechanisms.

{:#liquidity-transcript}
_Importance of reallocating liquidity_

**Dave Harding**: I'll ask a quick question.  How important is the ability to
quickly reallocate the liquidity?  So, I'm looking at this construction here and
the timeout-tree makes perfect sense to minimize the amount of data that goes
onchain, at least in the ideal system circumstance, right?

**ZmnSCPxj**: Yes.

**Dave Harding**: And at the leaves of the tree, you have just regular
LN-penalty channels.  I think you call them Poon-Dryja channels.  And so, that's
an established technology.  Obviously, we can just take the code that we already
have for LN-penalty, and timeout-trees is a pretty simple construction.  You
have timeout-sig-trees here.  So, it's just an n-of-n multisig and you just have
to get everybody to sign the transactions in a particular order.  So, again,
that's a pretty well-established technology, it's pretty simple.  But then in
the middle, you have the duplex micropayment channels, the Decker-Wattenhofer
channels, and that's something that was proposed a long time ago, like 2014 I
think, but I don't know that it's ever been implemented.  It's kind of a new
thing and its main purpose, as I understand, is to allow this fast reallocation
of liquidity.  So, the liquidity can be reallocated offchain, there's no need to
wait for Just-In-Time (JIT) channel.  So, obviously it's a benefit, but is it
worth the extra complexity?  I was just wondering if you could go into a little
detail about your thinking there.  How do we justify the complexity, the extra
steps here, versus just a pure timeout-tree with LN-penalty at the leaves?

**ZmnSCPxj**: Okay.  So, the big problem with just using a timeout-tree is that
you cannot really buy additional liquidity dynamically.  So, you have to wait,
or you have to join another tree in order to gain additional liquidity.  For
example, let's say halfway through this timeout-tree's lifetime, you find that
you are lacking inbound liquidity.  Then you need to join a different
timeout-tree, perhaps one that's going to be established soon, and then get
another channel on that.  And then similarly, you need to keep doing that to buy
more liquidity.  And then when your current timeout-tree dies, when its lifetime
ends, you need to move that capacity to a different tree.  Now you've still got
two channels on two separate trees that you are managing.

Another issue here is that the timeout-trees, I can't make a timeout-tree for
every block, like an LSP can't afford to make a timeout-tree at every block.
So, maybe once a day is fine, but 144 times a day is like two orders of
magnitude more expensive, right?  So, in order to buy liquidity in a
timeout-tree sense, you need to actually wait around for the daily period when
the LSP creates a new timeout-tree.  So, that's even worse than a JIT channel.
Now, we can always fall back to just using a JIT channel when we do something
like this, but it makes sense I think to at least make an effort to try to see
if we can do it without having to create a JIT channel, like we always have this
JIT channel mechanism as a fallback.  Our hope here with this mechanism is that
we are able to do an offchain liquidity reallocation without having to touch the
blockchain at all.

So, the reason for that is that nobody can control the onchain feerates easily,
right?  It could go up, it could go down, it could spike, it could drop.  So, in
order to be more consistent, to provide a more consistent fee to our clients,
it's easier for us if our first step is to try to do this offchain, and if that
fails, then we fall back to onchain.  Now, our hope here is that this fallback
of doing a JIT channel onchain is rare enough that even if it happens during a
fee spike, we can swallow this additional cost and we're still going to present
to the user, "Hey, each month you need to pay us this constant fee", because we
can mitigate some of those risks by using, for example, onchain feerate futures.
We can arrange that with miners and the LSP is in a better position to arrange
that than some random client.  So, our goal here is to try to minimize our use
of the blockchain in order to keep our risk from onchain feerate spiking low.

{:#overloading-transcript}
_What about overloading channels with liquidity from the start?_

**Dave Harding**: That makes sense, thank you.  I just want to push on that
point just a little bit more.  Just two things is, one, why can't the LSP just
overload the individual channels with liquidity at the start?  If you're the LSP
and you're taking on Mike as a client, why can't you take a leaf channel with
him and just open it with an extra 100,000 sats of liquidity for him, rather
than have to add liquidity, have to rearrange it between clients later on.  And
also, if we expect this construction to be popular, wouldn't we expect there to
be at least one LSP every block opening a new timeout-tree?  We can fit about
3,000 transactions of moderate size in a block.  So, expecting one new
timeout-tree to be opened 144 times a day, not necessarily by the same LSP, but
by an LSP that accepts any client, wouldn't that be a reasonable expectation?
So, if Mike needed extra liquidity, couldn't he just go to wherever these LSPs
are listed, have his software parse a list of open LSPs, see who's opening a new
timeout-tree in the next block, and then just do that, just do a JIT payment
receive into a new timeout-tree?

**ZmnSCPxj**: Yeah, that certainly can be done.  So the question is, are we
going to wait for a bunch of LSPs to make that happen, or can we start with
something that one LSP can do right now?  Like, how do we get there from here?

**Dave Harding**: That makes sense.  I was just concerned about the complexity
here of the duplex micropayment channels and now in the later design, the
pseudo-Spillman channels.  I was wondering if it would just be a really easy
step to just do timeout-trees plus existing LN-penalty.  It seemed like that
would be a pretty easy addition to something like LDK, or even Core Lightning
(CLN), even Eclair.  And then you would get the benefit of scalability in the
happy case where no extra liquidity was needed.  And then from there, you could
build up to a design that minimized the number of additional onchain operations
for liquidity movements.

{:#multi-single-transcript}
_Discussion of multi-LSP vs single LSP approaches_

**ZmnSCPxj**: Yeah, that's actually one of the first designs for SuperScalar,
which is just timeout-trees and we just ladder them, like every day we make a
new timeout-tree.  If you have a lot of different LSPs then certainly a client
can just switch to whichever LSP is providing them with a new timeout-tree right
now, soon, for the next block.  But yeah, that's the rub.  We need to kind of
coordinate across LSPs to like, if there are multiple LSPs on this block, and
then on the next block none of those LSPs are opening a new timeout-tree, do we
need to cooperate across all of those LSPs?  And what are we going to use to
cooperate across them?  Or do we need a separate blockchain for this
cooperation?

So, again, all of this is about, what can a single LSP do by itself without
having to create a federation of service providers for this service?  Because
the more number of corporations or big whales that need to get into this, then
the harder this will be to actually implement.  And I mean, the coding would be
simpler compared to the coordination of all the people that would be needed.

**Dave Harding**: That makes sense.  It sounds to me what you're describing is,
if we want people to be able to use JIT additions to new factories, we're
basically going to need a new gossip protocol, we're going to need a whole bunch
of more infrastructure.  Whereas what you're describing, someone like Eclair,
who they write the software and they also provide an LSP, they could just go out
and do this and provide a high-quality service to their clients as soon as they
have the code finished.

**ZmnSCPxj**: Yes.

**Dave Harding**: Okay, that's a really helpful way of framing it for me,
because I was thinking about it more in the sense of a P2P protocol and what
people could get ultimately from a thing.  So, obviously, we can go both, right?

**ZmnSCPxj**: Yeah, we can certainly move that towards that direction in the
future.  But we need to start somewhere now, right?  And as much as possible, we
need to be able to start with just an LSP and some bunch of clients without
having to have a lot of different LSPs just to make this happen.

**Dave Harding**: Okay, that makes sense.  Did you want to talk a little bit
more about the design, and then I'll think of some more questions?

{:#unilateral-transcript}
_Ensuring unilateral exit is possible_

**ZmnSCPxj**: Okay, so one of the issues that we've been thinking of is, how do
you ensure that unilateral exit is possible?  Like, in the worst case, your
client starts out as a no-coiner who has absolutely no bitcoins.  And in many of
our planned ways to pay for fees for offchain unilateral exit, we are going to
use exogenous fees.  What this means is that each of our transactions that are
offchain will actually have a pay-to-anchor (P2A) output that you can anchor to,
and then you can have a separate UTXO that pays for the fees for the offchain
transactions.  So, all of the offchain transactions pay zero fees and you need
to create a child transaction that pays for those offchain transactions.  But if
your client started out as a no-coiner, all of their funds are in this mechanism
and they don't have an external UTXO that they can use to pay for those
unilateral exits.

So again, we can take advantage of the asymmetry of the LSP versus the client.
We assume that the LSP is a big corporation, it's a big whale, it has bunches,
lots of UTXOs that are fairly large that it can use to pay onchain fees with.
It's a large entity and it can go negotiate with the miners to get onchain
feerate futures in order to smoothen out its risk with the mempool feerates.  So
now, what we do then is to invert the timeout-trees' timeout default.  So, in
the typical design for timeout-trees, the default condition is that the LSP can
get all of the funds.  So, the expectation is that the client has to proactively
exit this mechanism.  So, for example, it asks the LSP, "Hey, can you swap my
funds here to an onchain fund?" or, "Can you swap my funds here to that new
timeout-tree that you're going to make soon?"  But if the LSP does not cooperate
in that case, then the client has to do the unilateral exit itself.  And again,
like I pointed out, if the client started out as a no-coiner, all of its funds
are inside this mechanism.  And the default case would be that the LSP on
timeout will be able to claw back all those funds, which is a bad look for new
no-coiners, right?

So, we invert this so that instead of the LSP being able to get the funds back
on the timeout, the funds are redistributed to the clients.  So, let's say I
have two clients, and one has a 10-millibitcoin-capacity (10-mBTC-capacity)
channel, another has a 20-mBTC-capacity channel, then my total funding output is
30-mBTC.  So, what I have is that I have an nLockTime transaction that spends
this funding output and distributes the 10 mBTC to client A and 20 mBTC to
client B; it gives it to them outright, so it doesn't matter what their balance
is in the channel, they're going to get those entire funds.  Now, if there's a
reserve, like for example if the LSP is always required to provide a reserve, or
while the client does not require a reserve so that the client can go down to
zero, but the LSP cannot go down to zero, then the LSP always has something that
it can lose in this mechanism.  And because of that, the LSP is now the one that
must unilaterally exit before the timeout period, and it wants to be able to
coordinate or to cooperate with the clients so that, "Hey, if you don't have any
funds in this mechanism anyway, maybe you can give me control of those funds
instead so that I don't need to publish a unilateral exit, I can just claim all
the funds".  So, this is the inversion of timeout defaults.

So, this now puts the onus of unilateral exit on the LSP.  So, for example, if a
client finds, "Hey, I'm trying to send out my funds to a dubious website", and
then the LSP keeps blocking all sends to that, then it can just wait out this
time period and say, "Hey, screw you, you're not letting me send", so just waits
out those time period, and the LSP has to publish the path towards that channel.
Then, the client can now recover its funds.

{:#malicious-transcript}
_Malicious users forcing unilateral closes_

**Dave Harding**: Okay, so I guess my question with that, and it's kind of a
minor detail, it's one of those things that we would hope will work out in
practice, but does the LSP have to be worried about competitor LSPs pretending
to be clients of it and forcing it to do unilateral closes?  So again, if you're
an LSP and I'm also an LSP, I pretend to be a client of yours.  I get a channel
in your factory and then I just don't do anything, and now you're forced to
unilaterally close, you're forced to put that leaf of mine and all the
intermediate necessary nodes onchain.  So, you have to pay a significant amount
of onchain fees because of my actions.  That's more onchain fees than you would
probably make from an honest user, because an honest user, in a design that
didn't have the LSP being responsible for the onchain costs, would be able to
charge less.  So, is there a -- trust isn't quite the right issue there, but
it's one of these issues of identity where, if there's a cost to the LSP from an
evil competitor, they have to either charge clients more or they have to screen
clients, and so they need to know some sort of KYC stuff?

**ZmnSCPxj**: Yeah, that's one of the drawbacks of this inversion of timeout
default.  But again, the alternative is that if the client starts out as a
no-coiner, then they can't really pay exogenous fees.  And we don't have any
good ways to use endogenous fees without greatly increasing the number of
transactions that you need to sign.  What we could do is that you could create
multiple transaction trees and multiple versions of those transaction trees, and
you provide to each client a signature or the signatures so that it will always
eventually credit from the client's funds.  That's possible to do, but it's
going to require a lot of storage on clients because all of the possible paths
need to be handled.  Like, okay, what happens if the client is the only one that
exits?  What happens if another client exits first and they share a root, or
they share up to this part of the tree?  So, all of those combinations need to
be handled or there need to be additional transactions that need to be signed
for.  And because there are a number of different transactions that need to be
fulfilled, then it means that the channel itself will have multiple funding
outpoints and we'll need to be signing multiple versions of those.

**Dave Harding**: Yeah, I mean I understand there's a challenge.  It seems to me
with P2A though, anybody can fee bump the output that you want to put onchain.
So, if the client had some means of paying somebody to fee bump, they could do
that.  Now, I remember thinking about this before.  I don't think it's easy to
do that trustless, especially if you already have CHECKSEQUENCEVERIFY
(CSV)-locked output from that leaf channel that's going onchain.  So, if it's
hard to do trustless, again there's trade-offs there.  So, yeah, I just wanted
to ask about that design decision, whether it was something you had considered,
and obviously you have and it's a trade-off.

**ZmnSCPxj**: Yes.  The problem here is that you can't really trustlessly ask
someone else to pay for the unilateral exit.  So, for example, in the worst
case, the client has no other LSP, it only has that LSP, all of its bitcoins are
in a channel with that LSP and the LSP is not giving it service.  So, the client
says, "Oh, here's an HTLC (Hash Time Locked Contract)", and the LSP never
forwards that HTLC, because for some reason, whatever, it hates that client, or
whatever.  Then, this client can't really pay anybody else for the unilateral
exit precisely because the LSP is refusing all service.

**Dave Harding**: Yeah, I think that in the leaf channel, if you had an
unencumbered output, like a relatively small, unencumbered output, then it could
just co-sign a transaction with somebody bumping the P2A.  That would give them
control over those funds as soon as the P2A bump confirmed.  I'm sure these are
all things that will be considered as this goes to implementation.

**ZmnSCPxj**: It's not really work for the timeout-tree itself, because for
example, at the root node, all of the clients need to have an output.

**Dave Harding**: Right, right, that makes sense.

**ZmnSCPxj**: That makes it even larger, and that means unilateral exit even
more expensive.

**Dave Harding**: Right.

**ZmnSCPxj**: So, yeah, I've thought of that also, something similar to that.
But yeah, it's one of the reasons why P2A is such an important new technology
here.  We were discussing before about sidepools, and I kind of stopped that
because I realized that you needed anchor outputs for each of our participants
in the sidepool and that really sucked.  And it just didn't work out well,
because especially with Decker-Wattenhofer, you have multiple layers and you
have multiple transactions, and each of them has an output that can be
unilaterally controlled by each of the participants.  But with P2A, that's why I
kind of stopped doing sidepool stuff, and I kind of stopped thinking about
Decker-Wattenhofer for a while, because it just didn't work out.  But with P2A,
it's now a lot more feasible because no matter how many participants there are,
you only need the single P2A output.  So, that's the advantage here.  It keeps
the unilateral exit cost down.

{:#tunable-penalties-transcript}
_Decker–Wattenhofer channels vs John Law's tunable penalties_

**Dave Harding**: Yeah, yeah.  Talking about Decker-Wattenhofer, one of the
disadvantages of it, which you obviously described in your post, is that it has
a very limited number of state transactions, and the more you have to be kind of
heavy onchain, by chaining transactions, putting one transaction after another.
I was wondering if you considered, since Decker-Wattenhofer has never been
implemented, so it would be all fresh code anyway, have you considered something
like John Law's Tunable-Penalty Protocol (TPP), which allows an infinite number
of state transactions, doesn't require any consensus changes, and is also just
fine for having multiple parties?  Obviously, that's why you need
Decker-Wattenhofer, because LN-penalty itself doesn't do multiple parties.  But
duplex payment channels does and so does TPP, so I was wondering if that was
something that you had considered?

**ZmnSCPxj**: As I understand it, the tunable penalties requires additional
UTXOs outside of the mechanism, right?

**Dave Harding**: They can be offchain.  So, you can have the funding
transaction create the additional outputs that you need.  You need one
additional output per party.  So, you can have the funding transaction that goes
onchain, which would be the root of the timeout-tree in your protocol.  It can
create each one of the individual's penalty outputs, and if they're able to use
a tunable-penalty mechanism to keep everything offchain, to keep the rest of the
state offchain, to just float it into the next rollover in the ladder, then
those outputs would never be created.

**ZmnSCPxj**: How many outputs do you need?

**Dave Harding**: For each user, you need a minimum of one penalty output, each
user plus one for the LSP.  And then, you need all of your regular funding
transactions for the leaf channels.  Again, that can all be offchain.

**ZmnSCPxj**: Yeah, but again like I pointed out, before P2A, at the root of the
tree you'd need one anchor output for each client, and that doesn't work, right?
It makes the unilateral exit more expensive.

**Dave Harding**: You can make it into a tree so that the one output per client,
the penalty output would only be on a per-client basis.  So, if you have eight
users and only one of them wants to exit, you only need to put, whether two or
four transactions onchain, depending on how you design it.

**ZmnSCPxj**: Yeah, but do you need outputs for each client on the root
transaction?

**Dave Harding**: No, I don't see why you would.  You would probably need an
output there for the LSP that would allow -- if it made an invalid state later
on in the tree, it would invalidate its ability to spend and allow claiming the
penalty.  But for the clients, it would just be one and it could be on the leaf
node.

**ZmnSCPxj**: Yeah, but how do you reach the leaf node?

**Dave Harding**: You just, I don't know, I'll have to think about that.  I will
think about that and post to the Delving thread.

**ZmnSCPxj**: Yeah, because again, what we currently have is
one-parent-one-child (1p1c) package really for P2A.  So, how do we pay the --

**Dave Harding**: For that, you can just use P2A to get --

**ZmnSCPxj**: How does the client ensure that it reaches to the leaf?

**Dave Harding**: You're saying, if it doesn't have funds elsewhere?

**ZmnSCPxj**: Yeah.

**Dave Harding**: That's it.  I mean, you have the same problem with the
Decker-Wattenhofer.

**ZmnSCPxj**: Yeah.  Again, with the time-out trees, you can invert the --

**Dave Harding**: Yeah, but you can also invert TPP.  I'm just saying, TPP is an
alternative to both the Decker-Wattenhofer and I think also the pseudo-Spillman.
And its advantage there, I mean the costs are basically the same, I believe.
The advantage is that it allows an infinite number of state transitions for just
one onchain transaction.  You don't have to chain anything, except for making a
tree.  Obviously a tree is a bunch of chains, but you don't have to have
multiple Decker-Wattenhofer states or instances stacked on top of each other,
you can just have a single TPP.

**ZmnSCPxj**: So, for example, if you have a nested factory of tunable penalty
inside a tunable penalty, would you need separate control outputs for each one,
or could they share a control output if they are nested?

**Dave Harding**: So, they can kind of share.  I think the LSP could share, but
you would want an individual one for each client at… yeah, actually you could
share.  I think in his latest paper, which I think we covered in Newsletter
#270, he had a state diagram and I'm trying to remember it, but I believe he
only had one penalty output for everything.  Because the penalty output only
gets used, or can only be confiscated by other users, if the person fails.  If
they fail at any point, they lose the penalty output.  And they can't publish
anything else onchain if they lose their penalty.  So, I think you only need one
penalty per user per factory.

**ZmnSCPxj**: Okay, so even if we have nested state transactions, this is fine?

**Dave Harding**: Yes, I believe so, but I know his latest paper, second to his
latest paper, the one that does the Fully Factory Optimized Watchtower Free
(FFO-WF) design -- say that five times fast -- that one has diagrams in it that
show the control transactions.  So, I think if we just forget that paper and
look at it and you'll know if I'm right or wrong really quickly.  But for the
purposes of this discussion, we're getting really into the weeds here, I do
think that it might be a good alternative to Decker-Wattenhofer.  Obviously,
whatever you build you want to build.  What else do we have to cover here?
Let's see.

**ZmnSCPxj**: Yes, a lot of the disadvantages of Decker-Wattenhofer are kind of
cancelled out by the fact that you have a timeout-tree.  Like, if you have a
tree structure, you need to layer this anyway.

**Dave Harding**: Yeah, I think I really liked John Law's hierarchical channels
protocol, which it does a lot of the same stuff that you're doing here with
having multiple clients near the leaf for the rebalancing operations.  But in
his hierarchical protocol, instead of having the leaf channels be A and L and B
and L, and then L by itself, single-sig, for liquidity, he just threw them all
into A, B, and L, and then had a subchannel, a hierarchical subchannel of that
that was -- I'm saying this wrong, it actually combined multiple LSPs.  So, it
would be A with L1 and L2.  And again, that doesn't really fit into your
paradigm here where you're trying to get something that's really easy for a
single LSP to build up by itself really fast.  But I did like the hierarchical
channels for the ability of multiple LSPs to cooperate on liquidity, providing
that to the client offchain instantly.  And I think maybe instead of having two
separate LSPs, the way you could do that is having the same LSP with different
contracts and different versions of the latter.  So, you have the same LSP with
the contract that currently has 30 days left on it, cooperating with the version
of itself that has the contract with 29 days left of it, and it can move
liquidity between those within the hierarchical channels and deliver them to
Alice when she needs it.

**ZmnSCPxj**: Yeah, but in the end it's just one LSP.

**Dave Harding**: It is just one LSP, yeah.  So, I take that back, all I just
said, that was dumb, I apologize.  You really do need separate LSPs to manage
your liquidity.  And that is outside of the paradigm you're focused on here.

**ZmnSCPxj**: Yeah.

**Dave Harding**: Let's see what else is here, let me check my notes.

**ZmnSCPxj**: Anyway, more on that point.  The fact that Decker-Wattenhofer
practically requires, what do you call this, practically requires nesting in
order to increase the number of states is not much of an issue, because with
timeout-trees, you do need nesting, like a tree is a nested structure.  And
another point is that the LSP does not have an infinite amount of funds, so at
some point in the leaves, it's going to have some limited amount of LSP-only
funds that it can sell to those clients.  So, it doesn't have that much impact
if the Decker-Wattenhofer only has a limited number of updates.  It will only
use those updates to actually change liquidity allocations.  We're still using
Poon-Dryja for the effectively infinite number of updates for all the payments.
So, the fact that the number of updates is smaller is not as much of an impact.

The big impact actually is with the fact that you have nSequence, and those
nSequences add up, and every HTLC that goes to the client needs to have this
additional nSequence, this maximum nSequence added onto it.  And that also
increases everything that feeds from the public network to the client.  So, for
example, if this total CSV is seven days, then the public network needs to have
seven-plus-one days into the LSP before it can reach the client, or something
like that.  So, that's the big impact here of Decker-Wattenhofer.  We don't
really need that many state changes, we're not that impacted with the fact that
we need to nest this because, well, it's a tree anyway, you need to nest it.

{:#lock-times-transcript}
_Decker–Wattenhofer relative lock times impact on users_

**Dave Harding**: Right, that's a really good point, I hadn't thought of that.
I did think I was going to ask you about that.  What does the relative locktime
for the Decker-Wattenhofer impose on the client?  So, you're saying you don't
need too many state transitions from the Decker-Wattenhofer, so I guess you
don't need more than a few days' worth of --

**ZmnSCPxj**: Maybe a week or so.

**Dave Harding**: A week or so, okay.  But that's pretty big, right?  Right now,
our CHECKLOCKTIMEVERIFY (CLTV) max is two weeks, I think, in the BOLT spec, so
half of that is gone.  Now, on the other hand, these people will be using an
LSP, so hopefully they'll be very well connected and won't need a lot of hops.
So, it works out at a week.  I would think that would be an advantage again of
the TPP, because it doesn't use --

**ZmnSCPxj**: Yeah, that would certainly be an advantage of it, if we can figure
out if we can do it in this kind of timeout-tree protocol, and if we can use the
inversion of timeout defaults.

**Dave Harding**: Okay.  I think that's the end of my prepared questions.  Is
there anything else you wanted to cover from your post that you wanted to talk
about, that you think is interesting?

{:#trustless-transcript}
_Discussion of trustless non-P2P protocol structure_

**ZmnSCPxj**: Okay.  So, one of the interesting things here that I haven't
actually written out yet is that the LSP, so this is not a symmetric protocol,
this is not a P2P protocol.  The LSP is different from the clients.  We are
assuming that the clients here are small end users and we're assuming that the
LSP is a big whale at the minimum, and is probably a corporation that can hold a
lot of funds together.  So, one of the things here is that the LSP can actually
actually provide these services.  One of those things that I've been mentioning
also is that it can negotiate onchain feerate futures with miners.  And the
effect of this is that because it is negotiating onchain feerate futures from
the miners, it can experience somewhat flatter feerates on the mempool.  So, if
there's a spike, it doesn't see that spike much because it's going to earn money
from that spike at the cost of, if things are always low, then it's constantly
paying to the miners to support the miners for the onchain feerate futures.

This is one of the things that can be done at scale by an LSP on behalf of its
clients.  So, it's one of those things that helps.  It's an economy of scale
that is possible with this that is not otherwise possible if you are just
talking about P2P networks.  And at the same time, we are still enforcing that
the client always has keys all the way to the root of the tree, so it will
always be able to say, "Hey, I need to see that all of these transactions, or
whatever, do not make me lose my money, and I can enforce that by simply
refusing to sign a transaction that makes me lose my money".  So, it's still
your keys, your coins.  And this is like something I want to say is different
compared to stuff like Spark or the clArk or BitVM Bridges, because all of those
kind of require you to trust a bunch of entities.  And those entities might be
multiple, and that means it can't be done by just one LSP.  It needs to be a net
of some consortium or federation, or something, that you need to start up first
in order to actually make this practical.  And I look at Bitcoin's Liquid and I
say, "Why aren't you just using Liquid then?"

So, the advantage here again is that we can start this on Bitcoin without using
Liquid all by ourselves as a single LSP.  You don't need to form a consortium.
Because if you need to form a consortium, then Blockstream already did that, so
why don't you just use Blockstream's Federation?

**Dave Harding**: Right.  I did appreciate that about your design, is that it's
what I call 'trustless', that each person doesn't have to depend on anybody else
for correct operation of the protocol, up to the level of hoping everybody keeps
running full nodes.  And that is a problem that I feel exists in things like
BitVM, where you need somebody to run the code and audit the code.  And then, I
think you mentioned this in your thread, everybody would need to have a penalty
output in a BitVM thing in order to be compensated for failure of the protocol.
And that just becomes impractical.

**ZmnSCPxj**: Yeah, like it's not much different from just you having one
channel per client onchain.

**Dave Harding**: Right, yeah.  Again, I don't think I have any additional
questions.  Mike, did you have any questions, comments?

{:#ark-transcript}
_Contrasting SuperScalar with Ark_

**Mike Schmidt**: When we spoke with roasbeef last week, we touched on
SuperScalar briefly and you alluded to some of the comparisons here with Ark.
How would you further compare and contrast SuperScalar and Ark?

**ZmnSCPxj**: Okay, as I understand it, ideally you would have a single Ark
service provider that provides an Ark service and there would be multiple
senders.  However, okay, without a blockchain consensus change, you need to use
the clArk variant, and that's either you trust that the senders are honest, or
you just have everybody sign.  And if everybody signs, then there's going to be
the uptime problem where if even just one of you is offline, then everything is
stalled and you need to do a unilateral exit.  So in the sense that, yeah, if we
can have the post-covenants changes needed for Ark to break those limitations,
then Ark would be better, but until then...

**Dave Harding**: So, if I can dive in, what I understand to be the case is that
for Ark, everybody needs to sign for every state update.  For SuperScalar,
everybody needs to sign at the start, and everybody needs to sign if they're
going to move funds to a new thing.  But the only critical point for everybody
to sign is at the start.

**ZmnSCPxj**: Yes.

**Dave Harding**: Everything else can happen offchain.  And at the start,
because it's only a one-time operation, if somebody says that they want to join
and is uncooperative, it should be hopefully a pretty quick and easy process to
just kick them out of the thing and create an alternative transaction and get
the remaining people to sign.  It still has scalability problems.  We've seen
coinjoins, which is basically the same thing, we've seen coinjoins involving
hundreds of people, but we don't see coinjoins involving thousands of people,
even if we could relay transactions that big, just because it's really hard for
people's computers to stay on or people just to be around.  A thousand people
requires a lot of uptime, even for a short period, to get people to sign.  So,
without consensus changes, I think SuperScalar is probably limited to maybe a
few hundred users in a particular timeout-tree.

**ZmnSCPxj**: Yes.

**Dave Harding**: Yeah, but that's better than Ark right now, which I guess that
requires, as I understand it, the original version of Ark -- I know they have a
new version, it uses some BitVM stuff, so I haven't looked at it too closely --
but the original version of Ark, for the non-consensus-change version, required
everybody to sign for every state update.  So, you had to be online all the
time, you had to be part of a group that was online all the time.

**ZmnSCPxj**: Yeah.

**Dave Harding**: So, I think that's limited to maybe ten people and even then,
it's probably going to have to go onchain pretty often.  So, I do think the
SuperScalar is a lot superior in that sense.

**ZmnSCPxj**: Yeah.  So, one of the things also that you can consider is that
you could always redesign Ark to just accept k-of-n, right, barring consensus
changes.

**Dave Harding**: Can you, I mean and keep all the funds secure?

**ZmnSCPxj**: I think it should be doable.  It's one of the degradations that
you can use with clArk, is that only the senders need to be signing.  So, what
happens is that everybody else trusts that the ASP is actually making sure that
everything is okay.  So basically, everyone else is in a k-of-n and we have a
1-of-1 or off the ASP.

**Dave Harding**: Yeah, but that's not trustless.

**ZmnSCPxj**: Yeah, but that's not trustless, yeah.  But it's something that can
be done by Ark.  Yeah, and I would argue that basically, that's one of the
things that you can always do with BitVM, etc.  Like, okay, you need a
consortium of people who you kind of trust, and they have to be big and
trustworthy, and then you can go look at Liquid and why not just use Liquid.

**Dave Harding**: Any other questions, Mike?

{:#implementation-transcript}
_Implementation discussion_

**Mike Schmidt**: Yeah, I had a question.  Did I glean correctly from the
Delving thread that there is a working prototype of this?

**ZmnSCPxj**: No, there's no prototype.  Before I wrote that thread, it was just
something I had in my mind for a couple weeks or so at best.  So, no time to
code this.  This was something that was, "Hey, this is a neat idea.  You can
mesh Decker-Wattenhofer with timeout-trees".

**Dave Harding**: What do you think is the implementation difficulty?  Again,
obviously, we can reuse the existing LN-penalty.  Yeah, go ahead.

**ZmnSCPxj**: No, because one of the things that you need to do is that you need
to be able to receive a channel to a different funding output.  So, we do need
some kind of protocol changes at the protocol layer.  So, what I'm planning to
propose is that we have some kind of pluggable factory concept where, okay,
we're going to use an openv1 message to create this channel, and then we're
going to add a Type-Length-Value (TLV) that says, "Hey, this is the protocol
that we are using and this is an identifier that specifies which instance of
this protocol we are actually using".  Then afterwards, you can say, "Okay, at
the factory layer, we did some messaging and we now need to change the funding
outpoint of this channel".  And the thing is, while we're signing off on the new
state of the factory, we need to maintain the channel state for both the old
state and the new state, and that's actually very similar to splicing.  And we
can share the code for splicing there, actually.  However, we do need separate
messages for this, because splicing assumes that you are building up a
transaction using the funding transaction thing, AddTxIn, AddTxOut thing.  And
in our case, the factory has specific rules on how this transaction gets
constructed, and that's going to be different from splicing in that way.  So,
that's one of the difficulties here.

Another difficulty here is again, as a fallback, if you can't wake up enough of
the clients to move liquidity from one of them to another, then the LSP still
needs to do a JIT channel onchain.  And that means that the client then will
need to maintain two channels: a JIT channel onchain and a channel inside the
SuperScalar.  Now, we have to consider also, what if you have an HTLC that comes
in and is too large to fit into either of these two channels, but the individual
capacities, if you sum it up, can fit?  So, maybe what we could do is we could
do local multipath in that case, where okay, so the LSP receives a large HTLC,
it looks at the total capacity of the client and it can fit, but the individual
channels that the client has are not going to fit, so it has to split that HTLC
across those two channels.  And we still need to build that protocol because,
well, LND was talking about this, like, seven years ago, but as far as I know,
they haven't published any protocol for this.

**Dave Harding**: I think we actually had a guest on maybe about a year ago who
actually had software who did that opportunistically for privacy reasons.  So, I
think that there is code out there.  I don't know that it's widely used or how
great it is, but I think it's out there.

**ZmnSCPxj**: Yeah, that would be good if we could do that.

**Dave Harding**: Okay, well, I'm out of questions.  It looks like Mike is good.
I don't know, ZmnSCPxj, you want to say some final words to wrap up?

**ZmnSCPxj**: SuperScalar is awesome!

**Mike Schmidt**: So, we'll have a link to the SuperScalar Delving thread for
folks as a call to action to review and opine on some of the details.  ZmnSCPxj,
thanks for joining us.

**ZmnSCPxj**: Okay.

**Dave Harding**: Yes, thank you.

{% include references.md %}
[superscalar delving]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143/
