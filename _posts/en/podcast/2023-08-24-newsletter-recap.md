---
title: 'Bitcoin Optech Newsletter #265 Recap Podcast'
permalink: /en/podcast/2023/08/24/
reference: /en/newsletters/2023/08/23/
name: 2023-08-24-recap
slug: 2023-08-24-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Peter Todd and Henrik Skogstrøm to discuss [Newsletter
#265]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-7-28/344796115-22050-1-8ee99d79022b.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #265 Recap on
Twitter spaces.  It's Thursday, August 24, and we'll be talking about peer
storage and fraud proofs for our news today.  We have our monthly segment on
changes to services and client software, and we have a few releases and PRs to
review as well.  We have Peter Todd as a special guest to help us talk about
fraud proofs; Henrik from LN Capital as a special guest to talk about the
Scaling Lightning initiative and the Torq v1.0 release; and we also have Max
here, who's going to be joining shortly, to talk about the Wasabi release that
we cover later in the newsletter.  We'll do introductions.  Mike Schmidt,
contributor at Optech and Executive Director at Brink, funding open-source
Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work on Bitcoin stuff at Chaincode Labs.

**Mike Schmidt**: Peter?

**Peter Todd**: I'm Peter Todd, I do consulting.

**Mike Schmidt**: Henrik?

**Henrik Skogstrøm**: Yeah, Henrik, CEO and founder of Torq.  We build node
management systems and Lightning operation systems.

**Mike Schmidt**: Well, thank you all for joining us.  We're going to go through
the newsletter sequentially here, starting with the news.

_Fraud proofs for outdated backup state_

We have one item this week, which is titled in the newsletter as Fraud proofs
for outdated backup state.  And this was motivated by a post from Thomas
Voegtlin, who was unable to join us this week, who posted to the Lightning-Dev
mailing list an idea to make Lightning channels resumable from a wallet seed,
and these resumable channels would use OP_CHECKSIGFROMSTACK.  The motivation
here is Lightning-related, but it sort of went into a more generalized theme of
using peers for your backup data in this specific instance, potentially
Lightning channel backup data, and the associated risks and potentially fraud
proofs that can be done when a peer is holding your data and is potentially
fraudulently representing that.

Peter, I know you reviewed an early iteration of what Thomas put together.  Do
you want to try to summarize that, and then we can get into some of the other
ways it could potentially be used, or potential downsides?

**Peter Todd**: Yeah.  So basically to summarize, with Lightning, of course, you
have the issue that you need to go backup state, and that backup process, of
course, a problem with it is if you go use the wrong backup, your counterpart,
you could go lose funds basically.  This was a fairly well-known issue with
Lightning.  And an obvious potential party to go and do a backup with is your
counterparty on a Lightning channel, but you run into the challenge of, well,
what happens if they go and give you the wrong backup?

Thomas's idea, which I think is kind of clever, and I'll point out how it can be
kind of generalized, is to go use the non-existing OP_CHECKSIGFROMSTACK opcode,
as well as OP_CAT, which again doesn't exist right now in Bitcoin.  But
basically, the idea with OP_CHECKSIGFROMSTACK would be to go check a signature
on the stack against a message on the stack as well.  And in the more likely
version of OP_CHECKSIGFROMSTACKVERIFY, basically if that signature doesn't
correspond to that message, you would go and steal the check; fairly
straightforward there.  And in the backups case, I'm probably going to butcher
this detail subtly, but essentially the idea is you go and have basically a time
associated with the message you're checking.  And what the counterparty is
promising to do is that for a given time, they will only ever return one channel
state, which is the channel state that you uploaded at roughly that time.

So, the point of OP_CHECKSIGFROMSTACK is, well, if you can go prove that there
are two different valid signatures on two different backups for that same time
interval, that's fraud.  And if you go and make an output that has coins
attached to this that is spendable by proving fraud, you basically have a bounty
that can be collected by this proof of fraud.  And the idea behind that is that
provides economic incentive to not commit fraud, because if you get detected, if
your counterparty does in fact already have -- that backup doesn't actually need
your service, you're going to go and lose those funds.

The way you'd implement this in practice is basically every time that you would
go online, regardless of whether or not you had a copy of the data that you've
backed up, and essentially regardless of whether or not you need the backup
service, you would ask for the most recent data, check this, and if your
counterparty lies, then you go collect the fraud proof.  So, that's the general
idea there.  And Thomas pointed out in terms of Lightning, basically anything
where you needed a backup of a small amount of data that had this property,
where you want to know what's the most recent one and someone was willing to put
up money for it, this could potentially be used for this.

**Mike Schmidt**: So, the idea is I can use my peer to back up some channel
state information and I could essentially periodically test them to see if they
would give me the correct data.  And then, if I do have that data and they give
me a fraudulent version of that, I can then have a bounty against that.  I guess
the assumption there is they wouldn't know if I actually did lose my channel
data, and so they would be incentivized to always give me the correct
information if I was testing them or if I actually needed the backup?

**Peter Todd**: Exactly, yeah.  So, the key challenge with this is you just need
to implement it in such a way that the counterparty can't figure out whether or
not you've lost the data.  A good example where they might have an idea that
maybe you did, was let's suppose that every single day, you connect 12 times a
day, because your phone's on and automatically connected, but once in a while,
suddenly you go wait a week to connect.  Now, a potential reason why you did
that might be because you've lost your phone, and it took you a few days to get
a new one and restore from the seed.  So, that could be the result of a loss,
but by putting up a monetary bounty, it disincentivizes testing this and there's
just less reason for them to go and try this out.

I'll point out this tends to be more relevant in cases where your backup
counterparty is, for instance, your channel counterparty, and they're the people
who might be able to go and take money from you by you screwing up and using the
wrong backup.  So, that's like your likely outcome.  And I'll point out with
taproot, you could even arrange for the bounty to be within the channel itself,
so it would just be another taproot branch that could be revealed to go collect
those funds.

**Mike Schmidt**: Murch?

**Mark Erhardt**: Yeah, I had the impression that this kind of mixes a little
bit two different aspects.  So, in the proposal from Thomas, I think he was
actually not proposing to ask for the backup every time, but just occasionally.
Whereas, there's also a proposal that's partially implemented by Core Lightning
(CLN) and ACINQ that uses some backup mechanism and does ask for it every single
time, but it doesn't have the fraud proofs.  So I was wondering, Peter, since
you've read more about this, do you happen to know, what would happen if you
actually lost your backup and you connect, and you of course ask for your
channel backup, or I assume that you would be the first one to ask, but what if
the other party asks you first and you don't have it because you lost yours?
So, would they just disconnect; would they just use that to steal from you?

**Peter Todd**: Well, I mean this is where the fine details of influencing this
get a bit complex.  I think in a case where you're talking about, say, a private
channel, where there's a more clear relationship of the client, if you will, to
the server, it's certainly easier to say, well only one side's going to ask for
the backup and not the other.  You can also say, well, whoever connects to
whoever first.  And again, in the case of a phone, well, that's only ever going
to go one way, because a phone doesn't have a static IP address, so the
counterparty will never connect to the phone.  So, it gets down to the details.
But certainly I think in a case where you were in a position to go and ask for a
copy of the backup whenever you connect, I don't think there's any argument
other than the trivial amount of bandwidth consumed to not asking for it every
time.  I mean, I think that's the safest option and you might as well go do it.

**Mike Schmidt**: So another Lightning-related Service Provider that stores some
data, albeit I think different data, would be watchtowers.  Peter, is
watchtowers a use case here as well for these sorts of proofs?

**Peter Todd**: I mean, for that matter, I don't see any reason why you couldn't
simultaneously use this kind of technique and watchtowers at the same time.
Maybe someone knows of a reason why, but I can't think of any reason.  And, the
security in these techniques in the case of Lightning is additive, so you might
as well do both if it's possible.

**Mike Schmidt**: And you mentioned the need, at least in the case of this new
type of channel funding transaction, which would include an additional taproot
condition, that OP_CHECKSIGFROMSTACK would be required and is currently not
available in Bitcoin.  I think, is it true that OP_CAT would also then be
required as well to be added?

**Peter Todd**: Yeah, I forget off the top of my head exactly why OP_CAT was
needed in his proposal; probably something to do with exactly how the script
worked.  But certainly, OP_CHECKSIGFROMSTACK, that's definitely needed, and it
would certainly be possible to add it in a soft fork.  You'd probably do it as a
verified version, but I don't see any direct reason why you couldn't add it.
There might be other concerns around covenants and so on, because certainly you
can, in some versions of this idea, you can implement covenants with this.  But
that kind of gets into the details of how you would use it.

**Mike Schmidt**: Henrik, I'm curious, as an enterprise Lightning provider, what
are your thoughts on maybe the general idea of peer backups or this proposal
specifically?

**Henrik Skogstrøm**: Yeah, it's really interesting.  One concern, I'm not too
deep into this topic, but one concern I have is the speed of updates.  So, if
you do channel backups essentially for very busy nodes, that's going to be very,
very fast.  Yeah, what's your thoughts on that, Peter?

**Peter Todd**: Well, I mean the backup, there's an amount of data a
counterparty already has to go and store anyway, just in the normal operation of
a Lightning channel.  And by proportion, I mean some relatively small constants,
right?  So, adding this just adds some constant factor more of data you would
store, which I think is acceptable.  Certainly it comes down to the details of
what you're willing to provide, but there's no really fundamental technical
reason why you can't do this.

**Mark Erhardt**: I'm afraid I missed the first two sentences; I couldn't hear
you for a bit there.  Were you saying that you wouldn't be doing it every time
your channel updates or what was your --

**Peter Todd**: Oh, I was saying you could do it every single time your channel
updates, and the amount of additional bandwidth and storage necessary is a
constant factor, right?  So, obviously I think it's true that it does cost
bandwidth and storage space, but this isn't an excessive amount.  It's not like
we're changing the BitGo notation to something fundamentally different.  So, I
don't see any direct challenge.

**Henrik Skogstrøm**: So, what about the economic incentives?  So, if the guy
backing up the data cheats, then he gets punishment; but what if there's a risk
then for the guy backing up that something goes wrong?  How's the economic model
around that?

**Peter Todd**: Well, I mean I think when you look at it, basically the -- oh, I
guess one way to put it is, in any Lightning channel, there is a risk for the
counter party if they screw up, that's just how Lightning works.  You get
punishments if you go and publish the wrong states on the chain.  So, I don't
think this is fundamentally different.  I think, depending on the amount at
risk, they may choose not to, obviously.  But, certainly from the point of view
-- I mean, think of it this way.  If I'm the Lightning Service Provider (LSP),
and I offer the service on incoming channels to me, that might be an
encouragement to say, "Hey, on your phone you should connect to me, because it's
a bit safer on your phone".

I don't know that all this necessarily holds true in a more "P2P" Lightning
model, but certainly the model we're talking about, you know, people using their
phone to open Lightning channels where frequently the phone is off and it could
be lost, I mean I think it makes sense.  And as a Lightning node, if you have
very high confidence in your disk storage solution and backups and so on, which
I think you need to anyway, I don't see too much additional risk from doing
this.

**Henrik Skogstrøm**: Right, that's a very good point, super-interesting.  So,
it's sort of different use cases.  For enterprise, with a massive amount of
rapid updates, it might make less sense than in those sort of rare cases for
consumer wallets or mobile wallets.  But yeah, maybe I'm just missing a
fundamental piece, but yeah, I mean it's just I guess you pay the guy doing the
backups and then if he does something wrong, you sort of have a way to almost
cashback or punish him more then.

**Peter Todd**: I mean, a point I would make is the payments for the backups in
the case of an LSP is the transaction fees that they earn from having the
channel open at all.  So, provided that the cost of reliable storage is low
enough for them, I think this is a reasonable service to offer.

**Henrik Skogstrøm**: Yeah, makes total sense.

**Mike Schmidt**: You heard Murch mention earlier in this discussion about
CLN's, at the time, experimental peer storage backup feature.  And we spoke
about that a bit in Newsletter #238.  So, if you're curious about this topic,
jump back to that for an additional peer storage technique.  And as a result of
this peer storage being mentioned in this news item, we've actually created this
week a peer storage topic on the Bitcoin Optech Topic List, which is sort of
like a wiki, so you can see some other references to peer storage that we've had
through various other newsletters previously.  Murch, Peter or Henrik, I'm going
to bring in an audience question here, but any other points you'd like to make
before we wrap up?

**Peter Todd**: Yeah, well I'll I mean I'll just point out, my actual
contribution to that conversation was, of course, just doing the math on the
non-punishment version of peer storage, where every time you connect, you simply
check if they gave you the right backup, and if they didn't, you close the
channel.  And I think when you look at the economic math, provided that the rate
at which the backup is needed is low enough, purely by transaction fees on the
Lightning channel, it probably doesn't make sense for a counterparty to attempt
to defraud in most cases.  Now obviously, I think this is a much weaker argument
than if you actually have a direct punishment mechanism, but basically I think
what the map says is that peer storage is valuable even if there isn't Thomas's
punishment mechanism.

**Mike Schmidt**: Henrik, Peter anything else before we wrap up this news item?

**Peter Todd**: Nope, I'll get back to my conference.

**Mike Schmidt**: All right, Peter.  Thanks for joining us, especially on
last-minute notice; and Henrik, thanks for chiming in.

**Peter Todd**: Thanks for having me on.

**Mike Schmidt**: Cheers.  Next section of the newsletter is Changes to services
and client software.  This is a monthly feature that we have where we find
projects that are integrating interesting Bitcoin technology that we talk about
on the Optech Newsletter, and we like to highlight those for folks as a pat on
the back for those pieces of software, and also the opportunity for folks to
check out what's being worked on at a few layers above this Core software that
we end up talking about.

_Scaling Lightning call for feedback_

A little bit different than software update is our first item this week, which
is Scaling Lightning call for feedback.  And luckily we have Henrik on, who I
think is spearheading a lot of the work around here, so I will let him frame
this up, since it's his initiative.  Henrik, do you want to introduce what is
Scaling Lightning?  What are you trying to do; what can people do to help out?

**Henrik Skogstrøm**: Yeah, thanks.  First of all, I sort of spearhead and
started the project, but I want to also pull attention to the fact that Max
Edwards is working on this full-time and has built basically all of the code we
have today on the project, as he deserves.  I can see he's actually joining
here, so Max, if you want to join, just request speaker; I think you have a lot
of value to add there.  But the core thinking behind the project is essentially,
right now, there are some unknowns in scalability of the different Lightning
implementations, and also perhaps certain parts of the protocol, and also with
different software out there.  And I'm not saying that Lightning doesn't scale,
I'm saying that no software is perfect and we need to thoroughly test things and
prepare for the day where inevitably, there's going to be a massive amount of
traffic, and those changes can happen very quickly.

So, the project is essentially compiled by a set of different simple components.
So, if you are a protocol researcher or you are developing the Core clients, you
use it in one way; if you're developing a software for a company, you might use
it in a slightly different way.  And when you're writing end-to-end tests, you
have a slightly different use case again.  And lastly, if you want to run a node
on the signet, you have a slightly different use case as well.  So, that's why
the entire structure of the Scaling Lightning project is meant to be able to
support all these use cases without adding a ton of complexity and trying to
cover everything in a really sort of wordy way.  Right now, it's composed of
simple components; the goal is to have everything as very small, simple
components.

Firstly, we're using Kubernetes at the core of this.  And the reason for that
decision is that you can run Kubernetes on a desktop by just clicking a button
in Docker Desktop, for example.  So, it's very easy to run there, and a lot of
production systems run through Kubernetes setups.  So, we want to have that
setup as most usable from development into production systems, and also be able
to simulate larger networks in research setups, and also be able to deploy
either one or multiple nodes in a signet and have a lot of activity in that
signet.

So yeah, when we started down the Kubernetes road, it's also where we're looking
at the test software that's out there.  It's largely built by cobbling together
Docker containers in some way and writing some scripts to run either a fixed set
of those nodes or a variable set, and to start some channels between them, so
you have this base network.  You also have Polar, which sort of does the same,
uses TypeScript to construct these different networks and has a convenient
interface to do this.  But the thinking essentially is that this is what
Kubernetes is built to do.  It's built to set up different configurations of
separate components running separate software, different nodes, etc.  So, we're
leveraging all the different features we have within Kubernetes and Helm and
Helmfile, etc, to not have to build all that from scratch, and also having a
very standard way of configuring things that people are used to if they're
working already with Kubernetes or Helm.

Then, the second part is that all of these things that you set up through the
Helmfiles, etc, they are very easily replaceable, so you don't have to wait for
the Scaling Lightning Project and developer binder to update something for you.
You can just pull out any component you want, and that, of course, is very
important for different implementations and different versions of
implementations like CLN, LND, different versions of those.  And it also allows
you to create your own images and just replace them.  So for researchers, that's
even more relevant where they can test implementation with some crazy changes to
them.

Then, you have a set of what I would call like convenience add-ons.  So, right
now in the default setup, we start a sidecar client alongside each of these
nodes to make it super-simple to communicate between them or with them from the
client or through a library.  And the point here is not to cover all the
functionality that you can have in the Lightning node, but rather to do the
basics so that that's super-simple to do.  So for example, have a command that
says, "Open a channel from Alice to Bob of this size", and that's all you need
to write in the terminal.  Also equivalently, when you're writing end-to-end
tests, you can import the library in a set of different languages, so
TypeScript, for example, and say like, "Give them the connection details, and
open the channel from node A to B".  So that's the sidecar client and the
library helping you to do that very quickly.

Lastly, of course, get the connection details to each of these nodes directly,
etc.  So you can do whatever advanced setup you want and just leverage the fact
that Scaling Lightning helps you spin up these networks of nodes for development
or end-to-end tests.  Yeah, maybe I've been speaking for a while.  There's more
to talk through there, but I see you have a question, Murch.

**Mark Erhardt**: Yeah, so the way I understand you, you basically have a
Kubernetes setup that allows you to spin up networks.  So, for the LN, you can
cover multiple different clients from different implementations, and you have an
interface with which you can directly instruct specific nodes in that network to
take actions.  So that sounds like a great way to test interoperability and
maybe the rollout of new features.  Are you guys working on this by yourself or
are you working with the implementations; is this a coordinated effort or is it
just your project?

**Henrik Skogstrøm**: That's a very good question.  So first of all, I'm of
course leading Torq and we're building Torq, but this is completely separate
from the company, this has nothing really to do with that.  And the effort here
is to create an industrywide tool that is used by companies' implementations so
that we pool our resources into making this as good as possible so that not each
of the companies' implementation have to write this software from scratch, each
and every one.  So, we're talking with Lightning Labs, I've been talking
specifically with Ryan Gentry; I've been talking with Rusty about this, Rusty
Russell at Blockstream; briefly mentioned it to Spiral, but we probably need to
speak more about it with them; also, Carla at Chaincode Labs.

This is something where we're trying to build more support around and trying to
build collaboration with different researchers and node implementations, but
also companies.  So, we have a Slack Telegram group where we have a lot of
companies and people from the industry in there where we're keeping them up to
date, and we're slowly now seeing more people engaged in trying it out.  So
yeah, long answer to that question!

**Mark Erhardt**: Yeah, okay, one follow-up question.  So, I think there is a
test network for the LN on signet; and does this network that you're building,
the scaling network, plug into the Lightning signet, or is it rather meant for
everyone to spin up their own and to do their own research and testing, or does
it all plug into one global landscape?

**Henrik Skogstrøm**: So again here, configurability comes in, but we're not
sure if we're at that part yet, but the goal is to have one default one to
encourage people to join an agreed-upon signet to get traffic there.  But of
course, for research, some types of research, you're going to have some crazy
shocks of activity, etc, so they can, of course, create their own if they need
it, companies can create their own if they need that, they can use regtest
locally, etc.  But to just complete the thing on the signet, with the library,
the second part of that is creating a random generator where we can create these
sort of personas.

We can have a persona that simulates or works a bit, has a behavior of like
Kraken and Bitfinex, these really, really large nodes.  And then we have one
that is more like a medium routing node, one that is like a pleb, a small node,
and so on.  So we can through that, for example, look at how the network looks
today and take a subset.  So, let's say we have 15,000 nodes today, and then we
take 150 nodes and we spin those up on the signet, on a cloud infrastructure,
and give them different personas to make a mini version of the network, and then
we use those random generators to create this activity.  So also to do that,
we're thinking about opening up the sidecar clients in certain ways, so we
constantly have this traffic and users or different developers, they have an
active signet, which we don't really have today.  So, that's one of the bigger
goals of the project as well.

**Mark Erhardt**: That's really cool.  Last question from me for the moment, at
least.  I heard you mention that it also can be run on regtest, and I was
curious about that.  So regtest is, at least originally, construed to be the
internal testing mechanism for Bitcoin Core.  Why would you ever prefer a
regtest over signet when you're doing a network thing in the first place?

**Henrik Skogstrøm**: Yeah, actually internally now, in Torq we've been using
signet with LND, for example.  But the main thing is to have a very rapid
development environment when you develop and when you do end-to-end tests.  So,
yeah, the main goal there is to have this development environment that is not
testing in the wild-ish, right?  So that's the reason behind that.

**Mark Erhardt**: I see, thanks.

**Henrik Skogstrøm**: Great.

_Torq v1.0 released_

**Mike Schmidt**: Henrik, thank you for walking us through the Scaling Lightning
initiative.  We also, and this actually is coincidence, we also are highlighting
the Torq v1.0 release, and that's the next item from the newsletter as well.  Do
you want to talk about Torq generally and also some maybe high-level features in
this v1.0 release?

**Henrik Skogstrøm**: Yeah, sure.  And thank you for having me on board with
this as well.  I want to point out again that it's completely separate projects.
Scaling Lightning, it's a community industry, and then we have Torq separate.
Yeah, so v1.0 release was major for us.  We've been live and people have been
using Torq for a long time, but we got to the stage where we had full features
in the basic management.  We had multi-node management, we had automation coming
and becoming very advanced, so we decided it was time to integrate to v1.0.

First, maybe I can just quickly explain what Torq is for those who don't know.
So, Torq is enterprise level software for managing Lightning operations.  So,
you can think about it as a node management system, but that's at the beginning.
So for example, the Lightning is a node management system for manually managing
the basic actions of a node instead of using a command line.  So, we have that
functionality in Torq, but this is about more than that.  So, we have very
advanced automation, for example, where we're replacing the need for creating
most simple automation flows with the ability to do that with the UI and also do
that through a workflow method.  So, this is where you can basically make a
decision engine.  So, for example, "If your channel balance is lower than X,
send me a message and close the channel".  Or, and then, for example, open a new
channel to the same node.  So, for example, if you always want a private channel
to Cash App or River, then you can set that logic up so it always renews the
channels when needed.

So yeah, that's one part, and the v1.0 release there added some features, but it
also added a visual logs functionality.  So, when you run a workflow that closes
channels, you want to make sure that you don't mess up a filter.  Let's say you
want to check that you open the channel always to a certain node, but only if
conditions are right.  If you mess up a filter there, you can end up closing all
channels or opening a ton of channels.  So, we built in a logging mechanism
where you can both see what has happened on real runs, but you can also run dry
runs.  And then you can go in and see what actions were triggered, what was the
input, what were the filters applied, and then basically walk through that
visually.  So, you have a diagram showing the graph of the decision engine.  So,
it's actually like a directed acyclic graph, and you can click on the different
elements and the different paths of that log and see just the relevant log items
for that.  That was a major feature in the Torq v1.0 release.

We also have in there a Hash Time Locked Contract (HTLC) firewall, which is
similar to like CircuitBreaker, as that's part of the workflow.  And we have
functionality to move funds between your nodes, which is another very important
part of Torq, because large companies or companies generally run more than one
node in order to have redundancy, and the ability to update one node while
they're still operational.  So, multi-node management is also a major topic in
Torq right now.  So, I've been speaking for a long time there, maybe there's
some questions.

**Mike Schmidt**: None from me, Murch, you?

**Mark Erhardt**: No, it sounds good.  I think I've heard so often in the last
year that node management is a little bit of a headache and that running a
Lightning node as an amateur is taking a lot of time.  So, this sort of software
sounds like it would definitely have a market fit somewhere.

**Henrik Skogstrøm**: Yeah, thanks.  And to add there, Torq is very simple to
use, so you can use it as a smaller node.  But again, our mission is to reduce
all the need for making the default software that every Lightning company needs
to do.  It doesn't make sense if you're building a wallet app or you're building
an exchange on Lightning, or something, that your customers don't use your
product because of your wonderful node and how well your node runs.  They're
really using it and choosing your product for everything around it.  So, our
goal is to replace the need for all that basic functionality that you need in
order for your company to get started on what's actually important, and building
the products that your customers love.

**Mike Schmidt**: Dawn, did you have a question, Dawn of an empire?

**Dawn of an Empire**: Sorry about that.

**Mark Erhardt**: I did not understand that.

**Henrik Skogstrøm**: Could you repeat the question?

**Mike Schmidt**: And he's gone.  Okay, well, Henrik, thank you for joining us
for these first couple of items of the client services and software section.
You're welcome to stay on and chat the rest of the newsletter.  If you have to
drop, I understand.

**Henrik Skogstrøm**: Thanks for having me, I'll hang around a bit.

_Blixt Wallet v0.6.8 released_

**Mike Schmidt**: Blixt wallet v0.6.8 released, which adds support for hold
invoices and zero-conf channels.  Maybe as a reminder of hold invoices, also
called hodl invoices, instead of immediately locking in and settling the HTLC,
when a payment arrives, the HTLC for a hold invoice is locked but not yet
settled.  And at that point, it's not possible anymore for the sender to stop
the payment or revoke the payment, but the receiver can still choose whether or
not to settle or cancel the HTLC invoice.  One use case of this would be, if
there's a merchant online selling something and taking payment, but only
settling if and when they can actually fulfill on the item, maybe they need to
go check the warehouse or some such thing, and once they see that they can
fulfill, they can settle the invoice; and if not, then they can cancel the
invoice.

Then for zero-conf channels, the PR feature noted that it isn't zero-conf
channels just for anybody, but you can add pubkeys for nodes which you would
like to accept zero-conf channels from.  So, that's Blixt Wallet.  Murch, any
questions or comments there?

**Mark Erhardt**: None from me.

_Sparrow 1.7.8 released_

**Mike Schmidt**: Next release that we highlighted was the Sparrow 1.7.8
release, which added support for BIP322 message signing and also had
improvements for RBF and CPFP fee bumping features.  And the message signing for
BIP322 is for single-sig addresses, but it does also include P2TR.  So, that
would allow a wallet to sign some sort of an arbitrary text string by producing
a signature, and that's done using a virtual bitcoin transaction.  Murch, I
think BIP322 is still in draft status.  Are you aware of any progress around
that BIP?

**Mark Erhardt**: Yeah, I'm afraid that it hasn't gotten that much review, and I
think it's been basically just floating for two years.  This may be the first
implementation that I know of.  I don't think I've heard of another one before.

_Open source ASIC miner bitaxeUltra prototype_

**Mike Schmidt**: Next release that we highlighted here was the open-source ASIC
miner bitaxeUltra prototype.  And this is an open-source ASIC miner that is the
third major revision of this bitaxe open-source mining chip.  Essentially, they
took I think the Bitmain 1366 ASIC and used that as inspiration, which was I
think one of the S19 miners, and essentially this is an open-source project
around that, so all the design files are provided.  I thought this was a little
bit interesting, even if outside the box of our normal topics.  Murch, any
thoughts there?

**Mark Erhardt**: First time I hear about it, to be honest.

_FROST software Frostsnap announced_

**Mike Schmidt**: Next piece of software that we highlighted this week was
Frostsnap, which is an interesting team that's put together a project based on
FROST where, okay, so I guess maybe we should step back and talk about FROST.
So, FROST is a threshold signature scheme where you can have k-of-n signatures,
as opposed to something like MuSig where you have m-of-n signatures.  And their
goal is to, "Provide access to funds through a threshold number of devices", and
they have a few different features that would be available given this FROST
architecture.  So, "Users would be able to change devices belonging to their
multisignature without having to make any onchain transactions.  With Frostsnap
devices, users would be able to add new signers to your key.  If you lose a
device, you can replace it.  If a device is stolen, you can make every other
device incompatible with the compromised ones".  And it says, "We can adjust our
multisig as necessary while still controlling the same Bitcoin wallet and
private keys".

What's underlying this Frostsnap software is this secp256kfun library, which is
something that's been in development for some time, based on GitHub, and that's
authored by Lloyd Fournier.  Murch, did you get a chance to look into this at
all?

**Mark Erhardt**: I did not, but I'm familiar with the ability of FROST setups
to switch their keys under the hood, and the way that that works is in this
threshold signature scheme.  Of course, you only need signatures or
participation of a subset of keys up to the threshold in order to provide a
sufficient signature.  So basically, what you do is you use the key material
from that number of keys to generate unrelated new keys of a new quorum, and
then this new quorum can basically take over from there, and people delete, or
the former participants that created the new quorum can delete their old shares.
And that way, you can actually move devices or more specifically, bring into the
quorum new devices that have new keys, so you're not transferring key material,
but generating new key material for the new devices.

So that's pretty cool because you can essentially move your wallet around
without moving the UTXOs, and that can save quite a bit of -- well, moving UTXOs
is expensive, right?

**Mike Schmidt**: It sounds somewhat magical given the current state of things.
What is your assessment on the maturity of the FROST ecosystem; is this ready
for primetime yet?

**Mark Erhardt**: I'm not sure about that.  I mean, these new crypto libraries,
they need to really be checked out.  I don't have an opinion on it because I
haven't looked at it myself.

_Libfloresta library announced_

**Mike Schmidt**: The next piece of software that we highlighted this week was
Libfloresta.  And so, this is based on Floresta, which we covered back in
Newsletter #247, which is a utreexo-backed server that is Electrum
protocol-compatible; we talked about that a few weeks ago.  And the author of
that Floresta software modularized some of the underlying libraries that he was
using and published them publicly as this Libfloresta Rust library, that folks
can use to achieve some similar functionality in their own wallets by using that
library.  So if you're looking to do utreexo-type stuff, take a look at this
library.  Murch?

**Mark Erhardt**: All good, go on.

_Wasabi Wallet 2.0.4 released_

**Mike Schmidt**: The last piece of software that we highlighted this week was
Wasabi Wallet 2.0.4 being released.  And specifically, I included this piece of
software as there were some new features around fee bumping with RBF and CPFP,
as well as some of their coinjoin improvements and some faster wallet loading
RPC enhancements and other improvements, but specifically the addition of RBF
and CPFP I thought was interesting.  Murch, any thoughts on the Wasabi release?

**Mark Erhardt**: No, sorry!

_Core Lightning 23.08rc3_

**Mike Schmidt**: Moving on to the Releases and release candidates section of
the newsletter we highlighted Core Lightning 23.08rc3.  We covered some of the
pending features from the rc2 last week, and we also had Lisa and Dusty on from
the CLN team on #262 podcast, where we chatted through a bunch of the CLN PRs
that went into this release.  And I've also seen that since this newsletter,
this release is actually officially out, so I suspect we will cover it more in
next week's newsletter.  So, Murch, did you have anything to add, or do you want
to talk more about this next week?

**Mark Erhardt**: Next week sounds good.

_HWI 2.3.1_

**Mike Schmidt**: The other release from this week was HWI 2.3.1, which is just
a minor release.  It has some decoding that's used by the BitBox02 hardware
signer, and it also fixed some issues with the Qt GUI.

_Bitcoin Core #27981_

Moving on to the Notable code and documentation changes, I will take a moment to
solicit from the audience any questions or comments you have on this newsletter.
We'd be happy to take that at the end of the Twitter Space.  First PR this week
is Bitcoin Core #27981 and, Murch, I'm going to lean on you for this one about a
bug that could have potentially caused two nodes to be unable to receive data
from each other?

**Mark Erhardt**: Yeah, so this fixes an issue where apparently if two nodes
were both trying to send a boatload of data to each other, they could get into a
stall where they would not want to receive data until they had sent their own
queue.  And this was, I think, mostly for dust protection.  Now, the behavior
has been changed a little bit to prevent this stall.  When nodes are in this
situation, they will allow to receive some data, but then instead of blocking
completely, they'll permit some data to flow and perhaps that can break the
stall.  It does, however, if it takes just more than one send to move over the
whole data, it will still insist on trying to send its data all the way, unless
the other party declines.

This one sounded pretty weird to me, I had not heard about that before.  It's
good that it's fixed now.  But it also sounds like it probably would have been a
very uncommon situation.

**Mike Schmidt**: This is a bug that was originally discovered in the Elements
open-source sidechain software that powers Liquid, and so they discovered that
and surfaced this issue.

_BOLTs #919_

Next PR is to the BOLTs repository #919.  It updates the LN spec to suggest that
nodes stop accepting additional trimmed HTLCs beyond a certain value and a
trimmed HTLC is a payment, affordable payment, that is not added as an output to
the channel commitment transaction because it would be uneconomical chain;
essentially, it would be dust value.  So instead, amount equal to that trimmed
small HTLC is allocated to fees instead.  So, if the channel that needs to be
closed while the trimmed HTLCs are pending, then that node can't reclaim those
funds.  And so obviously, if that were to happen too many times, there would be
a non-trivial loss, and so the node needs to limit the number of those
potentially problematic trimmed HTLCs, and actually many implementations already
have added such a limit.  About two years ago, LDK, Eclair, and CLN added that
limitation, and now it's actually part of the spec as of this BOLTs PR.  Any
thoughts on that, Murch?

**Mark Erhardt**: Yeah, so we've talked about trimmed HTLCs in a few contexts
lately.  So, one was that there was a situation where when a node stopped
responding while a trimmed HTLC was in flight, then it could cause the channel
to be closed altogether, because the other node would of course see the trimmed
HTLC timeout.  And then it wouldn't be worth it to claim onchain, but it would
still close the channel in order to sort of end the HTLC.  Then, this could
cascade down the chain because now the next node would never hear about that
HTLC and also close that channel.  So, there was a recent change where, I think
it was CLN, and now it decides to rather close downstream as failed and just eat
the cost of that.

So, in light of this sort of behavior, where nodes begrudgingly accept to lose a
little bit of funds, it does make a lot of sense to me to explicitly limit the
exposure to these sorts of tiny payments.

_Rust Bitcoin #1990_

**Mike Schmidt**: Next PR from the newsletter is to the Rust Bitcoin repository,
#1990, and it adds a "Small hash function as a smaller but slower substitute for
existing hash implementations in Rust Bitcoin", and the PR noted that on
embedded processors it can lead to a 52% size reduction.  Any comments on that
one, Murch?

**Mark Erhardt**: In a previous life, I worked on an industrial camera with
image recognition, and one of the biggest limitations was that we were working
with C++98, because newer C++ required too much space on the device.  So, I feel
for these people.

_Rust Bitcoin #1962_

**Mike Schmidt**: In a similar vein, the next PR to the Rust Bitcoin repository,
#1962, now checks for the x86 architecture hardware, and then runs an optimized
set of instructions specifically for that architecture for any SHA256
operations, if it finds it's on that particular architecture.  So, optimization
there.  Any comments, Murch?

**Mark Erhardt**: No, not directly.

_BIPs #1485_

**Mike Schmidt**: Last PR this week is to the BIPs repository, #1485.  And this
is a PR to update, one, the draft drivechains BIPs, BIP300, and we noted in the
newsletter, "The main change appears to be a redefinition of OP_NOP5 in certain
context to OP_DRIVECHAIN"; and I guess somewhat related to this BIPs PR is, I
also saw this week that there is an open work-in-progress BIP300 drivechains
consensus level logic PR that has been opened to the Bitcoin Core repository.
Murch, do you have nothing to say or a lot to say on this?

**Mark Erhardt**: I don't think I have an opinion on this at this point.  But we
do have Max Hillebrand on right now, so maybe if you wanted to say something
about Wasabi?

**Max Hillebrand**: Yes, hello and welcome, and thanks very much for the
continued amazing work at Optech.  265 is a big number; hopefully it keeps going
up a lot more.  And with the latest Wasabi release, there are numerous important
improvements, but one that I'd like to highlight is a trick on drastically
improving or decreasing the wallet loading speed when BIP157 compact block
filters are used.  These compact block filters have a false positive rate,
meaning that every public key that gets checked against the filter has a certain
percentage of returning as a positive match, even when in reality this public
key is not a part of that Bitcoin block and filter.  And therefore, the larger
number of keys you check against a filter, the larger the occurrence of false
positive hits on the filter, and these blocks then have to be downloaded over
the Tor network, which takes some time and increases wallet loading speeds
dramatically.

So, a trick that we've now implemented with the latest release is that we have
two separate synchronization processes, where in the first lazy synchronization,
we only check for unused received addresses, so those where we are currently
awaiting payments for; but we exclude addresses that have already received money
in the past and addresses that are used.  So, this means that initially the set
of keys used to scan the block filters is much smaller, the false positive rate
is much smaller, the unnecessary block download is much lower, and we can show
the user an open wallet with an adequate balance very quickly.  Then later in
the background, we continue the synchronization of block filters across those
set of keys that have been used in the past, because potentially there might be
an address reuse payment, for example, that needs to be detected.

The second synchronization includes a lot more keys, therefore more blocks have
to be downloaded, and it will take some time longer.  And in some cases, the
user will see his balance increase after that second synchronization is
included, where new UTXOs have been discovered.  So this speeds up wallet
loading time quite substantially and might be important for other wallets that
implement these block filters for wallet discovery.

**Mark Erhardt**: That's a really cool approach.  I was wondering, did you have
this issue in practice that Wasabi wallets would download blocks more often than
you expected; or how did you come to the point that you wanted to implement this
in the first place?  Because I did some calculations a while back, and my
understanding is that if you are looking for about 1,000 scriptPubKeys, you
should only need to download a block roughly every eight weeks.  So do you just
have so much more output scripts that you're tracking, or…?

**Max Hillebrand**: Yes, that is the case specifically in a coinjoin wallet
because coinjoin rounds tend to fail and we generate new addresses, and a lot of
new addresses are being generated in general with these coinjoin self-spend
transactions.  So, yes, some Wasabi wallets have thousands, tens of thousands of
addresses, and that takes quite a lot of time.  And on top of that, we download
blocks over Tor, which can be quite unreliable as well, and that just compounds
the issues.  Yeah, but it's something, as you say, it makes a big difference if
you check for 20 keys versus 10,000!

**Mike Schmidt**: Max, thanks for jumping on and highlighting that.  I was
excited about the RBF and CPFP stuff.  And I saw that there was this note about
faster wallet loading, but I'm glad you were able to highlight some of the tech
behind there, because I think folks may be interested in your approach if they
find themselves in a similar situation.

**Max Hillebrand**: Yes, the speed-up transaction feature was also, of course,
heavily requested, especially in recent high feerate environments, which we can
expect to be there in the future, so we rolled out several fee-related
improvements.  Some of them we could deploy on the backend side, which is a much
smarter feerate estimation.  Bitcoin Core is rather lazy in its adjustment of
the feerate because it does not take the mempool into account.  So, we now use
the mempool feerate histogram feature to see the mempool, and we pick the top
certain megabytes of the mempool to see what the feerates are being paid in
different parts of the mempool, and we adjust our upper and lower bound of
feerate for this.  So, this means that the coinjoin feerates are now much more
real-time adjusted and therefore a lot faster confirmation time, while still
having lower feerates in a lot of different circumstances.

On the client side, the RBF and CPFP fee bump techniques have been implemented
with an important preference of this complexity that should not be exposed to
users, because the UTXO set is already confusing enough and RBF and CPFP are
very complex and nuanced.  So user-facing, it is a simple right-click and
speed-up transaction button, where it shows what fee has to be paid and it just
executes it.  Canceling the transaction is also available.  And Wasabi simply
picks in the background whichever method is for the specific case preferable to
then ensure that optimal block space efficiency is used.

**Mike Schmidt**: Excellent.  Thanks, Max.  Murch, anything to add here?

**Mark Erhardt**: I think that's a really cool idea to make the wallet choose
the appropriate tool for the job and not put that on the user.  I really like
that solution.

**Mike Schmidt**: Thanks for hopping on, Max.

**Max Hillebrand**: Yes, thank you again for having the podcast.  And I would
refer to the Wasabi blog for some further details on the different improvements,
also to the coinjoin block space efficiency, there's some interesting stuff
there too.  Thanks for having me.

**Mike Schmidt**: Thanks to everybody for joining us today and our special
guests and to always, my co-host, Murch.  We'll see you all next week.  Cheers.

**Mark Erhardt**: See you next week.  Bye-bye.

{% include references.md %}
