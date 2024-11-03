---
title: 'Bitcoin Optech Newsletter #315 Recap Podcast'
permalink: /en/podcast/2024/08/13/
reference: /en/newsletters/2024/08/09/
name: 2024-08-13-recap
slug: 2024-08-13-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Matt Corallo, Greg Sanders, Sivaram Dhakshinamoorthy to discuss [Newsletter #315]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-7-13/384719950-44100-2-6094d12a5886e.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #315 Recap on
Twitter Spaces.  Today we're going to talk about Dark Skippy, block withholding
attacks, some statistics about rates of successful compact block reconstruction,
pay-to-anchors and potential replacement cycling vulnerabilities, a BIP draft
for FROST threshold signing, some updates to Elftrace, adding ability to verify
zero-knowledge proofs; and then we have our usual weekly topics on releases and
notable code changes.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Matt?

**Matt Corallo**: Hey, I'm Matt, funded by Block, but do Bitcoin stuff.  I've
done Bitcoin stuff for too long.

**Mike Schmidt**: Greg?

**Greg Sanders**: Hi, I'm in the same place as Matt with Spiral.

**Mike Schmidt**: Sivaram?

**Sivaram Dhakshinamoorthy**: Hi, I'm a Spiral new grantee working on
FROST-related projects and libsecp.  I recently shared a BIP draft for FROST
signing on the mailing list.

**Mike Schmidt**: Thank you all special guests for joining us.  We have quite a
few news items this week, and it's great to have you all help opine with your
expertise on all of these.  We'll be following largely sequentially in the
newsletter, so bring up #315 if you don't have it up in front of you.

_Faster seed exfiltration attack_

Starting with the News section, the first item titled, "Faster seed exfiltration
attack".  The attack is named Dark Skippy and there's a lot of chatter on social
media about it right now.  BlueMatt was able to join us to give his summary and
perspective on the attack and maybe how it works, and the implications of it.
Matt, you want to take it from there?

**Matt Corallo**: Sure.  Yeah, I didn't work on this attack, I can only opine on
it, but it was pretty clever.  So, we've known forever that you can -- so, the
nonce in a signature, in an ECDSA signature, you can exfiltrate data, right, and
potentially link the private key.  So if you, for example, sign with weak
entropy in the nonce, then almost anyone can probably work back to the private
key that was used to generate the signature itself.  So, this is why a lot of
wallets do deterministic nonces, they use hash functions of the private key and
the message rather than using random data.  This is too easy to screw up your
randomness and leak your private key.  But this specific attack takes it a
little further.  Instead of just trying to leak the private key that signed the
message, it leaks your whole seed.

So if you have, for example, a hardware wallet, they demonstrated it on a
specific hardware wallet, but any hardware wallet could do the same thing,
basically.  If you have a hardware wallet and it wants to leak your secret to
some attacker, say someone who's backdoored the hardware wallet, backdoored the
firmware on the hardware wallet, or something like that, they can use this
attack to leak not just the private key that's finding the transaction, so the
specific input's private key, but your entire wallet seed.  And then the
attacker can use that to go claim all of your money, not just the money that
maybe was being spent in this transaction.  So, this is a novel attack, it's
cool, but we've known about the class of attacks for a long time, forever, since
before Bitcoin, and we've had mitigations for the class of attacks for many
years.

Two hardware wallets, I believe, have implemented it, only two sadly, so that's
BitBox and Jade.  I think Jade only does it if you are using the thing plugged
in via USB, so it doesn't do it in the offline mode or in the air-gapped mode.
But I think BitBox maybe always does it, I'm not quite sure.  But those
mitigations that are protected against the class of attacks still work, they
work here fine, and yeah, so that's the summary.  I think I caused a little bit
of a dust-up on Twitter because I kind of strongly hold the view that hardware
wallets that have not bothered to implement mitigations against entire classes
of attacks that we're aware of are incompetent and shouldn't be used.  But maybe
I should say how the mitigations work just really briefly.

The mitigations seek to improve the trust model of a hardware wallet.  So, this
class of attack plus generating a bad seed, or whatever, means that you have to
fully trust the hardware wallet, that the hardware wallet itself can, if it's
backdoored in any way, it can steal all your money or leak all of your private
keys or send all your private keys somehow to an attacker.  The mitigations that
we're talking about, for specifically the signatures here for the nonces, but
there's also other mitigations for nonces, for seed generation, make it so that
an attacker has to compromise both the machine driving the hardware wallet and
the hardware wallet itself.  So, with BitBox02 and with Jade, assuming it's
plugged in, you have to compromise both the software running on the laptop, or
whatever you have, and backdoor the hardware wallet, which is obviously a
substantially different attack in terms of has to be much more targeted, or you
have to get the software wallet that people are using and the firmware.  But
it's, instead of having to compromise one thing, you have to compromise two
things, which makes it a substantially more complicated attack.

**Mark Erhardt**: Yeah, I had a question, two questions actually.  First
question, do you happen to know whether this leaking of the seed will make it
public information, or does it send it directly to an attacker?

**Matt Corallo**: So, the way the way they designed it, it sends it to the
attacker.  So, you grind a little bit so that the attacker can identify that
this is with some kind of pre-shared secret between the attacker and the victim,
or the victim's firmware.  But you could do it either way.  You could implement
it to send everybody in the world your seed, but you could also do it so that
just the attacker, just the person trying to steal your money, gets the seed.

**Mark Erhardt**: Cool.  And you said that both devices have to be compromised.
Does this happen via a nonce commitment, or what is the implementation?

**Matt Corallo**: Yeah, both devices have to be compromised in the mitigation.
So, the goal that you really want is you want that both devices add some kind of
randomness to the nonce.  Now, the protocol for actually doing this for nonces
is not super-trivial at all.  If you go on Bitcoin-Dev, there's an old thread
from 2020 from Pieter that describes a number of different schemes to mitigate
this, and then kind of concludes which one you should use.  I forget exactly
what that thread is called, but you should be able to find it.  But yeah, it
tries to use randomness from the computer in the nonce generation, and then also
proves to the computer that that randomness was used.  For seed generation,
which is the other half of the types of attacks where the hardware wallet itself
could steal your money, it's much more trivial.  You just need to add randomness
from the computer, and then you can trivially prove that that was used for the
root key generation.

**Mark Erhardt**: Okay, cool.  Final question.  Some of the pushback you got
after your dust-up was, "Well, this attack doesn't work if people verify that
the device is using actual firmware".  Well, the actual firmware could also be
compromised, but do you have other comments on that?

**Matt Corallo**: Yeah.  I mean, I think that there's a lot of specific
discussion around like, "Well, is this style of the attack more likely, or this
one, or whatever?"  But I think it's not super-complicated.  I mean, we have a
protocol by which we can fundamentally change the security model of hardware
wallets for the better, and people don't do it, right?  So, whether the device
is compromised because, you know, many people buy hardware wallets on Amazon,
maybe they know they shouldn't, but they do anyway, and it came with bad
firmware; maybe they bought a hardware wallet and then didn't pay any attention
and it got bad firmware upgraded to it; maybe someone did a software-dependency
attack in one of the dependencies on a hardware wallet's firmware.  Whatever it
is, there's a ton of different attacks that might happen and different ones are
more or less realistic, but they could happen.  And if you take that from
something that is, in my opinion, fairly doable, to something that you have to
also then compromise something else on top of that, that's a very substantially
large difference in trust model.  So, my view is hardware wallets should be
doing that.

It's worth pointing out the one exception to this rule of hardware wallet should
be doing this, and I think hardware wallets that haven't done this are just kind
of lazy, is it you can always do multisig, right?  So, you can always do
multisig between the computer and the hardware wallet.  This accomplishes the
same goal.  I think someone from Ledger had given a talk not too long ago
basically saying like, "Yeah, doing all these more complicated protocols is
hard, so we're not going to bother, but we are going to do multisig, so we're
going to achieve the same security model upgrade, and we're just going to do it
with multisig, and it'll be easy, and we'll do it".  I guess they wanted to do
it with MuSig2, so with taproot.  So, that works too, you know, Casa, all the
different multisig schemes also accomplish the same kind of security model
improvement, but most hardware wallets, most hardware wallet and software wallet
stacks do not do this, and that's just really, really embarrassing for the
security level of the Bitcoin community, in my view.

**Mark Erhardt**: Okay, Mike, sorry, to you.

**Mike Schmidt**: Yeah, we have Rearden Code, who has joined us to discuss this
and/or other topics.  Do you have a question or comment?

**Brandon Black**: Yeah, I mean I think this was a great dust-up, Matt.  I
enjoyed talking with you about it on the feed there.  I wanted to just point out
one important thing about this.  While this is a threat model that we could
eliminate by doing these protocols, it's not obvious that it should be a
priority.  Like you said, hardware walls that haven't done this are lazy, and I
don't think that's a fair characterization.  Yes, this is a threat that can be
mitigated; yes, I think eventually it should be mitigated.  However, if we're
talking about the subcategory of users who get their hardware devices from an
untrusted pathway, whether that's from Amazon or buying it in person from
someone they don't know at a conference, or whatever other way they might get
it, those people we probably can't protect by doing nonce anti-klepto or by
doing mixing for seeds, or things like that.  The best advice we can give to
those people is buy your device from a reputable source, and that will be the
best protection they can get.  So, I think I'm not sure that this is a priority
threat to close, I guess.

**Matt Corallo**: Well, I mean you said we can't protect those people.  We
actually would.  If it were the case that somebody was being lazy, whatever,
they bought the device from Amazon, kind of bad, but whatever, and then they
actually did follow the instructions and verified the software download on their
computer, which maybe they did; maybe they bought it, but it happened to be
compromised, but then they did follow the instructions on the computer and they
got an honest version, or maybe the attacker didn't manage to hack the website
for the software wallet, or whatever, then they wouldn't lose their money.  You
do these things and now the hardware wallet wouldn't be able to unilaterally
steal the money that would actually protect these people.

I think more broadly that the Bitcoin hardware wallet industry has kind of stuck
its head in the sand and pretended that it isn't now a trillion-dollar asset,
and has security built for people storing maybe $100,000 or $1 million in
Bitcoin, and have not built out the kind of security level that you need to
store $10 million or $100 million in Bitcoin.  And I know there are definitely
people who have or $10 million or $100 million in Bitcoin hardware wallets.  Now
hopefully, most of those are funds, not individuals, but organizations, and
hopefully most of those are doing multisigs, or they're protected against some
of these kinds of attacks.

But these things do exist, and I think we've seen very organized attacks against
secure hardware, against hardware and shipping and transit, against all kinds of
things, for criminals to make tens or hundreds of millions of dollars, and it is
absolutely the case that hardware wallets should be thinking about these kinds
of attacks.  Because we've seen that criminals will take these kinds of actions,
like backdoor hardware, physically, while it's being shipped between the
manufacturer, or between the factory that manufactured it and the company that
it's being manufactured for, in order to steal $10 million or $100 million
dollars, in fact sometimes in order to steal less.  And now, hardware wallets
are a target of that volume, of that threshold, so they should be taking that
seriously, and they're not, again with the exception of hardware wallets
targeting different markets or hardware wallets that are being used exclusively
in multisig.

**Brandon Black**: I mean, I know where you're coming from here.  There's still
a fundamental issue, which is that we're trying to protect people from a
specific class of attack, which is that their hardware has been compromised and
is now out to get them.  And those people can already protect themselves by
buying a BitBox or a Coldcard or a Ledger from a reputable vendor, confirming
the packaging, confirming the firmware download.  There's a bunch of stuff that
those people can already do if they're responsible, knowledgeable users.  And of
course, the devices do their best to protect them as well by doing cryptographic
checks against the firmware before it can be installed.  So, this makes the
level of attack needed to go up to a hardware modification not just a software
modification in order to get a bad firmware on there.

So, users who want to protect themselves and have the ability to buy a device
from a reputable source already do; and users that aren't going to do that and
buy the devices from Amazon probably can also be compromised in other ways.  So,
that's why this is not a priority.  I know we're taking up a lot of time but I
want to shill, for people who want to learn more, check out the bitcoin.review
podcast; they cover this for like two hours straight.  And also check out my
Spaces from last week where we covered it for about a half an hour.  So, there's
lots more on this topic.

**Matt Corallo**: Yeah, I find that view to be somewhat naïve, frankly, because
users, maybe they're lazy, but having to compromise two separate things isn't
two orders of magnitude harder, right, it's not just twice as hard.  It changes
the attack very, very substantially.  So, while someone might be able to
backdoor some hardware wallets, manufacture identical-looking hardware wallets
and sell them on the market, that's not actually that hard.  It's some amount of
work, it's some investment, it's not that hard.  Actually then going and hacking
like the website for Cake Wallet, or whatever, on top of that and then happening
to get, or maybe making a phishing site that has the same binary, or has some
malicious binaries, but then happening to get users who bought your bad hardware
wallet and hit your phishing site and download the malicious wallet, is an order
of magnitude more work and you're going to get an order of magnitude or two less
revenue from this attack.  So, I think suggesting that this is low priority or
that users can defend themselves is just kind of naïve.

**Brandon Black**: If I may, I'll say one last word, which is just that if the
user buys the device from Amazon, they're going to plug it into their computer
and that device can easily have a modified USB chip that directs their computer
straight to a download site that's the malicious site, and 99% of users that buy
from Amazon will just download that software.

**Matt Corallo**: I'll let us move on to another topic.

**Mike Schmidt**: Yeah, I think that's a good idea.  We have quite a few news
items this week.  Matt, I think you can help us out with this next one as well.
Rearden Code, you're welcome to stay on and opine on some of these other topics
as well.

_Block withholding attacks and potential solutions_

Next news item was titled, "Block withholding attacks and potential solutions".
AJ spurned this news item by posting to the mailing list.  Topics he mentioned
in his post were block withholding attack, a related invalid shares attack, and
then potential solutions to both attacks.  We weren't able to get AJ on but,
Matt, my understanding is that you can speak to this topic.

**Matt Corallo**: Yeah, to some extent.  I mean, so AJ, yeah, his email was
mostly just about kind of the concept of block withholding and what to do about
it.  He mentioned this style of block withholding where you are using Stratum v2
or something like that, you create invalid work or P2Pool or Braidpool, or
whatever, you create invalid work and you mine on that.  This is, from the
pool's perspective, identical to block withholding and in fact a little easier
to identify.  So, I think both Luke and I responded that this is not a
particularly interesting sum variant of block withholding.  It doesn't change
anything, it's not specific to Stratum v2, or whatever, it's really just a kind
of shitty way to do block withholding attacks.  And a miner, or anything that a
pool can do to analyze block withholding, to detect block withholding, can
probably be done somewhat similarly on someone doing invalid shares.  Even if
you don't verify the shares at all, you can still identify the same kind of
statistical analysis.

Pools do do statistical analysis on block withholding.  AJ kind of raises the
point of, "Well, KYC pool is kind of required, you know, so some pools do KYC,
not all".  I mean, you can still do some level of analysis to detect miners who
are doing block withholding in a naïve way.  Someone doing super-advanced block
withholding, where they've really invested in a whole fleet of proxies and a ton
of user accounts generated from different IPs in different areas, and whatnot,
just to do block withholding would be harder to detect, and AJ suggests some
attempts to make that a little harder to see.  There's also just, everything is
kind of statistical, right?  Everything on block withholding is somewhat
statistical.

There are old papers on making block withholding impossible.  It would be a hard
fork, but basically the idea would be to change it such that anyone who is
mining a block can always take the coins, which would basically just make pool
mining completely impossible, because a miner could always take the coins from
the pool, rather than the pool being able to pull a reward.  And, yeah, I mean I
think in practice, pools worry about this, but have invested a bunch in
statistical detection and seem to mostly do fine with it, even without KYC.  So,
I guess I'm not too worried about it.  Yeah, I don't know if anyone else read
the full email and had more thoughts on some of the more specific block
withholding protections that were highlighted.

**Brandon Black**: I have a question.  With the variant that AJ is talking
about, aren't all mining shares invalid, right, they don't pass the PoW check?
So, in that sense, it's equivalent, right?

**Matt Corallo**: Kind of, yeah.  I was talking more from the pool's
perspective.  So, from the pool's perspective, block withholding just looks like
a miner that's mining a bunch of shares, but never mines a block.

**Brandon Black**: Right, yeah.

**Matt Corallo**: Whether that's because the block is invalid and they picked
their own work, or they just simply don't submit the shares for the blocks, is
somewhat irrelevant to the pool.  It all kind of looks the same.  And all the
statistical analysis stuff that they do works just as well.

**Mike Schmidt**: Murch, did you have anything to piggyback off of what Matt
summarized for us?  Thumbs down.  Okay, great.  Well, if there's anything that
we missed that's glaring, I'm sure AJ will let us know.  But thanks for driving
that, Matt.

_Statistics on compact block reconstruction_

Third news item this week, "Statistics on compact block reconstruction".  This
was motivated by a post by 0xB10C to Delving Bitcoin.  There's been some
discussion about the reliability of compact block reconstruction and it sounds
like a few people, I think Greg Maxwell was mentioned, 0xB10C, and I think
Libbitcoin developer, Eric Voskuil, all noticed some trends and maybe can
elaborate on what folks have seen and what the potential conclusions are from
that.

**Mark Erhardt**: Yeah, you cut out briefly there, just so you know.  But
essentially, this is the observation that ties into the mempoolfullrbf debate.
The context is, compact block relay is a method for propagating block recipes a
little more quickly on the network.  The idea is that with compact blocks, you
don't relay the full block, including all of the transactions, but rather you
just send the instructions how to bake your own block at home from short IDs and
the header.  And there's two different ways in which compact blocks are relayed.
One is the low bandwidth mode, which is basically I get the block, I validate
it, then I announce it to my peers.  They get the recipe first and only ask back
for the things that they need, and build their own block and then forward it.
And Bitcoin Core nodes will also tap some of their peers to be high-bandwidth
relay nodes.  And that means the peer will be requested to immediately forward
the block, even before validating it.  So, they just do some rudimentary checks
on the header and then they immediately forward the compact block recipe or, if
they got it on by regular means, they'll do it up to what transactions are in
the block and send you the recipe before fully validating the block.

So, the idea is that we can propagate blocks more quickly by sending these
recipes around as fast as possible.  And the expectation would be, in a healthy
ecosystem, where most nodes have seen all of the transactions that are included
in the block, or almost all of them, that somewhere around 85% to 100% of the
reconstructions go without needing to request another transaction that was added
to the block.  So, in the last year, we've seen a lot of transactions getting
added to blocks that were non-standard, compared to prior years, and we've also
seen some periods of time where block space demand was through the roof.  For
example, around the halving, we saw immense block space demand.  And what 0xB10C
measured here is that compact block relay required asking for missing
transactions significantly more often around the times when block space demand
was high, and generally had been degrading over time.  So, instead of being more
than 85%, as we would expect in a healthy node population, it slipped down to
the range of 45% to 70% of the blocks being able to be reconstructed without
getting additional transactions.

He posted statistics on the last six months or so, and one of the key
observations was, when he turned on mempoolfullrbf on one of his nodes, this one
node again got back to 88% to 90%, or something, reconstructions without
requesting additional transactions.  This ties into, as I said, the bigger
debate of mempoolfullrbf, where we have now observed that somewhere north of 95%
of the hashrate appears to be using mempoolfullrbf in building their block
templates, but a huge portion of the nodes are not using mempoolfullrbf.  So,
full-RBF replacements do not necessarily propagate to all the nodes, and all
these nodes then need to request these missing transactions when they see the
block coming in, because they haven't seen the replacement, even though almost
all miners pick them into their blocks now.

So, this is in context to a PR that we're also going to talk about later, which
is that Bitcoin Core is updating its default value.  So, in 24, Bitcoin Core
release 24, the mempoolfullrbf startup flag was introduced.  It was default
disabled back then, but now that almost all the hashrate appears to be using
mempoolfullrbf and some quorum of the node population appears to be forwarding
with mempoolfullrbf, we think it makes sense to turn it on by default, because
that is what blocks seem to be using and that will improve the overlap of what
we have in our mempool, what we expect the next block to be, with the actual
blocks that are being published.  Yeah, that's my rundown roughly.

**Mike Schmidt**: Okay, so I think we had suspected, or some people claimed,
that most miners were running full-RBF.  It seems like maybe this confirms that,
in addition to people are actually relaying transactions without signaling and
doing replacements.  So, I guess that's good ammunition for full-RBF as a
default then.  Matt?

**Matt Corallo**: I was going to ask, the compact block stack allows a node
doing high-bandwidth relay to relay an extra transaction, or five or something,
along with the compact block, with the intention being that if we start to see a
material number of non-standard or otherwise kind of "surprising" transactions
getting mined, then nodes can relay those transactions in addition and help
other peers do compact block reconstruction.  Did Bitcoin Core ever implement
the sending side of that?

**Mark Erhardt**: Unfortunately, that's still an open-to-do.  And so, if someone
is looking for a probably not good first issue, but a project to work on, this
would be an open item.

**Mike Schmidt**: Greg?

**Greg Sanders**: Yeah, I mean, I looked into this.  So, it's called the
pre-filled transactions field.  And it seems like it's a prediction problem.
So, you have to predict what other people, your peers, you have to predict what
your peers don't have, for whatever reason.  And so, I think Greg Maxwell has
recently spoken up about possibly picking up, if someone wants to look at this,
perhaps looking at using the erasure codes, or whatever those are, the
fiber-related technology, but something simpler maybe.

**Mike Schmidt**: Yeah, Matt, go.

**Matt Corallo**: I was just going to say, you could at least assume that what
was surprising to you would also be surprising to your peers.  It doesn't work
in general, but it might work in the specific cases we're talking about,
especially non-standard transactions.

**Greg Sanders**: So, one idea could be something like, "I saw this transaction
really recently, try forwarding that".  So, maybe it's time-based or something
like that.  But again, these are just guesses.

**Mark Erhardt**: Yeah, or anything you had to request yourself.  If you had to
request it yourself, you'd definitely then forward it to your peer, and your
peer didn't offer it to you, otherwise he would have had it.  We also have the
list of things that we have been offered by the peer and the things that we have
relayed to the peer.  We can also make a time-based guess.  So, yeah, there's a
bunch of different angles on this one.  And if you could just announce the last
three to five there, that might actually increase it to, well, a higher range.
But also, just turning on mempoolfullrbf will probably reduce the number of
block reconstructions in which an additional round trip is necessary.

**Mike Schmidt**: You think we're good on that item, Murch?  Next news item
titled, "Replacement cycle attack against pay-to-anchor".  And Peter Todd posted
to the Bitcoin-Dev mailing list about this potential attack, but we also have
discussion of pay-to-anchor (P2A) in our Review Club and also a PR on it.  So, I
was thinking that we could maybe cover the basics there first, sort of jumping
down to the PR Review Club, which is an overview of P2A, and then we can talk
about that.  But I do see Bob requests a speaker access.  So, Bob, perhaps you
have a question or comment about block reconstruction?

**Bob McElrath**: Yeah, first of all, this concerns me a little bit because it
creates a transaction withholding attack, where you intentionally withhold the
transaction and then cause other people to not have it, and thereby screw up
everybody else reconstructing the block.  The second thing I wanted to point out
is that there's a better solution to this, and that is if the mempool itself was
committed in some way, everybody would have the transactions, right?  The
problem is that there's no consensus on the mempool.  If there was consensus on
the mempool, this would not be a problem.  And I wanted to point to a proposal I
made on Delving Bitcoin a while ago about deterministic block construction.

So, if you had a committed mempool, you could apply any deterministic algorithm
to that set of committed transactions, and thereby not even propagate the block
transaction template because it's a deterministic, everybody can calculate it.
This is something we're planning to do in Braidpool, where we will mine Bitcoin
transactions in the Braidpool shares.  And so, there will be a committed set of
transactions and essentially a different mempool available with which we can do
deterministic block construction.

**Mike Schmidt**: Anyone have feedback on Bob's idea?

**Mark Erhardt**: Well, I'm not very knowledgeable about all that, but the
general consensus algorithm or consensus mechanism in the Bitcoin Network is of
course the block production itself.  So, having another consensus algorithm
that's on the mempool before the consensus mechanism that the network generally
uses feels a bit like a doubling up.  Now, in the context of Braidpool, where
you actually are looking to find a mechanism how you can coordinate yourself
where nobody can cheat and you work together, that makes more sense.  But I
think on the open network in general, I don't know if we would want to have
another consensus mechanism in there.

**Bob McElrath**: Well, just for reference, the consensus mechanism in Braidpool
is PoW, highest weight chain.  The only difference is that it's a direct acyclic
graph.  So, it is a merged, mined blockchain, similar to P2Pool, and yeah, it is
its own consensus mechanism.  But it is what it is.  If you want to have
everybody know what the set of transactions is, you have to have some kind of
consensus mechanism, because you just can't know what you don't know.

_Add PayToAnchor(P2A), OP_1 <0x4e73>, as standard output script for spending_

**Mike Schmidt**: Thanks for chiming in, Bob.  Greg, I sort of teed up this next
news item to you, but why don't you maybe provide us an overview.  What are P2As
and how does this relate to the discussion of ephemeral anchors that we've had
previously; and then we can maybe jump into this potential cycling attack
against it?

**Greg Sanders**: Yeah, sure.  So, in short, let's back up a little bit and say
what an anchor is.  An anchor is a way of adding exogenous fees into a
transaction that can't use, like, SIGHASH_SINGLE|ANYONECANPAY.  So, the
situation where you don't have a smart contract or a payment or some sort of
state change you want to affect, that's one input, one output.  So, it's not
like that, and you have, let's say, multiple outputs.  So, a Lightning channel
is one example.  One way of putting exogenous fees into this to pay for it to go
on-chain is to use something called an anchor, which is an output that's meant
to be spent immediately, and that spending, so this chain of two transactions,
has a child transaction, and this child transaction is the one that's bringing
the fees into this equation to get it confirmed.  So, that's Anchors.

P2A is an optimization on the case where you don't care who brings the fee
bumping, you just want it to happen.  So, as an example, today's LN anchors has
an immediately spendable path using a specific public key, so to spend that you
have to make the output, which is a certain size, a commitment to this public
key, and then you spend it using a signature and all the associated overhead.
P2A is just an optimization on that where it's a fairly small output, so it's a
significantly smaller output, and then there's also no signature attached at
all.  So, someone makes a claim that they're going to fee bump it, but they
don't need to spend virtual bytes to make signatures for it, just the child
transaction with the input spending that output.  I'll stop right here and let
you ask any questions.

**Mike Schmidt**: Yeah, we covered P2A, the PR Review Club that happened, I
think it was last week, where I guess the implementation of this in Bitcoin Core
that we then cover in the Notable code segment.  So, this is no longer
theoretical, this is something that is real that folks can use.  What's the
status of the rollout of support?

**Greg Sanders**: Sure, so starting with 28.0 and following releases, your node
will relay spends of this type.  So, the output itself is already standard to
make, there's some transactions that have already been mined that create a few
of these outputs.  And starting in 28.0, you'll be able to spend these as well.
So, that's kind of the key difference here.  So, they were already standard to
make, and now they're standard to spend.

_Replacement cycle attack against pay-to-anchor_

**Mike Schmidt**: Excellent.  Maybe we can touch on now, unless there's any
other comments, the high-level P2A discussion.  What is Peter Todd getting at
with a replacement cycle attack against P2As?

**Greg Sanders**: Right.  So, I think this dovetails with what I was mentioning
earlier, that this is a method of exogenous fees in a smart contract.  And
replacement cycling is fundamentally something you can do against anything that,
let's say you have a smart contract and you're pre-signing a transaction of any
type.  If you're allowing exogenous fees, then replacement cycling is currently
a thing you can do against it.  So, if you do, for example,
SIGHASH_SINGLE|ANYONECANPAY on a HTLC (Hash Time Locked Contract) pre-signed
transaction, which is what's being done today for the LN, a replacement cycling
can be done against it.  And if you have a transaction with an anchor, a keyed
anchor, then your adversary who has the key can replacement cycle-out the child
transaction as well.  Because if you're allowed to bring in a fee input, you're
allowed to conflict with that fee input with a double spend, right?  So, that's
fundamentally the issue at stake here.

So, it's not unique to P2A.  The one wrinkle here is that, contrary to a keyed
anchor, where it's key to you and one particular counterparty, so only you and
the counterparty can do this replacement cycling, a P2A is a kind of
anyone-can-spend output, so anyone can do this replacement cycling as well.

**Mike Schmidt**: So, this was something that you knew about, this passive
attack, you knew that P2A had similar vulnerabilities as other schemes in this
regard.  There is a wrinkle to it.  Is this just something that we'll just leave
that as a known drawback, or is there plans to address?

**Greg Sanders**: I mean, replacement cycling, in my view, is mostly attack
against miners, in that you're kind of playing games in the mempool where the
miner could have picked up more fees than it did, the attacker cycles out a
spend, which they're paying for, but then for some reason the Bitcoin Core node
or the Bitcoin node doesn't know how to recapture the original fees that the
honest participant was doing.  And so I spent a little time working on a proof
of concept, which I think I linked in that email thread, at some point, that
basically a strategy for perhaps looking at, like, miners could run a sidecar
script that runs on various feeds, data feeds, like RPC or ZMQ, or a mixture of
that, where they could, with an anti-denial service way, recapture some of those
fees, thereby effectively making this replacement-cycling attack moot.  Do you
want me to go into that a bit?

**Mike Schmidt**: Yeah, yeah, let's do that.

**Greg Sanders**: Okay, so it was based off an idea of Suhas from Chaincode.  He
gave a high-level kind of description of how he would do it, architecturally
speaking.  And then, I took that and tried to generalize it a bit, and also just
make it a sidecar thing.  Because I figured that if you could just have it be an
easy script to run on the side that, as long as 10%, like some small percent of
miners, run it, it effectively neutralizes the attack itself.  And so basically,
it kind of builds off this idea that replacement cycling is an attack on
basically the next block, right?  The replacement cycling is an attack on a
transaction that should have gotten mined but gets cycled out instead.  So, you
basically track things that are in the next block in your mempool, and you, at a
UTXO level, basically identify UTXOs that are being cycled out.  So, they were
going to be mined, but now they're not, and you basically track these cycles in
a compact manner.  And then, once you detect that someone's playing games, then
you can cache particular transactions.  So, as soon as something is evicted, you
cache that entire transaction, and then if you detect that that UTXO becomes not
next block, then you resubmit it again.

I have a proof of concept, which is a simplification of it because of various
reasons, but it's got comments and notes on what improvements would need to be
made, including things like cluster mempool and maybe modifications to the ZMQ
feeds, or an additional feed, because one of the key drawbacks is that ZMQ feeds
don't give you exactly what you need for this mitigation.

**Mike Schmidt**: Jumping back up maybe to P2A more generally, is this something
that you and other folks are working on with the multiparty protocols, like
Lightning implementations and other folks that would be users of P2A?  Is there
eagerness to adopt P2A, etc?

**Greg Sanders**: So, I mean I know one group.  So, I've heard t-bast from
Eclair say that, I think they'll just kind of adopt it for their own channels,
even if they don't get picked up by the LN spec.  But yes, in general, this
combined -- I guess we didn't talk about ephemeral anchors, right.  This,
combined with the ability to have the output value zero, would be nice to have
for various protocols where you're basically not allowed to set value from the
smart contract itself.  For the LN spec itself, I mean I think it makes sense,
but the LN penalty regime allows you to have this reserve value and penalties,
which allows you to play some games with this.  So, it's a little less crucial
to get this zero-value output, I'd say.  But anything like LN-Symmetry, or
spacechains, I heard, needs this, things like that.

**Mike Schmidt**: Murch, any questions or follow up on your side?

**Mark Erhardt**: I'm afraid not.

_Proposed BIP for scriptless threshold signatures_

**Mike Schmidt**: Okay, great.  Next news item is titled, "Proposed BIP for
scriptless threshold signatures".  And we have the author of that BIP, Sivaram,
here to discuss his proposal, mailing list post and, Sivaram, maybe just
high-level, what is this and why is it important?

**Sivaram Dhakshinamoorthy**: Yeah, I could probably try to address why do we
have two BIPs for FROST in the first place.  For example, MuSig2 is a
multisignature scheme too that has only one BIP, BIP327.  So, in general, FROST
is a signature scheme like MuSig2 that allows a group of people to share a
bitcoin.  So, the main reason we have two BIPs for FROST is because of the
differences in the key generation mechanism between MuSig2 and FROST.  MuSig2
creates this common shared key through a technique called additive secret
sharing, where they simply add up the available signer's key to create the
shared key.  And this key generation is easy to implement in a distributed way.
We just take the other person's key and give it to the aggregation API and that
will output a shared key.  It's non-interactive too; you don't need to talk with
other signers.

But FROST relies on a technique called Shamir's Secret Sharing to create this
shared key, and this requires the signing keys, AKA shares, to be correlated
with each other to derive the group key from just a subset of signers, instead
of the whole participant group.  And due to this property, when we try to do
this in distributed fashion, we need to communicate with other signers to
maintain this correlation property between signing keys.  And these
communication channels are not clearly specified in the FROST papers, which
makes distributed key generation difficult in FROST, hence we have a BIP called
ChillDKG, by Jonas Nick and Tim Ruffing, that performs this key setup.  And the
BIP that I shared, it allows people to create the signatures by a threshold
number of people to create the schnorr signatures in it.  Yeah, that's the
reason we have two BIPs.  It basically allows us to do signing.

**Mike Schmidt**: If there was a different method for generating keys to be used
with FROST separate from ChillDKG, does that change the signing portion that
you've proposed here, or could it be used with different key generation
algorithms?

**Sivaram Dhakshinamoorthy**: Yeah, that is one of the new things in the BIP,
like how do we specify these FROST keys in a generic way so that it's compatible
with different key generation protocols.  So now, we just say we have a property
that the FROST keys need to satisfy to be compatible with the signing protocol.
As long as the properties are satisfied, you can use distributed keys which are
generated through ChillDKG, or you could have a trusted dealer key generation,
which is described in the RFC 9591.  So, as long as the property is satisfied,
you can use any key generation mechanism.

**Mike Schmidt**: And for reference, we had Jonas Nick on in Podcast #312 to
talk about ChillDKG.  And we also covered that in the writeup for Newsletter
#312.  Sivaram, what's feedback been, if any, on the proposed BIP?  I assume you
also got feedback before you published this; there's only really a handful of
people that could review something like this.  What's feedback been so far?

**Sivaram Dhakshinamoorthy**: Yeah, it's pretty good because I also have
meetings with Jesse Posner and Jonas Nick, with whom I discussed the BIP before
I proposed it.  And since this paper is very -- I mean, in general, FROST
signing is very similar to MuSig2 signing, so the BIP is also very similar to
BIP327, so the feedback is pretty good.  People are happy with things and there
are a few open questions remaining that need to be addressed, but overall things
are good.  Oh, and one more thing that I'd like to mention, which people usually
get confused on, so when we say FROST, we usually refer to the FROST scheme
proposed by Chelsea Komlo, the original FROST paper.  But there has been a
number of variants of the FROST scheme that came up the next few years.  For
example, even the author itself proposed something called FROST2, that optimizes
scalar multiplication and signing.

In this BIP, we use a variant called FROST3 that is proposed by Tim Ruffing in
his ROAST paper.  So, people looking at this BIP right after reading the
original FROST paper might see some differences in the nonce generation and
things.

**Mike Schmidt**: Thanks for that clarification.  Murch, or any of our other
special guests, any questions or comments?

**Brandon Black**: I had a question for Sivaram.  I understood that you said the
BIP is quite similar to BIP327, and some things are almost verbatim the same.
And I'm curious, what was the choice point in terms of delegating some things to
be as defined in BIP327 versus fully redefining them here in the FROST BIP?

**Sivaram Dhakshinamoorthy**: You mean like we have a common place that we
mention the things same as the 327 FROST BIP?

**Brandon Black**: Yeah, so in the FROST BIP, like the nonce generation could, I
think, be the same as BIP327 nonce generation, but we have the full algorithm
specified here in the FROST BIP instead of saying, "Do nonce generation the same
as BIP327".

**Sivaram Dhakshinamoorthy**: Oh, okay.  The reason we are specifying it
completely because there are very small changes. For example, in BIP327, it asks
you to give the public key as a mandatory input, because in case of MuSig2, we
have this attack where, when a person is using a tweaked signing key, you could
perform a Wagner's attack using the key aggregation algorithm; but in case of
FROST, we have an interactive key generation algorithm, so this attack is not
possible.  So, in our case, we'll say, "Nonce generation, you don't need to
provide a mandatory pubkey, we can keep it as optional".  So, there are like
very few certainties, which is different from BIP327.  But the rest of the
things are pretty much same.  So, we didn't want to say just go back and look at
the nonce generation from the BIP because of these few differences.

**Brandon Black**: Gotcha.  Thank you so much.

**Mike Schmidt**: Sivaram, thanks for joining us.  If you have any parting
words, feel free to let us know.  Otherwise, we can wrap up and move on.

**Sivaram Dhakshinamoorthy**: No, thanks for having me.

_Optimistic verification of zero-knowledge proofs using CAT, MATT, and Elftrace_

**Mike Schmidt**: Last news item this week, "Optimistic verification of
zero-knowledge proofs using CAT, MATT, and Elftrace".  Elftrace is a tool to
verify the execution of a binary using Bitcoin Script.  It uses RISC-V binaries,
and we actually spoke with the tool's author, Johan, back in Newsletter #283,
with the topic of, "Verification of arbitrary programs using proposed opcode
from MATT".  And this week, we covered that that same tool can now have the
ability to verify zero-knowledge proofs.  There's some caveat there.  For this
to actually be used on-chain, we need both OP_CAT and the MATT soft forks to be
activated.  I know I always go, when we talk this scripting stuff, to Rearden
Code.  Brandon, do you have thoughts on this?  Were you aware of this
development and do you have any opinions on it?

**Brandon Black**: Sadly, I am not up to speed on the Elftrace stuff.

**Mike Schmidt**: Murch, did you have any other additional thoughts?

**Mark Erhardt**: Sorry, I'm also not super-familiar with this.

**Mike Schmidt**: All right, we can move along.  Next segment was our Bitcoin
Core PR Review Club that we do monthly, and we sort of already covered it.  It
was the PR by instagibbs to add P2A as a standard output script for spending.
There's a series of little question and answer quizzes if you want to jump in
and look at the details there.  Greg, do you think we covered the gist of it
sufficiently already, or is there anything else you'd like to add here?

**Greg Sanders**: I think so.  You can just take a look at the PR review because
it has little fun tidbits of like, "When is witness data required?  When is it
allowed versus script-saving data?  When is it allowed?  When is it disallowed?"
I think during the review club, even sipa got a little confused at certain
points.  So, I think it's worth diving into.

**Mike Schmidt**: Yeah.  So, in addition to the questions and answers that we
highlight in this Review Club section of the newsletter, there's a whole IRC log
where the meeting participants interact.  So, yeah, check that out.  Thanks for
the plug, Greg.

_Libsecp256k1 0.5.1_

Releases and release candidates.  We have two this week.  Libsecp256k1 0.5.1.
Sivaram, I believe you're a contributor to secp, is that right?

**Mark Erhardt**: He was just reconnecting.  He might not have heard you.

**Mike Schmidt**: Okay, all right.  Well, I see him gone now.  Well, there's a
few things that this release contains.  One is, it adds the ElligatorSwift key
exchange examples.  This is the same sort of technology that's used in BIP324.
It also fixes a compilation error when disabling the extra keys module.  And
then, we also noted in the writeup that it changes the default size of the
pre-computed table for signing to match Bitcoin Core's default.  So, this is a
minor release for those depending on libsecp.

_BDK 1.0.0-beta.1_

Next release, BDK 1.0.0-beta.1, which we've had in here for a few weeks.
Although this week, we summarized an additional note, which was that BDK's
functionality has been split into a few different modules called crates, in Rust
land.  So now, there are crates for BDK's features for Electrum, Esplora,
bitcoinD, the wallet, and one for BDK_chain.  As promised, we'll have a
contributor for BDK join us when this actually gets to version 1.0.0 so they can
walk us through the journey of this library getting to version 1.  Anything to
add on those releases, Murch?

**Mark Erhardt**: I'm afraid not, no.

**Mike Schmidt**: Notable code and documentation changes.  If you have a
question or comment for us, this would be the time to post it in the thread or
request speaker access.

_Bitcoin Core #30493_

Bitcoin Core #30493 enables full-RBF as the default setting.  Murch, I know when
we were talking about the block reconstruction topic earlier, we mentioned that
some of that data was informative of this getting merged.  Anything else that
you'd add here?

**Mark Erhardt**: I think maybe we can talk a little bit about the overall
situation and roadmap here.  So one thing is, of course, that if full-RBF is
active on the network, even if only something like 10%, 15% of the nodes
participate, it will reliably relay all of the full-RBF transactions to the
miners, and the miners seem to have adopted it almost fully.  So, I think in a
way it's kind of silly to still have the flag if that is the case.  It's
definitely going to be in the next release and maybe the next two releases, but
if the whole network is allowing replacements without signaling at this point,
you can turn it off, but it will sort of be simply hiding behind your towel so
you don't see the predator, right, and the predator still sees you, of course.
I mean, you cannot do the replacements locally, you'll still have them in the
blocks.

So, very likely Bitcoin Core will remove the mempoolfullrbf flag for good in one
of the following releases, and we might even think about getting rid of
signaling altogether, because if it's not being respected by the network, it
will not serve any purpose.  This has a couple of implications on people that
rely on zero-conf.  They hopefully, in the last two and a half years that it was
an option, have already worked on other metrics or heuristics to determine
whether they want to trust the transaction before it's confirmed.  Generally, I
think it's always been a tenet of the Bitcoin movement that transactions are
only reliable after they are confirmed.  So, I'm not particularly shocked that
whatever reliability people assign to zero-conf is getting degraded a little
more now.  But yeah, Bitcoin Core, the next release will have mempoolfullrbf
enabled by default.  It's probably going to be removed as an option in 29, I
think, and so that's one version later.  And then maybe we'll turn off signaling
altogether a little later, too.

_Bitcoin Core #30285_

**Mike Schmidt**: Bitcoin Core #30285.  This PR adds two different cluster
linearization algorithms to Bitcoin Core's cluster mempool efforts.  One of
those algorithms is for combining two existing linearizations; that one's called
MergeLinearizations.  And the second one is for improving linearizations by
adding additional processing; that one's called PostLinearize.  We discussed
some other cluster mempool PRs to Bitcoin Core last week in #314, and we also
had sipa on a few weeks ago.  I don't have the number handy, but check the
podcast feed where he talked about cluster mempool as a topic, so that was great
to listen to.  Murch?

**Mark Erhardt**: Yeah, so I wanted to jump in a little bit here and talk a bit
about all of the work that's being done here in our office.  So, we've been
talking about linearizations a little bit, which is you get a connected
component in the graph, which is just all the transactions that are ancestors
and descendants of other transactions in a cluster.  And once you've collected
that, the biggest possible group, you have the connected component.  And the
main idea of cluster mempool is that these clusters, what we call the connected
components, have an order in which they get mined, a linearization.

So, it turns out that depending on how you implement the linearization, they can
be better or worse.  It's kind of expensive to compute the optimal
linearization.  And one of the interesting breakthroughs here was that, I think
it was Pieter probably that discovered this, if you have two different
linearizations and they both generally just have to adhere to the topological
requirements, parents have to go in front of children, you can compare them with
our feerate diagram.  So, you just basically draw on the x-axis how large
transactions are and on the y-axis how much fees they bring, and you sort of get
the chunking by connecting the convex hull of that.  Well, it turns out that if
you have two different linearizations, some of them can be incomparable to each
other.  One line might be over the other line in some points and vice versa, and
you can't really say one is better or the other.

Turns out when you use the merge algorithm on these two linearizations, you will
always find a linearization that is better than either of the two, so one that
is strictly better.  So, this is used in a bunch of things around cluster
mempool, where we have come up or -- I'm mostly an observer in this too, so "we"
is maybe a little generous to me -- but Pieter and Suhas especially have come up
with a bunch of ideas of how to generate linearizations, and merging them
together will always improve the result.

The other thing is this PostLinearize step.  So, when you have a linearization,
you sometimes may end up with chunks that are unconnected.  So, two sets of
transactions that are not directly related are grouped into a chunk and would be
mined together, according to the chunking.  And in that case, you can just
switch the order of the two unconnected parts of a chunk, and it will lead to
one chunk being mined by itself with a higher feerate than the other one.  And
so, these are just basically very small building blocks on how we can improve
linearizations that are implemented and have been fuzzed in dozens of different
fuzzers, and we will get some really, really fast and near-optimal cluster
linearizations.

So, anyway, there's a lot of time being spent on making this as good as possible
and maybe over-engineering it a little bit, which according to sipa is the right
amount of engineering.  And then, yeah, eventually we'll hopefully have this and
probably not this release, well, obviously not this release because feature
freeze is this week, but hopefully next release.

**Mike Schmidt**: I'm very glad that you're in the office and also able to grok
all of that discussion.  Thanks for elaborating, Murch.

**Mark Erhardt**: I wish I could grok all of it, but I understand some, luckily!

_Bitcoin Core #30352_

**Mike Schmidt**: Bitcoin Core #30352 we covered in the PR section, but we
really covered it in the News section today, so refer back to that for details
on that PR, which is the P2A PR.

_Bitcoin Core #29775_

Bitcoin Core #29775.  This is actually a PR that we covered originally in #306.
This is the PR around testnet4, and in #306, that was the announcement for the
testnet BIP, which also referenced this PR.  Then we also had Fabian, the PR's
author, on in Podcast #311, where we covered this PR as part of the Review Club
segment.  Murch, maybe question for you.  What does activation of testnet4 look
like, and how do you retire testnet3 from Bitcoin Core's perspective?

**Mark Erhardt**: Well, that's an interesting question.  So, basically it's
active already, there's almost 40,000 blocks mined.  Basically, Fabian had this
draft PR open to Bitcoin Core, and some miners or some people already started
testing the PR branch and started mining on it.  I have actually run this PR
myself.  I've synced a node a few times, I even snuck a few blocks with the
20-minute exception rule recently, so I'm a testnet whale now, I have 500
bitcoin!  Yeah, very nice.  So, it already works.  There was some discussion on
whether or not we should reset it one more time, make the launch fairer, and
it's sort of pointless.  Actually, it's a great thing that there's some blocks
mined already.  A few people have already set up faucets.  So right now, you can
just go on a website when you're running the testnet for a client and have
testnet coins sent to yourself.  You're getting something like half a
millibitcoin to a millibitcoin, and yeah, so you can just jump in and it works
and it runs already.

There has been a little bit of discussion in the last week whether we should add
another consensus improvement here.  So, one of the things that ships with
testnet4 is the rule from the great consensus cleanup, that the first block of a
new difficulty period cannot be significantly older, per timestamp, than the
last block of the previous difficulty period.  So, some people might be aware
that the difficulty calculation has an off-by-one error and it makes the
difficulty periods not align perfectly and not overlap.  So, it is possible to
shift two difficulty periods to each other so that the later difficulty period
seems to start before the previous difficulty period.  So, the great consensus
cleanup proposed to restrict that the last block cannot have a timestamp more
than ten minutes ahead of the first block in the new difficulty period.

Someone described an attack this week, you might have seen it on Twitter or
Delving, where even if you fulfill this rule, there's a way you can
exponentially decrease difficulty by fudging timestamps.  You alternate back and
forth by setting blocks into the far future and then back to the current time,
or even a little bit into the past.  So, it looks like testnet4 is coming out as
is, but there might be a soft fork improvement to the testnet4 rules coming
still.  And while testnet3 is out there, there's people running it, there's a
number of other node implementations, in Bitcoin Core, support for testnet3 is
probably going to stay in for at least a couple more versions.  It'll probably
be deprecated in this release.  I think that might have gotten merged meanwhile.
And then next release, the RPC might get deprecated in the sense that you have
to use a different call.  Support is still implemented, but you have to
explicitly change how you call testnet3 support when starting a node, which
would hopefully make anyone that is using testnet3 right now and is updating the
node software realize that testnet3 support in Bitcoin Core is on the way out.
And then presumably, in version 30, we would remove testnet3 support from
Bitcoin Core.

So, the context there is of course that, on the one hand, there have been all
these block storms on testnet3 for a while.  Testnet3 is beyond the tenth
halving, it hardly produces any block rewards any more, so that's not a good way
of getting testnet coins anymore.  And the history is enormous, which means that
you have to spend a lot of RAM for keeping all of the block headers in memory.
And yeah, so if people want to take testnet3 and run with it forever, be my
guest, but I think that the ecosystem hopefully will transition away from it and
use testnet4, so it's going to go away in Bitcoin Core eventually.

_Core Lightning #7476_

**Mike Schmidt**: We have a few Lightning PRs coming up, and of course, we have
BlueMatt on, and of course there's no LDK PRs, so, sad face.  Core Lightning
#7476 titled, "Part 6: final catchup to latest BOLT spec".  This is part of Core
Lightning's (CLN's) ongoing work to support BOLT12 and the latest specifications
of offers.  There's 18 commits in this PR and a lot of it looked in the weeds,
but we did note in the newsletter that the PR adds, "The rejection of
zero-length blinded path in offers and invoice requests".  And also, I noticed
in the PR description it notes, "We get more serious about ID aliases".

_Eclair #2884_

Eclair #2884, which implements BLIP4, which is a BLIP that is titled,
"Experimental Endorsement Signaling".  This is not a BOLT, but a BLIP, this
BLIP4, which is a Bitcoin Lightning Improvement Proposal, the difference being
that if a feature is intended to become universal or near-universal in the LN,
it should be a BOLT and not a BLIP.  Okay, so what does this BLIP say and what
is Eclair doing here?  The BLIP is meant to help address channel jamming attacks
in the LN and it combines unconditional fees and local reputation to do so.  We
actually covered a bunch of the research and discussion around this sort of
research and channel jamming research last year.  And actually, Newsletter #282,
which was our Year-in-Review Special for 2023, had a segment linking to all the
discussions around HTLC endorsement research and discussion, which I think would
be a good resource for more details on that BLIP, which Eclair has implemented
here.  Murch, anything to add on BLIP4 channel jamming and Eclair's
implementation?

**Mark Erhardt**: I don't know specifically about Eclair's implementation, but
there's been a ton of research going into this.  The idea is, of course, that
you sort of would set aside a part of your resources of your node, half of your
channel capacity and half of your channel slots, that they would only be used
for endorsed HTLCs.  And the context here is, you would assign a reputation to
your direct peers, it's not a network learning, it's not shared with anyone, but
you just sort of learn, "Hey, this peer is giving me good traffic, the HTLCs get
closed quickly, I earn some fees on that", and over time, you put them into your
preferred trusted set, not trusted set, but you think they have a good
reputation, and you have set aside part of your channel capacity that is only
accessible for endorsed HTLCs, which means for example, if a peer that has a
good reputation sends you, "Hey, I think this is going to be a good HTLC", you
let it use these half of your set-aside slots and capacity.

So, the idea here is that this will help prevent low-reputation, new nodes from
jamming you and costing you money by not allowing you to forward anything for
extended periods, because they can just make HTLCs hold for up to two weeks.
And yeah, so this is progressing nicely.  There's been a bunch of testing,
there's been an Attackathon, where people came up with just testing heavily
whether this model will be viable in the long term, and I think we'll see more
news on this soon.

_LND #8952_

**Mike Schmidt**: LND #8952, which is a refactor PR in LND, and it's part of
their plan to implement dynamic commitments, which is a way in LND, well, in all
LN implementations, but a way to change properties of a LN channel without
having to close and reopen the channel.  So obviously, being able to upgrade a
channel or change the properties of a channel, without having to unnecessarily
close the channel and then reopen it, would be valuable.  We covered a news item
previously titled, "Upgrading existing LN channels", and that was in Newsletter
#304, where Carla Kirk-Cohen outlined a few different considerations and then
proposed ideas for upgrading channels.  So, check that out.  Murch, anything on
upgrading channels?

**Mark Erhardt**: Actually, let me.  Sorry, I did wave you off!  So, the
interesting thing about upgrading channels is, we've had taproot for a couple of
years now, there's interest in making channels taproot-based, which is
especially great for LN channels because they're inherently 2-of-2 multisig.
So, if you can make them MuSig based, they'll have a smaller on-chain footprint
and better privacy.  And there are some other features that people want to put
into channels.  So, we will need a way to make people able to upgrade their
channels, preferably without closing and reopening them, and this is what all of
this is about.

_LND #8735_

**Mike Schmidt**: LND #8735.  This PR is titled, "Route Blinding Receives:
Receive and send to a single blinded path in an invoice".  This is part of LND's
support for blinded paths and there's a tracking issue for this.  The parent
issue is #6690.  They note in the description that, "This PR is the first in a
set of 3 PRs that will implement route blinding receive logic and LND.  As LND
does not yet support BOLT12 invoices, this PR adds them to the BOLT11 invoice
serialization".  So, with this PR, LND users can request that a BOLT11 invoice
include blinded paths.  And LND will then also be able to pay a BOLT11 invoice
that includes blinded paths.  The description also notes that there will be a
follow-up PR that will add the ability to make use of multiple blinded paths.

_BIPs #1601_

BIP6 #1601 adds BIP94, which is testnet4.  We covered #29775 earlier in the
newsletter, which was the Bitcoin Core implementation for testnet4.  And as
mentioned earlier, you can reference Podcasts #306 and #311 that have additional
details on testnet4, including a discussion with its author.  As our resident
BIPs maintainer, Murch, do you have anything to add on #1601?

**Mark Erhardt**: No, I think it's nice.  We have the first time a BIP to
specify a testnet, even though we're already on the fourth testnet.  So, yeah,
testnet 3 had just been ancient, old enough that it was launched right around
the time that I think BIPs came out.  And well, yeah, so there's a whole BIP
that goes into the details and motivations for why testnet4.  It explains a bit
around the 20-minute exception, how we mitigate block storms with forbidding the
20-minute exception for the first block in a difficulty period.  So, maybe, do
you think I should maybe explain how block storms even happen in the first
place?

**Mike Schmidt**: Yeah, why not?

**Mark Erhardt**: Okay, so the block storms in testnet3 were happening due to
the 20-minute exception rule.  And the 20-minute exception rule was permitted
for every single block, even the last block in a difficulty period.  And if the
last block in a difficulty period was using the 20-minute exception, the actual
difficulty of the block was reduced to 1.  So, the exception rule states, if the
timestamp of your new block is at least 20 minutes higher than the previous
block's timestamp, you must use difficulty 1 instead of the actual difficulty.
Now, if the last block in a difficulty period was reset to 1, what happened was
in the new difficulty period, whatever difficulty adjustment was going to happen
was applied to difficulty 1, the difficulty of the last block in the previous
difficulty period, instead of the actual difficulty.

So, the way the fix happens is instead of taking the difficulty from the last
block in testnet4, we use the difficulty of the first block in the difficulty
period.  Since usually the difficulties across all blocks in a difficulty period
would be the same, which is the case in mainnet and just the special rule on
testnet, where we allow people to mine blocks with CPUs if the blockchain hasn't
been moving for 20 minutes, this works because the first block in a difficulty
period is not permitted to use the 20-minute exception, so it will always have
the actual difficulty.  So, testnet4, instead of being reset to difficulty 1 and
then someone with an ASIC being able to mine like 2,016 blocks in 386 seconds or
so, which is a little over 6 minutes, we basically restrict people to only being
able to mine something like 6 blocks with fudged timestamps until they hit the
two-hour-in-the-future rule.

So, the exception now works again for, "Oh, the blockchain hasn't been moving,
I'll be able to mine a block with my CPU at home".  But it doesn't work anymore
to generate thousands of blocks.  And especially, it doesn't reset the
difficulty to a minimum if it's used on the last block, because we always have
the actual difficulty and we start a new difficulty period with the actual
difficulty.  So, this is one of the, I think, two or three changes generally
with testnet4.  Yeah, hope you're also excited about testnet4 coming out there.
And if you're running your stack on testnet, please consider switching to
testnet4.  I assume that it will be a better user experience for you users,
except of course they'll need new coins because testnet3 coins are not
compatible to testnet4 coins.

**Mike Schmidt**: Thanks, Murch.  I don't see any requests for speaker access or
questions in the threads, so I think we can wrap up.

**Bob McElrath**: I'll make one more comment about that.  Awesome we're moving
to testnet4; testnet3 has been a pain in the ass for a long time.  The
fundamental problem with the storms of blocks is still going to happen if
somebody connects a high-power ASIC.  Because of that and because of the needs
of Braidpool, I started a new testnet, forked off of testnet4, called CPUnet.  I
just posted on Twitter, it's a work in progress, needs some more work, but the
idea being, just change the PoW function so that existing ASICs can't point at
it.  We're more interested in latency, and we need things to proceed, and
particularly difficulty adjustments to proceed as they happen in Bitcoin.  So,
for my particular use, the 20-minute rule is a problem.

Anyway, if anybody else is interested in having a CPU-mined testnet, please take
a look at that and reach out to me.  I'd love to have more users.  I have a
feeling there's more people out there who might need something like that.

**Mike Schmidt**: Thanks for chiming in, Bob.  Thanks for chiming in earlier as
well.  Thanks to Rearden Code for joining us and making an appearance, to Greg,
Sivaram, BlueMatt, and always, my co-host, Murch.  We'll see you all next week.
Cheers.

**Mark Erhardt**: Cheers, see you.

{% include references.md %}
