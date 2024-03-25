---
title: 'Bitcoin Optech Newsletter #293 Recap Podcast'
permalink: /en/podcast/2024/03/14/
reference: /en/newsletters/2024/03/13/
name: 2024-03-14-recap
slug: 2024-03-14-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by ZmnSCPxj, Anthony Towns, and Armin Sabouri to discuss [Newsletter #293]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-2-14/ffe08cf8-f077-6795-7793-18b0bd365b99.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #293 Recap on
Twitter Spaces.  Today we're going to be talking about onchain betting on soft
forks; we're going to talk about a variant of the Lisp programming language
that's used by the Chia cryptocurrency and how that might be applicable to
Bitcoin; there is a Bitcoin Core PR Review Club, which is actually Bitcoin
Inquisition this go around, that has to do with OP_CAT; and then we are also
talking about Bitcoin Core 27.0rc1, in addition to notable code changes and a
couple of other releases.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink, funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: ZmnSCPxj?

**ZmnSCPxj**: Hi, I'm ZmnSCPxj, I'm some random person on the internet who is
definitely not a cat and definitely does not have plans to take over the world.

_Trustless onchain betting on potential soft forks_

**Mike Schmidt**: Well thanks for joining us, ZmnSCPxj.  The first news item is
actually about your post to Delving Bitcoin.  ZmnSCPxj, you posted a Delving
Bitcoin about a protocol for using a UTXO for betting on whether or not a
particular soft fork will activate.  Maybe you can walk us through that
conceptually and then also the details that you jump into for doing such a
construction for specifically activation of OP_CTV.

**ZmnSCPxj**: Right, so the basic construction only actually works for OP_NOP,
for replacements of OP_NOP.  So you have to realize that CTV is old enough that
it predates taproot activation, and therefore it used OP_NOP replacement rather
than replacing an OP_SUCCESS opcode in taproot.  So, the big issue with using
OP_SUCCESS actually is that it always succeeds if it gets parsed as an opcode in
the script.  So, that's the big difference here between OP_NOP and OP_SUCCESS.
With OP_NOP, an older version will just skip over this opcode and not do
anything, but it will still actually execute the rest of the script versus
OP_SUCCESS, which does not execute the rest of the script.  Now, an older
version, a pre-soft fork version will accept a witness or a transaction that
will violate the rules of a post-soft fork, meaning for an OP_NOP replacement.
So, in the case of OP_CTV, we can determine whether this particular blockchain
is CTV-activated by deliberately violating the CTV rules.  So, by deliberately
violating the CTV rules in a piece of script that has OP_CTV in it, we are also
ensuring that it can only execute on a blockchain that does not have CTV
activated.  And by executing, if it executes on a blockchain successfully, then
we know that the blockchain does not have this CTV activated.

So, what we now do is that the other side has a timelocked branch from the same
UTXO to be able to differentiate between a CTV-enabled versus CTV-disabled
blockchain.  So, if the blockchain actually has CTV enabled, then after the
timelock, the other branch, which requires a violation of CTV to be executed
correctly or to be executed successfully, that UTXO cannot be spent using that
branch and the timelock branch can now execute, which now goes to the person who
wants to have coins on a blockchain that has CTV activated.  So, now we can have
a single UTXO that has different histories depending on whether CTV activates or
not.  And that is the base layer that we need to do futures or other kinds of
operations, like betting on which activates or whether it activates or does not
activate.  So, basically that's the whole run-through.

**Mike Schmidt**: Okay, go ahead, Murch.

**Mark Erhardt**: Oh, I just had a small comment on the activation of CTV.  So,
yes, CTV is older than taproot and therefore was originally built around the
OP_NOP4, replacing OPNOP4, but when proposed to change it to a OP-SUCCESS code,
people were also interested in using bare CTV in the outputs, which would save a
few bytes.  So, I think there's even other reasons than just it being old, that
it still uses the replacement of OP_NOP4.

**ZmnSCPxj**: Yeah, that's correct.  But basically, this technique only works
when you're looking at the activation of an opcode that replaces an OP_NOP.  It
doesn't work for OP_SUCCESS.

**Mike Schmidt**: I think we actually get into some of the OP_SUCCESS versus
OP_NOP discussion later in the newsletter with regards to OP_CAT, but we can
maybe save that discussion for then.  So, ZmnSCPxj, it sounds like if you have
two people, one wants to bet that it will activate by a certain timeframe and
one betting against that, the coins from each person are then placed into a
single UTXO, and I guess it could be one-to-one ratio or you could put in
different amounts of coins depending on what the odds are, I guess, of
activation.  And those coins are locked in a UTXO and there's two spending
paths.  One is essentially the activation of CTV and that one has a longer
LockTime than the other.  Is that correct?

**ZmnSCPxj**: Yes.  The one which activates the OP_NOP replacement opcode is the
one with the later LockTime.

**Mike Schmidt**: Can you explain that to me?  I guess I don't intuitively
understand why that is the longer timeout one.  I guess I would think it would
be the first one.  Like if it activates, then I'm the one who bet that it would
activate, I would take the coins.  But if it didn't activate, then the longer
timeout would go to, I guess, the default non-activate status.  Can you help my
intuition there?

**ZmnSCPxj**: The intuition here is that we can prove that the CTV was not
activated by violating the rules of CTV.  However, if you follow the rules of
CTV, you cannot differentiate between a blockchain which activates it and
imposes that rule, versus a blockchain that does not actually impose that rule,
because you're still following the rules.  And you're following the rules but
you don't know if it will be actually guarded or checked or validated by the
actual blockchain that you are using.  This is why you are actually checking if
the blockchain did not activate this particular soft fork, and that's why it
comes first.  And then the one that says, "Oh, yeah, it will activate", is the
one that goes second because it gives time for the first one to say, "Hey, on
this blockchain, it did not activate, therefore I can violate the rules of
whatever [or] this one is OP_CTV, whatever, and then I can get the points and
then the second branch never manages to trigger because it's too late, it's at a
later timelock.

However, if in this blockchain then the soft fork did activate, then the rules
have been applied and this branch which tries to violate this op code will not
be able to trigger, it cannot work, and therefore after some time, the remaining
branch is the timelock which goes to the person that says, "Oh, yeah, I want my
coins to live on a blockchain that has the soft fork activated".  So basically,
we are proving that CTV was not activated, or whatever soft fork was not
activated, and then we're inverting that logic by using a timelock.

**Mike Schmidt**: I understand.  Okay, so the point of confusion that I had was
that the first conditional is that you're actually violating the rules of CTV.
So, that was the part that I didn't understand.  Okay, that's clear now.
ZmnSCPxj, we noted in the newsletter that this is potentially an idea inspired
by Jeremy Rubin's bet around, or not his bet, but his construction of a similar
way to bet for taproot activation.  Was it just a matter of swapping the taproot
violation for the CTV violation, or was there something more deeper to the
change that you made with this?

**ZmnSCPxj**: Sorry, I don't actually remember the details of that construction,
so I'm not sure what the differences are.

**Mike Schmidt**: Okay, no problem.  So, it sounds like you maybe came up with
this somewhat independently then, if you don't have Jeremy's scheme in mind at
the moment.  Murch, any follow-up questions?  Are you ready to place your bets?

**Mark Erhardt**: No.  But yeah, I mean that seems reasonable.  OP_NOP means
that there is no operation while it is being executed.  So, if we can just parse
by the script during execution, we can run one branch.  And if the execution is
actually encumbered by some rules and we have to follow those rules, a different
thing must happen.  That sounds like a useful construction.  I'm just thinking
with the OP_SUCCESS code, I guess you could do something similar like that if
you basically put the OP_SUCCESS in a branch where it can only be reached if the
rules are not active.  But I mean, I assume you would be able to build notably a
different construction, but somewhat similar.

**ZmnSCPxj**: The problem is that OP_SUCCESS immediately succeeds as soon as it
gets parsed.  This is before execution of any script.  As soon as it gets
parsed, it passes.

**Mark Erhardt**: Oh, okay, then I'll take that back.

**ZmnSCPxj**: Yeah, which is why it cannot work with OP_SUCCESS, because if you
try to use an OP_SUCCESS and you violate this, it's like the rules is that
anyone can spend this branch.

**Mike Schmidt**: Murch with the thumbs up.  Okay, cool topic, interesting idea.
ZmnSCPxj, anything else you want people to know about what you posted about
before we move on?

**ZmnSCPxj**: Not particularly.  The issue here I guess is that it only works
for OP_CTV and cannot work for OP_1, no, what they call this OP_INTERNALKEY or
OP_CHECKSIGFROMSTACK (CSFS), which are the other bits of LNHANCE.  Now, the
problem here is that OP_INTERNALKEY cannot be implemented as an OP_NOP because
it specifically exists to reduce the witness size and extract the internal key
from the taproot and push it on the stack, which cannot be done by an OP_NOP, it
has to be an OP_SUCCESS.  Now, if all of these changes were packaged in a single
soft fork, then you could write it off OP_CTV.

**Mike Schmidt**: Makes sense.

**Mark Erhardt**: I have a follow up question at this point.  So, what would be
the application of this bet?  Would you say basically people could do something
like the segwit2x futures to bet on the outcome of the soft fork, or to use it
as signaling; or, what did you have in mind, why are you proposing this idea?

**ZmnSCPxj**: So, the idea is that, yes, it can be made as the basis of a scheme
for futures that does not require as much trust in some kind of exchange doing
things honestly, you know, reduces rugging risk.  But otherwise, yeah, it's just
a trust-minimized way of basing soft fork activation futures.

**Mike Schmidt**: Anything else, Murch?

**Mark Erhardt**: No, that makes sense to me.

**Mike Schmidt**: ZmnSCPxj, you're welcome to stay on and chat some of these
other items.  Otherwise, if you have things to do, we understand, and you're
free to drop.

**ZmnSCPxj**: Yeah, sorry, it's kind of late here on my time zone, so, yeah.
Bye, good night.

**Mark Erhardt**: Thanks for joining us.

**ZmnSCPxj**: Okay, bye, you're welcome.

_Overview of Chia Lisp for Bitcoiners_

**Mike Schmidt**: Next item from the newsletter is titled Overview of Chia Lisp
for Bitcoiners.  And this is a post from AJ Towns on the Delving Bitcoin forum.
AJ's been talking about, on and off for I think two years now, this idea of
using the Lisp programming language in some way with Bitcoin.  The Lisp
programming language -- oh, AJ's here, right on time, before I butcher your news
summary, AJ.

**Mark Erhardt**: Hey, you prepared it.  Come on, let us hear it.

**Mike Schmidt**: No way, not in front of AJ!  If AJ has a speaker.

**Mark Erhardt**: Well, I did invite him already.  But why don't you go ahead
anyway, because I don't know, he's not accepted yet.

**Mike Schmidt**: Sure.  We were talking about Lisp programming language.  It's
an abbreviation for Lisp Processing, and it actually originated in the 1960s,
and it's actually one of the oldest programming languages still in use today.
But this week, we covered AJ's post providing a primer of Chia Lisp with a
target of Bitcoiners.  And Chia Lisp is a variant of the Lisp programming
language and it's running currently on the Chia blockchain, which I don't know
anything about.  AJ starts the post off with, "Why would this be worth thinking
about at all?"  And he points out two things that Bitcoin's Script language,
which currently writes smart contracts and do programming with in Bitcoin, can't
do well, which is (1) looping, and (2) the handling of structured data.  He
notes, "The approach Chia Lisp takes addresses both of these limitations in
perhaps the simplest way possible".  AJ, how does Chia Lisp address both of the
limitations that you noted in your Delving post?

**Anthony Towns**: Hello, can you hear me?

**Mike Schmidt**: I can hear you.  Can you hear us?

**Anthony Towns**: Yeah, cool.  Apparently, I reinstalled Twitter, so I have to
re-enable microphone permissions by going through some process.

**Mike Schmidt**: I set the stage for you, AJ, which is I sort of gave an
overview of the history of Lisp and the fact that you're talking about Chia Lisp
from the Chia blockchain.  You mentioned two things that Bitcoin Script isn't
good at, looping and structured data, and then that's where we stopped.  So,
maybe you could reframe some of that or you can kind of address those two
components.

**Anthony Towns**: Sure.  So, the basic idea for Lisp is that it's a functional
programming language, and the way you do loops in functional programming is by
recursion, so you have the function call itself however many number of times you
need the loop to continue.  And the way that Chia does that is it just has an
opcode that says, "Run this bit of code", and you can parse the bit of code to
the bit of code you're running, which lets you do recursion, and that gives you
looping.  And that basically gives you more or less all the looping sort of
constructs you need with just a single opcode.  And the reason it can do that is
because what you're parsing to that opcode is kind of structured data that
represents a program.  So, that structure can contain all the conditions for the
looping, so if it's a for-like loop or if it's a while-like loop, or whatever,
and that then gets to the other part, which is the structured data.  And the
structured data of it, because it's Lisp, it's all lists, which is, as far as I
can think of at least, the most basic sort of structure you can get.

Lisp has been around long enough that we know that even that simple amount of
structure is enough to do pretty much whatever you might want to do.  Even if
it's not in the most pretty way possible, it's still at least possible.  And
keeping what you put in consensus as simple as possible seems like a good
strategy.  So, those were the two kinds of things that added up to me as a
really good approach; keep things simple, but still have it be basically as
powerful as anything can be.  And I had a look at other sorts of languages.
Like, you can do stack-based languages like Script.  But instead of just putting
a number or a byte string on the stack, you put basically a stack itself on the
stack, so you can have recursive stacks.  And that, I think, is exactly as
powerful as doing basically recursive lists in Lisp, but it also seems pretty
confusing and not very popular.  So, why do something strange just for the heck
of it?  Why not go with something that's pretty well understood, is the way I
think of it.

**Mike Schmidt**: AJ, what's your big-picture vision for exploring this idea?

**Anthony Towns**: So, a couple of hours ago, I posted the follow-up post, which
was what a Lisp for Bitcoin would look like rather than a Lisp for Chia.  So,
maybe that'll get summarized in the next Optech or the one after that, and we
can talk about that then.  But the basic idea is that Chia Lisp is obviously
designed for Chia, which works in a slightly different way to Bitcoin.  But if
you kind of pull out those differences and just keep the stuff that makes sense
for Bitcoin and add some opcodes that make sense for Bitcoin that wouldn't make
sense for Chia, then you can pretty much just drop in replace scripts with a
Lisp thing that takes the same sort of inputs and gives the same sort of output,
ie valid or invalid, but lets you write more complicated expressions.  And I
think with the way taproot's designed, we can drop in that as a separate
language, and that's already been kind of explored a little bit on Liquid with
their changes to script, that is kind of a separate script to BIP342 tapscripts
arguably, and the Simplicity work has also been designed that way and seems to
work that way, so I'm pretty confident that'll work.

So the question is more, well for a start, just doing the work to actually
implement all that so that you can use it, and then working out if there's
actual interesting things to be done with it once you've got that flexibility.

**Mike Schmidt**: Okay, so I've heard this with Simplicity that it could be
introduced via a new tapleaf version, and so then I guess the script that you
would be providing would just not be in Bitcoin Script, it would be in this BTC
Lisp?

**Anthony Towns**: Yeah, exactly.

**Mike Schmidt**: Okay, cool.  How would you contrast BTC Lisp with Simplicity,
and what are your thoughts on simplicity?  Maybe you can weave that in as well.

**Anthony Towns**: So, there's a few different levels you can look at it.  On
the really fundamental level, it's really two different ways of saying pretty
much the same thing, like there's some subtle differences in that at least the
way Chia and the way I think about Lisp is that you have lists of arbitrary byte
strings, so the byte strings can be as long as will fit in a block, and that's
essentially all the same type.  Whereas in Simplicity, the length of byte
strings is much more fixed as part of the type system, and that slightly changes
the sort of way you express things, but that's really technical more than
fundamental, I think.  But on the other side of things, Simplicity goes into a
lot more detail about what opcodes there are.

So, as a for instance, the SHA256 in Chia Lisp is a single opcode that does
SHA256.  In Simplicity, there are six opcodes for doing that.  So, there's one
for getting the IV, there is one for adding data to a block, there is one for
finalizing a block, and I forget what the other three are.  And so, it ends up a
fair bit more fine-grained.  And I'm not sure how valuable that is, and I think
it makes things a lot more complicated.  So, I mean it's hard to say without
really being able to see what an implementation of a real script looks like in
basically either Lisp or in Simplicity.  But that's my rough take on the
differences, the main differences, I guess.

**Mike Schmidt**: Murch, what do you think?

**Mark Erhardt**: Yeah, I was curious, how do you perceive the time until
arrival for if we started working on something like Bitcoin Lisp, which
apparently is already deployed on other systems, where we could very heavily
lean on prior work, and Simplicity, which also has been progressing for a long
time, but it feels a little untransparent to me where exactly or how far it
exactly is by now?

**Anthony Towns**: So, as far as implementation goes, Simplicity has the
disadvantage that it's coming from fundamentals.  So, it has the calculus of
simplicity, like the four or five axioms that let you build up the entirety of
mathematics from it, and that's then implemented in a proof system.  And then
everything's implemented in Haskell and then everything's implemented in C on
top of that.  And I mean, all of that is done, like there is code in the
Simplicity GitHub for all that, and I haven't tried building or running it.  But
as far as I can tell, it should all work.  And then there's the step of
integrating that C code into Bitcoin and the step of actually writing that all
up in a BIP that people are going to accept.  And all that formalism is very
complicated and because it's broken up into so many steps, so like there's a
specification of all the details of SHA256 in order to specify the opcodes that
do SHA256, and ditto for SHA3, and ditto for secp, and every other operation
that there is in there; and so, specifying that is a lot more complicated than
just hand-waving and saying, "Oh, this opcode does SHA256".

**Mark Erhardt**: Given that it's implemented in Coq, a formal proof system, and
we know what the output of SHA256 should be for certain inputs, could we maybe
just prove that it does what it does?

**Anthony Towns**: That is definitely the principle, but there's the question of
how confident you are that the proof that's written out is correct, and how
confident you are in all the tooling that connects all these things together.
The steps from the Coq code to the C code, I'm not sure how well connected that
all is.  And there is just plain a lot of code/text in all of that to review.
And I mean, doing the code that I've got at the moment is a couple of thousand
lines of Python by comparison, which I mean is pulling in all the SHA256 and the
secp stuff from the Bitcoin Core test suite, so it still is kind of as
complicated, but the stuff that you review is smaller.  So, I've looked at the
Simplicity PR a couple of times, and it just scares me trying to figure out how
you might even start to review that.

**Mark Erhardt**: Yeah, so I'm getting a little bit of a sense, if I'm reading
between the lines here, that the Simplicity work is maybe a little too
complicated to review easily and such a big chunk of work to actually formally
prepare, that it would really help if we had some steps to get there in between,
but it's just this humongous mountain by itself.  And it might be a case of
perfect is the enemy of good, where you do something much simpler but get many
of the benefits, even though maybe not provably so?

**Anthony Towns**: Yeah.  And I mean, the other thing I'm not sure about is how
-- so, the idea with Simplicity is, while you can build up all of mathematics or
logic, or whatever, from like bare bones ones and zeros, in practice you have
JETs that codify all the logic for the common sort of operations and do it
quickly.  And one way of looking at those JETs that was the original way, is
that the JET is specified as the SHA256 hash of all the code that goes into it.
And doing it that way makes your opcodes be 32 bytes instead of 1 byte, which
seems kind of lame, but equally you can just have an encoding of all those long
strings that essentially compresses those common 32-byte strings to 1 byte, and
that gets you more or less back to just having 1-byte opcodes for the things
that you want to do.

So, apart from that caveat that I said earlier about Simplicity having
fixed-size strings and the Lisp stuff having arbitrary-size strings, I'm not
really sure that you couldn't just specify all the interesting parts of Lisp as
essentially JETs in simplicity, and then leverage all the proof that you've done
with Simplicity in designing that to get you up to a proof of the Lisp stuff
working the way you hope it would.  So, I mean mostly I think they're two
separate ways of approaching the problem, but I don't think they're
fundamentally in opposition.  But like I said, I haven't done things with
Simplicity, so take that with a grain of salt.

**Mark Erhardt**: Right.  From how it was described to me earlier, I thought it
was two competing approaches, but that's an interesting way of seeing how they
could maybe compound into a stepping ladder to get the more complex system
integrated with a simpler framework to make it maybe deployable more quickly.

**Anthony Towns**: Yeah, and I mean the way the way the Chia Lisp stuff was
developed was by looking at the work that was going on in Simplicity and taproot
and graftroot, and figuring out ways to get all the at least easy wins from all
that stuff and to do other stuff on top.  So, they've got a lot of the same
ideas as well.

**Mike Schmidt**: AJ, what are you looking for from the community at this point?
Obviously, read your materials, be educated on it.

**Anthony Towns**: Yeah.  It's, yeah, like I said, I've made the second post in
it, which talks about what the Python stuff does and gives a bit of an overview
of what I think it looks like in the Bitcoin context rather than the Chia
context.  And the next thing I want to do is give an example of something
actually interesting/useful that you could do with it, in the vein of eltoo or
OP_VAULT, or that sort of thing.  And, yeah, from that point, it's a matter of
implementing it on Inquisition, I guess.

**Mike Schmidt**: Speaking of Inquisition, actually our next item is a PR Review
Club about Inquisition.

**Mark Erhardt**: Sorry, I had one more follow-up question, just a very quick
one.  I see that in your Delving Bitcoin thread, Russell O'Connor and Bram Coehn
both weighed in.  Did they have some interesting thoughts on the comparison of
Simplicity and Chia Lisp?

**Anthony Towns**: Let me look up what Russel said.  Yeah, so Bram's comments in
particular, that Chia has -- oh I put this.  So, the thing I've skipped over a
lot in this is how Chia's coin set model works versus the UTXO set.  So, rather
than having the transaction as the base unit like we do in Bitcoin, Chia has the
output coin be the base unit.  And it makes things a lot easier for some sorts
of NFTs and covenant constructions.  And it's really cool in that sense, but
seems like it would be really hard to do some sort of smooth upgrade for Bitcoin
to adopt that, that doesn't involve essentially having your node stop and parse
through the entire UTXO set and regenerate it with some extra data, or something
like that.  So, I've been pretty much ignoring all the sorts of cool things that
you could do that way, and Bram is bringing up some of the cool things there, I
think.

Russell had a couple of comments.  One was on the soft fork thing, and we had a
quick back and forth about that, and it sounds like the way that Chia does the
soft fork stuff turns out to be a good solution that could also work in
Simplicity, so that sounds cool.  And he also talked about delegation.  So, one
of the neat things about Chia Lisp is that, so the way we do a standard
transaction, I guess, in Bitcoin is that we have this taproot construct.  So,
you choose an address that matches the taproot formula, and that lets you have a
keypath and it lets you have a multitude of scriptpaths.  The way that it works
in Chia is that there aren't standard patterns like we have in Bitcoin these
days.  Instead, everything is script like it was in Bitcoin originally.  And the
standard scripts that they have let you do the operations like taproot, where
you plug in a hash reveal of the complicated scripts that you want, and prove
that it adds up via the elliptic curve stuff.

So, some of the cool stuff they've got in Chia is that they've already got
graftroot as part of their standard transaction because they can program that in
Lisp.  And it's a similar sort of thing in Simplicity, where the whole idea
behind the way that the witness data works is that that is just going to be a
simplicity program that gets called from the simplicity program in your public
key that you've committed in your UTXO.  And that new script that's called as
you spend it can do more complicated stuff and eventually include new features
from soft forks, or whatever.  And, yeah, so that's one of the other things that
he mentioned.

**Mark Erhardt**: Cool, thank you for this look over the edge of what's going on
in Bitcoin.

**Anthony Towns**: The edge of the cliff of the future of consensus.

_Re enable `OP_CAT`_

**Mike Schmidt**: AJ, I mentioned Inquisition.  We actually have a PR Review
Club that covered Bitcoin Inquisition #39, which is re-enabling of OP_CAT.  And
we have yourself, and we also have Armin here.  Armin, do you want to introduce
yourself really quick?

**Armin Sabouri**: Hey, guys, good morning, Armin here.  I've been hacking on
Bitcoin things for the last four or five years.  I was building multisig wallets
at Casa, starting 2019, and as of the last year, I've been taking an interest
into protocol development.  So, I've been doing some sidechain research as my
day job, and in the last couple of months I've been focusing on Bitcoin Core.

**Mike Schmidt**: Thanks for joining us.  I know that you and AJ are going back
and forth on the PR to Inquisition.  Maybe, Armin, it would make sense for you
to provide an overview of re-enabling OP_CAT on Inquisition, and we can talk
about that high level.  And then, maybe if you and AJ want to riff a little bit
at a lower level, we can go from there.

**Armin Sabouri**: Yeah, totally.  So, I guess, how did this thing start?  Ethan
Heilman, he's the other author on the OP_CAT BIP, we were just talking one day,
and he's been thinking about CAT as others have for years about all the cool
things that you could build with it.  And as he was explaining all these
different use cases to me, I realized this can actually solve some of the
problems in sidechains and layer 2 designs as well.  And so, the next thought
was, we should just put together the BIP and see how that goes.  And originally,
I was just taking a look at his BIP, looking over some of the use cases, and I
added a few things, and he asked if I could take a look at where this could get
activated.  And that's where we found Inquisition.

So originally, I thought we would just hack something together on regtest and
pass that around and implement some of these use cases.  But Inquisition seemed
like the next best fit, I guess, and that's where I opened the PR.  And AJ's
just been helping me review, helping me with activation parameters.  And fast
forward a couple months later, that's where we ended up with the Bitcoin Review
Club.  So, we wanted to get a few more people's eyes on this, just the fine-edge
cases, which we did.  Actually, out of the Review Club, I think we found two or
three different things that needed to get fixed.  Some builds were failing on
various versions of GCC, those kinds of things, yeah.

**Mike Schmidt**: AJ, what's your take on OP_CAT and maybe a perspective from
Inquisition?

**Anthony Towns**: I find it hard to believe that OP_CAT is a sensible thing to
do.  It always seems so, I don't know, trying to make an Iron Man suit in a cave
with a box of scraps.  We should be able to have better tools than this.  But
equally, if we can't have -- OP_CAT is the most basic thing, so we should be
able to get that as well, it should be easy.  So, yeah, I think we should be
able to do better things than it, but it's such a super-basic thing that we
should have it in the first place.  And so, at the very least, it should be a
good test of, can we get things into Inquisition and try them out?  And if I'm
wrong and we can get cool stuff built with just CAT, or just CAT and CSFS, or
whatever other things that we've got in Inquisition, then that's pretty awesome
too.

**Mike Schmidt**: And maybe just clarifying for folks, I saw in the PR that
there was actually people NACKing this PR, maybe not having the full context of
the purpose of Inquisition.  AJ, maybe you want to just maybe give a quick
summary of why we would want OP_CAT in Inquisition, even if you're not
necessarily a supporter of OP_CAT?

**Anthony Towns**: So, just to give a quick summary of why my understanding of
why people might NACK it in the first place, a lot of people are concerned about
too much programmability in Bitcoin being a kind of, I don't know, a temptation
too far, and that if you let people program stuff, they're going to let
governments program them into a corner so that Bitcoin no longer works the way
that they want it to.  And I'm not the best advocate for that position because
that's not my position, but it's also not completely implausible or
unreasonable.  So, I'm not sure that CAT is alone the worst example of that.
Like, all the LISP stuff is definitely a bad example if you're concerned about
programmability becoming a problem.  But insofar as CAT and CSFS, or CAT and
just regular CHECKSIG let you do crazy things if you put them together in
complicated ways, and I guess Andrew Poelstra probably gave a talk on this
today, which might be online or something somewhere, but you can look at it as a
foot in the door of horrible things, essentially.

So, that's a good reason to be concerned about activating it on mainnet, but the
whole point of Inquisition is to catch heretics or people that aren't going the
right way, or ideas that aren't going the right way, and nail them down and work
out exactly what they're doing wrong.  And so, at least my view is that that's
still a good reason to enable these features on the test network, work out
exactly how they're going to misbehave, and then we can say, "Look, this isn't
just FUD, it's not just a random concern that we have, it's not just fear, it's
not just scary.  This is a specific way that it can be used to attack us, cause
problems, make you lose money, make you not be able to spend your money, make
you be more vulnerable to censorship, all the whatever bad things it actually
enables".  We can be specific about how it enables those bad things and what the
impact of those bad things actually is.  And so, that's at least my view, that
we should have somewhere that we can investigate this on a real live network,
make it have real evidence that we can show to people, "This is exactly what
went wrong, and this is exactly why we shouldn't do it on mainnet".

Conversely, if we can't show problems, if we were just scared and the problems
aren't real, we can't demonstrate them, and in contrast we can demonstrate that
actually good things happen with these opcodes and they make LN better or they
make self-custody more safe, or some other thing like that, then knowing that
gives us a good reason to activate them on mainnet.  So, I think having the
features available on a test network so they can be investigated and just be
better understood and give us a better idea of what's good and bad about them,
is a much better approach.

**Mike Schmidt**: Murch, did you have a comment or question?

**Mark Erhardt**: I just wanted to say that while there are certainly the people
that think about the concern with too much programmability might elicit a wish
by governments to restrict Bitcoin usage to certain patterns, I think there is
also not a position that I necessarily subscribe to, but there's a broad mass of
people that just have undefined concerns about adding new features because it
might break things in unexpected ways.  A lot of people have the
misunderstanding that taproot broke Bitcoin in some ways because, of course,
we're seeing the inscriptions going on now.  And well, I think that there's a
few different camps that have different flavors of this concern that aren't
necessarily always well expressed.  I wanted to give Armin a chance to chime in
a little more on this, because AJ spoke a bunch about his position on OP_CAT and
I wanted to hear whether Armin has a response to that.

**Armin Sabouri**: Yeah, just to touch on these kind of NACKs and maybe the
ossify crowd, so I'll just echo what AJ said.  I think that was said perfectly.
This is a really good space.  The Inquisition Network is a really good place to
have mainnet conditions to prove those things out.  I mean, that's the whole
purpose of doing it on Inquisition.  So, I think those opinions are valid, they
just need to be backed up a little bit.  I expect more of them to come, but I
also think that's also a good measure of the system working, right, because soft
forks are not supposed to be easy to do.  If it was easy to do, and you just
have one every year, that wouldn't really be Bitcoin consensus because Bitcoin
consensus is really, really hard to change.  So, I guess my point is that this
is the system working.

I forget what AJ's original comment was about CAT, I think maybe that we should
have this and other things.  I think that's totally true.  We saw some use cases
of people building covenants, kind of the Andrew Poelstra fashion of doing it
without CSFS, and those have interesting trade-offs.  So, I agree that CAT
shouldn't be the final thing, but it's a really good first step.  And the reason
for that is because it does offer a wide variety of use cases with little
complexity, making it a really good candidate for Bitcoin consensus change.  So,
people are really excited to use CAT for covenant things, I think that's great,
but I do think there are better opcodes out there, whether it's TXHASH or CTV,
or something else, yeah.

**Mark Erhardt**: So, AJ, did you want to chime in?

**Anthony Towns**: Yeah, so one thing that CAT actually works really well for is
all the BitVM stuff.  So, one of the annoying things about BitVM is that the
only thing it can do is what I call NAND operation, like 1-bit NAND operations.
But once you add in CAT and SHA256, I think that's all you need.  You can extend
that to have a single operation operating on many more inputs, many more
potential inputs at once.  And at least if you think BitVM is a good idea, it
makes it much more efficient, and that, I think, is just with adding OP_CAT,
which is pretty cool.

**Mark Erhardt**: If we had the OP_CAT functionality, could we sort of build
something like a JET on Bitcoin Script where OP_CAT is executed multiple times
in combination with other opcodes, and all of that was packaged as some other
named opcode that just is based on OP_CAT, but does something more complicated?

**Anthony Towns**: I think any time you mention a JET, that is essentially a new
soft fork anyway.  So, it's not really a super-interesting way to think about
things, because if you have a new soft fork, you can add a new opcode that does
whatever specific thing you want anyway.

**Mark Erhardt**: Right, that was silly.

**Mike Schmidt**: Armin, I have a question.  You mentioned earlier that there
were some edge cases found in this PR.  Was it in the PR Review Club that you
all identified that, or was that in the PR itself?  Maybe you can just touch on
that.

**Armin Sabouri**: Yeah, this actually came from the Review Club.  It's small
things.  I noticed a couple people were building on Windows machines or just had
other versions of GCC.  And the way the activation parameters are set up, at
first I didn't think the order of the properties of the struct mattered, but on
certain versions of GCC, they do.  So a couple, like four or five people
couldn't build the PR.  We got that patched pretty quickly.  And there were a
few more edge cases found with the script tests.  So, if you look at script test
on JSON, Ethan had this little mini project of introducing new tapscript
semantics.  So, if you just look at that file, you'll see there's this kind of
new symbol, might be the wrong word for it, but this new semantic that says,
"Auto-generate this control block or auto-generate this witness for this
particular tapscript".  And there were just some small issues there with
counting how many bytes were being pushed, things that should have been failing,
but were passing.  Then we got those patched up as well.

**Mike Schmidt**: Cool.  It's nice to see the Review Club contributing in those
ways.  Armin, anything that you'd say in wrapping up this Review Club?

**Armin Sabouri**: No, I don't think there's anything else to say.  If anyone
else wants to take a look at the PR, it's up on Inquisition, PR #39.  Certainly
looking for more testers, reviewers.  Yeah, thanks for having me today.

**Mike Schmidt**: Yeah, thanks for joining us on short notice.  AJ, anything
else you'd say about OP_CAT, Inquisition, or Chia Lisp?

**Anthony Towns**: No, I don't think so.

**Mike Schmidt**: All right, well you're both welcome to stay on, or if you have
other things to do, we understand and you can drop.  Thanks for joining us.

_Core Lightning v24.02.1_

Releases and release candidates, we have three this week.  First one is Core
Lightning v24.02.1.  It involves a bunch of changes to the pay plugin and a few
fixes to the pay plugin.  So, it seems to be all around this pay plugin, which
is a command for sending a payment to a BOLT11 invoice.  And there's bug fixes
as well as changes to the scoring algorithm, which is used by that pay plugin.
So, if you're using that particular plugin heavily, check that out.

_Bitcoin Core 26.1rc1_

Next release candidate that we highlighted here is Bitcoin Core 26.1rc1.  Murch,
I know you and Harding did a recap last week in which you covered this RC.  So,
that's #292 Recap for folks who are interested in discussing this particular
item.  Murch, I think the summary was a bunch of small issues and bug fixes.  Do
you have anything that you'd add to that this week?

**Mark Erhardt**: No, just as I said last week already, the maintenance
releases, so that's the ones with a number after the dot, they are primarily
follow-up releases that fix issues in the major releases, and we only ever
release new features in the major releases.  So, generally in a maintenance
release like 26.1, you would only ever be looking for bug fixes.  Very, very,
very occasionally some back ports of something, but just in the sense of fixing
it, but not introducing a feature.

_Bitcoin Core 27.0rc1_

**Mike Schmidt**: This week, we also covered Bitcoin Core 27.0rc1.  We have our
resident Bitcoin Core developer, Murch, as well as AJ.  Murch, maybe I'll give
it to you to summarize whatever you see fit with regards to this particular RC.
I know we didn't go into the details on the writeup, but maybe there's some
things that you'd like to say.

**Mark Erhardt**: Yeah, so 27 is a little funny in the sense that we changed the
release schedule.  We had sort of been doing the feature freeze six months after
the previous feature freeze for a while, and it kept slipping a little more and
more and getting close to the holidays on either end.  And now, with 27, we're
going to a fixed schedule where we aim for a release in early April and a
release in early October.  So, this release cycle has been a little shorter than
usual.  The last release was only four months ago.  And so, what you might be
able to see in this release because of that is that there are fewer features
included in this one.  I just went over the PRs and issues that were tagged for
this milestone, and there's a lot of bug fixes.

As far as I can tell, the main two features are that the v2 transport will be
enabled by default in 27.0.  This is the encryption of traffic between Bitcoin
nodes that we've talked about extensively in the past months.  And then, well,
yeah, I think that's the main new feature and there's also a fix in the coin
selection that I'm pretty excited about personally, where at very high feerates,
we will now look for the absolute minimum weight in the input set to build a
transaction.

**Mike Schmidt**: Murch, do you know if there will be a testing guide for this
release?

**Mark Erhardt**: I think it's in the works.  Also, the release notes are still
being written, so I think if I miss something, we'll be able to follow up.
Since we're only on the first RC, I expect that there might be another two
iterations or so, one or two at least.  And yeah, so probably if there's more to
report, we'll know next week.

**Mike Schmidt**: Moving on to Notable code and documentation changes.  I'll
take this opportunity to solicit from the audience any questions you have for
Murch or I, or AJ or Armin, about this newsletter, questions in general.  We'll
try to get to those at the end after these three PRs.

_LND #8136_

First PR, LND #8136, which improves the fee estimation functionality of the
EstimateRouteFee RPC, and it does so by adding two additional parameters.
First, it adds an invoice string as a parameter to estimate the fee for; and
then second, it also adds a probe payment timeout parameter, which the sending
user can use to control how much time the payment should take.  A few of the
comments on this PR actually brought up considerations around probing when an
LSP is involved, a Lightning Service Provider.  I think there's some detailed
comments, but I think the criticism or the consideration comes down to basically
prepayment probes are not compatible with the current LSP protocols, and so
there's a lot of discussion around that.  So, if you're doing LSP work, maybe
take a look at that.

**Mark Erhardt**: I just had a funny thought in the sense, or I mean, it's not a
new thought, but one thing that is interesting about probing is that if you
start probing the moment that you learn about a pending payment that your user
is trying to make, the node already learns updated information about all the
channels along the route, which is the point of probing, of course.  But it's
also not really that different from making multiple attempts of trying to route
the payment itself, because if the first one won't -- well, the difference is a
qualitative one in the sense that if you're making multiple payment attempts,
you're actually trying to send the payment, as soon as you succeed, you're done.
But when you probe, you just learn which route will be conducive to routing your
payment, but then you will need to make fewer attempts later to actually route
it because you have already updated your knowledge about all the channels along
the way.

So, especially if you run an LSP, I would assume that actually your information
about the network and all the channels that you frequently route through is much
more current.  And I would say it's kind of interesting that LSPs probably
generally will have just much higher rates of success because, well, not only
are they well-connected, but they have a very current view of the state of the
network.

_LND #8499_

**Mike Schmidt**: Next PR, LND #8499.  This makes changes to LND's handling of
simple taproot channel, TLV, Type-Length-Value, types  So, we've covered simple
taproot channels previously.  LND is sort of a pioneer on that front, and
they've made changes to the type system or the TLV system behind the scenes for
those simple taproot channel data.  For example, taproot-related TLVs are
nonces, partial signatures, signature with a nonce, etc as examples.  And one
other noted benefit for LND, other than improvements to the API, is that they're
better able to protect against API misuse using this new type system behind the
scenes.  And so, I guess they were worried about people potentially misusing the
API given the current TLV setup that they have.  Murch, any comments on that?

_LDK #2916_

Last PR this week is to LDK, LDK #2916, which adds a simple API for converting a
Lightning PaymentPreimage into a PaymentHash.  In the PR, the author, sr-gi,
noted, "Currently there is no way to build a PaymentHash from a PaymentPreimage,
apart from doing it manually.  This seems like a useful interface to have for
downstream users".  And so, since the hash can be derived from a preimage in
Lightning, receivers and forwarding nodes usually, or could, only store the
preimage, so this API makes it convenient to also derive the hash from that
preimage using that API on demand.

I don't see any requests for speaker access except Murch.  Murch, you have a
comment or question?

**Mark Erhardt**: Yeah, one thing that I actually had noted down and forgot to
mention with the 27 release, in Bitcoin Core 27.0, we will start requiring a
C++20 compiler, and that's awesome for us people working on Bitcoin Core because
it allows us finally to use C++20 features in the code base.  And, yeah, if you
were just sitting in the starting hole and waiting for being able to use C++20
before contributing to Bitcoin Core, this is your sign.

**Mike Schmidt**: Doesn't look like there's any other comments or questions.
Armin, AJ, ZmnSCPxj, who's no longer here, thank you all for joining.  Thanks
always to my co-host, Murch, and for you all for listening.  See you next week.

**Mark Erhardt**: Thanks.  See you.

{% include references.md %}
