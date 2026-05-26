---
title: 'Bitcoin Optech Newsletter #400 Recap Podcast'
permalink: /en/podcast/2026/04/14/
reference: /en/newsletters/2026/04/10/
name: 2026-04-14-recap
slug: 2026-04-14-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by Julian Moik to discuss
[Newsletter #400]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-3-14/422069514-44100-2-21e9941d565a5.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #400 Recap.  A
little bit of a numerical milestone for us; 400 of these over the last eight
years.  And so, welcome to the Recap.  We're happy about that milestone and
today we're going to be talking about, we have a Bitcoin Core PR Review Club.
Finally, those are back after a few months hiatus, talking about the Bitcoin
Core 31.0 RC testing.  We have our Notable code and documentation changes,
including a GSR-related BIPs merge that we're going to get into right off the
bat here.  This week, Murch, Gustavo and I are joined by Julian.  Julian, you
want to introduce yourself for people?

**Julian Moik**: Sure.  Hi, everyone, thank you for inviting me.  Yeah, I'm
Julian, I've been working on script restoration with Rusty Russell for about the
last year.  And we finally managed to publish two of the draft BIPs, which are
often referred to as script restoration or GSR, Great Script Restoration.  And
yeah, happy to be here.

_BIPs #2118_

**Mike Schmidt**: Awesome.  Well, we'll jump right into that item.  For
listeners, we're jumping down to BIPs #2118, covering BIP440 and BIP441 being
formally published in the Bitcoin Improvement Proposal repository.  We covered
these last week briefly when Rusty Russell announced them.  That was in #399.
These are two, I believe, of potentially four BIPs that could be rolled into
GSR, and maybe Julian can walk us through these two and what isn't included in
these two as well, and maybe as an easy lead-in question, GSR, Great Script
Restoration, Grand Script Renaissance, what are we going with here, Julian?

**Julian Moik**: I usually just like to refer to script restoration.

**Mike Schmidt**: Okay, script restoration.

**Julian Moik**: I think that's pretty clear, but it's nice to have these fancy
names on it.

**Mike Schmidt**: All right, so what's in BIP440 and BIP441 for script
restoration?

**Julian Moik**: Yeah, I can give a quick rundown of the first BIP, which is now
labeled BIP440.  It describes a computational budget for a Bitcoin Scripting
language.  And so, it takes this existing sigops budget, that just limits the
amount of signature verifications that you can put into a block, and it
generalizes that concept so that it applies also to other operations.  So, not
only are signature verifications computationally expensive, but another good
example that I like to give is also hashing functions.  They can also be slow,
and currently there is no explicit limit on that.  So, you could argue even that
for the current state of script, it would make sense to extend that sigops
budget into a budget that also includes hash functions.  It's currently not
really an issue that there is not this hashing budget, because we have a block
size limit, we have quite strict stack limits, which just prevent construction
of blocks that would be too slow to validate.  But still, we only have those
size limits, and you could imagine that in the future, we might have opcodes
that are more computationally dense than we have now.  In this case, we might
need other limitations besides the block size alone.

The varops budget, it really tries to establish a framework for computational
cost, and it can be seen as a foundation for future upgrades, like adding new
opcodes, which then need that computational restriction.  That would bring me to
the second BIP.

**Mike Schmidt**: Maybe a quick question.  Could the varops budget apply just
even if you didn't have 441 or any changes to script; that's something that
could be applied in consensus?

**Julian Moik**: Yeah, you could potentially restrict the current state of
script.  I guess it's a little bit complicated with legacy script and then you
have, well, really in GSR, we introduce a new tapscript version and we don't
even touch the original leaf version.  So, we try to not change it at all.  And
I don't think it's really useful to have that with our GSR.  It's like a
prerequisite of restoring scripts.

**Mark Erhardt**: I believe, having read it a few times, but obviously not being
an author, I believe that it is backwards compatible in the sense that per the
varops pricing, all the existing prices are limited by the varops budget, either
to the same extent or more leniently.  So, I think that in conjunction with the
existing limits that also exist for the new introduced stuff, it is not a change
at all for the existing scripts.

**Julian Moik**: It was initially Rusty's idea that we define the hashing costs
such that basically, existing functionality is unchanged.  But we had to
increase that cost based on benchmarking results.  And so, now this might not be
true anymore.  So, you could probably find a case that would exceed the varops
budget if you just use hashing.

**Mark Erhardt**: Oh, so it is more restrictive than the existing budget in some
cases?

**Julian Moik**: It's only the sigops budget currently.  So, yeah, definitely.

**Mark Erhardt**: Right.  So, sorry, in tapscript v2, which we will get to in a
moment, the old things that were possible in tapscript v1, some of those might
not be possible under the new rules because the varops is more restrictive than
previous.  So then, answering Mike's question, it would be possible to introduce
it.  It only really makes sense in conjunction with BIP441, but it's a soft fork
and backwards compatible in the sense that it's just more restrictive.

**Julian Moik**: Yes, exactly.  But you would actually have to really try to hit
the limit.  The limit is quite high.  But if you really try it, you could craft
a script that would fail.

**Mike Schmidt**: Okay, so maybe we can move to BIP441 and what would be in
there; and then, what would be in there that would necessitate a varops budget?

**Julian Moik**: Yeah, there are several changes included and they all have that
aim of making script more expressive.  So, this is really the idea here.  We
want scripts to have those basic building blocks which are general and not
super-specific to any use case.  And I think this is a big contrast to most
other proposals, that we just want to provide primitives and not be so specific
about it.  And yeah, for once what is included is the restoration part.  So, we
have those 15 opcodes that were disabled in a very early version of Bitcoin in
2011 by Satoshi still.  And the concern back then was that you could basically
use some operations, like left shift, to create very large stack elements.  And
there were no limits in place, so you could just overflow the memory of nodes
quite easily, making that node crash and really making the complete network
crash just with a single transaction that would cause a stack overflow.  And
yeah, this led to this disablement of all 15 of these opcodes.  And now, the
script interpreter still has this code branch where it checks, okay, are we
currently evaluating any of those 15 opcodes?  And if so, we throw that script
error, the opcode is disabled.  And I always thought it was kind of weird to
have that section in the code.  It just hasn't been touched for, like, 15 years
now.

These opcodes, you can categorize them into three distinct categories.  So, the
first one would be splicing.  So, if you take a stack element, you would like to
maybe just take a part of it.  You take an element, maybe you just want the
first 4 bytes of that.  So, you could do that with OP_LEFT, for example.  You
could do the same on the right side.  Also, you have concatenation, which is
probably the most famous of the opcodes.  It just concatenates the top two
elements.  Then the next section is bitwise logic.  So, also very fundamental
operations, just AND, OR, XOR, and bitwise inversion of an stack element.  And
the last section is arithmetic, which basically boils down to multiplication and
division.  So, these are all things we cannot do right now in script.  And yeah,
this is really the big change, I would say.

There are some other changes.  One is the number type.  Currently, we use a
signed 32-bit integer.  So, you have positive values and negative values.  And
the BIP proposes an unsigned bignum integer.  So, this is like an arbitrary
length number which can grow arbitrarily large, basically.  And the reason for
that is, maybe for the sign first, the reason is you don't really have negative
values in Bitcoin.  So, the negative part, to my knowledge at least, was mostly
like wasted space.  And we would also like to just represent larger numbers.
Because of the 32-bit integer, you cannot even go up to the maximum number of
coins.  So, you have this new number type, and then it also loosens some kind of
arbitrary script limits.  So, you have the stack size, so the maximum number of
stack elements that you can push.  This one is loosened, and also the maximum
size of the individual stack elements.  So, this currently sitting at 520 bytes.
So, just removing some of these arbitrary restrictions and, yeah, they all just
aim to make scripts a more expressive language.

**Mike Schmidt**: Those restrictions you mentioned, that's different than what
was around in 2010.  So, that's unrelated to the change that Satoshi made back
then.  But all of these opcodes, these are the exact same set of opcodes that
were disabled in 2010, or is there some that don't overlap?

**Julian Moik**: Those are exactly those 15.  And yes, you could potentially
argue that maybe we don't need all of these 15, maybe we want something slightly
different.  The thing is, basically you have these opcodes already in the
codebase and they have their opcode number, and you would just have to re-enable
them.  You would not have to use a no-op, or however you want to add new
opcodes, it's a little bit more complicated for operations that haven't been in
there.  So, yeah, this is just the idea.  But you could totally argue that maybe
we don't need an LSHIFT, for example, because you can do that with
multiplication already.

**Mark Erhardt**: So, to be clear, the reasons why Satoshi stated that opcodes
were disabled back then were the concern of DoS.  So, all of these limits that
are being introduced with the varops budget and this loosening of other limits
is very much in line with this.  Basically, I think there was one bug discovered
in one of these 15 opcodes in how it was implemented back then in the codebase.
And basically, Satoshi presumably felt that he didn't have a lot of time to
react, and just disabled a bigger number of opcodes at the same time that could
either have vulnerabilities or could have a DoS vector potential.  And what I
perceive this proposal now to do is explore to a much bigger extent what exactly
the DoS vector surface is, what limits are necessary, what sort of computational
footprint is acceptable, and gives a framework to re-enable the previously
existing opcodes in a way that would be computationally safe in the Bitcoin
Stack.

**Julian Moik**: Yeah, that's a really good summary.

**Mark Erhardt**: And because re-enabling disabled opcodes would be a hard fork,
introducing a new version of tapscript, that is previously completely undefined
and therefore everything is allowed, allows you to have a bigger set of opcodes
by restricting it from anything goes to just tapscript v2.

**Julian Moik**: Right, yeah, this is how I understand these leaf versions.
They are really designed to have future upgrades made with relative ease.  I
think there can be up to 50 of those leaf versions.  It really doesn't touch the
rest of the scripting language.  So, if you don't feel good about those changes,
you could say, "Okay, I'll just use the original tapscript for my transactions".
Yeah, so potentially we could have many iterations of the language like that.

**Mike Schmidt**: I know a lot of people were excited when Rusty presented, I
think it was at BTC++ in Austin, about this idea.  And so, there was a lot of
energy from the folks who like to build.  And I'm wondering, have people been
tinkering at all yet?  Obviously, we're just at the sort of draft BIP stage, so
things are early, but I'm wondering if that energy manifested itself into
prototypes and things like that, using script restoration?

**Julian Moik**: I mean, one thing that everyone knows about, I guess, is
OP_CAT, which has been like, I mean, the builders have been building with
OP_CAT, like, I think it's really crazy what you can do with OP_CAT.  It's very
unintuitive and quite surprising.  And this is really one of the main enablers.
If you only had OP_CAT, you could already build like a ZK verifier, you could
build a vault, you could even do some introspection.  And yeah, having the whole
set of opcodes, it just makes that a bit more convenient.  But so far, I mean I
have been actually working on the Splunk verifier.  So, I looked, there is from
Starknet, there's like a prototype for verifying a proof.  And they just use
OP_CAT because OP_CAT is a thing that people maybe hope to activate alone.  I
tried to figure out what if we also had multiplication and the mod operator, and
this improves the efficiency of that verifier by quite a bit.  It would be one
example of a use case, like having the multiplication of numbers is very useful.

**Mark Erhardt**: So, very concretely, OP_CAT is proposed in BIP347 to be
enabled in tapscript with the leaf version 0xc0.  This is basically independent,
because if you use tapscript version 0xc0, which is the currently defined
tapscript, then if it were added there, you could do OP_CAT in that.  And here,
the proposal is to introduce a whole new version of tapscript.  So, if the leaf
version of a script leaf in the script tree were defined as, I think, did you
say 2c, right?  Then it would 0xc0 and 0xc2, not 2c.  So, if you used the second
tapscript version, then you get all of the new 15 opcodes, you get the varops
budget and so forth.  If you use the first version of tapscript, if OP_CAT were
enabled via BIP347, it would be added there.

**Mike Schmidt**: Julian, I have a question referencing back to some previous
coverage that Optech had, based on some posts that Rusty had to the mailing
list.  This was Newsletter #374, which was October last year.  Along with the
varops and the restoration of previously disabled script, there was, at least
articulated in the same email, OP_TX as a third BIP, and then new opcodes for
tapscript v2, which was the final BIP that was part of the post that Rusty put
up, which I think would include things like INTERNALKEY, MULTI, SEGMENT.  What
is the status of those?  Is the idea to work on those next, or to put forth
these two together and address those other two later?

**Julian Moik**: Yeah, I must say I haven't worked on those at all.  So, yeah,
you really need Rusty for those two.  But I think introspection is super-useful,
just the idea of it.  And I mean, there are now a lot of proposals.  It's again,
this question, do you want a specific operation, like CTV
(OP_CHECKTEMPLATEVERIFY), or do you want this super-powerful, generic, general
OP_TX, which they are really complete opposites.  And yeah, I think we have to
think about really, do we want a general language or do we want these
super-specific operations, which are potentially safer and less powerful?  But
then, if you add, for example, CTV, you have that in Bitcoin and you struggle
again if you at some point want to have something more general.  So, this is why
I and why Rusty like this more general approach.  It just enables builders to
build.  And then over time, we might figure out if we see onchain, for example,
if we see a lot of vaults being built with OP_CAT and blocks are full of vaults,
we know we might want to have a dedicated opcode for that, which is more
efficient than having this CAT construction.  And it should make it easier to
come to a consensus with having this general approach, I believe.

**Mark Erhardt**: So, sorry, I feel like there were two things I heard here.
One is you prefer the more general approach, but then OP_TX sounds like a very,
very specific and small and narrow approach.  thing you can commit to another
transaction.  So, with the general approach, you were talking about being able
to do many different things with OP_CAT.  But you also mentioned that
introspection is super-useful, which is extremely difficult by OP_CAT.  So, I
think that the OP_TX use case is essentially also covered by other proposals
like OP_ TXHASH, BIP346.  Then, OP_CCV probably, the CHECKCONTRACTVERIFY, could
probably achieve something similar.  And there is both CTV, which is BIP119, and
OP_TEMPLATEHASH now with BIP446.  And packages around that, like LNHANCE and
taproot-native (re)bindable transactions.  So, I think we actually have a lot of
options and we should just pick one if we're going to do introspection.  And,
yeah, if we get OP_CAT and that allows us to sort of demonstrate that there is
demand for it, because people even do it with the super-complicated and
convoluted OP_CAT approach, that might inform which one we pick.  But do you
have a preference if you've been thinking about covenants so far?

**Julian Moik**: Honestly, I'm not super-deep into the latest proposals there.
I mean, initially, I was a fan of CTV, but I more and more like these more
general versions, like TXHASH, or even Rusty's approach, which doesn't even hash
the values.

**Mark Erhardt**: Oh, maybe I misunderstand what OP_TX does then.  I thought
that it just commits to a txid, but what is the idea of OP_TX then?

**Julian Moik**: So, as I said, I haven't been working on that.  I think I have
read the draft paper once.  But as I understand it, it is like a more general
approach to OP_TXHASH.  Is that not the case?

**Mark Erhardt**: I guess then we'll have to leave that for another episode.  I
don't know better than you either.

**Julian Moik**: Yeah, sorry.

**Mike Schmidt**: Julian or Murch, is there anything else that we should cover
on this item before we wrap up?

**Mark Erhardt**: Well, maybe a general call to action here.  We've been getting
a little more BIPs.  I feel that might be induced demand to some degree, because
BIPs have been getting processed a little more quickly and people are writing
more BIPs again because, well, they don't just sit there anymore.  But it would
be really nice if there were more people from the community taking a look at
drafts or open PRs.  A lot of them have only been getting BIP editor review
before they move from being opened as PRs to the repository to being published.
I'm sure people also look at them once they're published, but so far very little
of the review or reading has led to comments or additional remarks on them.  So,
please feel free.  You don't have to be a BIP editor to read BIP drafts or PRs.
You can just look at them, leave your comments.  We have something like 50 open
PRs right now again.  And about probably ten of those or so are proposing to
create a new BIP.

**Mike Schmidt**: I'll emphasize one thing that Murch said there to sum it up
for listeners.  You do not have to be a BIP editor and have that title in order
to comment or review BIPs in the BIPs repository.  I guess maybe an analogy is
Bitcoin Core, you don't have to be a maintainer to review a PR.  In fact, most
of the review comes from folks who aren't maintainers.  But perhaps there's some
stigma in the BIPs repository that review maybe often and should come from the
BIP editors as opposed to general audience.  So, if you're curious about these
sorts of things, poke in, see what you're interested in, and leave feedback.
Murch, maybe just quickly, what types of things are valuable for people to look
at?  They don't necessarily need to evaluate the internals of the proposal,
right?  There's general things that can be reviewed as well, which would be
helpful, right?

**Mark Erhardt**: I mean, if you even just say, "I didn't understand this part",
or, "The motivation seems unclear", or I mean, it's not very helpful to say
you're against something because that's not the point.  The point is to make
them clearer or more accurate or more comprehensive.  So, if you notice there's
a part that should be defined but isn't mentioned, or if something is hard to
understand, or maybe there could be a table demonstrating the listed values
here, or something like that, that is useful feedback.  Saying, "I don't like
your proposal", is not.  So, please keep it technical and constructive.  And I
don't know if you see typos or stuff like that, that should be fixed before it
gets published.  That's also useful, of course.

**Mike Schmidt**: Julian, anything else for listeners before we wrap up?

**Julian Moik**: Yeah, I was just thinking, as someone who has spent quite some
time on these BIPs, it's always a good feeling to have some kind of engagement
or have someone being interested in your work.  So, I mean, even if you just
kind of look at the BIP and maybe you have a bunch of questions, yeah, it's
always a good feeling to have someone showing interest.  And yeah, so I agree,
it would be great to have more conversation and more review in the repository.

**Mark Erhardt**: One more question for you, Julian.  So, having worked on the
restoration of script and proposing to activate this new tapscript version, what
are some of the things that you're excited to see people build with this?

**Julian Moik**: Yeah.  So, I like to refer back to that we don't even really
know what people might want to build.  If you have a general purpose programming
language, you have no idea what people are creating with that.  And I guess this
is also part of the dislike about these forward-thinking proposals, that it
might allow things that we don't want to have on Bitcoin.  But eventually I have
this hope or I believe that if we would give builders all the tools, they would
build good tools, they would build tools that would help with Bitcoin, and they
would probably also build things that you would not like to see.  But in the
end, the idea is really that you have a fee market, you have limited block
space, and I would think that the useful applications, which scale payments,
scale ownership, potentially improve privacy, that those use cases would win out
through the fee market, right?  Because in the end, Bitcoin is designed to be
money and this is really the point.  And I would hope that if you have these
primitives, you could build things like a rollup on that, which improves scaling
and just makes better decentralized money.

**Mike Schmidt**: Excellent.  Good way to wrap up, Julian.  You're welcome to
hang on, but we understand if you have things to do and you're free to drop.

**Julian Moik**: Sure.  Thank you.

_Testing Bitcoin Core 31.0 Release Candidates_

**Mike Schmidt**: We're going to jump back up to our monthly segment on a
Bitcoin Core PR Review Club.  This one is titled, "Testing Bitcoin Core 31.0
Release Candidates".  And it's a little bit different than following a specific
PR, since this one is more of a group testing effort.  This was the testing
guide that we covered previously in #397 that svanstaa came on and talked to us
about creating the guide and how he went about that, and also the different
components in there, which include testing around cluster mempool and the RPCs
and cluster limits.  We talked about cluster limits in #382. Private broadcast
and testing that, I think we covered private broadcast in #388.  The getblock
RPC with the new coinbase_tx field, that was in #394.  And then, we also talked
about -dbcache size in #396, ASMap data by default in #394, and the REST API
endpoint, we talked about that in #386.

**Mark Erhardt**: And so, we're on RC4 for Bitcoin Core v31.  That means the
original roadmap was aiming for tentative date of April 10th to attack v31.  We
are on RC4; that was tagged a few days ago.  As far as I'm aware, there are no
open issues.  So, this might be the version that gets released and we're on the
verge of having v31 come out.  Obviously, if you still want to test or take a
look at the feature, the testing guide might still be interesting as a sort of
guided tour around the new features.  But if you're just ready to jump in,
you'll probably be able to do so in a few days.  I mean, you can always just run
the master branch from the repository, but then the actual release will be there
soon.

**Mike Schmidt**: Yeah, the testing guide in addition to the release notes draft
would have good ideas of what to test and obviously, like Murch said, what is
actually in there, if you're going to be looking to upgrade to 31.  Anything
else on this Review Club, Murch?  Great.  We're going to bounce to the Notable
code and documentation changes.  We didn't have any News and we didn't have any
Releases to cover this week.  We did touch on the one BIPs PR, but for the other
PR we have, Gustavo authored this segment this week.  What's going on, Gustavo,
this week in Notable code?

_Bitcoin Core #33908_

**Gustavo Flores Echaiz**: Thank you, Mike and Murch.  Yes, so this week, we
have the first one which is on Bitcoin Core #33908, which is a new endpoint or
addition that is added to the libbitcoinkernel API in C programming language.
So, this API is something that we've been recurrently talking about for the past
few newsletters.  This one adds a new function called
btck_check_block_context_free, which basically the name tells you that it's for
validating candidate blocks with context-free checks and also per-transaction
checks that do not depend on chainstate, the block index, or the UTXO set.  So,
what are these context-free checks and these per-transaction checks that don't
depend on the chainstate and these other data fields?

So, for example, block level context-free check can be just simply looking at
the block size and the weight limits, or it can also be looking at the presence
of a coinbase transaction, or witness commitment checks that verifies the
witness reserve value size.  So, those are like the main block level
context-free checks.  But also, this PR ads optionally, can also enable callers
to verify the proof-of-work and also the merkle root, right?  So, actually, this
function is just a layer on top of an internal function in Bitcoin Core called
checkBlock, which is different from another function called
ContextualCheckBlock, right?  So, you can tell by the name why the checkBlock
one is contextless.  So, a sub-function of checkBlock, excuse me, is
checkBlockHeader, which checks that the blockhash meets the difficulty target
declared in the header.  And the merkle root verification is also just
re-computing the merkle tree from the block transaction and checking against the
header's hash merkle root field.  So, those are the optional things you can also
add that callers can enable in this function.

Per-transaction checks that are context-free, well, you would have, for example,
making sure that inputs and outputs are not empty, once again transaction size
and weight limit, or other things like that.  So, coinbase scriptSig length
bound, for example, something we've talked about in the past.  So, yeah, so this
is just a new function part of this API that exposes the libbitcoinkernel.  So,
an interesting addition, just a follow-up.  Probably in the next few weeks,
we'll see more additions to this API.  Yes, Murch?

**Mark Erhardt**: Yeah.  As some of the things that require context, for
example, in the blockHeader, you commit to the previous block, so you can only
check that if you know the previous block.  To know whether your transactions
actually have the funds that they create for the outputs, you need to know about
the UTXOs, so you need context.  But there are a number of things that you can
check directly just from receiving the block.  And the idea there is that if you
have only the block, you can do a bunch of checks already that, for example,
mean the block was produced with a proof of work.  And that is already a very
high bar to meet.  It would be very expensive for someone to lie to you and to
give you a chunk of data that passes the proof-of-work check, but is not
actually valid.  So, that can maybe, in some regards, inspire confidence, but to
have a full check of whether a block is consensus valid, you need the context of
the UTXO set, the previous blocks, and so forth.

**Mike Schmidt**: Murch, question for you.  When we see btck, like this
btck_check_block_context_free, we just read that as Bitcoin kernel, the btck
part?

**Mark Erhardt**: I don't know, but sounds plausible.

**Mike Schmidt**: Okay, I've been seeing it pop up, so I was curious.  Okay,
back to you, Gustavo.

**Gustavo Flores Echaiz**: Thank you, Murch and Mike.  Yeah, so that's exactly
right.  And this is very much used by, like, mining pool template validation for
Stratum v2 template validation.  So, yeah, like Murch said, it's not a full
coverage, but it's a minimum verification around the mining template you created
or received specifically, and can be leveraged for Stratum v2 pools verify
miner-constructed blocks.

_Eclair #3283_

So, the next item is from the Eclair repository, PR #3283.  Here, a new field is
added to three similar endpoints, called findroute, findroutetonode, and
findroutebetweennodes.  So, a new field is added, called fee, that in msats,
this field provides the total forwarding fee for the route.  So, before this fee
existed, a caller would have to manually calculate the fee per hop and then sum
all that up to get the total fee of the route.  So, this makes it simpler for
callers to just get the fee filled from these endpoints, and not have to
manually construct the fee that would require them to go backwards and go per
hop, calculate the fee and then sum it all up.

_LDK #4529_

So, the next one is LDK #4529.  This is one of the two LDK PRs we're covering
this week.  The first one enables operators to set different limits for
announced or unannounced channels when configuring the total value of inbound
HTLCs (Hash Time Locked Contracts) in flight.  So, what this means is that
before this PR, you could set a limit for the total value of inbound HTLCs in
flight, but there wouldn't be a difference between the announced and the
unannounced, or also called private channels.  So, now this value, or the
setting, is split across two different settings, that one is for the announced
channels and the other one is for the private channels.  And what is the total
value of inbound HTLCs in flight?  This just means that, for example, when you
cap it at 25%, which is the default for the private channels, then at most there
will be 25% of the channel's capacity that is currently in flight, so that has
either not succeeded or failed.  So, the HTLCs are in flight and haven't yet
completed.  So, you're always reserving channel capacity and you're not at risk
of getting all of your channel capacity stuck in an HTLC.

So, the defaults for this are 25% for announced channels and 100% for
unannounced channels, but this is all very configurable, so a user could change
that to any desired value.

_LDK #4494_

The next one, LDK #4494.  Here, the internal logic around RBF for fee bumping
transactions is updated.  So, in the past few weeks, we've covered LDK's RBF
implementation specifically for splicing.  So now, it was found that LDK would
fail to comply, at the same time, with the BIP125 replacement rules, and the
also the rules specified in BOLT2.  So now, the update of the logic makes it
that LDK will always use whichever is larger, either the BOLT2 rule, which is
that the feerate has to be multiplied by 25/24, which is about a 4% increase;
so, it's either that 4.17% increase, that's what the LN spec says that the fee
bump has to respect.  The BIP125 rule simply says that the absolute fee has to
be higher, so you could simply increase by 1 sat.  But at very low feerates
there's a potential for one to be better to use than the other.

So now, LDK simply compares both rules and applies whichever is larger to ensure
that it always complies with the LN spec rules and the BIP125 rules.  And also,
this PR opened a new discussion on the BOLTs repository to ensure that we always
comply with BIP125, that the spec instructs implementations to always make sure
that they not only comply with the BOLT2 specification around fee bumping, but
also the BIP125 rules around the RBF.

**Mark Erhardt**: That is so odd to me.  BIP125 is still implemented by some
Bitcoin Core derivatives, but Bitcoin Core implement it anymore.  And then, why
25/24, a 4% increase in fees when an additional 25 sat per kiloweightunit
(sat/kW) is 0.1 sats per vbyte (sat/vB)?  So, that is the new default of Bitcoin
Core for the incremental relay TX feerate.  So, it sounds like they're actually
implementing Bitcoin Core's current new default feerate.  But where does this
25/24 come from?  And the other thing, yeah, it also assumes that the
transaction is the same size as before, which I think is a problem here, because
you do have to increase the absolute fee too, which usually happens when you
increase the feerate if the transactions are the same size.  But if your
transaction gets smaller, increasing the feerate doesn't necessarily mean that
you beat the prior absolute fee.

So, this update confuses me and I shall just state that I'm confused by it, but
I will probably not dig into it.  But if anyone working on this is interested,
we can talk!

**Gustavo Flores Echaiz**: Yeah, so I just took a look at the new PR that was
opened in the BOLTs repository, and I can see that this has been a requirement
in BOLT2 specifically.  For example, it says, "The sender MUST set feerate
greater than or equal to 25/24 times the feerate of the previously constructed
transaction, rounded down", right?  So, this has been a requirement on BOLT2 for
probably a while already, and there was maybe a hypothetical scenario where this
would conflict with the BIP125 rule, and this is why this was implemented in
LDK; probably very hypothetical, because from what I understand, LN funding
transactions are quite large, so this might not even be a problem often in
reality.

**Mark Erhardt**: I mean, very specifically the 25/24 does not increase the
feerate enough, if the prior feerate was less than 24 sats/vB before the recent
subset summer.  So now, it would be at 2.4 sats/vB, below of which this increase
is not enough.  And in all of those cases, increasing by 25 sats/kW is the
minimum amount that you have to bump for Bitcoin Core nodes to accept the
replacement.  So, it's just confusing to me that you now use whichever is larger
instead of just the latter, because the latter is always the right value.
Anyway, we're getting too much into the weeds here.  Let's carry on.

_LND #10666_

**Gustavo Flores Echaiz**: Thank you, Murch.  Yes, so the next one is from LND.
So, LND #10666 adds a new RPC called DeleteForwardingHistory and an equivalent
command on the lncli tool.  This enables operators to selectively delete
forwarding events older than a chosen cutoff timestamp.  So, you basically call
this with a specific timestamp and it will delete all the forwarding events
before that.  So, what's interesting about this is that you can now delete
historical forwarding records without having to take your node offline or
resetting your database.  So, this was not possible before this PR.  And there's
also a minimum age guard of one hour that prevents you from deleting or removing
data that is just way too recent.  So, you're unable to delete with this
function data that is over the past hour, but anything before that, you can
easily delete with this new command.

_BIPs #2099_

Next one, now we get into the BIPs.  So, we have BIPs, the PR BIPs #2099, which
publishes BIP393, which specifies an optional annotation syntax for output
script descriptors.  So, a common problem is that through the descriptors, or I
guess a limitation of the descriptor protocol is not being able to specify
recovery hints, such as for example, the birth date of a wallet.  So, wallets
would implement this outside of this descriptor protocol.  So, this adds it
directly into it.  Yes, Murch?

**Mark Erhardt**: Yeah, so the descriptors are very specifically designed to
express a set of output scripts, right?  And in Bitcoin Core, where this
proposal comes from, the descriptors are used to basically refer to a set of
output scripts that define part of a wallet.  So, if you, for example, have
output scripts for P2PKH and for P2TR, you would have at least two descriptors
that define those sets of output scripts.  So, in that context, they do not have
that meta information, because the wallet format of Bitcoin Core already stores
this meta information in other ways.  Where BIP393 comes from here is that this
project sees descriptors as an interesting way of they would like to use
descriptors in their wallet backups.  But in the context of wallet backups, you
have additional information that is relevant.  And very specifically, knowing
when a descriptor was created allows you to only scan the blockchain from that
point on.  As we've discussed with Craig Raw when he was on, who is the author
of BIP393, especially for silent payments, the scanning is so expensive that
this is a huge speed-up to be able to know exactly from what height to scan.

So, in the context of using output descriptors as an element of wallet backups,
it is interesting to have this meta information.  And if I recall correctly,
BIP393 adds exactly three kinds of metadata.  Was it the height and -- well, I
shouldn't have even started that if I don't remember!

**Mike Schmidt**: Block height, gap limit, max label.

**Mark Erhardt**: Wonderful, thank you.  So, max label only applies in the
context of selling payments.  The gap limit, of course, is a hint for wallets,
describing sort of how many addresses they tend to give out between payments in
average, or in the extreme.  And if you have a higher gap limit, you would
generate more addresses or output scripts in advance before scanning, and fill
up the bucket more quickly while you're scanning, which would potentially allow
you to find the history of your wallet more easily, but also mean that if the
gap limit is too high, create way too many output scripts.  And that is an
expensive operation on devices with little compute, and would probably be a
little harder to scan.  So, you kind of want a semi-accurate gap limit.  In case
of doubt, just 10x it or something.

**Gustavo Flores Echaiz**: Makes total sense.  Thank you, Murch, for adding
that.  And listeners who want to learn more about this, the Newsletter #294 and
its accompanying podcast episode, Craig Raw was invited to talk about this more
in detail.

So, the next one, we just covered it at the beginning of the episode, which was
the merging of the PRs BIPs #2118, which merges BIP440 and 441.  So, you can
listen to the beginning of the episode to hear Julian tell us more about that in
detail.

_BIPs #2134_

And finally, the last one, which is not so huge newsworthy, but we kind of had a
light week, so we still included it, is BIPs #2134, which updates the BIP352
specification around silent payments to warn wallet developers not to let policy
filtering affect whether scanning continues after a match is found, right?  So,
if you completely ignore, for example, dust, or you apply policy filtering when
scanning for a wallet, you will, for example, skip dust outputs and consider
that no match was found at that height.  And then, your wallet stop limit or
stopgap will simply arrive faster and you will miss later outputs from the same
sender.  Yes, Murch?

**Mark Erhardt**: Here, this is especially in the context of silent payments.
You can theoretically, it doesn't really make sense to do this, but
theoretically you could be paid multiple times in a single silent payment
transaction.  And the way the silent payments construction works is because the
output script depends on the inputs in that same transaction, if you were paying
the same recipient multiple times in a transaction, all of the outputs would
have the same output script.  And obviously, the whole point of silent payments
is to have a reusable payment instruction that does not reuse output scripts.
So, when you pay the same recipient multiple times, you increment a counter in
the generation of the output scripts, so the output scripts actually look
unrelated.  And because the recipient doesn't know which of the outputs paid the
recipient, when a silent payments recipient or a silent payments user scans P2TR
outputs, they have to scan every single P2TR output on the transaction to see
whether their first output exists.  And then, they can check if a second output
exists and they have to scan all outputs again.  And if a second one exists, you
have to check, does a third one exist?

The warning here very specifically is if you ignore, for example, dust outputs
and stop scanning because you didn't check whether a dust output was for you,
you might overlook a second output that has a larger amount that is derived from
a higher index and the incremented counter.  And that would be a mistake.  So,
you have to actually check all the outputs, even if they're dusty or something,
to see whether one of the other outputs pays you and you can only stop once you
do not find an output that pays you at that index.

**Gustavo Flores Echaiz**: Understood, that makes a lot of sense and I guess it
just amplifies the fact how expensive it is to scan for silent payment outputs.
Thank you, Murch.

**Mark Erhardt**: Yeah, we've been reporting on this, the accompanying debate
around this point, with like, how many payments to the same recipient should be
allowed in a silent payments output?  How many outputs should be allowed in
general in a silent payments transaction?  And so the developers and researchers
that work on silent payments have been spending quite a bit of time thinking on
that edge case.  And this is sort of another follow-up just to clarify very
specifically to implementers of silent payments that they do not overlook any
outputs that might pay their recipients and their users.

**Gustavo Flores Echaiz**: Right, even in a scenario that doesn't make that much
sense, but awesome.  Thank you, Murch.  That completes this section and
completes the whole newsletter.

**Mike Schmidt**: We want to thank Julian for joining us and hanging on today.
I thank my co-hosts, Murch and Gustavo, and you all for listening.  We'll hear
you next week.  Cheers.

**Mark Erhardt**: Cheers.

**Julian Moik**: Thank you, guys.  Cheers.

**Gustavo Flores Echaiz**: Thank you.

{% include references.md %}
