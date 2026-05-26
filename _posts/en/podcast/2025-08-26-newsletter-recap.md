---
title: 'Bitcoin Optech Newsletter #368 Recap Podcast'
permalink: /en/podcast/2025/08/26/
reference: /en/newsletters/2025/08/22/
name: 2025-08-26-recap
slug: 2025-08-26-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt discuss [Newsletter #368]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-8-8/407136571-44100-2-6635c69c8e92b.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #368 Recap.
Today, Murch and I are going to be talking about block template sharing and the
new BIP, emulating soft forks with trusted execution environments; and then we
have some highlights to ecosystem software, including items about a Bitcoin
kernel-based node, Utreexo, and the Simplicity programming language, among other
topics.  We'll jump right into the News section.

_Draft BIP for block template sharing_

First news item this week is titled, "Draft BIP for block template sharing".
Murch, you and I had AJ on a few weeks ago to talk about, I think it was a
Delving post, in which AJ outlined his idea for peers to be able to share what
they would consider their block template with their peers, what they would be
mining for the next block.  Murch, maybe you could help remind me and the
audience, why would we want to do that?

**Mark Erhardt**: Well, so recently, we've seen that people's mempools diverge a
lot more than they used to, both because there's a divergence in the policies
that node operators predominantly run, and because there is some small subset of
nodes that run more lenient mempool policies, and these have been adopted by a
majority of the hashrate.  So, we're now seeing somewhere over 40% of
transactions being below the previous min fee rate, which means that while these
transactions are at the top of the mempool, blocks propagate much slower because
instead of getting essentially what is a recipe to how to recreate the block
from a compact block announcement with the short IDs of the transaction that are
contained in the block, after receiving the recipe, nodes notice, Oh, wait, I'm
missing something like 30% or 40% of these transactions.  Could you give me this
list of items?  Sending that back, and then there's round trips to retrieve that
data, there is a limit on how much data TCP will provide per round trip.

So, with this amount of data, there's a significant delay in how quickly blocks
propagate between nodes that are missing a lot of the data.  We've been seeing
that the block propagation is slightly elevated for 50% of the listening nodes;
but for 90% of the listening nodes, it's gone up multiple seconds.  And this is,
of course, already a subset of the node population.  The listening nodes are
nodes that have up to 125 connections by default, they're very well-connected.
If even the tail end of that is so slow, the non-listening nodes, the nodes that
only depend on this backbone of the Bitcoin Network will receive blocks even
slower.

So, essentially the idea is, as I understand it, unfortunately I had AJ on last
week when we were trying to record this podcast, but he couldn't make it today,
my understanding is AJ's thought is, "What if we allow nodes to exchange more
often what they consider their top of the mempool with each other?"  This would,
for example, allow new nodes that had been offline and rejoined a network, to
quickly catch up what's maybe on people's radar to be included in blocks soon.
It would also potentially allow nodes to build support for keeping the top of
the mempool of some of their peers around.  So, when a node has a few peers that
have vastly different mempool policies, they could ask them every few minutes, I
think AJ was thinking about every two minutes, "Hey, what's your top 2
mega-vbytes of the mempool?"  And then, per AJ's sendtemplate proposal -- let me
take a step back.

So, AJ has a concrete idea now that he proposes here.  This is already open in
the BIPs repository and my spies are reporting that it might get a BIP number
soon!  So, the idea is basically a few new P2P messages where you announce a
service to your peers, "Hey, I can share templates", which is basically a table
of contents of the top of your mempool, and the other peer might then use a
sendtemplate message which -- sorry, no, sendtemplate is the one that announces
the service; gettemplate is, "Could you please give me the top of your mempool?"
and then the reply would be a template message where the serving node provides
basically a compact block formatted recipe, "Here is what I have in my top 2
MB".  Then, maybe in the future some nodes would put aside a little bit of RAM
to keep the top of the mempool around -- well, they would try to put it in their
own mempool.  But whatever doesn't pass their mempool policies might live in
another data structure where you might maintain that for three of your peers,
and just have an overview of what they consider the best transactions at the top
of their mempool.  And then, you would occasionally update that, ask again.

There's been a little bit of discussion how it might be a little more
bandwidth-efficient.  You could only send a difference between the previous
announcement, or you could use other formats to encode it more efficiently.  But
generally, it's just a way for sort of looking over the rim of your plate to see
what other people are doing in their mempool.  It might also be an interesting
way to get transactions that had been in people's mempools for a long time
rebroadcast, because if someone gets a transaction through these announcements,
they would consider it freshly added to their mempool and would re-announce it
to their peers.  So, where previously there really wasn't a mechanism by which
transactions that had been in the mempool for a long time would get rebroadcast
by Bitcoin Core nodes, with the sendtemplate scheme, these transactions that had
been around for a long time might get reintroduced to other people's mempools
and get rebroadcast at that point.

So, overall, there's a few nice little benefits to that.  The encoding of just
sending the short IDs of the transactions wouldn't make it extremely big, it's
probably around 40 kB or so.  You would only do it with a small subset of your
peers.  The proposal here is only for the messages.  And so, the recommendations
on how it would be implemented or used by node implementations are not nailed
down in this document at all.  But that's sort of the state of where this topic
is at from my perspective.

**Mike Schmidt**: There's a couple of things that I pulled up here that are I
think relevant to what you said.  One is actually the PR that we're going to be
getting to later, #33106, which makes some changes to relay fee rates.  There is
a response in that thread, a comment by 0xB10C, and he actually has a screenshot
of his mainnet observer, and he's got a chart on share of compact block
reconstructions over time.  And if you look, you can see very clearly that
there's basically a bunch of green over time, and then all of a sudden it turns
yellow, and all of a sudden it turns this dark orange, meaning that, well, I can
quantify it here in what he says, "In June, we were requesting less than 10 kB
worth of transactions per block on average for about 40% to 50% of blocks.  Now,
we are requesting close to almost 1 MB, 0.8 MB worth of transactions per block
on average for about 70% of blocks".  So, you now have the visual here, the
green to orange, but you also have those example data points.

So, when Murch is saying that block reconstruction is slower, this is a way that
someone is monitoring this information.  And we'll actually get to that later,
also his monitoring call to action later, and actually seeing this in real data.

**Mark Erhardt**: Yeah, this is especially interesting in the context of the
engineering that's gone into enabling miners to build their own templates at
home.  We want blocks to propagate as quickly as possible to all participants in
the network, because miners are participants in the network and they should
switch to the new best chain tip as fast as possible.  We expect an interval
between blocks of 600 seconds.  So, if it takes them six seconds to switch
between a block being found and them mining on top of this new block, that's
roughly 1% of revenue lost, right?  And it's a 6-second interval in which miners
are working on the old chain tip, and it's more likely for stale blocks to
appear.  So, of course, with the delay, very likely most of the other miners
have already received the prior announced block, the first block that was found.
So, it increases the window in which people waste work.  And it is my opinion
that this especially affects nodes that are less well-connected.

So, if people are building their block templates at home, I think that they
would have a significantly higher delay than large mining operations that
centrally organize block templates.  To make mining as fair as possible, where
people receive close to exactly their proportion of the hashrate in revenue,
requires that the delays are small, that people can quickly learn about new
blocks and switch and not waste work.  And especially when stale blocks occur,
larger mining operations have a big advantage in winning that race because they,
of course, mine on their own blocks.  So, if someone has, say, 30% of the
hashrate, 30% of the hashrate is going to work on their own template to build
the best blockchain from that.  The rest of the 70% of the hashrate is split
between whoever found the competing block when they learn about it, because
usually the miners always mine on whatever block they first hear about.  So, a
well-connected, big mining operation that has 30% of the hashrate will very
likely push out on many different nodes, quickly make that first hop to many
different peers, and smaller miners tend to just lose that stale block race much
more often.

So, this delay makes the advantage that bigger mining operations have already
worse.  And that's one of the reasons why block propagation is a concern for
Bitcoin Core contributors.

**Mike Schmidt**: Murch, am I thinking about it right that if you have this
delay, where let's say the larger miners are well-connected and are able to push
out blocks to each other fairly quickly, maybe they know who each other are via
contractual agreements, or maybe they know just from spying or some other such
analytics, that they get to each other quickly.  But I think what you're saying
is that these blocks then get to the smaller miners slowly, which somewhat has a
similar effect as selfish mining, right, because whether the miner is purposely
not disclosing the block to the broader network or whether it's just an artifact
of the P2P network that the block is delayed, the effect is the same, that you
have large miners that are able to immediately start building on the new chain
tip, whereas the smaller miners are disadvantaged, and all the negatives that
come with that that you pointed out.

**Mark Erhardt**: Yeah, that's exactly what I'm saying.

**Mike Schmidt**: Okay, that makes sense.  This reminded me when we spoke with
AJ, and I'll just insert it again here for the audience, it reminded me of the
weak blocks proposal that Greg Sanders came out with.  And I'll remind people,
as I reminded myself a second ago when I brought up the transcript of our
discussion, why not weak blocks?  Don't I want to see what the miners are going
to mine, because they are the ones who are mining?  And AJ pointed out two
downsides to that approach.  One is, you're going to get biased; only the big
miners are probably the ones you're going to get these weak blocks from.  The
bigger the miner, the more weak blocks you're going to get from them, so that's
one downside.  Whereas if it's truly P2P nodes, then you're going to get a more
diverse set of potential block templates.  And then the other disadvantage was
just timing.  If you can choose every so often to ping one of your peers, you
get a more refreshed version of block templates than you would if maybe six
minutes ago, you had a weak block from a minor and that data becomes stale after
a short period of time.  So, you sort of want more regular refreshes.  Was that
your takeaway as well?  Do you remember that?

**Mark Erhardt**: Yes.  So, weak blocks would work by basically setting a lower
threshold for making an announcement what you're working on, right?  So, you
might at 20% or 10% of the current actual difficulty.  If you surpass that, you
announce a weak block.  So, we would expect roughly 10 weak blocks per block.
But just like a large miner is very likely to find the next block proportionally
to the hashrate they bring to the table, if we're doing things right, they would
also be much more likely to offer the weak blocks.  So, a smaller mining
operation with just a few rigs would be much less likely to announce their
perspective of the network.  So, we wouldn't get this sort of, "What do my peers
think?  What would my peers be able to relay immediately?"  We can't ask just at
random times whenever we want that data, we would get it randomly whenever a
weak block is found.  And potentially, depending on what difficulty you set, it
would be a lot more data floating around, because if weak blocks diverge
drastically, we would perhaps get several of these and store them.

So, I think this proposal makes sense in the amount of control the node has in
how often they want to request it, how much of that they want to store, what
they do with it, do they add it to their mempool or just keep it in a side data
structure.  So, yeah, the advantage of weak blocks would be, of course, that
it's proof-of-work protected.  So, it would be hard to spam it because you
actually have to do the work.  But yeah, that's roughly the overview.

**Mike Schmidt**: I think it was you that had brought it up in our discussion
with AJ, but we noted it here at the bottom of the write-up, about this idea of
using set reconciliation, potentially using something like minisketch, which
people have talked about with Erlay for transaction relay, to do that here.  Is
that something that's in the BIP or in consideration at this point, or just it's
easier to use compact block messages as they are today and don't mess with
minisketch?

**Mark Erhardt**: Right, so minisketch is used in Erlay and maybe it's also good
to draw a comparison with Erlay.  Erlay is proposing to reconcile what you would
be announcing to your peer with what the peer would announce to you.  So,
instead of what you have in the mempool, these are the new things that you would
be announcing to each other.  And because you're both online at the same time
and you hear network messages from peers, these sets should be largely
overlapping, and reconciling them takes only a very little amount of data.  You
only have to send as much as the difference between the two sets for Erlay to
work well.  The approach here is potentially sending the entire top 2
mega-vbytes of the mempool.  For example, when a node just came back online and
he asked his first peer, "Hey, what do you have in your mempool?  Can you give
me the top of the mempool?" they don't have anything, so you would have to send
all of the data anyway.  There is no big overlap already that makes minisketch
very efficient.

With this, it might be 100% difference.  Or, let's say a node that accepts
low-feerate transactions talks to one that doesn't, or a node that accepts
inscriptions talks to one that doesn't accept inscriptions; they might diverge
on 20% to 40% of the top of their mempool because we have roughly 20%
inscription transactions and 40% low-feerate transactions right now, right?  So,
these are huge differences and reconciling them would be not very efficient with
minisketch, is my understanding.

**Mike Schmidt**: Okay.  Maybe one more question.  If this was deployed today
and then the network started mining, let's say I want to have 1 sat/vB (satoshi
per vbyte) as my min relay, and the network, in conjunction with a lot of the
miners, decides we're going to start mining 0.1 sat/vB transactions, so all of a
sudden I would start seeing these block templates coming to me that are being
shared with that lower feerate.  And so, that would not go into my mempool in
this mechanism, right?  It would go to a separate data structure and that would
be stored there.  So, just if I'm getting this right, we would then have the
mempool, the orphanage, the vExtra, and then this block template sharing as
holding pens for transactions that are unconfirmed.  Do I have that right?

**Mark Erhardt**: Well, as I said, the proposal doesn't really specify a new
data structure yet.  It just talks about these messages.  But there has been a
lot of talk about something called the extrapool, which Bitcoin Core uses to
keep some of the recently removed transactions.  So, for example, when you see
an RBF, like one transaction is replaced by another transaction that pays a
higher fee, but they both spend the same inputs RBF, then it very much depends
on when the next block comes in and whether the miner already saw that
replacement for the block template or didn't.  So, very often, the prior version
of a transaction before it got replaced is in the block instead of the
replacement, if the template was built a few seconds ago, or something like
that.  So, the idea behind the extrapool was to have a place where you can cache
some of the latest changes in your mempool in case a block comes in right after
the mempool changed.

So, some people discussing recent matters on the internet have been arguing that
this would also help with other things that are rejected from their mempool.
But maybe just to explain how the extrapool is set up in Bitcoin Core, it's a
very small, simple data structure that in Bitcoin Core by default only holds 100
transactions.  It will, however, keep transactions that take up to 100 kB of
memory.  So, with all the overhead of deserializing it and the context and the
UTXOs that were loaded in order to test the inputs and the whole data structure
for storing the transaction in their mempool, it's not about the serialized
size, but the size of what the mempool spends, or what the mempool data
structure takes in memory, right?  So, Bitcoin Core will store 100 times 100,000
memory bytes.  And so, if you drastically increase that, the data structure is
not really designed for that.  There is no DoS protection, there is no cycling
or anything.  It just probably lets first in, first out.

**Mike Schmidt**: And would that happen now?  Is that where policy-violating
transactions go now, including low feerate?

**Mark Erhardt**: I think that is the case, but well low feerate you would never
get anyway.  When you start up a reasonably recent version of Bitcoin Core, and
I think we're referring to any since 0.13, it will communicate with its peers a
min fee filter, and the min fee filter will indicate to the peer what the lowest
feerate transaction is that you're interested in.  So, your peers will simply
not send you transactions below that.  It's basically pre-emptive rather than
reactive.  So, yeah, you'll actually not have low-feerate transactions in the
extrapool because you shouldn't be getting them in the first place.  This might
work for something like an inscription transaction if your node rejects an
inscription transaction though.  But for context, a block has usually around
3,000 to 4,500 transactions, and by count I think 20% of the transactions have
inscriptions still.  So, we're talking about 900 transactions here missing.  And
by default, the extrapool stores 100 of all of the transactions that recently
dropped from the mempool, not the top mempool, right, not the next block.  So,
it might help a little bit, but it doesn't solve the issue with the delay.  You
will not have all of what you're missing from a block in your extrapool, even if
you blow up the limit very drastically.

**Mike Schmidt**: So, back to AJ's template sharing, the fee filter would have
to be ignored for purposes of block template sharing, so that you could get in
this hypothetical scenario the low-feerate transactions that are below your
limit?

**Mark Erhardt**: Right.  However, reminder here, it gives you the top two
blocks of data.  So, your mempool would basically be empty at that point because
you don't accept these lower-feerate transactions.  Your peer thinks that these
lower-feerate transactions are in the top of the mempool and likely to be mined
in the next couple blocks, and is just giving you the short IDs of those
transactions.  Then your node could still say, "Okay, do I want them?  Do I not
want them?  Do I request that inventory?"  And then in that case, your node
might store the top two blocks' worth of transactions in a separate data
structure.  So, currently looking at the mempool, for example, the top two
blocks do not have transactions below 1 sat/vB.  So, you wouldn't get them in
that case, right?  In that case, you would only hear about transactions you'd be
accepting anyway.

**Mike Schmidt**: Yeah, unless someone just hijacks this sendtemplate to send
things that aren't in the top two blocks.

**Mark Erhardt**: Sure, but then you'd probably stop requesting their templates.

**Mike Schmidt**: Yeah, I was thinking if there's a scoring mechanism or
something, if someone's just sending you a bunch of it.

**Mark Erhardt**: Again, this is just about the new sendtemplate P2P message and
how the data structure for the template might work.  How this new peer service
would be used by implementations is not currently part of the discussion yet,
and I don't think there's a draft for that yet.  Most certainly, it's not
deployed anywhere yet.

**Mike Schmidt**: Well, hopefully we'll have AJ on if we get to that point,
answering all my questions.  But I think we did pretty well on this news item.
I think we can wrap it up.

**Mark Erhardt**: Sure.

_Trusted delegation of script evaluation_

**Mike Schmidt**: The second and last news item this week is, "Trusted
delegation of script evaluation".  News item was inspired by Josh Doman's post
to Delving Bitcoin about something that he wrote, a library that would use TEE,
which is a Trusted Execution Environment.  I think in this example, it was an
Amazon Web Services enclave that would only sign keypath spends if the
transaction containing that spend satisfies a particular script.  And I think in
his scheme, that script could be things that include opcodes that are not in
Bitcoin potentially, and that that TEE would contain the logic to execute that
opcode and sign accordingly.

**Mark Erhardt**: Or even completely different languages.

**Mike Schmidt**: Yeah.

**Mark Erhardt**: So, your TEE could evaluate a Simplicity Script and check
whether you can satisfy the Simplicity Script.  And if so, it would return you a
keypath signature so you can spend the thing.  So, yeah, I didn't get a chance
to talk much to Josh last week about this, but my understanding is that it's
sort of a way how you could experiment on these potential future changes to
Bitcoin's consensus engine.  And you both get a fee savings, because presumably
the script that the TEE is evaluating would be much bigger and more complicated,
but then the onchain footprint would only be a simple keypath spend, a P2TR
single-sig spend.  And you can set up your TEE to work however you want your TEE
to work, and you could make it run opcodes already that aren't present yet, or
make it run languages that haven't been forked in yet.  And that way you could,
on mainnet, have wallets that have this TEE set up in the background and check
whether you're able to satisfy these future potential hypothetical changes to
Bitcoin and execute the transaction based on that.

Now, the downside, the very obvious downside to this is you trust the TEE that
it actually does what it's supposed to do; and then, you also trust that the TEE
is going to continue to be available, because if the TEE is gone, your script
will not execute on the chain proper rather.  So, you might set it up with a
fallback so it can be spent after some time with other security assumptions,
just regular Bitcoin Script.  I like the idea as a way out of the box, "Hey, how
could we play around with these things people have been talking about for the
last five years?"

**Mike Schmidt**: It comes down to 'trusted', the name, 'trusted', right?

**Mark Erhardt**: I mean, yeah, sure.  But you're setting up the TEE for your
service and whoever wants to start doing that.  It's pretty obvious you're doing
something else than vanilla Bitcoin there.  So, I very much assume that people
are in the picture of what trust trade-offs they're making there.

**Mike Schmidt**: It reminds me, Murch, of Green wallet, for example, that I
think would co-sign your transaction.  I think it was a 2-of-2.  You had one key
and then Green or Blockstream, or whomever, had the other, and then you would do
a transaction.  But you would have to do some form of 2FA or some other way to
verify that.

**Mark Erhardt**: Yeah, out-of-band authentication too.

**Mike Schmidt**: Yeah, exactly.  So, this is basically out-of-band execution of
Bitcoin Script or other languages, as opposed to just sending a four-digit code,
or whatever it may be.  I think it sounds like the difference here is that the
TEE would be the sole signer, or there some sort of a MuSig here?

**Mark Erhardt**: Yeah, I think it's the sole signer, but I guess you could set
it up in various ways, right?  You could do a MuSig.  I don't know if it's
implemented yet, but yeah, that's a pretty good simile.

_ZEUS v0.11.3 released_

**Mike Schmidt**: Moving on to our monthly segment on Changes to services and
client software, we have a handful this week.  We have Zeus v0.11.3 being
released, which includes improvements to its peer management, LN peers,
improvements to its BOLT12 support, and also additional submarine swap features.

_Rust Utreexo resources_

Rust Utreexo resources.  Abdel was here twice this week.  This is the first one
where he posted this Rust-based resource for Utreexo.  So, there's interactive
educational materials, he's got some WASM bindings, and he's got a website that
puts it all together as well.  So, there's, I think, three different
repositories for this that you can check in to learn more about Utreexo and play
around with it a bit.  So, good to see, along with the Utreexo BIPs.

**Mark Erhardt**: And the Utreexo BIPs getting numbers.

**Mike Schmidt**: Getting numbers, yeah.

**Mark Erhardt**: Yeah, they're #181 through #183.

_Peer-observer tooling and call to action_

**Mike Schmidt**: Peer-observer tooling and call to action.  So, I sort of
mentioned 0xB10C earlier and some of the research he was able to timely put out
to the community on a PR that was open.  Well, he posted a quite comprehensive
blogpost on his blog about the motivation for peer-observer, which is one of his
tools.  He had an overview of the architecture, the code, the supporting
libraries that he uses, and also findings that have come out of this
peer-observer project.  And he didn't push it hard that I've seen, but I did see
that there was a call to action here.  0xB10C wants to build, "A loose,
decentralized group of people who share the interests of monitoring the Bitcoin
Network.  A collective to enable sharing of ideas, discussion, data, tools,
insights, and more".

I wanted to put that along with the post because my feeling is that listeners
and readers of the transcript to this podcast are the type of people who would
think that that would be fun to do and might want to contribute to something
like that.  So, this is a call to you who are listening.  If you think that a
lot of this stuff that 0xB10C has come up with is cool, maybe you don't love
jumping and splunking into C++, but you want to contribute to Bitcoin in some
way, maybe trying to figure out this peer-observer thing would be cool, and
spinning up some of those and logging some of that data and collaborating in a
decentralized way with 0xB10C and some other folks would be a cool way to
contribute.

**Mark Erhardt**: Yeah.  And as a callback to the news items earlier, his data
has been instrumental for us to know what sort of stuff is going on.  He has
been talking about nodes that monitor, like other node operations that monitor
traffic on the Bitcoin Network.  He described forking events; he's found out
that AntPool & Friends is a thing; he has also all the data on the block
reconstruction, and so forth.  This is super-valuable information for Bitcoin
developers to make decisions and be informed about what's going on in the
network.

**Mike Schmidt**: Yeah, so if you see people on social media talking about what
activity is or is not happening on the network, obviously you can look at things
like mempool.space to get some idea, but there's people running several nodes,
different versions, different settings, to see how the network is behaving under
certain situations.  And so, if you don't want to just pontificate on social
media about what's happening on the Bitcoin Network, but you want to be more
rigorous in your data and analysis, maybe check this out.

_Bitcoin Core Kernel-based node announced_

Bitcoin Core Kernel-based node announced.  So, this is Bitcoin backbone, which
was announced.  It's announced as a demonstration of using the Bitcoin Core
Kernel library, also known as the libbitcoinkernel.

**Mark Erhardt**: Not to be confused with the implementation, Libbitcoin.  This
is a library in Bitcoin Core that has a lot of the P2P stuff and the consensus
code.

**Mike Schmidt**: And so, someone took that library and used it as the basis of
building a different node implementation as a demonstration.  I think it's in
Rust.  So, I think it's cool that we're even at the point where this could be
done.  And so, I guess that's a little signpost along the way for folks who are
following the kernel project, that it's at the point where someone can do a demo
node.

_SimplicityHL released_

SimplicityHL released, which is a Rust-like programming language.  I think it's
just higher level, I think at HL, but it compiles down to the lower-level
Simplicity language that folks have maybe heard about, that has been researched
for many years over at Blockstream and was recently activated on the Liquid
Network sidechain.  And there is a Delving thread that jumps into SimplicityHL
and has jumping off points for you to learn more about Simplicity, and whatnot.

**Mark Erhardt**: If you're familiar with miniscript, this is sort of how
miniscript policy can be written to compile down to miniscript.  So, a more
high-level, logical description of what you want, or in a language that's easier
to reason about, that then compiles down to the machine language.

_LSP plugin for BTCPay Server_

**Mike Schmidt**: LSP plugin for BTCPay Server.  So, this is an LSP plugin that
you can put into your BTCPay Server that implements BLIP51, which is the
specification for requesting inbound channels for liquidity.  So now, if you're
running BTCPay Server and you need liquidity, you can request channels using
BLIP51.

_Proto mining hardware and software announced_

Proto mining hardware and software announced.  I think a lot of folks who are
probably listeners of this podcast are already aware of that.  But we did cover
a few years ago that sort of feedback that the Mining Development Kit was
looking for back in the day.  That was in Newsletter #260, just over two years
ago, looking for community feedback on this thing that they were building.  They
wanted to hear the community's needs.  Well, that's been announced.  It's now
not the Mining Development Kit, it's called Proto, and it has mining hardware
and open-source mining software.  And there is an announcement that we link to
in the write-up that we have in the newsletter that will have all the details
for the mining nerds to geek out on.

**Mark Erhardt**: Yeah, and I mean I'm not super-plugged into the mining
community, but my understanding is that miners are very excited for a little
more competition in the hardware market there.

_Oracle resolution demo using CSFS_

**Mike Schmidt**: Seems like it.  Oracle resolution demo using CSFS.  This is
Abdel's second reference in this segment this week.  He posted the demonstration
of an Oracle using CSFS (CHECKSIGFROMSTACK).  He used nostr and MutinyNet to
sign an attestation of a particular event's outcome.

_Relai adds taproot support_

And our last item, Relai adds taproot support.  I remember doing these quite
frequently in years past, but there's still some folks integrating taproot.
This integration is for sending to taproot addresses.  And, Murch, I think I
stole this from When Taproot?  I think I saw it on your repo getting merged, and
I think I added that.

**Mark Erhardt**: Yeah, and to be fair, I think this happened quite a few months
ago, it's just not been reported to us.  People have not been paying as much
attention to the laggards that still don't support sending to taproot addresses.

**Mike Schmidt**: Who's left?

**Mark Erhardt**: Oh, you want me to jump in?

**Mike Schmidt**: Just give me the top couple.

**Mark Erhardt**: The top couple?  Okay.  My understanding is that Binance still
can't send to taproot, Crypto.com, Paxful, PayPal, Robinhood, and Venmo can't
send to taproot addresses.  So, yeah, we mostly keep the biggest names on there
still.  We're not going after every single little one, but is it the four-year
anniversary of taproot is coming up soon?  So, we have had over 50% of outputs
be paid to taproot outputs in blocks.  So, I don't know, maybe you want to send
to it!

**Mike Schmidt**: Well, I don't know how much transaction volume they do
onchain, those services, but they're definitely big names and it would be great
to have them adopt for you.

**Mark Erhardt**: I mean, at some point it is no longer a question of whether
they have already adopted it, but just on them.

_LND v0.19.3-beta_

**Mike Schmidt**: Yeah.  Releases and release candidates.  LND v0.19.3 beta.  We
actually covered the RC for this release pretty well in Podcast #366.  So, I
would refer listeners back to that episode for the details, or of course check
out the release notes.

_Bitcoin Core 29.1rc1_

Bitcoin Core 29.1rc1.  RC2 is actually out now, and I would refer to previous
episodes where we discussed features in this RC with Murch and also with Gloria
in previous podcasts.

**Mark Erhardt**: And it looks like RC2 is probably going to be the final.  So,
29.1 will be released pretty soon probably.

_Core Lightning v25.09rc2_

**Mike Schmidt**: Great.  Core Lightning v25.09rc2.  Well, for this RC, I'm
actually going to refer listeners to an already recorded future episode of our
Optech podcast, where we covered the final version of this release.  That was in
Optech Podcast #369.  You're listening to #368.  And for various technical
issues, we happened to record that episode before this one.  And the RC was
dropped and it's a full release, and we went through some of the features in
#369.

_Bitcoin Core #32896_

Notable code and documentation changes.  Bitcoin Core #32896, which adds v3
transaction creation and wallet support.  Murch?

**Mark Erhardt**: Yeah, so we got TRUC as a paradigm or idea a while back.  TRUC
stands for Topologically Restricted Until Confirmation.  TRUC transactions are
only allowed to have either an unconfirmed parent transaction or one unconfirmed
child transaction, so they at most come in packages of two transactions, and
they are restricted in the size.  So, a parent transaction may only have 10 kvB
(kilo-vbytes) and a child transaction may not have more than 1,000 vB.  So, with
those restrictions, coin selection becomes a little funky because if you have
confirmed funds, they're fine.  You can use any confirmed funds that you want to
spend, but you can only have unconfirmed outputs from a single parent
transaction.  And if you're relying on unconfirmed UTXOs to build a TRUC
transaction, the coin selection, or rather, which coins are even available for
coin selection, are restricted.  And you can't use unconfirmed outputs from
multiple transactions at the same time.

So, what this PR does is it addresses all of these concerns and adds support for
several of the send RPC commands, which is createrawtransaction, createpsbt,
send, sendall and walletcreatefundedpsbt, so that if you're building a
transaction that spends unconfirmed UTXOs, it would manage to keep within the
restrictions of TRUC transactions if you're building a TRUC transaction.  And
you can use these opcodes with the TRUC restriction by parsing the transaction
version in a parameter now, and then it'll hopefully just work.

_Bitcoin Core #33106_

**Mike Schmidt**: Bitcoin Core #33106, we referenced it earlier when we talked
about 0xB10C's chart showing block reconstructions not going well recently.
This PR lowers the default blockmintxfee, incrementalrelayfee and minrelaytxfee.

**Mark Erhardt**: Let me first jump in here already.  Pet peeve of mine is that
all of these variables are named '... fee'.  But really they're referring to
feerates, as you can see from the numbers that are presented afterwards and
their units.  So, blockmintxfee, which should be feerate, is the feerate at
which we consider transactions for the block template.  So, if you are running a
miner that might want to accept lower feerate transactions into their mempool
for building blocks, but for some reason does not want to include them in your
block template, you can use this configuration option to change what you build
your templates from, even if you do allow them into your mempool.  Other than
this, minrelaytxfee is the feerate that you use as the minimum feerate for what
you accept into your mempool; and incrementalrelayfee is the feerate that you
require a replacement to pay more in order to replace the original.  So, these
two used to be even the same configuration option.  They got split a few years
ago because some people might want to set them separately.  But generally, the
minrelaytxfee is what we think of as a minimum cost that someone has to put up
in order to get the data transmitted across the network.  So, if you replace
something with a higher-feerate-paying transaction, this is also what we require
you to pay again in order to replace stuff and transmit data across the whole
network again.

I think early July maybe, don't quote me on this yet, but I think early July, we
started seeing the first significant amount of transactions below the
minrelaytxfee be included in blocks.  And as we discussed earlier already,
people started reporting that the compact block reconstruction rate was
cratering.  We can see that in various other monitors, for example, there's a
university in Germany that has been monitoring block and transaction propagation
on the Bitcoin Network for a long time, and you can just see that the delays by
which blocks get distributed to listening nodes have gone up.  So, with now over
40% of transactions in blocks being below the previous min transaction fee, this
PR changes the minrelaytxfee and the incrementalrelayfee to a 10th of the
previous value, to 0.1 sat/vB, and the default for a blockmintxfee is lowered to
the minimum, because blockmintxfee, I think it was introduced before the
minrelaytxfee and when we still had the coin-age priority.  That's a callback.

So, there was a way of selecting, I think it was a 10th of the block, by
basically assigning nobility to all UTXOs.  You would multiply the amount of
money that was being spent with the number of confirmations that UTXO had.  And
then, you'd fill a 10th of the block just with really old UTXOs and large
amounts.  So, if you had really big UTXOs, they would also have coin-age
priority much quicker than smaller UTXOs, but then after that, also the age
would contribute.  So, that was a really strange, weird way of composing blocks
that was present until, I think, 0.12, which is about ten years ago now.
Anyway, blockmintxfee was introduced so miners could require a minimum fee for
what they put in their block templates and basically not do this.  Oh yeah,
coin-age priority was used to accept zero-fee transactions that had really old
coin-age priority.  So, anyway, this is a little old stuff.

Our idea is, if something gets in your mempool and you expect that to be mined
frequently, you source from your mempool, which is already filtered for what you
expect to be the acceptable transactions.  That's what you use to build your
template.  So, blockmintxfee is essentially no longer a more constrained
variable than the minrelayfee and takes a bit of a secondary role there.
Obviously, you can still configure it differently if that's what you want to do.

**Mike Schmidt**: Murch, can you help me understand why incrementalrelayfee also
changed?  I understand the minrelay motivation per our discussion, but that's
sort of like where you start your bidding for blockspace; whereas incremental
feerate is the granularity at which you can increase the fee.  And it seems like
I don't understand why we want to change the granularity of fee bumping along
with where we start our bids.

**Mark Erhardt**: Right, okay.  So, let's think of a situation.  We have two
nodes, Alice and Bob.  Alice accepts 0.1 sat/vB and has an incrementalrelayfee
of 1 sat/vB, the old incrementalrelayfee.  Bob has not updated yet and both
values are 1 sat/vB.  Now, if someone broadcasts a transaction at 0.1 sat/vB,
Alice accepts it, Bob doesn't, and then they RBF it, and they RBF it to 1.1
sat/vB, because they have to RBF it by at least 1 sat/vB.  Now, Bob will get it
and Alice will get it and everybody has the same mempool again.  Now, if the
sender of the transaction instead bumped it to replace it with a 1 sat/vB
transaction, only Bob would accept it and Alice wouldn't accept the replacement.
So, if minrelaytxfee is the feerate that we expect people to put up in order to
relay data across the network, it makes sense for the increment to also be
lowered to this point.

**Mike Schmidt**: Okay, I see.  And is there a point where that changes?  You
know, obviously we had the feerate spike a few years ago, like we were at 500
sat/vB.  And so now, is it still incremental bumping of 0.1 all the way up to,
let's say, 600 sat/vB?

**Mark Erhardt**: Yeah, the incremental is flat.  I found it extremely strange
that miners actually started accepting low-feerate transactions, because they
sort of had a minimum cost people were willing to pay and until very recently,
more than willing to pay for blockspace.  And not only did they sort of, for a
pittance, remove this very, very stable gentleman's agreement that had been in
place for over a decade; but also, previously when replacements came in,
replacements would increase by 1 sat/vB.  And with the minrelaytxfee being
undermined, also I think it was pretty obvious, especially since those two
values were essentially the same thing before, that the incrementalrelayfee is
also going to change.  So, not only did they reduce the minimum feerate that
people are going to bid on blockspace, they also reduced the spikiness of
mempool peaks, because now people will replace with only bidding 0.1 sat/vB
more.  So, this seems like such a very odd, not considering your own incentives,
that this is a total own goal on miners in my opinion.

**Mike Schmidt**: So, if I'm a user, I have more granularity in my fee bumping
now, if I'm a normal user, I guess I would say.  I can just slowly ratchet up
the feerate and just see what happens, as opposed to bigger jumps, for example.
So, I'm happy.  Now, if we're going from 400 or 500 up 100 sats in a bidding
war, I now have 10 times more relay that is going on on the network then, right?
So, instead of going from 400 to 500 and that being 100 placements, now it's
1,000 replacements, right?  Do I have that right?

**Mark Erhardt**: Yeah, I mean, the question is whether people are going to
replace 10 times more often.  I think people are going to roughly replace as
often as before.  They check back a minute later, "Oh, I've dropped out of the
top 70 of the next block and I want to be in the next block, so I should bump",
and then they bump back to, I don't know, the median of the next block.  So, I
don't think that necessarily the frequency with which replacements will be seen
goes up, but the feerate growth from the replacements will be going down.
Perhaps it's not a full 10th that the peaks have been reduced.  Maybe people are
willing to bid up higher because they're still used to the prior feerate
considerations.  They are still willing to pay a certain amount of money to get
their transaction in, like the value of the fee that they are willing to pay
might still be higher.

So, yeah, we'll have to see how it plays out in detail, but yeah, there's more
granularity.  That's great for users and maybe also to be clear though, so it
looks like maybe there's a few hundred nodes, on the order of 500-ish or so
listening nodes, that currently relay low-feerate transactions.  At least at
some point in the recent history, about 80% of the hashrate was including these
transactions.  So, there's a bit of an odd situation here where people that do
want to send these transactions can very easily peer up with some nodes that
already accept them, and then they will relay fairly reliably among this sort of
backbone in the Bitcoin Network that has found itself.  And they will get to
miners and they will be included in blocks when such feerates make it into
blocks.  But if you're a light client, or if you maybe don't have a ton of
peers, a non-listening node or so, it is much more likely that all of your peers
do not accept these transactions.  So, you might be blackholed.

If you create a transaction, someone experimented recently, I saw this on
Twitter, it took them about 72 hours for their node to peer with another node
that accepted low-feerate transactions, and for it to get in.  And now, of
course, that they have this peer connection, this peer is sending them a lot of
transactions that are now acceptable to both of these nodes.  And when blocks
come in, they might have a functioning compact block reconstruction because they
have all of these missing transactions.  So, this peer will be considered
valuable to the node because it is one of the first nodes that gives them the
new block, right?  So, once the relationship between nodes is formed, he is now
part of the backbone that relays these transactions.  So, what I'm trying to say
is, it might be a little early to set wallet behavior down to lower feerates,
because they might have a bad experience, be eclipsed by peers that don't accept
these transactions, and then their transaction will just linger and not get to
the miners.  But for people that are connected to this small portion of the
whole network that relays the transactions, it works perfectly fine.

So, Bitcoin Core will only change the mempool policy, but the Bitcoin Core
wallet's feerate remains at the 1 sat/vB at this time.  And if you do want to
manually create these transactions, you do have to manually configure your
wallet feerate to be lower so your wallet will build this, accept a feerate
below 1 sat/vB.  So, anyway, it's an interesting phenomenon to watch right now,
especially because the feerate had been stable so long for over ten years.
Obviously, the exchange rate has gone up a magnitude since then.  So, dropping
the cost of a transaction a little bit doesn't seem particularly bad.  There's
this surprising aspect that miners went along with it.  And then, of course, in
the last two years, blockspace was almost entirely demanded.  So, I wasn't
really expecting lower feerates to come into play.  It just seemed unnecessary,
because people were willing to pay more anyway.  Yeah, that's an interesting
thing to look at right now.

_Core Lightning #8467_

**Mike Schmidt**: Yeah, interesting development.  Core Lightning #8467.  This PR
adds BIP353 Human Readable Name support to Core Lightning's (CLN's) xpay
feature.  So, now you can use an email-address-looking identifier, like
mike@bitcoinops.org, to make a BOLT12 offer payment to someone like me!

**Mark Erhardt**: Well, obviously, once these people have set up the information
in their DNS for their domain and provide payment instruction there.

_Core Lightning #8354_

**Mike Schmidt**: Which I haven't, so don't try this.  Core Lightning #8354.
This PR adds events for when a payment or part of a payment begins, and another
event for when that part of the payment ends, along with the success or failure
status with the end notification.  So, these two notifications are now emitted
from CLN's xpay function, and these changes were partially motivated by a CLN
user that suggests, "Xpay needs to tell us about what it is doing so we can set
biases in created layers and tune the pathfinding behavior".

_Eclair #3103_

Eclair #3103 adds support for simple taproot channels, which are channels that
use taproot and MuSig2 in the cooperative case, and has benefits of smaller
sizes and improved privacy.  Included in this PR is also, "Support for dual
funding and splicing has also been implemented through extensions to the
interactive transaction construction protocol".  Seems like a cool PR, important
PR, lots of buzzwords, 'simple taproot channels', 'MuSig2', 'dual-funding',
'splicing', and 'interactive transaction construction'.

_Eclair #3134_

Eclair #3134.  This is a PR titled, "Use CLTV expiry when computing reputation".
This is part of the reputation and HTLC (Hash Time Locked Contract) endorsement
efforts that we've covered this past year, including Eclair research and other
implementations, implementing various versions of this endorsement.  Eclair is
changing their scoring here to get away from their previously fixed multiplier
approach, and they moved instead towards using the CLTV (CHECKLOCKTIMEVERIFY)
expiry.  of the HTLC.  I'm not sure I understood all that, but I will quote from
the PR, "The reason for the fixed multiplier was that an HTLC with the maximum
CLTV delta could stay pending for several orders of magnitude longer than a
regular HTLC, and would have an oversized impact on the reputation.  We mitigate
this by increasing the expected settlement time (from a few seconds to a few
minutes), using more historical data, (increasing the half-life), and counting
on the fact that most HTLCs will have a CLTV expiry a lot lower than the
maximum".

_LDK #3897_

Last PR this week is to LDK, LDK #3897, which is part 3 of LDK's peer storage
project.  Peer storage, as a reminder, is a Lightning feature where a node can
store state data for its peers, and then provide that data back as a backup in
case the data is lost on its peers' side.  This particular PR adds features to
LDK to determine if the user has lost channel state so that LDK can do something
about it.  "The main idea here is just enable node to figure out that it has
lost some data using peer storage backups".  So, it seems like it's just
identifying that state has been lost and not necessarily any mitigations within
this PR.  The fact that this is called part 3 and it references a couple of
future works, maybe the mitigations are done elsewhere in the future.

Murch, anything else on your side?

**Mark Erhardt**: That's all I had.

**Mike Schmidt**: All right.  Well, Murch, I'm sorry to you and our guests that
were unable to complete this recording last week.  I'm glad you were able to
join me today to go through #368 with me this time.  Thank you all for
listening.  We'll hear you next week.

**Mark Erhardt**: Hear you soon.

{% include references.md %}
