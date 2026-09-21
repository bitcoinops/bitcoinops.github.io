---
title: 'Bitcoin Optech Newsletter #422 Recap Podcast'
permalink: /en/podcast/2026/09/15/
reference: /en/newsletters/2026/09/11/
name: 2026-09-15-recap
slug: 2026-09-15-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Adam Gibson and Rob
Segers to discuss [Newsletter #422]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-8-15/431959050-44100-2-652f4a8249aba.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #422 Recap.
Today, we're going to be talking about a protocol for coinjoins disguised as
covert bets; we have a discussion about benchmarks for silent payment light
clients; and we have our usual weekly segments for Notable code and Releases.
This week Murch and I are joined by two guests.  We'll have them introduce
themselves briefly.  Waxwing?

**Adam Gibson**: Oh, hello, yes, thank you for having me.  I look forward to
it.

**Mike Schmidt**: Thanks for joining.  And, Rob, who are you and what do you
do?

**Rob Segers**: Hi, Rob from Bitsaga.  What do I do?  I help people secure
their Bitcoin, not as much as a low-level engineer as a usual guest, I guess.
But did some work on silent payments, unblocked, I guess, some discussion that
was going on in 2024.  I guess we'll dive into some findings and measurements
and perhaps where silent payments could be going.

_A protocol for probabilistic coinjoin and covert betting_

**Mike Schmidt**: Cool, thank you both for joining.  We're actually going to
go in order for once in the newsletter, since both of our guests are part of
the News segment this week.  So, we will start with Babilonia, which is a
probabilistic coinjoin and covert betting system.  Adam, maybe folks are
aware, but obviously coinjoins have some issues, in that they're recognizable
and there's obviously a variety of attributes people can use to sort of
identify these and they can get flagged, and in some places such things are
maybe unnecessarily criminalized, and so this privacy tool sort of marks
yourself.  You have this idea for Babilonia that takes sort of a different
angle on that.  Maybe you can elaborate on the issue and then also how you
came to what you came to with Babilonia and what it solves in this regard?

**Adam Gibson**: Okay, sure, thanks.  Yeah, I think you summarize the starting
point pretty well.  So, I guess there's two starting points, right, because
the other starting point is a line of discussion that started on Delving
Bitcoin maybe a year ago or two years ago, I can't remember, and it was
called, "Emulating OP_RAND", and the idea there was there's this clever
cryptographic trick that a guy, Oleksandr Kurbatov, I think is his name --
well, that is his name, but I think I pronounced it correctly -- and he had
this idea about within Bitcoin's existing consensus, so not proposing some new
opcode or something, that you could get a sort of trustless arrival at a
random number that the two parties or the end parties couldn't predict in
advance and actually have that enforced onchain.  And it was a cool idea and
some people were discussing it and seeing pros and cons.  And the obvious
application is that whole idea of being able to make probabilistic payments on
Lightning, because this is an old problem that if you want to make payments
that are so small that they're not sort of economic to be broadcast onchain,
could you still do that within an offchain protocol?  And it might be a good
time to mention that it goes back a lot further than that.

I'm guilty, as well as I think they were in that discussion, I'm also guilty
of not referring to the original history here, which is quite interesting.
But way back, 30 years ago, 1997, Ron Rivest published a paper basically
discussing the same thing.  And what he was thinking was this, that if we have
these new digital cash payment systems, they're cool and everything, but there
will be some flaw, some minimum cost to do such a transaction.  You know, it
might be 30 cents or a dollar or something, right?  And so, he was thinking,
"Well, how could we have payments that were really small, micropayments
between customers and merchants, and yet deal with the fact that if the
customer only wants to pay 10 cents, well, that's just not economically
viable?"  And so, he had the idea of a sort of a lottery approach, where
essentially the merchant would be receiving like lottery tickets instead of
actual payments.  And that, at some point later, and because in his point of
view of the world, this is way before Bitcoin, we were thinking about payments
that were mediated through banks or through some kind of central party.

So, within that context, the problem being solved is a little different, but
it's the same basic motivation that you might be able to, over a period of
payments that were statistical in nature, but nevertheless trustless, at least
the statistics of them were something that you didn't have to trust in, the
merchant could end up claiming the appropriate amount of money over a long
period of time.  And then, the problem repeats in Lightning, like I don't know
how many years ago it was, and I think, somebody correct me if I'm wrong, but
I think it was Tadge Dryja that originally came up with the idea that you
could have a probabilistic payment to replace a single satoshi payment.  And
then, over time, you might end up with 10,000 sats, which is a reasonable kind
of payment, one of those instead of several thousand 1-sat payments, which are
not economical.  But of course, it's a little different in Lightning, because
there isn't any central bank entity to rely on, so it's a little bit more
difficult.  So, I actually don't know all the history of that discussion, I
know there was a lot of discussion, but this new OP_RAND idea is kind of cool,
because it makes a sort of purely trustless way for someone to basically roll
a dice or flip a coin within the payment.

Okay, so that's kind of the background, and if you go back to that, "Emulating
OP_RAND", thread in Delving Bitcoin, you'll see that there wasn't a huge
discussion, but there was some discussion of that, and whether this idea might
be applicable to that.  And then, there was a kind of a back and forth of,
well, but if this new protocol we're coming up with involves zero-knowledge
proofs (ZKPs), which is the thing I haven't mentioned yet, in other words, how
do you get the scenario where there's essentially a coin flip onchain that
neither side can predict?  And the answer is that both sides do some kind of
preparatory work, and then prove that they've done it honestly with a ZKP.
And I think it was AJ Towns who was saying that, "Yeah, this could work, but
if you have to do thousands of ZKP creations and verifications during the flow
of updating HTLCs (Hash Time Locked Contracts), it might become quite
impractical.

So, there's a whole area of discussion there, and there was a paper by
Gerhart, Taylor, and a third name I can't pronounce, shortly after Kurbatov's
original short paper on this OP_RAND idea, and they sort of developed the idea
a bit further, and they made it possible to make a more arbitrary continuous
value out of a set of possible payments, instead of just, say, a coin flip,
which obviously is a bit limiting if you can only create two possible
outcomes.  And then, I haven't even started talking about my idea yet!  So, my
idea sort of continues on in that thesis, and I said to myself, well, the nice
thing about this, going back to Rivest's original idea, a user pays a
merchant, how do we try to address that in Bitcoin?  Well, we came up with
this idea of payjoin.  We said, well, look, we can actually improve the
privacy of actual real-world payments by creating a situation where the two
parties collaborate a little bit, and most specifically, of course, in
payjoin, the idea is that the collaboration takes the form of both the user
and the merchant contributing to the inputs of the transaction, thus violating
the most natural heuristic and the central heuristic in blockchain analysis,
which is that one party is producing the inputs and therefore you can use that
to deduce traces of where the coin ownership is going.

So, I thought to myself, well, the nice thing about payjoin is, well, how can
I say this?  Actually, it's better to look at the other extreme.  Look at the
most normal concept of coinjoin as we imagine it today, which is that n
participants, possibly a large n, are all coming together.  And yes, they are
violating common input ownership heuristic, because they all provide inputs
and then they all get outputs.  And we try to improve privacy very
specifically with equal-sized outputs.  But we realized early on that one of
the big problems with that construction, albeit it does achieve a specific
anonymity set goal, one of the biggest problems with that construction is that
this large transaction, suppose it's 100 participants, each participant is
paying themselves the amount that they put in.  So, each participant comes
along with 1 bitcoin or 4 bitcoins and they get out 1 bitcoin or 4 bitcoins.
And the implication of that is that even if some outputs are equal-sized,
therefore creating an anonymity set in coinjoin outputs, the other outputs,
the change outputs, do not have that property.  And so, it's actually quite
easy to track everything which doesn't go through in this exact size.

So, let's say you put in 4 bitcoins and you get out 1 bitcoin as an
equal-sized coinjoin output.  That 1 bitcoin might have an anonymity set of
100, but you're remaining 3 bitcoin, your change, does not have any increase
in anonymity set in general because of what's called subset sum.  Because
somebody looks at the 4 on the input side and they know that the equal output
side is 1, and then all they have to do is look for 3 on the output side and
they know that's the same person who was the 4 on the input side.

So, in the discussions of payjoin, which occurred back in 2018 in London, we
realized that what would be really nice is if we could break that subset-sum
property.  And we also realized that the only way that you can be sure that
subset sum doesn't occur, in other words the coinjoin transaction can simply
be broken down into a subset of individual transactions, the only way to avoid
that is to have payments within the coinjoin.  And that was one of the
motivating ideas behind payjoin itself.

**Mark Erhardt**: Sorry, may I jump in briefly?  So, in your example just now,
you said that someone puts in a 4-bitcoin UTXO and splits it into 1 and 3
because the shared output size, the standard output size, is 1 bitcoin.  But
of course, they could just pay 4 times 1 bitcoin to themselves.  So, wouldn't
the same also translate if you had multiple different stratified values, like
say you can make 1-bitcoin outputs, you can make 0.5-bitcoin outputs, 0.2,
0.1, and so forth, like some series of allowed sizes, and then multiple people
create multiple of those?

**Adam Gibson**: Yes, 100%.  That's exactly the idea of Wasabi v2.  Well,
WabiSabi has extra cryptography in there, but that was part of what they did,
is that they broke into many denominations instead of just the crude example
that we used back in the day, and that we still use, is a single denomination;
so, everyone agrees to one denomination, everything else is change.  You can
instead create multiple denominations, but I'm sure it's obvious that the
limiting factor of that argument is scale, right?  Obviously, if I have an
output of 0.423765 bitcoin, there's only so far you can go in doing that.  And
in some sense you could argue -- well, I don't know, obviously it's a good
idea to have multiple denominations, I think that was a good innovation.

**Mark Erhardt**: Okay, so basically, yes, but it doesn't work if you have a
very uneven amount, and you were going to tell us how to fix that.

**Adam Gibson**: Yeah, so in payjoin, obviously it's addressing that problem,
but it's obviously a completely orthogonal direction of trying to improve
privacy, right?  It focuses on completely different things.  It doesn't focus
on this concept of a quantifiable anonymity set.  The great thing about this
style of these simple, large coordination of multiple-participant coinjoins is
that you can say, at least at the point of that transaction, I have created
anonymity set K, you know, 100 or 50 or whatever it is.  Payjoin isn't even
trying to do that, but it is introducing this whole other angle, which I think
is really important, which is this sort of steganographic footprint, the idea
that you are making transactions which do have a privacy effect, but which
look the same as things which don't attempt to create a privacy effect.  And
that doesn't create some simple quantifiability.

I mean, a better example in a way is coinswap.  Coinswap is really pushing
hard on that concept.  It's saying, "I'm going to make swaps where there are
transactions, perhaps even on different chains, but let's just say on Bitcoin
itself, two different transactions, and they're not connected in the
transaction graph".  And therefore, assuming you don't actually print the
preimage on chain, in which case they're trivially linked, right, but if you
don't, you're creating two completely separate transactions.  And if you
address things like amount correlation, which is extremely difficult, and
timing correlation, which is less difficult, then if you fix those problems
magically, then coinswaps have this property that, no, you can't give them an
anonymity set of 100, but in some random sets they have an anonymity set of
the entire blockchain.

**Mark Erhardt**: Could we maybe just briefly explain what a coinswap is?  I
think maybe some listeners might not be familiar with that one.

**Adam Gibson**: Sure.  The most general concept is atomic swap.  And I think
it's become quite like, what's the word, pedestrian now.  It's quite sort of
an everyday thing nowadays, because people are doing things like swapping
their Lightning to onchain, or swapping their onchain to Lightning, or
swapping their Bitcoin to Tether, or swapping their Bitcoin to Litecoin, or I
don't know.  There's so many different swap services out there, especially
outside of Bitcoin, but even within Bitcoin, what's sometimes called a
submarine swap, where you move funds between an onchain output and an offchain
Lightning balance.  So, all of them have the same basic principle involved,
which is that the atomicity, the fact that two different payments are
guaranteed to happen, both or neither, both of them happen or neither of them
happen, is coming from the idea that within one of the payments, within
activating one payment, you're revealing a secret which the other side can use
to enact the second payment.  I'm trying to be as general as possible, because
there's so many different variants, right?  And when we say coinswap, let's
say in the Bitcoin privacy community, we're referring specifically to a slight
finesse on that idea.

This was published by Greg Maxwell around the same time as he published
coinjoin, back in 2013.  And the idea here is that instead of publishing that
preimage or that secret, which enables the other transaction onchain, which
would make it obvious that a swap is happening, and which would tie the two
transactions together, instead of doing that, you swap the secrets offchain
sort of optimistically, and then you broadcast the two payments without ever
revealing the tied-together secret itself onchain.  So, that's what we call a
coinswap.

**Mark Erhardt**: So, let me try to recap that.  Generally, the concept here
is that two parties move funds into a shared custody, and then while they
might have a recovery option, they tie together two transactions so that
either none of the two or both of them happen at the same time.  And this
allows them to create two transactions that pay each other that seem
completely unlinked.  This happens, for example, with an HTLC, or well maybe
an adaptor signature is maybe more the standard example, where one of the
signatures that they exchange is tweaked, and the tweak is missing, but the
other signature uses the same tweak.  And then, when one of the two
transactions is broadcast, the other one can be broadcast too.  And that way,
because the funds are held by both owners together in a 2-of-2 situation, they
can ensure atomicity, either both or none.

**Adam Gibson**: Yeah, that's a very good explanation.  I think the only thing
that was missing there is that it's two separate shared custody amounts
needed, not just one, but apart from that, I think that was a perfect
description.  And I think that might be a nice lead-in, because we haven't
really talked about Babilonia itself, that might be a nice lead-in there,
which is that you said at the end, the two transactions look totally
disconnected.  And of course, the obvious problem with that is if the two
parties are deciding to swap, let's say, 1.000 bitcoin, then both of those
transactions are broadcast onchain without any connecting secret, but they
both have exactly the same amount; or perhaps there's a fee difference, but
basically exactly the same amount.  And this is a problem that is always going
to crop up and is really difficult.  And Chris Belcher spent a lot of time
designing a system to try and at least partly address that by having
essentially networks of swaps to break amounts into constituent parts.

So, you keep seeing this pattern repeating of people trying to find ways to
break the connections between amounts of funds by sort of finessing what the
amount is, whether it be in denominations, whether it be splitting into
sub-amounts, and so on.  But often, those solutions have the problem that they
end up creating more and more transactions.  Whereas notice with payjoin or a
payjoin-type design, you partly don't have that problem, well you don't have
that problem, but that problem doesn't really arise because all you're really
trying to do is to make the payment hide not the amounts, but the fact that
there was a collaboration which mixes history.

**Mark Erhardt**: Where payjoin, of course, is a way of paying the recipient,
and the recipient can also add an input to the transaction.  So, the recipient
can combine that with a payment themselves or with a consolidation, for
example.

**Adam Gibson**: Yeah, absolutely.  And I just realized I said something
slightly wrong there, which is it is true that payjoin is trying to hide the
amount.  Whether it does or not is a kind of an interesting question.  It kind
of does and it kind of doesn't.  So, with the Babilonia concept, what I'm
saying is, "Oh, look, this old history and recent history of developing a way
for there to be a statistical outcome to the payment creates a situation where
there is actually a payment, and we can make it like a payment of a random
amount within something like a payjoin, where the two parties are
collaborating anyway".  So, I'm saying add this extra layer of cryptography
which makes it so that instead of me paying you a fixed amount, like 1
bitcoin, I'm creating a situation where there's a distribution where the
expected payment I make is, let's say, 1 bitcoin, but I mean it could be zero
perhaps, more realistically; but the actual payment I make could be anything
from -0.5, well it could be anything.  Okay, I haven't talked about like the
mechanics of it, but does that kind of describe what it's doing?

**Mark Erhardt**: So, let me try to phrase it back to you.  Babilonia proposes
that you overlay a coinswap situation, where two people are just trying to
move around funds in order to obfuscate the ownership with a probabilistic
payment, and in our News item we speak about a bet, and this probabilistic
payment would, in the long run, as people keep participating in that, end up
being roughly net zero.  But it would obfuscate the amounts more efficiently,
because now the amounts actually diverge based on this random bet.

**Adam Gibson**: Yeah, that's sort of half correct, because the thing is, my
proposal is actually coinjoins, not coinswaps.  But in the paper, I am sort of
observing rather lazily that actually, this could be even more interesting in
the form of a coinswap.

**Mark Erhardt**: Well, sorry for the idea!

**Adam Gibson**: No, no, I mean I actually suggested it already to the Citadel
guys.  I said, "Look, you should really look into it, maybe!"  I think it's
interesting.  But I thought just to limit the scope of what I'm trying to
write out, because it's already quite complicated, I thought let me write out
a version of it where, like payjoin, you try to make the payment look, so to
speak, non-suspicious.  And then, I mean you mentioned the idea of bet versus
probabilistic payment, and I think that's important as well, is that you could
just read the protocol as I put it out and say, "Well, this is a design for a
trustless casino", because it actually is.  I mentioned early on in the paper,
I say, well, the earliest kind of example of this was Satoshi Dice, right?
And it's interesting to compare, because what they did with Satoshi Dice is
they had a specific phrase they used.  They didn't call it trustless because
it isn't, they called it sort of provable after the fact.

**Mark Erhardt**: "Provably fair", I think was the term.

**Adam Gibson**: Provably fair, thank you.  So, the idea was that obviously,
you're not in an actual real casino and you can't watch somebody rolling a
dice or spinning a roulette wheel, but what you can do is watch blockhashes.
And so, they say, "Well, look, we're going to pay out according to a formula
based on the next blockhash.  And you can check, because you can see the
blockhash, whether we did it fairly or not".

**Mark Erhardt**: Right.  I think they pre-committed to some sort of nonce or
something, and then the second part of entropy was coming from the blockhash.
So, later they would reveal what the preimage was that they used for their
commitment.  And then obviously, they couldn't have known the hash, I think
the suffix of a blockhash, and because they wouldn't know the blockhash, now
they had two sources of entropy that were unrelated, that weren't both
controlled by them.  So, after the fact, by revealing the preimage and by
people knowing the blockhash, they knew all the inputs.

**Adam Gibson**: Yeah, exactly.  There's a lot of sort of finesse around it,
and there's caveats you could look into, "Is it fair?" etc.  Point is, the
general idea is pretty clear, provably fair.  You can check after the fact.
But what you can't prevent them from doing is just taking your money.  They
could just take your money.

**Mark Erhardt**: One of the big problems was, of course, that because it was
based on the blockhash and because you could reorganize if you had a lot of
hashrate, there were some suspicions that some big miners might, or I don't
know if it actually ever happened, but someone could have reorg'd a block
after losing a very big bet, and that could have put off the mining
incentives, like skewed them.

**Adam Gibson**: Yeah, absolutely.  As I said in the paper, there are caveats
and there are things you can look into.  But I think just at a high level,
it's clear that if you can create a scenario where the betting outcome is
provably underivable by any party, that's what you actually want.

**Mark Erhardt**: Sorry, I have a thought jumping into my mind.  Would there
be a way maybe to make it only be possible to find out who won the bet a few
blocks later, so that the commitment were onchain and it couldn't be reorg'd
out, but then you only find out later?

**Adam Gibson**: Are you talking about a finesse on the Satoshi Dice idea?

**Mark Erhardt**: Well, maybe a finesse on your idea, that maybe one
contributing factor could be sort of the third block after your transaction
that locks in the bet confirms, but then of course, you still have the reorg
problem.  But yeah, I don't know if there were a way to make it so that nobody
could go back in time to change the outcome.  But sorry, we're getting really
in the weeds here!

**Adam Gibson**: Yeah, sure.  I mean, yeah, you could always make it more
expensive, right, to attack the system.  But I think this is sort of
qualitatively what was originally Kurbatov's idea, is sort of more
fundamental, which is that what I think it really hinges on is this concept of
atomicity, just as we were earlier speaking about coinswap.  The most elegant
way to do it, which is the way I do it, is with adaptors, and indeed the way
Gerhart's paper does it.  It's interesting that Kurbatov's original paper did
it using the fact that when you pay an address, you're paying a hash, and so
that when you spend from an address, you're revealing the preimage of the
hash.  But it's the same basic principle.  That's just a little bit less clean
way to do it than adaptors.  So, this idea that when you spend atomically, you
have to reveal a secret, which occurs in coinswap or atomic swaps, also is the
heart of the idea here, because otherwise you have this kind of unresolvable
standoff between two parties who need to know a secret and have to reveal a
secret, and you have to make it so that neither of them can predict what the
outcome will be.  But the heart of the trick that Kurbatov's OP_RAND emulation
had, which has now been extended, is just that, using atomicity to make it so
that both parties…

But maybe I can sort of very high level describe the sequence of steps, which
is that basically, if you think of it as Alice and Bob, Alice being the sort
of proposer or dealer of the bet, and Bob being the player, so that the dealer
sort of commits upfront to a set of possibilities.  In my case, that's
specifically a list of curve points and the proof of knowledge that they
actually own those curve points.  And they're going to prove that an adaptor
that will be revealed when they give their co-signature will reveal a secret
key which decrypts one of those list of possibilities, one of those list of
private keys.  And on the other side, the player also has to give a ZKP that
their output address, the one that's going to be the payout address, is formed
from their own key plus one of the original curve points they were given as
possibilities, without revealing which.  So, with those two ZKPs in hand on
both sides, it's safe for -- well, the dealer will give the adaptor, of
course; you have to verify an adaptor before the secret gets revealed.  So,
when both sides have seen the proofs, the dealer can pay into the address
knowing that with a probability 1 out of n, the player will win.

So, remember that the dealer had n curve points that they sort of handed over
to the player.  The player secretly chose one of them, constructed his output
address, including that secret choice of one of those points.  Both sides ZKP
that they did it correctly.  And then, when the dealer makes the payment, they
reveal the preimage behind the adaptor.  The player takes that adaptor and
uses it as a secret key to decrypt one of the points.  And if it's the right
one, then they get the money; and if it's not, then after a time delay, the
dealer can swipe the money instead.  And then, you use the kind of typical
optimistic taproot style approach, where if the other guy is lost, well,
neither of them want to lose privacy, so they'll just agree to sign out to an
ordinary address instead of to a timelocked address.

**Mark Erhardt**: I see.  I was wondering how the money was recovered after
the commitment.  So, they construct an output together, where both parties
have committed to secret information.  And in the dealer's side, they have a
set of choices that they commit to; and on the player's side, they commit to
one of those choices.  If they guess right, they can immediately spend; if
they guess wrong, the dealer can take back the money after some time.  The
recovery is pre-known, right?  So, you could just say, after 10 blocks, or
whatever, it can be spent.  Oh, right, you don't want to reveal onchain that
you have the locktime construction there.

**Adam Gibson**: Yeah, you'll put a CSV branch in the output.  So, if when the
player looks at the adaptor, they see, "Oh, damn, I lost.  I can't actually
spend this key", he'll do nothing.  And after a CSV of, I don't know, 20, 100
blocks, whatever it is, then the dealer could take that money.  But instead,
this is the case where if the two parties are interested in privacy, then
they'll agree to cosign a spend-out without a CSV branch, which just has the
same effect.

**Mark Erhardt**: I was wondering whether you could just maybe have the
recovery transaction already encoded with a locktime and signed by both.  But
just by it having a locktime that is set to the future, you could have the
recovery already pre-committed by both sides, and then you don't need the
on-script footprint.

**Adam Gibson**: Yeah.  We avoid it anyway in what I've written in the paper
by -- I actually can't remember if we do it the way you just said, which
sounds definitely the right way to do it, or whether I had it done where --
that's a detail, but I think you're right that that is the most optimal and
efficient way to do it.  Yeah. I'll check that.

**Mark Erhardt**: Because then you don't need an onchain script that would
reveal that something special was going on.  Anyway, so yeah, that's pretty
cool.  And so, what amount would they be playing for?  Just a small portion of
the funds in order to mix them around and move them around and obfuscate the
ownership graph?

**Adam Gibson**: Yeah.  So, that's left open, in terms of what fraction of the
input that you choose to bet.  I guess I should take this opportunity to
mention the second layer, which I found was necessary.  I didn't realize
originally, and I had to update the paper, because I realized that because
this has a structure of two parties funding a MuSig and then spending out of
it, there was actually a privacy leak, which was because, let's say you choose
to make a pot for the bet of 1 bitcoin.  The problem is that if you just make
a single simple bet of 1 bitcoin, well, let's say both parties contribute 1
bitcoin, so the pot is 2 bitcoins, the problem is it's quite trivial to see
that such a bet has occurred, because there's two transactions here, not just
one.  There's the pay into the MuSig, and then there's the pay out of the
MuSig.  And I mean, avoiding the details, basically even though there's change
outputs and there might be some slight details here, there will be a
fingerprint, which will say, "Oh, look, there's an amount there and an amount
there", a bit like how in basic payjoin, even in basic payjoin, there can be
cases, depending how you set it up, where you kind of are giving away the
amount.

But I realized that actually, you can avoid that problem, admittedly at some
cost, which is this.  You say, instead of just making one bet, offchain we're
effectively making five bets.  And you presign the five bets, the five payouts
for the different bets.  But the nice thing about that is it's not just a case
of, "Oh, let's make five bets of 1 bitcoin", because the problem then is a
blockchain analyst can still say to himself, "Well, I think this is a bet.
I'm going to look at the possibility if it's one or two or three or four,
divided into an integer number of equal-sized bets".  But they don't have to
be equal-sized.  All you have to do is split the bets into private and unknown
partition.  So, like, the first bet will have 72% of the amount; the second
bet will have 19% of the amount; and the third bet will have whatever that is.

**Mark Erhardt**: 9%!

**Adam Gibson**: Thank you very much.  You're very good.  But that split will
be completely secret.  Nobody else will know it.  The result will be, because
there'll be a certain probability of win on each one of these bets, which
itself can be different, it'll be not just too computationally difficult, but
it will actually be impossible for somebody to deduce that the specific
payment in the second output is correlated to the payment in the first
transaction.  I just wanted to mention that because I thought it was a cute
little extra.

**Mark Erhardt**: So, basically, this would look now like a deposit into,
like, two UTXOs combining into one output and then a branching out payment
into multiple different outputs.

**Adam Gibson**: Actually, the first transaction structure will be almost
always, it could n in, 2 out, but generally perhaps 2 in, 2 out; both
participants contribute something.  In the funding transaction, let's say the
dealer participant, one of the participants will receive change, and the other
party's change is deferred to the second transaction.  But because of
presigning, it's safe in the normal way.  And so, you can actually spread the
change out to make both the transactions look like very typical payments, or
at least I'm claiming that; it's maybe not exactly true.  But the negative of
my splitting idea is that if the two parties fall out of agreement, then
they're suddenly broadcasting five payouts onchain and not one.  But you've
already kind of lost, if the two parties don't agree, you've completely lost
the privacy properties anyway, because you'll have scripts in there, or in
this case, you'll have five payouts.  It'll just look very weird.  Well, that
was pretty quick, but I mean, I think we've pretty much covered the idea, more
or less.

**Mark Erhardt**: I'm a little wondering still, obviously you need to split
the commitment from the payout, because otherwise, if you did it all in one
transaction, one of the two parties could renege as soon as they know the
outcome, and they know the outcome as soon as they see.  Would it be possible
to set it all up in one go, and then the reveal would be separate in some
fashion?

**Adam Gibson**: I'm actually forgetting now whether I had it where the single
adaptors is acting as the secret key for all of the reveals, or I can't
remember.  I'd have to look back at the paper.  It's been a while.  I'd have
to get back to you on that, like, how the splitting affects the reveal of the
secret behind the commitment, is what you're asking, I think?

**Mark Erhardt**: No, I think I'm asking, so one of the unattractive things of
how I understood it works now is that you have two transactions, right?

**Adam Gibson**: Yes, absolutely.

**Mark Erhardt**: So, I was considering whether it would be possible to have
the setup transaction immediately create the payouts, but then it's the
outcome only being looked at afterward.  Anyway, if there were a way maybe to
make it all in one transaction, but the outcome still being revealed
afterwards, you could still have a recovery where people just get back their
money after some time, but if they don't agree… anyway.

**Adam Gibson**: Can I just weigh in there, because I suddenly obviously
thought about, wouldn't this whole thing be way better if it was just one
transaction?  I think the simple answer is you could only get that by -- I
mean, think about Lightning, right?  The way Lightning works is you enter into
joint control.  Once you're in joint control, you can do a lot of things
offchain, right?  So, the way I see it is you could have someone or two
parties creating a stream of bets by doing one setup, and then each individual
bet could be done from that.  So, in other words, if you're starting fresh
with two participants who've never talked to each other, and it has to be
because you have to enter into joint control to start contracting with each
other, I don't think you can avoid that from fresh, which is what we are
thinking about.  I'm claiming it's impossible, but maybe I'm wrong.

**Mark Erhardt**: Right.  I'm thinking a little bit about the coinjoin in,
what was it, in Phoenix?  ACINQ does this where every onchain payment that you
receive to the Phoenix wallet is immediately --

**Adam Gibson**: Yes, spliced in.

**Mark Erhardt**: No, it is possible to splice it in by revealing something to
the counterparty, and then you immediately get a Lightning channel.  But if
you just wait, it becomes unilateral control.

**Mike Schmidt**: Is that the Swap-in-Potentiam?

**Mark Erhardt**: Thank you, Swap-in-Potentiam.  So, I was wondering maybe if
there are known dealers or something, you could set up the control
in-potentiam when you get paid yourself, and then you could enter the bet from
there.

**Adam Gibson**: I'll have to believe you on that one.  I have to read in
Swap-in-Potentiam.

**Mark Erhardt**: Yeah, maybe.  Yeah, sorry, I'm really getting into the weeds
here.

**Mike Schmidt**: Adam, where do we go from here?  You have a v2 that you made
reference to around the amounts of additional obfuscation; is there a v3?  Is
there a group working on this?  You mentioned the Citadel folks, maybe, and
CoinSwap?

**Adam Gibson**: I certainly shouldn't claim on their behalf that they're
working on it.  I just told them about it, and they said, "Well, we're kind of
busy, but we might look at it later"!  But no, there isn't really.  I set up
an example website, thimbly.org, where I just put, "If you wanted to try it on
signet, you could just enter it".  The interesting thing about that, which I
found from a kind of UI perspective is a problem, is I was saying, right,
somebody wants to come along with their wallet and make this bet with this
dealer.  Obviously, this isn't really the idea.  The idea is it should be more
P2P, and you could do it literally on Bitcoin Core nodes.  I mean, it's set up
that you can do that.  But I thought, just for fun, here's a website.  You can
literally try a bet out on signet, and it does work.  But the interesting
thing about the UI is that you have to sign a PSBT, because the dealer's
engaging in a MuSig with you.  And I found that I could only do it with
Sparrow and Core.  It's pretty easy, I suppose, for a technical person to do
it.  But I think that's probably an example of many other projects where
there's this attempt to create some kind of collaborative, offchain
negotiation of something, is that your coins are in your wallet, but
somebody's coming along and saying, "Oh, please cosign this weird transaction
with me".

So, yeah, it's set up, and you can try it out.  But yeah, you need to use
either Sparrow or Core.  I don't think anything else would work.  Hello?  Are
we here?  Am I there?

**Mike Schmidt**: We're here.  You're there.  We're here.

**Adam Gibson**: Okay, so I've made my point, yeah.  So, there we go.  But
that's it, there's nothing else.  A v2, that's just the second version of the
paper.  I don't really have any other specific plans.

**Mike Schmidt**: Okay, cool.  Maybe I'll just drop one piece of Optech
history that waxwing mentioned earlier.  We did have Oleksandr on in Podcast
#340 to talk about, "Emulating OP_RAND", which was the Delving discussion that
Adam mentioned earlier.  So, if folks are curious about that piece of the
history that we went through, folks can look back at that newsletter or that
podcast and transcription as well.  Murch, anything else on this item?

**Mark Erhardt**: No, I think I have gotten all my brainstorming in!

**Mike Schmidt**: Okay, great.  Adam, thanks for joining us.

**Adam Gibson**: Thank you.

_Update on silent payments light clients_

**Mike Schmidt**: We appreciate your time.  You're free to drop a few other
things.  Moving to our second news item titled, "Update on silent payments
light clients".  We have our second guest, Rob, to join us to talk about this
one.  Rob, with silent payments, you obviously have this static address or
this identifier that doesn't leak anything onchain.  But as part of the
mechanics there, there is this sort of cost to the receiver that the receiver
has to scan every block to find their money essentially, which is cumbersome
for a desktop, but pretty brutal for something like a phone wallet, let's say.
There was this discussion that we covered in Newsletter #305 about how light
clients should or could get scanning data, and it was sort of an open question
on Delving that we talked about back in June 2024.  And now, you've sort of
revived this discussion, and you've done some benchmarking and whatnot.  So,
maybe you can talk about your motivation, what you did, and how you started
picking up this conversation?

**Rob Segers**: Yeah, so I'm coming at this from a totally different
perspective, which is UX and UI and more the application layer.  And so, we
have sort of accepted that creating a new address every time is normal, but
actually, from a UX standpoint, it's absolutely horrible.  Imagine you have to
recreate a new email address every time to receive an email, because or else
everyone else can see what every email is you got.  It sounds absolutely
absurd.  And so, from the UX perspective, silent payments is total magic, and
you have to get there.  So, the arc that I went, and I'll just say that arc
that I took, and you sort of glanced over that.  So, the problem that silent
payments solve is indeed that static address, but it creates a new problem,
because the silent payment address is two public keys glued together, and --
I'm going through my notes here -- the sender is deriving things.  So, you
can't predict your own payments anymore, you've got to find your own money.
That's the problem, it's shifting a problem to the receiver.  And so, that is
a costly thing to do.

**Mark Erhardt**: The sender basically creates a shared secret based on the
inputs that they're using with your silent payments payment instructions.  And
then, you need to scan for the shared secret based on your scan key.

**Rob Segers**: Yes, the inputs that someone used.  Yes, so a silent payment
address, SP1, Sparrow supports it today, it's really not great today.  It's
really two parts.  It's a scan key and a spend key.  And each of those keys is
a keypair, so there's four keys.  And so, you need to find your own money
where money could have been sent, because you need to derive it.  And so, for
every transaction, there's this 33-byte value called the tweak, which is built
from public information.  And every wallet downloads that same tweak.  And the
scan key is what turns a tweak into an actual address that you can find out,
"Okay, one of my addresses was paid".  And so, the question really is, who
does the work?  Someone has to produce these tweaks, your phone can't, that
requires a full node because you have to go back all the outputs.  But
checking the tweak is free.  So, I did some measurements, I did a lot, the
discussion will get there.  But checking a tweak's like 65 microseconds.  If
you need to do a day of blocks, 144 blocks, you're at a couple of seconds.

**Mark Erhardt**: Sorry, when you say checking a tweak, do you mean checking
that the tweak was correctly derived from the transactions, or checking
whether the tweak with your secret creates a payment?

**Rob Segers**: It's money that was pointed at you.  So, the tweaks are the
same for everyone.

**Mark Erhardt**: Okay, so once you have the tweaks, yes.

**Rob Segers**: There's a tweak for a transaction that's the same for
everyone.  And then, you have your scan key that derives an address for you,
so that you know, "Okay, this money was intended for me".  So, the sender
derives something, and the receiver also has to derive something.  And the
deriving at the receiver part is a computation that needs to happen, which is
the framing of the problem at hand with silent payments.  Because the UX is
great, you got this static payment address, and the sender deriving, it's
trivial because it's just its outputs.  There's like a sum and a hash going
on.  And then, the receiver side has to find his money, literally.

So, there's two solutions proposed.  So, if you hand over your scan key to an
index server, that server becomes trusted.  And that's the current design with
Frigate, which is the thing that Sparrow connects with, which is also by the
same guy, Craig Raw, if I'm right.  And so, it's better than your privacy
being laid bare onchain, but that server still sees every payment that you
will ever receive, including all the old ones.  And then, the other version is
where every wallet gets identical data, but the server has no idea which
transaction you cared about.  So, if there's a tweak that's intended for you,
you just get the full block.  And so, that's two propositions.  Now we're in
the Delving Bitcoin discussion.  And the question was, "Well, we need to do
some measurements, which design is feasible here".  And so, there's filters,
which is by setavenger, 2024 spec, which is saying it's just filtering based
on taproot outputs.  So, it only sends you the taproot outputs.  So, okay,
your payment might be in this block, in these taproot outputs.  So, they're
cheap because they filter, but they produce false alarms, apparently false
positives, and that hasn't ever been built yet, as I've found.  Or sending the
full payload, sending the full block, if there's a tweak for you, which is
what BlindBit Oracle v2 does, which is setavenger's index server software.

**Adam Gibson**: Sorry, can I ask a question?  Is that kind of filtering the
same as the kind of filtering we have in BIP157?  Is it that kind of
filtering?  Do we know?  I'm just curious what the technology is.

**Rob Segers**: What kind of filtering?  I'm not sure, but it's filtering only
the taproot outputs.

**Adam Gibson**: Right, that makes it easier, yeah.

**Rob Segers**: It's sending not the full block, it's sending only those
outputs, because only those could be silent payments.

**Mike Schmidt**: I think it's BIP158 compact block filters.

**Adam Gibson**: It's the same type, is it?  Okay, thanks, cool.

**Mark Erhardt**: Yeah, basically, so BIP158 allows a client to pull the
filter with their own wallet data to see if they got paid and they might get a
false positive.  But for silent payments, really you only care about P2TR
outputs, because only a P2TR output could be a silent payment output, because
it'll always create a P2TR output.  So, if you reduce the filter to only P2TR
outputs, you can make much smaller filters, because there's fewer of them.

**Rob Segers**: Exactly, yeah.  And so, there's two proposed solutions there.
Either the filters send less over the line, less bandwidth.  So, two proposed
solutions there to determining what the client sends, either the full block or
the filters.  So, I did some measurements, every block since taproot, 255,000
blocks, no sampling.  And so, the numbers, let me peek, yeah, the difference
is not as big as expected, because it boils down to you still need the tweaks
anyway.  And the tweaks are 6 GB.  So, the first one with a silent payment is
6 times smaller.  The second finding was that it's about 2x, right?  A wallet
on the filter route still needs, like, 6 GB of tweaks, and it's 1 GB of
filters.  So, it's 7 GB, and the full payload is 15 GB.  So, that ratio is
only 2x, which isn't super huge.  What was interesting was that the ratio
dropped, the full payload is nearer to 3 MB daily today.  And so, the
discussion was framed on bandwidth.  Like, okay, is the filter going to save
us so much bandwidth that that's going to be the better solution?

But perhaps what we gain with sending full blocks is not communicating to the
server, because a second request has to happen to fetch the actual
transaction.  You send more data over the line, but you get more privacy.  And
so, does a hit force your wallet to go back and ask the index server for
something extra?  That's a signal in and of itself.  And so, that could be
framing of the discussion going forward, where that bandwidth question might
not matter as much.  And then, we could go, okay, perhaps we can make this a
setting.  But then, there's the history of BIP37 and Bloom filters, where
light wallets could tune privacy against bandwidth, which is a bit of a
similar discussion, apparently.  And then, every wallet chose bandwidth,
because that's the UI, the UX, I guess, angle again, where I guess I'm usually
coming from.  And that got turned off for a DoS thing, not for privacy.  So,
perhaps the better thing is to settle a default now, okay, sending the full
block anyway, which tells the server nothing about you.  That's a little bit
perhaps what these measurements could indicate.

**Mike Schmidt**: What has reception been, Rob, to the, I guess, refreshed
data, whether public feedback or private feedback that you've gotten from
folks on what you've done here?

**Rob Segers**: What I've done here, the more feedback I got was more on the
application layer side of things, and not specifically the measurements
itself.  The Delving Bitcoin thread is still where it's at, because I wanted a
new account, I couldn't join the actual discussion.  It's posted in the
Bitcoin mailing list, and some PRs and things happened related, but the
reaction was more towards the application layer.  Silentpayments.net was a
website that I made, where I combined silent payments and Lightning and Cashu
actually into one name.  Again, the UX side of things, which did have quite
positive feedback, because that's where I could see this going, is you just
have one name, and it's both onchain and Lightning, and you can just send
money to it depending on the sender's preference.  So, that's some more things
on top.  Also, DNSSEC proving on SeedSigner, that was something interesting,
but that's not been actually run on actual SeedSigner, it's all in a simulator
that's live.  But on the measurements themselves, nothing yet so far, more on
the application layer.  I've been building more on the application side of
things, and UI and UX, and not so much these lower-level technical things,
because I'm not all too comfortable in these lower-level technical things.

**Mike Schmidt**: Well, I guess the next steps here sounds like, audience,
keep an eye on the mailing-list posts as well as that potentially revived
Delving thread.

**Rob Segers**: Exactly.  So, there's perhaps one thing more to add, is a
condensed pre-draft, something that merges the existing specs with the
measurements, and that's up for, I guess, the best case is someone to disagree
with, to replicate, refute, and just start a discussion.  And then, where this
could be going, the silent payments server that I've started running is, I
like the provably fair framing, where I'm publishing hashes to nostr, where
you can check if it's all correct, because what can happen is not a silent
payments server loudly lying to you, but silently leaving tweaks out, which is
what actually happened in 2024 with the Cake Wallet users, that they didn't
see payments coming in.  And so, silent omission is something that is still a
problem, and so publishing hashes is something that I threw on top.  But then,
down the road, this could go even further, and it's on the silentpayments.net
roadmap also.

**Mark Erhardt**: So, I'm a little confused at the trade-off.  So, the two
options for serving the silent payment data, one was the approach to have a
separate filter just for taproot outputs that a light client would be able to
scan against.  And then, if they have a false positive or a real positive,
they would download the full block from someone, but not necessarily the one
that served them the filter.  And then, the other one would be to just stream
the tweak data directly for each P2TR output, which then would enable the
recipient to not just scan for their scan key in the filter, but directly
calculate whether anything paid them.  But in either case, I'm not quite sure
how one or the other would be a loss of privacy.  In either case, you sort of
reveal that you're interested in potential silent payments, because you're
downloading either tweak data or a filter specifically for P2TR outputs.  But
in neither case can the server tell which transaction you actually were
interested in.

**Rob Segers**: Fair, but in the filter case, because there is a conditional
request, that again happens.  And that conditional request in and of itself is
a signal to the server compared to just getting it all at once.

**Mark Erhardt**: Oh, I see, the conditional request of how many blocks do you
want the filter for, and you can calculate the filter, "Only give me new P2TR
outputs that weren't spent in some range of blocks", right?

**Rob Segers**: So, you're getting only the filter, and then you still have to
do the follow-up request to get the full thing.  And that request, that's what
it's about.

**Mark Erhardt**: Right, but you can pull a block from any peer.  You don't
have to pull it from the person that you got the filter from.

**Rob Segers**: That's true, yes.

**Mark Erhardt**: If you just get a block from someone, that is one of the
most common P2P messages.

**Rob Segers**: You don't have to ask that server.

**Adam Gibson**: But, Murch, if you're a node, yeah, then what you're saying
is true, but aren't we talking about non-nodes, a light client?

**Mark Erhardt**: Oh, if you have only a single server, yes.  Yeah, but many
light clients have multiple connections.  But yeah, if you're connected to a
server that serves you the data and you would only be talking to them, yes,
now I get it.  Now I get the concern.  Thank you.

**Mike Schmidt**: Rob, thanks for your time.  Thanks for joining us today.
You're free to stay on or drop if you have other things you're working on.

**Rob Segers**: Thanks for having me, yeah.

**Mike Schmidt**: Cheers.  Releases and release candidates.  We have three
this week.  And if you're wondering why I'm talking about them, we do not have
Gustavo today.  He's out.  So, Murch and I are leading the Releases and
Notable code segment.

_LDK v0.3-rc1_

LDK v0.3-rc1.  This is kind of a big one.  I'll list a few of the items from
this RC.  Obviously, read the notes before you test.  But RC1 includes the
ability for LDK users to fee bump a splice that's waiting to confirm, and you
can do that using RBF.  And you can also add and remove funds in the same
splice.  Also, and this surprised me that it's taken so long, but anchor
channels are now the default when opening channels in v0.3.  And also, apps
built on LDK now have to explicitly say, "Yes", to an incoming channel instead
of automatically accepting it, which was the previous behavior.  And, Murch?

**Mark Erhardt**: Well, that was a slippery slope there, Mike.  A year ago,
nobody was doing anchor channels.  Earlier this year, we were like, "Yeah,
some people are doing anchor channels".  And now you're like, "LDK, why did
this take so long?"!

**Mike Schmidt**: All right, maybe a little harsh.  When anchor channels...
There is a heads up here for developers.  If your app issued a BOLT11 invoice,
we talked about this back in #405 and #407, but if you're issuing a BOLT11
invoice with payment metadata on an older version, upgrading to this version
makes those invoices stop working.  We talked about some of the weird payment
metadata in Podcasts #405 and #407 as well.  And I guess the general
disclaimer for users is read the API and compatibility notes before you test
this particular release.

_LDK v0.2.6_

Second LDK release, LDK v0.2.6.  This is a security fix for the current stable
line of releases, so not anything related to the v0.3.  There's two bugs that
are addressed here.  The first one is a crash bug.  If your LDK node forwarded
two HTLCs with the same payment hash and the second one got rejected, the LDK
node's channel state could get saved in a form that it can't load back.  So,
the node goes down and can't come back up, at least not cleanly.  And the
second security fix is one that could result in loss of funds.  If a peer
starts a splice with you, they could trick your LDK node into putting too much
toward fees, and that extra doesn't necessarily go to miners, it actually goes
into the peer's own output.  So, the peer can basically take money through
some of the fee math.  So, if you're on v0.2, upgrade and grab these two
fixes, among others.

**Mark Erhardt**: I think if you're on any Bitcoin software this year, you
just want to keep your eyes peeled and watch carefully what's happening in the
corresponding repositories.  Obviously, it's also gotten easier than ever to
check what code changes went into releases.  So, if you subscribe to 'trust
but verify', you should maybe point some of your compute at making sure that
you want to upgrade, but you kind of do want to be on top of things these
days.

_BTCPay Server 2.4.4_

**Mike Schmidt**: Yes, and not surprisingly, the last release is in a similar
vein to Murch's energy here.  This is a BTCPay Server 2.4.4 release.  It's a
follow-up security release after a 2.4.2 incident.  I believe we talked about
in #418, where attackers stole LND macaroons and potentially funds as well.
This release removes BTCPay's old BitPay-style API keys entirely.  So, they
have this notion of these Greenfield API keys, but also these old API-style
keys, and it removes the old-style keys.  Existing Greenfield keys still work,
but if you have integrated using the BitPay-style keys, you have to move those
to the new Greenfield API keys that have been around for a while.  So, no more
BitPay-style API keys.  Also, in BTCPay Server, changing an invoices state now
requires, I guess, proper authentication or authorization, and a restricted
API key cannot create unrestricted one anymore.  API keys are now stored in
hash instead of plain text.  There's more on that in the code section that
we'll get to.  There's some changes to the Docker setup, which tightens some
access and enforces a little bit more permissions, I guess, when you're
setting LND up in Docker.

So, why are all these LND changes there, because we're talking about BTCPay?
Well, BTCPay says attackers are actively hitting LNDs password-change
endpoints on servers.  There's been some chatter about this.  And the idea
here is that people ended up reopening LND API access after the 2.4.2 fix for
BTCPay Server, and that was causing issues.  So, if you did do that, close
that gap and check out the release notes for some of the details there.  Two
last points here.  If you use the web-hosting billing plugin for BTCPay
Server, you need v4.0.0 and a new Greenfield key.  There's a migration guide
around that particular plugin.  And also, back to, I guess, Murch's point
earlier, everyone running BTCPay should upgrade and read these breaking
changes as well.

**Mark Erhardt**: I don't remember who said it, but there was this tweet
recently, "We're watching the future being born, and in the transition period,
we live in the time of monsters".  And it was more pithy in the written word,
but yeah, I must say it is quite fascinating what we can do with AI assist
now, and it has really changed how people work with code and what they can do
in security research, and it is a transition period.

**Adam Gibson**: Guys, I want to say you went one hour and a half without
being an AI podcast; congratulations!

**Mike Schmidt**: And now a moment from our sponsors!

**Mark Erhardt**: Well, it's the topic of the time.

**Mike Schmidt**: Well, it's not something that we normally cover, which is, I
mean, we have covered some things here and there, but obviously the Liquid
thing, we had Core Lightning (CLN) that we got into pretty deep with Níckolas,
and their thinking about rolling out binary-only, which immediately get
decompiled.  So, yeah, it's quite a crazy, crazy time right now.  And so, it's
not surprising that not only these three releases that we're covering this
week, but other recent releases that we've covered, in addition to some of the
PRs that we'll get to later, are around security-related work.  And I actually
think that, was it Nicolas from BTCPay, that had some tweet in the last weeks
or so that, "Hey, we're not adding any features.  We're spending the next X
months", or versions or whatever it was, "just on security and hardening or
moving old stuff".  So, we see some of that here, even with the BitPay-style
API keys being removed.  So, some legacy-type stuff that could have issues.

So, I guess we can move to Notable code and documentation changes.  Murch is
going to take us through a handful of Bitcoin Core ones, and then I'll pick up
with the remaining items.  Murch, why are there so many Bitcoin Core PRs?

**Mark Erhardt**: I have no idea.  Oh, well, yesterday was branch off.  So,
presumably a bunch of stuff got merged yesterday and today, but that would
have been after our, what is it?

**Mike Schmidt**: Cut off, yeah, publication.

_Bitcoin Core #35949_

**Mark Erhardt**: Yes, thank you, publication cut off.  So, yeah, I'm actually
a little surprised that there are so many, but let's get into it.  So, Bitcoin
Core #35949 updates how miners build blocks.  If you're building block
templates, your Bitcoin Core node will now start to be forward-compliant to a
rule that is being proposed by BIP54, the consensus cleanup, which mitigates
one of the time warp issues that was identified before BIP54 was written.
This is the Murch-Zawy attack.  So, if you're familiar with the time warp
attack, people can basically change how the time is progressing in blocks in
order to fudge with the difficulty.  In the Murch-Zawy attack, you could still
do some time fudging, even if you stuck to the originally proposed BIP54
rules.  Zawy had a Delving thread on that a while back, and I had an idea too,
how to make it more potent.

So, the main issue that you need to fix is you need difficulty periods to have
a positive amount of time.  So, the last block in a difficulty period has to
have a higher timestamp than the first block in the difficulty period, and
that fixes this issue.  Otherwise, you can sort of make the time go forward a
lot and then rewind back a lot, and that allows you to still drive down
difficulty and start producing blocks much faster.  So, our new block
templates will always have a positive time on the last block compared to the
first block in a difficulty period, which honestly should happen anyway,
because 2,015 blocks later, you should have had at least one second pass,
right?

_Bitcoin Core #34931_

Anyway, that was that one.  Second one is Bitcoin Core #34931.  This one fixes
an issue in the LevelDB wrapper.  And in the LevelDB wrapper, there was no
distinction between whether you could not deserialize a UTXO from disk or
whether a UTXO was not present in your chainstate.  So, if you're missing a
UTXO that you are spending in a transaction, obviously that transaction is
invalid; and if it's in a block, that block is invalid, because you can't
spend funds that don't exist.  But if there were some deserialization issue
with one UTXO, it would have also shown up as the UTXO not being present,
rather than just, "I failed to read something".  And then, it would mark the
block as invalid and that would fork you off the chain.  As far as I
understand, there is no such deserialization issue.  Someone just found that
these two situations should be properly distinguished, probably by throwing a
lot of compute at our repository.  So, this is just a bug fix.  As far as I
know, there's no security issue here, okay?  All right.  Stop me if you have
comments.

**Adam Gibson**: Sorry, could I just pick up on that one?  That's slightly
mind-breaking.  What could be the actual functional difference if a person has
a database from which they cannot read the entry, or that it was invalid?  I'm
not following how there would be a functional difference.

**Mark Erhardt**: Sorry, whether a UTXO was non-existent, so that it was not
found in the database, or whether you could not read the database entry, is
the functional difference.  And yes, in both cases, you're probably in a state
where you need to re-sync or fix your database.  Well, either you have found
an invalid block and everybody else seems to believe it, which probably also
should make your head scratch.

**Adam Gibson**: Yeah, it's fine.  As you said, there was no actual...

**Mark Erhardt**: Yeah, I think it's probably never going to be an issue
unless you ever have an issue in deserializing stuff from the database, and
that would be a pretty big issue by itself.

**Adam Gibson**: Okay.

**Mark Erhardt**: I think it's sort of the thing that you find when you spend
tens of thousands of dollars on compute.

**Adam Gibson**: Yeah, true!

_Bitcoin Core #36048_

**Mark Erhardt**: All right.  The next one is an issue where you could shoot
yourself in the foot.  So, if you used the -walletnotify configuration option
and used a wallet name as a regular expression, essentially, the -walletnotify
could be used to run commands on your machine.  So, you already have access to
a node, you can create wallets, and then you are also running -walletnotify
and now you can use wallet names to run commands on your own computer that you
already have access to.  So, this was fixed by properly escaping wallet names
in the -walletnotify messages, but also kind of an interesting problem.

**Adam Gibson**: I'm not sure, maybe I'm wrong here, but I'm not sure that
it's quite as trivial as, "Well, you already have access", because, I mean at
least theoretically, this is an authentication system.  So, somebody could be
saying to someone else, "You are authenticated to do this", and I expect them
to be able to use the wallet, but I don't expect to be able to execute
arbitrary code on their server, right?  So, I mean, maybe nobody's using
Bitcoin like that, but I don't know.  It seems like a non-trivial bug.

**Mark Erhardt**: Fair enough.  You could do little Bobby Tables, if you have
RPC access to a server that's running wallets already.  So, I guess if you're
running an Uncle Joe setup where people can create their own Bitcoin Core
wallets on your Bitcoin Core node that you have given them VPN access to or
something, they could break out of it.

**Adam Gibson**: I think Uncle Joe is usually Stalin.  I think you meant to
say 'Uncle Jim', but that's fine!

**Mark Erhardt**: Thank you, but I didn't quite catch it.  What is Uncle Joe
usually?

**Mike Schmidt**: It's Uncle Jim, I think.

**Adam Gibson**: Uncle Joe used to be Stalin, but not nowadays.  But never
mind!

**Mark Erhardt**: Oh, shit, okay!  Never mind!  Okay, Uncle Jim is what I
meant anyway.  I think I'm just too young for that reference, or something!

**Adam Gibson**: Very, very much so.  But yeah, I do think the Uncle Jim
scenario is relevant, or a corporate environment, or something like that.

**Mark Erhardt**: All right.  But either way, well, okay, maybe I'm
over-trivializing, but it is a very special setup, and then you need people
that you trust very heavily trying to be malicious to you, and I don't know.
It seems hard to exploit, let's say it that way.

_Bitcoin Core #36123 and #36169_

All right, we have two more here, Bitcoin Core #36123 and #36169.  This fixes
an unbounded memory growth issue.  When you're running an HTTP server, you
could make a server send messages slower than they can process them, and that
would make the buffer eventually bloat, and I think you could probably crash
the server.  And yeah, you basically introduce some TCP backpressure here in
order to not allow them to send requests faster than you can process them.
And yeah, basically just fixing a DoS issue.  Sorry, I learned this morning
that I'm responsible for these, so cut me some slack here!

**Mike Schmidt**: Wait till we get to the Lightning ones!

_Bitcoin Core #36176_

**Mark Erhardt**: All right, the last one that I have is Bitcoin Core #36176.
So, this fixes an error when you're trying to load a wallet while also running
with the -nosettings option, and then when you're loading the wallet, are
trying to make sure that it'll load on the next startup too.  So, it's sort of
an odd situation.  You're forbidding your node to update the settings, but at
the same time you're importing a wallet and you want to start loading it every
single time.  This used to cause a crash because of the conflict where it
wasn't allowed to update the settings, but was requested to start loading this
wallet every time.  And now, it instead completes the operation and warns that
the preference couldn't be saved because -nosettings was on.  So, again, a bug
that would crash your node if you do some maybe conflicting things at the same
time.

**Mike Schmidt**: It's nice that we have all of these totally human testers
testing all of these crazy edge cases that you're announcing fixes for, Murch.

**Mark Erhardt**: Yeah, I mean, it's good that all these little issues are
being found, but these are good fixes.  So obviously, we wouldn't be talking
about them if they were super-serious, then they would be fixed and later
disclosed.  I think this is just a series of bugs of, well, a lot of testing
going into Bitcoin Core, where because computers can do a lot of things in
parallel and serialize things and try a ton of scenarios that nobody would
ever come up with, we find these and it's great they're being fixed, but the
sky is not falling.

_Core Lightning #9434 and #9473_

**Mike Schmidt**: We'll move out of the Bitcoin Core notable PRs and we'll
move on to CLN with Core Lightning #9434 and Core Lightning #9473.  These are
related because they're two fixes related to the askrene plugin, which is
routing engine.  Askrene has this feature where you can set biases, meaning
that you can tell askrene that you prefer to connect to certain nodes or avoid
certain nodes or channels, and you can actually save those biases so that they
can survive a restart of CLN.  And so, that's maybe the preface to the two
bugs.  The first bug is that when you're loading one of these saved biases and
it had a description attached, the code used a piece of memory that had
already been freed.  So, essentially that causes memory error, it crashes
askrene as a plugin.  But since CLN treats askrene as an important plugin, it
actually takes the whole node down.  So, that was the first bug around
askrene.

Then, the second bug was if you removed one of these biases by setting it to
zero, the code actually deleted it from memory before saving it, so then it
crashed on a null pointer issue, because the removal never got saved, the old
bias came back after a restart.  So, the fix there is now it saves that
zeroed-out bias first.  More bugs.

_LND #11061_

LND #11061 is more work on LND's effort towards BOLT12 offers.  This
particular PR adds signing and verifying invoice requests and invoices using
Schnorr signatures.  So, the way BOLT12 signatures work is you build this
merkle tree out of the messages fields and then sign the root.  Before this,
LND only checked that a signature was there, and now LND will actually check
the signature if that is valid and it will reject bad ones.  This builds on
some of the invoice request encoding that we talked about back in #413, which
we link to.  Good to see more progress on BOLT12 offers from the LND folks.

_LND #11125_

LND 11125 lets you lock up wallet UTXOs in LND until the transaction spending
them gets a certain number of confirmations you pick.  So, LND now lets you do
that.  But before this, you had two options and both of them had issues.  You
could do time-based locks that could expire before your transaction was
actually confirmed; or the lock released at one confirmation, but then you're
at a position where a potential reorg could unlock the coins while your
transaction was sort of still up in the air, so the wallet might actually
spend them somewhere else.  So now, there's this LeaseOutput and FundPsbt that
take a confirmation count, and the lock actually survives reorgs and doesn't
expire on a timer.  So, you still have to release the lock yourself if you
abandon the transaction, it's noted in the write-up, and then also timelocks
are still the default.

_LND #11064_

LND #11064.  This is a change so that LND will now always say explicitly which
channel type it wants when opening a channel, which is actually what the spec
requires.  It puts the channel_type in the open_channel and then spits it back
out in accept_channel, and then it also rejects incoming opens that leave out
that field.  So, maybe one thing to note here is that if you're using LND and
you open a channel through the RPC without picking a type, LND picks one based
on what it knows both sides support.  And this is sort of tied into the fix
that we talked about back in Newsletter #407, where LND was picking a taproot
channel implicitly and then failing on it.  So, this is sort of related to
that line of work and fixes.

_BTCPay Server #7561 and #7542_

And we'll round out with some BTCPay Server PRs, some of which we sort of
talked about earlier with the Releases for BTCPay Server.  But BTCPay Server
#7561 and #7542, these are API key storage changes that shipped in that 2.4.4
release that we talked about earlier.  The #7561 change made a change such
that BTCPay Server API keys are now stored as a hash and then a key ID, and
not the actual secret.  And then, there's also a cleanup job in 2.4.4 that
wipes any of that leftover plain text once it's more than five minutes old.
Your existing keys will keep working but you can't view the secret in the
server anymore.  The idea here is if someone dumps the database, that they
don't get usable keys.  And finally, revoking a key now uses the key ID
instead of the secret.  So, that was the #7561.

For #7542, this is again around API key storage issues.  When you create a new
key, the secret is no longer in the URL that sends you to the key management
page, for reasons that URLs end up in browser history, server logs and all
kinds of things, so you shouldn't have secrets in them.  And so, this fixes
that, this #7542.

_BTCPay Server #7559_

Last PR this week, BTCPay Server #7559.  Maybe some quick background.  In
BTCPay, the invoice has two different clocks associated with it.  There is a
clock for the payment deadline, which is 15 minutes by default, and that locks
in the exchange rate.  So, using BTCPay Server, you have these fiat exchange
rates.  But there's also this monitoring window that's separate from the
payment deadline window that runs after that.  So, after a full day by
default, BTCPay Server will stop watching for late payments.  And a merchant
can configure both of these different windows.  The bug here is that onchain
payments in BTCPay Server were watched through that whole monitoring default
period, or the whole period, whatever you had that configured to; but the
Lightning side stopped after the 15 minute payment deadline.  So, a customer
could pay the Lightning invoice a couple of minutes late and then the payment
would go through on Lightning, but BTCPay Server would never record it, and
the merchant had to sort this whole fiasco out by hand.  Now, Lightning is
watched through that same monitoring window as the onchain and late payments
still get recorded.  They get recorded as being paid late but they get
recorded.  And the payment deadline itself doesn't change in any of this.  It
just doesn't watch forever.  So, that's a fix there.  And I think that's it,
Murch.

**Mark Erhardt**: Yeah, the dog barking in the background just reminded me of
times when we sometimes had roosters crowing in the background.

**Mike Schmidt**: Ah, yes, the good old days.

**Mark Erhardt**: Still miss those days.  Yeah, all right, I think we did it.

**Mike Schmidt**: Well, Adam, we want to thank you for joining us and also for
hanging on, we want to thank Rob for joining us earlier for this week's
episode.  And, Murch, thank you for co-hosting and for all of the audience for
making it through.  Cheers.

{% include references.md %}
