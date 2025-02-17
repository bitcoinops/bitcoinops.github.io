---
title: 'Bitcoin Optech Newsletter #339 Recap Podcast'
permalink: /en/podcast/2025/02/04/
reference: /en/newsletters/2025/01/31/
name: 2025-02-04-recap
slug: 2025-02-04-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Dave Harding are joined by Matt Morehouse and 0xB10C to discuss [Newsletter #339]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-1-7/394462918-44100-2-0107d2a8e1459.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mark Erhardt**: Hello and welcome to Bitcoin Optech Newsletter Recap #339.  As
you can hear, I'm not Mike.  This is Murch, and my guests today are Dave
Harding.

**Dave Harding**: I'm Dave Harding, I'm the co-author of the Optech Newsletter
and co-author of the third edition of Mastering Bitcoin.

**Mark Erhardt**: And also, Matt Morehouse.

**Matt Morehouse**: Hey folks, I'm Matt Morehouse, I've been working on the LN
and I'm especially interested in the security of the network.

**Mark Erhardt**: Thanks for joining me.  In today's newsletter, we will be
covering the News, the selected Q&A from Bitcoin Stack Exchange, Releases and
release candidates, and Notable code and documentation changes.  And it's great
that we have Matt on because today we're going to start with a news item that
was prompted by his post to Delving Bitcoin.

_Vulnerability in LDK claim processing_

He disclosed a vulnerability affecting LDK and this has to do with how LDK
closes channels with multiple pending HTLCs (Hash Time Locked Contracts).  And
as far as I understand, Matt discovered that if you have multiple HTLCs on a
channel and someone broadcasts a conflicting transaction that closes one of the
HTLCs, LDK would correctly recreate a batch transaction to close all of the
other HTLCs.  However, it would not do so if multiple conflicting transactions
were created to create single HTLC closing transactions.  It would only respond
to the first one and then not process the rest of the HTLCs.  Good thing that we
have Matt here to explain all the details to us.  Do you want to jump in?

**Matt Morehouse**: Yeah.  So, at a high level, prior to LDK 0.1, an attacker
could force close a channel with a victim and then claim HTLCs from that channel
onchain in a specific way.  And by doing that, they would force LDK to generate
an invalid claim transaction for the rest of the HTLCs.  And of course, since an
invalid transaction can't be mined, those HTLCs would get stuck in kind of a
limbo state where LDK hadn't exactly lost them, but it couldn't use them for any
other purpose, it couldn't reclaim the funds to use them for anything else.
This was fixed in LDK 0.1.  If you've been attacked in this way, you can upgrade
and replay the force close and the counterparties' claim transactions, and LDK
will then be able to generate a valid transaction to unlock your funds.  And at
this point, you may as well update to 0.1.1, because that's out now and has more
vulnerability fixes.  That's kind of the overview.  I can go more into detail
about the specific vulnerability if you like.

**Mark Erhardt**: Please do.

**Matt Morehouse**: Okay, so to understand it, we have to first understand what
happens when a channel is force closed.  So, when a force close happens on the
LN, it means one of the two parties in the channel broadcast their commitment
transaction.  And when that commitment transaction was originally generated and
signed, it's possible that there were HTLCs in flight on the channel at that
point.  If that's the case, each one of those HTLCs gets its own output on the
commitment transaction.  And then, when that commitment transaction hits the
chain, either party, depending on their role for that particular HTLC, can claim
the HTLC in a different way.  So, the receiver of the HTLC, if they broadcast a
preimage claim transaction, they can unlock the funds immediately that way.  For
the sender, though, they're not allowed to use the preimage.  They have to wait
for a timelock to expire and then they can use a timeout claim to get a refund
of the HTLC.  So, once that timelock expires, it's actually possible for both
parties to be trying to claim the same HTLC at the same time.  And in that case,
whoever gets their claim transaction confirmed first is basically the winner.
So, that's one thing we got to understand.

The other thing is, when that transaction hits the chain, if there's multiple
HTLCs on the transaction, you can actually claim multiple of them at the same
time in the same transaction.  And doing that, you can save onchain fees.  So,
LDK actually does this in certain cases.  And that's great, it saves on fees.
It adds a bit of a complexity though, because if the counterparty is able to get
their competing claim confirmed first, they can cause one of those HTLCs in the
batch to be already spent, which makes the batch invalid.  And this is kind of
the fundamental problem here.  Normally, LDK is able to recognize that this
happened and then they run some package, some batch-splitting logic that splits
out the conflicting inputs and makes the transaction valid again, so that LDK
can reclaim all the rest of the HTLCs.  What I discovered is that there's a bug
in this logic.  And if LDK has more than one batch in flight at the same time,
and then the counterparty creates a transaction that conflicts with multiple
batches, LDK will only split out the conflicting inputs from the first matching
batch.  The other batches are basically left in this invalid state, where LDK
can't reclaim any of the remaining HTLCs.

So, what an attacker needs to do to exploit this is two things.  They first need
to manipulate LDK into creating multiple batches, and then they need to
broadcast and confirm this conflicting transaction that conflicts with multiple
batches.  If they can do that, then they can lock up funds.  And I can go into
more detail about how exactly an attacker would do this for different versions
of LDK, but maybe let's pause here and make sure all that makes sense.

**Mark Erhardt**: Makes sense to me so far.

**Dave Harding**: It makes sense to me as well.  Yeah, I would like you to
describe, because my understanding is that for the older versions of LDK, the
worst case is that the fund would just be locked up.  They would be safe, but
they would be stuck until someone upgrades to a more recent version that has the
patch, and they would be unstuck.  But there was one version of LDK where there
was a fund-stuck threshold.  I'd be interested in hearing more about that.

**Matt Morehouse**: Yeah, that's exactly right.  So, prior to LDK 0.1 where this
was all fixed, there was 0.1 beta, and that pre-release started doing additional
batching where, on top of the batching that was done in previous releases, it
would also batch timeout claims together if they had the same locktime.  And so,
what this enabled was a more simple attack that could actually be used to steal
funds from LDK.  And the way it would work is the attacker would route multiple,
let's say three, HTLCs to themselves through the victim to themselves.  And they
would set the locktimes on those HTLCs in a specific way to force LDK to batch
them separately.  So, the first HTLC would have locktime of X, and the second
and third HTLCs would have locktimes of X+1.  And so then, when the attacker
force closed the channel and waited for those locktimes to expire, LDK would
batch HTLC1 by itself, and then HTLCs 2 and 3 that have the different locktime
would get their own batch.

So, the separate batching is achieved that way.  And then, it's pretty simple to
broadcast a transaction, a preimage claim that spends HTLC1 and HTLC2.  And once
the attacker does that, it causes conflicts with both of those packages.  And
because of the bug I described earlier, HTLC3 gets locked up.  Now, the
attacker, at that point, just needs to wait until the upstream HTLC3 expires.
And then, the whole payment gets failed back. The attacker is basically refunded
HTLC3 at that point.  And then, they can still go onchain and broadcast a
preimage claim to get HTLC3 from the victim.  And so, that's basically how they
would steal HTLC3.  Now again, this was only possible in 0.1 beta because of the
additional batching that started to happen.  And then, version 0.1 fixed the bug
so that it's also not possible to do this attack there.  Prior to 0.1 beta,
timeout claims were not batched together.  The batching was much more
restricted.  Only preimage claims were batched, or if a revoked commitment
confirmed, then all the claims on the revoked commitment would be batched
together.

So, my blogpost goes into more detail about how the attack works for older
versions of LDK, but essentially a revoked commitment has to be used, and
because of that, funds can only be locked up instead of outright stolen, because
once the upstream payment gets failed back, the attacker gets HTLC3 refunded to
them.  In order to steal it, they would then need to attempt to get their
preimage claim confirmed.  And if they do that, then LDK is able to use a
justice transaction to recover funds from that second stage transaction.  So,
funds can only be locked up not stolen, is kind of the short story.  I don't
know if we want to go into even more detail there, but there's a whole other bug
that's exploited with that variant of the attack.  I'll leave it up to you guys.

**Mark Erhardt**: Let me jump in to an earlier part first.  You said that if you
upgrade to version 0.1 or 0.1.1, you can replay the previous commitments and,
what was it, commitment transactions?  How would you replay stuff?  Does LDK do
that automatically, or is there some manual intervention involved?

**Matt Morehouse**: Yeah, so I'm not sure if it can be done automatically.  What
I do know is LDK is an API, so every time a block confirms, you can feed it a
new block and it will scan the block for transactions it cares about and handle
them.  There's another API where you can give it specific transactions that LDK
wants to know about.  So, you can use that API, you can give it the commitment
transaction that was broadcast and confirmed, and then you can follow up with
the HTLC transactions.  And that will give LDK what it needs to know in order to
create a valid claim transaction.

**Mark Erhardt**: I see, that's cool.  So, you can actually just replace
specific transactions and get them reprocessed.

**Matt Morehouse**: Right.

**Mark Erhardt**: Dave, did you want to ask a follow-up question?

**Dave Harding**: I don't have any follow-up questions on this.  If you want to
go into more detail, that's fine.  But I also did want to ask you about, you
made another disclosure after this for another bug in LDK, and I already have a
draft summary written for next week's newsletter.  But I was wondering if you
wanted to talk about LDK duplicate HTLC force close griefing, your post to
Delving from six days ago?

**Matt Morehouse**: Yeah, sure.  So, this vulnerability was fixed in 0.1.1,
which is another good reason to upgrade to that version instead of 0.1.  But
basically, an attacker could force close all the channels on your node or cause
them to be force closed.  So, if you care about your channels, you should
probably upgrade.

**Dave Harding**: Great, thank you.  I guess I have one question about both of
these together.  They both kind of look like it was a loop terminating earlier
than it should have.  Is that the case?

**Matt Morehouse**: That's certainly the case for the invalid claims one.  So,
the duplicate HTLC, maybe you could fix it that way.  I think that one is more
of, there was a change made later on, and maybe we can talk about this more next
week, but there was a change made that kind of seemed to try to get a little too
fancy, where it's trying to reclaim funds in a very corner case and to use a way
of matching up HTLCs that's not entirely accurate all the time.  So, you could
fool it by using duplicate HTLCs on a revoked commitment.  And prior to trying
to get fancy in that way, it all was safe and the conservative thing was done,
and all the potential HTLCs were failed back.  But after trying to get too
fancy, then things started to have problems.

**Mark Erhardt**: Yeah, sometimes we engineers are too smart for our own good,
right?  Dave?

**Dave Harding**: I guess I just had one final question, which was for both of
these bugs, how did you discover them?  You wrote in both that it was from an
audit.  Was that just you reviewing code, or were you applying any sort of
tools, or any sort of systematic approach, or just looking through the code?

**Matt Morehouse**: Yeah, good question.  I was just reading the code very
carefully.  That's about it.

**Dave Harding**: Thank you so much for doing that.

**Mark Erhardt**: Yeah, thank you, and thank you for joining us.  Do you have
something else to add to the topic or do you have a call to action for the
audience?

**Matt Morehouse**: I would say, so when I was reviewing this code for LDK, my
general impression was the code was hard to read, it was hard to understand.
And I think maybe it's a little bit overlooked by a lot of people, but I think
improving code readability, improving documentation, making the code easier to
understand, can go a long ways to help prevent bugs from happening, prevent new
bugs from being introduced, because maybe the code's originally bug-free, but
both of these vulnerabilities ended up being introduced at a later point,
because people didn't fully understand what the code was actually doing.  And
so, anything you can do, maybe you understand the code, but whoever is
maintaining it down the line isn't going to understand it as well.  So, whatever
you can do to make it easier to read the code and understand what's going on is
definitely worthwhile, especially for this kind of code that's so
security-critical.

**Mark Erhardt**: Super, thank you.  Thanks for joining us.  Your News item, I
think we've covered extensively.  So, if you want to stick around, we'd be happy
to have you.  If you have other things to do, we understand if you want to drop.
Thanks, Matt.

_Replacement cycling attacks with miner exploitation_

We are going to go to the next News item.  This is, "Replacement cycling attacks
with miner exploitation".  And, Dave, you wanted to chime in on this one.

**Dave Harding**: Sure, sure.  I think there's two things going on here.  First,
we have kind of an existing and somewhat known situation.  I don't know that I
ever quite thought about it this way, but it's pretty straightforward, which is
if you're sending money to a miner, so you're sending money, you don't
necessarily know that they're a miner, but they are a miner, you have an output,
they're receiving it.  They have the ability to employ various transaction
pinning techniques that will prevent you from fee bumping that transaction.
Now, usually you don't want to pin a transaction that someone is sending you
money, right, you want that money as fast as possible.  But in this case, you
might be sending money to other people, you might have some reason for this to
be a priority transaction, for example it's being used in LN or another contract
protocol, so you're going to fee bump it.  You've paid a miner, they can use a
transaction pinning technique to prevent you from fee bumping.  And by that, I
mean prevent a fee bump that you create from propagating across normal nodes on
the network.

In this case, the miner can also somehow get a direct connection to your node or
the client that you're using to create this transaction, and they can receive
your attempt to pin.  If all of that happens -- go ahead, Murch.

**Mark Erhardt**: Your attempt to bump, I think.

**Dave Harding**: Correct, your attempt to fee bump.  But if all of that
happens, then the miner will receive your attempted fee bump, so you're paying
more fees, but the transaction will propagate to other miners.  So, this miner
who has actively pinned you can receive more fees than other miners will
receive, because they're learning about your fee bumps, but nobody else is.  By
itself, that's maybe not too interesting because in order to pin a transaction,
you have to create a child transaction in this case, and that child transaction
would eventually probably be confirmed, so the attacker would lose money to
other miners.

However, what Antoine Riard has discovered is that his previously disclosed
replacement cycling attack from 2023 can also be used here to allow the pinning
transaction to be reused across multiple attacks.  So, Murch is sending a miner
money and the miner pins his transaction and waits for him to fee bump it, and
then claims the extra fees that he paid for fee bump that other miners didn't
have access to.  And then, I'm sending money to the miner and the miner just is
able to use replacement cycling to move his pin from Murch's transaction to my
transaction, and can keep doing this without ever having their pin confirmed.
Now eventually, their pin will confirm on somebody, because they're going to
have to keep escalating the fees to a certain degree, but they can do this
across multiple attacks.  Maybe they attack Murch multiple times because Murch
is a service provider; they attack me multiple times.  This makes the attack
more cost-efficient.  However, the base attack where a miner pins a transaction
and that transaction doesn't go out to other miners, it doesn't go across the
relay network, it doesn't propagate well, but the attacking miner does confirm
it, it's pretty detectable using tools built by our next guest.  So, we'll ask
him about that in a moment.

So, this is an attack.  It's something I think we should keep in mind, but it's
also something that I think would be pretty easy to detect.  And if you just
don't fee bump excessively, or you're careful about your fee bumping, I don't
know how much money can be stolen here.  And stolen isn't quite the right word,
but -- yeah, okay, go ahead, Murch.

**Mark Erhardt**: I think one point is maybe some of the light client models,
they don't actually watch the mempool directly and they don't have a good fee
estimate themselves.  They do hit third-party APIs for fee estimates sometimes,
but some of them actually just, while transactions don't get confirmed, continue
bumping them.  And now, I'm wondering if there is, for example, the alternative
Bitcoin Core client-based client with other mempool policies that only does
feerate-based relay that doesn't require the absolute fee to increase, so
something like that might be able to allow you to learn about a transaction like
that.  So, overall, if we look at Bitcoin Core nodes, I don't see how you would
ever see the fee bump while preventing everyone else from learning about it.
But maybe if you use other full node implementations with different mempool
policies, you might hear about something that most people don't hear about.

**Dave Harding**: Well, I think eventually, you might increase the feerate high
enough that you escape the pin, because a lot of these pins are based on like
absolute transaction fees, or other things like that.  So, you will eventually
escape the pin, if the attacking miner doesn't confirm it within that amount of
time.  Again, I think this is an interesting attack.  I don't think it's
something that's particularly applicable right now, and because we have good
detection tools, it's not something that I'm particularly worried about.  If it
happens, we'll see it happen, and people can adjust their software to adapt.
Murch, anything else?

**Mark Erhardt**: No, I think you're right.  I don't think it's particularly
practical.  Let's use this as a segue to the next News item.  We were meanwhile
joined by 0xB10C.  Do you want to introduce yourself?

**0xB10C**: Hey, I'm 0xB10C, or B10C, and I do lots of monitoring.

_Updated stats on compact block reconstruction_

**Mark Erhardt**: Hey, thanks for joining us.  So, your News item is, "Updated
stats on compact block reconstruction".  So, we talked about this in the last
year, where we were looking at a Delving post that you made where you had a
batch of different nodes on a network and were gathering statistics how often
these nodes would require to get additional transactions after receiving a
compact block announcement.  And it sounds like you found a correlation between
the size of the mempool and the number of transactions that need to be requested
in another round trip.  Do you want to expound on that?

**0xB10C**: So, yeah, I'm not sure if it's the size of the mempool or if it's
actively growing.  I think it's more of the same thing, that it's the mempool is
growing and, for more blocks, we need to request transactions that can be one
transaction or that can be multiple transactions.  But I actually haven't looked
into this too close yet.  Yeah.  And what I looked into is that these
transactions that are requested are quite often orphan transactions.  So, we
actually saw these transactions at one point, but we didn't have the parent for
it.  And then we need to, at some point, drop it from the orphan pool or the
external pool.  And then, we didn't have it for the reconstruction.  But that
also means we don't have the parent for it.  So, there seem to be at least two
transactions that are missing for each orphan.

**Dave Harding**: So, what I got from this thread was basically that we have a
few ideas for how to increase the amount of transactions that Bitcoin Core
stores in various ways that might be useful for block reconstruction, and that
your next steps are you've already increased the instrumenting on some of your
nodes, and you've changed the setting on some of your nodes, and you'll see if
that has any effect on it, and we'll come back and maybe talk about it again in
another month or so.

**0xB10C**: Yeah, so it's something I did today.  So, with a current empty
mempool, it makes it a bit harder to capture data.  And we actually need to have
a growing mempool arising before we come back to this and look at the data
again.  Because an empty mempool, the conversion is quite good, at least for the
past few months.  Yeah, and there has also been a PR by Gloria on the way of
turning orphans, and recreating them from peers that we think might have one.
But it might also have an effect of, I have multiple nodes, and I have one with
an increased extrapool size, and I have, for example, one with the new PR
version.  So, we can compare three scenarios of one node that's unchanged, and
two others.  You might be able to see some improvement in there, or you might
not.  And another thing that came up was providing a bit of the FIBRE mechanic
of not doing orphan constructions, but sending out blocks as fast as possible
across the network.  We also came up in this thread, which I found interesting,
but I'm not sure that's the immediate next step to take, or if you're saying,
let's try to improve on the reliability of the constructions.

**Mark Erhardt**: Yeah, I'm afraid I have a little trouble understanding you,
the sound is a bit rough.  I gathered that you were referring to a couple of PRs
by Gloria that improve how we handle orphans.  So, there's been specifically two
changes that are being made.  One is that we, instead of only asking the peer
that announced the orphan transaction to us for the parent, we will ask any peer
that announced the orphan to us for it, even if they were not the first one that
told us about it, if the first one doesn't give it to us.  And now there's talk
about having a separate amount of memory set aside per peer to store orphans,
which will allow us to have more robust orphan handling.  And all of these are
stepping stones towards more robust package relay.  There's a little bit more
package relay already now in the recent release of Bitcoin Core with TRUC
(Topologically Restricted Until Confirmation) transactions, which allow parents
to have zero fee and limit the topology of parent transaction pairs to just
that, a pair of transactions.

But I was also wondering, so one of the known issues with compact block relay is
that it may be anticipated that the most recently received transactions will not
be known by the peers.  So, there had long been the idea that a node would be
able to forward the last few transactions they received with the block
announcement, or if they had to do a round trip to get some transactions from
another peer, that they would forward them immediately with the compact block
relay announcement, like the last five-ish transactions, but this has not been
implemented so far.  Do you have an opinion on how much that might help?

**0xB10C**: I hope the audio is a bit better now, I'm not sure.  So, I've been
collecting data on this for the past week, but I haven't actually looked into it
yet, only very briefly, and there seem to be peers that request very different
sets of transactions from me.  So, the immediate answer would be maybe that's
not possible and not too helpful, but yeah, I definitely need to look closer
into the data.  And we also probably need data during a time where the mempool
isn't as empty as it is right now.

**Mark Erhardt**: Right, of course the mempool has, since December, dropped
precipitously and is now down to just a few blocks' worth of transactions
waiting to be confirmed.  And that is vastly different from most of last year,
where we were well above the 300 MB of data structure limit that standard or
default configured Bitcoin Core nodes have, and only bigger block explorers or
nodes with higher limits were even able to see the entire queue of transactions
waiting.  Good.  Yeah, the sound was much better.  And is there anything else
that you wanted to add to the topic, or do you have recommendations of where
people can engage with this topic

**0xB10C**: I think the best place to engage with the topic will be on Delving.

**Mark Erhardt**: Okay, cool.  Thank you for joining us.  Just like I told Matt,
you're welcome to stick around.  If you have other things to do, thanks for
joining us, we understand if you have to drop.  We will be getting to the
selected Q&A from Bitcoin Stack Exchange next, and we have quite the harvest
this time around.  So, I didn't even count it, but it's certainly more than ten
topics that we have here.

_Who uses or wants to use PSBTv2 (BIP370)? _

I'll start with the first one, "Who uses or wants to use PSBTv2?"  So, Sjors
Provoost recently asked, both on Stack Exchange and the mailing list, who
actually is trying to use PSBTv2, which is specified in BIP370.  And the
background to this question is, the PR to Bitcoin Core implementing PSBTv2 has
been open for a long time, has gotten very little review.  And if there are many
people that are interested in it, it would be helpful to get it reviewed in
Bitcoin Core, so that full nodes that make up most of the network would have
support for it, and that other implementations could benefit from testing the,
how do you say it, the compatibility between implementations and exchange test
vectors across the project.  So, this answer has meanwhile gathered a few
responses.  Apparently, Core Lightning (CLN) already uses PSBTv2 internally;
Ledger uses PSBTv2, but the companion app can also translate from v0, the prior
version of PSBT specified in BIP174; BIP375, which deals with silent payments
and PSBT, relies on PSBTv2; and both Coldcard and Sparrow apparently already
support PSBTv2.  If you have interest in that topic, maybe check out the Bitcoin
Core PR, or tell us about other libraries that already implement support for
PSBTv2.

_In the bitcoin's block genesis, which parts can be filled arbitrarily?_

Let's get to the next question.  The next question is, "In the bitcoin’s block
genesis, which parts can be filled arbitrarily?"  This was answered by Pieter
Wuille, and the answer is either everything or nothing, depending on how you
look at it.  So, if you look at how the genesis block could have been
constructed, it is arbitrary.  The block itself is not subject to the regular
block rules, so you could have defined it very differently.  It is merely
hard-coded in Bitcoin as the starting point of the blockchain, and therefore
Satoshi could have made different choices and made it very differently.
However, it is mostly adhering to the same rules that other blocks have, except
in some parts, like looking at the prior block is pretty hard from the genesis
block, and so forth.

On the other hand, nothing can be changed about the genesis block because the
genesis block is exactly that; it is defined into existence as the starting
point of the blockchain.  If you were to change anything about it, the starting
point of the blockchain would be different, block 1 wouldn't fit the rules of
the blockchain and would not point at the correct genesis block anymore, and the
entire blockchain history would not build on top of a changed genesis block.
So, depending on how you look at it, either nothing or everything can be changed
about the genesis block.

**Dave Harding**: I think you could argue that even though the genesis block
header commits to the block contents, it doesn't have to.  And so, if you didn't
have that check in there, the contents could be arbitrary or empty, or whatever.
I don't know, it's a pretty weird and interesting situation.

_Lightning force close detection_

**Mark Erhardt**: Yeah, exactly.  So, getting to another question, "Lightning
force close detection".  The user, Sanket1729, noticed that there is a diagram
in the mempool.space code which describes how they discover or detect Lightning
force close transactions.  Apparently, it is based on a couple prefixes that
appear in the sequence field and the locktime field of transactions.  And Sanket
was asking if there's some convention or what exactly makes this work?  Antoine
Poinsot answers that the nlocktime and nsequence field in the commitment
transactions are used, per the BOLT spec, to store obscured commitment numbers.
And this can be used to discover Lightning force close transactions.
Mempool.space basically makes the assumptions that if the sequence and the
nlocktime have these two prefixes, it's always a force close transaction.  So,
if you want to troll them, you can create transactions that use these two
values, and they'll label it as Lightning force closes, but it might not be.

**Dave Harding**: I'll just add quickly that the reason that the LN protocol has
the commitment numbers, which obviously we want to use if it's helping make it
easier to identify these transactions, is I believe for watchtower support.  So,
every commitment transaction in the LN has a different commitment number in
order for you to be able to give an encrypted copy of your transaction, your
justice transaction to a watchtower.  And then, when somebody broadcasts an old
state, that commitment number gives them the commitment number itself.  But it
creates changes to the hash enough that you're able to decrypt that justice
transaction and apply it.  So, I don't know how many people are actually using
watchtowers, so it's a question of whether this is a good feature trade-off of a
reduced privacy versus what else.  And I just don't know how this space has been
explored for next-generation Lightning stuff, like LN-Symmetry and whatnot,
whether we still need this for taproot-based channels, I don't know.  It would
be good to improve privacy if we could.  So, I just don't know whether this is
needed, but it's a legit way to identify Lightning transactions.

**Mark Erhardt**: I think that Lightning force closes by themselves due to the
scripts that are being employed are going to exhibit a similar fingerprint
already, or will be similarly fingerprintable.  So, there might not be that much
of a privacy loss.  But yeah, if we can hide it, especially if we move to
taproot-based channels where, for example, the multisignature does not appear
explicitly onchain, it might be possible to improve privacy here.

_Is a segwit-formatted transaction with all inputs of non-witness program type valid?_

All right, getting to the next one.  The next question is about the segwit
transaction format.  And the asker, Crypto L Plate, here asks about the
description of how the segwit format works, and that BIP141, which describes the
serialization format for segwit transactions, does not explicitly state that it
cannot be used for non-segwit transactions.  And the overall question is, would
it be permitted to use the segwit format for a non-segwit transaction?  This was
also answered by Pieter Wuille.  He answers that, no, BIP144 specifies that
you're not permitted to use the segwit serialization format for non-segwit
transactions.  And, did I have anything else here?  Yeah, that's pretty much the
gist of the answer here.

He goes into the details on how it's exactly constructed.  That segwit format,
of course, puts the marker in the position where the input counter would be, and
since that appears as a zero, it would make it invalid to non-segwit nodes where
non-segwit nodes should be able to read all the non-segwit transactions.  But
either way, it is forbidden by BIP144.  Cool, we are on a roll here!

_P2TR Security Question_

The next question is about the security of P2TR and how similar P2TR is to P2PK.
In P2PK, we have an output script that is mostly composed of the public key that
you're paying.  And this output script was, I think, in the first release of
Bitcoin Core, well, then just Bitcoin.  And the significant difference to many
of the other output scripts is that the output script is not hashed.  The
appearance of the public key is in the raw form, not in the public key hash
form.  And a lot of people have the understanding that if a public key is hashed
and therefore is not published to the blockchain before the transaction is
confirmed, that would be more secure against quantum attacks, which is a context
in which this question often appears.  So, it is correct that in P2TR, the raw
public key is published in the output script.

I think there is some disagreement about how much security hashing the public
key actually provides.  Yes, it does provide some long-term security.  If you're
just looking at the output that has been created, you cannot attack it with a
quantum attack.  But once the transaction that spends the output is published,
and it might still take some time until that transaction gets confirmed, the
public key becomes available and a short-term attack can be applied that attacks
the public key.  So, in a way, it's a bit of a mirage, this additional security,
because the fundamental problem is not resolved.

Another sense that P2TR is different from P2PK is under the hood, it has the
script tree, which allows you to use a P2SH-like construction, where you reveal
a leaf script that can have more complex spending conditions.  And so, P2TR of
course combines this public key and the key path spending method and the
scriptpath spending method.  And finally, this was not mentioned by the answer
of Pieter Wuille on this question, but P2TR actually has an address standard,
which P2PK does not.  Did I miss anything?  Do you have something to add?

**Dave Harding**: No, that's all good.

_What exactly is being done today to make Bitcoin quantum-safe?_

**Mark Erhardt**: All right, then I'll just continue here monologuing!  Yeah,
actually good lead over with the quantum stuff, because our next question is,
"What exactly is being done today to make Bitcoin 'quantum-safe'?", the user,
kjo, asks, and cites breakthroughs in quantum and the recent publishing of
several quantum-safe algorithms.  So, they feel like there seems to be impending
doom regarding quantum attacks on Bitcoin and wanted to know what anyone is
doing to prevent this.  So, unfortunately, there's no leadership tasked with
fixing quantum attacks against Bitcoin.  However, there seem to be more people
interested in the topic lately.

There is, for example, work on BIP360, which is titled, "Pay to Quantum
Resistant Hash", and proposes an output type that would be quantum-resistant.
And there's been also some discussions, I think, on mailing lists and Delving
that had various thoughts on that.  People have been following the publication
of the Post-Quantum Crypto by NIST, of course.  And then also, there is a big
question on how pressing exactly the quantum attack is.  Some people feel that
it is right around the corner; others feel that it might still be decades before
it is actually powerful enough to attack Bitcoin.

There's also the problem that if Bitcoin becomes attackable because of quantum
computers, pretty much all of the other cryptography that is used anywhere in
the internet becomes attackable, and there might be other juicy targets like
banking infrastructure or secure communications, and so forth.  So, yeah, I
think this is still a developing topic.

**Dave Harding**: Yeah, basically there's just a lot of trade-offs here that we
as a community need to consider before we take any course of action.  It's not
just a strict upgrade in security, it also comes with some pretty real costs,
also in other security parameters.  So, I'm really happy that people are working
on this, people who are excited about it, and people who want to learn about
quantum stuff.  I'm hoping they come up with an answer without me ever having to
learn anything.

**Mark Erhardt**: Well said, well said!  Yeah, I think it could actually use a
little more eyes.  So, as the BIP editor, I have been reviewing BIP360, and I
would say that people that are concerned about quantum, especially if they have
read more about it than myself, I think the proposal could use a few more eyes.
I've commented on the BIP myself that I feel that the approach could use more
feedback by people that actually know what they are doing in regard to quantum.
So, if you are interested in the topic, check out BIP360.  It is currently a PR
to the BIPS repository.

_What are the harmful effects of a shorter inter-block time?_

Moving on to the next question on Stack Exchange.  It is titled, "Minimal
requirements for the proof of work".  The user, SBF, asks essentially, "What are
the harmful effects of a shorter inter-block time?"  And, again, Pieter Wuille,
who answers a lot of the questions on Stack Exchange, goes into details here,
and he surfaces that the main issue is, we use blocks to synchronize the state
of nodes across the network.  However, propagating blocks takes some time, and
the latency between nodes propagating the blocks and receiving them leads to a
slight advantage of whoever finds the block.  So, if you are a large miner and
you frequently find blocks, if there is a very short inter-block interval, you
have a larger advantage because you immediately know about the new block,
whereas other miners will require some time to learn about the new block and
will start mining on the new block with that delay, first the propagation and
then also the validation of the block.

So, currently we have a targeted block time of 600 seconds.  Block propagation
takes maybe a couple seconds or so, maybe 4 seconds for most well-connected
nodes to receive a new block.  So, a very small count of seconds versus 600
seconds is a very small advantage for miners that find blocks.  If this were a
significantly shorter time period between blocks, the proportion of lead time
that successful miner finds versus the people that first have to learn about the
block and validate it would be much bigger, and that would be especially
advantageous for larger miners.  It would also make selfish mining attacks more
feasible, require less mining power to successfully selfish mine.  So, that's
why we have a 600-second block-time target.

**Dave Harding**: I think one of the interesting things there is that Satoshi
seemed to have picked a pretty decent value.  Obviously, he had no experience of
the current production network, he didn't know anything about compact block
relay, he just guessed, you know.  I mean, he probably did some experiments.  We
saw there's some early code from him where he used different values and he can
run the math on the Poisson distribution and stuff himself, but he guessed.  And
it looks like his guess is pretty good.  It's not so long that you have to wait
forever for confirmation when something's urgent, but it's not so short that we
have too much problems from it.  So, thank you, Satoshi, for making a good
guess.

_Could proof-of-work be used to replace policy rules?_

**Mark Erhardt**: Yeah, exactly.  We have a few more of these.  So, the next one
is, "Could proof-of-work be used to replace policy rules?"  The user, Jgmontoya,
asks, if you wanted to allow non-standard transactions, transactions that
currently wouldn't propagate on the network, could you, for example, require
that these transactions include some PoW somewhere in the transaction, and then
allow transactions that pay with this PoW to be relayed even if they are
non-standard?  This question was answered by Antoine Poinsot, and he mentions
that mempool policy on the one hand prevents unknown parties from wasting node
resources, which is something that could be hampered by requiring PoW on those
transactions.

But there's also other reasons for mempool policy, and Antoine cites especially
these following three: (1) Providing miners with an efficient way of building
the maximum-profit block template.  So, mempool policy is in some ways helpful
to make it easy for miners to create good block templates, especially small, or
not that small, but limiting the weight of transactions helps with that because
bigger transactions increase the part of the block that has a tail effect, in
which you would have to use a linear programming approach or other complex
solutions to find a really good block.  Smaller transactions make it much easier
to build an almost optimal block template.  (2) He also mentions that mempool
policy is used to deliberately discourage some types of transactions.  He
proposes that some transactions have large negative externalities, like storing
data in the blockchain was curbed in 2013 by introducing the OP_RETURN output
type to prevent people from using extremely large, bare multisig outputs instead
to write data to the blockchain, which would never leave the UTXO set.  At
least, OP_RETURNS are not stored in the UTXO set.  And there's some links to
more discussion here.

(3) Finally, Antoine talks about upgrade hooks for soft forks.  We deliberately
leave some patterns in transactions carved out to be able to introduce future
output types.  And mempool policy declaring them non-standard helps us prevent
that they're significantly used before they are used to usher in another soft
fork or output type.  All of these cases, the three that we discussed, would not
be served with allowing nonstandard transactions just because they have some
PoW.

_How does MuSig work in real Bitcoin scenarios?_

All right, the next one is really big and it's a very broad topic.  The question
is titled, "How does MuSig work in real Bitcoin scenarios?"  And it collects
several questions on communication and steps.  The question was later answered
by Pieter Wuille in an extremely long answer, so I'm not going to go into all of
the details here.  But first, there was maybe a misunderstanding.  The question
seems to be about MuSig1, but MuSig1 is not in use.  It was actually shown to be
broken and was replaced by MuSig2, of course, as probably many of you are aware.
And so, Pieter goes into all sorts of details here on how MuSig2 is used, how it
was designed, and how it changed from MuSig1 to MuSig2.  And I would encourage
you to read the post yourself if you want to hear the details.

**Dave Harding**: I would just quickly note that I believe the original MuSig
was broken, but MuSig1 does work.  I didn't read Pieter's answer, but that's my
understanding, is that MuSig1 is functional but requires a lot more interaction
than MuSig2.  And then, we have the other protocols in the MuSig family like
MuSig-DN that are also applicable in certain situations.  I just wanted to
clarify that, possibly clarify that.

**Mark Erhardt**: Okay, I believe you.  I think I may have misrepresented that,
but there was some part of MuSig, maybe an attempt of making MuSig2 a two-round
scheme or something, that was actually published and turned out to not work.

**Dave Harding**: Yeah, correct.  The original MuSig was broken, if you use it
in a certain context.  MuSig1, an updated paper, fixes that.  It's like, we can
call the original MuSig0, so the original version was broken.  There was an
updated paper, which is what we now call MuSig1, that does work, but it requires
more interactivity.  MuSig2 is a reduced-interactivity version of that.

_How does the -blocksxor switch that obfuscates the blocks.dat files work?_

**Mark Erhardt**: Thank you for keeping me honest.  I think I had forgotten
about MuSig0 in that sense.  All right, we're getting to, "How does new
-blocksxor switch that obfuscates LevelDBs blocks.dat files work".  Let me try
to restate that question.  There is a new startup option, which is -blocksxor,
and -blocksxor, what it does is it salts the blocks files, which store the chain
history in the Bitcoin Core node.  Even if you don't keep all of it, you will
have some of these, because you do at least keep two days of blockchain.  And
so, this person noticed that when -- sorry, I'm mixing that up with another
question that I read on Stack Exchange recently.

Okay, so what happens here is each full node rolls a new random XOR, and they
just use this key that they also store in the directory to add that sequentially
or repetitively to the block data, in order to store it in a different byte
representation than it would be stored in the raw form, because the Bitcoin
blockchain actually has some malware signatures, and also some anti-virus
software has been configured to generally block Bitcoin stuff, because sometimes
Bitcoin or other crypto miners are being installed to mine on computers without
the user's knowledge.  So, what Bitcoin Core does here is they store the block
data in an obfuscated way so that it looks different to the scanners, and it is
transparent to your own node.  When you read the data, it just reapplies the
same mask in order to read off the block data, but it causes every single node
to have a different sequence of bytes on their computer.

_How does the related key attack on Schnorr signatures work?_

All right, just three more.  "How does the related key attack on Schnorr
signatures work in real life?  Oh, sorry, this is actually the last one.  That
one actually doesn't even have an answer on Stack Exchange; it has a bunch of
comments, mostly by Pieter Wuille.  The problem that is being asked about here
is, if you have a private key and then you generate another private key by a
known relationship, for example, by doubling the private key or like multiplying
it with itself or things like that, well, actually that might not work, but
doubling it or offsetting it by 100, or something like that, if the attacker
knows about the relationship, they can treat these two keys as quasi the same.
And if the same key is used twice to sign the same message, in some contexts you
can calculate the key.  This attack only works if you actually know the
relationship as the attacker, or if you can guess it because it's a very simple
relationship.  And, well, if you know the answer to this question, or if you
want to go over Pieter Wuille's comments and write one, this one doesn't have an
answer yet!

_LDK v0.1.1_

Okay, after my soliloquy here, we are now jumping into the Releases and release
candidates section.  We have already talked a bunch about LDK v0.1.1.  As Matt
Morehouse earlier stated, this is a security release.  And there are the two
attacks that we talked about that older versions are vulnerable to, or one of
them only applies to the previous version, so we would encourage you to start
your update procedure, test it of course, and review the changes, and then
probably you want to move to update on this one fairly quickly.  Actually, I'm
looking at the release notes right here.  There's a couple of API updates, but
mostly it's bug fixes and security.  So, as usual, if you're upgrading, take a
good look at the release notes, especially if you're handling other people's
money.

**Dave Harding**: Yeah, so I'm just going to quickly repeat what it says in the
newsletter, which is that there's a vulnerability in this one where an attacker
can get you to force close all of your channels, every single one of them, by
them choosing to sacrifice 1% of one channel's funds.  So, the attacker has a
channel with you and they're willing to sacrifice 1% of their funds in that
channel.  They can get you to force close every other one of your channels.  So,
if you're a big service provider that's using LDK, this is a big problem for
you.  If you're just a regular local user and you only have one channel or maybe
two channels, probably not a big deal for you.  But it's always good to update
these security releases after, like Murch said, you've checked them out and made
sure you're comfortable with that.

Thanks, Dave.  We're coming to the last section of this newsletter, Notable code
and documentation Changes.  We have six of them this week, and Dave is going to
take you through them.

_Bitcoin Core #31376_

**Dave Harding**: Yes, I am.  Okay, we're going to start off with Bitcoin Core
#31376.  This is just a little background change to the RPC getblocktemplate
that prevents returning data that could cause miners to create blocks that would
use the timewarp bug.  This extra bit of code has already been applied when you
run a getblocktemplate on testnet4 to prevent miners from exploiting the bug
there, because testnet4 has a fix for the timewarp bug.  So, if you do this as a
miner, you will lose fake testnet coins.  This check, this extra code is now
applied to mainnet, so you won't create timewarp blocks on mainnet.  Now,
there's nothing stopping you on mainnet right now, but in the future, when we
have a timewarp fix on mainnet, this extra code will make sure you don't lose
the much more valuable coinbase fees.  So, it's a good thing to get that out
there now, just in case anybody doesn't upgrade a year or two from now when we
fix the timewarp bug, hopefully.

_Bitcoin Core #31583_

Next one, Bitcoin Core #31583.  This updates a bunch of mining-related RPCs to
return an nBits field, which is the representation of the block difficulty
target that you need.  You need to include the nBits in your block headers and
you need to know what it is so that you know when you've created enough PoW.
This is mainly part of the implementation of Stratum v2 in Bitcoin Core.  It's
useful in a lot of contexts, but it's something you need to know if you're going
to be a local miner, creating blocks as part of a pool and then potentially
broadcasting those blocks yourself.  You just want to have this information and
it's available, it's easy, everybody should have it, it doesn't cost anything to
put it in an RPC.  So, it's a nice API change.

_Bitcoin Core #31590_

Moving on, Bitcoin Core #31590.  This one is kind of interesting.  When you're
working with a descriptor, you're working with private keys in a descriptor for
taproot, those private keys can actually resolve to two different public keys in
theory, but only one of them is actually valid in taproot, because taproot has
what we call x-only pubkeys, and we use an algorithm to decide which one of
those two public keys we actually want to use.  And previously, if you had a
descriptor that had the wrong one in it, I'm not quite sure how that would have
happened, but if somehow you did that, the code now will fix it for you.  It
will find the right one and use the correct one, because only one of them is
consensus-valid.  So, it can do that for you.  So, that's a nice improvement.  I
wanted to make sure that was included in the newsletter, because maybe it's
something that other software should be doing too, making this automatic change.
Again, I'm not sure how you would get into that situation in the first place.
Go ahead, Murch.

**Mark Erhardt**: Maybe if you didn't start the parity bit at all and then made
a guess when you're trying to import it, you could have the wrong one, but
that's the only thing I can think of right now.

_Eclair #2982_

**Dave Harding**: Yeah.  Okay, so moving on, we're on to Eclair #2982.  So, when
you're working with dual-funded channels in Eclair and liquidity advertisements,
so you're advertising liquidity, Murch can come and say, "Oh, Dave, I would love
to buy your liquidity.  And here's my UTXO that I'm going to use to buy your
liquidity".  So, I say, "Okay, great, you're willing to buy", and I lock the
UTXO that I plan to use in that transaction for providing liquidity to Murch.
And then, Murch never follows through, he never signs his half of the
transaction.  Now, I would lock that UTXO, because I don't want to accidentally
create another transaction with somebody else and sell the same liquidity twice,
which would piss off Murch and lose me a valuable customer.  So, I would lock
that.  But if Murch doesn't follow through, I don't get paid at all.  So,
there's kind of this this griefing attack and it's a trade-off.  Do you want to
allow random people on the internet to prevent you from using your UTXOs in
funding transactions that will get you paid; or do you want to maybe create
conflicting funding transactions that are going to cause some of your customers
to have to recontact you and go through all these steps again?

There's no direct money loss here from this griefing attack, it's just kind of
time-value-of-money stuff.  But there's a trade-off here.  So, Eclair has added
a configuration setting to allow you to choose which side of the trade-off you
want.  And the default here is that they'll allow the griefing attack.  So,
they'll lock the UTXO by default so it doesn't get used more than once in a
funding transaction for a period of time, like six blocks or something.  So,
anyway, trade-off, configuration setting.  I think it makes sense.  Go ahead,
Murch.

**Mark Erhardt**: You also, or Gustavo also wrote that there is a configurable
timeout mechanism now, so you reference this with the six blocks.  So, it sounds
to me like it just gives you more tools to handle the situation in the first
place.  You could, for example, if you don't really suffer from this attack, use
the default setting, which means that you honor reservations and let random
people on the internet lay claim to your UTXOs, but then they timeout after a
while and become available again.  If they timeout a lot and you find that
people are not following through on their reservations, you could either lower
the timeout, or eventually turn it to false, because clearly someone is
liquidity-griefing you.  And so, I think from my read, which is very superficial
because I'm just reading it now, you get the tools here to deal with the attack
in case it occurs, but you're basically operating under this assumption by
default that you're not being attacked.

**Dave Harding**: Right, yeah, I think the timeout mechanism is good if it's an
accident.  So, if Murch really did intend to buy my liquidity, but for some
reason his node went offline before he can complete the transaction, the timeout
will restore that UTXO for use for the next customer in a few blocks.  If
somebody is trying to seriously attack you, they're going to have to do a lot of
work because there are thousands of LN nodes out there.  It costs basically
nothing to initiate buying liquidity, because they can't, there's just no
fundamental way to do that.  So, it's very easy, it's very cheap to have this
attack, but the configure timeout helps in the occasional accidental case.

_BDK #1614_

Okay, moving on to BDK #1614.  This adds support for using compact block
filters.  And BDK has multiple chain backends that it can support.  It can
support a full node, it can support an Electrum/Ledger server, and this gives it
support for compact block filters as its backing store for figuring out the
confirmation state of transactions.

_BOLTs #1110_

And then our final one is BOLTs #1110, and this merges the specification for the
peer storage protocol, which has already been implemented in CLN and Eclair.
That allows nodes to store up to 64 bytes on their peers and to potentially
charge for this service.  So, it's really good for storing your Lightning
backups.  So, every time the channel state changes, you encrypt your essential
backup information and you give it to your peer.  And then, when you reconnect,
you download that blob, and you decrypt it and you see what it says.  This
current version does not include any enforcement that your peer has the latest
blob that you have.  But in a previous newsletter, we did discuss a smart
contract that would allow that to happen.  And the simple mechanism is, you just
periodically request the latest blob from your peer and you see if they've
returned the latest one.  And if they don't, they return an older one, you
disconnect from them and you force close the channel and you say, "I'm never
going to do business with you again".

So, I think this is actually a really useful thing for light clients and maybe
even full clients to be able to just store their backups with their peers.  With
64 kB and typical Lightning settings, you can store your backups for multiple
peers with a peer.  So, let's say you have five channels, you store all of your
backups for all five channels with each of your peers, and you only require one
of them to be honest when you reconnect and provide you with the latest backup.
Did you have a question, Murch?

**Mark Erhardt**: Yeah, this came up at our last BitDevs, and what I gleaned
from the conversation around this PR was, it is a best-effort protocol, there is
no guarantees.  If you're, for example, sybilled, and you're relying on your
peers that are all the same Sybil to store your backup and they just are trying
to harm you, you might be out of your backup.  So, don't use this as your only
backup mechanism.  Keep a backup, especially of the channel state, somewhere
else.  It also doesn't appear to be feasible to have backups of like the
state-by-state updates.  It's more just the static channel backup sort of data,
which is like the channel topology and the information to get back channel
balances.  HTLCs that are in flight would still, in this case, be up for grabs,
or unless the counterparty properly closes it.  Well, it would basically give
you a map of who to tell that they should please close the channels unilaterally
with the latest state if they were so kind.

But yeah, you don't have the revocation transactions, you don't have guarantees
that that would be the last states, you just sort of know where your channels
were and how you would spend the balances that come back from the channel
capacity, not the HTLCs.  I think that's all we have for you today.  Thank you
for tuning in, and we'll hear you soon.

{% include references.md %}
