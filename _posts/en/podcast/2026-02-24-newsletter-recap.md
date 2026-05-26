---
title: 'Bitcoin Optech Newsletter #393 Recap Podcast'
permalink: /en/podcast/2026/02/24/
reference: /en/newsletters/2026/02/20/
name: 2026-02-24-recap
slug: 2026-02-24-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Misha Komarov, Erik De Smedt, and arbedout to discuss [Newsletter
#393]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-1-24/418752236-44100-2-b54befa6b1d3c.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt:** Welcome everyone to Bitcoin Optech Newsletter #393 Recap.
Today, we're going to be talking about some recent OP_RETURN output statistics
following Bitcoin Core's v30 release; we're going to talk about Bitcoin PIPEs
v2, and covenant-like enforcement without consensus changes; and we also have
our regular monthly segment covering recent Changes to client software that we
find interesting; and we have also our weekly Releases, release candidates, and
Notable code and documentation changes.  Murch, Gustavo and I are joined this
week by three guests.  We'll have them introduce themselves briefly, and then
we'll jump into the newsletter.  Misha, who are you?  Who are you, what do you
do?

**Misha Komarov:** It's Bitcoin Pipes, I guess the most relevant thing for
today's conversation.

**Mike Schmidt:** Excellent, thanks for joining us.  Erik?

**Erik De Smedt:** Hi, I'm Erik, I work at Second.  We're building an
implementation of Ark, and I'm going to talk about hArk, which is our new
variant of the Ark protocol.

**Mike Schmidt:** And arbedout?

**arbedout:** Hey, I'm working on Sigbash, which right now is a zero-knowledge
MuSig2 policy signer.

_Bitcoin PIPEs v2_

**Mike Schmidt:** Awesome.  Well, thank you again for joining us.  We're going
to go a little bit out of order.  So, if you're following along at home, we're
just going to have a little deference to our guests, and so bear with us as we
jump out of order.  But we are going to jump to the News section first.  We have
Bitcoin PIPEs v2.  Misha, you posted to Delving Bitcoin about Bitcoin PIPEs v2,
a protocol for enforcing spending conditions without consensus changes,
including covenant-like instructions.  Maybe, Misha, you can give us a quick
overview.  What was, or is, Bitcoin PIPEs v1, and then what is v2; and then we
can get into some Q&A?

**Misha Komarov:** Okay.  Well, long story short, Bitcoin PIPEs v1 was published
October 2024, and it was all about, well, the attempt to enforce post-covenants
or like pre-covenants and post-covenants, what's called pre-covenants and
post-covenants, without a soft fork or consensus changes, I mean kind of
externally.  So, Bitcoin PIPEs v1, we're focusing on trying to achieve this with
functional encryption.  Functional encryption is, well, futuristic.
Conceptually, it's how it should be.  And it's kind of the end game.  The
question was all about, can we make this run faster?  Can we make this run in
practice?  Can we make this run in production?  And what, a year, year and a
half later, v2 basically is all about that, is all about cutting out pieces here
and there, is about switching from functional encryption to witness encryption
which, spoiler, turned out to be still enough to enforce, I would say, the most
important covenants, like binary covenants and OP_VAULT, or like CSFS
(CHECKSIGFROMSTACK), I mean to emulate that effectively.  It's you know still
not very cheap to run, but come on, dude, that's witness encryption!  And over
the year, this went from, "Oh, it would be cool to run this sometime in the
future", to, "Well, you can run this, you have enough storage".  So, this is
what it is.  This is what Bitcoin PIPEs v2 is all about.

**Mike Schmidt:** Maybe, Misha, you can help explain a couple things for us.  I
think Jeremy Rubin, at some point, tried to explain to me functional encryption.
That was the first time I had heard of it.  Can you touch on functional
encryption and witness encryption a bit for the audience?

**Misha Komarov:** Yeah, okay.  So, both of them are pretty much
obfustopia-level cryptographic obfustopia primitives.  Functional encryption is
effectively a type of encryption scheme which allows you to decrypt and compute
certain things as the result over a ciphertext and the input you put through
there, only if the input satisfies a certain condition.  So, this way, you can
define this condition, you can predefine this condition.  So, effectively, it's
kind of cryptographically enforcing a certain type of computation if a condition
is met.  So, it's a generalization of a public key cryptography, where the key
is not just kind of the bytecode, but a circuit or a truth over a certain
circuit even more.  So, that's functional encryption.

Witness encryption is a, well, I would say a more lightweight brother of this
kind of functional encryption idea.  It doesn't allow you to compute a
complicated function over a ciphertext to output something large, like 256 bits,
or whatever the amount of bits you want to output as a signature, right?  But it
allows you to only output yes or no, effectively checking if the condition being
executed with a certain decryption algorithm over a ciphertext is true or not;
which means we can decrypt either 0, either 1, depending on if a certain ZKP is
correct or not; which means, well, turns out that it's enough to enforce certain
covenants.  So, that's what it is.

**Mark Erhardt:** So, basically you encode some predicates that allow you to
encode out-of-band conditions or criteria by which you want to lock up funds.
And all of that happens completely transparently or hidden, steganographically
basically, in the witness data.  So, all of the heavy lifting is out of band.
And this works today?

**Misha Komarov:** It works.  Surprisingly, we think we can state that it works,
the witness encryption part.

**Mark Erhardt:** So, you say that you can emulate certain covenants with this.
So, I guess, how would the average covenant user know that you're actually
enforcing the right conditions out of band?  They can't really see what's going
on under the hood.  How would a person that just wants to use the covenant
approach this?  Do they just trust you or is there more here?

**Misha Komarov:** Yeah, absolutely.  There is no need, or there is no idea for
somebody to trust anybody.  We wouldn't have spent a year otherwise doing the
work we've done.  I'd say, okay, so the idea is that just like, I guess, back in
the day, the key mechanism wasn't changed.  Initially, during the setup of a
certain covenant, there is a setup procedure for the covenant.  And of course,
we've got to be transparent in here, that there are like one out-of-band
assumptions there.  So, you've got to set up a certain covenant, like you've got
to generate a private key in like a DKG so nobody would know that key.  But of
course, the committee or whoever publishes the ciphertext on this key, you can
inspect and you can see what kind of circuit is required there for this
condition to be satisfied and the key to be unlocked.  And it's obviously also
kind of not required, but I would say it's expected for a committee to at least
publish a public key of the keypair they've generated, I mean so people could
see that once there is a transaction signed by a private key corresponding to
that public key, it means somebody has done the computation correctly and there
is a transaction and it's all valid.  So, basically, that's kind of the thing.

**Mark Erhardt:** Okay, so the ability to sign for the transaction guarantees
that the predicate resolved to true, and therefore the conditions that were
encoded were met.  And so, we trust in the setup procedure to some degree, but
other than that, if the setup was done correctly, we're good.

**Misha Komarov:** Nothing else can go south there.  That's the whole pitch.

**Mark Erhardt:** Cool.  Okay.  Yeah, anyone else got questions?  This sounds
like something that's down your alley, arbedout.

**arbedout:** Okay, this sounds incredibly interesting, and I really like the
idea that you don't have to wait for consensus changes to be able to test this
out.  I guess my first question is about, because this jumps out when you read
the paper, the 383 GB of data that is required.  As a user, do I need to fetch
that and run a cryptographic operation on it?

**Misha Komarov:** To be precise, it's not 338 GB.  Right now, at the time of
the first release of the Arithmetic Affine Determinant Program (AADP) witness
encryption with done, it's 338 TB, which is too much, obviously, yes.  But
again, we kind of calm ourselves internally that come on, dude, this is the
first witness encryption out there!  So, it's already good enough that we can
run something.  But we think we know, and there was a little bit of a banter in
the chat recently, we think we know how to reduce this to around 100 GB in terms
of ciphertext size.  Once we prove it's secure, because we don't have a formal
proof of that reduction in terms of security, we'll publish that as well.  It's
going to be like 100 GB per ciphertext.  So, effectively, it becomes similar to
what people do with garbled circuits, it becomes pretty close to what people do
with garbled circuits.  That's what it is.

In terms of, is a user expected to download the whole thing?  I mean, you can,
but can you outsource part of that computation somewhere?  Yes, that's the whole
thing.  You can outsource it to somebody who has enough computation capacity, or
you can outsource, I don't know, a significant part of it to somebody who has
enough storage capacity.  And I would say again, there is a mention of this in
the paper, but we think that as a way to batch a lot of keys into a into a
single ciphertext.  So, you could generate like several 100 or maybe 1,000, if
you wanted more keys inside a single ciphertext, and then decrypt, decrypt,
decrypt up to a certain limit.  I mean, of course, after a certain limit, it
becomes not really secure.  But up to a certain limit, you can keep this secure.
And this way, you don't need 100 GB per key, you basically need like 100 GB for
a certain amount you have batched inside.  So, that's kind of how it looks right
now.  But we wanted to be a little bit more conservative and put it out
experimental and speculative stuff.  I mean, we can talk about it like this,
right?  But when you put out the paper, you claim something, you'd better claim
something which you know works.

So, we know right now that this 338-TB thing is secure, more or less.  We
weren't able to crack it.  Anybody we consulted with wasn't able to crack it.
We spent significant time trying to crack it.  We will be doing public
challenges, we will be going around and we will lock some bitcoin behind some
ciphertext, behind some key, we will be like, "Okay, well, whoever breaks it
gets some bitcoin".  I mean, if you can retrieve the key, absolutely do it.  So,
that's just for the sake of making sure that this doesn't fall apart.  But yeah,
that's the situation there right now.

**Mike Schmidt:** Misha, we covered that you posted in Delving.  I believe you
or someone else also posted to the Bitcoin-Dev mailing list as well.  What's
reception been so far?

**Misha Komarov:** Well, I mean, Delving Bitcoin, as you might have notice, we
haven't seen anything negative.  I mean, there is interest, obviously.  There is
quite a lot of, I would say, positive reception.  Well, not very excited, of
course, because when people hear a phrase, "Witness encryption, and you can run
that", everybody gets like, "What?"  But in general, we haven't seen negative
feedback.  We've seen a lot of suspicion and we had to answer a lot of
questions.  It's okay, it's good.  We've seen a lot of positive results.  So, it
was like I said, seen positive reactions from, well, specifically from BitVM
guys.  We are yet to go around a little bit and to try to specify certain opcode
proposals, which were specified inside certain BIPs over time, like OP_VAULT.  I
mean, we know that it will deprecate, right?  But if we could do an analogous to
an OP_VAULT, I mean, anybody would mind?  I don't think anybody would mind.

So, we're yet to specify how certain BIPs, which we're interested in, which are
still interesting, over time can be expressed and can be replaced or can be
substituted or emulated with PIPEs.  We will be trying to go around relevant,
certain authors of BIPs, and then we will be trying to be like, "What do you
think?  I mean, maybe this can work today".  Like, this is one more thing we're
yet to do.  There might be something for us also to talk about with, besides
BitVM guys, to lightning folks, I mean because there's always a little bit of a
thing liquidity on the receiver side fragmentation, right?  So, if you have
OP_VAULT, or if you have some kind of vault, you could probably reduce that kind
of channel liquidity fragmentation there.  That's a little bit of improvement
there.  What else is there?  Yeah.  I mean, we could probably go around some
folks who try to do privacy-preserving Bitcoin transactions.  That would be
interesting.  Maybe we could improve Shielded CSV through that somehow.  That is
a couple of ideas it all comes down to basically, yeah.

**Mark Erhardt:** You mentioned BitVM a few times.  So, my understanding is that
BitVM allows you to encode these circuits, and then it's sort of optimistic in
the sense that they publish and if you find a mistake, you can challenge and you
have to publish big chunks of data, and then you can take the money.  It sounds
that your PIPEs are similar in what you can do with them, but the system works
rather with the zero-knowledge proof out of band.  So, there's no taking or
slashing.  Is that roughly correct?

**Misha Komarov:** It's pessimistic and single transaction and non-interactive.
That's the whole kind of pitch, yeah.

**Mark Erhardt:** Okay.  Is there other aspects that you would say are important
to compare or show the differences?

**Misha Komarov:** I mean, of course, maybe for now, one of the obvious things
for now, maybe the costs of storage are higher than what BitVM folks have right
now, right?  Of course, there are kinds of nuances about how BitVM constructions
in general manage the kind of reorg risks because of probabilistic finality,
which it's much easier for BitVM to handle that, because it's optimistic,
interactive, people are kind of okay-ish with that.  On the bright side, like on
the upside side, with PIPEs, well, if PIPEs were to be used as a foundation for
some kind of bridge, or this kind of stuff like the BitVM people do, this would
remove the operator liquidity requirements.  It would remove, I think, quite a
lot of interactivity.  I mean, it would remove the liveness risk, because the
whole decryption process is basically not interactive.  If the setup is done
correctly, then nothing can prevent you from just taking your bitcoin back if
something goes south, or whatever.  You can call it an escape hatch, if you want
to.  So, this kind of stuff.

Yeah, I mean, what else is there?  And of course, if you want to compare the
waiting period in terms of you've got to wait for somebody to submit a fraud
proof or this kind of stuff, well, there's nothing like this in here.  Once it's
decrypted, it's decrypted, it's there, the transaction is done.  So, this is the
attestation.

**Mike Schmidt:** Well, I think in those last comments that you made, Misha, I
think listeners, depending on what they do in Bitcoin, may have a call to action
to either check out the Delving post or reach out to you if there's something
they think is worth emulating or have questions.  Anything else you'd have as a
call to action for listeners?

**Misha Komarov:** I mean, we are looking to obviously as much feedback as
possible.  We are going to be looking for people willing to try to crack this.
I mean, it will be open challenges.  So, if you're a cryptographer person, or
whatever, don't hesitate to take a stab or, you know, we will be doing
challenges about this.  If you have ideas or you have good suggestions on which
BIPs also could use help of emulation via PIPEs, I specifically called for that
feedback, for those suggestions on Bitcoin-Dev mailing list a couple of days
ago, maybe yesterday, whatever.

**Mike Schmidt:** Great.  Well, Misha, thank you for joining us.  We appreciate
your time and if you have other things to do, you're free to drop.  Cheers.
We're going to jump to the Client and services segment and talk about a couple
of items before jumping back up to the news.

_Second releases hArk-based Ark software_

We're going to talk about Second releasing a hArk-based Ark software.  This is
in v0.1.0-beta.6, and we have Erik on who's going to walk us through, maybe
reminding us what Second is working on with Ark; and then, also jump into what
is hArk and how does it reduce some of these interactivity requirements we've
heard so much about.

**Erik De Smedt:** Okay, cool.  So, yeah, at Second we're building hArk.  It's
an Ark implementation and basically, we're just focused on sending and receiving
bitcoin, very straightforward and get user experience very well for users on
mobile, their phones, web browsers, not having to run a full node all the time,
to run a reliable wallet where you have some good sense of custody.  We started
building the Ark protocol as it was initially invented.  And basically,
especially for mobile phones, we ran a little bit into a problem.  So, the core
concept of Ark is basically, in Ark, you hold vTXOs and your vTXO is a bit like
Bitcoin UTXO.  The only difference is it's an output of a transaction that isn't
onchain yet.  You just have a chain of transactions, and in the best case, you
have a signature in the entire branch in that chain.  You can broadcast these
transactions and you're guaranteed that you can get your transaction onchain if
you need to.  It comes with a little bit of a trick, like this guarantee
expires.  After some point, the Ark server can basically sweep the coins, which
gives the Ark server the liquidity back, which is in the UTXO.  And to prevent
it, you need to participate in a round.  And basically, what you do is you take
your old vTXO, you forfeit it, and you will get a new vTXO in return.  And
that's basically the idea of participating in a round.

That process works quite well, but for mobile phones especially, it has one big
problem.  So, basically, the Ark server will host a round and let's say it will
do it at 1.00pm sharp.  Everyone who wants to participate in that round needs to
be online at 1.00pm sharp.  And we noticed, especially for mobile phones, that's
a huge problem.  You have some APIs to schedule a phone to wake up or send
notifications to the phone that they should wake up, but most of these things
are somewhat unreliable because smartphone manufacturers want to preserve
battery.  And we can say, "Please wake up at 1.00pm", but if you're unlucky, it
wakes up at 1.00pm and 30 seconds, and your phone has missed a round in the
refresh field, or it might not even wake up at all.  So, that's pretty terrible.

**Mike Schmidt:** And, Erik, what are the consequences if there isn't a wake-up?

**Erik De Smedt:** So, basically if you don't wake up, the phone will not
refresh the coin, and basically the old vTXO will expire.  And at that point,
you get in a situation where both you and the server could basically take the
money.  But at some point, the server actually has to take the money, because
they need their own money back.  It's in the same output.  So, basically, you
lose custody of your coins, which is very bad.  That's something we want to
avoid at any cost.  So, what we've been trying to do is, how can we make sure
that not all the phones need to be online at exactly the same time?  And it
turned out that the solution is ridiculously obvious.  So, in the round
protocol, which initially was a little bit convoluted, but basically there are
three steps in it.  So, the first one is if a round starts as a phone, you go
and say, "Hey, I want to participate in a round.  I have these vTXOs, I want to
get rid of this.  Give me a new one basically to sign up".  Then we have the
co-sign phase, where basically you sign your branch of transactions.  Ark works
with pre-signed transactions, it's some construction thing.  And then you have
the last phase, which is a forfeit, which is actually what we're diving in now.

Previously, we used a construct called connectors.  It's kind of weird, but the
core idea is that your forfeit transaction will have two inputs.  So, one from
the vTXO, which is forfeited, and basically that's the transaction where I say
as a client, "I give up my old funds".  But the forfeit also has another input,
and that goes back to the new round, which will give me the new vTXO.  It's a
little bit confusing.  But if you do that, at that point, basically as a client,
you're guaranteed that if you sign the forfeit, it will only be valid if you get
a new vTXO in return.  And the reason why it used connectors is actually because
the server, when it creates the new vTXOs, it needs to create a funding
transaction and it needs to put a round of money in.  And basically, it also
gives the same guarantee for the server, like you don't need to fund around
before you're sure all the old ones have been forfeited.  And for a while, we
thought that was super-important and you had to do it like that and hashlocks
didn't work.  But actually, that seems to be false.  So, what we now did is we
basically switched the order.

So, what will happen is the server will first fund around, and you think that
sounds dangerous, but we can ignore that for a while.  And then, at a later
point in time, the server or the clients can come online, sign the forfeits and
basically do it whenever they see it fits.  And if they come online two hours
later, fine, they can sign the forfeits and go through.

**Mark Erhardt:** Does that work with a similar construction as the connector in
the sense that only if you sign away the forfeit, you get your new vTXO?

**Erik De Smedt:** Basically, we now use hashlocks just like Lightning does it.
So, you sign now a forfeit transaction and that forfeit transaction gives the
server the coins if it releases a hash in time.  So, basically, we now just use
the standard hashlocks very much like Lightning works.  So, it's much closer how
Lightning works and pretty well understood.  And it's actually also safe for the
server, because the fact that you have a vTXO is kind of already a dust
prevention for the server, like you can't sign up without owning a vTXO, so the
server has control on how much money it will put in the new round.  It's turned
out to be surprisingly simple.  Our code became a lot smaller, clearer and
easier to understand when developing this.

**Mark Erhardt:** So, does this change anything about the amount of liquidity
that is necessary for each round?

**Erik De Smedt:** It doesn't change anything at all.  So, the liquidity
requirements stay exactly the same.  So, protocol-wise, there's not that much
that changes.  It also doesn't really change the trust model, at least not for
clients who can stay online.  So, if you're like a server and you can be online
at the time of the round, it doesn't change the trust model, but it allows
basically a fix for mobile clients who are not guaranteed to be online.  We had
the three phases, so the sign-up, which was the first phase, and we had the
co-signing phase.  If you run a node on a computer, which is always online,
you'll do the co-signing yourself and you will get the best security model.  If
you're a mobile client, you can ask others to co-sign for you.  So, the
co-signers will sign, they'll forget the key, so you get forward security.  It's
just all pre-signed stuff.  And that way, the mobile client doesn't have to be
online at the round, it can come online later and sign the forfeit when they
want to.

**Mike Schmidt:** Is the co-signing aspect here sort of a trade-off with this
new approach?

**Erik De Smedt:** Yeah, it's a trade-off, but it's fully optional.  So, the way
it's implemented, if you don't want the co-signing, you can still do it
self-signed.  But if you fail to co-sign, you can say, "Other people are allowed
to co-sign for me".  Even as a mobile client, how it's currently implemented is
basically you try to co-sign yourself.  If it fails, you fall back on the other
methods.  Oh, go, Schmidty, sorry.

**Mike Schmidt:** Oh, yes, sorry.  I was going to ask, I'm curious what the
other Ark implementations think of this approach.  Is this something that
everyone's going to be moving to?  Is this something that Second has a strong
opinion on and others differ?  Maybe just add some color there.

**Erik De Smedt:** I haven't gotten much responses there from the other teams.
I know we basically were pretty close to launch, but then we came on this idea
and it was like, "Hell, no, we're not going to build it while we have people
live on our system", because you're like doing open-heart surgery on the
protocol.  And if you have live users, it will be very hard.  So, I think once
you have an existing user base -- the engineering challenge of switching was
already hard.  I can only imagine it to be harder if you have to stay
backward-compatible for all the other users, because it's not backward
compatible at all.  I know other implementations have been looking at different
approaches.  They call it delegated refreshes, where basically you ask someone
else to participate in the round on your behalf.  The latest I know, it's
written in blogpost, but not in code, so it's not implemented yet.

I actually think the hArk model is better, because with the hArk model, it
actually comes with a few benefits.  So, the first one is if you rely on other
co-signers, let's say if we have ten co-signers, all ten of them can co-sign
your vTXO, and you'll get additional security from all of them.  So, that's
definitely a win.  It's not like that you just have the one guy you delegated to
do it, which is one thing which is really nice.  But also, a bit a downside of
the delegated model is basically, for your refresh to succeed, you need a server
to be online, like that's a hard thing because he needs to fund a new round.
But you also get, like, if you delegated to a third party, that third party
needs to be online to go to the server and say, "Hey, this guy allowed me to
participate in the round"; while if you just go to the server, "I want to
participate in that round just before expiry", you require less parties and you
can say, "If one of these co-signers is online, it's good".  So, it also can
give you a very robust model where you don't have to rely on too many other
people running services for you, because we see that might become a bit of a
reliability bottleneck.

**Mike Schmidt:** For listeners who want to try this out, we highlighted that it
was 0.1.0-beta.6.  Is this something that people can download and play with on
signet, or how do you recommend people try this out?

**Erik De Smedt:** I would recommend you to download it, play on signet.  If you
go to signet.2nd.dev, there's a demo environment, there's a faucet where you can
request Ark coins, you can make Lightning payments, onchain payments to a dummy
store.  If you use that, you can use it.  We have a CLI, we have barkd with a
Rust API.  So, on signet, you have quite a lot of things to play with.

**Mike Schmidt:** Excellent, Erik.  Anything else for the audience before we
wrap up this item?

**Erik De Smedt:** No, thanks.  Thank you very much.

_Sigbash v2 announced_

**Mike Schmidt:** All right, Erik.  Thanks for your time.  Thanks for joining
us.  We have a guest for another of our Client and service items.  This one was
titled in the newsletter, "Sigbash v2 announced".  And we have arbedout here to
talk about Sigbash and Sigbash v2, which now uses MuSig, WASM, and ZKPs.
Arbedout, we covered Sigbash v1, I don't know when it was, a couple years ago or
whatnot.  It seems like you've been hard at work at it.  It feels like a cool
project that I think people should be aware of, so I wanted to get you on to
talk about it.  Maybe talk about Sigbash and then we can get into v2 as well.
What have you been up to?

**arbedout:** Thanks, I really appreciate that.  So, I'll cover v1 briefly, I
guess.  V1 was a policy signer that used standard ECDSA, which doesn't really
afford you much opportunities for privacy, just the nature of the beast.  It
leveraged blinded xpubs, and the idea behind those is that we had the client
JavaScript deriving child keys using random paths from a master key that our
servers provided.  What that means is that users were given keys that the server
didn't know about up until signing time came around.  And once signing time
comes, of course, the server sees all of your transaction details still, because
it's ECDSA and PSBTs, the key itself as well.  Basically, you had privacy up
until you actually needed to use the server.  Now, that's a quantum leap ahead
of how normal signing works right now, where right off the gate, every member of
your ECDSA quorum sees your transaction balance and your entire history and
everything from the word go, even if you don't ask them to sign.  But it's still
not great.

So, the past couple of years, I've been exploring whether we could improve on
that model at all.  And what we've come up with is v2, which uses, like you
said, MuSig2, WASM, taproot, all that good stuff.  I'll talk through the
high-level flow of it, and then we can dig into questions.  So, you start off by
defining a signing policy, and that signing policy can be just about any
property of a PSBT, the inputs, the outputs, the amounts, the pubkeys, and it
can be as complex as you might like.  We take that policy, encode it into a
boolean abstract syntax tree.  So, all the logic gates you might remember from
CS101 AND, OR, XOR, NOT, everything that you might need to express a policy.  We
take that tree, walk it, and then turn that into a Sparse Merkle Tree, which I
know bitcoiners love, take the root node of that Sparse Merkle Tree, and just
send that single 32-byte hash to the server.  So, for all those transformations,
the only thing our server sees is that single hash.  It doesn't know anything
else about your policy.  And obviously, you can't really infer anything about
the policy itself from that hash.

Next, we create a key entirely in WebAssembly on the client side by fetching a
key from our server, generating a new key on the client, aggregating the client
side with MuSig2, and storing an encrypted blob on our servers.  So, from
beginning to end, from when you generate a policy to when you ask to sign a
policy, we never see your key, we never see your transaction, we don't even see
the sighash (signature hash) of the message being signed.

**Mike Schmidt:** Very cool.  I'm curious, like, I've seen some of the social
media discussion, I've seen you post about this.  Is this a service that is live
that you are providing now, this co-signing service?

**arbedout:** It is live right now.  You can go on sigbash.com and start paying
your way on the web app right now.  You don't have to download and install
anything.  That's the great thing about WebAssembly.  Right now, it's live on
signet.  If you go looking, you can figure out pretty quickly how to go live on
mainnet.  Maybe give us a couple of weeks before you do that.  We're still
making sure there are no bugs.  I have fond memories or not so fond memories of
someone on v1 immediately locking up about $5,000 in sats in a key that we had
to struggle to help them send.  I don't think we have any bugs this time around,
but give us a little bit before you try on mainnet.

**Mike Schmidt:** And is this open source?  Are you providing this as sort of a
company and you're charging for this service, or how does it work in that
regard?

**arbedout:** So, my plan is, and this is still loose, so bear with me, don't
hold me to this, but I think the web app is going to be free as long as I can
manage that.  It is a company, we are incorporated, but I think for that level
of integration, we need an SDK, which is what we're working on.  We're talking
to partners right now at exchanges, at custodians, anyone who is currently
handling signing or signing adjacent, whether it's multisig or watch-only
wallets.  We're probably going to be focusing on the SDKs, the commercial
enterprise, and the web app will be for all the crazy mountain-men node runners
who want to use it.

**Mark Erhardt:** So, you said that the server doesn't even see the message that
is being signed.  Are you referring to the transaction itself at this point with
message?

**arbedout:** Yeah, the transaction.

**Mark Erhardt:** So, it's completely blinded to the server; the server is
enforcing the policy that you committed to when you created it and signs off on
it when the policy is fulfilled, but doesn't even know which transaction it
signed?

**arbedout:** That's correct.  So, under the hood, what that looks like,
remember the server sees that root Sparse Merkle Tree, a hash?  What the client
in WebAssembly submits, you as a user upload your PSBT, WebAssembly parses that
PSBT.  Providing that your PSBT matches one of the clauses of the policy that
you defined, it will submit a proof bundle consisting of a path leaf with the
merkle inclusion proof proving that that path belongs to your original root
hash; a zero-knowledge proof proving that you know the inputs that can create
that path leaf; and a very small schnorr proof of knowledge, tying it to the
sighash, the message being signed.  So, end-to-end, you know, okay, this person
has a PSBT that must be able to create these inputs, and that PSBT must be tied
to a valid transaction.

**Mark Erhardt:** Sorry, I'm confused.  So, you provide a PSBT of the
transaction?

**arbedout:** On your side, and then, from there on, WebAssembly is parsing it
and providing, basically proving that you have a PSBT that semantically meets
the policy that was originally defined.

**Mark Erhardt:** Oh, the WebAssembly side sees the PSBT; the server does not
see the PSBT?

**arbedout:** Yeah.

**Mark Erhardt:** Okay, that's what I was missing.  Okay.  I was like, if you're
sharing the PSBT, you still see the transaction, just with extra steps.  But
yeah, okay.  So, only the client side has the PSBT.  Okay, cool.

**Mike Schmidt:** Well, I guess the call to action for listeners is pretty
straightforward.  Come play with this thing, right?  Is there anything else,
arbedout, that you want people to know?

**arbedout:** The nature of Sigbash v2 is that once it launches on prod, it's
set in stone.  So, please bang on it and let me know if there are any features
we're missing.  Just like Erik said, it's very difficult to have two different
versions of proof bundles, for example.  So, if there are conditions that you're
saying that are missing, please let us know.  We've implemented everything from
the basic stuff, like inputs and outputs and pubkeys and amounts, to more
complicated stuff, like covenant emulation.  But if there's anything we're
missing, give us a shout.

**Mike Schmidt:** Awesome, arbedout.  Oh, go ahead, Murch.

**Mark Erhardt:** Yeah, I feel like we're talking about very much similar ideas
a lot lately.  So, BitVM, the PIPEs previously, Sigbash.  Someone recently asked
me to read something in the comments on our tweet that was also sort of encoding
functional functions.  So, is this just taproot coming to roost; after taproot
being out for four years, people have had time to bang on the pot?  Or what
makes all of you come out with your projects at the same time?

**arbedout:** Speaking only for myself, I think definitely part of it is just it
takes time for tooling to be implemented.  A lot of what I built with Sigbash v2
required the upstream libraries to implement MuSig2 support and taproot support.
And then, there is obviously a learning curve trying to think about, "Well, what
can I do with this?  What is now possible?"  And then there's a sort of second
level.  Once you start seeing that initial trickle of other projects working on
things, that you draw inspiration from that and start thinking, "Oh, well, zero
knowledge, what can I do with this?"  In the case of at least the zero-knowledge
side of things, again I'm speaking only for myself, but I sort of can infer this
from comments other people have made, there's a pretty influential paper that
was released about two years ago called, Concurrently Secure Schnorr Signatures,
where the authors proved that the idea of zero knowledge predicates and how that
might work in theory with schnorr sigs.  And I remember Jonas Nick tweeting that
out, and then a bunch of different projects latching on to that and starting to
have discussions, "Well, zero-knowledge covenant-ish type things, what can we do
with this?"

I think it sort of is time, but it's a combination of time passing and then
people experimenting, and then other people getting ideas from those
experiments.  And then it's just a slow-moving avalanche.

**Mark Erhardt:** So, it's just the ideas floating around and then basically
infecting each other until something falls out.  And there's like four or five
different things that are very similar that have different trade-offs and now,
yeah, I guess we're getting all of them!

**arbedout:** Yeah, I promise we don't have some like pseudo covenants dragon's
den slack room that we're all meeting in to talk about this.  It's all actually
organic.  It's interesting, both for PIPEs and I think there's that other
project, BLISK, that announced a couple of weeks ago.  They're very similar
orthogonal ideas and you can see none of us have communicated with each other.
It's all after the fact, we've been DM'ing like, "Oh, wow, this sounds very
interesting.  We seem to be on the same wavelength", but it's completely
organic.

**Mark Erhardt:** Talking about covenants.  So, all of, or not all of you, some
of you are basically emulating covenants.  And what if we actually introduce
some of these opcodes into Bitcoin any decade now?

**arbedout:** Speaking only for myself, I would love that.  I think just from
the co-signing point of view, if you're using a co-signer to emulate covenants,
you either didn't need covenants or you're making do with something that
probably isn't purpose-suited for you.  The difference is the trust model.
Covenants, when enforced by consensus, are guarded by the Cyber Hornet crowd.
It's onchain and public, and everyone's nodes are enforcing it.  What we're
doing is offchain, private, and you're not really trusting the co-signer because
the co-signer doesn't see anything.  They can't be censoring you based on
transaction contents that they can't see, but you are trusting them to be online
and to sign things dutifully.  It's a radically different trust model.  From my
point of view, if covenants were to go live tomorrow, I think we'd start
building all sorts of cool new features on top of that, and I'm sure the PIPEs
guys would say the same thing as well.  As much as I would like to think
otherwise, there is no pool of Bitcoin users waiting and hoping, "Oh, I'm going
to write Bitcoin Script by hand for my transactions and these opcodes will slide
into it".  It's the builders like us that are actually going to make use of
those opcodes.

**Mark Erhardt:** Thanks for the perspective.

**Mike Schmidt:** Very cool.  Thanks for joining us and hanging on through the
first half of the newsletter, arbedout.  You're welcome to drop a few other
things to do.

**arbedout:** Thank you for having me.

_Recent OP_RETURN output statistics_

**Mike Schmidt:** Cheers.  Jumping back up to the newsletter, we had our first
News item, which was titled, "Recent OP_RETURN output statistics".  And we
covered AJ Towns' post to Delving Bitcoin about analysis that he did on
OP_RETURN usage since Bitcoin Core v30 was released, which was October 10th, I
believe.  And he has his analysis, but he also linked to analysis from a couple
of other people, orangesurf, and also, Murch.  Murch is obviously here and has
done some of the analysis hands-on and read both of the other analyses.  So,
Murch, what should we take away from this?  Well, I guess, what was found, and
then we can get into takeaways?

**Mark Erhardt:** So, I think the context of this is people making arguments
about the amount of OP_RETURN outputs we've been seeing, and maybe also putting
that in the context of what would be allowed, given some soft fork proposals
activating or not activating.  It's just giving the raw numbers on that.  So, AJ
has looked at some 20,000 blocks or so, 20,200, I think.  And in those blocks,
he found 24 million OP_RETURN outputs.  And out of those transactions, 24
million transactions with OP_RETURN outputs, 460 either had multiple OP_RETURN
outputs or oversized OP_RETURN outputs, where oversized means 84 bytes or more.
So, 24.3 million transactions with OP_RETURN outputs, 460 are affected or
subject to the new OP_RETURN policy by Bitcoin Core.  So, most of these would
just be completely unaffected, would not have changed their behavior at all if
the policy change in Bitcoin Core v30 hadn't been made.  And maybe also, to make
it very clear, 24,360,000 of those transactions minus 400 would also be in
reduced data, temporary soft fork chain, because they're compatible.

So, altogether, AJ found that there were about 474 MB of OP_RETURN data in these
20,200 blocks.  And of that, I wrote it out.

**Mike Schmidt:** Now we have the 'explicit' tag on Spotify.  Thanks, Murch.

**Mark Erhardt:** 2 MB.  2 MB of that were oversized or multiple OP_RETURN
outputs.  So, out of 474, 2 MB were affected, or could have been affected by the
mempool policy change for large OP_RETURNs in v30.  So, this is a tiny portion.
I think anyone still making the argument that OP_RETURN has been used a lot more
than it was before, I think it has been minusculely used more.  There are a few
more transactions, but in volume, I looked at this data myself, I published a
dashboard on dune.com that aggregates the OP_RETURN data per week.  And the
dashboard showed me that there were about, well, a similar amount of
transactions and data bytes in OP_RETURN outputs before v30.  And especially
also, oversized OP_RETURNs have not changed significantly.

So, the facts themselves, they are hard to argue with because they're facts, but
the interpretation that I have is that the OP_RETURN policy did not
significantly change the usage pattern of this on the network.

**Mike Schmidt:** And, Murch, I don't know if it was your analysis or some other
comments that I've seen, but there was actually a spike, well not a large spike,
but there was a few oversized OP_RETURNs that happened about a year ago before
the release, right?  Just mostly around, I don't know, the discussion of large
OP_RETURNs, like people playing around with it.

**Mark Erhardt:** I mean, a bunch of people went around and claimed that
oversized OP_RETURNs were hard about a year ago.  In April, when the policy was
debated whether or not the OP_RETURN mempool policy still has teeth and does
something useful, a few people, especially those that were against the change in
Bitcoin Core, made the argument that it was essentially impossible to do before.
So, I think this spurred a bunch of people that just felt the need to show that
it was incorrect to say so, to make a lot of oversized OP_RETURN outputs.  So,
the biggest spike in the last couple of years actually was April last year, when
there were, I think, some 10,000 or so oversized OP_RETURN transactions, just to
demonstrate that it was completely possible to do.  And yes, so the debate
basically provided parallel proof just how loose that policy was already, how
little enforcement it got.  Yes, only a few miners were including those
transactions at that time.  But unless you're urgently trying to get your
transaction in, it only takes a few miners to include it to get 100% of those
transactions in.

So, I think it succeeded in demonstrating that the policy was not very useful
anymore at that time.  And especially in the context that the inscription
envelope being cheaper for large amounts of data anyway, and being standard and
being widely deployed, continuing to enforce the OP_RETURN limit in order to
forbid a use case that naturally already was not incentive-compatible, except if
people were putting data in payment outputs, which was slightly more expensive,
just didn't make sense.  So, I think that our argument that we made as Bitcoin
Core developers back then still stands.  There is no big economic incentive to
use large OP_RETURN outputs because people are going to use the inscription
envelope instead.  And for people that use payment outputs to stuff data,
OP_RETURN being slightly cheaper and now allowing more than the 83 bytes per
transaction, actually allows them to use the OP_RETURN output instead of putting
data in payment outputs.  And I don't think it's controversial that putting data
into payment outputs is worst kind of data embedding.

So, the inscription data will not move to OP_RETURNs just as predicted, and
hopefully some of the payment data will move to OP_RETURNs, where it's less
harmful.  So, I don't know.

**Mike Schmidt:** In any of these analyses, are you aware of categorization of
the small number of OP_RETURNs that do exist, like into buckets other than just
truly arbitrary content?  Like, obviously I can put, "Mike is the greatest",
piece of content in there and that's just arbitrary content, but also people try
to structure their data and create these protocols.  Like, is there anything
other than just people putting in arbitrary stuff?

**Mark Erhardt:** I'm not aware of anyone having done further analysis than just
on size so far.  But yeah, I think most of them are probably text at this point.
We've seen, just as AJ found some 400 or so oversized OP_RETURNs, which is not a
lot, sure there's probably a couple of pictures in there too and something else,
whatever.  But yeah, I'm not aware of anyone actually having done the whole
analysis.  Orangesurf has published a report for mempool.research.  I did
briefly skim it.  I don't think it went into this aspect either, but if any of
us three, it would be in there.

_Amboss announces RailsX_

**Mike Schmidt:** That wraps up the News.  We'll jump back to the Changes to
services and client software segment.  We have three others that we didn't touch
on.  One was Amboss announcing RailsX, and this is a platform built on LN and
using taproot assets to support financial services, including things like
high-frequency trading or swapping between, let's say, Lightning bitcoin and a
stablecoin, or some such thing that's on taproot assets.  And we link to their
post that outlines what they're looking to build or have built already.  So,
check that out if you're interested.  Gustavo or Murch, anything?

_Nunchuk adds silent payment support_

We highlighted some support for silent payments from Nunchuk.  So, Nunchuk added
support for sending to silent payment addresses.  I don't believe that Nunchuk
supports actually creating a wallet that can receive silent payments, but you
can send out of your Nunchuk wallet to a silent payment address.  So, that's
pretty cool to see that building support for silent payments over time.

**Mark Erhardt:** Also, maybe sending to silent payments is a little
complicated, but it doesn't require that special scanning, or all you need is to
know all of the inputs and the recipient you're trying to pay, and then you can
construct the correct silent payments output.  So, sending support is quite
achievable by pretty much any wallet.  If you want to receive, it gets a little
more complicated because you need that special scanning mode, where you
construct a shared secret from the input public keys and your own private key
and compare that to all P2TR outputs.  So, especially on light clients, that is
a bit of a heavier lift.

**Mike Schmidt:** And we dove pretty deep with Craig Raw recently and talked
about some of the challenges of scanning.  I think last week you guys had
Sebastian on also talking about scanning.  So, if folks head to the podcast list
for Optech, look for the one last week, which would be #392, and then also
cruise back for the most recent Craig Raw one, where we talk into some of the
challenges with that.  It's definitely not prohibitive for wallets to implement
that, but there are some interesting challenges and it's not quite as easy, as
Murch outlined, in terms of sending to a silent payment address.

_Electrum adds submarine swap features_

Last piece of software we highlighted this month was Electrum adding submarine
swap features in Electrum 4.7.0.  I think they had some submarine swap features
previously, but in 4.7.0, using Electrum you can now pay onchain using your
lightning balance.  This is the notion of submarine swapping.  That's the
feature that we highlighted from this release, but there are many other features
and fixes in this Electrum version as well if you're curious.

**Mark Erhardt:** Wait a second, so submarine payments, I knew that as having an
onchain payment as the last hop, like in a multi-hop HTLC (Hash Time Locked
Contract); or vice versa, having an HTLC-based onchain payment first to pay into
a Lightning channel.  But isn't paying out of a channel balance to an external
address just a splice?  Sorry, I'm the terminology nerd here!  I think they just
implemented splicing even if they call it submarine swaps.

**Mike Schmidt:** Yeah, they're calling it Submarine Payments actually in their
release notes, and then they also refer to it as, "Supporting reverse swaps to
external address".  But yes, functionally similar to what you outlined there.

**Mark Erhardt:** Sounds like a splice to me, outgoing splice.  Anyway.  Let's
move on.

**Mike Schmidt:** We'll jump to Releases and release candidates and also Notable
code and documentation changes.  Gustavo authors this every week, which we are
very grateful for.  So, he is the most informed person on this podcast to also
walk us through it.  And we're grateful for that as well.  Gustavo, what do we
have this week?

_BTCPay Server 2.3.5_

**Gustavo Flores Echaiz:** Thank you, Mike and Murch for the intro.  Yeah, so on
the releases, we have one from BTCPay Server and one from LND.  Both are pretty
straight forward and pretty light.  So, the BTCPay Server v2.3.5 mostly adds
support for multi-coin support, so BTCPay Server allows you to use bitcoin, but
other altcoins as well.  So, support is extended that, for example, you don't
need to use bitcoin if you're using other UTXO-model coins.  Previously, you
were forced to sync a Bitcoin node to use other coins that are also based on the
UTXO model; now, you're no longer forced to sync a Bitcoin node for that.  Just
other things that were added are additional fixes, some user-visible fixes, such
as an image that wouldn't display correctly on mobile.  And an important one is
payments were getting undetected on LND, when your LND node restarted while your
BTCPay Server store was listening for LND for a new payment.  Then, on a
restart, it would fail to listen to new payments.  So, that bug fix was also
part of this release.

Finally, some new currency exchange rate providers for some additional
currencies, I believe, mostly INR, which is probably Indonesia or India based.

_LND 0.20.1-beta_

And then the next release is LND v0.20.1.  So, we teased, I believe, in two,
three newsletters ago, the RC of this release, and now this is the official
release.  There's many bug fixes included here.  One that I highlighted was a
panic recovery from gossip message processing, improvement around reorg
protection, and LSP detection heuristics.  So, these are things we've talked
about in previous podcast episodes.  But there's about ten bug fixes included in
this.  And the heaviest part of the release are the bug fixes and the additional
features that I mentioned earlier.  That would be it for this part, unless you
guys have any notes.  No?  Awesome.

_Bitcoin Core #33965_

So, we can proceed with the notable code and documentation changes.  So, we have
one from Bitcoin Core and a few ones from the LN implementations; and finally, a
new BIP, BIP360, and two updates on the BOLT specification.  So, let's start
with the Bitcoin Core PR #33965.  So, here, a bug is fixed around a concept
called -blockreservedweight.  So, when a miner constructs a block, he will
reserve some weight of the block for the block header and the coinbase
transaction.  That is what this value sets.  So, there's two ways of setting
this value.  Most RPC clients will simply set it to the startup config,
-blockreservedweight.  However, if you're an IPC caller, particularly a Stratum
v2 external client, you will use the mining interface and you will create your
own block using another value set, also called block_reserved_weight.

The problem was that if I'm an IPC client and I'm using the second value
block_reserved_weight, and I also set a startup config -blockreservedweight,
they will enter in conflict, and the startup config option will overwrite
silently the other value set.  So, here, what is done is that if an IPC caller
sets specifically the IPC value, then the startup config value that would
previously override it is now ignored for the one that IPC callers specify for
that one to take effect.  Yes, Murch?

**Mark Erhardt:** Basically, this is just more special case overrides more
general case.  And so, the general case is the startup configuration.  The node
generally uses the startup config.  But if you specify something more specific,
per the IPC, that should take precedence.  And the bug here was that the startup
configuration took precedence rather than the mining IPC value.  So, both of
them can set it, and if a client specifies something specifically on the call
that it is making, then obviously that's more important.

**Gustavo Flores Echaiz:** That's exactly right, Murch.  Thank you for
clarifying that.  So, that is fixed.  Another part of this PR is also the
enforcement of a value called MINIMUM_BLOCK_RESERVED_WEIGHT that would silently
clamp a value that was conflicting with this minimum value.  And now, instead of
silently failing, it will respond with an error message telling you that you
cannot set a block reserve weight value that conflicts with the
MINIMUM_BLOCK_RESERVED_WEIGHT setting.

_Eclair #3248_

So, we move forward with Eclair.  We have #3248, which is a fairly simple PR,
where basically if you have the option as a note to forward a payment through a
private channel or a public channel to the same destination, now Eclair will
prioritize the private channels when relaying payments, simply because private
channels are not publicly viewable.  So, if you're taking a public channel,
you're then sending a channel update to the rest of the network, and the network
believes you have less capacity because they're unable to see that you also have
a private channel with similar capacity.  So, Eclair now always prioritizes the
private channel.  But there's another part of this PR that when two channels
have the same visibility, let's say I have two private channels or two public
channels, Eclair now prioritizes the channel with the smaller balance.  This
allows it to keep channels with bigger balances available for payments that
would need more capacity.  Any comments here?  Perfect.

_Eclair #3246_

We move forward with Eclair #3246.  So, here, many new fields are added to
internal events.  For example, miningFee field present in an internal event
called TransactionPublished is split between localMiningFee and remoteMiningFee.
Another computed feerate field is also added to this event.  The point here,
maybe the details are not as important as to understand why this was done.  The
goal here is to bring more visibility or auditability into the economic
performance of our peers as a node.  So, if we're able to get all details around
the fees paid at all levels then we have better visibility into the economic
feasibility or economic performance of our different peers.  Another important
point is an optional purchase liquidity ads field is added to link a transaction
to a liquidity purchase.  So, if you made a transaction through a liquidity
purchase, now a field appears that would link the transaction with that
liquidity purchase.

Also, channel lifecycle events now include a field called commitmentFormat to
describe the channel type, whether this was an anchor or non-anchor channel
type, and eventually other forms of channel types, such as simple taproot
channels.  So, yeah, all of these fields, the goal is to bring more visibility
into the economic performance of your different peers.

_LDK #4335_

We move forward with two PRs around LDK.  The first one, #4335, this is an
interesting one.  It brings a concept back that was mentioned in Newsletter
#188, called phantom node payments.  And it applies it for BOLT12 offers.  So,
what is a phantom node payment?  It's a payment that multiple nodes can claim.
In the BOLT11 format, it uses something similar to stateless invoices.
Basically, it points to a phantom node, a node that doesn't exist, but multiple
nodes could basically intercept that payment and keep it.  Yes, Murch?

**Mark Erhardt:** Right, basically the idea is if you run a large operation on
the LN, you might have multiple nodes running at the same time that are
load-balancing, and they have their own channels, and you want to be able to
spin out one of them and do an update, or whatever, while still being able to
process all of the payments.  And in order to do so, you create a pretend node
or make up a node that sits as a channel partner behind all of your other nodes.
So, let's say you have three nodes, Alice, Bob and Charlie.  They are the actual
Lightning nodes that have actual channels to other nodes in the network.  And
then, you make up a phantom node, Philip, that has a virtual pretend connection,
like super-big channel, between Alice and Philip, Bob and Philip and Carol and
Philip.  And now, every time you get a payment, you make out all of your
invoices to Philip, but they could all go through any of the three other nodes
to reach Philip.  And instead, you collect the payment at the level of Alice,
Bob and Carol.

**Mike Schmidt:** I've been thinking about it.  You guys tell me if I'm thinking
about it the right way.  Is this sort of like load-balancing, like everything
goes through one, but then it can get routed to one of three behind the scenes?
Is that kind of how it works?

**Mark Erhardt:** No, it always goes to one.  And by trying to go to that one,
it will have to pass through one of the three.  And similar, but not quite the
same.  And by having these other three nodes that all do their own channels,
that all have liquidity floating around, if for example one of the three nodes
had all of their capacity on the outbound side and couldn't receive an inbound
payment, if you can't route through Alice to Philip, you can route through Bob
to Philip.  Or if Carol is getting a software update and is down for three
minutes, you can still route for Alice and Bob.  But all of the invoices are
created as if Philip were the recipient, and that way you get that flexibility
for routing from any of your nodes.  Otherwise, if you gave out all of the
invoices with Alice, Bob or Carol, if one of them goes down, that node can't
receive, or if the liquidity locks up.  I mean, you could still have huge-ass
channels between Alice, Bob and Carol in order to make that work most of the
time.  But if one of them is actually offline, you just can't receive those
payments at that time and all of the payments will fail.  So, it's sort of a
trick to be able to get redundancy.

**Gustavo Flores Echaiz:** So, in this PR, basically this feature is brought for
BOLT12 offers.  So, as a receiver, I will create a BOLT12 offer with multiple
blinded paths, and let's say I have three different blinded paths and each one
would terminate at a different node that I have, right?  So, then, technically
the payment could be made to any of those nodes once they received any of those
nodes' response to the invoice request, but the resulting invoice after the
invoice request can only be paid to the responding node.  So, let's say the
phantom payment part only happens at the invoice request level, and then it can
only, once there's an invoice issued, that invoice can only be paid to one
specific node.

**Mark Erhardt:** I just realized something completely unrelated, but if you
have a blinded path and the payment fails in the blinded section of that path,
you do know what nodes were in that.  Do you learn what nodes were in the
blinded path by them reporting the issue?  We should have a Lightning person on
this.

**Mike Schmidt:** This is when the t-bast bat signal, the bast signal should go
up.

**Mark Erhardt:** The bast signal, wow! Yeah, the t-bast signal.  Anyway, if you
know the answer, you could just enlighten us on Twitter below this post or
something.

**Gustavo Flores Echaiz:** Maybe through some sort of attributable failures
implementation, this could be known, you know, but maybe there's even
limitations to that.

_LDK #4318_

So, we move forward with LDK #4318.  This is a fairly simple one where the
max_funding_satoshis field from the ChannelHandshakeLimits is removed.  And what
does that mean?  It basically removes the pre-wumbo or the pre-large channels
default channel size limit.  So, there was an issue because LDK, at the same
time, by default was limiting channels to the pre-wumbo default channel size
limit, but at the same time it was advertising support for large channels by
default.  So, if you were a peer of an LDK node, you might try to open a large
channel to an LDK node for them to see that it fails, because LDK advertised
support for large channels, but behind the scenes it didn't really accept them.
So, now, this PR basically brings the advertising to be real.  Now, LDK by
default will accept large channels.  Users, however, who want to limit risk and
want to avoid large channels can use the manual channel acceptance flow and can
configure rejecting channels that are of a larger size than they want.

_LND #10542_

We move forward of LND #10542.  So, this is an interesting one because the graph
database layer is basically extended to add support for gossip v1.75, also
called gossip v2.  This was mentioned in Newsletter #261 and #326, but basically
gossip v1.75 is an extension of the gossip protocol to allow for channel
announcements of simple taproot channels.  So, we know LND has been going down
the simple taproot channel direction for a while and this has been work building
for a long time.  So, now LND can store and retrieve channel announcements on
its database.  However, this doesn't mean that LND has completed support for
gossip v1.75.  It remains disabled at the network level, pending completion of
validation and gossiper subsystems.  So, additional work is required for LND's
implementation of gossip v1.75 to take fully effect.

_BIPs #1670_

We move forward with BIPs #1670.  This is the publication, or it adds basically
BIP360, which specifies Pay-to-Merkle-Root or P2MR, which is a new output type
that is very similar to P2TR, the taproot output type, but it removes its
keypath spending or keyspending path.  The reason why this is done, it's to be
resistant to long exposure attacks by cryptographically relevant quantum
computers.  So, this is a topic that has been discussed a lot publicly, how to
make for taproot or P2TR output types to be resistant to, let's say, a quantum
computer using the Shor's algorithm.  Well, this is the solution for that.
However, this is not a new output type that would protect against short-exposure
attacks, because when you broadcast your transaction of a P2MR output, you would
then sign for that output.  And during the time it is unconfirmed, there could
be a short-exposure attack theoretically from a quantum computer.  So,
additional research is being done for other post-quantum signature proposals.
I'm guessing, Murch, you might have some comments on this?

**Mark Erhardt:** Yeah, so BIP360 had been in the works for, I think, over two
years.  The proposal was previously named differently, too.  So, if you don't
recognize P2MR, you might have known it as pay to tapscript hash (P2TSH) or pay
to quantum resistant hash (P2QRH) before.  It really came together in the past
couple of months after it got a complete rewrite.  And basically, it is the
first concrete proposal for any output type that has any benefit regarding
quantum.  My understanding is that the authors are looking into combining this
with an actual post-quantum secure signature scheme, which we've heard a lot
about here as well from, for example, Jonas Nick and Mikhail, that were on in
the last month or so.  Anyway, as Gustavo said, P2MR uses the same tapscript
stuff under the hood, just like P2TSH, but because it doesn't reveal an ECDSA
public key onchain, it is not vulnerable to long-exposure attacks.  It is still
vulnerable to long-exposure attacks if an address is reused, and the
post-quantum signature scheme is not available yet.  So, the idea would be,
presumably, to put a post-quantum signature scheme into an OP_SUCCESS opcode,
and then use that directly in tapscript, which is the script variant that we use
in P2TR leaf scripts, and then also now in P2MR leaf scripts.

Yeah, the obvious downside of these post-quantum schemes is that all of the so
far proposed ones are much, much larger, with public keys being about 3,000
bytes and signatures being somewhere around 8,000 bytes.  And if we compare that
to the current 32-byte public keys and 64-byte transactions, that's a two
magnitude increase, of course.  And, yeah, so we'll keep monitoring this
situation.  So far, I've not been affronted by any quantum computer on my way to
work, but we'll keep working on this, I guess.

**Mike Schmidt:** Murch, you mentioned this is a step towards quantum
resistance, but in terms of just having P2MR, you mentioned the short range, so
I mean, P2SH, for example, would be equally as safe, right, these sorts of
things?

**Mark Erhardt:** That is correct, yes.  So, P2WPKH or P2SH would give you the
same resistance to quantum attackers right now, as long as you don't reuse any
addresses where you reveal the actual spending conditions only at spending time.
And then, the attacker would have to reverse the private key from the public key
in the time from the unconfirmed transaction being broadcast and confirmed in
the chain.  So, given that quantum computers are actually pretty slow, or
there's different variants, but basically just the calculations take on the
order of hours.  If you make a transaction that goes into a block i n the next
hour, you're just not going to be vulnerable to that, and also not going to be
vulnerable to that if we ever get quantum computers that can make calculations
that can calculate private keys.

So, far, my understanding is that there are projects that have come up with one
physical qubit, and it's a big question how to get two of them to talk to each
other.  There are also advances on algorithms for quantum attacks, and the
number of qubits that are necessary to make these attacks keeps going down.  But
if we're actually still at a phase where these computers can run only in huge
facilities that are physically cool to almost absolute zero, where you have to
shoot lasers at specific spots on the chips in order to introduce the quantum
state, then you have tons of noise reading that out.  And we have no clue how to
make two of them talk to each other with, as far as I'm aware, the only
experiments that have been successful being factoring 15 and 21, when the
circuit design already included those numbers as heavily hinted, in order to
even factor numbers like that.  I'm just not very scared that we're going to be
able to factor 256-bit numbers anytime soon, and especially not in the time
between an unconfirmed transaction being broadcast and an unconfirmed
transaction being confirmed.  So, yeah, I'm still very much in the camp that we
have to react to quantum because so many people are worried about quantum, but
I'm not worried about quantum computers.

**Mike Schmidt:** Well, it seems like maybe the Bitcoin community should be
worried about quantum in proportion to the output of the quantum side of the
equation, right?  It's like you said, Murch, it can't factor 21, but Bitcoin's
supposed to have a signature scheme deployed, right?

**Mark Erhardt:** I mean, other systems are upgrading right now.  So, NIST has
been recommending that all online systems, websites, and online banking, and so
forth use post-quantum cryptography by, I think, 2035 or 2030.  And of course,
for these systems, that's fairly easy because when we're streaming hundreds of
GB of data just to watch movies, well, GB per hour per user, then sending a few
kB to establish an encrypted connection is not a big deal.  But in Bitcoin, what
we're doing is we have a highly replicated, very, very small throughput
blockchain, and if we have 1 MB or up to 4 MB per 10 minutes, giving them away
in chunks of 3,000 to 8,000 bytes for public keys and signatures is going to
significantly reduce the throughput.  And therefore, for us, the trade-off means
that we're going to reduce our capacity by 100x if we just blindly roll this out
today.  And meanwhile, with all of the recent interest in the topic again,
cryptography is making progress.  So, if we wait a couple of years, we might
have way more efficient schemes, way smaller schemes, that we'd much rather
commit to maintaining for the next five decades, hundred years, whatever.

So, I think being aware, doing the research, putting it into the context of the
trade-offs that we are solving for in Bitcoin is currently the right strategy.
And saying that we need post-quantum signature schemes yesterday in Bitcoin, and
everybody should also start using them right now, is I think just a little too
rushed.

**Mike Schmidt:** Agreed.

**Gustavo Flores Echaiz:** Thank you Murch, I completely agree with all you
said.  So, listeners can look up the episodes in Newsletter #344 for the first
coverage that we did on this BIP360, when it was called P2QRH, and Newsletter
#385, which was a Year-End Newsletter, also has a strong, big section around
quantum which includes this when it was called P2TSH.

_BOLTs #1236_

We move forward with BOLTs #1236.  Here, the specification around dual-funding
channels is updated to allow either node to send RBF to basically fee bump a
channel funding transaction.  However, previously, only the channel initiator
could do this and now this is extended for both peers to be able to do it.  The
reason why this is done is because in the PR #1160 that defines channel
splicing, this is a proposed part of splicing.  So, the goal was to align dual
funding with splicing to allow both sides to initiate an RBF.  There's also
requirements added that both senders of the RBF initiation must reuse at least
one input from a previous attempt, ensuring that the new transaction
double-spends prior attempts, right?  So, this is a condition around RBF, but
it's more properly specified in this PR to make sure that all details are
covered.  Any thoughts here?

_BOLTs #1289_

Finally, BOLTs #1289 changes how the commitment_signed message is retransmitted
when nodes reconnect in the interactive transaction protocol, which applies both
to dual funding and splicing.  So, the reason why the work here is done is
because the goal is to avoid unnecessary retransmission, which is especially
important for simple taproot channels, when retransmitting the commitment_signed
message would require a full MuSig2 signing round due to nonce changes.  In
other channel types, this is not that concerning.  You could just simply
retransmit the commitment_signed message.  But because we're now considering for
simple taproot channels, we've got to consider the work done every time you
retransmit the message.  So, like I said previously, commitment_signed was
always retransmitted when nodes would reconnect, even if the peer had already
received it.

So now, instead, the message channel_reestablish includes an explicit field that
basically lets a node request for the commitment_signed message if it still
needs it.  So, in most cases, a node that would come back online would simply
tell the other node, "Hey, by the way, I got your commitment_signed message
before I shut down, before I restarted, so you don't have to send it again".
So, this allows for a more seamless flow, specifically when it comes to simple
taproot channels.  And that's the last PR of this newsletter and that completes
the whole newsletter as well.

**Mike Schmidt:** Thanks Gustavo, great job.  We want to also thank our guests
today, arbedout, Erik, and Misha, who joined us earlier for their segments.  And
I also want to thank Murch for co-hosting and you all for listening.  We'll hear
you next week.  Cheers.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
