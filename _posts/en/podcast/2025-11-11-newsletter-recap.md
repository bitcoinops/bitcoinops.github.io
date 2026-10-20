---
title: 'Bitcoin Optech Newsletter #379 Recap Podcast'
permalink: /en/podcast/2025/11/11/
reference: /en/newsletters/2025/11/07/
name: 2025-11-11-recap
slug: 2025-11-11-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by Sebastian Falbesoner,
PortlandHODL, Tadge Dryja, and Antoine Poinsot to discuss [Newsletter #379]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-10-12/412340250-44100-2-37a87d02c626e.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Optech Recap #379.  Today, we're going to
be talking about comparing performance of ECDSA signature validation and OpenSSL
versus secp ten years on; we have multiple discussions about restricting data at
the consensus level from our Changing consensus monthly segment; and we also
have a discussion of a potential post-quantum signature aggregation idea and
opcode, as well as a native STARK opcode, also included in our Changing
consensus monthly segment.  And to round that off, we're going to talk about
some updates to BIP54, the consensus cleanup.  And then, we also have our weekly
Releases and release candidate, and Notable code segments.  Murch, Gustavo and I
are joined by a few special guests this week.  I'll give them a chance to
introduce themselves.  Sebastian?

**Sebastian Falbesoner**: I'm Sebastian, I work on Bitcoin stuff and I'm funded
by Brink.

**Mike Schmidt**: Portland?

**PortlandHODL**: Hi, PortlandHODL here, known as a very light Core contributor,
small changes only, and Bitcoin education on Twitter and some novelty products,
such as Slipstream, and doing a presentation up next about DoS blocks that has
been pretty popular.

**Mike Schmidt**: We have two other special guests that may be joining us later
in the show and we'll have them introduce themselves when we get there.  We'll
start off in order of the newsletter this week, but we may hop a little bit out
of order in deference to some of our guests and being cognizant of their time.

_Comparing performance of ECDSA signature validation in OpenSSL vs. libsecp256k1_

Jumping into the news section, first and only news item, "Comparing performance
of ECDSA signature validation in the OpenSSL library versus the libsecp256k1
library".  Sebastian, you posted to Delving Bitcoin and you outlined comparing
the performance of the two different libraries on signature validation, and you
looked at that over the past decade.  I guess it's been ten years and so you
wanted to do some benchmarking.  Maybe talk a little bit about how you did the
benchmark, what you came up with, and maybe even why you did it.  Sorry, Murch,
Murch is going to correct me.

**Mark Erhardt**: I need to jump in.  He hasn't been looking at this for a
decade.  He's been looking at the data from the last decade!

**Sebastian Falbesoner**: I wasn't a contributor yet, but yeah.

**Mike Schmidt**: You don't know that, Murch!

**Sebastian Falbesoner**: How could you know?!  Yeah, so the reason I looked
into that was that I was a little looking into past history of libsecp.  So, to
shortly explain, OpenSSL and libsecp are libraries to create and verify digital
signatures that are a fundamental part of every transaction in Bitcoin.  And
originally, the initial client was shipped with OpenSSL as a dependency.  And it
was about ten years ago that that was replaced by a libsecp library that was
created by Pieter Wuille, sipa.  And yeah, when I was researching, I was seeing
different numbers about speedups.  So, there is a PR linked in this Delving post
that I can very much recommend everyone to read.  It contains a nice summary.
And in that PR, it said there was a speedup of 2.5X up to 5.5X, a pretty wide
range, compared to OpenSSL.  But I also found other numbers.  I listened to some
early podcasts, there were speedups mentioned of 3X, some Stack Exchange posts,
they mentioned 5X.  So, I thought, okay, why not look at it, what the actual
speedup was, and also more concretely, how did that speedup develop over time,
how it is today.

So, in the first step, I tried to compare the latest versions each, like OpenSSL
and libsecp.  That already showed the end results that we will hear soon, the
great speed-up.  But I thought, wouldn't it be nice to also look historically at
how that developed, so not only using the latest versions by the Linux
distribution, but also compiling every version and benchmarking that with
dynamic loading.  And it turned out to work quite well.  So, in the first step,
all the versions are compiled with a shell script and are created creating a
shared object file, and then there is a little C program that loads one after
another each of these shared object files for each version, benchmarks three
specific functions that are relevant here for signature validation, that is
namely parse the public key, parse the signature, verify the signature.  And
doing that, yeah, it yielded a nice result.

So, the punchline probably is that by now, libsecp is 8 times faster than the
current version of OpenSSL, because there was not much change going on in
OpenSSL for the last decade.

**Mike Schmidt**: And to be fair, OpenSSL does a lot of different things.

**Sebastian Falbesoner**: Some describe it as a Swiss Army knife for
cryptography, and I think that's a quite proper explanation.  It offers
everything from, I don't know, certificate handling, TLS connection stuff, by
now people even post-quantum cryptography already.  So, it's in the other side
of the spectrum compared to libsecp, which is only a library originally targeted
only for signature validation.  By now it contains a little more that is
relevant for the Bitcoin ecosystem on this specific curve.

**Mike Schmidt**: And this wasn't just one machine.  It sounds like you ran this
across a bunch of different machines.

**Sebastian Falbesoner**: Yeah, I ran it on an ARM64 machine and on two x86-64
machines.  The graphs looked quite similar everywhere, but also sipa was posting
the result on his machine, and there wasn't as much of a big speed-up on one of
the version jumps.  So, it is also a little dependent on the hardware
architecture, because there are some hardware-specific optimizations even
included and also the benchmarking.

**Mark Erhardt**: Sorry, you go ahead.

**Sebastian Falbesoner**: Yeah.  Sipa replied that there is a certain bias
involved, because we are benchmarking now these past versions with CPU
architectures that were not even available back then.  So, for example, ten
years ago, ARM64 was probably not widespread.  Maybe it existed, I'm not
completely sure, there was much more 32-bit architectures than now.  And yeah,
the same with compiler versions.  If you run this project that I created, it
just picks the CC symlink that points to whatever compiler is installed.  And
yeah, sorry, Murch.

**Mark Erhardt**: Yeah, I wanted to point out that now for some CPUs, there's
even native instructions for certain cryptographic operations.  And of course,
that sort of stuff also has changed in the last ten years.

**Sebastian Falbesoner**: Talking about that -- yeah, sorry?

**Mike Schmidt**: Well, say what you want to say.  I have a follow-up question,
unrelated.

**Sebastian Falbesoner**: Yeah.  Talking about that, I wouldn't mind if someone
would send in a benchmark result on a 32-bit machine.  I would be interested in
that.  I've got two other people so far that sent in results that was both on an
x86-64 machine.  And even though 32-bit machines are not that relevant anymore
today, it would still be interesting to know how the graphs look there.

**Mike Schmidt**: Okay, listeners, you have a call to action here from theStack,
run it on a 32-bit machine and reply to the Delving post, right?

**Sebastian Falbesoner**: Yes.  Even if it's not a 32-bit machine, it would be
nice to get more results.  And if anything doesn't work, like the compilation
fails, then just feel free to open an issue on the GitHub project.

**Mike Schmidt**: I think listeners are probably impressed with the speed-up
that this Bitcoin-specific library has over the more generic Swiss Army sort of
default that Satoshi included to get that functionality originally.  Can you
comment a little bit about things that aren't performance-related, of why secp
would be a good idea to use, and getting rid of OpenSSL might be a good thing to
get rid of?

**Sebastian Falbesoner**: Yes.  So, OpenSSL, one lesson from that time back
then, ten years ago, OpenSSL is very much not designed for consensus systems.
There were certain issues that in the worst case could even lead to chain
splits, because a signature might be valid in one version and in another version
it wouldn't be because of certain differences, even on the bit size of the
system, for example.  And so, it's good to have something that is in our control
and is deterministic.  And also, it is good if the code is much smaller, more
focused on what we need.  So, there is also less review burden on that.

**Mark Erhardt**: I want to double-click on that too, because secp is so
important for Bitcoin.  It is hardly important anywhere else.  It's not a
first-class citizen in any other cryptographic systems.  It's only in Bitcoin
that it's used pretty much.  There just wouldn't have been any incentive for a
general purpose crypto library to invest a lot of time into secp.  But for us,
of course, where we want to verify tons of signatures in every block, we want
this to be fast and we want this to be secure and we want this to be stable over
various versions.  So, if you think back, some of you might remember the
Heartbleed bug in OpenSSL.  Such a huge library has, of course, a way bigger
surface for all sorts of activities, changes, bugs being introduced; whereas
libsecp being so super-focused only on the cryptography that Bitcoin needs, and
very specifically engineered for exactly that purpose, does not have that
attack.

**Mike Schmidt**: Sebastian, am I right to understand that secp also, there's
some timing considerations with, am I right, the side channel attacks?  Is that
something that secp prevents?

**Sebastian Falbesoner**: Yes, that concerns the signing part of the
transactions.  Because when you sign a transaction, you have to put that private
keys of yours to that library.  And so, there's a delicate process where some
side channel leaks could happen.  And yeah, libsecp also takes great care of
that by making these operations in constant time, it is called.  That means not
including any data branches that depend on that secret data.  I would assume
that OpenSSL also takes good care of that.  But of course, if we have it in our
control, and also test appropriately for it, then that might be even better.
I'm not up to date what efforts OpenSSL does in that sense, but it's absolutely
also a consideration, yes.  I mean, in that specific benchmark scenario I did,
there is no side channel problems involved, because it's only the verification
part, it's all public data.  But it's nevertheless a good point, yes.

**Mike Schmidt**: Any other follow-up comments or questions for Sebastian?

**Sebastian Falbesoner**: I have one, since you talked about signing, if someone
wants to do a benchmark scenario for signing, I also wouldn't mind.  So, feel
free to open a PR if you want to do that.  That would also be interesting, maybe
not as relevant for the typical node runner, but yeah, it could be an
interesting project if someone wants to do that.

**Mike Schmidt**: Murch, did you have a final question?  No.  All right.
TheStack, thanks for joining us, thanks for putting this research out there.

**Sebastian Falbesoner**: Thank you for having me.

_Multiple discussions about restricting data_

**Mike Schmidt**: Yeah, thank you for your time.  Cheers.  Moving to our monthly
Changing consensus segment we have a handful of items, and actually the first
two are somewhat related.  They're both sort of looking at ideas to change the
limits of various fields in consensus.

The first proposal we have titled, "Limiting scriptPubKeys to 520 bytes".
Portland, you posted to the Bitcoin-Dev mailing list as part of BIP2, a proposal
to limit the scriptPubKey size to 520 bytes in consensus.  What were you or are
you looking to achieve with this limit?

**PortlandHODL**: Okay, the primary reason for this specific change was in
response to a talk I did at OPNEXT about DoS or poison blocks, which essentially
you can use long-legacy scriptPubKeys create a very hard-to-validate block with
enough inputs.  And yeah, so by kind of cutting that limit down, you can reduce
that total time to validate by quite some time.  So, right now, it's on the
order of about 11X compared to what it previously was.  So, 25 minutes was my
worst block, and the current one I'm testing against is about 1 minute 40
seconds.

**Mike Schmidt**: And this was in your OPNEXT presentation, where you sort of
outlined some of these numbers and how one might do this.  Can a miner just do
this in a given block?  Is there setup required?  How would this work?

**PortlandHODL**: Yeah, so this specific method to create a very
hard-to-validate block requires a lot of setup.  I think it's like 161, or
something, blocks' worth of setup space.  So, you basically mine these
non-standard scriptPubKeys to the chain, and you continuously do this again and
again and again, filling up each block.  After you fill up enough blocks, you
have your 20,000 inputs to redeem, and then you redeem them all in a single
transaction that is 4 million weight units or roughly around there.  And then,
it will cause the node to basically do a lot of hashing operations as part of
the signature validation.  And yeah, just it takes a very long time on even very
fast hardware to do this.  So, basically, the kind of rationale was this is
probably one of the simplest ways to cut that attack surface down.  Though, I
think in hindsight, it wasn't the best idea, and that was found in the responses
to that specific mailing list thread.  And I think there are more elegant ways,
such as like what Antoine Poinsot is doing right now.

**Mike Schmidt**: Well, he should be joining us shortly.  Maybe we'll pull him
in to comment on that.

**Mark Erhardt**: Yeah, and could you double-click a little bit more on the
responses that you got for this proposal?

**PortlandHODL**: Yeah.  So, the first thing is, the appetite for something that
is permanent, that basically could restrict Bitcoin's capabilities in the
future, was overall low.  That was the big point a lot of people made is we
could need these bytes in the future, publishing STARK proofs, these kind of
things to the chain.  I think somebody came up with like a script-caching
mechanism where you could refer to another outpoint script, or something like
that.  And so, it came down to like, does the benefit outweigh the cost?  And it
seemed like it wasn't an instant no, but also it wasn't like a resounding, "Oh,
this is a free win for Bitcoin to take".  And so, okay, that's good.  And then,
Andrew Poelstra came up with, I think, one of the primary reasons why I don't
actually like this, and this was me being a little bit naive, was it is
confiscatory.  Because my first layer of thought was, okay, well I could just
grandfather in old UTXOs and those would be fine to spend.  But if you have a
chain of UTXOs that you have presigned, that becomes a much more difficult task
to keep track of.  And if you use SIGHASH_SINGLE, or something like that, how do
you prove this UTXO or this transaction was a part of the set it was
grandfathered in?  Otherwise, somebody could maybe just split it off, create a
bunch of out points and then, "Hey, I've got some of these you could use on your
transaction to bypass these legacy limits".

**Mark Erhardt**: Just to be clear, you cannot prove that you had a chain of
presigned transactions.  And even if you allow previously created UTXOs to still
be spent under the old rule after activation of such a new rule, such a chain of
presigned transactions would break, because at the point that the first
transaction is confirmed, the output that is being created was created under the
new rules, and therefore the subsequent transactions can no longer go through.
And that's what PortlandHODL is referring to.

**PortlandHODL**: Yes, that is 100% the point where this kind of tips over, is
you can do a single one pretty easily, but after that it becomes very messy.
And I think the code complexity to put something in, "Is it worth it?" becomes
an interesting question.  Some of the responses as well, I think Jeremy Rubin
stated that maybe this shouldn't be a permanent thing in Bitcoin, and that went
against one of my original theses.  I don't really like the idea of a temporary
soft fork, I'm just not there yet.  But at the same time that was proposed,
maybe we could just do this temporarily.  That was then later used in the
proposal for BIP-so-called-444, what I've seen.  And some other feedback
specifically was that I used the element of the fact that creating smaller
scriptPubKeys, like limiting it, would make anybody who wants to create a lot of
just OP_RETURN data specifically, or some sort of data onchain, they would have
to kind of break it up, right?  And that was like a social selling point towards
individuals who have an issue with "contiguous bytes", for any reason.  And
yeah, I think AJ Towns responded very well with, "Your honour, the bytes weren't
contiguous, therefore I am innocent".  It's not reasonable, in my opinion, to
kind of believe that.

So, yeah, essentially my whole thesis kind of tipped over.  And that's why I did
post that in the mailing list first for BIP2, was I wanted to get feedback.  I
wanted to realize what ways is this good and in what ways was this bad.  And so,
my final note, if I were to want to continue any further on this, would be I'm
much more interested in probably an unspendable policy for anything greater than
520 bytes.  So, you could still possibly publish things onchain.  It just might
not be executable code to the script interpreter, and maybe that would kind of
appease both camps if we might need this data publishing.  But at the same time,
it would nip these DoS blocks in the bud by quite a bit.

**Mike Schmidt**: Well, we sort of alluded to the next item from the newsletter
here.  Maybe Portland, you can help walk us through that as well.  Did you have
anything to wrap up on 520 before we go bigger and badder?

**PortlandHODL**: I guess I would state at this point, I am open to anybody who
wants to take this over or maybe champion this instead of myself.  I don't quite
even believe in the original philosophy that it came up with.  So, as such, open
season on that one.

**Mike Schmidt**: All right, up for grabs on this proposal.  Oh, go ahead?

**PortlandHODL**: I was going to say, I might still pursue it, but if anybody
beats me to it, that's totally okay.

**Mike Schmidt**: Next item, "Temporary soft fork to reduce data encoding".  I'm
not sure I'm pronouncing this right, but Dathan Ohm posted a BIPs PR, and then
also a Bitcoin-Dev mailing list post for the idea around a temporary soft fork
to limit how transactions can encode data.  And as I checked recently from block
934,864 for a period of year, until block 987,424, this soft fork proposes seven
additional consensus rules.  Output scriptPubKeys exceeding 34 bytes are
invalid, unless the first opcode is OP_RETURN, in which case the 83 bytes are
also valid.  Pushes of data larger than 256 bytes are invalid, except for P2SH
redeem scripts.  Spending undefined witness versions is invalid; uses of the
taproot annex are invalid;, taproot control blocks larger than 257 bytes are
invalid, tapscripts using any OP_SUCCESS opcodes are invalid; tapscripts using
OP_IF or OP_NOTIF opcodes are invalid.  And the stated motivation for these
changes is, "To reduce arbitrary data stored on nodes, and to reject the
standardization of data storage as supported use case at the consensus level".

Well, I did reach out to this person to join us today and they were unable to
join us.  So, it's on us to do our best job to describe this.  Murch, maybe you
could start.  Did I outline those consensus rules correctly?

**Mark Erhardt**: I believe you did, yes.  So, I reviewed this yesterday, I left
a few comments.  So, I think the motivation for all of these are that they are
currently used for data embedding in some form or another.  And this is mostly
based on a mailing-list post that Luke Dashjr made in PortlandHODL's thread
where he said, "Oh, if we're going to do this restricting, how about we close
everything?"  And he outlined a few rules that could be introduced to curb these
so-called spam transactions.  And then, the author of this proposal basically
just ran with that set.  Reading through, I read all the comments of other
people too.  It took me like two hours yesterday to read all this and leave my
own.  But the main points seem to be that as with Portland's proposal, there's
several different ways in which confiscatory surface is being introduced.  And
in this case, much more blatantly so, because there are already transactions on
the chain that use deeper script trees.  There are already -- sorry Tadge, hi,
thanks!  So, there's already script trees being used that are deeper than what
is being proposed to be allowed per this proposal.

The limit to 83 bytes on OP_RETURN by consensus is, of course, much more drastic
than anything else proposed so far.  I think I had another.  Which one was the
third one that is confiscatory?

**PortlandHODL**: Potentially bigger scriptPubKeys?

**Mark Erhardt**: Limiting scriptPubKeys to 34 byte is confiscatory with, for
example, bare multisig not working anymore, bare scripts generally not working
anymore.  Yeah, someone else chime in.

**Mike Schmidt**: Well, we did have Antoine join us.  Hey, Antoine.

**Antoine Poinsot**: How are you both?

**Mike Schmidt**: Hey, I wanted to loop you in.  There's a couple things.  Most
timely in this current discussion is your previous work on Liana.  And did I
hear right that Liana users, if, I think it's the OP_IF tapscript usage was
invalid, would affect Liana users as well as potential other users that are
using that sort of construction; do I have that right?

**Antoine Poinsot**: Yes.  So, miniscript uses OP_IF in its language, so any
users of Liana may be using an OP_IF, which now is the case of Nunchuk, that
also supported miniscript descriptors.  It's the case of the Bitcoin Core
Wallet, which supports miniscript descriptors in taproot.  So, there may be
users in taproot that have these opcodes without us knowing it, because
obviously it's in a taproot leaf.  I think it's beyond ridiculous to be
discussing a soft fork to confiscate something that has been deployed in
consumer-facing applications.  Yeah, I'm not sure what else to say.

**Mike Schmidt**: Portland, I saw you had your hand up as well.

**PortlandHODL**: Yeah, I was going to state specifically the miniscript
compiler and the use of OP_IF, OP_ELSE inside of basically the script it
compiles; and that, I'm pretty sure somebody would be able to trigger that
condition with one of their tapleaves that they have.  And as such, also in
general, the surface of which I mentioned, like, "Hey, there could be some
ability to confiscate funds", with my proposal, 520 bytes this takes this to a
completely -- the respondents that stated that, "Hey, this is confiscatory"
generally were like, there could be, it would be very difficult, because it's
not really well used.  There are only 169 transactions that have a scriptPubKey
greater than that size.  But still, it is possible.  With this, yeah, even if
you had, for example, a transaction that is signed with an OP_RETURN in it right
now, or maybe a second order, so a presign into a presign that has an OP_RETURN
greater than 83 bytes, you're going to have to wait a year to spend this
potentially if there isn't some second emergency activation on top, or whatnot.

Following up that one more level, I think some of these decaying multisigs,
where one participant is unlocked, then the next participant is unlocked, but
both participants can spend at the same time, maybe there are scenarios where
you want to give participant A or the first participant, the one that unlocks
first, a chance to spend before the second participant unlocks potentially.  So,
I think that could happen during that year where both timelocks become active.
But at the end of the day, yeah, it is confiscatory during the timeframe that
this is active.  It will be, sorry.

**Mike Schmidt**: Murch, are you back with us?

**Mark Erhardt**: I'm not sure.

**Mike Schmidt**: Okay, we can hear you, we can't see you.

**Mark Erhardt**: My video just stopped and I can't get it back.

**Mike Schmidt**: Sorry, go on, Portland?

**PortlandHODL**: Yeah, I think historically, my first delve into soft forks was
with basically the great consensus cleanup, and why don't we just take care of
OP_CODESEPARATOR?  Why don't we just disable that as an opcode?  Seems pretty
reasonable, nobody really uses it.  One of the first points that was brought up
is it could be confiscatory to disable that, because somebody could have it
behind a hash if you turn it off.  And to see the care and how delicate people
were with that situation in case of that one transaction, to this kind of
proposal where it's pretty overtly stating we are willing to sacrifice the
ability for people to spend during a timeframe under the statement that they
will be able to spend eventually, so it's not permanent, but it's a very
different dynamic than what I've previously seen.

**Mike Schmidt**: Murch or Tadge or Gustavo, do you have any comments on the
proposal?

**Mark Erhardt**: Yeah, I'm sorry, you probably have covered it, so stop me if
you did.  But the other confiscatory thing that I thought was really bad was,
there are several wallets that are using miniscript and are using descriptor
patterns already.  You covered that?

**Mike Schmidt**: Yeah, we did.  We did discuss that.

**Antoine Poinsot**: Anyway, that is such a non-starter.  This is an absolute
no-go from a protocol design perspective.  We don't break user space.  Just, no.

**Mike Schmidt**: Murch, what are your thoughts?  I know when we did the policy
series that you and Gloria put out a few years ago, one of the things that
wanted protection was future upgrade hooks, and it looks like this proposal is
trying to enshrine that in consensus.  Do you have a particular thought on that
angle?

**Mark Erhardt**: Yeah, so the argument that they're introducing a temporary
soft fork that is only restricting the blocks in that certain period, I actually
wanted to jump into temporary soft forks, but maybe we can do that later.  But I
think it's fairly reasonable not to expect that another soft fork would activate
within a year, because traditionally those efforts just do take longer.  But
also, it's just outright ridiculous to make that assertion while deploying a
soft fork within three months yourself.  If you can deploy your emergency soft
fork that introduces seven arbitrarily-motivated new consensus rules that have
all sorts of gaps already, not locking down everything as proposed, why should
it be so hard to activate another soft fork in 15 months, and what gives you the
right to decide that for everyone else?  I think that's just another really
poorly thought-out aspect of this proposal.

**Mike Schmidt**: Yeah, Portland?

**PortlandHODL**: I want to ask Antoine, because maybe you know a little bit
more on this.  My proposal of 520 bytes does some amount to curb a DoS block, a
poison block of the kind of known type.  Would something like this, with such a
restrictive scriptPubKey size, completely eliminate the DoS block from a network
block propagation perspective?  Or are there other ways that somebody could
still, within the scope of this temporary soft fork, produce one of these
blocks?

**Antoine Poinsot**: So, I didn't run the number with the 33 bytes.  I did run
the number with the 520 bytes that you proposed, but not with the 33.  But my
hunch is that I strongly suspect it would still not be enough.  You need either
the bundle proposed by Matt Corallo to disable, find, and delete
OP_CODESEPARATOR and other things, or you need to limit on the transaction size
or the number of sigops per transaction, or legacy sigops.  This is what I
strongly suspect, but I didn't run the number.

**Mike Schmidt**: Murch, anything else you think we should touch on here?  Did
you want to go into the temporaries?  Oh, did Murch drop?  We lost Murch again.
Okay, well we can maybe jump back to temporary soft forks in a bit.  I think
that's maybe good on this item, but there was mention of no other soft forks
that appeared mature or potential to be ready to activate in the next year.

_BIP54 implementation and test vectors_

That somewhat leads to our next item, which is, "BIP54 implementation and test
vectors".  Antoine, you posted to the Bitcoin-Dev mailing list an update on the
consensus cleanup, BIP54.  Maybe you just want to provide us the latest, what
was in there, and then we can also maybe get an idea of how ready BIP54 is.

**Antoine Poinsot**: Yeah, well, I'm happy to say that I feel like we're getting
there after two years.  I published implementation, I publish test vectors, on
which I spent a long time to try to make sure that they can be run on
alternative implementation of Bitcoin and Bitcoin Core, and that they are as
close as possible to the main network.  Because a lot of the modern soft fork
proposals concern themselves with the scripting system or transaction level
stuff, which is very reasonable to be testing on a regtest or on testnets.  But
some aspects of BIP54 touch on very, very much mainnet-specific aspects, such as
the proof-of-work (PoW) settings, the difficulty adjustment settings, the
retarget periods setting.  And for instance, the time warp fix and the merge
that we fixed are tuned to these mainnet parameters.  So, that's what I tried to
do with my test vectors.  I went as far as mining mainnet blocks from the
genesis to mine different chains of headers that exercise on mainnet the
attacks, and how they are prevented.

**Mike Schmidt**: So, how did you go about doing something like that?  What was
the infrastructure to set up that sort of test?

**Antoine Poinsot**: So, obviously, I branched from the genesis block, so I
didn't have to run an ASIC, but I just wrote a C++ miner, a very simple one, in
the Bitcoin Core codebase, that would mine 2,016 blocks, headers, block headers,
and along the way it would branch off with different chains of headers with
different timestamps.  And then, when coming to the 2,016 headers limit, which
is the retarget period, I would mine a number of different chains with different
blocks at block 2,014, 2,015, 2,016, in order to make sure that an
implementation does not have an off-by-one, such as Satoshi had in the first
place, or that we have exactly the same bounce checks, like it's that the
timestamp check is a superior equals to and not a superior, a strictly superior
to, which would be consensus failure otherwise.

So, that's what I did, and I shared the code of the miner, which is probably not
the most interesting, but it's always good to share the code that you use to
generate the test vectors of your BIP.

**Mike Schmidt**: We also covered the fact that you opened up BIP54 consensus
cleanup implementation to Bitcoin Inquisition.  What is the idea there?

**Antoine Poinsot**: I think we reached a stage where it makes sense to deploy
BIP54 on a test network, and Bitcoin Inquisition is the test network for
consensus changes.  We have other major proposals there, such as ANYPREVOUT
(APO), CHECKTEMPLATEVERIFY (CTV), and I think it makes sense to have BIP54.
It's kind of a step-by-step before starting to even discuss an implementation in
Bitcoin Core.  Well, potentially some people have been telling me about
activation stuff, but I don't want to rush things.  I think it's important to
have it in Bitcoin Inquisition, have it bake here for a while and maybe try to
set up some attacks in some way.  It's hard to do because you don't want to give
away the specific issues with the worst blocks.  So, we can only try to make bad
blocks, but that are not exactly the very worst one; can we try to craft
different blocks that are trying to exploit the timestamp-related
vulnerabilities?  So, that's where we're at.  Pretty happy with it.  I'm trying
to do some outreach as well to raise awareness that the work is closed,
complete.  And yeah, I have good hope that we can run it on the test network
soon.

**Mike Schmidt**: How has feedback been during your outreach?  Are people
supportive of the idea?  Is there a common objection that remains?

**Antoine Poinsot**: No, I think, well, which is pretty on topic, I think the
main objection to this proposal, when Matt originally made it in 2019, was the
confiscatory surface of his proposed change.  He proposed to remove
OP_CODESEPARATOR and various other obscure features of the scripting language.
And some Bitcoin developers raised maybe not quite objections, but concerns
about the theoretical possibility about confiscating some users' funds.  And I
think the concerns there were mostly philosophical.  In practice, it was not
going to affect anybody and nobody was going to use OP_CODESEPARATOR in a
timelocked presigned transaction for which they had thrown away the key.  But I
think it's the right way to think about how to design Bitcoin, to try to go at
length to try to not fuck with other people's money, which I think is in very
stark contrast with the modern script kiddie soft fork designs these days.  I
shouldn't call it BIP444, how do you call it, Murch?  Data Storage?

**Mark Erhardt**: RDTs.

**Antoine Poinsot**: RDTs, yeah.  So, this was the main concern raised,
objection to the proposal, and it was addressed.  Like, one of the main points
of my revival of this proposal was to find an alternative mitigation for the
worst block that did not involve making some script features invalid.  And so,
that's why I have, in BIP54, a limit on the number of sigops in a transaction
instead, which -- well a soft fork is always going to make some things invalid.
But what my proposal is making invalid is exactly the very type of transactions
that are harmful, exactly what it pinpoints, exactly what we want to make
invalid.  So, this was one concern that was addressed.

I also had maybe some discussions around the 64-byte transaction invalidation.
For instance, there is an interesting discussion on Delving Bitcoin between Eric
Voskuil, AJ Towns, and myself on the argument for invalidating the 64-byte
transactions.  So, Eric Voskuil objected to it, but he said that it was not a
blocker for him.  But the way AJ put it is that he improved our arguments,
because he pointed out that some of the arguments that we were making were not
precise enough, were for some of them incorrect.  So, I think the arguments
still stand, I think it's still good to invalidate the 64-byte transactions, but
the rationale in the BIP is stronger now.  And then, yes, and then there was
also, early on, a soft objection from Sjors Provoost on the grace periods in the
timewarp fix.

So, in the timewarp fix, at the boundaries of the difficulty adjustments, you
tighten the timestamp restrictions.  And Sjors was making the argument that it
was too tight, and it could potentially lead to miners creating invalid blocks,
which is something we try to avoid as much as possible in soft fork designs.
And I was not convinced by the arguments, but I was convinced eventually by the
asymmetry.  We could increase the grace period, so let's say the safety margin,
from ten minutes to two hours, and for like very, very, very, very small
deterioration in the fix.  So, I just went with Sjors' suggestion and updated
the grace period to two hours.

**Mark Erhardt**: Yeah, maybe just to jump in here briefly.  Sorry, I had
technical issues.  I'm back.  The grace period being around the limit of how
much we allow for the times to be off in the other direction just seems a little
safer, more conservative.  And the attacks that we described, like the Zawy
attack, the timewarp attack, Murch-Zawy attack, they rely on it being way, way,
way bigger amounts of time that you can offset your timestamps and blocks at.
So, with the two-hour difference at most, the attack becomes impossible, but
it's still more conservative and satisfies some reviewers.  And I think just to
be a little more meta, working on a fix that is almost completely
uncontroversial for several years to make sure that you get it exactly right,
because you're going to restrict consensus rules, is in stark contrast on how
some other people are currently proceeding on consensus design.

**Mike Schmidt**: Antoine, one thing came up in our discussion in the podcast
last week, actually.  Is it exactly 64 bytes that is disallowed?

**Antoine Poinsot**: That's also an update from Matt's proposal.  Matt's
proposal was going with the currently enforced and honest rules, which make
transactions 64 bytes and smaller invalid, which is I think the smallest
possible transaction size is 61 bytes, so it would make 61-, 62-, 63- and
64-byte transactions invalid.  And my proposal is to only make the least amount
of change to consensus as is necessary, so to only invalidate 64-byte
transactions.

**Mike Schmidt**: Murch, before you had technical difficulties, you were maybe
wanting to bring up a discussion of temporary soft forks?  Did you want to do
that?

**Mark Erhardt**: Yeah, let me briefly point out the minimal valid transaction
needs 60 bytes according to Vojtěch on Stack Exchange.  We had that answer, I
think last week.  And regarding temporary soft forks, so a few people have
brought up the argument that a temporary soft fork contains a rule-tightening
and a rule-loosening.  And because loosening rules allows blocks that were
previously invalid, and we usually, if they're done by themselves, refer to them
as a hard fork protocol change, a temporary soft fork would appropriately be
described as a soft fork plus a hard fork.  And I want to argue that this
perception is incorrect, because if you specify a soft fork from the get-go as
only applying to a certain number of blocks, be it like, "This one block cannot
have more than five transactions", would be a temporary soft fork.  And I think
nobody in their right mind would argue, "Oh, if we allow more than five
transactions in the block after, that's a hard fork", right?  And the same
principle applies here to the design of a temporary soft fork.  If you
temporarily restrict what is allowed in blocks and the rules include an end time
to when those restrictions dissipate, this is only a tightening of the rules
that applies to a predefined number of blocks.

So, I don't see where there is a hard fork here, unless you are talking about
people deliberately not implementing the actual specification of the proposal,
which is it ends at a certain height, as part of the specification.  If you
assume, "Yeah, people are not going to follow the specification and there's
going to be contention on whether or not to loosen the rules at the end of it",
then yeah, there might be a network-split risk at that point, because some
people continue to enforce the rules and some people don't.  But if you're just
analyzing the specification, it's simply a soft fork.

**Mike Schmidt**: Makes sense.  Tadge, we've had you listening along, and I'm
just curious if around any of these data restriction or consensus cleanup items,
you have any thoughts to impart on the audience?

**Tadge Dryja**: Sure.  Data restrictions, not really.  Consensus cleanup, I
think it's important, at least for stuff I'm working on.  Utreexo has a big
problem with BIP30.  it can't really enforce it, it's kind of a mess.  Oh, can
you hear me?

**Mark Erhardt**: Yeah, you're just very quiet for me.

**Tadge Dryja**: Okay, let me let me turn it up.  Is this better?  Okay, cool.
Um, yeah, so with utreexo, which is something I've been working on and other
people, you don't have the whole UTXO set, it's very difficult to comply with
BIP30.  And this is something that wouldn't be relevant for another decade or
more, I think, but a soft fork to finally fix once and for all the BIP30, BIP34
kind of mess would be nice, because then I wouldn't have to worry about this.
It's like a really out-there problem.  It was like, a miner would have to
intentionally lose their mining reward in 12 years from now, or something, and
try to make this weird transaction.  It's still like, most of the things in the
consensus cleanup are pretty like not huge threats right now, which is good, but
I'm like all for it.  And it's like, yeah, let's fix the BIP30 thing.  It's kind
of a mess.

**Mike Schmidt**: Antoine, as we circle back and wrap up on your item, any calls
to action for listeners on BIP54, BIP54 implementation, potentially on
Inquisition, outreach or evangelism of that particular soft fork, or anything
else that you have folks put their attention and time towards?

**Antoine Poinsot**: Yeah, sure.  If you think it's something that is important
or even if not the most important, something that is worth doing, try to talk
about it around you, try to talk about it at your local Bitcoin meetup, try to
talk about it on Twitter, to your Bitcoin friends, to everybody.  I'm not going
to be doing a whole, "Let's activate BIP54", round.  I don't believe that
changing Bitcoin should be a one-man effort.  So, it needs to be more people.
So far, the feedback that I've received is that, "Yeah, it makes sense.  Yeah,
we should do it".  So, I just need more people to create a momentum for it to
actually happen, because otherwise if we don't activate it, it would have been
for nothing.

**Mark Erhardt**: Yeah, so what do you see as concrete things that people could
help with?  I think maybe reply to your mailing list post and, say, offer
support.  Should someone start designing an activation proposal, or would you
see that as a different, separate BIP?  How do you see the responsibility there?

**Antoine Poinsot**: I think in terms of rippling effects, I think we need to
reach the next broader group of users.  For instance, I've recently spent a week
with Bitcoin developers and academics, and a lot of academics were not aware of
half of the vulnerabilities that we fix in BIP54, and they work on
Bitcoin-related stuff.  So, we need to raise awareness in broader groups.  I'm
sure a lot of users are not aware of these vulnerabilities and weaknesses in the
protocol.  So, I think raising this awareness and letting them know that there
is a proposal to fix that, that has been worked on for the past two years and is
getting mature, would help, more so than starting to discuss activation.  I
think it's premature to discuss activation.

**Mark Erhardt**: Thank you.

**Mike Schmidt**: Yeah, Portland?

**PortlandHODL**: (audio missing)

**Antoine Poinsot**: Yeah, so indeed, the coinbase transaction is not part of
the getblocktemplate response, written by Bitcoin Core, and it's crafted by
mining pool software that is usually close-source and hard to reach.  So, I've
been chatting with some miners in order to be forward-compatible, in the same
way that we introduce standardness rules for some scripts that may be
invalidated in a soft fork in the future.  I'm trying to reach to miners to be
forward-compatible and set the nLockTime in the coinbase transactions to be
forward-compatible.  So, that's one reason why I'm saying that it's premature to
talk about activation.  So, we need pools to be forward-compatible.
Fortunately, I've got very positive responses from the mining pools I've been
discussing with.  For instance -- sorry, you were going to say something?

**Antoine Poinsot**: Yes, MARA has been proactive in supporting the development
of BIP54 by stopping to use nLockTime field for other purposes.  And so, they
are not yet forward-compatible in that they do not set the nLockTime field
correctly, but it's a smaller change than what they already did in order to
support BIP54.  But I also discussed with other mining pools that are supportive
of the effort.  And one thing that maybe is worth highlighting here in the
context of other people proposing, I would say, unadvisable consensus changes,
is that some of them are trying to reach the mining pool to force them or
threaten them into enforcing the new consensus rules.  This is not what I'm
doing.  I'm trying to make them forward-compatible, and I want to very much
separate the activation and forward-compatibility discussions with the miner.  I
will not be reaching out to miners to activate.  I'm reaching out to them to
tell, "Just create forward-compatible blocks.  It's had no cost for you today,
except the development, and of course the risk that goes with any change to a
software.  But it's not going to make your blocks relay less efficiently, it's
not going to use space in your blocks.  Just make them forward-compatible in
case Bitcoin users decide to activate a soft fork in the future".  Because I've
before had suggestion to have the activation mechanism use the nLockTime field
in the coinbase transaction as a readiness signal.  But I want to separate the
two concerns so that it's clear from a political perspective.

**Mike Schmidt**: Okay.  Well, I think listeners have some idea of some calls to
action here.  And, Antoine, it seems like there's still a good amount of work to
be done.  Obviously, you're taking the approach quite slow and steady.  Yeah, I
think we can probably wrap up that consensus item, Murch, yeah?  All right.

_Post-quantum signature aggregation_

Moving on, "Post-quantum signature aggregation", via OP_CHECKINPUTVERIFY
(OP_CIV).  Tadge, you posted to the Bitcoin-Dev mailing list a proposal for
OP_CIV that enables a locking script to commit to a specific UTXO being spent in
the same transaction, enabling a group of related UTXOs to be spent with a
single signature.  One, did I get that right; and two, maybe you want to walk us
through this?

**Tadge Dryja**: Sure, yeah.  So, it's post-quantum, I guess.  It kind of has
nothing to do with quantum anything, except for it's kind of useless unless
you're worried about quantum computers, I think.  The motivation is, there are
post-quantum signatures, there's a bunch of things that work against quantum
computers.  Like, SHA256 is pretty much safe against quantum computers.  I mean,
there's Grover's algorithm, but against the Shor's algorithm, which is the thing
people would worry about.  And so, it's like, "Oh, we could potentially switch
to a new signature scheme".  People have talked about that with BIP360, things
like that.  One of the -- the main downside, I think, not one of them, the big
downside is these signatures are much larger.  So, there's hash-based
signatures, lattice-based signatures, but all of them are significantly larger
than the signatures we use today.  So, some of the hash-based signatures, the
defaults, we can probably get it down into the low-kilobytes range, maybe 2 or 3
kB, but still that's, that's 2 or 3 kB for a signature that currently costs 64
bytes.  So, that's a big problem.

So, it's like, well, do you increase the witness discount if you were also --
you know, these are all pretty theoretical, I'm not too worried about quantum
computers showing up anytime soon.  But it's interesting to sort of game it out
and say, "Well, what would we do if this were a problem really pressing?"  And
so, you could have a debate like, "Well, we should increase the witness
discount", because the signatures are so much larger, we'd need a lot more
space, a lot more block size, sort of how segwit increased the witness size.  We
could do that again with a different soft fork.  It would kind of be a mess.
It'd be great to avoid that, and avoid that controversy.  And so, this doesn't
directly reduce the size of any of those signatures, and it doesn't actually
affect those signatures.  But what it does is allows you to have multiple inputs
sharing a signature.

So, I called it cross-input signature validation, but I also was like, "It's not
really that", right, because people have been working on cross-input signature
aggregation for a number of years.  And that's a sort of elliptic curve specific
thing that uses similar ideas to MuSig and FROST, where you can say, "I'm going
to have one signature that sort of is a combination of all these signatures".
So, if I have three inputs in a transaction, there's three different pubkeys, I
can have them cooperate and create a single signature that sort of covers the
whole thing.  And that's really cool.  That wouldn't work in the post-quantum
signatures we're looking at right now.  There isn't really any well-defined
thing where you can say, "Oh, I'm going to combine these three hash-based
signatures or combine these three lattice signatures".  Or let's say someone is
saying it is potentially possible with lattices, but I'm fairly skeptical
because like with the elliptic-curve-based schnorr signatures, we thought it was
easy around 2018, 2019, it was like, "Oh, you just sort of add them up", and
then it took like five years of figuring things out.  And so, with the lattices,
someone's like, "Oh, there's potentially a paper that says it may be possible",
to me means, "This is going to be very hard".

So, what the opcode does is it basically says, "If this other input is in this
transaction, I don't need a signature", right?  If this evaluates to true, then
I'm good.  And it's sort of like, well, how does that work?  So, if you're a
wallet, when you're generating a new address, you would commit to your other
UTXOs that exist in that wallet in your address.  So, if it's taproot style,
you'd have a tree and maybe at the top of the tree, you'd have some hash-based
pubkey or something.  And lower down, in different branches of the tree, you'd
have commitments to your other UTXOs that are in your wallet.  And then, when
you're spending, if you spend one of those UTXOs at the same time, that UTXO
signs, but the one that you just made an address for doesn't have to sign,
because it can just sort of point to it.  You sort of reveal that that UTXO
belongs to the same wallet.  And since you're using SIGHASH_ALL on that first
one, and since it's UTXO-based, I don't think there's really any problems with
like replay attacks.  You could try to contrive a way, but you'd have to do it
yourself.  And this would reduce the total signature size.  So, if you have a
bunch of inputs, you know, five or six inputs, and they do all have these
pointers, then you can just use one signature, so 3 or 4 kB for the whole
transaction.  So, that'd be cool.  That would save a lot of space and also
verification time.  The verification is very simple because it's just, "Look at
this transaction.  Is this UTXO being spent?  Yes.  Great".

There are some downsides.  I feel like most of the downsides would be in
implementation complexity for a wallet, because it makes wallet recovery, like
if you have a seed phrase or something like an HD key and you've lost all your
wallet data, and you need to recover it and sort of look through the blockchain
and find all your UTXOs, it significantly makes that harder, not impossible.
It's all still deterministic, but it's deterministic based on a lot more
factors.  And so, it's like, okay, I can generate ten addresses from my seed
phrase, but then my addresses are different because they start pointing to the
different UTXOs.  So, as soon as I see a UTXO on like address 0, I'm like,
"Well, did address 1 get generated before that UTXO or after?  Because if it got
generated after it, it would change the address.  And so, it kind of blows up
and makes it a little complex.

So, the implementation for the wallets would have to sort of say, "Don't point
to all your UTXOs, only point to some subset and do it in a sort of standardized
way so that we can recover it without grinding through millions or billions of
addresses".  So, that point's a little complex.

**Mark Erhardt**: I was going to say, if you make your UTXO spendable by all of
your other UTXOs, then would that chain?

**Tadge Dryja**: You can't chain because that would be a hash cycle.  Or you
could chain, in that you could have like A points to B, B points to C, C points
to D and D signs.  That should be fine.

**Mark Erhardt**: That's what I meant, yeah.

**Tadge Dryja**: But D can never point back to A because that would be a hash
cycle.

**Mark Erhardt**: Right, you can always only point at UTXOs that already exist,
right?  But so, you wouldn't have to point at every UTXO that precedes it, maybe
just the last ten or something.

**Tadge Dryja**: Yeah, you'd want to limit it.

**Mark Erhardt**: Because otherwise, you would also leak, by the height of your
tree, how many UTXOs you have, which seems kind of problematic.

**Tadge Dryja**: Yeah.  So, so you could leak that.  One of the parts of the
proposal is there's a field that's sort of a nonce or blinding factor that has
no consensus, meaning it doesn't do anything, it's just dropped.  But there's
also potential attack where you try to grind through.  It's like, "I think this
is also this guy's UTXO", and you can sort of try to see what else is in the
taptree.  So, you want to blind them.  And then, you want that blinding factor
to be deterministic, so it'd be sort of like an RFC 6979 style thing.  So, I
think it's cool idea.  The wallet implementation, I think it's totally doable.
And the thing is, worst case, you don't use it, right?  Worst case, it's like,
"Oh, I have to have two signatures", and not the end of the world.  But you
don't want to get yourself into a corner where it's like, "Oh, I had this
exponential blow up, and it's going to take months of CPU work to try to figure
out what addresses and UTXOs I had".  So, you want the wallets to sort of limit
it to some reasonable blow-up factor where you can search, and I think that's
totally doable.

If this ever did become a thing and people were looking at it as part of a sort
of quantum-safe potential future fork or something, then we'd probably want to
make some like specifications of like, "Hey, you should do it this way for
wallets".  Because you don't need to have tons.  It works great if you've have,
I think, a lot of individual wallet usage it plays well with.  Potentially with
exchanges, it might not work as well.  If you're sort of like, "I want to
generate a thousand addresses right now and then use them", then they can't
really point to each other's UTXOs.  And so, that's a downside.  But I think for
a lot of usage patterns, it would work pretty well, and you'd probably end up
just having like one, or worst case two, signatures per transaction instead of
four or five or six, or however many you need.  So, for consolidation, it'd be
really nice.

So, I think if you're going to go down the road of like, "Okay, let's look at
different signature types and post-quantum stuff", this is a nice tool in that
set.  So, if you do end up, who knows, 10, 20 years from now saying, "Hey, let's
do a post-quantum soft fork", this might be a component of it.  Or maybe people
think of something better.

**Mark Erhardt**: Yeah.  So, there's some interesting aspects here, but the
address-generation one caught me a little off guard just now.  I realized that's
actually pretty horrible if you make the addresses deterministic based on the
UTXOs you have at the time of when you generate them, and then you hand them out
and people might use them way later.  So, in a recovery scenario, how would you
even know what UTXOs you had?

**Tadge Dryja**: So, worst case is 2<sup>n</sup>.  If you have n UTXOs for all
of your addresses, it's 1 bit for each.  But that is worst case.  That's if you
just randomly do it and you have unlimited.

**Mark Erhardt**: Well, at least the UTXOs are clearly ordered, so that would
help.

**Tadge Dryja**: So, you have order.  You can also just say, "Look, I'm going to
point to the three most recent", or something.

**Mark Erhardt**: That would be problematic, right, because you don't know which
ones the most recent are.  You should probably be more like, "I'll point at the
oldest three that I still had", or something.

**Tadge Dryja**: Yeah, you could point at oldest.  So, there's a bunch of
different ways.  And if it's only 3 and you've only ever had 10 or 20, then it's
like, Oh, it's, 2<sup>20</sup>.  But the numbers do get big.  Worst case, the
numbers get unfeasibly large, and it's like, "Oh, I have 50 UTXOs, and I
randomly picked".  Yeah, you can't really grind through that, you know, it's
2<sup>50</sup>.  So, you do need to sort of standardize and keep it small.  And
it depends on the usage.

**Mark Erhardt**: Yeah, I think I like the idea with CIV, especially if we're
talking about really big scripts.  Obviously, if we're talking about regular
P2TR schemes right now, these script trees will be so much bigger than a P2TR
that it wouldn't make no sense.  So, very specifically for very, very large,
locking scripts or unlocking scripts, this might be interesting.

**Tadge Dryja**: Right, today, a signature is 64 bytes, the proof alone is going
to be at least 64.  So, there's no point in this right now.

**Mark Erhardt**: But the address-generation thing, that sounds a little scary
to me.

**Tadge Dryja**: Yeah.  If you have lots of different UTXOs spread out over time
and you use them, it can make it difficult to recover.  So, I think part of the
next step is then, okay, let's find some good algorithms that are pretty
conservative.  And even if you kind of have a wild wallet, they can still
recover in a reasonable amount of time.  And having talked to people last week
about other post-quantum hash-based signature schemes, recovery from seed
entropy is an issue in a lot of these, because a lot of these different schemes,
it's like, "Oh, you can do all these cool optimizations, but you lose it if you
forget this extra data you're saving".  And that is the case here as well.  If
you keep all your data, there's no problem at all.  But if you're like, "Oh, I
just have this 32 bytes, my seed phrase or whatever, and I need to recover from
that", it gets tricky.

So, yeah, and people wrote on the mailing list, "What if you had addresses point
to addresses?" that would kind of make this problem less.  I think technically
it works.  I don't have a good theoretic, like a good mathematical argument.  It
feels a little worse in that it feels like it's encouraging address reuse, and
this one discourages address reuse, because if you want to get the benefits of
this and save fees and space, you really want to generate new addresses each
time, because if you don't, you can't use it.  And if you're going to generate a
new sort of root address, you might as well change the pubkey as well, right?
And so, you rotate through all the pubkeys and make them hard to detect.  So, I
think I like that aspect of it, in that it encourages people to not reuse
addresses.  But at the same time on the mailing list, people are like, "Hey, if
you have addresses point to other addresses, that might actually be a little
smaller and work better".  So, it's sort of a privacy and utility trade-off
there perhaps.

**Mike Schmidt**: Tadge, this is a single party doing these operations, right?
Have you ideated on a way to tweak it to enable multiparty?

**Tadge Dryja**: If you had a multisig output, you could point to that.  If it's
just someone else's output, then no, because you once you point to it, they can
resign, change the transaction.  You're basically giving them your UTXO at that
point.  But if it's like a 2-of-2 multisig, you could have a quantum-based proof
signature that you just use 2-of-2 multisig with.  And then you could point to
that UTXO, and it's still safe because you've signed it, so you're not going to
sign a new transaction.  Yeah, so I think I think it's fine if you're pointing
to multisig where you're a participant.  And if there are later some types of
multisig, like aggregate things the way that MuSig works today in schnorr
signatures, then you could point to that as well.  But I'm mostly thinking of it
in terms of one person has a wallet and they point to their different UTXOs.

You could chain different OP_CIVs.  You could require two.  You could say, "I
need to point to this input and this input", if there's two different keys, or
something, I don't know.  And I also mentioned another thing, there might be
some weird covenant-y thing you could do with this.  I didn't think of any, but
it is basically introspection, potentially leads to some kind of covenant you
could do, but that was not the goal.  The goal was sort of like, "Oh, if you
have huge signatures, this can save space".

**Antoine Poinsot**: Covenant wise, I think it enables the BitVM trick to get
rid of the presigned committee with something else than CTV.  Because CTV
commits to the scriptSig of the input spent at the same time as the UTXO where
the transaction is committed to.  Our design for OP_TEMPLATEHASH does not
do this.  It prevents the BitVM trick.  But I think in conjunction with your
proposal it might, just nothing.

**Tadge Dryja**: Okay, cool.  Yeah, I was like, "I bet this does something".  My
personal thing is I'm cool with OP_CTV and a bunch of these introspection
things.  I think they're great, and I would support them.  But yeah, so to me,
that's not a downside.  But If that's part of it, cool.

**Mike Schmidt**: What are next steps, Tadge, and what should the listeners
know?

**Tadge Dryja**: I don't think there's any immediate next steps.  I think it's
just sort of this thing where in the last year or so, a bunch of people are
like, "Hey, how would you do quantum stuff?"  And I don't think you need to
write a BIP yet, there's no rush, but I do think it's interesting.  I've gotten
nerd-sniped by it, because I think it's interesting like, "Hey, elliptic curves
don't work anymore.  How do you make Bitcoin work?"  And it's like, "Oh, well,
you could do all these different things".  And it's kind of fun, because pretty
rapidly, in like the space of less than a year, it seems like, yeah, you could
do this, there's a lot of things you could do.  So, I think people are just
looking at different signature types, different mitigation types and stuff.  So,
I'm not like, "This is something we need to do right now".  No, this is decades,
kind of thing.  But I hope that in the next few years, we will get a like, "Hey,
here's a bunch of tools we can use, a bunch of wallets".  Who knows?  Maybe
we'll make like a post-quantum testnet at some point in the next couple of years
and play with that.  That'd be cool.  But don't panic, this is not something we
need to worry about right now.  But it's great if it ever does become something
we need to worry about, then we've got a lot of solutions.

**Mike Schmidt**: And you had, what was it, what was the final name, Life Boat,
that you had Life Raft?

**Tadge Dryja**: Yeah, that other commit reveal scheme as well, yeah.

**Mike Schmidt**: Yeah, so you have been nerd-sniped.

**Tadge Dryja**: So, it's something I ended up working on just because people
are talking about it.  I'm like, "Oh, could you do this?"  It's kind of fun, but
not something that's going into Bitcoin in the next couple of years, I don't
think, which is good.

**Mark Erhardt**: Tadge, while we have you, we actually also have another
cryptographic proposal that we have on our newsletter.  I don't know if you
heard about the native STARK proof verification in Bitcoin Script?  That's
another topic we have here.

**Tadge Dryja**: Oh, I saw the headline, but I haven't read through how it works
or anything.

**Mark Erhardt**: So, I just wanted to curb that you drop off because you're
done with yours.  We might want to pick your brain on that one too.

**Tadge Dryja**: Sure.  I mean, I'll stay on, but I don't know if I have a ton
to add to there, but I'll definitely stay on.

_Native STARK proof verification in Bitcoin Script_

**Mike Schmidt**: All right, we can transition to that now.  This is the last
Changing consensus item this week, "Native STARK proof verification in Bitcoin
Script.  This is from Abdel from StarkWare, who posted to Delving Bitcoin a
detailed proposal for a new tapscript opcode, OP_STARK_VERIFY, which enables
verifying a specific kind of STARK proof in Bitcoin Script.  "The goal is to
enable onchain verification of a zero-knowledge proof with transparent
post-quantum-secure assumptions, without resorting to ad-hoc script encodings
(like OP_CAT) or enshrining a large family of arithmetic opcodes".  And so, the
ability to have zero-knowledge proofs verified in Bitcoin could allow things
like post-quantum signatures, additional privacy features, or sidechains that
use zero-knowledge proofs, like validity rollups that we've discussed
previously.  Other people are also trying to achieve similar functionality using
BitVM now, for example, but BitVM has the complexities of offchain computation,
the whole onchain challenge mechanism, and then the lockup of capital and
additional trust assumptions, and whatnot.  And there's also some other
competing ideas to use something like an OP_CAT opcode in very inelegant ways to
do this sort of STARK verification as well.

Abdel's OP_STARK_VERIFY cuts right to the chase.  It's a single opcode that
would be focused precisely on zero-knowledge verification in Bitcoin Script,
which would be much more efficient than these other techniques and
straightforward when compared to some of the other solutions.  We can get into
some of the use cases, maybe I'll pause there as an overview.

**Mark Erhardt**: Yeah, maybe let me jump in here first.  So, generally the
design philosophy around Bitcoin outputs is that we don't want to run tons of
computations onchain, like some other popular blockchain protocols, but rather
the style has always been we prove to you that we did it right, and then it goes
through.  So, we only provide a witness sort of construction that authorizes our
payment and nobody has to know what exactly under the hood was going on, whether
there was some oracle signing, or whether there's an aggregated public key that
multiple people signed, or something.  The design decision in Bitcoin is always
that that sort of stuff should happen offchain and not be computed by verifiers.
So, in that sense, having an out-of-chain complex computation that can prove
arbitrary things, and then just having a proof onchain that shows that it was
done correctly, would fit pretty well.

What I, looking into this a little bit, found not shocking but dissuading, is
these proofs, at least in this initial proposal, would be really large, hundreds
of kB to 1 MB per proof.  And the verification times for these STARK proofs
would also be pretty slow.  So, we're looking usually at block validation times
of less than 0.1 seconds on standard hardware.  And these proofs, also Antoine,
correct me, I think you know more about this if that's incorrect, but these
proofs would look at tens of milliseconds on standard hardware.  So, if you had
one of these, maybe two of these, they would take as long as we usually want a
whole block to take in validation time.  And so, those two things, they kind of
seem a little dissuading at this point. If the design gets better, they get
smaller, or maybe in the context of Glocks; we had Liam Eagan on a while back to
talk about the garbled circuits, where the proofs were much smaller.  So, if it
got smaller and computationally less intensive design-wise, philosophy-wise, I
think it sort of would fit pretty well.

The other big question is, of course, what sort of things this would enable and
would this, for example, enable a lot of MEV, or other concerns like that, these
second-order effects, where we have seen other blockchain systems become very
top-heavy, where value transfers on second layers became so much larger than on
the base layer that basically, the second layer started dictating base-layer
development and consensus, and also just completely changed minor revenues so
that, for example in our case, some of the incentive structures that we rely on
for Bitcoin to be stable might be subverted.  So, yeah, complex topic.

**Antoine Poinsot**: Just to jump in, I think the block validation time, the
average block validation time on reasonable hardware is about right.  I didn't
run the numbers, but I expect it to be about 100 milliseconds, as you said.  I
agree with you on the block validation time.  So, the reason Murch mentioned it
is because block validation time plays a role in mining centralization, because
it might increase the block stale rate.  But I think there is also a second
aspect, which is these transactions, if they are too large or if they are too
computationally heavy, might not be able to be relayed on the transaction relay
network.  And this is also a source of mining centralization, because it means
that these transactions would not be accessible to a new miner joining the
network and just plugging themselves on the public relay network.  So, it's a
source of fee revenue that would not be accessible, or maybe it would be
accessible only through specific portals.  So, that's also a concern.  If a
transaction is going to take 1, 2 seconds, or maybe 5 seconds to validate,
that's completely unreasonable to propagate it on the network with no PoW
attached.

**Tadge Dryja**: I had one question about verification time.  Murch, you say it
was like tens of milliseconds to verify the proof?  So, how do we get to from
there to many seconds?

**Mark Erhardt**: Right, so if one of these is 100 kB and takes tens of
milliseconds, let's say 50, you could have five seconds, sorry, half a second.

**Tadge Dryja**: So, you just fill the block with them.

**Mark Erhardt**: Right.  Or, I think the size scales, what was it, sublinear
with computation.

**Tadge Dryja**: Okay.

**Mark Erhardt**: So, 1 MB proof would be more than linear time increase from
100 kB.

**Tadge Dryja**: Right, yeah, so maybe you want to limit the max size, or
something.

**Mark Erhardt**: Yeah.  Oh yeah, I did read this earlier today.  Abdel did
suggest that it should first be limited to 100 kB, I think.  And so, that, that
would mitigate this concern to some degree.

**Mike Schmidt**: Do you have any other ZK thoughts, Tadge?

**Tadge Dryja**: No, I need to read up on it.  I mean, I guess it's cool that
you can prove all these things, and yeah, but it is the same as a lot of things
where you don't want a soft fork because it's like, "What if we have something
better?"  But at the same time, if you spend years and years, then you just
never get it.  So, I'm definitely sympathetic to this, like, "Hey, here's this
thing.  It's pretty good.  What if we put it in?"  And then, the sort of default
response is, "Okay, well what if we make something better next year?  Let's
wait".  And there's always sort of a tension there.  But I need to learn more.

**Mark Erhardt**: So, I think Abdel was mentioning Groth16 specifically, if that
says anything to you.  It doesn't to me.  So, this was like a
request-for-comments post, like what do people think about this generally?  And
one of the things he specifically cited was, yes, this would be sort of a
lock-in situation where if later something comes better, it might hurt the
deployment of that.  So, to be fair, Abdel had already anticipated much of the
comments that we made here.

**Mike Schmidt**: Yeah, I think he noted the sort of tribalism on the different
verification or proof styles.  And also, I thought there was something in the
post that there was little bit that you could flip to say which proof or
verification scheme was used.  I thought that was part of the post as well.  But
yeah, so it's clear he's thought about it.  I did ask him to join today.  He
couldn't make it.

**Mark Erhardt**: Yeah, I mean the 'bit' thing or having some sort of field
where you can specify what proofs you use, if we're already talking about proofs
that are 100 kB or something, being able to tell you what proof it is doesn't
really weigh down the scales too much.  Where it does become a little annoying
is, you'd still have to be able to process all the old proofs.  Well, you could
fork out a proof scheme at some point, but that would again, of course, be
confiscatory.  And so, if we introduce multiple of these, Bitcoin software
forever has to be able to process all these.  This is complex, fairly new
cryptography, and then you have to support it forever.  That makes it a little
hard to be extremely forward and extensible-compatible here.

**Mike Schmidt**: Yeah, and he noted also in his "Risks and drawbacks" section
of his post specifically complexity and audit surface, saying a verifier is
non-trivial C++ code.  He goes on to explain more, but that's definitely a
consideration, especially if you're having multiple of them forever.  Well, I
think that wraps up our Changing consensus segment.  A big chunky one today.
Tadge and Antoine, thank you both for your time on these items.

**Tadge Dryja**: Yeah, thanks, that was fun.

**Antoine Poinsot**: Yeah, thank you for having me.

**Mike Schmidt**: Cheers.  Releases and release candidates.  We have a Releases
and release candidates expert and a Notable code and documentation changes
expert on with us, the one who sourced and summarize these.  Gustavo, thanks for
joining us.

_Core Lightning 25.09.2_

**Gustavo Flores Echaiz**: Thank you, Mike.  Thank you, Murch.  Very interesting
conversation so far, so I'll try to maintain it to that level.  So, let's start
with Core Lightning 25.09.2.  This is a maintenance release for the current
major version that includes several bug fixes related to both bookkeeper
--bookkeeper is the data warehouse where all the information related to
transactions and just all the details is kept -- and to xpay.  Xpay is a plugin
used to pay, but with additional pathfinding algorithms, it uses just more
advanced pathfinding mechanisms.  So, some of these changes, we will cover them
in the Notable code and documentation changes.  So, not a big release, not just
a couple of bug fixes.

_LND 0.20.0-beta.rc3_

We move on with LND20, which is the third RC.  Very similar to what we covered
in the previous newsletter, so this is just a new version of the RC.  I think
now the fourth version has come out.  So, we recommend everyone to go test these
RCs.  There's many, many improvements.  One improvement that we covered in, I
believe, the past newsletter was the fix for premature wallet re-scanning.  So,
maybe that's more new, but there's just a lot of stuff to test.  Anything to add
here, guys, for the release section?  Awesome.

_Bitcoin Core #31645_

We move on with the Notable code and documentation changes, where we summarize
the most important PRs made to multiple projects.  And Bitcoin Core #31645.
This one increases the default size of the dbbatchsize config from 16 MB to 32
MB.  So, what is this config option, db, database, batchsize?  This option
determines the batch size used to flush the UTXO set cache and memory as set by
dbcache when it's flushed to disk after or during IBD (Initial Block Download)
or after an assumed UTXO snapshot.  So, basically, when you're doing IBD, when
you're syncing your node, you're keeping some of the UTXO set cache in memory as
set by dbcache, which if let's say you're not restarted, you would have kept
that in memory, so it would make the restart process easier.  And once you flush
that, let's say you set that at 1 GB, and then your dbcache size is set at 32
MB, then when you flush it to disk, it would go in those batch sizes.  Anything
to add here?

**Mark Erhardt**: Yes, sorry, let me jump in.  So, the dbcache specifically is
used to cache the UTXOs.  And what we try to do there, during IBD especially, is
as we process the blocks and new outputs are being created, we store them in the
cache, because most UTXOs are spent very soon after they are created, and
therefore caching them makes it much cheaper to retrieve the data to validate
future transactions that also come in, rather than seeking the UTXO data on
disk.  So, LevelDB is on disk, or rather the main store of the UTXO set is on
disk, but we keep hot the most recent created UTXOs.  Now, when that cache gets
full, a device would go into swapping, which means that it would start using the
hard disk as additional memory.  And that is super-slow, because writing and
reading from the hard drive is magnitude slower than RAM.  So, whenever it has
to store process data on the disk, it would just start being extremely slow.

This is, by the way, something that I think might have weighed down some of the
node software people have been running that have been reporting extremely long
sync times, is they were under the impression that they needed to set the
dbcache big enough that the entire UTXO set can fit into it.  But they set it
then to a value that's larger than the actual RAM their computer has.  And now,
the computer started allocating disk space for additional RAM and started
writing stuff that was supposed to be in an extremely fast, quick-to-retrieve
memory, to a fairly slow memory, and that doesn't work well.  So, in case you
were under the impression that you need to set the dbcache to a value that is
bigger than the UTXO set, no, the dbcache should be no bigger than 75% of your
actual RAM.  And if you don't know, don't change it, just don't change it, it's
fine.  It'll be slower but it'll continue working.  And if you do know, you
should increase it a little bit to a higher value than the default, because that
will be one of the things that speeds it up a lot.  But keep it significantly
below the maximum of your RAM, no bigger than 75%.

So, this flushing is what happens when the dbcache is full and we start writing
the UTXOs to the disk.  And this happens probably around a dozen times or so, at
least during an IBD, even if you have, let's say a GB or 2GB… no, probably more
than a dozen times.  Like, I think it might be 50 times or so.  So, if this
happens 30% faster because you're writing it in bigger chunks, this is pretty
cool.  And especially if you have a very small dbcache, for example on a
low-powered device with only 500 MB of dbcache, this will be a significant
speed-up.  So, the Raspberry Pis and other node-in-the-box systems, I think,
will especially benefit from this.

**Gustavo Flores Echaiz**: Thank you so much for adding those extra details.
That warning you talked about, well, just wanted to add that in Newsletter #373
Bitcoin Core added a warning that is admitted if you have allocated too much
dbcache.  Just to warn users not to do that and, well, Murch explained all those
details around that.  So, in this newsletter, the PR that I was talking about,
it just doubles the default size of dbbatchsize, which is what gets the
batchsize of when you flush the UTXO that is cached in memory to the LevelDB
database on disk.  And this update primarily benefits HDs and lower-end systems,
for example the auto reports that there was a 30% improvement in flushing time
on a Raspberry Pi that had a dbcache of 500.  Of course, users can override this
default setting as desired.

The motivation behind this came from the growth of the UTXO set, when the
original 16 MB was fixed in 2017, back when the UTXO set was much smaller.  So,
this just updates to current realities.  This is part of the larger project that
is speeding up IBD.  So, this is just many of those changes related to that.

**Mark Erhardt**: Maybe just a very small one.  Also, of course, in the last ten
years, RAM on computers has become much cheaper and much bigger.  Not only has
the UTXO set gotten bigger, but the amount of data that we would have in the DB
cache could be way larger.  And if you're, say, running with a dbcache of 4 GB
and writing it out in 16 MB pieces instead of 32 MB, pieces, you're just simply
doubling all of the seek times on where to write on the disk and the writing
itself is much faster, because also hard drives have gotten much faster, right?
So, it's just we have bigger amounts of data, let's write them in bigger chunks.

_Core Lightning #8636_

**Gustavo Flores Echaiz**: Totally, thank you for that.  So, Core Lightning
#8636, which was one of the changes of the new minor release that I was talking
about previously.  So, in here, a new config is added called askrene-timeout,
which imposes a timeout on askrene queries, which are basically just doing
pathfinding.  The default is now set at 10 seconds.  So, this means that once
you're looking for a route, it will timeout after 10 seconds.  Because
previously many loops, or at least one loop was found.  This happened when
setting maxparts was set to a low value.  Maxparts defines in how many pieces
you can split a payment.  So, when you're using multipath payments, you split
your payment into multiparts.  But the default of maxparts is 100, but let's say
if you put it at 3, then askrene would enter a retry loop on one specific route
that had insufficient capacity, it would just retry that route even though it
wasn't working and it had insufficient capacity, it would just keep on trying
that and that would cause a larger loop.  So, the timeout is added to just
prevent loops in general, but this PR also disables the bottleneck route in that
specific scenario so that forward progress can be ensured.  Anything to add
here?

**Mark Erhardt**: Yeah, I looked at this a little bit.  So, it sounds to me that
this specifically is a problem when you are trying to make a multipart payment,
and make a multipart payment with I think it was a low count of parts that you
allowed.  And then, it would sort of just get stuck on using a channel that had
too low of a capacity to make the multipart thing work, and it would just
infinitely loop.  And the way this bottleneck is removed is it now somehow
discovers when the channel is not useful for facilitating this multipart
payment.  Presumably it just picks one of the channels that have very low
capacity, and that just ended up being part of many, many different attempts
that didn't work, and marks that as don't use.  That way, it can break out of
generating very similar or the same routes that are all blocked on the same
bottleneck.  So, it used to be able to get into an infinite loop.  And now, if
it were to get into a loop, it would at least stop after 10 seconds, which seems
extremely generous if we want payments to usually go through in less than 1.

_Core Lightning #8639_

**Gustavo Flores Echaiz**: Yeah, overall seems like a good solution from both
hands.  Core Lightning #8639 updates the bcli plugin to use a setting -stdin,
which I think is standard input, when interfacing with bitcoin-cli, so when
interfacing with Bitcoin Core through the terminal.  This allows Core Lighting
(CLN) to avoid operating-system-dependent argv, which is command line argument
size limits.  So, let's say you were making a very large transaction, in this
example we present a PSBT with 700 inputs, as a user, you would be blocked from
building large transactions because you would hit command line argument size
limit.  So, adding this option, -stdin to bcli allows it to bypass the common
line argument size limits, and it allows large transactions to be built and
broadcasted.  Other improvements to the performance of large transactions are
also made by the main focus was this one.  Anything to add here?  All good,
perfect.

_Core Lighting #8635_

So, the last one for Core Lightning #8635.  In here, there's an update of how
payment status are managed and allocated, to only mark a payment part as pending
after the outgoing HTLC (Hash Time Locked Contract) has been created, when using
xpay specifically or injectpaymentonoin.  So, basically what's happening is that
CLM was marking payment parts as pending immediately, even before the HTLC was
created.  So, if the HTLC creation failed, let's say a couple of milliseconds
later, the status would never get updated to fail of that specific payment part.
So, instead of managing how the status is updated later, this just follows a
better order of how things should be done.  So, the first step is actually
creating the HTLC, if it's to mark the payment part as pending in the storage of
how transactions are listed.  So, this just means that if the HTLC is never
created, then the payment part will be marked as failed instead of pending.  And
this, you can check the status of all these payment parts with the endpoints
listpays and listsendpays.  Anything to add here?

**Mark Erhardt**: Yeah, maybe just to be clear, this is a bug in the flow.  So,
apparently there was a way that the creation of this HTLC could fail that wasn't
anticipated, and then it didn't correctly clean up.  So, this is basically a
transaction creation flow bug fix.

_Eclair #3209_

**Gustavo Flores Echaiz**: So, Eclair, we have three PRs for Eclair.  The first
one, #3209.  This one adds a check to ensure that routing feerate values cannot
be negative.  So, this was obviously just a bug that was overlooked.  It's never
really supposed to happen, but let's say if you set that value as a negative
value, then this would trigger a channel force closure.  So, now there's a check
that blocks you from setting a negative value.

_Eclair #3206_

The next one, Eclair #3206.  This one immediately fails a held incoming HTLC
when a liquidity advertisement purchase is aborted after signing begins, but
before signatures are exchanged.  So, let's say you're a node and you're trying
to receive a payment, but you don't have incoming liquidity, your LSP (Lightning
Service Provider) would hold on to that HTLC while you are negotiating a
liquidity purchase so that you have incoming liquidity.  However, once the
negotiation process is on, and signing has begun, but before signatures are
exchanges, this process can be aborted at that moment.  So, previously, once
signing had begun, it was assumed that there was not going to be any abort.  But
what happens is that mobile wallets can disconnect and abort non-intentionally.
So, this change adapts to that edge case where this can happen in a
non-malicious manner.  So, previously, Eclair just wouldn't handle this edge
case and would only fail the HTLC shortly before its expiration, which would tie
up sender funds unnecessarily.  Any extra comments here?

**Mike Schmidt**: I had a comment on the last one.  I think, Murch, didn't we
cover previously discussions of setting fees negative to incentivize rebalancing
of channels, or whatnot?

**Mark Erhardt**: Yeah, I believe so.  So, I think this is actually funny that
this would cause a force close in Eclair, because at some point people
considered making this a feature in order to entice people to go through your
channel.  Also, I briefly had looked at the issue that the person had filed, and
it turns out they basically just went to an engineer on Eclair and were like, "I
wonder what happens if I set a negative value here while playing around Ride The
Lightning".  And then they did, and their channel closed.  So, they're like,
"This is a bug"!

_Eclair #3210_

**Gustavo Flores Echaiz**: Yeah, I wasn't aware that that was actually proposed
as a feature.  So, thanks for adding that context, Mike.  We move on with Eclair
#3210, where the weight estimation now assumes a third 73-byte DER-encoded
signature, which is what the BOLT3 specification recommends and what LDK, for
example, implements as well.  However, Eclair never generates these non-standard
signatures, which are protocol-valid, but are non-standard.  Eclair might enter
a negotiation with, let's say, an LDK node, and there could be an edge case
where just estimating with like a 72-byte signature would actually make a peer
reject Eclair's attempt due to fee underpayments.  Assuming the highest size,
which is 73 bytes for the signature, ensures that Eclair never enters that fee
underpayment edge case when its peer is expecting a 73-byte signature.  However,
this wasn't added to this PR in the notes, but I later saw that LDK has now
opened a PR to actually switch back to 72 bytes, so actually do the opposite of
what Eclair has done.  So, we'll see if that later impacts Eclair's decision.
But for now, this is how things stand.

**Mark Erhardt**: Sorry, did they propose an update to the spec or to their
code?

**Gustavo Flores Echaiz**: No, specifically to their code.

**Mark Erhardt**: Huh, because I would have expected that this should be fixed
at the spec first.  72-byte signatures are standard because they assume that you
have a low-S and high- or low-R.  And to get a 73-byte signature, you'd have to
have a high-S signature, which has been non-standard forever.  So, as you see,
this was mentioned in Newsletter #6, which is what now, like five years ago,
something.  Yeah.  The point there is you have to sort of assume that people are
doing the most conservative.  You have to be most conservative about what people
do and non-standard transactions are consensus-valid, but non-standard, so
someone might give you a 73-byte signature.  So, if you want to make sure that
you meet a feerate estimate or agree on something like that, you have to
calculate with the biggest possible permitted value.  And this is where the 73
byte comes from here.

Now, I would assume that if people are going to use 72 bytes, and I would expect
everyone to always never have bigger than 72 bytes, so they would always have 71
or 72, unless in certain cases it could even be smaller, yeah, I would fix it at
the spec first and then at the implementations.  And here, you specifically
mentioned that 73 bytes is the spec.  So, maybe LDK should change the spec, not
their own code.

**Gustavo Flores Echaiz**: That's a very good point.  Actually, I just checked
the Rust Lightning #4208 was just merged 45 minutes ago, which changes it to 72.
But yeah, definitely something that should be done at the spec level.  We'll see
if there's a follow up there.

**Mark Erhardt**: Sorry, does it change what it accepts or what it creates?
When estimating signature weight, it now uses 72 weight units instead of 73
weight units.

**Mark Erhardt**: Interesting.  So, now I'm wondering whether the issue that one
had and communicated with the others was misunderstood as, "Hey, others, please
fix this".  And now, LDK is getting spec-incompliant because they heard about
Eclair's issue here.  If anyone is listening, you guys might want to talk with
each other.

_LDK #4140_

**Gustavo Flores Echaiz**: Definitely.  Kind of a funny situation.  Okay, we
move on, LDK #4140.  Here, there's a fix for premature force closes for outgoing
async payments, asynchronous payments, when a node restarts.  So, basically what
happened here is in an async payment, when an often-offline node came back, for
an async send, so a sender node, that went offline, came back online and saw
that his outgoing HTLC was past the setting called latency grace period, which
is 3 blocks, was 3 blocks past a CLTV (CHECKLOCKTIMEVERIFY) expiry, LDK would
force close immediately before the node could reconnect to the peer, and
actually allow the receiving peer to fail the HTLC.  In general, this setting
latency grace period, which is set at 3 blocks, is supposed to take effect
because there can be a race to claim an incoming HTLC.  But this doesn't apply
for synchronous payments when you're the sender.

So, now this PR adds a new setting of 4,032 blocks, which is a new grace period
specific to asynchronous payments, before force closing the channel.  So, now
LDK, let's say if it's between 3 blocks and 4,032 blocks past the CLTV expiry of
the HTLC, when the LDK sender node comes online, it will actually wait to
connect to the peer and wait if the peer will give the chance to the peer to
fill the HTLC within that grace period.  And if it's past 4,032 blocks past the
CLTV expiry, then at that moment, LDK will actually force close the channel.
So, this just reduces force closing that was maybe happening in an unnecessarily
manner.  It was probably too pre-emptive to nuke a channel in this use case
where there's no risk of a race to claim an incoming HTLC.  Any extra thoughts
here?

**Mark Erhardt**: So, I was trying to understand exactly.  So, in an
asynchronous payment where we expect one of the sides to be infrequently online,
basically you could have an inbound payment?  Is it inbound or outbound?

**Gustavo Flores Echaiz**: It's an outbound payment.

**Gustavo Flores Echaiz**: Outbound payment, okay.  So, basically there's no
cost, nothing at risk yet.  And so, when you come back, what you would do is
basically you would just try to give the money to the recipient.  But if you're
past the CLTV period, this is not going to work anymore.  So, what should happen
is you should just fold the HTLC back into your channel and abort the payment
attempt because you were offline too long.  And instead, what happened was the
node that came back online realized, "Oh, I have an HTLC that is outdated.  Let
me force close the channel".  And now, in order to give the node a chance to do
the right thing and not throw away a channel, when it comes back online, it gets
an additional grace period on an outbound HTLC that is timed out to just close
it and fold it back into the channel.  So, basically it will first negotiate
with its channel peer, "Hey, can we clean up this mess?" and then continue
operating instead of just throwing away the relationship.

**Gustavo Flores Echaiz**: That's exactly it.  That specifically applies to
async payments through this new constant called async payment grace-period
blocks, which is set at 4032, which is different from the other grace period,
which is set at three blocks.  And the other grace period, let's say the legacy
latency grace period, is actually important in cases where there's a risk.  But
in this case, there's no risk.

**Mark Erhardt**: Right, because the sender would have to first kick off the
payment, and this hasn't happened yet, as I understand it.  Okay.

_LDK #4168_

**Gustavo Flores Echaiz**: Precisely.  Perfect.  LDK #4168, basically what we
have to understand here is that LDK had two ways to signal to pause or resume
peer message reading.  One was a flag on a read_event and the other was another
struct called send_data.  So, here, the flag on read_event is removed so that
there's now just one single source of truth for pausing and resuming signals,
which would be through send_data.  So, why was this necessary?  Well, I mean,
this is just overall a cleaner solution because it provides a single source of
truth.  But there was a race condition happened where a node that had the
intention to pause and then resume would, for example, use read_event to pause
and send_data to resume.  But there would be a race condition where actually the
resume message would hit first before the pause message.  So, once the pause
message hit, you wouldn't resume after and you would basically arrive to the
state where your reads would be disabled indefinitely, at least until you sent a
message to that peer again.

So, here, this race condition and this confusion overall was removed by only
relying on send_data for pausing and resuming and removing the flag on
read_event that signaled a pause.  Any extra comments here?  Awesome.

_Rust Bitcoin #5116_

We move on with Rust Bitcoin #5116.  In here, the responses of
compute_merkle_root and compute_witness_root will now return None when the
transaction list contains adjacent duplicates.  So, basically there was a case
of a merkle root vulnerability where you could have adjacent duplicates.  This
was called CVE 2012-2459, where basically you could have an invalid block with
duplicate transactions share the same merkle root (and block hash) as a valid
block.  And if, for example, as a Rust Bitcoin node, I would receive an invalid
block and I would reject it for sure, but then I would receive the valid block,
I would reject both.  So, that would lead me to get confused and reject both,
even the valid block.  So now, here, once Rust Bitcoin receives a block that has
duplicate transactions, it will simply return None to computing the merkle root,
or the witness root, and thus it won't log as a rejected block that would then
trigger the future valid block to be rejected as well.  And this solution is
very similar to the one introduced in Bitcoin Core, I believe a long time ago.
But yeah, any thoughts here, any questions?

**Mark Erhardt**: Yeah, so the problem here specifically is a quirky way in how
the merkle tree in Bitcoin works for committing to the transactions in the
block.  So, a merkle tree is generally expected to be balanced and a binary
tree.  So, at every level, it doubles the number of nodes in the graph.  And
then, at the lowest level, you get all the leaves and the leaves are the
transactions.  So, for example, when you have three transactions, the fourth
transaction would be empty and you would be constructing a tree that is two
hashing partners in the first in the left side with A and B, and then on the
right side you'd have C and nothing.  And the merkle tree in Bitcoin works that
if a node is nothing, you just repeat the data from the other hashing partner.
So, it would concatenate C with C and then hash that.  And this is of course
obviously the same as having the transaction C twice, and that is not legal,
because having the same transaction in a block would obviously be a double
spend.  And, yeah, so you could construct a block that had the transaction C
twice and give that to someone, and they would reject it as an invalid block.
But it would have the same merkle root as the correct block that just has the
transactions A, B, and C.  So, this was apparently found in 2012 and now Rust
Bitcoin also has a fix for it.

**Gustavo Flores Echaiz**: Yeah, that's precisely right.  Now, Rust Bitcoin just
refuses to compute such an invalid block that has, let's say, two C
transactions, resorting to the same solution that was built in Bitcoin Core.

_BTCPay Server #6922_

Finally, the final PR, BTCPay Server #6922, where Subscriptions are introduced,
where a merchant can define recurrent payment offerings and plans, as well as
onboard users via a checkout process.  This is not a built-in actually pull flow
where funds are going to get pulled from your wallet, because Bitcoin doesn't
provide those mechanisms.  It is just a similar experience to just regular
checkout experiences in, let's say, Stripe, it provides a very similar
experience to that.  And it allows a merchant to send email alerts to notify
users when a payment is almost due.  It allows users to enter a portal where
they can upgrade, downgrade their plans, view their credits, add more credits by
paying bitcoin, and see all their history and receipts.  However, while this
doesn't introduce automatic charge, just like I said, there is a planned
integration with Nostr Wallet Connect (NWC) that can make that possible for
certain wallets.  I believe that NWC are all custodial Lightning wallets, which
makes this flow possible.  So, just an interesting development, a project that
was long talked about in BTCPay Server to improve the experience of merchants
and end users.  Perfect, well that completes that section and the newsletter for
this week.  Thank you.

**Mike Schmidt**: Thanks for running that, Gustavo.

**Mark Erhardt**: Yeah, thank you for doing so much work in citing all these.

**Mike Schmidt**: We had a long one today, Murch.  Although I think we'll make
up for it next week by the looks of the lack of news items.

**Mark Erhardt**: Come on, it was only 2 hours and 10 minutes!

**Mike Schmidt**: Yeah, we've done longer for sure.

**Mark Erhardt**: No, this was pretty long.  Yeah, good episode.  Hear you soon.

**Mike Schmidt**: Yeah, thank you all for joining us.  We want to thank Tadge,
and Antoine, and Portland, and Sebastian for joining us earlier, and my co-hosts
this week, both Gustavo and Murch.  We'll hear you all next week.  Cheers.

{% include references.md %}
