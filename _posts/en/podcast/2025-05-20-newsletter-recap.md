---
title: 'Bitcoin Optech Newsletter #354 Recap Podcast'
permalink: /en/podcast/2025/05/20/
reference: /en/newsletters/2025/05/16/
name: 2025-05-20-recap
slug: 2025-05-20-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Eugene Siegel, Chris
Stewart, Bram Cohen, and Robin Linus to discuss [Newsletter #354]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-4-21/400730871-44100-2-1b57ae23da53d.m4a" %}

{% include newsletter-references.md %}

## Transcription


**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #354 Recap on
Riverside.  Today, we're going to talk about a Bitcoin Core vulnerability that's
been recently disclosed; we have a draft BIP for 64-bit arithmetic in Bitcoin;
we have a new approach to recursive covenants; we're going to talk about the
benefits to BitVM from the CTV (CHECKTEMPLATEVERIFY) and CSFS
(CHECKSIGFROMSTACK) proposals; and we have our usual Releases and Notable code
segments as well.  I'm Mike Schmidt, Optech contributor and Brink Executive
Director.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Localhost and on Bitcoin stuff.

**Mike Schmidt**: Eugene?

**Eugene Siegel**: I'm Eugene, I work on Bitcoin Core and I'm supported by
Brink.

**Mike Schmidt**: Chris?

**Chris Stewart**: Hi, my name is Chris Stewart and I'm an independent
researcher on Bitcoin.

**Mike Schmidt**: Bram?

**Bram Cohen**: I'm Bram Cohen, I created BitTorrent back in the day and I'm
working on a blockchain gaming project.

**Mike Schmidt**: Robin?

**Robin Linus**: Hi, I'm Robin, I work at ZeroSync on BitVM and I'm also the
Bitcoin researcher at Stanford.

_Vulnerability disclosure affecting old versions of Bitcoin Core_

**Mike Schmidt**: Awesome.  Thank you all for joining us to represent your work
and ideas this week.  We have one news item, which is titled, "Vulnerability
disclosure affecting old versions of Bitcoin Core".  Antoine hosted a
vulnerability disclosure to the Bitcoin-Dev mailing list in accordance with
Bitcoin Core's recent security disclosure policy.  The vulnerability is of low
severity and was fixed in Bitcoin Core 29.0.  So, versions before that are
affected.  Eugene, awesome that you found this bug and were able to join us
today.  What did you find this time?

**Eugene Siegel**: So, it's the same bug as was reported earlier.  It's just
that Pieter Wuille introduced rate limiting.  And so now, if you wait enough
time, you can overflow the 32-bit counter to defeat the rate limiting, over the
course of maybe a year.  And it's laid out in the in the disclosure that if you
have, like, 1,000 peers connecting and they're spamming you with addr messages
this entire time, it would take a very long time for your node to crash.  So, it
is a very low severity bug.  So, yeah, the fix was done by Martin and it was a
change from 32-bit counter in the AddrMan to a 64-bit counter.

**Mike Schmidt**: So, it's low severity in that it would take a long time to
occur and many parties doing something for a long period of time, but obviously
the fact that it would crash is severe, but it's just sort of a less likely to
happen type scenario.

**Eugene Siegel**: Right.  And so, it is very unlikely to happen, it would take
a very long time.  And I believe your node would have to be up the entire time.
So, if you restarted it to do, like, an upgrade to 29.0, the attacker's progress
is basically lost.  And there was actually one way to trigger the crash that
wasn't really laid out in the disclosure by Antoine.  And it was that if you
gave a peer the addr permission flag, you could crash them as well, but that
requires social engineering.  But anyways, the issue is fixed now completely.

**Mike Schmidt**: Okay.  And for those curious about what Eugene was referencing
about this other issue, it was in Newsletter #314, that we covered the 'before
22.0 disclosures' in Bitcoin Core, and I believe, Eugene, were you on for that
one?

**Eugene Siegel**: I don't think I was.

**Mike Schmidt**: Okay.  Yeah, I guess, Murch, it was you and I talking about
that particular one.  How did you find this particular vulnerability?

**Eugene Siegel**: That one, I had literally printed out the AddrMan file and
then just read it line by line.  I think we could have written a test, or I
could have written a test, where you have a single node getting spammed over the
course of some amount of time.  The issue here is that a fuzzer would not catch
this, because you're sending many addr messages, and when we're writing fuzzers,
we're trying to optimize for very quick execution.  And so, something like a
fuzz test would not have caught this, at least how they're currently written.

**Mike Schmidt**: Murch, any questions or follow-up?  All right, great.  Eugene,
thanks for joining us today.  You're welcome to stay on for the rest of the
discussion, or if you have things to do, we understand, and you're free to drop.

**Eugene Siegel**: I'm going to drop.

_Proposed BIP for 64-bit arithmetic in Script_

**Mike Schmidt**: We're going to move to our monthly segment on Changing
consensus this week.  First one is titled, "Proposed BIP for 64-bit arithmetic
in script".  Chris, we've talked about this a few times with you.  We
highlighted your ideas on adding 64-bit numbers to Bitcoin Script in Newsletters
#285, #290, and #306.  And I think we had you on as a guest for Podcast #285 and
#290 as well.  But this week, we covered your post to the Bitcoin-Dev mailing
list about a draft BIP for a soft fork proposal for doing operations on 64-bit
numbers in Bitcoin.  In your email, you noted, "The purpose for this BIP is to
lay the groundwork for introducing amounts to script.  This document takes no
opinion on how this is done".  Maybe you can remind us why we would want
something like amounts in script, and then maybe you can jump into some of the
BIP details?

**Chris Stewart**: Yeah.  So, allowing amounts in script would allow us to do
interesting contracting schemes.  Like, for instance, any covenant scheme has
two components to it.  The first component is usually restricting where the
funds go, and the second part of any covenant scheme is how much of the funds
are going there.  So, I'm interested in the latter part, how much of the funds
are going to a specific place.  And to be able to do that programmably, we've
got to be able to introduce logic, either in validation.cpp or in the
interpreter itself, of restricting how much funds can flow places.  I think in
the 64-bit proposal, I have I think four different proposals that are currently
out there as soft fork proposals for laying out how to do different amount locks
in Bitcoin.  One is OP_INOUT_AMOUNT, another one is OP_CTV, which is pretty
popular.  Let's see, I'm blanking on the other two right now, but they're in the
document.  And 64-bit arithmetic has been talked about for a while now,
introducing it into script.  I think it's actually cited in BIP341 or 342, the
tapscript document, that a future proposal we may want to add.  And I think that
since a variety of soft fork proposals now have actually introduced 64-bit
support in small ways, such as OP_VAULT, James O'Beirne and Greg Sanders' BIP,
and like I said earlier, OP_CTV.

I thought I'd factor all this stuff out, put it into a single document, and
hopefully kind of encapsulate and modularize this precision enhancement in
Bitcoin.  And that's what I've done with that, posting it to the Bitcoin mailing
list and putting together the draft BIP proposal.

**Mike Schmidt**: Bram or Robin, I don't know if you, as fellow scriptors, have
any feedback on Chris's general idea or if you had a chance to check out the
draft BIP?

**Bram Cohen**: I slightly embarrassingly was not really aware that Bitcoin
didn't really have good integer math support already.

**Chris Stewart**: And Bram, you're not alone.  Right now, the supported
precision is 2<sup>31</sup>-1.  And to support satoshi mathematical values, we
need a 51-bit precision, if I remember correctly.  So, 64-bit gets us to be able
to support the precision that would be required for doing math on satoshis.
Rusty Russell, who has a kind of competing proposal, I'd call it, called the
Great Script Restoration Project, he claims that 64-bit arithmetic could be done
in the current script in a very ugly and, let's say, ingenious way.  I've not
checked it myself to make sure that this proof of concept is possible.  However,
I don't think that should prevent us from just natively supporting 64-bit
arithmetic.  There are, again, like I said, competing proposals for expanding
precision to arbitrary amounts.  I'm not necessarily against those.  My BIP, the
purpose is to be simple, straightforward, to the point, and hopefully not
controversial, and could be pulled into a wider soft fork deployment if it makes
sense, for instance, deploying one of these covenant opcodes.

**Bram Cohen**: Yeah, you can kind of hack it with OP_CAT just by putting zeros,
or whatever.

**Chris Stewart**: Yeah, and I took a holistic approach to this proposal, like
all of the currently supported opcodes, such as OP_ADD, OP_SUB, OP_GREATER_THAN,
all those comparison opcodes work with them.  This proposal, they've all been
upgraded to support 64-bit arithmetic, so it would be a very holistic,
everything now supports the same precision, rather than kind of a piecemeal
approach, which is kind of what OP_VAULT was doing with introducing their
Revault amount onto the stack.

**Robin Linus**: I'm actually painfully aware of the limits of arithmetic in
Bitcoin Script.  For BitVM, we have implemented 256-bit field multiplication
using just addition.  And that's like, I think, 70,000 opcodes or so for
multiplication.  And so, the first thing I wondered, does your BIP support
multiplication?

**Chris Stewart**: It does not support -- did you enable this by OP_MUL, or is
that what you're kind of thinking, an OP_MUL opcode, or are you thinking about a
specific?  No.  So, again, I'm a big believer BIPs should be about one thing,
one simple thing.  I think OP_MUL could be enabled based off of this BIP if it
was necessary, but I do view them as two separate things, and I like to keep
BIPs simple, and hopefully that invites less contention into one specific BIP.

**Robin Linus**: I would still reduce our multiplication from 70k opcodes down
to roughly 35k opcodes, I guess.  So, it's still a win.

**Chris Stewart**: Yeah, that sounds like a win to me.

**Mike Schmidt**: Speaking of controversy or not, Chris, how has the feedback
been to the mailing list post and the draft BIP?

**Chris Stewart**: I think when I last was on Optech, there was a lot more
controversy, because I had, let's say, a wider scope to this BIP proposal, such
as reworking the serialization format, did we do signed versus unsigned numbers
for instance; Bitcoin Script currently supports signed numbers.  There's some
people that want to do just unsigned numbers.  I got rid of all of the signed
versus unsigned stuff, or reworking the serialization format, in hopes to
reducing the amount of controversy that could be introduced to oppose the PR.
So, now it strictly extends the precision.  I have not had as much feedback on
the mailing list about just this proposal that I posted last week.  I've had a
few people ask about the Great Script Restoration Project and why not go that
direction.  I am not aware of that being worked on currently.  I have reached
out to Rusty and I've not got a reply back.  So, it's kind of unclear to me what
the state of that project is.  And that's the main feedback that I've got so
far.

**Robin Linus**: How do you deal with overflows?  Currently in Bitcoin Script,
if a 4-byte number overflows, it becomes a 5-byte number, and then you cannot
use it in arithmetic opcodes anymore.

**Chris Stewart**: We retain the overflow semantics.  I actually have a
Delving-Bitcoin post about reworking the overflow semantics.  If you're
interested in that topic, please check it out.  It has not got any responses
yet.  I think the Elements project is taking an interesting approach to dealing
with overflows.  The overflow handling was actually in my original
Delving-Bitcoin post about 12 to 18 months ago, and I got rid of it because I
just wanted to focus strictly on extending precision to just support as wide an
amount of use cases as possible that's being asked for today.  However, I think
if we were going to do a soft fork deployment with this BIP in it, maybe it
makes sense to rework overflow semantics in a separate BIP and deploy them
together.  This BIP that I currently have drafted excludes reworking overflow
semantics, but I do think it's a separate topic to be broached and probably will
invite more controversy, unfortunately.

**Robin Linus**: Do you have a suggestion for other overflow semantics?

**Chris Stewart**: I'm a personal fan of the Elements overflow semantics.  What
they do is after every arithmetic operation, they push a boolean value onto the
stack indicating if there was an overflow or not.  That means, so maybe the
downsides, if you want to look at it as this, is you've got to wrap everything
in an OP_IF, OP_ELSE, or that kind of logic, or you've got OP_DROPs everywhere
if you want to be writing unsafe code.  I think we should, as Bitcoin protocol
developers, we should give developers the tools to be able to write safe code if
they want to.  And if they want to just vibe code or YOLO it, or whatever the
kids are calling it these days, they can.  However, if you're serious about
things, hopefully we can provide tools for those people to do things in a safe
way.

**Mark Erhardt**: Why would you not just fail if it overflows?

**Chris Stewart**: I think in that case -- I just don't think we should make
such broad assumptions of people's use cases.  Maybe in certain cases there've
been overflows, they want to do other logic.  And if you give people an OP_TRUE
on the stack or an OP_FALSE on the stack, you put it in the hands of the
developer to handle that case, rather than us dictating to developers, "This is
the way it must be done.  You must fail if it overflows".

**Mark Erhardt**: It does introduce a lot of extra crud into the script though.
And if it just fails for overflows because it's, well, underdefined or not
possible, I think it might fit better with the Bitcoin philosophy that
calculations should mostly happen outside of the on-protocol script.  But yeah,
I haven't looked too deeply into this, this just popped up.

**Bram Cohen**: In general, you want it to be safe by default and whatever's
running onchain, it's speed running whatever it is that it's trying to
accomplish, because you worked it out beforehand.

**Chris Stewart**: And I mean, this is getting a little off topic to this, but I
would love to have this discussion on Delving Bitcoin if you guys have accounts.
I do have an overflow topic on there, has not received any responses.  It pulled
out all of the overflow replies that I got on the original 64-bit arithmetic
post and tried to consolidate them into one place and to get an idea of where
people stand on overflow stuff.  And I think there should be a healthy debate
had around this.  If a BIP comes out of it, that's great, or maybe we just roll
with what we have right now with the proposal, the 64-bit proposal that I
currently have.  I'm rolling with what we just have now because maybe there's
some controversy and we haven't come to consensus on how to best do this, and
that's kind of the feedback that I'm hearing on this call at the moment.

**Mike Schmidt**: Murch, any other follow-up?  Oh, sorry, go ahead, Robin.

**Robin Linus**: I just said I prefer the current semantics in comparison to two
items.  That would make our life harder.

**Mark Erhardt**: Could you maybe explain what the current semantics are?

**Chris Stewart**: So, right now, we support up to, I think it's 2<sup>32</sup>
bits of precision for OP_RANDs.  So, you can consume 2<sup>32</sup> bits of
precision for an OP_RAND.  However, the result of an opcode can be up to
basically 2<sup>64</sup>, and you can have that as a result.  However, you
cannot consume that result with another opcode.  You would fail with a very
cryptic error, "Script unknown error", is how it's phrased, and your script
would terminate execution and validation would fail.  So, this proposal, the
64-bit proposal, extends those numbers so that OP_RANDs can now be
2<sup>64</sup> bits, and then results of opcodes could be up to
2<sup>128</sup>-1, I believe.  Check the document for the exact ranges.

**Mark Erhardt**: Also, taking a step back, regarding deployment, how would this
be a soft fork?  Is it only enabled for a new version of tapscript, or how do
you make sure that this doesn't break existing software, which would not be able
to handle more than 32-bit?

**Chris Stewart**: So, my understanding of tapscript is anytime a new opcode is
introduced, you can redefine opcode semantics, existing opcode semantics,
keyword there, so such as OP_ADD.  You could redefine OP_ADD's existing --
sorry, semantics with a new opcode to be 64 bits of precision.  So, just let's
say hypothetically, we want to introduce this with OP_CTV.  And we roll out
OP_CTV, we deploy it in tapscript, which is the key point here.  There are
proposals to deploy OP_CTV as an OP_NOP, which I do not support.  But let's
assume we're deploying it as part of tapscript.  We can then rework precision of
the existing arithmetic opcodes to be 64 bits with this new OP_SUCCESS semantic
used in tapscript.

**Mark Erhardt**: Okay, so it would only apply to new opcodes and therefore,
nobody else would be handling those opcodes in a failing manner anyway, and that
way it could be a soft fork?

**Chris Stewart**: That's exactly right.  And you know, you'd certainly succeed
in tapscript if you come across an OP_SUCCESS opcode that you don't understand.
So, we would leverage that.

**Mike Schmidt**: Great discussion.  Chris, thanks for joining us and
representing your ideas.  We look forward to seeing how this progresses on
Delving as well.

**Chris Stewart**: If I can segue as well, a bit, I'm curious about Bram's
proposal.  I believe, Bram, in your proposal you have an amount semantic or an
amount lock in your proposal.  Is that accurate?

**Bram Cohen**: Well, you could avoid doing arithmetic because it's probably, in
the normal case, usually just giving the same amount over and over again.  But
yeah, there are places where you would want to divide by two and do other bits
of logic on that thing.  So, yeah, when you're playing a game, you have payouts.
So, if the payout is just simply win-loss to one side or the other, then it's
straightforward, because you can just repeat the amount that you got.  But in
many games, the payout is not strictly one way or the other, it's somewhere in
the middle.  And you definitely want to be able to do arithmetic for that.

**Chris Stewart**: Cool, and then so with the amount semantic here, so say with
CTV, sometimes you do this hash-based kind of covenant where you lock the amount
by a hash essentially.  With your proposal, is it touching the script itself,
the amount semantics, or is it just using like a hash-based lock?

**Bram Cohen**: Well, my proposal is not fully baked!  But there's kind of two
differences from OP_CTV.  One is an approach and one is a very subtle thing
about the semantics of it.  So, in terms of approach, OP_CTVC has this idea that
you're hashing quite a bit of stuff together, because you're just going to
presign it in advance, so the amount of stuff that you're hashing together
doesn't really matter.  But if you're trying to make a script to use that
dynamically, it becomes a problem, because if it only cares about one thing, it
needs to be told all the other things and calculate the hash itself.  So, I'm
proposing that you be able to say, "I'm going to assert that I have one output",
you're only talking about one output now.  And you say, "It's a P2WSH, and
here's its scripthash, and this is its amount", and that's what you're stating.
So, that way, you can have dynamic logic about covenants that's only really
worrying about its one path that it's taking through covenant land into the
future, and not having to think about all this other stuff that might be going
on at the same time.

The other subtle semantic point is that if this is done twice, it should require
two outputs.  So, if you have two different things, both of which make the same
claim as to there being an output with the same format, that means there needs
to be two of them, not one of them.  You could work around it if you don't have
that requirement, but it's a really good idea to have that in there, or security
problems can happen very easily.

**Mark Erhardt**: All right.  Maybe let's take all a step back and, Mike, did
you want to introduce the topic that we've already jumped in the middle of?

_Proposed opcodes for enabling recursive covenants through quines_

**Mike Schmidt**: Yeah, we kind of started there, but I'll say the Changing
consensus title here so that we have a place to put the show notes, and whatnot,
"Proposed opcodes for enabling recursive covenants through quines".  Bram, you
posted to Delving Bitcoin about the idea we started discussing here, which is,
"An idea for how to add a few simple opcodes to Bitcoin Script which would allow
for recursive covenants to be implemented in a natural and straightforward way".
Let's maybe high-level 10,000 foot, what is your idea and what is a quine?

**Bram Cohen**: All right.  So, I've been working on blockchain gaming,
specifically playing games like poker over state channels, which is not quite
possible in Bitcoin today.  It's close, it's not quite there.  So, the question
is for that exact use case, what is the minimum set of opcodes you'd need to be
able to add to Bitcoin Script to allow that to be implemented, which I have a
pretty good idea of now, because I'm almost shipping this project, building this
thing.  And it turns out, when you're doing this, writing quines is very central
to it.  So, a quine, for those who have forgotten this ridiculous exercise they
learned in their introductory computer science classes, is a program that
outputs itself verbatim.  And there's a fundamental trick to doing this, where
it's given a copy of itself.

So, to write one in something like Bitcoin Script, you write a program which
assumes that a string that is itself is sitting on the stack already.  And then,
it takes that thing and modifies it to plop that string itself onto the stack
before running it, and then run the actual thing it was given.  And that thing
itself is then a quine; that resulting program is then a thing that outputs
exactly itself.  You've doubled its size in the process of doing it.  But this
is a very fundamental trick when you want to have a recursive covenant.  And it
turns out if you just use OP_CAT and the slightly dumbed-down OP_CTV, maybe you
could pull it off with OP_CTV, I'm not 100% sure, you can write recursive
covenants actually pretty straightforwardly this way, and you can have fairly
sophisticated logic without actually adding in loops to Bitcoin logic or
anything, because in some sense you have loops.  It's just you need to restart
at the beginning, you need to spend the coin, and then when that one gets
executed, it's starting over at the beginning again.

So, the proposal I gave is trying to be a little more clever than just saying,
"Hey, you can do this using OP_CAT and maybe sort of OP_CTV.  I'm proposing kind
of a dumbed-down variance of those, where there's something that is like OP_CTV,
but is just making a specification about a single output of the transaction that
it's in.  It also has the semantic change about what happens if there's two of
them, that if there's two of them, that means you need to have two outputs.  But
that's the thing that's like OP_CTV.  And then, the other thing is this thing
that's like OP_CAT, almost, sort of, but it's hashing it, it's doing incremental
hashing.  So, it has update and digest.  That way, rather than having to plop a
copy of the entire program on the stack, you have to plop a copy of the partway
hashed thing up to its end on the stack.

Then, there's another thing I'm suggesting where it's important here that you be
able to modify a script to prepend stuff to it.  Now, if you're using OP_CAT,
it's pretty easy to either append or prepend logic onto a Bitcoin Script.  It's
hard to modify a Bitcoin Script in general, but prepending and appending are
straightforward.  If you're doing this trick with incremental hashing of things,
so you don't need a complete copy for quining, that runs into the problem that
you're adding to the end of the string, so that will naturally append, and what
you really want is to prepend.  So, I'm suggesting further having an opcode that
has to be the first one that says, "Okay, this sounds weird, but the entire rest
of the script, all the bytes are in reverse order".  And that way, when you are
appending to the end of the program as a string, you're prepending instructions
that are going to be executed onto it.

It turns out if you put these things together, it requires some clever
programming to do.  But it turns out this does not bloat up your programs all
that much or make them terribly big and complicated.  This is sufficient to have
game coins.  The Lightning-style channels can't quite support full-state channel
support in Bitcoin, and it's not really to do with the channels themselves.
It's to do with what they output, that they can output HTLCs (Hash Time Locked
Contracts) because Bitcoin Script supports HTLCs, but they can't output game
coins, because Bitcoin Script doesn't quite support game coins.  So, this is
enough to make it so that you can have actual game coins.

**Mark Erhardt**: Game coins being another asset here that is being created, or
what?

**Bram Cohen**: Game coin is a very covenant-restricted thing, which is a game
in progress.  So, it's a coin where it's your turn so you spend it, and now it's
my turn and now I spend that output, and then we alternate outputs until the
game is done, and then the rewards are divvied out to us.

**Mark Erhardt**: Okay, basically a state tracker?

**Bram Cohen**: Yes.  It turns out it's a really good idea for it to
optimistically accept state updates that the two sites give, and then make it so
that there's a slashing operation if someone attempts to cheat.

**Mark Erhardt**: Okay, given that we have other people here that are a little
more into the covenants debate, do you want to translate for us?

**Bram Cohen**: Who'd you ask that to?

**Mark Erhardt**: I was hoping Robin maybe, but he was not chomping at the bit,
I guess.

**Robin Linus**: Translate what?

**Mark Erhardt**: Well, I thought that you having thought about BitVM so much
more, probably had a better take or gut reaction or thoughts on this proposal
than I would.

**Robin Linus**: Well, I have a couple of high-level thoughts.  I think first of
all, it is probably possible to implement poker on Bitcoin as it is today.  I
would bet that this is true.  The other thing is, are you thinking about
two-party poker or multi-party poker?

**Bram Cohen**: Oh, this is strictly heads-up.  I don't even know how to make
state channels work properly with more than two participants.

**Robin Linus**: I think for multi-party poker, the fundamental issue is even
harder, because even if you can implement everything perfectly, then your
biggest problem is that you don't want the parties to collude.

**Bram Cohen**: Yeah, even collusion at the state channel level, I don't know
how to do.  There's this research on envy-free cake-cutting that terrifies me.
I don't know enough.

**Robin Linus**: If they share information about their cards, like let's say 10
people and 9 of them are colluding, then you have --

**Bram Cohen**: Oh, yeah, that's at the game level.

**Robin Linus**: I think that's unsolvable in the blockchain setting.

**Bram Cohen**: Yeah, right, but even the number of messages necessary to stop
collusion at the state channel level, I don't know how to fix that either.  So,
it gets ridiculous very fast.  Part of the idea here is to make it so we can
avoid BitVM-style stuff so that you can have just a few simple instructions of
not big scripts that do exactly what you want, and not have to do these hacks to
allow things in Bitcoin Script.

**Robin Linus**: I think there are also cryptography hacks, like you can shuffle
cards using cryptography.

**Bram Cohen**: Oh, yeah, I'm implementing poker and it turns out nearly all the
difficulties in mental poker have to do with card-replacement value.  So, I'm
just implementing a poker variant that uses an infinite deck!

**Robin Linus**: Oh, I see.

**Bram Cohen**: So, I could just use commit and reveal.  Except that actually
hints at if you want to implement the real thing, there's so few cards used in
Hold'em, especially with just two players, that you could do normal commit and
reveal, but do collaborative computation a priori before each hand to find out
if you'll have a card collision in that hand.  And if you will, you just skip
it.  And that makes it so all the onchain stuff is really super-cheap and
straightforward.  And people have claimed to me that it would be totally
practical to do this with SHA256.  I tried running some things and even their
benchmarks were not very encouraging on that, but maybe someone will figure out
how to make that work in the future.

**Mike Schmidt**: Yeah, so the use case that you're tackling here is Satoshi's
vision, which is poker and Bitcoin.

**Bram Cohen**: Yeah.

**Mike Schmidt**: Have you given thought, like how generalizable is this
approach?  It sounds like it's generalizable, but given the fact that we're
focused on this state channel of games …

**Bram Cohen**: Yeah, a game is a very special case of a two-player protocol, so
this general concept of, "We're going to have a protocol that's spoken between
the two of us that's turn-based that does something, and we're going to do it
over a state channel.  And then, if there's an issue, we'll do it onchain".  But
even when we're doing it onchain, the two parties don't introduce every single
thing that they're doing onchain, they just declare the state updates onchain
that are optimistically accepted, and then you can slash the other person if
they try to cheat.  And that is the one and only time there's an actual reveal
of the actual logic of how this thing works in the thing.  This is a very kind
of powerful and general set of concepts.  It's very fundamental to the whole
thing.  A lot of why I'm doing this is to learn stuff about state channels just
in general.  And those concepts are all very programmatic tricks.  They don't
involve adding much of anything to the underlying logic.  That's why I'm
proposing some very simple stuff that enables a lot of things, because it turns
out a little bit of programming trickery can really go a long way here.

**Mike Schmidt**: And the fact that there's no external data, right?  There's
randomness, I guess, in the cards, as you were mentioning, but you're not
relying on price data or anything.

**Bram Cohen**: Randomness is done using commit and reveal.  So, I will say,
"Okay, I'm thinking of some random junk and here's its hash".  And then you say,
"Okay, well, here's my random junk".  And now I reveal my preimage and we hash
that together, and that's our randomness.  And neither of us could control that
very well unless we colluded for it to not be very random, but we're both trying
to make it random against the other person.  So, that's this very fundamental
technique for having randomness in games.  It's just that poker itself has
card-replacement value, which gets really involved, what needs to happen there.
But basic randomness is pretty simple and straightforward.  But yes, this
doesn't require outside information.  If you wanted to include outside
information, you would either need it to be signed by somebody else, and CSFS is
really super-useful there.  And if you want to play a game that involves words,
it's very, very helpful to have CSFS, because then a third party can sign things
attesting to what words are allowable words in the game that you're playing, and
that's very helpful.  So, CSFS, I believe, is just a really useful and good
thing, just in general.

But yeah, anything more than that, like interacting with something else onchain
in real time, would require some pretty involved notion of coins having
capabilities and being able to prove their capabilities to other ones, and
things like that.  There are things like that that can be done, but that's a
couple orders of magnitude more stuff to add to Bitcoin Script to make that
possible.

**Mike Schmidt**: Chris, given your background in DLCs, do you have any thoughts
on this idea?

**Chris Stewart**: Yeah, I mean, I get that DLC do require a lot of coordination
for defining the outcomes up front.  I guess my question would be, I'm guessing
you don't need to enumerate the possible outcomes up front, you don't need to
exchange a bunch of digital signatures or adapter signatures?

**Bram Cohen**: Well, kind of the point here is you can't enumerate the outcomes
up front.  If you can enumerate everything, then Bitcoin Script, as it is today,
is sufficient.  The problem is, what if you're playing this very free-form game
where you have no clue what's going to happen in the future?

**Chris Stewart**: And your explanation makes sense of why DLCs wouldn't work in
this case, Bram.

**Bram Cohen**: Yeah.

**Mike Schmidt**: All right.  We've had a few fun discussions already.  Bram, do
you want to hang on and talk about BitVM?  It's up to you.

**Bram Cohen**: Yeah, I've got a few minutes here.

_Description of benefits to BitVM from `OP_CTV` and `OP_CSFS`_

**Mike Schmidt**: Okay.  All right, great.  Well, there's our segue, "
Description of benefits to BitVM from OP_CTV and OP_CSFS".  Robin, you posted to
Delving Bitcoin about how BitVM could be potentially improved if we get the CTV
and CSFS soft forks activated.  Maybe to frame things a bit for listeners, you
can give listeners a quick reminder of what BitVM is, what BitVM bridges are,
and then we can get into how they might be improved with these proposals.

**Robin Linus**: Okay, BitVM is essentially a scheme to enable arbitrary
computation on top of Bitcoin, but it's actually not generally useful.  Maybe we
could implement poker with it, but the main use case I see it for is bridges.
So, we want to bridge the BTC asset to different systems, to like side chains,
to roll ups, to stuff like ZK coins, and so on.  And yeah, BitVM is enabling
that essentially by enabling a SNARK verifier on Bitcoin, so you can verify
these super-powerful proofs.  Just maybe not everybody knows what a SNARK is.  A
SNARK is like a proof of validity and they are quite miraculous, because they
essentially allow you to compress infinite amount of computation into a succinct
proof.  And that is great for blockchain scalability and it's, in the altcoin
world, the hot topic.  And since Bitcoin is so hard to change, we don't have a
SNARK verifier on Bitcoin yet, but BitVM essentially enables a clunky workaround
that allows us to verify SNARKs on Bitcoin.  And that allows us to build bridges
and that allows us to bridge the BTC asset to second layers or to other systems
in general.

BitVM fundamentally relies on covenants.  Currently, we emulate these covenants
with a trusted setup.  So, there's like a trusted setup where you have like a
large MuSig, like an n-of-n multisig, and you have to trust that committee that
they're actually honest and that at least one of them deletes their keys after
the ceremony.  If that is the case, then the covenant is really safe.  However,
it is clunky.  Even if there is an honest party in the covenant committee, then
you still have that problem that you need that committee to set up the entire
contract.  That is just clunky and makes the system harder to set up.  It's
something that we would love to get rid of.  Also, of course, the trust
assumption is not nice.

CTV seems to allow to get rid of that trusted setup.  Initially, I thought it's
not possible, because CTV is designed to be so simple, and I thought it's not
possible that we can use it for our use case.  But Jeremy, he showed me quite a
clever trick to emulate it, probably.  I'm not entirely sure if it will actually
work out in practice, but it's looking good.  So, the thing is, we need a
special type of covenants, namely covenants that commit to sibling inputs, and
that essentially expresses, "I have an input", let's call it input A, and that
input A is only spendable in conjunction with input B.  And that is because in
BitVM, we represent state in UTXOs.  The existence of a UTXO represents a
particular state in our system.  And for example, having UTXOs representing
state means you can make transactions conditional, to be spendable only if that
particular state was reached.  This is essentially this thing where we have
input A is only spendable with input B, means you can spend this input only if a
particular state was reached, which is represented by input B.

A very simple example for that is in our bridges, you can just simply withdraw
money from the bridge if nobody challenged your withdrawal request.  You make a
withdrawal request that creates a UTXO and to challenge you, they spend that
UTXO.  And if nobody challenged you, then it means this UTXO has been unspent
and that means no challenge occurred, and that means you can just go down the
happy path and just withdraw money from the bridge.  If somebody spent that
particular UTXO, you cannot go down the happy path because you're missing that
input B.  And then you have to go down the unhappy path and actually provide
your proof, and then you go to this challenge game where you actually run the
stack verifier.

Now, CTV was designed to be super-simple.  It essentially just commits to
transaction outputs.  It does not commit to any transaction inputs.  In general,
you cannot commit to your own input because that would create a hash cycle.  So,
CTV just omits all of the inputs, because that's the most simple thing that you
can do.  And that's the reason why we thought we cannot do this input committing
covenants with CTV.  And now, here comes the trick.  CTV does commit to the
scriptSig of all inputs.  That is for some malleability issue.  I don't want to
go too much into detail, but the fact is CTV does commit to the scriptSig of all
inputs.  And now, the interesting thing is that if in our sibling we provide a
signature in its scriptSig, then we essentially commit to that signature.  And
since that signature commits to the input, we can commit to the sibling.  Does
that make sense?

**Mark Erhardt**: Sorry, I'm a little confused at one thing you said.  You said
that it is impossible to commit to your own input because that would lead to a
hash cycle.  How could you commit to the scriptSig, which signs the input then?
That seems weird.

**Robin Linus**: You go to the scriptSig of your sibling.  So, you have to make
it spendable with input B and input B has a signature, and in input A you commit
to the signature of input B.

**Mark Erhardt**: And does it send the same transaction?

**Robin Linus**: Yeah, this is how we try to make it atomic, how to make input A
only spendable in conjunction with input B.

**Mark Erhardt**: I see.  Carry on.

**Chris Stewart**: Sorry, I have a question related.  So, you say scriptSig.
Are you using scriptSig and witness interchangeably or are you very
intentionally saying scriptSig?

**Robin Linus**: I'm very intentionally saying scriptSig.  It would not work
with witness.  For that malleability thing, CTV only commits to the scriptSigs,
it does not commit to the witness data.  So, it only commits to scriptSig, and
that means also our input B, like input A and input B, the input B would have to
be either a P2SH input or a legacy input.

**Chris Stewart**: Okay, that's what I was getting.

**Bram Cohen**: Yeah, if you know the entire transaction that you're signing, in
principle you could say, "I need to look at a reveal of that and check the
signature", and then the reveal of it gives me this whole scratch area that
everything can use to communicate with each other, because the transaction can
have just junk in it.

**Robin Linus**: Yeah, I think that's what we're currently doing.  I'm not sure
if I understood you correctly, but currently we are just presigning the
transactions.  This is how we emulate the covenants.  We know up front how the
transaction would look like, so we can presign it.

**Bram Cohen**: Yeah, yeah.  I mean, for having communication with another
thing…  I'm thinking dynamically, if it was being done dynamically, where you
didn't have to enumerate everything in advance.

**Robin Linus**: Yeah, that's actually a drawback of the project we currently
have, that we have to know specifically which transactions everybody will use
and which inputs they will have.  And it propagates backwards through the entire
graph of transactions, so we have to know every specific input and you cannot
change anything about it.  That leads to all kinds of dependencies that are
actually not very nice in practice.

**Bram Cohen**: Yeah, I think the proposal that I made would dovetail pretty
nicely with this, actually.  It's just an approach.

**Robin Linus**: Sure, if you have more sophisticated ways to do covenants, you
can do it more dynamic.  But currently, we're doing it this way.  And CTV does
allow it to make it slightly better, but once you have to commit to the
signature, you already commit again to a txid and the txid represents the entire
graph of transactions.

**Bram Cohen**: Right.  Yeah, you wind up rapidly going into why we really want
capabilities now.  The most straightforward way to implement capabilities is to
basically have backwards-pointing covenants.  You have these scripts that put
restrictions on what they can do, and you just assert that your parent had that
thing or something else's parent had that thing, so you can recursively
determine that it originally was generated by what it was supposed to have
originally been generated by.  That requires a lot of stuff to be added.  But to
even start saying things like that, you need to be able to piecemeal say very
specific things about the transaction that you're a part of, and what your own
scriptSig is and what other things scriptSigs are as well.

**Robin Linus**: Maybe I'll finish the story quickly.  So, we now have seen a
way, we have input A and we have input B, and now in input A we have CTV.  And
that CTV hash commits to a signature in input B, in the scriptSig of input B.
And now, we thought everything is great and I made that post and everybody in
the BitVM community was super-excited that we can finally do that.  And yeah, I
made that post on Delving Bitcoin.  And then Anthony Towns came along and he
completely ripped it apart, because the funny thing is, we wanted to use a P2SH
output.  But there is that thing that it turns out that you can spend this input
A with a totally different input B if that input B is a legacy script input.
And that is because we cannot commit to a specific script type for input B.  We
cannot force that input B is actually a P2SH input.

That means somebody can just use a legacy script input and replace that input B
with some input B prime that is a legacy script input.  And that means the
redeem script that is in the scriptSig of that to which we committed in using
CTV, this redeem script is now interpreted as just a regular data push.  It's
just an arbitrary byte string on the stack.  And that means you can just drop
it.

**Mark Erhardt**: When you say legacy, do you mean bare outputs?

**Robin Linus**: Yes.

**Mark Erhardt**: Oh, okay.  I thought you were talking about P2PKH and it was
really confusing.

**Robin Linus**: No, that's the point that you have the entire script in the
input, in the pubkey script.  Is it called pubkey script, right?  That's the
name for it.

**Mark Erhardt**: I usually say output script and input script because I find
those terms much clearer than scriptSig and scriptPubKey.  So, maybe just to lay
out what was confusing me.  So, legacy often refers to P2PKH in internet lingo.
So, I thought that your input B was either supposed to be a P2PKH or a P2SH
input.  And with P2SH, of course, in the scriptSig, you push the redeem script.
So, in the P2SH output, you commit to a redeem script and that has to be shown
then in the input script, and usually requires signatures or other script
arguments in order to make it pass.  And I'm still not 100% sure whether you
only commit to the signature or the entire input script, but presumably the
entire input script with CTV.  And now I was confused.  How would you ever
replace a P2SH output with a P2PKH output?  That didn't make sense to me, and
that's where you lost me.  So, we're talking about P2SH and bare script?

**Robin Linus**: P2S outputs, essentially.  Yeah.

**Chris Stewart**: And the thing is, Robin, can you just say again, quick, what
the data is in input B?  I follow you with the clever thing that AJ Towns points
out, but what is that data meant to verify in BitVM again, in input B?

**Robin Linus**: Yeah, well very general, it's just we want to make input A only
spendable with input B.  That is the high-level primitive that we need in a
couple of places.

**Mark Erhardt**: You use the existence of input B as a marker for being in a
specific state in the BitVM, right?  So, if the input doesn't exist, you can't
use input A, because input B has to be spent with it.  And thus, if you are not
in that state, you simply cannot use input A.

**Chris Stewart**: So, then you could fraudulently say input B exists if input
B's output script was not a P2SH script.  Is that correct?

**Robin Linus**: Yeah, kind of.  So, maybe just to make it a bit more concrete,
why we want that, input A would be the deposit, the money that is actually in
the bridge, and input B would be some state that represents, "Yeah, you are
actually allowed to take the money out of the bridge right now".  So, you can
execute this withdrawal transaction only if input B exists, which represents you
are allowed to take it.  And now, the thing is we cannot really commit to the
txid of input B.  We can only indirectly commit to it by committing to a
signature to it.  However, we cannot really enforce that the signature is
interpreted as a signature.  We thought we can enforce that, but it's not the
case, because you can just replace the P2SH input, which certainly would
interpret it as a signature.  And you replace that with a bare script input,
which can interpret it as it wants.  It can just interpret it as arbitrary data
and then it can just drop it and it doesn't have to use it as a signature.  And
that totally bypasses the entire hack.  So, input B becomes more or less
arbitrary as long as it is a legacy script.

**Chris Stewart**: Okay, that clarifies it for me.  Thanks, Robin.

**Robin Linus**: And now, the next hack, how to fix it.  That's again Jeremy's
magic, is that we can kind of fix it by using legacy script for input B, or bare
script for input B.  And that is essentially possible because we can have
non-standard, let me call it legacy script, that's just the word that I'm using.
We can use non-standard legacy script, and in non-standard legacy script, we can
use non-push opcodes in the unlocking script.  Usually, you can only provide
just data in the unlocking script, but in legacy script you can also have
opcodes.  You can have CHECKSIG for example, which is kind of weird.  Usually,
you don't want that in the unlocking script.  It's kind of absurd.  It usually
doesn't make any sense to have any other opcode than signature data pushes and
stuff like that in the unlocking script.  But it is allowed in legacy script, in
non-standard legacy script.  And that means it would always be a signature
check; no matter what kind of input you feed into it, it would always be a
signature check.  And that means the signature has to be validated and then
re-enables our hack essentially.

**Mark Erhardt**: So, just to try to follow, you are committing to a specific
input script with the actual withdrawal, and usually the input script can of
course be provided arbitrarily by the spender, it just has to fulfill the output
script.  And then, you wouldn't be able to rely that they actually end up using
an OP_CHECKSIG in the input script.  But since the other output actually commits
to a specific input script, you can expect this specific input script to be used
in the other input, and therefore it will be forced to be an OP_CHECKSIG in
there.  Is that roughly it?

**Robin Linus**: Yeah.

**Mark Erhardt**: Okay.

**Robin Linus**: You essentially commit to that OP_CHECKSIG opcode in CTV now,
in the CTV hash.

**Mark Erhardt**: We've been trying for a decade to get rid of bare scripts, but
it's interesting that that ends up being the solution here.

**Robin Linus**: If we would get rid of bare script, then you would solve the
other issue.  Then, we could use P2SH again, because you can't attack it with
anything else other than bare script.

**Mark Erhardt**: That is an interesting proposal.  That would, of course, be
confiscatory, which would get a whole other crowd up in arms and raising
pitchforks.

**Bram Cohen**: It seems like this would be relatively easy to fix just via a
number of different methods if you could extend Bitcoin Script to be able to
make just more assertions about the inputs to the transaction.

**Mark Erhardt**: Yeah, maybe we should just replace Bitcoin Script!

**Robin Linus**: Yeah, that's what Anthony Towns says all the time!

**Mark Erhardt**: All right, all right.  I think we really got into the details
here.  Can we maybe dive or undive a little bit and track back towards the
surface?  I think you were explaining what BitVM is and then -- bye, Chris --
and yeah, I'm not entirely sure how we got here.

**Robin Linus**: I don't know.  But the other thing that I haven't mentioned yet
is CSFS, and CSFS makes BitVM way more efficient in general, because currently
we're using these lamport signatures to introduce state into Bitcoin Script.
Essentially, that works such that party A signs some value using lamport
signatures, and then party B can observe the signature in the blockchain and use
it in their script to set a particular value to exactly the value that party A
signed.

**Bram Cohen**: You're post-quantum already.

**Robin Linus**: Yeah, BitVM is post quantum!  Actually, it's not at all.

**Mark Erhardt**: Not really, but okay.

**Robin Linus**: I'm using taproot so you can just break them, right?

**Mark Erhardt**: Yeah, you can just spend it with a keypath.

**Robin Linus**: It's just compressed a lot by using CSFS.  You'd get a factor
of 10 roughly.  You would get more, but we can only sign 32-bit values.  CSFS
allows to sign arbitrary values, 32 bytes, or whatever you want.  But since we
want to work on these messages, we want to use them in arithmetic opcodes, we
are restricted to 32-bit messages.  So, that's why we only get roughly a 10X
improvement.

**Mark Erhardt**: So, it sounds like you're going to write another blogpost next
week, how 64-bit arithmetic would also be beneficial to BitVM.

**Robin Linus**: Oh, yeah, it would certainly be beneficial, yeah, in particular
with CSFS.

**Mark Erhardt**: All right, so maybe going a little more overview here.  So,
Bram needs OP_CAT definitely and would also love OP_CSFS in order to be able to
play poker on the Bitcoin blockchain.  And BitVM would love OP_CTV.  You can
defend yourself in a sec.

**Robin Linus**: Just give me a sec.

**Mark Erhardt**: And BitVM would benefit also from all the things we've
discussed, OP_CTV, OP_CSFS, 64-Bit arithmetic.  Generally, the thing is just
script is so limited right now that if you're trying to do anything more
abstract, it tends to really blow the opcodes up.  Sorry, Bram, what were you
going to say?

**Bram Cohen**: Yeah, I'm advocating for a slightly dumbed-down thing actually,
because you don't need full-blown OP_CAT.  And OP_CTV might be just a little bit
off for what I'm proposing doing.

**Mark Erhardt**: Right.  So, Robin explained the benefits for BitVM, and BitVM
itself would, of course, allow all sorts of layer 2 construction sidechains,
rollups and so forth.  Mike, did you have more to tie this all together?

**Mike Schmidt**: No, I think you did a good job summarizing.  It sounds like
there is this scriptSig hack that Jeremy informed Robin about, that CTV could be
used to benefit BitVM.  But AJ countered, pointing out downsides to that
approach.  But then, Jeremy came back in with another way to remedy that
downside.  And so, there are benefits that remain in that approach.  And then,
Robin got into some of the concrete improvements also that CSFS brings to BitVM
as well, which are outside, I guess, of that hack, or that scriptSig hack in
that concern, but benefits remain.

**Mark Erhardt**: Actually, I do have a follow up question for Robin.  So, bare
script, of course, would mean that the transactions are non-standard at that
point, right?  So, would you propose that one specific construction would become
standard, or have you thought about how that would be eventually used on a
network, or is that too far away yet?

**Robin Linus**: Yeah, we rely in a couple of ways on non-standard transactions,
so that requirement isn't that bad.  In particular for these two transactions,
it's the case that they are not really time-critical.  So, if it would take a
very long time to get them in, it's still fine.  So, you can go to Slipstream,
or whatever, even though they only have 5% hashing power.  So, yeah, but of
course it's not nice that they're non-standard.  We try to work around the
non-standardness as much as possible, but in that case, it seems impossible.
So, if I could propose a change, then I'd rather make bare script deprecated.

**Mark Erhardt**: Okay.  Wait, could you say that again?  If you had the choice
between OP_CTV and OP_CSFS or making bare script outputs invalid, you'd prefer
making bare script invalid?

**Robin Linus**: That wouldn't be an either/or choice for me.  Certainly, I
would choose CTV, but the bare script thing is completely irrelevant for us
without CTV.

**Mark Erhardt**: Okay, so basically you'd like all three of them.  Make bare
scripts invalid, or…?

**Robin Linus**: Well, I think it would be quite contentious, because I think
what you could argue for is that you disallow to spend to a bear script, but
spending from is confiscating money, right, and then people will go mad.

**Mark Erhardt**: Well, there is this theoretic problem that someone could have
a presigned transaction that spends to a bare sig.  But yeah, I'm more with the
people that say, making presigned transactions that are set more than one year
into the future seems just very unreliable, and I don't think that people
actually entrusted huge amounts of money to that sort of script.

**Robin Linus**: Hopefully not.

**Mark Erhardt**: All right.  It sounds like we covered our Changing consensus
section pretty well this time.  Did anyone have any calls to action or anything
to add to this?

**Robin Linus**: Yeah, activate CTV and CSFS, it's time.  Stop talking about
OP_RETURN, stop talking about sats versus bitcoins or sats versus bits.  Let's
talk about covenants.

**Mark Erhardt**: Okay.  I absolutely agree about, "Stop talking about
OP_RETURN"!  And all the other things, yeah, I think they would be more
productive.

**Bram Cohen**: I'm not so sure about OP_CTV, because I think it might not do
exactly the right thing.  I think it might be just a little bit off.

**Robin Linus**: We can do another round of bike shedding for two or three
years, or just activate CTV now and most people will be kind of happy.  I
wouldn't be super-happy, but it's way better than what we have so far.  So, it's
it would be cool.  But of course, we can also argue about activating OP_TXHASH
session instead, but I think that would take another two years.

**Bram Cohen**: It's possible that Jeremy or someone could get go deep in the
weeds of exactly what OP_CTV does today and point out to me that there's some
hack for doing exactly what I'm wanting, but I really don't know about that.

_BIPs #1848_

**Mark Erhardt**: While I have you both here, have either of you looked at
CHECKCONTRACTVERIFY (CCV) previously known as MATT?  Well, because OP_VAULT has
been mentioned a few times, and maybe I can pull it up very briefly, Mike, but
we do have a BIPs update at the bottom, which is BIPs #1848, and it actually
moves OP_VAULT, BIP345, to withdrawn.  And the argument of the OP_VAULT authors
here is that OP_CCV, a new BIP that just got merged, does almost all the things
OP_VAULT does and does it better.  So, they throw their support to OP_CCV.  So,
if you haven't looked at it yet, maybe that one would be interesting to you as
well.

**Bram Cohen**: Oh, I should probably also emphasize that for the tricks I'm
talking about, it does turn out that the bytes of this script are in reverse
order thing, and being able to reverse the bytes in a script so that you can cat
it or hash it properly is important for that.  I know that sounds really weird,
but that actually does something meaningful.

**Mark Erhardt**: Robin, did you have any thoughts on CCV?

**Robin Linus**: Yeah, I think it's a cool proposal.  I actually cited it in the
BitVM whitepaper.  It was kind of an inspiration for BitVM.  I think that would
make everything way easier, of course.  Then we could get totally rid of BitVM.
BitVM is just a clunky workaround to enable things that should actually be
activated by proper soft forks.  And so, I would be happy if I would have not to
write crazy scripts anymore, like 70,000 opcodes for multiplication.  So,
between CTV and CSFS, you actually want CCV?

**Robin Linus**: Yeah, I mean there are always two dimensions, right?  There is,
on the one hand, the dimension of how much does it enable in practice, like the
technical dimension, essentially; and on the other hand, there's the political
dimension.  And I feel like the political dimension, it's just way more likely
that we can get CTV than CCV.  I think we need a lot of bike shedding first.

**Mark Erhardt**: It is of course way younger and there's a few little things
that need to be fleshed out still.  I think nobody's really heard about it yet,
and so forth.  Okay, all right.  Maybe we can move on to the Releases and
release candidates section.  Mike?

**Mike Schmidt**: Yeah, that sounds good.

**Robin Linus**: Unfortunately, I need to drop.

**Mike Schmidt**: Yeah, thanks for joining us, Robin.  Thanks for joining us,
Bram.

**Robin Linus**: Thanks for having me.  Bye.

**Bram Cohen**: Bye.

_LND 0.19.0-beta.rc4_

**Mike Schmidt**: Releases and release candidates.  We have LND 0.19.0-beta.rc4.
And I actually saw this morning that as of a couple of days ago, there's LND
0.19.0-beta.rc5.  From what I can tell, the delta between those two RCs look to
me like just an update in the release notes, but the update in the release notes
is a breaking change, noting that the lncli listchannels and lncli
closedchannels commands, the output from those has changed.  They renamed the
channel chan_id field, which was actually the short channel identifier, to scid.
So, if you're using LND and you're parsing output looking for chan_id, you might
want to take a look at that as it's a breaking change.  And for summary of the
rest of that release, check back to Podcast #349 where we went through that
verbally.

_Bitcoin Core #32155_

Notable code and documentation changes.  Bitcoin Core #32155, which is a PR
titled, "Miner: timelock the coinbase to the mined block's height".  Murch, why
do we want to timelock the coinbase transaction to the block height?

**Mark Erhardt**: I have not looked too deeply into this PR, but it seems
obvious that this is related to the consensus cleanup proposal as it introduces
the semantics required by the consensus cleanup into Bitcoin Core now.  So, if
you were to build a block with Bitcoin Core, which doesn't really happen because
you'd be CPU mining and it doesn't really give you a block on the mainchain, now
the format of the coinbase transaction would be correct regarding the consensus
cleanup.  This is, of course, permitted already because it's a soft fork, so I
read it as a demonstration of how coinbase transactions should be shaped with
the consensus cleanup hopefully coming up sometime in the next decades.

_Bitcoin Core #28710_

**Mike Schmidt**: Perfect.  Bitcoin Core #28710, PR titled, "Remove the legacy
wallet and BDB dependency".  This PR is the final step of the legacy wallet and
Berkeley DB Removal Project, tracking issue #20160 for those following along at
home.  That project began in 2020 with two related goals: first, phasing out the
legacy wallet type in favor of descriptor wallets; and along with that, but
slightly tangential, is the second goal, which is to remove the Berkeley DB
wallet storage format in favor of SQLite.  The project has had dozens of commits
over these last five years, and this particular PR removes a bunch of the legacy
wallet RPCs, documentation around them, and tests around them.  And so, right
now, only a bare minimum of the legacy wallet code remains in the Bitcoin Core
project, and that is in order to perform wallet migrations from a potentially
old legacy wallet that someone might have, to the new version in the future.
And the PR noted, "The migration code will probably be around for a long
time/forever".  Murch?

**Mark Erhardt**: Yeah, hopefully forever.  The point is Bitcoin Core has the
forever wallet and if you have funds in a legacy wallet, we wouldn't want you to
need to try and dig up an ancient version of Bitcoin Core in order to be able to
open your wallet.  So, Ava actually wrote an implementation of Berkeley DB, a
read-only implementation that only implements the things that we actually need
in Bitcoin Core, that can read legacy wallets and transfer them into descriptor
wallets.  After this has been merged, you cannot create legacy wallets anymore
with Bitcoin Core.  And you will also not be able to load legacy wallets at all
anymore, except to migrate them.  So, we are now in the total
only-descriptor-wallets territory with Bitcoin Core releases.  Well, coming with
the next Bitcoin Core 30.0 in October, you will only have descriptor wallets
that are running on in Bitcoin Core wallet.

Berkeley DB was an open-source wallet until, I think, 2013 or so, when it was
purchased by Oracle and taken private, closed source.  So, we have long wanted
to get rid of that.  It's been basically unmaintained for over ten years.  So,
being able to just have a read-only implementation that we control ourselves
cleans that up nicely for us.  And yeah, overall, descriptor wallets just have a
better format, it uses SQLite under the hood instead of Berkeley DB, and it has
the descriptor format, which is a better way of describing xpubs, because you
get all the information in one description.  So, overall, this is all for the
better.  And I think it removed something like 12,000 lines of code from Bitcoin
Core, which Bitcoin Core is, I think, about 180,000 lines of code.  12,000 is a
significant chunk of that.  And yeah, it's a lot of this really, really old code
that we're very happy not to have to look at anymore.

_Core Lightning #8272_

**Mike Schmidt**: Core Lightning #8272 is a PR that removes DNS seeds for peer
lookups as a fallback.  So, in Core Lightning (CLN), one of the commits in this
PR notes that, "DNS seeds have been down/offline for a while, and this code,
which is blocking, has been a source of trouble.  We should probably use a
canned set of known nodes if we want to bootstrap".  So, that is what this PR
does, and it also fixes an issue where CLN could potentially have multiple
reconnects attempting at the same time, which also causes issues.

_LND #8330_

LND #8330 titled, "Bimodal pathfinding probability improvements".  The PR fixes
an estimating issue when routing, when the channel capacity is more than 1
million sats.  It also adds a fallback probability that is used if the bimodal
pathfinding model is not applicable.  And finally, "Fixes are added such that
the probability is evaluated quicker and to be more accurate in outdated
scenarios".  I think it closes two or three different issues that were open in
LND.  So, if you're curious about more of the details there, check out the PR.

_Rust Bitcoin #4458_

Rust Bitcoin #4458.  This is a PR around lock times in Rust Bitcoin.  It's a
change to the API to break what was one variable or one type, which is
MtpAndHeight, into two different separate types instead.  So, instead of one
type that represents both the median time past and the block height, there's two
separate types now.  And while conceptually this is a simple idea of just
splitting one variable into its two component pieces, it was, according to the
author, "A more involved PR than I had expected".  And there's a bunch of
interesting internal details and considerations around the change that I don't
think it's worth getting into on this podcast, but check out the PR description
and commit messages.  And I should also note that it is a breaking change to the
API, but the author notes, "I believe the resulting API is much more consistent
and discoverable".

_BIPs #1848_

BIPS #1848, we talked about this one a little bit earlier.  Do you want to call
that a closed case, Murch?

**Mark Erhardt**: Yeah, well, just BIP345, the OP_VAULT BIP, was updated to
withdrawn again, and OP_CCV, a new BIP, I think it was 443, just got merged.  I
think it'll be in the next newsletter.

_BIPs #1841_

**Mike Schmidt**: Two more BIPs PRs.  We have #1841, which merges BIP172.
Murch, I know, as our BIPs editor, you've taken a look at these.  What are we
trying to achieve here, and maybe you want to tie in BIP177, which is a BIPs PR
as well?

_BIPs #1821_

**Mark Erhardt**: Yeah, let me start with BIPs #1821.  It's kind of funny that
all three of these are in reverse order of time.  So, #1821 adds BIP177, a
fairly new informational BIP.  This is proposing that we should essentially
re-label what we call bitcoins in Bitcoin.  The original definition of a bitcoin
is 100,000 of the atomic units in Bitcoin.  Of course, at the protocol level,
Satoshi did call these atoms in the code.  So, they're unsplittable integer
values that we use at the protocol level.  Colloquially, today they're called
satoshis.  So, this informational BIP proposes that we should stop calling 100
million of the atoms 'bitcoin'.  We should instead call the atoms themselves
bitcoin.  So, essentially it is asking the community to start referring to what
we call today's satoshis as bitcoins.

Naturally, people have very strong feelings about that and have been already
debating that on social media.  And I believe that BIP172, another BIP that came
out very briefly after, was a reaction to BIP177, where it instead proposes
another informational BIP, which formally defines satoshis as the correct term
for the atoms in the Bitcoin protocol, and describes how to use the term and how
Bitcoin amounts should be formatted when talking about satoshis.  So, basically,
BIP172 and BIP177 are directly opposing here, and probably only one of them can
be adopted by the community.  As of yet, they're both drafts.  So, argue away
and please don't argue in the BIPs repository.

**Mike Schmidt**: I have to ask you, as somebody who's authored a terminology
BIP, what is your personal opinion?

**Mark Erhardt**: Well, to correct that, I have a draft that I haven't even
opened a PR to the BIPs repository for a terminology BIP, which I really should
write, or finish writing at some point.  I think it will be very difficult to
herd cats in the way that an organically adopted term gets replaced.  I do get
the point that people are making that if we could magically switch over and just
start calling atoms of the Bitcoin protocol 'bitcoins' instead of 'satoshis',
that might be an overall better world to be in because it gets rid of the unit
bias.  On the other hand, it gets to really, really large numbers for amounts
that we currently see quite frequently.  Like a bitcoin is then 100 million
bitcoins in that new world.  If you are talking about several hundred bitcoins
or something, it becomes billions.  And even small amounts, like $1, is
currently around, I don't know, 980-or-so sats, or bitcoins in that proposed
world.  I think it takes a very open mind to just jump in and consider what that
new world would look like and whether that would be a better world.  And if
people agree on that, I think there's a whole other debate whether the
transition from the current use of the terms to that new world is doable.  And I
think that's where most of my gripes come from.

I could see that there's arguments for, if we were in a position to have already
adopted the new terminology, that it would be a better world.  But I think the
transition there would be extremely confusing and difficult.  It would mean
updating every software, it would mean updating the understanding of everyone's
person, how much value a bitcoin roughly would be.  I think that's the part that
most people are concerned about, not the final outcome as much.

**Mike Schmidt**: Well, we'll see what the social medias think about these
ideas, as well as the idea of BIPs.  That's also been something people have
discussed.

**Mark Erhardt**: Yeah, right.  In this context, BIP176 has gotten some more
attention recently again.  This is an older BIP, I believe by Jimmy Song, that
just tried to formally introduce the term 'bits' for 100 satoshis, and sort of
advocated for the adoption of that term.  And yeah, so BIP172, 176, and 177 are
all in the repository now.  Feel free to read there.  Please do note, the BIPs
repository neither collects nor tracks, nor is the place to discuss whether or
not proposals will be adopted.  They're merely a place to present your proposals
when they're reasonably mature and on topic.

**Mike Schmidt**: Well said.  Well, we want to thank our special guests, Robin,
Bram, Chris, and Eugene for joining us today and talking about the work that
they've been doing and the research they've been executing.  Thank you to Murch
as co-host, and for everyone for listening this week.  Cheers.

**Mark Erhardt**: Thank you for your time.

{% include references.md %}
