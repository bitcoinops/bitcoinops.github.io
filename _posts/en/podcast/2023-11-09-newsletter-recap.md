---
title: 'Bitcoin Optech Newsletter #276 Recap Podcast'
permalink: /en/podcast/2023/11/09/
reference: /en/newsletters/2023/11/08/
name: 2023-11-09-recap
slug: 2023-11-09-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Johan Torås Halseth and
Abubakar Ismail to discuss [Newsletter #276]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-10-9/354837573-22050-1-43d565cf4b3e4.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #276 Recap on
Twitter Spaces.  Today we're going to be discussing the mailing list and looking
for a new host for the Bitcoin-Dev and potentially Lightning-Dev mailing lists,
HTLC aggregation with covenants, a Bitcoin Core PR Review Club that covers
performance improvements around fee estimation, the Bitcoin Core 26.0rc2, and
more.  I'm Mike Schmidt, I'm a contributor at Optech and also Executive Director
at Brink, funding open-source Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I'm an engineer at Chaincode Labs and a
moderator on Bitcoin Stack Exchange.

**Mike Schmidt**: Johan?

**Johan Torås Halseth**: Hi, I'm Johan, I'm an open-source engineer at NYDIG,
working on Bitcoin and Lightning primarily.

**Mike Schmidt**: Abubakar?

**Abubakar Sadiq Ismail**: Hi everyone, I'm Abubakar Sadiq Ismail, Bitcoin
co-Contributor, supported by Btrust Builders.

_Mailing list hosting_

**Mike Schmidt**: Thank you both for joining us this week.  We're going to run
through the newsletter sequentially here, starting with the topic, Mailing list
hosting.  So, there was a post to the mailing list about the mailing list, and
as folks may know, when visiting the archives, you'll see that the Linux
Foundation has been kind enough to host the mailing list, as well as web
archives of the mailing list discussion.  And I think there's been some effort
on their part to not do that hosting for open-source projects any longer.  I
think even as early as 2017, there's been some discussion about them wanting to
not do that any longer, and now it's actually come to fruition that they've sort
of given the, "End of year, we're going to shut down the mailing list
functionality".  So, archives will continue to be hosted at the Linux
Foundation, including the existing URLs, which is nice because it would be a
nightmare for all of those reference discussions to either have their URLs
changed or have broken links for all of that.  So, that's great, but the mailing
list functionality, the emailing functionality, is going to be going away.

So, the post was made outlining the situation and some options about how to move
forward.  I thought in reading the posts to the mailing list about hosting
mailing list discussions moving forward, it's evident just how conscientious the
Bitcoin Development participants are.  If you read the full writeup, there's
just a bunch of great consideration around making sure people can have backups
in a future state, making sure that there's accessibility for everybody, making
sure that there's privacy options and that censorship is minimized in these
considerations.  Murch, I don't know if you dug into this topic or have been
following some of the IRC discussion around this?

**Mark Erhardt**: Not too much, but maybe just to provide some context on why
the mailing list is important.  While many projects have their own communication
channels to work on tickets and PRs and like to debate the roadmap of their own
project, this is basically the only place that is institutionalized to announce
new releases, well not even new releases, but just work on BIPs and things that
concern the entire Bitcoin ecosystem.  So for example, in the BIP process, one
of the required steps is an announcement to the mailing list in order to make
sure that all the affected parties have seen the BIP and can chime in.  So, the
Bitcoin-Developer mailing list sort of has this announcement function to make
sure that all of the basically unorganized interested parties have a central way
of learning about what's going on.

**Mike Schmidt**: Yeah, that's good context.  And I would recommend it's not a
technical writeup, but I would recommend folks look at this post in its
entirety.  It goes into a lot of different considerations.  You may think, "Oh,
just run your own mailing list software and email server".  There's just a lot
more that goes into this, and I think it's interesting to read through that.
So, I'd recommend folks do that.  As we've noted in previous newsletters,
unrelated to this mailing list hosting issue, that a bunch of the discussions
around new Bitcoin proposals or Bitcoin technology has been happening on the
Delving Bitcoin web forum.  And so, that is actually mentioned I think in this
writeup as well, but it seems like some of the discussion's already sort of
peeling off into some different medium.  And we know that Optech and Dave, who
sources the material for the news section, is looking at particular parts of the
Delving Bitcoin Forum to pull out news items for Bitcoin Optech.  Anything else
to add, Murch?  Okay, thumbs up.

_HTLC aggregation with covenants_

Next news item from the newsletter is HTLC aggregation with covenants.  Johan
posted to the mailing list an idea about using covenants to aggregate multiple
Hash Time Locked Contracts (HTLCs) into a single output.  Luckily, we have Johan
here, author of the post and idea, and Johan, maybe to start, what does
aggregating multiple HTLCs into a single output actually mean?  And then maybe
we can get into the mechanics of it.

**Johan Torås Halseth**: Yeah.  So, thanks for reading through that long post I
posted.  Hopefully, it had some good ideas that we could use going forward when
we design new covenants or changes to Bitcoin Script.  So, the main idea about
doing HTLC aggregation is that we can, in LN today, every time you get an HTLC,
I won't go into details of what an HTLC is, but I could do that if people want,
then you actually have to create a new output on the commitment transaction.
And the problem here is that that's expensive and for small payments that
doesn't really work, especially in a high fee environment.

So, the idea about HTLC aggregation is that instead of adding a new output to
the commitment every time there's a new HTLC, you just increase the value of a
single HTLC output on the commitment.  And that has some real good benefits,
especially it gets much cheaper.  The commitment won't increase in size, and
that also simplifies protocol development a lot because you don't have to
account for this commitment having a larger size, based on the number of HTLCs
that are going through the node.  So, that's the main benefit, it's the cost
reduction of having just a single output in contrast to a lot of outputs on the
commitment.  And as a result from this as well, you also make certain types of
attacks harder to do, especially the one called channel jamming with slots,
since the point of doing channel jamming, like what's called slot jamming, is
that you can increase the commitment transaction size so much that a node needs
to stop forwarding HTLCs because the commitment gets too large.  And that
wouldn't be possible with a change like this.

**Mike Schmidt**: Maybe a quick tangent, what are other existing proposals to do
HTLC aggregation, if any?

**Johan Torås Halseth**: I don't think there has been really.  We haven't really
been looking at -- so that was kind of the point of this post as well, to look a
little bit into the future and assuming if we get a covenant enabled on Bitcoin
at some point, what kind of changes would we do to LN in order to take advantage
of this new functionality.  So, I think most future LN spec development has been
around ANYPREVOUT and eltoo, which is a great change and simplifies a lot of the
protocol in LN as well.  But we haven't really looked at what does this mean for
HTLCs and the HTLC outputs on the commitment.

**Mike Schmidt**: So, we went over the benefits, both in terms of channel
jamming and other, but I'm curious about the mechanics.  You mentioned that
there is some sort of a covenant required here.  Does your proposal outline a
particular covenant, or just the properties of a covenant that would enable this
type of functionality?

**Johan Torås Halseth**: Yes, so I've implemented a proof of concept of this and
for that, I've been using OP_CHECKCONTRACTVERIFY, which is part of the MATT
proposal by Salvatore, and he's also here, I see.  But I think you could do this
with many of the covenant proposals, as long as you have a recursive covenant.
Because the idea here is that you have some data in the input, you peel off some
HTLC of some value from the input, and then you send the rest to the same
covenant in the output.  So, as long as you have a recursive covenant, I think
you should be able to do this.  OP_CHECKCONTRACTVERIFY makes it very simple
because it has this notion of having some embedded data in the input, but I'm
pretty sure you could do it with something like CHECKSIGFROMSTACK or OP_TXHASH
as well.

**Mike Schmidt**: I see in the writeup, and you've mentioned it just now, that
you do have a demo/proof of concept doing this.  So, if folks are interested in
playing around with this, they can jump in and play with that; is that right?

**Johan Torås Halseth**: Yeah, that's right.  It should be linked in the mailing
list post.

**Mike Schmidt**: So, one downside, maybe not a downside, but I guess the fact
that there's a prerequisite on this covenant is, maybe it could be seen as a
downside.  But assuming that we had this type of covenant implemented, what
would be the considerations of other potential downsides or things to keep in
mind or limitations if this were in place?

**Johan Torås Halseth**: I think it's sort of like a strictly beneficial change
in terms of LN.  It's also like a local change, so you wouldn't need a
network-wide upgrade on LN to start using this.  You only need to agree with
your channel peer that you move to this kind of HTLC format.  Other than that,
it's obviously making a protocol change on LN as well as on Bitcoin.  It takes a
lot of time, a lot of testing.  So, assuming we had a covenant tomorrow, I
wouldn't start implementing and rolling this out right away.  There's also so
many more improvements we can make to LN if we have a new opcode and a covenant.
So, I think it would take some time to actually flesh out the various ways we
could upgrade LN if that was the case.

**Mike Schmidt**: So, we linked to the Lightning-Dev mailing list post that you
had, and I don't see that there's been any responses there.  Perhaps you've
gotten feedback offline or elsewhere about the idea, and if so, maybe you can
outline what that feedback's been?

**Johan Torås Halseth**: Yes, I've gotten some feedback, and it's mainly about
the idea in general, "If you have this, then that would be beneficial for LN".
I think I haven't gotten any feedback on the actual technical details of
implementing it this way.  I am sorry, the post got pretty long, because it
outlined different use cases of this change.  So, I think it takes some time to
for people to grok it perhaps.  And my idea was also to just get people thinking
about what we can do in LN if we had covenants.

**Mike Schmidt**: Great.  Murch, do you have any questions or comments?

**Mark Erhardt**: Yeah.  So, I've looked a little bit, very briefly, at this
mailing list post, and one thing that isn't quite clear to me yet is how do you
go back from the single HTLC output to executing or not executing each HTLC in
the according direction, depending on what happened upstream or downstream?  So,
clearly each HTLC depends on whether the payment went through upstream or
didn't, and then has to be folded either to one side or the other.  So, if you
had folded everything together into that single HTLC, do you fan it back out to
resolve the HTLCs; or how do you envision that?

**Johan Torås Halseth**: No, so you wouldn't have to fan out at any point.  You
only consume the aggregated HTLC output, then you take whatever value you claim
into your own output, and then you send the rest back to a recursive aggregated
HTLC output.  So, how that would work from an offered or received HTLC point is
that you have two or more scriptpaths in the taproot output.  So, if you're in
the timeout case, you do one of the scriptpaths; if you're in the offered case,
you do another one of the scriptpaths; and then you send it back to the same, in
my example, you don't modify the tapscript tree at all, you just kind of empty
out the HTLCs you claimed, and then you send the rest of it back to the same
tapscript tree.

**Mark Erhardt**: So, basically, you're just peeling off the ones that you can
settle already, and the remainder goes back into the caching state where they
can be peeled off later once they resolve?

**Johan Torås Halseth**: Exactly.  So, the way I did this, I encoded in a merkle
tree, and the merkle tree also includes the value of the HTLC.  So, in order to
claim an HTLC, we can enforce in the script that you set the value of this HTLC
to zero in the new output.  So, that means that you cannot claim it anymore, or
you could, but it's a zero-value HTLC.  So, that wouldn't be a point in doing
that.

**Mike Schmidt**: Johan, any calls to action for the audience, other than
parsing through our writeup and your longer write-up on the mailing list and
potentially playing around with the prototype?

**Johan Torås Halseth**:  Yeah, I think playing around with it, just look at the
idea.  And also, one thing it seems like all these kinds of covenant proposals
would need at some point is a way to do 64-bit arithmetics.  So, that's also
something that will be great to start looking at again if we want to enable that
on Bitcoin, because that seems like a no-brainer to me.

**Mike Schmidt**: Well, thanks, Johan, for joining us.  You're welcome to stay
on as we go through the rest of the newsletter.  If you have other things to do,
you can drop.

**Johan Torås Halseth**: Sure.  Thanks for having me.

_Fee Estimator updates from Validation Interface/CScheduler thread_

**Mike Schmidt**: Moving out of the news section and on to our monthly segment
that highlights a Bitcoin Core PR review club session.  This month we
highlighted, "Fee Estimator updates from Validation Interface/CScheduler
thread".  And the PR author, as well as the host for this PR Review Club, is
here this week to chat with us.  Abubakar, at a high level this PR modifies the
way the transaction fee estimator data is updated.  Maybe as a place to start,
what was wrong with the way that the fee estimator data was updated previously?

**Abubakar Sadiq Ismail**: Thank you very much, Mike.  So previously, the fee
estimator updates are from the mempool.  So, the fee estimator is a member of
the mempool, so whenever a new block arrives, we update the fee estimator
directly from the mempool which slows down block processing, and in turn also
delays block relay to other peers.  So, we will always want to finish block
processing fast.  And also, it will be inefficient to add other complex steps
during the fee estimator update previously.  So, this PR is intended to enable
the fee estimator to listen to validation interface notifications to process new
transactions that are added and removed from the mempool.

**Mike Schmidt**: So, it sounds like at the time that a block is being received
and processed, that there was also, at the same time, some fee estimation code
that was running that was potentially slowing down the processing and then
propagation there of that block; is that right?  And so what you've done is
separated out that fee estimation, or at least the updating of the data around
fee estimation, to not be blocking the processing of that block; do I have that
right?

**Abubakar Sadiq Ismail**: Yes, previously it is updating synchronously whenever
we are processing new blocks.

**Mike Schmidt**: How did you come across this as an issue that you could
potentially work on?  I'm curious, I know it's a non-technical question, but I
just was curious.

**Abubakar Sadiq Ismail**: Yeah, it's basically there was attempt to the
solution previously.  So, it is up for grabs for everyone to work on.  So, it
seems like a nice issue that I think needs to be solved.  So, I think BlueMatt
is the author that worked on it previously.  But previously, it is not only
attempting to update the fee estimator from validation interface, it is also
splitting the validation interface into two, whereby we have validation
interface and mempool interface.  What the PR intends to do is to have all
notifications from validation events coming from the validation interface, and
all notifications that are from mempool events will come from mempool interface.
There are also some refactors and other changes.  Previously, it's a pretty huge
PR, but this PR is only focusing on updating the fee estimator from validation
interface notifications.

**Mike Schmidt**: Okay, so this original PR, this one from 2017 from BlueMatt,
#11775, did something similar, but it maybe was a bit more ambitious and didn't
get merged due to the other things that were in there.  So, you took the
motivation behind that PR with respect to fee estimator updates and spun it off
into its own PR.

**Abubakar Sadiq Ismail**: Yes.

**Mike Schmidt**: Okay, great.  We highlighted, I think, nine different
questions from the PR Review Club, and usually we don't jump into all of those,
because they're usually somewhat technical and harder to follow on audio.  But
if folks are interested in the high level that you've given here, Abubakar, I
would encourage them to jump into that Q&A that we have in the newsletter, as
well as the transcripts for this particular PR Review Club meeting.  But of
those questions that were asked, and maybe even the broader discussion that was
had in the PR Review Club, are there interesting pieces that you think would be
worthy of highlighting for the audience, Abubakar?

**Abubakar Sadiq Ismail**: Yeah, I think the interesting thing that we discussed
about it is the benefits of having CTxMempool as an internal component of the
mempool, which means that CTxMempool will have access to all the mempool
transaction data.  In the future whereby we want to add other fee estimator
features, it will be much easier to do that because it will have access to
CTxMempool entry.  But with this PR, there is a new struct that I created, which
is NewMempoolTransactionInfo, whereby we only add the transaction data that the
fee estimator needs and add it to the validation interface with the creation
callback that the fee estimator will update from.  So, that's one of the, I
think, drawbacks, but the fee estimator does not need all that information.  It
only needs the base fee, the fee size, and the time that the transaction was
added to the mempool.

**Mike Schmidt**: Murch, obviously you do a lot with fees and fee estimations
and feerates.  I'm not sure if you have comments or questions on this particular
change or some of the context behind it.

**Mark Erhardt**: Well, it does sound great to me that it would be removed from
the block validation chain and sort of asynchronously attached to the process,
so that fee estimation no longer has to be finished before we forward a block.
In the broader context, of course, the latency by which each new block is
received by all the nodes affects directly the mining revenue of smaller miners
and also the chance of just getting tied or conflicting chain tips.  So, making
block validation and block forwarding as fast as possible should be generally
one of our goals to make mining as fair as possible.  So, I haven't reviewed
this PR directly, but what Abubakar is trying to achieve here makes a lot of
sense to me.

**Mike Schmidt**: Abubakar, on that note, are there any metrics that you've come
up with about how much faster or what potential impacts there would be that are
quantifiable with regards to this PR?

**Abubakar Sadiq Ismail**: No, I have not run any benchmarks yet, but there are
some comments in the PR that are asking for benchmarks.  But I think high level,
this is beneficial and people really want it in, even without the benchmark.
But yeah, it will be interesting to see how this PR will improve locally.

**Mike Schmidt**: From your perspective, well actually maybe for the audience,
as of this recording this PR is still open and feedback is being provided and
changes are being made accordingly.  Abubakar, what would you say is any holdup
to getting this in?  Is there any particular contention or things that needs to
be updated, or is it just a matter of addressing some smaller review comments?

**Abubakar Sadiq Ismail**: Yeah, I think it's review comments.  It has gone
through various rounds of reviews, has some ACKs from I think TheCharlatan and
only TheCharlatan ACKs the PR, but it was invalidated after a review from
Gloria, so it's currently on review and I will appreciate any comments or
feedback on the work so far.

**Mike Schmidt**: Excellent.  Before we move on, Abubakar, anything else that
you think people should be aware of around this PR?  Otherwise, we'll move on in
the newsletter.

**Abubakar Sadiq Ismail**: No, I think it's fine.  Everyone who is interested
should go to the GitHub repo.

**Mike Schmidt**: Thanks for joining us, Abubakar, you're welcome to stay on or
if you need to drop, we understand.  Next section from the newsletter is
Releases and release candidates.  We have three this week.

_Bitcoin Core 26.0rc2_

The first one is Bitcoin Core 26.0rc2.  I'm going to take the opportunity now to
plug our podcast from #274, specifically the podcast and not the newsletter,
because Murch went through a thorough tour of the 26.0 changes and some of the
release notes, so I would advise folks if you're curious what is this new
release, what's in there, what are the high-level new features and changes,
check out the audio or the written transcription of his verbal overview as a
good starting place.  We also note in the newsletter this week that if you're
curious about how to test this RC as an end user, that the Bitcoin Core PR
Review Club that we just went through with Abubakar, there's going to be a
session on that dedicated to testing this release candidate on November 15, so
just in less than a week.

So, this is something that I think is approachable regardless of your technical
skills.  You can jump in and go through how to think about testing and mechanics
of actually executing testing as an end user and providing feedback.  Murch, any
commentary on the RC2 binaries being out and the Review Club dedicated to
testing?

**Mark Erhardt**: Yes, I just wanted to point out that currently the link
appears to be going to the wrong page and we will fix that shortly.  But there
is a fairly extensive RC Testing Guide already, and it goes into some detail on
now currently nine different new features that could be tested.  For example, it
walks you through how to install the RC in the first place, then how to connect
to a BIP324 node that enables v2 transport and some tests around that.  There's
basically for the nine different topics a few small steps on how you can test
those.  This is just a starting point; if you want to test more you can
obviously just play around with these things more, and we will fix the link in
the newsletter shortly.

**Mike Schmidt**: Which link is it; the one to the wiki that's incorrect?

**Mark Erhardt**: Yeah, it seems to be going to an empty page and be missing the
words, "Release Candidate" before testing.

**Mike Schmidt**: Yeah, I see that Max Edwards made some substantial changes to
the RC Testing Guide in the last two hours, and so that would be a great link
for folks as well.  I suspect we'll be covering this Testing Guide maybe a bit
more.  Hopefully we can get Max on maybe for next week or shortly thereafter to
go through some of this in person.  I know we've done that previously with some
of the testing guides, so looking forward to that.

_Core Lightning 23.11rc1_

Next release is to Core Lightning (CLN).  It's actually an RC for 23.11.  It's
the RC1, codenamed Bitcoin Orange Paper.  There's a couple of things that I
wanted to highlight it just at a high level without being too much of a spoiler
alert for this release.  This release makes a bunch of additions and changes to
the JSON RPCs.  Too many to go through here, so check out the release notes for
this RC for details if you're using CLN, and a couple notable fixes that are
included in the release.  I believe we talked about one or both of these, but
one is a fix for peer disconnects, and another is related to stuck HTLCs when
using splicing.  So, we would obviously encourage folks who are running CLN to
check out those JSON RPC changes and bug fixes as well, and provide feedback
accordingly.  Murch?

**Mark Erhardt**: Yeah, I just glanced at the release notes earlier, and two
things that jumped out at me was that the configuration has changed in this
release.  Wumbo channels are now default in this CLN release; and another one
that seemed potentially useful to our listeners is, there is now a recover JSON
RPC command, and it will restart an unused lightningd node with the --recover
flag.  So, I don't know exactly what the recover startup option will entail, but
if you need that, you might be happy to hear that it is in this current release.

**Mike Schmidt**: And probably related to this release is the fact that we also
have five CLN PRs that we'll be covering later in the newsletter as well,
including that wumbo/large channel configuration change.

_LND 0.17.1-beta.rc1_

Last release this week is LND 0.17.1-beta.rc1.  I saw three notable things from
this release, one is a reduction in CPU usage due to the new mempool scanning
logic; second one is enhancements to the CPFP logic, specifically around anchor
outputs; and the last one is a bug fix for the new taproot channel type that
they've implemented, that in some situations could have caused a channel to show
as inactive in some situations.  So again, call to any LND node runners to run
this if this is important to your operations, if you're a business, and provide
feedback accordingly.

**Mark Erhardt**: Yeah, it's funny how when the mempool is above 160 sat/vbyte,
suddenly all these fixes for bumping come out.

**Mike Schmidt**: Yeah, necessity is the mother of the invention, right?  Moving
on to Notable code changes.  As I mentioned, there was five from CLN and so it's
obviously nearing CLN release season.

_Core Lightning #6824_

First one is Core Lightning #6824, and this PR is based on a proposed change to
the Lightning protocol, specifically BOLT2, which covers peer protocol and
channel management.  And that BOLT2 proposed change is part of the dual funding
protocol PR that is currently open, and so there's a specific commit related to
this BOLT2 change.  And the BOLT PR notes that there are cases where you can't
reconcile states if there's a disconnection that occurs during the signing
process.  So, in order to mitigate that potential condition, additional state
needs to be stored such that if a disconnect does happen, peers can reconnect
and continue the signing process.  So, all that is from the related BOLT PR.

This particular CLN PR reworks how it reconnects, and how that works for
dual-funding channel opens, and it wants to be in line with the recommendation
from the BOLTs PR, which I think was made by t-bast.  Murch, did you get a
chance to dig into any of this?

**Mark Erhardt**: Sorry, no, I have not.  But well, you know, how do I put this?
Any complex system grows from a very simple kernel idea, and I think that with
dual funding, it seems to be exactly that process once again.  It's a very
simple idea, "Hey, what if both people can add funds?"  And then it turns out
that there are just all these little things that crop up over time as the idea
develops further, and implementations work on trying to make that fit into their
previous processes, all these little kinks crop up and you get all these little
improvements.  And eventually, you get a much more complex solution that does
address the concern comprehensively, but you can't just jump in and immediately
drop in a working solution for something like a protocol like this.  Anyway, I'm
rambling; go on!

_Core Lightning #6783_

**Mike Schmidt**: Next PR is Core Lightning #6783, which deprecates the large
channels configuration option, which is also known historically in some circles
as wumbo channels.  Now, large channels are the new default for all users.  And
some background on this is that originally the spec limited channel sizes to, I
believe, 16 million satoshis.  That was early on in Lightning's iteration and
wanted to prevent loss-of-fund situations with larger amounts of funds.  And I
guess to your point earlier about things maturing, now that option is
essentially enabled.  It's the default enable to use large channels.  So, I
guess that's sort of somewhat a milestone in the Lightning world to say that
they feel that it's confident enough to use larger channels.

**Mark Erhardt**: It's also kind of funny that back when wumbo was first
introduced and limited max channels capacity to one-sixth of a bitcoin, that was
only a few hundred bucks.  And just due to how the overall exchange rate has
evolved, that probably was able to carry demand for a much longer time just
because, well, a sixth of a bitcoin has a lot more value transfer possibility
now than it used to be.

_Core Lightning #6780_

**Mike Schmidt**: Next PR is Core Lightning as well, #6780.  The PR is titled,
"Anchors multi utxo".  And what we wrote in the newsletter is that, "This
improves support for fee bumping onchain transactions associated with anchor
outputs".  And before we jumped on, I tapped Murch on the shoulder to see if he
could dig into this one, since I was not grokking it myself.  So, Murch, I'm not
sure if you were able to grok this?

**Mark Erhardt**: I stared at it a little bit and it seems to me that this
change introduces the capability for bumping anchor outputs with transactions
that have multiple inputs, and it seems that previously CLN would ever only use
a single additional input.  And, well, in cases that you need more funds or your
UTXOs are too fragmented and especially as the fees are currently exploding
upwards again, it seems useful to be able to have multiple inputs on your anchor
output transaction.

So, when you close a channel, one of the big issues is that you are using a
commitment transaction that you may have negotiated many weeks in advance, and
the feerate environment might be completely different at the time that you're
closing the channel versus when you negotiated the commitment transaction.  So,
the anchor outputs, of course, are a mechanism that enables you to attach
another transaction that is unencumbered, because the two local and two remote
outputs are, of course, encumbered so that the person that closes the channel
cannot immediately spend the funds, and the other person has a chance to publish
their justice transaction.

So, in order to make that fair, I think on anchor output closing transactions,
both the remote and local output are locked, and either can use the anchor
output to bump the closing transaction.  And yeah, so this just improves on the
mechanics of using anchor outputs in CLN and allows for more flexibility by
adding more inputs.

_Core Lightning #6773_

**Mike Schmidt**: Next Core Lightning PR is #6773, and this PR enhances backup
functionality by allowing users to verify their already existing backups.  And
instead of a new RPC to do that verification, the decode RPC, which existed
previously, now verifies that the contents of a backup file are valid and
contain the latest information to perform a full recovery, related to the full
recovery feature that Murch outlined in the CLN release.  And there's two pieces
of information that are verified during this backup, the emergency recover and
also peer storage data pieces of data stores are validated and made sure that
they're both up to date.

_Core Lightning #6734_

Last Core Lightning PR, #6734.  So, we need to dig into this one.  So, we did
the writeup as, it updates the listfunds RPC in CLN to provide information
around CPFP fee bumping mutual close transaction.  But looking at the PR this
morning, that doesn't seem to be what Core Lightning #6734 does.  The title of
that PR is, "CPFP for mutual close".  So, I'm going to call this an Optech
review failure and blame myself for either not catching this mismatch, or
alternatively not understanding how this PR pertains to the writeup that we put
in the newsletter.  Murch, I know you took a look at this as well.  I don't know
if you concur with that or maybe we need to get back to the folks on this.

**Mark Erhardt**: I didn't.

**Mike Schmidt**: Okay, it's close enough that it seems correct, but it doesn't
really seem like it affects the listfunds RPC.  So, our bad on this one, guys!

_Eclair #2761_

Last PR this week is to the Eclair repository, #2761.  And quoting t-bast from
the PR, "Splicing and dual funding introduce a new scenario that could not
happen before, where the channel initiator, the one paying the fees for the
commitment transaction, can end up below the channel reserve, or just above the
channel reserve, but any additional HTLCs would make it go below the reserve".
And in that case, it means that most of the channel's funds are on the
non-initiator side of the channel so that, "We should allow HTLCs from the
non-initiator to the initiator to move funds towards the initiator", and that
would result in a more balanced channel where both sides meet the channel
reserve requirement.  And Eclair is allowing the ability to slightly dip into
that channel reserve if that's the case, and they limit that to at most five
pending HTLCs to limit the exposure.

This change that was implemented in Eclair was actually proposed for the LN
spec, but that recommendation was closed because the other LN implementations
didn't like that approach and preferred an alternate approach, which was
tracking the previous channel reserve until the new channel reserve was met.
And so, because the other implementations did it this other way, t-bast said he
didn't like that approach that the other implementations were taking, because it
was awkward to track, and he preferred this option still, and that it achieved
similar benefits by just allowing a few extra HTLCs.  It's a little bit of
discrepancy in how to handle this scenario in the LN implementations.  And
t-bast went on his own, it sounds like.  Murch?

**Mark Erhardt**: Yeah, I was staring at this a little bit, and I was wondering
how a splice could cause the channel initiator to drop below the channel
reserve.  And I think the reason this is happening is, the channel reserve is
required to be 1% of the channel capacity.  And when you add more funds to the
remote side, the overall capacity is increasing, but the initiator's balance is
not increasing, right?  So, when the initiator was already close to the channel
reserve on the old amount and the overall capacity increases, it now may drop
below that 1% of the new capacity by no fault of their own.  And so now, almost
all the funds are on the non-initiator side, and in order to move them over, you
couldn't add an HTLC because that would increase the channel reserve
requirement, because you basically lock in more funds for the fees because the
transaction is getting bigger, and now your channel reserve on the initiator
side is even smaller compared to the overall capacity.

So, that just as context for why this is an issue, and if any LN people find
that I'm misrepresenting that, please leave us feedback in the comments on
Twitter.

**Mike Schmidt**: Well, thanks to our special guests this week, Johan and
Abubakar, for joining us and explaining what they've been working on.  Thanks
always to my co-host, Murch, and thanks to you all for joining us this week.
Murch, any parting words?

**Mark Erhardt**: I will see you in three weeks.  I'm on vacation, bye!

**Mike Schmidt**: Oh yeah, that's right, we won't have Murch for the next few
weeks.  So, I think Dave may be joining us, Dave Harding, so that will be great.
And hopefully we can get by without you, and hopefully you enjoy your time off,
Murch.  Cheers.

{% include references.md %}
