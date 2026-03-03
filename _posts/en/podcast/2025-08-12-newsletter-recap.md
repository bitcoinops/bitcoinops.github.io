---
title: 'Bitcoin Optech Newsletter #366 Recap Podcast'
permalink: /en/podcast/2025/08/12/
reference: /en/newsletters/2025/08/08/
name: 2025-08-12-recap
slug: 2025-08-12-recap
type: podcast
layout: podcast-episode
lang: en
---
Gloria Zhao and Mike Schmidt are joined by Tadge Dryja and Anthony Towns to discuss
[Newsletter #366]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-7-13/405609342-44100-2-47f0d9e5e9be6.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #366 Recap.
Today, we're going to be talking about draft BIPs for Utreexo; we're going to
talk about lowering the minimum relay feerate in Bitcoin Core; we're going to
talk about how sharing block templates can cut down on block propagation times
in a mempool-divergent Bitcoin Network; we have a Bitcoin Core PR Review Club on
watch-only functionality in Bitcoin Core's wallet; we have an Optech
recommendation, and also a correction to get to, in addition to our regular
Releases and Notable code segments.  Today, I'm joined by Gloria, who's not only
a guest for today, but also my co-host.  Gloria, say hi.

**Gloria Zhao**: Hi.

**Mike Schmidt**: And we have two news item guests as well.  Tadge has joined us
today.  Hey Tadge.

**Tadge Dryja**: Hello, how's it going?

**Mike Schmidt**: AJ.

**Anthony Towns**: Howdy, how are you doing?

_Draft BIPs proposed for Utreexo_

**Mike Schmidt**: Thank you both for joining us to represent your ideas here.
We're going to jump right into one of those, getting right into the news item,
"Draft BIPs proposed for Utreexo".  Calvin Kim posted links of three BIPs to the
Bitcoin-Dev mailing list.  All three BIPs are around the Utreexo project.  One
is Utreexo's accumulator data structure; the second one is full node validation
using the accumulator rather than a full UTXO set; and the last one is P2P
changes to move extra data that Utreexo needs.  These BIPs were authored by
Calvin, who posted to Bitcoin-Dev Mailing List; also, Davidson, who we had on
recently talking about Floresta on the show; and Tadge, the originator of
Utreexo idea, who has joined us today.  Tadge, it must feel good to get these
BIP drafts out into the world.

**Tadge Dryja**: Yeah, definitely.  It's been a long time and it was great
writing them, because we realized how many things were like, "Oh, wait, we
haven't implemented this.  We've sort of talked about that, but not actually
defined it".  So, I think it's pretty well defined now, although there's
definitely a couple areas where we have implementations and specifications, but
it's like, "That could be better", and maybe we'll revise before it takes over.
But to the extent that there's any consensus-breaking changes, which is not even
really a consensus change, I think it's pretty set now.

**Mike Schmidt**: How would you explain, like maybe give us a two-minute mental
model of the accumulator and how we can get the UTXO commitment down to such a
small size?  I think that's one of the core pieces of this, right?

**Tadge Dryja**: So, if people are familiar with merkle trees, the way a block
header commits to all the transactions in a block is with a merkle tree.  And
you use this very similar technique in Utreexo to say, okay, a node will store a
commitment to all the UTXOs.  And similarly, you can make proofs, right?  Like,
in Bitcoin, we can make what's generally called SPV proofs, proofs that a
transaction is within a block, but we don't really do that much.  I don't know
if there's anything in Bitcoin Core that still does that.  I think it's mostly
removed.  And similarly, in Utreexo, you don't actually make proofs generally.
It's sort of you're storing it because you computed it yourself.  So, one of the
big confusion points is it's not a UTXO set commitment, right?  It's not like
the miners now commit to a UTXO set and you can then sort of verify against
that.  There's no consensus change.  So, it's basically just replacing your
database with a smaller cryptographic accumulator, basically merkle roots, and
then you can verify transactions against that.

**Mike Schmidt**: Okay, that makes sense.  I don't know if you want to break --
are there things that are notable, you think, for the audience within each one
of these BIPs, or maybe things that have significantly changed since you've had
more discussion going around Utreexo?

**Tadge Dryja**: Sure.  I guess, as general motivation, people debate a lot
about the block size and its 4 million weight units, or whatever, and you look
at the blockchain and its 700, 800 GB, or whatever it is now, and that gets a
lot of attention.  But actually, if you're working on this, it's not that
important compared to the UTXO set size, which is much more limiting and slows
things down and more of a concern.  And so, this addresses that, this doesn't
address block size, although you can think of it as a retroactive block size
increase if you want to, if you want to get people riled up, because the extra
messaging is, now you need proofs alongside your historic transactions.  So,
yeah, we split it up into the accumulator design, which is sort of a modified,
more complex merkle tree that doesn't just have one merkle root.  It's got a
bunch of merkle roots, but still is pretty small.  I think it never gets over 1
or 2 kB; and then, the validation, which is saying, okay, if you're a node that
does this, you have just these merkle roots, and someone wants to give you a
transaction or a block and prove that this is valid so that you're doing the
same exact validation as regular, full Bitcoin Core, here's how you do that, how
you verify these proofs, and stuff; and then, the P2P messages, which is one of
the things that took the longest and this is the most complex because there are
so many optimizations we can make.

So, these proofs initially seem pretty big and it potentially about doubles the
size of IBD (Initial Block Download), which seems bad, but you can compact them
quite a bit.  Because if you look at how Bitcoin works today, and this is
totally heuristic, this is not a provable property of the system.  But if you
look at Bitcoin today and you look at like how old UTXOs are when they get
spent, it's a very power-law distribution, where the most common age for UTXO
being spent is zero blocks, that it's created and destroyed in the same block.
And then, the second most common age is one block.  And I think it's like half
of UTXOs that are being spent are spent within six blocks of them being created,
something like that.  And there's also a big spike at six, because everyone, for
whatever reason, waits six blocks and then spends their coins.

So, just because of those properties, which could change in theory, but it's
been pretty consistent for the ten-plus years we're looking at this, if you cash
a little bit, if you say, "Okay, I'm not storing the full UTXO set, I'm not
storing all these things.  But hey, I will store stuff from the last few blocks,
because I know it's so likely to be spent", then your proofs can dramatically
get smaller in size.  And so, there's a bunch of messages to how to deal with
that, like, "Oh, I only need a partial proof for this transaction or this
block", and that gets kind of complicated.  So, we don't deal with compact
blocks right now.  That would be another thing we'd have to, you know, "How
would Utreexo work with compact blocks?"  It would, but that's not defined yet.
We'd have to work on a revision to it later.  So, the complex part ends up being
the P2P stuff, which I think people can identify with.  A lot of people now are
working on P2P messages and mempool stuff, where it hadn't been as looked at
five, ten years ago, and now it's like, "Oh wait, this P2P stuff's kind of
tricky".

**Mike Schmidt**: You talked about P2P, and you maybe touched on this briefly,
but maybe we can double-click into it, the different types of nodes?  And then,
maybe even just clarifying for people which of those, are they all on the
Bitcoin Network?  Are we talking about sending Bitcoin P2P messages?  Are they
all sending Bitcoin P2P messages?  Or is there some sort of side network of
Utreexo nodes that are communicating some side information, or maybe just
elaborate on all that?

**Tadge Dryja**: Yeah, you can think of it as a side network, but it speaks
mainly the same protocol as regular Bitcoin on port 8333 or P2P v2 as well.  But
it is an extra sort of network flag, and actually there's two extra network
flags.  So, you can think of it sort of like, I guess one similar thing was the
block filters, where you can have nodes that say, "Hey, I have I have block
filters and I will send those to you", and you have an extra message for that.
Or like the old, I think it's deprecated, bloom filters, where a node that was
like an SPV node that wasn't a full node, but still spoke the regular Bitcoin
protocol, could connect to a full node and say, "Hey, here's a bloom filter,
please filter blocks when you send them to me".  And that full node would then
take a block, match it against the bloom filter, only send certain transactions.
That worked sort of, but it didn't really work well, and I think people got rid
of it because it was actually a pretty heavy load on the nodes CPU.  So, that's
one of the things we worked on to make sure that the nodes doing the serving,
it's very lightweight for them; and if there's work to be done, have the
validating client do the work.

But yeah, so there's two flags.  One is node Utreexo, where it's got these
proofs.  And basically, that means if you're going to send inv messages, if
you're going to say, "Hey, I have a transaction", and then you give the
transaction to the other person, you need to give these hash-based proofs if
they request it.  And then, the other is, I think it's called 'node Utreexo
archive' or no, did we call it network?  It's weird, because in regular Bitcoin,
node network means you have all the historical blocks.  I don't really know why
the word 'network' means that but it does.  And I don't think we actually called
it 'node Utreexo network', I think we called it 'Utreexo archive', because
that's a better word for it.  But if people will say, "Hey, let's change it to
'network' to be in keeping with the other messages", sure.  And that means you
have proofs for historical blocks.  And those are separate because they're
already sort of separate in regular Bitcoin nodes.  You can have the full UTXO
set and propagate transactions, but not have historic blocks.  And so, we wanted
to keep that separate as well.

It's also separate in that you can have Utreexo proofs for old blocks, like
blocks ten years ago, but not actually have those old blocks.  That's a little
weird, but it actually seems pretty useful, because if you have all these old
proofs, it's getting close to a TB.  And similarly with Bitcoin, if you have all
the archive blocks from 15 years, it's getting close to a TB, 700, 800 GB.  And
so, it's actually, in terms of the code, very easy to separate those things.
They don't need to be stuck together on the same computer, right?  So, if you're
a Utreexo proof node, you can say, "I don't actually have block 300,000, but
I've got the proof for it", and you can go get block 300,000 from someone else
who's running regular, unmodified Bitcoin Core.  And for the validators and for
the servers, it seems really easy to do that.  So, it's like, yeah, why not have
that ability?  It's easy to run both at the same time, on the same computer, but
it's also easy to have them separate.  And that means that if you only have like
a 1-TB SSD and you want to run an archive node and serve blocks or proofs to
someone, you can do that this way.

**Gloria Zhao**: So, if you're a Utreexo node, in IBD you would look for these
archival Utreexo nodes?

**Tadge Dryja**: Yes.

**Gloria Zhao**: And then, when you're out of IBD, you would look for the other
kind that can give you proofs closer to the tip but don't necessarily have the
full data?

**Tadge Dryja**: Yeah.  The normal ones will give you like in-mempool proofs,
and that's fairly small.  And then, the other ones will have the sort of
archive.  It's similar to how when you're doing IBD, I don't actually know if
Core does this, I don't think so, but when you're doing IBD, you don't need to
connect to a normal node.  I mean, I don't think there's any nodes that only
have historic blocks and don't give you invs and new transactions and have a
mempool.  I guess you could do that, but I don't think anyone has.  But yeah,
you can have those two things separate.  And we haven't separated it either.  We
just put the messages in because it was like, in theory, you could do it, you
can have all these different combinations of functionality in a node.  We
haven't coded it though.

**Gloria Zhao**: I guess you could have a blocks-only today that advertises node
network, and then when you're out of IBD, you do a network limited.

**Tadge Dryja**: Yeah, so you can do that.  I mean, I'm not going to program
that, I don't know if anyone else is, but it's like if someone wanted to, you
know…  It's just when we're thinking of the spec, yeah, you need to have an
implementation, but you don't need to have an implementation of all the possible
things you could do with the spec, I guess.  And so, part of it was, it's not
really any more complex to let these sorts of options open.  And I sort of worry
about, having worked on LN ten years ago, there's a lot of things that when you
start making a protocol, you're like, "Oh man, don't screw it up in the
beginning", because then you're sort of stuck with things for a decade.  So,
it's like try to make it pretty extensible, pretty flexible, pretty simple.  And
who knows?  And maybe this doesn't take off and no one really ends up using it.
Hopefully people use it though.  And it probably will be the case that people
use a very strict subset where it's like, every node that's archived also has
both blocks and proofs.  And you'll have both those flags at the same time.
Okay, that's fine.  But if anyone wanted to, the code would probably work with
those separate.

**Gloria Zhao**: I guess you would include this if you find you have a shortage
of archival nodes, right?  Like, I don't know what incentives people have to run
these, you know.  I assume there's some of them.  And I guess because not
everybody needs the full archival stuff, splitting that into two different
services can help make those slots available for people who actually need it.

**Tadge Dryja**: Yeah, I guess.  Yeah.  So, it's just like regular Bitcoin Core
nodes, there's no incentive to have node network and serve blocks.  And it seems
to work.  I don't even know what the metric of like, how do we even detect if
that's becoming scarce, if it's hard to IBD?  I don't know.  But yeah, there's
same idea, you know, there's no incentives and you just hope some people run it.
But in Utreexo, there's similarly this sort of bridge node functionality where
-- sorry, I haven't talked about.

There's regular nodes they can do post-IBD and there's the archive nodes, and
then there's also, not specified in the messages, but you need some nodes that
have the full UTXO set and can sort of translate and say, "I'm going to take
regular mempool transactions, stick a proof onto them and send them over to
Utreexo nodes with the proof".  In theory, if everyone used Utreexo and every
wallet supported it, you wouldn't need this, because every wallet would just
stick a proof onto the transactions it was creating.  But that's almost
certainly never going to happen, and certainly isn't the case now.  And so, you
need these sort of nodes to bridge and put proofs on.  And some people don't
like this, it's like, "Oh, this kind of a weak link".  And so, I don't think
it's that big of a problem, but we recognize that, yeah, if you take out all the
bridge nodes, you do sort of split these two networks, and all the Utreexo nodes
won't be able to validate anymore, right?  They won't validate current
transactions.

So, we made it so that the bridge nodes don't advertise themselves as such,
right?  They're running full validation, full UTXO set Bitcoin nodes at the same
time that they're running the Utreexo accumulator, but they don't tell each
side.  From the Utreexo nodes, they just say, "Yeah, I'm a Utreexo node", and to
other normal nodes, they say, "Yeah, I'm a normal Bitcoin node".  So, that's how
sort of, you only need a few of them.  And then once you have these
proof-carrying transactions, those can propagate among non-bridge nodes that run
Utreexo.

**Mike Schmidt**: AJ, do you have thoughts on Utreexo that you'd like to share?

**Anthony Towns**: So, the bridge nodes need to do a lot more processing than
the archival nodes, right, because they need to update the proofs as the state
gets updated?  Is that still right?

**Tadge Dryja**: Yes.  Well, so they need to do more than the archive because
the archive doesn't even have any currently changing proofs.  But they do the
same amount of CPU work as any validating node, since when a block comes in, you
sort of automatically update all your proofs.  So, bridge node, CPU wise, it's
very simple.  There's a bit more disk I/O, but it's pretty manageable.  So, that
was basically why we used the design we did in Utreexo, is because there's a lot
of cooler accumulator designs and people are like, "Oh, use RSA accumulators",
or this kind of thing.  And the problem there is the bridge nodes updating the
proofs is expensive, whereas with this one, updating the proofs is very cheap.

**Anthony Towns**: And so, you have a bridge node running somewhere now with
what sort of hardware does that run on?

**Tadge Dryja**: Oh, I mean any computer that can run Bitcoin Core now can run
it.  It adds, I don't know, a few percent CPU.  But in the space to have the
full proof thing for a bridge node, it's 20 GB, 30 GB.  You know, there's some
size, and that's 20 GB, 30 GB in more of a LevelDB kind of thing than a flat
files.  So, it's some and it's bigger than the UTXO set, but it's not too bad.
It seems to be on the order of running a current Bitcoin full node.

**Anthony Towns**: So, it increases UTXO size by factor 3 or 4, or something
like that, I guess, or 2 or 3, maybe?

**Tadge Dryja**: Yeah, and that's because we're using LevelDB.  I know there's
better ways to do this that would reduce that overhead to be about double, but
right now, we're using just a regular key-value store for it.  Yeah, so
basically, if you can run Bitcoin Core current full node, not even archive, with
a computer today and it's not really taxing on that computer, you should
definitely be able to run a bridge node.  And that's our goal anyway.

**Anthony Towns**: And the code is currently in Go or Rust or something, right?

**Tadge Dryja**: Yeah, all of the bridge node stuff is in Go and we've been
using btcd.  We could add stuff to Core to have like an extra bridge node
functionality, but the hard part is changing Core to not use LevelDB would be a
big thing.  And so, what we're really interested in now is there's
libbitcoinkernel, which does seem to allow … because we're using btcd, but it
would be great to be able to import Bitcoin's sort of consensus engine and say,
"Hey, here's a block and here's a UTXO viewpoint that we've, you know, that's
the part we've generated.  Tell us if this block is valid or not", and then not
have to use a different implementation for the block validation.  I think that's
something we are working on.

**Anthony Towns**: Sure.  And so, if someone wanted to run this and fire it up
the btcd-based implementation, how long would IBD take on a regular computer?

**Tadge Dryja**: So, if you want to become like a proof node that has proof
archives, it's currently really slow.  We need to make that faster.  It takes a
couple of days.

**Anthony Towns**: How slow is really slow?  Like a week, a month?

**Tadge Dryja**: I think it's like four or five days.  So, significantly slower.
It's the kind of thing where we know how to do it, it's just there's a lot of
interesting algorithmic things here that we could fix.  But a lot of it is just
like, let's get something that works that we can get progress and get people
looking at it.  And then for a Utreexo node that doesn't have archive and
doesn't have all this abridged node, I think it's not too much slower than Core
today.  It's still slower, which is unfortunate, and that's mostly because of
the btcd stuff and signature validation.  So, it'd be great to use something
like libbitcoinkernel, which could potentially speed it up.

We did do this thing, I think it was like two years ago, where we split it up
and we had, I think, four different computers doing IBD at once.  And we sort of
said, "Okay, this computer does blocks zero to 300,000; this one does 300,000 to
500,000", which is something you can do pretty easily with Utreexo because the
entire state fits in one TCP packet.  So, you can sort of send a worker computer
like, "Hey, validate these 1,000 blocks", and then it just gives you a thumbs up
or thumbs down.  And then, I think we did IBD.  It was sort of a stunt, but it's
like, "Oh, we got IBD to work in two hours, cool!"  But yeah, I don't know how
practical it is, but yeah, so the current implementation is still a bit slower.
But it seems that in theory, potentially it could get faster, because you're not
bottlenecked by disk I/O with LevelDB.

**Anthony Towns**: Cool.

**Mike Schmidt**: Tadge, the work is out in the world now.  Any feedback so far
and what are next steps?  What can listeners do who are technically curious,
etc?

**Tadge Dryja**: Yeah, definitely take a look at the specs and you can try
running it.  Definitely don't put all your money on it, it's not robust, but we
definitely want other people to come work on it and look at it.  I think it's a
cool thing as maybe a long-term thing, but it does seem like long term, it's
like, "Well, how big is UTXO set going to grow?  Will this become a problem?"
And it's nice to have this thing where it's like, "Oh, we have a solution and
we're working on it and making it better".  So, hopefully, definitely want
people to take a look and give comments.  And we have a Utreexo call on Jitsi
every Monday morning, US Eastern time, or Monday evening in Asia.  So,
definitely want more people to join and ask questions and try to work on it.

**Mike Schmidt**: Go ahead, Gloria.

**Gloria Zhao**: Is there anything in particular that you're looking for
feedback on, like a particular problem, and you're wondering if there's a
solution or if it's worth solving or what stability things?

**Mike Schmidt**: Yeah, not so much in the specs, although if there's some
things in the specs where people are like, "Hey, this is a bad idea because this
will be annoying for other people", or something, then sure.  In the
implementation, there's definitely a lot of stuff where we're just like, "I
don't know, let's use a hash map and map all these things", and it gets really
ugly and there's all these garbage collectors.  And it's like, we know that's
bad, but it's just like, I don't know, is there a better algorithm for this?
Because we have these big merkle trees and we want some efficient representation
with pointers of partial merkle trees and stuff.  And there's definitely ways to
do it, but anyway, we can do it sort of the easy way now.  So,
implementation-wise, I think there's some interesting, kind of cool algorithm-y
things that people could look at.  So, yeah, that's one thing, if people have
cool ideas.  And it seems like the kind of thing where if you knew what you're
doing and had a good idea for the algorithm, you could be like, "Oh, hey, this
is now 10 times faster".  It's like, "Oh, great".

**Mike Schmidt**: Tadge, we're going to talk about relay and mempool if you want
to hang out, otherwise we appreciate you joining.  All right, cool.

**Tadge Dryja**: I'll stay on.

_Continued discussion about lowering the minimum relay feerate_

**Mike Schmidt**: Second news item, "Continued discussion about lowering the
minimum relay feerate".  Gloria, you posted to Delving discussing lowering the
minimum relay feerate.  Maybe I'll let you frame it up.  What motivated this
discussion and your associated PR to Bitcoin Core to actually make the changes?

**Gloria Zhao**: So, yeah, I think for the past few years, people have asked
about this a lot.  So, the minimum relay feerate hasn't been touched for about
ten years, and people often ask me like, "Oh, can we lower that, because it's
getting kind of expensive".  And I think it never felt like something worth
thinking about, because I think we've got a real problem if fees continue to be
really, really, really low in the long term.  So, I think based on that alone, I
always thought of it as a low-urgency or low-priority policy to look at if we
ever needed to reconsider it.  And I imagine you guys have talked about this on
Optech for the past month or so, but there's a lot of sub-1-sat/vB (satoshi per
virtual byte) transactions that are being relayed and mined.  I was hearing like
80% to 85% of miners from a tweet.  I didn't verify that.  But the thing that
made it very urgent in my mind was seeing 0xB10C's stats on compact block
reconstruction, where I think the numbers were for 70% of blocks, it requires an
extra round trip to get those transactions, and it's 800 kB on average for those
blocks.  And I think we're seeing about 100,000 transactions that are below 1
sat/vB per day or so.  And so, this became a lot more urgent.

I don't know that it's kind of, you know, it's kind of dumb that miners are
doing this, but that was the motivation.  And Robin Linus had opened a PR to
Bitcoin Core, and there were a few things wrong with the request and there
wasn't kind of the standards that we might have for changing a default policy
setting.  So, I kind of took the mic from him, I guess -- sorry, Robin -- and
wanted to open a proper PR with tests and everything, and then start this
mailing-list discussion, because it's something that needs to be discussed.  And
AJ provided some really good framing for how to choose an exact number I think
for PRs like this.  Often the difficult part is like, "All right, we agree, the
current number is bad.  What should the new number be?"  And I don't know if,
AJ, you want to jump in and talk about your calculations for the comparison with
using EC2 bandwidth costs?

**Anthony Towns**: Sure.  When I started reading the PR, my thought was much
more on keeping minor fees at some sort of level that would have a reasonable
relationship to the block reward subsidy, because that's the long-term view.
But looking back on the PRs, particularly the last one that updated the min fee,
Matt's reasoning was much more focused on the effective cost of sending a
transaction, the effective bandwidth cost of sending a transaction across the
network, because that's the cost you're incurring when you relay a transaction.
You send it to one person, they send it to 8 or 100 other people, each of which
send it on to their peers.  And everyone who sends that on is incurring a small
bandwidth cost for their VPS provider or for their home node not being able to
download Netflix movies quite as fast.  And the thing with that cost is it's
distributed amongst everyone that's using Bitcoin, but it's kind of benefiting
the people making the transactions who are only sending a few bytes of data
rather than the MBs that it ends up being when you copy the transactions across
100,000 nodes.

So, back when the feerate was dropped to the 1 sat/vB, the comparison was to EC2
prices and how much it would cost to basically send the same amount of data via,
I guess, relatively expensive EC2 data rates.  And doing the same calculation
now, obviously Bitcoin is much more valuable, so every satoshi is much more
valuable, so that changes the rate a bit.  But the same formula works
independently of that, and it's just a relationship between the price of
Bitcoin, the cost of bandwidth and the number of nodes on the P2P Network.  And
that kind of gives you a rough formula for what a reasonable rate is, that if
someone was able to use sending a transaction to attack the network, then you
don't want that to be cheaper than just attacking the network directly.  So,
that seems like a good metric to me.

**Gloria Zhao**: Yeah.  So, I think we landed on somewhere between, I want to
say 35 and 100 satoshis per kvB being the range that would make sense.  So, just
picked 100 as a nice round number that would be easy to reason about.  And then,
I collected some stats on what kinds of transactions we're seeing that are under
1 sat/vB to see if like 0.1 would capture all of them, or if most of them are
actually even below that, because then this wouldn't really help with compact
block reconstruction.  And 97% of these really low feerate transactions are at
or above 0.1, which is the threshold that we set in the PR.  And then the other
3%, the vast majority are zero.  So, I was kind of guessing that either that's a
package, a TRUC (Topologically Restricted Until Confirmation) package, or the
miner's own transactions.  So, maybe it's actually even higher than 97% that
would be captured by the 0.1 sat/vB new filter.  And we can't lower it to zero
anyway, so it doesn't really make sense to make it go down further to
accommodate those.

I guess there was some discussion on the Delving post.  One of the topics was
like, "Oh, what if we add proof of work to transactions?  Would this address the
same thing that min relay feerate is going for?"  Tadge seems to have some
opinions.  I thought it was not really something you can ask wallets to do, like
signing devices to do.  But I guess since you talked about bridge nodes, maybe
you could have bridge nodes that like add work to things, but why the heck would
they do that?

**Tadge Dryja**: Feels like that's what the fees are there for.  So, you're
paying someone else to do the work, but yeah.

**Anthony Towns**: You could add, with segregated witness transactions, you
could add proof of work to the txid and then sign it afterwards, which only
changes the wtxid and doesn't invalidate the proof of work.  So, that would be
technically possible.  But the problem with it is that proof of work is
centralized amongst people who own ASICs, and so that really advantages a small
number of people who might then want to spam the network or otherwise control
it, as opposed to random people who just want to make transactions.  So, that
seems pretty obnoxious to me.

**Gloria Zhao**: I think it's maybe the kind of idea you come up with when
you're working on the P2P code that does, and you're like, "Oh, the difference
between these transactions and blocks is one of them has work and the other one
doesn't.  We should just have them both require work".

**Anthony Towns**: Yeah.  So, the old thing we used to have was priority
transactions, where you don't have to pay a fee or you don't have to pay as much
fee if you're spending a really old transaction, like if you're spending a
really old UTXO.  So, that was based on Bitcoin Days Destroyed, I think.  So, if
you had 2 bitcoin sitting around for three months, then that's 180 Bitcoin Days
Destroyed when you spend it.  And that's a different sort of proof of work, kind
of like a proof of hodl, I guess, that you could also use, but that doesn't
benefit miners at all.  So, it's not really economically aligned to their
self-interest.  So, we had that functionality and it went away because miners
weren't using it anymore.

**Tadge Dryja**: It was great while it lasted.  You could make really cheap
transactions, but yeah.

**Mike Schmidt**: Gloria, I have a few questions for you.  You mentioned you
can't drop it to zero.  Can you outline why?

**Gloria Zhao**: Well, as AJ talked about, the purpose of this particular policy
is to account for the fact that each node on the network and the network as a
whole incurs a cost for relaying the signed, confirmed transaction.  And let's
say your goal was to make the network waste bandwidth on this, you should incur
a cost that is kind of proportional/more expensive than the cost to the network.
And so, we have this minimum bar where even if there's changes in demand, we
don't relay transactions that are below this threshold, at least by default in
Bitcoin Core.  Because transaction relay has this magnified effect, as AJ was
talking about.  You send it to one node, they send it to all their peers, and
use all their peers.  And so, that's why we multiply the amount of bandwidth, or
the amount of the serialized size of this transaction by something that is a
function of the number of nodes on the network to calculate this bandwidth cost.

**Mike Schmidt**: So, you're Gloria, protector of node runners!

**Gloria Zhao**: Awesome!  Well, I didn't invent this policy, I think Satoshi
did!

**Mike Schmidt**: Would you say that this change is rushed?

**Gloria Zhao**: Yeah, I mean, yes, because it's kind of urgent.  I think people
have pointed this out where they're like, "Oh, why are you rushing changes?
This should be done slow and steady", or whatever.  Well, it has a pretty
significant impact on the network from a block relay perspective.  So, it kind
of jumped up in the priority queue.  I don't think it means we should just
blindly choose numbers, but that's why you start the discussion, right, and
encourage people to give feedback.  Yeah, we can own it.  It's being prioritized
because it's high priority.

**Mike Schmidt**: I'll piggyback on that with my other question, and I have a
few more.  Does the fact that there's so many of these transactions now and
Bitcoin Core is essentially blind to them, does that mean you want to backport
this to previous versions?

**Gloria Zhao**: Yeah, so we had a chat about this at the IRC meeting last week,
because usually policy changes are considered like features.  Are they?  Well,
for the most part, it depends.  Like TRUC, for example, was not backported, it's
more a feature really, or package stuff.  Sorry?

**Anthony Towns**: TRUC is a bit more complicated, and 1p1c
(one-parent-one-child package relay), and stuff.  That's harder to backport.

**Gloria Zhao**: That's true, yeah.  But I guess we can also get to this later
for the 29.1 RC, but this is, I think, problematic enough where you'd consider
it a bug that older nodes are not able to download blocks as quickly as they
could due to current network conditions.  So, yeah.

**Tadge Dryja**: Would you say, like, if someone's running older software, you
can just edit Bitcoin.conf and set your min tx relay.  Would you recommend, or
are you making other changes as well?  Or is it like, "Hey, if you're running
0.27, you can't upgrade for some reason, just reduce the min tx relay fee in
your conf file, and it should fix it mostly"?

**Gloria Zhao**: I think I would recommend that, yeah.

**Anthony Towns**: For what it's worth, I've done that on my node, which I guess
is fairly well known.  I've seen it in some of the nodes that will relay
sub-1-sat/vB things if you're trying to do a transaction and you need to get it
out there.  And looking at my compact block relay logs from that, I'm mostly not
seeing the same 800-kB extra bunch of transaction roundtrip stuff, but I am
still seeing 1, 4, 8, 5 transactions needing to be requested in an extra
roundtrip.  So, even running a pretty well-known node for that isn't getting me
enough connectivity to get all those transactions in my mempool first, to do the
one-shot reconstruction of the compact blocks, which is a bit disappointing.  I
don't think it's taking very long to do the round trip so I don't think it's
having that huge an impact on block relay, but it's getting it down so we're
doing it the way that we expect.  Seems a fair bit better still.

**Gloria Zhao**: So, you're thinking that handful of transactions you're still
missing are just not getting to you before the block because so little of the
network is doing this?

**Anthony Towns**: So, either the transactions are getting to a miner either
directly, or the network's just a little bit not connected well enough or
something, or else maybe people are doing double spend.  So, I'm getting one
version of a transaction, the miner's getting another, and so obviously I'm not
getting the miner's version because I've already got one at the same feerate, so
it doesn't RBF, or something.  I don't know, I haven't looked into it in that
detail.  So, yeah, I'm getting like 1, 16, 2, 1, 14, 1, 1.  And then, on the
blocks that are above 1 sat/vB min fee, I'm just getting them directly with zero
transactions that need to be requested.

**Mike Schmidt**: I have more questions for you, Gloria.  What about setting the
minimum relay fees dynamically?

**Gloria Zhao**: Yeah, I think I saw a comment from David this morning about
that.  There's some concern about this value being basically a conversion rate
between BTC to bandwidth costs.  And I think there were like feelings of
ickiness around having that hard-coded, or something.  And my response was
essentially that there are a lot of hard-coded things.  Well, there are several
hard-coded things in Bitcoin Core that are designed to kind of ground it in
economic reality or state of computer processing reality.  Like the header sync
parameters, we have the script that we run to generate those parameters that are
like, "Oh, we think an attacker can hash headers this quickly, because a current
Ryzen blah, blah, blah processor, we benchmarked it and we can do this many
hashes per second", or something like that.  And that's sort of the name of a
processor.  And obviously that will change over time, but these are things that
change so slowly and gradually that it wouldn't even be nearly as much as our
headers params or the same params or the hard-coded seeds for peers, things like
that.  So, I think it's very normal to do that.

I don't think this is something that should change very often.  I think it
should be grounded in reality, and hopefully change more than every ten years,
hopefully slightly more responsive.  But no, I don't think it's appropriate to
move it up and down.  Like, policy getting stricter, for example, should be a
more involved process because it can cause people with certain applications and
assumptions that they're making when they're broadcasting transactions, it can
make those assumptions break.  And then, suddenly they can't broadcast their
transactions on the network.  So, making things stricter shouldn't really be
done willy-nilly.  And so, yeah, I don't really think we should be turning the
style every release or something.

**Anthony Towns**: I'll add a comment to that, and that is that, I mean we do
have the mempool minfeerate, which is dynamic, based on how much of a backlog of
transactions there are.  So, once the mempool fills up and we start evicting the
cheapest transactions, we'll bump the minimum feerate up to whatever the level
is that we evicted transactions from.  So, the parameter that we've got here is
really doing two things.  It's setting a minimum when there's basically no
competition for block space.  So, before the 100 sat/kvB summer came in, we had
a whole bunch of basically empty blocks, which I mean is fine, but is also not
getting much value from the blocks that are coming through.  And so, if this
setting is blocking that, then maybe it's worth dropping.

In a future where we've got a huge backlog, fees are driving miners' rewards,
then maybe the mempool min fee is enough to keep some lower bound there, and we
don't need this setting at all and could drop it to zero.  I mean, the node
software works if you drop it to zero, you just get random trash that's never
going to be mined in your mempool, so it's not that useful.  And the other thing
is, you could have a setting that does this differently.  So, instead of saying,
"We won't ever do something that costs 0.01 sat/vB", you could say, "We'll allow
some transactions through, but we'll rate-limit them so that there aren't too
many and we don't get a DoS flood of our bandwidth", or whatever.  But that
would be a much more complicated change to the logic that you can't just rush
through in response to, "This is what the network's doing", and we want to make
it work with what people are actually doing on the network.  So, that's my
thoughts anyway.

**Mike Schmidt**: Gloria, what has the feedback been on Delving and on the PR?
I see a lot of ACKs on the PR, for example, but I do see some NACKs.  What's the
steelman objection to this change?  Is it specific to the nuances of your
approach or is it a NACK conceptually?  What's the steelman against this?

**Gloria Zhao**: I don't want to mischaracterize, but I think some of the more
common NACKs that I see are that the really low feerate transactions are spammy
and I guess it's kind of the filtering crowd, the people who want Bitcoin Core's
default policy to be stricter in order to try to limit the transactions that end
up being confirmed on the network.  And we've had this debate many, many times.
Bitcoin Core isn't able to control what gets mined or what ends up onchain.
It's part of the piece of the puzzle in terms of being able to relay
transactions on the network.  But the fact that we see so many transactions that
are filtered by Bitcoin Core's policy, I think is proof that it's not really an
ability that Bitcoin Core has.  So, I think that's the main objection.

I think another one is maybe the formulation of, "Oh, the price has changed and
that has impacted what we think the new numbers should be".  I think maybe
people are object to the idea of price having a role in the protocol, or
something like that.  And I mean, I think because of what this policy is
supposed to do, it's a translation from what resources are consumed by the
network and translating that to a cost to the attacker.  And so, it should be
grounded in reality.

**Tadge Dryja**: Maybe to respond to some of the people, am I correct in saying
that it's not the case that the people like yourself are like, "Oh, we're
reducing it by 10X".  You're not happy about it, right?  Because for me, it's
like, "Oh, yeah, we've got do this", but it's not good.  It's sort of because
long term, it's like, "Yeah, this is real low.  I don't see how this is going to
fund mining after new coins stop coming out", kind of thing; is that your take
on it?

**Gloria Zhao**: Exactly.  Two years ago when people would ask me this and
they're like, "Oh, can we lower it?"  I'm like, "Why would we?  Blocks are
always full and mempools haven't cleared in months, I don't think this is ever
going to be relevant".  And then of course, now it is relevant again.  But I
think that's really not a good thing that we're thinking about what the lower
end of fees should look like.  The problems you'd think we would be solving at
this point, when the subsidy is going down and down, is things like package
relay and making sure fee bumping is efficient, because I really didn't think we
would get to this point where we're like, "Oh, the really cheap ones when
there's no competition, we might as well have some extra sats because otherwise
it's empty space".  This is really bad.  I don't want the network to be full of
these kinds of transactions, but it's similar to data stuffing as well.  It's
not really what we should -- I didn't think we would be here.

**Tadge Dryja**: So, it's sort of like, hopefully we won't really have to think
about this problem long term because there will be much higher fees and stuff,
yeah.

**Gloria Zhao**: Yeah.  I mean, so I guess this is the case.  So, right now with
the package relay rules, unless it's a TRUC transaction, it does have to be
above the minimum relay feerate.  So, this does make package relay maybe
slightly more potent because you can now be bumping something that is 0.1 sat/vB
instead of 1 sat/vB.  So, there's that, but yeah, it's not very exciting.

**Tadge Dryja**: Does it also change the definition of dust in some way?

**Gloria Zhao**: No.  The dust feerate is separate from the minimum relay
feerate.  Yeah, we're actually changing three minimum feerates in Bitcoin Core
that are tied to each other, but dust isn't one of them.  I think dust should go
up over time.

**Anthony Towns**: So, changing the dust, like the dust amount gets baked into
like LN protocols and stuff in that you have to specify in the LN negotiation
that it's an error if you make an output that is below the dust amount.  So,
changing the dust amount, particularly ever moving it up, is pretty scary for
breaking all that sort of software.  And for me, that also makes it harder to
take it down, because if you take it down too far and want to bring it back up,
if anyone's relied on that, then that's a breaking change for them, which is
kind of obnoxious.  So, that's a, "Let's leave this well enough alone as far as
possible", for me.

**Gloria Zhao**: That's true.  Yeah, I think dust is also kind of, it's not
really what's the absolute minimum that a transaction could be, it's more like
what can we reliably say will get consolidated or can get consolidated at some
point.  So, I don't think it's quite the same.

**Anthony Towns**: But of course, if we have Utreexo everywhere, then the dust
amount doesn't matter.  It can just go away entirely, right?

**Gloria Zhao**: There you go.  Yeah.  But it's also like, I don't know, one
thing I was trying to say in the PR originally, and then I ended up deleting it
because I don't know if it made any sense, is at some point, if all of the miner
reward is fees, then there is an amount that will never really make sense.
Like, as a function of the amount that you could transact within a block, dust
is almost, okay, maybe this doesn't make any sense, but you can only have so
many transactions per block and all of the rewards come from fees.  So, it feels
like at that point, dust should go up.  I don't know if this makes any sense,
but anyway.

**Anthony Towns**: That might be the same sort of thing as the mempool min fee
going up, it's just something that people do for their own self-interest rather
than something the code needs to enforce at that point, because if you're paying
lots of fees and Bitcoin's really valuable, you don't want to burn some sats to
something that you're never going to be able to spend.  And you don't need
software to tell you that, you're just a sensible person because that's how you
got into Bitcoin in the first place.  So, maybe that's too optimistic.

**Mike Schmidt**: Very optimistic.  Gloria, anything you want to wrap up with or
calls to action?

**Gloria Zhao**: No, we've noodled on this quite a long time.  We can move on.

_Peer block template sharing to mitigate problems with divergent mempool policies_

**Mike Schmidt**: Great.  Last news item this week, "Peer block template sharing
to mitigate problems with divergent mempool policies".  AJ, you posted to
Delving a write-up about peers sharing block templates.  You pointed out the
trend of diverging mempool policies over time and resulting impact on compact
block relay, and some of the research from 0xB10C.  You then go on to put forth
block template sharing as a potential solution.  What is block template sharing?

**Anthony Towns**: Okay, so when we have the mempool, that is a consistent
collection of transactions that could go in future blocks based on what the
current tip is.  So, we don't have conflicting transactions, obviously we don't
have invalid transactions, we don't have transactions that don't match whatever
our block building policy would be.  And so, that's where you get into the
divergent mental policy.  So, if I were building a block and I didn't want to
include large OP_RETURNS or low-fee things or inscriptions, or whatever policies
I might have for the blocks I build, then that policy then reflects in the
mempool and they're just transactions I won't accept or relay.  But obviously,
what my policy for building blocks is doesn't necessarily match other people's
policy for building blocks.  And so, they may well accept transactions that I
won't.  If they do that and they win a block, then when that block gets relayed,
I won't be able to cheaply reconstruct it because I don't have all the
transactions in it.  And that's how the compact block relay stuff slows down.
And it doesn't slow down that much, it's just, "Here's the block that you need
to do and a hint as to how to reconstruct it".  "Oh, I can't reconstruct it
because I'm missing these transactions.  Can you give me them?"  "Yeah, okay,
I've got the transactions".

But when I'm sitting in the network and I've got whatever my policy is, I'm
connected to a bunch of other nodes that might have other policies.  And if
blocks are coming in from people who share my peers' policies, so if I've got
some Knots neighbors and Ocean wins a block, then there's a fairly good chance
that maybe the Knots nodes that I'm paired with will have a similar policy to
the Ocean miner that built the next block.  Or if I have a Libre node, a Libre
Relay here, then maybe that's got a pretty close-matching policy to what MARA
pool might be mining for their block if that's what comes in next.

So, the idea is that instead of just relaying the transactions and building up a
mempool, also relay what my guess of the next block is.  So, I'll make a guess
of the next block and I'll make a template of that and I'll allow my peers to
request that template and store it.  So, If I've got the Libre Relay peer and I
request their template, then I might get some transactions with large OP_RETURNS
or with really low feerates, or that had been bumped by RBFr instead of RBF that
I would have rejected but they would have accepted.  And that's a relatively
scalable way of doing it, because it's only 4 MB worth of transactions from each
peer, rather than 300 MB of mempool from each peer.

So, the idea is that if we can get an idea of what all my peers' templates would
be doing, then there's a much higher probability, even if mempools' policies are
divergent, that I'll have the transactions for whatever miner builds the next
block, and thus be able to reconstruct the compact block straightaway.  Okay,
did that make any sense, what are the questions from that?

**Mike Schmidt**: I have a question from that.  What happens when I'm a Knots
node runner and I request from a Libre Relay and I get all this stuff.  Do I
say, "Oh, this might actually happen so I might as well retain it this time",
even though I didn't retain it when it was potentially circulating the network
previously; like, is there a specific data structure that this would go into
that would be more liberal then, or how would that work?

**Anthony Towns**: Yeah, exactly.  So, a Knots peer gets a template from a Libre
Relay peer with very different relay policies, and the Libre Relay peer might
have a template that includes a bunch of transactions Knots already rejected.
So, the Knots node might look through those transactions and see if it can now
accept any of them into its mempool, but all these ones it rejected before it
won't accept.  So, it just keeps those around for, say, two to five minutes
until it requests the next new template from that node.  So, the idea is that it
has a separate data structure from the mempool that keeps each of these
templates, but also kind of de-dupes the transactions that are already in the
mempool, so it's not wasting too much space, and de-dupes the transactions that
are in other peers' templates as well.

**Gloria Zhao**: So, when you're constructing the template that you're going to
send to your peers, do you ever use the transactions from your peers' templates
or just what's in your mempool?  I guess it'd be difficult to take other
people's templates.

**Anthony Towns**: So, the idea is you get the template from another person, you
treat that as if they'd relayed the transactions to you, try adding them to your
mempool.  If they go into your mempool, you relay them on to other people in the
normal transaction relay manner.  But the ones that don't make it into your
mempool, you just keep those in reserve in case they're going to come in the
next block anyway.

**Mike Schmidt**: Isn't that what the extra pool is somewhat, or obviously
proposing something bigger than that, and then communication of block templates
is different, but it makes me think of that data structure?

**Anthony Towns**: There's a, there's a thing called vExtra transactions, which
is also used to improve complex block reconstruction.  I think it's 100, or I'm
not sure how many transactions go into it; I think it's 100, but it is just
everything from the mempool.  So, if something gets RBFd, then that'll get stuck
into it, even if it's a low feerate transaction that's not likely to get into a
block.  So, it's good for basically a handful of recent transactions that might
make it into blocks, but it's not spectacularly reliable.  And yeah, in the way
the code's written, it uses the exact same mechanism that that does to access
the transactions from these templates when doing the compact block
reconstruction.

**Gloria Zhao**: How do you store the templates?  Because I imagine we could
repurpose the new orphanage structure to do this so that you could de-duplicate
across peers, you could rate-limit and make sure that like you are keeping --
how do you rate-limit this?

**Anthony Towns**: So, it's rate-limited because a peer requests a template
rather than the templates getting sent.  So, my current settings are, I generate
a template every 30 seconds so that it's relatively recent, but I only request a
template from a peer every two minutes.

**Gloria Zhao**: So, if you get ten requests from different peers, you'd serve
the cached one in any 30-second period?

**Anthony Towns**: Yes

**Gloria Zhao**: I see.

**Anthony Towns**: With a little bit of adjustment for, we have a whole thing
where we don't immediately announce transactions that make it into our mempool
to peers.  And so, I've got the same delay essentially for sending a template
that might include the same transactions to peers who haven't heard it via inv
yet.  But other than that little note, yeah, every 30 seconds they get the most
recent one if they want to request it.

**Gloria Zhao**: Did you consider using minisketch instead of compact blocks?
Because if you're both interested in each other's templates, especially if it's
going to be a similar template, it might be worth the bandwidth savings.

**Anthony Towns**: I spent five seconds thinking about it, but this was inspired
by Greg Sanders' weak block relay thing, where his idea was that when miners get
a high work share that's not quite enough for an actual block, they relay that
as well, and we use that as a cache of what transactions might be mined soon.
And that was via compact blocks, because it's a block.  So, I have not thought
what that would look like in minisketch or what the CPU or bandwidth for it is.
The challenges, or possible drawback, is that you're not necessarily expecting
your templates to align.  They might, in which case it's great, but they might
not.  And then, maybe you're wasting bandwidth or CPU continually deciding, "All
right, these transactions are missing, these ones aren't", but maybe you're
reconciling it to their last template that you had rather than your template,
and that would be okay.  I don't know, interesting.  Do you know what the size
of the reconciliation is?  I guess it's configurable, isn't it?

**Gloria Zhao**: Yeah.  When you request a sketch, you specify the capacity.
So, you could give them your inv send size or you could give them your block
template size, like the number of transactions in your block template, for
example.  Or it's like an upper bound on what you think the difference is going
to look like.

**Anthony Towns**: I'm not sure how you start that off as cleanly as with
compact blocks.  Like, if you connect to a new peer and you don't know what
template to expect, with compact blocks it's just the fixed 20 kB or so message
to get the short IDs of all the transactions.  Yeah, I don't know, that's
probably worth exploring.

**Gloria Zhao**: Can this slow down reconstruction?  Because I think the way we
do reconstruction is we'll calculate the short IDs of all the transactions that
might be in the compact block, and then we see which matches.  So, if we have a
lot more transactions that we might potentially be looking at, can this slow
that down at all?

**Anthony Towns**: Yeah.  So, we iterate through the entire mempool to check,
calculating the short IDs of everything in the mempool and matching.  And having
done that, we then do the same thing through the extra transactions, which would
be where these templates fit in.  And compared to the size of the mempool, I
think a full mempool is more of a hit on number of transactions you're
calculating things for.  And the other thing is that you're only ever doing the
calculation over the wtxid, not the full transaction, so that makes things a
little bit quicker than it might otherwise seem.

**Gloria Zhao**: Would we request just from our outbounds, I guess?

**Anthony Towns**: That's all I do at the moment, because if every outbound is
attacking you and giving you 4 MB templates of garbage, then that's 24 MB, 32 MB
of extra memory that you're sitting on.  But if you were doing that for every
inbound as well, that's like 400 MB of data potentially.  And so, I've had some
thoughts about just keeping the top of the templates for those and having some
sort of memory bound for it, so that if everyone's giving the same template,
then you can keep all of it because you're de-duping and kind of aggregating the
cost across all the peers that are giving you the template.  And if someone's
giving you a completely different prediction, then maybe you keep the top 30 kB
of it, or something, rather than the top MB of it.  But that got too complicated
to implement for a prototype.  So, it's just outbounds for now.

**Gloria Zhao**: Makes sense.

**Mike Schmidt**: You mentioned Greg's discussion recently on weak blocks.  Can
you explain why I would want to get an indication from just a random peer of
what they would build, as opposed to somebody who's putting proof of work behind
it and might actually come up with a block, what they see as a candidate block?

**Anthony Towns**: Oh, so the drawback for me for weak blocks is twofold.  One
is that the obviously weak blocks, you're going to get more weak blocks if you
have more hash power.  So, that's going to be biased to the pools that have the
most hash power.  And that means that if a small pool is doing some weird
transaction stuff, then their blocks are going to be slower because they're not
likely to get a weak block with the transactions that they're going to include.
And I want an approach that's effective for low-hashrate pools or low-hashrate
miners, rather than just advantaging high-hashrate miners.  And this isn't
perfect for that because it's advantaging the policies that are most popular on
the network.  So, if you have a moderate hashrate and are getting blocks, but
barely anyone on the network is sharing your node policy, then maybe no one's
getting to see your templates or similar templates to what you're producing.
And this isn't helping there, but this is the best I've come up with so far for
that.

The other disadvantage with weak blocks is that they just keep coming through in
time.  So, if you've got ten minutes between actual blocks, and you have ten
weak blocks, like your target is ten weak blocks per block, then odds-on you'll
get a weak block nine minutes before the block and eight minutes before the
block and seven minutes before the block, except much more randomly than that.
And that weak block that's nine minutes old isn't really, is probably not doing
that much good for your prediction of what's going to come right now.  And also,
weak blocks are likely to cluster and have long lags between them the same way
that regular blocks do, which I mean is better than nothing but doesn't seem
ideal either.  And if you're not doing proof of work, then you can just get them
on a timed basis, which as long as you have some way of not getting a billion
blocks from everyone on the network, which is why it's only doing for peers and
you're not relaying these on further, then having something that is close to now
that miners are likely to actually be working on seems better.

**Mike Schmidt**: That makes a lot of sense.  Thanks, AJ.

**Anthony Towns**: Okay.  So, the other two things for it is that it also makes
it easier to populate your mempool when you just bring up a node, either because
you've been doing IBD or because your node was down for a couple of days.  So,
currently if you do that, you'll see new transactions that come in, but you
won't see transactions that have been sitting in the mempool for an hour.
Whereas with this, you'll get those sent through on your template, you can add
them to your mempool and you're up and running straight away.  So, I think
that's a kind of fun win, which both gets you compact block stuff working as
well.  But as well as that, if you're running a mining pool or a DATUM or a
Stratum v2 node, it means you can start generating proper templates yourself
that are realistic and not missing transactions and have a competitive feerate
straightaway.  And I've forgotten whatever the other thing was.

**Mike Schmidt**: Gloria, any other questions for AJ?

**Gloria Zhao**: Not really.  I think I'll look at the implementation, it's
cool.

**Anthony Towns**: Yeah, so I've got a more limited implementation, which just
generates and serves templates, rather than requesting and making use of them,
which I think would be interesting to possibly get in the next release that's
coming up way too soon, because that would allow a bit more experimentation on
policies for getting templates.  So, I've got a write up of that, which I'll
post pretty soon.

**Gloria Zhao**: Well, by next release, you mean 31 or 30?

**Anthony Towns**: 30, yeah.

**Gloria Zhao**: I have seven days!

**Anthony Towns**: Yeah.  I've got a BIP write-up now and a PR, which I'll get
out.

**Mike Schmidt**: Oh, wow, breaking news!  If somebody who's listening wants to
see your proof of concept or maybe just run it and get some logs and data, play
around with it, where should they go to find that?

**Anthony Towns**: So, you look at the Optech Newsletter, there should be a link
to the Delving post, which has got links to the prototype code that's currently
there.  You'll need to run two nodes to get any use of that, because you need
one that provides a template and one that requests a template to see what's
going on.  Because there's not anything on the network doing this, your node
that provides the template will need to be running a little while to actually
have a mempool that's got transactions in it to go into the template.  But
otherwise, yeah, that works straightaway.

**Mike Schmidt**: Cool.  All right, AJ, thanks for joining us.  We appreciate
your time.

**Anthony Towns**: You're welcome.

_Add exportwatchonlywallet RPC to export a watchonly version of a wallet_

**Mike Schmidt**: Moving on to our monthly segment on a Bitcoin Core PR Review
Club.  This month, we highlighted the, "Add exportwatchonlywallet RPC", which is
an RPC that exports a watch-only version of a wallet file with descriptors.
Gloria, I don't think you hosted this particular Review Club, but I know you
were involved.  Maybe you want to help elaborate on this.  At first, I thought
it seemed like a fairly straightforward from the explanation PR, but there's
actually quite a lot going on here in the Review Club.

**Gloria Zhao**: Yeah, it turns out that a wallet's a lot more than a bag of
keys or a bag of descriptors.  I think maybe there was a version of this that
existed for legacy wallets, like non-descriptor wallets in the past, but
definitely not anymore.  The use case is you want to export your watch-only
wallet or you want to export your wallet in a watch-only format so that you
would be able to see all your transactions and calculate your balance and look
at your addresses, and things like that, somewhere else that doesn't have your
keys.  But the wallet file includes a lot more than just those addresses and
descriptors.  You have address labels, you have certain settings on the wallet
that can actually impact what the calculation of your available balance is, such
as avoid reuse.  So, even though you're not going to be constructing or signing
transactions on this watch-only wallet that you import, if you have an output
marked as avoid reuse, for example, because you already spent from that address
and you don't want to spend from it again to reveal links between your coins,
then that is deducted from your available balance.  So, there's different
balances that will show when you ask your wallet, "How much money do I have?"
But it will show up in some of them, but not others.

So, as an example, avoid reuse is an example of a wallet setting that you do
want to export along with all the other information, in order to have the exact
same wallet if you are to import this or restore this wallet file elsewhere.
So, yeah, that's I guess an example of kind of the edge cases and more
complicated details for capturing everything in this exportwatchonlywallet RPC.

**Mike Schmidt**: How would you do it before?  Would you get a full export and
have to kind of parse through there to figure out what to take out to send to
watch only, and then that's obviously error-prone if you include additional
information in there?

**Gloria Zhao**: Yeah, yeah, good question.  I think you could export all the
descriptors.  But if you wanted all this metadata, like the labels and the flags
and stuff, you would have to manually do that.  I want to say there was a way to
get all those settings, so maybe you could write a script for it, but that's
definitely not as good as just calling a couple of RPCs.

**Mike Schmidt**: Excellent.

**Gloria Zhao**: Yeah, I don't know all the details because I didn't host this
one.

**Mike Schmidt**: Well, I am checking now.  It looks like the PR is still open.
So, if folks are curious about wallet stuff, we didn't touch on it, but there's
a series of questions that we have in the newsletter write-up that get quite
technical, in addition to the PR Review Club normally very robust write-up as
well.  So, if wallet is something that you're interested in and approachable to
you, you should jump in and dig into the details there.

**Gloria Zhao**: Yeah, it will help you appreciate how complicated it is.

_Optech recommends_

**Mike Schmidt**: We actually had a segment that we haven't had in a while, a
short segment called Optech recommends, in the newsletter this week.  This was a
call out to the Bitcoin++ Insider publication.  They've been publishing a few
different series on their Substack recently, including a segment called, "Last
Week in Bitcoin" and another segment called, "This Week in Bitcoin Core" that we
mentioned in the newsletter this week, which may be of interest to Optech
readers and Optech Recap enjoyers.  They also have a technical take series and
recent things there include SPHINCS+, which is some of the quantum-resistant
signature stuff, Cashu, F2Pool and Marathon mining taproot annexes, to give you
a flavor of that series.  And then, there's also a Scaling Bitcoin series that
had recent publications on BitVM-based bridges, private Bitcoin payments, and
statechains.  So, if that kind of stuff is interesting to you, check out
Bitcoin++ Insider.

_LND v0.19.3-beta.rc1_

Releases and release candidates.  We have three this week.  LND 0.19.3-beta.rc1,
this contains a handful of bug fixes.  One is around gossip, which we actually
get to in the Notable code segment.  That's actually the related fix, so I'll
save that one.  And there's some other fixes.  There's changes in the gossip
message rates, also related to what we've talked about previously and we'll talk
about later for LND PR in the Notable code segment; and then, there's some
changes around sweeping anchors to prevent pinning.  So, this is just a release
candidate.  So, please check it out, test it out, provide feedback to that team.

_BTCPay Server 2.2.0_

BTCPay Server 2.2.0 adds support for wallet policies and miniscript, and also
adds feerate and fee information in a bunch of new areas of the user interface
for BTCPay Server.  Obviously, the normal features and improvements as well as
bug fixes are in there as well, but those are the ones that I thought were most
applicable to Optech readers.

_Bitcoin Core 29.1rc1_

And we have Bitcoin Core 29.1rc1.  I think it was last week Murch and I pulled
out a few things that we thought were interesting but, Gloria, as a maintainer,
are there particular things that you'd like to highlight for the audience that
will be in there and that they should be aware of?

**Gloria Zhao**: Fairly normal, I think.  There's some fixes for 32-bit systems
and some CMake build things that got fixed, since this was the first release
that was built with CMake.  I guess the biggest thing is the, what's it called,
BIP54, is it?  The very large legacy sigop transactions are non-standard, and
that's part of the consensus cleanup.  So, if you imagine that consensus soft
fork activating like two years from now, or something, and you hadn't updated to
32, or whatever it is.  And so, these transactions with more than 2,500 legacy
sigops are now consensus-invalid.  This 29.1 will at least not be accepting them
into mempool.  So, if I guess a miner is running 29.1, when that soft fork
activates, they're not going to be publishing blocks with invalid transactions.
And if you're non-mining, you're not going to be accepting these transactions
that are newly consensus-invalid.  And so, that's a 'forward compatible in case
of soft fork' change that is more significant in the 29.1 list?

**Mike Schmidt**: Yeah, I think that was Bitcoin Core #32521, and you'll have to
just search that on Google with site:bitcoinops.org.  But we did talk about that
in the newsletter and the podcast as well as the dbcache values for 32-bit
operating systems and why it's a good idea to cap some of those things.

**Gloria Zhao**: Yeah, and 2,500 legacy sigops is pretty rare.  I think Antoine
had an analyst post that listed all of them, and there's maybe a dozen or so in
the last 15 years.

**Mike Schmidt**: I think the word I've seen is 'pathological', you have to be
wanting to mess around with this.

**Gloria Zhao**: Yeah.  It's it's probably not going to be a meaningful change
in practice, but it's there for a good reason.

_Bitcoin Core #32941_

**Mike Schmidt**: Notable code and documentation changes.  Bitcoin Core #32941,
"Orphanage revamp cleanups".  Gloria, this is your PR.  What's the latest in the
fortification of the orphanage?

**Gloria Zhao**: Well, this is the last PR in that project, at least for a
while.  It's mostly follow-ups to the last one, which we talked about maybe two
or three Optech Recaps ago, newsletters ago.  Yeah, mostly little fix-ups.  One
of them was to have the orphanage automatically trim itself so that you could
have a check that it's never oversized, and that just makes all the tests a bit
stronger.  But it's not a behavior change in practice.  We were trimming it,
it's just that the caller was trimming it instead of just adding things to it.
So, yeah, orphanage is in better shape than it was before.  I think I still
remember AJ moving it to its own module, like five years ago?  I feel like
orphanage has changed so much.  I think it was in the original Satoshi client as
this map that had everything in it, no size limit, that kind of thing.  And now
it's quite a bit more robust.

So, now we're pretty much done with most of the P2P stuff for package relay, and
we still need to accept the package validation stuff to have arbitrary packages
and to handle package RBF, and a lot of that's dependent on cluster mempool.
And then afterwards, it's pretty much just adding support for the package relay
messages, because now we see an orphan, we can put it in orphanage and request
the package information, and have some confidence that it's not going to fall
out of the orphanage as soon as we get the list of transactions we need to
download.  And we have all of the efforts to make sure we try to resolve these
orphans.  So, we ask all of the peers that we can ask for the package from.  So,
I think we've covered almost all of the more difficult pieces of the P2P logic
for package relay, and we just need to stitch it all together, after we figure
out package RBF, of course, which is a very easy problem.

_Bitcoin Core #31385_

**Mike Schmidt**: Well, speaking of packages, the next PR this week, Bitcoin
Core #31385, relaxes some of the validation rules around packages of
transactions.  Gloria, this is also your PR.  Maybe, can you remind us of the
current rules around packages and why we might want to change those at all?

**Gloria Zhao**: Sure.  So, the current requirement for the submitpackage RPC,
current as in, in all of the releases that are out, package has to be filed with
unconfirmed parents.  So, it has to be child-plus-parents shaped.  There can't
be any transactions that aren't a parent of the last transaction.  They can be
parents of each other as long as they're also direct parents of the last
transaction.  And the part that's removed in this PR is that all of the
unconfirmed parents have to be present, which is in hindsight a silly rule.  But
basically, now, if you have a package where some of the parents are already in
the mempool, it won't get rejected if you leave those out, which makes perfect
sense.  So, now you can actually, in the P2P code, which is they just have to be
1p1c, if you have a 1p1c that attaches to other things, you can broadcast that.
So, it does make a difference, but it's just removing a thing that was in the
way before.  It didn't really do much.

**Mike Schmidt**: As we're going through these Bitcoin Core PRs, maybe it's a
good time to remind listeners of the release schedule and whether these PRs are
in the next version or is that time passed; maybe just some people know if
they're going to get this soon maybe or not.

**Gloria Zhao**: These will be in the next version, unless we revert them for
whatever reason.  All the features that are merged from now until next week will
make it in.  I think we do branch off like a month from now and then it'll come
out in October-ish.

_Bitcoin Core #31244_

**Mike Schmidt**: Great.  Bitcoin Core #31244.  This is a PR that implements the
parsing of BIP390 MuSig descriptors.  It's actually part of Bitcoin Core's
MuSig2 efforts that has the tracking issue -- I love tracking issues -- #31246.
So, if you're curious about the broader MuSig2 efforts in Bitcoin Core, check
out #31246.  And this PR is actually split off from a bigger PR titled, "Be able
to receive and spend inputs involving MuSig2 aggregate keys".  Gloria, did you
have more on this one?

**Gloria Zhao**: Sure.  Yeah, I think we can now receive but not send MuSig.
So, if you generated a MuSig address with some friends and you had this
aggregated public key and you guys received money to it, you would now be able
to import that as a descriptor and see that you've received money, but you
wouldn't be able to spend it yet.  So, the aggregate key looks exactly like any
other single-sig taproot key, and the signature also looks just like any
single-sig schnorr signature, and you can import it into your wallet, but you
won't be able to spend it.  You don't have the ability to create the signatures
to aggregate, or I think you also don't have the ability to generate the nonces
and stuff to create the partial, yeah.

**Anthony Towns**: This was just the parsing, not the sending or the receiving,
I thought.  I thought those were in the PR that it was split off from.

**Gloria Zhao**: So, when you import it, does the wallet not rescan to see what
has been received?

**Anthony Towns**: I got the impression this was just the parsing, not even the
importing.  I might be wrong.

**Gloria Zhao**: It might be, I don't know.

**Mike Schmidt**: It's titled, "Parsing", and it's split off from the
send/receive.  So, maybe it's just strictly the parsing piece.  If only there
was a tracking issue!

**Gloria Zhao**: When I messaged achow, she said we can receive but not send.
So, that's going to throw her under the bus!

**Mike Schmidt**: All right.

**Gloria Zhao**: Maybe it's somewhat nuanced, like you can see that you received
stuff, but I don't know where you draw the line.

**Anthony Towns**: If you can add it to the wallet, then you can track it.

**Gloria Zhao**: I imagine if you can parse, then you can import, right, the
descriptor?  I said, "So, we could import a descriptor for our MuSig and see
that we received BTC to it?"  And she said, "Yes".

_Bitcoin Core #30635_

**Mike Schmidt**: Okay, that's pretty authoritative.  Bitcoin Core #30635.  This
unhides three RPCs, waitfornewblock, waitforblock, waitforblockheight.  What do
these do and why were they hidden before?

**Gloria Zhao**: Things are usually hidden because we don't expect anyone to be
interested in them, but we made them so that we can write tests.  It's pretty
useful to be able to wait for the next block to come in, right?  You write a
test that's like, "Oh, you broadcast these, you have this miner do this", and
then you assert that the node does this, but only after receiving the block and
processing it.  So, it's pretty useful for testing.  But I imagine in the real
world, you have a lot of other options for encoding something that is triggered
by a new block.  But yeah, I can't really speak to what people were thinking.
But yeah, I guess now they are unhidden.  I mean, you were always able to use
them, it's just that they weren't advertised to the users.

**Mike Schmidt**: Yeah, it's not listed in the help.  So, that's the definition,
I guess, of hidden.  And it sounds like, I mean, yeah, it's just for testing,
right?  I don't know of any use cases that come to mind for waiting.

**Gloria Zhao**: Maybe if you're a miner and want to wait for your own block?

**Anthony Towns**: Well, if you get a new block in, you want to immediately get
a new template to work on probably.  And so, this would give you that indication
that a new block's come in without having to call for it. I think you can use
ZMQ for it.

**Mike Schmidt**: Yeah, that's what I was thinking.

**Gloria Zhao**: Right, so you're almost getting a notification instead of
pulling.  Yeah, that's pretty good.  And then, there's the adding the argument
for the tip.  So, I guess, I don't know if this is useful in real life, unless
you're expecting multiple blocks at a time.  But in tests, for example, I
think...

**Anthony Towns**: I think if you do the request immediately after a block's
come in because you're just unlucky, then you won't see the notification that
the block has just come in.

**Gloria Zhao**: Right, okay.  So, if you parse in a current tip and it's like,
"Oh, I already know about that.  Here you go", you would just…

**Anthony Towns**: You'd Immediately get a response to say, "No, that's not the
current tip".

**Gloria Zhao**: Makes sense.  Cool.

_Bitcoin Core #28944_

**Mike Schmidt**: Bitcoin Core #28944, adding anti-fee sniping to send and
sendall RPCs.  Gloria, I've got two questions here.  One, what is this anti-fee
sniping?  And second, I thought Bitcoin Core had anti-fee sniping for like a
decade?

**Gloria Zhao**: Yeah, well fee sniping I think is mostly a very
far-into-the-future concern, where fees are such a large part of the block
reward that hopefully you might run into a situation where the miner is deciding
what they should mine and they see that there's not a lot of transactions, ie
transaction fees available to gain as a result of building on top of the current
tip.  But if they reorg and remine some of the past transactions, then that
multiplied by the risk or probability of them not actually having the rest of
the network build on this block that they built as a reorg, they somehow
calculate that it would be worth it for them to actually not extend the current
tip, but to try to remine a previous one.  So, that's very scary, and there are
a few mitigations.  I think the Optech Topics page has an excellent summary of
the problem and the proposed solutions.  And something that Bitcoin Core has had
for a long time is anti-fee sniping and wallet/RPC stuff, where you just set the
locktime of the transaction so that it only becomes consensus-valid at this
block height.  So, if you were to reorg back, it would not be valid anymore.

**Mike Schmidt**: So, the juicy transaction fees are safe from reorging miners,
especially in a future state where there's higher incentive to do that, because
the subsidy's out?

**Gloria Zhao**: Correct, yeah.  I think this has existed for a while, but maybe
just not for these two particular RPCs, send and sendall.

_Eclair #3133_

**Mike Schmidt**: Okay.  My memory didn't fail me.  This has existed, just not
for those RPCs, okay.  Eclair #3133 adds to Eclair's support of peer reputation
by adding reputation for outgoing peers.  A couple of weeks ago, we covered a
similar PR from Eclair that added reputation-tracking-related metrics for
incoming peers.  The idea here is to use reputation of a node's neighbors to
decide if an HTLC (Hash Time Locked Contract) should be relayed or not, and it's
part of a broader set of mitigations against channel-jamming attacks, where
attackers can attempt to either take up all the HTLC slots or all of a channel's
liquidity.  It's basically a type of DoS attack.  So, we've gone through a lot
of research with folks on anti-channel jamming ideas.  This peer reputation is
one of them, and Eclair has implemented both ends of that now.  And as of this
PR, Eclair now considers reputation in both directions when forwarding an HTLC.
But at this point, and I think this is planned in the future potentially,
there's no penalties implemented yet.  It's just merely collecting data at this
point.

_LND #10097_

LND #10097, a short tangent here.  Matt Morehouse joined us in Podcast #364,
where we discussed a DoS vulnerability that he had found in LND.  And that DoS
vulnerability was specifically around LND's handling of gossip.  So, recently,
over some period of time after that migration, there's been continued rework of
LND's gossip-handling architecture.  And it appears that this PR is part of that
ongoing re-architecting work, not specifically for that bug, but as a result of
re-architecting the gossip, there's been other challenges that have come up and
this PR attempts to address some of that.

It adds an asynchronous processing queue for these range filters for gossip,
which were the problem in that bug we discussed a couple of weeks ago with Matt.
It can prevent blocking issues and also improve performance, especially under
heavier load.  And then also, when the queue is full now, they drop messages,
whereas before they would just try to execute that whole thing, which was the
DoS vulnerability.  This PR also provides an option to limit how many of these
gossip filter request operations can be running simultaneously.  So, another DoS
mitigation and a lever that you can play with.  And one thing that I saw in the
PR and in the files was actually this gossip rate-limiting markdown file that
details all of LND's gossip-handling approach, the different options that node
operators can use to modify those gossiping behaviors.  Quite a robust document
that's included as part of this PR.

_LND #9625_

LND #9625 adds an RPC to delete an invoice that had previously been canceled
from LND's database.  The main use case here would seem to be just cleaning up
the database of unneeded entries.  And this was possible to delete these
canceled invoices previously, but it was less straightforward than this new RPC,
required more work, and may have not fit in the existing workflows for LND's
users and developers very well.

_Rust Bitcoin #4730_

Rust Bitcoin #4730 adds the Alert Bitcoin P2P message.  Gloria, blast from the
past, the P2P alert message type has been deprecated for some time.  Maybe for
listeners, in the early years of Bitcoin Core, or maybe just Bitcoin development
at that time, Satoshi for example had the keys to be able to send alert messages
to nodes, maybe a notice of a critical bug or a security incident or urgent
software updates, etc.  But in 2016, I believe it was, Bitcoin Core developers
decided, "Hey, that's a bad idea.  You shouldn't have a decentralized system
that has privileged users able to send alert messages on the Bitcoin Network",
so it was removed.  But in the interest of thoroughness, Rust Bitcoin has
implemented this Alert P2P message in this PR in the form of sending the final
alert message that was sent from that key, which is, "Urgent alert key
compromised, upgrade required", I believe.  Yeah, I hope I got all that right.
But that was like a little bit of Bitcoin lore there.

**Gloria Zhao**: Yeah, wait, so we still have that, right?  We still send the
final alert just in case there's really old nodes and we need to tell them that
the alert queue is compromised.  Like, I think this is still in Core and we
can't remove it.

**Anthony Towns**: It's still there as long as the version of the node we
connect to is old enough that it hasn't dropped support for it.

**Gloria Zhao**: Right.  And we wouldn't ever remove it from the codebase just
in case, right?

**Anthony Towns**: I mean, it's one, two, three, four lines of code, or five
lines if you count the comment.

**Gloria Zhao**: Yeah.

**Mike Schmidt**: So, deprecated in terms of new uses, but retains that final
message, which is what Rust Bitcoin has done here as well.

**Anthony Towns**: Yeah, they have a lot more lines of code for it.

_BLIPs #55_

**Mike Schmidt**: Well, they're apparently thorough.  Last PR this week, BLIPs
#55, adds BLIP55, which is also known as LSPS5, Lightning Service Provider
Specification 5.  This is the specification that we spoke about last week when
LDK implemented BLIP55.  But as a reminder, it's a way for an LSP server to set
up to be able to send push notifications to a client device, usually a mobile
device, when something happens, for example receiving a payment, and there's a
mobile LN wallet that isn't always online.  You can sort of register a webhook,
and the LSP will send a message to that webhook which, in the case of a mobile
device, might do a push alert and let somebody know that they got a payment,
that the LSP's changed the liquidity, or an onion message, or some other such
message as well.  So, LSPS5/BLIPs #55 is the specification for that sort of
webhook.

_Correction_

And we have a correction in addition to an Optech recommends, we also have a
rare correction as well.  We noted that in last week's newsletter, when we were
talking about BIP360, which is the pay to quantum-resistant hash, we were
referencing that as making the change that Tim Ruffing had outlined in his
recent paper.  But there is a difference there.  I think Tim Ruffing was
outlining that it could just disable keypath spends in existing taproot
addresses, whereas BIP360 actually has a new taproot-based output type that also
removes keypath, but it would be actually a different type of address.  And
that's what this correction gets into.  AJ, you may have more to piggyback on
that.  AJ doesn't.  Okay, good, that means I didn't say anything too wrong.
Gloria, anything that you want to add to that?  All right.

Well, AJ, thanks for joining, Tadge had to drop off.  AJ, appreciate you hanging
on at God knows what time.  Gloria, thank you for jumping on and co-hosting.

**Gloria Zhao**: My pleasure.  Hope I was a satisfactory stand-in for Murch.

**Mike Schmidt**: It was great.  I mean, we love Murch, but couldn't have asked
for a better week for Murch to take off since you participated in every segment
of the newsletter!  We appreciate it.  And thank you all for listening.  Cheers.

**Gloria Zhao**: Thank you.

**Anthony Towns**: Thanks, Mike.

{% include references.md %}
