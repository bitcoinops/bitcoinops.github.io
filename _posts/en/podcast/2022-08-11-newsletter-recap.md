---
title: 'Bitcoin Optech Newsletter #212 Recap Podcast'
permalink: /en/podcast/2022/08/11/
reference: /en/newsletters/2022/08/10/
name: 2022-08-11-recap
slug: 2022-08-11-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Peter Todd, Larry Ruane, and Gloria Zhao to discuss [Newsletter #212]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-9-2/349449898-22050-1-7a7417e84c9d3.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: We are going to review the Bitcoin Optech Newsletter #212 and
we have one main news item for this week and our special segment.  I'm not sure
if people follow along, but we do have once-a-month segments; one of those this
week is the PR Review Club, and Larry actually did the writeup this month, and
we'll be taking over that moving forward; and we also have special segments for
Client and service updates, which is notable technical updates to software using
scaling or new Bitcoin technology, and we note those with links; and then
there's also the monthly Stack Exchange section that is another segment that we
do monthly, where we go over popular Q&A from the Bitcoin Stack Exchange.  So,
this week is the review club.

_Lowering the default minimum transaction relay feerate_

So, I think we can just jump in with our news item here, which is the topic of
lowering the default minimum transaction relay feerate.  And we brought on Peter
Todd, who has been contributing to that discussion on the mailing list in this
most current iteration of the discussion.  Perhaps it also makes sense, since we
may have some new listeners, that everybody sort of provides a quick
introduction.  So, I am Mike Schmidt, I contribute to Bitcoin Optech, and I also
am the Executive Director at Brink, where we fund Bitcoin open-source
developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I help educate people about Bitcoin online and
I work at Chaincode Labs.  I write for the Optech Newsletter sometimes.

**Mike Schmidt**: Peter, do you want to introduce yourself?

**Peter Todd**: Yeah, I'm Peter Todd, I've been involved in Bitcoin in various
ways for years now and used to do a fair amount of Core development as well,
though I haven't actually contributed to the codebase for a while.  And also,
worked as a consultant in various stuff related to consensus.

**Mike Schmidt**: Excellent.  Larry, do you want to introduce yourself?

**Larry Ruane**: Hi, I'm Larry Ruane, and I work on Bitcoin Core, mostly doing
reviews on a grant from Brink.

**Mike Schmidt**: Excellent.

**Mark Erhardt**: How about we start with a short overview for the minimum
feerate, like what is it and what does it mean in the first place, before we
talk about changing it?

**Mike Schmidt**: Yeah, I think that is a good place to start and I think that
there was some mixing of terminology, which I think might be good to clarify as
well.  So, maybe I can take the 101 summary and then we can jump into a little
bit more depth there.  So, yeah, the discussion here is about transaction relay
feerate.  So, if I am crafting a transaction and I want to broadcast that, I
need to make sure that I have peers that will relay that transaction.  And one
of the factors in consideration of whether or not a peer will accept and relay a
transaction is the minimum feerate, and that's the minimum relay feerate, which
is currently 1 satoshi per vbyte (sat/vB).  So, if for whatever reason I have a
transaction whose feerate is, let's say, half of a satoshi, then what will
happen on the network currently is most folks have the default, which is 1
sat/vB, and they will not relay that transaction.  So, if I was doing that to
attempt to get a low fee transaction confirmed, the likelihood of that being
propagated in the current topology of the network would be low.

We've actually had, I think, I don't know if it was an exchange or wallet
software, that was incorrectly calculating the feerate and ended up in certain
situations having something just under 1 sat/vB in the past, and those
transactions weren't being relayed or confirmed.  And so, due to some
miscalculation on some of the software side, those transactions weren't going
through as estimated.  And I want to distinguish the relay feerate with the dust
limit, and I don't recall the exact numbers for the different output types on
dust limit, but you could in theory have a 10-bitcoin-denominated transaction
that doesn't get relayed due to the feerate.  And so, that can happen with large
amounts as well as small amounts, whereas the dust limit is more about the
actual size, the amount of bitcoin in the transaction, as opposed to the feerate
being paid by the transaction.  So, Murch?

**Peter Todd**: I mean, maybe just to explain it quickly, the idea of the dust
limit is to forbid the creation of outputs that would be unprofitable to go
spend in the future, because they're just so small that the fees necessary to
spend them is unlikely to be worth it.

**Mike Schmidt**: Yes, exactly.

**Mark Erhardt**: Yeah, the discard feerate is 3 sat/vB, so if a UTXO is so
small that spending it would cost more than, yeah, I believe -- how do I explain
this best?  If it costs 3 sat/vB to spend an input, and that's the size or value
of the UTXO, the transaction will not be added to the mempool by standard
Bitcoin Core nodes.  Yeah, one comment, maybe it's still on your overview.  The
min relay transaction feerate is 1 sat/vB.  So, most nodes will actually not
accept transactions to their mempool,  and also they learn about it and
immediately drop it because it doesn't meet the minimum criteria to be added to
the mempool.  And obviously, if they're not added to their mempool, they will
not forward it to their peers either.

Actually, there is a small amount of nodes that have lower min relay transaction
feerates set, because it is a setting that you can change on startup of your
node.  It is just that it seems apparent that no miners are mining anything
below min relay transaction feerate.  I've looked at the block data a few times
in the past and I could not find any transactions that were included that were
below that feerate.  So, I think it's mostly stopped at the miner level where
nobody is taking the transaction and putting it into blocks.

**Peter Todd**: I mean, I believe you're somewhat incorrect there, because it
looks like some miners at least mine zero fee transactions.  Those seem to be
things that they generate internally to then do whatever they need to do for
their business.  So, it may be true that no one mines any non-zero fee
transactions with very low rates, because there's no way to get in there.  But
it's a little hard to be sure about that, because of course no one's creating
them either.

**Mark Erhardt**: Okay, I'm noting specifically a discrepancy on the mempool
charts, mempool monitors, that shows that there is, at times, 30 to 60 MB worth
of transactions waiting with feerates below the min relay transaction feerate.
And then there is, of course, the coinbase transactions that have zero fee
usually, or not usually, I think there's no way for them to have a different
feerate since they don't have an input.  And sometimes miners do include their
own transactions, I would agree on that, but it's like if you look at it, I
think the last figures I got were maybe one or two per day, which out of 350,000
transactions per day is basically zero.

**Peter Todd**: Yeah, I mean, it's certainly a trivial amount, although I would
point out that because no one's really able to relay below min feerate
transactions, it's quite possible some miners do in fact have their actual nodes
set up that way, and there's just no realistic way to get transactions to there,
and that's something that's quite unobservable to us, because the moment you
diverge from commonly accepted relay policy, it just gets very difficult to get
the transactions to the miners.

**Mark Erhardt**: I have a slight disagree there, just because I do see on
multiple mempool monitors and also from individuals that run with lower
feerates, that they do end up getting transactions.  So, if miners were using
those feerates and also had their border nodes configured to relay transactions
at these low fees, I do think that we would see at least some blocks where
currently with many blocks having extraneous space that is not being used, that
include setup of transactions.  But I don't see any blocks where there's a
significant number of these transactions at all.

**Peter Todd**: But I want to say, the thing with mempool monitors is, just
because these show up in a few different nodes doesn't mean that they have any
way of propagating.  Because some of these mempool monitors, the way they work
is they connect to a very large number of nodes at once, but that doesn't mean
that those transactions will still be able to propagate from one to another.  I
mean, I haven't actually done the exact math on this, but roughly speaking it's
probably true that if, say, 1% of the Bitcoin nodes happen to go and use some
non-standard policy, transactions will propagate reliably between those
different nodes because there's just not enough interconnections.  The
mathematical theory behind this is percolation theory, and it's a bit complex,
like what thresholds are needed to propagate.  But essentially, the way
percolation theory works is that below a certain threshold of interconnectivity,
the ability of transactions to broadcast, well of anything to percolate through
a network, goes to zero.  It's a very strict threshold.  You're either above the
threshold where things would propagate or you're below it.

**Mark Erhardt**: I have more comments on that, but let's take it elsewhere.  I
think that we've covered how it's difficult for the transaction to propagate in
the first place, and there may or may not also be probably no miner that
actually includes some at this point.  But what would be the advantages and
disadvantages of reducing the feerate and how would that be achieved in the
first place?  That's maybe another interesting topic that we should cut into.

**Peter Todd**: Well, first let me just mention one thing that I think wasn't
mentioned, which is the minimum relay feerate, there's actually two versions of
it, right?  One is the absolute minimum that any node will allow, which is sort
of a setting that you send to your bitcoin.conf file.  But then there's a second
variant of this, which is as the mempool fills up to the, by default, 300 MB
limit, then the minimum relay feerate is chosen by what's actually at the
minimum feerate in the mempool.  So, as more transactions come in, other
transactions get evicted from the mempool and replaced, and then that minimum
feerate can actually go up.

**Mark Erhardt**: Yes, that's a good point.

**Mike Schmidt**: Peter, as you're talking about sort of the feasibility of
propagating, I know there's BIP133, which provides some sort of peer messaging
about essentially informing and getting information from your peers to either
send or not send in messages related to certain fee levels.  I don't know if
anyone's done any research on the network to see what those values are set at,
to be able to determine the feasibility of propagating these lower feerate
transactions; I don't know if, Murch or Peter, you guys are aware of anything
around that?

**Mark Erhardt**: I think defaults are super-sticky and they're just going to,
like 99%, maybe 99.9% of all nodes will never change their defaults.  And so, a
network will form a connected component of a subgraph if there's at least two
edges in average that exhibit the same property.  So, I think, yeah, one or 2%
of all nodes setting that would probably be enough for transactions to somewhat
reliably broadcast, and much fewer if they had a way to preferentially peer.  I
kind of find that interesting, but I'd like to also get into other topics a
little more.  We've covered this already for ten minutes.

**Peter Todd**: I mean, I could maybe answer the advantages and disadvantages
question, which is, the thing with minimum fee relay is that the current
situation the network works in, where mempools are rarely full, the minimum fee
relay is basically nearly 99.9% of the time, the actual minimum, etc.  This
doesn't match how people expect the network to work in the future, where
transaction fees are much higher, and mempools are constantly full, and there's
constantly backlog, and so on.  So, what we've done by putting in this minimum,
which is well above the market threshold, which would be the minimum, is we
constantly have the network in a situation which we're not expecting it to be in
the future.  And I think this is not a good idea to have.

I think we'd be better off figuring out how the network works, what we expect it
to work like in the future, by setting a threshold low enough that the market
forces can go figure out what the feerate should b based on purely demand and
the mempool limit.

**Mark Erhardt**: Yeah, I think that is an interesting proposal.  And yes, we
already have a hard limit on how much data will go through the network in the
long run because obviously, once the block space is all spoken for, there would
be a natural limit forming by the mempools filling up, the dynamic feerates
potentially going up, and then people wouldn't broadcast and relay these
transactions anymore.  So, I think that is a good point and an important idea to
keep in mind, and we should probably do it, I would agree with Peter.  But I
think the original reason to introduce the min relay transaction feerate was
that we don't want the network to be used as a cheap broadcast system.  If you
have the option to relay data to every single node in the network that then
later never gets mined, you essentially give people the ability to cheaply
broadcast to the whole network for free, because they do not pay the transaction
fee later.

So, maybe there should be a very small minimum just to make it not free.  And I
think that the replacement feerate should remain the same, where if you want to
use the same funds again and again to create transactions that you have to
increment in solid chunks.  But other than that, yeah, maybe it would be very
interesting to drop the current min relay transaction feerate to something much
lower.  Peter?

**Peter Todd**: I mean, it's important to remember that as long as we have
transaction expiration, it will always be possible to use the mempool in the
future to go broadcast stuff for nearly free, because it's unlikely to get
mined.  But this isn't something that the minimum fee relay actually gets rid of
in the future, because the minimum fee relay is expected to go and float, which
provides you the ability to go broadcast data by just broadcasting transactions
that are close to that.  And most of the time, they'll eventually get knocked
out of the network.  So, I think again, this speaks back to, we have this
artificial limit here which blinds us from how the network is actually expected
to work in the future, and we're probably better off just tackling these
problems now.

As I recall historically, the min fee relays, it was actually added before the
mempool eviction scheme was set up.  So, this was added first, then we added the
ability to go and evict transactions and thus keep a size limit on the mempool.
And probably what should have happened is we just got rid of the hard-coded
minimum at that point, but historically that's not how that happened.

**Mike Schmidt**: Gloria has joined us.  Gloria, I know you're jumping in the
middle, but we're discussing the default minimum feerate for relay, and I'm sure
you have some thoughts on that and the mempool.

**Gloria Zhao**: Yeah, maybe.  I think, was Peter still finishing his thought?
Also can you hear me?

**Peter Todd**: The floor's all yours.

**Mark Erhardt**: Maybe in two sentences, what we've talked about.  So, we
established what the minimum feerate and the discount feerate and the dynamic
feerate are, and we've pointed out how the network might operate differently in
the future if there's a constant backlog and we're not really testing for that
yet.  Peter made some great points about that.  And we talked a little bit about
the concern of having a cheap broadcast system, if we allow free relay, but
stuff never gets mined.  And I think that's roughly it.

**Gloria Zhao**: Yeah, I guess free relay is maybe unambiguously not good.  But
yeah, sorry, I guess I wasn't here, so I can't really speak to the old points
that were discussed before I got here.  But I think historically, we kind of use
it as a bit of a DoS protection, and I guess there's a question of how effective
that is, and whether it's appropriate to use it for that purpose, etc.  So, that
would be something to throw in there.

**Mark Erhardt**: Maybe another follow-up, I thought it was interesting,
somebody proposed whether we could do a hashrate, or a little bit of a proof of
work on transactions.  I had some thoughts on that and I also wanted to hear
other people's thoughts.

**Gloria Zhao**: I mean right now, you can sign a transaction without hardware
that's able to work.  So, that might be a bit not fun for some people trying to
transact.

**Mark Erhardt**: Yeah, that was my concern as well.  I would see that hardware
with signing devices might have issues producing that proof of work, it might
obsolete some of the signing devices right now, or, well I guess if they could
either pay or do proof of work, it would still work by them just paying a higher
feerate.  But on the other hand, people that do try to waste bandwidth of other
users would probably not be restrained by having low computing power.  So, with
the small throughput that is possible in the network in the first place, I think
it would be pretty easy to harness enough computing power to still produce the
necessary proof of work to spam the network with this.

**Gloria Zhao**: Exactly, I'm not sure how effective that would be.

**Peter Todd**: To be clear, I proposed the idea of having a separate
transaction relay scheme, as an example, using different mechanisms to determine
whether or not a transaction was worth relaying.  As a separate scheme, I think
having proof of work could be an interesting option.  But it's important to
note, the way I think a system like that should work is, you would want to have
a scheme where anybody, unrelated to the original signer, could just do some
minor proof-of-work scheme, and of course by proof of work, I don't necessarily
mean the Bitcoin proof of work, you could choose one of these so-called CPU hard
schemes, etc, where the only purpose of that is just to tell these other set of
nodes, "Hey, broadcast this transaction, maybe some miners will see it, maybe
some won't".  But I'm not suggesting that we add this to the existing system.

I think the reason why you'd want to have a separate system is for redundancy,
because of L2 protocols, where the ability to get a transaction broadcast and
visible to miners is really important, because their punishment systems are
based on this.  If you cannot get a transaction broadcast into miners who can
then look at the merits of that transaction on their own, you could lose a lot
of money because your punishment transaction will go and your counterparty will
steal your funds in, say, a Lightning channel.  So for that, having diversity is
good, but certainly not something we should add to every transaction.

**Gloria Zhao**: Okay, so you mean you want more ways to propagate the
transaction, not fewer ways?

**Peter Todd**: Exactly, yeah.  I mean, transactions broadcast over Twitter
would be perfectly good in this kind of scenario, where obviously, that's a
highly centralized way of broadcasting transactions.  But as an adjunct to other
systems, that will reduce certain types of failure modes, where for instance,
someone's exploited a mempool bug, and suddenly a bunch of Lightning channels
are about to go in to get exploited.

**Mark Erhardt**: That's an interesting point, and thanks that you clarified
that.  I guess I hadn't thought it through all that much, and I think we also
want to get a little bit into the Peer Review Club.  So, does anybody have some
final points that they want to add about the minimum feerate topic?

**Mike Schmidt**: I'll relay something that Tadge had sent me offline.
Unfortunately, he doesn't have a microphone on his device, so he's attending in
listen-only mode.  But one of the points that he made is that since low feerate
transactions could just be sent to the miners directly, you may end up in a
scenario where you're incentivizing modified Bitcoin Core clients that can do
such things, and that it might be easier for someone to download a new binary
than in modified bitcoin.conf and maybe if it's not the default client, then you
sort of end up with these alternate clients with these patch systems that can do
these sorts of things.  So, I don't know if you guys have thoughts on that
incentive, or that consideration?

**Gloria Zhao**: I don't think there's that much wrong with there being some
nodes that are changing their configurations.  I mean, min relay fee is
configurable, so that's totally fine.  I think the question of changing the
default is like, okay, maybe 1 sat/vB is suboptimal, but if we're going to
decide on some new value, it shouldn't be arbitrary.  So, the process of
figuring out what this new value is, is if someone were to simulate, "Okay,
what's the cost of using this much network bandwidth that we determine is not
okay and considered spam/attack?  What does that look like in terms of sats; and
then, what does that look like in terms of USD, or whatever; and then that's the
budget.  That's probably the process of coming to a conclusion on what this new
value might be, otherwise we're just going to go and bikeshed, "Why is it 0.1;
why is it not 0.2; why not whatever?"  But yeah, if anyone says, "Set it to
zero", I would say that's quite unsafe.  But yeah, that's my two cents on how we
would come to a new value for defaults, not for configurable things.  Sorry, go
ahead.

**Mark Erhardt**: Yeah, I wanted to mention two things.  One is, having multiple
avenues how clients can be distributed might be a great thing, but if it becomes
very broad so that a ton of people publish clients, it might also be easier to
distribute malware, because people would become maybe more accepting of, "Oh,
yeah, they are doing something cool now and I'm getting it from this random
sketchy website".  That might be a concern that might hit some random users more
than advanced users, but there is a certain safety in having a solitary source
of where you can get the client.  And if we were able to configure our client
directly to exhibit these behaviors, that would be safer for users that are less
discerning, maybe.

The second point that I wanted to make is, if we actually drop the feerate to
zero, it would perhaps become very cheap for people to consolidate outstanding
UTXOs that are tiny right now, but it might also become really cheap for people
to create a ton of UTXOs, and I think it might be really hard to specifically
think what effect such a change would have.  And yeah, so the bikeshedding would
be pretty difficult maybe to conclude.

**Mike Schmidt**: Go ahead.

**Peter Todd**: As long as the dust limit is still in existence, it would not
become cheap to go create a new UTXOs though, because you've got the dust issue.
And then I think I'd point out, I mean what I expect would happen if you
actually just said it's zero, was people would do consolidation transactions,
whatever, maybe spam the mempool, who cares what it is; and in practice, the
limit would actually be set by the mempool size limit.  So, whatever the heck,
you know, 300 MB works out to be by the market, that's what would happen, and it
would probably be somewhat consistent across different nodes.  And again, I
think the advantage of that is we just go and operate in a regime where we keep
saying we expect to operate in the future.  Because in reality, blocks are
pretty close to full, but not quite.  Yet somehow, despite being pretty close to
full, we're not seeing big backlogs like people expected.  And I think we should
explore what's really going on there and why is it that these backlogs of
transactions aren't popping up like we expected.

**Mark Erhardt**: Great.  Back to you, Mike.

**Mike Schmidt**: Yeah, a couple of things.  One, Tadge mentioned similarly that
he would like to see what that backlog would look like with a reduction in the
min relay.  His guess was that there would be a large backlog of sub-1-sat/vB
transactions; that's just his stipulation.  And then my question to the group
is, to Murch's point about allowing these consolidations at lower feerates, I
don't know if any miners in the past have volunteered to process batches of
those lower fee transactions that would facilitate consolidation on behalf of
the network.  It may not be financially prudent for them to do so, but I don't
know if anybody in the past has done that as an altruistic thing.

**Gloria Zhao**: I think it has happened.

**Peter Todd**: Yeah, F2Pool, but yeah, you go ahead, you probably know too.

**Gloria Zhao**: No, you go ahead.

**Peter Todd**: All right, yeah.  Anyway, F2Pool mines huge numbers of 1 satoshi
outputs, and I think even some 0 satoshi outputs that were I believe actually
non-standard that got mined.  So, that has happened in the past, but I believe
that was all just done manually.

**Mark Erhardt**: I think we're going to wrap up, or what do you think, Mike?

**Mike Schmidt**: Yeah, I mean that sounds good to me, unless Peter or Gloria
have something else on this topic.

**Peter Todd**: Sounds good to me.

_Decouple validation cache initialization from ArgsManager_

**Mike Schmidt**: All right, great.  Well, like I mentioned, we have a monthly
segment this week, which is the Bitcoin Core PR Review Club.  Gloria is here on
behalf of both, I guess, PR Review Club, as well as the host of this particular
meeting that we're covering this month in the newsletter.  Gloria, I think it
might make sense if you sort of pitch the PR Review Club before getting into an
overview of this particular PR.

**Gloria Zhao**: Yeah, sure.  So, Bitcoin Core PR Review Club is a weekly
meeting where we pick a PR, the host will put up some notes and some questions
about that Bitcoin Core PR, and then we take an hour on IRC every Wednesday at
17:00 UTC to discuss those questions.  And pitch-wise, this is basically how I
learned the Bitcoin Core codebase.  It's very large, and there's a lot of
components, it's very large in scope.  And each PR, you can kind of think of as
like a guided tour through some functionality.  Sometimes it's a bug fix,
sometimes it's adding a feature.  Either way, the notes sometimes give kind of a
scenic route of the associated parts of the codebase, so it's a great way to
learn about the code.  And the questions are kind of designed to help you build
up a review mindset of what kinds of questions you might want to ask yourself to
convince yourself that a PR is safe.

So for example, the one that was covered in Optech this week was a refactoring
PR.  And there's no behavior change, and so the questions went through each
commit and listed questions of like, "How can you verify that?  How can you use
GDB to make sure that something is still hit, even though it was deleted?"  Or
like, "Why is this C++ attribute added to this function; why is that
appropriate?  Why is this type change?" just like, how do you dive a little
deeper and zoom in on the details and be just a really security-minded reviewer.
So, that's kind of my pitch and recommendation for coming to PR Review Club.
It's at bitcoincore.reviews.

**Mike Schmidt**: Yeah, I think I would endorse any folks who are curious about
the technicals to jump into one of those meetings.  You could spend a bit of
time before the actual meeting itself and study the PR, but you could also just
sort of jump in and follow along with the discussion, either while it's
happening or after the fact there's logs on the website to review everything.
And I think it's a good way to sort of dip your toe in the water if you're
curious about the technicals and want to sort of get a shotgun approach of each
of the areas of the codebase.  You may be doing P2P one week and consensus
change the next week, or a factoring one like this one.  So, I would endorse
folks who are curious to join.

**Gloria Zhao**: Yeah.  And I should have mentioned that it's open to anyone and
you're supposed to be able to ask questions and all beginners are welcome.

**Mike Schmidt**: Gloria, you kind of gave a slight summary of the PR.  Do you
want to jump in a bit further?  Do you want to go through the questions?  How do
you want to approach?

**Gloria Zhao**: I would recommend if people are really curious, just go and
read the logs or look at the PR itself.  So, the PR is called Decouple
validation cash initialization from ArgsManager, so a few pretty Bitcoin Core
specific terms in there.  It is part of the libbitcoinkernel project, which
maybe we can talk a little bit about.

**Mike Schmidt**: Yeah, I think talking about the project would be interesting,
since it may not be something that folks are familiar with.  And if they are,
maybe understanding what is the motivation for that; where could it be used in
the future; etc?  And Gloria, I know you have some opinions here.

**Gloria Zhao**: Yeah, well, so this is Carl Dong's project, and I think the
background is essentially Bitcoin Core is called the reference implementation of
the Bitcoin protocol.  And it's always hard to completely modularize code, and
so maybe part of the reason we see a kind of dominance of Bitcoin Core as the
implementation used by nodes on the network is, it's quite difficult to create a
brand-new implementation because it's so, so important to stay in consensus, and
it's kind of hard to replicate because it's very hard to enumerate what all the
consensus rules are and what all the consensus-critical components of the
codebase are.  And so, libbitcoinkernel is one of, I think there have been many
attempts, or several attempts at least before this to essentially modularize
what is consensus, what is consensus critical.

I don't want to butcher this explanation, but so it's not just meant to be like,
"Oh, let's throw all of the consensus functions into a library"; it is, it's
supposed to be a kernel, so a stateful, like, how do I say this?  I'm butchering
this, but it's own -- well, let me just quote from this.  So, let's see, "It is
a stateful library that can spawn threads, do caching, do I/O, and many other
things which one may not normally expect from a library".  And I think this
approach is separate from, or different from previous approaches, in that it's,
"Reusing existing code", again I'm basically just quoting from the issue itself,
"rather than trying to create one library and throw everything in there".  And
so, yeah, hopefully Carl's not listening to this, but yeah, that's what kernel
is.  Go ahead, Murch.

**Mark Erhardt**: I think you didn't butcher it, that was a good description.
So, I think you mentioned that there's other things besides just evaluating the
rules directly in there, for example, how to behave with the cache.  And at that
point, I think it would be interesting to point out that in the past, we've had,
for example, a network fork when a limit was hit on a database that was not on
the radar of being consensus critical.  So, it is not only a question of
enumerating all the rules, it's also a question of being bug-for-bug compatible
with the actual behavior on different architectures, different systems, and
different operating systems.  So, yeah, it's much more comprehensive and
difficult to actually produce a module that encompasses all of that and can just
be imported into different projects.  And that's why it's not just a library.

**Gloria Zhao**: Yeah, so to be more specific, you're referring to BIP50, yeah,
which was an accidental hard fork in 2013, where no fork was intended, but a
change in the database meant that some nodes were -- I think it was, didn't have
enough mutexes to validate all the transactions, and the block had quite a few
transactions, and so some rejected it.  And so yeah, there's so many things that
are consensus critical, but we wouldn't maybe consider a consensus rule.
Obviously, the implementation details and the database and how many mutexes to
have is not part of block validation rules, but it's an example of -- we talk
about this a lot in the meeting actually, if people are interested in reading
the Review Club notes, the difference between consensus and consensus critical,
and thus why it is important to then try to just cut this as kernel instead of
extract out what we think are the consensus rules, because that might be
impossible to do.

**Mike Schmidt**: And I think one example from the PR Review Club, that I hadn't
really thought about until it came up, was the cache component, right?  That's
another one of those that you could say, "Oh, well, that's not part of kernel,
or whatnot", and maybe this is a good segue into the PR a bit, which is, "Why is
the cache, why should that be part of kernel; and, what could go wrong that
would be consensus-related with the cache?"

**Gloria Zhao**: Yeah, exactly.  I guess to dive into these validation caches,
so scripts, specifically signature verification, are computationally expensive,
and the most computationally expensive part of validating transactions in a
block, and thus the block itself.  And so, one thing that we do to speed up
performance is to cache the signature and script verification results of
transactions we see that are broadcast before they're in a block.  So, when
we're validating them for our mempool, we'll check that the signatures are
correct, and whatnot.  And so we'll cache those.  And then in block validation,
we'll just use those results and that makes things much faster, and so it's
consensus critical.  So, if there is something wrong in the script cache
implementation, like for example we're dropping the last bit, or we're not
actually caching the signature itself but only the pubkey, or something maybe
more nuanced than that, but for some reason we're allowing invalid signatures in
our cache, that could be a consensus bug.  Well, it is a consensus bug because
now you're no longer enforcing those rules when you go to validate transactions
in a block.  And so, yeah, that's why validation caches are part of kernel.

**Mike Schmidt**: Do you know if the project has aspirations beyond just being
used in Bitcoin Core?  Like, would this be a kernel used in alternate node
softwares?

**Gloria Zhao**: As far as I know, that is the intention, that after kernel, you
could use this to build an alternative implementation of Bitcoin and then maybe
we wouldn't have so many Bitcoin Core nodes, we'd have "kernel plus blank"
nodes, which could be healthy for decentralization on the network.

**Mike Schmidt**: Yeah, I was going to sort of lead you to that, if you want to
comment briefly on your philosophy there.

**Gloria Zhao**: Oh, yeah.  So, I think it's quite important to not have every
node on the network be Bitcoin Core.  But what that means is, if there is a bug
that can cause nodes to crash, for example, like there's an assertion based on
an assumption that is not true in specific cases, then it becomes somewhat easy
for an attacker to take down a large portion of the network.  Or, if you notice
some particular behavior that can cause Bitcoin Core nodes to disconnect each
other, then you can cause a network partition.  But if we have a bit more
diversity in nodes, just from a security standpoint, that makes sense.

The other thing is a lot of people make arguments that Bitcoin Core kind of
controls Bitcoin.  I don't think that's the case, but it's still a lot of
pressure to put on Bitcoin Core contributors and maintainers to be like, "Yeah,
you have to make sure this is correct, otherwise if you deploy it and everyone
runs it, the consequences can be taking down a lot of the network".  So,
hopefully that makes sense as an argument for why multiple implementations make
sense.  But more importantly than that is, all the nodes on the network should
enforce the same rules.  And so, if there isn't like a shared, I don't know,
library or kernel or something, there is that risk of potentially falling out of
consensus.  And so I think this is a really, really good approach to having
both, where everyone is using, let's say, kernel, which is a minimal set of the
consensus critical stuff, and then all the other things that should be optional
are.

Then, we no longer have this kind of double standard of like, "Oh, Bitcoin Core
needs to be a perfect reference implementation, and we need to make sure that
nothing ever breaks", but also all of these nice things that make Bitcoin
usable, like a wallet, like even some of the optional protocol things, like
package relay or mempool or whatever, maybe we can have more lightweight
versions or more enterprise-focused nodes, like multiple implementations, I'm
saying.  So, we have both diversity on the network, but also everyone staying in
consensus.

**Mike Schmidt**: Thanks for explaining your philosophy there.  For any
journalists on this space, you can now quote Bitcoin Core maintainer as saying,
"I want you to use Bitcoin Core less.  I want less Bitcoin Core in the network"!
I kid.  Is there anything else about this particular PR or the project in
general that you think would be beneficial to the listeners to discuss?

**Gloria Zhao**: I mean, if people are interested in contributing to Bitcoin
Core, please review PRs!

**Mike Schmidt**: Yeah, that's a great place to start.  Murch, anything that
you'd like to add?

**Gloria Zhao**: No, I think Gloria did a great job of summing it all up.  How
about we move into the update section with the PRs that got merged?  I think we
might go a little over the hour, but let's try to attack that.

_Bitcoin Core #25610_

**Mike Schmidt**: Yeah, that sounds great.  Murch, why don't you jump in on this
first one, since I know you had some feedback on that when we were crafting the
newsletter.

**Mark Erhardt**: I don't have it in front of me.  That's 24584, the segregation
of inputs?  No, that's the next one.  This first one is the RBF default,
essentially.

**Mark Erhardt**: Oh, yeah, right.  So, we had a PR that changed the default
behavior of Bitcoin Core.  So far, Bitcoin Core, the wallet will generate
transactions that opt-in to RBF if you create transactions through the GUI.  So,
currently we're seeing about 27% of all transactions signaling replaceability.
There's also recently been a change in Bitcoin Core where you get a new startup
flag and if you use that startup flag, you will actually not require the
replaceability flag on transactions to allow transactions to be replaced in your
mempool.  So, there's a little bit of a shift here, or another shift.  It's
basically the same things people have been arguing for the last five years, that
to get rid of some of the issues around pinning attacks and making replacements
easy on the network and making it easy for users to prioritize their
transactions and be compatible with mining incentives at the same time,
transactions before they're confirmed should be easily replaceable at a cost,
because whenever you replace a transaction, obviously you're broadcasting data
to all of the network, and we want people to opt-in to pay something for that,
for broadcasting a message to the whole network.

So, in this specific PR that we're looking at, we changed that after the GUI
already opts-in by default, the RPCs, when you use Bitcoin Core from the command
line, will also create transactions that opt-in to RBF by default, and that
happens in twofold ways.  On the one hand, there is the default behavior on
startup, the wallet RBF flag is now true by default instead of false; and there
were two RPCs that now by default create transactions that are replaceable by
default.  I don't have them in my head right now, which ones they were.

**Mike Schmidt**: And one thing that I saw, I forget in which venue this was
discussed, but something like almost 30% of transactions are signaling RBF, is
that right?

**Mark Erhardt**: Yeah, I think the latest figure is like 27% or so.  Funnily
enough, a lot of transactions do signal replaceability, but the amount of
replacing events is not that high yet.  I think that 0xB10C had been collecting
some data on that.  I don't know if he's already published it.

**Gloria Zhao**: Yeah, based on the graphs that he sent me, it looks like 3% of
all transactions are replacements, which is quite a bit.  There's a few thousand
every day.

**Mark Erhardt**: That would definitely go up a bit if two things happen, (a) if
we drop the min relay transaction feerate to zero; and (b) if we make
replaceability the default, which is what this previous PR, that we link in the
newsletter, is about, is full RBF instead of opt-in RBF.

_Bitcoin Core #24584_

**Mike Schmidt**: I think we can move on to Bitcoin Core #24584, which is
talking about coin selection and --

**Mark Erhardt**: Oh, can I take that one?!

**Mike Schmidt**: We have a coin selection guru here that maybe can bring some
clarity to what's going on in this PR.

**Mark Erhardt**: All right, so when you build a transaction, you have to pick
some inputs to fund the transaction, and previously in Bitcoin Core, we have
always been just picking from the whole set.  With this PR that Josie
contributed, we will now try to separate the UTXO types in our wallet first and
try to build an input set from each of those separate types.  So, if you have
P2PKH legacy inputs or native segwit inputs and wrapped segwit inputs, you would
try to do coin selection on each of those sets separately.  And if you find an
input set that only uses one type, we would prefer using only a single type at
first.

The idea here is that that helps with some of the fingerprints around building
transactions that might reveal especially what the change output was on a
previous transaction.  And it turns out that if you segregate the input types,
you actually can also save fees, because it will now prefer spending larger UTXO
types like legacy at low feerates more, and spend cheaper UTXO types at high
feerates more, because now we directly create separate sets of inputs for those
and our waste metric that we have already will cause it to prefer the one that
is cheaper.

**Mike Schmidt**: Excellent.  So, I assume you're supportive of this change?

**Mark Erhardt**: Yeah, I think the idea was born for it in a meeting that
Josie, I, and a few other people had, and he then volunteered to implement it.
I've been supportive.  I was pleasantly surprised that it also caused fees to go
down in our simulations that we did to make sure that it actually is a
beneficial change in all avenues, and I think that it is a good privacy
improvement.

**Mike Schmidt**: Great.  Anything more to add on that PR?

**Mark Erhardt**: Oh, maybe there was a different change in, I think it was
February or January, and that is that we always, in Bitcoin Core, now match the
output type of the recipient with our change.  So, when you send money to a
legacy output, you would also create a legacy change output, or the same with
native segwit, or you would downgrade your output to match the type, because
there's several heuristics that Chainalysis, or chain analytics companies, use
to follow the transaction path and try to cluster activity to distinguish
wallets.  And a lot of them are around identifying what the change output was in
a transaction, because that ties future transactions of the wallet to old
transactions.  And so, matching the type will actually cause us to have UTXOs of
different types, which is why this PR is especially useful; and vice versa,
having this PR makes it more palatable to match other types.

**Mike Schmidt**: Yeah, essentially the previous change, the previous update,
affected that first transaction so that the change wasn't as obvious.  And then
this PR that we're talking about affects subsequent transactions that would
happen with the change from that original transaction.  And if you're a little
confused on this PR, Josie's got a nice diagram and example in the PR that can
help you kind of wrap your mind around these different changes that have made to
coin selection.

**Mark Erhardt**: Cool.  Next one?

_Core Lightning #5071_

**Mike Schmidt**: Yeah, next is a PR to Core Lightning (CLN), and it's #5071,
and it adds a bookkeeper plugin.  So, CLN is plugin-based and that a lot of the
functionality can be augmented or changed using these plugins.  And so, this is
a bookkeeper plugin.  And essentially from what I can tell, it's an accounting
plugin, so you can sort of see all movements of the coins in and out, including
fees, and then have some reporting around that for various reasons, including I
suppose auditing and tax purposes could be use cases here, as well as just
general analytics around your particular CLN node.  I haven't used it, so I
can't opine more than that.  I don't know, Murch, if you've used it, are you
familiar with it?

**Mark Erhardt**: No, unfortunately not.  We really need to get a Lightning
expert up here too!

**Mike Schmidt**: Yeah, indeed.  Maybe I'll put the feelers out and see if
somebody wants to join us for future.  Two more here.

_BDK #645_

One is BDK.  There's a change to the way that taproot spends are signed for.
So, before this change, BDK, which is the Bitcoin Development Kit, would sign
for the keypath spend and then also any scriptpath leaves that it had the keys
for.  So, I guess it would just sign everything, as opposed to with this PR, as
a way to specify specifically which of the spend paths you want to sign for
instead of signing all of those different potential scriptpaths.  So, in taproot
you have the keypath spend and then you have these scriptpaths, and instead of
signing all, you can specify exactly which one key scriptpath spend you would
like to spend.

**Mark Erhardt**: That sounds like a good change!

_BOLTs #911_

**Mike Schmidt**: Yeah that seems reasonable.  And then the last PR here is a PR
to the BOLTs repository, which is essentially the LN spec.  And the summary is
that it, "Adds the ability for a node to announce a DNS hostname that resolves
to the IP address".  And my understanding is part of the motivation there was
that without this, you're somewhat relying on the gossip network to get some of
this information, and having this DNS entry adds a little bit more validation to
some of the address information, as opposed to just having it and getting it
through the gossip network.  Murch, anything on BOLTs 911?

**Mark Erhardt**: Sorry, I must admit that I actually failed to look at it
earlier tonight.

**Mike Schmidt**: Okay, no worries.  Well, we're a little bit over time anyways,
so if anybody has a question, feel free to raise your hand or request speaker
access and we can bring you in.  Here we have one.  Akhtar?

**Mark Erhardt**: Cool, you're up here.  You just have to unmute so we can hear
you.

**Mike Schmidt**: Akhtar?

**Akhtar Hussain**: Hey, brothers, how are you?  Good evening.  This is Akhtar
Hussain from Pakistan.  So, I am interested in Bitcoin.  So, can you kindly
inform me what it is about and how can I benefit from it?  I will be thankful.

**Mike Schmidt**: Just more broadly and using the Bitcoin software?

**Mark Erhardt**: I'll try to cover it in two sentences, but I think that it
might be a little too broad as a question for this meeting in general.  So,
generally Bitcoin is useful to send money to other people, and since it's a
global system it works to anybody on the planet and it tries to exhibit the
properties of cash payments on the internet.  So, there are a few privacy
benefits and just more sovereignty to holding your own money.  So, if that
sounds interesting, you could for example try to find our, "I'm new to Bitcoin"
topic on Bitcoin Stack Exchange.  It's, for example, linked on my profile.  We
go into a lot of different questions early users have, and there is also one
that is about the key selling points of what Bitcoin can do for you, and I think
it's called, "How do you describe Bitcoin in a few sentences or so?"  I'll link
it in the announcement of our meeting here.  Okay, goodbye.  Oh, you just
unspeakified yourself, never mind!

**Mike Schmidt**: Fin.

**Mark Erhardt**: Okay, hi.  Well, okay, I guess now that we've taken two
questions, does anybody have something to say about wrapping up this meeting?!

**Mike Schmidt**: Gloria, would you like to make a sound effect noise as well?

**Gloria Zhao**: Not really!

**Mike Schmidt**: All right, well, thanks everybody for joining.  Sorry that we
weren't able to get Tadge on verbally and we had to read some of his notes.  It
was great that Peter joined us, Gloria joined us, Larry joined us, Murch, thanks
for doing this thing with me.  And I hope you guys like the Thursday edition,
giving everybody a little bit more time to consume the newsletter before we have
this discussion.  Any feedback, feel free to message myself or Murch, or reply
to the Optech account with any ideas, and appreciate you all joining us and your
curiosity into Bitcoin and some of the technicals.  So, thanks everybody.

**Gloria Zhao**: Thank you.

**Mark Erhardt**: Yeah, cheers.  Talk to you soon.  Bye.

{% include references.md %}
