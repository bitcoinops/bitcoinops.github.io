---
title: 'Bitcoin Optech Newsletter #347 Recap Podcast'
permalink: /en/podcast/2025/04/01/
reference: /en/newsletters/2025/03/28/
name: 2025-04-01-recap
slug: 2025-04-01-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Sjors Provoost and Antoine Poinsot to discuss [Newsletter #347]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-3-1/397648477-44100-2-41f0231f8dafe.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #347 Recap.
Today, we're going to talk about John Law's fee-based spam prevention for
Lightning; we have a discussion about testnets, also potentially relaying
taproot annexes; and 11 Bitcoin Stack Exchange questions, including one on
duplicate transactions and another one related to the consensus cleanup soft
fork.  I'm Mike Schmidt, contributor at Optech and Executive Director at Brink.
Murch?

**Mark Erhardt**: Hi, I'm Murch, I am working at Localhost, in the Localhost
office today.

**Mike Schmidt**: Sjors?

**Sjors Provoost**: Hi, I'm Sjors, I work on Bitcoin Core.

**Mike Schmidt**: Sjors, thanks for joining us.  I think Antoine's gonna join us
a little bit later in the show to talk about his items, but we can get started
in the meantime.

_LN upfront and hold fees using burnable outputs_

First news item is titled, "LN upfront and hold fees using burnable outputs, and
unfortunately, John Law isn't able to join us today, but he posted to Delving
Bitcoin the summary of a 25-page paper he posted to his GitHub titled,
"Fee-Based Spam Prevention for Lightning".  His idea is to discourage spam and
help prevent channel jamming.  He wants to do that by using two types of fees
when forwarding payments in Lightning.  One is an upfront fee that would be paid
by the sender to compensate forwarding nodes for temporarily using a scarce HTLC
(Hash Time Locked Contract) slot, which is a limited resource, there's only 483
available; and the second type of fee he wants to charge is a hold fee, which is
actually paid by a node along the payment path that might delay the HTLC from
settling.  And that hold fee would depend on how long the payment was actually
delayed.

We noted in the write-up that there were a few other newsletter references where
we spoke about the different ideas around upfront and hold fees, so I'm not
going to list those here but refer to this week's newsletter for those previous
mentions.  John Law, he proposes to enforce these fees by locking some funds
between the channel counterparties in a sort of bond, and those funds that would
be locked would be essentially at stake, if you want to think about it like
that, and either of the channel counterparties could unilaterally destroy those
funds in that bond, which is the incentive for good behavior in this protocol.
And the idea for locking funds in a bond like that was one of John Law's
previous ideas that he outlined in his offchain payment resolution (OPR)
protocol, and we covered that OPR protocol in Newsletter #239.  Murch, did you
get a chance to dig into this idea?

**Mark Erhardt**: Not deeply.  I must admit that I find the incentives of the
bond a little unclear.  We've seen before with some other protocols where funds
were just held, that they would make one of the parties blackmailable.  I
haven't looked into it too much but I don't know, I didn't read the paper.  25
pages seems like a lot of writing, so maybe it gets into the details of this,
but I wonder how the game theory works out exactly.

**Mike Schmidt**: Yeah, so it sounds like instead of having some sort of
protocol level enforcement of these fees, I guess you would have sort of a
handshake agreement on this, and then it would just be in this bond.  And as
long as everything resolves correctly, then nobody gets funds burned?  Is that
your understanding, Murch?

**Mark Erhardt**: Yeah, my understanding is that both parties put in a huge
amount of money, like twice the amount of the commitment, and as long as they
play nice, they both get it back.  And then, the only option to punish the other
party is to burn your own funds and to burn the other person's funds.  So,
basically, if you anger the other party so hard that they want to punish you
more than they care about punishing themselves to the same degree, then there's
a punishment.  And it's kind of harsh that you have to punish yourself in order
to punish the other party.  So, it might incentivize good behavior, but I'm not
entirely sure that's the outcome.

_Discussion of testnets 3 and 4_

**Mike Schmidt**: Well, I think we can wrap that one up.  Moving on to the
second news item titled, "Discussion of testnets 3 and 4.  Sjors, you mailed the
Bitcoin-Dev mailing list an email titled, "Does anyone still need testnet3?"
What did you find?

**Sjors Provoost**: It seems the answer is yes.  And I think today especially,
people pointed out that there's still some LN infrastructure running on testnet3
and it's kind of difficult to move, because when people are testing LN, they'll
have multiple nodes running and they have channels in between them, and those
nodes are run by different implementations.  So, if one of the implementations
doesn't move to testnet4, then the others can't.  I think there was also an
earlier wallet using it.

**Mike Schmidt**: Maybe Sjors, let's talk a little bit about this graphic that
we included, and I think there was a similar one that I saw somewhere else about
testnet4 and the different reorgs going on.

**Sjors Provoost**: Yeah, so on testnet3, what started happening is people,
well, one person really, started making block storms, so thousands and thousands
of blocks in a very short time, and that was one of the reasons to try testnet4,
which had slightly different rules.  And now we're seeing other weird behavior,
and I think it's mainly, if you look at this chart, very wide forks, so like 10
blocks at the same height.  And my impression is it's people trying to CPU mine.
So, they're trying to CPU mine and the way you CPU mine is by setting your clock
20 minutes in the future.  And so, when you set it 20 minutes in the future,
there's a rule that says the difficulty now drops to 1.  So, that makes sense,
then somebody thinks, "Oh, I want another block", so they move their clock 40
minutes in the future and then 60 and then, etc, etc.  And then you hit a limit
of 2 hours, because then if you set it more than 2 hours in the future, other
nodes won't accept your block anymore.  So, you probably get somebody producing
5 blocks in a row very quickly, and then somebody else tries it at the same
time, and they might be racing each other.  That seems to be what's going on.

**Mike Schmidt**: Murch, do you have any knowledge of this activity?

**Mark Erhardt**: Well, pretty early on we saw that some people were playing
around with the 20-minute difficulty exception to get a few of their own coins,
and then someone seemed to just start doing it for every single opportunity that
was available.  And now, with the 10 parallel blocks all the time, it looks like
not just one person is running an automated script that tries to mind these
minimum difficulty blocks immediately, but there's many different people that do
it.  So, it's basically, people are trying to monopolize the common good and
therefore it fails for all of them.  People are no longer able to occasionally
get a few testnet coins for themselves to do testnet transactions without having
massive amounts of hashrate, and people are selling testnet4 coins already.  So,
altogether, it just doesn't work as for the intended goal of being able to mine
your own non-standard transactions and distribute some of the testnet coins
easily to developers, Because it's exploited all the time.  I think Antoine has
some thoughts on this one.

**Mike Schmidt**: Antoine, do you want to introduce yourself real quick, and
then we can get to your unbreaking testnet4 post?

**Antoine Poinsot**: Sure.  My name is Antoine, I work at Chaincode Labs.  I
have some, well, basically you guys explained it all.  I think this can be
pretty much summed up as, people assumed that participants would play nice; not
only that participants would play nice, but every single participant is always
going to play nice all the time, and I don't think it's a realistic assumption.
So, I think we should either bite the bullet of, if we want to lift the
restriction for some people, identify them and use something like signets.  But
if you are going to have an open-entry network, like mainnet, with PoW, you need
to have a real PoW.  Any amount of shenanigans that you're going to try to
weaken the PoW from some people, but not from others, are necessarily going to
lead to either being exploited or being unhelpful for people who are trying to
help.

So, yeah, I think we should have a PoW for testnet that just matches that of
mainnet and have signet when we want more lenience for some people.

**Sjors Provoost**: Maybe useful to add here that on testnet3, the coinbase
reward, or the subsidy I mean, was already gone.  So, the reason we're not
seeing this type of behavior on testnet3 is because it's not profitable.  You
can make 6 extra blocks on testnet3, but it's just going to give you, like, 100
sats.  Whereas on testnet4, every block gives you 50 fake bitcoins.  So, going
back to testnet3, I don't think it solves the problem, and testnet3 now seems a
lot more stable.  That's probably only because nobody feels like attacking it
anymore.  As soon as everybody starts using testnet3 now, there's a reason to
attack it again.

**Mark Erhardt**: In a way, the big underlying problem is that people started
trading testnet3 coins again, which led to us finally resetting testnet3 to
testnet4, or starting testnet4.  Really, we can't reset it in the sense that
it's a bonafide blockchain, and if some people are running it, it'll run.  But
the problem was that the infrastructure that was in place to trade testnet3
coins on exchanges immediately got reused to trade testnet4 coins.  So, on the
one hand, it makes it very reliable how to get coins because you can just go to
a marketplace and buy them.  You don't have to knock on 15 doors and ask, "Hey,
do you have some testnet coins?  I need to test something".  But on the other
hand, it's entirely against the purpose of this network for the coins to be
worth anything.  And by them being worth something, it drives this behavior of
trying to mine them, trying to monopolize them, trying to make money off of
trading them on an exchange.

So, it sort of has perverted the incentives to make this just this worthless
test network, where everybody can just easily get some coins and test their
transactions.  And instead, we now have this monopolization of the block space
and the funds.  Testnet3 additionally has this fun behavior lately where people
will only mine transactions above 50 sats/vB (satoshis per vbyte), some people.
So, it's driven up the fees on testnet3 extremely and all these people that have
been mining off of faucets and getting payouts of, like, 1,000 sats when they
try to consolidate those funds into a usable amount, they end up spending 60%,
70% of it in fees because the inputs are so tiny.  So, altogether, testnet just
has significantly been reduced in usability, utility.  It's quite annoying.

**Antoine Poinsot**: This thing of people starting valuing and attaching a price
to testnet coins is not unique to testnet, right?  It happens on signet as well,
where it causes a lot of issues with faucets, for instance, which is another
point where you can have some dust.  I think we should treat them as separate
issues.  And, yeah, it just was exacerbated on testnet4 because in addition to
people starting to value testnet coins, they could also claim them by having
some luck trying to abuse the system.

**Mike Schmidt**: Murch, or maybe Sjors as well, we have testnet4 as a fix for
testnet3; so, if testnet4 has issues, does that mean testnet5, or is there
another approach to fixing this issue?

**Sjors Provoost**: So, one of the options is to have frequent new testnets, but
I would say there's quite a bit of overhead in adding a testnet and maintaining
the old ones.  And now, as we've seen with projects like Lightning, it's quite
painful for everybody to move over to the new testnet.  So, if we were to do it
every year, there would be like three or four testnets behind at some point.
So, I'm not sure if that's the right approach.  And if I can make a prediction
of what the next shenanigans are going to be, so as soon as this difficulty drop
rule goes away, so the difficulty doesn't reset to 1 anymore, I expect more
people to start mining with ASICs on testnet4 which would ramp up the actual
difficulty.  And then, if you want to be annoying, you can do very deep reorgs,
because it's still a fairly low difficulty, so anybody with a serious amount of
ASICs could come in for five seconds and reorg 1,000 blocks and crash any
exchange that tries to use testnet4.  But we'll see how it goes.

I don't think you can ever fix the problem.  I mean, every altcoin on the planet
in the beginning tried to have the same PoW.  They quickly realized that you
need to have a different PoW if you want to be on the same chain.  You don't
want to have the same PoW as the biggest coin out there, and we don't want to go
the route of introducing PoS (proof of stake) on testnet either.  So, it seems
to me it's inherently unsolvable as long as people think that it has value.
It's just they're going to create a mess one way or the other.  But at least
it's possible to test your software on it, despite this.  I think that's the
only thing we should worry about.

**Mike Schmidt**: Another shenanigan would just be, if you remove this
exception, I don't know, someone with a decent amount of ASICs could just get
the difficulty up and then just pull them?

**Sjors Provoost**: Yeah, this used to be called, I think, a difficulty bomb,
although the term has been co-opted to mean something else in Ethereum, I
believe.  But yeah, the idea would be somebody ramps up the difficulty to some
crazy amount and then just leaves, which means no new testnet blocks are found
for a long time, and now you have to start asking big miners to please mine a
testnet block.  Yeah, that could happen again.

**Mark Erhardt**: Yeah, so there's downsides all around.  The funny thing about
the attack that Sjors mentioned, if someone actually with a bunch of hardware
hashrate were to reorg 1,000 blocks or 10,000 blocks, that would probably
significantly disrupt the exchange's operations, because of course if they sold
any new coins, those coins would just cease to exist and the buyers might be
angry.  So, that could be a way of making the whole exchange situation very
annoying and just cause a lot of support tickets for these people running these
marketplaces.  So, this would of course already work even with the difficulty
adjustment and doesn't require us to do anything, except someone that feels
charitable in that way using their hashrate to cause some good trouble.

**Sjors Provoost**: But then they could just ask thousands of confirmations, and
then people use atomic swaps to make deposits.  I mean they'll find a way.
Nature finds a way.

**Antoine Poinsot**: Even then, this is just addressing the symptom, not the
cause, right?  The only thing that you are going to do is to make the market
less liquid, to restrict the supply available to people that are demanding, and
just push high the prices, right?  So, I'm not sure that's the route we want to
go.

**Mark Erhardt**: Well, also, they couldn't rely on the payments because the
transactions would get unconfirmed and the exchange would get the money back in
that case.

**Sjors Provoost**: Yeah, but if people wish to be demanding these testnet
coins, right, they would still be ready to pay for it.  They would go on IoT and
say, "I'm ready to pay that many ads for testnet coins".  They would just have
less sellers and be ready to pay more.

**Mark Erhardt**: But there might also be less buyers if they can't rely on
keeping those coins.

**Sjors Provoost**: Yeah, well, we can also just delete testnet4 and there won't
be any buyers.

**Mike Schmidt**: Testnet has been so interesting this last year or so.
Anything else on this item?  Okay.

_Plan to relay certain taproot annexes_

Last news item this week, "Plan to relay certain taproot annexes".  Peter Todd
emailed the mailing list letting people know that he was working on adding relay
support for transactions using the taproot annex on his Bitcoin node, which is
Libre Relay, and that is a Bitcoin Core software fork that he's running.  And he
outlines a couple conditions of the taproot annex usage that he would consider
standard, which I'm not sure we need to get into yet.  Perhaps first, Murch,
what is the taproot annex; how is it treated today; and what could people
theoretically do with it?

**Mark Erhardt**: Right.  Antoine, if you have any corrections, feel free to
jump in.  The annex is an optional field in a taproot witness stack.  So, the
same place where you would have the signature, other script arguments, or the
leaf script and the control block, is then appended by this optional field
called the annex.  If you do want to have an annex, it starts with the bytes
0x50, and then the signature has to commit to the annex.  And so far, nobody
uses it.  Also, in this mailing list thread, from what I understand, nobody
suggested a specific purpose for using it right now, even though now it's going
to be relayed by Peter Todd's implementation.  And so, this annex is intended to
be an upgrade mechanism in the future.  So, for example, we could put additional
data there with a specific prefix to declare the purpose; or people have
suggested that you could put null data there, just like people put in OP_RETURNS
and other things, because at least it would be clean, it would be obviously
non-script data and so forth.

So, what Peter Todd specifically proposes here is that annexes should only get
relayed if all inputs in the transaction have an annex, and then he also will
only relay annexes that start with the prefix 0x00, but he drops the size limit
from the previous proposal that he bases this on, which was by Joost Jager in
2023 I think.  And so, yeah, all inputs have an annex, the annex has a specific
prefix, it has no size limit here, and nobody knows what it's for yet.

**Antoine Poinsot**: I guess what's interesting to see is, because it's one
thing to relay it, but it's another thing to mine it, because miners running
Bitcoin Core to generate their templates are not going to include them in the
templates because they're non-standard.  So, it will be interesting to see if
some hashrate is running Peter Todd's fork of Bitcoin Core that is essentially
developed, maintained, and released by a single guy.

**Mike Schmidt**: So, would something like, I think Marathon has their
Slipstream, would you be able to have a non-standard transaction and throw it to
Slipstream and give them some monies to include that?

**Antoine Poinsot**: Yeah, so there might be false positives.  There might be
some transactions with annex that gets mined, but that does not necessarily mean
that Peter Todd's Bitcoin implementation reached adoption.

**Mike Schmidt**: Does anybody know, no one's done this before?  Is there
something that's been confirmed previously that used the annex just for LOLs?

**Antoine Poinsot**: Oh, also, I don't know, but just to correct myself with
regard to Slipstream, it is my understanding that Marathon does not mine any
kind of standard transaction.  They consulted with Bitcoin developers before
opening to the public a bunch of standard transactions and tried to restrict
some of standardness checks that are done, because this behavior is harmful.
They're just using some upgrade hooks.  So, I'm not sure that they would even
mind transactions with annexes themselves.

**Mark Erhardt**: Yeah, just to clarify, they will not mine everything that
they're presented with, they still have some restrictions.  They just, for
example, drop the size limit for some things, and stuff that people had wanted
to do and then they, yeah, what Antoine said, just with the correction.  When he
said, "They will not just mine any transaction", what he meant is that there is
restrictions beyond the standardness rules.

**Mike Schmidt**: Sjors, do you have any thoughts on this topic?

**Sjors Provoost**: To be honest, I still do not understand what the taproot
annex even is and what it was intended for.  It's one of those upgrade hooks
that can do all the things, but I'll worry about it when I find any of these use
cases interesting enough to study them.

**Mike Schmidt**: I think we can wrap up that news item and thus the News
section.  We're going to move to our monthly segment on Selected Q&A from the
Bitcoin Stack Exchange.

_Why is the witness commitment optional?_

The first question here, which I thought was interesting and it was hard to
condense it down to a sentence in the summary for the newsletter was, "Why is
the witness commitment optional?"  And Antoine, you were one of the folks, along
with Pieter Wuille, who answered this question, which involves a few different
BIPs and potentially consensus cleanup.  What is going on?  Why is this person
asking about the witness commitment being optional?  What is the block height in
the coinbase?  Can you help get us up to speed?

**Antoine Poinsot**: Yes, I think this person, well actually I checked, so I
know that this person is asking about why is the witness commitment optional
following a post from BitMEX research about duplicate transactions, which comes
back to duplicate coinbase transactions, which I suggested a year, a
year-and-a-half, something like that ago, that we might mandate that witness
commitments be included in coinbase transactions to avoid possible future
duplicates.  I think, well, I don't need to go back into duplicate transactions
because we discussed that at one point, I think, right?

**Mike Schmidt**: Yeah.  I don't know if we need to go too deep, but what's the
one sentence version of what a duplicate transaction is or why it might be bad?

**Antoine Poinsot**: The one sentence is that, well, it might be bad because
UTXOs in the UTXO set are pointed to by the txid.  You have two UTXOs but with
the same txid, the first one is erased.  So, yeah we want unique transactions,
unique and spent transactions, but unique transactions also seems like a nice
feature to have.  It was not the case initially in Bitcoin, then a check was
implemented with BIP30.  And then it was made in BIP34, coinbase transactions
were mandated to commit to the block heights in their scriptSig to make them
unique without having to perform an explicit check of uniqueness.

**Mark Erhardt**: Because such a check is quite expensive, right?  You have to
look through the whole known UTXO set to see if something exists, which takes
time.

**Antoine Poinsot**: Yeah, for every transaction in the block, you check if
there is no UTXO with the same txid in the UTXO set.  So, yeah, it's a bit
expensive, but it's also unnecessary.  And another motivation to get rid of it
is that some more modern ways of implementing full nodes, such as utreexo, are
not compatible, just cannot perform this check.  So, that's another argument to
get rid of them.  And so, we have a few opportunities for duplicates in the
future, because before BIP34 activated, miners were already using the scriptSig
as basically an extra nonce and were introducing garbage in the scriptSig.  And
some of the garbage in the scriptSig in these early coinbase transactions, they
serialised to a valid height far in the future.  The first one is around, like,
1,900,000.  So, before then, we will need to get back to re-enabling the
explicit check that utreexo nodes cannot implement, and that it's still
expensive and necessary for a Bitcoin Core node to do, unless we find a way to
make these future coinbase transactions different from these past occurrences
with garbage that happens to deserialize it as a valid block height.

So, one way of doing this, so when I first studied the topic, I was trying to
find a way that will be the least intrusive to miners, because we know that
miners are infamous for being slow to upgrade and not really willing to upgrade.
So, assuming that almost one decade after it activated, all miners supported
segwit, we could just mandate that all coinbase transactions contain a witness
commitment, which is an OP_RETURN in outputs in the coinbase transaction,
mandating that the witness commitments can be there even if there is no segwit
transaction in the block.  Given that there were no coinbase transactions before
BIP34 activation with an OP_RETURN, it would basically mean that even if they
have the same BIP34 hides in the scriptSig, they would still be different
necessarily, so we can afford to not resume the BIP30 check, which is the
explicit check that is annoying.

But then, discussing in the threads, it turns out that people were more in favor
of doing it properly, let's say, by actually committing to the block height in a
field that expects a block height, such as nLockTime, in the Coinbase
transaction header.  It has other advantages.  I'm not sure if I'm speaking too
long, so should I go in disadvantages?  No, okay.  Well, there is two advantages
of using nLockTime instead.  The first one is that, well, it makes it easier for
application to just query the block height of the block from its coinbase
transaction, because before you would have to parse Bitcoin Script in the
scriptSig, which is marginally annoying.  Then, it also makes it such as you can
enable the timelock feature on coinbase transaction, because while in the
original Bitcoin implementation by Satoshi, nLockTime was not part of the
consensus rules, but then eventually, it was made part of the consensus rules
and it was enforced since Genesis.  So, right now all Bitcoin implementations
enforce nLockTime since Genesis.  So, it's as if it was always a consensus.  And
it is enforced on coinbase transaction.  So, you might have as a miner your
block refused, because you set a timelock too far in the future on your Coinbase
transaction.

**Mark Erhardt**: But that block would be invalid either way, because you have
to have a specific height right?  For a coinbase transaction to be valid, it
would have to be the current block height minus one.  So, if you set a future
block height, it would also be invalid because of that.

**Mark Erhardt**: Yeah, I meant under today's rules.  Under today's rules, if
you set a locktime too far in the future, it will already be invalid.

**Mark Erhardt**: Oh, I see.  So, it's basically a soft fork that is already
enforced by the old nodes.  That's sweet.  I was wondering why you thought it
was an advantage.  Now, I get it.

**Antoine Poinsot**: And so, it means that basically, let's say, a simpler way
to reason about this is instead of making the witness commitments mandatory, we
can just think, let's use a different version for the coinbase transaction.  All
coinbase transactions except a couple of exceptions were nVersion 1 before BIP34
activation.  We can just say, well, future coinbase transactions must be
nVersion 2, well anything but 1, and that would fix the issue as well.  But it
means that if you're in a chain where BIP34 did not activate at exactly the same
height or with the different block height, you don't know if there is not more
exceptions and you don't know if there was no usage of nVersion 2 back then.
So, you need to always conditionally apply this check.  Whereas with the
locktime, you know that this coinbase from block 200,000 cannot have an
nLockTime of 1,900,000 in the future because it would have been invalid then.

It's purely theoretical because we would not have a 1,000,000 blocks reorg, and
if we do, the system is worthless anyways.  But it's pretty neat from a
theoretical point of view and also from an implementation point of view.  From
an implementation point of view in Bitcoin Core, right now, the validation is
very confusing for BIP30, BIP34.  Basically, you have, "Oh, well, we always do
BIP30, except after BIP34 activation, but only if BIP34 is activated on this
specific height with this specific block hash, because that's the only chain for
which we can ensure that there won't be an exception until block 1,900,000".
And then, actually, there is also a BIP30 exception.  So, basically, the whole
code logic is a bit of a mess.  It's not a mess in itself, it's just convoluted.
And this neat check just makes us able to just say, once we bury this consensus
cleanup stuff work, after activation height of consensus cleanup, just never
check anything anymore on any chain.

**Mark Erhardt**: Yeah.  So, why is the witness commitment optional?

**Antoine Poinsot**: Yeah, sorry side point, it was made-up channel, so I didn't
know all the details…

**Mark Erhardt**: How about I take this one then?  So, originally when segwit
activated, there was some concern about whether or not everybody would be ready
to enforce it and would create segwit-enabled blocks from the get-go.  And it
was deemed better to allow old-style blocks that only included legacy
transactions by the miners that didn't upgrade at the activation time.  So, the
witness commitment is optional as long as there is no segwit transactions in the
block.  As long as the block only contains legacy transactions, you do not need
the witness commitment.  In fact, you're not allowed to have one, I think.

**Sjors Provoost**: And some context that's useful here is that miners, at least
the way it works so far, they have to make their own coinbase transaction.  So,
Bitcoin Core can be used to say, "Please give me a block", and it will generate
a block based on the mempool.  But it does not include a coinbase transaction.
So, back when segwit activated, all miners had to make sure that whatever
software they were using was producing segwit blocks.  And so, it's much safer
to not require the witness commitment, at least back then, because as long as
you were mining standard transactions, you could safely make a non-segwit block,
basically.

_Can all consensus valid 64 byte transactions be (third party) malleated to change their size?_

**Mike Schmidt**: We touched on, and I'll use this as a segue, we touched on
consensus cleanup in this previous question that you guys were discussing.  And
so, the segue here is to our second Stack Exchange question, "Can all
consensus-valid 64-byte transactions be (third party) malleated to change their
size?"  And I know that even as I was in summarizing this, there was some back
and forth and changing of perspectives.  Sjors, you asked the question, so based
on the answers you've seen in the discussion in the Stack Exchange, what is the
answer here?

**Sjors Provoost**: The answer is no, but just a little background of why I
asked it, because there was some discussion about the great consensus cleanup on
the mailing list and one of them was, "Oh, but what if I have some sort of
covenant smart-contracting system that just accidentally produces a 64-byte
transaction?  That would be bad".  And so, I was hoping that in that case, you
can always just malleate it, which means that if you even accidentally produce
such a transaction, you can just add a byte to it and it's fine.  Unfortunately,
that's not always possible, and the answer was given that if you're spending
from a segwit transaction, then you cannot change anything about it, if it uses
SIGHASH_ALL.  And yeah, I went back and forth, because I just tried to enumerate
every sort of conceivable transaction, because there's not that much space,
right?  A transaction has about 61 or 60 bytes of overhead, if you want to call
it that.  So, the absolute smallest thing you can make is 60 or 61 bytes, and
then you can only add a couple bytes to get to the 64.  So, you can kind of
enumerate every possibility, which I tried to do sloppily, and then as people
commented on it, I was changing my answer back from, "Yes, no, yes, no", so
there we go.

**Mike Schmidt**: Antoine, does this deter you with 64-byte transactions in
relation to consensus cleanup?

**Antoine Poinsot**: Well, this topic is being discussed on the mailing list
right now.  As things stand, I think that there is more upsides than downsides
to making a 64-byte transaction invalid.  I'm not married to the idea, but it's
separate, right?  Still, 64-byte transactions either burn your coins or are
anyone can spend.  So, in any case, your coins are already gone basically, so
there is some minimal confiscatory surface to making them invalid, but it's only
making something invalid that is already insecure.  And also, we are not making
them invalid for the sake of doing it, we're making them invalid because they
enabled some weaknesses in the merkle tree to be exploited.

**Sjors Provoost**: Well, my thinking is here so far, and yeah, I can definitely
still change my mind on it, is that the complexity is going to sit somewhere,
especially if you take the smart contract example that I kind of started to
search with.  Your smart contract, depending on what it's trying to do, if it
needs to verify an SPV inclusion proof of another transaction, then either it
needs to account for the fact that 64-byte transactions can exist and you need
to verify the coinbase, or something like that; or, you can assume that 64-byte
transactions don't exist because we soft-forked them out.  But in that case, you
have to make sure you don't accidentally create a 64-byte transaction.  And my
guess is the latter is much, much easier to guarantee in a smart contract than
the former.  And I'm also thinking about, there's no size limit to the coinbase
transaction.  So, if you make some sort of smart contract that verifies a
coinbase transaction, then probably it has to account for the largest possible
size with all sorts of branches.

But somebody would have to implement it to know that for sure.  And of course,
you might be completely against covenants, period, in which case the discussion
is moot.

**Antoine Poinsot**: Also, I don't see how you would actually not create a
larger than 64-byte transaction.

**Mark Erhardt**: I think the main point that we're all trying to make is so
far, nobody has demonstrated any reasonable use case for 64-byte transactions.
So, the concern that someone has created a ton of them somewhere hidden, has
never used it on a testnet or a mainnet, and argued about how it's awesome after
years of discussing it, indicates that probably there is a confiscatory surface
that will never be actually relevant.

**Sjors Provoost**: Well, the argument has gone to accidentally producing such a
transaction.  So, nobody's arguing that such a transaction would be useful, I
believe, but you could maybe produce it by accident.  But even that seems
somewhat unlikely, but I'm not entirely sure about that.

**Mike Schmidt**: Well, based on mailing list discussion, we may be revisiting
this topic in the next few weeks.  We'll see.  One more Stack Exchange question
and one notable code item, and then I think we can let our special guests go,
Murch.

_Which applications use ZMQ with Bitcoin Core?_

The Stack Exchange question is, "Which applications use ZMQ with Bitcoin Core?"
Sjors, you asked this question.  Maybe since I'm surfacing this question as a
way to get a broader audience to potentially answer it, why are you asking this
question?

**Sjors Provoost**: Yeah, so maybe also I'll quickly say, ZMQ is a way for you
to listen to your node for announcements of things like blocks and transactions
in a relatively straightforward and relatively fast manner.  So, if you want to
just monitor the mempool, for example, you can do that.  Why am I asking this?
Well, there's kind of two sides to look at it.  One is Bitcoin Core is very
large and becoming somewhat unfocused, as some people might say.  So, maybe it's
one of those things that one day we can get rid of.  I don't think that's going
to be anytime soon, because obviously people do use it.  But the other side I
was coming at it is this.

So, I've been working on Stratum v2, trying to use the inter-process
communication (IPC), which I think you guys did an earlier episode on.  That's
part of the multiprocess project.  And originally, the multiprocess project.
And originally, the multiprocess project was meant to really split the node from
the GUI from the wallet, and then they would communicate to each other through a
fairly complicated interface, and that has been moving slowly.  Whereas as soon
as the idea came along of using it for mining, now we have a very simple, very
small interface, and that's making a lot more progress very quickly.  So, I was
thinking perhaps there's other applications that could benefit from a somewhat
simple interface.  So, perhaps, say, you want a Lightning interface.  And maybe
it wouldn't be called Lightning; maybe it could be eltoo, or something slightly
more generic than Lightning.  But basically, my idea was like, any applications
that's using ZMQ is probably interested in something that's performant, so might
actually also like IPC as an alternative.

So, yeah, the first step is to just get an inventory of which applications use
ZMQ period, and then you can kind of look through their source code as why
they're using it, and then perhaps you can design an interface and then tell
them, "Hey, why don't you try this interface?"  And then maybe in 50 years, we
can drop ZMQ.

**Mike Schmidt**: And I think the thrust of your question is substantial
projects or services, whether those are open-source or closed-source, you're
looking for those folks to raise their hand and maybe comment on how they're
using ZMQ, right?

**Sjors Provoost**: Yeah, and so in the case of open source, all I need is a
link and I can look at it later.  But in the case of closed source, yeah, I
guess you'll have to say what it's doing.

**Mike Schmidt**: All right, so listeners, if you're using ZMQ in your project,
check out that question from the Stack Exchange and add it to Sjors' list that
he's compiling there.

_Bitcoin Core #31603 _

We're going to take a quick tangent to the Notable code segment.  We have
Bitcoin Core #31603, a PR titled, "Descriptor: check whitespace in keys within
fragments".  Antoine, I saw that you were a reviewer on this PR and I'm curious,
why do we care about the white space here?

**Antoine Poinsot**: It's just not valid in the descriptor language and it was
accepted by Bitcoin Core.  So, Bruno noted that it was, I think, as part of his
differential fuzzing work, and set up to fix it by dissolving white spaces in
descriptors.  I think one interesting consideration for this PR is, well, is it
going to break anybody's wallet?  But it's not, it's going to prevent, so it's
going to be a slight break of the ops interface in that a descriptor with white
space adds very specific spots not anywhere, won't be accepted anymore by
Bitcoin Core.  But existing wallets, for which a descriptor containing a white
space was in input back when it was created, will still be compatible with
future versions of Bitcoin Core.  So, it's still entirely backward-compatible.
And it is because Bitcoin Core will serialize the descriptor to its database
itself.  It's not going to take the string that is given by the user, it's going
to take the string by the user, parse it into its internal representation, and
then when it wants to create the wallet database, it's going to serialize it
itself.  And Bitcoin Core will never serialize it with a white space.
Therefore, this is not a backward-incompatible change on this aspect.

**Mike Schmidt**: Excellent.  Antoine, Sjors, thank you both for joining us.  I
think we've wrapped up all the pieces that you all have contributed to in these
various places, so thank you both for joining us.

**Sjors Provoost**: Thanks for having us.

**Mike Schmidt**: Cheers.

**Antoine Poinsot**: Yeah, thanks for having me.

_How long does it take for a transaction to propagate through the network? _

**Mike Schmidt**: Jumping back to the Stack Exchange, we left off at, "How long
does it take for a transaction to propagate through the network?"  So, this is a
Bitcoin transaction going through the Bitcoin Network.  I think the question had
the thrust of like, "Can my node see how long it takes a transaction to
propagate", and Sergi points out that you would need many nodes observing the
network similar to probably what Chainalysis or other spy nodes are doing
currently, in order to do timing analysis on when the transaction is seen
between different nodes.  He also points to a website run by Decentralized
Systems and Network Services Research Group at KIT that is actually doing that
exact thing, and they have a series of graphs not just about transaction
propagation times, but there's other data that they've collected with their
observing nodes or spy nodes.  And so, we link to the website in the answer.
So, if you're curious, that might be one to bookmark for your Bitcoin resources.

Final note, to quote the answer here, "Transaction propagation times show that a
transaction takes about 7 seconds to reach half the network and about 17 seconds
to reach 90% of the network", based on that analysis from the KIT group.

**Mark Erhardt**: I wonder whether that's -- that's probably only listening
nodes, but it's not 100% clearly described here.  So, I'm wondering whether
non-listening nodes, so nodes that only form outbound connections, might
actually be a little slower still.  And, yeah, that's all.

_Utility of longterm fee estimation_

**Mike Schmidt**: Next question wasn't really a question.  It was titled,
"Utility of long-term fee estimation".  This is actually an older question that,
at the time, I didn't cover because there were no answers.  But I did want to do
similar to what we did with Sjors and his call out in looking for feedback from
the community.  Abubakar was seeking feedback from projects or protocols that
rely on long-term fee estimates for work that he has been doing and was doing on
fee estimation.  Murch, maybe as a fee estimation guru, you can help define what
is a long-term fee estimate, and why is the fee estimates that Bitcoin Core is
providing long-term, and how is that different from when I go on mempool.space
and look at feerates?

**Mark Erhardt**: Right.  So, Bitcoin Core collects the transactions that it
sees in its mempool and then later sees again in blocks, and it uses the
discrepancy, or the difference between the time when it first sees them to when
they are confirmed, to estimate how long it takes for transactions of certain
feerates to get confirmation.  From that data, it predicts feerates for certain
confirmation targets.  So, if you want to get a transaction confirmed within the
next five blocks, it calculates a high-confidence feerate that should get a
confirmation in five blocks.  And a Bitcoin Core node that has been running for
a while and has collected that data produces data for the targets between two
blocks and 1,002 blocks, I think, or maybe 1,028, slightly over 1,000.  And so,
1,000 blocks are about one week.  And so basically, it's trying to predict what
feerate with high confidence might enable you to get your transaction confirmed
within the next week.

The point of that is, of course, if you're trying to get a transaction through
paying the least possible fees, you might want to not use the minimum feerate
but something that actually gets confirmed within the next week somewhat
reliably.  All of these predictions are fraught with uncertainty, because
suddenly someone can start a new transaction trend or some politician makes a
great announcement and people get very excited and start trading more, and
within hours, feerates could be completely different.  But yeah, so Bitcoin Core
uses this historic data to predict up to one week in advance, and that's what a
long-term feerate estimate is.

How this compares to mempool.space, my understanding is that the mempool.space
feerate estimates are based on the content of mempool.space's mempool.  So,
whatever transactions they have currently in their own mempool, they chunk up
into blocks and see, okay, the next block will go down to feerate X, the second
X block will go down to feerate Y, and so forth, and uses that with some margin
as a prediction of what will be enough to be in that block.  So, yeah, Bitcoin
Core only uses historic data, mempool.space only uses the content of the
mempool, and both of them have some advantages and disadvantages.  Like one can
predict long-term out, if somewhat fraught with uncertainty; and the other one
tends to be more thrifty and more accurate in the short term, under the
assumption that the content of mempool.space's mempool is representative of
what's going to be in the next block.

**Mike Schmidt**: So, you have Bitcoin Core looking at historical, you have
mempool.space looking at current.  And I think there was even a period of time
during the ordinals and/or other JPEG craze where actually you could look
forward and kind of see.  Because I think some of these protocols or mints, or
however it was working, actually had block heights that it would be open for
minting, or however it works.  And so, you can actually have future-looking as
well.  But obviously that's a little bit more in the meatspace and harder to
quantify what that would actually be feerate-wise.  But thanks for elaborating
on that, Murch.

_Why are two anchor outputs are used in the LN?_

"Why are two anchor outputs used in the LN?"  Murch, I punted this one to you.
Why?

**Mark Erhardt**: Right.  So, when anchor outputs were first introduced, they
were meant as a fix against some of the pinning attacks, because they would
allow either of the two parties to bump either of the commitment transactions.
So, whether the other party closed the channel or you closed the channel, the
other party or you would be able to attach an output to that commitment
transaction in order to reprioritize it.  Obviously, having an extra output more
than necessary would lead to a bigger transaction.  There's also the problem
that some of these anchor outputs just never get spent and stick around in the
UTXO set.  So, overall, it's just a little inefficient.  It also wasn't
super-reliable, in some cases, at least instagibbs says that in his answer.

So, in the new approach that we will be able to do, now that we have the TRUC
(Topologically Restricted Until Confirmation) transactions, the opportunistic
two-transaction package relay, and now also the, what is it?  Ephemeral dust and
anchor outputs, we can have a single anchor output that is spendable by anyone,
including third parties, not just the two parties in the channel.  And we can
still ensure that there will only ever be one other transaction attached to the
commitment transaction.  We allow other transactions to override this
transaction in the package, due to sibling eviction.  And so, now we retain the
ability for either party to bump any of the two commitment transactions.  We
only have one output.  This output must be spent, because it's only permitted to
use them in this fashion when the parent transaction has zero fee.  And, yeah,
so we clean up our mess now.  Anyone can bump still the commitment transactions
and overall, transactions are smaller because the anchor outputs are minimal in
weight, and so TRUC transactions fixes this.

_Why are there no BIPs in the 2xx range?_

**Mike Schmidt**: "Why are there no BIPs in the 2xx range?"  Murch, as a BIP
editor, you probably already knew the answer to this, but I did not know this or
I had forgotten it, but Michael Folkson pointed out that all of the BIP numbers
in the 200 to 299 range were, at some point by Luke, reserved for LN-related
BIPs.  I guess the idea, Murch, was that the things that are BOLTs now would
actually be part of Bitcoin and they would be BIPs.  Do I have that right?

**Mark Erhardt**: Yeah, exactly.  So, the whole range between 200 and 299 is not
being used because it's designated for LN, and the idea was to eventually
migrate the BOLTs into BIPs.  And I consider this less likely to happen, but the
reservation still stands at this point.  But I consider this somewhat unlikely
because the BOLTs spec moves at a very different pace than BIPs, although BIPs
now move more quickly as well again; and the BOLTs spec is a living document, it
is constantly amended.  As new edge cases are discovered or unclarities are
discovered, the BOLTs spec gets updated to clarify, and people are expected to
implement the current BOLTs spec.  Whereas BIPs are author documents that get
written once and then, especially if they're final, are not supposed to be
amended in the content anymore.  Maybe in the phrasing but not in the meaning.

Yeah, so I'm not sure whether the LN specification process is inherently
compatible with the BIPs process, so maybe at some point we will reconsider what
we use those BIPs for.  But also, we still have plenty of BIP numbers to give
out, because the space was designated as having four numbers and we're under
600.  So, we have over 9,000 left, so we're not hard-pressed to get back those
100 numbers.

**Mike Schmidt**: Thanks for that, color, Murch.  The next two questions from
the Stack Exchange this month were both about BEC 32.

_Why doesn't Bech32 use the character b?_

"Why doesn't bech32 use the character, 'b'?"  And Bordalix answered this
question and noted the similarity between the letter B, if you think of the
capital letter B, and the number 8.  So, that was the rationale for not allowing
B in the address format.  Then there was also, I think he provided some
additional trivia around bech32.

_Bech32 error detection and correction reference implementation_

Then the second question, "Bech32 error detection and correction reference
implementation".  And Pieter Wuille jumped in on this one and noted that the
address format, bech32, can detect up to four errors when encoding an address,
and also correct two substitution errors.  Murch, are you familiar with this
correcting of substitution errors?

**Mark Erhardt**: Right.  So, the way the checksum works in bech32 allows you to
actually calculate the contribution of each letter to the checksum.  So, as long
as there's a very small number of errors, you can calculate back what position
was incorrect and how it was incorrect.  And I think the most important part in
that answer is the part where Pieter explains why we do not implement error
correction, only error detection.  And the problem is, if someone makes more
than the minimum number of errors, there might be a way to fix the address by
only making two fixes.  So, let's say you have six or seven errors and your
wallet software sees, "Oh, if I change these two letters, I get a valid
address", and fixes it, you might end up sending to an address that's actually
not held by anyone and your funds are lost.

So, what Bitcoin Core does, for that reason, is it will tell you that there are
errors and as long as it can tell where the errors are, it'll tell you to check
for specific positions and make the user check the source material, or ask back
with the sender, "Hey, I'm getting an error on this letter.  What is the correct
letter?" and that way you ensure that it is compared to the original document or
original address, rather than automatically fixing it, potentially incorrect.
So, you're guaranteed to detect up to four errors, you can locate up to two, and
you should not in any implementation ever automatically correct.

_How to safely spend/burn dust?_

**Mike Schmidt**: Thanks, Murch.  You answered this next question as well, "How
to safely spend/burn dust?"  And if I recall, the person asking this has these
dust outputs in their wallet, and instead of just leaving them, they want to
somehow clean them up and burn them in some capacity/get them out of their
wallet.  Is this something feasible, and what should you think about if you're
trying to do something like this?

**Mark Erhardt**: All right.  First, the mandatory pet peeve.  The term dust is
underspecified and used for different things.  Usually, it refers to a small
amount, but one that can be economically spendable.  So, the dust limit in
Bitcoin Core is actually three times the value of the cost of spending it at the
minimum feerate.  If you're talking about an uneconomic UTXO in the sense that
it cannot pay for its own transaction weight to spend it, then really you're out
of luck.  Because let's say you have a 1-satoshi UTXO, it'll never be able to
spend for its own input.  Therefore, you always have to bring other funds in
order to spend it.  Bringing other funds means that you crack open a second
UTXO, and you now combine in the transaction graph the address that you received
that UTXO to with the address that you received the dust to, and you get exactly
the outcome that whoever dusted you wanted, the forced address reuse in
combination with another address.  And now they know, well, whoever owned the
address that they dusted also owns this new address where you brought funds
from.

So, if you're looking at a generally uneconomic UTXO, do yourself a favor and
just mark it as 'ignore', like blacklisted, so your wallet will just never spend
it.  Maybe if we ever end up reducing the feerates, the minimum feerate to a
point that they become spendable, or there's another scheme how you can make
dust UTXOs go away, maybe un-blacklist them at that point.  But up to that
point, just ignore them, don't spend extra money in order to burn your dust,
because it's both a privacy loss and costs extra funds.

If you however have a bigger dust amount that is economic to spend, say a
400-sat UTXO for P2PKH, so P2PKH is 148 bytes in the input and 400 is under the
dust threshold but over 148 sats.  So, you could use that as an input and it
would carry its own weight in a minimum transaction relay fee transaction.  And
you could, for example, just get together with a bunch of other people and they
each contribute some of these barely economic to spend UTXOs, and then you burn
them together or you send them to one Bitcoin eater, or some other way of
getting rid of them.  And because the inputs now each carry their own weight,
you can get rid of it, you don't lose privacy in the sense that you're
misleading the common input ownership heuristic, because instead of combining it
with other inputs that you control, you combine it with inputs that other people
control.  Yeah, you could do that if it's slightly bigger.  If it's slightly
bigger, you can also just reap the remaining sats to yourself, but of course at
the loss of privacy if you spend it with another bigger UTXO, because you need
to create outputs that are at least the dust amount.  So, if your input was too
small and you deduct the input fee from that, you won't be able to create an
above-dust-threshold output just from that input.

So, yeah, pick your poison.  You might have a privacy loss, you might have to
spend additional funds in order to get rid of the dust, or you just mark it as
blacklisted and do not spend, and fine.

_How is the refund transaction in Asymmetric Revocable Commitments constructed?_

**Mike Schmidt**: "How is the refund transaction in Asymmetric Revocable
Commitments constructed?"  This question is specifically about the Mastering
Bitcoin book.  There is a chapter, I believe it was 14, where there's some
examples of commitment transactions in Mastering Bitcoin.  And so, this person
was pasting some of the example code, I believe, and then in the answer, Biel
walked through verbally what's going on in those examples to clarify for the
person asking the question.  I don't think it's worth jumping into those
examples, but it's a call to action for you all, if you're curious about that,
to take a look at the answer.  And that wraps up the Stack Exchange for this
month.

_Bitcoin Core 29.0rc2_

Moving to Releases and release candidates, we have Bitcoin Core 29.0rc2.  Last
week we had on Jan B, who walked through the Testing Guide, which is now linked
in the newsletter this week.  So, if you're curious about the Testing Guide, as
well as the RC's contents and features and changes, check out last week's
discussion.  Murch, anything to piggyback on last week's discussion about this
RC, other than, "Please test the RC"?  That is the purpose and intention of a
RC.

_LND 0.19.0-beta.rc1_

We have another release candidate, this is LND 0.19.0-beta.rc1, and it provides
a few different features that I'll highlight in this RC just so you know if
you're using them you can test them.  But this release provides LND with
additional channel backup features, initial quiescent support which is needed
for splicing, and a few RPC and CLI updates that you can test.  Also in the
newsletter, we noted and called out this new cooperative close feature, that we
will cover later in the newsletter, as something folks could also consider
testing.

_Eclair #3044_

Notable code and documentation changes.  We spoke about Bitcoin Core #31603
already with Antoine, so refer back if you've ended up in the middle of this
podcast.  So, we'll move to Eclair 3044, which removes transaction confirmation
scaling based on funding amount.  So, this was the number of confirmations in
Eclair for channel transactions to be considered safe from reorgs.  Previously,
Eclair scaled the number of required confirmations, based on the channel funding
amount.  So, a larger channel funding amount would require more confirmations,
but that doesn't work with things like splicing, and it's gameable in other ways
as well.  But specifically with splicing, the channel capacity can change
dramatically.  So, in this PR, Eclair is moving to a simpler model and are just
using a default of 8 confirmations for everything, which they believe is large
enough to protect against malicious reorgs.

_Eclair #3026_

Eclair #3026 titled, "Support P2TR Bitcoin wallet".  So, Eclair is adding some
support for P2TR addresses, making it compatible with Bitcoin Core wallets that
use P2TR by default.  And Eclair still uses P2WPKH scripts to send funds when a
channel is mutually closed.

_LDK #3649_

LDK #3649 adds the ability for an LDK node to pay a Lightning Service Provider
(LSP) using BOLT12 offers.  Previously, only BOLT11 invoices and onchain
payments were supported for paying an LSP.  This change is related to BLIP51,
which is also the LSPS1 spec for wallets to purchase a channel from an LSP
directly.  So, in addition, this PR in LDK implementing BOLT12 LSP support,
there's also an open PR to the BLIPs repository to update BLIP51 and add that
BOLT12 Lightning payment.  So, if you want to buy a channel, purchase a channel
from an LSP directly, you had BOLT11 in onchain; now you have BOLT12, at least
with LDK.  It's not in the BLIPs just yet, it's in open PR.

_LDK #3665_

LDK #3665 allows LDK to accept BOLT11 invoices that are up to 7,089 bytes in
size.  Previously, there was no max in LDK, but I believe it was a dependency
that started enforcing a default of 1,023 bytes, so for a very short period of
time there was a restriction after having no restriction.  And then, LDK decided
to just match LND's 7,089-byte limit.  As a note, neither Core Lightning (CLN)
nor Eclair have any limit, and LND chose that 7,089 limit because it's the max
number of bytes that can fit in a QR code.  But actually, that 7,089 is numeric
characters, as pointed out in the PR description, and if you include uppercase
alphanumeric characters, it would actually not be 7,000-something, it would be
4,296 as the limit.  But in the interest of compatibility, LDK went with what
LND did with that 7,089 limit on the size of the QR code.  Go ahead, Murch.

**Mark Erhardt**: I was just wondering, if they're increasing the limit already
from 1,023 bytes, why not choose the smaller, accurate limit if it's already an
increase by 4X?  There must have been someone that created a QR code that was
above that in order to exercise the reason to go with LND's limit.  Otherwise,
it would seem that everybody should just come down to 4,296.

**Mike Schmidt**: I think the PR noted that they were just going to do it in the
spirit of compatibility, as opposed to accuracy in terms of QR.  I suppose
there's ways to transmit these invoices that are not QR codes as well, so
perhaps that's part of it.

**Mark Erhardt**: Sure, but I wonder, are there even invoices that are this
large?  I guess with the blinded paths, you might get bigger invoices now, and
who knows?  I don't know.

**Mike Schmidt**: Yeah, I think an example in one of the PR comments or
somewhere that, yeah, blinded paths, along with moderately large, I think it's
description fields, or something like that, could result in a larger one.  Check
out the PR for the details on that.

_LND #8453, #9559, #9575, #9568, and #9610_

Another LND PR, #8453, #9559, #9575, #9568, and #9610, are all affiliated with
LNDs new feature that we mentioned earlier, the ability for either channel party
to bump the fee of a cooperative channel closing transaction using their own
funds and using RBF.  So, this PR removes the old approach, which was based on
negotiation between the channel peers, and one potentially had to convince the
other counterparty to pay for the fee bumps, and sometimes of course those
negotiations would fail.  So, there was a ton of code here, I was clicking into
the PR, there's a lot going on there.  That's our summary of it and it's now
available in that LND RC as well.

**Mark Erhardt**: The entire RBF bumping of commitment transactions of course is
relevant in the context of the switch to the flow with TRUC transactions and
anchors, because now there would be only a single output and it has to be
replaced.  The child has to be replaced in order to bump.  So, maybe, it seems
to me that this is related and work towards adopting these new mechanisms that
are hopefully coming to Lightning in general in the next year.

_BIPs #1792_

**Mike Schmidt**: BIPs #1792 is a language overhaul and cleanup for BIP119 CTV
(OP_CHECKTEMPLATEVERIFY).  Murch, resident BIP editor, anything interesting in
there?

**Mark Erhardt**: Yeah, so BIP119, CTV, has been discussed a lot lately again,
and this PR just sort of updates the examples to today's discussion and
clarifies a few things.  So, essentially it's just catching up the formal BIP
proposal to the state of the discussion today.

_BIPs #1782_

**Mike Schmidt**: And last PR this week, BIPs #1782, which is a reformatting of
the testnet for BIP, which is BIP94.  Murch, anything interesting in there
besides reformatting?

**Mark Erhardt**: No, it's entirely exactly the same specification.  The author
of this improvement just rewrote a few sections of BIP94, because they felt that
they were a little harder to parse than necessary, and made it more into a list
and a little more straightforward.  But the content is the same.  So, this is
just a clarification of BIP94, which specifies testnet4.

**Mike Schmidt**: Just in time, because my dog is barking.  Thanks to Antoine
and Sjors for joining us as special guests this week.  Murch, thanks as co-host,
and for all of you for listening.  We'll hear you next week. Cheers.

**Mark Erhardt**: Cheers, hear you next week.

{% include references.md %}
