---
title: 'Bitcoin Optech Newsletter #430 Recap Podcast'
permalink: /en/podcast/2026/11/10/
reference: /en/newsletters/2026/11/06/
name: 2026-11-10-recap
slug: 2026-11-10-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
0xB10C, Luke Carriere, and Sjors Provoost to discuss [Newsletter #430]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-10-10/436428610-44100-2-b5d8a1b218034.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #430.  This
week, we're going to talk about some updates to TCP hole punching, the idea we
discussed a while back; there's a draft BIP for standardizing what co-signers
enforce when they emulate covenants; we have a prototype for opt-in replay
protection; and then we also have a slew of other Changing consensus monthly
segments, including BIP54, three quantum-related proposals, and a sidechain
discussion; and then, we have our weekly Releases and Notable code segments.
This week, Murch, Gustavo and I are joined by a couple of guests.  We'll have
them introduce themselves. 0xB10C?

**0xB10C**: Hi, I'm 0xB10C.  I mostly do Bitcoin Network monitoring, and
through this, also dived into TCP hole punching, and maybe we can improve how
we make connections on the Bitcoin Network, especially for home nodes.

**Mike Schmidt**: Awesome.  Sjors, you're muted.

**Sjors Provoost**: Sorry, I'm Sjors, I work on Bitcoin Core, mostly on either
Stratum v2 or trying to help MuSig2 move forward, but occasionally I get
distracted, such as by today's topic.

_Continued discussion of TCP hole punching for home nodes_

**Mike Schmidt**: Awesome.  Thank you both for joining.  We'll go a little bit
out of order for our guests, but you all can follow along, you're used to this
drill.  "Continued discussion of TCP hole punching for home nodes".  0xB10C,
this is your item.  You're back.  I think we had you on in #406 when you first
floated this idea, or at least articulated this idea that you and others were
hashing out.  Maybe, 0xB10C, you can give a quick refresher of what the
general idea is, where we left off, and then why it's worth revisiting this
idea, and some of the new ideas that piggybacked along with it?

**0xB10C**: Yeah.  So, the current Bitcoin P2P Network, how nodes are
connected, is mostly split into two separate things.  There are servers that
run in the cloud, maybe Hetzner or DigitalOcean or Google Cloud or AWS, or
similar, and these are able to accept inbound connections on their side, and
then there are others in these clouds that connect to them.  So, they form
quite a well-connected network graph.  And then, a couple of people, or many
people, run nodes at home.  And usually at home, you have a router that
includes a firewall and a NAT table.  So, these nodes make outbound
connections to these cloud nodes, but they cannot necessarily accept inbound
connections.  A while back in Bitcoin Core there was a change making NAT-PMP,
which is a way of telling the router, "Hey, open this port for my Bitcoin node
I run at home so I can actually receive inbound connections", so we made this
default in Bitcoin Core v30.  We looked into it a bit and I don't think it
made a big difference in the number of reachable nodes.  I don't know the
exact details why it did not, and maybe this also changed.

But at the time, looking into this, the idea came up, okay, maybe we can do
entirely different things, and one of these things is hole punching.  In hole
punching, you have some coordinator, or some coordination in between, and at
the same time, you open a simultaneous TCP channel, and through this channel,
both the firewalls and routers allow the connection.  So, you punch through
the firewall and the NAT there.  We tested this a bit, and we could use this
for Bitcoin.  There's a big design space to do this.  You need two kinds of
information to do this hole punching.  You need to have the address of the
other side, and the other side also needs to have your address, and you need
to have timing information.  You need to do it roughly at the same second, or
the same ten seconds or so; there is some room there.

We explored a few things, just in discussing this at CoreDev with a few
people; we explored a few things and thought about a few things, where you
either have a coordinator in between, and who is going to be the coordinator
and who chooses the coordinator is part of the design there.  You don't
necessarily want to have a coordinator that connects you to some attacker, or
maybe the coordinator is the attacker, so you want to be careful there.
There's also the option that maybe you actually don't trust any third-party
coordinator, but you run your own little Tor hidden service.  Maybe you're
already running a Tor hidden service for your node to receive inbound
connections to, but you're also running one for coordinating hole punch
connections.  That could be an option.  And then, there's also a bit of
discussion about maybe we hand off connections, or run a matchmaking pool.
And then, there's also a way of maybe saying, okay, maybe we can do this
without a coordinator.  We can send out addresses through the network, and if
both nodes see these addresses, they decide on making a connection at a
certain time point.

I'm not going into the detail here.  There's a bunch of discussion on Delving.
So, I think this is the fun part, thinking about what design spaces there are,
how any DoS mitigations work, how we can stop someone from spamming fake hole
punch addresses, for example, how we can stop this.  It's very easy to get
nerd sniped there, and I think we got a few people nerd sniped for a few days.
But I think we should first think about the question, like I'm pretty sure we
can do it, but we should first think about the question, 'should' we do it?
This is also the question I raised on Delving.  Anthony Towns, AJ, at least on
Delving, has been on the side of okay, maybe there are reasons not to do it.
I think one of the biggest points he put out is that there are these firewalls
and NATs for a reason on home routers.  Maybe accepting inbound connections on
a home node is not great at all, because there might be ways for attackers now
to reach home nodes which they previously could not reach.  There recently
have been a few TCP-related vulnerabilities disclosed for Bitcoin Core, so
maybe some of these could have been exploited.

I think the discussion there is interesting.  It covers a bit more thinking
about okay, we can do something that could improve things, so maybe it
improves interconnectivity between home nodes, because currently you have to
go through a cloud node.  But on the other side, maybe it allows an attacker
to mess with your node, to attack your home node, and we definitely don't want
to introduce a vector of attackers getting into people's home networks just
through hole punching or similar.

**Mark Erhardt**: All right.  Allow an inbound connection for once, please.  I
wanted to jump back a little bit.  I'm not sure that all of our listeners are
actually aware of what problem we're solving.  So, I wanted to talk a little
more about the general problem.  You did mention early on that some nodes are
reachable and other nodes are not reachable, but the unreachable nodes, nodes
that are behind firewalls, they usually only have eight full outbound
connections and two blocks-only connections.  So, the goal here is to allow
them to have more connections with other nodes by facilitating some way of
having a pseudo-outbound connection that's an inbound connection, so the node
can always go out from their firewall into the internet and make a connection,
but they don't accept inbound connections.

So, you said the original idea was to have some sort of coordinator.  The new
idea is to have a coordinator-less approach, where I think the first one was
to advertise your IP address plus a public key.  And then, the other
participant that is also trying to hole punch would use that public key with
its own to make an Elliptic Curve Diffie-Hellman (ECDH) shared secret, and
that way find the actual connection, and they'd just both start at the same
time to punch out from their firewalls, and by having the same shared secret,
they would be able to make a connection with each other.  My understanding was
that the problem is that the unreachable nodes hear about these sort of
address propagations much less, because they have a smaller footprint in the
network anyway.  The message goes out on fewer P2P connections and then
propagates, especially to unreachable nodes, non-listening nodes less likely.

**0xB10C**: Yeah, just to jump in there, this is how it currently is, if we
use the current mechanism for relaying these.  But obviously, when designing
something you have some kind of freedom, because you need to introduce maybe a
new addr v2 kind for these anyway.  So, you would have the freedom to say,
okay, maybe we propagate these slightly differently than the current ones.

**Mark Erhardt**: Right.

**Sjors Provoost**: Maybe another step back is to point out that, unlike the
PCP protocol and the UPnP protocol and the NAT-PMP protocol that we are using,
this is a completely invented hack, right?  Is there any other software that's
doing this?  Because we're just abusing or using, leveraging, whatever word
you want to use, the fact that routers, when you open a connection to somebody
else on the internet, very briefly make a window for a return message.  It's
kind of like you're leaving your door open, but with a secret code or
something, for a few seconds.  And we're trying to use that because the
routers are not supporting the proper way to open them.

**0xB10C**: Yes.  But I think that's a part of the TCP spec.  There is a
section on TCP simultaneous open for it.  It's used mostly in UDP.  It's just
that the Bitcoin P2P Network doesn't run on UDP, it runs on TCP, so we're
using it in TCP.  There are far fewer users on TCP, but there are a lot of
users on UDP.  For example, all your Signal voice calls do this.  There are a
lot of, I think, computer gaming applications, a lot of other video streaming
things, all of these.  The actual party that facilitates them is just
coordinating them, and if the coordination works, then they don't have to
relay your traffic, which is a lot more efficient for them, with a lot lower
traffic cost from them.

**Sjors Provoost**: So, the only new part is using it on TCP then, and
coordinating it differently.

**0xB10C**: Yes, there are people doing it on TCP, but just not as much as
UDP.  So, yes, it's a hack, sure, but I think it's not something we would
expect to break at some point, or to be only available for 1% or so of
routers.  We tested a bunch of routers and we saw it would work for, I think,
roughly half of the routers we tested.  Obviously, that might be a bit biased
because we're tech people and we might have different router models or live in
countries where this is more available than in other countries.

**Sjors Provoost**: Well, if it's used by gaming, I would expect a lot of
routers to support it, because a lot of people game.

**0xB10C**: Maybe some are supported better for UDP than TCP.  This part
definitely needs some testing as well.  I think before that, having a clear,
"Should we do this?", and, "If we do this, what is the best approach to doing
this?" should also be answered.

**Mark Erhardt**: Yeah.  So, maybe back to that message board idea.  You said
that instead of having a coordinator, or having the timing-based coordination,
where people propagate a new address format, could you get a little more into
the message board idea?  So, nodes would collect all of the people that want
to hole punch and make them available to -- how would that work?

**0xB10C**: So, what the message board idea is solving is, for an attacker
currently, and that's a problem in address relay all the time -- so maybe
stepping back.  For blocks, relaying blocks, they have proof of work.  We can
relay them quite quickly because we know there is a cost associated with this.
And for transactions, there is also a fee people have to pay, so there's also
a cost associated with it.  But for address relay the problem is that
essentially, everybody can spin up something that generates addresses and
announces them to the network, and at the moment we don't have a way of
efficiently checking whether this address is actually reachable, and obviously
it could be reachable; there could be an attacker behind it telling us yes,
this is reachable.

The problem with an earlier design of this was that an attacker could send out
fake announcements of "I want to hole punch on this IP address", and we would
try to hole punch there, but all of our hole punches would fail.  I don't
think there is a big advantage in adding something new to the Bitcoin protocol
or to Bitcoin Core where it's easily DoSable.  So, what the message board idea
is solving is that you actually have to control the IP address, and connect
from this IP address you want to make the hole punch from to a board, and
register yourself on the board.  There the cost is, "Okay, I actually have to
control the IP address I want to make the announcement from".  So, we have
some way of introducing a slight DoS protection against hole punching
connections.

**Mark Erhardt**: So, you would connect directly to the message board, and
that way your IP address is basically verified, because the message board can
see where the message is coming from and match it against the post on the
message board.  And then, we already have multiple people connecting to the
same message board.  Wouldn't that then also be able to function as a
coordinator?  Why make it a message board and not just coordinate, if people
are connecting to the same one?

**0xB10C**: Yeah, I think that's a great question, because in a very early
design, just using a coordinator, one of the downsides is that if someone
decides who you connect to, they also learn who is connected.  By using a
message board, you see other people on the message board you see their public
keys, you derive a shared secret from it, and the board knows there are these
sets of people, and maybe they connect or maybe they don't connect, and the
board doesn't know.  The board doesn't choose who connects and it doesn't see
who connects, compared to the coordinator who learns that these people are at
this point probably trying a connection.  It does not know if the connection
actually ends up happening.  So, there is some privacy aspect in there as
well.

**Mark Erhardt**: Right, okay.  So, the message board has the advantage that
it does not learn which attempts are being made.  But how would the message
board participants know when to connect?  You said it has to be within ten
seconds of each other that both sides attempt?

**0xB10C**: Yes.  So, there's another thing we use.  In Bitcoin, there is some
kind of clock going on, and that's that blocks are found on average roughly
every ten minutes.  And from maybe the block timestamp or the blockhash, or
something in the block, we could derive a timestamp along with our shared
secret on when to connect.  This is an approach that is also useful in
deciding who to connect to, because if I publish something and say, "Okay,
I've seen this public key", before the next block arrived, and I derive from
the next block and the public key I learned before this block arrived, a time
when and who to connect to, nobody can grind something that matches my public
key.

**Mark Erhardt**: Right.  I think the idea was to use the shared secret as a
decider for which connections you attempt.  You would use the lowest few
shared secrets.  But that would of course enable other message board
participants to explicitly grind against already known participants on the
message board before connecting with another connection, and then force
connections with specific peers.  So, it could be used to target specific
message board participants.  By hashing the block into it, you randomize it at
the time that people are trying to make the connection.  So, basically,
whenever these non-listening nodes receive a new block, they know, "Oh, now is
the time I connect to the three nodes that I have the lowest hash or shared
secret with".  All the shared secrets can be derived previously, they get
tweaked with the block, then you sort them and you make your three
connections, or five connections.  The hope is that the other people have a
similar list, and the shared secrets obviously are the same on each side of a
potential P2P connection, so other people that get a low hash or low secret on
a P2P have a good chance to try the same connection, and you might end up with
a couple of new peers out of five attempts.

**0xB10C**: Yeah.  That's the general idea.  I'm not sure that's the best we
can do.  I think the bigger question is not, how do we do it; I think we can
definitely explore a few design approaches there.  It's way more, should we do
it?  Because this is definitely coming with some complexity, and I think it's
definitely worthwhile to think about whether we should actually do this before
attempting to implement anything, or before writing a finalized spec, and
thinking about the protocol a lot more.  And there, I'm currently undecided.
I definitely agree with AJ's point, but there's also, I think, value in
offering this for people who just can't control their routers, or open this on
their routers, or maybe just don't know how to open this on their routers.
Recently someone mentioned to me they were using BitTorrent and they were so
amazed at how easy that works, and they were able to seed a Linux ISO to other
people just from their laptop without touching their router at all.  And this
is also using hole punching.

So, having this working out of the box on a Bitcoin node, and giving
non-technical users, telling them, "Okay, just run this, and it's going to
offer inbound slots to the network", which are a scarce resource, is probably
a nice way of doing it.  But again, should we do it?  I don't know yet.

**Mark Erhardt**: Right.  So, obviously a lot of people are using Tor
connections already to get around firewalls, because Tor connects to the onion
router and thereby already bypasses the firewall.  But Tor connections are
often limited in bandwidth or have higher latency, because they have multiple
hops in between.  So, the advantage here would be to have clearnet
connections, even though your firewall would usually not allow them, which
might have better throughput, lower latency, and be maybe more diverse than
what we get on the Tor Network.

**0xB10C**: Yeah, that's one thing we discussed.  It's like an upgrade for Tor
connections, a latency and bandwidth upgrade for Tor connections.  Just one
last thing.  There's also a different option, where we just give users or
applications an RPC that they can then coordinate over, like Signal voice
calls, Nostr, however they like, to say, "Okay, I'm doing a hole punch with
this other participant I know, or don't know, or I trust, and I'm doing the
hole punch now by pressing Enter on my RPC command line".  If both do this at
the same time with the IP addresses exchanged manually, that could also be
useful.  But again, there is a lot of design space here.  It's fun to think
about it.  I'm currently not sure.

**Mark Erhardt**: That does sound fun and useful to make connections to your
actual friends.  But it's also a bit of a privacy leak to your friends,
obviously.  But yeah, so for making regular connections or additional connect
connections… sorry, no, it's addnode; connect is the one that is exclusive.
But just working out of the box and making a few more hole punch connections,
maybe ten more or so for non-listening nodes, that would be pretty cool.  So,
what would you expect the impact to be of this?  You said that you were a
little disappointed with the outcome from NAT-PMP.  Is this lemon worth the
squeeze?

**0xB10C**: Yeah, I don't know.  I think in some way it's bringing the P2P
back.  It's really P2P.  It's not going through a cloud hoster to another
peer, which it's not fully that.  There are reasonable nodes on home ISPs as
well.  But I think it's bringing back a few things that someone coming to
Bitcoin and thinking about a classic P2P network, where everybody is connected
or can connect to everybody, more like a full mesh network, I think this would
move it slightly more in the direction of a full mesh network, and away from
more like a hub network we have currently.

**Mark Erhardt**: Maybe one last question and then maybe we should wrap up.  I
think that the listening nodes make up the backbone of the Bitcoin Network
right now, and we have pretty good numbers on those.  They're about, what is
it, 10,000, 15,000 of those.  How many nodes do we expect to be non-listening,
and would something like a message board even scale to that?

**0xB10C**: So, I think there's a rough number of maybe 30,000 or 40,000
non-listening nodes, last I heard.  It's always a bit of a challenge to
estimate this or get reliable numbers, but I think this is a good number.  And
the idea for the message board would be that there are definitely multiple
message boards, or maybe even each reachable node could be a message board.
It obviously needs to be very DoS-resistant and shouldn't interfere with the
working of the nodes at all.  But having very limited traffic over these
message board connections could be a way of having each reachable node
actually act as a message board.  And then, once all of the hole punch
connections are filled, we don't need to maintain a connection to a message
board anymore at all.

**Mark Erhardt**: Right.  I mean, listening nodes currently have a 125 peers.
10 of them are their own outbounds, or 12.  And then, the remaining 110, or
so, are inbound connections.  Now, obviously some of those are light clients,
but the other are full nodes, so a long-lasting node on the network, might
have some 40, 50 inbound peers anyway.  So, there might be a couple of dozen
that would be interested in hole punching.

**Mike Schmidt**: Well, as you both mentioned, it's a big design space and the
Delving thread reflects that.  If listeners are curious about the details,
they can jump in there and also participate and provide feedback or additional
ideas on the design and the benefits thereof.  0xB10C, anything else before we
wrap this item?

**0xB10C**: Yeah, if listeners are interested in this, and especially for me
the question is still, "Should we do this?  What are your points for this or
your points against this?"  Feel free to comment there.  Yeah, thank you for
having me.

**Mike Schmidt**: Thanks for your time, 0xB10C.  Cheers.  Well, we have Luke
who's joined us to talk about the next item, but Luke didn't get a chance to
introduce himself for the audience.  So, before I intro that item, we'll have
Luke say a few words about who he is and what he's working on.  Hey, Luke.

**Luke Carriere**: Hi, thanks for having me, I really appreciate it.  I've
been involved in Bitcoin since 2014.  I earned a Master of Science in digital
currencies from the University of Nicosia from 2017 to 2019.  I got to study
under Andreas Antonopoulos there, who was one of the teachers.  I did brief
stints at companies like IOV Labs down in Argentina and Blue Orion, which was
a little startup that I tried to co-found with someone I met on AngelList.  It
really went nowhere, but we did some work involving Stellar.  But lately, I've
been doing open-source Bitcoin projects.  So, at my web domain,
lukecarriere.com, I've got several, including BitBuyback, which pulls public
company data and compares it to their stock by repurchases.

**Mark Erhardt**: Luke, could you please focus on the things that are more
towards our topic?

_BIP draft for standardized co-signer spending policies_

**Luke Carriere**: Yeah, sorry, I'm going down tangents.  But yeah, so all of
this thinking about Bitcoin and credit led me to, why don't I make a flash
credit product for Bitcoin?  Well, the why not is because I would become the
next Celsius and I would crash.  And so, what I discovered through thinking
about this is that there are seven pillars needed for Bitcoin credit to be a
completely open protocol, just like Bitcoin is money.  It could be
open-protocol money and it could be open-protocol credit.  There are seven
things needed for that to exist, and six of them already exist.  The only
thing missing is the one that I'm proposing in this BIP, which is a co-signer
policy that is protocolized.  And of course, there are challenges.  How do you
become a protocol without becoming just yet another standard?  The truth is
everyone's doing their own currently, and if they could all agree on some
interoperability, then it would free up the space a lot.

**Mike Schmidt**: Maybe, Luke, we can frame it for our audience a bit.  First
of all, we're on the item, "BIP draft for standardized co-signer spending
policies".  But how would you define a co-signer, Luke?  And then we can talk
about the spending policies, and then we can get into the standardization
piece that you're talking about.

**Luke Carriere**: Sure.  Okay, so a co-signer, and I'm going to refer to my
notes here because I'm in over my skis.  I've never developed Bitcoin
protocols before, but this wouldn't change Bitcoin at all.  It's just an
agreement of how a policy works on top of Bitcoin.  So, the coins sit in
taproot with several ways to spend them, and each way needs participant keys.
A co-signer group's signature is a condition that's enforced.  But the taproot
script enforces, everything that can be enforced in script is enforced in
script, so it would only be something that can't be enforced in script that
you would require a co-signer for.

**Mark Erhardt**: Yeah, so for example, some services provide 2-of-3 multisig
services, where one key is held by the user, one key is held by the company,
and a third key is held by a recovery service.  And the company would, for
example, allow the user to set up no more than this amount per day, or funds
have to have at least 20 confirmations before they can be spent, or whatever,
things like that.  And the service that provides the additional signature
obviously runs on a different stack.  So, if the user were breached and their
keys got taken or controlled by an attacker, the attacker might not be aware
of what policies the user is subject to, and they might struggle with pulling
out the funds, because the co-signer enforces additional limitations on the
flow of money.  Just as an example of what a co-signer could do.

**Luke Carriere**: Yes, thank you.  My examples are pretty laser focused on
the lending example and if this were able to be used for lending.  But yes, in
general, my co-signer policies basically lay out when a co-signer can co-sign,
under what conditions, and it makes it portable across these different lending
stacks.  Currently, if you were to take out a Bitcoin loan with Coinbase or
with Ledn, they're not interoperable, right?  But if they spoke the same
language and were interoperable, then you could, say, refinance a Coinbase
loan with Ledn, or vice versa, and it would be possible without moving the
Bitcoin, without changing custody of it.  It would be interoperable.

**Mike Schmidt**: Okay, yeah, that makes sense.  I think the earliest example
I can remember of this was the Green wallet.  That was a wallet where I think
you could set up something that was either 2-of-3 or 2-of-2 with a fallback,
where the second signer was actually doing 2FA on your behalf.  So, it would
actually maybe do one of those short codes in your text message, and if you
were able to provide that, it would do the signature, right?  Obviously
there's a huge design space here.  Luke, you're mentioning the lending space,
but I think you could emulate things like covenants as well, where payments
out of this can only go to certain addresses, or other restrictions as well.
You mentioned a lot of folks are doing things like this already.  How has the
reception been to the idea?  Have you been able to get in contact or gotten
comments on the idea for this?

**Luke Carriere**: Yeah, so no one's really trying to make it interoperable.
Every lender is doing their own policy and creating their own standard and
using it only in their silo.  And so, I guess I did research what has been
done along these lines that's similar, and my post mentions them.  I'm in the
process of reaching out to them to solicit their comments directly, to see if
they have any thoughts on this and how it differs from what their work has
been.  I've gotten two comments on the public post and they've both made valid
points, and I've adjusted, and I'm continuing to use AI to poke holes and find
missing pieces and gaps that are out of the scope of what I've posted so far.
I want to continue posting and maybe talking to the couple of commenters that
I have, and building in public and showing a public record of what the
intention of this is, what the hope of it is, and then any dialogue, and as I
get more feedback, incorporate it.  Like the previous guest said, I want to
know, you know, I believe it's something that there is a need for.  And since
there are all these other applications for co-signers besides my use case, I'd
like to generalize it and make it so that it works for all of these people as
a true protocol, and not just satisfying my one narrow scope.

**Mark Erhardt**: One thing that I can think of that this would also apply to
is escrows, which would really benefit from standardization.  They're used,
for example, in P2P markets, and being able to express exactly how an escrow
is supposed to behave would be valuable there.  There are custodians or wallet
service providers that use multisig and co-sign for their customers.  So, for
example, there's Cash App's Bitkey that is based on 2-of-3 multisig; Unchained
BitGo; and for an escrow example, the Bisq marketplace.  So, there are a few
other places where this sort of formal expression of a co-signer's duties
would be super-interesting.  I think from the idea, that sounds like a good
gist.  What I was wondering, I saw your design principles that you mentioned
in your draft, and I was wondering if you could tell us why there always has
to be at least one path that needs no co-signers, and what you're thinking
there; stuck out to me?

**Luke Carriere**: Yeah, so I guess that comes from my use case of viewing it
like a loan.  If the Bitcoin were collateral, think of other things where you
have a house as collateral or a car as collateral for a loan.  You control
that asset until, if and when, you forfeit it in lieu of the defaulted loan,
or whatever.  I don't want to enter into this world where you feel like you've
lost custody, where you feel like you're no longer in control, where someone
could collateralize and get your asset out of your hands and rehypothecate it,
right?  So, I felt like including that it is always yours, if and when until
you violate the terms, and then it would be repossessed under a proper escrow
or system that is then able to confiscate it; but until then, it would be
entirely yours to control.  Maybe that's something that is a backdoor into
someone abusing it or something, but I felt like that was a use case where you
want to feel like it's yours until the conditions are satisfied that it's not
yours.

**Mike Schmidt**: Well, similar to our last item, it sounds like this is also
a somewhat big design space.  Maybe if listeners are interested, Luke, we
could encourage them to comment on your Delving thread or reach out to you and
provide feedback.  That seems like the call to action here.  Anything else
before we wrap up, Luke?

**Luke Carriere**: No, I appreciate it.  That's exactly the ask.  Please
criticize it, poke holes in it.  If there are participants of these wallets
who use some form of escrow or multisig, please tell me what would help you
want to use it or not, what would be unattractive to using it.  I don't want
to just propose yet another standard that then makes 13 proprietary standards
instead of a dozen.  I want one that unifies them, that everyone wants to
participate in, and that will make the interoperability even more useful for
all.  So, yes, I welcome comments and criticism.  I'm going to keep posting on
the Delving thread and cross-posting to the Bitcoin mailing list so that you
can see my thought process, so that it's built in the open, and we can create
more dialogue on it.

**Mike Schmidt**: Excellent.  Luke, thanks for your time.  We appreciate it.

**Luke Carriere**: Thank you very much.

_Opt-in replay protection prototype_

**Mike Schmidt**: Cheers.  We're going to jump to the Changing consensus
segment.  We have an item titled, "Opt-in replay protection prototype".  On
the show, I think it was back in #420, we had Moonsettler on to talk about
replay protection, and Sjors is doing something similar here.  Maybe, Sjors,
just a quick recap, what is replay protection and why do we care?  And then,
if you saw or heard Moonsettler talking about this previously, maybe we can
talk about how your idea is related to that or not.

**Sjors Provoost**: Well, the relation is very simple.  I was listening to the
Optech Newsletter, and as he was describing it, you guys were discussing it,
and I had an idea of how to do it differently, which I then deployed Claude to
do.  But let's zoom out a little bit.  Back in 2016 or so, I think replay
issues first became visible when Ethereum split into Ethereum Classic and the
Ethereum where the DAO hackers' coins were frozen.  And quite quickly, I think
Coinbase or another exchange lost a small amount, maybe a couple of million,
because they were sending out the transactions for both sides of the fork at
the same time accidentally.  Well, they were only trying to pay people their
ETH or their ETH Classic.  About a year later, Bitcoin had a bunch of
discussions about segwit2x and Bitcoin Cash, basically one potential and one
actual hard fork.  There, people already knew this is going to be a problem,
how do we prevent people who want to claim one side of the fork to
accidentally burn the other side of the fork?

On the Ethereum side, they very quickly came up with a way to change some
magical bytes in the hash so that one side would not be compatible with the
other side, and they just always do that with a fork.  For segwit2x, I think
something similar was discussed on the forking side.  But you immediately got
this political debate of, "Well, we don't think it's a fork, we think it's an
upgrade, therefore we kind of don't want to acknowledge that there is such a
thing as the other side of the fork.  And if we added replay protection, we
would be acknowledging this other side of the fork", so you kind of want to
prevent that.

**Mark Erhardt**: Yeah, especially because the mechanisms that were discussed
at that time, how to introduce replay protection, were all changes in the
message format that potentially required everybody to upgrade their software
to make transactions.  So, essentially a hard fork for transaction sending.

**Sjors Provoost**: Yeah.  So then, if somebody is doing a hard fork, and they
say, "We don't think we're a hard fork", or, "We know we're a hard fork but we
feel like we're an upgrade", they don't want to do it, even though they could.
And then, the side that doesn't want the hard fork is not going to do a hard
fork just to add replay protection, because the whole reason it didn't want a
hard fork is because it didn't want a hard fork.

**Mark Erhardt**: They just want to stick to the regular rules, so all the
nodes that are currently running on their network stay with them.  And if they
had to update the rules, they would basically be splitting their own momentum
for just the status quo.

**Sjors Provoost**: Now, the taproot annex actually adds an opportunity to
introduce replay protection on Bitcoin pre-emptively.  So, before there's any
kind of contentious fork, have it there, so then when there is a fork, it's
there and you don't have to debate which side has to implement it.  I've never
really understood the annex, so this was a nice opportunity to play with that.
I literally just told Claude, "Hey, I think we should do it this and this and
this way", and then kind of saw what it came up with and looked at the code
and understood what's going on.  If I understand the annex correctly, the idea
is currently, it's an extra part of the witness that we ignore.  So, it
doesn't matter what you put there, it's always valid.  It's basically just
skipped.

**Mark Erhardt**: I think it is consensus-valid.  It is considered a potential
upgrade hook for future use, but it is non-standard to put anything there
right now.  So, if you make a transaction that has data in the annex, most
nodes will not relay such transactions on the network, but they will accept
them in blocks.

**Sjors Provoost**: Okay, so there's the typical thing where something is
non-standard because it is an upgrade hook, so that you don't accidentally use
it.  Okay, so the idea there is basically a variant of Moonsettler's idea,
where we have a new rule that says if the first byte of the annex is, I guess,
1, and it's followed by 4 bytes, then those 4 bytes represent a block height.
And so, we don't actually put a block in there, we reference an existing block
height.  So, if you have a fork that's more than, say, 100 blocks deep, you
reference a block a 100 blocks ago that's only on your side.  And then, the
signature over the transaction includes the blockhash.  Typically, the way you
make a signature is you take all the fields inside a transaction and you treat
certain fields in a special way, but you basically write them all down, and
then you hash that and you sign the hash.  But there's really no limit to what
you can add to the things that you're hashing.  Go ahead, Murch.

**Mark Erhardt**: Could you maybe specify further what 'includes the hash'
means?  So, we would want signatures to remain valid for un-upgraded nodes in
order to make it a soft fork.  Are you talking about a tweak?

**Sjors Provoost**: Okay, so no, we're talking about a new version of
tapscript, I think specifically; no, I think it's a new version of taproot,
right?  This is not usable as a standalone soft fork, the way I've proposed.
It has to be part of, or it should be part of another soft fork that needs a
new taproot version, because for segwit v2, the next taproot version, there
are no rules, anything is valid, there's no constraint on how a signature is
made.  So, we make this new version that says, "Okay, now consider the annex,
and if it has a height in it, consider that the block has been added to the
signature".

**Mark Erhardt**: Okay, so basically you would change the transaction
commitment or signature hash, how it is composed, what a signature directly
commits to, and add the blockhash from the height that the annex committed to.
And thereby, the signature would be different than for previous versions.  Old
nodes would allow that because they're currently not encumbering new versions
at all, so everything is valid.  New nodes that are upgraded would see the
annex, interpret the annex as a commitment to the previous block, and look for
the hash being signed.

**Sjors Provoost**: Yeah.  And if you don't need replay protection, nothing
changes, the signature is exactly the same as it is under the current taproot
rules.  If you do need it, you've got this extra annex.  And then, beyond the
replay protection thing in the annex, the annex itself works as before, so you
can still add arbitrary other stuff and we can use it in the future.  The nice
thing about this is that because the hash is not actually in your signature,
if somebody wanted to do a hard fork and get rid of this mechanism, it would
get pretty ugly for them, because the hashes are not included.  So, the only
way you know the hashes is if you follow the other chain, or you remove the
whole mechanism somehow, but that's a very big breaking change.

**Mark Erhardt**: Right, but removing the mechanism would mean presumably that
the signature is created differently than the standard signature.

**Sjors Provoost**: Removing the mechanism might itself be replay protection,
yeah.

**Mark Erhardt**: Yeah, exactly, because the signature wouldn't be valid per
the old rules.  It would only be valid in the context of the annex commitment
to a specific block height.  That's interesting.

**Sjors Provoost**: And it's very small, right?  I think I calculated it
counts as less than 2 vbytes, because the annex is already discounted.

**Mark Erhardt**: Right, 4 bytes for the height, 1 byte for the annex, a
length byte is 6 weight units.  I don't know if there's anything that you need
to show for the annex to exist.  But yeah, I think 6 weight units.

**Sjors Provoost**: I came up with 1.75, but yeah.

**Mark Erhardt**: Oh, 7 then, okay, sure.  But that's pretty small.  So,
basically, when there would be some sort of split coming up in the network, as
for example we saw recently when the BIP110 people left Bitcoin, we would be
able to, just after 100 blocks into one side of the fork, start using this
replay protection mechanism, with less than 2 vbytes, to commit to a specific
predecessor that is only on one of the two chain tips, and thereby immediately
have replay protection.  Our transactions would become non-replayable on the
other chain, which would make it easier to split funds and move funds safely
only on one side.

**Sjors Provoost**: Yeah, and it should be safe against reorgs too, because if
there is some sort of very deep reorg, then the hash no longer exists that
you're committing to, so it can't replay either.  So, I think it should be
pretty nice.  My thinking is that this should probably piggyback on something
that actually needs a new taproot version, such as some of the quantum
schemes.  Its first use case might be the inevitable debate about whether or
not people want to freeze Satoshi's coins, because I don't think there's going
to be agreement on that on technical grounds.  So, maybe that's an inevitable
split, and then we might as well handle it elegantly.  Of course, maybe it
never happens.

**Mark Erhardt**: Although there are some interesting new game-theoretic
approaches that we're learning about with the landmines proposal that just
floated through the mailing list.  I'm sure we'll report on that in some
future episode.

**Sjors Provoost**: And there's also just all these random forks, right, where
people say, "I've got Banana Coin now, and if you want to claim your Banana
Coin, use the replay protection".  And maybe that creates a small incentive
for people to move to the new quantum-secure address type, even if they don't
care about quantum stuff at all, because now they get to claim their forked
coins more safely.

**Mark Erhardt**: Well, there are two different schools of thought here,
whether or not we should have additional incentives to move to the quantum
output type, because not having additional incentives would mean people only
move to the quantum output type when they actually have a leaf that can be
spent with quantum.  But I have one question.  You said that because the block
height commitment makes it safe against replays, if the block gets reorganized
out, the transaction becomes invalid.  Why then would you propose that the
height is at least 100 blocks in the past rather than 6 or 12?

**Sjors Provoost**: I wanted to make the security equivalent to spending from
a coinbase.  If you're spending a coinbase transaction, you have to wait 100
blocks, and that means any node that's checking your transaction already needs
to worry about reorgs.  But we have this rule where we pretend that reorgs
more than 100 blocks just don't happen, because otherwise probably everything
breaks.  So, that's why I picked that number.  You could pick a lower number,
but I don't want to create any extra game theory for doing deep reorgs.

**Mark Erhardt**: Yeah, that's fair.

**Sjors Provoost**: And it seems fast enough to me, because one side is going
to move; if one side gets all the hash power, it's going to move at 140 blocks
a day; if the hash power is equally split, they're both going to move at 70
blocks a day, so it's still not a very long wait.  And that's as bad as it
gets.

**Mark Erhardt**: Right, so a little over a day, one and a third of a day or
so.

**Sjors Provoost**: Yeah.

**Mike Schmidt**: Sjors, I think you touched on this, but on the mechanism, I
think AJ responded that you don't need a new witness version; I think you kind
of touched on that.  Anything more to say there though?

**Sjors Provoost**: It's correct that you can do replay without the new segwit
version, there are different mechanisms.  But to leverage the annex mechanism
I came up with, you do need it.  I guess that's a matter of taste.  I think
the other approach he suggested is that you can make a new public key type,
because taproot basically says that if you present any kind of new public key
format, like a whole new encryption scheme, I think it just considers the
whole transaction valid or invalid, one of those two.  So, you could use that,
but to me that felt a bit of a hack.  And also, it only works in the
scriptpath, whereas my approach works on the keypath.

**Mike Schmidt**: Murch, what do you think?  Did we cover this one pretty
well?

**Mark Erhardt**: Yeah, I think so.

**Mike Schmidt**: Sjors, anything else for the audience, other than check out
your post and opine accordingly, and maybe even play with the prototype you
have?

**Sjors Provoost**: Yeah, those sound like good suggestions.

**Mike Schmidt**: Awesome.  Sjors, we appreciate your time.  Thanks for
joining us today.

**Sjors Provoost**: Thank you.

_Continued discussion of BIP54_

**Mike Schmidt**: All right, we are going to continue with the Changing
consensus segment, and we have, "Continued discussion of BIP54".  We do not
have a guest for this item.  This is sort of, I guess, a series of updates or
discussions around BIP54, which is the consensus cleanup soft fork, which
fixes four different bugs in one package: talk about the time warp; worst-case
block validation time; the merkle tree issue with 64-byte transactions; and
duplicate transactions.  There were a couple of new threads that we drew
attention to under this umbrella item here.  The first one is that Antoine
Riard posted a high-level status of what he is seeing in terms of the
proposal, talking about the 64-byte transaction ban being the most contested
piece.  We've talked about that on this show in Newsletter #408 and #412.
It's sort of an ongoing discussion, although I think that those objections
have been addressed.

There is also discussion of Bitcoin Core #35793, which is an implementation in
Bitcoin Core that is under review and testing currently, which would turn on
the rules for regtest only, not a mainnet activation.  So, if folks are
interested, check out that PR and the discussion there, or provide review.

**Sjors Provoost**: I still need to review that.  I wish people would stop
reporting CVEs and other stuff that tends to go first.

**Mark Erhardt**: Yeah.  So, rude that the whole world is burning and we have
to deal with that!

**Mike Schmidt**: We have to stop mitigating protocol bugs to mitigate
software bugs in the meantime, yeah.  Btcd has some interoperability work in
their PR #2537.  I think Riard posted that he knows of no Libbitcoin
implementation, but there is, and I posted this on my Twitter, I believe a
merged Libbitcoin support for BIP54.  Again, that's not activation, that's
just implementation.  I guess the best source of that is actually looking at
the Libbitcoin repo, or if you're unsure, you can look at my Twitter account
and it should be somewhat recent.  Riard commented a little bit about what he
sees as next steps.  That's obviously speaking for himself, but you can look
at what his ideas there are.

We also, in this summary, recapped the second thread, which was Pieter
Wuille's analysis of how BIP54's two timestamp rules bound the chain length.
We did talk about that on our own separately.  That was in #425, so you can
refer back to that.  I think there has been some discussion since we covered
that originally, if folks are curious.  And there is a third thread here.
This third one is also Antoine Riard, resurrecting an old objection from back
when BIP54 was originally being designed and discussed, someone arguing, I
think it was Friedenbach, that fixing the time warp would rule out a consensus
change that would allow for forward blocks.  This is an idea from 2018, where
you can actually manipulate the timestamp in a way to increase capacity and
thus throughput.  I think Antoine has his own comments on forward blocks and
whether there'd still be a window to do that.  But yeah, Murch?

**Mark Erhardt**: I'd be happy to provide some very subjective color here.

**Mike Schmidt**: Oh, yes, please!

**Mark Erhardt**: So, the forward blocks proposal basically is like, "Oh, we
have this protocol bug, what if we exploit it for good?" and then suggests
that we introduce a split, or a second blockchain, a consensus blockchain and
a compatibility blockchain, where the consensus blockchain would have a
changed block latency, maybe 15 minutes, but way bigger blocks; and then, the
compatibility chain would be the existing blockchain, but using the time warp
attack to have blocks every minute or so, which would then allow for ten times
the throughput, or whatever else you set, where the transactions that are in
the consensus chain, in the other slower new chain with bigger blocks, get
reprocessed into something that the old nodes would follow along without a
consensus change.

Now, the biggest issue with this idea, besides the huge increase in
complexity…

**Sjors Provoost**: That sounds like the exact reason why the time warp attack
needs to be fixed.

**Mark Erhardt**: Yes, exactly!  Basically, you're constantly exploiting the
time warp attack, which means you're at the brink of the network falling
apart, because the moment someone decides to go faster, all the blocks are
already fucking with the timestamps in order to allow this.  So, you'd need a
bunch of new consensus rules, I guess, to lock in the specific speed that
you're going for with the forward blocks.  It also assumes that everybody
wants more blockspace, and the whole extra blockchain.  And so, even in, I
think, 2016 or so when forward blocks were proposed, I think it didn't really
get much traction at all.  So, while it might be good to have a footnote in
BIP54 that concretely fixing the time warp vulnerability does not forbid use
of forward blocks in the future, I think it is a very broadly held position
that people think it's a terrible idea to do forward blocks.  So, I don't
think it's a big issue for the viability of BIP54, but yeah, sure, maybe we'd
document it.

**Mike Schmidt**: And Murch, if I recall correctly, in our conversation with
Jeremy, you had a similar conclusion on the 64-byte transaction, "Hey, we
could do this, we could add a new merkle tree, or 64-byte transactions could
do this and that in a perceived future".  You had a similar, I guess, feedback
to that, which is like, "Well, yes, you could, but that stuff is kind of a
little bit outlandish, I guess".

**Mark Erhardt**: Yeah, so I'm going to try to steelman Jeremy here.  He feels
that, (a) it is really ugly that we allow transactions of 62 bytes, 63 bytes,
and 65 bytes, but we have that one value, 64 bytes, in between that we don't
allow; and (b) what if 64-byte transactions would be very useful in the
future?  So, forbidding it now as a shortcut to fixing an issue might come
back to bite us and we might regret it.  So, the alternative approach that
Jeremy was floating was, instead of forbidding 64-byte transactions, we forbid
including hashes in the merkle tree that could be valid transactions.  You
would basically run a bitmap check that checks whether a transaction hash is
composed in a manner that would allow it to be deserialized into a valid
transaction.  If so, that is not a valid hash in the merkle tree, and a block
cannot be valid if it produces any such hash anywhere in the merkle tree.  So,
whenever you build a block template, you would have to hash all the
intermediate hashes and check that none of the intermediate hashes in the tree
could be deserialized into a valid transaction.

My initial reaction was that that might be very costly for hashers to do, but
apparently with bitmaps, you can implement this fairly efficiently.  However,
I'm still not sold that 64-byte transactions will ever be valuable, because
that means that the input script is empty and the output script can, at most,
have 3 bytes.  So, there's no way that you could commit to a specific public
key or other mechanism that requires a signature.  So, these outputs would
always be ANYONECANSPEND.  And if they're ANYONECANSPEND anyway, we could
either express them in a byte less or add a byte more to pad them to 65 bytes.
And for these future hypothetical use cases that have no examples that feel
palpable right now, I think this burden of potentially padding your output
script by 1 byte seems an acceptable price.

**Sjors Provoost**: The other thing is, if you're going to add a bunch of
complexity, the 64-byte rule is very simple, but you could make this more
complicated rule with a bitmap.  But if you're going to add a bunch of
complexity to the consensus rules just in case, then I would almost think just
add the simple rule, and then budget that complexity for a future soft fork
that is geared towards whatever the thing is you wanted to do with the 64-byte
transactions.  If we see this new use case for exactly 64 bytes and you cannot
use padding for it, it seems to me that there has to be a new soft fork that
you can do that does allow it.  And then hopefully, the totality of the
complexity is lower than this bitmap solution, which also just sounds quite
complicated to wrap your head around, even if you can probably do it correctly
and performantly.

**Mark Erhardt**: Right, I agree.  And then, regarding the consensus scheme, I
think it's more acceptable to just forbid transactions under 65 bytes, than if
we're really, really upset about one value being forbidden.  They're
non-standard already.  We have seen a few examples of them, but they're
basically no input script OP_TRUE, single input, single output.

**Sjors Provoost**: Ugliness is an argument if you've ever looked at the
consensus code, but I don't know.  It makes more sense to me to ban this thing
that you strictly have to ban, than to ban more because it's more elegant,
maybe.  But I can sort of see both sides of that.  The real bug is the merkle
tree calculation, and we can fix that with a hard fork, but we don't want to
do that for the next 100 years.  So, I think it's fine to say, well, this is a
special value because it is exactly two leaves, and it's only about that
special value.  It's not about smaller values and it's not about bigger
values.

**Mark Erhardt**: Strictly speaking, you could do it in a soft fork, where you
just move all of the Bitcoin transactions to an extension block and require
that the old blockspace is always empty, and then you can do whatever the fuck
you want, which would be a soft fork.

**Sjors Provoost**: Yeah, you can play chess.

**Mike Schmidt**: We look forward to your BIP, Murch.

**Mark Erhardt**: No, man, absolutely not!

**Sjors Provoost**: Well, I think Peter Todd once wrote a blog post explaining
how you could do a chess game this way.  Nowadays with Claude, I guess you
could actually implement a chess game with this evil soft fork, but maybe not.

**Mike Schmidt**: Please don't give people ideas.

**Mark Erhardt**: I mean, people are doing interesting stuff like that already
with different payment channels, where they then basically step through the
states of essentially a Lightning channel with the rules of chess or poker.
You just open a Lightning channel and after the game, close it, and in between
you can play at the speed of the communication between the two peers.  So, I
think we don't even need to go there and do a whole soft fork in order to play
chess on Bitcoin.  People that want to do that sort of thing have found ways
already.

**Mike Schmidt**: Yes, see, I believe, our waxwing discussions recently for
more details there.  Well, I think we link off to a bunch of the reference
discussions in the write-up for this BIP54 summary item.  So, if folks are
curious, dig into that, find the Libbitcoin PR, find the btcd PR.  I think
there's a SAT D implementation.  I think rbitcoin has a PR open for BIP54 as
well.  So, if you're curious about the implementation state, you can check
those primary sources.  And then, there's some of the discussion we mentioned
on the mailing list and Delving, so check it out.  Anything else on this item,
gentlemen?  We delve into quantum now.

**Sjors Provoost**: I'm signing off, by the way, so thanks for having me.

_QSAVE for unmigrated coins_

**Mike Schmidt**: Okay, we'll see you, Sjors.  Thanks for your time.  "QSAVE
for unmigrated coins".  This is another entry in our cap of what do we do with
the coins that never migrate to post-quantum addresses after a potential
Q-Day.  This one is from James Tagg.  He posted five draft BIPs for something
called QSAVE.  The idea is a quantum migration transition which never burns
anybody's coins.  He frames this as an alternative to BIP361 and an
alternative to Hourglass.  We talked about Hourglass back in #395.  The idea
of these coins that don't move, what do you do with them?  The idea here is
that at some enforcement height, activated as a soft fork, any input that
isn't part of a known post-quantum type counts as unmigrated.  And that
unmigrated output now has an additional constraint put on it, which is that
you've got to satisfy the normal locking script, but then there's this second
factor, and James mentions a zero-knowledge proof (ZKP) that a proof of seed
-- we've talked about this in the genre of rescue protocols previously -- so,
you have to satisfy both of these in order to move the funds.

But also, an unmigrated input, if you can't provide that second factor,
apparently it doesn't destroy the coin.  What he describes is a sort of
offchain lost property process, which starts touching into the meatspace,
where I think he's unspecified, but somehow there's some quorum that would
then do meatspace or traditional legal processes, and the person could prove,
through some documentation, that they actually bought the coins back in the
day, or whatnot, and then this quorum would actually sign off on it.  This is
my understanding of it.  Maybe I'll pause.  Murch, you're getting antsy, which
means you want to talk.

**Mark Erhardt**: Yeah.  Well, generally for all of these recovery scheme
things, they are always based on some sort of knowledge asymmetry.  So, even
when you have the public key onchain, if it was derived with a BIP32
derivation or if it is derived from a mnemonic, you can show that there was a
hash to which you know the preimage that matches the public key.  You could
prove, by having the mnemonic, that the public key belongs to the derivation
chain of that mnemonic.  And since there's a hash step in that process, this
would be something that a quantum adversary would not be able to do.  Now, I'm
not super familiar with QSAVE directly, but this offchain lost property
process I feel would be the meat of this proposal, and getting that right in
the meatspace seems ambitious.

**Mike Schmidt**: We have Bitcoin so we don't have to worry about these sorts
of things.

**Mark Erhardt**: Yeah, well, I guess the deep problems are coming for us
whether we want them or not.  The question of what to do with these unclaimed
coins or lost coins in the face of a quantum adversary appearing at some
unknown point in the future is still unclear.  We didn't have the quantum
landmines here, but I'm sure we'll talk about that in the future.  There seems
to be a new trend, beyond the Hourglass proposal, to have some game theory
approaches to solving this problem.  So, I'm sure we'll talk about that next
month or in the coming weeks.

**Mike Schmidt**: Yeah, it seems like, even with this next item that we'll get
into, there's this category.  There's been discussion, "Do you freeze or let
them steal?"  And now, people are introducing various third options, like this
one has the meatspace sort of adjudication for coins.  And Cory posted about
landmines, which I guess we'll talk about a month from now when we cover the
Changing consensus segment again, that introduces some different ideas as
opposed to just freezing those at the protocol level or letting quantum
attackers steal them.

**Mark Erhardt**: Yeah.  Now that we've mentioned it three times, if I
understand it right, the basic idea is that after an activation, someone would
have to put up collateral before they can spend unmigrated coins.  And if they
put up collateral and there's an actual owner that has some sort of knowledge
asymmetry, they can take the collateral and the coin, which means that it is
dangerous for a quantum adversary to put up the collateral and then try to
steal old coins, because a potential actual owner would be able to take that
collateral.  And for coins where there is no knowledge asymmetry, because the
original wallets were just bags of keys where each key was independent and
they were directly used in output scripts, it would be very hard to produce
any sort of documentation or knowledge asymmetry there.

There was a second idea to have some sort of bidding war, where people can
commit up front how much money they would spend in order to take that UTXO.
That part I need to understand better still.

**Mike Schmidt**: Yeah, and in the first version, it can protect coins that
don't have that asymmetry, or maybe don't even have an owner any longer if
that person has passed on, or those keys are destroyed, or whatnot, because
the threat of somebody potentially having that protects those coins as well.
So, it's an interesting idea.  Maybe we'll be able to get Cory on and talk
about it next month.

_Proof-of-decay for unmigrated outputs_

But in the meantime, we have another post-quantum discussion.  This is,
"Proof-of-decay for unmigrated outputs".  So, it's the same problem we've just
been discussing, but a different answer.  bitKingAE posted a sketch where
quantum-exposed coins that don't move within a certain grace period slowly
shrink.  One example he mentioned was a small percentage decay of the
spendable amount every 50,000 blocks.  So, every 50,000 blocks, if you had 1
bitcoin, what you could spend goes from 1 bitcoin to some percentage less than
1 bitcoin.  And then, there are ideas that he posted around those lost sats
either getting burned or they're paid to miners in some way.  I don't think
the idea is fully fleshed out in terms of exactly how that would be done.
When you go to spend, I guess there would be some consensus rule that would
enforce that a certain portion of the coins can move, and I guess the rest
would go to fees.  That would be the simplest example, but I think there's
some more discussion on how that might work.  Murch, Gustavo, I don't know if
you've taken a look or have thoughts.

**Mark Erhardt**: I mean, the general idea is a pretty old one, that coins
that are lost could be used to fund a tail emission or a long-term mining
reward, or just be deleted from the UTXO set in order to make the UTXO set
smaller.  This seems to be a variant of that.

**Mike Schmidt**: Well, if you're curious, we weren't able to get bitKingAE
on, but there is, I think, a Delving thread.  If you're curious, you can jump
in there.  I think there are already a little bit of objections, as you might
imagine, already to this approach.  Obviously, people are thinking about this
quantum stuff, so voice your opinion as you see fit.

_BIP300 bundle censorship_

And our last Changing consensus item, "BIP300 bundle censorship".  Folks may
have heard rumblings of the ecash, as they're calling it, hard fork related to
BIP300 and BIP301.  I don't remember the timing of this post, it may have been
after that.  But this person points out that in BIP300, any miner can send
this sort of alarm in a block.  BIP300 activates drivechains, so this idea of
having a series of sidechains off of Bitcoin where your coins are pegged out
into the sidechain.  But instead of doing something like Liquid does, where
you have this federation, you actually have the miners be the ones that
control where the coins can move back and forth from.  And as part of that
mechanism, I guess there's this alarm signal that a BIP300 miner can send,
which would essentially knock one point off of their pending bundle of
withdrawals from the sidechain back to the mainchain.  The poster articulates
that a miner with 26% of the hashrate, who continues to send this alarm to try
to block this bundle or this withdrawal, can block that valid withdrawal
forever, because if the other 74% of the miners actually do approve the bundle
or the withdrawal in the block, the score that it would get under BIP300's
rules in this 26,300-block window would be something like 12,600, but it needs
13,100.  So, this minority miner can essentially block these withdrawals.

**Mark Erhardt**: So, drivechains are an idea for creating sidechains next to
a main chain.  They're based on the idea that miners essentially are the
authority, the executive power on the blockchain, and as long as the mining
power is sufficiently distributed and honest, you can have untrusted, safe
interactions between the sidechains and the mainchain.  So, these drivechains,
they are based on a very long delay, what is it, 26,300 blocks, in order to
make deposits and withdrawals.  Each miner in every block can either support
or ignore the withdrawal from the sidechain.  But then, there's also an active
veto, this alarm mechanism.  And the alarm mechanism counts double, I think.
So, if now 26% of the hashrate, or probably a little over 25% of the hashrate,
were sending the alarm signal on every block, it would count as over 50% and
thereby deny any sort of interaction between the drivechain and the mainchain.

I think it got a little lost in the drama about BIP110, which was much more
effective at getting some spotlight.  But the ecash project actually started a
fork of Bitcoin in, was it October, I think?  And the interesting thing about
that is, looking at their block explorer right now, there are two miners that
have over 27%.  The biggest miner currently on that blockchain appears to have
66% of the hashrate, and the second biggest has 28.5%.  So, this is not
completely theoretical, because either of those two parties would be able to
block interactions between the drivechain and the mainchain.

**Mike Schmidt**: I think that's probably good for that item, which I believe
wraps up our News and Changing consensus segments, and we can move on to
Releases and release candidates with Gustavo.

_LND v0.21.6-beta and v0.20.7-beta_

**Gustavo Flores Echaiz**: Great.  Thank you, guys.  This was really
interesting stuff.  So, let's start with the Releases and release candidates.
This week we have three different items.  The first one is LND v0.21.6 and
v0.20.7.  These are security releases that were urgently shipped, so not to be
confused with the previous ones we covered last week.  These two releases
include a mitigation for the Linux kernel vulnerability that has been
discussed in a lot of similar media around information security, which
basically allows a remote attacker to take over a Linux server.  This
mitigation in LND we were going to cover it as a separate item, but it doesn't
fully fix a computer that has this Linux vulnerability.  It simply changes
some settings in LND, but a user would still need to install patched kernels.
So, it's important for any LND user to upgrade, but this as itself isn't
sufficient if you're running a compromised machine.  We're going to get into a
little more detail in a minute when we get to the Notable code section for
this.

_Core Lightning 26.06.10_

The next release, Core Lightning 26.06.10.  This one we don't have details on.
As usual, the Core Lightning (CLN) maintainers have withheld many of the tests
associated with the fixes.  So, the source code is available, but we haven't
yet seen a proper description of the vulnerabilities and the fixes and, like I
said, the tests have been withheld.  So, all users are strongly recommended to
upgrade.  But apparently these vulnerabilities specifically targeted dual
funding, splicing, onchain HTLC (Hash Time Locked Contract) resolution, and
access controls.  These are very similar topics that we've seen being
exploited in the past few weeks in CLN and other similar repositories.

_BTCPay Server 2.4.7_

The final one is BTCPay Server 2.4.7.  This is another major security release,
so once again, users and operators are strongly recommended to upgrade.  It
fixes 85 security findings that were reported in Anthropic's OSS Scanner
program.  BTCPay Server, being open-source software, could benefit from a
specific program by Anthropic, one of the main developers of AI intelligence
software.  This allowed the Anthropic team to deploy BTCPay Server code in an
isolated instance, and test the code and find vulnerabilities in that specific
isolated instance.  That's the process of how these vulnerabilities were
found.  They affect payout limits, access to other stores' data,
authentication, and resource exhaustion.  It also fixes payment accounting and
reliability issues.  So, a lot of fixes, none seem to be critical or ones that
made a major story.  But if listeners are curious about what those fixes are
-- excuse me, there's actually one critical security fix.  The others are
either high, medium or low.  But the release notes have all the details on
that.

_Bitcoin Core #36539_

So, that covers the Release section, and now we jump into the Notable code and
documentation changes.  We have three different items from Bitcoin Core this
week.  The first one is about an issue that shipped in Bitcoin Core v32.1.
So, specifically, PR #36539 reverses a change made in Bitcoin Core 32.1, where
in the GUI, if you installed Bitcoin Core 32.1 and you were trying to export a
PSBT, either when creating a transaction or when bumping the fee, it would
export using v2.  There was no way for a user to choose between v0 or v2 from
the GUI, contrary to the RPC, which by default is now v2, but always allowed a
user to use v0.  So, if you were a user that had a hardware wallet, for
example, that only supported v0, and you upgraded to Bitcoin Core v32.1, you
would have been unable to use the Bitcoin Core GUI with your specific device.
So, now this restores v0 by default on the GUI.

However, if you were using the external signer workflow that we've previously
covered, which basically allows you to connect your hardware wallet with a
machine running Bitcoin Core, even via the RPC or the CLI or the GUI as well,
that continues to use PSBTv2, because it also uses HWI, the Hardware Wallet
Interface, behind the scenes.  So, if, for example, your device only supports
v0, HWI makes the conversion for you.  So, it doesn't matter that Bitcoin Core
exports in v2, because HWI will make the conversion if your device only
supports v0.  But the main change is that if you're a user using Bitcoin Core
without the external signer workflow, transactions are now going to be
exported in v0, as was the case before version 32.1.

_Bitcoin Core #35714_

The next two items are a bit similar.  The first is a bug, #35714, where for
example, in a specific case where you would have, let's say, two separate
disks.  In one disk you would keep your block index or UTXO database, and in
another disk, your block or undo data.  And for example, you were trying to
flush block or undo data from memory to disk, but your node would be unable to
complete that flushing, probably because you ran out of space on that specific
disk.  However, the failure would signal to the node to shut down, but it
wouldn't stop the block index or UTXO database from being written in that
specific disk.  And if I bring up the case where you're using two separate
disks, then the write would succeed on that latter disk, and this would create
an inconsistency between the different states, and could complicate recovery.

**Mark Erhardt**: Right.  So, the problem would be that it doesn't write the
block, it fails, for example, because the disk is full.  In the case that this
happens at the same time as the node shutting down, which might happen because
of the failure to write to the disk, it would then update the block index and
UTXO database.  So, it would not have the block on disk, but it would already
have deleted the UTXOs that were used and added the new UTXOs to the UTXO
database.  And this is a problem because without the undo data, we don't know
which UTXOs were spent.  So, the newly added UTXOs are easy.  I can just
reprocess the block, I see which outputs were created in the block, I add them
to the UTXO set, and that way going forward from a specific point, or even
rolling backwards and just rewriting the additions to the UTXO set, that's
trivial.  The problem is the deleted UTXOs, because we don't know when those
were created.  We would have to scan the entire blockchain again to get those
back.  And that's exactly how you would recover from this, by doing a whole
reindex.

**Gustavo Flores Echaiz**: Exactly.  Thank you, Murch.  So, now, if it fails
to flush block or undo data to disk, it will not only signal the node to shut
down, but also skip the database writes for the block index or UTXO database.

_Bitcoin Core #35492_

The next one, Bitcoin Core #35492.  This is a bug when dumping a wallet file
to export it, the first step would complete, you would be able to create the
export file, but somehow, for example, when once again running out of disk
space, you could not complete the subsequent write operations.  So, the
destination file would get created, but it would not get completely written.
Previously, Bitcoin Core could just report success even if the wallet export
was incomplete, just because the destination file was present, which meant
that as a user, you could mistakenly believe that the export was complete, try
to recover the wallet on another machine, for example, and then you would
discover that there's missing data when trying to restore the wallet.  So,
now, the fix is simple.  The command not only verifies that the file exists,
but that the writing, the flushing, and the closing of the file were all
successful, and it reports failures and removes incomplete dump files in the
scenarios where it fails.

_BIPs #2205, #2210, and #2212_

The next item, from the BIPs repo, combines three PRs, #2205, #2210,
and #2212, which together are the three draft specifications for cross-input
signature aggregation (CISA).  The first one, BIP458, specifies
non-interactive half aggregation.  The second one, BIP459, specifies DahLIAS,
I believe that's how it's said, which is an interactive protocol for full
aggregate signatures, so not just half aggregation, but full-on aggregate
signatures.  And finally, the last one, BIP460, is the proposal for how to use
these schemes for keypath spends, so basically what the Bitcoin transaction
would be to represent those operations.  Anything you want to add here, Murch?
No?  Okay, great.  So, yeah, just to say that listeners can look through the
BIPs text for each one.  The first one, like I said, covers the half
aggregation scheme, the second one the full one, and the third is the proposal
for how to actually turn it into a Bitcoin transaction.

BIP460 doesn't announce a specific activation mechanism or parameters, that
remains unspecified, but deploying such a proposed transaction aggregation
scheme would require a soft fork.  And also, this has massive benefits for
reducing transaction weight, specifically when talking about…

**Mark Erhardt**: Well, "massive"?  We should be careful with soft forks.  A
big part of inputs is the commitment to the UTXO they're spending.  The
commitment itself weighs 36 bytes: the 32 bytes of the transaction ID and the
4 bytes of the position of the output in that transaction.  So, what you're
saving on is the signatures.  In BIP458, the half aggregation one, it's the S
values, I think, that get aggregated, right?  Signatures have an R value and
an S value, which are 32 bytes each.  In taproot, which I assumed this would
be ruled out for, they're exactly 64 bytes together, because the format was
improved over how we do other ECDSA signatures.  So, you would be able to save
those 32 bytes from all but one of the signatures.  If you have five
signatures, you would save four times 32 bytes.  However, the signature bytes
live in the witness already, so they're discounted.

So, if you're looking, for example, at a P2TR keypath spend, which has 57.5
vbytes, I think, 36 of those are just the output, then you need the sequence
for another 4 bytes, and the input script length for one more byte.  So, 41
bytes of those are already from the non-witness data on the input.  And then,
only the 64 bytes plus the witness item count, and so forth, which makes us go
to those 16.5 extra bytes.  Those would be discounted.  So, they're 64 weight
units, which comes down to 16 vbytes.  So, the big portion is just what UTXO
you are spending.  The small portion here is the signature, which is about a
third of a P2TR input.  And then, you can only save on n-1 of those for half
aggregation.  For full aggregation, you get to save the entire signature.  So,
it's a little better, but still less than a third of the weight of the inputs.
Outputs don't get discounted.  So, there's a slight financial incentive to
aggregate and to do transactions with more inputs, but we shouldn't overstate
it as a massive cost reduction.

**Gustavo Flores Echaiz**: Thank you, Murch, for adding that extra context.
That's very helpful.

**Mike Schmidt**: Yes, maybe one quick plug from the past.  #417, we had
Fabian on to talk about a bunch of this.  He's one of the authors of these.
So, listen to #417 if you're curious about some of the details and benefits,
straight from the horse's mouth.

**Mark Erhardt**: Maybe also, if we did a post-quantum cryptography input
type, those inputs would presumably have way more signature data.  SHRINCS
runs, for the stateful one, over 300 bytes, and for the stateless one, over
3,000 bytes, if I recall correctly.  And then, you might also need to reveal a
public key, which I think comes in at another 3,000 to 5,000 bytes depending
on the scheme.  Or I guess SHRINCS was smaller.  But anyway, we're looking at
300 to 3,000 bytes.  Now, if we were able to aggregate some of those, that
might be more important.  And I think that some of the output type discussion
revolves around that sort of thing.  So, maybe with post-quantum outputs, we
could do some aggregation, and that might then bring the incentive for people
to have way, way larger inputs, but at least you only have to pay for a
smaller amount of signature data.

_Core Lightning #9419_

**Gustavo Flores Echaiz**: Great stuff.  Thank you both.

The next items are now from the Lightning repositories.  We go with CLN first,
PR #9419.  This is a new field that gets added in a specific RPC command,
listforwards, and a new notification called forward_event.  It adds an
optional field called failure_reason.  What was happening here is that if you,
as a node, are forwarding a payment, and you trigger a forwarding issue, for
example you have insufficient outgoing liquidity or an outgoing peer goes
offline, you would simply report back to the node that's trying to make the
payment through you that this was a temporary channel failure.  And
previously, you, as a node operator, would have no more insight on why it
failed beyond the message you reported back to the payer.  So, the objective
here, through this field, is to have more insight on exactly why this
happened, whether this was insufficient liquidity, too many HTLCs, there are
multiple potential reasons.  So, now you can make a distinction between these
different reasons why the payment failed to forward via your node.

_Core Lightning #9592_

Next item, #9592.  This updates xpay, which is the main plugin for payments in
CLN, and it's updated to avoid a forwarding node for the remainder of a
payment if it returns unknown_next_peer twice.  So, you are making a payment,
you just chose a route with askrene, which is the routing layer underneath
xpay, and you arrive at a hop and the payment fails, that hop specifically
returns unknown_next_peer, so its next peer is unknown.  Then, you make the
payment again with another route, but you choose that node once again as a
hop, and then you get the same failure.  Now, you will just exclude that
specific node from any payout attempt for that specific payment.  It's not
like you're going to add it to a blacklist forever, but just for that payment,
you're going to exclude it.  And why this is important is that the PR covers
an issue where someone retried the same node more than 40 times and the same
response was given.  So, the payment would simply consistently fail through
the same node with the same error.

This heuristic might exclude usable channels, right?  So, there's a trade-off
here.  This is not a perfect solution, because you don't know if the next
attempt through that node will once again trigger that result.  But if you've
gotten the same response twice, the CLN team here makes a decision to exclude
that node from being chosen for this specific payment.

**Mark Erhardt**: I do hope that they discover when a payment has to go
through that node.  For example, if we're making a payment that goes to Dave,
and Dave only has a channel with Carol, we might go through Bob and Alfred and
whoever in the first hop to arrive at Carol; but if we have to go through
Carol in order to pay Dave, and if both Bob and Alfred fail and we stop going
through Carol, and there's no other route, that might be an issue.  So, I
assume this is pretty obvious.  I assume that they must have thought of that,
but if not, I hope they hear me!

**Gustavo Flores Echaiz**: That's a great point, of course, and a great
question.  I don't have the exact answer for you, but it's definitely
something that I'm sure they thought about.

_LDK #5089_

Next item, LDK #5089.  This is a specific case when trying to broadcast a
commitment transaction and a child transaction that spends an anchor output of
that commitment transaction.  Previously, if LDK didn't have the funds
required to pay for the fee of both transactions, specifically of the child
transaction that pays for the parent, it would have simply not broadcast
either of those, and that would have delayed recovery of channel funds.  So,
what this PR does is that if LDK cannot find the necessary funds for the child
transaction that pays for the fee of the commitment transaction via CPFP, it
will still broadcast the commitment transaction alone.  Probably, it might not
get confirmed, because LDK initially is making a CPFP attempt because the
network fee is probably higher than the commitment transaction's.  But it's
better to broadcast that transaction alone, just in case fees come down and
that transaction could just confirm by itself.  Yes, Murch?

**Mark Erhardt**: I mean, we've been having historically low feerates lately.
A lot of the issues in Lightning stem from feerate spikes, and we had this
period of time in which feerates were absurdly high for over a year.  But
since then, we regularly drop to feerates of a 0.25 sat/vB (satoshis per
vbyte), now that feerates below 1 sat/vB are broadly accepted on the network.
And presumably, almost all of the Lightning channels have at least 1 sat/vB as
the minimum fee on the commitment transaction, unless they're using zero-fee
transactions with TRUC (Topologically Restricted Until Confirmation), the new
construction that is slowly rolling out for the latest Lightning releases.
So, yeah, if you currently were to broadcast a Lightning channel commitment
transaction with 1 sat/vB, chances are that it goes through within a few
blocks, basically any time in the last few months.  So, this might have been
discovered by Project Loupe, but it's actually interesting in today's day and
age, because low-feerate commitment transactions may well be viable.

**Gustavo Flores Echaiz**: 100%.  Thank you, Murch.  And like you mentioned,
the exception of TRUC or zero-fee commitment transactions is also marked in
this PR.  So, this fallback excludes those types of transactions, because
obviously they cannot be broadcast by themselves as they require a fee-paying
child transaction for relay.

_LND #11456_

The next four items are from the LND repo.  The first one is the one we were
discussing in the release section, PR #11456.  This disables Multipath TCP
(MPTCP) listeners by default to mitigate the CVE vulnerability that allows a
remote attacker to basically execute code remotely on a Linux machine.  Go
1.24 and later enabled these listeners by default.  So, it meant that if you
were running a Linux machine with LND by default, and you were using a Go
version of 1.24 or later, you had those listeners enabled by default, and you
should definitely upgrade to the latest release that fixes this for LND.
However, like I said earlier, this doesn't fully fix the underlying kernel
bug.  So, if you have an affected system, you still require a patched kernel.

_LND #11357_

The next item, LND #11357.  This is a major effort towards tightening BOLT11
invoice validation, mainly following the merging of BOLTs #1357, which we
covered in Newsletter #428.  This also follows work that we covered in
Newsletter #425, where LND was already rejecting duplicate payment hashes.
But now, the main objective of this PR is that, instead of using the first and
ignoring the rest, it now rejects duplicate payment secret fields, which
prevents ambiguity between LND and other software, where one could choose one
payment hash and the others could choose another payment hash.  In
Newsletter #428, we discussed how this led to an exploit in a piece of
software called LNP2PBot, which was a Telegram bot for P2P trading of bitcoin
and fiat currencies.  So, this was an exploited bug in other software because
of the ambiguity in the BOLT specification.  So, now LND applies the latest
change in the BOLT specification, so that there's simply no ambiguity, and it
will always reject duplicate payment secret fields.

There were tests added, and it revealed other requirements that were not being
enforced.  For example, the decoder now rejects incorrect lengths for a
payment hash, a description hash, a payment secret, and a receiver public key.
Previously, if those fields had an incorrect length, it was treating those
fields as absent.  And that's specifically a problem for the receiver public
key, because an incorrectly-sized receiver public key was previously treated
as absent, which could cause LND to fall back to recovering the key from the
signature, because that's also a rule from the BOLT spec: if the receiver
public key field is absent, then fall back to recovering the key from the
signature.  But in this case, it wasn't absent, it was just of the wrong
length.  So, now LND simply rejects incorrect lengths for that field and other
fields, as I mentioned.  Additionally, for invoices containing an explicit
receiver public key, a low-S ECDSA signature is also required.  However, this
restriction does not apply when the public key is recovered from the
signature.

_LND #11413_

The next item, LND #11413.  This is a cleanup operation, that some users were
having issues when starting up their node.  During normal operation, the node
would have accumulated a result for each resolved locally-initiated HTLC
attempt, which meant that at startup, it would remove results that are no
longer needed.  But for example, if it had accumulated many of those results,
then at startup it would be making individual database operations for removing
those results, and reading and deleting those entries would require repeated
database round trips, specifically when using PostgreSQL.  This was
particularly bad when you were using a remote database on a separate machine,
and this could potentially even take hours.  So, now all database operations
are done in a batch, while preserving the results needed to resume pending
payments.  The benchmarks are quite impressive.  Even on a database that is
local, so not the worst case of a remote database, the improvements are 30
times faster, so quite a considerable speedup here.  It should be noticeable
for LND users that make a lot of HTLC transactions.  They should notice a
difference next time they upgrade with the next version, and at startup
specifically.

However, I want to note that the issue was found specifically in PostgreSQL,
but the upgrade is made for both PostgreSQL and SQLite.

_LND #11151_

The next item, LND #11151.  Here, we add checks for excessive commitment
feerates and inadequate initial balances when accepting incoming channels.
Now, LND will reject a proposed feerate based on a specific rule when
accepting an incoming channel: if the feerate is above the greater of ten
times its three-block estimate or 100 sat/vB, it will always reject when the
proposed feerate is the greater of those two.  Additionally, LND was
previously not enforcing BOLT2's initial reserve rule, and it now will start
enforcing it.  But it also adds an additional rule on top of that, which is to
reject channels where neither party's initial balance exceeds the reserve that
party must maintain.  That means that if my peer has a specific set limit for
how much initial balance I need to have, LND now checks that I have that
balance.  And also, if my node has that rule set, it will also check that the
peer has that initial balance.

This reserve rule is different.  There are two reserve rules in Lightning.
This reserve rule is about how much bitcoin you must keep inside the channel.
For example, if I have 100,000 sats, I cannot spend 100,000 sats on that
channel.  I always need to keep a reserve, for example 10,000 sats.  The
purpose of that reserve is, if I'm caught cheating in a penalty transaction, I
always have a balance that I can lose.  So, there's always an incentive for me
not to cheat.  If I had no reserve, then I could just spend my whole channel,
I could try to cheat, and I wouldn't lose anything, because I had already
spent my whole channel balance.  This reserve ensures there's always something
to lose.

_Rust Bitcoin #7067_

And the final item, Rust Bitcoin #7067.  This extends specifically the taproot
signature hash (sighash) helpers to accept an optional annex and, for
scriptpath spends, the opcode position of the last OP_CODESEPARATOR.  What
this is exactly is that before signing a Bitcoin transaction, your software
calculates a sighash, the digest that the signature will authorize.  Rust
Bitcoin's general function, not the specific taproot helpers, already accepted
the case where you would have an annex and/or an OP_CODESEPARATOR.  However,
the specific taproot helper function would always assume there was no annex
and no OP_CODESEPARATOR, which meant that if you were using those helpers to
calculate the sighash, but the transaction you're trying to sign has an annex,
it would previously simply fail to create the right signature, because you're
simply not able to compute the right sighash.  So, now the specific taproot
sighash helpers catch up to the functionality required to support these types
of transactions.  And that's the final item and completes the newsletter.
Thank you.

**Mike Schmidt**: Awesome.  Thank you, Gustavo.  We also want to thank Murch
for co-hosting, and we want to thank our guests today.  We had 0xB10C, Luke,
and Sjors joining us earlier.  Thank you all for listening.  We'll hear you
next week.  Cheers.

{% include references.md %}
