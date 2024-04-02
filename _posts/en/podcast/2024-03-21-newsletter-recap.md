---
title: 'Bitcoin Optech Newsletter #294 Recap Podcast'
permalink: /en/podcast/2024/03/21/
reference: /en/newsletters/2024/03/20/
name: 2024-03-21-recap
slug: 2024-03-21-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Sebastian Falbesoner,
Anthony Towns, and Russell O’Connor to discuss [Newsletter #294]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-2-21/6c2a2069-4de7-8b88-6751-c171e7c6c596.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #294 on Twitter
Space.  We are talking about a variety of news items today and some interesting
software updates.  We have a project for BIP324 proxy for light clients and we
have Sebastian to talk about that; and we have an overview of the Bitcoin Lisp
programming language, and we have AJ and Russell to talk about that; eight
interesting ecosystem software updates involving Bitcoin technology; and then we
have our usual releases, release candidates and notable code change coverage.
I'm Mike Schmidt, contributor at Optech and Executive Director at Brink, funding
open-source Bitcoin developers.  Murch.

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: AJ.

**Anthony Towns**: Hi, I'm AJ, I work with DCI on Bitcoin stuff.

**Mike Schmidt**: Russell?

**Russell O'Connor**: Hi, I'm Russell O'Connor, I work in Blockstream's research
department on Bitcoin and Liquid stuff.

**Mike Schmidt**: Sebastian?

**Sebastian Falbesoner**: Hi, I'm Sebastian, I'm a Bitcoin Core contributor
funded by Brink.

_BIP324 proxy for light clients_

**Mike Schmidt**: Well, thank you all for joining this week.  We'll just go
through the newsletter sequentially here, starting with the item titled BIP324
proxy for light clients.  Sebastian, you posted to Delving Bitcoin announcing a
proxy for translating between Bitcoin P2P v1 protocol and P2P v2 protocol
messages.  As a reminder for folks, v2 protocol is encrypted while v1 is plain
text.  There's an emphasis in the project for this proxy being used in light
clients.  So, Sebastian, maybe you can talk a bit about the project and maybe
why light clients would be a good use case for this proxy.

**Sebastian Falbesoner**: Yeah.  So, the goal of this project or the motivation
is basically P2P encryption for everyone.  So right now, all of the messages go
over the wire unencrypted, at least with the default settings of Bitcoin Core,
and there was a lot of progress last year with BIP324.  So, starting with the
release 26, released in last December, there is an optional support for P2P
encryption; and in two weeks, I think, or less than two weeks in the best case,
there will be the first release that has P2P encryption on by default.  So, this
is a great development, so the nodes will talk to each other encrypted.  But at
some point I was asking myself, okay, that's great, but how can we help other
clients to also talk encrypted.  And one obvious answer is simply to wait,
because they would implement it at some point.  But another thing one could do
is provide the tools to accelerate the process.  And this is where BIP324 proxy
comes in.  It is, as the title says, a tool to teach light clients to talk v2
P2P protocol without them needing to do many changes.

So, how this works is by a process in between a proxy that does all the hard
work to translate between v1 and v2, and the motivation for this is, it's well
described in the Optech Newsletter.  So usually, light clients, they only send
out their own transactions, and if this goes to the wire unencrypted, this is
very revealing that this transaction will belong to them.  So, with P2P
encryption, it will be less obvious what is going on, because you would have to
conceal a man-in-the-middle attack or actively listen there to find out what
transaction this light client is sending.  And also, I think it's great overall
if everyone would use P2P v2 encryption also maybe to just hide the fact that
you're running Bitcoin at all.  So, this was the short summary of this project.

**Mike Schmidt**: I'm curious how reception has been so far.  I know it's a
fairly new idea.  Are you getting feedback from the community, feedback from
potential wallet integrators; and then maybe we can also get into ...

**Sebastian Falbesoner**: Yeah, mostly on Delving Bitcoin, there was a few
answers.  First, there were people offering to help with the maybe factoring
that out into a library, because there is so far no BIP324 library available as
far as I'm aware.  And there was one answer of a person offering to help with
that, I think his name is rustaceanrob.  He's working on a BIP324 library, so
that's great and we can try to cooperate there and maybe factor out some parts
to this library.

**Mike Schmidt**: You talked a little bit about the underlying library and some
of the plumbing there.  Maybe talk about Python versus Rust and where you're at
with maturity of the project.

**Mike Schmidt**: Yeah.  So Python is, I think, a great language for
prototyping, also for network programming stuff that is used there.  One reason
I use Python is because all the code was already available in the functional
test framework of Bitcoin Core.  So, there was a good effort by stratospher and
sipa mainly to provide the cryptography in Python and also all the integration
in the network layer of our Python nodes.  So, I could just use that one by one,
and that is actually also the most complex part.  So, I didn't have to do that
myself, I just copied the stuff over, and the rest is just a little not too
complex socket magic with this translation.

One drawback of this approach here that it's quite slow, especially for the
encryption itself in ChaCha20.  So I thought, okay, why not change to Rust?  It
is a modern language with a growing good ecosystem, so it might make sense to
use that.  I mean, another alternative would be to stay on Python and use an
efficient library.  I guess there are ChaCha20 libraries out there, but I guess
it's cleaner to just immediately switch to a more modern language that is
efficient in all sense.  And so, that's where I'm now.

**Mike Schmidt**: You mentioned the speed, but we also noted in the newsletter,
and I think it was a quote from you, the side-channel attack concern.  Can you
talk about that?

**Sebastian Falbesoner**: Oh, yeah.  That is, of course, all the things are
taken from the functional test framework and there are these warnings in the
headers.  So, I thought I'd mention that this is, for the cryptography parts,
this is not safe to use.  I mean, I guess it's not worse than no encryption at
all, but I thought I'd rather be conservative here and warn that this is not
used.  That's why it's also by default only usable on signet right now.

**Mike Schmidt**: And so, as excited as wallets and other libraries may be to
add this sort of thing, it is not recommended for use just for playing around
right now, is that right?

**Sebastian Falbesoner**: Yes, exactly, yeah.  I mean, with the Rust
re-implementation, then the ellswift bindings will be used either directly or
with a library in between this BIP324 library, so those problems will be gone,
and then it should be good to use I guess.

**Mike Schmidt**: Murch, or any of our other special guests, any questions or
comments for Sebastian?  Murch with a thumbs up.  Sebastian, what would you call
for the audience to do?  It sounds like maybe if there's developers interested,
they could help out on the Rust side of things.  If there's wallets interested
in integrating, maybe they should reach out in some capacity to let you know
that they'd be willing to test it or implement it or provide feedback.

**Sebastian Falbesoner**: Yeah, that would be very great.  So, I've started a
Rust branch, and where I am right now is just doing a proxy v1 to v1, the simple
stuff, not BIP324-related at all.  And if any developer is interested to help,
there is a concrete task I'm now hanging on.  There is a presentation linked in
the repository, and one of these slides shows the main loop actually that
translates between the two versions, and I'm just doing -- that ten lines of
code, I'm just trying to port to Rust, and it's turned out to be a bit harder
than it should be because I'm using the select() call.  This is a Unix's call
for multiplexing sockets, and it turns out this is not available in Rust.  So,
if anyone has an idea how to use this, this would be great if someone could
suggest to me how to proceed from there.

**Mike Schmidt**: Sounds like a potentially good first issue for somebody who's
got the familiarity with Rust, Sebastian?

**Sebastian Falbesoner**: Yeah, I think so, yeah.  So, anyone more familiar with
Rust probably knows how to do this.  There is also an open question whether to
use an asynchronous network programming framework, like Tokyo, because right now
I would try to do it with only the standard library.  I don't know if I should
go deeper here.  So right now, I'm only using blocking I/O calls, because I
think that's good enough.  So we have multi-threading.  So, for each incoming v1
client, one new thread is started, but you still have to socket pair the local
and the remote socket, and those do that in blocking calls.  So, I'm not sure if
I should change that or if that is really a problem.  I mean, for efficiency,
the main problem has been, like I said, the stream cipher, the ChaCha20.  So,
probably this is good enough.  Yeah, let's see how it goes.

**Mike Schmidt**: So, Rust developers reach out to the Stack.  Wallet
integrators curious about this, reach out to the Stack or you can reach out to
Optech and we can connect you with Sebastian.  Sebastian, thanks for joining us
today.  You're welcome to hang on or if you have other things to do, we
understand.

**Sebastian Falbesoner**: Yeah, thanks.

_Overview of BTC Lisp_

**Mike Schmidt**: Next news item from Newsletter #294 is titled Overview of BTC
Lisp.  AJ, last week in Newsletter #293, we covered your Delving post, which was
sort of a primer for what the Chia Lisp programming language is and what it can
do and what it does on Chia.  You also spoke with Murch and I on the Spaces last
week, where we went into a bit more detail, and also briefly discussed the post
that we ended up covering in this week's newsletter on Delving, which was titled
BTC Lisp or Bitcoin Lisp as an alternative to Script.  So, AJ, maybe recap
Bitcoin Lisp for those that didn't get the sneak preview last week and I'll also
note that the Simplicity programming language has some similar goals to Bitcoin
Lisp.  So, I've asked Russell O'Connor, who's spearheading Simplicity, to join
us as well today to help not only provide feedback on Bitcoin Lisp idea and
summarize some of the conversation going on there, but also to help us maybe
contrast the two.  And maybe AJ and Russell can riff a little bit here.  AJ, you
want to kick us off?

**Anthony Towns**: Sure.  So, the basic idea is, Script is a fairly limited
language and you can't express a whole bunch of ideas in it.  So, you can't do
looping, for instance, which is something you might want to do if you wanted to
do the same sort of thing on each output of a transaction, if you're
introspecting that.  And so, when it comes to all the new opcodes that people
are looking at, introspection ones, for instance, if you want to hard code the
concept that you're proposing, then that's fine and that works for things like
OP_VAULT and OP_CTV (CTV) and SIGHASH_ANYPREVOUT (APO).  But if you want to
provide more flexibility to application developers so that they can create their
own ideas and implement them, then you want to be able to do something where
they're building the logic in themselves.  And that requires to be able to say,
"Okay, for each output, I want to look at the amount and make sure that's at
least some value," for instance.  And the only way you can express that in
Bitcoin Script is by saying, okay, maybe there are 10 outputs.  If the 10th
output exists, then do this; if it doesn't, don't worry, do nothing.  And you've
got to kind of hard code that limit and you've got to write the expression
however many times you're going to allow the number of outputs to be, and that's
kind of limiting.

So, a couple of years ago, I started thinking about it in that sort of terms and
wondering if there's a way that we can kind of get around that limit while still
keeping Script really simple.  And the way I thought about that was that, well,
Lisp is kind of an old thing, almost as old as all the Forth sort of stuff that
leads into script, and it does provide a fairly easy way of skipping those
limits, so what does that look like?  And so Chia Lisp is something that is
actually implemented and works seemingly fine.  So, that was a nice background
for it.  And then this post kind of brings it, it explores some of the other
implementation choices you could make that might be different to what Chia did,
but also brings it more into line with what might make sense in the Bitcoin
context.  And so I guess that's the 5,000 foot view.  And then there's a bunch
of details and I'll quote from the Optech Newsletter, "The post goes into
significant detail; we encourage anyone interested in the idea to read it
directly", because that saves me trying to repeat it all here.  Yeah, so I think
that's the overview.

**Mike Schmidt**: Well, somebody who I think has read it directly is our other
special guest, Russell.  Russell, I guess I'll let you take the floor in
whatever way makes sense, if you want to talk a little bit about Simplicity and
a brief journey there, similar to AJ's journey with Bitcoin Lisp, or you can
comment on AJ's ideas directly, whatever you feel comfortable with.

**Anthony Towns**: I suspect a lot of people don't have any idea what Simplicity
is up to these days, so an overview of that would probably be helpful.

**Mike Schmidt**: Yeah, go for it, Russell.

**Russell O'Connor**: Yeah, so I mean in some ways, AJ just expressed the same
background that I had for simplicity.  I mean, maybe not so much the worries
directly about looping overall inputs, but a more general feeling of Bitcoin
Script is very limited in its computational abilities, especially since most of
the operations were disabled early in Bitcoin's life by Satoshi.  And what got
me excited about Bitcoin way back in the day was the idea of programmable money.
So, I spent a lot of time thinking about how one would create a programming
language in the context of the blockchain, which is quite a bit different from
the context that normal programming languages operate in.  And that has led me
to design Simplicity, which is sort of a low-level consensus language that would
be suitable for a blockchain environment.  Or, for instance, most programming
languages are designed to be repeatedly run under multiple input conditions, and
so you can explore various outputs on the various inputs, right?  But in the
blockchain language, you have this potential of a bunch of different ways that
your transaction could be executed or spent in some case, but in the end it only
gets spent in one particular way.  And in some sense, it only gets executed
once, right?

So, this has led me to a design of a language that differs from maybe common
programming languages, because I think the blockchain has unique circumstances
and requires sort of a unique answer.

**Mike Schmidt**: Well, maybe that's a good segue then.  You mentioned
Simplicity was sort of thought of in the context of a blockchain.  Maybe, so
where did you end up with that approach, from a ground-up approach like
Simplicity, versus something like repurposing, if you will, an existing
programming language like Lisp?  How should we think about the differences that
occurred from those different approaches?

**Russell O'Connor**: Yeah, so one of the major aspects of Simplicity design
that was influenced by this is sort of the pruning aspects of the language,
right?  So, if you have an if() statement in a programming language, you have
two branches.  But if you're only executing the program once, typically you will
only execute one of the two branches of that if() statement.  I mean, that's
true even in Bitcoin Script, where you have an OP_IF statement.  During
redemption, only one of the two branches of the OP_IF gets executed, and the
rest of the branch has to be exposed and is just sort of lying there taking up
block space, right?  So one of my early design decisions was to prune away
unexecuted branches.  And it uses this Merklized Abstract Syntax Tree (MAST),
the original mast as I like to call it, so that the program itself, is stored as
a syntax tree.  And then, that syntax tree can get pruned away of all those
branches that never get taken, reducing blockchain space, potentially, usually,
and increasing privacy because you don't even expose those conditions.  And of
course eventually, that masked idea got incorporated into the taproot proposal,
and so we have a certain aspect of that available in Bitcoin today, which is
great.

**Mike Schmidt**: AJ, any thoughts so far on what Russell's said?

**Anthony Towns**: The only one is a slight digression.  Do you have any idea in
practice how much difference the true MAST makes compared to taproots?

**Russell O'Connor**: I guess, one thing is that in taproot you sort of have to
bring all your branches to the top level, and that's going to involve an
exponential blowup in the branching you will take.  Like, if you ever went to
sequential decisions, you can sort of put them in sequence and take one branch
out.  But if it makes all those choices up at the top, you get this exponential
increase.

**Anthony Towns**: Yeah, so if you've got a bunch of ands and ors --

**Russell O'Connor**: Yeah, exactly.

**Anthony Towns**: -- the taproot way is pretty crap.

**Russell O'Connor**: I mean, it's not so bad, it's just bad on the computation
side because in the end, only one branch gets exposed in that sort of
logarithmic in the size of the number of branches.  So, the operational aspects
of the verification on the blockchain aren't so bad.  It's just that you have to
compute that giant taptree.

**Mike Schmidt**: AJ, maybe in an effort to suss out for us listeners the
differences here a little bit further, maybe not to cause drama per se, but
Russell's been working on this for several years, but you've chosen to go a
different route.  Maybe if you explain your choice in going this Lisp route, it
will help us understand a bit more about the diverging approaches.

**Anthony Towns**: So, I mean I like Simplicity and my fondest hope for the
outcome here is that we have both of them working and explore what scripts look
in both of them, and that improves both of

them and we end up with something really good.  So, I think the Lisp approach is
different and interesting enough to be working on, rather than I think
Simplicity is bad, is where I'm coming from.  So, asking why Simplicity is bad
kind of misses the point, but I'll answer it anyway.  So, I had a look at the
simplicity PR, and the thing that kind of scared me about it was its size and
the number of consensus specification points.

So, one of the fundamental things with Simplicity is that you want a bunch of
JETs to make common operations fast.  And so, you've got JETs for SHA and for
secp256 and for addition and multiplication, and all that makes perfect sense.
But the way that they end up getting done in Simplicity is you've actually got
six JETs for all those, for the SHA things and a similar number for the secp.
And depending on how you look at addition, it's actually 32 JETs or something,
one for each different size of number.  And that makes perfect sense coming from
the design of Simplicity and the constraints that come from that.  But my gut
reaction to that was, I don't like it, so I want to see what else is possible.

**Mike Schmidt**: That's fair.  And when you're saying you'd like to see both of
these in action, I assume you're referring to getting working code up on
Inquisition and folks being able to build there?

**Anthony Towns**: Yeah, well, I imagine that the working code for Simplicity
will be up on the Elements testnet or Liquid proper before too long, I don't
know.  But I more mean seeing what it looks like when you write a vault or a
payment pool or an eltoo L2 implementation or APO.  You get the same
functionality with Simplicity or with Lisp as APO without actually having the
consensus change for APO, you just implement it yourself and go with it without
having to wait for consensus on some particular spec to build.  And so, seeing
how that turns out in practice is kind of what I'm interested in.

**Mike Schmidt**: Russell, is there a timeline for Simplicity on Elements or
Liquid?

**Russell O'Connor**: That's mean!  Well, yeah.

**Mike Schmidt**: Well, if there's not, there's not.  I'm just curious.

**Russell O'Connor**: No, for like the last year, it's been the goal to get at
it in the next six months, and I think we're getting a lot closer now.  I just
want to read it before I go on.  I just want to say that I totally agree with AJ
about multiple implementations.  And I think actually even having BTC Lisp as a
contrast to Simplicity, not only can they help each other with design, but if we
just had Simplicity, people would have the question, "Well, is this really the
best thing to do?"  And then having two or more things to contrast, we'll be
able to really put them head to head and see.  Like, I've made some design
choices and I'm not entirely sure whether they're the best choices, and so it'll
be good to see a comparison of that.

But yeah, when I first did Simplicity, I was like, okay, we do the Core language
and get the interpreter working for that, and then the last step is to create a
bunch of JETs.  It's sort of like a single-line item in my to-do list of like,
"Just build a bunch of JETs for the various operations that I think people want
to do".  But that process has turned out to be much more, not necessarily
difficult, but longer than I expected.  We've had to create a bunch of JETs, and
AJ is absolutely right with his understanding.  We have multiple different
widths of integer operations for JETs, and I even wanted big integer JETs
because people might want to do cryptographic operations on maybe different
curves and stuff like that, that haven't made the cut into it.  So, I both think
that there are too many JETs and too few JETs at the same time.  And writing all
the JETs is much more finicky than I expected.  For every JET, there seem to be
a bunch of corner cases or decisions that need to be made like, "How are you
going to divide by zero?  What are you going to do in that case?  What are you
going to do when you take a modulus by zero?"  And then everyone has to agree
with it, so it has to be clearly written out what you're going to do.

In the end, I have basically three implementations of every JET, one reference
implementation I've written in Haskell; another formal specification, you might
call it, written in Simplicity itself; and then its C implementation on a test
suite to run all three against each other on various randomized inputs.  Then
you have to determine a good set of distributions of those randomized inputs to
exercise the model, and you have to do this for every JET.  And it's tedious, so
it's error prone, so you really have to be careful to get it correct.  And there
have been many other blockchains that have run into problems.  Apparently, TLS
had a division-by-negative-numbers issue; I know Ethereum had like some unclear
specification of one of their language primitives that they added.  So, it
really takes a lot of time and effort to carefully nail down everything so that
you can avoid this sort of ambiguity, which I've been trying to do, and that's
just been taking a lot of time.  But I feel I'm getting very close now.  I don't
want to commit to anything, but I think we're getting very close now.

**Anthony Towns**: Have you had any luck with the, I don't know what you call
it, the provable spec to C code sort of stuff, to link the different
implementations and prove that they're the same?

**Russell O'Connor**: Yeah, I have been working very slowly on that.  I think
it's doable, but it's very expensive.  So, most recently I've been working on
proving the correctness of the secp256k1 modular inverse code and using the
Verify Available Software toolchain to prove it's correct, and then eventually
prove the JET is correct.  This is by far not the easiest JET to work with.  I
could prove addition JETs correct much more easily, but I thought the modular
inverse code was difficult enough to show that if we can prove the correctness
of the modular inverse JET, then we can basically prove any JET correct.

**Mike Schmidt**: Murch?

**Mark Erhardt**: Okay, a completely different topic.  You both have mentioned
that one of the things that the Bitcoin Script language cannot do is loops.  So
I'm wondering, if you are introducing the capacity to essentially have a
Turing-complete language instead, have you considered how we are going to
restrict transaction scripts so that we are sure that we can evaluate them in a
limited time?

**Anthony Towns**: So, if I go first, I've got the easy answer and Russ has got
the awesome answer.  So, for the Chia approach, it's just that you'll have the
transaction or the input specify a limit on how much computation that evaluating
the thing is going to take.  So, I'll have a 200-byte script or something, and
I'll say this is going to take 40,000 units of computation, and that 40,000
units of computation will perhaps increase the weight of the transaction and
therefore make it more expensive.  And if it turns out the computation goes over
40,000 units, then the transaction's just invalid.  And that's slightly
different to what Chia does, but in essence the same thing, and seems like it
should be fairly easy to make work.  I haven't done all the details yet because
I haven't hooked it up into actual transaction processing, but I don't see any
problems.  Simplicity has a much cooler answer.

**Russell O'Connor**: So, Simplicity doesn't have unbounded loops in it, and you
might think you can't just loop over all inputs, right?  But since there are
only -- I mean, AJ has this in its comment, and he's exactly right.  There's
only well under 2<sup>32</sup>, like you just can't exceed 2<sup>32</sup>
inputs.  So, you can just write a subroutine that tries up to 2<sup>32</sup>
inputs with a fast path to exit early by calling a routine that goes over
2<sup>31</sup> inputs twice for the first half and second half and the
2<sup>31</sup> routine calls a subroutine that runs over 2<sup>30</sup> inputs,
and you get this 30-level nested thing.  But hopefully, we can design things so
that can get pruned away, so when you only have ten inputs, you don't have to
even expose all that nesting.  But yeah, this was one of my original thinking
thoughts, was that Bitcoin Script has this unique property that you can't have
unbounded computation that's not expressible.  And I was pretty big on
preserving that when I was first designing Simplicity.

In Simplicity, you can only do a bounded amount of computation and because of
the static piping and various things of Simplicity, you do this pre-processing
step where you do an analysis of the presented script program, and you can come
up with an upper bound on the amount of computational operations, the number of
JETs, how many times they can be executed.  And you can come up with a total
bound of like a maximum amount of computation that this program will need to
take before you execute it.  And this is analysis that you could do in principle
with Bitcoin Script.  You could just look over the script and look through the
obvious statements and determine how many signature hash (sighash) operations
you're going to do and get an upper bound on, like, what's the worst-case
execution going to be.  And I used to think that was very important to do.  I've
softened over the number of years, I've softened a little bit on it.  I still
think it's kind of important, but maybe not as super-important as I used to
think about it, because if you want to waste people's time, you can always make
an invalid script that goes up to the limits and then fails at the last moment,
and you can still waste a bunch of time that way.  But I still think it's nice,
and I do like it very much.

Then we use the weight mechanism basically introduced by tapscript.  In
tapscript, you have to use, I think it's 50 weight units per signature checking
operation (sigop).  And then as you run signature, your initial budget is
basically the size of your witness element, and as you go through signature
checking operations, you start using up 50 of your weight units per operation.
So, Simplicity works built on that, except we have more operations that are
expensive than just signature checking.  But it follows the same idea, that we
try to normalize the cost to, a sigcheck operation costs 50 units.  We compute
this, use static analysis to compute a bound on the total amount of computation
that will be needed, and then we make sure that we have enough weight to cover
that worst-case scenario.  And if not, then the transaction fails even before
you execute it.

If you need to do something expensive and you don't have the witness stack for
it, the current plan is just to pad it by using the taproot annex, fill it with
a bunch of zeros to increase your transaction weight so that you have the budget
to do whatever expensive computation that you might need to do.  I don't think
this will be necessary for most cases, but it's sort of a safety thing; in case
you do need to do it, you can always pad the annex.  That of course increases
your transaction weight, but that's exactly the purpose of this, to make the
transaction weight reflect your operational cost.

**Mark Erhardt**: It feels like if we're just going to pad transactions with
useless data, that we should be able to maybe rather have a field in the annex
where we say, "Treat this as if it had more weight than it looks like", and say,
"I'm willing to pay whatever weight you put there", and it has to be higher than
the actual transaction length would indicate.  But yeah, just writing a bunch of
zeros into the blockchain seems a little wasteful.

**Russell O'Connor**: Yeah, no, I think that would be the right way to go.  The
nice thing about the zeros is it's totally backwards-compatible and everyone can
understand it.  The Annex transaction format is still up in the air, so whatever
choice we make would ideally be compatible with however we decide to treat annex
data.

**Mark Erhardt**: Right, but since it would only claim more weight than it has,
it would also be fine if we just said, you can have a number there that
indicates that you're claiming more weight than your transaction length would
indicate, because then the nodes and miners that enforce the new rules would
limit the block to a lower size due to you claiming too much.  So, it should be
fine with backwards and forwards compatibility, right?

**Anthony Towns**: I think that's roughly equivalent to just, you could imagine
if you do a new serialization format for the transaction that you use saving to
disk and doing over the network, where you just compress all those zeros into
the number of zeros.  So, I think they're kind of equivalent in that sense.

**Russell O'Connor**: Yep, I agree.

**Mike Schmidt**: As we look to wrap up this news item, AJ, maybe you want to
comment on your Lisp play repository and the Python file that you have there.
Is that something that you want people to start playing with or not, or what are
you planning to do there?

**Anthony Towns**: It's a totally fun thing to play with.  There's a whole bunch
of examples that I wrote down when I was testing things that eventually get into
almost doing interesting stuff with actual transaction data, some of which I
pulled off the actual blockchain.  I'm hoping my next post will actually not be
background information, but be an actual interesting use case of all this.  But
I haven't written it yet and I'm still figuring out how to do it exactly.  So,
to be continued, I guess.  It's fine to play around with the Python thing.
There are definite bugs in it.  The design of the language will almost certainly
change, but I mean it's a Python thing, it's fun to play with, go for it.

**Mike Schmidt**: Russell, any parting words from yourself?

**Russell O'Connor**: Yeah, you can find our Simplicity repository.  If you just
search for, "GitHub Simplicity", you should find it.  It's under
github.com/BlockstreamResearch/simplicity.  And I do want to emphasize that
Simplicity is low-level, right?  It's not something that's meant to be written
by hand.  And we're working on a new project called Symfony, which is sort of
the front end for Simplicity, and that's something that compiles to Simplicity.
And hopefully the front-end language will be more approachable, it'll be easier
for people to get into using Simplicity and building covenants and interesting
use cases with that.  And we should have a nice WebID coming up soon, so stay
tuned for that.

**Mike Schmidt**: Russell, AJ, thank you both for taking the time to join us
today.  You're welcome to stay on or free to drop if you have other things to
do.

**Russell O'Connor**: Thanks.

**Mike Schmidt**: Next section from the newsletter is our monthly segment on
Changes to services and client software.  We have eight of those this week.
This is highlighting services and client software or wallets that are
implementing interesting Bitcoin technology.  Obviously, there's a lot of
releases, there's a lot of open source software, there's a lot of interesting
projects.  We try to highlight ones that are adopting or pushing the envelope on
specifically Bitcoin tech that we talk about in the Optech Newsletter.

_BitGo adds RBF support_

The first one here, BitGo adds RBF support, and there's a blog post that they
put out about this on the technical portion of the BitGo blog, announcing
support for fee bumping using RBF, available in their wallet and also their API.
Murch, as BitGo is your alma mater, do you have any inside baseball on this
item?

**Mark Erhardt**: Yeah, I picked some of the people that are still there's
brains and apparently they rolled it out with being on by default, which
surprised me a bit.  And so far, no complaints.  So, yeah, I'm kind of excited
that that is finally here because I had already looked into implementing RBF
years ago.  I mean, RBF itself was defined in, what, 2015, 2016?  So, yeah, I
think it's interesting that it's now available at BitGo, and that would make it
available to a bunch of Bitcoin businesses that use BitGo as custodian or wallet
service provider.  So maybe we'll see a little bit of a peak on the RBF
transactions on the network.

_Phoenix Wallet v2.2.0 released_

**Mike Schmidt**: Phoenix Wallet v2.2.0 being released.  I thought there were
two interesting big items here.  The first one is that Phoenix can now support
splices while at the same time making a Lightning payment, and there's some
technology under the hood that we've talked about previously which facilitates
this.  It's achieved using the quiescence protocol, which is something that we
covered, I think, in a few different newsletters, but I noted Newsletter #262
specifically here because that is the Eclair PR that implemented this feature,
and Phoenix uses Eclair.  The second item I thought was interesting about this
Phoenix release was, they're improving their swap-in feature, both from a
privacy perspective and a cost perspective.  And the technique that they use to
achieve that is this swaproot protocol, which we link to in the writeup.  And
they note in that swaproot protocol writeup on their blog that they think that
they can make this cheaper by 16% if the swap transaction has one input, and 23%
for two inputs, and 27% cheaper for three inputs.  As a reminder, Phoenix is a
single-channel LN wallet, so the swapping in is involving that single channel.
Murch?  Sorry, I didn't see you had your hand up.

**Mark Erhardt**: No, I just put it up!  Yeah, I thought this was pretty
exciting.  So, swap-in-potentiam is just generally super-cool.  And as a
reminder, it works by essentially when you receive funds that are to be added to
your Phoenix channel, in this case, you receive them to a 2-of-2 locked output
that after a timeout becomes spendable by just yourself.  So, you sort of stage
funds that are then locked to both your Phoenix, and Phoenix, and that allows
them to have a zero-conf splice-in, because while it's locked, of course, they
know that it cannot be double spent, and they can therefore splice it in and
immediately pick up payments on the channel again.  And before, they were using
what I think was a P2WSH construction of the same; they already had the
swap-in-potentiam construction, but with a P2WSH output.  And then, of course,
you have to have the entire logic of this timeout and everything right there
present in the output script.

But with a P2TR construction, you can make the happy path where Phoenix and the
user agree to splice it in.  You can make that a keypath spend.  So, instead of
having a complicated output script that you have to reveal and satisfy, and
where you have to show the branches that weren't used in the input later to
satisfy the spending, here you never show that, it just looks like a single-sig
P2TR input, as long as the timeout isn't hit.  When it times out, of course, the
user will sweep it and then they have to reveal the scriptpath.  So yeah, I
think it's just cool to see more businesses and implementations build stuff
based on MuSig2.  And, yeah, it's been a very long time since that's been
coming, and now it's just arriving in the end user apps.

**Mike Schmidt**: Murch, you mentioned swap-in-potentiam, and we discussed that
in Newsletter #233, if folks are curious, under the news titled Non-interactive
LN channel open commitments.  And I believe for that podcast, #233, we also had
ZmnSCPxj and Jesse Posner on to talk about that particular idea.  So, if folks
are curious of some of the underlying technology we talked about with this
Phoenix release, check that out as well.

_Bitkey hardware signing device released_

Next piece of software that we highlighted is the Bitkey hardware signing device
being released.  The Bitkey device is a hardware device that's designed to be
used in this 2-of-3 multisig setup that the Bitkey folks have architected.  So,
it involves a mobile application for your mobile device and there's a key there
as well; and then you have a physical piece of hardware, called this Bitkey,
which is an interesting form factor because I think there's no screen and
there's just maybe a fingerprint meter; and then there's a third key, which is
Bitkey's server key, and there's source code for the firmware and various
components, including the recovery, which Bitkey is focused on being able to
recover if you lose your keys or phone.  I have not tried the device myself, but
they've released that recently, and there's a bunch of write ups on their blog
that are technical as well, if you're curious about the inside baseball to the
key.  Murch, any thoughts on the Bitkey?

**Mark Erhardt**: I think it's interesting in the sense that it's very similar
to how BitGo has always been setting up their wallets.  So, you essentially have
one or two keys with the customer at BitGo and then one with a key recovery
service or as a backup, and finally the BitGo key.  In this case here, it's of
course Square, your hardware device and your mobile phone.  And what this allows
you to do is, of course, to have a policy how you can spend a small amount just
with your mobile device and then, if you want to spend a bigger device, they
basically require you to also sign off with your hardware wallet.  You set that
up yourself, I think, the limit.  But that means you get access to small amounts
of money on the go, but you get the security of having a second factor that you
don't need to carry around with you for the bigger payments.

So generally, it strikes me as a UX choice that is very comfortable and
convenient.  The big drawback of course is that Square, or sorry, Block, gets a
full view of all your activity in the wallet, whereas most hardware wallets are
just a single key; and I don't know exactly how much insight they have, but for
the most part I understand it just runs on your end and they do not actually see
your payments at all unless you, for example, would use their Electrum server to
get updates.  But for the most part, you can set it up in a way that it's more
private.  And here, you're definitely fully transparent to Block.  That's at
least how I understand it.  So, yeah, I'm curious what people will write about
it, that try it out, whether they can confirm that it actually has a very nice
UX, which seems to have been a focus for Block.  And, yeah, maybe a good choice
for the not necessarily die-hard privacy maximalists, but people that are more
concerned about losing access themselves.

_Envoy v1.6.0 released_

**Mike Schmidt**: Next piece of software is Envoy v1.6.0 being released.  This
is a wallet software, and they've added replace-by-fee (RBF) support to achieve
two particular end-user features.  The first end-user feature is fee bumping
transactions, as we normally discuss here on Optech.  And the second one is one
that we've been talking about more recently, it's becoming more common, but this
idea of canceling a transaction using RBF.  We've seen it a few times in our
Client and service updates section recently, it's becoming more common.  Murch,
any thoughts?

**Mark Erhardt**: Yeah, I don't know.  I've held the position before.  I'm not
super strong on it, but as long as the transaction unconfirmed, it is
essentially just a notification to the other party that you intend to pay them a
payment promise, as you will. But of course, that's not fully true, because the
other party can also interact with the transaction and, for example, CPFP it or
pin it.  But I find it very natural that while a transaction remains
unconfirmed, especially if you might have sent it at a very low fee rate, that
you get the ability to cancel it.  So, I think it's interesting to see that
arrive in wallets when last year, we had these big discussions about zero-conf
safety, and now it seems to be swinging a little bit in the other direction.

_VLS v0.11.0 released_

**Mike Schmidt**: VLS v0.11.0 being released.  This is still labeled as beta
software on the GitHub.  But this, well, maybe I should recap VLS first so we
can get into this release.  But VLS is a project for separating signing keys in
an LN node from the actual LN node's operation.  And this release is adding to
VLS a feature that they've called tag team signing, which allows multiple
signing devices to authorize transactions for the same LN Node.  And I think
it's an important distinction here, once you have multiple signing devices,
people think multisignature or multiple devices that need to sign in order for a
transaction to go through, where in this case it's basically the same key but
just on different devices.  So, they go into the blog post, different use cases
for users and businesses that can be enabled with having this kind of feature.
Murch, did you get a chance to look at that?

**Mark Erhardt**: Not a lot, just I looked a little bit at this tag team
signing, and I think it's an interesting idea to have multiple signers.  I know
that we used that in the context of business wallets at BitGo back then too.
Like, just when you have really, really big amounts, or, yeah, you probably want
to have multiple sets of eyes on it, and to build that into an LN wallet signing
device makes also sense to me.

_Portal hardware signing device announced_

**Mike Schmidt**: Next project that we highlighted was another signing device
being announced.  Recently-announced Portal device works with smartphones using
NFC, which I think is like sort of that tap-to-pay kind of thing that you may
use on your phone.  And there's hardware and software source code available.  So
this is Alekos, he went off and built this.  He was a Brink grantee for a while
working on BDK.  I believe Portal is built on BDK, and I saw it got a lot of
traction online.  Looks like an interesting hardware signing device.  I haven't
tried that one either myself, but wanted to highlight that.  Murch, did you look
at Portal at all?  Or, I think it's 2022, you may have seen online as well.

**Mark Erhardt**: I did see the announcement, but I haven't looked much into it
yet, no.

_Braiins mining pool adds Lightning support_

**Mike Schmidt**: Braiins mining pool adding Lightning support is the next item
that we highlighted this month.  So Braiins has a mining pool and they announced
a beta program for getting mining payouts through Lightning.  Now, the
announcement that we linked to in the writeup is actually a Twitter post.  I was
hoping to get a little bit more information about how they plan to do that
exactly, given that things can be reorg'd and there's potentially thresholds.  I
wanted to get some of the details there, it sounds interesting.  I know it's
something also that the Ocean Mining Pool was planning on working on as well, or
maybe they have something that I haven't seen yet either.  It's cool to see this
being worked on at the mining pool level.  Murch, thoughts?

**Mark Erhardt**: I only looked briefly at their tweet and they say that they
won't have a minimum and they will not take any fees on the Lightning
withdrawals.  So, on the one hand, I think that it's a natural good fit.
There's one big wallet that will do a lot of sending, and the amounts are rather
on the smallish side.  I assume that they would have at least some level of
depth that they wait for maybe 20 blocks, or 100 blocks before the payouts are
mature and they would credit their customers.  But I haven't verified that,
that's just gut feeling.  But on the other hand, if you have a wallet that only
sends out, you probably get a little bit of a liquidity management headache.
So, yeah, I'm curious to read more.  Maybe they'll have a blogpost eventually,
or maybe we should try to get them to write about their experiences after
they've been running it for a while.

**Mike Schmidt**: Yeah, it's an interesting point.  If the mining pool is paying
out in anything sooner than I guess those 100 blocks, then essentially Braiins
is fronting that money to the miner by giving them money that isn't quite yet
available to them from the coinbase.  That's an interesting point.  I'm
wondering, yeah, maybe we'll reach out to Braiins and see how that's going.
It'd be interesting maybe to have a write up on Optech if there's something
there to talk about for other pools who plan to do something similar.

_Ledger Bitcoin App 2.2.0 released_

Last piece of software this month, Ledger Bitcoin App 2.2.0 being released.  And
the headline feature here is miniscript support for taproot.  I don't really
have anything further to drill in on that.  Murch?

**Mark Erhardt**: Yeah, I think it's just cool to see that that went pretty
quick.  I think miniscript taproot support was only merged, what, late last
year, three months or so, and I've heard from multiple hardware wallets already
that they already support it.  So, I think all of the -- almost all, Frost isn't
there yet, but a lot of the things people have been waiting for in taproot are
starting to settle in place.  And I mean, it's been active for two-and-a-half
years, so it's high time.  But we're starting to see some apps and services roll
out their taproot-based things, but we'll see a lot more of that in the next
year, now that libraries and services and hardware wallets offer the support for
it.

**Mike Schmidt**: And it doesn't hurt that our friend, Salvatore, I think, is
heading up this effort and probably nudging that along quickly.  I'm not sure of
the inner workings there, but obviously he's a big bitcoiner and big into the
tech, so I wouldn't be surprised if he helped nudge that along at Ledger.

_Bitcoin Core 26.1rc2_

Next section, Releases and release candidates, we have two.  First one, Bitcoin
Core 26.1rc2, a second RC for this maintenance release; we've covered the first
RC a couple of different times.  Murch, you mentioned to me offline that there
wasn't really anything super notable that changed here in the second RC.

**Mark Erhardt**: Yeah, I think just the block mutation fix.  The check whether
a block was mutated got some fixes and was backported to the 26 branch.  So,
yeah, as we mentioned in the last two weeks, this is a maintenance release.
This is for people that want to continue to run the 26 branch for the time
being, but want to have the bug fixes.  So, yeah, if you're looking to stay on
that branch, please consider testing.  And if you switch to a new version, roll
it out for some nodes, not all.

_Bitcoin Core 27.0rc1_

**Mike Schmidt**: Bitcoin Core 27.0rc1.  We talked about this release a bit last
week, so refer back to Podcast #293 for a brief overview.  I think we will
probably go into more depth potentially with the release of the testing guide,
which I actually saw this morning is up on the repository as of a handful of
hours ago.  I didn't get a chance to look at the testing guide but, Murch,
perhaps we should dive deeper maybe next week, potentially with the testing
guide author as a guest.

**Mark Erhardt**: That sounds great.

**Mike Schmidt**: Awesome.  Notable code and documentation changes.  If you have
a question for Murch or I, or I see both Sebastian and Russell are still on as
well, if you have a question for any of us, now's the time to formulate that and
request speaker access or comment on the tweet thread so we can get to that.

_Bitcoin Core #27375_

Bitcoin Core #27375, which adds support for Unix domain socket communication
when Bitcoin Core is communicating with a local Tor proxy.  So, Unix domain
sockets are a faster, and potentially more secure way, for exchanging data
between processes that are executing on the same machine.  The faster and more
secure is in contrast to using something like TCP/IP which is currently used,
and those TCP/IP sockets currently that are being used as a way to communicate
between processes over network, but they have additional overhead.  So, if
you're communicating on the same machine, there could be advantages to using
these Unix domain sockets.  This PR only uses these faster Unix sockets for
local Tor communication as a first use case, but there's plans for future work
to roll out Unix sockets more broadly, specifically using Unix sockets for ZMQ,
I2P, maybe on Windows where that's possible, and also some places in the GUI as
well.  Anything to add there, Murch?  Okay, thumbs up.

**Mark Erhardt**: I know nothing about this!

_Bitcoin Core #27114_

**Mike Schmidt**: Now you do.  Next PR, Bitcoin Core #27114 allows for
whitelisting of manual connections.  Whitelist is a startup option for Bitcoin
Core that adds permission to the peer connecting from a certain provided IP
address.  Bitcoin Core previously allowed whitelisting of inbound peers.  And
when we say whitelisting, this is not some binary whitelist where it's just yes
or no, but there are actually several permissions that you can flag as part of
the whitelisting.  A couple of examples, one might be this noban flag, which
means that you won't ban the peer for misbehavior.  Another example flag for
permission would be the relay permission, which will actually relay and accept
transactions from a peer even if you're running in -blocksonly mode.  And
there's a handful of other different permissions as well that you can flag using
this whitelisting feature.

This PR that we're covering this week adds a new field in the whitelist option
to specify permission of outbound peers.  So, my understanding is that after
this PR, the whitelist declarations where you outline those flags will have an
"in" or "out" specifier at the start of the field to designate if the
permissions apply to an inbound or outbound connections.  Murch?

**Mark Erhardt**: I think I understand the addition here with this PR a little
different.  So previously, the whitelist basically only applied to inbound
peers.  So when another node made a connection to you, you could give it some
form of special access, and it would never apply to outbound peers, as in peers
that you had tried to create a connection to.  So what this allows you is to
also give special access to peers that you created the connection to.  And,
yeah, so from what I understood, that is the major contribution here, is that
you can specify a special access for outbound peers.  And I think, for example,
where that would be relevant is, if you have two nodes that you want to have a
privileged connection between, one of them has to initiate.  So, if the
whitelisting properties only happen in one direction, one of them would not get
it every time you make the connection, and now it would be bidirectional.

**Mike Schmidt**: There's a few different interesting resources around this PR
that we just discussed.  One is, there is a Bitshala Bitcoin Core PR Review
Club, which is separate from the PR Review Club that we normally cover, that
does cover this PR #27114, so check that out for some details there.  And
there's a related PR on the other bitcoincore.reviews, the traditional Bitcoin
Core PR Review Club that we talk about, for a related PR, which is #26441.  So,
if you're interested in this topic, check those out for a little bit more
information.

_Bitcoin Core #29306_

Next PR this week, Bitcoin Core #29306, adding sibling eviction for transactions
descended from an unconfirmed v3 parent.  Murch, I'm punting to you on this one.
What's going on here?

**Mark Erhardt**: Okay, so you all have probably heard of v3 transactions, or as
they have been recently referred to, TRUC transaction (Topologically Restricted
Until Confirmation).  So, we're thinking here about a set of maximum of two
transactions with basically a cluster limited set of transactions to a cluster
of two.  There can only be a parent and at most, one child.  And if there's a
child, the child is restricted to 1,000 vbytes and well, yeah, it can only have
that single parent.  What that does is it reduces the capacity to do a lot of
pinning.  And it is, for example, intended to be used with smart contracts where
pinning can be a problem and you want to restrict how much overpayment the other
party can incur on you by attaching a big transaction.  So, when you have a
transaction that has multiple outputs and it can only have a single child, you
sort of get into the issue where you could have multiple child transactions that
don't directly conflict, because they don't spend the same output.  So, in a
confirmed situation, both of these transactions could coexist at the same time.
But in the restrictions of the TRUC transactions, only one of them is permitted
in the mempool at the same time.

So far, we have never allowed a transaction that exceeds the descendant limit
unless for the CPFP carve out, and we would just drop them on the floor.  This
is over the descendant limit and we don't accept it, and try again later,
basically.  So, in this case though, with the very limited topology in which the
transactions can appear already, we have a few special cases.  One is the TRUC
transactions always have to be replaceable, so they signal RBF replaceability
regardless just by diversion.  Second, since there's only ever a single child,
whether or not you spend the same input, you know exactly which child you might
be conflicting with.  In a regular transaction situation where you might have up
to 25 descendants, it would be a non-trivial question which output you might
replace with a new transaction if you were to accept a sibling instead.  But
with TRUC transactions, since there's only ever a single child, it is obvious
that these two children are competing, and then we do what would be the
incentive-compatible thing to do.  We pick the one that pays more fees, or that
is more attractive to miners to include in a block; we keep that one instead of
just the first one we've seen.

So basically, if we had seen them in the opposite order, right now we would also
keep the sibling that is evicting the original child.  But we apply all the same
RBF rules, so you still have to pay more feerates, you still have to pay a
higher total fee.  But now, you don't have to pay exactly the same input.  You
just have to pay another output of the same v3 transaction parent.  Yeah, so
that's basically the idea.  And staring at that for quite a bit, even though
there is not a direct conflict here, it seems to make sense and it is
incentive-compatible.  So, it makes the mempool better for the miners.  So,
yeah, that's basically a sibling eviction.

**Mike Schmidt**: Murch, we have a question that is tying together a couple of
things that we've talked about in this newsletter, and I'm hoping you can help
clarify.  The question is from HeroGamer asking, he's linking to the "Sibling
Eviction for v3 transactions" Delving Bitcoin post, which I think is what you
sort of just covered, and asking, "This idea unlocks the ability to cancel
bitcoin transaction?"  So, I think it's maybe confusing the sibling eviction
with the RBF cancel transaction that we were talking about earlier.  Maybe,
Murch, you can help clarify this idea of canceling a transaction with RBF, which
I think would indicate how it's not related to sibling eviction, unless this is
a new way to cancel a transaction that HeroGamer's talking about.

**Mark Erhardt**: No, absolutely.  So, if the other party, that is also getting
paid by the parent v3 transaction, uses the child transaction as a means to
perform a payment, then absolutely the counterparty that is using sibling
eviction to supplant the original child with its own child is basically
canceling the payment of the original child.  In the context of where v3 is
intended to be used, that would basically be uncommon, I would say.  Usually,
your intent is here to, for example, bump a commitment transaction to get it
confirmed in order to, for example, unilaterally close a Lightning channel or
other smart contracts, coinjoins, whatever.  And here, I think the main intent
of the child transaction usually would be to reprioritize the parent and get it
confirmed, especially in the context of, for example, either minimum feerate or
zero feerate commitment transactions.  So, making a payment with the transaction
that bumps the commitment would be unusual, I'd say.  But in that sense, yes,
you could basically cancel a payment that another party has performed.

_LND #8310_

**Mike Schmidt**: Thanks for clarifying that, Murch.  HeroGamer, I hope that
answers your question.  Next PR, LND #8310, which adds support for the ability
to have sensitive configuration options, specifically the rpcuser login and the
rpcpass (password) word options to be pulled from the operating system's
environment variables, which better protects those potential secrets, compared
to those values just sitting in a plain text configuration file.  So previously,
LND forced users to have the username and password secrets in clear text in that
configuration file, and now that can be pulled from the environmental variables
for the operating system.  And we note in the writeup also, a use case for this
is being able to have the LND configuration file be version-controlled without
storing the actual username and password in that version-controlled
configuration file.  And this is something, Murch, that I understand that
Bitcoin Core already does similarly support such configuration.  Is that right?

**Mark Erhardt**: Honestly, I don't know.

_Rust Bitcoin #2458_

**Mike Schmidt**: Me neither, I read it somewhere.  Rust Bitcoin #2458 adds
support for signing taproot in PSBT to Rust Bitcoin.  And I thought it was
interesting that this PR actually came from a downstream user of the Rust
Bitcoin library, a developer from the Keystone Wallet team.  And so, the
Keystone Wallet team created an issue on the GitHub for taproot support in PSBT,
but not only that but they also then, I think it was about a week later, opened
this PR, which was very much welcomed by the Rust Bitcoin devs.  One of the devs
noting, "This is awesome, thanks a million for working on this.  And also, it
has been sorely needed for a long time and no one has gotten around to it.
Really appreciate your efforts".  So, we love to see, in this case I believe, a
commercial user of open source actually committing some code to the repository
that they use for features that they want, so that's nice to see.  So, I wanted
to highlight that.  Murch, any comments on this Rust Bitcoin PR?

Well, thank you to our special guests, Russell, AJ, and Sebastian, and thanks
always to my co-host, Murch.  That was a great newsletter, great recap, and
we'll see you next week.

**Mark Erhardt**: See you next week.

{% include references.md %}
