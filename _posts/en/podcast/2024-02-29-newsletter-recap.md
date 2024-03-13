---
title: 'Bitcoin Optech Newsletter #291 Recap Podcast'
permalink: /en/podcast/2024/02/29/
reference: /en/newsletters/2024/02/28/
name: 2024-02-29-recap
slug: 2024-02-29-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Richard Myers, Rijndael,
Luke Dashjr, and Jason Hughes to discuss [Newsletter #291]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-2-4/9d86a854-a984-ae05-e03a-ce5ce4440bd1.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #291 Recap on
Twitter spaces.  Today, we've got a good collection of news items including
talking about a contract for miner feerate futures, coin selection for liquidity
providers, including for LN, a vault prototype using OP_CAT, ecash using
Lightning and zero-knowledge contingent payments, and also a bunch of questions
from the Bitcoin Stack Exchange.  I'm Mike Schmidt, I'm a contributor at Optech
and also Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work on coin selection and other Bitcoin Core
topics at Chaincode Labs.

**Mike Schmidt**: Luke?

**Luke Dashjr**: Hey, I'm Luke, a Bitcoin Core developer and co-founder of
Ocean.

**Mike Schmidt**: Rijndael?

**Rijndael**: Good morning, I'm Rijndael, I'm a Bitcoin developer currently at
Taproot Wizards and right now focusing on R&D on fun things we can do with
OP_CAT.

**Mike Schmidt**: So, we have a Taproot Wizard and we have an Ocean
representative, so we'll try to keep it civil.  Richard?

**Richard Myers**: Hi, I'm Richard, I'm working on LN stuff, mostly with the
team at Async, and a little bit sort of more towards the intersection of LN and
layer 1.

_Trustless contract for miner feerate futures_

**Mike Schmidt**: Well, thank you all for joining us, taking the time out of
your day to talk about your ideas and your work.  We're going to go through the
newsletter sequentially here, starting with the News section, titled Trustless
contract for miner feerate futures.  Unfortunately, ZmnSCPxj wasn't able to join
us today, I think he said he's sleeping, so we'll try to represent his idea as
best we can.  I'll provide a summary and obviously any of our special guests or
merchants, feel free to chime in as well.

ZmnSCPxj posted an idea to the Delving Bitcoin forum, titled An Onchain
Implementation Of Mining Feerate Futures, and he walks through some of the
backstory and sort of sets this up.  He notes that future onchain fees that will
be paid to miners can't be predicted, and for users, like users of the LN,
there's some risk in onchain enforcement, especially if you don't know what the
fees are going to be, such that low onchain fees may reduce miner earnings on
the flip side.  So, you have these users that want potentially the fees to be
low and the miners that would want the fees to be high.  And so what he proposes
is a way for miners and transactors to hedge against these different fee
scenarios, so for miners to hedge against low fees while onchain transactors can
hedge against high fees.  Mining fee futures are incentivized on both sides, so
blockchain users want to bet that future mining fees will be high, so in case
that happens, they'll be compensated; and miners want to bet that the mining fee
futures will be low so that if mining fees become low, they will be compensated.

So, in his write-up, ZmnSCPxj describes how a miner and an onchain user could
create a futures contract in a trustless manner.  From the writeup, we used the
miner as Bob and the user or the person wanting to do a bitcoin transaction as
Alice, and each of those parties deposit funds into a funding transaction.  And
the assumption here is that Alice, who's the onchain transactor, expects to make
an onchain transaction near a specific block height.  And in the writeup, we
used block 1,000,000 as the example.  And we also then assumed that Bob is a
miner that expects to mine a block around that similar block height of
1,000,000.  So, they deposit funds into this funding transaction and the funding
transaction can then be spent in one of three ways.

The first one I think is the easiest to understand, which is just a cooperative
spend of the funding transactions output, however they want to use those funds,
and that would be using the taproot keypath spend.  The second way that this
funding transaction output can be spent is if Bob, who is the miner, he can
claim back his funds plus Alice's deposited funds if he can spend the funding
transactions output in that block 1,000,000, or shortly after that block.  And
the script that the miner would use in this path requires Bob, the miner's,
spend to be a certain minimum size.  And we used an example of maybe twice the
size of a typical spend.  So, that's the second scenario that would sort of be
Bob claiming the funds or winning this futures bet, if you will.  And then the
last way would be Alice, who's the transactor, she can claim back her funds plus
Bob's deposited funds if she can spend the funding transactions output sometime
after block 1,000,000.  So, there's sort of this time delay here.  We gave the
example of 144 blocks.  And then the key here is that Alice's transaction is
relatively small.  So, those are the three spending scenarios.

So, if feerates at block 1,000,000 are lower than expected, Bob can include his
large spend in that block and profit, which would compensate for the lack of
mining feerate at that time.  Or, if feerates at block 1,000,000 are higher than
expected, Bob wouldn't want to include his large spend in a block, and that
would allow Alice then, sometime after that block 1,000,000, to profit by
including her smaller spend in a block shortly after 1,000,000.  So, that's my
take on the summary.  Murch, do you want to elaborate on any of that before we
can maybe get into some of the implications here?

**Mark Erhardt**: I think the only thing that I'd mention would be that some
repliers to this proposal mentioned how it was neat that not only was there a
way now to speculate on the overall fees in a block, but that there's no
financially incentivized way of cheating, that it is sort of self-reinforcing.
It's only worth sending whatever transaction at the feerates that people are
speculating on.  So, if the feerates are low, it only makes sense for Bob to
publish their transaction.  If the feerates are high, it only makes sense for
Alice to publish their transaction.  So, this is not only imposed by the rules
or by the contract and requires people to behave properly, no, it only makes
sense to behave properly, otherwise they lose money.

**Mike Schmidt**: It's interesting how creative people can get even with limited
scripts.  You have this sort of feerate futures idea.  I think there was maybe a
similar idea about hashrate futures using Bitcoin Script as well.  So, people
are creative given the current limited environment.  Luke, Rijndael or Richard,
if you guys have any commentary, feel free to jump in.  Otherwise we can move on
to the next item.  All right.

_Coin selection for liquidity providers_

Next news item is titled Coin selection for liquidity providers.  Richard, you
posted an idea to Delving titled Liquidity provider utxo management.  And you
opened that post saying, "Current wallets are not optimized for liquidity
providers like Lightning nodes that fund requests for liquidity via liquidity
ads".  Richard, maybe you can explain liquidity ads in LN briefly, and then how
coin selection for those use cases might be different than a "normal" wallet
coin selection.

**Richard Myers**: Great.  Yeah, sure.  So, I mean I guess the impetus for this
is that a lot of threads in LN are sort of coming together and in particular,
they just merged the BOLT for liquidity ads, which is if you want to receive
payments on LN, you need to have inbound liquidity, but it has been unspecified
exactly how you would get that inbound liquidity.  A lot of the Lightning
Service Providers (LSPs) have mechanisms to do that, but this liquidity ads
creates a standard way for both routing nodes and also end users on an LSP to
potentially get inbound liquidity.  So, an inbound liquidity can be thought of
as sort of a transfer of a UTXO into the channel.  So, if you're splicing, you
can take, say, a 100,000-sat UTXO, splice it into the channel on one side, and
then that becomes the inbound liquidity for the user.

So, now that these things are coming together and fees are high, it begs the
question, what's the best way to do that?  And most wallets really aren't
optimized for that situation in a few ways.  So, the thought was, how could we
design our wallet and take advantage of the nice coin selection that Core has to
satisfy this particular use case in a way that really minimizes fees?  That's
sort of the overarching goal for this whole thing, is how can we do this, not
just to minimize fees for each transaction that, say, splices in or starts a new
channel, but also over time you know you're going to have this recurring flow of
UTXOs you want to spend of certain bucketed sizes, so how can we do that?  So,
yeah, that was the post and the draft PR is sort of an implementation, a sort of
first rattle out of the bag, but we're really looking for feedback on how if
there's any inspiration people might have on how to do that better; that's very
open for those ideas as well.

**Mike Schmidt**: Murch, you have quite a pedigree in this department.  What are
your thoughts so far?

**Mark Erhardt**: Yeah, well I was on vacation briefly and I haven't gotten
around to diving deep into this.  But one of the things that I noticed when we
were working on current selection stuff at BitGo was that one criteria you can
use to be for your pre-selection for consolidations, is that you just use the
oldest UTXOs for your consolidation transactions because they were not
organically useful in the longest time.  So, maybe that would be an interesting
approach, to look at what the oldest UTXOs are that are in the wallet because
those haven't been used, and use those to replenish the buckets that Richard is
talking about from which the liquidity ads are staged.

**Richard Myers**: Yeah, that makes sense, like perhaps the feerates have
changed so that those older UTXOs haven't been taken just by themselves.  Makes
sense.

**Mike Schmidt**: Richard, what's feedback been so far?

**Richard Myers**: We haven't gotten a lot of feedback, so we still hope people
will get around to looking at the proposal.  Internally, we're just sort of
iterating on creating simulations, so most of the feedback has really just come
from running simulations and seeing what the thing does, and that's ongoing.
But I think the initial feedback from the simulations is that we can optimize
for this situation and lower fees, so it's encouraging us to continue with it
and see what more we can do.  But ideas, like what Murch said about introducing
time in there and thinking of it as sort of a cache and figuring out how to sort
of optimize it like that is important.  I mean, one other way implicitly that
this is different than a normal, say, exchange wallet is we don't necessarily
have both incoming transactions and outgoing transactions.  It's really mostly
spends and then maybe an occasional top-up.  So, it's probably a little bit
different than what a lot of exchanges have optimized for.

But I'm also curious too, and maybe people on the call have some thoughts on
this, are there other applications that have this sort of usage pattern of fixed
size UTXOs being spent?  One idea was perhaps coinjoins, or maybe something
similar to that.  So, if anybody has thoughts on that, I'd be curious to work
with those communities too to see if they have similar need.

**Mike Schmidt**: Actually, Abubakar requests speaker access.  Abubakar, do you
have thoughts on the coin selection here?

**Abubakar Ismail**: No, I'm so sorry, I accidentally request for the mic.

**Mike Schmidt**: Okay!

**Mark Erhardt**: Okay, then let me say one more thing.  So, even if you have a
big business where you make a lot of payments, especially on exchanges, you'd
just try to batch those payouts, for example.  So, you're totally fine as long
as you have some big chunks that you can spend down from, and you need enough of
them that you can bridge a very slow block.  If there is no new block found for
an hour and you only spend confirmed UTXOs, you probably need 20 to 100 or more
UTXOs even if you are already batching.  But here with the liquidity ads, where
you are really going for only making a single

payment and you are trying to hit exactly a certain range of amounts, then
creating a change output on each of those transactions is a significant overhead
versus when you make a batch payment where you pay 50 people, whether or not you
add a change, it doesn't really weigh into that transaction that much.  If you
have a single input, a single output, adding a second output significantly
increases the size.

Of course, you don't want to do extra transactions at high feerates in order to
create UTXOs of the right size, if you're just going to then also spend those
UTXOs at high feerates themselves.  But at low feerates, when you pay maybe a
tenth of what you'll pay later when the liquidity add is being bought, you can
make some of those fitting UTXOs, because it'll be cheaper to do it now and then
later use them.  So basically, I'm just paraphrasing how I understand Richard's
problem and how it's unique even from, say, a spend-only exchange wallet where
you have a lot of volume, but you don't really care to have these exact amounts
so often.

**Richard Myers**: Yes, that's true.  I mean, the avoiding of change is
definitely a much higher priority, and when we look at the simulation, the best
results are when we can find a single input that satisfies that particular
liquidity add.  But yeah, that's sort of an ongoing struggle.  And one other
thing I didn't mention before that's an important aspect of this problem is,
what we're funding is going to be this liquidity through the funding transaction
for an LN channel, so we really can't trust our change.  So, any change that is
produced is going to have to wait for that potentially low fee transaction to be
confirmed.  And these things can be at a low priority because the channel can
still be used in the case of a splice, so it may be a quite a long delay.  So,
any change we add could be kind of slow in coming.  So, yeah, that's the other
reason we want to, as good as we can, predict and have a set of change outputs.
But I think from what Murch said from the exchange standpoint is, I think
there's probably also an aspect that's like an exchange, where we might want to
have some large transactions that can just be split up occasionally into
different outputs.

I didn't say that the sort of key to the strategy we've implemented now is that
when you do have change, we don't just go for the minimal change or the change
that matches the size of the input, which is a sort of current Core thought way
of doing it for privacy reasons.  Instead, what we do is we target a change
output when we need to use change that can be broken up into UTXOs of the sort
of anticipated size.  So, that's the sort of minimal change to Core that we
would want, is to see if we can specify a custom minimum change target.  So,
anyway, yeah, there's lots of ways we can look at this, but it's good to get
that feedback.

**Mike Schmidt**: Murch, maybe one question to wrap up here.  As a coin
selection guru, how do you look forward into the future about maybe different
personas, like Richard's talking about one persona or one way of doing coin
selection for a particular use case; I could also see others, like maybe there's
privacy-minded people that would want to have some more control over their UTXOs
that maybe wouldn't be manual, like, how do you see that?  Is there like an
interface of sliders that you'd have or would people plug in their own coin
selection algorithms based on their usage?  How do you see that in the future?

**Mark Erhardt**: Yeah, I mean, it's really hard to make a one-size-fits-all
approach, and we have absolutely no information about who our customers are and
what their needs are, except for our own gut feelings and whenever somebody
actually approaches us and tells us something.  So, my theory is that most users
of Bitcoin Core are probably end users.  There is a small count of businesses
that use Bitcoin Core.  And so far, we only use the waste metric, so a financial
heuristic on which input set to prefer, and I would very much like to backfill
that with two more heuristics.  One sort of wallet health heuristic that is
informed by the frequency that the wallet transacts and looks at the size of the
UTXO pool of the wallet, and maybe also the composition of the UTXOs.  So for
example, if there's a ton of really old UTXOs that are large and the wallet also
uses new UTXO types already, that it would consider that a sort of detrimental
health feature and would, at low fees, more aggressively spend these old UTXOs
that are more block space inefficient and turn them into block space efficient
new UTXO types that the wallet already uses, and things like that.

So, from the wallet health metric that would fit, hopefully you could say how
many UTXOs do you expect, or it learns from how many transactions this wallet
makes, what a good number of UTXOs would be.  And then from a privacy metric, I
would hope that we would at some point be able to have a score that looks at how
the input set is composed and how that impacts the privacy of the user.  What is
the pedigree of the UTXOs being used; do we combine two UTXOs of vastly
different age, like a ten-year-old UTXO and a two-week-old UTXO; do we spend
different UTXO types together; does the input set match the recipient output;
does the change output and the recipient output differ; and stuff like that.
So, we would hopefully be able to have satoshi-denominated scores on each of
these three heuristics, just like the waste metric currently has a
satoshi-denominated heuristic, and then we could actually calculate an optimal
score.  And then I can go crazy and write ten more coin selection algorithms
that produce input sets, and we choose from that per the optimal score.  That
would be my vision.  But it takes nine months to get CoinGrinder merged, so I'm
not sure how long that'll take to get out there.

**Mike Schmidt**: Jason, did you have a comment on coin selection?

**Jason Hughes**: No, Luke actually told me to jump in here and I'm running a
little behind.  So, maybe I missed something from before if we were talking
about the Ocean TIDES payout system.

**Luke Dashjr**: We haven't gotten to it yet.

**Jason Hughes**: Okay.

**Mike Schmidt**: Yeah, we'll get to it.  Thanks for joining us.  Okay.
Richard, thanks for joining.  You're welcome to stay on, but we understand if
you need to drop.

_Simple vault prototype using `OP_CAT`_

Next news item, titled Simple vault prototype using OP_CAT.  Rijndael, you
posted to the Delving Bitcoin forum about a proof of concept vault
implementation that uses the proposed OP_CAT code.  Maybe talk a little bit
about the prototype from the technicals as well, and then have a few follow-up
questions for you.

**Rijndael**: Yeah, sure.  Good morning.  So, I've been really curious about
what it would look like to actually use OP_CAT in practice to build covenants
for Bitcoin.  So, Andrew Poelstra wrote a blog post in, I want to say, 2021.  I
know it's been covered by Optech before about how you could use OP_CAT along
with some tricks with schnorr signatures in order to get the common signature
message that's specified in BIP341 onto the stack, and assert that it matches
the transaction that is being validated.  So, the idea, or the way that you
would use that mechanism, is you could specify ahead of time which elements of a
transaction you want to have fixed in a particular script, and then you would
build up the rest of this common signature message on the stack, you would do a
bunch of concatenation to build up a schnorr signature, and then you'd use just
vanilla CHECKSIG to assert that the signature that you have on the stack is
valid for the transaction.

So, I started playing with this a few weeks ago and built a really basic
covenant that can only spend to itself, and I thought that building a vault
would be a really nice way to explore what's actually capable with CAT and what
it's like in practice.  A lot of people have hypothesized about the size of
these scripts or the complexity, or whether or not certain things were possible.
So, the reason why I picked a vault, there's two reasons.  One of them is that I
think vaults are an actual useful capability for Bitcoin users.  Like, if you
want to hold a lot of value in Bitcoin, then adding reactive security to be able
to get your money back if somebody is stealing it, if they compromise your keys,
is a really useful capability.

But then the other thing is, with vaults, so for folks who don't know, the idea
of a vault is you have a UTXO and when you want to spend it, it can only go to
sort of an interstitial withdrawing step where you have to wait for some time
lock to expire, and then you can actually move your money to whatever its final
destination is.  So, that implies that there's some amount of state that spans
multiple transactions, because when you go to withdraw your coins, you say, "I
want to take 1 bitcoin to this address".  You move your coins to this
withdrawing step and then after the time lock has expired, you're able to move
them forward.  And you don't want that destination to be able to change between
when you triggered the withdrawal and when you complete the withdrawal.

The way that this has been solved in the past, with proposals like James OB's
OP_VAULT, is when you go to trigger the withdrawal, you include an
OP_CHECKTEMPLATEVERIFY (CTV) hash that will be enforced during completion.  We
can't really do that with just OP_CAT, and so what I needed to do was say, when
you trigger the withdrawal, one of the outputs of that transaction is the
scriptPubKey of your final destination and a dust amount.  And then, when you do
the withdrawal completion transaction, you actually need to inspect that output
of the prior transaction in order to assert that state.  So, what's being done
here is we are inspecting an output of a prior transaction and using that to
carry state forward, which on its own is a super interesting primitive for
building new kinds of scripts and like new kinds of applications with Bitcoin.
And then, the other thing that's really interesting is, we are partially
specifying outputs.

So, with something like CTV, you have to fully specify all of my outputs,
"Here's the scriptPubKey and here's the amount for all of them".  In order to
make this vault work, there's some steps in the workflow where you are fully
specifying the amount, or you're fully specifying the scriptPubKey and you're
doing one or the other or both.  So, I thought that the vault would be just an
interesting way of exploring, what does it look like to have partially specified
inputs and outputs; and what does it look like to use attributes of the bitcoin
transactions themselves to carry state forward and to build these simple little
stateful multi-step transactions?  So, I'll pause there, that was a lot of
words, but that was kind of the intent.  And in addition to the Delving Bitcoin
post, there's also a link to a Git repository that has a fully functioning demo.
It runs on regtest on your local machine.  You type three commands and you can
actually run the vault yourself.

**Mike Schmidt**: Rearden Code, I saw you request speaker access.  I don't know
if you have questions or comments.

**Brandon Black**: I have a specific question about this, I think it's awesome,
and that is, with these CAT-based vaults, can you get fee flexibility where you
can have a vault that has rules like, "In the withdrawal process, no more than
5% of the sats go to fees?"  What kind of flexibility do you gain with CAT
versus the pretty restrictive, the fees come from outside the vault that you get
with OP_VAULT?

**Rijndael**: Yeah, that's a great question.  And I'm glad you asked that
because I can also address some points in a helpful comparison table that the
Optech team put together in this week's newsletter.  So, in my current
implementation, I don't have any arithmetic over input and output amounts.
Instead, all of the vault money has to just sort of move from the input to the
output and it's not paying for fees.  It's just if you have one coin on the
input for the vault amount, you must have one coin on the output for the vault
amount.  The way that I currently have this written is when you do a trigger
transaction, the complete withdrawal transaction, or a cancellation transaction,
when you do any of those things, you have to provide a separate input to pay for
the fee, and that input will be completely consumed.  So, you need to choose
your input wisely.

There's nothing at a protocol level that would prevent you from having your
vault input pay for the fees or for having a change output.  The reason why
that's not done yet is in Bitcoin today, we only have 32-bit arithmetic, and so
you can't just use normal Bitcoin addition opcodes in order to validate input
and output amounts and make sure that not too much of the vault balance is being
burned to fees.  So right now, if you let people just do variable output
amounts, spending the vault input, then you open yourself up to an attack where
somebody compromises your keys and they can start an unvaulting operation, and
maybe they can't steal all of your money, but they can burn all of your money to
fees.  So, in order to fix that, what we'd really want to have is 64-bit add
support in Script, either first-class 64-bit add support, or using OP_CAT, you
could do it as like a big num type implementation where you're doing 32-bit
arithmetic, you keep track of if there's a carry, and then you CAT all the
results together for a 64-bit amount.

If we had that, then you'd have more flexible fee specification, and then the
other thing that you'd be able to do is you'd be able to batch withdrawals,
which is something that you can do in OP_VAULT, but you can't do in my current
demo.  So, you'd be able to batch withdrawals to share that cost, and you would
also be able to do partial withdrawals, where you have a vault with 10 bitcoin
in it, and you want to be able to only withdraw 3 bitcoin, you'd really like to
not have to unvault an entire UTXO at once, or an entire vault at once.  So, the
only thing that's really preventing that right now is, I haven't had the time to
sit down and build proper 64-bit add with CAT.  But if somebody's interested in
doing that, it would slot into my current vault implementation really nicely and
you would get batching, partial withdrawals, and more flexible fee payment.

**Brandon Black**: So, correct me if I'm wrong, but couldn't this vault work
without 64-bit arithmetic if you assert that the amounts are 32-bits only, which
works for up to 40 bitcoin per UTXO?

**Rijndael**: Yeah, you could do that.  You could, that would definitely be just
a limitation of, don't use this vault if you have more than 40 bitcoin.  But
then again, part of the appeal of vaults is you have a lot of bitcoin that you
want to protect, so that might limit the usefulness of the vault.  The other
thing that you could do if you wanted is you could pre-commit to a bunch of
different tapleafs with slightly different variants of the script that just
pre-commit to different amounts.  So, if you know that you're going to have 100
bitcoin in a vault, you could say, "I'm going to have one version of this that
peels off 1 bitcoin, another tapleaf that peels off 2 bitcoin, another tapleaf
that peels off 3 bitcoin, and you could pre-bake these different denominations.
It limits your flexibility a little bit, but it would also shrink the script
size.

**Mark Erhardt**: Could you perhaps also continue to use 32 bits if you just
reduce the precision?  So, you could say instead of denominating it in satoshis,
you denominate it in microbitcoins as in 100 sats, so that would give you 100X?

**Rijndael**: Yeah, that's a really great idea.  I will check that out.

**Brandon Black**: I guess you probably do it by bytes, so you'd strip off a
middle 32 bytes out of the amounts and then do math on that.

**Rijndael**: Yeah, that's a great idea.  So, if I can just throw a quick plug
out there, what I'd ask folks to do maybe, if you're interested in this, either
because you're excited about CAT or if you hate CAT, is maybe just take a look
at it.  I found in practice, doing this kind of assertion over inputs and
outputs of the transaction ended up being less onerous than I was expecting.  I
was pleasantly surprised by it when it all came together.  So, if you're
interested, you can run it.  Feel free to shoot me any questions you have.

**Mike Schmidt**: It's great to see the concept or prototyping work based on
some of these proposals as well.  I know that's something that the communities,
various members are curious about seeing since there's so many proposals out
there.  So, thanks for putting it together, thanks for walking us through it,
thanks for the call to action.  We'll move on in the newsletter.  Murch had a
suggestion, since we have two Ocean people sitting here waiting, maybe we should
just briefly jump down to the Stack Exchange question that involves you guys,
and you guys can walk us through that and we won't monopolize too much more of
your time.  Luke, are you okay with that?

**Luke Dashjr**: I guess so.

**Mike Schmidt**: Okay, I've also brought Jason back up as a speaker.  So, for
those following along, we're jumping into the middle of the Stack Exchange Q&A.

_How does Ocean’s TIDES payout scheme work?_

There was a question on the Stack Exchange, actually it was you, Murch, who
brought this up, "How does Ocean Tide's payout scheme work?"  And, Murch, you
brought this up about three months ago saying, "This week, a new mining pool,
Ocean, was announced.  The mining pool uses a payout scheme titled Transparent
Index of Distinct Extended Shares, TIDES".  And there was one fairly lengthy
answer on the actual Stack Exchange, which I believe, Murch, you accepted, but
we also have Luke and Jason from Ocean here.  And Luke also linked me earlier
today to ocean.xyz/docs/tides for more information about this, but I'll let them
maybe summarize what TIDES is and maybe how it's better than other payout
schemes with the caveat of, we are not very familiar as an Optech audience with
the minutiae here, so maybe if you can keep it somewhat high level on the
distinction between this scheme and others, maybe that would be helpful.  Sorry,
we'll turn the floor over to you guys.  Luke or Jason?

**Jason Hughes**: I guess I'll jump on that.  So, TIDES is kind of a derivative.
It was what PPLNS was supposed to be.  I don't know if anybody was here that is
familiar with PPLNS, but it's basically a payout system where the pool doesn't
have to buffer funds from miners.  So, when a block is found, the funds are
immediately rewarded to miners in pretty much as fair a way as possible.  It
tries to keep variance low so that your payouts are consistent once you're with
the pool for a bit.  And it's not like any other system, like where PPLNS was
implemented before, where you lose resolution of your rewards through shifts or
anything like that, where the pool is just trying to do a speed-up to make
things easier on their end.  We track every single submitted share in order and
keep it that way so that the entire window is rewarded at every block.

The main thing is, it's low variance, we reward for every block.  You can
confirm your split of the reward so that when we find blocks, you can look at
what you submitted versus what the pool actually earned and what the pool
actually mined and do the math and see that you actually got what you were
supposed to get.  And as far as I know, nobody else does anything close to that.
So, that's kind of the high-level overview and open to questions.

**Mike Schmidt**: Jason, you mentioned this shifts and potentially resulting in
miners getting significantly less accurate payments based on the hash rate that
they've contributed.  Can you define what these shifts mean and how that could
be bad for an individual miner?

**Jason Hughes**: So, the way PPLNS is supposed to be and the way TIDES actually
is, is you're supposed to submit your shares.  They go into kind of a record on
the pool side and then when a block is found, the last N, which is the N in
PPLNS, the last number of shares that's predefined is gone back through and
rewarded by the pool.  Well, what other pools have done in the past to implement
PPLNS is do a speed up call.  Some have called it shifts, some have called it
some other things.  But they'll just take some block of time, let's call it ten
minutes or so and call it a shift, and they'll just add up everybody's shares in
that shift and then that will be what is rewarded.  And what ends up happening
is you just lose resolution, so it's not as accurate of a payout system.  It's
not so much that you would lose or gain from it, it's just not accurate.
There's no way to really validate that because they're clumping miners together
in some arbitrary timeframe, instead of actually rewarding the last N shares
like they're supposed to.  So, as that averages out, depending on how the math
works out, the pool could possibly push that in their favor or push it out of --
it could be skewed, basically, it's just you lose the resolution.

With TIDES, we don't do that, there's no shift.  There's one shift, the entire
share window, which right now, with the current difficulty, is like 650 trillion
shares, and we track every single one in order to make sure everybody gets their
fair split.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: So, to be clear, there's not some trillions of work items you
take care of, but each mining pool contributor has an individual difficulty.
And if they submit a share that meets that individual difficulty, their share
counts at that individual difficulty level of their own work package, right?

**Jason Hughes**: Correct.  Internally, it's counted as if, like our minimum
difficulty is 16,384, and if you submit one difficulty 16,384 share to the pool,
that counts in tithes as 16,000 individual shares, so that the sum of
everybody's shares that have contributed currently sums up to 8 times the
network difficulty, which is like 650 trillion-ish.

**Mike Schmidt**: And Dan, did you have a question?

**Rijndael**: Yeah, I think Jason might have just answered.  So, the picture
that I have in my head right now is you have some fixed width buffer, and it's
like a ring buffer, and just as people submit shares, they aggregate in here,
and the newest share in pushes out the last share.  And then when you find a
block, you assign rewards based on who's still in the buffer.  So, I was going
to ask how you determine the size of the buffer, and it sounds like it's a
multiple of the difficulty, is that right?

**Jason Hughes**: Yeah, it is.  So right now, I don't think we have any
intention of changing it or updating it, but the intention is for it to be eight
times the network difficulty number of shares.  The window size is estimated
until a block is found.  Obviously, the difficulty doesn't change all that
often, but when the block is found, the difficulty of the block that is found is
used to determine the size of the window.  We never discard shares, because if
the difficulty goes up, well, we might have to dig back further.  If the
difficulty goes down, we're not digging back as far.  So, it's determined by the
block that's actually found.

**Mark Erhardt**: And then you just divide by the number of shares that each
miner has contributed and give them that relative portion of the total reward?

**Jason Hughes**: Yeah, pretty much.  It's simpler than it sounds, but it's a
way to make sure it's fair and auditable.

**Rijndael**: Yeah, and I know that you guys long term want to work to lower the
payout threshold.  I've heard talk about payouts over LN or something else.  I
imagine that this system is going to help with that, because when somebody hits
whatever their payout threshold is, you have a better record of what their old
shares are, and like that's more auditable and verifiable by the individual
miner.  Is that kind of the idea?

**Jason Hughes**: Yeah.  I mean, so we're actually working on something towards
that now.  And the main thing is that it's transparent, so it's not just the
miner that can validate it, you can use the public stats to validate that
everyone on the pool got their fair split.  And it doesn't matter if that's --
it's down to 1 sat resolution.  So, that's obviously as low as we can go with
paying it directly in bitcoin.  So, the main thing is that anybody can verify
what they're supposed to get and how that gets paid out.  The main thing we're
going to try to do is get everybody in the generation transaction directly so
that people are paid by the network, and that's calculable on the fly by TIDES
for every bit of work that miners are given, so that we have basically the
payouts right from the network.  And for people that can't get that for whatever
reason, they're a small miner, the generation transaction does have a size
limit, thanks to Bitmain, those are going to be with LN or through some other
mechanism to be determined.  I mean, it's all auditable though.  So, it's not
like we can not pay someone.

**Mike Schmidt**: Murch?  Okay.

**Mark Erhardt**: Yeah, well, okay.  Let me ask the question, even though I feel
like I now understand how it works.  But obviously you do not know what shares
were submitted when the block is found because you give out a block template and
then miners might be working on their work package for 30 seconds, or even more.
So, obviously you're not going to get paid out in the block for the work that
you're doing to find that block.  But what you can do is when you request the
payout, the payout will be included in the coinbase transaction immediately, so
you do not have to stage funds separately from the block rewards.

**Jason Hughes**: So, the technical way around that is the actual rewards
calculated for the work that's being paid out in the generation transaction is
calculated as if that work had won the block already.  So, there is actually an
explanation about this in the explainer that we just did that goes into it in
more in-depth, but it does make it so that there is a little bit of a lag of
maybe like 30 seconds for the work, but that's the only fair way to do it,
because otherwise there's some exploits, like somebody could find a block and
hold on to it, shoot a bunch more hashrate at the pool, and try to bolster their
share window before the block comes in, and there's some exploits that that
avoids.  So, it is done by when the work is actually given by the pool.

**Mike Schmidt**: If you're curious about the details, I mentioned a moment ago,
I'll mention it again, ocean.xyz/docs/tides for a fairly lengthy writeup on
TIDES.  Luke or Jason, anything that you give users a call to action to, other
than miners joining Ocean?

**Jason Hughes**: I mean, I would just say if you want to be able to verify
you're getting what you're supposed to get from your pool and you're getting a
fair split of what you're actually mining, then there's nothing better than
TIDES at the moment.  If you mine with Ocean, you'll know what you're getting,
you'll see exactly what you're getting, you'll see what you're supposed to get,
and anybody and you can verify that that's actually been the case, and there's
no other pool that does that.  So, if you want transparency, we're the place to
go.

**Mike Schmidt**: Thanks, Luke.  Thanks, Jason.

**Jason Hughes**: Yeah, no problem.

**Mike Schmidt**: You’re free to stay on, but of course, if you have other
things to do, we understand.  Thanks for contributing.

_Sending and receiving ecash using LN and ZKCPs_

Jumping back up to the news section, we had one more to review.  This one's
titled Sending and receiving ecash using LN and ZKCPs.  This was opened with the
question from AJ, Is it possible to link ecash mints to the LN without losing
ecash's anonymity or adding any additional trust?  I believe it is".  Maybe it
would be useful to quickly define ecash, actually.  Luckily, Dave, Dave Harding,
added an ecash topic to the Optech Topic List this week.  And from that, I'll
quote, "Ecash is a type of centralized digital currency that uses blind
signatures to prevent the centralized controlling party, also known as the mint,
from knowing the balance of any particular user or from learning which users
were involved in any transactions".  So, check out the ecash topic entry.

Then also, AJ's talking about ZKCPs here.  We can define ZKCPs, which is Zero
Knowledge Contingent Payment.  Also on the Optech Topic List is an entry titled
Accountable Computing Contracts, which also covers this ZKCP.  I'll just read a
quick excerpt there, and then we can move on with AJ's proposal.  ZKCPs are,
"Payments that the receiving party can spend if they verifiably run a specified
function on a specified set of inputs.  If the receiving party doesn't run the
function or doesn't run it correctly, the paying party can reclaim the payment
after a small period of time".  So, what AJ is proposing is to connect ecash
mints to LN without losing ecash's anonymity or adding any additional trust
using ZKCPs.  What he'd like to do is be able to both pay the mint, the ecash
mint, over LN for issuing new tokens, and also redeem existing ecash tokens for
bitcoin to be received over the LN.  So, there's sort of the input of sats via
the LN to get ecash tokens and then getting those out in a reliable way.  And
then he goes on to outline a scheme for issuing new ecash by depositing
Lightning and another scheme for then redeeming the ecash to the LN.  Murch,
what have you got?

**Mark Erhardt**: Honestly, not terribly much.  I guess the main issue here is
that obviously the chaumian ecash that the mints use is not necessarily exactly
the same thing as Bitcoin transactions, and therefore it's not trivial to tie
these two together.  I think that it would be super-powerful if the mints were
connected to the LN and I think that's also been long the goal of the mint
projects.  The big elephant in the room with mins always is, of course, that the
mint itself is centrally run.  So, it's a custodial entity that you're trusting
your money with.  But they don't know who you are, so either they can steal from
everyone or randomly from people, but they can't censor specific people.  So,
it's trade-offs all the way down and, yeah, that's all that I got.  Does maybe
Rijndael or Rearden Code have something on this?

**Rijndael**: Yeah, I haven't read AJ's exact proposal.  I mean, I think you
ZKCPs are really interesting for a lot of these offchain payments protocols,
because what you want to be able to do is somehow encumber a UTXO to say, "This
can only get spent if you can prove that you followed some offchain set of
rules", like what you'd ultimately like to be able to do is say, the L1 bitcoin
that's held by the mint can only be dispensed by the mint if they can prove that
they are doing that to satisfy a legitimate withdrawal from a mint user.  That
ends up getting really hard because we don't have a ton of expressivity in
script and you can't select verify a ZKP.  And so, all the ZKCP schemes have
relied on offchain verification of a ZKP and then just using a straight-up hash
lock to do the encumbrance of the bitcoin.  So, I'm really interested to go and
read AJ's proposal here.  Anything with ZKPs are super-interesting.

**Mike Schmidt**: Excellent, I think we're going to wrap that item up.  Moving
back into the Stack Exchange, we have four remaining questions, I believe, this
week.

_Why can't nodes have the relay option to disallow certain transaction types?_

The first one is, "Why can't nodes have the relay option to disallow certain
transaction types?"  And so, the person asking this question specifically
mentions P2TR v1, which I guess is segwit v1 P2TR, which contain inscription
spam.  And that WhoIsNinja user asked this question and there was an answer by
Ava Chow, who went into some rationale about what is the purpose of mempool
policy.  And she notes a few different things, I think things we're mostly
familiar with, but I'll recap them briefly: P2P relay being a mechanism to
inform miners about a transaction so that it can be included in a block; users
who are transacting need to know the mempool policies of the miners and
potentially the nodes in between, such that they can be confident that they're
able to assume that that policy is somewhat homogenous so that the transaction
will actually get to a miner; and also, it's important that the best mempool
policy, one that maximizes miner revenue, in Ava's words, is publicly available,
is free and open source, so that small miners and larger miners can also exist.
So, that's some background.

Ava goes on to note the compact blocks benefit and the fee estimation benefit of
having more homogenous mempools.  She also notes, "The filtering of transactions
can also lead down the road of censorship".  Luke, do you have thoughts on this
topic?

**Luke Dashjr**: Yeah, I mean basically it's completely incorrect answer.  Is it
still open for being answered correctly, because that's basically just FUD and
incorrect.

**Mike Schmidt**: Where do you think would be a good spot to drill into one of
the disagreements?  I don't want to get into a whole debate, but maybe throw
something up.

**Luke Dashjr**: I don't know.  Is the Stack Exchange question still open, or
should I just post a correct answer there?

**Mike Schmidt**: Yeah, I think it is.  I don't know if any of these close,
yeah, so you can still provide an answer there.  The question's only a few weeks
old.

**Mark Erhardt**: Yeah, Stack Exchange questions do not close.  The asker did
accept already another answer, but I don't think that that is a serious answer
at all.  So, you can continue to add answers at any time.

**Luke Dashjr**: Okay, what's the best way to find these?

**Mark Erhardt**: Well, it's linked in the Optech Newsletter.

**Mike Schmidt**: Yeah, if you go to the newsletter for this week, you can see
the question, and it will link right to the Stack Exchange where you can opine.

**Luke Dashjr**: Okay, I'll take a look.

**Mike Schmidt**: Great.  Next question.  Oh, go ahead, Murch.

**Mark Erhardt**: Maybe I can disagree politely here.  So, basically the
question is asked, "What is the problem if every node has their completely
different approach on what they relay?"  And one of the issues that arises from
that is that it would be harder to spread information about what transactions
are available for mining in the network and it would slow down block
propagation.  I don't think that those are all that --

**Luke Dashjr**: Those are the good effects of spam filters there to prevent the
spam from getting anywhere.

**Mark Erhardt**: Yeah, sure.  Okay, anyway, moving on.

_What is the circular dependency in signing a chain of unconfirmed transactions?_

**Mike Schmidt**: Next question from the Stack Exchange, "What is the circular
dependency in signing a chain of unconfirmed transactions?"  The person asking
this question is referencing the latest Mastering Bitcoin book by Dave Harding,
who is also the author of the Optech newsletter.  And the question references
Chapter 6, a section titled Circular Dependencies Issue.  Murch, maybe you could
take a crack at explaining the circular dependency issue of transactions,
especially since you were one of the people answering this question?

**Mark Erhardt**: So, basically the question hones down at, why is it difficult
to know what an output of an unconfirmed transaction eventually will be?  And
the problem with that is, of course, that when you make an input for a bitcoin
transaction, you have to reference what piece of bitcoin you're spending
exactly.  And you do so by pointing out which transaction created a UTXO and
what the position in the output list of that transaction that was.  So, if you
do not know the txid of the prior transaction, you cannot say what the input
will be to use.  So, before we had the signatures in the witness portion of the
transaction, the signatures appeared in the input script, and the input script
of course contributes to the txid.  So, if you wanted to make a chain of
unconfirmed transactions such as, for example, making a funding transaction that
creates an LN channel and adding the payback to the funder in case the other
person just goes away, you can't make the payback transaction before signing the
funding transaction, because without the signatures, you do not know the txid of
the funding transaction and therefore don't know what to call the input for the
return transaction.

So, what segwit enabled, by putting the signature data into the witness, is that
the witness does not contribute to the txid, it only contributes to the witness
txid.  So, you know what the name of the transaction will be for the outpoint,
or sorry, the name of the UTXO that the input is going to spend of the follow-up
transaction, even before it is signed.  And that's why Lightning got so much
easier after segwit was introduced, because you were able to have these txids
earlier before signing.

**Mike Schmidt**: Go ahead, Rijndael.

**Rijndael**: Yeah, and this problem of the location of an input is specified by
the txid, which is a commitment to the version, the LockTime, the inputs and the
outputs, that problem ends up popping up in a bunch of other contracting
protocols that people are trying to build out.  So, for folks who might have
heard of ANYPREVOUT (APO), the idea there is that you can not have to have a
signature cover the specific inputs of a transaction, which lets you re-bind
pre-signed transactions later.  For the vault that we talked about earlier, I
ran into this problem where you need to be able to encumber where coins are
coming from or where they're going, but you don't know the txid ahead of time.
And so, the way that that gets solved in these CAT-style covenants is that you
can pass in, as witness elements, all the data that you need in order to
reconstruct the txid, and then you can assert that that txid matches one of your
inputs.

So, this circular dependency problem was solved in some ways by segwit, but in
some of the other covenant-y things that people want to do for LN or for other
protocols, it pops up again.  And that's one of the things that's driving the
discussion for either new signature hash (sighash) flags or new opcodes or other
ways that we can specify where bitcoin should be going or how it should be
spent.

_What data does the Bitcoin Core wallet search for during a blockchain rescan?_

**Mike Schmidt**: Thanks for that color, Rijndael.  Next question from the Stack
Exchange, "What data does the Bitcoin Core wallet search for during a blockchain
rescan?"  So for example, let's say you're running Bitcoin Core, you have a full
node and you want to import an existing wallet, and you'll need to do a
blockchain rescan to figure out what applicable transactions from blockchain are
particular to your individual wallet.  The person asking this says, "Does the
wallet database store a table of all the actual output scripts derived from its
keypool?"  And Ava responded, "Kind of", and Pieter responded, "Exactly", which
I thought was kind of funny.

Both Ava and Pieter answered the question, pertaining to both descriptors as
well as legacy wallets, and expanding those descriptors into a set of
scriptPubKeys to look for during the scanning.  And then also for legacy
wallets, Ava says, "It's a lot more complicated.  It will determine the type of
script and then do lookups for scripts and keys in the wallet depending on the
type".  So, there's obviously some differences between what we call legacy
wallet, which is being phased out, and descriptor wallet, which is the new
hotness.  Murch, what would you add here?

**Mark Erhardt**: Sorry, I was distracted.  I currently do not have anything at
the ready.

**Mike Schmidt**: Okay, no problem.  Sorry to put you on the spot.  Well, if
you're curious about the details there about converting descriptors into
scriptPubKeys and some of Eva and Peter's thoughts, check out that Stack
Exchange answer.

_How does transaction rebroadcasting for watch-only wallets work?_

Last question this month from the Stack Exchange, "How does transaction
rebroadcasting for watch-only wallets work?"  The person asking this says, "I'm
wondering what bitcoind does if I submit a raw transaction with a minimum fee
that is 1 satoshi per vbyte (sat/vB) for a local watch-only wallet when the
mempool is full and the mempoolminfee is higher than 1 sat/vB.  Does BitcoinCore
have a 'special mempool' for transactions that it knows is part of its own
wallet; or will Bitcoin Core reject that raw transaction?  Murch, do you want to
take this one since it sounds like I'm having some mic issues?

**Mark Erhardt**: Sure.  Yeah, so the transaction is not treated specially by
the mempool, but a Bitcoin Core wallet will treat its own transactions
specially.  So, if we are looking at a watch-only wallet, the transaction
probably didn't originate with the Bitcoin Core wallet, but it was created in
some way, somewhere different, or maybe it was broadcast through that node, but
not necessarily.  So, if it was not broadcast through this node, the wallet
would not know about it, so there would be no way for the wallet to prioritize
it or treat it specifically because it doesn't even know about it.  So, under
the assumption that the transaction at some point made it into the mempool, the
wallet would pick up that this transaction is relevant to it and would start
rebroadcasting it because it's its own transaction and it has learned about it.
Otherwise, if it doesn't make it into the mempool, the wallet doesn't learn
about it and therefore, it will not be treated specially in any way.

**Rijndael**: Or, another common case might be if you have the watch-only wallet
in your copy of the Bitcoin Core wallet, but you have a signing device either in
an air-gapped machine, or you're using a hardware signer with HWI, or something
else, then in that case you might be broadcasting the transaction from this
watch-only wallet, even though you've signed it somewhere else.  And then,
exactly as you said, your wallet knows about it and will try to broadcast it
when it connects to peers, or whenever else.

**Mark Erhardt**: Right.  Thanks for taking that one, Murch.  I apologize for
the audio quality.  I don't have my wired headphones with me, so I was using my
AirPods, and now I'm using the phone mic.  So, hopefully this is not worse, but
luckily we only have a couple things left on the newsletter this week.

_Core Lightning 24.02_

Releases and release candidates, Core Lightning 24.02.  This release is titled,
uint needs signature.  Nice reference there.  There's a few different
improvements that we noted and a couple more that I saw when I dug into the
release notes.  The first one is that Core Lightning's (CLN's) recover plugin
has improvements, which is a way to recover seeds.  And I guess there's some
anxiety that's been relieved with the features added to that particular plugin
with this release.  There's also improvements in CLN to anchor channels being
more flexible and more reliable.  There's also a patch for libwally, which is a
sort of primitives library that CLN uses.  And libwally had a problem parsing
Bitcoin blocks, specifically a large transaction on testnet.  And so CLN has
patched libwally to address that in this particular release, and they want to
encourage everyone to upgrade.

Also, there's optimizations in the way that CLN processes blocks, meaning that
they can sync with the Bitcoin blockchain 50% faster than before, which is quite
an improvement.  And this release also has the newest version of the splicing
protocol implemented, and that is still marked "experimental" but they encourage
folks to try it out, because it could also inform the spec process as well.
Murch, any thoughts on that CLN release?  Some interesting things in there

**Mark Erhardt**: I love the name!

**Mike Schmidt**: I think I saw that Rusty Russell, who's somewhat highly
involved with CLN, didn't realize the nickname of the release until recently, so
that's kind of funny.

_LDK #2770_

We have one Notable code change this week.  I'll take the opportunity to solicit
any questions or comments from the audience, and we'll try to get to those after
we summarize this LDK PR, LDK #2770.  The PR is titled Preliminary refactoring &
structure for dual-funded channels.  Yay!  This is part of LDK's effort to
implement v2 channel establishment, and the parent PR to this, if you will, is
#2302.  And LDK also has a tracking issue for both dual-funded channels and
splicing.  That's LDK #1621 for that tracking issue.  Murch, you know I'm a
sucker for tracking issues.  So, if you want to get the high-level view of LDK's
progress towards dual-funded channels and splicing, check out that #1621.  And
just looking at the commits for this PR, there's a bunch of changes to
constructors

and data structures in LDK to support v2 dual-funded channel types.  Anything to
add, Murch?

**Mark Erhardt**: I don't, I know nothing about this, unfortunately.

**Mike Schmidt**: Well, I don't see any questions or requests for speaker
access.  So, thank you to our special guests, Rijndael, Richard, Luke, and our
impromptu guests, Jason, Rearden Code, and even Abubakar accidentally!  Thanks
all for joining us.  Thanks to my co-host Murch, and we'll see you all next
week.  Cheers.

{% include references.md %}
