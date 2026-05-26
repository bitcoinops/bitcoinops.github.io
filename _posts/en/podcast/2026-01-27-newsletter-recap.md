---
title: 'Bitcoin Optech Newsletter #389 Recap Podcast'
permalink: /en/podcast/2026/01/27/
reference: /en/newsletters/2026/01/23/
name: 2026-01-27-recap
slug: 2026-01-27-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by René Pickhardt to discuss [Newsletter #389]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-0-27/416956680-44100-2-1c15e68a2b9ca.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt:** Welcome everyone to Bitcoin Optech Newsletter #389 Recap.
Today, we're going to talk about some payment channel network research; we have
our Changes to services and client software monthly segment with a couple of
items; and we also have our Releases and Notable code segment per normal.  This
week, Murch and I are joined by René Pickhardt.  René, you want to say hi to
folks?

**René Pickhardt:** Hey everyone, thanks for having me.

_A mathematical theory of payment channel networks_

**Mike Schmidt:** Thanks for joining again, René. This week, we're going to talk
about your paper in the news item, "A mathematical theory of payment channel
networks".  René, you posted to Delving Bitcoin about the publication of your
new paper, "A mathematical theory of payment channel networks", and you unify
some of the research and LN observations that you've sort of put out of the
years into a single framework.  Maybe, for listeners who haven't read the paper
yet, and who haven't, for themselves, synthesized what you've been doing in your
work over the years, maybe you can help us understand what's the most useful
mental model that you want folks understanding payment channel networks and
Lightning to take away from this?

**René Pickhardt:** Yeah, that's a big question.  So, the paper summarizes
basically everything that I've been working on over the last seven years, but
the main focus, I should say, is liquidity and how liquidity works on the LN.
Everyone who is running a node or a service has experienced the fact that
sometimes payments fail and it's hard to find a route.  And when you are routing
nodes, you want to keep your liquidity available, but the channels tend to
deplete all the time.  And for many years, people have been discussing that we
are just not finding the right fee settings, for example, to get balanced flows,
or we just haven't figured out how to connect to which nodes properly, because
these phenomena emerge.  I was lucky enough to be able to go deeply and study
the dynamics of what's happening on the LN and I provided this mathematical
geometrical framework to express what's going on.  And what we can see is that
some of the stuff that people are experiencing on the LN is just very natural to
emerge, and basically it has to emerge by the way the protocol is designed and
how the protocol works. So, the fact that some payments are infeasible is
strongly connected to the fact that liquidity is always shared only between two
peers and you cannot really move liquidity from one channel to another channel
unless you do an onchain transaction.  I mean you can rebalance the channel but
that changes liquidity of everyone else who is participating in your circular
rebalancing.  And yes, depletion is a fact that is connected to the linear fee
structure of the PPM.  So, yeah, these are basically the observations.  And I
think the interesting question is, are there ways how we can mitigate this on a
protocol level, make web protocol extensions, because these phenomena are not
bad user behavior.  I mean, they're connected to a selfish user behavior and
self-interest, but I mean that is something we should always expect that people
do, right?  That's fine.

**Mike Schmidt:** Okay, so you touched on a few different things there.  One
thing that I feel like you maybe have been on the show and talked about this,
but I feel like it's part of your big picture is, maybe just recap for us and
for folks, what is this feasible wealth distribution?  Like what are wealth
distributions and how does that play into your framework?

**René Pickhardt:** Yeah, so let's assume Mike, Murch, and I, we have 21 coins
in total on the LN.  Technically, if we collaboratively shared 21 coins, we
should be able to distribute those 21 coins among each other in whatever
distribution we like.  So, in the extreme case, Mike gets to own all the 21
coins.  But if Murch and I have a payment channel that is of, let's say, a size
of 7 coins, those 7 coins cannot leave the channel that is between Murch and I.
So, in that scenario, Mike could at most only on 14 coins.  And if we were to
transfer more than 14 coins to Mike, we would have to close the channel between
Murch and I and increase a channel that is bigger between Murch and Mike or
between me and you, Mike.  And this effect only gets stronger the more
participants join the LN. So, I recall actually back in 2018 when I started
looking at the LN, I was at the Lightning Hackday and we discussed autopilots
and automatic topology generation.  At that point in time, a lot of the
fundamental constraints, something like 300,000 transactions in bitcoin per day,
were obviously known, but we didn't discuss feasibility.  We assumed an
autopilot would generate a topology where everyone would basically collaborate
with each other.  And at that time, in this blog article, I wrote the sentence,
"I dare to say that a bigger network is generally good for the network".  But as
we just discussed with this feasibility thing, it's actually a problem.  And
what is good for the network or what might be better for the network is if we
had multiparty channels.  So, for example, if Mike, Murch and I had a
three-party channel, well then, of course, again every wealth distribution of
these 21 coins among us three people would be possible again without doing an
onchain transaction. So, yeah, one main result of the paper is that two-party
channels are a very strong constraint to liquidity.  And this provides an issue
because some people's become only feasible if we do onchain transactions to
change the channel graph.  And we can only do that many per second, per minute,
per day, per block, you name whatever frequency you want.

**Mark Erhardt:** So, what I'm hearing is that basically, in general, funds that
are in the LN are allocated to specific channels and they can either be on one
side or the other side of that channel at the extremes.  But obviously, they
cannot flow from one channel to another.  So, the entire amount that is
allocated to the LN cannot be owned by one party.  And the more parties there
are, the more distributed and the smaller the portion of coins that can only be
owned by one party.  But what I'm not hearing is, that means that if parties
that want to own more coins in the LN just open more channels, they do increase
the amount that they can hold to the degree that funds can be allocated from
other channels to them, right?  So, obviously the entire network is still an
external limit on how much can be transferred to them, but their own channel
allocation can be increased by having more funds in the network.  I don't know,
that's just restating what you're saying, right?

**René Pickhardt:** That's absolutely right.  And I mean, I'm not saying that
the LN is not useful here.  I mean, we can already see that small payments work
fairly well, and within the feasibility region it's really possible to do quite
a lot of things and obviously, liquidity also is a local thing.  So, I mean,
Murch, if you and I were, let's say, exchanges and we were frequently sending
back and forth payments, I mean we just create a large channel between the two
of us and we don't care what the rest of the network does.  But for the routing
part of the network, while it's possible that I allocate some more of the coins
that I own in the channel between you and I, Murch, to your side, depending on
you allocate some of the coins that you own in another channel to somebody else.
I mean, that also works, but it only works to a certain limit because you affect
liquidity of others.  And that, once in a while, occurs a problem and yields a
change of topology or reallocation of liquidity.  And there is hardly anything
we can do about this with respect to, "Hey, let's create a better topology", or,
"Hey, let's be smarter with whom we open channels".  These problems are
structural. I think it's important for developers, for the community to
understand these, because then, and this is the positive note of this research,
I mean if you note, the research is posted in a Git repository called, "Limits
of Lightning", because I was trying to study those.  And we need to decide how
to address those.  And there are, well, potential ways to go down, but they may
be complicated to implement and come at costs.  And this is a discussion that,
at some point in time, we need to take.

**Mark Erhardt:** So, basically we have independent dimensions here.  For the
funds that are allocated to the LN, the more participants there are, the less
can be allocated to one party.  But of course, people could go and allocate more
funds to the LN.  And there are still other things that we can do.  So, you
already mentioned that it would maybe be possible to have channels that are
multiparty channels instead of two-party channels.  There has been a lot of work
going towards either APO (ANYPREVOUT) or other ways of implementing LN-Symmetry
as a different mechanism for doing channel updates, which would be hopefully
much easier to use in a multiparty channel capacity.  You've also now brought up
that Ark might be considered a channel factory in this context.  So, because
Arks virtualize a lot of the UTXOs between rounds, you could have virtual
channels and therefore consider one UTXO shared between many different parties
to form virtual Lightning channels that could mitigate this to some extent.  How
about we dive a little more into that?

**René Pickhardt:** Sure.  So, let me be clear.  Just because I mentioned Ark as
a potential use case in this scenario, doesn't mean that concepts like Eltoo
would not work.  I mean, I think Eltoo would be a vast and major improvement for
the LN.  I think as a solution, as far as I understand it, and I might be a
little bit limited here, is that with Eltoo, you basically have to find your
group of people with whom you create a channel, and that will be your funding
transaction.  So, you could create like a 100-party channel, right?  And channel
state maintenance with the Eltoo scheme would work among these 100 people.  But
if then, at some point in time, Mike, for example, would decide, "Hey, I also
want to join the party", well then you have to make an onchain transaction again
to anchor this to like a 100-party channel funding transaction.  Because before,
it's always 100 people that needed to sign off something; and if Mike joins or
wants to leave the party, that yields an onchain transaction.  Whereas in Ark,
the membership problem is a little bit easier because you always have the Ark
service provider as a coordinator.  I mean, of course, they also do onchain
transactions, let's not forget this.  But within this one onchain transaction,
they can actually create a lot of new vTXOs also to new members.  So, that is a
little bit more dynamic from the way how you would construct this thing.  That
is why I think Ark is very interesting with respect to that. What I'm not sure
is how you could, for example, combine Eltoo ideas at Ark.  I mean, Ark
initially was also proposed with, "Hey, if we create this soft fork and we have
a covenant-style thing, well then things become easier in Ark".  And I think
with the Eltoo mechanism, you might be able to also solve this membership
problem, I'm not sure.  You would have to ask Christian on this probably, or
Greg, I don't know, Greg Sanders.

**Mark Erhardt:** Yeah, just for context, when René is speaking about Eltoo,
that is also referring to what we now call LN-Symmetry.  It's the original name
of the proposal.  This is about having symmetric channels where the commitment
transactions are the same for all parties in the channel, rather than having
asymmetric commitment transactions as in LN-Penalty, which makes it much harder
to have multiple parties, because you'd get into issues like assigning blame for
the penalty and constructing these multiple asymmetric transactions for every
update.  For LN-Symmetry, because the commitment transactions are all the same,
that is much easier and scales to larger numbers.  But of course, if you have a
large number of participants in an LN-Symmetry channel, every channel update
needs a sign-off by every single participant, which then makes it more brittle
in that sense, that if any one party starts communicating, the channel might
shut down and need to be executed onchain and reopened with the remaining
participants. Now, of course, that got a little better since we have splicing
now as a tool, to update channels on the fly.  But yeah, with virtual channels,
potentially it would be much easier to scale up users and scale up channels
without as much onchain transactions.

**René Pickhardt:** But to be fair, I mean also under the Eltoo multiparty, or
LN-Symmetry multiparty scheme, you could imagine a situation where the updates
are also only virtual channels.  So, you wouldn't have to create a new one -- I
think they're called update transactions under the scheme that Christian
proposed -- so, you wouldn't have to create a new one every time you make a
payment among the people in the multiparty channel, but you could create one
just to create virtual two-party channels.  And you would also then only change
those offchain and then need a sign-off for everyone.  So, I think the
difference between the LN-Symmetry and Ark model is just how you do the
interactivity requirements and communication requirements.  But the advantage
for offchain payments to widen the feasibility region and to make more payments
feasible, those should be the same.

**Mark Erhardt:** For context, Christian Decker, I think with, I don't recall
the other name, but I'm not talking about LN-Symmetry, but rather the channel
factories paper, which I think was a master thesis by a student of Christian, is
a proposal to basically have these virtual channels that are coordinated in the
form of an LN-Symmetry channel.  So, you would have virtual channels that live
inside of an LN-Symmetry channel that are bilateral, and then if any of those
wants to update, only the two parties participating in the virtual channel need
to update; whereas if you want to create new virtual channels, you need activity
of all participants of the channel factory.  There is a very good description by
Dave Harding on the Stack Exchange that explains channel factories, if you're
interested in this topic.

**René Pickhardt:** Yes, and the same concept could work in an Ark, right, where
the advantage in Ark is, if Murch and I had such a channel and we wanted to
increase the capacity, well we only would have to talk to the Ark service
provider and don't get a sign-off by everyone else in our round.

**Mark Erhardt:** Right, we could basically splice-in with a virtual transaction
in the Ark.

**René Pickhardt:** Yes.  But again, the same concept could work in an Eltoo
scheme.  It's just that everyone else has to sign off.

**Mike Schmidt:** René, your paper is titled, "Mathematical Theory", and I'm
curious, how do you think about grading the practicality of this?  How much is
this a concern today?  I have no doubt that you have your theory and your
proofs, but should we be worried today, or is this just like, okay, in theory,
this is a constraint at certain points, or how do we know where we are in there
practically?

**René Pickhardt:** I mean, there is a blog article from the folks at
amboss.space, for example, that explains that for them, they very much look at
max flow as a metric to improve, and that is one of the things that basically
comes out of my research and is part of what I'm saying, because I'm saying the
feasibility region is directly connected to the min cut in the network and you
know there is in research the min-cut max-flow theorem that basically says this
is the same.  So, for them, they actually use this internally quite a lot to do
computations and to help people with assigning liquidity on the network.  So,
they, at least as far as I understand, have used this theoretical framework
quite extensively in practice in order to make better decisions.  But even if
you make the best decisions, you hit boundaries.  So, I think it really depends
on how frequent the LN is actually being used for payments. I have the sense
that wallets are out there, technically everybody could log on to the LN.  But
if I go to the last BTC++ conference that I participated, I saw something like,
"Hey, in our company, we see basically that many percent of payments that we do
are on the LN".  And I mean, I don't think even the LN currently captures as
many payments as we can put into the blockchain.  So, we haven't really seen a
huge uptake of Lightning payments.  And I'm not sure if it's a chicken-or-egg
problem.  If people realize it's not reliable enough, too many payments fail, so
therefore we don't push it enough.  Or if it's the other way around, that we
don't see the boundaries because it hasn't been taken up so far.  But my feeling
is if it were to take off and really scale and people would really make a run
and use this technology, we would see the limits very quickly. So, therefore, my
feeling is we should fix those and make the technology just more robust and make
it easier for people to use and make it make the reliability guarantees
stronger.  That's my feeling.  But I do see that people who run a local service
provider, you know, they just facilitate payment between their LSP (Lightning
Service Provider), they're like, "Yeah, we're happy enough, we have enough
onchain transactions that we can use to reassign liquidity, and we make just one
huge channel to our service provider whatsoever, and then we have mobile
clients", and they're happy with it.  So, my feeling is some people may not
experience the severity of the limits yet.  So, we will have to see when the
research is being taken seriously as in, yeah, there are actually practical
limits that we experience and we need to address them.

**Mike Schmidt:** Makes sense, thanks, René.  I guess I should mention for folks
who are curious about these kinds of topics, that if you go to the Optech
podcast list page, you can search for René's name, you can see all the times
he's appeared on the show.  Obviously you can also search his name within the
Optech website in your favorite search engine to see previous coverages with
René, where we've gotten deep on some of these, including a deep dive on channel
depletion research, and things like that.  So, if folks are curious, there's
more there, in addition to obviously the paper that we're covering this week,
which you should take a look at.  Did you have something?

**René Pickhardt:** Yeah, that's, by the way, why I didn't talk so much about
depletion, because we had covered it in depth on the podcast before.

**Mike Schmidt:** Anything else?  Okay.  Murch is good.  René, what's feedback
been like and what are you looking for from potential listeners or ecosystem
participants as you depart?

**René Pickhardt:** So, I think when I discuss individually with people, they
acknowledge that these problems exist and are severe.  I also have the feedback
that basically summarizes a little bit of what I just mentioned, as like, "In
our operation, the problem is not relevant to us yet.  For what we do locally,
stuff works and we have figured out how to handle our operations".  I think what
I wish for is that the protocol developer community starts to think in the
direction of how to address the issue of widening the feasibility region.  As we
discussed in the show, we can think about LN-Symmetry and how to utilize channel
factories there.  We can think about how to standardize Ark and how to do this.
I think one of the ideas that is also out is just provide a general API on the
LN for multiparty systems, and then everybody can plug in their multiparty
system that they like. So, I think there are plenty of ways to go down, but I
think there is the opportunity to think about adding some form of interface for
multiparty channels into the protocol.  And of course, I do understand that's
much easier said than done, because you need to basically implement everything
of this.  And two-party channels implementation and making this work in all of
the software was a major effort.  And, yeah, I mean it's just a tremendous
amount of work and much easier said.  But I think at some point in time, if we
want the LN to succeed and to get a much wider usage and adoption, we need to
have that discussion.

**Mark Erhardt:** I'm not really following why implementing multiparty channel
would be such a huge lift once you generalize channels with LN-Symmetry, should
it get adopted, because the flow of funds through the channel would always be
that it enters at one node and goes to one other node.  So, the channel change
would still be between two parties on that channel.  And that seems pretty, at
least from an abstract point of view, exactly the model that we have.  You bring
the funds to one party in the channel and it is shifted to the other party in
the channel.  So, why do you think that once LN-Symmetry is there, it would be a
huge lift to make it multiparty channels?

**René Pickhardt:** I mean, you're correct.  If you just understand LN-Symmetry
as like a two-party system, the rest of the network doesn't care.  I mean,
Murch, if you and I do whatever we want as a protocol in our channel, and we
announce the channel properly, everybody can route through our channel, no
matter how we actually implement this.  But having something like a multiparty
channel, where we have virtual channels, I mean that's a change to gossip,
because currently channels are anchored to a funding transaction, unless we make
them unpublished, but then they're not usable for routing directly because
people are not aware of the channel.  And then, of course, we need to handle all
these things of like, I mean splicing is there, but currently splicing depends
on what we see onchain.  Now we would have this kind of like, I call it
statechain for a moment, you know, this multiparty system.  But I mean, this is
a lot of change.  It's just like a lot of implementation and integration work.
I'm not saying it's impossible. I mean, one of the arguments for Bitcoin
Magazine, I was asked to provide an article for their Lightning issue.  And one
of the arguments I made is, "Hey, I understand Lightning is hard, but we learned
quite a lot over the last years.  Let's not look at, 'Oh, there are shiny other
things like Ark, and let's just move there and be happy', because they may also
yield some tricky problems and some issues.  No, no, no, no.  Let's utilize upon
the experience that we have".  So, yes, we conceptually know how to do these
things, I'm just saying it's a lot of implementation work.  It's not like, "Hey,
let's make this small, incremental change where we add a new feature to
something", and it doesn't matter if one person implements it and the others
don't.  I mean, supporting for multiparty channels, that's just a huge lift in
code change.  It's not only like, "Hey, let's make a specification on this".
That was what I was trying to say.

**Mark Erhardt:** Right.  I think what I misunderstood was, it sounded to me
like you said that the conceptual support would be very difficult, and at the
protocol layer we would have to change a lot of things in order to enable
multiparty constructs.  But I think on the conceptual level, the work should
generalize pretty well; it is on the implementation level that it would be
heavy.

**René Pickhardt:** Yes, that is what I meant.  And if I talk to Lightning
developers who work on the spec, and if they would just ignore the fact that
they have implementations, like implementing the spec, it would probably be much
easier to be like, "Oh yeah, let's change just this primitive and make a
standard for multiparty channels".  Spec'ing this out is probably the easy part,
but integrating this in actual Lightning nodes, being even backwards-compatible
with all the two-party stuff, because it's still there and it facilitates the
core of the network, that's just touching a lot of parts of the software
implementations.  And that's the part where I fear a lot of hesitation comes
from, understandably.

**Mike Schmidt:** Well, René, we appreciate your time and joining us yet again,
and for putting out this research.  Thanks for your time.  You're welcome to
stay on, but you're free to drop.  We understand you have other things to do.

**René Pickhardt:** Well, I mean for me, it's in the middle of the night, as I'm
basically in the Australian time zone right now.  So, therefore, I would prefer
to drop off!  But thanks for having me and for covering this, and let's see what
happens here.

**Mark Erhardt:** Yeah, thanks.  Sleep well!

**René Pickhardt:** Yes, thank you.  Have a great day.  Bye-bye.

_Electrum server for testing silent payments_

**Mike Schmidt:** Cheers.  We next have our monthly Changes to services and
clients software segment.  We found two notable ones this month, first one
titled, "Electrum server for testing silent payments".  Right now, silent
payments has just seen a few different wallets implement, in terms of receiving,
and there's been a lot of tinkering with how the technology for scanning for
silent payments receiving could be done.  And one such prototype, which is now
out of experimental mode, is this Frigate Electrum Server, which actually
implements a portion of BIP352, which is the silent payments BIP.  There's
different sorts of roles or services that could be provided within the silent
payments ecosystem, and there's this remote scanner service.  And so, what Craig
did, Craig Raw, who works on Sparrow Wallet, he implemented an Electrum server
that does this indexing for silent payments.  And he found that I think a lot of
folks know that the scanning is quite intensive, but he found a little bit of a
workaround, if you will, by using GPU computation to reduce the scanning time.
As you can imagine, if someone's running an Electrum server and they want to
service more than one potential wallet, that that scanning time is really
important.  So, in order to support multi-user scanning services on an Electrum
server, he used GPU to sort of optimize that scanning process.  Seems like a
pretty cool piece of software.  I think initially when I drafted this, it was
titled, "Experimental and proof of concept".  But when I ran it by Craig, he
actually said he thinks it's ready for primetime.  So, I took that out.  Murch,
any thoughts?

**Mark Erhardt:** I did not know that Craig had meanwhile also written a whole
Electrum Server.  That's pretty awesome.  The Sparrow wallet ecosystem of
software seems to be expanding.  Do you happen to know whether this is based on
kernel or is this building on a different Electrum Server?

**Mike Schmidt:** I do not know.  I do not see the word 'kernel' in the README,
but that doesn't mean much.

**Mark Erhardt:** Well, either way, that sounds really cool.  I'm also always
happy when I hear about someone working on better support for silent payments.
I think it's still a super-cool thing and hope that soon it'll be more available
also on other software projects.

**Mike Schmidt:** We did have Craig on in #387, so a couple podcasts ago, we had
Craig on talking about silent payments, not necessarily this piece of software.
But if you're curious about some of the challenges in terms of building products
and services and usability with regards to silent payments, he definitely gets
into some of that and in talking about, it was a BIP around silent payments with
regards to backups, right, and some of the considerations there, including a
birthdate, which could speed up the scanning process and the necessary resources
for scanning.  So, if you're curious a little bit about silent payments, maybe
flip back to Craig talking about that.  I thought we got in pretty deep with him
there.

_BDK WASM library_ "BDK WASM Library".  So, this is bdk-wasm, which in WASM is
WebAssembly.  And so, this library provides access to essentially BDK features,
like essentially binding for JavaScript.  And you can actually run BDK-ish in
WebAssembly.  And what I thought was also interesting about this, in addition to
the library potentially being useful for people in those ecosystems, although
asterisks with all the WASM WebAssembly stuff, browser-based wallets, proceed
with caution; but the MetaMask folks actually built this, and then I guess gave
control of it once they launched to the Bitcoin Dev Kit folks.  So, it was
written by MetaMask, it's used by MetaMask to implement Bitcoin features in
their MetaMask wallet, and now run by the BDK team.  So, interesting to see.  I
don't know about wallet-y stuff in browser-y WebAssembly stuff, but maybe
there's more than just having a wallet in your browser that could be done with
WebAssembly and this bdk-wasm library.  Any thoughts, Murch?  Okay. Moving to
Releases and release candidates.  Gustavo, unfortunately, couldn't make it this
week to run us through his writeups on the release candidates and notable code
segments.  But fortunately, we have Murch, who's prepped these items.  So, we're
going to see how it's done.  Let's do it, Murch.

_Core Lightning 25.12.1_

**Mark Erhardt:** Thanks for the intro.  So, we are going to talk about two
releases, or rather one release and one RC.  There is a new release for Core
Lightning.  This is v25.12.1.  This is a maintenance release for the release
from December.  There's a few fixes.  So, in December, Core Lightning (CLN)
introduced a new way of handling the hsm_secret backup.  It introduced a format
that was based on BIP93 Codex32, which is a Shamir-Secret-Sharing-based proposal
or strategy how you can create your own key backups manually, literally by hand,
using a paper book with lots of tables.  I've done this once.  It took me an
hour to do one out of several keys and it is quite intensive, but you can do it
completely offline with pencil and paper.  So, anyway, CLN now can export the
hsm_secret backup with a mnemonic that is based on Codex32, but it hadn't
implemented the recover function.  So, this new maintenance release adds the
12-word mnemonic to the recover RPC method. There were also a couple of issues
where the key derivation switched to BIP86 for taproot, which BIP86, sorry, yes,
BIP86 is the description of how to derive new keys for P2TR.  But also, all the
old-style addresses, the other output types were derived with BIP86, but the
signing hadn't been updated.  So, you weren't able, with the new node, to sign
for addresses of the old types, but the funds were not lost, it's just that the
signing hadn't worked the same way as the key derivation, is my understanding.
So, there's a bunch more bug fixes here.  Some of them are also related to
hsm_secret, which is this plugin that allows you to have the secret separate
from the Lightning node.  And, sorry, I have one more note here.  Yeah, there
was an issue where the maxdelay parameter was not enforced properly, and that is
when the maxdelay was lower than min_final_cltv_expiry, route calculation would
ignore maxdelay and allow the route to be used anyway, even if it was higher
than maxdelay.  And this has been fixed. So, yeah, maintenance release fixes a
bunch of bugs, some crash bugs in plugins and also lightningd.  I believe in
some edge cases, but if you're running lightningd v25.12, you probably want to
take a look at this one and check out the release notes before.

**Mike Schmidt:** I was just going to plug, since you mentioned Codex32, it's
been a while since we talked about that.  I just wanted to plug that we did have
Russell O'Connor on in Newsletter Recap #239.  Wow, we've been doing these a
while, Murch.  And he talked about the BIP for Codex32 seed encoding scheme.
So, if you're curious about that, jump into that.  Just wanted to plug that.

**Mark Erhardt:** Yeah, thank you.  There's also a lot of work recently on
improving the writeup of BIP93 on the BIPs repository.  So, there might be some
updates to that BIP coming out soon.

_LND 0.20.1-beta.rc1_ So, the second item we have in the Releases and release
candidates section is LND 0.20.1-beta.rc1.  This is also a minor version, and
the main takeaways here were that they finally closed the oldest remaining issue
in the LND repository, which was number 53, after 10 years almost, it was open
since 2016, which improves the reliability for channel openings when there is a
reorg.  So, these happen obviously pretty seldom and then they'd have to overlap
with a channel reorg.  So, presumably, that was why it hadn't been addressed in
a very long time.  But this minor release finally improves the reliability in
phase of reorgs.  And then, I also saw that there was an improvement to
EstimateRouteFee.  So, when there are LSPs in a route, it will now differently
handle the routing for routes with LSPs that improves the flexibility and add
some griefing protections.  The release originally came out in November, and
there are a few other bug fixes and performance improvements.

_Bitcoin Core #32471_ All right, then we get to the Notable code and
documentation changes.  We have, for the first one up, Bitcoin Core #32471.
This fixes a bug with listdescriptors.  So, in Bitcoin Core, you can have
wallets that either have private keys or wallets that do not have private keys.
And in the case that you're trying to get a descriptor for a wallet with private
keys, but where the Bitcoin Core wallet doesn't have all of the private keys, it
used to fail and it would just not show you the private keys.  So, this happens,
for example, when you have a multisig wallet for which not all of the keys are
held by the Bitcoin Core wallet.  When you want to export the descriptor with
the private keys, it wouldn't work.  So, #32471 fixes this.  If you have only
some of the private keys, it will now properly show you the descriptor.  Yeah,
cool.

_Bitcoin Core #34146_ The second PR is also in Bitcoin Core.  This is #34146.
This improves the peer announcement, so the self-announcement of a node after
connecting to a new peer.  Maybe let me explain first what a self-announcement
is.  So, nobody really knows your IP address necessarily, because if you're
behind a router or something, or behind a VPN, or other things, your actual IP
address might be different than the IP address your peer sees.  So, when nodes
make a new connection, they don't use the perceived IP address, but they use the
IP address the node tells them as their own address.  We call that the
self-announcement.  These addresses are of course managed in the peer manager
and then forwarded to other nodes that ask us for addresses of potential nodes
to connect to.  And previously, the self-announcement, so where the node tells
its peer about its own IP address, was included in the first batch of addresses
that a peer asked for.  And this would (a) display a foreign address that might
be included in that batch, and (b) because it was handed over with a bunch of
other addresses, it might not be forwarded by the peer. If you now make a new
connection with a node, especially, and nobody's heard your IP address, you want
your node address to be announced a little more reliably.  So, the improvement
here is that instead of packing the self-announcement into the batch, we make a
separate message where the node announces itself to its peer only on the first
connection.  We also self-announce, I think, every 24 hours.  This is only for
the very first connection right after connecting to the peer.  We tell the peer,
"This is our address", so that they might talk to other peers about our address.

**Mike Schmidt:** Murch, this only happens the first time your node finds its
first peer?

**Mark Erhardt:** I think it happens the first time for every peer.

**Mike Schmidt:** Okay, for every peer.  Got it.

**Mark Erhardt:** But we announce our own address every 24 hours.  And for the
later announcements, we package it with the batch.  Just for the very first one,
we now make a separate message that only announces your own IP address, or other
network address.  Like, on Tor, it's not an IP address.

**Mike Schmidt:** Makes sense.

_Core Lightning #8831_

**Mark Erhardt:** All right, we're getting to Core Lightning #8831.  We already
talked about that earlier in the CLN release, but 25.12 started using BIP86 for
key derivation for all types of addresses and only used it for P2TR signing at
first.  This fixes that bug.  So, if you had any issues with old-style addresses
that were generated by your node and you couldn't sign for them, this is the fix
and it's out with the recent release.

_LDK #4261_ We continue with LDK #4261.  This is an update to allow splice-in
and splice-out in the same transaction.  This can now also allow that the
channel balance goes down if the splice-out is bigger than the splice-in.
Splicing support is continuing to roll out to different implementations, and
being able to do both of these things at the same time is pretty cool.  So, you
can take some funds out of your channel and some funds from your onchain UTXO at
the same time to create a payment.  Or you can stock up your channel at the same
time as making a payment.

_LDK #4152_ Next, we look at LDK #4152.  This adds support for dummy hops in
blinded payment paths.  We had previously reported on LDK adding support for
dummy hops in blinded messages.  That was Newsletter #370.  But in this one, the
same thing is added in blinded payment paths.  The idea here is, again, when you
have a blinded path, you include in your offer basically an onion package
already that includes the last few hops from an entry point to the actual
recipient.  So, the recipient that creates the offer obfuscates the last few
hops by having that onion there.  And with the dummy hops, you can have, I
think, up to 10 hops in the onion.  And the idea here would be some of them
might be after the recipient, just padding the onion package, which makes it
harder for the sender or anyone along the route to guess which node exactly is
the recipient.

_LND #10488_ All right.  With LND #10488, there was a bug where the maxChanSize
was supposed to only apply to incoming channels.  It was a configuration option
that allowed you to limit how big channels could be, a maximum capacity of
channels for inbound channels, but this was erroneously applied to fundMax when
you open an outbound channel.  So, the fundMax option is now no longer limited
incorrectly by the maxChanSize.  And instead, the fundMax option will use the
protocol level limit.  If you're running your node with the non-wumbo limit,
that's about one-sixth of a bitcoin.  If you run it with wumbo, it's 10
bitcoins.

_LND #10331_ One more LND.  LND #10331 is also the one that we already discussed
for the RC above.  This improves the reorg safety for channel openings and
closes the oldest open issue in LND.

_Rust Bitcoin #5402_ Next, we're getting to Rust Bitcoin.  Rust Bitcoin PR #5402
introduces a consensus bug fix, which is Rust Bitcoin used to accept
transactions that spend the same UTXO twice.  So, someone discovered that they
had a similar bug as the one -- sorry, there's a CVE, I don't have the number at
the top of my head -- that was in Bitcoin Core, where we did not catch if a UTXO
was spent twice.  And so, Rust Bitcoin now implements rejection of these invalid
transactions, because clearly a UTXO cannot be spent twice.

**Mike Schmidt:** Is that the CVE listed here, the CVE-2018-17144?

**Mark Erhardt:** Yeah, sorry.  Let me pull up the newsletter in the background.

**Mike Schmidt:** It inputs vulnerability.

**Mark Erhardt:** I think this is related, but it's not exactly the same thing.
But anyway, Rust Bitcoin was permitting transactions to spend the same UTXO
twice, or not permitting, it wouldn't catch these invalid transactions.  Now, as
far as I know, Rust Bitcoin is not used by any full node implementation, so this
would not actually lead to a consensus split on the network because there's no
nodes running it.  But it's good that these invalid transactions are correctly
rejected now.

_BIPs #1820_ Next, the BIP repository PR #1820.  If you listened to our episode
last week, we already discussed that quite a bit.  But in brief, this was the PR
that deployed BIP3, the new BIP process.  It also closed BIP2, because we only
can have one BIP process at the same time.  And it also updated all of the
published BIPs' formatting to match the new preamble requirements.  So, there
were actually a lot of changes to a lot of BIPs in #1820, and that was merged
last week.  And we are now using BIP3 as the guideline for the BIP process.

**Mike Schmidt:** And Murch is the author of this PR and BIP3.  So, congrats,
Murch.

_BOLTs #1306_

**Mark Erhardt:** Thank you, yes.  Very nice to have that wrapped up.  We have
an update to the BOLTs repository.  PR #1306 clarifies a behavior for invalid
offers.  So, if the offer_chains field is present in an offer, but empty, that
would be an offer that cannot be resolved, but it was not documented in BOLT12,
which is the BOLT that specifies the offers.  And BOLTs #1306 adds language to
clarify that such an offer should be rejected because it cannot be resolved.

**Mike Schmidt:** I assume just because it can't be resolved that there was no
issues coming from the lack of this specification, because you wouldn't lose
money or anything like this.

**Mark Erhardt:** I think someone might have not checked for that and that's how
it was discovered, but I didn't read into it deeply enough to know exactly how
it was found.  But yeah, so it's basically an edge case.  It was clearly already
invalid, but maybe someone hadn't implemented that edge case and stumbled upon
it during testing, or otherwise.

_BLIPs #59_ Our final PR that we're covering is BLIPs #59.  So, this updates
BLIP51, which is also known as LSPS1.  So, this adds support for BOLT12 in the
LSP spec, and LDK has implemented support previously.  We reported on this in
Newsletter #347.  Yeah, that's it from me.

**Mike Schmidt:** Awesome.  Yeah, thanks for handling those segments this week,
Murch.  We also want to thank René for joining us earlier, and for you all for
listening.  Cheers.

**Mark Erhardt:** Cheers.  Hear you soon.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
