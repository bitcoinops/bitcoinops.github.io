---
title: 'Bitcoin Optech Newsletter #213 Recap Podcast'
permalink: /en/podcast/2022/08/18/
reference: /en/newsletters/2022/08/17/
name: 2022-08-18-recap
slug: 2022-08-18-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Lloyd Fournier to discuss [Newsletter #213]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-9-2/349442903-22050-1-f6b340106018c.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody, Bitcoin Optech Newsletter #213 Recap.
We're going to go through the news and some of the PRs, and we have a special
guest today as well.  I think it makes sense to do some quick introductions.
I'm Mike, I'm a contributor at Optech and also Executive Director at Brink.
Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.  I contribute to a
bunch of different educational initiatives and sometimes also manage to do some
code in Bitcoin Core.

**Mike Schmidt**: Lloyd, do you want to introduce yourself for the folks?

**Lloyd Fournier**: Sure, yeah.  I'm Lloyd, I work on Bitcoin research.  I've
been doing that since around 2019.  I went to my first Scaling Bitcoin
conference and was inspired by the other attendees and became a fully-fledged
bitcoiner, and now all I do is think about Bitcoin and work on Bitcoin.  I have
my fingers in many different honeypots.  One of them is the Discreet Log
Contract (DLC) effort, and especially on the research side of DLCs.  I'm really
excited in practice for the technology to be able to make bets on things, do
trading on things without third-party custodians at least.  Yeah, so I've been
really interested in that.  I've been contributing to the research side of
things and we just published a paper on it that I'm really excited to talk
about.

_Using Bitcoin-compatible BLS signatures for DLCs_

**Mike Schmidt**: Excellent.  Well, yeah, thank you for taking the time to join
us and discuss that paper and your post to the mailing list.  I think we have a
diverse set of technical experience on the call, is my suspicion, and so I think
maybe if you could explain DLCs generally and maybe also get into existing DLC
technology, and then we can kind of get into why what you're proposing here has
pros and cons versus what is largely being done today.

**Lloyd Fournier**: Yeah, sure.  So, yes, DLCs.  Well, you can make all kinds of
funny conditions with Bitcoin Script, well, perhaps not all kinds, perhaps
there's some really funny kinds that you can do on Ethereum that you can't do on
Bitcoin.  But most useful kinds of conditions you could want to do, conditional
transfers based on revealing secrets, transfers based on time and transfers
based on having a certain threshold of signatures, you can all do that in
Bitcoin, but then there's this question of how you do conditional payments based
on real-world events, right, because that's the holy grail of conditional
payments, is to basically map your coins conditionally moving to someone else
based on a real-world event.  There is of course no way for the Bitcoin
blockchain to inspect the real world, so you have to somehow cryptographically
map the real world into Bitcoin.

So, a proposal was made by Tadge Dryja, an ingenious proposal, called Discreet
Log Contracts, was the name of the paper, and it was a very simple idea, which
was totally out of character for crypto-based ideas at the time, or the other
ideas that were rather complicated to do this.  And the idea is basically, yeah,
two parties put coins into an output on the Bitcoin blockchain and create some
transactions that will be enabled should an oracle attest to that outcome or the
state of the world being in a certain way.  So, the oracles, the users would
look at what the -- some kind of, let's say, an oracle announces an event, an
oracle would announce that it will attest to an event in the future.  When that
announcement is made, the parties would be able to construct a set of
transactions each not yet valid, but each would become valid should the oracle
then attest to a certain outcome, one of the finite outcomes specified in the
oracle's announcement.  And that is at a very high level how DLCs worked.

At a slightly lower level, the way I like to think about it or talk about it is
that we put coins into an output and we verifiably encrypt signatures under some
key, and each key corresponds to a certain outcome.  And so, when/if that
outcome is attested to, we are able to decrypt that signature and then put that
transaction on the blockchain.  The verifiable encryption we use is called an
adaptor signature, which allows you to create a signature that is encrypted,
encumbered by requiring some decryption key, and those decryption keys are the
things that the oracle reveals, in this case when some outcome occurs.  So that
skips over some things, but that does it for how things started and how things
are today.  And I'm just going to check in, because my internet is bad, that
everyone can still hear me and that I'm not just talking to myself.

**Mark Erhardt**: Yes, we hear you.

**Lloyd Fournier**: Perfect.

**Mark Erhardt**: So maybe one comment.

**Lloyd Fournier**: Go ahead.

**Mark Erhardt**: The interesting thing here is of course that the oracle
attesting to an event makes this a public announcement, and the parties using
that attestation do not have to tell the oracle that they're going to use it,
but can totally depend on it without the oracle even being aware of what it is
being used for.  I think that's pretty cool.

**Lloyd Fournier**: That is absolutely correct and that is a crucial point that
I missed.  I sort of alluded to it when I talked about how complicated other
schemes were for doing this on Ethereum and in other places, and even in pre-DLC
Bitcoin proposals, the oracle would always be involved in the contract or the
oracle is supremely involved, in that it takes data from the actual world and
actually puts it onto the blockchain, in some cases in Ethereum, like there will
be actual numbers and prices stored on the actual chain in perpetuity in some of
those ideas.

So, this is much more elegant, and this data never actually gets on the chain,
it is simply used; the announcement data, the actual real-world events are
mapped to cryptographic objects, and those cryptographic objects are used to
enable or disable signatures.  And all this can be done by the two participants
in the contract and do not require the oracle to be aware of the contract.  And
indeed, if things go well, the settlement and the creation of the settlement and
settlement of this contract can look like normal payments, especially in a
taproot world.

So yeah, we can now perhaps move on to what our most recent research is, is that
we managed to make practical, I would say this is the major outcome, although I
think there are some really interesting things inside this, but the major
outcome for DLCs is that we can have the oracle attest using Boneh--Lynn--Shacham
(BLS) signatures, which are signatures on a different curve, different
properties to the elliptic curve that Bitcoin uses for its cryptography.  And
the interesting thing about BLS signatures is that they are deterministic, and
deterministic perhaps is not the right word here, there is a single valid
signature for every single message under a certain key; whereas with schnorr
signatures or ECDSA signatures, there are many valid signatures for a particular
message.

So, if I have one message like, "Attack at dawn", and I want to make a signature
of it with a schnorr signature, I can make that signature and people can verify
it, but there will be many valid signatures.  That's because we use randomness
when we create the signature, okay?  And so, in order to anticipate or in order
to map these signatures ahead of time in the announcement, our transaction
signatures to these oracle signatures, we have to know the randomness the oracle
is going to use to the attestation with the Bitcoin elliptic curve.  All schemes
on the Bitcoin elliptic curve are going to need this, unfortunately.  But with
BLS signatures, there is no -- go ahead.

**Mark Erhardt**: So basically, if we were using regular ECDSA or schnorr
signatures, the announcement by the oracle would also do a pre-commitment, like
the R value or something, that they would use in the signature?

**Lloyd Fournier**: Absolutely, that's exactly correct.  The randomness that you
would use in the signature would be pre-committed to in the announcement.  You
would say, "I'm going to attest to this event with this randomness as part of my
signature".  That's a decent way of looking at it at least.  With BLS
signatures, there is a single valid signature for any message under a public
key, and so there is no randomness.  We can actually do this anticipation
without an announcement, and this actually changes the game quite a bit.  It's
still the same idea.  You anticipate signatures and encrypt your Bitcoin
transaction signatures to the revelation of these signatures, but now we do not
need to know any announcement.  We still need to know that the oracle is going
to attest to that thing.

**Mark Erhardt**: So, you're basically just committing to the public key of the
oracle, rather than the announcement and random value now.  Cool.

**Lloyd Fournier**: Yeah, and we can get the public key once initially.

**Mark Erhardt**: So you still need to be sure that the oracle will do an
attestation about the event then?

**Lloyd Fournier**: Well, you don't actually.  It turns out that if you just
change what an oracle is, right, take it out of the DLC idea a bit, and we just
say, "Okay, an oracle is a web service that you can ask it to go to any other
website, JSON API or web page or whatever, and get it to fetch the web page
content, do the HTTP request and make some BLS signatures on the content, then
the oracle doesn't need -- and let's say the BLS signatures include the content
that you've asked to assign, but also the request that you've asked it to make.
And so, you now do not even need to know that the oracle is going to attest to
any event, as long as that event is authoritatively published on the web and you
know what the URL is and you know where exactly that will be in that HTTP
response.

You can predict what the oracle is going to sign, in other words you can think
of this space existing beforehand on the web, and you can anticipate what this
oracle signature will look like for any of the outcomes for this bit of data on
the web and make a contract out of it, without ever contacting the oracle.  And
then at the time that it comes for the oracle to attest, the oracle has not
announced that it's going to attest to this, you simply ask it, "Please go to
this website and sign this stuff", and then it will do that, and you will be
able to unlock your signatures on your Bitcoin transaction.  Does that make
sense?

**Mark Erhardt**: Yes, it does make sense.  I might have said an API or
something explicitly well-defined that gives you an exact piece of data, but it
works for me, I think.  So basically, you know that you'll be able to ask a
specific public-key-associated service to retrieve real-world information and
attest to it, so basically like a web server notary.  That's pretty cool.

**Lloyd Fournier**: Yeah, it is very cool, I really like this idea, I'm
extremely excited about it.  It makes me smile, because it really makes this
idea of the programmable web real because you can now take any bit of the
internet and transform it into a cryptographic object, which you can use to make
a Bitcoin contract on.  That's quite a powerful idea.

**Mark Erhardt**: Doesn't it though move some of the knowledge about what piece
of data you're specifically interested in back into the purview of the oracle?
Because now you're asking the oracle to attest to some specific data, so
obviously you must have been interested in that data; where previously, you
could just use published pre-announcements and the oracle would never even
notice whether or not you used it?

**Lloyd Fournier**: You don't, I mean, the oracle will know when you fetch the
attestation in any case, right, because you would have to ask the oracle, "Okay,
what was the attestation for this event?" so the oracle will know that you're
interested in that event.  This now, you're right, narrows it down to a
particular web page, where obviously most times a particular web page or
adjacent field is in fact indicative of the same thing, it doesn't give you
extra information, I guess, over what you would have given before.  But there is
actually a very good advantage to this, because changing it to BLS means that
you don't need to fetch the announcement.  But I mean, you don't need to fetch
the attestation either, actually.  If you can both agree on what the outcome
was, and you can both go to the web page anyway, you can both settle the
contract without even contacting oracle.

So, in the expected case, you have perfect privacy from the oracle itself.  Now,
you will have to contact the web page yourself, but usually contact, like going
to a web page or going to a JSON API, is a rather innocuous kind of action, it
doesn't tell the operators of that JSON API too much, depending on the JSON API,
of course.  But in many cases, you're just getting some data which your phone
apps are doing anyway, right?

**Mark Erhardt**: So, the idea is here that you would either require an
attestation from both participants, or an attestation from the oracle about the
same datum, and since BLS signatures are non-interactive, aggregatable, does
that have something to do with that?

**Lloyd Fournier**: No.  So, I mean if you both agree, you just do a schnorr
signature, you just cooperatively close the contract like you would with a
Lightning channel.

**Mark Erhardt**: Oh, yeah, you don't need the pre-committed transaction that was
dependent on the oracle at all, yes.

**Lloyd Fournier**: Yeah, exactly.  So this actually gives a rather strong
privacy guarantee in the cooperative case.  Now, in the non-cooperative case, as
I've already just said, it's basically the same.  You have to fetch the
attestation in the current scheme anyway.  But here is where I changed the model
slightly even more, let's take this idea even further.  So, instead of just
telling the oracle to go fetch this thing on the web page, we can tell the
oracle to process it for us.  We can tell the oracle to visit many web pages and
process it and turn it into an average, for example.  So, we can tell the oracle
to go to different web pages and run a program on the inputs, and get the
outputs and map the outputs to specific integers.  If you want the Bitcoin
price, it doesn't have to be the actual Bitcoin price.  You could get the
Bitcoin price and then map it to some specific intervals.

Let's say you're doing the Bitcoin price, every time the Bitcoin price changes
$30, I get a little bit more satoshis than you.  We make a transaction for that
interval, or whatever interval you want, can be a floating point number,
whatever.  The point is that we can ask the oracle to process this and map it
into our contract domain.  We don't have to leave it as a Bitcoin price, we can
map it to like indexes of transactions we're going to use.  And for some
technical reasons, this is actually much more performant, or at least it doubles
the speed of the protocol, which is actually important because it is actually a
bit slower using this BLS scheme.  So, you can get the oracle and tell it to run
a program on a bunch of inputs from different web pages and give you the output.

If you're thinking about smart contracting programming language, this becomes
like a smart contracting programming language, right?  We can take data from the
web, write a contract, do whatever logic we want to it, output some bits and use
that as a kind of circuit to enable certain transactions in our own personal
contract, which can do whatever we want, and the oracle won't know about it.
But now, like I was saying, we're telling the oracle now quite a bit more.
We're talking about which web pages, which data, and how to process it and turn
it into our local domain, which will obviously leave some fingerprints there
about what perhaps we're doing.  It may even, if you're not careful, leave some
fingerprints about the amount of transactions you're signing, which may even
leave some fingerprints about the values in those transactions being a multiple
of something in the contract.  You can imagine if you're doing a thousand
transactions, each one pays one person more than the other one and they go up
linearly, and if that's a common thing, then mapping these data to certain
intervals which map closely to these --

**Mark Erhardt**: To the program run by the oracle, yeah.

**Lloyd Fournier**: Yeah, the program tells them information.

**Mark Erhardt**: I think that's still --

**Lloyd Fournier**: Like I said, we only contact the oracle at all in the
uncooperative case, which I think for me, that ameliorates that concern.

**Mark Erhardt**: I think it's also strictly superior to only tell the data to
one oracle rather than print it in the blockchain.  I mean, even if we're
leaving some data with the oracle and we must consider that it might be an
adversary, not leaving it in the blockchain for perpetuity for anyone to look up
at any time later in the context of the transaction that was executed, is
strictly superior.

**Lloyd Fournier**: Yeah, so hopefully if you're cooperatively closed, then you
never leave any information about your contract whatsoever on the blockchain,
obviously.  But yes, in an uncooperative place, there may be some privacy leaks.
I think it's not so bad.  I think it's definitely not a deal breaker, this
uncooperative privacy issue, and I mean the privacy is fantastic.  I mean, like
you mentioned, the other protocols leave data in the blockchain, and everyone
can see why this money is moving, because the data is there.  I mean, the
privacy is just almost perfect, let's say.  At least in the cooperative phase,
it is perfect, and in the uncooperative phase, you leak a bit of information but
it's not so bad.  You don't tell them what your transaction is.

**Mark Erhardt**: And it also depends on how you actually construct the request
and how you then use the information that you get, given that I mean you could
feed it also with additional information to obfuscate how much you're really
interested in and ask for more attestations than you need, or you could separate
out crucial parts of it into multiple requests, stuff like that, right?  You
could probably make it harder to track what belongs together.  And then if you
combine the information, it does maybe look different.

**Lloyd Fournier**: Absolutely.  You could ask for multiple things you don't
even care about and combine them all together.  I mean, I wouldn't do this in
practice, but yes, I think it's not some fundamental limit either.  You could go
for the full privacy or decoy kind of privacy if you wanted to, in the case that
you have to be uncooperative, yeah.

**Mike Schmidt**: Yeah, and I suppose if I were an oracle, I would be wanting to
charge additional, based on the amount of processing that I'm doing.  So, I
guess in the case of the obfuscation example, I think Lloyd in your post or in
the paper, I think there was the example of the Bitcoin price.  So, if you were
only interested in the Bitcoin price to Murch's point, you could also ask for
the Ethereum, the Zcash, the Monero price, and then knowing that you're just
going to use the Bitcoin price, but maybe the oracle charges you a bit more for
something like that.

**Mark Erhardt**: In a way, it might also be more incentive-compatible with the
model where the oracle pre-commits to attesting to an event and then just
publishes the attestation.  I don't see how the service of the oracle would be
rewarded at all, but here it's pretty clear.  If you're running a program
specifically for one user, the oracle can obviously require a payment for
running the program and giving the attestation, for example, a Lightning payment
or something.  Make the request, then payment required, and here you see your
attestation, your personally crafted attestation.  So, I think that it might
make sense from a, "I want to run an oracle" perspective and I can actually earn
something with it.

**Lloyd Fournier**: That's an interesting point.  I didn't think too much or
haven't philosophized on the payment and how you reward oracles for doing these
things.  I guess it's an open question.  I think BLS signatures, they're not too
computationally intensive just to do.  But in running these small programs, I
think it's probably okay to do it for free for a while obviously, but at some
point, yeah, I think some remuneration for these oracles would be appropriate if
they're providing a competitive service.

There's an interesting idea, so I've been taking this idea even further.  What
if we go even crazier with this idea, okay?  So, an oracle is a trusted party,
and obviously it makes sense to put it into a kind of federation.  And with this
protocol, as a sort of side note to this whole discussion, we can now do
thresholds of oracles more efficiently, at least more efficiently in the time
complexity in the number of oracles.  So, in the current protocol, it's
exponential or combinatorial in the number of oracles, the number of the nano
computation you have to do, whereas this is linear.  So, that's a big win as
well for thresholds of oracles.  But we have thresholds of oracles and we also
have this burgeoning field of these Fedimints, right?  And so you have these
trusted parties that are oracles, there are trusted parties that are federated
mints, and they both probably should be federated, or in some way.  So, what if
you just joined them together?  What if you had an oracle that was a federated
mint as well?

Now, this becomes interesting, because now this programming language could deal
with actual assets and coins itself, and could actually go from just processing
that web data, also issue assets in the contract.  So, you could add
functionality to the contracting language that allows you to create new assets
to transfer assets between people, whoever's calling the contract may be able to
get some coins out of it, if something has happened on a certain website, for
example.  And then, there's an obvious way of renumerating, for giving coins to
this party for providing the services here, because it's an e-cash, it's a
federated mint as well.

So, yeah, that's a really far-in-the-future kind of idea I'm playing with in my
head, seeing what we could get away with, if instead of having a blockchain with
these smart contracts, which we know how well that is going on Ethereum --
depending on your perspective, it's going very well or very badly --but perhaps
it could go a lot better in this kind of federated setting, where you're using
e-cash rather than recording everyone's assets in perpetuity for everyone to
see.  It's just, you can forget about them and you have a trusted federation to
be able to verify if you have an asset, but be able to issue assets in the
contracts and also put assets into the contracts for later release to other
people.  And to be able to also consume web data at the same time, you could
imagine very sophisticated DLCs that are not just DLCs, right?

The DLCs are between two parties.  That's sort of the fundamental limitation of
them.  You can't do what you call a decentralized exchange (DEX), or you have to
find other people to participate in the contract with you to do it, and that's
great if you can reliably get this kind of network set up.  But it will end up
being a hub-and-spoke model.  So, with the DLCs, whether it's this protocol or
the existing protocols, you have a hub that will give out these DLC contracts to
people and you contact them.  But then you can imagine if you didn't want the
hub-and-spoke model, you could have this oracle combined with Fedimint thing
have a kind of decentralized exchange on it, programmed using this language, or
a decentralized betting service in this case, not an exchange.

We don't necessarily have to have shitcoins in this, is what I'm talking about.
These tokens I'm talking about issuing could be like positions in a certain
asset, right?  And then when you want to get your bitcoin out, you give back the
token that represents the position and it liquidates it and gives you the
bitcoin that you're owed.  This is the way I'm thinking, but this sort of just
answers that question of how oracles could get paid.  If they went to this
model, it would be very obvious how they get paid.  They get some e-cash back
when they execute a contract.

**Mark Erhardt**: Right.  And now the DLC would still be between two parties,
but because you have basically a designated market operator, the counterparty
for everyone is sort of always available and performs the translation and
matchmaking for you, which sort of gets rid of the needing to look for a partner
in the DLC.

**Lloyd Fournier**: Yeah, exactly.  So, I mean one way of thinking about it is
that right now on Ethereum and other places, they try to do this thing,
decentralized exchange.  I don't really like this term, I don't really like it.
So they do this, what is this called, "automated market making" on Ethereum.  I
don't really like that idea, I don't think it works that well.  I think it's
like a poor man's version of an exchange, right?  You rather just have a
centralized exchange actually.  But what you could do is, the order book of a
centralized exchange is actually what you want when you're trading, that's what
you want.  And when you're settling for this automated market making thing,
you're settling for something that isn't as good.  But I think trusted parties
can run order books, that's probably okay.  The thing is you don't want them to
have custody of the funds.

**Mark Erhardt**: Yeah, exactly.

**Lloyd Fournier**: So with this thing, you could let a centralized party run
the order book, but have the federated mint do the custodying, and there would
be no friction there.  And essentially, the Fedimint doesn't have to know it's
doing that, right?  As long as it has this programming language there, you could
go in there and make this kind of consume this website, which is running this
HTTP endpoint, which is running the order book, but then make it do the transfer
of assets within the Fedimint sort of obliviously, or without knowing that it's
doing that, without having to program anything.  The user or the developer of
the smart contract would be able to make that relationship.  So that's an
exciting idea.  I don't know if any of this works, by the way, just mulling
around in my head.

**Mark Erhardt**: Yeah, that's super-exciting.  Thanks for sharing in depth.

**Mike Schmidt**: Lloyd, we went over the use cases and the positives and the
benefits of this potential technology.  It sounds like it's all unicorns and
rainbows.  Is there any downside to this; and if so, what are they?

**Lloyd Fournier**: No, that's a hard one.  In terms of for me, this is strictly
superior.  Okay, the downside I can find you is it's a bit slower to create.
For example, you're just creating a simple contract.  Let's say 1,000 outcomes
on the price, it's going to take you like a second or so to compute it.  And
also that second, it also involves three rounds of communication, so
one-and-a-half round trips.  So, the protocol itself is more complicated, so
that's a downside.  It uses an elliptic curve that is not the one that Bitcoin
uses, which means we're working outside the Bitcoin cryptography stack, that's a
downside.  And it involves more rounds of communication.  So, instead of just
sending a message, "Hey, I want to do a DLC", "Yeah, let's do it", and send a
message back, or maybe two or three, you know, one to propose it and then one
back and one again for setting it all up so that you have a transaction on the
blockchain, there's a few extra rounds in there.

It's required because it uses statistical security rather than computational
security as the technical reason for it.  So, it requires some games to be
played, where you send something and then someone gives you a challenge over the
wire, and then you take the challenge and do something with it.  So, there's a
few extra rounds of communications.  So, all the downsides are in the
cryptographic layer and the protocol engineering layer, they're not at all in
the architectural or conceptual layer, which is a good place to have the
complications, right?  I think it's a good place to have them.

**Mark Erhardt**: Yeah, because when somebody has implemented the library that
does all this, building on top of it wouldn't be that much more complicated.
But it might be a little harder to bootstrap it in the first place.  I mean,
Ethereum is already there and it's doing all this already, so people plug into a
rich existing ecosystem.  But yeah.  Well, that was pretty exciting.  Would you
remind us, why do DLCs benefit from taproot?

**Lloyd Fournier**: Yeah, it's just that we do -- actually, out of all the
things, it probably benefits the least, but it'd be faster, that's the main
thing.  The current specification uses schnorr and ECDSA adaptor signatures.
With Taproot, you can switch it to schnorr adaptor signatures, which are ten
times faster to create.  Right now, DLCs are kind of slow.  It takes a few
seconds to do, especially because of this problem if you're doing multiple
oracles, it gets very, very slow, because it's combinatorial or close to
exponential complexity of adding new oracles to the mix to do a threshold, like
2-of-3, 3-of-5, it gets exponentially more computationally intensive.  So a 10X
improvement makes some parameters viable that were not viable before.

**Mark Erhardt**: Yeah.  Okay, so I kind of walked into that one.  But my
understanding was that DLCs originally came basically out of the idea of
scriptless script, so it was related to it early on.

**Lloyd Fournier**: Actually, I mean that's one interesting thing, because
that's a point I skipped over.  The original DLC paper did not use scriptless
scripts.  So, it's interesting you say that because it's not really there, in my
opinion.

**Mark Erhardt**: Okay, I'll just shut up now!

**Lloyd Fournier**: I mean, it should be there.  In fact, I read the paper and I
thought it was using scriptless script adapter signatures to do it.  But in the
original paper, it wasn't like that.  But when we eventually got to doing a
specification, the first thing we did when I got involved was to use ECDSA
adaptor signatures instead of the original protocol, and that drastically
improves the protocol.  So, yeah, I don't know, maybe the idea was around then,
or maybe it was like Tadge came up with it just before that or something.  I
definitely know he was definitely aware of it.  I think the ideas were
pollinating each other perhaps in some ways.  The original paper doesn't have
the idea in it, which is unfortunate, but in the end, it doesn't matter.

**Mike Schmidt**: Lloyd, I saw that it didn't seem like there was any feedback
on the DLC mailing list, which is where you originally posted this, not on the
Bitcoin-Dev mailing list, for listeners.  So, if you want to read about that,
check out the DLC mailing list.  I didn't see any responses there.  Have you
guys gotten feedback outside of that email post about what people thought of the
protocol and the paper you put out?

**Lloyd Fournier**: Yeah a little bit.  They're interested in it.  The people
who work with me on the DLC specification effort are, yeah, they're interested
in it.  I don't know, the thing -- okay, it's very difficult.  When you come up
with, and I'm kind of annoying like this, I just come up with these ideas and
it's basically, you have to rewrite everything.  It's like, "Trash everything
you've done, start a new thing now", and it's not so appealing to hear those
kinds of ideas.  And when you're trying to get a product out, it's also not so
helpful to be distracted by that.  It's more like, "Okay, that's something
coming in the future.  Maybe that's not on our plate right now", and it
shouldn't be.  It's correct to have that approach because it's not worth just
trashing everything you've done.  You're trying to build a user base and you're
trying to see how people interact with the technology and learn from that and go
forward.

But of course, this will change to some extent how users will interact with the
technology just because of the way it allows you to bet on anything on the web.
So it's something that they will have to consider.  But I don't like to just
tell everyone to drop everything and just work on my idea.  We'll see how it
plays out.  What I can say is that my colleagues, my ex-colleagues and people I
love working with, they're the comit.network or CoBloX and they are working on
something called itchysats.network, which is already a working DLC.  It doesn't
follow the DLC spec, but it's a DLC technology on layer 2, so it's within
channels that allows you to do Bitcoin -- let's say BitMEX, but non-custodial so
you can do BitMEX non-custodial on itchysats.network right now.  It's early,
whatever, but we've talked about it, and we're going to work on using this idea
in their systems.

One of the main motivations for me is that I'm actually their oracle and it is a
pain in the ass, every time they want a new thing to bet on or a new way of
doing things, they have to ask me and say, "Lloyd, can you please attest to this
thing now?  And can you please attest to this thing but more frequently?"  It's
a lot of maintenance work looking after an oracle, that especially the people
are relying on and money is there.  It's a pain in the ass actually.  So, I'm
really looking forward to this idea and I'll be implementing it, just so I can
get delete my database, because this oracle doesn't need a database.  It just
goes to things on the web it can have a cache maybe to remember stuff that it's
just done so it doesn't get spammed, or whatever, on the same thing.  But I
don't have to maintain the oracle at all, it just needs to run as a service on
my server and as long as the process is there, the thing is working, right?  And
that's what I'm excited about.

**Mark Erhardt**: So you're saying you're externalizing the work on the user
instead of the oracle, and you're excited about that.

**Lloyd Fournier**: How rude!  It's not really the user, right?  It's them, the
developers.  Because the user could.  You could write DLC software that could go
-- the user can propose some Python program that can be loaded up to the oracle
and it purports to get some data, or whatever, that you could bet on and then
the users can like, "Hey, man, let's do this bet on this Python program I just
wrote".  You could have that user experience.  I don't think it'd be very
popular, but really what it is, is it's about the developers can now add trading
on ETHUSD or trading on any other random thing on the internet and don't have to
ask me to attest to it.  That's super-exciting to me.

**Mark Erhardt**: Yeah, that sounds super-exciting, thank you very much.  I
think we'll quickly go over the other news items still.  What do you think,
Mike?

**Mike Schmidt**: Yeah, that sounds good.  Lloyd, thank you for that.  That was
very educational for myself and I think our audience, and we appreciate your
time.  You're welcome to stay on and comment on any of these other items we're
discussing.  But yeah, thank you very much for that.

**Lloyd Fournier**: Sure, no problem.  That was great fun.

_Rust Bitcoin 0.29_

**Mike Schmidt**: So, one of the releases this week in the newsletter was Rust
Bitcoin 0.29, which is a major release.  It has some breaking changes, but also
adds some more modern features.  So, for folks not familiar, Rust Bitcoin is a
Rust library that has a lot of different serialization, deserialization, and
Bitcoin-related data structures, and P2P message structures that you can use if
you're wanting to do Bitcoin stuff.  I know there is some consensus stuff in
there but it is not meant to be a consensus implementation.  And so, they've
added compact block support and improvements to taproot and PSBT as well.
Murch, any commentary on Rust Bitcoin in general or the specific release?

**Mark Erhardt**: I'm not super-familiar with it, but maybe I think BDK and LDK
would probably use Rust Bitcoin, and Lloyd would know; is that right?

**Lloyd Fournier**: I haven't looked at the release notes, but I can tell you
one thing that's in there that's really good, is we now have a type for
locktimes, okay, and sequence numbers.  And so, instead of just having to fiddle
around with like, "Oh, is this locktime good enough to spend this coin?" and
then having to say, "Oh, Bitcoin locktimes, they can be either a height or an
actual timestamp or median time passed in technical term", and you have to do
this checking yourself in prior versions.  But now they have a type for it, you
can just ask, "Is this locktime satisfied by this number?  Like, if I put this
number in this transaction as the locktime, will this be able to spend from this
coin?"  You can now do that.  That's something I'm pretty happy about, and
there's something similar for sequence numbers, though it needs to be a bit
further developed, but that's coming, too.  Yeah, that's what I noticed from it.

_Core Lightning 0.12.0rc2_

**Mike Schmidt**: Great.  Thanks, Lloyd.  I think we could skip over the release
candidate for Core Lightning (CLN).  I think anybody who is using CLN should
test out the release candidates and provide feedback accordingly.

_Bitcoin Core #23480_

In terms of notable pull requests merges, the Bitcoin Core #23480, it adds a new
descriptor, which is rawtr(), raw taproot descriptor, for referring to an
exposed key in a taproot output.  Murch, I think you may have a little bit more
familiarity with the use cases here and exactly why rawtr(), raw taproot
descriptor is useful?

**Mark Erhardt**: I must admit that I'm a little guessing here, but from what I
read in that, it sounds like it's mostly useful to do watch-only wallets.  I
think if you want to import a single key otherwise, you could use other
descriptors already.  But, yeah, I don't know for sure.  Sorry.

**Mike Schmidt**: Yeah, it sounds like there's some edge cases where this could
be preferred, and I think that's sort of indicated when you see this raw prefix,
that there's likely something else if you're an end user that you could be
using.  But if you're someone building on top of these descriptors, maybe you
need the raw variant in order to do some of these edge cases.  I think some of
the use cases were around vanity addresses or cooperative tweaking of keys.

_Bitcoin Core #22751_

Bitcoin Core #22751, this is a new RPC.  So, Bitcoin Core includes RPC
functionality, which means you can call certain functions, get certain
functionality from outside of Bitcoin Core by using these RPCs.  You can get
something as simple as just getting a balance, what is the balance of the
wallet; there's an RPC for that and a variety of other things.  This PR adds a
new RPC, which is simulaterawtransaction.  What you parse to that function is
one or more unconfirmed transactions, and what is returned is essentially what
is the delta on the balance of the wallet going to be if those transactions were
confirmed, so all the inputs, all the outputs, what is this going to do to my
wallet balance?  Murch, any thoughts on simulaterawtransaction?

**Mark Erhardt**: I think it might make it easier to automate some co-signing
stuff and things like that, where you want to know whether a transaction
actually benefits you.  But other than that, I don't see an immediate use.  We
did have instagibbs up here for a moment and I was wondering whether he wanted
to chime in on the previous, but he's gone now.

**Mike Schmidt**: He's here.

**Mark Erhardt**: Oh, is he?  Twitter is so weird for me right now.

**Mike Schmidt**: Instagibbs, I've given you the invitation to speak if you so
choose.  Hola!

**Greg Sanders**: I was having trouble with my headset.  So, the one list, going
back to the raw taproot thing, the one thing it does allow you to do is, it
allows you to understand and sign for the keyspend for a taproot output.  Even
if you don't, for some reason the wallet doesn't understand what tree was
committed to it.  So, I don't know if that's like a compelling use case, but
that's one.  Because alternatively, you'd have to put in like the raw address or
something, but then it wouldn't understand what key to sign for pretty much from
a wallet architecture perspective.  That's it.

**Mike Schmidt**: Okay, yeah, that makes sense.  Thanks for chiming in there.
That was one that I wasn't entirely sure of the use case this far, so thanks for
enlightening us.

**Greg Sanders**: Yeah, I think there's also some debate on for PSBTs adding
these kind of things, like partial information for some situations.  You
wouldn't need all the information to do some things, sometimes you do, so I
think Pieter and others have been debating this.

_Eclair #2273_

**Mike Schmidt**: Thanks for jumping in.  We have a couple minutes left.  We'll
get on to this Eclair PR, so this is Eclair #2273, and this is one PR of several
that is working towards dual funding in LN.  So, in the traditional funding
model, you would have a channel in which it's single funded, and that's sort of
v1, if you will, in which if I'm opening the channel, I am contributing the
entirety of the channel balance myself and then that channel goes one way.
Whereas in the dual-funding model, which folks are working towards speccing out
and also implementing, not only would I be able to put in funds going one
direction, but the receiver, or I guess the other end of the channel, would also
be able to put in funds as well.  So, right off the bat, either of us could be
sending each other satoshis along that channel, it's not just one way.

**Mark Erhardt**: It's funny that you're saying that the original conception was
that channels would be opened by one side, because very early on, I think the
idea was always that both sides contribute funds to the channels and both start
with a balance.  And then it just turned out to be really much harder to
implement it that way.  So, it's sort of coming back full circle to the original
idea, where now both parties chip in and open channels.  I think it is related
to the push on first open, sort of allowing when you open a channel to have
balances for both sides, even when one person funds the channel, but inherently
it's a little different.  And one thing I just realized that I'm kind of excited
about is, it will increase the number of transactions where multiple parties
contribute funds to create a transaction.  So, in a way, if dual funding takes
off, it will be more payjoins on the network, and that's kind of cool.

**Mike Schmidt**: Yeah, that's a good point, I hadn't thought of that.  That's a
nice side effect.  And I don't exactly know how this would go out, but I would
think there would be a fairly large adoption for dual funding once it's
implemented and fairly solid, but it's a great point.

**Mark Erhardt**: I mean, it makes this problem where, "How do you get inbound
liquidity?" just much more easy, because you could then have a marketplace of
people with similar amounts opening channels to each other.  They would start
with a balance on both sides, would immediately be able to forward, and, yeah.
I hope it does go through.  It's more complicated than single open channels
though.

_Eclair #2361_

**Mike Schmidt**: The next PR here is also Eclair, and this harkens back to
Newsletter #211 that we covered a couple weeks ago, which is this
htlc_maximum_msat field, which I think we covered as a BOLT previously, and this
is Eclair actually implementing that change.  And what that is, is simply the
channel requires a field of what is the max size Hash Time Locked Contract
(HTLC) that I will route through this channel?  And everybody, I think, or most
implementations, were already sending that.  So, this is just a formalization of
that field being included.  And Eclair will, I believe, reject channels that do
not include that field moving forward.

**Mark Erhardt**: As a reminder, that field is sort of also a proxy for the
amount of funds that people allow, or channels allow, to be in all HTLCs open at
the same time, and that in turn is protection against probing; that's the word
I'm looking for.  So, when you can basically lock up most funds in a channel,
you can find out how much money exactly is on each side of the channel.  And if
you limit how much money can be held in open HTLCs at the same time, you can
diminish the amount of information such attackers can glean from the channel.
And that's why it's being formalized, or one of the reasons it's being
formalized.

_LND #6810_

**Mike Schmidt**: The next PR here is an LND PR, and it basically is a change to
use taproot everywhere possible.  And so, where LND might use taproot is like if
you're sweeping funds from the wallet when you're funding the channels, and
there's some other watchtower-type use cases in which they're going to use
taproot now.  So, that's good, taproot adoption is good.  Murch, any thoughts on
the details here?

**Mark Erhardt**: I think it's probably not going to be used when funding
channels because taproot-based channels are not implemented yet.  But I think it
generally defaults to basically all the change outputs and automatic closing
transactions that LND creates will use P2TR outputs.  So, we might see a little
bit of an increase of P2TR outputs on the network with the next LND release.

_LND #6816_

**Mike Schmidt**: Excellent.  The next PR is LND #6816, which is really just a
documentation PR, and it's talking about zero-conf channels.  So, a
zero-confirmation channel is one in which the funding transaction has not
actually confirmed in the blockchain yet, and there's certain use cases where it
may be appropriate, where there's trust, where you can actually use these
zero-conf channels before the transaction actually confirms.  Murch, any
thoughts on zero-conf channels or the associated documentation here?

**Mark Erhardt**: I haven't read it, sorry.  No, no idea.

_BDK #640_

**Mike Schmidt**: It's just documentation.  Cool.  And the final PR this week
for Newsletter #213 is BDK #640, which is just an update to the get_balance
function, and it returns the balance separated into different categories.  So,
there's available balance for confirmed outputs; trusted-pending balance for
unconfirmed outputs from the wallet itself, so in the example there would be
like a change output; and then a different category of balance for
untrusted-pending balance, that would be unconfirmed outputs from outside
wallets; and then an immature balance in the case that this is a miner and there
is a mining output which hasn't quite reached the 100 confirmations necessary to
spend it.  Murch, any thoughts on the categorization of get_balance in BDK?

**Mark Erhardt**: That sounds good to me.  I was, when I read that first,
thinking also it might be interesting to have effective balance, which estimates
the current feerate and then deducts the cost of the inputs or the whole UTXO
pool from the balance and tells you how much you could actually spend, based on
the current feerate.  But I guess that's a future PR or something!

**Mike Schmidt**: That's such a Murch response, I love it!  Always thinking
about fees.  Alright, Murch, anything else that you wanted to discuss from this
newsletter or any other announcements we should make?

**Mark Erhardt**: No, I think we're good.  We've got it all covered.  Thanks
instagibbs and Lloyd for joining in.  I think, see you next week.

**Mike Schmidt**: Yeah, that sounds good.  Thank you all for attending, and
yeah, thank you instagibbs and Lloyd.  This was a great conversation, and look
forward to talking with you all next week.  Cheers.

**Mark Erhardt**: Cheers.

{% include references.md %}
