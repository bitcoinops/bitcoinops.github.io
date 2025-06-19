---
title: 'Bitcoin Optech Newsletter #355 Recap Podcast'
permalink: /en/podcast/2025/05/27/
reference: /en/newsletters/2025/05/23/
name: 2025-05-27-recap
slug: 2025-05-27-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding is joined by Alex Myers and Rodolfo Novak to discuss [Newsletter #355]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-5-2/401443098-44100-2-83c29b547d91e.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Dave Harding**: Welcome to the Recap for Bitcoin Optech Newsletter #355.
Today, we're going to talk about some recent Changes to services, client
software, and popular Bitcoin infrastructure software.  Your regular hosts, Mike
and Murch, are at a conference this week, so I'll be hosting today.  I'm Dave
Harding, co-author of the Optech Newsletter and the third edition of Mastering
Bitcoin.  We have two great guests today.  The first is Alex Myers, who will
talk us through a spate of recent changes to Core Lightning (CLN).  Alex, could
you please introduce yourself?

**Alex Myers**: Sure, yeah.  I've been a CLN engineer for a few years now.
Mostly, I work on the gossip protocol side of things, and I also work on
reckless, which is our plugin manager.  My background is more in electrical
engineering than CS, but I got so enamored with the LN that I kind of couldn't
stay away.  So, yeah, I've really been enjoying my time contributing CLN and
working with the ecosystem.

**Dave Harding**: That's great.  And our second guest today is Rodolfo Novak,
known to many as NVK.  He'll be talking about a recently added feature to
COLDCARD, and we'll lean on him throughout this episode for his deep knowledge
of what everyone else is building too.  NVK, would you like to introduce
yourself?

**Rodolfo Novak**: Hey, so yeah, NVK, I founded Coinkite.  We've been making
Bitcoin security devices and hardware for, I don't know, 15 years now.  And
yeah, that's what I do.  People know it for COLDCARD, BLOCKCLOCK and TAPSIGNER,
and other things like that.

**Dave Harding**: Okay, great.  Those are our two guests.  So, we're going to
just jump right into the newsletter.  The first section we usually have is News,
but we didn't actually find any significant news this week.  And I actually
think that's kind of great, not just because I'm lazy and I don't want to
actually write stuff, but also because I think it means people are out there
building stuff.  Between the big announcements that we cover, the protocol
changes, the theory about Bitcoin, we actually need people to be doing the
actual day-to-day building.  And that's kind of what this newsletter is about.
We're going to be looking at the changes to products, like what Rodolfo is
building, we're going to be looking at changes to code, stuff like what Alex is
doing, that actual stuff that has to get done when we're not sitting around
talking about, well, I won't say what we've been talking about lately, but that
stuff.

_Cake Wallet added payjoin v2 support_

So, going on to our next section, it's Changes to services and client software.
And we had eight this week.  The first one is Cake Wallet.  It's added payjoin
v2 support.  So, the original payjoin is a protocol that allows a wallet that's
about to receive a payment to communicate with the spender who's about to send
the payment, and they can actually include some extra inputs into the
transaction to break up the heuristics that companies use to try to track who
owns bitcoins.

V2 payjoin is a protocol that allows you to do that without the receiver acting
as a server, so previously they had to run a server.  So, it was great for like
BTCPay because they already have an HTTP server running.  But for other wallets,
it was hard if you're just using your regular consumer wallet.  So, v2 payjoin
protocol allows a third party to act as the server, in a sense, as a relay
server.  They don't learn any information, they just learn that people are
connecting through them, and allows people to use this really great privacy
protocol.  So, Rodolfo, Alex, you have any comments you want to add on that?

**Alex Myers**: I'd love to see more adoption of payjoin.  I want to break all
the heuristics, that's kind of my goal, so I love that it does that.  Also, I
think just managing your UTXOs by providing that input, you kind of limit the
growth of your wallet change.  So, I think it's a win all around.  I don't deal
too much with payjoin, but I love to see it.

**Rodolfo Novak**: Yeah, I mean it's super-cool.  Same thing I echo, I really
wish we would see more adoption.  I wonder if maybe LN wallets could start using
it for funding channels, and maybe there is a path there.  On the store side as
a merchant, it's really hard to sort of implement a solution that does find
other payjoiners to join, there is a bit of a chicken and egg issue there.  So,
I think maybe starting with things that have a lot of users, like LN wallets,
might be a cool place to start, because they have to fund it, right?  They have
to deposit something, either by themselves or by whatever magic of liquidity
happens.  So, I don't know, that's super-cool.

**Alex Myers**: So, LN does have a dual-funded transactions in which both
parties contribute an input and you get effectively a payjoin there.  But like
you said, the hard part is the marketplace for it.  So, like with CLN, we've got
liquidity ads where you can advertise in your node announcement, that's the
gossip message that says, "Hey, here's my node, if you want to connect to me,
this is where to reach me", and all of that.  And you can list like what rates
you're willing to -- if you want to contribute, like, half of a channel capacity
to a channel open, you can say, "Hey, I'm willing to contribute up to this
amount.  And this is the maximum fee that I'll charge you if you want to use
this channel to receive on", that sort of thing.  But yeah, it is hard to create
that marketplace where you can discover other people who want to create a
payjoin.

**Rodolfo Novak**: Yeah, it's like some automation there, some, "Check a box if
you want to participate", kind of thing in a high volume of users sort of system
would be pretty cool.

**Alex Myers**: Yeah, so I've been running it on my node for a few years now,
and it was experimental for most of that time, but I've had a few people open
channels, dual-funded, so it's nice to see there's a few people interested in
checking out the new features.  But yeah, I'd love to see more of it.

_Sparrow adds pay-to-anchor features_

**Dave Harding**: Okay, moving on to the next item, we have, "Sparrow adds
pay-to-Anchor features".  So, pay-to-anchor (P2A) is a specially formatted
output to a transaction that signals to the Bitcoin Network that it's meant for
fee bumping.  For that reason, we allow it to be an exception to some rules in
some cases.  Sparrow is a great wallet if you want to play around with some
advanced Bitcoin features.  It's a really nicely done wallet, I think.  And it's
great that they've added support for this, both you can send it, you can also
display it in their transaction explorer thing to see what's going on.  So, if
you got a weirdly formatted transaction, now you'll learn that it's got a P2A
output.  And if you want to create it, I don't know there's going to be a lot of
demand to create these in Sparrow wallet, what do I know?  They're mainly used
for transaction packages.  So, we see them a lot in proposals for upgrades to
the LN, where transaction packages can be really important for unilateral
closes.  But I don't know how often you're going to see them in typical end user
onchain transactions, but you have the option now in Sparrow wallet, so that's a
great thing.  Any colour, guys?

**Rodolfo Novak**: I'm just happy that Craig added a total amount for send to
multisig.

_Safe Wallet 1.3.0 released_

**Dave Harding**: Oh, okay.  Nice.  Okay, moving on to our next item, Safe
Wallet.  Safe Wallet, they have hardware device support in that wallet.  And
their new feature in this one that we've noted is a CPFP fee bumping.  So, this
is kind of the base feature you get before P2A, and it's great.  It allows you,
when you receive a payment, to increase its priority by bumping the fee on and
create a child transaction that pays extra fee.  And this encourages miners,
through the Bitcoin Protocol, it's an incentive to include that transaction.
You can also use CPFP on your own outgoing transactions if you don't want to
change them.  Although often in that case, it's better to use RBF, because
you'll save a bit on fees and should accomplish the same result.  But CPFP is
the only option you have when receiving a transaction from someone else
normally.  And so, it's a great addition.  Any comments on CPFP?

**Alex Myers**: I guess it makes sense for a multisig wallet.  It's going to be
a lot more pain to do the RBF and you might not have access to one of the keys.
So, sure, having more options is always nice for the user.

_COLDCARD Q v1.3.2 released_

**Dave Harding**: That's true, that's a really good point.  And then moving on
to our next item.  So, we have a new version of COLDCARD and I'm just going to
let Rodolfo take it away.  Tell us what's new in here.  I know a headline
feature, at least for me, and I'm really excited about it.  So, tell us,Rodolfo.

**Rodolfo Novak**: Well, go for it!  I'm just here to answer questions.

**Dave Harding**: Okay, well, the headline support for me is this new upgraded
multisig spending policy support.  And as I understand it, please correct me if
I'm wrong, you can set up one of your COLDCARDs in a multisig, maybe multiple,
but I know for one, to have a policy for what it's going to sign.  And I believe
that's pretty much automated signing, right?  Like, once you get it, get the
policy set up and you can just set it to PSBT and it'll just sign it for you if
it matches the policy, is that correct?

**Rodolfo Novak**: That's right.  And there's a bit of port-knocking sort of
mentality there.  So, it's not visible to an attacker that may be beside you.
So, unless the PSBT contains the xpub of the COLDCARD extra key, the policy key,
it's not displayed.  And you can choose to have it set up, you choose the
velocity, you choose maybe it's a whitelist of addresses, that's a very common
use.  There's also 2FA.  So, it's essentially like Web OTP.  So, you just scan
the web with a 2FA token, and you can also authorize that way.  So, right now,
this is sort of a pigeonhole to 2-of-3.  And we're looking into adding this
feature for a single-sig as well.  Always a little bit reluctant to do something
like that, because there is a limitation to how much a device can be secured by
one key.  But there is a lot of people who need this for their spending wallets
or for medium-sized amounts.  If you're not too concerned about laser fault
injection, then I think it's sufficient security.

I'm super-excited about this.  We spent a few years trying to figure out, how
can we create more serverless, higher thresholds of signatures for people to
operate on the field, especially because now people don't live in the same place
anymore, people are traveling, people are nomads.  And the codename for this
feature was 'Travel wallet'.  And we wanted to just make something that creates
a bit of a higher threshold of safety first for people to spend.  I would not
put your life savings on it, but it is definitely up there with most
server-based solutions in terms of actual practical security.  Yeah, and that's
where it goes on that feature.

**Dave Harding**: That's really great.  When I was doing the digital nomad thing
before COVID, that was a real concern of mine.  It was trying to figure out how
to transport my bitcoins safely so that I could access them when I was
traveling, but other people couldn't.  So, I mean I just love this feature.  I
think it also maybe enters sort of the vault conversation.

**Rodolfo Novak**: That's right.

**Dave Harding**: Stuff like this is what people want.  They want ways to secure
their bitcoins that's very easy to use.  You set up this policy and you just
forget about it, except you can spend, right?  So, great.

**Rodolfo Novak**: There was some inspiration based on OP_VAULT by Jameson.  And
if we're going to get covenants on Bitcoin or not, that's a completely
different, massive tangent.  But the reality is, we need spending policies,
right?  You can't exist in a financial, secure universe without, at a minimum, a
velocity limit or whitelisting.  And again, we just keep on breaking it down,
like how can we make this happen to people without having to call a server,
because the server is often the problem, especially when you're trying to be
sovereign, right?  You can't realistically leave a server running somewhere and
just expect it to be there.  I think this in conjunction with, say, decaying
multisig on miniscript, so maybe this is where the funds go to in case your
miniscript decaying fails or progresses, depending on how you want to look at
it.  There's a lot of permutations that this can happen.

There's also the business use case, right?  A lot of people in offices, you
have, say, two founders and they need to operate.  So, one founder has key A,
the other one has key B, and then both have key C, because you can use the same
key in two COLDCARDS.  So, both COLDCARDs can have spending policies set for key
C.  And that's really cool, because now at least you also have some auditability
because you know which key spent, if it was key A or key B plus key C.  So, the
two founders are able to spend on a limitation that they decide together.
There's some trust involved, of course, but then if they want to spend over the
limit and they're both traveling, they can just sign together with key A and key
B.  That's a super-cool thing.  And that ties into the other feature, the key
teleport feature.

**Dave Harding**: Yeah, tell us about it.

**Rodolfo Novak**: So, again, based on this idea that people no longer are at a
single location anymore, really joining that sovereign individual kind of
mindset.  I wanted a way to send a secret to somebody else where I don't trust
the phone, I don't trust the computer and I don't trust the comms.  Those three
places, nobody in their right mind trusts anymore.  That's why we do AirGap
things.  But if we assume in this trust model that the AirGap device is secure,
because it's already holding the secrets anyways, how can we create a simple
tunnel between the two so that it can send a secret.  And another aspect of that
was, how can I do that without needing again a server, or a server that is
something that the two agree on, right?  I mean, everything's a server, but I'm
getting that.  So, in a phone call, a video call, can I send, say for example,
key C to a coworker, COLDCARD; could I send him an SSH key because there is an
emergency with the server; or could I send him a truly secret message without
trusting the computer or the phone?

That's what key teleport essentially achieves, is this very, very hardened,
secure comms between two COLDCARDs via a untrusted channel.  And really, all you
have to do is the receiver essentially shows a QR code on a call, or you could
do NFC with a website that we created, and you can run that web on your own
computer if you want as well.  It's open-source code for you to do that.  And
you share this QR, which is essentially like a public key for a whole Diffie
session, protected by a small password, because some trade-off there on the ease
of use and really is just for the privacy of that disposable key, which is
already disposable anyways.  So, essentially you exchange the secret over a
different channel in case you have somebody watching that channel and you don't
want them to see the public key of that session.  And then, the other party can
send you anything from their COLDCARD, including the COLDCARD itself, by sending
the full backup of that COLDCARD.  So, you can teleport to that COLDCARD.

I think it's a very elegant, simple solution.  We really tried to keep it to
non-novel cryptography and in our usual way, just sort of bang it out there,
uses BBQr or I get NFC with this very simple spec.  I use it a lot like when I
have to help people set up COLDCARDs with BIP85 seeds, or friends, family,
colleagues need to recover a seed from some different hard wallet that they just
transferred to a whole COLDCARD that I told them to get, and then they send it
to me and help them discover whatever horrible derivation path they had.  You
know, the usual problems that Bitcoin ownership has.  I think this is a
super-cool feature.

**Dave Harding**: Yeah, that sounds really cool.  I like that it sounds like
something I could give to my dad, you know, I could give to somebody who is not
super-nerdy about modern security technology, and they could just use it.  Like
if you and I had to send a message, we could probably find a way to do it.  But
anybody else, they could just go out and buy a COLDCARD and we could just trade
messages.  That's pretty awesome.  Thank you for doing that.  That's a great
feature add.

_Transaction batching using payjoin_

So, I'm just going to keep moving on to the next item.  And that next item is,
"Transaction batching using payjoin".  So, there's an experimental
implementation of a transaction batching service.  I think this is here.  This
is kind of designed to allow multiple people to batch their transactions
together, kind of like a coinjoin, but for sending payments.  And it has what
they're calling a payjoin thing.  So, the receivers can also participate in the
transaction batching.  So, that's pretty cool.  It looks very experimental to
me.  It's explicitly says in the documentation, "Don't use this in production",
so that's a good sign that you shouldn't.  But it does seem like a nice path
forward for companies, organizations that are making multiple payouts a day to
different people.  They can set up this batching service and say, "Hey, Alex,
Rodolfo at 5.00pm today, you're going to get a payment.  But if you want, you
can also contribute inputs to this and just boost your privacy".  So, I mean
that's great, I hope people use that, and it's using the payjoin protocol.  So,
we talked about this earlier, as we get more support for that in software,
hopefully this will become more and more of an option for people.  Any comments?

**Alex Myers**: Yeah, it's great to see people playing with these sorts of
things and releasing this batching system.  So, this is the first I've seen of
it, but it looks exciting.

_JoinMarket Fidelity Bond Simulator_

**Dave Harding**: Yeah, I didn't hear about it until Mike put it in the
newsletter.  So, happy about that myself.  Our next item is, "JoinMarket
Fidelity Bond Simulator".  So, JoinMarket is a coinjoin implementation that
doesn't use server coordination.  So, Wasabi and old Samourai, they used a
server-coordinated coinjoin.  JoinMarket is P2P.  But because it's P2P, they
have problems with DoS attacks.  People can offer and say, "Hey, I'd be happy to
merge my coins with you".  And then, you go to them and you tell them about your
coins, because they need to know your coins in order to create a coinjoin.  And
then they're like, "Okay, well, I'm not going to create a transaction with you
anymore, I'm not going to sign.  And so, they learn that you're trying to get
privacy, and you do this through Tor, and whatnot, but they might learn stuff
about you.

To help cut down on that kind of problem, JoinMarket introduced fidelity bonds a
while ago, and that's a time locked bond.  So, you take your money and you spend
it to yourself but in the future.  Until that future point, you can't spend it.
So, there's a time value of money.  So, you're losing access to your money and
that's kind of a cost, but it's not a cost that's borne by anybody.  You don't
have to pay fees.  I think you're actually in the JoinMarket, you're actually
also allowed to destroy bitcoins.  And so, somebody has created a bond simulator
there.  So, for X amount of bitcoins that you put into this time locked
contract, how much money are you expected to make through maker fees in joint
market?

So, I should have explained, joint market as a P2P protocol also has makers and
takers.  So, makers are people who probably want privacy, but they also want to
earn fees, and they're willing to be patient and sit around and keep their
bitcoins liquid for you to come in for a coinjoin.  And then, takers are people
who want privacy right now.  So, they have bitcoins, they want to break that
transaction history, so they can go and find a maker and do a coinjoin with them
and get the privacy right away.  And often, you want to do that several times,
so you'll do your coinjoin with several different makers, either in a single
transaction or a series of transactions.  And the makers are the ones who are
advertising their service by creating these fidelity pods.  So, this simulator
just helps you find that sweet spot between how long are you going to lock up
your bitcoins and how much money are you going to make; because if you lock them
up for too long and you don't make much money, it's not worth it.  So, I think
this is a great piece of software.  Any comments from you guys?

**Rodolfo Novak**: So, part of our corporate strategy involves JoinMarket, and
we believe that you shouldn't reveal your coin pools essentially to vendors when
you pay them in bitcoin.  And we found that there is a lot of FUD with
JoinMarket.  It's just because, I guess, there is less visibility because there
is no centralized coordinator.  But it is surprising how much liquidity there is
at it.  It just may not be at that specific moment you look at the index.  You
can put in quite a lot of funds through it.  There is some leakage.
Unfortunately, the leakage is heavy on the taker side, just because of the sheer
amount of, you're going to have to do a minimum of seven rounds.  And if you
want that to move, then you're going to have to pay fees on top of the
percentage.

But the maker side is surprisingly good.  And if you lower your fees enough,
which many people do, the leakage is nearly zero.  You might actually make a
buck.  Also, personally, I recommend people just target neutral, just because if
they're doing this lawfully speaking with a tax bullshit participation in the
thinking, it's a lot easier accounting-wise if you have a neutral outcome.  And
what we're missing now really is just better UI for it.  Right now, if you want
to do it well, you have to use a terminal.  But I do highly recommend people
stop being afraid of it and use it.  It's perfectly good to do so, and there's
liquidity.

**Dave Harding**: Yeah, I think it's a great piece of software.  Go ahead, Alex.

**Alex Myers**: I don't have too much to add.  I just like to see tools like
this that bring a little bit more data to the table so that you understand
what's going on behind the scenes.  I think, especially in LN, we have a problem
where we focus on privacy, but it's kind of to the detriment of protocols where
it's a little bit opaque, like how much usage and details like that are
occurring.  So, I'm always for tools like this that help people understand a
little bit about the trade-offs and what they can expect.

**Dave Harding**: Yeah, it is great.  And I do hear you about how privacy, it
makes it hard to celebrate our wins.  Like, exactly how much liquidity is in the
LN?  I don't know.  There's private channels and stuff.

**Alex Myers**: And I think the private channels actually probably dwarf the
public ones, if we're being honest.  So, we have no idea.

_Bitcoin opcodes documented_

**Dave Harding**: Right.  So, there's a downside.  Obviously, we all want
privacy.  We just wish we could have everything, right, we can have our cake and
eat it too.  Moving on to the next item.  There's a new website here called
Opcode Explained, and it documents each script opcode, and they also have a
tutorial to help show you how Bitcoin Script works, which depending on how you
learned how to program, it could be a bit of a brain twist.  If you're more
familiar with the lower-level stuff, it's just like that's how it is.  But if
you only learned Python, you might need a little bit of tutorial there.  So,
it's great.  For each of the opcodes, you just pull up the thing and it tells
you what the opcode number is, what the representation looks like.  So, if
you're trying to decode some hex script, which if you get really into Bitcoin,
you will, and you actually start to read that stuff pretty well, I think.  And
then, what it does, and they have an example.  So, it's a really nice website
that just helps you through this stuff.  Up until this point, I've used the
Bitcoin wiki.  I think the page is named 'Script', and it has a list of all the
opcodes.  This is a lot nicer, especially if you're learning it and you don't
know what's there already.  So, kudos to whoever created this.  Any comments,
guys?  I think we'll just move on.

_Bitkey code open sourced_

And the last one is, the Bitkey code is open-sourced.  And I think I've seen
Rodolfo talk about the difference between open source and free software on
Twitter.  So, this is open source in the sense that their code is viewable, but
they have a restriction for non-commercial use.  And I think that's basically
what you guys do with COLDCARD too, is that correct?

**Rodolfo Novak**: Yeah.  So, it's a very complicated topic.  The OSI has a
different take on this, but essentially, I believe they use the same license
that we did, which is MIT.  It's extremely permissive license.  Due to
commercial issues with bad actors, we decided to add a commercial restriction on
the device.  So, the users are protected, they can do whatever they want.  They
can copy, they can change, they can give it to their friends, they can sell to
their friends, whatever.  It really is just a protection against people taking
advantage of the open nature of the device.

I think the difference is, the Bitkey hardware device has that license, but
Bitkey is not quite the hardware wallet, it's more like a backup device.  There
is a server which is a holder of one key, and I think there is an app as well.
So, it's sort of like one of the legs is open, the other legs are complicated.

**Dave Harding**: Okay, 'Complicated'.  That's a good description, I think.  Did
you want to say something else?

**Alex Myers**: It's nice to see some progress and moving in this direction.  I
guess personally, I'm more excited about fully open source, because then you
encourage external contributors that might not have volunteered their time to
review source code.  Otherwise, yeah, it's nice to see.  It's nice to see some
progress in this direction.

**Dave Harding**: I agree, it's nice that you can go and do the source code.
So, if you're starting to have a problem or you're concerned, I know somebody
who found a flaw in a hardware wallet.  They did, what is it, RFC, I can't
remember, 3757 for ECDSA deterministic nonce.  They had actually inverted one of
the operations so the deterministic nonce wasn't matching the thing and somebody
was able to go and look at the source code and figure out what was going on,
because it was just generating these wrong nonces.  It didn't realize it was
just -- anyway, so that's nice.  I also would love to see purely free software,
but I understand that there's other constraints out there.

**Alex Myers**: You know, it's one of those things that's a real shame.  You'd
think all users would be concerned about this sort of thing and be kind of
clamoring for at least having accessible source code here to review for
themselves.  But at the end of the day, you send out surveys.  I remember there
was one for the Jade and they were talking about anti-exfiltration and some fun
new crypto features.  And the major takeaway was that the features that users
were actually clamoring for was like, "I want more color options for the case",
that sort of thing.

**Rodolfo Novak**: We've been doing open-source Bitcoin stuff for literally
ever, right?  And we find that like 99.99% of the time is like, "Please don't
contribute to my codebase because your security suggestion is bad".  That
happens a lot.  And we find that the majority of the people who have a stake in
the game, right, they're holding reasonable amounts of funds and devices, they
will contribute regardless of the license.  And you get those; every time we
release new software, we get emails, PGP emails, "Hey, why did you change this?"
or, "Why did you do that?"  It is kind of fascinating.  A lot of that action
happens quietly.  Yeah, it's tricky.  And at the end of the day, users really
want practical things, right?

I think that the biggest advantage, at least just focusing solely on security,
not the ethical preferences of the licenses, is the reproducible code.  Because,
people wanting or not, when it comes to complicated things, we do rely on the
few who can understand.  And if they trust that that signature matches, and you
can check that it builds to that, it is a total superpower.  I mean, it's hard
to convey that to get to that level without reproducible builds, you have to go
into a military facility and have like three people to essentially review each
commit, and then there's three people who review the commits of the three people
who review the commits.  It's super-cool, so props to them for making that at
least open for review.

_LND 0.19.0-beta_

**Dave Harding**: Yeah, yeah, that's great.  Okay, we're going to move on to the
Releases and release candidates section.  So, we have a new release, it's LND
0.19.0-beta.  This is the latest major release of LND.  I made some notes here
for what the major features are.  I don't know, Alex, is there anything in this
release that you saw that excited you?  You don't work on LND, but for
interoperability or anything else, is there anything that you said, "Oh, I'm so
happy that they got that out there"?

**Alex Myers**: I'm reading the release notes now.

**Dave Harding**: Okay.  Well, then I'll go through my notes real quick.

**Alex Myers**: Okay.

**Dave Harding**: The big one for me is they added support for the RBF
cooperative closed flow, which I think is also supported by Eclair and maybe
LDK.  I'm not sure that CLN supports that one yet.  What this does is it allows
the node, who's requesting the channel be closed in a cooperative scenario, to
say, "This is how much fee I want the cooperative closed transaction to pay and
I'm willing to pay it out of my side of the channel".  And the other side is
like, "Great, you're going to pay the fee and get this channel closed.  That's
perfect for me".  So, it's a nice fee and you can actually, as the name implies,
you can use it for RBF.  So, the channel, they created a cooperative closed
transaction and it hasn't confirmed in a reasonable amount of time, the party
requesting close can say, "Okay, well, let's bump the fee.  And again, the
additional fee's coming out of my side of the channel".  So, we can use RBF for
cooperative closes, rather than having to use something like CPFP.  And CPFP
just requires more bytes onchain, which requires paying more fee overall.  So,
it's a nice feature.

Another feature they have in this new release is archiving of their channel
backups.  I don't exactly understand what's going on here.  I'm guessing it's
just tracking what backups you've made.  This is by default off, so you're not
using it by default, but if you need it, it's there.  Another feature that
excites me is they have experimental HTLC (Hash Time Locked Contract)
endorsement signaling.  This is something that ultimately we may want to use to
prevent channel jamming attacks, which are a concern that Rusty brought up, I
think, seven, eight years ago, pretty early in LN development, that we haven't
quite solved.  It hasn't yet, as far as I know, been a major problem, but it is
an outstanding concern.  HTLC endorsement is not an entire solution for it, but
it's a great mitigation.  LND is not using it directly here, they're just making
the signals and allowing it to be used for research purposes.  They're not
changing how anything is routing in this release.

**Alex Myers**: Yeah, that's a difficult one.  I can actually speak to that a
little bit.  I followed Carla and Clara's work on it, and Matt Morehouse was
also a major contributor to running some of the channel-jamming scenarios.
Yeah, that one's going to take a while to roll out, because as you say, you need
all the parties to support that endorsement bit.  But then, you can actually use
it to kind of bucket your HTLCs into endorsed and non-endorsed.  And so, the
idea is that you can start applying back pressure under a jamming scenario and
you still have some open HTLC slots available for those endorsed HTLCs that you
say, "Hey, I've got some reputation with both of these peers, so I'll give you
guys a little bit of preferential treatment at the moment".  But yeah, it's
exciting to see some progress on that.  I think it is something that we should
be devoting some resources to, but like you say, it's not really a silver
bullet.  But it's definitely a lot better than not being prepared at all for
such a scenario.  Yeah, so this is kind of the first step in supporting that.

**Dave Harding**: I think Eclair has also started doing the experimental
signaling without any routing changes or forwarding changes.  And the final
thing I called out in my notes was, they have initial support for the quiescence
protocol, which I believe every other implementation already supports.  And
that's for channel splicing, that's part of channel splicing, and it also will
help with dynamic commitments, which I know is a major hobby project of
roasbeef.  And dynamic commitments are the ability to upgrade the format of the
channel-funding transaction without closing the channel.  The quiescence
protocol, it's just one node says, "Okay, let's not add any more payments to
this channel.  Let's settle it, get it into a state where we can do an important
operation, and then un-quiescence it".  I don't think it's a word, but we try.
So, I'm really glad to see that they're doing this.  I'm hoping that they'll get
splicing support.  I think we have splicing support also in every other
implementation.  I'm not sure about LDK, but I think we have it there too.  So,
that's great.

**Alex Myers**: All I can say is I know CLN and Eclair have interoperability
now, and there were a lot of edge cases for re-establishing channels that were
just really easy to overlook, so that was kind of a long road in fleshing out
that spec there.  But kudos to Dusty for spearheading that.

**Dave Harding**: Did you see anything else in the notes that you wanted to
comment on, Alex, for

**Alex Myers**: LND?  No, I think you covered it pretty well.

**Dave Harding**: Okay.  Rodolfo, anything you want to say about LND?

**Rodolfo Novak**: Oh, dude, I am Lightning-complicated!  No,
it's awesome, things are moving.  We've been playing with phoenixd to just check
it out, and Lightning is great for clearing.  For payments, it's tricky, but I'm
loving the progress.

_Core Lightning 25.05rc1_

**Dave Harding**: Great, great.  And then, we're going to move on to, we have an
RC.  We have Core Lightning 25.05rc1.  Alex, what's going on?

**Alex Myers**: Yeah, so I thought it was going to be a small release, but we've
got a few features.  Let's see.  Rusty worked a bit on reducing the latency of
commit and revoke messages, so we got a little speed up in performance there.  I
added a couple features to reckless, which is our plugin manager.  I was
actually working on archiving a plugin that Christian Decker had written a while
ago, historian, that just archives all of the gossip traffic that it sees.  And
just continuously pushing these updates to my node to test them live, I realized
that our infrastructure was a little bit lacking there.  So, yeah, we've got an
update command that you can just run reckless update, and it will go through all
of your reckless installed plugins.  And so, long as you didn't ask for a
specific tag or commit when you installed it, it'll just update to the latest
with the same source.

Let's see.  We've got some askrene fixes.  That's still a little bit new.  So,
that's René Pickhardt's min cost flow solver, when we're doing payments and we
need to create a route.  Rusty's xpay plugin relies on that, and it's had really
good performance, as far as from my own personal experience at least, I don't
know if other users would agree as well.  But yeah, it leans heavily on askrene
internally.  So, it's nice that it is getting those kinks worked out with each
release.  Let's see. the listhtlcs API has pagination support, so that's nice
for developers.  And then Peter Neuroth has been starting work on an LSPS client
and server.  So, this is if you want to be able to offer a Just-In-Time (JIT)
channel, or something like that.  This is still in the early development, so
he's just got the transport layer worked out now.  But the idea is to be able to
support that in the future, so you can basically be your own LSP from your CLN
node.  I think that's really exciting.  So, anyone who's interested in that
should definitely look into a little bit and see what he's working on.

Let's see.  We had a feature request from, I think it was the guys at Ocean
Mining, wanted a signmessagewithkey, so that you can sign an arbitrary message
with your wallet.  That's in this release.  And then, let's see.  Yeah, we've
got the splicing updates for Eclair interoperability.  Oh, and actually, one of
the big ones is peer storage was an experimental feature.  And that lets you
back up your emergency recover or static channel backup, depending upon the
naming convention you use.  It lets you back that up with a peer.  So, there's
this message where you can basically say, "Hey, here's this blob of up to 64k of
data".  And when you initially connect to that peer, they reply with your blob.
And you can use that to validate, make sure that you have the latest state.  If
you somehow lost state, they'll actually reply to that first thing and you can
start an emergency recovery process.  So, anyhow, this was an experimental
feature for the last couple years and it's now been merged into the spec.  So,
this is now on by default.  And we were able to settle on the finer feature flag
to use there, and just polished up a few of the things for larger nodes, make
sure that it scales reasonably, and that sort of thing.  Yeah, this feature has
graduated to the big time now, so it's nice to see.  Oh, you're muted.

**Dave Harding**: Thank you.  That sounds great.  That's a very nice release.
We will cover, I think, at least one of those things a little bit more.  We had
the peer storage that was pretty late in the release process.  So, we actually
have that in our merges below.  I think peer storage is great.  It's a really
nice use of the protocol.  Do you know if there's been any work on, I think
Thomas V, I can't remember his name, from Electrum proposed a pure storage with
penalty if you didn't provide the latest state?  We covered that, I don't know,
a year-and-a-half ago in the newsletter.  I don't know, did you hear anything
about that?

**Alex Myers**: No, I haven't heard anything lately about that.  But yeah,
that's interesting as well.  I don't know, it gets kind of complicated, the
incentives.  This isn't really meant to be like an end-all and just totally
solve your backup problems, but I think for the average home node runner that
doesn't have serious funds and doesn't have hundreds of channels open, it's
definitely a nice feature to have that doesn't have a major cost to implement
it, and it provides you something.  I think if you have a serious node, you have
more backup options, you could run a Postgres database with replication, and
that sort of thing.  So, there's definitely more appropriate options for major
nodes out there.  But just for spinning up a small node with a few channels,
this should provide a fairly decent option for most people, I think.

_Bitcoin Core #32423_

**Dave Harding**: That's great.  Okay, thank you, Alex, so much for giving us
that rundown.  We really appreciate that.  We're going to move on to the Notable
code and documentation changes.  We're going to start off with Bitcoin Core
#32423.  This is a rare thing to happen.  It removes the deprecation notice for
the RPC password configuration options.  This is a way to add a plain text
username and password to your configuration file in Bitcoin Core.  It still is a
way to do that.  It's been supported since, I believe, the original RPC
implementation for Bitcoin Core, which was added sometime around the time that
Satoshi left, I believe.  And the idea there was that sticking a plain text
password in a text file on your file system is not the most secure thing to do.
So, tools were added and additional configuration added to add a hashed password
to your configuration file, a hashed username password combination.  So, you
could authenticate with that.

However, even though it's not the best security idea, it's also not the worst,
because you really want to keep your file system secure for lots of other
reasons.  And people have continued to use it and the developers are like,
"Well, we've been talking about removing this for a long time but we haven't.
People are still using it.  It's not the worst idea".  So, they decided to
remove the deprecation notice and they're just going to keep it.  So, I thought
this was really worth calling out.  The tools for using a hashed username and
password, they're still there, you can still use it.  If you're a little bit
more security conscious, you should.  But it's nice to see developers change
their mind, because sometimes that can be hard.  So, that's great.  Any comments
on that, you guys?

**Rodolfo Novak**: I mean, if I remember right, this was the one that a lot of
people's coins were being taken way back then by RPC.  Was this the one or no?
Was it the auto password?

**Dave Harding**: I don't think it's the auto password either.  I think, was
that people using the SSL authentication?  So, they were doing it over the
network.

**Rodolfo Novak**: I remember something with RPC and the password way, way, way
back then.  But anyways, I mean, yeah, it's nice to see a little improvement
there.

**Dave Harding**: Yeah, I think it's often the case that if they have local file
system access, they probably have other access to steal your coins in another
way.  So, that's why it's not the worst idea to use this.  But you could be more
secure if you want to be.

**Alex Myers**: Deprecations are hard, especially with all the downstream users.

**Rodolfo Novak**: People even keep coins on Bitcoin Core wallet, generally
speaking, it's very rare.  I mean, sure, there is some folks that are extremely
more technical than most people, but it's very hard for me to find people who
are using Core directly as their wallet too.  So, there is that.

**Alex Myers**: Got to agree with that.

_Bitcoin Core #31444_

**Dave Harding**: Okay.  Moving on to the next item, we have Bitcoin Core
#31444, and that extends a class related to cluster mempool.  I won't go into
details here, but this is one of the last major PRs, we hope, for cluster
mempool support in Bitcoin Core.  That will still be experimental for a while.
The way it's likely to go out is that it's going to be turned on by default when
it goes out, because it's not worth having the code for both cluster mempool and
non-cluster mempool in the same codebase.  But Pieter Wuille has been adding all
the function necessary for it in the background, and this is the last one of
those.  So, I suspect the developers are going to be building with the cluster
mempool, they're probably just going to have a branch, they're going to work on
it over there, and that's great.  Cluster mempool is really exciting.  The end
user, it's probably not going to change how you use Bitcoin or what you see, but
it's going to be really great for the developers because it gives them tools to
improve mempool policy in the future.

We've covered cluster mempool quite a lot in previous newsletters and previous
recap podcasts, so I won't go too much in detail here, but I am excited to see
this get closer and closer to the end line, and also at the point now that we
can start to use it in experimental settings, people could start to run, not
yet, not with this PR, but we're getting close, but people could start to run
cluster mempool nodes and compare the performance of that to a traditional node.
And when we're at parity, we can switch over to that and then start building on
the guarantees that cluster mempool gives us for mempool policy.  Any comments
on that, Rodolfo, Alex?

**Alex Myers**: Love to see some progress here.  Yeah, it's been a long time
working on cluster mempool, so yeah, I'm excited for it.  Don't have too much
else to add.

**Rodolfo Novak**: Yeah, same.

_Core Lightning #8140_

**Dave Harding**: Yeah, okay.  Great.  And now we have five PRs from CLN.  The
first one of these, Alex I think has already been talking about.  It's Core
Lightning #8140.  It enables peer storage of channel backups by default.  Alex,
you want to say anything more about it?  I know you already said a bit.

**Alex Myers**: Yeah, I guess I already talked a bit about peer storage and the
emergency recover feature.  I guess the only other thing to add is that it's
really nice when we have new features like this.  I can actually search through
all of the public node announcements and see which features are offered by the
nodes.  And so, I can use this one specifically to see how many people are
running the latest master or RC and testing that out.  So, working on this
release cycle, we try to give a couple of weeks of testing before we finalize
the release.  And sometimes, I've wondered in the past how many people -- I know
there's at least a few crazy people that run master or that want to be on the
bleeding edge and test out these latest features.  But because we have that
privacy guarantee, you can't really know for sure who all is running which
software.  Actually, now though we can, because when you set this new feature
bit and you look at it in conjunction with the other features that CLN supports,
you can actually tell, I can see that, you know, 12 people are out there running
the RC or master right now.  So, that's also like really convenient for me
personally.

**Dave Harding**: That's great, that's great.  Actually, that reminds me of an
earlier part of our conversation, we were talking about how many people use
Bitcoin Core.  And every once in a while, Bitcoin Core changes the features its
wallet uses.  So, it'll start opting into RBF, or whatnot.  And I think the last
time they did that, it was only about 6% of all transactions were created by
Bitcoin Core, which is higher than I would expect.  I suspect a lot of those are
services using Bitcoin Core.  I know like Eclair uses Bitcoin Core in the
background, other stuff like that, but still it's really impressive.

_Core Lightning #8136_

Okay, our next one here is Core Lightning #8136, and our description here says,
"Updates the exchange of announcement signatures to occur when the channel is
ready, rather than after six blocks".  And my understanding of this is the two
participants in the channel are exchanging their announcement signatures right
away now.  But you still can't announce it to random peers, your other network
participants, until six blocks.

**Alex Myers**: Exactly, yeah.  So, I think Eclair pushed for this update to the
spec.  So, this is for your channel announcement when you're ready to send it
out.  But the channel for most implementations has already been usable for
several blocks.  I think three is a common number.  You can actually configure
this yourself in your config file.  But just from a state machine level, it's
easier to reason about if we say, "Hey, this is sufficient depth for us, I'm
willing to exchange signatures".  From the protocol standpoint, you still have
to wait for the standard six blocks before you can relay the announcement.  So,
yeah, that's just a clarification there.  This particular PR, though, it was
really nice to rework our state machine, and there's like a lot more assurances
that the state transitions are all correct.  So, yeah, I think there's some
benefits to the codebase there as well.

_Core Lightning #8266_

**Dave Harding**: That's great.  Core Lightning #8266, it adds an update command
to the reckless plugin manager.  I think you've also talked a little bit about
this.  And I would just quickly add that I think that's wonderful, because once
you have more than two plugins updating them seems like a huge pain.  Do you
have anything else you want to add about that?

**Alex Myers**: No.  I'd love more people to test it out and see if there's any
edge cases that I missed, that sort of thing.  But no, it's really satisfying to
run it and just go through all those plugins, and the node works.  So, yeah,
give it a try.

**Dave Harding**: Our notes here say you also extended the install command from
reckless to take a source path or a URL.  So, people who want a plugin that's
not in the registry, I guess, can also now get it.

**Alex Myers**: Exactly, so if you have a local source, so this is the thing
that I wanted as I was tweaking this historian plugin, I've got a local copy,
and I want to test out these changes.  So, I can just reckless install and parse
the path in it.  It kind of infers the name, so you've got the directory name
for your plugin, but then you've got the entry point, which is the executable
that you're actually going to run.  So, reckless does some things to infer what
the entry point is from what's in that directory.  But yeah, it's just one more
quality-of-life feature to make it a little bit easier to test things out.

**Dave Harding**: Right, great, and I know you guys have been building CLN on a
very plugin-heavy design.  It didn't used to be the case, but maybe three or
four years ago, I guess Rusty and Christian started to really use plugins, and
now you guys are doing everything as plugins.

**Alex Myers**: Yeah, exactly.  They're really first-class citizens, and yeah,
you can really extend what's possible through the use of plugins.  So, yeah, I
don't know, I'm always excited to see new plugins.  Interestingly, one of the
ways that I've seen this feature used, reckless, and I've got a lot of feedback,
is there's a guy who's got lnplay.live.  And it's a way that you can spin up a
bunch of LN nodes on a test network or just a local network.  But you can
basically demo everything.  And he's integrated reckless so that you can use it
by RPC to install and try out new plugins and see what happens.

_Core Lightning #8021_

**Dave Harding**: Nice.  Moving on to our next item, we have Core
Lightning#8021.  It says, "Finalizes splicing interoperability with Eclair".
So, I guess this is Dusty's work, and with compatibility with Eclair, it's
eligible for spec inclusion now, I believe.  So, that's really exciting to have
years of work hopefully getting to the spec.

**Alex Myers**: Exactly.  Yeah, and it's difficult because that PR in particular
was such a moving target.  There was just a lot of things that we didn't know
were missing.  So, it'll be really nice to see that slow down and then get
merged.  So, this one also allows you to RBF a splicing transaction.  It doesn't
have a great user interface for that, but basically if you try to perform a
splice on a channel with an existing splice, it creates an RBF transaction for
the first splice, and you can just kind of chain these together.  It keeps track
of all the state on the back end, and it's got to be a little bit wild how it
does it.  But yeah, it's impressive.

**Dave Harding**: That's great.  I really like splicing.  Users are going to
love it.  I think they already love it because they're using it with Eclair now.
I think Eclair has it on by default for people who are using it.

**Alex Myers**: Exactly.  Yeah, Phoenix wallet users.

**Rodolfo Novak**: For the privacy, it really is nice.

**Dave Harding**: Yeah, the privacy is nice too, that you kind of get that same
thing we were talking about with payjoin and with dual funding.  For splice-ins,
you get the heuristics there.  And for the splice outs, I guess you can get
privacy there too because you're spending from an LN channel, and that might not
be clear from a heuristic standpoint.  I'd have to think about that harder.  But
for the splice-ins, it's very nice.  You get that same benefit.

**Rodolfo Novak**: Yeah, for the inwards, yeah.  For the out, I mean it really
depends on your trade model here.  I mean, if you're not like trying to fight
like a state actor somewhere, you're just trying to find some privacy against
vendors, or whatever, it's a huge improvement.

**Dave Harding**: That's great.  And again, glad to see it get closer to
eligibility for spec, or at the point of spec inclusion probably.  So, hopefully
the other implementations will agree that it's good to go and it will be in the
spec.  And again, we saw earlier that LND is making some progress with the
support of quiescence to get it into their implementation too.  And again, I
believe LDK has done some support work as well.

_Core Lightning #8226_

And then, our final item here, which we also have talked a little bit before,
it's Core Lightning #8226.  It implements BIP137, which is kind of a
documentation for the traditional signmessage protocol, although I think it's
got some tweaks to it over what Bitcoin Core implemented way back in 2011 for
the first time.  So, yeah, Alex, tell us about signmessagewithkey.

**Alex Myers**: Yeah, well this was just a user-requested feature, or a
downstream implementation requesting this.  I think it was, again, Ocean Mining
that would have found this useful for users to basically use a public key and
basically be able to sign messages that way.  And I think it follows the
Electrum standard, which is kind of the most widely adopted one.  But yeah,
testing this out with Sparrow, you can use this RPC and it'll validate your
signed message.  Previously, if you wanted to do the same thing, it was a long
chain of events of installing additional libraries and external RPC calls, and
everything.  So, yeah, I hope this solves some problems for people.

_LND #9801_

**Dave Harding**: Yeah, that's great.  And our final PR is from LND, this is
#9801.  This adds a new default option.  It's --no-disconnect-on-pong-failure.
So, LN nodes can send, and I think the recommendation's every 30 seconds, a ping
between themselves, just to make sure the other peer is still connected, because
you don't want to start trying to send forward a payment to a disconnected node.
And the reason for that is once you try sending that payment, you kind of have
to assume the other person received it, even if they don't confirm that they
received it.  Once you send it out there, you have to act like that happened and
you might have to force close.  So, if they go offline, well, nothing is
happening.  You can just let them sit offline for a long time.  If you don't
have any pending payments, you don't care.  It's just a matter of eventually,
you might want your money back to open a new channel.  But if there are pending
payments, you might be forced to force close a channel within a relatively short
amount of time.  And so, you don't want to send a payment to somebody that you
know is offline, because again you're going to have to assume that it went
through.  Because if they did see it, they could steal money from you if you
don't make that assumption.

So, again, LN, the nodes, they send ping messages and they reply with pong
messages.  And this is LND adding an option that says they're not going to
disconnect the peer if they receive a late pong message, or if it is somehow
corrupted.  And the justification of this in the PR is that we're just having
some people with problems with this.  They say that sometimes the TCP channel
gets backed up or something.  I don't know.  And so, they've added this option
for people who don't want to disconnect their peer.  And I guess you're going to
see that some LND nodes have thousands of channels, and I can see how that could
be a problem.  If you have a brief delay in your connection and you disconnect a
thousand channels, reconnecting them could be a major pain.  So, I'm guessing
that's what this is here for.

I don't think it worries about the safety guarantees, this is not going to
change the safety guarantees in the sense that if you do send a message to a
disconnected channel and you didn't know it was disconnected, you're just going
to have to force close that channel later on.  So, there's a bit of a trade-off
here.  But if you're an LND node, you can run this option.  It's not going to
change your safety guarantees, it just might change the number of force closures
you have.  And it's probably something that they'll just default off.  They're
going to test in practice.  So, I think it's good.  Any comments, Alex?

**Alex Myers**: Yeah, I think the vast majority of users won't really need to be
concerned with this setting.  But it's one of those that if you need it, you
probably really do need it.  So, it's nice to have it available.  It's also
probably nice, we've got a number of features that I kind of don't know how much
use they get in the real world, but for our black-box CI testing, some of them
are really useful to have in trying to recreate problematic scenarios and just
trying to debug.  So, it's one of those that I like to see that sort of
configuration option available.

**Dave Harding**: Yeah, and that brings us to the end of the newsletter.  Any
final comments Rodolfo, Alex?

**Rodolfo Novak**: Not really, man.  It's fun.  Learned a lot about Lightning,
new stuff that I haven't heard in a while.  You can find me on the
bitcoin.review pod and the stuff we make.

**Alex Myers**: Yeah, I mean it's nice to see people building things.  I don't
think the pace has slowed down by the length of the newsletter.  So, yeah,
thanks for letting me review it with you.

**Dave Harding**: Thank you.  Thank you both for joining me, I learned a lot
too.  So, have a great day and to our audience, you all have a great day too.

**Alex Myers**: All right, cheers.

{% include references.md %}
