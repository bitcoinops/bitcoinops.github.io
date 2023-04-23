---
title: 'Bitcoin Optech Newsletter #246 Recap Podcast'
permalink: /en/podcast/2023/04/13/
reference: /en/newsletters/2023/04/12/
name: 2023-04-13-recap
slug: 2023-04-13-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Lisa Neigut and Niklas Gögge to discuss [Newsletter #246]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/68844979/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-3-18%2F9eda5cda-1b7a-6f75-0e30-338a49051222.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #246 Recap on
Twitter Spaces.  It's Thursday, April 13, and we have some special guests that
are joining us.  I'm Mike Schmidt, contributor at Optech and Executive Director
at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch.

**Mike Schmidt**: Hi, Murch.  Lisa?

**Lisa Neigut**: Hi, I'm Lisa, also known as niftynei.  I worked on Bitcoin Core
Lightning (CLN) implementation of one of the precursors to splicing, and I
currently am working on a side project, called Base58, where I teach the Bitcoin
protocol.

**Mike Schmidt**: Any upcoming Base58 events that you'd like to plug?

**Lisa Neigut**: Oh, yeah, I should definitely plug Bitcoin++, which is an
in-person Bitcoin technical conference we're running in a few short weeks here
in Austin, Texas.  You can find more info about the conference at our Twitter,
which is @btcplusplus.  We're super-excited about it, we've got an all-star cast
of people who are going to be talking about layer 2 technology on Bitcoin,
existing as well as new and proposed ways of doing layer 2 transactions for
Bitcoin.

**Mike Schmidt**: I went last year and it was great content and a great bunch of
attendees to hang out with, so I recommend it.  Niklas?

**Niklas Gögge**: Yeah, hi, I'm Niklas and I work on Bitcoin Core at Brink,
mostly P2P and fuzzing stuff.

**Mike Schmidt**: Excellent.  Well, thank you both for joining us today to lend
your expertise; we'll jump into the newsletter.

_Splicing specification discussions_

The first news item this week is about splicing, which we haven't talked much
about on this show.  So I think maybe, Lisa, we could start to calibrate the
audience a bit.  Maybe just what is splicing, and why do we want something like
that, what are the advantages; and then we can drill into the current state of
splicing and then some of these specific topics that have been discussed on the
mailing list after?

**Lisa Neigut**: Yeah, that sounds great.  I mean, it's such a great question.
I think splicing is one of the most exciting protocol updates to LN that I think
few people know about it.  I think it's one of those slowly growing in
consciousness, and probably the reason for that is that it's not implemented
anywhere yet, so you can't use it, so it's all mostly just something we're
excited about coming.  But to tell you what it is, to give you some background
on it, so right now when you have a LN channel, when you put funds into the
channel, you kind of have to decide up-front how much capital you want in that
one channel.  So, those of you who are maybe not as familiar with the LN
channels, you commit a certain amount of Bitcoin to one particular relationship
with one other peer.

So, let's say I wanted to put 100,000 sats to a channel between myself and
Murch, then at any point in time that gives me 100,000 sats that I can use to
pay Murch, or to pay out through Murch to other people.  But if at any point in
time I decide that really a relationship between myself and Murch deserves or
merits 1 million sats' worth of capital, then currently how would you go through
the process of adding more capacity in this channel between myself and Murch?
You'd have to close the channel, which is one onchain transaction, it has some
delays and times built into that depending on how much you're willing to pay to
get the transaction mined and what the mempool looks like, and all that.  Then,
I'd have to submit another transaction, so two transactions, to reopen the
channel.

Then any time that you close and reopen a channel, there's a period in time in
which for that 100,000 sats I had originally, I was able to make payments; while
the channel is closing and then while the channel is reopening, that's going to
be at least an hour, maybe more time, when you can't actually use that channel.
You can't keep making payments through this channel while you're basically
resizing the channel.

Splicing is a protocol proposal which will let you dynamically resize a channel,
so you can both go up, so add sats, go from 100,000 sats to 1 million in this
case; or, if I had 1 million sats in a channel and I wanted to maybe reallocate
some of those sats to another channel, or I wanted to pay someone onchain using
sats that are currently in a channel, I could use splicing to accomplish this.
And the really nice thing about it is you do all of this in one transaction, and
you can continue making payments with what's the left amount; whatever amount of
sats you still have in that channel, you can continue making payments.

It's a real big improvement in terms of what I like to think of efficiency of
where you put your sats in LN.  And one of the really cool grand vision things
is right now, when you have a channel, when you have LN and LN channels, you
kind of have to make a decision about how much of your -- let's say you have 10
million sats to allocate, maybe you run a business and that's your treasury, or
maybe you're just a normal consumer who uses LN to buy things.  And say you
have, I'm going to make up a number, like 10 million sats, you have to decide
how much of that sats you want to keep in an LN channel so you can buy things
with LN, and how much of that to keep onchain so that if you need to, you can
make onchain purchases.

Splicing makes it such that you can keep all of your sats, like all 10 million
sats, you could put into channels right now.  So, you have the opportunity of
making routing fees on those 10 million sats at any moment, so you don't have to
decide how much of that to keep onchain out of a channel to make payments.  It
allows you to basically use your LN wallet as an onchain or LN wallet very
easily.  So now, you can put all your money in a channel and if you ever need
to, or want to pay someone onchain, you can just splice out a balance out of an
existing channel.

So, it's really I think new and big and I think it's going to be pretty
revolutionary in terms of how we think about onchain versus in-Lightning money,
and it's coming and we're excited about it.  Does that cover it?  Is there
anything else maybe that I can speak to you about how splicing works?

**Mike Schmidt**: I think that makes sense.  It sounds like it would lower some
of the friction associated with LN, thereby encouraging folks to put more
liquidity into the LN.

**Lisa Neigut**: Yeah, exactly.  And it makes it such that when you do decide to
put capital into LN, if maybe I made a channel with Murch and then later decide
that I really needed a bigger channel with Niklas, in one transaction I could
move money out of a channel with Murch and into a channel with Niklas, and that
would all happen in one transaction; whereas before splicing, I think that would
take four transactions, one to reclose Murch's and then another to resize one
with Murch and then another to resize the one with Niklas.  So, it's just, yeah,
I think it's going to be really wild how much more dynamic it makes money on LN.

**Mike Schmidt**: So, I can do a splice out and a splice-out and a splice-in
then all in one transaction in this example, that you would maybe take half of
your channel capacity off of Murch's channel and put that into Niklas's all in
one transaction?

**Lisa Neigut**: Yeah, that's right, yeah.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: I was wondering, so I think that some LN implementations allow
multiple parallel channels between two nodes and some do not.  Can you speak to
the trade-offs of having multiple channels between two nodes versus having a
bigger channel and splicing?  I assume that it's actually nicer!

**Lisa Neigut**: Yeah, so as you mentioned, for a long time for CLN, you could
only have one channel per peer.  And the reason that we did that is we were
anticipating splicing.  As of a few releases ago, we went ahead and just made it
so you could have as many channels as you want.  But the ideal situation on LN
is that peers only have one channel between them.  I can explain my thinking
behind that; maybe other people have different.  I think there's definitely some
different perspectives on it.

So right now, the reason that multiple channels are kind of a thing that exists
on LN is really, it has to do with the fact that on the v1 of channels, only one
side has an opportunity to put money in the channel, right.  So, when you open
the channel, only one side really builds the transaction and then typically puts
their funds in it and then opens it.  I worked for a long time on a new
protocol, called dual funding, which lets both sides put money in the channel.
But when you can only have one side putting money in the channel, and you as a
person who -- so, let's say me and Murch have one channel, Murch opened a
channel to me with 1 million sats in it, but now I need to pay Murch, I can't
take the channel we have and splice into it and then pay him; I'd have to just
open a new channel and push money to Murch.

The reason that I think that having multiple channels is a little suboptimal,
part of the reason for that is now when you're trying to do routing, when you
create an onion message, you usually have to specify which route you want to
send it through.  So then now, all of a sudden, you need a dynamic router at
every one of the nodes that knows that between me and Murch there are two
possible channels.  So, maybe the onion that I'm routing said, "Go through
channel A", and really there's only capacity to route the payment through
channel B, both sides of the node need to know.  You have to add more logic to
the nodes such that they can route over any channel, no matter which one the
onion says, if that makes sense.  So, there's a little bit of inefficiency;
everyone has to do a little more work there.

The other thing about having multiple channels, it's a really huge cost on the
general network, it's one of the tragedies of the commons thing, every
additional channel that you open creates three new messages on gossip, and these
are a pretty chunky size.  They're some of the biggest gossip messages that we
have because they contain a lot of signatures.  So, every time you open a new
channel, you're creating a network cost of new gossip that everyone has to have
and maintain as part of their routing tables.

So, if we're able to introduce something like splicing, where there's really no
need for 99% of nodes to be able to have just one channel between you and -- for
myself and Murch, for example, and I can add and remove funds when I want, Murch
can add and resize funds when we want, then it really makes it such that it
just cuts out tonnes of duplicate information that exists in the routing table
right now.

**Mike Schmidt**: Niklas, I see your hand up.

**Niklas Gögge**: Yeah, if I splice-in, would I not send out a gossip message to
tell the network that there's more capacity?

**Lisa Neigut**: You would, but the old gossip message you had now can be thrown
away.

**Niklas Gögge**: Okay, yeah.  Sure, that makes sense.

**Mark Erhardt**: There's still the same amount of announcements, but you're
maintaining less data to have the whole network state; that's what you're
saying, right?

**Lisa Neigut**: Yeah, exactly.  Basically, you would make a new gossip message
announcement whenever the channel gets resized, but that basically replaces the
old one.  So, the net amount of gossip that LN nodes have to store and circulate
doesn't change; it's a constant size basically.

**Mike Schmidt**: So, now that we know what splicing is and some of the benefits
of it, maybe it would make sense, before we jump into the discussions that we
covered this week in the newsletter, to maybe just give folks an idea of where
we're at with implementing this feature on the LN.  It looks like the draft
specification that we noted in the newsletter is a couple of years old, it does
seem like there's work being done, but maybe you can quantify where you think
this feature is in terms of eventual availability to folks.

**Lisa Neigut**: Yeah, that's a great question.  So, I've been working pretty
closely with Dusty Daemon on the CLN side.  He's got a draft of it up,  it
works.  So, there's a working implementation that's in draft on CLN.  The async
side is the same, they have a draft implementation that I don't think has been
released yet, but they've been using it to do testing.  So, I think it's between
two implementations of what I would say -- I apologize to any implementation I'm
missing out, I usually think of there being four LN implementations; I know
there's a couple more than that.  So, half of the LN implementations currently
have a sort of in-draft mode working implementation of splicing, which is really
exciting.

What happens after that, at least for CLN side, is we need to get it through PR
Review and merged into master, and then it will basically go out as an
experimental feature, so gated behind an experimental thing.  Then I think async
is probably similar, if they haven't already launched it, or if it's behind an
experimental flag, etc.  So, once those go out and we can do interop testing,
then that will basically make its spec and it would be available on both CLN and
Eclair to work, and it would be something you could use.

So, I think we're actually pretty close with it.  As Mike mentioned, it's been
in process for a few years now.  It's a little bit of a difficult change to make
because of how many things you have to keep track of.  You can have multiple
candidate splices at the same time, so you could make a splice and then RBF it;
and then in the meantime, have a bunch of Hash Time Locked Contracts (HTLCs)
you're still keeping track of.  So, it's quite an involved protocol change, it
touches some of the more complicated state machinery of a LN node.  But we've
two implementations that basically mostly have it finished now, and I know that
the Lightning Dev Kit (LDK) team is ramping up to get it done.  I think it's one
of the higher priorities on their roadmap; they recently released a new roadmap.

So, I think there's a good chance of it being live on the network probably by, I
mean I think the safe thing is I say two weeks TM, but I'm kind of hopeful that
maybe by this fall, it will be available for people to use, at least maybe in an
experimental fashion, if not actually fully ratified and adopted into the spec.

**Mike Schmidt**: We highlighted a couple of discussions that were going on
regarding the spec in the newsletter, and there's also a diagram for folks, if
you want to follow along, in Newsletter #246.

_Which commitment signatures to send_

But the first thing that we highlighted, the first segment of discussion was,
which commitment signatures to send.  So, we're jumping a bit deeper into the
weeds here, but Lisa, can you summarize what this discussion is about, about
these different commitment signatures and parallel commitment transactions, etc?

**Lisa Neigut**: Yeah, definitely.  So, I think the ones you're referring to,
this kind of goes back to -- so, this discussion in particular, the one that
Mike referenced about which commitment signatures to send, kind of has to do
with the central debate there is around how you design a protocol, so to speak.
And the general idea is, when you're making a new splice transaction, so let's
say I'll go back to the example of Murch and I have a channel, I've got 100,000
sats in it, I want to make it bigger, I want to make it 1 million sats, so I
made a splice to splice it in; Murch and I have agreed on the new transaction
that's going to have my 1 million new sats in it, so now we've got a transaction
which is going to replace our existing funding transaction onchain.  So, we've
made that, we've broadcast it.

We've made it, this is really in the weeds with LN, but basically when you make
a new transaction, a new funding transaction on LN, before you send it out you
need to get signatures for what we call the outputs on it.  So, you need
commitment transaction signatures before you broadcast it.  There is a little
bit of a debate in whether or not when we send that, we need to send signatures
for all the existing transactions that we already have, or should we only
incrementally send signatures for the new transaction that we're creating, and
it was just what are the pros and cons of doing that.

I think we all, after a long discussion, decided that the right way to do it is
to, when you've negotiated this new transaction, only send the new information,
so all that you would need to send are the signatures for the commitment
transaction and any HTLCs off of this new funding transaction that you've got.
But the bigger picture there is that a lot of times, any time that you send new
commitment signatures for splicing -- maybe I'm going the wrong direction here
in terms of explaining things, but the other reason you would send new
commitment signatures, so maybe that's an easier way.

Whenever you create a new funding transaction, you have to exchange commitment
signatures.  But there's another time you have to exchange commitment
signatures.  That other time that you exchange commitment signatures is any time
that a payment moves through the channel.  So, if I've got a commitment
transaction and then I send a payment out through -- what am I saying here?!  If
I have a channel with Murch and I'm sending a payment out through it, so I'm
sending a payment over to Murch, in order to do that we're going to need to
update our commitment signatures, so that means basically exchanging some
information between us.  And if we have a splice in progress, we have to update
not just the current funding transaction, but we also have to exchange these
signatures for any potential splice transaction that might get mined some time
in the next whatever.

So there's potential that basically, when the commitment transaction gets
updated, we have to send a bunch of new signatures, just to make the new stuff
in whatever.  I see Murch, is your hand up?  I'm going to say, yeah, go ahead.

**Mark Erhardt**: Yeah, I just wanted to sort of recap what you just said.  So,
in an LN channel, we have funds, in this case Lisa and I have funds in a
channel, which means really that we just have a shared UTXO that we own with a
2-of-2 multisignature.  Now, it would of course be unsafe to just put money into
a 2-of-2 multisig pot when I don't know whether the other partner is going to be
available all the time, so we want a way to recover the funds if the other
partner loses their device, goes offline, or any other such thing.

So, before we even broadcast a transaction, we get the commitment of the other
side that allows us to take out the funds unilaterally, and that's actually what
we needed segwit for, because before segwit, there were ways of changing
transaction IDs on unconfirmed transactions, which made it impossible to chain
unconfirmed transactions reliably.  So with segwit, we can chain other
transactions on top of unconfirmed transactions, while even if someone malleates
stuff, it doesn't affect the txid, so a whole chain of unconfirmed transactions
is safe.

With a splice-in, we have a second funding state that follows our first funding
state, and we have to basically chain all of the commitment transactions on top
of that funding, just to -- I'm just repeating what Lisa said, in other words!

**Lisa Neigut**: Yeah, we're definitely in the weeds here, I think, on how LN
works.  This is probably one of the more crucial and also complicated things in
LN, in my opinion.  When I was learning it, it took me a long time to understand
what all this was.  Anyway, so we have this process basically, where you have a
channel open, for how we re-send signatures, and the whole debate was, should we
re-use the existing process that we have, where we just re-send everything; as
soon as we send a new commitment, we just re-send everything, which is exactly
the right thing to do in the case when a payment is being made.

However, when a new funding transaction basically gets spliced as being a new
splice transaction's negotiated, you could sign and re-send everything but you
really don't need to.  The only thing you really need to re-send is the new
information, the incrementally new information that you need, which would be all
the commitment signatures just for that new splice transaction, if that makes
sense.  So, one of the things at least in the implementation I thought is kind
of interesting.  It's not something that you really think about if you're not
really used to talking and designing specs, so to speak, but one of the
interesting things about -- basically, we have this process that we use all the
time.

Should we use the process that we use all the time, which is to re-send
everything across everything, even though none of that information is new, your
peer already has it, we're not giving them new information; for the sake of
simplicity, should we just re-send everything, so there's never any exceptions
or any cases where you're not sending?  That would make sense, but just from an
implementation standpoint, the spec would make it such that it's very simple;
there's one way you do it, you always re-send the commitment signatures and then
whether it's a payment moving or a new splice, you just use the same process.
So, that's nice because it cuts down the amount of code, it cuts down on the
amount of, in theory, branches that you need in your implementation because
there's one way that we do it and that's how we're doing it.  So, that's the
"send all the signatures" debate.

The other side of that, which I think is interesting, is what new information do
we need?  This is the minimal protocol design.  When you think about protocols,
a large part of the thinking around how you design them is what's the minimum
amount of information I can send to get the job done.  So, from that
perspective, when a new splice transaction is negotiated and created, the only
new information that we need to send is the commitment transactions for that
particular new splice.  So, from a protocol perspective, you can cut down on
potentially re-sending a lot of data the peer already has by creating a special
kind of case in the code, where in the case where you've made a splice
transaction, you only send the commitment sigs for that new transaction.

So, from an implementation, and in terms of the amount of code you need to
implement the spec, it's a little bit more because now you need to be aware of
these two different situations, one situation where you only send one, the other
situation where you send everything.  So, that's the thing we're going back and
forth with as spec designers that are working on how LN should work at a spec
level.  So, the post that I made to the mailing list I think walks through these
two cases, and I reached the conclusion that yeah, we should probably just send
the more minimal set of new information that we don't have yet.  Yeah, Murch, go
ahead.

**Mark Erhardt**: I was just wondering now listening to this description, if I
only need to send the new state and I'm in the situation that I've lost maybe a
few of the latest updates of my channel because of a backup error, could I not
just request that we splice-out or splice-in some funds, and then have the other
party commit to the new state and me commit to the new state, and thus flush out
all of the old channel toxic backup mess that I no longer can actually serve;
would it be a nifty way to recover into a new channel from a lost state?

**Mike Schmidt**: Nifty, huh?!

**Lisa Neigut**: Yeah!  So, when you do a splice transaction, yes, you can
delete and throw away all of the old data, so that's actually one of the amazing
things in CLN that we do, and is from an implementation standpoint, once that
splice transaction is confirmed, so that's not when you broadcast it and sign
it, but after it's onchain and buried, I think we wait three or six blocks, then
yes, you delete all of the old data; it's the way you can clean up.  So, if you
had a channel that's been alive for years and you want to reduce the amount of
size that it's taking up on your database, this is all pre-eltoo, "Eltoo fixes
this TM", yes, that will let you.

So, yes, as long as you can get to the point with your peer where I believe you
are trying to think if you need -- my understanding of exactly the mechanics
between revocation are a little hazy, I don't know if you -- there's some
assumptions here about, let's assume for whatever reason that you have the most
recent commitment transaction but you've lost 80% of the historic history for
that channel, I don't know how you got in this situation, because there's some
stuff at start-up that if you don't have exactly the right state, your channel
will fall into an error state basically.  But assuming we avoid that, assuming
that your problem is that you've lost 80% of the channel state but you're still
at the most recent thing, then this is a problem because if your peer somehow
figures out that they're -- tries to force close on you in that window of 80% of
stuff that you don't remember, you basically lose all the funds in the channel,
I think, you basically can't recover them because you can't find them.

But if you splice, if you make a new splice, if you know this has happened and
you splice the channel, then yes, all of that old history would be deleted
anyway.  So from then on, you can basically take a channel where it was in kind
of a dangerous state, you can splice, and that will basically reset the whole
history from the point that the splice happened.  So, yeah, it's actually a
really great way I think of -- eltoo fixes a lot of this but prior to eltoo, a
way of maybe reducing the amount of data that your node has to store and
maintain.

_Relative amounts and zero-conf splices_

**Mike Schmidt**: There was a second bit of banter about splicing that t-bast
brought up separately, and he talked about relative amounts, and I'm curious,
what does he mean by these relative amounts; and why is it important that we use
relative amounts when splicing?

**Lisa Neigut**: Yeah, Murch, you've got your hand up.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: Yeah, I was going to follow up on something from the previous
topic, but I can also bring it up later.  I think the relative amount stuff is
just, you would usually talk about the absolute balances of the sides in the
channel when you negotiate stuff.  But in HTLCs, we also already assign a
certain amount to an HTLC, so I'm not quite sure about the terminology here.
Relative amount seems to indicate to me just the amount that you want to
splice-out in absolute terms, but maybe I'm misunderstanding this.

**Lisa Neigut**: No, I think you're right on there, Murch.  So, maybe some
history here is useful for understanding why we're having this discussion.  So,
a lot of splicing is based on the current how you open a channel and when you
open a channel, you can only do opens in round sat amounts, because round, whole
sats is the only thing that onchain acknowledges and admits to existing.  So,
when you're opening a channel, you're basically like, all right, I want to put 1
million sats in, but just a whole sat amount.  And when you go to splicing then,
you had this problem that they were kind of using the same idea where it's like,
okay, we're going to make a new splice channel and the new splice channel is
going to have 2 million sats in it total.

Part of the problem there is that as the LN channel is operating, so as funds
are moving back and forth, you can send a fraction of a sat!  I'm laughing,
because it's like on Bitcoin you say you can send a fraction of a Bitcoin, and
on LN you can send a fraction of a sat.  And the problem they started as the
implementors were getting into it, they started running into problems, because
when you're making a splice, a splice is a whole sat amount, it's going to be
onchain.  The only level of granularity that we have to express amounts onchain
is in sats.  But in LN, we maintain balances that are fractions of sats.

So, they're making this problem of, if we're renegotiating a splice and we're
communicating the whole dollar, like the whole sat amount it's going to be, what
do we do with this residual sat amount?  The suggestion from I think BlueMatt
actually was the first one to point it out, is okay, you can just leave that
because you're just renegotiating a sat amount.  So, one way that you get around
this in the spec then is instead of saying, "Okay, we're going to take a 1
million sat channel and make it 2 million sats", you say, "Okay, I'm going to
take my existing channel, I'm going to add 100,000 sats to it", or, "I'm going
to remove 50,000 sats"; so now we're communicating around differences, like I
want to add or subtract a difference, instead of the goal of this new channel
balances this amount.

The nice thing about that then is you can take the existing balance and apply
the diff, if that makes sense.  So, if I had a channel that had 100,000 sats in
it, 0.001 BTC, because in LN you can have fractions of a sat, and then I said I
wanted to add 100,000 sats, then I would just take the 100,000 and add that to
my existing with the residual balance and it all works out fine, there's no
complicated math.  Whereas, if I had said, "I want the new channel balance to be
200,000 sats", now it's like, okay, what do I do with that residual?  So yeah,
Murch, I think your hand's up.

**Mark Erhardt**: Yeah, I wanted to point out that we had a pretty interesting
discussion with Tadge Dryja on millisatoshis (msat) and even very small amounts
of satoshis being not really representable in the LN, because creating an HTLC
costs more than the amount of money that is being transferred and there is some
odd behaviour around that in general.  So, if you're interested in that, you can
look at the Chaincode Labs podcast from recently.

**Lisa Neigut**: Oh, that's awesome, yeah.  I also did a presentation at Bitcoin
Conference 2019 around the sub-sat payment stuff, about where they go and the
security model.  So, I'll have to check out that podcast that you guys did then,
that sounds really interesting.  Yeah, I'm curious to see what Tadge has to say.

**Mark Erhardt**: Well, he actually hates them; msats!

**Lisa Neigut**: Yeah, I'm pro-msats, I think it's a really cool thing that
we're able to do in LN, because I see LN as being pro-micropayments, and at some
point when there's sat/dollar parity, being able to send a fraction of a sat
will probably be a killer application of the LN.  So, I think it's a useful
thing that we should maintain and try and keep as part of what LN is capable of
doing.  We're in a good place, because we already added it, we did all the work
engineering to make it a platform for when that's possible.  Anyway, that's a
whole separate discussion.

Anyway, I think the relative amount thing is really nice.  I also think, just
thinking about it from designing the UI, it's so much easier to say, "I have a
channel and I want to add 1 million sats to it" or, "I have a channel and I've
got a balance of 100,000 sats.  I want to remove 50,000 sats from this channel,
I want to make a payment out of 50,000 sats from this channel", as I think just
from an API perspective and a spec perspective, it's just so much easier to
think about and reason about, because now you're making the spec around the
intention of the action that you want to take, rather than, you know, the total
amount in the channel's going to be secondary calculated off of this intention.

So, yeah, it took some time and we've had to use a couple of iterations here on
trying to do it with just asserting a balance, a goal balance, and now we've
gotten to in the spec, you would assert instead of a goal balance for the
channel, you would say, "An action that I would like to add, or would like to
add or remove this amount of sats".  And then again, it's really cool, because
then you can express that in sats and it's very easy to take the existing sat
balance from the previous funding transaction and either add or subtract that
amount and there's no fractions, there's no residuals, you can still hold on to
your relative balance as a secondary thing that you calculate independent of the
chain, but we don't have to deal with rounding or who gets that weird sat stuff.
I think it will be a neater way, a cleaner way of implementing this splicing
protocol, which is cool.

**Mark Erhardt**: Yeah, that sounds like it to me as well.  I mean, you're
basically negotiating a change of your current state, and talking relative to
the agreed-upon state just seems way cleaner.

**Lisa Neigut**: Yeah, exactly.  Anyway, some of this splicing stuff I think is
interesting because I think this has been a really good opportunity for us as LN
spec developers to expose some of the thinking that goes into protocols, like
what does it mean to be an LN spec engineer or to work on protocol design, and
these are exactly the sorts of questions I think that come up and you end up
thinking through and making decisions on as a spec body, which is sort of fun,
and definitely I think a different kind of engineering than most people do when
they're writing an application, etc.

**Mike Schmidt**: Murch, did you have a question that we glossed over earlier,
or anything else that you'd like to talk about regarding splicing?

**Mark Erhardt**: I kind of forgot what I wanted to ask earlier, but I did have
one other point.  I wanted to point out that there is of course a trade-off.  If
you're making a splice-out in order to pay someone onchain, you now need to
negotiate and you're dependent on your channel partner to make that payment, so
(a) they learn about the payment of course, and (b) they could delay it or slow
it down, or the same stuff that they could do to your LN channel.  So, it's
unlikely that they're going to be uncooperative, but there are some trade-offs.

I was also wondering, I think the cost of doing that is pretty good.  I was
considering how it compares to making an onchain payment in the first place but
assuming that we're moving to P2TR MuSig channels, it will look like a taproot
key-path spend to spend a funding transaction into the new funding transaction,
and therefore I think it's actually way cheaper than closing a channel and
opening a channel, or making an onchain payment in the first place, or similar.
So, yeah, I agree that the overall cost structure of using a bigger channel and
then splicing-out, if you need to make an onchain payment, seems pretty
reasonable.

**Lisa Neigut**: Yeah, and I think one thing that's pretty cool then is,
splicing really gives you the ability to keep more money in LN or more sats in
LN, and the cool thing about that is, depending upon your topology in the
network, etc, is that the amount of time in theory, this is all a little
theoretical, again it depends on the network topology and where you are and the
liquidity towards you; but in theory, it means that you're able to possibly earn
routing fees on capital that otherwise you might have had onchain, etc.

**Mark Erhardt**: Jim, you have a question or a comment?

**Surferjim**: Murch, I struggle to understand the technical stuff, but it's a
desire of mine to understand it, and I missed part of the beginning of this
conversation so if you addressed it, I apologize.  Am I wrong to view splicing
each time you do it as some form of an onchain transaction has to happen; and if
so, how is that different than closing and reopening a channel, except that it
sounds like two transactions versus maybe one as an update; am I seeing this
accurately?  Thank you.

**Mark Erhardt**: Thanks for your question.  Yes, you do see that accurately.
You're essentially recasting your channel into a new channel, and that requires
an onchain transaction because you're creating a new funding output.  And it is
cheaper than closing and opening because instead of two transactions, you can do
it in one transaction.  And since it's cooperative with the other party, we were
just talking about the cost of that, assuming that we get the P2TR MuSig2
channels eventually, it will look like a P2TR key-path spend, so it's going to
be pretty cheap.

**Surferjim**: Thank you for that.  Is it inappropriate to ask Lisa to describe
how it will be better with eltoo, which I have heard about, but if you asked me,
"Jim, what's eltoo?" I couldn't tell you, but I've heard about it and I know
some people are excited about it and I know it brings benefits if it's adopted.
But what would be the difference between splicing and eltoo; and why is eltoo so
much better, if that's appropriate for this conversation?  Thank you.

**Lisa Neigut**: Yeah, I can answer that.  So, splicing and eltoo are different,
they do different things.  You can have either of them independently and they
will work just fine, so they're not really dependent on each other, they're not
really in competition, I would say, in terms of what they're looking to do.
Splicing has to do with, I have money in a channel, I want to move more money
into the same channel, or I want to move money out of an existing channel
onchain.  Splicing is the way that you're able to do that, or one way, I don't
know; it's the way that we've been working on that will let you do this.

Eltoo works at a different level, it does something different.  The kind of
thing that you can do with eltoo is right now, whenever you make a payment, it
has to do with when you make payments through LN channels, how long do you have
to remember that you made that payment, if that makes sense.  So, if I route a
payment through my channel from Murch over to Niklas, how long do I have to
remember that I made that payment?  Now, I probably won't know that it was from
Murch to Niklas, or whatever, but I do kind of have to remember that at one
point in time, I've moved money through that channel.  And I have to remember
every single time that I've moved money through a channel, so this becomes -- we
call it the toxic waste problem on LN.  And every time you make a movement of
money through an LN channel, you have to remember it, and this is really
difficult for backups.

It's sort of a nightmare from, I run a computer and I keep this application
working and if anything goes wrong, I can recover from it.  It's quite a
difficult situation and problem in this current state of LN and that's just how
it is.  Anyway, so that's the current problem.  Eltoo fixes this problem of
toxic change, and the way that it does it is it makes it such that you'd no
longer have to remember the historical state of what your channel balances were.
Now, all that you have to do is remember the current state of play, the most
recent one that you know about, so it goes from being every time I move money
through this channel I have to make a note of it, to all I need to keep track of
is the most recent balance.

So, that's an enormously huge savings in terms of backup history.  You can throw
all the old state away every time money gets moved through a channel with eltoo
and it's going to be really good I think, but they're separate.

**Mark Erhardt**: All right, then, one more then we'll wrap up the topic I
think.

**Surferjim**: Okay, yeah, so when you say you have to remember transactions or
channel updates, is that like being your own watchtower essentially, so that the
other side of the channel can't close out an old state without you knowing it
because you don't remember it; is that what I'm hearing you say, and that eltoo
takes that away somehow?

**Lisa Neigut**: Exactly, 100%, that's exactly the thing, yeah.

**Mark Erhardt**: Yeah, so basically eltoo is a new update mechanism for the
channel state.  Where we currently use LN penalty, eltoo gives us a new way of
keeping track of what state the channel has.  And with eltoo, we only need to
remember the current state, whereas with LN penalty we need to remember all
previous states, and especially the penalty transaction tools so we can punish
the other side if they cheat.  With eltoo, we can just overwrite them when they
cheat with the latest state.  We can always enforce that the latest state
happens.

So, these two are just different ways of updating the state of the channel with
the funding transaction remaining the same throughout.  And with splicing, we
change the funding transaction, so we increase the capacity or decrease the
capacity of the channel.

**Mike Schmidt**: Excellent.  Well that was quite a great in-depth news topic on
splicing.

_Proposed BIP for transaction terminology_

We do have another news item that I think we should move onto in the interest of
time.  There is a new proposed BIP for transaction terminology.  And
fortunately, we have the author of this proposed informational BIP to talk about
the motivation of the BIP and what's in there.  Murch?

**Mark Erhardt**: Hi!  Yeah, especially around the office and in my previous
job, I used to have lots of discussions about transactions.  Bitcoin
transactions have a set of components and they have a lot of conceptual aspects
that many people use different names for.  So for example, if you think about
the scriptpubkey, which is the output script that sets the conditions by which a
UTXO can be spent, there's a number of different ways of referring to that and
the function.  So anyway, I had a bunch of discussions around the activation of
taproot and started thinking about someone should really write up a set of
vocabulary so we can skip the part in every conversation about this topic where
we first establish what we call everything!

So finally, 15 months later, I've written it up to a degree where I'm happy to
share it.  I posted it to the Bitcoin-Dev mailing list and I'm looking for
feedback, especially from people that are describing Bitcoin transactions
frequently, or have written books about the topic, or are in the process, to
take a look at the terms, whether they match their expectations.  Anyway, there
is a link in our newsletter, if you're interested in that sort of bikeshedding
and pea-counting, please take a look.  And I see Dusty joined us.

**Dusty Daemon**: Hey, yeah, someone just let me know you guys are talking about
splicing; I guess I missed it.  What was the update?

**Mark Erhardt**: At this point, we will need to make you listen to it later,
because we just finished 45 minutes of talking about it!

**Dusty Daemon**: Sure, I just wondered if there was anything I could add,
because I'm right in the middle of all the splicing stuff?

**Mark Erhardt**: Oh, cool.  I think we got it pretty well covered but maybe if
there's follow-up soon, when we hear more about the implementations and the spec
progress, we'll ask you to come on.

**Dusty Daemon**: Yeah, sounds great.  I mean the implementation that I've been
working on is just about done.  I'm waiting on Lisa actually to finish the
review, but I'd be happy to talk about it any time.

**Mike Schmidt**: Excellent, thanks for that, Dusty.  Yeah, we'd love to have
you on.  Clearly, there's some interest in this topic as we've gone almost an
hour on it, so perhaps if there's a way to work it in, in a future recap, we'd
love to have you.  We'll be publishing this as a podcast, so you can go back and
listen and feel free to correct anything that we've discussed, or augment any of
that when that's out.

**Dusty Daemon**: Cool, let's go!

_Don't download witnesses for assumed-valid blocks when running in prune mode_

**Mike Schmidt**: Let's do it!  The next segment of the newsletter this week
involved our monthly segment on the Bitcoin Core PR Review Club, and Larry did
the write-up for this and he chose the PR by Niklas, who's joined us, that is
don't download witnesses for assumed-valid blocks when running in prune mode,
and I think we actually covered a Stack Exchange question previously related to
this topic, and it's great that we have Niklas here.  I'll let Niklas speak to
his motivation for creating this PR and what exactly it solves.  Niklas?

**Niklas Gögge**: Yeah.  So, I guess the motivation basically is that it's a
performance improvement for Initial Block Download (IBD), so it makes IBD a bit
easier because you have to download less stuff.  And to be specific, it
currently would be around 100 GB that you would save with the PR.  Maybe to get
a little bit into how this works, so basically the PR only works if you're
running in prune mode and you're using assumevalid, and assumevalid is on by
default in Bitcoin Core.

So, prune mode is basically when you're a full node but you don't keep all of
the historical blocks, and that's completely fine, you can still validate all
new transactions and blocks.  The only thing you can't do if you're running in
prune mode is to serve old blocks to other nodes, but that's just nice of you if
you're doing that.  Then, assumevalid is also a performance optimization that is
turned on by default, where Bitcoin Core skips script validation up to a certain
known-to-be-good block, and every release we update this known-to-be-good block
in the Bitcoin Core release.

If you're running prune mode and you're using assumevalid, so if you're
downloading witnesses but you're not validating them, then shortly after you're
pruning them away.  So, the PR's basically, instead of doing that, just skip
downloading the witnesses.

**Mike Schmidt**: Niklas, in your experience in drafting this PR, was this
something that should have been in previously, was considered previously, or
does seem like something that should have been in an earlier PR, and potentially
this was motivated by some of the ordinals witness bloating; is that what
brought this to light, or was there discussion of this previously and it just
wasn't a priority at the time?

**Niklas Gögge**: Yeah, I should have said, this is not my idea.  The oldest
known place where this was mentioned that I know of is a blogpost from 2016 on
bitcoincore.org, where the blogpost in general is about the benefits of segwit,
and then one sentence about, "We can just skip downloading the witnesses as it
performs optimization".  Then I don't really know why it hasn't been implemented
so far, I guess because just nobody worked on it.  But also, in the beginning
after segwit, there wasn't that much witness data, so it wasn't really worth it.

But now, it's like 100 GB and as you said, if we have most of the ordinals, or
maybe any sort of protocol that produces large witnesses, it would make this
more beneficial.  And the thing where I saw this was a thread by Eric Wall,
where he talked about how ordinals would make this even better.

**Mike Schmidt**: In the Stack Exchange question that we covered previously, I
think sipa had answered, "We hadn't really thought of this, this should be
done", but there are some additional checks that even if you skip some of the
validation, there are some other checks that are done that would need to be I
guess explicitly ignored, and there are some questions in the PR Review Club
about that.  Can you talk about those other checks; and why does it work out
that you don't need to add any specific code for skipping those checks in the
future?

**Niklas Gögge**: Yeah, so the only check that you need to explicitly skip is
the witness merkle root, and then the other checks, I can't list all of them,
but there are some resource requirements on, for example, the size of the
witnesses or the size of each witness stack element.  And it turns out, if
you're validating but you're not even downloading the witnesses, so empty
witnesses just by default pass all the checks; if you're skipping script
validation entirely then empty witnesses, they pass all the resource checks and
stuff, so that's why it just works out without explicitly handling that.

**Mike Schmidt**: Murch, do you have any questions or comments on this PR?

**Mark Erhardt**: I think I would like to add a metaphor, well, not metaphor,
but you can think of the node just pretending to be a non-segwit node while
you're in the assumevalid phase.  So, assumevalid in general is an optimization
where we do not check the signatures, because transactions have been buried so
many weeks and months that we assume if there was a mistake in that, nobody
would have built such a long chain on them.  And we set that explicitly in
Bitcoin Core to a few months before the release, so we still rebuild the whole
UTXO set from scratch, but we do not check every single signature in that case.

So, with segwit, we've moved a lot of those script arguments into the witness
data and we're not checking it, so we're downloading it for nothing and then
throwing it away immediately when we get to the pruning depth, only for pruning
nodes.  So basically, we're just short-circuiting that by pretending that we're
non-segwit nodes, and we download only the script transactions which include the
information which UTXOs are destroyed and created.  So, we still build the whole
UTXO set just as we had before, we almost do all the exact same checks that we
did before, but we can save about 110 GB of download.  And I think if the
current block space demand keeps up the way it is, that value's going to grow
quickly.

**Niklas Gögge**: Yeah, that number can only go up.

**Mike Schmidt**: Yeah, so thank you for putting this together, Niklas.
Obviously, IBD's important and folks running nodes is important and this seems
like a great savings, I think.  In the Bitcoin Core PR Review Club discussion, a
participant pointed out that 110 GB that was saved is 10% of his ISP
download limit, so there's real practical gains to be had by this PR.

**Niklas Gögge**: Yeah, I'd say it's a rather easy win.  I mean, the original
patch that I opened the PR with was much simpler than it is now, but yeah, even
if you handle the edge cases I think the extra complexity is worth this big of a
win.

**Mike Schmidt**: Jim, you have a question?

**Surferjim**: Yeah, interesting that Murch essentially answered a question I
was thinking about with regard to the risk of not validating stuff, and by
comparing it to a non-segwit build was very helpful for me.  In all of Bitcoin,
you have to always look at the downside of any proposal, that's why it's a pull
request, and it has to get looked at and everybody wants to be cautious.  I
don't hear a downside to this, but is anybody vocalising there's a negative
possible outcome by implementing something like this?  You guys all seem super
in favour of it, it does seem pretty benign, but I'm just curious, I'm playing
Devil's advocate; what's the downside?

**Mark Erhardt**: Yeah, I think that's a fair question.  So, one person in the
online discussion brought up that we would essentially reduce the number of
people that download the witness data every month, and have an actual check on
the witness data being present on the network.  I think that's sort of true, but
doesn't really matter much because I think if we look around in this Spaces, for
example, a lot of us run a full node to have our complete copy of the
blockchain.  Currently, full nodes only offer blocks for download if they have
the complete block, including witness data.

So, in order for people to start serving blocks non-segwit and actually also
removing witness data locally, you'd have to assume that they want to have a
full copy of the block chain, but don't want to have the witness data, which
seems like a bit of a stretch in the first place for me.  And then, gratuitously
downloading the witness data for nothing and throwing it away does not seem like
the best way of checking that the witness data is present.  Just running a full
node with the whole block chain and then first downloading the whole witness
data and checking it is a much better check, and I think a lot more people do
that already.

So, I'm just not at all worried about this vector, but yeah, basically if we
make it too easy, or the fear is if we don't require witness data and make it
too easy to not keep the witness data, eventually maybe people won't have the
witness data, but I don't share this concern.

**Mike Schmidt**: Niklas, did you have any other potential downsides to add to
that?

**Niklas Gögge**: No, that would have been the only one that I would also point
out.

**Mike Schmidt**: And, Niklas, anything else that you think would be important
to outline regarding this PR and the associated PR Review Club?

**Niklas Gögge**: Not really, but I should focus working on it and get it done!

**Mike Schmidt**: What work remains to be done?

**Niklas Gögge**: I think it's just ironing out edge cases and writing a bunch
of tests mostly, just some internal database stuff that I need to figure out
which way we want to go, but that's probably too deep in the weeds for this I
guess.

**Mike Schmidt**: That's fair.  Well thanks, Niklas, for this PR and thanks for
joining us to explain it.  Murch, onto the releases and release candidate
section, Murch?

**Mark Erhardt**: Sure, of course.

_Libsecp256k1 0.3.1_

**Mike Schmidt**: All right.  Well, the first one we noted was a security
release for libsecp, and it looks like there's an issue related to libsecp being
compiled with Clang version 14 or higher, that would allow a vulnerability in
the form of a side-channel attack.  So, there's a strong recommendation to
upgrade if you are dependent on libsecp.  Murch, are you familiar with this
potential for side-channel attacks and libsecp and some of the technical details
there?

**Mark Erhardt**: I can talk a little bit about the general concern of why we're
trying to do this.  So, if you are running cryptographic code, you want it to
behave from the outside always the same.  So, even if you have different private
keys for different signatures, you don't want to have visible change in the
behaviour from the outside.

So there was, for example, an attack published on Trezor, I think it was
probably almost ten years ago by now, where someone measured the electricity
going through the cable of the Trezor while they were signing, and was able to
learn the private key just by making lots of signatures, because they were
drawing a little more power when a bit was set and a little less power when the
bit was not set.  I think that person then started working at Trezor, so it
worked out in the end, they also fixed that.  But generally, the idea is for all
of these cryptographic operations, you always want to make sure that there is no
leak, no side channel by which you can glean information from running the code.

So, libsecp implements a lot of the crypto that we use in Bitcoin Core, like the
signing, the inverses and all that, and all of the relevant things that touch
secrets are implemented in constant time.  So, every time you run it, whatever
the secret data is, it will always have exactly the same steps in constant time.
So, Clang here was getting too smart, the library that we use to run this code,
and it optimized out some section in cases where it wasn't needed and made it no
longer constant time, so this update fixes it.

**Mike Schmidt**: Great explanation, Murch.  We had a question from the
audience.  Baljeet?

**Baljeet**: Hi, sorry I couldn't join earlier on, it's regarding the
assumevalid; I have a question if you don't mind, please?

**Mike Schmidt**: Go for it.

**Baljeet**: Yeah, by doing the assumevalid, Jim was asking if there's any other
trade-offs, but would this PR introduce a trust factor, like are you assuming
that it's already been verified, the signatures have been verified and the
transaction is valid; instead of checking it yourself, you're getting a snapshot
of the chain until a certain height and assuming all those previous transactions
are all valid; is that a concern?

**Mark Erhardt**: So, yes and no, but not really.  So, we're already using
assumevalid by default in Bitcoin Core when you do IBD.  What we do there is
basically, we check whether a specific block hash is present in the best chain
that is being served to you, and if that is the case, up to that point we assume
that the block chain, all the signatures of the transactions that you will see
up to that block are going to be valid.

So, we assume validity in the signatures; we still look at every single
transaction, check that it is well-formed in general; we still build the UTXO
set from scratch ourselves, we just don't actually check whether all the
signatures were valid.  And with the shortcut that Niklas introduces now, we
actually don't download some of the signature data for short, because we're not
going to check it anyway.  Instead of downloading it, going a few blocks further
and then deleting it again, we simply don't download it in the first place.

So, the security trade-off here is, you still look at the main body of the
transaction, this whole strip transaction, and check all of that; you check that
the transactions were present in the block; you check that the block chain
headers are intact, and that's where actually the proof of work happens, so you
check the proof of work, which is very hard to fake.  So, the amount of trust is
basically just, "I trust that someone else has the remainder of the data, the
witness data, and could serve it if I wanted it", but other than that I think
it's really benign.

**Baljeet**: Cool, thanks for that, that makes sense.

**Mike Schmidt**: Yeah, thanks for your question.

_BDK 1.0.0-alpha.0_

The next release from the newsletter is the BDK 1.0.0-alpha.0 release, which we
discussed previously, and described in Newsletter #243, and we also had Alekos
on to explain some of the architectural changes that went on in that.  So, look
back to that newsletter and our recap of it for more details.

_Core Lightning #6012_

Moving on to the notable code and documentation changes, we have a slew of PRs
here, mostly Lightning.  The first one is Core Lightning #6012, which implements
significant improvements to the Python library for writing CLN plugins.  So, CLN
has a pyln client which serves two different purposes.  First, it allows you to
run commands, Python commands, against your CLN node to do certain things; and
secondly, it also serves as the basis for making CLN plugins.  And CLN has this
plugin architecture where if you want to add any functionality, you do that in
the form of a plugin.

So, if you're doing a Python plugin, you would use this library to implement
that plugin to add whatever sort of functionality you want to your LN node, and
this PR added a bunch of gossip-related features to the Python library, which is
especially helpful for plugins that do LN analysis and optimization.  Perhaps,
Lisa, if you're still on, I don't know if you're familiar with this PR, but you
could add to that or correct anything I said?

**Lisa Neigut**: No, I'm not familiar with it, I was just going to see if I
could pull it up really fast to get a look at it.  Unfortunately, I don't really
just off the top of my head.  Let me see if I can find it in a list of stuff.
Oh, no, I haven't looked at this but it seems really nice, yeah.  I'll click
into it and look at it here really fast.

**Mike Schmidt**: Sure.  Maybe Murch can buy you some time!  Murch, did you get
a chance to look at this PR or library?

**Mark Erhardt**: Yeah, I was actually staring at that a little bit this morning
in order to figure out just exactly what the extent of the Python part of CLN
is, and you kind of already answered most of my questions in that regard.  So,
this is an attached library that comes with CLN that is only used for these
plugins; is that right?  It's not a re-implementation of the LN protocol that
would be able to create gossip, or anything like that?

**Lisa Neigut**: That's right.  I can't tell if I've got my speaker on or not.
Okay, cool.  So, pyln is a part, in some ways I think, of the CLN repository.
It's a little bit of a monorepo, not exactly, but there's a lot of little
projects inside of the CLN GitHub repo, and pyln client is one of them.  So,
<!-- skip-duplicate-words-test -->what it is is it's a Python client that you can use in any Python.  It gets
shipped on PyPI, you can install it using pip, so it's a full-fledged
independent Python library that gets built and updated inside the CLN repo.

So, in this PR, what they've done is they've added a lot more good, a lot more
utilities and stuff around helping you parse through and better understand
gossip objects.  So messages that come over the gossip channel, now in pyln on
Python, it seems like you'll be able to do a lot more things.  One of these that
seems pretty cool is the get_halfchannels thing; I'm looking at the PR, the
third bullet point.  What's cool about this is it lets you return an area of
channels, it says, "Within a given distance towards a certain node".  So, I
think this particular new method that they've added would make it such that
you're able to look for -- basically start building a route, so give you route
candidates, is my understanding, which is pretty cool.  Anyway, I don't know how
helpful that is.

**Mark Erhardt**: Super.  Thank you for adding colour.

**Mike Schmidt**: Thanks, Lisa.

_Core Lightning #6124_

There's another CLN PR, Core Lightning #6124, adding the ability to blacklist
runes with the commando plugin, and also maintain a list of runes, which is
useful for tracking and disabling compromised ones.  So, commando is a plugin
that we've talked about previously, allowing a node to receive commands from
peers actually using LN messages to execute commands on the CLN node who's
allowing those requests.  And the authorization piece here is something called a
rune, and the PR here is two parts: one is the ability to list all of those
runes that have been initiated on that CLN node; and then the second part of the
PR is the ability to blacklist or disable a rune, or if you're suspicious that
the rune has been compromised, or the machine that the rune was on was
compromised, you can blacklist that so that those remote commands can no longer
work.  Lisa, I would defer to you on any commando-related things as well.

**Lisa Neigut**: Yeah, that's right, I think you nailed it pretty much there.

**Mark Erhardt**: Yeah, you answered all my questions!

_Eclair #2607_

**Mike Schmidt**: Okay, great!  The next PR here is an Eclair one, Eclair #2607,
adding a listreceivedpayments RPC that lists all the payments received by the
node.  It seems fairly straightforward and fairly useful.  One thing that I
noticed in going through this PR is that the PR also initially attempted to add
a listexpiredinvoices RPC, which could have some benefits for accounting
purposes, if you wanted to know what sort of invoices you've sent out that are
expired.

It could be useful for some people on an accounting aspect, but that RPC was
removed because there were questions about the usefulness of that use case, and
also the fact that Eclair currently purges old, expired invoices from the
database periodically, I believe at least, by default it purges those from the
database, so maybe that RPC wouldn't be as reliable, so it was removed from this
PR.  Murch, any comments on Eclair?

**Mark Erhardt**: No, you keep saying everything I've wanted to ask already.
Great prep.

_LND #7437_

**Mike Schmidt**: Great!  The next PR is to LND, LND #7437, adding support for
backing up just a single channel to a file.  So, it seems like maybe there was a
bug there since if you wanted to backup a single channel and you were able to
provide a file that you wanted that channel backed up to, it actually just spat
out all the output to the console in JSON format, as opposed to packing that
into a file as you requested.  So, I think this PR fixes that and it also adds
the capability to verify that channel backup, and restore that single channel
from a file as well.  Anything to add Murch?  All right, great.

_LND #7069_

LND #7069, allowing a client to send a message to its watchtower asking for a
session to be deleted.  We had some discussion about watchtowers last week with
Sergi, and I would invite people to jump back into that to familiarize
themselves with watchtowers and this whole idea of deleting a session.  This PR
is for the LND implementation of watchtowers, which has both a client and a
server, the client being the node that is using the server as a watchtower.  And
when that client has a session that is no longer needed for monitoring for
onchain transactions, that client of the watchtower can now send a message to
the watchtower server letting it know that it can stop that monitoring, and it
can actually delete any of the data that it has, so being nice to the watchtower
server there to be able to free up some resources.

One thing that I saw in this PR that is a bit relevant to our discussion last
week is that there is a random amount of time that the client will wait before
it sends the delete message, so as to not give away too much information to the
watchtower, which obviously would help with privacy.

**Mark Erhardt**: Yeah, also it does seem to identify whether all of the updates
that it's sending belong to one channel.  So, also going off of the discussion
with Sergi last week, it seems to at least identify the channel when updates
belong to the same channel, otherwise it couldn't delete all of it in a single
go either.

**Mike Schmidt**: That makes sense.

**Mark Erhardt**: Anyway, I looked it over a little bit.  I think you got all
the important parts.

_BIPs #1372_

**Mike Schmidt**: Last PR for this week is to the BIPs repository, BIPs #1372,
assigning the number BIP327 to the MuSig2 protocol for creating multisignatures.
We've talked a bit about MuSig even today.  Murch, maybe it would make sense to
give a brief overview of MuSig2 in the route to this BIP, and why you think it
might be important for the Bitcoin ecosystem?

**Mark Erhardt**: Yeah, sure.  So, you all probably have heard about how taproot
enables public key aggregation, which means that while it looks like a single
public key in the output, we actually might have multiple keys involved under
the hood, and specifically MuSig2 offers a protocol to allow a signature scheme
in the sense that k-of-k signers can sign off and it will look like a single
public key and a single signature.  So, this is for example super-interesting in
the context of LN, where we have 2-of-2 participants that need to agree on a new
state.  Instead of having a 2-of-2 multisig setup, we now have something that
looks onchain like a singlesig P2TR output, but under the hood has still the
same behaviour that both parties have to sign off and trade this signature
together.

One of the huge benefits that we expect is that some of the multisig users will
be able to move to the MuSig construction and will look exactly like singlesig
onchain, both getting the lower onchain cost because the transaction gets
smaller, and being indistinguishable from singlesig use.  So, yes, I've seen
some complaints how taproot hasn't been useful at all yet and why nobody's using
taproot yet, and I think I want to point out here that some of the core features
that people were excited for getting, in the context of taproot, are just
rolling out now after they are finally specced.  I know that Muun has been using
2-of-2 MuSig constructions already before the spec was finalized.  I think
they've been closely cooperating with the authors of the BIP, but now I think
that other implementors and users will also want to move on this more.

This is also, for example, interesting in cases where you have a threshold
setup.  So for example, at my old employers, we used 2-of-3 multisig wallets,
but two of those keys were way more likely to sign.  So, you would encode a
2-of-2 as the key-path on a P2TR and when those two keys signed, they can just
create a signature together and it looks like singlesig, and you would only ever
reveal that it was a 2-of-3 in the case that you need to fall back go a
different quorum, like two other signers, and then reveal that there's a
script-path that had a leaf script where the other two parties could sign.

So overall, I think this will make it cheaper for business use cases to produce
transactions; it will improve the privacy because more users will look like
they're using the same output types and schema; and -- well, sorry, I've been
rambling for 20 minutes.  Any other questions about this?  Anyway, it's finally
a BIP and it is BIP327 and that's exciting.

**Mike Schmidt**: I think there's some confusion that I see online often with
multisig versus multisignature versus threshold signature.  So, I'll just
attempt to clarify that a bit.  With the MuSig2 protocol, it's a multisignature
protocol, so you would have to have n-of-n, so 2-of-2, 3-of-3.  Murch outlined
that there's ways that you can do that and also have fallback but if you wanted
to do threshold signatures with schnorr signatures, there are different
protocols that are in the works for that, so those would be something like FROST
that we've covered in the newsletter, and ROAST, which could be threshold
signature schemes that would allow for 2-of-3 in a schnorr-type setup, as
opposed to having the key-path being MuSig in a multisignature and then falling
back to script-paths to do the 2-of-3.

There's a nice table that we have on the threshold signature topic on the
Bitcoin Optech website, as well as the multisignature topic.  It gives you a
good visualization of the differences between multisig, multisignature and
threshold signature.

We have a couple of speaker requests, and if you also have a question, feel free
to request speaker access and we can get to your question.  Baljeet, you have
another question?

**Baljeet**: Yes, please.  I know there might be no correlation, but is there
any relation to the payjoin at all with this setup, or is it totally different?

**Mark Erhardt**: So, a payjoin generally just means that you're doing a
multiuser transaction, and that means that multiple participants are
contributing inputs to the transaction.  It doesn't necessarily mean that they
need to use taproot, or even aggregated public keys, it's just more on who
contributes funds to the transaction.

One of the connections that had come up with taproot before is for a long time,
schnorr signatures were also traded with the notion that we would be able to
aggregate signatures across whole transactions, so that if you use all
schnorr-based inputs, you would be able to only have a single schnorr signature
for all of those inputs.  And the idea here would be that coinjoins and the
specific case of payjoin would be financially attractive, or economically
attractive, because it would be cheaper to have a transaction with more inputs
than it would be to have one with fewer inputs, since now the signature data is
aggregated and you only have to pay for one signature instead of a signature on
every input.  So, there would be an economic incentive to join multiple
transactions into a single transaction in order to have smaller overall block
space use.

<!-- skip-duplicate-words-test -->The problem is that that is fairly complicated and it was years away at the
point when people got really excited about being ready with taproot, and it was
separated into future work.  So right now, the proposal cross-input signature
aggregation is still under research and we'll have to see what happens in the
future.

**Mike Schmidt**: We had another speaker request from Peace; Peace, did you have
a question?  Okay, perhaps not.  It doesn't look like there's any other
questions.

**Peace**: Hello, can you hear my voice?

**Mike Schmidt**: We can hear you.

**Peace**: So, I'm just a beginner in LDK, I'm trying to use, as well as I'm a
Solidity developer building dapps on Ethereum.  So, is there any EVM-compatible
solution that I can use my existing projects that I wrote in Solidity for the
LN?

**Mark Erhardt**: I'm not familiar with any LN implementations that interface
with Ethereum at all.  I think that's not likely to happen any time soon, so I
would be surprised if you do find something like that.  I do know that there's
stuff that interacts with derivative or bitcoins, like wrapped bitcoin, and
maybe people have been doing something in that regard, but I don't think we
would know about that sort of effort on this end, because we only look at
Bitcoin stuff, not Ethereum.

**Mike Schmidt**: There may be some EVM compatibility with some of these
projects building on Bitcoin with respect to things like maybe RSK, Rootstock,
may have some feature parity with some of the programming languages, but that's
not something that we're super-familiar with here.

**Speaker 1**: Okay.  So, as far as the LN development is concerned, what would
you recommend; which document should I go through?

**Mike Schmidt**: That's a broad question, Murch.  Where would you point
somebody who wanted to do LN-related development to get started?

**Mark Erhardt**: I think a starting point might be the recently published
Mastering the Lightning Network book, by Andreas Antonopoulos and other authors.
I think that it's maybe still a living document in that there are a few
references that are getting improved, but I hear that people are reading it
successfully.  And we also have an LN protocol developers' seminar on the
Chaincode page under learning.chaincode.com.  So, maybe if you look at that, you
could find some interesting content.  There's a lot of talks and articles that
we've collated that cover different aspects of the LN.

So, even if you don't want to join the seminar, you can find the content and
just look it over to get a pretty good overview of how LN works, how the LN
protocol is being developed.  So, that would be learning.chaincode.com.

**Mike Schmidt**: Thanks, Murch.  It doesn't look like we have any other
questions or comments, so anything further that you would add; any
announcements, Murch?

**Mark Erhardt**: Nothing new from me.

**Mike Schmidt**: Well, thanks to my co-host, Murch, as always.  Thanks to Lisa
for joining us and Niklas for joining us to opine on the work that they've been
doing, it's very appreciated.

**Mark Erhardt**: Thank you also for the people coming up with their questions.
We were happy to be able to address you guys directly, because that's why we're
doing it on Spaces and not a different platform.

**Mike Schmidt**: All right, thanks everybody for your time and we'll see you
next week.  Cheers.

{% include references.md %}
