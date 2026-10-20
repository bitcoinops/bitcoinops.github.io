---
title: 'Bitcoin Optech Newsletter #414 Recap Podcast'
permalink: /en/podcast/2026/07/21/
reference: /en/newsletters/2026/07/17/
name: 2026-07-21-recap
slug: 2026-07-21-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Keagan McClelland and Andrew Toth to discuss [Newsletter #414]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-6-21/428366795-44100-2-437315dfbd43e.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #414 Recap.
Today, were going to talk about a new project that's applying formal
verification techniques to the Bitcoin protocol; we have two Releases to
Bitcoin Core, they're maintenance releases that we're going to jump into; and
then we have Notable code and documentation changes, including some IBD speedup
work that we have a guest on to talk about as well.  This week, Murch, Gustavo
and I are joined by a couple of special guests.  We'll have them introduce
themselves briefly.  Keagan?

**Keagan McClelland**: Hello, hi, my name's Keagan, I have a background in
some layer 2 development, including Lightning and some BitVM stuff.  And I'll
be talking about some of the formal verification techniques that were
aforementioned as we get into it.

**Mike Schmidt**: Great, thanks for joining.  Andrew?

**Andrew Toth**: Hi, I'm Andrew, I work for Exodus doing Bitcoin stuff, and I'm
sponsored by OpenSats to do open-source Bitcoin stuff.  And I've been working
on Bitcoin Core for a number of years now.

_Formal verification of the Bitcoin protocol_

**Mike Schmidt**: Awesome.  Thank you both for joining us.  We'll jump into our
first and only news item titled, "Formal verification of the Bitcoin protocol".
Keagan, you posted the Bitcoin-Dev mailing list, and I believe Delving Bitcoin
as well, about your project to bring a formal verification approach to the
Bitcoin protocol.  You posted about btc-verified or is that Bitcoin-verified?

**Keagan McClelland**: That is, yeah, I mean I've actually not really ever said
it out loud, so candidly I'm not sure how you're supposed to say it, so you
guys can decide and there's no way that's wrong!

**Mike Schmidt**: So, btc-verified is written in Lean4, and so we've thrown out
a few things here.  We have the Lean4, we have the btc-verified project, we
have this idea of formal verification of the Bitcoin protocol.  Keagan, maybe
you can give us your perspective.  What is formal verification and what can it
do for Bitcoin and the Bitcoin protocol?  Maybe we can start there and then we
can get into your project, which is motivated, I assume, by the answer to that
question.

**Keagan McClelland**: Yeah, okay.  So, maybe the best way to start the
conversation is, let's talk about what formal verification is.  So, for the
audience members who have written code before, some of this will be familiar.
But when you write software, there's a whole spectrum of things to choose from
in terms of programming languages and styles.  But when we write software,
there's the code that actually executes and does the computations, but then
there's also the set of things that you need to do to ensure that your software
is correct.  Any working software engineer has experience writing tests of some
kind, whether they're unit tests or otherwise.  And then, depending on which
sort of discipline you come from with respect to software and engineering, you
may also have experience with type systems.  So, like I said, there's a
spectrum.  It goes from, on one end, you have dynamically-typed languages, such
as JavaScript, Ruby, Python, etc.  And then, what most people in the Bitcoin
space will have some kind of experience with is something like a statically-typed
imperative Language, like C, C++ or the canonical ones in this space, because
that's what Core is written in.  But it's things like Go are included in there,
Java would be included in there.  There are certain features of those
programming languages, and Rust is the other major one that people would
recognize, that fit into that category.

There's a number of differences between those sets that I was talking about, but
the main difference between those clusters is that they have this notion of
static typing.  Now, when type systems were first invented, they were things
that were there to help the compiler decide how to lay out your code in the
silicon.  And when the type systems started to improve, they started to take on
a different shape that made them have a different role completely after that.
Where do I want to go from here?  All right, anyone who has written programs in
statically-typed languages knows that there are certain entire classes of tests
that don't even make sense to write anymore.  For instance, if you're writing in
C++ and you write a function, and that function takes a number of arguments, you
don't need to write that say, "Well, if I parse a string into a function that
expects a number", I don't have to check that the function appropriately returns
an error or returns some null value that would denote that you've misused the
API, because the compiler statically rules out the possibility of misusing the
API in that way.  And so, as a result, you start to learn that these types can
be used to enforce certain invariants about your code that might otherwise not be
enforceable, or it might require a different layer of work, ie testing, to ensure
that they are enforceable.

In that case, there's a question about just how far can we take those ideas,
right?  If you could start to write arbitrary types that represent certain ideas,
and that the ways that you can enforce those invariants can get arbitrarily good
-- sorry, I'm losing the thread here.  Let me start this explanation over.  Once
you realize that static types can rule out certain invariants, there are certain
things that you can do to try to encode the invariants that you might want from
your software into these types.  And if you've ever gotten to use something like
Rust, you'll notice that there is a feature within Rust that might differentiate
from, like, old-style C++ or Go, where you can essentially take two types and
mash them together in two different ways.  You can mash them together either as a
product type, where you can say I have some type A and some type B, and I can say
that I have a new type C that is both of those things.  This is present in pretty
much any programming language you can think of.  But there's another feature that
you might want, which is that I might have this other sort of glue type that I
might want that says I can either have type A or type B.  And when you have that
feature, there's all sorts of new things that you can enforce at compile time that
you couldn't enforce before when you didn't have that feature.

So, when you start to introduce these ideas, you start to realize that these type
systems vary in how much power they have, and the power that they allow you to
encode invariants.  And so, there's a question that comes about there, which is if
we assume that there's any stratification or hierarchy between these programming
languages in terms of what they can encode, is there a logical endpoint?  Is there
some type system, some master type system, that gives us the ability to encode
everything?  And when you start to ask that question, and thankfully many, many
researchers before us have done a lot of this work, there is, I don't want to say
it's the best possible one, but it's the one that is rooted most deeply in formal
logic, which means that any truth claim that you can make about a program, whether
it behaves in some way or not, can be encoded in these type systems if they have
something like a dependent type theory.  So, interactive theorem provers, of which
Lean4 is one, they have this dependent type theory that they're based on.  And
when you have that, then you can start to ask and answer a lot more deep questions
about whether or not the software behaves properly.  If you don't have a facility
like this, you're essentially relegated to certain testing strategies that range
all the way up from unit testing to something maybe like property testing.

So, a property test is where you might write a function and you might say, "Well,
I don't want to give specific example numbers or example inputs to the function
and just test it against known outputs, I want to be able to say the invariant in
a little bit more general way".  The example that's very easy to understand is, if
I have some function that computes addition, A plus B, an example might be 3 plus
5 equals 8.  And I can write a test that says that.  But one of the important
properties you might expect out of addition is that it commutes.  So, A plus B
equals B plus A for all A.  And so, you might write a test harness that generates
random numbers, and then sort of does those two separate computations and ensures
that they match.  Now, even if you go through property testing, you are still
limited by only checking the points at which you sample.  And in a lot of cases,
this is really good.  But it'd be better if we could prove that our
implementation, A plus B equals B plus A, for any possible A and B, not just the
100 or 1,000 inputs at random that we chose to test it with, but for any possible
one.

This type of reasoning is not really possible in something like C++, yet it's
still really useful to do when the stakes of a project or the cost of failure is
extremely high.  And I don't think I need to convince bitcoiners that taking this
high-security, no-failures-allowed mindset is generally a good thing.  Now,
granted, we live in a real world where efforts are finite and we have to choose
where they're most effectively directed.  But in principle, the value proposition
makes a lot of sense, especially as the network capitalizes to greater and greater
heights.

Now, there might be a question that arises that was just like, "Why haven't we
done this before?  Is this technology new?  Is it just that nobody's thought it
was worth it?"  And the answer is a little bit varied, which is that even within
the cryptographic ecosystem, we've used proof assistant, like I think Blockstream
came out with Simplicity, and Simplicity was a programming language for smart
contracting that sort of had a design goal of being easily formally verifiable.
And the way that they chose to do that formal verification inside the Simplicity
ecosystem was with a proof assistant called Coq, or it's now been renamed to
Rocq, but you'll see both names in the literature, depending on what era you're
looking in.  Now, why not write all of Bitcoin in this?  And there's a few
different reasons.  Number one, which is that they have different design goals.
The programming languages that are proof assistants are designed to convey greater
understanding of not only the implementation, but the derivative properties we
might expect from them.  But it's not necessarily geared towards making efficient
software that you can run in silicon on low-memory or low-CPU hardware, etc.  And
so, as a result, these programming languages, like anything else, they kind of
niche down into where they're most useful.

So, you can also ask the question like, "Why haven't we done something this before
in Bitcoin?"  And I would argue that the biggest thing, and this is what's most
exciting about this moment in history, with all of the LLMs and stuff that are
coming out, which is that in order to be able to do this type of proofs, like
engineering on Bitcoin, you would first need people who are well-educated enough
in the theory to be able to do it at all, which is a very, very small subset of
the population of programmers.  Not because, I mean it is both genuinely hard and
so it requires a lot of rigorous intellectual thinking, but there are plenty of
people in the Bitcoin ecosystem, especially the people who work on Core protocol
dev, who I think have a level of mathematical and reasoning maturity that they
would be able to do this.  But also, that any work that you do towards this end
is work that's not being dedicated towards actually making software work.  So, in
the early days of Bitcoin's history, the marginal value of allocating your efforts
towards making Bitcoin more useful were far better spent there than in maybe the
time we find ourselves in now, which is that maybe Bitcoin -- I'm not going to
try to take positions on whether Bitcoin is sort of complete or not with respect
to features or protocol stuff, etc.  But you can argue that 17 years into its
operation, it would be a good idea for it to allocate more towards security and
protection of what is already there than to add incrementally new stuff.  But
we'll find in a second that these two goals are actually not strictly competitive.
In fact, the more that we can do, like reason about the security of the protocol,
actually gives us the confidence to be able to change things without breaking
other things.

Then, the last piece is that even for the people who have been widely educated in
the subject, or deeply educated, sorry, in the subject of formal methods, the
actual effort to get anything of significance done was insane, right?  When I give
you the example of A plus B equals B plus A, for someone who knows what they're
doing and doesn't already know the answer, that might take them an hour to prove.
This is a fact that every elementary schooler is taught and accepts and they're
fluent in its use, and it still takes someone who knows what they're doing a
decent amount of time if they don't already know the answer.  And so, this is
where the LLM stuff gets really, really interesting.  And that's because I think
that LLMs are uniquely suited to the proof side of this work.  Some of the things
that you've seen kind of going around Twitter, or just as the industry collectively
understands what LLMs are good at and what they're not, is that for people who can
accurately specify what correct means and have a good level of precision in saying
what that is, having the taste to be able to decide what that is, the output that
they get from LLMs is quite good.  If they don't have that ability, that's where
you get slop.  And this is either because you weren't sufficiently specific, and
maybe the lack of specificity has something to do with the clarity with which you
speak the language to Claude and define what you want; or it comes from a lack of
clarity of mind, where you don't actually know what it is that you want, and
that's why you didn't say it to begin with.  Murch?

**Mark Erhardt**: I mean, that is just a skill that generally translates, right?
In order to assess whether somebody knows what they're talking about, you need to
have a certain acumen in the topic in order to assess the quality of what they're
saying.  So, really, the skill to assess whether the output of an LLM is useful
is, you would be able to do it yourself, or if you would be able to do it
yourself, you are much more capable at assessing and leveraging the LLM.  I think
it was AJ Towns, I saw a tweet yesterday, in the context of how only software
engineers are not upset that their jobs are being automated.  And his take was,
"Well, gee, why are lumberjacks upset that they're only being handed chainsaws?"
So, yes, for programmers who have been all their professional life trying to
express formally what exactly is happening in a program, it's not such a big
change in pace to very precisely instruct a very hardworking, but not very smart
agent, to do your work for you, so we get huge leverage on our work.

**Keagan McClelland**: Exactly, yeah.  And so, what's even more interesting than
that, or sorry, not even more interesting, but it kind of builds on that, is that
for most programming languages, it's true that if I have a function that I'm
trying to write that's supposed to do a certain thing and we can agree what it's
supposed to do, I can write three or four different copies of the code and there's
still some ordering of what might be better or worse between those four different
implementations.  And we can kind of maybe disagree about which ones are better,
but this ordering can form because we have different values, because not all of
what is correct in what the function does is purely expressed in terms of its
"correctness".  There's other things at play, like performance characteristics,
whether or not something is readable or not, and these things matter.

But in proof engineering, it's actually a little bit different, where if you have
a certain claim, and I'll try to give more examples so that people can grab onto
something concrete.  Let's say that these two functions are inverses of each
other, so that for any input, if I run it through one and then I run it through
the other, I get the original input back.  So, encoding and decoding serialization
on the wire is a great example of this.  You might be able to write different
encoders and serializers that have different performance characteristics, but by
and large, if you can prove that they're inverses of each other, and you have four
different proofs that take different approaches to proving this fact, all four of
those proofs are essentially equivalent.  In math, where proofs were much more
common before, proofs had two roles.  They were both trying to prove that the
conjecture was correct, but then also, very often in finding a proof of that
conjecture, you would reveal deep insights about the field.

Formal verification is slightly different in that that second one, we don't really
care that much about.  We only care, does the software do the thing that we think
it does?  And how you get there doesn't matter so much.  So, this is what's really
nice, is that because the proofs are very easily checked, in that there's a very
mechanical, dumb, no-AI process for checking whether or not a proof actually
proves the claim that has been presented, and because we don't care about how it
gets there, once we have that specification for what correct means, we can turn
the LLM loose on it.  And as long as it passes this very small check, very dumb
code that actually verifies the proof, we can just be on our merry way.  And then,
not only that, but the future of this I think is actually substantially better
than it is today.  And that is because the reason LLM coding agents have gotten
so good in the last year is primarily due to reinforcement learning.  So, what
reinforcement learning is, is that you set up an agent in a harness, you give it
a task, and you give it some sort of criteria that it can use to evaluate whether
or not it's correct.  And depending on that process, it'll try, it'll evaluate,
and then it'll try again until it actually gets there.

What's very nice about proof assistants is that they have a very narrow
specification for what is correct.  They give you a language for being ultra
precise of exactly what correct is in ways that Python says it does not.  And as a
result, it means that the reinforcement learning harness can converge, not just in
terms of the agent trying things on your computer as it's coding, but even in the
training environment, it will start to be able to climb the slope of improvement
much, much faster than it will in Python.  And so, per unit data that gets
generated, proof assistants or LLM coding agents will learn faster how to get good
at Lean than they will learn at Python.  So, even though Python's training corpus
is much, much larger, it'll actually probably get better at writing stuff like
Lean faster.

**Mark Erhardt**: Yeah, so one of the interesting things is once you have an
implementation that you know to be correct, you can compare that another
implementation behaves exactly the same way in all of the edge cases.  So, while
the proof code may be very inefficient, it will be efficient enough to run a few
tests on it.  And if you, for example, have a fuzz harness that you have been
training on Bitcoin Core, which is a pseudo random way of finding all the edge
cases in a piece of code, you could turn loose all of those fuzzed test cases on
the prover, and/or have an LLM generate all those test cases in some other way
that can be consumed both by the formally verified software and the underlying
system you want to check against.  And you can turn this into sort of a
correctness harness.

**Keagan McClelland**: Exactly.  And so, I don't know kind of where you want to
take this conversation.  I could talk about this endlessly and I know I've been
talking quite a lot just myself already.  So, maybe I want to turn it over to you
guys, and we can talk kind of whichever direction you guys want to go with it.

**Mike Schmidt**: I had a low-level question, which I think you answered in a
high-level question.  The low-level question, it sounds like it's solved by LLMs,
but Brink had on Russell O'Connor early maybe last year to talk about, I mean he
put out a paper on, I think it was a formal verification paper on safegcd.  And
then, he walked us through an example in video chat like this, of doing formal
verification of a multiplication function in libsecp, and it was an absurd amount
of artifacts.  So, my first question was that, like how are you going to do that
for the Bitcoin protocol?  But it sounds like the answer is use those same or
similar types of tools which I think he mentioned, Rocq and C, LightGen, or
something, and you use those similar tools but you're using it with LLMs who are
maybe good at this with the proper person guiding them; is that right?

**Keagan McClelland**: Yeah, and I will say this.  As I'm working on btc-verified,
there's a whole range of things that people can do when vibe coding right?  And I
have a very high-touch approach to vibe coding.  So, I'll maybe give a very large
prompt to Claude or Codex, or I haven't really tried Grok lately, but about my
preferences and how I want to structure things, which is just informed by my own
sort of intuition and taste and experience.  And then, it will generate something
in terms of a specification, and then it'll generate the proofs for it as well.  I
don't look at the proofs at all, but I'm very, very nitpicky about the
specifications, (a) for correctness, but also (b) because there's different ways
to structure it such that it fits nicely together and we can build up this
hierarchy of understanding; but also, just to make sure that things aren't being
duplicated and that there aren't subtle errors in the way that the specification
is written.  Because even if the proof checks out and you've proven that the code
meets the spec, if the spec itself doesn't match reality, then you haven't really
gotten anywhere.

But what it does do is it very much compresses the surface area of attention.  So,
when someone reviews Bitcoin Core, not only do they have to review the overall
architectural structure of whatever code goes into the codebase, but they also
have to review whether or not the implementation actually satisfies the conditions.
Now, good engineers will oftentimes write high-quality tests, and their tests will
ideally be something that is invariant-driven as opposed to example-driven.  I'm
actually a firm believer that example-driven tests are a way to produce false
confidence, where if you know that 3 plus 5 equals 8 and that's the only test you
write, then there's a million ways you could write the addition function that just
happened to accidentally get that one correct.  And even if you have a handful of
those, the more examples you put in there, the more likely it is that you'll get
the right answer even from examples.  But then, the funny thing is that as you
start to do that, you just approach an invariant-style test anyway, and so all
these proofs and the theorems really, but the equivalent in formal verification of
a test is a theorem.  So, what you would write is like, for all transactions, that
if we decode them after encoding them, we get the same exact transaction back and
vice versa.

So, once you have that invariant, that variant's also much more interesting and
much more elucidating in terms of how the protocol works, because I could give you
a bunch of tests and someone could squint at the test and be like, "How do I know
this test is right".  With 3 plus 5 equals 8, it's easy for anyone to see.  But
even for really, really experienced engineers who know the Bitcoin protocol
forwards and backwards, if I give you an example test like, "Hey, this secp
signature using this nonce over this transaction is this thing," no person could
look at that and be like, "Yeah, that test is right".  But you could absolutely
look at a test that says like, if you have a same transaction, use two nonces, you
should get two different signatures.  Almost anyone who knows cryptography should
be able to express that invariant, look at the test, and see that the test is
actually testing that.  And then, whichever values you use is actually irrelevant.
And so, it just takes it to the natural extreme here.

**Mike Schmidt**: The big-picture question is okay, so what do we do?  What's
going to come out of btc-verified?  I mean, obviously there's a lot of Core-based
nodes on the network.  And so, what does btc-verified look like?  And then, how
does that impact the practical composition of the network?

**Keagan McClelland**: So, it's actually really important to say that I personally,
at least in the near future, do not believe that people will run nodes that are
btc-verified.  Now, maybe that'll come about one day, but there are a lot of hoops
we have to get through first.  And I think that this is not a project that has no
value if we stop short of that.  So, the first thing really is that right now, the
Bitcoin development process has a rotating set of contributors, and it has a very
imprecise way of talking about how changes happen.  If you have an idea for how to
improve the Bitcoin protocol or the codebase, you will go to the forums or you'll
go to the GitHub repository, you'll open an issue, there'll be debates there, and
those debates will take place in nominally English.  And depending on the thread,
it might be a very high-quality English debate, or it might be a very low-quality
one.  But the bottom line is that there's a lot of imprecision in it.  And this is
important, it's useful, but there's still a lot to be desired there.  Moreover,
when those debates get settled, we don't have a sort of referenceable artifact
afterwards that says, "Hey, actually, when these two people argued it out, we
actually discovered this important truth about the protocol that is worth
remembering and stating concisely".

So, btc-verified has the potential in this case to essentially be this living body
of knowledge about the protocol that never actually runs on silicon.  We may very
well continue in a world into the future where everybody's running Core or some
fork of Core, and this might not be run by anyone.  But still, it will produce
this compounding proof capital that helps crystallize our understanding of what
Bitcoin is, all the different paths that we could go down that are wrong, and why
they're wrong, and have ways to point to the artifacts from that and say, "Hey,
this is why we didn't do that".  Because right now, if a new contributor comes to
the forums and asks a question that's already been asked, maybe Greg Maxwell is
patient enough to answer it with a really nice, coherent essay that someone can
reference after, and he's doing God's work when he does that.  But that isn't
always what happens.  There are some times where people just get dismissed and
they're like, "Yeah, we talked about this before.  Shut up and go away".  And
that's not satisfying for the person who comes in, right?  It'd be nice if they
could get a citable reason, because then at least, this person, in a lot of cases,
maybe there's spam, but sometimes, a lot of times, people are coming in with good
intentions, and they're just naïve and new.  And it'd be nice if their interaction
with that process generated knowledge within themselves that they could come back
in a future iteration and contribute to the protocol again, especially since people
don't want to do this forever, presumably; maybe they do, they don't.  But it'd be
nice if we didn't lose a lot when people decided that they're kind of "retiring"
from Bitcoin protocol development.

Then, because of that structure, that structure is also amenable to evaluating
potential changes.  So, if we have a complete description of how the protocol
behaves now, and we want to change something about it, it'd be nice to know all
of the theorems that no longer hold, or all of the ones that do hold, and ask
whether or not we're okay with those things.  And that's just on the protocol
side.  From there, you can ask questions about whether or not the actual
implementations within Bitcoin Core or btcd, or pick your favorite implementation,
actually satisfy these more abstract properties that we as users come to expect out
of the protocol.  One of the canonical examples here is that everyone knows there's
only 21 million Bitcoin, right?  But how?  Why is that true?  There's nowhere in
the code where you can find the constant, 21 million.  Maybe you can in
documentation.  And there's that famous equation that does the summation over all
of the halving epics that gets you there.  But even that equation doesn't exist
anywhere in the Bitcoin codebase.  It's a derivative property of the way that the
code is written.  And so, btc-verified is very amenable to that type of analysis.
If you have the way that a thing is written, like the emission schedule of block
subsidy, you can say, "Here's a theorem.  For all time, there will never be more
than 21 million Bitcoin.  And, oh, by the way, here's the proof", and that proof
is then anchored in the actual algorithms that actually run in Bitcoin Core.

**Mike Schmidt**: You mentioned some other projects, I think, doing something
similar, and if you didn't, we can bring up Hornet, who we had Toby on, are you
familiar with Hornet node and what he's been working on there?

**Keagan McClelland**: Hornet has been brought to my attention recently.  I will
say this.  The Hornet sits kind of on the spectrum between btc-verified and what
Bitcoin Core is doing.  Right now, the consensus rules are written in C++, like
normal, executable, software-engineering, battle-tested C++, but that does not
make them amenable to legibility.  So, if you were to open up the consensus module
within Bitcoin Core, it would still require some knowledge, experience, skill,
etc, in order to be able to make heads or tails of what those consensus rules are
actually saying.  Now, things have improved significantly over the course of
Bitcoin's lifetime.  The quality of them now is much better than they were maybe
ten years ago.  But the reality is, it's still written for the purposes of
execution and not for the purposes of understanding.  My understanding of what the
Hornet Node project is -- you said Toby -- my understanding of what that is, is
that it's a DSL domain-specific language written in the C++ ecosystem that allows
you to express these consensus rules in a much more easily-readable-to-the-average-person
way, such that then they get compiled, I mean it is technically a compiler chain
within the C++ ecosystem, then translates it down into what actually executes.
But the problem is, is that it's still limited to what C++ is capable of, which is
not a full dependent type theory.  And as far as I understand it, my skimming of
the archive paper that was put out that was about Hornet Node, is that it does not
actually make any attempt to put a dependent type theory into this language.

So, there's still a very, very large number of invariants that you might want to
express about it that you cannot, because you do not have things existential
quantification or event, to a lesser extent, you can't move terms and types
between each other, which is a really important part of proving properties about
code.  But it's a lot better than what Core has shipped today in terms of this
ability to understand and test and verify things.  It's also worth noting that I
would really to see this, and maybe this is a failure on my own part, but I have
not seen actual source code for Hornet Node.  I've seen the paper and the
associated website.  But it's rather strange to me that something that purports to
try to increase legibility and verifiability doesn't have source code published.
But maybe it's forthcoming, or maybe I just failed to see it, but I couldn't find
it when googling it last week.

**Mike Schmidt**: Maybe I'll connect you and Toby if you're interested, but I
definitely want to make sure that Murch or Gustavo or Andrew can also ask some
questions as well.  Anything else, fellas?  Okay, Keags, people are interested,
they're listening right now, what do you want them to do?  How can they take the
next step and help you or contribute in some way?  What's the call to action?

**Keagan McClelland**: So, I'd say if you're interested in formal methods and
applying them to Bitcoin, definitely take a look at the GitHub repository.  I have
tried to be very aggressive in putting the roadmap into the issues and milestones
about how I'm doing this.  I will request a little bit of patience because I think
it's still early in the project, and so certain architectural decisions about
essentially separating computational artifacts from mathematical artifacts is still
really important.  And naming things such that we don't have -- like, part of the
goal of the project is to make it very clear and consistent how we understand the
protocol.  And so, there is, like, for PRs that have gotten external contributions
already, and I have nitpicked them a little bit, so I promise it's not because I
hate your code, it's just I want this to be a durable, living artifact that can
help increase the institutional knowledge of the Bitcoin protocol development
process.  And otherwise, I would say if you're not well versed in formal methods
at all, but you're still interested, definitely come and check it out and take a
look, because I don't think that there's been a better time to try to get into
that space than now, especially because of that major cost reduction from LLMs.
And like I said, that cost reduction is one of the more uniquely free cost
reductions in all of software engineering.

**Mike Schmidt**: Keagan, thank you for taking the time and joining us today.  We
appreciate it.

**Keagan McClelland**: Yeah, thank you for having me on.

_Bitcoin Core 30.3_

_Bitcoin Core 29.4_

**Mike Schmidt**: You're free to hang on or you're free to move on if you have
other things to do.  We're going to jump to the Releases and release candidates
segment this week.  We have two, and we're in luck, because they're both Bitcoin
Core PRs.  We have Murch here, we have Gustavo, who authored the segment, and we
have Andrew, Core developer and also contributor to some of what went in here.
So, Andrew, you volunteered to help walk us through this.  Take us where you want.

**Andrew Toth**: Yeah, sure.  So, so there's a Notable change in these two
releases, and it also was a change that was in 31, the point release that was
covered last week, which is a bug that would overwrite the chainstate repeatedly
and cause a lot of unnecessary disk I/O.  And so, I worked on fixing this, and so
I can speak to the bug and give a little background about how it came to be.  So,
I want to say that this was a longstanding issue before even version 29.  It just
wasn't as severe.  So, in previous releases, there were issues.  Well, there was
an issue in the Bitcoin GitHub from a user frustrated about database compactions
occurring every time the node was started.  And then, there were other users who
were experiencing this.  It was being investigated, but the root cause wasn't
determined yet.  And looking back, the issue was that every time the node was
stopped, the chainstate was flushed, so a small file was written to the chainstate
database.  And then on startup, when we verify the chainstate, we read, I think,
six blocks and connect them.  And that caused a lot of reads that happened on the
chainstate directory.  And so, that last file that was written on shutdown gets
compacted.  And so, this was an annoyance, but it wasn't really a severe bug.
Yeah, go ahead, Murch.

**Mark Erhardt**: Sorry, what does it mean, "This small file got compacted?"  You
said there was a lot of disk I/O.  If it was only a small file, what was actually
happening here that made it a lot of disk I/O?

**Andrew Toth**: So, the LevelDB works by having levels.  That's why it's called
LevelDB.  And the levels are a tree.  So, the top level is the latest written
entries.  And then, as these files either get too big or they used to get read a
lot, they would be compacted to a lower level.  Each level has ten times as much
space.  And so, when we look up something from LevelDB, it first starts reading
for entries at the top level, and then it finds the direction to take to the next
level, and it keeps going down the tree until it finds the file it needs.  And so,
when we flush the chainstate, we are writing the diff of everything that happened
in the UTXO cache.  So, any transactions that were connected in recent blocks will
erase UTXOs and create new UTXOs.  And that change exists in the cache only until
we write that to disk.  And when we do a chainstate flush, which is on shutdown or
previously, every 24 hours, we would write that as a file to the chainstate
database, and that would be a small file.

So, this wasn't really a huge issue before, because I was going to say, in v29,
we made this problem worse, because we made a change to the LevelDB default file
size.  We increased it from 2 MB to 32 MB.  And this was done for the purposes of
speeding up IBD (Initial Block Download) and index syncing.  And so, you can see
in Lawrence's charts, there's a big drop from 20 to 29 in IBD speed, well, drop
meaning less time.

**Mark Erhardt**: Drop in time, a speed up, yes!

**Andrew Toth**: And so, there's a big speed up in v29.  This is primarily due to
this one line change, where we changed the LevelDB file size.  But that had a side
effect, right?  So, now all the files are 32 MB.  So, if a small file is being
compacted in the chainstate database, every entry is random, right, because
they're SHA256 hashes, they're txids and a vout.  And so, a small file in this
database would have keys in pretty much every other file in that database.  So, if
it's compacted, each entry has to find its corresponding file in the lower levels,
and those entire files get rewritten.

**Mark Erhardt**: Right.  So, basically, our intermediate solution is to put a
stack of documents on the file cabinet.  And then, when we find that we are
looking up a lot of stuff all the time, we actually put it in the hanging folders
in the file cabinet.  And if we have a bigger stack, we have to touch a lot more
drawers in the filing cabinet.

**Andrew Toth**: Yeah, so each file, though, would have a bunch of stuff in it
and if you were going to take one file from the top and put it in, you would have
to actually take all those papers out and put them all into a new folder, right?
You couldn't just stick one into the folder, you have to rewrite that whole file.
And so, previously, those folders were smaller.  And so, if you had five pages,
you'd only pick five small files and rewrite those.  Now, these lower folders are
much wider.  So, they pretty much take up, if you have five pages, they would take
up all five of those and you'd have to re-put in five new ones.  It's a great
analogy, Murch, thanks.

**Mark Erhardt**: So, our stack got 16 times the size and the drawers got 16
times the size.  So, if we open a drawer and have to reorganize the whole drawer,
it affects 16 times the data, so probably 250 times, or something, the data
touched?

**Andrew Toth**: Yeah.  I mean, so right now, every time we did a compaction, it
would be about 15 GB of read and write.  I'm not sure before, I haven't really
measured what it was before, but it wasn't noticeable before; I'll get to why I
didn't notice it before.  So, in theory, because our files are now 32 MBs, that
first file that's on top of the file drawer, we should be able to fit 16 times
more data before we have to then take that and put it down.  The issue is LevelDB
has this feature, called seek compaction, which is if you are just reading from
this folder, if you read enough times from it, you have to compact it before it's
full, which is an anti-feature in my opinion.  And so, what happened was, in v29,
every 24 hours when we would write that small file when we flushed our chainstate,
we would then get lots of reads immediately after on the top file, because every
mempool transaction that comes in, we have to look up the UTXOs they're spending.
And that causes a read on the first file as it goes to find its other files;
they'll always hit the first file.  And that exhausts the read budget on that
folder and would cause it to compact.

Then, in v30, this got even worse, because now we write a small file every hour
instead of every 24 hours.  And so, when I was making that change to write every
hour, I did I/O measurements on seeing if this was an issue.  But the measurements
I did was before that change of file size was merged.  So, that's some learning we
can do to make sure that we remeasures things that right before we're merging or
before the release goes out.  So, this wasn't really reported by anyone until v31,
and then we got a slew of reports that there's hundreds of gigabytes of disk I/O
happening.  And this led us to discover that it was seek compaction.  And so, the
fix there was to just disable seek compaction in LevelDB, and now we've
backported that to v31, 30 and 29.

**Mark Erhardt**: Right, so it had been a great focus in the last few versions to
improve IBD.  And as it goes, when multiple people focus on working on the same
sort of area, changes synergize or maybe affect each other.  So, in this case,
specifically, the one thing that was introduced was we used to only flush the UTXO
state every 24 hours, but you improved that by allowing it to be flushed every
hour, which means if, for example, a node crashes, it will not lose as much
progress.  And you also introduced that the cache was kept hot, or warm, I should
say.  So, only the, is it the dirty UTXOs are being written out, whereas the ones
that were just loaded and not changed, they're kept in the cache unless the cache
is full.  Only when the cache is full, we flush it completely to disk.  If the
cache has only been sitting for an hour, we write out all the changed UTXOs to the
chainstate database, but we keep the ones that were just loaded.  So, this meant
that the UTXO cache would fill up less often, and we would lose less progress if
the node happened to crash.  But then, in combination with making the file size
bigger in level DB, you ended up having the flushes much more often, the files
getting sorted into the cabinet much more often, and touching way more off the
cabinet at the same time.  And now, suddenly we got a lot of disk I/O as LevelDB
basically got rewritten, what, every hour?

**Andrew Toth**: Yeah.  I mean, so the main issue was that LevelDB has this
anti-feature called seek compaction.  And without that, it would never have
rewritten, because we could still write every hour and it wouldn't compact until
that file gets full to 32 MBs, right?  With seek compaction, as soon as we put a
new file there, all the mempool transactions would read it and it would cause it
to flush way too prematurely.

**Mark Erhardt**: So, in sum, we got a few new features that make IBD faster.
And now that they've been out in the wild, we've also found out a couple of the
bumpy corners and padded them.  Maybe this is a good point to lead over a little
bit.  Oh, maybe one more word.  So, we talked about Bitcoin Core 31.1 released
last week, and I bumbled through trying to explain the chainstate issue that
Andrew just explained.  So, that was what I was trying to say.  And other than
that, basically, these are the three currently active major branches: 29, 30, and
31.  So, all these bug fixes and improvements have been backported as appropriate
to the major branches.  If you're, for example, trying to stay on major v29 for
some reason, you can get all the new features or fixes by upgrading to 29.4 --
sorry, not all the new features, just the fixes.  The features are only released
in major.

_Bitcoin Core #35295_

So, how about we use that as a lead over to another improvement to IBD in our
Notable code and documentation changes segment?  So, we mostly invited you for
this one, which is Bitcoin Core #35295, and you've been working on this for almost
two years.  I see that there have been over roughly, well, around 1,000 or so
review comments, maybe even more, because it was split up over several different
PRs after a while.  So, you've made a major improvement on how we load UTXOs from
the disk when we validate blocks.  How about you take us a little bit through
that?

**Andrew Toth**: Sure, yeah.  So, you were touching on that too when you mentioned
that we keep the cache hot now over flushes.  So, that was a big improvement,
primarily that was initially done to keep the cache hot over steady state, right?
So, every 24 hours, we would flush the cache.  And then, right after we had
flushed the cache, new blocks coming in would be connected slowly.  But then, that
was a segue to then keeping the cache hot for pruning flushes, which improved IDB
for pruning.  And really, keeping the cache hot means that anything in the cache,
when another block comes and spends it, we don't have to read that from disk
because it's in our cache.  But still, especially in the blocks 800,000 to
900,000, the cache gets too big too quickly, there's lots of new UTXOs being
created.  And so, the cache flushes, and now we have to read them again.  And so,
this change is a speedup to how we repopulate the cache before we read a new
block.  So, it improves IBD quite a bit, especially on certain systems with
high-latency disk.

Also, it improves it on steady state.  So, if your cache flushes during steady
state, you will now see faster block connection from new miners who produce blocks.
And that has a second-order improvement to block propagation too, because if you
send a compact block message after you get it, before you validate the block, if
your peer has some transactions missing from that compact block, it can't
reconstruct it, it will ask you for those transactions.  If you're still validating
that block, it will have to wait for you to finish validating the block before you
can respond.  And then, that has a cascade effect of how the block could propagate.
So, we should see a lot of improvement from this change.

So, the main mechanism here is that when we get a new block, we have to validate
it.  We don't know yet if it's good or not.  So, we do some checks that are
stateless checks.  So, we can check that it's within the right size limits, the
merkle branches are correct, the PoW is correct.  But then, we actually have to
measure it or validate it with the current chainstate, the current UTXO.  So, we
have to know that every transaction is spending valid UTXOs, that they exist,
they're not double-spending any UTXOs, and that their UTXOs are being spent
correctly, like they're not forging signatures or anything.  And so, to do this,
we have to look up all these UTXOs from the chainstate.  And we have a cache of
UTXOs, but if the UTXO is not in the cache, we have to go to disk and look it up.

So, before this changed, the way the validation code would work is it would go
through every transaction's inputs one by one and look up the UTXO.  So, first we
go to the cache.  If it's on the cache, it would wait for the lookup to the disk,
and then puts that back into the cache, and then gives it to the validation code.
And the validation code is waiting for this whole lookup for every input in a row.
So then, we'll do the next input, wait for the lookup, the third input, wait for
the lookup.  And all this waiting for the lookups stacks up, and certain systems
especially would dominate the validation time, just the waiting on these lookups.
So, what this change does, it does these lookups much more efficiently.  So, we
already have this block and we know, even if it's not valid, we know what inputs
the validation code is going to want to look up, because we have the block.  So,
we use that information to kick off these worker threads to then look up all these
UTXOs in the background, and multiple threads at a time.  So, we can be looking up
eight at a time instead of just one at a time.  But also now, this unblocks the
validation so that it doesn't have to wait for that single read.  It's just going
to get the UTXO that was already fetched by one of the workers, and then continue
validating as the workers are also then fetching the later UTXOs.  And so, this
parallelization greatly speeds up IBD and block validation in general.

**Mark Erhardt**: Right, so in steady state when we're at the chain tip, we
generally hear about a lot of the unconfirmed transactions that are floating around
in the mempool.  When we see transactions, we look up the UTXOs their inputs are
spending, and we validate the transaction and cache that validation.  Then, when a
compact block announcement comes in, which is sort of the recipe how to recompile
the block or how to rebuild the block from the mempool and other information we
have, we can just look at our mempool and see what is cached there already and
very quickly validate the block.  For any of the transactions that we haven't seen
before, we have to go to disk and look up the UTXOs.  And this is where Andrew's
improvement comes in.  Instead of looking for one UTXO that you're missing and
coming back and looking for the next UTXO, and so forth, ping-ponging back and
forth, we now, you said, up to eight threads take just a list of things to look up
and, well, up to eight things to look up in parallel, and fetch all of them and
put them in the cache while the validation thread itself doesn't have to look it
up if it's in the cache already.

So, basically, there's a clerk introduced at the start of the block that just
takes a list of all the inputs that will appear in the block, and start sending
his helpers off to pick up all the UTXOs and put them in the cache already.
Whereas the validation thread starts at the top of the block and just goes through
the transactions, but the helpers have probably already scurried and gotten the
UTXOs.  And now, in the steady state, where we're at the chain tip, where we see
the unconfirmed transactions often before the block arrives, there's very few
transactions generally that we haven't seen when the block comes in.  But during
IBD, you do not have a mempool, you do not see transactions before they arrive.
So, for every block that arrives, and we're trying to do one per second or more,
you have to get something like up to 7,000 UTXOs.  Well, I think the biggest
block had over 20,000 UTXOs, but generally we have something around maybe 6,000 to
7,000 UTXOs that are being spent in a block.  And as you go through IBD and don't
have a mempool, you have to fetch all of these from all different heights in the
blockchain, mostly recent UTXOs, but not necessarily.  And this is greatly sped up
by just taking attendance first and sending off people to fetch everyone to stand
ready instead of ping-ponging between the validation thread and picking up from the
UTXO database.  Okay, sorry, dumbing it down a little bit and recapping.

**Andrew Toth**: Yeah, that's great.  So, for steady state, I know, Murch, we
had a little conversation in the GitHub PR about this as well.  So, yeah, usually
you have these transactions in the mempool and then you won't have to look them up
from the disk.  So, this change doesn't have a dramatic effect.  It still does,
because you're doing some hashing work to look up these transactions from the cache
in the background, so it speeds it up a little bit.  But one instance where it
does have a dramatic effect is if you fill up your DB cache and then it has to
empty, that doesn't mean your mempool gets cleared.  So, a block will come in,
you'll find all these transactions in the mempool, and then when you go to
validate the block that you've reconstructed, all those values will be erased from
the DB cache.  And so, I was seeing really bad block times when the cache was
cleared.  And so, if I was running on an AWS EBS volume, EC2 EBS volume, they have
about one-millisecond latency.  And so, you have, like, 10,000 inputs, that's 10
seconds of just looking up blocks.  So, sometimes block speed at tip would degrade
to 10 seconds.  And so, this change helps in this worst-case scenario to really
help speed up block validation.

**Mark Erhardt**: Right, yeah.  So, sometimes miners just stuff a block full of
transactions that you haven't seen before.  And in that case, you're basically in
the same scenario as in IBD, where you haven't seen anything and you have to just
load very quickly; or if your cache is empty.

**Andrew Toth**: But also, not just if you haven't seen them, but if miners are
mining non-standard stuff.  Or, like, you're on a different policy than the
miners.

**Mark Erhardt**: Right.  You can also put that on yourself that you don't see
them, but you still haven't seen them, right!

**Andrew Toth**: Yes!

**Mike Schmidt**: Andrew, what are the headline numbers here in terms of
performance?

**Andrew Toth**: I mean, it varies depending on your system a lot, but we haven't
seen any system that was less than, I think, 50% faster.  And for
network-connected storage like I was experimenting with, if you're running on AWS,
I saw up to three times faster IBD.  So, it ranges, I think, typically about 35%
if you're running on a laptop or something.

**Mike Schmidt**: Very cool.  Nice work, Andrew.  Awesome.

**Andrew Toth**: Thank you.

**Mike Schmidt**: Murch or Gustavo, I just want to close out the Releases.  Was
there anything else that we should note from the Releases?  I know we dug in on
the chainstate discussion.

**Gustavo Flores Echaiz**: I think another important item from both releases is
the inclusion of the PR #35209, which was a fix to the CVE bug found in
CVE-2024-52911.  I believe these are the first maintenance releases to include
this in 29 and 30.  So, this was initially covertly fixed in v29, and then there
was a cleaner fix that has been shipped in these two maintenance releases as well.
So, those are the two main items of these releases.  Also, 30.3 has additional
items related to PSBT and miniscript, but they're all quite minor.  29.4 almost
has these only two items.  It does have other things that are way, way less minor,
but anyways, listeners can check out the release notes for further details.  But
what Andrew's explained was the main objective of these main releases.

**Mike Schmidt**: Great.

**Mark Erhardt**: Sorry, could you remind us what the CVE was that was fixed?  I
didn't get that from our newsletter.

**Gustavo Flores Echaiz**: Yeah.  So, this was something we covered a while back.
It's CVE-2024-52911, which was an issue that was fixed initially covertly, and
then this fix was a clean fix.  So, give me just a second to pull from the
previous newsletter to remind me.

**Mike Schmidt**: Correct lifetime of precomputed transaction data.

**Gustavo Flores Echaiz**: Yeah, so in Newsletter #405, we covered the PR #35209,
which was addressing the root cause of this issue.  It was now constructing the
txsdata vector before the CCheckQueueControl object, because what it says is that,
"C++ destroys local objects in reverse construction order".  And now, we were
ensuring that the script check queue was completed before the precomputed
transaction data, referenced by the queued CScriptCheck, was destroyed.  And this
also was referenced in Newsletter #333, when the covered fix was shipped.  But the
CVE issue was simply covered in Newsletter #405, and the full-on fix was also
included in that item.  So, yeah, so #405 is where all the details are.

**Mark Erhardt**: All right.  I think this was the one where you could build an
attack block that had to have very specific transaction data in it that could cause
you to have the transaction dereference before you try to read from it.  And then
it would crash, or could crash, because of undefined behavior.  Is that the one?

**Gustavo Flores Echaiz**: Yeah.  So, basically, it says, "Script Interpreter
Remote Crash disclosure, a vulnerability affecting versions of Bitcoin Core after
version 0.14.0 and before 29.0.  Validating a specially-crafted block could cause
the node to access previously freed memory".  And yeah, so it's exactly what you
described.

**Mark Erhardt**: All right, thank you for the reminder.

**Mike Schmidt**: Gustavo, do you want to pick up where we left off on the
Notable code items?

**Gustavo Flores Echaiz**: Yes, certainly.

**Mark Erhardt**: Do we have one more for Andrew?

_Bitcoin Core #35568_

**Gustavo Flores Echaiz**: Yeah, there is one more for Andrew.  So, maybe we can
just skip to that one directly, which is #35568.  It was disabling Bloom filters
to optimize disk usage in the txospenderindex.  So maybe, Andrew, you want to give
us the details on that one?

**Andrew Toth**: Yeah, sure.  So, that's another LevelDB optimization.  So,
txospenderindex is a new index that was released in 31 that lets you look up the
transaction that spends your output, I think.  And it's a fairly beefy database,
right, it was almost 100 GB on disk.  And the way it reads values though is a lot
different than other indexes.  So, it was using an iterator to look up a prefix of
the outpoint that was being spent.  And it would seek to that prefix, and then it
would try and read that prefix.  And if that prefix was a false positive, it could
just iterate to the next prefix.  This lets us store that data efficiently.  But
the thing about that is that it doesn't need to use the Bloom filters.  So, Bloom
filter, for those who don't know, is a data structure that lets you efficiently
query if a value is not in a set.  So, if you look up, "Is this value in a set?"
You can 100% guarantee if it says no, then you can move on, because that item is
not in that set.  If it says maybe, then there's a high chance that that entry is
in the set.  But then, depending on how you configure it, I think in our DB, we
have about a 1% false positive rate, so you always have to check if it's in there.
It might not be in there, you might be getting a false positive.  But the point is
that you can move on if it's not in there.

So, these Bloom filters are used in all our LevelDB, or they were used in our
LevelDB databases, to allow point reads to be able to skip files.  Like we were
talking, there's a tree of files, right?  And if you are looking up an exact file,
you have to go through each file in the tree until you find the correct one.  And
you would have to actually go through each file and look at all of them to see if
it's not in there.  But with Bloom filters on each file folder, you can just
consult the Bloom filter and know definitely, if that file is not in this folder,
we can just skip it and not have to do any reading and move on.  And this is great
for the chainstate database, because we're looking up exact UTXOs.  But for this
case of the txospenderindex, we are just seeking with an iterator.  So, because
we're looking up a shared prefix and we have to look up anything greater than that
prefix, that's how the seeking works.  A Bloom filter doesn't know anything about
the set that's in there, whether anything is greater than or less than a key.  It
just knows, "Is this particular specific, exact key in there or not?"  So, we
can't use that Bloom filter construct for this type of read pattern.

So, creating these Bloom filters for every folder is work, and it's also data on
disk that we have to store for that folder.  So, by disabling the Bloom filter, if
we're not needing it, we save both time and disk space for this database.

**Gustavo Flores Echaiz**: And if I understand correctly, these filters were
inherited in this new index because they're also used in other indexes, but then
it was realized that it wasn't necessary to be included here?

**Andrew Toth**: Yeah, that's exactly right.  So, by default, we put this Bloom
filter on all our databases.  And so, now the way this PR worked, it made putting
that Bloom filter an option.  So, in the future, we can reevaluate our other
database usage as well and remove this Bloom filter if it makes sense to do so.
But in this case, it's also backwards-compatible.  So, if you already created your
txospender database and you upgrade, you won't have to do anything.  You will still
keep those Bloom filters existing, but you won't use them.  So, if you want to
reap these space savings, you need to delete and re-index, and that's an option
that users will have in v32.

**Mark Erhardt**: Let me try to sum it up as I understood it.  So, basically, we
have something called a Bloom filter for our databases and Bloom filters enable us
to know for sure if something is not in a drawer, but we might sometimes get a
false positive.  So, we always get true negatives, but sometimes false positives;
you said 1% right?  And this Bloom filter enables us to rule out drawers or
folders if we're looking for a very specific file.  But when we're looking for all
files that start with the letter A, we can't use it because we can't feed a prefix
into the Bloom filter and rule out things.  So, we weren't actually using the
Bloom filters at all in this case, and they were just obsolete.  So, deleting them
makes it faster to run the index creation and it makes the index smaller.  And in
this particular case, we were not using them at all because they weren't useful.

_Bitcoin Core #34897_

**Gustavo Flores Echaiz**: Thank you, Murch and Andrew.  So, the next item, we go
back into the regular order.  The next item was Bitcoin Core #34897.  So, here,
an issue was found where an index, such as coinstatsindex could get further ahead
to the UTXO state that had been flushed to disk.  So, in an unclean shutdown, this
could cause the index to be ahead of the chainstate's latest flush, and it would
create an inconsistency between the two databases.  And this was particularly a
problem for coinstatsindex, which MuHash state to roll it back requires
reprocessing the corresponding blocks, or the corresponding UTXOs that had been
lost and had not properly been flushed to disk.  And this occurs because the
finalized digest that is produced per height, the per-height record in the
coinstatsindex, is a SHA256 32-byte hash of the live accumulator of each height.
So, you do have the live accumulator of the current height, which means all the
stats of the UTXO chainstate database, so how many UTXOs are active, and so on.
But if you wanted to roll back this database to the tip where the chainstate had
been flushed to disk, you would require those blocks that were not safe to block,
because simply you cannot revert a hash without its previous data.

So now, the fix is for Bitcoin Core to always ensure that an index, such as
coinstatsindex, will never get ahead of the chainstate's last durable UTXO flush
by skipping a commit, unless the index tip is an ancestor of the last flushed
chainstate block.  And yeah, that's it.  Anybody want to add any context here?

_Bitcoin Core #35406_

We move on with the Bitcoin Core item #35406.  So, here, a new limit is added to
the private broadcast feature, which we covered in Newsletter #409, which allows
you to choose a short-term circuit or a short-term connection to broadcast a
transaction with a different identity, also called the private transaction
broadcast.  So, this feature has a tracking queue, which are the transactions that
have been broadcast to one peer only in this short-term connection, and were
waiting for our other peers to send us back that transaction, and that would allow
us to prove that it was properly broadcasted.  This is the tracking queue, these
transactions remain here until they are received to our node by another peer.
However, the issue here was that if you would have policy differences with the
peer you are sending this transaction to, then he would never relay it onto other
peers and onto the network, and you would simply never get it back.  So, you could
potentially have an unlimited tracking queue that would consume an enormous amount
of resources.  And here, there's a cap to 10,000 transactions in this tracking
queue.  Yes, Murch?

**Mark Erhardt**: I wanted to add a little context on this number and how we
submit transactions via private broadcast, and I think Andrew has also looked at
this quite a bit.  So, Andrew, chime in, please, if you have anything to add.  So,
private broadcast is a new feature that we added in 31.  It's basically the idea
that instead of offering a new transaction to all of our peers, we pick one node
in the network, teleport our transaction just to them, and see whether it comes
back to us via the open network.  So, we make a Tor connection and just connect to
one peer that we haven't made a connection to before and say, "Hey, I have a
transaction for you.  You got it?  Okay, bye".  And so, the idea is that this
other peer, hopefully, or this random node in the network, takes this transaction,
puts it in their mempool, propagates it to all their peers, and this removes the
IP address of the original sender from the transaction, or disassociates them.  So,
surveillance that have lots of connections in the network will not actually see the
node that originated a transaction as the first one propagating it to its peers.

If the first person that we send it to doesn't forward it and it never comes back
to us, we actually retry.  So, we will send the same transaction to multiple
peers, I think three attempts or so, and only after each of those had a few
minutes, we will actually propagate it ourselves.  So, the idea that transactions
would hang around forever is pretty unlikely, unless we're sending transactions
that are so low feerate that they just never propagate on the network and never get
mined.  10,000 transactions are a lot of transactions.  That's about two-and-a-half
blocks' worth of transactions.  So, that any node would have these many
transactions in their private broadcast queues would be extremely uncommon and a
bit of shooting your own foot with a foot gun.  Andrew, please?

**Andrew Toth**: Yeah.  So, it's really just a guard against some kind of
misconfiguration.  Like you said, we won't get that node back if it's a low
feerate or if it's not following policy, non-standard, then we would never get it
back either, and we would just keep retrying.  And so, we do the three initial
tries, but if we don't hear back, we keep that transaction in the queue.  And
every, I think, five minutes or so, we initiate another broadcast.  And so, if we
have poor connectivity so we don't actually manage to make these three connections,
we'll still keep that transaction in the queue.  So, if we have a misconfigured
node, then we don't have many peers, or our Tor goes down, or something, we won't
actually be able to send these out.  And so, if you have this hooked up to a
system that's making lots of transaction broadcasts, these can start piling up.
And so, this is kind of just guard against us crashing your node.  Eventually,
your system will get an RPC error saying, "Your queue is full, so abort some of
these or see what's wrong".  But we're not going to actually crash the node due to
this.  So, I think that's a nice safety feature to have for this.

**Mark Erhardt**: Thanks.  Great addition.

_Bitcoin Core #35380_

**Gustavo Flores Echaiz**: Thank you guys.  We move forward with the next item,
which is Bitcoin Core #35380.  So, here, the libbitcoinkernel API, which we've
covered multiple times, and which was introduced in Newsletter #380 as a C header
that serves an API for libbitcoinkernel, which enables external projects to
interface with Bitcoin Core's block validation and change state logic, here this
API is extended to expose, through a specific view called the btck_WitnessStack
view, to expose each transaction's inputs, witness stacks, and scriptSig to allow
an external application to retrieve the public keys either stored in the witness
data for segwit inputs, or the scriptSig for P2PKH inputs.  So, the goal here is
to allow these external applications, like I said, to retrieve the public keys, but
it specifically targets silent payment scanners who instead of having to deserialize
the raw transactions separately, can simply obtain the public keys of the
transaction inputs through this specific view.  And this is necessary for a
silent-payment scanner to determine whether any of these transactions' outputs
belongs to the wallet.  It needs to scan all the inputs, obtain the public keys of
the inputs, and then combine it, hash it, with its own scan data to in order to
conclude that specifically these P2TR outputs are maybe part of its of its
transactions.  So, this is what this item covers.

_Bitcoin Core #34538_

**Gustavo Flores Echaiz**: The next one, #34538.  Here, the option, externalip,
which allows a node to advertise an address where it accepts inbound connections
and other nodes can connect to, previously if you added an address from a network
that was excluded by the onlynet option, if you had configured that option, you
would simply get an error and you couldn't add that address.  So, what is the
onlynet option?  It's an option that allows you to configure that your node will
simply establish outbound connections via a specific network.  So, you could say,
"I onlynet IPv4", I only want connections via IPv4.  Previously, this was
conflicting with external IP, so onlynet was also applying it to inbound
connections.  I cannot set an external IP from a network that I have excluded via
onlynet, and that was the previous behavior.

Now, Bitcoin Core basically says, "The user is manually inserting an address and
explicitly configuring an address with external IP.  Let's allow the user to use
that, even if it conflicts with the networks that have been excluded via the
onlynet option".  And for example, this could allow a node to only establish
connections via IPv4 as set by onlynet, but also operate separately in the Tor
onion service that accepts inbound connections via Tor and which is configured
using the externalip option.  Also, important to say that the externalip option
isn't validating whether these addresses will actually work and they're properly
configured to open an inbound connection to the node.  So, it's simply trusting
that the user has properly managed that configuration separately.

_BIPs #2208_

**Gustavo Flores Echaiz**: The next item is from the BIPs repository.  It's an
update to BIP54, specifically its rationale around the invalidation of 64-byte
witness-stripped transactions.  So, I believe, Murch, you might have something to
add here.

**Mark Erhardt**: Yes.  So, BIP authors are supposed to document issues that were
raised or concerns as they are being discussed while a BIP is being proposed and
reviewed by the community.  So, in this case, the BIP54, which is consensus
cleanup, just got slightly extended in the rationale section to document the
discussion about the 64-byte mitigation that BIP54 proposes, and the alternative
that Jeremy Rubin has proposed.  So, it was pointed out that either way, nodes
that rely on the fix would need to update in some cases in order to benefit from
the fix.  So, this correction was incorporated.  And there's a link to the debate
with Jeremy Rubin and a commentary on why BIP54 still chooses to stick to its
initial approach.

_LND #10962_

**Gustavo Flores Echaiz**: Awesome.  Thank you, Murch.  The next two items are
from the LND repository.  So, first, LND #10962.  Actually, both of these items
are specifically about auxiliary channels, such as Taproot Asset channels.  The
first one, #10962, is a specific issue when using the RBF cooperative-close flow
that was covered in Newsletter #347, where basically this flow says that either
peer can bump the feerate using their own channel funds.  Previously, in the other
RBF mode, peers had to convince the counterparty to pay for the fee bumps.  So,
this is an easier flow to fee bump a cooperative-close transaction.  So, there was
a conflict between this flow and when it was used in auxiliary channels, such as
Taproot Asset channels, where basically the RBF flow, when increasing the feerate
and choosing a coin to spend, it could accidentally choose a coin that had some
overlay asset included in it.  So, for example, it was 10,000 sats, but in reality
it represented an overlay asset of, let's say, a stablecoin worth much more.  So,
this was included in order to fee bump the cooperative-close flow transaction.

But the issue was that the transaction would go on, would get broadcasted onchain,
even confirmed, but it would not invoke the auxiliary hooks needed to carry the
overlay assets into the closing transaction on the meta protocol that it was coming
with.  So, technically you could destroy the overlay asset when including this
input in the RBF, to add additional funds to fee bump the RBF cooperative-close
flow.  So now, the fix is simply to make the Taproot Asset channels, or the
auxiliary channels as a whole, incompatible with this RBF cooperative-close flow
to avoid using coins that would not invoke the auxiliary hooks required to carry
the overlay asset into the next state.

_LND #10897_

**Gustavo Flores Echaiz**: And the next item, #10897, is a different but related
issue.  It's a bit the opposite direction, where when you are trying to increase a
feerate, you would skip including an output that was not of a sufficient set amount
that would suffice for the feerate increase you wanted.  So, for example, once
again, a UTXO that represents an overlay asset of a very high value, but a very
small bitcoin value, would always get skipped by the sweeper because its bitcoin
value was very small, so it was never included.  And now, basically the fix is to
understand that this output is not simply a Bitcoin output, but it represents an
overlay asset, so include it and include another input that can also be used in
this transaction to increase the feerate to be able to sweep both of these UTXOs.
So, that's the final item from LND.

_BINANAs #21_

**Gustavo Flores Echaiz**: And the final item from the newsletter is a new BIN
number assignment, so in the BINANAs repository #21.  Yes, Murch, I mispronounced
it.

**Mark Erhardt**: You have to give this more of an Australian pronunciation.  The
BINANA repository, I think.

**Mike Schmidt**: There's an R at the end there too, I think, BINANA(r)!

**Mark Erhardt**: Okay.  The BINANAs are, of course, the Bitcoin
Numbers-and-something Authority!

**Mike Schmidt**: Numbers And Names Authority?

**Mark Erhardt**: Right, that's it.

**Gustavo Flores Echaiz**: Yeah, Bitcoin Inquisition Numbers And Names Authority.
So, a new one is assigned to BIP442, BIN-2025-0003.  That number is assigned to
BIP442, which is the proposal for OP_PAIRCOMMIT.  Yes, Murch?

**Mark Erhardt**: Yeah, so the BINANAs serve two purposes.  One is that these
numbers are being referenced when you try to activate a soft fork on Inquisition,
which is running on the default signet.  So, if you want to test your soft forks
on signet, you would request that something is assigned a number and then activate
the soft fork there, and then you can play around with it on the signet.  The
other thing that the BINANAs did was a few years ago, when the BIPs repository was
not moving very quickly, some developers got frustrated.  And the BINANAs
repository served as a means to be able to standardize and publish documents.  The
policy for publishing stuff there is a bit different than in the BIPs repository.
My understanding is, well actually, I think I'm a BINANA editor.  I haven't done
anything, but when someone opens a PR, they get a number.  That's the process.
So, if you need a number for something, you can always go with the BINANAs
instead.

**Gustavo Flores Echaiz**: Excellent, thank you, Murch.  And that is the final
item from this newsletter and it completes the whole episode.

**Mike Schmidt**: Thanks, Gustavo.  Thanks, Keagan and Andrew, for joining us.
Thanks, Murch, for co-hosting.  We appreciate your time everyone and for you all
for listening, and we'll hear you all next week.  Cheers.

{% include references.md %}
