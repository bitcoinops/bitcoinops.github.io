---
title: 'Bitcoin Optech Newsletter #369 Recap Podcast'
permalink: /en/podcast/2025/09/02/
reference: /en/newsletters/2025/08/29/
name: 2025-09-02-recap
slug: 2025-09-02-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Bruno Garcia and Liam Eagen to discuss [Newsletter #369]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-8-2/406746775-44100-2-88a2598fae782.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #369 Recap.
Today, we're going to be talking about the Bitcoin fuzz project; garbled locks
for Bitcoin; and we have Stack Exchange questions touching on quantum,
obfuscating data on disk, and other topics.  Murch and I are joined this week by
Bruno, soon to be here.  But Liam's with us now.  Liam, you want to give a quick
introduction for folks?

**Liam Eagen**: Sure, yeah.  I recently published this paper called, "Glock,
Garbled Locks on Bitcoin".  It's kind of like the evolution of the BitVM style
protocols that replaces a lot of onchain complexity with this cryptographic
primitive called a garbled circuit.

**Mike Schmidt**: And it's got a cool name.

**Liam Eagen**: Yeah.

_Garbled locks for accountable computing contracts_

**Mike Schmidt**: Well, let's just jump right into it.  So, for folks following
along, it's the second news item in the newsletter, which is, "Garbled locks for
accountable computing contracts".  And, Liam, you posted this paper to the
Bitcoin-Dev mailing list and you introduced garbled locks, which is a twist on
garbled circuits.  And at Optech, we've been referring to this in our Topics as
categorized as accountable computing contracts, including things like BitVM, and
we've spoken a bit about some of the related projects in previous shows.  But I
think it would be helpful for you, given this set of topics can be easily lost
on folks, including myself, maybe you can help us understand, what is the big
picture; what are we trying to achieve here; what are these optimistic smart
contract verifications; and how can it be used?  And I think we can zoom in from
there, because I think, at least for me, sometimes these things get jumbled up
and there's a new version every so often, thanks to you guys doing all this
research.  But maybe you can kind of hone in on it for us so we know what we're
looking at.

**Liam Eagen**: Yeah, for sure.  So, as people may know, probably know, Bitcoin
Script is fairly limited in what it's possible to verify.  So, wherein with a
more powerful scripting system, you might be able to sort of directly verify a
zero-knowledge proof on chain, in Bitcoin you cannot.  We don't have
zero-knowledge-proof systems that are simple enough to verify within the
constraints of Bitcoin Script.  So, I would attribute this to sort of BitVM and
Robin Linus introduced this alternative paradigm where instead of having a smart
contract or a script that's verified directly by the L1, you have a kind of
script that's optimistically executed, meaning we assume that it is run
correctly, and then it's possible for another party to provide a fraud proof.
They can prove that the computation was run incorrectly.

So, this kind of asymmetry between the complexity of proving something was run
correctly versus something was run incorrectly opens up a lot of possibilities.
And one style of this is BitVM, and then another one is Glock, or these
garbled-circuit-based protocols.  So, you can prove that something was run
incorrectly more efficiently than you can check it directly.

**Mike Schmidt**: I hear these things in the context of bridges and locking
coins and then unlocking them on some higher layer or sidechain or something.
Is that the sort of canonical use case, or are there other use cases?

**Liam Eagen**: Yeah, I mean in some sense, the bridge use case kind of
encapsulates everything else generically.  You could sort of bridge to any
environment where you could do any subset of things.  Due to the limitations of
the way the tech works now, there are other interesting use cases.  So, in a
bridge, you have to, because of the lack of covenants, use a presigning kind of
federation to sign all of the transactions for the Glock or BitVM game.  But in
other applications, this might not be necessary.  So, for example, if you were
doing a lending protocol and it was just between a designated borrower and
lender, you wouldn't need a separate presigning committee.  You could just have
the borrower and lender co-sign everything themselves.  So, in narrow cases
where all the parties are known in advance, you can do a little bit better than
a bridge security.  But I would say the bridge is sort of the application
everybody has in mind when they're working on this stuff.

**Mike Schmidt**: Okay.  That's helpful for my high-level questions.  Maybe you
want to dig into some of the interesting tech work that you guys have been
working on, or maybe Murch has a question as well.

**Mark Erhardt**: I mean, maybe to put it into context a little further.  So,
generally on Bitcoin, we like to do our smart contracts in a way that we only
prove that they've been run correctly.  We don't compute them onchain.  So,
Glock is one of these approaches where you put out all of the complexity
offchain and you simply can prove that something was run incorrectly.  So, how
much data footprint do we still have?  I saw that it was a huge improvement.
The fraud proof is only a single-signature now, which you described as a 550x
smaller, or previously it was 550x bigger, the fraud proof.  But how big is the
setup?  What's the other part of it?

**Liam Eagen**: Yeah, there's a bunch of different components.  And when you
really start to dig into the system or the schemes, like when you want to make
something, things become more complicated.  But just focusing on Glock, you have
to sort of lamport sign essentially a proof, a SNARK, and you have to provide a
fraud proof.  So, in the case of BitVM, lamport signing the SNARK, you also have
to lamport sign intermediate states of the computation, which is where a lot of
the savings comes from.  And then, in order to provide the fraud proof, you give
this big blob of Bitcoin Script.  So, I don't have the numbers on hand, because
they're a bit sensitive to the precise way you instantiate the scheme.

But you can think of a lamport signature, like we propose in the paper a variant
of lamport signatures that uses adaptor signatures that I think is kind of neat.
And it saves a lot over what people were using previously.  But it's like tens
of kilobytes probably to sign a proof, depending on the specifics, and then you
have a fraud proof, it becomes a signature.  So, you're replacing in that case,
4 MB with 64 bytes.  And if you count all of that, I don't have the calculation
on hand, but then there's a bunch of other additional costs.  So, you have to
presign these transaction graphs, because all of these protocols, Glock or
BitVM, have kind of multi-step games that are carried out between, at least in
games like Glock, it'd be like a garbler and an evaluator, or a prover and a
verifier.  And that cost, yeah, I don't know, I don't have it on hand.  But I
mean, in my opinion, it's manageable, but it's not something you should just
ignore.

**Mark Erhardt**: So, if you're saying that one part is in the tens of kilobytes
and then there's multiple other parts, it's probably on the range of around a
tenth of a block at least to do one of these?

**Liam Eagen**: Yeah.  Okay, I see.  So, the presigning stuff is all offchain.
That doesn't incur onchain costs.  So, I think the question is really about the
bridge, like how much data do you actually put onchain if you're going to do a
bridge.  And this depends, in the case of Glock, on the number of watchtowers
you have.  So, I'll say it like this.  When you make a bridge, you are providing
a proof of something.  So, the proof has two parts, the proof itself and the
public inputs to the proof, meaning what you're making a proof about.  In BitVM,
we can do permissionless challenging for the validity of the proof.  So, the
proof itself we can check, it's just like a syntactic property of the proof.
Whether the public inputs are correct is a more complicated question.  And right
now, the only way we know how to do this is with a permission set of
challengers.  So, in Glock, we have a permission set of challengers for both.
We have a permission set of challengers for the public inputs to the proof, and
we have a permission set of challengers for the proof validity itself.

The total onchain cost scales with the number of what we call watchtowers,
people who are eligible to challenge for the validity of the proof and the
public inputs.  So, I think your estimate is roughly correct.  It's like 100-ish
kB, because we have, let's say, 16 watchtowers and, say, 10-ish kB per
watchtower, because they're each lamport signing a proof.  So, in the worst
case, this would be the onchain costs, because the fraud proof is negligible,
it's just one signature.  But I don't know.  I mean, it's also maybe worth
emphasizing that this is in the so-called unhappy path.  Like, this only happens
in the case that some party is behaving maliciously.  And empirically, this
tends not to be the case with these types of systems.  But yeah.

**Mark Erhardt**: All right.  Sorry for the big tangent.  Did you want to dive
into more details of how it works and whatever Mike asked?

**Liam Eagen**: Oh, sorry, I don't know, I think it's fine.  So, the BitVM2
style of protocol as well as Glock, we make this observation that SNARKs are the
universal verification primitive.  So, it's sufficient to be able to verify a
SNARK to be able to verify anything.  And so, Glock in particular is very, very
tightly coupled with a particular SNARK.  The SNARK that we use is a variant of
this SNARK called Pari.  And our variant is actually smaller than Pari and is
the smallest known SNARK, which is kind of cool, like an interesting theoretical
development.  And so, we have this SNARK and we then instantiate it in what is a
so-called designated verifier paradigm.  So, normal SNARKs can be verified by
anyone, but a designated verifier SNARK can only be verified by a designated
verifier.  Concretely, this means there's some secret information the verifier
has to know in order to verify the SNARK.  And this allows us to get rid of
pairings, which Pari and Groth and the sort of SNARKs people might have heard
of, all require pairings.  Because we can get rid of pairings, we can simplify
the verifier circuit quite a bit.

So, there's a parallel effort by the BitVM Alliance to do a garbled circuit for
Groth.  And this is ongoing, but at the moment is quite a bit larger, like
several orders of magnitude more expensive than Glock, in part because they
require pairings.  And so, we get rid of pairings, and we're also able to use a
different type of curve that is not pairing-friendly, that arithmetizes better
into a kind of garbled circuit.  So, you could kind of imagine by kind of
fiddling with the parameters, we make all the pieces fit together better.  And
by making the pieces fit together better, you have maybe four or five levels of
abstraction.  And so, you save a factor of 10 at each level and it multiplies up
pretty fast.

**Mark Erhardt**: Sorry, to jump in briefly.  You said Grug is the alternative
approach.  I don't think I'm familiar.  Could you maybe elaborate in one or two
sentences what that's about?

**Liam Eagen**: Oh, sure.  Yeah.  So, Jeremy Rubin has this note on Delbrag,
which introduced the garbled circuits kind of paradigm.  And there's this
problem in garbled circuits generally where the garbler, the person who produces
the garbled circuit, might be malicious.  So, I, a malicious garbler, might give
you a malformed garbling table so that when you try to evaluate it, you just
fail.  And in order for the protocol to be secure, you must succeed.  So, we
have to make the protocol maliciously secure.  There are a few ways to do this,
and one of them is Grug.  And the way Grug works is Inside a garbled circuit,
you have a bunch of logic gates.  And if the circuit is malformed, then one of
these gates has to be malformed.  And so Grug uses a sort of Bitcoin Script
basically, in a similar way to BitVM2 to slash for malformed gates.  So, if
there's a bad gate, you can slash for that.  The cost of this is that the
worst-case slashing complexity goes from a single-signature to tens of kilobytes
of Bitcoin Script.  So, like, ideally, we would be able to avoid this.
Unfortunately, previous approaches, it was not feasible to do that.

The other two approaches just worth mentioning for malicious security are
SNARKs, like you can just run a proof that you constructed the garbling table
correctly, but this is too expensive for all of the current approaches.  And
then the other one is called Cut and Choose, which is what we use for Glock.
And the heuristic here is you, the garbler, garble about n times; and then me,
the evaluator, I open half of them.  And if I detect any faults, then you're
cheating; and if I don't detect any faults, then as long as one of the remaining
ones is valid, I can succeed.  So, kind of like you cut a sandwich in half and
then I get to pick your half, or something.

**Mark Erhardt**: Okay, let me try to break it down a little simpler to show
whether I've understood it correctly.  The alternative approach previously did
not depend on a set of watchtowers or otherwise privileged verifier group anyone
would be able to challenge.  You're basically introducing a group that have
privileged information and that is required to verify that the setup was
correct, but that allows you to make it magnitudes more efficient because you
can get rid of pairings, which is a property of elliptic curves -- yeah, I think
it's only elliptic curves, right -- that is not used in Bitcoin usually, and
that has cool properties in some ways, but obviously has other downsides.  Let's
not dive into that more.  Anyway, you get rid of pairings, that makes it much
more efficient, but the trade-off is you require information in order to verify.
So, you have a pre-chosen set of verifiers, which you call watchtowers, and this
makes it much more efficient, and that's pretty cool.

**Liam Eagen**: Yeah.  The one thing I would add, this is like a 'yes and', but
the previous system also requires permissioned watchtowers.  So, because you
need permissioned watchtowers to challenge for the public parameters, concretely
this is because the longest chain rule can't be verified objectively.  You need
somebody to be able to come in and say, "No, I have a heavier chain", right?
The BitVM2 approaches also require this.  So, I would argue that in fact both
systems have permissioned watchtowers.

**Mark Erhardt**: Right.  In the other system, one of the two aspects requires
the pre-chosen verifiers.  You're like, "Well, if we have pre-chosen verifiers
anyway, let's just use it for both".  That way you get rid of pairings and make
it magnitudes more efficient.  I get it.  I think I get it, roughly.

**Mike Schmidt**: Liam, you mentioned there's this new SNARK, this smallest one.
It sounds like there's some novel things going on here.  What has the feedback
been from the community?  And also maybe, what is the process to vet these or
harden these or get more eyes on these?  Maybe talk a little bit about the next
steps after the paper.

**Liam Eagen**: Yeah, I don't know.  I mean, I think I've been pretty happy with
the feedback.  I think people have been nice.  There's a lot of interest, which
is always really fun for this kind of work.  Next steps?  So, we're in the
process of implementing it.  That's important.  The cryptographic work.  I think
there's enough novelty in the paper probably for a conference submission, which
is always good to get peer review.  I think that, well, I don't know.  I mean,
the kind of applied cryptography space for SNARKs and cryptocurrency type stuff
is sort of interesting, because often you get even more eyes on something that
people care about than you would in a conference submission.  But yeah, I think
it doesn't hurt to do both.  So, that's that.  And then, I don't know, I think
of this as a part of a longer chain of work.

**Mark Erhardt**: Right.  If we look at somewhat comparable efforts, MuSig was a
paper first, and then it had an implementation, then there was a bug found in
the paper.  There was a second version of it.  Ultimately, it took several years
to get fully specced out.  It's still being implemented in Bitcoin Core, it's
released in some other Bitcoin clients.  So, if this is in process, and I'm not
saying they're super-comparable, but the timeline is in a similar magnitude,
then this is probably a couple of years away or so from a BIP, or maybe a year
away from a BIP and being implemented.  Is that roughly right?  What would your
gut say?

**Liam Eagen**: I don't know exactly how this would fit into a BIP.  But yeah,
always degrees, right, but fully hardened so to speak, yes, probably at least a
year of continued work.  There are a lot of parts, but they're fairly modular,
which makes it I think a bit easier to analyze.  And, yeah, the implementation,
I mean it's not even done yet.  So, we're going to have the research
implementation and then it'll be like, I don't know, a production quality type
implementation, and then there'll be audits of the implementation and conference
submission of the paper.  And so, yeah, I think that's probably right.  It's
hard to compare these types of things, but that's probably the right order of
magnitude.

**Mark Erhardt**: You say you don't know how it would fit into a BIP.  Why are
you saying that?  Would you say it's not necessary to specify it because it
doesn't require any consensus changes, or do you think it's far enough from
regular Bitcoin Script because it's like tying other systems into Bitcoin, or
what's the connection to it maybe not fitting into a BIP?

**Mike Schmidt**: Keep in mind, this is a BIP maintainer asking this!

**Liam Eagen**: I don't know.  I mean, yeah, I guess I would defer to you.  But
it doesn't touch consensus almost conspicuously, like this whole line of work is
designed to work around, or accommodate the existing consensus structure.  And I
don't know.  I mean, I also personally suspect this is probably not the final
form that this work will take.  It's very, very hot, like it's ongoing.  There
will be more improvements and hopefully they sort of build on each other, but I
don't know.  I'm not sure it's even really ready.

**Mark Erhardt**: Yeah.  I mean, I wasn't expecting you to write a BIP next
week, but anyway, this is maybe still pie-in-the-sky.  All right, I think that's
my questions.  Mike or Bruno, did you have something else?

**Mike Schmidt**: I had something else.  Liam, what is the culture around these
different companies and organizations working on similar things like this?  Is
it cooperative, like are your peer orgs and other -- you're at Alpen, right?
So, are the other companies excited about this and they're going to do their own
version?  What's the IP like here?  Is everybody working together?  Maybe just
give us a little bit of vibe there.

**Liam Eagen**: Yeah, so I would say it's very collaborative.  There's this
organization called the BitVM Alliance, which was working on a collaborative
implementation of BitVM.  Alpen was a part of that, Citrea, a bunch of other
companies in the space, and it still exists.  And prior to Glock, they were
working on this Groth16 implementation of garbled circuits.  But I don't know, I
mean in terms of IP, I'm a very strong believer in permissive intellectual
property for cryptography especially, but things in general.  So, all of this is
like anybody can use it, anybody can work on it, anybody can develop on it, or
trying as much as possible to develop in the open, all open-sourced, as
everything should be.  And will other people use this?  I don't know.  So, this
this also comes down to some sort of complicated trade-off questions, right?
So, I don't know if everybody will use this, but I would like to see that, and I
think there's a lot of interest in it.  But yeah, I would say good vibes all
around.

**Mike Schmidt**: Good to hear.  Liam, we've taken up a good chunk of your time.
We appreciate you joining and explaining this for us and answering our
questions.  Thanks for joining.

**Liam Eagen**: Thank you.

_Update on differential fuzzing of Bitcoin and LN implementations_

**Mike Schmidt**: Jumping back up to the previous news item, "Update on
differential fuzzing of Bitcoin and LN implementations", we have another special
guest who has arrived.  Bruno, can you introduce yourself briefly, and then I'll
introduce your news item?

**Bruno Garcia**: Yeah, I'm Bruno, I am a Bitcoin Core Contributor and I'm the
creator of this project, bitcoinfuzz, that does differential fuzzing of Bitcoin
LN implementations.

**Mike Schmidt**: Awesome.  So, specifically, this news item that we covered
this week was around differential fuzzing across Bitcoin and LN implementations
of the Bitcoin LN Protocol.  You, Bruno, just recently shared some progress on
bitcoinfuzz, and some of the results are impressive.  Over 35 bugs, I think,
were found across things like btcd, Rust Bitcoin, Rust Miniscript, Embit,
Bitcoin Core, Core Lightning (CLN) and LND, if I have those right.  Maybe we can
get into some of those bugs and how they were found, but maybe you can just
remind us, what is this differential fuzzing technique?

**Bruno Garcia**: Differential fuzzing is basically feeding two or more
implementations with the same inputs, and then we can compare the outputs to see
if there's something wrong.  So basically, for example, Bitcoin Core has a
miniscript parser and Rust Miniscript has a miniscript parser, so we can send
the same miniscripts for both implementations and we can compare the outputs,
like for example, if the miniscripts are valid or not valid.  So, if Bitcoin
Core says that a miniscript is valid, and with the same miniscript, Rust's
miniscript says it's not valid, so something's wrong, basically.

**Mike Schmidt**: Okay, that makes sense.  Are you testing, for example, like
Bitcoin Core's RPC against another node implementation RPC, or are you going
right into the code to test it that way?

**Bruno Garcia**: No, we don't test RPC.  Bitcoinfuzz is more source-code level.
So, compared to, for example, Fuzzamoto, Fuzzamoto is more high level.  So, we
run Bitcoin nodes and we call RPC or send P2P messages.  And bitcoinfuzz is more
low level, I would say.  So, basically, it's source-code level; we call a
function from the code of Bitcoin Core, we call a function from Rust Miniscript,
or other implementations using wrappers.

**Mike Schmidt**: And this is distinct.  We've had you on and folks may remember
you or think of you as the mutation-testing guy.  Is this completely separate,
or do you reuse some of the components for each of these approaches?

**Bruno Garcia**: Yeah, mutation testing is completely different from this
approach.  One of the things that I use differential fuzzing with mutation
testing is when I want to know if a mutation is equivalent or not.  So, for
example, I change the code, I create a mutator for a code, then I realize that
it wasn't killed; there's no test that killed that mutant.  So, I have to
understand, if that mutant should be killed, so we have to improve our tests, or
we can ignore it because it's an equivalent mutant.  An equivalent mutant is
basically a mutant that has the same behavior as the original code.  It's one of
the challenges of mutation testing.  And one of the ways that I found to
understand if a mutant is equivalent or not is basically running differential
fuzzing between the original code and the mutant.  So, if I run it for one hour
and I don't find any discrepancy, so okay, it's equivalent.  So, it's a paper
that I work at that basically proved that we can use differential fuzzing for
this.  But there are different parts, by the way.

**Mike Schmidt**: Now, what about different versions, like different versions of
Bitcoin Core?  Do you do differential fuzzing across implementation versions?
And I guess if you can do that, what about between PRs and the code before that
PR, you know, these sorts of things?

**Bruno Garcia**: Yeah, this is great.  We don't do this right now.  I think
Rust Bitcoin does it, if I'm not wrong.  But now, bitcoinfuzz has models, so
Rust Bitcoin, Rust Miniscript, Bitcoin Core, btcd.  And we build these models
based on commits.  So, it's not fixed on a specific release, it's based on
commits.  So, we can build bitcoinfuzz using, for example, based on a specific
PR because I want to test that PR.  But for now, we don't have this or we don't
have an easy way to, for example, test the same implementation, but different
versions.

**Mike Schmidt**: Okay, makes sense.  We referenced some of the accomplishments.
I think we should give you a quick opportunity to do a victory lap and maybe
highlight a couple, like what are a couple of bugs that you found doing this?
Maybe some interesting ones for the audience.

**Bruno Garcia**: Yeah, we found over 35 bugs.  So, for example, we found many
implementations using the incorrect type for the key type value for PSBTs
(Partially Signed Bitcoin Transaction).  This is great, because we realized that
only Bitcoin Core was doing this right.  So, every other implementation was
using the wrong type, not following the BIP.  And we found a CVE vulnerability
on Rust Miniscript, a panic on btcd's PSBT parser, and many other LN bugs.
However, we found many bugs, not because of the differential fuzzing, but only
because of the fuzzing, because many implementations in the ecosystem don't have
fuzz testing.  So, for example, we found a panic on btcd's PSBT parser, or we
found the CVE on Rust Miniscript because of basically fuzzing, not because of
the differential fuzzing.  And so, I wrote in, "The state of Bitcoinfuzz", that
we do differential fuzzing of projects that do not have fuzz testing and we
found bugs with it.  And there are some projects, like Rust Bitcoin and Rust
Miniscript, they have fuzz testing, but this is not enough.  When you have fuzz
testing, we have to run it continuously.  So, if you don't run it, of course,
you won't find any bugs.  So, you can have many targets, but if you don't run
them, of course, you won't find anything.

I started the project basically focused on Bitcoin implementations.  So, I
started basically with Bitcoin Core, btcd, Rust Bitcoin.  But then, Erick and
Morehouse joined the project because they think it's important to have the same
work for LN implementations.  And we found many bugs across different LN
implementations.  And another thing that is funny, it's because doing
differential fuzzing of specific Bitcoin implementations is hard, because we
don't have a specification.  So, when we have a crash, for example, between btcd
and Bitcoin Core, who is wrong?  Who is correct?  So, we have it to investigate.
But in case of LN implementations, we have the BOLTs, so we can basically
compare their behavior.

**Mark Erhardt**: The specification against the behavior, and that they all
match up.  Actually, I have a question about that.  It seems to me that you're
mostly focused on differential fuzzing, but how does this differ from the
fuzzing that, for example, Bitcoin Core does internally?  You said you found a
bunch of bugs on other projects because they're being fuzzed for the first time,
and that's sort of what Bitcoin Core does already with the QA assets.  So, could
you highlight maybe the difference between those two approaches?

**Bruno Garcia**: Yeah, for example, the Bitcoin Core fuzz testing is basically
we use, for example, libFuzzer or AFL.  And bitcoinfuzz is not different, it's
basically libFuzzer.  So, we have a PR to integrate AFL, but it's basically
libFuzzer.  So, it's the same approach of Bitcoin Core, but we have this
comparison between implementations.  But the way we create inputs, the way we
have our corpora it's all similar to Bitcoin Core.  We use libFuzzer and, yeah,
we have some custom mutators, for example, for some LN targets.  But yeah,
Bitcoin Core also has some custom mutators for some targets and, yeah, it's
basically the same approach.

**Mark Erhardt**: So, would you be able to use some of the inputs from Bitcoin
Core on other projects?

**Bruno Garcia**: Yeah.  If the targets are compatible, yeah.  For example, in
the case of miniscript and descriptor parsers, the inputs are basically the
miniscripts for the descriptors.  And I think that 90% of the bugs that I found
for these things were using the corpora from Bitcoin Core.  Because I know that
Bitcoin Core has a well-maintained and completed corpora that we have all the
edge cases for these things.  So, we basically ran, started to run in
bitcoinfuzz using the corpora from Bitcoin Core for these targets, and we found
many bugs with it.

**Mike Schmidt**: I know we had Matt Morehouse on recently and he was quite
adamant about wanting more testing and fuzz testing, specifically in his domain
of LN implementations.  So, it sounds like you're echoing that sentiment as
well.

**Bruno Garcia**: Yeah, I was mentioning that for the Bitcoin protocol, we don't
have a specification.  We have a specification for LN, the BOLTs, but we found
that sometimes the specifications are not clear.  So, we found some bugs that we
analyzed and basically, "Okay, the BOLT doesn't say anything about this specific
case, so I have to improve the specification".  So, this is great because of
course we find bugs that implementations should fix, but we also find things
that we know that the specification should be improved.

**Mark Erhardt**: Wait, so you can fix bugs by fixing the specification?  You
don't have to answer that!  But yes, obviously, sometimes things are
under-specified, and sometimes the code is buggy.  This is a meta comment.

**Bruno Garcia**: For example, we have to update a BIP because we have a target
for the addrv2, and we realized that we got a crash between Bitcoin Core and
Rust Bitcoin because Bitcoin Core deleted support for Torv2, but Rust Bitcoin
was skipping support for Torv2.  If you see the BIP, BIP has many things about
Torv2.  Okay, there is a specification about the field, and whatever, but Torv2
is basically not used anymore.  So, should we delete from the BIP?  Should we
mark it as not used anymore?  But then I opened a PR on Rust Bitcoin removing
the support for Torv2 and, yeah, that's fine.  It's another example.

**Mike Schmidt**: A couple of calls to action here that I can think about.  One
is actually from the newsletter write-up itself saying, "Developers of Bitcoin
projects are encouraged to investigate making their software a supported target
for bitcoinfuzz".  So, that's my first call to action for the audience.  My
second one is, and maybe, Bruno, you can elaborate on this, the collective of
you and others that are working on Bitcoin fuzz and related projects, I assume
you're looking for contributors and maybe people to run some of this or adding
testing targets in specific libraries, things like that.  If that's true, maybe
you can elaborate on that, so some of our tech enthusiasts, listeners who want
to contribute in some way can maybe take a look at this?

**Bruno Garcia**: Yeah, we need more contributors because bitcoinfuzz is a huge
project.  And for example, we integrate projects with different programming
languages.  So, of course, I'm not an expert on C++ and Rust and Python and
Kotlin, but we have to deal with these languages.  So, more reviewers would be
great.  And we need to improve our build system, the way we build the models.
We have some conflicts and we should improve it.  So, if people want to
contribute on this thing, it would be very valuable.  And we need more targets
and more people running it.

**Mike Schmidt**: Bruno, anything else you'd say in closing?

**Bruno Garcia**: No, it's fine.  Thank you.  Thanks for having me.

**Mike Schmidt**: All right.  Thank you for your time, Bruno.

**Bruno Garcia**: Thank you.

_Is it possible to recover a private key from an aggregate public key under strong assumptions?_

**Mike Schmidt**: Moving to our monthly segment on the Bitcoin Stack Exchange.
First question, "Is it possible to recover a private key from an aggregate
public key under strong assumptions?"  Pieter Wuille answered this.  He answered
it briefly and then went on to explain a bit.  But he said, "Yes, absolutely".
Go ahead, Murch.

**Mark Erhardt**: I think it's important to explain what he said 'of course' to.
So, the base assumption of the asker here is, if we can calculate private keys
from public keys, is MuSig in any way more secure than a single public key to a
private key relationship?  And to that, Pieter says, "No, of course not.  If you
can calculate private keys from public keys, you can calculate the private key
from the aggregate public key".  So, I think it's important to understand that
the strong assumption here is secp256k1 is already insecure, and then MuSig2 is
also broken.

**Mike Schmidt**: Yeah, I had a quote from him as well that I saw him hint at,
and then get explicitly at the end of his answer on the Stack Exchange question,
which is, "If you are concerned about the security of secp256k1 for whatever
reason, you shouldn't use it at all.  No multisignature scheme, aggregated or
not, is going to save you if the cryptography beneath it all is broken".

**Mark Erhardt**: Well done.  Sorry for jumping in so quickly!

_Are all taproot addresses vulnerable to quantum computing?_

**Mike Schmidt**: No, I appreciate that.  Next question, "Are taproot addresses
vulnerable to quantum computing?"  So, Hugo, you and Murch highlighted answers
here that even if a scriptpath-only taproot output exists, they aren't quantum
safe, partially because there's no such thing as a scriptpath-only spending
option in taproot.  There's always a keypath, even if you don't know the private
key to spend it.  Is that correct so far, Murch, and then we can get into the
wrinkle?

**Mark Erhardt**: Yeah, let me jump in right away.  So, the construction of
taproot allows two ways of spending.  One is by keypath, which basically means I
know the private key directly with which I can sign, and therefore I just
provide a signature that corresponds to the internal public key that is tweaked
with the merkle root of the script tree.  Sorry, I'll say that again.  You just
sign with the key that you've basically committed to and that works.  That's the
single-sig case or also the MuSig case, when multiple people together have an
aggregate public key.  In the scriptpath case, you show, "Hey, wait, there's
more here than just the public key that I committed to.  Let me show that there
is a script tree here.  I'll show you the path to the leaf, I'll show you the
leaf and then I satisfy the conditions that are encoded in the script leaf".
And now, there might be cases in which you want to make it impossible to use the
keypath.  Like, if there's only complex conditions under which a UTXO should be
spent, you would use a point that there is no known relationship to.  And this
is called a NUMS point or nothing-up-my-sleeve point.  So, if you use a NUMS
point, it can only be spent by scriptpath by you.

But now, someone has a quantum computer and can do exactly what we were talking
about in the last question: find the private key from a public key.  There is a
private key to the tweaked public key that was derived from the NUMS point.
Even if there's no private key to the NUMS point itself, the tweaked key does
have one.  Even if you don't know it, it can be calculated, and then you can
make a signature and spend from that UTXO.  So, the funny thing here is if
someone created an output with a NUMS point, which by them is only spendable by
using the scriptpath and revealing a leaf and satisfying that leaf's conditions,
if another person uses a quantum computer to quantum decrypt a private key from
the public key and then signs with that, makes a keypath spend from this output
that is thought to be only scriptpath spendable, then the person that created
the output in the first place can prove that a quantum description happened,
because they can show that the output was originally built with the NUMS key
under the hood.  So, that's the interesting part there.

**Mike Schmidt**: Yeah.  That was the interesting wrinkle that I think it was
you, Murch, in the answer had pointed out.  So, we can get proof of quantum
computing if they choose to point it at some such output.

_Why cant we set the chainstate obfuscation key? _

"Why can't we set the chainstate obfuscation key?"  Ava Chow explained that the
blocksdir obfuscation key and chainstate obfuscation are separate.  And I
believe that the blocksdir key is configurable, Murch, but the chainstate one is
derived and thus not configurable.  Am I right so far, and then I have probably
a few more questions for you after that?

**Mark Erhardt**: The blocksdir obfuscation was added much more recently, so
maybe someone built it with that together.  But the chainstate obfuscation is PR
#6650, which sounds like ten years ago, roughly, or so.  Maybe not ten years,
but very old.  2015, exactly ten years, actually.  September 7th, 2015.  Yeah,
so presumably when people did a similar thing now, they just thought a little
more holistically about it then.  And sorry, what was your question?

**Mike Schmidt**: Oh, well, one of them was the mempool can also be persisted to
disk, right?  And it also has obfuscation as well.  Is that correct?

**Mark Erhardt**: Possibly.  I'm not sure, actually.

**Mike Schmidt**: Okay, we'll dog ear that for our listeners to do their own
homework.  There's been a lot of talk of obfuscation these last few days.  I
think, Murch, if I have it right, the idea is that with OP_RETURN limits being
relaxed at the policy layer, that it could be abused to put in illegal content,
or some such thing, and that the fact that it would be an OP_RETURN would mean
that it could be contiguous and potentially not interrupted with separators,
like data push things, and therefore it is more likely to be targeted by either
antivirus or law enforcement.  Am I getting the gist of that concern that is on
social media?  And then, if not, correct me and then maybe we can talk about if
that is true, or the response.

**Mark Erhardt**: So, the software we're using does not actually read data as
any other format than just script.  So, if someone else puts in data blobs, yes,
they would be in the blockchain and potentially, something that looks for a
specific sequence of bytes would not see them in the obfuscated blocks data,
because basically what we do is we create a byte pattern and then we XOR the
entire block content with that.  So, basically we encrypt it with a very weak
encryption that is just switching around some of the bytes.  And then, when you
read the blocks again, your software knows where to find the key, which is
stored in a specific location in the Bitcoin directory itself, and then just
applies this mask back on.  And then, in memory, you can read it and process it.
But Bitcoin Core itself doesn't interpret the content of inscriptions or
OP_RETURNS.  It wouldn't read out the text of the Genesis block to you.  You
have to apply second-hand processing in order to get this sort of data out of
the blockchain.

So, we already have a bunch of illegal content in the blockchain.  This has been
a problem before.  I believe that it has been previously rejected.  Essentially,
there's no way to filter for all of this sort of stuff, because you don't know
what someone might want to put in, so you can't write a filter that searches for
it and rejects it.  And therefore, it being committed to by the blockchain and
maybe buried a few blocks already before anyone notices what's in there, it
seems I just don't think that there's a legal case here.  It seems absurd to me.
And I don't think that there's a huge difference between it being stored in
OP_RETURN in a complex data encoding that we don't interpret on the Bitcoin
level versus it being stored in an inscription where it's encoded in a complex
format that is stored in 520-byte chunks.  There's just, I don't think there's a
big distinction here.  Either way, this is not data that Bitcoin uses.  And if
someone else wants to get that data out and do something with them, that's
another story.

**Mike Schmidt**: So, similar to the discussions we've had before about people
can come up with whatever scheme they want to embed data into Bitcoin, and then
it's on this sort of separate software, like client software, like whatever the
ordinals or inscription software is, to know what the scheme is and then pull
that data out and stitch it together, and then somehow know that it's a JPEG and
then it's a JPEG file.  That all had existed, exists today, and that all that's
changing is that maybe someone's going to come up with a new scheme using
OP_RETURN, which will also require software to find those bytes, organize those
bytes, interpret those bytes into whatever scheme that person is using, right?
So, it seems like it's a different scheme, but it's the exact same thing that
we've dealt with previously, right?  Am I interpreting that right?

**Mark Erhardt**: Well, exact same?  People might disagree on absolutes here,
but it is negligibly different, in my opinion.

_Is it possible to revoke a spending branch after a block height?_

**Mike Schmidt**: All right.  I think we covered that one pretty good.  Hot news
topic.  Next question, "Is it possible to revoke a spending branch after a
certain block height?"  And Antoine answered this pointing out that inverse time
lots, which are spending conditions that can be revoked based on the height of
the blockchain, aren't something that's feasible with Bitcoin's current design.
And he goes on to note that maybe that's a good thing that that feature is not
available.  Murch, what is the canonical reason that that could be a bad thing
to have spending conditions revoked?

**Mark Erhardt**: Imagine a transaction that decides the fate of tens of
thousands of bitcoin being locked to expire at a specific block height, and then
it is included exactly one block before it's no longer includable.  Suddenly, a
reorg has a huge financial incentive to happen.  So, there's just been a
longstanding approach that people do not want transactions to become invalid
after they have been valid.  We do have transactions that are only valid after a
specific point, like timelocks, but the opposite introduces some different
scenarios and game theory that make it kind of iffy.

_Configure Bitcoin Core to use onion nodes in addition to IPv4 and IPv6 nodes?_

**Mike Schmidt**: "How to configure Bitcoin Core for onion nodes beyond IPv4 or
IPv6?"  Pieter Wuille answered this one as well, clarifying that that onion
config option only affects outbound connections, and that inbound Tor setup
would still require your node to be reachable over Tor.  And he goes on to point
out how you might do that as well.

**Mark Erhardt**: I think basically what you would do on Linux is you install
Tor, and then when you run Bitcoin, it automatically does the things you expect
it to do.

_Bitcoin Core 29.1rc2_

**Mike Schmidt**: Releases.  We have Bitcoin Core 29.1rc2, which is a new RC for
Bitcoin Core.  This is out and ready for testing.  If you're running Bitcoin
Core, now would be a great time to test for any regressions or test with your
deployment scripts and provide any feedback to the team.  Didn't have anything
else to add there, Murch.  I think we sort of talked about some of the items
that were in the first RC a couple times.  I don't know if there's anything new.

**Mark Erhardt**: Well, due to the public interest, I think it's fair to say
again, because of the latency that we see in block propagation ever since
minrelayfee filters have apparently not been broadly enforced anymore, the 29.1
release will backport the mempool policy change regarding minrelaytxfee and
incrementalrelaytxfee.  So, if this is a very important topic to you, upgrading
from 29.0 to 29.1, by default, your minimum relay transaction feerate will be
reduced by a factor 10 to 0.1 sat/vB (satoshi per vbyte).  So, if this is the
sort of thing that keeps you awake at night, if you want to upgrade, you totally
can upgrade, but you might want to configure your minrelaytxfee to your
preferred amount because the default changed, or will change when it's released.
Also, if you run on a 32-bit system, which I don't know if there's that many
around still, and you were playing around with your maxmempool and dbcache, they
are now capped because if you set it to high, it'll actually not work on a
32-bit system.  And that was the interesting ones I think that I saw.

There's a bunch of bug fixes.  There's usually no new features.  Well, there are
no new features in point releases, but in this case, there is a policy change
due to the issues that the policy was creating on the network.

_Core Lightning v25.09rc4_

**Mike Schmidt**: Core Lightning v25.09rc4.  I actually noticed a few hours ago
the release for this RC was published, so you can not just download the RC, but
the full version.  CLN now includes bookkeeper in CLN itself.  I believe that
was a plugin previously; xpay can now pay BIP353 human-readable Bitcoin payment
instructions; there is that log viewer tool that we covered previously, which I
think was a web-based tool to interact with the logs a little bit more
user-friendly way; there's improvements to package management; there are
splicing improvements and better interop with splicing with Eclair; and there's
other features and improvements.  Please check out the release notes if you're a
CLN user.

_Bitcoin Core #31802_

Notable code and documentation changes, Bitcoin Core #31802, which adds
bitcoin-node and bitcoin-gui to release binaries for IPC.  Murch, this seems
like a big one.  What's going on here?

**Mark Erhardt**: So, we've talked before about the multiprocess project, which
has been going on for a very long time.  And we've also been talking about
Stratum v2, of course, which will hopefully help miners that participate in
mining pools build their own template locally, and then work on that template
locally, and only prove to the mining pool operator that they're doing useful
work, rather than following the template of the mining pool operator.  So, Sjors
has been working on this for I think a couple of years now to put support for
Stratum v2 into Bitcoin Core.  This entails that we need to be able to build
block templates in Bitcoin Core and update the provided template frequently.
Originally, he was trying to put Stratum v2 support directly into Bitcoin Core,
but that was a very large code change that people felt was maybe a little too
big for a feature that only a small portion of the users would be using.  So,
the approach changed over time a little bit to make it into an interface, where
the mining information can be got and then a sidecar that translates it to the
Stratum v2 format.

So, this has been out as a concept proof I think for a while.  And one of the
big concerns that people trying to implement Stratum v2 support on their end had
was that essentially they're running Sjors' private, one-developer release with
the Stratum v2 support, and it would be much nicer if they could instead run
vanilla Bitcoin Core with a command line option or something to get that
instead.  So, what this code change does is it enables a CMake option, called
ENABLE_IPC, by default, which means if you build Bitcoin Core, it will create
the two binaries, bitcoin-node and bitcoin-gui, which are the multiprocess
binaries.  And these binaries talk to each other using something called the
inter-process communication, IPC.  It will also then support this mining IPC
that the sidecar of Sjors is using.

This was merged a couple of weeks ago.  This is before the feature freeze, so it
will be in the 30.0 release.  And what it will allow is that the people that are
working on implementing Stratum v2 on their end will be able to run the Bitcoin
Core binary and work against that, instead of Sjors' private branch.  And I
think that's it.

**Mike Schmidt**: Murch, was this Stratum integration not possible with
something like the existing RPCs or other ways to interact with Bitcoin Core
previously?  Or it was possible, but this is a more performant way to do it?

**Mark Erhardt**: I think the biggest difference is that RPCs are only when you
pull data, like you call it as the data receiver.  You ask the node, "Give me
that data", and then it gives you the data back.  With the IPC, you can have
push notifications.  So, for example, the node in this case could be set up to
build a new block template every 30 seconds, and to automatically push that data
out to the mining IPC.  And then, the sidecar would update the Stratum v2
template and push that out to the mining operation.

**Mike Schmidt**: Okay, that makes sense.  One more follow-up question.  So,
this will be in the v30 release.  Are these binaries in any way experimental, or
are there asterisks by these binaries in any way, or are these considered
production-ready?

**Mark Erhardt**: Please don't nail me down on this.  I think that they are
considered pretty mature.  They've been tested a lot.  So, usually we like to
merge features early in the release cycle.  In this case, the request came
specifically from the people working on Stratum v2, that they would prefer to
work against Bitcoin Core directly.  You could have run with the multiprocess
way of building the binaries before, but now, in addition to the regular way the
binary is built with bitcoind, It is now built as two separate binaries too that
can run in their own processes.  So, by default, you're not going to use this
unless you opt in.  You don't have to change anything about your setup unless
you're specifically interested in this IPC stuff.  If you want to help testing
with multiprocess, I'm sure that the people working on multiprocess would
appreciate that a lot.  So, yeah, I would actually have to go back to my notes
and the description of the multiprocess overview to double-down on exactly how
ready this is and everything, but I think it's basically fine to use.  Maybe
don't hook up your several-billion-dollar company to it yet, but you know.

**Mike Schmidt**: Okay.  Yeah, that makes sense, Murch.  Didn't mean to put you
on the spot there.  I was just curious.

_LDK #3979_

We can move to LDK #3979, which adds splice-out support for LDK.  So, in
Lightning, you can now add funds to an existing channel that would be via a
splice-in, and this was in LDK in their main branch as of last month.  But with
this PR this week, LDK users are able to splice funds out of a channel.  For
example, if they want those funds onchain for another purpose, this is part of
LDK's dual-funded channel and splicing project, tracking issue #1621 on the LDK
repository, if you want to follow along.  I think in the newsletter, we put that
this wraps up their support for splicing.  There are other items on that
dual-funded channels and splicing project tracking.  There are some items that
look like they're still remaining.  If you're curious about this kind of
low-level stuff, check out that #1621 tracking issue.  Murch, do you know, I
don't know, can I splice-out of one channel and into an existing channel with
the current tooling all at once, do you know?

**Mark Erhardt**: I think that Phoenix can do that.  I'm not sure if LDK can
yet.  That was definitely something that the Lightning developers talked about.

**Mike Schmidt**: That seems like for these LSPs and other Lightning liquidity
folks to be a killer feature.  So, I assume it's coming if it's not here
already.

_LND #10102_

LND #10102 titled, "Catch bad gossip peer and fix UpdatesInHorizon".  This PR to
LND makes two changes.  One is it starts recording bad peers when they make
invalid channel update announcements, and there is a scoring and threshold
system now in place for that.  And the second thing is that it also updates LND,
some of their internals to be more robust around handling invalid announcements.
These changes follow on some other recent PRs to LND that we've covered around
LND's effort to, I'll use the word 'fortify', fortify their handling of gossip
to be more resilient.

_Rust Bitcoin #4907_

Last PR this week, Rust Bitcoin #4907, which introduces script tagging.  And if
I'm understanding this correctly, Rust Bitcoin previously had a generic script,
I'll use the word 'data type'.  And after this PR, Rust Bitcoin has types for
different types of scripts.  So, instead of just that generic script, they've
pulled out things into categories of scripts, including ScriptPubKey, ScriptSig,
RedeemScript, WitnessScript, and TapScript.  So, you can imagine stronger script
typing that can be useful in Rust Bitcoin or client software using Rust Bitcoin
to have these more specific data types, and potentially there's even
restrictions on their usage in different parts of the codebase.

Well, that's it.  We want to thank our guests for joining for the news segment,
Bruno and Liam, this week.  And I want to thank Murch for co-hosting as always,
and for you all for listening.  Cheers.

**Mark Erhardt**: Cheers.

{% include references.md %}
