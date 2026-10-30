---
title: 'Bitcoin Optech Newsletter #426 Recap Podcast'
permalink: /en/podcast/2026/10/13/
reference: /en/newsletters/2026/10/09/
name: 2026-10-13-recap
slug: 2026-10-13-recap
type: podcast
layout: podcast-episode
lang: en
---
Gustavo Flores Echaiz is joined by Clara Shikhelman and Elias Rohrer to
discuss [Newsletter #426]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-9-14/434133077-44100-2-c5dbc239ad223.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Gustavo Flores Echaiz**: Hello everyone, and welcome for another episode of
the Bitcoin Optech Live Show and Podcast.  Today, we're going to cover
Newsletter #426.  We've got multiple News items, as well as many Releases and
Notable code and documentation changes.  For the most interesting News item we
have, on a proposal for onchain, private bitcoin transfer with no consensus
changes, we have invited Clara.  Clara, would you like to introduce yourself,
please?

**Clara Shikhelman**: Hi, I'm Clara Shikhelman, I'm Head of Protocol Research
at \[\[alloc\] init\], and one of the authors of the paper introducing
Shielded Bitcoin.

**Gustavo Flores Echaiz**: Thank you so much, Clara.  We're going to start
with that item, and then we're going to move onto the LDK Releases and Notable
code and documentation changes.  For that, we have Elias.  Would you like to
introduce yourself, Elias?

**Elias Rohrer**: Sure.  Hi, I'm Elias, I'm with Spiral working on LDK and
also Project Loop, which is AI security scanning, which probably we'll both
get into.

_Proposal for onchain, private bitcoin transfers with no consensus changes_

**Gustavo Flores Echaiz**: Awesome.  Thank you so much, both of you, for being
here.  So, we're going to run out of order today, and we're going to go
directly to the third News item, since we have Clara for that.  So, "Proposal
for onchain, private bitcoin transfers with no consensus changes".  So, I
believe everyone saw this on Twitter, or X, a few days ago, and then we saw
your post on Delving.  So, quite a lot to unpack there. I was reading on it
last night, and definitely a lot of interesting stuff.  I think there are some
things that remain unsolved, but we'll talk about it.  So, maybe, could you
start by introducing the idea of Shielded Bitcoin, you know, what you're
trying to achieve with this proposal; just give us a little intro to the
topic, please?

**Clara Shikhelman**: of course. So, the paper we published is a part of an
ongoing work, and this paper mostly focused on how the transaction will
happen. So, the goal is to have the ability to move bitcoin without
broadcasting sender, receiver and amounts, the way we do it right now. And the
main motivation for that is that if 15 years ago, the pseudonymous cover of
Bitcoin seemed pretty good, in this day and age, especially in the age of
LLMs, what seemed private and not everybody's business seems to be just out
there completely.  And I believe we can and we should do better.  And the
paper we published is the protocol part of that.  This will be to allow this
protocol to work without consensus changes, without operators, without any of
the other problems that we have.  We're going to use PIPEs, which is built on
top of a very powerful and new cryptographic scheme.  And again, it's going to
be a pretty large body of work, so, yeah, but the paper was on the protocol
part.  And, yeah.

**Gustavo Flores Echaiz**: Awesome, really great stuff.  Thank you for the
intro.  So, could you walk us maybe through, let's say, one private payment?
So, let's not yet talk about how to connect to actual bitcoin, like, we can
leave the PIPEs and the bridge part for later, but let's actually talk about
the Shielded Bitcoin system.  Can you walk us through one private payment?
Assume, let's say, Alice has funds inside the system.  How does she get to pay
Bob?

**Clara Shikhelman**: Of course.  So, if Alice already has funds inside of the
system, this means that she has a note that she owns, and this is very similar
to Bitcoin's UTXO model.  She has some funds under her control.  Then, to send
it to Bob, she creates a note for Bob, maybe another note of change going back
to her, and this she does all by herself.  And then, she will publish on chain
a message, which is a bit bigger than usual bitcoin transactions, but not
significantly, maybe five times more, something like that, that will look like
a regular bitcoin transaction with extra information carried in it.  This
extra information, first of all, tells anybody that is following Shielded
Bitcoin that a note was burned.  The note that she had, it's gone.  And then,
this is the note nullifier structure or architecture, which means that this
note that she had is gone, and now there are other notes created that can be
used either by Bob, who knows the private key of the public key, again, very
familiar territory, and herself or anybody else.

This information, so there's going to be also a proof that, first of all,
she's allowed to do this, that she owned the note that she just burned, that
the amounts coming in and coming out are the same, and other things you would
expect when moving a note.  And there's information there for Bob to retrieve
his funds and later on, pass it.  So, anybody that's watching the blockchain
can see that something happened and they can update the nullifier set so that
Alice cannot pay again with the note she just used.  But beyond that, they
don't know that this was Alice that did the payment, they don't know where
it's going, they don't know how much money moved, and so on.

**Gustavo Flores Echaiz**: Right, thank you so much for explaining that.  And
so, is my understanding correct that basically, the proofs get published on
the Bitcoin chain and that consumes blockspace, and it is bigger than an
average Bitcoin transaction; so, who verifies the proofs?  I think there's
such a concept called the indexers or the verifiers; could you maybe walk us
through that?

**Clara Shikhelman**: So, there are no verifiers.  Indexers are passively
watching the chain.  So, you can run your own indexer, there's no consensus
there.  This is just a way, it's more like a block explorer.  You look at the
chain, but now you're just looking at the specific transactions.  So, the
proofs are there.  When you're going to use the note or accept the note, you
need to verify it.  So, for all of this transaction to make sense, you do need
to verify this.  But this is between -- it's mostly Bob's thing.  When he want
to accept the funds, maybe send something back in return to Alice, or so on,
Bob can check it.  And the indexers that are following, you want later on to
check if Alice pays you.  So, you do want to go over the chain and see that
this note was not in the nullifier set.  So, you do need to read the whole
chain and make sure that everything makes sense.  But this is just, you read
the chain and you get the same result.  It's very deterministic in that sense.

**Gustavo Flores Echaiz**: Awesome, makes total sense.  I guess one question
that I had and maybe listeners also have, is what is the main innovation you
believe that came up with Shielded Bitcoin?  For example, from my
understanding, we had already seen protocols like Zcash years ago, and you're
kind of taking on similar concepts.  So, what is the difference between, let's
say, a sidechain, a federated sidechain that would have used Zcash privacy
five years ago; what would you say are the main innovations from the paper you
released?

**Clara Shikhelman**: I think the main innovations in the paper that released
are, if you're comparing to Zcash, the main reason that we wanted it is
because we wanted Bitcoin and not Zcash.  And then, a lot of work went into
making the transaction smaller.  So, being able to fit everything in a
reasonable size for Bitcoin is one of the main things that we had to work on.
And of course, we're building on top of a very lively research area and
standing on the shoulders of giants, and so on.  But there was a lot of work
of translating it into Bitcoin, making it of reasonable size and reasonable
structure, using, of course, the very, very impressive work done previously by
a lot of other researchers.

**Gustavo Flores Echaiz**: Right.  But is my understanding correct that you're
also not creating a new consensus system, not a new blockchain, right, and
that's also part of the benefits of this proposal?

**Clara Shikhelman**: Yeah, absolutely.  So, no federation, no operators, no
consensus.  So, in that sense, this is not a sidechain.  This is not vanilla
layer 2 in the usual sense, although there's semantics there.  But this is
just, we were very, very focused on doing one thing and doing one thing well,
and that's moving bitcoin privately.

**Gustavo Flores Echaiz**: Great.  Finally, on this topic, before we move on
to the PIPEs and how you connect it to actual Bitcoin, what are the main trust
assumptions that a listener should know about when it comes to the Shielded
Bitcoin protocol?

**Clara Shikhelman**: So, when it comes to the shielded Bitcoin protocol, and
this also goes down to PIPEs and so on, as in many zero-knowledge structures
and in PIPEs, there is a setup phase where there will be a trust assumption,
probably 1-of-n or k-of-n, where n is hopefully pretty large.  So, you're
welcome to join the party in that sense.  If you don't trust anybody, you can
trust yourself.  But this is a trust assumption, but this is relevant only for
the first, for the beginning.  At that point, there was this setup phase, and
now all of the entities involved can and hopefully should disappear.  We don't
need them anymore, you don't need them to join the shielded protocol, you
don't need them to transfer, you don't need them to leave.  So, there is a
trust assumption in the setup.  But once it's done, we never use these trusted
parties again.

**Gustavo Flores Echaiz**: Right, okay.  So, similar to what Zcash had to deal
with at the beginning, a trusted setup, and there's simply no way around it,
right?

**Clara Shikhelman**: Yes.  So, we are exploring some ideas.  But again, we
haven't published this part yet.  But there probably will be a trusted setup.

**Gustavo Flores Echaiz**: Understood.  Thank you.  Let's now jump in, how
does this connect to real Bitcoin, right?  So, I believe it was in a few
episodes ago, your co-worker, Misha, he had the pleasure to join us to talk
about his proposal around PIPEs.  So, could you maybe connect both concepts
and tell us how, let's say I have real bitcoin, I want to have bitcoin inside
the Shielded Bitcoin system, how does that happen?

**Clara Shikhelman**: Okay, so, just very quickly, what PIPEs allows us to do,
and I'm sure Misha covered it pretty well, the idea is that you can create a
UTXO that is a public key that nobody knows the private key for it.  So, what
it allows us is to create a UTXO to which you can get the private key if you
satisfy a set of rules, if you can provide the witness that something
happened.  This is our general use of PIPEs.  So, in the case of Shielded
Bitcoin, you will join the system one of the ways, or the most structured way
is you'll join this by pegging-in, that is, sending an amount into this vault
structure.  And then, let's say you send 1 bitcoin, I sent 1 bitcoin and so
on, now when you want to exit, you need to prove to one of the vaults, and it
does not have to be your vault, you need to prove to this vault that you
indeed burned 1 Shielded Bitcoin.  And then, if you show this proof to this
vault, it will give you the private key and you can take the funds on Bitcoin.
So, this is the general idea of how you get in and get out.  And as we speak,
we're writing the paper and details will follow soon.

**Gustavo Flores Echaiz**: Right.  I'm not going to scrutinize you too much on
the PIPEs question.  I believe the paper, the Shielded Bitcoin paper, puts
clear that that remains sort of unresolved and still a work in progress.  But
I would like to point listeners to episode #393, where we had the pleasure to
receive Misha to present the v2 of the Bitcoin PIPEs idea, and where Mike and
Murch made Misha walk us through the process, but also scrutinized a few of
the trust assumptions.  So, maybe you can just simply briefly, let's say, talk
about what you would say the PIPEs system, what are the main trust assumptions
or unresolved questions of the PIPEs system that could be used by Shielded
Bitcoin?

**Clara Shikhelman**: So, I think the trust, again, this is what I mentioned
before, there is a trusted setup.  So, this I think is the main trust
assumption.  It's not RSA, so it is new cryptography.  So, the same way you
had the idea of zero knowledge for a long time, so the idea of witness
encryption is floating around for quite a while, and this is the first time it
meets reality, the same way zero knowledge met reality with Pinocchio.  So,
there are some issues there that everything needs to be done very carefully.
So, it's not a proper trust assumption when we're talking cryptography, but it
is a delicate process and we're planning to have lots of challenges.  And of
course, we're talking with all of the experts in the field, and so on, to make
sure that everything works well.

**Gustavo Flores Echaiz**: Right.  But I was more talking, let's say, about
the PIPEs system.  You do have, let's say, distributed key generation to
generate the private key.

**Clara Shikhelman**: Yeah, that's the multiparty computation, that's the
setup.

**Gustavo Flores Echaiz**: Okay, perfect.  But also, the witness encryption
security system also has, like the ADP construction, also has strong
cryptographic assumptions that, from my understanding when I read the paper,
was that this hasn't undergone security cryptographic audits required for it
to move to production, so that would still be needed?

**Clara Shikhelman**: So, yeah, definitely.  That's what I mentioned before.
So, the challenges and talking to experts, and so on, cryptoanalysis,
absolutely.  We're moving very carefully because I like doing boring things in
the boring way, and so do the other people here.  So, that's definitely
something that needs to be done carefully, and we're learning from previous
processes and doing all of the steps that need to be done, and again,
cryptoanalysis, attacks, we have off-chain challenges, on-chain challenges,
and so on.

**Gustavo Flores Echaiz**: Definitely a big challenge and I applaud you for
taking it on, and I would like to, how has been the response so far?  What
would you take away from that?

**Clara Shikhelman**: I think the response was pretty good, because every time
you put something on Twitter or X, you're like, "Oh, let's see what comes up",
and I think the response was very good.  Some of the reviews or the points
that people brought up were very, very helpful and we'll definitely take them
into account moving forward.  I think there was a lot of interest.  So,
because this is part of an ongoing project, a lot of people were guessing what
will be the next part, and so on.  So, we do need to encourage everybody to
take a deep breath.  We have everything coming up, yeah.  But I think the
responses were pretty good.

**Gustavo Flores Echaiz**: Great.  What are you looking for now?  For
listeners, for example, is there any action items you have for listeners, any
feedback you would want?

**Clara Shikhelman**: I think use cases and your needs, because when designing
a protocol, you always need to make some choices.  And then, understanding
better what is it that you need or in which cases would you want to use a
protocol, that could be very, very helpful.  And for the more technical
people, please attack the papers, please attack anything.  Anything technical
that we put out there, please break it as soon as possible.  It's good for
everybody.  Yeah, so if you're technical and feel like breaking things, please
go ahead, please look at the paper.  Look at the cryptographic releases that
are also coming up.  Yeah, that would be amazing.  We're looking forward to
any feedback on that end.

**Gustavo Flores Echaiz**: Awesome.  I'm going to do that myself because I
actually found it really interesting.  One final question I had out of
personal curiosity, the Shielded Bitcoin protocol, could it be used with
another bridge peg-in, peg-out system, or say, for example, with a federated
sidechain or with a BitVM v3 peg-in bridge system, or does it have to be used
with the PIPEs system?

**Clara Shikhelman**: I think that the way we're building it right now, the
peg-in and peg-out will be through PIPEs.  So, you could definitely do atomic
swaps, for example.  But changing the peg-in and peg-out process into
something else means that you are putting the trust assumptions of that
mechanism on people that did not sign up for that.  So, this is something we
need to be very, very careful with.  So, if it's between two parties, like an
atomic swap, and you're just chill with that, it's between Alice and Bob,
that's good.  But with joining or leaving the system, we don't want to add any
trust assumptions, especially if people joined under one umbrella, and then we
can't go like, "Oh, yeah, and now people can take your money and leave using
this federation".  That's a bit irresponsible.  But you can build on top a lot
of things if you want to.  So, this is definitely something we're very, very
interested in.  And yeah, maybe one day.

**Gustavo Flores Echaiz**: Awesome.  Well, that's great, Clara.  Thank you so
much.  Anything else you would like to add to this interview?

**Clara Shikhelman**: No, not really.  We're really enjoying the feedback, we
really enjoy scientific scrutiny.  So, please go break things, it's important
to us.

**Gustavo Flores Echaiz**: Awesome.  Well, thank you so much.  That was great.
I would like to point listeners to the Delving Bitcoin post that Misha made,
but also to the paper that you co-wrote with him alongside Aleksei, and also
to the episode #393 of the Bitcoin Optech podcast, if listeners want to learn
more about Bitcoin PIPEs v2, which is the bridge or peg-in, peg-out system
that Shielded Bitcoin would use.  Thank you so much, Clara.  Your free to
drop.

**Clara Shikhelman**: It's been a pleasure.

**Gustavo Flores Echaiz**: Thank you.  See you.  Great.  So, now we have
covered the main News item, and we're going to get to the next two News items
around the dynamic one-byte message type IDs for BIP324, and discussions of
conventions for tagged hash tags in BIPs, in a few minutes.  But first, we're
going to go with the LDK items.  We have three different Releases this week,
as well as four different Notable code changes.  I believe there were a few
vulnerabilities that were covered or vulnerability fixes.  So, Elias, I give
you the stage.  Would you like to maybe start with the releases?  What are the
new releases of LDK?

_LDK v0.3-rc3_

_LDK v0.2.7 and v0.1.13_

**Elias Rohrer**: Yes, so we have actually three new releases that came out
recently.  That is the v0.3-rc3 release, which will be our next mainline
release, which we have now the third RC of.  We keep on fixing things,
basically, but hope to release the final soon.  Then v0.2.7 and v0.1.13 came
out, which are both patch releases that cover a bunch of bug fixes, but also
security-relevant hardening fixes; essentially, backports for things that also
landed in the v0.3 branch and in the current main branch, of course.  Yeah, so
for one, we have a few bug fixes that could, for example, have led to
force-closes.  One issue, for example, was related to HTLC (Hash Time Locked
Contract) fulfills that were followed by update_add_HTLC, essentially.  So,
when in a Lightning channel, a new HTLC would reuse the liquidity that got
freed when update_fulfill_htlc immediately basically in the same transaction.
We could land in a situation where we would have force-closed the channel.
That, for example, has been fixed, as well as a few other typical bug fixes in
that release.  I'm not sure if you're looking to discuss any particular ones
there.

But maybe the security fixes are the most interesting ones in the release.
And generally, as many people in the Lightning space are in the Bitcoin space
currently, the last few releases were security-related hardening, but
generally bug fix releases for us, because of course a lot of people are
currently doing LLM-based scanning.  And these releases are no different.  So,
we had a few issues that were reported by individual contributors and by
individual people.  But indeed, the most fixes that we discuss here have been
reported by Project Loop and other security scanning efforts.  And to get into
the security fixes, for one, there was one Electrum issue, where in our
Electrum sync logic, we previously, when we essentially tried to download
transactions for a specific output spend, we would previously pick a random
transaction of a certain block essentially, because we were not fully sure
what the transaction for this output spend is, due to how the Electrum API was
structured.  And that could have led us to, for example, if that happens to be
an OP_RETURN, which is not a typical Lightning thing, but other users might
use our syncing logic in that way, then it could have led us to not seeing a
confirmed transaction, basically, leading to never pulling down a certain
transaction and hence not marking it confirmed to our internal state, which
was also with some potential, although not drastic, but some potential
security impact.

The second issue was maybe the most dangerous one, which was a bug in our
ChannelMonitor logic that could have led us to essentially allow a
counterparty that already had gotten a commitment update before, to
essentially outright lie and say it didn't receive that commitment update, and
then trigger a reconnect and hence a channel_reestablish, which would have led
LDK to retransmit a newly signed commitment update, leading to an inconsistent
internal state of LDK.  And the outcome would be that the counterparty was
allowed to essentially steal the HTLC funds, because LDK then would simply
fail to claim the respective HTLC funds.  So, that was maybe the most critical
issue in this security release.  And then, maybe the final security fix that
was in these releases that is probably noteworthy, was a bug in the LSPS2
Just-In-Time (JIT) channel flow that allowed an attacker to essentially try to
or craft a certain onion packet that allowed it to trigger the LSP to open a
channel and forward an HTLC, without actually sending the funds essentially.
Because there's basically a field that says, "I want so-and-so much in my
channel", basically the onion value, and we unfortunately only looked at that
value and didn't actually check that the inbound HTLC value was actually
there.  That was essentially the third major security item of these releases.

**Gustavo Flores Echaiz**: Right.  Well, thank you so much for walking us
through the releases.  So, yeah, so first of all in this newsletter, we
covered the third RC of the v0.3.  So, is there any action items to take here;
are you looking for testers?  Anything to tell listeners about this specific
release before we talk again about the others and the vulnerabilities?

**Elias Rohrer**: So, yeah, we generally absolutely encourage any users to
check out the v0.3 branch, because that is what's actively developed.  It's
also the RC branch that will actually power LDK Server when it comes out.  So,
any kind of pre-testing from the current main branch of LDK Server is very
encouraged, though you might not want to test on mainnet until it's actually
released.  Of course, it should be generally fine to do that.  We're
approaching a final release there too.  But yeah, just generally, before you
have a stable release, you just shouldn't do mainnet, of course.  But we
absolutely encourage everybody to test out also LDK Server based on that v0.3
branch.  And for the other releases, we definitely encourage all users to
upgrade as soon as possible.  That should be, when you're a Rust user, just be
a simple cargo update, and then rebuild your Rust application and you're
basically done and you get the newest LDK patches.

**Gustavo Flores Echaiz**: Perfect, excellent.  Thank you so much for the
action items.  Definitely, listeners, make sure to upgrade if you're using
LDK, because those two security releases are quite important.  And okay, now
let's jump into each LDK item which you briefly covered the first two.

_LDK #5057_

So, the first one, #5057, it's the vulnerability that allows a malicious
channel peer to steal the value of a forwarded HTLC.  So, this is what you
described, right, where during reconnection, a peer basically falsely claims,
in a channel_reestablish message, that it has missed the commitment.  However,
it had already acknowledged it with revoke_and_ack, but now it's pretending
that it misses the commitment.  And then, LDK signs and transmits a new valid
commitment transaction, but doesn't record it in its ChannelMonitor, right?
And then, when the peer publishes the transaction on-chain, that's when LDK
fails to claim the corresponding incoming HTLC.  Is that an accurate
description of the issue; and what would you add to it, and what is the fix
for it?

**Elias Rohrer**: Yes, that's a very accurate description.  Thank you for
that.  The fix is actually very simple.  So, the main bug was here, of course,
that we didn't check before.  So, generally, it's no bug that we regenerate a
commitment, because you want to do that on channel_reestablish if the
counterparty actually didn't receive the previous one.  So, that is a feature,
not a bug.  The issue that we had was a single line fix, because we simply
forgot to check that the counterparty didn't confirm receipt of the previous
commitment.  So, the fix is simply check if the counterparty already confirmed
that it received the previous commitment, and if it does not actually have an
outstanding commitment update, if it confirmed that it received the previous
one, don't send a new one, basically.  That is the simple fix.  And if you
detect that, you can essentially just force-close, because the counterparty
might try to cheat you at that point, or it's buggy, but you don't know that.
But then, the way out is just to force-close the channel.

**Gustavo Flores Echaiz**: Right, totally.  And I just want to make a point
here that we've seen so many of these types of vulnerabilities in the past few
weeks related to all Lightning implementations.  And Lightning being such a
complicated system with so many negotiation steps, that's when these
opportunities for attacks arise, right?  So, this is just another example of
the wave we've seen lately, which emphasizes how important it is for users to
upgrade to the security releases that are now out there.

_LDK #5042_

Let's go to the next one.  So, #5042.  This one is when the LSP could lose
funds.  So, is my understanding correct that an LSP is opening a JIT channel
for a user that wants to receive a Lightning payment but doesn't yet have a
Lightning channel.  However, the payer requests a larger outgoing payment
while sending less, but the LSP doesn't really check how much it receives.  It
simply acted on the requested outgoing payment amount requested by the payer.
Once again, is that a correct description?  What would you add to it, and
what's the fix here?

**Elias Rohrer**: Yeah, indeed.  So, essentially, the issue is, as I briefly
explained before, there's basically two parts to that HTLC.  There's one value
that is in the onion and defines the expected outbound amount in this case,
also.  And then, there is the actual inbound amount that the LSP node gets
from the HTLC, basically.  And in this logic, we unfortunately only looked at
the expected outbound amount essentially, that is payer-set, and didn't
actually check that at the point where the LSP opens the channel and forwards
the HTLC, that at this point we actually have gotten sufficient inbound HTLC
values.  It basically just trusted the amount that was in the onion that can
be manipulated by the payer, and therefore allowed the payer to open a channel
and have the LSP forward funds without actually sending inbound funds
essentially by the payer.

**Gustavo Flores Echaiz**: Right.  So, once again, a small fix, right?  You
just check that you have received the amount, that it actually makes sense,
that you're not forwarding amounts that are higher than what you received?

**Elias Rohrer**: Yes.

_LDK #5046_

**Gustavo Flores Echaiz**: Perfect.  Next item, #5046.  So, this is one about
a bug that could cause a forwarding node to lose funds when restarting with an
older ChannelManager state than its ChannelMonitor.  I think this one, you
didn't yet cover, but maybe you did.  So, could you walk us through that one,
please?

**Elias Rohrer**: I try to recall.  I think this is mostly to do with our
channel -- no, I actually can't fully recall what this one is about.  I think
it has to do with essentially when we recover -- when loading a ChannelManager
and ChannelMonitors from disk and there are stale ChannelMonitors, we
generally, in theory, need to force-close if the two are out of sync.  Yeah,
but basically, under some circumstances, this previously allowed us to still
attempt it essentially when there was still persistence in flight of
ChannelMonitor updates.  So, in LDK, we have basically three different main
objects that are to do with a channel.  Basically, ChannelManager is the main
object that manages everything; and then, you have ChannelMonitors that take
care about the actual, yeah, mostly on-chain claims, and so on; and then, you
have ChannelMonitor updates, which are incremental updates to these
ChannelMonitors essentially.  And yeah, so this is a case where these three
could get out of sync, or the ChannelMonitors and ChannelManagers could get
out of sync, especially if ChannelMonitor updates are still in flight while
reloading from disk essentially.

**Gustavo Flores Echaiz**: Right, that's my understanding.  So, basically, the
state basically loses sync.  And then, when LDK force-closes the channel, it
incorrectly treats an outgoing HTLC as never committed downstream, and it
fails the incoming HTLC.  So, the downstream peer claims back the failed
incoming HTLC.  But LDK incorrectly treated the outgoing HTLC as never
committed, however it was committed.  So, LDK loses money on both ends and now
the fix is for LDK to always check which previously blocked monitor updates
have already been applied before force-closing.  So, it never fails back an
HTLC that it doesn't have to.

_LDK #5028_

There's another item, LDK #5028, about SCIDs (Short Channel IDs) alias-only
forwarding becoming the default when opening new unannounced channels.  I
don't know if you have any thoughts on it.  If not, no worries.  I understand
that LDK is a collaborative project and you're not working on each individual
PR.  But since you're here, I wanted to give you the opportunity.

**Elias Rohrer**: Yes, definitely.  So, #5028, you said, that is actually a PR
of mine.  So, it basically turned out that we previously didn't negotiate SCID
aliases by default for private channels.  And there was an option for it
which, however, was introduced back then for compatibility reasons, mainly
because without getting too much into the details, essentially we couldn't
just immediately switch to always negotiating SCID aliases.  However, since
this is essentially by now very old versions that would now be incompatible,
and we have even bumped our compatibility threshold beyond them, so there was
no reason to keep this old config, and we simply now dropped this option that
you could have missed before, or whatever, and now default to just always
negotiate option SCID privacy for private channels.

**Gustavo Flores Echaiz**: Awesome, great.  Well, thank you so much for being
here.  Thank you for walking us through the releases and these individual code
changes.  This was very useful and we're very grateful to have you here.
Anything else you would like to add?

**Elias Rohrer**: Yeah, I mean, I definitely want to thank everybody that
reported these issues again, individual reporters, I'm not sure if Red Team
had a report in this release.  Definitely also want to shout out Project Loop,
which is our own LLM scanning project, which generally, if anybody is working
on projects and not doing LLM scanning, you definitely should because they
find a lot currently.  You definitely need to scan your code.  That is maybe
something to add here.  Otherwise, upgrade your nodes as soon as possible.

**Gustavo Flores Echaiz**: Totally.  Thanks so much, Elias, for coming here.
You're always welcome to the show when we have other LDK items to cover.

**Elias Rohrer**: Thank you so much.

**Gustavo Flores Echaiz**: Thank you.  All right, now we have covered both
items from the guests, so we're going to jump back into order, and we're going
to go through with the first two News items, and then we're going to just go
with the remaining Releases and the Notable code changes.

_Dynamic one-byte message type IDs for BIP324_

So, the first news item, "Dynamic one-byte message type IDs for BIP324".  So,
Anthony Towns posted on The Bitcoin-Dev mailing list a draft BIP he's working
on, that lets each peer choose its own one-byte message type IDs for the
message it sends over the v2 P2P transport.  So, what this means is that
BIP324, which specifies the v2 P2P encrypted transport protocol, as much as it
does work by basically creating an encryption system for messages to be
private between two nodes that send it to each other, and nobody in the middle
to be able to inspect those messages, as much as the main work is focused on
that, it also assigns one-byte IDs from a fixed table, so specific message
types have a one-byte ID.  So, you don't have to say, "This is a ping
message", you simply have a fixed table of one-byte IDs that said, "This is a
ping message", right?  So, message types are defined by simply one-byte IDs,
which reduces the size of these messages.

However, with new P2P messages and P2P features, you could have new message
types that are not defined in the fixed table of BIP324, right?  For example,
Anthony Towns gives the example of set324alias message.  So, this message
being non-standard, or being of a feature that was not defined in the fixed
table of BIP324, under the current protocol would require both nodes to reuse
the same message type all the time.  So, what the proposal is right here from
Anthony Towns is to basically allow two nodes to basically set a fixed
one-byte ID for a specific message type.  So, they would announce their own
alias at connection times of that specific message type, so then the new
message can be deployed and experimented at the P2P layer without the
coordination.  So, you basically agree on one-byte ID for that message type
once, and then you reuse it and you reduce the size of each message.

So, Towns also notes that the space saving ranges from up to 66% on a
connection carrying only pings to about 5% on a typical connection, and is
zero until new messages without an existing one-byte ID are deployed.  So,
cool idea, definitely an extension of BIP324.  And also, when combined with
BIP434, which is the Peer Feature Negotiation BIP, I think this becomes really
powerful then, because if you're negotiating new features or non-standard
features with your peers, you don't want to have to send the full message type
with each message.  You would much rather agree on a one-byte ID for that
message type that you can coordinate once and then use in later
communications.  So, if anybody's interested, they can jump into the
Bitcoin-Dev mailing list.  I believe Anthony Towns received a response from
Peter Todd on this.  But definitely something that was needed specifically for
BIP434, but definitely a continuation of BIP324.

_Discussion of conventions for tagged hash tags in BIPs_

The next item, "Discussion of conventions for tagged hash tags in BIPs.  So,
Fabian Jahr posted to the Bitcoin-Dev mailing list asking whether BIPs that
use BIP340 tagged hashes should include the BIP number in the tag, because
some BIPs do, for example, 324, 340, but others don't, such as 327 and 341.
And the reason why he asked is because Fabian has been working on the DahLIAS
draft, BIP459, and recently got assigned a number.  When it got assigned a
number, Fabian went ahead and changed the draft tags, but it broke the
existing implementation and the test vectors.  So, now he's wondering if it
was even worth it to do.  So, what is exactly a tagged hash?  So, in a BIP,
you can have similar inputs that when going through a hash function, let's say
SHA256, always the same input arrives to the same output.  But what if you
want to have similar inputs arrive at different outputs, because you have
different use cases for the result hashes?  That's when you use tagged hashes,
where you not only use the same input message, but you also add a specific
tag.  For example, let me pull up an example, but I don't know, "This is for
the signature, and this is for the merkle root", right?  So, that's your
tagged hash and it's the additional input that you would use to not have the
same result hash.

So, now Fabian is asking because some BIPs include in the tagged message,
BIP324, and others don't include the BIP number.  So, now he's asking whether
it's even worth it, what's the consensus here, since there doesn't seem to be
a specific standard of how we apply, or a convention for applying tagged hash
in BIPs?  And he puts some arguments in favor and some arguments against.
Obviously, the arguments in favor are that the number is guaranteed to be
unique within the BIPs ecosystem.  For example, two BIPs that would have BIP
proposals that would have the same input and the same tagged hash message,
they will arrive to the same result.  So, how do you differentiate those two
BIP proposals?  That's when you introduce the BIP number.  So, it makes the
origin of a hash obvious when reading code or test vectors.

However, he also presents arguments against it, such as what I said earlier,
that the spec is broken at the time the number is assigned, right?  You need
to do extra work, you need to rewrite the existing implementations, and also
the test vectors.  Also, another argument against it is that maybe tags don't
need to be unique across BIP proposals, and be interpreted as more general
domain separation.  So, anyways, Fabian opens the discussion on that topic and
receives a response from Bitcoin developer, Sjors Provoost, where he basically
says, "Yes, it is a bit annoying, but because you do have to regenerate the
test vectors.  However, it's not like this is immense work, and also other
modifications to the spec are needed when updating the BIP numbers".  So, he
doesn't think it's much of a big deal.

So, clearly, there's two ways to go around this, and the best would probably
be to arrive at a at a convention and a standard.  But the discussion is open.
If any listeners want to jump ahead and give their opinions, they're more than
welcome.  So, those are the three News items.  If you missed at the beginning
of the episode, we covered the third News item, "Proposal for onchain, private
bitcoin transfers with no consensus changes".  We had Clara Shikhelman come in
and explain that to us.  You can listen to the beginning of the episode for
that.

_Bitcoin Core 32.0rc3_

Now we jump into the Release and release candidate section.  We've got first
the third RC of Bitcoin Core v32.  So, a testing guide is available.
Listeners are invited to test out this new RC.  And the testing guide, we
covered it two episodes ago.  We had someone from the Bitcoin Core team or a
contributor to Bitcoin Core join us to walk us through the testing guide.  So,
you can listen to the episode #424 for that.  But yeah, definitely listeners
are invited to give more feedback here to help out testing.  This is an
important release and it now has its third RC out there since last week.
Hopefully, this is going to be the last RC, but maybe another one will follow,
and then we'll have the full release.

_Core Lightning 26.06.9_

The next release is Core Lightning 26.06.9.  This is another very important
security release of Core Lightning (CLN).  If you haven't yet upgraded, please
do so.  This is the third security release, I believe, in a row, or fourth.
No, it's the third security release in a row.  The one that made the news was
26.06.7.  That was back in late August and initially had an embargo on the
source code.  That embargo has ended.  Then, there was version 26.06.8 that
was released three weeks ago, and now we have a new one, 26.06.9.  So, please,
listeners, if you're here, please go ahead and upgrade if you're using CLN.
I'm not going to walk through all the security changes, because some test
vectors have been withheld to make it harder for an attacker to exploit the
vulnerabilities.  But there's multiple vulnerability fixes related to channel
reestablishment, splicing, HTLC handling, access controls, among other things.
It also fixes a regression in 26.06.8 that could delay channel traffic by
incorrectly throttling peers for ordinary gossip pings in the onion messages.
So, once again, this project strongly recommends upgrading.

I'm going to skip through the LDK items since earlier on this episode, we had
Elias come in and walk us through them.  But, like he said, the v0.3 release,
third RC requires testers.  So, listeners are welcome to jump in and test it
out.  And the other two are security fixes and users are strongly recommended
to upgrade to them.

_BTCPay Server 2.4.5_

Finally, we have BTCPay Server 2.4.5.  This is a security release of BTCPay
Server.  I believe we've had other security releases in the past few weeks for
BTCPay Server as well, so this is just the latest one.  Yes, now I can see
that there were a few before this one.  So, once again, users are recommended
to upgrade to this release.  This one has a few interesting fixes around not
known vulnerabilities, but potential exploitation attacks, such as, for
example, the main one is about blocking private-network destinations by
default for outbound HTTP requests used by Lightning Connections, LNURL,
invoice notifications, and webhooks to prevent server-side request forgery.
So, for example, if I was setting up a webhook with BTCPay Server, and instead
of putting my public domain or my public IP address, I simply put an internal
IP address, for example, Localhost and a specific port, then BTCPay Server
before this release would have made that webhook callback into that
private-network destination.  And that would basically allow an external
system to basically trick BTCPay Server into calling a private-network
destination, such as another system running in the same network or in the same
device.  Now, that is blocked by default, you could still remove it if you
have a use case that works this way, but by default it's removed to prevent
server-side request forgery.

It also tightens invoice and refund permissions, because it seemed that some
refund permissions were allowed too many users that weren't supposed to have
those permissions in the BTCPay Server.  So, that is now corrected, and also
invoice creation is speeded up.  Accompanying Docker changes make Tor opt-in,
including for existing deployments, so that's also very important to note.
And it also removes several unmaintained integrations.  Once again,
administrators are encouraged to upgrade and review the deployment changes.

_Bitcoin Core #36277_

Now, we jump into the Notable code and documentation changes, which is my
bread and butter that I cover every week.  This week, we have four items from
The Bitcoin Core repo, one major one from CLN, a middle one from Eclair, and
the ones we covered from LDK, as much as one from LND.  Let's start.  So,
first, we have Bitcoin Core #36277.  This is about a potential transaction
origin privacy leak in the experimental, opt-in private broadcasting feature.
So, if you remember, we covered, in Newsletter #388 and in Newsletter #425,
but mainly #388, a new feature that Bitcoin Core added where a new Boolean
option, called privatebroadcast, allowed a Bitcoin Core operator to create
short-lived Tor or I2P connections when using the sendrawtransaction RPC.  So,
basically, Bitcoin Core sends a transaction through a short-lived Tor or I2P
connection, or through the Tor proxy to IPv4 or IPv6 peers, and then closes
that connection once it's done broadcasting that transaction or those
transactions.  And that protects the privacy of the transaction originator by
concealing their IP address and by using separate connections for each
transaction to prevent linkability.  This was a main challenge that we were
trying to solve for years.  Maybe listeners remember earlier proposals, named
Dandelion, but this is how it has landed in Bitcoin Core.  And in Newsletter
#425, which was last week, we covered a potential privacy leak in that
implementation.

Now, we also cover another potential privacy leak.  And what is it this time?
So, when you broadcast a transaction with this mode, you have three initial
broadcast attempts.  Once you make those three broadcast attempts, then you
will keep broadcasting at a lower rate, less often, until you receive the
transaction back to the network from another peer, not the peer you
broadcasted to, and not through the private connection, but through your
regular connection.  So, you receive your transaction back from the network,
from your regular connection, and then you can basically know that your
broadcast attempt was successful, right?  Because technically nobody should be
able to know that the private broadcasting connection is the same one as your
regular connection.  So, once you receive it back, you simply stop
broadcasting.

But like I said, there were three initial broadcast attempts.  The problem
here was that as soon as you received the transaction back, you would have
canceled the remaining initial private broadcast attempts.  So, you would have
broadcasted once, you received the transaction back in your regular
connection, and you canceled the remaining broadcast attempts.  However, an
attacker that would, let's say, control multiple peers to whom you had
broadcast through the private broadcast feature, they could, for example,
receive it on the first node, then delay the request on the second node, while
at the same time relay the transaction back to the suspected origin node
through a separate connection, so let's say a third connection lends to your
regular connection.  Then, basically, you would stop your initial private
broadcast attempts.  If your node would close the pending private connection
instead of responding to the request, then the attacker could basically infer
that the private broadcast connection that originated initially the
transaction is the same as the node that received the transaction, because as
soon as the node received the transaction, the private connection canceled the
remaining initial private broadcast attempts.

So, this is a very theoretical attack that would require an attacker to
control multiple nodes, and also to be inspecting the behavior of, at the same
time, your private connection and your regular connection, and also kind of
suspect that you are the same node behind those connections, right?  So, now
the fix is for Bitcoin Core to always complete the three initial private
broadcast attempts over Tor or I2P, even if the transaction has already
propagated back to its original connection.  So, however, subsequent retries
will stop as appropriate, right?  So, it always now completes the initial
three because else, if it would have stopped, its regular connection could get
linked to its temporary private connection.

_Bitcoin Core #36365_

The next item, #36365, this is about two issues with the mempool-based fee
estimator.  So, in Newsletter #420, we covered how Bitcoin Core has
incorporated a mempool-based feerate estimator next to the existing
confirmation-based block-policy estimator.  So, we had also described that if
it doesn't have enough mempool data, it always falls back to the block-policy
estimator.  However, there was an edge case that wasn't covered, which was
when the mempool estimator was simply unavailable.  So, it was covering when
the mempool estimator didn't have enough data, but not if it wasn't available.
So, now it does, and it would show an error if the mempool estimator wasn't
available.  So, now it falls back to the block-policy estimator or
confirmation-based estimator instead of returning an error.

The second fix is that this PR also prevents the mempool-based estimator from
being used immediately after a restart if the mempool fails to load.  So, the
way it was checking if the mempool estimator had enough data, it would look at
basically mempool data and previous blocks and see, "Okay, the mempool had 75%
of the transactions that went into the previous blocks", so it then considered
that the mempool health was good and then it would incorporate use that fee
estimation.  However, after a restart, you could think that you have good
mempool health.  However, the mempool could fail to load and it would
basically have an empty mempool that was considered healthy, and it would
result in artificially low fee estimates.  So, now the fix is to prevent the
mempool-based estimator from being used immediately after a restart, if the
mempool fails to load.  Also, a value is renamed from none to auto in the RPC
default fee_rate_estimator value.

_Bitcoin Core #36338_

Then, next item, Bitcoin Core #36338.  This is about a bug fix in the BIP352
silent payments implementation.  By the way, I want to emphasize that the
mempool-based fee estimator hasn't come out yet in a release of Bitcoin Core,
and the same thing for the BIP352 silent payments implementation.  So, we're
covering fixes before they even get released into an official release.  So,
now, this item is about a problem where a wallet could miss payments when a
transaction contains a modified, yet consensus-valid P2PKH input.  So, in
Newsletter #425, we covered how Bitcoin Core had begun its implementation of
BIP352 silent payments.  However, yes it added supports for encoding, decoding
addresses and scanning transactions, but it didn't yet enable sending or
receiving silent payments through the wallet's RPC or GUI.  So, that remains
the case.

So, what was the issue?  The issue was that an attacker could insert an
invalid signature and a conditional branch inside the input scriptSig of a
valid P2PKH input of the transaction without invalidating the transaction; the
transaction would remain valid.  Which means that Bitcoin Core, when
evaluating the scriptSig, before, it would use a dummy signature checker and
it would accept the invalid signature and execute that branch.  So, basically
it would extract the wrong public key and it would cause the scanner to miss
the payment.  So, now the fix is quite simple.  It now searches for a
scriptSig for a valid compressed public key whose HASH160 matches the hash
committed to in the spent output.  So, it doesn't just grab any signature and
potentially grabs the invalid one and extracts the wrong public key, it
actually looks for the one that matches the hash committed to the spend
output.  So, now it won't miss those transactions, even if an attacker inserts
an invalid signature and a conditional branch inside the transaction's input
scriptSig.

_Bitcoin Core #32895_

Next item, Bitcoin Core #32895.  This is about preparing the wallet for future
automatic upgrades by recording the version and supported features of the last
client that opened it.  So, basically, here the situation is that I could have
my wallet, open it in v31, let's say, and then it would upgrade to v31; my
records would upgrade to that new version.  But then, I could open that same
wallet in v29 and I could add new records to the wallet, and then I would open
it again in v31, but my new records wouldn't get updated, because Bitcoin Core
would just see that some records were up to v31, so it would basically ignore
the remaining records, be like, "Yeah, this wallet has already been migrated
to the new format", it basically skips the migration.  This is why now Bitcoin
Core records the version and supported features of the last client that opened
it.  That way, if you open it again in v29, and then you open it again in v31
after adding wallet records, it detects that it was last opened in v29 and it
makes the migration again.

The new metadata will enable future versions to identify these
upgrade-downgrade-upgrade scenarios and perform the necessary migrations.
Also, importantly, it also separately records the features of the last client
to decrypt the wallet, because it's not just enough to open the wallet, it's
also different to decrypt the wallet, since some upgrades require access to
private keys.

_Core Lightning #9582_

That completes the Bitcoin Core section, and we jump into the Core Lightning
item #9582.  This is a massive PR from the CLN team.  It backports 77 commits
that have multiple security and reliability fixes from v26.06.8.  So, in
Newsletter #424, similar to how we covered the latest one, Newsletter #424, we
basically announced this security release and we said the source code, while
it was available immediately, some tests were temporarily withheld.  Also, the
fixes hadn't been committed to the master branch.  So, now they have been
committed to the master branch.  So, now we have a better background on what
were the vulnerabilities related to that release.  So, I'm not going to go in
massive detail, I invite listeners to jump into the PR if they want to learn
more.  There's 79 commits and most of them are bug fixes, but we're going to
go through the main ones.

So, the first one, one fix prevents force-closes after a completed splice from
broadcasting an outdated commitment transaction that may have been revoked by
subsequent channel updates, allowing the counterparty to claim funds as a
penalty.  So, here, the problem was that CLN, in some cases, and this goes
back to multiple versions, so some users could have had exposure for a long
time, they could incorrectly have published an outdated commitment
transaction.  And of course, their counterparty could have claimed the funds
as a penalty.  So, a massive issue that would have made some users lose funds,
because CLN would simply broadcast an outdated commitment transaction that was
already revoked.  So, now the fix simply prevents those force-closes after a
completed splice from broadcasting those outdated commitment transactions, and
finding themselves in a penalty transaction scenario.

The second fix is about an on-chain HTLC resolution.  It's about matching HTLC
outputs based on both script and amount.  Okay, so let's say if two HTLCs have
the same payment hash and also the same expiry, but they have different
amounts, then CLN could have basically mixed those two HTLCs.  So, when having
to fail one, it would fail the other, fail the incoming HTLC, even if the
corresponding outgoing HTLC was still claimable on-chain.  So, that would lead
CLN to fail an incoming HTLC, but not be able to recover it from the outgoing,
from the downstream peer.  So, now the fix is for CLN to not just check based
on script, but based on amount as well.

The third issue is a privilege escalation vulnerability.  This is a very
interesting one.  So, CLN has a makesecret RPC that allows RPC users to create
new authorizations for other users or for themselves.  But they're always
supposed to have less permissions than the caller themselves, right?  It
doesn't make sense if you can create a secret that gives you more permissions
than what you already have.  However, this is the vulnerability that was
present where a caller, authorized to use the makesecret RPC, could derive the
master rune's cryptographic secret and basically forge unrestricted RPC
authorization tokens.  So, anybody that had makesecret RPC access could forge
unrestricted authorization token.  So, now CLN blocks the derivation of the
reserved secret to not allow users to create unrestricted RPC authorization
tokens if they don't have the existing permissions themselves.

Now, there are multiple other fixes.  Like I said, I'm not going to cover each
one, but they're related to gossip-related DoS risks, dual-funding and
splice-RBF handling, anchor fee calculations in anchor channels,
multipart-payment processing, rune validation and blacklisting, BOLT11 and
BOLT12 message handling, onion routing, and finally, REST API
resource-exhaustion vulnerabilities.  So, quite a lot in this PR.  Once again,
that was included in the previous release, but now we have a newer one, so you
really want to upgrade to the latest release.

_Eclair #3390 and #3388_

Then, we have the Eclair item that combines two PRs, #3390 and #3388.  So,
this is about closing gaps in the protections against excessive mining fees
during dual-funding and splicing.  And this might seem familiar because we
covered similar issues in Newsletter #423, when we covered the item of Eclair
#3376 that had multiple issues also related to fees, but also related to other
situations.  So, this is sort of additional work on top of that, nothing that
competes with it, it just adds additional coverage.

So, the first PR protects against a compromised Bitcoin Core backend.  So,
Eclair holds the keys, but Bitcoin Core builds the transactions.  However,
Bitcoin Core could build transactions that basically misreport fees or
manipulate transaction outputs.  If you were using a compromised Bitcoin Core
backend, you could have basically paid excessive fees when Bitcoin Core
constructed transactions, and Eclair would simply sign and pay more than
intended.  The fix is for Eclair to independently verify actual fees, and
ensures the reconstructed funding transactions respect the expected amounts.
Eclair is no longer trusting Bitcoin Core, which previously it was.

The second PR is about preventing a malicious channel peer from imposing an
excessively high RBF feerate when Eclair is the one contributing funds to a
replacement dual-funding or splice transaction.  So, this was a missing check
that Eclair wasn't checking against its locally calculated maximum, right?
So, now it will.  Eclair will calculate the maximum feerate that it could pay.
And if the peer is proposing something higher, then it will simply reject it,
except in the case where the peer pays the fee, or specifically in the case of
the liquidity purchase as well, where the peer always pays the fee.

_LND #11290_

Then we're going to skip through the LDK items, because we had Elias from the
LDK team come in and present those to us.  But if you missed that, that was
around minute 25 to minute 45.  So, I would point you to take a look at that.
And finally, the last item on this list, which will allow us to complete the
Newsletter and the Episode, is LND #11290.  So, this is about fixing an
overflow bug when constructing BOLT11 invoices containing blinded payment
paths.  So, basically the problem was that LND used 32-bit arithmetic to
aggregate the forwarding fees of hidden hops.  But this meant that it could
overflow at relatively low fees, around 4,295 msat, or 4,295 ppm.  So, you
would construct a BOLT11 invoice as an LND node.  You would try to put a fee,
but it would overflow because it was using 32-bit arithmetic.  So, you could
construct invoices that advertise lower fees than the hidden hops actually
charge.  And this is specifically in the case when you build BOLT11 invoices
containing blinded payment paths.  And then, payers would attempt to pay that
invoice, but because they don't know the hops of the blinded payment paths,
they have to trust the fee that is marked, and they would pay too little fees,
which means that the amount that would arrive to the receiver node would be
under the requested payment invoice amount.  So, the payments would simply
fail because, like I said, the receiver would receive less than the invoiced
amount.

So, the fix is for LND now to use 64-bit checked arithmetic instead of 32-bit,
to calculate the aggregate fees that will basically not end up in an overflow
bug.  And also, it has to exclude paths whose fees exceed the invoice format
limits.  So, that is the final item of this list, and that completes the whole
episode.  Thank you so much, listeners, for being here with me tonight.  Today
was simply me as the only host, but in the next few weeks, we should have the
other co-hosts alongside us.  Thank you.

{% include references.md %}
