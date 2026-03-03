---
title: 'Bitcoin Optech Newsletter #345 Recap Podcast'
permalink: /en/podcast/2025/03/18/
reference: /en/newsletters/2025/03/14/
name: 2025-03-18-recap
slug: 2025-03-18-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Sindura Saraswathi,
Christian Kümmerle, and Stéphan Vuylsteke to discuss [Newsletter #345]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-2-24/397140581-44100-2-027e35324b3be.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #345 Recap.
Today, we're going to look at an analysis of P2P traffic, we're going to discuss
some new Lightning research on pathfinding, we're going to jump into a new
approach for creating probabilistic payments, and then we have a PR Review Club
covering invalid blocks.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Localhost Research.

**Mike Schmidt**: Sindura?

**Sindura Saraswathi**: Hi, my name is Sindura Saraswathi, I'm a PhD student.  I
work on Lightning and Bitcoin research.

**Mike Schmidt**: Christian?

**Christian Kümmerle**: Hi, I'm Christian Kümmerle, I am a computer scientist
and mathematician, working on machine learning problems, efficiency algorithmic
improvements in terms of AI in a larger scheme, but I'm also really interested
in the LN and contributing to further pushing that technology forward.  In
particular, we've looked at LN pathfinding.

**Mike Schmidt**: Stickies?

**Stéphan Vuylsteke**: Hi, I'm Stéphan, or Stickies.  I am working on Bitcoin
Core, I'm a Brink grantee.  Besides Core, I'm also hosting London BitDevs and
the co-host of the Bitcoin Core Review Club.

**Mike Schmidt**: Excellent.  Thank you three for joining us to opine on the
news that you all made this week.  We're going to start with the News section.

_P2P traffic analysis_

P2P traffic analysis.  Virtu posted to Delving a post titled, "Bitcoin node P2P
traffic analysis".  He was doing research to determine the bandwidth savings
that you might be able to expect if something like the Erlay P2P upgrade was
rolled out, and he shared some of his findings.  He ran a single node in four
different modes over the period of weeks and collected data from the trace
points within Bitcoin Core, which Murch is totally not logging because he always
has to remind me it's tracing, not logging.  He had his node initially in IBD
mode and then in non-listening or outbound-only connections mode, then in pruned
listening mode and archival listening mode.

We pulled out in the newsletter three notable points from the research that we
highlighted.  One, and this was not surprising, serving lots of block data as an
archival listening node, a bunch of people doing IBD.  The second one was high
inv traffic as a pruned listener.  The note here from Virtu was that 20% of the
traffic in this mode was inv messages that could be significantly reduced by
Erlay.  And then the last point of note was that he grouped inbound connections
into three categories, IBD nodes, regular nodes, and spy nodes.  And he notes
that the bulk of inbound peers appear to be spy nodes saying, "Interestingly,
the bulk of inbound peers exchange only around 1 MB of traffic with my node,
which is too low (using traffic via my outbound connections as a baseline) for
them to be regular connections.  All those nodes do is complete the P2P
handshake and politely reply to ping messages.  Other than that, they just suck
up our inv messages".  Murch, did you get a chance to look at that research?

**Mark Erhardt**: Well, just a little bit, but I thought I might explain why
Erlay would save, especially on inv messages, which just sort of jumped out at
me.  So, when we make connections on the P2P Network, every single transaction
is announced on one connection, on each connection at least once, well usually
only once.  So, either we tell our peer, "Hey, I have this new transaction, do
you want it?" or we hear from the peer about the new transaction.  Now,
listening nodes especially will make about 125 connections, so they will be on
125 connections where this transaction will be announced in one or the other
direction.  And really, they only need to learn about it once, or all the peers
need to learn about the transaction once.  And what Erlay does is it reconciles
all the announcements, so you will not have to send inv messages that the other
party knows about, in all the cases where we find it through the resolution.
So, that was the one thing.

The other thing that jumped out to me was, why are these nodes classified as spy
nodes?  And you already touched upon that.  So, these nodes apparently only
establish the initial connection, reply to pings, and then they are passive,
they only receive the inv messages.  If they were SPV nodes that also don't
participate in announcements as much, they would at least send SPV messages
like, "Hey, I want to know about transactions that follow this pattern", or,
"Can you give me the client-side compact block filters for this block or that
block", and they never ask for any of this.  So, that's how Virtu probably
identified them as spy nodes.

**Mike Schmidt**: One thing additionally that I wanted to note for listeners was
that Virtu also published his analysis as an open-source Python notebook, along
with some of the data for people to play with.  I think he aggregated the data
somewhat over some larger timeframes, because I think the original trace point
data was going to be too big for GitHub.  But it's something you can crunch on
as well.  Anything else, Murch, before we move on?

**Mark Erhardt**: Maybe one more point from a response in this thread.  The
funny thing is, these spy nodes that only suck up the inv messages will not
benefit from Erlay if they don't participate in the reconciliation, we will
still continue to announce all this.  So, one of the responders doubts that
there will be a huge improvement on that traffic, because if most of it goes to
spy nodes, they'll still continue to suck up the data.

_Research into single-path LN pathfinding_

**Mike Schmidt**: Next news item, "Research into single-path LN pathfinding".
Sindura, you posted research to Delving Bitcoin, that you and Christian, who are
both here, put together about optimal pathfinding between nodes on the LN.  Your
post and your research paper are titled, "An Exposition of Pathfinding
Strategies Within Lightning Network Clients", and maybe we can start with you,
Sindura.  How would you summarize the motivation for your work, as well as
summarize your findings?

**Sindura Saraswathi**: Yeah, sure.  So, the main objective of our research is
to conduct comprehensive comparative analysis and provide transparency on
single-path pathfinding strategies used by prominent LN client implementations,
including LND, Eclair, Core Lightning (CLN) and LDK.  So, these clients differ
in their pathfinding strategies to trade-off between payment reliability and
routing fees.  When I say they differ in their pathfinding strategies, I mean
they have different underlying cost functions, different constraints, and
different greedy algorithms of shortest path type.  And we observed that the
pathfinding problems that most LN client implementations try to solve are
NP-complete and the variance of Dijkstra's algorithm that are currently in
production and are used by LN clients, cannot guarantee optimal solution for
pathfinding.  And to this end, we ran simulations to study the empirical
performance of eight client variants that are in production, and in fact to
study the performance on metrics such as success rates, routing fees, path
length, and timelock.

Through simulation, we find that Eclair is performing well in terms of success
rates and offering us with paths with lower feerates.  And LDK, for smaller
payment amounts, offering high fees, and for larger payment amounts, the fees is
really low, in fact the lowest.  And CLN offers paths with lower timelocks.  And
using these analyses and also the results of simulations, we see that there is
still room for substantial improvement for pathfinding in future.  And also,
more sophisticated algorithms beyond Dijkstra's can be used, and better weight
functions can be designed that can be used within the pathfinding algorithm.
So, that summarizes the research.

**Mike Schmidt**: Christian?  Oh, sorry, go ahead, Murch.

**Mark Erhardt**: Sorry, I had a follow-up question already.  You said that LDK
has the best fees for large payments but high fees for small payments.  I think
in your post, you mentioned that you might want to change the approach depending
on how big the payments are made.  Is this result that LDK is expensive for
small payments, is that a result from using the same strategy that's good for
big payments on small payments too?

**Sindura Saraswathi**: Yeah, it is the same strategy, same weight function is
used for both smaller and higher payment amounts.  So, we ran simulations for
weighting payment amounts, like the payment amounts ranged from 1 to
10<sup>8</sup> sats.  So, the same weight function is used for all the
simulations that we did.

**Christian Kümmerle**: Yeah, so I think Sindura greatly summarized the
motivation and what we tried to get at in this research and what we learned from
our studies.  I would say that from a high level, I started to look into this
maybe two years ago, when I was actually motivated by multipath payments, so
trying to develop better algorithms to find better splits for multi-payment
methods.  And then, as a first step, Sindhura and me basically took a step away
from multipath and tried to understand, okay, what are the existing approaches
done in the different implementations for single-path payments.  And, yeah, by
really digging a little bit deeper, we had a few of these interesting
observations.  For example, I think while some people are not aware of, let's
say, three-quarters of our time working on it, that basically the fact that some
of these clients impose also constraints on their paths are actually making the
problem really difficult.  And the kind of algorithms that are being used, such
as standard Dijkstra algorithm, can be considered as a heuristic greedy
algorithm that is working, I guess, reasonably well, but potentially there are
better algorithms to be taken.

I just want to point out another interesting kind of observation that we had.
So, the modelling of the LND client is really interesting because it somehow was
working pretty well in terms of the results, but then we basically looked at the
cost function that they are imposing, and so the part of the cost function that
models the success probability of a path, it's basically not really 100%
compatible with how the Dijkstra algorithm works.  So, we basically came up with
a counter example that shows, okay, we just find the suboptimal solution because
the modified Dijkstra that they use, which accounts for basically the particular
structure of this objective, is also basically just a kind of greedy algorithm
that will not always find its optimum, so the optimal solution of the underlying
problem, even if there are no constraints imposed.

So, I think that's also, I guess, an opportunity to further dig deeper,
potentially develop better algorithms, because the modeling itself is
interesting but it somehow imposes certain challenges on the algorithm.  So,
that was, I think, another interesting observation that we had.

**Mark Erhardt**: I have another couple of follow-up questions.  So, I seem to
remember, unfortunately I couldn't find it just now, that LDK recently made a
few changes to their pathfinding algorithm.  So, I was wondering, are you
tracking the current changes in the repositories, or what state of the clients
were you comparing?  This is probably not the cutting-edge latest releases, I
assume.

**Sindura Saraswathi**: Yeah, so regarding LDK, we studied this version 0.0.120.
So, that is the version that we spoke about in the research paper and also in
the post.  So, in that version, LDK was having basically two modelings for
success probability.  One is with uniform liquidity distribution assumption, and
second with bimodal liquidity distribution assumption.  And we are not tracking
the changes that has been done recently, but that was the version that we were
referring to.

**Mark Erhardt**: Yeah, the other question that I have was, I'm aware that there
was a lot of research done by René Pickhardt, and I was wondering whether you
had taken a look on that.  I think CLN has a plugin that uses Pickhardt
payments, but I'm not sure if it's actually part of the main CLN release, so
just wondering whether you included that in your evaluation?

**Sindura Saraswathi**: Unfortunately, not for this evaluation.  So, it's more
towards the multipart payments.  So, we focused on single-part payments,
single-part pathfinding.  So, we excluded that from the analysis that we have
here.

**Mark Erhardt**: All right.  Thank you.

**Sindura Saraswathi**: I think Dr Kümmerle is on mute.

**Christian Kümmerle**: Hi.  So, I just wanted to add one important detail about
our study.  So, we kind of assume that we do not have historical payment attempt
data for our clients.  I think that is important to know, because there is I
think a current kind of initiative, or there's different approaches, to make
this more non-public data, or a priori non-public data that maybe either one
specific node gathers about their payment attempt history, or maybe you can pull
that data from some other sources and use those to get better estimates of the
success probabilities of certain channels.  So, I think that is important also
to mention.  That was kind of beyond the scope of our study and I think that's a
great direction to go into to figure out ways to somehow leverage this
semi-public, but not entirely public data to improve pathfinding.  And that can
be applied to single path and multipaths, and I would say there's a lot of room
to leverage that type of information as well.

**Mark Erhardt**: That makes it of course even harder to compare all the
approaches, if you use different strategies of learning from prior attempts.

**Christian Kümmerle**: That's right.

**Mike Schmidt**: Christian, you had mentioned something about you came to this
research looking for multipath payments and then you stepped away from that, but
there's a reference I think that Sindura had in the write-up that multipath
payments are beyond the scope of the study, but you also said that these
insights will be relevant for future improvements for multipath payment
pathfinding algorithms.  Is that something you all plan to work on next?

**Christian Kümmerle**: Yes.  So, we are currently working on multipath payment
basically after the conclusion of this project, and we are specifically working
on the optimization side, so to develop better algorithms for the underlying,
relatively non-convex optimization problem, which is somehow a challenging class
of problems.  We hope that the insights that we get here are basically feeding
well as well into the multipaths payments.  So, that's a bit of a project,
that's a bit of a more challenging setup, but I think the potential -- the
amount of work that has been done is relatively limited.  You mentioned René
Pickhardt.  He did great work in that direction, but there is still, I think, a
lot of improvements there.  For example, maybe if you follow that discussion
about multipath payments, there was a discussion about the role of the base
fees.  So basically, in his modeling, the base fee kind of imposes certain
challenges which are somehow inherent mathematically in a problem, if you
include base fees.  But I think currently, there is no great solution for the
multipath payment pathfinding problem if you include base fees.  So, that's kind
of what we are currently working on actually.

**Mike Schmidt**: Well, it sounds like we might have you on in a future episode
then.

**Sindura Saraswathi**: Yeah, for sure.

**Mark Erhardt**: I just wanted to mention, so I found the reference on the
pathfinding improvement in LDK.  There's this blog post on the
lightningdevkit.org blog, which they published in February.  And so, it goes
into their methodology a bit.  And people that are interested in pathfinding,
including maybe our guests, might be interested in having a look if they haven't
yet.

**Christian Kümmerle**: Thank you.

**Mike Schmidt**: Christian, Sindura, thank you both for joining us today and
discussing your research.  You're welcome to stay on for the remainder of the
newsletter, or if you have other things to do, we understand and you're free to
drop.

**Sindura Saraswathi**: Yeah, thanks for having us.

**Christian Kümmerle**: Thanks for having us.

_Probabilistic payments using different hash functions as an xor function_

**Mike Schmidt**: Last news item this week titled, "Probabilistic payments using
different hash functions as an xor function".  To maybe set the context here a
bit, in Newsletter #340, we covered Oleksandr's work around emulating OP_RAND to
achieve some randomness in Bitcoin Script.  And then, we also had him on to
explain his ideas in Podcast #340.  And then, in Newsletter #341, we covered
some of the follow-up discussions, including using probabilistic payments for
trimmed HTLCs (Hash Time Locked Contracts) and potentially simplified
zero-knowledge proofs (ZKPs) using probabilistic payments.  Well, this week,
Robin Linus replied to that original Delving thread, and he has his take on
probabilistic payments.  Murch, what's he getting at?

**Mark Erhardt**: Yeah, so I would say this is more of a sketch.  I wasn't able
to find any data on how big this scheme would be, which was one of the points
that was raised about the other probabilistic payment schemes, for example, for
resolving very small HTLCs.  It just doesn't make sense to have a big script
that resolves it.  In this case, it looks like Robin proposes that each of the
participants rolls a random nonce and then picks a sequence of bits, and these
bits resolve to either using SHA256 or HASH160 in hashing the nonce that they
picked, and then applying these different hash functions in sequence to the
nonce.

So, the idea is basically each of the two parties commits to a number that is
not revealed, for these two parts of the secret, and then in the end, the result
of those two bit strings that resolve in which hash functions are used to
produce the commitment, they are xored and then depending on the sum of the xor
between the two participants, it either results in one or the other party with a
50-50 chance of getting the payment.  Yeah, seems easy enough conceptually.
It's basically like the game where you hold up a number of fingers and then you
sum them up to either equal or odd, and you could probably very easily implement
that.  What I'm wondering is how large the script would be, because you have
these two commitments, you have these bits that get to a hash function, and then
I think you'd also have to somehow make the bit strings add up and all these
hashes and so forth.  So, I wonder how big the script would be, but conceptually
this is pretty easy, yeah.

**Mike Schmidt**: In the example of Alice and Bob, and you gave sort of the
50-50 probabilities, is there a way to have probabilities that are different
than that, like, assuming still a binary outcome, one or the other, but one is
weighted one way or the other using something like this?

**Mark Erhardt**: Yeah, I think so.  So, there was an example in the write-up of
3 bits, and with 3 bits, there's 4 possible outcomes: all 3 bits match, which is
an xor of 0; there's one difference between the 3 bits, which is a 1; two
differences, or all three are different.  So, one party doing 101, and the other
party doing 010 would result in a 3.  So, in this case, you could allocate, for
example -- I'm wondering actually, well, you could achieve different
probabilities.  I'm not sure if you can do quarters here, because I'm not sure
if the distribution would be equal here.  Also, it would have to be that each of
the parties rolls randomly, because humans are terrible entropy and they might
be much more likely to pick 110, for example.  Anyway, yes, you could achieve
different probabilities with this scheme.

**Mike Schmidt**: Okay, very cool.  Do either or any of our computer scientists
on the call have any thoughts on this or comments?  Okay.

_Stricter internal handling of invalid blocks_

Moving on to our monthly segment on the Bitcoin Core PR Review Club.  Today, or
this week, we highlighted, "Stricter internal handling of invalid blocks", which
is a PR by Lightlike that improves the correctness of two non-consensus-critical
and expensive-to-calculate validation fields.  Stickies, you ran this Review
Club a couple weeks ago.  What sort of context can you provide on this PR?

**Stéphan Vuylsteke**: Yeah, I think it was interesting to see that some fields
in our validation logic are not guaranteed to be correct.  And of course,
validation is a quite critical part of the codebase.  But some fields are just
used as more of an optimization or kind of a helper tool.  And so specifically,
the two fields that this PR aims to make more correct, or even absolutely
correct in certain cases, are the m_best_header and nStatus fields.  And so,
I'll briefly give some context on what they do.

So, the m_best_header field is basically our best view of which block out there
is going to be the most PoW header that we're going to try and move our chain
towards.  Kind of like a North Star, a guiding light, it's where we want to go.
And this field represents the header with the most PoW that is not known to be
invalid.  We can't guarantee it's valid either.  So, it might be, it might not
be, we'll have to figure it out.  We're going to store that in our block index
to hopefully try and make it the header, or otherwise mark it as invalid on the
way there.  And so, the problem with m_best_header is that if we do find out
that a certain header that we've received from a peer is invalid, then finding
the new header is kind of an expensive operation, because we have to iterate
over our entire block index again, and especially over time, that grows quite
large, because for every single header that we've received that is not clearly
bogus, we're going to store that in our database, which is also kept in memory.
So, it's possible, but it's expensive.  So, previously, this was only done at a
slightly later stage, so it was not guaranteed to be great.  And I'll talk about
why this works now a bit later on.  So, that's m_best_header.  Where do we want
to move our chain towards?  Kind of like this North Star.

Then the second field is nStatus, which relates to how we validate blocks.  So
basically, block validation is both an incremental process and also a
parallelized process.  So, with incremental, I mean that we have different
functions validating different parts of the consensus rules.  They're usually
sorted by expensiveness, so we try and do cheap checks first and then more
expensive contextual checks later, either because it's more DoS resistant or
because it's necessary, because for certain checks we need context that we don't
have until the very end.  So, it's kind of a gradual process.  And each of these
functions can update the blocks nStatus.  So, it starts at level 0 and then
moves up to, I think, level 4 is the highest level.  And, yeah, nStatus is used
for that progress.  But then it also has a field, a block field child, which is
used to indicate that one of its ancestors was invalid.

So basically, whenever we find a block to be invalid, we need to update all of
the status fields of the descendant children to represent that one of its
ancestors could be direct, could be a few levels up, was found to be invalid.
But similar to the m_best_header, doing this operation is quite expensive
because we have to iterate over our entire block index again, which is
expensive.  So, rather than doing that right away every single time, as soon as
we find an invalid block, we're going to postpone some of these invalidation
operations until slightly later, which is usually where we connect a new block
to our active chain, so a slight optimization, or sorry, a pretty big
optimization with usually not huge impacts, but it basically means that these
two fields cannot be relied upon.

So, what Martin has been set out to do in not just this, but also his previous
PRs, is to make better guarantees on his PRs, not because we need it now, but
basically mostly because he wants to ensure that we don't have any footguns in
the future, where if future PRs use these fields, they could rightfully assume
that they're correct, because that's what most fields in the code do.  So, his
reasoning was, since we now have the pre-header sync, so pre-header sync is
basically where we only store our headers to disk after we verified that the
headers that someone sends us have enough PoW attached to them, and I think
you've covered this at multiple newsletters in the past already, so I won't go
into too much detail; but basically, that ensures that people can't send us
bogus headers without spending significant resources.  So, that kind of changed
the trade-off, where we should not be okay with doing more work when receiving
headers, because it's very hard to attack, and it offers more guarantees that
we're not using incorrect fields.  Yeah, that's kind of the high-level
summaries.  Does that make sense; did I miss anything in my summary?

**Mike Schmidt**: Yeah, I think that's good.  So, it improves the correctness,
but the correctness is still not guaranteed, and these are still not
consensus-critical variables.  Do I have that right?

**Stéphan Vuylsteke**: This does not change direct consensus criticality.  So,
that's an effect for sure.  My understanding is that m_best_header, after this
PR, should always be correct, and I think the same for BLOCK_FAILED_CHILD, but
I'm lagging a little bit, so I'm not too sure on that.  M_best_header, I know
for sure, is fixed after this PR.

**Mike Schmidt**: Any follow up?

**Stéphan Vuylsteke**: And so, I guess maybe one interesting observation I had
while looking at this PR is the reason why these operations were so expensive,
or are so expensive, is because, as I mentioned, we have to iterate over the
entire block index.  And that is because conceptually, we usually only store
references to a block's ancestors, but not their descendants, which also aligns
with the concept of blockchain, where each block commits to the previous block.
But of course, by definition, it cannot commit to the next block, because that's
unknown at the time of producing a certain block.  So, you have this asymmetry
where each block is guaranteed to have a single ancestor, or parent rather, like
direct ancestor, but multiple children.  So, iterating backwards is trivial,
it's very cheap to do, but iterating forwards, so away from the genesis block,
is not trivial, because if we want to implement that, you have to store
references to all the possible descendants of a block which can grow, kind of
unbounded embedded in size; and then you also have to start thinking about all
the branching logic that can iterate over all the different descendants from a
block, given that they can be different branches, which is not true for the
opposite direction.

So, yeah, that was an interesting aspect that makes this logic quite a bit more
complicated than you would initially assume it to be.

**Mark Erhardt**: Yeah, maybe I'm on a wrong path here, but we remember the
chain tips that we know about; why wouldn't we just have a look at all the chain
tips that we're storing rather than the entire block index?  Do you happen to
know that?

**Stéphan Vuylsteke**: Because we could have received headers that have not been
part of our active chain that are more work than a new potential change tip,
right?  This is mostly where I think we're at a chain tip and the most recent
block comes in.

**Mike Schmidt**: Stickies, do you want to plug up a call to action for folks on
the PR Review Club?  Do we know what the upcoming one is for next month yet?

**Stéphan Vuylsteke**: For next month, we're going to do a testing guide for the
v29 RCs.  So, every six months we release a version of Bitcoin Core, and before
we do the release, we try and make sure we get as much as testing done as
possible to ensure that everything goes smooth in production.  So, to do that,
we have our tradition of producing a testing guide that helps people to kind of
approach doing this testing, you know, what are some easiest to do, just kind of
a bit of hand-holding to get them started so they can do their own testing.  And
so, the next Review Club, I'm quickly opening up the page for the correct date,
is on March 19, which is tomorrow.  I missed it on my radar a bit.  We're going
to be testing, yes, v29's RC1.  So, if you want to check it out, you can go to
bitcoincore.reviews, and then you'll find a link there.  And yeah, just chime
in, follow the guides, do some testing, submit your feedback.  It's
super-helpful to make sure that Bitcoin Core works as expected and that we don't
have any unexpected issues after using it.

**Mark Erhardt**: Okay, now I have a question.  Isn't the 19th out of the rhythm
that we used to have for the Bitcoin Core Review Club?  Has something changed
about the rhythm?

**Stéphan Vuylsteke**: Yes, I'm very glad you brought that up.  We have been
having some discussions about how to make the Review Club most useful to
everyone involved.  And everyone involved is both new developers that are
interested in contributing to Bitcoin Core, but maybe don't really know where to
start or what's a good entry point.  It's also slightly overwhelming to start
contributing to the Bitcoin Core repo.  And so, the Review Club is really a way
to make that much easier.  There's no dumb questions on Review Club.  We try to
provide notes and questions to, again, provide some structure and to make it
more welcoming.  But at the same time, we also realized that it's a great place
for existing and seasoned developers to have kind of a forum to work on the same
PR together and share questions and ideas, and to make reviewing PRs, that are
kind of the item du jour and that everyone is interested in, to provide that
place to talk about it.  And so, we're bringing it all together.

So, initially, the Review Club was on a weekly frequency, but then that was
getting a bit too much to maintain.  And also, to review for attendance, we
switched to a monthly cadence.  But now we're going to try and amp that up a
bit.  I think at the moment, we're not fully set on how frequent, but at least
it might be, yeah, whenever there's more interest in doing a PR.  So, I guess
the actual frequency is still a bit TBD, but it should be more frequent than on
a monthly basis going forward, especially if we have sufficient people
interested in hosting a PR, which we're going to try and link a bit more to the
working groups that we have at Bitcoin Core.  So, if people working on certain
projects feel like a PR is ready to get more eyes on, they can suggest it and
host it.  And then, yeah, we're putting some new life in the whole Review Club
attendance and cadence.  And yeah, I'm excited about that.  Thanks for the
reminder, Murch.

**Mike Schmidt**: Yeah, that's great.  Thanks for explaining that, Stickies.
And I would encourage folks, if you haven't been to a Review Club before, that
this one tomorrow on the 19th could be a good one for you, because it's the
testing guide, and it's a way for you to, on your machine, test some things that
folks have written up for you while also poking around and using the RC how you
normally would.  And you might find something else that you want to report.  So,
I think it's even more approachable than the normal Review Clubs likely for
listeners, so I encourage you to take a look.  Stickies, thanks for joining us.
You're welcome to stay on.  Oh, no, you're definitely staying on.  All right,
let's do the Releases and release candidates and then, jump to that one.

_Eclair v0.12.0_

Eclair v0.12.0.  Major release for Eclair, which adds support for creating and
managing BOLT12 offers.  It also adds the new channel closing protocol that we
discussed previously, which is the option_simple_close protocol from the BOLT
spec, and that supports RBF.  This release also adds support for storing some
peer data, and it also makes some progress on splicing interoperability,
although the release notes do note that splicing cannot still be used with other
implementations, which I think is unchanged from previous, but it sounds like
they're getting closer.  Something else of note for this release is that Eclair
bumped their Java version to 21, so if you're an Eclair user you may need to
also update your Java runtime.  And also, they are now using Bitcoin Core 28.1
as a dependency, so that may be bumped for you as well.  And the reason they're
doing that is for opportunistic package relay.

_Bitcoin Core #31407_

Notable code and documentation changes.  Bitcoin Core #31407.  Stickies, this is
the one I thought you could help us out with because I saw that you were a
reviewer on it.  What is going on with this notarization in macOS?

**Stéphan Vuylsteke**: Yeah, I didn't actually review it, but I made an issue
that had one of the issues that are being fixed in this PR.  So basically, what
the PR does is fix some pretty big UX issues for people using Bitcoin Core on
macOS.  So, over the last, I think, six years or so, Apple has become
increasingly strict in which binaries they allow to run on their platform, just
to prevent malware and the kind of evil binaries running on people's platforms.
And so, they've been tightening requirements on both code signing and
notorization over the years to the point where, including v28, people couldn't
really use well on macOS without having to do certain steps manually to make the
binaries run, which is a bit awkward at the very least for non-technical people.

So, maybe to quickly explain, so code signing and authorization are the two key
things here.  Code signing is just about the developer, whether it's Bitcoin
Core or anyone else, verifying their identity and attaching that to the binary,
which helps you understand that the stuff you download is indeed coming from
that developer.  It's been on package for a very long time.  And then,
notorization is related, but different stuff that basically involves a developer
submitting the binary to Apple servers, so they can quickly do some checks.  I
don't think these are very thorough checks because they're just using the
binaries, but yeah, they do some checks for malware and those patterns, I guess,
that are potentially nefarious.  They also check the signature, so they check
who's submitting the binary, and then they provide, I think it's called
certificates or a stamp, I forgot the exact details.

**Mark Erhardt**: Notorization.

**Stéphan Vuylsteke**: Awesome, same name, which is going to be shipped together
to users.  And so, since I think v10.15, notarization has become required for
all distributed binaries.  So, if you download stuff, then it has been
notarized.  And code signing has now also become mandatory since v11 for pretty
much all binaries.  This applies to all Apple, or at least macOS binaries, but
we have some additional complexity for our code, namely that we do things in a
reproducible way.  So, we use guix for reproducible builds, which means our tool
chain is slightly different, or in some cases, very different, but in this case,
I think only slightly different from most build processes.  So, we can't really
use the existing code sign tool to sign our stuff, we've had to build, and this
is achow's work, build a separate tool, called signapple, to do the signing
which is compatible with our guix build process.

Up until now, signapple all was only able to code sign app bundles, which is
basically like the .app file, the qt binary, that you mostly build macros for
downloads.  But I don't think it did notorization yet, and it also didn't code
sign any of the, what we call the flat or standalone binaries, like the
bitcoind, bitcoin-Qt, bitcoin-tx, all the other helper binaries that are
typically more focused on developers, but whatever.

So, this PR does two things.  One is it incorporates updates to signapple, which
I think is actually the bulk of the work being done there, to make a new version
of signapple, both notorize and code sign both bundles, as well as individual
binaries, and then PR #31407 basically updates our build and contrib process to
use new signapple, to update the code sign procedures, and then also to attach
these signatures to binaries.  So, basically, complete the whole flow so that
from v29 onwards, every single Apple and macOS binary should be able to be
opened normally.  People can just download it, double-click it, and they
shouldn't have to jump through any strange hoops to comply with these
requirements.

**Mike Schmidt**: It's amazing how much work can go into just building and
running the software on different operating systems.

**Stéphan Vuylsteke**: Yeah, it's been a lot.

**Mike Schmidt**: Well, thanks for sticking around, Stickies, for that one.
Okay, now you're free to drop, Stickies.

**Stéphan Vuylsteke**: Thanks, I'll see you around.

_Eclair #3027_

**Mike Schmidt**: See you.  Eclair #3027 adds a routeBlindingPaths function that
creates a path from a given node to a receiver node using only nodes that
support blinded paths, so essentially, pathfinding functionality for blinded
paths in Eclair.

**Mark Erhardt**: When you're putting it that way, I'm wondering if you only
allow pathfinding for the blinded paths through nodes that support blinded
paths, is that a tell what the path might be?

**Mike Schmidt**: Good point.

**Mark Erhardt**: Yeah, I assume, well, I haven't been tracking it on that
detail level, but I think all major implementations have been making a lot of
progress on blinded paths.  So maybe, I'm not sure about, well, I don't want to
name names, but this might not be an issue because actually all implementations
are supported.

_Eclair #3007_

**Mike Schmidt**: Eclair #3007.  This is a PR that fixes a race condition that
can occur during splicing funding transactions.  So, before this PR, if one node
sent a channel_update after channel_reestablish, which might happen after a
disconnect, but before receiving a splice_locked message from a peer that had
confirmed the latest funding transaction, a race condition could occur.  And so,
this Eclair #3007 mitigates that potential condition, which I must admit I don't
fully understand, but I'm glad they fixed it.

_Eclair #2976_

Eclair #2976 enables basic BOLT12 offers without the need for a plugin.  So,
from the PR discussion, "Offers allow a wide range of use cases and it would be
impossible to cover everything in Eclair, which is why we have relied on plugins
to manage offers.  However, most users will not need advanced features.  With
this PR, we aim to provide the basic features that will be enough for 95% of
users.  Advanced users can still use a plugin to manage more complex offers".
And so, they're including out-of-the-box BOLT12 offer functionality in Eclair.
And if you're curious, the supported Eclair BOLT12 offer features include
accepting donations, selling items without inventory management, compact offers
using the public node ID, and private offers where the node's identity is
protected by a blinded path.  So, if that fulfills your needs for offers, then
you can use the out-of-the-box BOLT12 functionality from Eclair.

**Mark Erhardt**: This brings me to a question that I should probably know more
about, but how many Eclair nodes are there actually on the network?  Obviously
the Phoenix node itself is Eclair, and I believe at least it used to be the
biggest node on the network with the most connections.  How many other Eclair
nodes are there that would be using this feature?  So, is this just for
themselves to create offers, or does this downstream to the Phoenix users and
they can use it to create offers?

**Mike Schmidt**: Christian, do you happen to know any stats about that from
your analysis of the network, what percentage of the LN is Eclair nodes?  Do you
happen to know?

**Christian Kümmerle**: No, I don't have that particular data.  We didn't look
at it from this kind of level.  We basically, for our research, we used an older
snapshot of the network from a similar one, or actually based on data gathered
by René Pickhardt I think two years ago.  So, I don't have the particular
numbers.

_LDK #3608_

**Mike Schmidt**: Okay, no worries.  LDK #3608.  This is the PR that was
motivated while BlueMatt was working on the LDK PR to batch onchain claims more
aggressively per channel.  He noticed that many of the confirmation target
values that were in the code didn't make sense anymore.  And so, this PR updates
a bunch of those.  For example, it increases the MIN_CLTV_EXPIRY_DELTA delta, it
changes values that made sense for pre-anchor channels, but no longer make sense
in an anchor channel world.  An example of that would be LDK's CLTV claim buffer
value.  And this PR also adds a new MAX_BLOCKS_FOR_CONF value, which is the
upper bound on how many blocks LDK thinks it can take to get a transaction
confirmed.  And then, it updates a bunch of the tests to reflect these new
values as well.

_LDK #3624_

LDK #3624 enables funding key rotation in LDK after successful splices, by
applying a tweak to the base funding key to obtain the channel's 2-of-2 multisig
key, which allows LDK to get additional keys from the same secret.  And this PR
was motivated by an issue that noted, "Currently there is no way to generate a
new funding pubkey in ChannelSigner, only by regenerating the entire signer,
which would change the other keys as well, including the revocation key, provide
a way in the signer to generate or provide a new funding key".  So, this PR
resolves that issue.

**Mark Erhardt**: So, maybe I'm going to try to talk a little more about this.
So, splicing essentially reestablishes the channel.  It spends the funding
output that creates the channel, and then creates a new funding output.  So,
after that is confirmed on the chain, all of the prior commitment transactions
are obsolete and you don't have to keep track of them, which is one of the big
benefits of splicing, is that you don't have to keep around all that potentially
toxic old state.  And I guess, if you create a new funding transaction and
there's new signatures, you might want to create a new pair of keys for the two
channel participants.  Well, I don't even know why you would need new keys.
Maybe it's a privacy issue or it helps with getting rid of all the old state.
That would be what I'm curious about.  What is the underlying motivation?

**Mike Schmidt**: I poked around, I had a similar question.  I didn't find
something satisfactory from my understanding for the user.

**Mark Erhardt**: So, if you're listening to us and you know this, how about you
drop a reply to us in one of the social media platforms where we post this, and
you explain it to us.

_LDK #3016_

**Mike Schmidt**: LDK #3016, this is a PR that allows external projects to LDK
to run LDK's functional tests.  It also allows replacing certain components of
the tests, like for example the signing piece of a test's signing component with
something dynamic.  I didn't see any explicit references to the motivation here,
but I thought maybe, Murch, something potentially like VLS (Validating Lightning
Signer) could use something like this for their testing, so they can test LDK
along with their test suite.  That was my thought.

**Mark Erhardt**: Yeah, I think when you have a bigger integration that includes
LDK, it would be interesting to be able to plug in your part and then run your
software stack including the functional tests.  So, for example, if you trigger
payments from a plugin and it uses LDK under the hood, you might want to use the
existing functional tests with the plugin to trigger the tests.  Yeah, so could
help with developing additional software around LDK.  And often, if you have
additional software, you might not be as aware as the original software
developers what all needs to be tested, and the testing core set for the LDK
software is probably bigger than all of this related software.  So, I assume
that this would maybe benefit the other developers by getting access to the
functional tests of LDK.

_LDK #3629_

**Mike Schmidt**: LDK #3629 adds more logging around certain edge cases where an
onion failure couldn't be directly attributed or interpreted.  "The
non-attributable failure in particular can be used to disrupt sender operation,
and is therefore good to at least log these cases clearly".  This PR also fixes
a bug where an unreadable failure with valid HMAC (Hash-based Message
Authentication Code) wasn't properly attributed to a node.  So, there's a fix as
well as adding some more logging around these edge cases.  And then, we noted in
the newsletter, "This may be related to allowing spenders to avoid using nodes
that advertise high availability, but fail to deliver".

_BDK #1838_

Last PR this week, BDK #1838 titled, "Make full-scan/sync flow easier to reason
about".  The author of this PR noted issues that he had when working on a
different PR, including timestamps around replacement transactions, reasoning
about applying timestamps in BDK's transaction graph data structure, and not
having the ability to have multiple timestamps for a transaction in the case of
first seen and last seen.  So, the PR adds the sync_time to SyncRequest and
FullScanRequest.  It then allows multiple seen_at timestamps per transaction,
and removes a now unnecessary function, with the PR noting, "These are breaking
changes to BDK core.  It needs to be breaking to fix all the issues properly".

All right.  Well, that wraps up Newsletter #345.  Thank you to Stickies,
Christian, and Sindura for joining us as special guests.  Thank you to Murch, my
co-host, and for you all listening.  See you next week.

**Mark Erhardt**: Hear you next week.

{% include references.md %}
