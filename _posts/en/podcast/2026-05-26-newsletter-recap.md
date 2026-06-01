---
title: 'Bitcoin Optech Newsletter #406 Recap Podcast'
permalink: /en/podcast/2026/05/26/
reference: /en/newsletters/2026/05/22/
name: 2026-05-26-recap
slug: 2026-05-26-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by Oliver Gugger and
0xB10C to discuss [Newsletter #406]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-4-26/424935054-44100-2-c8bc9ec3a7af7.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optec Newsletter #406 Recap.
Today, we're going to be talking about a couple of news updates, one to BIP322's
generic signed message format, and another one talking about TCP hole punching
for accepting inbound connections on your node.  We also have our monthly
segment covering four Changes to services and client software, as well as our
weekly segment on Notable code and documentation changes.  This week, Murch,
Gustavo and I are joined by two guests.  We'll have them introduce themselves
briefly.  Oli?

**Oliver Gugger**: Yeah, thanks for the invite.  I'm Oli, also known as guggero
on GitHub, former developer with Lightning Labs, now working on a new project,
currently undisclosed, not published.  And I came across some to-do's on BIP322,
and that's, I guess, why I'm here, to talk about that.  So, thanks for the
invite.

**Mike Schmidt**: Awesome, thanks for joining us.  And 0xB10C.

**0xB10C**: Hi, I'm 0xB10C, I work on Bitcoin monitoring with the Bitcoin
Network Operations Collective.

_Significant updates to BIP322 Generic Signed Message Format_

**Mike Schmidt**: Awesome, thank you both for taking the time.  We're going to
jump into the News section.  First item titled, "Significant updates to BIP322
Generic Signed Message Format".  Oli, you posted to the Bitcoin-Dev mailing list
about your work making several updates to BIP322, known as the Signed Message
Format Proposal, Generic Signed Message Format Proposal, I should emphasize.
That proposal's sort of been sitting open for a long time.  Maybe, Oli, you
could perhaps give listeners some of the long-ish history of BIP322, and then
you can let us know how you came to start working on it.

**Oliver Gugger**: Sure.  I hope I can represent the full history because I
wasn't really involved before.

**Mike Schmidt**: Maybe abbreviated, yeah.  You can give us an abbreviated
version.

**Oliver Gugger**: So, yeah, I think it was in 2018 by kallewoof, what's his
full name, with the idea to be able to prove to someone that you have the
ability to spend from a certain address, usually involving a cryptographic
signature, but as we'll see later on, doesn't necessarily need to be a
cryptographic one.  And often, the use case is for KYC.  Yeah, we all don't like
KYC.  I wish there were better options, but instead of doing something like a
Satoshi test to prove to an authorized broker that you own the recipient
address, you could use a signed message or sign a message that proves that you
are the ultimate recipient.  So, I guess that's the whole purpose for the BIP.
There are other use cases, interestingly enough.  The Ark protocol uses it for
the virtual transaction signing, to prove you own the UTXO.  So, it's not
limited to that single use case.

But yeah, the history is that it was opened as a draft in 2018.  Then, there
were two Bitcoin Core PRs.  Both of them were closed due to lots of discussion
with seemingly no resolution and open items.  Yeah, so it felt like the BIP was
stuck for a while, for a long while.  I mean, it's been eight years.  And then,
yeah, I've seen some requests on the LND and btcd repos to support it.  And
then, yeah, I started this new project where we actually require it, and that
was the final straw to sit down and implement it in Golang.  And while
implementing, I discovered all the open questions.  Instead of just trying to do
a workaround, or whatever, I thought, "Hey, I've worked with BIPs, I've read a
couple of them.  Why not try to get it over the finish line?"  So, I gathered
all the open questions, all the discussions, and tried to address them, either
by just text or by actual changes to the spec itself.  And so, yeah, then I got
lots of review, specifically from Murch as well.  So, thank you very much.  And
the final process was pretty quick.  So, it was merged within three weeks, or
something, and it's now status complete 1.0 which is cool.

**Mike Schmidt**: And so, what were the big pieces that remained from that
initial work, and then lingering over those eight years to what you got across
the finish line in the last few weeks?  What are the big things that people
should be aware of that you put your time into?

**Oliver Gugger**: So, there are several ones, one of them being a breaking
change, or I guess two of them.  So, I want to mention them up front.  So, first
is that there are three different variants of a signature, and they all use a
different internal encoding, which makes it hard for implementers, that you
basically have to try each encoding and see which one doesn't fail to find out
what variant it is, which isn't super-nice.  So, I proposed a human-readable
prefix, just three letters, that indicate which version it's actually supposed
to be, and then the parser can directly use that.  And because of the prefix,
you can't just base64-decode it anymore, it will fail.  So, you have to update
your parser if you already have an implementation.  There is a small
backward-compatibility fix in there that if you don't supply a prefix and it's
the simple variant, then you're supposed to allow it just so that all the
existing implementations don't break.  But other than that, it's a breaking
change.

And then, the second one, which is definitely a change to the format, is the
proof-of-funds variant, which allows you, in addition to proving that you can
spend from a certain address, you can also prove that you can spend some set of
UTXOs.  So, you can point to UTXOs and provide a signature or a witness script
to solve them, and with that, proving that you have the ability to spend them,
which is used for proving that you own a certain amount, or that you haven't
spent something, or for exchanges to do with actual proof-of-reserve stuff.
Although I don't know if any of the exchanges actually use this protocol.
There, a remaining issue was that information about the UTXOs was not part of
the signature.  So, you, as a validator, you had to fetch the UTXO set, or be
able to get access to it, to be able to even cryptographically verify without
telling that it's spent or not.  Just even verifying the signature required you
to be online, and that is not super-practical.  So, I decided to propose turning
the signature into a PSBT because a PSBT can hold that information that is
required.  So, long story short, proof-of-fund variant now is a full PSBT
instead of just a signature.  And that at least allows a verifier to verify the
witness stack offline.  And then, only if they require to find out if the UTXO
is still unspent, then have to query the blockchain or the mempool, or whatever.
But at least you can verify the signature offline.

Oh, yeah, and what was also missing was just the process, how would you go ahead
and create the valid signature for a multisig address, maybe using cold storage
devices?  Would you use PSBT?  How would the flow look like?  And I described a
proposed flow as well so that hardware wallet manufacturers can easily implement
it in their software and know how it should behave and what format should
follow.

Then last, there were some just text clarifications on what the BIP is supposed
and not supposed to be able to prove.  So, there was a lot of discussion around,
yeah, can you even prove that you own something or not own something?  And so, I
just rounded off the wording there to make it clear what the purpose is and what
definitely isn't list of purpose.  I guess that's it, or did I forget anything,
Murch?

**Mark Erhardt**: Did you talk about what the situation was before this was
updated and completed?  You talked very briefly about the history.  So, maybe
just for context, that there was a signing format, but it only existed for P2PK
and P2PKH, so the legacy style addresses.  And then, with new output types
coming out over the years, people were coming up with workarounds like, "Oh,
I'll sign with the key in a P2PKH, but actually my output script is a different
one", or they implemented some variants of 322 that they came up with themselves
that weren't documented.  And then, I think there, we found out meanwhile that
COLDCARD had implemented 322 earlier this year, but so far 322 had had very
little adoption otherwise, as far as we know.  And so, there were just too many
open questions, or the format was maybe a little underspecified in some aspects.
So, now that it is rounded out and completed, the controversy still exists.
Obviously, some people were very against this, because it would enable more KYC.
But clearly there's demand for it in some ways, like people trying to prove
funds before they participate in multiuser constructions or Lightning channels
or proof of funds, and so forth.  So, as many tools, it's a double-edged sword.
You can do useful stuff with it, but it might also get used for stuff that we
are not so fond of.

So, anyway, with the generic signed message format, you can now sign with any
output script, because you basically just replicate signing for that UTXO, and
thereby you can just sign for anything that you otherwise would be able to sign
for.  So, multisig is covered, taproot is covered, anything where you can spend
funds, you can now also sign for.

**Mike Schmidt**: Murch, you mentioned some stopgaps and some workarounds over
the years that people have put in place.  Actually, one of the software that we
highlight later in the newsletter, I saw one of the features they touted was
support for BIP137.  Are you familiar with that BIP?  And what is its relation
to 322, if at all?  I think it's basically the segwit version of message
signing.  Is that something that's on either Oli or Murch's radar?

**Mark Erhardt**: Is that Steven Roose's?  No, that was 127, right?  Steven
Roose had proposed a different proof-of-funds or proof-of-reserve scheme in 127
before, and signatures of messages using private keys.  I'm not familiar with
137, to be honest.

**Mike Schmidt**: Okay.

**Mark Erhardt**: That was also created in 2019, or something, but it looks
related.

**Mike Schmidt**: Yeah, it was interesting that it had come up later in the
newsletter, and I hadn't seen it, or if I had, I had forgotten about it.  But it
would seem like BIP322 is more comprehensive, in that it covers other address
types, other output types.

**Oliver Gugger**: Yeah, I also didn't come across 137.  I guess one downside,
or I guess disadvantage of BIP322, is that because you can prove any type of
script, you also need a full script interpreter, right?  So, on the validation
side, you need to be able to run the full Bitcoin Script stack-based engine and
signature verification, and that might be a bit heavy for a browser or even a
signing device.  So, there is a downside and 137, because it seems to, from a
quick glance, only do the actual schnorr or ECDSA signature, it's probably
lighter to implement.  But still, BIP322 is also futureproof by its
construction.  It will support any future version of segwit that we might add in
the soft fork later.  So, yeah, it's pros and cons everywhere.

**Mike Schmidt**: Well, I mean that's a huge advantage to being futureproof to
new types, obviously, because like Murch mentioned, the original Bitcoin Core
software or earlier Bitcoin Core software had support for certain address types.
And then there's 137, which seems to have segwit support.  And so, it would be
sort of painful to continuously do this.  And so, 322 is futureproof.  So, I
mean, that's a great benefit.  How's reception been, Oli, from the wider
community?

**Oliver Gugger**: Not too sure.  Nothing negative so far, which is nice.  I
haven't done a lot of research.  I just saw that Sparrow already updated to the
new version, which is awesome.  Interpreting from the message from COLDCARD that
Murch mentioned, I assume they're also upgrading and hopefully add support for
the new version in their next firmware.  I myself created a PR for the BitBox to
implement it, haven't heard anything back there.  Otherwise, not that much
direct response, but I guess it's still early, hasn't happened so long ago.  So,
yeah, but anyone has comments, the mailing list thread is still open.  Yeah, let
me know if you have questions.

**Mark Erhardt**: Maybe then just here another call to action.  So, anyone that
had implemented a scheme for signing for UTXOs in their Bitcoin project, if that
was based on 322, you should probably take a look at this update to see whether
you're still compatible, or whether you want to make updates or leave some
feedback before it's out there too long.  If you have used a different scheme,
we would probably still want to know.  I wasn't particularly aware of other
projects, like 137, apparently.  And yeah, currently it's proposed now, and a
few people have started adopting it.  But if more feedback came in, now would be
the best time before everybody forgets about it and has had it in their projects
for years, and it's always harder to get everybody on the same standard further
down the road.

**Mike Schmidt**: Oli, thanks for joining us.  We appreciate your work on this
and for joining us to speak about it.

**Oliver Gugger**: Yeah, thank you very much, and also for the coverage in the
newsletter.  Cheers.

_TCP hole punching for Bitcoin nodes behind NATs_

**Mike Schmidt**: Next news item, "TCP hole punching for Bitcoin nodes behind
NATs".  0xB10C, you posted to Delving Bitcoin about this idea to help more
Bitcoin nodes behind home routers, for example, to accept inbound connections.
Maybe a good place to start would be you can help us recap for the audience why
are there challenges, and what are they around getting inbound connections to
your node, if you're running at home, for example?

**0xB10C**: Right.  So, currently, I guess we have two types of nodes on the
network.  We have the listening nodes, which are able to receive inbound
connections.  Usually, these are hosted in cloud providers in other houses, and
they don't have a firewall in front of the HTC port.  And mostly, the nodes at
home, the unreachable ones, are behind a router that either blocks the access to
the port by a firewall or because they're behind NAT.  And there have been
discussions and ideas around this for a while.  So, with the release of v30, one
idea to open up more inbound connection slots on home nodes was to make
something called -natpmp=1 by default.  And now, after the release being out for
a little more than half a year, I revisited this, and we were looking at if the
number of reachable nodes in the residential ISPs increased since the release of
v30m so since people have been upgrading.  And by making this a default, the
actual expectation was it would see a big increase in the number if it's
working.  But so far, it hasn't really had the big uptick we had hoped to see.
And this sparked some discussions on other ways we could allow home nodes, nodes
behind the NAT, to have inbound connections.

So, this came up in a discussion while hanging out with a few other Bitcoin
developers a few weeks ago.  And one idea that came up was hole punching.  And
hole punching is a technique that you can use if you're behind a NAT, or if two
people are behind a NAT.  They can coordinate with a third party and from there
can say, "Okay, we open a connection through our NATs at the same time.  And
this tricks our NATs into accepting the package from the other side".  This is
commonly done in UDP protocols, but the Bitcoin traffic we have on the network
right now is not UDP, it's TCP.  So, we first looked into if it's actually
possible on TCP, and it turns out it is, and people are actually doing it.  So,
very roughly, the idea would be, okay, we have two nodes, two home nodes on the
network.  Both are unreachable from the broader internet, but we have some
reachable node somewhere.  So, Alice and Bob are the unreachable ones, and
Charlie is the reachable one.  And for some reason, Alice and Bob connect to
Charlie, and Charlie is able to coordinate between Alice and Bob that they
should open, at a certain time point, these connections to each other, and then
they punch through their home nets and are able to make a connection.

This sniped quite some people, so we had quite some discussion about this in
person, and I posted to Delving to continue the discussion there, and also just
to write down what we have thought about and what could be a potential option
going forward.  But this is very far from having a proposal or a standard.  At
the moment, it's mostly an idea and it's something that is possible, it seems
possible, we've been testing it out in different networks, so different hotel
networks, for example.  Hotel Wi-Fis seem to allow it.  Many people at home said
it's possible for them, or in the office it's possible.  We also got someone to
test it from a plane, so it's possible there.  So, these are places where you
now could accept inbound connections to your nodes.  How that's going to look
like on the implementation side, we don't know yet.  And also, we don't really
know who's going to implement this and what exactly are we going to implement.

**Mike Schmidt**: Makes sense.  0xB10C, maybe just taking a step back, and I'm
sure Murch will get into some of the technicals, which I think are interesting,
but maybe just conceptually, why is an inbound connection desirable, and it's
worth going through these hoops to jump through?

**0xB10C**: Right.  So, each node is making outbound connections, and you need
to have some inbound slots for these available on the network.  And if we don't
have any inbound slots available on the network, we can't make outbound
connections.  So, that's a big reason why we want to have a certain number of
inbound slots available on the network, depending on how many nodes are running,
also depending on how many are offering inbound slots and not.  But inbound
slots are also a limited resource.  You want to limit it for memory reasons and
DoS reasons and bandwidth reasons, and so on.  So, there is a limited number of
these on the network right now.  And if we could have more inbound slots, then
we could make more outbound slots, which would, for example, help with partition
resistance, and so on, on the network, but also just offer better connectivity
across parts of the network that might not be well connected at the moment.

**Mike Schmidt**: Is there a particular industry or type of software that does
this sort of hole punching currently that people could maybe relate to, because
it sort of feels a bit hacky?

**0xB10C**: Yeah.  So, hole punching is quite commonly used in, for example,
one-to-one voice or video chats.  So, that's using UDP.  But it's very commonly
used.  So, one example is, for example, Signal.  If you do a Signal video call
or a Signal voice call, it's probably trying to hole punch.  And if your carrier
or your home browser is allowing it, you have a direct connection to the other
person.  And if hole punching doesn't work, it's using a relay in between.  But
these relays are obviously expensive to run, because they use up quite a bit of
bandwidth and CPU, for example, Signal.  And so, ideally, it's using hole
punching, and I think they have seen quite good numbers.  And in general,
they've seen quite good numbers on hole punching in general.  But I'm not so
sure who is using TCP hole punching.  There are some projects using it, there is
a big library using it, but I haven't dug into who exactly this is and what for.

**Mike Schmidt**: So, even though we're, I think you used the phrase, 'tricking'
these firewalls or these routers, this isn't some obscure technique.  Signal and
others are using it.

**0xB10C**: Right, yeah, we're not coming up with this on our own.  There's
other people.  I think there's actually at least some parts of this are
documented in RC or so, but obviously not all routers support it, depending on
how they configure their NAT.

**Mike Schmidt**: Murch, have you been following along with these conversations?

**Mark Erhardt**: Just a little bit.  I mean, I wanted to expand a little bit on
the inbound slots issue.  So, our nodes by default are listening, but not all of
them, of course, are reachable from the open internet.  And we make eight
outbound connections by default.  So, every full node tries to pick eight peers
to download new blocks from, and picks them themselves.  But then, for example,
a lot of the light clients, other projects, not Bitcoin Core, they only consume,
they don't actually provide inbound slots themselves.  So, we allow up to 115
inbound slots.  So, if you are a listening node and reachable from the open
internet, you will provide these inbound slots where light clients and other
software can get information about the current state of the Bitcoin Network.

So, if we want as many people as possible to be (a) running their own nodes, and
(b) as well connected as possible, the eight outbounds, they just take slots
away from the available slots.  And if the more nodes we can get to add inbound
capacity from there, the better connected the network will be.  So, if we had a
way of getting a node that is about to kick off some inbound connections because
they're getting new connections, to instead hand them off to each other and make
a match between them so that they have a pseudo inbound connection, which they
usually wouldn't be able to do by themselves, we would be able to interconnect
the network better and give these nodes more connectivity without using slots
from the listening nodes.  So, yeah, that was basically the idea.  Let's say you
have 115 inbounds already, someone connects to you and it would kick someone
else off.  What if you just connect those to the one that you would be kicking
off and the new connection to each other, or something like that?  That's just
more in the background.

**0xB10C**: I think that's one of the ideas that we were thinking about making
this work.  So, there could be some handoff going on.  So, if two nodes connect
to Alice, Alice could say, "Okay, I'm actually full, I'm going to hand this
off".  But we also have been thinking about different ways.  So, there could
also be a matchmaker node who is just responsible to matchmake two peers that
are actually looking for this hole punch inbound and outbound connections.  And
there has been some discussion on making this a coordinator-less or like a
coordinator light version of this, so maybe going through Tor and coordinating
on a Tor endpoint which might be reachable, or which is reachable on the Tor
network, to get rid of this third party in the middle.  And also, there have
been some questions on how malicious can the third party be and what can it do
to break this?  Could it only give you connections to maybe some kind of spy
node entity or so?  Or could it filter out certain IP addresses so you never
hear about these IP addresses you might want to connect to?  But that's all
still ongoing.

**Mike Schmidt**: It sounds like this is a newish idea, there's some prototyping
going on.  I suspect Optech listeners, there are probably a handful of
networking nerds that might be interested in this topic.  0xB10C, where can
people follow along with helping to build this idea and contribute to the
prototype, or test on their particular network or machine, or whatever?  Where
can they follow along?

**0xB10C**: So, I guess the best option is the Delving thread.  There is some
work done by sipa.  He built like a chat server.  There's also some tooling for
testing if your home router supports this, or your VPN supports this, or your
whatever company network would support this.  And posting information about this
would be interesting, especially from different vantage points.  And there has
been some work, so for example, Will Clark posted about testing with a sidecar
for Bitcoin Core.  That's basically like a separate process that manages this
hole punching.  So, the implementation in this version isn't in Bitcoin Core
itself, but in a third-party sidecar that you run alongside it, just to figure
out if it's working and what's working and how successful it can be with this.
But yeah, most of the discussion is happening in the thread by now.  There is no
other place, no issue, no repository yet.

**Mike Schmidt**: Okay, listeners, check out the Delving thread if you're
curious about this.  This seems like an interesting place to tinker and help
provide feedback.  And it's very early in the idea stages, so it sounds like
feedback is welcome.  So, anything else, 0xB10C, before we move along in the
newsletter?

**0xB10C**: Nope.

_peer-observer P2P monitoring tooling_

**Mike Schmidt**: Okay, great.  Well, that wraps up the News, but we also have
0xB10C and some of his work highlighted in the Changes to services and client
software segment, our monthly segment.  So, we'll jump a bit out of order and
cover, "peer-observer, P2P monitoring tooling".  And 0xB10C, you posted again on
Delving, I think it was an update to a thread that we've covered previously,
outlining some of the open-source components behind your peer-observer platform.
And I thought that it was worth highlighting here, even though maybe those
pieces aren't downloadable and executable pieces of software like some of these
other pieces, like wallet software, and whatnot.  I thought it would be
appropriate for this audience to highlight those.  Maybe you can just remind
everybody what peer-observer is as a broader platform, and then maybe you'd like
to highlight a couple of components that you called out in your post that could
be interesting for the audience?

**0xB10C**: All right.  So, peer-observer is a monitoring tool, and the idea is
you're attached to different interfaces of the Bitcoin Core node, and you can
monitor for attacks and anomalies on the network that reach your node.  And as a
part of the broader peer-observer platform, I run a bunch of honeypot nodes that
I hope people connect to and do funny stuff with, but I'm not publishing the IP
addresses.  So, the hope is that an attacker would connect to this, or these
nodes would run in a configuration where they see some kind of anomaly
happening.  And anomalies are usually bugs that we might want to fix and have
data on.  And so, what the peer-observer tooling does and the extractor does is
it connects to a bunch of interfaces.  So, for example, it connects to the node
via the tracing interface, but also via the P2P interface.  It reads from log
messages, so a log interface.  And obviously, the RPC interface is being used a
bunch.  And recently, we added support for something called an IPC extractor,
which is in the very early stages, but it reads from the IPC interface.

All these extractors collect events, and these events are passed into a big
message bus and can, on the other side, be processed by different toolings.  And
so, one tooling is, for example, just showing metrics on the Grafana dashboard
for a bunch of events.  But recently, we also have been working on something
called an archiver that archives all of these events to disk for long-term
storage, and there has been some work going on there.  And also, in general,
improving anomaly detection here and there, making it more automatic, but also
having some predefined sets of heuristics that we want to alert on.  So, there's
an alerts tool that's using metrics we've previously been thinking about and
saying, "Hey, if this happens in the network or on the node, that would be
interesting to alert on".

There has been a bunch of work going into this.  I've been seeing a bunch of new
contributors coming online and helping out with this.  So, I'm quite happy with
the progress here and there.

**Mike Schmidt**: Great.  So, if listeners need to, I guess, reuse any of those
components, this is all open source, right, 0xB10C, so these extractors for the
different interfaces, the work on archiving that information, and then you
mentioned heuristics and dashboards.  I think it would be interesting for
listeners to pursue just contributing to some of your efforts more broadly.  But
obviously, if they have projects that they're working on that may necessitate
any of those components, they can grab that open-source code as well.

**0xB10C**: Right.  And everything is open source.  It's on
github.com/peer-observer, and there is code for running the infrastructure, and
there is code for these tools and extractors.  And there is also a demo
infrastructure that is public for anyone to explore.  Obviously, these node IP
addresses are public, and so people might mess with them or they might not mess
with them.  And on the infrastructure side, we also have been working on, for
example, doing some continuous profiling on these nodes, so we can actually see
in which areas of the Bitcoin Core codebase the node is spending most of its CPU
time in, which is, for example, very helpful if you want to detect DoS attacks
on these nodes as well.

**Mike Schmidt**: Maybe you can tie this work into what you mentioned, I think,
in your introduction, which is your open collective, BNOC, and what you guys are
doing there?

**0xB10C**: Yeah, right.  So, I've started something called the Bitcoin Network
Operations Collective.  Currently, that's primarily a forum on bnoc.xyz, and
there is a bunch of discussion about people making observations of the network,
posts about, like, "Today I saw this", and then other people may chime in and
say, "Oh, yeah, I saw this with my node as well", or, "Yeah, I've been seeing
this for the last two years", and so on.  But there's also some data sharing
with researchers going on.  So, recently we got a data share and we've been
uploading stuff here and there and sharing it with researchers.  So, one use of
the forum is as well to go there and say, "Hey, I actually have some data I can
give away for others", or, "I want to have some data from someone and I don't
know who exactly has this data", but maybe someone will see the post and comment
there, and stuff like this.

So, the idea is to have some kind of collective that's taking care of what's
happening on the network, similar to what maybe a network operations center
would do in a company.  But yeah, we're not really a company in Bitcoin
open-source development.  So, it's more like a collective of people coming
together from various places in the world and companies.

**Mike Schmidt**: So, if listeners want to be a Bitcoin Network watchdog, you
all should check out what 0xB10C is up to with BNOC.  And even if you're not, I
think there's been some interesting discussions surfaced there recently, so
encourage folks to check that out.  Anything else, 0xB10C?

**0xB10C**: I think that's it.  Thank you for having me.

**Mike Schmidt**: Okay.  Thanks for joining us, 0xB10C.  Cheers.

**0xB10C**: Yes, thank you.  Bye.

_Ibis Wallet announced_

**Mike Schmidt**: Back up to the first item from the Changes to services and
client software, is Ibis Wallet being announced.  This is a new Android wallet.
It supports a bunch of Bitcoin Optech goodies, coin control, fee management
using RBF and CPFP, there's Tor integration, silent payments, some silent
payment support, hardware device signing, multisig, I think they're
multi-wallet.  We talked about BIP137 earlier, which was interesting.  And also,
this wallet supports second layers in sort of an opt-in way.  So, turn on and
off things like Spark, Liquid, and Ark.  There is not native Lightning support,
but it's provided BOLT11 and BOLT12 support through its Liquid and Spark
integrations.

_LDK Server announced_

**Mike Schmidt**: Next piece of software we highlighted was LDK Server being
announced.  Spiral, and I think benthecarman in Las Vegas, announced LDK Server,
which is an API-first Lightning node built on LDK Node, which itself is sort of
an abstraction over LDK library.  And so, they're calling this LDK Server, and
it's meant to be sort of API-first.  So, this is things like gRPC, it uses MCP
(Model Context Protocol) for AI integrations for folks doing AI stuff with
Lightning.  And then, behind the scenes, there's a BDK embedded wallet as well.
I think there are some slides and maybe some posts on this.  So, if folks are
curious, they can check that out.

_Mempool.space v3.3.0 released_

**Mike Schmidt**: And our last piece of software is mempool.space v3.3.0 being
released.  There is a slew of features.  We pulled out a few that we highlighted
here.  There's some visualizations for taproot script trees, so you can actually
visualize some of what we talk about when we're talking about tapscript tree
structures; updated PSBT previews; there's improved fee estimation; ephemeral
dust support; there's interesting sighash icons now, so you can sort of visually
identify the sighash; there's stale block comparisons, which is helpful for
understanding what happened maybe during a block race; and I think I mentioned
ephemeral dust, but ephemeral dust support as well.  And like I said, if you
check out the release notes and some of the details there on their GitHub, you
can see there's a bunch of stuff that went into this release.  So, pretty cool.

We did not have any Releases or release candidates this week.  So, we jump right
to the Notable code and documentation changes.  And I'll hand off to Gustavo,
who was the author of this segment.  Hey, Gustavo.

_Bitcoin Core #29136_

**Gustavo Flores Echaiz**: Hey, Mike, thank you so much for the intro.  So, we
start this week with five different items from the Bitcoin Core repository.  The
first one and the most significant is the addition of a new RPC command called
addhdkey, that allows you to import or generate one if you don't specify one to
import, a BIP32 extended private key.  However, it won't be used to produce any
output scripts.  So, for example, if you wanted to add BIP32 extend private key
for later use, such as in a collaborative multisig script, but you don't want to
immediately generate addresses from it, you would use this RPC command.  What is
useful about it is that when you export through listdescriptors RPC command,
when you want to export all the descriptors and the keys from your wallet, this
new key will appear through a new descriptor type called unused(KEY), so you can
say back up this key that is unused for now that could later be used.  Yes,
Murch?

**Mark Erhardt**: Just to be clear, I think listdescriptors by default does not
list the private key, or listdescriptors in the most common use would only tell
you about the descriptors and their public descriptor portion.  If you want the
private keys, I think there's a flag, and for backing up keys, just back up the
wallet file.  That's the Bitcoin Core idea, at least.

**Gustavo Flores Echaiz**: Right.  Thank you for specifying that.  And yeah, I
believe it's the internal flag that is used if you want to expose the internal
or external descriptors, but I'm not 100% sure there.

**Mark Erhardt**: Internal and external refers to whether it's a receive address
descriptor or a change output descriptor.  So, Bitcoin Core's wallet has a bit
of an interesting design there.  We have slots by address type.  So, whenever
you have a descriptor that fits into a slot, for example your P2TR slot, you
will only have one of those P2TR descriptors be the active descriptor.  So,
usually when you add a new descriptor for P2TR, you can specify that it becomes
the active one.  And then, when you do getnewaddress P2TR, it'll give you new
addresses from that descriptor.  But you can have any number of descriptors in a
wallet.  So, sometimes you might need to find out, "Okay, which descriptors did
I have?", and listdescriptors will give you a description of all of the
descriptors.  And so, this unused(KEY), for example, would show up if you create
one to set up a multisig descriptor or a watch-only wallet, or something like
that; It would show up as an unused(KEY).  Internal or external refers to a
change output or receive an address type.

**Gustavo Flores Echaiz**: Understood.  Okay, so I just checked.  So, yeah,
there's a private flag that you could use if you wanted to expose the private
descriptors.  And also, this new key added to this RPC command would show up
when using the gethdkeys command separately, that also has an option for
retrieving private or non-private keys.  Perfect.  Thank you, Murch, for adding
that extra context.

_Bitcoin Core #34893_

**Gustavo Flores Echaiz**: So, we move forward with Bitcoin Core #34893, which
updates the RPC command called combinepsbt, so that it properly preserves BIP174
proprietary fields.  So, when combining PSBTs, previously this command would
silently drop the proprietary fields without displaying that this had happened.
However, decodepsbt was properly handling, parsing, and serializing those
fields, so you could expect that combinepsbt was following the same logic as
decode, but it wasn't.  So, now, it will make sure to always preserve those
fields and not drop them silently.

_Bitcoin Core #34860_

**Gustavo Flores Echaiz**: So, another item from the Bitcoin Core repo #34860,
this one is a bit of a long story.  So, in short, the option called
include_dummy_extranonce is now dropped from the CreateNewBlock() method.  What
does this mean and what is this related to?  So, in Newsletter #392, we covered
the addition of this option.  And the problem there the goal was to solve for,
when an IPC client connects to Bitcoin Core and he wants to obtain the coinbase
transaction, Bitcoin Core could hand the coinbase transaction with a dummy
extraNonce it had added.  And those dummy extraNonces are added at heights 0 to
16 to satisfy a consensus rule related to the scriptSig length in coinbase
transactions, that at heights 0 to 16 requires an extra dummy extraNonce.

So, in Newsletter #392, we covered that Bitcoin Core #32420 had added an option
called include_dummy_extranonce that was set to false by default in the IPC
codepath, so that when an IPC client requested a coinbase transaction, it would
not include that dummy extraNonce.  So, an IPC client wouldn't have to
unnecessarily receive that data and then strip or ignore that data.  And it
seemed fine.  However, it wasn't the proper solution.  The proper solution was
to always append a dummy padding or that dummy extraNonce at heights 0 through
16 and never after the height 16, and to never expose as well that extra padding
in the getCoinbaseTx() endpoint that was exposed to IPC clients.  So, instead of
having an internal option that could either be set to true, and if it was set to
true, this padding would get added at any height, and if it was set to false, it
would never get added, instead of having this option that would either make it
true or false at all heights, now Bitcoin Core has updated its internal logic to
completely remove this option, only apply the padding when needed, which is
block heights 0 to 16, and never expose it through the getCoinbaseTx() endpoint.
However, an IPC client that calls getblock will receive the full block and if
it's at high 0 to 16, it will have that extra dummy padding in that coinbase
transaction.

**Mark Erhardt**: I think if we zoom out a little bit, the important part is the
scriptSig field, or also called the coinbase field in the transactions that
generate the block reward, has a minimum of 2 bytes' length, just 2 bytes.  So,
in order to have at least 2 bytes, you have to put first the height of the block
in this field.  And now, if you start a new blockchain, for example, on regtest
or your own signet, or maybe another testnet or something, or your own shitcoin
that is forked from Bitcoin Core's codebase, on the first 16 blocks, or rather
before the 16th block, 15 encoded as hex will take fewer than 1.  Or I guess
starting with 16 bytes, it's at least 2 bytes, right?  And you will naturally
have a minimum length, the minimum length that is required for your scriptSig.
Before block 16, you would not have the minimum length, and that's why you need
the padding.

I think the point here was that it didn't make sense for the user to need to be
aware of that.  If this is the case every time for these blocks, let's just
automatically generate the padding and then not generate the padding after that.
I think that's the summary.

**Gustavo Flores Echaiz**: Yeah, that's the summary.  Thank you for taking a
step back and presenting it in a different manner.  So, yeah, just to clarify as
well that if you're using the Mining IPC interface, you will not get that
internal padding when fetching a coinbase transaction when you fetch the
coinbase transaction by itself, even at those heights.  However, when you fetch
the full block at height 0, it will appear.  If it includes the dummy padding at
height 0 through 16, it will be included, but not after those heights.

_Bitcoin Core #31298_

**Gustavo Flores Echaiz**: So now, the next item is Bitcoin Core #31298.  Here,
another RPC command is updated, called combinerawtransaction, where if you're
trying to combine or merge two unrelated transactions, it will now throw an
error indicating that these transactions do not match.  Previously, you were not
getting an error if the transactions were unrelated, only the first one of the
two unrelated transactions you were trying to merge would get returned, and it
would simply ignore the second one.  Now instead, you've got the proper
behavior, where you get told that these transactions don't match because Bitcoin
Core has compared the resulting unsigned transactions' hashes after stripping
the scriptSigs and the witnesses from each transaction.  Bitcoin Core can tell
whether there's an error, they don't match, and it will properly surface that
error to you.  Yes, something you guys want to add?

**Mark Erhardt**: Yeah, I was just wondering, do you know, is combineraw used
during combining PSBTs, or is it sort of a predecessor to PSBTs?  Like, you
would have two raw transactions where someone had signed the first input on one
and someone had signed the second input on the other.  And with
combinerawtransaction, you can generate a single raw transaction that has both
signatures.  That's how I interpret it from your description.

**Gustavo Flores Echaiz**: Yes, that's it.  It's related in the sense that they
work similarly, but they are two transaction types.  So, it's not a PSBT type,
it's just a hex legacy transaction type.

**Mark Erhardt**: Yeah, sure.  But it's sort of the predecessor to PSBT in, how
do you generate a transaction with multiple users, and how do you get all the
information then into a single transaction?  You could do this manually, of
course, if you know exactly what bytes to cut and paste, but obviously that is a
lot more effort and more complicated.  So, this RPC takes two partially-signed
raw transactions, not PSBTs, and would take the signatures from all of them and
maybe other fields that can be picked by the signers, like the nSequence, and
combine them to one construct.  And so, it sounds like it was buggy.  If you
handed it two unrelated transactions, it would just return the first one because
there was nothing to combine.  But now, much more appropriately, it fails
because the two transactions cannot be combined.  And if you call a function
called combine and it can't combine stuff, then it should throw an error rather
than just return the first one.

_Bitcoin Core #28802_

**Gustavo Flores Echaiz**: That's exactly it.  So, next item #28802.  This is
the last one from Bitcoin Core.  We are adding support for command-specific
options to the ArgsManager, Bitcoin Core's CLI arguments parser and manager.
So, previously, if options were not declared to specific commands, now they are.
So, for example, this PR first builds the structure to add support for
command-specific options, but also applies it to bitcoin-wallet's -dumpfile
option, which is now registered only for the dump and createfromdump commands.
So, for example, if you try to apply this -dumpfile option when using other
commands, it will understand that -dumpfile is registered only for dump and
createfromdump commands, so it will naturally return the correct message,
indicating that this option only applies to these commands.

So, now, ArgsManager, the Bitcoin Core's CLI argument parser can list the
specific options that are registered for the commands.  So, if you, for example,
use the CLI and you want the help output, it will let you know what options
apply for these specific commands.  And before, it would have a more general
approach; now we have a more granular approach.

_Eclair #3298_

**Gustavo Flores Echaiz**: So, the next item, Eclair #3298, is highly related to
things we've discussed in Newsletter #400 and Newsletter #404.  So, in
Newsletter #400, we covered that LDK updated its internal RBF logic to be not
only compliant with the BOLT2 rule around the increase of fees when replacing a
transaction, but also with BIP125 replacement rules that specifically targets
very low feerates.  So, if you were only following BOLT2's rule that says that
you have to multiply by 25/24, which is about you have to add a 4% increase to
your fee at very low feerates, that could fail to comply with BIP125's rule,
which is applied by Bitcoin Core's relay policy.  So, that happened in
Newsletter #400 for LDK.  Then, in Newsletter #404, it got updated at the BOLT
specification level.  So, now Eclair is updating its internal logic to also
comply with that specific rule.  And that is first to comply with, like I said,
Lightning specification, but also ensure that the transaction relays properly.

I would also add, because you made some comments about this, Murch, in previous
newsletters, so I wanted to circle back on this, this kind of ignores the
absolute fee rule that if, let's say, you were to increase the transaction size,
you also have to increase the absolute fee, not just the relative fee.  So, this
doesn't really talk about that, neither at the specification level nor the
implementation level.  But it is kind of implied that you would have to ensure
that your transaction properly relays and not only follows Lightning-level
rules, but also relay-level rules.  Yes, Murch?

**Mark Erhardt**: I think actually the issue appears when you make the
transaction smaller.  If you replace an original transaction that is bigger with
a smaller transaction, you might even increase the feerate, but you would
potentially end up with a smaller absolute fee.  And Bitcoin Core requires you
to both increase the absolute fee and the feerate.  So, in this case, you would
potentially underpay and it would not propagate.

**Gustavo Flores Echaiz**: Understood, okay.  Thank you for specifying that.
But yeah, I wanted to say that there's nothing about this that talks about that,
but it is kind of implied that you would have to comply to ensure that your
transaction gets relayed.

_LDK #4575_

**Gustavo Flores Echaiz**: Now, we have two more from the Lightning
specifications.  So, the next one is from the LDK repository #4575.  Here, a new
API endpoint called splice_in_inputs is added to allow you to manually select
UTXOs when splicing funds into a channel.  So, it was previously not possible to
manually select UTXOs.  You would have to enter an amount that you want to
splice-in, and LDK would automatically select those UTXOs.  Now, you can
manually select UTXOs.  However, the requirement is that the selected UTXOs will
be fully consumed with their value, minus obviously the transaction fee, but all
their value will get added to the channel and no change output will be created.
So, now you can have those two different methods for splicing in funds.
However, they cannot be combined or mixed, so you either have to choose one or
the other when splicing in funds using LDK.

_LND #10814_

**Gustavo Flores Echaiz**: And the next item is an item that we can surface very
quickly, because it simply removes some endpoints that had been deprecated way
earlier.  So, in Newsletter #340, we covered how LND had moved from V1 endpoints
to V2 endpoints, specifically endpoints related to sending payments,
SendToRoutes, SendPayment, and TrackPayment as well.  So, now users are not only
encouraged to migrate to the new V2 methods, but they're kind of forced because
they're going to be deleted in the next version.  However, this had been
deprecated for multiple releases already.  We covered it initially, like I said,
in Newsletter #340 in February 2025, but now they will be fully removed.
Another one that had been previously deprecated and is now removed, is the
single-channel outgoing-chan-id field, that now is called outgoing-chan-ids.
So, it now implies multi-channels instead of single channels.

_Rust Bitcoin #6191_

**Gustavo Flores Echaiz**: And finally, we've got Rust Bitcoin #6191.  So, here,
there's support being added for encoding and decoding P2P messages, called
sendtxrcncl.  These are used in the Erlay protocol and the same support had been
added to Bitcoin Core way earlier.  We covered that in Newsletter #223, so that
was October 2022.  So, now Rust Bitcoin has parity with Bitcoin Core to be able
to encode and decode these messages.  However, this doesn't mean that Erlay
transaction reconciliation support is implemented.  This is simply a first step
that now Rust Bitcoin has done and Bitcoin Core as well.  But none of those have
added additional support for the Erlay protocol.  And just to add that the Erlay
protocol is a proposal to improve the bandwidth efficiency of relaying
unconfirmed transactions between Bitcoin full nodes.  And I believe a simple
idea is simply for nodes to reconcile what unconfirmed transactions they have
already received in order to ensure that you don't send a transaction to a peer
that already has it.

**Mark Erhardt**: Yeah, it just reconciles the send queues between two nodes as
to the reconciliation is on the list of things they would be sending to each
other.

_BLIPs #42_

**Gustavo Flores Echaiz**: Precisely.  And the final item is in the BLIPs
repository, we have PR #42, which adds BLIP42, also the same number, which is
the specification for BOLT12 contacts.  So, because BOLT12 offers are reusable
payment instructions, they can be stored within wallets as contacts.  So, the
main goal here is to define a new field that payers can include when making a
payment, that basically includes their contact secret, their own offer, or a
BIP353 human-readable name that abstracts their BOLT12 offer.  The protocol also
specifies how wallets should implement the contacts related to this protocol,
but it mostly centers around the field that the payer includes when making a
payment to basically display their contact information, so receivers can add
them as contact and later pay them back.  But yeah, like I said, wallet behavior
around contacts is also minimally defined.  And that is the last item from this
section, and that covers the whole newsletter.

**Mike Schmidt**: Great.  Thanks, Gustavo.  We also want to thank our guests
earlier, Oliver and 0xB10C, who joined us this week.  And also want to thank
Murch and you all for listening.  We'll hear you next week.  Cheers.

{% include references.md %}
