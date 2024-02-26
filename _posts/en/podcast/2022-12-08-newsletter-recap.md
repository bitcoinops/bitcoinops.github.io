---
title: 'Bitcoin Optech Newsletter #229 Recap Podcast'
permalink: /en/podcast/2022/12/08/
reference: /en/newsletters/2022/12/07/
name: 2022-12-08-recap
slug: 2022-12-08-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Greg Sanders and Larry Ruane to discuss [Newsletter #229]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-6-26/340781356-22050-1-b4b2cda023d74.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome, everybody.  Thanks for joining us for Bitcoin Optech
Newsletter #229, Audio Recap on Twitter Spaces.  I am Mike Schmidt, a
contributor at Optech and also Executive Director at Brink, where we fund
open-source Bitcoin developers and folks working on good Bitcoin software.
Murch, do you want to introduce yourself?

**Mark Erhardt**: Hi, I'm Murch, I work in the Bitcoin space on education and
code contributions, and I'm employed by Chaincode Labs.

**Mike Schmidt**: And we also have two guests today.  The first one, instagibbs,
you want to introduce yourself?

**Greg Sanders**: Sure.  My name is Greg, or instagibbs.  I'm working at
Blockstream, currently Core Lightning, working on mempool policy as well and
eltoo channel constructions.

**Mike Schmidt**: And a repeat guest, thank you for joining us again.  Larry,
you want to introduce yourself real quick?

**Larry Ruane**: Hi, yes, I'm Larry Ruane, and I'm one of the somewhat newer
Bitcoin Core developers.  And I've been pretty active in Review Club and in
helping out with some of the Optech newsletter, the section on the Review Club
that we have every month.

**Mike Schmidt**: Excellent, well thank you, Larry, and thank you, Greg, for
joining us.  I shared a few different tweets that link to the newsletter
material that we're covering today and we'll just be going through that in
order.  Murch, I didn't prepare any announcements.  I don't know if there's
anything on your radar that you wanted to announce before we jump into the
newsletter?

**Mark Erhardt**: No.  Well, there's one conference in Mexico City starting
tomorrow.  I think the Ghana Conference ended last week, so probably smooth
sailing until January.

_Ephemeral anchors implementation_

**Mike Schmidt**: Right on.  Okay, we'll jump into it then.  Our first and only
news item this week for Newsletter #229 is titled Ephemeral anchors
implementation.  And so, if you've been following along the last many weeks,
we've covered I think this idea from the time that v3 was proposed, and I think
there was some with some ideation of this concept, and now through this
implementation.  And perhaps, Greg, you can give an overview of maybe how we got
to where we are today and what is the status of this implementation, and what's
any feedback then or challenges that you've run into.

**Greg Sanders**: Sure, I'll do my best Gloria impersonation right now.  So
basically, this work builds on a number of people's other work.  So, this is
dealing with mempool policy, which is how nodes decide what transactions get
into the mempool or don't.  It's not as simple as you think because there's kind
of these competing users.  You have the node runners, who don't want to get
crashed, out-of-memoried, CPU exhaustion, that kind of thing, so you have the
DoS part, and anti-DoS part.  But you also have wallets, right?  Wallets are
trying to get transactions into the mempool so they can get into blocks and
mined and confirmed.

So, what this work had been looking at is what we call the mempool pinning
aspect, which is basically how you could be stopped from bidding a feerate to
get into a block.  So, let's say there's a going feerate of like 10 satoshis per
vbyte (sats/vbyte).  There are situations, due to the complexity of mempool,
where you could make your transaction that high of a feerate, but not be
included.  You might need to add double that amount or triple, things like that.
And that's one style, one way of describing mempool pinning.  So, basically we
want to make a more robust interface for wallets.  We want to make these
policies that don't crash nodes, but also allow wallets to bid proper feerates
to get into blocks.

The first foray into this work is Gloria's v3 proposal, which I now kind of call
an RBF carve out; I'll explain why.  So basically, v3 is you mark your
transaction as nVersion3 and this basically opts into a new mempool policy,
where their transaction package can only be of size 2 instead of like 25, which
is the default today.  So basically, you have a parent and a child and the
parent can be any size, so it's basically the same rules as before, but then the
child, it can only be one child, and this child must be pretty small.  So, the
current number is like 1 per 1,000 vbytes (1/kvB).  This allows someone to make
a transaction package opting into this where it's much easier to RBF that
transaction package.

So, if it's a pre-signed transaction, like for example a Lightning channel
commitment transaction, if it was v3, then it makes it easy for each
counterparty to bid against the other person and RBF that transaction package.
It minimizes the pinning, because the pinning vector in v2 or v1 transactions
would be something like, your counterparty puts the commitment transaction
onchain and immediately spends it with a huge low feerate transaction, which is
not competitive to get mined.  And that means this commitment transaction will
sit in the mempool for a very long time and you can't RBF it because you're
paying basically, you have to replace the total fee of that package, but it's
not worth it for you, even though it's not going to be mined.  It's going to sit
there forever, and then you get basically money stolen from you.  So, this is
the RBF part.

So, this leads to ephemeral anchors, where basically I also call this now a kind
of a CPFP carve out.  Actually let me stop right here.  Questions at this point,
because there's a lot going on?

**Mark Erhardt**: I think you're good so far.

**Mike Schmidt**: Nothing from me, yeah, go ahead.

**Greg Sanders**: Okay, all right, so just a lot of review.  So, ephemeral
anchors is this idea where, okay, without this, if we just had v3, this is good
and a very good improvement, and we can improve things like commitment
transactions, splicing, there's a lot of things that can improve by this.  But
there's a few kind of nagging points here.  One is that, let's go back to the
Lightning channel construction, because that's what everyone knows or is more
familiar with.  If we did v3, we'd basically still have to do things like every
output that we don't want immediately spent, we have to put a one-block relative
timelock in the script.  So that means, like in a splice for example, if you
want to do a CPFP for a splice, that you'd have to lock up all the outputs
except for the anchor output.  The anchor is the one you want to spend.

So there's already anchors today in commitment transactions, but there can only
be one or two, which is kind of a… but in a v3 world, there'd be one anchor,
because if you have multiple anchors, then basically since you can only have one
child, if your counterparty gets to the mempool first and publishes their one
child, basically you won't be able to double-spend that, you can't bump that
out.  So basically, every other output has to be one-block timelocked, except
for the anchor.  And then, yes, that's actually the core of it right there.

**Mark Erhardt**: So again, maybe let me jump in here.  If you have the two
anchor outputs which is necessary if they are asymmetric, then (a) one problem
is that you still have to replace at least two transactions I think, because --
so, this is the case where each commitment transaction has a separate anchor and
you want to replace the other party's commitment transaction and also bump that
transaction with an anchor output.

**Greg Sanders**: Yeah, so let me give a more concrete example here.  Yes, under
the v3 idea, you'd have a commitment transaction, so each counterparty has their
own version and each counterparty has their own anchor output that's only to
them, right?  So basically, they RBF each other's packages; this is using
package relay.  So, you still have funny things like in the commitment
transaction, the balance output to the other person, which doesn't need to be
timelocked, so if I put my claim to the blockchain, my counterparty should be
able to take it right away, their balance, right?  Even right or wrong, they
should be able to take it.  But today we basically have to use this one-block
timelock in the script to make sure that there's not a pinning vector, that that
output can't be spent and then pin that and then create a pinning vector.

But this is bad because, for example, what if I want my balance from the
commitment transaction, what if I want it to go straight into cold storage?  I
can't do that.  It's a weird script that my Ledger or Trezor, or whatever,
doesn't support.  Does that make sense?

**Mark Erhardt**: Because there's the OP_CHECKSEQUENCEVERIFY (CSV) and you have
to handle them?

**Greg Sanders**: Yeah, because in the script it's going to say like one CSV,
say like one-block timelock, so you can't spend it in the mempool.

**Mark Erhardt**: Wouldn't it be something that we can make work with
descriptors now though?

**Greg Sanders**: It's not necessarily miniscript compatible, which is annoying.

**Mark Erhardt**: I see.

**Greg Sanders**: I've tried playing around with it.  So, you'd have to either
support it directly in miniscript, and everyone has to support miniscript, or
basically, the trick they do is they put this one-block CSV at the beginning of
the script, so you can look at it, kind of, or it's templated, right?  So
basically, you need to build a whole system of wallet support that, I talked to
the miniscript developers, and they weren't even aware it was a problem, because
they're worried about satisfaction properties and weight units and stuff like
that.  They're not worried about mempool policy weirdness.  So ideally, we would
just get rid of that, make scripts smaller and make them miniscript compatible,
like with miniscript today.

So, the ephemeral anchors idea is that, okay, we know we have one child; a
parent and a child, a parent and a single child, right?  One parent, one child.
What if we then say, if the parent has a specific kind of watermarked output, in
my implementation I use OP_2, by the way, the number two, not one; if the output
is marked this way, then it must be spent immediately.  So, this is done in
package submission and would be done in package relay.  So basically, this
output must be spent.  Therefore, it's basically, it's like a mutex lock.  It's
taking up the slot of the child, right?  It's saying, "You must make a child
from this output".  And this means that you can actually unlock the other
outputs as well.  So, you can have an arbitrary set of other outputs that you
know for certain that you can double-spend the child.

Let's go back to the example of the commitment transaction in Lightning.  So,
let's say your counterparty gets into the mempool with their version and they do
a spend.  The spend includes spending the ephemeral output as well as, let's
say, a Hash Time Locked Contract (HTLC) output, because they had the pre-image
or something.  So, now they're spending two outputs.  The thing is, if you see
it in your mempool, then you can directly double-spend that ephemeral output
because it's OP_2, and to satisfy that, it's an empty witness, you don't need
any data for that, and then you can bring your own output.  So for example, in
this example, you could actually sweep your own balance output, because they put
their version of the transaction on a mempool so you see, "Oh, there's my
output", and you can immediately spend that output as well to do a CPFP.  So,
you spend the ephemeral output and your to-self balance output from the
commitment transaction and then you get it mined.  So, that's one example.

**Mark Erhardt**: Wait a minute, so you use the anchor output and the output
script has this OP_2 that you mentioned, right?

**Greg Sanders**: Yes, the output script is OP_2, which means anyone can grab
it, right?  So, it could be you, it could be your counterparty, or it could be a
watchtower, pretty much anyone.

**Mark Erhardt**: So, oh, okay, so you spend both outputs in a single
transaction, so you only have one child transaction.  But that way you can spend
both your own output and the anchor output, satisfy the requirement that the
anchor output is being spent, but also get to redirect where you want your
funds.  I see, okay.

**Greg Sanders**: Yeah, so you can sweep all the available outputs.  So for
example, in this situation I could say, "Okay, I'll take my balance output, I'll
take all the HTLCs that are timing out back to myself, and all the HTLCs that I
have the pre-image for", you could do something like that.  Or, you could just
sweep the anchor output, use an output you have in your wallet already as an
additional input to pay for fees.  It's kind of up to you as a wallet
implementer.  And it also opens up the door for things like transaction
accelerators.  So, if you can get a pre-signed, unfunded transaction with this
output to someone who has a wallet of any kind, they can attach their own fee
input and do a CPFP.  So, they basically spend the ephemeral output, they'll
bring their own other input for fees, and then use that as a bump.  So, this
would be useful for things like watchtowers or transaction accelerators.

**Mark Erhardt**: Right.

**Greg Sanders**: So, to recap basically, then you'd have, whenever you're
making these smart contract compositions, you don't have to worry about what
shape the transaction outputs look like when it comes to pinning.  For a splice,
you can just directly pay splices into your Ledger, your Trezor, to Bitrefill,
or whatever, because they're giving you an address.  You can't mutate their
address relative to timelock, so it's much better for composability.  You can do
splices, pin, you can do splices from channels into new channels, set up a new
channel in a splice, and this isn't pinnable, so it's very nice.

**Mark Erhardt**: Cool.  So, I have a question about the OP_2 output script.
So, one of the problems that we want to solve is that we don't want to have all
these anchor outputs hanging around the UTXO set, so we want to ensure that they
always will be spent.  If we locked up the other outputs, basically the only way
that the commitment transaction has any fees is by attaching money to the OP_2
output, and we would ensure that it gets spent.  But if we make the other output
spendable too, would it be a policy that the OP_2 output has to be spent, or
would that be a consensus rule?

**Greg Sanders**: Yeah.  To recap, this is all mempool policy.  So the policy
is, it must be spent.  You can take a look at the implementation, it's only 130
lines of logic.  But basically, it checks like, does this transaction have this
special kind of output?  Yes.  And then you say, "This must be spent by the
child transaction".  So, you're basically doing package level analysis, saying
this has to be spent.  As another simplification, we say a parent with this
output must be zero fee, because if the child is booted from the mempool, we
definitely want the parent to not be mined.

**Mark Erhardt**: Yeah, so a miner could however include a transaction that only
spends the other outputs and leaves this zero value anchor output with the OP_2
output script hanging around.

**Greg Sanders**: Yeah, and they can also mine dust today, so I think it's
isomorphic, personally.

**Mark Erhardt**: I mean, since v3 is a mempool policy anyway, they could always
just mine the zero-fee transaction anyway.

**Greg Sanders**: Yeah.

**Mike Schmidt**: Greg, is there a reason that you went from, I think, early
discussions, it was going to be OP_TRUE, and now OP_2?

**Greg Sanders**: Yeah.  So, OP_TRUE is just camped by lots of tests and stuff.
It's just annoying.  People use OP_TRUE outputs as unit tests and functional
tests and I don't want to sit and disrupt everything.  And any numbered output
is basically just as good as another as long as it evaluates to true.  So it
can't be OP_FALSE; it can be OP_1 through OP_16, or something else too.  There's
some light discussion on the PR about maybe using like an OP_NOP; I'm kind of
against it, but anything that evaluates to true in the script sense is fine for
this purpose, as long as it's unique and other people aren't trying to use it
for otherwise useful reasons.

**Mike Schmidt**: Gotcha.  A bit of a higher level question.  I know the order
of operations, at least from my vantage point, was there was this idea to have
v3 transactions, and then it seemed like you had some ideas to put on top of
that or with that.  Are there other similar ideas that are kind of joining this
v3 package relay sort of grouping of potential policy updates?  Is there
somebody working on something else on top of all of this or in conjunction with
all of this?

**Greg Sanders**: Not that I'm aware of.  For historical colour, there's been a
lot of discussion on how to stop mempool pinning and not very many, I would say,
comprehensive ideas.  It's very hard to reason about because people focus on a
couple of the rules.  BIP125 has a rule called Rule 3, which is the absolute fee
pin, which is the most obvious.  But actually, anything we're trying to decide
in a mempool level that is something better or not for the miner is actually
kind of difficult, which opens up this mempool pinning in different ways.  So
basically, zooming into the case where it's one child and one parent is much
easier to reason about.  You don't have to traverse graphs and make estimations
and then make more assumptions about what the rest of the mempool looks like.

So, I would say at this point, there's no serious other proposals.  I think
there are people who are like, we should have a more comprehensive change to
today's policy, maybe fix some pinnings.  But I think it's really hard to reason
about and convince myself, or anyone else, that you really fix the problem
unless you scope it down, which is what Gloria did.

**Mike Schmidt**: Optech uses the term, "transaction pinning".  I've heard you
use the term, "mempool pinning".  Are those basically just synonymous?

**Greg Sanders**: Yeah, same thing.

**Mike Schmidt**: Yeah, just wanted to make sure there wasn't --

**Greg Sanders**: Mempool transaction pinning, just a bit longer.

**Mike Schmidt**: Murch, do you have other questions?

**Mark Erhardt**: Maybe a comment.  I've heard that somebody is looking into
trying to make the RBF rules all incentive compatible, or the rules for which
replacements are evaluated, because as you've already alluded to, we don't have
a perfect ordering of transactions.  So for example, if there's an original
transaction, when you make a replacement or make two replacements of that and
one beats it in feerate, the other beats it in absolute fee, it would
potentially depend on which of the two gets seen first by other nodes that they
would accept that.  But the other one could not replace the competing
replacement, because one beats it in feerate and one beats it in absolute fee.
So, this sort of problem is one of the issues around replacements on mempool
policies.

**Greg Sanders**: Yeah, and even if we do something like, let's say we just
assume that long-term mempool is going to be full and we just want to do feerate
optimization, it's still not an easy problem.  If you take a look at, I think
you're mentioning it, I don't have the link handy on my phone, but Suhas's work
has a PR where it's trying to make replacements more incentive-compatible, and
it's like a thread full of people making mistakes pretty much, because the
transaction relation topology is kind of complex, and you miss what should be
obvious things all the time.  So, this is where I've been thinking that this
kind of v3 direction is, in the short term, the right way to think about things,
because it's just too hard to reason about these larger topologies.  And we
should be focusing on figuring out if something like v3 is enough to get wallets
what they want, right?  Because in the end, this is all, you know, we're
balancing DoS with wallets, so do wallets need something like this?  Will they
use something like this?  And if the answer is a yes, I think it's the right
direction.

**Mark Erhardt**: Cool, super.

**Mike Schmidt**: What has feedback been, both on the implementation that you
have a PR open for, as well as the conceptual discussion on the mailing list or
otherwise?

**Greg Sanders**: I had really good feedback at the TABConf with other Core
devs.  So, I've had very good feedback.  Like I said, there's one or two people
who want to look at more comprehensive overhaul, but if they're just going to be
sketching and not moving forward, that's fine, but we can think about short
term.  So, overwhelmingly positive, I'd call it.  So, the implementation of the
kind of feedback was, "Wow, that's short", right?  It's 130 lines of code plus
tests.  So, it's really compact and easy to reason about, and I think that's a
very important piece to make something easy to reason about and maintainable, so
I'm kind of hopeful.  There's still some work being done.

Basically, I'm doing more work right now on the v3 stuff, so v3 and
prerequisites, to get that to a point where we can get that considered for
inclusion.  But I think at that point, I think it's a pretty easy sell.  It's a
little bit of bike-shedding with kind of the format of the outputs precisely,
and maybe some questions about if the anchor can have non-zero value, because
that opens up possible fun and games with miners.  But those are solvable.  We
could just say it has to be zero value to make it simpler; that's fine by me.
We'll just have to update how other things are handled.

**Mark Erhardt**: Yeah, and in parallel to that is of course the effort to push
forward package relay, which I think has a BIP now and the implementation is in
the works.  But the BIP could also use a few more eyes.  So, if mempool policy
and network relay is your sort of gem, maybe take a look at that.

**Greg Sanders**: Yeah, that's right.  So, package relay is still not a thing
you can do in test mode for a Bitcoin node.  You can push it using submitpackage
RPC, so it's like a local testing, but it doesn't actually get propagated across
your regtest network or anything.  So, the level of testing right now is
basically on your own node.

**Mark Erhardt**: Cool.  I think then we could move on to the next section; what
do you think, Mike?

**Mike Schmidt**: Yeah, I think that's good.  It's an opportunity to also segue
in Larry.  Larry, I don't know if you have any thoughts on either the
implementation or just the philosophical discussion around v3 and ephemeral
outputs.

**Larry Ruane**: No, not in particular, no.

**Mike Schmidt**: Okay, great.  Well, instagibbs, thanks for joining us.  You're
welcome to stay on and continue to comment and listen, but if you've got other
things to do, we understand as well.  Thanks for joining us.  Larry, it's that
time of the month again for PR Review Club.  Do you want to introduce the frame
up, the PR maybe at a high level?  And we actually have the PR author here to
help opine on it as well, so we should have good coverage on this one.

_Bump unconfirmed ancestor transactions to target feerate_

**Larry Ruane**: Yeah, sure.  Let's see, this one is #26152 that we reviewed,
and this is authored by Murch and also by Gloria, so it's a kind of joint effort
for those two.  And I think this PR was, I forgot, it's like a few months ago, I
think maybe back in June or so, is when this was first published as a PR.  So,
it's probably getting pretty close to getting merged and there's been a lot of
comments on it and stuff.  So, we decided to review it.  Actually, Gloria was
the host of that, I think.  Yeah.  So, it took two weeks to review this.  So, we
only got through half the questions in the first week and then Gloria and
everybody decided to push it into a second week.

So, what this PR does is, oh, maybe I should just give a little background
first, is when the Bitcoin Core wallet is constructing a transaction just to do
a payment, I mean, not anything unusual, but just a regular payment, then the
RPC that will do that, there are two RPCs that are similar: sendmany and
sendtoaddress.  And the way this works is that the wallet will construct a list
of UTXOs that are available to spend that it has the keys for, and it sends all
of those, in particular the values of those UTXOs, and a target amount, how much
we want to spend in this transaction, to coin selection.

So, coin selection is this kind of a magic black box.  And I call it that
because there's a lot of complexity hidden inside this coin selection, but it
has a simple interface.  And I think Murch is actually an expert on coin
selection because he did his thesis on this, I believe.  So, there's actually
more than one coin selection algorithm, but we don't have to get into any of
those details.  Just think of it as this magic black box where it takes a list
of UTXOs and in particular, the amounts of those UTXOs, and then finds a
combination of those, a subset, that will add up to the target amount that we
want to spend.

So, I think a lot of listeners here are probably too young to know, but in the
old days before credit cards and stuff, this is something that a human being
would actually do.  So, you want to pay for something with cash, you look in
your wallet or purse and you find a combination of nickels, dimes and quarters
and bills that will add up to at least what you want to pay.  And there could be
more than one solution to that, more than one combination would work, but you
try to find a combination that's close to the target amount, and then if you
overshoot that, you get change back.  So, this is what's being automated in coin
selection.  And the thing is that when coin selection returns this subset of the
UTXOs that it decides are good ones to spend, some of those might be UTXOs that
are part of unconfirmed or mempool transactions, right?  So it tries to avoid
doing that.  It tries to choose UTXOs that are from at least I think actually
six blocks that are, you know, six confirmations, but sometimes it can't be
avoided and it'll return some UTXOs that are from unconfirmed transactions.

So, what people have noticed is that -- and also another thing is when the user
wants to construct this transaction, the user also gives us a feerate, or some
kind of priority, that the Bitcoin Core wallet can derive a feerate from, and
that affects obviously how quickly the transaction gets mined, so it's sort of a
priority.  And if the feerate is like, say 100 sats/vbyte, then there's a
certain expectation of how long that will take in the current conditions with
block space demand.  So, people were noticing, starting several years ago, that
sometimes a transaction would take a lot longer than expected.

So then, upon investigation, it was discovered that the transaction would be
spending one or more unconfirmed UTXOs that were in the mempool from a low
feerate parent, or the UTXO is from a low feerate unconfirmed transaction.  What
that causes is it drags down the effective feerate of our transactions.  So,
even though we want our feerate to be X, it's actually some amount lower than X,
because an economically rational miner realizes that to mine our transaction,
then of course that requires all of our unconfirmed parents to be mined, and in
general all of our ancestors, they have to also be mined.  So, In deciding
whether to include our transaction in the current block, the miner will actually
add up all the fees and all the sizes of our transaction plus our unconfirmed
ancestors, and then it calculates an overall, you might call package feerate or
ancestor feerate is another name for it.  And if that's lower than what this new
transaction is requesting, then this transaction won't get mined as quickly as
desired.

You might think, well, what we can do is just do the same ancestor feerate
calculation when constructing the tx so that we could actually bump our fee
enough that the ancestors that are having to be included that are lower feerate,
that this overall package has the required feerate so we can bump our own.  So,
this is called fee bumping our ancestors.  And this, by the way, is a little
confusing of a term because when I first read that I thought, "Wait a second, we
can't really modify our ancestors.  We don't even have the keys for those in
general".  We're not talking about replacing and increasing the fee on our
ancestor transaction, but just the terminology is when we say we're fee bumping
our ancestors or our parents, then that just means that we are constructing our
transaction at a higher feerate, enough higher that it gives the miner enough
incentive to mine us and our parents or our ancestors.  So, that's what fee
bumping is in this context.

You might just think, okay, let's just say, just to keep it simple, we have a
single parent and it's a low feerate parent.  Well, then we can look at its size
and its fee and then combine that with our size and fee and construct this
overall, calculate this effective feerate for our transaction, and then add
enough fees to reach what the user is requesting for the feerate to be for this
transaction.  But it's not quite that simple, because our parent might have
another child that's in the mempool, of course, that's like our sibling to us,
and that one may have a very high feerate.  So, in that case, the miner will
mine that transaction, that high feerate child and our shared parent before it
mines even us.  So, in that case, we don't have to "bump" our parents'
transaction fee; we don't have to do that because this other child is already
doing it.

This is why the problem is a little more complicated than you think at first,
because it has to -- and really the code that is in this PR is called MiniMiner.
What it's actually doing is sort of predicting what the miners will do and to do
that, not for the entire mempool, but only for this transaction, the UTXOs that
it can spend, that it has available to spend, so that's a much smaller set
generally than the entire mempool.  So, it's predicting what the miner will do
as far as mining our ancestors, maybe other children that are not our ancestor
or descendant will pull the effective feerate of some of our ancestors higher,
and so then we don't have to bump those.  So, we want to try to calculate the
exact fee bump, the minimum fee bump that we need and not do too much, because
that's just wasting money.  So, we try to calculate the exact feerate that we
have to bump, taking into account other siblings of ours, basically, that are
already bumping our parents and then we don't have to.

**Mark Erhardt**: So, maybe let me jump in.

**Larry Ruane**: Yeah, please do.

**Mark Erhardt**: Okay.  All right, you've covered a lot of ground and I wanted
to recap a few of the abstract concepts that brought us here so far.  So, we are
talking about transaction building, and we want to pick the set of inputs that
are sufficient to fund a transaction, and that are also in line with what we
want to spend.  So, if the current mempool is extremely competitive, we want to
maybe spend few inputs and we will try to build a small transaction at a high
feerate.  If the mempool is wide open and nobody is asking for block space right
now, we might be more generous and use a lot of inputs.  So, during that coin
selection, sometimes we may need to use unconfirmed inputs.  In that case, we
need to account for the feerate of the parent transaction.  That is the main
problem that this PR addresses.

To that end, what we use is a concept called CPFP.  So, the parent transaction
cannot be changed, transactions are immutable once submitted to the mempool, but
when we add a child transaction that has a much higher fee that is attractive to
miners to include, they must include the parent first in order for the child
transaction to even be eligible for inclusion.  You cannot spend a child
transaction before the output that it spends even exists.  That's why the parent
has to be included first.

Basically, when we are spending the unconfirmed output from a transaction
already in the mempool, we are constructing a CPFP transaction.  But before this
PR, we were doing so without considering the implications.  And after this PR,
we actually look at the feerates of the parent transaction and pick deliberately
the feerate for the child transaction to reach the goal of the feerate for the
whole package that we're intending to do.  Sorry, just summarizing what you
already heard from Larry just now.  So, I think Larry was just about to go into
the details of how the PR manages to figure out what exactly the feerate is
using the MiniMiner.  Back to you.

**Larry Ruane**: Okay, thanks.  Yes, and let's see, there's one detail I wanted
to just mention first, is the way we actually generate this additional fee is
when we tell coin selection -- so normally, coin selection is given the output
amounts of these UTXOs, right?  But for quite a few years now already, there is
this concept that's been in the wallet called effective value adjustment.  So
essentially, that's like when you give coin selection, this list of UTXOs, each
has a real output value, let's say 1 BTC, then coin selection is given a lower
number.  We sort of lie to coin selection a little bit.  We say, "Okay, this
output is actually only 0.995", or something like that.

The reason we're doing that, and again, this is before this PR, this has just
been in for quite a few years, this effective value calculation; but the reason
we do that is because we want to generate a fee, enough fee to spend this UTXO.
So, when we construct this transaction, it's going to have an input, and the
input is actually the larger part, you know, inputs are larger than outputs.
So, we have to make sure to have enough of a fee to cover the input size and so
we just fake, we pretend that the output has a slightly lower effective value
and then that way, if the coin selection chooses that UTXO, then the difference
between its real output value and what it was told the output value was is
slightly less, then that difference goes to fee, it will become a fee amount
that's available to become the fee, part of the fee.  Is that your
understanding, Murch; did I get that right?

**Mark Erhardt**: So basically, the value that we deduct to calculate the
effective value corresponds to how much it will cost to put the bytes for the
input into the transaction at the feerate we're looking to achieve with the
transaction.  So, if an input is 140 bytes and we're trying to make a
transaction at 10 sats/vbyte, we will calculate an effective value for the input
that is 1,400 satoshis less, because that will pay for a 140-bytes input at 10
sats/vbyte.  So that decouples the feerate calculation from the input selection
because whenever we pick inputs, they have already paid for their keep; whatever
inputs we select, they have already been accounted for in the feerate
calculation.

**Larry Ruane**: Yeah, and the reason I mention all that, and what Murch just
described there has been in there for a long time, that's something that applies
to all UTXOs that we might be spending, whether they're confirmed or not.  So,
that's been in there for a long time.  What the difference is, what this PR does
is it uses that same concept, that same idea, but reduces the effective value
even more.  And that's the reason for doing that is, again, because we want to
fee bump for unconfirmed transactions only.  So, we may need to fee bump the
unconfirmed transactions by reducing their effective value even more, and that
generates more fees.  So that's how we do it, we sort of lie to coin selection
even more and reduce values even slightly more, but only for the unconfirmed
UTXOs that have a lower feerate than what our desired feerate is.  So again,
they might have a sufficient feerate or higher feerate, then we don't have to
"bump" those.  So, it's only some of the unconfirmed UTXOs that we have to do
this for.

**Mark Erhardt**: Right, so basically, whenever we are forced to use unconfirmed
inputs, which we only do as a back-off step if we can't fund a transaction only
from confirmed funds, we look at the parent transaction.  If it is lower in
feerate than what we are targeting, we must bump the parent in order for the
package to reach the right feerate.  Since we can tell from the UTXO which
parents will have to get bumped if we use a UTXO, we can calculate how much fees
we have to pay extra in order to elevate the parent transactions to the target
feerate, and we deduct that from the effective value as well.  So, not only does
an unconfirmed UTXO now pay for its own input size, but it also pays for bumping
the parents to the correct feerate.  So, the effective value on which we do the
coin selection already has in mind basically how much it has to pay to make the
whole package the right feerate.  I think you wanted to go somewhere from this,
so I'll give it back to you.

**Larry Ruane**: Okay, just the last point is that after coin selection chooses
this subset, remember the coin selection is given this very large list of UTXOs,
and then it's only going to choose some of them, enough to reach the target
output value.  But if it turns out that it chose two UTXOs that have a common
ancestor that needed to be bumped, like a low fee ancestor, a common parent that
needed to be bumped, then if we bump both of those, remember again, we're
choosing two UTXOs, the coin selection shows two UTXOs which happen to have a
common ancestry, then when we calculate those bump values before coin selection,
we calculate them kind of independently, or we didn't take into account that
shared ancestry because we don't know which UTXOs the coin selection is going to
choose.

But now it turns out that coin selection chose two UTXOs that have a common
ancestor, then we're bumping too much, because we don't need to bump through
both of those UTXOs to that common ancestor.  So, then we have to run the
algorithm again, make a second pass, but this time -- not the coin selection
algorithm, but the MiniMiner that this PR implements, we run that algorithm
again, but this time the input to it is not this very long list of what's called
a cluster, which is all these related UTXOs, well, it's still a cluster, but
it's formed from a much smaller set of the UTXOs that coin selection chose.

Then, there's a kind of nifty algorithm that really was fun to learn about.  I
would highly recommend anybody who's interested in algorithms to look through
this stuff.  But basically, it figures out how much we're over-bumping because
of these two UTXOs that have common ancestry.  And then, that can be used to
increase; we want to reduce the fee, basically, we've overshot the fee now, so
then to correct for that, we make the change output have a slightly higher
value.  So now, if this transaction doesn't have a change output, then it could
just get thrown into increasing the fee, and that's not a terrible thing,
because the miner will choose it more quickly; or we might create a change
output if it's, I guess, significant enough.  I don't understand that part of
the code, and I don't know if you wanted to explain that part, Murch.

**Mark Erhardt**: Yeah, so basically, the problem is pretty complicated because
you can have more than one ancestor.  So, let's say you have a wallet that only
has received a single transaction, but the mempool has been very full, and the
service that you bought the Bitcoin from sent it with a transaction that had
hundreds of outputs and a lot of other people are trying to get their money out
and dumping that already.  So, you have to look at all the connected
transactions, because some other transactions might interact with the effective
feerate of your ancestry, or there might be multiple ancestors and some of those
ancestors have high fees and some of them have low fees.

So, the MiniMiner that we've been mentioning essentially treats all of these
connected transactions, a so-called cluster, as the set of transactions to pick
into a block, and then it will build a block up to the target feerate, and
whatever it has included in the block already, it knows that it doesn't have to
bump anymore because it got picked before the feerate that we're aiming for.
So, as Larry mentioned, if we do the bump fee calculation for every UTXO in
advance of coin selection, because we need to know if we pick that UTXO, how
much fees do we have to pay extra in order for the package to achieve the right
feerate?  But if we have overlapping ancestries in any way, we would of course
be bumping the ancestry multiple times because each UTXO bumps all of its
ancestry.  So when UTXO A and UTXO B both have the same shared ancestry, they
would have paid twice for it.  And that fee, of course, in a final pass, when we
look at the whole input set together, we can calculate a single bump fee for the
whole input set.  And the difference between the individual bump fees and the
bump fee for the set tells us how much we overpaid in the initial estimate, and
we can reassign that either to our own change output or drop it to the fees.

**Larry Ruane**: And the reason we don't want to go back through coin selection
again, like you might say, "Well, okay, we're paying too much in fees for this.
Let's just go back and choose again".  No, because that's just a cyclical
dependency that you might never get out of.  We don't go back through coin
selection again.

**Mark Erhardt**: Maybe here's a good point to hook into something you said
earlier.  So we actually have multiple different algorithms in Bitcoin Core how
we pick input sets, and when we get to the point where we have a single decided
input set, we have already excluded the other options as worse.  So, the scoring
system that we use to evaluate input sets against each other has at this point
already determined that this was the best option that we came up with.  So, even
if we are dropping maybe some extra fees onto our transaction because we have a
changeless transaction, we have already calculated that this is the most
cost-effective way of building the transaction.

**Larry Ruane**: And, Murch, do we sometimes actually add it if that residual or
that extra fee, too high a fee, is large enough, do we actually add a change
output do you know?

**Mark Erhardt**: Yes, we do.  Yeah, if we can pay for the change output and it
becomes a non-dust amount, then we will actually just add a change output at
this point.

**Larry Ruane**: Okay, so that's all I had.  So, Mike or Murch, if you'd like to
cover any of the questions that we had in the Optech Newsletter; we have a list
of all the questions that were written for this as a discussion generator for
the PR Review Club.  Or we could just move on to the next topic.  I think we
covered it pretty well.

**Mike Schmidt**: I think we covered it pretty well and maybe in the interest of
time we move on, but encourage anybody listening to review the newsletter and
review the selected questions and jump into the logs from the PR Review Club to
get some of the answers and thoughts from folks who attended that meeting.
Larry, thank you.  You were in the intimidating seat to be able to have to
summarize someone's work who's also on the call listening!  So, thank you for
taking that challenge on.  I thought it was interesting as well.  You started
with the analogy of like dollar bill selection as an analogy, and you see how
quickly that can break down in coin selection within a Bitcoin wallet with fees
and ancestors and feerates and all that, and it's sort of its own rabbit hole.
So, thank you for giving us that tour, Larry, and, Murch, thanks for authoring
the PR.

Murch, one question for you before we move on.  I see the PR is still open; what
remains to be done to get this merged.

**Mark Erhardt**: So, yeah, I've been traveling a lot lately.  I still have to
address a bunch of review comments and I actually had an interesting discussion
with some colleagues of mine today that posited the problem that since the
transaction cluster we pull in and evaluate to calculate the exact fees for each
UTXO, it's essentially unbounded because, in the worst case, your ancestors have
descendants that have ancestors in turn that have descendants in turn and so
forth, that transitively you could be connected to the whole mempool, and that's
a potential dust vector.  People might, just for a sudden giggles, create huge
clusters in the mempool because they know that Bitcoin Core coin selection would
get super-slow because we evaluate the whole mempool every time we calculate the
fees for UTXOs.  So, we were considering whether we want to restrict it to only
rely on our own transactions for the bump fees.

So, in case of a cousin transaction or a sibling transaction that bumps some of
our ancestry that we did not offer, we might just ignore it and overpay on
purpose for dust safety and basically not relying on a third party to keep their
transaction in mempool, because they might just RBF it and reduce the fee, or
double-spend themselves to remove that UTXO that was bumping its ancestry.  So,
to make sure that we always control how much feerate our package has, we might
overpay on purpose.  So, I'm thinking about that still.  Hopefully maybe by the
end of the year, this is actually merge ready, but we'll see.  So, if you want
to grind your teeth on some interesting algorithmic problems and look at this
one, I think it's been pretty well documented with the PR Review Clubs and the
chat logs from our meeting, so might be fun to look into.

**Mike Schmidt**: Excellent.  Thanks again, Larry and Murch, for covering that
segment.  We'll move on to software release candidates and releases.

_BTCPay Server 1.7.1_

We have a BTCPay release 1.7.1, and it's got some changes to the API, some
enhancements to the API, some bug fixes, and then it's marking MySQL and SQLite
backends as deprecated.  This was released ten days ago.  If you are a BTCPay
user, upgrade.

**Mark Erhardt**: I think if you use Core Lightning (CLN) under the hood, you
might want to take a moment before you upgrade to 22.11 in conjunction with
BTCPay server.  I saw today that there was a change in 22.11 Core Lightning, how
the server address of CLN is announced.  I think DNS instead of IP, and there
was an issue with BTCPay Server there.  So, try to read up if you're using both
CLN and BTCPay Server and looking to upgrade, I think there's a patch coming
soon.

_Core Lightning 22.11_

**Mike Schmidt**: Thanks for the heads up, Murch.  And yeah, that's the next
release we're talking about here, is Core Lightning 22.11.  We covered some of
the changes to this in past weeks.  We talked about the reckless plugin manager
and some of the changing in version numbers.  But check out the release notes,
and then also be aware of what Murch just pointed out if you're using CLN with
BTCPay Server

_LND 0.15.5-beta_

Next release is LND 0.15.5-beta, and the release notes just note some bug fixes
it looks like, and I think we covered the release candidate for this previously.
I don't know if there's anything more interesting than that.  Murch, are you
aware of anything?

_BDK 0.25.0_

**Mark Erhardt**: No.  Great, and then last release for this week was BDK
0.25.0.  I see this is marked that we're linking to the pre-release, but I
thought that there actually was a 0.25.0 release; maybe that's just tagged
differently.  But there's a fix for some slow sync times when you're using
SQLite, it looks like, and there's some additional bug fixes in this release as
well.  And they added some examples for connecting your BDK to the Explorer
software, Electrum Server, Neutrino, and Bitcoin Core.  So, maybe jump in and
play with some of those examples if you're curious about BDK and interacting
with some of those services.  Murch, any comments on BDK?

**Mark Erhardt**: Not from my side.

_Bitcoin Core #19762_

**Mike Schmidt**: Okay, great.  Well, I thought since we had Larry on, and he
does a lot of work on Bitcoin Core, that maybe he could summarize this first PR
to the Notable code and documentation changes for Bitcoin Core #19762.  And
before he jumps into that PR summary, we'll just take an opportunity right now
to allow anybody who's listening who has a question or comment to raise your
hand, request speaker access while we go through these PRs.  And hopefully when
we wrap that up, if there's any questions we can get to those.  Larry, do you
want to summarize this Bitcoin Core PR about the RPC and positional arguments?

**Larry Ruane**: Sure, and also I forgot to mention at the very beginning today,
when I was introducing myself, that I'm able to work on Bitcoin Core full-time
because of a grant from Brink.  So, thank you to Brink, couldn't be doing this
without Brink.  So, this PR has been merged and it was merged I think nine days
ago, and it was from actually 2020, it took a while to get merged, but it's a
pretty simple idea.  So, in the RPC interface, and this includes bitcoin-cli, in
the past you could have positional arguments or you can specify -named, and then
you can have named arguments which means like keyword value pairs.  And then
what that lets you do is to specify the arguments in any order because they're
keyword identified.  But you could only do one or the other.

So, what this PR does is it allows you to do both.  And I think it's a
convenience type of thing.  And I think the mental model that you should have
for this, because you might be wondering, "Well, how can you have both and
what's the meaning of that?"  So, I think what the mental model is, is that you
pull out all of the keyword arguments and then anything that's not keyword is
left, those are positional.  So, that's the first argument, second argument,
third argument.  So, this provides quite a bit of flexibility.

There's just one thing that was discussed in the PR that was really interesting,
I thought, was that sometimes it can be a little confusing because let's say
that the first positional argument, suppose you specify that with a keyword,
then you have a second argument that you don't specify with a keyword, then that
argument will be interposed, because remember I said you pull out the ones that
are specified with keywords, and then what's left is a positional argument.  So,
the first non-keyword argument becomes the first argument, and then that would
conflict with the first argument that you've now specified with a keyword.

So practically speaking, when you're doing this kind of mingling of positional
and named, it works best if the first so many arguments are positional and then
the latter ones toward the end are named, and then they can be in any order and
you don't have to specify optional, of course.  So, that's all I had on that,
unless there's any questions.

**Mike Schmidt**: Nothing from me.  Murch, do you want to augment any of that?

**Mark Erhardt**: I have a question, actually.  So if you, for example, both
specified the feerate as a positional argument and as a named argument, I hope
that it would throw, or does it have some sort of priority?

**Larry Ruane**: Yeah, it would throw an exception, that would be an error.  So,
I think that might be a possibility to improve that, so I was going to look into
that, but possibly leave a comment, a suggestion on the PR.  Well, it would have
to be a follow-up PR, because this has been merged.

**Mark Erhardt**: Right, so basically, you can specify each argument once, but
either as a positional or as a named argument.  And we try to usually design the
RPC such that the arguments that you most often want to specify are early in the
positional list, like the feerate is usually one of the first arguments.  So,
other more optional things would be maybe just provided as named, and then you
don't have to provide a list of ten positional things.  But you put the
recipient address, the amount, and the feerate, and then you say, "I want this
to be a PSBT as a named argument".

**Larry Ruane**: Yeah, and see, one of the really nice benefits of this is that
with positional only, then if you remember, if you want to specify, and you have
a lot of optional arguments which have a default, and if you want to specify one
of the latter arguments in the positional list, then you have to specify
everything leading up to that.  This relaxes that requirement, where you don't
have to do that if you specify just some of the optional arguments as keyword
arguments.  But you're right, Murch, usually the first few would be the ones
that you most likely will specify all the time.

A good example, by the way, is createwallet.  That takes, I think it's like
eight arguments, eight or nine, it's one of the highest ones in the number of
arguments.  So, the first one is not optional, it's the wallet name.  And then
after that, there's a whole bunch; there's like seven positional arguments that
this would be very useful for specifying just some of them, with some specifying
the keyword arguments for those.

**Mark Erhardt**: Cool, sounds great.  Thank you.

_Core Lightning #5722_

**Mike Schmidt**: Thanks, Larry.  The next PR for this week is Core Lightning
#5722, and it adds documentation about how to use the GRPC interface plugin.
Murch, what is GRPC?

**Mark Erhardt**: Why are you're asking me all the hard questions?!  I think,
well, RPC is Remote Procedure Call.  I don't actually know what the G stands
for.  Maybe it's just "Go", because I've seen it in the context of LND first,
but I don't actually know what G here in this context is.  Larry, do you know?

**Larry Ruane**: I think it came out of Google originally, and it's been spun
off as a separate project after that.

**Mike Schmidt**: Yeah.  Google came up with this originally.  It's a way to
wrap RPC calls to be used in a bunch of different environments.  And so, I think
in the context of the PR we're talking about here, it allows you to interface
with your CLN node using GRPC.  So you can essentially use any of the languages
supported by GRPC, which also provides I think some authentication and other
performance-boosting ways of interacting with your node over remote.

**Larry Ruane**: Yeah, so I was just going to say real quick, I think they put a
lot of effort, I know, into making it smooth as far as being backwards
compatible.  They made it easy for older clients to work with newer versions of
the protocol on the server, or whatever.

**Mark Erhardt**: So, a quick web search reveals that the G actually does stand
for Google, and it's just a framework to implement high-performance remote
procedure calls.  So, yeah, it's basically a standard approach of building an
RPC set for a piece of software.

_Eclair #2513_

**Mike Schmidt**: Okay, I think that's good on that PR.  Next one we have here
is Eclair #2513, and I must confess that with my travels this week, I did not
dig into this one to the level of being able to provide my cursory usual
summaries.

**Mark Erhardt**: Let me jump in then.  So, #2513 on Eclair deals with a problem
that we introduced through a change in Bitcoin Core.  So, on Bitcoin Core, we
matched the output type of recipient outputs with our change.  So, when you send
to a wrapped segwit output, you will create a wrapped segwit change output.
When you send to a legacy output, you will create a legacy change output.  When
you send to a taproot recipient, you create a taproot change output.  The idea
here is if both outputs on the transaction have the same type, it's harder to
tell which of the two is the change output and which of the two is the
recipient.  And for Eclair, this caused a problem, because to create a Lightning
channel, all of your inputs must be segwit inputs, because a Lightning channel
is essentially a chain of unconfirmed transactions that are -- yeah, you need to
be able to create a recovery mechanism before you fund the commitment
transaction.

If a miner could maleate the input or the funding transaction and change the
txid, the funds could be held hostage by your channel partner because you no
longer have a unilateral recovery.  So, we can only use segwit UTXOs to create
Lightning channels, and Eclair being a Lightning Service Provider (LSP), or
being the implementation of an LSP for the LN, they only want to have UTXOs that
can create Lightning channels, so they only want segwit outputs.  So, if you
send from Eclair to a P2PKH address in, I don't know, an onchain transaction,
they would now get legacy outputs which are not usable to create Lightning
channels, and they wanted to avoid that.  So, what they did was, instead of
allowing Bitcoin Core to always match the output type of the recipient, they
always use native segwit v0 outputs, so P2WKH outputs, so that these can always
be used for Lightning.

**Mike Schmidt**: Excellent.  Thanks for taking that one, Murch.  I don't think
there's anything that I have to add.  Larry, do you?

**Larry Ruane**: No.

_Rust Bitcoin #1415_

**Mike Schmidt**: Okay, great.  We'll move on to Rust Bitcoin #1415, which
implements or allows the use of this Kani Rust Verifier to prove some properties
of Rust Bitcoin's code.  I actually was not familiar with this tool, but it
looks like it's an analyzer/verification tool that does some additional
reasoning against Rust programs to prove certain things about memory safety, or
certain runtime errors based on analyzing the code.  So, it provides additional
level of verification for that Rust-Bitcoin code.  Murch, are you familiar with
this analyzer previously?

**Mark Erhardt**: I am not, no.  It sounds cool.

_BTCPay Server #4238_

**Mike Schmidt**: It sounds cool.  And then the last PR for this week is BTCPay
Server #4238, and this is actually part of the release that we noted above.  It
adds invoice refund endpoint to BTCPay's Greenfield API, and that Greenfield API
is sort of their newer API over the last couple years, which is separate from
their original BitPay-inspired API that they started with originally.  So, you
have invoice refund endpoint now with the new API.

**Mark Erhardt**: This of course addresses the problem that you can't just send
money back when somebody pays you.  If, say, you receive the payment onchain or
even on Lightning, and the customer then afterwards cancels their purchase and
you want to refund them, you cannot just send back to the address that the funds
came from, that the previous transaction was funded from, because you don't know
whether the recipient directly controls that.  If, for example, they use an
online wallet with shared custody of a lot of users' funds, that address might
not actually be associated at all with the user that requested the payment to be
made.  So, this is a way to collect information from the customer where a refund
should be going, or that would be my interpretation.  I should probably look at
it a little more.

**Larry Ruane**: I think you're correct.

**Mike Schmidt**: All right.  I don't see any questions, so I think we could
probably wrap up by saying thank you to instagibbs, thank you to Greg Sanders,
thank you to Larry for joining us and helping opine on the news and the PR
Review sections.  It's very valuable to have you experts opine on what you're
looking at and what you're offering, so thank you, Larry.  I think instagibbs
dropped, but thank you to him as well.

**Mark Erhardt**: All right, thank you very much for coming and listening, and
we'll see you all in a week, or you'll hear us, I say.

**Mike Schmidt**: Cheers.  Have a good week, Murch.

**Mark Erhardt**: Thanks, enjoy your trip.

**Mike Schmidt**: Thanks.  Bye.

{% include references.md %}
