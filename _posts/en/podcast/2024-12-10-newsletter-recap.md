---
title: 'Bitcoin Optech Newsletter #332 Recap Podcast'
permalink: /en/podcast/2024/12/10/
reference: /en/newsletters/2024/12/06/
name: 2024-12-10-recap
slug: 2024-12-10-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Antoine Riard and Antoine Poinsot to discuss [Newsletter #332]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-11-10/391328774-44100-2-8cdb3942568cc.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #332 Recap.
We're recording on Riverside this week.  We're going to talk about a new
transaction-relay jamming attack; we're going to talk about the potential of a
new fix being added to the consensus cleanup soft fork; and we have our usual
Notable code segments and Releases and release candidates.  I'm Mike Schmidt,
contributor at Optech and Executive Director at Brink, funding Bitcoin
open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work on Bitcoin stuff at Chaincode Labs.

**Mike Schmidt**: Antoine Riard.

**Antoine Riard**: Hi, I'm Antoine, I'm a long-term contributor to Lightning and
Bitcoin Core and I've been active in this space since 2018.

**Mike Schmidt**: Antoine Poinsot.

**Antoine Poinsot**: Hi, I'm Antoine, I work at Chaincode Labs.

_Transaction censorship vulnerability_

**Mike Schmidt**: Thank you both for joining us this week to cover the two
respective News items that you guys kicked off.  First one is titled in the
newsletter, "Transaction censorship vulnerability".  Antoine Riard, you posted
to the Bitcoin-Dev mailing list the disclosure of a jamming attack that you're
calling, "Transaction-Relay Throughput Overflow Attacks", and that type of
attack, or two types of attacks, could target offchain protocols like Lightning.
Antoine, can you describe the attack and its two different variations?

**Antoine Riard**: Okay, so we are going to get started.  Should we start by a
general reminder about offchain protocol security models like Lightning, and we
explain how timelocks are useful and why do they matter?

**Mike Schmidt**: Yeah, I think you can give a little bit of context, if you can
keep it fairly brief.

**Antoine Riard**: Yeah, yeah, I just don't know what's the level of the
audience.  Yeah, so basically in Lightning, we're using timelocks for two main
operations.  The first one is when you do revoked transactions.  At the
transaction, you're going to get a secret from your counterparty.  And if this
counterparty is ever going to broadcast a revoked chain state onchain, you do
have creative timelocks encumbering these counterparty funds, and that gets you
punished if you have to punish the counterparty.  And there is a second main
operation, which is where the timelocks are very useful.  It's for the
second-stage HTLC (Hash Time Locked Contract) transactions, and we do have HTLC
timeout as well as HTLC preimage.  And the idea is like, I promise you an HTLC,
and if you ever go offline or if you disappear, I can always broadcast my states
and go to claim an HTLC before the timelock expires.  Timelocks are at the very
basis of insecurity models.  When we talk about transaction-relay jamming, the
idea is like, okay, can I present my counterparties to go onchain and confirm a
state by just jamming the confirmation of the transactions until the timelock
expires?  So, that's the basic idea with all this transaction-relay jamming
stuff.

What is the transaction-relay throughput attack?  It's some kind of old, known
concern.  It was known for a while among a few people that in fact, you might be
able to abuse, and you can abuse Bitcoin Core P2P stacks to just prevent your
counterparty transactions over the network.  And how do you do that?  Well, the
main tricks I explain in this writeup is exploring the fact that when you're
going to send an announcement to your Bitcoin Core peers, let's just do some
kind of pause and explain how the transaction relay works in Bitcoin Core.

So first, you're going to send an announcement, so send an INV with a txid, or
if you support BIP339, but witness txid.  And when you receive that, like let's
say I send an INV txid to Mike, Mike is going to look up in his own inventories
and say, "Hey, do I have already this transaction?  Yes or no".  If you don't
have it, you're going to do a getdata.  I will receive this getdata, and if I'm
honest, I will send you a transaction message and you do add transactions.  And
you're going to validate a transaction, add a transaction to your mempool, and
further relay as transaction over the network.  So that's how the
transaction-relay P2P network works, if I'm correct, I'm not squeezing any
state.

So, this transaction-relay mechanism is the one which is exploited.  This
scenario, where basically when we do an INV txid, we are going to sort them by
feerates.  So, we are going to take the highest ferrate with the highest
ancestor score and send those txids.  And you're going to do this like every 3
to 7 seconds, something like this, because we don't have the same trickle rate
between inbound and outbound peers.  And when you do that, in fact, if you
receive far more transactions than you can actually flow out, at some point the
low-feerate transactions are never going to propagate, even if they have been
over your fee filters, so fee filter mechanisms.  So, that's how this attack
works, where let's say we are a Lightning counterparty and there is Alice and
Bob and they do have pre-signed transactions, they pre-signed the stuff at 5
satoshis per vbyte (sat/vB), and what an attacker can do is now like, okay, I'm
just going to propagate junk transactions at 6 or 7 sats/vB, just to get your
transaction getting stuck into the internal inventory of your nodes.  And these
transactions are now propagating over the network.  And you do that in loop
until some kind of timelock expires.

**Mark Erhardt**: So, I have a question here.  So, you described the attack as
preventing the victim from being able to broadcast their transaction.  But if
you keep broadcasting very high-feerate transactions, you're also competing for
the block space.  And could you describe what the advantage is of preventing the
victim from broadcasting their transaction versus just buying all the block
space?  Because it seems like you're doing both of it.

**Antoine Riard**: No, no, no.  Yes, that's a very good question.  So, there is
a trick which is mentioned in the article, is you can exploit mempool
partitions.  Because let's say, Murch and Mike, you're both Bitcoin Core nodes
and you're both broadcasting transactions, and there is no necessity that you
have both -- I can configure your mempool and I'm just going to broadcast like a
10 sats/vB parent A in Murch's mempool and a 10 sats/vB parent B in Mike's
mempool.  And then, I can spend on top of these parents all the traffic, which
is going to reach the INV, which is going to overflow the throughputs of the
inventory you can do throughout the time periods.  So, you're not going to buy
the block space, you're just going to overflow transactions through the...  Yes,
the attacker is going to overflow current traffic over your nodes, but this
traffic, there is no necessity that it's going to reconciliate and it's going to
learn some kind of miners' block templates.

**Mark Erhardt**: Okay, basically you're overwhelming the relay network with
transactions that have a higher feerate than the victim's transaction.  And you
can reuse transactions or replace transactions or have conflicting transactions
go through the network, and that allows you to actually buy less than the total
block space of the blocks that you prevent them from getting into.

**Antoine Riard**: Yes, exactly.  I don't know if you remember earlier this
year, but I think it was Peter Todd who came with a few tricks to do free relay
attacks, where actually you're not going to pay for the bandwidth of what you're
relaying, but you can also exploit those kinds of vectors as building blocks of
these attacks to lower your cost as an attacker.

**Mark Erhardt**: All right.  Please continue.

**Antoine Riard**: Yes.  So, that's mainly the main idea.  So, I came up with a
proof of concept for high overflow and I tested on versions 27 or 28.  And there
is also the high-overflow variance, which is the low-overflow variance.  And
here, it's more conceptual because we have not done real-world testing of it.
And when you're doing transaction relay, there is the way the sender is ordering
the INVs, the inventory of txid, and there is also when I'm the receiving peer
and I receive too much traffic, at some point I'm just going to discard traffic.
And it's our limit.  It's the same for all the Bitcoin Core nodes since version
2018 or 2019, it's the MAX_PEER_TX_ANNOUNCEMENT, it's a limit of 5,000.  And
here the idea is like, can you overflow this limit?  And it's more like an open
question at the time of writing, we have not done extensive tests, because when
you start to do that, you can play with a lot of topologies.  There is no
guarantee that if I start to -- you can have up to 125 connections by default
with Bitcoin Core, and if you start to overflow the traffic flow, not even the
majority of it, but a certain number of connections, at some point you can
observe there is a drift in the sense of the rest of your peers start to have a
more and more consequential buffer of none of received txid, but non-processed.
And that's more like the high-overflow variance.

But the cost of the attack, so it was a very raw estimation.  Timelocks, I'm
talking here only for implementations, or I think Eclair is 100 intervals
between the inbound HTLCs and outbound HTLCs; Rust-Lightning is something like
42; Core Lightning (CLN) I think is something like 30; LND, I think it's also
something like 40.  But they do have also some kind of dynamic selection
mechanisms for, like, say relative timelocks on conditional transactions.

**Mark Erhardt**: So, regarding that second attack, you're flooding in the sense
that you're just sending a ton of transactions.  And when the queue of
unrequested transactions goes to high, they will no longer accept new inventory
announcements, I think.  But this is per peer, right?  If you have, you said
we're looking at up to 125 peers, of course, and the attacker controls some of
those, but usually not all of them.  So, if they flood only their outbound,
probably all of their outbound connections, because you would just add
transactions to the node, those transactions will propagate.  But what prevents
another node to send the honest transaction?  Is that why it's less reliable?

**Antoine Riard**: So, you have to keep in mind you do have the Mallory, Alice
and Bob transaction-relay topology.  And Mallory is going to inject junk traffic
on Alice to overflow the transaction-relay connection between Alice and Bob.
And there is, like, if you do that on sufficient peers -- in this attack, Alice
is the original transaction issuer.  Let's say Alice is an LSP or a Lightning
node, or running some kind of coinjoin coordinator, or something like that, and
is the only one originally broadcasting the transactions.  So, yes, one of the
ways to mitigate that is actually, the rest of the network receiving the
transaction, let's say, from another transaction broadcast mechanism.  But right
now, it's not something standard, in the sense of it has been discussed also in
the past for like time-duration attacks to have redundant transaction-relay
broadcast mechanisms, but it's not something very standard in Lightning
software.

**Mark Erhardt**: I see.  So, this attack would be mitigated pretty easily by
having a second broadcast avenue, and not just relying on your main node to be
participating in the network, and also being the sole source of broadcasting?

**Antoine Riard**: Yes, yes, I can dig into that.  But one of the main intuition
is as an attacker, all my junk traffic is going to reflect or relay for all the
honest peers, in a sense of this overflow is going to be like, if I uniquely
announce the transaction to Alice, like let's say in Mallory, and I'm crafting
the transaction to be unique in the network, there is no way the peers get them
from another, someone else.  And that means, all this junk traffic would have to
go through Alice and we'd have to overflow all the honest links of Alice.  But
it's the same unique traffic.  So, that's the easiest mitigation, or at least
most intuitive one, like we're talking about it's over-provisioning
transaction-relay throughputs with adjacent full nodes where, yes, so let's say
you're an LSP or, like a big, unique hub, and you will have ideally, you're
going to separate your full node doing block relay and your node doing
transaction relay.  And your node doing transaction relay is not going to take
inbound connection from the outside, and will just have outbound connections
open to special nodes.  And yes, ideally, you're going to open adjacent full
nodes through your transaction-relay nodes, and that way, you're going to
increase your max capacity and make the attack more costly for an attacker.

**Mike Schmidt**: Antoine, I have a question you can help clarify.  Maybe it's
just my understanding, but for the high-overflow variant, if I want to get a
transaction broadcast and someone's trying to use this high-overflow variant,
they're going to send me 1,000 unconfirmed transactions or more and they're
going to be perhaps a higher feerate than the one that I would like to
broadcast.  And because Bitcoin Core doesn't give any preferential treatment to
my transaction, then it gets behind on that queue.  So, I mean just, I guess,
the maybe naïve version would be, "Well, hey, if it's my node, put my
transaction in there at least at 999, or something like that", right?

**Antoine Riard**: Yeah.  So, it doesn't appear in the reports, but we talked
about it among the coordination group, yes.  Like, you know in the past, there
was this idea of priority fees in Bitcoin Core, where you were able to bless
your transactions, to favor its propagation, something like that?

**Mike Schmidt**: Yeah, wasn't that something about the age of the UTXOs, or no?

**Antoine Riard**: There was something like that too, but in my memory it's
something different.

**Mark Erhardt**: No, it's a prioritized transaction.  So, you give a
transaction in your own mempool and elevate it to virtual feerate.

**Antoine Riard**: Yes, that's what I'm talking about, which has been removed
years ago.

**Mark Erhardt**: No, no, no, that still exists.  Are you talking about coin age
priority which was removed, or are you talking about prioritized transaction to
change the virtual feerate of transactions in your mempool?

**Antoine Riard**: I think I'm talking about prioritized transactions.

**Mark Erhardt**: That still exists.

**Antoine Riard**: Is there an RPC for that?

**Mark Erhardt**: I'm pretty sure that still exists.

**Antoine Poinsot**: It does exist still, I just checked.

**Antoine Riard**: You just checked?  Okay.  So, yeah, I went through the whole
priority cut when I was working on that.  And, yes, so ideally you could use
that for, like, prioritize the fees of your own traffic.

**Mike Schmidt**: Does that affect relay or does that just affect --

**Antoine Riard**: That's a good question.  Let me check the code.

**Mark Erhardt**: It does affect relay, I think, because it treats the
transaction as if it has a higher feerate in your mempool.  But it shouldn't
overwhelm filters.  So, if a connection says, "Don't send me anything over 12
sats/vB", and it's below that, you wouldn't send it.  But it might affect relay
priority.  That's a good question.  Maybe we can find that out offline.

**Antoine Riard**: Oh yeah, prioritized transactions.  We do have an RPC in our
RPC mining.  Yes, prioritized transactions.

**Mike Schmidt**: Yeah, I guess the question is, if that affects in this
scenario with this 1,000 unconfirmed-transaction limit, does that move it up or
down?

**Antoine Riard**: If it does affect relay, in my understanding, it would
improve the issue, at least for the high overflow.

**Mike Schmidt**: Okay, all right.  Well, I mean it sounds like there's more to
dig into as well.  We noted in the newsletter writeup that this disclosure
happened pretty close to the newsletter publication, and so there may be some
more discussion on this that we dig into in the future.  Antoine, anything that
you'd say to wrap up this news item before we move on?

**Antoine Riard**: To wrap up that, yeah, it's not said very explicitly in the
report.  It's only talking about in the report, but most of the analysis should
hold for other contracting protocols, like coinjoin, payjoin, wallets with
timelocks, submarine swaps, what else?  Onchain DLC.  Yeah, anything which is
using timelocks is very likely also affected.  It depends on the timelock
durations, but that's my final point.

**Mike Schmidt**: Antoine, thanks for joining us.  You're welcome to stay on.  I
think there is a mention of an LND PR related to HTLC endorsements and channel
jamming, if that's curious to you, you can stay on.  Otherwise, if you need to
drop, we understand.

**Antoine Riard**: I can stay until like ten minutes more.

_Continued discussion about consensus cleanup soft fork proposal_

**Mike Schmidt**: Okay.  Our second news item this week is titled, "Continued
discussion about consensus cleanup soft fork proposal".  Antoine Poinsot, you
followed up to the Delving Bitcoin thread on the great consensus cleanup saying,
"I think the Consensus Cleanup should include a fix for the Murch-Zawy attack".
We covered the Murch-Zawy Time Warp attack in Newsletter #316 and, Murch, I
think you represented the research on that in that Podcast #316 discussion.  But
Antoine, perhaps you can describe this new attack for us?

**Antoine Poinsot**: Yes, I think it's more useful maybe to give an intuition of
what this attack performs and how it relates to the existing time warp
vulnerability and what would be the fix for this new attack.  As a quick recap
for the time warp vulnerability, the issue is that the retarget periods
considered by the Bitcoin protocols for the difficulty adjustments do not
overlap.  The last block in a difficulty retarget period is not the first block
for the next one.  It means that it is possible, because the time that is going
to be taken into account by the protocol to consider the time it took to mine
the 2,016 blocks, is going to be the time of the first block in the period and
the time of the last block in the period.  So, it's possible to have the last
block of one period be very far in the future as much as you can.  So, currently
by protocol rules, it's 2 hours in the future, and immediately have the first
block of the next period be as far back in the past as you can.  So, that's why
it's called a time warp, because you're going back in time when you go at the
next period.

So, the fix for this attack, which was already included in the original proposal
for the consensus cleanup, is to tie the timestamp of the last block in a period
to the timestamp of the first block of the next period, so that you cannot go
back in time or you can only go back in time by a tiny amount, such as it's safe
to roll out for miners, but it does not enable an exploit of time warp.  This
second issue, so the time warp attack requires a majority of the hashrate to
collude, but it's still fairly achievable and pretty catastrophic if exploited
to the full potential.  This new attack is more theoretical but enables the same
impact.  So, it will be harder to roll out, I think, but enables the same impact
as the time warp vulnerability, which is to drastically reduce the difficulty of
mining, such as you end up with a very, very low difficulty, which makes it hard
for the network to converge in the end.

This new attack exploits the fact that the retarget for the difficulty is going
to be clamped by 4.  Between 2 difficulty periods, the difficulty cannot be
bumped by more than 4 times or divided by more than 4.  So that's what, at the
end of the day, this attack is going to exploit.  So, the attack goes like that.
Murch, I need to speak under your correction, but the miner mines the first 2
weeks of blocks and is going to put the last timestamp as far in the future as
possible.  So, the first period is still publishable.

**Mark Erhardt**: They keep the timestamp back of all blocks, and only the last
block they put 8 weeks into the future.

**Antoine Poinsot**: Okay, so they cannot publish the last block?

**Mark Erhardt**: They actually cannot publish the last block of the first
attacker period yet.

**Antoine Poinsot**: Yeah, so they hold back the timestamps for one period.
Last block, they put it very high in the future, so it means that at this point,
the miner starts mining on --

**Mark Erhardt**: According to the difficulty, yeah.

**Antoine Poinsot**: -- without publishing their block, like they're hiding
their block.  Whereas with time warp, they're always still publishing their
block and the network just accepts them because it's broken.  But with this new
attack, they just hide their block and because it was for 8 weeks in the future,
it divides the difficulty by 4.  So, they start mining the next period, so it's
going to take 2 weeks divided by 4 to mine the next block period, and they still
do the same.  So, they still put it 8 more weeks in the future, so the last
block in the next period is going to be 16 weeks in the future.  And so, it will
make it possible to still reduce the difficulty by a factor of 4.  And they are
going to keep doing that until the real clock time is going to be --

**Mark Erhardt**: Let me jump in here briefly.

**Antoine Poinsot**: Yeah, go.

**Mark Erhardt**: They keep the timestamps of all blocks in the past as far as
possible, and you only have to increase the timestamp block of every sixth block
by one second.  So basically, they can keep the timestamp of all the blocks of
the attacker chain at the time that they started the attack, with some minuscule
increase in seconds.  Then in the first difficulty period, they set the last
block to 8 weeks in the future.  And because the first block of the next
difficulty period is clamped to it, that one also has a timestamp of roughly 8
weeks in the future.  And then, in the second difficulty period, they keep all
the blocks in the past again, except for the first one.  And then the last one,
they set 16 weeks in the future.  Because another 8 weeks have passed, between 8
weeks and 16 weeks, they reduce the difficulty again by a factor of 4.  So, they
are now at one-sixteenth of the original difficulty.

Then, in the third difficulty period, and here that's the part that was missing,
they start with a very high future time, 16 weeks in the future, but then they
set the last timestamp in the difficulty period to the most in the past that
they can, so to the time of the start of the attack.  That means that the
difficulty is increased by a factor of 4, because now -16 weeks passed for the
third difficulty period.  But because the difficulty adjustment is clamped to a
factor of 4, it can only increase up to factor of 4 or reduce by a factor of
four, they can basically go forward in 2 steps and reduce the difficulty by a
factor of 16, and then go back in a single step and increase the difficulty only
by a factor of 4.  And that allows them now to repeatedly reduce the difficulty
by another factor of 4, increasing the speed at which they're mining blocks by a
factor of 4 every 2 difficulty periods.  And that allows them to still produce a
chain that roughly has the same total difficulty, but mines a ton of blocks in a
very short period of time with an increasing pace.  And eventually, we have the
same outcome as with the original time warp attack, where they can just reduce
the difficulty to minimum and just blot out any other participant in the network
by broadcasting blocks so quickly.

So, they can collect more fees because they have more block space, if the blocks
are full in the defender chain, and they can collect all of the subsidies of
blocks.  So, the attacker is potentially making more money than 50% of the
network, up to more than 100% of what the other network is earning, the
defending chain, but they have to be in secret for 16 weeks, roughly.  Actually,
longer, right?  Because they -- well anyway, they can only publish the attacker
chain when the timestamp is 16 weeks progressed.  So, the attack requires an
extreme amount of selfish mining in private where they have to continue to hold
roughly 50% of the hashrate.  So, it's extremely unlikely to be used, but it
still works even when the last and the first block at the end of a difficulty
period to the start of the next one are clamped together.  Okay, back to you.

**Antoine Poinsot**: Yes, I think the main observation also that Murch pointed
out, even if you didn't understand the whole attack from just a note here, if
you look at the table for each block and the difficulty of this block, you would
be able to understand the attack pretty quickly.  But the other important thing
to understand and to take away from this podcast is also that the time warp fix
does not fix this attack.  That's why Murch's description of the attack assumes
that the first block is clamped to the timestamp of the last block of the
previous period.  So, yeah, that's it.  And the fix for this is also as simple
as the fix for the time warp.  Pretty much like we tied together the first block
of a period with the last block of the previous period, for this fix, it's to
say that the last block of one period can never have a timestamp that is lower
than the first block of the same period, which makes absolute sense.  Why would
a block 2,016 blocks later, have a timestamp lower than the block 2,016 blocks
before.  It's also, as far as I know, never happened.  On mainnet, it would be
very safe to roll out.  Yeah, and we'd completely prevent this attack.

So, I took also the Bitcoin Optech Newsletter when you mentioned that -- yeah,
sorry, go ahead, Murch.

**Mark Erhardt**: So basically, we're just requiring that a difficulty period at
least takes one second; 2,016 blocks should take more than one second.  And this
prevents you from doing the going overly back in time thing in a difficulty
period, which allows you to exploit the clamp, right?  Where you previously were
going down a quarter down to a sixteenth in 2 steps and then back up a factor of
4, but resetting the time so you could reuse the time span, this doesn't work
anymore because you're going back is inhibited to not going back at all.  You
can't go negative time in a difficulty period.

**Mike Schmidt**: I think when this discussion came up in #316, it was around
testnet4.  Is testnet vulnerable to this attack and is anyone doing any
shenanigans with that?

**Antoine Poinsot**: I'm not aware of anyone exploiting it.

**Mark Erhardt**: Yeah, we have not seen time warp on any Bitcoin-related
network, I think.  I don't know if any altcoin has ever experienced a time warp
attack or anything.

**Antoine Riard**: It did happen on, like, it was Vertcoin or something like
that?

**Antoine Poinsot**: Verge, yeah, on Verge, yes.

**Mark Erhardt**: Was that the same as the big reorg attack?  I thought that,
was it, I seem to remember that I thought it was Verge coin had this 1,000-block
reorg, but I'm not sure if they also did a time warp at the same time, did they?

**Antoine Poinsot**: I am pretty sure that there's a Verge somewhere, a time
warp.

**Mark Erhardt**: Cool, all right.  So, in the newsletter, we mentioned that
some other people had other ideas about how this attack would be fixed.  Do you
want to get into that a little bit?

**Antoine Poinsot**: Sure.  So there, we had a lot of ideas about a lot of
attacks and a lot of fixes for this specific issue.  I do not think all of them
are applicable to today's Bitcoin and it would not be realistic to do a lot of
the recommendations.  One of them was potentially applicable to today's Bitcoin,
which is basically what we are saying when we want to say that one period takes
at least one second, is that we enforce monotonicity between the first block of
a period and the last block.  And what he was saying, "Well, actually, we could
just enforce monotonicity between every block in the period.  And this way we
have better timelocks and blah, blah, and we have better things".  And AJ was
like, "That's probably safe to do, because we have ten minutes between each
block.  It's not like we have ten-second block intervals, so it could cause a
coordination issue".

I feel like the entire difficulty adjustment algorithm only relies on two
timestamps, which is the first and the last block of periods, and that's where
the issue lies.  And I feel like we are fixing Bitcoin on the fly here.  So, I
think we should go for the safest, simplest fix that entirely fixes the attack.
So, maybe it would be nice to have to have monotonicity between each block, but
not fixing on the fly, yes.

**Mark Erhardt**: So, what would be potential problems if every block had to
have a higher timestamp or same timestamp as the previous block?  That would
mean that if someone starts doing shenanigans with the timestamp and
broadcasting a block with a timestamp of up to two hours in the future, of
course all of the subsequent blocks would have to adjust to that and basically
regenerate from that in the next two hours.  As blocks are found, the timestamps
get closer to the real time again.  But I think that AJ also mentioned the idea
of requiring that no timestamp can be more than two hours earlier than the
previous block, which matches the two-hour window.  It does not, I think
however, fix the Murch-Zawy time warp attack, because if you just go back two
hours in every block, like from block 1 to block 2,016, you can go back 4,000
hours, and that should be probably more than 8 weeks, right?

**Antoine Poinsot**: Well, if you require one second more every time, yes, you
can still do it a little bit, because you have 7,200 seconds and you have only
2,016 blocks.  I'm not sure.

**Mark Erhardt**: So, my calculator says that if you can go back two hours in
every block, you can actually achieve -- never mind, the MTP prevents that,
because your last 11 blocks would then never be more.  Yeah, okay, never mind,
you can't hold back a timestamp that way anymore, so that does prevent the
issue.

**Antoine Poinsot**: It's fine, because you can just keep it two hours.  The
first block is two hours back from the current time, then the next block is the
same, then you arrive at the sixth block where you need to put it two hours plus
one second, and then you have a budget of six more blocks, and you do that, and
you just need to bump by one second basically, so it doesn't prevent it
entirely.

**Mark Erhardt**: Well, I'll have to think more about it, but if you can't go
more than two hours back and you always look at the last 11 blocks, putting the
last and first block at a difficulty period edge to the actual time, or a future
time, would mean that you can only move back six times two hours from that
point.  Because with each step, you can only go back two more hours, and then at
some point, your MTP will catch up.  So, you can't go back more than I think 12
hours is my intuition, but I'll have to verify that.  We're also getting super
in the weeds here!

**Antoine Poinsot**: Yeah, we are.  And I think it's a good illustration of my
point.  It's like the bell curve IQ meme, right?  Just prevent negative
timestamp for one period.  Actually, we can make it monotonicity between each
block, and actually it would cover the attack, but it just makes it harder to
reason about and actually just avoids for it to be negative.

**Mark Erhardt**: Yeah, and it has potential other second-order effects that we
have to think through.  Maybe some mining hashrate wouldn't notice that they
have to always match at least the last block minus two hours, or people might
publish invalid blocks and lose money; or maybe our timestamps would get stuck
two hours in the future all the time for some reason that I'd want to think more
about, but things like that pop in the mind that need to be checked.

**Antoine Poinsot**: Yes, so tl;dr, my opinion on this is that it's probably
applicable, but I think it would be more reasonable to do if we were to design
Bitcoin from scratch, and not if we are trying to fix it on the fly.  Can I talk
to the last item on the newsletter, or do we have anything else on the
timestamps?

**Antoine Riard**: Just the thing is, a block wouldn't be valid if it's more
than two hours in the past compared to your local world clock.

**Mark Erhardt**: So, there's two restrictions on the timestamp.  One is nodes
do not accept blocks that are timestamped more than two hours in the future from
their own time.  And the other one would be, that was one of the proposed
solutions, that you cannot go back more than two hours from the timestamp of the
predecessor block.

**Antoine Riard**: You cannot go back?

**Mark Erhardt**: Like, if the last block was mined at noon today, then you
can't have more than 10.00am today as the next block timestamp.

**Antoine Riard**: The last block was 10.00pm, the next block cannot be as
11.00am?  That's the idea?  Yeah, I mean it sounds super-risky because now I can
just, especially if you have a difficulty period where the difficulty is going
down, I can mine cheaper blocks and use them to restrict, I don't know.

**Mark Erhardt**: You would still have to adhere to the MTP rule.  So, if the
last 11 blocks have timestamps that are lower…

**Antoine Riard**: Yeah.

**Mark Erhardt**: Well, anyway, so it would be a second restriction on it.  You
can't go back more than two hours than the previous block.  Yeah, anyway, I
think we're reopening the same conversation again that Antoine and I had just
before.

**Mike Schmidt**: Antoine, did you want to talk about the duplicate transaction
component?

**Antoine Poinsot**: Yes.

**Mike Schmidt**: Okay, go ahead.

**Antoine Poinsot**: Yeah, very quick.  I think we already discussed it back
when you had me on, when I published the research on the consensus cleanup.  I
think it would be nice to make coinbase unique, base transactions unique, from
now on, such as we do not have to re-enable the check for duplicate transaction
in the future, which is something like 20 years from now.  But if we're going to
do a cleanup soft fork, there is very simple fix that we can include, such as
bitcoin transactions are actually unique again, so that's cool.  However, it
requires slightly tweaking the coinbase transaction.  So, I was just curious if
there was any reason I was not aware of that one way of fixing it would be more
complicated for miners to roll out than another.  So, I posted to the
Bitcoin-Mining-Dev mailing list to gather opinions about various possibilities
to fix this.

I've got one reply from one person, I'm not sure from what organization though,
but they said that this did not pose any of the fix, did not pose particular
issue or should be preferred over another.  So, various fixes have also
interesting features that would be nice to have.  So, if they're the same, other
things equal, we could probably favor one which allows, for instance, to take
the block height value from the locktime field of a coinbase transaction without
having to parse the scriptSig.  That would be nice to have.  Yeah, so that's it,
it was mostly a request for feedback from mining pools.

**Mark Erhardt**: Yeah, so please, if you're interested in or if you run mining
operations and you're familiar with the restrictions on coinbase transactions in
your block template creation or hardware, and if there's any restrictions on
this, please chime in and let protocol developers that are proposing to
potentially add more restrictions to coinbase transactions, please let them know
if you would not be able to adhere to them or implement them.  Other than that,
I have a question while I have you here, Antoine.  If you put the locktime to
the current block height, that would of course be invalid if the sequence
enforces that the locktime to be active, because the locktime in a transaction
shows the last block that cannot include a transaction if the locktime is
active.  So, essentially you would be restricting both the sequence value to the
max value, which disables the locktime, as well as the locktime field to a
specific value.  Did anyone previously set other values there?  Why aren't
people using that for entropy or something?  That seems like such an available
field in coinbase transactions.

**Antoine Poinsot**: Yeah, I don't know.  I suggested to use the sequence final
as well, on the Delving post, as you know.  I think I'm coming around to just
putting the block height minus one in the in the locktime field instead because,
hey, we're already constraining 4 bytes, so let's keep the 4 bytes from the
sequence free to be used by anything in the future.  Or, as you mentioned, if
anybody has some codes to actually use it today, let's not make it invalid.

**Mark Erhardt**: One more question.  So, another option would be to require
that the coinbase transaction uses v2 or v3 for whatever reason.  Maybe not v3
because that would limit the size of the coinbase transaction, but v2.  Is there
any downsides to that?  That seems like a very clean, very simple fix.

**Antoine Poinsot**: V3 would not limit the size of the coinbase transaction.
It's only a standardness rule, right?

**Mark Erhardt**: That is correct, yes.  You are most correct.  You're
technically correct, which is the only way of being correct.

**Antoine Poinsot**: Yeah, the downside is that currently you can have software
that might be interested in learning the height of a block just from the
coinbase transaction, and right now it requires parsing the scriptSig of the
coinbase transaction, which is mildly annoying.  That's feasible, but it's a bit
annoying.  If you could just, from the header of the coinbase transaction, be
able to learn the block height of the block, which is the nLockTime field in the
coinbase, it's in the header of the coinbase transaction, it would be neat.  So,
let's say the trade-off here is we can just constrain 1 bit in the version of
the coinbase transaction and we would fix the bug.  But if we were to trade 4
bytes, we could also have this neat way of querying the block height of a
transaction.

**Mark Erhardt**: Okay, let me spitball you something.  Why not put the block
height in the version?  I think it's just non-standard, right, not invalid to
have higher versions?

**Antoine Poinsot**: Yeah, I think it's possible.  Didn't I mention it?  I think
I mentioned it.

**Mark Erhardt**: I'm sorry, I read it like weeks ago.  I didn't read it again
before our podcast, but anyway, okay.  So, there's lots of options.

**Antoine Poinsot**: Oh, wait, no, no.  Because there are weird constraints from
earlier soft fork about block versions.  So, we will have to see if the...

**Mark Erhardt**: Right.  People, people will signal for...

**Antoine Riard**: Before BIP9 we were using…

**Mark Erhardt**: That's in the block version, not in the transaction version,
right?

**Antoine Poinsot**: So, I think by consensus, we reject block with block
version.  Oh yeah, no, that's block versions.  No, no, that's nonsense, sorry.

**Mark Erhardt**: Okay.  Let's do on-the-fly protocol development some other
time, I think.  What do you think, Mike, have we covered this news item
sufficiently?

**Mike Schmidt**: Yeah, yeah, this is great.  So, I think the call to action
here, Antoine, is you've posted on Delving, you've posted on the Bitcoin-Dev
mailing list, and you've also posted on the Bitcoin development miner mailing
list to solicit feedback on the approach here.  So, if you're affiliated with a
mining organization, you should take a look at one of those places and opine
accordingly, even if you don't have further thoughts.  Anything else Antoine?

**Antoine Poinsot**: No, I don't have anything else.  And of course, if you're
listening to this and feel not comfortable maybe shaming in public or
opinionating on the protocol, and you want to reach out about that, I'm happy to
discuss what the potential impact to your mining business could be of this.  So,
yeah, reach out in any way possible.  If a miner is listening to this, reach out
in any way possible.

**Mike Schmidt**: I was excited.  I saw the discussion and I went to post on the
Mining-Dev mailing list, and you had already posted.  So, thank you.

**Mark Erhardt**: Yeah, and I was confused because I didn't see it, because he
sent in the same email to the Mining-Dev mailing list and Bitcoin-Dev and then
sort it into the Bitcoin-Dev field.

**Mike Schmidt**: Thanks for joining us, Antoine.  You're welcome to stay on or
drop if you need to.  Releases and release candidates.  We have all the major LN
implementations having a Release or release candidate this week, which I think
is a first.

_Eclair v0.11.0_

First one, Eclair v0.11.0, which adds official support for BOLT12 offers.  It
also stops accepting non-anchor channels, and it adds a bunch of features around
liquidity management that we spoke about with t-bast previously.  Many of those
PRs were from Newsletter #323.  We had t-bast on in Podcast #323.  He did a
great overview of the features there, so I figured we wouldn't bother him to do
that again here.  So, refer back to that episode for the details.  I really
recommend you listen to that segment, which included a discussion of liquidity
ads, on-the-fly funding, and fee credits as well.

_LDK v0.0.125_

LDK v0.0.125.  This is a bug fix release.  It looked like it had four bug fixes.
The most important bug fix that was noted was a fix for a bug that happened when
you were upgrading to the previous version, v0.0.124, and during that upgrade
process, it could cause unintended force closures of channels.  And the details
were beyond my understanding but check out the release notes if you're curious
about that, or just jump to 125.

_Core Lightning 24.11rc3_

Core Lightning 24.11rc3, which follows from our coverage of this RC2 from last
week.  And I see, as of yesterday, this 24.11 is actually officially released.
So, I'm going to reach out to the CLN team to see if someone would like to join
us perhaps next week when we cover the official release and can discuss that.

_LND 0.18.4-beta.rc1_

LND 0.18.4-beta.rc1, which is an RC that we covered last week, so refer back to
that.  Also, test your RCs please.

_Bitcoin Core 28.1RC1_

And last release candidate, Bitcoin Core 28.1RX1.  I have in my notes here a
link to the release notes, but I wanted to punt to Murch if you had any
commentary on this RC.

**Mark Erhardt**: Yeah, I looked at it briefly.  So, this is the latest in the
major 28 branch, which is of course the release that just came out in October.
It looks like there's just six bug fixes and there is some, I don't know,
nothing too major.  If you are on the 28 branch, I would suggest that you check
whether any of those fixes are relevant for you.  And generally, you want to be
on the latest version.  Other than that, it's just a maintenance release.

_Bitcoin Core #30708_

**Mike Schmidt**: Notable code and documentation changes.  Bitcoin Core #30708
adds a getdescriptoractivity RPC that gets all the transactions associated with
the descriptor within a set of blockhashes.  It gets the activity.  So, you
parse in a list of blockhashes and get back from the RPC all the events for that
descriptor, including spends and receives relevant to that descriptor.  If
someone's not familiar with the scanblocks RPC, your first question would be,
"How do you know which blockhashes are relevant to your descriptor?"  And there
is an RPC for that as well.  The scanblocks RPC was added to Bitcoin Core in
2022, which given a descriptor, will give you a list of blockhashes that contain
activity for that descriptor.  So, you can use those two in conjunction.

**Mark Erhardt**: So if you, for example, had multiple descriptors on your
wallets, you could use this to only look at the activity regarding one.  For
example, if you give someone a pubkey or a descriptor that they always paid to,
you would that way sort of have an account-like feature after the account
feature was removed in Bitcoin Core a few years ago.

_Core Lightning #7832_

**Mike Schmidt**: Core Lightning #7832 changes CLN's behavior around anchor
transactions.  So, previously in CLN, if a commitment transaction didn't have
any HTLCs and wasn't urgent, CLN didn't create an anchor at all, which could
cause issues, since CLN didn't provide a good way for users to do this
themselves.  So, with this PR, CLN will now create a low-priority anchor for
these low-fee unilateral closes, even if there is no urgency.  And so, I think
we noted in the newsletter --

**Mark Erhardt**: And when you say, "Will create an anchor", you mean a
transaction that spends the anchor output, right?

**Mike Schmidt**: Yes.  And the approach is a 2,016 block, so two-week block
target, and then slowly going down over time to that 12-block fee target over
time.

**Antoine Riard**: That way, if you don't agree with the point of priority on
like a closing feerate for your channel, you can go with the lowest one and just
like fee bump it with the CPFP.

_LND #8270_

**Mike Schmidt**: Thanks Antoine.  Now LND #8270, the quiescence protocol PR.
The quiescence protocol, essentially the way I think about it is it just pauses
a channel for a period of time while larger changes to the channel can happen.
One such change would be, for example, for splicing, and quiescence is a
requirement for splicing.  This PR is part of a series of PRs implementing
dynamic commitments in LND, and it follows from the quiescence protocol updates
in the BOLT specs that we covered earlier this year, in Newsletter #309.  And
the quiescence protocol is actually a prerequisite for dynamic commitments.

**Mark Erhardt**: And dynamic commitments is a channel commitment upgrade
mechanism.

**Mike Schmidt**: That's right.  One thing to note that I saw from the writeup
here, "This PR does NOT include a mechanism for timing out a quiescence session.
This means that if we have an intentionally or unintentionally uncooperative
peer, the channel will remain quiesced indefinitely".

**Mark Erhardt**: That seems kind of dangerous.

**Mike Schmidt**: It did to me, so I thought I would note it.

**Antoine Poinsot**: Well, your peer can always decide to stop responding to
messages.

_LND #8390_

**Mike Schmidt**: LND #8390 adds the ability for LND to set and relay an
experimental field that signals endorsement of the HTLC.  We note in the
newsletter, "If a node receives an HTLC with the signaling field, it will relay
the field as is; otherwise, it sets a default value of zero".  The goal here is
continuation of research into channel jamming attacks and potential mitigations
that we've covered over the last couple years.  I think our topic entry on
channel jamming gives a lot of historical context to this discussion, and also
links off to a lot of the newsletters where we covered different research
topics.

**Mark Erhardt**: So, so far this does not mean that HTLC endorsements are
active, but rather HTLC endorsement messages are being propagated, so that the
researchers can watch whether they do propagate and if they propagate, what
value do they have.  And that would allow them to learn whether it's viable, or
if the solution will not have any adverse effects, hopefully.

**Mike Schmidt**: And it's a field on the HTLC that is a boolean.  Is that
right, Murch?  So, it's, "I endorse this or I don't".

**Mark Erhardt**: Right.  Okay, so originally the idea was, so HTLCs are usually
multi-hop contracts being set up and they originate from the sender.  The sender
builds a node and then sends a set of onions wrapped in each other that set up
all of the HTLC steps to the receiver, right?  And the idea for the HTLC
endorsement mechanism to fix, I believe it's slow jamming, is that you would
reserve part of your capacity and part of your HTLC slots only for endorsed
HTLCs.  And once, let's say, half of your capacity and half your slots are
taken, you would not receive an unendorsed HTLC.  And yes, the idea would be
that when you set the HTLC, you signal to the other side whether you endorse
that HTLC.  And if the other side sees that, they might take that into account
towards whether they want to also endorse it to the next step.  And I think
there was recently a discovery that some issues are mitigated if you do it in
reverse order, but I don't have it in detail right now.  So, maybe we'll talk
about that in another episode sometime.

**Mike Schmidt**: Antoine or Antoine, any thoughts on this topic?

**Antoine Poinsot**: I do not have thoughts on the topic because I'm not
familiar, but I just checked and it's indeed just a flag, just a boolean set on
the HTLC.

_BIPs #1534_

**Mike Schmidt**: Last PR this week to the BIPs repository, BIPs #1534, which
adds BIP349, which is a specification for an OP_INTERNALKEY tapscript-only
opcode.  Murch, you are resident BIPs editor, and I believe you hit the button
or reviewed this.  What's going on here?  What is OP_INTERNALKEY?

**Mark Erhardt**: Okay, so there's been a lot of work on various introspection
or otherwise new opcodes to make introspection and covenant proposals more
feasible.  This belongs to the suit of proposals that belong to LNHANCE.  And
LNHANCE as a package would be proposing mechanisms to do both LN-Symmetry for
the LN, and then things similar to CHECKTEMPLATEVERIFY (CTV) and, well, it
includes CTV.  So, you'd be able to build covenants with it and other more
complicated covenant-like structures, I think, like maybe payment pools would be
pretty easy and things like that.  OP_INTERNALKEY specifically is a very simple
new opcode.  It would push the internal key of the taproot output to the stack.
And then you could, for example, interact with it with CHECKSIGFROMSTACK (CSFS)
and use it as like the key to check this signature against.  So, if there's a
message, a signature and a key, you can do a signature verification with CSFS.
So, it belongs to that set of things.

It's, as I said, fairly simple as an opcode, because it just reveals that
internal key of the taproot construction.  So, maybe to explain, taproot outputs
have two keys, the publicly visible external key, and then there's an internal
key that is tweaked in combination with the merkle root of the taproot tree.
So, this one would just reveal the internal key, not the external key that the
output script shows.  Anyway, in some constructions it can save 8 vbytes, and
it's merged, it's still a draft BIP.  I'm not sure, the LNHANCE suite is one of
multiple competing proposals that I feel like all could use a little more public
discussion or endorsement, and yeah, if covenant stuff interests you, I hope you
can refer to OP_INTERNALKEY as BIP349 now.

**Mike Schmidt**: Thanks, Murch.  Well, that's it for the newsletter this week.
Thank you to Antoine for joining and for Antoine for joining, and my co-host as
always, Murch, and for you all for listening.  Cheers.

**Antoine Poinsot**: Thanks for having us, cheers.

**Mark Erhardt**: Hear you soon.

{% include references.md %}
