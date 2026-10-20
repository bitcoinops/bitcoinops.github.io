---
title: 'Bitcoin Optech Newsletter #421 Recap Podcast'
permalink: /en/podcast/2026/09/08/
reference: /en/newsletters/2026/09/04/
name: 2026-09-08-recap
slug: 2026-09-08-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
average_gary, Erick Cestari, Conduition, and Greg Sanders to discuss
[Newsletter #421]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-8-10/431611742-44100-2-f30e10d4df64e.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome, everyone, to Bitcoin Optech Newsletter #421 Recap.
Today, we're going to be talking about silent payments for miner payouts; we
have a disclosure of a DoS vulnerability in Core Lightning (CLN; we have a
Conduition triple-header in the Changing consensus segment, talking about
DropKick, the SHRINCS draft BIP, and also some continued discussion on PQC
output type discussion/debate; and we also have an update from the BIP448
ecosystem, sort of several updates rolled into one; and then we have our
weekly Releases and Notable code segments.  This week, Murch, Gustavo and I
are joined by four guests.  We'll have them introduce themselves.
Average_gary?

**Average_gary**: Yeah, hello, average_gary, big participant in the Bitcoin
Veterans organization as a military veteran myself.  But over the past couple
of years, I've been working in the Bitcoin mining space doing software
development, and have been pretty active in the Stratumv2 (Sv2) community.
So, glad to be here.

**Mike Schmidt**: Great, thanks for joining.  Erick?

**Erick Cestari**: So, hello, my name is Erick Cestari and I'm a Vinteum
grantee, and I have been working on security on Bitcoin, especially on the LN
for two years.  And I'm one of the maintainers of bitcoinfuzz, and I've been
also contributing towards Smite, which is snapshot fuzzing for Lightning.

**Mike Schmidt**: Awesome, thanks for joining us.  Conduition?

**Conduition**: Hello, I'm Conduition, I'm a cryptographic engineer working on
various post-quantum research initiatives, and I'm funded by Brink.  Very glad
to be here talking about this stuff with you guys.

**Mike Schmidt**: Instagibbs?

**Greg Sanders**: Hi, I'm Greg or instagibbs, I work at Spiral.  I've been
splitting my time this year in half, six months, basically between security
work, including Project Loupe, assisting that effort, as well as putting
Lightning on Ark.  Just finished up a series of PRs for that.

_Using silent payments for miner payouts in coinbase transaction_

**Mike Schmidt**: Very cool.  We appreciate all of you joining and lending
your expertise to the discussion today.  For listeners, we're going to do the
News items in order, starting with, "Using silent payments for miner payouts
in the coinbase transaction".  Gary, maybe you can give us a little primer on
how these miner payouts are typically done, and then maybe we can do a quick
overview of silent payments, and then how you might marry the two, as you've
done in your write up here?

**Average_gary**: Yeah.  So, in Bitcoin mining, a mining pool is essentially
an accounting database.  It's counting hashrate and coming to a conclusion on
how much you're owed based on the hashrate that you contribute to the pool.
As far as I'm concerned, there's one exception to a single-address coinbase
payout, and that's OCEAN.  There might be some smaller pools that I'm unaware
of that do a similar thing.  But for as long as I've been working in mining,
it's always a single-address payout and a big old coinbase tag or a pool tag
on that, indicating who is being paid.  And then, after the fact, miners will
get paid out.  OCEAN, when they launched with their TIDES accounting schema,
started doing something a little more different.  And they actually pay out,
to the best of their ability, as many miners in that coinbase transaction as
possible.  There's obviously dust limitations when you get there.  There's
some nuance, because if you don't have enough, if you have a Bitaxe and you're
mining with a pool and you're not earning enough rewards, you can't really be
paid out in that coinbase, or it's not economically valid.  There's some
firmware limitations.  I think some of the Bitmain firmware was actually
limiting the coinbase size to a certain number of coinbase addresses that
could be paid out.  So, just generally speaking, across the broad mining
industry, you just see a single address, every coinbase.

For anyone listening that's unfamiliar, the coinbase is the first transaction
of a block.  It is the mining rewards that are paid out.  It is the block
subsidy, which is at 3.125 Bitcoin currently, that we'll have here in the next
however many thousands of blocks.  And then, you have the fees that also are
paid to the miner.  So, this is the way that the mining pool collects the
revenue that is gathered by doing the mining.  And we largely, in my opinion,
don't see any sort of novel or unique things or fun things, as I like to say,
done in the coinbase transaction.  There are some guardrails in the consensus
level for that.  You have a 100-block lock-in, so you can't spend a coinbase
within the first 100 blocks that it's mined.  You also have no inputs, which
is relevant to this silent payments coinbase.  The input itself is a
predefined sort of data structure.  There's no witness, it's all zeroed out.
There is just a scriptSig, and that scriptSig has a certain amount of data
that can be put in there, and it can sort of be whatever you want.  Part of
that is the nonce space that is rolled by the miners.  But the other part of
that is this pool signature that you'll see if you go look at a coinbase from,
let's say, Foundry, you'll see, "Foundry USA Pool #dropgold".  That's actually
part of the hex embedded into the scriptSig of the coinbase transaction on the
input side.

So, that's generally the mining space and coinbase transaction, everything
like that.  And my hope is, especially Sv2 being a lot more mature and robust,
we'll see more things like the OCEAN TIDES where you have multiple payouts in
a coinbase.  Or one of my crazy ideas that I've floated out there, which I
don't think is realizable, but what if you could splice or open a Lightning
channel in a coinbase transaction, or just generally do anything sort of fun
or novel within a coinbase transaction, instead of paying to just a single
static address?  That led to me doing some experimentation.  It was relatively
easy to give it an xpub to the pool and have that pool rotate an address every
block that it hit.  I have several testnet4 demonstration blocks and a short
writeup on that.  But as I've been thinking through some of these things, I
wanted to try to imagine what it would look like to have even more sort of
dynamic coinbase payouts.  And that led to me doing a writeup on silent
payment coinbase.

You could have a miner provide an xpub, and then you as a pool could rotate to
a new address index for every block.  That's great.  But if you're trying to
do that for privacy purposes, which there's privacy purposes to rotating
addresses, there's also the post-quantum risk you have of exposing a public
key when you spend from a static address that you're reusing over and over
again.  So, to further mitigate those concerns, you could rotate address every
time.  But if you're seeking privacy on that front, having an xpub in the
hands of a pool, if that data is compromised, you have no real guarantees
there that your privacy is going to be preserved.  And so, I was trying to
think of fun, novel, cryptographic ways that you could have some identifiable
information be provided by the miner.  And the reality of this is you have to
have some identifiable information because it's an accounting database.  You
need some sort of key in that database for how much hashrate is being
provided.  So that way, fair and equitable payments can be made by the pool
itself.  And yeah, just sort of occurred to me that silent payments is one
such way where you have publicly published information that is used to then
derive a payable address for the sender.

In a regular silent payment, and forgive me, I'm not super-savvy on this, but
I did do some digging, a regular silent payment, you have your silent payment
information, there's actually two parts of that.  There's the send key and the
spend key.  The send key is the key that you're going to scan the blockchain.
You're going to use that in this elliptic curve, Diffie-Hellman sort of
process, to figure out which addresses actually belong to you.  So, there's
some computation on the receiver side that is needed for you to go figure out
which addresses you've been paid into.  And then, the spend key allows you to
then spend out of that Bitcoin Script.  When you're sending a silent payment,
you take this published information of the receiver and you combine it with
some of the public key information from the inputs on the transaction side.
And this is where the deviation comes from in this coinbase proposal, because
there is no input on a coinbase, or there is a well-defined input that you
really have finite rails; you can't just put whatever.  You have to have the
nSequence of a certain type, you have to have no witness in there, and you
really only have this scriptSig to play with.  But that scriptSig has plenty
of bytes, in my estimation, to put a public key, which is again, when you're
spending on a silent payment, you're exposing a public key on the inputs, that
public key is then used by the receivers to scan and do the computation to
check if that address actually belongs to them, if they are able to spend that
one, or if it's using their send key of that pairing to receive.  So, without
an input key or a pubkey using the input, you have to put that data somewhere
else.

You also want to have, it's referred to, I believe, as like a nonce in this to
make sure there's no grinding that a malicious sender could use to sort of do
some cryptographic trickery to make somebody reuse an address or to dox the
privacy of a recipient.  And so, in the proposal that I wrote up, you take the
block height, which is already part of every single block.  I think it's
BIP34.  It requires it to be, in every block, a couple of bytes.  And so, you
can use that as a concatenated hash with the public sending key of the pool,
and now that becomes part of the scanning.  The scanning is further reduced
because instead of having to scan every single transaction, every single
block, if you are a silent payments coinbase receiver, you just have to look
at the first block.  And you only have to look at the one that is from the
pool that you're mining with, right?  And so, there is data available there to
sort of get to this, but the public key that a sender would normally publish
on the inputs of the transaction now becomes part of that scriptSig.  It's
more commonly referred to as the pool tag, right?  So, instead of putting,
"Foundry USA #dropgold", you would input 34 bytes of a public key that all the
receivers could then use in this silent payments dance to figure out which
addresses are them.  And then, that creates, I guess, a privacy threat vector
or a trade-off, we'll say, of while the pool is doing its accounting, it has
to keep track of which silent payment address has what amount of hashrate.
But as the blocks mature and you go beyond a window of time, you can start to
age off that data.  So, you have a very finite window of time where your
privacy trade-off is, the pool, in its current state has knowledge of a silent
payment address correlated to a hashrate amount.  But you have a time box
here, because you don't necessarily need to retain historical logs for pool
accounting purposes if they've already been paid out.

So, in the proposal, it's not a formal specification by any means, but in the
proposal, I made the assumption that it would be an ephemeral key.  And again,
there's no funds at risk here from the pool side.  It is just using this
Diffie-Hellman Key Exchange to derive who's receiving what.  And so, the pool
could generate an ephemeral key every block to use in the block template that
it passes down to the miners to do this silent payment coinbase paradigm.  And
I hope that was sufficiently clear and not too opaque.

**Mike Schmidt**: Gary, this is the point in the show where usually Murch
comes in to translate for the audience.  But I thought you did a great job.
So, we'll see.  Maybe Murch could jump right to questions.  Murch, what do you
think?

**Mark Erhardt**: I can do my thing, though.  I mean, so yes, silent payments
usually create a shared secret between the keys of the inputs and the
recipients.  So, the coinbase transaction, or the coinbase field in the input
does not contain a key.  And therefore, you have this idea to put a public key
there instead of the pool tag.  That sounds all okay to me, especially the
idea of putting the height in there to make sure that the outputs are always
unique.  Because, yeah, if you were using the same key to create the shared
secret with the same recipient key, you'd always get the same output script.
And that's exactly the point of silent payments, what it's trying to avoid.
So, at first glance, that sounds all good to me.

I was wondering a little more about the trade-offs here.  So, the big
advantage is, of course, that you get to write the rewards of the pool
participants to the blockchain directly, and then you can forget the data, as
you mentioned, maybe ten blocks later or something.  And the trade-off, of
course, is that you're giving away blockspace for paying out your pool
participants that you can't fill with other transactions.  So, if the feerates
are very high right now, you're sort of sending the payments at the current
feerate, displacing potentially juicy transactions.  But it is pretty
space-efficient because it costs you only an output, not a whole transaction
to pay.  Yeah, and otherwise, you'd have to wait for the output to mature
before you could spend it again.  So, you'd have to store the data for at
least 100 blocks more, so about two-thirds of a day.  Sounds like a reasonable
idea.  I think it's pretty cool.

**Mike Schmidt**: Conduition?

**Conduition**: Hey, Gary, thanks for sharing, it's really interesting.  I
have a couple of questions, actually.  The first one is, could you contrast
this protocol with what miners currently do?

**Average_gary**: Yeah.  So, currently, as I said, a lot of the bigger pools
just have a single coinbase address output.  The one pool that I know that
does not, which is OCEAN, uses something called TIDES.  It's a version if
you're unfamiliar with the accounting space of mining, which many people are,
but you have something called PPLNS or Pay Per Last N Shares, and that N is
this sort of sliding window, specifically in the OCEAN TIDES mechanism.
There's a sliding window; the window is as big as the difficulty, I think x8
or some multiple of 8, but you sort of define the window of which you're going
to get paid within.  But then, a lot of pools are using something called FPPS
or Full Pay Per Share, where it's not really the number of shares that you
have, it's like a fixed rate per individual share.  And then you, as a miner,
get to go into your account and tell the pool when you want to get paid out.
So, it goes to a single coinbase address and you have a single address that's
paid into.  And then as miners exit, either on a periodic schedule or on
demand, they get paid out in a normal Bitcoin transaction.  Some of the pools,
I think Braiins, as well as OCEAN, also offer Lightning payouts.  So, if you
are a miner that maybe doesn't warrant a huge, juicy UTXO, you can get paid
these smaller amounts over Lightning.  I kind of left that out of the scope of
this proposal, just because it's sort of an orthogonal concern.  But it does
acknowledge that there's only so many space and you don't really want to pay
dust transactions in the coinbase, or in general at all.

So, the contrast is right now we have single addresses.  And OCEAN, even
though they are doing multiple-address payouts in a block, there's multiple
paid out addresses in each coinbase transaction that OCEAN wins, it's still a
static address, right?  So, the way that you sign up for an account, there's
no login or anything like that, but you provide in the username of the Stratum
field, and this works on Stratum v1, is the protocol that they support right
now.  They recently announced some interest in Stratum v2 (Sv2), so I imagine
it will work the same.  But your username as a Stratum miner is your Bitcoin
address.  And so, they're using that as the database key.  That is a single
static address that if you're a hashrate provider, you could go in and maybe
automate across your entire fleet of miners to update that, but not
necessarily a risk.  Every time you go to touch a miner and change something
about it, if the firmware is not cooperative, it could completely restart
mining.  You could have some introduced risks.  Anytime you're changing
payment-related information, you want to be very, very cautious.  And so, by
changing your Bitcoin address on the fly as a miner, you already have an
entire mining site to manage.  You don't necessarily want to keep track or
manage this one individual piece.

So, I still wanted to have a static identifier that a miner could provide,
because that's sort of what they're used to right now.  Even in the OCEAN
sense, it's just a single Bitcoin address that gets paid out.  So, having that
was important because once you set your mining equipment, most operators do
not want to touch it again, right?  You set it and forget it until there's a
problem, because it just sits there and it does its hashes over and over
again.  So, I guess to contrast this would have (1) dynamic coinbase
allocation on the output side of it, so very similar to what OCEAN is doing,
which is just non-existent anywhere else; and then (2) would have this privacy
trade-off where it's not the same address over and over.  You can go to
OCEAN's site right now and you can look at their top hashers based on the
Bitcoin address.  You can go see how much hashrate those providers are using.
The pool, in the silent payment coinbase scenario, could publish this data
publicly, but they don't have to, and it would probably be detrimental to the
trade-offs that the pool would be providing because it would compromise some
of the privacy.

So, it does create, as with anything, when you're involving privacy, there's
some opaqueness that gets into making sure the accounting is done correct.
That's a tricky problem in the pool space because you inherently have to
expose some information, some identifiable information to the pool in order to
have them account accurately.  And then, when you trust the pool to do this
accounting for you, it's very difficult to perhaps audit it.  You know, is the
pool inventing hashrate to sort of debase your reward or not?  And I don't
know if that's an actual solved problem, and these are sort of theoretical.
But the current paradigm is single address in the coinbase output, or in the
case of OCEAN, you have multiple outputs.  So, this would be similar to
OCEAN's multiple output payments, but would introduce what I believe something
that is a little more private.  Does that answer your question?

**Conduition**: Yeah, totally.  Thank you.  Second question is when miners are
executing these payouts, typically I'm assuming they would be paying to either
P2PKH or P2WPKH addresses.  Each of those have a scriptPubKey of about 21
bytes.  But if we're paying to taproot, those actually have a longer
scriptPubKey, 34 bytes, I think.  Or no, 22 bytes, I think, for P2PKH types.
No, 34 bytes for P2TR (pay-to-taproot).  Murch, am I on point here?

**Mark Erhardt**: Are you talking about the script size or the output size in
total?

**Conduition**: The output scriptPubKey.

**Mark Erhardt**: The script size, okay.  So, the amount is 8 bytes and the
length of it is 1 byte.  So, that leaves 22 for P2TR and 25 for P2PKH.

**Conduition**: Isn't P2TR a 32-byte public key plus some extra prefixings?

**Mark Erhardt**: Sorry, I was mixing it up with P2WPKH.  Yes, you're right.
It's 34 for P2TR.  Yeah, 22 for P2WPKH.  Yes, sorry.

**Conduition**: So, my question is that if you extend the size of the
scriptPubKeys that you're putting into these coinbase transactions, does that
affect the math on the miners' accounting side?  Do they have to decrease the
size of their payouts to account for that?

**Average_gary**: No, it just consumes blockspace, so you might not be able to
stuff as many transactions into a single block, which does remind me of one
sort of interesting note.  Again, OCEAN with their DATUM and Sv2 with their
job declaration, allowing miners to craft a template themselves, that's not
quite fully fleshed out in this proposal.  But the trade-off is just size,
right?  The coinbase is a transaction just like any other transaction in a
block.  It just happens to be, it's always the first one and has some special
parameters around the input.  On the output side, you could, I believe
theoretically, to my understanding, and I'm not a consensus expert by any
means, but you could have an entire block of outputs on the coinbase, is
theoretically possible, as long as it's consensus-valid.  Would you want to do
that?  Maybe right now with 3.125 as a guaranteed block subsidy, but as we
move into fees-based mining rewards in the next few epochs of Bitcoin mining,
that becomes a lot more relevant.  So, yes, it's not any different than, I
guess, any other block-stuffing consideration where you are going to have it,
you will have a size constraint there, and every transaction output that you
include is however many less bytes that you could include in the block
template itself.  So, it would probably push out some lower-fee transactions
if you have a lot of payouts.  Go ahead, Murch.

**Mark Erhardt**: Yeah, I mean, the trade-off Murch.  Yeah, I mean the
trade-off is just to pay the mining pool participant later or in the coinbase
directly.  If you're paying more often, that will take more blockspace.  But
otherwise, paying later actually takes more blockspace, because you need to do
a whole other transaction where you add the inputs and the transaction header.
But other than that, whether the output is on the coinbase transaction or on a
later payout transaction is basically the same.  If you pay to P2WPKH, sure,
it would be 31 bytes.  If you pay to P2TR, it's 43 bytes, so it's 12 bytes
more.  But on a block size limit of -- okay, so outputs are non-witness data,
so it's 12 vbytes, right?  Sure, that's part of the block budget, but that's
what it is.

**Average_gary**: I think one of the other things to consider here is, you
asked about is it any impact to the payouts for a miner, a hashrate provider?
That is going to be totally up to the accounting done on the pool side, right?
You have to kind of separate out the coinbase outputs and how you arrive at
what those payments look like with the actual mechanism that you arrive at,
right?  So, there's some algorithm that you're going to put in all of the
inputs, the amount of hashrate, who's getting paid, etc, and then you have
some output.  The block transaction size and the amount of data in there is
completely orthogonal to how you arrive at that weighting, right?  So, you
could have some way that, and I've seen this, the demand pool, DMND, had a
somewhat novel payout schema where they do your standard PPLNS, so however
much hashrate you're getting; they do that for the block subsidy.  But on the
fee side of it, because they are supporting job declaration or they're
allowing miners to create their own block templates, they are doing something
called SLICE.  And don't ask me what it stands for, it's been a while since
I've reviewed it, but they're essentially taking the fees and weighting those
based on your block template.

So, if Murch and I are mining together on the same pool that's using the SLICE
paradigm and Murch has fat, juicy blocks full of high-paying fees, and for
whatever reason I have a handful of fees in my block because I choose not to
include those transactions, their accounting mechanism actually weights our
block templates differently solely on the fee side.  So, we get rewarded on
the block subsidy side in this PPLNS-JD schema, the SLICE schema; we get
rewarded the same on the subsidy side based on just our hashrate.  But then,
when it comes to paying out the fees and the weighting of how much we get paid
out, the block template generation is sort of considered there in the waiting.
Does that make sense?

**Conduition**: Interesting.  I did not know that, thank you.

**Mark Erhardt**: I also saw that Erick had his hand up.  Did you want to say
something?

**Erick Cestari**: No, thanks.

**Mark Erhardt**: Oh, never mind then, sorry!  Yeah, back to Mike.

**Mike Schmidt**: Yeah, Gary, we sort of had some feedback questions for you
here in the show.  What has feedback been to the post or anything that you've
gotten offline about the idea?

**Average_gary**: Yeah, the post has had just a couple of comments in there,
nothing that, I guess, changed my thesis or my idea radically.  And then, just
tangentially, having maybe asked one-on-one with a handful of people that I
know have some hashrate, privacy or at least having payout in the coinbase is
something desired.  I think some of that was obvious with a lot of hashrate
moving to OCEAN; not a lot, but a decent amount of hashrate moving to OCEAN.
There are people out there that don't necessarily want to go through the
signup process and registering an email and having all this account.  They
just want to put a static identifier in their hashrate and they want to focus
on mining operations, which is where they really eke out the profits in their
operations.  So, just from a very, very small subset of n, there are people
that would appreciate this.  When you introduce privacy considerations though,
there are a certain subset of people though that kind of shy away from that
and might not appreciate that.  So, it seems to have been received somewhat
well, but I haven't gotten too many comments or critiques.

If you know anybody, especially somebody that is very, very knowledgeable on
the silent payment side of things, I would appreciate just a technical review
of the proposal just to make sure there's not any kind of gotcha on how you
might compromise the privacy of the receivers, outside of what I've already
documented.

**Mike Schmidt**: Gary, thanks for your time, thanks for joining us.  You're
welcome to hang on for the rest of the newsletter, or we understand if you
have other things to do and you need to drop.

**Average_gary**: Thanks for having me, Mike, and it was a pleasure chatting
with you all.  And I will drop, so have an above-average day.

_Responsible disclosure of a denial-of-service vulnerability in CLN_

**Mike Schmidt**: Cheers.  Next news item, "Responsible disclosure of a
denial-of-service vulnerability in CLN". Erick, you disclosed a critical DoS
vulnerability affecting CLN versions before 25.09.  Maybe you can give us the
high level on what you found, what could possibly happen, and maybe even how
you found it.

**Erick Cestari**: Yeah, sure.  So basically, I found this one because I was
studying how BOLT8 works, which is basically the transport layer on Lightning,
where you can do the handshake and have the encryption connection, and also
make an authentication so the peer knows who it's connecting to the node.  So,
I was doing and creating this BOLT8 code, which is basically a Noise protocol.
And when I started doing it, I started to point out some nodes and also
testing locally.  So, I made some docker and using some containers to connect
to those nodes, and started sending a lot of ping messages without reading
from TCP connection.  So, normal people would not do that because they want to
send message and have the exchange of the init message, which is the first
message on the LN which you need to exchange to announce feature bits.  And I
started sending a lot of those ping messages and not reading nothing from the
TCP connection.  So, the peers in the other side need to somehow stop reading
our message or drop the pong message.

So, I tested it with CLN, LND and all the Lightning nodes.  And with CLN, it
suddenly crashed the nodes and started to use all the memory.  And the reason
is basically because CLN uses a lot of process.  So, it first has the main
one, which the lightningd and starting to create others daemons, they call it,
which is basically a process which they can talk to each other using IPC.  So,
the main process that listens for connections on CLN is connectd, and the
connectd listens for all the peer messages.  So, it listens for the message
and then it writes for other daemons.  So, there is gossip daemons, there is
closingd, openingd.  So, if you're sending an openchannel message, it's going
to take that openchannel message and send to these different daemons.  And the
problem was that basically, there are some messages that connectd doesn't need
to send to other processes because it's going to handle locally, which is
basically the ping and pong message and some of the gossip messages.  And when
the connectd received the ping message, for example, it needs to send a pong
to that peer.  But with the pong message, it didn't stop reading the
connections.  So, it would try to send the message, put in the outgoing queue,
and continue reading from the TCP connection.  So, it started like pushing
message, adding message to a queue, and not being able to send because the
peer is not reading the message, and started increasing the memory usage
because it's not being able to send that message and free the queue.  So, it
would die by out-of-memory (OOM).

**Mike Schmidt**: Okay.  So, it sounds like you wouldn't even need a channel
for this.  An attacker could potentially send these messages, pretend or
actually not get the reply.  And does the sender of a ping also get to set how
big the reply should be, so you actually could end up requesting larger-size
pongs and then not read them in order to fill up that queue?  And I guess, as
you said, then eventually that would DoS the node to the point where it would
actually run out of memory and crash?

**Mark Erhardt**: You're muted, Erick.

**Erick Cestari**: Sorry!  You could actually take down all the nodes in the
network that are using CLN, because you just need to open a connection, do the
handshake of the Noise protocol, exchange init message, and then you can
already send a flood of ping messages and stop reading from the TCP
connection, then the attack is done.

**Mark Erhardt**: So, from what I understand, the attacker needs a large
amount of RAM though, because they first fill their in buffer first before
they fill the out buffer of the other side.  And then, from what I understand,
it was some plugin, right?  The plugin wasn't checking for the queue size or
the pong buildup.  So, the attacker would ping the victim, tell the victim to
return a very large pong.  The pong would then arrive at the attacker, the
attacker would not read it, leave it on unread and fill up its own in buffer.
And then once the in buffer was full, the out buffer would start to fill from
the victim.  And there was no limit on the out buffer on the victim side, and
it would eventually run out of memory and crash.  Yeah, that's pretty mean.

**Erick Cestari**: You don't need much memory, because you can actually
configure when you're opening the TCP connection how much inbound buffer you
want, and how much you have the outbound buffer.  So, you could actually put
some small size.  So, when the peer tries to send a pong message, we're almost
full with just one pong message.  So, the attacker would only need to start
spamming and on the CLN side, it doesn't use a plugin.  Since it answers
locally inside the daemon, it's more like an event loop where it needs to
signal to start reading a new message.  And how it worked before, it would not
signal anything, but it would call a function to start reading now without
having to stop from reading from the buffer, from the TCP connection.

**Mark Erhardt**: So, basically it has actually no problem whatsoever on the
attacker side, no restrictions, you can just basically remotely crash CLN.
That's pretty rough.

**Mike Schmidt**: Erick, maybe folks have the CLN embargoed release in their
mind and then they see you coming on the show here.  What you've done has
happened quite a bit in the past, right?  This is not related to the embargoed
release?

**Erick Cestari**: Yeah, it's more than a year.  Actually, I could have made
this responsible public way before, but I had just time for it now.  But it's
safer for a long time already.  So, it's not related.

**Mike Schmidt**: Erick, we appreciate your time.  Anything else folks should
know before we wrap up this news item?

**Erick Cestari**: No, thanks so much.  Thanks to Vinteum to sponsor my work.
Thanks for having me.

**Mike Schmidt**: Cheers.  Thanks, Erick.  Erick, actually one more thing
before you go, and maybe Gustavo can correct me on this if I'm wrong, but I
did see we had LND #11090, which is ping rate limits and gossip decoding
fixes.  And I'm wondering maybe, I don't know, Erick, if you've had a chance
to look at that or, Gustavo, obviously you have, you summarized it.  Is that
somewhat related to this disclosure or just coincidental?

**Gustavo Flores Echaiz**: It seems related to me.  Probably, they saw this
disclosure and rushed to fix similar limitations on their end, because the
peer control resource growth is the same here that would affect CLN and the
disclosed DoS vulnerability.  What do you think, Erick?

**Erick Cestari**: Yeah, I've tested, like, one year ago with all the LN
implementations and only CLN was the most vulnerable one.  The others would
increase a bit of memory.  So, I believe what LND is doing is just trying to
avoid getting so many messages from the ping side.  And also, usually when the
attacker stops reading from the TCP buffer, TCP connection, the node would
notice that, because the node would probably try to send some ping message and
never receive the pong.  So, this attack is limited to some minutes, because
the node would stop the connection because it did not receive the pong
message.

**Mike Schmidt**: Anything else to add there, Gustavo?  All right, thanks
again, Erick, for your time.  We appreciate it.  We're going to jump to the
changing consensus segment and go a little bit out of order.

_BIP448 and CSFS/CTV demos and applications_

We have the item that involves BIP448 CSFS (CHECKSIGFROMSTACK)/CTV
(CHECKTEMPLATEVERIFY) demos and applications.  We're pulling this one a little
bit out of order since we have instagibbs here, who joined us back in
Newsletter #397, back when I think it was BIP446 and 448 were freshly
published drafts.  And since then, there's been some steady progress,
including Inquisition activation, so that'll be on signet; there's been some
Ark demonstrations that we've covered in some of our segments; and then, we
sort of did a roundup this week of some, I guess, developments of what's
becoming a genuine ecosystem of proof of concepts (PoCs) and demos.  But
maybe, Greg, you can maybe give us an overview of what we've covered in the
newsletter this week, but also what you think would be important for people to
know, talk about the GitHub organization, etc?

**Greg Sanders**: Right.  So, I haven't looked super-recently with this, but
the kind of overarching desire is to prove out this set of primitives,
including things that would be hopefully production-ready if it were to go and
be activated.  So, rather than have like with taproot, where activation
happened and then it took multiple years for things to actually use it, our
hope, like Antoine, Steven, my hope would be that there'd be a set of things
already proven out in real usage, or real on signet usage, with mature coding
code stacks that exercise this behaviour.  So, there's stuff that Antoine and
others have been working on, like miniscript PSBT integration, so making sure
that all the building blocks that wallets build off of have things built in to
use those directly.  So, imagine you're doing a Lightning wallet and Lightning
would want to update the BOLT specifications.  You'd have to propagate all
those changes through the whole stack, including wallet descriptors,
miniscript, PSBTs, and probably more of that as well.  There's also other
projects like a revival of my old LN-Symmetry work.  I think a couple of
people are looking at that using OP_TEMPLATEHASH and related.

I've also been working on, well, Steven is the CEO of Second Tech, which is
the Ark implementation called Bark, and they have a working demo where you
swap out this tree presigning ceremony with these commitments to next
transactions.  And I mentioned earlier in the intro that I've been working on
Lightning on Ark, and that was also motivated by that.  So, with this ceremony
swap-out, you can go from partial security, kind of a statechain-like
security, to full security, with none of the kind of wallet layers or protocol
layers really having to pay attention to it, except for that specific piece
being swapped out.  There's also some work by Ademan talking about putting
things at state to mitigate some of the issues with statechains.  He proposes
it in the view of Lightning on Ark, but I think it's more broadly applicable.
And so, he goes through some of the game theory and mechanics of what a
non-equivocation bond would look like, to make sure that operators can't
freely equivocate on statechain-like payments.  And I'll pause there.

**Mike Schmidt**: Greg, is this just a bunch of volunteers coming forth and
putting these together?  Is there sort of a bounty system or issues on the
GitHub org, where there's sort of up-for-grabs kind of things that people can
do with these PoCs; or is it just people publishing things and you collecting
them in the repository or the org?

**Greg Sanders**: So, a number of these things were kind of thought about and
put on just a GitHub list long ago, where the main authors of the proposal
were wondering what would be a compelling demonstration of actual uses, and
where would these huge latencies in actually deploying it show up?  And that's
where all the tooling came about.  But it's pretty asynchronous, right?
There's no bounties or anything like that.  It's just interested parties
wanting to see what the integration would look like in modern-day Bitcoin tech
stacks and how they can use it.

**Mike Schmidt**: Murch or our other guests or Gustavo, any questions for
Greg, things we should tease out?

**Mark Erhardt**: Yeah, Greg, so you've been looking at ANYPREVOUT (APO) for a
long time and have been working on LN-Symmetry, obviously, as the application
for it.  How big of a change would that be to the BOLT spec to support
LN-Symmetry?

**Greg Sanders**: From, you mean, the difference in BOLT spec between APO to
TEMPLATEHASH for LN-Symmetry, or from BOLTs today to LN-Symmetry post the
addition of something?

**Mark Erhardt**: The latter.

**Greg Sanders**: It would be pretty significant.  There are some things that
don't change.  So, the P2P message stuff doesn't change that much.  You'll
have related messages, the protocol is a lot simpler than today's Lightning.
So, I think the spec would be about half the size of today's spec, but there's
a lot of stuff that doesn't reduce complexity, right?  So, you have onion
messaging, and top of my head, a lot of the stuff wouldn't change too much or
simplify too much, but the core mechanics would be a lot simpler.  BOLT3,
which is the Bitcoin transaction-like specifics, that would be a lot smaller
potentially.  Well, it is smaller based on my previous drafts.  Well, it's a
large change.

**Mark Erhardt**: Well, there would first probably be some transition period
where both is allowed, right?  So, at first it would get a little bigger, but
if then everyone used only LN-Symmetry, it would get smaller?

**Greg Sanders**: Correct.  And so, that's one hurdle you'd have because
basically, I think there'd have to be buy-in to get it into the spec as that
notion that someday it would replace the original spec.

**Mark Erhardt**: It looks like there are a bunch of projects that are working
on PoCs or on applications for re-bindable signatures.  What is your plan?
How are you trying to move this forward?  I know there's a Signal group where
people have been sort of collaborating on these PoCs and exchanging thoughts,
but other than that, what's the idea?

**Greg Sanders**: That's a great question.  I think I've been a little
distracted lately with the security crisis we've had in the space.  So, I
think it has made me think more about what value would that bring in that
respect, right?  And I think the main one would be circling back to what are
the ways we can simplify what we already have out there.  Obviously, some
things would not be fixed by this.  It doesn't solve key management or key
generation, anything like that.  Well, okay, it doesn't solve onchain key
management or not.  It would solve things like the signing ceremony, people
promising to delete keys; a lot of that stuff can go away.  And protocols just
become a lot simpler, a lot of these protocols.  And with Lightning, that's
pretty pertinent, I would say.

**Mark Erhardt**: Yeah, as the saying goes, "Complexity is the enemy of
security", so simpler does sound good.  But for example, I guess some
platforms could introduce a vault-like construction and get reactive security
if people make the extra lift to make that work.  That might help with large
breaches because you have two different sets of wallets in the loop.

**Greg Sanders**: Yeah, the use case I'm most excited about is trying to
increase the ability for people to make payments.  And so, that's where my
work on Lightning and Ark has come into play.  But there's a whole swath of
potential things you can look at.  And I'd encourage anyone in the age of
generative AI, like LLMs, you really don't need permission to build this out
to a kind of at least end-to-end at a PoC stage, it's so easy.  And so, the
idea is the hard part, execution not so much, at least for this level.
Getting these new systems to secure against adversaries, that's an ongoing
discussion that the whole community is having.  But that extends to any layer
1, layer 2 system we have.

**Mark Erhardt**: Also, it's very easy to test now with it coming live on
Inquisition, thereby on the default signet.

**Greg Sanders**: Right, yeah.  Me or someone will definitely be launching a
number of things on there to test out what we've been working on.  So, that is
in the cards.

**Mark Erhardt**: Conduition?

**Conduition**: Hey, thank you.  I just wanted to ask what you think the
biggest next hurdles are going to be for activating these feature-rich
opcodes.

**Greg Sanders**: So, I still think, well, we've had a recent split in the
community, which might change the calculus a bit.  But one, I don't think
we've convinced everyone that this is the right stopping point.  So, I believe
it's Antoine's email -- we collaborated, so I kind of forget who did what --
wrote an email basically saying, "Here's our argument for why what is now
called BIP448 is a good stopping point".  Because there are other stopping
points you could do, right?  And so, one would be like, "Why not TXHASH?"  So,
take CTV or TEMPLATEHASH and then make it programmable.  So, have a bit field
and then you can select any sort of operation, any sort of fields in
combinations, and then you can do slightly more interesting things with them.
So, our argument is that the enabled use cases and abilities are not that
interesting compared to the relative complexity you get.  But then, you can
ask like, "Why not go all the way to ZKPs?"  There's this whole spectrum here.
And so, I don't think we've convinced everyone necessary that this is a good
stopping point, from conversations I've had.  So, I think that's one big
hurdle.  But that doesn't preclude us from building out the alternative track,
which is, "Okay, we think these capabilities are important and we've convinced
everyone.  Does this actually fit the bill or should we be doing something
else?"  And so, these can be answered, like worked on simultaneously.

**Conduition**: Thank you.

**Mike Schmidt**: Greg, have there been any lessons learned from, I guess,
this has been going on for several months and there's been some tooling and
there's some of these PoCs; has any of that informed the BIPs or the approach?
Or I guess the alternative flipside to that question is, is it confirming the
approach in the BIPs?

**Greg Sanders**: So, I think the PoCs have been mostly not surprising,
because we have a rich wealth of data from CTV, and CSFS itself is not new.
So, like, it's pretty well-understood at this point.  I do think it's been
interesting seeing people working on it and then realizing what the
limitations and trade-offs are.  So, one, if you did APO, one of the benefits
could be that it allows you to do the sighash flags, which allows you to do
batching.  So, if you could imagine on Symmetry, you want to batch, confirm a
bunch of HTLCs (Hash Time Locked Contracts) in the success direction, you can
do that with SIGHASH_SINGLE|SIGHASH_ANYONECANPAY.  With TEMPLATEHASH, that's
not available.  It's a fixed kind of SIGHASH_ALL style transaction hash.  And
so, you have to grapple with the fact that Lightning today, in certain
circumstances, is more efficient than would be enabled with TEMPLATEHASH.  And
you have to just kind of grapple with, is that important, how important is it,
and reason to that.  I've seen people work through things like that, and it's
been interesting.  I realized it a long time ago, working on LN-symmetry, but
it's more like propagating this information, and so people don't have
misconceptions of what the proposal enables.

**Mike Schmidt**: Makes sense.  Any other learnings on either side of the
equation do you think are notable for the audience?

**Greg Sanders**: I think it's interesting seeing how far you can go with just
these changes.  So, I was spending my last, since January, I was starting up.
So, I guess it's almost been nine months, the LN and Ark thing.  And so, it's
really been interesting working on a codebase like Bark that would slot in so
nicely to it, but also seeing how far you can push the envelope without even
changing Lightning itself.  It's a very powerful primitive, I think.

**Mike Schmidt**: Well, in terms of pushing the envelope, is Robin Linus aware
or playing around with this?  Obviously, he's paying attention, but I'm
wondering if he's been on it.

**Greg Sanders**: So, I think they've been focussing on it.  There's some
discussion about ZKPs and stuff for building more complete bridges, so I'm not
sure if he's been paying attention recently.  But he claims that he can use
TEMPLATEHASH to get rid of the interactive peg-in ceremony piece.  I have not
verified that claim and this stuff seems so complicated to me, I can't really
verify it.  So, it'd be nice if there was a PoC of that.  I think that would
be a great contribution.

**Mike Schmidt**: Okay, I think we covered this one pretty good.  I guess
maybe we just leave listeners with the call to action.  Greg, you mentioned
folks can use LLMs to prove out some of these ideas.  Would you encourage
folks to contribute to this organization in some way as well?  I'm just trying
to tie it off with a call to the audience here?

**Greg Sanders**: Yeah, I think my main call at this point would be trying to
understand what actually is being offered with these capabilities and
convincing yourself that it is enough, or if it's insufficient, right?  If
there's this, "Oh, if we just let you commit to this next bit, then we enable
this", that would be important to know.  So, I still think that kind of
direction is one of the most important ways to contribute.

**Mike Schmidt**: Greg, we appreciate your time, we appreciate your work on
this.

**Greg Sanders**: Thanks for having me.

**Mike Schmidt**: You're free to drop a few other things to do and other
Bitcoin projects to save with Project Loupe.  We understand.

**Greg Sanders**: I'll listen in for a bit.  Thanks.

_Continued discussion of PQC output types_

**Mike Schmidt**: Okay, great.  We have more Changing consensus items.  We
have a trio, a hat trick from Conduition.  And we'll start with, "Continued
discussion of PQC output types".  Conduition, we did have you on previously
and we covered Pieter Wuille's output type comparison thread.  And we got into
some of the arguments or discussions and back and forth.  But I know I've been
following this thread to a degree, but there's been a lot of updates.  So, we
wanted to revisit that initial coverage.  And maybe if you have a dog ear in
your mind of where we left off on that last chat and what's happened since,
that would be great to hear your thoughts, and obviously trying to represent
Pieter and others' side on this as well?

**Conduition**: Yeah, absolutely.  So, some of the only major points that I
would want to point out from recent discussion submissions would be around
CISA (Cross-Input Signature Aggregation) potentially being bundled into a
post-quantum output type, and SNARK aggregation discussions, and the semantics
of what gets committed, what doesn't, how would it actually work, who does the
proving, that kind of stuff; and whether it's actually necessary for a PQ
output type to have this in the first or later stage.  I think we're generally
in consensus around the SNARK part.  We probably don't want to do SNARK
aggregation right away because that is a very heavy project to consider adding
into Bitcoin consensus, so I spun off a different thread to talk about that.
And that just keeps this thread focused on output type design.  And one of the
main points that I walked away from the Bitcoin++ Toronto Conference from was
that Fabian Jahr's CISA proposal actually melds very, very well with Pieter
and Antoine's P2TRv2 proposal.  In fact, they already have a BIP for CISA.  It
would be very easy to fold P2TRv2 into the CISA BIP.  All you would need to do
is attach another BIP that deploys post-quantum signatures.  "All you need to
do", is a lot of effort compacted into one sentence there.  But still, it's a
lot easier to fold two BIPs together in that way, especially now that we have
a potential draft for a post-quantum signature BIP, which we'll talk about
soon.

**Mike Schmidt**: Why would we do that?  Maybe spell out the benefits.  I
think folks maybe are familiar with one and the other side.

**Conduition**: In case you're not familiar with CISA, CISA allows a spender
using classic elliptic curve signature tricks to merge all your signatures
together into one.  So, if you're signing a transaction that has, say, 20
inputs, you can sign 20 times and offline aggregate all those signatures
together into a single signature that authorizes all of those 20 inputs.  So,
instead of 64 times 20 bytes in the witness, you're doing just 64 plus 20
bytes, because you just need a single 1-byte marker for each of those
placeholder signatures.  So, this would basically drop the cost of classic
elliptic curve spending with this new output type.  And this is all just
pre-quantum stuff.  And the reason why it folds so well into a post-quantum
output type design is that if you do this, if you package CISA together with a
post-quantum output type that also supports something like SHRINCS or ML-DSA,
or some other post-quantum signature algorithm, you can have an address type
that is simultaneously more efficient than every other address type today, but
also supports this migration path towards post-quantum cryptography that might
be necessary someday.

**Mike Schmidt**: Okay, that makes sense.  You're sort of economically
incentivizing people to move over.  But I guess there's other ways to do that
potentially.  And then, there's also things that are non-economic, for example
what we've spoken about with instagibbs here.  Why not, instead of fee
savings, dangle functionality in front of people to come into the taproot v2
world?

**Conduition**: That's very true.  I mean, there's no reason you couldn't
package a whole bunch more things together.  I personally am not that familiar
with the landscape of covenants proposals.  Getting to learn more about them
is very, very welcome, and I think it could definitely be considered.  I
haven't thought much about that myself.

**Mike Schmidt**: I didn't mean to derail too much, but yeah.  So, go ahead,
Murch, I see your hand up.

**Mark Erhardt**: There is, of course, a little bit of a trap here.  So, the
idea of introducing P2TRv2 originally came from the thought that you'd want a
way for people to demonstrate that they have included post-quantum security.
And one of the originally proposed properties of P2TRv2 that would be
beneficial to that end was that it actually did not have any cost savings.
So, you would assume that people would only use P2TRv2 if they actually have a
leaf that is post-quantum secure in their tree.  Because as proposed, P2TRv2
would come with this expected sunset of elliptic curve cryptography when Q-day
is imminent, or some other criteria are fulfilled.  And so, you wouldn't put
your funds at risk in a P2TRv2 output for absolutely no benefit unless you
actually get the benefit of the post-quantum security in some leaf.

Now, of course, that is just one way to think about it.  The other way is, we
do want people to do the post-quantum security thing.  And because elliptic
curves could be sunset at some point for that output type, if they're worried
about that, they would have to have a post-quantum spending path.  And
thereby, by economically incentivizing them, you would get them to implement
post-quantum security.  But the savings of something like this, while for
large transactions with lots of inputs, significant, are currently not that
juicy because the feerates have been so low and probably implementing
post-quantum security has its own challenges.  So, the savings versus
implementing post-quantum security earlier might actually also not be
sufficient to motivate people.  Yeah, just a few additional thoughts on this.

**Conduition**: Yeah, absolutely.  I definitely agree that the lift of adding
post-quantum signature schemes is heavy.  Thankfully, we don't need to
implement the signing schemes yet.  The most important thing for migration
towards PQ is simply being able to generate addresses that support PQ.  You'd
only need to implement key generation in the first stage of any migration, and
that part is relatively easy.  It consists mostly of just generating a merkle
tree when it comes to a hash-based signature scheme.

**Mark Erhardt**: Sorry, I heavily disagree.  I don't think anybody should
send money to a script that they don't know they can spend from.  So, yeah,
you could say they can spend with the regular elliptic curve thing, but
nothing lives longer than a good enough provisional solution.  So, if they
cannot actually verify that the post-quantum is implemented correctly, sending
to a script with post-quantum leaves seems a little disconcerting, at least.

**Conduition**: That's fair.  You don't necessarily need to, but you probably
would want to implement signing schemes.  It really depends on the individual
and the wallet that you're designing.  It depends on how much resources you
have.  I'm just saying that the bare minimum that you'd need to do to migrate
to post-quantum is key generation.  And if you follow test vectors, then you
know your key generation is working correctly.  And if you know your key
generation is working correctly, then you know you can sign with those keys.
But yes, as for the efficiency of CISA, I do agree that it is not as
significant of a change as, say, migrating from P2PKH to P2WPKH.  But I think
it's important to remember that if you just keep the cost of adopting PQC as a
fixed constant, then you're just playing with one variable here, which is how
efficient do we want to make this post-quantum output type?  Do we want to
make it more efficient at the cost of slightly greater implementation
complexity on the consensus side, or do we want to keep it as bare minimum of
a change as possible?

**Mike Schmidt**: I think that covers some of the CISA side.  I think you had
other realization in terms of SNARK aggregation as well, was one of the things
that you walked away with recently; do you want to talk about that?

**Conduition**: Yeah, although I think it might be a little bit of a tangent
for the discussion of the output types.

**Mike Schmidt**: Okay, sure.

**Conduition**: Honestly, I've realized recently that you can deploy SNARKs
without having a new output type.  I mean, with taproot or P2MR, you really
just need a new leaf script version.  And there's a whole very, very deep
ocean of different design considerations around SNARKs, so I don't want to get
too deep into that ocean.  But I do want to mention how this affects P2MR
because that is another consideration.  So, with P2MR, CISA behaves somewhat
differently.  With P2TRv2, on the other hand, plus CISA, you get really,
really efficient witnesses.  You basically reduce the size of your witnesses
to zero asymptotically.  And then, you just need one single signature to cover
an effectively unlimited number of inputs.  With P2MR, it's not that easy
because P2MR, you need a hash preimage and you need a sibling leaf in order to
have an address that supports PQ.  And so, at the bare minimum, you still need
those 64 bytes included with every input, 64 bytes of witness data.  So,
that's still discounted.  But at best, that's still equal to P2TR.  So, with
CISA added into the mix, P2MR could improve to be as efficient as CISA.  But
then, it comes with the additional implementation complexity.  So, on one
hand, it gets you much closer to having parity with current elliptic curve
spending efficiency.  But on the other hand, you have to add this additional
implementation complexity of running the DahLIAS protocol, which is the
cryptographic protocol that CISA relies upon, offline.

**Mike Schmidt**: It makes sense.  Is this particular discussion still ongoing
on the thread?

**Conduition**: Oh, yes.  And I have a meaty post that I'm ready to submit at
some point today to continue the discussion.  I'm hopeful, but I'm starting to
get the sense that most of the other people in the thread are considering CISA
as a non-starter.  That leaves me to reflect on what would happen if we deploy
P2TRv2 without CISA.  What would probably happen is P2TRv2 becomes a very easy
output type to deploy.  I mean, really all it is, is just P2TR, but with an
addition of this implicit agreement on a future soft fork.  And maybe it will
come packaged with a tripwire system, which we discussed in a previous
newsletter.  But at the end of the day, it doesn't actually have post-quantum
security.  And so, the impetus to migrate to it will pretty much be only for
people who want to claim quantum security without actually doing the work of
having quantum security.  There will be no other incentive to migrate to
P2TRv2.  Whereas with P2MR, there is actually a potential path to using P2MR
securely with only post-quantum cryptography.  And so, P2MR becomes
significantly more attractive in that outcome.  And I would guess that P2MR
would probably go the extra mile of implementing CISA in the consensus rules
for P2MR, because, well, if P2TRv2 won't do it, P2MR will get a big advantage
compared to P2TRv2 by doing it.  So, I would expect to see BIP360 changes if
P2TRv2 doesn't bundle CISA.  Murch?

**Mark Erhardt**: Yeah, so taking an initial look at BIP460, the CISA BIP
draft, the original idea is to only have CISA for the keypath and not for the
scriptpath at all, because it just gets so much more complicated to be sure
that you would be able to support the signature aggregation then.  So, how do
you propose would CISA be implemented in P2MR?  Would that have a specific
path that can only have a single signature, or something like that?

**Conduition**: Yeah, that's how I would probably do it if I were to do it.  I
haven't spent that many cycles considering it, but the easiest way, if you
were to design it in an ideal scenario, would be to define a new leaf script
version and have that leaf script expect a public key in CISA format, and then
the witness for that particular leaf version would just be either a
placeholder marker or a full-aggregated or half-aggregated signature.

**Mike Schmidt**: Conduition, is there discussion of, because I think we're
talking about output types, there's lots of different approaches and I think
the bitcoiner brain is like, which is better?  We get to pick one.  Is there
discussion of, "Hey, we could do two of these things", or is that just sort of
off the table and we've got to pick the best one?

**Conduition**: I think most likely, it will end up being both, because I
don't think either proponents of P2MR or proponents of P2TRv2 are happy with
just one in either case.  So, what's probably going to happen is P2TRv2 will
be deployed first because it's just the easiest one to deploy.  Whether it
bundles CISA or not, I don't know, that's an open question.  And then later,
P2MR will be deployed, probably with some additional more heavy-handed
upgrades that have been thought through and designed more carefully.  P2TRv2
is so much easier to deploy, we might as well deploy it today with
post-quantum cryptography, so that at least we have something that people can
migrate to.  And maybe if we can time the disabling fork correctly, people who
use that address will be safe.  And then, for the longer term, we can have a
more well-designed, scalable solution, because that's really the problem here,
is how do we do post-quantum in a scalable way?  And I think P2MR is the right
output type to fulfil that role.  And there's various options.  We've been
discussing SNARKs, we mentioned that a minute ago; we've also been talking in
a separate thread about witness styles and discounts for post-quantum
signatures, and how you would handle the larger size of blocks that comes with
that, without SNARKs, or with SNARKs.  You could do it without SNARKs, but
then you have 16-, 32-megabyte blocks and you have to shard the network or do
checkpoints or other extreme measures.

**Mark Erhardt**: Whoa, whoa, whoa, we haven't even talked about a block size
increase yet.  Do you want to give us the lay of the land here?

**Conduition**: Yeah.  So, there's a separate thread about witness styles,
which is the term that Pieter Wuille uses to refer to new extensions to
transactions that include a different witness discount.  So, this isn't really
a block size increase per se, it's just weighting the post-quantum signature
data differently than we weight today's signature data.

**Mark Erhardt**: Well, yes, that would increase the block size, though.
Okay, let's say post-quantum signatures are several thousand bytes, and let's
say 3,000 just for the sake of it.  If we wanted the same throughput, that
would be a 50x decrease if we kept the block size the same, right, because
currently P2TR signatures are 64 bytes.  3,000, okay, maybe not exactly 50,
but 3,000 bytes instead would really reduce the number of transactions we can
do.  On the one hand, that might give us a substantial feerate increase, which
would maybe make us more comfortable in regard to whether fees will eventually
contribute the majority of block rewards versus the subsidy.  But on the other
hand, obviously, if we could suddenly make something like 50x fewer
transactions per block, the throughput of what's possible onchain with Bitcoin
may be debilitating.  On the other hand, even though currently demand seems a
little low, the block supply is inflexible.  So, once you go over the
production of block space, it very suddenly increases the feerate.

So, the idea would here be, if we introduce this new signature scheme, maybe
we have sort of an extension to the transaction format similar to segwit,
where we put all that post-quantum signature data, and then give it a
different discount than the witness data.  And that would indeed be a block
size increase in the soft fork in itself.

**Conduition**: Yeah, that's exactly right.  And the semantics of how we
actually would implement that is the subject of the discussion in that
separate thread.  I think it's called, "Segwit commitments to PQ witness
data", or something like that.  It's on Delving Bitcoin.  A very good read,
it's got lots of interesting ideas.

**Mark Erhardt**: Yeah, and before everybody gets out their pitchforks, people
are spit-balling here, talking about what we might need to do in order to have
a functioning Bitcoin Network in case there is an advent of quantum computers.
So, please entertain with an open mind before getting out your pitchforks.

**Conduition**: Yeah.  And my personal take is that I don't think a witness
discount is going to be accepted widely by the community, which is why SHRINCS
is designed the way it is, which we'll get to later.  And it's why I'm so
interested in SNARKs, because it will allow us to keep the same block size.
In fact, we could even make blocks smaller and still maintain massive
throughput.  In fact, we could increase the throughput of Bitcoin using this
technique.  But of course, it comes with the caveat of, we have to do the work
of building this SNARK system correctly, soundly, and in a way that is
malleable enough to upgrade later.

_DropKick commit/reveal PQC rescue_

**Mike Schmidt**: Conduition, it sounds like we'll have you on for this
discussion in a few months, based on another Delving post, it sounds like, or
whatnot.  But no pressure, obviously.  But we do have two more items that we
should jump to.  The second one, DropKick, which is a commit/reveal PQC rescue
protocol.  Conduition, we had you on last time and you used this term, this
'knowledge asymmetry' framing that you gave us a few episodes back.  Maybe you
can remind folks, what is knowledge asymmetry in the context of quantum, and
then maybe we can get into your idea?

**Conduition**: Yeah, absolutely.  Rescue protocols in general rely on this
idea of knowledge asymmetries, which are secret pieces of data that normal
Bitcoin holders know, but which quantum attackers would not, or at least
should not.  And this could include things like the preimages of hashed
addresses, or BIP32 hardened parent keys, or the internal keys of taproot
addresses.  These are all things that are normally not exposed onchain,
although in some cases they are exposed in the course of spending.  However,
you can map the network and index out every UTXO that has certain ones of
these knowledge asymmetries, as I call them.  For example, you can index
through the entire Bitcoin blockchain and collect the set of all addresses
that have never been spent from before, but are protected by a hash.  For
example, every P2WPKH address that's never been spent from, that is a hashed
address.  And so, we would say that it has a knowledge asymmetry with the CRQC
(cryptographically relevant quantum computer) that we're assuming exists at
this point.  Because the CRQC, they can factor elliptic curve keys very
easily, but they can't invert hash functions.  And that asymmetry is what
we're relying on for what's called rescue protocols.

So, the idea of a rescue protocol is to make use of this fact that all these
Bitcoin users out there, they know these secret pieces of information, just by
complete coincidence through the way that Bitcoin and wallets are designed,
they know these pieces of secret information and they can use those things to
authenticate themselves.  But in order to do that, we have to deploy new
rules, and that's what a rescue protocol is.  It's a set of new rules that old
outputs would have to meet or would have to satisfy in order to spend their
coins.  So, there's two types of rescue protocols generally.  There's
zero-knowledge-proof-based protocols and there's commit/reveal-based
protocols.  There may be others.  I'm personally not aware of any, but these
are the two ways that we know of, of proving knowledge asymmetries.  ZKPs are
relatively self-explanatory.  If you're familiar with them, a zero-knowledge
proof is basically a way of proving that you know a particular piece of
information that satisfies a certain set of constraints without revealing what
that information is, which seems like it's exactly what we'd want to do here,
right?

The only problem with that is that ZKPs that are quantum-secure are very
complicated, very big, and very, very slow.  And there's also some situations
in which they can't be deployed as a soft fork.  Like remember the hashed
address that we just talked about?  Well, if you want to prove that you know
the preimage of a hashed address without revealing that preimage, well, you
can't do that without deploying a hard fork that removes the requirement of
revealing that preimage, because that's how all hashed addresses today work.
In P2WPKH, you have to reveal your pubkey; in P2WSH, you have to reveal the
script.  So, those asymmetries, they're no longer asymmetrical anymore if you
have to reveal them as part of your spend.  So, ZKPs are big, hefty, and they
don't work in all the situations we want them to.

So, I turned into commit/reveal for my research into rescue protocols.  And
Tadge Dryja spearheaded this way before I did, by the way.  And his ideas on
Lifeboat, they predate mine by years.  So, I highly recommend you check out
his threads on that before looking at my protocol.  I posted an article about
DropKick, which is my own commit/reveal-based rescue protocol.  The way that
commit/reveal rescue protocols work is much simpler than a ZKP.  In practice,
it is very, very complicated though.  A commit/reveal protocol is basically a
way of using a timestamp system to prove that you know something before a
quantum computer finds that same information out.  So, in the case of a hashed
address, if you can prove that you know that piece of information at a certain
point in time, and then reveal it later and authenticate the fact that you
knew it earlier, well then any verifier can say, that person knew that secret
before any quantum attacker could have, they must be the real holder of that
coin.

So, what DropKick and Lifeboat both do is they use Bitcoin as that
timestamping system.  They say, "Okay, let's insert a commitment", which is
basically just a hash or a set of hashes, "somewhere in the blockchain, and
then wait a few blocks, and then reveal or open that commitment", is the
technical term, 'opening' a commitment.  And when you open the commitment, any
Bitcoin node can verify it, check that it occurred at a previous point in
time, long before the actual secret information, such as a BIP32 xpriv or the
preimage of a hash, before that information could have ever been known to a
quantum attacker.  And note that unlike ZKPs, this system only needs hash
functions, no heavy-duty machinery, no sum-check protocols, no circuits, no
arithmetic or algebraic circuits.  It's just hash functions and timestamps and
blockchains and block headers, which is all information that Bitcoin nodes
already have.

**Mike Schmidt**: What do we lose by such an approach?  It sounds amazing.

**Conduition**: Well, it depends what approach you take, and there are a
litany of different knobs that you can tweak with rescue protocols.  Many of
them are knobs that squash you with an enormous hammer and crush the security
of your protocol.  Lots of other commit/reveal-based protocols have been
discussed before, but none of them are really that suitable for Bitcoin
specifically, because they don't take into account the way that Bitcoin blocks
and specifically Bitcoin blockspace is used.  You have to pay for Bitcoin
blockspace; there's only a limited amount of it; and nodes don't index all of
it.  Mostly, nodes just index transactions, and not all nodes record all
witnesses.  Some data is pruned, some is not.  So, figuring out the details of
how you would actually construct this on top of Bitcoin itself is where most
of the work is.  And Tadge's protocol, I should probably talk about first,
because it's the easiest to understand, I would say.

With Lifeboat, users publish commitments in OP_RETURNs.  So, they would need
to have access to Bitcoin UTXOs, first of all, or they would need to pay
out-of-band to acquire those UTXOs.  And by the way, those UTXOs have to be
quantum-safe, otherwise you're not going to get very far in this whole
protocol.  Once you have a post-quantum UTXO though, it's very easy to just
publish a transaction that contains an OP_RETURN that commits to a specific
piece of data.  And then, you introduce a new consensus rule that says, "Any
OP_RETURN that fits this particular template, you must index it and then
remember it for later because it's going to be useful".  A few blocks later,
the user who wants to rescue their old pre-quantum coins can open that
commitment, point to the specific index that the validator node has already
picked up on, and show, "Hey, yes, I did know this particular piece of secret
information.  Also, by the way, here's all of the other consensus-satisfying
witness data that I would normally need to spend, but then also here's this
extra chunk that proves that I knew the secret piece of information, the
knowledge asymmetry, before any quantum computer could have".  So, it's this
extra encumbrance tacked on to the spending transaction that rescues the
pre-quantum coins.

Okay, the downsides though is that, first of all, notice that you have to wait
a few blocks; notice that you have to have post-quantum UTXOs to do this; and
notice that nodes have to index all the commitments.  Those are some of the
main drawbacks of Lifeboat and of commit/reveal protocols in general.  So,
with DropKick, I wanted to fix two of those, and I made the third one worse.
With DropKick, instead of putting your commitments onchain in the clear in
OP_RETURNs, you can essentially use an OpenTimestamps-like server, or called
an aggregator, that collects commitments from unknown, untrusted users and
merges them together into one big merkle tree.  And then, they just post the
root of that merkle tree onchain somewhere.  They could even hide it inside of
an elliptic curve public key if they wanted to.  But the key point is that the
root of that merkle tree needs to be hidden somewhere in a block committed to
by the block header, so that the blockhash is essentially the commitment to
all of those other commitments.

Now later, a few hundred blocks later, instead of just a few blocks, we had a
few hundred blocks, and then you open your commitment by providing essentially
an SPV (Simplified Payment Verification) proof, that says, "Look, back at that
block a few hundred blocks ago, that contained this long sequence of hashes
that eventually reveals this particular secret piece of information that only
I could have known".  And then, that becomes the extra piece of data that
satisfies this new soft-forked-in encumbrance that's called a rescue protocol.

So, the benefits of doing this are, first of all, notice the user does not
need to have any post-quantum UTXOs anymore.  They can offload that
requirement to an untrusted third-party server who, by the way, can actually
extract fees from the rescue if they wanted to; salvage fees, you might call
them.  That's all in-band, onchain, and verifiable.  Then, the work that the
aggregator needs to do is relatively minimal.  They need to do some offchain
aggregating of hashes, but that's incredibly cheap.  OpenTimestamp servers do
that today for basically free.  And second requirement, notice that nodes no
longer need to index anything.  The commitments are all hidden offchain.  And
this is the major drawback of Lifeboat, and it's the major benefit of
DropKick.  But it's also DropKick's greatest weakness, because the reason that
Lifeboat forces everyone to post their commitments in the clear is that it
allows nodes to construct what's called a total order on the set of all
commitments.  So, later, when you're doing the reveal stage, nodes can
distinguish what the earliest valid commitment was.

That isn't possible with DropKick.  You don't have the set of all commitments.
They're hidden.  And so, with DropKick, that's why we wait a few hundred
blocks, because we need to prevent this thing called minor censorship attacks.
If a miner blocks your reveal transaction or censors it, they can insert their
own commitment that occurred, say, a few hundred blocks after yours.  So,
yours is still technically earlier, but there's no way for a validating node
to know that.  So, if the miner can censor your transaction for some hundreds
of blocks, they can steal your coins by usurping your commitment and opening
theirs instead.

**Mark Erhardt**: Maybe let me just jump in here to make that point clear,
because it's important to understand the rest of it.  So, you make a
commitment to the secret preimage that you have, and then you store it in a
merkle tree that is committed to by some data in the blockchain.  So, you have
the merkle branch that goes to your commitment.  You only ever had to provide
the hash of your commitment to the aggregator, so they don't know the secret
yet.  And then, hundreds of blocks later, you make an input that you sign
regularly.  But in addition, you provide the merkle branch that proves that
you had committed to being allowed to spend this and to your secret
information that you now reveal in the input hundreds of blocks later.  Now,
by revealing the input to the preimage, other participants on a network can
see what the preimage was, and they can construct their own commitments.  And
thereby, if they can wait long enough, if they can censor your recovery long
enough, they can act on their own commitment that they now include after you
reveal your recovery transaction, and thereby they can steal your funds.

**Conduition**: Exactly right.  And that's the main trade-off between Lifeboat
and DropKick.  With Lifeboat, you get very tight security because it's
impossible for somebody to forge an earlier commitment unless they reorg the
entire chain back to before your commitment was there.  With DropKick, all
that miners would need to do is censor your transaction consistently.  And
this is where, in order to show security for DropKick, I had to resort to some
game theory.  It turns out, if you do the math, you can figure out that in
order to prevent miners from censoring you, it suffices to provide a
proportional fee.  Because the miners' reward, in a game-theory sense, their
reward for censoring your transaction only pays out if all miners also censor
your transaction consistently until their own commitment matures enough to
spend.  So, it turns out, if you work it out in detail, that the amount of fee
that you need to provide to incentivize the miners away from that strategy is
at least, actually it should be strictly more than, the value of your UTXO
divided by the number of blocks you're willing to wait.  So, if you're willing
to wait 100 blocks, you need to pay at least, hopefully more, than 1% of the
value of your rescued UTXO.  And of course, if you're rescuing multiple UTXOs,
you need to add up all the values.  Murch?

**Mark Erhardt**: Yeah, I've been thinking a little bit about the game theory
here, and I think that this lower bound might be a little too low.  So, 51% of
the hashrate, or just a simple majority of the hashrate, can censor any
transaction by overtaking all block production.  So, actually, if you then
gather 51% of the hashrate into a cartel and split the reward among them for
the censorship, you don't actually have to pay only a percentage of your
reward, but you would have to pay a 51st part of it to make it more juicy to
defect.  So, divide by 51 instead of 100 for 100 blocks.

**Conduition**: I'll mention that in the security game-theory argument, I
assume no reorganizations, and that's a big assumption.  If you allow a mining
cartel of 51% or more, then all bets are off basically.

**Mark Erhardt**: I mean, Bitcoin's completely broken then anyway, because a
majority hashrate attacker can reorganize the chain at will, can double-spend
at will, can censor at will, can monopolize all the block rewards.  So, block
production basically is reduced by almost half.  So, fees will run up and they
can monopolize the entire block reward.  So basically, Bitcoin is completely
broken if you allow for a majority hashrate attacker.  And well, if Bitcoin is
fundamentally broken, that your recovery method is also broken is kind of just
a sideshow.  Yeah, but I'm wondering whether the 1% or total recovery amount
divided by blocks you're waiting is accurate, because a smaller percentage,
like a selfish mining attack with a little over 33% might be able to do a
chain of some length profitably.  So, I think it might be a little higher.  I
haven't thought through the game theory completely, I'm not a game theory
expert either.  But that is maybe the claim about DropKick that I'm least
confident about.

**Conduition**: Same here.  That's why I would love further review on the
game-theory mechanics that I use, because there could be mechanics that I
haven't factored into my model.  And I'm not the most knowledgeable about
Bitcoin mining.  We were talking earlier with Gary, and honestly, a lot of
that was very new information to me.  So, any feedback from people experienced
with how mining works and the incentives of mining pools and individual miners
would be very welcome.

**Mark Erhardt**: Yeah, basically, so what we can summarize that to is you
have to pay enough of a portion of your recovery that one of the miners is
incentivized enough to defect from a cartel that censors you and to take the
reward immediately, rather than wait for the other commitment to mature and to
be able to take it themselves.  So, you basically have to be able to
incentivize someone to defect and confirm your recovery transaction.  But
unless they're actually playing that game, that might actually just be a
regularly juicy fee.  If they're not really trying or even considering how
much they could make in several hundred blocks by censoring you, just paying a
good chunk of fees straight up might get any, at least smaller miner, to
immediately include it or any honest miner.  And assuming that some of the
audited and regulated entities are not going to steal money from you, you
might have a pretty good chance if you just -- I might recommend instead of a
100 blocks as the prime example to go for 1,000 blocks directly, like a week.
Somebody defecting from a cartel once a week seems pretty easy and that might
make it much cheaper to recover.

**Conduition**: I agree.  I think if I zoom out here, the trade-offs between
like DropKick and Lifeboat are such that if we want to really depend upon this
protocol, we should probably use something with much tighter security, which
is Lifeboat.  And Lifeboat can also be extended with many of the tricks that I
developed in DropKick, like authorizing post-quantum keys instead of
authorizing transactions, and generalizing to different knowledge asymmetries.
And that all kind of transfers between Lifeboat and DropKick.  But the core
trade-off is DropKick does not have this tight security and you need to rely
on this loose game-theoretic perspective in order to argue its security.  And
if the majority of the Bitcoin UTXO set needs to use it, then I don't think
that's a sound assumption.  So, if we consider it in the strategy of
post-quantum migration, DropKick sits closer to the edge of the contingency
where most people have already migrated by Q-Day.  And if we only need to
rescue a tiny portion of the UTXO set with a rescue protocol, well, DropKick
would probably be fine for that.  Those rare edge case people trying to
recover their coins lost after years with pre-quantum keys, they're probably
okay with waiting 1,000 blocks and paying 0.1% of their stack.  If we needed
to use it to rescue 80% of the UTXO set, that'd be a very different story, and
Lifeboat would be a better choice there.

**Mike Schmidt**: We've mentioned Lifeboat a few times.  We did have Tadge on
when we covered his commit/reveal posts back in Newsletter #361 and Podcast
#361, which was about July or so last year.  So, if folks are hearing that
idea and want to dig into more, you can hear it from Tadge himself.

_SHRINCS draft BIP_

But we do have one more Changing consensus item, big one.  Maybe we should
have put this one first, "SHRINCS draft BIP".  Conduition, you posted on
behalf of the SHRINCS working group the first draft BIP specifying SHRINCS.
Can you remind us again, what is this SHRINCS thing?

**Conduition**: Yes, very excited to talk about this one.  So, there are very
different types of post-quantum signature schemes available and they're
divided into families that rely on different assumptions.  There's a family
called hash-based signatures that rely only on hash functions and no other
extra cryptographic machinery.  And there is a very well-known, perhaps the
most well-known candidate for a hash-based signature scheme is called SPHINCS.
And SPHINCS is notable because it's the first fully stateless hash-based
signature scheme.  You don't need to maintain any specific counters or
remember anything to use it.  It works basically as a drop-in replacement for
classical keys.  The only problem is that it's really big, really, really big,
like 100 times larger than classic elliptic curve signatures.  It's also
really, really slow to sign with.  We're talking about, like, millions of hash
function invocations.  Compared to with a regular elliptic curve key, you'd be
considering something comparable to maybe 1,000, 2,000 hash invocations.  So,
it's orders of magnitude difference in performance.

But you can actually do much better if you consider adding in statefulness.
So, if you consider a signer on Bitcoin, they typically only use their key
once, maybe twice, and then they move their UTXOs to a new wallet.  There's
some people, like exchanges, who reuse keys and reuse addresses, but the
average Bitcoin wallet generates new addresses for every receive, and so they
only use that key once.  Now, if we consider this as an average user
experience or an average kind of use case, you can say, "Well, what if the
wallet can just remember how many times they signed with a given key?"  If you
can do that, you can actually get way smaller hash-based signatures and way
faster performance.  And this is the trade-off that SHRINCS makes.  It says,
"Okay, most Bitcoin wallets don't need these massive stateless signatures.
They don't need to sign trillions and trillions of times with each key.  They
only really need to sign once or twice.  So, let's just add in the option of
using this stateful signature genre in order to allow people to make much
cheaper, faster signatures".  And SHRINCS combines SPHINCS with these stateful
signatures into one unified scheme, where signers can choose whether they want
to use the stateful or the stateless components.  Murch?

**Mark Erhardt**: Yeah, I wanted to jump in a little bit and double-click on
the once or twice signing per key, because I had, among other things, a long
debate with someone on Delving that was proposing a new post-quantum signature
scheme.  And I just want to make it very clear that every key in Bitcoin
transactions has to be able to sign more than once, because even if you intend
to just use a key once, you get paid to an output script a single time, and
then you spend it immediately, you might need to be able to make a second
transaction because, let's say, feerates just generally go up the moment
people start using post-quantum signature schemes, and your transaction was
created at a feerate that is lower than any future feerate will ever be
achieved.  And you made the transaction only once, but now your transaction
will never get included in a block because the feerate is too low.

So, you need to be able to sign a second time to make another transaction that
spends this input at a higher feerate.  So, yes, a lot of wallets and the way
a lot of bitcoiners use their addresses only a single time, they often end up
only signing once, maybe twice, but they have to be able to sign a few times,
either because they have to RBF, or because they are creating a transaction
with a counterparty where they use a multisig scheme.  And if the counterparty
forces them to restart the process of signing, they might need to be able to
sign a second time.  Or they want to collect an airdrop and now they have the
same UTXO on more than one chain.  And in order to dump their shitcoin, they
need to make two transactions.  So, they make two signatures, right?  So also,
other people can send to your output script again.  Forced address reuse,
dusting, that sort of thing, may make your output script be paid more than
once.  So, you need to be able to sign multiple times with keys.  I agree on
the not needing trillions of times for most users, thousands would be probably
plenty, but there definitely has to be the option to sign multiple times with
one key.

**Conduition**: Completely agree.  And SHRINCS supports all those use cases.
So, the person you were probably talking to, I'm guessing, was considering
deploying one-time signatures.  And that would be a folly in my opinion,
because for the same reasons that you pointed out, you need to be able to sign
multiple times in a lot of situations.  And a one-time signature scheme just
does not cut the mustard for that.  So, what you can do is you arrange your
one-time signature keypairs into a merkle tree.  And in SHRINCS, that merkle
tree can have arbitrary structure.  So, one thing that we recommend as
probably the most useful standard for average Bitcoin wallets is called an
unbalanced XMSS tree.  This XMSS system is, by the way, called the Extended
Merkle Signature Scheme, and that's the unique addition that SHRINCS makes,
the unique contribution that we propose.  And then, we just basically
concatenate the key for this flexible XMSS scheme with a standard SPHINCS key.
And then, you just have access to both of them, and a signature from either
component suffices to validate.  So, if you are okay with statefulness and you
want really small signatures, the cheapest possible, you can use XMSS and just
keep your leaves very close to the root.  But if you need to sign multiple
times, you can go deeper into that tree.  And if you ever lose your state or
if you don't want to manage state at all, you can just use the SPHINCS key and
never touch the stateful part.

Oh, and I should probably contextualize this.  So, we've been working on this
specification for SHRINCS for several months.  It was initially proposed by
Jonas Nick, and Mikhail Kudinov back in, I think, February or March, and they
invited me into their group to work on this.  And we've been having a fun time
working out all the details and hammering out the specifics and the per-byte
encodings of what goes into every hash function, what the signature format is,
what the key format is, how it's compatible with SLH-DSA, and all that.  And
this spec is, we think, the first draft that we would consider viable for
public review.  And so, we're posting it here on the mailing list now to
solicit that review.  And we're hoping to get feedback about any
vulnerabilities or oversights or design considerations that we might not have
looked at.

**Mike Schmidt**: Well, hopefully our audience is listening and is able to
provide that such feedback.  I'm curious, you mentioned the stateless
fallback, and there's a certain budget to that as well.  I think the big thing
here is state, right?  I think there's pushback concerns from various users
and parties about the state.  I guess, I mean, they could just plan to always
use the stateless fallback.  Is that a valid approach for people, or how are
you thinking about that?

**Conduition**: That's a great question and it's very topical, because for the
time while we were drafting the specification, we mostly considered the
stateless component as being entirely a fallback.  We're starting to reassess
that a little now after hearing the initial feedback.  Most of the feedback
is, "State is dangerous", and that most people won't use it, and that's a
viable stance.  If you don't have the engineering bandwidth to go into
managing these redundant state systems, and you don't have access to, say,
rollback-resistant storage or TPMs or hardware signing devices, or the other
kinds of durable storage media that you need to use statefulness with, then
stateful path might not be a great idea for you.  And in that situation, you
would need to use only the stateless path, and that would be your default path
and the stateful path would be ignored.  So, we're considering what we might
do to modify the scheme with that in mind.  I still think having the stateful
path is a good idea, because if you only just deployed SPHINCS, just SLH-DSA,
maybe change the algorithms, maybe tune the parameters a little, you would
still end up with like 3,000-, 4,000-byte signatures at best.

There's a floor on how small SPHINCS can get and on how efficient it is.
Because remember, the smaller you make these signatures, the more expensive
they get for the verifier, which is another very important knob; there's a
point where you can't tune below.  If you make the verification too expensive,
block propagation slows to a crawl and IBD (Initial Block Download) will
become way slower.  So, we're trying to consider what the best balance might
be, and parameter sets and algorithm design plays a very important role here,
because hash-based signatures are almost infinitely configurable, but you
still have to meet and satisfy all of your various requirements.  And so,
having the stateful path available as this backup that can be really, really
high throughput, really high performance, I think will still be a benefit one
way or the other.  Unless, unless, unless we're going to talk about SNARKs.
If we're going to talk about having SNARKs in Bitcoin, I don't think the
stateful path is necessary at all, which is why I'm so interested in SNARKs
now.

But if we're considering the minimum viable post-quantum signature scheme that
Bitcoin could hobble onwards on in the event of an emergency Q-day scenario,
then I think SHRINCS or something like SHRINCS is probably our best option.

**Mike Schmidt**: We covered this a few weeks ago in Newsletter #419, but
maybe you just want to give us your two cents on the implementation.  We
covered libshrincs, the C library that I think Remix did some formal
verification on that.  Do you want to talk to that just briefly?  We didn't
get into it too deeply when we talked about it before.  You don't have to get
in too deep, but maybe just what have that group been doing?

**Conduition**: Yeah, it's very cool work.  Honestly, I can't say too much
because my knowledge of formal verification is about on par with a
kindergartner's.  So, I'll simply say that I'm very, very happy to see this
work being done, even if I don't understand it yet.  Because with the slew of
other vulnerabilities recently discovered in post-quantum cryptosystems,
either by humans or AI, and in the Bitcoin ecosystem by both, the bar for
security has increased a lot since Fable and other AI models started probing
the weaknesses in cryptographic schemes.  And formal verification is a way of
using that same weapon as a defensive tactic to use AIs to prove that a scheme
is secure against a contract that is human-written and human-readable.  It
says, "We have this theorem that this particular scheme satisfies these
requirements", and then you give the AI the goal of proving that statement.
And you can use type theory and compilers and other trickery to verify the
AI's proof against that statement.  I think that is just mind-boggling to me,
that what I previously only considered as an offensive tool, AI cryptanalysis,
can be turned into a defensive tool that proves security.  And it gives me a
lot more confidence that we can design secure cryptosystems as humans with the
assistance of AI.

**Mike Schmidt**: We've talked a few different topics here within quantum, and
if folks have made it this far through these quantum discussions we've just
had with you, Conduition, maybe they're on top of it.  But if you listened to
these last few discussions and were a little bit confused about how these
different things interplay, I am going to shill the Brink Engineering call
that we had with you, Conduition, where you had a visual on the screen of the
different aspects of post-quantum Bitcoin discussions and how they interact
with each other, how they're categorized, how they depend on each other,
including the tripwire systems, signature schemes, post-quantum output types,
etc, some of which we touched on today.  But if it felt a little bit over your
head and you want to contextualize a lot of it, check out the Brink
Engineering call with Conduition.  I thought especially the first 20 or 30
minutes or so when you went over that initial diagram was very helpful.  So,
I'm going to shill that here.  Anything else that you'd shill before we move
along, Conduition?

**Conduition**: No, thank you.  That's very flattering.  I honestly just kind
of made what I could out of what I know, and it's limited.  There's a lot
missing from that diagram, but it's a good, useful overview of what you could
work on and what you might want to think about if you're considering
researching into the subject, or if you just want to get up to speed with the
current state of the art and where the discussions are today.  Thank you.

**Mike Schmidt**: And I'm sure that the second the video was released, it was
out of date in some way.  But if people are spinning through space and need
something to grab on to, to contextualize things, I think it's a valuable
resource.  So, we appreciate your time in joining us today, Conduition.  I
know it's been a couple of hours.  We appreciate your time.

**Conduition**: Thank you so much, Mike.  It's always a pleasure.  I'm going
to drop out, but I will see you on the next one.

**Mike Schmidt**: Cheers.  We can move out of the News and Changing consensus
segments to our Releases and Notable code segments authored and described here
by Gustavo.  Hey, Gustavo.

_Core Lightning 26.06.7_

**Gustavo Flores Echaiz**: Hey, guys.  Thank you, that was really interesting.
But now, let's get into the Releases.  So, this week we have three releases.
The first one was very-discussed Core Lightning 26.06.7.  This is a very
important security release, for which the binaries have not been released yet,
to prevent attackers from reverse-engineering the fixes.  The source code
should be released 14 days after the binary release, which would put it this
Friday.  So, if you're interested in looking at the source code of this
release that you might have already installed, it should just be coming up in
the next few days.  So, there's not more details than just to update.
Although also, it was advised that if a user didn't want to update, they could
also take their node offline.  So, that was also part of the initial advisory.
This would prevent an attacker from potentially stealing funds of the user or
attacking his node in other ways.

Also very important to warn users that if you Docker users who pulled the
latest tags or this release tag between August 28 and September 1, you might
have received an image that reported the new version but did not actually
contain the fixes.  So, if you were amongst those users, you might want to
check your image digest and re-pull again, now the images that you re-pull
will include the fixes.

**Mike Schmidt**: Maybe just one point of clarification, because I think that
flag, called --offline, is a bit confusing.  It's not actually taking your
node and turning it off, but it's turning off certain capabilities in terms of
the node's operation, which leaves the onchain mechanism active.  So, it will
check to see if someone is attempting to cheat you.  And there's this flag
that does that, that is --offline, but it doesn't actually mean to unplug your
node, because then you obviously lose the ability to do that onchain checking.

**Mark Erhardt**: Right, it turns off the P2P communication with other
Lightning nodes, it disables creation of new channels, and routing of messages
and P2P gossip, I think.  But it still continues to follow your onchain source
and check for channel closures in confirmed transactions so you can react.

**Gustavo Flores Echaiz**: Thank you guys for that extra context.

**Mark Erhardt**: Also, if you didn't mention it, so we had last week a
maintainer of CLN on who told us that the source code that someone had
recreated was able to be built bit-for-bit correctly into their release
binary.  So, while you don't get the commentary of the source code, the source
code does seem to be available, although it cannot be verified because, well,
it passed the shasum, but you will get a lot more disclosures and commentary
in the release from the source code of CLN.  But if you do want to inspect the
source code already, there is a version of that available that passed the
shasum check, so it is byte-for-byte correct.

_LND v0.21.3-beta_

_LND v0.20.4-beta_

**Gustavo Flores Echaiz**: That's great, thank you for adding that.  Even I
hadn't caught that.  So, the next releases are both maintenance versions from
LND, v0.21.3-beta and v0.20.4-beta.  So, both of these are maintenance
releases that backport multiple fixes, some of which we will cover in the
later part of this newsletter in the Notable code and documentation changes.
The first is putting limits around peer resources, specifically when receiving
inbound ping messages and sending outbound pong replies.  So, we will discuss
that in a few minutes.  But also, some other fixes that were covered in
Newsletter #420, so last week, around how when opening a channel, there could
be a potential lock if there was a race condition between opening a channel
with a PSBT, and at the same time cancelling a channel reservation.

The difference between these two versions, v0.21.3 and v0.20.4, is that some
features and some fixes that are part of the maintenance release of the
v0.21.3 are not in the maintenance release of the v0.20.4, specifically when
it comes to auxiliary channels that are used for Taproot Assets.  So, that was
included in a fix for the cooperative close flow which was included in the
maintenance release version of the branch v0.21.3, but not v0.20.4.  Same
thing for a feature called experimental XCreateAccount, which we covered in
Newsletter #419, that allows you when you're running an LND node to create
separate accounts that are derived from the same master key, but that allow
you to segregate onchain funds in your LND node.  So, that was also included
in version v0.21.3, but not in v0.20.4.  But those are the exceptions.  All
the other fixes, whether they're related to, like I said, peer resource
limits, but also the PSBT funding deadlock fix, and many others, were included
in both releases.

_Bitcoin Core #36111_

So, now we jump into the Notable code and documentation changes section.  We
have two items from the Bitcoin Core repo, and both are related to improving
the performance and reducing memory usage.  So, the first one, #36111, it's
specifically related to this RPC command, validateaddress, when validating
bech32 strings, and particularly when reporting errors for overly long bech32
strings.  So, previously, when you were validating a bech32 string that
exceeded the character limit, each position past the limit was going to get
computed and returned as an error location.  So, for example, if there was a
mistake at position 15, that was going to get reported.  But if, let's say, it
had 100 characters, then position 90, position 91, position 92, and so on,
would all get reported as separate errors.  So, if you were to going to make
an HTTP call with its potentially highest request body of 32 MiB, then the
benchmark would say that 5.6 GiB of memory would get consumed, so quite a lot
of memory usage just for validating the size of, or at least returning that a
bech32 string was exceeding the 90-character limit.

So, now the fix is simply to return the first position that exceeds the limit,
so position 90 or the character 91, where the length violation begins, and not
return an error for subsequent positions, because it's implied that if the
first position that violates the length is returned, the rest is also implied.
Yes, Murch?

**Mark Erhardt**: I just wanted to make clear, this is an RPC command issue.
So, an RPC is something that only the node operator himself or herself should
have access to.  Sometimes, people run nodes that they give access to by other
people, but especially if there's a wallet connected, that would be very
unsafe.  But yeah, if you're giving RPC access to your node, you're
essentially giving node operator access to your node.  So, this is something a
node operator can do to shoot themselves in the foot.  That is the extent of
this.  This is not something someone can externally or a third party can do to
your node, you have to do it to yourself.

_Bitcoin Core #36032_

**Gustavo Flores Echaiz**: Thank you, Murch, for specifying that.  And that
also applies to the next item, Bitcoin Core #36032.  So, here, when
constructing a transaction and parsing through outputs for the construction of
the transaction, either when you use an RPC command, such as
createrawtransaction, createpsbt, or sendmany, the fix is that it will now
become linear instead of quadratic.  So, previously, when iterating through
the output keys, which are the output addresses, and separately looking for
each corresponding value, the value amount of each output, it would be scanned
the same list of keys each time.  So, if, for example, when trying to obtain
the value of the first key, it jumps to position 1, it goes to value 1.  But
then, when trying to obtain the value of position 4, it goes through position
1, position 2, position 3, position 4, right?  So, just a lot of work that was
unnecessary.  Now the parser walks through the keys and values together by
index, "Okay, I want to obtain index 4, I jump straight to key 4 and value 4
instead of parsing through all positions".  So, once again, a performance
improvement of internal RPC usage, potentially a resource and performance
issue, but not a major security issue.  And here, the benchmark of the author
reports that, for example, parsing 10,000 outputs will now take half a second
instead of 1.8 seconds.

This fix is similar to something we covered in Newsletter #419, related to the
gettxspendingprevout RPC when checking large batches of outputs.  So, similar
performance fix here.  Yes, Murch?

**Mark Erhardt**: Yeah, I think I want to contextualize that too.  A wallet
with 10,000 UTXOs is extremely large.  So, you're probably running your
Bitcoin Core at least as a business backend at that point, and you haven't
really done much UTXO management, I'd say.  Generally, Bitcoin Core is
relatively consolidatory in its UTXO management to a point where I consider it
overly so.  So, you shouldn't get to 10,000 if you're transacting regularly
and not just receiving.  But if you're just receiving, you would also not bump
into this problem.  And then, if you have 10,000 UTXOs, calling your
createtransaction RPC would cost 1.5 seconds instead of 0.5 seconds.  Or was
it 1.8 you wrote?  I think 1.8.  So, even then, with 10,000 UTXOs, you're
going to get through it in 2 seconds on this machine that it was tested on,
which might be more beefy than your average machine.  But, yes, there's a good
improvement.  Just again, this is not the world ending or anything.  You have
to have a very large wallet and not really do any UTXO management to even bump
into this.

_Core Lightning #9435_

**Gustavo Flores Echaiz**: Totally.  Thank you, Murch, for that extra context.
Next, we jump into the CLN repo, so PR #9435.  Here, CLN is updated to
actually align with the BOLT2 specification.  So, this behaviour of CLN wasn't
spec-aligned.  So, what was going on is that when you were receiving a
channel_reestablish message from your channel peer, but he had a
next_commitment_number of zero, CLN was sending a warning to the peer, but was
leaving the channel open.  However, BOLT2 specifies that if you receive a
channel_reestablish message with a next_commitment_number value of zero, you
should force close the channel, because this is probably your peer indicating
that he has lost his channel state and he needs you to force close the channel
so that he can recover his balance using a static channel backup.  CLN would
enforce this on a freshly opened channel.  So, if you had just freshly opened
the channel and no other transactions other than the funding transaction had
occurred, then CLN would actually execute properly and force close the channel
when receiving this specific value in this specific message.  But for any
other state of a channel that had progressed beyond being freshly open, CLN
was simply sending a warning and leaving the channel open.

There's simply no scenario, other than one where you have lost your channel
state, where your channel_reestablish message next_commitment_number has a
value of zero, because even on a freshly-opened channel, the value should be
1.  So, just to say that this is a scenario where a user has definitely lost
his channel state or has entered into a bug-like scenario.  So, CLN now aligns
to the spec to do what it's supposed to do in this scenario.  Yes, Murch?

**Mark Erhardt**: Maybe don't understand this wrong.  If someone sends you a
channel state zero, that doesn't mean it's safe to cheat on them, right?  So,
they might have a bug that they didn't lose their entire channel state, just
the latest state.  And if you go back and broadcast an old transaction, they
might still slap you with a penalty transaction.  Not that I'm expecting any
of our honest users to use this ever, but just I think the way you described
it, it sounds like it might be used whenever the latest channel state is lost,
or when the node isn't sure they have the latest channel state, but they don't
have necessarily lost all their state.

**Gustavo Flores Echaiz**: Right.  Great clarification, totally.  Because your
peer is indicating he doesn't know the latest channel state, like Murch says,
doesn't mean he has lost completely all his channel state.  Thank you for
clarifying.

_Eclair #3368_

The next two items from the Eclair repo, both are fixes and hardenings.  The
first one, #3368, is related to after Eclair added simple taproot channels, a
TLV position in the commitment_signed message was added or specified for
including a partial signature with a nonce value for MuSig2 partial
signatures.  And that is for simple taproot channels.  However, Eclair was
still accepting that TLV value position with a partial signature with a nonce
value, even on a non-taproot channel.  So, potentially a channel peer that is
attacking an Eclair node could include, yes, the valid ECDSA signature so that
Eclair would properly validate that signature and accept the commitment sign
message, but it would also carry a value in the TLV reserve for the partial
signature with the nonce value.  So, Eclair would properly verify the message,
but because it detected that the partial signature was included, it would
incorrectly store the partial signature instead of the ECDSA signature that it
had validated, and that was the proper signature for this message.  So, Eclair
later on when trying to force close the channel, it would be unable to because
it had stored the wrong signature that an attacker had attached, and the
attacker had also attached the right signature, but this wasn't a
signature-verification issue, rather a storage-of-the-signature issue and
Eclair couldn't foreclose the channel.

So, the fix is quite simple.  Eclair first checks the signature type that
matches the channel commitment format so it will know, "Okay, this is a
non-taproot channel, I shouldn't ever store a partial signature with a nonce
value that is used for taproot channels".  So now, Eclair properly verifies
and properly stores the verified signature so that it can later on broadcast
the commitment transaction and force close the channel if it has to.

_Eclair #3366_

The next item is still in the Eclair repo, #3366.  This is about hardening the
splicing implementation of Eclair.  So, once again, we keep going in the
profile of security, right, this is not about fixing a specific bug, but about
hardening the implementation if a channel peer could try to sabotage or
basically just interact by not following the specification.  So, for example,
when you start the splicing process, you will enter into what's called a
Keysend protocol, or you will send a keysend message, specifically stfu, which
basically tells your peer to, "Stop sending any other channel update because
we're going to negotiate a splice.  So, first let's stop any other channel
update".  So, the first part of this item is that if your peer sends a channel
update after he had sent the keysend message, you should disconnect from that
peer, because he's not following the process that he himself is initiating and
then going against, right?  Same thing for a peer that sends a
commitment_signed message while the splice is being negotiated.  So, you're
negotiating a splice but your peer is trying to advance the commitment state
of the channel parallelly to the splice being negotiated.  So, a lot of fixes
like that, or hardening.

The next one is that Eclair will force close the channel if a peer attempts to
advance the channel's existing commitment while the splice is being signed.
So, this is not about the moment where the splice is being negotiated, but the
splice is being signed and your peer is also attempting to advance the
channel's existing commitment state.  Finally, Eclair also refuses to complete
a splice whose commitment numbers no longer match the channel.  So, if somehow
your peer was able to advance the channel's state while you were trying to
negotiate a splice, well, Eclair will refuse to complete that splice if the
channel's state has advanced beyond what the Eclair node understands as the
current channel state.  And finally, another edge case related to liquidity
advertisements, which is a protocol that Eclair has developed that allows a
node to publicize its willingness to contribute funds to a new channel
requested by a remote peer, when a splice in which Eclair sells liquidity to
liquidity advertisements is aborted, Eclair now immediately fails the incoming
HTLC, which allows the payer of the liquidity advertisement to reclaim his
funds.  Yes, Murch?

**Mark Erhardt**: I just wanted to clarify, people might have a
misunderstanding about this.  So, the quiescence protocol that introduced this
new stfu message, we didn't explain what that stands for.  That's obviously
for Something Fundamental Underway.

_LND #11090_

**Gustavo Flores Echaiz**: Thank you, Murch.  I wasn't even sure about what it
stood for.  So, thank you for clarifying.  The next items are from the LND
repo, #11090.  So, this is the one we mentioned at the beginning of the
episode, when Erick was explaining this is responsible disclosure of a DoS
service vulnerability in CLN related to ping messages and pong replies, which
could cause an OOM crash.  So, it seems that LND might have seen that
responsible disclosure and has now implemented rate limits around inbound ping
messages and also outbound pong replies.  It also caps each peer's outgoing
messaging queue.  So, what are these new limits that have now been
implemented?  So, the inbound ping request bucket for each peer connection,
LND now maintains two token buckets, one for ping request messages and another
for outbound pong replies.  The buckets of inbound ping requests per peer
start with 200 tokens and replenish at a rate of 10 per second.  The outbound
pong reply starts with 20 tokens and replenishes at a rate of 1 per second.
So, the ping request messages queue or bucket has 10 times more capacity than
the outbound pong reply bucket.  And exhausting these buckets causes LND to
stop replying.  And this is a deliberate deviation from what the BOLT1
specification says, probably triggered due to CLN's responsible disclosure of
an OOM issue.

So, also there's another cap, which is each peer's outgoing queue is also
capped at 10,000 messages or approximately 16 MiB.  So, this is a general
limit that doesn't replenish through time, contrary to the previous buckets
that I just described.  So, that's the first part of this PR and really about
hardening or introducing rate limits around the ping messages and the pong
reply buckets.  But separately, this PR also fixes an issue where when LND
would advertise inbound fees in a channel_update gossip message, it wouldn't
sign properly the bytes it broadcasts.  And this would lead to peers to reject
the channel_update message of LND when using inbound fees.  So, inbound
forwarding fees are as a non-standard in the sense that it hasn't yet been
merged in the BOLTs repository, waits for an LND node to accept a payment for
forwarding or not just add additional fees, but actually add a discount of
fees on the inbound channels where the payment is coming from.  So,
traditionally, a Lightning node will charge fees on the outbound channels
where the payment is being forwarded by, but the inbound forwarding fees
protocol allows a node to charge or actually introduce a discount of fees
where in the inbound channels.  And the goal here is for a node to basically
be able to guide payers into the channels it wants them to take, by offering
incentives and particular discounts on the inbound channels that a payment
passes through; it can incentivize which channels a payer takes.

So, however, when broadcasting a channel_update message, LND wasn't properly
signing it when advertising this specific feature.  So, potentially peers
could reject the update.  So, now this is also fixed where LND will properly
sign the bytes that include these optional fees.  And additionally, if LND
receives a channel_update gossip message from a peer, even if it doesn't
recognize a specific feature as a TLV record, it will just forward the
originator's message without disrupting it, because previously it could drop
them or it could drop the bytes that it doesn't recognize, and that would
invalidate the original signature.  We covered a similar bug fix or a similar
fix in Newsletter #418 in the item, Eclair #3341, because Eclair was also
doing something similar where it was overriding specific bytes it didn't
recognize in channel_update messages, and that was also invalidating the
signature and making peers refuse or reject the message.

_LND #11140_

So, the next item, LND #11140.  Here, this is related to something called
trimmed HTLCs.  So, trimmed HTLCs are when an HTLC is below a channel dust
limit.  So, a node will not resolve it onchain because it's below its dust
limit.  And here, there are two scenarios.  In these two scenarios, both
channel peers have different dust limits.  So, LND could look at the HTLC and
be like, "This HTLC is over my dust limit", but the channel peer could look at
the HTLC and say, "No, this is actually under my dust limit".  So, when
broadcasting a transaction, the commitment transaction onchain, the channel
peer could simply not include it in its onchain transaction because it's below
its dust limit.  However, LND had considered previously that this was above
its own dust limit, which means that if the peer's commitment transaction
confirmed without that HTLC, LND wouldn't fail the incoming HTLC back because
it had judged the HTLC based on its own commitment, which included the HTLC
because it was above its dust limit.  So, now the fix is that LND decides
based on the commitment that actually confirms.  So, if its channel peer
doesn't include the HTLC, then LND fails back the incoming HTLC and allows the
peer downstream to recover its HTLC.  But the second scenario is basically the
opposite, where LND would immediately fail an incoming HTLC if it saw that the
HTLC was below its dust limit, but then its peer could potentially include
that HTLC in its broadcasted transaction onchain, and that would allow the
downstream peer from claiming back the HTLC, right?  So, LND in the middle
loses it both ways.

So now, LND, even if it considers that an HTLC is below its dust limit, it
will actually wait to see, because potentially his peer would include it in
the commitment transaction that it broadcast, and LND wouldn't fail it
downstream in that scenario and wouldn't lose the money both ways.  So now,
LND handles properly both scenarios when it comes to trimmed HTLCs.

_HWI #792_

The next item is from the Hardware Wallet Interface repo, item #792.  So, this
is a follow-up to work we've been covering in the past two newsletters.  So,
in #419, we covered that a new command, called registerdescriptor, was added,
which allows a main output script descriptor to be registered with a hardware
wallet.  Then, in Newsletter #420, the next step was extending the
displayaddress command to match a registered BIP388 wallet descriptor policy
to basically allow a hardware wallet to display an address if it matches a
descriptor policy that was registered in the device.  So now, the next step is
to add a registration option to the signtx command, which basically allows
HWI, or a caller of HWI, to add the registration option, and that will flag to
the hardware wallet that is signing the transaction that the transaction being
signed matches the output script descriptor that was previously registered
with the registerdescriptor command.

This option accepts any serialized registration returned by registerdescriptor
which, for example, in Ledger's case, is a specific HMAC, but it could be the
policy name, the descriptor, the device type.  And this support is implemented
for BitBox02, Coldcard Edge, Jade, and non-legacy Ledger devices.

_BDK #2262_

And the final item in this list is from the BDK repo, PR #2262.  So, this is
about fixing a bug when reindexing a wallet's transaction graph.  So, for
example, you use your wallet which uses BDK, and you are basically asking BDK,
"Can you scan all the transactions that you're aware of and see if any of my
addresses match any of these transactions?  Which outputs belong and which
transactions belong to my wallet?"  However, because these outputs were
examined in a random order and because BDK was watching a window of addresses,
wallets will not scan for all potential addresses.  They will scan for a
specific window and if we reach the last position of that window, it will
extend that window of addresses.  So, BDK was doing exactly that.  However,
because the examination of the outputs was done in a random order, sometimes
BDK would consider that the search was done when it technically wasn't yet.
So, now reindexing repeats the process until the window stops extending,
because depending on the order of how you examine the outputs, you could get
different results if you were looking at outputs and if your window wasn't
extending and you weren't looking for the addresses that match with
transactions that your wallet had.

So now, BDK just does the process again until the window stops extending, and
that way it catches all transactions that match your wallet addresses.  That's
the last item and that completes the episode and the newsletter.  Thank you.

**Mike Schmidt**: Thanks, Gustavo.  Thanks, Murch.  We also want to thank our
guests today, Gary, Erick, Conduition, and Mr. instagibbs, Greg Sanders, for
joining us this week, and thank you all for listening.  We'll hear you next
week.  Cheers.

{% include references.md %}
