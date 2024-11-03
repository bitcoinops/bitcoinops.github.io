---
title: 'Bitcoin Optech Newsletter #325 Recap Podcast'
permalink: /en/podcast/2024/10/22/
reference: /en/newsletters/2024/10/18/
name: 2024-10-22-recap
slug: 2024-10-22-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Olaoluwa Osuntokun and Steven Roose to discuss
[Newsletter #325]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-9-22/388534090-44100-2-f54c79307ef44.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #325 Recap on
Twitter spaces.  Today, we're going to talk about the Lightning Summit notes
that roasbeef posted, we have eight interesting ecosystem software updates,
including an Ark-related update from Steven, and we have our usual segments on
Releases and Notable code changes.  I'm Mike Schmidt, contributor at Optech and
Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin.

**Mike Schmidt**: Roasbeef?

**Olaoluwa Osuntokun**: HI, I'm Co-founder and CEO of Lightning Labs, working on
Bitcoin and Lightning software.

**Mike Schmidt**: Steven?

**Steven Roose**: Hi, I'm CEO and Co-founder of Second, and we're building an
Ark implementation.

_LN Summit 2024 notes_

**Mike Schmidt**: Thank you both for joining us this week.  We're going to go
through the newsletter sequentially here.  Starting with the News section, we
have one news item this week titled, "LN Summit 2024 notes".  Roasbeef, you
posted to Delving Bitcoin.  It was a post that linked to your notes along with a
summary in the post of the LN Summit 2024.  We have a few things that Dave, who
authored this segment, pulled out as highlighted topics.  I don't know if you
have that up in front of you and want to talk to that, or if you have another
direction you'd like this to go?

**Olaoluwa Osuntokun**: Yeah, let me get the topics, or at least your summary of
it, and then I guess we can go from there.

**Mike Schmidt**: Okay.

**Olaoluwa Osuntokun**: I can provide some background.  But yeah, so if we go
back on why, this happens roughly every one to two years, one-and-a-half-ish,
basically.  We try to do every year or so, but then just because of time zones
or scheduling difficulties, or exactly where it ends, then it maybe ends up
being something that happens every one-and-a-half years or so.  And the last
instance was actually in 2022, which was in Oakland, California.  And that was
one that was in the US, and we usually try to hop around a little bit, because
it is a very international group, so sometimes we like to make sure that people
are able to join this wherever they are.  So, yeah, I mean it's a very loosely
structured kind of meetup basically, but developers.  There are a lot of other
side conversations that happen, maybe side conversations around other protocol
things, people doing things around interop.  There were also some whiteboard
breakout sessions as well that people were doing.  And this is my attempt to
take notes and do the discussion at the same time.  Unfortunately, partway
through, I spilled coffee on my laptop and I was out of commission while I was
triaging!  I pushed up some commits very hastily to make sure some of the work
that I had on the plane over didn't actually get lost.

But yeah, I think there were a few major things.  I think probably the most
concrete thing that came out of the summit itself was the v3 transaction
commitment concept.  And part of some of the background in my post, basically
the way it is today in LN, there's some fundamental shortcomings of the way fees
work basically, right?  Because you need to get into the chain in time, you need
to guess what fees are.  So in the past, because you weren't able to update the
fees at all, we didn't really have a CPFP mechanism, which basically once you
spend a child tx, you bump the fee up, you basically had to guess the fee to get
into the next block.  This resulted in some early disagreement at the software
level, because maybe some implementations wanted to do 5X the next block fee,
while another implementation maybe wanted to do something a little bit more
conservative.

The way it works, even right now, is that the industry actually pays the fees
the whole time.  So the person that opens the channel and puts all of the funds
in the single-funder channel type pays all the fees, with the dual-funder
channel type paying up but splitting it a little bit, but you still end up with
this issue, you have to guess the fees ahead of time.  Eventually we had anchor
outputs, which is basically another way to do fee bumping via CPFP.  We
basically have these two very small outputs hanging on either side of the
community projection.  And then, either side can spend that once they broadcast.
That's actually a super-helpful because now at least at this point, you don't
need to guess to get into the next block, you basically need to guess to get
into the mempool.  But as we know, sometimes there's going to be some very large
sort of fee storm basically, and getting into the mempool can even be something
that's actually somewhat difficult, just because the mempool has what they call
a min relay fee, basically a fee that you must pay in order to actually get to
the mempool in the first place, right?

So, there is sort of a dire scenario that can happen, say, in the network, where
let's say fees are rising very, very quickly, and I had my current transaction
at 10,000 bytes basically, and I didn't fee bump up in time using CPFP or even
if I did otherwise, then it eventually falls out, right?  So, this is all about
preventing that scenario using a series of tools, I think many of which shipped
with bitcoind 28, which is a TRUC (Topologically Restricted Until Confirmation),
which is a new sort of replacement semantics that can supersede RBF for certain
use cases, pay-to-anchor (P2A), which is a new standard type that really
crystallizes that mechanism of using anchor to bump things.  And the other thing
as well is, everything we're using right now is also generally applicable to any
other multi-party offchain contract.  For example, things like Ark can actually
be using this.  Anything that is doing any pre-signed transaction can be using
this and other stuff.

The final component that will help make stuff a little more robust is something
called optimistic one-parent-one-child (1p1c), which is an ability that we don't
necessarily have full-on package really yet giving me, giving you the entire
package.  There's some RPCs that sort of expose that stuff and there's a bunch
of PRs on the P2P level.  This is something that's sort of like is more
iterative, where if I send a node a child transaction that doesn't know the
parent, it'll actually now fetch that parent up to depth 1 itself, right?  And
so, there was discussion about catching what the latest and greatest on this,
and instagibbs had some great resources that I think is now actually on the
Bitcoin Core website linked somewhere, it's a Google doc I linked into my notes.
They basically show all the developers and authors how to actually use this in
practice, right?

Then, we got into some of the nitty-gritty around some of the design decisions,
around things like how are we going to handle dust, are there any sort of
implications towards minor incentives of the way we're handling dust, and so
forth.  But it's pretty exciting because actually going into the meeting, t-bast
already had a very prototype implementation of it, and maybe some of y'all saw
it on Twitter or X, or whatever it is.  And the interesting part about this, if
you look at the transaction, the transaction actually had zero fee, which is
something that's rare to see on Bitcoin.  Like, you've all been like looking at
block explorers for many years now basically, and you're always accustomed to
look at the feerate or the fee itself.  But the commitment transaction has zero
fee, and the child actually entirely pays the fee for the parent itself.  And
this is very exciting, because now we can drop the zero fee, we can remove
things like update fee, we don't have to have any disagreements around what the
fee should be or anything like that.  So I think that's something that's very,
very cool.

As far as the upgrade path, so giving this just actually link-level upgrade.  So
by that, I mean you're just updating the channel and not like the HTLC (Hash
Time Locked Contract), or anything at the gossip network, this is going to be
something that can happen over time in a desynchronized manner.  And working on
something else as well, that wasn't necessarily a formal discussion topic here,
something called dynamic commitments, which is the ability to upgrade the
commitment type or parameters over time.  So for example, today we have a dust
value, we have a CSV (CHECKSEQUENCEVERIFY) value, a CLTV (CHECKLOCKTIMEVERIFY)
value at times.  These are things that maybe end up being somewhat security
parameters, or just something like the max_htlc.  This will basically let us
update those values, also the commitment structure, the commitment direction
itself.  So you can imagine this is done, let's say sometime in the future
basically, people upgrade and maybe there's a manual command, some flag that you
set, that'll let you update to this new commitment type.  And so I think we have
a pretty smooth upgrade path there.

The one sort of limiting factor is actually going to be the rate of upgrade of
the Bitcoin Core nodes, right, or any node really that supports this new TRUC
feature, right.  So we're also implementing this in btcd, we're not quite done
yet.  And I think Bitcoin Core 28 just rolled out, like, it's just maybe a few
weeks old.  So, I think we're all just watching the node version to basically
see at what point is it safe to do this.  And depending on the way you look at
it, maybe you need 18% of the nodes, maybe you need around 50% or so, but I
think we'll wait until there's a majority relay path basically there.  Because
ultimately, what you do need is you need the server dominant relay path and also
relevant miners to run it.  I think the other day I saw Ben Carman, he
broadcasted something on mainnet and it didn't really propagate, it wasn't
really mined yet.  So, I think that's another indicator that we can have
basically, like if you try to use this thing, does it actually get into the
chain, or does it get broadcast and propagated?  And then if so, that maybe
means we can start to be rolling this stuff out yet.  But in the meantime, we
can be using it on things like testnet4, which I think has more generally
upgraded nodes, so that's pretty exciting.

**Mike Schmidt**: Excellent.  So, we covered v3, TRUC, I put in the chat here a
reference to the wallet guide that roasbeef just mentioned that covers some of
the Ark use cases as well as LN that roasbeef touched on.  Okay, do you think we
can talk a little bit about PTLCs (Point Time Locked Contracts)?

**Olaoluwa Osuntokun**: Sure, sure.  Yeah, so PTLCs, this is definitely
something that people have probably heard for a very long time on the Lightning
mailing list, even on the Bitcoin mailing list, things around, like,
zero-knowledge conditional payments, a bunch other stuff, in the past as well,
right?  So, we're definitely getting a lot closer.  And I remember, I think
benthecarman asked a question on the Delving post, around like, "Hey, what's the
next step here?  People have been talking about the options for some time now".
There's sort of like a series of concurrent, yet somewhat dependent projects,
right?  So for example, to get to PTLCs, in the past there was a consideration
to basically do PTLCs with ECDSA or schnorr, and there was sort of this scheme
that was going to be called multi-hop lock, that basically allowed you to have a
protocol that was compatible with both.  So, I could have like one EDCSA hop on
the incoming, one schnorr hop on the outgoing, and it would basically just work,
because underlying there's a similar structure for both adaptor signature
schemes, right?

So, ultimately we just ended up pausing, because even with that itself, only
recently in the last year or so has the MuSig2 been a thing.  Just a few weeks
ago, the MuSig2 got merged into libsecp, which is what many implementations use.
And so, there's some dependencies there, right?  But the first thing is
basically just taproot channels, which we've been working on at LND, and we have
our implementation of MuSig2 in BTC suite, where we're going to be able to use
that itself.  That's moving along, I think.  We had a meeting the other day.
Eclair's pretty close to actually getting full interop there, so that'd be
exciting to move that forward itself.  But today, taproot channels actually have
a restriction in that they're actually only on advertised channels because the
gossip network can't actually understand this new channel type, right?

So with the way the gossip network works, it's a little bit more inflexible, I'd
say, or very much precise to basically the channel type that we have today.  We
didn't necessarily envision we were going to have any new channel types in the
future, we really just wanted something that was going to work at that point
there.  And the way it works right now is that nodes see the multisig keys and
they try to reconstruct that P2WSH multisig script, basically.  But in this
case, with the way the taproot channels work, it's actually a MuSig2 output,
which means it looks like a single key, and we're also using a single signature.
So, it actually looks very different.  So, once we get taproot channels, and
then the gossip protocol, which I'll talk about a little bit later, the
extension of that itself, then we can get into PTLC land, and this is basically
around some of the design paths in PTLC.

Another individual that was helping in the discussion is instagibbs.  Instagibbs
in the past has worked on LN-Symmetry and looking at different state machines,
just going from a blank mind, like how would we construct this from the
beginning.  And he presented a few different versions basically, a few different
versions around exactly how this worked in practice.  And generally, I think we
have a pretty good idea.  There's one thing where right now, the Lightning state
machine itself is sort of a concurrent update protocol.  Basically, it's sort of
full duplex and asynchronous, right, which means both sides at any given point
can actually send an update.  And then eventually, with the way the protocol
works, you can actually end up never synchronizing.  If both sides stop doing
updates, and you're actually just now synchronizing the state, eventually you
actually synchronize it, it's there, right?

This gets a little more complicated once you add MuSig2 nonces into it, because
I can't necessarily send a signature until I know your nonce.  And the way
MuSig2 works is that both sides basically need this use of nonces and you
aggregate the nonces and then you use the nonces for the signature.  And like
anything else, you're not supposed to reuse the nonces and they're only meant to
be used once.  But today in Lightning, there's something called a second-level
HTLC, which means that when I'm sending an HTLC for your commitment transaction
itself, rather than you spending it directly off of the commitment transaction
output, you need another signature, because it's like a multisig output, right?
And this is effectively where we're sort of emulating offchain covenants.
There's some sort of certain opcodes where  we can get rid of this thing, and I
can make things a lot simpler.  But in this case, we basically need to use this
2-of-2 contract to bind exactly how you can spend this output, to make sure that
you're not just taking the money and you're actually following the rules, the
protocol, which is important because of the security properties that we want for
verification and CSV delay and things like that itself.

That's what kind of complicates the PTLC contract, because typically I send you
the ad, I send you my commitment signature, and then in that commitment
signature, I'm also sending you a signature for your part of the HTLC multisig,
right?  But in this case, you needed to basically exchange a nonce before I
actually did that itself.  And then also now, because you can send concurrent
updates at the same time, it's difficult to basically figure out who's doing
what, what nonce am I going to use, because if you're sending or using the wrong
nonce, you're going to get a validation failure.  That's going to break the
channel itself because maybe we wouldn't necessarily be able to recover from it.
So, there's some discussion around which direction do we want to go in.

Another one was using a single-sig or MuSig2 adaptor signature.  One thing I
just mentioned is that the second-level HTLCs, they have a two-signature state.
One is from me, one is from the other party.  So, with MuSig2 adaptor
signatures, we could make that a MuSig2 signature, so one signature, and then
also an adaptor signature; or we could keep my signature a normal schnorr
signature, and then just make your signature the adaptor signature which is
needed for me, which you need to complete.  Once I complete, I get this new
payment secret itself there.  One thing with that is that I don't think there's
yet a MuSig2 adaptor signature BIP per se.  Maybe this is something we want to
get going before we actually start to commit to that in the protocol and make
that more of a standardized thing.  Obviously, the single-sig is smaller, two
sigs a little bit larger, but maybe there's less resistance there moving
forward.  The interesting thing is, doing this meeting itself, the MuSig2 PR to
libsecp wasn't yet merged.  Now that's merged, that's pretty cool, because now
people can start to move forward in that direction.

So, I was thinking with PTLCs, I feel like the path is a lot clearer now,
exactly like some of the design decisions to get there.  But there's still the
two prior phases, maybe even three now, as we get into this next thing that's
around state update protocol, of updating the nodes before we get there.  The
other thing with PTLCs as well is that it is a network-wide, internal network
update, meaning that every single node needs to be updated for me to use PTLCs
on that path.  So, I can't go to PTLC and an HTLC.  Technically you can, but you
require more computationally intensive, zero-knowledge succinct proofs
basically, for me to prove that the pre-image of the hash is also the private
key of this key, and things like that.  I remember AJ actually did a prototype
of this many years ago.  I'm sure it's a lot more efficient now, but that's
something that I don't think we're ready to put in the protocol directly, just
because we also want to make sure things aren't too difficult to implement or
have these dependencies of things that maybe aren't yet super-mature yet.

**Mike Schmidt**: We had, I think, a speaker request from everythingsats.  Did
you have a question or comment?

**Everythingsats**: Hi, guys.  I actually had a comment and a question.  So,
first of all, I just want to confirm that you can hear me.  Can you guys hear
me?

**Mike Schmidt**: Yes.

**Olaoluwa Osuntokun**: Yeah, we can hear you.

**Everythingsats**: All right, awesome, because I couldn't hear you guys at some
point.  So, the first comment is that on desktop for Twitter, you can actually
see all of the emoticons, their recent updates, so you can use Twitter for
desktop.  I think that was roasbeef initial 'ish'.

**Olaoluwa Osuntokun**: Oh, cool, thanks.

**Everythingsats**: No problem.  And then, the main question was on the tl;dr
somewhat Delving push you made, where you spoke about liquidity rebates.  And I
don't know if you guys have touched on this yet, but from my understanding, I
just wanted to somewhat query whether or not it was somewhat akin to the credit
ecash thing that moonsettler is trying to do.  I don't know if you're somewhat
familiar with that, but if you are, could you somewhat contrast or make
similarities as to whether or not the liquidity rebates, or probably even expand
on what the liquidity rebates is.  Maybe there's something I'm missing.  And
yeah, that's where I'll stop the questioning for now.

**Olaoluwa Osuntokun**: Yeah, yeah.  Okay, so to provide some broader context,
there was another session just around onboarding for non-custodial or
sub-custodial mobile, or otherwise basically, because typically things are fine
once you already have a channel and particularly if you have bitcoin already,
you can basically send outbound.  When you don't have a channel, you don't have
bitcoin, then we basically need to set you up on the network in a way that is
still somehow economically viable for the person opening a channel to you, or
maybe the wallet author, or whoever, or whatever node; and obviously, any node
can provide the open channels, and that's just basically the way that the
network works as is.

But the question around the fee rebate, so it's different because something like
the ecash protocols, they're trying to be interoperable across other stuff,
because you basically know the same format of the ticket or the signature or who
it is, or whatever, and things like that.  But I would say I think there are
similar tools to help people use very small values without actually having a
channel yet.  Because one thing I talk about as well is fundamentally, if the
chain fees are a certain level, certain outputs are uneconomical to go onchain
basically.  Maybe there's some sort of other value you're ascribing to the
output itself, or maybe there's someone that can help subsidize that transaction
fee itself.  This is why we have the dust limit, which is some kind of
philosophy that was enforced in the early policy, which right now, standardness
and policy aren't as concrete as they were in the past, but it's a little bit
different.

But the fee credit, I think the best way to understand it is, it's a payment
towards a future service basically, in that you get a fee credit, or the fee
rebate, and you can use the rebate to basically pay for something in the future.
You can imagine it's something like, you go to a restaurant or something like
that, and you're not ready to buy a bagel yet, so you put down 50 cents towards
the bagel.  And then in the future, you can buy the bagel at another time.  But
in this case, the bagel is actually just a service, maybe related to channel
liquidity, opening a channel, splicing, paying chain fees, stuff like that.  So,
I think they're in a similar category.  And the category I'd put a solution for
the construct in Lightning, is something like you say, the ecash stuff, the fee
rebate, something like a hosted channel, even like another sidechain-type
contract, which locks up liquidity, or something like that, because that gets
away from actually doing things directly on the chain.

The main difference is that the fee rebate, you're putting that upfront service
payment at the person that's going to provide the service for you in the future
basically, so therefore it's different in that when you have the ecash, you can
send to anybody.  In this case, it's basically just for the purpose of solving
some issues around small-value channels, right?  And to provide some more
context, the way it works is that, let's say I receive a 10-sat payment over
Lightning.  Also, at this point, I have no channel yet at all, right?  So at
this point, I probably won't go onchain because maybe if fees for the
transaction are going to be 1k sats, well, I have 10 sats, I can't pay that for
myself.  And if the other party paid at this node that can be anywhere in the
network, then they would basically lose money as well.

So what this says is, "Okay, hey, we'll sort of put that 10-sat payment towards
your eventual channel opening itself, and once you get to 100 sat, or 500 sat,
something like that, we'll put that towards the feerate to actually a channel
to, right?  And this is something that, once again, it's fully an opt-in thing,
not all wallets use it, it's sort of a new construct that we're looking at
basically.  There's something we're also looking at to handle some of these
problems that arise when you have very, very small amounts of bitcoin, in order
to bootstrap people onto live markets.

**Everythingsats**: All right, so this is live on what implementation, if you
don't mind me asking?

**Olaoluwa Osuntokun**: Sorry, can you repeat that?

**Everythingsats**: I'm saying this is live on what implementation, the
liquidity bit?

**Olaoluwa Osuntokun**: I think it's only on phoenixd, so the server version of
Phoenix.  The other thing as well, there actually are a number of BLIPs that
describe the underlying protocol.  I mean, so in the past, we would need to use
something they called liquidity ads, which is sort of a way to advertise that
you want to open channels for individuals for nodes on the network, or the other
way around.  But if you look on the BLIP repo, there's a few.  I think it's
BLIPs #36, so it's PR #36.  That's a package of many other items basically, and
there's another one for liquidity ads, there's another one for the fee rebate as
well.  All of it's described as one protocol level, and something that people
can start to update and use themselves.  I think one of the main nodes that
actually uses this protocol in the wild as well, so it combines a bunch of other
things that are helpful to on-board users at the last mile, similar to some of
the LSP spec stuff maybe you've heard about.  This sort of seeks to eventually
incorporate a lot of some of the knowledge and some of the work that's gone into
that, into something that's a little bit closer to the protocol.

**Mike Schmidt**: If you're curious about these topics, we actually had t-bast
on.  There was a series of Eclair PRs around this, including the BLIPs #36
on-the-fly funding discussion.  So, that was in Newsletter #323 that we had the
writeup for those PRs.  And then, I would check out the Podcast for #323, and
you should be able to link to that first Eclair PR, where t-bast goes through a
lot of this as well.  Roasbeef, should we continue?

**Olaoluwa Osuntokun**: Sure, yeah.  So, as I mentioned a little bit earlier,
the current state machine protocol for Lightning, it's full duplex asynchronous.
By that, I mean that both sides can send a package or a commitment to control
update at any given time.  It's also asynchronous in that they're not waiting
for another party to send it.  What this means is that you can have certain
situations where you have a concurrent update case.  So, I connect, I'm like, "I
have an HTLC", I do add, then I do sync.  You connect, you say, "I have an
HTLC", you do add, then you do sync.  This actually happens at the exact same
time.  So, the way it works is that the very first state that both of us receive
actually won't contain both updates, right?  It'll take us to revoke again and
then sign again for us to basically have all the updates to be synchronized.
And this is what I mean when I say that at times, the state can actually not be
identical, but if you continue to go enough and there's enough updates that are
flowing with the way the channel works, eventually it'll start to synchronize it
on itself.

So eventually, this was something where I think it was something that we wanted
to sort of maximize the theoretical throughput.  I mean, it had to get like a
non-blocking, asynchronous, full-duplex protocol, which is pretty cool on paper.
But I think over time, at least earlier on, there were a number of
implementation bugs, maybe because the system wasn't super-well-specified, or
there was some slight issue with things like the reserve, and so forth.  And I
would say another bigger drawback with protocol work today is that whenever you
run into a failure of sorts, you actually can't recover, because let's say I
violated some metric that you have as far as, like, the maximum size of HTLC or
the minimum size of HTLC, right?  On reconnect, with the way that it works today
at least, they'll continue just to retransmit that signature over and over again
basically, and that sort of effectively makes that channel unusable for that
period of time it's off.

One thing that Rusty drew up many years ago, something he called simplified
commit, or basically the simplified channel code and state machine itself.  What
this says, this says, "Okay, well, we'll actually just make it be round-based".
Rather than figure out all this stuff around the indexes and the counters and
which signature it's covering, and things like that, so five updates, I'll send
those updates, we'll commit them, and then it's your turn.  You can send the
updates and then you can commit them, and then we'll see if we go back and forth
itself, right?  And this is something that is pretty common in other particular
networking protocols, something called RTS, CTS, (Request To Send, Clear To
Send), which is more to do with interference in a wireless network domain, or
something that's maybe shorter, from a firewall or something like that itself.
We've basically used something similar here, right?  And the cool thing is, this
will let people simplify the code.

One trade-off is that invariably, maybe we do sacrifice a little bit of
throughput, because now we have something that's actually simplex and blocking
as well from either side.  But today, I don't think generally people are really
getting to the point where their links are fully, fully saturated all the time.
Maybe you have certain bursts and I think there's a number of monitoring stuff,
for example, something called lndmon for LND, that lets you monitor that stuff,
so perhaps not really sacrificing anything by going in this direction.  It's
also a bit as well that with the way things work, it would be possible to switch
on-the-fly to do the simple one.  Then let's say you're thinking things are
getting hot, something just dropped or something is getting really popular, then
go to the duplex version.  Then we can also just use this one in the beginning.

I think one big thing with this one is that now this can actually let us recover
from failures that we wouldn't have been able to otherwise.  For example,
because today, once again, if I violate that dust or min HTLC, max HTLC amount,
the channel is just unusable, right, we can't really go forward.  But in this
case, you would send me the HTLC that's below my minimum, and I would say, "No".
And I'll say, "No, I'm not going to add that to the next", and you say, "Okay",
and then you propose the next one, right?  So now in this case, because we're
withholding signatures until we've agreed on everything on both sides, there's
no issue as far as trying to go backwards, which may be as difficult, or trying
to recover from some other disagreements as well.  And as I mentioned a little
bit earlier, some of the MuSig2 stuff requires you to be sending additional
nonces alongside each HTLC.  But in this case, for example, my app message can
actually include my nonce for the HTLC itself.

So, we can actually do a bunch of upfront from primary negotiation, agree on the
next state, and then stamp that and move forward.  Similarly, we can also now
actually recover from going backwards as well.  I think it's cool because this
is a way we can simplify the protocol over time.  We actually have a new
implementation.  Someone who's working on a C# implementation, I think, is
Nicolas, so potentially they can implement this one from the get-go versus
messing with the other full-duplex protocol.  So, it's always nice to be able to
simplify certain things and also just realize that maybe we don't need this, but
also fix some problems around being able to recover from failures, making the
protocol a lot simpler, reducing implementation issues, and also paving the way
for something like MuSig2, adaptor signatures, state insurance, which requires
more analysis for each HTLC.

**Mike Schmidt**: The next item that we called out from roasbeef's notes was
SuperScalar.  And we noted here, and we've talked offline about trying to do a
deep dive on this topic, but maybe, roasbeef, can you give us a tl;dr on what is
SuperScalar?

**Olaoluwa Osuntokun**: Yeah, so as I mentioned, we had an early session that
was around self-custodial channel onboarding, basically.  How do you onboard
users that maybe have small amounts?  Because if they have medium amounts
basically, it's okay.  And by small, I mean less than 1,000 sats, or maybe you
can even get that to 10k.  Because at a certain point, the chain fee costs -- or
you can say the main issues for that, with the way people are doing it today, is
the onchain fee costs.  And the other thing as well is, when you have an
unadvertised channel, the channel funds are just in that channel itself, right?
They can't necessarily be routed elsewhere because they're just between the
routing node and then that end user there, so the Lightning basically, right?
So at that point, it's just sort of in the channel capacity, which also makes it
actually decrease the efficiency of the network itself, because now at that
point, you're not being as efficient as you could be with the channel, because
it's sort of just dead weight sitting there, right?

So, people have been just talking for some time around sort of like other
offchain protocols to allow individuals to sort of get onto Lightning itself, or
even just be able to use HTLCs or other outputs in a way that may be a little
more chain-efficient.  And so, SuperScalar is basically one of those.  It builds
on like a few different ideas.  One of them is our channel factory, which you've
heard from in the past, which is like the idea that rather than just having a
2-of-2 channel, you can have a multiparty channel, and the channel maybe is
constructed in some sort of tree.  Maybe there's a 5-of-5 multisig at the top,
and then it goes down and splits into a 3-of-3, then there's a 2-of-2, and
that's the actual channel.

You can even do things that are multiparty channel and that are self-multiparty
channel as well.  It builds on something else called timeout trees, which is
something that came out a while ago, maybe two or three years ago, by this
individual on the mailing list, John Law.  I think, I didn't really understand
the scheme then.  I remember I read it a few times, I think, the presentation,
and maybe I was working on some other stuff.  But now I'm realizing that a lot
of stuff ends up using the timeout-tree concept.  For example, my opinion on Ark
actually, as I guess we'll hear in a little bit, Ark uses a version of a timeout
tree, and then SuperScalar also uses a version of a timeout tree as well.

I think the high-level way I can describe a timeout tree is that whenever you
have this multiparty option construct, the hard thing to get is everyone to be
online and basically sign at the exact same time.  Because if everyone's online
and signed at the same time, and that's fine if basically you're doing updates,
you're not restricted to basically the way you can rebalance the tree.  You
could add an individual, you can remove them, you can do all this other stuff.
If everyone's not online at the same time, then things become a little more
challenging, right?  Because at that point, does that mean that we basically
need to go onchain to spend what outputs we can and recreate the tree, and
things like that as well?  But timeout trees basically just say, once things
timeout, the funds go back to the coordinator of the system basically, which I
think initially can be a little bit unintuitive.

But what that means is that today, you can say in LN we have the requirement
that you basically need to be online because there is potential for breaches.
They happen very, very rarely.  We sort of have watchtowers, which is this sort
of deterrence mechanism on the software side.  And I don't think we've had like
a major breach at that level in the entire time.  Maybe there's been small,
isolated instances, typically because of some hardware failure itself right?
But then with something like a timeout tree, it's sort of the opposite.  It's
that you need to get online at a certain point in the future to either join the
next instance of the tree or sweep your funds out.  And so for example, you look
at something like the way Ark works, you either need to join the next round or
you just send your funds elsewhere, maybe offchain, something like that.  And
then SuperScalar has a similar construct.

Then, he adds another construct, which he calls laddering, which is once again
kind of similar to the way Ark works.  You basically add additional instances of
this SuperScalar output.  So, maybe one output expires in 30 days and has 20
people, the other output expires in 40 days and has 50 people, and so forth, and
you basically have these individual instances of it.  And because of that
timeout mechanism I mentioned, one thing he described, I forget, the active
period and the decaying period, I think.  Active period is basically when you're
in the tree and everything is fine and you're moving and you're sending payments
and you're making others over the rails.  And decaying period is basically when
you're getting closer to that new absolute timeout, which means you need to
start to get funds out of the channel construct.

It's interesting because in the beginning, there was the ability to basically
deploy expiring channels, because that didn't necessarily need other kinds of
fixes that maybe things like segwit have, or whatever else.  The downside is
basically the channels could be open forever.  And today it's nice, because I've
had channels open on my node for several years now.  I don't have to worry about
it, it's just there, it's nice not to have that time down.  But it turns out, I
think, maybe by moving to certain expiring channel constructs, for example
something like the way SuperScalar works and timeout trees generally, which Ark
also uses, you're able to gain some additional scalability, just because with
this construct, everything that's offchain doesn't need to hit the chain after
that timeout expires, right, because it can all be spent from a single root
output and then rolled into something else.

The final thing that they add is, so with the way it works as well, every single
channel is actually a 2-of-2 channel between yourself and this coordinator as
well.  So they potentially need to give a bit of BTC into this thing to
basically help to facilitate some of these transfers.  Potentially, that can be
a role that's distributed to the individuals, but then every single channel has
another output L.  This output is basically an additional set of BTC that can be
used to add BTC to any of those other two channels.  So with this, you're able
to batch users into this single output construct itself, but then you're also
able to reallocate the channel liquidity between the users at the leaves.  So
for example, I can remove some from a user, put it back in L; I can add some
from a user, put it to L.  And then the way it works, I mentioned a little bit
what you can do when people are online, people are online, you can basically go
back to the next higher branch or route, and then re-sign that, to maybe
reconfigure everything below it, all the way up to the top, assuming people are
actually there.

But one other thing I forgot to mention is that for the internal branch update
mechanism, it uses the old duplex micropayment channels, which is basically
based on the old decrementing sequence value construct itself.  The one downside
for that is that it lets you achieve semi L2-like sequence ordering as far as I
can state, but every time you do, you're basically adding another transaction
onto this tree as well.  So, the worst case maybe if this thing needs to go
onchain, you could have quite a bit of transactions, depending on how many
updates have been carried out.  But I think they have a series of goals,
basically, that they set out to achieve something like this itself.  But yeah,
so that's sort of the combination of duplex micropayment channels, the old paper
from Christian Decker and his advisor, along with timeout trees, along with
channel factories, the laddered concept, and then some other stuff.

But also, since then, since some of the conversations at the summit, ZmnSCPxj
has iterated three or maybe even five different times, basically incorporating
some additional ideas that were generated there.  And right now, it's just a
concept he's thinking about to basically solve some of these problems that he
sees around last-mile onboarding.  And then someone on our team, Ryan Gentry,
actually created a post, I think it was Bitcoin Magazine, that's sort of framing
the last-mile mobile onboarding problem in Lightning, as pertains to more to
communication or transport networks as well.  We also have that issue where,
even me here in San Francisco, I have pretty bad internet, and that's because of
the challenge of the last-mile problem.

**Mike Schmidt**: The next item that we highlighted was a discussion around
gossip.  If I recall, I don't know if it was the last LN Summit, but it sounded
like there was some rough consensus around gossip 1.75.  I know you all at LND
have been pushing this along with some of the simple taproot channels and some
of the taproot assets work you guys have been doing.  Do you want to jump into
that a little bit?

**Olaoluwa Osuntokun**: Yeah, sure.  Yeah, so as I mentioned a little bit
earlier, so today, we want to get the PTLCs, right?  Today we have the simple
taproot channel, which basically was meant to be the most minimal taproot
channel that we could actually use.  So for example, it's just using MuSig2 for
the multisig output, single-signature there, and then still using normal
second-level HTLC individual signatures.  Because I sort of got wind of some
issues around the nonces and the state machine update protocol, and okay, let me
just make sure, let's do it a little bit simpler to get that out there itself.
And then, so initially, I think people recognized there were some shortcomings
with the gossip protocol around things like the way everything was open-encoded
as far as the value, the pubkeys, stuff like that as well.  And also, part of it
was also somewhat inflexible.  For example, there's certain fields that we added
almost as a joke that like, are they really used?  For example, there's a color
field, right, in the gossip protocol.  I think people use the alias because they
want to name their names and it's kind of a thing you can say, "Oh, I know that
person from the alias", even though it's not unique at all.  But we realized,
"Okay, we can do a little bit better here".

So, the last time there were ideas, the more atomic abstract idea was gossip
2.0, an ability where we have this new gossip protocol, we're able to add
additional capabilities to let people advertise channels the way they need to.
Maybe they don't necessarily need to be one-to-one back.  We still want to have
an additional opportunity cost, basically, and not make it costless just how we
do channel, so we're a little more flexible, right?  And then we had meetings
with the minds and came in also in the middle of what we were calling gossip
1.75.  And 1.75, you can have two goals.

Number one, first and foremost, enable taproot channels to actually be
advertised in the network itself, right?  Because I mentioned a little bit
earlier, with the way things work, the taproot channels are directly identified,
and old nodes basically don't even know how to verify the taproot channels,
because they don't know MuSig2, they don't know what we're using there, etc.  So
this basically to enable these channels to be advertised.  Another goal is to
eventually also allow the old channels to be advertised as well too, because we
want to sort of unify on a new gossip network.  So, we want to have an ability
where the old channels can actually be advertised with the new concept, which
was a different message format, and also use the schnorr signatures.  And today,
with the way the protocol works, there's actually four different signatures.
There's signatures of two of the multisig keys and the signature of two of the
nodes that are on the network itself.  With MuSig2, we can actually just make
that into one signature, which is pretty nice.  So, you save a good bit of space
by just having that one signature there, and it also just allows you to have a
slightly more elegant protocol on the side there.

So initially, we were talking about some kind of challenge that people were
having today with gossip around maybe some things not necessarily always
propagating, people don't know what's going on with channel updates, stuff like
that.  Ended up going into a conversation around minisketch.  And in the past,
we'd looked at using that for gossip protocol.  But the way it works today,
everything is based on a timestamp, right, and the only rule that the timestamp
must increment from the last update.  But because of time doing things like that
as well, there's no really objective interpretation of the timestamp.  And some
people, even in the past, started at zero and would bump forward one, and that
caused some implementation fun because we were trying to figure out exactly what
was going on there.  But with the new version, we're basically moving to blocks
everywhere.  What this means is that the update will basically have a block and
you can only have one update per block.  So, it's also somewhat naturally
rate-limiting, unless you can just mine blocks at will, maybe on testnet4 or 3,
or something like that.  But on mainnet, we know that's difficult or costs a lot
of money.  So, we can then use other separate reconciliation protocols, like
minisketch, or other things like that, to basically simplify the delivery of the
protocol a lot more.

Another thing is that the protocol, this one will be a lot more flexible with
respect to basically how you advertise the channel itself.  So for example
today, you say, "I have a channel onchain", you basically do the signatures and
I know that that's your output and that's going to be the channel that's going
to be there in the future.  Another thing is that the way it works today, you
basically have the SCID, which is an encoding of the block height, transaction
index, and also output index, which means that in order to verify the channel,
you basically need to fetch the block and then find the transaction and then
fetch that itself.  But we can do something as well.  We can actually add merkle
proofs into the message in a way that's optional, which is actually really good
for light clients, because today a light client, if they want to verify, for
example Neutrino, which it only supports, you want to verify every single
channel -- by verify, we basically mean the channel actually existed at some
point -- they need to fetch tens of thousands of blocks, basically, and even
more people are sending them their own garbage.  With this one, they could
actually just use the SVB proof directly there, which was definitely a lot
nicer.

The other thing as well, this also gives us room to do additional stuff in the
future.  For example, because of the way taproot outputs are, you could actually
do things like ring signatures over them.  So, it means I can say, "Hey, one of
these is my channel", I can do things like a zero-knowledge proof, I can say,
"Hey, I'm in this large commentary of all the valid channels, and the valid
channels are this because the proof and this recursive and so forth".  So, it
really gives us a lot of additional flexibility.  You can even do things like
just say, "Hey, I have funds somewhere, I'm using those and I can use that to
back the channel as well".  So, it gives a lot more flexibility as far as the
way the gossip network is actually structured.  Actually, in the future, it also
lets us advertise meta channels in a way, right, or rather maybe like a virtual
channel.

So, let's say like we're going back to SuperScalar and we have this massive
channel factory and the channel factory has 100,000 channels because it's pretty
big, or something like that, itself.  But today, like those wouldn't necessarily
be on the public network because there's not that direct link.  And also, they
can't be verified because it's actually all totally held offchain, they're not
actually onchain itself.  So, something like the eventual idealism of gossip 2,
we could allow those to be advertised, because now we're moving away from having
that tight coupling between chain and channel, we're letting you advertise other
channel types as well too.  This is cool because now you can actually get to
something close to the internet, where you have this aggregation of identities
or prefixes where maybe ZmnSCPxj's SuperScalar instance had a pubkey prefix and
then something else itself.  So, people can basically route towards that and
then they know they can get to the other individual's format.  So, I think it
allows us to be a lot more flexible with the way the topology is in the future,
whereas right now, the topology is very much one-to-one between the UTXOs
onchain and channels.  But in the future, it can be useful maybe to break that
limit for additional flexibility, which still allows us to experiment with other
topologies.

**Mike Schmidt**: Excellent.  Thanks for elaborating on that, roasbeef.  We have
one more item that we highlighted before we can do Q&A, if anybody has anything.
But the last one here is, "Research on fundamental delivery limits".  We
referenced some research from René Pickhardt in Newsletter #309.  But roasbeef,
do you want to summarize the discussion on deliverability?

**Olaoluwa Osuntokun**: Sure, yeah.  So I mentioned, I think since this, I think
he's put it out on Twitter.  I think it's something that's a work in progress,
like not finalized, but it's always cool to see additional research focus on the
formalization side of things, because it's always useful to say, "What's
actually possible in the limits?" and then obviously, "What do we need to do, or
what's actually practical?"  Because once again, on paper, this is the very
early thing, it's like, "Oh, Lightning can never work.  You have to solve this
problem super-optimally".  But then in practice, it's like, "Oh, it's good
enough".  It's good enough to have a compelling experience and make sure things
are working properly.  And you don't necessarily always need the optimal
solution to something.  Something that's practical can just give us a solution
that just has this right now.  For example, there's certain fundamental
impossibilities as far as distributed consensus.  But then in practice, we'll
flip a coin, and then maybe it'll work there in a sec.

But so, this is looking at exactly what's the limit of payment deliverability.
The way he ended up modeling everything is a graph, and rather than trying to do
an iterative pathfinding to basically say, "Okay, well, can I get somebody
else?" instead he said, "Okay, can I modify each of the edge weights or balances
pairwise to get to a desired distribution?".  He ended up morphing this into, I
think, a linear constraint problem, and you can solve that and then you can
decide, "Okay, well, is a payment satisfiable or not?"  And the way this works,
the way the model works, if something isn't reachable, then the model says,
"Okay, well, you need to do an offchain transaction", and that can be a splice,
it can be a submarine swap, it can be a new channel, you can close a channel,
you can just send them a payment onchain itself.  So you can say, okay, well any
time something is unfeasible, that's actually going to cause a chain transaction
at that particular point.  And this is interesting because maybe, I think, it
captures indirectly what happens in the network today.

But I think one thing it doesn't necessarily capture is the degree of
aggregation you can get as well.  For example, maybe it's one chain transaction,
but you can actually aggregate many, many users in a single change transaction.
For example, something like loop out, a service that we operate, allows you to
basically do that itself.  The other thing is that the way the model works is
that it's always going for that any-to-any payment.  So me, Bob, I want to
basically be able to pay every other person in the network at the same time,
which maybe in practice isn't necessarily the case.  I think it's useful for a
model basically, once again, because we're looking at the full limits of what
something like this is possible.

I think part of the paper is where it then started looking at, okay, well how
does this change if you have something like a multiparty channel?  Trying to
find that if you have a multi-party channel, then this means less of an issue,
or rather less payments are deliverable because at any given point, if you have
a multiparty channel of two people and they each have 3 BTC, that means at any
given point, one person can own up to 6 BTC in the channel; versus if you have
two people, normally they only have 2 BTC, you can only own up to 4 BTC.  So,
allowing individuals to have a more varied distribution of funds they can have
in the channel ends up increasing the delivery rate or feasibility rate of
payments from the network itself.  At a certain point, it ends up doing some
back-of-the-envelope calculation around, okay, well if we have this amount of
bandwidth in the space itself, and then a transaction costs so much bandwidth,
and we have a certain amount of failure rates, basically, we can look at those
values and derive some sort of values or relationship between the infeasibility
rate, the throughput of the network, and also the payment throughput of the
offchain payment network itself.  I think one of the metrics is that if you have
infeasibility rate of 0.29%, then you basically have 40,000 deductions per
second.  And once again, this assumes that we're doing this any-to-any payment,
because obviously I can have two nodes, I'm just sending back and forth between
them the whole time.  I can exceed that value if I have some verified disk where
I'm just using it in memory or otherwise.

Another construct that we talked about is that, okay, if you have something like
a credit channel within there, then that can actually allow a payment that was
at once infeasible to become feasible.  And maybe this is something that always
happened at the edges, maybe it's something that obviously, it is a more trusted
relationship, because you're sending credit to somebody.  Maybe it's something
where it's like, I have a node with Bob, and me and Bob are hommies, so he'll
let me for the HTLC.  But if I don't have the full bandwidth, then he'll give me
the additional part of it.  And then, it's basically a matter of like how you
actually do the accounting for it, which can function in several ways.  For
example, people mentioned something like the ecash a little bit earlier.  You
can use something like taproot assets for this as well if you want to select
natively the amount of the credit within the channel.  Yeah, I think that's the
main bridge of it.

The paper's coming out, I think, or maybe it's already there.  It has some
pretty cool diagrams around the ways of visualizing things as well.  But it's
just kind of a cool thing.  I think the main takeaway is that multiparty
channels can actually help pay more liability, because they can help make
payments that were previously unfeasible, feasible.  And then also, if you can
virtualize or add some sort of credit cards to be charged to the channel as
well, you can also make those payments that were previously unfeasible now
feasible again.  So, it was some cool conclusions and generated some additional
discussion around chain fees, and all the other stuff as well.

**Mike Schmidt**: Murch and Steven, do you guys have questions?  We sort of
covered the callouts from the newsletter.  I wasn't sure if there was anything
else you guys wanted to discuss.

**Steven Roose**: No questions, no.  I just wanted to mention that the
construction that ZmnSCPxj came up with, the SuperScalar, it's pretty similar to
like Ark with LN channels on top.  There's a lot of similarities that I'm not
sure he realized.

**Olaoluwa Osuntokun**: No, totally, and that's something I brought up, right?
And to me, I think both Ark and SuperScalar, the way I'm thinking about mine,
use timeout trees, where timeout trees is the whole thing where rather than like
needing to worry about re-signing or doing a cooperative close, the main thing
is the funds go to one place.  And therefore, you need to either join the next
instance or move the funds elsewhere, potentially offchain of your channel and
so forth.  So, yeah, it is pretty simple.  I think the difference between
SuperScalar and Ark is that it uses the duplex micropayment channels to
basically do additional updates.  And I guess one difference, the Ark tree is
basically immutable once it's in the chain, because you're either going to let
it play out to the expiry, or you're going to join the next version; while the
SuperScalar tree is actually immutable, and it's immutable because it uses the
duplex micropayment channel construct to re-sign internal branches to modify the
liquidity distribution within the channel itself.  And I think that was one of
his, I think, goals, because he wanted to promote sort of offchain liquidity
distribution basically.  And if you can re-sign the channel versus going to the
next one, then it's a lot more flexible.

But yeah, I mean, there's overlap.  I think one of the things I ignored for a
while, but I think I understand the tool, is basically the timeout tree concept.

**Mike Schmidt**: Everythingsats, did you have another question or comment as we
wrap up this session?

**Everythingsats**: Yeah, quick question to roasbeef, or anybody, on their
comments on the LNHANCE proposal by moonsettler that got a website launch, and
its relationship with LN-Symmetry.  I just wanted to know whether or not you'd
read it or seen it, and any input you probably have on it, and that's it.

**Olaoluwa Osuntokun**: Yeah.  And for the audience, I think it's a combination
of BIP 119, OP_CHECKSIGFROMSTACK (CSFS) from Stack, and then also,
OP_INTERNALKEY.  I think that's the set of it.  Comment on it?  No, I mean, I
think it's cool.  I think we have BIP 9, and BIP 9 lets you advertise a future
BIP, and then it also lets other nodes see if a future BIP that they don't know
about is maybe about to reach some threshold.  So in my opinion, I think it's
okay for people to try BIP 9 stuff, and I think most of them will fail, which I
think people will learn from, because then it's less a whole inner thing of
like, "Oh, it's keeping it down".  But also it's like, if you tried and it
failed, it failed; and then if something succeeds, then I think we learn things
from that, because then it's more of a direct revealing preferences instance.
And I think it should be okay to try something and fail, and everything isn't
necessarily some big attack because they tried and they failed, and there's a
protocol called BIP 9 or BIP 8 that people can use for it.  Will this one
succeed?  I guess we'll find out.

**Mike Schmidt**: Murch, you good to move on?  All right, roast beef, thanks for
joining.  You're welcome to stay on.  I think we do have an LND PR later if you
want to hang out for that, and we'll talk a little bit of Ark as well, if that's
interesting for you.

**Olaoluwa Osuntokun**: Cool, thanks.  Thanks for having me on.

**Mike Schmidt**: Next segment from the newsletter is our monthly segment on
Changes to services and client software.  We highlighted eight different what we
thought were interesting updates in the ecosystem, so we'll jump into those.

_Coinbase adds taproot send support_

First one here, "Coinbase adds taproot send support".  So, if you're using the
Coinbase Exchange and you're withdrawing, they will now allow that to go to a
bech32m taproot address?  Murch, when taproot?

**Mark Erhardt**: Well, there's still a few big services that don't support
sending to bech32m addresses.  There's also some bitcoin-only companies that
still don't, which really baffles me with the anniversary of the activation
coming up in a month or so, the third anniversary, I should say.  And, well, I'm
very happy that Coinbase is finally doing it.  I think depending on how many
customers of Binance you anticipate to be on among your user base, it seems a
lot more viable now to roll out a taproot-only wallet at this point.  And I
think if someone actually took that leap, it might push the rest of the services
over the ledge to finally implement it.  And frankly, it's such a small change.
If you can already send to native segwit addresses, I would be surprised if it
were more than, let's say, a couple of engineering days to implement it.  And,
well, the space is moving that way, so you'll have to do it eventually anyway.
Anyway, yeah, you can hear I'm a little frustrated!

**Mike Schmidt**: Yes, I saw some posts recently.  The "When taproot" account
has woken up.

**Olaoluwa Osuntokun**: Yeah, and if I'm not mistaking, I think they added a
receive support initially when one of the ETFs came out.  I think it was like
the Bitwise and people were sort of complaining.  I remember the next day, they
published their address and people were like, "Why is it not in a taproot
address?"  I think then they ended up working with them, because they're using
Coinbase for custody to add the receive.  And then once you have received, might
as well do send.  At least, that's the way I remember it.

**Mark Erhardt**: Yeah, the way I remember it was that they only implemented
support in the custodial part of their software.  So, the end user wallet was
not able to send to bech32m addresses or receive yet, while the custodial
enterprise-facing service did.  And then it took another, I don't know, a
quarter year, half a year or so for the end user wallet to also get support.

**Mike Schmidt**: So, yeah, it sounds like from what we know then, that Coinbase
custody product has a taproot receive capability and Coinbase Exchange has a
taproot send capability, but I guess we're not really sure of whether Coinbase
Exchange is doing received.  I haven't done testing there to see.

**Mark Erhardt**: I think it's only send support so far.

_Dana wallet released_

**Mike Schmidt**: Okay.  Dana wallet released, I believe I'm pronouncing that
right.  Dana wallet is focused on the donation use case.  So, they have a wallet
that is focused around silent payment identifiers, the recently released silent
payment protocol.  And I think the recommendation at this point for this wallet
was, "Hey, you can use this on mainnet, I believe, but please use signet".  And
actually, the same group runs a signet faucet for you to sort of mess around
with silent payments using their wallet.  Murch, did you get a chance to look at
that?

**Mark Erhardt**: Yeah, I did.  I thought it was really interesting.  This is a
new one.  It's a signet faucet that only takes silent payment addresses to pay
out.  So, I've seen some people asking the signet channel recently again.
Apparently, it's still pretty hard to get signet coins.  There also seem to be
some efforts to monopolize testnet coin creation and a new marketplace for
testnet4 coins has popped up which, well, I guess it's very easy for a single
person to ruin a common good, but these people are doing a great job at it.
Anyway, yeah, I thought it was super-interesting to have a faucet that only pays
out to silent payment addresses.

_Kyoto BIP157/158 light client released_

**Mike Schmidt**: Kyoto.  Kyoto is a Bitcoin light client.  It's an
implementation of BIPS 157/158, which is the compact block filters, and it's a
light node whose intended use is by wallet developers.  It's written in Rust, so
if you're a wallet developer looking for a light client implementation, maybe
check out Kyoto.  Murch, anything?

**Mark Erhardt**: Well, maybe just generally, I think that maybe from an
abstract point of view, BIP 157/158 compact client-side block filters are way
more attractive than the server client model that is employed by most light
clients.  I'm aware that it takes a little more bandwidth, but if you just sync
up while you're at home, or something, that basically doesn't cost you much, or
nothing.  So, I'm a little surprised how little uptake compact block filters has
gotten.  Just it has so much better privacy properties, so I'm curious what will
have to change eventually to make this happen, and I'm very happy that more
people are working on it.

**Olaoluwa Osuntokun**: Yeah, yeah.  I'd also like more people to use it.  I
think also now, with BIP 324, which is the encryption protocol, now the link,
once we finalize that, can be also encrypted, which is a pretty big bump from
doing potentially some unencrypted connection to someone else's server,
basically.  But yeah, to me, it is a bit disappointing where a lot of things
say, "Oh, it's a mobile wallet, it's a light client", but it's really connected
to their Electrum server, which gives quite a lot of information away, which is
definitely unfortunate.  I mean, I will say, I'm meaning to do a number of
updates to the protocol.  For example, re-examine the false positive rate, make
a filter that's segwit only.  And then, one other thing that I know kept people
down, at least when you use mobile wallets, one thing that can take some time
once you come back up is sort of re-scanning a period of like several weeks or
months, because maybe the user was offline for a long time and they want to use
Lightning, and something like that.  That's one thing that I know is definitely
a lot slower than just asking the node for the latest set of addresses or
transactions related to an address.

In the past, I know Kalle from Digital Garage, he worked on some research
looking at aggregation of the filters, describing you downloaded one filter,
maybe you download a filter for a month, and if that says no, then you
definitely know it's not because there's no false negative, but if it says yes,
then maybe you have something in there.  I think that's something that can help
to cut down the sync time there.  But yeah, definitely I think, maybe I'll also
post about those mailing lists to see if people are interested in picking some
of those up, because I definitely think it's important that we have good
light-client support here moving forward.  And I think one thing that can
actually help to make it more attractive is, for example, some of the tooling
around from like the STARK proofs that was getting a little bit better, you can
write a program in Rust, or integrate with Rust or whatever else, that they can
then generate your proof.

I think people can do something like take something like utreexo, or some of the
utreexo commitment basically, and then create an authenticated version of that.
And then using that, that actually would change the way light clients work,
because they would be able to sort of have this authenticated lookup into either
UTXO or the spent transactions for a given block.  That can actually help to
make things even more bandwidth-efficient, because it's better to fetch maybe a
proof that's like 100 kB or so versus fetching blocks that are tens of MB in
aggregate.

**Mike Schmidt**: Hey, thunderbiscuit.

**Mark Erhardt**: Yeah, the idea of having a filter that lets you scan 1,000
blocks at once or something, that would be a week, not a month, as you
suggested, that seems really attractive.  I guess you'd add even more bandwidth
in order to get more filters until you find your transactions, but if you don't
find anything, that should be super-efficient.  And most wallets, especially
light-client wallets, probably don't have a super high volume of transactions.
So, I think you should absolutely post about that.  That sounds amazing.

**Olaoluwa Osuntokun**: Yeah, and remember, there's sort of a sweet spot.  You
can basically look at some of the parameters, like the false positive, the size
of the filters, and the expected bandwidth due to download as well.  And you can
find that sweet spot and then parameterize around that.  But yeah, I definitely
think this should be revived moving forward, because I think a lot of developers
are trying to make a better Electrum.  And it's like, let's just make light
clients better!  That's what I'm thinking.

**Mike Schmidt**: Thunderbiscuit, did you have a comment or question?

**Thunderbiscuit**: Yeah, just quickly I wanted to say, I work with Rob who is
developing Kyoto.  So, it's too bad, I know he wanted to be here, but I think
he's traveling.  And I don't want to speak for him, but I think one of the
really cool things happening right now is that he's got it working on BDK, so
it's a Rust library.  But we also have the PR on the language bindings, so that
gives you mobile support.  And we were able to integrate it last week in both of
our example wallets, so the Bitcoin Development Kit maintains both a native
Android and a native iOS app, and both of them, we were able to integrate Kyoto
into it.  I think one of the things is that, yeah, I don't know how easy the
clients were for mobile.  So, that's one thing that will hopefully come soon
enough on our side, at least, so you should be able to use it on mobile.

One of the cool things, because if you're familiar with the Kyoto stuff, the
issue of course with the compact block filter is you don't actually get any
mempool stuff.  So, you're sort of stuck waiting for the transaction to confirm
before you can see it, and that's the main downside from a user perspective,
like UI and UX.  But I know that one thing that Rob's got a PR and he's been
working on is kind of fun is, he's got this thing where you can actually listen
to the P2P messages as they pass through.  And so, if you know that you're about
to receive a transaction, this is something you can turn on for a few seconds,
and you will actually see you're listening to the gossip.  So, you're going to
see your transaction go through, and that's kind of fun.  I mean, it's not a
super-big solution and you can't have that on all the time on your mobile
device, but if you know somebody is about to send you a transaction, you can
turn it on for a few seconds and it picks up transactions super-well.  So, it's
kind of neat.  Anyway, that's all I have.

**Mike Schmidt**: Steven?

**Steven Roose**: Yeah, I want to I wanted to say something about Olaoluwa
saying that people are trying to improve the Electrum protocol.  I think there's
some people from BDK that actually tried to do something that's like a
combination of the neutrino-like model with the compact block filters and
Electrum, where you basically have a centralized server that serves you the
filters so that you can both have your privacy and your better version of the
light node, but you don't need to do P2P.  So, web clients, mobile clients that
don't want to use too much bandwidth can just ask the filters from a single
source.  So, you need to kind of trust the source to give you right filters, but
if they give you wrong filters, the only thing that happens is that you don't
find anything.  I think they called it Neutrum, you know, like Neutrino and
Electrum, but I'm not sure if they're actually actively working on it.  But it
was an idea that they had.

**Olaoluwa Osuntokun**: Yeah.  The one thing I want to say is, they mentioned
that a drawback is not having uncoordinated action.  That's something that we've
seen where some mobile wallets, they wanted to have that, so they were looking
to add some hybrid kind of a thing.  There are a few things you could do.  You
could have some sort of stream of hash of PkScripted value, something like that
itself.  Ultimately, because it's unauthenticated, they can still kind of spoof
this.  Remember, this was something in the law back where people had some BIP 37
client and it sent them 21 million satoshis or 21 million bitcoin, or something
like that.  But yeah, there are definitely challenges in terms of getting that
better UX and getting it aligned.  But at least my goal is to give people the
best P2P version that we can deliver, and then obviously it's up to them to make
a decision.  But ultimately, the P2P version will at least be more robust
because maybe you're undercutting on a single server, but maybe you're trading
off bandwidth.

_DLC Markets launches on mainnet_

**Mike Schmidt**: Great.  Good chat between the group here, I like that.  Next
item that we highlighted from the newsletter is DLC Markets launching on
mainnet.  So, DLC Markets provides non-custodial trading services using DLCs.
Looking into some of the literature on the service, they can do something like
futures trading options or even other products like hashrate or blockspace.  And
what's being done behind the scenes is that there's this locked-up
collateralized bitcoin and then there's a series of oracles for external to
bitcoin data, like price information and whatnot.  So, that's available on
mainnet.  I asked about the open-source nature of the product.  I think they're
going to open source some things, maybe not everything, so maybe there's
something interesting there, we'll take a look at that in the future.

_Ashigaru wallet announced_

Next piece of software, Ashigaru wallet is announced, and this is a fork of the
Samourai Wallet project.  So obviously, though the Samourai Wallet devs were
targeted for prosecution and I think development on that project largely slowed,
this is a software fork of that.  And in their announcement, they didn't just
announce a rebrand, but also some improvements on the batching side, some
enhanced RBF support, and fee estimation improvements.  So, I guess they're
carrying the Samourai Wallet torch.

_DATUM protocol announced_

DATUM protocol announced this is a protocol similar to Stratum v2, in terms of
allowing individual miners to participate in a pool setting, while also being
able to choose transactions for a candidate block themselves.  This writeup was
before I think they published some more specifications and/or open-source
portions of this.  I haven't got a chance to see that if that is the case, but
this newsletter was published Friday morning.  So, if that is out now, it was
not available at that time.  So, I think we'll probably have more to discuss
here in the future.

_Bark Ark implementation announced_

And Ark, we've been waiting for it.  We have Steven here from Second, who
announced the Bark implementation of the Ark protocol, and I think there was a
video with some live Ark transactions on mainnet that got some traction in the
Twittersphere.  But Steven, why don't you talk about the company, talk about the
implementation, talk about Ark, and maybe we'll have some questions.

**Steven Roose**: Cool, yeah.  Thanks for having me on.  Yeah, so I think Ark
was published, like the idea was published, a year-and-a-half ago.  I was on
sabbatical from Blockstream at the time.  So, I got interested, started to work
on a proof-of-concept version in Rust, and then eventually left Blockstream and
decided that I wanted to try and build a production version of the protocol.
So, we started a company called Second, incidentally three former Blockstream
co-founders, so a good friend of mine and another colleague from Blockstream.
Yeah, we've been working hard.  We decided to focus on a version of Ark that's
called Clark, which doesn't require covenants, so Covenant-less Ark, which is
basically based on multisignatures instead of covenants, so that we can deploy a
version of this on Bitcoin as it is today.  Obviously, we do want covenants.  We
think the protocol would be a lot better without covenants.  It would reduce a
lot of interactions needed in the protocol, bandwidth usage for clients.  So,
obviously we want covenants, but we also wanted to build something that could
work today.

So, we're building using Rust, using the whole Rust Bitcoin set of libraries and
ecosystem that I also contribute to.  We did do the announcement a few weeks
ago.  We did some payments on mainnet.  We didn't fake anything during the
announcement, but our product is definitely not ready for mainnet usage.  So,
there's a lot of things that are not robust, there's a lot of things where users
could start doing weird stuff, and we don't know how to handle that yet.  So,
definitely it's not in beta or alpha stage yet, we're still building, but we
hope to have a signet version out in a few months so that people can start
spinning it up and at least firing some transactions on signet.  We just did a
small set of hiring after the announcement.  So, we're going to onboard three
more people to our team.  And, yeah, we're really excited to be building Bark.

**Mike Schmidt**: Awesome.  I think, and I don't know if there's Ark rivalry
here, but I think we covered, was it Ark Labs, or something like that, that we
covered a few weeks ago.  Obviously the software is different, but are they not
using Clark, or are they using a different version of Ark; how would I compare
and contrast?

**Steven Roose**: Definitely no rivalry, but just what you said, colleagues,
right?  We're trying to build a better experience for Bitcoin.  Actually, I did
work with the people that started Ark Labs in the beginning for a short while,
but we decided to just part ways and have our own implementations.  I'm not sure
what their current roadmap is, but they started with their prototype on Liquid,
so they were using the governance that Liquid had.  I think by now, they also
support Bitcoin mainnet and doing a Clark version, but I'm not sure which one of
the tools they're going to be prioritizing or focusing on as their main version.
But yeah, they're using the Go stack, like the EDC suites and all the Go
libraries that they have.  So, yeah, the implementation is different.

There's one very big difference between like the Lightning ecosystem, where
there's multiple companies building different implementations, and Ark, is that
the Ark protocol is inherently a client server protocol.  So, there's no
specification needed in between the implementations.  There's no P2P, future
negotiation, all that kind of stuff.  So, the implementations can be quite
distinct and can just focus on their own server and client implementations, and
there's no need for us to agree with them on certain things.  Obviously, we
communicate on protocol ideas to improve the overall experience and the security
of the protocol, but we can iterate a lot faster than the Lightning space, where
specification needs to be built and people need to agree on common
specification.  So, yeah, they're building another version at Ark Labs.  We're
building Bark at Second.

**Mike Schmidt**: So, as of now, there's no interoperability concerns, so you
guys can sort of iterate and innovate independently?

**Steven Roose**: Exactly, yeah.  So, we envision that the interoperability
would be very much like the ecash situation where you have different mints, you
have like Cashu mints, FediMint mints, and even different FediMint mints and
different Cashu mints among each other cannot really interact much.  So, you
would use Lightning as like some kind of bridge between the different
implementations.  And similarly, from any Ark, you can pay Lightning invoices.
So basically, if you wanted to pay to someone who's on a different Ark, you
would send them a Lightning payment.  So then, it doesn't matter whether the
other Ark is an Ark on Liquid or a Go Ark, or whatever, or a Bark Ark, lot of
Ark!  So, we will bridge using Lightning payments because the ASP will be
functioning as a Lightning bridge, or an LSP, so that users don't have to worry
about what version of whatever protocol their recipient or their counterparty is
using.

**Mike Schmidt**: Hard to answer a question, but I'm sure people are curious
since Ark is a hot topic.  You said you're polishing up Bark, making it a little
bit more robust.  Do you have an idea of when that might be ready, ready for
something like an alpha or beta?

**Steven Roose**: I said a few months for signet, right?  Yeah, I mean it
depends.  We're currently onboarding a few people or we're going to be
onboarding a few people to our team, and I think then we can accelerate a lot.
We are actually focusing a lot on being mobile-friendly, so we recently decided
to make a few changes to how our client server protocol works to make it a lot
less bandwidth requirement required, and try to optimize for the mobile use
cases, where phones can only be woken up for short periods of time, where they
don't have a lot of bandwidth, where they might drop out.  It makes things a lot
more complicated, but we think it's very important to have that use case from
the get-go.  So, we're going to be offering an SDK as our first product, so
we're going to partner with some wallets that will integrate using our SDK.  And
then, yeah, we're going to be optimizing the client offering for the SDK so that
it can work on mobile.  The ASP on the other hand also has a lot of work to be
done.  It's hard to make estimations.  Definitely several months, definitely not
this year.

**Mike Schmidt**: Anything else you'd say in wrapping up, Steven?

**Steven Roose**: No, no.  We're very excited to be building this, and you'll
definitely hear from us.

_Phoenix v2.4.0 and phoenixd v0.4.0 released_

**Mike Schmidt**: All right, Steven, thanks for joining us.  The last piece of
software we highlighted this month was the Phoenix v2.4.0 and phoenixd v0.4.0
being released, and both of those include a lot of the liquidity management that
we spoke about with t-bast, that I referenced earlier that was in Newsletter and
Podcast #323, "This is basically the result of two years of trying things on
Phoenix to figure out how to actually best manage liquidity so that people did
not have to care too much about it, while having to not have to pay too much
fees either".  So, if you look back, we were talking about Eclair in #323, but
t-bast also let me know that a lot of those same features are in these Phoenix
releases that we covered.  So, I invite people to go back and check that out.
We talked about on-the-fly funding, recommended feerates, liquidity ads, funding
fee credits.  So, jump into that to get some more details.

_BDK 1.0.0-beta.5_

Releases and release candidates.  I didn't have anything for this BDK
1.0.0-beta.5 release that we've had for the last couple of weeks.
Thunderbiscuit, anything new on the BDK front?

**Thunderbiscuit**: No, nothing special.  I think beta.6 is coming out this
week, or next week at the latest.

**Mike Schmidt**: Cool, we'll look forward to that.  Notable code and
documentation changes.  If you have any questions for us on what we've covered
here in the newsletter, feel free to request speaker access or drop a comment in
the Twitter thread, and we'll try to get to that.

_Bitcoin Core #30955_

First PR is Bitcoin Core #30955, which introduces two new methods to the mining
interface that we discussed back in Newsletter #310.  Murch, did you have any
details on these?

**Mark Erhardt**: I did look at this a little bit.  So basically, when you use a
node to craft the block template, the only things that are missing that need to
come back from the mining hardware are the variable items, right, so the
version, the timestamp, the nonce, and of course the coinbase transaction
itself.  And from what I understand, looking at this PR, it added a new method
that allows to submit block solutions in this minimal data way, and it also
reactivated the getCoinbaseMerklePath() function, which is used to calculate the
merkle path to a specific transaction in a block.  So, this seems to be
obviously work towards support for Stratum v2 in Bitcoin Core and, yeah, that's
all I have for it.

**Mike Schmidt**: I wonder if, with this DATUM protocol doing something similar
to Stratum v2, if they would also be consumers of this interface.  I guess we'll
see.

_Eclair #2927_

Eclair #2927 adds enforcement of recommended feerates.  I mentioned this a
moment ago, but we covered recommended feerates with t-bast and Eclair back in
Podcast #323.  But as a recap, Eclair sends an optional message that tells its
peers the feerate that it would like to use for funding channels, and this lets
the peers know which values are acceptable for them.  It uses an odd type in
Lightning, which means it's ignored by nodes that don't support that feature.
And with the PR now this week, Eclair will now reject channel open or splice
requests if the peer is using a feerate lower than what the Eclair node
previously had recommended to its peer.  This is specifically for on-the-fly
funding that we talked about as specified in BLIP 36; we talked about that a bit
earlier.  Anything to add, Murch?  All right.

_Eclair #2922_

Eclair 2922 adds stricter adherence to the proposed splicing spec to Eclair.  So
previously, Eclair would support non-quiescence splicing, and after this PR it
does not.  So, splicing is, as a reminder, the term given for replacing the
funding transaction with a new one.  And for simplicity, the splicing spec
required that splicing takes place once a channel is quiescent, meaning that the
channel is somewhat in a paused state during the splicing process, and then
operation would return to normal after the splice transaction has been signed,
at which point that channel would no longer be paused or quiescent anymore.  So
essentially, Eclair more strictly requires this quiescence.

_LDK #3235_

LDK #3235.  This is a PR that was motivated from an issue in the LDK repo.  That
issue suggested, "For accounting purposes, it's nice to know what your local
balance was when a channel was force closed.  This would allow you to see how
many millisatoshis (msats) you lost due to rounding".  So specifically, this PR
adds a last_local_balance_msats field to the ChannelForceClosed event in LDK.
So, you have that piece of data if you wish to record it for curiosity,
reporting, statistics, or other purposes.  Oh, no, we lost roasbeef.

**Mark Erhardt**: Yeah, he left a while ago.

_LND #8183_

**Mike Schmidt**: Oh, I was hoping he'd stay on for this one.  I did not prepare
my notes in that optimistic hope!  LND #8183 adds the optional CloseTxInputs
field to the chanbackup.Single structure in a static channel backup file.  It
was noted that when you're messing around with this particular individual sort
of backup, that you should exercise extreme caution because there could be loss
of funds.  And there was also, I think, a manual update method which will update
the backups after LND shuts down.  But I didn't jump into the PR other than
reading the summary, which I've largely summarized for you here.  Murch, did you
get a chance to look at this one by chance?

**Mark Erhardt**: I have not actually.

_Rust Bitcoin #3450_

**Mike Schmidt**: Okay.  We'll just have to take the L on that one then.  Last
PR this week, Rust Bitcoin #3450, which adds a v3 variant to transaction version
data structures in Rust Bitcoin.  This follows Bitcoin Core 28.0, which now is
released, and considers v3, or TRUC transactions, as standard as part of 28.0.
I would also plug the wallet guide.  I plugged it a little bit earlier, actually
roasbeef did, for using 28.0 P2P and policy features, including TRUC/v3
transactions.  But in the wallet guide, we also got into 1p1c relay, 1p1c RBF,
and P2As.  I should note that this Rust Bitcoin PR simply allows the v3 TRUC
transaction field and doesn't touch on those other features, and I didn't see
any sort of helper features or anything.  It's just merely the data structure
mechanics for adding v3 to a transaction.

**Mark Erhardt**: Yeah, I was just looking at the commit in here as well.  So,
it really only permits v3 and it does not enforce the topology restrictions that
are specified in BIP 431, as far as I can tell.  It apparently also does not
permit a zero-fee parent transaction.  So, it's a bit odd in the sense that it
makes v3 standard, but doesn't actually implement BIP 431.

**Mike Schmidt**: Murch, I see one question.  Oh, go ahead, Steven.

**Steven Roose**: If I can add, actually, even without this PR, you could
already create v3 transactions yourself.  I mean, you can do everything
manually.  I recently did the whole TRUC, 1p1c thing for Ark.  I think they're
just trying to standardize so that people feel more confident that the version
is actually right and it makes sense to set it.

**Mike Schmidt**: Murch?  I stopped hearing Steven in the middle of the
sentence.

**Mike Schmidt**: Yeah, okay.  Yeah, I wanted to make sure because this happened
before and I ended up talking over the guest.  So, it looks like he's dropped to
listener status.  So, maybe something.

**Mark Erhardt**: Well, so it looks like it just declared v3 standard.  That
might make sense, because Rust Bitcoin doesn't really have a huge portion of the
nodes on the network, so if they do not forward a lot of transactions, it's not
going to hamper anyone.  But for transaction creation purposes, if you see that
it's standard, that might make it simpler for the users of this library.  Yeah,
that's roughly what I gathered from Steven, but maybe if Steven's back now, do
you want to chime in again?

**Steven Roose**: Yeah, sorry, where did I drop?  I think my app crashed.  I
just wanted to say, yeah, I could probably summarize.

**Mark Erhardt**: Just take it from the top.

**Steven Roose**: You could already create transactions I think, whereas Bitcoin
is mostly used for wallets and end users, or end developers, so you could
already create all of the topologies that you wanted.  It might make sense for
the library to add some validation on maybe the TRUC topology stuff eventually.
But I think adding the version was mostly to make users feel comfortable that
it's the right version.  It's a version that makes sense, instead of just
picking a random number from a random integer.  So, yeah, it's a minor change.
You could already do the whole TRUC stuff, like I did manually.

**Mark Erhardt**: Right, that makes sense.  Thanks.

**Mike Schmidt**: Murch, we had one question here from Triple Max asking,
"Silent payments wallets would be taproot only, no?"

**Mark Erhardt**: Well, if they only receive via the silent payments addresses,
they would always receive P2TR outputs, yes, because silent payments payments
will always be P2TR outputs.

**Mike Schmidt**: All right, I think that's it for the questions.  So, thank you
to roasbeef and Steven for joining us, thanks to thunderbiscuit for jumping in
as well and some questions from everythingsats., and as always to my co-host,
Murch, and for you all for listening.  We'll see you next week.

**Mark Erhardt**: Cheers.

**Steven Roose**: Cheers, thanks for having me.

{% include references.md %}
