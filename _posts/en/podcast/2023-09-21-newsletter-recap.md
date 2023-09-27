---
title: 'Bitcoin Optech Newsletter #269 Recap Podcast'
permalink: /en/podcast/2023/09/21/
reference: /en/newsletters/2023/09/20/
name: 2023-09-21-recap
slug: 2023-09-21-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Sergi Delgado Segura to
discuss [Newsletter #269]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-25/348467520-44100-2-592da54fffc0c.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Recap #269 on Twitter
Spaces.  It's Thursday, September 21, and we are joined this week by Sergi
Delgado to talk about Bitcoin Research Day event, and we also highlight some
interesting software updates in our monthly services and client software
segment.  We'll go through some introductions and then jump in.  I'm Mike
Schmidt, contributor at Bitcoin Optech and Executive Director at Brink, funding
Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.  I'm currently
Wi-Fi-challenged!

**Mike Schmidt**: Sergi?

**Sergi Delgado**: Hello, I'm Sergi, I also work at Chaincode now and my Wi-Fi
is not great either!  And thank you for having me today here to talk about the
Bitcoin Research Day.

_Bitcoin research event_

**Mike Schmidt**: Well, the Bitcoin Research event that we referenced just a
second ago is actually the first news item, so we'll jump into that.  Sergi, do
you want to introduce maybe the what of what is this Research Day, and maybe we
can get into why you guys are putting that on, and maybe some of the content
that will be there?

**Sergi Delgado**: Sure.  So what this is, is a one-day event that is going to
happen later this year in October in the Chaincode office.  And the idea of it
is kind of bringing together researchers from the Bitcoin space, and developers,
to talk about the things that make Bitcoin what it is; make it robust, make it
secure, make it somehow private.  And it's kind of a way of bringing them back
together.  Because it feels like at some point, the research community and the
development community were quite tied together, but that feels like it's not the
case anymore.  There's research being done on Bitcoin, and there's a lot of
development being done in Bitcoin, but it feels like the two sides are not
collaborating enough or not listening enough to each other.  So that feels it
could be improved, so that's kind of the rationale for why we are doing this.

**Mike Schmidt**: So, what kind of discussions are scheduled to be had, or do
you hope will be had with, I saw that there's speakers and Lightning talks;
maybe you can get into the topics?

**Sergi Delgado**: So, the idea of how the setup is going to look like, there's
going to be long-format talks from both researchers and developers covering
topics from cryptography to P2P, from BIP writing to actually implementing the
BIP; there's consensus; there's what else?  I think those are currently the main
topics.  I would need to go over the website to remember a little bit more.  But
those are going to be long forms.  Whoever is in charge of that talk will give
the presentation.  There's going to be discussion around it after that.

But we also are encouraging people who are working in the space, and they may
have early-stage research, or they are working on a specific development
project, that want to give a short talk, like a  much more lightning talk, or a
five-minute talk, to come around and talk about what they're doing.  That may
kickstart a collaboration program later on with either some of the local
developers or some of the researchers.  That's about it for the speaking slots.

But what we also want to have are people who are interested in this.  You don't
need to be a researcher or a developer, but we encourage you to be, so the
discussion can be open to more than just the speakers.

**Mike Schmidt**: So, you mentioned you're targeting a certain audience to
attend.  So, this is probably a curious topic for listeners here, but you're
encouraging an ideal attendee to be an academic researcher or a developer in
order to sign up to attend; is that right?

**Sergi Delgado**: Sure.  I mean, it's not like you're required to be, but the
focus of the day is going to be really technical, like the whole point of it is
fostering collaboration.  So, if you are not, you're also welcome to come, but
you may have less to say, or you may get more bored by what is going to end up
happening, right?  We are targeting this to be a highly technical day with a
purpose in mind.

**Mike Schmidt**: And is this something that's going to be recorded, audio,
video, or like a transcript of it, or is that more meant to be sort of an
internal, in-person meeting only?

**Sergi Delgado**: So, it's in-person, that's for sure.  I don't think we're
going to be streaming it.  There may be some transcripts that we haven't decided
on yet.  But it's mainly going to be something to be had in person.  So, again,
there's no tickets, you don't have to buy anything to come, you just have to go
to the website and sign up.  There's a form for that, both for the Lightning
talks and the attendee list.  We cannot ensure that that's going to be
transcripted.  If we have the means to do it, we may do our best to do it, but
in the same sense that when we run the Socratic seminars, we want to encourage
people to participate and to say their piece; we don't want to disencourage
people to say what they feel they have to say.  So, if that gets in the way of
people speaking up, then we won't do it.  So, if that's not the case, if people
are happy with it and we have the means to do it, we may do it.  But I guess no
promises here.

**Mike Schmidt**: And I see a few great speakers listed on the website.  The
website, by the way, is brd23.com.  One of the speakers is our very own Murch.
Murch, do you have a topic that you'd like to share that you'll be talking
about?

**Mark Erhardt**: I think that I might be getting a bit into how I started as a
researcher writing my master thesis about coin selection, and how that
translated into developers putting that into various code bases, and sort of as
an example of how this collaboration will go or could go.

**Mike Schmidt**: So, if you're a developer or a researcher, head to the
website, brd23.com, and there's a big yellow "Sign me up!" link, and hopefully
you can collaborate with some smart people.  Sergi, any parting words of
encouragement for our audience?

**Sergi Delgado**: Not much more.  I would say I think it's going to be a really
interesting event.  If you are somehow interested in research or developing
Bitcoin, I think it's something you shouldn't miss out on.  It's going to be in
Chaincode, you know, it's one of the most special locations you can have in New
York, so it's going to be worth coming.  There will be a happy hour later where
you could also discuss more general topics.  There's going to be the -- oh, I
completely forgot about that, that's true.  There's the Bitcoin Research Prize
Ceremony in where -- so let me phrase this properly.

Some time ago, there was a process for submission of academic papers within 2019
to 2023, I think it was, or 2018 to 2023, I don't remember the exact timeframe,
to decide what was the best Bitcoin-related research paper within that time
period.  Then a committee was selected to vote on that, and the announcement of
the winner would be had during the research day.  And they are also going to be
talking about the paper itself, so they will make a presentation about it.
That's something that we are exploring.  We don't know if that's going to happen
again or not, but it feels like it's also a good way of encouraging people to do
research in things that matter.

**Mike Schmidt**: Excellent.  Well, thanks, Sergi, for coming on and promoting
this.  I think it's a good opportunity for certain folks in the community to
collaborate, and I'm glad you guys are doing that.  So, thanks for joining us.
You're welcome to stay on, but you're welcome to drop as well if you have other
things you're doing.

**Sergi Delgado**: No worries.  Thank you guys for having me.

**Mike Schmidt**: Next segment of the newsletter is our monthly segment on
client and service software updates, things that we think are interesting
developments or adoption of Bitcoin tech that we want to surface for the
community.

_Bitcoin-like Script Symbolic Tracer (B'SST) released_

The first one here is Bitcoin-like Script Symbolic Tracer, which is acronymed as
B'SST.  And this is a tool that, "Symbolically executes opcodes, tracks
constraints that opcodes impose on values they operate on, and shows the report
with conditions that the script enforces, possible failures, or possible values
for data, etc".  So, you feed it either a Bitcoin script or the element script,
which is the basis of the Liquid sidechain, and you can provide those scripts to
this tool, which is written in Python, and it will analyze that script and
provide you some interesting report with those different conditions and possible
failures.  Murch, did you look at B'SST?

**Mark Erhardt**: Just very briefly.  I think it's probably interesting in the
context of the ways that people might consider making output script descriptors
in the future.  It's maybe also interesting in the discussion of what sort of
new opcodes we want to introduce for introspection or covenants, because a bunch
of those are, for example, already in elements.  So, that's just the ideas that
come to mind when I read about this, but I haven't looked too much at it.

_STARK header chain verifier demo_

**Mike Schmidt**: The next piece of software that we highlighted was a demo that
was put together by the ZeroSync project.  We covered a ZeroSync item in
Newsletter #222, if you're curious.  We spoke about ZeroSync and their project
of using utreexo and STARK proofs to sync a Bitcoin node, like you would do in
Initial Block Download (IBD).  And this demo that they have that we highlighted
this week is a demonstration of using STARKs to prove and verify a chain of
Bitcoin block headers.  So, they're just proving the chain of headers, they're
not doing the whole blocks yet.  I think there's a lot of resource intensity
that goes into that, so they're starting with just the chain of Bitcoin block
headers.  So, I thought that was interesting.  There's a lot of talk about
STARKs and these sorts of proofs lately, so that was a cool demo.  So, check it
out if you're curious about some of this syncing that they're working on.

**Mark Erhardt**: Yeah, one of the interesting applications here would be, of
course, if you can prove that you have processed correctly the entire header
chain, and that potentially then in the future you have also processed the
entire blockchain correctly, and you can tie that to a UTXO set, for example;
that would be another way of how you could very quickly bootstrap a full node to
the current state of the network.

**Mike Schmidt**: It seems like there's a lot of different projects working on
things like this to get somebody up and running with a node that is eventually
fully validating, but there's maybe some shortcuts in between.  So, good to see.

**Mark Erhardt**: Yeah, I think this one actually would also work very well to
make light clients less trustful.  So, if you can prove that you have correctly
processed the header chain, and then you can prove that a transaction is
committed to by that header chain, then that would be a completely different
light client model.

_JoinMarket v0.9.10 released_

**Mike Schmidt**: Next piece of software is JoinMarket.  In their v0.9.10
release, they added support for RBF.  JoinMarket is a coinjoin software and the
RBF support that they've added is not relevant to the coinjoin transactions and
fee bumping, but non-coinjoin transactions can now be fee bumped.  And this
release also included some fee estimation updates and some other improvements as
well.

_Machankura announces additive batching feature_

I will probably butcher the name of this next piece of software, so I apologize
in advance to the team, but Machankura announces additive batching feature, and
so this is an interesting site.  I think they provide a lot of Bitcoin-related
services in areas where maybe there's not a lot of cell coverage, or there is
cell coverage, but maybe not a lot of Wi-Fi, people are working on more
traditional phones.  You can interact with Bitcoin using sort of a flip phone
kind of thing.  And so they have the ability to buy and sell, I believe, and
transact.  I think there's also a web interface for their service as well.

What we talked about that they announced on Twitter recently was a beta feature
that supports additive batching using RBF, and they're doing that in a taproot
wallet that has a FROST threshold spending condition.  So, a lot of good Bitcoin
tech in there, in their beta feature.  If you look at the tweet thread in which
they announced this, they gave an example of the additive batching, which the
example was, there was an initial user that wanted to withdraw 21,000 sats and
so they showed a screenshot on mempool.space of that initial transaction, and
then they then fee bumped using RBF and added an additional withdrawal,
potentially for a different user, for 22,000 sats.  And you see that UTXO being
added, and then a third one for 23,000 sats.  Murch, any comments on additive
batching or my explanation of additive batching using RBF?

**Mark Erhardt**: I think it's pretty cool that people are building this sort of
stuff.  I think, sure, RBF came out in 2013, but there's really only after this
block space market that we have been seeing this year, I think more people are
exploring how they can leverage RBF to improve their operations.  And so, CPFP
has been adopted way more broadly, but of course CPFP comes with the downside of
needing to have another transaction and thus buying more block space when you
want to bump an existing transaction.  So, with the RBF batching, you just add
the output to an existing transaction.  You also increase the fees, so you may
have trade-offs at some points.  It might become better to CPFP again instead of
RBFing or starting a new additive batch, but yeah, I think this is just a sign
of people making more use of the tools that they have because the market
conditions have changed.

_SimLN Lightning simulation tool_

**Mike Schmidt**: Necessity is the mother of invention, right?  The last piece
of software that we highlighted this week was SimLN, which is a Lightning
simulation tool.  We spoke about a similar effort maybe a month ago, which is
called Scaling Lightning, and they were, I think, trying to figure out a way to
spin up Kubernetes with a bunch of different Lightning implementations and maybe
even different versions with different things supported, and using that as a
developer tool to test changes in those different implementations, by executing
a bunch of different scenarios and then being able to do that in a collaborative
way.

But SimLN is a Rust simulation tool that generates realistic Lightning payment
activity.  And in this initial release that we covered, it supports LND and Core
Lightning (CLN) implementations, but there's also work being done already on
Eclair and the LDK Node node as well.  And in the description of the project, I
saw, "It is intentionally environment-agnostic so that it can be used across
many environments, from integration tests to public signets".  And so, this may
be a useful tool if you are one of the following: a protocol developer looking
to test proposals, an application developer load-testing your application, a
signet operator interested in a hands-off way to run an active node, or a
researcher generating synthetic data for a target topology.  And those were four
different use cases that I read from the writeup on GitHub.  Murch, are you
familiar with the SimLN tool?

**Mark Erhardt**: Yeah, I heard someone talk about it recently.  So, some of my
colleagues worked on this.  The interesting thing here is also that you can do
some live compatibility testing here, right?  So, by having a simulated network
that is not just one type of implementation, you could, for example, have old
versions and new versions of the same node software.  You could have different
node software interacting, and you can automate activities.  So, for example,
one user might send a transaction at a specific interval for a specific amount,
some other nodes might randomly send or not send at specific intervals, the
amounts might change.

So, you'll naturally get into situations where maybe some channels are exhausted
in one direction but not in the other.  And you might just be able to see, do
all the nodes properly resolve this sort of behavior with each other, even
across different software bases.  You might be able to sort of test the jamming
mitigation proposals that have been worked on for quite some time.  That sort of
thing is the background here.

**Mike Schmidt**: Great examples, Murch, thanks for clarifying and adding to
that.  Next segment of the newsletter is Releases and release candidates.  We
have two --

**Mark Erhardt**: I think we omitted BitBox.  How about we do that stuff?

_BitBox adds miniscript_

**Mike Schmidt**: Oh, I did.  Thank you for catching that.  Back to the client
and services section.  BitBox adds miniscript.  So, the Bitbox02 firmware adds
support for miniscript and security fix and some usability improvements.  So,
the Bitbox02 is a hardware signing device, and with the proliferation of
miniscript getting a lot of uptake lately, they've added support for miniscript.
So, now you can sign with your BitBox.  Murch, do you want to shill miniscript
at all?

**Mark Erhardt**: I think this is another one of those Legos that we have put
into our protocol stack that we will still have to wait a little bit to see the
outcomes of.  So, you basically get a high-level language that compiles down to
a Bitcoin script that you can use to describe output script descriptors.  So,
when you want to, for example, make a decaying multisig that at first starts out
as a 2-of-3 multisig, after a few months becomes a 1-of-3 multisig, you could
specify that in a higher level language that's much more human readable, and it
would give you the optimal script expression to put that into your output
script.  And so, there's a bunch of wallets now that have built support for
this.  We are still waiting for a tapscript miniscript support; that's coming
soon, hopefully.

But I assume that as this matures and people are aware of the availability, they
will start using this to make more creative solutions, for example, for
inheritance planning, or for just key-loss scenarios where as long as you move
your funds often enough, it's always pretty secure with a 2-of-3 multisig or
maybe a 3-of-5, but then over time, if you can't move your coins, it might
become easier to move that, so you don't ever completely lose your access.  So,
we've seen, for example, the Liana wallet by Wizardsardine dig into that
concept.  I've also seen a demo recently by, I think it was AnchorWatch, that
has a drag-and-drop editor for miniscript, which I thought was really cool as
well.

So, it'll take some time for all of this to arrive for the user, but when it
does, it just makes it a lot easier for developers to be expressive in what they
want their scripts to do.

**Mike Schmidt**: As part of Optech's effort to educate and provide insights and
lessons learned from Bitcoin businesses about Bitcoin tech to other businesses,
I'll give you a sneak preview that we have a miniscript field report that is
currently under construction that will go through some lessons learned with
rolling out a miniscript heavy piece of software, from some of the pioneer
software providers in the miniscript space.  So, look forward to that in a few
weeks.

_Core Lightning 23.08.1_

Okay, now actually to the Releases and release candidates section.  Core
Lightning 23.08.1, which is a maintenance release for CLN, fixes a few bugs.  A
couple that I saw that might be interesting for folks is that the CLNRest tool
that we talked about a few weeks ago, that allows you to interact with your CLN
node via REST, now it works on macOS, so I think that maybe wasn't possible
previously.  And there were also some minor fixes to the renepay plugin that we
covered in a previous podcast as well.

_LND v0.17.0-beta.rc4_

Next release is LND v0.17.0-beta.rc4.  We spoke with roasbeef about this release
a bit last week.  So, if you're curious jump back to podcast #268 for that
discussion, and listen to it on perhaps half speed, you get more details about
this particular release!

Moving on to Notable code and documentation changes, I'll take the opportunity
to solicit from the audience, if you have any questions, feel free to type them
in this tweet thread, or you're also free to request speaker access, and we'll
try to get to your question at the end of our discussion.

_Bitcoin Core #26152_

First PR is Bitcoin Core #26152.  Murch, congrats on getting this merged.  This
is your PR, so I'll let you describe the PR and the issue that it resolves.

**Mark Erhardt**: Yeah, okay, so I've been working on this for a while.  The
idea here is when you use your UTXOs to create a transaction, Bitcoin Core used
to always treat all UTXOs as if they were confirmed already for fee purposes.
However, when you have an unconfirmed UTXO that is created by an existing
transaction with a low feerate and you use that to build a new transaction, you
might actually underestimate the necessary fees to achieve the feerate that you
intend.  So, you're probably in a situation there then that you create a CPFP,
but you didn't account for the bump fee that you need to elevate the parent
transaction to the current feerate.  And so, I had a few collaborators that
heavily helped with this effort.

A few months ago, we already got the first part of this merged, which is the
calculation of how much fees it would cost to elevate or reprioritize an
ancestor structure to a certain feerate.  And with this PR, we also put it into
the wallet, where the wallet will now use it to calculate the effective value of
UTXOs.  So, when you spend a UTXO that is encumbered by a low-fee parent, then
it will already estimate in the effective value how much it has to pay extra to
bump the parent to the same feerate.  And yeah, so if you, for example,
explicitly choose to pay or to use an unconfirmed input in a payment, you will
now automatically bump the parent transaction to the same feerate as the new
transaction you're building and hopefully that, for example, fixes issues around
when you accidentally have a consolidation transaction and then try to make an
urgent payment, or when you otherwise are forced to spend an unconfirmed input
that you might not even get into the mempool because it's below the dynamic
minimum mempool feerate.  Sorry, it would fix that part maybe by not using the
UTXO, because we account for the cost correctly and deprioritize it.

But, yeah, it's been a big lift, a lot has been written about it.  There's even
a video for people that were interested in reviewing it.  We did also a Bitcoin
Core Code Review Club on it.  So, if you're interested in it, you'll find a lot
of links with more information in the PR.

**Mike Schmidt**: Excellent, congratulations, Murch.  And that sounds like quite
a useful feature.

**Mark Erhardt**: No, it's a bug fix!

**Mike Schmidt**: Well, true, yes.  You can actually use a CPFP feature
correctly; what a novel idea!

**Mark Erhardt**: Well, we actually don't have a CPFP RPC yet, but we can build
one now.

_Bitcoin Core #28414_

**Mike Schmidt**: Soon.  Bitcoin Core 28414.  As part of the PSBT workflow,
there's a walletprocesspsbt RPC that currently returns Base64-encoded PSBT,
along with a boolean indicating if the transaction is, "Complete".  So, you
already potentially have a complete and finalized transaction at that point, but
you would then have to call the finalizepsbt, even though you already have a
finalized transaction.  In theory, the walletprocesspsbt could finalize the
transaction for you and provide you the final hex of the transaction, and that's
exactly what this PR does.  So, with this PR, walletprocesspsbt returns an
object and will also include the broadcastable hex string if the transaction is
already final.  So, that obviously saves users an extra step of calling that
finalizepsbt command.

**Mark Erhardt**: Yeah, and also to explain what walletprocesspsbt does, this is
essentially the follow-up or the cousin of signrawtransaction.  When you pass a
PSBT to the wallet, the wallet will add all the information it has about the
parts of the PSBT that concern it, and will sign the parts where it has the
private keys.  So, if someone has built, for example, a PSBT for an external
wallet or for a multiparty process and then passes it around, with
walletprocesspsbt, you would be adding the signatures to it.  And then of
course, if all of the signatures are there, we would also be returning the hex
at this point.

_Bitcoin Core #28448_

**Mike Schmidt**: Next PR is Bitcoin Core #28448, which deprecates the
rpcserialversion configuration parameter.  And that is an option that allows
users to specify the format of the raw transaction or the block hex
serialization.  So, this was something that was originally introduced during the
transition to v0 of segwit to allow users to continue to access blocks and
transactions but without any segwit fields.  But given that segwit was activated
in 2017, probably most people have upgraded, so this option is now being
deprecated.  And if you're somebody who's still using this, you can re-enable it
for now using the -deprecatedrpc option and providing that configuration
parameter, the rpcserialversion.

**Mark Erhardt**: And to explain again here, this is not affecting the Bitcoin
Core version that you have deployed.  This will be shipped in 0.26, which
hopefully we will see in November.

_Bitcoin Core #28196_

**Mike Schmidt**: Next PR is also to the Bitcoin Core repository, #28196.  This
is a PR that is part of BIP324, the encrypted transport protocol that
opportunistically encrypts traffic between nodes, and we spoke with Pieter
Wuille last week, on podcast #268, about BIP324, so check that out if you missed
it, it's always good to hear Pieter talk.  And this PR implements all of what
the BIP calls, "The transport layer and the application layer".  And it notes
that it does that in a non-exposed way, meaning that you can't use BIP324 yet,
there's still some things to do to enable that.  And this PR also includes, "An
extensive fuzz test, which verifies that v2 transports can talk to v2
transports, and v1 transports can talk to v2 transports, and a unit test that
exercises a number of unusual scenarios".

What is left to do to complete the 324, since this adds a lot of meat, but
doesn't actually allow you to use it, we need to, "Actually use the v2
transports for connections", this is from the PR itself, what's remaining,
"support the NODE_P2P_V2 service flag, retry downgrade to V1 when attempted
outbound V2 connections immediately fail", and then also some P2P functional and
unit tests need to still be added in order for BIP324 to be officially enabled.
Murch, thoughts?

**Mark Erhardt**: Yes, so it sounds like it's essentially one more commit in
order to be feature complete, and I'm not sure if the service flag has been
picked, but that would be then added and it looks currently like that it might
ship with 0.26.  So, we might be able to start encrypting all of our traffic
with the upcoming release in November.

**Mike Schmidt**: Amazing, a ton of work, a long time coming, a lot of different
people contributing, so it's good to see that project moving along.

_Eclair #2743_

Next PR is to Eclair repository, #2743.  Eclair nodes currently already provide
automatic fee bumping, but this PR adds a fee bumping RPC, called
bumpforceclose, that allows users to manually fee bump an anchor output from a
channel to use CPFP to bump that commitment transaction.  So, a manual way to
do, it sounds like, what they are already doing automatically in some cases.

_LDK #2176_

Next PR is to the LDK repository, #2176.  LDK currently stores a bunch of
historical estimates of channel liquidity in 8 evenly sized buckets.  That
allows LDK to somewhat guess the amount of liquidity available in distant
channels that it's attempted to route payments through previously.  And the PR
notes, "This lacks precision, especially at the edges of channels where
liquidity is expected to lie".  So, this PR, "Rips out the existing buckets,
those 8 buckets of equal size, and replaces them with 32 unequal sized buckets,
which allows LDK to focus their precision at the edges of a channel (where the
liquidity is likely to lie and where the precision helps the most)".  And I
think there were some figures and numbers around these liquidity numbers in the
writeup, but I also cherry-picked some of these quotes from the PR itself.

The PR noted that the change does slow down routing performance a bit, and
they're estimating that it's a 5% to 8% performance reduction in order to
achieve that more accurate granularity of liquidity estimates.

_LDK #2413_

Next PR is also to the LDK repository, #2413, which also references LDK #2514,
which adds support to LDK for sending two blinded payment paths and also for
receiving to one-hop paths.  And this is part of LDK's BOLT12 offers efforts.
And there is a tracking issue on the LDK repository, which tracks all of the
work that they're doing to support offers, and that is LDK #1970.  So, if you're
curious about tracking issues, like I am, go check that out and you can see that
a lot of progress has been made there and there's just a few things left to roll
this out to LDK.

**Mark Erhardt**: I think it's kind of funny how since you cannot tell how long
a blinded payment path instruction is and you can just wrap your own onion
around it, if you don't know what node software is running the receiving node,
this is indistinguishable from other nodes that may have already multi-hop
blinded path receiving support.  So, even just having single-hop receiving
support, already adds to the anonymity set or to the feature set of people
because they don't know how many hops it is.

_LDK #2371_

**Mike Schmidt**: Last PR is also to LDK, #2371, and this PR is also part of
LDK's BOLT12 implementation.  This one adds support for outbound payments for
paying a BOLT12 invoice.  So, it allows users to one, use an offer to register
its intent to pay an invoice with another node.  It also then can timeout that
payment attempt if a sent offer never results in actually getting the invoice
that you wanted.  And then it uses the existing LDK code to pay that invoice,
including retry mechanisms if the first attempts don't succeed.

That's it for #269.  Murch, any announcements or anything notable before we wrap
up?  I don't see any questions.

**Mark Erhardt**: I don't have any announcements.

**Mike Schmidt**: Well, thanks to Sergi for joining us and thanks always to my
co-host, Murch, and for you all taking the time out of your day to listen about
Bitcoin technology in our Twitter Space.  Cheers.

{% include references.md %}
