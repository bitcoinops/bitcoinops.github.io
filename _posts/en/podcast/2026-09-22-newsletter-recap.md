---
title: 'Bitcoin Optech Newsletter #423 Recap Podcast'
permalink: /en/podcast/2026/09/22/
reference: /en/newsletters/2026/09/18/
name: 2026-09-22-recap
slug: 2026-09-22-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Davidson Souza, Eric Price, and PortlandHODL to discuss
[Newsletter #423]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-8-22/432462472-44100-2-14a83896fb792.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #423 Recap.
This week, we're going to be talking about mining pool difficulty and
stranding potentially stranded miners; we're also going to talk about
improvements to Utreexo's IBD (Initial Block Download); there's a draft BIP
for unspendable taproot internal keys that we'll get to; and then we have our
monthly segment on Changes to client and service ecosystem software, including
one update from a new group working on EntropyLab; and then we have our weekly
Notable code and documentation, and Release segments.  This week, Murch,
Gustavo and I are joined by a few guests.  We'll have them introduce
themselves briefly.  Davidson, who are you and what are you working on?

**Davidson Souza**: I'm Davidson, I work on Utreexo in Floresta, and thanks
for having me.

**Mike Schmidt**: Thanks for joining.  Eric?

**Eric Price**: Hi, I'm Eric, I work at MARA on Pool mining pool, and I've
been doing some work on vardiffs.

**Mike Schmidt**: Thanks for joining.  Portland?

**PortlandHODL**: PortlandHODL, I work for AnchorWatch and am a Bitcoin
educator on Twitter, possibly.

_Improvements in Utreexo initial block download_

**Mike Schmidt**: Thank you all for taking your time to walk through some of
your items with us.  For listeners, we're going to start with the first item
this time, "Improvements in Utreexo initial block download", and we have
Davidson, who mentioned he's working on that, Utreexo as well as Floresta.
Maybe a quick setup for listeners.  Do you want to, Davidson, explain maybe
just normal full node and keeping UTXO set on disk and maybe how Utreexo fits
into that, and then we can get into Floresta as well maybe at the end, but I
want to hear about improvements to IBD; but maybe we have this background
information for people first?

**Davidson Souza**: Yeah, one of the main rules that a Bitcoin node actually
checks when validating your block is whether the UTXOs existed, meaning the
outputs were created by a previous transaction and not spent by that time on
the current best chain.  And usually, we use something called the UTXO set,
which is an abstraction where only live TxOuts are kept.  We learned in recent
years that that's not the only way to do that.  Libbitcoin, for instance,
doesn't keep that.  But at the end of the day, you have implicitly that idea
that a UTXO exists and it's still unspent, like a TxOut is still live in the
chain.  And this tends to be on the main bottleneck for running nodes,
especially for low-power devices and a device that doesn't have good SSDs or
doesn't have enough memory, because the I/O operations need to fetch those
UTXOs; as the UTXO set grows, the I/O operations tend to mount.  And right
now, we have several people complaining that their setup, which usually is one
of those things, it either doesn't have a good SSD or doesn't have enough
memory, it takes a while to IBD.  I've seen people that took like a month to
IBD now, using basically old SSDs.

Utreexo tries to alleviate that by instead of having the entire set of UTXOs
of TxOuts that are still unspent, we keep an accumulator, which is just like a
tiny representation of that, where it's less than 1 kB, currently it's half of
that, I think, and you only need to keep that information, around 1 kB, that's
nothing, you can keep that in the CPU cache.  And instead of storing it,
whenever you see a transaction or a block, you must receive as well a proof
that this transaction was like those outputs, they exist in this accumulator.
So, when you're trading off bandwidth, like you're using more bandwidth and a
little bit more CPU, but you don't need to keep the full set anymore, don't
need to keep, like I think nowadays, Bitcoin Core's UTXO set is like 11-ish
GB; you don't need to keep that.  And you don't need particularly fast SSDs or
lots of memory.  The current code already runs on super-tiny devices.  We can
run on, like, smartphones, we can run on single-board computers without any
problem, because the I/O bottlenecks no longer apply to what we are doing.

**Mike Schmidt**: All right, great background.  Maybe you can walk us through
maybe what happens when the UTXO is added and spent, and then you talk about
this in your latest post, this 200 GB, where did that come from, and maybe
explain the trick you had here around your proposal, that the deletion
overhead gets down to almost nothing during sync?

**Mark Erhardt**: Maybe can I just jump in very quickly?

**Mike Schmidt**: Yeah, go ahead, Murch.

**Mark Erhardt**: I think I heard that you said Libbitcoin doesn't have a UTXO
set, and I've heard that a few times lately, so I wanted to clarify.  The
model that Libbitcoin uses does not have an explicit UTXO set because it has
the whole transaction output set.  So, yes, it has a UTXO set, but it's a
subset of the entire transaction output set; it just keeps everything.  So, I
think it is incorrect to say that Libbitcoin does not have a UTXO set.  It has
way more data than the UTXO set, but also has the UTXO set.  So, I just wanted
to clarify that.  And Utreexo, on the other hand, does not have a UTXO set.
So, it is actually a distinguishing feature here.

**Davidson Souza**: Yeah, sure.  I think we should say that it doesn't have an
explicit UTXO set abstraction, but yeah, it's basically the difference between
the outputs versus inputs tables, you get the UTXO set.  That's fair.  So,
before this trick, Utreexo, every time you receive a block, you must receive
as well the proof that every single element in that block existed.  And you
also need to do a lot of hashing to update the accumulator and produce the
newer version of the accumulator with those inputs spent.  So, you remove them
from the accumulator.  And this is quite a lot of data and quite a lot of
hashing that you need to do.  For instance, the worst case we can get in terms
of overhead is 100%.  So, if the chain is 700 GB, the worst case the proofs
would be also 700 GB, so you end up downloading 1.4 TB of data during IBD,
which is not great.  Bandwidth is also, in some places, a very big problem,
and over 1 TB is gonna take a while.

So, the idea or the question was, can you remove this proof-checking during
IBD; can we remove proofs at all from IBD and not require in doing that?  The
first attempt was basically caching, which is a natural thing to think.
Bitcoin has this nice property of UTXOs, they're exponentially more likely to
get spent right after being created.  So, if you keep just, say, the last 100
blocks' worth of UTXOs, you already save, like, currently it's almost 80% of
all these spends happening, recreating the last few hundred blocks.  So, you
already save a lot.  I think in the experimentations we had, you could reduce
the amount of data required to like 30% to 40% of the chain size, which is
improvement, but still 200 GB to 300 GB of extra data that we need to
download.  So, that's still not great.  And to get more than that, you need to
have even more RAM available to cache.  So, finally getting to a point where
it doesn't make sense anymore to use Utreexo.  But last year we had an
in-person get together with a few people, we had the Floresta team, but we
also had Tadge, Calvin and Ruben Somsen.  And we tried to get rid of this
somehow, when you add things to the accumulator, can we already update it in a
way that the deletion is already taken into account?  Because Utreexo is just
a bunch of trees, and the way you delete things is just moving things up.  So,
if you're deleting an older, take the sibling and move the sibling to where
the parent is.

**Mark Erhardt**: Yeah, so because, of course, in a hash tree, two siblings
hash together to make an inner node.  So, if one of the two siblings is
deleted, the other sibling moves up and becomes the parent, and that way you
can make the tree smaller, yeah.

**Davidson Souza**: And then, we're trying to figure out if I know the UTXO is
gonna be spent ahead of time, so it's an assumption I have, I know when I add
that UTXO to the accumulator, I know at some block height, it is already
spent.  So, if I know this, can I already apply that operation in a way that
it already goes to where it will end up after all those operations are made,
like all the additions are made and the deletions?  And the answer is yes, I
can do that.  And the nice thing is that the additional operations, they only
require the root sets.  So, they only require the roots, which is the less
than 1 kB set of data that you need.  So, if you have the roots and you know
the spent-ness of a TxOut when you are adding it to the accumulator, you can
already move it up to the positions it moves, and then you end up where it
would be if you did explicitly; so, explicitly just do the additions and then
the deletions as usual.

**Mark Erhardt**: Okay, sorry, I have a question here.  So, if you change the
content of the tree, wouldn't the hash of the inner node change and therefore
the root change?  So, if you already delete things that will only be used
later, wouldn't the intermittent proofs become invalid?

**Davidson Souza**: Yes, the intermediate states are invalid, but we don't
need them because we're not checking proofs here.  And then, that's the next
thing that we need to talk about.  For this to work, you need SwiftSync,
because SwiftSync already tells you whether the spends were valid or not.  You
don't need to check the proofs if you're doing SwiftSync, because the
aggregate will tell you exactly the same thing that validating proofs would
give you.  So, the intermediate spends, they are invalid.  You cannot validate
a proof, like your block 100, and you have an accumulator built this way of
adding and removing things implicitly.  That proof that was computed before
doing this is invalid for that particular accumulator, because that
accumulator is different.  But the thing we need is by the end of the IBD,
when I reach the last block in that range, that accumulator is valid.  That
accumulator is equal to the one you would obtain during the normal operations.
And during this process, we explicitly want to eliminate proofs.  So, there is
no reason to validate proofs in the meantime.

**Mark Erhardt**: Okay, I think I get the gist here.  So, usually, if you
naively did Utreexo, you would process the entire blockchain, but you wouldn't
store the UTXO set along the way.  And therefore, you would have to process
all the proofs along the blockchain, which would double the bandwidth roughly
and require you to download all these proofs.  So, if you instead do a vanilla
SwiftSync on the part until you reach a predetermined height, you can check
whether inputs and outputs canceled out for the ones that have been hinted to
you, and you just build the forest of merkle trees that is the accumulator,
for the height that you want to reach with the SwiftSync.  And you depend on
SwiftSync along the way to check that all the other outputs were created and
consumed, because that accumulator cancels out.

**Davidson Souza**: Yeah, and I need SwiftSync as well, because I have that
assumption that I know the spent-ness of an output when I create it.  So, I
get that from the hintsfile from SwiftSync.  And we just changed the addition
algorithm slightly to take that information in and already compute the updates
when I add things.  And the way I know that range is valid when it comes to
removal and addition of UTXOs, and that there is no double-spends, and all of
that, it's not from Utreexo, it's from SwiftSync.  I'll get that from Utreexo
after I finish SwiftSync when I reach steady state.  Then, it's Utreexo that's
telling me that, but for IBD, you want SwiftSync.

**Mark Erhardt**: Right, I think I get it.  Cool.  So, that saves you about
half the bandwidth.  SwiftSync is also pretty quick.  It might just be faster
in IBD.

**Davidson Souza**: It's way faster.  I've just tested on a crazy-fast machine
or implementation.  We have an implementation of assumevalid SwiftSync that's
almost ready.  It's fully parallel, like everything's concurrent.  I had a VPS
that's, like, crazy internet.  I finished in 19 minutes 45 seconds.  And I
think I can get better results, but at this time I'm like, I'm not going to
bother.  But yeah, it's really fast.  We are saturating every single network
link we can come up with.  The guy who is making it is Jose.  He was already
here explaining Witnessless Sync.  So, he did the Witnessless Sync
implementation in Floresta as well.  So, he's got an internet that's like 800
Mb/s top.  He was able to finish in 1 hour 30 minutes.  My internet's kind of
bad because I live in the middle of nowhere, but it can finish in three hours,
and very bad machines.  So, we are basically going as fast as you can download
things and it's really fast and it's super-lightweight.  We already finished
on like a Pi 3, all sorts of low-end.  Like, I finished on my Pixel phone.  I
recently had an Android binding and in four or five hours, I finished on like
a Pixel running over Wi-Fi.

So, we are getting some pretty low bounds to where you can run this.  So, at
some point, you can even go to sleep, leave your phone syncing, and when you
get up it's already synced, and you're just validating; at least inside the
assumevalid assumptions, you just did a sync.  So, it's really interesting
results we're getting.  I'm very excited to have this ship in the next couple
of weeks and see people trying it out in different setups.

**Mark Erhardt**: That does sound pretty awesome.  So, this is a thin client,
but due to the proofs it can actually validate unconfirmed transactions and
can validate blocks fully, once it has reached the steady state?  And you say
it runs on your mobile phone?  So, that's pretty impressive.

**Davidson Souza**: Yeah.  And now, I'm starting to work on the
non-assumevalid version of it.  This one is going to require more hardware.
It's very hard to make it, especially memory.  It's very hard to make it with
low memory requirements.  But already, we have the architectural means of
making it also fairly concurrent, at least like Libbitcoin-level concurrent,
for processing blocks in the non-assumevalid as well.  So, that should also
give us some interesting results, but that's very preliminary work.  I'm still
figuring things out.

**Mark Erhardt**: All right.  Is this discovery the reason why there hasn't
been an update to the SwiftSync BIP in a year?!

**Davidson Souza**: Yes!  Sorry about that actually, sorry about that.  But I
wrote that blog as a first version of what I will eventually write in the BIP,
because I have some updates.  I still need some reviews from the team, but I
have some updates for the 183 and 182.  But 181, I'll have to rewrite a lot
of stuff there because of the changes.  So, these are also like a
brainstorming of what I need to update in the BIP for it to be compatible.
But yeah, that's largely the reason why we haven't updated anything, is we are
redoing things from the ground.

**Mark Erhardt**: Okay, so the old style would have worked, right?  Would
anybody still run the old style, for example the full nodes, the translation
nodes that translate from the open network to the proof network?

**Davidson Souza**: You mean the bridge nodes?  They don't have to.  And we
are even working with the assumption that no one will request old proofs.  So,
we are building faster bridge nodes.  I have one that can sync in like
20-something minutes.  So, Bitcoin Core plugin uses libbitcoinkernel to get
blocks from Core.  It builds the forest, and then you can spin up Core again
and it gets blocks from RPC and serves them over P2P.  So, if you have Core
and you want to use Utreexo stuff, you can just use this.  I should announce
this in the next couple of weeks because I'm finishing some stuff.  But we are
working with the assumption that historical proofs will no longer be required
because they are quite big.  You require terabytes of data to store them, and
that's kind of off-putting for most people.  So, now, we're just saying, like,
100 GB is already more than enough to keep recent-ish UTXO block proofs.  So,
you can serve that and you're already helping a lot.  Historical proofs, we're
thinking about dropping them.

**Mark Erhardt**: So, there is a total rewrite going on, because you're
actually incorporating this assumption throughout the proposal.  Instead of it
being sort of an alternative way of syncing, it actually will become the new
go-to.

**Davidson Souza**: It's slow.  It's better to do that way, because you don't
gain anything by doing the old way.  Because validation-wise, SwiftSync also
gives you full validation, the non-assumevalid SwiftSync.  And you're
literally just spending more bandwidth.  There is no other improvement for
doing the old way, so we think we can just deprecate it since it makes things
so much faster and so much easier infrastructure-wise.

**Mark Erhardt**: More bandwidth and more computation and more I/O.

**Davidson Souza**: Yes.  Because bridge nodes for actually proving everything
from genesis is super-slow.  But we can just skip through and view the forest
as if it were, like, block 900,000.  So, you skip all the way to 900,000.
This is insanely quick.  I synced up to, like, 960,000, and I was using an
old, one of those off-the-shelf desktops, like mini-computers that Tadge got
me.  He bought four for $90, like super-small machine, and I was able to sync
in 30 minutes using that Core plugin thing.  So, that's super-fast, and if I
can do that, it's just way better, and there's no reason to support anything
old.

**Mark Erhardt**: Okay, okay.  Great.

**Mike Schmidt**: So, there's a lot of exciting tech that we just talked
about, and I can imagine there's a couple classes of listeners who maybe one
wants to learn a little bit more about the details and maybe contribute.
Obviously, we could post them to the Delving-Bitcoin thread, Davidson, that
you posted about that we covered this week.  But there also may be folks who
want to start maybe building tooling around this or play with it a little bit
deeper.  Where would people go who want to start contributing to the project
and maybe not just understanding the technicals at this level?

**Davidson Souza**: The SwiftSync stuff and all the client-wise stuff, we have
an implementation in Floresta.  There's a PR with that, if you want to play
around, test it, and give your results and maybe give some feedback.  It's on
GitHub, it's getfloresta/Floresta.  There is a PR by Jose that implements all
the assumevalid part.  The non-assumevalid should open a draft PR in the next
weeks maybe, just for people to review.  And the Bitcoin Core plugin thing
that I mentioned is also on the org.  I think it's called rpc-utreexo-bridge,
something like this.  So, there is an open PR there with the fast bridge
building.  You can check it out as well.  And we're planning in the next
couple of months to revamp our blog.  We have a blog in getfloresta.org, where
we should publish some technical stuff of Floresta.  So, I think Jose is
already preparing one for his experiments with the assumevalid SwiftSync.  I
should also post some about some experiments I'm doing.  So, check out the
blog, keep an eye on it.  We should update this with some cool stuff as well.
I think that's the main ways people can get in touch with the latest changes.

**Mike Schmidt**: Awesome, Davidson, we appreciate your time joining us today.
You're free to drop and move to other things.

**Davidson Souza**: Yeah, thank you for inviting me.  See you all.

_Vardiff controllers that strand slowing miners_

**Mike Schmidt**: Cheers.  Okay, so, I lied and that wasn't the first item in
the newsletter.  We actually went a little bit out of order, but I think that
also benefited Davidson and his schedule.  So, we'll go to the actual first
News item from the newsletter, "Vardiff controllers that strand slowing
miners".  Eric, I don't know if you listen to our show or read our newsletter,
but we don't do a ton of stuff in the mining world.  So, maybe you can
summarize or maybe contextualize for folks on the software side of things,
like exactly what are the components in play here; what's the scenario and
issue; and maybe we can get into the Delving thread then?

**Eric Price**: Yeah, sure.  Can you hear me?

**Mike Schmidt**: Yeah.

**Eric Price**: So, the basic context for this is the mining pool, and it goes
to something called a controller basically.  So, the mining pool is trying to
produce blocks for the blockchain and you've got a bunch of contributors
working on small pieces of work that could be a potential block.  And so, the
basic loop is we're trying to produce blocks and the miners are solving these
jobs and they're, let's see, you've got a stream of shares coming from the
miner and we're receiving them.  So, we've got a sensor and the pool's trying
to create a regular cadence of shares from all of its contributors.  And so,
it has a target share rate that it wants them all to produce output at.  So,
different miners have different efficiencies and capabilities, and so there's
this layer of indirection, called the difficulty, that lets it adjust how long
it takes to produce the solution.  And so, it measures how quickly it's
getting answers from each miner and compares that to the desired frequency
that it wants, and adjusts the problem difficulty in accordance to the
difference between what it wants and what it's receiving.  And so, that's the
basic feedback loop.

**Mark Erhardt**: Right, so the actual Bitcoin difficulty is way higher, of
course.  So, the mining pool gives each participant in the pool, let's call
them hashers, a custom difficulty that they participate on, and they will give
shares whenever they beat that custom difficulty.  Is that the vardiff that
we're talking about?

**Eric Price**: Yeah, within the mining pool.  There's a similar problem at
the chain level, where you have all the miners basically contributing blocks
to the chain.  And then, every two weeks, the chain looks at how many it got
and compares it to a target that it wants them to contribute at and adjusts
the network difficulty according to the error, the difference between what it
got and what it wanted.  So, it's a similar context in the mining pool
environment, where basically it's just the miners connected directly to the
pool.  It's like an infrastructure thing.  It's like, how do we control the
amount of traffic that's coming into the entire server so that we don't fall
over.

**Mark Erhardt**: Right.  You want to measure how much work each hasher is
doing, but you don't want to overwhelm the controller.  So, if you gave
everybody the same difficulty, the faster hashers would produce tons of
shares, the slower hashers would not be able to give a signal at all.  So,
each hasher gets a difficulty that is custom to them.  And then, what are you
aiming for, like one share every ten seconds or something?

**Eric Price**: Yeah, so this is a pool-configured property.  The pool
basically writes down whether they want six or typically it's in the
neighborhood of six shares a second.  But at the chain level, we have what a
block every ten minutes, so that's how the problems map.  So, I set out this
project just trying to see if I could -- and let me say, we're working
primarily in Stratum, Sv2 world, so a lot of my context is from that.  I had
some prior experience in Sv1 world, but a lot of things are different.  So,
just to give you context.

**Mark Erhardt**: Yeah, talking about context, could you tell us again what
problem you're trying to solve?  So, we have different speeds, we have
introduced the concept of shares, and now what is happening and causing an
issue?

**Eric Price**: So, originally, I was just trying to optimize the vardiff that
exists in Sv2.  I wasn't necessarily trying, I was just optimizing, looking to
improve it.  But as I poked around at the algorithm, looking at ways to like
-- when you first connect, sometimes the machine, the miner, it starts at a
low difficulty so the share rate is very high.  And then, it waits until it
sees some shares before it has enough information to adjust that down.  So,
one of the first problems was trying to keep network traffic from spiking.
But I soon realized that there wasn't a lot of wiggle room in optimizing the
vardiff because there's this wall.  The problem is sort of information bound
by the stream of data that comes in itself.  And if you try to make it react
faster, you lose precision; and if you try to make it more precise, it becomes
less responsive.  So, you're really bounded by the rate of data that comes in,
by the share rate; the target rate that you're setting, it is a proxy for
that.  It may not be that value when you first connect, but as it converges to
the target, six shares a second, that's the rate of data that you get in, and
you can't get around that anyway except changing that rate itself.

So, I was getting frustrated trying to do this optimization problem, because
every time I improved something, I lost something else.  And then I noticed
something.  I was using AI and doing a lot of runs, changing different
parameters, and I stumbled on something where I was playing with the
adjustment rules.  And so, you can either adjust it up to produce shares
faster, or you can adjust it down to have shares go slower.  And I started
playing with an asymmetric rule here, where one side is adjusted harder than
the other side.  And I noticed that if you increase the share rate more than
you decrease the share rate, if the rule is to push the share rates higher
more easily than to push them lower, the machines happen to live longer, they
just stay up longer.  And I thought this was very weird.

**Mark Erhardt**: So, let me try to paraphrase that.  So, you found that if
you allow them to do more shares, they stay live longer.  So, there was an
issue with liveness if the share rate was too low?

**Eric Price**: Yes.  If for whatever reason your share rate is lower, I'll
just say it's generally in a statistical sense, you're not likely to live as
long as a connection to a mining pool than if your share rate is above the
target.

**Mark Erhardt**: So, when would this be happening?  If a miner is spinning
down or if it's suddenly running slower, the mining pool would just sort of
lose track of it and disconnect it?

**Eric Price**: Yeah.  If it's below the target, it's more difficult to deal
with generally.  It's more difficult to see, it's more difficult to know if
something changes.  Basically, it's like this, and I'll just kind of reason
through it.  For whatever reason, say there's some sort of event that happens,
maybe you have a power outage or, you know, it's solar powered and the power
goes down, or for some reason there's some disruption and you're hashing at a
reduced rate, maybe you had a hardware issue or something.  You had a certain
difficulty and you were producing supposedly at rate, so your target was fine.
And now, something's happened and you're producing shares at a lower rate.
The controller sees less shares, it has less information about what is
happening.  So, let me look at my notes here just so I get the sequence right.
Yeah, the shares slow down due to some initial disturbance.  The controller,
the estimator has this window where it's watching the shares as they come in.
Well, it's taking longer for shares to come in, so it's seeing less data, so
it has less certainty about what the true hashrate actually is.  And so, the
vardiff controller can't push you back up, can't adjust your difficulty to
save you from the situation, because it has less information.

**Mark Erhardt**: So, reading our write-up of what you posted about, it sounds
like the vardiff is often adjusted at a specific number of shares.  So, when
the shares start coming in much slower, the time until the next adjustment
becomes greater.  So, if some hasher is in a continuous decline for hashrate,
they might run into a situation where the number of shares they have to bring
in order to provide enough information for an adjustment is hard to reach and
they get disconnected before they produce enough shares.  So, I think you had
an idea how to improve the adjustment of the vardiff?

**Eric Price**: Yeah.  So, the issue here is that this whole loop is
event-driven.  You need the events to drive the loop to get you out of the
problem you're in, but the problem is that you're getting less events.  So,
that's the vicious cycle.  And the way out of it is to perceive the passage of
time within this cycle, okay, and there's different ways to do that.  But you
need to know that your events are spreading apart.  And the only way to do
that is to inject emptiness into this window of measurements.  You need to see
that there's gaps of time between things, and take the absence of events as an
event in itself.  And there's parallels to this on the other side; the
blockchain problem.  And you can look as recently as this last fork, the Luke
fork.  When the chain split, his fork was sitting there at a high difficulty
and the miners needed to produce blocks, but they couldn't reach the
difficulty.  And so, they weren't able to trigger the difficulty calculation
to lower the difficulty in the first place.

So, we've seen this before, and Bitcoin's own control loop is not particularly
sophisticated.  And you can look all the way back to our first major chain
split with Bitcoin Cash.  There's actually academic literature that followed
that, where they went and tried to add a timing aspect to the difficulty
controller so that they could actually get blocks into the chain in the first
place.  And they made a couple of different adjustments over several years.
The first, and this is actually really interesting and I'm going to go into it
when I talk at TABConf, but their first attempt was called the emergency
difficulty adjustment.  I think it was a hard fork; it was a fork.  And it
made it so that when you wait a certain amount of, time the difficulty
automatically increased.  But there's a big difference between a mining pool
and a blockchain.

**Mark Erhardt**: Sorry, the target increased or the difficulty got lower,
right?

**Eric Price**: Yeah, I'm sorry, I forgot what I said.

**Mark Erhardt**: No, you said the difficulty increased when the time was too
long.

**Eric Price**: Sorry, no, it got easier for the miners to put blocks on the
chain.

**Mark Erhardt**: Sorry, let me jump in a little more.  You described the
problem that if the difficulty is way too high but it takes a fixed number of
blocks in the blockchain for the adjustment to come, the chain might starve.
So, for example, you brought up the Bitcoin Luke's Vision fork recently.  So,
the difficulty was way too high and we were projecting some two years or so
until it would adjust, and it would have cost millions of dollars of hashing
to get there.  But we also have the same issue on testnet.  So, on testnet, we
had a different difficulty adjustment rule; we had an exception.  If the time
was more than 20 minutes, we would allow a low-difficulty block to be found.
But we had to remove that recently because it caused other issues.  And now,
we're a little worried with the proposed testnet5, if some miner wants to
troll us and points hashrate at the testnet5, it might run into the situation
where we starve, because the difficulty was run up by the miner that pointed
their hashrate at it, and then we would need to get a certain number of blocks
to reduce the difficulty again to the actual hashrate on the testnet.

So, we have the same situation here for hashers in a mining pool, where for
some reason, the difficulty adjustment is based on the number of shares that
have been produced.  But when they are winding down and are finding fewer
shares, they might starve before they reach it.  So, you're saying instead of
counting or waiting until all the shares have been found for the next
adjustment, you're injecting emptiness in between.  You're just counting when
you get fewer shares, how much time has passed, and you realize that they are
way below the expected rate.  And so, it sounds like once you get a low number
of shares in a period of time, like the difficulty adjustment that Bitcoin
Cash used, where after six hours, I think the difficulty would halve, or go
down even more drastically.  Or was it, I think, six blocks in six hours, or
something, the difficulty would halve.  But it also had some interesting
consequences.  It caused miners to deliberately not find blocks on Bitcoin
Cash and had the effect of the oscillating hashrate.  In this case we wouldn't
have an adversarial situation, because the hasher and the mining pool are
actually trying to work together.

But so, the solution is just to look at the shares are coming in way slower,
and now we adjust based on time instead of hashrate, is that right?

**Eric Price**: Yes, conceptually based on time.  The final evolution of the
Bitcoin Cash saga was an algorithm they called ASERT, which was basically the
final evolution of their estimator.  In the paper, I kind of talk about
vardiff as being composed of three parts: the estimator, whose job is to have
a guess at what the true hashrate of the miner is; and then, the boundary
which decides whether that hashrate needs to be adjusted or not; and then, the
last part is the magnitude of the adjustment.  So, what the BCH literature
looked at was the estimator part, where they said, "Of all the ways we could
inject time into the system, what seems to work best for us is to use an
exponentially-weighted moving average", and it solves some of the problems you
were mentioning before.  So, with just a regular average, you have a window of
a certain size, and we've been talking about this wall which governs what
happens when you go between a short estimator and a long estimator.  The long
estimator, you have a lot more data and so you're not bouncing off of
yourself, you're not seeing these kind of reverberation effects; whereas the
shorter window, you can respond quickly to changes, but you don't know what
the source of the changes are, you might be responding to yourself.  Go ahead,
Murch.

**Mark Erhardt**: Right.  So, if you, for example, just used an average, and
then you found 50 fast blocks and 50 slow blocks.  Before that, you had fast
blocks.  As you find the 50 slow blocks, it keeps slowing down a little bit.
But then, let's say the energy goes back up and your issue is resolved and you
go back to the regular speed.  Now, it also takes the 50 next shares to move
back up.  And also, the adjustment would be very slow, because first it's just
one slow block and 99 fast blocks; two slow blocks, 98 fast blocks, and so on.
Whereas you want it to be more reactive if something changes, but you want the
context, the broader context of the entire situation, right?

**Eric Price**: Right.  So, this exponential mechanism takes the benefits of
the short window, and the benefits of the long window and combines them by
basically attenuating the impact of the older samples.  So, the window grows
in a way that doesn't cause other issues.  The content within the window grows
unbounded, but the size of the window itself stays fixed, which prevents some
other issues.  There's an issue that's live in the Sv2 vardiff today that has
to deal with an unbounded window, and the exponential version fixes those
problems, and you can see it through the history of what happened to BCH.  So,
that's why I think it's very interesting.

**Mark Erhardt**: Right.  So, you basically were able to use BCH as a study of
the problem that you were trying to solve and look at their solution space,
evaluate it.  And what you came up with eventually was that you put a higher
weight on the most recent share latency and a lower weight on the older, but
it still factors in.  And that way, you get a faster adaptation to the changed
circumstances, but don't lose the context completely.

**Eric Price**: Yeah, so we don't see as much churn or chop from the window
having a finite size.  Like, it's hard to explain what the effect is, but it
messes with the payout variance.

**Mark Erhardt**: Yeah, it removes the overcorrections, right?  If you have
just the average, you under-correct and catch up for a long time.  But then,
once the situation is improved, you suddenly have way too many shares.  So,
you might overwhelm the controller with additional data that you wouldn't have
to send because there's too much information now.  So, you sort of adjust more
quickly, but you don't lose the entire context.  That sounds like a good
solution for the issue.

**Eric Price**: So, now we're looking at ways to kind of bound and control the
excess of shares now.  We've sort of fixed one problem and made an easier
problem that needs a little bit of work.  But one interesting thing I wanted
to bring up, in comparing BCH to mining pools, not BCH, but chain difficulty
versus pool difficulty with -- well, I didn't get into the asymmetry part.
Well, we started to touch it, but when you refuse to increase difficulty as
much as you would increase the share rate, the asymmetry, where you are
reluctant to tighten up the difficulty and eager to increase it, more share
rate, that creates this kind of permanent offset where the shares are going
faster than they should by kind of a regular offset.  In the chain context,
that causes the miners to receive their mining subsidy faster.  So, the fix
that Bitcoin Cash made caused the emission rate of the chain to increase,
which sort of violates consensus.

**Mark Erhardt**: Well, more like the reward schedule that had been
communicated earlier.  Adjusting the difficulty calculation is already a
consensus change, right?

**Eric Price**: Yeah, true.  But it was a no-go situation to have the emission
schedule accelerated on the chain.  But in the pool context, almost all of the
ways we do share accounting is with proportional-valued shares, like your
higher-difficulty share is worth more than a lower-difficulty share.  So, the
same solution of being asymmetric about how you adjust the pool difficulty
doesn't have the same consequence as it does in the chain context, because we
don't have an emission schedule, we don't have a fixed value per share.  So,
we don't need to worry about that concern.  We can apply this asymmetric
technique to our controller problem without worrying about the chain concerns.
So, the same technique that was initially tried and rolled back in the Bitcoin
Cash context applies fine in the mining pool context.  And so, that's sort of
the gist of the paper, that asymmetry kind of fixes this kind of intrinsic
problem with making your miners hash with harder problems.  You lose sight of
them because it takes longer for them to get -- if they're not actually
efficient enough to produce shares with that difficulty, if they're going
below the difficulty that they're capable of producing, then you lose sight of
them and you can't see what happens if something else changes.  That's the
gist.

**Mark Erhardt**: To summarize it, the solution didn't work for Bitcoin Cash
perfectly, because the shares basically were also what produced the block
rewards.  So, their emission schedule was changed and that was an unintended
side effect.  But in our case, in the mining pool, each share only counts at
the weight of the difficulty that it is mined at.  So, there's no fixed reward
per share, but rather the shares are weighted in their own context, and
thereby the asymmetric solution solves all the issues here, but it wasn't the
right solution in the context of Bitcoin Cash.  Basically, if they had
adjusted the reward to be based on the difficulty or something, well, now
we're getting outlandish and too much into the details.  But thank you for
covering your thought process.  I think we got into all the details of how
mining pools can now adjust the vardiff calculation.

So, where is this going live?  So, the interesting thing of course is that
mining pools don't have consensus.  So, they need to run on software that they
know what it's doing, but it is client-server relationship.  So, you can
update software and just have a different calculation scheme.  You said you're
doing this in the context of Sv2?

**Eric Price**: Yeah.  But I think to your question, the impact of this I
think is more responsive miners, less jankiness when something happens to your
mining fleet.  You'll be able to see it under adverse situations and keep on
chugging no matter what happens.  That's what I think is the end goal of this.

**Mike Schmidt**: I saw Portland has his hand up and he also did 20 minutes
ago.  Sorry Portland!

**PortlandHODL**: Oh, no, it's no problem.  I had two quick thoughts on this
working, specifically at MARA at one point, the vardiff was more problematic
in our cases during startup.  So, it would start, like you said, at a low
value, and especially when you have a site with a ton of miners, you would
completely flood the traffic controllers, etc.  So, that's very interesting
that this can possibly be solved on especially the downward side, but still,
that is the primary pain point there.  The second question I had is, the
vardiff, from my understanding, is like a miner reports in and you say like,
"Hey, okay, you're reporting really quick, I'm going to give you a harder
job".  And in the case of some miners, am I correct that it is an exponential
function, like you can do powers of two, or is it a number that you can
actually set any value to?

**Eric Price**: So, this is interesting.

**PortlandHODL**: Because I had this issue with the Antminer specifically.
You could do powers of two, but you couldn't set it like, "I just want this
exact target".  So, you kind of had to guess which one is the best.

**Eric Price**: Yeah, so I've noticed this, kind of poking around in some of
the Sv1 pools.  A lot of them are always setting difficulties to powers of
two.  And I've noticed this in some Sv2 pools, and I'm trying to dig out to
the origin of this.  And it seems like it started in CGMiner, an open-source
mining software that actually gets run inside of the firmware.  And so, I
think it started on the firmware side, and then the pool started adapting to
that and locking it in, and it's bad for vardiff.  It removes variability.
And now, I think the firmware has moved on largely, but some of the pools
still have that in there.  So, it's sort of this legacy bug.  It's bad for
vardiff, it's bad for the visibility of your miner, and I've seen it in our
pool and some others.  So, it's something that we need to eradicate.  I don't
see it in Sv2, so I think the future is going to be absent of that artifact of
the past.

**Mark Erhardt**: So, there's no hardware requirement for the specific
hashers' difficulty to be two?

**PortlandHODL**: I would research that very closely.  Most documentation and
firmwares I've seen for older Bitmain machines, S19 and previous, seem to
require a power of two.  Please do not hold me to that though; that's just
from my own experience.  The next question I had specifically is, in my
experience with vardiff, the machine would start off just absolutely blasting
shares off to your pool like crazy when it fires up.  But once the machine was
stable, it typically hit like, okay, it wasn't exactly -- the target was 30
seconds, but it was still good enough.  What would actually cause a machine to
basically stop reporting at that specific rate?  I'm going to give my answers
to what I think could happen.  You could lose a hash board, you could lose
chips, or you could downclock.  But how common is that?  Like, how common is
it to find a miner that is now slowing down, or am I missing something there?

**Eric Price**: Well, I'm trying to do some experiments now to catch them
live.  It's hard.  You're trying to catch a rare event.  But I mean, we could
induce one.  I mean, I can have somebody go into a lab and pull a board out,
and I might have to do that to do some of these experiments.  But what was the
other part of your question?  Yeah, it is hard to find them.

**PortlandHODL**: Yeah, I was wondering if there's other use cases that would
cause, like, a Stratum connection to appear to be more variable, because in my
experience, usually once you hit that, it's hashing, unless it blows a
hashboard, it's pretty stable overall, the vardiff is constant.  And then, a
proxy was my last one.  Like, if you have an entire pool proxying machines
together to send over shares, that is the case where I think this would be
incredibly useful.

**Mark Erhardt**: But also, in the case of a whole pool, wouldn't you have a
much more gradual reduction, because you wouldn't turn off the whole pool at
once?  You might lose one of the machines or maybe downclock slowly through;
no?

**PortlandHODL**: Curtailments in certain sites mean lever gets flipped, you
lose several thousand machines on proxy, right?  So, the proxy aggregates all
these machines into one connection.  So, it'll appear like, "Hey, we just lost
a significant portion of our hashrate very suddenly".  And then, that can at
any moment be flipped back on.

**Mark Erhardt**: Right, but that wouldn't be 90% usually, it would be more;
or would you actually run into the 30-second limit that AJ was proposing?

**PortlandHODL**: I don't believe so.  But the curtailments are variable in
the size, like it can be 5%.  You're given a power target you've got to hit
and you're supposed to turn off machines till you hit it.  It can be 90%, it
can be 95%.

**Mark Erhardt**: I see.  Eric?

**Eric Price**: But I think the promise here is a partial.  Like, what happens
today is there's no way to do a partial curtailment.  You just turn them all
off and then turn them back on.  But we could have partial.  And to the point
about the share storm, first of all, when you first turn on the miner, with
Sv2, that problem is done.  There's a protocol carve out.  On the initial
connection, you can parse in your nominal hashrate, like, your sticker
hashrate.  And so, that's basically feeding forward.  You don't even have to
wait for the convergence time at all.  It comes out of the box for free.  But
if there is this decline and a cutoff, then you're ending up reconnecting
multiple times.  So, if we're finding a vardiff issue that induces reconnects,
then we're back to having this share storm problem.  But if we can seed in the
natural hashrate, then we don't have to worry about this anymore, at least for
native Sv2 firmware.

**PortlandHODL**: Thank you, that was pretty cool.  Awesome.

**Eric Price**: If I missed any questions, let me know.

**Mike Schmidt**: Well, we can direct folks to your post as well, which is
available in the newsletter, and folks can follow up there.  Eric, thanks for
diving deep with us on that one.  We appreciate it.  You're free to drop if
you have other things to do.

**Eric Price**: Yeah, no problem.  Okay, thanks.

_EntropyLab offline key calculator_

**Mike Schmidt**: "EntropyLab offline key calculator".  We have Portland to
talk about this.  Portland, you guys created (checks notes) an HTML file.  Why
is this cool?  What is this HTML file?

**PortlandHODL**: This HTML file is actually pretty cool.  There's going to be
some caveats here in a moment.  But basically, the problem that we were trying
to solve at EntropyLab was essentially how do you validate and verify the
outputs of various hardware wallets and entropy generation solutions for the
deterministic side.  So, for example, we have hardware wallets that can offer
dice rolls and stuff.  For their users, how can you prove that those solutions
are being honest, or as it expanded, because there was scope creep throughout
the project, how can you convert other forms of physical entropy into a seed
phrase essentially?  This was essentially started by MrHodl on X, who is not a
programmer or a dev by any means, and a great guy, but he just used AI,
specifically Claude, and generated an HTML file to solve his issue of
converting dice rolls to a seed phrase.  And then, it kind of just took off,
like, okay, what else can we verify, down to PSBTs, different forms of
entropy, later on generating a wallet.dat file from that entropy.  Like,
direct imports from that HTML file creates a wallet.dat that you can check
your pubkeys to see like, "Hey, is there a balance here?" replacing kind of
the BlueWallet as a recovery tool.

My notes, before I get too sidetracked into this, this is 100% not designed
for any mainnet bitcoin.  I don't want to be responsible for anything like
that.  It calculates tpubs, xpubs, but this is really only for verification of
existing things.  Do not put in seed phrases or anything involving real
bitcoin into this EntropyLab HTML file.  I'm just going to be very clear that
this is not the tool to put real bitcoin with.  If you have maybe a brand new
hardware wallet and you want to test some dice rolls without any real funds
first to see, like, "Hey, does it generate the correct seed phrase given the
dice rolls?" that's probably okay.  Just don't use the same seed phrase again,
wipe it, etc.

**Mike Schmidt**: So, I maybe just want to spit back the context.  So, we had
this COLDCARD incident and then everyone was like, "Well don't trust the
device's randomness", was the natural backlash.  And so then, memes about
dice-rolling and, you know, "You've got to do that".  And I guess the natural
reaction was then like, "Well, how do I know if I put in my dice rolls, what
if that conversion within the hardware signing device is incorrect and it's
actually showing me seed words that aren't corresponding to my dice, and maybe
that's a bad thing?"  So, in that instance, as well as all the other use cases
you mentioned, it's a way to validate that that device in that instance is
behaving.

**PortlandHODL**: Absolutely.

**Mike Schmidt**: Yeah, okay.

**PortlandHODL**: There's other things as well.  For example, like RFC6979,
which is when you sign your transactions, you have to generate this nonce.
And there are very specific properties of a nonce that it cannot be reused for
the same message, like, that you need to verify it's deterministically
generating on that device.  So, we have a tool like, "Hey, you can check your
PSBT signatures to make sure that with this specific key, this lines up".
It's deterministically generating, it's not leaking information.  Dark Skippy
was an example of that.  You can also validate anti-exfil, all these different
functions of a hardware wallet.  This is supposed to be the one-stop shop to
test, to validate that, "Hey, this is my expected output from the device", and
it gives just another reference point to validate these devices.

**Mark Erhardt**: Sorry, I have to get nitpicky about something you said.  You
said you're not allowed to use a nonce for the same message.  That is safe.
Using the same nonce for exactly the same message will produce the same
signature because it's deterministic.  If you use the same nonce for a
different message, you leak your private key.

**PortlandHODL**: Correct, and that is a very bad outcome.  So, yeah, going
forward, it quickly became that even things like BIP85, all these things need
verification.  And the tools available to do these kinds of tasks, from the
libraries to AI specifically, are all present.  Like, Rust Bitcoin exists,
right?  We have the ability to derive things, we have the ability to convert
entropy to seed phrases, follow these standards, BIP32, BIP39.  How do you put
them all in one place?  Ian Coleman previously existed; Jameson Lopp has a
site where you can convert your xpubs and get the little parts and bits; how
do you put all this together in one place?  And that's kind of the next thing
that happened, was not just how can we get a seed phrase into an xpriv, or
whatnot, or wallet.dat, it's how do you put all the things together?  And the
answer very quickly, just hang out on Twitter Spaces, use AI models and burn
tokens, and you will end up with a probably pretty overall good solution to
your problem.

So, the nuts and bolts of the whole thing became Rust Bitcoin was the baseline
for everything.  It was the framework everything was built on, because Rust
Bitcoin could be compiled into WASM, WebAssembly, essentially.  So, you got
all the libsecp256k1 code Jonas Nick and everybody wrote that is, in my
opinion, beyond excellent.  And you get to just kind of bolt that directly
into your website.  And then the AI essentially was able to link the pieces
together, take these bindings, follow the specifications and standards, and
produce very usable input frameworks so that the user could put in their dice
rolls, put in their entropy, give them a live hash, etc, and combine all these
pieces together to form EntropyLab.

Some nice little tidbits of things that were actually -- one new thing that
came out of this whole thing is there is now a direct Bitcoin Core wallet.dat
js library.  So, you can convert a mnemonic directly into a wallet.dat file,
or give it descriptors, and you can just build these things out.  That's a
part of EntropyLab.  I think that's pretty neat.  And from there, what kind of
also came about is how did we really come up with the use of AI being
acceptable for this kind of tooling, right?  This is private key material;
this is applied cryptography essentially.  And that decision came about
because of, one, cost and accessibility.  So, EntropyLab, I think, given the
number of features it has, like you have everything from like multisig,
descriptor creators, PSBT editors, validators that it's consensus valid, BIP85
child derivation, silent payments, vanity address generators, the time to
build all these features out by hand, if I had to sit there and just type it
out, I think it would have been on the order of months.  Maybe if I was really
motivated a little less, but this happened in two weeks, we were able to
create all these functions and tools because of AI.

The cost overall was incredibly low.  For the entire suite of EntropyLab, I
could probably say it's around $2,000 in AI credits.  Given the cost of a
developer, that if they were to take their own time, let's say they're senior,
because this kind of work is typically senior, that would be maybe like one to
three days' worth of their work, and they still wouldn't have it done.  AI was
able to complete all these tasks for that same cost of one to three days'
worth of work.  The next component is what the Bitcoin Red Team, I think, also
showed incredibly clearly, is that AI and its ability to analyze code from a
security perspective, I think is outperforming humans, and not by a little
bit, but by a lot.  I think that projects with longstanding, very talented
developers, like Bitcoin Core, secp256k1, that have had tons of brain power,
tons of time to review, fared incredibly well against AI.  But in terms of
more niche, less reviewed code bases that don't get access to the top talent,
those projects don't fare as well, in my opinion.

**Mark Erhardt**: I wanted to jump in there.  Review is one thing, but also,
Bitcoin Core especially has built out a core set of all sorts of different
testing strategies that I think other projects should look more into, and that
might also be way easier to bootstrap now with the assistance of AI.  So, if
you haven't been doing fuzz testing yet, I think it is way easier to get
started with that now.  Maybe, I don't know, mutation testing is probably
similar, and so forth.  We've been doing a lot of these things.  We've
probably been on the forefront on some of these strategies for testing
software.  And I think that is a big contribution.  Niklas Gögge had a great
blogpost about this the other week.  So, yeah, I think getting more creative
with your testing strategies is another way where you don't have to throw just
money into the AI oven to test every time a new model comes out, but you can
actually be proactive instead of reactive.

**PortlandHODL**: Absolutely.  And, for example, fuzzing, EntropyLab uses
fuzzing as a method, like even during CI, and we have some runners externally
to fuzz different components of it.  And that process, just from using, for
example, an open-weights model like Kimi K3, that is literally like $3 of
credits to build an entire fuzzing suite, obviously human review is necessary
to kind of say like, "Hey, this is legitimately doing what it should be
doing".  But my point more so about a project like EntropyLab, which is open
source, is we don't get access to Pieter Wuille to double-check our solutions.
So, with that stated, AI has provided, I believe, a sufficient alternative for
security review and in the current and test framework generation.

So, yeah, that's kind of the interesting thing, is that this project is the
first example of a project where instead of leaning on the humans as the
primary backbone for code generation, review, and validation, we moved towards
a direction of realizing the speed at which these tools should be delivered.
The accuracy of AI can present, in terms of its review, from a security
perspective and finding holes, bugs, logical inconsistencies, deviating from
specs, is incredibly good.  And so, with that, we just, as a project, leaned
into it as we kind of nicknamed it Team Oogabooga, because we have become the
Oogaboogas, the simple primitive beings.

**Mark Erhardt**: So, we're now proud of being meat proxies, is that what
you're saying?!  No, sorry, I'm just teasing.  But yes, I'm not sure if you
are the first.  Rearden Code has been working on his rbitcoin.org thing.

**PortlandHODL**: And Ibis Wallet.

**Mark Erhardt**: Yeah, Ibis Wallet too, okay.  But yeah, this is definitely,
I guess, a new advent of how to develop software.

**PortlandHODL**: Yeah, and I just want to close out that I'm not saying that
this model is right for every path.  Like, a production path, probably not
maybe the best idea to just 100% go all-in on AI and just burn thousands of
dollars of tokens and just hope the result is right if you don't have any
technical competence on your team at all.  But at the same time, a project
like EntropyLab, where your budget and time constraints are very low and
you're trying to achieve a great output, which is to create a validator for
basically any type of function on a hardware wallet, you're kind of forced to
use these tools to produce those outputs.  I can't spend my entire day
building out a BIP85 derivation tool for when I have a regular job I've got to
maintain.  And so, that became the rest of the team as well, is we all just
leaned into it and then built on top of these AI tools to create EntropyLab.

**Mike Schmidt**: Portland, if I'm using this tool as instructed and I somehow
validate my download, I'm doing this offline AirGap, all this good stuff, and
I'm using it for verification, other than legal concerns, what is the concern
with using it in, I don't know, a production mainnet setting; and by legal
concerns, I mean the developer's legal concerns?

**PortlandHODL**: So, yeah, I'm going to say this very in my opinion.  I have
used EntropyLab for my mainnet bitcoins before, specifically the act of
splitting, because I was dumping the Luke Dashjr fork for some extra bitcoin
and I wanted to validate that my PSBT's input belonged, the txid was from the
new chain, not my previous input, because that would cause a fee issue and a
bunch of other problems.  It works just fine and it told me, "Hey, you had a
problem", to which I resolved that, which I'm very thankful that I had this
tool because it was very easy to go into the PSBT Editor and see.  I think
that the main thing I have a concern with anybody using this for mainnet
bitcoins is I just don't want to be responsible if there is a problem.  I'm
not willing to take on that liability.  Because I think, like, Rob Hamilton,
for example, made a post that a computer can never be responsible, or
summarizing it, and accountable.

At the end of the day, it's not the LLM that's responsible for the bad code,
it's the person who authored and pushed that code that has to be their head's
on the line, basically, and that's going to be in any environment.  There's
got to be some ability to point to something and go, "That was the problem".
I'm stating very clearly that I don't want anybody using this tool for mainnet
bitcoins because of the fact that I don't trust this software in its current
state.  Another issue as well to say why you shouldn't use this, there hasn't
been a formal 0.anything released.  This is still just a master branch
constantly evolving every day.  Things are in flux.

**Mike Schmidt**: That's fair.  Yeah, I think there's like a 1970's IBM
engineer quote about the computer can't make a decision because he can't be
accountable, or something like this, yeah.  That's fair.

**PortlandHODL**: Yeah.  But at the end of the day, I am fairly confident, in
my opinion, on the validation testing of the frameworks that it's built on and
the ability to link those together to form the outputs that are needed to
verify.  So, basically, we're using Rust Bitcoin for all the internals, and
then really it's just gluing it all together.  And as long as the glue logic
is correct and adheres to the specifications, you should be fine.

**Mark Erhardt**: Yeah, if only.  I mean, the COLDCARD thing was also a
problem across glue boundaries, right?

**PortlandHODL**: Yeah, that is correct.  They did not glue on the entropy
generation.

**Mark Erhardt**: The good thing is it's a fairly small project.  I think the
other thing that I want to point out is I assume it's licensed under some
open-source license, and almost all of the open-source licenses are no
warranty, you run it at your own risk.  And that is on purpose, because you're
also not paying for it.  While the developers are definitely going to try to
do their best in general, there's no company to sue.  It's provided as is, no
warranty.  And I think more people need to remember that that is how open
source works.  And while certainly mistakes are made on the developer side,
it's also partially the responsibility of the users to help review and audit
and make sure that things are verified sufficiently.

**PortlandHODL**: Yeah.  We essentially used the Unlicense.  We did have a
rewrite of it called the Oogabooga license, just for a little bit of thematic
elements essentially, and we did say that this includes all the previous
conditions of the Unlicense.  But yeah, just it goes no warranty, not
responsible for anything.  Just yeah, you're using this software 100% at your
own risk completely.

_New BIP draft for unspendable internal keys_

**Mike Schmidt**: Portland, thanks for your time and joining us.  I do want to
offer, if you want to stay for the remaining News item, that if perhaps in
your capacity at AnchorWatch and, I guess, even previous involvement in your
Bitcoin endeavors, you want to talk about the draft BIP for unspendable
internal keys?  Sounds like he's sticking around.

**PortlandHODL**: Yeah, I'll stick around.  I'm going to note I have not
reviewed that specific draft BIP.

**Mike Schmidt**: Okay, no problem.  Well, maybe Murch has anyway.

**Mark Erhardt**: Well, it hasn't even hit the inbox of the BIPs repository
yet.  It's so far just a mailing-list post that announced that someone had
picked up a previous, well, we previously had one or two attempts where people
were trying to define how you would make a descriptor or a wallet policy in
which the internal key is not spendable.  So, a nothing-up-my-sleeve (NUMS)
point, which means that there's an unknown discrete logarithm you cannot
actually, as the creator of that output script, spend with the internal key.
So, basically you have a P2TR output for which the keypath is human-disabled.
Now, maybe also the caveat right away, quantum computers could still, if and
when they exist, revert that logarithm and then spend.  And funnily enough,
that would also give the owner of that output script a proof.  They can show
that it was a NUMS point and they could prove that someone broke the discrete
logarithm assumption.

So, yeah, basically from what I saw, there's a new write-up, a draft that is
being proposed, how to use the unspendable internal key in descriptors and
wallet policies, and I'll have a stronger opinion on this once it hits the
BIPs repository.

**Mike Schmidt**: So, yeah, we did talk about this a while back.  It's been a
couple of years we talked about it.  There was a delving discussion.  It had
Salvatore, Pieter Wuille; that was back in #283.  And then, Andrew Toth took a
crack at it, and we talked about that in #338, if people want to go back and
review that discussion.  Maybe just to recap, I think, Murch, you said it,
essentially disable the keypath spend.  Two questions.  One, why would you
want to do that?  What are the use cases there?  And two, isn't there this
sort of built-in NUMS point, and why not use that?

**Mark Erhardt**: So, the built-in NUMS point is present, but then you don't
want to exactly use the NUMS point, because when you reveal your scriptpath,
you have to show the internal key as the hashing partner of the merkle root,
and thereby you would show that it was a NUMS point.  So, I think it is always
a tweaked NUMS point.  But the question is not whether or not to use the NUMS
point, but rather, how this would work in descriptors, how you could express
the absence of an internal key in a descriptor or a wallet policy.  So, the
concept is available, has been discussed since 2022 at least.  The idea would
be you only want scriptpaths to be available.  So, you have a script tree with
maybe multiple alternative spending conditions, but the keypath is excluded,
because you only want script leaves to be able to spend that UTXO.  So, did I
cover all of your questions?

**Mike Schmidt**: I think so.  Would there be a privacy implication then too
if everyone's just using the NUMS point?

**Mark Erhardt**: Yeah, if everybody were using the NUMS point untweaked,
every time someone spent from a scriptpath, well, I'm going out on a limb
here, I'm not 100% sure, but from what I remember, in BIP341, a NUMS point was
proposed that is used to construct the internal key, and you would tweak it in
order to hide which one it is actually.  Because if you just use the same NUMS
point all the time, once you do a scriptpath in the control block, you have to
reveal, "Okay, here are the hashing partners for the merkle tree", and then
you also have to reveal the internal key.  So, everybody that uses the NUMS
point, if it were just the NUMS point, would reveal the same internal key.
So, every scriptpath spent that forbids the keypath would become identifiable
by that.  So, it is tweaked.  And by tweaking a number into it, you don't
learn the key.  So, it is still a NUMS point, and you can prove later that you
knew the tweak, and thereby it was derived from the NUMS point, if someone
needed that proof.  But it is no longer discernible for other people that you
used the NUMS point unless you prove it.

**Mike Schmidt**: Portland, any thoughts, or pass?

**PortlandHODL**: I'm going to pass on that.  I don't have enough insight or
information towards this specific proposal.

**Mike Schmidt**: For listeners, jump into the summary on the newsletter, and
there's also then the underlying post by NTL that is reinvigorating this
discussion, for more information and to participate yourselves.  Portland,
thanks for joining us.  Oh, go ahead, Murch?

**Mark Erhardt**: Also, if I said something wrong, feel free to correct me
below this show somewhere.

**Mike Schmidt**: Yell at Murch on Twitter!

**Mark Erhardt**: Yeah.  Flame me and correct me so I learn.

_BitBoxApp adds Spark-based Lightning payments_

**Mike Schmidt**: Thanks, Portland.  We'll see you.  We have two other Changes
to services and client software that we covered, in addition to the Oogabooga
guys' EntropyLab work.  There's BitBoxApp adding Spark-based Lightning
payments.  So, I'm emphasizing a couple things there.  One is this is the
BitBox application, so this will be on, I think it's their mobile app, and
it's version 4.52.0, adding support for Lightning payments through Spark.  So,
it's built on the Breez SDK and it's using the Spark statechain.  So, you can
do Lightning payments.  It's not necessarily using that hardware device that
people know BitBox for; it's in the app and it's a mobile app.  So, the funds
are held in a hot wallet on the phone rather than on the hardware device, from
my notes.

**Mark Erhardt**: Oh, really?  So, not even the signatures are being done with
the BitBox?

**Mike Schmidt**: I do not think so.  Now that you ask me, now I'm anxious
about making that statement.

**Mark Erhardt**: I haven't looked into that but my underlying assumption
would be that they use the BitBox for the secret management, but then the
mobile wallet app for the liveness.  But, well, I haven't looked at it, so I
might well be wrong.  I wanted to point out a couple more things about
statechains.  Statechains are semi-trusted, in the sense that the statechain
operator could cheat with any previous owner that held the same state coin.
When funds are transferred in a statechain, the secret is re-sharded by the
statechain operator and the new owner, I guess.  So, you're reusing a
different split of the same secret so other people can spend the same coin in
a statechain if they go back.  So, you're relying on the statechain operator
to faithfully execute the protocol.

The other thing that you rely on is the statechain operator gets full insight
on your payments.  So, this is apparently a way of making Lightning payments
from something that you have semi-custodial control over, but I just want to
point out that the trade-offs, both privacy and security, are slightly
different than vanilla Lightning.  It is of course a trade-off of convenience,
where running your own Lightning service or Lightning node has other issues.
Especially on a mobile phone, the liveness is still a difficult problem; we've
reported numerous times on async payments, not the company, ACINQ, but
asynchronous payments.  So, I just want to point that out because I believe
some marketing material called it just outright non-custodial, and that is
kind of offensive.

**Mike Schmidt**: Yes, I think this has come up several times in discussions
I've seen online, in that the nuance either gets glazed over on the marketing,
and then there's a fight on the back end about the technical.  So, appreciate
you clarifying that, Murch.

**Gustavo Flores Echaiz**: I want to add that Murch was right about the secret
being derived from the hardware wallet using BIP85, but the Lightning or Spark
wallet used is a hot wallet derived from the secret of the hardware wallet.

**Mike Schmidt**: So, I think that's for recoverability, right?  So, the
hardware device will have that secret and it's derived, but it's obviously
advantageous to have a hot Lightning wallet.

**Mark Erhardt**: Oh, okay.  So, it's a derived key that the hardware wallet
produces and then shares with the mobile wallet, and the mobile wallet uses
that to participate in the statechain, which means that the hardware wallet
can be plugged into a different device to recover the statechain access.

**Gustavo Flores Echaiz**: Exactly.

**Mark Erhardt**: I see, that's cool.  Well, kind of scary that you can export
private keys, but…

_Covenants.diy script editor_

**Mike Schmidt**: Our last piece of software from this month was Covenants.diy
script editor.  And we mentioned this one briefly, I think it was in the
instagibbs segment a couple of weeks ago when we were talking about Changing
consensus items, and sort of the ecosystem around OP_TEMPLATEHASH and
covenants, and things like that, sort of proof of concepts, things like this,
and tooling.  We mentioned it briefly in that newsletter, and I think maybe in
that podcast as well, but I figured we'd highlight it here as well for folks
to jump in.  So, this is a browser-based, I guess you could call it editor,
for building covenant scripts, and then sort of stepping through how they
might execute.  So, it includes a bundle of things we've been talking about as
prospective opcodes, including OP_CTV (CHECKTEMPLATEVERIFY), OP_CSFS
(CHECKSIGFROMSTACK), OP_CAT even, OP_TEMPLATEHASH, OP_INTERNALKEY,
OP_PAIRCOMMIT, OP_TXHASH, and then also APO (ANYPREVOUT) as well.  And user
beware, this is for test networks only, obviously, since these things aren't
activated.

But yeah, I thought it was interesting.  People keep talking, they want
covenants, so part of that is getting little tooling websites like this,
little editors to step through how things might work, and I think it might be
interesting for listeners to play around with.  Murch?

**Mark Erhardt**: Yeah, so it looks like both LNHANCE and re-bindable
signatures are completely covered here.  OP_TXHASH is part of the Great Script
Restoration proposal, or also a standalone.  And OP_CAT is separate, but has
had some demand in the past.  APO is BIP118, of course, which I think is a
little more superseded idea-wise, because re-bindable signatures, the BIP448
proposal, sort of replicates the things that APO was asked for, as in
LN-Symmetry.  But if you're into covenant research, it sounds like this is
something you might want to grab and go wild with on Inquisition.

**Mike Schmidt**: Thanks, Murch.  That's it for the News and for the Changes
to client and service software segments.  We have Releases and release
candidates and Notable code changes with Gustavo.

_Eclair 0.14.3_

**Gustavo Flores Echaiz**: Yes, thank you guys.  So, this week, we only have
one release from the Eclair repo, v0.14.3.  I'm going to talk more in detail
about the changes that are brought into this release, because we also cover
them as Notable code changes.  But briefly, there's a new configuration
parameter, called max-funding-feerate, which is the maximum feerate that your
Eclair node would pay for funding or splicing transactions.  Even if your fee
estimator were to say you should pay a higher fee, this configuration
parameter basically allows you to put a cap on the feerate that you would pay
for those transactions.  This is a protection against potential manipulation
of the fee estimator, which would make you pay excessive fees.  Of course,
there's a trade-off, because in some real scenarios, you would actually want
to pay higher fees, but this configuration parameter allows you to cap the
feerate you will pay for funding and splicing transactions.

There's also other changes that are more security-related that I'm going to
cover later on.  They're mostly related to channel closing scenarios, splicing
scenarios, and one important potential fund loss scenario on on-the-fly
funding, but we'll get to that more in a few minutes.  This release is a patch
release that contains important security fixes, so users are recommended to
upgrade in order to avoid running an Eclair node that has issues that could be
potentially exploitable by malicious nodes.

So, now we get into the Notable code and documentation changes section.  We
have a big, heavy week this one, about seven items from the Bitcoin Core repo.
Most of them are bug fixes.  And in addition, we have a few ones from the
Lightning implementations that are mainly bug fixes, but also a new BIP and an
update in an existent BIP specification.

_Bitcoin Core #35445_

So, let's start with Bitcoin Core items.  The first one, #35445.  Here, there
was a bug if you had a descriptor wallet that was using a miniscript
expression that was using the h syntax for hardened derivation markers,
instead of the apostrophe syntax.  So, this was really a syntax issue that if
you had a wallet that used the h syntax to define hardened derivation, after
upgrading to v31, you wouldn't have been able to load your wallet.  Yes,
Murch?

**Mark Erhardt**: Yeah, so maybe a little background on why the syntax was
changed.  A lot of the interactions with the RPC in Bitcoin Core, especially
if you do it through the console in the app, require a lot of escaping.  So,
you would frequently enclose parts like arguments to your calls with quotation
marks or apostrophes, the single quote marks, I should say, because the
apostrophe is actually a different symbol.  But anyway, the issue here is now
of course, if you use the single quotation mark as a hardened derivation
marker, you have to do extra escaping on that, whereas h is just a regular
character.  And I think that caused some usability issues in the past.  So, we
changed the expression, or the syntax, for hardened derivation in Bitcoin Core
over the last few versions.  Sorry, do you want me to also talk a little bit
about how this bug came to pass, or do you want to cover it?

**Gustavo Flores Echaiz**: Please go ahead.

**Mark Erhardt**: Okay.  So, the descriptors in themselves have a bit of a
challenge, in that you could create multiple descriptors that derive
equivalent output scripts, right?  And so, one attempt to notice whether we
have a descriptor already was to derive an ID based on the text of the
descriptor, like the textual representation of the descriptor.  If you put in
exactly the same text, we would notice, "This is the other descriptor that we
already have in the wallet with the same descriptor string".  And now, of
course, between one and the other versions, it was previously the single
quotation mark for hardened derivation, and then it was the h instead as the
hardened derivation marker.  So, the string changed, and therefore the
descriptor ID that was calculated from the descriptor string would have
calculated a different ID, and this caused the compatibility issue.  Now, the
fix for this was to instead treat the already stored descriptor ID as an
identifier that is not derived from the string directly, but just as a random
number that was stored to identify this descriptor.  And now, I think was this
where we introduced normalization so we always compare the strings?  Like, if
you put in a descriptor with a quotation mark versus a descriptor with an h,
it would recognize that these are both the same, even though the previously
calculated descriptor IDs would change.  It now compares the strings and will
realize, "Yes, this is intended to refer to the same descriptor".

The descriptor ID was only used in importdescriptors and
createwalletdescriptor, the two RPCs.  So, these now are based on a string
comparison rather than the descriptor ID.  We do think about using the
descriptor IDs internally still, now just as an identifier inside of a
scriptPubKey manager.  For example, we were just talking about how we would be
using that in the context of multisig setups, which we're working on here in
Localhost Research, to identify which key expressions participate in a
descriptor.  But yeah, so we still need sort of a way of disambiguating
descriptors internally, even though at the surface level, the RPC level, we no
longer use this identifier.

**Gustavo Flores Echaiz**: Exactly.  Thank you, Murch.  So, the issue here was
treating the identifier as a value that had to be recomputed from the string.
So, if you would change the syntax, then the identifier wouldn't match
anymore.  Now instead, the identifiers aren't treated as such, simply are
treated as links between related wallet records.  And now the RPCs,
importdescriptors and createwalletdescriptor, compare the strings instead of
the identifiers.

_Bitcoin Core #36076_

Next item, Bitcoin Core #36076.  This is another bug fix when using the
combinepsbt RPC.  When you're combining two different PSBTs, you could discard
the sighash (signature hash) type of the second PSBT file.  So, if your first
PSBT file didn't have the sighash type defined in the PSBT_IN_SIGHASH_TYPE
field but the second one did, and the second one also was properly signed,
then because you would first put a PSBT that didn't have that field, Bitcoin
Core would simply erase the field.  And then, there would be a mismatch
between the signature and the absence of the sighash field.  Actually, it
would get overridden.  So, if you were using a non-default sighash type, this
is when this problem would occur.  Yes, Murch?

**Mark Erhardt**: Yeah, so the thing is that when you create a signature, you
get to pick which sighash you use, so what parts of the transaction do you
commit to with your signature.  You can commit to all the inputs or the one
input that you're signing, you can commit to all the outputs or just the one
output at the same position that you're signing at in the input list, or you
can commit to none of the inputs or none of the outputs, and combinations
thereof.  But the person that signs, or the user that signs, gets to decide
the sighash type of their signature.  So, this problem would occur when
someone creates a PSBT, it doesn't make any determination about the sighash
type, and then someone else adds a valid signature with a sighash type.  And
now, the conflict was between no sighash type and the provided sighash type
with this signature.  Is that right?  Yeah, okay.

So, yeah, we talked about how we combine fields when they disagree, I think a
few weeks ago.  And obviously, if there are two different values for the same
field, that is an issue.  But if there's only one value, it should override.
So, it sounds like the absence of a type here was equivocated with the default
type, and that's where the conflict came.

**Gustavo Flores Echaiz**: Precisely.  And it was also depending on the order
of the PSBT files, right?  It had to be that the first file didn't have the
field.  That's where the conflict would arise.  So, now, it doesn't matter in
which order you put them, it will retain the field if it's not a non-default
sighash type.

**Mark Erhardt**: Basically, the difference between null and zero, or null and
the default value.  You have to explicitly realize whether the default value
has been picked or no value has been picked.

_Bitcoin Core #36150_

**Gustavo Flores Echaiz**: Right.  Next item, Bitcoin Core #36150.  Here, this
is a bug where if you have an archival node, just a regular node that is
unpruned, and you also haven't configured yet either a compact block filter
index (-blockfilterindex) or UTXO set statistics index (-coinstatsindex), so
you haven't configured any of those, but you decide to prune your node to
enable pruning, at the same time, you decide to enable one of those indexes.
Then, you restart your node and the pruning begins before the index.  So, it
starts pruning all block files before the new index put a lock into those
block files, so that the index could be built before those block files were
eliminated.  So, you would find yourself in a moment where the process
couldn't even continue, because the index would simply return an error because
the block files were absent.  So, now, the fix is to put a lock at height
zero, so the index builds and the pruning can begin after those files have
been used.

**Mark Erhardt**: I didn't read this PR, but does it throw an error or does it
try to re-sync?  Because if you turn on -blockfilterindex, I think it would
have to recover the block files in order to reintroduce it.  So, if you had a
pruned node and turned it on, it would probably just process the entire
blockchain again, or does it just error that the files are not there?  I
haven't checked.

**Gustavo Flores Echaiz**: From my understanding, the index simply fails to
start syncing and tells you to re-index.

**Mark Erhardt**: Right, you would need to re-index in order to get the data,
but it doesn't do it automatically.

**Gustavo Flores Echaiz**: Exactly.

**Mark Erhardt**: Yeah.  The first time I read this News item, I thought it
was always when you turned on compact block filter and were already pruning,
that it would, on restart, first prune and then update the index.  I'm glad
it's only when you go from an unpruned node to a pruned node, but that's an
important thing that I missed the first time I looked at this.

_Bitcoin Core #36174_

**Gustavo Flores Echaiz**: Right, good clarification.  Next item, Bitcoin Core
#36174.  This is about the replacement HTTP server, which we covered in
Newsletter #411, which is now replacing the libevent-based HTTP server, one of
the last remaining dependencies in Bitcoin Core.  In Newsletter #422, we
covered some fixes to this server that were complementing the receive-side
protection.  And now, the new item is about send-side protection, or
backpressure.  So, in Newsletter #422, we covered a client is making too many
requests; we've got to limit those requests.  Here instead, the problem is
that the client that has made many requests isn't reading the responses that
our node is giving back to it.  So, the queued response data is growing
indefinitely.  So, now, the fix is simply to pause processing of further
requests when the send buffer exceeds 32 MiB.  And it resumes once the client
starts draining the responses.  So, it will actually start reading the
responses, then the send buffer drains or reduces in size, and then we can
start processing new requests again.

_Bitcoin Core #34743_

The next item, Bitcoin Core #34743, this is about how, if you manually
selected some peers, either through the -addnode, -connect options, or the
addnode RPC, if these manually selected peers would stall block downloading
during IBD, previously your node would simply disconnect the peer.  Now, what
it does instead is that it will simply request the same blocks that were
getting stalled from other peers and pause new block requests from the
stalling peer for two minutes.  So, instead of disconnecting the peer, you
simply stop requesting blocks from it for two minutes.  And this is
specifically when the peer is stalling block download during IBD or during,
let's say, another moment of you need to sync multiple blocks.  So, other
peers are already giving you the next blocks, but this peer is unable to
complete this block request.  And that's what we called 'stalling block
download', which is different from just timeouts set for header syncs or
separate block download timeouts, right?

In regular timeouts, you will actually disconnect from this peer.  That
scenario remains as it was previously working.  It's simply in the scenario
where your peer is stalling block download.  That's when you won't disconnect
from it if you had manually selected that peer.  You will simply pause new
block requests for two minutes.

_Bitcoin Core #36081_

The next item, Bitcoin Core #36081.  This is about adding a new field to the
getmininginfo RPC response, called bestblockhash.  So, the problem here is
that there could be a sort of race condition where you want to obtain the next
object, so you want to know what's going to be the difficulty target for the
next object, and you want to build on the current tip hash.  But because you
had to make two requests separately, there could be a sort of race condition
where the current tip hash could change while you were making the second
request.  So, now, that field that defines the current tip hash is added to
the same RPC response.

_Bitcoin Core #35975_

Next one, Bitcoin Core #35975.  This fixes a potential wallet crash when, if
you had in your wallet two malleated versions of the same transaction but you
bumped the fee on simply one, it didn't immediately mark the other one as
replaced.  So, if you were to attempt to bump the other one too, that could
trigger an assertion failure and would crash the node.  The fix is simple.  If
you bump the fee of one of the transaction versions and that one gets
replaced, the other one has to be marked as replaced too.  And if you were
trying to bump the fee of the variant, that would simply hit an error instead
of hitting an assertion failure and crashing the node.

_BIPs #2241_

The next items are from the BIPs repository.  So, BIPs #2241 adds BIP332.  So
maybe, Murch, I don't know if you want to jump in here, but this is about the
specification of a new message that is using the BIP434 peer negotiating
support feature, or called opt-in relay of recent stale chain tips.

**Mark Erhardt**: Right, so this introduces the capability for nodes to opt
into participating in stale tip relay, and that's also the title of the BIP.
The idea here is that occasionally, the Bitcoin Network has two competing
blocks at the chain tip.  And when that happens, you would usually only learn
about one in most cases, because once you hear about the first one of the two
competing blocks, the second one you would download but not forward.  So, it
sort of creates a rift through the network, where on one side the nodes have
received one block, and on the other side they have received the other block
first; and on the borderline, they know about both blocks, but they do not
forward the information about the second chain tip.  So, this is interesting
when there's a reorg, because if you know about the other chain tip already,
you would be faster at reorging to the chain tip that wins if you're on the
other one.  And it is especially also interesting for researchers that are
trying to track the stale rate.  So, how often stale blocks occur as a measure
of how much latency there is in the block relay system, and it can also
indicate selfish mining attacks and other deviant behavior, where the stale
rate goes up for malicious reasons.

So, this is a proposal for telling other peers that want to hear about it when
you have seen more chain tips.  It will also propagate, on first connection,
up to ten chain tips from the last 1,000 blocks, so in the last week.
Usually, we only have one of those every other week.  So, it shouldn't usually
be a lot of data.  But I think it is also already implemented in Bitcoin.  No,
sorry, there's only a draft for Bitcoin Core.  So, if it were coming to
Bitcoin Core, it would be not in the upcoming release v32, but in v33 or
later.

_BIPs #2258_

**Gustavo Flores Echaiz**: Thank you, Murch.  The next item is also from the
BIPs repository, PR #2258.  Here, BIP93 specification, which defines Codex32,
which are a way of encoding BIP32 seeds different from the BIP39 protocol.
So, here, I don't know, Murch, if you know much about this, but from my
understanding, this is about fixing checksum length limits.  So, the prefix
was not being considered.  The checks were only counting the data portion, so
some strings would exceed the lengths of the error-detection guarantees of the
checksum.  And also now, the encodings have a specific size.  They used to be
very flexible.  I think it was from 16 to 64 bytes.  But now, they have
specific defined byte sizes, either 16, 20, 24, 28, 32 or 64, to avoid user
error.  So, if, let's say, you made a transcription error where you added or
removed a digit, then this would allow you to know better whether you made
that transcription error or you didn't.  Anything you want to add here, Murch?

**Mark Erhardt**: Yeah, this is part of an effort to make a bunch of
improvements to BIP93, which is Codex32, which is an extremely work-intensive
way of manually, literally with pen and paper, creating your own entropy --
no, not the entropy, but to shard keys.  And, yeah, so this one contributor
has been digging into BIP93 for a few months, and I think the overall
intention or motivation there is that BenWestgate seems to be working on
introducing BIP93 support into BIP85, so like a dedicated derivation path.
And yeah, this has been going on, and it started as one very big change to
BIP93, and now changed into, I think, six PRs that are all more focused and
smaller.  But anyway, there's a bunch of cleanup coming to BIP93.  BIP93 is
still in draft status, even though we have maybe already played around with
volvelles and with, well, big books of tables to fill out at various workshops
in the last, whatever, six years or so.  This is a draft BIP, and it looks
like there's, at the edges, still improvements being made.

If that sort of thing, calculating key shards by hand, is your thing, you
might want to check out BIP93 and the recent changes to it.  There are still
several open PRs.

_Eclair #3380_

**Gustavo Flores Echaiz**: Great, thank you, Murch.  The next three items are
from the Eclair repo.  The first one, a pretty simple one, #3380.  Here,
Eclair adds rejection of API requests that contain an Origin header.  Usually,
the API requests that contain an Origin header come from a browser.  So,
basically now this doesn't allow any more browser-based front end to call
Eclair directly.  It has to call its own backend that then its own backend
would call Eclair directly.  This is to prevent cross-site request forgery
using cached HTTP Basic authentication credentials.  If you're using
command-line clients, such as curl or eclair-cli, this remains unaffected,
unless you explicitly set this header.  But if you are making these API
request calls directly from a browser, then the Origin header is automatically
set.  And that is now forbidden by Eclair too for security reasons.

_Eclair #3376_

The next item, #3376.  This is the main security finding that was included in
the latest Eclair release.  There's multiple fixes being packaged here, the
first one is in a closing fee negotiation scenario.  So, if Eclair pays the
fees, let's say your node pays the fees, but your peer proposes a fee that
exceeds what you have configured as your maximum closing feerate, in a
scenario where your peer didn't support fee ranges, which is a part of an
advanced version of the fee negotiation protocol -- so, very old nodes don't
support fee ranges -- then if you were negotiating fees with a node that
didn't support fee ranges, then your node could accidentally accept the fee
being proposed by your peer, even if it was above your maximum closing
feerate.  So, an attacker running an old version of a Lightning node could
convince your node to pay an excessive amount of fees.  And now, Eclair simply
makes sure that it will never accept a fee range that is outside of its fee
range or that is above its configured maximum closing feerate.  That's the
first issue.

The second one is if in your node, Eclair is involved in a splicing
negotiation, but it has to force-close the channel during an incomplete
splice, and it had already exchanged commitment signatures for the post-splice
state, but it hadn't yet completed the splice, previously Eclair would try to
broadcast the commitment transaction after the splice state.  But like I said,
the splicing was incomplete.  So, it would simply make no sense for Eclair to
broadcast that transaction that's dependent on the splice that was incomplete.
So, now Eclair will broadcast the latest commitment whose funding transaction
has been fully signed.  So, in the scenario where the splicing is incomplete,
it won't broadcast the commitment transaction that depended on the splicing
transaction.  It will broadcast the previous commitment transaction that
depended on the initial funding one before the splice even took place.  So,
this is a fix when force-closing, Eclair would simply broadcast the correct
transaction instead of broadcasting one that doesn't have a finalized state
yet.

However, in this specific scenario where you broadcasted that commitment
transaction, if your peer who has received your splice and signature, so he
has both signatures for the splice, if he broadcasts the splice and the splice
confirms first, the other addition to this PR is that Eclair will instead
close using the commitment that followed the splice.  So, I want to take a
step back.  The first part of this PR was about the closing scenario that I
covered.  Now, we're talking about the splicing scenario, and there's two
parts to this splicing scenario.  First, Eclair broadcasts the correct
commitment transaction when it wants to force close.  But if ever the peer
broadcasted the splicing transaction, then Eclair will properly respond with
the commitment transaction that followed the splicing one, which will allow
Eclair to properly respond to the peer.  That's the second part of the PR.

The third part is a fund-loss scenario when executing an on-the-fly funding
payment via blinded paths.  So, basically, Eclair will always make sure that
the outgoing HTLC (Hash Time Locked Contract) has a lower CLTV
(CHECKLOCKTIMEVERIFY) expiry delta than the incoming HTLC, except in a
scenario of on-the-fly funding via blinded paths.  So, in that specific
scenario, yes, Eclair constructs the outgoing HTLC and defines the CLTV expiry
delta, but the outgoing peer constructs the blinded path in his invoice, and
those instructions specify a CLTV expiry delta.  Eclair is not supposed to
trust those instructions, it's supposed to decide on its own what CLTV expiry
delta it will use.  However, in this specific edge case, it wasn't properly
looking for that.  So, it would simply accept any CLTV expiry delta that was
instructed in the blinded path of the invoice.  And that could lead to a
fund-loss scenario because at the same time, it would be an unsafe forwarding
where the downstream peer could claim the payment, but the incoming HTLC would
expire before Eclair was able to recover that.  So, it would lose funds in
both edges.  So, that's the third part of the PR.

The fourth part is adding the configuration setting that I discussed earlier
on in the release section, which is called on-chain-fees.max-funding-feerate,
which defines the maximum feerate that Eclair will ever pay.  Even if its fee
estimator says to pay a higher fee, Eclair will refuse to pay a higher fee
than the configured setting.  And this is a protection against manipulation of
fee estimators.  Of course, it has a trade-off, because in some scenarios you
do want to pay that high fee, but it allows users to define a maximum feerate.

_Eclair #3372_

The next item, Eclair #3372.  This is when Eclair is acting as a trampoline
node, an issue was that Eclair, as a trampoline node, was retaining too much
of a fee, which was making the payment fail eventually, because the fee budget
reserved for downstream routing wasn't sufficient, specifically in the case if
the receiver was using an LSP (Lightning Service Provider) and the LSP was
charging a forwarding fee.  So, now there's a new setting that allows an
Eclair node that is acting as a trampoline node to define the minimum fee that
Eclair retains, so that Eclair can minimize the fee that it retains and allow
the budget to cover the downstream fees, including those charged by the
recipient's LSP.  At the same time, the PR also increases the default minimum
total fee budget.  So, on one end, there's a new setting that allows Eclair to
retain less fees as a trampoline node, but at the same time, Eclair now asks
for a larger minimum total budget.

_LND #11163_

The next item is from the LND repo #11163.  This one fixes the handling of
replayed HTLCs when using the forward interceptor.  So, the forward
interceptor was covered as early as Newsletter #104.  It adds the ability to
delay forwarding a payment by giving an external process the ability to review
and decide the forwarding of the HTLC.  So, here, the issue was if your peer
would disconnect and reconnect, or your node would restart, LND might
reprocess the incoming HTLC, even if it has already forwarded it.  So, that
means that LND could treat this as a new interception, and if the expiry was
too close, it would simply reject it, even though it had previously already
forwarded the HTLC.  So, it would think that it's a sort of new HTLC when it's
simply just one old one being replayed.  So, now, LND simply checks existing
forwarding records.  It allows the replay to continue through the original
payment's resolution.  It doesn't take a new decision here, and it avoids the
scenario where it would simply reject the HTLC because it thought the expiry
was too close, even though it had previously accepted.

_BDK #2246 and #2263_

The final item from this list comes from the BDK repo, two items, #2246 and
#2263.  This is about how wallet balances are classified.  Previously, for
example, if you had change that came from spending an unconfirmed incoming
payment, that change, because it was change, it could be considered trusted as
if it came from your wallet.  However, the change was coming from an
unconfirmed incoming payment.  So, BDK was not properly classifying wallet
balances, because it wasn't properly checking the output's unsettled
transaction ancestry, right?  So, now BDK ensures to check the ancestry of
each UTXO to make sure to properly classify it either as trusted or as
untrusted.  And there's a new API, called classify_outpoints, which allows a
user to classify the outpoints himself.  And there's even another function
being added, called confirmations_lower_bound, which helps applications define
settlement rules.  For example, this should require six confirmations before
it's considered settled, so that's also part of this addition.  And that's the
final PR item and this completes the newsletter.  Thank you.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.  And we also want to thank our
guests today, Davidson, Eric, and Portland for joining, and Murch for
co-hosting, and you all for listening.  We'll hear you next week.  Cheers.

**Mark Erhardt**: We would have made a shorter News Recap if we had had more
time, right?

**Mike Schmidt**: Yeah, that old saying.  Was that Mark Twain?!  Yeah, cheers.

{% include references.md %}
