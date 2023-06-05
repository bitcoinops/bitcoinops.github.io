---
title: 'Bitcoin Optech Newsletter #252 Recap Podcast'
permalink: /en/podcast/2023/05/25/
reference: /en/newsletters/2023/05/24/
name: 2023-05-25-recap
slug: 2023-05-25-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao, Robin Linus,
and Lukas George to discuss [Newsletter #252]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/71361787/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-4-31%2Fe79a73bf-c611-123c-de4f-df2a11aacbdd.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #252 Recap on
Twitter Spaces.  It's Thursday, May 25th, and we're going to be talking about
validity proofs and the mempool and a bunch of services and client software
updates today.  We have a few special guests.  We'll go through introductions
and we'll jump into the newsletter.  I'm Mike Schmidt, I'm a contributor at
Bitcoin Optech and also Executive Director at Brink, where we fund open-source
Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm WhenTaproot?, and I impersonate Murch today.

**Mike Schmidt**: Gloria?

**Glorida Zhao**: Hi, I'm Gloria, I work on Bitcoin Core at Brink.

**Mike Schmidt**: Robin?

**Robin Linus**: Hi, I'm Robin, I'm working on ZeroSync.  We are applying STARK
proofs to Bitcoin.

**Mike Schmidt**: And, Lukas?

**Lukas George**: Yeah, I'm Lukas, I'm a colleague of Robin, working on the same
thing.

**Mike Schmidt**:  Awesome.  Well, thanks everybody for joining us today.  We'll
just go through the newsletter sequentially.  I've shared some tweets in the
spaces, otherwise, you can follow along at Bitcoin Optech Newsletter #252.

_State compression with zero-knowledge validity proofs_

Our news item for today is state compression with zero-knowledge validity
proofs, and we have both authors of the whitepaper that was posted to the
Bitcoin-Dev mailing list here to explain the idea, the benefits, and other
interesting things that could be done with their proposal.  Robin and Lukas, if
I could summarize it, the usual way to understand the state of Bitcoin
blockchain and transactions in the UTXO set is to download Bitcoin Core and run
a full node, which a lot of people do.  But there are other ways and there's
pruned nodes, there's Simple Payment Verification (SPV), there's all kinds of
other techniques to understand aspects of what's going on in the Bitcoin
blockchain.

But there is a new way that you guys are proposing here, using zero-knowledge
proofs to compress the state into a proof using some cryptographic tooling and
techniques, such that as users of those proofs, we can validate those proofs and
maybe understand a bit about the blockchain without having to download all that
information.  Perhaps you guys can walk through, correct anything I've said, and
maybe provide a high-level summary of what your paper goes over, and then we can
jump into some of the details.  Robin, do you want to start?

**Robin Linus**: Yeah, sure, thanks.  Yeah, what you explained was perfectly
right.  What we are basically doing is we are running a full node inside of a
proof system.  So, a very beefy server does the initial block download once, and
then it creates a proof that they did it correctly, and then they can share that
proof with millions of ZK nodes and they can basically instantly verify the
chain state with that proof.

**Mike Schmidt**: And what is included in that proof; what is being validated
and what is not?  Maybe talk a little bit about the prototype you have and then
plans for the future about how different things could be validated.

**Robin Linus**: I'll do it the other way around.  In the end version, all
consensus rules can be verified within the proof, except for the longest chain
rule and the data availability.  So, you can verify the proof of work, the
difficulty adjustments, the UTXO set, the fees, the coin emission schedule, and
basically everything except for the longest chain rule, because the proof is
only aware of a single chain at a time.  So, you still would have to connect to
some P2P network, and it would be required that you are connected to at least
one honest peer.  And as long as you have one honest peer, you could easily find
out what is the longest chain by using a proof.

**Mike Schmidt**: I think in the paper to illustrate that, you guys created a
web verifier for these chain proofs, so that you could actually have compiled
something down into web assembly, such that someone in a web browser could very
quickly verify Bitcoin's chain state on a website; is that right?

**Robin Linus**: Yes, that's right.  And in that web demo, it is only a header's
chain proof.  We are planning to build the full-chain state proof in three
stages.  The first stage is very similar to an SPV client.  In the second stage,
we call it the assumevalid proof, which verifies all consensus rules except for
the scripts.  In the third stage, we will verify everything.  And what's
currently available in that web demo is the header's chain proof, but we have
also built a prototype of that assumevalid proof that already uses, for example,
utreexo to manage the UTXO set within the proof.

**Mike Schmidt**: And so you mentioned these different types of proofs that
you're working on and have worked on.  What I think everybody thinks of the use
case of having a quicker initial sync, maybe you can speak to that briefly.  I
think that you have some technology that's been integrated into Blockstream
Satellite, maybe you can talk to that a bit.

**Robin Linus**: We are going to integrate it into Blockstream Satellite.
Currently it's not integrated, but yeah, the Blockstream Satellite is a great
use case for our technology because it's very bandwidth constrained.  You can
already sync with the Blockstream Satellite, but it takes, I think, weeks or
even a month to download the entire blockchain and without chain state proof,
you could sync within a second also.  And combining it with a utreexo node, you
can immediately start listening for new blocks and start participating in the
network basically instantly.

**Mike Schmidt**: And, what are the considerations in terms of concerns about
this cryptography or downsides to using this technology versus just running your
full node or syncing in a traditional way; what should people be conscious of?

**Robin Linus**: The cryptography itself is relatively conservative, because it
doesn't introduce any new fancy cryptographic assumptions.  There is a range of
different zero-knowledge proof proposals, but we are using STARKs, which is
probably the most conservative one.  Others are using pairings and stuff that is
less battle-tested, I'd say.  And also STARKs have been around for quite a
while, and I think within the cryptographer community, there is not much of
concerns about it.  But of course, it's still very novel technology and it will
take us quite a while to get to a point where it gets even remotely close to
Bitcoin Core in terms of security.  We would have to harden it a lot and we need
lots of eyeballs to really check it before we could claim anything close to
Bitcoin Core security.

**Mike Schmidt**: There was a second use case that you noted in the whitepaper,
that is trustless light clients.  Can you speak to that a bit and how that
differs from SPV?

**Robin Linus**: Yes, maybe Lucas wants to answer that.

**Lukas George**: Sure.  So, yeah, the use case we thought of is basically
that when you request a full node to send you, for example, your UTXOs, so you
first connect to the network, you have some wallet address, you want to know
what UTXOs you can spend possibly, and they could withhold you some data; or
basically with anything you request, they can withhold data, and you kind of
have to trust the full node in that they will send you the data you asked for.
And with a proof, they could essentially prove that they did send everything
that you requested.

**Mike Schmidt**: Versus SPV, where something could be withheld; is that right?

**Lukas George**: Yes.  And with SPV, you only have the merkle path.  But if
the node just decides to not send you the merkle path and just say, "No, sorry,
I didn't find any at the transaction, I didn't find it in the block you
specified", then you would have to go on to ask the next node and eventually be
convinced that it does not exist.  But yeah, with the proof, it gets a bit
easier and you lose the trust assumption or get rid of it.

**Robin Linus**: And I would add that SPV clients, the more people are using
SPV clients, the higher the incentive for miners to mine invalid chains, because
the SPV client, of course, it cannot check if the inclusion proof that it gets
are actually from a valid chain.  They assume that the longest chain they know
is also a valid chain.  And, well, the more people are relying on that
assumption, the higher the incentive to break that assumption.  And with a ZK
light client, there is no incentive to mine an invalid chain because the light
client will validate the validity of the chain.  So, yeah, it makes no sense to
mine an invalid chain.

**Mike Schmidt**: You mentioned a couple other potential uses for these types of
proofs.  One is privacy on the LN being improved.  How would that work?  What's
the problem now, and how would a proof address it?

**Robin Linus**: Currently in the P2P gossip protocol, you kind of have to dox
yourself because you have to tell everybody about your UTXOs.  That is a measure
against DoS attacks so that you cannot announce channels that don't exist.  And
when you use ZK proofs, you could prove that you own some channels without
revealing which channels you actually own, and yeah, that would be great for
privacy.

**Mike Schmidt**: And what about proof of reserves or attestations?  That was
also mentioned in the paper as a use case.

**Robin Linus**: True, yeah, people have been thinking about that for quite a
while, I think, to use zero-knowledge proofs to do proof of reserves.  So, yeah,
that would be basically a by-product of valid chain state proof.

**Mike Schmidt**: And would that be, I can prove that I own a certain amount of
bitcoins, or I can control a certain amount of bitcoins, without revealing the
UTXOs involved?

**Robin Linus**: Exactly.  You could basically prove any kind of statement about
the UTXO set, both in plain setting and in zero-knowledge.  So you could prove,
"I own that many UTXOs and I held them for at least that amount of time".

**Mike Schmidt**: Go ahead, Lukas, did you have something to say?

**Lukas George**: No, that was exactly it.

**Robin Linus**: You could even prove that they are timelocked and you cannot
move them even if you wanted to.

**Mike Schmidt**: Pretty cool.  Will you speak a bit to what is zkCoins, and
maybe provide an overview to that?  It seems like it's building on this
technology, but it is something a bit different.  We've covered taproot assets
and RGB previously, it seems like it's in that similar vein of client-side
validated protocols.  Maybe you want to get into that a bit and how you differ
from those other protocols?

**Robin Linus**: Yeah, it is based on the fundamental idea behind Taro and RGB.
Yeah, that fundamental idea is client-side validation.  And in client-side
validation, there is not really global consensus, there is like local consensus.
When I send you a coin, I attach to that coin the proof of history validity or
like a proof of transaction history so that you, the recipient, you verify that
the entire history of that coin is actually correct.

What is great about that is that it removes a lot of burden of verification from
the main layer and shifts it offchain to the recipient.  And that is quite cool
because the recipient is actually the only one in the world who is incentivized
to actually validate the history of a coin.  The main problem with them has been
that the history grows quasi exponentially, because every transaction has at
least one input and on average it has more than one input.  So, if you walk back
in time, pretty quickly the history becomes mostly the entire history of all
coins, and yeah, that scales poorly.

But we can combine that with zk-SNARKs, zk-STARKs, and that is a great match
because it allows you firstly to compress the entire history into a constant
size proof, so no matter how long the history becomes, it will always be
constant size and very tiny; and on top of that, you get zero-knowledge, like
when you get perfect privacy, you can obfuscate both the transaction amounts and
the transaction graphs, and the onchain data becomes indistinguishable to
eavesdroppers, so you learn nothing about transactions at all.

**Mike Schmidt**: You also mentioned in the paper this notion of aggregators and
sort of aggregating data.  And it made me think, is that similar to what
OpenTimestamps does, in that it's sort of aggregating a bunch of data and then
putting it into the blockchain; is it something like that?  Can you explain
aggregators?

**Robin Linus**: I feel like the term "inscribers" would be a better term,
because they are inscribing commitments to CSV transactions into the blockchain.
And what's cool about that is that when you have those middlemen between you and
the blockchain, then you can make zkCSV transactions without having to have BTC.
So if I send you, for example, Tether or so, then you got like 10 Tether, but
you have no BTC yet.  So in conventional models, you would have to buy some BTC
first to pay Bitcoin fees to make a Tether transaction.  But if there's that
inscriber in between us, or in between you and the blockchain, you can just make
a Tether transaction and pay the inscriber in Tether, and then the inscriber
pays the Bitcoin transaction fees.

**Mike Schmidt**: I've somewhat monopolized the questions here; maybe open the
floor.  Murch, do you have some follow-ups?

**Mark Erhardt**: Yeah, so for the zkCoins, I first was wondering whether the
transactions you're talking about are essentially compressing onchain
transactions, but it sounds like it's more of a Colored Coin scheme.  This is
more in the wheelhouse of, say, BRC-20 tokens right now, just way more
efficient, private and better; or is this a way to compress onchain
transactions?

**Robin Linus**: Right now, without a soft fork, it would be just for stable
coins and stuff like that.  The best thing you could do is to mint a privacy
coin by burning bitcoins.  I think that would not introduce a shitcoin, but
yeah, you could at least have some kind of privacy coin on top of Bitcoin.  But
of course, all of that is quite unsatisfying.  In the long term, we hope that we
will have either like a zero-knowledge proof verifier on Bitcoin, for example,
within Simplicity, or some sidechain that can validate zero-knowledge proofs.
And both of that would allow us to pack Bitcoin into a zkCoin, and then we would
have much more throughput on Bitcoin and full privacy.

**Mike Schmidt**: Murch or Gloria, do you have other questions?

**Mark Erhardt**: You mentioned that it is currently not viable to produce the
proofs in the same amount of time that new blocks are produced.  So how long
until you can produce proofs quick enough to catch up with the chain tip?

**Robin Linus**: Maybe Lukas wants to answer again.

**Lukas George**: Yeah, I think this is a tough question.  So we have some
optimizations in mind, but the truth is that, yeah, proofing right now is very
expensive and blocks tend to get bigger, more transactions, more hashes that are
generally like 80% of the proofing computation, and yeah, now takes about four
hours for just a single block.  But we are confident in our optimization
techniques and there are still a lot left that we can implement and work towards
a reasonable amount of time.  I think ten minutes will still be tough, but we
have the option to parallelize the proofing for blocks so we can then prove five
blocks in parallel and then recursively verify them in the next step, and
therefore almost divide the time we need for every block by five or a constant
number.

**Robin Linus**: Well, you can also parallelize single blocks, like you can have
like batches of transactions, let's say ten transactions or so, and give them to
one person and then the next batch to some other person and then they can proof
in parallel, and then you aggregate all those proofs into one big proof.  And
what is required for that is mostly very efficient proof recursion, so you can
verify a proof in a proof to get a more succinct proof, or to combine two proofs
into one proof and do that recursively until you have a block proof for all
transactions.  And we think that this will give a huge performance boost.

Additionally, for the initial catch-up for proofing the existing about 800,000
blocks, we will use probably ASICs or FPGAs, or something, to do that in a
reasonable amount of time for the initial sync.  And then afterwards, it will be
much easier to keep producing new block proofs within ten minutes.

**Mark Erhardt**: Right, and of course the proof only has to be produced a
single time for the chain tip so after that it can just be distributed.

**Robin Linus**: Yeah.  And a very important point is that we might have FPGA
set up at the beginning and then people might be, "Hey, no, we don't want to
trust that single proofer", but that is not the case.  We just produce that
proof once and then we share it with the world and then everybody can extend
that chain proof, even if we die and never show up again.

**Mike Schmidt**: It sounds like there's a lot of work still to be done here in
terms of research and other work.  Is there a call to action that you'd have for
the audience in terms of your paper and maybe the space more broadly?

**Robin Linus**: I would say it's mostly engineering work.  I think the problems
that we have are solved on a theoretical level, and it's very much a matter of
engineering work.

**Mike Schmidt**: Any final words that you'd leave the audience with?

**Robin Linus**: But call to action, definitely if you want to join us, if
you're a developer, we are definitely looking for more people to join the
project.  If you're a sponsor, we are definitely looking for more sponsors.  We
are a Swiss nonprofit and we personally believe this is very valuable for the
Bitcoin community.  And if we are right that it's very valuable, then people
would probably sponsor it; and if not, we should probably work on something
different, but it looks like people are getting that this is a good thing for
Bitcoin and that it's important.

**Mike Schmidt**: Robin and Lukas, thank you for joining us.  You're welcome to
stay on if you want to comment on the rest of the newsletter or listen in.
Otherwise, you guys are free to jump off if you have other things to do.

**Robin Linus**: Yeah, thanks a lot for having us, it's a great honor.  Your
newsletter is probably one of the most reputable ones in the entire field.
Thanks a lot.

**Lukas George**: Yeah, thanks a lot.  The summary was almost better than our
paper, to be honest!

**Mike Schmidt**: It looks like we might have a question from the audience;
SovereignIndividual.  Well, maybe not.

_Waiting for confirmation #2: Incentives_

The next section from the newsletter is part of a weekly series we're doing.
The first one was last week, Waiting for confirmation; this is #2 on incentives.
To recap, last week we talked about mempool as a cache of unconfirmed
transactions that essentially allow users a way to send transactions to miners
in a decentralized way, and we're going to build on that thought process today
here.  And one of the authors of this segment, Gloria, is here to walk us
through her thought process on incentives.

**Gloria Zhao**: Yeah, so kind of following up on the two ideas that we
explored last week, one being it's just a cache, it's just a cash of unconfirmed
transactions; and the other being that we have this decentralized transaction
relay system.  So on one hand, we're like, okay, the first question you might
ask when you're talking about the cache in a computer is like, how do we measure
its utility?  We want it to be useful, so how do we measure the usefulness of
each item in this cache?  And of course the other one is, we're riding this wave
of high transaction volume, and so mempools can kind of serve as this
decentralized fee-based market for block space.  And then, let's see.

So we kind of start off this post with this idea that block space is scarce;
that's a good thing, we've probably been feeling its scarcity for the past few
weeks.  And because of the scarcity, the miners have to have some way of
deciding what goes into blocks.  And ideally, the fairest decision-making
process, or in the free market sense, hopefully this decision-making process is
just based on fees.  So mempool kind of serves as this public auction platform
where you can see what other people have bid, you can estimate what you might
need to bid in order to beat someone to get this block space, and we also talk
about a little bit about how mining, like block assembly works, at least in
Bitcoin core.

To my knowledge, miners are using the same algorithm; it's pretty good.  Murch
has done a lot of research and it's not the perfectly optimal algorithm.  It is
one that kind of relies on mempool caching being a thing, and then it's this
greedy algorithm.  And we have two examples of policies that we list in that
post; these two policies essentially help with the efficacy of this, again not
optimal, greedy algorithm, because selecting transactions to maximize fees and
to fit inside the sigop limit and the weight limit is an NP-Hard problem.

So, yeah, that's kind of the general overview.  I don't know if Murch, Murch was
the other author on this, if you want to elaborate on any of these things.

**Mark Erhardt**: I kind of wanted to bridge a little bit from the title of our
column to the content.  So why did we call this piece "Incentive"?  So the idea
is, of course, we want to have this big market for block space where everybody
can see what other people are bidding, where you can get your transaction
through by bidding the most; and that makes, of course, sense from the miners'
perspective, where the miners say, "We want to maximize the fees that we collect
in each block".  But it also makes sense from the users' perspective, because as
we already mentioned last week, block propagation is faster when we have all
transactions already that miners include in their blocks.  And also, when we fee
estimate, we base that on what we have seen in our mempools, so we want to have
the same things in the mempool, in our mempool, as the miners do in their
mempool.

As long as the mempools across the network are homogenous, we get the best
results, both for block propagation, fee estimation, we get the most informed
bids for ourselves, so the incentives are aligned in that regard.

**Mike Schmidt**: Gloria, you mentioned selecting transactions for a block due
to the limit on weight and sigops being an NP-Hard problem.  Can you try to
break down what an NP-Hard problem is?

**Gloria Zhao**: Oh, let me look up the Wikipedia page for NP-Hard problem.
Basically, a difficult problem.  So this is, if you're a computer science
person, this is two-dimensional knapsack.  Basically, NP-Hard means the only way
to, let's say you're given a mempool and you're trying to build a 4 million
weight unit block, and you're trying to figure out what is the absolute maximum
amount of fees that I can fit into this block and which transactions are those,
kind of the only way to figure that out is to try every single combination.
There are ways to try to do it better.  For example, what we'll do is we'll try
to sort by ancestor feerate and we'll select the best ones first.

However, of course, the best example of this is, let's say you have a
transaction that is extremely close to 4 million weight units, it's like that
giant taproot wizard for example.  Because we use a greedy algorithm, if there
is so much as one transaction that's like 100 vbytes that has a higher feerate
than that 4 MB one, we will select that tiny one first and then not have room
for the second-best feerate transaction in the mempool.

Of course, we can add logic to potentially swap out those transactions, because
in this situation, to you and me, it's very obvious that we should evict this
other transaction from our block template and put in this huge taproot wizard
that pays the second highest feerate.  But we're really concerned about
performance when we're talking about building a block template for miners, like
every millisecond counts, right, because you only get these fees if you win the
block.  And so getblocktemplate should be really fast, which is why we take
these "shortcuts", and we do things like we limit how big a standard transaction
can be so that we're not getting into these situations, where it's between this
gigantic high feerate transaction and swapping things out and stuff.

Did I answer the question?  It's a hard problem.  And so, we do pretty well by
limiting what transactions we're going to be working with and using this greedy
algorithm and picking by ancestor feerate.  Well, okay, no, okay, it's two
knapsack plus the extra complications of, you have dependencies between
transactions.  So for example, if one unconfirmed transaction spends another,
you have to mine the parent in order to mine the child, so this adds a layer of
complexity.  I probably should have said this in the beginning, I apologize, but
this is just to illustrate that it is a hard problem.  Murch has his hand
raised.

**Mark Erhardt**: Yeah, I think that you already mentioned the main point, which
is basically the problems trying to find the optimal solution for an NP-Hard
problem scales polynomially in the number of objects in the solution space.  So
for example, people might know that sorting is kind of, you have to compare a
lot of items in a list to sort something, but that scales with slightly more
than linear.  And polynomial means it blows up immensely.  It means that it
exponentially increases in workload to find the optimal solution.

So for example, in the case of a mempool that has over 1 GB of transactions with
500,000 different transactions queuing, we would have to find all possible
orders to make sure that we got the optimal.  The next block, we would have to
try all 500,000 transactions combined in any order, right?  So, you might
imagine how much work that would be if we tried to exhaustively search them.
So, we find that with the ancestor-based feerate selection, we do pretty well
already.  Clara and I published a write-up last summer about trying to do this
with an approach called Candidate Set Based (CSB) mining, where we tried to
cluster transactions that are connected first and find the best package from
that cluster to include in the block next.  We found that at least for the block
times that we tried it on, the best result was only 0.7% more fees than just
using the ancestor-set-based one, which is pretty quick.  So we're not finding
the optimal solution, but we're finding a good enough solution.

The whole problem gets much harder when the chunks that fit into the space are
bigger, because then you get sort of an effect towards the end with the greedy
approach that is called the tail effect, where some of the transactions might
not fit in anymore and you have to start swapping out.  By limiting ourselves to
transactions that are most one-tenth of the block, we limit when this tail
effect starts and we can just sort of throw up our hands after trying a bunch of
things and say, "Well, this is good enough"; whereas, if we allowed transactions
to be up to the full block size, we would immediately start with the tail effect
and then we would get into a situation where we actually have to try a huge
combination space of possible things, because we have to see it.  So, let's say
we take these five transactions but then nothing else fits in, and we have to
compare that to thousands of other transactions combining and taking that space
instead.

**Mike Schmidt**: Gloria or Murch, anything else that you'd like listeners to
take away from this week's post in the series?

**Mark Erhardt**: I'm good.

**Gloria Zhao**: I guess one tiny thing.  The ultimate goal of this series is to
help people building on top of Bitcoin, or using Bitcoin, to understand a little
bit better how things work.  I think people are probably in fee bumping vines
nowadays and seeking as many solutions as possible, and there are various
solutions out there.  Hopefully, people read this and start to demand better
wallets, as well as look at some of the inefficiencies in mempool.

So, I think the existence of out-of-band fee services can point to there maybe
not being efficient enough public auction bidding processes, or available tools
available in the public market, right?  And some of that, it's not necessarily
the case that we cannot improve, and this is one of the things that I really
wanted to communicate to the community with this series, is (a) demand better
wallets, build better wallets, and (b) let's work together as application and
protocol devs, or users and devs in general, to make this interface better for
everyone.  That's kind of my main message I wanted to finish off with.

**Mike Schmidt**: Dave, did you have a comment?

**Dave Harding**: I do.  I think this is a great session, I'm really glad that
Gloria and Murch are writing it, and I completely agree with everything that
Gloria just said that this is a collaborative effort, this is something that we
all need to work on, trying to get policy right so that it works for as many use
cases as possible, and also miners and nodes, relay nodes, making sure just
everywhere works together.

I had a question while I was listening to Gloria and Murch talk.  It's not
really a question, it's a crazy idea.  So it sounds to me like a lot of the
complications that we have from creating good policy today are kind of related
to ancestor mining.  Now, that's a really powerful feature to enable CPFP, and
there are people who want to build on it with things like transaction sponsors.
But what if we went the other way and just soft-forked out the ability to
include any related transactions in the same block?  So when a parent
transaction goes in a block, that block can't include any children.  So now,
it's no longer necessary to have ancestor or feerate mining, we don't need
package policies, sorry, Gloria.

Would that massively simplify things; would we be in a much better position to
have more flexible policies; or would there still be a lot of these underlying
problems?  I realize that package selection would still be an NP-Hard problem, I
just wanted to get Gloria's and Murch's quick takes on what would that simplify
if we didn't have the ability to have descendant transactions in the same blocks
as their ancestors?

**Mark Erhardt**: Do you want to take it first?  Okay, go ahead.

**Gloria Zhao**: This would make our lives so much easier!  Great idea, concept
hack.  This is basically where the thoughts for things like cluster mempool come
from.  Basically it's like, can we limit cluster size to one?  Yeah, it would
make things much, much easier.  That's kind of finally answered.  But we would
have use cases that are no longer available, of course.

**Mark Erhardt**: Yeah, exactly.  So this would make mempool way easier, it
would throw out a ton of DoS vectors, it would make block building massively
easier, it would probably encourage a lot of people to very quickly finally add
RBF support, because now that would be the only way to unstack transactions
since you clearly could not CPFP stuff anymore.  It would also introduce a bunch
of new design constraints on second-layer protocols and other ideas.

So for example, of course, you wouldn't be able to have a Lightning transaction
that is bumped by an anchor output.  The Lightning transaction would have to be
able to carry its own feerate.  Perhaps we could have, for example, on the
commitment transactions SIGHASH_SINGLE construction, where people can then add
additional inputs to provide the fees, and that way we could still have
Lightning channels that close.  But yeah, it would very much change a lot of the
design properties for things that are going on in the space.  But yeah, cluster
size one would be amazing.  Yeah, we could probably skip ahead a bunch of
protocol development efforts by, well, skip back in time and just not spend
years on them.

**Gloria Zhao**: Yeah, I think looking back when we remember a conversation with
someone else where it was like, "Oh, we should have started with maximum cluster
size one, or we should have started with you're not allowed to spend on
confirmed transactions in mempool", and then as use cases like Lightning opened
up, we'd be like, "Okay, how do we get two transactions in a mempool, or how do
we add trees to mempool?"  But instead, we kind of started with, "Anything's
allowed", and then we're like, "Oh, we can't handle this because of DoS".  So we
tried to add heuristics to restrict things, and then we find a difference
between what we can handle and because we have these heuristics, or we're not
handling things optimally, there's these pinning vectors or whatever.

Then basically, now we're trying to carve out what makes sense, and the vast
majority of clusters are of size one in mempool, according to the research that
you guys have done.  But of course now, if we were like, "All right, we're going
to change Bitcoin Core's policy to not allow ancestor packages or descendant
packages larger than two or one, or whatever", then it's like, "Okay, now there
are uses, there are still some people who are using this, so we cannot now add
the restriction".  But if we had started with maximum size one, that would have
been cool and maybe we wouldn't be in this situation, but we cannot go back in
time and change that.

**Dave Harding**: Thanks for the answers.  That's what I was thinking, to a
certain degree, but I'm glad to hear that I'm not completely crazy for thinking
that.  Thanks again.

**Mike Schmidt**: Next section of the newsletter is Changes to services and
client software, and we had

a slew of them this week, so we'll try to work through them fairly quickly.

_Passport firmware 2.1.1 released_

The first one is Passport firmware 2.1.1 released, and this is a new firmware
for the Passport hardware signer, and they add support for taproot addresses,
BIP85 features, and then some improvements and bug fixes regarding certain
multisig configurations and handling PSBTs.

_MuSig wallet Munstr released_

Next entry was about MuSig wallet being released.  I think this was a product of
a hackathon actually and it's beta software, so don't use real funds or use
sparingly, but this Munstr software uses Nostr in order to facilitate the
communication rounds required for signing MuSig multisignature transactions.
So, there's some communication that's required to do a MuSig multisignature, and
the way to coordinate that, or one way to coordinate that could be using this
Nostr protocol to pass the incomplete transaction around for folks to sign to
get that signature.  So, I thought that was a pretty creative product to come
out of a hackathon.  Murch?

**Mark Erhardt**: I also have to laud this project for having some of the
coolest artwork.

**Mike Schmidt**: Yeah, I mean you get a wide variety of output from these
hackathons, yeah, and they have a cool -- was it a Frankenstein, did I recall
correctly?

**Mark Erhardt**: Yeah, it's a Munstr!

_CLN plugin manager Coffee released_

**Mike Schmidt**: Next piece of software that we highlighted this week was a
Core Lightning (CLN) plugin manager named Coffee.  And Coffee, essentially -- so
CLN has these notions of plugins which augment the functionality of the
Lightning software.  And this plugin manager simplifies many of the aspects of
managing a plugin, everything from installation, configuration, and then
dependencies and actually upgrading the plugins themselves.  So it looked like a
cool project to me.

**Mark Erhardt**: Yeah, I was actually wondering, I think there is already a
package manager for CLN, is it Reckless, I think?  So, I was wondering how the
two fit together.  But it I think that the design approach or architecture
approach from CLN being focused on being package-based and plug-in-based is
already just conducive to a third party coming in and starting to develop a
plug-in manager that plugs into the plug-in architecture of CLN.  So this is
pretty cool.  I think this is a great way to get leverage on your own
development effort and getting the community involved.

_Electrum 4.4.3 released_

**Mike Schmidt**: Electrum 4.4.3 being released.  I think there was actually a
4.4.0, 1 and 2, which had most of these features in it and then some bug fixes
on top.  So I think the 4.4.0 release had these features, which is coin control
improvements -- I didn't say coin selection, Murch, are you proud of me? -- a
UTXO privacy analysis tool and support for Short Channel Identifiers (SCIDs).
Any comments there, Murch?

**Mark Erhardt**: Sounds great.

_Trezor Suite adds coinjoin support_

**Mike Schmidt**: Next thing we noted was Trezor Suite adding coinjoin support.
And so, there's a Trezor hardware device, but there is also the Trezor Suite,
which is a piece of software that interacts with that hardware signer, and they
announced support for coinjoins.  And I think specific to note here is that it
has to use the zkSNACKs coinjoin coordinator; that's actually a restriction of
the software.  So, not only can you not use other coinjoin protocols, but even
if you're using, I think this is the Wasabi-based protocol, you have to use that
one specific coordinator.  But it is nice to see coinjoins proliferating.
Murch?  Thumbs up.

_Lightning Loop defaults to MuSig2_

Next piece of software that we noted was Lightning Loop defaulting to MuSig2.
So Lightning Loop is a swap provider between onchain and Lightning bitcoins, and
they now default to using MuSig2 as the default swap protocol.  And the benefits
there are lower fees and also better privacy.  Murch, did you get a chance to
look into this one?

**Mark Erhardt**: I have not looked into it specifically, but so the idea is
that they use submarine swaps and submarine swaps are essentially a Hash Time
Locked Contract (HTLC) that is executed onchain to either move coins from the
chain into a Lightning channel, or vice versa to pay out a Lightning transaction
into an onchain output.  And, the idea here is, of course, that onchain
transactions can benefit from MuSig to reduce the input size, and that makes the
submarine swap have a lower block space footprint so it'll save the customer's
money.  Oh, and it'll look more private too because it's indistinguishable from
a single input transaction.

_Mutinynet announces new signet for testing_

**Mike Schmidt**: The folks at Mutiny, who I think we've covered previously in
this monthly segment on the wallet work that they've done, they have something
separate from their wallet, which is this Mutinynet, which is a custom signet.
So it's a signed testnet with 30-second block times, and they include a bunch of
testing infrastructure as part of their custom signet.  So they have a faucet to
get some coins, they have a block explorer, and then they have a bunch of LSPs
and Lightning nodes running on this network.  So I think this accelerates some
of the testing that they were doing, and they made this public so that other
folks could also benefit from some of this infrastructure.  Murch?

**Mark Erhardt**: Yeah, that makes sense.  I mean, if you're trying to build a
Lightning wallet and you're frequently opening and closing channels, then
waiting for confirmations may delay your tests.  But on the other side, I think
there were some interesting critiques brought up in there.  They opened a
related pull request to Bitcoin Core requesting that there would be a feature to
have signets with custom block times.  And one of the pushbacks was, if people
get used to testing on signets with way faster blocks, they may be unconsciously
or consciously optimizing for a network that doesn't have the properties of the
Bitcoin mainnet, and the product will be poorer for it.

So, people recommended to them that they would keep their testing infrastructure
aligned with the Bitcoin network behavior, because it would otherwise perhaps
inform their development efforts incorrectly if they stop, for example, thinking
of the UX of having to wait for confirmations in their setup of their Lightning
channels, and things like that.  So, I thought that the debate around this new
signet with the very quick block interval spawned some interesting debate and
thoughts on that.

**Mike Schmidt**: I hadn't seen that debate.  I'm not sure how much I agree with
that, but I'm glad folks are talking about it.

_Nunchuk adds coin control, BIP329 support_

Next item is Nunchuk adding coin control and BIP329 support.  So, Nunchuk has an
Android and iOS mobile wallets, and they added coin control features, as well as
BIP329, which is something we've covered in a previous podcast, which is the
ability to export wallet labels so that you have some context as to different
addresses and transactions and being able to label those accordingly.  Any
thoughts, Murch?

**Mark Erhardt**: No, all good.

_MyCitadel Wallet adds enhanced miniscript support_

**Mike Schmidt**: MyCitadel Wallet adds enhanced miniscript support.  So, in
their latest v1.3.0 release, the MyCitadel folks added more complicated
miniscript capabilities, and something notable I thought there was timelock
capabilities.  You can jump into the release notes for that v1.3.0 release to
see exactly what kind of complicated miniscript you could be doing in there, but
I thought this was a noteworthy adoption of Bitcoin tech.  Murch?

**Mark Erhardt**: Yeah, I thought it was super-interesting.  So, I was in Miami
last week and I saw no less than three or four different software demoing
miniscript capabilities, and just from the perspective of this starting out as
an effort from protocol development, with the idea of being able to put
miniscript support into, well, P2TR script leaves, and then now this getting
adopted broadly by wallet developers that want to surface the capability of
making more complex scripts easily, is super-cool.  And so, some of the
interesting applications that I've seen there is, of course, being able to build
in decaying multisigs, or to have built-in inheritance planning.

I saw a demo where somebody had basically a drag-and-drop graphical editor for
output policies and, yeah, there's some really cool stuff going on there.  All
of our wallets will be so much cooler in the next few years and it will be so
much easier to set up your own wallets.

_Edge Firmware for Coldcard announced_

**Mike Schmidt**: The last item from this monthly segment about changes to
services and client software is Edge Firmware for Coldcard announced.  So the
Coinkite folks, who produced the Coldcard hardware signing device, announced an
experimental firmware that's targeting really wallet developers or power users
and allowing them to experiment with newer Bitcoin tech features.  And so, this
initial release of this experimental firmware includes taproot keyspend
payments, some tapscript multisig payments, and BIP129 support, so I thought
that was pretty cool.  I'm not sure if that was something that they were passing
around internally and to known wallet software and then they made it public, or
if this is a new effort, but it's definitely public now.  Murch, any thoughts?

**Mark Erhardt**: Well, I kind of pre-empted that with the previous statement.
Here again we see people working on tapscript, and yeah, I think it'll still
take -- so, the big problem with these big protocol development pushes is that
it takes years to get out the protocol change in the first place, but then it
takes another year or two for the new capabilities to arrive in the wallet
space.

So for example, in winter, we saw some people be like, "Well, taproot was a huge
nothing burger.  It's been a whole year that it's activated already and nobody
is using it.  There's nothing cool coming out of it", and so forth.  And now,
another half a year later, we're starting to see people build products around
taproot.  We're seeing people build on Frost with new hardware wallets; we're
seeing people come out with miniscript that leverages both the native segwit v0
output capabilities, but also experimental support now for tapscript, which is
not completely finished yet.  For example, in Bitcoin Core, we can only use
miniscript with native segwit v0 so far.

But yeah, the release cycles, or also just the time until the protocol efforts
trickle down to the end user are just so much longer than everybody expects, but
it is coming and it's really nice to see that and be reminded of that.

**Mike Schmidt**: Yeah, it's a great point.  We went through this list and we
had taproot support being added, we have a couple different additions related to
MuSig, and yeah, it always takes longer than you think and I think it's a good
perspective to point that out.

_Core Lightning 23.05_

Next section from the newsletter is Releases and release candidates.  First one
is Core Lightning 23.05.  We've been sort of teasing some of the features that
were coming in this release with some of the release candidates, including v2
PSBTs and flexible feerate management and blinded payments.  Murch, I don't know
if there's anything else that we want to jump into in this recap?

**Mark Erhardt**: I just noticed that there's also some improvements on fee
estimation and for CLN in this release.  And I think it's kind of funny how
there's a lot of things that everybody knows they need to have in their wallet
software, but they're also on the, "we can do that next month" list.  But then
we get these bouts of extreme block space demand and suddenly people have
features for RBFing, for CPFP, for fee estimation and consolidations, and that
sort of stuff, pop back up to the top of the list and get them done.  So, yeah,
I think we're going to see also this across a bunch of other wallets.

**Mike Schmidt**: Yes, similar to the last time these waves kind of came in, I
think exchanges weren't doing batch withdrawals, and all of a sudden that was
all done within a short period of time; and now we have this next wave, and now
you have big exchanges posting that they're going to support Lightning and some
of the fee bumping stuff that you mentioned as well.  So, I guess some of the
stress occasionally is good to nudge people in that direction.

**Mark Erhardt**: Yeah, I think that's maybe also a call back to our mempool
column earlier.  One of the reasons why block space should remain constrained is
that we are pushing people to make the most with a limited resource, and it
really makes people more creative and inventive and pushes wallet development
and protocol development to build for a future, where a lot more people are
going to try to use these limited resources.  And even if we very eventually do
decide to increase the block size, we will have all these tools to make the best
use of the still limited block size.

**Mike Schmidt**: We're talking about block size increases, we're talking about
soft forks today; it's going to be controversial on social media!

_Bitcoin Core 23.2_

_Bitcoin Core 24.1_

Murch, we talked about these maintenance release candidates last week for
Bitcoin Core, and now they're out.  The 23.2 and the 24.1 maintenance releases.
Do you want to jump into any of that in this discussion?  Oh, Gloria; Gloria
wants to jump into it.

**Gloria Zhao**: I just wanted to say, this wouldn't have made it into the
newsletter, but we just had 25 today, new major release.  Would recommend
updating.  And I also want to say that Bitcoin Core has put out three releases
in the last two weeks, mostly in response to the high transaction volume that
started two or three weeks ago.  So, I never want to hear people saying Bitcoin
Core moves too slowly ever again!

**Mike Schmidt**: Gloria, do you want to give a headline of what was addressed
in that short time period for these maintenance releases relating to fees?

**Gloria Zhao**: I don't want to give too many details.  So, if you notice that
your Raspberry Pi is seeming like a fire hazard in your apartment, it has a lot
to do with the volume of transactions on the network.  There are some, let's
say, inefficiencies and, yeah, it was pretty CPU intensive and now that's been
made much more efficient.  That's also coupled with, we were seeing some
malicious actors messing with block relay completely separate from the
transaction volume.  So would recommend updating, but I would recommend 25 as
the best thing to upgrade to if you're going to restart your node.

_Bitcoin Core 25.0rc2_

**Mike Schmidt**: Segueing into 25, Gloria, I know there was a PR Review Club, I
think it was yesterday, and I believe that the topic was going through sort of a
testing guide for 25.0.  I think we had Andreas on, who created the 24 guide to
testing.  Do you want to plug that and comment on that, even though the release
is already tagged?

**Gloria Zhao**: Yeah.  So with 24, for example, we cut 24.0.  And then within
like 24 hours, somebody found a bug that definitely needed to be fixed.  Of
course, it happens, and we ended up tagging 24.0.1, but ideally we catch it
while we're doing the RCs.  And so, yeah again, my main message when I'm coming
onto these Twitter Spaces is like, this is a collaborative effort, it's not the
devs over there are figuring out how to make Bitcoin Core work and then they're
shipping it to us, we're all users of Bitcoin and we all do better when the
software is working well.

So, highly appreciative of the Optech Newsletter putting out release candidates
every week, or publishing the fact that there are release candidates, and
testing them is very important.  Yeah, that's kind of it.

**Mike Schmidt**: Murch, any comments on the maintenance releases or 25.0?

**Mark Erhardt**: I just wanted to note, so for people that build on Bitcoin
Core for their enterprise software, the release candidates, or rather the
releases with the point releases, like 23.2 and 24.1, those only backport bug
fixes.  So if you want to leave a little time for 25 to be out and not upgrade
to a version with new features, you can of course just upgrade to the point
releases.  And yeah, if you're just running a node that's unassociated with
funds and unassociated with new software, please feel free to upgrade to 25 to
help us test it in production.

**Mike Schmidt**: Last section of the newsletter is Notable code and
documentation changes.  We have a few of those.  I'll take the opportunity to
solicit from any listeners; if you want to request speaker access, if you have a
comment or question on anything we've discussed today, now's the time to do that
and we'll get to that after we go through these PRs.  Likewise, you can respond
to this Twitter Space thread and you can type out something if you don't feel
comfortable with speaker access.

_Bitcoin Core #27021_

First PR is Bitcoin Core #27021 and, Murch, I believe you did the write-up for
the newsletter and you are also the author, so I would be foolish to not give
the floor to you to explain this.

**Mark Erhardt**: All right, so this PR is the first of two PRs to address a bug
that we've had since four-digit issues, which was like six, seven years ago, and
that is, when we build transactions with unconfirmed inputs, we may
underestimate the target feerate in our new transaction if we're spending
unconfirmed inputs that have a lower feerate parent transaction.  So, if the
parent transaction has a lower feerate than the new transaction we create, we're
obviously creating a CPFP; and if we don't estimate how much fees we need to add
to bump the parent, we're creating a CPFP transaction whose package feerate is
going to be lower than what we intended to target with the new transaction.

To that end, we have to find out how much fee to add to our transaction in order
to bump our ancestry to the same feerate, and that turned out to be way more
complicated than in our first approach.  It took us three approaches.  I've had
a lot of help with this PR from Gloria and Andrew Chow and a ton of reviewers.
So, this PR mini-miner allows to address any possible ancestor sets.  We
calculate which transactions will make it into the block before our target
feerate, and then from the remaining transactions that are left, we can
calculate exactly how much sats you add to the child transaction.  And we can
then, in the follow-up PR that I'm still working on, use this in our transaction
building to correctly assess fees, to automatically bump parent transactions,
and hopefully to get a smooth sailing experience whenever we are forced to use
unconfirmed.

Note that Bitcoin Core, of course, tries to not spend unconfirmed inputs in the
first place, so if you have funds that are confirmed, they will get used first.
And, yeah, so this has been a pretty interesting one to work on.  Took us three
tries, 15 months to go back and forth and repeatedly work on this one.  So yeah,
pretty happy that got merged last week.

**Mike Schmidt**: Congrats, Murch.  Gloria, you were a reviewer and
collaborator, did you have anything to add to this PR?

**Gloria Zhao**: We are now the authors of something that starts with mini, and
we are not Peter!

_LND #7668_

**Mike Schmidt**: Next PR is LND #7668, adding the ability to associate up to
500 characters of text with a channel when opening it and then allowing the
operator to retrieve that information later.  Digging into this PR just
slightly, it really is a note to yourself about why you opened up the channel.
It's only ever stored locally and it in no way impacts how the channel operates.
So it's similar to what we were mentioning earlier with the wallet labeling,
except for you're labeling the channel.  Murch, any thoughts?

**Mark Erhardt**: I mean, I wish I could do that with Twitter users.  I often go
to conferences and then I add people.  And then months later, I see that I'm
following someone and I don't remember who it was because their username might
be completely unreflective of their actual name and they use some picture
instead of their face.  So, I wish I had that on Twitter too.

**Mike Schmidt**: Well, maybe after Elon fixes our weekly Twitter Space issues
with this Optech podcast, maybe then he can get to adding memos into follow
requests.

_LDK #2204_

Next PR is LDK #2204, adding the ability to set custom feature bits.  I think it
was in Newsletter #250 that we covered a similar PR to LND.  And as a reminder,
the setting of feature bits allows you to communicate to peers what additional
or optional LN features your node supports.  And so, this is a way for you to
set those and then also understand peers' announcements as well.  Murch?

**Mark Erhardt**: Yeah, I think that came about in the context of being able to
write plugins that sort of handle parts of your node interactions.  So for
example, if you had a plugin that pre-empted the processing of a channel
announcement and did some additional checks on it, and then maybe, for example,
allowed dual funding or, well, that didn't make sense in the context of how I
led up to that.  But if you have custom features or if you, for example, open up
your Lightning Node to have multiple users, so keys need to be retrieved from
elsewhere and signatures need to be made by other parties or anything like that,
you could sort of surface these capabilities and feature bits through this
avenue.  So, this is more of a developer update here.

_LDK #1841_

**Mike Schmidt**: LDK #1841.  This change addresses a potential pinning attack
that was addressed by a recommendation in BOLT5 previously.  And BOLT5 covers
the Lightning-related recommendations for onchain transaction handling.  And the
LN specification allows multiple HTLCs that were pending at the time a channel
was unilaterally closed to all be settled in a single transaction, but there's
some scenarios, namely when your outputs may pay your counterparty, which would
allow them to pin this justice transaction.  And so, the recommendation from the
BOLT was to continue to allow that batching for efficiency purposes, but when
it's getting close to the time left to the expiry, it's to split those HTLCs
into separate transactions close to when that timelock expiration is happening,
so that the pinning isn't as much of a problem.

I think that the BOLT recommendation was 18 blocks, but digging into this, it
sounds like the implementations are potentially doing much larger blocks in
terms of that threshold at which you would go from batching those closes to
individual ones to prevent the pinning.  Murch?

**Mark Erhardt**: Nothing to add from me.

_BIPs #1412_

**Mike Schmidt**: Final PR this week is to the BIPs repository.  It's #1412 and
it updates that wallet label export BIP that we spoke about earlier, BIP329, and
it adds an optional new field to the wallet export, which stores key origination
information.  And, that key origination information is a BIP380 abbreviated
output descriptor that describes a BIP32-compatible originating wallet.  And the
motivation for this change seems to be a concern about disambiguating
transaction labels from different wallets that would be in the same export,
which is particularly useful when you're exporting multiple accounts, or you're
doing an export where there's multiple accounts derived from the same seed; at
least, that was my understanding of the motivation.  Murch, did you get a chance
to dig into this one and the motivation?

**Mark Erhardt**: I think you explained that right.  So Sparrow Wallet, the
author of this change to the spec, has a very nice wallet that, or Sparrow
Wallet is a very nice wallet that especially surfaces the ability to have
multisig setups quite easily.  And in that context, I could see how being able
to have more labels and tracking on where keys were generated and how they
belong together would be super-helpful, just as a human, to be able to keep
track of multiple wallets, which you would probably set up if you use a cool
wallet like Sparrow.  As you can tell, I'm a pretty big fan since meeting Craig
two weeks ago in Nashville!

**Mike Schmidt**: Well, that's it for the newsletter this week.  I don't see any
requests for speaker access for comments or questions.  So, Murch, any
announcements before we jump off?

**Mark Erhardt**: Nothing from me.

**Mike Schmidt**: Excellent.  Gloria, anything before we jump off?

**Gloria Zhao**: No.

**Mike Schmidt**: All right, well thanks everybody for joining us.  Thanks to my
co-host, Murch, as always; thanks to Robin and Lucas for joining us; thanks to
Gloria for joining us; and thanks to Dave for chiming in.

{% include references.md %}
