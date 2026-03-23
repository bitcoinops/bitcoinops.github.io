---
title: 'Bitcoin Optech Newsletter #396 Recap Podcast'
permalink: /en/podcast/2026/03/17/
reference: /en/newsletters/2026/03/13/
name: 2026-03-17-recap
slug: 2026-03-17-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Jonathan Harvey-Buschel to discuss [Newsletter #396]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-2-17/420221497-44100-2-6ec15cadb2353.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #396 Recap.
Today, we're going to talk about a collision-resistant hash function for Bitcoin
Script that is quite wild, and we also have some discussion following up a
previous item that we covered, Gossip Observer for the LN, analyzing some of the
traffic there.  This week, Murch, Gustavo and I are joined by JHB.

_Collision-resistant hash function for Bitcoin Script_

We'll do the first news item first, "Collision-resistant hash function for
Bitcoin Script".  This was a Delving post referencing a paper written by Robin
Linus.  You may be familiar with his work that we've covered previously.  We've
had him on also to talk about BitVM, BitVM 2, 3, and some of the work around
bridges.  This time, he posted to Delving about this whitepaper about Binohash
which, without any consensus changes, does enable some limited transaction
introspection, so the ability to look at the actual transaction itself using
only the existing script primitives.  And for Robin's use case, he's thinking
about BitVM and he's thinking about these BitVM bridges, where coins are sort of
locked and then accessible on some sort of second layer side chain.  But there
is some interactivity with the layer 1 Bitcoin, and it's advantageous for things
like BitVM bridges to be able to see certain things like, "Did this certain
payout happen?" etc, within the transaction.  There's no good way to do that
now, so they have different schemes to compensate for that lack of
introspection, which could be provided by something like covenants, but we don't
have covenants in bitcoin.  So, he's worked around that with this Binohash
proposal.  Murch, I know you've looked at the paper a bit.  Do you want to get
into some of how that is achieved, how this introspection is achieved?

**Mark Erhardt**: So, it looks like it uses some weird construction that is
based on bare multisig, and it uses the FindAndDelete opcode, I guess, to delete
some of the signatures out of that, which allows it to have some covenant-like
properties.  I did not have time to fully read the paper, but it sounds to me
like it uses a lot of data to achieve some fairly low security with a lot of
grinding on top of it.  I skimmed a bit through the paper and I saw some
figures.  I don't know if that was the right figures, but it looked like 8,000
bytes for about 50 bits of security, although the paper does overall say it
achieves 80 bits of security.  But it looked to me like it would basically write
a pretty big blob of data.  And then, the setup also requires grinding for about
$50 worth of compute to set it up.  So, I think we're sort of in this arc, as in
story arc, where a lot of people are inventing covenant-like constructions that
can be done without consensus changes right now, presumably because people feel
that there's little hope that a covenant will actually manifest anytime soon.
And this is interesting and it's cool that it works, but extremely blockspace
inefficient and apparently also computationally inefficient.

So, from my very superficial understanding -- and I hope next time we have Robin
or Liam on, they can expound on this -- this seems like another proof-of-concept
sort of thing that does work, but doesn't seem very practical in production.  I
also saw that it's based on lamport signatures.  So, that's a very old
quantum-resistant signing scheme that is based on big blobs of data that you can
only use once.  But anyway, it seems more like a proof-of-concept academic sort
of paper, rather than something that will be rolling out to the network anytime
soon.

**Mike Schmidt**: So, it uses bare script and you noted some of the quirks of
the approach.  Does this mean this would not be something that would be relayed?
This is a non-standard transaction, and it would have to be mine separately?

**Mark Erhardt**: Oh yeah, very explicitly this is non-standard because it uses
FindAndDelete, I think, which I don't remember whether that was the reason it's
non-standard, but it basically is non-standard for multiple reasons.  On the
policy level, it is consensus-valid.  But there's also the problem that it
operates just below the maximum number of opcodes and the maximum script length
for scripts to not be invalid generally, which is 10,000 bytes for legacy
script.  So, I think it's sort of squeezing into the corner on a bunch of the
limits.  Non-standard transactions, definitely.

**Mike Schmidt**: Large transaction, you're going to spend tens of dollars in
fees even at current feerates, you're going to spend fifty dollars grinding to
get the appropriate hash, it sounds like.  So, expensive, but maybe for these
bridges, that's worth it to them.  And then obviously, there's the concern about
not being able for this to be actually relayed.  So, then you're talking about
out of band to slipstream or whatever else.  But obviously, interesting quirks
being used here.  An exotic protocol, but maybe not practical?

**Mark Erhardt**: I'm also wondering now, as you were saying, all the signatures
and legacy script.  So, of course, we have the quadratic hashing problem in
legacy script.  And if you're writing 10,000 bytes of signatures, well, again, I
didn't dive very deep, sorry.  I wonder whether this might be sort of getting
close to the poison transaction sort of constructions that are extremely
expensive to validate.  So, overall, there are many open questions here, I would
say.

**Mike Schmidt**: There is a funny note in the acknowledgments of the paper
itself, "We apologize to Pieter Wuille for abusing the Bitcoin Script
interpreter so badly".  So, that was kind of funny to see in a whitepaper like
that.  I think we've done all that we can do on this item.  What do you think,
Murch?  All right.  We'll bring back in JHB.  JHB, do you want to introduce
yourself real quick for the audience and we'll move into your news item?

**Jonathan Harvey-Buschel**: Sure, yes.  Jonathan.  I've been working on various
kind of projects running in the LN for a while, and this latest project is
basically just looking, trying to collect some data on like how the LN gossip
layer is working right now, and from that trying to see what issues may exist,
compared to items or complaints I hear from actual node runners, like can I find
evidence of those issues, and then use that to inform some upcoming kind of
protocol changes or design decisions.

_Continued discussion of Gossip Observer traffic analysis tool_

**Mike Schmidt**: Well, thanks for joining us.  The news item's titled,
"Continued discussion of Gossip Observer traffic analysis tool".  And we did
cover Gossip Observer a few months ago, I think we covered it in a Client
services monthly segment and not necessarily a News segment.  But this thread, I
believe, on Delving has grown and we decided to revisit it, and that was a good
opportunity to now bring you on to actually talk about it instead of us talking
about it on your behalf.  You sort of touched on it a bit, but what exactly are
you looking for and why?  Gossip Observers, so Lightning gossip messages, but is
there an end goal that you have out of this?  Obviously, collecting the data
will give you a lot of information, but did you have sort of an angle you're
working towards?

**Jonathan Harvey-Buschel**: Yeah.  Well, I guess the name sort of half gives it
away because it's similar to the names that 0xB10C uses for his monitoring
projects.  It was intentional.  But there's sort of two main goals.  One is to
have something similar to mainnet observer, where if I'm collecting a bunch of
data in the background, maybe we can start to have some sort of detection of
anomalies of like, "Hey, these metrics that we're looking at every day or every
hour just changed a lot.  Maybe something's going on and maybe that's a problem
or that's some network issue that could be looked at".  The primary goal is
really to inform gossip changes that are coming up with the introduction of
taproot gossip.  The gossip is already changing to support taproot channels and
there's been some interest for a while in also changing how messages are
actually propagated in the network, alongside changing the message format.

So, the message format is changing and people are interested in also changing
like, should these messages be flooded to your peers in the same way they are
now?  Will the current mechanism be able to keep up with the size of the network
as it grows or if we keep adding channels or new nodes, will we start to have
even more issues with what we have now?  So, we should look at some alternative.
The proposal right now is trying to use minisketch in some way to save
bandwidth, similar to the old Erlay paper, and some ongoing work I know from
other people.  I think Sergi is looking at that for Bitcoin Core these days.
So, something in that direction of trying to inform some actual PR on the BOLT
repo, like this is what we should do with these parameters, because they get
informed by this data that is being collected.

**Mike Schmidt**: Okay, so a few different potential uses for the data.  One is
informing set reconciliation or minisketch.  People may know Erlay-based
gossiping versus just the flood method now, as well as this transition to simple
taproot channels and changes along with that, and then observing those; in
addition to potentially, even if those weren't happening, general observations
and maybe being a little bit of a watchtower over the network.  If something
gets interesting, you could report on it and potentially more proactively engage
with whatever that threat or anomaly is.  Are you running one server?  Maybe
talk a little bit about the setup.

**Jonathan Harvey-Buschel**: Sure.  So, it's, I think it's 21 different LN nodes
that are collecting data from other LN nodes.  I think 6 of those have channels,
so that means that I can send to channel-update messages.  You can't send a
gossip message in the LN without having a channel, so I need to open some
channels for that.  But basically, looking at just the nodes and the payment
channels they already have, the public channels, I tried to split up the network
in some way based on, this group of nodes, they all have channels to each other,
and this other group of nodes over here only makes channels to 1ML, or something
like that.  And then, after I had these sort of communities or this split-up of
public nodes, just connect to each group that I had, each community, and collect
data from those, and then I've got some big Postgres database that's ingesting
all of that.  And then, I can run some queries over that later and try and use a
metric.

**Mark Erhardt**: You said you are running 21 nodes, 6 of which have channels,
so 15 do not have channels.  I'm just curious, is that a monoculture or are you
running different types of LN nodes?

**Jonathan Harvey-Buschel**: Yeah, I have a small fork of LDK node that's just,
I picked that because it seemed like the easiest implementation to actually have
a small patch on so I could directly collect raw messages from the wire.
Because if I'm collecting the message with the signature, that's also useful for
playing back messages in some future simulation situation.  Since the messages
all have to be signed, it can be useful to just have the message without any
filtering or other changes that other implementations may make.  There's some
other techniques people have used in the past to try and collect this data, but
I figured a fork of LDK would probably be easiest.  So, yeah, I may try and
deploy some fork of LND at some point, but right now it's just all LDK now.

**Mike Schmidt**: Are you the only collector of this information, or I know
historic information for 0xB10C's projects, people have provided additional data
and even historical data in some cases for certain things; is that something
that you're open to or are doing, or is this sort of you want to be guarded with
the data that you're collecting at this point?

**Jonathan Harvey-Buschel**: So, right now, I guess for this system, the Gospel
Observer project, all the nodes that are collecting data that gets stored by me
are just under my control.  But there are two other people that appeared on this
thread that I also talked to outside of the thread that collected data with a
slightly different methodology.  But I think one of them, Fabian, he's
collecting data in an ongoing basis.  He's running Core Lightning (CLN) nodes
for that.  And then, someone else, Jan-Philipp, I think, who collected data for
a specific period of time.  I think he was using a custom fork of LND.  So, I'm
talking to them to kind of see, maybe even if all the data doesn't necessarily
end up in public, just being able to kind of compare and try and have some
conclusions from just intersecting our data sets to see what differences appear.
I know for Fabian's infrastructure, for example, he's just running stock CLN and
it makes its own choices on which peers to connect to, using the defaults, which
is not what I'm doing.  So, that's interesting in terms of like, are his timing
observations very different from mine, or he has some other interesting metrics
about how different the graph view is for the two nodes he's running.  Just
something I'm also looking into, but kind of a work in progress.

There's one other concern node operators have is like, "Are my messages really
getting to all the nodes they're supposed to get to, or is there some pocket of
nodes that maybe they're missing my messages and they don't know my channel
exists, or they don't know my current feerate, so they wouldn't be able to tend
to payment over my channel?"  It's a problem we definitely want to address in
any gossip changes.

**Mark Erhardt**: So, I attended a BitDevs recently, where this topic was
discussed.  And one of the things that I thought was very interesting was that
we touched on how the LN gossip is very different from the gossip on the Bitcoin
Network.  And so, because I thought that was interesting in this context of, "Do
messages go to places?  Is everybody hearing my messages?  Do they know about my
channel?" could we maybe talk a little more about how the gossip on the Bitcoin
Network and the gossip on the LN differ?

**Jonathan Harvey-Buschel**: Sure.  So, for the Bitcoin Network, if we just
think about how transactions are intended to be propagated, ideally the network
as a whole doesn't know exactly where the transaction came from.  So, the
privacy of the source of the broadcast or of the message is really important.
But you also have this competing priority, which is that you want the
transaction to propagate as fast as possible, right?  The transaction, you
intend to get into a block and you don't want it to take, I don't know, an hour.
Ten minutes maybe is an acceptable number, but ideally, it would be fast.  So,
that's the situation there, you have privacy and speed.  Whereas for the LN, all
the messages are already signed by the node generating them, and they're
intended to be public.  You want them to be as widespread as possible, but
there's not really a privacy concern about where they're coming from.  That node
is already announcing an IP address or a Tor address, it's already signing
everything, so you don't really have this privacy concern.

There is a separate consideration where if I'm announcing a change to my
feerate, I'll actually still honor the old feerate for a few minutes.  So, they
don't need to propagate necessarily as fast as possible, but you do need to get
these messages to propagate eventually, because if they don't, you may cause
failed payments or just bad routing decisions by other people because they have
stale information on your channels.  But yeah, it does simplify a lot of the
kind of design choices, because you don't need to worry as much about privacy.

**Mark Erhardt**: Right.  So, the transaction relay in Bitcoin is a best effort
but not reliable necessarily.  We don't have to guarantee that every transaction
reaches everyone.  Blocks obviously have to reach every node and they are
propagated extremely quickly.  In LN, the channel announcements and channel
updates, they should also be received by everyone, but you have a few minutes
basically to achieve that, because the nodes accept the old feerates before they
totally switch over to the newly announced feerates and you're just not going to
use a channel you don't know about.  So, it's not that bad if you don't know
about a channel for a couple of minutes.  So, maybe in that sense, it would be
more compatible with the trade-offs that Erlay is making.

So, Sergi had been working a bunch on the adoption of the Erlay style
transaction propagation in Bitcoin Core, but in Bitcoin Core, the transaction
propagation also limits how quickly blocks can be propagated.  So, when
transactions are missing, more nodes need to ask for the missing transactions in
order to reconstruct the blocks, and that introduces additional round trips.
But the most recent version that I read was proposing that for every transaction
you receive, you flood it to three peers, two or three peers, and then the rest
of it is reconciled with the minisketch approach that Erlay uses, where you just
compare what you would be announcing to each other and then find the
differences, and only ask for the ones that you're missing.  And so, I'm just
thinking, what you described might be more compatible with that because you have
a little more time for the announcements to propagate.  You still need to flood
them out in order to make the differences small between the comparisons of the
announcements, because minisketch is only efficient if the difference is small.

But maybe, well, on Bitcoin nodes, you might have 125 connections, so you don't
want to propagate the same transaction information, even if it's just a header
125 times on every single connection.  I don't know.  How many connections do LN
nodes make actually?

**Jonathan Harvey-Buschel**: Yeah, the default right now is basically five to
ten P2P connections, but that's not really counting your channel counterparties.
So, with most implementations, you're also going to send and receive gossip
messages with your channel counterparties, but not everyone has five or ten of
those.  The other thing worth bringing up here is right now, each
implementation, they don't flood any messages immediately.  They normally build
up a batch of messages and then flood every 60 seconds.  So, this introduces
some natural delay that we already have, which means if we switch to a
minisketch-based approach or some mixed flooding and minisketch, we don't
necessarily need to aim for a propagation delay that's much lower than what we
have right now.  I think the real issue is just making sure that everyone
eventually gets a message, not necessarily just making it fast.

**Mark Erhardt**: Yeah, but the delay is mostly to reduce the overall bandwidth,
I think, right?  So, if you did Erlay, where you minimize the amount of things
that get announced to each other by just finding the differences between what
you would announce to each other, you might actually be able to announce more
often in the same bandwidth.  So, it might actually allow announcements to
propagate faster without using more bandwidth in LN.

**Jonathan Harvey-Buschel**: Yeah.  I mean, this is something I need to look at
in simulation or some sort of modeling, but there's the same consideration of
maybe I want to keep the minisketch timer relatively long, but I want to
reconcile with my peers in some staggered ordering, so that if one peer has a
message I don't have, I have time to reconcile with them and include it in my
set so that for the next four peers, I'll be able to spread that message to
them.  Or maybe I decide to flood it and that reduces the differences.  It's
sort of the number of expected differences is something you need to dig into to
actually compute.  This is what I'd expect with how many messages we see right
now.  I think right now it's like 300 messages a second, or something.  There's
a fair amount of traffic.  And we could say, if the network grows in this way,
this is how we expect that to change.  And the parameters we pick now are still
going to be fine, at least for a while.  I just need to dig into that more.

**Mike Schmidt**: Awesome.  JHB, anything else as we wrap up this item?  Any
call to action for our listeners that could help out, or dig in for more
information?

**Jonathan Harvey-Buschel**: Yeah, I'd say definitely, I think I'd like to have
some sort of private kind of closed beta API up soon for node runners, or other
people currently participating in the network to use, to see, like, are my
messages getting widely propagated, or what does the timing look like for my
specific set of messages that I'm producing?  So, if there's features that you
think would be very useful to you in some sort of API like that, definitely let
me know.  Should be reachable via Twitter DMs or Delving, I think, has DMs as
well.  That's probably better, honestly.  And otherwise, I mean if you're some
of the people listening to this that are collecting their own data, definitely
chime in on that thread.  So, I know there are a lot of companies that run
infrastructure that probably have their own kind of internal metrics and their
own observations of this.  If there's some issues that you see with your own
infrastructure, definitely let me know and I can see what I see on my side.
Maybe that's something other people are having.  I guess, yeah, just feel free
to DM me with any sort of requests or just comments of like, "Hey, this issue
always pops up for me.  Do you have any ideas?" things like that.

**Mike Schmidt**: Awesome.  Thanks for your time, Jonathan.  Thanks for joining
us today.  You're free to stay, but you're also free to drop.  Cheers.  This
would normally be our monthly segment where we talk about a PR Review Club, but
there have not been Bitcoin Core PR Review Clubs for the last few weeks and
months.  And so, if you're curious why we haven't been covering that, that's
why.  Which means we move right into Releases and Notable code and documentation
changes, authored by our friend and co-host here, Gustavo, who will help walk us
through them.

_BDK wallet 3.0.0-rc.1_

**Gustavo Flores Echaiz**: Thank you, Mike.  Thank you, Murch.  That was an
interesting conversation.  Let's dive into the releases.  So, this week, we
simply have a BDK wallet 3.0.0-rc.1.  So, this is a major version of BDK that
introduces a few takeaway features.  The first one is a persistence in how a
UTXO is locked, and basically a new table inside the SQL database to track UTXO
lock status.  And what does it mean to lock a UTXO?  It means that I could
reserve a UTXO to be used in a future transaction and my wallet wouldn't ever
try to take that UTXO into another transaction, right?  So, I can reserve it for
future use.  And this would previously not persist through restarts.  However,
this state now lives in the database, which allows it to persist across
restarts.

Another major update of this release is the structured wallet events.  So,
basically, when you had a wallet event, you couldn't receive specific callbacks
related to the change of the status of a transaction, for example, when a
transaction was newly seen in the mempool, replaced, dropped from the mempool,
then confirmed in a block.  This release introduces wallet events that let you
know about the change of status of a specific transaction.  And then also,
there's also other features such as the addition of NetworkKind, which is
basically an easy structure that allows you to detect whether you're using
testnet or mainnet, so this can be used by other parts of the code.  And
finally, just additional support for new wallet formats, specifically for the
Caravan project, which has been covered in a previous Bitcoin Optech Newsletter,
exactly Newsletter #77, which is a multisignature open-source wallet tool; and
just a special migration utility for SQLite database migrations with previous
versions.

So, this is the first RC out here for testing and we should expect, in the next
few weeks, the official release to come out.

_Bitcoin Core #26988_

So, we continue with the notable code and documentation changes.  This week, we
have two on Bitcoin Core.  The first one, this CLI command called -addrinfo, or
address info, that used to return a subset of the full set of known peer or node
addresses, will now return the full set of known addresses instead of the subset
that was filtered for quality and recency.  So, how does it achieve that?  It
replaces the RPC that was used behind the command.  It used to use
getnodeaddresses and now it uses getaddrmaninfo, which is a newer version that
will basically return the whole set instead of a subset.  So, now, you're
obtaining all the data you would like from this endpoint.  Also important to
note that if someone is running a different version of bitcoin-cli than his
Bitcoin node, this would be incompatible with bitcoind versions that are earlier
than v26, because the underlying RPC was added in v26.  But this only affects
users that have complex setups where they use a different version for the
bitcoin-cli than for bitcoind.  If you're using the same version altogether, you
wouldn't have this incompatibility issue or risk.  Any addition here?  No?
Perfect.

_Bitcoin Core #34692_

So, the next one, Bitcoin Core #34692.  Here, there's an increase of the default
values used in the setting dbcache that was set on to 450 MiB.  it's now
increased to 1 GiB, specifically on 64-bit systems that have at least 4 GiB of
RAM.  Else, it falls back to the previous setting of 450 MiB.  So, this change
only affects bitcoind.  If you're using the kernel library that we've covered in
previous newsletters, then you retain the previous default value of 450 MiB.
Also important to note that a larger dbcache is useful specifically at the
moment of IBD (Initial Block Download) and for the performance in that process.

_LDK #4304_

So, the next one, we have two on LDK.  The first one is a refactor of how HTLCs
(Hash Time Locked Contracts) are forwarded, specifically for trampoline routing.
So, here, there's an update in how LDK forwards HTLCs to now support multiple
incoming and outgoing HTLCs per forward.  So, basically, the way it was working
before is that LDK's code assumed that when an HTLC came out, one in, one out.
So, every time an HTLC resolved, it would only apply to an HTLC that came in, an
HTLC that went out.  However, when you're doing trampoline forwarding, the
sender might be sending you multiple HTLCs split using MPPs (Multipath
Payments).  And once you're the trampoline node and you're sending it to the
receiver, you might also use MPPs to get to your target.  So, how can an LDK
node that acts as a trampoline routing node forward multiple HTLCs and act
basically as a MPP endpoint on both sides?  So, the structure is rebuilt to
accumulate multiple incoming HTLC parts, find a route to the next hop to the
receiver, and splits the forward across multiple outgoing HTLCs as well.

So, there's a new variant called TrampolineForward that tracks all the HTLC
states related to a TrampolineForward.  Also, there's a claim and failure
handling added, and also a trampoline-specific channel monitor recovery is also
implemented.  So, for example, if the node restarts in the middle of the
forward, it would need to reconstruct the state of all incoming and outgoing
HTLCs.  So, a specific channel monitor recovery, specific to trampoline
forwards, is implemented for that.

_LDK #4416_

Next one, LDK #4416.  Here, there's an extension of the splice protocol that
occurs when both splice peers try to initiate a splice at the same time.  So,
when that happens, there's the quiescence protocol that basically would
determine which one would be selected as the splice initiator.  Previously, if
two nodes would try to initiate a splice at the same time, one would win and
that would be the one to open the splice; and the one that would lose would
simply be the acceptor and not be able to commit any funds.  So, what this PR
does is that it enables the acceptor, the one that lost the tie break, to
contribute funds as well in the same splice transaction.  So, it effectively
adds support for dual funding on splice transactions.  So, because the acceptor
had prepared to be the initiator, the main work done in this PR is the
adjustment of the fee he pays, right?  Because in the splice, the initiator
covers the fees of those common transaction fields.  So, a lot of the work of
this PR was adjusting that the one who became the acceptor, the one who lost the
tiebreak, his fees will be adjusted from the initiator rate, which was going to
cover the common transaction fields, to the acceptor rate which only covers the
fields that are only specific to himself.

So, now, the splice_channel API also accepts a new parameter to target a
max_feerate.  Because, for example, when you're the acceptor, the initiator
would lead with the feerate.  So, now that there's dual funding on splices, as
the acceptor, you would want to be able to target the max feerate that you would
be willing to pay as the acceptor that also contributes funds to a splice
transaction.

_LDN #10089_

So, the next one is LND #10089.  Here, we advance in the implementation of
BOLT12 support for LND by officially adding onion messaging forwarding support.
In Newsletter #377, we covered that there was some message types and some RPC
endpoints that were added that were definitely the structure required to add
onion messaging forward support.  And now, in this PR LND #10089, we're finally
at the moment where all of these message types and RPCs are used to implement
official onion message forwarding support.  So, there's also a flag that can
allow to disable this feature, called --protocol.no-onion-messages, and a wire
type called OnionMessagePayload will decode the onion inner's payload.  And
there's also a per-peer actor that handles decryption and forwarding decisions.

So, I looked specifically at the epic or the issue that tracks BOLT12 support.
And this addition, this merged PR, basically completes, or at least is the last
one before the last to complete the stage one of implementing forwarding onion
messaging.  The next two stages are about pathfinding for onion messages, and
the final stage is offer creation and invoice request handling.  So, quite
exciting to see LND move forward on this support.  Murch, Mike, any thoughts at
this point?  No?  Thank you.

_Libsecp256k1 #1777_

The next one comes from libsecp256k1 #1777.  So, here, a new API endpoint is
added that allows external applications to supply a custom SHA256 compression
function at runtime.  So, the situation here is that when you're using libsec,
which is a binary that comes built-in within Bitcoin Core, you used to have no
way to let libsecp know about the CPU that the computer was using, and to target
a specific hardware-accelerated version of the library that would run these
computations.  So, now this endpoint allows Bitcoin Core or other software to
basically let libsecp256 know at runtime to know the CPU that is being used, and
to also parse the hardware acceleration algorithm that would be used to do these
computations faster.  Why couldn't you just do this at compile time?  It's
because at compile time, you don't know the user's CPU, if the user's CPU
supports the hardware instructions.  So, Bitcoin Core already has solved this
and can detect whether the CPU supports the hardware instructions at runtime,
and now is able to let libsecp know about it, and also to parse the hardware
acceleration algorithm.  So, very cool.

**Mark Erhardt**: Yeah, so this has become much more common in the last few
years, that CPUs have architectural support for secp.  And obviously, it's way
faster if your CPU can directly run it in the hardware.  And so, my
understanding here is that just it allows the secp library to leverage the
hardware gains.  And so, for example, especially on low-powered devices, some of
which -- I think maybe our listeners should correct me if I'm wrong on this --
but I seem to remember that Raspberry Pi got hardware support for SHA256 in the
newer versions, and there, that would make a huge difference because all the
calculations are what the bottleneck is in IBD for Pis.

**Gustavo Flores Echaiz**: Makes sense.  Yeah, I think that's my understanding
too.  Thank you, Murch, for adding that.

_BIPs #2047_

So, we're almost done, but we move forward with BIPs #2047, which publishes
BIP392, which is the BIP proposal for defining the descriptive format for silent
payment wallets, which would allow for wallet software to have specific
instructions on how to handle the scanning and the spending of silent payment
outputs, and also for interoperability between wallets.  So, the way silent
payments works in general is that it has both a scan key and a spend key, right?
So, a scanned private key allows you to see which silent payment address is
linked to which specific P2TR outputs, as specified in and BIP352.  However, the
spend key either is public or is private.  So, BIP392 introduces two types of
expression.  One is a one key expression argument that takes a single bech32m
key can have two different forks.  The first one is called spscan, which encodes
both the scan private key and the spend public key.  So, this allows you to
fully watch a silent payment wallet but not to spend from it.  The second
expression is called spspend, and this one is a full spending wallet which has
both the scan private key and the spend private key as well.

There's also a two-argument form of the silent payment descriptor, which
separates the keys instead of encoding them together.  And the first key is
always the private scan key as the first expression, and the second argument is
a separate spend key, which can be either public, it can be either private, but
also it has support for MuSig2 aggregate keys.  So, your spend public key or
private key can also be specifically a MuSig aggregate key.  Anything to add
here, Murch?

**Mark Erhardt**: Yeah, maybe just higher level.  The descriptor format is a way
of describing patterns of output scripts.  So, with BIP392, we formalize how you
could export and import and backup silent payments keypairs and transfer them
between wallets.  So, I don't know, if you've been following BIPs, you've
probably seen that there's a lot of descriptor BIPs.  The whole 380s, and now
the 390s too, are all about output script descriptors.  This is just an
improvement in how we do wallet backups and wallet import format.  And yeah,
descriptors are now also available for silent payments.  And hopefully silent
payments adoption continues to grow because it's awesome.

**Mike Schmidt**: I'll also just plug Newsletter #387 and also Podcast #387,
where we talked about this idea when it came out originally, and also had Craig
Raw on to talk about it.  So, if folks are curious, listen back for those.

_BOLTs #1316_

**Gustavo Flores Echaiz**: Thank you, Murch Mike.  Great additions here.  So, we
move forward with the two final PRs of this week.  So, both are additions or
improvements to the BOLT specification.  The first one, BOLTs #1316, clarifies
that when an offer_amount is present in a BOLT12 offer, it must be greater than
zero.  The writer must set the value greater to zero, but if it was set to zero,
then the reader must not respond to those offers.  Also test vectors are
included.  So, this was just a clarification that was missed initially, because
you can omit the offer_amount, but if you include it, it must be a non-zero
value, it must be greater than zero.

_BOLTs #1312_

The next one is BOLTs #1312.  This comes as a follow-up from a fix we covered in
LDK, Newsletter #390, which applies specifically to the invalid bech32 padding
of BOLT12 offers.  So, in this PR, BOLTs #1312, a test vector is added with an
example of a BOLT12 offer that has invalid bech32 padding, and clarifies that
such offers must be rejected according to the BIP173 rules.  So, basically what
happens here is that a specific bech32 encoding comes out and works in 5-bit
groups.  But the data encoded is often in 8-bit groups.  So, it means that it
supersedes the number of bits of the data encoded and you add some padding bits.
But the rules say that the padding bits must be at most 4 bits, and those bits
must be all zeros.  So, if the padding bits are non-zeros or exceeds 4 bits,
then the encoding is invalid and must be rejected.

So, this was discovered through differential fuzzing, and it was revealed that
LDK and CLN were accepting invalid padding offers, while other implementations
were correctly rejecting them.  So, this adds this vector at the specification
level to ensure that the BOLT specification has the right semantic or
clarification around it, so implementations can then base themselves properly on
the specification.  This was the last PR and this completes the section and the
newsletter.  Thank you.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.  We also want to thank JHB for
joining us earlier, for Murch for co-hosting, and for you all for listening.
We'll hear you next week.  Cheers.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
