---
title: 'Bitcoin Optech Newsletter #316 Recap Podcast'
permalink: /en/podcast/2024/08/20/
reference: /en/newsletters/2024/08/16/
name: 2024-08-20-recap
slug: 2024-08-20-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Bastien Teinturier and Hennadii Stepanov to discuss [Newsletter #316]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-7-20/385067899-44100-2-5107aeb0ee806.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #316 Recap on
Twitter Spaces.  Today, we're going to be talking about a new time warp
vulnerability in testnet, a paper about DoS risks with onion messages, an opt-in
authentication of senders feature in Lightning, Bitcoin Core's switch to the
CMake build system, and our weekly releases and notable code change topics.  I'm
Mike Schmidt, contributor at Optech and Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch.  I work at Chaincode Labs on all sorts of
Bitcoin stuff.

**Mike Schmidt**: T-bast?

**Bastien Teinturier**: Hi, I'm Bastien and I work on Lightning at ASYNC and the
Lightning spec, and implementation and wallet software.

**Mike Schmidt**: Hennadii?

**Hennadii Stepanov**: I'm hhebasto, a Bitcoin Core contributor working for
Brink.

**Mike Schmidt**: Well, thank you both for joining us this week.  We have a few
News items and a bunch of interesting PRs later on.  If you're listening, bring
up Newsletter #316 in your browser, and we'll try to go through that
sequentially.

_New time warp vulnerability in testnet4_

First news item is titled, "New time warp vulnerability in testnet4".  Murch,
you were involved with sort of cultivating the discovery of this vulnerability.
Maybe you can walk us through how the idea was surfaced and how you built upon
the original idea by Zawy.

**Mark Erhardt**: Absolutely.  So, we included in testnet4 the proposed fix for
the great consensus cleanup, which would prevent the original time warp attack
as it was described.  And the time warp attack is based on being able to shift
the start of a difficulty period compared to the end of the prior difficulty
period.  So, as some of you might know, there is an off-by-one error in the
difficulty adjustment calculation, which makes the difficulty periods not
overlap.  So, instead of actually taking the time that a difficulty period took,
which is the time of the last 2,016 blocks, it only takes the time of the last
2,015 blocks, namely the timestamp of the first block in a new difficulty
period, and the timestamp of the last block in a difficulty period.  To make
that overlap, that would have to be from the last of the previous to the last of
the current, right?

So anyway, in the classic time warp attack, this shifts by taking a lower
timestamp on the first block of the new difficulty period than the last block of
the previous difficulty period.  I think we've explained the time warp attack
here before, so I'm not going to explain how all of that works in detail.  But
anyway, so in the great consensus cleanup fix, we required that the first block
of the new difficulty period is no more than 10 minutes before the last block of
the prior difficulty period.  So, it limits the shift, that's a soft fork; it's
also something that shouldn't affect anyone that honestly minds.  So, yeah, that
fix was just put into testnet4 because, why not?  We're starting a new network,
we might as well test the things that we want to do to mainnet eventually.

Now, on Twitter, a user called Zawy mentioned, "Oh, there's this time warp
attack that is not fixed by the new rule that you put into testnet4", and he
described it on Twitter, and I felt that the description was a little hard to
access, so I wrote it up; or sorry, actually the first description was on the
testnet4 PR, and it was sort of getting a little out of the main topic there,
which was the code review for testnet4.  So anyway, I wrote it up in detail on
Delving again as I understood it, because I felt that it was a bit hard to
understand.  And while writing it up, I actually had an idea how to improve the
attack.  And in the original version of the attack, the attacker could -- well,
Mike, how did you want to go through this, or do I just narrate?

**Mike Schmidt**: This is great, keep going.

**Mark Erhardt**: All right.  So, maybe I'll get into how this attack works here
now.  As you know, there are some restrictions on timestamps.  Hopefully you
know if you're a regular listener, but let me recap.  So, the timestamp cannot
be more than 2 hours in the future of a Bitcoin node's own clock, otherwise it
will just not accept it.  Obviously, that's not a consensus rule because as time
progresses, maybe those 2 hours, the horizon is reached and then a node would
accept it.  So, this is more of a temporary validity rule.  The other rule is
that a timestamp has to be at least the median of the last 11 blocks'
timestamps.  So, you look at the prior 11 blocks, sort them in order, sort their
timestamps in order, which may be different from the order in which the blocks
were produced, and take the median element, which is just the sixth element in
this order.  And the timestamp has to be actually bigger by 1 second than that
median element.  So, we have sort of a mechanism to force that timestamps move
forward over time, and we have a mechanism that protects us against the
timestamps running away into the future, because then people could obviously
just cheat and say, "Oh yeah, this totally took 8 weeks and here's my timestamp
far in the future, and I'm going to reduce the difficulty by a factor 4 every
single time".

So, what this attack does is it does exactly that.  It says, "Oh, let's pretend
that the first difficulty period actually took 8 weeks, which allows me to
reduce the difficulty by the maximum of a factor 4.  And then in another
difficulty period, we're also going to pretend that it took 8 weeks and put a
timestamp that is now 16 weeks from the start of the attack in the future, and
that way we reduce the difficulty again by a factor 4.  Meanwhile, on all the
other blocks, we only increment the timestamp by the absolute minimum
necessary".  And as you might have noticed, if you are looking at the median of
the last 11 blocks, it means you can only increment the timestamp by 1 second
every sixth block.  So, you can have 6 blocks per second according to the
timestamps, and then on the last block, you set it to 8 weeks into the future,
and you do that again.  You keep incrementing all of the timestamps of most
blocks by a minimum, and then the last block is at 16 weeks into the future.

So, you've decreased the difficulty by a factor 4 twice.  And now, in the third
difficulty period, you use the minimum timestamp, the one that you had been
cultivating over the last two difficulty periods, which is just a few hours from
the start of the attack timestamp.  And therefore, you increase the difficulty
by a factor 4.  Now, reducing it twice by a factor 4 and then increasing it once
by a factor 4 means that overall the difficulty is still a quarter of the start
of the time.  To perform a time warp attack, because you have to control the
majority of the timestamps, you need at least a majority of the hashrate.  So,
at least at the point where you publish a block that is 8 weeks in the future,
nobody else will accept your block, so you're mining by yourself, and with half
the hashrate roughly, that will take you about four weeks to produce 2,016
blocks in the first difficulty period, but then it gets faster because it's
reduced by a difficulty of 4.  So, the next difficulty period only takes you a
week.  Then you reduce the difficulty by a factor 4 again, which means now it
takes a quarter of a week.

So, this is actually not the original attack that Zawy described.  Zawy had the
trick with the 8 weeks into the future and 16 weeks into the future, and then he
started alternating between using the minimum timestamp and the
16-weeks-in-the-future timestamp for the last blocks, which let him reduce the
difficulty by a factor 4, increase the difficulty by a factor 4, and vice versa.
And that way, overall it looked like the difficulty was only, well,
five-sixteenths of the actual difficulty.  I'll have to think a little more
about that, but you can produce more blocks than you should be able with half
the hashrate.  So, with my idea that you can repeat this, incrementing the
timestamp only to 8 weeks and then to 16 weeks again, ratcheting up the
timestamp in order to reduce the difficulty, you can subsequently reduce the
difficulty by a quarter to a quarter of the previous cycles' difficulty in each
of these three difficulty period cycles.  And that way, you can reduce the
difficulty to the minimum just like with the original time warp attack.  Okay,
that was a lot of explanation.  Any questions so far?

**Mike Schmidt**: I have a question.  Does this vulnerability then, since we
applied the consensus cleanup time warp attack remedy to testnet4, and there's
still this other vulnerability that you've outlined, does that mean that the
consensus cleanup time warp attack mitigation needs to be iterated upon?

**Mark Erhardt**: Right.  So, this attack is possible on mainnet right now, just
like the original time warp attack is possible on mainnet right now.  Both of
them are fairly impractical, because you need at least half of the hashrate, you
need to collude on keeping back the timestamps, or, well that would be extremely
visible.  And then with Zawy's attack and my variant of Zawy's attack, you would
just drop off with half the hashrate at the end of a difficulty period.  First,
you publicly keep back the timestamps or you do that in private as well already,
but that extends the time of your attack by two weeks, or maybe not by two
weeks, but makes it slower for you to produce the blocks of the first difficulty
period.  So, it would be extremely visible.  You need at least half the
hashrate, and the defence against this attack is once the attacker's chain is
published, you call invalidateblock on the first block, and then hopefully, if
your node didn't die from a 16-week block re-org, you just re-org back to the
chain that everyone was on for the last 16 weeks.

But theoretically, this attack is possible, and yeah, the idea of fixing it with
the great consensus cleanup, we did fix the original one, which is more
practical, but we would need another rule here in order to fix the new one, and
this rule would be required that the last block in a difficulty period is at
least 1 second larger than the first block of a difficulty period.  Now, that
should usually take 14 days, even if you have a lot of hashrate, it's probably
not going to be significantly less than 14 days.  So, requiring that there's at
least an increase of 1 second between the first block's timestamp and the last
block's timestamp doesn't feel like a rule that would be impacting any honest
participants in the network.  So, yeah, my suggestion was, let's just require
that the last block is after the first block.

**Mike Schmidt**: Excellent.  T-Bast or Hennadii, you guys are welcome to jump
in as well.  It sounds like, Murch, as we note at the end of this writeup, the
trade-offs between the proposed solutions were being discussed.  It sounds like
this is a sort of ongoing thing now. Anything else to note before we wrap up?

**Mark Erhardt**: I think actually, so the only two timestamps that matter for
the difficulty adjustment are that of the first block and that of the last block
in the difficulty period.  So, the alternative suggestion was to have stricter
rules on timestamps, for example, only being able to increase or no timestamp
ever being able to be less than 2 hours of any prior block's timestamp.  I think
that those rules would also work, I think that those rules should also not
impact any honest miners, but they would be more invasive code changes in the
consensus code area.  So, I think the rule that the last block in a difficulty
period has to be at least 1 second greater than the first block is just way less
invasive and, yeah, it fixes this attack specifically.

_Onion message DoS risk discussion_

**Mike Schmidt**: Next news item titled, "Onion message DoS risk discussion".
So, there was a paper published recently by two researchers, Amin Bashiri and
Majid Khabbazian, and this paper was covering onion messages and potential DoS
factors for distributing onion messages in the Lightning Network.  Gijs van Dam
posted to Delving to discuss that recent paper, but Gijs was not able to join us
this week.  But good news is that t-bast was, and I think, t-bast, you mentioned
in our pre-discussion that you can speak to this item.

**Bastien Teinturier**: Yeah, exactly.  So, let's first detail what onion
messages are and why we potentially care about being DoSed through onion
messages.  So initially, the only thing we had in Lightning to be able to reach
a remote node was to send payments that use an onion encryption scheme, called
Sphinx, that we slightly modified to fit our payment use case.  And we figured
that there were cases where we would want -- some people started actually using
HTLCs (Hash Time Locked Contracts) to send small messages, which was actually
bad because it locked liquidity for intermediate nodes along the road for things
that were actually not payments.  So, it made sense to introduce another way to
be able to parse data from one node to a remote node, while keeping the privacy
benefits of onion encryption.  And this was also something that was needed for
BOLT12, where we want to use to create a static payment address that you can
then reuse to generate invoices on the fly.  And we use onion messages for that.

So, an onion message works at the encryption level quite like an HTLC.  You
choose a route through the payment, through the network, and then you do an
onion encryption of your message.  And you can also include, in the payload for
the last node, the reply path so that they can reply to you.  And this reply
path is a blinded path so that you can keep your sender privacy.  The receiver
does not know who sent a message to them if you don't want to reveal that, and
potentially, receivers can also use blinded paths for people to reach them so
that they can receive messages without disclosing their identity, which is
really nice, but opens the door obviously for abuse, because then if anyone is
able to send onion messages to anyone and intermediate nodes are just relaying
messages without knowing who sent them and where it goes, potentially that can
be used to send dummy data and use a lot of bandwidth across the whole network.

So, that's why one of the important design goals of onion messages was to make
them very light to relay.  So, whenever you relay an onion message, the only
thing you do is that you receive an incoming packet that is at most 65 kB.  You
do one ECDH operation and one ChaCha20 decryption, and then you relay that on
the outgoing link, and you don't have to store anything in your DB or even in
RAM.  So, this is very light, which potentially makes it hard to DoS, because
since this is very easy to relay and very light to relay, even a small node can
easily relay a lot of onion messages without being impacted at all.

But we also figured, one of the very early discussions about onion messages was
that even though it is really light to relay, it can still potentially be
abused, and we want to have a way to mitigate that abuse.  So, that's why two
years ago, during one of the Lightning summits, we worked on a design for a very
simple mitigation where each node applies some rate limits to incoming onion
messages.  And whenever they drop an onion message, instead of just dropping it
and not saying anything, they would send a very small message back saying, "Oh,
I'm dropping that onion by the way".  And then, you are able to quite easily
statistically get that back to the sender of a payment and penalize the incoming
link.  So, nobody has implemented it yet, but we have detailed the protocol and
it's quite a -- oh, yeah, Murch, go ahead.

**Mark Erhardt**: Sorry, just a quick question at this point.  I thought that
when you forward the onion message, you don't keep any log of what you
forwarded.  So, if you say you drop a message, wouldn't that only work if the
sender was the hop before you?

**Bastien Teinturier**: Okay, so that's where, with this mitigation, when
implementing this rate limiting, then you need to start recording something for
each onion message relay.  And the thing you actually record is that whenever
you relay to an outgoing peer, you remember the last incoming peer who sent that
message to you.  If you relay another onion message, you just replace the
previous incoming peer with the latest one.  So, for each of your peers, you
only store 33 bytes for the node ID of the previous peer.  And then, that means
that statistically, you will send the response, you will attribute the failure
to the right incoming peer, but potentially not all the time.  If you receive a
failure from downstream and you have relayed another onion message since the
previous one from a different incoming peer, then maybe you don't attribute it
to the right attacker.

So, that's why it's only a statistical rate-limiting scheme that only works
statistically, but it's probably good enough.  When we posted it, we said, "Oh,
it's an interesting research problem to see that actually, it's good enough in
practice, and model that correctly to be able to have real figures on how well
it works".  And then, this paper came out later.  It only mentions our
rate-limiting scheme at the end in the conclusion, and it tried to do it
differently.  It says that if there is an issue with DDoS with onion messages,
they propose two ways and some other standard implementation steps to
potentially mitigate DoS.

The first one, the first thing they propose is completely changing the encoding,
the way the packets are encoded to separate the routing information, the
information that says to whom you are supposed to relay the other messages from
the data itself, so that we can keep a small routing part to make sure that it
cannot be more than n hops, for example, four or five hops.  Limiting it to five
hops already limits the DoS potential and makes it easier to attribute errors to
incoming links, basically.  But the thing is, since it completely changes the
packet format, I don't think we want to do that at all.  It's interesting in
theory, but in practice, we won't change everything for that, because the
already proposed rate-limiting scheme probably does that well enough already.

But the other thing they propose, which I think is way more interesting, is that
they say that one of the issues is that an onion message can potentially travel
through 500 hops, because you have at most, they say, 32k in the paper, but
actually you can use more than that.  So, you can potentially create an onion
message that bounces through many, many, many nodes.  And right now, we have not
limited that, even though our rate limiting potentially could prevent that.  But
they introduce an exponentially growing PoW that creators of onion messages
would have to create.  Basically, when you create the shared secrets when doing
the onion encryption, they would force each shared secret to meet a PoW
difficulty target, and then the next shared secret has to build on top of a
previous one.  So, it gets exponentially harder to create long onion messages.
Yeah, go ahead, Murch.

**Mark Erhardt**: Right, so the sender would have to do the PoW.  It would
exponentially increase with each hop, and then each hop would check, "Hey, I got
this amount of PoW.  The one that I'm forwarding, I can also see the PoW, and
the PoW is exponentially bigger than mine"; or do you actually get a difficulty
statement?  Because if you are very lucky at generating the PoW for one hop and
the hops don't know how far away from the sender they are, so they don't know
the target, you might have a very low value on your prior hop and that would
make it more difficult for all subsequent hops; or, how would it work?

**Bastien Teinturier**: I think that currently proposed version would not be
what we would eventually do because there are a few things that are actually, I
think, impossible to use in practice.  So, we would do something that takes the
overall idea, but reworks them into something more practical.  But I think
that's what they're proposing today, is that you choose a difficulty target for
the whole network, and it's a setting that is part of a protocol.  And since
each has to build on top of the other one, that's why it gets exponentially
harder, because first you have to get a solution for the first node, and then
you use the result of that solution to build the shared secret for the next one.
So, you have to redo the PoW again, and again, and again, and again for every
hop.

**Mark Erhardt**: But that would only be a linear increase, not an exponential
increase, right?

**Bastien Teinturier**: Good question, because they are actually not detailing
it that much in the paper.  They're just providing a picture that shows how they
use different sources of the Bitcoin latest block hash, for example, and how
they resolve things with each other, but they don't detail how it gets the next
official --

**Mark Erhardt**: I guess if changing the later hops requires redoing the prior
hops, it would be exponential.

**Bastien Teinturier**: Yeah, I think that's it.

**Mark Erhardt**: Yeah, maybe that's it.

**Bastien Teinturier**: Yeah, I think that's their goal.  But since we would
have to change a few things in the way they do it, we would have to ensure that
this is still the case.  So, I think the overall idea is great, that some form
of exponential power makes sense to limit the length of onion messages.  That's
probably something we would add because it can be added on top of the existing
protocol without having to redo everything, but we wouldn't do exactly the way
they do it in the paper.  We would have to rework it slightly because, for
example, they use the latest Bitcoin block hash and they assume that everyone
has access to the latest Bitcoin block hash.  Well, we know that nodes
potentially are lagging behind and would reject onion messages if they don't
agree on the latest.  They would think that the PoW is invalid, even though it
is potentially valid, if they just don't have the latest of the same block tip.
So, some of those things would need to be done differently, but the overall idea
makes sense.

But I think it's really a long-term thing, because right now I don't think
something more complex than the very simple rate-limiting protocol that we have
is necessary.  So, that paper doesn't explain why the currently proposed simple
rate-limiting scheme is not enough.  So, we would have to first model this
correctly, and if it's not enough, then we would work on implementing that
exponential PoW as well.  So, I think that for a few years, we're just going to
run with a very simple rate limiting, and then more research work needs to be
done before we do anything more complex.

**Mark Erhardt**: Cool.  Thanks for explaining all that.

**Mike Schmidt**: T-bast, I missed it if you mentioned it, but I think roasbeef
had a proposal for preventing onion message abuse by charging for data relay.
What's your take on that?  And if you mentioned that, apologies, I stepped away
for a moment.

**Bastien Teinturier**: Yeah, I don't think he highlighted it again.  That's
something he proposed at the very beginning when we first introduced onion
messages.  And then, it was basically re-adding almost all the same complexity
as using payments for what is basically onion messages.  So, I personally don't
think it's a good idea, and I don't think Matt or Rusty thought it was a good
idea either.  I don't think we need it.  And I think I need to re-ask Laolu
again, but I think he was okay.  Once he started reviewing the rate-limiting
protocol we proposed, he seemed okay with just going with that without having to
pay for bandwidth, basically.  But that's potentially a discussion we can have
again, but I don't think he wanted to pursue that option.

**Mike Schmidt**: OK, thanks for clarifying.  Anything else to wrap up this
topic, t-bast?

**Bastien Teinturier**: No, I think it's good.  The paper is actually quite a
short paper, so people can read it and people can also read, in the conclusion,
it links to the rate-limiting email that I sent from 2022, I think.  So, people
can also read that if they want to get an idea of how the values proposed
rate-limiting options for onion messages are.

_Optional identification and authentication of LN payers_

**Mike Schmidt**: Well, the next news item is also t-bast motivated, posting to
Delving, "Optional identification and authentication of LN payers.  T-bast,
maybe walk us through the motivation of why we would want identification and
authentication in such a protocol, and we can walk through the idea a little bit
more.

**Bastien Teinturier**: Sure.  So, this is something that builds on top of
BOLT12.  So, once you have BOLT12, you have one static QR code or maybe a
handful of static QR codes that you reuse to receive payments.  And based on
those QR codes, payers will send you an onion message to get an actual invoice,
and you will send them an onion message back with the actual invoice, and then
they will pay you.  And since we have this back and forth that happens at
payment time, we can embed data from the payer to the recipient and potentially
exchange keys if necessary, or exchange anything.  And one thing that people
miss a lot in payment apps, in Bitcoin payment apps, compared to normal payment
apps basically is to be able to send money to your friends and to have your
friends see that it was coming from you.

The issue is that if you just include a text field that says, "Oh, this is
coming from me", there's no way to actually trust this.  Anybody could have sent
this value and you cannot verify it.  But since people actually have long-term
identities, long-term keys, we could devise a system where every user has some
kind of a contact key, a public key or a set of public keys that are their
contact information that whenever you add people to your trusted -- yeah, go
ahead, Murch.

**Mark Erhardt**: I'm kind of confused by the problem.  So, if I'm asking
someone to pay me an amount and I get a payment that matches the offer, clearly
they must have communicated in some way, and either I got the payment from the
person that I expected to pay me, or I got it from someone that did it on behalf
of them.  So, could you walk me through a scenario where I would be concerned
that someone else paid on behalf of the actual sender?

**Bastien Teinturier**: That's because you're still thinking in BOLT11.  You're
still in the past, Murch!

**Mark Erhardt**: Okay, fine!

**Bastien Teinturier**: No, more seriously, BOLT11 is really awkward because
whenever you want to receive a payment, you have to generate an invoice for it
and you have to send that to a payer, which requires interaction.  And we can
actually get rid of that interaction with BOLT12, because with BOLT12, what can
happen is that only once I add people to my contact list, for example, Murch,
you give me your offer, I add it to my contact list, and then I never have to
speak to you again whenever I want to make payments to you.  I'm just going to
choose you as a contact in my app and say that I want to send you money, and
it's going to use that default offer to send you money.  But that default offer
will have no amount in it because it's basically a default offer to be able to
reach me for anything that you want to send me.  And then I want to authenticate
myself because that offer, you could also have posted it on Twitter to receive
tips or donations or anything.  So, if you want to be able to identify that
payments are coming from me, you need something more.

That something more that I'm proposing is that if I add you to my contacts list
and you add me to your contact list, then whenever I'm trying to pay you,
because you are one of my contacts, that author is one of my contacts, I will
also use something derived from my own contact key so that you can authenticate
that the payment was coming from me.  Yes, go ahead.

**Mark Erhardt**: So, the problem is not that I as the receiver am concerned who
paid me, but you as the sender want to be able to prove that you were the one
that paid me, right?

**Bastien Teinturier**: Yeah.  And basically, just simply in the UX, we want to
be able to show in your payment history, "You received this payment from Murch;
you received this payment from Bastien", and we want that to be done
automatically.  And this way, whenever we have identified that a payment comes
from one of your contacts, we can also display the potential message that they
included.  Because if it doesn't come from one of your contacts, we probably
don't want to display messages because it could be phishing information, because
anyone could have sent that payment.  So potentially, they sent payment with
phishing information inside it that puts the user at risk.  Whereas, if we
identify that the payment came from a known contact, then it's less risky to
display the message.

So, it's really mostly for UX, so that people have a UX that they feel matches
what they expect from payment apps where they have their contacts, usually their
phone contacts, and they are able to send money to their contacts and they are
able to see when they receive payments from their contact that this was coming
from a specific contact.

**Mark Erhardt**: Okay.

**Bastien Teinturier**: And there are many ways we can do the crypto for that
and many ways we can create the keys that we would use for that mechanism.  So,
that Delving Bitcoin Post is mostly to gather feedback on the set of proposals I
made for that.  But there are potentially also other options, mainly to exchange
the contact keys.  So, I'm interested in feedback and review from anyone who
cares about being able to have a contact list in their Lightning wallet.

**Mark Erhardt**: And yeah, completely random and not super-related, I'm so
looking forward to a future where we have push payments on the internet that
properly work, because pull payments suck.

**Bastien Teinturier**: What do you mean exactly by push payments?

**Mark Erhardt**: I had a fun interaction with a car rental last week again, and
now I have some charges on my card because they can just pull it in.  So, the
idea that I'll be able to just push the amount and they'll verify that they got
paid and we're all happy, and I never have to look at past interactions again
and review them and check that they actually only took as much as they were
supposed to, and so forth, that prospect seems marvellous to me.

**Bastien Teinturier**: Yeah, I completely agree with that.  And that was one of
the main motivations when Rusty did BOLT12.  And he initially included a
recurrence scheme directly inside the first BOLT12 proposal so that you can take
a subscription, and instead of the money being pulled from you, you're just
going to pay that subscription, you're going to push that subscription amount
every month, and your wallet can show you your active subscription and you can
just decide to stop anything at any time unilaterally without having to contact
the URL, or anything.  It would be entirely controlled by you, which is a very,
I agree, important feature compared to what we have today with credit cards.

**Mike Schmidt**: T-bast, what's the feedback been from the Delving Post, as
well as I know you have a BLIP open, a related BLIP as well?

**Bastien Teinturier**: Yeah, so we discussed it.  There was only feedback on
the Delving Post from Dave, but I discussed this with Matt and Rusty in the last
two spec meetings, and it's on their to-do list to review that once they're done
with their releases.  And we are going to discuss it also during the next
Lightning Dev Summit in September or October.  So, this should see some progress
during the fall, I think, and then we should achieve something, hopefully by the
end of the year, that would be cross-compatible between multiple wallets.

**Mike Schmidt**: Excellent.  T-bast, we appreciate you joining for these news
items.  There are some non-Eclair Lightning PRs later if you want to stick
around.  Otherwise, if you have things to do, we understand if you're going to
drop.

**Bastien Teinturier**: Sure, of course I'll stick around.  Thanks for having
me.

_Bitcoin Core switch to CMake build system_

**Mike Schmidt**: Last news item this week, "Bitcoin Core switch to CMake build
system".  And this news item was motivated by a Bitcoin Dev mailing list post
from Cory Fields talking about the switch from Autotools to CMake for builds.
Hennadii, you were mentioned here as one of the leading contributors to the
effort.  Maybe you can discuss with us a bit about the different build systems
and the fact that there are different build systems, and what are the
differences between the two and what are the timelines for all of this?

**Hennadii Stepanov**: Absolutely.  We have been working on this project for
more than two years.  And the importance of having a good build system for
reference in Bitcoin client could be easy to assume if you just count how many
source files are in the source repository.  And if you also look into the
download page in BitcoinCore.org site, there are binaries for the recent 27.1
version, binaries for nine different platforms, including Linux, macOS, Windows,
and some not so common platforms like RISC-V, PowerPC, and for example, for also
single-board computers running ARM, 32-bit or 64-bit.  And these releases, it's
important to note that they are reproducible.  So, before publishing these
releases, multiple developers around the world built the same binaries and they
confirmed that binaries are exactly the same as binaries built by other
contributors.  I mean exactly bit-by-bit the same.  More important also is the
fact that it doesn't matter which platform is used as a build platform.  For
example, if one developer built on usual Linux x86 and got a binary and other
build on ARM64, they will get exactly the same binaries.

Besides all the reproducibility, it's also important to maintain security of
resulting binaries, because current build tools we use during the building
process, which includes compiler, linker, different kinds of binary utilities,
have many features which make resulting binaries more resilient and could resist
against, for example, such attacks like buffer overflow, which potentially allow
an attacker to execute any code on a user's machine.  And a huge part of current
build system is responsible to maintain such a high level of security for
resulting binaries.

So, currently we use Autotools, which is actually a set of multiple separated
tools, including Autoconf, Automake, Libtool, and some other small tools.  And
these build systems served us for years very good, but new times require more
from the build system.  And also, Autotools has a few flaws.  For example,
besides executables, which usually is a part of the release package, including
bitcoind, the main Bitcoin client, bitcoin-cli, to access to bitcoind using RPC
interface or Bitcoin GUI or other utilities.  Besides them, we also in the past
provided a shared Libbitcoin consensus library, which is currently deprecated,
and shortly we will ship libbitcoinkernel library, which will allow other
developers to build their own implementations and using the same kernel
functionality as Bitcoin Core, avoiding potential consensus-related failures.

**Mark Erhardt**: Hhebasto, Murch has his hand up, so I'll give him a chance.

**Hennadii Stepanov**: I'm sorry, Murch, go ahead.

**Mark Erhardt**: Yeah, so I don't know a ton about build systems, so I asked
around a little bit.  My understanding is that Autotools is basically a 30-year
old set of macros that is hardly maintained, and it only works with Make.  And
so, my understanding is that CMake is going to be way more compatible with a
bunch of different build systems, build environments, I should say.  And
notably, Cory, who originally bootstrapped Bitcoin Core's Autotools
configuration, is extremely excited about CMake.  Does that match or is that
roughly the main points that we take away there?

**Hennadii Stepanov**: Exactly.  So, from the point of view of build system
maintainers, switching from Autotools to CMake looks very similar, like for
example, switching from a very complex script written in a simple shell to a
Python, for example.  Also, CMake has its own domain-specific language, and it
makes maintainability much simpler.  And speaking of support different
platforms, for example, to build on Windows natively, we still maintain
currently a separated Microsoft specific build system, which after migration to
CMake will be gone, because CMake natively supports a wide range of build tools,
including Microsoft Visual Studio and macOS Xcode, and can be tightly integrated
with many integrated developer environments.

So, other problems with the current Autotools is that during recent years, we
upgraded our C++ standard from C++11 to C++17, then from C++17 to C++20.  And
with C++ 20, we lost ability to build our binaries for Android platforms.  It's
related to the point that our Android binaries are actually GUI, Graphic User
Interface, which build with the help of Qt framework.  And the currently
supported Qt version 5 has built-in Android specific library, NDK, with built-in
standard library support only for previous C++ standard.  It doesn't support C++
20.  We need to switch to newer Qt 6, which effectively has CMake as a native
build system.  So, it's another benefit of CMake.

**Mark Erhardt**: Right.  So, with the recent switch to C++ 20, we would have
not been able to ship the GUI as it was previously written, because we would
have just not been able to build it anymore?

**Hennadii Stepanov**: I mean, we are able to ship GUI for all platforms except
for Android.

**Mark Erhardt**: Oh, yeah, sorry.

**Hennadii Stepanov**: The problem is Android-related.  Also, besides platforms
I already mentioned for releases, we support and document build procedures for,
for example, all flavors of BSD systems, including OpenBSD, FreeBSD, NetBSD; and
their own native Make tool is not compatible with GNU Make, which is currently
required for Autotools.  CMake handles these platforms equally, so when using
CMake, no need to install some other additional tools when building Bitcoin Core
on any BSD system.  And as I already mentioned, having own domain-specific
language makes further development much simpler.  For example, my colleague,
Niklas Gögge, who works on a fuzzing test, some day asked me how to create an
executable for each harness target, for each fuzz harness.  So, for example, we
have 200 different harnesses for fuzzing, and for his purposes, requires exactly
one executable harness.  And currently, using Autotools, it's possible to
complete this task just running 200 pieces of code separately for each target,
which will make the whole build script hardly maintainable.  For CMake, when
using CMake, this task could be accomplished with a simple loop.  So, it's a
completely different approach for maintenance.

With the current release cycle, we are expecting that the next Bitcoin Core
version 22 will be released in a couple of months.  This version will be the
last one built using Autotools.  And the version 29, which is expected to be
released next spring, will be the first one which will use CMake as a build
system.  The current PR, #30454, has also updated build documentation for all
platforms, and all developers who work on Bitcoin Core and who use Bitcoin Core
as a sub-project in their own projects are encouraged to test that PR using
CMake in their own environments and the different build testing, and any other
scenarios.

**Mark Erhardt**: Right, let me jump in here for a moment.  So, the upcoming
release will still be with Autotools.  This is the release that we just did
feature freeze for last week, and that's coming out, I think, in October.  And
the next one, so this project is getting merged right after the feature branch,
or sorry, the release branch has been forked off, and then the master, like the
old, or the main repository, will get the CMake tooling.  And then, there is a
PR right now already that you can use to test whether CMake will work with your
use cases.  So, if you build your own Bitcoin Core binaries or have
customization in your Bitcoin node, please take the time to try and build from
this branch, in order to surface any issues that might come up, to give the
developers that work on the CMake project more time to fix any upcoming issues
before the 29 release in eight months.  So, yeah, just if you use your own
custom builds or build the binary yourself, please help with testing.

**Hennadii Stepanov**: Thanks, Murch, for wrapping up.

**Mike Schmidt**: Hhebasto, thank you for walking us through that.  Thank you
for your perseverance on this project for several years, getting it to the point
where it's almost across the finish line.  Murch, thanks for the call to action.
I think that's how I was thinking of wrapping as well.  I do have a feeling that
no matter how much we scream from the rooftops to test this, that there will be
a series of a flurry of issues on the repository, or elsewhere, about people
having issues building in some period of time once this is out there, but we'll
do all we can to make the parties aware that they should be testing and becoming
aware of the new build process.

**Hennadii Stepanov**: It's a good thing that we will have CMake available at
the very early stage of the 29 version release cycle.  So, we will have a few
months for polishing and testing.  That's a good thing.

**Mark Erhardt**: Yeah, and I'm really excited.  I mean, it's a lot of work
right now, and it's basically front-loading some of the pain, but then being
able to have much simpler build processes to build to all these different
environments easily.  I like the example with the fuzzing.  I've been doing a
lot of fuzzing.  If we can have our separate binaries for the fuzz tests instead
of running all of Bitcoin Core every time, I assume it's going to be much
quicker.  So, this sounds amazing to me, even if we have a little pain to go
through right now.

**Mike Schmidt**: Cool.  Thanks again, hhebasto.  You're welcome to stay on
through the rest of the newsletter.  Otherwise, if you have other things to do,
we understand.  Next segment from the newsletter, Releases and release
candidates.

_BDK 1.0.0-beta.1_

We have trustee old BDK 1.0.0-beta.1, which we've talked about forever.  I do
promise we will get somebody on to talk about this when it's ready.  Nothing new
to add from my side.

_Core Lightning 24.08rc2_

We also have two other release candidates, one for Core Lightning 24.08rc2.  I
know we keep some of these things under wraps until it's officially released.  I
didn't happen to drill into this release candidate to give you any sneak preview
bits.  Murch, I don't know if you did.

**Mark Erhardt**: No, I'm afraid not.

_LND v0.18.3-beta.rc1_

**Mike Schmidt**: And similarly with LND v0.18.3-beta.rc1 release candidate for
minor bug fix, I did not look at that bug fix or those bug fixes in LND.
Perhaps these will be on next week and we can divulge a little bit more.
Notable code and documentation changes.  If you have a question for Murch,
myself, t-bast, or hhebasto about build systems or Core Lightning (CLN) stuff,
feel free to post it in the Twitter thread or request speaker access.

_Bitcoin Core #29519_

Bitcoin Core #29519 is a change to Bitcoin Core's P2P code when using the
assumeUTXO feature.  As a reminder, since the next two PRs here I think are
assumeUTXO, that assumeUTXO allows node operators to load a snapshot of the UTXO
set at a certain point in time in the past, typically when bootstrapping a new
full node.  So, for example, someone loads a UTXO snapshot as of a month ago.
Then, assuming the snapshot represents the best chain, the node can verify those
blocks from the last month, in addition to any new incoming blocks, and then
have an operational node sooner than if they started IBD from scratch the
traditional way.  I guess a note here that the node would still download and
verify historical blocks to prove that the initial snapshot was indeed correct.

So, what does this PR do?  This PR fixes a couple of things with assumeUTXO at
the P2P level.  First, if the snapshot is not in one of our peers' best chains,
we don't download blocks from that particular peer, which I guess makes sense
since you're going to be downloading blocks that aren't what you think are the
correct blocks.  Then second, it ensures that the blocks after the snapshot are
prioritized for download, as opposed to downloading or prioritizing historical
blocks before the snapshot.  So, there was a bug that was fixed here.  So, when
a snapshot was loaded, the last common block variable was not updated.  And
maybe Murch can speak more about that specific variable.  But this fixes that so
that now, that last common block is the snapshot, so then these newer blocks
after the snapshot are prioritized, so that you can get up to speed and get your
node running, as opposed to downloading some of the historical blocks that you
don't really need to do just yet.  Murch, how did I do there?  I felt scared!

**Mark Erhardt**: I think you did great.  I have actually not looked into this
enough to be sure, but I have a guess what's going on here.  So, when you use
assumeUTXO, you download a state a few months from the current chain tip in the
form of a UTXO set, and then you first sync to the chain tip, right?  And that
makes you come online very quickly.  You have the recent history, you know about
all the UTXOs that exist.  So, if you import a wallet, you will know what your
spendable balance is because you have processed from the UTXO snapshot to the
current time.  So, any transactions that happened since, and all that, will be
accounted and you know any new stuff you've received very quickly.

I think what happens now is the pindexLastCommonBlock, so that's pointer of
course, p-index, so the index of the last common block would then, I think,
usually be what you track your local chain tip with.  Guessing from the context,
I'd say it jumps back to the Genesis block and then moves forward as you sync
the background chain.  And now you wouldn't be downloading any new blocks after
initially catching up to the current chain tip.  As new blocks come in, your
node wouldn't get them and you would remain stuck at that point that you first
caught up to until your background sync finishes.  And what this fix does is
that it allows you to continue to jump to the chain tip and get those blocks and
update your chain state on that current chain tip, even while you're in the
background processing the old history to validate the snapshots.  Maybe
instagibbs knows more if he's here and has looked at this.

_Bitcoin Core #30598_

**Mike Schmidt**: In the meantime, we can continue, since the next one is also
assumeUTXO.  So, we can keep riffing on assumeUTXO here.  Bitcoin Core #30598,
another assumeUTXO-related PR.  This time, the PR is removing a piece of data
from the UTXO's snapshot data structure, specifically the block height, the
numerical block height.  There was a recommendation to remove block height from
the snapshot, because either (1) since you're downloading the snapshot from the
internet, the value is untrusted and thus cannot be used, or (2) since the block
height value is eventually checked and validated anyways, in which case that
block height value is redundant with the value that you're checking it against.
So, there was some debate about removing that block height field along with
considerations of its usefulness or not with some of the PRs and issues around
this topic.

So, check out Bitcoin Core #30516, which was an alternate approach to handling
this, and that's now closed.  And then there's an issue that motivated both that
PR and this PR that we're covering this week, which is issue #30514, that I
think was actually a sanitizer check that surfaced this integer value in the
snapshot, potentially having problems.  So, they resolved to just remove it at
this point.  Murch, have you been following along with that discussion at all?

**Mark Erhardt**: I have not, but of course the block height is not unique.  You
could have multiple blocks at the same height.  Even if there's only one block
at each height in the best chain, well, you could have more than one block at a
given height.  So, if you already have the block hash, that is actually unique
and that is a better identifier for blocks.  I think there's a similar problem
in many wallets when they store just the height at which a transaction was
received.  That usually causes problems around reorgs, because of course when
they reorg they have to roll back, and sometimes transactions are only included
in one of the blocks at the same height, or even a double spend could be in the
other chain tip.  Yeah, don't use height as a block identifier, use the block
hash.

**Mike Schmidt**: Except for your BLOCKCLOCKs, you got to have the block height.

**Mark Erhardt**: Yeah, sure.  I mean, having the height in the context of the
best chain, the height is unique right, but it is not a good identifier to say,
"Exactly this block, like this header and these transactions, is what I'm
talking about".  If you just want to know what the highest height is, then the
highest height is the information.

_Bitcoin Core #28280_

**Mike Schmidt**: Bitcoin Core #28280.  This is another PR around initial
bootstrapping and block download.  This one is a performance optimization for
IBD when you're in pruned mode.  Murch, you're free to double-click into this a
little bit deeper, but the optimization involves the dbcache, which could slow
down syncing, because every coin in the cache was scanned.  And so, instead of
scanning all of them, there's this logic to mark some as dirty, which improves
the efficiency of IBD up to 32% for pruned nodes.

**Mark Erhardt**: Yeah, so the dbcache is used to keep track of the unspent
transaction output set, and the UTXO set, of course, changes at every block.
So, there's an optimization when you're doing IBD.  If a UTXO is created and
it's spent before you've last written to disk, you never have to write it to
disk, because obviously it's just ephemeral anyway.  A UTXO only exists between
it being created by a transaction and then it being consumed by a transaction.
So, what this PR does is basically, it keeps track of UTXOs that have already
been invalidated versus UTXOs that still exist.  And the dirty ones are actually
the ones that it would need to write to disk if it flushes.

So previously, all of these were stored together and then when you flushed, the
simplest thing was to flush all of the changes at once, and then empty the cache
and not remember any of the prior UTXOs, which was annoying because then if you
had new transactions to process, you'd load those very same UTXOs from the disk
again, the ones that were still surviving.  And here, with the optimization, you
keep track of the ones that you still want to keep versus the ones that have
been obsoleted, and then you can more easily only throw away the ones that you
don't need to keep, and that action makes it much faster.

_Bitcoin Core #28052_

**Mike Schmidt**: Thanks for breaking that down, Murch.  Bitcoin Core #28052,
which is a change that now Bitcoin Core XORs the blocked data files.  So, before
this, Bitcoin Core stored the blocked data files as they came in from a peer.
And the potential problem with that could be that the contents of the files
could be scanned or flagged by antivirus or other software, and then seen as
malicious and quarantined, or however the antivirus software handles those
potentially nasty files that it thinks that the block data has.  So, instead of
storing the files as is, there is this random XOR operation that's performed on
the files and then those sort of scrambled -- I'll use the term, Murch can
correct me -- files are then stored on disk.

Similar changes have been merged in the past to obfuscate Bitcoin Core data on
disk.  In 2015, there was a similar XOR obfuscation for chainstate; and in 2023,
mempool data was also XORed.  Murch, do you have some color commentary on this?

**Mark Erhardt**: No, pretty much what you said.  The interesting thing is that
the key with which it's XORed is stored locally, so everyone has their own,
which means that the files will look different on every local machine, which
makes it impractical to search for sequences in the blockchain to identify that
you have Bitcoin Core on your machine.  And other than that, yeah, people write
all sorts of junk into the Bitcoin blockchain.  The blocks files had previously
usually not been affected by antivirus because they're 100 MB or bigger, and
antivirus usually only scans small files.  But this just follows up on prior
efforts to solve these sorts of virus signature problems or other stuff.  So,
all the data is just basically salted with a random sequence that you generate
locally.  It shouldn't affect your speed or anything, it just makes it hard to
search for.

**Mike Schmidt**: Murch, how would you describe XORing the data?  It's not
encrypting the data, it's not hashing the data.  What is happening there
exactly?

**Mark Erhardt**: I mean, it is sort of a form of encryption.  You basically
generate a bit sequence, 1s and 0s, and then XOR means that you basically mirror
it around that random sequence that you use, so you turn every bit.  I think
it's, well, it's a reversible operation with this bit sequence, and so it's
basically a form of encryption, yes.

_Core Lightning #7528_

**Mike Schmidt**: Okay, thanks.  Core Lightning #7528 is a PR titled, "Adjust
the sweep fee estimation".  And I was scanning through the PR description and
some of the release notes, and I thought that this was most descriptive of the
change, "Sweeping funds from channel closes, we now use an absolute deadline of
two weeks, rather than a relative deadline which causes sweeps not to confirm
for prolonged times".  So, it introduces this slow sweep deadline function for
CLN onchain sweeps when closing channels.  You can look at the algorithm in more
detail in the PR.  So, I guess the issue motivating this was previously, that
feerate was set to that 300-block timeframe, which sometimes caused transactions
to be stuck at the minimum relay fee limit causing those delays.

**Mark Erhardt**: Yeah, I think this is a very simple but kind of nifty
approach, and nothing to do with Lisa, just ...!  Yeah, the point is that you
basically target just two weeks in the future, and then as you get closer to
that time, you linearly increase the feerate, and presumably every time it goes
over the minimum relay feerate amount as an increase, like when you start with 1
satoshi per vbyte (sat/vB), once it's over 2 sats, once it's over 3 sats, you
rebroadcast a closing transaction.  So, this should generally be very cost
efficient.  It might be a little slower than other possible approaches, but
eventually I think it goes on the current 2-hour estimate.  So presumably, if it
doesn't go through then before that point, it'll go through the next night when
usually block space demand drops off a little bit.

_Core Lightning #7533_

**Mike Schmidt**: Next PR, Core Lightning #7533, a PR that's titled,
"Bookkeeper, meet splicing", and this allows CLN's bookkeeper plugin to become
aware of the splicing features that are being added to the protocol.  The
bookkeeper plugin in CLN stores a lot of different accounting information about
CLN's node operations for the user, that fun accounting stuff in Lightning.  So,
yeah, I guess it makes sense that this bookkeeper plugin is aware of the notion
of splices and how to handle that.  Any thoughts, Murch?  Oh, t-bast, all right.

**Bastien Teinturier**: Yeah, and this shows that CLN is reworking and working
more on splicing to match the Eclair implementation.  And hopefully, we will
have interop between CLN and Eclair on splicing in a few months, I guess.  So,
we are finally going to be able to officially ship splicing, even though it has
been used in the wild for a very long time now.

_Core Lightning #7517_

**Mike Schmidt**: Core Lightning #7517 added a plugin named askrene, "rene"
being a reference to René Pickhardt, who's done a lot of research on pathfinding
in Lightning, Pickhardt Payments, among other things.  This plugin uses René's
min-cost-flow implementation, originally from renepay, which I think is another
plugin.  And we discussed renepay in Newsletter and Podcast #263.  I'm curious,
t-bast, what are your thoughts on renepay/Pickhardt Payments and some of this
discussion?

**Bastien Teinturier**: So, most people have been lagging behind on implementing
that, because I think one of the reasons was that the initial plugin for CLN was
quite unstable because of implementation issues and because it's a way more
complex algorithm than using just a few Dijkstras.  And also, on the research
side, René has kept working on this and finding new stuff, and kept refining his
research and view of how liquidity works in the network.  So, he's working on a
new paper that he's close to finalize.  And we've all delayed actually
implementing anything because usually the new papers make the previous thing
obsolete, and it's not completely obsolete, the previous renepay stuff, but at
least not as good compared to what we have today, as was initially thought.  So,
this is interesting, I think, mostly for research, if you want to play out with
it and compare how it works compared to other standard payment algorithms.  But
I think it's early to turn it on by default for all of your payments.

_LND #8955_

**Mike Schmidt**: Thanks for that color, t-bast.  LND #8955, which adds coin
control capabilities to LND's sendcoins function.  It was possible to do coin
selection in LND before, but it took several steps, and actually I'll list them
here, because there's quite a lot: coin selection itself, fee estimation, PSBT
funding, PSBT completion, and transaction broadcasting.  So, by adding this UTXO
field on the sendcoins function, or sorry, I guess it's an RPC command, you
shortcut all of that additional work into one command.

**Mark Erhardt**: That sounds like a useful change.  I have just a pet peeve.  I
find it confusing when people use coin selection for manual coin selection,
which I would usually use coin control for.  That's how the feature was named
when it shipped, I think, first in Bitcoin Core.  Coin selection is the
automated process, in my opinion, but then I guess people use it differently.

**Mike Schmidt**: Murch, you'd be proud.  In my notes, I originally had coin
selection in my writeup here and I changed it to coin control, with the
exception of the coin selection last piece, because I was quoting the
newsletter.  So, give me my proper kudos!

**Mark Erhardt**: Sure, sure, kudos to you!

_LND #8886_

**Mike Schmidt**: T-bast, I hope you can help with this next one as well.  And
we actually added a topic about inbound forwarding fees, but LND #8886, which
adds support for inbound forwarding fees.  I think, I don't remember if, t-bast,
you were on when we talked about the original news item discussing this, but
maybe I guess regardless, folks including myself forgot your opinion on inbound
forwarding fees, including maybe starting with what they are.

**Bastien Teinturier**: Okay, so inbound forwarding fees are a way to price
differently payments coming.  Usually you set a price on the outgoing payments.
You tell the network, "If you want me to relay a payment through this channel,
it's going to cost you that much", but you don't tell people, wherever it comes
from, basically it costs the same thing.  So, if I have a channel with Mike, a
channel with Murch, and an outgoing channel with someone else, if Mike or Murch
want to meet relay payment for that outgoing channel, I'm going to price it the
same for both of them.  But potentially, you may want to price differently
depending on where the payment is coming from and not only where it's going to.
And that's why the LND folks wanted to introduce inbound fees.  That's the goal,
where for each of your incoming channels, you can say, "Oh, by the way, my
outgoing fee is that much, but if it's coming from this channel, I'm going to
put, for example, a discount on premium".

If I remember correctly, they're only supposed to use it for discounts to
incentivize moving liquidity from one side of the channel to the other, not to
add additional fees on top of the routing fees.  And I'm not exactly sure what
was the latest decision for the protocol, because we initially started
discussing that in a BLIP, but there was a lot of pushback on how the LND folks
wanted to do it, and I'm not sure which version they shipped.  And I'm not sure,
I think LDK was also working on something similar, but potentially not with the
same protocols.  So, at that point, it's really just an experiment, and you
should be careful when you use that because potentially, this is going to be
ignored by the rest of the network who does not support that specific flavor of
inbound fees.  So potentially, you will have weird results.

Also, there's a bug in the current LND version that created a lot of issues with
gossip, when they created invalid signatures for channel updates that was
discovered recently because of this inbound fee feature.  So, if you are using
this, really make sure you always grab the latest version so that you at least
don't have the bugs.  Yes, Murch, go ahead.

**Mark Erhardt**: Regarding LDK, I think we had a news item a few weeks ago
which stated that LDK was going to implement inbound forwarding fees only if
they're negative.  So, if a routing node chooses to charge less if the inbound
payment comes on a certain route, it's free money for that node, and they were
supportive of that, but they would not support positive inbound fees.  I think
that was the news item.  I don't recall exactly which newsletter it was.

**Bastien Teinturier**: Okay.  And I think that makes sense and I think that's
the only way I would use inbound fees for.  We had a lot of discussions, I
think, on the mailing list about that a long time ago where we all expressed our
opinions.  I generally don't think this is useful at all, and I detailed that in
my post on the mailing list.  But if people are at a point where it's nice that
people can experiment with it, and if they find it useful and I'm proven wrong,
I'd be happy to implement that in Eclair as well.  And if this is actually
useful for people, it will eventually be in every implementation.  But I think
that at this point, it's just an experiment mostly for people who think that
this way, they can keep their channels balanced for some reason, where I
fundamentally don't think it's a goal to keep your channel balanced and to
actually pay for that, because it can be exploited.  We've seen a lot of plugins
that try to do rebalancing lose a lot of money because they were countering each
other, and one side was rebalancing and the other side was rebalancing in the
opposite direction automatically and it's completely dumb.

But yeah, this is really in the experimentation phase at that point.  So, if you
are using it, make sure you always grab the latest versions and yeah, be
prepared for potential incompatibilities with the rest of the network.

**Mike Schmidt**: Yeah, so to reiterate, this idea is not a BOLT.  There are a
couple BLIPs, I believe BLIPs #18 and BLIPs #22 document these different
approaches.  And so, I guess this is not something I'm working with day to day,
but the fact that the t-bast is saying proceed with caution is probably a valid
path to consider, is proceed with caution.

**Bastien Teinturier**: Yeah, make sure you understand it before you actually
turn it on and start playing with it on your node.

_LND #8967_

**Mike Schmidt**: LND #8967 adds a new Stfu message.  Stfu is SomeThing
Fundamental is Underway.  This is used for quiescing, or I think of it as kind
of pausing a channel in preparation for some sort of a channel protocol upgrade.
T-bast, is that how you think about it, as like pausing and then upgrading the
channel in some capacity?

**Bastien Teinturier**: Yeah, exactly.  It's telling your other peer, "I'm not
going to send you any more updated HTLCs or fail or fulfill HTLCs.  I'm hoping
you do the same once you're done with your current set of changes.  We're then
going to pause for a few seconds for running HTLCs while we upgrade the channel
to something".  For example, to do splice, that's the first step in splice.  You
first send Stfu.  This way, it ensures that both commitment transactions are
synchronized, contain the same HTLCs, which makes other things simpler, because
otherwise some edge cases would be impossible to reconcile.  And when you are at
that stage where commitment transactions contain exactly the same set of HTLCs,
then you can upgrade the channels or change some channel parameters.  And LND
wants to use that to be able to move to taproot channels before taproot channels
are actually fully specified and can be advertised to the network.

We are already using this for splicing, and there are also proposals to use this
to update some of the static channel parameters, some parameters to channels
that are static today, for example, the dust limit or your reserve, that we may
want to make dynamic in the future, and you would have to go through this Stfu
step before you change those parameters.  So, this is a quite fundamental, tiny
protocol to put your channel in a state where it can then run another protocol
that changes deep things about the channel.

**Mike Schmidt**: I'll plug here the Topics wiki on bitcoinops.org.  There were
two new entries, I think, this week.  One was for inbound fees, which was
referenced in the last PR we discussed from LND, and then we also have this
channel commitment upgrades topic that was also added this week, so read a few
paragraphs on those to get a summary of what those things are.

_LDK #3215_

LDK #3215, a PR titled, "Protect against Core's Merkle leaf node weakness".
Murch, I did not run the idea of throwing this at you, but I'm going to throw
this at you.  What is Bitcoin Core's merkle leaf node weakness?  If you don't
know, I can regurgitate something that I have pre-written here if you want.

**Mark Erhardt**: How about you start with that and then I'll add color?

**Mike Schmidt**: Okay, I'm going to regurgitate from the comment in the LDK PR.
So, there's actually comments in the code here that explain this.  And it
states, "Bitcoin Core's merkle tree implementation has no way to discern between
internal and leaf node entries.  As a consequence, it's susceptible to an
attacker injecting additional transactions by crafting 64-byte transactions
matching an inner merkle node's hash.  To protect against this (highly unlikely)
attack vector, we check that the transaction is at least 65 bytes in length".

**Mark Erhardt**: Right.  So, the merkle tree, as it was created for Bitcoin or
implemented for Bitcoin, has a few weaknesses.  One of those weaknesses is, for
example, addressed in the taproot tree, in the script tree for taproot, where we
use tagged hashes.  So, for each hash in the tree, we use a different prefix
depending on where it is positioned in the tree.  So, a transaction hash will
have a different tag than an inner node hash.  This didn't exist for the old
merkle tree.  We can't change it because that would be a hard fork.  And this
leads to issues like, well, when you do a hash, the inner nodes are just a
concatenation of the hashes of the two child nodes just written after each
other, smushed together.  And if you create a transaction that actually matches
one of those hashes by solving a partial preimage, well, it's hard to create
these, but you could wreak a lot of chaos.  You could, I think, make people
either believe that a transaction was confirmed that is not in the blockchain,
and in another variant of this attack, you can make people reject a valid block.

So, yeah, transactions that are small than 65 bytes are potentially problematic,
and that's why we do not allow transactions that are 64 bytes specifically in
the non-witness data.  The witness data doesn't count into this.

**Mike Schmidt**: And I think I misspoke earlier when I said that we added
inbound forwarding fees topic and the channel commitment updates topics.
Actually, it was the inbound forward fees and then this merkle tree
vulnerabilities topic that's actually timely to this particular PR.  So, Dave
actually did a great writeup of merkle tree vulnerabilities that's on Bitcoin
Ops Topics wiki.  So, check that out, there's diagrams in there, it's a really
useful visualization of what Murch is talking about.

**Mark Erhardt**: Yeah, and I don't think we harp enough on this.  So, the
Bitcoin Optech site has 145 Topic pages, and not only do they give usually a
rundown on what exactly a topic is about with an explanation on the important
fundamental details, they also link to every single newsletter appearance of
that topic.  So, if you want to know about, I don't know, A is Ark, for example,
if you want to know about Ark, you'll click on it, you'll get an explanation on
what Ark is, and then all the two newsletter items that we had about Ark, and
some relevant related topics like joinpools and covenants.  So, if you're ever
researching topics, please think of our Topics Index.

_BLIPs #27_

**Mike Schmidt**: Last PR this week is to the BLIPs repository, BLIPs #27, which
adds BLIP04 for HTLC endorsement.  I would take a crack at summarizing this if
t-bast wasn't here, but it would be a shame not to utilize his brain for this.
T-bast, what's HTLC endorsement?

**Bastien Teinturier**: So, there's been an issue with Lightning channels for a
very long time that is called channel jamming, where you can use HTLCs to
potentially fill someone's channels with pending HTLCs, and this way they cannot
relay payments anymore, and you can use that as a dust mechanism to make sure
that your adversaries are not able to earn money from the channels they are
using, for example, if you are a malicious LSP and you want to target another
LSP.  And unfortunately, it is quite hard to mitigate, because having anonymous
payments and protecting against spam is basically pulling on a rope in two
different directions.  But we've been researching ideas for those mitigations
for a very long time.  Mostly Carla and Clara from Chaincode have been working
on that a lot.

The first step, they have a good reputation algorithm that we would like to try
out on the network on mainnet, because we can only really see if those
algorithms work on real traffic, but we cannot get real traffic from the
network, because every node in the network only sees a part of the real traffic.
So, the idea is that we're going to use a TLV (Type-Length-Value) field that we
add to the HTLCs, where nodes that run a reputation algorithm can decide to set
the reputation of an HTLC.  Basically, when they receive an HTLC and are asked
to relay it, they will tell the next peer, "I think my confidence that this HTLC
is honest and will succeed is that much".  And then, the next peer can take that
value as input and feed it into their own reputation algorithm and their own
local thinking of which of their incoming channels are honest or malicious, and
decide whether to relay on that HTLC or relay it with an updated value.  The
first step for that is that nodes that do not support any kind of reputation
algorithm should at least relay what they receive as input.  If you receive an
HTLC with a confidence value, an endorsement value, you should relay it to the
outgoing node.  This way, we'll be able to send payments across the network and
if we control the sender and the receiver, we can see the end value for the
endorsement and measure potential accuracy of the algorithms based on the data
we get.

So, Eclair and LND have code to relay that endorsement value, and we are both
working on actually also enabling a reputation algorithm so that your node can
decide to set this value to something that is based on their history of payments
from incoming channels and to outgoing channels.  So, this is exciting because
we're finally going to get closer to a good solution to channel jamming once we
go through enough rounds of collecting data on mainnet.

**Mark Erhardt**: I have one quick question.  So, obviously, I don't work on LN
day to day.  I happen to share the office with Carla and Clara, so I've heard an
update talk a month ago or so.  I was just wondering, my understanding was that
the endorsement value is binary, so you would either say, "So, this came with an
endorsement and I trust my peer that endorsed it, so I'll also endorse it", or,
"This came without an endorsement or just came on a channel with a peer that I
don't trust, so I don't endorse it and just forward it as an unendorsed
payment".  Is this an evolution of what I heard last, that you said it has a
numeric value, or is this an implementation detail that I was missing?

**Bastien Teinturier**: So, this is basically part of the experiment, because
Carla and Clara's algorithm works with binary values, but Thomas in my team
wanted to use more discrete values.  So this way, we have two different
reputation algorithms, the one designed by Carla and Clara that works on binary
values, and the ones we're going to be using that works on more buckets of
discrete values; and we're going to be able to see what works and what doesn't
work by just comparing the results.  The only difficulty it introduces is that
since we are going to create values that are between, we decided to have eight
thresholds to just use eight potential values in that byte.  So, we're going to
have to decide on a cutoff threshold below which Carla and Clara's algorithm
will consider it a zero,

and above which they will consider it a one.  So, that's something we were not
sure yet what to use.  And I think Thomas is working with them on that.

But yeah, it's just a way to potentially allow experimenting with either binary
or bucketed algorithms.  But we don't know which one we're going to actually use
in, I don't know, one year or two on the network once we have results and see
what works.

**Mark Erhardt**: Awesome.  Thank you for explaining that.

**Mike Schmidt**: I don't see any questions, so I think we can wrap up.  Thank
you very much, t-bast, for joining and staying on for this hour-and-a-half plus.
It was very useful to have you for the news sections as well as the PRs that
we're talking about, interesting Lightning things.  We very much appreciate
having you on.

**Bastien Teinturier**: Thanks for having me.  It had been a while, so I'm happy
to come back!

**Mike Schmidt**: Awesome.  And hhebasto dropped, but thank you, hhebasto, for
joining us and talking about the build system changes.  And thanks always to my
co-host, Murch, and for you all for listening.  See you next week.

**Mark Erhardt**: Thanks.  Hear you soon.

**Bastien Teinturier**: Thanks.  Bye, everyone.

{% include references.md %}
