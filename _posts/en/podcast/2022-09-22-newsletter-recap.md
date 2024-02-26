---
title: 'Bitcoin Optech Newsletter #218 Recap Podcast'
permalink: /en/podcast/2022/09/22/
reference: /en/newsletters/2022/09/21/
name: 2022-09-22-recap
slug: 2022-09-22-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Jeremy Rubin and Paul Sztorc
to discuss [Newsletter #218]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-25/348475410-22050-1-1cc945c929d03.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody, this is Bitcoin Optech Newsletter #218
Twitter Spaces Recap.  Quick introductions, we have a few guests.  I'm Mike
Schmidt, contributor at Bitcoin Optech and also Executive Director at Brink.
Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs, I do Bitcoin-y stuff
here.

**Mike Schmidt**: Paul?

**Paul Sztorc**: Hello, my name is Paul Sztorc, I comment on Bitcoin on my blog,
Truthcoin, which is named after this P2P Oracle thing I invented a long time ago
in 2013.  And I'm very interested in sidechains and prediction markets and in
particular, I'm the author of BIPs 300 and 301.

**Mike Schmidt**: Great, Jeremy?

**Jeremy Rubin**: Hi, I'm Jeremy, I raise rabble and cause problems for people,
and I'm waking up right now.  So, thank you for having me.

_Creating drivechains with APO and a trusted setup_

**Mike Schmidt**: Yeah, thank you for joining, I know it's early where you're
at.  Okay, great, well we can just go in order of the newsletter, which
fortunate for both of our guests, the first item is related to drivechains and
some work that's been going on in the mailing list from Jeremy as well as
ZmnSCPxj.  I think the best person to outline the more general idea of
drivechains and at least his idea for BIP300 would obviously be Paul.  So, Paul,
you know, we have listeners that are probably slightly technically oriented, but
I think a general overview of drivechains, what are you trying to accomplish
there; what are the benefits; what resistance have you gotten in trying to
activate drivechains?  And then we can get into both Jeremy's mailing list posts
as well as some of the work that ZmnSCPxj did on saying that this drivechain
technology is potentially possible in different ways, and we can get into that a
little bit later.  So, Paul, do you want to give your spiel on drivechains?

**Paul Sztorc**: Well, okay, I think I'll be 100% honest with the spiel, because
I'm a big believer in it, but anyone who wants to just interrupt and say, "This
is going off the rails", I'll try to keep it really short.  But honestly, it's
an idea that gives Bitcoin infinite scalability, privacy, and extensibility, and
it has no downsides at all.  I don't normally describe it that way, I try to
have a little more humility, but how is that even possible, and why would I say
something so absurd and outrageous?  Well, it's because the sidechain idea,
which is not mine, it goes way back, Satoshi kind of half invented it when he
invented merged mining, and whoever was coming up with Namecoin, which is a
great thread that everyone should read on Bitcoin Talk, I'm sure everyone here
has probably read it already; but the sidechain idea is just the idea that
someone can send coins to a different blockchain, to a different piece of
software, and then over there they can do whatever they want, including send
them to other people, or use zk-SNARKs, or use Turing-complete smart contracts,
or prediction markets, or whatever you want.

What I did with BIP300 is I basically just said, very simple idea, drivechain
from November 2015.  In fact the title was, Drivechain, a Simple Two-Way Peg;
turns out, maybe not as simple in practice, or for the audience, so maybe I
don't explain it very well.  But basically, all I said in the post was, even
though it's, whatever, 30 pages long, all I said in the post was, if 51% miners
are against the system, you're kind of already dead.  Many of the large blockers
at the time were okay with SPV mode.  So I just said, well, we'll just assume
that we have this one chance to have the miners bring the funds back via the
withdrawals, but we're not going to let them off so easy.  We will force them to
count patiently up to a very high number, which was two weeks back then.

So, the BIP300 idea, to bring this rambling rant to a close, is it basically
says you send all the coins to a script, and then when money wants to come out,
it has to wait very carefully.  It's just an integer that counts up to 13,000.
You declare, "I want to take this money out of the script", which I call
Hashrate Escrow, which is the name of BIP300, and when you want to take the
coins out, you have to just count up to a really, really high number.  And the
only way you can do this is if you mine three months' worth of blocks that are
each advancing you one thing closer.  So, a good metaphor is you're leaving
prison and they have the interlocking locked doors and they have a little buzzer
and the doors don't all open at once, you've got to traverse a series of gates.

So, this is my rambling explanation, but yeah, I think that it's a very tame
idea.  It has no real drawbacks to anyone, it lets a lot of people do whatever
they want to do, subject to this one assumption, which many people are clearly
willing to at least take.  I would point out that it's kind of the same
assumption as the LN undertakes.  If 51% are willing to attack, there's a lot of
bad things they can do.  So the question is, under what circumstances are they
likely to do those things?  But that's a completely different conversation than
the whole, what can they do?  So this is a rambling explanation that I should
probably end with.

**Mike Schmidt**: To dig into that a bit, I understand that you can sort of put
some funds into this sidechain and that's the fairly easy part of it, and then
the getting the funds out has some risk.  And you mentioned part of the risk
mitigation is sort of this metaphor of the jail cell with multiple gates.  Maybe
explain the issue there first, so that one miner can't just pull everything out
in one block?  What are people seeing when they're seeing these gates, this
metaphorical jail gates open; what can the community do to stop something that
shouldn't be going outside of the jail, to use the analogy?

**Paul Sztorc**: Well, the way I see it is actually somewhat different.  I
actually see it as the metaphor that I used, when I described it back in
November 2015, was actually a lot like mutually assured destruction, which has
taken on a new relevance now that just recently, Vladimir Putin has tried to
nuke every other country that...  So, this idea has taken on new relevance that
there's a line in the sand that people would want to cross.  So, I almost think
that people shouldn't do anything.

But to answer your question, the layer 1 nodes, if they activate BIP300, they
know which outputs are spent into sidechains, so they know how much money each
sidechain has, because it's just like a certain address or something; and they
also know when someone initiates a withdrawal attempt, it has a little score,
which again is just a number that's counting up to 13,000.  And then it has
26,000 blocks, six months, for the number to reach the goal, and then it times
out.  There's some other stuff as well, such as anyone can introduce a new
withdrawal at any time.  But if you upload one, it downloads the others.  So,
that prevents the DoS attack in both directions.

That's basically the whole idea.  All the people on layer 1 are only seeing this
little integer.  And they don't get to see the sidechain data, nor any of the
sidechain messages, and they don't do any validation on the sidechain, which is
the whole point.  That is a very essential point.  It would be a disaster.  It
would be trivial to simply just say, you could just declare the sidechain
consensus rules are part of mainchain consensus now, and then nothing could ever
go wrong, like the miners could never steal, or whatever, but this would now be
basically a hard fork, blocksize increase in a very curious way.

But yeah, the issue is since layer 1 is not seeing anything on layer 2, the
miners can just try any withdrawal they like, they can move the counter up, no
one's layer one node will know anything about why one withdrawal should be
favored over another, and whenever the withdrawal gets to 13,000, then the
relevant withdrawal can be included in a block, and the coins can then be
withdrawn to that pre-declared destination.

**Mark Erhardt**: So this count up that you're mentioning, that happens in the
coinbase transaction, or why does it have to be done by the miners?

**Paul Sztorc**: It is a coinbase transaction because we want to just make it
clear that it is within the domain.  I mean everything is, the miner can control
the whole transaction.  But yeah, you asked about the pushback; I think an
enormous part of the pushback, in my humble interpretation as the author, which
I may be deluded by my own ego or whatever, same as anyone else, but my own
interpretation is that I had a very unfortunate historical timing where this
idea was proposed right before segwit, and then as soon as segwit was finished,
it was immediately blockaded by the miners, thus starting the acrimonious miner
versus developer blocksize war.  And I think that just made people's minds
incapable, if you like, of considering the idea.  But yeah, it's a coinbase
transaction because it's just the easiest way of having the money.

**Mark Erhardt**: So, if it has to happen within 26,000 blocks and it requires
13,000 of those coinbases to count up, it means like 50% of the hashrate has the
support the withdrawal for it to happen; is that right?

**Paul Sztorc**: Yes.

**Mike Schmidt**: And is your summary -- you mentioned one objection,
essentially rounding to not trusting the miners; is that what it would round to
here; is that the steel man objection here?

**Paul** **Sztorc**: Well, yeah.  I mean, the two that I normally get are,
"Miners can steal", and that's number one; and it affects miner incentives,
that's number two.  But the sad thing is I anticipated both of those when I came
up with the idea.  So, even before I had written it down in November 2015, I had
worked all that out on paper, and I disregarded -- for a while, I tried to be
kind of very charitable and say there's all sides to an issue, but in my heart
of hearts, I really just don't ever believe that either of these two objections
have been reasonable because, first of all, the miners can steal, but I don't
think people realize that it takes months, and I don't think people realize that
it's just one hash that doesn't match a different hash, that the sidechain is
going to be screaming in all directions in every block, and in every sidechain
block header, so it would be very, very detectable.

But even if it weren't, the owner, the user, whoever is the Bitcoin owner, it's
their money, they can do anywhere they want.  They can sell the coins for goods
and services, or they can buy Ethereum or Solana or something.  So if they want
to spend to this script where they're slightly more vulnerable to the miners,
that's on them.  I think the "miner can steal" thing is often trotted out.  It's
an argument that's thrown out as if it's some kind of flaw that people could
fix.  But the point is, that's not the case at all.  Fixing it would be far
worse, because the only ways of fixing it involves mandatory layer 1 validation
of whatever these miners are supposed to be doing.  The whole point of it is
that it's loosely coupled, and that the sidechain's going to summarize
everything with one hash, and we're just going to say the miners can assert that
hash.  That's what allows it to break, and that's what we want to happen; we
want it to break, we want to be able to steal, because that's what lets us
ignore the sidechain on our layer 1 node.  And that's how you get, for example,
small blocks and large blocks to live together in peace and harmony, instead of
what we got, which I think was not ideal.

**Mark Erhardt**: Right.  So, if we forced the regular layer 1 miners to
evaluate all the sidechains, it would be basically a mandatory extension block.
That's not very popular, obviously.  So, sorry, one more follow-up question,
wouldn't indifference then be a huge issue; so, if less than 50% of the hashrate
cared about the sidechain and didn't count up, you could never withdraw from it?

**Paul Sztorc**: Your understanding is correct.  But again, it's designed with
that in mind.  The user who deposits to the sidechain, they take that risk on
themselves willingly.  But yes, it's true.  But you have to consider what
actually will happen.  As long as the sidechain is still being mined, which it
could be merge mined and it could be blind merge mined, my other thing; but even
if it's just regular merge mined, that usually happens on autopilot and so
blocks will still be found over there.  So, even though the coins cannot travel
back from the sidechain to the mainchain, they can still switch hands over in
the sidechain world.  And so as a result, if people are indifferent, they can
just sell the coins to other sidechain users.

If the miners are indifferent, then this creates a problem with the bridge
between layer 2 and layer 1.  The bridge becomes a one-way street, which would
be problematic for anyone who wanted to go the other way.  People can still sell
the coins or switch to someone who's more patient over there, and that person
may actually be a miner themselves, or they may be someone who knows the miners,
or someone who can get their attention.  But again, this is part of the delay as
well, because the part of the delay is, inescapably, there will be some kind of
imposition at some point of layer 2 on layer 1.  That's the only way of having
the coins change hands and having it affect layer 1.  So, eventually there'll be
something, and so the goal is just to make it very, very infrequent and very,
very easy for everyone to observe.  That's why it's just one hash every three
months because, yeah, you have to overcome indifference.  So that is correct.

**Mark Erhardt**: Thank you.

**Mike Schmidt**: So, getting BIP300 activated has been a bit of a struggle, and
some smart people have come up with other ways that that sort of drivechain
functionality could be implemented without activating BIP300 directly, but
perhaps with, I think there's recursive covenants from ZmnSCPxj, and Jeremy has
his idea as well.  Jeremy, I'd like to bring you in.  One, I guess, do you have
any commentary on what Paul has said?  And then if not, we can jump into maybe a
quick summary of ZmnSCPxj's proposal, and then what you have been thinking in
your latest blog post and mailing list post.

**Jeremy Rubin**: Yeah, sure, that sounds okay to me.  I think Paul's
description is fair.

**Mike Schmidt**: Okay, great.  So what was ZmnSCPxj thinking; and then, what is
this idea that you've come up here with ANYPREVOUT (APO)?

**Jeremy Rubin**: Let's see, I'm trying to think.  So, basically what ZmnSCPxj
and I have been thinking about is implementing various types of counters in
basic covenants.  And there are different ways that you can do that kind of
thing.  And so a while ago, ZmnSCPxj wrote up a nice post about how you can
implement a specific kind of counter in a recursive covenant, and how he set it
up was he used something called a Peano number.  And what a Peano number is,
it's basically a number which is represented in essentially unary instead of
binary or trinary, everybody's favorite number system, decibel.  Unary is
basically just like tallies, you just count the number of ones that you have,
and then that's what the number is.  But particularly, it is a structural tally
where you have a base number, which is 0, and then you have a successor
function.  And successor is really a type.  And so if you do successor,
successor 0, that would be the number 2, for example.

One thing that kind of looks a lot like Peano numbers is a hash function.  So,
if I have a, let's say, a hash preimage, which is 0, just like the all 0s,
32-byte string, and then I hash it, and then I hash it again, and again, and
again, that hash, that later point, kind of represents a number, it's like a
Peano numeral.  And if you provide the preimage to it, you can get the
predecessor; and if you hash it again, you can get the successor.  And so, it
functions essentially the same as a Peano numeral.  And so ZmnSCPxj's core
concept was that you can use these hashes to do a basic Peano arithmetic in a
smart contract.  And then you can essentially collect the tallies and votes in
the way that drivechains, kind of requires, in a sense, as a covenant which
tracks one of these Peano counters.  And then, when the hash hits a certain
precomputed value, which would be, let's say the zeros hash-hashed 1,400 times,
or whatever the time target is that you pick for how many votes you need, then
you can take some resolution action.

**Mike Schmidt**: Jeremy, is the crux of this, going back to what Paul was
saying about having the counter and then Murch's point of it being in the
coinbase, this is just a different way of having that counter be on chain
without having it necessarily have to be in the coinbase; is that what we're
trying to recreate here?

**Jeremy Rubin**: Yeah.  So I mean, I think that basically the implementation of
something like drivechains doesn't really matter as much as it matters that
there's a way to implement a smart contract that has a counter that you can
increment and decrement.  And that's really kind of the concept that is -- I
mean obviously, the application of something like a drivechain matters.  If you
just had a counter that has no state effect after the counter reaches a certain
value, then it's not really doing anything, it's just sort of like a little
program living in Bitcoin.  And that's really the angle upon which I've been
attacking this.

I don't really particularly care for, let's say, the application in this, but
what I'm really interested in is proving out the balance of what types of
computations you can run using various primitives in Bitcoin.  And I was
thinking about APO, for example, and I was like, "Oh, actually, you can make a
pretty cool gadget that implements a certain sort of finite state machine
logic".  And a classic thing to implement is a counter as a state machine.  So I
implemented a counter, and then once you have a counter, then that's sort of one
of the really core components required to implement drivechains.

**Mike Schmidt**: Jeremy, what are some other applications of this sort of
research?  We have the counter that could enable drivechains; what sort of other
interesting things do you see could be enabled with such research?

**Jeremy Rubin**: So, I would have to do more analysis.  So you can't, I don't
believe, create like a Turing machine in this model for a couple reasons, but
there are certain types of thing that one can construct that gives you certain
computational bounds on much more powerful types of smart contract.  And in
this, it is a kind of innumerable finite state machine, which is just sort of a
level up in terms of computation compared to what's been done previously.  And
there are lots of applications, which if you can represent them as a small
finite state machine, small and finite meaning somewhat different things, then
you can use this type of gadget design plus, let's say, like maybe a compiler,
and you could write little Python programs, let's say, and then those Python
programs could get compiled into Bitcoin scripts.  And then those Bitcoin script
primitives would be non-terminating, like they could run forever, for example.

**Mike Schmidt**: I saw that the mailing list post got ZmnSCPxj's response, but
have you gotten other responses from the community on this idea or similar
ideas, outside of the mailing list, that's noteworthy of feedback?

**Jeremy Rubin**: I've not gotten that much feedback, to be honest.  I actually
came up with the idea for this in May or something, and I just kind of forgot to
post it.  So, I found it while I was cleaning my system, and I was like, "Oh, I
probably should post it".  So, I sent it out a while ago.  I'm not sure if
anybody has fully followed the argument of what you can build, or the
construction.  So, no, I think it's still kind of percolating into the
collective conscious.  So, I'm grateful for the opportunity to explain further
here.

**Mike Schmidt**: And Paul, do you have thoughts on Jeremy's method of
potentially enabling a drivechain, obviously if these sorts of changes are made
to Bitcoin?  Do you care about the end result and not necessarily how you get
there, or what are your thoughts?

**Paul Sztorc**: Well, yes, that is the case.  I do care about the end results
and not particularly how we get there.  Although, of course, BIP300, it was
designed with all the efficiency in mind, so it's supposed to be really, really
simple, the most efficient use of block space, bytes, CPU, etc.  More
importantly, I kind of just think if there's some other thing, more general way,
recursive covenants, APO, whatever, if those things let you do drivechain, then
to me it just speaks all the more to how silly it was to not be pro-drivechain
the whole time.  And so, I mean personally, just my own opinion, I understand
that you have to persuade people and such and such, but I regard all the
drivechain opposition as irrational and I regard all of the attempts to do it in
a very circuitous way, I think to me that looks kind of like mental illness or
something.  I just think like, why are people doing this?  But I realized that
the decision is not up to me.

But all the information that I published is there waiting for everyone, and all
the sidechain clients, we have a Zcash sidechain and stuff.  The sidechains that
we built are there for anyone to take if they ever want to take them.  So, yeah,
I mean I agree that it doesn't really matter.  At the same time, though, I just
wonder what combination of beliefs do people hold in their head this whole time
that makes them consistent, I guess, if that makes any sense.

**Mike Schmidt**: Murch, do you have any questions or follow-up or comments on
drivechains and APO enabling drive chains or covenants?

**Mark Erhardt**: I'm afraid I just have the most frustrating answer.  I don't
know.  It's just not part of the things that I've thought a lot about or have
spent a lot of time on.

**Mike Schmidt**: Paul, I mean just riffing off that, is that a common comment
on this?  Is it people just aren't interested in it or do you feel like there's
active --

**Paul Sztorc**: I think a lot of people do say something like, "I've heard
about that".  People say like, "I always wanted to read about it more, but I
never had time".  I think there are things going in fashionable waves.  It's
just my opinion that, you know, you have these places like Chaincode, you have
Blockstream, and I think it's like anything else.  I mean, I used to be in
academia.  There are fashionable ideas come in, and something gets hot and
people worry, "I mean, I've got to get on this hot thing because that's how I
get a job, that's how I get a grant, or whatever, that's how I have a career".
I think that's part of it.  I really do think a lot of it is related to the
blocksize war.

In particular, there's something else, which is that sidechains allow you to
leave the Bitcoin Core software, but once people study the Bitcoin Core software
a lot, they have a kind of loyalty and a friendship to it, etc.  So, the idea of
leaving is kind of strange.  In my view, everyone is imprisoned in the Bitcoin
Core software and sidechains allow you to escape the prison, but a lot of other
people find that to be sort of rude.  They object to me referring to it as such
an undesirable place to live.  And they say, "This is my home.  This is like
Yoda in Empire Strikes Back".  They're like, "I like Bitcoin core.  I don't want
to leave".  So I think it's a bunch of weird ideas like that.

I think Blockstream had an officially endorsed point of view that because of
pools or because of mining centralization, both of which I think are irrelevant,
but because of those things, according to them, that it was too risky to attempt
this idea at this time, or something, which I thought also didn't make sense,
because they could always leave whatever the conditions were in one year.  If
they could change and improve to a later year, then they could also get worse.
So, if that was a changeable thing, then the argument didn't seem to be
coherent.  But more to the point, it's kind of like, again, as I said, it's the
user's decision to where they put their coins.  So, any risks, it just needs to
be a risk that some people would be willing to take.  Maybe you personally
wouldn't do it, but some other people would.

This was before the blocksize war in 2015 that I wrote this, so it was all
before.  There was this split in the community, and so I could say all of the
large blockers are pro-SPV validation.  So, I don't know.

**Jeremy Rubin**: I've got a question for you, Paul.  If Rootstock and Liquid
and, I don't know, WBTC on Ethereum, if those were all with a drivechain, do you
think that they would be more popular than they are?

**Paul Sztorc**: Well, that's a good question.  I'm not sure because my spiel
about -- well, first of all, WBTC, you're referring to Wrapped Bitcoin in
Ethereum, right?

**Jeremy Rubin**: Yeah.

**Paul Sztorc**: One thing to point out is that there's like a hundred times
more coins, like billions of dollars of coins.

**Jeremy Rubin**: Oh yeah, I mean I think that there's real demand for that and
I think that that goes to the likes that it's run, you know, in a system that
has more things, network effects going on.

**Paul Sztorc**: Yeah, that's an interesting case because that's like, whatever,
literally a hundred times more popular than either the LN or Liquid, which is
like, I wonder what to make of that.  Is it because Ethereum, and whatever; is
it for no reason at all; is it because people actually really like the
sidechains idea so much that they do it on the Ethereum?  I wonder about that.
I think Liquid is kind of a dark horse, or like a kind of a black sheep, I can
mix all these metaphors.  I think the Liquid people say and maybe I'm totally
wrong about this, I could be totally wrong about this, 100%.  Maybe anyone could
just jump in and be like, "Oh, you're 100% wrong".  But the Liquid people say,
this is a federation where it's a multisig address.  No one knows who the key
holders are.  They never tell anyone who the key holders are.  No one knows how
the ceremony was performed.  No one can prove that the ceremony happened a
certain way.  Most of that software is not open source to this day, at least
last time I looked into it wasn't, so they have all these kind of peculiarities.

All the transaction fees in Liquid, for what this is worth, which is not very
much, but I'm just speaking to how different it is, all the transaction fees go
to a wallet controlled by Blockstream.  I'm not saying there's anything wrong
with that at all.  I'm just saying this thing is kind of weird, and the
Blockstream people say that that doesn't matter or it shouldn't matter.  But I'm
not sure, I think they may have underestimated the customer.  I think the
customer actually would like to know some of these details of information.  What
do you think about that, Jeremy?

**Jeremy Rubin**: Yeah, I mean I think that --

**Paul Sztorc**: I think that may speak to the lower demand for it, because
people are just like, "Okay, what is that?"

**Jeremy Rubin**: I think the issue is, I think that there's a little bit of
like an anti-competitive nature where like, "Everything else is bad, don't do
this".  But then, like, all the other things that are bad are just, I don't
know, other things that lots of people are using.  And then Blockstream's
product is not particularly open source either.  So, you can't really just run
your own instance and compete on one of the Core things, which is like, who are
you trusting when you run it?  And so, I think you're probably right that the
consumer is like, "I don't want to send money to Blockstream's Federation
because I don't really even know who is a participant".  It might be listed now,
but for a long time, it wasn't publicly listed.

I also don't even know what software they're running because that software is
not publicly available for audit.  And so, whether or not something like
Ethereum is a lot worse, at least all the code is open source.  So, maybe that's
why people have a preference for it.  Or if you have WBTC, it's explicitly
custodial, and they don't make any presumption around it not being custodial.
Yeah, Murch?

**Mark Erhardt**: Yeah, I think that there is also a significant starting cost
to get into Liquid, at least as one of the federation members.  I think that you
can just use it as a wallet user, but if you want to issue assets or want to
participate or check the validity of what the federation does, there's a package
you have to buy, which I think was fairly expensive.

**Jeremy Rubin**: Yeah, and I think that they also misrepresent a lot of the
claims.  One thing that people don't usually commonly realize is that in order
to withdraw from Liquid, you can only withdraw to a whitelisted entity, which is
usually an exchange.  You can't actually directly withdraw as a user, which is
just sort of a weird thing that I think is obviously not put everywhere all over
the marketing, but it means that you always have to go through single point of
failure and how they currently accept whitelisted entities.  So, it's just sort
of has weird properties.  I think the market might not explicitly know them, but
the market implicitly learns these things because people try to do these
operations that are like, "Oh, I can't actually do this".  People don't build
projects that rely on those things being able to happen.

But anyways, I did want to pivot a little bit, just into talking about the
actual novel mechanism, because I think that this is all stuff that maybe people
are familiar with, like the arguments for these other things.

**Mike Schmidt**: Go for it.

**Jeremy Rubin**: So, yeah, I guess the new mechanism here is that people are
familiar with APO, right; or should I explain what that is?

**Mike Schmidt**: I think you should give a quick overview.

**Jeremy Rubin**: Yeah, so APO is a relatively old proposal.  It used to be
called SIGHASH_NOINPUT.  And all that it's saying is that right now when you
spend a bitcoin, you authorize a particular coin, and that signature is unique
to that exact output that exists.  APO would get rid of that and would allow you
to bind signatures to the keys.  And so any output that has that key would be
able to be spent with that signature.  So, you can imagine a cool thing, which
would be like a wallet sweep behavior.  So, let's say that you're doing key
reuse, and you have a million outputs, and they're all the same size, let's say,
for simplicity, and you want to send all of them, you can sign one transaction
and that transaction could be applied to all million outputs.  That might not be
super-useful, but that's just generally what the thing of APO is doing.

That use case is not super-useful, but there's a use case that people do really
like, which is for the LN, which is something called Eltoo, which I don't like
the name.  So I prefer Decker Channels.  And the idea behind Decker Channels is
that you can implement something called a ratchet protocol inside of this APO
thing, where for the LN state updates, instead of signing them using normal
signatures, you can just sign something that is always valid and bound to the
key.  And so, what you do is you set up a little state machine.  That's where
it's kind of similar to the stuff that I'm working on.  You set up a little
state machine that has a counter, and the counter inside of that state machine
can only count upwards.

The important part of how those channels are set up is that the counter at each
number, you associate with it a new key, and that new key is only used once.
And that new key that you've associated with the counter at that point in the
contract, you also sign some time-delayed resolution with it.  So, for example,
at state n, I might sign with some key k, n+1 or something, and then that n+
first state would then have a specific resolution, which would be like after two
weeks payout, Alice and Bob, their channel state for state n+1.  And there's an
alternative path, which is just with key ratchet, and key ratchet basically
allows for any signature against key ratchet that has a higher locktime value.
And the trick is that you use the locktime values that have already expired for
this ratchet, and there's something like a couple of billion of those.  So, you
can use these channels for, like, a billion state updates.  Is that an okay
explanation of APO, or am I a little bit sleepy-brained?

**Mike Schmidt**: No, I think that's good.  Did you want to continue?

**Jeremy Rubin**: Yeah, so it's a soft fork.  It would be able to be put as a
part of taproot.  It could be independent of taproot, though, like it could have
applied for ECDSA as well.  It's just a general idea about the sighash
(signature hash) digest algorithm.  And so, with APO, you can do a couple of
things interesting.  So, one is you can implement something that's similar to
CHECKTEMPLATEVERIFY (CTV) covenants, which is where you define a finite
expansion of a state.  So you could just say, starting from a set of terminal
states, you can construct a special script and then work your way backwards from
that to the beginning opening state.  And then you can commit to a coin that
enrolls in a very specific particular order to a leaf node.  That's one option,
and that is a non-recursive computation.

Or, this gets into where the new thing is, you can implement a tieback.  And the
tieback that you can implement allows you to create infinitely looping Bitcoin
smart contracts under a one-time trusted setup assumption.  And so essentially,
you can imagine the simplest case of this is just a simple loop.  And so, you
can think of this as like the simplest version of the gadget; let's say that I
have a key k, and that is just a taproot address, and the only scriptpath is key
k.  It has to be a scriptpath based on how taproot was implemented.  And that
key k is authorized to spend with APO.  And then I sign a single transaction
from that APO, and then it is authorizing transferring the 1 bitcoin in this
contract back to the same key k again.

Now you can keep on broadcasting the transaction for that infinite times, it's
always valid.  Does that make sense to people?  It's like key k transfers to key
k, key k is authorized to transfer to key k, there's, there's no termination in
that logic.  Does that make sense?

**Mike Schmidt**: Makes sense.

**James Rubin**: And so then basically, if you extend this logic out a little
bit further, you can say, "Okay, well, what if key k transfers to key k2 okay,
so key k to key k2, and then key k2 transfers to key k1?"  So, now you can go
key k1, key k2, key k1, key k2, and then you have a computation that is a
wrapping binary counter, right, does that make sense?

**Mike Schmidt**: I think so.

**Jeremy Rubin**: Okay.  And so, this is really where the core idea is for this
thing, is what if we build an arbitrary counter?  And let's say it's of length
n.  So we can go key k1, key k2, key k3, key k4, key k5, etc, key kn, right?  So
now, we can count forwards in one direction as much as we want.  The other thing
we can do is we can count backwards.  So, what if we also add an authorization
that lets us go from key ki to either key ki+1 or key ki-1?  So then when we're
at state i, we can go from ki to ki-1 or ki to k+1, and then k+1 can go back to
ki, and then ki-1 can go back to ki again.  So now, at each step we have a
little loop as well as a next step, or each step has two loops that it's
involved in.  Does that make sense?  There's the forward direction and the
backwards direction.

**Mike Schmidt**: I'm hanging on by a thread.

**Jeremy Rubin**: Okay, what part of that --

**Mike Schmidt**: Feel free to keep going.

**Mark Erhardt**: I think it might be a little complex to explain audio only.
We do also come up on towards the end of our hour, I think we might want to get
into a few more other things we have a list of, so if you could find a way to
wrap it up.

**Jeremy Rubin**: Okay, well, the punchline is more or less that for any finite
state machine that you can come up with, which is basically like a program that
is represented by a known graph, what you're able to do is use APO and one time
setup, which means that the program could have been set up like a million years
ago, and there's no new information that you need to introduce into the system
to keep on running the program, which is different than other new covenant
systems that might have ongoing or per-instance requirements.  These are just
basically public parameters that you can create, let's say, in a build with the
100 Bitcoin developers who you trust at a given time.  And then, as long as that
trust assumption remains valid, and at least one of them destroyed their key in
that ceremony, then the setup of this covenant would be clean.  So then, you can
build these infinitely looping small programs and just run them, add and fit
them.  And a particular use case of this is drivechains, where you can implement
a counter, and then with channel state, you then have reached consensus that
you're supposed to make the appropriate redemption to people.

The other part is that there's ways that you can find rules for merging two
state machines.  So, if you have one state machine and another state machine,
you can define specific rules that take two state machines and collapse them
into one.  And you can also define rules for state machines that fork in other
state machines.  So, you can write these sort of parallel, parallelized
fork-and-join types of state machines, where state machines at different states
are allowed to join together, which that part is quite novel and enables like
much more sophisticated types of applications.

**Mike Schmidt**: And if folks are interested in more of the technicals that you
were getting into, this is represented in your latest blog post, right?

**Jeremy Rubin**: Yeah, you can find it on my blog.  It's just on rubin.io, and
it should be called Spookchains.

**Mike Schmidt**: Excellent.  Yeah, I think in the interest of time, we'll move
on to some of the other newsletter items.

_Federation software Fedimint adds Lightning_

There is one that maybe is somewhat related to the sidechain discussion, which
is the Fedimint.  So Fedimint, since the last update I guess, Blockstream has an
update that that Fedimint project has integrated LN support as well as a public
signet and a faucet as well.  I'm not sure if, Paul or Jeremy, you are familiar
with Fedimint or care to comment on that.  We haven't necessarily covered this
in our previous discussion, so maybe a quick overview if either of you feels
comfortable with that competing sidechain-ish technology?

**Paul Sztorc**: I'm not as familiar with it as I would like, I'll tell you
that.  But I do know that there's this part of it that I'm not 100% comfortable
with it, which is that the proponents of the Fedimint say, "Hey you have a
friends and family that you trust, so you can all have one Bitcoin address
together", or something like that, is kind of a really, really unfair summary of
it.  But I don't know.  One of the reasons why I trust my friends and family is
that they can't just easily steal all of my money.  If they could, I would
probably be a little more suspicious of them.  And so, I'm not sure if that 100%
squares.

People say the same thing about drivechain, but the whole miners can steal thing
is supposed to be offset by the six-month thing.  So, I don't know, but that's
just my little comment on Fedimint.  My very uncharitable summary is that you
have a little group that you sort of trust, and then within the group you have
all the great things in life.  You have Chaumian e-cash, but they can steal your
money.  So, I'm not sure how cypherpunk it is.  I'm not sure how I feel about
it, but I don't know as much about it as I would like.

**Jeremy Rubin**: Yeah, I think I would say that it seems like it's good
technology, and I'm glad to see it getting developed.  I think what I don't like
is, this is sort of like a facet of how the Bitcoin community responds.  There
are so few things happening in Bitcoin compared to other ecosystems, and there
are maybe people who have a lot of influence who throw it around in various
ways, that we get really into narratives being built out.  And then there's like
one project which represents the narrative, and then we pin all of our hopes and
dreams and ambitions on it.  We saw that happen with the LN, for example, where
it was like, "Oh, Lightning is the solution for scalability", and then
everything else was to the detriment of that.  And then that kind of a little
bit more feels like a centrally planned model, even if the consensus narrative
forms in a decentralized way.  I think is really harmful for actually having a
healthy competition of ideas to try and beat various goals.

So, I'm excited for Fedimint to be like a new project and new capability for
moving coins around.  But I think it matters to have just more competition in
types of things that people can do, and I don't like how people are kind of
building like, "Oh, this is the narrative now", which I've seen a little bit of
that activity around it.  And I think we shouldn't try and form narrative, we
should just try and figure out if software wants to be used by users.  And then
if it does want to be used by users, then it's a narrative.  It's a sort of
cart-before-the-horse behavior.

**Mark Erhardt**: You were breaking up a little bit at the end there, but I
think we've got the gist of it.  I think my summary of Fedimint would be that,
on the one hand, the Chaumian e-cash setup is a completely different method of
trading value, and it has very strong privacy, much stronger privacy than either
LN or onchain Bitcoin transactions.  But on the downside, clearly, as both of
you have said already, there is the question of how the custody of it is solved,
and you do trust fully the federation to operate correctly.  And it's really
hard to audit, so that's clearly the downside.

But Fedimints by themselves, the Chaumian e-cash setup, as far as I understand
would be a huge scalability and privacy boom.  And with the interoperability of
Fedimints via the LN, you could even maybe easily pay users of other Fedimints
by just bridging through the LN.  And what I find attractive about this is I
think that it breaks through some of the things that I perceive to be hampering
other projects we talked about earlier, which is it doesn't require the full
network to opt in, it just requires some people to be interested in pooling
their funds, setting up some federation that they trust, and it's all voluntary
from all sides, and no protocol changes are needed.  It's just, it doesn't even
seem to be that big of an engineering leap.

We saw this other week that Cashu, like I would say a very basic variant of the
Fedimint idea, somebody, Callebtc, set up a fully trusted Chaumian e-cash system
that is also Lightning integrated, which he calls Cashu.  So, I think I wouldn't
say that it's centrally planned, it's just that they managed to get a little
more interest for their idea pretty quickly, and it is currently the narrative.
We'll have to see whether it plays out in the long run, but I don't think that
there's a group of people sitting somewhere determining what ideas are allowed.

_Mempool Project launches Lightning Network explorer_

**Mike Schmidt**: A couple other updates that were noted in the Changes to
services and client software section, one is the mempool project launching their
own LN explorer, which is a page on the mempool.space website, which shows some
aggregate statistics as well as some rankings of individual node liquidity and
connectivity data.  And I believe that they're working on getting that cleaned
up a bit to be part of one of their open-source releases.  But right now, I
think it may just only be live on the mempool.space website.  So, pretty cool
little dashboard tool.

_Bitpay wallet improves RBF support_

Another one, and this is actually really an update from a while back, but
there's been a recent change to it, but Bitpay's wallet added RBF support, and
the note in this newsletter was that they improved their support.  There's some
apparent fix that they had for this, but Bitpay did add RBF functionality in the
last months actually, maybe as long ago as late last year.

**Mark Erhardt**: Yeah, it was November last year, and that's actually a little
funny to me.  Bitpay, being such a big proponent of the big block narrative back
then, being so much earlier to fully support RBF than a lot of other services in
the space.  I think people could take a look at themselves there a little bit.

**Mike Schmidt**: Yes, that's one of the reasons that I thought it would be
interesting for our audience that they have been quite vocal against things like
RBF, but their wallet software does indeed support it.

_Mutiny Lightning wallet announced_

Then the last client service section update was I saw that there was a new
Lightning Wallet, Mutiny Wallet, had a previous name of pLN, which I think is
Private Lightning Network, and they're a privacy-focused Lightning wallet, and
they actually borrowed some of the John Cantrell's Sensei work to enable privacy
by essentially spinning up different nodes for each channel.  And so this is
very alpha software and in fact I think, I'm not even sure that you can receive
right now, I think it's just sending only, but I thought that was interesting
concept.  Murch, I don't know if you have thoughts on that approach.

**Mark Erhardt**: I think you have the main gist of it, right?  Basically,
instead of being a fully interactive Lightning node on the network, you only
send, and for each channel that you generate, you act as if it were a completely
separate node.  And that makes it harder to track your activity on the LN across
all of your channels as being from the same entity.  And I think that their idea
is, in the long run, to use blinded channel in order to enable forwarding and
receiving through that node and unannounced channels.  So, the advantage of
senders in the LN right now is of course that they do not reveal who they are
and they don't have to.  The receiver has less privacy, but with blinded
channels I think that receivers can regain some privacy as well, and that might
work out to enable them to receive too in the long run.

_Eclair #2418 and #2408_

**Mike Schmidt**: Murch, that is a good segue to some of the Notable code
changes, and specifically Eclair adding support for receiving payments sent
using blinded routes, and also the dimension of unannounced channels.  Do you
want to give a quick summary since we're on that the topic of blinded and
unannounced channels?

**Mark Erhardt**: Sure, what are they?  So, unannounced channels are simply,
they used to be called private channels, but I think unannounced fits better.
It's simply a channel that isn't being advertised on a network.  So, people can
learn about it existing when they, for example, send through it.  It's not
forbidden to tell other people about it, and you cannot prevent it, obviously,
but generally they're not being advertised, and they're mostly used, for
example, for mobile clients or participants that are not online all the time.
And yeah, they should just not be expected to work for routing, that's the main
idea, and they might be a little more private, too.

Blinded routes are the idea that, instead of telling the sender where to send
the payment exactly, you can basically give them a little package of a few
onions that are the last hops in the route, and they don't actually learn who
the final recipient is because instead of putting the final recipient, they put
that onion at the core, and once it gets there it gets unwrapped and the payment
gets forwarded to the final recipient without revealing to the sender who the
final node was that unpacked the pinion.

_Core Lightning #5581_

**Mike Schmidt**: Thanks, Murch.  We skipped over the Core Lightning (CLN) one
because the blinded routes was applicable to the Mutiny discussion, but CLN just
has a new notification for when blocks are added.  You can subscribe to that
notification if you have a plugin in CLN, and you can get notifications when
bitcoind receives a new block, so that's fairly straightforward.

_Eclair #2416_

There's another Eclair update, and this one is around receiving payments via the
offers protocol proposed in BOLT12.  I think we've covered offers, but maybe,
Murch, do you care to provide a quick summary of offers, and maybe even BOLT12.

**Jeremy Rubin**: I've got to bounce, by the way.  So, thanks for having me.

**Mike Schmidt**: Okay, Jeremy.

**Mark Erhardt**: Yeah, thanks for joining us.

**Mike Schmidt**: Thanks for joining us.

**Mark Erhardt**: Yeah, offers is basically a newly thought-up replacement for
BOLT11, which specifies how invoices work.  And one of the things that it has
better support for is, if the sender wants to initiate a payment, there is
support in the spec for asking a receiver to create an invoice for them, and it
also supports a few other methods of creating the invoices and creating payments
that are slightly more advanced than previous specced-out methods.

_LND #6335_

**Mike Schmidt**: Great.  Thanks, Murch.  There is an LND PR here, LND #6335,
that adds a TrackPayments API, which is slightly different than their existing
TrackPayments API, and you get a feed of all of the local attempts at payment.
And the purpose of this is to, well, one potential use case for this is to
collect statistical information about payments, and that could be used for a
variety of different use cases.  And one example that is noted in the
newsletter, if you're using trampoline routing is also another application of
wanting to have that API implemented.  I don't know if we want to get into
trampoline routing or you just want to move on to this LDK, Murch, or do you
want to talk about trampoline routing?

**Mark Erhardt**: No, not really.  I mean, let me try to give a two-sentence
summary.  For nodes that aren't online all the time, it's hard to route through
the network because they might not have heard about new channels opening and
closing.  And they can basically delegate the pathfinding to another node by
crafting a payment that goes up to that node and then telling them to build a
multi-hop payment to the recipient who knows about the invoice.  So, they lose
some privacy towards the trampoline, but they can get around needing to know
about the whole network.

_LDK #1706_

**Mike Schmidt**: And our last PR here is for LDK, and this is around support
for compact block filters, so they've merged that support.  And so, LDK, if
folks aren't familiar with it, it's a library for Lightning functionality.
There's a lot of people who have used that LDK along with BDK to sort of build
wallets or Lightning wallets, but they've integrated compact block filters.
Perhaps we could do just a quick overview of compact block filters.  I know
we're over time, Murch, but if you want to take a crack at that, BIP158 and I
think 157 as well, right?

**Mark Erhardt**: Yeah, that's right.  So, if you don't want to download the
whole blockchain and validate it, you have a few different options.  The oldest
one is BIP37, which had very poor privacy towards the nodes.  You would just
hand them a bloom filter, and the full node would run the bloom filter on the
data they had in order to be able to tell the node, the SPV node, what they're
interested about.  They would basically learn all of the addresses that the SPV
node is interested in that, and also the computation was being put on the full
node, so it was expensive for the full node to offer that.

The more prevalent option these days is that you just talk to a central server
or an Electrum server, which basically has a full database of all the data and
they just look up what you're interested in, and you also have very poor privacy
to that.  So the idea is, well, just run your own Electrum server and trust your
own Electrum server, then you don't lose any privacy.  But that's, of course, a
lot of overhead for home users to run their own Electrum server, which requires
additional databases and a lot of, well, some setup work.

So BIP157, 158 is the idea to turn around the filter, and instead of asking a
full node to run a filter on the data that they have in order to identify what
might be relevant, you ask the full node to give you a table of contents of what
is in the block, and then you can run lookups against that table of content on
the side of the SPV client to see if there's anything relevant in the block.
And then you just get the full block and pick out the data that you're
interested in yourself.  So, that is much more private.  It's still a big
reduction in what amount of data the thin client has to receive in order to be
able to tell whether anything is relevant, but it is more bandwidth than the
previous approaches because you have to download the whole filter, which is some
kilobytes, I think 8 kB or so.

Yeah, anyway, so compact block filters allow thin clients to learn about blocks
that might be relevant to them; there's false positives, but never false
negatives, so they will not miss anything, but they might download some blocks
that turn out to not be relevant.  LDK, being basically a bring-your-own
blockchain sort of Lightning library, means that you can very easily run a
mobile client that just talks to any full node that supports compact block
filters in order to stay abreast of things happening on the LN.

**Mike Schmidt**: Great summary of compact block filters.  Thanks, Murch.  Well,
that wraps up the newsletter.  Paul, I know Jeremy had to go, so thank you to
Jeremy, but Paul, thank you also for joining the drivechain use cases and how
that's been going.  Murch, thank you as always for joining.

{% include references.md %}
