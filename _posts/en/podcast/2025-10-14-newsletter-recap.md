---
title: 'Bitcoin Optech Newsletter #375 Recap Podcast'
permalink: /en/podcast/2025/10/14/
reference: /en/newsletters/2025/10/10/
name: 2025-10-14-recap
slug: 2025-10-14-recap
type: podcast
layout: podcast-episode
lang: en
---
Gustavo Flores Echaiz and Mike Schmidt are joined by Sindura Saraswathi,
ZmnSCPxj, and Eugene Siegel to discuss [Newsletter #375]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-9-17/409446744-44100-2-cb3a83c6f7b1a.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #375 Recap.
This week we're going to be covering research into threshold signature usability
versus security, and looking at the trade-offs there and some research; we're
going to talk about flattening nested threshold signatures into a single layer
and potential issues around that; we also have a news item on the theoretical
limits of embedding data into the UTXO set; and we have our Releases and Notable
code changes.  This week, I'm joined by a different co-host.  We have Gustavo,
Optech contributor, and he's been doing the Notable code segments and has joined
us the last few weeks on the podcast.  You want to say hi, Gustavo?

**Gustavo Flores Echaiz**: Hi, everyone, happy to be here.

**Mike Schmidt**: Yeah, thanks for your time.  Thanks for stepping up to
co-host.  I think Murch is having some other Bitcoin fun at some conferences, so
we'll fill in for him in the meantime.  Gustavo and I are joined by a few
special guests.  We have one that is a late arrival, but we've started
regardless.  Our first one, Sindura, you want to say hi to folks and introduce
yourself?

**Sindura Saraswathi**: Yeah, sure.  Hi, my name is Sindura Saraswathi, I'm a
PhD student and I work on Lightning and Bitcoin research.

**Mike Schmidt**: Awesome.  ZmnSCPxj?

**ZmnSCPxj**: Hi, I'm ZmnSCPxj, I'm just a randomly generated internet person,
previously a wannabe Indie game dev who got suckered into buying bitcoin, and is
now using skills to hack apart the game rules of all of your protocols and win
all the money in the world.

**Mike Schmidt**: Awesome.  Thanks for joining.  And we have Eugene.

**Eugene Siegel**: I'm a Bitcoin Core Contributor and I'm sponsored by Brink.

**Mike Schmidt**: Well, we have one more special guest today, I hope he's going
to join us.  We will skip over his news item if we get there, but we'll jump
right into the News section.

_Optimal Threshold Signatures_

The first news item is titled, "Optimal Threshold Selection for Multidsig", and,
Sindura, you posted to Delving about modeling the trade-offs between usability
and security in threshold signatures.  You introduced different ways to think
about the trade-offs there and combining them into trying to achieve an optimal
threshold across different scenarios.  Maybe you can give us the one-on-one on
at least how do you define usability in security in a threshold signature
context, and then maybe you can get into some of your findings?

**Sindura Saraswathi**: Yeah, sure.  I can summarize the research.  So, we have
seen that in Bitcoin, threshold signatures are a common method for securing
funds.  This is an m-of-n scheme where the user needs at least m signatures to
unlock the funds that are secured by n keys.  Now, the questions are, what
should be the optimal threshold for an m-of-n scheme, and when it should be low,
when it should be high, and how it should change over time.  So, our research
addresses these questions by formulating the design of threshold signature
scheme, including the degraded multisignature scheme.  And we studied this
problem in a more security context, where we assume that there is a malicious
attacker, with some probability, is trying to steal the funds from the user.
And the user selects the threshold that trades off two forces.  One is the
benefit of preventing the attacker from stealing the funds, which we call
security; and then the other one, or the second one, is the cost of also locking
out of his own funds for the user.  That is like self-lockout, which we kind of
formulate using usability.

**Mike Schmidt**: Maybe just to clarify, sorry to interrupt.  Security part
makes sense.  The usability is focused on not necessarily the coordination of
many parties to do this, or the actual interface to do that coordination, but
strictly about the risk of being locked out.  Do I have that right?

**Sindura Saraswathi**: Yes.

**Mike Schmidt**: Okay.  All right, sorry, continue.

**Sindura Saraswathi**: For the user that we are defining it for now.

**Mike Schmidt**: Makes sense.

**Sindura Saraswathi**: So, the optimal threshold will balance the security and
usability, or it kind of balances the benefit of security against the cost of
usability.  And I will try to explain the model very briefly.  In our model, the
goal is to minimize the total expected loss, that is the combination of the user
loss or the self-lockout loss and the loss caused by the attacker stealing the
funds.  So, we minimize this loss across four states of the world.  The first
state is when the user is having access to the funds and also attacker is having
access to the funds.  So, this leads to 50% chance of losing the funds.  And the
second case is when the attacker is having access but the user is not having
access.  This is like total loss of funds.  And the third case is the user is
not having access and attacker is also not having access.  This is again total
loss of funds for the user.  And the last and the final state is the user is
having access but the attacker is not having access.  This is like, there is no
loss at all, zero loss.

Then, we define a parameter for security and a separate parameter for usability.
And then, using these parameters, we define probability for the user and
probability of attacker accessing the funds.  And then, we solve the
optimization problem, and then come up with a closed-form solution for optimal
thresholds in terms of those parameters that we define.  And then, we observe
that increasing security or usability leads to higher thresholds.  So, this
might seem counterintuitive, right?  For example, placing keys in a safe
decreases the attacker probability, and one might think to relax the thresholds.
But think of it like placing the signatures or keys in a safe decreases the
attacker probability, and this makes the higher threshold cheaper, and the user
can afford to have higher thresholds.  And similarly, in terms of usability, for
example, user embosses private keys onto a titanium plate that is fireproof, and
the user can have access to the funds even in case of fire.  This is increasing
their usability, so the user can increase the threshold even in this case.

So, this is the first part of our research and as a second part, we modeled the
dynamic multisignature scheme, already graded multisignature scheme, and
specifically an end-stage degraded multisignature scheme.  And we know that over
time, the probability of the user and attacker changes.  In one case, the
probability of both attacker and user decays over time; and in another case, the
probability of user decays, but the attacker gains access because the keys can
be compromised over time.  So, we solve for optimal thresholds and optimal
timelocks at which the threshold changes in every stage, and then we see that
the optimal threshold degrades, that is the previous threshold is always greater
than the current threshold, and in terms of timelock, it increases in security
and usability.

This analysis, we feel it is relevant in guiding which scheme is superior to
others, especially when it comes to complex spending conditions.  Yeah, this is
about the research.

**Mike Schmidt**: And for listeners, Sindura is mentioning this idea of
degrading multisig.  I know folks have different words for this.  I know some of
the products in the market refer to it.  I think Liana has something like this,
where after a certain period of time, the threshold of keys changes.  You could
do things like inheritance with this.  I think the word, 'inheritance' is often
thrown around.  And like Sundara mentioned, the timelock can facilitate that,
making those spending conditions only available after a certain period of time.
Sindura, one thing that you mentioned that, well, I guess maybe broadly, if I
was a listener, I'd be curious.  So, what's the right answer?  Is there one
right answer?  Is there a website where I put in security?  Do I put certain
things in and it spits out an answer?  Or is there something practical that
folks can take away?

**Sindura Saraswathi**: Yeah, of course.  So, we have also mentioned that in our
paper, we have a closed-form solution for the assumptions that we made.  But of
course, there is always a future where you can adapt that closed-form solution
for a more realistic probabilistic model.  So, for now, if you can give me the
security and usability numbers, I can give you what has to be the threshold.

**Mike Schmidt**: Okay, that makes sense.  And I think you touched on this
towards the end, but I had in my notes that I pulled out here that you touched
on how taproot and taptrees can enable more flexible constructions.  Is that
just baked into the research, or is that a separate area to explore more on?

**Sindura Saraswathi**: So, with that, we mean that with taproots, we can
obviously have a lot of complex spending conditions, right?  Like, when you
design a taptree with lots of depth, then you have a lot of complexity involved
in terms of timelock in terms of these thresholds.  And then, even in future
when we have, say, AI agents interacting with each other in taproots, then these
schemes can be very helpful, and it is important in terms of negotiating the
contracts or some sort of complex spending conditions.  That's what we mean by
saying taproot, and also future direction towards that.

**Mike Schmidt**: Makes sense.  Obviously for us as bitcoiners, we see this
research on Delving.  I'm curious as to what the feedback's been on Delving, but
also the fact that you're an academic, you probably have access to a different
audience than would just be on Delving.  I'm curious if you've gotten feedback
from either or both sides on the research so far?

**Sindura Saraswathi**: Yes, so with Delving, of course, I got some feedback
right there.  And also, with academic audience, I also presented this research
at Stanford, and also understood from their perspective how exactly this can be
modeled in terms of more realistic way, and also empirically model this further.
So, yeah, that's going on, and we are trying to publish this as well.

**Mike Schmidt**: Okay, oh, so it's not published yet, it's still draft?

**Sindura Saraswathi**: Yeah, it's under review.

**Mike Schmidt**: Okay, understood.  You've hinted at a few things, but is there
an idea of where future research direction might go?

**Sindura Saraswathi**: So, we want to adopt some more realistic probabilities
and make it more usable, and also, say, we also try to concentrate on taproot
specifically, and also having AI agents interacting, negotiating and using these
kinds of modeling to negotiate.  So, that's in our mind at the moment.

**Mike Schmidt**: All right.  Gustavo or Eugene or ZmnSCPxj, you're free to ask
any questions as well.  That's everything that I had.

**Gustavo Flores Echaiz**: Yeah, well, I guess you say this is very conditional
to real-life conditions, right, and it would vary depending on the use case.
But so, do you think there could be, with time, a tool that users could use to
sort of try to insert their conditions and then get recommendations based on
that?

**Sindura Saraswathi**: Yeah, of course.  That would be also another goal to
make it more viable, and also the user just telling the conditions, like, "We
have this sort of environment and we want this as our security and we want this
as our usability".  Then, there will be a recommendation system based on this
model, which will recommend the user to set the particular threshold for a given
condition.  So, that's also the end goal of the research.

**Gustavo Flores Echaiz**: Very interesting.  Thank you.

**Sindura Saraswathi**: Thank you.

**Mike Schmidt**: All right.  Well, I think we can wrap up that news item.
Sindura, any parting words or calls to action for folks who may be listening and
curious?

**Sindura Saraswathi**: I mean, thanks for having me here, and also I would also
be interested to hear feedbacks and also incorporate some of the things that we
see.  It is very important for the community at the end of the day.

**Mike Schmidt**: All right.  So, if this is interesting for you, you're a
wallet dev or researcher, check out the linked Delving thread from the
newsletter and give Sindura some feedback.

**Sindura Saraswathi**: Yeah, sure.  Thank you.

**Mike Schmidt**: Sindura, thanks for your time.  Thanks for joining us.

**Sindura Saraswathi**: Thank you.

**Gustavo Flores Echaiz**: Thank you.

_Flattening certain nested threshold signatures_

**Mike Schmidt**: Next news item, "Flattening some nested threshold signatures".
ZmnSCPxj, you posted to Delving a post titled, "Flattening Nested 2-of-2 Of a
1-of-1 And a k-of-n".  That's quite a title.  If I'm understanding correctly,
you're looking at nested spending conditions and then reframing it as a single
threshold group.  If that's correct or not, I guess maybe help explain that for
me and listeners.

**ZmnSCPxj**: That's quite correct.  So, one of the things I've been doing in
the background or thinking about in the background is that of nested k-of-n
inside k-of-n, or more generally, yeah, nested k-of-n inside of k-of-n,
especially in terms of what we can do for LN, which is that LN is typically a
2-of-2 for a channel.  And it's possible that one of those participants is
actually not a single entity, but rather a k-of-n aggregate group.  And that's
one of the things that I've been thinking of in the background.  And that's why
long before, when Bitcoin-Dev mailing list still existed, I brought up the
concept of nesting a MuSig2 inside a MuSig2, or nesting a nowadays, what would
be FROST inside a FROST or FROST inside a MuSig2.  And basically, every
cryptographer that I've talked to about this has said that we don't have a proof
that this kind of nesting is at all safe, and we know how to do the math.  The
math to do this is trivial, but whether it is actually safe to do this
security-wise, nobody actually knows yet.

So, since that isn't known yet, I came up with this sort of stopgap solution,
which is to flatten this specific nested case into a single-layer k-of-n.
Because at least the single-layer k-of-n, we do have a proof in the FROST paper
that the FROST implementation of a k-of-n is safe within certain limits.  So, as
long as we hit those certain limits, then we can emulate this sort of nested
1-of-1 with k-of-n with a single layer of k-of-n possibly with FROST.  Or if
that's not possible, then we fall back to using at least just a single layer of
k-of-n CHECKMULTISIG, or in taproot would be CHECKSIGADD.

**Mike Schmidt**: Okay, so FROST has a proof, I guess I could phrase it that
way; MuSig2 has a proof; but what you're concerned with is if you have a MuSig,
it's a 3-of-3, and then each of those three potentially has a threshold
underneath it where it's 3-of-5.  So, there's three 3-of-5s essentially that
roll up into that MuSig, and that the interplay between FROST and MuSig in that
example is where there's no proof, and so you're working around it.  Is that
right?

**ZmnSCPxj**: Yeah, that sort of thing has no proof yet.  Even the simple MuSig2
inside MuSig2 does not have a proof yet either.  So, all the cryptographers I
talk to when they ask about this, they say, "Yeah, it's possible to do the math,
it's probably safe to do this, but we don't have a proof yet, so don't quote me
on that".  That's what they all say to me.  So, this is a very specific single
case that we can flatten.  Like, in the general case of a MuSig2 inside a
MuSig2, we can always flatten that trivially because we just flatten it to a
single layer where everybody signs with everybody there.  The thing here is that
it leaks privacy because now, you need to reveal how many participants each
group actually is.  You can't pretend that, "Oh, we're a single entity".  There
are actually multiple entities doing this and you're all signing as a single
end-of-end layer as part of the larger group.  And everybody kind of finds out
that that's all of you.  And because each of you in the MuSig2 case has to
reveal your public keys, you need to list down all of your public keys.  So,
that's a loss of privacy.

Again, also with this, there is also a loss of privacy where one of the
participants is a k-of-n, and we can make this trick where the 1-of-1
participant in this specific case holds multiple shares of the larger k-of-n.
And it reveals, of course, to everybody who the k-of-n is and how large that
k-of-n is, so they can't pretend to be a single one.  But it at least lets us
emulate this kind of setup where one part is k-of-n and the other part is a
1-of-1.  And those are just the two participants overall in this overall nested
setup.

**Mike Schmidt**: What end-user use case do you have in mind as like a canonical
example for people to wrap their brains around?  Is this something like a
custodian or something, where you would need all of this sort of complicated and
many parties; or are you just thinking about it really more theoretical?

**ZmnSCPxj**: Mostly, it's theoretical, but we did have a few times this year
that we came up with possible plans to do something like this, where one side is
a 1-of-1 and the other side is a k-of-n.  For example, one of the use cases that
we considered is a custodial scheme, based on RGB or something similar or any
kind of colored coin scheme, where because the custodian is required to be able
to freeze funds, they need to be able to say, "Oh these funds, I will not allow
you to spend it".  Now, in a typical colored coin scheme, the ones who actually
control the inclusion of a transaction is the miner, right?  So, it's the miner
who says, "Okay, I'm going to let this signature through because it pays me
these bitcoin fees, and I'm going to put it on the block I'm constructing".  And
the problem now is that the custodian might be required by law to say, "I am
able to freeze these funds and not allow them to be moved, and that ground
requires me to be always a signatory in every transfer".

So, the most basic case, for example, is that the owner of the funds is a k-of-n
and we have the custodian, who is required by law to sign off on any of those
transfers, is now a single-sig of a 2-of-2 between them.  So, in order to spend
this custodial fund, the k-of-n user has to provide their signature, and also
the 1-of-1 user, which is the custodian itself, who is required by law to be
able to freeze funds, will check, "Hey, is this fund frozen or not?"  And if
it's not frozen, then it will also provide the signature and create this
combined signature to allow the transfer to be done on the blockchain, and
miners can now mine it.  So, that's one example.

Another example is that of using statechain operators, where semantically
speaking there are two owners, the statechain operator and the current owner of
the funds.  Now, what we want to do is that the statechain operator is not a
single entity but rather a threshold, such that if there is a k-of-n threshold
for the statechain operator, then at least n - k + 1 need to be deleting their
old keys so that the statechain operation is always forward only and you can't
roll back to the past.  Now, the intended mechanism to implement this is, of
course, some kind of verifiable secret sharing scheme.  And none of those are
safe in the setting where you have an n-of-n, where the other side is a
single-sig owner, which is the user of our statechain, versus the statechain
operator, which has to be k-of-n in order to diffuse the trust requirement.  And
that's not actually proven, there's no proof yet, because as I understand it,
any proof that this is safe can probably be transformed to a proof that FROST in
MuSig2 is also safe.  Because FROST is basically using a Verifiable Shamir
Sharing (VSS) underneath.  So, if that can be proven to be safe for a general
VSS, then that probably can be transformed to a proof that FROST in MuSig is
also safe.

So, by flattening this statechain operator example also, we can also flatten it
to a single layer and we know that VSS works; well, some VSS schemes work at
this single layer.  So, those are two examples that came up this year, and so
it's happened twice, so that's why I put the note on Delving Bitcoin, because it
might happen a third time.

**Mike Schmidt**: Yeah, those cases make sense, one, the custodian needs to
co-sign essentially; and then, the second one is the statechain application.
How's feedback been?  I see that Waxwing has replied.  Unfortunately, he isn't
here.  I thought he would be here to opine on this himself, but maybe you can
digest what his thoughts were.

**ZmnSCPxj**: Well, it's mostly that it's pretty much just directly logical
math.  There's no number theory, there's no information theory.  This is just
pure, simple logic that you can actually do this.  It's more of nobody has tried
doing it before because nobody was trying to figure out how to get around the
limitation of not having a proof of this k-of-n inside n-of-n, or something like
that.  So, it's possible to do this using this scheme where you increase the k
and the n and you have the 1-of-1 user have multiple shares in this k-of-n.  And
that works out to actually being equivalent to it logically.

**Mike Schmidt**: That makes sense.  I think, unless there's anything you'd want
to add, ZmnSCPxj, I think we can wrap up.  Any calls to action from the
audience, other than taking a look at your Delving post and if there's a
cryptographer coming up with a proof?

**ZmnSCPxj**: Yeah.  Cryptographers, please come up with a proof that k-of-n
inside of k-of-n is safe.

**Mike Schmidt**: I'm sure we'll just get that done.

**ZmnSCPxj**: I heard there's people working on it, but it's math.  This is not
something that you can show progress on.  It's more like we're kind of waiting
for some insight, a flash of insight.

**Mike Schmidt**: Gustavo, anything before we wrap this one up?

**Gustavo Flores Echaiz**: All good.

**Mike Schmidt**: All right.  ZmnSCPxj, thanks for joining us, you're free to
drop.

**ZmnSCPxj**: Bye.

_Compact block harness_

**Mike Schmidt**: See you.  We are going to temporarily skip the third news item
about embedding data in the UTXO set, and move to the Bitcoin Core PR Review
Club, which is a monthly segment that we do highlighting a discussion that that
group has, and covering it in depth in this newsletter.  So, this week, we have
the PR titled, "Compact Block Harness" and it's a PR by Eugene who's joined us
this week to talk about it.  Eugene, my understanding is that the PR expands
fuzz coverage of Bitcoin Core, specifically around compact block relay logic.
Maybe it makes sense for users to hear from you what is fuzzing, and then maybe
we can get into what harnesses are and what you've added here.

**Eugene Siegel**: Fuzzing is, at least in the way that we're using it, a way to
provide random inputs and test parts of your codebase.  And usually, the two
fuzzers we're using are libFuzzer and AFL or AFL++ compiling the Bitcoin Core
program, there's like a bunch of instrumentation added.  So, there's like a
bunch of extra stuff that the compiler adds.  That's kind of like a problem
because it can also happen later now that they compiled that.  But there's a
bunch of instrumentation that is added so that the fuzzer gets feedback about
what data hits in the program.  So, it's like a feedback loop.  And so, the
fuzzer provides these random inputs, and then it sees that it gets further in
basically the maze of Bitcoin Core, and then it mutates those inputs further to
get even deeper.

**Mike Schmidt**: Eugene, I was just sending you a message.  Your mic is cutting
out a little bit here and there, at least for me anyways.  But I think we got
the thrust of it.  My thoughts generally are throwing quasi-random inputs at
functions to see if you get some sort of weird result.  And so, I guess the idea
then would be we want as many of those fuzz tests as possible and as much
codebase as possible as well.  Based on the fact that this one is talking about
compact block harness, was there no fuzzing for compact blocks previously?

**Eugene Siegel**: There was fuzzing in one part of the compact block area, but
none of the net processing code.  So, none of the actual P2P part that is
processed from the peer.  And I just looked at the existing coverage, and then I
noticed that there was basically none.  And so, I decided to write this fuzz
test.

**Mike Schmidt**: Okay, excellent.  Now, obviously, during the PR Review Club,
there's a bunch of questions that are seeded for participants to think about
beforehand, and then answered during the meeting.  Are there things that came up
either in that discussion of the PR Review Club, or just interesting things as
you were implementing this harness that you think would be interesting for
listeners?

**Eugene Siegel**: Yeah.  I came up with I don't know how many different
approaches to do this.  I think probably eight or something.  It was a little
ridiculous.  And the issue is that the normal way that we write fuzz tests in
Bitcoin Core is usually, we mine a regtest chain of 200 blocks, and then we
process messages or something, and we keep that chain around.  But that doesn't
work for this harness, because if the fuzzer creates a valid block, then the tip
has advanced, and so instead of being at tip 200, we're now at tip 201.  And
then, further iterations of the fuzzer might think that we're at tip 200 rather
than 201.  And basically, there's a lot of non-determinism to do things this
way.  And so, what I had to do was each iteration of the fuzzer, I had to
basically copy the data directory that was created initially.  And people
pointed this out in the PR Review Club, like, "Why are you doing this?  This is
confusing", and stuff like that.  They weren't negative at all, but it was very,
I guess, not how we typically do things in Bitcoin Core.  But it's necessary
because if you don't do this, then each iteration pollutes the global state and
then your fuzzer is basically useless.  So, that was one of the things that came
up.

**Mike Schmidt**: Well, help me understand.  So, the mitigation then was to just
use the same set of blocks all the time, or how do you get around that
non-determinism?

**Eugene Siegel**: Yeah, so in the very start of the fuzz test, it mines 200
blocks, and then each iteration of the fuzzer, it copies that data directory,
instead of using the same one that was created initially.  Does that answer your
question?

**Mike Schmidt**: Yeah, I think so.  Anything else come up as you developed and
went through the PR Review Club?

**Eugene Siegel**: Yeah, people pointed out that some coverage was missing.
They pointed out that there's not really coverage for something called short ID
collisions.  And if you don't know, in BIP152 compact block relay, you relay
these short IDs across and it's possible that they can actually collide, like
two transactions could have the same ID.  And I wasn't really sure how to get
coverage for this because it's kind of random.  Short of grinding out
collisions, I didn't think that it was possible to actually get coverage for
this.  But I think David Gumberg did point out that it was possible.  I think we
just need more iterations and more transactions to hit that.

**Mike Schmidt**: Okay, yeah, makes sense.  Do you think that the
non-determinism was part of the reason that there wasn't originally, maybe not
originally, but there wasn't earlier a harness created for compact blocks like
you've created?

**Eugene Siegel**: Yeah, I think so, I think that's one of the reasons.  And I
think if someone had tried to make a harness truly non-deterministic, they would
have run into one of the issues that I had, was if you mine a new chain every
iteration of 200 blocks, you get I think literally half an execution per second.
And I just think that that's not really a useful harness if it's getting so low.

**Mike Schmidt**: Give us some context.  On an average Bitcoin Core harness, how
many executions are you getting per second to compare?

**Eugene Siegel**: It can vary.  Some could be thousands.  I think some of the
very quick ones are thousands, and then some are maybe 50 to 100.  But yeah, so
definitely much higher than I was seeing zero.  It said zero because it rounds
down.

**Mike Schmidt**: Okay, yeah, so 100 or 1,000 times slower for that particular
approach.  Okay.  And yeah, it's all about throwing a lot of inputs.  And so,
the slower it is, the either longer it's going to "take", or you won't find
things as sooner.  Maybe talk to the audience about, when you're fuzzing, do you
run this locally, or do you have some sort of a server that you use?

**Eugene Siegel**: Yeah, so I initially was just running it locally on my Mac
work computer.  But when I would try to do other things on the computer, my
computer would just get too slow.  So, I have a server and I just run it on, I
think it has 16 cores or something like that.  And then, it's much better than
doing it locally.  Plus, with Mac, there are all sorts of issues that people
have experienced with fuzzing with the various compilers.  So, I would not
recommend fuzzing on Mac if you have the option to.

**Mike Schmidt**: If folks are interested in, and I've always touted this,
getting into testing, I think a lot of people got into Core development through
the functional test, maybe not the fuzz test; but if folks are curious about
what this fuzzing thing is all about and want to play around with it, is there a
resource on the repository or some website that people can go to, to learn more?

**Eugene Siegel**: Um, yeah, so in the docs folder, I think it's doc/fuzzing/md.
There's a README on how to compile Bitcoin Core with libFuzzer and AFL++.  So,
that's a really good resource.  And if that's not enough, then I would probably
say the AFL++ GitHub page.  And there's all sorts of READMEs and stuff in there.

**Mike Schmidt**: All right, excellent.  Anything else for the audience or calls
to action before we move on, Eugene?

**Eugene Siegel**: Well, I don't know if this is really for the audience, but I
think we need more fuzz testing of the P2P code.  And so, yeah, if anyone wants
to help with that, that'd be great.

**Mike Schmidt**: Well, I'm glad we have you.  Hopefully, we can get more.  It's
funny when we have the folks who do this sort of fuzzing work, like Matt
Morehouse, on, yourself, it's hard for folks to hold back just, "Hey, we need
more of this testing".  I think partially, I know in your case, you've found
bugs in Bitcoin Core.  Previously, Matt Morehouse has found bugs in LN
implementations.  And so, I think being the one to be able to find these, and
sometimes these aren't even very -- they're shallow kind of bugs, sort of gets
you in the position where you want to encourage others to come join you and help
find these as the good guys, right?

**Eugene Siegel**: Yeah, pretty much.

**Mike Schmidt**: All right, well, thanks for joining us.  Thanks for your time,
Eugene.

**Eugene Siegel**: Thanks for having me.

_Theoretical limitations on embedding data in the UTXO set_

**Mike Schmidt**: We're actually going to jump back up in the newsletter.  I was
killing some time hoping that Waxwing was going to be able to join us.  That was
the plan.  And so, I am less prepared than I normally would be, thinking that he
would explain this news item.  But hopefully, Gustavo and I can grind our way
through it.  "Theoretical limitations on embedding data in the UTXO set".  So,
Waxwing started a discussion on the Bitcoin-Dev mailing list about how much
arbitrary data could you hide in the UTXO set, given a restrictive rule that
each P2TR output must prove spendability with a signature?  So, even in a
somewhat restrictive environment compared to what we have now, can you still get
data in?  And so, I think that the title of his post is maybe a little bit more
descriptive.  I'm clicking into it now, "On the (in)ability to embed data into
Schnorr".  And so, he posted to the mailing list, and he has three different
avenues that he sees that you could still, under this restriction of even having
a spendable output that you had to verify the spendable, there's still three
avenues to embed data into the UTXO set.

The first one, he notes as, "Bitcoin's version of schnorr signatures is broken".
Obviously, that's not the case.  So, that's not the route that he's pursuing
here.  But obviously, if schnorr signatures were broken in some way, there would
be a way to embed arbitrary data that way.  And then, the second one, "A small
amount of arbitrary data could be embedded by grinding the public key".  So,
folks may be familiar with like a vanity Bitcoin address, sort of like the
similar idea where you keep generating many addresses until you get one that
starts with, "1mikeschmidt" or whatever, and that's your vanity address.  So, I
think the idea is similar here, except for instead of going for something like
your name, you would put some arbitrary data in the public key, maybe not the
address itself, but the public key.  And then, you would just throw away all of
the data, all the addresses or public keys that didn't contribute to the data
that you were trying to embed in the UTXO set.  So, that was number 2.  And
then, number 3 was, "Using a private key that can easily be calculated by third
parties as a form of, 'leaking your private key'".  And then, he gets into a
little bit more about that third case.

Before we jump into some of maybe the responses on the mailing list, Gustavo, do
you have anything to add there?

**Gustavo Flores Echaiz**: Yeah, so basically his note demonstrates that these
are the only three ways you could insert data.  And the second item, the
grinding one, is kind of ignored in his longer-form note, because you could only
embed a few bytes at best.  So, it's not much of a useful use case.  However,
the third case, the revelation of the secret key material, he emphasizes that
although this note, his note that he wrote cannot prove that the data cannot be
embedded, he can prove that embedding the data reveals the secret witness, of
the key, right?  So, yes, you could use this to embed data, but then your UTXO
would be spendable and it would be removed from the UTXO set.  So, yeah, I
thought it was an interesting thought exercise he did here.

**Mike Schmidt**: Yeah, and maybe just quoting a bit from AJ Towns, who was one
of the folks who replied.  I think also Greg Maxwell and Andrew Poelstra were on
there, I think Peter Todd.  So, if you're curious about their feedback, some of
which has come in after we published the newsletter, check out the Bitcoin
mailing list post.  But I'm going to quote AJ's quote here, "Once you make the
system programmable in interesting ways, I think you get embeddability pretty
much immediately.  And then, it's just a matter of trading off the optimal
encoding rate versus how easily identifiable your transactions can be.  Forcing
data to be hidden at a cost of making it less efficient just leaves less
resources available to other users of the system though, which doesn't seem like
a win in any way for me".

So, I think this touches on, you know, I don't think they say this directly, but
obviously there's a lot of discussion about arbitrary data in Bitcoin right now.
And I think maybe one thing that some folks have emphasized, but maybe hasn't
been widely discussed, at least it isn't a dominating narrative on social media,
is what AJ alludes to here, which is once you have arbitrary scripts, which
Bitcoin has, you can lock up your bitcoins in an arbitrary set of ways.  Once
you have that sort of programmability and that arbitrary scripting capability,
that really arbitrary data kind of follows from that.  And we can see that here,
even in this sort of contrived system that Waxwing outlined, where you have to
prove actually that it's spendable, that there's spendable outputs.  And even
then, you can still have arbitrary data.  And so, I think that's what AJ is
getting at.  And I think that's somewhat one of the tenets of the discussion
about arbitrary data online recently, is just, "Hey, there's infinite ways to do
this.  And so, stopping one or two ways, you just end up in this infinite game".
So, that's how I would maybe tie it back to some broader recent discussions.
Anything else on this item, Gustavo?

**Gustavo Flores Echaiz**: Yeah, well I mean, I totally agree with you there.  I
would just say, though, that I do think that it was interesting that Waxwing
went into detail of analyzing this specific way of embedding data and figuring
out that there are trade-offs, so it's not like a limitless embedding data use
case.  In this particular one, you would be allowing someone to spend your
output by revealing the private key material to embed that data, right?  So,
just important to note that nuance here.

**Mike Schmidt**: Yeah, and I didn't see it in his write-up, but my first
question for him was what his motivation was for doing this.  So, I guess
that'll have to just be a mystery for now.

**Gustavo Flores Echaiz**: Right.

_Bitcoin Inquisition 29.1_

**Mike Schmidt**: Okay, well, we've covered the News and PR Review Club
segments.  We can move to Releases and release candidates.  We have just one
this week, Bitcoin Inquisition 29.1.  Gustavo, I know you've been helping us
with the Notable code, but you've also now started helping us with the Releases.
Do you want to explain Inquisition 29.1?

**Gustavo Flores Echaiz**: Yeah, certainly.  So, well, Bitcoin Inquisition is a
signet full node software that kind of experiments with proposed soft forks,
such as covenant proposals.  So, this one just is the 29.1 version, basically
just backports what Bitcoin Core 29.1 introduces, which is a new default for the
minimum relay fee at 0.1 sats/vB (satoshis per vbyte).  But it also includes the
larger data carrier limits expected in -- well, now expected when I wrote this
newsletter, but now released in Bitcoin Core 30.  And it also includes support
for OP_INTERNALKEY, which is a new covenant proposal.  If I recall correctly,
OP_INTERNALKEY places the taproot internal key onto the stack.  So, yeah, and
also new internal infrastructure for supporting new forks, probably eventually
more support for covenant proposals, and the infrastructure is built in to
support that.

**Mike Schmidt**: Yeah, I think there's a lot of discussion around covenants, at
least before this OP_RETURN dust-up, that was sort of the thing brewing that
people were interested in discussing and improving use cases for.  And I think a
lot of people have then said, "Okay, well what is it that you would build?  Show
us an example, show us a prototype", something like this.  And I think whether
that's being built on your own local test network or some video demo with
regtest, a lot of people have also said, "Hey, put it on Inquisition.
Inquisition supports some of these proposals.  Not only can you see how CTV
(CHECKTEMPLATEVERIFY) might work for your particular idea or proof of concept or
product, you can see the interplay between CTV and OP_INTERNALKEY, etc".  And
so, I would encourage folks who are working on protocols and also building on
top of new potential protocols, to take a look at Inquisition and see if you can
get something working there.

**Gustavo Flores Echaiz**: For sure.

_Bitcoin Core #33453_

**Mike Schmidt**: Notable code and documentation changes.  I'm going to turn it
over to Gustavo for what we're starting with, Bitcoin Core #33453.  Oh boy!

**Gustavo Flores Echaiz**: Yeah.  Well, actually this PR was written by you.
So, Bitcoin Core #33453 un-deprecates the datacarrier and datacarriersize
configuration options, because many users want to continue using these options,
as we've seen on social media demonstrations but also on GitHub.  But I think
also, I guess the main points here, that apart from the user request, was that
the depreciation plan wasn't clear, there wasn't a version or a date noted for
deprecating these configuration options.  And well, there are just minimal
downsides to removing the deprecation, right?  So, I mean I think you want to
probably add some thoughts here since it was your PR.  You know better about it
than I do.

**Mike Schmidt**: Yeah, sure.  And the funny thing is I wrote the words in the
description for the PR, but the commit and the code changes are not mine.  I
pulled from one of AJ's branches.  So, technically I'm still not a Bitcoin Core
contributor.  But yes, the idea was that it seemed like Bitcoin users were sort
of in this Schrodinger's deprecation, where it was deprecated but not, because
it was clear, well, at least to me and from what some other engineers had said
publicly that, "Well, clearly no one's going to take this out anytime soon".
So, users are in this situation where the words say 'deprecated' and people say
that I can keep using it and will be able to for a while, but at the same time
they're not taking it out.  So, there's sort of the unclear intent of
deprecation, is sort of what I was getting at.  Obviously, that's magnified by
the fact that a lot of people were using it and talking about it, and then also
the final note that you mentioned that there's probably worse footguns in
Bitcoin Core, if folks see this as a footgun, than setting the data carrier
size.  And so, that sort of wraps up the motivation for it, at least.  Does that
make sense?

**Gustavo Flores Echaiz**: Yeah, totally.  And I think it wasn't contentious at
all, right?  I think almost everyone seemed to come in agreement to doing this
also.

**Mike Schmidt**: Yeah, I mean it seems so.  Of course, there's some dissenting
voices.  I mean, something like this is always going to have some dissent, but
it did seem like it had support.  I hope Bitcoin Core users, those who want to
use that option, can continue using it.  And hopefully, if we come to the point
where the Bitcoin Core project and users decide that this isn't worth keeping up
due to maintenance or potential issues, that it can be deprecated with a
schedule next time, especially something that has so many users interested in
it.  And I think another maybe wrinkle to this is it did seem to me in the
comments that a lot of Bitcoin Core engineers saw the definition of deprecation
differently as I think the general public and maybe even myself included saw it.
As someone who's built on top of libraries, when I see deprecated, I think that
means it's going away.  It means you can use it now, but it's going away,
probably in the next version or so.  And I saw Bitcoin Core engineers commenting
more, and there is, if you look up the definition of the word in a software
context, there are multiple definitions, but they were taking it as 'discouraged
for use'.

So, I think that even amplifies the unclear intent to the users that I was
trying to get at, is that if engineers are saying, "Hey, this is really more of
like, we don't think you should use it, but we're keeping it" versus, "Don't use
it and we're going to remove it soon".  The definition of deprecate also
confused people, so you can see that in the comments in the thread, but I don't
want to talk too much about my one and only PR.

_Bitcoin Core #33504_

**Gustavo Flores Echaiz**: Certainly, makes sense.  All right, let's move on.
Bitcoin Core #33504, this one's a PR that skips the enforcement of the TRUC
(Topologically Restricted Until Confirmation) checks that happen during a block
reorganization when confirmed transactions re-enter the mempool, even if they
violate true topological constraints.  So, basically, a TRUC transaction, or a
v3 transaction relay, is a proposal, well now it's implemented, that allows
transactions to opt into a modified set of relay policies designed to prevent
pinning attacks.  So, for example, there are some rules such as you can only
have every TRUC unconfirmed ancestor, if you have a TRUC transaction and you
have an ancestor, it has to be signaling that it's a v3 transaction too, right?

But let's say I have an ancestor that is confirmed of a TRUC transaction and
there's a reorg, and that previously confirmed transaction comes back to the
mempool but it wasn't signaling version 3, then there would be an eviction under
the previous conditions, because it would break the TRUC topological constraint
or rule that says all unconfirmed ancestors have to signal v3.  But that didn't
really make sense on a practical sense, because it wasn't meant that this was
going to get re-orged and this was going to re-enter the mempool.  So, this is
why the enforcements of these checks are now skipped during a block
reorganization to avoid unintended evictions that were previously happening.
Any extra thoughts to add here or I can move on to the next one?  Cool.

_Core Lightning #8563_

So, Core Lightning #8563.  This one defers the deletion of all HTLCs (Hash Time
Locked Contracts) until a node is restarted, rather than deleting them when a
channel is closed and forgotten.  So, let's say I have a channel that I'm
closing and I'm forgetting and I have all the HTLCs that I don't need to have
saved anymore, so I would just remove them at that moment previously.  Well,
that would halt my Core Lightning (CLN) node, all my other processes, and I
could spend a couple of milliseconds or even seconds deleting these old HTLCs.
So, this PR, the first, that deletion to happen when a node is restarted to
improve performance and to avoid halting other processes, right?  So, because
it's unnecessary to do it at the moment where the channel is closed and
forgotten, you can just defer that to another moment so that you don't impact
other processes and you improve your performance.

So, this PR also updates the RPC listhtlcs to exclude these HTLCs, because
previously you would just delete the HTLCs on the spot.  So, when you ran
listhtlcs RPC command, they wouldn't appear because you had deleted them, right?
But because you're deferring the deletion, this RPC has to be updated to make
sure it's not listing the HTLCs that are going to be deleted soon from closed
channels.  So, maybe not as big a change as the previous two, but I think still
important for users of Core Lightning.  Any comments here?

**Mike Schmidt**: Yeah, I mean just a comment, I guess, about when I read at
least the first part of this write-up, I thought, "Oh, the deletion of old HTLCs
is just too inefficient of a process.  They should speed it up instead of just
stuffing it into when a restart happens".  I'm sure there's a better reason to
do it.  Maybe that has to be a long-running, relatively long-running process for
some reason.  But that was just my initial thought.

**Gustavo Flores Echaiz**: I just think, for example, he does a quick test with
50,000 HTLCs, and that took 450 milliseconds.  I think that's about half a
second, so I mean we're still talking very small timelines, but it's still
important here, right?

**Mike Schmidt**: Okay, I see.

**Gustavo Flores Echaiz**: Maybe these are not real-life conditions where you
have 50,000 HTLCs to delete, but at least it's safeguarded against those
potential conditions that you could have.

_Core Lightning #8523_

Let's move on to Core Lightning #8523.  So, this one removes the previously
deprecated and disabled blinding field from the decode RPC that is also present
on the onion_message_recv hook, because it has been replaced by first_path_key
in previous versions.  So, this was a change in the BOLT specification that had
been made in CLN in multiple versions before.  I believe it was deprecated in
v24, disabled in v25.05, and now posted for a removal on 25.09.  Yeah, so this
was just mainly a renaming change that was made on the spec, and also the
experimental-quiesce and experimental-offers options are also removed, because
these features are now the default, so there's no more experimental-offers.  You
just do offers by default on CLN and the same thing for the quiescence protocol,
which is used for splicing and other types of channel commitment upgrades.  So,
just a very simple maintenance PR here.  Any comments here or we can move on?

**Mike Schmidt**: No, makes sense.

_Core Lightning #8398_

**Gustavo Flores Echaiz**: Core Lightning #8398, so another CLN PR this week.
This one adds a cancelrecurringinvoice command to the experimental recurring
BOLT12 offers.  So, this allows a payer to signal to a receiver that the
receiver should stop expecting further invoice requests from that series.  So,
for example, I want to involve myself in a recurring invoice, so every month I
pay, let's say, a million sats.  That means that in every month, at that
specific time, I will send an invoice request to the receiver so that the
receiver can give me an invoice to pay.  So, that's the recurring the recurring
BOLT12 offers flow that is still experimental, and this new RPC just allows CLN
to notify a receiver to stop expecting the invoice request for that series,
right?  So, just a simple notification and cancel flow.  And other updates are
made to align with latest specification changes in BOLTs #1240, related to once
again the BOLT12 recurring support.

_LDK #4120_

Let's move on to now LDK.  LDK has an update for #4120, which clears the
interactive funding state when a splice negotiation fails before the signing
phase, for example, if a peer disconnects or sends a tx_abort alert, so that the
splice can be retried cleanly.  And this can only happen before the signing
phase begins, right?  So, if the tx_abort alert message is received after the
peers have begun exchanging tx_signatures, so the signing phase has begun, LDK
treats it as a protocol error and closes the channel for safety.  So, the main
goal here is to clear the state so that a splice can be retrieved cleanly if
there's a disconnection or a tx_abort alert message, so mainly just streamlining
communication between peers during splicing to manage all edge cases of
disruption in the splicing negotiation process.  Any further thoughts here?

**Mike Schmidt**: Well, I'll just fill in for Murch because I know he would say
it here.  It's just great to see splicing making its way to the different
implementations.  And so, I'm going to say that on his behalf, because I'm
pretty sure he would say something like that.

**Gustavo Flores Echaiz**: Yeah, I mean I've been I've been seeing LDK getting
closer to that now I think.  Every week, I'm like, "Are we done with splicing on
LDK yet?"  But it's a very detailed process, right?  But yeah, we seem to be
getting closer to the end of the splicing implementation on LDK.  So, yeah,
that's great.

_LND #10254_

Finally, LND #10254 deprecates support for Tor v2 onion services, which is
planned for removal in the next 0.21.0 release.  So, Tor v2 is now hidden, that
configuration option is now hidden, support is discouraged.  Users should
instead use Tor v3, which is now the new Tor standard version.  So, I mean, I
don't have any further comments here.  Unless, Mike, you want to jump in, we
will be done with the section.

**Mike Schmidt**: No, sounds good.  Yeah, I think that wraps up Notable code and
thus our podcast for Newsletter #375.  I want to thank Sindura, ZmnSCPxj, and
Eugene for joining us as guests this week.  Gustavo, I also want to thank you
for jumping in and co-hosting on less than a day's notice.  Appreciate your
time, and thank you all for listening.

**Gustavo Flores Echaiz**: It's a pleasure.  Thank you.

{% include references.md %}
