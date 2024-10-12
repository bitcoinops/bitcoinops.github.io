---
title: 'Bitcoin Optech Newsletter #323 Recap Podcast'
permalink: /en/podcast/2024/10/08/
reference: /en/newsletters/2024/10/04/
name: 2024-10-08-recap
slug: 2024-10-08-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Bastien Teinturier to discuss
[Newsletter #323]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-9-8/387743456-44100-2-4aa7fb5971fd3.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #323 Recap on
Twitter Spaces.  Today, we're going to talk about a forthcoming btcd security
disclosure, the Bitcoin Core 28.0 release, and a series of interesting Eclair
PRs that t-bast will help guide us through, in addition to maybe a little bit of
a victory lap regarding the BOLT12 offers PR getting merged.  I'm Mike Schmidt,
contributor at Optech and the Executive Director at Brink, funding Bitcoin
open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs and I'm back from
vacation.

**Mike Schmidt**: Bastien?

**Bastien Teinturier**: Hi, I'm Bastien, I work at ACINQ on the LN and I'm also
back from vacation.

_Impending btcd security disclosure_

**Mike Schmidt**: Thank you both for joining today, should be a nice and easy
one.  We'll start with the News section.  We had just one news item this week
titled, "Impending btcd security disclosure", and this was prompted by Antoine
Poinsot, who posted to Delving Bitcoin about a bug that he and Niklas Gögge had
created, or had found in the btcd project, and they're posting about it on
Delving.  They found this vulnerability in March, so earlier this year, and
Antoine indicated in his post that it is a critical severity issue for btcd
users.  The issue is that an attacker could potentially hard fork btcd full
nodes using a simple and standard Bitcoin transaction.  So, no sophisticated
setup or large financial cost to the attacker, as we've seen with a lot of other
attacks.  So, the bug is serious, critical, classified as critical in the post
for btcd users, but the threat to the Bitcoin Network is minimal, since some
analysis that Antoine posted shows that of all the Bitcoin nodes on the network
that are vulnerable to this attack, it's really less than one-tenth of 1% that's
vulnerable.  But if you are one of those nodes, you will want to upgrade.

We don't have the technical details of the bug yet, but since publishing the
newsletter, it sounds like btcd contributors, as well as Niklas and Antoine,
will be announcing the full disclosure later this week.  So, if and when that
happens, that will be in a forthcoming newsletter where we'll close the loop on
this.  The bug was fixed in btcd v0.24.2, so if you're running anything before
that, you should upgrade as soon as you can.  Murch, anything to add?

**Mark Erhardt**: Yeah, maybe just to point out v0.24.2 only came out earlier
this year in June.  So, even if you're updating your node regularly, this one
might have slipped by you so far.  So, if you're running btcd, just check that
you're on a non-vulnerable version.

_Bitcoin Core 28.0_

**Mike Schmidt**: Moving to the Releases and release candidates section of the
newsletter, two this week.  Big one: Bitcoin Core 28.0 officially released.  We
had Gloria and Fabian on in our Recap #320 and we covered a lot of the headlight
features of this release with them.  So, look back at #320 if you're curious for
an overview of what has recently been released.  Both Gloria and Fabian also
joined the Stephan Livera podcast #607 and covered 28.0, as well as some other
discussion items there as well, so you get a double dose of Fabian and Gloria.
I thought that since we've already gotten some core devs' perspectives on this
release, including walking through the Testing Guide previously, it might be
interesting, given that several of 28.0's updates involve P2P and mempool policy
changes, that maybe we could get the thoughts about those features from a
Lightning project contributor.  So, we happen to have t-bast here.

So, t-bast, this Bitcoin Core 28.0 release has one-parent-one-child package
relay (1p1c), TRUC transactions, relay of pay-to-anchor (P2A) transactions, and
some limited support for package RBF relay.  Maybe to get your thoughts, how are
you thinking about these updates from Eclair's and Phoenix's perspective, and as
a Lightning contributor?

**Bastien Teinturier**: We are very, very happy that these just landed in this
release of bitcoind, because first of all, it's going to allow us to improve
propagation and some pinning scenarios of existing and Core channels that are
just going to be able to -- we're going to be able to use the package 1p1c
topology to actually relay our commitment transactions without changing the
commitment format of the existing channels, which is really, really nice.  And
also, what's even nicer is that we're going to be able to introduce a new
commitment format, where the commitment transactions of Lightning channels will
be able to use v3 TRUC transactions, pay zero fees, which removes a lot of edge
cases in the Lightning protocol, and use a single anchor.  And for that, I think
we're going to wait for Bitcoin 29.0 to have the ephemeral anchor proposal as
well, which I think Core dropped to a zero value when not actually needed.

All of these are changes that we've been waiting for a long time, that are going
to help us protect much better against pinning, and basically simplify the
Lightning protocol by removing the dependency and onchain fees from the actual
channel usage.  So, I'm really excited about those, and we're going to be
starting working on them in the coming months.

**Mark Erhardt**: Yeah, moving the fees out of the commitment transaction into
the anchor is a real game changer, I believe.

**Bastien Teinturier**: Yeah, exactly.  It's really, really much better and it's
also, from a user's perspective, much easier to reason about, because when
commitment transaction pays zero fee, it removes the very weird case where when
a commitment transaction does have a feerate, for example 1 sat/byte, whenever
you add an HTLC (Hash Time Locked Contract) to the commitment transaction and
it's pending, the weight of that transaction becomes bigger, which means that
you have to pay more fees, so your balance actually decreases for a while.  This
is really hard to explain to users, and we should not have to explain that to
users, it should be completely decoupled.  And once we move to zero-fee
commitment transactions, we are finally able to completely decouple those and
make it much easier to understand and reason about the balances of your
Lightning channel.

**Mark Erhardt**: Yeah, and the other thing that we also recently talked about
was, when the feerates spike on the network, we won't get these channel closures
due to implementations disagreeing or nodes generally disagreeing by having
different feerate sources and being unable to agree on a new feerate of the
commitment transaction, because the feerate can always be zero.

**Bastien Teinturier**: Yeah, that's a very good point.  This is going to remove
most of the unexpected force close that we see on the network today, because
most of them are linked to spikes in feerate and edge cases around updating the
feerate of the commitment transaction when there is a certain state in the
channel and implementations disagree.  So, all of these cases of force closure
will completely disappear once we're able to move to the zero-fee commitment
transactions, so it's going to make Lightning much more robust.

**Mike Schmidt**: T-bast, you mentioned you guys are getting to work on
implementing some of this.  I'm curious what you think, from your perspective,
Eclair's perspective, Phoenix's perspective, would be coming soon; and maybe a
follow-up question there, does the architecture of Phoenix and phoenixd lend
itself to being able to roll these things out quicker in some scenarios?

**Bastien Teinturier**: Kind of, but not entirely, because we are indeed able to
experiment with some channel types between our node and Phoenix or phoenixd much
faster than having to wait for the spec to be actually fully added to the
vaults.  But one issue with this specific case is that, first of all, we'll want
to wait for ephemeral anchors, which hopefully will be in Bitcoin v29.0, so
we're still waiting for one more release before we actually deploy that stuff.
But also, one of the main issues for mobile wallets is that, once we move to
zero-fee commitment transactions, then the only way you can actually broadcast
your commitment transaction is through the submitpackage, RPC; you have to
submit it with a child.

The main issue here is that Electrum protocol does not support that, and I don't
think they plan on supporting that.  And most mobile wallets connect to an
Electrum instance instead of directly connecting to a Bitcoin instance.  So,
they will not have the ability to publish their commitment transaction, which is
not acceptable because you want for it to be trustless, you want the wallet user
to be able to automatically publish their commitment transaction if they detect
a breach or need to force close for any reason.  So, we need to find a way to
change the backend, or have something else than Electrum that people can deploy
at home and connect to their bitcoind to point there.  Yeah, I'm not exactly
sure what we're going to do here.  Elias on the LDK team mentioned starting to
work on a project to kind of replace Electrum for those mobile node cases, but
this is very new.  But we will need to find a solution to that before we are
able to actually release it for mobile wallet users.

**Mike Schmidt**: What's the rationale in not planning to support that on the
Electrum side?

**Bastien Teinturier**: I think it's just that they don't have the resources.
If someone is willing to do the work to add this to the Electrum protocol, that
would be great, because then we wouldn't have to do anything apart from waiting
for most Electrum nodes and people to upgrade their Electrum nodes to use the
new version, and then that would be great.  But I don't think anyone is actually
willing to work on that in the short term, or at least I don't know about anyone
who signaled working on the Electrum protocol to add the support for the
submitpackage RPC.  But it would be really great to see.

**Mike Schmidt**: All right.  So, prospective Bitcoin and Lightning open-source
contributors, there's a need.  T-bast is calling you to action.  So, if you're
curious, reach out.  Sounds like that's something people are looking forward to.
Murch, anything else on the Bitcoin Core release that you'd like to know?  You
cut out there, but I'm going to take that as a no, I think.

Next release is a release candidate for BDK 1.0.0-5.

**Mark Erhardt**: Sorry, I had one more comment on the Bitcoin Core thing.

**Mike Schmidt**: Yeah, go ahead.

**Mark Erhardt**: So, I was curious.  My understanding is that Lightning
implementations recently synced up and so when you said that you're waiting for
v29.0, is that a position shared between the different projects, or is this just
the approach of Phoenix?

**Bastien Teinturier**: Yeah, we don't have yet a draft BOLT for that new
commitment format.  We started discussing it during the recent Lightning Summit
with the other implementations.  And since we will want to use the ephemeral
anchor when it's ready, and we don't want to introduce two new different
commitment formats almost at the same time, one not using ephemeral anchor, we
all agreed that it was best to wait for the ephemeral anchor, at least if it
ships in bitcoind v29.0.  Otherwise, if it looks like this is not going to get
in, maybe we will revisit.  But I think everyone is on board with waiting for
ephemeral anchor to define that new commitment format.

**Mark Erhardt**: I see, thank you.

**Mike Schmidt**: Maybe piggybacking on that topic, I know, I forget, I guess it
was sometime last year, there was an LN Summit and I think we got notes maybe
from Carla at some point, and we had that highlighted in the newsletter at the
time.  Is there something like that that is out or is planning to be out for us
interlopers?

**Bastien Teinturier**: We're planning on sharing, I shared some of my notes on
the issue and the Lightning repository.  We had an issue to organize the Dev
Summit, and I shared some of my notes and Laolu today shared some of his notes
as well.  I think his contain more details than mine, but are structured and
just following the discussion.  So, I think both of them can be useful to get a
summary of what happened there.  But I think I'm waiting for more people to
share the notes on the topics they really listened in and were interested in,
and maybe that will provide a better summary for everyone to read.

**Mark Erhardt**: Oh, I had another follow-up, and I also see thunderbiscuit
joined us.  So maybe, thunderbiscuit, you first.

**Thunderbiscuit**: I was just going to mention, I think you guys were headed
into the BDK section, and I maintain the language bindings for BDK, but also I'm
on the Core team, so I was going to speak to that for a second if you wanted to,
but I don't know if that would be your next item.

**Mike Schmidt**: Murch, do you want to wrap up your question or comment, and
then we can get to the BDK item?

**Mark Erhardt**: Yeah, I had sort of a question around Electrum.  So, my
understanding is that Electrum is sort of very underspecified, and there's a
number of different implementations that diverge on details.  So, maybe this
need for wallets to be able to submit packages will lead to some more
standardization or some updates across the ecosystem.  So yeah, anyway, maybe
that's more of a thought than a question, but I was surprised that we wouldn't
be getting a package submit.  And I guess, since it's more of a client-server
relationship, I guess you can't do the same trick where you submit the child
first and then submit the parent.  But yeah.  Anyway, that seems like a
surmountable problem.

**Bastien Teinturier**: I hope so!

_BDK 1.0.0-beta.5_

**Mike Schmidt**: Hey, thunderbiscuit, thanks for joining us.  BDK 1.0.0-beta.5.
You want to talk about any portion of the beta process or this particular RC or
anything?  The floor is yours.

**Thunderbiscuit**: Sounds good.  Well, quickly, I think beta.5, I mean people
have been waiting for 1.0 for a while.  So, I think this might be the last beta,
or there might be one more, but we're wrapping up everything we had in terms of
bugs or feature requests that we're going to be breaking.  So, we're looking at
the stable 1.0 hopefully very soon.  And the language bindings, for those who
are not familiar with them, we maintain Kotlin, so Java; and then Android,
Swift, and Python language bindings, which you can also combine to create React
Native and Flutter bindings.  For BDK, those are also updated to the beta.5,  so
we're at the latest stuff and we're hoping to release all of that as 1.0 soon
enough.  I don't think beta.5 is a particularly big one breaking, just we
enabled RBF by default on the transaction builder, but otherwise that's about
it.

If you haven't been following BDK, one of the cool things in my opinion, of
course, I'm a mobile developer, but is the development of a compact block filter
client called Kyoto.  So, this was started by one of our students sort of, who
got a part-time grant to work on this and it's been working really well.  And we
have early integration into the language binding, so I'm using it on mobile
right now and it works.  I mean, it's very early, so we're still debating hotly
the API and what should be available.  But I think it's pretty cool because it's
coming up as potentially a compact block filter client you would be able to have
on any mobile device, which is currently not quite the case, I guess.  So, yeah,
looking forward to that.

**Mike Schmidt**: Will that be something that is under the BDK umbrella, or is
it just a totally separate project nurtured elsewhere?

**Thunderbiscuit**: So, currently, the Kyoto library is under Rob, so it's his
repo, but he has asked to pass it on to the BDK org, so we're discussing that.
We have a bit of a bar that people need to meet before we bring in.  We don't
want to bring all the libraries and then have to maintain them.  So, there's a
sort of standard, we're asked for one year of continuous maintainer-ship, and
then somebody on the Core team to be willing to take that on as a secondary or
primary maintainer.  So, he currently doesn't meet that, but it's developed --
like, he works with us, we're very much in sync.  And he, I believe, got a
short-term grant from OpenSats to continue the work on Kyoto.  So, that's the
pure client itself, just like we maintain libraries for Electrum, Esplora, and
the Bitcoin Core RPC.

Then we have also libraries that are the glue between what BDK, the wallet type,
and the TxBuilder, and the transaction graph expects from the clients.  And
those smaller, thinner libraries, that's the BDK Kyoto basically library is
under our org and is currently maintained by us.

**Mike Schmidt**: Cool.

**Thunderbiscuit**: So, if you're not familiar with it, we can have all sorts of
clients.  And as long as you write a little wrapper library that connects
basically a client to the BDK infrastructure, you can get that and use any
client.  So, we've talked with the Ark guys, who are interested in having
potentially an Ark client that would be able to follow at least the onchain
part, not the virtual UTXO part, but just the onchain of that.  And if you have
sort of a BDK Ark sort of glue] library, then you'd be able to use a BDK wallet
on an Ark client at low cost, say.

**Mark Erhardt**: That sounds cool.  I wanted to poke a little at you.  How come
the RBF by default is rolling out just now when Bitcoin Core is turning on
full-RBF by default?  Is that a coincidence?!

**Thunderbiscuit**: I mean, I feel like pressure's been mounting and just it's
been part of a bunch of dev calls, and I need to brush up on some of that maybe,
but yeah.

**Mark Erhardt**: Okay.

**Thunderbiscuit**: It's definitely part of that.  I know that now with a lot of
like -- yeah, that was basically a big part of that conversation.

**Mark Erhardt**: I see.

**Mike Schmidt**: We actually have that PR later in the newsletter, BDK #1616.
Thanks again, thunderbiscuit, you're welcome to hang on.

**Thunderbiscuit**: Cheers.

**Mike Schmidt**: All right.  Notable code and documentation changes.  If you
have a question for any of us or our guests, feel free to request speaker access
or drop a question in the thread here, and we'll get to that.

_Bitcoin Core #30043_

Bitcoin Core #30043, a PR titled, "Replace libnatpmp with built-in PCP+NATPMP
implementation".  Murch, what does all that mean?

**Mark Erhardt**: Yeah, that's also not part of my core competencies, but my
understanding is that the functionality in Bitcoin Core that allows you to
basically punch a hole into your firewall when you are running a listening node,
without configuring manually that you're forwarding exactly certain ports, has
now been extended to also cover IPv6.  And the author of this PR also completely
replaced the dependency and rewrote stuff that takes care of this in-house.
Yeah, it's basically a drop-in replacement for the previous support for IPv4,
plus now extending the support to IPv6.  Basically my expectation is once this
is released, which is going to be v29.0 presumably, well not presumably, v29.0,
which is six months away of course, it should be easier to get your node up and
running and listening on the network without configuring manually your router to
do so.

_Bitcoin Core #30510_

**Mike Schmidt**: Excellent.  Thanks, Murch.  We're going to get you back in the
saddle with another one here, Bitcoin Core #30510 titled, "Add IPC wrapper for
Mining Interface".

**Mark Erhardt**: Yeah, so there has been a, I think now seven-year effort to
separate processes in Bitcoin Core into multiple executables.  And one piece
that is sort of related and fairly new that got added to this project roadmap
recently, was to have a mining interface that makes it easier for a Stratum v2
mining process to get data directly from Bitcoin Core.  And my understanding is
that IPC is just more efficient and faster than an RPC.  And so, this PR I think
just revisits the efforts that we covered, I think three weeks ago, where now
the wrapper is integrated into the other efforts of the process-splitting
project.  But yeah, unless you're working on Sv2 or running a mining pool, I
think this is -- well, in that case, you should probably read this more
carefully than I did.  But that's all I have.

**Mike Schmidt**: It seems like the Stratum v2 requirements of Bitcoin Core are
sort of nudging the multiprocess project along a little bit.

**Mark Erhardt**: Yeah, well, I think multiprocess is actually getting pretty
close to being ready to be deployed, but it just really nicely fits into this,
because the idea is to split up the executable into three parts, basically the
Core node that does all the networking, the verification of the blocks, and so
forth; the wallet; and the GUI.  And this is just something that would attach as
an interface to the Core module of the multiprocess.  And yeah, so Sjors has
been working on it hard, but this PR is from Russ, I think.  So, yeah, I think
it was basically just a follow-up from the other one from three weeks ago, where
Russ added some stuff that made it fit better with the multiprocess project.

**Mike Schmidt**: Yeah, we talked about Bitcoin Core #30509 in Newsletter #320,
so that's a related PR.  If you're curious about this discussion, check that
out.

_Core Lightning #7644_

Core Lightning #7644 is a PR titled, "Provide nodeid from hsm secret".  And this
PR adds a method where you can provide an hsm secret and get back the node ID
that a node using that hsm secret would have, which is something useful for
verifying that if you're using Core Lightning (CLN), that you're accessing the
correct secret and to match the backup to the specific node and avoid confusion
with other nodes.  Rusty Russell, in the PR description noted, "This is
extremely important for backups: if they are using VLS, they need to back *that*
up instead, for example.  I didn't have anything else there.

**Mark Erhardt**: Yeah, this sounds like something you would need if you are
deploying a whole fleet of Lightning nodes and people actually hold the keys
separately from them.  I wonder what prompted this.  Probably the Greenlight
project?

_Eclair #2848_

**Mike Schmidt**: The next four PRs here are all to Eclair, and I think there's
some very interesting tech.  And I'm glad that t-bast was able to make the time
to join us to explain this in a much better fashion than I think Murch and I
would.  T-bast, we started with Eclair #2848, which implements extensible
liquidity advertisements.  You want to break that down for us?

**Bastien Teinturier**: Sure.  So, we merged all of those PRs at the same time,
because we actually stacked them on top of each other and spent a lot of time
testing them end-to-end with an integration in Phoenix.  This is basically the
result of two years of trying things on Phoenix to figure out how to actually
best manage liquidity so that people did not have to care too much about it
while not having to pay too much fees either, trying to find a good middle
ground where inbound liquidity is abstracted well enough, but users can still
customize it enough to keep some control.  And the first result of that is that
we wanted to make sure that it eventually gets into the spec.  So, we want to
reuse things that we are building potentially for other things as well.  And
Lisa had been working on liquidity ads for a while.  Her first view was just to
let basically big nodes sell their inbound liquidity to over-routing nodes, but
we actually needed more flexibility.  So, we decided that we wanted to build all
of our liquidity management around liquidity ads, because it made sense to have
only one tool for that and make sure that it lets us do all kinds of liquidity
management.

But the first version that is a design was a bit too limiting for that, because
at the time, it was only for dual-funding and splicing was not here.  So, there
are actually a few things that are different when you are buying more liquidity
for a splice than when you are buying it for a new channel.  So, we needed to
change the protocol to reflect that.  And we wanted that protocol to also give
some flexibility on how the fee for that liquidity purchase was paid, because
initially in Lisa's version, it had to be paid from the buyer's channel balance.
So, if this is an existing channel, the buyer needed to have enough balance on
their side to pay the fee for the liquidity purchase; or, if this was a new
channel, the buyer had to add an input on their side of a funding transaction
with enough funds to be able to pay the liquidity fees.

_Eclair #2861_

We actually added in this version of liquidity as a way to potentially override
-- that behavior is still the behavior that is used by default, but it's also
possible to change that behavior, and that is actually what we're doing in the
other PR, #2861, which is on-the-fly funding.  And in that PR, what we create is
using those extension fields in liquidity ads to be able, for a mobile client
who is receiving an HTLC but doesn't have enough inbound liquidity to actually
receive that payment, to tell the LSP, "Okay, I want to buy that much liquidity,
because then with that much additional liquidity, we'll be able to really relay
that payment and I will pay the fees from the HTLC itself".  And that's one of
the modes that can be used for on-the-fly funding.  And we describe, we
introduced a few modes to cover all cases of how you may be able to pay the
liquidity fees without having to trust anyone in that setup.  And that part is
not something that we think should be added to the BOLTs, because this is really
for LSP-to-mobile communication.

So, we instead created a BLIP for that, because other LSPs would probably be
interested in working on this.  And I know we've discussed with the LDK team
actually making this a standard default, and they are working on starting to
implement it as well and give feedback on the specification.  So, the goal is
that spec for the mobile clients, use that same specification so that it has a
standard feature on the network, which would let wallets pick the LSP they want
among a set of LSPs that would provide the same features.

_Eclair #2860_

Then the second PR is just a small one.  The #2860 is just a way to communicate
which feerates we find acceptable to make sure that whenever the other side
initiates a funding transaction, they use a feerate that is acceptable, because
otherwise we would just send error immediately, which wastes a round trip.

_Eclair #2875_

And the final PR, #2875, is an additional way to cover the case, because even
with the on-the-fly funding provided before, either the mobile wallet user needs
to be able to pay the fees for the liquidity purchase from the channel balance,
or from the HTLCs they receive.  But if they are receiving very small HTLCs and
have no channel balance, then they won't have enough to pay the liquidity fees.
And in that case, with only on-the-fly funding, the only thing we can do is just
fail those payments; we just cannot accept them.  But in the case of a user who
is stacking very small payments over a long period of time, maybe what they want
to do instead is when they receive their first 1-sat or 10-sat payment to say,
"Okay, this is not enough to get me a channel, but I can accumulate those as
mining fee credits so that when I have enough, then you can open a channel to
me".

So, that's what this fee-credit feature is.  Whenever a user is receiving a very
small payment that is not enough to justify creating a channel or making a
splice to add more inbound liquidity, they have the option to tell the LSP,
"Okay, here is the preimage.  Accumulator, take this HTLC amount as fee credit,
and when you have enough, then you will actually create a channel to me or make
a splice to me".  And this is not ecash in the sense that this is not something
that you can then send.  It's really you are purchasing fee credit and
accumulating it slowly over time, until you reach a point where it actually is
used to pay the mining fees for the channel or the space transaction.

So, with all of these, then we cover basically all cases of managing liquidity
on the fly, as long as the fees are low enough that users accept paying them.
And then, you are able to receive any kind of payment without having to actively
care about your inbound liquidity.  So, that is a lot.  So, it's probably a bit
hard to digest, but I think the easiest way to understand it is to just play
with it.  And I think the easiest way for that is to use phoenixd, which is a
server version of Phoenix, and let you play with the command line to actually
see things in action, see logs and get more control than the Phoenix mobile
wallet.  And we haven't released yet the versions of Phoenix and phoenix that
use these updated specifications, but we should be able to release them in the
coming days or weeks.  So, you'll be able to play with those protocols very
soon.  Are there any questions about this?

**Mike Schmidt**: I'm curious about being able to play with the phoenix.  Is
there a way to visualize or is there like a simulator to use to sort of run
through these different scenarios that you've outlined that Eclair is now
handling, in terms of on-the-fly funding and these fee credits?  Or is it just
sort of, I get access to the command line and I have to create these scenarios
myself to be able to sort of experience it?

**Bastien Teinturier**: Yeah, you will have to kind of create it yourself,
basically for example by just spinning up a phoenixd and trying to receive a
10-sat payment, which cannot be used to actually create a channel.  And then you
will see that if you have authorized enough fee credit, then you will see that
you will release the preimage from that payment and the sender will see that the
payment was successfully made.  But the only thing you will see on the phoenixd
side is that you have now accumulated fee credit, and then you can play with
receiving more until you reach the point where our node will actually open a
channel for this.  You would have to play with the API yourself to test the
scenarios, but then you will be able to list payments and have access to the
payments DB or CSV export of all the transactions.  And those will show you what
is added to fee credit, what is actually received as amount in a channel, and
where are the mining fees and some of the service fees associated with those
operations.  So, I hope that this helps people get a good feel for how it works
and, yeah, get accustomed to it.

**Mike Schmidt**: With the funding fee credits for these smaller payments that
I'm receiving, does it matter what entity is receiving those on my behalf; like,
does it have to be the same entity every time in order for them to then justify
opening that channel; or, how does that work; or, am I misunderstanding
something?

**Bastien Teinturier**: Yeah, it does matter a lot, because if you activate fee
credit, and this is optional, this is something that is not activated in Phoenix
and will not be released in Phoenix, will be released in phoenixd, but can be
deactivated.  And this is a trust relationship, because whenever you buy fee
credit, you completely trust that the LSP will actually honor that fee credit in
the future and use it to open a channel to you.  So, these are small amounts,
but still this is completely trusted.  So, you would only want to do this if you
trust the LSP with the amount of the maximum amount that you configure as
maximum authorized fee credit.

**Mike Schmidt**: Okay, that makes sense.  And I guess, in addition to trusting
that entity for some period of time, I would also need the confidence that over
some period of time, that I will receive enough payments in order to sort of
trigger the point that the channel would actually be opened, right?  If I'm only
getting a couple of payments and I think I'm going to get more, then I guess I
would never be able to receive those funds if I don't continue to receive.

**Bastien Teinturier**: Yes, exactly.  If you just install phoenixd and do one
payment of 100 sats and then never come back, those 100 sats will just end up at
our LSP and will be money that we received on your behalf; but you just
disappeared, so we're keeping that money.  But yeah, and by the way, Matt
Corallo told me that we should really rename that, because this is not a credit
in the banking sense, so it's rather a mining fee prepayment.  Maybe that will
be more clear if we name it 'mining fee prepayment', or something like that, but
we haven't decided yet on the official name for that.

**Mike Schmidt**: Murch, what do you think about all this?  It seems
super-interesting.

**Mark Erhardt**: It sounds like there's -- we're still only in year, what is
it, 9 of the 20 years that Rusty said new protocols take to be built, and we're
making headway.  And it sounds like it'll get a lot easier over time to manage
your liquidity.  And yeah, can't wait to use Phoenix again, but how's that?  Is
there anything on the horizon for us people living in the United States?

**Bastien Teinturier**: Either getting some clarity or having other people
actually run LSPs, because since we were the only LSP running in the US, then it
would make more sense for us to come back if other LSPs are offering the same
services, so that we can feel that we're not the only one with a big target
pointed on our back.

**Mark Erhardt**: Yeah, thanks for that.  I understand, I guess, especially
looking at the legal developments recently with Samourai Wallet and so forth.
That's just not a fun position.

**Mike Schmidt**: We have the offers protocol spec merge as the last PR.  We
have a couple more in the meantime, if you can hang on t-bast?  Anything else on
the Eclair ones?

**Bastien Teinturier**: No, I think that's all.  So, there will be some
discussion.  I know that CLN is working on that updated liquidity specification,
so hopefully that is something that will get into the BOLT soon-ish.  And for
the on-the-fly funding and fee credit part, I think those will take longer,
because the only other implementation that is actually actively working on this
is LDK, but they have some big prerequisites before being able to do that, such
as dual-funding, splicing, liquidity ads, and also they are potentially waiting
for the zero-fee commitment format that I mentioned before to only do on-the-fly
funding with that commitment format.  So, this one will take longer to get
cross-compat and become standard.  But while we're waiting for LDK to be able to
work on it, we're going to keep experimenting with this in the wild with Phoenix
and phoenixd, and we will tweak it as we discover if there are some edge cases
that need to be reworked or some improvements that we can make to the protocol.

_LDK #3303_

**Mike Schmidt**: LDK 3303, which improves LDK's event-handling infrastructure.
So, the way that LDK works is that users or clients of LDK can implement
event-handling logic in their code.  But in some cases, events get replayed when
there is a restart.  And before this change, while it was easy to identify
outbound payment events and make those unique using LDK's PaymentID field,
handling inbound payment events wasn't quite as clean and could lead to some
unintentional behavior, potentially accepting duplicate payments, or could also
result in an unintentional failed payment if you were to handle those events
successively or multiple times.  So, the change here is that LDK adds a
PaymentID identifier that takes into account the channel ID and HTLC ID as a
pair, which simplifies the inbound event handling for LDK client applications.

_BDK #1616_

BDK #1616, which I referenced earlier and is in this beta.5 for BDK.  It changes
the way that transactions are created.  And by default now, transactions will
signal opt-in RBF by default.

**Mark Erhardt**: Yeah, so I thought thunderbiscuit might chime in on this one,
but I've been thinking about why this appeared, maybe in the context of full-RBF
now rolling out as the default in Bitcoin Core.  So, that was of course proposed
several years ago, and the observation was that in the mining sphere, a vast
majority of the hashrate now appears to be using full-RBF.  They accept
replacements even without signaling, and therefore I guess it makes sense as an
intermediate step to always signal RBF, because that is now the behavior that we
should expect on the network.  Everything will be replaceable, and by signaling
replaceability, older software or software that hasn't really updated their RBF
support yet will indicate that a transaction is signaling replaceability, and
therefore it will match the expected outcome on the network.  But it's also a
little funny that just as it's unnecessary to signal, well, as soon as 28.0
nodes get more adopted on the network, we also see that this project has enabled
the signaling by default.  But yeah, I think it makes sense now.

**Mike Schmidt**: Thunderbiscuit, anything to add here?

**Thunderbiscuit**: No.  Just that it's funny, because yeah, it's like Murch
said, it's almost like we're a few years behind, you know?  Just as it finally
becomes like everything is replaceable, now we're turning this on by default.
This should have been the default a long time ago.  I think internally as well,
if you wanted to bump a transaction, you were using the TxBuilder and you need a
transaction that would signal RBF on it.  So, similar to what Murch said, it
helps if you're on an older version, or whatnot, to make sure that your
transactions all signal RBF, so that way, the TxBuilder is not going to give you
grief when you want to bump.  But eventually, all of this is kind of a moot
point at this point.

I do have a question though, maybe for others or Murch, or whatever.  I'm
wondering if you see this eventually going away entirely, where people would
signal, like you would not opt-in RBF, and it would just be implied that
everything is, and so software will start not even signaling for it; or, is all
software always going to signal for it just as a legacy thing?

**Mark Erhardt**: Yeah, I think that the idea is that the signal will go away in
general, and therefore the transaction fingerprints go away.  This will also
sort of get on board the other wallets that never bothered to interface with RBF
at all, because then everything will look the same again.  But in this context,
it's also really interesting.  I think there's none or very few wallets that
have made a lot of headway with showing multiple versions of the same payment,
like conflicting transactions, in a good overview way, but happy to be corrected
on that.  I'm certainly not looking at all the wallets all the time, so there
might be some.  But I think that feature will become a lot more important now
that full-RBF is going to be deployed more widely, and we will probably
eventually see more use of full-RBF.  Currently, it's already getting used every
day, every hour, but if wallets adopt this more, then giving a good overview of
what's happening and why you might see a transaction and then another version
that conflicts with it will be very important.  Did that cover your question,
thunderbiscuit?

**Thunderbiscuit**: Oh yeah, very well, thank you.

_BIPs #1600_

**Mike Schmidt**: BIPs #1600, which makes or made, I guess, several changes to
the BIP85 spec, which is titled, "Deterministic Entropy from BIP32 Keychains".
Murch, I know you've been a bit more out of the loop these last few weeks, but
you are also our resident BIP maintainer.  Did you get a chance to get caught up
on this change and why there was some consternation in the community?  Yeah, go
ahead.

**Mark Erhardt**: Yeah, so a few months ago, I think four months ago, a person
approached the repository and wanted to update BIP85 for clarity, and had a new
reference implementation that they felt was clearer.  And we tried to contact
the original author of BIP-85, but were unable to get any response on the email
address that had been left in the BIP.  So, after posting that to the mailing
list and announcing that there would be an update, nobody replied, nobody saw
it.  But I guess on Friday, so this change after four months was adopted, there
were some I guess breaking changes in the BIP, and people thought that it hadn't
been adopted that widely.  But once the news of that got into the Optech
Newsletter, suddenly a few people jumped up and were like, "Hey, wait a minute,
this was deployed into multiple projects already.  This should probably be final
and certainly not get any breaking changes anymore".

So, this PR that we reference here in the newsletter actually got already
reverted, and there's now two new PRs.  One is to make just these clarifications
that are not breaking changes; and then, yeah, just I think maybe the other
stuff will eventually become a new BIP, or maybe it's scrapped and that part I'm
not completely caught up on yet.  Anyway, this is still developing and hot off
the press.

_BOLTs #798_

**Mike Schmidt**: Last PR this week to the BOLTs repository, BOLTs #798, which
merges the BOLT12 offers protocol into the LN spec, a PR that had, according to
GitHub, 28 reviewers, several hundred of review comments over four years,
finally merged.  T-bast, we've discussed offers quite a bit on the show and
several projects support it in some fashion.  So, we don't need to get maybe
into the details, but maybe at a higher level, how are you feeling about it, and
what would you add?  Any interesting anecdotes, or kind of take this any way you
want as sort of a victory lap on this getting merged.

**Bastien Teinturier**: Oh, yeah, it's really, really nice that this is finally
getting merged.  I think that Rusty is really relieved that he doesn't have to
look at all the comments on this PR anymore.  He can just be done with it and
can also start re-adding the things that he removed from BOLT12, because
initially he had a recurrence feature that can be very useful when you are
paying for subscriptions for an offer.  But he was asked to remove it because it
was already a big chunk to get BOLT12 with what it is today, and having
recurrence on top that requires conversions from fiat currencies is something
that the way you want to do it is potentially, there's a lot of debate.  So,
he's really happy and we're all very happy that this got in, because now we can
start working on all the other things that we are building on top.  And BOLT12
is really just a platform to be able to build many things on top that provide a
better UX, provide more services that can leverage LN.

So, yeah, this is really nice because at some point, we thought that we would
never get there.  We were constantly moving the finish line further and further
while we were getting closer, but then always adding new stuff and adding new
bikeshedding.  But then we took the opportunity of the Summit, since we already
had three implementations here in LDK and Eclair that had full implementation of
BOLT12, and all the tests that we had been making were passing.  So, we were
pretty confident that we had cross-compatibility, and even LND with the LNDK
project was able to test compatibility with the other implementations.  So, we
just needed to make sure that the spec itself didn't have any remaining
mistakes, spelling issues, or things like that.  And we took the opportunity of
the Lightning Summit at dinner to finally merge that PR.  And this was really a
happy moment.  We all cheered to that and I hope it's not the last BOLT we add.

**Mike Schmidt**: It seemed to me, as an observer over the years that, and maybe
this is just incorrect, I'd like your feedback on it, that there was a competing
scheme to achieve something similar, and it seemed like there was some fighting
around there and that it was unclear, at least in my perspective, that this was
something that would eventually be merged.  I think the last year or so, that
hasn't been the case, but was there ever a point where you thought that maybe
this wouldn't get merged?

**Bastien Teinturier**: No, not really, because I think that all of the LNURL
protocols that do functionally some of the things that BOLT12 do have issues,
have mostly privacy and potentially security issues that BOLT12 fixes.  So, I
think it was important, it was really useful that LNURL shipped fast and allowed
that functionality to be available for many use cases, and that helped the LN
ecosystem evolve a lot.  But I think that BOLT12 is an improvement towards that,
so I was always pretty sure that this would get in.  And I'm still pretty sure
that in the long run, this is going to entirely replace some of the LNURL
protocols, because it is just, for some things, a superior way of doing it.  And
so, yeah, I was pretty sure that this would happen, but I had no idea of the
timeline, and I still have no idea on the timeline for migrating to BOLT12 and
for having more wallets starting to support BOLT12, and slowly phasing out the
existing protocols.  That will take a long time, but we will eventually get
there, and I think that everyone will be happy when we get there, because we
will all see that this is working better and in a more private and more secure
way for users.

**Mike Schmidt**: Murch, any thoughts on the offers protocol merge?

**Mark Erhardt**: Yeah, I mean I'm pretty excited.  It sounds really cool, it
sounds much better in some regards.  We've talked about it so much.  I'm excited
about blinded paths, about the static invoice format, yeah.  But four years for
a BOLT is a lot to lift and to keep track of for a long time.  So, maybe this
very, very slow burn is, I think, something that a lot of Bitcoin enthusiasts
maybe don't appreciate, because it's just protocol developers sometimes are
working on stuff for years before it actually comes to fruition.  We've seen a
similar thing with the package relay project recently, which had also been in
work for four years.  We're looking at multiprocess with seven years in the
making.  I don't know exactly where I'm going with this yet, but maybe just the
time horizon is very remarkable on this whole thing.

**Bastien Teinturier**: Yeah, I agree.  And it's really good that we have people
who stay here long enough to be able to shepherd those things all the way to the
finish line for years and not give up.  And agree that for BOLT12, it took such
a long time also because there was LNURL that was filling some of the
functionality, and there were a lot of very much higher priority things that we
needed to do on the BOLTs.  So, that's why BOLT12 lagged a bit behind, but still
it's something that people were constantly looking at, starting to work on.  So,
it's really nice that we show that we have people who are able to stay for such
a long time working on long-term changes that get the protocols to a better
state.  And that's something that we should really encourage and we should have
always more people moving into protocol development and be there for a long time
like that.  This is really helpful and this really helps the protocols get
better.

**Mike Schmidt**: I don't see any questions in the thread or speaker access, so
I think we can wrap up.  Thanks to our special guest, Bastien, and for
thunderbiscuit for joining us, and welcome back to my co-host, Murch.  We'll see
you all next week.

**Bastien Teinturier**: Thanks for having us.

**Mark Erhardt**: Yeah, cheers.

**Thunderbiscuit**: Cheers.

{% include references.md %}
