---
title: 'Bitcoin Optech Newsletter #407 Recap Podcast'
permalink: /en/podcast/2026/06/02/
reference: /en/newsletters/2026/05/29/
name: 2026-06-02-recap
slug: 2026-06-02-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Chandra Pratap to discuss [Newsletter #407]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-5-2/425378608-44100-2-e521948fef1f2.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome, everyone, to Bitcoin Optech Newsletter #407 Recap.
Today, we're going to talk about the disclosure of a vulnerability in Core
Lightning (CLN) nodes and its responsible disclosure; we also are going to
cover some transcripts from a recent Bitcoin Core in-person developer meeting;
and we have our usual weekly segments on Notable code and Releases.  This week,
Murch, Gustavo and I are joined by Chand.  Chand, do you want to introduce
yourself?

**Chandra Pratap**: Yeah, sure.  Thanks, Mike.  I am Chand, a grad student of
mathematics at NIT Surat, India, and a Summer of Bitcoin 2025 alum where I
worked on fuzzing CLN.  And I'm a participant in this year's Summer of Bitcoin
as well.  So, yeah, that's about me.  It's great to be here.

_Core Lightning assertion DoS disclosure_

**Mike Schmidt**: Awesome.  Thanks for joining us, and we'll jump right into
your news item titled, "Core Lightning assertion DoS disclosure".  Chand, you
posted to Delving Bitcoin about disclosing a DoS vulnerability in CLN, and you
mentioned that that was discovered during your Summer of Bitcoin 2025
internship.  The vulnerability affected any CLN node that accepted incoming
channels.  Maybe we can get into what the vulnerability is.  Talk about maybe
the process of channel opening, and then how the vulnerability fits into that
process.

**Chandra Pratap**: Right, yeah.  So, how CLN works is basically it's a
multi-daemon architecture.  So, there's a master daemon, which is called the
Lightning Daemon, and it works as a demultiplexer for different types of
messages.  So, for open channel flows, for flows that open channels, there's
the opening daemon for gossiping, there's the gossip daemon, there's the
onchain daemon for onchain operations, and stuff like that.  And this
vulnerability was basically found in the opening daemon, which handles all, I
guess, operations pertaining to open channel operations.  And what happens is
basically a remote peer, after it connects, it completes the initial Noise
handshake and initiates the standard open channel procedure, which is sending
an openchannel message followed by receiving the acceptchannel from the peer.
After it does that, it creates, you need to send a funding_created message.
But what's special about this funding_created message is that if you set the
funding_txid, which is a parameter in this message, so to say, if that is
completely zero, that basically crashes the node.

How that works is basically, CLN relies on HSMD, which is the Hardware Security
Module Daemon, for all its cryptographic operations.  And the opening daemon
parses this funding_created message to the HSMD to verify for correctness.  And
there was an overtly strict assertion in the HSMD, which basically asserted for
this funding_txid to be non-zero.  The developers assumed this was an
impossible state to reach over the wire, but apparently it was not.  And
because the assertion fails, there's an abort signal, and the HSMD basically
errors out.  And because Lightning Daemon relies on the HSM Daemon for all
critical cryptographic operations, it cannot safely continue without it, and it
has to become offline as soon as HSMD is offline, which in turn takes out the
whole node.  So, that's how that vulnerability works.

**Mike Schmidt**: Okay, so it's an assertion error somewhere in the CLN
codebase that was assumed to not be something that would be relayed over from a
peer, or at least it wouldn't get to that lower level of the stack.  And if it
did, it essentially crashes the CLN node.  And so, all CLN nodes were
vulnerable to essentially being taken offline through this vulnerability?

**Chandra Pratap**: Right, yeah.  The potent part of this vulnerability is the
fact that it is fully remote and permissionless.  So, any public node that
accepts incoming channels could be instantly crashed by an interested peer
before any sort of capital is locked.

**Mike Schmidt**: Wow.  Yeah, that's a big one.  Good find.  Maybe if Gustavo
or Murch have questions on the vulnerability, we can get into that.  But I was
also curious about the discovery of this.  So, how did you find this?  You
mentioned fuzzing earlier.

**Chandra Pratap**: Yeah, so my entire project was about writing advanced,
well, hopefully advanced, but basically improving the fuzz testing suite for
CLN.  And that involved writing new harnesses, fuzzing harnesses for the
program.  And while I was writing the harness, I was working on the project, I
decided to take it step by step.  And the opening channel flow is one of the
first things that occurs when you open a channel on any Lightning Network.  So,
that's the part that I decided to test first.  And I created a custom fuzz
target for it, it's called fuzz-open_channel.  So, what the target basically
does is it randomly alternates between feeding complex, raw, random data or
structurally valid but semantically random messages.  So, randomized feature
bits, flags, TLVs, stuff like that into fundee_channel(), which is basically
the handler for openchannel messages in CLN.  By mixing this structure of valid
messages with random content, the fuzzer navigated past the outer protocol
guards and struck an edge case in the deep logic that resided within the HSMD.
And the sanitizer caught the crash, and that's where the fuzzer basically
tripped up.

Matt Morehouse, who was my acting mentor at the time, he then verified the
vulnerability using a custom attack script, which is basically a malicious
Lightning peer that sends the malicious funding_created message to the node.
And that's how we came to be sure of the fact that this was a vulnerability,
and later disclosed it to CLN security.

**Mike Schmidt**: It's interesting, you mentioned Matt Morehouse.  Listeners of
this show and readers of the newsletter will know that he made several
appearances on the show, I believe it was in the last year or two, coming up
with vulnerabilities that he discovered on his own.  And he consistently had
the message calling out to people that there needed to be more people doing
more fuzz testing on Lightning implementations.  And it sounds like he put his
time where his mouth was, in terms of being a mentor for you during The Summer
of Bitcoin program.  And now, you've done this fuzzing last year and discovered
this.  So, it's interesting to see that sort of go full circle.  Murch, do you
have any comments or questions on this, or Gustavo?

**Mark Erhardt**: Maybe just a great find.  And that sounds like a big one,
because just randomly crashing nodes remotely is, of course, pretty
debilitating.  And especially if you can just send a message directly to one
peer by contacting it and handshaking, and then it crashes.  That's like the
definition of a critical vulnerability.  So, glad that that was fixed.  I see
that it was disclosed in July last year, and then it was fixed in August.  So,
I take it that all of the current CLN versions that are in use are secure
against this bug now?

**Chandra Pratap**: Correct.  The latest version, which was, I think, 26.04 of
CLN, fixed this bug, and everyone that's operating is advised to upgrade.

**Mike Schmidt**: For listeners who may be curious about fuzz testing and what
it takes to get in and write a harness or start poking around, maybe you can
articulate a bit of your experience before the Summer of Bitcoin program, and
what level of effort or knowledge was helpful in ramping up with that fuzz
testing with Lightning, and maybe other folks can maybe hear a pathway to doing
something similar?

**Chandra Pratap**: Yeah, sure.  I mean, I think fuzz testing is actually a
pretty great entry point into Lightning and the Bitcoin ecosystem in general,
because it doesn't require a lot of domain-specific knowledge.  You can get
started with writing targets for very simple message parsers if you want.  And
again, you don't need very complex domain knowledge, the different protocol
flows, how they interact with each other, different messages, to get started
with it.  Me personally, I did not know about fuzz testing or Bitcoin
development, any of it before my Summer of Bitcoin 2025 internship.  But I
ramped up through my phase of writing the proposal for the project.  And
throughout the project, I was able to take up whatever was necessary to see it
to completion on a good level.  So, yeah, I think it's a pretty good entry
point.  And for anyone that's looking to get into it, I think the best way to
do that would be to start right away.  Lightning Network still, fuzz testing is
something that the entire ecosystem is lacking in.  There's a lot of
implementations, a lot of them are written in different languages.  So,
whatever you're comfortable with, you can dive right in, start implementing,
writing fuzz targets in whatever language you're comfortable in, and that's a
great entry point.  So, yeah, I think that should be a good roadmap for anyone
that's looking to get into it.

**Mike Schmidt**: Yeah, thanks for commenting on that.  What are you doing
during your 2026 internship?  You mentioned you were doing it this summer as
well.

**Chandra Pratap**: Right.  So, this is, I guess, in a sense, a continuation of
my previous work.  I am working on building Smite, which was basically started
by Matt again.  And it's a snapshot fuzzing framework for the Lightning
Network.  So, instead of targeting a specific Lightning implementation, we're
building a sort of generalized framework that attacks a specific lightning
implementation from a high level, and trying to find deeper stateful
vulnerabilities that way.  And that's what I'm working on for this summer.

**Mike Schmidt**: Very cool.  Murch, I saw you kind of had your hand up there.

**Mark Erhardt**: Yeah, I just wanted to double-down on the fuzzing being a
good entry point.  Basically, fuzzing treats functions as black boxes, so you
really only need to know what goes into a function.  And then, you write a
routine that just generates random, Well, not random, pseudo-random values
depending on the seed.  And so, as someone that's also written a few fuzz
tests, you get to basically just exercise all of the possible parameters that
can go into a function, or in case of whole software pieces, like the entire
API surface or the web traffic surface.  And that allows you to find edge cases
very easily, because the fuzzer explores specifically in the directions of
where it finds progress.  So, whenever the software executing the input
diverges on its execution path, it notices and then it'll start using that bit
that it just flipped more.  So, you basically randomly go over a huge amount of
different dimensional inputs, but you double-down on the ones that actually
lead somewhere.  So, it tends to be very good at finding edge cases.  And it is
fairly easy to get into because you only, to write such a routine, have to sort
of understand how the function is called.

**Mike Schmidt**: Chandra, anything else that you would leave for the audience
as we wrap up this item?

**Chandra Pratap**: Yeah, sure.  I mean, you mentioned Matt.  He's been on here
more than a couple of times, and I'm pretty sure he's said this already.  But
security across the Lightning Network is something that I think is undervalued
as of now.  And I don't want to call out CLN in particular, but the time that
they actually took between implementing the fix and actually shipping the fix
code was pretty huge.  And it points to me that it's not very reliable for its
operators.  So, just fuzz testing in general, security in general, is something
that Lightning needs to take more seriously in general.  And that's because
ultimately, developers are humans.  We cannot account for every edge case.  And
fuzz testing is sort of a barricade against these types of issues.  So, it
should definitely be something that Lightning should invest more in.  I know
Bitcoin and Bitcoin Core already value it a lot.  It would be nice to see that
happening across Lightning as well.  And yeah, I think that's what I want to
leave it.

**Mike Schmidt**: Awesome.  Thank you for responsibly disclosing that and
working your summers on Bitcoin, and for joining us today to talk about it all.
Appreciate your time, Chandra.

**Chandra Pratap**: Right.  Thanks, everyone.

_Bitcoin Core developer meeting transcripts_

**Mike Schmidt**: Next news item titled, "Bitcoin Core developer meeting
transcripts".  And this is an item we've seen before in past Optech
Newsletters.  We sort of note and cover the fact that this in-person Bitcoin
Core developer happens every six months or so.  And in an effort to provide
some transparency to bitcoiners and folks curious about the technicals, many of
the Core developers themselves volunteer to write transcripts during some of
the sessions.  And that ends up being published publicly on the
btctranscripts.com website.  And then, if you look, there's a category for
these Core developer meetings under Bitcoin Core Dev Tech.  And then, there'll
be an entry for May, which was the meeting covered this week in the newsletter.
You can see a bunch of different topics.  We highlighted a few, but I think
there's something like 20 or 30 in there that have notes, and then another
dozen or so that just have notable mentions.  So, we covered SwiftSync; talk
about cluster mempool; talk about Erlay; package relay; silent payments; the
idea of the TCP hole punching that ended up being a discussion in Newsletter
#406, and is ongoing on the Delving Bitcoin forum; private broadcast;
discussion of a modern crypto library; mutation testing; and a bunch of other
things.

We could obviously talk about any one of these topics for an entire newsletter,
but you can see what the Core developers are talking about by looking at the
individual transcripts.  Murch, do you have any color commentary on this item?

**Mark Erhardt**: Yeah, maybe just a few comments on why we get together to
meet in person.  So, Bitcoin Core is a very loosely-organized project.  I'm
sure some people have noticed that there is not a spokesperson or a president
or a boss of the project that will take questions publicly or roll out their
roadmap, or anything like that.  Especially for new members of the team, it's
therefore not trivial to get a sense of what's going on and what people are
working on.  And we find that getting together in person and putting faces to
nicknames, when most of our communication is written on the internet, really
helps with establishing some mutual trust, and just helping people interpret
each other's review and comments as charitable.  Just having met people seems
to flip a switch that you have an idea how they could mean stuff better, and so
forth.  So, we get together twice a year for a few days to just talk through
what people are working on, to get input, to review PR together.  This is an
un-conference-style event, so we don't have an agenda usually before, but
people just put some items on the calendar after we get there if they want to
have sessions on topics.  And yeah, it's especially great for new contributors
to get a sense of who everyone is and what they're working on, but also for
established contributors to get vibe checks on ideas, or to get some review on
things that had been in flight for a long while, or for going through old PRs
and checking which ones should get some more review or can be closed because
they're no longer relevant.

So, yeah, we do try to not make big decisions on the direction of the project
or anything in person, because we don't want to exclude people that want to
participate but cannot be there.  So, those still happen in the IRC meeting, on
the Internet Relay Chat on Thursdays, which is open to the public and for which
you can also find the logs on various websites that collect them.

**Mike Schmidt**: I would add maybe just one more note here that I've seen on
social media people talking about Bitcoin Core developers all being in an
office or all being in offices, and things like that.  And by my guesstimate,
there's probably 15 to 20 people who are in an office across four or more
offices.  And there's probably, in a given year, if you count regular-ish, or
maybe multi-commit, multi-review contributors, maybe something like 50 to 60.
So, the majority of folks are not in an office.  And I think it's a good
opportunity, Murch mentioned, for newcomers to meet some of the nyms that they
interact with online.  But it's also a good opportunity even for seasoned
engineers to get a chance to see people that they maybe don't regularly see,
but twice a year.  So, I just wanted to make that note as well.

I think we can wrap up that News item and the News section as a whole, and move
on to Releases and release candidates.  And the author of this segment and the
Notable code segment is Gustavo.  And so, we'll have Gustavo, who's back, to
walk these items for us.  Thank you, Gustavo.

_Eclair v0.14.0_

**Gustavo Flores Echaiz**: Excellent.  Thank you, guys.  So, this week we have
two releases.  The first is Eclair v0.14.0, which is a major release, not an
RC.  Here, we have the final versions for splicing and simple taproot channels.
However, zero-fee commitment (0FC) channels, those are still on the
experimental version.  So, that's also been added in this release.  We also
have experimental peer scoring, and also the latest implementation of channel
jamming mitigation that is now called channel attribution.  Maybe that's not
exactly the name.  HTLC (Hash Time Locked Contract) accountability, excuse me.
So, that is now also part of this release.  It was previously called something
else, but now Eclair has updated to the latest spec proposal.

There's also something called plugin validation of interactive transactions.
So, basically, a user can use some external plugins to perform validation of
remote inputs and outputs.  So, for example, if you're building a splicing
transaction or some sort of other interactive protocol, you can use an external
plugin to validate the remote inputs and outputs being added in your
interactive transaction.  So, for example, you can see that a peer would add an
input that you don't want to participate in.  So, you can simply refuse to
participate in that, or to broadcast that splicing transaction after you've
validated those inputs.  So, quite a big release.  I think it was interesting
to observe that they've now made it possible to add 0FC channels in this
release, because that's also an item that we're going to cover in the Notable
code and documentation changes.  So, that was squeezed in at the last minute,
but overall, very interesting release.

Also, another important thing to specify is that Bitcoin Core v30 or above is
now a requirement for Eclair to benefit from v3 transactions and ephemeral
dust, which is required for 0FC channels.  So, that's also very important for
Eclair users to be aware about.

_Core Lightning 26.06rc2_

The next release is the second RC of CLN.  So, CLN, as we know, has this habit
of making multiple RCs before getting to the official release.  So, this was a
release with a few new RPC endpoints, as we discussed, I believe, two
newsletters ago.  Also, the deprecation cycle of a popular plugin called pay,
now deprecated in favor of xpay.  And also, the RC v2, the difference with the
first RC is that the BOLT12 payer-proof protocol has now been updated to the
latest proposal.  Some changes were made to that proposal in between RCs.  So,
this one has some additional bug fixes, but also the experimental payment-proof
implementation is updated to the latest draft.  Any comments here?  No.

_Bitcoin Core #33966_

So, we move forward to the Notable code and documentation changes section.
This week, we have three items from the Bitcoin Core repository.  The first
one, #33966, refactors how mining block template options are parsed.  Basically
here, the problem was that an external client that was requesting a block
template through the Mining IPC interface could pass on a mining option, for
example, blockreservedweight, that would conflict with startup mining options
of the node.  For example, if an external client that was requesting a block
template would set a value at runtime for blockreservedweight that would be in
conflict with blockmaxweight, for example a value that would exceed the maximum
block weight, well, Bitcoin Core would previously simply ignore the invalid
value that was being parsed at runtime and silently adjust it to a valid range
value.  So, that was, let's say, one of the initial problems.

So, the refactor here, the goal was to create a sort of shared object between
the startup options from the node and the runtime options passed by an external
IPC client, to ensure that these can live in perfect harmony.  The main goal
was to resolve the conflict between specifically the value of
blockreservedweight and blockmaxweight.  So, now, this refactor allows for
these values to live more coherently.  But also, some other additions that are
made in this PR is that at startup, taking a step back here and ignoring the
IPC client at startup, previously you could set a blockreservedweight value
that would be in conflict with a blockmaxweight value.  So, now, even at
startup, you ensure that the blockreservedweight value makes sense, and it
would be rejected instead of being clamped later.  And also, if you enter a
negative value for blockmaxweight, it will now be parsed as zero and then
rejected instead of overflowing into a garbage signed value.

So, a bit of a refactor for the benefit of IPC clients, and also some internal
mechanics fixed for the conflict of some values for startup mining options.
Yes, Murch?

**Mark Erhardt**: It's a little surprising how hot stitched the IPC interface
still is.  Yes, it was rolled out as experimental recently, but I mean also,
this means that you have actively put in incorrect values to run into these
issues, or conflicting values, right?  But it seems that with the IPC interface
being released last cycle, there is still a lot coming this cycle to follow up
on it.  So, I assume that these things will also get backported to the previous
release.

**Gustavo Flores Echaiz**: That makes sense.  Yeah, definitely.  I think we've
covered every week almost findings that were discovered through the Mining IPC
interface, and adjustments that were done later, and this is just the latest
one.

_Bitcoin Core #34917_

So, the next item, Bitcoin Core #34917.  This is a maintenance PR.  So, if
anybody was still using the bip125-replaceable field in RPCs that are related
to the wallet, such as listtransactions, listsinceblock, and gettransaction,
this field has now been deprecated, although it can still be requested with the
deprecated RPC option.  The PR also deprecates the walletrbf startup option,
and now emits a warning that this will be scheduled for removal in the next
release.  Yes, Murch?

**Mark Erhardt**: I just wanted to make it very clear.  Obviously, nothing
changes in the software you're running already.  So, if you are now using it,
that's totally fine.  It is going away in the next release, as in, it is marked
as deprecated in the next release, and then presumably it'll be properly
removed in the release afterwards.  So, the background here, of course, is that
mempoolfullrbf was adopted across the network a few years ago, which means that
Bitcoin Core and presumably other implementations too will accept replacements
regardless of whether they have set the replaceable flag on the original or
not.  So, previously, BIP125 required that transactions were marked as
replaceable for a node to accept replacements of that.  And now, any
replacement that pays more attractive fees, as in a higher absolute fee and a
higher feerate, will replace the original transaction without the original,
even if the original was not marked as replaceable.

So, we had actually just gotten the option for the wallet to signal RBF, I
don't know, not that long ago, also a few years ago.  I think just around the
time when mempoolfullrbf was happening or the discussion was happening.  And
now, we're removing it again because it no longer makes sense to signal
replaceability on transactions when any transaction can be replaced simply by
RBFing it.

**Gustavo Flores Echaiz**: Thank you, Murch, for that extra context.  Yes, and
the mempoolfullrbf option was removed in November 2024.  So, yeah, this was
long due.  Perfect.

_Bitcoin Core #35017_

The next PR is #35017.  So, here, this is a bit confusing.  So, basically, if
you are submitting a package that has, for example, a parent and a child, but
then follow-up descendants, you could be in a situation where, for example,
your initial package is submitted and a further child is also submitted.  While
some transaction checks are still running on the initial transactions, you have
already submitted a second descendant to Bitcoin Core.  And, for example, if a
later consensus script check denies the child of the initial package, not the
subsequent child, at a later stage, Bitcoin Core would properly remove the
package, but Bitcoin Core wouldn't properly remove the later child that was
added in the meantime those consensus script checks were running.  So, now,
this update ensures that when a package transaction submission fails due to a
later check, all subsequent transactions that remained in the mempool and were
previously not properly removed, they are now all removed; all the subsequent
childs are now properly removed.  So, not to say that the initial package
transaction submission, that was properly handled, it was the subsequent childs
that were ignored if only in the specific case, where a further, like a final
consensus script check would remove one of those transactions.

**Mike Schmidt**: Murch, question for you on this one.  What would happen in
the operation of a Bitcoin Core node by having this sort of dangling child
remaining in the mempool after the parent is removed?

**Mark Erhardt**: Well, if nothing gets confirmed, it would just stick around
the mempool for, I think, two weeks and then get dropped.  But if there were a
conflict, I think we would notice the conflict and then remove conflicts and
their dependent transactions.  So, if a different transaction spends some of
the same inputs, we would still remove it.  But I think the biggest issue is if
there were a conflict with the parent, we would not notice, because the parent
is not present in the mempool.  So, children can obviously only be valid if the
parent exists, because they spend an output created by the parent.  And if we
had a child in the mempool but its parent wasn't there, and then there was a
new transaction added that would have been in conflict with the parent, we
would just put that in the mempool and then not realize that dependent of the
non-existent child should have been removed too, because it became invalid.
So, maybe some feerate checks, where we were supposed to check for the entire
chain that gets removed, would not run at all because the parent isn't present.

But so overall, that doesn't sound like a huge issue.  Maybe a few bytes of
memory occupied unnecessarily.  And if other transactions came through or made
it into blocks especially, that wouldn't cause an issue.  And it sounds like
this is only possible if you submit a package locally to your own node, so you
would be putting things into your own node's mempool accidentally.  This
doesn't sound like it's an issue that can be triggered by handing stuff over
the wire, so overall not a big issue probably.

**Gustavo Flores Echaiz**: Thank you, Murch, for that extra context.  So, those
are the first three items of this list from the Bitcoin Core repository.  And
next, we have two items from the BIPs repository.  We have two new BIPs, #449,
and #450.  Murch, do you want to do the honors for these two items, please?

_BIPs #1944_

**Mark Erhardt**: Sure.  So, BIP449 is OP_TWEAKADD.  This allows you to add a
32-byte value and a public key to the stack, and they get combined into a
tweaked public key.  This is intended to be used with, well, sort of covenant
constructions, but it's pretty small, of course.  But it would allow you, for
example with OP_CHECKSIGFROMSTACK (CSFS), to check signatures from the stack
against the tweaked key.  So, this would maybe enable oracle signing and
similar things.  This has been open for a while, but it's published now.  If
this sort of thing interests you, maybe give it a read.

_BIPs #2108_

The second one is BIP450, called Formosa.  This is a similar style proposal as
BIP39 mnemonic seed phrases.  So, Formosa takes the idea behind the mnemonic
seed phrase a little further, in that the mnemonic seed phrase is just random
words, and humans are not very good at remembering random words.  So, instead
of just rolling random words of a list with 2,048 words, it constructs
sentences that are themed.  So, for example, there could be a science fiction
or a fantasy themed sentence.  And the same entropy, per a grammar that they
define in their BIP, is used to generate a sentence, actually multiple
sentences to encode an entire -- I think it's four sentences for one mnemonic
story that encodes a seed phrase.  So, such a phrase could, for example, be the
king serves the wine to the queen in the dungeon, which humans can remember
much more easily because it has context and puts subject, object, and verb in
the context of something that humans can easily remember.  Obviously, you still
should not make up your sentences yourself and then check how they would be
encoded in order to generate seed phrases.  That's a great way to lose your
money.  But this is maybe more useful for someone trying to keep something in
their mind for some period of time or travel, or whatever, because you now have
to remember a few phrases that you can picture in your mind more easily.  And
then, you can regenerate your wallet from that.

Obviously, I would recommend that you have a backup somewhere because humans
are very good at forgetting stuff or mixing up stuff or changing their
memories.  So, generally, brain wallets are still a terrible idea.  Anyway, if
you're interested in seed phrases, a wallet developer, you might find this one
interesting.  It seems to be a little easier to, for example, read to someone
and transfer it that way, or to remember for a while because of the context.

**Gustavo Flores Echaiz**: Thank you, Murch.  Yeah, I think it's interesting
too.  I think it lengthens, from what I understand.  Like, for example, three,
four words would become like six, seven words.  I'm not sure, but so it would
lengthen, but it would be more memorable.  Interesting.

_Eclair #3192_

The next ones are from the Lightning implementations.  So, as I was saying in
the Release sections for the Eclair v0.14.0, this item from the Eclair
repository, #3192, 3192 adds experimental support for 0FC channels.  As
discussed in Newsletter #404, this is now part of the BOLTs specification, and
is also present in the LDK implementation.  So, Eclair follows up to LDK as the
second implementation to implement 0FC channels, which is why Eclair now
requires Bitcoin v30 to be used with Eclair.  However, this feature is disabled
by default, remains experimental, but can be turned on for users that are
interested in trying out.

_LDK #4584_

The next two are from the LDK repository, a bit related, both around the
payment_metadata field.  So, the first one, #4584, builds the plumbing required
to add payment_metadata maps not directly to the BOLT12 invoice, but to the
BOLT12 blinded message and payment path contexts.  So, this is simply a
plumbing PR.  It basically lays out for us that this will later be added as an
optional feature that can be used by users.  But for now, it's simply an
internal plumbing that is required for that then to make it available as an
option to users.  So, like I said in the write up, this building offers with
metadata is not yet supported.  And it also is built in a way that it will
allow multiple independent pieces of data to be attached to the same payment.
So, it's an implementation that could be quite flexible for multiple use cases.

_LDK #4628_

The next one, LDK #4628, is related to the item we covered in Newsletter #405,
where we announced that the BOLT11 payment_metadata was now committed to the
inbound payment HMAC (Hash-based Message Authentication Code).  So, it
basically ensured the integrity of the payment_metadata disabling or removing
the ability for a payer to corrupt the payment_metadata that was inserted by
the payee.  So, now, this PR serves as a follow-up, where the payment_metadata
is not only committed to the HMAC, but it can also now be encrypted by the
payee to ensure that the payer doesn't have access to that invoice metadata,
and to simplify the encryption layers so that, for example, previously a payee
could handle encryption themselves externally.  Now, it can all be handled
directly within LDK.

There was also a bit of a discussion internally of how to obtain the required
nonce, also called initialization vector, or nonce, that was required to
encrypt this value.  So, there was a bit of an exchange there to find the exact
way to implement it correctly.  But it was found that when creating the payment
hash, LDK already generates a sort of initialization vector nonce that could be
used for encrypting the payment data.  So, that is what's being used instead of
adding additional values that could consume additional space in the
payment_metadata.  The initialization vector created when sending the payment
hash is also reused here.

_LND #10552_

So, now, the next one is from the LND repository, the item #10552.  Here, this
is work done on the Neutrino-backed LND nodes.  So, if you're not using Bitcoin
Core, LND has this function that allows you to use compact block filters, that
allows you to obtain a bunch of block filters so that you can later scan them,
find your transaction history within those block filters, to then request
specific blocks that have the information that you need.  This is a privacy
protocol for light clients to obtain transaction data.  So, Neutrino has
existed in LND since the beginning.  However, there's now a new fast, initial
synchronization mode that allows an LND node to either import pre-built Bitcoin
block headers and compact filters from a local file or from an external HTTP
source.  In the PR description, block-dn.org is presented as one of those
options that users can connect to, to download headers from a trusted source,
instead of fetching them one by one from peers.  This could reduce initial sync
time from hours down to minutes, and after that, LND would resume syncing from
the P2P network upwards of a certain chain tip that was obtained from either
the local files or from the external HTTP source.

So, there's some new options: neutrino.blockheadersource and
neutrino.filterheadersource that must be configured together for this to work.
And imported headers are validated locally, and then Neutrino fetches any
headers, like I said, after the imported tip from network peers.  So, I would
have thought this was already in place within LND, but this is a great addition
for improving initial sync time for users to reduce that time from potentially
hours down to minutes, although there is some trust involved here, but I think
the validation makes it that it's quite minimized.

**Mark Erhardt**: I think I would want to add a few things.  So, Neutrino is
the implementation the Lightning Network Daemon, LND, uses to implement BIP157,
158, which is the compact block filter protocol.  So, the compact block filter
protocol allows people to get sort of a table of contents of blocks that they
can search on their end rather than giving -- okay, let's add a little more
history.  Before the compact block filter protocol, the common way of how light
clients got information about transactions from full nodes was per Bloom
filters, where they would create a filter and then give it to the full node,
and the full node would run it on their data and then return hits.  The idea
was that it would be a little fuzzy and find things that don't actually meet
the filter, but it would always be a superset of the things that the light
client was interested in.  So, the light clients essentially gave away what
they were interested in regarding their wallet.

Compact block filters turns this around so that the light client does the
searching.  And what they use is they get back a representation of the content
of the blocks, the compact block filters, and they can search those filters
like a table of content, "Is something about my address in here, or is
something about my UTXOs in here?"  It does this a little slow and
computationally-intensive, and presumably only a small portion of full nodes
serve compact block filters, so it could take a while to get them.  I don't
think that it is a privacy improvement for LND to get the compact block filters
from a website, because now, when they hit the website, they actually share
their IP address with the website and thereby say exactly what blocks they were
interested in to a single party that can keep statistics on which IP address
downloaded what compact block filters at what time, right?  So, if you get them
from the public network via peer messages, it would probably be more private.
But just getting all of the information at once is probably a speed-up and that
seems to be the motivation here.

_LND #10820_

**Gustavo Flores Echaiz**: Thank you for that extra context, Murch.  Very
valuable.  So, the next and final item is also from the LND repository.  This
is item #10820, where after the simple taproot channels implementation in LND,
well, after turning it on into production mode, if two nodes would want to open
a public channel between them, and if both nodes supported the simple taproot
channels implementation, LND would try to open that type of channel.  However,
as we announced in a previous newsletter when we talked about the simple
taproot channel implementation being added to the BOLTs repository and LND
promoting it to the production bit, well, taproot channel announcements have
not yet been specced, and LND of course has not yet added support for it.  So,
trying to open a public channel, use a public simple taproot channel, is not
possible and naturally fails.  But the developer team at LND hadn't considered
that.  So, this PR fixes this edge case where both nodes would support this
type of channels, and they would try to open a public channel that would
ultimately fail, right?  The opening of the channel would simply get rejected.

So, now, simple taproot channels must be explicitly requested, since only
private channels of this type can be opened.  And implicit negotiation, so
basically an automatic public channel opening, still selects the lower level,
like the next type of channel that both nodes support, either anchor channel
types or previous types of channels.  Yes, Murch?

**Mark Erhardt**: Yeah, so maybe to put it a little more simply, currently you
can't tell people that you have a simple taproot channel.  So, even when both
sides support it, trying to open a public channel with simple taproot channels
is not possible.  So, it has to downgrade to the next one.  And instead of
defaulting to it and then failing to open a channel, it will now correctly
downgrade.  And it still, and has before, supports private simple taproot
channels.

**Gustavo Flores Echaiz**: Precisely.  Also, this PR also has some additions,
some things that were missed when promoting simple taproot channels to the
production bit, and moving it from experimental to production.  For example,
the lncli openchannel -- command, if you chose the channel_type=taproot, it
would still try to open an experimental type of channel.  So, now, that is also
fixed in this PR, to complete the transition from experimental to production
for simple taproot channels in LND.  And that is the last item of this section,
and that completes the newsletter.

**Mike Schmidt**: Great.  Thank you, Gustavo.  We also want to thank Chandra
for joining us earlier in the News segment, I want to thank Murch for
co-hosting as well, and for you all for listening.  We'll hear you next week.
Cheers.

**Gustavo Flores Echaiz**: Thank you.

{% include references.md %}
