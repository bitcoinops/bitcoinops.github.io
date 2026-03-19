---
title: 'Bitcoin Optech Newsletter #395 Recap Podcast'
permalink: /en/podcast/2026/03/10/
reference: /en/newsletters/2026/03/06/
name: 2026-03-10-recap
slug: 2026-03-10-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Jon McAlpine, Antoine Poinsot, Mike Casey, and Ethan Heilman to discuss
[Newsletter #395]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-2-11/419798504-44100-2-31bff5b4caf7f.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #395 Recap.
Today, we're going to be talking about a few News items, including verifying
VTXOs across different Ark implementations; there is a draft BIP for expanding
miner-usable nonce space in the block header; and then, we have our monthly
segment on Changing consensus that has a handful of quantum-related items, and
also some tooling for OP_TEMPLATEHASH.  This week, Murch, Gustavo and I are
joined by a few guests.  I'll have them introduce themselves briefly.  Jon.

**Jon McAlpine**: Hi, my name is Jon and I'm working on V-PACK, which is a tool
for independently verifying VTXOs on Bitcoin layer 2.

**Mike Schmidt**: Antoine.

**Antoine Poinsot**: Hey, my name is Antoine, I work on Bitcoin stuff and
Bitcoin Core at Chaincode Labs.

**Mike Schmidt**: Mike.

**Mike Casey**: Mike Casey I work over with the Anduro team over at MARA, and we
work on quantum-related issues primarily these days.

**Mike Schmidt**: And Ethan.

**Ethan Heilman**: Hi, I'm Ethan, I'm one of the co-authors of BIP360, and I've
been taking a look at how Bitcoin can survive breaks in its signature
algorithms, including quantum attacks, but also classical attacks.

_A standard for stateless VTXO verification_

**Mike Schmidt**: Thank you all for your time and thanks for joining us.  We're
going to jump in with the News.  First item, "A standard for stateless VTXO
verification".  Jon, you posted to Delving Bitcoin about new V-PACK that you
just mentioned, a stateless VTXO verification standard.  Maybe there's a few
different questions we can unwrap for the audience to make sure they're up to
speed.  How about, remind us what a VTXO is, what is verifying a VTXO, what is
the stateless verification of VTXO, and then why do we need a standard for this?

**Jon McAlpine**: Sure, yeah.  Okay, so starting with what is the VTXO, that's
probably the most important.  VTXO stands for Virtual Unspent Transaction
Output.  And it's kind of the atomic unit of ownership for the Ark layer 2
protocol.  So, one of the things that's, I think, really helpful and nice about
Ark is that the VTXO maps very closely to a UTXO, just like on layer 1 Bitcoin,
and it's even right there in the name.  But there's one important distinction,
maybe more, but there's one that I'm going to talk about today, which is that on
layer 1 Bitcoin, to kind of have full sovereignty and access to your funds, you
only need a private key or a seed, something like that, and you can access your
funds.  In Ark, with VTXOs, if a user wants to unilaterally exit, which is to
say kind of claim their funds on layer 1 without cooperation of the Ark Service
Provider (ASP), they actually need two parts.  So, I call this kind of a
half-key problem.  You need the private keys and you need a map to your specific
VTXO, because your VTXO lives in a leaf in a taproot tree.  And to get to that
leaf, you actually need to kind of construct the tree from the root, which lives
on layer 1 as a layer 1 transaction, up each layer of the tree until you get to
your specific leaf containing your VTXO.

So, for unilateral exits, you cannot just have your private key, you also need
this kind of map.  And so, that's what V-PACK aims to do, is to store this map
in a kind of highly optimized file that can give users sort of an independent
backup, and also kind of verify that there's kind of two pillars of security
with VTXOs.  One is that you have the map to your funds and you have the ability
to store your funds, and that's what V-PACK does currently.  It's work in
progress.  So, the second pillar is not quite implemented yet, but that's to go
through that tree and verify that there are no other spending possibilities, no
other kind of back doors where an ASP, or someone else, could sweep those funds
or take those funds for themselves.

Okay, and so then moving on, the stateless aspect is that this is meant to be
deterministic.  So, if you have the anchor transaction on layer 1 Bitcoin and
you have the full taproot tree, you can construct those two pillars of security
to be sure that you have access to your funds and no one else does.  I want to
be clear as well, there are two main implementations of Ark currently.  Ark labs
are building Arkade and Second are building Bark.  And with both of these
implementations, you already can have all of this information.  They freely
provide this data, those are open-source projects.  I want to shout out those
teams, they've been very helpful.  And this isn't to say that they don't give
you everything you need, they do.  But V-PACK is aiming to be kind of an
independent, neutral standard so that even as Ark implementations are diverging
in their focus, or innovating and bringing new features to layer 2, the security
and the fundamental sovereignty and ownership of the VTXO hopefully can kind of
converge on an open standard, so that users maintain their sovereignty over
their funds and their ability to independently audit that sovereignty and
potentially claim those funds on their own as well.

**Mike Schmidt**: I think we covered all of the pieces of my original question,
and you also touched on one of the, I don't know if, I guess it's maybe not an
objection, but one of the concerns raised.  I think it was Stephen Roose talking
about the path exclusivity, and I think you mentioned that that's something that
you'll be working on next, which is, okay, you can ensure that your unilateral
exit is in there, but what about any other shenanigans that may have been put in
there?  And so, that's in progress, correct?

**Jon McAlpine**: Yes, that's right.  I've actually recently applied for a grant
from OpenSats to continue this work.  I'm still building it on my own.  But
yeah, the current next step is, like you said, verifying that no one else can
claim those funds.  Looking further down the line and longer term, if covenants
become a thing, this makes things a little easier for V-PACK, and I would say
for Ark in general.  But the need to still be able to independently verify is
still there.  And so, I think this kind of tool is useful and important now and
moving forward.

**Mike Schmidt**: Now, I know there's a website with a live tool.  Is it
vtxopack.org; do I have that right?

**Jon McAlpine**: Yes, that's right.  Yeah, so I'd eventually like this to be
kind of a suite of tools.  The V-PACK library is intended to be no standard and
potentially usable on hardware wallets or other kinds of constrained devices.
But I'd also like to add some tools where users can broadcast these unilateral
exit transactions, or these series of transactions, if needed.  Currently, that
vtxopack.org site allows users to verify their specific path.  But I plan on
continuing to work on that to show the full tree once I have the path
exclusivity part of the security model, and also add an ability for users to, if
they need to, import their V-PACK and broadcast the series of transactions to
claim their funds on layer 1.  And I think also it's just very helpful to kind
of be able to visualize.  I think a lot of users understand the UTXO model well.
And the VTXO model, I think, is not too difficult once you wrap your head around
it.  But for me, at least visualizing the tree and the idea of a path to your
funds is helpful.  And so, I hope the site can do that as well.

**Mike Schmidt**: Great.  What's the feedback been from the different teams?
You mentioned you appreciate that they were open source and they were engaging
with you.  Are they on board with developing such a standard, or is there a
competing standard or idea?

**Jon McAlpine**: Yeah, right now the feedback has been positive.  I think
another benefit of V-PACK is that it acts as kind of a second pair of eyes.  So,
right now, both teams are kind of on their own, they're writing the code for the
server.  So, they're writing the code that generates and creates these VTXOs,
and they're also writing the code that kind of consumes those VTXOs.  And so,
there's maybe an increased possibility where if there's an incorrect assumption,
that assumption could be baked into the server side and the consumption side.
And V-PACK hopes to be another set of eyes to run kind of like a cleanroom math
on these taproot trees and things.  So, I think the project is also meant to be
helpful for the teams, in that they'd have a second set of eyes, and I think
they've kind of recognized that.  As far as a competing standard there, there
isn't right now.  The thing to keep in mind is that Ark in general is very new,
so they're changing very quickly.  And so, the VTXOs that they are creating are
changing and are not set in stone.  And so, the idea of a VTXO standard, we're
not to that point yet, I think.  But deciding on kind of a minimum viable
standard to verify VTXOs, I think that's what I'm trying to get at, and I think
there's been some positive momentum toward that.

**Mike Schmidt**: Well, those are my questions.  I'm not sure if Murch, Gustavo
or others have any follow-up.

**Mark Erhardt**: I think I didn't fully appreciate that you were completely
independent from the Ark teams before you explained this.  So, that's pretty
awesome, because there's a lot of complexity in how these trees of transactions
work and what assumptions all are baked in there.  So, having a third set of
eyes is pretty nice.  I was wondering, so there are a lot of covenant proposals
floating around and I think that the Ark teams are especially interested in
TXHASH and CSFS (CHECKSIGFROMSTACK), maybe CTV (CHECKTEMPLATEVERIFY) or
TEMPLATEHASH.  Have you been looking into how that changes your implementation,
if any of them might get adopted at some point?

**Jon McAlpine**: A little bit.  Not in the specifics of each particular
possible implementation, but more broadly, I'd say with covenants, there's less
ambiguity about where funds can be spent.  And so, currently, going back to the
two pillars of security, that second pillar of path exclusivity.  Right now, we
will need to store in V-PACK additional signatures and more data to prove that
there are no hidden back doors to your funds.  Once we have covenants at a high
level, and we can more easily verify that the funds can only be spent to your
address, we still need to kind of traverse the entire taproot tree to verify
that those funds aren't double-spent in another way, but we don't need to store
as much data, because signatures that are not trying to spend those funds to
your address I don't think will need to be stored.  So, I've kind of started
looking in that direction a little bit, but haven't gone very deep on what it
means specifically.

**Mark Erhardt**: Yeah, thanks for your work.

**Mike Schmidt**: Jon, any parting words for the audience, any calls to action
before we wrap up this News item?

**Jon McAlpine**: No, I just want to say thank you again to the Ark Labs and
Second teams.  They've really been very helpful and I hope to continue the good
work.

_Extensions to standard tooling for TEMPLATEHASH-CSFS-IK support_

**Mike Schmidt**: Jon, thanks for your time, we appreciate it.  We're going to
move out of order a bit and go to the Changing Consensus segment, and we'll
start with the first item there titled, "Extensions to standard tooling for
TEMPLATEHASH".  Antoine, you posted to the Bitcoin-Dev mailing list about your
preliminary work, working on TEMPLATEHASH and the surrounding opcodes that
bundle in that proposal, specifically tooling around miniscript and PSBTs.
Maybe just really briefly for the audience, maybe you can recap OP_TEMPLATEHASH,
and how that bundle can achieve additional things in Bitcoin.

**Antoine Poinsot**: Sure.  So, TEMPLATEHASH is a primitive that allows you, in
a taproot script, to commit to the very specific transaction to spend an output.
For people familiar with CTV, it's a taproot-only version of CTV, which allows
us to leverage the modern features of taproot, such as address reusing the
signature hash that is already cached for signatures, which really simplifies,
by and large, the implementations in the consensus code, and also allows to push
the hash on the stack instead of having to verify semantics that were necessary
in CTV, because it was using the OP_NOP upgrade hooks instead of the more modern
OP_SUCCESS upgrade hooks in tapscript.  So, that's what TEMPLATEHASH is.  And
the whole bundle is very similar to the CTV plus CSFS proposal from last year,
except that it's using TEMPLATEHASH instead.  And it's arguing that it's a good
first stopping point for a feature soft fork, because feature soft forks have
been discussed for the past six years without finding real consensus around what
features do we really want to enable, and what new applications do we want to
enable, and what are we wary of enabling?  And there is bias expressivity
levels.

The first one that is a good balance, in our opinion, with Greg Sanders and
Steven Roose, is this bundle, which improves existing proven ways of scaling
Bitcoin, such as Lightning, improving all sorts of payment channels, and also
new promising ways of scaling Bitcoin, such as Ark.  So, that's the tl;dr of the
bundle.

**Mike Schmidt**: Awesome.  And so, I don't have the newsletter handy, but we
covered your initial publication of the idea around TEMPLATEHASH and the
software bundle.  Users can search for that on their own, and I think we had you
on to talk about it.  But now, I guess, as this proposal moves forward, one in
the community might expect things like what we're talking about today, which is
integrate this with some of the tooling and see how that works, right?  And
maybe you can talk a little bit about challenges or ease of integrating
TEMPLATEHASH into miniscript and PSBTs.

**Antoine Poinsot**: Yes, so the goal is, I guess, twofold.  First of all, it
was interesting to me to just go through the process of, let's say we had
enabled these opcodes, and now we need to use them in various protocols and
applications using Bitcoin, then we would have to modify the standard toolings
that we have to work with Bitcoin transactions and scripts.  And so, the tooling
that we have that is standard is PSBTs to work with transactions, and miniscript
to reason about Bitcoin Scripts.  So, I was trying to think through what could
make sense to integrate into miniscript, because you want to first reason about
the script and then you think through what do you need in the PSBT, what new
fields do you need in the PSBT to satisfy the scripts.  So, you want to think
more at the capability level rather than the specific opcode primitives when
you're thinking about new miniscript fragments, which is essentially new
miniscript operations.  And the capabilities that are introduced in the soft
forks are committing to very specific next transactions, re-bindable signatures,
which is the basis on which a lot of the payment channels improvements I
discussed earlier are based on, and arbitrary message signatures.

So, there is an existing type system for miniscripts, where all fragments, all
operations in miniscript have some defined properties that are encoded into
types.  And then, when you want to combine them, you assert that the various
operations are compatible using those properties by leveraging the types.  And
so, there was some work around the type system with thought for the existing
operations.  And these new operations have some properties that do not neatly
fit in the model, so I had to extend some of the type properties.  I don't think
discussing the very specific details of the modifications to the type would be
necessary here.  If you want the details, the auditors can look up the mailing
list post.

But essentially, I think the takeaway is with some small modification, it fits
in fairly nicely.  And also, I learned something about, for instance, the order
of operation for the CSFS opcode, which is it turns out that all the operations
that was chosen by the BIP authors actually conflicts with how miniscript
reasons about the general operations.  I don't think it's necessarily a big
conflict.  I also discussed it with one of the authors of BIP348, CSFS, and I
think we agree that if we didn't want the additional OP_SWAP that was necessary
to work around the order of operation in CSFS, we might as well just change the
type system of miniscript.  At the end of the day, my exploration was just an
exploration.  I didn't want to introduce a whole new type into miniscript.  But
if we were to activate those opcodes, it might be necessary and it's fine, and
CSFS does not need to be changed.  So, I think it's some amount of validation on
the design of those opcodes.

**Mark Erhardt**: Sorry, you said that there would be a lot of OP_SWAPs required
if you just fit an OP_CSFS into miniscript.  I assume that that is because you
either want to modify the message that is being checked with the CSFS, or you
want to modify a key, or sometimes maybe the signature, well, tweaking something
into it, or whatever.  So, in our writeup, we say that there's not an obvious
order in which OP_SWAP would be used less often.  How would fixing the type
system get around this issue?

**Antoine Poinsot**: Actually, changing the order of operations would fix the
issue for the miniscript integration.  It might conflict with other use cases
that required this order of operations, and it turns out that I was not aware,
but the author of the BIP pointed out to me that this specific order was chosen
based on some empirical work he had done.  So, one thing needs one order,
another needs the other order, and it turns out that my thing can just be
adapted to work around it.  So, I think it's better to adapt miniscript if needs
be.  And with regard to your other question of how to adapt it, the issue with
the order is that in miniscript, there is a type, which is K for keys, which can
be any general expression.  And it can be really anything that checks a
multisignature and is a threshold of another set of conditions.  And at the end,
it just spits out a public key.  Then, it will still be a type K, and it will be
supported in my generalistic fragment for verifying arbitrary messages.

An alternative to design the fragments to check the arbitrary messages could
have been to hard-code the public key inside the fragment.  In this case, we do
not need the OP_SWAP.  This is because the type of miniscript depends on where
it takes its arguments from.  It takes its arguments from the top of the stack.
And because the public key needs to be the first argument to a CSFS, and then
there's the message, if you have the message and then the generalistic argument
that precedes it, you cannot give argument to the generalistic message.  So, you
need to have the message first, take the generalistic operation, let it be fed
its arguments, and then you swap the result, because the result is always a
single element.  The way of fixing it is to instead, instruct the defragment to
take its inputs from one below the top of the stack.  And we already have one
such type that does it, which is W, and it just does not exist for the key type.
It only exists for the basic type, which is something like "Check a signature".
That's a basic type, because it always returns 0 or 1 on the stack.  And we have
a W that does the equivalent of this, but takes its input from one below the top
of the stack, and we could just have the equivalent for the key type as well, if
we wanted to.

**Mark Erhardt**: So, basically, the order in which the elements are read would
be changed so that CSFS would always take the public key from the second element
from the top rather than the top, even while there is still a top element.
Anyone else have comments on this topic?

**Mike Schmidt**: I had another question for Antoine, but maybe if he comes
back, we can integrate them.  But maybe in the meantime, we can move forward.

_Hourglass V2 update_

**Mark Erhardt**: Okay, so Hourglass V2, I think that's up next.

**Mike Schmidt**: Yeah, we'll move on to Hourglass V2.  Mike, thanks for joining
us.  You posted an update to the Hourglass protocol on the Bitcoin-Dev mailing
list.  I don't think we've discussed Hourglass on this show before.  So, maybe
it would make sense to talk about the motivation, and maybe just a brief
explanation of what Hourglass V1 was; and then, that will make a little bit more
sense about V2.

**Mike Casey**: Sure, thanks for having me.  Well, the motivation is basically
what to do with the P2PK coins, which are the earliest mined coins before we
switched over fully to the P2PKH, which of course is a hashed variant of that
output type, which does provide it some protection from quantum attackers,
because it is much, much harder to reverse a hash than it is with a
cryptographically-relevant quantum computer using Shor's algorithm to reverse a
public key.  And the public key is in fact what is posted on the P2PK
transactions on the blockchain.  It's particularly onerous for this set because
these are the first coins that were mined on the network, which include
presumably all of Satoshi's coins.  Your guess is as good as mine as to how many
of that set are Satoshi's coins, but the total set is pretty well known.  It's
about 1.7 million BTC in total are part of this set.  And most of them are
pretty much generally regarded as lost.  They were mined at a point in time
where Bitcoin effectively had no price, had no value.  And it is assumed that
most of them were just thrown away as they were just an experiment.  But that
may or may not be the case.  They are found from time to time.  And of course,
Satoshi may or may not still be out there and maybe still has his keys.  So,
nobody knows.

There are two camps on what to do, or historically there've been two camps on
what to do with these coins.  One is probably Bitcoin purist, is to do nothing.
You know, not your keys, not your coins.  If somebody has the ability, they have
the private key, they should be able to spend the coins.  That's the assurance
of Bitcoin.  The other camp say, well, this could be very, very dramatic on the
price of bitcoin and the security budget of bitcoin because of that.  If
somebody were to get it, it would cause havoc.  And it was already assumed,
under most people who joined into Bitcoin later, they operated on the assumption
that was told by everybody who orange-pilled them, "Well, those coins are gone.
They'll never be spent.  Satoshi said, 'Consider those a donation to the rest of
bitcoin's value'".  So, they've operated under that assumption and to say,
"Well, these could come roaring back to life in the hands of new owners", then
it could be very deleterious and it would allow them to effectively steal the
coins.

It's interesting, because both sides are kind of a bit of a violation of the
promise of Bitcoin.  Because the promise of Bitcoin is (a), you will always be
able to spend your coins if you have the keys.  There will be no restrictions,
you cannot be censored.  That's part of the promise.  And the other part of the
promise is, technologically, cryptographically, it's safe.  Nobody can steal
your coins unless you reveal your private key.  So, those two things are at a
conflict, and then we don't know what to do as a group.  And I personally find
the thought of confiscation kind of abhorrent, which would be freezing or
burning these coins and saying they cannot be used after a certain date.  But a
lot of people feel very differently, and they feel that we should do it.  But
the fact is, if we are to do anything with these coins, other than liquidation,
which is the current status quo, if we do nothing, then if quantum computers
ever do become a thing, then they will be stolen.  And the scary part about that
is, we did the math.  These things could be stolen in a matter of three hours if
you pre-cracked all of the keys and crammed every single block full of these
transactions.  You could get all 1.7 million bitcoin somewhere liquid within
three hours, which that could be disruptive.

Yeah, so the original hourglass proposal, it was the simplest thing.  We talked
about it a lot, Hunter and I, and we went back and forth on a bunch of things.
We decided we had to keep it exceedingly simple.  And the simplest thing to do
was just restrict it to one output per block.  This was not our idea, by the
way.  I forget the gentleman's name.  He's in the draft as an acknowledgement,
but he mentioned it to Hunter in Denver as, "Well, why don't you just restrict
the P2PK spends to one per block?"  And I started thinking about that, and I was
like, "But that's amazing".  Because if you restrict it, you're not
confiscating, you're restricting.  So, somebody who has one of these coins, or
one of these P2PK outputs, they can still spend it.  It's just inconvenient
because you can't spend a whole bunch of them at once, you can only spend one
per block.  And so, it creates kind of a secondary fee market based on that; but
one that in the absence of a quantum attack, I would not expect to be heavily
leveraged, because these coins have been sitting dormant for nearly as long as
Bitcoin has been around.  So, you wouldn't imagine there would be much
competition at any one time to start moving these keys all of a sudden.

Also, most importantly, this would be a flag-day activation soft fork out in
front.  There would be plenty of notice for anybody before activated to be able
to move their coins ahead of time before any restrictions put in place.  So, the
idea would be, much like any of the confiscation proposals, to let people know,
"Hey, on this date, this is going into place.  So, if you move anything you have
in this set to some other form of output, there will be no restriction.  You can
freely use them.  However, if you leave them there beyond this date, then there
will be this restriction put in place that will make them harder to move".  But
you still can move them, that is the key.  It is not a total confiscation
because you can move them, there are just restrictions in place to which the
speed you can move them.

So, the original proposal was one per block.  And we did the math.  Roughly
eight months for the 1.7 million bitcoin would be the maximum somebody could
move all of those coins.  So, you go from three hours to roughly eight months.
But a lot of people that we talked to when we socialize this, especially in the
confiscation camp, they said, "That's not enough time.  You could still lead to
a mass liquidation event, because of panic in the market because these things
are flying off".  And that's a lot of bitcoin to change hands in a brief amount
of time.  I mean, I don't necessarily 100% agree with that perspective, but I am
sensitive to it, right, if we're trying to appease people.  Well, okay, so we
revisited it.  We actually initially had a much wider scope, because we wanted
to try to apply Hourglass to not only the P2PK coins, but also the reused set,
the reused addresses, addresses that have been spent from prior.  We looked into
it.  There's no way conceivably to do that, because the only way you could do
that is to track every address that has ever been sent from, through the history
and growing history.  This is an enormous amount compared to the UTXO set, and
will grow forever, and there is no trimming it.  So, it's just not something you
can consider.

But as part of that original proposal, one of the other things we were looking
into, and we discussed it with Peter Todd, you can actually put in a further
restriction on it, so it's not only one output; you put in another restriction
mandating that in any excess of a certain amount, we chose 1 bitcoin, 1 BTC as
the amount, anything in excess of that amount as an outflow from a transaction
with a P2PK input must contain that amount minus 1 as an input back to the
original sending address.  So, what that means is you can take bitcoin out of
it, and there's no use about reusing address, don't even worry about it, because
the public key is already posted, it's already exposed.  So, you change nothing
by having multiple spends on this.  Yes, Murch?

**Mark Erhardt**: Let me jump in there for a moment.  I don't think that's true.
Because now you're making 50 payments and if you're paying to 50 different
outputs, you're tying together all of these 50 other outputs.  So, you're
creating a set of outputs that belong together that is vastly bigger than a
single one.  And so, there is a privacy concern due to the address reuse because
it ties together all of the recipient addresses.  Even if you only do that one
operation, a P2PK input, and sending the rest back to the same output script,
all of the outputs are being tied together.  So, it creates a huge tree of
future transactions that are associated.

**Mike Casey**: Well, yes, I mean, it is somewhat deleterious from a privacy
perspective if you do not use the same path for all of the transactions going
out.  It's not perfectly analogous to it, but it doesn't really bloat anything,
right?  It's just privacy trade-offs, correct?

**Mark Erhardt**: Yeah, it's just privacy.  But when you say it doesn't bloat
anything, well, you go from a single input that's 114 bytes and 1 output to,
well, 50 inputs and 49 P2PK outputs that weren't necessarily -- so, yeah, you
increase the block space you need by about 600 times.

**Mike Casey**: That is correct, it does, but it is temporal.  So, the total
block space is still the same, it's the same amount per block, because it's
pushing it out into the future.

**Mark Erhardt**: But to spend your 50 bitcoin, let's say you start with 50
bitcoin and one P2PK output.  You now need 50 transactions to chip off 1 bitcoin
each time.  And every time, you also need this additional change output that
goes back to the prior.  So, it's not quite, but 50 times more block space to
spend your coin.

**Mike Casey**: That is correct.  But it's spread out over 50 blocks.  So, you
have 50 times as much block space to use as a percentage of, versus 1.  So, it's
actually very close to the same size on a per-block basis.  But you're right; in
total, it does use 50 times as much.  But it's not at one set point in time, 1
block.

**Mike Schmidt**: Mike, how do the fees work here?

**Mike Casey**: Okay, very, very, very good question.  So, I mean, it would
create another fee market, because you would have a separate fee market for
this, opposed to regular fees.  So, if somebody did want to move these, if
nobody else was moving them and it was open, you would submit, you know, it
depends on your time preference, of course, right?  So, in the absence of a
quantum attacker, I think it's a safe assumption that most of these holders who
have been holding on to them since 2010 probably have a fairly low time
preference.  And if that changes, then the value has increased such that 1 BTC
is worth quite a bit more than it was back then.  So, let me just first, the 1
BTC restriction, did I go over that?  So, yeah, so the amount is 1 BTC.

So, yeah, once you get back to the 1 BTC restriction, I would just like to touch
on this briefly.  That level, it is arbitrary, but it's a good Schelling point.
And aside from that, if you backtest it, how long would it take you to move that
in the absence of any other fee competition?  That means you could move one of
these P2PK outputs, which are typically 50 BTC, you could move almost three in a
day.  It would take you about a third of a day to get through all 50 of those,
with 144 blocks in a day, easy to do the math.  So, yeah, so that's the
bandwidth that we're talking about here.  And of course, if you're talking about
fees, it's a function of how much demand on one side, and supply.  So, we've
restricted the supply for these.  You cannot move them.  Under an Hourglass,
it's coded.  Yes?

**Mark Erhardt**: Well, to be fair, this would be announced way ahead of time,
and assuming that people who have a ton of money in Bitcoin are even
superficially paying attention to what's going on in Bitcoin, they would
hopefully hear about this restriction being discussed and planned.  And if they
have the keys, they would just move their P2PK outputs before the restriction
even applies.  So, we're talking presumably, unless people have been really
laying low and not paying attention at all, we're talking only about UTXOs of
people that weren't paying attention or that have been misappropriated by people
with quantum computers.

**Mike Casey**: Correct, and that's an excellent point, Murch.  It's not like
we're just going to impose this overnight, and then everybody's funds are stuck
and they now have to compete.  The goal is to do it with a sufficiently advanced
warning that everybody who wants to move their keys and has access to them can
do that.  And what's really weird is we talk about timeframes and scales.  We
don't really know what the timeframe or scale would be until that that event has
happened.  Now, imagine if Satoshi was among that population, just decided to
move all of his keys, which let's say is somewhere between 600K and 1.2 million,
and just decides to move all those in advance.  Well, that would drastically
change the assumptions.  So, I mean, which is fine, that's why you go through
the exercise.  And the reason I like Hourglass so much better than a
confiscation is in a confiscation scenario, you have now potentially forced
Satoshi's hand.  They, he, she, whatever, Satoshi has to move those coins or
lose them forever, per the protocol, if a confiscation's enacted.  But if
Hourglass is put in place, that doesn't really exist, right?  So, Satoshi's
temporally restricted, but -- yes, Murch?

**Mark Erhardt**: Well, you already mentioned that it would take 38 years to
move all of the coins, and you're talking about 1.7 million.  If the Patoshi
pattern actually is correct, and if Satoshi still has the keys, then 1.2 million
of those coins roughly are Satoshi's.  So, that's temporarily limited to 25
years to move their coins.  No, I think Satoshi, if they still have their coins
and this limit gets consensus, they would move their coins in advance.  It would
be very dumb to rely on being able to do it over 25 years.

**Mike Casey**: Correct.  Well, I would assume so too, but it all depends on how
much Satoshi values his privacy, right?  Because there could be other coins that
Satoshi has, far more than you or I or anybody, that are not part of the Patoshi
pattern, that he mined independently that are not tied to him.  So, I don't know
enough about Satoshi to say what he would or wouldn't do.  But with this, he
would have the option, if he wanted to maintain his anonymity and not move his
coins, to hide in the set of Hourglass-restricted, whenever he wanted to draw
from the pile of coins that he holds and still maintain his relative anonymity,
which is something great.  Yes, Mike?

**Mike Schmidt**: Yeah, Ethan, I want to bring Ethan in, he had his hand up and
he's been patient.

**Ethan Heilman**: I just thought of something while you were talking and maybe
you said it and I missed it, but I was curious, do you limit the amount of fees
that can be paid to a miner?

**Mike Casey**: Yeah, well, that's an interesting part of it.  The total that is
capped out, yes, the fees are limited, and that's a very good point.  The fees
are limited to -- I don't know where I said this in the proposal.  I don't think
it matters for this version.  It mattered in the other version, where it was
50x.  But in this version, it doesn't actually matter what the fees are, because
you're forced to pay the 49, or whatever, the remainder, n-1, back to the
address.  But in the original version of Hourglass, it was a cap; you can spend
no more than half of it on fees to the miners.  Because otherwise, yes, you're
correct, you could just bribe a miner to offload the set, and then you could
actually pay them to take the coin, and then make it all in fee, and then do a
back channel to yourself of a payment.  Then, you're kind of avoiding the cap
altogether.  But in the Hourglass V2 version, I don't think that's applicable,
because you have the forced output back to the original address.

**Mark Erhardt**: Right, you can't extract more than 1 bitcoin from the set,
because n-1 has to go back to the original output script.  So, paying more than
1 bitcoin fees would be possible, but you would be burning money from other
inputs in addition to burning all that you can extract from the P2PK output.
So, it doesn't make sense to pay more than 1 bitcoin.  In fact, it doesn't make
sense to pay the whole bitcoin.  So, it would be something less than that.

**Ethan Heilman**: There's an aspect to this that may solve a different problem,
which is that it seems like if it's not Satoshi moving them, like it's someone
that's broken ECDSA that's moving them, if this break is well known, then the
miners are likely the people who would exploit this break, because if a miner
could steal the coins, they would not mine a block in which stolen coins were
being moved, because it's not incentivized for them to move it, because they
could steal it in another block, so they would drop that and steal it
themselves.  And this is one of the things that's always worried me about
quantum, not just the price, but these sorts of attacks.  And I think this does
a really good job of turning stolen coins into a block reward.

**Mike Casey**: Well, yeah, that's the knock-on effect, which isn't actually the
intended purpose of it.  But if you game it out, it really ends up effectively
as a subsidy.  Because if you have more than one quantum attacker, and remember,
keep in mind, if Satoshi doesn't move his coins, if nobody appreciably does, the
span of Hourglass V2, because it's 1 bitcoin per block, actually goes out over
32 years.  So, it would be a 1 BTC you could pull out of this for 32 straight
years, which is a multiple of how long Bitcoin has existed.  But yes, over that
span of time, you would have to assume if you have one quantum attacker, then
pretty shortly you will have a second quantum attacker of equal capability.  And
when you have at least two, they have to bid against one another in order to
reclaim those coins.  And since we have such a limited amount of throughput,
they have to start bidding more and more for the block space for this specific
type of coin from the miner, meaning more and more of that restricted throughput
is going to be paid out to the miner in fees, and it's not any one specific
miner, it's going to be whoever wins the block, right?

So, what that ends up being is a de facto emission of reuse of whatever coins
that were in here, not intentional, just that's the way that it works out, and
you end up with, instead of having this quantum-attacker risk to Bitcoin, you
now have quantum attackers subsidizing Bitcoin by insuring the security budget
for a long amount of time.

**Ethan Heilman**: Yeah, the risk of a fork catastrophe, where miners don't
build on each other's blocks because they all want to steal the coins.

**Mike Casey**: Well, that was the first thing.

**Ethan Heilman**: But if the coins are still there, if it's a subsidy, then you
address that.  I don't know, that's one of the things that I worry a lot about,
and I do like the thinking about the protocol there.

**Mark Erhardt**: Okay.  So, the interesting thing here would be that usually,
if there's a humongous fee, it would incentivize remining the prior block
because you want to collect the fee instead.  But because if there are multiple
quantum attackers that are putting transactions in every block to chip off that
1 bitcoin from an existing output script, they would be presumably roughly
bidding the same fee on every block.  So, you would have the same incentive to
move forward versus remining the prior block.  So, the concern doesn't really
apply here.

**Mike Casey**: Exactly.

**Mike Schmidt**: Mike, anything else we should know?  We kind of went pretty
deep on there, but maybe there's perhaps also more.

**Mike Casey**: No, it's pretty wide and varied with the game theoretical
knock-on effects, but at its core, it's a very simple process.  The one thing I
would also say is the biggest complaint I've got, other than hardcores who say,
"We cannot touch this", the biggest complaint I've got is just that it's
arbitrary at 1 BTC.  But I think it's a great Schelling point, it serves a good
purpose for clear communication of the concept.  And if you do the math for any
gameable actual scenario, it works out to a good value.  So, I don't see any
other reason to change it, and just keep it simple.  And my hope with this is
that I don't see us getting consensus for a confiscation fork without having a
hard fork, which I don't want to happen, if we can avoid it.  So, this is put
forth as something that maybe we can all agree is a decent compromise between
the two camps of confiscation and liquidation.  So, that's my hope.

**Mark Erhardt**: Hopefully, one of the last few questions, but what have you
been thinking about the deployment timeline?  The draft that I read doesn't have
a deployment timeline or even a recommendation of how long out to schedule this
deactivation of this rule.  What are your thoughts on this so far?

**Mike Casey**: I mean, open question, I would say without a doubt, a minimum of
six months to give people enough time to be able to move their funds.  But
possibly longer.  And I'm open to opinions on that.  But I mean, it would be a
standard.  You would do a BIP9 flag day, "Well, this is when we intend", and
it's n number of blocks from when it becomes approved, right?  That's how I
envision it.  But again, I'm open to suggestion on timing, but yeah.

**Mike Schmidt**: Sorry, a BIP9 flag day?  So, you mean something like speedy
trial?  Because usually BIP9 is activation when the signaling is high enough.

**Mike Casey**: Yeah, with an offset.  So, everybody would activate or signal
activation, but that's just the lock-in for it, and it doesn't actually access
until the set determined period after it actually ratifies.  Yeah, that's what I
would suggest.  But as to the length of time, that's up for debate.  Quantum is
still viewed by many to be very, very, very far out, but advancements are made
all the time.  So, the sooner we can come to agreement on when we should do
something, the sooner we can act.

**Mark Erhardt**: Yeah, thank you.

**Mike Casey**: Thank you.

**Mike Schmidt**: Thanks for joining us, Mike.  You're welcome to hang on or
you're free to drop.  A couple more quantum items here.  These two are somewhat
related to each other.  And there was a thought to put them potentially together
as one item, but we split them off.

_Algorithm agility for Bitcoin_

The first one titled, "Algorithm agility for Bitcoin".  And we have Ethan, who
wrote to Bitcoin-Dev mailing list talking about cryptographic, specifically,
algorithm agility for Bitcoin.  Ethan, what are you getting at here?  And I know
we just talked about quantum, but you have ideas here about how this is
potentially advantageous, even regardless of quantum.  So, maybe you want to
talk about this cryptographic algorithm agility.

**Ethan Heilman**: Thanks.  This is really motivated by the question of how
Bitcoin can be safely used over long time horizons.  So, a human lifespan, let's
say 75 years.  Someone buys bitcoin when they're 20, they put it in a safe
somewhere, the estate planning is handling it when they're 90.  Would those
coins still be safe over a 90-year period or over a 75-year period?  So, the
idea is to think through, given the history of cryptography and the fact that
cryptographic algorithms weaken with age, how someone could put their coins down
somewhere, and those coins, they don't touch them, and 75 years, they take the
coins out and the coins are still good.  And I think this is a really important
question for Bitcoin, because if people are using bitcoin as a savings account
or to put wealth in, thinking on these long time horizons is actually really
important to both communicate the value of bitcoin and for bitcoin to still have
that value.

Part of this is motivated by quantum, as quantum is the current big threat to
the digital signatures used in Bitcoin.  But it's also motivated by the fact
that almost every single cryptographic algorithm we've had has weakened with
time.  And so, there may be classical attacks on the elliptic curve cryptography
use.  I want to be really specific in the cryptography I'm talking about.  I
believe that for most likely cryptographic attacks, Bitcoin can survive the hash
functions being broken.  If someone breaks the collision resistance of SHA256,
that's actually a pretty easy fix.  The miners are incentivized to go along with
the fix, and you just have additional data next to the chain that uses a new
hash function for everything, and the old chain; and you soft fork this in so
that the new consensus change is just, "Reject blocks that don't have this
additional data", similar to how segwit works.

So, I'm not very concerned with breaks in SHA256, because I think that the
recovery story is actually pretty good there.  What I'm concerned with is the
signature algorithms, because if, say, ECDSA or EC-schnorr were to be broken,
how do you prove that you own an output?  It's almost entirely through
EC-schnorr.  And if that's broken, it becomes extremely difficult to
authenticate; or basically, the ownership of Bitcoin outputs is now no longer
cryptographic.  And I say I own it and someone else says they own it and we can
both provide signatures, how do you tell who owns it?  And that seems like
that's the soul of Bitcoin, like that's really the value that Bitcoin provides.
And if that was broken, that would be really, really bad for Bitcoin.  There
might be some ways to survive this with proof of seed phrase, but it would be a
very, very hairy situation to deal with.

So, what I am proposing is a way of having a redundant signature scheme, such
that you put your coins on a seed phrase, you bury it in a coffee can in your
backyard, not suggesting anyone do this for their seed phrase, it's a bad idea,
but for the scenario, maybe you put in a safety deposit box, and there are
multiple signature algorithms to spend it.  And so, you use schnorr like you do
every day, but then schnorr gets broken, you don't move the coins, 50 years go
by, someone looks at it and is like, "Oh, schnorr's totally broken".  But you
can also spend these coins with another signature algorithm.  And because you
can spend those coins with another signature algorithm, the coins can be then
safely moved to an output that is secure and doesn't use EC-schnorr.

The really important thing to understand about how this works is that it uses
the tapleaf tree, where you can have multiple scripts that are all in a tree, in
a taproot output.  And so, it's not that you have to spend with a new algorithm
and the old algorithm.  It's actually an 'or'.  You could spend with schnorr, or
you could spend with, like, imagine Fancy Algorithm, right?  You could spend
with either one.  So, if you're just spending these as normal, you're not
incurring any cost.  But because they're at the bottom of this merkle tree in a
taproot output, as long as you haven't revealed the public key for schnorr, no
one can spend it even if schnorr is broken.  This does require BIP360 or
something similar to BIP360, because if you could break schnorr, you could
actually just spend through the keyspend path in taproot.  But assuming that
either BIP360 is out there, and by BIP360 I mean P2MR (pay to merkle root),
which is basically P2TR, but with the keyspend path cut off, or the keyspend
path has been disabled in taproot, which is actually really similar to BIP360,
if either of those are true and we have an additional signature algorithm, you
could employ this.  If the current signature algorithm is broken, you could use
the new signature algorithm to then move everyone over to a new output.  Those
that don't move over will still be protected.  And using this, we can rotate the
signature algorithms that are used in Bitcoin as they're broken.

If you want to get really long-term about this, be long-termist about this,
imagine Bitcoin for 200 years.  I think that it's hard to think about things on
this timescale, but I do think it's a valuable mental exercise.  We'll probably
have multiple signature breaks over that time.  So, we need a mechanism to move
from one signature to another that doesn't get us in the situation that we
currently are with, like, P2PK outputs, where it's like, do we confiscate them,
do we not confiscate them?  So, the main idea with algorithm agility is, what
can we learn from where we are now so that we can make these transitions to new
signature algorithms smooth and safe?  And also, if someone just buries an HD
seed or buries a secret somewhere or sticks it in a safety deposit box, in 75
years when their estate takes over, they don't have a security problem, they can
move those coins safely.

**Mike Schmidt**: Ethan, it sounds like the idea is that there basically would
always be two.  Is that the preference; two, not more than two, not less than
two, two?  And so, when one gets bad, then the combination would be the second
one, plus a third one potentially would be then the standard moving forward, or
maybe talk a little bit about how that might work.

**Ethan Heilman**: Yeah.  You would always want at least two, so that if one's
broken, you can have one, like a transition, a migration public key, and a
migration algorithm.  The way that I've been thinking about it is that the
secondary one, the migration one, for the 75-year use case, you really want that
one to be secure.  You don't want there to be two breaks, because then the
person that buried their HD seed in their yard is in trouble when they dig it up
in 75 years.  So, you want a cryptography for the migration key that probably
will be the same over time.  And then, you have the sort of new, everyday
signature algorithm, that occasionally gets replaced when it weakens with a new
everyday signature algorithm.  And we do have some signature algorithms that are
very inefficient but are thought to be extremely secure that would make good
backup algorithms, specifically hash-based cryptography.

You could use SPHINCS for this, or you could use SHRINCS for this, which is like
a stateful version of SPHINCS, which is significantly more efficient than
SPHINCS, and also has the property that you can treat a SHRINCS public key as
either a SHRINCS public key or a SPHINCS public key.  Now that I'm saying these
words out loud, it's a bit of a tongue-twister.  And so, the nice thing about
that is that almost works as like a third backup.  Like, you have two signature
algorithms, SHRINCS and schnorr.  Schnorr gets broken, maybe it's quantum, maybe
an AI discovers some new elliptic curve approach that breaks it.  And you go to
use SHRINCS, and SHRINCS is almost definitely going to be secure.  But let's say
there's some discovery that somehow it's not secure.  Now, using your SHRINCS
public key, you can fall back to a SPHINCS signature.  So, I guess SPHINCS is
the backup and then SHRINCS as the everyday algorithm.

**Mike Schmidt**: Yeah, that example makes sense.  And I know you're not
necessarily proposing this exact scenario, but I think it's helpful for folks to
wrap their heads around it.  So, we have schnorr now and we can do fancy things.
But people are worried about that breaking, so maybe they would use something
dumb, like a hash-based, right, as like their panic button that they push.  And
then, maybe the fancy signature that comes around is something more like
lattice-based, where my understanding is that maybe we get some of the
interesting benefits of the crypto that we enjoy now.  And then, I guess that
would be sort of an example of how this could play out over the next few
signature schemes?  I know you're not proposing this, but I'm just trying to
wrap my head around it practically.

**Ethan Heilman**: Yeah, I think that's exactly it.  We don't want to lock
Bitcoin into SPHINCS and then have to give up a whole bunch of things, like
signature aggregation.  And I know there's ways to do signature aggregation with
SPHINCS, but it's messy.  You really would want something that's like a drop-in
replacement for schnorr, but we're not there yet.  And so, it's like you have
two castle walls, and you have the outside castle wall that people come through
all the time, it's very useful.  And then, you have the last castle wall where
everything's gone wrong.  There's one gate in it, it's a real pain to get in
there, but if you're at the last wall, you're really happy it's there.  And if
the outside castle wall gets breached at some point, it's cool.  You can build a
new one out there with all the nice features that you want.  But you'll always
have that final wall to fall back to if everything goes wrong.  And I really
think we need that final wall if we're going to think of Bitcoin as not like a
30-year project, but as a 100-year project, or even longer.

**Mike Schmidt**: Mike?

**Mike Casey**: Yeah, thanks.  Yeah, I totally agree with everything you've been
saying.  I just wanted to point out something as well, that P2MR offers as a
structure.  If you have multiple algorithms there, you also have the ability to
have a leaf that requires two different algorithms or some sort of hybrid of
that, which the advantage it gives you there is we're, in some cases, dealing
with novel cryptography here.  And there's a chance it could be
quantum-vulnerable or even classical-vulnerable, whatever we're injecting into
the system.  So, if you have a leaf that allows you to rely on both a new crypto
scheme and, say, schnorr, it gives you at least the resistance to any of those
other traditional attacks that schnorr does, if it requires both.  And since
schnorr is such a light algorithm, it doesn't really add much extra to the
weight of it versus some of these PQC (post-quantum cryptography) schemes.  So,
that's just another little avenue of this.  But yeah, I followed Ethan's post.
It was great, phenomenal.

_The limitations of cryptographic agility in Bitcoin_

**Mike Schmidt**: Ethan, maybe this is a good segue and you can help us, because
we don't have Pieter here.  And I know Pieter wrote a different post, but it was
in the similar vein of this algorithm agility.  And so, do you feel comfortable
summarizing what you think his -- can you steelman his stance?

**Ethan Heilman**: So, I saw his post. his post is called, "The limitations of
cryptographic agility in Bitcoin".  And I was like, "Oh, I'm going to disagree
with this".  And I think that I largely agree with it.  I kind of see it as kind
of in the same direction that I was trying to go with, with algorithm agility.
And I'm looking at it now.  I think his main point was that we don't want a
fragmentation of cryptographic algorithms, which is something I really agree
with.  And my attempt to steelman his post, which I'll just give you my own
views, because it's pretty much the same as Pieter's on this; if we just had
people adding their own signature algorithms to Bitcoin and being like, "Well, I
want Fancy Algorithm 1", and someone else is like, "I want Fancy Algorithm 2",
and they can't agree, so we add both, this would be bad for security and it
would be bad for user experience and it would be bad for wallet developers,
because do the wallets support all of these?  Is this a privacy leak?  The
wallets are probably not going to support a bunch of different signatures, and
people adding their own signatures to Bitcoin means that people will likely get
it wrong.  Or you go to dig up the HD seed in the backyard after 75 years and
then you can't figure out how to spend it because it's some cobbled-together
algorithm that grandpa thought was cool 75 years ago.

So, I think that we have to be very exact in this, that adding signature
algorithms to Bitcoin should be taken very seriously and very carefully, and
that we should make sure we understand why we're adding it.  We shouldn't just
add it to make people happy.  We should add it because it solves a real security
problem, we've heavily tested and looked at this algorithm.  And when we go to
wallet devs and be like, "Listen, you've got to build this.  There is a real
desire from users for it", so that the wallet devs feel like they're not wasting
their time and that we haven't come to them, like, five times last year and been
like, "You've got to add a new signature algorithm".  So, I really agree with
almost everything that was said in there.

**Mike Schmidt**: Well, it seems that Pieter just takes it one step further.
You both agree that maybe everyone shouldn't be rolling their own schemes using
things like OP_CAT, or something, and trying to come up with their own way to
secure things.  And obviously, there's the ecosystem tax that that puts on
wallet developers, etc.  But I think Pieter seems to be taking it one step
further and saying like, "Even if there's two, everyone's going to want the
other people to use the one, right?  There's going to be camps and they're going
to want to force people on their scheme".  Am I understanding his perspective
right?

**Ethan Heilman**: I think so.  I think every time there is a discussion of
like, "Should we add a new signature scheme to Bitcoin?" there's going to be a
lot of debate around that.  I personally don't see that as a bad thing.  And I
don't think that we should solve the debate by just letting everyone have the
scheme that they want.  I think the community has to make hard choices.  And I
think if the community can't make hard choices on this on a timescale long
enough, and we only have one signature scheme on a timescale long enough, that
signature scheme will be broken.  So, I think there's actually a strong forcing
function for the community to make these hard choices.  But I think it has to be
a hard choice.  It can't be, "Oh, we'll just let any signature scheme in".

**Mike Schmidt**: Is it a hard enough choice that it's only moving from one
signature scheme to the next single-signature scheme?  I guess, that's where I
see the delta, is you're saying it should be hard.  But I think from what I'm
reading from Pieter, he thinks that having more than one is the issue.  If you
add one, you turn off the old one, right?  That's where I'm seeing the delta.

**Ethan Heilman**: Yeah, I think that's my point of disagreement with Pieter.
Although I feel like he says that he's not arguing that Bitcoin should turn off
the old one, he just thinks that that's likely.

**Mike Schmidt**: Fair.  Yeah, he's not saying that; he's saying people will say
that, I guess, yeah.

**Ethan Heilman**: Yeah.  My personal view on both how this will work and how
this should work is that at least with scripts that use ECDSA or schnorr, I
think we should still allow those opcodes to be used, and that we shouldn't just
turn them off, even if they're insecure; similar to how we don't turn off SHA1,
even though SHA1 has collisions in it.  I do think that we want at least two
secure signatures at any one time, where one of them is thought, "This will not
be broken on a 100-year timescale", and one of them is thought, "This is a
really useful signature", but it's more like schnorr, where it might work for 30
to 40 years before being broken.  I just made those numbers up, I should be
clear.  No one really knows how long schnorr will last, but elliptic curve
cryptography is currently being phased out, given its age.  And so, we don't
really know, but I should be careful what I say there.  We don't actually know
when schnorr will be broken.  There's the threat of quantum computers, there's
also the threat of classical attacks and new mathematics.  But I think that most
cryptographers would imagine that SPHINCS would last significantly longer than
schnorr.  And so, I would advocate for two signatures so that Bitcoin can last
long term.

My perspective here is actually motivated by something I used to say.  I used to
say, "If elliptic curves gets broken, Bitcoin's doomed, so we shouldn't think
about that".  And I said that for years.  And then, one day I thought about it
and I felt bad about myself having said that.  And I was like, "I should turn
that around.  What can we do to ensure that Bitcoin survives if elliptic curves
get broken?"  And so, informed by that perspective, I think we need at least two
signature algorithms.

**Mark Erhardt**: It's been a while since I read that thread, but my
understanding was that Pieter was just basically expressing, when people have
doubts about cryptographic assumptions and therefore push for one or another
signature scheme, the problem is that they're not going to say, "Oh, if you want
to trust that, that's fine, but I really would like this other scheme to be
used".  But rather, you get into a situation where the people that have strong
feelings about the cryptographic assumptions are going to want everyone to have
the same cryptographic assumptions as them.  And I think he was mostly opening
up the debate about what social dynamics would exist when there are multiple
cryptographic assumption sets among the population of Bitcoin users, and how
that could be rectified.  I guess even if you say, "Well, let's just combine
both signature schemes and require that both are relied upon", then you're still
saying, "Well, I want everyone to use my cryptographic assumptions, that we need
the security of both these cryptographic schemes".

So, I don't know if that's the whole point Pieter was making.  It seemed pretty
complicated, but I think the main point is if there are different sets of
cryptographic assumptions, you're not choosing and picking when you introduce
all the signature schemes, but you force all of the cryptographic assumptions on
everyone, because if some people secure their coins with Fancy-sig Algorithm,
then everybody is trusting that their coins are secured by Fancy-sig Algorithm.
And vice versa, if people don't want to move over because they don't trust
Fancy-sig yet, everyone has to trust that the old algorithm continues to be
secure, because so much of the supply is secured by that, right?  So, I think
that's the point he was trying to make.

**Mike Schmidt**: All right.

**Ethan Heilman**: Yeah, I mean that makes a lot of sense.  And I think that
Bitcoin as a whole should have a set of cryptographic assumptions that we all
agree on.  And where I want to move us to is a set of cryptographic assumptions
where we have a backup algorithm where, if everything goes wrong, we can fall
back to that.  And then, we have an algorithm that is convenient and everyone
can use.  There is this whole risk that we are in currently because we don't
have that, where basically what Hourglass is trying to solve, which is like,
there's this enormous risk that if you don't turn off the older algorithm and
someone continues to use the old algorithm, if it's like one person, like I
could do some really, really bad signature scheme in Bitcoin today using like
SHA1 or something, and no one should trust that.  I can do that, but I'm not a
risk to Bitcoin because if I do that with a tenth of a bitcoin, who cares,
right?  But it's when you have large groups of holders that don't agree on
cryptographic assumptions, you do have this very dangerous situation.  And I
think we need standards and to work with wallet developers so that as we
transition to Fancy-sig, or whatever new signature we want, that we don't end up
with two camps, that we always have one camp.  And I think there's an enormous
amount of work here that I don't want to pretend doesn't exist.  But I see
Bitcoin being around after we're all gone as something that is important and
valuable.

**Mark Erhardt**: Right.  And I think this is whole debate is a meta comment on
the quantum fears right now, because there is this set of people that have been
arguing very loudly that Bitcoin should move to new cryptography faster rather
than slower, because of the perceived risk of cryptographically-relevant quantum
computers.  And this is basically exactly the scenario, where people are now
trying maybe to push for lattice-based signature schemes that have had a lot
less money secured by them in the past, and maybe it seems like dangerous new
cryptographic assumptions to some people.  Whereas others feel, "Oh, not having
quantum safe signature schemes is the bigger risk".  And we get this social
dynamic now where these different camps are pushing for their own interpretation
of the work.

**Ethan Heilman**: One thing we talked a lot about with BIP360 is sort of a
worst case.  And we designed BIP360 to handle the worst case, where imagine that
the quantum threat becomes very real.  Like, no one's stole funds yet, but it's
seeming more and more likely that it's getting there.

**Mark Erhardt**: Like, they actually factored 21?

**Ethan Heilman**: Exactly.  We got to 21, maybe they even factored a larger
number.  You know, we're not in the current situation where there's disagreement
about it being threat, it's really a threat.  An enormous amount of work gets
put in and we move to, like, a lattice signature scheme.  And then we're like,
"Oh, thank God we moved here.  The quantum computers can now break things, but
everything's good".  And then, just as quantum computers become practical and
breaking Bitcoin public keys, someone discovers a classical attack on the
lattice scheme.  And it's like, "Oh, that is the absolute worst case, because
now we have to move to a new scheme", and all trust has been lost.  Like you
said, this scheme was good, and then it turns out not to be, at the worst
possible time.  And so, a lot of this algorithm agility stuff is motivated by
discussions that we had with BIP360, where it's like, how do we pick the backup
algorithm that we're 100% sure of that that won't happen to, so that we can do
this transition without that worst case happening?  And I think that some of
the, "Just move to lattice like yesterday, bro", is like, we have to be careful.
It's not just that there are quantum risks.  There are also risks of moving too
quickly, and there are risks of moving too slowly, and we've got to manage those
two risks and not view one risk as not there.

**Mark Erhardt**: And the third one being it becomes unusable due to block
space.  I mean, if we just go with a hash-based complicated scheme like SPHINCS
or SPHINCS+ or whatever, and suddenly public keys are 3,000 bytes and signatures
are 8,000 bytes.  And, I guess we could have another expense extension block and
then everybody puts spam there.  That's the third dimension, like how much block
space are we willing to trade off?  It's a big pile of trade-offs.

**Ethan Heilman**: Yeah.  I mean, I think with SPHINCS, you would be in trouble.
You really only want to use this as a last wall.  The really cool stuff with
SHRINCS, although it hasn't been looked at as much as SPHINCS, is that because
it's stateful, it has like 380-byte signatures and 32-byte pubkeys.  So, you
could probably use it, it wouldn't be that bad.  But my ideal is that we get
SPHINCS or SHRINCS as the final wall, and then a SQISign becomes performant, and
now we have 100-byte quantum-proof signatures that we can do all sorts of fancy
stuff with.  We're not there yet.  But I do want to give things time.  I want to
get us to the point that we have the final wall, but then also give the
community time to improve the performance and shrink the size of post-quantum
signatures.  Mike, you had your hand up for forever.

**Mike Casey**: Yeah, thank you.  This is actually going back to Pieter's point
on the externalities of somebody else using a weaker cryptographic scheme and
being compromised and losing their keys, and that affects you negatively.  I
just would like to point out a shameless plug here.  It's not totally trustless,
but facilities exist like MARA's Slipstream, which would allow you to submit
your transaction privately.  And unless the transaction's orphaned, as long as
MARA doesn't steal your key, then it's not at any risk of attack until it's
mined.  So, there is a world with the use of private mempools that it can be
broken, but still, we can migrate over to something secure by using private
mempools in that manner.

**Mark Erhardt**: Well, that's a terrible crutch, though.  We're replacing
cryptographic security with, "Trust me, bro".

**Mike Casey**: Better than nothing!  But yes, point taken.

**Mike Schmidt**: Well, it was a great series of conversations, but I think in
the interest of time, we should probably move on with the rest of the
newsletter.  Ethan, you're welcome to hang on and chat a little more with us if
you'd like.  But if you have other things to do, we understand, and you're free
to drop as we move through the rest of the newsletter.

**Ethan Heilman**: Thanks so much.

_Draft BIP for expanded `nVersion` nonce space for miners_

**Mike Schmidt**: We're going to move back to the News section, and we're going
to talk about the item titled, "Draft BIP for expanded nVersion nonce space for
miners".  This is a Bitcoin-Dev mailing list post from Matt Corallo, proposing
to increase the miner usable nonce in nVersion from 16 bits, which I believe
BIP320 designated, to 24 bits.  We have Antoine back and also Murch to help out
with this.  And maybe I'll punt it to Antoine.  Antoine, this nVersion field was
originally used as an integer for versioning blocks, correct?  And then, after
v2, those bits were then shifted to be used by BIP9 for signaling, and then some
of those bits were carved out with BIP320, and now Matt is proposing to carve
out more of those bits.  What are the miners doing with these bits that we need
to start carving out more and more for them?  And is that timeline that I
roughly outlined correct?

**Antoine Poinsot**: I think it's roughly correct.  I think the minimum version
is actually 3 or 4.  I need to go check that real quick.

**Mike Schmidt**: Murch is saying 4.  Stack Exchange answer right there.

**Antoine Poinsot**: Boom, nice!  Okay, so it's actually 4.  So, it means that,
well, there's a number of values that cannot be used anymore.  It was
transitioned to signal for voice-concurrent deployments for soft forks.  There
are 29 bits available in the version field, provided that we respect the
existing constraints, for deployments.  However, well, first of all, it's a lot
more than we appear to need.  We don't have a lot of soft forks happening in
parallel.  What we must say also is you can have one soft fork; as long as it
starts before the other one is completely done and removed, they can't use the
same bit number.  So, even if they don't happen exactly at the same time, we
still need a few of these bits.  Nonetheless, it seems to me, and that's my
personal opinion, that as Bitcoin matures, consensus changes are becoming less
and less frequent, and so it's fine to have less bits available for concurrent
deployments.

So, coming back to our discussions back when we discussed the BIP54 and
locktime, the way ASICs work is that they can only mine the header of a block,
and they have a controller on top of the ASIC that is feeding new jobs.  And the
controller is grinding, for instance, the extraNonce, which is in the scriptSig
of the coinbase transaction, re-computing the merkle root and feeding a new
header in the ASIC.  And the ASIC rolls the nNonce in the header and rolls some
of the bits in the version field, and then needs a fresh job.  With only 16 bits
in the version field, that with the 32 bits of nonce, that's 48 bits of free
work for an ASIC, which is going to be exhausted after 280 TH (terahash), I
think, if I remember correctly the figure.

**Mark Erhardt**: That is correct, I also calculated that.

**Antoine Poinsot**: And that's less than what many miners nowadays can do in a
second, which means that it's starting to put pressure on controllers to feed
jobs to the ASIC for more than every second.  And so, the natural tendency of
this is that your controller is starting to become a miner as well, because it
needs to grind the extraNonce and needs to recompute the merkle root, which is a
lot more hashing than is required to just grind the headers, and then send the
fresh jobs.  And currently, controllers can be very cheap boards, they don't
need to be computationally expensive.  And it would be really annoying to have
ASICs do these operations themselves, or have the controller become essentially
an ASIC itself.  However, miners have another field that is loosely enforced by
consensus but with some flexibility, and that's the timestamp.  And so, it turns
out that some commercial real miners some of the links in the proposal point to
-- what's the name of these small miners that individually run the pleb miner
stuff?

**Mike Schmidt**: The Bitaxe?

**Antoine Poinsot**: The Bitaxe, yeah.  So, it was a discussion on the Bitaxe,
but it actually points to some of Intel's really beefy miners that started
rolling the timestamp fields.  So, there are ASIC designers out there that are
not involved in the Bitcoin community that have started grinding timestamps.
And it's not ideal, because obviously we have consensus restrictions on
timestamps, but it would be better if miners didn't start skewing the time of
blocks; especially as we have free, well, let's say unused space in the version
field that would better serve this purpose than the timestamp field.  So, this
proposal from Matt Corallo is to standardize the use of version bits that miners
could be doing anyway.  It's in no way prevented by consensus, but as a norm, we
only allowed 16 bits to be used in the version bits, and so miners started using
the timestamp instead.  And so, Matt was like, "We should tell them to use the
version bits instead, rather than skew the timestamps".

**Mark Erhardt**: Right, let me try to give a bigger overview again.  So, miners
need entropy in the blocks in order to go through tons of candidates in order to
find one that hashes to a very low number, which makes a valid block.  So,
Satoshi included the nonce field there, which only had 4 bytes and 4 bytes is I
think enough for 4 billion candidates.  And you can do that on a laptop these
days.  So, at some point, we allowed using 16 bits of the version.  Well, first
we redefined 29 bits to be used for BIP9 version flags for soft fork
development.  But then, we realized that we would never have 29 soft forks in
concurrent or parallel deployment closely together, and we don't need 29 bits
for that.  So, we use these 16 bytes since BIP320 to have extra nonce space,
extra entropy, where miners could now go up to 280 TH per second without
touching the timestamp.  And now, it would be instead 24 bits of the nVersion,
which leaves us only 5 signaling bits for soft fork activation.  But that would
bring us up to 72 PH (petahashes) per second per block candidate, where I think
that's pretty far away from what individual ASICs are still doing, because the
whole network is only up to, was it 1 YH (yottahash) now?  And so, that's like a
140th of the entire network right now.  That's not something individual ASICs
can do.  So, now we would be able to maybe have a clock on ASICs that is
actually accurate and it goes through block candidates with the timestamp set to
the actual time.

I think so far, ASICs don't actually manage their own timestamps because for the
most part, they just work with whatever the job provided, because most blocks
are some range of seconds off from the actual time, just lagging behind
somewhere between 10 and 30 seconds, just how long the ASICs were noodling on
the jobs they had.  But now, if we declared the timestamp to be hopefully mostly
accurate, ASICs could just switch over the timestamps once per second and
continue noodling on the same job until they get a new job, by using the 24 bits
from the version.  And the 32 bits from the nNonce would give them 56 bits,
which is 72 PH per second, and the ASICs would never run out of work.

**Mike Schmidt**: So, did we do it?  Did we cover it?

**Mark Erhardt**: I mean, so far there's been one reply on the mailing list,
from Antoine.  And there is now a BIP draft, which I haven't read yet.  It's on
my to-do list.  So, yeah, between the three of us, we have the whole
conversation here, if Matt were here!  But it makes sense.  I'm a little
worried, there's so many soft fork proposals right now.  We haven't had many
signaling in parallel, but if all of these people were saying, "Well, why are we
not signaling for our current soft fork proposals?" we might actually run out of
the 5 signaling bits.  But in that case, we could also come up with smarter
schemes where we use a combination of bits or reinterpret how the bits are used,
or whatever.  But anyway, this seems at least worth talking about.  I haven't
seen any pushback on it yet.

**Mike Schmidt**: Antoine, anything else from your perspective?

**Antoine Poinsot**: No, I wish we could have more feedback from other people,
but it seems to be well received.  At least my implementation on Bitcoin Core
has received some reviews.  That's good.

**Mike Schmidt**: Excellent.  Well, thanks for hanging on and jumping back on,
Antoine.

**Mark Erhardt**: I also notice we should probably put BIP320 at least.  It's in
draft.  It should probably be deployed.

**Mike Schmidt**: All right.  Go ahead Antoine.

**Antoine Poinsot**: BIP320 is not enforced by Bitcoin Core though.  Bitcoin
Core would still warn about these bits.  So, BIP320 said that you shouldn't warn
about them, and the implementation was closed because of reasons.

**Mark Erhardt**: So, do we currently warn all the time about unknown soft forks
being deployed?  I thought someone turned that off, but okay.

**Antoine Poinsot**: Yeah, in the GUI, because there was spurious warnings in
the GUI, but I'm pretty sure you would still have the warnings on the
getblockchaininfo warnings list and in getnetworkinfo list as well.

**Mark Erhardt**: Interesting, okay.

**Mike Schmidt**: Well, that wraps up News and Changing consensus.  We can move
to Releases and Notable code changes.  We have Gustavo, thankfully, back with us
this week, so Murch and I don't butcher these too bad.  Hey, Gustavo.

_Bitcoin Core 28.4rc1_

**Gustavo Flores Echaiz**: Hey, thank you, Mike.  Thank you, Murch.  That was a
great discussion.  Now let's get ahead with the Release and Notable code and
documentation changes section.  So, on the Releases this week, we have the same
as last week, Bitcoin Core v28.4, the first RC for this series.  You can check
out the RC for additional feedback to the maintainers.  And this is a bug fix or
a maintenance release, so it contains the wallet migration fixes that were added
in v30.2 and were backtracked to v29 and also now v28.  It also removes a DNS
seed that was reviewed and considered unreliable.  An RCv2 is expected over the
next few days.  There's already some GitHub activity signaling that a second RC
for this version will come soon.  Any thoughts here?  Perfect.  Oh, yes, Murch,
please.

**Mark Erhardt**: Not on 28.4, but I just thought it would be a good point to
mention that v31 is in the making.  Feature freeze happened a little while ago.
The branch off point is coming up very soon and we're expecting Bitcoin Core v31
in April.

_Bitcoin Core #33616_

**Gustavo Flores Echaiz**: That's awesome.  Thank you, Murch, for adding that.
So, now we move forward with the Notable code and documentation changes.  We
have about 12, 13 different PRs this week.  So, the first two are from Bitcoin
Core.  The first one, #33616.  Here, there's a check that is now skipped when a
block reorganization happens and confirmed transactions re-enter the mempool.
So, this is specifically about ephemeral dust or ephemeral transactions that get
spent in the same block they get added, and are usually broadcasted as 1p1c
(one-parent-one-child) packages.  However, when they're brought back into the
mempool after a block reorganization, every transaction is brought back
individually rather than as a package.  So, when this check existed before this
PR, it would see that the transaction, that the parent wouldn't be spent in the
same block, because it would only see the transaction individually, and it would
reject it by relay policy.

So, what this PR does is simply remove that check so that these transactions can
come back into the mempool after a block reorganization without getting
rejected.  Yes, Murch?

**Mark Erhardt**: Remove the check only in the context of a reorganization.  So,
this is when you have the chain tip A that is at a height 100 and then chain tip
B finds a block.  There was a block B also at height 100 and now there is a
block 101 on chain tip B.  Your node would now remove block 100 on the A chain
tip and then add block 100 on the B chain tip and block 101 on the B chain tip.
And in that brief step between removing block 100 A and adding block 100 B, all
transactions are pushed back into the mempool from block 100 A, because they're
unconfirmed again, right?  And in this situation, we would throw away the
creation of the ephemeral dust, because the ephemeral dust spend check
(CheckEphemeralSpends) would be applied here, even though the transactions are
not seen as a package, but individually.  So, only during the reorg, this check
is not.

**Gustavo Flores Echaiz**: That's exactly right.  Thank you, Murch, for adding
that extra explanation on the process.  And this is just about transactions such
as 1p1c.  But if a miner was receiving transactions out of band and skipping
relay policy, this could apply to other types of transactions, right?  The PR
author gives an example of a chain of ephemeral dust, that spend each other in
the same block.  So, that's an extreme scenario that is not common on the relay
policies and the relay settings of Bitcoin Core, but technically possible if a
miner added a non-standard set of transactions to his block.

Also important to note that there's another check called pre-check ephemeral
transaction.  That check is kept when a reorg happens, because what this check
does is to check if a transaction has dust and non-zero fees.  So, if it had
fees and it would pay for itself and it would be a dust transaction, it wouldn't
be a standard transaction.  Only dust and non-zero fee transactions are
accepted, because those are the parents in the 1p1c package relay.  So, just to
say that this other check is kept in place, only the check we talked about
previously is removed in the reorg scenario.

_Bitcoin Core #34616_

We move forward with Bitcoin Core #34616.  Here, a more accurate cost model is
added to the spanning-forest cluster linearization (SFL) algorithm.  So, in
Newsletter #386, a new algorithm was added designed to handle difficult clusters
more efficiently.  The problem was that this was implemented with a naive
version of calculating the cost.  The first problem was that it would only track
one type of internal operation, when there's about 15 different types of
internal operations occurring when handling these clusters through this
algorithm.  So, a lot of CPU time was unaccounted for.  So, that's the first
major thing that's happening here.  It's accounting for the CPU time that's
spent across all operations on this algorithm.

The second aspect of it, it's that to find exactly the CPU time spent for
exactly this algorithm and this process, it would be naive to simply look at how
one machine does it.  Instead, the PR author ran a benchmark across 13 diverse
types of machines and averaged it across those machines, linearized more than
385,000 clusters, thousands of times.  So, now that's how he obtains the
acceptable cost threshold, is by weaning out all of these different benchmarks.
Yes, Murch?

**Mark Erhardt**: I wanted to take a step back and look at it from a little
further away.  So, what we're talking about here is the algorithm that is used
to linearize the clusters for cluster mempool.  So, as you probably have heard
if you follow this show regularly, cluster mempool is coming with Bitcoin Core
v31.  And the algorithm that it uses to sort the clusters or to find the best
order of these clusters is the newly introduced SFL algorithm.  And previously,
there was a naive way of estimating how much CPU time it would take to work
through a cluster.  And so, assuming that there's many big clusters, we would
want to prioritize or estimate how long clusters would take to optimally order,
and stop prematurely before the clusters are ordered fully, if some clusters
take too long and it takes too much CPU resources.  So, there is this cost
function here that measures or estimates how much CPU time has been spent on
ordering a cluster.  And to allocate the CPU time more appropriately, the CPU
time estimation was improved by making it more granular and testing it against
many different machines.

What you should take away from it at a high level here is there's a very fancy,
cool algorithm that does the optimization of the cluster order efficiently.  And
now, it will also more accurately estimate how much CPU time was spent on every
cluster to prioritize clusters.  But you'll never notice any of this.  Hopefully
your computer is generally way sufficiently powerful, and all of that happens in
the background and your clusters are all just sorted perfectly.

_Eclair #3256_

**Gustavo Flores Echaiz**: Thank you Murch for taking a step back and giving a
full picture of what's happening here.  So, we move forward with three PRs from
Eclair, the first two, #3256 and #3258, are very related, at least in the
motivation of why they were done.  So, the first one, #3256, a new event is
emitted or added, called ChannelFundingCreated.  This is emitted when a funding
or splice transaction is signed and is now ready to be published, either by you
or by your peer.  And the motivation behind this event, as much as for the next
one, is so that you can basically react to the creation of this channel that you
had.  For example, if you didn't fund the channel and it was simply funded by
your peer, you could now see the inputs that he used to fund this channel or to
add additional funds to when splicing.  And this would allow you to react
immediately if, for example, you found out that the inputs that are being used
for this channel are considered blacklisted inputs; you could immediately react
by closing the channel.  So, that's the example that the PR author gives for why
this event would be useful, but there could also be other use cases.  It's just
an additional event that is added in the transaction flow.

I want to point out that in Newsletter #388, we covered other channel lifecycle
events or work that was done.  There used to be a channel-opened event that was
removed in that PR and that Newsletter #388; and two events, channel-confirmed
and channel-ready for payments were added.  So, now as a follow-up, in this
newsletter we're covering right now, #395, the new event, ChannelFundingCreated
is emitted that could be useful for allowing someone to react as soon as a
transaction will be published, to see if the inputs used are adequate to you.
Any thoughts here?  Perfect.

_Eclair #3258_

So, the next one, #3258, like I said, is very related.  This is different.  This
applies to dual-funding channels, where you're committing inputs as well as your
peer is committing inputs as well.  And there's a new function that's added,
called ValidateInteractiveTxPlugin, that enables you to plug an external
software, with say a plugin, that would inspect the inputs and outputs of your
remote peer.  So, for example, you could see that your remote peer is inserting
inputs that you don't wish to be associated with, then this trait or this
function would allow you an external software, like a plugin, to simply reject
or validate this before proceeding to sign it.  So, compared to the previous PR
which I mentioned, that was specifically about remote peer funding all the
inputs and it was ready to be broadcasted and was already signed, here both
peers are committing inputs and this is before signing, you have the chance to
reject or accept your remote peer's inputs and outputs.  Specifically, if you
were to implement this in, let's say an LSP model, where you're looking at
filtering your users and the inputs of your users, this would be very handy for
that use case specifically.  And this applies for both dual-funded channel
openings as well as splices.

_Eclair #3255_

So, the last one from Eclair, #3255, this is a bug fix that was introduced in
the previous newsletter we covered, where in Newsletter #394, we covered that
you would be able as an Eclair node to simply automatically select the channel
type you want to open with your peer by preferring the best channel type.  So,
for example, if both peers support anchor channels, or in the future if both
peers support simple taproot channels, then a channel would be opening
preferring those types of channels.  However, a bug was introduced in that PR
where the specific feature, called scid_alias, that should be reserved for
private channels, was being automatically used for public channels, which is not
compliant with the BOLT specification.  So, in this newsletter, the PR #3255
fixes this so that the feature scid_alias is never picked when using public
channels, and only is reserved for private channels to be spec-compliant.

What is scid; what does this mean?  It allows a node that sits behind a private
or unannounced channel to basically conceal its identity, because its funding
transaction, the funding transaction for the private channel, was never
propagated to the gossip network.  So, this node sitting behind a private
channel can use the scid_alias feature to create invoices that will route
through the node that is publicly announced and that will end up with him.  So,
this is a feature only possible with unannounced channels which, is why the PR
fixes it so it doesn't ever apply to public channels.

_LDK #4402_

We move forward with LDK #4402.  Here, there's another bug fix, where in a
specific scenario where you are receiving a payment but you're also a trampoline
node, previously the HTLC (Hash Time Locked Contract) claim timer would use the
external onion payload value rather than the internal HTLC CTLV
(CHECKLOCKTIMEVERIFY) expiry value.  And in most cases when you're receiving a
payment, this is fine, the two values should be the same.  However, because in
this case the receiver is also a trampoline node, the trampoline node has
basically added an extra CLTV delta on the outer onion, because in most cases it
is simply routing a payment; but in this specific case, it is receiving the
payment so there is a difference between those two values.  And the fix is
introduced so that in this specific case, LDK will target the internal value,
the HTLC CLTV expiry, rather than the onion payload external value that should
be looked up when the trampoline node is actually routing the payment to someone
else.

_LND #10604_

The last one from the Lightning implementations is LND #10604.  So, this has
been a work that has been done over many multiple weeks now and is brought
together with this PR.  But many other PRs were part of the same project.  So,
here, an SQL backend, that could be either SQLite or Postgres, is implemented
for LND's outgoing payments database.  This is reworked from LND's existing
bbolt key-value (KV) store or database.  So, this has been a long objective of
LND, moving away from its previous database scheme that was that was part of the
Go ecosystem from which LND is built.  And now, LND is transitioning to backends
that are more standard, that are SQL-based.  So, you can find multiple PRs
within the release notes of this one that talk about the specific things that
were done to bring it all together.

So, I want to also add that this is a known criticism or feedback to the LND
implementation for years already.  So, for example, in Newsletter #169, support
for Postgres was added; and Newsletter #237, support for SQLite was added.  So,
this PR brings it together for specifically LND's outgoing payments database.

_BIPs #1699_

Perfect, so now we're entering the BIPs section, so I'm sure, Murch, you're
going to have a lot of things to add here.  So, we can start with the first one,
where the tapscript opcode, OP_PAIRCOMMIT, basically one that resembles OP_CAT
but avoids enabling recursive covenants, here two elements of the stack can be
combined basically, and their SHA256 hash can be added to the stack, which
allows for similar multi-commitment functionality to OP_CAT, like I said.  And
also, this is part of the LNHANCE soft fork proposal alongside CTV, CSFS, and
INTERNALKEY.  This was initially proposed in Newsletter #330, but please, Murch,
if you have some extra thoughts to add here, I think listeners would appreciate
it.

**Mark Erhardt**: Yeah, so moonsettler had proposed this almost one and a half
years ago, and I'm glad that this is for a relatively simple proposal that this
is wrapped.  So, that was published just recently.  If you're interested in
LNHANCE or OP_TEMPLATEHASH or OP_CAT, I think this one is an easy and
interesting read that you might want to take a look at.  I think that it is
pretty mature as a proposal, but it hasn't gotten a ton of commentary.  If
you're into the whole covenant stuff, maybe give it a read and leave some
feedback.

_BIPs #2106_

**Gustavo Flores Echaiz**: Thank you, Murch.  Next one is BIPs PR #2106, where
the proposal for silent payments, BIP352, is updated to introduce a per-group
recipient limit of 2,323 for mitigating worst-case adversarial transactions.
So, in Newsletter #392 and the podcast that came with it, we covered a proposal
to limit the number of per-group silent payment recipients, and we brought in
the author of the Bitcoin-Dev mailing list post, Sebastien Falbesoner, to
explain his discovery and his proposed mitigation for a theoretical attack on
silent payment recipients.  So now, initially, the amount that was proposed or
the value that was proposed was 1,000, and now actually what is merged in the
BIP proposal increases it to 2,323.  The goal is to match the maximum number of
P2TR outputs that can fit in a standard size 100 kvB (kilo-vBytes) transaction.
And the reason why the 1,000 was not chosen is because it would allow to
fingerprint silent payment transactions, because it was extremely precise.
However, pushing it to the upwards limit makes it less easy to fingerprint.
Murch, any comments?

**Mark Erhardt**: I just wanted to point out, this is specifically only limiting
the count of outputs that can be sent to the same recipient.  So, when you scan
for silent payments, your node will check whether there's a first payment to
your key.  And if a recipient is paid to multiple times, because the output
script is composed of the recipient keypair and the input keys, it would have
the same output script for several payments, right?  So, when there are multiple
payments that go to the same recipient, there's a counter that gets incremented
in order to create multiple different output scripts.  So, the vulnerability
here is that if you pay a recipient multiple times, they might need to scan all
of the outputs again.  So, if you have 2,323 outputs, they might find in the
last one they scanned that they got paid.  And now, they check again all other
2,322 outputs, whether they'll get paid again.  And maybe the last one they
scan, they get paid.  So, it introduces a quadratic cost to the scanning.  And
if you made a whole block of silent payment payments to a single recipient, you
could have them scanning multiple minutes.

On the other hand, this attack is pretty theoretical because it requires you to
pay the same person every time.  Now, you could have a lot of zero-sats payments
and then one juicy last payment, and they would continue scanning through all of
them, and then the last one you send to yourself.  So, you could waste someone's
time, but you're still paying for all that block space.  So, overall, this is
probably not something we will see in the wild.  But yeah, there was a long
discussion in the past few weeks about what the appropriate limit is.  And now,
it's basically just limited to the maximum number of P2TR outputs that you could
have in a standard transaction, so there's no additional fingerprint by
introducing this limit.

_BIPs #2068_

**Gustavo Flores Echaiz**: Thank you, Murch, very insightful to give all that
context.  So, now, the final BIPs PR is #2068, which publishes BIP128, also
called Timelock-Recovery Storage Format.  So, here, a standard format is
proposed for specifically timelock-recovery plans.  So, the way it works is that
it consists of two presigned transactions that would enable to recover funds if
an owner loses access to their wallet or, for example, inheritance use cases.
So, the first transaction that is pre-signed is an alert transaction that would
consolidate all the wallet UTXOs into a single address part of that wallet.  And
then, the second transaction would be the recovery transaction, but it would be
timelocked with a specific relative time lock.  It could be configured between 2
to 388 days.  And the reason why there's the specific second recovery
transaction that is timelocked is because the other transaction could be
broadcasted prematurely and out of protocol.  So, the timelock gives the initial
owner the chance to spend the output that was created with the first alert
transaction, back into his wallet to invalidate the recovery.  So, there's a
failsafe for the owner to block the recovery flow by simply moving the funds
somewhere else as he wishes.  Yes, Murch?

**Mark Erhardt**: Or actually, just any single input to the second transaction.
So, the second transaction is supposed to sweep the entire wallet's funds to the
second wallet, to the backup wallet.  And of course, if you spend any single
input of that, you invalidate the second scheduled transaction.  I think the
scenario the authors have in mind is you might have a less secure, maybe mobile
wallet, and this is basically infrastructure that would eventually sweep all the
funds in your mobile wallet to your backup wallet or more secure wallet in case
you lose your mobile phone.  Of course, If you have a backup anyway, then
hopefully you wouldn't be in the position to need to rely on this.  Anyway, this
is also a proposal that has gotten so far not a whole ton of commentary.  I
think there is a project or a company that is trying to implement this as a
service.  So, there's interest in implementing this already.  But if you find it
interesting, you could find the mailing list post and reply there for leaving
some feedback.

**Gustavo Flores Echaiz**: Yes, thank you, Murch.  And yeah, I want to add that
there's a reference implementation that is added as a plugin on specifically
Electrum Wallet that is cited in the specification of BIP128.

_BOLTs #1301_

So, the final PR covered this week is BOLTs #1301.  Here, the specification is
updated to recommend a higher dust limit threshold value for HTLCs in anchor
channels.  So, the HTLCs of modern anchor channels have zero fees, and they have
to be higher than the dust limit.  But the initial specification didn't account
that a second transaction would be needed to spend them, because they pay zero
fees.  So, the dust limit should actually apply to the combined weight of both
transactions.  And here, only the second transaction that would spend those
HTLCs wasn't accounted for when determining the dust threshold of these HTLCs.
So, there's not a specific value that is set in the specification, it's simply
noted that there should be a consideration for these subsequent transactions
that spend these zero-fee HTLCs, when setting the dust limit value threshold for
these HTLCs.

**Mark Erhardt**: And it's probably good that there is not a specific limit set,
because at least recently, the minimum feerate that we see confirmed in blocks
has gone down almost a factor 10.  And therefore, while you have to account for
the second transaction, the overall fees that are acceptable are much lower.  I
should point out, however, that at least in Bitcoin Core, the dust amounts have
not been adapted.  The dust amounts are still based on 3 sats/vB (satoshis per
vByte) in Bitcoin Core, so the dust limits of what Bitcoin Core considers a dust
output are still the same.

**Gustavo Flores Echaiz**: Thank you, Murch.  Yeah, this specification update
also mentions the Bitcoin Core standard values, so it's specified that they have
to be higher than the standard values of Bitcoin Core.  And this completes this
section and the whole newsletter.  Thank you, Murch.  Mike?

**Mike Schmidt**: Awesome.  Thanks, Gustavo.  Well, that was everything from
#395.  We want to thank our guests for today, Jon, Antoine, Mike, and Ethan for
joining us this week.  Thank you to my co-hosts, Gustavo and Murch, and for you
all for listening.  We'll hear you next week.  Cheers.

**Gustavo Flores Echaiz**: Cheers.

**Mark Erhardt**: Cheers.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
