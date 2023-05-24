---
title: 'Bitcoin Optech Newsletter #237 Recap Podcast'
permalink: /en/podcast/2023/02/09/
reference: /en/newsletters/2023/02/08/
name: 2023-02-09-recap
slug: 2023-02-09-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Martin Zumsande and Carla
Kirk-Cohen to discuss [Newsletter #237]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/70968446/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-4-24%2F88391adb-902d-6be2-bce7-b5f7e6c747c9.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #237 Recap on
the Twitter Spaces.  We have a couple of special guests today, one of which is
hopefully joining us shortly.  I don't think there's any announcements on my
side before we do some introductions and jump into covering the newsletter.
Murch, any announcements on your side?

**Mark Erhardt**: No, everything's smooth sailing.

**Mike Schmidt**: Well, I'll start off, Mike Schmidt, contributor to Bitcoin
Optech and also Executive Director at Brink where we fund open-source Bitcoin
developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs, I contribute to
Bitcoin stuff.

**Mike Schmidt**: Carla, do you want to give a little bit of your background and
what you're interested in and working on?

**Carla Kirk-Cohen**: Sure.  Hi everyone, I'm Carla, I'm also a software
engineer at Chaincode currently sitting in a booth next to Murch.  I work on
Lightning things, currently focused on figuring out some of the jamming
mitigations that we'll talk about today; and then also working on route binding
for LND, which is a part of the bigger offers effort that Lightning is working
on at the moment.

**Mike Schmidt**: Excellent, Carla, thank you for joining us.  We have one news
item before yours and I think we could just jump into it.  I will share some
tweets so that folks can follow along, but look for the Bitcoin Optech
Newsletter #237 and you can find that on Twitter or bitcoinops.org to follow
along, if you're not doing something else.

_Discussion about storing data in the block chain_

The first news item for this week is discussion about storing data in the block
chain.  Wow, a hot-button issue that made its way to the mailing list.  I think
we covered this slightly a few weeks ago with The Stack Exchange, in which folks
were looking at these interesting transactions and wondering what was going on,
and folks pointed to this ordinals group that was doing inscriptions, and
there's been a lot of discussion and debate on Twitter about this.  But it
finally made its way to the mailing list so we cover it here in the Optech
Newsletter this week, and it looks like there's a lot of discussion about this
topic, so maybe we'll cover it next week as well.

Murch, what do you see onchain?  Maybe we can start with some of the data, and I
guess we can recap also exactly the mechanism as well, but I know you were doing
some research and you've seen some stuff in the mempool and maybe you want to
provide some of that data.

**Mark Erhardt**: So, the mempool currently has 46 blocks worth of data waiting,
yet you can be in the next block with 1 satoshi per vbyte (1 sat/vB), which is
pretty uncommon I would say.  So altogether, the memory usage of the mempool is
187 MB, so it's a little more than half full for the default limit running full
nodes.  So, I guess we finally found the base block space demand, for a while at
least until this fad is over.

I saw somebody post earlier today that something like 600 MB worth of data was
already written to the block chain since inscriptions have become a thing and
yeah, I don't know, I've seen a few people come up with proposals to lower the
block space to get rid of the witness discount, to stop relaying transactions
with inscriptions, and I don't know, it feels like shooting with cannons on
sparrows and it's also kind of funny how there's people that yesterday were
censorship-resistant maximalists, today are calling for consensus changes to
curb gravity.  So, I don't know, it's kind of curious to watch.  I don't really
have a beef in this fight.

It's obviously not great that the block chain is growing faster than it used to,
but beyond that it's not going to do a lot of harm validation-wise, it's not
much slower.  It does cost a little more bandwidth to download the block chain
eventually probably.  If you run a pruning mode, you can just cut it away with
the remaining block data.  I saw someone started working on making a patch to
only prune witness data in Bitcoin Core already, so that might also be an option
eventually.  What do you think?

**Mike Schmidt**: Well, I'm curious.  There's some calls for mitigating this or
trying to stop it at some level, but maybe we can jump into exactly what's being
utilised here, because I think these are taproot spends, right?  What is the
taproot portion of this that is advantageous to taproot and not just segwit?

**Mark Erhardt**: Basically, one limit that existed before taproot has been
removed, because taproot improved how we calculate signature hashes (sighashes).
Maybe that's not completely accurate, but basically it has become less expensive
to have certain opcodes in scripts, and one of the reasons why we had multiple
dimensions of limits on transactions previously just doesn't really exist
anymore.  So, one of the only limits is the transaction size that really kerbs
everything.  So, with taproot, it is slightly easier to put more data into a
transaction than it was just with segwit.  Previously, you would have probably
had to split up a few things a bit more into separate pushes, or even separate
inputs if you got over a specific size; while with taproot, you can actually put
bigger images or data objects into a single input.

What the inscriptions do is they push data directly into the witness data on
basically a dead branch of the script, where that is irrelevant for the payment
authorisation.  But since it's part of the transaction, of course it lands in
the block chain and thus can be used as a publishing mechanism.  So, other than
something like OpenTimestamps, that proves that something existed where you
still have to have an external provider for the actual data, these inscriptions
are directly published on the block chain, which apparently is unlimited demand
for publishing stuff on the block chain, which we always knew.  Basically it has
happened before, since 2014 at least, maybe earlier, where people would just
write stuff to pubkeys and their multisigs, or make up other non-standard
scripts to maximize the data payload that they could write into the block chain.

In a way, it's just the same thing we did ten years ago already, slightly more
efficient because it gets a witness discount, but it also just goes to the
witness, which is probably one of the best places it could go to.

**Mike Schmidt**: With taproot, some of the limits were relaxed, which enabled
this sort of inscription-type data-stuffing to be done in a single transaction;
whereas pre-taproot, you could do that with segwit but it would take maybe a few
transactions to cram all that data in.  So, it made it a bit easier, but then
even without segwit or the witness, you mentioned some alternatives, and I think
Andrew Poelstra got into that as well.  Yeah, go ahead, Murch.

**Mark Erhardt**: Inputs, not transactions.  So, you could do the same thing
with multiple inputs ever since segwit basically, and also put it in witness
discounted data.  It would have been a little more difficult to put it all
together and read it as a single data blob potentially, but not really a bit
hurdle.

**Mike Schmidt**: Yeah, and you mentioned Andrew Poelstra got into this with his
reply on the mailing list, which is there's just really no good way to prevent
this.  You can make it slightly more expensive, even if we didn't have witnesses
or taproot, or anything like that.  I guess grinding on signatures, or you
mentioned their multisig as a way to put data in there and it would be more
expensive, but you could still achieve the same outcome of these jpegs on the
Bitcoin block chain.

**Mark Erhardt**: Correct.  Basically, the only way to prevent this sort of
thing from happening would be if we restricted all of the network activity just
to standard transactions.  But even then, people could just do a multisig where
the not-used public keys are data objects.  They would just hide it in something
that looks like standard behaviour, but actually isn't.  There's no good way to
kerb this.  I mean, that's not great, I don't care one little bit about NFTs or
pictures in the block chain, but it also doesn't keep me awake at night.  It's
actually kind of interesting, a few months ago people were concerned about the
long-term fees, whether that would be enough to prop up the mining market, and
now we seem to have a base demand, so we'll see!

**Mike Schmidt**: There have been periods of history where people have seen
things as spam that have gone into the Bitcoin block chain.  I think Satoshi
Dice was one of those projects that was utilising a significant portion of the
Bitcoin block chain for a while and was criticized for that.  I think there was
another project that was doing something similar to OpenTimestamps, except for
they were anchoring into the Bitcoin block chain using a bunch of transactions
and they were criticized for that, and I think those projects seem to have been
priced out eventually, or the interest in those projects has waned, and
potentially something like that happens here again, where eventually these types
of transactions are priced out and it solves itself.

**Mark Erhardt**: That's what happens.  I mean, buying block space in bulk like
this is going to be bound to be expensive, even at 1 sat/vB, you accept these
pictures are paying on the range on multiple dollars to get into the block
chain, it's just probably a little too cheap right now.  But as soon as other
people need to up their transaction fees in order to get their regular
transactions through, which for the average payment size that we've seen on the
block chain is easily magnitudes more than what inscriptions are currently
paying, those inscriptions are not going to have the priority.  They'll still be
waiting, so if in the night the demand for block space drops off, or on the
weekend, the network will start chewing through inscriptions and write them in
the block chain, I guess.  But I think they will be very much a low priority
backlog.

If enough activity happens to send priority transaction payments, or Lightning
channel opens and closes, or who knows what else, then they'll just not happen
at all, and that's exactly what happened in these other instances where people
decried spam.

**Mike Schmidt**: I think the listeners want to know, Murch, how many
inscriptions have you executed yourself; how many NFTs have you minted?

**Mark Erhardt**: Are you talking about the UTXOs that I've owned over the
lifetime of doing Bitcoin transactions?

**Mike Schmidt**: No, it needs to be a jpeg blob.

**Mark Erhardt**: Zero.

**Mike Schmidt**: Okay!  Anything else you think is interesting on this topic
before we move on?

**Mark Erhardt**: I don't know.  It's kind of curious, but not really that
interesting.

**Mike Schmidt**: This is probably the least drama Twitter Space, ordinals
inscription Twitter Space that there's been, just talking about it from the
technicals.  So, I think we've probably exhausted that topic for now.  Maybe
there'll be more interesting discussions on the mailing list for next week.

**Mark Erhardt**: Yeah, I'm sure that's going to come up again.

_Summary of call about mitigating LN jamming_

**Mike Schmidt**: The second news item for this week from the newsletter is a
summary of a call about mitigating LN jamming.  So, we have Carla from
Chaincode, who's introduced herself, and we've also had Clara on previously.
You guys have an effort to start having more regular conversations about channel
jamming.  We've gone through, Murch and I, as well as the newsletter, a bunch of
different discussions on this and approaches.  Maybe, Carla, do you want to
start with just a quick summary of why this is important, why this is a concern;
and then, the different initiatives that are springing up to research and
address potential mitigations?

**Carla Kirk-Cohen**: Sure.  So, I think most folks on this call will know that
jamming is an outstanding problem in the LN.  It's pretty trivial to DoS large
portions, or even the entire network by sending payments through the network
really quickly, or sending them through and waiting a long time for them to
resolve, because you can do this without really incurring any costs, as an
attacker.  Because, right now in Lightning, you don't pay for a failed payment
attempt, you only pay for a successful payment attempt.

This is something that's been known about for years.  I was actually looking up
on the Optech Topics page, my go-to, just to shill the host for a second, when
this was first discussed, and I think this was as early as 2015 that people
started talking about this and ways that we could address it.  And there's been
many, many different proposals of how we could possibly fix this over the years,
ranging from up-front fees to doing proof of someone in the route closing a
channel to prove that somebody paid for this misbehaviour to using routing
tokens to allow people to prepay for their ability to route through.  And this
year, so last year, I guess, Clara and Sergei, who are researchers at Chaincode,
put out a paper that proposed a solution which uses a combination of up-front
fees and of local reputation tracking to address jamming, kind of with a
combined approach to lock down all the various ways that people can try and work
around that approach.

So, what I've been working on with Clara at the moment is taking that research
paper and trying to turn it into an update to the Lightning specification, so
actually going through it and saying, "Okay, how would we code this up?  How
would nodes communicate this?" and work on the solution.  And we're doing these
calls every two weeks in the hope that we can get a bit of momentum on this
issue, because Lightning is getting pretty big now and it's still pretty
vulnerable to this type of attack, and we don't want to find ourselves in a
situation where someone chooses to spam the network and we all need to scramble
and maybe put a sub-par solution out there.  So, we really want to have
something pre-emptively in place for if and when this does happen.

We started this discussion with the up-front fees topic and what we're aiming to
do is start with the most simple version of this, and then improve upon it until
it's something that we think is incentive compatible for the network and would
work out well.  I can dive into more detail there, but that's kind of the
sparknotes of what we've been working on.

**Mike Schmidt**: Okay, great.  Thank you for that overview.  It sounds like
this series of conversations that you're attempting to get the community around
is to brainstorm the best solution; or, do you think you have a solution and
you're trying to garner consensus or support for that solution?

**Carla Kirk-Cohen**: I think that I feel pretty confident that what we've got,
with a combination of up-front fees and local reputation, will work very well.
It is the case that something like this inevitably will add some cost to using
Lightning, so there's definitely an element of, we need people to know about
this and understand it and understand why we need it so that we can deploy it on
the network, because we have wallets and we have lots of different players in
the Lightning ecosystem.

But there is another proposal as well that we're also discussing on these calls,
which is the idea of using sender side.  So, we kind of have two horses in the
race at the moment and we're just trying to figure out which one of those will
achieve our goals most efficiently.  I'd say they're almost very similar because
a reputation token, you need to make an up-front payment and then you get a
token back versus making an up-front payment, you just make the payment along
with your payment, so it has fewer steps.

So, it's just about deciding what's going to be the best mechanism to implement
this sort of system in Lightning.  So, still reaching a technical consensus, but
wanting to have people folded in from the broader community from the beginning,
so they know this is coming and they understand why it needs to be added.

**Mike Schmidt**: The writeup in the newsletter mentioned the Lightning Service
Provider (LSP) specification working group, which wasn't something that I was
familiar with.  Can you explain what that group is; and is that who's joining
these every-two-week calls, or is it a broader audience?

**Carla Kirk-Cohen**: So, I can do my best to explain that.  I can't do it much
justice because it's sort of a separate effort.  But the LSP specification
effort is a group of people who are working on the application level, so wallet
developers and people who would desire to run LSPs, and they're trying to figure
out a common specification for things like selling a channel, or rating a node,
<!-- skip-duplicate-words-test -->or that kind of thing so that that second layer on top of Lightning itself has
some common interoperability so that, as an example, if you're a mobile wallet,
if you have a common spec, you can switch between LSPs rather than being tied to
one LSP, if everyone's interactions work in the same way.

So, folks from that group only hopped onto one call because the reputation side
of things is something they're interested in, in the context of if these people
will be selling channels, they need to know that the node that they're buying a
channel from is a good node to purchase a channel from, so there was some
overlap there.  But primarily, this is the usual suspects of the Lightning BOLT
specification process getting together every other week to talk about it.

**Mike Schmidt**: Murch, anything that you'd like to ask?

**Mark Erhardt**: So, you said that you would like to approach the problem by
going with the minimum viable approach, and then maybe ratcheting up more parts
to find the optimal solution.  What is the minimum solution?

**Carla Kirk-Cohen**: So, for up-front fees, the absolute most basic way that we
could do this is that we express an up-front fee as a portion of your success
case fee.  So, if you charge 10 sats to forward, then maybe 1% of that amount
will be charged as an up-front fee.  It makes a lot of sense to relate up-front
fees to success case fees, because really what you're paying for in an up-front
fee is the opportunity cost a node would have faced if they had successfully
forwarded the payment, but your payment had failed.

So, the idea is that nodes will probably assume a default of 1%, or they can
advertise a custom policy no higher than 10%, because having up-front fees
higher than your success case fees makes no sense.  And then senders would very
simply just accumulate up-front fees along the route in the same way that we do
for regular payments, and completely unconditionally they would push these fees
along the routes.  So, say you're doing a three-hop route and each of them need
10 sats of up-front fees, you push 30 to the first person, they push 20 to the
next person leaving themselves with 10, and they push 10 to the next person
leaving themselves with 10.  So, that's a really easy, really simple way of
looking at this, and that was the first thing that we did.

But the problem that we've run into there, which we actually didn't expect
because we were first at looking at this on a very theoretical level, but
Lightning has fee differentials.  So, if you've just joined the network, maybe
you have default fees that are really low compared to a really big routing node,
like ACINQ, which will have much higher routing fees in some cases.  So, this
very simple mechanism suffers a bit of an incentives breakdown.  So, you've got
one node that charges 10 sats of success case fees and then the next node
charges 100 sats of up-front fees.  When you push that amount along to them,
they get this payment that arrives at them and says, "It's got 400 sats of
up-front fees", which actually needs to be passed on to the next person, "But
hey, I was only going to get 10 sats of regular fees if I forwarded this, so why
would I ever forward it?"  And they have an incentive to just take that up-front
fee, which is actually owed to the rest of the route, and then just drop payment
and then pocket the money.

The reason we have this kind of accumulating issue is that you have to source
all of the funds for the up-front payment from the sender.  If you don't, you
just run into all sorts of issues where people can start maliciously forwarding
payments through the network and failing them, trying to drain up-front fees.
So, it's really important that they come from the originating node so that an
attacking party is always paying those fees.

So, the simplest solution, while easy, maybe won't be completely
incentive-compatible, which is not something we want, because we don't want
nodes to be disincentivized to forward.  But when we start to look at how we fix
that incentive compatibility, the complexity of the spec change starts to really
blow up quite a bit.

**Mark Erhardt**: That's really a little bit of a roadblock that I hadn't
anticipated.  So, in the theoretical way that it's been explained to me before
of course, I understood that at each hub, there's just a little bit of up-front
fee.  But given that you have to source it from the sender, now if the first hub
doesn't forward it, they can just keep the whole up-front fee and you would
never be able to even understand whether they maliciously kept it or there was
an issue; or, does this tie maybe together with the fat errors that Joost was
proposing lately?

**Carla Kirk-Cohen**: Yeah, so that's another thing that we've chatted about
actually in our most recent meeting on Monday, is yes, nodes could do this, they
could once drop a payment, but there's also kind of more to consider in
Lightning when it comes to just failing a payment for your own benefit.  I mean,
every routing algorithm in Lightning, once a node has failed a payment, they
will no longer use that node, say, "This one's not working", and they'll go
around it.  So, your ability to do this on an individual level would be very
limited on a per-sender case.  Like, if you steal my up-front fees, I say, "I
don't know if you're a thief or you just don't have liquidity, but I'm going to
send my payment elsewhere".

They've now been renamed to attributable errors, because I thought that's a bit
of a better name, but Joost has a proposed spec change which I think is really
great, which allows us to lock down who you can blame for a failure; because
previously, people could just basically destroy the error and you would never be
able to blame anyone.  So, it is a question for me that if we have the ability
to perfectly pinpoint who's failed this payment, down to either one node or a
pair of nodes, and we have these routing algorithms that route around a node
that fails, how bad can this be?

But this is where it gets really fuzzy and really difficult to quantify in
Lightning because sure, the payment algorithm will route around it, depending on
the location of the node.  There's lots of different senders in Lightning and
they don't communicate with each other, so if you can steal $1 from a million
people, then you've still made a lot of money doing this, and obviously that's
not the case right now.  Lightning doesn't have the kind of volumes where this
would really be a problem.  They'd steal a few sats and you'd route around them,
but do we want to deploy something now that isn't going to work in the future,
when maybe we do have this kind of volume?

**Mike Schmidt**: There's a topic on the Optech Wiki, if you will, and it's
about channel jamming attacks, and we outline there that there's two categories
of this attack: there's the liquidity jamming attack; and HTLC jamming attack.
It sounds like the mitigation for both of those could be some version of this
up-front fee.  Is there something that you have in your mind; is one of those
attacks more likely to happen or harder to mitigate than the other, or are both
of these equally part of your focus and part of the solution?

**Carla Kirk-Cohen**: So, in terms of liquidity jamming versus HTLC jamming, I
think that these are the two limits of resources we have.  We only have so much
Bitcoin in our channel and we only have so many HTLC slots.  And there are a
bunch of parameters that you set when you open up channels saying, "This is the
smallest HTLC I'll allow, this is the number of slots I'll allow".  And I think
that a rational attacker will just target whichever one of those is cheapest.
So fundamentally, it is the same thing that either it'll do 483 of the smallest
payment possible, or if it costs them less money they'll just jam the liquidity.

I'd say generally, with the state of the network right now and the kind of
values that people have on their minimum HTLC, you would just go for slot
jamming because it's cheaper.  But something that we do look at differently, and
I imagine Clara would have spoken about this when she came on, is the concept of
quick jamming versus slow jamming.  So, whichever one of these scarce resources
an attacker chooses to take up, they can either attack by just constantly
streaming payments through your channel, which is quick jamming, and then
failing them back really fast, which kind of looks like regular payment
activity, it's more difficult to identify whether this is malicious or not.
Although, if you see a massive drop in your success rates, maybe that indicates
that someone is attacking you.  It could also be that someone just wrote a
really bad pathfinding algorithm.

Then there's slow jamming, where they send an HTLC through you and they hold it
for the longest amount of time they can hold it without causing a force closure
of their own channels.  That one is slightly easier to identify, because it's
pretty unusual for HTLCs to be held for such a long period of time in Lightning,
but there are a bunch of use cases, like swaps and all sorts of interesting
other stuff going on in Lightning, that do have a legitimate use case for
holding for a long period of time.

So, the way we think about this two-pronged solution is that the local
reputation tracking, which we haven't really covered in this call, but the idea
is that you can set some metric of what is good behaviour; and if a node is
behaving well, you reserve half of your scarce resources, be it your liquidity
or slots, for a good behaving node.  And then, if a node is behaving badly, you
would keep the other half, or the bad behaving traffic.  So, when someone does
choose to attack your node in whichever way, be it quick jamming or slow
jamming, you degrade their reputation, and then people who are still behaving
still have access to some of those slots and liquidity that are reserved for the
non-attacking actors, and other regular traffic can still go through the
untrusted buckets.

The problem with a solution like that, because maybe that would be the ideal
thing and we just do that, is that any time you have a threshold, someone can
try and figure out what the threshold is and sit just below it.  So, the
combination of a reputation tracking system that reserves liquidity and slots
for good acting nodes, and up-front fee which will punish nodes that
repetitively try and do this because they have to pay the routing node that
opportunity cost, together they manage to lock down a very large amount of the
surface area of jamming attack, because if you go one way we're going to catch
your notification; if you manage to evade reputation, you're still going to have
to compensate nodes anyway.  So, doing the two together I think is a really
important part of what we're looking at.

**Mike Schmidt**: We would always encourage folks who are interested to follow
along with the research being done, and you guys have these calls every two
weeks and it looks like there'll be transcriptions of the calls for interested
folks to follow along.  So, there's one potential call to action for interested
parties there.  Is there something you're looking for from the community other
than following along with these discussions?  Are you looking for more wallet
developers to attend these calls, or maybe give a call to action for our
audience if there is one?

**Carla Kirk-Cohen**: Yeah, so anyone who's interested in keeping up with the
spec development, we welcome you to join the call every other Monday.  We had a
technical mishap this week, but generally there will be transcripts available
and I'll keep sending summaries to the mailing list so that folks can keep up.

I think right now, while we're still figuring out the nitty-gritty of what this
would look like in the protocol, there isn't much need for wallet developers and
application-level Lightning folks to join those calls at the moment, the
transcripts will probably be good enough.  But I think just keeping up with the
general awareness that if we want Lightning to be DoS-resistant, which seems
like a pretty important property for a payment network to have, we are going to
have to change something.  And just keeping that awareness in mind as you build
out things on top of the LN is very important.

Rusty opened the 2019 Lightning Conference with, "Lightning is not always going
to be free", and I think that's an important thing to keep in mind as you build
on top of it.

**Mike Schmidt**: Murch, anything else on this news item?

**Mark Erhardt**: No, I think Carla covered it wonderfully.

**Mike Schmidt**: Yeah, thank you, Carla, for joining us and hopefully you can
hang on for a bit longer, because I think there are potentially some Lightning
PRs later on that you'll have some opinions on that may be more informed than
Murch and I.  So, if you can hang on, great; if not, we understand you've got
important things to do as well.

**Carla Kirk-Cohen**: Yeah, thanks for having me and I'll stick around for a
bit.

**Mike Schmidt**: Great.  Okay, we have a monthly segment that we do that covers
the Bitcoin Core PR Review Club, and that is a weekly club that gets together on
IRC and reviews Bitcoin Core PRs, and it's a very approachable, lurker-friendly
way to get a variety of perspectives into the Bitcoin Core codebase by looking
at these different PRs.

_PR Review: Track AddrMan totals by network and table, improve precision of adding fixed seeds_

This month, we covered in the newsletter Track AddrMan totals by network and
table, improve precision of adding fixed seeds, and that's actually a PR by
Martin, who's joined us.  Martin, do you want to introduce yourself briefly
before we walk through the PR Review Club and what you're attempting to do with
this PR?

**Martin Zumsande**: Sure.  So, I work at Chaincode Labs, I'm working on Bitcoin
Core and I'm mostly interested in P2P and also have done a lot of things like
AddrMan and Address Relay, so that's basically what I'm interested in.

**Mike Schmidt**: I think we could potentially jump into some of these questions
from the PR Review Club, but I think it would make sense, Martin, if you give an
overview of the PR and the motivation for it before we jump into some of those.

**Martin Zumsande**: Sure, yeah.  So, basically the whole thing is part of a
larger project where we try to change the way that automatic connections are
made with respect to different networks, because currently this is all very
random because we know of a bunch of addresses and when we need to make an
outbound connection, we just pick one at random, and if we happen to know 90%
Tor addresses and 10% IPv4 address, then we'll pick a Tor address; and if it's
the other way round, we'd probably pick an IPv4 address.  So, there is currently
no management with respect to that, and there isn't even a way currently to tell
in Bitcoin Core, "We now want to make a connection to Tor", or I2P or some other
supported network.  It's currently completely random, and this is the first step
in an effort to change this.

The problem is that in order to make this thing that we can targetly make a
connection to a particular network, we would need to know how many peers we
currently have from that network, because otherwise, the way this algorithm
works, we would get stuck in an infinite loop.  So, this is basically the first
part, where we give the AddrMan a way to query it and it will just tell us, "We
currently have that many peers from this network and that many peers from that
network", and also the AddrMan, the Address Manager, is divided to two tables,
"new" and "tried".  The new table has addresses that we haven't tested yet, and
the tried table has addresses that are of better quality, because at one point
we had been connected to them, and we can also query with respect to these
tables.  So we could ask AddrMan now, "How many new entries in from IPv4 do we
currently have?"

So, this is the one part of this PR, that we actually keep track of this
information; and the second part of this information is the first use case of
this, where we use this kind of data, and this is related to the fixed seeds.
The fixed seeds are a way of bootstrapping the node if, for example -- I mean,
there are also the DNS seeds that many people probably know about, but these DNS
seeds only give us addresses from IPv4 and IPv6.  So, if we want to have
addresses from Tor or I2P then we cannot use them.  That's where the fixed seeds
come in.  These are coded addresses of potential peers, and they are used the
first time a user would open up their node and doesn't know any peers yet.

**Mark Erhardt**: Let's recap for a moment.  So, the fixed seeds, they are used
to make an initial connection to a new network.  We have the DNS seeds, but they
only cover IPv4 and IPv6, so the Clearnet Bitcoin Core has a bunch of other
networks supported, like I2P and Tor.  And the fixed seeds that are being added
in this PR, according to what I understand from Martin right now, are sort of
first contact in these networks and once you contact these, they'll give you
addresses of other peers.

These get first added to your new table, because whenever a peer tells you about
some other nodes on the network, we don't know how accurate that information is,
whether we actually can find a node there.  So, we separate these new addresses
that we just learned about into the new bucket and after our feeler connection
tries these new addresses and connects them once and gets a handshake and learns
that there's an actual Bitcoin node responding on that connection, then it goes
to the tried table.

So, when we try to reconnect to the network, for example after shutting down a
node, we would pick a few of the nodes from the tried table to make initial
connections to the network again, and generally the tried table is our better
quality bucket, because we know that something can be reached here.

**Martin Zumsande**: Okay, so what this PR does with the fixed seed is that
before, if we don't have any addresses at all, only then would we query the
fixed seed.  And the change of this PR is that we now do this selectively,
network by network.  For example, if we don't have any Tor addresses but have
many IPv4 or IPv6 addresses, it will still query the fixed seed, particularly
the fixed seed for Tor, and this can be helpful if a user makes abrupt changes;
like before, they would only be connected to IPv4 and they would not accept any
onion addresses, because we only accept addresses from networks that we
currently support, and then the user might make a change and switch from a
Clearnet and go to only Tor, so that they only make outbound connections to Tor.
Before that, they would be kind of stuck, because the AddrMan is not empty, so
the fixed seed wouldn't be queried again.  But they also don't have any Tor
addresses, so we would be kind of stuck then and would need some manual
intervention there.

Now, with this PR, in this situation where we have a lot of Clearnet addresses
but no Tor address, we would selectively load a fixed seed from Tor and then we
can use them to bootstrap into the Tor Network.  It's a situation that is not
very common, but I guess it happens to some people and this will make it easier
for people there.

**Mark Erhardt**: Cool, so this is a bug fix too.  Maybe a combative question:
isn't it weird to trust these nodes to be our first contact in a new network?
How have they been selected and how much trust do we put into these fixed seeds?

**Martin Zumsande**: Well, it's not something we like to do, but we need to
bootstrap in some way, I guess.  So, they are selected like before each time a
new release is built for Bitcoin Core, people will select some nodes that have
been online for a long time and well-behaving.  So, they suggest a list and this
gets approved and, yeah, these are not handpicked, we don't know who they are;
they are just peers that seem to be good.  And what's also important is we don't
have just one or two; we have pretty large and hopefully it will be even more
nodes in the future.  So, if a node makes a connection to one, then even if that
would be malicious, it would also make connections to others, and hopefully
they're not all malicious.

So hopefully, something that a node only needs to do once in a lifetime and
there is definitely some risk involved, but currently we don't have a better
solution, I would say.

**Mike Schmidt**: Zooming out just a bit, you mentioned that this is a PR in a
larger effort to improve outbound peer selection, and this leads to one of the
questions that we highlighted in the newsletter which is, why would it be
beneficial to have an outbound connection to each network at all times?  Maybe
speak to the broader motivation.

**Martin Zumsande**: Yeah, I think there are different reasons.  One thing is an
audit for the entire network of all subnetworks to keep together.  It's
important that there are nodes that make connections to more than one network.
Otherwise, if everyone would only be in their own networks, there wouldn't be
any connections and there wouldn't be partitions of the network, and information
wouldn't go from Clearnet at all; that would be very bad.  So, it's important
that some nodes do this.  And so what I'm trying to do is, the nodes that will
volunteer to do this, that they actually get the connections, because currently
a node might say, "Yeah, I want to be on", I don't know, "CJDNS and Clearnet",
and then they have thousands of Clearnet addresses and only 100 CJDNS addresses
and then they make no outbound connections to it, because there is no management
currently, it's just randomness.

What the bigger effort is, is to introduce a logic that helps a node to be at
all times, he would like to have at least one outbound connection to each of the
networks that we support to be on.  I think this helps the network, and it also
is helpful for the node itself, I would say, because having more networks to be
connected on will improve resistance against eclipse attacks.  So, an attacker
that would try to cover all of your connection slots would then also need to be
active and dominant on all of these networks, which is a lot harder to do than
if you are just on one network.

**Mike Schmidt**: So, as a node operator, I help myself by preventing eclipse
attacks against me, which is a reason, as a node operator, to want to do that
for themselves.  And then additionally, by bridging all of these different
networks that Bitcoin Core supports, you're also then preventing a potential
partition within the network that may happen if there are different subgroups
that are on different networks; you're bridging that so the partition doesn't
happen.

**Martin Zumsande**: Yes.  And currently, node operators who want to do this,
they can do this by opting to make manual connections.  So, they will pick some
peer from a network and manually say, "I want to always make a connection to
this", and this is nice and it's good, especially if you trust that peer.  But
it would also be nice to have this kind of thing automatically, have automatic
support, so for people who don't want to go to the trouble of managing their
connections and then checking if this manual peer is still online, or maybe
they've gone offline, so maybe we need to pick another manual peer.  So, there's
a lot of manual management there which it would be nice if this could all work
out of the box that we always connect to all of the networks.

**Mark Erhardt**: So, basically a manual workaround before your PR would have
been that you run two nodes, one node that is only on the alternative network,
like Tor for example, and one that is on the Clearnet.  And then, since you
trust your own nodes, you connect those two nodes to each other; that way you
make sure that you have a minimum amount of connections on either network.  But
of course, that's twice the work.

**Martin Zumsande**: That's not actually what I meant.  I mean, that's a
possibility, but that's way too much work.  You can specify up to eight manual
connections from this one node you have, and you can say, "I want to make a
connection to this one friend which is on IPv4, and I want to make another
manual connection to this other friend which is on Tor", and I can have both of
these at the same time with one node; I don't need two nodes for this.

**Mark Erhardt**: Right, okay, sure.  So, that would have been overkill really
with the two nodes.  But anyway, with this patch essentially we're making this
happen automatically, because each network that we want to support will have at
least one connection at all times.

**Martin Zumsande**: Yeah, but that's still work in progress.

**Mark Erhardt**: What, it's not done yet?!

**Mike Schmidt**: Well, thank you, Martin, for your work on this.  I think it's
important to make good behaviour, if you will, or productive even for the
individual node operator, as well as benefiting a network, something that is
default, so we applaud you for that.  We should also note that while I did say
that Martin was the author of this PR, and that's true, also Amiti contributed
to this, so thank you to her.  Anything else that you think is important on
this, Martin, or Murch?

**Mark Erhardt**: I'm good.

**Mike Schmidt**: Okay, great.  Thank you for joining us, Martin.  You're
welcome to hang on as we go through the rest of the PRs in this newsletter, or
you're welcome to jump off and work on the next PR to facilitate this project!

_Bitcoin Core #25880_

**Mark Erhardt**: Actually, looking at the next PR that we will be talking
about, Bitcoin Core #25880, it's pretty useful that Martin is here, because he's
the author of that PR as well!  I mean, it would feel silly to explain to Martin
his own PR, so I'm going to ask him to maybe give an overview of that one as
well.

**Martin Zumsande**: Yeah, this is a completely different thing.  It's about
stalling, and the background is that sometime earlier this year, I did some
Initial Block Download (IBD) on a very slow connection and I would see in the
log that there would be like, "This peer has been stalling, is getting
disconnected, and another peer's getting --" so all of my peers, one after
another would get disconnected, and for a couple of minutes I would make
absolutely no progress during IBD and I was wondering what the hell is going on
there.  This is basically an effort to fix this kind of thing.  It only happens
if you're doing IBD on very slow connections.

The problem with stalling during IBD, we do like a parallel download of blocks
from different peers, but we have only so many blocks ahead that we download, so
I think it's 2,024 blocks we do ahead of our current tip that we have connected
to the block chain, we download all these blocks in advance.  And at some point,
if we cannot make any progress because these 2,024 windows are exhausted and we
need the first one from this window in order to connect you to the block chain
and let the window slide further ahead, in that case we are in a stalling
situation.  This only happens if some of our peers are faster and some of our
peers are slower, and one slow peer is stalling all the progress there.

So, the question is, once we are in this situation, how do we deal with this?
What we did before, and still do, is we give this stalling peer two seconds and
then we disconnect it if they don't give us a block.  And that is fine, because
that peer has been stalling a block download for a long time probably, and the
two seconds are kind of a last resort and then we just don't want to have it
anymore and try to get the block from another peer.  So, the problem is the
second peer then; we would also only give it two seconds and if it doesn't give
us the block in two seconds, then we would kick it again and then go to the next
peer.  This would be a cascade of failures if we are just not able to download a
block in two seconds because our connections are too slow.  Maybe we're on Tor
or something and we need five seconds for a block, or four seconds, because it's
just our connections, and this was the problem there.

The fix that was merged for this is that we do this like an adaptive phase.  So,
we still give the first peer only two seconds, but then we double it for the
next peer.  So, the next peer gets four seconds to give us a block and if they
do this fine, then we have made progress; and if they don't, they get kicked
after four seconds.  And then the next peer gets eight seconds, so it has even
more time, and hopefully then this peer will give us a block in these eight
seconds and then we can connect other blocks and make progress and continue with
IBD.

So, that's what this PR basically did; it made this timeout adaptive, not only
two seconds as a fixed value, but double it.

**Mark Erhardt**: I wanted to jump in and reiterate a little bit how the
situation comes to pass.  So, in Bitcoin Core when we're not at the chain tip,
we're just trying to get all the block data.  We don't participate in
transaction gossip, we don't trade addresses much, we're only connected to
outbound connections and ask them to give us a copy of the block chain.  Because
it would be really slow to only get the next block and then wait, process that
and get the next block after that, we create a buffer of blocks that we want to
process.  So, we download the next 1,024 blocks from all of our peers.  So, to
the eight or so peers that I have, I go, "Could you give me this block, could
you give me that block", and so forth.  And when every one of them has given me
one of the next few blocks, I tell them to give the next one that I don't have
yet.

So, if one of our connections is super-slow and still working on that first
block that we asked him to give us, and all the other nodes have provided all
the blocks up to 1,024 in the future, then we stall, we cannot make progress,
because of course to process the block chain, we still have to locally read the
blocks in order, and adapt the UTXO set to the inputs and outputs that were on
the transactions.  When one of them is still promising to give us the next block
and hasn't delivered yet and we have 1,024 other blocks waiting or requested,
then we kick it.  Then the whole situation that Martin explained comes to pass.

I think the last thing from the writeup that comes to mind is, as soon as we
start getting blocks again, we will start scaling back the timeout again.  We
double it each time we don't get a block, but then once we have that block, of
course we will also have a few stored very likely ahead, like a buffer of work
to go through, and we also start scaling back the timeout block-by-block.

**Martin Zumsande**: Yeah, that's correct.

**Mike Schmidt**: Somewhat timely of a PR as well, since we recently had a 4 MB
block, right?

**Martin Zumsande**: Yeah, that would have been a candidate to lead to this kind
of situation, definitely.  I also like the two seconds.  It was suggested a long
time ago at a time where blocks were much, much slower, so it wasn't probably a
problem back then, because the blocks were so small then.  And first segwit came
and made the physical amount that you need to download larger and blocks also
were getting fuller.  So, at the time when this was suggested, this two seconds
made a lot of sense, I would say, because blocks were maybe, I don't know, 100
kB or 500 kB, or something, but now it doesn't really make that much sense
anymore, because all connection speeds scaled in the same way that the blocks
became larger over time.

**Mike Schmidt**: Thanks for walking us through that PR, Martin; I missed that
you were the author.  It's perfect that you were able to join us and walk us
through that.

**Mark Erhardt**: I think we can move on to the next one.  We have a lot of
Lightning stuff this week.  So, it looks like Core Lightning (CLN) is gearing up
for their next release and they're merging a few things.  I think that's led to
us having four PRs, or five actually mentioned here.

_Core Lightning #5679_

So, Core Lightning #5679 adds a new plugin.  I think Rusty added this so that
when you query your CLN node and want to list some information that your node is
tracking, like your channel connections or your peers, that you can actually
also run SQL queries directly on the result of that list.  So, rather than
needing to get the data, then put it into some other SQL database in order to
search it, you can search directly on the results.

**Mike Schmidt**: Yeah, that seems really useful.  Even there's some Bitcoin
RPCs that I know I've written code in the past that would have to then go
through after you get the list, and then filter it client-side.  Whereas this,
you provide the query that does the filtering on your behalf, so it seems like a
useful feature.

_Core Lightning #5821_

Next PR here is Core Lightning #5821, which adds preapproveinvoice and
preapprovekeysend RPCs.  That essentially, if you're attempting a payment, you
need to get a signature, and for CLN they have this signing module that will
sign for you.  But these PRs add the ability to essentially make sure that, "Is
the signer going to sign for this?" so there could be some policies in place or
rate limiting, etc, in which case the signer wouldn't sign.  And the way to do
that now is just attempting the payment and then failing; whereas, these PRs
allow you to say, "Are you going to sign for this?" and then you can make sure
that you don't attempt what you have the potential knowledge of would be a
failed payment.

**Mark Erhardt**: Yeah, sounds like people are really starting to think of how
to make Lightning work for bigger businesses than run Hardware Security Modules
(HSMs) and have a lot of funds in their nodes.

_Core Lightning #5849_

**Mike Schmidt**: Well, speaking of large Lightning nodes, the next Core
Lightning PR #5849 made some backend changes to allow a CLN node to handle over
100,000 peers, each with one channel.  I think this was sort an exercise to see
where the performance bottlenecks would be in doing such a thing, because as we
know in the newsletter, it would take a dozen blocks or more to open that many
channels if you were just monopolizing the block space.  I think it's an
interesting way to think about trying to find performance improvements in CLN.

_Core Lightning #5892_

Next PR here is another Core Lightning PR, it's #5892, and actually t-bast did a
quite comprehensive writeup that's referenced in this PR, and there's a ton of
data and ton of information and even some diagrams showing how there's some
compatibility testing that he had done that points out some incompatibilities.
This Core Lightning PR fixes a bunch of those with regards to the offers
protocol compatibility.

**Mark Erhardt**: Yeah, so we talked about BOLT 12 a few times in the past few
months.  This is something that is gearing up to happen.  It is essentially a
drop-in replacement for the BOLT 11 invoice protocol with even more
capabilities.  And, my understanding is that CLN and Eclair have
interoperability on testnet now.  Lightning Dev Kit (LDK), I think, is starting
to work on BOLT 12 support.  They have a few small parts ready, but aren't quite
there with the interoperability yet, whereas LND does not seem to be working on
BOLT 12 yet, from what I understand.

_Eclair #2565_

**Mike Schmidt**: We now have Eclair PR here #2565 that requests that funds from
a closed channel go to a new onchain address, rather than an address which was
generated when the channel was funded.  Murch, I don't know why that's the case.
Wasn't the address that was generated when the channel was funded also a new
onchain address that in theory wouldn't be used?  I guess I need some education
on this one.

**Mark Erhardt**: I was wondering the same thing.  I would expect that if you
make a Lightning channel and generate an address as the dedicated closing
destination afterwards, that you would keep that dedicated to that channel's
closing amount.  But it seems to me that maybe Eclair here would generate a new
address and as long as the address hadn't been used yet, it would use the same
one as the closing destination for multiple channels.  So, either way, when you
make a bilateral close, like close a channel in cooperation with your channel
partner, then you can send the money wherever you want anyway, because it's just
a matter of negotiating with the channel partner.

It seems to me that they are making use of that here to just say, "Let's see if
we might want to give a new address instead of the one that we had negotiated
potentially months ago", but I don't know for sure what exactly the cause was
that the address wouldn't have been fresh.

**Mike Schmidt**: Yeah, that was the only thing I could think of as well, is if
the fund where you would get the channel closing would potentially be reused.
That was the only thing I could think of.  Obviously, a lot of things could
happen in the months that a channel could be live, so there could be various
reasons that you'd want the funds to go somewhere else.  So, I guess it makes
sense to provide this, regardless.

**Mark Erhardt**: I mean, one downside of keeping a lot of addresses set aside
for closing channels would be that you would have a very big gap of addresses
that didn't get used.  So, maybe that's the concern here.

**Mike Schmidt**: Yeah, I guess if you open up hundreds of channels, then I
guess depending on the gap limit in the software, that could potentially be an
issue.  But I guess we're just theorising at this point.

_LND #7252_

Next PR here is from LND #7252, adding support for SQLite as LND's database
backend, and that's only supported on new LND installations, and there is no
code for migrating from an existing database.  I think that by default, does it
use Postgres in LND, do you know?

**Mark Erhardt**: I dimly remember that they had other work to migrate to, yeah,
Postgres; I'm not 100% sure whether that is now the backend by default.  LND
used to have a self-written what was just a value data storage key value pairs
or something.  It got a lot faster when it went to Postgres, was my
understanding.

**Mike Schmidt**: Yes, I think I forget the name of the key-value store;
e-something?  But yeah, they had a key-value store in Postgres as potential data
sources as well.  So now, you have SQLite.

_LND #6527_

Last PR for this week is LND #6527, adding the ability to encrypt the server's
on-disk TLS key.  So, it sounds like LND uses this TLS key for authenticating
remote connections if you're controlling your node remotely, and that right now
that TLS key was not encrypted and was sitting in a plain text file, which is
someone got access to that, they could spy on your communication with your
server; whereas now, this TLS key is encrypted and needs to be unlocked before
using it.

**Mark Erhardt**: That sounds like we got through all of it.  I'm glad that we
had so many guests today and they brought all their expertise to explain their
PRs to us, and their newsletter and mailing list posts!  So, yeah, I think we
got it all in.

**Mike Schmidt**: Excellent.  Well, thanks to my co-host, Murch, thank you for
Martin, special guest joining us, and thank you for Carla as well for joining us
and we'll see you back here next week where we recap Newsletter #238.  Thank you
all for your time.

**Mark Erhardt**: Bye.

**Mike Schmidt**: Cheers.

{% include references.md %}
