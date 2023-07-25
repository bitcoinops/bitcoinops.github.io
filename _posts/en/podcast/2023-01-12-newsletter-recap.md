---
title: 'Bitcoin Optech Newsletter #233 Recap Podcast'
permalink: /en/podcast/2023/01/22/
reference: /en/newsletters/2023/01/11/
name: 2023-01-12-recap
slug: 2023-01-12-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Jesse Posner and ZmnSCPxj to discuss [Newsletter #233]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-6-7/338380278-22050-1-27ae3677ada6c.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #233, Twitter
Spaces Recap.  We'll do some quick introductions and, Murch, if you have any
announcements, we can go through that as well, and then we'll jump into the
newsletter.  And I will share some tweets shortly so that folks can follow along
if you're not familiar with what we're covering from the print version of the
newsletter.  By way of introductions, Mike Schmidt, contributor to Bitcoin
Optech and Executive Director at Brink, where we fund open-source Bitcoin
developers.  Murch?

**Mark Erhardt**: Sorry, yeah, yes! Hi, I'm Murch, I work at Chaincode Labs, I
do a lot of Bitcoin-y stuff for work.

**Mike Schmidt**: Jesse, maybe introduce yourself and give us some background on
getting into Bitcoin and some of the work you've done.

**Jesse Posner**: Sure, yeah, so I used to be a lawyer in a previous life when I
started going down the Bitcoin rabbit hole a little bit ago, and I joined. I
used to work at Coinbase on the key management team, working on cold storage
stuff after my conversion to engineer/cryptographer.  And then I was actually
funded by Brink for a while, working on open-source implementation of FROST and
ECDSA adaptor signatures, and I'm continuing to work on FROST, I've got a PR
open in the secp256k1-ckp repo.

But I joined Block last year to work on the self-custody wallet solution, and
specifically I've been looking at designing our Lightning architecture, our
Lightning implementation for the wallet.  And that's where I've been working
heavily with ZmnSCPxj, who can intro himself, but we've been thinking about
Lightning implementation, and that's where this idea emerged, swap-in-potentium,
to handle some of the liquidity pain points that come up in Lightning.

**Mike Schmidt**: Excellent, thanks for joining us, Jesse.  ZmnSCPxj, do you
want to introduce yourself and some of your background, that you feel
comfortable sharing?

**ZmnSCPxj**: Hello, can you hear me?

**Mike Schmidt**: Yeah, we can hear you.

**ZmnSCPxj**: Okay, so I'm ZmnSCPxj.  I'm just some random guy on the internet.
You can argue that I am actually some wannabe indie-game dev who wandered into
the wrong part of Reddit and got suckered into buying bitcoins and now I develop
Bitcoin software.

**Mike Schmidt**: Awesome!  Well, thank you for joining us. I think your
proposal is quite interesting and it's great that you both were able to join to
sort of explain this with a little bit of Q&A from us, from Murch and I, as well
as the audience.

_Non-interactive LN channel open commitments_

So the first item in the newsletter this week is your proposal.  So, I think we
can jump right into that.  It may be beneficial to maybe walk through the
current way that a user may go through the process of, you guys can correct the
use case, but potentially maybe I buy some bitcoins on Coinbase, I want to
withdraw those, I'm a good citizen, I want to hold my keys, so I take them off
the exchange, and then maybe at some point later, I want to do some
Lightning-related payments.  So how is that done today?  And then maybe weave in
how there could be issues in some of those use cases, or it could be improved,
and then we can get on to how your proposal improves upon some of those use
cases.  Maybe Jesse you want to take this first one of, how do we open and
manage Lightning channels now, and how would that use case work, and what are
some downsides?

**Jesse Posner**: Yeah, absolutely.  So, in the current way we deal with
Lightning, you have to consciously and manually make sure your Lightning channel
has sufficient outbound liquidity.  So, let's say you have some Lightning
channel open and you buy some bitcoin on Coinbase, or you get paid bitcoin, or
somebody sends you bitcoin, you just you receive bitcoin onchain, those coins
are not available as a source of liquidity in the Lightning channel on their
own.  You need to take an action and pay a fee and wait for onchain confirmation
to load up your Lightning channel with the new coins.

So, where this can become kind of annoying is, let's say I like to go to my
local coffee shop and use Lightning to buy coffee every day but I get paid
onchain.  And one day I go to buy my cup of coffee and I don't have sufficient
liquidity in the Lightning Channel, even though I just got paid yesterday,
because I forgot to move the onchain coins into the channel.  This is
particularly a problem if I'm using a mobile wallet, because if I have an always
online desktop or server that is handling this, I could potentially automate the
process where as soon as I receive some onchain bitcoin, I can have it move
funds into the channel, either by I can open a new channel with my Lightning
Service Provider (LSP), I could close the channel and open a new one to move
funds in, I could splice in, or I could use a submarine swap.  Those are all the
different ways we could increase the outbound liquidity, but they all require on
chain confirmation.

If I forgot to do that and I don't have some automated server that is always
online and available if I'm using a mobile wallet, where the wallet software is
going to exit periodically and not have background threads running all the time,
I very well may end up in a situation where when I'm going to pay for my coffee,
I don't have the liquidity, and you don't really want to have to wait for an
onchain confirmation when you're in the checkout line ready to buy coffee.  And
it's also not really -- I don't think it's an acceptable UX to ask bitcoiners to
have to constantly be keeping track of this kind of liquidity management.  It's
annoying and most people simply aren't going to do it, unless you're an
ideologically committed bitcoiner that you're willing to go through this.  Most
people are just going to use their credit card or something else if they have to
constantly, manually move the liquidity around.

So, that's what we're trying to solve, is to make it so that when I go to buy
that cup of coffee, even if I don't have sufficient outbound liquidity, I can
get that liquidity instantly, on demand, without waiting for an onchain
transaction.  And I only pay for the liquidity when I actually need it, and I
only get it when it's actually needed, and it could even happen right when I go
to make the payment, the liquidity could swap in transparently.  And the final
thing to add is we can also do this in reverse.  So, let's say I want to receive
a payment and I don't have sufficient inbound liquidity, that again would
require an onchain transaction to increase my inbound liquidity.  It's kind of
annoying to have to block a payment or wait where a payment can't go through
until an onchain transaction occurs.  Again, like a downgrade to the Venmo
experience, or the fiat experience in that sense.  And so it would be better
where, when I actually need the inbound liquidity, I can swap it in instantly to
complete the payment.

If we're in a world of async payments, the LSP has some warning that a payment
is pending, and when the mobile wallet wakes up, will need to be received, so
the LSP can prepare this swap-in-potentium liquidity to be ready to rock when
the wallet wakes up and needs to receive the payment.

**Mike Schmidt**: Now we cover a lot of news around zero-conf channels, so maybe
you can speak a bit to why that is not a good idea and the trust minimization
there.  If I'm at the coffee shop, I just do zero-conf channel, right?

**Jesse Posner**: As long as the risk of double-spending is acceptable to the
participants.  You can take that risk but it kind of undermines the trustless
aspect of the systems -- ZmnSCPxj, do you want to jump in here?

**ZmnSCPxj**: Yeah, I want to interrupt here because I would like to point out
that these sorts of things are going to lead to hidden charges, or rather to
price increases that are not directly reported to the consumer.  It's similar to
how a credit card actually works.  A credit card works by doing a
zero-confirmation.  It's not even confirmed that you have the money to pay for
this thing that you're buying with a credit card, so it's not confirmed.  This
is as opposed to having a debit card, but whether it's confirmed that you
actually have this money.  So, a zero-confirmation works like a credit card.

The issue here is that credit card companies will have in fact a surcharge.  If
I am a merchant and I want to receive credit card payments, I have to pay a
subscription fee to a credit card company.  And in order to offset that, I need
to increase my prices.  And this is something that is not easily noticed by the
end consumer.  They say, "Oh, hey, credit card, instant payments.  Wow, I don't
even have to pay anything except, you know, when the credit card bill is due!"
right?  But the effect here is that there is always a credit card surcharge.
And there are even countries where if a store says, "Oh, we can give you this
same item if you pay by cash at a cheaper price", where that is made illegal;
there are countries where that is illegal.  And of course, it's those credit
card companies who push for those kinds of laws.  So, I want you to consider
that zero-confirmation is basically credit cards.  Okay, so that's my scale.

**Mike Schmidt**: Yeah, I think that analogy makes sense, that due to the risk
involved, like in the credit card example, that risk isn't free, that there is
some mitigation of that risk from the credit card company.  And similarly with
zero-conf, there is a risk and that would need to be mitigated in some way as
well.  I brought up the zero-conf thing more as a tongue in cheek, but I do
think some people would think about that as a potential, but I appreciate you
guys breaking down why that maybe isn't a free thing.  Go ahead, Murch.

**Mark Erhardt**: Yeah, I was wondering, so we've talked a little bit about how
the swap-in-potentium has a better UX for the situation in which we do not have
sufficient Lightning liquidity, but do want to either receive or make a payment.
Maybe we could jump in a little bit in how your proposal works and who has the
funds before, how the funds get locked up to remove the double-spend risk and
yes, let's jump into the details a bit.

**ZmnSCPxj**: Okay.  Jesse, will you take this or…?

**Jesse Posner**: Sure, yeah.  Feel free to jump in at any time, but I'll take a
first stab at it.  So, the way it works is that whenever the wallet --
basically, we're going to create these L1 addresses, onchain addresses, that
are, how the output structure will be, the script structure will be that it's a
2-of-2, so we're going to create a taproot, MuSig 2-of-2 in the keyspend path.
And we're also going to put the 2-of-2 condition in the tapscript as well, and
there's an interesting reason why we're kind of hedging our bets by having two
ways of signing for the 2-of-2, both by the MuSig or the script path, and we're
intending the script path to be used at least initially.  The important thing is
that it's locked by a 2-of-2 between, let's say Alice, who has the wallet, and
Bob, who is the LSP, or let's say Larry who's the LSP.

So, there's also a timelock in the script where after some period goes by, let's
say two weeks, Alice, the wallet owner, can spend unilaterally without the LSP.
But until then, both Alex and Larry both have to sign to spend from this output.
And as ZmnSCPxj points out in the mailing list post, this is actually one of the
kind of early designs for payment channel a unidirectional payment channel.  So,
what we're going to do here is now we're going to create commitment
transactions, or let's say we're thinking really maybe --

**ZmnSCPxj**: State transactions, they're state transactions.

**Jesse Posner**: State transactions that spend from this, what is sort of
equivalent to the funding transaction, this 2-of-2.  Now note, every time Alice
receives bitcoin, it's going into this channel automatically upon receipt,
because each address already embeds this 2-of-2 requirement with the timelock.
So, every payment she's receiving or every payment she wants to be subject to
this swap-in-potentium would directly be bound in this construction as soon as
it's received.

**Mark Erhardt**: So, to clarify, Alice basically chooses to add an additional
encumberment to payments to herself, and instead of receiving money directly,
she chooses to have it locked up to the condition either that she needs also
Larry's sign-off on any payments to herself before she can spend them, or to
wait for what in the example, it was 6,000 confirmations, so about six weeks,
and to be able to spend it unilaterally?

**Jesse Posner**: That's right, yeah.  And so, if Alice wants to make an onchain
payment and spend from this output, she simply asks the LSP to co-sign and if
the LSP isn't acting maliciously, the LSP should not refuse.  As long as a swap
hasn't occurred, the LSP shouldn't refuse to co-sign just any arbitrary onchain
transaction that Alice wants, because it's Alice's coins.  So, if Alice can
cooperatively request, "Hey LSP, Larry, please co-sign, I'm just going to spend
this onchain".  Alternatively, if Alice wants a swap, she can create a
transaction that spends from this output to a Hash Time Locked Contract (HTLC),
where she'll create some hash preimage and spend from the 2-of-2 to be redeemed
by the hash and also I think we'll need to require Larry's key as well.  And so,
yeah, ZmnSCPxj, please.

**ZmnSCPxj**: Okay.  So, Alice will hand over the signature and the transaction
to Larry, and Larry is, well, Larry can now sign it and broadcast it if that's
what Larry wants, or Larry can keep it offchain, and then when it sends the
funds to Alice, it can now ask Alice for a signature for a different
transaction, which is instead of going to an HTLC, it goes directly to Larry to
an address that Larry chooses, okay.  So, if Alice then refuses at this point,
Larry can still take this HTLC-based transaction and then spend the actual HTLC
via the hashlock branch, because it already should have known the hash from
Alice via the on-Lightning payment that will refund or give additional funds to
Alice's channel with Larry, and it will be able to use the HTLC branch.  And of
course we can remove this one additional transaction by having Alice coordinate
this time for the second state.

**Mark Erhardt**: So, let me try if I understood that correctly.  Since Alice
receives the money to this shared ownership between Larry and herself, where
it's held for a few weeks if Larry chooses to become uncooperative, they can
essentially treat that as a semi-offline Lightning channel.  And if a Lightning
payment arrives to Larry that is intended for Alice, they can have an onchain
HTLC to make a last hop to Alice, or if Alice tries to make a payment out of
this shared funds into a Lightning payment, can directly pay an HTLC to Larry.
And Larry can more confidently participate in these schemes because the funds
are already held in shared custody between Larry and the user, Alice, so that
there's at least a few weeks these funds are held and that makes it easy to
immediately create either a Lightning channel or a Lightning payment onchain.
Is that about right?

**ZmnSCPxj**: Yes, that's correct.  If you want, I can discuss about a short
amount about the history of payment channels.

**Mike Schmidt**: Go for it.

**ZmnSCPxj**: Okay, so payment channels were invented by Satoshi Nakamoto.  So,
the initial plan for payment channels was based on nSequence.  So, long, long
ago, back in Bitcoin alpha 1.0 for Windows, you know, the very first version
that Satoshi actually released way back, nSequence was part of our transaction
filtering, inputs.

**Mark Erhardt**: Yeah, each input has an nSequence field.

**ZmnSCPxj**: This nSequence was used during mempool filtering.  For example, I
get a transaction and it spends this particular input, and it has a higher
nSequence, it will replace it in my mempool.  That was the original rule for
nSequence, that's why it was nSequence, that's the reason why the field is named
that way.  So, it's supposed to be a sequence number that is continuously
incrementing, right?  So, the original plan would be like, okay, I would have
funds in my address and then I want to pay you, right?  So, if I pay you, I
create a transaction and I put a sequence 0, the lowest possible sequence.  Then
I broadcast it to the mempool network, to the full nodes, and then later if I
say, "Oh, I want to pay you more because I want to buy another item", I would
increment this nSequence number and then I would rebroadcast this, okay?

So, that was the original design for nSequence and that is why it is called
nSequence, because it's supposed to be a sequence of transactions that you are
doing, that you are sending out to the gossip network before it confirms, before
a block can confirm, because Satoshi Nakamoto was aware that block confirmation
had to be slow so that it would propagate globally.  But he also knew that
transactions would need to be fast also so that you can actually buy coffee and
would not wait ten minutes for the payments, right?  So, that was the original
plan.

Now, of course, this is substantially broken because mempool policy is not
consensus.  If I change my mempool policy, then I can still maintain consensus,
I can still keep track with consensus in the sense that these are the confirmed
blocks and I will still agree that those confirmed blocks are confirmed.  But
now I can change the way that transactions are propagated on the network.  Like
for example, I give you a transaction with a high-end sequence number and then I
go talk to my best friend and have him combine nSequence 0.  And because this is
not a part of consensus, this is only part of transaction policy, relay policy,
then it's not something that miners --

**Mark Erhardt**: Yeah, so there was no mechanism to enforce the sequence to
actually take precedence.

**ZmnSCPxj**: Yes.

**Mark Erhardt**: And a miner can still pick any transaction they saw that is
confirmable.  And since, yeah, well, they picked the transaction, there was no
mechanism to actually -- or even if they just naturally found a block that
happened to include the previous version of the transaction, that's still a
valid block.  And these two ways of how they pick the block are fundamentally
indistinguishable.  Whether they haven't seen the new version or whether they
chose to use the old version, looks the same to every other participant.

Another issue with this was that it essentially gave everyone a license to dust
the network by just using all 3 billion sequences for each input on their
transactions in a matter of seconds!

**ZmnSCPxj**: Yes, yes, so that's an issue.  So, the next iteration of payment
channels would be, you now have nLockTime base and it's now unidirectional.  So,
what you do is you start with an address that is a 2-of-2 between you and a
counterparty, like the coffee shop that you are buying from.  So, you prepare
this beforehand and then you create a transaction that has an nLockTime in the
future and spends that, and then you receive it back to yourself.  So, this is
another design for payment channels which predated Lightning and this is, I
believe, called Spillman style channels.

**Mark Erhardt**: Yeah, I think that was implemented by BlueMatt when he was
working for Mike Hearn at an internship in 2013 or so.

**ZmnSCPxj**: Yeah.  Anyway, so basically what happens is that you spend this
2-of-2 and then there's a transaction that is kept offchain that refunds the
entire amount back to the one who opened this channel.  Now, in order to spend
to somebody else, I now hand over transactions which change how the funds are
divided, so some of it now goes to the other person in the channel.  So, this
channel is still two participants, it's still a channel, and the other person
now gets more funds, and this transaction is not timelocked, it can be sent
right now.  So, by sending it right now, I can close the channel and then the
funds will now be correctly divided between the receiver side and the sender
side of this channel.  So, this is a unidirectional channel.

However, the receiver side can, instead of immediately broadcasting this to the
relay network, it can just keep it.  And then later if the sender says, "Oh, I
want to buy another coffee", then they create another transaction that now gives
more funds to the receiver.  So now, the fact that, or rather, the idea that
prevents cheating here is that the receiver has an incentive to earn more money.
So, it's not going to immediately close the channel and broadcast the first
transaction and then just close the channel, it's going to wait around until
maybe you'll pay it again.  And then when you pay it again, you give it a larger
amount out of this channel.  And the only time that they really need to actually
confirm this channel or confirm the closure of the channel is when the timeline
or the timeout is about to expire.  So, this is now a unidirectional channel.

**Mark Erhardt**: I think one little thing is missing here still.  So, the
receiver, since it's a 2-of-2 multisig that the funds are in, the receiver is
the only one that can close the channel, because the sender gives the receiver a
half-signed transaction, so the receiver chooses which of the channel states to
use to close the channel before the timelock expires that the refund was locked
to.  So, that way, the receiver is the only one that can close, and the sender
can actually not use one of the earlier states that he gave to the receiver.
And yeah, I looked it up, it's June 2013 that Matt announced that to the mailing
list.

**ZmnSCPxj**: Okay, so that's another style.  The problem here is that it is
vulnerable to transaction malleability.  So, before segwit, signatures were part
of transaction IDs.  And the problem here is that if you take a signature and
you flip the sign of one of its numbers -- so, a signature is really composed of
two special magic numbers; you flip the sign of one number and it will still be
a valid signature.  But transaction ID is a hash and if the transaction ID is a
hash, then changing even just one bit is going to completely change the
transaction item.  So, that is the problem of the transaction malleability.

So, remember, to start the transaction, first the two participants, the sender
and receiver, have to sign, have to presign the refund transaction that has an
analog time in the future and which refunds the channel funds back to the sender
in full.  Now, they have to do this before the sender puts funds in the channel.
But the problem is, if the sender puts funds in the channel, so they sign a
transaction to create the channel, the receiver can now change the signature,
change one bit of the signature, in order to change the sign of the component of
the signature.  And this now completely changes the transaction ID, but it is
still a valid transaction.

The problem is that the transaction that refunds to the sender points to a
specific transaction ID and you are able to change this transaction ID.  That is
the transaction malleability problem.  Okay, so that is the transaction
malleability problem, and that is why this kind of channel was not safe.  So,
what we did was we created the OP_CHECKLOCKTIMEVERIFY (CLTV) opcode.  That is
one of the justifications for why this opcode was created.  So, instead of
sending to a plain 2-of-2, you've now created a more complex script where one
branch is 2-of-2, and the other branch is the sender and CLTV.  And because
there is an alternate branch in this address, there is no need to create a
refund transaction that returns the funds to the sender, okay?

**Mark Erhardt**: Yeah, great.

**ZmnSCPxj**: Okay, so that is one way to work around the transaction
malleability problem.  Now, if you pay attention in Lightning, when we open a
channel, the first thing we do is to create the initial commitment transaction.
And this initial commitment transaction returns the funds of the channel to the
funder of the channel.  That's the initial commitment transaction.  And it's
exactly the same as what is used in this previous channel mechanism.  You need
to have a transaction that refunds the channel funds back to the funder of the
channel.  You need to get that signed and you need to ensure that transaction
malleability is fixed.  That is why Lightning needed a transaction malleability
fix in order to actually be implementable safely.

But the advantage of the CLTV opcode is that you don't need this pre-signed
transaction.  It's already there in the script.  There is no need to do this,
there's no need for this extra dance to open a channel.  Like, okay, I have an
address and this address encodes the script 2-of-2 or the funder after some
time.  I have a CLTV or in our case, CHECKSEQUENCEVERIFY (CSV) because we've now
changed nSequence to be a relative locktime field.  The advantage here is that
you don't need to do this dance where both of you sign this initial transaction
that refunds the channel back to the original funder of the channel, it's
already encoded in the address itself.

So, we are now able to use this technique to open a channel, effectively, what
is a channel, but it's not Lightning because it doesn't use the Lightning
protocol, but it's a channel nevertheless, and it's openable by simply sending
to an address.  There is no complex machinery like in Lightning, where you have
to both sign this initial commitment transaction and then you send the funds to
this address.

**Mark Erhardt**: Yeah, it's actually very similar to what you and Jesse are
proposing with the mailing list

post here, right?

**ZmnSCPxj**: Yes, this is basically a revival of this old idea.

**Jesse Posner**: Right.  So, it's a revival of this old idea kind of combined
with the submarine swap idea.

**ZmnSCPxj**: Yes.

**Jesse Posner**: And maybe it'd be useful to take a couple minutes just to
describe that, the swapping process.  So, with the submarine swap, the way it
works is you make a transaction onchain that pays out to some hash preimage and
let's say you're swapping with an LSP and the LSP's key.  And then the LSP
offers an HTLC in the Lightning channel tied to the same hash.  And so at that
point, we have the two scenarios.  We have a cooperative scenario, where Alice,
who has the wallet who initiated the swap, reveals that she knows the preimage
to the LSP, and then the LSP is able to take the funds onchain and they can
update the channel state to just drop the HTLC and replace it with a standard
output; or if, for whatever reason, Alice closes the channel and takes the HTLC
onchain to spend the HTLC, she has to reveal the preimage and then the LSP would
learn the preimage and be able to take the funds onchain.

So, we've swapped onchain funds for offchain funds.  Alice paid the LSP X amount
of bitcoin onchain and then the LSP paid Alice the same amount of bitcoin
offchain.  But to do this safely we need to wait for the onchain transaction to
confirm, the LSP needs to wait, before offering the HTLC in the channel,
otherwise Alice could double-spend the LSP and take the funds in the channel,
but then also take the funds onchain.  So, by adding this Spillman style channel
to the construction, we've removed Alice's ability to double-spend, because to
spend from the UTXO that's offering the HTLC onchain, it requires both Larry's
signature and Alice's signature until the timelock expires.  And so therefore,
the LSP does not have any risk of double-spending by Alice, as soon as that HTLC
is offered onchain, even if it's not confirmed or broadcast, it's just staged
locally, the signed transaction by the LSP, the LSP is safe to offer the HTLC in
the channel, because Alice can't double spend because she needs the LSP's key to
do so.

**Mike Schmidt**: Jesse and ZmnSCPxj, you mention the benefit of the LSP not
having to worry about double-spends in the context of protecting the LSP.  I'm
wondering what your thoughts are on, if people were to use this technique, do
you see LSPs also providing what GreenAddress used to sort of provide, which is
a promise and reputation that they won't sign other double-spends, so that
onchain transactions coming out of this output, they would say, "We won't sign a
double-spend", and thereby decreasing the risk to people outside of that LSP
that a double-spend would occur out of there?

**ZmnSCPxj**: You'd be replacing a miner with that service.  And if a miner can
be bribed to double-spend it, then that can be bribed to be double-spent also.

**Mike Schmidt**: Yes, there's obviously no guarantees and it would be the
reputation of the LSP that would be at stake there obviously.

**ZmnSCPxj**: Yeah, because when you think about it, you can always get the good
reputation and then sell-out at the last minute with your golden parachute.

**Mike Schmidt**: Of course.

**ZmnSCPxj**: Yeah, like you can argue that that's what happened with you know
SBF, or stuff like that.

**Jesse Posner**: But the goal for the design is to mitigate --

**ZmnSCPxj**: Not require.

**Jesse Posner**: Yeah --

**ZmnSCPxj**: To not require the trust.

**Jesse Posner**: to reduce the trust of the -- yeah.

**ZmnSCPxj**: No, yeah, not require trust.  The only trust here is that Alice
trusts that Larry will not go offline and refuse to sign when Alice needs to
spend funds right now.  So, it's basically it's either -- but at the end of the
timelock, Alice will now get unilateral control of the funds.  So, it's only
enforced hodling.  And you know, if you are a wallet and you're dependent on an
LSP, then this LSP can always refuse to forward any of your payments.  Like
you're online and you connect to the LSP and you say, "Hey, I want to sign this
HTLC", and then the LSP gives you bullshit reasons like, "Oh, no, the channels
you're selecting to that route are all jammed up", and they can completely
refuse service to you.  So, you're already trusting that an LSP will in fact
forward your payments, will help you to pay, okay?

So, this is not a worsening of this scenario.  If the LSP disappears, then all
your funds are in the channel with the LSP, then you still have to wait out the
unilateral close for that channel.  So, similarly, if they're here, you have to
wait out the unilateral part or the unilateral branch of this swap-in-potentium.

**Mark Erhardt**: Right, but the long-term outcome here still is that the funds
actually go to the recipient.  So, where we previously had ideas for how we do
async payments where the LSP actually becomes a custodian for the funds before
they are given to the recipient, we now have a construction where the funds are
actually held in the commitment that enables the final recipient to take the
funds unilaterally in the end, which is actually a strict improvement.

**Jesse Posner**: And the only thing I'd add also is that these timelocks are
going to roll off as Alice generates new addresses.  So, each new receive
address she creates, there's a new timelock that gets triggered when that
address receives --

**ZmnSCPxj**: I thought we were going to use relative timelocks?

**Jesse Posner**: Right, but those timelocks would not be the same across
addresses.  Like, let's say Alice generates an address.

**ZmnSCPxj**: No, the relative timelock would be the same, but the absolute
timelock would be different based on when it got sent to.

**Jesse Posner**: Right, but for a fresh address, right, like she's generating
-- if I generate an address today and get paid at that address, the timelock
will start.

**ZmnSCPxj**: Oh, yes, the absolute timelock will start.  But the script itself,
the address itself, would contain only a relative timelock.  You don't need to
change the script itself, it's possible to do address reuse.  This is safe for
address reuse.

**Jesse Posner**: Absolutely, yeah.  So, for a given address, there's a specific
timelock.  In other words, these addresses --

**Mark Erhardt**: I think you meant for a specific UTXO, not for a specific
address, that's the confusion here.

**Jesse Posner**: But my point is that the entire balance at any given time is
not going to be locked up.  There will be some UTXOs for which the timelock has
expired, and there will be some UTXOs for which it has not.  And so, when we
talk about Alice's inability to spend, typically this is going to apply to her
more recent funds, but there will be expired UTXOs that she will potentially
have available to spend with, even if the LSP will cooperate.  Presumably,
depending on her wallet activity and its history, she'll probably have some
UTXOs available that aren't encumbered because the lock has expired.

**ZmnSCPxj**: Yeah.

**Mark Erhardt**: I would like to try to rephrase this.  So, since the addresses
that Alice now creates in collaboration with her LSP, each contain this relative
timelock, as in the funds that are received to these addresses have to age for a
certain number of confirmations before she can unilaterally spend them, if she
continues to use that style for all of her addresses, eventually some of her
funds will always be available to be regularly spent from her wallet, while any
new funds have this swap-in-potentium attached to them while they are still
waiting to be aged appropriately, mature enough to be spent by herself.

**Jesse Posner**: Yes, that's correct.

**Mike Schmidt**: And so as a user, or as an Alice in this example, I am giving
up the risk of being force-hodled and not being able to use my bitcoins for the
reward of having these additional Lightning-related optionalities that I get
with those UTXOs?

**Mark Erhardt**: No.

**Jesse Posner**: That's correct.

**Mark Erhardt**: There's a small other downside as far as I understand, which
is while when Alice and Larry cooperate to spend the funds, they could use MuSig
in the long term to create an output that essentially looks no different than
single-sig.  If Alice needs to unilaterally spend them, she has to use the
checksequence branch, and that requires her to reveal that it was present and
reveal the script.  So, in the case that she needs to fall back to a unilateral
spend, she will actually (a) have a larger transaction input, and (b) reveal
that this was going on.  But as long as Larry is cooperative and remains there,
Larry should always co-sign anything that Alice wants to sign.  So, this is
strictly just a fallback scenario.

**Jesse Posner**: Yes, that's correct, with the caveat that we also are
contemplating potentially not using the MuSig key.  So, remember at the
beginning I also described that we're embedding the 2-of-2 in the tapscript as
well, and so there's a trade-off that is that Alice can decide or the LSP can
decide if they want to take, which is if they use the script path instead of the
keyspend path, they don't need to go through the interactive MuSig nonce
protocol; and then the other thing is, they can point to FROST keys.  So if,
let's say Alice wants to, instead of just having her side of the 2-of-2 sign
with a single key, if she actually wants that to require a 2-of-3 consensus in
her wallet system to sign, by embedding her key in the tapscript, which points
to a taproot key, that taproot key could secretly be actually a FROST key that
was generated with multiple parties and requires multiple parties to sign with.

The reason that we can't -- eventually we're hoping to be able to do that
directly in the keyspend path, but to do that requires nesting, where we would
have to take a MuSig 2-of-2, and have one or both of those component keys in the
MuSig itself be a FROST key.  So, we're nesting FROST keys inside of MuSig, and
there's some outstanding open research questions in terms of the right way to do
that and the security properties.  So, as a stopgap, we have this alternative
where we can use the script path and embed our FROST keys without nesting.

**Mark Erhardt**: That's very cool, yeah.  So either way, you will always have
the ability to have a threshold signature scheme as part of your spending path
in the form of Alice.  And now that makes all sense to me, because I was
wondering how that fit into the ecosystem of Block.  I don't know how much you
-- I guess you've blogged about these things already on the Block blog, right?

**Jesse Posner**: Yeah, I mean we've talked about how we're going to have a
2-of-3 key management setup for the wallet, and so that's the kind of security
model we want for our system, is to not have single points of failure, to
require multiple keys; and in general, I think this is a great way to harden any
wallet setup, is to require a threshold of keys to sign rather than just a
single key, especially when you're talking about a phone where a mobile device
can be compromised and so on.  So, if you have some offline signer or dedicated
hardware wallet signer that can participate, that really improves the security
posture of the wallet.

**Mark Erhardt**: Yeah, totally.  It also sounds like this Block wallet that
you're talking about really depends on taproot getting a little more adoption.
And maybe we should all remind everyone that works on software wallets that they
really, really should be able to send to taproot addresses by now!

**Jesse Posner**: I wholeheartedly agree!

**Mark Erhardt**: All right.  I think we've gotten pretty deep on the whole
micropayment channel topic and also your new proposal on how we can make the
swap-in-potentium.  I think that's really cool and a great idea.  We do have two
smallish news items left, or three actually, on our newsletter, and we're almost
on the hour.  So, I think we're going to wrap up the Lightning swap-in-potentium
topic, unless you have something else to add.  And also a reminder for everyone
that's on our Spaces here, if you have questions or comments, please put in a
speaker request so that we can later give you speaker if you want to talk.

**Mike Schmidt**: One last thing that I'd like to get feedback on is, Jesse and
ZmnSCPxj, how has this proposal been received by the community, both on the
mailing list or any conversations you've had outside of that?  Are people
largely supportive of this; are there criticisms that would prevent this coming
to fruition, etc?

**ZmnSCPxj**: Well, I personally didn't quite like it at first, but I like it
now.

**Jesse Posner**: I like it too.  I think the one pushback we saw in the mailing
list was, Laolu had talked about how the Loop protocol allows for something very
similar.  I think it was recently updated.  I wasn't quite aware that there's a
construction that allows for cooperative onchain spent with Loop.

**ZmnSCPxj**: It's just a plain HTLC.  That's why it's not safe for address
reuse.  So, it's just a plain HTLC address.  And what's happening is that Loop
pays attention to every block that gets confirmed and checks for addresses that
it knows are HTLCs.  And then when it sees that HTLC address, it sends it out to
whoever asked for it.  But because this address commits to a specific hash, once
the swap is done, then the Lightning Loop server now knows the preimage.  And if
somebody sends to the same address again, then Lightning Loop can get this
unilaterally without cooperation of the customer.

**Jesse Posner**: Yeah, so I think there was some initial confusion on the
mailing list about what precisely are the differences between these systems, but
I think that's now been clarified and I haven't seen any other pushback and
we've definitely seen some positive feedback, some excitement about this.  It's
something that we can implement today, there's no consensus changes or anything
like that required.  We're definitely looking to get any feedback we can.  If
anybody has any concerns or thinks it's cool and exciting, please let us know;
we're looking for any and all feedback.

**Mike Schmidt**: Well, thank you both for joining us.  You're welcome to stay
on the Spaces as we wrap up these additional items from the newsletter, or if
you have other things to do, you're welcome to drop off.  But thank you for
walking us through this.  It's really valuable to hear from researchers and
proposers of these ideas to actually discuss it with them.  And you guys have
been very generous with your time for the last hour, so thank you.

**Jesse Posner**: Yeah, thank you so much for having us on.  This is great, and
really happy to have the opportunity to talk about this new idea.

**Mike Schmidt**: Yeah, and we were all a bit lucky this week because there
weren't too many other items from the newsletter, so we were able to really dig
in on this one.  Murch, anything else before we move on?

**Mark Erhardt**: No, I think we've got it all covered.

_BDK 0.26.0_

**Mike Schmidt**: All right, great.  Back to the Newsletter #233, we're in the
Releases and release candidates section.  BDK 0.26.0 was released.  Actually, at
the time of the Spaces last week, we had seen that this was released, and we did
discuss that a bit last week about the Electrum server compatibility and some
dependency bumps there.  Murch, I don't know if you have anything to add on top
of what we discussed last week.

**Mark Erhardt**: Yeah, I actually looked at the release notes a little bit this
morning, and it looks like it's mostly housekeeping stuff.  So there was, for
example, with the Electrum compatibility, the issue that if you called the
save_tx function, BDK had assumed that they would always be in the same order
that they had been requested, but that was actually not the case.  So, that was
just a fix to be able to deal with the response coming in any order.  And the
other things, like the descriptor templates and the code samples from the README
are also just fix-mes.  Yeah, mostly smaller things and housekeeping, except for
maybe the transaction detail ordering and some configuration about using SSL
with the Electrum communication.

_HWI 2.2.0-rc1_

**Mike Schmidt**: The second release that we highlighted this week was to HWI.
There's a 2.2.0 release candidate.  So obviously, if you're using HWI in any of
your software, you probably want to test that.  I went to jump in to the release
notes.  I couldn't actually find a summary of the release notes here.  I think,
Murch, you were potentially going to ping achow.

**Mark Erhardt**: Yes.  I have chatted with the author of this package, and
since it's only a release candidate, the release notes have not been written
yet.  They're pending, and they will be part of the release.  So, I guess if you
are looking to test this release candidate, you might want to take a look at the
commits that were added to the release in order to get an impression of what's
been changed.

_Eclair #2455_

**Mike Schmidt**: Excellent.  And moving on to code changes, we just have one
this week, and it's Eclair #2455, implementing support for Type-Length-Value
(TLV).  Murch, what's TLV, and what's Eclair doing here?

**Mark Erhardt**: So, a long time ago, the protocol for multi-hub payments or
generally communication on the Lightning Network, was changed that the format
was no longer fixed length but actually had this TLV optional field, where
basically to each message, you could attach more information by declaring just
what is it that I'm sending you, what is the length of it, and what's the value.
And here, Eclair implements an additional field, an additional TLV stream for
the failure messages.  So, if a routing attempt did not succeed, a node that say
didn't have enough funds to forward, I can now attach a message back to the
sender in the form of a TLV.  And this is in conjunction with what we recently
discussed.

So, we had used, I think, and discussed the fat error scheme and how there's a
gap in assigning the error or attributing errors to causes and nodes along the
route.  And with these TLV fields, we will be able to propagate messages back to
the sender so that they know why something failed and how they could better try
to find a path for the LN for future attempts.  So, this is essentially Eclair
already implementing the recently introduced change to BOLT04 that proposed to
add this free-form field to the failure messages.

**Mike Schmidt**: And if you're curious a bit more about what Joost was
proposing, its Newsletter #224 that we cover LN routing failure attribution, so
you can dig into that a bit.  That was our last item on the newsletter for this
week.  I don't see any requests for speaker access or questions.  So, Murch,
anything else you'd like to add or announce before we wrap up?

**Mark Erhardt**: Yeah, it's 2023 this year already, so in case other people
also didn't notice.  No, I don't have any announcements!

**Mike Schmidt**: And, Murch, I know you already reminded folks, but I saw, I
think it was you or the WhenTaproot Twitter account, that it really can only be
a couple-line change to support taproot.  So, encourage your wallets and
providers to support this so that we can get some of these features, like we're
talking about here today with Jesse and ZmnSCPxj.

**Mark Erhardt**: Oh, yeah, I actually have a tiny little thing.  I was looking
at the statistics of P2TR outputs on transactionfee.info, and I've been watching
how the curve of outputs has been increasingly accelerating, and we're at like
about 10,000 P2TR outputs per day now.  So, that's still tiny, it's like a
little more than 1% of all outputs created per day.  But it's pretty cool to see
the curve move up.  Yeah, I posted that recently on Twitter.  So, anyway, if you
want to help increase that curve's acceleration, then you should probably also
start using P2TR outputs!

**Mike Schmidt**: Was there a conclusion on where that additional adoption was
coming from?

**Mark Erhardt**: No, I don't think that it's just one person.  I mean, 24.0 got
released, so some people that always try to lag behind one version to give some
time for fixes to appear for anything that's still found might have started
using 23.0 now.  Or, so if you create a new wallet with Bitcoin Core now, the
standard will have support for taproot already.  There are a few other wallets
that have been working on improving that.  LND recently made all of their
payouts taproot, so people rolling out the latest LND versions will start
receiving P2TR outputs.

Then Kraken recently announced that they now support sending to bech32m.
Somebody mentioned that for them, that was now the point that they could start
using P2TR because I assume they have some sort of business relationship with
Kraken, and now they can withdraw to P2TR.  So, I think it's just slowly getting
easier to use P2TR and that's why we're seeing more people trying it out and
using it.

**Mike Schmidt**: Excellent.  Well, thank you everybody for listening today.
Thank you, Jesse and ZmnSCPxj for joining and explaining your research, and
thanks to my co-host, Murch, as always.  And we'll see you all next week when we
cover Newsletter #234.

**Mark Erhardt**: Thanks, Mike, see you.

**Mike Schmidt**: Thanks.  Cheers.

{% include references.md %}
