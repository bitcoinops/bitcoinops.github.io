---
title: 'Bitcoin Optech Newsletter #349 Recap Podcast'
permalink: /en/podcast/2025/04/15/
reference: /en/newsletters/2025/04/11/
name: 2025-04-15-recap
slug: 2025-04-15-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Dave Harding are joined by Sebastian Falbesoner, Ruben
Somsen, and Abubakar Sadiq Ismail to discuss [Newsletter
#349]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-3-22/398820649-44100-2-fc9ab822cafb8.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mark Erhardt**: Hi, this is the Bitcoin Optech Recap for Newsletter #349.  As
you can hear, I'm not Mike Schmidt this morning.  I'm Murch and I'm hosting
today with Dave Harding.

**Dave Harding**: I'm Dave Harding, I'm co-author of the Optech Newsletter and
the third edition of Mastering Bitcoin.

**Mark Erhardt**: I'm also joined by Ruben Somsen.

**Ruben Somsen**: Hi guys.

**Mark Erhardt**: And Sebastian Falbesoner.

**Sebastian Falbesoner**: Hello, I work on Bitcoin stuff and I'm founded by
Brink.

_SwiftSync speedup for initial block download_

**Mark Erhardt**: So today, our news item is, "SwiftSync speedup for initial
block download".  And the topic here is that Ruben came up with an idea how we
could speed up the IBD (Initial Block Download) by hinting at the node which
UTXOs the node should keep because they will not be spent.  And instead of
keeping the other UTXOs that will be spent up to some specific block height that
we're targeting, to just add them to an aggregator.  And as inputs and outputs
get processed and added to the aggregator, if new outputs come in, and inputs
get deducted from the aggregator, at the targeted block the aggregator has to be
empty, and we end up only with the UTXOs that compose the current UTXO set.  He
described that theoretically recently at a meeting, and then Sebastian
apparently ran with it and just implemented to try it, and it turns out that
they achieved a speed up of about 5x.  How about you two tell me more about
this?  Let's start with the idea, Ruben.

**Ruben Somsen**: Sure.  Yeah, so I think this has been a topic that people have
been thinking about for a long time.  There have been a lot of similar ideas.  I
think the one that's most similar is Cory Fields' UHS, which is from back in
2018, maybe even 2017, I'm not sure.  And yeah, just a general, it's kind of
surprising that there was still such a huge sort of optimization to be found.
But yeah, Murch, I think you summarized it very neatly.  The general observation
I would make is that in Bitcoin, we already say that it's better to verify
something than to compute something.  So, if you know the answer to a
calculation, then generally it's easier to check the answer than to find the
answer yourself.  So, very naively, maybe this is a division or a
multiplication.  And if you already know the answer, and check it, in particular
with division, it's easier to check the answer than to divide the number
yourself.  And so here, we have a very similar -- I think Abubakar, we get a
little bit of feedback with your mic?

Okay, yeah.  So, here, it's kind of a similar observation where with the UTXO
set, what we're doing is currently we're sort of looking at the set of inputs
and the set of outputs, and we're computing what the remaining UTXO set is, and
with these hints of saying, "Well, okay, if we have knowledge of where we are
going to end up, can we then verify whether that state is correct?"  And
verifying that ends up being a lot faster than just computing it yourself.  And
I would say the big difference is that normally, if you go sequentially through
the blockchain and you say, "Okay, an output was created.  Oh, now the output
was spent", what you're constantly doing is you have a database, and you're
constantly writing new outputs to the database.  And then, once that output is
spent, you're removing it again from the database.  And so, you're constantly
adding and deleting and this database gets very big, it doesn't fit in memory,
and so now you have to go to disk, and that slows down things even further.

With this design, we just say, "Well, we know where we want to end up.  Can we
not just check whether or not the outputs that are going to be spent matches all
the inputs?"  And yeah, it turns out we can do that very efficiently, we can do
that in full parallel, we can do it without having to have any order whatsoever.
So, it doesn't matter if you process block 2 first, and you're removing a bunch
of UTXOs that weren't added yet; if you add them later, the result still adds up
to zero.  And so, it's a very neat way of being able to do everything, and it
fits together very well with everything we currently have, where it doesn't
impact how we're going to validate going forward, which has been the case with a
lot of prior proposals.  UHS was like that, utreexo is like that, where we say,
"Okay, we could do these neat things, and maybe we can speed up IBD with it.
But now we end up with a UTXO set that is different, and now we have to continue
validating the blockchain in a different way", and that's not the case here.

**Mark Erhardt**: So, if we're still processing transactions, we're still
looking that they hash correctly, we're still looking at whether the inputs
match up with the outputs that were previously created, we're not checking the
scripts, but we also don't do that if we're running assumevalid, how do the
trust trade-offs or trust assumptions compare to assumevalid and assumeUTXOs for
SwiftSync?

**Ruben Somsen**: Yeah, so first of all, I want to clarify, and I think that
this has been something maybe that was not intentional, but a lot of people are
confused by this.  This does not actually require assumevalid.  So, you have
sort of two states in which you can use this.  And one, the easiest version, or
the simplest version to implement, and the cleanest one I'd say, is the one
where you utilize assumevalid, because what we're doing with the hash
aggregates, where we're adding stuff and we're deleting it again, when you
delete it, you need to actually have the data that you're deleting.  And
generally, if you think about the UTXO sets, that is what is inside of the UTXO
set.  That is the data that you're adding and subsequently that you're deleting.

So, in the non-assumevalid version, when you're deleting an entry again, you
need to receive that data.  So, you need to download that either from Bitcoin
Core nodes, it could even be outside of the network.  But maybe the simplest way
of thinking about it is, we just serve it over the P2P network.  As luck may
have it, it's already data that's being stored, because we also need it to go
back in a blockchain.  So, that data is already there anyway.  And so, with that
model in mind, you basically can do full validation.

But there are a few caveats, which I don't think I want to go into completely,
but I'll just mention them because it gets a little technical.  But the thing is
that since we're doing everything without order, there are certain checks that
we used to get because we're doing things in order, and now we have to do them
explicitly.  And one of those is, "Well, did an output get created before it got
spent, yes or no?"  And that is still a check that we want to do if we want to
do full validation.  Now, if the output got created in a block prior to the
block where it's being spent, it's actually very easy, because we already have
the block height in the UTXO set.  So, we can just check the block height and we
can say, "Okay, great".  But if it's in the same block, now we have to check
within the block whether or not the order was correct.  So, there are a few
little things like that.  BIP30 is another one that I won't go into.  But those
are all solvable and have been solved in my write-up.

But the downside that I mentioned was that you are downloading some extra data.
This is roughly 10% extra data compared to what we're downloading today.  So,
that is a downside, but the upside is quite massive considering you basically
have virtually no states and you can do everything fully in parallel.  And so,
with the assumevalid version, now we're saying, "Well, we're not checking
scripts".  And there's actually a bunch of other things we could skip too,
because they are similar to the script checking, they're not any more severe
than that.  And so, if we skip those, then you don't even need to download that
data, because all you're doing is now you're checking whether the outpoints, or
on the input side, there's basically a reference to the output that you're
spending.  So, that reference is what you're hashing and that's what you're
removing and adding.  And since that's already in the block on the input side,
you don't need any extra data.  And so, with the assumevalid version, the amount
of extra data required is also basically nothing.

So, that sort of ends up making it very simple and neat.  And that's also the
version that Sebastian ended up implementing, which by the way, Sebastian, I'm
very happy that you just ran with it.  We had a little like, "Oh, maybe I should
have come to you first because now I gave it a different name".  No, I'm very
happy that you just went and you implemented something, because ultimately
that's what needs to happen.  And so, I'm only happy that that happened, and I
hope many more people will start working on it.

I guess the one point I didn't address yet was assumeUTXO.  So, with assume
UTXO, we are basically starting at a UTXO set, and then we do background
validation.  And the background validation parts, that could be done entirely
through SwiftSync.  So, that part, you can fit those in together very neatly.
And in fact, in the non-assumevalid version, you won't even need to download the
hints anymore, because the UTXO set is essentially equivalent to the hints,
because the hints are basically data that says, "Will this output get spent, yes
or no?"  But the UTXO sets is roughly equivalent to that.  So, we can sort of
utilize.  That's the quick summary.

**Mark Erhardt**: Roughly equivalent?  No, it's exactly, it's just a different
way of transporting the same data.  In one you say, "These are the UTXOs that
we'll have when you're finished", and in the other one, you say, "This is the
UTXOs at this block", and then you just check that you end up there.  So, it's
literally a superset of the data.  Sebastian, we've talked a bunch about the
theory behind this all.  What made you just run ahead and implement this, and
what did you experience then?

**Sebastian Falbesoner**: Yeah, so this was a few weeks ago on a Core Dev
meeting, when I found Ruben talking about this proposal, and it took a while
until it clicked.  At first, it didn't make much sense to me, but when it did, I
thought it's a very nice idea that potentially is not too complicated to
implement, but could still yield a lot of speed up.  And I think the timing was
kind of right for this proposal, because there were some nice building blocks
out there.  So, the bitcoinkernel lib was released with a nice Python wrapper,
like Py-bitcoinkernel, just a few weeks before, which I could build on.  It's a
project by stickies-v, so thanks to him.  And there is also a script out there
that generates the UTXO set in a SQLite database that is very useful, for this
year, which is by the way in the included release today, Bitcoin Core 29.0.

So, with those building blocks it was quite straightforward to implement that,
because what you need to do to create these hints, this is the first part, you
have to go through all historical blocks, go through every transaction output
ever created and answer the question, "Is this output, this coin, in the block
at the, I think it's now called, terminal SwiftSync block?"  I'm very glad there
is now official terminology for this because I was not sure how to name it, when
I was still naming it IBD poster.  So, with that, using that was
straightforward.  So, I started a Python project using this Py-bitcoinkernel
library, then go through all the blocks.  That is the first input, you need a
datadir that is not running and you need a SQLite UTXO set, which you can create
by first creating the assumeUTXO binary serialized UTXO set and then converting
it to the SQLite database.  And in order to be efficient, we can use the created
index on the block height that is very useful, so we can be faster in fetching
the necessary coins.  So, what the script does now, I do one database query per
block height and build a map that maps from txid to vout.  And that, I found, so
far is the most efficient thing to create the hints.

Finally, the same thing that needs to be applied on the Bitcoin Core side can
also --

**Mark Erhardt**: Sorry, let me jump in briefly.  You map from txid to vout.
So, the outpoint of UTXOs, which is the unique identifier of each transaction
output, wouldn't that be both of those?  So, could you explain the mapping?

**Sebastian Falbesoner**: Yeah there is a map in there, which maps the txid to a
list of vouts, and I just use that.

**Mark Erhardt**: So basically, you just remember how many outputs there were
per transaction?

**Sebastian Falbesoner**: Yeah.  So, in the first situation, I did a single
SQLite statement per transaction output per coin, and I found it's faster if I
just do one database query and build a map out of that.  But that's just a
technical detail.

**Mark Erhardt**: Okay, carry on.

**Sebastian Falbesoner**: But on the hints generation side, and finally, the
same thing that can still be done on the Bitcoin Core side, like parallelizing,
could also be done on the hints generation side, because the script is still
very slow because it goes through all blocks linearly, and that could also be
just parallelized.  Stickies-v sent me a message recently, there's a new
Py-bitcoinkernel lib release that supports multi-threading and reading multiple
blocks in parallel.  So, that will be a next step to implement that, because
creating the hints file for the block I included there was still creating, I
don't remember, it still took one or two full days.  So, I think that's also
nice to speed up that.  And yeah, the file format is pretty much proof of
concept, like it's basically a giant bit set, but in order to divide it into
blocks, I stored a number of outputs per block in front of each section.

Someone pointed out a flaw that this is a 16-bit integer, that this could be not
enough, because there could be blocks with more than 65,536.  Apparently there
has been blocks where this was the case.  If you always have an output script of
almost 0 or 1 byte, then this is in theory possible.  So, this needs to be
something to be improved.  Someone pointed out, "Why not just store the bits
linearly without any division", but I think we want some way to find the bits
between the blocks.  So, I think what could be done that we just create a table
of contents in the beginning that maps block height to position in the file, or
something like that.  And yeah, that is the hints generation part.

The other side is a Bitcoin Core branch that uses this hints file.  So, there is
a command line option, now called SwiftSync file, previously called IBD booster.
Sorry again for the confusion that I created with the post.  I will soon publish
a branch that adapts all the terminology and the new naming.  And what it does,
it first loads the file, creates a map from block height to Boolean bit vector.

**Mark Erhardt**: Yes, indeed.  So, so far, there is a branch that can do the
SwiftSync, there is a way of generating the hint file, but it sounds like the
hint file has to be acquired out of band.  So, right now, where would it be
published?  Would it be just something that you've BitTorrent, or is it
something that you get from a website?  What's the long-term vision compared to
that?

**Sebastian Falbesoner**: That's not something I've given much thought of, to be
honest.  I think it's a little the same problem we have with assumeUTXO.  Yeah,
of course, it could be that you'll kind of store a hash of that file also in the
Bitcoin Core binary, like we already do with assumeUTXO.  You could, in theory,
even include it directly in the binary.  In that case, it might make sense to
look into compression.  I think in general, compression is something, it's one
of the things I will look at the very last things, because I think it's already
quite small, given that someone who goes to a full IBD has already to download,
I don't know, at least 600, 700 GB of data.  So, for a user perspective, it
doesn't matter if you download an additional 300 MB or 100 MB.  But if you embed
it in the binary, it might be nice to keep it as small as possible.  Funnily,
the reason I compressed it was that GitHub didn't allow me to include files that
are larger than 100 MB.  So, I applied xz on it and then it ended up nicely with
80-something MB, and that's how I included it.  So, that was the reason why I
compressed it in the first place.  But yeah, that is an unanswered question, I
think, how to distribute that.

I should also point out the thing I implemented is the assumevalid version of
the SwiftSync proposal.  What I like about the proposal also, it is actually, if
you look at the branch, it's not that much code.  So, everything is in a small
scope.  There is one function that's called ConnectBlock, which does the single
block validation.  And within that, you just skip a few of the validations,
mostly because there will be some validations that would still be cheap, like
verifying the block reward, but we cannot do that because we don't have the
prevout data anymore about the output amounts from the inputs.  So, not all of
the checks are skipped because of optimization reasons, some of them are just
skipped because we don't have the necessary optimization.

But the main change is in a function that applies actually a transaction to the
UTXO set, where previously it would just spend coins and add the outputs.  And
with this proposal, if the SwiftSync is activated, it will just, for each input,
remove it from the hash aggregator; and from the outputs, either add it to the
UTXO set if the bit vector says 1, or add it to the hash aggregator if it says
0.  And at the terminals with block if everything goes well, then this hash
aggregate should be 0; and if not, a block validation error is thrown.  And
yeah, I think it's very cool.

I initially implemented it with MuHash because that was back then the idea what
was talked about, and now it's simply a uint256 modular arithmetic addition,
subtraction, and that's even simpler.  So, that's cool.

**Ruben Somsen**: So, the current implementation, I think the complexity, there
is more complexity once you consider the non-assumevalid version.  I think
assumevalid version, definitely it's very clean and it's very nice for us to be
able to get the numbers from that.  And, Sebastian, you already said it, but
your implementation currently does not do any parallel validation.  So, the
expectation is that that will speed up things even more.  And I think actually,
the non-assumevalid version, it sort of adds a fixed cost of having to check
every script.  Of course, you can do it in parallel now, so that's a win.  But I
think that will probably lower the numbers a little bit again.  So, we'll
probably get another massive speedup from the parallelization, and then maybe
slightly lower for the non-assumevalid version.  And of course, it depends on
how many cores do you have; are you brand bottlenecked, yes or no?

Something else that's kind of interesting is that you can even distribute the
workload over multiple computers.  So, in theory, you could even sort of go that
way and have it be -- it should, in theory, at least basically be as fast as how
much bandwidth and CPU you have, which basically removes any other bottleneck we
had before this.

**Mark Erhardt**: That's very impressive.

**Sebastian Falbesoner**: I mean, to implement the parallel validation, I think
it needs much more invasive changes to the code base.  Also very dangerous, of
course, it touches consensus code, which already my branch does, but in a more
limited way that is fairly easy to review, I would say.  But yeah, parallel
block validation is a different beast.  I would hope that someone tackles that,
that is a little more knowledgeable about block validation and the general
architecture of Bitcoin Core.

**Dave Harding**: One of the things I was really, really impressed by was how
small the consensus changes were for this assumevalid version, and it's just
amazing.  No parallel validation, but it was just really cool opening up your
diff and seeing that it was basically just one function, that you added a
function and made two other changes.  You know, it was just so, so small, so
amazing that we get this huge benefit from such a small change to the consensus
code.  It's just amazing.

**Sebastian Falbesoner**: Yeah, I was also positively surprised by that.  One
thing, I don't know if that's in the proposal, one drawback I found, which might
cause second cause is the undo data that is missing.  You mentioned it already,
Ruben.  It is true that it's primarily for reorgs.  So, if we put the terminal
block long enough in the past, that won't be an issue.  But the undo data is
also used by other indexes, like for example the block filters.  So, that might
be a drawback, that you cannot create some kinds of filters anymore.  Some RPC
calls, like getblock, they use the undo data to show the prevout data for
certain blocks.  So, that will be an issue for the assumevalid version.

**Ruben Somsen**: Yeah, so the non-assumevalid version doesn't have this
drawback, so that's the first thing to point out, of course.  I think the second
thing is to compare it to a pruned node, right?  If we do pruning, then we also
don't have the undo data.  So, I think that's sort of what you get.  So,
essentially, you could sort of say, well, you get some of the drawbacks of a
pruned node as well if you do assumevalid.

**Mark Erhardt**: So, the problem here is that you do not store the data in a
specific manner.  But if you download everything, couldn't you later add these
indexes from the copy of the blockchain that you have?

**Ruben Somsen**: Like as a sort of background validation, you mean?  Yeah.  I
mean, of course, I mean that's always possible.  Probably with additional hints
data, you could maybe even do it, because if you say, "Well, this output will
get spent in this specific block", then maybe you can sort of use that to write
it to disk.  It's more write operations, but there are some middle grounds there
that you can think about.  But ultimately, I think the simplest answer is just
if this is a downside to you, then do non-assumevalid SwiftSync.  I think that's
the simpler thing than to over-engineer a solution to this problem, which might
be possible.

**Mark Erhardt**: I think it's also generally fair to assume that people who
want to have all the indexes are not running on the smallest minimum machine and
tend to have the smallest data footprint.

**Sebastian Falbesoner**: Do I understand correctly, Ruben, the non-assumevalid
version would need to introduce a new P2P message for downloading the undo data
probably?

**Ruben Somsen**: Yeah, I'm personally sort of agnostic about where you want to
get the data, because as long as there's a hash committed in Bitcoin Core, or
not even that, if you just have a trusted third party, say, that just says,
"Hey, I will help you", and you download the undo data from them, at the end of
the line, once you've completed validation, then you know that everything that
you receive from them is correct.  So, I'm like, sure, maybe it's not the ideal
way of doing it, and we prefer everything to be P2P, but I don't necessarily
want to dictate one or another method of doing this.  And I guess one thing to
add to that is that with adding things to Bitcoin Core, we are limited to
Bitcoin Core's releases, which means that if you are running on an old release
and then you still have X months' worth of validation to do once you reach the
terminal switching block, at that point you could think of some kind of hybrid,
or a third party could be more flexible there, and just say, "Okay, well, I will
help you all the way up until the current tip".  And the worst-case scenario is
that this third party screwed you over and wasted your time.  And then, you
spent half a day evaluating something that ended up being incorrect.  And now,
the third party lost their credibility.  So, that's not the end of the world
either.

So, just to say it's flexible and there are multiple ways of approaching this.
So, I don't want to already go and pinpoint one specific direction.  But sure,
the other direction would be Bitcoin Core, the undo data is already available
with all the nodes.  So, we could start serving it and over the P2P network.
And interestingly, that also would theoretically allow, you could use that to
allow pruned full nodes to reorg back, if they downloaded the undo data to go
back in time, provided that they kept a hash of the data themselves, so they
know the data they receive is accurate.  So, there are some other potential
benefits that we could gain from this.  But yeah, that would be one way of doing
it.

**Mark Erhardt**: Now I forgot what I wanted to say.  Dave, did you have
anything else?

**Dave Harding**: No, I think we covered this quite in detail.

**Mark Erhardt**: All right.  Well, thank you, Ruben and Sebastian, for joining
us for this news item.  We're going to move on to the next item.  If you want to
stick around, please feel free, but we understand if you want to do something
else.

**Ruben Somsen**: Thanks, guys.  Bye.

_Add Fee rate Forecaster Manager_

**Mark Erhardt**: We are now getting to the next item, which is the Bitcoin Core
PR Review Club this month.  And for this item, we have another guest, Abubakar.
Would you like to introduce yourself?

**Abubakar Sadiq Ismail**: Yeah, thank you so much, Mark.  I'm Abubakar, I'm a
Bitcoin Core contributor, being supported by BitTrust.  I am excited to join you
and talk about feerate forecasting.

**Mark Erhardt**: Super, thank you.  So, you led the Bitcoin Core Review Club,
which generally is a meeting in IRC, where people get together for an hour to
talk through one Bitcoin Core PR in detail.  You are both the author and the
host of the meeting, so I assume you're quite well-versed in the topic.  Let me
try to tee it up a little bit.  This PR's title is, "Add Fee rate Forecaster
Manager", and the background idea is that currently, Bitcoin Core uses the
CBlockPolicyEstimator, and I'm just going off of your own notes right now, but
the point there is Bitcoin Core has long only provided a feerate estimate based
on past performance of transaction confirmations.  So, it tracks only
transactions that the node has seen in its own mempool and then sees again
confirmed in blocks, and measures how long and what feerate transactions took to
get confirmed, and uses that as the basis to make estimates of how long it'll
take for other transactions in the future to get confirmed at certain feerates.

So, the current policy is very hard to manipulate because each node measures
only things that they have verified themselves, transactions in their mempool
and in blocks, but it doesn't react at all to the content of the mempool.  So,
if something gets added to the mempool and you can already estimate that the
next block will have a much higher feerate, this estimation cannot predict that;
and vice versa, if the demand drops off, the Bitcoin Core estimates will still
linger at a higher feerate.  So, you've been working on this for quite some
time.  Would you like to tell us more about the PR at hand?

**Abubakar Sadiq Ismail**: Yes.  So, I opened this PR back in January.  It's
part of the project that you have just described, which is to improve Bitcoin
Core fee estimation, so fee estimation strategy in Bitcoin Core.

**Mark Erhardt**: Sorry, I think we had an interruption.  I didn't hear you for
a few seconds.

**Abubakar Sadiq Ismail**: Can you hear me?

**Mark Erhardt**: Yeah, now I can hear you again.  The last thing I heard was,
"To improve the Bitcoin Core feerate estimation", and then there was a gap.

**Abubakar Sadiq Ismail**: Yes, so I was saying there is an issue on Bitcoin
Core, which highlights all the limitations of the current strategy that we are
using.  So, what I want to do is to add a forecasting manager, which is going to
subscribe to events that is happening in the node, which includes new blocks
being connected, all transactions that have been removed from the mempool due to
a block being connected; and then also have access to pointers to strategies
that are being used for fee estimation, one which is a CBlockPolicyEstimator and
another one is the mempool, and then decide which one to use.  So, the PR that I
have added this feature, it also refactors the currency BlockPolicyEstimator
during some renames and file moves.  And then, it added an abstract class, which
all feerate forecasting strategies are going to implement, and then provide a
method that the ForecastManager will know and use whenever it decides.

So, it's going to return, based on what it has ascertained, whether your mempool
is roughly alike with miners or not.  And the current approach is to use the
mempool to lower block policy estimates.  Whenever you have noticed that the
main pool is parsed and BlockPolicyEstimator is giving you a very high estimate,
you are going to return what the mempool is indicating.  But whenever
BlockPolicyEstimator is higher, then you will take it, because it's highly
likely that currently with the current algorithm, the feed rate that it provides
is very high, and sometimes it's sufficient for your transaction to confirm in
the next block.  But there are some times where there is, let's say, a
congestion in the mempool or sudden fee spike, then what BlockPolicyEstimator is
telling you will not help at that point.  So, this is the limitation of the
current approach.  But the FeeRateForecastingManager provides a modular approach
to fixing this issue and without much refactors and subscribing to the
validation interface, not the CBlockPolicyEstimator holding mempool pointers and
chainstate pointers.

**Mark Erhardt**: I was going to jump in briefly to recap what I understood.
So, you're saying that there will be a new mempool-based feerate estimation.
And in order to make sure that it is not manipulated, we in some way measure how
close our own mempool is to what miners are putting into blocks.  Could you
briefly describe how that would work?

**Abubakar Sadiq Ismail**: Yes, so how I ascertain that is using the validation
interface notifications.  So, whenever a new block is connected, we remove
transactions that have been added into that block from our mempool, and then we
emit a notification, "Mempool transactions removed from block".  So, I am
computing the total weight of those transactions, and then when the full block
has been validated, there is also another notification called, "Block connected
with all the transactions".  So, I will compare the weight of the transactions
in the block that we have seen in our mempool and the actual weight of the
block.  And if there is not much difference, then you know that most of the
transactions in that block, you have seen it in your mempool.  So, this does not
require building any block template immediately after you receive a new block,
or stuff like that.  It's fully using validation interface notifications, and it
runs on the background without blocking the code path.

So, previous approach that I have implemented is to build a block template and
then compare them.  But I think this is more elegant and better.

**Mark Erhardt**: Yeah, I was going to ask exactly about that, whether you're
comparing the block that you would have built with the block that the miners
built, or whether you're just looking at whether the transactions that were in
the block were in your mempool before.  So, I guess theoretically, you could
have either less or more in your mempool than the miner considered.  So, if you
have things that you have already seen that you would have included, that would
make your block template more different from the miner's block template.  But
that might also happen when the miner found a block based on a block template
that was given out 30 seconds ago to a slower mining hardware device, and you
have received 30 seconds' more transactions and you would have built a better
block, right?  Whereas if you just compare, "Have I seen everything in my own
mempool that is in this block?" at least they don't include a lot of foreign
transactions that you've never seen and you get that information.

**Abubakar Sadiq Ismail**: Yeah.

**Mark Erhardt**: Cool.  So, could you repeat again, I wasn't sure I got that
right?  The mempool-based feerate estimation is only used if it is lower than
the CBlockPolicyEstimator, which we currently use, because our worry would be if
the mempool gets filled with a lot of transactions at very high feerates, that
we would overpay if the miners then don't actually include those in the blocks.
So, the mempool feerate estimation will not be used to increase the feerate but
only to lower it, is that correct?

**Abubakar Sadiq Ismail**: Yes, that's correct, and I like the idea like this.
There is a recent post by, I think, Matt Morehouse, in Delving Bitcoin, which
explains LND's budget-aware sweeper.  So, I think this can really be used with
the budget-fee-aware sweeper, in the sense that whenever you have a deadline for
your HTLC (Hash Time Locked Contract), you can call estimatesmartfee to get the
feerate for your transaction to confirm.  And then, if a block parsed and your
transaction did not confirm, then you can call estimatesmartfee again and
compare with what the fee function is telling you, and then take the highest.
So, what the fee function is telling you is what you can afford to pay at that
point in time before the deadline elapsed.  So, comparing these two will make
you not pay more than necessary and will make your HTLC likely confirm
economically.

The only issue with this approach is for users that want their transaction to
confirm as soon as possible, they just want it to confirm next.  They want to
pay whatever fee that is being recommended.  So, what we are giving the users,
since it's based on CBlockPolicyEstimator, when there is congestion or when
there is a fee spike, it won't work really well.  I think we have made that
decision due to an attack that was explained elegantly by Harding.  But that
attack is really theoretical, and I don't care much about it.  Maybe, Harding,
you can explain it better.

**Dave Harding**: Well, I mean basically miners can send transactions that they
know will never confirm to your node and fill your mempool up with transactions
that they know they will never confirm, either because there's a 51% attack of
miners, or maybe it's because we're activating a soft fork anyway.  At least in
theory, it's possible to fill your mempool up with stuff, and then create a very
high feerate environment in the mempool that doesn't represent what's actually
going to get confirmed.  The other way of thinking of that is, with the tools
that we have with RBF and CPFP, it's always possible to increase a feerate, but
you can't decrease a feerate once you've paid high.  So, you want your estimator
to give you an accurate estimate ideally, but start on the low side and then use
your tools available to increase, like you were talking about with Matt
Morehouse post, which we covered in a previous newsletter.

**Mark Erhardt**: So, what this approach will help us with is estimating a
better low end of the feerate estimate, because one of the biggest criticisms
with Bitcoin Core's fee estimation has been the lingering overpayment, where
especially when people used to, by default and also by practice, use the
two-block estimate and the feerate had run up, for a very long time, there were
two stratified levels of feerates, people that were paying what needed to be
paid to get into the next block, by looking at the mempool; and Bitcoin Core's
very conservative feerate estimate that tended to stay at the same level of the
peak for some time.  And then, because there were transactions that were paying
at that level, other Bitcoin Core nodes continued to use the same feerate
estimate.  And the self-fulfilling prophecy led to Bitcoin Core's feerate
estimation taking a long time to decay back to the regular level.

With the project that Abubakar is driving here, we would very quickly be able to
reduce the starting point of the feerate estimation.  This has already gotten
better since the main issue with us always creating RBFable transactions and
using smart fee estimation instead of conservative feerate estimation, and
generally starting lower.  But now we have another way of lowering the feerates.
And as Dave already mentioned, we now always have access to RBF and CPFP, so
it's easier to increase the feerate after the fact than it is -- well, it is
impossible to decrease the feerate, people will just take the juiciest
transactions so you can take back transaction fees.

All right, Abubakar, do you have more details on this, or do you want to add
anything else?

**Abubakar Sadiq Ismail**: Just that I think this approach is what we have been
working on with Will Clark, josibake and Clara.  So, right now I think the
mempool is the source of truth mostly for feerate forecasting.  But then, we
said we should go with this approach of having a FeeRateForecastingManager and
the interface, so that in case mempool is not the source of truth, then it
should be very easy for us to extend and add another strategy, so that it will
just be natural to incorporate.  And yeah, after this Review Club, I have gotten
very useful feedback from the attendees, which I have already implemented.  And
right now, the PR is currently open for review.  So, if you are interested in
this project, you can reach out to me directly or just take a look at the PR.  I
think the nodes have a very good description of the current status and all the
work that have been done in the past.

**Mark Erhardt**: Yeah, anyone that wants to catch up on this project, look at
the PR Review Club notes.  They're quite extensive and in detail.  I spent some
time perusing them yesterday.  Also, if you're generally interested in levelling
up your Bitcoin Core contributions and reviews, we are trying to increase the
frequency of the Bitcoin Core Review Clubs again, and there have been quite a
few.  So, when it was more once a month until a few weeks ago, it's been more
like every week or every other week now.  So, if you're interested in joining PR
Review Clubs and seeing how people approach PRs, what they think about them or
just want a guided tour through a PR, check out bitcoincore.reviews to get
information on the next meetings and upcoming PRs.  All right, thank you,
Abubakar, for joining us and walking us through your work.  We will be heading
to the next section.  If you want to stick around, you're welcome to stick
around, but we understand if you have other stuff to do.  I think most of the
upcoming stuff is LN-related.  So, if you want to drop, we don't mind.  Thank
you for joining us.

**Abubakar Sadiq Ismail**: Thank you, I'm dropping.

_Core Lightning 25.02.1_

_Core Lightning 24.11.2_

**Mark Erhardt**: All right.  We now get to the section, Releases and release
candidates.  We have five of those this week.  So, we start out with Core
Lightning (CLN), which has two releases.  There's the 25.02.1 release and the
24.11.2 release, and I'm mentioning them together because they're both
maintenance releases.  They're the maintenance releases for the two latest major
versions, and most of the bug fixes in the release notes apparently overlap as
well.  So, there's a few backports, I think, that improve the fees for
unilateral closes; and also in both of them, I think, there was a bug where
outputs wouldn't get discovered if the peer didn't support an option called
option_shutdown_anysegwit, and I think that that was also backported in both of
these releases.  So, if you're running CLN, you might want to check out these
new releases, especially if you've been troubled by some bugs.  There's also a
few other bug fixes, but you will find the details in the release notes.

_BTCPay Server 2.1.0_

Then, the next one coming up is BTCPay Server 2.1.  BTCPay Server is a new major
release and it especially includes some breaking changes.  If you are a user of
Monero or Zcash with your BTCPay Server, please do read the release notes here.
They moved the processing of Monero and Zcash out of the main core function and
you will have to install some extensions for these two cryptocurrencies if you
want to continue processing them, if you upgrade.  So, be aware before you
upgrade to read the release notes.  There's also improvements for RBF and CPFP
fee bumping, and a better flow for multisig if all of the signers of the
multisig are using BTCPay Server.  I think that was the major points, but the
BTCPay Server release was very juicy.  There was a lot of stuff in there, so be
sure to check the notes if you're running BTCPay Server and thinking to upgrade.

_Bitcoin Core 29.0rc3_

So, we're getting to a Bitcoin Core release now actually.  Even though our
newsletter said that we are on RC3, yesterday actually Bitcoin Core 29 was
released.  We did talk a bunch about the features and the functionality that
should be tested in the recap of Newsletter #346 because we had Jan on to talk
to us about the Bitcoin Core Testing Guide.  Well, the new Bitcoin Core release
is out now.  You can find the release notes on bitcoincore.org and also the
downloads there.  I think I might note here that at least in the past on
bitcoin.org, the verification of the binaries was outdated.  So, if you do want
to verify your Bitcoin Core release binaries, please check the instructions on
bitcoincore.org, not on bitcoin.org.

The release of 29.0 also means that Bitcoin Core on the 26.x branch, so 26.0 and
any maintenance releases since then, are now in the maintenance end and they
will likely not receive any further updates.  And the security disclosures for
v26 will be published in a couple weeks for 26.x.  So, if you're running 26.x in
an infrastructure project or generally, you might want to look into upgrading,
because security disclosures are coming.

_LND 0.19.0-beta.rc2_

All right.  David, please jump in if I'm missing anything.  Okay, cool.  Let's
go on to the last RC.  We are looking at LND 0.19.0-beta.rc2.  This release also
contains database migrations, so if you upgrade, you will not be able to
downgrade.  This one was also chock full of new features and upgrades.  I wrote
out a few that jumped out to me.  So, there is a new feature to add support for
archiving channel backups for future reference.  There is support for the new
RBF cooperative close flow, which allows either party of the two channel
partners to use their own funds to create RBFs.  So, previously there was a
negotiation that sometimes failed if one party wanted to increase the fees, but
it was using the other party's funds.  In this new flow, either party can
finance the RBF from their own funds, and therefore negotiation should be much
easier because the person that wants to increase pays.  There is also support
for the experimental endorsement signal that we've talked a bunch about in the
last years, which is for channel jamming mitigation.  And this is just an
experimental signal to measure how well the signals would be working in case
they actually would get used.  But we're excited to see that this is coming to
LND now.

I also saw that there's a new RPC for BumpForceCloseFee, and several other RPC
improvements, with new parameters or bug fixes.  There is initial support for
quiescence, improvements to sweeping of outputs, and yeah, there was a lot.  So,
if you're an LND user and you want to upgrade, please do peruse the release
notes to see if there's stuff that you need to test in your testing
infrastructure, before pushing that out into production.  Cool, this is what we
had on Releases and release candidates.  We are now coming to the last section,
which is the Notable code and documentation changes, and over to Dave for this
section.

_LDK #2256 and LDK #3709_

**Dave Harding**: Thanks, Murch.  Okay, we're going to start out with two PRs
from LDK, that's #2256 and #3709.  And these both include LDK's handling and
support for attributable failures.  So, that's when you try to route a payment
through the LN network and it fails at some distant hop.  You want to learn
exactly where it failed so that you can avoid routing through those nodes at
those pair of channel partners in the future.  And this is something that Joost
Jager has been working on for several years, and we've talked about it a few
times before in the newsletter and in the recaps.  And he wants to really lean
heavily on this for trying to get nodes to be forwarding nodes, not your regular
node on your mobile phone.  But if you're going to be a forwarding node, we have
good reporting of who is not forwarding payments correctly.  We can heavily
penalize them and not forward payments in the future, creating a strong
incentive for forwarding nodes to be very fast and high uptime and good.

So, these two PRs, they make a few specific changes that we go into the
newsletter.  And one of the interesting things here is not only do we mostly get
attributable failure, so we know where it fails; we also get timestamps that are
being added by each hop along the way that allow us to see how long a node held
a payment.  Now, these are not guaranteed to be reliable, because there's no
perfect timestamping service out there that we can rely on, except for block
timestamps, which are not perfect themselves, and they don't have high
resolution, but these are what the nodes are saying they're claiming the time
was.  So, we might be able to see a little more insight into how long payments
are taking, where they're slowing down at particular nodes, so we can maybe
penalize those in the future.  But the main thing here is penalizing nodes that
are failing payments, so we can avoid routing through them in the future.

_LND #9669_

Moving on, we have LND #9669.  And this speaks to what Murch just talked about
in the RC for LND 19.  This actually downgrades simple taproot channels, which
is LND's experimental new channel format that uses taproot.  Those are all
unpublished channels at the moment.  And it downgrades them to always use the
older traditional legacy cooperative flows.  So, Murch was talking about how
there's a new RBF-based cooperative close, where either side can use their own
funds to say, "Hey, I want to bump the fees on this", and the other person's
like, "Hey, if you want to use your own funds, sure, go ahead".  This has been
downgraded for simple taproot channels.  I understand there's some sort of
conflict there in the design.  I think they're going to resolve this eventually,
but we wanted to note it here in the in the newsletter for anybody who's
expecting to depend on that for simple taproot channels.

_Rust Bitcoin #4302_

And our final PR for the week is Rust Bitcoin #4302, and this just cleans up
their API related to relative timelocks.  Relative timelocks in Bitcoin are kind
of a little weird, because we reused an existing field in the transaction, the
nSequence number, and we didn't want to use the whole space of nSequence field,
because we were using it for some other things and we wanted some additional
extension options in the future if we needed them, and so you could do multiple
things with that field.  And before this change, we kind of had to know what was
going on.  And now, they've got their API, they have a couple of new functions
where you just say, if you want to use relative locktime, you just put your time
into this function, it'll format it for you, it'll check to make sure
everything's correct and you're good to go.  Those are our three PRs for the
week.  Back to you, Murch.

**Mark Erhardt**: Thank you, Dave, that was very filled with details.  I really
enjoyed that.  That is all for our newsletter this week.  So, thank you for your
time, dear listeners, I hope you hear us again next week.  And we would like to
thank our guests, Ruben Somsen, Sebastian Falbesoner and Abubakar Ismail Sadiq
who joined us to talk about the news items and the PR Review Club.  And I would
very much like to thank Dave for jumping in this week to help me provide this
newsletter to you.

{% include references.md %}
