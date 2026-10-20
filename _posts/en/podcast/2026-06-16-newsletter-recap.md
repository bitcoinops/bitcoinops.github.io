---
title: 'Bitcoin Optech Newsletter #409 Recap Podcast'
permalink: /en/podcast/2026/06/16/
reference: /en/newsletters/2026/06/12/
name: 2026-06-16-recap
slug: 2026-06-16-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Vasil Dimov to discuss [Newsletter #409]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-5-17/426324663-44100-2-03dc6687edd0d.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome, everyone, to Bitcoin Optech Newsletter #409 Recap.
Today, we have a News item talking about a draft BIP for testnet5 to replace the
struggling testnet4; we have one release, which is the LND 0.21.0-beta release;
and then, we have our weekly segment on Notable code and documentation changes.
We have no guests this week, although we may have a late guest joining, we'll
see.  But we're going to jump into the News section.

_Draft BIP for testnet5_

"Draft BIP for testnet5".  This is a Bitcoin-Dev mailing list post that we
covered, and it links to a draft BIP that was co-authored by Fabian and Pol to
replace testnet4 with testnet5.  I think if you look at the mailing list that we
linked to, the mailing list post, it actually links to a previous draft.  But
right before publication, we did see that there was an updated PR.  So, when we
link in the newsletter to that, that's the most updated one.  So, why testnet5?
I think it's been maybe a couple years on testnet4.  There were a few
justifications given for problems with testnet4.  One is the sustained
exploitation of the 20-minute rule, also known as the difficulty exception.  I
wanted to loop in Murch on this one.  Murch, what is the 20-minute rule that
applies to testnet, but not things like mainnet or obviously signet?

**Mark Erhardt**: Right.  So, the 20-minute rule or 20-minute exception is, once
there is a gap of 20 minutes or more between the previous timestamp and your
current block's timestamp, you must use a difficulty of 1 instead of the actual
difficulty.  And the idea here was this was introduced in testnet2 with a hard
fork towards the end of testnet2, after testnet2 had run up a way too high
difficulty and made it hard for people to use testnet2.  The idea was to enable
people to mine blocks with CPUs if they wanted to get their non-standard or
not-yet-supported transactions mined in testnet, or if they wanted to mine
themselves a block reward in order to have testnet coins.  This rule had a bug.
Sorry, maybe I should first say, this rule was then also adopted for testnet3
when testnet3 was started in, I think, 2012.

So, in 2012, testnet3 was started with this rule, and people discovered after a
while that if the 20-minute exception was applied to the last block in a
difficulty period, the difficulty reset would use the last block's difficulty as
the basis of calculating the new difficulty, just as it does in mainnet.  But if
that block's difficulty is 1, it would at most multiply the difficulty by a
factor 4.  So, it would reset the difficulty to, well, if the previous difficulty
period had the expected number of blocks to a difficulty of 1, or if it was a
little fast, it would reset it to a difficulty between 1 and 4.  So, this
difficulty is extremely low.  It's so low that a CPU can very easily mine a
block, especially more modern computers, can mine blocks very easily.  So, if
someone points an ASIC at that, they can mine thousands of blocks per minute,
which leads to something we call block storms.  This caused testnet3 to be at
just below 5 million blocks right now.  So, for comparison, the Bitcoin mainnet
has somewhere around 950000 blocks.  So, testnet5, in fewer years, has more than
five times the blocks.  And actually, testnet3 has had 23 halvings already and
the block reward is reduced to 546 sats.  So, it got very hard to get block
rewards by mining blocks.  People for a while exploited the block storm
vulnerability on purpose, in order to demonstrate how broken testnet3 is, by just
every difficulty period, reusing the 20-minute exception on the last block on
purpose, and thereby just creating a lot of blocks very quickly until the subsidy
ran out.

So, about two years ago, a new testnet was started with the idea, as always,
testnets should be without value; the coins should be freely available; it should
be a common good for developers to easily be able to test their software in a
mainnet-like environment; and especially for miners to be able to test their
mining setup in a mainnet-like environment, because while signet is useful for
testing transactions, signet cannot be used for testing mining setups.  So,
testnet4 fixed the block storm vulnerability by forbidding the 20-minute
exception on the first block.  The first block always has to use the actual
difficulty, and by using the first block of the previous difficulty period as
basis for calculating the difficulty for the next period.  So, because the first
block always uses the actual difficulty and the difficulty is constant across a
difficulty period, it doesn't matter whether you get the difficulty from the last
or the first block in a difficulty period.

But in the case of testnet, where the first block has to use the actual
difficulty, it would always have the correct difficulty and thereby, the
calculation would keep the actual difficulty.  It did, however, keep the
20-minute exception for all other blocks, which then led to now there being a lot
more awareness of the 20-minute exception.  A lot of people started using the
20-minute exception, and then it started to get perpetually used so that almost
every block height had five or even ten different candidate blocks at the same
height, and testnet4 was suffering from constant reorgs all the time, even
multiple times, because people would go and after a block was mined at the actual
difficulty with an actual timestamp, they would immediately mine a block at
minimum difficulty, just with a timestamp dated 20 minutes to the future, then a
second one 40 minutes to the future, a third one 60 minutes to the future, and so
forth.  So, they could mine up to six blocks in advance because Bitcoin Core
accepts blocks up to two hours in the future.  So, every time an actual
difficulty block would get mined, six blocks would immediately follow by several
participants, and you'd have not just reorgs but multi block reorgs all the time.

So, now that it's been a couple of years -- and I should also mention, while the
idea is that testnet should be worthless because we keep resetting it whenever it
gets value, testnet1 failed when it became the first altcoin and people started
trading it for other currencies; testnet2 failed when it became valuable and
people started trading it and the difficulty went up; testnet3 eventually got
monetized and traded on an altcoin exchange, and some people also immediately
started trying to monopolize the block rewards of testnet4 and monetize it on
exchanges.  To be fair, this made it very straightforward to find out how to get
testnet coins.  You just go to an exchange and buy them.  But the idea is that
they're freely available via faucets, and so it undermined the incentives to run
faucets and give away testnet coins, which on the other hand made it more
expensive or less accessible for other developers.  So, again, testnet coins are
worthless.  We'll continue to create testnets every few years whenever that's
necessary.  And the idea is for testnet coins to be given away freely on faucets
for any developers that want to make testnet transactions.  So, if they continue
to get monetized all the time, testnets will continue on until monetization
stops.

So, let's get to the actual news item.  Testnet5 is proposed.  Testnet5 drops the
20-minute exception altogether because clearly it is getting abused all the time.
So, it will not be possible to mine testnet5 blocks with CPUs probably.  However,
this will make testnet5 more like mainnet, because it'll have its own difficulty
and will just get mined by presumably some people's old ASICs, or whatever
hashrate is pointed at it.  Testnet5 also has the motivation of introducing the
BIP54 rules from block 1.  So, because BIP54 has a component that affects miners,
where miners need to update how they build blocks, we will activate BIP54, the
consensus cleanup consensus rules, starting from block 1.  So, any miners that
want to test whether they've correctly implemented support for BIP54 will be able
to use testnet5 for that purpose.  Did I forget anything?

**Mike Schmidt**: I think that the only other thing, maybe you covered it and
maybe I missed it, but the minimum difficulty being higher than testnet4.  So,
not only is that difficulty exception removed that you talked about, testnet5
would take that away, that 20-minute rule; BIP54 rules instantiated from genesis;
and then, minimum difficulty higher than testnet4.  So, that means, I guess, if
there's very little mining activity on the chain, there's only still so low that
the difficulty would adjust.  So, it would maintain a higher difficulty than
mainnet rules would allow.

**Mark Erhardt**: Right, so I believe testnet4 had a minimum difficulty of 1, 1
being I think it's like 10 megahash roughly, or something, which a laptop can
mine that every ten minutes or so.  The new testnet5 is proposed to start with a
minimum difficulty of 1 million, so significantly higher.  I think this is more
on the level of an old ASIC, maybe.  I don't know, I won't speculate, I don't
know the numbers from the top of my head, but 1 million times higher difficulty.
This will especially affect the start of the testnet.  Usually, if you were to
start a new testnet at minimum difficulty 1, of course the first few difficulty
periods would blast past.  If someone points an ASIC at them, they would probably
mine them in, I don't know, half an hour or something.  And then, difficulty
would quadruple with every difficulty period.  And eventually, it would get to a
level where whoever is mining first slows down to a point where other people
might actually hear about the block before new blocks are found.  So, to avoid
this block storm at the beginning of the testnet, the new testnet5 starts with a
minimum difficulty of 1 million instead of 1.

**Mike Schmidt**: Now, part of the reason, I can imagine, for the 20-minute rule
would be if somebody ramps up the difficulty and then just drops it, right, and
then somebody could jump in and continue to advance the chain.  If that's not
present here, I guess there is no prevention of that.  Like, somebody could throw
a bunch of hash at it for a few periods, ramp up difficulty, and then unplug
those machines, and now you get very, very long block times, if at all.  Is that
a concern?

**Mark Erhardt**: Yes, that is a concern.  Since there's no special rules
regarding the difficulty or difficulty calculation, someone could point some
significant amount of hashrate at the testnet5, ramp up the difficulty, and then
it would get stuck at that difficulty with slow blocks.  Presumably, someone
would have to then donate hashrate to mine a block, say, every 20 minutes or so
to make the difficulty go back down, and that would be annoying.  But I guess
we'll have to see whether someone does that.  If something like that were to
happen, potentially we would consider having some sort of difficulty decay in
testnet 6, where if there's no block for two hours, or something, difficulty goes
down, but not to the minimum, but maybe down by half, or something like that.
But we'll see whether that happens.  Again, testnets are not supposed to be
valuable, they're supposed to provide a live network for people to test
transactions and mining.  And, well, if people keep producing tragedies of the
commons, we'll iterate on that model.

**Mike Schmidt**: And then, one point that I think was brought up in the
discussion, or related discussion was, "Testnet5 or patching testnet4?"  And I
suppose the testnet5 has the advantages that you mentioned, which is it really
cuts off testnet4 coins in terms of people trying to monetize that, or whatnot.
And it's probably simpler to just cut over a new testnet than it is trying to
patch something existing.  Is that relatively the case against patching testnet4?

**Mark Erhardt**: Just to be clear, nobody can stop the old testnets.  We're just
pointing our own participation elsewhere.  I believe testnet1, I don't know if
it's still going, but it could still be going.  Testnet3 is still going, testnet4
will continue to be going, probably.  Someone will probably mine it.  But
testnet5, the idea here is in order to fix the difficulty adjustment of testnet4,
to take out the 20-minute exception, or other fixes, would likely require a hard
fork.  And forking a test network is too much effort.  Like, coordinating that,
then getting the participation of the miners that are, some of which are actively
monopolizing and monetizing testnet4 coins, is just why bother?  Just start a new
one.

**Mike Schmidt**: Okay.  I think we covered that one pretty well.  Murch or
Gustavo, anything else before we move along?  Okay.  Well, I will turn it over to
Gustavo for our Releases and Notable code items.  Gustavo, the floor is yours.

_LND 0.21.0-beta_

**Gustavo Flores Echaiz**: Thank you, Mike.  Thank you, Murch, as well.  So, this
week we have one main release and a maintenance release.  The first one, LND
v0.21, is a major version of LD.  Multiple features are added in this release.
The focus is mostly around building the tooling for onion messages, sort of as a
preparation for full onion message support, and probably eventually onion message
support either on BOLT11 invoices as the LND roadmaps plans, but also probably
for BOLT12.  So, there's basic support for onion messaging forwarding, as well as
pathfinding support for writing onion messages.  However, like I said, this is
internal tooling.  A technical user could still construct and send an onion
message, but it's not surfaced through other features.

Another big focus of this release is the announcement of production simple
taproot channels.  So, as we saw in the past few newsletters, simple taproot
channels are now part of the BOLTs specification.  So now, LND has promoted them
to a production support.  And with it, it also includes some other features such
as, for example, RBF cooperative close for taproot channels.  On the other end,
some other features that we've discussed that are added in this release are, for
example, the fast initial synchronization for Neutrino-backed nodes, so a node
that doesn't use a Bitcoin Core node or a btcd node, and instead is a light
client that uses Neutrino software.  Well, it now can basically point to a local
file or a specific HTTP URL to fetch the block filters and the header chains and
the block headers, instead of fetching them over the P2P network.  It could
potentially reduce privacy, but it improves performance considerably.

There's a lot of work also around the transition within LND from using key-value
databases, and migrate towards SQL-based databases, particularly for their
payments database.  But a lot of internal work is being done and we should
probably expect, in other releases, other databases to migrate to the new SQL
implementation.  So, overall, quite a big release.  There's multiple other bug
fixes and improvements.  We invite everyone to check out the release notes if
they want to have a full picture of what was in it.

_Core Lightning 26.06.1_

The other release is a maintenance version of Core Lightning, 26.06.1, which
follows up 26.06, which I believe we covered in the last week's Newsletter.  Here,
bwatch, which is a new plugin introduced to watch the blockchain basically,
failed to run at startup time after it had properly been built.  The make install
code wasn't properly pointing to the right place.  So, just a reorganization of
file hierarchy to make it so that it will probably register at startup time.

_Bitcoin Core #35410_

So, those are the two releases and now we move forward with the notable code and
documentation changes.  We got about six items this week, so a pretty light week.
And I see that Vasil has just joined perfectly in time, because we're now going
to talk about the Bitcoin Core item #35410, which is a major, well at least some
sort of big news around a bug that was found in the private transaction broadcast
implementation of Bitcoin Core.  So, I'm going to stop here.  Maybe Murch, Vasil,
you guys want to chime in, as you guys have probably looked into it?

**Mike Schmidt**: Yeah I just wanted to frame this briefly.  Vasil, thank you for
joining us perfectly in time.  We tried to have Vasil on when we originally
covered the private transaction broadcast feature to sort of celebrate that
merge, and we had technical difficulties and he couldn't join us.  So, maybe one
thing that we could do to start this PR off is, Vasil, can you explain what the
feature is, and then maybe we can explain the situation that might cause a bug in
this feature?

**Vasil Dimov**: Okay, so the private broadcast is a solution to one specific
problem that exists when you send to your own transactions.  And the way it works
without the private broadcast is that when you have a new transaction to send to
the network, your node would send it to everybody it is connected to.  And then
they would send it to everybody, and then everybody sends it to everybody they
are connected to, and this is how the transaction floods the network.  The thing
is that with this approach, it's not very good for privacy because if there is
somebody who is monitoring many connections or has many connections to many
nodes, it's not too difficult to deduce where the transaction originated, which
might mean IP address and geolocation, which is not very nice to have your
bitcoins linked to your location.  So, the private broadcast is a solution to
that, in which we send the transaction not to everybody we're connected to, but
we open a new connection, in the simplest case, to some Tor node.  We send them
the transaction like normal transactions send, and then we close the connection.
So, the only thing that goes in this connection is that transaction, and then
this node, like normally they broadcast it to everybody, this is what normally
everybody does.

So, in this way, the originator of the transaction is hidden behind the Tor
network.  And in the Tor network, you don't have source address.  So, the
connections don't have source address or originator.  So, whenever somebody
receives a connection on the Tor, they don't know where it is coming from.  This
is one thing with the Tor network.  And the other is that we open a new
connection, even if we have already Tor connections to some peers, because in
those other connections, maybe we leak some information, too much information.
And yeah, it's not too difficult to link the IP address of my node to my Tor
connections.  That's some other aspect which we avoid when we open a new
connection, just for sending the transaction.  Yeah, so that's private broadcast.
So, okay, I will keep going.

So, this feature is very nice and it was released in the latest Bitcoin Core
release.  And just a few weeks ago, somebody found a problem with that.  And this
problem, now I'm going to explain what the problem is.

**Mark Erhardt**: Can I briefly jump in?  So, when we say that private broadcast
was released in v31, private broadcast was only introduced for one RPC so far,
the sendrawtransaction RPC and it's off by default.  So, only when people
explicitly use the sendrawtransaction RPC, they would have an option to submit a
transaction via private broadcast, whereas Vasil described your node would make a
fresh connection to a Tor peer, handshake, hand over the transaction and
disconnect, so that the new transaction would be without any other context.
Okay, Vasil, you wanted to get into what the issue was that was discovered.

**Vasil Dimov**: Yes, I heard most of what you said, not everything, but it was
introduced in the latest release and it is off by default, because it's kind of
like a new feature.  We don't want to impose it on by default, maybe there will
be bugs, and now this is what we're going to talk about.  So, when we send the
transaction, we can choose to send it if the peer has a connection to the I2P
network.  This is the easiest, like we just send it to the I2P network, to some
peer on the I2P network.  This is one thing.  And that's kind of isolated,
because the I2P doesn't have connection to the clearnet.  I mean, they don't have
exit nodes, so ignore this for now.  The Tor network is special because You have
Tor nodes that are on the network, and also through the Tor network, you can
connect to clearnet in a way that preserves your IP address or geolocation.

So, when we are sending a private broadcast transaction, we could choose to send
it to a Tor node, if the node has a connectivity to the Tor network, or to
clearnet.  By clearnet, I mean IPv4 or IPv6 address.  And to do that, we would use
the proxy that is normally used for the Tor network, so that the connection would
go through the Tor network and through the Tor exit nodes to clearnet, protecting
our location.  Now, this is new functionality that was not present before.  I
mean, this is something internal within Bitcoin Core.  When it opens connections,
you have the proxy configuration, which use this proxy for all connections, like
Tor and clearnet.  Or you have the configuration proxy for only Tor.  So, in this
case, for the private broadcast, we wanted to, if we're sending to clearnet
address, we want it to route through the Tor proxy always, regardless of whether
it is the global proxy, or whether we would otherwise open directly connections
to IPv4 or 6 addresses.  And so, this new functionality had the problem that --
okay, I'll step back.

When we open a connection to some peer, if we think they may support v2 protocol,
which we call the P2P encryption, if we think they do support that, we try to
speak the encrypted protocol to them.  And if they do, then we start, the
connection is opened successfully.  If they don't support, what happens is that
the connection would be closed by them, because they only speak like a v1
protocol, which is not encrypted, and to them, somebody connected and is sending
encrypted garbage.  So, they would close the connection.  And this is indication
to us that, "Okay, we were thinking that this peer supports v2, but they don't;
probably they don't because they closed the connection.  So, let's try v1, retry
another connection because the first one is already closed".  So, we have to open
completely another TCP connection, trying to speak the v1 protocol.  And the
problem is that with this private broadcast sending to IPv4 or 6, that if we think
that the peer supports v2 and we would try to speak this to them, and if they
close the connection and then if we retry a new one, then it would forget to use
the proxy, if it is not the global proxy, like if we want to override the global
configuration, because this is private broadcast.  In this case, it would forget
to use the proxy and it would open the connection directly.  Which means that peer
would see our IP address, and this is breaks the feature, or how to say?  This
defeats the purpose.

**Mark Erhardt**: Yeah.  So, actually it is worse than not working.

**Vasil Dimov**: So, we were rehashing what exactly is needed for this to happen,
like when would the bug be triggered, or how to say, yeah?  And so, first of all,
v2 has to be on, on our configuration, which by default v2 transport is enabled.
I mean, it has to be enabled because otherwise we wouldn't try v2 and then v1.
The peer must have access to the Tor network and it must not be the global proxy,
which means without private broadcast, we would open directly connections to IPv4
or 6 addresses.  So further, in our addrman, we keep track of which peer supports
v2 and which doesn't.  So, also, the other condition is that when we connect, we
have to have in our address database somehow that this peer supports v2.  And they
must not support that because otherwise, if they do support, the connection would
be opened successfully.  So, if all this happened, then we would open connection
through the clearnet.  And the solution is to, yeah, even the v1 retry, to do it
through the Tor proxy.  This is the fix of the bug.  I think I speak enough now.

**Mark Erhardt**: So, to recap, we added a new feature to Bitcoin Core v31 that
was only available on the RPC sendrawtransaction as a new Boolean option off by
default.  And if your node was configured to use v2 transport and had no global
proxy set for Tor, and encountered a peer while trying to do the private
broadcast that was advertised as supporting v2 but actually didn't support V2, and
this node was in clearnet, you were trying to reach it through the proxy, then
your node, upon downgrading to v1 transport would not reuse the local proxy.
Instead, if there was a global proxy configured, it would use the global proxy,
which is also off by default, to be clear.  But anyway, in these very specific
circumstances, their retried connection to do private broadcast would fail to use
the proxy, and then your IP address would be directly visible to the receiving
node because you would make a clearnet connection where the peer would learn your
IP address, and you would send your new transaction and then disconnect
immediately, which would be the obvious private broadcast pattern.

The fix for this was to remember to use the proxy when you downgrade from v2
connections to v1 connections, after a node had falsely advertised support for
v2.  Obviously, this is worse than just not working, because if you had submitted
your transaction to all of your peers, like you would usually, at least it could
have been received by another node and you were just forwarding it.  But with the
private broadcast mechanism, you only connect to a single node and it has a
distinct pattern where you handshake, hand over the transaction and disconnect.
So, there would be reason to believe by the recipient that this was your own
transaction and they got your IP address under all of these above circumstances,
false advertising, trying to use a proxy to reach clearnet, and using an
experimental new Boolean feature on a sendrawtransaction.

So, this bug is fixed.  The 31.1 release is coming out soon and will fix this
issue.  And I think that the idea is to, after this has been taken for a longer
spin, to use private broadcast generally for new transactions eventually once we
have more confidence in it, and maybe even to use private broadcast for
rebroadcasting transactions that we would have expected to be in a block but
didn't see in that block.  That would help keep transactions present in the
mempool when they should be mined, but apparently weren't in the mempool for
other peers anymore, and also act as camouflage for actual new transactions being
sent by private broadcast.

_Bitcoin Core #34779_

**Gustavo Flores Echaiz**: Thank you guys for that.  So, now we have two more
items from the Bitcoin Core repository.  The next one is Bitcoin Core #34779,
which is basically the implementation of BIP323, which we have covered in
Newsletter #405, which the BIP proposes to expand the number of bits available in
nVersion nonce space for miners from 16 to 24.  So now, this implementation
reserves the all the bits 5 through 28 as extra nonce space for miners.  And also
what it does is that it ensures that a Bitcoin Core node won't think that this is
basically an unknown software signaling.  So, all the bit-range monitoring by
BIP9 version bits is basically turned off or is reduced to bits outside of the
bits 5 through 28 range.  But I'm sure, Murch, you have some extra thoughts you
would like to add here.

**Mark Erhardt**: Yes, so the idea here is that people were using time rolling,
where they increment the timestamp more often than once per second in order to
have extra nonce space.  And it would be preferable if block templates were
accurately labeled for the timestamp.  So, because their version is not used that
much, there was this proposal to use eight more bits from the nVersion field for
extra nonce space.  And so, since the introduction of BIP9, which is version bits,
which introduced this method of using bits in the nVersion field to signal
readiness for enforcing rules of a new soft fork, the Bitcoin Core would parse
any such bits as, "Oh, someone is signaling for a soft fork that I don't know
about".  And because now the Bitcoin Core implementation that's coming up -- this
will be released in v32 -- will be considering bits 5 through 28 all for an extra
nonce, and they will have random values, this warning label is turned off.  So,
if signals in those bits were set, then they will not be warned about.  The bits 0
through 4, so five bits, are still reserved for signaling for soft fork readiness.
This is hopefully enough.  There are currently several soft fork proposals
signaling, or not signaling actually, but well, one is actually getting any
signals.  But it seems like five soft fork proposals being signaled for at the
same time is probably enough at this time.  And if not, we can come up with other
signals.

Yeah, this is a fairly fresh BIP, but the idea was pretty popular and I think
avoiding time rolling is a worthy endeavor to reduce the size of the version bits
for.

_Bitcoin Core #32150_

**Gustavo Flores Echaiz**: Thank you, Murch, for clarifying that.  The next one is
an item, Bitcoin Core #32150, that actually, Murch, you were the author behind it.
So, no one's better at introducing it than you would.  So, please, Murch, give us
the honor.

**Mike Schmidt**: Yeah, if only we had a special guest for this one!

**Mark Erhardt**: So, in Bitcoin Core, we use several different strategies to come
up with potential input sets for funding transactions.  We use these coin
selection algorithms on each type of UTXOs.  So, if you have a wallet that makes
use of different output scripts, they will be run separately on each of those
output script groups.  So, we use a random draw of the UTXOs.  We use the ancient
knapsack algorithm that has been around for 12 years, and then we also use
something called CoinGrinder at high feerates only to minimize the input set.  And
this approach is called Branch and Bound (BnB), which is supposed to find
changeless input sets.  So, this is a branch-and-bound algorithm that explores all
possible combinations of the input set, and looks specifically for a combination
of inputs that matches the payment outputs exactly so that no change output is
necessary.  Not only did I write this PR, but this is based on my master thesis
from 2016.  And last year, I think last year, I looked at this a little more and I
offered a refactor of how it is implemented in the Bitcoin Core codebase.

Previously, when you were watching this tree of all possible combinations, tree in
the data structure sense, it would use the walking of the tree to update the
invariance, like how much money has been selected, what the total weight of the
selection currently was, and so forth.  And when it backtracked a branch to go to
a different branch, it would explicitly visit each of the intermediate nodes.  And
in this new rewrite of the algorithm, instead of walking all of the intermediate
nodes in the tree, it will skip directly to the next distinct input set so that it
doesn't have to revisit nodes that it had previously visited, and it skips over
some equivalent input sets.  So, with the same number of iterations in the
exploration loop, it will now iterate over more different candidate sets and
hopefully find solutions in fewer loops; or if it runs out of loop tries, it'll
explore more candidate sets.

Yeah, this was in review for about a year and got merged last week.  So, I'm a
little excited that it's finally done.

**Gustavo Flores Echaiz**: Nice.  Very clear.  Thank you, Murch.  So, that
completes the three items from the Bitcoin Core repo.  And now, we have one from
the LDK, BTCPay Server, and the BIPs repository.  We had started to put the BIPs
items first, but I'm going to just go in the order as it's written first.

_LDK #4647_

So, first, LDK #4647 basically changes how it uses introduction nodes in blinded
message paths because of an incompatibility with LND's onion message support.  So,
basically, the problem is that because LND has started onion message support, but
only partially, it doesn't fully support, for example, forwarding messages from
non-channel peers.  However, it can receive a message from a non-channel peer, but
it won't forward it.  So, an LDK node could choose an LND node to be the
introduction node in a blinded path, but when it would come the time for the LND
node to forward the blinded message, the onion message to the LDK node, it would
simply not forward it, basically breaking the point of choosing the LND node as
the introduction node in that blinded path.  So, LDK has basically reverted its
functionality to now only choose itself or the recipient as the introduction
point for a blinded path.  There's a privacy trade-off here because now, as a
sender, you now know that the receiver is the introduction point, so receiver
privacy is deteriorated partially.  And this is probably just a temporary change
made until LND achieves feature-compatibility and could eventually forward onion
messages from non-channel peers.  However, to not break support, this is
downgraded to now on all blinded paths, LDK will just choose itself, the receiver,
as the introduction point in blinded paths.

Also in this PR's discussion, it was analyzed the idea of building a sort of
heuristic that if we were going to choose an LND node for this, then maybe skip
the LND node and try to choose a node that isn't an LND node.  But the author,
Matt, basically went against this idea of trying to build heuristics across nodes,
because this has also caused other issues with, like, LSP heuristics, which is
another part of LDK.  So, it was just chosen to make this change for the time
being, so that support for BOLT12 blinded paths doesn't break when LDK would
choose an LND node as the introduction point of the blinded path.  So, that's for
the LDK one.

**Mark Erhardt**: My understanding is, I think we talked about LND last week.  And
if I remember correctly, I didn't research this one too deeply, they have a DoS
protection mechanism where if they get too many messages, they will receive all of
them but drop some of them and only forward partially.  And I would assume that
this is maybe even more strict regarding non-channel peers, so that there would be
more leniency towards a peer that you have a channel with versus a peer that you
just peer with for gossip messages.  And so, of course, when you receive messages,
but not guaranteed to forward all of them due to this DoS protection mechanism,
this would potentially cause payment instructions to get lost if the BOLT12
support that depends on onion messages working, if those BOLT12 messages would get
dropped.  So, I think that's the context to last week that explains how LND has
structured its initial support for onion messages might be an issue here for LDK.

**Gustavo Flores Echaiz**: Yes, that is exactly right actually, Murch.  I just
looked at the release notes of LND v21, and one of the items that I didn't mention
in detail before.  But yes, with the introduction of incoming onion messages, LND
implements strong rate limiting and channel-presence gate, which is exactly what
this is about, right?  So, for example, the notes say, "Incoming onion messages
from peers with no fully open channel are also dropped at ingress as a
Sybil-resistance layer; pending channels are excluded".  So, yes, it is about rate
limiting and preventing some sort of spam of onion messages, which by the way, I
think we've discussed in this podcast that that also introduces some other issues.
But yes, that is exactly related to why LDK has to make this change, because LND
has implemented this rate limiting and gaining of onion messages from non-channel
peers.

**Mark Erhardt**: And maybe also for context, I think at least a past number was
that about 85+% of all nodes on the Lightning Network are LND.  So, with LND
rolling out this new feature, probably a lot of the peers that advertise onion
messaging would actually implement it in this manner.  So, this means that if you
just randomly pick peers based on the advertised flags, you might hit an LND in
more cases than not.

_BTCPay Server #7218_

**Gustavo Flores Echaiz**: Right, perfect.  Next item, BTCPay Server #7218 adds a
guided setup flow for multisig wallets.  So, what does this mean?  Previously in
BTCPay Server, you could use a multisig wallet.  However, it was one user that
would create the multisig wallet by himself, and the signing would occur
externally from the BTCPay Server platform, for example through PSBT signing.
However, what is introduced here is a new guided flow where multiusers
participate.  So, for example, I as a user, as a store owner, I choose the signing
policy, and then I invite users to become store users who will then submit their
signer keys through the guided flow.  So now, this is basically multiple users can
collaborate in the creation and then the signing of a multisig wallet within
BTCPay Server.  And they can do this by bringing signer keys manually, or also
through the plugin called BTCPay Server Vault, which allows you to connect a
hardware wallet to BTCPay Server.  So, quite a big user experience improvement,
and something that was also being worked for a little while already.

_BIPs #2186_

Next and final item comes from the BIPs repository #2186, where BIP77 is updated
to specify basically compatibility between a payjoin v2 receiver and a payjoin v1
sender.  So, for example, what is described here, and maybe, Murch, you know more
detail about this, but from my understanding, what is described is that in payjoin
v2 BIP77's normal response path, a sender provides the receiver with a reply key
and the receiver can provide its response and encrypt it with the reply key and
deliver it to the sender-derived reply mailbox.  However, from my understanding in
BIP78, these reply keys simply don't exist, or senders at least don't provide them
receiver.  So, the receiver doesn't necessarily encrypt the message and there's no
such thing as a sender-derived reply mailbox, so the receiver will instead write
its response in his own mailbox where the sender had originally posted the original
PSBT.  And when we're discussing messages, we're talking about the signing of
PSBTs.  But please go ahead, Murch, if you have something to add here.

**Mark Erhardt**: Yeah, let me start by explaining a quirk here.  BIP78 is payjoin
v1.  The actual title is, "A Simple Payjoin Proposal".  And we will refer to this
as v1.  And BIP77, with the lower number, is v2, "Async Payjoin", or also known as
payjoin v2.  I think that derives from originally BIP79 being assigned a
payjoin-like construction, and then counting down for some reason.  We generally
otherwise try to at least have follow-up BIPs that build on other BIPs to have
higher numbers, because that feels more natural.  But in this case, 77 is actually
the follow-up to 78.  Okay, now that we have that out of the way, 77 is
asynchronous payjoin in the sense that when you use payjoin v1, BIP78, you had to
run a server.  And this server would allow a collaborator to communicate and build
a transaction with the receiver together.  So, the receiver would host a server
where they would offer their PSBT with their own input and their own output.  And
then, the sender would pick it up there, add their inputs and change output
potentially, put it back in the same spot.  They would encrypt it, but use the
same encryption key.  And then, the receiver would pick it up again, finalize it
and submit it to the network.

In asynchronous payjoin, neither of the two parties has to run their own server.
They use a third-partied mailbox system that is encrypted in two separate steps,
so that one party is responsible for the data hosting and the other party is
responsible for either the key exchange or either way, the third party cannot read
the content.  Oh yeah, the IP address is separated from the data storage.  So, one
party cannot see who is participating and the other party cannot see the data.
And because this is a third party now that uses some fancy moon math to encrypt
everything and make it very private, you can run this without running your own
server as the receiver, which is the big innovation of payjoin v2.  And payjoin v2
users should be, of course, compatible with payjoin v1.  And to achieve this
compatibility, they have to behave in the way payjoin v1 expects, because payjoin
v1 nodes, of course, don't know about payjoin v2; versus payjoin v2 knows about
how payjoin v1 works.

So, in order to achieve this backward compatibility, the BIP77 clients behave as
BIP78 payjoin v1 would expect, and put the data back where the receiver originally
put their PSBT, and respond in the manner that the old protocol worked.  And that
was apparently not fully documented before in the v2 payjoin BIP and was now added
to it.

**Gustavo Flores Echaiz**: Perfect.  Thank you, Murch.  Well, that completes the
final item and the whole newsletter.

**Mike Schmidt**: Awesome.  Thanks, Gustavo, and thanks, Murch, for getting us
through an interesting Notable code segment this week.  We also want to thank Vasil
for joining us for one of those Notable code items, and we want to thank you all
for listening and we'll hear you next week.  Thanks guys.

**Mark Erhardt**: Thanks for your time.

{% include references.md %}
