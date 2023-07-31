---
title: 'Bitcoin Optech Newsletter #260 Recap Podcast'
permalink: /en/podcast/2023/07/20/
reference: /en/newsletters/2023/07/19/
name: 2023-07-19-recap
slug: 2023-07-19-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao, Rearden Code, Ken Sedgwick, and Jack Ronaldi to discuss [Newsletter #260]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-6-20/340050581-22050-1-ad2f4dffcb391.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome, everybody.  Bitcoin Optech Newsletter #260 Recap on
Twitter Spaces.  It's Thursday, July 20, and we have a great newsletter again
this week.  We're going to be wrapping up our series on waiting for
confirmation, so we have Gloria as a guest to come by and talk about that one
last time; we have a pretty strong section of updates to client and service
software that we'll be going through, and we have a few guests that'll talk
through that; and then we also have a few different PRs, Bitcoin Core, Core
Lightning, LND, and libsecp that we'll be getting through.  Introductions, I'm
Mike Schmidt, I'm a contributor at Bitcoin Optech and also Executive Director at
Brink, funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch.

**Mike Schmidt**: That's the shortest one yet!  Gloria?

**Gloria Zhao**: Hi.  Just kidding, wanted to beat Murch.  I'm Gloria, I work on
Bitcoin Core at Brink.

**Mike Schmidt**: Jack, do you want to introduce yourself and give a bit of
background?

**Jack Ronaldi**: Sure.  So, my name is Jack Ronaldi.  I'm the product manager
for the Validating Lightning Signer Project, which is separating your Lightning
keys from your Lightning node.  And Ken should be joining us soon to chat about
the details.

**Mike Schmidt**: Jack, do you also want to plug the product community?

**Jack Ronaldi**: Sure, yeah, so I'm also part of the Bitcoin Product Community,
which is a group of Bitcoiners, or I guess anyone interested in working in
product in Bitcoin, whether that's product management, product design, or
building any kind of product.  So, join us on Discord, and you can find us on
Twitter as well.  Pretty fun, and learning a lot from like-minded Bitcoiners.

**Mike Schmidt**: Thanks for joining us, Jack.  I've shared a few tweets in the
Space.  If you want to follow along, we're just going to go through the
newsletter sequentially.  There wasn't any significant news from the mailing
list this week, so we'll jump into our limited weekly series, of which we've hit
our limit now.

_Waiting for confirmation #10: Get Involved_

We're at Waiting for confirmation #10, titled Get Involved.  And before we jump
into the details here, I just wanted to thank both Murch and Gloria for taking
the time out of their busy schedules to not only come up with the idea for the
series, but both of them together, to author all ten weeks back-to-back.  It's
quite grueling going through that every week, I'm sure, on top of a full
workload of other work, and then Gloria also joining us on these Twitter Spaces
to explain a lot of these ideas.  So, not only do I want to thank you for your
time, but I think that the output is valuable.  So, thank you both.

**Gloria Zhao**: Well, thank you to Optech for letting us write all over the
newsletters for the past ten weeks.  It's been a huge honor to have so much
space on, you know, if it was a printed thing.

**Mark Erhardt**: Yeah, and thanks to Gloria who had the idea and did probably
most of the work!

**Gloria Zhao**: Yeah, I don't know, this last post is kind of just a summary of
a lot of the central themes that we wrote about over the past nine weeks before
that.  This kind of came about when Murch and I were talking in the Chaincode
office and I was kind of ranting where I feel like people sleep on mempool and
P2P stuff all the time, and there's all this like buzz about soft forks and
they'll be like, "Oh, you guys do amazing things like covenants and vaults and
all these things".  And then you'll see in the papers that people write, "Oh
yeah, by the way, this needs package relay".  I'm like, "Wow, we need people to
make that happen as well".  And so this is kind of like a recruiting effort/hope
to nerd-snipe some people who are really smart and can dig really deep on the
different soft forks out there, but could also maybe turn their attention
towards some of the very interesting things going on in mempool.  Yeah,
hopefully, maybe, someone's interested.

If you read the series and got interested, please feel free to message me.
Always looking for mempool people to work on Bitcoin Core.  But yeah, I think
that's all I wanted to say with this is, is mempool is responsible for a lot of
important functionality of a Bitcoin node, as well as responsible for many
headaches of developers and users, and we can change that if we work together.
Murch, do you want to say anything?

**Mike Schmidt**: Gloria, I saw your post, I think it was yesterday, your spicy
take that soft forks are overrated and interesting stuff is in the P2P Network.
And I guess that's part of the motivation there, is to maybe draw some developer
and technical expertise towards not only just evaluating interesting and
potentially sexy soft forks, but also some of the stuff that's going on with
policy and P2P and mempool.

**Gloria Zhao**: Yeah.  Yeah, I also just recommend it as maybe a different way
of looking at how cool the Bitcoin Network is.  I think there's a lot of really
interesting ideas introduced by Bitcoin and a lot of really interesting
technical pieces of it.  But again, I think people kind of take the
decentralized structure of it for granted a little bit.  Of course, there are
plenty of crypto projects where they're structured as decentralized, as in they
have a P2P Network, but that's also created by -- there's a lot of design
decisions that go into, okay, ultimately our goal is to have tens of thousands
or hundreds of thousands of independent, anonymous entities running these nodes,
not just the same guys spitting up some in AWS us-central-1 and some in asia-2;
that's not quite decentralization.

It ends up being these very interesting trade-offs that you have where you're
like, "All right, we only get 300 MB.  What's the best we can do with this data
structure?  We have to make sure it's really cheap.  We have to make sure it's
very efficient and it's defensive against attacks, and it also can't censor".
There's all these very interesting, technical challenges when you're trying to
design this piece of software that is hopefully accessible by lots and lots of
people around the world to run.  So, I don't know, I find mempool very
interesting, mempool and P2P, and hopefully other people do too.

**Mike Schmidt**: Murch, Gloria mentioned a couple of things there that could be
something that would be looking for a takeaway from the community from this
series.  One thing that I heard was trying to draw technical talent to some of
the interesting research and coding that may go into existing policy or new
policy changes.  And another thing is just maybe broader community awareness of
what goes into P2P and policy.  What's something that you would hope that the
community takes away from this series; I assume you echo both of those
sentiments?

**Mark Erhardt**: Yeah, those and I think we had multiple interesting debates in
the past year, one-and-a-half years, where mempool played a crucial role and it
sort of showed that very many people don't have a deep understanding of how
mempool fits together, what it all does under the hood, what the design concerns
are, and just how difficult it is to collaborate in a space where you have
absolutely no information about the other nodes, whether they might be malicious
or collaborating with you, and you have to be ready for all of those things and
be able to handle them.  So, I think it also is meant to just help people get an
appreciation and understanding of how things fit together and what the mempool
all does under the hood, what mempool policy does for us, and why those things
might be a little more important than just, "Well, we would like to have bigger
inscriptions, so could you please drop all standardness rules?"

**Mike Schmidt**: Gloria, maybe this is an opportunity that's not directly
related to the Waiting for confirmation series, although I think we touched on
some of it, but maybe you can let folks know, what will you be working on this
next year that isn't writing a mempool and policy series for Optech?

**Gloria Zhao**: Like everything?  Like, a standup?

**Mike Schmidt**: Well, maybe some of the big pieces potentially related to some
of the policy stuff we're talking about.

**Gloria Zhao**: I'm trying to get package relay done as soon as I can.  It's so
much harder than one would imagine.  Shout out to Greg, who's on this Spaces.
Hi, Greg.  Thank you so much for helping me with that.  And then the v3
proposal.  Both of these are mentioned in post #9, I think.  I'm also going to
shill a Bitcoin Core PR Review club, it's bitcoincore.reviews.  We're kind of
doing a revamp to try to give it some new life.  We are going to do meetings
every month to talk about a big-ish PR and all of the surrounding areas, the
codebase areas that it's touching, in an effort to help people learn more about
the codebase, learn how to review PRs, what to look out for, what are some
pitfalls, reviewing with a kind of security mindset, and hopefully recruit some
new talent.  So, yeah, bitcoincore.reviews.  That's most of what I'm doing, I'm
going to review some PRs.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: Yeah, I wanted to mention, because it's been alluded to but
not really said out loudly; so, Gloria has been working on package relay and the
related topics for, I don't know, something like over two-and-a-half years now.
And one of the things that is happening there is that it's a focus of the
Bitcoin Core project, this release cycle, and we talk about that every week in
the Bitcoin Core meeting and those PRs are looking for reviewers.  Now, that
might not be a topic where you can just jump in from one moment to the next and
give good feedback, but if this is interesting to you because, for example, you
work on a second-layer network or because you have a company that depends on
chaining transactions and you would like to have better reliability for RBF or
similar things, you should perhaps try to keep abreast of what's happening
there, and if you can, contribute some reviewing resources or input, feedback,
and review.

So, hopefully this is going to make some more strides with the next release and
can get out in this or the next release after.  But yeah, more review could be
used on our big projects and Bitcoin Core, including package relay, package RBF,
v3 transactions, that sort of stuff.  Gloria, Murch, any final words to wrap up
this post in the series?

**Mark Erhardt**: Let's never do it again!

**Mike Schmidt**: That's the spirit!

**Mark Erhardt**: No, it was great, but it was a lot of work.

**Gloria Zhao**: Yeah, sorry for roping you into it, but I'm very, very proud of
the work that we've done.  It's 8,000-something words.  It's fun, it's been
good.

**Mark Erhardt**: Well, actually I do hope that now that we've written it all
up, it becomes sort of a standard page to link people to that want to learn
about the topic.  And there's a bunch of different topics wrapped all up in
that.  We do have a topic -- or not a topic page, a page that collects the whole
series.  So, I think I've seen it linked on Twitter recently.  Yeah, so if you
want to learn about mempool, we do have a long page now that describes a lot of
aspects of it that we can link to.  So, that's great.

**Mike Schmidt**: Thanks again for both of your time on the series.  We'll move
along in the newsletter to Changes to services and client software.  We have a
bunch of these that we've captured for this month's coverage.  We talk about
DLCs, payjoin, MuSig2 support, RBF support, splicing, and a large exchange
integrating Lightning support and CPFP, so we'll jump into that.  As a reminder,
this is a monthly segment of the newsletter where we try to collect interesting
Bitcoin tech being implemented in higher-level pieces of software and we'll jump
right into it.

_Wallet 10101 beta testing pooling funds between LN and DLCs_

The first one here is wallet 10101 beta testing pooling funds between LN and
DLCs.  And so, this wallet from 10101 that is being beta tested is a Bitcoin and
Lightning wallet and it's built using the BDK and LDK libraries.  And they've
also introduced the discreet log contract, DLC functionality.  And to give an
example that I think that they use from one of their other blog posts, is this
notion of a stablecoin using DLCs.  And in that example, you would use bitcoin
that you have as collateral to enter a short position against your bitcoin,
effectively creating like a dollar stable coin in this DLC, since if you're
holding bitcoin, you're long, and if you're short in this DLC, that would
effectively give you a synthetic dollar using this DLC.

In order to achieve something like that, where you need pricing information,
they need an oracle to essentially tell the contracts what the bitcoin price is
at a certain time.  And 10101 uses adaptor signatures from different oracles to
provide that pricing signature data to the DLC contract.  And the way that
they've introduced these DLCs is actually using a Lightning commitment
transaction.  So they've added what they call a custom output with arbitrary
spending conditions as part of Lightning's current revocable output in the
commitment transaction.  This is in a modified Lightning node that can still
route LN payments, although I don't believe that these DLC contracts are being
routed over LN.  Murch, did you get a chance to look into this 10101
announcement and the different blog posts?

**Mark Erhardt**: Not that much more than you, or nearly as much as you.  You've
already covered it much deeper than I would.

**Mike Schmidt**: Sorry, go ahead.

**Mark Erhardt**: I mean, much deeper than I could have!

_LDK Node announced_

**Mike Schmidt**: The next piece of software that we highlighted in this segment
is LDK Node being announced.  And so, folks may be familiar with the LDK
library, but this is actually the potential to create a Lightning node using
LDK.  And so the LDK library is known for its customizability, and the LDK API,
they note in the blog post, has over 900 different methods that you can use to
configure Lightning-related functionality.  And they note in their post, "While
this customization is great for builders, it often comes with the added cost of
increased complexity".

I think what they're getting to is that for folks to get up and running using
LDK, it would be advantageous to have a package that can put together LDK as the
core of a Lightning node that offers some customizability, with some opinionated
implementations already baked in.  And so because LDK doesn't come with an
on-chain wallet, they've sort of bundled LDK and BDK together and created this
LDK node, which is a more fully baked solution.  And they note that one of the
primary goals of LDK node is, "To simplify the integration of self-custodial
Lightning nodes, specifically targeting mobile applications".  Hey, Rearden
Code, did you have a question or comment?

**Rearden Code**: Oh, we can talk about the BitGo MuSig2 support, because I
wrote a bunch of it.

**Mike Schmidt**: Oh, awesome.  Yeah, thanks for jumping in.  We'll get there
shortly, and remind me to call you in if I forget.  So, Murch, any comments on
LDK Node?

**Mark Erhardt**: Yeah, so I was curious when I saw that announcement where the
blockchain source comes from.  And my understanding is that it uses basically,
what was it, Electrs or…?

**Mike Schmidt**: Esplora, I think.

**Mark Erhardt**: Esplora, yes, an Esplora backend as the blockchain source.  So
I thought that was interesting.  So, you sort of distribute the source of
blockchain data to running an Esplora node and then you have a whole stack of
BDK, LDK and out of all of those projects that you sort of build up your own
node.  I think it's kind of neat how it's stitched together.

**Mike Schmidt**: And a point that was made for a future version of LDK Node is
that they do plan support for both Electrum and bitcoind RPC backends for chain
data in the future.

_Payjoin SDK announced_

Next piece of software that we highlighted from the newsletter was Payjoin SDK
being announced, which is called PDK.  And PDK, the goal is to make a to make
payjoin functionality a drop-in upgrade for all software touching Bitcoin.  So,
the idea is that you drop in this library and you have a series of functions
that can help you coordinate payjoins and maybe I can loop in Murch.  I think
many folks are probably familiar with payjoin but we haven't covered it
recently.  Murch, what is payjoin and why would we want to encourage wallet and
services to implement something like payjoin?

**Mark Erhardt**: A payjoin is when a spender includes an input from the
receiver in their transaction.  So let's say I am trying to pay Acme Company
for, I don't know, some service, I would usually build a transaction using my
input, make a change output, and a recipient output to Acme Company.  And of
course, that would just look like a single input to output transaction onchain.
To make that a payjoin, I would, in the process of negotiating my payment to, or
receiving the invoice from Acme Company, learn which input they would like me to
include.  We would build a transaction with two inputs, one from me, one from
Acme Company, and then we would still have two outputs, where the recipient
output to Acme Company would now be increased by the amount that they
contributed in the input.

What this does is it breaks the common input ownership heuristic.  So, usually a
surveillant can assume that all inputs on a transaction are owned by the same
entity.  And in this case, that's no longer true, of course, because one input
has been contributed by the sender and one input has been contributed by the
receiver.  So, if the surveillant doesn't catch that, they might think that all
the inputs belong to the same wallet and would cluster all of the inputs
together as trying to track a wallet onchain.  This may help befuddle such a
surveillant; it may also make it harder to distinguish the change output from
the recipient output, because both inputs and outputs would now be owned by both
the receiver and the spender, so patterns that track input flags or fingerprints
would appear on one input and one output each.

So, yeah, it's sort of a mechanism to achieve privacy.  There's also a tiny
consolidatory effect because now, of course, instead of the recipient having two
outputs afterwards, they combine those two outputs into one, by sort of
consolidating one of their inputs into their recipient output.  Yeah, and I
think I covered it all, right?

**Mike Schmidt**: Yeah, that was great, Murch.  One of the things that I'm
excited about as an Optecher who is interested in adoption of Bitcoin tech, is
this idea that wallets and services using a well-established library, like let's
say BDK, instead of every wallet and service writing their own Bitcoin
libraries, is that it's likely that adoption of Bitcoin tech would accelerate by
using a common, well-tested library and that tech would roll out more quickly to
wallets and services using that underlying library, since they don't have to
architect something like in this example, payjoin, all by themselves.  It's done
in a common library that's already used.

So, to that point, there is a segment in this write-up that Dan Gould did on
PDK, which is, "Why not add Payjoin to BDK?"  And there's a few different
explanations that he has in here, including alluding to the fact that BDK and
PDK complement each other well, and there probably could be a day in the future
where PDK's payjoin crate in rust compiles as part of BDK, but that may be
coming soon.  But he also notes that, "In order to provide well-engineered and
reviewed components, PDK lives in his own repository for specialized scrutiny,
so that each effort can focus on their individual strengths", and also points
out that PDK is not doing IO, whereas BDK does do IO, and so they're keeping
these two projects separate for now to let them mature at their own rates.
Murch, I don't know if you had a take on that?  No take, okay.

_Validating Lightning Signer (VLS) beta announced_

Good news.  We have some folks from the VLS team here to talk about the
Validating Lightning Signer beta announcement.  Jack and Ken are here to talk
about VLS.  This is a project that I've heard a lot of rumblings about, so it's
nice to see this beta.  In lieu of myself butchering some sort of summary of the
project, I can turn it over to Jack and Ken, who can maybe explain the elevator
pitch for VLS at a high level.

**Ken Sedgwick**: Hello, can folks hear me?

**Mike Schmidt**: Hey Ken, do you want to introduce yourself real quick?

**Ken Sedgwick**: My name is Ken Sedgwick and I work on the VLS project with dev
random and Jack Ronaldi.  We've just announced a beta which supports Core
Lightning (CLN) and LDK-based nodes.  It does layer 1 and layer 2 validation.
We're working feverishly on making it smaller so it can fit in embedded
environments because we think that that's an important use case.  So, you would
be able to run it on a small, inexpensive device, maybe with an ESP32 or an
STM32, something like that.  What do folks want to know about it?

**Mike Schmidt**: Well, maybe it would make sense to outline what's happening in
Lightning now and what would be happening in Lightning with VLS, and maybe
highlight some potential pitfalls in the way that Lightning nodes currently
could be operating and why it would be better with VLS.

**Ken Sedgwick**: Okay, yeah.  The need for VLS is because Lightning nodes have
to have hot wallets.  So, a good example would be a large retailer might have 1
million channels and they each might have $100 in them.  And so now you have to
have $100 million hot being connected to the internet, and that's quite a
target.  Normally with layer 1 Bitcoin, if you were doing something like that,
you would try to keep most of the funds cold by taking them out of the hot
wallet.  And so exchanges frequently have 95% of their funds cold.  But
Lightning wallets don't allow you to do this; the funds need to be hot and they
need to be onchain.

So, when we looked at that, we decided that we really need to do more with
Lightning nodes than people were doing with Bitcoin nodes.  And a good place to
start was to make sure that the keys and private materials, so secrets of
various kinds and keys, were protected as much as possible.  In the traditional
enterprise, this would be an HSM, and maybe, in fact, we would indeed run in an
HSM.  Now, we're software guys, so we're not doing the hardware directly, but
we're trying to write the software in a way that it can be put into both small
setups, embedded setups, so like a hardware wallet, and also can be run in
something like an HSM, where your ability to connect to the internet and the
like should be severely restricted on purpose to keep it more secure.

When you're using VLS, what happens is the node does not have the actual signing
keys.  Instead, every time it wants to do a protocol operation, so let's just
say, for example, you're routing a Hash Time Locked Contract (HTLC), you would
need to get commitments signed so that you can exchange them with your peer.
You would communicate with VLS, you send a request, and we provide the
signatures that you need, after checking, to make sure that the commitment does
not leak your funds.  This is the critical thing.  It's not just good enough to
sign things, you need to make sure that the things which are being signed
represent safe transitions for the person who owns the node.  Our security model
is, in fact, that we expect that the node can be completely compromised, and VLS
will protect your funds.

So, a typical attack to describe there is if your node was compromised, the bad
guy would simply suggest a closing transaction which sent all the funds to some
place that was good for him.  But VLS will see that and realize that, no, you
were entitled to X% of this channel and you need to see that those funds are
returned to an address that VLS controls the key for, so a wallet address or an
allow-listed location.  So, by first separating the keys out, and then secondly
by maintaining enough state so that we can tell that every transaction is safe,
we can ensure that even if your node is taken over by a hostile entity, that VLS
will protect your funds.  I don't know how much time to use.  So are there...?

**Mike Schmidt**: No, that's great.  And maybe to define a couple of these
things that you've mentioned in your explanation, which I thought was a great
explanation, thank you.  So, HSM is Hardware Security Module.  I was going to
say, a question that I have for you is, are these STM32s and, what was it,
EPS32s, are those just like lesser versions of HSMs, or is there something
conceptually different there?

**Ken Sedgwick**: Those are commodity devices.  So the ESP32, for example, is
currently being used by Stackwork and Sphinx, and they're running VLS on it.
So, that's a $10 device, and the idea is though that an end user can have a
signing device in, I want to call it a wall wart, but a little thing that they
plug into the power adapter, into a power socket, and then it would connect to a
node which is running in the cloud.  So the node would be operated by a
Lightning Service Provider (LSP), but it wouldn't have the keys, so the user is
maintaining custody in this case.  So, all requests which require sending money
or even receiving money come to the signer, and the signer makes sure that the
user's funds are safe.

So, HSM is one end of the scale; these are very, very expensive, exotic pieces
of hardware.  And then the other end of the scale is commodity devices.  So
we're writing everything in rust, and we're writing the core pieces using no_std
rust, if people are familiar with that.  But basically, it means that the core
is very embeddable, it doesn't use lots and lots of Unix system calls, for
example.  So, you have to provide it with proofs that things are what they are,
and then it can validate the proofs and say, "Yes, okay, so we've seen a new
block in the blockchain", for example, "and that had an output in it which is
important to me".  I'm rambling a little bit.  So, we're trying to address the
entire spectrum by writing it consistently and using techniques which allow it
to be embedded.

**Mike Schmidt**: Ken and Jack, we've covered Greenlight in the past, and folks
may be familiar with the value proposition to that service.  How is VLS, if at
all, related to what Greenlight is doing?

**Ken Sedgwick**: Actually, I think I better let Jack do -- we're related.
We're working with Greenlight.  Greenlight is using VLS as its signer, but I
want to be careful not to pre-announce or carelessly announce too much here.
Jack, do you have a handle on what it's okay to say?

**Jack Ronaldi**: Yeah, it's already public.  They're working with us and they
helped us with the grant.

**Ken Sedgwick**: Okay, cool.  Yeah, I'm always just a little nervous when it
comes to IP and stuff like that.  I love working on open source projects where,
you know, the VLS team does not have any secrets.  It's impossible to reveal
something by mistake for us, but we have to be careful with our partners and
folks we're working with.  But yeah, so Greenlight needs a signer because that's
in essence what it's doing, so it's separating out the signing and giving
custody to the end user in their location and then running the bulk of the node,
all the gossip and routing and all that stuff, in the cloud as a service.  And
they've chosen VLS as a signing technology that they can use.  So we are
currently working with them on that.

We also support CLN in a just basic mode.  So, CLN is made up of a bunch of
cooperating daemons, these are different processes, and one of those daemons is
called the HSMD.  And Rusty said, "Well, it was aspirationally named", but he
intended someday for an HSM to be put there.  So, VLS actually is doing that.
We replace the HSMD with a proxy, which speaks a protocol to an external VLS
signer, and you can run that today.  That's all integrated and can run their
full integration in test suite, and we are running them in testnet all the time.

**Mike Schmidt**: Jack, what would you hope to be getting out of this beta
release?  Who is a great candidate to beta test this; and what sort of feedback
are you looking for on the data?

**Jack Ronaldi**: Yeah, so we're really looking for -- VLS is an open-source
library and reference implementation, so we're not actually building anything
that's going to be necessarily consumed by end users.  So we're hoping, or our
ideal hope, is to get a handful of Lightning developers and Lightning companies,
that might be able to use this, to start working with it and maybe try to
integrate into their project, whatever they have, and then give us feedback on
what's missing, what would they like to see.

So, Stackwork and Sphinx, that Ken mentioned, is one of our first customers, and
they're planning to use VLS in their solution, and we'd love to get maybe at
least five more to start, ideally scale this up, like Ken was saying, to large
retailers eventually.  But I think we need a little feedback, because right now
we're kind of making best guesses on what people might need for priorities.  But
if we had actual customer feedback, that'd be super-useful.

**Mike Schmidt**: Murch, any questions or comments on VLS?  Okay, he's giving me
the thumbs up.

**Mark Erhardt**: Yeah, no, that was for Jack.  I think that it is pretty
interesting or it's great to see that you all are making so much progress.  The
inherent issue around Lightning, of course, is that all your funds are hot.
They are on an internet connected device that is actually capable and in need of
being able to send funds around.  So, being able to decouple the signing from
the operation of the gossiping node and the negotiation with peers on what
exactly gets forwarded where, and being able to sort of formally express your
requests to the signer in a way that you can prove that your node is actually
not losing money right now, so succinctly that just this embedded hardware
device is capable of assessing whether or not it should sign something, is
really, well, it's very difficult and it's impressive that you've managed to do
so.

**Ken Sedgwick**: Well, thank you.

**Mike Schmidt**: Ken, Jack, thank you for joining us.  You're welcome to hang
out for the rest of the Twitter Space, or if you have other things you're doing,
you're free to drop.  Thanks for representing VLS and it's a very cool project,
thank you.

**Jack Ronaldi**: Thanks for having us.

_BitGo adds MuSig2 support_

**Mike Schmidt**: Next piece of software that we highlighted, implementing some
Bitcoin tech in this segment of the newsletter, is BitGo adding MuSig2 support,
and we have a guest representing some of the research and work done here,
Rearden Code.  Do you want to introduce yourself and talk a little bit about
your involvement here?

**Rearden Code**: Yeah, sure.  My name is Brandon, I've been the manager of the
BitGo Bitcoin team for a few months now.  And yeah, so we added MuSig2 support,
which has been kind of a goal of mine for as long as I've worked in the Bitcoin
space, to get MuSig2 into the hands of users.  I was excited about it from the
beginning of the taproot conversations and everything.  So, when BitGo first did
Taproot support, back when we launched it concurrent with the taproot soft fork,
we had read the draft work by Jonas, Nick, and all of them on MuSig2.  So we put
a theoretically signable MuSig2 key in our first taproot implementation almost
two years ago.  Then the spec changed, that wasn't signable with MuSig2.

But here we are almost two years later, we've launched MuSig2 support, so this
lets BitGo customers with hot wallets have their multisig BitGo spends look just
like single-sig taproot spends.  And I can tell more stories about this if you
guys want, but I think it's a huge announcement, and getting MuSig2 into the
hands of customers, making it so that there's really no big drawback to using
multisig for a lot of purposes, I think is huge for the future of Bitcoin.

**Mike Schmidt**: Maybe talk a little bit about what was the drawback to using
multisig before, and how does MuSig2 help that?

**Rearden Code**: Yeah, sure.  So there were two big drawbacks to multisig
before this, and one is privacy.  If you're using a multisig, there's kind of
two multisig sizes that are fairly common, and that's BitGo's 2-of-3, or Casa's
3-of-5.  Outside of that, if you use any other multisig than 2-of-3 or 3-of-5,
you pretty much alert exactly what wallet software you're using.  So it's a
privacy downside there, where everyone knows when you're using multisig which
wallet you're using.  And in some cases, they can even narrow it down to, you
must be one of just a few people using that wallet because multisig isn't that
popular, especially these less common multisigs.

The other downside to multisig historically has been fees.  Signatures are big,
16 to 20 vbytes, call it, for each signature.  So, every additional signer on a
multisig adds a lot of cost to your transactions.  MuSig2 with taproot solves
both of those, where if you use your taproot keypath with MuSig2, it's just one
signature onchain, and it looks like any other single-sig spend onchain as well.
So, the cost is the same and the appearance onchain is the same.

**Mike Schmidt**: I'm curious if there is any of the software that you've
developed to implement MuSig2, BIP327, that BitGo will be open-sourcing for the
community to be using, or if that's something that you guys are keeping
proprietary for now?

**Rearden Code**: Yeah, great question.  So, we have two MuSig2 implementations
involved in our total deployment.  Being a multisig wallet, we have signers that
exist in two places typically, three in some cases, but not for MuSig2.  And so
we have our HSM proprietary software, you guys were talking about HSMs for VLS.
So we have the MuSig2 on our HSM, and that's closed-source code.  But we also
implemented it in TypeScript, and there's a library out there called Musig-js
that is open source and anybody can look at or use.

**Mike Schmidt**: Excellent.  Murch, do you have any questions or feedback for
your alma mater here and their rollout?

**Mark Erhardt**: Yeah, I think this is just the coolest thing ever, because
just the week that I left BitGo in 2020, I wrote an article about how to use
P2TR to implement 2-of-3 inputs, and of course with BitGo in mind because I had
been working there for over three years, and I was the lead on rolling out
segwit there.  So we were, back then, the first business enterprise I'd say, two
weeks after segwit activation, we got segwit working for our customers.  And of
course, BitGo has hundreds of Bitcoin companies as their customers.  So, pushing
out segwit that quickly, especially as in 2017, there was this huge block space
demand, and of course later that year we saw that huge spike of feerates, but
BitGo had segwit support already, so our customers, by the droves, switched over
to segwit.

I hope that, well, right now the block space demand is not quite as high, but I
really love that BitGo has put out MuSig2 support basically the moment that the
spec was finalized.  And now customers of BitGo, which make up, I don't know,
the official numbers by BitGo, I think, are something like 20% of all
transactions go through BitGo; so, being able to switch those outputs to MuSig2
outputs and look like single-sig onchain for all of these companies that are
currently using multisig, which has fee savings and privacy implications, and
also just increases the pool of people that use keypath taproot spends already,
that's really awesome.  Brandon, you wanted to say something else?

**Rearden Code**: It's 20% of value on Bitcoin, not 20% of transactions.  We
tend to move bigger transactions!

**Mark Erhardt**: Oh, back when I worked there, it was 20% of the transactions.
I guess now it's 20% of the value moved through Bitcoin.

**Rearden Code**: That's what I've most recently heard.

**Mike Schmidt**: Excellent.  Well, thank you for jumping in to explain your
work.  I echo both of your sentiments that this is a very cool and important
announcement.  Hopefully we will see more of these types of announcements from
other companies in the future.  Brendan, any final words before we move along in
the newsletter?

**Rearden Code**: I just want to say thank you to Jonas, Nick, well especially
Jonas for his time on this.  We talked with him quite a bit throughout the
process of developing it, and he was super-helpful and always thoughtful, and it
really made it possible for us to get here and be the first company to do this,
because he was so patient with his time.

_Peach adds RBF support_

**Mike Schmidt**: Next item that we highlighted from client and services
software changes implementing Bitcoin tech is Peach adding RBF support.  So, the
Peach Bitcoin mobile application is intended to be used for P2P exchange, so
buying and selling bitcoin.  They have a variety of, I think, fiat integrations,
and I think they use multisig escrow for doing the exchange.  And they noted in
a tweet, "Bitcoin fees went up and Peach users got some of their transactions
stuck in the mempool.  You can now bump the fees to your outgoing transaction".
I'm not exactly sure how the setup is.  I do believe that there is a multisig
escrow, so I guess, Murch, how would that work then if they're fee bumping and a
multisig, they need to do some coordination on the fee bumping transaction?

**Mark Erhardt**: Well, if they're doing RBF in a multisig setup, then
definitely they would need to get at least a quorum of signers involved to
create a replacement transaction.  So, I'm not entirely sure how they
implemented that, but I do know that that is definitely non-trivial to implement
because, well, I looked at it way back when I was at BitGo still, how to do RBF
with BitGo, and we didn't ship it back then, at least.  I wonder, have you
looked more at Peach in general?  Is that sort of the spiritual successor to
LocalBitcoins, which recently shut down altogether?

**Mike Schmidt**: It does seem like it, yeah.  I haven't used it myself, other
than seeing mentions of it on Twitter.  People seem very supportive of the P2P
exchanging, no KYC solution.

_Phoenix wallet adds splicing support_

Next item from the newsletter is actually something we talked about last week,
which is Phoenix wallet adding splicing support.  We had t-bast, or t-best, on
last week and I suspected that we were going to be covering this item, so we
talked with him a bit.  He gave a more in-depth explanation of ACINQ's Phoenix
wallet than we'll get into today, so you should jump back and listen to that
segment of the podcast; that's #259.  But this is a mobile Lightning wallet that
uses a single, dynamic channel that is rebalanced using splicing and a mechanism
similar to the swap-in-potentium technique that we talked about previously.
Murch?

**Mark Erhardt**: Yeah, I just wanted to point out again because it's just so
cool, essentially what they changed their model to is where they previously
would have multiple channels between their customers and themselves, now they
will have a single channel per customer.  And when you want to send funds from
your channel onchain, they just splice out a UTXO.  They sort of spend the
funding output directly into a new funding output to make a new channel, you
make a recipient output to the receiver that you wanted to pay, and you
therefore have an uninterrupted channel.  And vice versa, when you receive, they
stage the funds in the swap-in-potentium output and then splice it in when it's
confirmed, so that there's also no interruption of your channel.

It makes a lot of the UX around having a Lightning channel and, well, just like
channel management and the abstract concepts that are involved in that and, why
can I not receive the full amount of balance that is outstanding from the other
party, and all of those sort of headaches that new users especially have when
they use Lightning, they are drastically simplified by this approach.  So, I'm
very excited to eventually be able to use that for my Phoenix wallet.  And they
don't pay me, that was just an endorsement from me personally!

**Mike Schmidt**: Yes, I guess disclaimer for this section for all eternity is
that we aren't paid to cover or not cover any particular items here.  This is
just something that I go through based on what I see on particular projects, on
some of the recap shows, on my own list of software projects, and of course
Twitter.

_Mining Development Kit call for feedback_

Next item that we covered this week is a call for feedback on the Mining
Development Kit (MDK).  So the team working on the MDK posted an update, a blog
post, on their progress to develop hardware, software, and firmware for Bitcoin
mining systems.  I believe this is largely driven by Block, and they're looking
for feedback from the community about different use cases, scope, and approach.
The intention behind the MDK is to provide developers a bunch of tools to unlock
any creativity and innovation in the Bitcoin mining hardware space.  So, their
initial proposal included a Bitcoin mining hashboard, a custom design controller
board designed to work with that hashboard, a suite of open source firmware,
software API, and web front end to allow developers to mess with the parameters
of the hashboard using an interface, and also a bunch of reference materials and
support documentation so folks can easily customize this hashboard.

In one of their blog posts, they mentioned, "We anticipate the MDK being useful
for development projects focused on integrating Bitcoin mining into various
novel use cases, such as heating solutions, off-grid mining, home mining, or
intermittent power applications, as well as optimization of Bitcoin mining
hardware for traditional commercial mining operations.  With the MDK, we see
significant opportunity to increase the accessibility and openness of Bitcoin
mining hardware in order to accelerate innovation in the field".  Murch, do you
have any familiarity with the MDK idea and any of the progress there?

**Mark Erhardt**: No, I mostly just rediscovered that through your section here
in the newsletter, but it does sound pretty cool to have just this building
block that becomes more accessible.  And I think we can generally just use more
competition in the mining hardware sector.

_Binance adds Lightning support_

**Mike Schmidt**: Next item from the newsletter is about Binance adding
Lightning support.  So Binance posted an announcement for both integration of
Lightning for their sending out, which would be withdrawing from the exchange,
as well as receiving, which would be a deposit into the exchange, using the LN.
And I believe that there is some chatter from team members from the Binance team
that mentioned that they were working on Lightning around the time of the fee
spike.  So, I believe that this is motivated by the recent fee spike on the
Bitcoin Network.  Murch, thoughts?

**Mark Erhardt**: Well, it's always been surprising to me that especially these
exchanges, well, at least if they also dabble in smaller amounts, why they
wouldn't have done this years ago.  So, it's good to see more exchanges to roll
out this.  I think that, of course, Bitfinex has had Lightning support for a
long time.  I recall that Bitstamp might have also.  But generally, especially
for companies that should anticipate a large amount of transactions being sent
right between each other, having Lightning support would be pretty amazing.  So,
for example, I would anticipate that people that arbitrage would try to send
funds between exchanges and when these exchanges are able to discover that a
send is going from one to the other, that they, for example, just facilitate
that via Lightning.

**Mike Schmidt**: Yes, much similar to the value proposition originally from
Liquid as well, which was quick exchange of Bitcoin between exchanges.  Curious
to see how the interexchange LN continues to grow.

_Nunchuk adds CPFP support_

**Mike Schmidt**: Last piece of software that we highlighted from the newsletter
is Nunchuk adding CPFP support.  So, Nunchuk is a mobile wallet that supports
multisig wallet setups and hardware signing devices, and they had RBF fee
bumping in the first version of their wallet and are now adding CPFP fee bumping
as an option as well.  And they specifically call it, "The advantage of CPFP
over RBF in the use case of the recipient wanting to fee bump an incoming
transaction".  And so they have a nice blog post that we linked to that explains
some of their rationale and why they did this.  Murch, thoughts?

**Mark Erhardt**: Now we just need package RBF and cluster mempools so that when
multiple people are CPFPing stuff, it also gets recognized as contributing to
the overall package feerate rather than just competing CPFP.

**Mike Schmidt**: That wraps up the client and service software update section
of the newsletter.  We'll move on to Notable code and documentation changes and
I'll take a moment to call to the audience.  If you have a question or comment
about anything that we've talked about, or really anything Bitcoin tech-related,
feel free to request speaker access or comment on this Twitter thread with a
question, and we'll try to get to that at the end of our Spaces here.

_Bitcoin Core #27411_

Bitcoin Core #27411, preventing a node from advertising its Tor or I2P address
to peers on other networks, like plain IPv4 or IPv6.  Murch, why would we want
to prevent advertising that, and what are the potential concerns?  I understand
there's some fingerprinting here potentially, but maybe it's worth digging a
little bit, a level deeper here, to understand why this PR was merged.

**Mark Erhardt**: Right.  So, let's take another step back here.  Bitcoin Core
nodes will regularly announce their own IP address to their peers.  So, when you
have a Bitcoin Core node, in order to ensure that other Bitcoin Core nodes, or
generally nodes on the network I should say, hear about your existence, the node
will, about every 24 hours I believe, rebroadcast its own IP address as it knows
about itself.  So, this sort of self-advertisement is a repeated announcement of
the node's IP address.

I think that Martin discovered this issue where if you are on I2P, you can be
active on I2P without having an identity for yourself.  And while Bitcoin Core
was already always using the best fitting representation of itself in the
network where it was self-advertising, this could cause that because there was
no self-identity on I2P that it instead published its Clearnet identity.  So of
course, if you're on I2P and you're publishing your Clearnet ID and your IP
address, then that is sort of a privacy hazard.

So, what this PR does is it shores up the separation of your identity between
those networks in the sense that when you self-advertise, you will only ever
self-advertise the identity corresponding to that network and it cannot leak
over.  So on I2P, you would only advertise your I2P identity; on Clearnet, you
would only ever self-advertise as your Clearnet identity.  Note that of course,
if you are forwarding just generally a set of IP addresses that have been
advertised to you, and that includes your identity from the other network, you
would still forward that as part of your regular package, you will just not do
it for the self-advertisement that you regularly do every 24 hours.  So, yeah,
this is basically a bug fix for a privacy issue.

**Mike Schmidt**: Excellent explanation.  Thank you, Murch, for taking that one.

_Core Lightning #6347_

Next PR is Core Lightning #6347.  And as a reminder, CLN is heavily based on
this plugin architecture, where different plugins can do different things to
customize how that Lightning node behaves, and this particular PR allows you a
plugin to subscribe to all event notifications.  I think previously you had to
specifically say what types of events your plugin wanted to subscribe to, and
now you can subscribe to all using the * wildcard.  I noticed that in the
opening of this PR, I think it was Rusty that said, ''It is not recommended, but
it is useful for plugins which want to provide generic infrastructure for
others".  So, I guess there's certain types of plugins that would benefit from
this, but in general, it is not recommended.  Murch, any thoughts?

**Mark Erhardt**: No, not on this specifically, but I just saw that someone
asked a question on VLS.  So Ken, could you explain to us whether VLS allows any
automation in regard to rebalancing channels?

**Ken Sedgwick**: Oh, that's a great question.  Personally, I use CLBOSS a bunch
because that can set up a whole lot of activity.  Today, I'm putting the VLS
signer in permissive mode when CLBOSS is rebalancing the channels.  So, we do
not currently have what we need there.  That said, it should be possible to, for
example, if you're doing a loop out, I think is the one that you frequently need
to do to get liquidity, you should be able to present the onchain transaction to
the signer as a proof that it's okay to make the Lightning payment necessarily
to facilitate the loop out.  So, we are optimistic that we will be able to
support loop out, for example, and other such looping rebalancing.

The other thing is circular routing.  So, you route a payment to yourself
through several other nodes in order to adjust the balance of all of those.
That one's much easier because basically you're paying an invoice where you are
the receiver of the invoice.  And so, it seems very simple to make that safe.
Does that answer the question?

**Mark Erhardt**: I believe so, that sounds pretty good.  This was asked by Chad
Pleb on Twitter, by the way.

_Core Lightning #6035_

**Mark Erhardt**: Thanks for the question, Chad.  Next PR from the newsletter is
Core Lightning #6035, adding the ability to request a bech32m address for
receiving deposits to P2TR output scripts.  And this change is optional for
requesting a bech32 address for receiving a deposit.  And it also does change
the default for change to now be sent to a P2TR output by default.  Go ahead.

**Mark Erhardt**: Actually, in this context, I think it's interesting to point
out, if any of you are involved with any Bitcoin businesses that are
apprehensive about changing their receive address standard to P2TR already, you
can totally change your change addresses to P2TR way earlier than you can change
the receive addresses, because the change addresses are only the addresses that
you send yourself to.  So, you know that you'll be able to send to them, even if
your customers haven't upgraded yet to send to P2TR.  You could, if you have a
very high volume wallet, potentially already save costs or, well, at least if
the feerates go up way higher later on, the inputs will be cheaper if you've
stored your funds in P2TR outputs.  So, yeah, you can totally consider just
upgrading your change addresses first and then later upgrading your receive
addresses when you feel confident that users generally have enough support for
sending to bech32m.

_LND #7768_

**Mike Schmidt**: Next PR here is to the LND repository, LND #7768, implementing
a change that allows the ultimate receiver of an HTLC to accept a greater amount
than they requested, with a longer time before it expires than they requested.
And we've covered this a couple of different times in our recap.  And one thing
that I always get back to, that I think is the best explanation, is in t-bast's
BOLT PR.  He explains this well, and I'll quote him, "It is important to ensure
that intermediate nodes and final nodes have similar requirements.  Otherwise, a
malicious intermediate node could easily probe whether the next node is the
final recipient or not.  Unfortunately, the requirements for intermediate nodes
were more lenient than requirements for final nodes.  Intermediate nodes allowed
overpaying and increasing the CLTV [CHECKLOCKTIMEVERIFY] expiry, whereas final
nodes required a perfect equality between HTLC values and onion values".

So due to that concern about probing, there's been changes, and we note those
BOLTs #1032 and #1036 and we covered it in Newsletter #225 as well.  Murch, do
you have anything to add to that?

**Mark Erhardt**: Just when I was reading this, one thing that came to mind was
obviously you cannot lower either of those two numbers.  If you forward too
little money, the next hop will not accept the forward because the amount of
fees that they would be able to keep, while still fulfilling the obligation
encoded in the onion that they unwrap, would leave them less fees than they
require, and so they would reject it.  Similarly, you cannot send a lower expiry
because the forwarding hop requires some sort of delta to have enough time to
settle a multi-hop payment when it needs to go onchain.  And if the expiry on
the inner onion and the one that they are forwarded do not leave enough for
their own delta, then they would reject it.

So really, you can only overpay a little bit or leave too much time for the next
hop in order to see whether they behave differently than expected.  And yeah, if
of course the recipient was strict about the things that they requested in the
original invoice and now reject an HTLC that is being forwarded to them because
they are too generous, then that is the privacy leak here at that point.

_Libsecp256k1 #1313_

**Mike Schmidt**: Last PR this week is to the libsecp repository. And to set the
context here, sometimes compilers attempt to optimize certain pieces of code
that was designed to run in a fixed amount of time, and when it does that
optimization, it changes that fixed amount of time to potentially run in a
variable amount of time.  When you have a variable time code that works with
private keys and nonces, it may lead to side-channel attacks.  We link to a few
of those that have potentially occurred in the past.  And so, this PR begins
automatic testing using development snapshots, using the GCC and Clang
compilers, which may help detect some of these optimizations that those
compilers are doing, in order to detect those changes that can result in these
sorts of side-channel attacks.  Murch?

**Mark Erhardt**: Yeah, I wanted to jump in a little bit there.  So, constant
time is when you require that an operation on your computer always takes the
same amount of time, regardless what inputs are provided.  So for example, if
you're implementing a cryptographic operation, and that cryptographic operation
is faster if the key value is lower, you might be leaking privacy or giving
hints to someone that is observing exactly how much computation you're doing or
how much energy you're drawing through a cable, by taking less time or less
energy for the operation when the key is lower, right?  So, especially
cryptographic operations implement constant-timeness in order to ensure that
whatever data you're using under the hood, especially the secret data, it always
looks indistinguishable to any observers, and that's what this is about here.

So, yeah, I think we covered it just recently with libsecp, I think it was GCC
had an optimization where it did something smarter than expected and optimized
away something that was done to enforce constant-timeness.  And there was
actually also recently an announcement by, I believe it was Intel, that they
were going to introduce a runtime flag or something for their chips that allow
us to enforce constant-timeness on certain operations or instruction sets.  So,
there is some progress in this issue in various avenues.

**Mike Schmidt**: Well, that wraps up this Newsletter #260.  Murch, any parting
words?

**Mark Erhardt**: No, all good.  Have a nice week.

**Mike Schmidt**: All right, thank you to Jack and Ken from VLS for joining,
Gloria from the Waiting for confirmation series, and Rearden Code from BitGo
talking about MuSig.  Thank you all for taking the time to join us and explain
the work that you're doing.  Have a good week.  Cheers.

{% include references.md %}
