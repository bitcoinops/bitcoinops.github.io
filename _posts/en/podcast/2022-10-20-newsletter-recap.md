---
title: 'Bitcoin Optech Newsletter #222 Recap Podcast'
permalink: /en/podcast/2022/10/20/
reference: /en/newsletters/2022/10/19/
name: 2022-10-20-recap
slug: 2022-10-20-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by John Light and Gregory
Sanders to discuss [Newsletter #222]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-12/346757672-44100-2-0e499eddeca38.m4a" %}

{% include newsletter-references.md %}

## Transcription

_Block parsing bug affecting BTCD and LND_

**Mike Schmidt**: Well, let's jump into it.  We got a somewhat beefy news
section for this newsletter.   The first item we covered last week and we get
into a bit of detail this week, which is the block parsing bug that was
affecting BTCD and LND nodes, and we expanded a little bit on what happened
there.  So, there was a large, a very large taproot transaction with a witness
that had almost 1,000 signatures; I think it was something like 998 of a 999
multisig.  And the size of that witness caused BTCD and LND to not be able to
process that block correctly.  And my understanding is the reason for that is
there was actually a check that remained from a previous segwit policy rule that
limited the witness size and this large transaction exceeded that, and while
there were some tests in their code base that passed, there were some areas of
the code, and I think it was on the networking side, that that check did not
pass; there wasn't a test around that particular section of the code base.  So,
when this large witness came in, it essentially failed at the network level,
which caused all sorts of chaos that you've probably seen on Twitter for the
last week or so about what happened there.

So, there's a fix, as we talked about in the announcement section, make sure
you're updated.  And I think there was a little bit of discussion about whether
there should be limits for the taproot witness size or not and, Greg, I know you
kind of opined on that discussion.  Do you want to give your take on the pros
and cons of having a limit and what your take is there?

**Greg Sanders**: Yeah, so I was being a little gentle and mild on my email,
just pointing out that you'll burn people's funds, as a kind of a showstopper,
right, so we can stop talking about it.  But the whole point of taproot with the
witness script being unbounded size is that essentially, the validation cost is
proportional to how big the witness is itself.  So, there's no real need to make
extra limits on this bucket of resources that we pay for fees, right?  So, in
previous versions of scripts, you'd have things like, pre-segwit, you'd have
quadratic signature hashing (sighashing), meaning if you have a lot of inputs,
it's actually more expensive to validate than the linear cost you're paying.

But that went away with segwit, and then there's a few more updates, where
basically you go down to one metric, right, it's just the size, and this size
could be paid for using fees.  The size is proportional to how big the block can
be, directly, directly proportional.  So, there's no real need for these extra
buckets, in my opinion, and that was part of the design decision.  It's very
intentional how it was done.

**Mike Schmidt**: And I guess the example of burned coins or lost funds would
be, if somebody had previously, let's say there was a few other people who had
done this already, right?

**Greg Sanders**: Yeah, by logical deduction, Burak apparently put money in this
script, right?  And so, if somebody has put money in a script that's considered
very large or too large, then we decide, "Oh, that's illegal, it's too big",
then you burn their coins.  So, Burak's money would have been burned.

**Mike Schmidt**: Yeah, that makes sense, yeah, and like you said, that's
definitely a showstopper to re-adding in limits.  So, I guess that's a moot
point, although someone did bring that up as a potential consideration.  That's
probably good on the BTCD bug.

Rolling into the next news item from Newsletter #222 -- actually, I realize that
in waiting for Murch, we didn't actually go through introductions, so we can do
that really quickly.  Mike Schmidt, contributor to Bitcoin Optech and Executive
Director at Brink, where we fund open-source Bitcoin developers.  Greg, you've
already been speaking a bit, do you want to introduce yourself?

**Greg Sanders**: Yeah, my name is Greg or instagibbs.  I've done various
wallet-like systems and currently I'm working on Core Lightning (CLN).

**Mike Schmidt**: John, do you want to introduce yourself?

**John Light**: Yeah, sure.  So, my name is John Light.  I'm here today to
discuss a report that I published as part of my participation in the Human
Rights Foundation's ZK-Rollup Research Fellowship.  I published a report about
how we can build validity rollups, also known as ZK-rollups, on top of Bitcoin;
and by day, I work on a protocol called Zero as part of the Sovryn Community,
amongst other projects there, but Zero is my main focus right now.

_Transaction replacement option_

**Mike Schmidt**: Great, well thank you two for joining this week.  The next
news item in our newsletter for #222 is transaction replacement option, and this
references a couple of news items that we've discussed previously about Bitcoin
Core merging support for a configuration option for mempoolfullrbf, and maybe it
makes sense to just prime the discussion slightly with, there's two techniques
for increasing fees: there's CPFP fee bumping; and then there's RBF fee bumping.
So, CPFP would be if I have a transaction that I'm interested in having
confirmed, and it's sitting in the mempool, let's say, and I would like to get
that confirmed quicker.  Maybe fees went up or maybe I underestimated the fees,
and I really need to confirm that I can create a child transaction that spends
that outputs from that transaction and effectively overpay on that child
transaction so that I can get my parent transaction confirmed together, since
miners would be interested in that juicy child high feerate.

What we're talking about here is the other technique, which is RBF fee bumping,
and there's been a lot of discussion on the mailing list, and there's been a lot
of PRs recently around this, this mempoolfullrbf configuration option being one
of them.  I think it would make sense maybe, instagibbs, if you could kind of
maybe give an overview of within this RBF world, what's been happening, what's
mempoolfullrbf, the configuration option, and we can maybe get into some of the
concerns that Bitcoin services have about that.

**Greg Sanders**: Yeah, so there's a lot of context here which makes it
difficult, but I can talk about the specific things being proposed.  So
essentially, previously for RBF, transactions would have to explicitly opt into
this behavior.  So, you set your nSequence bytes, a part of your input, to say,
"Hey, I might replace this in the future", and nodes today, I think all nodes,
honor this flag and will do a replacement.  So, there's some arguments about, so
ignoring the context of the arguments, the current PRs that are out there,
suggested changes are basically saying, "Hey, in a world, we think that
replacement should be based on incentives, so someone's paying more fees for
this version of the transaction, replace it", because miners will tend to pick
up these things, game theoretically anyways.  So, while there's widespread
protocol support for this, there's arguments about, or discussions about, how
exactly to roll this out in a safe manner and a fair manner for those who are
still relying on zero-confirmation security protocols.

If you look at the newsletter, there's probably I think two open PRs now, and
there's two parts, is that in Bitcoin Core 24.0, there's an argument you can set
on your node, mempoolfullrbf, which will ignore the flag in the transaction and
replace it if the fees look better in a certain way, regardless of how it's
signaling.  Then the second piece is, do we want to delay this?  So, there's a
mixture of, do we want this feature for 24.0; and second would be, if and how do
we want to flip this to be default true?  Because in 24.0, this is default
false, meaning users would have to go in and change this variable themselves.
So, the question is kind of like, if and when should we switch this to true, and
if and when should this switch be in the software at all?  And so there's kind
of these competing narratives and discussions, and it's still being worked on.
I'll cede the floor for questions, I guess.

**Mike Schmidt**: I have potentially maybe a naïve question on this topic, which
is, so as things are today, your wallet software, if I'm creating a transaction,
I need to either have the option to signal or maybe it's just signaling default
behind the scenes, and maybe I don't have the option, but there is a required
signaling involved; and I guess subsequently then, depending on the wallet
software, I can have features that would allow me then to adhere to BIP125, and
if I adhere to all those, including certain requirements on how much I need to
increase the feerate, I can replace that transaction?  And in the future, a
potential future state that seems to be inevitable would be the not requiring of
the signaling.  Now, I guess my question to you, Greg, is if someone isn't
signaling replacement, is it likely that they would replace?

**Greg Sanders**: Yeah, so that's part of the context, I'll go into that.  So,
ignoring the game theoretic, this is nicer for miners long-term, what's the
actual argument from a wallet developer standpoint?  So, this would be things
like, just the simplest case would be coinjoins.  So, you have a group of people
contributing their own inputs in a coinjoin protocol or a coinjoin-like
protocol.  And so, you don't actually control all these inputs, right?  You
control your own and no others.  So, the issue here is that your counterparty in
a coinjoin could double spend their own input with something uneconomical, so it
won't get mined, it'll just stick in the mempool, well in their mempool, right,
and maybe the miners' mempool.  But on your side, you're trying to do a
coinjoin.  And even if the coinjoin signals RBF opt-in, their double spend does
not.

So, if they're well connected with miners, then basically they've jammed the
coinjoin.  And technically speaking, you may never see this pinning vector,
right, you may never see this double spend because there is no "the mempool".
Does that make sense?

**Mike Schmidt**: Yeah, that makes sense.  I wasn't aware of that potential use
case.

**Greg Sanders**: Yeah, so that's why wallet developers care.  There's software
people who care from a game theory perspective, but there's also software wallet
developer people who care for these kind of reasons.  It just complicates a lot
of this and it makes DoS easier.

**John Light**: I have a question.  So, Greg, you mentioned that there is debate
about whether or not this new setting on your node software gets into 24.0 or
not, and when to enable it as true.  And part of the reason might be just giving
people more time to adjust their services to this if they're relying on
zero-conf.  How long has this new node setting been a part of the discussion,
and are you aware of engagement from industry in the discussion?

**Greg Sanders**: Yeah, so I mean this has literally been, I don't know, a
ten-year discussion, or something, so it's hard to say when it started.

**John Light**: I guess now there's written code.

**Greg Sanders**: Exactly, right.  So, people are saying, okay, maybe default
true is too aggressive, or something.  Maybe we can get default false, and then
you'd have to have something like 10% of node operators turning it on or
basically sybiling the network, connecting to miners, to really make a
difference.  So, that was the thought.  And so, this very small patch that
included this flag was merged prior to 24.0, before the branch off from the
master branch.  And so that's why it's showing up in a release, right?  And so
what people did, like service people, then read these notes and said, "Oh no, we
think this feature's dangerous.  We need n months to fix things", or whatever
other metric.  So, that's kind of where the conversation went.

**John Light**: Okay, so at least some folks have noticed and are already
raising the question.

**Greg Sanders**: Yeah, and so there's debate.  It's made its point and people
are now aware that there's this intention, should we disable this option for
some window; or is disabling an option an anti-feature and too upsetting for
users?  There's a lot of questions here.  I don't think there's any right answer
per se, but the discussion's ongoing, and hopefully there's a resolution where
we all get the things we want in the end, but we have to figure out how to get
there.

**Mike Schmidt**: And I saw that there was a couple of proposals that would
involve potentially changes in the 24.0 release.

**Greg Sanders**: Yeah, so AJ is here, Anthony Towns is actually in the audience
here, but he has a --

**Mike Schmidt**: He's spying on us!

**Greg Sanders**: He's spying, that's right!  He has a proposal which a mainnet
turns off the flags.  You can't; if you set it to something, it's invalid.
Basically, mainnet, you can't set it, or it's not active until, like, let's say
six months in the future.  I think the current one is six months.  But the idea
is, delay it on mainnet and then switch it to default true at some time in the
future, when people think it's enough heads up.  So, is it six months; is it a
year?  This is the conversation happening right now in the mailing list with
different merchants talking about what are their metrics that they think are
appropriate.  And then a decision will have to be made one way or another for
24.0 and then for the future.

**Mike Schmidt**: Okay, so this is still being discussed.  Nothing has been
determined yet, but there's a few different proposals.  Okay, great.  I see
Murch has joined us.  Murch, essentially the co-host invite.  Anything else
noteworthy on this topic, Greg, you think, before we move on?

**Greg Sanders**: I mean, I think that gives you proper context.  We talked
about, a little bit about miner incentives, we talked about what wallet devs
want, and then the zero-conf operators, they have their own concerns.  And so,
if you're interested, I'd recommend reading, there's Sergej from Bitrefill and
Dario from Muun Wallet talking about their concerns.  So, I think it'd be better
to do justice if you read their emails.

**Mike Schmidt**: I have a question, a subjective question for you, Greg.  If
you could wave a magic wand on all of this RBF stuff, what would you have
happen?

**Greg Sanders**: If I was a dictator you mean?

**Mike Schmidt**: Yeah, dictator.

**Greg Sanders**: So, if I was the dictator, I'd probably push back the window
another six months.  I'd take AJ's PR, push it back six months, and then just
merge it and then get yelled at by devs.

**Mike Schmidt**: Okay, that's fair.

**Greg Sanders**: So, one operator was asking for six months and, well, I guess
I'd wait for operators to tell me how long they need, like discrete timelines,
right?  So, someone says they need a year, I would just bump it back to an
honest maximum of that range and then just merge.  But not a dictator, so…

**Mike Schmidt**: Murch, I see you've joined us.  Do you want to introduce
yourself really quickly for the audience, who probably already knows who you
are?

**Mark Erhardt**: Hi, I'm Murch and time zones work differently than I thought
this morning before getting coffee, with the wonderful doggo that my cousin has,
and sorry for being late!

_Validity rollups research_

**Mike Schmidt**: No problem.  We've kept it together.  I don't think we've gone
too far off the rails just yet.  We are going through the newsletter
sequentially, and we are about to roll into the validity rollups research from
John Light, who's here to help explain this mystical world that bitcoiners only
usually hear about in altcoin and DeFi land.  So, John, if you want to step up
to the plate, maybe one place to start is, is what you've researched here
zero-knowledge proofs?  Maybe you can give us a little context here on the
motivation and maybe the 101 for bitcoiners on zero-knowledge proofs.  I've
heard the example of Bitcoin signature proving you have knowledge of the private
key, being like the bitcoiners' way of thinking about zero-knowledge proof, and
maybe you just want to take some of that and run with it.

**John Light**: Sure, thanks.  So, zero-knowledge proofs were invented, like
computational zero-knowledge proofs were invented back in the 1980s.  And it's
basically a technique that allows you to prove the correctness of a statement
without actually revealing anything about the answer.  So, you're able to
convince somebody else, a verifier, that you know the answer, or that a
statement is true, without actually revealing any details about why it's true.
And that's quite powerful because the statement can be really arbitrarily
complex in terms of what exactly it is that you're proving true.  And there are
also ways to develop non-zero-knowledge computational proofs, which you might
reveal some information about the statement you're making or the information
backing the statement, but it's still a very small amount of information
relative to maybe the total size of the statement.

In a practical term, for the use case that we're talking about, validity
rollups, what you're able to use this type of computational proof, which is
called a validity proof, to do is to prove that a state transition on a
different blockchain is correct according to the rules of that blockchain.  And
you're able to prove that to Bitcoin full nodes without those Bitcoin full nodes
actually having to replay any of the transactions that are happening on this
other blockchain.  And what that gives you in terms of benefits, the reason why
you would want to do this, is twofold in the case of validity rollups.

One is that you're able to link confirmations on the rollup to confirmations on
Bitcoin.  So, if you're doing transactions in this other blockchain, which is
called a rollup, once a rollup block is produced containing those transactions,
the block producer then does a transaction on layer one saying, "This is a hash
of the new state of the blockchain according to this block that I just produced,
built on top of all of the previous blocks that have ever been produced, and
confirmed on layer 1", and then put a validity proof on layer one that convinces
layer one full nodes that indeed this hash of this state is a correct transition
from the previous known state.  And once that transaction, that state update
transaction gets confirmed on layer 1, the rollup block has just as much
finality as the layer 1 block itself.  So, this other blockchain, the rollup
blockchain, is actually fully inheriting the double-spend security guarantees of
layer 1 by putting the hash of the state and the validity proof that proves the
correct state transition, into that layer 1 transaction in a layer 1 block.  So,
that's one of the benefits of using the validity proof this way.

The second benefit is that because you're able to prove that the state
transitions are correct on this other blockchain, what you can actually do is
you can develop a script on layer 1, such that you can deposit bitcoin into this
script, and then it will be locked there until you're ready to withdraw it.  And
once you lock bitcoin in this script on layer 1, the layer 2 rollup blockchain
full nodes will see that some bitcoin has been deposited to this script, and
then issue an equivalent amount of bitcoin to maybe the same address or a
different address that was specified in the deposit on layer 1.  And now, the
recipient of those bitcoins can then do transactions within this other
blockchain, using the bitcoin that they kind of transferred into this script on
layer 1.

So, this kind of harkens back to this idea that's been floating around the
Bitcoin community for a long time, called sidechains, where the idea is you have
this so-called bridge or two-way peg where you can move bitcoins to another
blockchain and back.  And one of the problems that was kind of unsolved for many
years, since the first introduction of the sidechains idea is, okay, you can
move bitcoins into another blockchain.  That's not too difficult because you can
do SPV proofs, or maybe that other blockchain, their full nodes can just look at
the state of the layer 1 blockchain and they can see, "Okay, bitcoins have come
into this special script.  I'm going to issue an equivalent amount of bitcoins
on this other chain".

The real tricky bit is, how do you get the bitcoins back onto the main Bitcoin
blockchain when you want to withdraw from this other blockchain?  And this is
sometimes called a peg out.  And so the reason why this is a challenge is
because Bitcoin layer 1 full nodes don't know anything that's happening outside
of the blockchain.  Bitcoin's scripting language is not really advanced enough
to be able to even verify an SPV proof from a different blockchain, or something
like that, right now.  And so the way that this problem has been solved up until
now is basically using some fancy form of multisig, or even just a centralized
custodial bridge.  So, you give your bitcoins to this trusted third party or
trusted federation, and then they'll issue you some IOUs on a different
blockchain.  And then when you want to get the blockchains back or the bitcoins
back, you ask them, "Can you please send me the bitcoins back on layer 1?"

What validity rollups have introduced is this ability to have a totally
trustless cryptographic bridge between Bitcoin and another blockchain, so that
when you move your Bitcoin over to this other blockchain, you always have the
ability to exit and with your coins that you own.  And the reason is in part
because of the validity proof, also because some of the state of the blockchain,
or the state of this other blockchain is stored in layer 1 blocks for data
availability.  But really, it's the validity proof that's an absolutely
essential component here, because the validity proof is proving that state
transitions on this other blockchain are correct; I explained that earlier.  And
now when a user wants, because the layer 1 full nodes are validating that the
state transitions are correct, they can confirm that withdrawals are correct as
well.

So, when a user on the rollup, or who has bitcoins on the rollup, wants to
withdraw those bitcoins back to layer 1, they just submit a withdrawal
transaction, and either the rollup block producers are cooperative, and they
process the withdrawal transaction, include it in a block and then put it on
layer 1 and the user can get their bitcoins back; or in the uncooperative case,
the user can submit a transaction directly on layer 1 along with a validity
proof that shows like, "Hey, I own these bitcoins in the current last known
valid state of this other blockchain, I would like to withdraw these bitcoins to
my layer 1 address".  The layer 1 full nodes, when that withdrawal transaction
gets included in a bitcoin block, will just verify the validity proof, they'll
run it through their verifier software, and if it comes back true, then they
will process the withdrawal, and the user can get their bitcoins out of the
rollup.

So, that's how validity proofs are used in the rollup.  And to summarize, those
benefits that you're getting from that design are that this other blockchain,
the rollup blockchain, is able to fully inherit the double-spend security of the
parent chain.  In this case, it's the layer 1 Bitcoin blockchain.  And users who
move their bitcoins into this other blockchain have cryptographic guarantee that
they can get the bitcoins out of this other blockchain and back onto the layer 1
Bitcoin blockchain.

**Mike Schmidt**: Excellent description.  Thanks for walking us through that.  I
think you've used the term sidechain, but also rollup, and I know there was some
discussion about that.  Do you think of this as sidechain technology, or is
there an important distinction between what's commonly referred to as a
sidechain and what you're talking about here, other than the technical magic
that you've mentioned?

**John Light**: Yeah, that's a good question.  So, in some ways these look very
similar because a rollup is another blockchain that you can move your bitcoins
over to and back to Bitcoin, and that sounds a lot like the sidechain idea.  But
I think one of the important features or distinctions between these two
different types of protocols is that a rollup puts its state, like data about
its state, onto its parent chain.  This is a design requirement for something to
be considered a rollup.  Whereas, I consider a sidechain a totally separate
blockchain, that it could have its own consensus mechanism, it could have its
own throughput, it could have very big blocks or very small blocks.  It doesn't
really matter how this other blockchain is parameterized, as long as it has this
ability to move some asset back and forth with another blockchain, and maybe
uses that asset as its native asset that you would use to pay for fees.

So, for example, Liquid or Rootstock are sidechains that run today, and they
don't put any of their blockchain state data onto the main Bitcoin blockchain.
They're not fully inheriting the double-spend security of the layer 1 blockchain
the way that rollup does.  So, I think that those are kind of the main important
distinctions, and that a rollup, although it is a blockchain and it shares some
characteristics with sidechains in that you can move bitcoins over to them and
move them back, I think they're different enough that they merit having their
own category in the ontology of blockchain-based protocols.

**Mike Schmidt**: So, if I'm an end user and I'm thinking about the end effect,
I send my coins somewhere similar to a sidechain, I get the features of
something like a sidechain, maybe I can send a high throughput number of
transactions, or some such thing, and then when I'm done doing whatever I'm
doing on this sidechain, I can get my coins back.  And so, in that regard it's
similar, but it's different in that instead of, like I said in the Liquid
example, depositing into an address that's in essentially a giant multisig, I'm
depositing into -- I guess my coins are locked with a script that has the
ability to validate these proofs, such that in the worst case that a rollup, I
don't know what you call the people running the rollup, but if they don't
cooperatively give me my coins, that script has the ability for me to sort of
have an escape hatch and show the proof, because I guess there would be some
change to full nodes such that they can validate those proofs, then I would be
able to get my money out in the uncooperative case?

**John Light**: Yeah, exactly.  Your ownership security over your coins on a
rollup is equal to the ownership security that you have of coins on layer 1.  So
basically, as long as you can get a transaction on layer 1 confirmed, you can
get your bitcoins out.  The same way that, as long as you can get a bitcoin
confirmed on layer 1 today, you can move bitcoins from your layer 1 address to
some other layer 1 address.  So, I think that's a guarantee that no sidechain
design that I've ever seen provides in all cases.

**Mike Schmidt**: Murch?

**Mark Erhardt**: Yes, yeah exactly.  I was wondering, so in a way it sounds a
little more like an extension block, because it feels like a compression
mechanism, if you still need to track all the state transitions on the mainchain
and you also have to be aware of the rules of the sidechain in order to validate
the proof.  So, it might actually be a little related to extension blocks?

**John Light**: Yeah, that's a good point, or question.  So, the difference with
extension blocks is that somebody on layer 1 has to replay the transactions that
happen in an extension block.  Whether it's full nodes or miners, at the very
least, the miner who mines the block is replaying those transactions so that
they can ensure that those transactions are valid, and then be sure that full
nodes that do recognize the extension block aren't going to reject that block
for containing invalid transactions.

In the case of a rollup, there's a separate full node network and block producer
set that is actually receiving incoming rollup transactions, they're executing
those transactions against the current state and checking that they follow the
consensus rules, and then gathering those transactions into a block and
generating the validity proof and putting that data on the layer 1 chain.  So,
layer 1 full nodes and miners could, in theory, never replay, never need to or
see or replay those transactions themselves.  They just see the state data in
the block, they verify the validity proof, but they never actually have to
replay those transactions.  All of that happens in a separate layer, full node
network.

**Mark Erhardt**: So, what we would need change-wise on the mainchain side would
be the ability to evaluate these ZK proofs.  And other than that, if we got that
as a new opcode or whatever that is, that would be the only effect that we would
need on the mainframe side; is that right?

**John Light**: Not just that.  So, if you're designing this in a way that is
very similar to how Bitcoin works today, so you're not cheating and, say,
building an extension block with rules that are totally different than the way
that Bitcoin works today, in order to support this use case.  But Trey Del Bonis
has proposed using recursive covenants in combination with the validity proofs.
And what the recursive covenant gets you is the ability to basically ensure that
the UTXO or the script that the users are depositing their Bitcoin into, when
they want to deposit to the rollup, that when the next state update comes in for
the rollup, that the UTXOs stored in that script are always carried forward into
the next rollup script update.

So, with covenants, you're able to restrict what kind of script your outputs
from your spend transactions are being sent to.  And this would be used
recursively to ensure essentially likeness and the correct rollover of state
whenever there's a state update transaction that comes in sequentially,
block-by-block, as the rollup state progresses.  Does that make sense and answer
your question?

**Mark Erhardt**: Yeah, that makes sense.  So, we would need some sort of
introspection and we would need the ability to evaluate ZK proofs.  But if we
then still need to track the state transitions, how much of a compression do we
get out of that?

**John Light**: So, this depends on the implementation details of the rollup
that you're building.  I gave three different examples of different state models
that you could use, which would provide different levels of compression.  So, if
you move to an account-based model, similar to the way that Ethereum works,
where users have a single account and their account is simply debited whenever
you want to send money to another account, you could get transactions for simple
spend transactions down to like 12 bytes, because you would have 4 bytes that
represent the account number of the sender, 4 bytes that represent the account
number of the recipient, 2 bytes that would represent the amount, and some
change for other metadata about the transaction.  And so that's compared to 120
to 200 bytes for a similar, simple spend transaction.  So, that's like a 10X
difference.

But then if you apply the witness discount to that data, then you're talking
about a 12 weight unit transaction compared to a 561 weight unit mainchain, one
input, two output, P2WPKH transaction.  And 12 goes into 561, what's the math on
that?

**Mark Erhardt**: Yeah, more than 45, or so.

**John Light**: Yeah.

**Mark Erhardt**: Yeah, so roughly a 45 decrease and actually, having it all as
an account-based -- so, would this rollup basically always spend all of its
UTXOs into a single UTXO back?  So, it would sort of also, well, no, the
transitions are onchain.  It's not really privacy tech, is it?

**John Light**: Well, certainly with this account-based model, if anything, you
might be losing some privacy because you lose the ambiguity of change outputs.
But if you want to implement some new privacy protocol, like Zerocash or a
CryptoNote, or something like that, then that's going to make your transactions
bigger.  But you still get some scalability benefits in the sense that you're
able to leave the witnesses out of the rollup transaction data that actually
gets put on layer 1, and replace all of the witnesses of the rollup block with a
single validity proof.  And then you just amortize the cost of that validity
proof over all of the transactions that you can fit in the rollup block.

So, for normal UTXO transactions, what I estimated is that if you did that with
a 4 million weight unit block, you could fit about 26,000 transactions per block
for UTXO model one input, two output transactions; for the account model
transactions, you could fit 250,000 transactions in a block; and if you want to
do something fancy, like a Zerocash style rollup, then you could fit about 4,500
transactions in a block.  So, yeah, that kind of illustrates, I think, some of
the throughput benefits that you can get with these different compression
models.

**Mark Erhardt**: Cool, that's very interesting.

**Greg Sanders**: Can I ask a question?

**John Light**: Please.

**Greg Sanders**: This might be way too in the weeds, but when you say Zcash
style, does that include the data being onchain having to publish this
accumulator kind of spent UTXO set stuff?

**John Light**: Yeah, so that data per transaction is like a proof and then a
nullifier.  And the nullifier is essentially like the note, or it shows you that
a note is being spent and removes the note from the unspent.

**Greg Sanders**: I guess my question is, would the contract, so to speak, the
cluster of UTXOs in this covenant, be getting larger in the witness space, over
time, I mean, as there's more of these notes, or whatever? I'm just trying to
understand how this would all fit together.

**John Light**: Yeah, that's a good question.  I don't know the answer to that
question.  There is a Zerocash style roll up that has been built on Ethereum,
called Aztec.  I would have to look at how they're doing it, whether they --

**Greg Sanders**: Global state, I'm guessing.  All right, thank you.

**John Light**: Yeah, you're welcome.

**Mike Schmidt**: So, I mean the benefits sound interesting, the tech sounds
interesting, we touched a little bit on some of the mechanics.  What's the
downside, what are the unknowns, and what are the trade-offs here?

**John Light**: That's a good question.  And the answer, again, I would say
depends on the implementation details.  So, if you just had a rollup that worked
like Bitcoin, let's say, like the consensus rules were pretty much identical to
Bitcoin, and you even designed the soft fork that enables this rollup in such a
way that your Bitcoin, the actual byte size of a Bitcoin block is on average no
bigger than the biggest blocks that we've seen historically with Bitcoin today,
I think the record right now is 2.77 MB, then your trade-offs are basically nil,
you don't lose anything.  If anything, you gain, in the sense that if your
entire block is full of rollup transaction data and all the layer 1 full nodes
have to do is verify a single validity proof, that's going to be cheaper than
verifying 2.77 MB worth of today's Bitcoin transactions.  So, you get more
throughput and your layer 1 blocks become cheaper to verify.

Now, that's not the only way that you could build a rollup.  You could build a
rollup in such a way that you're taking full advantage of the full 4 million
weight units and you apply the segwit discount or the witness discount to all of
the rollup transaction data, so you're able to get close to 4 MB blocks, you get
that much more throughput.  But it's also going to take up more bandwidth and
more hard disk space because your blocks in bytes are bigger.  Your blocks still
might not get more expensive to verify, and they still actually might be cheaper
to verify, but it's going to cost you bandwidth and hard drive space.  And
that's for like a Bitcoin-style rollup.

You could also design your soft fork that enables validity rollups in such a way
that you support proofs of more complex statements than simple bitcoin
transactions, of complex smart contract logic or recursive proofs, or other
things like that, which could enable new types of transactions that you couldn't
even do on Bitcoin, such as the Zerocash style privacy transactions that we
talked about earlier, or maybe a Simplicity blockchain, so like a different
blockchain that supports the Simplicity smart contracting language, or really
any kind of blockchain that you could imagine.  You can turn that dial to make
your verification systems simpler or more powerful to determine how complex your
validity proofs that you want to be able to support would be, and therefore how
powerful of a blockchain you want to enable or not.

Of course, different blockchains with different capabilities could add maybe
various new types of incentive models to Bitcoin.  If you can enable MEV, Miner
Extractable Value, or algorithmic incentive manipulation style contracts
directly on Bitcoin, that could change how miner incentives work today, which
some people are cautious about, rightfully so, I would say.  So, I would say
that that's, yeah, I'll leave it at that in terms of the costs and trade-offs.
I see Murch has his hand up.  Go ahead, Murch.

**Mark Erhardt**: Yeah, I think, to be fair, we also have to talk a little bit
about the new components that we would have to have to evaluate and integrate
those, the second layer.  So, we would need to be able to parse ZK proofs, which
we currently can't, and that would be a new cryptographic primitive that we
don't support yet so far.  And then for these, depending on what we exactly want
to do with the sidechain, we would also need different support for the things
there, like if we do the Zcash style outputs, we would of course be able to
parse that.  So, I think those complexity trade-offs and new cryptographic
primitives would also need to be factored into the trade-offs.

**John Light**: Well, to clarify, layer 1 would only need to know how to verify
the validity proof and to store the transaction data from the rollup; and then,
of course, to have a way of carrying the state of the rollup forward, which you
could do with recursive covenants.  They don't need to, say, know how to speak
Simplicity if it's a Simplicity rollup, or to really know how to execute those
Zerocash style transactions if it's a Zerocash rollup.  All they have to do is
just know how to verify the validity proof that proves the correctness of the
rollup block.

**Mark Erhardt**: Thanks for the clarification.  That's fair, but I'm just
trying to point out how there was a huge debate earlier this year already about
non-recursive covenants, and then this might be even more of a debate, is what
I'm trying to get at.

**John Light**: Oh, yeah.  No, that's also totally fair.  I was mainly thinking
about the rollups, but also talking about, yeah, the actual effort and debate
required to get validity proofs in and recursive covenants, or whatever else
could be used to carry that state forward.  Yeah, that's a that's an effort unto
itself as well.  Thank you.

**Mike Schmidt**: John, any call to action for the listeners here?  Do you want
people to go through your paper, provide feedback, discuss on the mailing list?
Is there something to play around with?  What can folks do?

**John Light**: Yeah, so I would say all of the above.  Definitely check out the
paper if you hadn't had a chance to read it yet.  I'm totally open to feedback,
my DMs are open.  If you want to have a discussion publicly, there's a thread on
the mailing list.  And there's no software to play with yet for Bitcoin.  There
have been validity rollups built on other blockchains, if you want to take a
look at how those work.  But in terms of something on Bitcoin, there's nothing
on Bitcoin yet, but I would say if anybody is interested in actually working on
this and maybe making some changes to a fork of Bitcoin on testnet, or something
like that, or maybe looking at Elements or some other software like that, where
we could experiment with some of these ideas, get in touch and maybe we can get
a little working group together or something to experiment with these ideas in a
Bitcoin context.

**Mike Schmidt**: Excellent.  Thanks for joining us, John.  You're welcome to
stay on.  I think there may be a news item, or one of the items later that you
can opine on.  And you're obviously free to opine on any of the things we're
discussing and hang out, but if you've got to go, we understand as well.

**John Light**: Yeah, thanks.  I'll hang out here, and if anyone has questions
later, I don't know if you do audience questions, but I'll hang out.

_MuSig2 security vulnerability_

**Mike Schmidt**: Okay, great.  Getting back to the newsletter, Murch, since you
were late today, maybe you can explain the intricacies of the MuSig2 security
vulnerability for everyone.

**Mark Erhardt**: Gee, thanks.

**Mike Schmidt**: I'm kidding!  I don't think we need to get into that.

**Mark Erhardt**: Honestly, I don't know, I was very deluded before coffee this
morning and after traveling last night, and I actually thought we're starting at
12.00 and I had two more hours to read, so I got coffee first.  So, I got just
got coffee and I didn't read yet!  So, I guess I only got the cliff notes on
this one, but my understanding is that -- actually, do you have it?

**Mike Schmidt**: It almost feels out of scope to dive into the details of this
on this chat, to be honest, but I do think it would be maybe informative for
folks if we just give a quick overview of MuSig, and maybe I can take a crack at
that and you can maybe supplement.

**Mark Erhardt**: I mean MuSig, sure.  So, MuSig is just a protocol with which
multiple participants can craft a shared signature together.  And the problem
with that is that if too much information is known to the counterparty, the
counterparty can construct a partial signature in a way that it cancels out the
other party's key, and then basically make the signature unilaterally after it
gets a -- it can sort of force the other party into signing over the decision to
itself.  And from what I understand on this security vulnerability that Jonas
Nick posted about, it's that if you know the public key and the tweak, you can
sort of have a cancellation attack constructed; and usually, hopefully, you
would not know the xpub and you would also not know the tweak before, because
people commit to the tweak, I think, with a secret commitment.  Anyway, along
those lines, there's a new security vulnerability and the spec is being updated
to address this.

**Mike Schmidt**: Yeah, and if you're sort of thinking about the taxonomy of
where MuSig, or I guess MuSig2 fits into all this, there's the traditional
multisig using Bitcoin script, where you have sort of a 5-of-7, or some sort of
arbitrary numbers there of signers; then you have multisignature, of which MuSig
and its ilk are sort of under this multisignature taxonomy, which is an
indistinguishable single signature that represents m-of-m, so all of the signers
in the quorum are signing, which is different than from threshold signatures, in
which you have a single signature, but you can have a subset of signers.

So, within multisignature, you then have the three different MuSig proposals.
So, there's MuSig1, MuSig2, and then MuSig-DN.  And we're talking about MuSig2
and one of the bugs found, or potential attack vectors, I guess you should say,
in MuSig2.  So, look at the Optech website, there's some topics on MuSig and
threshold signatures and multisignature to kind of try to put this in your
brain.  And then if you're curious about the details, there's the mailing list
post that you can drill into from the newsletter, to understand the specific
vulnerability.

_Minimum relayable transaction size_

Next item, minimum relayable transaction size, which was prompted by a mailing
list post from Greg Sanders, who hopefully is still able to hang on with us even
though we're going over our usual hour a lot.

**Greg Sanders**: Still here.

**Mike Schmidt**: Okay, great.  So, Greg, you want to decrease the minimum
relayable transaction size, but I guess maybe we could start, why is there even
a minimum reliable transaction size in the first place?

**Greg Sanders**: Right.  So, a number of years ago, there was a standardness
restriction that the justification was something like, it's a small transaction,
it's probably not real, it's probably spam, and it makes allocations on the heap
slower, or something like that.  But once it was revealed, it was actually a
standardness, belt-and-suspenders, to avoid a specific issue with SPV proofs.
Where a transaction is exactly 64 bytes in non-witness serialization, meaning
the way it's serialized a certain way, it's 64 bytes exactly, that it could look
like an inner node in the SPV proof.  So, there's these merkle proofs, and
basically an adversary might be able to trick, make a weird tree where it looks
like this is an inner node, but it's actually a transaction, and this could make
false proofs.

So later, this is revealed, and people know about it now, but there was still
old code there, old comments, and I was going in there poking and changing it,
and in the end, basically, the constant size they picked was something like one
input and one output to a P2WPKH, and there's actually use cases that I've heard
from a few people that would make it smaller than that.  So, basically, it's
reducing this restriction to 65 bytes and above, instead of 85.  So, this opens
up a few use cases.

**Mike Schmidt**: Okay, and that 85 was somewhat arbitrarily chosen not to be
exactly 65, as to give away the attack vector?

**Greg Sanders**: Yeah, exactly.  It's going to the smallest one output that's
the smallest secure output, right?  But there are circumstances where you don't
want it to be secure, like I want to toss this all the fees for a CPFP.  And in
that case, you weren't allowed to do it without padding, like an OP_RETURN with
a bunch of bytes.  So, 65 means I think you'd have to pad 4 or 5 bytes; I'd have
to look at the PR tests and stuff.

**Mark Erhardt**: But yeah, looking at the 85, I think P2WPKH would have 68
bytes plus 42 weight units for the metadata, and then 8 bytes for the amount
plus 1 byte for an OP_RETURN would be something like 87.  So, it would just be
allowed to do an output that is an OP_RETURN and just gives away all the money
in the output.

**Mike Schmidt**: Greg, I think you alluded to it, but what is it that you can
do in that 65- to 85-byte range that you can't do now, that you're trying to do?

**Greg Sanders**: So actually, the optimal would be 61 bytes, and this would be
where, remember this is non-witness serialization.  So, the input could be a
P2WSH, P2WPKH, anything like that, but these witness spikes don't contribute to
that size check.  And then the output, you could burn it directly to fees.  So,
in Bitcoin consensus, you must have one output, you can't have zero outputs,
which is not great, but that's the world we live in.  So, the optimal thing
would be to include a single output, an OP_RETURN, that then burns all the rest
of the coins to fees, right?  Let's say it's too small for a change output, like
you would toss it normally, so you just want to toss it to fees.  So, how do you
do this?  Right now you have to do an OP_RETURN with like 21 padding bytes, or
something like that, for no reason, so you're scribbling on the blockchain for
no reason.  And the two options were to make 64 bytes exactly illegal or make 64
and below illegal, by policy not consensus.

So, BlueMatt previously had done a software proposal which made 64 and below
consensus valid, so I kind of just picked that number as a thing that's been
discussed before, but do it for policy only.

**Mike Schmidt**: Okay, great.  Murch, any questions?

**Mark Erhardt**: Maybe you could mention one of the use cases why you would
want to ever create 61-byte transactions.  I think that was part of our news
items last week already, but just to remind people.

**Greg Sanders**: You want me to state it?  Yeah, so it would be the case where
you have, let's say in a Lightning transaction of some format, where you have an
output that's pretty small, and you want to do a CPFP with that, you want to
sweep it to do a CPFP, but the value isn't big enough to make another output.
Today, you'd have to make an uneconomical output, which may not even be relayed
if it's considered dust.  So, this is like a corner case pretty much, where
you're allowed to burn out all the fees.

**Mark Erhardt**: All right, thanks.

_BIP324 update_

**Mike Schmidt**: All right, next item on the newsletter was BIP324 update, and
that was prompted by a mailing list post from Dhruv, in which he goes over a
bunch of updates to the BIP proposal for encrypted P2P transport, and there's a
bunch of interesting resources to review, there's a whole website and a guide to
the proposed changes, this is pretty cool.  At a basic overview, I guess the
tl;dr is that instead of traffic between peers being completely plain text,
you'd have the option to encrypt that traffic between yourself and your peers,
which can help in a few different use cases, from privacy perspective and
tampering.  I think it's all around a net win.  I was fortunate enough to be
able to sit in on Pieter Wuille and Tim Ruffing's presentation in walking
through the BIP, and there's quite a bit of impressive engineering behind that.
Murch, do you have comments on the content of BIP324 as a whole, as well as the
specific update that Dhruv is outlining in the mailing list?

**Mark Erhardt**: Yeah, sure.  BIP324 picks up the idea again to make a new
version for the whole protocol communication, and that's a fairly old proposal.
I think it was originally proposed by Jonas Schnelli, I want to say five to
seven years ago.  And so there's just a few little inefficiencies here and there
and actually, even though we want to encrypt all the data pushed around on the
network in the version 2, it would be smaller, it would be an efficiency
improvement for bandwidth usage, a very small, slight bandwidth improvement, and
it generally just makes the cost of being a passive attacker and observer on the
network more expensive; because when everything is encrypted but not
authenticated, you can still listen in on all the traffic but you have to
actually run Bitcoin software in order to parse what's going on.

Currently, every ISP and every node that forwards internet traffic would be able
to see exactly that people are posting Bitcoin traffic, and what exactly they
are transferring; but with this encrypted layer, instead it would have to be
decrypted first in order to be read.  So, a passive attacker would at least need
to do all of that.

**Mike Schmidt**: Yeah, it seems great.  I think that's it for our news section
this week.  Quite a beefy one.  It took us through an hour-and-a-half and we've
still got quite a few items in the newsletter.  So, moving on to Changes to
services and client software.  This is a monthly segment that we put in the
newsletter in which we highlight things that we think are interesting to the
Optech audience, whether that's scaling or other Bitcoin-technology-related of
services or open source software adopting certain technology.

_btcd v0.23.2 released_

The first one here is BTCD, and they had a v23.2 release.  I think most of these
changes that we outlined in the newsletter were actually in the v.23.1 release,
but includes support for addr v2, additional support for PSBTs, some additional
taproot support, I saw some there's some MuSig tooling in there as well, and
then a bunch of other enhancements and fixes.  So, for those not familiar, BTCD
is another Bitcoin full node implementation separate from Bitcoin Core that
implements the Bitcoin protocol.  I'm not sure exactly what the --

**Mark Erhardt**: It's a Go implementation and it's, for example, used by LND.
So, this is actually the -- I think 0.23.2 release would be the one that fixes
the block parsing issue that caused the LND nodes to stall last week.

_ZEBEDEE announces hosted channel libraries_

**Mike Schmidt**: That's right.  The second item is ZEBEDEE announcing a bunch
of open source software around hosted channels, and we link to the blog post for
more information.  But essentially, ZEBEDEE has announced NBD, which is an
organization that's furthering open-source development, and as part of that
announcement, they have four different libraries that they've announced.  One is
a wallet called Open Bitcoin Wallet, a CLN plugin called Poncho, a Lightning
client called Cliché, and a Lightning library, which I think has existed before,
but Immortan.  And the focus of these libraries are all Lightning-focused, and
especially around this idea of hosted channels, which has a strong use case in
onboarding new users to Lightning.  So, instead of new Lightning users having to
open up their own channel, there's these hosted channels which are somewhat
trusted, but provide a better user experience, that are quite popular with
Lightning Wallet software.  Murch, any thoughts on hosted channels?

**Mark Erhardt**: Yeah, I think hosted channels is just a sort of subspecies of
turbo channels.  So, usually when you open a channel, you have to negotiate with
the counterparty and it takes then a few confirmations until both counterparties
are happy with the state of the channel being locked in and then forwarding
payments on it.  With turbo channel, the idea is because you are interacting
with a Lightning Service Provider (LSP), the LSP opens a channel to you and they
trust you with a little bit of credit so that you can immediately receive
payments or immediately send payments on the channel.  And I think this ties
well into the business model of ZEBEDEE, which is focused on Lightning-infused
gaming, so that they can have a smooth experience for new users onboarding.

_Cashu launches with Lightning support_

**Mike Schmidt**: Next item is Cashu, Cashu launches with lightning support.
So, I think we covered actually Fedimint, which is another E-cash software, in a
previous newsletter.  And so, Cashu is in that realm, although not necessarily
exactly the same type of software, and it's launching as a proof-of-concept
wallet.  And right now, they have the ability to receive via Lightning, although
last I checked, there's not the ability to send out of that.  So, this is still
very beta-type software playing around with proof of concept.  So, it looked
pretty cool.  I thought it was worth surfacing to the community.

**Mark Erhardt**: Well, from what I gathered, they're mostly pushing around tens
of satoshis right now.  But the really fun thing about this is, this makes use
of a concept called Chaumian E-cash, which we talked about in the context of
Fedimint already.  And Chaumian E-cash was introduced by David Chaum, I think in
the 1980s, and there was a business built around that in the early 1990s,
DigiCash.  And the idea is basically, I give people tokens that they can spend
for a specific amount of E-cash and I can then tell, as the service provider,
whether that token has been spent before, but I do not distinguish the tokens by
themselves.  So, they're all single use, but I don't know who is using the
money.

So, the users of the E-cash system, they basically just hand over the token to
another recipient, sort of like cash, P2P, and then the new recipient phones
into the central server and says, "Hey, I would like to reissue this token in a
new proof", and then service provider says, "Sure, here's a new proof for the
same amount", and the old one is burned.  So now, the recipient at that point
has unilateral control over the money, and they can then in turn give it to
somebody else.  But the service provider guarantees that there is no additional
cash produced, so the token amount is not inflatable, at least I mean the
central party can give out more, but the users cannot create more money, and it
is extremely private from the user side.  The big downside of the system is that
you have to fully trust the counterparty, the central service provider, with
keeping the amount of money fixed.

We talked about Fedimint in this context, where the central party is a
federation, and you would basically only need to trust some of the federated
members that they are not colluding against you.  And Cashu, I think, is more
centralized, but it might take the place of something like Coinbase, where
Coinbase wants to allow you to pay user-to-user, without learning who is paying
whom.  Well okay, maybe in the case of Coinbase, that is not actually what they
want, but you could do something like Coinbase without collecting the usage
patterns of your users.  So, yeah, it sounds fun.  I think it's still very
experimental and I don't know how deeply it's been vetted by other parties, but
just for playing around it sounds pretty fun.  And yeah, keep it to the tens of
satoshis for the moment, maybe.

**Mike Schmidt**: Cool.

**Mark Erhardt**: Actually, we have the author here too, if I see that right.
So, Calle, if you have a moment and want to talk about it, too?

**Mike Schmidt**: I invited Calle, but...

**Mark Erhardt**: Well, okay, we'll see.

_Address explorer Spiral launches_

**Mike Schmidt**: Nothing yet.  Okay, next one on our list of client service
updates is a new address explorer, Spiral.  Spiral not affiliated with Block or
any of the -- Oh, I think Calle --  yeah, we can.

**Callebtc**: I'm cooking right now, so I hope that the noise in the background
doesn't disturb you, but thanks for mentioning Cashu.  I just wanted to add,
sending out funds via Lightning has been working for a couple of weeks already.
So, in the very first version, you could only receive funds; that was obviously
kind of a joke because it's a one-way street, but sending out payments via
Lightning has been working so far.  And just to add on that very quickly, the
medium-term goal of Cashu is to become kind of a library that you can include
into your custodial services yourself.  As Murch said before, the idea is kind
of to make existing custodians or maybe new custodians in the future adopt
Chaumian E-cash instead of ledger-based, fully transparent systems.

**Mike Schmidt**: That's a worthy goal.  I hope some of these entities take you
up on that.

**Mark Erhardt**: Yeah, thanks for jumping in.

**Mike Schmidt**: So, yeah, I was saying about Spiral, the address explorer is
not affiliated with Block or that organization, it just happens to have the same
name.  So typically, if you're going to, let's say, Blockstream.info or the
mempool transaction explorer, address explorer, there's some information that
you're giving up when you're making a request and you're making queries of them.
And Spiral is an open-source address explorer that lets you put in an address,
and it's using some cryptography to provide privacy to the end user who's
looking up that address information.  So, there's some cool cryptography there.
It's not a full block explorer as we're used to, but it is a private way to look
up address information.  Did you check that out at all, Murch?

**Mark Erhardt**: I have not yet, really, but it sounds pretty fun because one
of the problems that we have with block explorers currently is some of them are
actually run by Chainalysis and other companies like that.  So, when you put in
your request to look up information, they probably remember what IP address made
that request and things like that.  And if you use it a lot, you might have a
bit of a footprint there that they associate with your IP address.  So, being
able to look something up without revealing to the service what you looked up
sounds like a pretty interesting goal.  I'm curious, though, how they would
prove that to you, because you're still just looking at a website.  And if they
run the website in the background, how do you know that they are running the
code that they claim to run?  But it sounds definitely very interesting.

_BitGo announces Lightning support_

**Mike Schmidt**: Next item here is, BitGo announces Lightning support.  So,
there's a blog post here in which BitGo goes through the features that they're
providing.  They're custodial clients, this is a custodial Lightning solution,
so BitGo is running the nodes, BitGo is maintaining the liquidity of the
channels.  And so, it's convenient in that regard, but it's definitely
custodial.  Murch, any comments from your alma mater here?

**Mark Erhardt**: Well, BitGo is a custodian already, so if you have custody
already, isn't it kind of neat if you can just make Lightning payments and they
account for it on their end, and you basically get access to Lightning through
the same interface you're already integrated with and you can spend whatever
money you have in custody?  That seems like a pretty big benefit to me.  And I
could see, given that BitGo has some hundreds of exchanges as their customers,
that it might pave the way for some simple Lightning integrations for exchanges
and things like that.  And if a lot of services take them up on that offer, it
would have a lot of liquidity.  Maybe it would be really useful for arbitrage
and things like that.

_ZeroSync project launches_

**Mike Schmidt**: Yeah, it's always good to see Lightning adoption.  Last item
here on the client service updates is ZeroSync project launching.  And I didn't
get a chance to try this myself, but the ZeroSync project is working to use
utreexo and STARK proofs to sync a Bitcoin node, similar to what you might do
when you're doing Initial Block Download (IBD).  So, I didn't see any figures
about how fast this is or could be, but this could drastically speed up the IBD
process if you're willing to trust these technologies.  Like I said, I haven't
tried it.  I don't know if there's any benchmark metrics out, I hadn't seen any,
but it seemed like an interesting effort.

**Mark Erhardt**: I'm not super-familiar with this approach exactly, but the IBD
is definitely one of the most harrowing parts of the user experience.  You just
download Bitcoin, and you want to start using the wallet that is packaged, and
then wait.  I have to wait like eight hours for the node to sync up with the
blockchain; that sucks.  And by the time the person that finishes up, they
either have downloaded another wallet already or maybe they've moved on and lost
interest.  So, having a way of quickly getting some state update and maybe
having SPV-like assurances in your Bitcoin Core wallet early on, and then in the
background syncing in full or even having a zero-knowledge proof that you have
synced correctly, could enable us to really quickly onboard people and then
perhaps also allow us to make much bigger blocks eventually, if we don't have to
have everybody download and process all of them in advance.

So, one of the goals, I think, that is packaged with utreexo is, instead of
everybody keeping the whole state of the UTXO set, every user would just keep
proofs for their own UTXOs, and when they want to spend them, prove that they
exist and haven't been spent.  And of course, if everybody only needs to keep
track of their own money and then be able to prove that the money exists, that
would introduce some scalability benefits potentially.

_Bitcoin Core 24.0 RC2_

**Mike Schmidt**: Moving on to Releases and release candidates, the big one here
is Bitcoin Core 24.0 RC2 is out.  Since we last spoke, we've been shilling folks
to jump into the testing guide to test RC1.  And if you've done that and you've
found some enjoyment there, maybe you want to jump in and also attempt to do
some testing on RC2.  You got anything there, Murch?

**Mark Erhardt**: I think we're sort of scheduled for RC3 already.  I heard
about another bug being found and with the mempoolfullrbf discussion ongoing,
I'm getting the impression that people are starting to consider whether or not
something needs to be patched there.  But we do need more testing, obviously,
because we still found another bug.  So, please do play around, try fancy stuff,
try all the things that you are interested in and want to work.  Yeah, and let
us know if you find anything suspicious.

_LND 0.15.3-beta_

**Mike Schmidt**: The LND release is just a minor release with some bug fixes
that I don't think is worth getting into now, especially at the 90-minute mark.

_Bitcoin Core #23549_

In terms of Notable code and documentation changes, there's a couple of Bitcoin
Core PRs that have been merged.  There's #23549, which is adding scanblocks RPC
that identifies relevant blocks in a given range for a set of descriptors.  And
that RPC is only available if you enable compact block filtering with the
compact -blockfilterindex flag.

**Mark Erhardt**: So, this one's interesting because if you're running a pruning
node, you actually throw away blockchain data that you've already processed.
And if you then add a descriptor, especially import an old descriptor that has a
birth date that precedes the latest block that you still keep, you actually
would have to, in the current paradigm, completely rescan the blockchain, which
means completely re-downloading and reprocessing the blockchain on a pruned
node.  And compact block filters have been around for a while now, I think two
releases that it's been formally enabled on Bitcoin Core.  And so if other nodes
keep these compact blocks, or you have indirectly access to one of those nodes,
you can just say, "Hey, with this descriptors, can I scan the compact blocks and
see whether any of those older blocks have data relevant to my node?"  And then
instead of parsing the whole blockchain, just download the nodes that contain
interesting data.

So, you would find your own transactions and your own UTXOs again without
processing the whole blockchain, but just the whole chain of compact blocks in
the range.

**Mike Schmidt**: Yeah, super-useful as somebody who's been the victim of having
to do the rescan before.  It seems like a great usability improvement there.

_Bitcoin Core #25412_

Bitcoin Core #25412 has a new /deploymentinfo REST endpoint, and that contains
information about soft fork deployments, and it's basically just the same thing
as the getdeploymentinfo RPC, so it's just a REST endpoint for that.  Nothing
too exciting there.

_LND #6956_

LND #6956, this harkens back to some of our previous discussions in other
newsletters about this notion of the minimum channel reserve, and so I think it
was maybe CLN last that we covered the channel reserve.  Murch, do you want to
explain why we have a channel reserve and the 1%?

**Mark Erhardt**: Sure.  So, in the update mechanism that the LN uses, we need
to have the counterparty keep a minimum of money so that we have something to
punish them with.  We use the mode, LN-penalty, and what it does is we ensure
that each of us will only ever use the latest state of the channel when they
broadcast to unilaterally close the channel, because otherwise we're going to be
able to take all of their money from any false state that they broadcast.  And
with this reduction of the minimum channel balance, you can allow the
counterparty to completely empty their side.

So, for example, if you are an LSP and your client is a mobile wallet and they
want to close their account, you might want to allow them to completely spend
their Lightning balance on the LN instead of closing it out as a channel
closure.  And that's what you can do with this new change.

**Mike Schmidt**: Not recommended to set that to zero if you're not sure what
you're doing, or who your channel partner is.

_LND #7004_

LND #7004.  This is essentially the update to LND that we talked about before,
that changes the version of the BTCD library used by LND, and thus fixing the
vulnerability that we discussed earlier in the newsletter and last year as well,
or last week as well.

_LDK #1625_

And our last item for today is LDK #1625, and this is a change to the LDK that
adds the ability to track liquidity of distant channels, and the purpose of that
is if you can keep track of some size of payments that have either been routed
through, which have failed or succeeded due to insufficient funds, you can use
that information as an input for pathfinding in the future.  So, it's an
additional data collection mechanism to facilitate better pathfinding.  Any
comments there, Murch?

**Mark Erhardt**: I mean, maybe we can say a couple of things here, yes.  One
is, of course, if you want to make a payment for a sizable amount, and you've
already tried channels before, and they've basically told you they can't route
that much, keeping track of that information and not trying that channel again
soon after is of course a benefit, because then you will have more success in
routing attempts because you avoid routes that are highly unlikely to be able to
facilitate your payment.  On the other hand, we have now multiple different
approaches on how we facilitate routing.  There is the Pickhardt Payments, which
sort of probabilistically model where the balance in each channel is probably
going to be, and try to find the path that has a high probability of having
sufficient funds; there are some approaches that only model the fees and try to
find the route with the lowest fees to forward the payment; and this seems like
a third approach now, where you actually just try to learn from experience what
worked and didn't work in the past, and then informed your attempts that way.

**Mike Schmidt**: All right, 96 minutes in, we did it.  I did not open up the
floor for questions during the Notable code and documentation changes' section,
so maybe we'll give folks just a quick minute to raise your hand, or request
speaker access if you have questions, before we wrap up.

**Mark Erhardt**: Yeah, this was probably our longest recap so far, right?  And
I also let you do the first third of it by yourself!

**Mike Schmidt**: That was good.  Luckily, we had some guests that helped
prevent me being the one just reading the newsletter.  It doesn't look like
anyone's requesting speaker access, so I guess we could wrap it here.

**Mark Erhardt**: Thank you everyone for jumping in and helping out with your
expertise, and I hope you enjoyed our very meaty newsletter this week, and I'll
hear you next week.

**Mike Schmidt**: Yeah, John, Greg, thanks for joining, guys, thanks for
opining.  I think it was very informative and I appreciate you guys taking the
time.

**John Light**: Yeah, thanks for the invite and thanks again for hosting and
putting this on.

**Mike Schmidt**: Cheers, bye.

{% include references.md %}
