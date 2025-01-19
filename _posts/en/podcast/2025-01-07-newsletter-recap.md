---
title: 'Bitcoin Optech Newsletter #335 Recap Podcast'
permalink: /en/podcast/2025/01/07/
reference: /en/newsletters/2025/01/03/
name: 2025-01-07-recap
slug: 2025-01-07-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by Yuval Kogman, Jeremy Rubin, and Steve Myers to discuss [Newsletter #335]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-0-7/392681768-44100-2-dd52b2f9d38af.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #335 on
Riverside.  We have two news items this week.  We have a news item on
deanonymization attacks against central coinjoin, and also an updated ChillDKG
BIP draft that we're going to talk about.  And we also, starting this year, have
a new monthly segment that we're covering this week, that summarizes proposals
and discussion about changing Bitcoin's consensus rules.  That segment covers
five different discussions this week as well.  And then we have our usual
Releases and Notable code changes.  I'm Mike Schmidt, contributor at Optech and
Executive Director at Brink, funding Bitcoin open-source developers.  Dave?

**Dave Harding**: I'm Dave, I'm co-author of the Optech Newsletter and of the
third edition of Mastering Bitcoin.

**Mike Schmidt**: Yuval?

**Yuval Kogman**: Hi, I'm Yuval, or nothingmuch, previously involved with Wasabi
coinjoin work.  We'll talk about that a little bit today.  And currently working
on other privacy stuff at Spiral.

**Mike Schmidt**: Jeremy?

**Jeremy Rubin**: Hi, I'm Jeremy Rubin, I'm the author of BIP119,
CHECKTEMPLATEVERIFY (CTV), and been contributing on the covenant upgrades for a
while.  And I'm working on a new project called Char.

**Mike Schmidt**: Yeah, Steve?

**Steve Myers**: Yeah, I'm Steve Myers, I'm one of the contributors on the
Bitcoin Dev kit project.  Also, the President of the Bitcoin Dev Kit Foundation.

_Deanonymization attacks against centralized coinjoin_

**Mike Schmidt**: Excellent.  Thank you all for joining.  For those following
along, we're gonna go, where possible, sequentially through the newsletter,
starting with the News section.  Deanonymization attacks against centralized
coinjoin.  Yuval, you posted to the Bitcoin-Dev mailing list and the email was
titled, "Reiterating centralized coinjoin "Wasabi and Samourai) deanonymization
attacks".  We covered another of your vulnerability findings in Newsletter and
Podcast 333.  Can you summarize the most recent post and vulnerabilities for us
here?

**Yuval Kogman**: Yeah, so there's a few misconceptions about it as well, so I
want to kind of go slowly.  But basically, in a coinjoin, the funds are never at
risk because everybody signs, but we still need to have a way of agreeing what
we're going to sign.  So Chaumian Coinjoin is this technique of using a server,
and the server gives you blind signatures, which allow you to add your outputs
anonymously.  So, 'anonymously' here means you connect over an isolated Tor
circuit that's not linkable to your inputs.  And, yeah, so the main issues I've
been discussing over the years are mainly to do with passive deanonymization
attacks.  But this particular thing I wanted to document is a very egregious
active deanonymization attack.

So, the scenario there is, if the client connects to the server, the server can
trick the client into basically disclosing who it is.  The classic way to do
this is what's called a key tagging attack.  In this case, the blind signing
key, that's the Whirlpool vulnerability.  The blind signing key would be unique
for every user.  So, the output edition, because it contains an unblinded
signature by a unique key, the server knows exactly what input that corresponds
to.  In Wasabi, the vulnerability was a little bit more subtle.  So recently,
there was this loss of what they called 'the round,' should better be called 'a
session', because it's a bit of an overloaded term, but whatever, we'll stick
with round.  So, Round ID is supposed to be like a hash of the parameters that
go into deciding what goes into the transaction, among other things, the width
of the range proofs required.  So, they lost, in a refactor, the code that
actually calculates the hash, and they claimed that this was a new
vulnerability.  I dispute that.  And then they claim to have fixed it, which I
also dispute.

The concern there is that the Round ID was never a binding commitment in the
first place.  So, every client could potentially be communicating under a
different round ID.  The server could be merging the inputs and outputs between
these concurrent rounds and then creating a final merged transaction, which is
still fully tagged, in terms of every user is uniquely assigned to their own
Round ID.  And there were ownership proofs, so BIP322 proofs, that were intended
to kind of mitigate this.  They have three purposes.  One is to protect the
server from DoS, so basically you can't register with an input that you don't
own.  The second concern is for hardware wallets, or in general, stateless
signers to be able to recognize their own inputs and therefore avoid theft.  So,
you can imagine the hardware wallet not being told about all of its inputs, and
then automatically signing for only a portion of the funds that it receives
back.  So, this was a well-known attack that ownership proofs were meant to
mitigate.  And the third concern is exactly that Round ID consistency.  So, if
everybody signs with their ownership proof, which is of just like an invalid
transaction, but it has the same kind of signatures, and those signatures all
commit to the same Round ID, and everybody sees and can verify everybody else's
ownership proofs, then everybody knows that they're not being tagged, that they
all see the same consistent view.

So, the problem was that initially the ownership proofs were never given to the
client, so only the first purpose was actually used.  Then, when Trezor got
support for this, they only addressed the second concern.  But the third concern
of the Round ID consistency was never actually -- although the clients received
the ownership proofs, they just received potentially arbitrary previous outputs
to verify them against and completely trusted the coordinator with that data.
So, the ownership proofs were not binding, which means that the server could
potentially generate a set of ownership proofs for each client with completely
made-up keys, potentially also made-up amounts, and thereby still be able to get
individual clients to basically tag themselves.  I hope that makes sense.

**Dave Harding**: It does make sense.  I just wanted to try to distill this.  If
I understand correctly, let's say we have a coinjoin with just two participants,
which I know is not good, but for simplicity, it's Alice and Bob are the two
participants.  So, the server can send Alice an ownership proof for her actual
scriptPubKey, and can send an ownership proof that claims to be for Bob's
scriptPubKey, but is actually made up or controlled by the server.  And then,
when sending its information to Bob, sends Bob his actual scriptPubKey, but a
forged one for Alice, and then just maintains this and is allowed to keep state
on them and just follow them through the protocol, because it's partitioned them
into two separate channels.  Even though they think they're working together,
they're actually only talking to the server, and the server is able to just see
each one of them in isolation.  Is that basically correct?

**Yuval Kogman**: Yes, that's exactly it.

**Dave Harding**: Okay, that seems pretty bad.

**Yuval Kogman**: Yes, especially in the context of, like recently, free-for-all
started happening with regards to who operates different coordinators.  Some of
them have actually stolen funds from clients, tricking them into participating
in transactions that contribute nothing to privacy, but still claiming the fees.
Subsequently, they removed the coordinator fee support entirely.  So, yeah, it's
kind of a mess as it stands.  And the thing that's particularly upsetting to me
is that I always believed that we would address this, because the entire motto
behind this project was this can't be evil, supposed to be a trustless
coordinator.  And there's no technical reason why it shouldn't be.  So, for
example, full node support is an optional thing that would allow absolute
verification of ownership proofs.  Even in lieu of that, the server could give
the including block hashes and let clients spot-check those.

There's another mitigation, which is if you take the hash of everything that
went into the transaction and use that to shuffle the transaction, the inputs
and outputs have no meaningful order.  So, that's a way of costlessly embedding
a commitment to the shared view into the transaction itself.  That would have
prevented any such transactions from being fully signed, because everybody would
be signing a different transaction.  That was never implemented, even though I
repeatedly raised that.  So, there's issues that were invariably closed for
being stale by the GitHub stale bot.  And yeah, so it's not only that this is a
serious technical concern, it's also been a concern from day one, and there's a
bit of misinformation about whether or not the service is actually trustless.
So, yeah, I'll stop ranting there.

**Dave Harding**: And I think since we published the newsletter, there's been
some follow-up discussion on the mailing list between you and Sjors about
possibly finding logs to see anybody who's used these protocols.  What is your
thought there on people being able to find proof that this has happened, if it
ever did happen?

**Yuval Kogman**: So, just to be clear, I don't think this is likely to have
happened, at least with the zkSNACKs coordinator.  But the client did keep logs
in the wallet directory, so there are debug logs which note the Round ID.  So,
at least the trivial version of this attack could be detected after the fact,
had it happened.  With the equivalent vulnerability in Samourai, I see
absolutely no recourse.  I think the ship has sailed entirely there.  The good
news is that one of the developers still contributing to Wasabi, now that the
company is no longer in business, if I understand correctly, but some people are
still contributing changes, so we had spoken and he said that he would add,
first of all, a mitigation where redundant queries of the publicly available
information would be made.  So, instead of just querying which rounds are
available once and then using the Round ID that you got there, the client would
use multiple Tor circuits to query this several times and make sure that it's
still consistent.  So, that's not a foolproof mitigation, but certainly a
substantially better situation.  And secondly, he said he would try to implement
the deterministic shuffling thing, because again, that's not a protocol-breaking
change.

There are additional concerns.  So, for example, the ownership proofs, or the
Round ID, don't commit to the address of the coordinator, which especially if
it's in a hidden service, that matters.  And I still have many concerns about
passive attacks.  So, all of what we discussed today is just deanonymization
attacks where the coordinator can get caught red-handed if it's trying to
deanonymize users.  But there's still some concerns about potentially passive or
covert ones, which are a bit more insidious.

**Dave Harding**: That's it for questions from me.  Does anybody else have
questions?  Yuval, I want to thank you again for publishing about this to the
mailing list.  I'm sorry we didn't cover this earlier when I heard about it on
Twitter a few years ago.  So, thank you again for publishing about this.

**Yuval Kogman**: Thanks for having me and let me speak my truth, I guess.  And
your apology is still denied.  I don't think you're culpable in any way.

**Mike Schmidt**: Yeah, unfortunate situation, but thank you for jumping on and
explaining the technical side of all of this to us, Yuval.  You're welcome to
stay on for the rest of the newsletter, we've got a beefy one today.  Otherwise,
if you have other things to do, we understand and you're free to drop.

_Updated ChillDKG draft_

Next and second and final News item is titled, "Updated ChillDKG draft".  Tim
Ruffing had posted to the Bitcoin-Dev mailing list a bit ago, starting off his
post with, "We made many changes, improvements, and cleanups to our BIP draft
since our first announcement to the mailing list".  And then he goes on to
outline some of those updates in bullet point format, but there's also some more
details around that as well.  Dave, I know you had a chance to jump deeper into
this one than I have.  Do you want to walk through some of those notable updates
to that draft BIP?

**Dave Harding**: Of course.  I didn't go too deep because when these crypto
guys really get going, I just can't follow the math and the crypto stuff.  But
they fixed a security vulnerability that they found in the protocol.  Again,
this is not a deployed protocol, so we just talk about it read out.  They also
added, and I think it's very useful, a blame functionality to identify faulty
parties.  So, if you follow the protocol, you're guaranteed to get a good key, a
good threshold key for a good threshold or scriptless threshold signing.  But if
somebody messes up during the protocol of creating this key, before, you
wouldn't know who it was, and you could just keep going through the process over
and over and over again and keep getting bad keys and not having something you
can work with.  Now, they've added an investigation phase that allows them to
step through the protocol a bit slower and find out which party was at fault.
This is useful for people who are deliberately messing up the protocol, but it
could also be useful if there's just mistakes being made.

They also say that they've made the threshold public key taproot-safe by
default.  I didn't dig into exactly what that meant.  I'm guessing they found
something that meant it couldn't be used for keypath spending immediately, or
something.  And they've also wrote that they let each participant encrypt the
secret share intended for themselves.  And their advantage for this, they say,
is the encryption is symmetric to avoid the overhead of Elliptic Curve
Diffie-Hellman (ECDH) computation.  I don't know where that would be a big deal,
but we had previously talked on the mailing list about just encrypting the
result by a public key that you might have, say, in your HD seed to make it very
easy to recover these keys, because these keys can't be -- by yourself, you
can't derive them from your HD seed, you need backup information.  So, that back
information, you don't want to just store that around anywhere where someone
might stumble across it and find that information and then learn which outputs
you partially control.

So, with this improved backup, at least as we previously discussed, it should be
possible to encrypt that by your HD seed.  You can store it anywhere, you could
post it on a sign in front of your house if you wanted to, and people couldn't
read it because it's encrypted.  But with your HD seed, you could decrypt that
information and get the key, and be able to find your outputs, and then
hopefully be able to participate in spending them.  I'm glad to see people still
working on this.

Oh, and the other thing there is that they have been working with siv2r, who's
been working on a draft for a FROST signing.  So, ChillDKG is about generating
keys, and siv2r has been working on actually signing, threshold signing.
They've been trying to keep their proposals in sync to ensure that this all
works together and that we have some additional tools for doing scriptless
threshold signing on Bitcoin, which makes me very happy.

**Mike Schmidt**: I don't have anything to add there.  I don't know if anybody,
any special guests have anything to chime in there?  All right.

**Dave Harding**: It's just Yuval noted really quick in the chat that the
taproot-safe thing that we talked about earlier is not for keypath, it's for
scriptpath.  And so, anyone wants to dig into that more can.

**Mike Schmidt**: That wraps up the News section, and we actually have, as I
mentioned earlier, a new monthly segment in addition to our coverage of Stack
Exchange questions, Client and service updates, and PR Review Club, we have a
segment titled, "Changing consensus: a new monthly section summarizing proposals
and discussions about changing Bitcoin's consensus rules".  I'd like to note
that, Dave, you're the author of this segment and you use the same news sources
for this monthly segment as you do for the News section, for listeners who are
curious how things appear here or don't appear here.  Do you want to speak
briefly, Dave, to the motivation about making this a monthly segment, as opposed
to including these as items in the News sections, as we've done in prior years?

**Dave Harding**: Sure.  First of all, we've had a lot of discussion about this
in the last year in particular, but the year before that, and then building up
before that.  And I think it would be helpful to group this together, in part,
actually, for this recap that we do.  It would be great to have authors of
proposals for changing consensus rules all on the same chat so they can talk to
each other about their proposals.  They're the experts on this stuff, and it's
great to have multiple experts in the room at the same time.  And then, also, I
feel like some of these things, when we write about them every week, there's a
little bit of pressure for us to summarize them right away before they've had
time for people to digest them and discuss them.  So, by doing a monthly
section, we give a little bit more time for people to have discussions about
this, and then we can summarize that discussion.  I feel like it just gives us a
better view of the newsletter, because we're not trying to analyze all this
stuff ourselves; other people in the community have a chance to comment on it.
So, that's it and I hope it works out, and that we have a lot of fun in the
coming year.

_CTV enhancement opcodes_

**Mike Schmidt**: Well, it's quite appropriate then that we have Jeremy Rubin,
who's joined us, to talk about at least a few items that he's involved with
directly and indirectly.  The first one that we covered in this segment was
titled, "CTV enhancement opcodes", and this was a post by moonsettler, who was
unable to join us thus far, to both Bitcoin-Dev mailing list and Delving to talk
about two new opcodes that could be used with CTV: OP_TEMPLATEHASH and
OP_INPUTAMOUNTS.  Jeremy, I saw that you replied on the Delving thread.  Maybe
you can jump into your analysis of these proposed enhancements.

**Jeremy Rubin**: Yeah.  Well, I wish moon was here, because despite the
allegations, we are in fact not the same person.  So, I think that the two
proposed opcodes that moon put out, one is template details, basically, and what
that does is it can consume from the stack a bunch of the different pieces that
go into a CTV hash, and then compute that hash to then be fed into CTV.  This is
helpful because you could be working on the stack with all the different pieces
of data that you want to covenant over, and have them actually all broken up
into their logical pieces.  And then, once you finish doing those manipulations,
then just make that call and then compare against maybe a signed template hash.
This is nicer than something like OP_CAT in general, because when you're doing
OP_CAT, you have to take into consideration all sorts of serialization logic for
what the actual representation is.  Now, for CTV, it's not that bad because we
tend to use friendly formats, but for things like signature hashes, it can be a
little bit more complicated.  And then, once you've broken it up so it works
programmatically, it's just a lot simpler to work with.  If you want to
manipulate one output, you can push the other bits and work on it and then
commit to it being a specific way.  So, overall, I think that that's pretty
good.

Then, the other one is sort of an amount output.  That one I'm a little bit less
confident on.  I think that obviously, moon has thought it through to a large
degree, but I think that the different modes to me are still a little bit
confusing.  Generally, CTV avoids binding the specific amount in an input.
There are a couple of reasons for it.  One is that it's not strictly necessary,
and the BIP does say that it would be best left to a later upgrade to deal with
committing to specific amounts.  So, there is a need for some sort of opcode
like that.  The general problem is that amounts are larger than the largest
script number that you're allowed to represent.  So, I'm a little bit wary of
anything that's not fully thought through on how to deal with larger numbers.
There's also some logic for being able to combine multiple inputs that have the
same covenant, which I think is also, to me, a little bit confusing and probably
unlikely to be used, maybe outside a very specific context where somebody's
really thought through that this works perfectly.

**Mike Schmidt**: Jeremy, we haven't had you on since this bigger picture
discussion of covenants has started snowballing, in that there's a wiki now,
there's people giving their feedback on the different proposals around script
enhancements and covenants, a lot of support around CTV, which you're the author
of.  Maybe a big-picture question, what is your take on that wiki or the
conversation more broadly?

**Jeremy Rubin**: Yeah, I think I'm purposely avoiding having too much of a
take.  I think historically, there's been a lot of pushback on me for various
reasons.  So, I'm pretty happy with the conversation just evolving as it goes.
What I will say about the table in particular is, I think you've got to take
with it a big grain of salt, you've got to really dig into what positions people
hold and what they mean.  I think on the table as a whole, I guess I'll get in
trouble for this one, but no doesn't mean no.  You look at the positions that
people have where they say no on CTV, and then they are supporting other opcodes
that we either would contain CTV or would be more powerful.  So, I think there's
not really a simple read on it.  My read is that everybody who has put their
name on there, unless they're 'no' across the whole board, is probably pretty
happy with CTV.  Previously, that was what I kind of claimed when I pushed for a
CTV activation, was that CTV actually does have technical consensus and how I
determined that was I looked at what everybody had said about covenants, and the
only thing that I could come up with that was a reason not to do it was like,
"Oh, we might want something more later down the line".  And that seems to be
the same thing that's happening.

There really aren't any strong, valid technical critiques against CTV at this
point, there are maybe some more strong technical objections of why we might not
want the sort of full MEV unlock that something like OP_CAT would entail.  There
are reasons why something like OP_TXHASH is not near term given some of the
design constraints.  I think that that's what we see with this new
OP_TEMPLATEHASH, is it's sort of an alternative to TXHASH, where TXHASH is a
little bit more rigid of, you have to have, like, compute this exact flag set
that you want.  This is more like, "Well, let's just get the things on the stack
and we can manipulate them from there".  So, that might actually be a closer fit
for what people are expecting as like programmers, and then other stuff that
just seems a little bit more niche or understudied.

I think it does seem like there is sufficient support that nobody would be
spiking a CTV and CHECKSIGFROMSTACK (CSFS) fork.  I would love to see that
include INTERNALKEY, because INTERNALKEY is almost just an implementation detail
of CSFS; it's not really a separate concept, just given if you look at like the
prior literature, CSFS and ANYPREVOUT (APO) have included this notion of a pun
key, where you use the byte 0x1 to stand for the INTERNALKEY.  So,
OP_INTERNALKEY is just doing that as an opcode instead of as the 1 byte, because
it's a little bit more generic than that mechanism.  So, I think that would be
my ideal situation, at least looking at consensus right now, is CSFS, CTV and
INTERNALKEY.  The other stuff I don't feel has broad consensus for it.  And I
think if somebody tried to push or propose something like that, it would
probably cause more controversy than not.

The only thing that's been controversial ongoing is there's a group of people
who feel, in what I see as a self-fulfilling prophecy, that soft forks are
difficult, which they are, but I think that they're more difficult because of
self-fulfilling prophecy than the actual difficulty, where it's made difficult
by people wanting it to be difficult; as opposed to, there's a lot of, if you
ask somebody, "Hey, what do you think?" they're gonna say, "Oh, well, I need to
figure out what everyone else thinks".  And it's like, "Okay, well, can you give
me your original thinking, or can you just say for what you personally would be
okay with?"  "Well, I would be okay with this, but because they're so difficult,
we could never get one again, so we really have to make this one more difficult
so that if we never can do it again because they're difficult…", it's like,
okay, so you're doing the job of making them more difficult.

So, I think that that's something that there at least seems to be consensus that
that set of upgrades is good and doesn't fundamentally change how we understand
Bitcoin.  It just makes things that we're sort of already doing more efficient
and easier to build, more secure, more scalability.  And then the OP_CAT and
things like a TEMPLATEHASH opcode that puts more stuff on stack, that starts
getting into more sophisticated covenant ability that maybe takes Bitcoin into
application land instead of money land.  So, that's kind of my take.  But I'm
not really particularly advancing any activation, I think that the community
needs to do that.

**Mike Schmidt**: Dave, I intentionally derailed us with that question because I
was curious as to Jeremy's answer.  Is there anything else about CTV enhancement
opcodes that you think is valuable, or do you have any questions for Jeremy
based on his broader thoughts?

**Dave Harding**: Oh, on the broader thoughts, oh, geez.

**Mike Schmidt**: Whatever you feel comfortable with.

**Dave Harding**: I think that's a completely respectable opinion.  I think it's
supported from his perspective.  I can understand how other people have other
perspectives, but I don't think there's anything crazy controversial in there
that we have to address.

**Jeremy Rubin**: I think one of the main things that I think is a little bit
interesting to see is, people do need to advocate a little bit more strongly for
things that are in their interest.  I think notably, the Lightning community has
been a little bit silent, and some of the minor changes are major space savings
motivated by how well things will work for Lightning.  So, I think for the
broader Lightning-Dev community, if the answer is, "We're happy to just have
this stuff", then any of it will do.  But if it's like, "Oh, we're never going
to implement this stuff anyways", then maybe some of these things, like
INTERNALKEY matter a little bit less.

_Adjusting difficulty beyond 256 bits_

**Mike Schmidt**: Jeremy, we have another item later in this consensus segment
that we want to bring you on for, but there's one in between, and this one is
titled, "Adjusting difficulty beyond 256 bits".  Dave, I punted this one to you
because I wasn't exactly sure about this unfathomable increase in hashrate and
the feasibility of that.  I saw that there was some a couple of back and forths
on the Bitcoin-Dev mailing list post as well.  Do you want to summarize the idea
here?

**Dave Harding**: Well, sure.  I mean, the question somebody had was, "What do
we do if we run out of space in the hash that gets included in the block
header?" which is 256 bits.  So, you'd have to grind in a ten-minute period; or
really, your worst case of having to grind in a ten-minute period would have to
exceed 256 bits on a regular basis.  It's not a problem that I personally worry
about.  I think that if that was possible, there are other reasons we would
hard-fork upgrade Bitcoin, because it would mean things like txids and witness
txids would not be secure.  However, there was some interesting discussion there
of how we could do a technically soft fork to extend proof of work beyond 256
bits, by having a secondary target that gets included in the block somewhere.
And both the secondary target and the primary target in the block header would
have to be met.  Again, this is not something I'm personally concerned about,
but I thought it was interesting.  And it's similar to some other ideas that we
have previously discussed.  And so, I just wanted to mention that as it's
clever, and it kind of connects to these other things.  So, minor point, but fun
discussion.

_Transitory soft forks for cleanup soft forks_

**Mike Schmidt**: All right, and we're back to Jeremy to talk about transitory
soft forks for cleanup soft forks.  Jeremy, what's going on here?

**Jeremy Rubin**: Yeah, so this is inspired by something Harding said a while
ago, which is, "Why don't we just make the forks temporary?"  And I know we've
got a little bit of a disagreement here, but I think for feature upgrades, I
think it's entirely inappropriate.  And the reasoning that I have for that is
maybe best understood by analogy.  If I said, "Hey, you want to get in my car?
Just FYI, it's going to blow up after the odometer hits 30,000 miles, but it's
at 20,000, so it's good", you'd probably be like, "I don't really want to drive
around in that car".  And I think it's a little bit more bad than that, because
if you have a covenant proposal, for example, that you upgrade, and then all of
a sudden, all of the LN is using it, and they're using massive trees of channels
that are mostly not going onchain, and then your covenant primitive is like,
"Oh, it's got a year left and it's actually not going to get extended", you
might have more than a year's worth of chain load to clear out that covenant
soft fork and to clear out all the outputs, so everybody go onchain to resolve
in a unilateral exit scenario.  So, I think that just for that, for just the
general reason of like, "Oh, I'm going to rely on a feature that if there's
enough bitcoin in it, will get repealed", I think it just doesn't really fit
that well for the user of that, for somebody to form a reliant interest on that
particular use case.

Now, the flipside, and this is where my proposal came in, is people have been
really excited about this great consensus cleanup, as maybe we can fix some of
these longstanding bugs in Bitcoin.  And I'm generally supportive of that.  When
I've looked at that in the past, one thing that I felt difficult is, I really
don't think that Bitcoin should make changes that could confiscate funds.  And
if Bitcoin does make changes that could confiscate funds, you have to deal with
it one of multiple ways.  The first way is that we earmark things that everybody
knows that these things are going to change in the future.  An example of that
is the segwit versions.  Now, today, I wouldn't recommend doing segwit the way
that it was done, because I think that maybe somebody is going to rely on some
particular script version to evaluate to true, and that might be a little bit
dicey.  But when segwit was done, we set it up in the future, so that everybody
knows the next segwit versions are going to be ANYONECANSPEND until something is
actually installed there.  And if you were to try to rely on that going forward,
as it being spendable without any validation, I think you'd be pretty stupid.
There's so much documentation.  I don't know exactly how the reject rules work,
if they reject non-standard outputs for unknown segwit versions.  I think that
they don't.  So, it's conceivable that you could have this problem if you just
weren't really paying attention.  But I think everybody kind of knows that these
things are reserved for upgrades.

Now, for the other case, where it's a change that would say like, "Oh, we had a
problem with taproot and we now need to be quantum secure, so only a specific
NUMS point can be used, you would confiscate a bunch of funds.  And that would
basically lock in a lot of people and maybe you'd say, "Oh, well, everybody knew
that maybe you should include a branch with an unactivated lamport signature,
something or other.  And if you didn't, that's just too bad".  But I think those
kind of confiscatory changes would entail, just in my personal opinion, that you
would have to have some method of restitution.  If you ended up confiscating a
million bitcoin, you'd have to agree that, as a community, a hard fork will be
taken to restore people; or maybe if it's just 1 bitcoin that somebody can prove
that there was missing, that maybe somebody just says, "Hey, we've insured this
upgrade up to 10 bitcoin, and if you can show an output that you lost money,
maybe we'll try and pay you back".  Or you do a fork if you can't pay people off
at that point.

So, I think that that's two things of like, if you do something that
confiscates, it all kind of makes me a little bit cagey about, can we do
something that confiscates?  And all of these can great consensus cleanup
things, they're all confiscatory.  And a lot of them I think are quite bad,
because they fix a problem, but they create a new problem.  And if we discover a
further problem later on, the two fixes may actually not be compatible, because
it might be that to fix issue A, we do one set of restrictions, then we discover
issue B.  And then, to fix B, given the fix to A that we've applied, it might be
actually really hard to fix B without breaking something else.  So, I think that
these consensus upgrades that are compensatory in some way have a lot of danger,
even though they seem to be making Bitcoin more secure, which they also do.
They make Bitcoin more secure against a known problem, but they maybe create a
confiscatory risk over a long time.  I'm getting a thumbs up thing.  So, that's
why I think I'm caged about them.

As an alternative, we could apply this idea of a transitory soft fork and, say,
once every five years, or three years, or whatever, we re-ratify a soft fork
bundle.  And the soft fork can be configured to do this automatically.  It's not
like you have to re-have the conversation.  The signalling can be all set up in
advance to re-signal and activate and lock in whatever the restrictions are.
And then if it comes to light that this wasn't the right approach, then people
can make a new upgrade and activate a different set of rules, and then not
reactivate the old set of potentially compensatory protocol changes.  So, I
think that that, for things like the great consensus cleanup, are valuable,
because in contrast to a feature upgrade, nobody is relying on using behavior
that breaks Bitcoin.  Like, nobody's relying on these transactions, except for
maybe one person, right?  One person might be relying on it, or we might
discover that two fixes are incongruent and can't be combined, or we might
discover, one example that I really don't like is there's a proposal to ban
64-byte transactions.  And one reason I don't like that is that in the future,
somebody is going to write a covenant thing that might emit a 64-byte
transaction for some reason.  And then, now every covenant, in order to be
secure, you have to assert that your covenant program can never get into a state
that requires emitting a 64-byte transaction, which just seems like a lot of
protocol bloat.

So, if we wanted to add that, yeah, sure, add it speculatively, but make it
something that we re-ratify, in case we discover later on that maybe we should
fix SPV a different way.  We shouldn't live with permanent protocol bloat of a
more complex protocol because we're fixing an SPV issue that we later fix a
different way anyways.  So, that's sort of like my general motives for it.  The
network would be made secure, we'd be able to deploy out fixes a little bit more
aggressively.  And I think the main counterargument that I've heard is, people
don't really want to have to re-advocate for the security fixes.  That's why I
would just have the software by default automatically re-signal for this stuff.
And it wouldn't necessarily require a bunch of politicking, it would just be the
way that the protocol works, is these things get renewed by default; but if we
needed to disable them, there's a path to disable them on some frequency.

**Mike Schmidt**: Dave, you've given some thought to this idea, as Jeremy
referenced.  I think it was a few years ago, you brought up this idea of
transitory soft forks.  What do you think about Jeremy's philosophy on the
matter?

**Dave Harding**: I mean, I liked transitory soft forks back then; I like them
now.  I think Jeremy's points are all strong and valid.  I especially like the
point about the 64-byte transactions.  I had not thought about it that way.  I
appreciate that.  My concern on this was that when I proposed it a few years
ago, nobody wanted to go for it for future forks.  Jeremy has his reasons there,
I don't agree with those.  I think that there's always a small risk that the car
you get into will blow up, and that's just a kind of inherent risk in using
stuff, especially new stuff.  And with a transitory soft fork, those risks are
much better specified than they are in ordinary things.  If you want to use a
new feature in Bitcoin, most people are not using the opcode directly, they're
using it through a product.  And whether that's an open-source product or that's
a commercial product, there's a risk that that product will not be there in five
years.  So, if we have transitory soft forks that expire in five years, this is
a risk that you already have to be prepared for, is that your stuff just isn't
going to work in five years.

Finally, if we're in the case where we have thousands of people using this and
it's impossible to unwind in a year, I don't know why you wouldn't have enough
community support to continue that soft fork.  Because a transitory soft fork is
not something that guarantees reverting.  As Jeremy said, we can have the client
automatically signal to continue it by default.  But we can do that for future
forks too.  We can assume that we're going to want to keep this, but if we
decide we don't want to keep it, we can get rid of it.  However, I think just
last time there wasn't a lot of support for this.  If there is support for doing
transitory soft forks for consensus cleanups, I'm on board, I'm totally on
board.  And Jeremy, I'm glad you brought it up.

**Jeremy Rubin**: Yeah, I think also it is a design space.  You can also do
repealable soft forks, where it's like 2016 consecutive miners, a majority, put
in an OP_RETURN that says a pre-committed value of repeal, you know, x on bit 5.
And then after that happens, then signalling starts in a month to disable a
specific flag.  So, it doesn't necessarily even have to be automatic for it to
be transitory.  So it could be, these things live, but if we ever did want to
repeal it, we could signal to repeal without permanently wasting a version bit.
So, I think even something like that would be better for features, because you
just need the active action for the thing to go away.

I think that the main difference I would draw is, like, the thing that happens
automatically if a soft fork that's a feature fork gets repealed, is all people
relying on it get screwed over; and the thing that happens if a security soft
fork gets repealed, that the network wasn't exploited before it went live, is
nothing, nothing happens.  So, it's just a difference of, do all users
automatically get screwed who are still using that, or does nothing happen?  And
because, like, if 64-byte transactions became valid again after being invalid
for SPV, we haven't even seen 64-byte transactions, I think, live in blocks to
exploit this issue.

**Dave Harding**: I don't think we've seen anybody try to exploit the 64-byte
transaction issue, because that requires a large investment of hashrate.  We
have seen transactions below 64 bytes.  We had a discussion on that a few years
ago where Electrum was actually, I think, accidentally creating those.  But if
you're putting it in the hands of the miners, there could be incentives for them
to do things like time warp.  So, you'd have to have a user-activated soft fork
to preserve the fix if that happened.  Again, I think we're probably getting
into the weeds here.  I think this is an interesting proposal.  I think it's
something that people should really think about.  I also still think people
should think about it for future forks, but that's just my perspective.

**Jeremy Rubin**: I'll add one point in favor of Harding's perspectives on
repealing future forks, which is there are probably small tweaks that you could
make to them that require it being invalidated, but would be good to add those
small tweaks.  One example would be with CTV.  We have a 32-byte default
argument that matches exactly one template.  You could potentially make it match
and try five different default templates, and that would only be doable if you
repealed it and then reparsed it in exactly the same way.  And it wouldn't
really negatively impact anyone, because people shouldn't be necessarily relying
on some particular, very specific hash value not being valid.

_Quantum computer upgrade path_

**Mike Schmidt**: Next item from our consensus discussion was titled, "Quantum
computer upgrade path", and this was an item spurned by Matt Corallo posting to
the Bitcoin-Dev mailing list.  He talked about adding to tapscript a new
quantum-resistant signature-checking opcode, and there's some details around
that, but I'll pass it to Dave to sort of outline what BlueMatt was thinking
here.

So, I think this is something that's come up a few times before, but the way
taproot and tapscript work is that if you use a tap, if you use tapleafs,
there's a commitment to them from the output.  And so, you can stick stuff in
there that's protected by a hash and hashes are less vulnerable to quantum
computer attacks.  So, Matt just said, if we come up with an idea for a
quantum-safe signature format, even if we don't necessarily allow using it at
present, but if we fully specify it, then people can start to create tapleafs
that use that quantum signature format.  And after we discovered that quantum
computers are able to make schnorr signatures, public keys, ECDSA or EC public
keys unsafe, they can use the taproot tapleaf spending condition.  And then Luke
added that, again, we don't actually need to do a soft fork at all for this,
even one that's not standard or anything.  We can just have a really good
specification.  I personally am a little skeptical about that.  I worry about
competing specifications.

Then Tadge Dryja suggested a transitory soft fork that people who thought
quantum computers were right on the horizon, we could have that with an
automatic reversion in a few years, unless there was proof of a quantum
computer.  So, if somebody created a proof that quantum computers were able to
recover EC public keys or EC private keys, we would automatically lock in that
transitory soft fork.  Otherwise, it would revert after five years.  But of
course, it could be renewed for another five years through community consensus.
And again, I think we've had a lot of these discussions before, but this kind of
just pulled them all together into a single thread.

**Mike Schmidt**: So, am I right, Dave, that the idea would be, in one of these
tapleafs, it's essentially like an escape hatch, right?  So, you would transact
as normal.  You would not be using that quantum signature scheme, but it would
be there in the scriptpath if you needed to use it at some point in the future,
so people could feel confident that if something did happen, they wouldn't, I
guess, need to move their coins immediately.  They would already have some sort
of protection and something would then trigger the ability to use that new
opcode, if there was thought that quantum was here?

**Dave Harding**: Basically correct.  It would be there in case there was a
surprise quantum computer.  If you woke up tomorrow and discovered that the NSA
had a quantum computer capable of recovering EC private keys, all of our money
would be gone, at least all of our money that -- well, there's a couple of
special cases where we wouldn't necessarily lose money.  But pretty much,
everybody's money would be gone.  And so, people who were concerned about that
would have the opportunity to create a tapscript that allowed them to spend
using a quantum-safe algorithm.  This works for your cold wallet.  It doesn't
necessarily work for you in a contract protocol, unless the quantum-safe
algorithm has the same properties as we already depend on in these scripts.  So,
if we're just using plain CHECKSIG in a tapscript with no key aggregation, then
you're fine.  But if you're using key aggregation, these quantum-safe keys don't
necessarily have that property.

So, it's something that you could do.  I don't know that it's the best solution,
but it's something we should talk about.  And it is there for people who are
really concerned about quantum computers right now.  And there's certainly
people there, and I can understand their legitimate concerns.

**Mike Schmidt**: Is Matt's idea that that specified opcode that would be
quantum resistant would be usable immediately, or would there be some event that
would trigger the ability to use that scriptpath with that new opcode?

**Dave Harding**: That was discussed a bit in the thread.  The problem with the
quantum-safe algorithms is the signatures for them are very large compared to
existing signatures.  The degree to which they're larger has come down a lot in
the last ten years, but they're still quite a bit larger than a 64-byte schnorr
signature.  So, we might not want to allow them to be used right away, just to
prevent people from using up a lot of block space.  On the other hand, we might
want them to be used right away, just to make sure they work and people can use
them in practice.  You can see it both ways.  It's kind of a challenge.  And we
also don't necessarily need to specify the particular signature algorithm, as
long as we can specify the public key format, and we have a strong belief that
will be usable with a future quantum-safe signature algorithm.

**Jeremy Rubin**: Yeah, I think one thing I would just want to add into the mix
on the subject, is ZK proofs, like STARKS are quantum resistant, or at least can
be, from what's on the market right now, re-engineered slightly to be quantum
resistant, I think if you use like a larger hash digest.  So, that's also
probably a very viable path to deal with a lot of the size constraints, is to do
a proof over all of the proofs in each transaction, and then have one aggregated
proof per block; or when you're a client catching up, one aggregated proof per
month or something.  So, I think that it's probably more worth it to use
whatever the best primitive is and then not worry that much about space
constraints.  And I think also, just accept that we can maybe make it into a
soft fork, but it may just be simpler to do a hard fork.  And quantum resistance
is a really, really big change from how Bitcoin works.  And one of the things
that we'll probably want to do is do a hard fork to commit to a terabyte big
block to allow everybody to close and reopen in one go.  I think that probably
quantum will be a hard fork, not a soft fork for the given extant UTXO set.

_Consensus cleanup timewarp grace period_

**Mike Schmidt**: Our last item from the consensus segment is titled, "Consensus
cleanup timewarp grace period".  And Sjors posted to the Delving thread that is
discussing the great consensus cleanup that we referenced earlier.  And the
great consensus cleanup as proposed today says that the first block in a new
difficulty period can't have a time more than 600 seconds earlier than the last
block of the previous period, to fix some of the time-warp issues.  But Sjors,
in his response, is suggesting a less restrictive limit, proposing 7,200 seconds
instead of 600 seconds.  Dave, what would be the advantages of having such a
longer grace period?

**Dave Harding**: The advantage there would be that we don't know exactly what
software and hardware miners are running, and we don't know exactly how it
works.  We have lots of guesses and sometimes we have open-source software that
we can look at and poke at and see how it works.  But not in all cases do we
know how pools are set up.  And it's possible that there might be some software
there that wouldn't work with 600 seconds.  It could generate a block that would
be valid.  It would be a valid block, but it would have a time too far in the
future to be accepted by full nodes immediately, which could cause other miners
to create competing blocks, even though that block exists and they might have
received it.  Other miners might keep competing blocks and that first minor with
the weird software we don't know about would lose their block reward.

I went through this this thread, and Antoine Poinsot makes some pretty strong
arguments, if you look at them from a probabilistic perspective, that this is
quite unlikely to happen, just because of what an attacker has to do.  However,
like Jeremy was saying earlier, we, as bitcoiners, think it's really important
for us to be concerned about confiscation risk.  I know this isn't exactly
confiscation.  This would be causing somebody to lose money by trying to fix a
bug that has so far never hurt anybody.

**Jeremy Rubin**: The hashrate validation is constant.

**Dave Harding**: Yeah, I agree.  And so, Sjors is posing a limit that's much
more liberal, in that sense.  I don't know how existing software, unless it
already had a really severe bug, could have a problem with 7,200 seconds.  600
seconds, you can kind of imagine that it's possible, even though it's a low
probability thing.  With 7,200 seconds, you're two hours in the past, you're
very unlikely to bump into convenient time pass restrictions anyway, if you're
moving time.  So, this is just a proposal to be extra safe about this, to be
extra careful about not invalidating hashrate, having a confiscation risk here.
So, I thought it was an interesting discussion.

**Mike Schmidt**: I haven't checked the Bitcoin-Dev Mining mailing list to see
if something like this was posted there recently, but this would be a good
discussion to solicit any sort of miners and mining pools, if they are currently
doing something that could roll the timestamp into the future like that.  If
folks are curious, when miners are hashing, they may tweak the timestamp, and I
think that's the concern here, is that as they're hashing, they're tweaking that
timestamp past that 600 seconds and their algorithms may run more frequently
over that 600 seconds than is anticipated in Antoine's 600 seconds here.  Yeah,
interesting discussion.  We're wrapping up this segment.  Bob, I know you had a
comment or question.  Do you want to talk about covenants now, it sounds like?

**Bob McElrath**: Sure, I hadn't planned to say anything, but since you guys got
into the meta of covenants and activation and which covenant and how, I just
thought I'd offer my opinion, which I don't usually say, because I haven't been
weighing in on this topic for quite some time.  I am a fan of covenants and the
perspective of the aficionados is that, "Well, show me something that you can do
damaging with it", and I think this isn't strong enough.  We really need to have
something that we actually need to do with covenants.  And the number one case
that everybody put out, and I put out, was using it for wallets and vaults,
right?  And unfortunately, this idea has kind of failed in the market.  There's
a company, Liana, that tried to do this using a signing server to essentially
achieve covenants, and they have basically failed in the market.  I personally
have failed at this.  I tried to shill it at Fidelity, even presented a demo to
the CEO.  This went nowhere.  The fact of the matter is vault-based wallets are
far more complex, and in every scenario, I've seen at least three times in my
personal experience, companies have chosen to use HSMs because they're far more
flexible.

So, in the absence of that, we need a really good reason to do this.  My
perspective on the entire covenants conversation has been very much, "I have a
hammer and everything looks like a nail" scenario, and a lot of the use cases
are that.  They're like, "Okay, here's a hammer, what can I do with it?"  But I
would really love to see a really strong, really good, "We need this", where
everybody can get behind and say, "We need this", right?  I posted to the
Delving list today an idea for using covenants for Braidpool.  This is in line
with Jeremy's post he did years ago about what he called a mining pool, which
really is kind of a method to do miner aggregation with covenants.  I would love
to see a covenant proposal that achieves that, and I think that would be a very
strong motivator to do a covenant proposal.  And if somebody comes along with
that, I will put my weight behind it.

**Mike Schmidt**: Jeremy, do you have any thoughts on that?

**Jeremy Rubin**: Yeah.  I'll give three thoughts.  One is a joke, I guess, is
first to show that somebody really needs vaults, you need to show that somebody
really needs Bitcoin.  So, I guess that that's maybe still an exercise left to
the reader.  But I think if you look outside the Bitcoin community, an example
would be the Gnosis like safe wallet.  It's a vault, it has like $100 billion
worth of assets.  That's just one vault implemented in Ethereum land.  So, I
think it's probably not a facet of vaults not having market demand, it's more a
facet of what we've been able to produce in Bitcoin being convincing enough for
people to want to use them.  And especially with pre-signed vaults, the data
storage requirements are hard for people to want to swallow that pill, because
they kind of want a stateless backup generally.  So, I think that that's one
aspect of why maybe those approaches have not been so popular.

I think the follow-on to your other point about mining pools is, skipping over,
where does the Venn diagram of mining pool versus some scheme that miners
collaborate on to coordinate payouts terminologies therein, I think most of the
stuff that I wrote about in terms of mining pool payouts and aggregation is
applicable.  I think the difference between your mailing list post and what
happens there is whether or not the aggregation happens as a result of the
covenant executing to combine two UTXOs, or whether the coordination and
cooperation of participants is sufficient.  I think with CTV in particular,
probably just CTV, you can set up a mining pool where in every template, you pay
out based on recent participation to all miners who are a member to that pool.
And then you create outputs over time that have payout trees to, let's say the
last 100 miners, or something like that, or however your pool works, you have
all those payouts.  And then, you would maybe exclude anybody who's a DoS risk,
so you only want well-behaved miners who are actually keyholders.  Other people,
if you're not well-behaved, maybe you get excluded from getting included in the
multisig.  And then you can coalesce those multisig outputs into one and do one
condensing transaction on some frequency to rebalance those outputs.

So, I think what you're asking for, it's maybe a long way of saying it, but I
think it probably would work fine with just CTV.  The main thing that you really
need is being able to set up unilateral exits from a given output without
requiring signatures.  Requiring signatures for the setup of a covenant in
mining is a non-starter, because it requires an interactive signature scheme in
the loop of forming new block templates, which I think is probably not going to
be popular.  But if you have non-interactive, then you can probably, if
everybody has the data for what would go into that output, as a member of the
mining pool, you can probably successfully aggregate.  And the aggregation can
happen interactively, it doesn't need to be non-interactive aggregation across
those inputs.

**Bob McElrath**: Great.  I didn't want to get into design right here.  I'd love
to have your input, Jeremy.  Anyway, just that's all I had to say.

**Mike Schmidt**: Thanks, Bob.

**Jeremy Rubin**: Yeah, thanks, Bob.

_BDK wallet-1.0.0_

**Mike Schmidt**: Releases and release candidates.  We have what we've promised
listeners for a few months, I'll put it that way, on a few RCs, which is BDK
wallet-1.0.0.  We covered the beta releases for BDK in the past months, we've
also covered probably a lot of the BDK-related PRs that went into this release,
the last beta being in December with the 1.0.0-beta.6 RC, which I don't think we
covered, but we have here Steve Myers to celebrate the BDK 1.0.0 release.
Congratulations.

**Steve Myers**: Thank you.  Congratulations to the whole BDK team and all of
our users, and thank you for all of your months of covering our releases, our
beta releases, our alpha releases.  It has been a long journey for the team.
Yeah, we're a little behind schedule, probably like a year-and-a-half, but we
got it out, we got it done.  Yeah, the team put in a lot of work this year, this
past year, and yeah, got to that 1.0 milestone.  One of the things I know that
came up in your prior newsletters was this question of what we meant by betas
is, were they RCs?  I guess I was thinking about it more from an enterprise
point of view, where beta basically means it's ready for our users to test it.
So, I guess you could call that an RC.  But we were still, up until the end,
making still changes based on that user feedback, so we did get users that found
stuff.  We were really lucky to get Antoine to do an audit before we did the 1.0
and he found some issues.

One of those issues is, I think you have later down on the list, which is this
performance issue.  But yeah, so 1.0 is a big deal, and finally got it out.
Now, we have our new challenge, and this is my challenge to everybody out there
using BDK or interested in BDK, is to please, if you're using pre-1.0, now is
the time to upgrade to 1.0.  And I'll post a link in the chat here that maybe we
can post somewhere.  We do have a migration guide.  It's a beginning of a
migration guide, but I think it's a pretty good start.  We, as part of the 1.0,
wanted to have better documentation, everybody wants that.  So, we have this
thing called, "The Book of BDK", and it's more of a tutorial-style
documentation.  And one of the chapters is on migrating.  The main issue for
migrating is you just primarily want to get your data from the pre-1.0 database
into the new 1.0 database, and then it all works the same.  Of course, the APIs
have changed over time also.  But in terms of the actual migration steps, we
have that there in the guide.

Yeah, so I don't know what else you're curious about with 1.0, but we did make
some pretty big API changes.  A lot of the highlights, I guess you would say, is
better no_std support, which means better WASM support, better async support.
So, if you're doing an application, this is primarily for server-side stuff,
where you might have a lot of users accessing a single wallet.  Async is very
important, so things like accessing your database in an async manner, accessing
whatever your blockchain source is in an asynchronous manner, so this would be
Electrum or Esplora; those have asynchronous options now without having to block
the main wallet.  A lot of refactoring was also meant to improve performance,
although we still had some performance issue that I think is completely fixed
now.

I also wanted to mention that one of the new features that's still sort of
experimental, but is very exciting, is rustaceanrob is one of our new devs and
he created a compact block filter client.  That's something we had a very basic
version of before, but we now have a much better, more complete one.  And this
is a relatively new development, so that's why it's kind of considered
experimental, but it's ready for testing and use.  We also have much better RPC
support.  So, yeah, for folks that are more server-based that might have access
to a core node, we have much better, more efficient RPC support, where you could
be tracking a lot of UTXOs in just every block.  We just scan each block, so
it's like a block-by-block synchronization of a wallet.  So, we're excited about
that also.  So, yeah, any questions at this point?  Otherwise, I'll mention a
couple of shills where people can find us.

**Mike Schmidt**: Yeah, quick question for folks that are listening, maybe they
follow along with some of the PRs with BDK and maybe they're just not sure if
they should consider using it or migrating it or building on top of it, who is
the best fit sort of target audience for using BDK?

**Steve Myers**: Good question.  So, we'd initially focused primarily on sort of
single-user wallets, this would be mobile wallets.  Examples there would be
Bitkey as a mobile wallet that uses BDK.  That would be a typical case, but
we've gotten a lot more interest in server-based wallets.  So, this would be
something like, still single user-based, but running more on a server, so
someone like Proton Wallet, so they run on a server.  So, I think definitely if
you're making a mobile wallet, take a look at BDK, but I think also if you're
making any kind of application that might be on the server where you need a
wallet.

Antoine even did an interesting experiment back a few weeks ago, where he used
BDK Core as sort of the back end with BDK as sort of the consensus layer stuff.
And then he used some of the, what did he call it?  There's basically some new
APIs around the Core consensus module, like the modularization of Core.  He used
those APIs to talk to a BDK wallet for synchronizing wallet data.  So, in the
future, I could see people who want to make more high-performance wallets on
more of a server back end could use a scenario like that.

But yeah, so I know what we're really going for is we want to be a
well-reviewed, open-source, free library that any businesses or individuals
making apps that need a wallet can tap into.  Of course, we're descriptor-based,
so that is, I guess, a limitation for some folks.  Our BDK wallet library,
that's again something I should mention, is that originally the BDK library,
pre-1.0, it was just called BDK.  We've now split it up some more, so now it's
called bdk_wallet, if you're on the Rust land, so look for that create,
bdk_wallet.  But underneath that, we have this lower-level thing called
bdk_chain, which is really just focused on all the pieces you might need to
track chain data.  And that's used at the higher-level wallet.  But the reason I
say that is you might have an application like, I don't know, like Ark, for
instance, that doesn't necessarily use a traditional descriptor-based wallet,
but still might be able to take advantage of some of the features in our chain
crate to track UTXOs or to do coin selection, or things like that.

So, those components are now exposed that were not exposed before.  So, I think
it's going to open us up to more esoteric Bitcoin applications beyond a simple
wallet.  We haven't had anything like that ship yet, but I do see some of it on
the horizon.  But yeah, the quintessential case is anything that needs Bitcoin
wallet onchain using descriptors.  That includes taproot and all the features
that, you know, we try as much as possible to stay consistent with the feature
set of Core's wallet.  We may not be 100% there yet.  We still have some
features I'd like to implement in terms of privacy, and locking and unlocking,
which is somewhat useful for some applications.  But in terms of taproot support
and descriptor support, miniscript, that's where I think anybody building
applications that need those features, we are there.

We also have a recent project that, I mentioned mobile.  One of the things we
spend a lot of time doing, in addition to the Rust library, is making a language
bindings, which allows people to access primarily all of the features of BDK,
but through Kotlin, or through Swift, or through Python.  Those are the
languages we focus on.  And we have another team that's working on JavaScript,
so as a node; if you want to use it in node, that's fairly new.  And we also
have, gosh, what's it called?  Google's, I always forget the name of this
language, it's not Flash; it's Flutter.  So, there's also a Flutter
implementation that another team has built on top of BDK.  So, yeah, we're
trying to be that resource in the ecosystem for people building tools in any of
those platforms.  Yeah, I basically said we want to make it available for
everybody, is kind of the idea here.  And it's also a bit of a training
exercise, like for instance, Python, we have people that might want to learn
about Bitcoin, Python, you may not want to create an application, although we do
have somebody who's creating a very cool desktop wallet using Python and BDK.
So, yeah, it's sort of covering a lot of different application space there.

**Mike Schmidt**: Well, maybe the 1.0 milestone will get a few more folks
interested.  I'm glad you were able to come on and tell people about it.
Congratulations.

**Steve Myers**: Thank you.

**Mike Schmidt**: We do have that BDK performance-related PR a little bit later.

**Steve Myers**: I'll hang on for that.  Thanks guys.

**Mike Schmidt**: Dave, did you have a comment?  Okay, I couldn't tell if you
were raising your hand.  All right, excellent.

_LND 0.18.4-beta_

Next release that we covered this week was LND 0.18.4-beta.  This beta release
includes four bug fixes that I saw, four RPC additions, and then there were
eight PRs around a new feature to support custom channel functionality.  There's
also this note about additional Bitcoin Core 28.0 compatibility testing.  I saw
in one of the comments or PRs, or maybe it was release notes, "Of note are the
bitcoind v28.0 compatibility fix and an optimization for payment requests
(invoices) that removes unnecessary size expansion.  See full release notes for
set of changes".  So, if you're an LND user, check it out.

_Core Lightning v24.11.1_

Next release, Core Lightning 24.11.1.  This is a minor release for Core
Lightning (CLN).  It included four fixes and four changes, most of which were
around the xpay JSON-RPC and the xpay-handle-pay RPC.  The PR notes, "This is a
quick release due to the popularity of xpay, especially using the (reckless!)
xpay-handle-pay option".  So, if you're using any of those RPCs, you might want
to check out this minor release.

_Bitcoin Core 28.1rc2_

Bitcoin Core 28.1rc2.  We touched on rc1 briefly in Podcast #332, and I think we
covered it also in #333.  I am not aware of anything between rc1 and rc2.  That
doesn't mean there isn't anything, I just didn't get a chance to dig into it.
Dave, I'm not sure if you're aware.  Okay.  All right.  Well, I think Murch had
the call to action last time we discussed the Bitcoin Core RCs, which was,
"Please test them before they're final", because there's at least some history
of people just taking the final --

**Dave Harding**: Otherwise, it would be like LND, and you'll have to put a
release note saying, "Hey, we actually tested it in 0.18.4".

_LDK v0.1.0-beta1_

**Mike Schmidt**: Good point.  LDK 0.1.0-beta1.  The release notes are
forthcoming, is what I saw, without digging into the code itself and the PRs
that were included with that.  So, I don't have a summary of that.  I saw that
the previous release was 0.0.125.  So, with the 0.1.0, I'm not sure if there's a
change in version numbering there.  I assume we'll learn more shortly on that.
Wasn't able to get an LDK representative on to talk about this beta and the slew
of LDK PRs later.

_Bitcoin Core #31223_

Notable code and documentation changes.  Bitcoin Core #31223.  This PR fix is an
issue where if you were running multiple bitcoind instances using Tor, it would
result in a crash.  The common reason that someone might be running multiple
nodes like this would be for testing.  I'm not sure the other sorts of use
cases, but that would be the common one.  So, this has been an issue previously,
where running multiple instances using Tor caused issues, but previously those
Tor connections would just all go to the first node because they were all
binding on the same port essentially.  But with a recent 28.0, update it
actually became a crash.  So, this is a fix for folks who have multiple Tor
nodes on the same machine.

_Eclair #2888_

Eclair #2888 implements a feature for peer storage, which is proposed as part of
the BOLTs repository, currently an open PR, that's PR #1110.  And the peer
storage functionality allows an Eclair node to store channel state for their
channel peer, which could potentially allow a peer to keep using a channel, even
after that peer lost local state for some reason, because its peer was nice and
backed it up for them and provided it for them.  There were a couple notes from
t-bast on the PR, who was not the PR author but the reviewer, and he says a
couple things.  First, "I thought this was an easy PR, but as I dived into it, I
think there are many subtle aspects that have a big impact on scenarios where
users restore from seed.  That's why I have multiple comments that aren't
trivial, for which we need to decide how we'd like Eclair to behave".  And
another quote saying, "I'm a bit afraid of the DoS risks associated with this
feature".  I should note both of those concerning-sounding PRs were through the
review process and they worked out all of those concerns.  But if you're curious
of some of the details of why that could be thorny for Eclair, check out that PR
and the commentary associated with it.

_LDK #3495_

LDK #3495, I have two different things I want to highlight.  One was from the
writeup this week, LDK #3495, "Refines the historical success probability
scoring model in LN pathfinding by improving the probability density function
(PDF) and related parameters based on real-world data collected from randomized
probes".  So, that was our summary.  The source material from the PR description
had a bit of a writeup, and I thought a similar summary from there was also
interesting, sort of iterating the same saying, "Utilizing the results of probes
sent once a minute to a random node in the network for a random amount (within a
reasonable range), we were able to analyze the accuracy of our resulting success
probability estimation with various PDFs", which was the probability density
functions, "across the historical and live-bounds models".

**Dave Harding**: I think we actually wrote up something about this before for
LDK, when they started using those probes and started using them to refine their
functions.  I think this is a really useful approach for them to actually go out
and do that testing and to see how it stacks up.  I just really like seeing
that, because this is something you can do on LN, is you can send probes that
are basically free to send and see how your code actually stacks up.  It's not
necessarily what your clients are using, because everybody has a slightly
different view of the network in these sort of things, but it gives them a good
basis for improving the code and making sure it works the way they expect it to.
So, I'm very happy to see this testing-based improvement.

_LDK #3436_

**Mike Schmidt**: LDK #3436 moves the lightning-liquidity crate into LDK.
Previously, that was in a separate repository under the LDK organization, and
that lightning-liquidity crate contains a bunch of types and primitives to
integrate a spec-compliant LSP with an LDK-based Lightning node.  So, really
just a little bit of reshuffling in there.

_LDK #3435_

LDK #3435 is a PR titled, "Authenticate blinded payment paths".  This PR fixes
an issue where an attacker could potentially take a payment secret from a BOLT11
invoice issued by the victim node and then forge a payment.  And I'll paraphrase
Jeff, who is the PR's author here, and in the description when he says, "When
receiving a PaymentContext from a blinded payment, the context must be
authenticated.  Otherwise, the context can be forged and would appear within a
PaymentPurpose.  In order to authenticate a PaymentContext, an HMAC and nonce
must be included along with it.  Upon receiving an HTLC (Hash Time Locked
Contract) over a blinded path, ChannelManager can then authenticate it".  So, a
few different pieces of LDK-specific jargon in there, but if you're curious, you
can jump into the details and generalize something like that a little bit more
broadly.

_LDK #3365_

Another LDK PR, LDK #3365, which fixes the upgrade logic when upgrading from LDK
0.0.123 and prior.  And that fix is to prevent scenarios where a couple of
negative interactions between LDK's internal handling of commitments between
those various versions could cause issues.  For example, before this PR, a
situation could arise that would result in an assertion failure, if you're in
LDK's debug mode, and a forced closure of the channel in production.

_LDK #3340_

LDK #3340 enhances LDK's onchain transaction batching feature set.  The PR is
titled, "Batch on-chain claims more aggressively per channel".  Previously, LDK
batched only non-pinnable claims, and this was to prevent risk around outputs
that, if you claimed a bunch of outputs in a batch that might fail if one of the
outputs was pinned, it would essentially be able to pin all of them.  The PR
noted, "However, if pinning is considered an attack that can be executed with a
high probability of success, then there is no reason not to batch claims of
pinnable outputs together, separate from unpinnable outputs".  I didn't have
anything else here, Dave.  Did you dig into this one any deeper?

**Dave Harding**: A little bit.  I think they were being very conservative
before by saying, "If we have a pinnable output, let's just do it individually".
And like you said, why not batch these together?  If one of them is going to get
pinned, you're likely to get all of them pinned, because they're probably all
with the same counterparty.  I didn't check to make sure that was the case.  But
if you have multiple HTLCs and one of them is pinnable, they were all with the
same counterparty, so that counterparty is probably trying to pin them all.  And
so, why not throw them all together?  And again, you're doing this within 12
blocks of the height, so they still have a little bit of time.  They're waiting
until the end of the time before doing this.  So, it seems like a useful thing.
I hope they looked into it very carefully, would be my comment there.

**Mike Schmidt**: To your point, I think based on the PR title saying, "Per
channel", that it would be per counterparty.  And there was, yeah, some
discussion about the fact that an output can transition between unpinnable and
pinnable based on block height.  So, yeah, if you're curious, jump into the PR.
There's some good discussion there.

_BDK #1670_

BDK #1670.  Steve, you alluded to this a bit earlier, but do you want to
double-click on that a bit and give us some details here?

**Steve Myers**: Yeah, I can give a little background on this.  This was an
issue that was found.  This is a potential performance issue that was found by
Antoine.  It was one of these situations where it was a little bit of an edge
case in the sense that it only came up in the scenario where you might have a
lot of double spends, or like a very complicated tree of transactions that were
double-spending each other.  But because this could be done without waiting for
those to get confirmed, it could just be in the mempool with this crazy
cancellation tree, it was something that could be exploited.  As far as we know,
nobody ran into it, but we still wanted to fix it.  Evan did a heroic job here
at getting it really well spec'd out what the issue was and implementing a
solution.  And then, one of our new full-time devs, valuedmammal, did a really
amazing job testing it.  He created a whole benchmark framework.  There's a
benchmark framework feature within Rust that he took advantage of and bottom
line is, was able to get these.

So, the solution, just to kind of summarize what the solution was, we have this
concept within BDK's chain crate of canonical versus non-canonical, canonical
meaning it's in the best chain.  And what we were doing before was we were
checking every transaction when you did a transaction list individually to
figure out if it was canonical or not.  This improvement sort of just
short-circuits that that says, if you're canonical, then your ancestors are also
canonical, so your parents are also canonical if you're canonical.  So, it sort
of does some short-circuiting using that logic.  And in valuedmammal's testing,
the performance went from milliseconds, and in some cases the tests didn't even
finish, so multiple seconds potentially, down to microseconds.  So, it did solve
the problem in a really great way.  And yeah, we were happy to get that into the
1.0 release.  So, like I said, I don't think we had any users that ran into it,
but I'm still happy to see we were able to get it fixed prior to the 1.0.  And
just in case anybody had any worries about complicated trees of transactions
spending and re-spending each other.

_BIPs #1689_

**Mike Schmidt**: Great.  Thanks, Steve.  BIPs #1689 adds Discrete Log Equality
Proofs, DLEQs, as BIP374.  DLEQs can allow someone to prove that they can
control a UTXO in the UTXO set without revealing the specific UTXO.  We've
talked about this on the show and in the newsletter previously.  A different use
case and the motivation for this PR was around another use case, which was
proving a silent payment output was constructed correctly without disclosing a
private key, specifically in the context of multiple parties creating a silent
payment address and coordination between them.  We had some discussion of this
in Podcast #327, where we had the BIP author, Andrew Toth, on and he discussed
the original BIP draft, so for further details, check out that episode.  And we
also have a DLEQ topic on the Optech Topics list as well, so please reference
that if you're curious.

**Dave Harding**: Yeah, just to quickly summarize what's going on there, is when
you're creating a silent payment output, you have to use the recipient's key,
but you also have to use your own private key in there.  If there's multiple
signers, everybody has to use their private key in order to derive the silent
payment output.  If they do it wrong, the silent payment output will be
unspendable by the receiver, there's just no way they'll be able to spend it,
and that money will be potentially permanently lost.  So, this proof just makes
sure that when there's multiple cosigners, they all have assurances that
everybody else generated the output correctly using their own private key, and
that no money will be lost, but their receivers will get it.  So, it's a really
powerful tool to have for multisig situations with silent payments.

_BIPs #1697_

**Mike Schmidt**: BIPs #1697, which updates BIP388 to add support for MuSig in
descriptor templates.  BIP388 is the BIP for wallet policies for descriptor
wallets.  This change involves some changes to the grammar to support MuSig
expressions.  So, if you're using wallet policies, you can now, if your software
is updated, use MuSig in those policies moving forward.

_BLIPs #52_

BLIPs #52.  This PR and the one that we're going to cover next are both
additions to the BLIP repository based on specifications that originated from
the LSP Spec group.  We had Severin on, I don't remember the episode or the
newsletter number, but he was talking about this LSP Spec group.  They have a
series of specs that they've gone through, and these next two PRs that we're
covering are sort of upstreaming those to the BLIPs repository.  The PR author
noted, on a similar note, "As previously discussed on multiple occasions, the
LSP Spec group is, however, moving to a BLIP-centric process, which is why we
'upstream' these previously-stabilized specifications here".

So, this first PR, this BLIPs #52, specifies a protocol for communications
between an LSP node and the LSP's client.  It uses BOLT8 and JSON-RPC as the
mechanisms for that communication.  And it's essentially the LSPS0 spec from the
Bitcoin and Lightning layer specs LSP repository that we've referenced
previously.

_BLIPs #54_

BLIPs #54, similar to the previous PR, is the upstreaming of the LSPS2, which is
the JIT channel negotiation spec from the LSP repository.  It lets an LSP's
client with someone with no channels potentially to start receiving on LN
without any channels, and the cost of that inbound liquidity is taken out of
their received incoming payments.  One thing not related to this PR, but Dave, I
also noticed that there was an upstreaming of add BLIP51, which was the channel
requests LSP spec, which is LSPS1.  So, I guess for the audience, LSPS0, 1, and
2 were all merged into the BLIPs repository.  And that LSPS1 is a specification
for providing a standardized LSP API for wallets who wish to purchase a channel
from an LSP direct.

**Dave Harding**: I don't know how I missed that.  Sorry, guys.

**Mike Schmidt**: So, I guess there's three sort of similar, this upstreaming,
it sounds to me like moving specs from the LSP repository into the BLIPs
repository.  So, there may be more of these, because I think I saw that there
were more LSP specs that were in there that hadn't moved yet.  We'll see.  All
right.  Well, I think we can wrap up.  We had a big one today.  Steve, thanks
for joining us.  Congratulations on the BDK release.  Thanks to Jeremy for
joining us and Yuval as well and Bob for chiming in on his covenants and
Braidpool perspectives.  Dave, thanks for co-hosting this week.  Thank you all
for listening.  Cheers.

{% include references.md %}
