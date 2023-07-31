---
title: 'Bitcoin Optech Newsletter #261 Recap Podcast'
permalink: /en/podcast/2023/07/27/
reference: /en/newsletters/2023/07/26/
name: 2023-07-27-recap
slug: 2023-07-27-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Greg Sanders and Bastien Teinturier to discuss [Newsletter #261]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-6-27/340927362-44100-2-605437ca1324d.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #261 Recap on
Twitter Spaces.  It's Thursday, July 27, and we've got a great newsletter
covering a couple of different Lightning news items, including the Lightning
Network Summit and a bunch of takeaways from those notes.  We have five
questions from the Stack Exchange talking about segwit, OP_CSV, route hints; we
have a couple of releases, HWI and LDK to go over; and just a single lone
Bitcoin Core GUI PR to review.  Introductions, Mike Schmidt, Contributor at
Optech and Executive Director at Brink, where we fund Bitcoin open-source
developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch.  I work full time on Bitcoin open-source stuff
at Chaincode Labs.

**Mike Schmidt**: Greg?

**Greg Sanders**: I'm Greg.  I'm at Spiral and I do open-source stuff as well,
focusing on mempool as well as some Lightning work.

**Mike Schmidt**: T-bast?

**Bastien Teinturier**: Hi, I'm Bastian.  I work at ACINQ on the Lightning
specification and implementation Eclair, and on the Phoenix wallet as well.

**Mike Schmidt**: Well, it's great to have some Lightning expertise for this
newsletter, that's for sure.

_Simplified LN closing protocol_

The first item that we have in the news list here is Simplified LN closing
protocol.  And Rusty Russell proposed this on the Lightning-Dev mailing list,
and there's also a PR open with some changes and unfortunately due to time-zone
restrictions, Rusty isn't able to join us to talk about his proposal.  But
luckily I saw that it was being heavily commented or reviewed by t-Bast who was
going to be joining us already for the LN Summit discussion.  So, t-bast, it
sounds like you're comfortable kind of walking through what Rusty's proposing
here.  Maybe you want to take the lead and explain exactly what's being
discussed.

**Bastien Teinturier**: Yeah, sure.  So initially, the first version of
Lightning had a protocol for mutual closing channels that is still heavily in
use, where we thought that having dynamic negotiation of a fee was a good idea.
So, whenever you say that you want to mutual close your channel, the only one
who is going to pay the fees for that is the party who initially opened that
channel, so they don't have an incentive, they really don't want to overpay the
fee.  But then, if they're not the one who initiated the closing, maybe they
didn't really want to close so they don't have an incentive to -- the incentives
are a bit weird regarding how to set the fees.

So since we didn't know how it would turn out, we created a protocol where each
side says, "I'd like the fee to be that", and the other side has to answer with
either, "I'm accepting your fee", or, "I'm raising it [or] lowering it".  And
you can have many rounds of exchanges like that, where it goes back and forth
between the nodes, until you decide on what fee you want to apply to a mutual
closing transaction.  But the issue is that since this is automated, actually in
implementations, it's already decided from the start what fee you're going to
accept and what fee you're going to reject, so this negotiation was not actually
very useful, and it created a lot of issues between those that couldn't agree on
fees.

So at some point, we added a small tweak to that to make it one round and a half
of exchange, where the party who wants to close the channel sends a
Type-Length-Value (TLV) saying, "I will accept any fee inside that range, and I
am proposing that one".  And then the other party can either just reject that
entirely by disconnecting, or can either also accept the fee that was proposed,
or propose another fee inside the range that was proposed.  But we realized that
this was causing issues for taproot because now that we are preparing a
migration to taproot, whenever we sign a transaction, we will have to exchange
nonces beforehand.  So, we really need the protocol to be request response,
where we can always have an opportunity to share nonces before we actually sign
the transaction.  So, we needed to change it.

Rusty's proposal was that instead of creating one transaction and trying to
negotiate the fees on it, we would actually create two transactions, one for the
channel initiator, one for the non-channel initiator, where each one decides how
much fees they're ready to pay and what fees are taken from their output.  So,
if I'm the initiator and I want to close the channel, I'm going to say, "I'm
closing that channel with that fee that is taken from my output.  I will pay
that fee.  Please just give me a signature where you don't pay any fee and the
resulting transaction has the fee I'm proposing".  And the other party can also
say, "I want a transaction too, here is the fee I'm ready to pay.  Please just
give me a signature and I'll pay that fee".

So in the end, you have two transactions that are negotiated with just one
request and response, one where the initiator is paying the fee, one where the
non-initiator is paying the fee, and each of them chose the fee they are ready
to pay.  So, everyone should have a transaction they're happy with now.  And
since this is request response as well, this makes it easy to share nonces for
MuSig to taproot funding outputs.

**Mike Schmidt**: Okay, so each side gets a chance to propose and while you're
doing that communication, you're also taking advantage of that interactivity
point to also exchange nonces?

**Bastien Teinturier**: Yes, exactly.

**Mark Erhardt**: And this will always terminate, because the person that wants
to close the channel, of course, already says, "Hey, I want to pay this amount
and it'll be taken from my portion of the channel".  So, if the other person
does not want to pay, they can just sign off on it; and if they want to have the
closing transaction a higher priority, they have to actually pay more and then
the other party can just sign off, so there's no deadlock here anymore.

**Bastien Teinturier**: Exactly.  And on top of that, if you have both prepared
two transactions, published them, they're not confirming, at any point in time,
you can just resend that message that says, "I'm ready to pay that fee now.  And
please just give me a signature where you won't pay anything and I'm going to
pay that fee so that we can RBF the mutual cost transaction", which is also a
good improvement because before that, I don't think we had any way to do RBF
right now.  So now, it's going to be a very simple version of RBF, where the
incentive should be properly aligned because only one party is paying the fees
and they are the one proposing that RBF.

**Mark Erhardt**: I really like that the person that wants to close the channel
now has to pay for it, because it always baffled me that the person that started
the channel also had to pay the closing fee.  That made no sense, and this makes
a lot more sense to me.

**Bastien Teinturier**: Yeah, even though this creates also potential issues,
because the commitment transaction right now, the fees are paid by the channel
initiator.  So, when you have a channel non-initiator, maybe you have more of an
incentive to force close than to mutual close because this way it's going to be
the channel initiator that will pay the fees.  But if you play that game, the
channel initiator will just blacklist you and you have to come up with a new
node ID if you want to have channels with them, because force closing on someone
is just, yeah, not a gentleman's agreement.

**Mike Schmidt**: You mentioned in your outline of the current way that closing
is done that there was a tweak to make it down to one-and-a-half rounds of
exchange, I believe.  It sounds like this simplified protocol is two rounds.
Are there other downsides, other than that additional minor communication that's
done, that there would be a reason to hesitate on implementing the newer
protocol, other than just getting everybody to implement and roll it out?

**Bastien Teinturier**: No, I don't think so.  And honestly, the communication
is really not an issue here, because you are actually closing that channel,
you've already decided that you want it to close it, so you're not relaying any
Hash Time Locked Contracts (HTLCs) on it.  So, this is basically a channel that
cannot be used any more, there's nothing urgent to do on it apart from closing,
so having even a few more round trips is just not at all an issue.  Nothing is
latency sensitive here, so this really isn't an issue.  So, since we all want to
move to taproot, and this was one of the blocking points for taproot, that we
didn't have a good way of closing taproot channels and exchanging the nonce
securely beforehand, I think everyone will just implement that version.  And
this way, we'll be able to completely deprecate the older two versions at some
point.

**Mark Erhardt**: Okay, I have one more question.  Why is the fee for the
commitment transaction paid by the opener of the channel?  I understand why that
would be the case for the initial open commitment, because when the opener opens
a channel and the -- well, I guess the other party does accept it anyway.  Yeah,
I don't understand why the balance is not -- well, I guess in the initial
balance all of the balance is on the side of the opener and that's why they have
to pay the fees.  But after that, there's a reserve on each side.  So why
wouldn't it transition to it being 50/50 split or something?

**Bastien Teinturier**: Because there's only one other party can actually change
the feerate of a commitment transaction and it's the channel initiator.  So, if
you are not the channel initiator and you are paying for part of the fee and
only the initiator is able to choose that feerate, that would be an issue.  So,
we would have to introduce the ability for both sides to send the update fee
message to change the fees of a commitment transaction.  And already, with only
one side of a channel being able to send that message, it creates a lot of
issues, because updating the fee of a commitment transaction while you have a
lot of HTLCs in flight can actually make you deep into your reserve.  And there
are a lot of edge cases around that that are really weird and annoying.

So, since our goal is rather to go in the direction of removing update fee
entirely and using zero-fee commitment transactions, we're just not going to
bother changing how the fee is paid before we get to that point.  The goal is to
just get to a point where the commitment transaction doesn't pay any fee so that
everything is simpler.

**Mark Erhardt**: Right, because of course, we're also going to get to that in
the next block.  So actually, yeah, I'll talk about it there.  Mike?

**Mike Schmidt**: Yeah, I think it's probably good to jump into the second news
item, then we can continue some of this discussion.

_LN Summit notes_

The second news item in Newsletter #261 was about the Lightning Network Summit
notes.  So, there was an in-person meeting of some of the Lightning Network
developers in New York, and Carla posted to the Lightning-Dev mailing list the
summary of a bunch of the discussions that occurred.  It sounds like that was a
several-day meeting.  There was a variety of topics that we highlighted from
that list in the newsletter this week.  I also wanted to sort of introduce why
we invited instagibbs to come talk about some of this.  Greg, folks may be
familiar with some of your further background working on Bitcoin, but you've
been doing some Lightning work recently.  Maybe you want to talk about that
briefly, and then we can kind of jump into some of these items?

**Greg Sanders**: Sure.  Yeah, so for the past year or so, I've been working on
an implementation of what's called Eltoo, which I picked the name LN-Symmetry.
So basically you have symmetric payment channel networks, so the channel has
symmetric state.  It requires a soft fork, the anyprevout soft fork, but
basically proving out the design of that.  And I also, due to that, started
working on package relay and related.  So it's kind of how I got into this, I
guess.

**Mike Schmidt**: And that leads --

**Mark Erhardt**: And joined the anti-pinning task force.

**Greg Sanders**: Yeah, well part of it, right.  So, especially with something
with symmetric, you basically have to worry about when your transaction hits the
mempool and there's no penalty.  And so you really have to care that there are
ways of paying fees and getting in blocks properly, which there really isn't
that well right now.  LN relies on the penalty a lot to kind of enforce good
behavior, when I think it's not as necessary in this imagined future with an
improved mempool.

**Mike Schmidt**: Speaking of some of those improvements, the first item we
noted from the summit was Reliable transaction confirmation, which was a
discussion that includes package relay, v3 transaction relay, ephemeral anchors,
cluster mempool, and a bunch of other topics about getting your transactions
relayed and mined.  We've talked a bit about some of these in our Waiting for
confirmation series the last couple of months.

I was looking through the notes and I don't know if we want to get into the
details of each one of these, but some things that stuck out to me from the
notes were, "In what way does it not fit LN as it's currently designed?"  And
that wasn't attributable directly, I don't think, to any one of these.  And then
there's also a question about when do we jump?  Wait till V3 package relay?  So,
these are kind of maybe big picture questions about how LN moves forward
relative to some of these proposals that we've been talking about.  Maybe,
instagibbs, you can kind of talk to that a bit.

**Greg Sanders**: Yeah, I can speak to that a bit.  So, a number of people have
been working on this package relay and v3, ephemeral anchors, cluster mempool,
all this stuff.  But the question is, when do you do a first cut, right?
Because it's one thing to have the code, let's say, launched and Bitcoin Core
nodes get updated, and eventually the network updates enough where you can rely
upon it.  But there's also the specification work as well.  So for the LN
specification, you'd have to pick it up, get it developed, get a spec developed,
get it implemented and get it rolled out.  So, that's like another level.  And
so, basically it's looking at what parts would be worth it to get a first cut of
updates to the LN spec, and so there's some back and forth on that.

Basically, I think there's some basic agreement on this line that we're shooting
for with package relay, v3, and ephemeral anchors, where the commitment
transaction can get a very nice cleanup and improvement and kind of confirmation
requirements, while the rest, there's still some pinning vectors beyond that
with HTLC transactions.  Oh, Murch, you can poke your head in.

**Mark Erhardt**: Sorry, I wanted to make the call back here that the proposal
with the v3 transactions and the ephemeral anchors, of course, is what allows
commitment transactions themselves no longer to have any fees.  So, that would
be enabling us to (a) have to have one that makes the force close bring the
fees, and (b) to have zero fees on the commitment transactions themselves.

**Greg Sanders**: Yeah, we'd be able to get rid of that message, the update fee
that t-bast was talking about, which would be great.  I never had to deal with
that with my LN-Symmetry work, and so I also did not implement mutual closings
because of all the complications you mentioned.  I thought in my head, they'll
probably pick a better protocol by the time it actually would be required and
ends up being true, so that's good news.

Where was I?  And so, at the HTLC level, so you have these smaller outputs,
well, relatively small outputs on the commitment transaction that are in the
smart contract itself for relaying payments across network.  Those, in some
cases, would still be tenable because from the feedback I got basically it's,
fixing it, does it bridge too far?  It's, I would say, in the garden-path case,
where the nice case where your counterparty just went offline and won't talk to
you anymore, it would become more expensive to resolve these HTLCs in an
unpinnable way.  So basically, it's kind of a trade-off between the case where
your channel partner falls over versus they're trying to pin you and steal your
funds.  And basically, there's some choices to be made there.

With future updates to the mempool, hopefully we get around that just basically
for free, where any channels that have already updated with v3 and ephemeral
anchors will benefit from these other background updates as well.  But that's
further in the future, like considerable further in the future.  And in the
interim, you can reduce your exposure by essentially reducing the amount of HTLC
exposure you have in total, which is a configurable parameter, which I think all
implementations do now.

**Mark Erhardt**: Yeah, I had one other question.  Maybe it's a little too many
steps back, but I don't think we see a ton of pinning on the network right now.
So obviously, pinning is possible and makes things harder, but how much weight
should we be putting on fixing pinning if we don't see any of it on mainnet?

**Greg Sanders**: Well, with penalties, maybe it's less of a problem, but also
pinning is a problem in lots of other scenarios too, Discreet Log Contracts
(DLCs), any sort of time-sensitive contract, right?  It's also just a life
headache, but it's a judgment call, because right now, LN kind of works on firm
handshakes, nobody's attacking each other, nobody's doing channel jamming, but
that could all change overnight.  I don't know, maybe Bastien has another
opinion on that.

**Bastien Teinturier**: Yeah, I think also one of the reasons we don't see
pinning is that really, it's harder to pin right now and make it work your
while, because right now, commitment transactions do pay some fees.  It's been,
most of the time, with only the fee that it pays, it's going to be confirmed in
the next week or two weeks or so.  So, making sure that you are actually pinning
it and getting more value out of the attack than what you paid to actually make
the pinning work is probably quite hard today, especially with the state of the
mempool.

When it was three months ago and the mempool was really full for a long while
with high-fee transactions, then there was an opportunity to do pinning, but I
don't think any attackers were really ready to actually do that.  But that
doesn't mean they won't be ready for the next time this happens.  And if mempool
stays full with a very high feerate for a few months, then there's an incentive
to start attacking, and I think we should be ready for that before it happens.

**Mike Schmidt**: Greg had mentioned DLCs as another potential protocol or
different types of protocols that should be considering relay policy, mempool,
and getting confirmations.  We noted in the newsletter, "We strongly recommend
readers with an interest in transaction relay policy, which affects almost all
second-layer protocols, read the notes for the insightful feedback provided by
LN developers on several ongoing initiatives".  This question, I guess, is for
Murch, Greg or t-bast, but are there other layer 2 protocols that we see having
an interest in contributing to some of these discussions?

**Greg Sanders**: Well, statechains is another thing that needs -- It's any
time-based contract, right?  So statechains, spacechains, Ruben Somsen's saying
it needs ephemeral anchors.  They're kind of all over the place.  I haven't seen
a lot of contribution from those projects, aside from having open dialogues.
So, I would talk to Bastien quite a bit, I would talk to the statechains people.
I'm making sure that whatever we're building would actually be useful by these
projects, I think that's very important.

**Mike Schmidt**: Murch, you good to wrap up this first bullet?  All right.  The
second segment of the LN Summit notes that we highlighted was Taproot and MuSig2
channels.  And I'm curious how Lightning engineers are thinking about taproot
and MuSig2 related channels and how the audience should think about their nearer
term uses in Lightning, in contrast to something that I think a lot of Bitcoin
hopefuls are thinking about, which is Point Time Locked Contracts (PTLCs)
involving schnorr signatures and adaptor signatures.  What is taproot and MuSig2
fitting in; and then maybe contrast that a bit with PTLCs?  Maybe that's for
you, t-bast.

**Bastien Teinturier**: Okay, so for now, the first thing we are doing with
taproot is just moving the funding transactions, the channel output to use the
MuSig2 taproot output.  This way, it's indistinguishable from any other taproot
output, whereas right now, funding outputs are witness script hash of 2-of-2
multisig, which is really easy to distinguish onchain.  So, just moving the
funding transactions to use MuSig2 already has a very nice benefit for all
users, and it's a good way to start experimenting with taproot with MuSig2
before moving on to PTLC.  So we're only focusing on that funding output for
now.  And even with that one, I think we've ironed out almost all the details,
and I think both LND and LDK have a first version, a first prototype that is
working almost end-to-end.

The main question that we had during the Summit is that there's work when the
current proposal spends the MuSig2 output for both commitment transactions and
splices and mutual closes, which means that we have to manage nonce-state,
MuSig2 nonce-state in many places, and it's potentially dangerous because
managing those nonces correctly is really important for security.  And there was
an idea that instead of using the MuSig2 output, the commitment transaction,
actually, the funding output would have both a keypath spend that would be
MuSig2, but also a scriptpath spend that would use a plain, normal 2-of-2
multisig, so that all the commitment transactions would use the scriptpath
spend.  And this way, you don't have to exchange nonces for the MuSig2 output
and only the mutual closing and maybe the splices, probably the splices as well,
would use the MuSig2 spend path.

So this would really simplify the proposal, but is it really worth it, because
it still makes the commitment transactions weakness bigger than if we just spend
the MuSig2 output.  So, there are arguments for doing it both ways, and it's not
decided yet.

**Greg Sanders**: Yeah, if I can jump in.  I'd say, to me, I have some
experience working.  For the LN-Symmetry, I did the MuSig nonces for everything.
I didn't think it was too bad, but the one key difference here is that for the
payment channels with penalties as currently designed, it's necessitating that
you store these secret nonces forever until channel close.  This is the main
issue here, in my opinion, where you're basically holding on extra key material.
You have to persist it to disc,  you have to write it somewhere, where if you
look at like the MuSig API, they say don't persist this.  There's no
serialization format, and there's strong recommendations against not doing this,
right?  And yet this current spec, as it is recommending, is basically acquiring
it.  So I think that's, to me, the biggest red flag.

The rest seems okay to me, actually, as far as complexity is concerned.  For
LN-Symmetry, I didn't have to pull this around because there's no penalties, so
I just, in memory, hold these nonces and then complete signatures just in time.
So, just a bit of context there.

**Mike Schmidt**: Murch or t-bast, any other comments on taproot and MuSig2
channels?

**Mark Erhardt**: Oh, maybe one.  We had a great podcast out in the Chaincode
podcast, where we talked to Elle Mouton and Oliver Gugger about simple taproot
channels, which basically is this proposal.  So, if you want to learn more about
that topic, it's not too long, something like an hour or so, walking through all
the details of that proposal.

**Mike Schmidt**: The taproot and MuSig2 channel discussion somewhat leads into
the updated channel announcement discussion and how gossip protocol would need
to be upgraded in order to support moving to P2TR outputs.  Maybe, t-bast, you
can give an overview of why the current gossip protocol is incompatible with
taproot and MuSig2 channels, and what the different options were discussed
during the meeting about how to upgrade it.

**Bastien Teinturier**: Sure.  So right now, when we announced the channel on
the network, we explicitly announced node IDs and the Bitcoin keys that are
inside the multisig 2-of-2, and people verified that the output that we are
referencing is actually locked with the script hash of multisig 2-of-2 of those
two keys, so you can only use it with scripts that really follow the format of
Lightning channels without taproot.  So, we need to change that, because we need
to allow taproot, which means allowing also input, especially if we use MuSig2;
we don't want to reveal the internal keys.

The discussion is, how far should we go?  Because we've always been discussing
the fact that announcing, having the channel announcement point to a specific
onchain output, was quite bad for privacy and that we could probably do better.
But there are a lot of degrees to how much, how more decorrelated we could make
it.  And we've always gone back and forth between those, because we don't know
if we should do a simpler version first and wait for later to do a much more
complex version, or if we should just jump to the more complex version right
now.

I'm not sure what the consensus is right now.  I think we're going to stick to a
simple version, where you allow pointing to any type of output to pay for your
channel.  But I don't think we'll allow you to have any kind of multiplier,
because one of the other ideas was that you could also just announce some UTXOs
that you own, with the proof that you own them, with a total value of, for
example, 2 bitcoin, and then that would grant you the ability to announce up to
X times that in channels without having to point to any specific onchain output.
And that would be nice, very nice for privacy, but it's hard to decide what the
multiplier would be, it's hard to decide how we will make the proofs and how we
will make sure that the proofs cannot be reused.

So, I think we are not going to do that in the short term.  I think this is
still going to be different for later, and we are just going to be allowing any
kind of UTXO in your channel announcement that has to match the capacity of the
channel that you are announcing.

**Mike Schmidt**: Maybe dig a bit deeper into this multiplier concept, like what
needs to be -- I know that's not something that is getting moved forward with, I
just want to understand a bit myself.  This isn't fractional-reserve bitcoin, is
it?  Go ahead, Greg.

**Greg Sanders**: Yeah, I just had one point.  So right now, the way channels
are announced, it has to be specific 2-of-2 multisig, looks exactly like
ln-penalty channels.  But with this, this kind of narrowly allows taproot
channels as well, but it also opens the door for experimental channels.  Sorry,
my small child is yelling!  If you have another Lightning-like channel
specification that you coded up or a custom channel type, you can also include
that in this channel announcement and it will just work.  No one but your
channel partner has to understand how the channel works, essentially.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: I had a follow-up question.  So, you can point out any output
that has sufficient funds to have basically funded that channel; I assume that
means enough or more.  And on the other hand, how do you make sure that the same
UTXO is not reused for the announcement; and what happens if that UTXO gets
spent?  So, will we need to be keeping track of the UTXO actually not being
moved while it is the stand-in to have announced the channel?  Can the channel
stay open when the UTXO gets spent?

**Bastien Teinturier**: Yeah, that's actually the hard part.  That's why we're
not doing that right now, and that's why most people will just keep announcing
the output that really corresponds to the channel so that when it gets spent,
people actually notice it and can remove it from that graph and know that they
cannot route through that channel anymore.  So, those are things that we've
always been just hand-wavy about how we would do that in the future.  We don't
know exactly how we would do that, those proofs, and how we would make sure that
those proofs cannot be reused, how we would track channel closing differently
than just watching onchain.  So, those have just not been thoroughly explored
and I don't think there's a real solution for that yet.

**Mike Schmidt**: Next section from the Summit discussed PTLCs and redundant
overpayments.  Maybe we can begin with t-bast.  What are PTLCs, what are
redundant overpayments, and why are these two being discussed together?

**Bastien Teinturier**: Okay, so PTLCs are a change that is allowed by taproot
and adaptor signatures.  Right now, whenever you send a payment, this payment is
going to go through multiple nodes on the network.  And right now, it's going to
use the same payment hash with all these nodes, which means that if someone owns
two of the nodes in the path, they are learning information, and this is bad for
privacy.  PTLC fixes that by making sure that instead of using the preimage of a
SHA256 hash and its hash, we're going to use elliptic curve points and their
private keys.  And they're going to be tweaked at every hop, which means that
even if you have multiple nodes that are on the path of the same payment, it's
not going to be payment hash, you're going to see a different point, a different
secret than in both nodes.  So, unless there's obvious timing, amount, and
expiry values that lets you know that this is actually the same payment, at
least the cryptography of the secrets that are shared will not let you correlate
those two payments.

So, this is a very nice improvement and it also opens the door to creating more
things on top of normal payments like redundant overpayments.  The idea behind
redundant overpayments is that when you are trying to send a big payment across
the network, you're usually going to split it across multiple routes because you
won't be able to find a single route that will be able to carry that whole
payment in one go.  So once you split it, there's a risk.  You have more risk
that one of those shards will not get to the recipient because there's a buggy
node somewhere in the middle.  So, what if you could instead send more than what
you are actually trying to send to increase the likelihood that at least the
required amount gets to the destination, but while preventing the recipient from
claiming more than what you intended them to have.  So, this is quite hard to do
correctly, and there are proposals.  There are two research papers that have
proposals on how to do that by modifying the scripts that we use in the
corresponding output in the commitment transaction.

So, those things become possible with PTLCs, and we'll see when we actually
implement them.  But I think this is still very far away in the future.  So a
first version of PTLC will not have redundant overpayment, in my opinion,
because there are different ways that could be achieved, and they have different
trade-offs that need to be explored a bit more.

**Mike Schmidt**: And those techniques that you mentioned, is that the boomerang
and the spear that we mentioned in the newsletter?

**Bastien Teinturier**: Yes, exactly.  Those are the two I know of.  There's
another one that's much simpler that just lets you add another secret and add an
additional round trip between the recipient and the sender, and this is the same
thing as a stepless payment.  This is how it was called in 2019 or 2020 when it
was first proposed, and this is something we could do easily with onion messages
and PTLCs, but it's less efficient than boomerang or spear.  So, we would have
to do more research on how we actually really want to do redundant overpayment.
And also another issue with redundant overpayment is that you are actually, for
the duration of your payment, using more liquidity of the network than what is
required.  So, maybe this is an issue, maybe not, but we'll have to think about
it in more detail.

**Mark Erhardt**: So basically, all of these would decouple the establishing of
the multi-hop contract with the execution of the multi-hop contract.  So, in the
regular multi-hop payment as we use it today, the last hop getting established
of the contract also transfers the secret to the recipient so that they can
start to pull in the payment, which makes it cascade back to the sender.  But
with these both redundant overpayments and also with the stepless payment,
basically we first establish the contract and once we get a response from the
recipient that they have received sufficient parts of the contract, we would
only then exchange the secret; and once they have the secret, we can exchange
the secret in a form in which they are only allowed to pull in enough payments.
So basically that's the idea here, right?  Cool, thanks.

**Greg Sanders**: Yeah, that sounds right.  So the one, Bastien, you're talking
about, I think that's spear actually.  Spear is the H2TLC, or something like
that, which can be converted into PTLC.  And I think the original stock list is
essentially like, you can do the full payment 100%, and then you can also do a
secondary and a third.  So it's like 100% of liquidity required, then 200%, then
300%.  Whereas boomerang and spear allow you to do essentially fractions above a
100%, is that right?  So, it's not immediately clear to me, like, is that even
necessarily better?  I don't know.  That's up to people to figure out, I guess.

**Mark Erhardt**: Yeah, with the simple variant where you do two or three times
more, wouldn't that be sort of a jamming vector?

**Greg Sanders**: Well, they can all be jamming vectors, it depends.  Complexity
does matter, too, I don't know.

**Bastien Teinturier**: Yeah, and even if it was only 50% more or even 20% more,
that could be considered jamming as well.  So, it's really hard to figure out
where to draw the line here.

**Mike Schmidt**: Well, speaking of jamming, the next topic from the Summit was
Channel jamming mitigation proposals.  We've spoken previously, over maybe six
months a bunch of different times, about different kinds of channel jamming
attacks: liquidity jamming attacks, which exhaust the capacities in channels;
and HTLC jamming attacks, where the attacker attempts to take all the HTLC slots
with a bunch of small payments.  We've also spoken with Clara and Sergei about
their research work involving upfront fees and local reputation.  We've had a
few of those discussions over maybe six or nine months, and I'm curious how you
all would summarize the jamming discussions from the LN Summit meeting.

**Bastien Teinturier**: So basically jamming, there are two types of jamming,
slow jamming and fast jamming, and those two types of jamming potentially and
most likely need two different kinds of solutions.  So for fast jamming, paying
upfront fees all the time, whenever you send an HTLC, even if it's going to
fail, you pay a small fee, a fixed upfront fee.  This is a very easy way to
solve fast jamming, but the issue is that it has an impact on normal users as
well, because if you're a normal user, you try to make payments, you have a lot
of failures before you actually get to the recipient, you will have paid upfront
fees for failures that you may think are not your fault, not something you
should be paying for.  So this is more of a UX issue, but on the technology
side, it's somewhat easy to fix.

But the harder thing to fix was the slow jamming issue, where you send an HTLC
that takes a lot of liquidity, or a few HTLCs that take a lot of liquidity, and
you just hold them for a very long time.  And for this, one of the promising
solutions is to use local reputation, where you track how much fee revenue every
one of your peers has generated for you in the past, and you only allocate them
liquidity bandwidth for something that would lose less than what they made you
earn in the past basically.  And Clara and Carla have been working on that for a
while.  Thomas from our team has been working on that for a while.  It's really
hard to find a good reputation algorithm that would seem to work.

But what's interesting is that once we start having ideas, concrete ideas on how
to do that local reputation, we can actually deploy it on our node in a shadow
mode, where you will still relay all the HTLCs, but you will keep track of the
reputation, and you will record the decision you would have made if we would
have activated that code.  This way, we can let this run on the network for a
while, evaluate how it works in real life, and once it's in implementation, that
way we can also start doing some research on regtest where we simulate networks
where attackers are trying different kinds of behaviors and see how the local
reputation algorithms work with those type of attacks.

So, this is really making progress.  We're going to be able to deploy those in
shadow mode to collect data, I think, in a few months on nodes on the network,
and then I hope that researchers pick that up and try to attack those algorithms
by stimulating some attacker behavior.  So, we're going to be able with that to
make good progress and hopefully, at some point, have a good enough solution to
fix all those jamming issues.

**Mike Schmidt**: Does it feel like this is moving towards experimenting and
figuring out one solution, and that all implementations and node-runners and
going to use that solution, even if it's a combination of techniques; or is this
more something that different implementations may have different combinations of
keys and different algorithms for reputation, and maybe even users would be able
to configure that; which direction do you see that going?

**Bastien Teinturier**: It's really hard to tell, honestly, because both
directions can make sense in some scenarios.  It's hard to figure out if hybrid
deployments would actually really work in practice.  So, that's why I think the
first step is to get those mechanisms deployed, make them easy to tweak so that
we can actually really test this and see how it behaves.  And then we'll have a
better idea of whether anyone can do their own thing and still be protected, or
if it's better that everyone applies the same reputation algorithm to make it
work.  This is really hard to answer when we don't have the data and the right
model for that.

**Mark Erhardt**: It also is really nice about -- one thing that I really want
to point out.  Again, this is not a reputation system where nodes share
reputations between each other and gossip about it, where we have to be worried
about someone bad-mouthing another node or anything like that.  This is purely
local, so every node will start collecting information on their peers, how they
have previously interacted with them.  So, they basically allow heavy users,
sort of regular customers, access to more resources, and that will basically
ensure that the peers that your node always interacts with and continues to have
a good relationship with, continue to be able to send, even if a new user that
hasn't established themselves starts taking a lot of resources.

So, the downside of this approach is that this sort of scheme is open to a
long-term attack, where people just build up a reputation and then, at some
point, attack and take a lot of resources and jam.  But that comes with the cost
of first behaving well for a long time and paying a bunch of fees towards
building up the reputation.  So, for the most part, that should just work.  And
even then, if they do jam, it's no worse than what they could have done if we
hadn't reserved some of the resources for our regular customers in the first
place.

**Mike Schmidt**: But it doesn't prevent that information, that local
information, from being shared outside of the protocol, right?  There's
obviously some value in that information.  People could sell that information or
use it internally to configure their channels accordingly, right?

**Mark Erhardt**: I guess you could sell that or share that, but it's not clear
to me why any other peer or network participant should trust you to have
accurate information.  So, it would sort of become a, "He said, she said"
situation where, sure, people could have these lists or could claim that certain
nodes are better, or make a personal opinion listing of what the best nodes are,
but there is no incentive or reason why other peers should trust in.  It's sort
of like how Bitcoin nodes all do their individual check of the blockchain and
enforce all of the rules locally, because they have absolutely no reason to
trust another peer that that peer did the work and is truthfully reporting the
data to them, instead of just doing it themselves locally.

**Mike Schmidt**: That's fair.  Greg, or t-bast, any other comments on channel
jamming discussion?

**Greg Sanders**: No.

**Mike Schmidt**: All right.  Next item from the LN Summit that we highlighted
in the newsletter was Simplified commitments.  Currently in Lightning, either
channel peer can propose a new commitment transaction at any time, and this can
be simplified by introducing this notion of turn-taking.  T-bast, can you talk
about the issues with either peer being allowed to propose a commitment
transaction and why turn-taking may be a good idea?

**Bastien Teinturier**: Yeah, so the current protocol is optimal in terms of
latency because both sides can be continuously applying updates.  But that means
it's hard to reason about the state because at any point in time, you have a
correlation between what's signed in your commitment and what's in your peer's
commitment.  It makes it hard to debug, it's something where we had a lot of
compatibility bugs over the years, and it created a lot of force close a few
years ago because there were compatibility issues when many updates were in
flight, and just because that protocol was complex to get right.  So, I think
that now we have fixed most of these issues, we haven't seen in the past one or
two years any issues related to the implementation of that protocol.  So, that's
why we haven't moved that much to change it, because we finally have something
that seems to work across implementations.

But whenever we want to add new features on top of it, the complexity that we
have today is going to make it harder.  So, Rusty wanted to simplify that and
instead, move to a model where each side proposed updates.  I propose some
updates, then it's your time to propose some updates, then it's my time, so that
it's not as efficient in terms of latency, because if you want to propose an
update and it's not your turn to propose them, you'll have to wait for a bit.
But actually, I think that at that point, latency shouldn't be that much of an
issue, but that's something that we'll see once we actually have implemented it
and have some figures running on the real network.

It really makes the protocol simpler and it allows us to do some things that we
could not do before, like imposing dynamic limits on what gets into our
commitment.  Because right now, we have to set static limits right from the
beginning when we establish the channel.  For example, you cannot add more than
30 HTLCs to a commitment.  And if you add one more than that, my only option is
to force close basically.  And we've simplified commitments.  We would have the
opportunity to just reject some of the updates without force closing, which is
really a nice benefit.  This is something that Rusty has proposed a very long
time ago.  It's always been quite unclear how much priority we should assign to
that, because now that we have a protocol that everyone's implemented and works,
when is it going to be worth changing?  But maybe with splicing and I'll need to
make some of those static parameters dynamic, maybe this is becoming more
important.

But to be honest, I'm not sure how soon we will implement that and how soon that
will get traction.  That's something that we will eventually do because
simplifying the protocol is always a good idea, but it's hard to tell when is
going to be the right time.

**Mark Erhardt**: So I'm wondering, one of the issues that seems to jump out
when I hear you talking about this is, what if one side keeps making updates but
not concluding it?  How do you know; is there a way for the other party to say,
"Hey, I want to take my turn, can you finish up?"  Or, is it just generally that
everybody should only take as little time as possible, as in, "I propose this
and we wrap it up immediately, we finish up our commitment transaction", and
then it's nobody's turn for a while until somebody starts taking a turn again;
or, how is it ensured that everybody can take turns when they need to?

**Bastien Teinturier**: I think Greg implemented that, so...

**Mike Schmidt**: Okay.

**Greg Sanders**: Yeah, so I implemented this for LN-Symmetry because it's
symmetric for protocol, so it makes sense, right?  So, you can prompt, basically
a yield, you say, "Hey, I have an update, it's not my turn".  You send like an
app, like a message, and then you can also yield your turn, so send a yield
message.  So basically, it's not quite latency optimal, but if you're not doing
anything or if you have a pending update you want to give, you can prompt a
yield from them to take your turn.  So does that answer it?

**Mark Erhardt**: So, while nobody is taking a turn, both have yielded and then
anybody can start again, or…?

**Greg Sanders**: Well, it's always someone's turn.  Nothing could be happening,
or nothing has to happen.

**Mark Erhardt**: Oh, okay.  So, let's say it's your turn right now, I want to
make a payment, then I say, "Hey, I know it's your turn, but can I do an update
right now?  I have one", and then you send yield, and then I can go?

**Greg Sanders**: Exactly.

**Mike Schmidt**: The last item from the LN Summit is about The specification
process.  And we note in the newsletter, "The discussion appeared highly varied
and no clear conclusions were apparent from the notes".  So, perhaps a question
to Greg and t-bast, how would you summarize this meta-spec process discussion?
Is there anything notable to take away?

**Bastien Teinturier**: I think mostly that it's starting to work fine and we're
starting to have good velocity on the spec process on some of the important
features.  We want to make sure that we use IRC more for day-to-day
communication, and to make sure that because right now, communication has been
scattered across different smaller groups who are implementing different
features.  For example, for implementing splicing, the splice implementers
created their own Signal or Discord groups to do day-to-day discussions without
polluting the main IRC channel.  And we decided that we should just pollute the
main IRC channel for everything, because it has been dead for a month, and there
was just no activity on that IRC channel, which was really sad.  So, everyone is
okay with just having all discussions on the IRC channel and we'll start that
and we'll see how it goes.

On the spec itself, there was a proposal to move to working groups to split the
specification into different working groups.  But to be honest, everyone's
feeling, I think, was that we're not a big enough team of people actually
working seriously on the specification to be able to split into many working
groups.  So, that wouldn't really make sense for the BOLT, because most of the
BOLTs are actually interconnected.  Some of the things you change, most of the
features, you will require touching many of the BOLTs, so you cannot just have
one working group per BOLT.  And even working groups per features, it's not
really enough.

So, since we're still a very small team, maybe at some point, I hope that we are
way too many specification writers, and then we need to split into different
working groups.  But this is really premature.  So right now, we are just going
to keep working like we've been doing for the past few years, try to make sure
that we discuss on IRC a lot more, so that many people can see all of the small
nitty-gritty details of how every feature is moving forward.  But apart from
that, I wouldn't expect any major change.

**Mike Schmidt**: Greg, did you have anything to add?

**Greg Sanders**: No.  I haven't been as deep in the argumentation like Bastien.

**Mike Schmidt**: There were two other items from the notes that we didn't cover
that I wanted to give either of you an opportunity to comment on.  One was
multisig channel parties, and the other one was async payments/trampoline.  Greg
or t-bast, is there anything that you think the audience would benefit from
knowing about those discussions?

**Bastien Teinturier**: Hmm, on the first one, it was just about using threshold
signatures, and I think there are cryptographic details to iron out before it
becomes a real possibility.  So, I'm not sure this has made a lot of progress,
but this can still make progress in the past months, but I haven't been tracking
that closely.  And then async payments and trampoline, this is a longer-term
effort, because it requires a lot of things that we're working on but are not
complete yet, before we can actually really do async payments.  We've been
starting to prototype that with the LDK team.  This is moving slowly, and I hope
it gets done at some point, but this is going to take time.  And on trampoline,
I think that, again, people expressed interest in implementing trampoline, but
I'm still waiting to see if this actually catches on, because many people are
interested, but it still doesn't seem to meet the bar for implementation in the
short term.

**Mike Schmidt**: Greg, for folks that may not be completely sure of the
timelines for LN-Symmetry, they may say, "Hey, you had Greg on talking about
Lightning, but LN-Symmetry wasn't even in the LN Summit notes".  Maybe you can
kind of put it to rest why that wasn't a main discussion item during the meeting
and why?

**Greg Sanders**: Okay, so in case people are wondering, yeah, so the
LN-Symmetry implementation is what I consider complete from a de-risking
perspective.  So, I didn't do things like unilateral closes and gossip, but as
you heard from the Summit notes, that stuff is actively being overhauled
anyways.  So, from that perspective, it's kind of done.  The remaining piece
would be things like the mempool policy work, which we're continuing to work on
as a necessary precondition.  But as well, I mean, the biggest one is
requirements for something like anyprevout, right?  And that's consensus change,
and people working on spec details aren't going to spend a lot of time lobbying
for consensus changes, because they're understandable.  So, I don't know if
there's much to talk about there.

There's also a bit of talk about, I guess, the lack of penalty.  I have my own
opinions about penalties and channels, and everyone has their own opinion,
right?  But the current LN as of today is 100% penalty-based, and it doesn't
seem like it's going to change much.  Like, people might not want to just
replace the current types of channels with a penalty-list channel.  So, this
could sound like, I guess from a priority perspective, I don't think it's quite
there.

**Mike Schmidt**: Any final words as we wrap up this section of the newsletter?
All right.

**Greg Sanders**: Thank you for your time.

**Mike Schmidt**: Yeah, thanks for jumping on, Greg and t-bast.  You're both
welcome to stay on.  We have Stack Exchange questions we're going to go through.
Otherwise, if you have things you've got to do, got to drop, understandable.
It's time for the monthly segment about the Stack Exchange, Murch's favorite Q&A
section on the internet about Bitcoin.  We have five questions that we covered
this week.

_How can I manually (on paper) calculate a Bitcoin public key from a private key?_

The first one, at first I thought this was kind of a funny question, but I
actually got a lot of interest on the Stack Exchange, which is, "How can I
manually, on paper, calculate a Bitcoin public key from a private key?"  And
Andrew Poelstra answered this, providing some background, some other
hand-calculation verification techniques that he's used previously, including
Codex32, and he estimates that it would take, even using some tricks and some
helper lookup tables, that it would take about 1,500 hours to do that, 36 weeks
of a full-time job, even using some of those tricks that he outlined in his
answer.

It was pretty wild to me how much it seemed like Poelstra had thought about
this, and it almost seemed like he was waiting for someone to ask this question
on the Stack Exchange to be able to give such a comprehensive answer!  Murch,
I'm sure you dug through that and you have thoughts on his answer and the
question generally?

**Mark Erhardt**: Yeah, I was also surprised on how much Andrew had to write
about that, but yeah, it turns out that humans are not computers, and while
computers are good at some things, they are not great at other things, and while
humans are good at some things, they're not very good at calculating hashes and
doing elliptic curve math on paper.  And frankly, I don't think that it is
whatsoever reasonable for anyone to do multiple hours of calculation just to do
transactions, let alone multiple months and, yeah, so I don't know.  I thought
this was sort of a comprehensive treatise of the topic, so glad that we have it
on our site.

**Mike Schmidt**: Okay, Murch, so 1,500 hours is too much for you, but Poelstra
mentioned in his answer, "If we could reduce this to one month, 160 hours of
work, I think this would be a reasonable thing to do for a certain kind of
super-paranoid Bitcoin user who only transacted every several years".  What do
you think, Murch?  It's down to 160; are you in?

**Mark Erhardt**: I would say that working with the people at BitGo for a few
years has made me way more paranoid, and I don't think that anytime soon I'm
going to be nearly as paranoid to want to do this.

_Why are there 17 native segwit versions?_

**Mike Schmidt**: Next question from the Stack Exchange is, "Why are there 17
native segwit versions?"  Folks may be familiar that the original activation of
segwit included introducing native segwit v0 outputs, and that taproot
activation was segwit v1, and that potential future soft forks could use other
segwit versions as points of extensibility.  But 17 versions?  Why do we have 17
potential segwit versions?  And, Murch, you asked and answered this question,
and in your question you noted that usually decisions, like determining the
ranges of values for something, involves binary powers of 2, which would point
to something like 16 segwit versions or 32 segwit versions, but we have 17
segwit versions.  Maybe you can explain why.

**Mark Erhardt**: Yeah, I think I came across this question again when I was
reviewing Mastering Bitcoin 3rd Edition.  Hi, Dave!  And so, I've actually been
digging into a bunch of minutiae on how Bitcoin works under the hood lately,
because I'm doing the technical review of the updated version of Mastering
Bitcoin.  And so, yeah, this, it just stuck out as odd to me how this is not a
power of 2, as almost all numbers that appear in the context of any computer
protocols are.  So, it turns out that we have constants for some numbers in
Bitcoin script, and there are single-byte opcodes that can express these
constants.

So, obviously we have one for OP_FALSE or the empty array or OP_0, which is all
the same thing.  And then we have one for OP_TRUE and OP_1.  Yeah, anyway, those
are just single-byte expressions.  And it turns out that we have the first 16
numbers defined as single-byte constant opcodes, and with OP_0 in addition, we
have 17 opcodes that represent a number directly.  And it seemed to me that that
was the most likely explanation, because in an output script, when we define a
native segwit output, what we do is we put a version byte, and then we put a
witness program, which, of course, there are three defined of.  There's the
P2WPKH witness program, which is a v0 witness program of 20 bytes.  There's the
P2WSH program, which is preceded by a v0 and then a 32-byte witness program.
And now with taproot, we also have a v1 witness program, which is also 32 bytes.

So, yeah, it's just because we can express the number 0 through 16 with a single
byte, and that's why we have 17 native segwit versions defined in, I think it's
BIP141, yeah.

_Does `0 OP_CSV` force the spending transaction to signal BIP125 replaceability?_

**Mike Schmidt**: Next question from the Stack Exchange is, "Does 0 OP_CSV force
the spending transaction to signal BIP125 replaceability?"  And I think it's
important to understand here that since both the CSV timelock opcode and BIP125
RBF use the nSequence field for their enforcement, and also due to the potential
range values for CSV overlapping with RBF's range of potential values, it can
end up forcing a spending transaction to signal RBF in order to spend a CSV
locked output.  Murch, I'm sure you have something to add here, but is that the
gist of it?

**Mark Erhardt**: Yeah, pretty much.  So using OP_CLTV or OP_CSV makes you set
an nSequence value that essentially forces the transaction to be considered
replaceable.  So, by requiring a 0 CSV, you do force replaceability even though
there is no wait time, because a wait time of 0 means that it can be included in
the same block.  So, having an output that includes the 0 CSV forces
replaceability.

Now, there's an interesting quirk, especially with 0 CSV, which is since CLTV
and CSV were forked in by replacing an opcode that has a no operation or OP_NOP,
the OP_NOPS are not allowed to change the stack because previously no operation
meant that it does nothing.  So, the stack has to be the same before and after,
or it wouldn't be a soft fork.  If the new opcode, for example, removed an
element of the stack, nodes that followed the new rules per the soft fork, well,
in that case hard fork, would have a different stack after executing the opcode
than old nodes, because old nodes would not interact with the stack at all.  So,
other than most opcodes that read an element from the stack, these two leave the
element that they read on the stack.

Now, with a 0 CSV, the 0 is left on the stack and 0 is a false-even value.  So
if that were the last element on the stack, it would actually indicate that the
transaction validation has failed.  So, with a 0 CSV, you actually also have to
add an OP_DROP to remove the stack element in order to not fail the transaction
validation.  Whereas for most CSVs, it would leave an element on the stack that
is greater than 0, and that is a truthy outcome and would allow the transaction
to pass validation.

**Mike Schmidt**: You mentioned the OP_DROP.  I think in the Twitter thread that
you mentioned, there was Ruben Somsen talking about some of the work that he was
doing, and I think he was adding a 1 instead of the OP_DROP; is that an
alternate way to achieve an appropriate stack?

**Mark Erhardt**: Yeah, he was doing an OP_1ADD, which turns it into a truthy
value.  You could also do, I think, OP_NOT, which would turn a 0 into a 1.  But
generally, you would want to -- well, you have to handle that 0 element on the
stack one way or another.  This week, I actually went through Appendix B in
Mastering Bitcoin, which is a list of all the opcodes, and read all the
descriptions and looked at which ones I found, or refamiliarized myself with the
entire script language.  So I'm sure you could come up with about a dozen
different ways of how to handle that 0 on the stack, but you do have to handle
it.

**Mike Schmidt**: I'm excited for the new edition of Mastering Bitcoin for a
variety of reasons, but especially due to the thoroughness that appears to be
going into the authorship and review.  I see tweets about it, I see reviewers
commenting on it, I see Stack Exchange questions about it.  So, there's been a
lot of eyeballs on it, so looking forward to that coming out.

**Mark Erhardt**: Honestly, sometimes when I finish a chapter, I'm baffled on
why it took me so long.  But then I look at the Stack Exchange questions, the
discussions I have with my colleagues, the back and forth that I have in emails
with Dave, and so forth.  I think it just takes time to -- I'm actually reading
everything, I'm trying to go through every example.  And yeah, I hope it'll all
be for the better and we'll have a great book that we can thoroughly recommend
by the end of the year.  And shoutout to Dave again, he's putting a ton of
effort into this.

_How do route hints affect pathfinding?_

**Mike Schmidt**: Next question from the Stack Exchange is, "How do route hints
affect pathfinding?"  I've always thought of route hints as being used when, if
I'm a recipient of a payment and I'm using unannounced or private channels, that
I would provide some additional information to a sender so they know how to
route to me.  But there's also this technique that Christian Decker mentioned in
his answer to this question on the Stack Exchange, which is route boost, which
means that I can also provide some sort of hints about channels that I'm aware
of that have adequate capacity for the payment that I wish to receive.  T-bast,
I'm not sure if you're still listening in, but is that right?  Do you have more
to add here on route boost?

**Bastien Teinturier**: Yeah, I think I discussed that recently with Christian
and I don't remember exactly why, but he was annoyed because this actually
didn't work.  Yeah, this actually didn't work because some senders did not
prioritize the channels that were in the route hint.  For example, at least in
Eclair and in Core Lightning (CLN), whenever you read an invoice and see some
route hints in there between a pair of nodes, you use those channels in priority
regardless of whether you have other channels to reach that destination between
the -- to reach that -- well, no, I don't remember.  I think that LND had a
different behavior when the way they used the route hints was different, and
would actually make route boost not work.  So I think we've just...

Yeah, this has never been really relied upon.  And in a way, blinded path makes
that easier, because with blinded path, blinded path is a way to doing some
route boost without actually telling people about the channels.  You would just
include them in your blinded path, people don't even have to know what channel
this is, but you kind of force them to go to a direction where you know that
there is liquidity.  So yeah, I do think route boost is more of an interesting
historical thing that was tried, but it didn't really yield any meaningful
result in practice, I believe.

**Mark Erhardt**: I think that there might also be a couple of issues here with
if you, for example, have one peer that you closely work with and you want to
funnel more fees to, you could always route boost them and then make sure that
they collect the fees rather than other peers you have, which may be sort of a
downside of prioritizing boosted peers.  But on the other hand, it could also be
used, for example, to prioritize channels where you need to balance your
capacities.  So, you could sort of ask that people route through specific
channels because that one is especially lopsided and it would move the liquidity
more in the direction that would balance out the channel, which would be a good
thing.  So, I guess it would be nice if it worked, but I see an attack vector
there too.

**Bastien Teinturier**: Yeah, and in a way, blinded path will just allow you to
do that again because whenever you choose your blinded path, you can choose to
make them go through your friend who wants to collect some fees through exactly
the channels where you need them, when you know you have a lot of inbound
liquidity and want to balance the channel.  And if you have information about
your peers, channels, liquidity as well, because you're sharing that somehow,
then that will also impact how you build your blinded path.  So blinded path
will be some kind of superior route boost where people can decide on whether
they want to use it that way or not.  But it's really the recipient's decision
to whether they want to use it or not.

_What does it mean that the security of 256-bit ECDSA, and therefore Bitcoin keys, is 128 bits?_

**Mike Schmidt**: Last question from the Stack Exchange is, "What does it mean
that the security of 256-bit ECDSA, and therefore Bitcoin keys, is 128 bits?"
So, Murch, Bitcoin uses 256-bit ECDSA but 256-bit ECDSA only provides 128-bit
security.  If I'm understanding the reason behind that, it's that the reason
that sipa points out here, that there are known algorithms that are more
effective than just brute-forcing 256-bit keys, so that it's technically then
128-bit security; am I getting that right?

**Mark Erhardt**: I believe you are getting that right.  I think that it might
be related to how likely it is to be able to create a preimage attack.  Because,
if you try to replicate a hash, an exact hash, without knowing the input, I
think you do have 256-bit security.  But if you're trying to replicate a hash by
knowing when you know the input message before the hash, the pre-image, then
it's only a 128-bit security because you sort of have to find two things that
produce the same digest rather than needing to replicate one digest.  I'm not
doing a great job of explaining this right now, but yes, oftentimes there is a
quadratic reduction of the security due to algorithms and what sort of attack
model or threat scenario you're applying, and I think this happens to be the
case here.

**Mike Schmidt**: The person asking this question was also asking about seed
security and was maybe mixing up this 256-bit ECDSA versus 128 versus like the
security of a seed, which sometimes can be 512.  So, there's some details in the
answer on the Stack Exchange there.  I don't know if you have anything to add to
that, Murch.

**Mark Erhardt**: I think that if you're just randomly trying to hit a specific
thing, that it usually is just the square-root complexity.  So yeah, this is not
my wheelhouse where I'm an expert.  I usually go to sipa to ask him about that
sort of stuff!

**Mike Schmidt**: Next section from the newsletter is Releases and release
candidates; we have two.

_HWI 2.3.0_

First one, HWI 2.3.0, which has a few items from the release notes that I think
are worth talking about.  The first one is Jade DIY device support.  So, there
actually are a number of different hardware devices that can run the Jade
firmware.  So, you can run Jade on non-Blockstream hardware, and now with this
HWI 2.3.0 release, you can also now use HWI with those DIY devices.  The second
item from the release notes was the ability to, within the GUI, import and
export PSBTs to and from a file.  And the last notable item from the release
notes for HWI was Apple Silicon HWI binary for MacOS 12.0+.  So, there were
certain models introduced to Apple Mac computers, I think, starting in late
2020, when Apple began to transition from Intel processors to this Apple Silicon
chips.  And now, there's binaries built for HWI for that particular setup.
Murch, did you want to say something?

**Mark Erhardt**: I think that there is some follow-up work for this release
that is coming out soon, but I don't know exact details.

_LDK 0.0.116_

**Mike Schmidt**: The next release we covered is LDK 0.0.116, which adds support
for anchor outputs and multipath payments with keysend.  And we've covered a lot
of these PRs as they were merged to the LDK repository over the last few weeks.
I think Newsletter #257 and Newsletter #256 cover some of these PRs in more
detail.  And you could also look at our podcast for Newsletter #257 and #256 for
some of our discussion about these individual PRs.  Murch, do you have comments
on the release more generally?

**Mark Erhardt**: I'm sorry, I do not.

_Bitcoin Core GUI #740_

**Mike Schmidt**: We have one notable change to the Bitcoin Core GUI repository,
#740.  Murch, I think you dug into this one a bit, so maybe I'll let you take
it.

**Mark Erhardt**: Yeah, so for this one, we have a small update for how PSBTs
are shown in the GUI.  So far, the GUI would not indicate if you were using --
oh, sorry, could you hear me?  I think I accidentally covered my microphone.

**Mike Schmidt**: No, you didn't.

**Mark Erhardt**: Okay.  So, so far when we were processing a PSBT in the GUI,
we were not indicating which addresses were yours.  This makes it especially
difficult if you're creating a change output that belongs to you, because the
change output, of course, goes to a freshly generated address, and if you're
just seeing money go to a freshly generated address, you do not know whether
that's your address or whether somebody may have tampered with your PSBT and is
sending the remainder of your transaction to their own address.  So, what this
update does is it indicates which addresses belong to your own wallet, and that
makes it especially easier to recognize a change output as such, and hopefully
makes PSBTs more accessible in the GUI.

**Mike Schmidt**: That wraps up the Newsletter #261.  Thanks to our special
guests, Greg and t-bast, and thanks always to my co-host, Murch.  I think this
was a great recap.  It was really valuable, Greg and t-bast, having you guys on
to talk about Lightning stuff with us, we really appreciate it.

**Mark Erhardt**: Yeah, thanks to you two, Mike, for always being so
well-prepared and having all this newsletter here.

**Mike Schmidt**: Cheers, see you next week.

**Bastien Teinturier**: Thanks a lot for having us, bye.

{% include references.md %}
