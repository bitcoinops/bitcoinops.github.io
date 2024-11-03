---
title: 'Bitcoin Optech Newsletter #299 Recap Podcast'
permalink: /en/podcast/2024/04/25/
reference: /en/newsletters/2024/04/24/
name: 2024-04-25-recap
slug: 2024-04-25-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gregory Sanders to discuss [Newsletter #299]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-3-25/440f5652-2807-aea9-78fc-435a58480386.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #299 Recap on
Twitter spaces.  Today is going to be a discussion about weak blocks; we're
going to talk about the five new BIP editors, including someone that we know
very well; we also have five Stack Exchange questions; and also, our usual
weekly release and notable code segments.  I'm Mike, contributor at Optech,
Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work full-time at Chaincode Labs on Bitcoin
projects, and since of Monday, I'm a BIP editor.

**Mike Schmidt**: Instagibbs?

**Greg Sanders**: Hi, I'm Greg, or instagibbs.  I'm at Spiral.

_Weak blocks proof-of-concept implementation_

**Mike Schmidt**: Greg, thanks for joining us this week.  We have your news item
as the first item in the newsletter.  For those following along, you can look at
the tweets in the Space or bring up Bitcoin Optech Newsletter #299.  The News
section, first one, Weak blocks proof-of-concept implementation.  Greg, this is
your post to Delving and you resurrected this old idea of weak blocks, which
I'll let you introduce.  It's not something that I was actually very familiar
with before you brought it up again, so maybe you can introduce it to everybody.

**Greg Sanders**: Yeah, sure.  It's definitely got some history.  I'd forgotten
how long ago it was.  This is kind of the heat up of the blocksize wars,
discussions within the community, the Bitcoin community, which was pre-split.
So, you had people who were sympathetic to larger blocks and they're trying to
figure out how to work through this.  And so, weak blocks was basically one
idea, a family of ideas, to reduce the marginal orphan rate for blocks that get
larger.  So, if you wanted blocks to get like 10 MB, 100 MB, how could you do
this?  Oh, go ahead, Murch.

**Mark Erhardt**: Stale block rate.

**Greg Sanders**: Okay, stale block rate.  So, if blocks are like ten times as
large, then basically the chances of your block becoming stale go up and this
has, I'd say, perhaps non-linear effects, depending on how big you are as a
mining pool.  So, if stale rates go up, the incentives are much higher to join
into larger and larger pools until you get 51% or even more.  So, this is one
big concern that people had and they're thinking about how could you use
essentially this -- you'd send around mining shares.  So, a mining pool or these
miners would basically have near misses.  So, let's say instead of a full proof
of work (PoW) required for a consensus valid block, you get one-tenth or
something like that.  That would be still a lot of PoW, and you'd send these
shares around the P2P network, and these shares would essentially hint at what
miners are working on.

So, you can imagine if you have like 100 of these coming in between every real
block, that you could get a good sense of what is going to be in the next block.
And these proposals also use differential coding schemes like, okay, the first
weak block maybe it has everything in it, or the second weak block tells you the
delta from the first weak block, the third the delta from the second, and so on
and so forth.  This would compress it further, but that would require strict
ordering and extra consensus layer on top, complicating the protocol.  And this
is again back when people were thinking, "Maybe we should soft fork in some of
these ideas to consensus enforce these things".  And as also a reminder, this is
about 2015 when a lot of this -- I dropped a few links in the Delving post, but
this is before compact blocks was at least deployed.  I'm not sure, I don't
remember how far the spec had come along by then, because I was pretty early and
I was just getting into the development space in 2015.  But it's around the same
time as it was being specified.  The BIP152 for compact blocks was around 2016
or the end of 2015.  And so, that's just some basic history.  Murch, is your
hand still up or is that just like an old...

**Mark Erhardt**: That seems to be an error in your GUI.

**Greg Sanders**: Okay, all right.  So, that's kind of the weak blocks idea.
I'll stop there for any clarifications required for the weak blocks historical
idea.

**Mike Schmidt**: Maybe just a tangent and not necessarily a clarification of
that.  When you're talking about the deltas between these weak blocks, when
people were talking about that, something that comes to mind is set
reconciliation, like the erlay kind of tech?

**Greg Sanders**: Yeah, so I'll circle back to this.  I think you could keep it,
you could do a version of this with weak blocks even without adding global
consensus to this, maybe a per-link differential, but it's something for future
work.

**Mike Schmidt**: Okay, I think that's a good opportunity for you to continue.
Sorry for the disruption.

**Greg Sanders**: Right, no problem.  So, this leads into compact blocks.  In
the interim, we've had compact blocks deployed and basically it's a scheme to,
when a new, full PoW block comes in, nodes tell each other about this new block
in a compact way.  Basically, a compact block, it includes the header, as well
as per-link short txids, so basically the txid list for the entire block, but in
a shortened way that's sorted per link, so you can make it even smaller while
still being safe.  And this allows the receiving node, this compact block, if
they're lucky and if they have everything in their mempool or held somewhere,
they can fill out the entire block with this kind of sketch and then continue
forwarding it to the next nodes.  So, this would be a half-a-round-trip block
update versus a number of round trips, and this makes the network converge
faster on the new chain tip, which then allows miners to mine on the most
profitable thing, regardless of how much hash power they have.  Again, this is
to reduce accidental selfish mining and speed up network conversions.

**Mark Erhardt**: I think that a useful analogy would be, instead of sending
around the entire block, you send a recipe on how to cook the block from your
own mempool.  And then, if you're missing any ingredients, you ask your peers,
"Hey, I'm missing that transaction, could you hand it over?"  So, yeah, it's a
way more compact form of getting everybody the same cake.

**Greg Sanders**: Yeah, prior to compact blocks, what would happen is the new
block comes in, and old, old way, is you'd send them a hash and say, "Hey, I
have this new block", and then you'd say, "Hey, give me the full block", and
they'd give you the full block.  But at 4 MB, you already probably have almost
everything in your mempool and you're just wasting bandwidth and there's all
this back and forth.  And 4 MB is too large just to unilaterally send, right?
So, you can't get the same -- it's also just larger, so it just has more latency
inherent there as well, so reducing it to optimistically half a round trip and
being quite small, so this can speed up quite a bit.

**Mark Erhardt**: So, with the weak blocks going around, your idea is we can use
compact blocks again and we basically give recipes of people's block templates
ahead of time, and that would allow everyone to get the transactions they're
working on before the block is found?

**Greg Sanders**: Right.  Yeah, exactly.  I haven't gotten to the modern
motivation.  So, rather than thinking about scaling block sizes, I was thinking
more about how network mempool policies are maybe diverging, and there's some
examples, right?  So, recently we saw transaction prioritization.  So, ViaBTC
prioritized a bunch of transactions which wouldn't actually be entered into a
normal mempool, normal meaning 300 MB mempool default, because they're so low,
but suddenly a block full of these shows up, and then all the nodes in the
network are basically missing these few thousand transactions and have to go
fetch them in a round trip.  There's also things like some nodes are doing
mempoolfullrbf, some are not; some are filtering inscriptions, some are not;
some have limited OP_RETURN limits or like 80 bytes, or some have unbounded;
there's some that have different dust limits, so different transaction output,
satoshi value limits, some have none, some have non-zero.

Then, there's also just more experimental things, like different replacement
policies.  So, all these things mean that potentially when, let's say, OCEAN
Mining finds a block, they might have a significantly different mempool than my
node.  And if I'm a miner, I want the update as fast as possible so I can start
building on top.  And yeah, so basically with this kind of motivation in mind,
what if we just reuse compact blocks infrastructure, but reuse them in a weak
sense?  So, we just have a slightly different code path saying, "Hey, I have
gotten a block that is a tenth of the PoW.  What if I can gossip these compact
blocks around?"  Yeah, Murch, is that a fresh hand up?  Sorry.  Okay, no, it's
just you, I think.  Okay.

Yeah, so the main discussion in the Delving thread is mostly about motivation,
how it would be structured, and then also just the design trade-offs.  There's a
lot of things that would have to be decided, for example, how many updates
between each block should we be expecting?  Do we have to send every weak block
we find, or do we need a rate limit in some way?  What do we do with the weak
block?  So, in my implementation, I basically get a weak block.  As soon as it's
completed, I do the round trip fetching of the transactions that are missing.
As soon as it's completed, I first of all protect all those transactions, but I
also try to enter them into the mempool, because maybe I just haven't heard
about it.  So, that's kind of a mempool-sync thing.  So, you have to think about
all these things, do we want; what do we do; what do we don't want to do?

There's also discussion about, does this actually incentivize miners to do
things?  So, for example, if a miner wants to hide a transaction, they're
incentivized not to do this scheme.  So there's, for example, I think Marathon
has their Slipstream service, 	and one of their advertised points is that they
hide these transactions because they're doing BRC-20 token issuances and there's
MEV involved there.  So, they're kind of pinky-swearing that they won't tell
anyone about these transactions.  So, that's kind of an interesting incentives
problem, mismatch maybe there.

**Mike Schmidt**: Yeah, I was thinking about that and the flip side.  So, you
have Marathon that doesn't want to share that information potentially for
various reasons, so they don't want to participate.  And then there's folks,
let's say, like the OCEAN side of things, where they don't want to see, well, I
guess eventually they see it in a block, but they don't want to see relayed spam
garbage.  And I guess what this is saying is, great, you won't see transaction
relay garbage, but you're going to see sort of these half block garbages and you
have to go download it anyways; or, how would that work?

**Greg Sanders**: Right, so one thing is, let's say you're OCEAN, you would see
the transactions in this new message type, but again, you would not have to add
them to your mempool or include them in a block.  This is primarily a way of
reducing latency and block network convergence.  So, I think to argue against
this, you'd essentially have to say -- I'm not saying this is what they'd say,
but let's say you're against inscriptions, you want to filter them at the P2P
layer.  If you start penalizing block relay to penalize inscriptions, that's
essentially what you're doing.  So, you're arguing against fast convergence of
the network, and I think that's pretty problematic, because if that's the case,
there are many ways we could make it worse, right?  An inscription filtering
node might just literally put a penalty on a block.  If it gets a new block that
has an inscription, it could put a timeout penalty on it, right, "Don't accept
this for one second".  And I'm trying not to give bad ideas here, but I think
it's functionally equivalent here to rejecting this idea from that perspective
at least.

**Mike Schmidt**: You mentioned, as part of the motivation, diverging mempool
policies on the network and that resulting in delays for final block
propagation.  Is there a good place to see those metrics or charts showing that,
or is that just more of that we sort of know that's happening based on the
divergent mempools?

**Greg Sanders**: There's no central location because every node has its own
view of the mempool.  But one thing I do with my node is I take a look at it.
There's a compact block logging flag you can turn on and it tells you basically
these stats.  Every time a block comes in, it says how many transactions were
there in the compact block; how many did you have in your mempool; how many did
you have in this special -- there's a special kind of holding cell, called the
extra compact block transactions.  It's kind of a verbose name, but extra
transactions.  But this is just 100 transactions total.  And then it says, "How
many did you request from your peers?"  So, you can see how many you ended up
not ever hearing about, or having hashed, and so you can think about from that
perspective that if we had weak compact blocks, how many times would this
non-zero value of missed transactions go to zero?  And I think that's kind of
the primary motivation there.

The thing is, it's hard to test, right?  You don't know until miners start
sending out these transactions, or advertising these transactions in maybe a
mining template.  So, one big piece here is, would miners want to run this,
because they would have to plug into this; and how much work would it take to
integrate with such a system?  So, these are big, open questions that I do not
have answers for.

**Mark Erhardt**: I mean, if miners got paid for getting a confirmation and the
transaction gets confirmed in someone else's block, they should be happy, right?
I mean, they didn't put aside the block space in their own block and they still
got paid.  On the other hand, altogether this seems to only solve the one side
of the problem, the one where a transaction has already gotten to miners and we
want the network to hear about that transaction as soon as possible in order for
blocks to propagate quickly.  And we want other miners to also hear about any
substantially interesting transactions that might be available among any miners.
But it doesn't address, of course, the question, what happens if some people
want to send transactions that are currently non-standard; how do they get to
miners in the first place; what do we want to do about that; and so, forth.

**Greg Sanders**: Yes, that's very true.  So, in that Delving thread also, Bob
pops in and does a little pitch about Braidpool.  So, if you're interested in a
more advanced solution, which is supposedly, I don't know how to do the game
theory analysis here, but the intention is for Braidpool to be a place where
you're incentivized to share all these essentially weak blocks.  And so,
Braidpool uses a form of weak blocks, but in a kind of mining-pool-based
consensus format.  So, please take a look at that if you're interested in this
direction going further, but I have a feeling that a lot of engineering work
beyond what I've proposed, which you can take a look how much code I've
proposed.

**Mike Schmidt**: What is a DAG?

**Greg Sanders**: Directed Acyclic Graph.  So, let's see, so Bitcoin
transactions conform DAGs, there's just no cycle.  So, a transaction can't spend
itself, in other words, or it's transaction descendant or ancestor can't spend a
descendant's output.  So, if you have weak blocks, you can basically form a kind
of PoW DAG instead of a chain, the linear chain, and this would allow you to
basically make a partial ordering of all these weak blocks to pay out to miners
in some proportional fashion.  Ethereum, at least back when it was PoW, had a
minor version of this with uncles, but they don't have that any more; proof of
stake, I think.

**Mike Schmidt**: You outlined some next steps.  Maybe you want to talk about
that for the audience.

**Greg Sanders**: Oh, so I'd have to open the post for that, but I think the two
were basically, look at what people think about it, because I talked to some
people in private about it as a motivation idea, but seeing what people were
working on, so some feedback I've gotten is from Bob saying, "Hey, it would be
even better if we incentivize even large miners to share transactions".  Some
other feedback I've gotten is basically that maybe things like MEV, or as
BlueMatt calls, MEVil, that maybe that's the largest concern these days.  And
so, we should just first work on relaxing relay policies as much as possible
while staying safe as a vector to make sure Bitcoin Core stock miners are making
the most money.  So, that's another piece of feedback I got.  And lastly, if I
wanted to continue this further, I'd have to approach miners, because if miners
don't run this, it's not helpful.  So, this is beholden on miners actually doing
uptake and need to figure out if there's market fit at all for this.

**Mike Schmidt**: And it's miners?  You wouldn't need to have anything done at
the pool level, right, it's the individual hashers?

**Greg Sanders**: Well, it depends, right?  Let's say I'm a miner who's just
blind mining off of a -- I'm doing Stratum v1, I'm blind mining off of just a
header hash, right?

**Mike Schmidt**: Yeah.

**Greg Sanders**: Yeah, you have to be able to at least see what's in the block
to help with this, right?  So, Stratum V2, or something like it, where at least
you get to see what you're mining on, is at least necessary, maybe not even
sufficient.

**Mike Schmidt**: Murch?

**Mark Erhardt**: Yeah, I wanted to chime in on that too.

**Greg Sanders**: Yeah, but I've never done mining, so this is like one big -- I
see Portland.HODL here.  So, that's one good question I would have to do some
market research on.

**Mike Schmidt**: Murch, any other questions before we move on?

**Mark Erhardt**: No, all good.

**Greg Sanders**: Greg, thanks for joining us to talk about this.  You're
welcome to hang out or if you have things to do and drop, we understand.

**Greg Sanders**: My pleasure, I'll hang around.

_BIP editors update_

**Mike Schmidt**: Next news item, titled BIP editors update.  So, after a lot of
discussion on the mailing list, there are five new BIP editors: Kanzure, Jon
Atak, our co-host here, Murch, Roasbeef, and Ruben Somsen.  Murch, you're sort
of on the inside of some of this, or you're a direct participant in it anyways.
So, I guess congratulations, but maybe also give us some insight about what do
you think about becoming an editor; what have you noticed so far; and maybe how
you're going to approach this responsibility that you have now?

**Mark Erhardt**: Well, I think all of us have noticed that the BIP repository
has been moving a bit more quickly in the past few days.  I think I've looked up
some stats for us here.  91 PRs have been commented or updated since Monday; 54
PRs have been closed, either by merging them or by closing the PR; 3 BIP numbers
have been assigned; 1 BIP has been merged; and we're down to 98 PRs from
originally 142, with a few new ones being opened since.  So, I think that just
throwing a little more manpower at the problem has definitely helped get some
eyes on some stuff that was ready to be merged.

We've also revised BIP2 very slightly, in the sense that there was a PR open
since 2017 that suggested the addition of BIP editors may merge a change to a
BIP that doesn't change the meaning.  So, in the sense that if there's, for
example, a typo, or if there's like a broken link where a file just moved and
it's obvious what the file was and that it was just restructured in a project
that it was linked to or something, making fixes like that where you do not put
words in the mouth of the BIP editor but just add the missing character to fix a
typo or something like that, we can merge now.  And that took care by itself to
allow us to merge something like 30 PRs that were just making minor touch-ups on
open stuff that just shouldn't linger for 7 years.  There's no reason for that
to take that long if it's just fixing a typo.

So, I think that the BIP process is, well, we're still guided by BIP2, of
course.  It's a little more flexible than it was last week, in the sense that a
lot of these really, really tiny PRs have been addressed.  I think it will take
a little longer once we are through the low-hanging fruits.  And we still have
to get to the bigger things, like there's a number of actual BIP proposals open
that have to be read and that might need some feedback, like some things haven't
been posted to the mailing list yet, which is a requirement in the BIP process
for getting merged.  There's also some discussion about whether or not relay
policy is BIP-able at all, because it is the position of some participants that
relay policy is a per-node decision and therefore shouldn't be standardized.
So, I think we're looking into what exactly the state is of affairs and we're
collecting some ideas in how BIP2 could be improved upon by being less vague and
more explicit in what exactly we require and how it is to be interpreted.

So, as some of you might have seen on the mailing list, there's been a
discussion on what the BIP process should entail and some ideas on how to update
it.  So, potentially there might be an effort by some people to write a new BIP
that has a more modern take on BIP2, on what the role of the editors are, what
the process is, what the requirements for something to be published as a BIP
are.  And my personal wish list in that regard would be that, for example, value
judgments would get a little more boxed in.  For example, what does it mean if a
BIP sticks with the philosophy of Bitcoin?  I think that's very hard to decide
for a single editor, because there's probably as many opinions on what exactly
Bitcoin is as there's Bitcoin users.

So, yeah, if you are interested in participating in what the BIP process should
be, please check out the Bitcoin-Dev mailing list where there's a thread
ongoing.  And, yeah, I hope that someone decides to put some elbow grease into
starting to write a successor to BIP2.  That would be wonderful.  Otherwise,
maybe some people that are involved in the BIP editorship might take a crack at
it eventually, but hey, you could do it too.

**Mike Schmidt**: It's still very early with all the new editors, and I'm
excited to see what happens of that.  But I guess we can all say now, thank you,
Murch, for your time in doing this.  I know you are already probably full with
all of your contributions in the space.  So, thanks for doing this.

**Mark Erhardt**: Absolutely.  I think it's been more gratifying than I thought
because, well, it's been such a frustrating process for so many people for so
long, so it just being moving is pretty cool.

**Mike Schmidt**: Speaking of all your contributions in the space, you are also
a moderator at the Bitcoin Stack Exchange, which is the next segment from the
newsletter, our monthly segment on interesting Stack Exchange Q&A.  How long
have you been doing that now, Murch?

**Mark Erhardt**: Now over ten years.

_Where exactly is the off-by-one difficulty bug?_

**Mike Schmidt**: Wow!  Okay, awesome.  Well, we have five questions this month
that we've highlighted in the segment.  First one is, "Where exactly is the
'off-by-one' difficulty bug?"  And this is actually a question on the Stack
Exchange from 2014, but I noticed in my combing the Stack Exchange that Antoine,
who's working on some related work, recently provided an additional follow-up
answer to the question.  He didn't point to a line of code, per se, but in his
answer he explains the off-by-one error, which I'll digest here.

He explains that, in order to see how long it took to mine 2,016 blocks during a
difficulty period, that the Bitcoin Core software looks at the difference in
time between the first block of the period and the last block of the difficulty
period.  The problem is that that only measures how long it took to mine 2,015
blocks, not 2,016 blocks.  In order to see the 2,016 blocks' worth of time,
you'd actually need to go and look at the last block from the previous
difficulty adjustment period.  And that's possible for all of the difficulty
adjustment periods so far in Bitcoin's history, except for one, which was the
first adjustment period in the weeks after Bitcoin's launch, which wouldn't have
a last block of the previous period to look at because there was nothing before
the Genesis block.  So, that would have been a special case to handle that first
period.

So, Antoine hypothesizes that maybe Satoshi didn't want to complicate the code
with this special case for the first two-week difficulty period, or maybe
Satoshi did not notice the off-by-one error with his code.  Murch, I'll pause
there.  Are we on the right track in describing this off-by-one?

**Mark Erhardt**: Excellent work so far.

**Mike Schmidt**: Okay, great.  So, now looking at that, we're off by one block
out of 2,016 blocks.  So, I guess that seems like a small proportion, so who
cares?  We're a little bit under counting time and we're slightly biasing as a
result towards adjusting the difficulty a bit more than it should have, but is
that it?  And Antoine wraps up his answer with noting, "No, that's actually not
it".  Those small differences are not why anybody would care about this
off-by-one.  Actually, the Time Warp Bug is related to the off-by-one error as
well.  We talked about the Time Warp bug as part of the great consensus cleanup
being revived, when we had Antoine on in our podcast and newsletter in #296.
Murch, it's up to you if you want to jump into the Time Warp Bug here, or if we
just want to point people to #296.  What do you think?

**Mark Erhardt**: Oh, I can give it another quick riff.  So, basically the
problem is, if you're looking at the last 2,016 blocks, you would be looking at
the time from the last block in the previous period to the last block in the
current period.  So, the time of the last block would matter for the current
period. However, in the off-by-one, since the last block of the period is only
looked at once, you can actually shift the last block of the previous period
versus the first block of the next period and therefore shift the two periods
independently.  So, if you shift the first block earlier, but pick the last
block in the period as at the current time, and as you shift the first block
earlier and earlier, because the rules permit you to use any timestamp that is
higher than the median of the previous 11, which means that you really only have
to increase the timestamp by 1 second for each block, you would be able to
stretch the perceived time more and more in each period, and that of course
would reduce the difficulty more and more, and you would be able to mine the
rest of all the block subsidies in something like six weeks.

So basically, just making these two periods overlap would be a trivial fix to
this, because now if you shifted the last block back, you'd also shorten the
next period.  If you shift the last block forward, you get a higher difficulty
in the next period because it looks like it's been shorter.  So, the lack of the
overlap is really what enables this Time Warp.  And, yeah, we talked about this
in the context of the great consensus cleanup.  The fix is pretty simple, too;
we can soft fork it in.  We just require that the time difference between the
last block and the current block doesn't exceed some period of time, and that
limits how you could use this off-by-one error in order to modify the difficulty
adjustment.

_How is P2TR different than P2PKH using opcodes from a developer perspective?_

**Mike Schmidt**: Excellent, Murch, thank you.  Next question from the Stack
Exchange, "How is P2TR different than P2PKH using opcodes from a developer
perspective?"  Murch, you answered this question, so I'll let you take the lead
on what you think that this person was asking or getting at with their question,
and how you answered it.

**Mark Erhardt**: Yeah, sure.  I guess the fundamental misunderstanding here is
that some of the address types commit to a very specific template, and the only
malleable thing or the thing that can be modified about the template is which
key plugs in, whereas other output templates allow you to have an arbitrary
script that you commit to with a scripthash.  And P2PKH is, of course, one of
the former, which means if you change the template in any way beyond just using
a different public key, it's not a P2PKH address anymore.  And so, what this
person wanted to do is, would it be possible to basically have a ordinals
envelope or an inscription envelope in P2PKH?  And, no, that's obviously not
possible, because it would modify the output script in a way that it doesn't
match the P2PKH template anymore.

So, what you need in order to have some sort of envelope like this would be a
scripthash-type output, or P2TR, which is both, right?  P2TR allows you to have
a public key-based spending with the keypath spent and a script-based spending
with the scriptpath spent.  And of course, the envelope is included in the
scriptpath and is committed to in the previous output script, so that's how the
envelope works and that's not compatible with P2PKH.  Did I get that completely
or did I miss something?

_Are replacement transactions larger in size than their predecessors and than non-RBF transactions?_

**Mike Schmidt**: Yeah, I think you got it all.  Thanks for walking us through
that.  Next question, "Are replacement transactions larger in size than their
predecessors and than non-RBF transactions?"  The latter question is easier to
answer, since transactions signaling RBF, BIP125, are no larger than any
transactions not signaling BIP125, and that's because the bits that are used for
signaling replacement are always present in a transaction, regardless of if
you're signaling or not.  It's actually using the end sequence number, and so
there's no additional space used for signaling or not signaling, so they're the
same size.  And then, in terms of the former question, "Are the replacement
transactions larger than the original transactions that are being replaced?"
Vojtěch answered this, in that there's scenarios depending on what you're
replacing about the transaction that you could end up with a sized transaction
that the replacement is bigger than the original, or the same size as the
original, or smaller than the original.

When we're talking about size, we're talking about the actual bytes size of the
weight of the transaction, not the amount of bitcoins moving around in the
transaction.  So, it could get bigger, smaller, or stay the same.  Murch, you
may have more to add there.

**Mark Erhardt**: Yeah, I mean you could just run the statistics and get a
decent answer on that.  And if someone wants to do that, that would certainly be
interesting and make for a great blogpost.  But there is no requirement for RBF
transactions to be bigger, and I think that's the main point here.  You can do
whatever you want, you can replace a bigger transaction with a smaller
transaction, you can replace a smaller transaction with a bigger transaction, as
long as you fulfill the BIP125 rules, which have requirements on both the
feerate increasing and the absolute fee increasing.  So, if you're going, for
example, from a big transaction with a low feerate to a small transaction with a
higher feerate, you may need to pay a significantly higher feerate in order to
pay a higher absolute fee.

**Mike Schmidt**: I saw 0xB10C in here earlier and someone also invoked 0xB10C
in one of the comments of the answer.  When you talk about, it would be nice to
see some plot of this information, 0xB10C would be a great individual to provide
that.  He was in here a second earlier, I guess we missed him.  Maybe he's
working on something like that.

_Are Bitcoin signatures still vulnerable to nonce reuse?_

"Are Bitcoin signatures still vulnerable to nonce reuse?"  So, I guess maybe we
should explain what are nonces.  In computer science, nonces are an arbitrary
number that's used one time in cryptographic communication.  And in Bitcoin
signature land, not only are those numbers used once, but they're numbers that
must be used only once.  And why?  Because if you reuse the same nonce with two
different signatures, the two signature equations can be combined and sort of
canceled out using some basic algebra; the nonce can be canceled out, and then
you solve for only a single value in the algebraic equation, which would be the
private key.  And so, you want to make sure you avoid nonce reuse.  And that
applies, and I think this is what the person asking the question was getting at,
that applies to schnorr signatures as well.  So, when we added schnorr
signatures to the protocol, that did not eliminate the concerns about nonces and
also, many of the signature variants, like MuSig2, also need to account for
nonces for the same reason that you're worried about a nonce reusing a single
sig.

**Mark Erhardt**: Small correction.  So, reusing nonces alone is not sufficient
to lose your private key.  You have to reuse the nonce in the context of the
same private key for different messages.  So, you have to sign two different
messages with the same private key and the same nonce.  And then, yes, it's a
simple system of equations where you can solve for the private key.  And people
might wonder why this both affects schnorr signatures and ECDSA signatures.
Well, the interesting thing is that after Schnorra put a patent on his schnorr
signatures, people really liked the scheme but wanted to not pay patent fees for
it.  So, they came up with ECDSA as a response to schnorr, which is essentially
the same idea with a little bit of a convoluted overhead added that allowed for
some of the interesting properties of schnorr signatures to be used patent-free,
but for example, cause the signatures no longer to be linear.

So for example, why MuSig is available now with schnorr signatures but would be
very difficult to implement with ECDSA, is because the schnorr signatures are
linear and that allows them to be added together, which with a more complex
scheme is even secure, and with ECDSA would be way more complex.

_How do miners manually add transactions to a block template?_

**Mike Schmidt**: Last Stack Exchange question, "How do miners manually add
transactions to a block template?"  And Ava Chow answered this question,
providing two different potential ways that manual transactions can be added
into a block template.  The first one would be, if you're using Bitcoin Core's
block template, you can use the sendrawtransaction RPC to get that transaction
into the miner's mempool and then adjust the priority of that transaction, which
essentially manipulates the perceived absolute fee for the block-building
template algorithm.  And you can use that prioritisetransaction RPC on that new
transaction that the miner added to the mempool in order to give it an
artificially high feerate so that it ends up getting mined, even though from a
feerate perspective it might not have normally.  That's the first route.

Then the second route that a miner could use is, they could change the
getblocktemplate in Bitcoin Core to modify it to do something slightly
different, or they could have a totally separate block building software in
scheme instead of totally separate from Bitcoin Core.  Murch, thoughts on block
building?

**Mark Erhardt**: Yeah, I think that just using the prioritisetransaction RPC is
probably the avenue that is used by most because, I mean it's right there, it is
already in the node software that builds templates.  I don't know if there's
actually a block template building software out there that is widely used by
miners beyond Bitcoin Core.  Almost all blocks that we see on the network are
consistent with the ordering how Bitcoin Core would do it, so I assume that it's
mostly prioritisetransaction.

_LND v0.17.5-beta_

**Mike Schmidt**: There's one release this week, which is LND v0.17.5-beta,
which is a maintenance release, and it gets LND compatible with the recent
Bitcoin Core 27.0 release.  Murch, I was messaging to you earlier that I'm not
exactly clear on the interplay here.  It sounds like there's LND, there's btcd,
and then there's Bitcoin Core.  And Bitcoin Core added a PR that limited max
feerates to a certain amount, and because of a bug on the btcd side of things,
potentially that they had a higher max feerate, and now because Core is
enforcing that, there's now an error when people go to send transactions, but I
don't get how those three pieces of software are interplaying.  Did you get a
chance to look into that?

**Mark Erhardt**: I did stare a bit at that.  So, my understanding is that (a)
btcd was using satoshis per kilobyte, whereas Bitcoin was using bitcoin per
kilo-vbyte.  So, that by itself would be a factor of 100 million difference.
But then how that problem actually became an impediment for LND to send its
transactions was, apparently LND uses the sendrawtransaction RPC to submit
transactions to Bitcoin Core in order to broadcast them to the Bitcoin Network,
when of course Bitcoin Core is used as a backend.  And by introducing this new
maximum feerate, the way that sendrawtransaction was being called by LND, that
used the maxfeerate parameter in the sendrawtransaction call, now caused LND to
call it with a maxfeerate that was higher than the permitted range by Bitcoin
Core.  So, the sendrawtransaction call could have been completely fine if the
maxfeerate wasn't explicitly being raised to an out-of-bound figure.

So, essentially, the fix was to just reduce the glass ceiling that they were
parsing in into the sendrawtransaction to the values permitted by Bitcoin Core,
which is still a very high feerate.  And then the sendrawtransaction could
succeed again.

**Mike Schmidt**: Okay, that makes sense.  So, there's a parameter of
sendrawtransaction that indicates the feerate max, and that was too big, and the
check was failing on the Bitcoin Core side as a result, is that right?

**Mark Erhardt**: That's how I understand it, yeah.

**Mike Schmidt**: Great.  It looks like the reported issue to LND, that this was
a potential concern, was March 20.  So, someone doing some of the release
candidate testing potentially, that we encourage folks to do, had found that and
opened up the PR/issue to LND to get that fixed.  It looks like it came out a
little bit after 27.0, so maybe a little too slow on the fix.  I did see some
chatter about that on Twitter, so I don't know if there's a lesson learned
there.  Murch, do you think, were the Bitcoin Core developers aware of this
issue on the LND side of things?

**Mark Erhardt**: I was not.  I guess that, well, I can only encourage people
that depend on Bitcoin Core software in their setup and backend that they
involve themselves in the release candidate testing.  Clearly everyone that
updates to software, especially if they depend on it for managing money, should
check the release notes before they update, and when they see stuff that is
potentially concerning, they might want to test it on testnet first before
updating their production systems.  I think that if that was an issue and that
should have maybe delayed the release or caused the LND release to be quicker,
that should have been raised a little more loudly or, well, I'm not really that
involved in the release process.  Maybe the maintainers were aware.  But anyway,
it seems like it could have been fixed by a little more communication and/or a
little more heads up looking into it earlier.

_Bitcoin Core #29850_

**Mike Schmidt**: We have one notable code change that we covered this week.
I'll take the opportunity, if anybody has any questions on weak blocks, or some
of the stuff we spoke about today, you can request speaker access, we'll get to
you at the end, or you can post your comment in the Twitter thread here.
Bitcoin Core #29850, which limits the maximum number of IP addresses accepted
from an individual DNS seed to 32 per query.  So, when you're starting up a
Bitcoin node for the first time, your node needs to figure out what other nodes
are there on the network to peer with.  One way to discover peers is clearing a
list of hard-coded DNS seeds, and these DNS seeds then return a bunch of IP
addresses of Bitcoin nodes, which you can then choose to peer with, with your
node, or that your node will automatically peer with.

The data limit when you're querying via DNS limits the number of IP addresses
that the DNS seed recommends to you to a max of 33 IP addresses, based on the
just limits of querying via DNS.  However, you can also query DNS seeds using
TCP, which does not have the same data limit.  In theory, the DNS seed could
return 256 IPs or more, but 256 is the limit in Bitcoin Core's net.cpp
networking-related code.  So in theory, one of the seeds could give you 256 IP
addresses.  So, if any of the seeds decided to return 256 recommended IP
addresses, and those 256 could be malicious peers, then results from that single
DNS seed would take over more than half of the outgoing addresses used by the
node.  So, that's obviously a concern because it would increase the
vulnerability of the node to eclipse attacks, where an attacker can --

**Mark Erhardt**: Oh, I lost you.

**Mike Schmidt**: Sorry, I had an incoming phone call.  So, you don't want to
have a bunch of IP addresses recommended to you from a potentially malicious
peer, because you'll be more vulnerable to an eclipse attack.  So, this PR
changes what was a 256 hard-coded limit from a single seed to 32 IP addresses
that the node will accept from a given DNS seed.  That was a lot of rambling,
Murch.  What do you think?

**Mark Erhardt**: That sounds really smart.  That way we will be more likely to
get a diverse selection because we're asking all the DNS seeds, each of them
gives us 32.  There's not going to be one DNS seed that stuffs our try list with
a ton of nodes.  And yeah, well, we only do this once when we sign up to the
Bitcoin Network at the very first time.  And then after that, of course, every
peer that we connect to, we ask for more addresses.  So, I think as long as
there's a single good address in those, or maybe not a single, but a few good
addresses across all the DNS seeds, this should be more safe this way.

**Mike Schmidt**: I don't see any questions or requests for speaker access, so I
think we can wrap up.  Thank you, Greg Sanders, for joining us and talking about
weak blocks.  And thanks always to my co-host and BIP editor and Stack Exchange
moderator, Murch.

**Mark Erhardt**: Thanks, it was a great show.  Hear you again next week.

**Mike Schmidt**: Cheers.

{% include references.md %}
