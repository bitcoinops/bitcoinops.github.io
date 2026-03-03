---
title: 'Bitcoin Optech Newsletter #352 Recap Podcast'
permalink: /en/podcast/2025/05/06/
reference: /en/newsletters/2025/05/02/
name: 2025-05-06-recap
slug: 2025-05-06-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Sjors Provoost discuss [Newsletter #352]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-4-9/399945938-44100-2-1e203ed9d64d3.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mark Erhardt**: Hello and welcome to Bitcoin Optech Newsletter Recap #352.  My
name is Murch and I work at Localhost Research, educating about the OP_RETURN
drama.  Today, I'm joined by Sjors.  Sjors, would you like to introduce
yourself?

**Sjors Provoost**: Yes, hello I'm Sjors Provoost, I work on Bitcoin Core, based
in the Netherlands.

_Comparison of cluster linearization techniques_

**Mark Erhardt**: Cool.  Today, we have two news items, one Release candidate
and four Notable code and documentation changes.  We'll jump into the news.  The
first news item is about a comparison of cluster linearization techniques.  If
you have been listening before, you probably heard us report on cluster mempool.
And Pieter Wuille had been talking a lot about how to best find the correct
order or the best order of a cluster.  We reported on this before, when out of
the Bitcoin Research Week in November, a new approach was found that was more
efficient than the original currently implemented cluster mempool linearization
algorithm.  And then recently, we reported on this in Newsletter #340, about 12
weeks ago.  Another researcher pointed out that they found a paper from the '70s
that described an algorithm that should be able to be used in the cluster
linearization.

So, Pieter went down this rabbit hole and evaluated all three approaches, the
original candidate set search algorithm; and the spanning forest linearization
algorithm that came out of Bitcoin Research Week, when people realized that it
could be described as a linear programming problem and all the knapsack solvers
and so forth would be applicable; and then now, as the parametric min-flow-based
algorithm by Gallo, Grigoriadis and Tarjan or GGT.  Yeah, so he goes into a
bunch of details in this Delving post and finds out that he wants to use the
spanning forest linearization, because it can be interrupted anytime.  The
longer it runs, the better the result gets, but any intermediate state will be a
decent or improving state and can be used immediately as a linearization.  And
other than the other two algorithms, it doesn't require budgeting, because you
can just allocate a certain amount of time for each cluster and fairly compute
and distribute your computation power between the clusters.

So, it seems to be slightly faster than the other two approaches, or slightly
faster than GGT, and much faster than candidate set search.  And, yeah, there's
more discussion on this Delving thread.  Several other developers or interested
parties asked questions that are discussed.  And, yeah, there will also be a
talk at BTC++ tomorrow.  So, for the people that really want to dive deep, they
could try to get a copy of that talk sometime soon probably.  All right.
Anything from Sjors on this one?

**Sjors Provoost**: Yeah, so I mean first of all, I think cluster mempool is
pretty cool, but in practice I'm only following it from a distance, because I
think it will be somewhat helpful in Stratum v2, where what we want to do is
basically push templates out to miners as soon as they're better.  So, of
course, when a new block comes in, you want to give miners something new to work
on.  But also, if you have better fees in a mempool, you also want to give
miners a new block.  And the question of, "Are fees better in a mempool?", right
now is kind of tedious to ask.  You basically just create a block and then
compare it and like, "Yeah, it's better".  But with Cluster Mempool, we can
probably answer this question much faster, though there's some hairy details.
Like, you created a block template before, so you know exactly how many fees are
in there.  But as you just described, there's all these little algorithms that
can further and further optimize the block.  So, you may get two numbers.  One
is like, "We know for sure that there's this much fees in the block", but there
could be more because the algorithm is still working on it.  So, then the
question is, when do you decide to send out a new block to the miners?  Do you
do that when the worst case is better, when the best case is better, stuff like
that.  But I'll worry about that when there's some code I can actually use.

**Mark Erhardt**: Right.  Yeah, so one of the advantages of cluster mempool will
be that block template creation should be much faster, as you can sort of divide
up the problem.  You first sort all of the clusters, which are just the groups
of transactions that are related to each other through parent and child
relationships.  And because you already know the best order for every cluster,
it is very easy to assemble a block-size chunk of transactions from the top by
merging the best parts of various clusters to get the block template.  And,
yeah, once you have the block template, it's very easy to compare whether it's
better or worse, because you see exactly how many fees you will collect with the
block template.  But of course, you still have to run the block template
creation in order to make a reliable comparison.  Yeah, cool, okay.

_Increasing or removing Bitcoin Core's `OP_RETURN` size limit_

Let's get to the second news item, which might come as a big surprise to
everyone right here.  The second news item is, "Increasing or removing Bitcoin
Core's OP_RETURN size limit".  So, the history for this one is that one
developer proposed on the mailing list that it might be time to revisit the
question of whether the OP_RETURN limit should be dropped.  The email cited
especially that there was another use case of using Bitcoin's blockchain for
data availability that would be writing data to public key hashes, which then,
because they're unspendable, live in the UTXO set forever.

**Sjors Provoost**: Can you add this to public use, as this taproot?

**Mark Erhardt**: Okay, sorry, public key instead of public key hashes, yes.
The idea was if we had slightly larger OP_RETURN outputs and those were
standard, maybe the about-to-launch rollup could instead write to OP_RETURNs,
which then would be able to hold the entire data that they need to make quickly
and reliably available.  This discussion progressed a bit on the mailing list.
There were several people that thought it was a good idea, or that the OP_RETURN
limit was no longer timely, and Peter Todd opened a PR to the Bitcoin Core
repository.  This pull request was then quickly discovered by someone who
represented it as opening the door to more spam and turning Bitcoin into a
shitcoin, making it an altcoin, doing away with Bitcoin being only for payments.
And this led to, let's say, a heavy involvement of the community in the PR.  So,
far so good.  Sjors, any thoughts?

**Sjors Provoost**: Yeah, it may be useful to go back a little further into
history because this debate is, I think, at least 11 years old.  Like, 2014,
there's a BitMEX research blog post called, "The OP_RETURN Wars of 2014", which
kind of suggests that this stuff was behind us.  And that's probably also why
maybe some people get the wrong impression when they think Bitcoin Core is just
proposing this out of the blue.  It's not, it's one of those things that have
been simmering for a decade and this seemed like a good time.  But if you're not
aware of that previous discussion, it can come as a surprise.

So, back in the olden days, there was something called Counterparty, I think
they were the first ones.  They started doing NFTs, that's what we call them
now, basically NFTs on the blockchain, the Rare Pepe, that sort of stuff.  And
they were initially, I believe, encoding their pictures and other data as fake
public keys.  This is basically in the bare multisig, so you would create a
1-of-3 or 3-of-3 multisig signature and all of the keys would be fake.  And you
would basically put them all in the output of a transaction.  This was quite bad
because unspendable keys means that they're going to stay in your UTXO set.  And
so eventually, people were like, "Okay, can we mitigate, can we convince them
not to do this?" and the solution then was to make OP_RETURN standard.  So,
OP_RETURN has existed since the beginning, it's part of consensus, you can make
them as long as you want according to the consensus rules, but they wouldn't get
relayed.

So then, I think initially the compromise was, "Let's relay 40 bytes", because
that would be enough to do at least a hash of whatever they wanted to do,
instead of the whole picture basically.  And then, well, there was a bunch of
discussion on the mailing list, probably also on GitHub, whether this limit
should be 40 or 80, and it was kind of based on the merits of the use case.  So
like, "Okay, a commitment should just be 32 bytes plus a little bit more, so why
do you need 80?"  And then eventually, I think that the conclusion was 80 is
fine.  I believe Bitcoin Knots very early on already made it 40, but that's up
to everyone, but noticed that people were still sometimes using these bare
multisig things, because the way Counterparty was then designed was to say,
"Okay, if we need less than 80 bytes, we'll use OP_RETURN.  If we need more,
we're going to use these bare multisig, this pattern".  And so, this came back a
few years ago in the form of Stamps, which was basically using Counterparty.  It
was basically, they were marketing it as provably unprunable, that sort of
nonsense.

So, they used Counterparty, which as far as I know is completely unmaintained,
but it has this property of creating bare multisigs if the payload is more than
80 bytes.  And so, they basically deliberately made payloads that were bigger
than 80 bytes, namely jpegs, and started growing the UTXO set at a very worrying
pace.  It was already made clear there was not much you can do about it, because
even then, if we had increased the OP_RETURN limit, we could have dropped the
OP_RETURN limit back then, and we could have told the stamps people, "Hey, why
don't you just use OP_RETURN instead of these large multisigs.  And then, they
probably would have said two things.  One is, even if we wanted to do it, we
can't, because nobody is maintaining this software, so we can't modify
Counterparty to just always use OP_RETURN.  And even if we could modify it, we
don't want to, because the whole point is to make it pollute the UTXO set.  So,
in that case, you could say, "Well, then maybe there's no point in raising the
OP_RETURN limit".  But that was not the only thing that happened, of course.
What to do more?

**Mark Erhardt**: I think this is a good point to jump in with another thing
that I wanted to raise.  What is mempool policy versus consensus?  You mentioned
it already in your description, but do you want to take it?

**Sjors Provoost**: Okay, yeah.  So, consensus means if you're validating the
blockchain just looking at blocks, that's the rules you can enforce.  Whereas
the mempool and policy basically means, "Am I going to relate this stuff or I'm
going to put it in my own mempool.  And if I put it in my own mempool, I'll send
it to my peers".  Those are generally the same thing.  So, generally, the rules
for the mempool are more strict than the rules for consensus.  So, you may not
relay things, but if they're in a block, you'll accept them anyway.  Which
means, if you want to get something in a block, you'd have to go directly to a
miner.  That used to be somewhat of a barrier, but that's definitely not a
barrier anymore.  There's all these accelerators out there, there's even people
that are running with more permissive mempools for the sole purpose of relaying
this stuff.

**Mark Erhardt**: Right, sorry, you had another point that you wanted to add
regarding the history?

**Sjors Provoost**: Yeah, the stamps I think was an example of an actual
adversarial user that had as a purpose to pollute the UTXO set.  But a case like
the Citrea whitepaper, that was brought up in this mailing list post that we
started with, is a case of a company using this technique of bloating the UTXO
set because standardness wasn't enough for them.  They wanted to be on the safe
side, but they would be open to using OP_RETURN probably if it was made
available to them.  So, there, I think it does make sense to increase the limit.
Now, in their case, increasing it to 150 bytes or so would be enough, it doesn't
have to be dropped entirely.  Which then gets you into discussion of, "Okay, if
we're going to increase it to 150, do we really want to have this debate every
time?"  But what I think is more important to say is that they don't seem to be
price-sensitive.  If you just look at how that protocol works, and I don't
pretend to understand it, they need to put this 140-byte zero-knowledge proof on
the blockchain, they need to make absolutely sure that it ends up on the
blockchain on time.  And if that costs them $1 million, well, that might be too
much.  But if it costs them like $100, that's probably fine.

So, just by giving them a discount by making OP_RETURN bigger, that's not going
to motivate them.  It's really just about you give them the option and say,
"Please use this because it's nicer".  So, they don't necessarily want to
destroy Bitcoin, but also, there's no monetary incentive.  Whereas in the
original days with Counterparty, I think there was an economic incentive for
them to use OP_RETURN instead of the bare multisig, because it just made their
life easier and there weren't any of these accelerators.  So, we just lived in a
very different world there.

**Mark Erhardt**: Right.  So, let's very briefly recap that.  Citrea is some
ZK-Rollup.  It produces transactions in some second-layer scheme, and then it
anchors into the blockchain, into the Bitcoin blockchain by writing these proofs
into the Bitcoin blockchain.  They have come up with a scheme that is
consensus-valid and uses standard transactions right now, aka transactions that
would be accepted by the default mempool policy of most Bitcoin Core nodes that
are deployed today.  And basically, the idea was, "Hey, if we increase the
OP_RETURN limit a little bit, we, as a Bitcoin community, could ask them, 'Could
you please not write into the UTXO set, and instead use this OP_RETURN output to
write your data into an output, that we can at least ignore safely after
processing the transaction?'"

Yeah, so I think we've covered what mempool policy is.  We've set the background
with the example of Citrea.  And now, you said they would need about 150 bytes
for their proof.  I think it's 80 bytes plus two times 32 bytes, so 144.  So,
what happens at that point?  What's the interesting thing right around that
number of bytes?

**Sjors Provoost**: Well, yeah, so far, you could say this discussion might have
been very similar to the 40 versus 80 bytes thing.  It's a bit of a discussion
about what's more useful, but already from a weaker negotiation point of view,
because they're going to do this thing anyway.  But the elephant in the room,
which we haven't talked about, is inscriptions.  And inscriptions came around, I
think it's two years ago now?  I forgot, time flies.

**Mark Erhardt**: Yeah, 27 months or so.

**Sjors Provoost**: Somebody, for some reason, many, many years after segwit
activated, and even many years after taproot activated, realized that you can
stuff 4 MB of crap in the blockchain without violating standardness rules, by
using the witness, using a pattern.  Basically, I think you say OP_IF, or with a
zero in front of it, which means it's false, so anything after OP_IF is not
executed and then you just put your data there, and then you put OP_ENDIF,
something like that.  Now, you could have done this with segwit in a slightly
different way, but it doesn't matter.  So, once they found out, created a whole
hype around it, people got angry.  Of course, that angriness is part of the
marketing.  And since then, blocks have basically been full.  There've been
waves of worse and less bad.  This coincided with the Stamps story I just told
you.  So, that was sort of a reaction like, "Oh, these inscriptions might be
pruned.  Let's just put things in the UTXO set".  But that, I think, died, maybe
not.

**Mark Erhardt**: I believe so, yeah.

**Sjors Provoost**: So, then you're looking at, "Okay, why are we still doing
this OP_RETURN limit thing, because it's not going to make blocks smaller?
They're going to be 4 MB now, so what's the point?"  It's just even a slight
motivation for people to start adding things to the UTXO set again.

**Mark Erhardt**: Let me jump in there very briefly.  You said, "It's not going
to make blocks smaller", which is funny, because of course the witness data is
discounted by 75%.  So, only if you have a lot of witness data, you can have
blocks that are much bigger than 1 MB.  For all the other data that is not in
the witness, the old limit holds and the bytes there come in at full weight.
So, if we write data to output scripts, like OP_RETURN does, those bytes are not
discounted and count fully towards the 1-MB limit, or I should say count as 4
weight units towards the 4 million weight unit limit.  And that means OP_RETURNs
do make the block smaller.  More OP_RETURNs means less witness data and smaller
blocks.  Sorry, please continue.

**Sjors Provoost**: But they'd be four times more expensive per byte.  No, I
mean, that's where we were two years ago.  And so, I believe also Peter Todd at
the time just decided to open a PR and said, "You know, this is pointless.
Let's just drop this OP_RETURN limit".  That created a whole bunch of drama, and
eventually that PR was abandoned based on some sneaky math, not sneaky math,
just some amazing math by you.  So, maybe you want to explain that math.

**Mark Erhardt**: Yeah, basically, an OP_RETURN requires that you create another
output.  Adding another output to a transaction means that you need to have an
amount field, which is 8 bytes.  Then, you need to have a byte that indicates
how long the output script is.  And then, in the output script, there's 2 more
bytes of overhead and the OP_RETURN opcode itself and then a pushdata opcode
that indicates how long the data payload is.  And so, at least 11 bytes of
overhead; for longer messages, it would be a bigger overhead, because the
pushdata can get bigger.  But anyway, so you only have 11 bytes of overhead for
OP_RETURN.  For inscriptions, you have a lot more overhead, because you have to
create an output that commits to the inscription.  And then, in the input, you
have to have a scriptpath spend and have the construction that Sjors described,
which the inscription enthusiasts call 'envelope'.  And overall, I think the
overhead for that is, I don't remember from the top of my head, but something
like 50 vbytes or 60 vbytes.  So, altogether, the more overhead means that a
small message in an inscription is more expensive than a small message in an
OP_RETURN.  But then, because the witness data is discounted by a factor 4, over
time or as the payload gets bigger, it becomes cheaper to use an inscription for
the data instead of an OP_RETURN.

Now, my calculation back then might have had a mistake, because Vojtěch Strnad
recently redid the calculation and had a different result.  But we agree that
roughly around 144 bytes or 143 bytes, the data payload becomes cheaper to do on
an inscription, and at smaller amounts it's cheaper to do an OP_RETURN.

**Sjors Provoost**: There was a range between 80 and about 140, depending on how
you do the math, where it was still cheaper to do it in OP_RETURN than to use
inscription.  So, just dropping the OP_RETURN limit would basically give about
60 extra bytes to people in a way that's cheaper than inscription, so that might
be a net harm increase.  So, that didn't seem like a good idea back then.

**Mark Erhardt**: Right, okay.

**Sjors Provoost**: So, now we are in this new world where we're seeing people
making these bigger things, bigger than 140, or at least almost at the edge of
it, and we don't want them to do that.  We really want them to not create these
extra UTXOs.  And the only way to convince them to not make these extra UTXOs is
to say we need to increase the OP_RETURN limit to at least about 140.  So, we've
established that we need to increase it to 140 to prevent the UTXO set from
being destroyed.  We've also established that above 140, inscriptions are
cheaper anyway, so there's no incentive to use OP_RETURN.  So then, the
conclusion is just drop the limit, because it is not doing anything, it's just a
bunch of extra complexity.  Plus, if every time you want to increase this limit
because somebody needs slightly more for whatever their weird scheme is, you
need to have this discussion like once a year, which is also not very
productive, as we have seen.

It was those combinations of reasons is why it made sense to just drop it.  And
I get that this comes out of the blue for some people, but if you've been
following this more closely, it should make sense.

**Mark Erhardt**: Right, and now, there's of course people that are in favor of
dropping the OP_RETURN limit.  A lot of Bitcoin Core contributors seem to be
convinced that it would be a net harm reduction; and a lot of opponents appear
to think that reducing the friction for people to add data to the Bitcoin
blockchain overall will mean that it will get used a lot more and it will cause
another wave of what they call spam data transactions, and they consider this a
big change in the culture of Bitcoin, not so much in the code but rather in the
culture, that this is not being fought harder.  And I think a big part of why
this debate has been blowing up so hard is because of the disconnect of one side
trying to soberly weigh the trade-offs, and maybe permit, in their perspective,
a little more data on the Bitcoin blockchain, so at least the data doesn't get
written to the UTXO set.  And on the other side, people feel that the identity
of Bitcoin is being changed.

**Sjors Provoost**: Yeah, and I guess that does get to another aspect of, how
hard should you fight spam, right?  And I don't mind calling some of these
things spam, although I still think it's subjective.  But I personally think
that monetary use cases should be the most important one, censorship resistance
basically.  So, you could decide, as a project, to allocate a lot of resources
to saying, "Okay, let's really try and prevent people from putting arbitrary
stuff on chain".  The question is, if you take that a few steps ahead, where
does that take you?  And I think it takes you to, first of all, you're just
going to fail, because it is a cat-and-mouse game.  And this cat-and-mouse game
really has to be played with consensus code, in my opinion.  The idea of using
standardness just doesn't work, because no matter what Bitcoin Core does in its
standard rules, somebody like Peter Todd is going to release something like
Libre Relay, it's going to be accelerators, so it'll be trivial to bypass,
especially for people that are willing to spend money there anyway.  And there's
the status aspect of polluting the blockchain.  So, there's already a very
perverse incentive to try and break it.

So, if consensus is your only way, now we know how much work it is to make
consensus changes, even for the most trivial and non-controversial things.  So,
do we really want to put huge amounts of effort into finding consensus changes
that actually prevent people from stuffing data in the chain?  I think that's
not worth the effort.  And those changes would be very, very dramatic.  You'd
need signatures to prove, or maybe not a whole signature, like a zero-knowledge
proof, to prove that a public key really has a corresponding private key, that a
hash really has a preimage, all those sorts of things; it will probably break
all sorts of nice use cases by accident; it would definitely make blocks bigger.
It adds a lot of complexity that I'd rather not do.  And then, you can still
stuff data into blockchain, because even if you have to prove that there's a
valid private key, well now you can still grind your private key right until you
have a public key, that at least the first, say, 10 bytes, or not 10 bytes, but
the first part of the public key still represents the data that you're trying to
do and the rest is just waste.

**Mark Erhardt**: Or you can do the same with signatures, or you can stuff data
into the sequence field, or you can stuff data into the timelock.

**Sjors Provoost**: Yeah, but the only thing to add is, if you really want to
stop spam, I think you would literally have to have a committee that just looks
at blocks, like actual humans that look at blocks and just censor them.  And
that's something we absolutely don't want to do.  That would be effective.  If
you had a consensus rule that says, "Hey, these people for the next five years
are now authorized to decide what is and isn't spam", that would work.  That
would be absolutely terrible, but it would work.  So, I think just if you look
at this game, if you really want to play it, not just virtue signal like, "Oh,
my node doesn't accept spam", no, actually play the game and actually try to win
the game, you don't like where you're going to end up.  And it's a huge resource
consumption thing that I think we should be spending on other things.

**Mark Erhardt**: Yeah, I think that a lot of people have been spending a lot of
time on the debate in the last week.  I think this ties nicely into what mempool
policy is trying to achieve in the first place.  And so, Gloria Zhao and I wrote
a ten-week series in Optech, I think that was one or two years ago, about
mempool policy and mempool.  And the title eludes me right now, but I'll find it
in a moment.  It was called, "Waiting For Confirmation", a series about mempool
and relay policy.  And there, we argued that mempool police should be largely
homogenous across the network.  And I think a point that has been brought up a
lot in the last week is that mempool policy should also be very closely related
to what gets mined often in blocks.

So, the advantage of having the things in your mempool already when a block
comes in is, you will be able to very quickly validate the block.  You have
already evaluated all the scripts in your transactions, and when a compact block
announcement arrives, it basically just provides a recipe how to reconstruct the
block from the transactions that you already have in your mempool.  If a lot of
people have very different mempool policies than what gets mined, it means that
the compact block announcement is received and then you see, "Oh, I'm missing
two, three transactions".  And that actually increases your block reconstruction
time by probably a factor 100 or so.  Because now, instead of just building the
block from the transactions in your mempool, you have to ask back to the peer
that announced the block to you, "Hey, can you give me these two transactions?"
especially if these are huge data transactions or if it's many transactions that
are missing.  And it just adds another 100 milliseconds, or so, maybe 150
milliseconds, until you have received all of the remaining transaction data, and
you can reconstruct the block and validate it.

Now, block validation times, or the latency until a block has propagated
entirely through the network, is beneficial to the largest miners, because they
win a block more often and the block propagation time only slows down their
competitors.  Because the block propagation time has gotten so much smaller, we
have a lot less stale blocks.  It is more fair for smaller miners to
participate, because they are behind less time from the bigger miners that more
often, on average, win; not 'on average' as in 'disproportionately', but when a
big miner wins, they immediately start mining on the next block, any miner
really, but a big miner will win more often and therefore, more often has the
advantage of not needing to wait for the next block.  So, if this time is
longer, bigger miners benefit more than smaller miners.

So, the idea is most nodes should have most transactions that are in blocks
already when the block is being announced, and that would make the block
propagation as fast as possible.  Go ahead.

**Sjors Provoost**: There's a chart on blockchain.com.  I don't know if it's
still up to date.  It basically looks at orphan blocks, stale blocks really,
over time, so the number of those per year.  And you can see there was lots of
them in 2014 up to, I think, mid-2017, and after that, virtually none.  My guess
is that they're not tracking all of them because definitely there are still
some, but it happened.

**Mark Erhardt**: I think they stopped tracking.

**Sjors Provoost**: Yeah it used to happen quite frequently and then it stopped
happening.  And the main reason is that Bitcoin Core introduced these compact
blocks that you talked about, plus a few other optimizations.  And then, if I
remember correctly, Greg Maxwell gave a talk about this, saying like, "We made
so many improvements in Bitcoin Core, but miners just didn't upgrade Bitcoin
Core.  And then, for segwit, they finally did upgrade Bitcoin Core.  And so,
that's why the orphan rate just dropped to the floor".  So, this kind of now
looks like this made-up problem because we haven't had the problem for many
years, but we did have the problem.  And mining centralization is already pretty
bad.  We don't want to make it even worse by having this high orphan rate come
back, because everybody runs their own mempool.

**Mark Erhardt**: Exactly.

**Sjors Provoost**: It happened again, right, with full-RBF basically causing
these blocks to be inconsistent again, and that's kind of why Bitcoin Core had
to drop that option, basically make full-RBF the default.  You don't want to
have multiple mempool policies living in the network, because it's disruptive.

**Mark Erhardt**: Right.  So, the blockchain.com chart I think is not
maintained, but you could look, for example, at fork.observer, which collects
similar data.  Regarding the mempool policy, one of the other observations in
the context of this whole debate is that we have been recently seeing a lot more
non-standard transactions, where non-standard refers to transactions that are
not accepted to the mempool of most nodes.  And so, there is of course MARA
Slipstream, but also I believe F2Pool has been mining non-standard transactions
when they receive them, and this has led to a situation where it is quite
possible to get a transaction with a larger OP_RETURN output into the
blockchain, but it won't reliably happen in the next block.  So, let's say you
operate a ZK-Rollup and you have to get 140 bytes of data reliably into the next
block, you will not use OP_RETURN, because only a small portion of the entire
hashrate mines these transactions.  But anyone that wants to, and can wait a
little bit, can easily get these transactions into the blockchain.

Now, often the non-standard transactions pay a premium because they are
submitted out of band directly to miners, which leads us to another mining
centralization pressure, where the mining pools that have more manpower can put
in effort to offer a direct submission interface, can run multiple node
implementations, like Libre Relay, to receive these non-default transactions
that pay higher fees, and they will have, especially as the block subsidy tapers
off exponentially, they will eventually make more money from including these
transactions versus other mining pools that don't.  So, this again would
probably benefit larger mining pools more than smaller mining pools, because
when people look who they give their non-standard transactions to get them
mined, they will look at the largest mining pools.  They won't look up 20
different mining pools and give it to the small mining pools that have maybe two
thirds of a percent of the hashrate.  They'll just send it to the biggest three
and then see what happens, unless they relay on the open network, which makes
them available to everyone, which means that the fees that these transactions
pay are equally available to any block template producer.  And it is much
preferable that all transactions are public information before they get mined,
so that anyone can jump in at any point in time and make a fair amount of
revenue, the same expected revenue as any other mining pool that already exists.

**Sjors Provoost**: Yeah, sounds right.  Just to add a little color there, if
you need to get it confirmed immediately, then sure, you'll send it to every
small miner out there.  But if you have like a deadline of, I don't know, a day
because of some timeout mechanism, you'll just send it to the two biggest ones.
You're not going to send it to the smallest ones.

**Mark Erhardt**: Yeah.  And for statistics, I think there's been at least 20
oversized OP_RETURN output transactions this week alone.  And so, I think the
argument that a minority of nodes implementing this policy, or even a majority
of these nodes implementing the policy, has been shown not to completely forbid
it.  And yeah, so many nodes implementing a policy that restricts these
transactions, and a subset of miners not including them, means an economic
disadvantage for those that don't include them and a less accurate picture of
the available fees that you're competing with when you're building your own
transactions.  It would be preferable to have a homogenous mempool across the
network.

**Sjors Provoost**: Another way to look at the mempool is that it is very good
at preventing censorship, as in even if 90% of all nodes were to censor
something, you're still going to get through that 10%.  It's very nice.  I think
somebody once gave a presentation, might have been in Prague, where basically
they did a game of whispers, where he would whisper a word to the people in the
first row, just one or two people, and then they would tell; half the people
should ignore it and the other half should pass it through, and then the back
row would still get the message intact, just to demonstrate what happens if only
50% of people are honest, but you can go to a lower percentage.  But conversely,
if you want to censor something as a collective, that just doesn't work, again
because that 90% is unable to block things.  So, being that 10% that does relay
things makes you really useful, because you help somebody evade the censorship.
But being the 90% that tries to block things is not that useful.

**Mark Erhardt**: It's just not particularly effective, they just don't forward
the transaction.  But nodes have up to 125 connections.  So, if even 90% of them
don't forward it, among 125 connections, there'll be some 12 or so that do
accept and forward the transaction.

**Sjors Provoost**: Yeah, and then there's something called preferential
peering, where somebody can just signal that they support this bigger
standardness, I think Libre Relay does that, so that if you're looking for peers
that will help you, you can actually find them.  And unless you want to go in
the offensive and toss those nodes offline, you're not going to be able to
censor things.

**Mark Erhardt**: Correct.  So, there was one more aspect to this PR that
especially raised eyebrows, and that was, not only was the default for the
configuration changed to a higher limit, but the configuration option that
allows node operators to set their own limit was proposed to be removed.  Also,
maybe to be clear, when something gets merged into the Bitcoin Core repository,
it'll only be released in the next release, which would be October at this
point.  So, either way, we have some time to get through this debate, because
it's not going to be especially time-pressing whether it gets merged or not
before October.

So, the removal of the configuration option that already existed especially had
some people upset, because they felt, "Well, but if I don't want these
transactions in my mempool, not only are you deciding for me that, by default,
my node should accept it, but now you're also taking away my option to remove or
to set a lower limit again".  Do you have some color on that one?

**Sjors Provoost**: Well, this is, I guess, more project philosophical.  So, I
think even some contributors were not immediately happy about removing the
option.  So, I can get that.  I think that the argument for removing it is that,
and I think Greg Maxwell coined this term, it's a placebo.  And putting a
placebo in a serious software project is, I don't think it's a good idea, and
arguably it's even not very nice to the users either.  So, it depends on your
perspective, right?  You can say, "Oh, it's good to have the option and I'm
happy now".  But at the same time, if you're as a developer deceiving your users
into saying, "Here's a fake option, just use it, like these buttons at traffic
lights that don't do anything".  Some actually do something, but that's also a
problem.  So, you can argue back and forth there.  I think we should not have
options that don't do anything.

**Mark Erhardt**: Maybe we can clarify, that 'don't do anything'.

**Sjors Provoost**: That thing that we just talked about, the censorship, it
keeps it out of the mempool.  But that seems like a very strange thing to want,
because it's going to be on your computer.  So, if you really, deeply care about
what is in your mempool.dat file or on your computer that doesn't seem real,
then you can say, "Well, I don't want my node to relay it", but you're going to
relay the block, so you're going to relay it, you're just not going to relay it
as part of a transaction.  You know, you feel guilty about helping these
transactions propagate and you want to not do that somehow.

**Mark Erhardt**: Right, well, so you'll download it twice.  You'll download it
once when your peers propose it to you as an unconfirmed transaction.  Your node
evaluates it, decides that it is to be classified as spam, drops it on the
floor.  And then later, when the transaction does get included into the block
you download it again.  You have the extra round trip after the block is
announced, but you get the data twice now for extra bandwidth, and then you
accept the block because it's consensus-valid and you forward the block
including the transaction anyway.  Right.  So, I think Greg might have called it
a placebo, but Pieter Wuille, in the mailing list, explained he thinks that
there shouldn't be a configuration option when you cannot give guidance on when
it should be used or make a recommendation for how to use it.  And in this case,
I cannot make a good conscious recommendation to use this option at all.  I
think it doesn't make sense, and therefore I first argued that we shouldn't have
the option.

But meanwhile, I've been also talking to people for a whole week and I've
shifted my opinion.  It feels like you're taking away an option that they
previously had, which disenfranchises people.  If they insist that they want
this option, I would prefer that we only increase the limit and leave the
option, even though in my opinion, the option is not useful, potentially
slightly harmful to the node operators.

**Sjors Provoost**: Right, that's the other thing, it's also harmful.  It's not
just harmful to the node operator, because you're actually actively disrupting
the network by botching compact block relay.  So, even if the option existed, it
would have to have this long disclaimer saying like, "Don't use this.  Not only
are you not helping yourself, you're disrupting others, and it doesn't work".
It seems absurd to keep it around.  I don't think that's a good direction to go
in.  It also kind of reminds me of certain culture war things, like trigger
warnings, but it just seems wrong.  And I think then the better approach is for
people to fork the project, just like Peter Todd did for his Libre Relay, just
like Luke did for Knots.  It doesn't have to be Knots, it can be something much,
much simpler, where it's like, "Okay, for people who care about this issue for
whatever reason, just run this alternative client", because, yeah.  It seems
like the route to go in, where this sort of thing can happen with other features
and we start spending more and more time on almost pure politics rather than
good code design.

**Mark Erhardt**: The funniest thing about this is, if miners include these
transactions, only their block will have a disruption in the relay and get to
other miners more slowly.  Therefore, only the people that do the behavior that
the filterers do not want to support, they support that the miners get a faster
head start, longer head start.

**Sjors Provoost**: Well, in a sense, if a bigger miner is doing this, yeah,
you're essentially increasing the stale rate, which is to the advantage of the
bigger miner.

**Mark Erhardt**: Exactly!

**Sjors Provoost**: It's hard to explain in a README, so, yeah.

**Mark Erhardt**: Right.  I think I can at most sympathize with the argument
that reducing the friction will invite more people to use this option in future
designs or for more NFT bullshit.  But yeah, that's the main argument that I can
relate to in this whole debate for the opponent side.  Okay, the debate is still
ongoing.  There has been a second PR opened, which keeps the option.

**Sjors Provoost**: But deprecated.

**Mark Erhardt**: And there's a lot of material out there now.  Personally, I've
written an FAQ on Stacker News that I've linked in a few places already.  So, if
you want to try to understand this situation completely, that might be a good
resource to understand, decide, or my personal opinions on it, but I think many
Bitcoin Core contributors lean similar ways.  Anything else on this topic,
otherwise I think we might move on?

**Sjors Provoost**: No, I mean, let's maybe not go into the whole meta
discussion, or maybe we should, but let's say you really don't like this change.
What do you do?  Do you go on GitHub and just write really long comments; or do
you go on the mailing list and write really long comments; or do you, I don't
know?  I don't think it's good to try and disrupt the whole process for this, I
mean in the sense that it slows things down.

**Mark Erhardt**: But right.  So, one of the things that happened early on was
that a lot of people started posting on the GitHub PR.  GitHub doesn't scale
particularly well to conversations with hundreds of people because it's a single
thread.  There's not really much in the flow of the conversation, such as, for
example, on Reddit or Stacker News, where it just splits up and people have a
specific post that they answer to, which allows many different conversations to
happen in parallel.  So, GitHub got a little overwhelmed.  Then the moderators
of the Bitcoin Core repository started hiding duplicate and repetitive, or
comments that didn't provide new arguments, which then of course led to people
feeling that they were being disenfranchised, because they couldn't weigh into
this topic that felt very important to them.  And so, there's a whole other
dimension to how people feel that things should work about whether or not the
Bitcoin Core repository is the right place to have this sort of protest, or
whether that's a conversation that should happen in other places.  And maybe,
obviously, you can have as much discussion about this on social media as you
want.  The mailing list is already moderated too, but tends to let conversation
branch fine.  But the GitHub repository tends to not really scale to this sort
of conversation, and it is usually the spot where people are focused on code
review.  They'd rather not engage with a culture war in the Bitcoin Core GitHub
repository.

So, I anticipate that if this happens again, it'll have a similar outcome, where
moderators will try to make the conversation more readable and limit, to some
extent, the excess unwanted comments.

**Sjors Provoost**: It makes it hard to work.

**Mark Erhardt**: Right, yeah, who's done any work in the last week?!

**Sjors Provoost**: Well, people, the goal is to write code, and so the comment
should be focused on that code.  Now, if you're really opposed to a change,
especially I think the main contributors should be able to let that known.  But
I don't think that needs to be done in tenfold, first of all.

**Mark Erhardt**: Or hundredfold, yeah.

**Sjors Provoost**: Then secondly, I think even the PR at the top said, "Hey,
there was this discussion on the mailing list that talks about this topic in
general".  So, I think the good thing to do there is to go to the mailing list.
But then, even there, I don't think the goal there should be to say, "Hey, I
disagree with something, I'm just going to post now on this mailing list",
without doing some work.  And this gets to the question of what is the target
audience of these media?  So, I think social media, like Twitter, the target
audience is everyone and everybody can have an opinion about everything.  And
the way that that is managed is that you follow people or you don't follow
people, based on their signal-to-noise ratio as you perceive it.  But these
mailing lists are broadcast to everyone and same with GitHub.  So, we can't
follow people on a mailing list.  You can only actively mute them if they're
really annoying, but it doesn't really work that way.

So, on the mailing list, I think the target audience of the Bitcoin-Dev mailing
list is mostly developers who are working on Bitcoin-related stuff.  So, not
just Bitcoin Core, but Bitcoin in general.  They're working on wallets, they're
working on exchanges.  These are fairly technical people, and so when a post is
put on the mailing list, it's not meant for the general public.  So, that's
maybe why people felt like a little bypass, like this quick mailing post by
Antoine, was aimed at an audience that is assumed to kind of know what this is
all about and knows how to find things in the archive.  And so, there's a
missing link there in communicating these changes to the general public.  I
think Optech is trying to help with that.  But if Optec is not the first one to
communicate it, but yet the people who don't like it, then they just basically
bypass that part.

So, even saying to people, "Go to the mailing list", is not really complete
either, because I don't think everybody should just be writing long stories on
the mailing list either, unless they thoroughly understand this at a technical
level.  And this is one of those bike-shedding situations, and not even in the
negative sense, it's one of those topics where people feel they understand it
because it sounds simple.  It's just spam, it's just opportune, but there's ten
years of history and there's nuance, etc.  So, the mailing list really isn't the
right place to have a normal debate either.  It's not a debate for everyone on
the mailing list.  So, does that mean then the normal debate should happen on
Twitter?  That's kind of mean either.  It's like, "Okay, we have this really
nice, exclusive venue for our super-sophisticated discussions, and if you don't
qualify for that venue, you must go to this sewage basically.

There's probably room for more sophisticated debate.  I would say the Bitcoin
Socratic Seminars are a good venue for that, where it's a little lower.  I think
the bar for asking a question at a Socratic Seminar is much lower than on the
mailing list.  That's I think how you should look at it.  And maybe there needs
to be something in between that.  But I would say, and especially because the
timeline isn't this urgent, right, we make a release once every six months; so,
I would say next time you see something on GitHub or your favorite social media
influencer talks about it, your first response should not be to comment on it.
It ideally should be to find your local Bitcoin Socratic Seminar, go there, ask
some questions, and then if you still think after asking some questions, "Hey,
this is stupid and bad", well, then it's probably a time to start speaking out
on social media.

**Mark Erhardt**: I think that's good advice.  Maybe also, I want to hook into
saying that it is a technical audience that is discussing.  A lot of people have
left comments such as, "NACK", or, "I'm against this", which really doesn't
contain much argument to convince the people that are trying to come to a
conclusion for a design debate or an approach debate.  Really, what is needed to
participate in this conversation is to make an argument why something is a good
change or a bad change.  This argument could be rooted in culture, but it has to
be presented to the technical process, and has to convince the other
participants of the process.  Just saying, "I'm against it" or not won't help
because it's not a vote.  It's about trying to find a good solution.

**Sjors Provoost**: Yeah, and I would say there were some actually useful
arguments, even on the GitHub thread, right?  There was one about the issue of
contiguous data versus data with gaps in it that I thought was actually
interesting, and I almost missed it because it was buried between a million
other comments.  So, if your goal is to stop something because you think it's a
bad idea, like I said, try to go through these steps.  But you also don't want
people to go on there and put too much stuff on these topics, because the thing
I just advised was like, be that guy that goes to the meetup first, tries to
understand something thoroughly, and then comments.  And I don't pretend to
always do that by the way, but that would be ideal.  But that doesn't stop other
people from doing it.  And so, you're still kind of watching this unfold.  So,
then maybe the question is, what can you do about that?  I don't know.  But
ideally, you also want to do something about that phenomenon.  If you see an
influencer link directly to GitHub and saying something like, "Go comment on
this PR", you probably want to call that influencer out for doing that, because
they're definitely disrupting the process.  And even if you agree with the
influencer in question that this particular feature is bad, this is not the
right way to do it.

**Mark Erhardt**: Yeah, you have to understand a little bit the scale of the
number of people that are involved here.  If you look at, for example, on
Twitter, the biggest Bitcoin Twitter participants have on the scale of hundreds
of thousands of followers, whereas there's about probably 40 people that
full-time contribute to Bitcoin Core or part-time contribute to Bitcoin Core.

**Sjors Provoost**: Which is a problem, right, time that they can't write code.

**Mark Erhardt**: Right.  Whenever you come to the GitHub repository and add
comments there, you can anticipate that this comment will be read by probably at
least a dozen of us.  And so, please make it worth it to get the eyeballs of 12
developers for a minute or two when you write something.  Make the arguments
well-thought-out, and read up a little bit on what the state of the discussion
is before you weigh in.  All right.  I think we might have covered this pretty
extensively.

**Sjors Provoost**: Listening to our preachings.

_LND 0.19.0-beta.rc3_

**Mark Erhardt**: Yeah.  All right.  I think we'll wrap this topic at this
point.  I know it was a pretty long news item, but I hope it was interesting to
you.  We're getting to the next section, which is Releases and release
candidates.  As the last few weeks already, we still have LND 0.19.0-beta.rc3
and we had already covered that in more detail in Newsletter #349.  So, if you
want to listen to our description of what is in this upcoming LND release,
please check out that episode.  And as always, if you depend on running LND in
your infrastructure, please test the RCs, so that issues are found before people
are starting to use it, rather than after.

_Bitcoin Core #31250_

Going on to the Notable code and documentation changes section, we have four of
those this week.  The first one is Bitcoin Core #31250 and this one's an
exciting one.  It is about disabling creation and loading of legacy wallet.  I
think we've talked about the legacy wallet and the new wallet, which is the
descriptor wallet, and 'new' might be a bit of a stretch because they have been
default in Bitcoin Core since 2021.  The old one, the legacy wallet, is based on
a database format called Berkeley DB.  Berkeley DB has been unmaintained for ten
years or so, roughly.  So, we really, really wanted to get off that, and that's
what led to the descriptor wallets that are using an SQLite database under the
hood actually.  So, Berkeley DB wallets can no longer be created.  They can also
not be loaded into Bitcoin Core starting with the next release.  Instead, what
would happen is you would have to use the migration tool that converts your
Berkeley DB legacy wallet into a descriptor wallet.

**Sjors Provoost**: This is not as scary as it sounds like.  Bitcoin Core
wallet, if you use the GUI, there's a menu.  I think it says, "Wallet migrate".

**Mark Erhardt**: Well, the expectation should be that it just works.  The
migration tool has been released for several years already and has been
extensively tested.  The idea is Bitcoin Core is the forever wallet.  You will
always be able to load any wallet that was created by any older version of
Bitcoin Core.  And in this case, Bitcoin Core contributors wrote a read-only
version of Berkeley DB.  They implemented their own Berkeley DB reader with only
the functionality that Bitcoin Core uses.  And this tiny little library will
stay in Bitcoin Core so that legacy wallets will be able to be imported forever.
But starting with the next release, 30.0, you will need to migrate your wallet
to descriptors, if you haven't done so yet.  Overall, this code change removes
5,600 lines of code, which is quite cool.  And, yeah, if you want to read up on
the start of the migration tool, we mentioned that in Newsletter #172, so quite
some time ago.

**Sjors Provoost**: Yeah, and then the next PR removes Berkeley DB itself and a
few leftovers, so you can't load them anymore, but there's still some
functionality hidden in the code that will go away.  Just another couple of
thousand lines probably.

**Mark Erhardt**: I think overall, it was something like 12,000 lines of code,
which in the context of the whole codebase is, I think, about 6%, 7%, because
it's around 180,000 lines of code, I think.

**Sjors Provoost**: Yeah, but as a percentage of code that people don't
understand, it's pretty significant.  Because the legacy world is one of those
things where nobody really knows how it works.  So, even building a well-tested
migration tool is a huge challenge, because there was all these edge cases and
all these weird behaviors.

_Eclair #3064_

**Mark Erhardt**: Right, exactly.  Okay, our second PR is Eclair #3064.  This
one is a refactor about channel key management.  And the background here is that
the plan of Eclair was originally to use HSMs (Hardware Security Modules) and
external signers to do the signing.  But over time, they changed their approach
and are now putting their entire node into a secure enclave.  So, where the key
generation and key management was distributed into many different spots of the
codebase in order to allow signatures to be produced by external signers, that
is no longer necessary.  And this refactor introduces a new class, called
ChannelKeys, which introduces type safety for the different types of keys, puts
all of the logic together in one spot, and that makes it easier for people to
not mix up different key types and so forth.  So, it's just a big cleanup that
makes key management safer and easier to understand in Eclair.  All right,
Sjors, you're not big on Eclair PRs, is that so?

**Sjors Provoost**: I really liked Phoenix.  That's the same company, but not
the same codebase.

_BTCPay Server #6684_

**Mark Erhardt**: Right.  Okay, third one and second last, BTCPay Server #6684
adds support for a subset of BIP388 wallet policy descriptors.  So, BIP388 only
got merged a few months ago, and describes a language that is very similar to
descriptors, that is specifically aimed to work with the limitations of hardware
signers that have very little computational power and memory.  And so, BTCPay
Server here implements part of BIP388, and that allows users to import or export
single-sig and k-of-n policies, which should make it easier to use BTCPay Server
in a multisig setup.  And especially, it looks like they had compatibility with
Sparrow in mind.  The policies that are supported are P2PKH, P2WPKH,
P2SH-P2WPKH, and P2TR, with the corresponding multisig variants, except for
P2TR.  Any other thoughts on that one?

**Sjors Provoost**: I was going to say, I'd like to see MuSig support, but
really Bitcoin Core needs to add MuSig support and I need to review the code
that, does that so I shouldn't be complaining.

**Mark Erhardt**: Yeah, it's been coming for a long, long time, but there's a PR
open in Bitcoin Core that implements it.

**Sjors Provoost**: And Ledger implemented it on their device, so that means you
can actually test it against a completely independent implementation, which is
nice.  It's still very, very tedious to set up such a MuSig wallet using just
RPCs.  It's mind-boggling, but at least it would be nice if it actually worked,
and then we can figure out how to make it usable.

**Mark Erhardt**: Yeah, there's been a bunch of progress in various avenues.
There's been PSBT fields added for MuSig2; there's been a description of, or a
proposal, a BIP that describes how MuSig would be used to generate wallets and
derivation paths for MuSig; and, yeah, there's an open PR to implement MuSig
support in Bitcoin Core that needs to be reviewed and then, hopefully, Bitcoin
Core will have MuSig2 support.

_BIPs #1555_

Final PR that we're going to cover today is BIPs #1555.  This BIP PR merges
BIP321.  Now, you might wonder what is BIP321?

**Mark Erhardt**: No, dude, I merged that just last week!  And so, this has been
discussed for quite some time.  The PR has been open since, or the number was
assigned in November, and it got just merged last week.  So, BIP321 is an update
and extension of BIP21.  BIP21 deals with the URI schemes, like when you scan a
QR code in order to make a Bitcoin payment and get the payment information,
these sorts of things had been regulated in BIP21 before that.  BIP21 had been a
super-old BIP from 2012, so it turned out that a bunch of people had been using
BIP21 a little different than it had been originally specified.  For example,
they just added some fields for LN into it that hadn't been described in 2012.
So, 321 on the one hand just gives an overview of how URIs are being used in the
context of Bitcoin by most wallets, provides a description of standards, and
then also describes a forward-looking approach on how new address types might be
added to the scheme.  There's also now a way of providing proof of payment to
the sender.  And yeah, so same author too, Matt Corallo, wrote BIP321 and also
contributed to BIP21.  And, yeah, so far it's still a draft, but if you work on
a wallet that has BIP21 support, you might want to look into updating to BIP321
support at some point.

Well, thank you very much for joining me today, Sjors, and thank you very much
to our listeners for taking the time.  Bye-bye.

{% include references.md %}
