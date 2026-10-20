---
title: 'Bitcoin Optech Newsletter #362 Recap Podcast'
permalink: /en/podcast/2025/07/15/
reference: /en/newsletters/2025/07/11/
name: 2025-07-15-recap
slug: 2025-07-15-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Josh Doman and Gloria Zhao to discuss [Newsletter #362]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-6-16/404017715-44100-2-53811b06043be.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #362 Recap.
Today, we're going to be talking about compressing script scripters; we have a
PR Review Club about orphans and Bitcoin Core; and we have our usual Releases
and Notable code segments.  Murch and I are joined this week by Josh Doman.
Josh, you want to introduce yourself?

**Josh Doman**: Thanks for having me.  I'm Josh Doman, I'm an independent
developer.

_Compressed descriptors_

**Mike Schmidt**: Thanks for joining us.  We may be joined by Gloria later in
the recording, and we'll have her introduce herself when she joins us.  We have
one News item this week titled, "Compressed Descriptors".  Josh, we had you on
the show when we covered your descriptor encryption library in Newsletter #358.
And well, it turns out that part of the encoding approach that you used for that
descriptor encrypt library can be used as the base of an encoding scheme to cut
down on storage size of wallet descriptors as well.  Can you tell us what you've
been working on here?

**Josh Doman**: Yeah, that's right.  So, for context, I released this encryption
library a few weeks ago, which had two components.  It had an encoding component
to actually encode the descriptor, and then there was an encryption component.
And it turns out that just the idea of encoding it to reduce its size by 30%,
40% is useful in and of itself.  And so, I saw a comment by, I don't know how to
pronounce his name, Sjors, in the context of talking about capital H in
descriptors, and he was referencing how that might be useful perhaps to create
smaller QR codes.  And that kind of gave me the inspiration to say, okay, maybe
it'd be useful just to have a smaller descriptor format for QR codes, or for
other types of data formats, like maybe sharing over NFC, where you have a
limited number of bytes you can use.

So, I created a separate library, called descriptor-codec, where you can parse
in a string descriptor and it will encode it in a much more compact format that
saves about 30% or 40% bytes, using variable length encoding, and also just by
not having to use base58 encoding for the xpubs, things like that.  And I
released that.  I also released a companion little toy website, called
descriptorqr.org, where you can generate QR codes from descriptors and scan
them.  And so, that's what the library does and that's how it works.

**Mark Erhardt**: Okay, first question.  Can the website be run offline?

**Josh Doman**: You can build a website offline, yes.  It's available on GitHub.

**Mark Erhardt**: Because, of course, you're working for a triple-letter agency
and storing all the descriptors with the IP addresses, which would be the
natural reaction of bitcoiners!

**Josh Doman**: Of course.  I would also note that if you don't want to even
generate a QR code, you can use the descriptor-codec library as a command line
tool, and you don't have to worry about anything going over the internet.

**Mark Erhardt**: Okay, that's helpful, of course.  So, the output script
descriptors, of course, are a better backup for wallets because they get rid of
the separation of xpubs and script composition, and have it all together.  What
made you say, "Oh, I really need to store this as a QR code?"

**Josh Doman**: Well, it's a great question.  Our last discussion was about this
encryption library, and you presented some very good perspectives on why someone
might not want to necessarily encrypt their descriptor or store it on a
blockchain at all.  And I felt that that was perfectly reasonable, and I think
that many people still want to back up their descriptors offline, right?  You
might want to print it out on paper and store it next to your seed phrases.  And
if you print it out as a human-readable string, it'd be hard to take that back
into your software later to be able to access your funds.  Alternatively, you
could just run it through a run-of-the-mill QR code generator, right?  The
downside of that is, depending on how large your descriptor is, that QR code
might be very, very large, it might be harder to print out, it might be harder
to scan.  And so, if we can just encode it to reduce the size, that's free byte
savings, makes it easier to print out, sparser, it's easier to scan, that seems
like a win all around.

**Mark Erhardt**: Right, that sounds very reasonable.  So, I assume you looked
at things like how exactly the encoding goes, probably only use capital letters,
because that's more efficient for QR codes?

**Josh Doman**: I don't quite understand your question.  Could you repeat that?

**Mark Erhardt**: What did you use for the encoding, and what's your approach?

**Josh Doman**: Understood.  So, every component of the descriptor is given a
byte tag.  And so, what the encoder does is it moves along and if it sees, for
example, a witness scripthash, it gives it the witness scripthash tag and it
moves along the descriptor in that way.  P2TR, the tapleaves are given bytes,
etc.  And then, if it sees things like, for example, derivation paths, those
will be encoded using variable length encoding.  If it sees things like a block
height, that will be a variable length encoding.  And it's using in the
background the Rust miniscript library to do all this.  So, that's an incredibly
useful library.  It wouldn't have been possible so easily without it, because it
fully enumerates all possible descriptors.  And so, every type of descriptor is
handled by the encoding scheme.  And in the future, if new types of descriptors
become possible, if we have a soft fork, or things like that, then that will
need to be incorporated into this library as a tag.

**Mike Schmidt**: I have two related questions.  One, is anyone else doing
something like this?  And related, is the goal here to eventually have this be a
BIP to coordinate the production and consumption of these things by other
softwares as well?

**Josh Doman**: That's a good question.  I am not familiar with other tools
right now to encode descriptors in this way.  If they exist, that would be news
to me.  But I'd be very interested to see what people have built.  Whether or
not it should belong as a BIP, I think it depends on whether there's community
interest in that.  This is a useful tool to make things smaller.  If you're
going to parse things over machine to machine, it's not necessarily as useful
for human-readable descriptors.  If there's interest from that, from the
industry, then yeah, I think it'd be great for this to turn into something like
a BIP, but I'm not going to propose that unless there's interest from others.

**Mike Schmidt**: Well, that leads to my next question, which was, is there
interest from the community?  Maybe more generally, what's the feedback been?  I
saw Maxim Orlovsky replied, but I'm not sure if you had feedback outside of that
Delving Bitcoin thread.

**Josh Doman**: Yeah, I haven't received a great deal of feedback online.  I
personally, as I said, use this in my encryption tool, which did receive a
little bit more feedback.  That placed second at the Bitcoin 25 Hackathon.
People seemed pretty interested by that software.  I also could imagine that
salvatoshi's encryption scheme, which is different than mine, could also
potentially benefit from something like this, if the goal is to represent things
in a more compact format.  But I have not received feedback from wallet
manufacturers or software providers, but I also haven't reached out to those
people yet.

**Mike Schmidt**: Murch, any other questions?

**Mark Erhardt**: I think I'm good, thank you.

**Mike Schmidt**: Josh, we obviously noted the Delving post in the write-up.  We
have you on here to get exposure to the idea.  If somebody's interested in this,
I assume that you would just want feedback on that Delving thread, or are you
looking for other things from potential listeners?

**Josh Doman**: Yeah, please give feedback on the Delving thread, I'd love to
hear what you think.  And if there's ways that I can improve it, I'd love to
hear that too.

**Mike Schmidt**: Great, Josh, thank you for your time, thanks for joining us.
You're welcome to hang on if you want.

**Josh Doman**: Thanks for having me.

_Improve TxOrphanage denial of service bounds_

**Mike Schmidt**: Moving to our monthly segment on a Bitcoin Core PR Review Club
meeting.  This month we highlighted the, "Improve TxOrphanage denial of service
bounds", PR and we have the author of this PR as well as the host of the PR
Review Club from a few weeks ago.  Gloria has joined us.  Gloria, you missed the
intro portion, so maybe you want to just intro yourself for folks who should
know you.

**Gloria Zhao**: Hi, yeah, sorry I was late.  I got distracted at lunch talking
about things like this PR.  I work on Bitcoin Core at Chaincode Labs.  A lot of
what I work on is transaction relay and mempool things.  And this kind of
long-running project that you may or may not have heard of, because we've talked
a lot about it on Optech, is package relay.  We have some different components
of it that are in right now and some that are still in the works.  And one
long-running portion of it has been orphan resolution.  And part of orphan
resolution is this data structure that we use to temporarily store these
transactions while we are waiting for… yes, Murch?

**Mark Erhardt**: What's an orphan?

**Gloria Zhao**: Okay, sure, okay.  I always forget how much context I give it.
So, an orphan transaction is, from the perspective of a particular node trying
to validate this transaction, one that has missing inputs.  So, usually this
will happen when a transaction spends from an unconfirmed transaction that you
haven't received yet.  It is also possible that it spends completely
non-existent UTXOs that somebody just made up.  There's no way to tell the
difference between these two scenarios.  But because we do often run into the
scenario of just missing a parent, because we just came online or they announced
it to us a long time ago and you forgot about it… no, that doesn't make sense.
It could be spending a low-feerate parent that they just didn't send to us
because we had sent them a fee filter.  And this is kind of like a package relay
scenario.  We want the ability to handle these cases.

Actually, the orphanage has existed since Satoshi era times.  It used to hold
more than just transactions that were orphans or missing input specifically.  I
think maybe that has diverged into multiple data structures.  But yeah, it's a
separate data structure from the mempool, which is the transactions that we have
already validated and have considered to be consensus and policy valid, and we
think these are probably going to be mined in a future block.  So, mempool has
indexes on feerates and whatnot, whereas the orphanage is just a really
best-guess, best-effort data structure.  And the primary concern there is DoS.
So, prior to, I think, 2012 actually, the orphanage didn't even have bounds!
And yeah, that's pretty bad.  In many ways, 2012 Bitcoin nodes were pretty
vulnerable to DoS.

So, the solution at the time was to just cap it at 100 and then evict a random
one when… well, actually, it initially evicted by txid order, just the order of
the data structure, which was using the hash of the transaction.  And then, they
later changed it to be like a little RNG within your node's logic, not like a
cryptographically secure source of entropy, but just a way for you to randomly
evict transactions that your peer wouldn't be able to anticipate the order of.
But still, it has this problem where it's optimized really well for DoS, but it
is extremely churnable and, in the presence of adversaries, then completely
useless.  Because if you can imagine, if I'm using the orphanage as this, you
can think of it as like a temporary workspace to make it possible to download
packages and receive them.  Today, we have this opportunistic logic where if
there's a low feerate parent and we happen to have held on to the child
transaction in the orphanage, we'll go ahead and submit those as a package.  And
this is enough to, in normal cases, allow packages to propagate.  But of course,
the P2P network, we shouldn't assume it to be this very nice environment where
people are only sending valid transactions, right?  And so, we've been aware of
this.  It's not a vulnerability per se, it's just a known limitation of the fact
that we use this opportunistic data structure that is much more heavily
optimized for DoS than it is for fairness amongst peers.

So, this project, which I think I started maybe six months ago or so, was to
address a lot of these limitations and create a DoS protection mechanism that
was a lot more comprehensive.  So, for example, if a lot of peers are sending
you the same orphan, you probably shouldn't need to count the memory usage of
that transaction multiple times, right?  But at the same time, because we build
these indexes of each announcement and we also have indexes on the inputs of the
transactions, how do we account for the additional computational complexity, or
additional latency even, of handling transactions that are very large and have a
lot of inputs and etc?

**Mark Erhardt**: All right, let me recap a little bit.  So, we learned that
orphans are transactions for which we don't know some of the inputs.  And that
means of course that we, for example, don't know the feerate of the transaction
because we don't know how much money comes in.  And we use this
opportunistically to do package relay, because if we have a child and then learn
about the parent, and they happen to only work as a package where the parent is
maybe too low feerate, we can submit them to our mempool tests together.  So,
previously we had just one single orphanage and we randomly evicted one whenever
it overflowed.  It was limited to 100, I think, and to 100,000 vbytes?

**Gloria Zhao**: Yeah.

**Mark Erhardt**: Right.  So, if someone just sent us a bunch of made-up
transactions with inputs that didn't exist, we would drop everything on the
floor over time.  And now, you're saying that instead of just randomly keeping
everything in one bucket and randomly dropping stuff, we use announcements where
we remember who told us about what, and we can have announcements from multiple
people for the same transaction.  Is that right?

**Gloria Zhao**: Yeah.  So, we define a way of measuring DoS in multiple
categories, including memory and latency or computation for each transaction, as
well as each peer, and globally for the orphanage.  And so, this allows us to
create a more fair mechanism.  And the accounting is such that when multiple
peers announce the same thing, they're not double-counted, unless we really need
the space, or whatever.  And so, the algorithm is, when we're at the global
limit, we will look at which peer is DoSsiest on any of the metrics, and then
we'll evict their oldest transactions first.  So, there's no randomness anymore,
but this is kind of the sensible thing to do in an honest or a dishonest case
is, you know, it's fine to just do oldest first.

**Mark Erhardt**: Right.  So, if that were also announced by another peer for
whom it was not the oldest, we wouldn't drop it, but we drop just the oldest
announcement, right?

**Gloria Zhao**: Yeah.

**Mark Erhardt**: So, we have to continue evicting until we drop under our
global limit though?

**Gloria Zhao**: Exactly.  That's good and bad.  It's good in that no peer can
affect the evictions of another peer's orphans, because if somebody else has
announced it, then we'll still hold on to it.  The downside is you might go
through quite a few rounds of eviction before you actually find something that
doesn't have a duplicate to evict.  And so, the PR has a number of benchmarks to
handle these kinds of worst-case scenarios to see kind of what the potential
latency is.  If everybody announces the same stuff randomly, but it just so
happens that their last transaction is the unique one of something else, what
happens if you have to delete basically everything before you get to something
that actually makes a dent in the memory limit?  And of course, that's why we
have more than just a memory-loss score for these transactions.  We also do keep
track of the total number of announcements, and that's not a deduplicated thing.
That's every peer plus orphan counts as one.  And we actually also add input
count to that.  So, transactions with a ton of inputs will have a pretty large
impact on our outpoints index.  And so, we make sure to keep those down.

We picked a ratio that was chosen after some benchmarking and analysis of, it
wasn't profiling per se, but an analysis of how long it takes for us to update
each data structure within the orphanage comparatively.

**Mark Erhardt**: So, if we have multiple honest or non-malicious peers and one
malicious peer, they might send us a bunch of big transactions with lots of
inputs that actually, some of which might be made-up.  And the other
announcements from other peers probably get resolved more quickly, because once
they announce an orphan to us, we would ask back, "Hey, can you also give me the
parent?  I don't know about it".  And as soon as, of course, parent and child
are present, we can just submit them as a package.  So, does that mean that the
opportunistic 1p1c (one-parent-one-child package) relay should be way more
robust in this context now?

**Gloria Zhao**: Yeah, way, way, way more robust.  So, with the total cap-100
thing, you could just have one inbound peer that is just flooding you with
orphans and causing enough churn where nothing really stays in the orphanage
longer than a second, and that could be enough for you to have requested the
parent, it comes, and then you've already forgotten about the child, so this
whole thing is kaput.  But yeah, here's another thing, is we wanted to optimize
for the normal case as well.  So, you could have one peer that's sending you a
bunch of stuff and because they're an attacker… but you could also just have one
peer that is a good outbound of yours that happens to be the most helpful
transaction relay peer because, I don't know, you're in Palo Alto and they're in
Fremont, or whatever, and your ping times are just so fast, they're the first
ones to give you the orphans and the parents all the time.  In that case, they
might be an honest peer that is using the whole orphanage, and we didn't want to
limit those peers.  If there's no attackers, you have the space available, you
should be able to give the peer as much space as they are helpfully using, and
only evict when you actually reach the capacity, you actually reach the limit
that you set as the DoS limit.

**Mark Erhardt**: Right.  But if they are an honest peer that just happens to
send you a lot of orphans and resolves them, they would also reduce their memory
load again as soon as they send the parents, right?

**Gloria Zhao**: Yes, exactly.

**Mark Erhardt**: So, do you also track the historical record, "They sent me
orphans and resolved them", or would that maybe be part of the scoring?

**Gloria Zhao**: We do not in this PR.  So, the original idea I had was to do
this kind of token bucket mechanism, where everybody starts out with the same
number of tokens -- they're not real tokens, they're just counters, they're
integers -- tokens for how much space or how much of each metric you're allowed
to use.  And then, the more useful you are, these tokens will replenish.
Whereas, if you keep sending orphans that don't end up being useful at all, then
gradually those tokens are not returned to those peers and you eventually go to
zero.

**Mark Erhardt**: Right, but if multiple people announced to you, you'd have to
give back and call them useful announcements anyway for everyone, right?

**Gloria Zhao**: Yeah, exactly.  And it's not entirely clear how fair this is,
given that you could have policy differences with your peers, you could have
received things out of order for other reasons.  Like, there are completely
benign reasons for why somebody's orphan might not pan out.  And one layer
removed at just the 'how we choose our peers' layer, we have these kinds of
eviction preferences where we have a lot of inbounds, we'll rotate them.  A peer
that's like never been useful to us in terms of giving transactions, we might
select them for eviction sooner than another one that we are actively having a
dialogue and giving each other useful data with.  So, yeah, the token bucket
idea did not seem necessary.  I think we are still thinking about potentially
having different limits for outbounds versus inbounds, just because we
inherently are much more selective and assume better behavior from outbounds,
because we choose who our outbounds are; instead of inbounds are people who
connected to us.  So, we should basically assume that they're all attackers when
we're designing this data structure, whereas outbounds, we can kind of be a
little more generous towards.

But yeah, it's a good point.  There's room for I think baking in more reactivity
to different behaviors with peers.  I think in terms of timers, for example, in
the transaction relay mechanisms, so not the orphanage, we could kind of give
peers more or less time to respond to things or before we retry with other
peers, for example, based on how they have responded in the past.

**Mark Erhardt**: So, we discussed earlier that the original limit was 100,000
vB (vbytes).  And I saw in the description of the PR Review Club that now
there's a limit of 100,000 vB per peer.  Does that mean that our orphanage is
now up to 12.5 MB big?

**Gloria Zhao**: So, it's 101,000 vB per peer.  Well, actually that would
translate to up to 404,000 bytes, because if it's all witness data, I mean, a
normal transaction isn't 100% witness data, but the cap is actually closer to
400 bytes in terms of memory usage.  You have to add that multiplier to vbytes.
Yeah, so the potential memory usage has gone up by a little bit.  So, if you
think about the original limit being 100 transactions times, let's just call it
400, you get to 40 MB.  That was the original worst case, right?  And now we are
doing it as a multiplier of the number of peers.  So, the default is 125. It's
more like 10 if you don't do inbounds.  But 125 times 404 is like, it's higher
than 40 MB, but it's only higher by a little bit.

**Mark Erhardt**: Right.  Sorry, I thought that previously the limit was 100
transactions or 101 kilo-vbytes (kvB), but it's 100 times 101.

**Gloria Zhao**: Yeah.

**Mark Erhardt**: So, yeah, that used to be a little over 40 MB because of
witness data.  And now, with 125 peers, so it's like a quarter more or so,
50-something MB maximum.  Of course, that would be if the transactions were
completely witness data, which is unlikely, and all of our peers were filling
our orphanage, which also seems pretty unlikely, unless we're being attacked by
not just one peer.  Okay, so yeah, go ahead.

**Gloria Zhao**: I just want to add, since we're talking about memory and have
this document of a bunch of things we could do to the orphanage, and one of them
is the way that transaction data is stored in memory is pretty inefficient.
It's actually, I think, more than double what the serialized size of that
transaction could be.  And of course, we have all these other data structures,
like the outpoints index that I was talking about, where I was like, in the
worst-case block, where you have like 27,000 inputs or something, this data
structure is even bigger than the main one.  So, yeah, that's not the exact
number, the 50 and the 40 that we were just talking about, it's actually higher.
But we were thinking this is first of all very tolerable for how modern
computers run Bitcoin nodes today, and because it's quite similar to the
original value.  But there are things that we could do to make this much more
compact.

If we wanted to, for example, increase the limits without really increasing the
limits, we could be like, "Let's store orphans in serialized form", and build a
custom kind of shared pointer thing within the orphanage to better utilize the
space, and thus be able to increase the global limit without really increasing
the global limit.  Yeah, I just wanted to add that.  Might be interesting.

**Mark Erhardt**: Okay, I have one more question.  So, in the past couple
months, we've been talking a lot about different node types that may have
diverging mempool policies.  So, assuming that all of the node populations were
running this new TxOrphanage, but there were two groups of nodes that had vastly
diverging mempool policies, how, would you say, does that change how
transactions get propagated on a network and may still be in the orphanage when
blocks come in or not?

**Gloria Zhao**: So, in the singleton transactions realm, there's no difference,
because orphanage is just when you're missing inputs.  So, I guess this would
mostly impact situations where you have policy differences, some nodes consider
a transaction invalid, and some nodes will reject it based on their policy and
some people accept it.  Maybe these transactions get spent by unconfirmed
children, and then those are propagated to the nodes that rejected them.  They
would say it's missing inputs, they would request it from the originating nodes.
Yeah, you would waste a little bit of bandwidth where you're re-downloading this
invalid transaction.  And then you'd reject it immediately, because it's in your
rejections cache for not meeting policy.

**Mark Erhardt**: Wouldn't you be able to tell that from the txid already?

**Gloria Zhao**: No.  I mean, the vast majority of transactions are segwit,
right, particularly the ones that these nodes are rejecting for policy reasons.
But this is true.

**Mark Erhardt**: Oh my God, are you thinking of a concrete set of nodes?

**Gloria Zhao**: Like, in the 90s% of transactions are segwit.  And of course,
when you're missing an input, you only know the parent by its txid.

**Mark Erhardt**:** **So, because the witness txid could have changed, if we
rejected something based on its witness data, we would still have to download
the same txid, because we don't know if the witness data might have changed.
There might be two ways of spending the same output, say a keypath spend and an
inscription, and we just don't like the transaction with the inscription, but
yeah, okay, I see.  All right.

**Gloria Zhao**: Yeah.  But so, the good thing is that you would probably
download again but you wouldn't validate it again.  So, it would be not great
for your bandwidth but, well, not 'not great', as in there would be a slight
difference in how much bandwidth is used.  But because of the rejection caching
that we do, if you receive the same transaction again, you won't look at it
twice.

**Mike Schmidt**: Is the rejection caching the same as this extra pool that I've
heard this label, or is that something different?

**Gloria Zhao**: It's different.  So, we have an extra pool which contains
transactions that we've rejected or replaced that we'll keep around just in case
they confirm in a block, and we can use that to reconstruct the compact block.
The rejections cache, we don't hold onto the transactions.  It's just a rolling
Bloom filter of the wtxids of transactions that we have rejected.  So, as Murch
mentioned, definitely not a txid, because that would be very problematic if
someone could send us a transaction with a different witness, we'd reject it,
and then we'd just reject all versions of that transaction by txid.  So, we
throw rejected wtxids into this rolling Bloom filter.  It has like a 1 in 1
million probability of doing a false positive, but in general it's very compact
but fairly reliable for us to say like, "Hey, have I seen this transaction
before?  Should I just throw it, drop it on the floor?"  And so, we'll do that
to save our computation from being wasted.  But like I said, that's different
from whether or not we'll redownload the transaction.

**Mark Erhardt**: Right, so if someone could send us a transaction with a broken
witness and we would reject the txid, that would be problematic because witness
data is actually malleable.  But I think we covered that earlier in this news
recap, maybe 100 episodes ago!

**Mike Schmidt**: You and Murch talked about the size of this data structure
being capped.  I also see that in the write-up for this Review Club, there's
also a limit that has been changed on the default announcement limit going from
100 to 3,000.  Can you talk about the announcement limit and the rationales
behind 3,000?

**Gloria Zhao**: Sure.  So, one could say the original announcement limit, we
never enforced an announcement limit, but we allow 100 unique transactions,
right?  And then, we have a set of announcers for each on master.  We already
keep track of multiple announcers.  And I guess, 100 times 125 is the effective
announcement limit on master, although in practice, I imagine must be a lot
lower.  So, yeah, with the worst-case scenario I mentioned before, which is that
all of the oldest transactions from every peer is a duplicate of another
announcement from another peer, then we're going to be erasing, like we always
pick the DoSsiest peer, right?  We evict one.  Then we pick the next DoSsiest
peer, we evict one.  And then we're just evicting round robin until we get to
the very last transactions, and we finally find one that's unique, and we
actually can free up memory by deleting this transaction.  This is kind of the
worst-case scenario we can contrive for the new eviction policy.

So, it would be pretty bad if we had no announcement limit.  It probably
wouldn't happen in practice, but we could have this really, really awful
pathological case.  And so, basically what we did was we wrote a benchmark for
this, and we used 125, I think we used 125; we used a realistic number of peers
and then we benchmarked the worst case to fit within our memory limits, but to
see what is the overall latency of this worst-case scenario.  And we basically
wanted to bring it to a millisecond or a couple of milliseconds.  That seemed
acceptable for something that can happen very regularly within one message that
you process from a peer on the P2P network.  And then, we also tried to create a
nice, easy-to-reason-about limit per peer.  And so, what we came up with was 24
per peer at a time, unique, so total 3,000 if you have 125 peers.  And the 24 is
like this magical number where if we think about the worst-case, single, honest
transaction that you might be working on with a peer, what's the most amount of
missing inputs transactions you might have with this peer that's relevant to one
transaction, and that's 24.  So, you have like this one missing transaction and
then 24 transactions that spend from it.  That's the default policy limit, is a
descendant package of size 25.

So, this kind of neatly encompassed like, "Okay, everybody can be announcing one
descendant package guaranteed at a time".  And also, if we have this crazy
scenario where everybody has the exact same thing except for the last couple
transactions, it would take us less than a few milliseconds to actually run this
eviction algorithm.

**Mark Erhardt**: So, of course, if you had a transaction with 24 parents and
one child, that would still also be in the current ancestor limit.  But would we
ever then ask back for all 24 parents?

**Gloria Zhao**: No, because the child is the only one that can possibly be
missing unconfirmed inputs.

**Mark Erhardt**: No, sorry.  Someone announces an orphan to me and it has 24
unknown inputs.  Would I ask for all 24 inputs, the parent transactions?

**Gloria Zhao**: Yes.

**Mark Erhardt**: Okay.  But do we then also submit that as a package?  I
thought it was only for 1p1c.

**Gloria Zhao**: No.  So, orphan resolution has existed a long time before 1p1c
has.  The 1p1c logic is just specifically for the case where the parents are low
feerate.  So, the network doesn't really have any support for 24 parents being
bumped by one child.  It's just, if you just came out of IBD and these 24
parents had been circulated a few minutes ago, and somebody spends from all of
them and you receive a child and you're like, "Oh, sorry guys, I wasn't here
when you guys broadcast the parents, could you just send them to me please?"
That's a scenario that's been around for a really long time.  So, yeah, if all
of them are low feerate, we're out of luck, sorry.  Still working on the
arbitrary package validation stuff.  But if it's just 1p1c, then…

**Mark Erhardt**: So, if 23 are high feerate and one is low feerate, it will
still work?

**Gloria Zhao**: Unfortunately not, but I have a PR that disables that stupid
restriction.  It truly is an unnecessary restriction that was put in there in
2022, or something.  I had a PR out for like a year to remove it.  But yeah, if
you want to review that, that'd be great.

**Mark Erhardt**: All right, so these are all my questions.  Back to you, Mike.
Yeah, I think we did a good job diving deep and it's great.  I mean, that's a PR
Review Club, that's what we're supposed to do.  Gloria, is there anything that
you'd want to say to tie all of this work on the orphanage lately?  The
orphanage has become more of a load-bearing data structure than it has in the
past.  Do you want to tie that back to the work that you're doing in this bigger
picture that you mentioned earlier in the chat on package relay?  Maybe just
spell out, why exactly is the orphanage becoming so load-bearing recently?

**Gloria Zhao**: Yeah, I like the term 'load-bearing'.  I think that's a good
way to describe it.  I feel the same way about the extra pools.  We have these
opportunistic data structures.  Yeah, they're best effort, but unfortunately,
completely unreliable.  And while we can't make them completely robust, like
100% guaranteed, whatever, we can do a lot better than just 100 and you evict
one.  Yeah, so in the greater package relay kind of picture, package relay is
all about making transaction relay more efficient, and the P2P marketplace of
transaction broadcast an efficient one.  And I think package relay, as written
in the BIP, has a couple different use cases.  One is to try to get rid of
txid-based relay, which we talked about, actually about witness malleation, why
trying to talk about transactions with your peers using the txid relay is really
problematic, because it's not specific enough for you to really be able to not
have to re-download things over and over again.  Because if it's by txid, you
have to basically always be optimistic that this time I download it, it will be
a valid version of it.  But if peers only talk to each other via wtxid, then you
wouldn't have this problem.

So, that's one use case of package relay, which requires the orphanage.  And
that's why it's so relevant to package relay is… sorry, orphan resolution right
now is the only time that we need to talk about txids in the transaction relay
functionality of peers.  It's the only time we still use it.  But if we were to
just have a protocol where we asked people, "Hey, can you give me the ancestors,
but do it by wtxid?  I know what the txids are and I know I'm missing at least n
of them.  Can you just tell me the wtxids, and then I'll work on downloading
those?"

Then, the other one is for fee bumping, right?  We have this very deep-rooted
limitation where, because we don't analyze packages at a time, we miss
transactions that are going to be bumped but aren't enough by themselves.  And
that's also, as we've implemented it today, this situation where we're reactive,
right?  We're like, "Hey, I got a low-feerate transaction, I'm missing
something", or, "I got an orphan transaction.  It must be bumping something, but
I'm missing that data".  Being able to store that in this load-bearing data
structure makes all this way, way more reliable.  And so, orphan resolution is
something that makes package relay so, so, so much more useful.  And I had been
thinking of it as like a nice-to-have after package relay, but it really does
change the game, I think, if you're able to guarantee that you're going to
remember at least a few transactions per peer, because the nature of package
relay is you have to remember something.  It's like you have a transaction that
requires something else, whether it's a bumping thing or if it's a missing
parent.  Having this place to store unvalidated data is really useful.  And so,
all of these changes that we're making are very useful to package relay.  And I
think after this is done, we're basically going to be working on arbitrary
package validation.  And then, hopefully we can get something a lot bigger than
1p1c in a year's time.

**Mike Schmidt**: Excellent.  Murch, anything else before we wrap up PR review?
Gloria, thank you for joining.  I think this was much more productive with you
joining us than me and Murch worrying about having to do this without you, so
thank you for your time.

**Gloria Zhao**: Thanks so much for having me.

_LND v0.19.2-beta.rc2_

**Mike Schmidt**: Cheers.  Releases and release candidates.  We have LND
v0.19.2-beta.rc2.  I think the rc1 also came out late last week, but I don't
think that we covered it in the newsletter.  This rc2 includes ten bug fixes.
It also adds support in LND for testnet4 and signet peer seed services.  So,
previously they had testnet and mainnet, but not testnet4 and signet.  So, you
can now find peers in LND that way.  It also adds a database cleanup that will,
"Lower disk and memory requirements for nodes significantly".  So, that's an
optional database migration.  And then, there's also other features as well.
So, check out the Release Notes for details on those ten bug fixes and those
other features.

_Core Lightning #8377_

Notable code and documentation changes.  Core Lightning #8377.  This is a PR
that implements some of the recent changes to the BOLT spec that we covered
previously.  The first change to the BOLT spec implemented here is the change to
make the payment secret field, which is s, mandatory in BOLT11 invoices.  The
advantage of that is that it prevents payment probing attacks by requiring all
invoices to include those payment secrets.  We covered that change to the BOLT
repository, which #1242, and that was in Newsletter #350.  And then, the second
change is that Core Lightning (CLN) will now enforce that a sender must not pay
a BOLT11 invoice if a mandatory field has an incorrect length.  And this change
was in the BOLTs PR #1243, and it clarified that a mandatory field that is
present but has an incorrect length, that the invoice should actually be failed
instead of skipping that field.  Previously, it was ambiguous about how that
should be handled.  Yeah, go ahead, Murch.

**Mark Erhardt**: I was wondering, you said that this changes probing.  How does
it change probing?  Did you read more up on that?

**Mike Schmidt**: So, the requirement that all invoices include payment secrets.
Now, if you double-click on that, I return null, I don't have an answer for why
those payment secrets prevent probing attacks.

**Mark Erhardt**: So, I think the payment secret would only become relevant in
the last hop, where the recipient receives the multi-hop contract, and then they
would parse out the innermost onion.

**Mike Schmidt**: Sorry, there's a piece from the PR that I can pull out, "The
payment secret prevents intermediate nodes in the payment path from probing for
the destination by generating their own payment onions".

**Mark Erhardt**: Okay, so if an intermediate node malleates the multi-hop
payment, they can learn something.  I was going to say, if the sender is
probing, often they will try to find information about an intermediate hop, and
they would learn whether the intermediate hop has sufficient funds to forward by
whether or not the probe passes the intermediate node and comes back from
downstream, or is returned by the intermediate node.  So, I was surprised that
it would affect probing.  But yeah, so if it means that the intermediate hub is
malleating something and then checking whether the neighbor is the recipient,
that would make more sense.

**Mike Schmidt**: Yeah.  And that last component of the BOLT11 invoice changes,
about the mandatory field being present and having to have the correct length
and not just skipping that field, we talked about that.  That was in Newsletter
and Podcast #358.

_BDK #1957_

BDK1957#.  This PR improves the performance of syncing and full scans when using
the Electrum backend.  Specifically, the full scan time was cut by about 50%,
and those performance improvements were achieved by a combination of batching
RPC calls and also caching certain RPC calls, which cut down on the network
traffic, the need to round-trip, while also eliminating any redundant work as
well.  So, a performance optimization there if you're using Electrum as your
backend.

_BIPs #1888_

BIPs #1888, this harkens back to some discussions we've had recently, one in
Newsletter #360, talking about H, as the capital H, as the hardened derivation
path marker in BIP380.  Murch, as our resident BIP editor, what's going on here?

**Mark Erhardt**: Okay, so 380 is a BIP that deals with descriptors and
specifically with, I think, derivation from various types of descriptors.  And
originally, BIP380 introduced capital H as a second alternative for the hardened
derivation marker.  So, hardened derivation is a derivation step where you need
to have the private key in order to derive the child, rather than unhardened
where you simply need the public key in order to derive a child.  So, for
example, if you have an xpub and it has a hardened derivation step below, those
additional keys cannot be derived by other people that only know the xpub; they
need the private key.  Traditionally, the marker to symbolize that was a single
quotation mark.  And now, of course, with strings, the quotation mark often
delimits the end of a string.  And this is sort of an RPC interface hazard,
because if people put their string arguments or parameters for RPC calls in
single quotes instead of double quotes, the single quote, as a hardened
derivation marker, would end the string there, so it has to be escaped.  And I
think a lot of people struggle with the RPC for what exactly needs to be escaped
and what doesn't.

So, I believe the lowercase h was introduced as an alternative hardened
derivation marker, in order to make this problem go away, where we don't delimit
strings accidentally with single quotation marks.  I don't exactly know how the
uppercase H came to pass, but it might be because people were thinking about QR
codes being more efficiently encodable if you have only numbers and uppercase
letters.  And that was also what I was bringing up with Josh earlier.  So,
there's a different QR code encoding mode that has a smaller alphabet, so it
makes more compact QR codes, ie the grid is smaller in the QR code, which means
that it's easier to scan.  So, that uses only uppercase and maybe people were
thinking about, "Well, eventually output script descriptors might be represented
as QR codes for import or export.  And in that case, we might want to be able to
use uppercase".

However, there was an inconsistency where the test vectors forbid uppercase H,
but the text of the BIP specifically introduced it as a second alternative
hardened derivation marker.  So, this was recently fixed when someone discovered
it.  And specifically, this is now fixed, because apparently nobody has been
implementing the uppercase H as a hardened derivation marker, and so it is just
being dropped; you don't use the uppercase H anymore.  If your implementation or
project handles this differently, there was a discussion on the mailing list,
and I know that we've also relayed the message here before.  If someone is using
uppercase H as the hardened derivation marker, please speak up, because
otherwise this is dropped from the BIP now.  And yeah, well, at least Bitcoin
Core and Rust miniscript do not do it right now, so, to our knowledge, we are
safe to drop it.  Anyway, this is just to bring everything into consistency and
make it a little simpler.  And if that doesn't affect you, that's fine.

**Mike Schmidt**: Yeah, reach out if it does.  I believe there was a
mailing-list post on it and we obviously reference the newsletter where we
talked about that, and we have the BIPs #1888 here for you to come squeal.
Thanks for summarizing that, Murch.  Thank you to our guests, Gloria and Josh,
and my co-host, Murch, and you all for listening.  Cheers.

**Mark Erhardt**: Cheers.

{% include references.md %}
