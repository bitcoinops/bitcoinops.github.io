---
title: 'Bitcoin Optech Newsletter #312 Recap Podcast'
permalink: /en/podcast/2024/07/23/
reference: /en/newsletters/2024/07/19/
name: 2024-07-23-recap
slug: 2024-07-23-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Jonas Nick and Pieter Wuille to discuss [Newsletter #312]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-6-23/383712664-44100-2-591cec59e5dcf.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #312 Recap on
Twitter Spaces.  Today we're going to talk about distributed key generation, a
protocol for FROST, an introduction to cluster linearization; we have nine
interesting technical updates to ecosystem softwares; and then we have our usual
segment on notable code updates with eight different PRs to eight different
repositories.  I'm Mike Schmidt, contributor at Optech and Executive Director at
Brink, where we fund Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I work at Chaincode Labs on Bitcoin topics.

**Mike Schmidt**: Jonas, you're on mute.

**Jonas Nick**: Oh, should I introduce myself?

**Mike Schmidt**: Yeah, say hi, for folks who might not know you.

**Jonas Nick**: Yeah.  Hello, everyone, I work in the Blockstream Research
Group, working on various cryptographic topics, signatures, zero-knowledge
proofs.  And I recently published a BIP draft for a distributed key generation
protocol for Rust to the Bitcoin mailing list.

**Mike Schmidt**: Pieter?

**Pieter Wuille**: Hi, I'm Pieter, I do research and development on Bitcoin at
Chaincode Labs.  And I recently published an introduction to cluster
linearization writeup on Delving Bitcoin, which I understand you want to talk
about.

_Distributed key generation protocol for FROST_

**Mike Schmidt**: We do.  Thank you both for joining us.  For those following
along, this is Newsletter #312.  We'll be taking the news items and then notable
code changes in order here.  Our first news item is distributed key generation
protocol for Frost.  Jonas, Tim Ruffing posted to the Bitcoin-Dev mailing list a
draft BIP that you both worked on regarding generating keys for use in FROST,
the threshold signature scheme.  Maybe first a quick summary of FROST compared
to something like MuSig2, and then we can get into the challenges and
considerations around FROST key generation.

**Jonas Nick**: All right, okay.  So, the thing we're talking about is FROST,
and FROST is a threshold signature scheme.  And what this allows you to do is to
create a signature for a message that is valid for a certain public key.  And
the interesting thing is that you start with a setup where n people are part of
a group, and then you set some parameter that is usually called t, the
threshold, and then t out of that n of that whole group, they can produce a
signature over a message.  So, not everyone needs to participate, just t of
these n total signers in this group, they need to participate to create a
signature.  And so, the first step they do is they sort of set up a shared
public key.  That is the first part.  Second part, they create a signature.

The simplest threshold signature scheme, call it sometimes naïve or trivial, is
the classic OP_CHECKMULTISIG, where okay, they are the group, they don't come up
with a shared public key, just that everyone contributes their public key, and
then t signers contribute a signature, and then you have the script that checks,
"Okay, now t out of these n signers have contributed a signature", and if so,
the script succeeds.  And the interesting thing about proper multisignatures and
threshold signatures is that this group comes up with a single public key
instead of each participant having their own public key.  And they create a
signature together so they don't have to each provide a signature, but rather
they provide a single schnorr signature, a single signature that is valid under
the BIP340 schnorr verification algorithm.  And this is then therefore much more
efficient when you do that on the Bitcoin blockchain, compared to something like
OP_CHECKMULTISIG, and it looks as if a single signer has produced a public key
and signature is not really distinguishable.  It's not distinguishable at all if
you don't have additional information, if you just observe the chain and then
you don't know, well, was this a single participant, is this a MuSig
multisignature, or is this a FROST special signature?

**Mike Schmidt**: Excellent, thanks for that summary.  Maybe you can get into
why key generation is potentially a challenge and what considerations need to go
into that, as folks may not be aware of why that can be challenging.

**Jonas Nick**: Yes, so roughly speaking, you could distinguish two parts in
this FROST signing scheme, and the first part is the key generation part, second
part is the signing part.  The signing part is quite similar to MuSig2, the key
generation part is different.  So, key generation can work in essentially two
different ways.  Either you have what is often called a trusted dealer, who just
generates the public key and then sends shares to the participants of the FROST
setup such that they can sign in this t-of-n manner.  The problem with this is,
of course, that this introduces a single point of failure, because if that
trusted dealer is malicious or compromised, then they can just create a
signature on their own without having to consult anyone from the group.  So,
this is generally something that probably we don't want to see in practice very
much.

The other way to do this is what is called distributed key generation (DKG),
where every participant of the setup contributes a key, contributes some
randomness such there is no such single point of failure.  And for example,
there is this specification of FROST from the IETF.  There is an RFC
96-something, and they consider key generation out of scope, they roughly
explain how you could do this with a trusted dealer, but they don't explain how
to run a DKG algorithm.  And this tells you that this DKG is a little bit more
challenging than it may sound.  So, okay, it's more challenging, but still it's
described in the FROST paper, for example.  So, if you look in any of the
papers, these papers describe a DKG protocol.

What they require, what they don't explain you to do, but what they tell you to
use is a secure channel.  So, you need secure channels between the participants,
which means that the messages sent through it, they are encrypted and
authenticated.  Okay, engineers probably know how to do that, use some library
and then hopefully that does the work for you.  And the second thing they
require is a so-called broadcast channel.  And a broadcast channel is a
cryptographic primitive, or distributed systems primitive, which is more
complicated than -- like one way, you might read broadcast channel and then you
think, "Okay, I have channels to everyone else, to all of the participants, all
participants have channels to every other participant, and they just send the
message to everyone".  But that is not a broadcast channel, or at least it
wouldn't be a secure one.

There's two properties that we want from a broadcast channel.  So, another
challenge is that this broadcast channel sometimes has subtly different
definitions that sometimes matter more, sometimes matter less for security.  But
one property that we want, that is kind of a usual property you have in a
broadcast channel, is what we call integrity, which means that all honest
participants, if they successfully receive a message in the broadcast channel,
then they all receive the same message.  And what this prevents is that a
malicious participant in the key generation protocol would send a share to
someone that is inconsistent with a share that they sent to someone else.  So,
they don't really match, match not meaning that they're equal, but they're not
consistent, which would mean that in the end, the signers, t-of-n, won't be able
to sign, and this will be a problem.  So, if you have integrity in a broadcast
channel, you can set the DKG up such that the honest participants would notice,
"Okay, there is someone who has sent us a different message, potentially
inconsistent share, so at least we consider the broadcast to not have worked".
So, that is the one property that we want, integrity.

The second property, that is a bit more specific to our Bitcoin use case, we
call conditional agreement.  And what this means is that if some honest
participant considers the DKG successful, then they will be able to eventually
convince everyone else, or all other honest participants, that it was
successful.  Why do we need that?  Well, in some cases, it could happen that one
of the participants considers the DKG successful, and then they have this public
key, they compute an address, they send coins to it.  Now, the problem would be
that some other participants, for whatever reason, considers the protocol to
have failed, for example, and they have deleted all the secrets, all the secret
shares that they have received, or whatever.  And that would be a problem,
because now those coins could be burned, could be unrecoverable.  So, we need
this additional property that we call agreement.

So now, what this BIP does, it specifies the whole protocol without referring to
some external things, like secure channels or broadcast channels.  So
everything, you can just implement the BIP, the specification is written in
Python, you can copy that to your favorite language using secure cryptography
libraries, of course.  And then, you don't need to worry about definitions of
broadcast channels at all.  And we believe that this was a significant gap,
because previously, before the specification, there wasn't really anything you
could just give to engineers and ask them to implement it, because there were
all these different pitfalls that you had, for example, with a broadcast channel
and this agreement property.

**Mark Erhardt**: Okay, let me jump in here real quick.  It sounds to me like
coming from MuSig, which we are more familiar with, the signing appears to be
similarly complicated, but what gets really much more complicated is the key
generation.  So, would it be fair to say that the biggest lift would be in
creating output scripts for this, well, for P2TR addresses, for example, that
make use of ChillDKG?

**Jonas Nick**: What do you mean by output scripts?

**Mark Erhardt**: Well, so if we split up the use of addresses, there's of
course being able to receive funds, and to that end you have to agree with your
counterparties on an output script that you distribute in your invoices.  It
sounds like at least once, you need to make a fairly complicated and interactive
protocol to set up the quorum of receivers, or to make them participate in
creating an address.  I assume then after that, you would be able to derive
other addresses from this initial seed, but so it seems to me that that is the
most complicated part of adopting.

**Jonas Nick**: Yes.

**Mark Erhardt**: Okay.

**Mark Erhardt**: Yeah, so this DKG definitely seems to be, at least to us,
there's no FROST-signing BIP right now, but it's in the work.  But it should be
very similar to MuSig.  The DKG is a bit different also in other ways; we could
get to it later, or I could talk to it right now.  So, for example, one of the
problems traditionally in Rust, if you want to use this in practice, is that you
receive shares from other parties, and from that you compute your secret that
you're going to use in signing.  That means that difference to normal single
sign or schnorr signatures, or whatever, you don't derive the secrets from a
seed.  You receive them, then you need to store them if you want to sign later.
So, that is a challenge, so something that is different to normal signing, also
different to MuSig, for example, because you have this interactive protocol
where you need to remember stuff.

**Pieter Wuille**: If I can jump in for a second, I think you, so you touched on
the difficulty of, yeah, there's this requirement that DKGs have, like, a secure
broadcast channel, but I don't think you really went into how burdensome some of
the requirement is.  My understanding is, basically it needs a consensus
algorithm between the participants to actually implement that in practice.
Like, even ignoring existence of libraries or whatever, this is just technically
a complicated thing, right?

**Jonas Nick**: That is what we thought a while ago, but luckily that is not the
case, at least if you buy some of the downsides that we have.

**Pieter Wuille**: Right.  So, my understanding is that what ChillDKG does is
drop the requirement for a full broadcast channel, and instead, don't require
that everyone ends up with the same thing, but still just change it to a
successful participant can convince others that they were in fact successful and
recover their key.

**Jonas Nick**: Exactly.  This is what we call conditional agreement, which
works with any number of dishonest participants, whereas if you wanted to have
full agreement, which means that the signers, not only -- so, conditional
agreement is if one participant believes the protocol to have run successfully,
they can convince the others it was successful.

**Pieter Wuille**: And not only that, it can help them recover the keys they
need to sign.

**Jonas Nick**: Yes.

**Pieter Wuille**: That's pretty great.

**Jonas Nick**: And full agreement would mean that not only -- so, if a
participant believes the protocol has failed, then no other honest participant
will succeed, and we don't have that property.  So, we also don't have, for
example, robustness, which is probably something that would require a full
consensus algorithm, or at least something similar to that.

Okay, so I wanted to talk about backups.  So, one of the features of the
ChillDKG is that you don't have to store a share that you receive from the
others for each DKG session.  Instead, you have a single seed and you need to
back up what we call recovery data.  And this recovery data is public, for the
purposes of security, which means that it contains all the data you need and
your shares encrypted to you.  And it's the same for all participants, it's the
same recovery data for all participants, which means that you backup the
recovery data; and if you were to lose it, you could ask another honest signer
to give you the recovery data, then you can restore the whole thing.  You could
backup the recovery data on some public cloud storage provider, whatever.  This
has privacy implications, but at least no one will be able to impersonate you or
store your coins.  So, we believe that this is a significant improvement over
the previous way of having to store secret data for every DKG that you are
involved in.  Instead, you have one seed that works for multiple DKG sessions
with multiple setups, and for every setup, you have this recovery data.

**Pieter Wuille**: How big is the recovery data?

**Jonas Nick**: Small.  It's linear in the size of the signers at least.  This
was one of the things that took a while to figure out how to do.  But it's not
megabytes.  Of course, it depends on the number of signers, but I don't have it
off the top of my head.

**Pieter Wuille**: No, but it being linear, that sounds great.

**Jonas Nick**: Yeah.  So, another feature I could talk about is maybe the way
how we designed the thing.  That's more for people who want to implement it.
So, essentially, ChillDKG, how we call the DKG, is a wrapper of a wrapper of a
DKG.  And that internal DKG is called a Simple PedPoP: Simple Pedersen Proofs of
Possession DKG.  And that one was proven secure in a paper by Tim Ruffing, my
co-author for ChillDKG, and his collaborators, proven to be secure when used
with FROST.  And this Simple PedPoP DKG is a protocol that requires secure
channels to be provided somehow and a broadcast channel.  So, we wrap the Simple
PedPoP in a protocol that we call Enc PedPoP, or Encrypted PedPoP, and that
protocol adds the secure channels, and then we wrap that whole thing in
ChillDKG.  And that adds the agreements, the conditional agreement and broadcast
part.  And we hope that this way of describing the protocol in such an abstract
manner helps to understand it and to analyze it and also to implement it.

**Mark Erhardt**: So, for the engineers that will end up trying to implement
that into their wallet system, I assume that there would be a library
implementation that wraps all of these calls to functions, and you would just be
able to call something like, "Create broadcast channel with participants", or
how would that work on an engineer level?

**Jonas Nick**: So, maybe one important thing I should say, so the whole design
is centered around an untrusted coordinator because we think that this is what
people use in practice.  So generally, you send a message to the coordinator and
then the coordinator does something, sends messages back to the participants.
So, what you would call, according to our reference implementation, is to call a
function that we call participant_step1, and that returns a message that you
send to the coordinator; you receive a message from the coordinator; you run
participant_step2; send a message to the coordinator; you receive a message;
then you finalize it.  So, it's two rounds with the coordinator, back and forth,
back and forth.

**Mark Erhardt**: Okay, that's even more abstracted away than I thought.  So,
really it's just a matter of calling certain steps and then trusting the library
to give you back the right things; and then on your end, of course, to implement
the correct hooks for signing, when signing comes out eventually.

**Jonas Nick**: Yes.  So, we have this one setup assumption, which is that the
participants, they have distributed their public keys -- they have some sort of
what we call host public keys.  So, these are long-term public keys that are
used to identify the participants, used for encryption, for example.  And we
assume that they have the correct public keys of all the other participants,
which is the same assumption we have in OP_CHECKMULTISIG setups or MuSig as
well.  So, you need to be sure that you have the right long-term public keys of
the other participants.  And of course, other assumption is that you have
created your public key with proper cryptographic randomness, and then you will
use that randomness in the DKG.  So, that will be input to the functions, to the
step functions I just mentioned.  But I think that's about it.  I mean, other
input is the threshold, but not much more.

**Mark Erhardt**: So, comparing to previous optimistic outlooks that some
network participants would have FROST wallets last year, it sounds like there's
a BIP for part of the problem coming out soonish, then there would be a BIP for
the signing eventually, and both of these would need to make their way into
libraries first.  So, it sounds to me like it's moving forward but it's a few
years away from being available to be used in wallets.  Would you agree with
that?

**Jonas Nick**: I don't know.  Since I'm not working on a wallet, this is hard
to tell.  But the current state of this BIP is that we're just looking for
feedback.  So, we've received some very valuable feedback already, we're looking
for more feedback.  We have this reference implementation that works, we believe
it's secure.  We've both read it, so both co-authors, but I don't think anyone
else, or analyzed it.  And a bigger part that still needs to be done is to add
the test vectors, for example, to make sure that when libraries implement this,
they can test it in an exhaustive way that would uncover all these edge cases
that could happen in these multi-step interactive protocols.

We are considering to add another feature that we call "identifiable aborts",
because right now if the protocol fails for some reason, you cannot really tell
who is responsible for it.  You could argue that problem away and saying, okay,
if at the point of creating a key something fails, then maybe you just want to
fail and investigate.  Maybe the group you're doing it with is the wrong group,
something went wrong.  But still, you probably want to know who is responsible
for it.  And the kind of property we can get is that we believe we could tell
the user either participant number i was responsible for it failing, or the
coordinator is malicious.  So, we call that property identifiable aborts.
That's not included right now.  We currently believe that we can edit.  So,
that's another thing we want to add.  So, those are the two big things, test
vectors, identifiable aborts, and yeah, looking for feedback; probably also,
we'll need to incorporate feedback somehow.  Will it take years?  I don't know,
I hope not.

**Mark Erhardt**: Thank you for that overview.  Mike, back to you.

**Mike Schmidt**: Sure.  Yeah, it sounds like there's a few potential takeaways
for the audience.  For those who are technical enough to review the proposed BIP
and participate in the discussion, there's the mailing list post as well as the
draft BIP to review.  And for folks who maybe like to tinker, there is the
reference implementation in Python as well.  Jonas, anything else that you would
add for the audience to help this project along?

**Jonas Nick**: Yeah, so it would be cool if you want to play around with this,
maybe implement it, read the BIP.  Really, any kind of feedback is welcome, and
you can open issues on our GitHub project or contact us directly.  That would be
great, thanks.

_Introduction to cluster linearization_

**Mike Schmidt**: Thanks for joining us, Jonas.  You're welcome to stay on, or
if you have other things to do, you're free to drop.  Next news item this week
is titled, "Introduction to cluster linearization".  We had Pieter on in Podcast
#280 for a more broad discussion of cluster mempool, and in that discussion, we
touched on cluster linearization.  But this week, we highlighted a specific deep
dive, Pieter, that you posted to Delving on the topic.  Maybe to frame the
discussion a bit, what's your summary of cluster mempool for listeners, and then
we can explain how cluster linearization forms the basis for a cluster mempool?

**Pieter Wuille**: Yeah, so I describe cluster linearization as a
re-architecturing of how Bitcoin Core, or other code, reasons about unconfirmed
transactions in a way to enable it to be able to actually compute and reason
about incentive compatibility.  So, if you look back at the number of pieces of
code that Bitcoin Core does relating to unconfirmed transactions in its
mempools, like block-building is an obvious one if you're a miner, but obviously
that doesn't affect many people; but also, relay of new transactions and RBF for
replacements or evictions when the mempool grows too big, or fee estimation, or
all these things.  Looking back now after our whole thinking around cluster
mempool, I think we realized they're all half-baked attempts at trying to reason
about incentive compatibility.  Like, is this transaction making things better
or not; or what's the best we can do?  And cluster mempool is about replacing
all of that with a single framework that's well abstracted and we can analyze
separately just about the question, how good is this transaction compared to
this; or how good is this set of transactions compared to this one?

In order to do so, the big computationally hard part is we really need to have a
full ordering on transactions in the mempool, like what order would we mine them
in?  And in cluster mempool, we pre-compute that to an extent, which makes this
computationally feasible.  Yeah, Murch?

**Mark Erhardt**: You said a few times, "Better or good" and, "Incentive
compatibility".  Could you maybe give us a sense of what makes transactions
better and what sort of criteria we're using at this point?

**Pieter Wuille**: Yeah, of course.  So, better means more fees in abstract, but
concretely that is not as simple to reason about.  Sure, a single transaction
compared to a single other transaction, if the second one has the same size and
pays more fee, it's obviously better.  But once you introduce dependencies
between transactions, this becomes a much harder question to answer, because I
assume most listeners will be familiar with CPFP, Child Pays For Parent, where
you have a dependent transaction that pays a higher fee than its parent.
Virtually, it bumps the fee of the parent, because we can think of these two
transactions now as a collection that jointly pay for the relay and mining of
both.  Because clearly, the child cannot be included without a parent.  And so
CPFP is the simple example, which is something that Bitcoin Core has attempted
to reason about since I think 2015 or so.  But it's really just one simple
example of ways in which dependencies matter.

Cluster linearization is, in a way, a very broad generalization of that concept,
where we just take a bunch of related transactions and basically run the mining
algorithm just on that small group of transactions, which gives us the order in
which we would want those transactions mined.  And it turns out that just
pre-computing that piece of information, like these related transactions, in
what order would they be mined with respect to each other, ignoring everything
else, is sufficient to answer most questions that we want to know.

**Mark Erhardt**: So, basically the problem that we're looking at is, previously
we looked at the mempool in the context of ancestor sets and they overlapped,
and it was very hard to distinguish in what order all of the transactions stood
to each other.

**Mark Erhardt**: And with cluster mempool, we group them into these sets, or
components in the graph of transactions that are related to each other.  Then we
decide what order they would go in, and remember that, and that gives us sort of
a general order for the entire mempool.

**Pieter Wuille**: Exactly.  So, quick summary.  The way the current algorithm
works is, or data structures work, in the Bitcoin Core mempool, is it has all
transactions sorted by their ancestor feerate and their descendant feerate.  And
the ancestor feerate is the sum of the fees of a transaction and all its
unconfirmed dependencies, divided by the size of all of those.  And descendant
feerate is the same thing, but with all unconfirmed descendants.  And in the
block-building code, we just pick transactions according to the highest ancestor
feerate first.  This is sufficient to deal with CPFP correctly.  But then, for
example, if the mempool fills up too large and we need to remove some things, we
would like to evict the thing that would be the last thing to be mined.  And so,
the approximation for that is we evict the thing with the lowest descendant
feerate.

But it turns out these are not exact opposites.  And this is the direct
motivation that made Suhas and I and others look into this cluster mempool
approach, because right now it is possible that the first thing you evict from a
mempool is in fact the first thing you would want to mine, and that is broken.
This made us realize we really need a total ordering on all the transactions in
the mempool, and it is infeasible with the current algorithm to just -- the
obvious solution would be, well, run the mining algorithm on the entire mempool,
don't stop at 1 megavbyte, just keep going until the end and see what's the last
thing you would include, and that's what you evict.  But this is way too slow.
And so, cluster mempool is about putting limits on how large the groups of
transactions are that can be affected by one another, and then pre-computing
enough to answer this question quickly.

**Mark Erhardt**: You mentioned that the ancestor set-based mempool was enough
to reason about CPFP, and also of course longer chains that had single members
at each generation.  One of the things that is exciting in cluster mempool is
that it also discovers multiple children that have a higher feerate than
parents.  How would that, for example, change how we build transactions?

**Pieter Wuille**: So, I'd say in a first step, the cluster mempool proposal is
just running a mining algorithm on groups of transactions.  We could keep the
existing mining algorithm for that, which isn't guaranteed to discover anything
better than single CPFP.  However, we realize that, oh, we need a limit on how
big these groups of transactions can be.  If we accept that that limit is there,
suddenly it becomes computationally feasible to run a much better mining
algorithm on these small groups of transactions at once.  And with that, I
believe in many, perhaps not all, but in many cases, it will in fact be pretty
easy to discover multiple CPFP too.

**Mark Erhardt**: Sorry, I guess I threw a bit of a curveball.  The point that I
wanted to get to is when, for example, you get a withdrawal from an exchange and
they use a batch payment transaction with, I don't know, 200 recipients, we've
often seen on the network that recipients of such withdrawals, they withdrew the
money in order to make a payment, or have other reasons to send it further along
immediately.  So, very often, batch payments will have multiple child
transactions that, in fact, are trying to reach some sort of priority processing
and get confirmed quickly.  Where ancestor set-based mempool would discover each
of these children's withdrawal transaction as an ancestor set and evaluate them
in isolated fashion, so that they would be competing to be first.  With cluster
mempool, because we only look at the cluster and we evaluate the order in which
all of the transactions in the cluster would be picked into a block, we would
discover that these transactions are, in fact, collaborating and form a bigger
package than just child and parent, that it has a total higher feerate.  So, I
guess I'm jumping ahead a little bit.

**Pieter Wuille**: Yeah, so thanks for that, for clarifying in what context
multiple children appear, because they do appear in practice.  The point I was
trying to make earlier is that we can't guarantee, even with cluster mempool,
that multiple children will be discovered.  But in practice, we probably will.
And that is something that ancestor sort generally won't.  This is due to the
chunking aspect.  But yeah, that's jumping ahead, I guess.

**Mark Erhardt**: Right.  So, okay, we now have decided that we're basically
running the mining algorithm on clusters.  The output of that is a linearization
and ordering of the transactions, telling us how they would be picked, in what
order they would be picked into blocks.  But surely if we see a parent with a
low feerate and then the next transaction has a higher feerate, even though they
are topologically ordered in that way, we wouldn't pick the parent alone.  So,
would you like to jump into how we proceed from having linearization?

**Pieter Wuille**: Yes, exactly.  So, the computationally hard part is just run
some mining algorithm on these clusters of transactions.  Let's skip that part,
assume we've done that.  What you do with that linearization, so this is just an
ordering of transactions, is you group transactions together whenever a higher
fee follows a lower fee.  Turns out there's a unique way of doing that and this
gives what we call the chunking of linearization.  It's really just chopping up
the linearization.  In the one extreme, it may end up with all individual
transactions being their own chunk, or it could be the entire cluster becomes a
single one, or anything in between.  And this is really the generalization of
CPFP, because whenever you have something higher feerate follow something lower
feerate, they'll be grouped together.  And now, if you do this, you'll see that
the chunk feerates, so those are the sum of the fees of the transactions in a
chunk divided by their size, are non-increasing.  Within a single linearization,
you have the highest one first, then lower, then lower, then lower, then lower.

This leads to an obvious, probably not what we'll do in practice, but it's an
easy thing to reason about mining algorithm or block template building, which is
just you pick the highest fee chunk across all clusters, put it in your block
and continue.  And because the chunks are already sorted in a fee-decreasing
way, this will respect topology.  You will never pick a later chunk from the
same cluster before a lower one.  Yes.

**Mark Erhardt**: Sorry, a nitty comment, but just to be clear, the chunks are
ordered by feerate, right?

**Pieter Wuille**: Yes.

**Mark Erhardt**: So, we pick the chunk with the highest feerate and any other
chunks have a lower or equal feerate in the mempool, and that provides us with
an order for chunks to pick them into the block template.

**Pieter Wuille**: And what this also means is that eviction is now just picking
the lowest chunk across all chunks of all clusters.  And this gives us the
property that eviction is in fact the exact opposite of mining.  And this is a
much more important property for individual nodes.  In fact, maybe this is
something I should go into, why we care about this stuff at all.  And really, I
think it is important that nodes on the network are able to make decisions about
which transactions being relayed or replaced, or whatever, are
incentive-compatible.  Because if the network ends up doing something very
different than miners, this creates an incentive for the ecosystem to just
submit transactions directly to miners, which is a hugely centralizing effect.

So, I think of cluster mempool really as one piece of technology to help align
the network with miners' actions.  And yeah, so that is why we care about this.
Examples of this are all these places where things break, like eviction can pick
the worst thing, or replacements make the mempool worse, like is possible today,
and cluster mempool will abstract all of that away.  We just go into reason
about actual scores of transactions and then we can directly compare them, and
everything else is implementation aspects or policy rules to make this question
computationally feasible.

**Mark Erhardt**: So, maybe let me add another sentence to mining
incentive-compatibility.  It sounds sort of like we're elevating the miners to
make decisions for what we want to keep on our nodes.  But really, we do have
guarantees for propagating blocks, and that is what forms the consensus of the
Bitcoin Network and causes us all to synchronize on a shared state across the
network.  The propagating of transactions and relaying unconfirmed transactions
is sort of a behavior that doesn't really provide us any benefit except that we
want to use it ourselves too.  And it is the best way for us to be participating
in the network and being able to anticipate what the miners might be doing so
that blocks propagate quickly, that we can make proper estimates on feerates,
that we ourselves can reason about what we might need to do with our
transactions in order for them to achieve confirmation within the timeframe that
we're aiming for them to get confirmed.

So, we sort of not completely selflessly participate in broadcasting unreliable
and potentially useless information across the network in order to have that
information ourselves in order to inform ourselves.  So, the miners are not
elevated to the dictators of what we should be sending around, but rather we are
trying to figure out a best guess of what they might be picking in the end
because we want to have that information to inform our own actions.

**Pieter Wuille**: To inform our own actions and in order to make the network
align, right?  There are other cryptocurrencies out there where mining is
essentially outsourced to centralized services because it's infeasible for the
network to do this, just computationally, it's too hard a question.  And that's
really not a situation we want to end up in.  So, yeah, I guess should we talk
about -- the writeup that resulted in us discussing this here is something I
started writing from a perspective of, well, I wanted a document that explains,
why are all these problems hard, what are the issues you would encounter if you
try to reason through this, to someone who is technically competent and is
perhaps interested in reading the code, or at a higher level, understand what
the algorithms are, but hasn't heard about anything cluster mempool at all.

So, I wanted something that gave examples, like "Let's try this, see what goes
wrong", because I realized that many of the discussions my coworkers and I have
had about this have been on whiteboards or on calls, or whatever.  And this,
yeah, it's hard to convey information without examples, I think.  So, I wanted
something that is more easily accessible.

**Mike Schmidt**: Pieter, I see on Delving for this particular post, you have a
bunch of thumbs up reactions to the writeup.  Obviously, there's some other
writeups on Delving in addition to open PRs.  Have there been any concerns
raised to the approach at a high level?

**Pieter Wuille**: I haven't heard much.  I think the biggest question, there
are a number of open questions we have, such as cluster mempool involves a
policy change, namely we'll replace the ancestor and descendant count and size
limits with a cluster size limit, which is similar in some fashions, but not in
others.  Suhas been doing research to try to figure out, will that change affect
any real users?  Probably not.  But that is certainly something we'd want to
hear input on.  Another is, there are questions about computational costs of
this.  Exactly how big can we set things, or benchmarks, so we can reason about
those, but a lot of that is still to be fleshed out, how everything integrates.

**Mike Schmidt**: One question I had, I was curious if there was any sort of
existing non-Bitcoin literature on this sort of research.  Obviously, there's
Bitcoin-specific things here, but is there anything from academia that was
useful?

**Pieter Wuille**: Not really, or not that I know of, I should say.  It's not
the type of science that I'm most familiar with.  It's perfectly possible that
there is some domain somewhere out there that has discovered all these
properties already, but I think it wouldn't surprise me if there isn't, because
it's sort of a problem that only appears after setting a particular design.
Like, if you approach it from the question of, well, we have a set of
topologically-restricted transactions.  So, we have things with a fee and a
size, or a value and a weight, with dependencies between them, and now I want to
solve a knapsack problem that maximizes the fee given these constraints.  There
is research on that question.  But that isn't enough in our setting, because we
don't just need a good solution to that, we need one that is pre-computable
ahead of time.  Because our end goal isn't so much picking the maximum fee, it
is being able to reason about what changes will affect it in a positive way or
not.  I have the impression that it's only after restricting ourselves to this,
we want one single order ahead of time, that this whole host of questions
appears and with interesting properties around them.

**Mark Erhardt**: So, I wanted to maybe more explicitly ask the question again.
Once this rolls out, so would it require a soft fork?  Would it break things
between nodes that have it and nodes that don't have it?  How would it even be
apparent that people are using this?

**Pieter Wuille**: So, no, not a soft fork, not even a protocol change.  It is
just an internal change to how Bitcoin Core reasons about transactions in its
mempool.  It will probably be apparent to other nodes in certain cases where the
number of certain transaction relay decisions are made somewhat differently,
probably for the better.  And it is, we could conceive of protocol changes after
the fact, for example, ones that relay linearization information from one node
to another.  Or maybe more indirectly, say, package relay is something that's
been talked about for a while.  Package RBF I think has, before cluster mempool,
I don't think we had a good idea how to do that at all, how to reason about it.
Now, we sort of do.  So, having it may affect future developments that do
involve protocol changes, but yeah, definitely no consensus changes.  This is
all at the level of individual relay transactions.

**Mike Schmidt**: Maybe one way to wrap up here is to, and I think you alluded
to this, Pieter, in some of your explanation here, but part of the motivation
for this writeup was to provide some background material for folks who wanted to
review a couple of PRs around cluster mempool.  And so, if folks are curious
about this topic and wanting to take a look at those PRs, it's #30126 and
#30285.  So, hopefully we can get some members listening, or reading a
transcript here, to go through this writeup and actually contribute to some of
the review proposed in Bitcoin Core?

**Pieter Wuille**: Absolutely, but I do want to add that while that is why I
started writing it, I think it is more generally interesting than just people
who want to look at the PR.  So, if you're interested in what is all this
cluster mempool stuff about and why is it hard and maybe why is it interesting,
please have a look.  And by all means, feel free to, if things aren't clear in
it, comment on it or send a DM, or whatever.  I'm pretty interested in hearing
what parts are hard to understand or need elaboration.

**Mike Schmidt**: Pieter, thanks for joining us.  You're welcome to stay on, or
if you have other things to do, you're free to drop.

**Pieter Wuille**: Great.  Thanks for having me.

_ZEUS adds BOLT12 offers and BIP353 support_

**Mike Schmidt**: Next segment from the newsletter is our monthly section on
Changes to services and client software.  We have nine of them this month.  The
first one is ZEUS, adding BOLT12 offers and BIP353 support.  This is the ZEUS
v0.8.5 release and behind the scenes, they're actually using TwelveCash, which
is a new service that helps support offers, as well as BIP353.  BIP353 is the
specification of DNS payment instructions, and that essentially describes how
you can put a BIP21 URI with payment information into a DNS text record.  So,
ZEUS is leveraging TwelveCash to provide that to their users.  And you can check
out Newsletter #307 for more on BIP353.

_Phoenix adds BOLT12 offers and BIP353 support_

Similar update for our next piece of software here, Phoenix adding BOLT12 offers
and BIP353 support as well.  As far as I can tell, they are not using an
external or separate service behind the scenes to facilitate that, it's all
homegrown.  And it's the Phoenix 2.3.1 release that added offers, and the
Phoenix 2.3.3 release that added the DNS payment instruction support.  And I
believe with Phoenix, you can also plug in your own DNS-related records, whereas
I think the TwelveCash is all done behind the scenes.

_Stack Wallet adds RBF and CPFP support_

Next piece of software is Stack Wallet adding RBF and CPFP support.  This is in
the v2.1.1 release for Stack Wallet.  Both of those fee bumping mechanisms have
been added, as well as support for Tor.

_BlueWallet adds silent payment send support_

BlueWallet adds silent payment send support.  This is in the v6.6.7 release.
BlueWallet added the ability to send to silent payment addresses.  We've covered
a bunch of silent payment adoption and discussion and tooling over the last
several weeks, which is great to see.

**Mark Erhardt**: Yeah, generally it's pretty exciting to see these UX
improvements for users come through.  I think that BIP353, the DNS-based static
addresses, or static payment information, is going to be a big gamechanger.
And, yeah, BOLT12 on the LN side, of course, has been a long time coming, and I
think that silent payments will also, once it rolls out a little more, I think
there's few wallets that currency actually can generate silent payment
addresses.  And even when some consent to it yet, it'll take a moment, but yeah,
good things are coming.

_BOLT12 Playground announced_

**Mike Schmidt**: Another BOLT12-related update.  There is this BOLT12
playground that was announced by the Strike team, which is a testing environment
targeted for testing BOLT12 offers between different LN implementations.  So, it
actually uses Docker behind the scenes to spawn a bunch of wallets, create
channels, and then make payments across those different LN implementations.  We
talked about scaling Lightning, which was a similar initiative, which was a
testing toolkit for the LN that ran on regtest and signet.  I'm not sure, it
doesn't look like Stripe's using that behind the scenes, but I guess it's good
to see multiple testing environments for these different protocol updates.

_Moosig testing repository announced_

Moosig testing repository announced.  This is probably a bit niche repository.
It's a Python testing repository for MuSig2 and BIP388 wallet policies for
descriptor wallets, specific for testing I think the Ledger hardware device.
It's a simple script that's in Python that just tests support for
BIP388-compliant wallet policies in the Bitcoin Ledger app.  And as a reminder,
BIP388 is a templated set of output script descriptors, and these policies allow
software and hardware that can opt in to make certain simplifying assumptions
about how descriptors will be used, which helps minimize the scope of the
descriptors, and thus reducing the amount of code and details needed to be
verified by users.  So, specifically for hardware devices, it could come in
handy.

_Real-time Stratum visualization tool released_

Next piece of software is a real-time Stratum visualization tool that was
released.  You can see the tool running itself at stratum.work, which is sort of
a live look at various Bitcoin mining pools' Stratum messages.  So, you can see
some information there.  I think the source code is available, and it's based on
some work from 0xB10C that had a similar tool.  I know when the halving
occurred, there was some of us that were viewing 0xB10C's webpage that had
something similar up, so you could see what Stratum, what the different mining
pools were mining on during the halving, which was potentially quite dramatic at
the time.  So, it's great to see a source available tool for doing something
similar.

_BMM 100 Mini Miner announced_

BMM 100 Mini Miner announced.  This is a piece of mining hardware from the
Braiins folks, and it came with a subset of Stratum V2 features enabled by
default, specifically increased security using Stratum's end-to-end encryption,
as well as reduced data loads due to the binary protocol used in Stratum V2.
So, not necessarily choosing your own block template just yet, but some Stratum
V2 features in there.

_Coldcard publishes URL-based transaction broadcast specification_

Last piece of software this week is Coldcard, publishing URL-based transaction
broadcast specification.  So, there's a few different things here, but there's a
protocol that allows the broadcasting of a Bitcoin transaction using an HTTP GET
request, and the Coldcard folks are using that for their NFC-based hardware
signing devices to be able to broadcast transactions with a tap.  You may see
this Push TX website that Coldcard I think is running, and that's not to be
confused with a different Pushtx Rust tool that we actually covered previously
in our Changes to services and client software section.  That other Pushtx tool
was a Rust library that would connect to a variety of Bitcoin nodes to broadcast
your transaction.  Whereas this is more of a specification for broadcasting
using HTTP GET requests.  Murch, any comments on these?

**Mark Erhardt**: Oh, well maybe on the last one.  I think people are familiar
with the problem of trying to get the transaction to the network without
revealing anything about the sender.  So, one of the problems here is, of
course, that if you just push it out to all of your peers, especially if you're
a light client, it's probably obvious to your peers that you were either the
sender, or you were submitting it on behalf of your counterparty.  So, there's a
few interesting proposals around that.  One is, of course, you can just use a
website or a mining pool that offers this as a URL, to drop off the transaction
there.  The problem there is, of course, that you would leak your IP address.
So, people have been doing that over Tor.  And there's also the one-shot
transaction submission via Tor proposal that is being worked on in Bitcoin Core.
So, it's just another flavor, sort of, that fits more a signing device that
doesn't actually have any networking capability.  Yeah, I think it's interesting
how many different ways there are to approach this problem.

**Mike Schmidt**: Jonas, are you still on with us?  There's a question here that
I believe is targeted for you.

**Jonas Nick**: Yeah, sure.

**Mike Schmidt**: Big picture question.  Let's see.  It's a two-part question.
When will Bitcoin be upgraded to quantum resistance?  And two, can Bitcoin be
upgraded to quantum resistance?

**Jonas Nick**: Oh, wow.  Maybe the second question first.  I think yes.  So,
one thing that seems to be a theme that is developing is that the threat of
quantum computers doesn't go away, it will always be there, so it will be good
to be prepared or even have some mechanisms in the Bitcoin protocol that would
allow you to create or have wallets that are sort of quantum resistant.  And
there are even some recent studies which say that quantum computing might come
earlier than expected by many.  Of course, we don't really know for sure, but
certainly a very interesting topic.  I think at least right now, there isn't
really a very good scheme for how to actually achieve this.  So, there has been
some recent discussion and proposal on the mailing list, which doesn't really
have all the details that you would want for, of course, implementing it, but it
seems like a first step.

The thing is, the general problem is that making Bitcoin secure against quantum
computers has pretty big trade-offs, at least in the way we have to look at it
right now, because the schemes that would provide quantum security would be
either very slow to verify, so the signatures are very slow to verify, or
signatures and/or public keys are extremely large on the order of kilobytes
and/or that is so slow to verify and/or would be slow very slow to sign.  So,
right now it would look like we would have to accept some of these trade-offs if
we wanted to make Bitcoin quantum secure right now.  Plus some of the more
efficient schemes, they are not, they are pretty new so from a cryptographic
viewpoint, it might not make sense to settle on one of those schemes right now,
because they might turn out to be not as secure as you would hope or as you
would expect.  So, this is certainly a challenge right now.

There are schemes that have been proposed, let's say in the last two years,
which have fewer drawbacks in the sense they are relatively fast and they are
relatively small.  But those are exactly the ones where we don't really know
how, in the long term, or whether they will turn out to be secure.  So, that
that I think is the main challenge.  So, we could make Bitcoin quantum secure
sort of right now.  There are these older schemes, but they have pretty big
drawbacks, and I don't think that Bitcoin would work in the way it works today
with these huge public keys and huge signatures.  So, I think, in the longer
term, we will have to evaluate these proposals and hopefully there will be
better post-quantum algorithms that we can use in the future, potentially to
achieve post-quantum security.

**Mike Schmidt**: So, no open research questions still.

**Jonas Nick**: Yes.

_Bitcoin Core #26596_

**Mike Schmidt**: Thanks, Jonas.  Notable code and documentation changes,
starting with Bitcoin Core #26596 involving the legacy database.  Murch?

**Mark Erhardt**: Yeah, so we reported earlier how Bitcoin Core introduced its
own implementation of the Berkeley DB scheme for read-only, and that was, I
think, merged a few months ago.  So, the intent here is, a Berkeley DB is a
severely outdated implementation, I think like a dozen years old, or the scheme
that was used by Bitcoin Core was defined in a version that was published a
dozen years ago, and then it sort of went partially open source, or whatever.
Anyway, it's unmaintained software, we want to get away from it.  So, we've had
a multi-year effort to get new wallet types that use a different database scheme
and now are based on descriptors.  But of course, if someone comes back with a
Bitcoin Core wallet from 2010 and wants to be able to spend their money, we want
to be able to support that they will forever be able to access or import their
wallet.

So, we, mostly Ava actually, got this implementation for read-only Berkeley DB
and this is now being used for the migration of such legacy wallets to
descriptor wallets.  Yeah, that's the PR.  It tears out the actual Berkeley DB
implementation at this point and uses the read-only version in order to migrate
legacy wallets to descriptor wallets.

_Core Lightning #7455_

**Mike Schmidt**: Core Lightning #7455, which is a PR that enhances Core
Lightning (CLN) support for onion messages in a few different ways.  First,
onion messages are now rate limited to 4 per second.  Secondly, CLN can now
forward onion messages using short_channel_IDs (SCIDs) in addition to the full
node_ID which was previously supported.  And finally, CLN now turns on onion
messages by default, since they are now in the spec.

_Eclair #2878_

Eclair #2878 is a PR titled, "Activate route blinding and quiescence features".
So, there's two different LN features being turned on here.  First is route
blinding, which was added to the BOLT spec, and we covered that in Newsletter
#245, which route blinding allows a node to receive a payment or an onion
message without revealing its node identifier to the sender.  And the second
feature is the quiescence protocol, which we covered as part of BOLT2, which is
in Newsletter #309, which is a way to stop certain channel activity for a period
of time so that the channel can make certain protocol upgrades using the STFU
message.  T-bast noted in the PR, "We start advertising that we support them by
default", and these features were flipped from disabled to optional in Eclair's
code with this PR.

_Rust Bitcoin #2646_

Rust Bitcoin #2646 adds several methods for retrieving information about a
Bitcoin Script.  It adds the ability to get the redeem_script from a P2SH BIP16;
it improves retrieving the tapscript from the witness; it adds the ability to
get the taproot_control_block from the witness; it adds the ability to get the
taproot_annex from the witness; and it adds the ability --

**Mark Erhardt**: You're still there?  I lost your sound.

**Mike Schmidt**: Sorry, I got an incoming phone call.  I'll recap the last few
of these.  It adds the ability to get the taproot_control_block from the
witness; adds the ability to get the taproot_annex from the witness; and adds
the ability to get the P2WSH witness script from following the BIP141 rules.

_BDK #1489_

Next PR, BDK #1489.  This is part of BDK's efforts to rework their Electrum
backend to use merkle proofs.  Now, when BDK fetches a transaction, they will
also get the merkle proof and block header for verification, and there's some
reorg considerations that have been re-architected as well as part of this PR.
And this stems from an issue comment noting, "I think Electrum really intends
for you to use merkle proof API.  Best solution is to do that and attach
confirmation time of each block to local chain".  Yeah, go ahead, Murch.

**Mark Erhardt**: Yeah, one comment here.  It seems to me, if I saw that right,
that BDK now finally released their 1.0 version with the big re-architecture
that we talked about last year sometime.  And, yeah, so there was a huge flurry
of BDK updates recently.  I think that this is all sort of the last swath of
things that were happening before BDK 1.0 got released.

**Mike Schmidt**: One other thing to note here for BDK #1489 is that, in the PR
summary, they note that this is a breaking change.  So, if you're using BDK,
make sure that it's not breaking your software.

_BIPs #1599_

BIPs #1599, Murch?

**Mark Erhardt**: Yeah, so this one adds BIP46.  BIP46 is about documenting what
JoinMarket does with their fidelity bonds.  So, one of the problems that you
have with an open protocol to coordinate coinjoins is that it would be very easy
to sybil a naïve marketplace.  If, I don't know, 90% of all participants are
actually some sort of surveillant, they would be able to learn a lot about the
participants by participating in every single JoinMarket coordination.  And the
way that JoinMarket apparently defends or mitigates the impact of such a
surveillant is, it requires people to lock up funds for a significant amount of
time, and uses this fidelity bond, just locked-up funds, they can't be slashed
or anything, to sign the offers on the JoinMarket.  That allows participants to
be sure that some participant at least had to set aside coins that they can't
use otherwise for some period of time, like a year or even longer, and would
make it way more expensive for surveillants to generate a lot of participation
in the JoinMarket protocol.

So, BIP46 describes the wallet setup of how JoinMarket tracks these funds, and
there's a bunch of details there, how it locks up the funds exactly to, well,
just to some start of a month, which reduces the number of possible timestamps
that you have to remember, which makes it much easier to just store static
information and be able to recover all of your funds, even if you don't store
the timestamp itself.  Anyway, there is apparently some incompatibilities with
other BIPs, and unfortunately I think that there is little chance of that
getting fixed because this is documentation, not a proposal, that is still
looking for feedback on how to approach this situation.

_BOLTs #1173_

**Mike Schmidt**: BOLTs #1173 is a change to the LN spec titled, "Drop the
required channel_update in failure onions".  This updates BOLT4 of the
specification for onion routing, and the spec is changed.  And I think a
relevant piece here is, "The channel_update field used to be mandatory in
messages whose failure code includes the update flag.  The channel_update field
is no longer mandatory and nodes are expected to transition away from including
it".  The motivation here, I think, is articulated well by BlueMatt, who notes,
"As noted previously, channel_updates in the onion failure packets are a massive
gaping fingerprinting vulnerability.  If a node applies them in a
publicly-visible way, the erring node can easily identify the sender of an
HTLC".

_BLIPs #25_

And our last PR this week is to the BLIPs repository, BLIPs #25, which actually
adds BLIP25.  And BLIP25 is titled, "Allow forwarding HTLCs with less value than
the onion claims to pay".  And the motivation here is that many LN users are
expected to be connecting to the network using LSPs, or Lightning Service
Providers, and these LSPs manage LN channel liquidity on behalf of the end user.
And often, these end users are onboarded to an LSP using a just-in-time (JIT)
inbound channel when they are receiving an incoming payment.  But since those
channels cost fees to open, LSPs will want to take some extra fee from an end
user's incoming payment to help pay for those channel opens.

So, this BLIP codifies that ability to take that extra fee by specifying that
the penultimate hop in a Lightning payment can take an extra fee.  The BLIP
defines a TLV, a Type-Length-Value field, it's titled update_add_htlc, and that
allows a relaying node to relay a smaller amount than the amount in the onion.
Any comments on those last few PRs, Murch?

**Mark Erhardt**: Nothing is certain except for death and taxes!

**Mike Schmidt**: Well, I don't see any additional questions for us, so I think
we can wrap up, Murch.  Thank you to Pieter and Jonas for joining us this week
as our special guests.  Murch, thank you for being co-host yet again, and thank
you all for listening.  See you next week.

**Mark Erhardt**: Or even sooner.

**Mike Schmidt**: Indeed!  Cheers.

{% include references.md %}
