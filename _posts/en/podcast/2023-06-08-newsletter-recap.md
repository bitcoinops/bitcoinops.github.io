---
title: 'Bitcoin Optech Newsletter #254 Recap Podcast'
permalink: /en/podcast/2023/06/08/
reference: /en/newsletters/2023/06/07/
name: 2023-06-08-recap
slug: 2023-06-08-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by Gloria Zhao, Johan Torås Halseth,
and Salvatore Ingala to discuss [Newsletter #254]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/72022043/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-5-12%2F512999a6-0077-2033-f7cf-2653f6076623.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: So, welcome everybody to Bitcoin Optech Newsletter #254 Recap
on Twitter Spaces.  It's Thursday, June 8th, and we'll do some introductions
before jumping into our newsletter.  Today we'll be talking about MATT and CTV
and joinpools, along with our limited weekly series about mempool and
transaction selection, Waiting for confirmation #4 on feerate estimation.  And
then we have a release from LND and some PRs to go through, so thank you all for
joining.

I'm Mike Schmidt, contributor at Bitcoin Optech and Executive Director at Brink,
where we fund Bitcoin open-source developers.  And unfortunately, Murch couldn't
make it this week, but fortunately, Dave Harding can.  Dave?

**Dave Harding**: I'm Dave Harding, I'm one of the authors of this week's
newsletter and really looking forward to this discussion.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core.  I'm funded by Brink
and I authored the feerate estimation section.

**Mike Schmidt**: Johan?

**Johan Halseth**: Hi, I'm Johan, I work on Lightning and Bitcoin stuff.
I'm funded by NYDIG.

**Mike Schmidt**: Salvatore?

**Salvatore Ingala**: Hi all, I'm Salvatore, I work on the Bitcoin
application at Ledger, and I also wrote the initial proposal for the MATT
governance.

**Mike Schmidt**: Awesome.  Well, let's jump into it.

_Using MATT to replicate CTV and manage joinpools_

Our first news item, and only news item this week, is using MATT to replicate
CTV and manage joinpools.  So, I'll take a stab at setting the context for
everybody here, and then we can jump in with the experts to dive a little bit
deeper.  So, we've had Salvatore on previously, and we've highlighted some of
his work, which was MATT, and initially presented at, I think, BTC Azores last
year, and it's a proposal that seeks to enable general smart contracts in
Bitcoin.  And the original mailing list post outlined several potential new
opcodes as part of enabling the MATT proposal, including something called
OP_CHECKOUTPUTCOVENANTVERIFY (COCV), which is the piece that would enable some
covenant functionality.

I think that opcode has since now been named to OP_CHECKOUTPUTCONTRACTVERIFY,
and the idea of a covenant is that instead of being able to spend the coins in
my UTXO to any destination, there would be some restriction put on where those
coins can be sent, and that can enable certain smart contract use cases.  And in
Newsletter #249, Salvatore talked about how you can use some of MATT's opcodes,
including OP_COCV, to enable certain vault use cases.  And now this week, Johan
has taken OP_COCV and shown that you could replicate some of the functionality
of the OP_CTV, OP_CHECKTEMPLATEVERIFY proposal, and in a separate post also
outlined how some of these MATT opcodes could be used in conjunction with the
currently disabled OP_CAT opcode to create a joinpool.

So, to kick things off, Salvatore, what would you add to that framing of the
context of MATT before we move forward with Johan's two different posts?

**Salvatore Ingala**: Yeah, I think it was a good introduction.  I think, apart
from specifying the specific opcodes, maybe one thing that could be useful for
someone who's new to the idea is what the opcodes do.  If you look at the core
of what the proposal does, it's just to give a way of embedding some data, just
a hash let's say, inside a script, inside a UTXO.  So you want to be able to do
two things in scripts: one is to access any data which might be embedded in the
current input that you're spending, so give us access to script to this data;
and the other thing that you want to do is to be able to constrain the script
and the data of the output.  Once you have these two primitives, you are able to
do some interesting stuff, because you can have data which is dynamically
computed, while normally the program you don't care about dynamically computing
that.

But for many contracts, it's impossible to pre-enumerate all the possible
futures, which was a limitation of CTV instead, where you kind of need to be
able to enumerate them in advance, otherwise you cannot put those into the
script, because the futures will depend on what's parsed into the witness stack
when you spend the coins.  And the initial proposal that I made for MATT was not
super-formally well-written, because there are some details still to be figured
out exactly on how to do them, and so they were in these two opcodes.  There
could be ways of doing that with just a single opcode that I touched briefly in
the last mailing list, and I think I'll try to experiment soon, but that's the
core idea.  Once you can have this way of embedding some data and piping this
data through transaction spends, then you can build some stuff on top, and I
think that's all I will add.

**Mike Schmidt**: And I guess I could segue to one of the things that could be
built on top, and, Johan, we can jump into your first post about replicating the
functionality of CTV.  Do you want to talk a little bit about that?

**Johan Halseth**: Yeah, I can talk about that, and I can also give some context
of how I got to this point as well.  So, I started researching using CTV
actually as part of the next generation of Lightning Hash Time Locked Contract
(HTLC) outputs for commitment transactions, because I wanted to make those more
efficient, because now we have all these HTLC outputs on the Lightning
commitment transactions, and I wanted to compress this into a single output.  So
I started using CTV, but quickly got into the same problem as Salvatore here is
explaining, that you cannot really predict all possible futures of spending
those HTLCs; it becomes an exponential blow up.

So, I started looking into the various ways we could solve this with the
proposals on the table, and that piqued my interest because it's very, very
simple really in the COCV and CHECKINPUTCONTRACTVERIFY (CICV) opcodes.  You can
checksum data in the input and checksum data in the output.  And then I started
looking at what I could do with this and quickly realized that you can actually,
as long as you can compute it in Bitcoin script, you can basically use these
opcodes as a way of accessing memory in the input and the output states.  So
that's super-interesting that you can find all this.  You can get this very,
very powerful thing in Bitcoin script with such simple opcodes.

After I did this with both still working on the HTLC proposal, so that's coming
soon, then also, like a simplified version of that again, it's the coinpool
idea.  So I published that and also realized that, okay, with this, I can
actually very, very simply just do what CTV does with this opcode, because it's
a strict superset really of what you could do.  So, that's how I got to that
point.  And yeah, a very simple opcode in itself, but very powerful properties
you can get with those opcodes.

**Mike Schmidt**: I noticed a tool that I hadn't heard before that you used to
do some of the demonstrations here, which is Tapsim.  Do you want to talk about
that real quick, and then we can dig a little bit deeper on both of those?

**Johan Halseth**: Yeah, for sure.  So, Tapsim is a tool I created basically to
start playing around with these covenant proposals, because there's so many
proposals out there and they're all very theoretical.  There's mailing list
posts and some of them have BIPs, but not all of them have a real
implementation.  And if there's an implementation, it's in Bitcoin Core, and
it's very hard to access and play around with.

So, what I did was I made a fork of BTCD, which is in Go, which for me
personally is much easier to work with.  And then I created this tool that just
inspects the VM state during script execution and added some UX sugar on top, so
it's easy to step through what the script is, what the stack and old stack and
the state of the VM looks like while it's executing.  So, I packaged this into a
tool that I've been using myself a bunch.  It's very helpful.  I didn't plan on
publishing it yet because it's a bit rough around the edges, but it's usable and
for me it's been very, very helpful in terms of debugging and playing around
with different opcodes.

**Mike Schmidt**: Dave, do you have questions on these two mailing list posts
that we covered this week?

**Dave Harding**: Sure.  Actually, I wanted to start by just saying I really
liked Tapsim.  It reminds me a lot of an old program by Kalle Alm, called
btcdeb, which was very similar.  It just built one copy of bitcoind and it was a
debugging tool for scripts.  And, way back in the day, Kalle implemented, I
think it was BIP116, OP_MERKLEBRANCHVERIFY, which was going to enable MAST on
Bitcoin before the idea of taproot came around.  And so Kalle implemented that
in Bitcoin Core and allowed you to go and play with it with btcdeb.

I think this is a really great way for evaluating proposals like this, to just
implement them in bitcoind, or in an alternative implementation of the consensus
rules, and then plug in some scripts and go and see how they work.  I just want
to say to Johan, I really, really like going and looking at these demos using
Tapsim.  I didn't run them, but I just looked at the code for them, and it just
helped me see how these things were working a lot better than reading pages and
pages of mailing list posts, so I really appreciated that.

I guess the question I had for Johan was, I'm pretty sure I know the answer to
this, but having implemented the primary behavior of CTV using COCV, would you
still want CTV and script, if you were actually going to go out and build things
like joinpools or vaults or other stuff; would you still want CTV and script or
do you think COCV is enough?

**Johan Halseth**: Well, it's a very good question.  So obviously, I think as I
was trying to demonstrate, is that you can basically simulate CTV in using COCV.
So, I think it's strictly more or less a superset of what you could do.  But as
mentioned in my post as well, CTV can actually be used to compress future spends
a lot more than COCV, in some sense at least.  So it's more efficient, so I
would say there are different use cases for those two proposals.  I'm excited
for both of them, but maybe obviously more excited about the COCV because of the
powerful features it offers.  Yeah, so that's my answer there.

I just wanted to mention that btcdeb was a huge influence, or something I've
used before, and had a lot of influence on how I created Tapsim as well, but I
found it much easier to work with Go codebase basically, which is why I created
Tapsim.

**Dave Harding**: Yeah, that makes total sense.  I think it's going to get
accessible to a lot more people, which is just great for evaluating these
proposals.  We want to get people with hands on them and building stuff that
they actually want to use.  I think, as we move into the future and soft forks
become kind of harder to do just because of the sheer mass of people who have to
have eyeballs on this, have to be confident in it and upgrading their nodes and
willing to run this, we just need people to build out these use cases, not just
in theory, but as close to practice as we can.

So I guess my question for you and for Salvatore would be, are either of you
guys working on getting this maybe into Bitcoin Inquisition, or just getting
this implemented up for more experimentation on signets or other test networks?

**Johan Halseth**: I think maybe Salvatore you...

**Salvatore Ingala**: Yeah, so the last one or two months, I've been a little
bit busy with the work I'm doing at Ledger with Miniscript, so I didn't do a lot
of progress.  I was actually very happy to see that Johan was doing some more
progress on the proposal as well.  But definitely, yeah, the main thing that I
would like to achieve in the near future is to actually have fully formally
defined opcodes that have all the missing features that are in a way trivial,
like being able to inspect the amounts, but there is some design space to fill
there, let's say.  And so, there was something that I mentioned in the proposal
following up on Johan's post, which is he suggested for some reasons to actually
make the two opcodes kind of symmetric so that you can have the same semantics
that you have for inputs as you can have for outputs, because in the initial
proposal the CICV only works for the current input and it's a little bit simpler
opcode, but they are kind of doing the same thing.

So, one could think of either making them symmetric or even coming up with just
a single opcode that can work on either an input or an output, and yeah, it
would be interesting to try to do that and see if the code gets too complicated,
it makes sense to have two opcodes instead because it's a little bit simpler
programming.  And so, that would be something that I want to experiment in the
near future.

Just connecting to what was mentioned before about CTV, because in terms of
functionality, CICV together with COCV, is a strict superset of what CTV
enables.  On one hand, one could think, okay, then we don't need CTV; on the
other hand, there are many cases where we can show that CTV is a lot more
efficient, and actually that was one of the things that I wanted to show in the
post with emulating OP_VAULT with MATT opcodes, because that's one case where
you can see that CTV makes the construction a lot more efficient.

So, since it doesn't add any more powers to the script and the opcode is still
very simple, I think it's a no-brainer that if you're happy merging MATT
opcodes, then adding CTV as an optimization is a very small amount of complexity
added, but it makes it a lot more efficient for some interesting use cases.  So,
I think it will make a lot of sense to include CTV in the proposal as well.  I
don't know if I missed any of the questions.

**Mike Schmidt**: No, I think you addressed that.  Dave mentioned Inquisition.
You guys obviously have mailing list posts which are garnering feedback.  I know
that there's also a Contracting Primitives Working Group, and then there's
probably some offline discussions as well.  I'm curious as to, Johan, both with
your example post as well as the broader MATT proposal, what has feedback been
from the community; how would you summarize the community's temperature check on
this proposal and these related demos?

**Johan Halseth**: Well, what I would say is really that the original MATT post
that Salvatore did was maybe a bit hard to grok for many; it has a lot.  So,
it's very cool that you can do arbitrary computation using these opcodes, but
maybe what I tried to do is to get to the heart of it, what it's like, what can
you distill these opcodes into?  And what I found from doing this experiment is,
basically it gives you access to some memory in the output and some memory in
the input, and that's very powerful, as Salvatore shows in his post as well.  So
I think maybe that's the feedback I got is that, "Oh, okay, now I understand
what these opcodes are doing", instead of having this very, very powerful and
maybe complex example of what you can do with this, trying to get into the
really simple way of explaining these opcodes and how you from there can build
out to something much, much more powerful.

That's also kind of why I created Tapsim as well, so you can easily step through
these scripts and so that you can understand what's going on and how you can
build from there.  And also, without announcing Tapsim in any large way, people
that have looked at it have given me the feedback that, "This is super, super
useful, and it's something I've really wanted for a long time".  So I'm very
happy to hear that as well.

**Mike Schmidt**: Salvatore, what is your feeling on how the community's reacted
to the MATT proposal?

**Salvatore Ingala**: Yeah, I agree with Johan.  My initial posts were a little
bit hard to decode for many people, and the fact that I was not able to show
code initially because I thought, if Tapsim was available when I wrote the
proposal, probably it would take me less time to write some code that I can show
to people, instead of actually writing a functional test in Bitcoin Core.  So,
that took me quite some time to find the energy and the commitment to actually
put the many days in a row into this project and have some working code.  And
so, yeah, I'm definitely looking forward to experiment more with Tapsim as well.

I think from past experience with soft forks and past experience with
discussions on covenants, there's a little bit of, let's say, PSTD from the
Bitcoin community, where people are scared of covenants for potential risks that
are being discussed, but not really materialized in any concrete scenarios of
what are the dangers of covenants.  And so, seeing the other side where we see
what are the useful things that we can build with covenants might probably help
to level up the discussions.  And basically, we want more people thinking about
these ideas and reasoning about them and thinking, of course, if there is
serious concerns about dangers that could come up with covenants, that's
something that more research will help to figure out as well.

But yeah, my impression is that actually the more people will think about these
things, the more we will realize that the scale of these things was a bit
overblown, while there are many interesting things that we can build with them.
And so actually, it's not obvious at all the risks to potential, like the game
theory of Bitcoin might materialize, and it could even be the opposite; by
enabling more applications to be built on top of Bitcoin, more smart contracts
that could be even privacy solutions or these coinpools and more reasons for
people to pay fees on the base layer, that could actually even improve the game
theory.  It's not obvious at all that there are dangers that are in the negative
in terms of game theory, it could be an improvement as well.

So, definitely my hope is that we get more people and more minds on this
problem, on how we extend Bitcoin smart contract security in a secure way, and
I'm quite optimistic about the potential of this kind of approach on improving
Bitcoin.

**Mike Schmidt**: Dave, I'm curious, we have a lot of these kinds of proposals,
and I'm thinking as a general Optech Newsletter reader or a listener to the
show, what would be a useful way to think about where we, as a Bitcoin
community, are at with all these proposals?  Is there a particular way that you
think about things that you think would be useful for others to be aware of in
terms of these types of proposals?  It seems like every other month, there's
something interesting, a proposal or innovation that is involving either
covenants or new opcodes; how do you think about it?

**Dave Harding**: Well to a certain degree, I just try not to think about it
because like you said, there's just so much going on, so I write the newsletter
and then I just run away and put my head in the sink!  But I think that we have
a lot of these proposals that are significantly overlapping in the
functionalities that they enable, sort of like how we see in this week's post
that COCV can emulate part of CTV, you know, it can emulate it all, I guess,
maybe.  But there's trade-offs; between all these proposals, there's trade-offs.
We have a lot of ideas, they're significantly overlapping the functionality that
they can perform, but there's trade-offs.

So CTV, like Johan said, is going to be more efficient in some cases, but it's
less flexible in other cases.  You have these trade-offs, and I'm going to show
my own idea here, but a little bit over a year ago, I posted to the mailing list
the idea of an automatically reverting soft fork.  So after, say, five years, we
would activate a soft fork, and after five years, it would un-activate.  Those
consensus rules that we added in the soft fork would no longer be enforced at
the consensus level.  Some people didn't like that idea; Matt Corallo in
particular did not like that idea, and that's fine.

The more I see these proposals that are technically sound and they have a
minimum consensus footprint, the technical complications are not great, the more
I feel like that might be a reasonable direction to go, is just find a bunch of
these proposals, test the heck out of them on Inquisition, test the heck out of
them in adding them to Bitcoin Core proper, and then activate a bunch of them
and see what happens, see what opcodes people use over a period of five years,
see what people build on them, and then let the ones that aren't being used or
that are being used poorly maybe just un-activate, fall out of consensus use,
and then keep the ones that work really well.

So, that's kind of where I'm leaning on a path forward, again that's a
controversial path forward, but just this idea of maybe we should think about
this stuff as, let's grab all the goodies and not worry now about trying to find
which one is in some criteria best.

**Mike Schmidt**: I think the idea of sidechains originally was along this line,
which is let these ideas proliferate and see what works.  Obviously that hasn't
come to fruition in the Bitcoin community in a trustless way.  You have things
like Liquid that are doing some of these sorts of experiments, but yeah, I do
remember that post and I'm not sure if we'll end up there, but it's an
interesting route to get some of these things operationalized.  Salvatore or
Johan, do you have any closing words or call to action for the community?

**Johan Halseth**: Yeah, I can just add that I think there's been a lot of
covenant proposals.  I think many of them could achieve the same as COCV does.
But the nice thing about it, in my opinion, is the simplicity of the opcode.
It's very, very easy to reason about what it does, and still you can build all
these super-interesting use cases, which is why I'm very excited about the
proposal.

**Salvatore Ingala**: So, since you asked for closing words, I'll try to do a
pitch for the proposal, which is I think soft forks are more dangerous than
covenants, and so adding a more general covenant will reduce the need for future
soft forks.  So, I think that's one reason why I think simple opcodes that are
general could be an interesting direction, and that's what I'm trying to do with
MATT.

**Mike Schmidt**: Well, thank you both for joining.  You're welcome to stay on
as we go through the rest of the newsletter, but if you have something that you
need to get to, you're free to drop.  Thank you for joining us.

**Salvatore Ingala**: Thank you.  My pleasure, as usual.

**Johan Halseth**: Thank you.

_Waiting for confirmation #4: Feerate estimation_

**Mike Schmidt**: Next section from the newsletter was from our limited series
on transaction relay and mempool inclusion and policy, titled Waiting for
confirmation #four: Feerate estimation.  So luckily, Gloria has returned this
week to join us to talk more about this weekly series.  Last week's topic was
all about techniques you could use to minimize your transaction fees, including
things like modern output types, coin selection considerations, payment
batching, and more.  And this week, the topic is transaction feerate estimation.
So maybe to lead in, Gloria, how do we think about what a transaction's feerate
should be?

**Gloria Zhao**: Yeah, so again, I kind of want to preface this with the hope
for this series is to start conversations about how we can make things better
for all the users of Bitcoin.  And so it may seem weird that I've dedicated an
entire post to feerate estimation, but I thought it's a space that's really ripe
for innovation, and there's a lot of work we can do to make things better, and
it's very multifaceted and interesting.  So hopefully, someone's been nerd
sniped by this post.

But yeah, so the question was, how do we think about feerates?  So, feerate
estimation, the goal is to translate a target timeframe for which you want your
transaction to get confirmed to a minimal feerate that you should pay.  So
obviously, if you pay, I don't know, 1 Bitcoin on your transaction, you're going
to probably get confirmed pretty quickly.  But you want to pay as little as
possible, of course.  And the main point of this post is to say that fee
estimation is really hard for a few reasons: (1) the supply is unpredictable;
(2) the demand is unpredictable; and (3) the information isn't always public to
you and can sometimes be gamed, really.

So an overarching idea for this series so far has been to create this public,
efficient auction for block space.  So, when I talk about information not being
public or being gameable, for example, if we only looked at the fees of
transactions included in blocks, basically the miners can put artificially high
feerate transactions in their blocks to drive up feerates, if we had a very
silly, naïve theory estimator that only did that.

Anyway, so back to supply and demand being unpredictable.  Blocks don't come
every ten minutes exactly, and that is a really sucky, UI/UX problem for
Bitcoin, but it's part of what makes feerate estimation hard.  For example, if
the merchant gives you 30 minutes to send the payment before they give the goods
to you, but the next block takes 45 minutes to be found, you can get screwed.
But of course, sometimes you find three blocks in a row in the span of a few
minutes, right?  And these kinds of things are, I guess, a UX problem.  It's not
just, how do we write a piece of software that's really good at estimating
things?

But of course, there's also the other side of the coin, that demand is very
unpredictable.  Of course, we all know that there are huge fluctuations in
volume and sometimes you can get blindsided by that.  Sometimes your transaction
can fall out of the mempool and that's a whole other UI/UX problem.  And yeah,
so fee estimation is really hard.  I talked about two existing fee estimators
that I'm aware of: one is mempool space, which I think is pretty accurate, I
think a lot of people use mempool space, I imagine.  And their approach,
hopefully if there's someone on the call, you can correct me if I'm wrong here,
is essentially you have a really good view of what's in miners' mempools and you
can almost just calculate what's going to be in the next n blocks.  So, you take
the mempool and you run the block assembler algorithm and you're like, "All
right, to get into the nth block, I can literally just build n blocks and then
tell you what the feerates of those transactions are".

Of course, I imagine that to do this kind of accounting for other transactions
<!-- skip-duplicate-words-test -->that might come in in the next timeframe is to build with a decreased block size
to account for like, okay, there's other people that might send transactions at
these feerates and they'll fit into these empty spaces in the blocks that we're
projecting.  And so that's one.  It very much relies on all of your information
being accurate, like what's in your mempool actually being what miners are going
to mine, and maybe that's very appropriate for something like mempool space,
where you have a lot of nodes, you have a very good idea of what transactions
are in miners' mempool, and maybe even have a good idea of what out-of-band fees
they might be accepting.  So that's one pretty accurate, as far as I know, fee
estimation algorithm.

Then there's also Bitcoin Core's, which tries to sidestep the problem of
non-public information by not trying to record it.  So Bitcoin Core's fee
estimation algorithm is looking at transactions as they come into your mempool
and then recording when that happens and then recording when you then see them
confirmed, and then it's historical-data-based.  Of course, if you have miners
putting artificial high fee transactions in their blocks, then that won't impact
your fee estimation since you won't see them that time.  So, that's trying to
avoid this gameability aspect of potentially trying to just use the information
available to you.

So, that's highlighting two feerate estimation algorithms that I'm aware of.  I
think both of them have room for improvement; both of them are perhaps more
appropriate for the user, the piece of software that they're designed for, like
Bitcoin Core hopefully is just an individual user running their Raspberry Pi
node or their laptop node, or trying to have an independent fee estimator and
not relying on centralized APIs.  And hopefully, Bitcoin Core gives them a nice,
trustless fee estimation based on public information.  And then mempool space
has access to more information, and hopefully can give you a more precise
result, but perhaps requires you to have a very, very accurate idea of what
miners are going to mine.

So, yeah, it's a multifaceted, fascinating problem.  There's a mixture of UI/UX,
maybe there's room for data-based, intelligent modeling of forecasting demand,
put some data scientists on the case.  I feel like at least Bitcoin Core, I feel
like there's a lot of room for improvement, and hopefully someone comes and
looks at our fee estimator and opens a PR or something; that's been my goal.

**Mike Schmidt**: Gloria, you mentioned just now and also in the post that
forecasting block demand space is ripe for exploration, and you mentioned some
examples of that.  You mentioned data science, but you also mentioned in the
post about certain activity patterns that may occur or certain times of the day
or business hours or external events that can mess with feerates.  I know that
there was the BitMEX withdraw at 8.00am Eastern time every day.  I think that's
gone now, but I think that was a big, known thing.  Are you aware of anybody
working on some supplemental, external events or otherwise ways of doing fee
estimation?

**Gloria Zhao**: I am not at all.  I mean, Murch will tweet about it, and he'll
be able to point out patterns, and I'm sure we all do a little bit of thinking
about it.  I don't know of anybody who's actually, I don't know, building a
model or…  I mean, surely maybe we can start with like a hackathon project or
something to start plugging in data and seeing.  Well, I think what we should do
really is first try to build a framework for feerate estimation accuracy.  Oh, I
think Josie, Josie Bake, has built a really nice IPython notebook that draws a
few graphs and has some tooling for like parsing at least the Bitcoin core fee
estimation database.  Those are the only people that spring to mind.

I'm very sorry if there is totally someone who's just dropped a paper on this,
for example.  Anyone that knows anything, please ping me.  I feel like this is
something that is almost a low-hanging fruit, almost.  We could definitely
improve, or there's some very obvious things that we can do to try to get
started, like making things better.  Just, you know, anyone listening
interested, please do something.

**Mike Schmidt**: Dave, a lot of interesting points here from Gloria.  Do you
have anything to augment, or questions for Gloria on this topic?

**Dave Harding**: No, I think those are very well-written posts.  I don't really
have any questions.  Related to your previous question about people working on
better feerate estimation, a few years ago, Kalle Alm, who we already mentioned
in this podcast, he had a project called the Mempool Monitoring Project, where
basically he just recorded every transaction that hit his node, when it hit his
node, when it got confirmed, and just details like that in a historical database
to provide the information for future research efforts.  I don't know where that
went, but it's the kind of thing that would be useful.

He also had the idea of, one of the things we have with feerate estimation is
that it's kind of self-recursive in the sense that when feerates go high, the
feerate estimator tends to return high feerate estimates, everybody starts
paying higher fees.  And then when there's a small spike in demand or a loss in
supply, feerates go higher, the feerate estimator turns even higher fees, and so
it just keeps increasing, increasing, increasing, and it falls off a cliff all
of a sudden when demand drops just a little bit, and whatnot.  And so, Kalle
also had the idea, I don't know if it was his idea, but he was working on a test
implementation of having feerates set to the lower bound of what was currently
in the mempool versus what the statistical-based feerate estimator does, so kind
of a synthesis of the two approaches that Gloria describes in her post right
now, just synthesizing this and taking the minimum of that, and return that as
the feerate for transactions that could be easily fee-bumped with RBF.

I guess that would bring me to one other point I'd like to make, is that if you
don't have feerate estimation, basically what you're stuck doing is setting a
transaction at a very low feerate, waiting some amount of time for it to
confirm, and then RBF fee-bumping it.  You just keep doing this until all of a
sudden it gets confirmed.  This is, as far as I know, your only alternative for
trustless fee management to running your own node with a mempool, is to just
iteratively RBF fee-bump your transactions until it gets confirmed.  That's kind
of a bad UX in the sense that it takes a long time before you get to the rate of
the current mempool.  You're probably still going to overpay too by some amount,
so I think the rate estimation is an interesting topic.  It's good to explore,
it's good to see how far we can get at making good estimates considering, like
Gloria said, the unpredictability of the supply and demand.

I guess I could throw one more point here, is a few years ago, some researchers
posted a paper to Bitcoin-Dev suggesting we change the way the auction works.
The idea was that you overpay your fees, but you get a refund, so miners have to
claim every transaction in a block at a consistent feerate; every transaction in
a block pays the same feerate, but you can overpay your feerate and get a refund
of the difference between what you paid and what miners claimed.  The cheapest
feerate claimed in a block would be the feerate that applies to all transactions
in a block.  Unfortunately, this does not work with Bitcoin's UTXO model, at
least not very well, you'd have to make a horrible hack of it.  But man, I think
that would be a great improvement.  So that's it for me.

**Mike Schmidt**: So how would that work then?  Transaction fees would be
collected by the miner and when the block is mined, essentially users who are
transacting and who have transacted over that average, or whatever that cut-off
is, would get paid out in the coinbase, sort of like a mining pool kind of
thing, to get their refund?

**Dave Harding**: So, it was designed kind of in mind of the Ethereum account
model.  So in Ethereum, you have an account with a balance.  So, if you think of
the way it would work in Ethereum is that all the transactions in the block
would say, okay, you can use up to 1F of my balance to pay the transaction fee
to get my transaction in the block.  And the miners would take all the
transactions they could.  Again, they would pull them by what would be most
profitable for the miner, and they would choose whatever the lowest paying
transaction they include in the block, and they would take 100% of that
transaction's allocated fee.  But the highest transaction, they might only take
5% of its fee, and the rest would stay in the Ethereum account.

Now in Bitcoin, we don't have accounts.  That's what makes this a really sticky
proposal, is that you'd basically have to have the miner, like you say, in the
coinbase transaction issue a bunch of outputs for every transaction in that
block.  So if you had 4,000 transactions, the coinbase transaction would have to
have 4,000 outputs at about 40 bytes each, which is just insane.  I think Mark
Friedenbach had a proposal for how to do this, and it's something that becomes a
little bit more possible with covenants because covenants can kind of get us
towards an account model.  If you want that, it's bad for privacy, it has all
these problems applying to Bitcoin.  I just wanted to mention it in case
somebody's listening and can think about a really, really clever way to make
that possible, because it just allows you to say, "This is the highest feerate
I'm willing to pay for my transaction.  Get it done", and yeah, that would be
nice.

**Mike Schmidt**: Just pipe all the excess funds into a joinpool, there you go!

**Dave Harding**: You solved it, Mike, yeah!

**Mike Schmidt**: Gloria, anything before we move on?

**Gloria Zhao**: Next week's is about DoS.

**Mike Schmidt**: Looking forward to it.  Gloria, thanks for joining us.  I know
you are at an event.  If you need a drop, thanks for joining; if not, happy to
have you on.

**Gloria Zhao**: Cool.  Thanks for the not dox!

_LND 0.16.3-beta_

**Mike Schmidt**: Next section of the newsletter is Releases and release
candidates, and we just had one here, which is LND 0.16.3-beta, which is noted
as a maintenance release.  There's a few different bug fixes and other
performance fixes here.  The one that I thought was notable was that LND bumps
the version of its underlying BTC wallet library, which is a library that LND
uses for its wallet functionality.  The reason that it's bumping the version of
that library was that there was a performance issue in this BTC wallet library
that caused CPU usage to spike when performing certain mempool related
operations.

So, there was an optimization put in BTC wallet that added a cache, which
improves this performance and solves the CPU issue, which also then obviously
affected LND.  So, by bumping that version of that library, LND is no longer
susceptible to these CPU spikes.  Dave, was there anything else notable from
this LND release that you wanted to know?

**Dave Harding**: No, we just added a note here that I think the fix that you're
talking about was related to their mempool watching logic.  So, they're actually
looking at the mempool now to find transactions, Lightning transactions, that
have gone onchain for one reason or another, so they can resolve them quicker
than waiting for them to confirm.  And so, this is a speed up between the time
that a channel closes, and you can start using your funds for something else.
So, they're working on that, they're making LND a little bit faster its users,
so that's nice.

**Mike Schmidt**: Next section of the newsletter is Notable code and
documentation changes.  I'll use this opportunity to solicit any questions that
the audience may have; feel free to request speaker access, or comment on this
Twitter thread and we can get to your question at the end of the newsletter.

_Bitcoin Core #26485_

First PR is Bitcoin Core #26485, and this is a change to Bitcoin Core RPC
methods and how they're called.  So, in order to call certain Bitcoin Core RPCs
previously, there was a parameter called options, which was required to pass
certain parameters, and that particular options parameter was a big, nested JSON
object.  And with this PR, that nested JSON option still can be used, but
there's an additional way that you can now call certain RPCs that required that
previously, and you can actually use name parameters instead of a big, old JSON
object.  So, this adds some flexibility for applications calling RPC, which
seems nice.  Dave, is there a particular use case that you think was in mind
here for adding this additional way to call RPC?

**Dave Harding**: So, I use bitcoin-cli a lot, and one of the really big pains
of using it is that you spend half your life quoting stuff, because JSON in a
shell is just not fun.  You have to put the outer thing in single quotes, you
have to put all of your parameters in double quotes, and then you're putting
curly braces around everything, or square braces around arrays.  And so, anytime
somebody comes along with an idea like this, it's just a small code change and
allows you to stop quoting everything and stop -- the braces aren't so bad, but
just simplifying stuff.  I think that's what it is.  It's just Bitcoin
programmers are spending a lot of time using Bitcoin Core and they're spending a
lot of their lives just quoting things and then dealing with the problems that
happen, the weird error messages you get in the shell when you misquote stuff.

So, I think that's what's happening here, is they're just making it a little bit
easier to use, especially since it's something they use every day, tons of times
every day.

_Eclair #2642_

**Mike Schmidt**: Eclair #2642, adding a closedchannels RPC.  So Eclair's adding
this, we noted that a few newsletters ago, we covered CLN adding a similar RPC,
and I thought it was interesting in digging into this PR, the first comment I
think was in response to someone opening this PR, was t-bast saying, "Can you
explain why you think this is useful?"  And the person opening the PR said,
"First of all, it's going to make me as famous as Rusty Russell is via the
Bitcoin Optech Newsletter", since we had covered this CLN RPC previously.  So, I
thought that was kind of funny to get an Optech shoutout in the middle of this
PR for the reason of opening this.

But the real reason the person gave was, the only way to figure out which peer
closed the channel and what the cause and what the balance of the channel was,
in addition to other information, was this person was using a Lightning
<!-- skip-duplicate-words-test -->explorer, and mentioned Amboss and some other ones, and noted that that is a
privacy leak by using these explorers to find out some of the information that
was already in his node, he just didn't have an easy way to access it.  And then
t-bast added the Optech Make Me Famous label to the PR, and now this person is
famous!  Dave, any comments?

**Dave Harding**: No, except that I laughed at that remark too on the comment!

_LND #7645_

**Mike Schmidt**: LND #7645, making sure that any user-provided feerate in
certain RPC calls is no less than a "relay feerate".  And so there's
OpenChannel, CloseChannel, SendCoins, SendMany RPCs in the LND node that are
functions that a user can provide a feerate.  And previously, there was no check
on what that feerate would be, and thus it could be below either a relay fee or
the minimum mempool fee.  And so this change actually puts a check in and will
provide an error if the "relay feerate" may seem slightly different than things
depending on the back end.

So, there's multiple backends, and so for bitcoind, this relay feerate that
they're referring to is actually whatever is greater, the relay fee or the
minimum pool fee, and I'm not exactly sure what BTCD equivalent is for that.
But there's at least some checking going on for user-provided feerates to make
sure that they're adequate, I would say.  Dave?

**Dave Harding**: Yeah.  So, this is just something that you need to do when
we're having what some people call full mempools.  So when bitcoind, and I think
BTCD now as well, their mempools have a maximum size, and when they get full,
they start dropping transactions at the bottom.  And they can use, I think it's
BIP133, but it could be BIP130, I get this confused all the time.  There's a
message that nodes can send that says, "This is the current minimum fee that I'm
accepting".  And so when you're at that point that the node is rejecting
transactions below the minimum feerate, if you try to send a transaction below
that, it's just not going to propagate at all.  It's going to hit the first node
and that node's going to drop it, and it's going to go nowhere in the network.

So, I think that's all that's happening here, is saying that your local node,
your backend, has a minimum, and maybe all its peers have a minimum, I don't
know exactly how this is implemented, and if you're trying to send a transaction
into that, it's just not going to work, so try with a higher fee.  So, this is a
nice fix, say, an edge case that users might bump into, improvement.

_LND #7726_

Next PR is LND #7726, making a change that it will always spend all HTLCs paying
the local node if a channel needs to be settled onchain, even if it might cost
more in transaction fees to sweep them than they are worth.  And this is in
contrast to a PR from Eclair from last week, that added logic not to claim an
HTLC that would cost more in fees to claim than it's worth.  And noted in this
PR is, "In the future, we'll start to make more economical decisions about if we
go to chain at all for small value HTLCs".  So, it's interesting to see sort of
diverging PRs with regards to claiming HTLCs on chain.  We have one saying we'll
do it economically, and one saying we'll do it no matter what.  Dave, thoughts
on this PR?

**Dave Harding**: This one was a bit confusing for me to disentangle when I was
writing it up, to figure out exactly what was going on.  It said it's a small
code change to LND, the actual PR itself, that you kind of have to dig in to
figure out what it's working on.  But the idea there is they already had logic
that wouldn't try to claim an HTLC if it looked like it was uneconomical.  But
there were a bunch of cases where it could be economical because other things
depended on it.  And so they decided to make the call to always claim it, even
though it might not be economical, just because they don't want to lose out on
those occasions where it could be a larger amount of funds depended on it that
would definitely make it economical.

What they're going to do is go back and just add cost accounting to their
program to be able to figure this stuff out so they can always make economical
decisions.  That just means sometimes an HTLC on LN is going to be uneconomical.
You make a transaction on LN two weeks ago when fees were lower, and today fees
are higher and it's just not worth claiming that money.  And that's just an
interesting dynamic that we need to think about when designing Lightning
software in the future, is what do we do about high-fee environments and small
HTLCs not necessarily making sense.

So, I think this is an interesting, I don't want to say it's an open problem in
LN; it's not.  I think there's solutions out there, but just figuring out which
solutions we're going to adopt and what trade-offs we're going to make.

_LDK #2293_

**Mike Schmidt**: Last PR this week is LDK #2293, and the motivation here sounds
like LND sometimes stops responding, leading to channels being forced closed.
And the common solution for LND node operators is to restart their node or
reconnect to their peers, and just try to start from some sort of a fresh state.
And so LDK is mitigating this interoperability issue by disconnecting
unresponsive peers after a period of time to, I guess, also cause that fresh
state to be forced.  And there is actually a related LND PR, which was recently
merged as well.  So, Dave, this sounds a little funky.  It's like the old, if
it's not working, turn it off and turn it back on again.

**Dave Harding**: That was exactly what I was going to say!  But yeah, actually
it seems like a decent solution to actually just have in your codebase, is if
your peer isn't responding, but you think they could be responding and you think
there's just something going on there, just start and stop.  And the reason that
works in software so often is that it just brings you back to that initial
state.  Programmers are a lot better about reasoning about initial states and
finding bugs in initial states than they are in a piece of software that's been
running for days or weeks and is in just some state that is very rarely reached
in the code, that the programmer has not thought about.

So, just in the case of unresponsiveness, just going back to that initial state,
I think it's a good solution.  I don't see any problems here.  It's an ugly
hack, I guess, but if you can get over the ugliness, it seems pretty functional
to me.

**Mike Schmidt**: We have one question, Dave, that I'll direct at you that came
from Chad Pleb.  This person asks, "Is it possible to take historical blocks and
say something about how efficient transaction fees were in order to approximate
how much was overpaid or wasted, or using some sort of standard deviation like
metrics?"

**Dave Harding**: So, Chad, what you need is you need to know when that
transaction was first relayed and when it got entered to a block.  So, you just
can't grab blocks themselves because you're missing the information of when that
person sent that transaction.  What I think you might be looking at is, say, the
difference between the highest feerate for a transaction in a block, and the
lowest feerate transaction in a block.  And if they're all close together, then
you could call that efficient; and if they're very far apart, you could call
that inefficient.

That works pretty well, if you assume that nobody was paying fees out of bound
and that miners weren't doping their own blocks.  So miners can add transactions
to their blocks that pay any feerate at a very low risk to the miner of somebody
else grabbing that fee.  So, just to be really specific here, if I'm mining a
block, I can include a transaction that pays 1 BTC in fee to myself.  And that
makes it look like I claimed a lot of fees, but in reality I just wasted block
space.  So if you ignore that, if you ignore people paying fees out of bound, so
people paying fees directly to miners through a credit card or through another
system, then you can do that.

I don't know exactly what information that gives you except, like you said, how
inefficient it was compared to optimum.  Again, I think what you really want to
know is what people paid, when they paid, and how long it took them to get into
a block.  I guess you also want to know how long they wanted to wait, which is
unknowable from public data.  Sorry, it was a bit of a rambling answer.  I hope
that kind of answered your question at least.

**Mike Schmidt**: Thanks, Dave.  I think that's it for questions and that's it
for the newsletter this week.  I'd like to thank Gloria for joining us and Johan
and Salvatore, and to my co-host, Dave, for coming in for Murch.  Thanks, Dave.

**Dave Harding**: Always a pleasure, Mike.

**Mike Schmidt**: Thanks everybody, cheers.

{% include references.md %}
