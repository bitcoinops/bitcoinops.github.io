---
title: 'Bitcoin Optech Newsletter #365 Recap Podcast'
permalink: /en/podcast/2025/08/05/
reference: /en/newsletters/2025/08/01/
name: 2025-08-05-recap
slug: 2025-08-05-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by David Gumberg, Lauren
Shareshian, Jameson Lopp, Steven Roose, and Tim Ruffing to discuss [Newsletter #365]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-7-6/405222600-44100-2-baed90fd0025c.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #365 Recap.
Today, we're going to talk about research into compact block performance, fee
estimation using just the mempool, and we have our monthly segment on Changing
consensus that is going to cover a couple of quantum discussions, the idea of
longer timelocks, and the OP_TEMPLATEHASH proposal.  Murch and I are joined this
week by David Gumberg.  David, you want to introduce yourself?

**David Gumberg**: Hi, I'm David Gumberg, I work at Localhost Research on
Bitcoin Core.

**Mike Schmidt**: Jameson?

**Jameson Lopp**: Hi, I do Bitcoin stuff.

**Mike Schmidt**: You're on the right podcast then.  Steven?

**Steven Roose**: Hi, I'm Steven Roose, I'm building Ark at Second.

**Mike Schmidt**: Tim?

**Tim Ruffing**: Hi, I'm an applied cryptographer at Blockstream, working on all
kinds of cryptography stuff in Bitcoin.

_Taproot-native `OP_TEMPLATEHASH` proposal_

**Mike Schmidt**: Great of you all to join us, thank you for your time.  If
you're following along with the newsletter at home, we're going to go a little
bit out of order in deference to our guests in different time zones.  So, we're
going to jump into the Changing consensus segment, and we're going to talk
about, "Taproot-native OP_TEMPLATEHASH proposal".  Greg Sanders posted to the
Bitcoin-Dev mailing list about a software proposal he's been working on with
Antoine Poinsot and Steven Roose.  Steven's joined us today to explain the
proposal.  Steven, at first glance this looks like the CTV
(OP_CHECKTEMPLATEVERIFY) and CSFS (OP_CHECKSIGFROMSTACK) proposal that's been
batted around recently, but with OP_INTERNALKAY added.  Or similarly, the
LNHANCE proposal with the OP_PAIR commit removed.  Is that an oversimplification
and maybe we can get into some of the deltas?

**Steven Roose**: I think that's more or less correct, yes.  Yeah, you can go
ahead if you want to give more intro, or I can go.

**Mike Schmidt**: No, I think that's good.  I mean, that's just how I see some
of the discussions at a high level going, but I think maybe you can help educate
us on why a variant of both of those is maybe the preferred route in your
opinion.

**Steven Roose**: Yeah.  So, I think it boils down to two major motivations.
One of them was that we wanted to limit the effect that future soft forks have
on legacy scripting capabilities, and we wanted to limit all our functionality
to just the tapscript context, which has already some other issues resolved that
the other script contexts would have.  So, then the OP_TEMPLATEHASH opcode would
only work in the tapscript context, just as the other ones that we're proposing.
And instead of checking a hash, which is what you only can do if you're
replacing an OP_NOP, we can actually directly put the template hash on the
stack, which then comes to the second motivation, making it a lot more efficient
to do re-bindable signatures.  So, re-bindable signatures originally come from
the APO, or ANYPREVOUT proposal, and you can do re-bindable signatures using CTV
and CSFS directly, but you would have to post a public key on the stack and you
would have to post a CTV hash on the stack, or in your witness, which would cost
you something like 66 bytes.

So, with this change proposal, you don't have to put those things on the stack,
you don't have to provide them in the witness, but you can get them on the stack
directly from the script.  So, you can get your internal key, which saves you 33
bytes, and you can get your template hash, which saves you 33 bytes.  So, I
think that's the in-a-nutshell summary of the improvements that we're trying to
make, mostly based on feedback from talking with various people over the last
few months.

**Mike Schmidt**: For that first motivation, Steven, is the reason to not have
it in multiple script context just a maintenance thing, or help us understand
why only in tapscript?

**Steven Roose**: Well, I mean first of all, it helps us have INTERNALKEY and
TEMPLATEHASH, right, which otherwise we wouldn't have; but also, the other
script contexts are kind of a lot harder to reason about because they have very
weird limitations on how you can abuse things in weird ways, while the tapscript
context already has like a lot more sanity limitations put in place.  Segwit
also has more than legacies, so we've been improving over time and extending the
things you can do with this legacy context just opens up a whole, like, giant
review surface of how this can be exploited, given the low limitations or
constraints that these contexts already have.  So, I think the tendency that
we're trying to do, also with the consensus cleanup, is to even further limit
those legacy contexts just to prevent abuse.  Of course, we cannot deprecate
them because people are still using them, but we want to keep supporting the
legacy, like the actual use cases of this context, but then restrain people that
can potentially use them for abusing validation time of nodes, and stuff like
that.

So, just limiting the scope to tapscript makes it a lot easier to reason about,
like this is exactly what you can do.  This is the context that everyone's kind
of thinking and reasoning about lately, and then we don't have to go back in
time and say like, "Oh, yeah, but in this context, we don't have this
limitation", so, then maybe we can do stuff like this.  I think that's mostly
the motivation.  Also, we shouldn't be providing motivations for people to go
again, use the old context, right?  Tapscript should be the most modern version
of Bitcoin Script and it should be what people should be using for building
their applications on Bitcoin.  If there's issues with taproot and things that
people want to have from the previous context, maybe we should think about that
and then maybe iterate and improve further.

**Mike Schmidt**: Well, what is lost by removing it from legacy script?  I
think, was there some discussion of the congestion control idea being less
efficient?  Is that the main thing?

**Steven Roose**: Yeah, so there's two things.  One thing is the congestion
control thing.  I spent an entire conference asking people if they could come up
with good reasons to have congestion control, or to have bare CTV basically, and
the only reason was congestion control.  And I haven't really felt much
enthusiasm around the congestion-control idea.  I don't think it will be very
useful.  It's still possible to do with this latest proposal, but it's just
going to be a little bit more costly.  But I don't really see why application
developers would want to use congestion control.  The second thing that you can
do is this weird trick that the BitVM people figured out, using some weird
convoluted hack with the scriptSig and P2SH, to somehow commit a certain piece
of scriptSig into your template hash, or to commit to certain inputs by
committing to the scriptSig that it's going to have to put into the input, so
that one of the BitVM transactions can actually commit to the input that's going
to be used alongside.  Yeah, I mean I would prefer not to motivate that
specifically, but it's a very ugly trick that they came up with.  They were
definitely not using the opcodes the way that they were intended to.

So, obviously input commitments are useful and we should do them in a way that
is meant for them and not find some weird ugly hack, because scriptSigs are
something that shouldn't be used anymore and are obviously deprecated in
tapscript context.

**Jameson Lopp**: You're saying we shouldn't be tricking the nodes?

**Steven Roose**: Exactly.  So, I mean it's not like we kicked this out, it's
just that scriptSigs are just not allowed in tapscript context.  So, if you're
using this -- well, no, I mean in theory you could have a scriptSig on the other
one, but we're just not committing to them.  Yeah, no further comment, I guess.

**Mike Schmidt**: I think this proposal commits to the taproot annex, which CTV
does not.

**Steven Roose**: Oh, yes.

**Mike Schmidt**: What are the implications of that?

**Steven Roose**: Yeah, that's a good other thing that I forgot to mention.  So,
we're also committing to the annex.  Basically, because we went back to the
drawing boards with a new opcode, we could just revisit what CTV was committing
to.  And we also considered, for example, the input amounts.  But there's some
problems with that that could make funds get black-holed if you do something
silly or something not entirely correct, and there doesn't seem to be much
benefit for the annex, yeah.  So, the annex is a new thing that was introduced
with Taproot, and it doesn't really have any use cases yet, other than putting
JPEGs.  But since all the current tapscript signature hashes are committing to
the annex, it seems like the purpose of the annex in the future will be that it
should be for data that should be committed in some way, because everything else
is also committing to it.  So, then it seems logical that any committing to a
next transaction scheme or any re-bindable signature scheme would also commit to
the annex so that it's compatible with any future upgrade that we will give, or
any future meaning we will give to the annex.

I think some people are using the annex for proof of concepts of LN-Symmetry,
where they're putting some extra data, and I think for that it would be
beneficial if it was committed as well.

**Mark Erhardt**: Have you gotten any feedback from the prior CTV proponents?
How is it going over?

**Steven Roose**: Well, my memory is failing me for most of what's happening on
the mailing-list thread.  I think most of the feedback was, "Well, but CTV could
do the same thing".  But I guess the responses were not saying that the things
that were proposed until now were not useful, we're just trying to incrementally
improve them a little bit.  I think most of the feedback was kind of normal and
as we expected, like, "This is just a better version.  Let's just keep
improving".  We also -- well, I'm saying we; Greg and Antoine did a lot of work
in doing the test, like a lot of functional tests in the Bitcoin framework to
see the interactions of the different pieces that are committed.  So, yeah, I
think the work is being continued.  We're talking with some people to change the
LN-Symmetry proof of concepts to using this proposal.  I'm currently quite busy
with trying to ship our Ark implementation for mainnet, but we're also thinking
of doing a proof of concept of one of those new Ark designs, like hArk and Erk,
using this proposal.  So, yeah, I think the work is just continuing, reviewing
the latest and trying to see how it can be used in applications.

**Mike Schmidt**: Steven, anything else on this item before we wrap up?

**Steven Roose**: I don't think so.

**Mike Schmidt**: Okay.  Oh, Murch has something.

**Mark Erhardt**: Actually, so we talked a little bit about how having native
CTV would have allowed congestion control.  I think that there was also a
proposal of introducing a new output type, like a native CTV, if that was really
desired.  So, that would get the efficiency that adding it to legacy would have
done, is that right, or what is the idea there?

**Steven Roose**: Yeah, we pondered the idea of having an additional output type
that does direct CTV, but we were ourselves not convinced that it was useful.
But I think we wrote some kind of draft BIP how it could be designed, and then
we just put it out there and said, "If people think this is very useful, people
really want this, they should provide some motivation and really support for why
we should have it", but ourselves, we're not convinced.

**Mike Schmidt**: All right.  Well, if you're interested in the proposal, check
out the mailing-list discussion.  There's been a good amount of back and forth,
including Rearden Code, who was a champion of LNHANCE, which has had some
similarities, saying good things about this proposal.  So, opine on that so we
can move along or not accordingly.  And we'll move along.

_Proposal to allow longer relative timelocks_

Steven, we have another item that you had commented on that we don't have a
guest for titled, "Proposal to allow longer relative timelocks", and this was
based on a Delving Post by user Pyth, suggesting that that BIP68 relative
timelocks could be extended from what they are today, with a max of about a
year, to a new maximum of about ten years.  Pyth mentioned that the motivation
for his post was feedback that he saw from Liana Wallet users, that were
wondering why the limit exists and saying that they wanted longer limits.  And
if I understand correctly, Liana has sort of a degrading multisig approach to
their wallets, which can allow things like inheritance.  But I think also, that
means you need to roll the coins over periodically.  So, I think that's probably
some of the pushback from that particular user base.  I think Blockstream does
something similar with the federation funds as well.  Go ahead, Murch.

**Mark Erhardt**: Yeah, so I think what they do is that the user with the
service can spend it immediately, but then when the user loses access to some of
their keys, there is a fallback with fewer of the user keys and the service to
recover.  And then, there's a long-term recovery, where only the service can
recover it in case the user loses access to all of their key material.  And I
think especially that last one would be interesting to push out further than one
year.

**Jameson Lopp**: Yeah.  I mean, I have a lot of thoughts on this because I want
to say I started talking about the issues of practical implementation of
timelocks in 2020.  I gave a talk at MIT, specifically entitled, "The problems
of non-deterministic data in Bitcoin Script and all of the follow-on effects of
that".  What that was really getting at though is that you have two different
forms of timelocks, if we're about actually preventing money from being spent
until certain conditions or a certain time has passed.  You've got your absolute
timelocks, where you put an actual timestamp or block height, and there's really
no limitations to that.  You could timelock your coins to a block height that's
100 years in the future, though I would recommend against doing that for a
variety of reasons; or the relative timelock, which basically says, "Okay,
whatever block height at which this UTXO was created, you cannot spend it until
so many other blocks have gone past", and I think that it's roughly 18 months,
is the current max of relative timelocks.

So, the downside of using an absolute timelock is that you essentially break
having a deterministic wallet.  And what I mean from that is you're putting some
number into your descriptor for your wallet.  And that's all fine and well until
you want to change whatever that lock is.  You essentially have to create a
whole other logical wallet, which will have a different wallet descriptor, and
this starts making backing up your wallets more onerous.  It starts hearkening
us back to the days when we would have to regularly back up our wallets.  So, if
you were changing your locktime every so often to push it out further, that
would become a problem.  But then, the flip side is with these relative
timelocks, as you said, you have to start churning the UTXOs whenever that
happens.

The problem with both of these is that it basically makes the wallet more
interactive from the user perspective.  On one side, it's more interactive
because you have to start backing it up more; on the other side, it's more
interactive because you have to start rolling your UTXOs.  Now, I think that we
should allow more than 18-month timelocks, but I do think that going beyond
probably 5 to 10 years is when things get dicey.  And this actually kind of
rolls into what we'll talk about later with quantum computing, or just general
existential threats to the ecosystem that might require people to move their
money faster than that.

**Tim Ruffing**: I wonder why this limit was introduced or is even there.  I
mean, I have no idea, but does anyone know?

**Jameson Lopp**: I think the limit has to be with how many bytes are being
used, right?

**Steven Roose**: Okay, yeah.  It's just because you can't express the number
in…

**Tim Ruffing**: Yeah.  I think it's a purely technical limitation.

**Mark Erhardt**: Yeah.  It's 65,575, or whatever.

**Tim Ruffing**: Yeah, okay.  I tend to agree that 18 months is not a lot.

**Mike Schmidt**: But really, it just came down to how many bits of the end
sequence were going to be hijacked for this purpose, I guess.

**Steven Roose**: Yeah, exactly.

**Mike Schmidt**: Steven, what were your comments on the Delving thread?  What
are your thoughts on this?

**Steven Roose**: I think the proposal was actually very well put out.  So, the
way the nSequence field works is, so what you do when you express a relative
timelock is you add a certain value to your input.  And then, that value will
express how much time needs to have passed since the coin that you're spending
has existed, has been created.  And currently, we allocated the first 16 bits, I
think, to be an indicator of how the other 16 bits should be interpreted.  And
then, the only mod that we actually created for that was that the other 16 bits
would be created, it would be number of blocks or a timestamp, something like
that.  So, that that made the limitation to be the 16 bits.  And what the
proposal just proposed is to use another of the bits in the first 16 to
indicate, use the last 16 bits but multiply it with 8 so that you only have a
granularity of 8, so you can only do 8, 16, 32, stuff like that.  But then you
can go 8 times as far.

So, the design is very simple.  It's very similar to how the relative timelock
works right now, it's just that if a user specifies a certain amount of years,
you will just have to round instead of to a block, which is 10 minutes to 8
blocks, which is 80 minutes.  And the questions are there, like what multipliers
should we use?  Obviously, multipliers of powers of 2 are cheaper or easier to
implement, so he could have chosen 4, 8, 16.  I think 8 is kind of a sweet spot
where we get to around 10 years, slightly over 10 years.  It could have been 20
years if we doubled it again.  Another technical question that I mentioned was
if you just say that in the new scheme, you multiply by 8, in the old scheme,
you just multiply by 1, you just take the normal number.  That means that for
all the multiples of 8 within the first year, you have two different options to
represent the new timelock, right?  You can either use the old version or the
new version.

So, one way to avoid this ambiguity is to just only allow the longer scheme
beyond the first 18 months.  So, then we could actually go to 11 or 12 years.
But his argument against this approach was that if you do it like this, both of
the two schemes have to coexist still in all our code bases, otherwise we could
just deprecate or totally forget about the old scheme and only use the new
scheme.  So, there's arguments on both sides, I don't really have a strong
opinion there.  But yeah, I think the proposal was fairly straightforward and
clean, and I think it makes total sense.  I don't think there's any danger.  I
mean, the argument that you can lock up your coins for too long and it can be
dangerous for quantum-related things, it's kind of a difficult argument to make
because you can already do it.  Like Jameson mentioned, you can already put an
absolute timelock somewhere 100 years in the future.  Obviously, not many people
are doing that, while if people are going to be very customarily putting things
15 years or 10 years in the future, it could become a little bit more cumbersome
to actually deal with people practically doing these things.  But I think that's
up to the wallet implementers to guide their users to pick sane values, by
basically either just limiting it for them or putting some warning if they go
beyond 10 years, or something like that.  I think those are just UX arguments,
not really protocol arguments.

**Mark Erhardt**: Thanks.  Could you repeat again?  So, a single bit would be
used to indicate whether the rest of the 16 bits are interpreted with a factor 8
or not, was that what you said, or does it add bits?

**Steven Roose**: No, I don't think it adds bits.  It just does the same
division where half of it is the actual value and the other half is the bit
flags.  And then it just picks another bit flag in the first half and then
reassigns the value of the latter half.  I think it's like that.

**Mark Erhardt**: Oh, so the first 8 bits would be whether something is
multiplied in the rest of the bits.  I'm not sure I entirely fully understood.

**Steven Roose**: Aren't sequences 32 bits?

**Mark Erhardt**: Oh, you are right.  Yes, of course.

**Steven Roose**: Yeah.  So, we have 16-bit values, which is why we can go up
to, I think, 65,000.

**Mark Erhardt**: Right, okay.  Yeah.  So, correction on the times 65,535 blocks
for the block-based one and 65,535 times 512 seconds.  And the former, the
block-based one, is about 455 days and the latter one is about 388 days.  So,
it's about 15 months in the block-based one and 12.5 months for the time-based
one.

**Steven Roose**: These are the old ones, right?  Yeah.  So, then you would just
multiply by 8 for the new proposed mechanism.  I don't think I have much more to
add.

**Mike Schmidt**: We can move along.  Steven, thanks for joining us, we
appreciate your time.

**Steven Roose**: Yeah, thanks for scheduling me first!

_Security against quantum computers with taproot as a commitment scheme_

**Mike Schmidt**: No problem.  "Security against quantum computers with taproot
as a commitment scheme".  Tim, you posted to the Bitcoin-Dev mailing list an
email titled, "Taproot is post-quantum secure when restricted to script-path
spends", and maybe one quote I'll pull out to kick things off here is, "It
appears to be a common assumption on this list that an attacker can't break
scriptpath spends, but I'm not aware that a convincing justification for this
assumption has been presented by anyone before".  So, I threw that out there,
that's sort of the framing.  So, yeah, I mean, there was a Quantum Summit a few
weeks ago and I think, yeah, your quote sort of embodies that, that the
assumption was that scriptpath spends can't be broken by a quantum attacker.
But you've done some rigor around that analysis.  Do you want to talk about
that?

**Tim Ruffing**: Right.  So, I think your introduction is pretty much to the
point.  So, I mean if we want to upgrade to post-quantum signatures, there's at
least one thing we need to do at some point.  We need to add support for those
post-quantum signatures somewhere, right?  This is the obvious part.  And then,
maybe in a second step, and I think we need to do this and I know at least
Jameson here also thinks there needs to be a second step, where we disable ECDSA
and schnorr signatures, or spending using ECDSA and schnorr signatures, or the
old, in a sense, the legacy at that point, discrete-logarithm-based schemes,
because at some point they will be insecure, assuming that there will be a
sufficiently powerful quantum computer.  Why we need to do this is more like a
social or philosophical or monetary question maybe.  But I think I don't want to
go into that discussion here too much, I think, but I just want to refer to
Jameson's great blogpost, I think.  Feel free to chime in.  But yeah, I don't
think a world where someone with a quantum computer can just steal all the coins
is a great world for Bitcoin.  So, let's maybe assume for now we need these two
steps.  We need to introduce post-quantum signature support, then give some time
for people to move their coins to post-quantum UTXOs, or at least UTXOs that
would support post-quantum signature spending.  And then, at some point later,
hopefully before large quantum computers are available, we disable spending
using discrete logarithm signatures.

One way to do this, or to do this first step of adding quantum signature support
is to add it within tapscript.  And this idea, I think it's kind of one of the
obvious ways to do it, and this idea has been floating around, it has been
spelled out explicitly by Matt Corallo, I think, earlier this year or even the
end of last year on Bitcoin Dev.  If you ask me, the advantage of this approach
is that the entire ecosystem can continue using taproot for a while.  We can
keep the nice benefits of taproot.  Schnorr signatures, they're short, they're
compact.  We have multisigs, maybe I'm a bit biased here.  But yeah, we created
all these nice things and we want to keep using them for a bit.  And in
particular, this gives us more time to do research and experimentation and
development, and whatever, on post-quantum solutions, because if you look at the
research side, we have some post-quantum signature schemes now, but they have
huge signature sizes, they have huge public keys maybe.  Okay, you could hash
them, but everything is a bit less efficient or extremely less efficient
depending on your point of view.  And also, they lack a lot of advanced
functionality, like multisigs, for example, or public derivation is a hard thing
to do.

So, the idea would be, if you took that approach, the idea is you add
post-quantum signature support now by adding opcodes to tapscript,
CHECKSIGPOSTQUANTUMVERIFY maybe, something like that.  So, you have opcodes for
that in tapscript.  And then, if you now receive new coins, you can still
continue using schnorr-based keypath spends for a while, but you also commit to
a script in your tapscript tree that enables spending via post-quantum
signature.  And this means that essentially you have a fallback.  So, if now, at
this point, we would keep all spending, or spending using ECDSA and schnorr,
then you could pull out that script and then do scriptpath spends using a
post-quantum signature.  And yeah, this was the long introduction.

But what the paper now basically shows is just that this approach is secure.
So, even if at that point, if you disabled the DL-based spending because we
think there is a sufficiently large quantum computer, we know that, of course at
this point, the quantum computer can't break keypath spends anymore just because
they're disabled.  But also, what the paper shows is that, and hopefully with
some rigor, that the attacker at that point can't break scriptpath spends.  What
would it mean to break a scriptpath spend?  Well, one obvious way is to break
the bindingness of what I call the taproot commitment, so basically, take your
auto key and open it to some merkle root or to some script that wasn't even in
there.  And this of course would be very bad, right?  If I can open your taproot
UTXO, your taproot outputs to any script I want, then I can impose any
conditions so I could spend it and just steal it.

So far, I think people have assumed that this is kind of secure because it uses
hash functions, and hash functions tend to be post-quantum secure.  But I felt
the need to have really rigorous arguments, because I believe in improvable
security.  And I think if we make cryptographic changes to Bitcoin, we should
have various kinds of evidence that they're secure.  And one kind of evidence is
cryptographic security proof.

**Jameson Lopp**: Now, I guess is it fair to say, it's secure against long range
attacks as long as the funds haven't been spent, right?

**Tim Ruffing**: I think that's fair, but I wouldn't see why it wouldn't be
secure against short-range attacks also.

**Mark Erhardt**: Well, with address reuse.

**Jameson Lopp**: Yeah.  Well, once you spend the funds, you're exposing
everything about the scriptpath spender.

**Tim Ruffing**: Yeah, okay.  In a world where you don't disable DL-based
spending, you say?  Because my working assumption is now that at some point in
the future, you will disable spending via schnorr signatures or spending via
ECDSA, and then it doesn't really matter if you revealed your public key before,
because breaking it isn't worth anything for the attacker.

**Jameson Lopp**: Gotcha.

**Tim Ruffing**: But right, if you don't do this, then I think your conclusion
makes sense, yeah.

**Mark Erhardt**: Right.  So, you talked a little bit about your idea how we
could introduce post-quantum secure signature schemes, but I wanted to put it
into the broader context.  So, BIP360 has been a proposal that has been evolving
over the last year or so, and the latest iteration is that BIP360 proposes now a
new output scheme that would be very similar to taproot, but essentially only
have a scriptpath spending way and remove the keypath spending.  It would make
the scriptpath spending slightly more efficient, but that would allow users to
continue using tapscript in this new output scheme, and then in parallel, also
add leaves to their tree, which are post-quantum safe.  So, they would have a
way of spending, even after cryptographically-relevant quantum computers arrive,
a way of spending with the post-quantum signatures.  But before that, they could
use the scriptpath spend, which would still be bigger than a keypath spend in
taproot, but it would be much more block-space efficient than the post-quantum
signature schemes, which are humongous in comparison.  Currently, something like
the smallest are 50 times bigger or so than what we're using right now.

So, you're saying, why not just put it into tapscript directly and allow P2TR to
have post-quantum signature schemes, and then users could on their own time do
the same thing.  They'd create new outputs that under the hood have both
scriptpath spending leaves with post-quantum security and without.  And then,
once cryptographically-relevant quantum computers arrive, we disable the keypath
spending on P2TR, and then people would be able to just start using the
post-quantum-safe leaves.

One thing that has come up in this context is that people have been complaining,
"Oh, but then you can't see how much coins are post-quantum save or not, because
it's actually hidden under the hood".  And some people have been arguing,
"That's the point.  We don't want outputs to look differently".  Others have
been arguing, "But it would make it very easy to have a different output type so
we know what outputs to lock for good".

**Tim Ruffing**: I think that's kind of an orthogonal question at least.  I
mean, in terms of privacy, you can always voluntarily review data, right?  I
think your description is very accurate of that approach, but even in that
approach, if you want to add a flag to the new UTXOs, of course you can do it by
setting a bit or by increasing the taproot version, or something like that.
Yeah, indeed.

**Mark Erhardt**: Right.  Yeah, so you're saying this is obviously not
necessarily something you have to decide, but I think it's very interesting in
the context of BIP360 that you're saying, "Well, we can just do it in taproot.
It's slightly less efficient on the scriptpaths for block space, but other than
that, we get it immediately with P2TR already.  It would be a smaller soft fork
maybe.  And the security proof, of course, is very welcome.

**Tim Ruffing**: Yeah, I think that's a very accurate description.  And in that
sense, the BIP360 proposal, at least the updated version, isn't too far from my,
I wouldn't call it my proposal, but from the upgrade path I had mentioned.  It's
just that I think if you have taproot keypath spending now, why disable it now
if you can prove that it's secure?  And one maybe governance kind of argument is
that I think at the moment, there are many proposals and there's not so much
pressure.  I mean, post-quantum is now a topic everyone talks about, but I feel
like some external pressure could be necessary to actually agree on a soft fork
or even on a hard fork, or whatever upgrade we want to do in the future.  And
this may sound a bit stupid, but this is an argument to procrastinate on this,
because if we keep using the stuff we currently can do, then this allows for
pressure to build up, and this will maybe make it easier in the future to agree
on a change, just because then we are all in the same boat in the end and some
change is better than no change.

**Mark Erhardt**: Jameson, you've been thinking a lot about post-quantum
security lately, and I think you've been at least building your proposal on the
idea that sending to P2TR and other quantum-vulnerable output types would be
restricted first.  So, having a distinct output type for the post-quantum safe
scripts would be helpful in introducing that step.  Do you have comments at this
point?

**Jameson Lopp**: Yeah, from that perspective, I think it would be preferable if
you want to have a more gradual migration.  Really, what I've been thinking
about for the past five months or so is more of just the game theory of all of
this.  I was thinking about the philosophy and morality stuff as well, but
ultimately my conclusion that I ended up writing up back in March was that it's
the game theory and then the incentives that I think are going to matter the
most.  And there will be a lot of conflict because of ideological clashes and
the fact that one way or another, if quantum computing ends up posing a real
threat, there will be a violation of properties of Bitcoin that people consider
to be inviolable.  So, I'm not a cryptographer and I'm not opining upon how long
we have.  I'm also not a quantum computing expert.  All I know is that the
general interest in quantum computing and advancing quantum computing seems to
be picking up.  And I know that the ability to upgrade Bitcoin and coordinate is
becoming harder and harder, and the process of doing so is becoming slower and
slower.  And just the divergence of those two things is what causes me concern.

So, if we're talking about a problem that may not arise for a decade or longer,
I think it's still prudent to start talking about how we might approach this
problem because it's going to be a huge coordination nightmare, especially
because it would be unprecedented in the sense that we've never had a protocol
change before that required people to actually move their money to change the
properties by which they were locking their money.  And that's why the BIP that
I have been working on is not so much about the cryptography because, quite
frankly, as Tim said, a lot of the current options are pretty terrible, and
hopefully we can develop better ones before it becomes an issue.  But it's
really more about how we would go about creating incentives in game theory that
are the best possible outcome for having to go through this process.

**Mark Erhardt**: Let me jump in real quick.  So, we were talking about the
security against quantum computers with Tim, and we've sort of gradually segued
now into the other changing consensus topic by Jameson, which is a new BIP about
migration from quantum-vulnerable outputs.  So, I just wanted to quickly give
Tim a chance.  Did you have any wrap up that you wanted to add to your topic,
because then we'll start with Jameson's.

**Tim Ruffing**: No, nothing really from my side.  I think in particular, your
last summary was very accurate, but just let me add one comment to what Jameson
said.  It's interesting that you said you're not a cryptographer and then you
added you're not a quantum computing expert, because that's what I always say,
"People, don't ask the cryptographers!"  I mean, they're the wrong people to
make predictions.  But anyway, I believe it's very hard to predict the future
that holds for everyone, including cryptographers and quantum computer
researchers and engineers.

**Mark Erhardt**: All right.  Thank you.

**Mike Schmidt**: One quick tangent for you, Tim, before we move on.  You
referenced BlueMatt's post at the end of last year titled, "Trivial QC
signatures with clean upgrade path", where he suggests that you could
essentially have the scriptpath and if things go awry with quantum, then you
could use that as a quantum spendable if the keypath is disabled.  Does this
quantum signature scheme need to be decided before something like that hook is
made available, or could the semantics of such a scriptpath hook be agreed upon
and then the particular scheme implemented later?

**Tim Ruffing**: Yeah, I think that's another one of the hard questions.  I
think from purely a technical point of view, what you could do is just decide on
a public key type now.  So, maybe take a hash-based scheme.  Of course, if you
look at the signature scheme, it comes with a key generation algorithm, comes
with assigning algorithms, comes with a verification algorithm.  But in
practice, if you improve schemes because there's more research, and so on, what
you typically improve is how verification works, how a signature looks maybe,
but not how the public key looks.  So, there might be a possibility to say, from
a technical point of view, "Okay, we just commit to a key that looks like this".
And maybe currently, there is some scheme there, but we could hope for further
improvements in the future, so that at the point when we actually have to
produce signatures, the scheme or the techniques behind it have been improved.
But that's vague in various ways.  So, it's already vague when I say it, because
it depends on future improvements.

In a sense, maybe this goes into too much detail, but also I think it varies a
bit depending on what cryptographic assumptions you want to use.  The key for a
hash-based scheme is probably the root of some kind of merkle-tree-like thing.
And here, the tree structure really depends on what you can do with the
signature.  So, you probably, if you use a hash-based scheme, it doesn't really
make sense to leave the scheme unspecified.  It could make more sense in other
types of signatures, maybe lattice-based or zero-knowledge-based signatures,
because there you have just more flexibility to play around with the signature
algorithm and make improvements in the future.

But just from a maybe implementation or confidence user perspective point of
view, I think if we add a way now to commit to post-quantum public keys, we
should also enable a way to give post-quantum signatures on the chain, because
otherwise it's not really convincing to the ecosystem, right?  It's like, okay,
there is some way to commit on a key and I could even do this now.  I mean, I
can have a hidden script in my tree that I don't reveal.  So, we don't need any
consensus change at all to do this now.  But that's exactly the problem, because
if I start doing that now, it's just my hope that the ecosystem will converge on
my methods, and I think this is just too vague.  So, I think just from that
point of view, it just totally makes sense to, if we add the scheme now, we also
implement it and fully activate it so people could use it if they really want
to.

But there's one thing I may want to add.  There could be some way in between
where we say, okay, some of these particular hash-based schemes, which are
conservative, are few-times signature schemes.  So, we can give a few
signatures, maybe let's say 8 or 16, or something like that, and after you have
created this many number of signatures using your private key, you can't create
any more signatures without losing security.  We could do something like this to
maybe say, okay, maybe we commit in a way that we have an 8-time signature
scheme where you can do 8 signatures, and then you have 8 slots that you reserve
for future schemes that you can add to Bitcoin and you just delegate to those
schemes.  So, maybe we add the 8-time signature scheme; maybe in one slot, we
already now add something like SPHINCS+, just to name one thing that is kind of
pretty conservative; but then we could say, okay, in the future, we now have
another scheme that we are confident in and that we like, and we add this to
basically the second slot.  And then, what users then could do is just to use
this 8-time signature scheme in the future to sign a public key of the second
slot scheme.  And basically, we have 8 slots, we have a few chances to improve
or get things wrong.

This is just a vague idea that I had in my mind.  I may want to spell this out
in the future, but this might be a middle way.

**Mark Erhardt**: Yeah, Tim, I was going to say you're creating proposals here
on the fly.  How about you write some of them up?  I hear we have currently four
quantum-related BIPs, or five even, at various degrees of maturity.  We
absolutely need more competition.

**Tim Ruffing**: I agree.

_Migration from quantum-vulnerable outputs_

**Mark Erhardt**: All right.  I think we've delved quite deeply into this topic.
Thank you, Tim, for joining us.  I hope you feel better soon.  And then, sorry
for putting you back on the back burner, Jameson, I think we're going to dive
into your proposal now.  We sort of had an introduction already, but, Mike, did
you have something prepared that you wanted to say?

**Mike Schmidt**: Just a quick one.  Jameson, you posted a post-quantum
migration proposal to the Bitcoin-Dev mailing list.  What is your three-step
plan?

**Jameson Lopp**: Right.  So, I'm skipping the hard part here, which is actually
getting consensus to determine that quantum computing is a sufficient threat
that we need post-quantum cryptography, and then bike-shedding over which
post-quantum signature scheme is the least terrible.  And I'm instead looking
forward and saying, okay, this BIP is going to start under the assumption that
we have done that, that we have implemented post-quantum cryptography.  How do
we then deal with all of the incentive issues to get people to migrate, because
this is an unprecedented problem where we've never had a protocol change before
that is done under the assumption that people need to adopt it as quickly as
possible for their own safety and for the security of the ecosystem at large?
So, essentially this says, okay, we've activated some post-quantum scheme.  What
do we then do with regard to making the migration more gradual and palatable,
and understanding that there's no way to email every Bitcoin user, there's no
way to message everyone who's using Bitcoin saying, "Hey, you need to upgrade
the security of your funds".

So, I figure the first step that makes sense towards this type of migration
would be that we only really allow for funds to be spent out of legacy scripts
to a quantum-secure output.  So, basically that means at some point, say several
years, we're saying three years is the suggestion after we activate this
post-quantum cryptography, and we give people those three years to start
implementing it essentially for the protocol change to matriculate throughout
the ecosystem; and then, at the three-year mark, if you are sending money to
what would be considered a quantum-vulnerable output type, then we reject that,
we just don't allow that transaction to happen.  The idea being that if someone
is trying to send money and their bitcoin transactions are getting rejected,
that is going to essentially force them to educate themselves as to what is
going on, and then they will understand the incentives around why they need to
upgrade their security.

So then, more controversially, we're suggesting that two years after that, so
five years after activating post-quantum cryptography, that we then start
rejecting any transactions that are spending funds out of a quantum-vulnerable
script.  So, current idea being that we essentially look for any of the opcodes
that are using ECDSA, like OP_CHECKSIG, OP_CHECKSIGVERIFY, OP_CHECKMULTISIG, so
on and so forth, and of course this is arguably the most controversial aspect of
this proposal, because this would essentially prevent people from being able to
spend money if they had not upgraded it.  So, in an attempt to remediate that,
and this is where more research and development is going to be required, is can
we then have a third step, preferably a third step that activates at the same
time as the second phase, which is that we do allow people with
quantum-vulnerable funds to spend their money if they also provide some
additional quantum-safe proof that the funds belong to them and have not been
reverse-engineered by an attacker.

There's a variety of ways that this could occur.  The one that we were leaning
towards is maybe some sort of zero-knowledge proof.  But essentially, I think
that whatever proof it would end up being, it would essentially have to be a
proof that you have a hierarchical deterministic wallet and that you are able to
independently derive the private key that you're spending from, from a root
private key.  So, that's going to require additional research to figure out how
feasible it is, but it certainly seems theoretically possible.  And that would
allow us to somewhat remediate the issue that there still could be people that
get locked out of their funds in the long term.  Essentially, this would still
likely create the permanent locking of any really, really, really old, non-HD
wallet funds, because there's just no other data that exists that you would be
able to provide publicly to the network to show that the wallet was yours and
not an attacker.

**Mark Erhardt**: Yeah, this would generally not work for anyone that uses a
bag-of-keys sort of wallet, which Bitcoin Core had, I think, before 2013.  And
likely a lot of the P2PK outputs from the first reward epoch with the 50-bitcoin
block subsidy would not be new wallets in that sense that they could prove
anything about these P2PK outputs.

**Jameson Lopp**: Some might say, "Why three years, five years?" so on and so
forth.  These are arbitrary numbers that we could argue about.  I would argue
that it doesn't really make sense to me, and I don't believe that we would end
up implementing some sort of novel, new post-quantum cryptography, unless it was
deemed it was going to be truly necessary.  So, I doubt that we would activate
something several decades before a cryptographically-relevant quantum computer
came along.  Also, there's an ongoing debate as to whether or not doing this in
an opt-in only fashion is sufficient.  I think that's where a lot of the crux of
the argument is for locking or freezing vulnerable funds.  Is it sufficient if
we give people the ability to voluntarily secure their own funds, if a
non-trivial part of the ecosystem does not upgrade in time?  And we all know
human nature and procrastination.  Are you going to be happy, as a bitcoin user,
that your funds are quantum secure if so much bitcoin ends up re-entering
circulation and getting dumped that the value of your holdings gets totally
crushed?  That's, I think, what a lot of this comes down to.  And then, what are
all of the ripple effects throughout the rest of the ecosystem if such an event
occurs?

**Mark Erhardt**: There's also just the question of how much confidence people
would have in a system where, say, a quarter of all bitcoins are up for
misappropriation and not owned by the people spending them, with basically no
way of properly distinguishing them or alternatively introducing a fungibility
issue.  So, this might be a fork event or all sorts of other ways that the
Bitcoin ecosystem could be severely damaged.

**Mike Schmidt**: Jameson, question for you.  It seems like the timeframes of
your proposal kick off at the time that a quantum-resistant signature scheme is
activated on Bitcoin mainnet, which sort of then means that it puts a lot of
pressure on activating that scheme to be an accurate indication of if quantum is
going to be here; whereas I could see there being different bars, right, where
one bar is, "Hey, we have a scheme, it looks like this thing could happen", but
then like, "Okay, quantum is here.  Now there's a higher bar, and now we're
going to execute the next phases of your proposal", if you want to think about
it like that.  But in the way you have it, sort of the bars are the same.  Once
we even put the idea of a quantum-resistance signature scheme out there, we've
now signed up for locking coins.  I don't know, I think there's been some
discussion, I think, on your proposal on the mailing list and maybe you can
digest that for the audience of how you think about that?

**Jameson Lopp**: Yeah, well, so one aspect of it is, at least currently, all of
the post-quantum cryptography is terrible, it has so many terrible trade-offs.
I don't know why anyone would even want to entertain implementing it unless they
really thought that this was a true threat to the entire ecosystem.  Maybe
something much better will come along that will make more sense that it would be
an opt-in only thing, and it's actually quite efficient and we're not losing a
lot of the other functionality that we currently have with the protocol.
There's a number of different ways that this could go as well, which I haven't
really dug into too much, but sort of on the opposite extreme is that it's
feasible to come up with an alternative activation and accelerated timetable in
the event that something does occur that makes a cryptographically-relevant
quantum computer appear much sooner on the horizon, or even if we just have
actual cryptographic proof of such a computer existing.

That's one of the things that we talked about at the Quantum Summit a few weeks
ago, was essentially offering a triggering mechanism at the protocol level.  It
would be fairly trivial for someone with a quantum computer to be able to prove
that they had a quantum computer.  The bigger problem is, does the game theory
work out such that someone who had that ability would be benevolent enough to
prove it to the ecosystem that they were a threat and that we need to guard
against it?

**Mark Erhardt**: Yeah.  I wanted to jump in, tying back to what Tim was talking
about.  So, if Tim says, "Why not just put a post-quantum signature scheme into
tapscript as a fallback mechanism that people can start opting in?" I think that
would, of course, not qualify as the, "We're actually convinced that post
quantum is really going to happen sometime soon to trigger Jameson's proposal",
or at least it seems obvious to me that's not the same things you guys are
talking about.  But, Tim, did you want to chime in on this?

**Tim Ruffing**: Yeah, I guess you're right.  These are different approaches and
I think they both are meaningful.  And I think if you ask me, I mean I tend to
work on the cryptographic questions because this is where my expertise is.  But
I feel like those in the end are not even the hard questions in a sense.  At
least we have post-quantum signatures right now.  We have some schemes, they may
not be great, but we have them.  We also have proposals on how to do the
upgrade, but I feel like this is where most of the discussion will happen, in
particular because everyone tends to have an opinion.  I feel like for your
proposal, I think that's a very reasonable thing to do.  I'm just not sure if
people would want to agree on this again, like if they don't know that the
quantum computer will be shortly available, whatever 'short' means.  So, it goes
back to maybe what has been said before, that at the point you start the
timeline, you have to commit on the deadline where we do the moves.  And if we
are talking about the time frame of a few years, it's even hard to predict what
will be there in three weeks, and it's even harder to predict what quantum
computers will be able to do in three years.

I could imagine that in an optimal world, I would love to see this migration
path being the one that's used, but I'm just not super-convinced that we can
agree on a soft fork that says, "Okay, from now on, we just start the clock and
in three years, the deadline".

**Mark Erhardt**: Yeah, that reminds me of one of the conclusions I had from the
Quantum Summit, which was that the hardest part is actually trying to gauge the
viability of cryptographically-relevant quantum computers and the timelines of
those.  One of the quantum computer experts that was attending made a salient
point about, "Well, in the next five years, we'll probably get good updates on
the timeline".  And hopefully, that means that they are not going to be here in
the next five years, but that is one of the questions that are hard to answer.

**Tim Ruffing**: But even that is a meta prediction about the future, right?
And maybe, let me maybe add one anchor to that again, maybe a bit of a technical
one, but you could say that the upgrade strategy that I've been talking about is
a bit more conservative, literally because it keeps the full taproot
functionality.  But this is not even true from a technical point of view, at
least given the current post-quantum schemes that are out there, because what
people tend to overlook is, at least with hash-based signatures and everybody
now talks about hash-based signatures, is that we can't have public derivation.
And this already changes how wallets work.  So, even this, there will be
pressure and procrastination.

**Mark Erhardt**: Let me jump in very briefly.  So, last week I believe, we had
Jesse Posner on, who had spent some time doing research on which of the current
wallet patterns are available with various post-quantum schemes.  And one of the
conclusions that he had was that a lot of the BIP32-like derivation, MuSig,
FROST, and so on, would be compatible with lattice-based signature schemes,
which of course make more cryptographic assumptions and therefore are
potentially more vulnerable to be broken in the near- or long-term future.  But
he also thought that some of the derivation wallet schemes might be possible for
the hash-based signatures, if I remember right.  So, what I was thinking is,
wouldn't you be able to craft an output script descriptor that has a tree with
regularly derived scriptpath spends that are DL-based (discrete-log-based) and
then have a static post-quantum scheme next to it, where the post-quantum scheme
is there and yes, you'll have to reuse the script leaf a few times if you have
multiple UTXOs?  But you could basically have, in parallel, an output script
that looks different every time, whereas it has a static post-quantum fallback,
giving you privacy in the default case where it's not needed yet, but giving you
a default back for post-quantum if you need it.

**Tim Ruffing**: Yeah, you could, and this is maybe a totally reasonable path in
the middle.  So, the problem here is that to construct the UTXO, you need to
have all of the involved public keys, right?  So, if you have a DL public key
that can be used at least now for spending, you may have multiple maybe
post-quantum public keys, depending on what schemes we add.  I mean, it's not
crazy to add multiple ones to see what works out best in the future.  But the
issue is to compute the UTXO, to compute the address, you need to know all of
these public keys.  And so, this idea of, "Okay, let's add multiple schemes and
let's wait a bit and see which ones get broken and which not and which ones
would get improvements", doesn't really work out in every last bit.  But what
you could do is let's say now, yeah, this is basically really what you said.
So, maybe let's say the hash-based schemes are very conservative, so let's add a
hash-based scheme now.  And what people can do is have a static script where
they can spend their UTXOs using a hash-based signature, with the idea that it's
really just a fallback in case everything breaks down and we are not quick
enough adding more solutions, and with the drawback then that if you really
reveal that script, at least the public key in there will be the same for your
entire wallet.  So, you kind of link all your coins together.

The alternative is, of course, you can also, if you have a hardware wallet, you
can make it export a million keys.  You can do that, but it's just it doesn't
fit the current API model of what wallets do, so it may be hard to get a wallet
to do this.

**Jameson Lopp**: I think it is preferable if we can give people wallets that
have multiple signature schemes behind them, but you still inevitably will run
into the question of, "Okay, when do we disable a given signature scheme?"  So,
I think there's two main paths.  One is, do we aim for a gradual, slow, more
smooth migration path, because we know that it's going to take probably many,
many years to actually get the UTXO set migrated; and then the other, which I
don't think has really been discussed as much is, what are the potential
emergency break-glass scenarios of cut off all spending of vulnerable coins in
any vulnerable signature schemes, and then basically require people to either
only use the post-quantum cryptography schemes or to use some sort of other
quantum-safe proof of wallet ownership?

**Tim Ruffing**: Yeah, indeed, I fully agree.  So, maybe add one more thing to
what I was saying.  So, you could commit to static hash-based public key nodes,
this is a merge set, but also commit to maybe a lattice-based scheme.  And I
just wanted to mention that also, other assumptions may allow public
derivations, for example, zero-knowledge-based schemes.  There's a variant of
Picnic, for example, which is an MPC-in-the-head-based scheme that also enables
public verification and public derivation.  And we haven't really looked into
other assumptions.  But yeah, I mean it's totally feasible to add multiple ones,
modular auto engineering complexity, but it's really what Jameson said, there's
no precedent for this.  So, it may sound crazy to add multiple schemes at once
because you're not sure, but if you think about it, we never had an event like
this before or a situation like this before, so maybe it's not that crazy.

**Mark Erhardt**: To break the lance for that approach, one of the things we've
been hearing about at the Quantum Summit was that a lot of other ecosystem
participants were sort of pushing for something to happen to address this
potential future problem.  Having an opt-in mechanism that people can use
already, even while we consider quantum computers to maybe not be super-pressing
yet, would demonstrate that the ecosystem is starting to react to the topic.

**Mike Schmidt**: Well, it's an interesting set of discussions around quantum.
Tim and Jameson, thank you both for joining for these two this week.  I'm sure
we'll have more and look forward to talking to both of you about it in the
future.  Thank you for your time.

**Jameson Lopp**: Thanks for having me.

_Testing compact block prefilling_

**Mike Schmidt**: Jumping back up to the news section, we have two news items
this week.  The first one is titled, "Testing compact block prefilling.  David,
you posted a follow-up or reply on a Delving thread about compact block
reconstructions that we covered previously, initiated by 0xB10C.  In that
original post, 0xB10C looked at how using compact blocks, or as Murch likes to
say, passing around block table of contents, instead of full blocks, how that
performs statistically over a period of few months.  And in your reply, which I
feel like I'm doing a disservice calling what you wrote a reply as it's quite
robust, but you detailed a bunch of research that you conducted on prefilling.
Can you maybe explain what prefilling is in the context of compact blocks?

**David Gumberg**: Yeah, so the compact block message, to use Murch's metaphor,
includes a table of contents of the transactions that the node receiving the
announcement needs to have in order to perform the reconstruction.  And if a
node that receives a compact block announcement is missing any of the
transactions in the compact block, it has to perform a round trip to request
those transactions and receive them.  The original compact block proposal
includes a prefill section in the compact block announcement, where a node
that's sending a compact block announcement could include transactions that a
peer might care about.  And today, in Bitcoin Core, we only use the prefill
section of the message to prefill the coinbase transaction, which peers always
won't know about until the block is announced.

A few months ago, 0xB10C proposed and wrote a branch of Bitcoin Core that tries
to predict the set of transactions that a peer won't have, and send those along
in the prefill section of the compact block announcement.  And if we can get the
prefill right and send the right transactions that our peer would have been
missing, we can prevent altogether this extra round trip.  The approach that
0xB10C used was to prefill the set of transactions that we didn't know about
when we received a block.  So, when you receive a compact block, whatever
transactions in there that you had to request from your peer, you'll pass along
in the prefill to the next peer.  And if you're receiving a block that's been
prefilled, you'll also look inside the prefill and see which of these did I
actually need, and you'll pass those along to your peer when you announce a
compact block to them.

There were some questions raised on the Delving post.  So, there are some
trade-offs here between bandwidth and latency.  And there's one particular
hiccup, which is that the Bitcoin P2P Network is over TCP sockets.  And in TCP,
there's a little bit of a complication, which is that we can't just send as much
data we want over the wire without incurring an additional round trip.  I
detailed this in the post, but basically there are these TCP window sizes, and
if we send messages that are too big, then an extra round trip will be required
anyways.  And so, what I wanted to do research about was basically whether or
not 0xB10C's prefilling approach could be -- well, first of all how effective it
was, I wanted to observe that; and second of all, whether or not the prefills
would actually fit within the TCP window.  And I also outlined in the post why,
if we ever exceed the window, we were better off not doing the prefilling in the
first place, because we pay an extra round trip and we might as well have let
the peer ask us for the transactions that they were missing.

So, basically what I observed, so what I did was I connected one node that was
prefilling the compact blocks that it was announcing.  It was running 0xB10C's
branch.  And the other node, I made it so that it would basically only listen to
compact block announcements from this peer.  And I just gathered some data.  And
so, the baseline that I observed, over about 20 days, of reconstruction rate for
a normal node was 62%.  So, 62% of the time in this particular node, when it
received a compact block announcement, it did not have to request additional
transactions and pay an extra round trip.  But 39% of the time, it had to pay an
extra round trip to complete reconstruction.  And looking back to the beginning
of 0xB10C's post, he shows some data about what block reconstruction times look
like, when you need to do a round trip and when you don't need to do a round
trip.  And when you don't need to do a round trip, it takes on the order of 15
milliseconds to do reconstruction; and when you need to, it takes somewhere
around 150 milliseconds, obviously depending on your connection to the peer.

**Mark Erhardt**: To be fair, one should maybe also include the time that it
takes to get the data the first time.  So, the round trip obviously adds a
message back to the sender and another message from the sender to the receiver.
So, presumably the first reconstruction is 15 milliseconds plus something like
75 milliseconds or so?

**David Gumberg**: Yeah, exactly, something like that.  So, that metric comes
from some logging that Bitcoin Core does, and we don't know what's on the other
side.  So, we don't know how long it took from the peer announcing the compact
block to us beginning the reconstruction process.  We don't have that timing.
But that figure that I just showed, yeah, that has that caveat, which is that it
doesn't include that half-round-trip latency for us.  So, maybe a better way to
put it is something like that when we need to do a round trip, reconstruction
gets about 150 milliseconds worse than whatever it is.

**Jameson Lopp**: I can say that from my own logging with my Satoshi node, the
median peer ping is about 50 to 60 milliseconds.

**David Gumberg**: Yeah.  So, that would be on the order of 100 extra
milliseconds.  And it's even slightly worse because compact block announcements
are done really, really early in the validation loop.  So, even before you've
fully validated a block and checked all the signatures, you're sending out
compact blocks as fast as possible.  But when I receive a compact block and then
I request the rest of the transactions from you, that request has to wait in
line for the block to get fully validated.  It's just like, it doesn't get this
kind of special hot-case treatment.  So, there's other small effects that add on
to why latency gets worse in that case.

For comparison, what I observed on the node receiving prefilled blocks was that,
kind of as expected, these are two Bitcoin Core nodes that are basically running
the exact same mempool policy, these two nodes were in the same data center,
they're very well connected to each other, very low latency.  So, this figure
kind of comes with that caveat, which is that not all nodes will have this
strong of a tendency to converge.

**Mark Erhardt**: Sorry, they are in the same data center, and the round trip
still adds 150 milliseconds?  Is that right, do I understand that?

**David Gumberg**: No.

**Mark Erhardt**: Okay, sorry.

**David Gumberg**: The 150-millisecond data, that comes from 0xB10C, and he
observed that on mainnet with some of his nodes.  In this observation, I didn't
do anything with round trip times.  I just was trying to reason about when we
did and when we didn't have to pay for a round trip, whether or not we did, not
how long it took.  But that, I think, is the next step of work, to actually put
two distant nodes so we can get real latency data.

**Mark Erhardt**: Okay, let me jump in briefly.  So, the idea is basically the
fastest way nodes propagate block announcements is giving a recipe how to
compile the content of the block from another node's own mempool.  It's
basically just an ingredient list and the header.  And we do this specifically
with, I think, three peers that we say, "Hey, you're giving me stuff pretty
quickly.  I'll declare you my high-bandwidth, compact block relay node.  You can
send me blocks even before you finish validating them".  So, we don't do this
always, otherwise that might actually cost more bandwidth.  But in this context,
now you're proposing rather than just giving the ingredient list and the header,
I'm also going to send you a few transactions that I had to ask back about
before I could forward the block.  In this context first, would maybe also
including some of the transactions that you just learned seconds before hearing
about the block make sense, if you have space in the prefilled block?  Have you
looked at that?

**David Gumberg**: No, I haven't looked at that.  So, what I observed was with
this kind of really primitive prefilling, only using this one heuristic, that
the node receiving the prefills was able to reconstruct 98% of blocks.  So, the
reason it's not 100% in this case, even though they're running the same mempool
policy, is probably because of a scenario like what you're talking about.  So, I
do think that would be worth looking at, yeah.

**Mark Erhardt**: Well, if you're saying that you already get 98%
reconstruction, whereas you measured 62% before without the prefilling, maybe
the simple heuristic is already sufficient.  And sure, maybe we could do even a
little better, but it might also make it worse because we're now sending more
data that is unnecessary often.  So, you've been testing for 20 days.  I saw
your write-up in Delving.  People that are interested in this topic, this is a
thorough work of all sorts of statistics and a detailed description of the
approach.  If you are interested in the topic, give it a read, it's well worth
it.  So, what are the future steps?  What's going on next?

**David Gumberg**: I just want to add one more caveat to that 98% figure, which
is important, which is that that is unbounded prefilling, but in reality we're
going to have to bound the size of prefilling.  And the estimate that I got was
something like 93% once we bound the prefilling to the TCP window.  And there's
work to be done to maybe get that number higher, to be smarter about which
transactions we choose to include.  So, there is a lot of future work here.
Like I said, I didn't really think about propagation times.  I was just trying
to focus on whether or not we had to do a round trip.  And so, one of the things
I want to think about more is how to go from thinking about point-to-point
latency, like node hearing about compact block and reconstructing it, to
thinking about how that impacts networkwide propagation.  I think there's a lot
of further work there, and I think there's more work to be done.

I think the next experiment is going to involve actually doing prefills bounded
to the TCP window.  And then, I also hope to do maybe some work using the warnet
tool to maybe set up some scenarios that have more than just two nodes, because
the experimental setup I described really only works when you kind of have two.
And I want to try some more, I guess, contrived scenarios to see how this
performs.

**Mark Erhardt**: Thank you for the thorough description, and thank you for your
patience sticking around so long.

**David Gumberg**: Thank you.

**Mike Schmidt**: Mike, did you have more?  Just maybe a comment that I saw
earlier.  It was on Gloria's PR to change the relay fee.  I think 0xB10C posted
some data with a bunch of red in it, indicating nearly 1 MB of data to
reconstruct the block, due to a lot of below-1-sat/vB (satoshi per virtual byte)
transactions being mined, but not necessarily being fully relayed.  Probably can
get into that in a future discussion as well, but it touches a little bit on
your work, David.  Yeah, Murch?

**Mark Erhardt**: I think actually it's sort of orthogonal.  So, with that sort
of amount of data, we wouldn't be able to solve it with a prefill.  What this
shows is how brittle compact block relay is, in the sense that it only really
works when mempool policies are somewhat cohesive and a lot of nodes already
have almost all of the transactions that are in the block.  So, in the
sub-1-sat/vbyte summer that we're seeing right now, where suddenly a few people
convinced miners to start mining transactions that were paying less than 1
sat/vB, which had been the minimum relay transaction feerate for almost a
decade, they first started out with only one or two mining pools doing that and
there was sufficient demand that it appeared on mempool.space quickly thereafter
in their visualization of the mempool.  And people started doing a poor-man's
version of preferential peering by just sending around a list of listening nodes
that would accept transactions below 1 sat/vB.  And fast-forward a few weeks
later, 80% of the hashrate is mining transactions below 1 sat/vB.

So, there is currently work in Bitcoin Core to address this discrepancy between
what we're seeing getting mined with what we're relaying by default in Bitcoin
Core.  The feature freeze is coming up in a few weeks, so the idea would be if
we can manage to process this PR in time, maybe in the 30.0 release, this
hashrate preference and what is being relayed on the network and the defaults in
Bitcoin Core would match up again.  And then of course, David's work on
prefilling would be relevant in that context again, but before that, prefilling
is probably limited to, I think, less than 10 kB, usually even less than that.
So, with us seeing blocks requiring almost 0.8 MB of additional data to be
constructed, I think we're going to see hugely increased latency for the moment
on the network between the nodes that do not participate in forwarding such
small feerate transactions; and unfortunately, prefilling wouldn't do much in
that context.  David, back to you.

**David Gumberg**: Yeah.  And I mean, presumably, I think part of the incentive
for miners to run this policy is to have fast reconstruction as well.  It's part
of the equation there.  Yeah, I think that prefilling doesn't solve that kind of
a major divergence between mempool policy and economic activity, but I do think
it can fix two things.  One is small inter-release divergence, so the lag
between the Bitcoin core release being cut and lots of people running that is
huge.  So, it takes a long time to react to economic activity diverging from
mempool activity.  So, this is just like a little bit of a pressure-release
valve, or prefilling would be just a small pressure-release valve there.  And it
would also kind of address one thing that there's nothing Bitcoin Core or any
implementation of Bitcoin can do anything about, which is private mempool
transactions, which we hope remain a small proportion.

**Mark Erhardt**: Actually, one more follow-up question in this context.  Would
nodes that are not upgraded be able to receive such a prefilled block, or does
that require new network messages or something like that?

**David Gumberg**: Yeah.  So, everything was implemented about prefilling except
for picking which transactions to prefill.  There's a comment in there like,
"Come up with some heuristic for the transactions we'll prefill".  But yeah, the
node that received prefills in my experiment wasn't modified in any way, except
for to only listen to compact block announcements from this one peer and some
additional logging, but otherwise it was a default node.  And my node that was
doing prefilling was sending out prefilled blocks to lots of random public
nodes.  And as long as they were running Bitcoin Core, well, yeah, they were
able to process all the prefilled transactions and got the benefits of those
reconstruction times.

**Mark Erhardt**: Sorry, you're creating more questions.  What would happen for
other implementations?  Would they be upset about getting a prefilled block?

**David Gumberg**: Well, presumably, if they've implemented compact blocks and
they're doing the compact-block handshake where they're telling you they support
compact blocks, and then they're asking you to send them high-bandwidth blocks,
then I would assume or hope that they have also -- and the fact is that they
already had to implement prefilling to receive the coinbase transactions.  So, I
would assume that every existing implementation of compact blocks would be able
to handle prefilled transactions.

**Mark Erhardt**: Awesome.  Thank you for your work on this.

**David Gumberg**: Thank you.

**Mike Schmidt**: I encourage folks, like Murch said, to check out the Delving
reply that David packed a lot of information into.  It's a good read.  David,
thanks for hanging on, thanks for your time, thanks for joining us.

**David Gumberg**: Thank you guys very much.  Appreciate it.

**Mike Schmidt**: Well, we have one guest who didn't introduce herself earlier
who's joined us, and thank you, Lauren, for hanging on.  Do you want to
introduce yourself for folks, and then I'll frame up the news item?

**Lauren Shareshian**: Sure, thanks for having me.  My name is Lauren Shareshian
and I work on the Bitcoin custody team at Block.

_Mempool-based fee estimation library_

**Mike Schmidt**: Excellent.  Well, thanks for joining us and I apologize.  We
had a big newsletter this week, but we're glad you're here.  The news item is
titled, "Mempool-based fee estimation library".  Lauren, you posted to the
Delvin-Bitcoin forum a post titled, "Augur: Block's Open Source Bitcoin Fee
Estimation Library".  And in that post, you outline how your mempool-based fee
estimator works.  Lauren, what have you built?

**Lauren Shareshian**: Yeah, we released Augur.  It means, "To predict the
future from omens".  And maybe I can start out explaining what originally
motivated the project.  In the past, we had relied on various external APIs for
our fee estimates.  And some of these providers had experienced pretty large
outages lasting days to weeks.  And so, we really wanted to increase the
resiliency of our system by building an internal tool instead.  And as we were
choosing the internal tool to build, we noticed that WhatTheFee was giving us
the best estimates.  And generously, Felix Weis had shared on GitHub the code
that powers the WhatTheFee estimates.  They were in a pretty informal Python
notebook format, so it took some time for my team to get them production-ready
and convert them to Kotlin, which is what my team uses.  And we also increased
the frequency of the estimate updates.  And since Felix's shared code was so
helpful, we wanted to open-source ours as well.

So, we created the main library, Augur, as well as a reference implementation
for it.  And when we posted that on Delving, almost immediately we got feedback
that it'd be helpful to post the benchmarking tool as well.  So, my colleague,
Steven, got that out like two weeks ago.  And it includes our benchmarking
script plus six months' worth of provider data that we've been benchmarking
against.  We think the tool will be helpful because it keeps track of a few
different metrics, and so different folks might care to optimize different
values.  So, if your biggest concern is getting confirmed as soon as possible,
then maybe you want to minimize your miss rate; whereas if your biggest concern
is saving money, maybe you want to minimize your overpayment.  At Block, we've
been mostly keeping track of a composite metric that takes into account both
miss rate and overpayment, because we don't want to overcharge customers, but we
also need their transactions to get confirmed in a timely manner.

So, for our quickest confirmation tier, Augur has been getting 85% of
transactions confirmed on time, while only overpaying 16% on average.

**Mike Schmidt**: Now that website, Lauren, that you mentioned is whatthefee.io
by Felix, and you mentioned that that served as maybe the scaffolding for what
you guys came up with, and you also now have some data behind some of this
benchmarking that you're putting out.  I saw also that you and Abubakar were
going back and forth.  Abubakar has been doing some Bitcoin-Core-related fee
estimation work.  What discussions did you and Abubakar have in terms of
approaches or questions?

**Lauren Shareshian**: Yeah, he's been super-helpful.  We basically are
considering getting things kind of in parity with WhatTheFee and getting our
benchmarking tool set up; we're kind of considering the beta version.  And now
that we have the tool set up and the algorithm in place, we can iterate to make
it better.  And so, Abubakar, one thing he said he was playing around with was
porting the ideas of Augur into a mempool-based forecaster in Bitcoin Core,
which we thought was super-cool.  And then, he also suggested that we should try
benchmarking against newer versions of Bitcoin Core since the default mode is
economical now.  So, we're going to start working on that soon.  That was
another really helpful suggestion from him.  So, yeah, the feedback we've got on
Delving has given us new paths to go down and we've been super-appreciative of
the feedback.

**Mike Schmidt**: Are there particularities of Block's setup that inform how you
think about fee estimation?  I assume you have many users doing transactions or
withdrawals and you can batch those and you can do fee management with CPFP or
RBF.  And as people go through what you've written up, is the way that you guys
approach it after looking at that research different on your back end?

**Lauren Shareshian**: Yeah, that's a great question.  So, we do have fee
bumping and batching and all the other things in place.  I guess this Augur tool
is trying to minimize the use for the fee bumping and fancier things, right?
We're just trying to get a good first estimate, but then fee bump if we need to.
And then, I suppose another thing that maybe is unique to us or maybe not is
that we have various withdrawal tiers, like standard, rush, priority, and so a
user can choose how fast they need their transactions confirmed.  And so, that's
why you'll see in our API output there's various block targets, because we need
several different block targets for our various tiers, as well as different
confidence levels.  So, if you really need to be conservative, maybe you'll go
with a higher confidence level; if you really want to save money, maybe you'll
go with a lower confidence level.  We've typically been using the 80% confidence
level, which I think is what WhatTheFee uses as well.

**Mike Schmidt**: Murch, you have questions?

**Mark Erhardt**: Well, I guess many, but so the first block target is
notoriously difficult, because of course we have no idea when the next block
will be found.  Bitcoin Core has, for the longest time, only I think given an
estimate starting with two blocks from now because of that reason.  So, you
described that you use the flow of transactions into your mempool as a predictor
of how much other transactions you'll be competing with by the time it's most
probable the next block is found.  Could you go a little bit into that?

**Lauren Shareshian**: Yeah, and to your point about one block, our minimum
block target that we give output for is three blocks, because we're not really
set up to simulate mining partial blocks.  And so, yeah, to go a bit more detail
in the algorithm, we start out by putting everything in the mempool into buckets
by feerate.  And so, as a super-simplified example, maybe the cheapest bucket
would contain all the transactions from 1 to 2 sats/vB, and the second cheapest
bucket would be 2 to 3 sats/vB.  These aren't the exact bucket thresholds
because we actually use a log scale to provide more precision at the lower fee
levels, but for example purposes, it's fine.  And then, we also keep track of
what's flowed into the mempool recently.  So, if I continue with this simplified
example, then maybe there's 100 transactions currently in the cheapest bucket
tier.  But we've been noticing that an extra transaction comes in each minute at
that cheapest bucket tier.  Then, we think there's probably going to be, well,
100 plus 10, 110 transactions in that cheapest bucket 10 minutes from now.

Disclaimer, our assumption currently is actually a little bit simpler than that,
because what we do is we just have the recent inflow during a typical block as
additional weight.  So, let's say we think there'll be 10 in that cheapest
bucket that'll come in over the course of a block, and we have 100 in there at
the beginning of the block.  We're just going to assume that 105 are in there
for the block, which means we'd be overestimating at the beginning of the block
and underestimating at the end of the block.  So, this is one example of where
we feel like we have a beta version, and now we can iterate.  We'd like to see
if we can make that scaler a bit more dynamic.  And then, just to finish off the
gist of the algorithm, we assume miners will choose the most expensive rates
first.  So, we go down each bucket, starting from the most expensive, add their
weights until the block size is reached.  This will give us the cheapest feerate
that actually made it into the block.

Then, the randomness component of how often blocks get mined, that's where the
Poisson distribution comes into play.  And so, on average, three blocks get
mined every 30 minutes, but if you need to be more conservative, maybe you're
going to assume that only one block will get mined in that time.  And that's
kind of why we can't do less than three blocks, because we can't assume that
less than one block is getting mined with our current algorithm.  We're not
doing decimal values of a block getting mined.  So, yeah, that's the basic, just
the algorithm, and it's why you see various confidence levels in our output.

**Mark Erhardt**: So, we know about multiple other mempool-based feerate
estimation methods.  You had in your blogpost a comparison with some of the
popular ones, such as mempool.space.  Did you compare notes with anyone else
besides Abubakar and Felix?

**Lauren Shareshian**: No, those were the only folks.  I'm actually pretty new
to the Bitcoin community, so I haven't met folks on other teams just yet.

**Mark Erhardt**: Okay.  And notoriously Bitcoin Core, well, this is why
Abubakar is working on fee estimation, because Bitcoin Core's feerate estimation
is not currently something that we pride ourselves on.  Did you do any
comparisons?  I think you mentioned that you did comparisons with Bitcoin Core,
but could you get into the details laid on us?

**Lauren Shareshian**: No, we actually want to.  So, one thing that he
recommended is doing a comparison against Bitcoin Core, a newer version.  And
so, we're working on that now, although there's actually kind of some internal
debate on my team about like, if comparing a mempool-based estimator to Bitcoin
Core, is that comparing like apples to apples or apples to oranges?  Are they so
different that like you shouldn't compare them in the first place?  Someone's
expressed that idea on my team.  So, we do want to do it, but we haven't done it
yet.

**Mark Erhardt**: Yeah.  So, for context, Bitcoin Core uses a feerate estimate
that's purely based on the historic speed at which transactions leave the
mempool.  So, it only uses transactions that the node saw in its own mempool and
measures how long it took from them arriving to getting mined.  So, it's a very
different approach than looking at what is currently in the mempool and getting
added and projecting from there.  Well, that's what I had on the top of my head.
Mike, do you have anything else?

**Mike Schmidt**: Yeah, just I wanted to encourage folks, the post on Delving
links to the open-source code from Lauren and her team.  There is also reference
to a public API endpoint that you can query.  The source code for WhatTheFee is
linked there.  There is a post from Abubakar that's referenced, and there is a
post from Block's engineering team that is referenced.  So, there's a ton of
information about this for folks who are curious about this kind of discussion
to dig deeper.  Lauren, is there anything that you'd like to have as a call to
action for folks, or something to wrap up?

**Lauren Shareshian**: Yeah, the feedback we've gotten so far we've appreciated
so much.  So, anything else, we'd appreciate as well.  Thank you so much.

**Mark Erhardt**: Well, thank you for your time.

**Mike Schmidt**: We appreciate your time, and yeah, you're welcome to hang on
for the rest of the newsletter or you're free to drop obviously if you have
other things to do.

**Lauren Shareshian**: All right, thanks.  Bye.

_Bitcoin Core 29.1rc1_

**Mike Schmidt**: Releases and release candidates.  We have Bitcoin Core
29.1rc1, and there was a few notable items that I saw in the release notes here.
Murch, you probably have some as well.  But in terms of notable changes, at the
top is mempool policy.  We covered Bitcoin Core PR #32521 previously, which
essentially limits the pathological transactions in legacy sigops.  Those are
non-standard now.  We covered that, I forget which week that was, but that was a
recent discussion.  We also talked about the dbcache values for 32-bit operating
systems and why it's a good idea to cap those and the bad things that can happen
if you don't.  There's over a dozen tests, a dozen build-related PRs, a dozen
doc-related PRs.  Did you see anything else in there, Murch?

**Mark Erhardt**: No, that's a great summary.  Maybe the one thing that I
noticed was in the, oh, sorry, no, I'm mixing this up with one of the PRs below.
Never mind, sorry!

_Bitcoin Core #29954_

**Mike Schmidt**: Sure, Notable code and documentation changes.  Bitcoin Core
#29954, which adds two fields to Bitcoin Core's getmempoolinfo RPC.  So, calling
Bitcoin Core's getmempoolinfo RPC returns a bunch of information about the
mempool, including size, memory usage, total fees, etc.  But also returns relay
settings, like fullrbf and the node's minimum relay fee for transactions.  This
PR that we're covering this week will also include two new relay settings.  One
for permitbaremultisig, which is a true and false based on if the node's mempool
accepts transactions that are bare multisig outputs; and a second field will be
returned from that RPC, which is maxdatacarriersize, which is the number of
OP_RETURN bytes that the node will allow in the mempool.

**Mark Erhardt**: And that was the PR that I was thinking of.

_Bitcoin Core #33004_

**Mike Schmidt**: Got it.  Bitcoin Core #33004 will now default Bitcoin Core
nodes to automatically open ports on the node's network router to allow for
inbound connections.  When you run your Bitcoin Core node at home, for example,
you'll see outbound connections; but unless you configure your router to open
ports to go to your node, you won't see any inbound connections.  And in earlier
versions of Bitcoin Core, this automatic port-opening feature was available and
used the miniupnp library.  But after multiple vulnerabilities involving that
miniupnp library, including remote code execution attacks, the feature was
disabled.  You can check out on our CVEs Topic Page and search for miniupnp to
see a few of those that we've covered.  But last year, Bitcoin Core merged PR
#30043, and that was an in-house implementation that achieved a similar feature
of opening router ports.  And that feature at the time, last year, was disabled
by default, partially waiting on additional testing.

Well, this PR today is simply enabling that in-house port-forwarding feature in
Bitcoin Core by default.  One thing I'll quote from the description, "The upside
of turning this feature on by default is, if most ISP default provided router
support is supported by default, a much more diverse P2P network will emerge.
The downside is an increased attack surface.  A vulnerability affecting only
listening nodes would now expose people's node at home".  Murch, any thoughts?

**Mark Erhardt**: Well, people have been long worried about the low count of
Bitcoin nodes.  And one of those related topics there is, how many listening
nodes are there in the first place, or how many nodes are there, because we can
obviously only easily find the listening nodes?  So, if more nodes by default
were able to accept inbound connections by opening these ports on their routers
or ISPs enabled by this protocol, we might see a huge jump in listening nodes as
this feature rolls out to people.  I believe that by default, all nodes start in
listening node, and of course listening nodes have a little bit more bandwidth
consumption because they, for example, help peers bootstrap with the blockchain
and serve light clients.  But it would also distribute that traffic that is
currently only on the currently visible listening nodes to to these new nodes
that would come online.  So, hopefully this would just make the Bitcoin Network
overall more robust if more nodes appear on the network with listening
capability.

_LDK #3246_

**Mike Schmidt**: LDK #3246 is a PR titled, "Enable Creation of Offers and
Refunds Without Blinded Path".  Now, LDK already has the ability to handle
BOLT12 offers and refunds without blinded paths, but until this PR, there wasn't
an easy way to create them.  So, this PR gives LDK users full control over how
the blinded message path is constructed, including the option to omit the
blinded path entirely.  Discussion of the PR noted, "This is also useful for
testing or when alternate privacy strategies are needed."

**Mark Erhardt**: It's really neat to see how over time, all of these little
parts fall into place.  And who knows, well, I don't know the exact timeline,
but hopefully by the end of the year or next year, we'll broadly have blinded
path and BOL12 offer support across the ecosystem.

_LDK #3892_

**Mike Schmidt**: LDK #3892, this PR includes two commits.  The first adds an
OfferId to all BOLT12 invoices, linking invoices to their originating offers.
And then, the second commit makes the BOLT12 offer merkle tree signature
available in the public API.  Now, for that second piece, it could be a useful
feature for developers that are building command line BOLT12 offer tools that
need to verify the signature of BOLT12 invoices or recreate invoices.  And
another noted use case was learning tools, where having that information would
be helpful.  And there was some slight back and forth on whether this particular
API, public API for the offer merkle tree, should be something within LDK, but
they ultimately decided that it was.

_LDK #3662_

Last PR this week, LDK #3662, which implements LSPS05, which is Lightning
Service Provider specification number 5, which is also the Bitcoin Lightning
Improvement Proposal 55 or BLIP55.  Both of those specs detail how LSPs should
handle webhooks.  That's usually something used when the LSP is interacting with
a usually mobile device and usually a mobile wallet, and needs to send a
notification to that mobile client without the mobile client having to
continuously pull the LSP for updates.  So, you provide a URL that can be
essentially pinged when certain activity happens.  Some examples of those such
push notifications might include an incoming payment, a BOLT onion message,
changes to the LSP that they're making in terms of liquidity for that particular
user, and then there's some other examples as well.  And this LDK PR is actually
a complete implementation of that LSPS05 spec, although I did see some minor
follow-up related PRs.  It was all done in one bang.

I think that's it for this week, Murch.  Just about two hours.

**Mark Erhardt**: Yeah, big one.

**Mike Schmidt**: Well, we want to thank our guests for joining us, Tim, Steven,
Jameson, Lauren, and David for their time, some of them hanging on and listening
to the podcast along with you all.  And thank you to Murch as co-host this week
for taking time out of his day for you all and for you all for listening.

**Mark Erhardt**: Hear you soon.

{% include references.md %}
