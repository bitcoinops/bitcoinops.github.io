---
title: 'Bitcoin Optech Newsletter #336 Recap Podcast'
permalink: /en/podcast/2025/01/14/
reference: /en/newsletters/2025/01/10/
name: 2025-01-14-recap
slug: 2025-01-14-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Abubakar Sadiq Ismail, Gregory Sanders, and Daniel Roberts to discuss [Newsletter #336]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-0-14/393072427-44100-2-d29b2a1ac6ee3.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #336 Recap on
Riverside.  Today, we're going to be talking about some discussion of mining
pools and their use of coinbase transaction; some contract-level timelocks in
the context of LN-Symmetry/eltoo; a multiparty eltoo scheme with penalties and
our Releases and Notable code segments.  I'm Mike Schmidt, contributor at
Optech, and I help run Brink, funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Localhost Research.

**Mike Schmidt**: Congratulations.  Is it official?

**Mark Erhardt**: Yeah, just started yesterday.

**Mike Schmidt**: That's so cool.  Abubakar?

**Abubakar Sadiq**: Yeah, I'm Abubakar Sadiq, I work at Chaincode Labs on
Bitcoin Code stuff.

**Mike Schmidt**: Instagibbs?

**Greg Sanders**: Hi, I'm instagibbs at Spiral.

**Mike Schmidt**: And Dan.

**Daniel Roberts**: Hey, I'm Dan, I work in an unrelated field, but I'm happy to
be here.

**Mike Schmidt**: Thank you all for joining us.  For those following along,
we're just going to go through Newsletter #336 sequentially here, starting with
our three News items.

_Investigating mining pool behavior before fixing a Bitcoin Core bug_

First one is titled, "Investigating mining pool behavior before fixing a Bitcoin
Core bug".  Abubakar, you posted to Delving Bitcoin a post titled, "Analyzing
Mining Pool Behavior to Address Bitcoin Core's Double Coinbase Reservation
Issue".  Maybe a good place to start is, maybe you can describe what is Bitcoin
Core's double coinbase reservation issue?

**Abubakar Sadiq**: Yeah, thank you.  So, the issue is we are reserving space
for coinbase transaction and block headers twice in the codebase.  We have a
constant default max block weight that reduces the 4000 weight units (WU) we
need that we want to reserve, and we also do it in Block Assembler.  So, that
results in Bitcoin Core blocks having less space than intended.

**Mike Schmidt**: Okay, so as part of the mining operations, Bitcoin Core says,
"Hey, we'll take a little bit out of the block space, because there's going to
be this coinbase transaction, we're not quite sure what you're going to put in
it, but we're going to save some space for that".  But the problem with that is
that that logic is duplicated, so the same amount of space is reserved twice, is
that right?

**Abubakar Sadiq**: Yes.

**Mike Schmidt**: Okay, and so anyone running default Bitcoin Core, if they
filled up that initial reservation slot perfectly, they still would have
additional reserve available that is taken out of the potential block space for
other transactions.  And so really for, I guess, I don't know how long this
issue has been around, but essentially miners are underfilling blocks
unintentionally due to this double reservation.

**Abubakar Sadiq**: Yes, exactly.  So, during the analysis, I noticed that only
F2Pool is producing optimal block templates.  And I think they are, they have
been messing around with the mining algorithm in Bitcoin Core, so somehow they
fixed that issue in their own software, and all other mining pools are adhering
to the same default behavior that we have, and their block is mostly around
3,992 WU.

**Mike Schmidt**: Okay, so it seems like F2Pool discovered this and is either
intentionally, or due to some other customizations they've made, unintentionally
getting around this double reservation issue, whereas other mining pools
seemingly haven't noticed this.  There hasn't been issues on the Bitcoin Core
GitHub from miners, or pools pointing out that their profitability is down due
to this extra space being held?

**Abubakar Sadiq**: So, there are no issues by miners, and the issue was
discovered by Antoine Riard, I think around 2021.  I also came across the issue
recently while writing a test.  So, if you want to write a test that you want to
fill up the block template, you cannot be able to do so.  And it's not
documented anyway that we are reserving for this space.  So, during my
observation, I have noticed that the default that we are reserving is 4000 WU,
but still the resulting block is less than that.  So, after some more
investigation, I found the Antoine Riard issue and I decided to fix it.  Then, I
think (inaudible 04:57) was reviewing the PR and he noticed that if we end up
removing the double coinbase reservation issue, we might end up harming some
miners, because he has noticed that Ocean Pool are creating coinbase
transactions that are above the 4,000 WU that I initially proposed.  So, that's
what made me do this research to see how are we going to affect miners, and I
discovered that Ocean pool are basically using the same default.  And even if we
fix it and lower the limit to 4000 WU, we are not going to affect them because
they are starting up their bitcoind with much lower block max weight option, I
think around less than 3,900,000 WU.  But still, there might be some miners, I
think, that might be utilizing the 8,000 weight units that we are reserving.

So, we ended up saying we are going to reserve the default behavior, but enable
miners to be able to lower it on their own.  So, we are introducing another
startup option, block reserve weights, with the default still 8,000 WU, but
miners can lower it as they wish or increase it as they wish, so that Ocean
Mining Pool are not going to start their bitcoind with lower block max weights,
just for them to be able to have a very large coinbase transaction, they can
just parse whatever WU that they want to reserve.

**Mike Schmidt**: Okay, that makes sense.  Ocean, I know, has prided themselves
on, where possible, paying out miners from the coinbase.  So, that's
potentially, I guess, a reason that they would want bigger space for the
coinbase transaction if they're doing a lot of payouts.  Did you see that in the
data?

**Abubakar Sadiq**: Yeah, that's correct.

**Mike Schmidt**: Okay, and so instead of the fix being, eliminate the duplicate
reservation and then potentially people have issues because they don't have code
that can handle the 4,000 max, they're counting on maybe 8,000 max, or some such
scheme, you're having the solution be an opt-in to decrease that 8,000 as
needed.  Do I have that right?

**Abubakar Sadiq**: Yes, it's opt-in.  But by default, you are getting the same
previous area.

**Mike Schmidt**: Okay.

**Mark Erhardt**: Optimally, I think it would be nice if a getblocktemplate or
the successor for that, when we get cluster mempool, would take a parameter
where a miner can set how big their coinbase transaction is, and it would
dynamically build block templates that fit the coinbase transaction of the
miner.  Because the miners generally have to know the coinbase transaction
before they build the block template, or they would leave a little allowance for
themselves but they would know how much they want to use.  So, if that were part
of the RPC, that would make a lot of sense.  But reducing the duplicate here is
a great PR as well.

**Mike Schmidt**: Murch, a couple of things there.  One, it sounds like you were
saying you could specify how large the coinbase transaction is and then the math
would just fall from that.  Would it also work to just also parse in the
coinbase transaction so you don't even have to worry about calculating that
correctly on the mining pool side of things?

**Mark Erhardt**: So, the block template has to be known in order to finalize
the coinbase transaction, but generally miners know how big their coinbase
transaction will be.  So, the coinbase transaction in the outputs has to commit
to all the witness txids, right?  So, you can't have the coinbase transaction
finalized until you know what transactions will be on the block.

**Mike Schmidt**: Right.

**Mark Erhardt**: Yeah, so it's a little bit of a chicken-egg problem, right?
You pick the transactions in order to fill the block up to the point that you
can fill it.  You have to leave room for the coinbase transaction, you have to
leave room for the block header and the count of transactions, which sort of is
not counted to the block header and adds another, I think, 1 to 3 bytes,
depending on how many.  And yeah, so if you didn't know, well, we always put
this message into our input and there's an extra nonce of that size, and our
coinbase transaction template uses merge mining and the witness commitment and
two more outputs, or however many this specific mining pool or block template
creator uses, you know exactly how big your coinbase transaction will be.  But
you don't know the coinbase transaction yet because you don't know the
transactions yet, so you can't construct a witness commitment.

**Mike Schmidt**: That makes sense.  Murch, maybe a slight tangent, but you made
reference to some thinking being done around cluster mempool and potentially a
separate RPC for getblocktemplate.  Is there anything interesting there that
you'd like to share, thoughts about that?

**Mark Erhardt**: No.  I think people are just a little over getblocktemplate
itself.  It's sort of BIP-specified, but it's a little odd in some ways.  I
think, rather than with cluster mempool, which is a drop-in replacement, with
Stratum v2, there is work now on changing the mining interface and making sure
that all the correct RPCs are in place.  And I would hope that in the design for
the Stratum v2 RPCs and being able to hopefully get block templates for Stratum
v2 out of Bitcoin Core, there would be consideration for parsing in a coinbase
transaction weight.

**Abubakar Sadiq**: Yes, so I propose adding that as a runtime option but as you
have mentioned, it's BIP-specified, so doing that can be a bit tricky.  And
previously with the block, the mining interface cannot be able to lower it below
4,000 weight units.  So, because we have a constant that is reducing it from the
consensus 4,000,000 WU.  So, this PR is going to enable that.  And when we have
the mining interface ready, we can just parse whatever weight unit we want for
the coinbase transaction and headers size.  So, yeah, it will be as you are
suggesting, Murch.

**Mike Schmidt**: Abubakar, I think it might be just slightly interesting for
the audience to hear about the methodology.  I believe that you used the
libbitcoinkernel library to pull in block data, and I think you married that
analysis with some of the data from 0xB10C on mining pools.  I think there's a
repository that 0xB10C has out there with some of that information and you had
some scripts that put it together.  Do you want to talk a little bit more about
that?

**Abubakar Sadiq**: Yeah, so the methodology is interesting, I think.  So,
libbitcoinkernel is an interesting project that I've been looking forward to
mess around with.  So, previously, if you want to get historic data, personally
what I used to do is to call the RPC, and getblock RPC is a little bit slow.
So, I experimented with libbitcoinkernel library to read block data from disk,
and it's far more performance than using the RPC.  So, yeah, I used open-source
tools, like mining-pools from 0xB10C to match the tags in the coinbase
transaction and know which pool mined the block.  I also use a Python wrapper,
so I did not use the libbitcoinkernel library directly.  I used stickies-v's
Python wrapper, because the script I am using for my analysis is in Python, so
it fits in well.  So, it's really interesting to experiment with this library at
this early stage and do this analysis with it.

**Mike Schmidt**: Very cool.  The only other thing I had to note here was that
Jay Beddict also posted a reference to this Delving discussion on the Bitcoin
Mining Development mailing list.  And as I checked this morning, there were no
responses to that.  So, if you are involved in the mining ecosystem and you have
an opinion on this discussion and the approach that Abubakar is looking to take,
obviously you can chime in there, chime in on Delving and have your voice heard.
Abubakar, anything else before we wrap up this news item?

**Abubakar Sadiq**: No, the PR is still open for review.  0xB10C and Sjors are
looking at it.  So, as you have said, if there is anyone that is interested in
this PR, they should give their feedback.  It's very, very welcome.

**Mike Schmidt**: Thanks for joining us, Abubakar.  You're welcome to stay on,
but we understand if you have other things to do.

**Abubakar Sadiq**: Thank you for having me.

_Contract-level relative timelocks_

**Mike Schmidt**: Next news item titled, "Contract-level relative timelocks".
Greg, you kicked off this discussion with a Delving post where you noted, "Eltoo
constructs such as LN-symmetry suffer from an issue where every time an update
transaction is confirmed on the blockchain, the relative timelock to settle the
contract is reset.  This causes further funds lockup and further extends HTLC
(Hash Time Locked Contract) expiry in the LN use case, potentially reducing
network utility".  And then you went on to explore the idea of a contract-level
relative timelock (CLRT), but maybe before we explore that, you can help
elaborate on the problem that I just quoted here, so that we can fully wrap our
heads around the issue.

**Greg Sanders**: Yeah, so the core of the issue here is where, well, in most
STARK case, and in LN-Symmetry case, you basically have this output that can be
spent in two different ways, in the update path, which is like, "Hey, you did an
older update, here's a newer update", so that can immediately be re-spent; but
you also have the settlement path, which is the security parameter, the time in
which the counterparties have to be online, the liveliness requirement, to get
their funds back to the correct final state.  So, ideally, this would be the
shared delay parameter and you'd only have to wait this many blocks before
taking the settlement path.  But there's some issues here where, for example,
Alice and Bob are in a channel and Alice sends an update to Bob and Bob does not
respond with his countersigning to this update.  So now, Bob has access to a
newer state than Alice, Bob goes offline for whatever reason, Alice decides,
"Hey, I need to do it onchain", so she broadcasts her nth state.  And then
almost you wait, let's say shared delay is a day, so 144 blocks; 140 blocks
later, Bob comes back online and broadcasts his last state, the nth+1 state.
This will reset the relative time lock back to 144 more blocks.

So effectively, in the LN-symmetry case, where you're doing unlayered
transactions, you have to wait another 144 blocks before you can lock in HTLC
success or failure, right, so collecting money or getting your money back from
HTLCs.  So, this would have an effect, as an example, that if you use this in
the LN, for security reasons, you'd have to have your HTLC expiry just be pretty
far in the future, which causes more capital lockup in the primary case, which
is not the worst thing in the world.  But back when I was working on this
initially, a couple of years ago on LN-Symmetry, I thought, what you want is the
smart contract to have a relative timelock of its own, which is at smart
contract level.  But if you have UTXOs in your smart contract refreshing, this
would be at odds.  So, I thought it was kind of impossible at the time, because
there's no way of enforcing, in a reorg-safe manner, that the elapsed blocks,
like let's say 140 blocks elapsed, there's no way of requiring Bob to forward
that elapsed time into the next step of the update due to reorg safety.  There's
Bitcoin design principles here that we can't get around.  So, I said, oh, it's
probably impossible.  I had discussed with a few people, put it down.  But then
I was talking to ademan recently, and I was trying to convince him this and when
I said it, I'm like, "That doesn't sound right.  It doesn't sound impossible",
and that's why I revisited the problem two years later.

**Mark Erhardt**: Maybe a sort of orthogonal question.  Obviously, the HTLCs
have to have a longer timeout than the time that it takes to get the transaction
onchain.  So, if the HTLC, let's say, were generally 50 more blocks on top of
the channel closure delay, and the channel closure delay now needs to account
for a duplicate, we'd go from, let's say, 144 plus 50 would be 194 blocks, to
300 and what is it, 44?

**Greg Sanders**: I don't know.

**Mark Erhardt**: 348-something?

**Greg Sanders**: It's bigger.

**Mark Erhardt**: 338.  So, is there maybe, because there is symmetry here, and
we hopefully, whenever we do LN-Symmetry, we would be using TRUC (Topologically
Restricted Until Confirmation) transactions because the LN-Symmetry trigger
transaction can't have a fee in the first place, at least not an intrinsic fee,
would it perhaps be reasonable to say that due to the transaction itself not
having a fee, they are going to be more reliable or faster to confirm than
penalty transactions; or would you say that it's completely interchangeable in
that regard?

**Greg Sanders**: I think it's completely interchangeable, right?  We could
update penalty channels to be pretty good.  I mean, we could just simply update
what we have now, just do TRUC and all that nice view management stuff.  The
watchtowers would be a little easier with LN-Symmetry, so maybe just some
hand-waving arguments there, that you could have easier watchtower time.  But
that's also a little questionable.  I think you're going to find that these all
have trade-offs.  So, this post isn't even necessarily a serious attempt to
modify LN-Symmetry, but I wanted to distill the idea and see if it was more
generally applicable.  And it turns out, for example, John Law's already
implemented a simple version of this, the txid-stable version of this.  We can
get more into that later, or I'll let Mike drive this.

**Mark Erhardt**: Right.  So basically, all of the delays would be the same as
expected.  We might have better mechanisms, we might be generally able to more
reliably send the Lightning transactions due to TRUC and bringing the fee at the
time of publishing the transaction, rather than pre-picking it.  But so if we
were doing LN-Symmetry without another -- well, we need a protocol change either
way, but if we wouldn't get a second protocol change, then we'd basically have
to double the HTLC delays, which makes, of course, jamming attacks more
effective.

**Greg Sanders**: Right.  So, I mean, there's some anecdotal evidence that in
practice it might not matter, but these are just anecdotes.  Markets can change,
adversaries can adapt, it's hard to say.

**Mike Schmidt**: Greg, you brought up a couple of related research items.  You
mentioned the John Law two-level transaction relative timelocks, I think there's
this coinid feature from Chia that was discussed as well.  I think those are
both things that you brought up, but then we had Jeremy, AJ, and a bunch of
other people chiming in.  Which ones should we be paying attention to?  Which
ones do you want to highlight here?

**Greg Sanders**: So, I think we can talk about the txid-stable version of
these, because that's easier to think about in some ways.  John Law has, I
posted, a lane diagram thing here.  But basically, there's two lanes of the
smart contract.  One is dealing with the commitment transaction challenge
response period, and the other is dealing with a relative timelock for an HTLC.
And these eventually join up later, but you want essentially that the HTLC
relative timelock to be enforced without resetting every time a new transaction
shows up, because there's a revocation period for the commitment transaction.
And if basically someone makes a claim and then it gets revoked n blocks later,
that would be resetting all these time-relative timelocks in this multiparty
channel setting.  So, what you want is two separate relative timelocks in two
different lanes, and the longest timelock, probably at least in this example,
would be the HTLC-relative timelock.  So, that's an example of where, if you
know the transaction ID ahead of time, you could just simply sign for it, right?
You sign the transaction just sighash all it commits to the prevout and that's
stable.

There's the kind of silly example I gave, where you do eltoo, but you do it all
onchain.  So, you just imagine a sequence of inputs and outputs that keep
updating the values of the payment channel.  But at unilateral close, every
single update has to be put to chain, right?  That would be txid-stable, and
that'd be pretty easy to do, because from a CLRT point of view, because you know
the transaction ID ahead of time, you can just sign for it.  An analog would be
also, maybe we'll get to this more later, there's connector outputs.  So, things
like timeout trees, Ark, use this kind of stable txid paradigm to basically do a
fair trade, so atomic swaps of sorts, with these trees.  So, if a tree gets
unrolled down to a leaf, the leaf has a similar output that gets consumed by the
operator of the tree in a prior tree.  So, it's a way of swapping these virtual
UTXOs with the previous owner, who is now the sender, and the coordinator, the
ASP (Ark Service Provider), or whatever you want to call it.  So, that uses
something like CTV (CHECKTEMPLATEVERIFY) or pre-signing everything, and it
relies on txid stability to connect these prevouts to each other.  But you could
imagine situations where -- oh, is that another time?

**Mark Erhardt**: Yeah, maybe just to jump in quickly and give another angle on
explaining that.  Basically, it enforces that a whole tree is unrolled in order
for a specific version of a transaction to be able to be created, because it
depends on a leaf in the tree creating this connector.  So, it's like an
alternative spending path that's only available if a tree got unrolled.

**Greg Sanders**: Right.  It's a way of revoking old stuff to the coordinator,
so they stay whole.  But you can imagine situations where it's not txid-stable.
So, Ark v2 is a great example of this, where Burak had an idea, "Well, I can
reclaim some of this liquidity from a tree that has spent outputs if I have…",
and then insert hand-waving magic.  But this hand-waving magic also invalidates
the txid stability.  So, it'd be great if we had a more general connector output
kind of paradigm.  Can you introspect, can you say, "This contract resulted in
this output being unrolled here, and then let me spend that?"  Let's see.  The
other interesting parts, let's take a look.

Yeah, so the Chia stuff is kind of interesting, but it's mostly a slight change
on how the UTXO model works.  They have a UTXO model in Chia, but it's a UTXO
set, a coin set, they call it something else, coin set or something like that,
where the txid is simply the parent's txid hashed with the scriptPubKey.  And
basically, in a Chia transaction, you're not allowed to have duplicate
scriptPubKeys.  So, you have a unique coin based on the parent txid hashed with
the new scriptPubKey.  And so, with that information, you can do some slightly
more compact tricks.

That kind of devolved into discussion of ancestry history, ancestry proofs in
the thread.  And then basically, Salvatore and @rot13maxi discussed basically
ways in which you can do ancestry proofs in Bitcoin.  I'm actually working
through the concrete stuff right now, but there's basically a bunch of ways that
we could solve this.  And the question is, first of all, let's assume we have
pretty powerful introspection primitives somehow, right, whatever that is,
whatever the limits of this ancestor-proof, contract ID-proof system would be?
And also, what kind of tooling would best cater to those use cases?  And so,
that's kind of what I'm looking at now.

**Mike Schmidt**: One of the other people chiming in was Brandon Black, Rearden
Code, who pointed the thread towards some work by Daniel.  Yeah, go ahead.

**Greg Sanders**: So, yeah, I can give a little preview in how this relates.
So, you could say, "Hey, well, if we have a system where the channel partners
can only submit an update once, then you could basically get around this issue".
There's more to it, but in the multiparty case at least, you still have this
issue with the shared delays kind of stacking on each other.  And this piece
would hopefully be modular enough that you could graft it into whatever other
crazy system you're designing.  Or basically, it's if we know how to do this
CLRT, then you can graft it on any smart contract you want.

_Multiparty LN-Symmetry variant with penalties for limiting published updates_

**Mike Schmidt**: Well, I think we can continue discussing this as we progress
to the next News item, which is related.  We made reference, Dan, to you earlier
under your ademan handle, but you posted to Delving as well, a post titled,
"[BROKEN] Multi-Party Eltoo with bounded settlement".  So, it sounds like you
were working on implementing LN-Symmetry, and perhaps you can elaborate on what
Greg outlined and what you uncovered?

**Daniel Roberts**: Sure, I can try.  So, this actually was kind of inspired by
what Greg was working on.  I was kind of curious if there was another way to
bound the settlement time.  I actually didn't entirely appreciate specifically
what Greg was trying to limit when I started on this.  So, he was obviously
working on this 2x shared delay issue, and my head was elsewhere at, "How do we
prevent an adversary from publishing old states to the point where you can time
out the HTLCs?"  And so, that led me down a couple of paths that ended up with
this system where parties can only update a single time after they've updated
the onchain state of the channel.  They're kind of put into a new set where they
can't update anymore, and this would prevent the issue.  Although I think
multiple people chimed in and kind of said, "Well, this is poorly motivated
because when you're trying to do this attack, we can see it, we can fee bump our
updates, and cause the attacker to basically spend much, much more in fees than
would be worthwhile".  So, this attack really only matters if there's a way to
communicate your update transactions directly to a mining pool, or otherwise
hide them from your other channel partners.  So, I was a little poorly
motivated, but I got excited about what I found.

**Greg Sanders**: So, can I chime in real quick?  I don't agree that it's poorly
motivated per se.  So, the one caveat is that if you have a multiparty channel,
I think you still have these delays, right?  Like, the shared delay problem
still exists.

**Daniel Roberts**: Yeah, it can be reduced by one, but only one.  So, for a
two-party channel, it ends up looking a lot like Daric and you can actually
eliminate that second delay, which is nice, but I think Daric's probably
superior anyway.  But with multiparty, you end up only shaving one delay off of
that n-time shared delay issue.  And I guess the other notable finding is that I
realized I had made some assumptions about the penalty version of this that
ended up kind of requiring me to really go back and examine what I was doing.
And it turns out that there's a lot more state that I need to be accounting for
to support penalty, which just completely blows up the number of transactions
that need to be computed for every state update.  And I gave some preliminary
performance numbers in my original Delving post, and it's just considerably
worse than that, which is unfortunate, but I think this was at least a useful
exercise.  It's my first post on Delving.

**Mark Erhardt**: Yes, it does sound like a useful exercise.  It sounds to me
like you noticed that, especially in combination or in relation to the 2x delay
issue, when the victim initiates a channel update and the attacker just leaves
them hanging without finalizing that, of course there has to be a way for both
partners to be able to close the channel.  So, in that case, let's say Alice is
the victim and Mallory is the attacker.  Alice initiates a channel update, for
example, to add an HTLC and therefore gives up on the -- or she doesn't have the
new state yet, she hasn't given up on the old state yet.  Mallory leaves her
hanging, can sign by themselves the new state, and therefore has a different
state.  So, when Alice eventually, after being left hanging, closes with the
prior state, Mallory can finalize the state update, use that state to go
onchain, and now two updates have been made and Mallory gets access to Alice's
coins, right?  That was sort of the issue that was how introducing the penalty
is potentially problematic.

**Daniel Roberts**: Yeah, that's exactly right.  And so, it is possible to
counter for that, but it complicates things significantly.  You have to
basically introduce new states where, in this case, you need to have an update
and a revocation signing basically, and you'd have to be able to have an update
path where Alice can publish her state.  And because she has not signed for the
revocation, she's not actually able to be penalized, but she can be updated.
And you have this kind of explosion of that state through this entire tree of
transactions that I'm already building out for every state update.  So, it's a
significant complexity increase.

**Greg Sanders**: So, I like the exercise and I also like to think a little
ahead, like what if we had more powerful transaction primitives, like how much
better this would get?  I suspect a lot.  And maybe the solution is more
powerful introspection primitives gets you to, let's say, at least ten-party
channels or more, and maybe that unlocks something from a liquidity perspective.
And you can also basically have this CLRT, put it all together and maybe that
unlocks some liquidity, makes liquidity requirements less enough to unlock some
new potential perhaps.  So, I think it's worthwhile to think in a kind of
higher-level form of how you want to do it in a perfect world.

**Daniel Roberts**: Yeah, I definitely began to appreciate the design of CCV
(CHECKCONTRACTVERIFY) while I was working on this.  I think it allows you to
carry a state that would basically, you could explicitly track the sets of
parties who are still able to update, parties who have updated, and parties who
need to be penalized.  And it makes all of this explicit, and I think, well,
it's much cleaner, much simpler too.

**Mark Erhardt**: Yeah, I mean in a way, it's sort of counter to the idea behind
LN symmetry, where you say, "Oh, if we only had symmetric state, a lot of the
state archiving that we have to do would become simpler because you don't have
to hold on to all the previous states, you just have to remember the last one.
Previous state is no longer toxic".  So, now if you introduce the penalty
mechanism back into LN-Symmetry, you sort of get some of the same problems back,
which is kind of interesting.  And I kind of want to say ten people in a channel
would be awesome, of course, but even if you had a much smaller number of
people, if you had three people, a single channel could replace three two-party
channels; if you had four people, a single channel could potentially replace six
single two-party channels because, of course, four people being able to send to
any of the other three people would require six two-party channels usually.

So, I think ten as an aspirational number would be amazing.  You, of course,
probably very quickly run into liveness issues, because just one person being
gone means that updating becomes more difficult or you have to build complex
solutions for that.  But even if we only get to three or four or maybe five
participants in a channel, that could be a good improvement.

**Greg Sanders**: Also, you could think of using these for as a piece in
something like ZmnSCPxj's SuperScalar stack, right?  We had something much
better than the DW channels, whatever that's called, and without locking up
liquidity forever or variable amounts, which I don't like about that
construction.  So, you could get something where the delays ended up being
constant per level and decent scaling in the vbyte sense.

**Mike Schmidt**: Anything else we should explore before we wrap up these newest
items, Greg, or Murch, or ademan?  Okay, great.  Well, there's a few Delving
posts that we've referenced, so if you're curious about this, Greg mentioned
there's some diagrams. Ademan's writeup is fairly lengthy as well, so there's
plenty to jump into, but I think we can wrap those up.  Greg and Dan, thank you
both for joining.  You're free to drop if you have other things to do, or you
can come hang out with us for the Releases and Notable code segments.

**Greg Sanders**: I'll hang around thanks.

**Daniel Roberts**: Thanks for having me.

_Bitcoin Core 28.1_

**Mike Schmidt**: Releases and release candidates we have Bitcoin Core 28.1,
which is a maintenance release that has, by my count, two build-system updates,
four updates around testing, among other changes and fixes.  One P2P item that
we covered in Newsletter #335, there's a fix in for that as well.  That was the
fix for running multiple Tor nodes on a single machine, which was Bitcoin Core
#31223 that we talked about in #335.  Murch, what else is in here or notable?

**Mark Erhardt**: Yeah, the port thing with the Tor port, that was the thing
that stuck out for me when I looked at the release notes.  So, I assume that's
what you talked about last week.  I wasn't here, of course.  Okay, cool.

_BDK 0.30.1_

**Mike Schmidt**: Yeah, that's right.  BDK 0.30.1, this is a maintenance release
for the older series of the BDK library known as BDK.  The release notes point
out that the 0x release series, so like the 0.31.1, etc, and thus the BDK
library is deprecated moving forward, and users should move to the 1.0.0 series
based on not BDK library but the BDK wallet library moving forward.  We link to
the migration guide in the newsletter, so please follow that and get on the
latest version.  Also, I saw in the release notes, "The BDK team will continue
to publish BDK 0.30.x bug fix releases as needed, but only for a limited time".
And I also wanted to point out that the migration guide is actually part of the
book of BDK, which is a great resource for projects or developers using BDK.
And also, we had Steve Myers on last week in Podcast #335 to discuss the BDK
wallet 1.0 release last week, so for more information on BDK and the latest,
check that out.

_LDK v0.1.0-beta1_

**Mike Schmidt**: LDK v0.1.0-beta1, I think we talked about this one last week
but, "The release notes are forthcoming".  So, I did not investigate further.  I
assume there will be more you can cover, Murch, anything?  Okay.

_Bitcoin Core #28121_

We have two notable code and documentation changes this week.  First one,
Bitcoin Core #28121, which adds additional detail to the testmempoolaccept RPC,
the response from the testmempoolaccept RPC, in the event of an error.
Testmempoolaccept is a Bitcoin Core RPC that tests whether a given transaction
would be accepted into that node's mempool, but does not actually broadcast it.
It's essentially a free broadcast validity check, and it's useful for developers
to debug transaction construction issues before actually broadcasting the
transaction.  The RPC had already included a reject reason-field in the
response, but this PR adds a reject-details field with more information, which
could be useful for debugging, which is mostly what that RPC is used for
anyways.

_BDK #1592_

BDK #1592 adds two Architectural Decision Records, ADRs, to the BDK repository.
These are the first of potentially more ADRs, or decision records, that document
important decisions made on the BDK project.  It's helpful for newer
contributors to understand historically why certain architectural decisions were
made.  There were two included with this PR.  The first is a decision record on
why the BDK project decided to remove the persist module from the BDK chain
crate.  And the second decision record is why the BDK team added a
PersistedWallet type for more convenient wallet persistent options for storing
and loading wallets.  And so, there's those two and there's also a template,
which future decisions should be documented using that template.  And the
template was a format inspired by the Mozilla projects UniFFI Rust library.
Murch, this seems like a good idea.  I'm curious your thoughts on how you
compare documenting that tribal knowledge in BDK for newer contributors, as to
how that tribal knowledge is recorded and percolated in Bitcoin Core currently?

**Mark Erhardt**: Cool, great question.  So, we do have a wiki in Bitcoin Core
as well, I don't know if many people are aware of that.  For example, there is a
lot of stuff on the mempool changes in the wiki, I think especially documenting
how RBF used to work or how it differs from the description of BIP125.  And
there's also a few PRs that have very lengthy descriptions on exactly how things
were changed, either in the commit message or directly in the code.  For
example, Pieter wrote some extremely lengthy descriptions on -- or maybe that
was libsecp, but for the ElligatorSwift or Elligator-something stuff that he
added to libsecp, it's like a ten-page description of how the algorithm works
and how he arrived there.  So, a lot of that being directly in the codebase is a
good place because, of course, it's easy to find again.  But of course, it also
makes the files there a little larger.

**Mike Schmidt**: Great, that's it for this week.  Yeah, go ahead?

**Mark Erhardt**: Sorry.  We also of course have the IRC meetings, which are
archived.  And so, whenever people talk in the IRC channel, all of that stuff is
searchable, although maybe not compacted very well.

**Mike Schmidt**: Maybe it's up to the AIs to document this.  You just ask the
AI to give me the rationale behind XYZ.  Yeah, it sounds like it depends much on
the PR or the proposal's author to choose to include the rationale in a ten-page
explanation of the change, or if it's a one-line description then you've got to
look at the files.  Okay, great.  Dan, Greg, Abubakar, thank you all for joining
as special guests this week.  I thought this was a fun one.  Murch, good to have
you back, thanks for co-hosting.  We'll hear you all next week.  Cheers.

{% include references.md %}
