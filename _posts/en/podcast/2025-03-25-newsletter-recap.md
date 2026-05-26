---
title: 'Bitcoin Optech Newsletter #346 Recap Podcast'
permalink: /en/podcast/2025/03/25/
reference: /en/newsletters/2025/03/21/
name: 2025-03-25-recap
slug: 2025-03-25-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Matt Morehouse, Yong Yu,
Alejandro De La Torre, Jan B, and Marco De Leon to discuss [Newsletter #346]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-2-26/397277243-44100-2-7e8915a138416.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #346 Recap.
Today, we're going to talk about LND's new dynamic feerate adjustment system; we
have 12 interesting ecosystem software updates, including DMND pool and their
Stratum v2 rollout; we have the Bitcoin Core RC 29.0 and Testing Guide; and
we're going to talk about a PR around checkpoints in Bitcoin Core.  I'm Mike
Schmidt, contributor at Optech and Executive Director at Brink, funding
open-source Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Localhost Research.

**Mike Schmidt**: Matt.

**Matt Morehouse**: I'm Matt Morehouse, I work on securing the LN.

**Mike Schmidt**: YY?

**Yong Yu**: I am YY, I'm from Lightning Labs.

**Mike Schmidt**: Alejandro?

**Alejandro de la Torre**: Hey, Alejandro, CEO of DMND, Stratum v2 pool.

**Mike Schmidt**: Jan?

**Jan B**:** **Hi, Jan, I'm a student of the 2025 Chaincode Labs BOSS Program
and currently working on Bitcoin Core.

**Mike Schmidt**: Marco?

**Marco De Leon**: What's up? I've been helping out with Core for about a year
now and I'm currently working with Brink.

_Discussion of LND's dynamic feerate adjustment system_

**Mike Schmidt**: Thank you all for joining us, this should be a fun one today.
We're going to start off with the News section.  We have one item this week,
which is, "Discussion of LND's dynamic feerate adjustment system".  Matt, you
are borderline a co-host at this point.  Thanks for joining us again.  You
posted to Delving Bitcoin as well as your own blog, a post titled, "LND's
Deadline-Aware Budget Sweeper", that both you and YY, or Yong, worked on that
also includes Yong's work on implementing functionality in LND.  Matt, maybe
talk to us about sweeping in the context of LN and you can pull in YY as
necessary?

**Matt Morehouse**: Sure, so the focus of the blogpost was on LND's new sweeper
system that was released in 0.18 last year and it's basically a rewrite of the
old sweeper system.  The general idea is to patch together HTLC (Hash Time
Locked Contract) claims that have similar deadlines, and then manage the fee
bumping of those transactions to make sure that they confirm before the
deadlines.  And YY could probably go into more detail, specifically about how it
works, but my main goal with the blogpost was to talk about the new fee-bumping
strategy that's used, because I've hoped to see other implementations adopt a
similar strategy, since it provides some nice security benefits.  So maybe, YY,
you want to talk about the general, what the difference with the new sweeper is
first?

**Yong Yu**: Sure.  So, I think the sweeper is really made based on a simple
idea, in that we just want to enable users to precisely manage the fees paid
when they are sweeping the outputs from a force close transaction.  And in the
sweeper system, we kind of view the cost from three aspects.  So, the first,
which is the most obvious one, is the miner fees that we pay when we collect
outputs; and then there's the second one, which is the potential loss if the
output is not collected, because some of the outputs have timelocks.  And if the
timelock expires, for instance, for say an incoming HTLC, we want to collect it
before the remote can spend it via the timeout path.

So, based on these two aspects, we introduced the concepts: budget and deadline.
So, the budget is the maximum mining fee that you are willing to pay to collect
the output; and the deadline is just simply the block high that this spending
transaction must be confirmed by.  And of course, finally, there's the aspect of
the cost, the time value.  So, for instance, the local output can only be
collected by the local node.  So, in theory, the deadline could just be
infinite.  But however, you may want to collect this sooner so you can unlock
liquidity to, say, fund a different channel or whatever, and that's why we also
provide a set of configurable params to enable it.  So, that's just the sweeper,
the general idea behind the sweeper design.

**Mike Schmidt**: Matt, anything to piggyback on there?

**Matt Morehouse**: Yeah.  So, I think what I'd like to talk about is maybe the
differences between LND's new RBF strategy and other implementations.  So, as YY
mentioned, there's certain deadlines that HTLC claims need to be claimed by,
otherwise you can lose the value of that HTLC to one of your channel
counterparties.  And so, what all implementations do is they basically start at
a low feerate so that they don't spend more fees than they have to.  But then,
as the deadline gets closer, then they start to bump that feerate using RBF.
And there's a couple of different strategies that are used to determine what
feerate to use.  The strategy that all implementations use is relying somewhat
on feerate estimators.  So, this is like Bitcoin Core's estimator where you give
it a confirmation target and it tells you what feerate you can expect to need in
order to get your transaction confirmed by that target.  So, implementations
will give the deadline to the feerate estimator as the confirmation target, and
then use the feerate to set their transactions at that feerate.

The problem with this is that feerate estimators are just estimators and there's
no guarantee that you actually will get your transaction confirmed by the
deadline, especially in scenarios where your node is under a targeted attack.
So, if your node is the victim of a pinning attack or a replacement cycling
attack or some sort of minor bribing attack, then the feerates that the
estimator gives you are going to be way too low and you really need to be
bidding much higher on your fees in order to defend against these sorts of
attacks.  And so, the LND's new strategy -- oh, sorry, there's another strategy
besides using just the feerate estimator that LDK and Eclair specifically use,
called exponential bumping where, as the deadline gets close, rather than
relying solely on the feerate estimator, then they start multiplying the feerate
by some fixed multiplier.  And the idea here is to bump higher than the feerate
estimator would normally tell them to.  And so, this hacks a little bit, but it
still doesn't offer the strongest protection against these sorts of attacks,
especially for large HTLCs, because in that case, the attacker may be willing to
spend a lot in order to steal a portion of that HTLC.  Meanwhile, your 20% or
25% fee bump may get you nowhere near the feerate you need in order to outbid
them.

So, LND's new budget-based approach takes into account the value of the HTLC.
The key insight here is the larger your HTLC is, the more you should be willing
to spend to reclaim a portion of that HTLC.  So, you don't want to be paying the
same feerate for a dust HTLC as you would for 100,000 sats.  And especially as
deadlines get close, there's some amount that the node operator is willing to
spend to recover from that HTLC.  If the deadline is one block away, how much
are they willing to pay in that worst-case scenario?  And so, once you have that
number, you set that budget, then you can create a fee function over which you
do your fee bumping.  And the fee function starts at a low feerate and it ends
at the maximum budget that the node operator is willing to pay, and this is what
LND does.  And the benefit of this is you can potentially bid a lot higher on
fees, which helps protect against these kinds of attacks.  So, you have a much
better chance of outbidding a pinning attack, there's much stronger guarantees
that replacement cycling attacks become uneconomic, and protection against all
sorts of attacks like this.  And this is specifically what I would like to see
other implementations incorporate into their own fee-bumping strategies.

**Mike Schmidt**: Have you spoken with other implementations yet?  Or is maybe
part of being on this show and being in the newsletter to get the word out on
some of this?

**Matt Morehouse**: Yeah, still getting the word out.  Bastien did respond to
the Delving post and it seems like he's considering implementing something like
this or some variant of it in Eclair.  So, that's good to hear.  I haven't heard
from anyone else, but hopefully they will watch this and think about it.

**Mike Schmidt**: I saw that Abubakar, who has done some work in Bitcoin Core
around fee estimation hadn't replied in the Delving thread.  Anything notable
there for what you're working on and potentially other implementations to use
Bitcoin Core's fee estimator better?  Yeah, so I think the key thing he
suggested was rather than using the deadline as the confirmation target, use
some sooner value as the confirmation target, and then just wait, and hopefully
you can get it confirmed at a lower feerate.  And then, if that fails, then you
can go into this more budget-based fee bumping strategy.  And this is something
that YY and I have actually discussed in the past too, so I was glad someone
else thought of it too.  And YY's actually done some research in the past about
potential different fee functions that could be used that would operate more
like what Abubakar suggested.  I don't know, YY, if you want to talk about that
or...?

**Yong Yu**: Yeah, that's things that have been updated and researched.  So,
yeah, I guess I'll pass.  But to add to Matt's point, that's correct.  We did
discuss this in the past and we did find out that there are actually better fee
functions than what we are using here.  So, just a brief summary about the fee
function here.  So, what we use here is a very simple algorithm to progress the
starting feerate to approach the ending feerate over the deadline blocks.  And
at the moment, we just use a simple linear function, which means in every block,
the feerate is increased by a fixed amount.  And this is just a starting point,
a very dummy fee function.  And in that research, I also tried different fee
functions, like we can try to, say, delay the increase, just give it a grace
period, and then increase it when the deadline is approaching.  Or we can be
more aggressive and relax the speed of the increase when the deadline is
approaching.  So, different strategies work based on the actual deadline that we
have, and I still find that the research interesting.

What I find most surprising is that even with a very small feerate, say 1 sat/vB
(1 satoshi per vbyte), you can still manage to get your transaction confirmed,
as long as you are willing to wait, say, 100 blocks.

**Mike Schmidt**: Obviously, for other implementations wanting to understand a
little bit more about this research, there's the Delving/blog post that they can
look at, and I think that was pretty in-depth.  Maybe, YY, on your side, as
somebody who participated in some of the research as well as the implementation,
anything notable for other LN implementations on the implementation side, like
level of effort or amount of time you spent on this, any other tips for them?

**Yong Yu**: I think the approach could more or less just be the same.  So, like
Matt talked about earlier that we use a fee function, and I think that just
could be used for every implementation because it is a very simple function.
You just build it there and you use it to guide how much fee to increase for
each block.  And then, you can just plug in three variables, so the starting
feerate, the ending feerate, and how long, how many blocks you are willing to
try, so the deadline blocks.  And then, you can just also define something like
a budget and that the ending feerate is just the maximum feerate or it's the
budget over the transaction weight.  But there's actually some subtleties here.
So, when we choose the starting feerate, it's actually the largest value of the
three items.  So, it's either the mempool min_relay_fee_rate, because we want it
to be relayed, or it's the peer's fee filter feerate, or it's the feerate
returned from a fee estimator using deadline as a conf target for the
estimation.  So, yeah, there's some subtleties there.

**Mike Schmidt**: Matt, anything else before we wrap up this news item?

**Matt Morehouse**: Yeah, maybe just a word of caution.  Touching this part of
the codebase is often risky, because any bugs you introduce here can potentially
cause funds to be lost.  And I know considering LND basically rewrote the whole
sweeper, there was a lot of changes that happened and a lot of bugs that were
found and fixed before the release happened.  And, yeah, it can be a little
nerve-wracking changing this code, so I would recommend trying to keep changes
small, focus on specifically the fee bumping behavior, and maybe try to avoid
changing things you don't have to.

_BOLTs #1233_

**Mike Schmidt**: Well, thank you both for joining us.  Matt, there is one PR
that touches on some of our previous discussions that I was hoping you could
help us with, and I think we discussed it briefly previously, but maybe you
could recap for folks.  This is BOLTs #1233, which updates a node's behavior to
never fail an HTLC upstream if the node knows the preimage, ensuring that the
HTLC can be properly settled.  Matt, can you give a quick recap of why we would
need to make that change in the BOLTs spec?

**Matt Morehouse**: Yeah, so I think the main issue was that the previous
wording in the spec was not complete.  So, if you were strictly reading the spec
and implementing exactly what it said, you would actually end up failing back
HTLC's that would be very dangerous to fail back, and you could end up losing
funds that way.  And so, this PR makes it way more explicit that if you know the
preimage, then you need to use the preimage to claim upstream rather than
failing back.  And the hope is that we can avoid issues like the excessive
failback issue that LND had going forward.

**Mike Schmidt**: And that was Newsletter and Podcast #344 where we discussed
some of this previously.  So, refer back to that if you're curious of the
details there.  Matt and YY, thank you both for joining us.  You're free to drop
a few other things to do, you're welcome to stay on as well.

**Matt Morehouse**: Thanks, folks.

**Yong Yu**: Thanks.

_Wally 1.4.0 released_

**Mike Schmidt**: Moving to our monthly segment on Changes to services and
client software, we had a dozen this month.  First one is Wally 1.4.0 being
released.  This is the libwally-core library that I believe the Blockstream
folks utilize in some of their software.  It is a library for Bitcoin wallet
primitives, so things like addresses, BIP32, PSBT, crypto functions,
transactions, descriptors, etc.  I think it's probably something that doesn't
get as much discussion in the community as maybe it should.  And with this
release, they added taproot support, support for getting BIP85 RSA keys,
additional PSBT and descriptor features.  So, check that out if you're looking
for some crypto and wallet primitives to build on top of.

_Bitcoin Core Config Generator announced_

Bitcoin Core Config Generator was a recently announced project.  It's a terminal
user interface for creating Bitcoin Core config files.  I think Jameson Lopp has
a web-based GUI for this and I guess this is similar, in that as you're
providing your configuration options, there's some helper text and warnings and
things as you build out that configuration file, which seemed kind of cool.
Murch?

**Mark Erhardt**: Yeah, I think the nice thing here, I watched a bit of the
demo.  It looks like it's step-by-step, and for each step it explains a little
bit around the setting and walks you through it, rather than just a single big
overview where you can pick and choose.

_A regtest development environment container_

**Mike Schmidt**: Next piece of software is a development environment container
titled, "Regtest-in-a-pod", and it's a repository for using Podman containers
with Bitcoin Core, Electrum, Esplora all sort of pre-configured and ready to go
out of the box in those containers.  There's also a companion blog post titled,
"Using Podman Containers for Regtest Bitcoin Development", so there's a blog
post that goes along with that.  I did not run through that setup.  Murch, I
don't know how much of a pain point that is for someone like yourself who's
doing that development, but maybe somebody who's just jumping in to get
something started, it could be helpful.

**Mark Erhardt**: I'm still a little surprised how many other projects ended up
using regtest, because regtest was originally just meant to be a testing
environment for Bitcoin Core development.  But now, there's all these other
things that plug into Bitcoin and sort of built around using this internal tool.
So, I was wondering whether it would make sense to make it a signet version, or
start its own signet instead of regtest because regtest is a little weird in a
couple of ways.  But yeah, I haven't looked too much at it, just random thought
here.

_Explora transaction visualization tool_

**Mike Schmidt**: Explora transaction visualization tool, so Explora, not to be
confused with Esplora, which we just referenced previously, Esplora being the
block explorer software.  Explora here is a web-based explorer for visualizing
navigating between transaction inputs and outputs.  So, it gives you sort of
like a chain of transactions and how they're related, and you kind of click on
the inputs and outputs to advance.  So, kind of a cool visualization tool there.
Yeah, Murch?

**Mark Erhardt**: Yeah, so this is really nice if you want to look at the flow
of funds.  For example, if you're trying to see if something might be a peel
chain, this will become apparent immediately.  If you're exploring on a block
explorer and just clicking through input, output, you have to keep in your head
where you came from and how that might connect.  You might still be able to see,
"Oh, there's a big output each time", and go down a chain that way, but more
complex patterns don't really emerge.  So, this one will just give you a graph
visualization of the transaction flows and that looks really cool.

_Hashpool v0.1 tagged_

**Mike Schmidt**: Hashpool 0.1 is tagged.  We actually had vnprc on in Podcast
#337 and he was talking a lot about this, but I don't think that there was
anything that was tagged or ready to go at that time.  Essentially, he was
talking about his Hashpool project, which is a mining pool that essentially took
the Stratum v2 reference implementation and took out some of the parts for
mining shares and put in, as representations of those mining shares, ecash
tokens.  And so, we won't dig into that much here because I think he did a good
job of representing that idea back in Podcast #337.  So, refer back to that, but
it's an interesting idea.

_Krux adds taproot and miniscript _

Krux adds taproot and miniscript.  So, Krux was the open-source firmware project
for building commodity hardware, hardware signing devices, which is pretty cool.
We highlighted them previously.  And in this update this month, we're talking
about how they're using embit, which is a Bitcoin library that can be run in
MicroPython on embedded devices, so they have that as a dependency.  And embit
added miniscript and taproot support, so Krux is also adding miniscript and
taproot support, so interesting to see that.

_Source-available secure element announced_

Source-available secure element announced.  This is TROPIC01, is how I'm reading
it.  This is from the Trezor hardware signing device folks.  They've come up
with a secure element that is source-available.  They have an open architecture
for auditability and they want folks to take a look at that and poke holes in
that.  The secure element is targeting RISC-V, which is an open-source
instruction set for processors, and so this is something that you can see being
used in maybe not only Bitcoin world for secure elements, but there's lots of
other applications outside of crypto wallets as well that could use that.  So,
interesting to see that.

**Mark Erhardt**: Yeah, so this seems to be coming out of the corner of Trezor.
I see that Pavol Rusnak is on this.  I think it works well, or I can see why
they would be working on this, because the Trezor has been source-open and had
only been using architecture elements on their board that were source-open.  So,
I think they didn't have a secure element on the Trezor before.  So, making one
that is source-available and with an open architecture just sort of completes
their options with their hardware wallet.  Alejandro, do we have you back?

_DMND launching pooled mining_

**Alejandro de la Torre**: Yeah, can you hear me?  Okay, great.  So, thanks for
including us today.  It's always an honor to be here.  So, yeah, we launched, we
just launched our pooled side of DMND, and this means that normal miners can
join us.  It's not just a solo pool.  And Stratum v2 is the main feature behind
our pool.  It's built from the bottom up, that's the Stratum v2.  So, we don't
have a Stratum v1 endpoint.  That means that our users are going to be able to
create their own blocks, our miners.  This is going to help decentralization in
Bitcoin.  Right now, we have a very serious issue, as everyone knows here, with
a handful of operators controlling all the blocks.  And if you add the FPPS
(Full Pay Per Share) payment model, which centralizes Bitcoin money even
further, then we have a disaster in our hands.

So, Fillipo Merli, which was the lead developer of the Stratum reference
implementation, and I, we co-founded DMND.  We've been working in stealth mode
on the pool and we just are now coming out with the pool.  We also released the
announcement of our investment by TVP.  And I do encourage any miners that are
listening to join our waitlist and become part of history in Bitcoin mining.
Stratum v2 brings a whole list of upgrades, as we all know.  It's in binary,
making it more efficient; it's encrypted, making it more secure; but most
importantly, it brings the block template creation, and I think this is going to
change the game completely.  That's my bet, that's why we started this, and
looking forward.  Mike, should I add something else?  You go ahead.

**Mike Schmidt**: Yeah.  I have some follow-up.  Obviously, you've been heads
down building the thing, but you're transitioning now a little bit into, I
guess, marketing and business development mode, which would put you speaking
with miners who you hope to adopt, I guess broadly, Stratum v2, but also what
you guys are working on specifically at Demand.  What's the reception of Stratum
v2 like to miners?  Is this something that they want?  I know Bitcoiners want
this, but I'm curious what the feedback from miners is.

**Alejandro de la Torre**: Well, the feedback so far has been very good.  The
miners recognize the other important upgrades in Stratum v2 (Sv2), like
efficiency and security.  But it's been quite an eye-opener to see that most, if
not all the miners that have spoken with us now that we've announced, have
wished to create their own blocks.  And I think most miners are recognized that
the issue with centralization is a real issue.  Ultimately, if you're a Bitcoin
miner, you're also invested in Bitcoin, of course, and you want Bitcoin to do
well.  And if there is a very strong centralization risk or centralization issue
right now, I would say, in Bitcoin, then that puts your investment and your
business in risk.  So, miners recognize this.

It's an ongoing process.  We're actually right now still in the testing phase
with a lot of these miners because we have to explain to them how it works.
It's a tad bit different, it's not very difficult at all, but you do need to run
a proxy in your mining operations, your farm, and we have to answer questions as
to why they have to run a proxy.  So, basically, since all the mining equipment
nowadays have Sv1 messages, we have to translate that to Sv2, and that's what
the proxy does.  It also has a whole list of other features that we already
implemented and will be implementing, so it's good.  And also, we have to kind
of explain to them the reasons why they're running their own node in their farm,
and just basically help them do that all that stuff.  So, it's been a lot of fun
actually.

Sv2 is great in the sense that since the miner, for example, is going to have to
run their own node, number one, there's more nodes in the network, which we all
want, so it's already an added benefit there; but most importantly for the
miner, they don't have to connect to the pool to get the new jobs, right?  They
communicate directly with bitcoind via their node.  So, they're bypassing the
perhaps very long distance between our pool node and their mining farm.  And
this is particularly important for miners that are based in the middle of
nowhere, which is quite a lot of miners.  So, remote mining has always had an
issue with stale shares, and that issue is a lot less of an issue, because if
they're communicating directly to the Bitcoin daemon, the other node, then you
bypass that whole entire problem.

So, a lot of these miners are kind of, it's a learning curve, not a long one,
but it's kind of an eye-opening experience, both for me and for them, because
they start to realize, "Oh, wow, now I understand why there were so many stale
shares and just running this Bitcoin node is going to help me save some money,
so it's great".  So, I've been having a lot of fun, me and the team have been
having a lot of fun.  Actually, the team right now is in Mining Disrupt, Miami.
We're hosting a side event in a couple of hours, and it's sold out, the side
event, actually.  I think we're over capacity, but I mean I hope that bar
doesn't kick us out.  And it's good, it's very good.

**Mark Erhardt**: Awesome, so I guess you would also be talking about the
performance of the node that should be on site with the mining equipment.
Because in the past, of course, we had that episode where we had a lot of stale
blocks, and part of the reason was that a lot of the template-creating nodes
were just very weak and took a little too long to process blocks and create new
templates.  Yeah, I hope people realize that, especially if they're running a
lot of mining equipment, they want to run a sufficiently powerful node.  But
yeah, just to put that in the context here.

**Alejandro de la Torre**: That's 100% true.  So, we recommend a pretty beefy
server for their node.  Actually, there is a benchmarking tool that was built by
Gabriele Vernetti, I believe his last name is, or gitgab19, on Twitter.  He's
also part of SRI.  And one of the metrics that he tracks is the CPU usage of the
node.  So, we recommend a pretty beefy node.  But at the end of the day, these
operators are running multi-million-dollar infrastructure, I don't think they
mind adding a handful more cores to their server for their nodes.

**Mike Schmidt**: One more question, I think listeners may be thinking, "Oh,
build your own block template, that's what Ocean does, and they have a protocol
for doing that".  How would you contrast what they may be familiar with, with
that DATUM protocol, versus Stratum and what you guys are doing?  What's the
delta there?

**Alejandro de la Torre**: Well, I like to preface this question with saying
that we're fans of having more pools in the industry.  So, it's a net positive
for the industry to have another pool that's building another block or allowing
users to build their own blocks.  That's great, we're fans of that, of course.
We're here to decentralize Bitcoin mining, so that's our goal.  However, I think
Stratum v2 has been tested and is specified in this documentation.  DATUM does
not have any specifications as far as I know, so it's very difficult to kind of
look behind the tech.  Or if Ocean decides to change something, you're kind of
left in the -- it's more specified in the sense also that, so Stratum v2 has had
three years of non-stop work by many developers, has been tested extensively,
thoroughly.  So, I think it's kind of a beefier system to DATUM in that sense.
So, that's my answer.  Basically, Stratum v2 is the more advanced project in
this regard.

**Mark Erhardt**: I have a separate question.  So, one of the concerns a lot of
people had with pushing the block template creation to the miners is that miners
may have different preferences of what they include in their blocks; and
currently the fees are a very small portion of the total block reward, but let's
say the fees go up again and there's different ways of building the block
template.  If the node is really far remote and has maybe a weak internet
connection, they might not hear about as many transactions, or people might
prefer not to include certain transactions.  How are you thinking about the
template quality of what a miner uses that contributes to the pool, and how do
you put that into your processes?

**Alejandro de la Torre**: That's a great question.  Our policy is to accept
everything and anything.  Of course, it has to be in the rules of Bitcoin, so it
can't break Bitcoin.  But if one of our miners decides to add transactions or
subtract transactions, be it for ideological reasons or whatever it is, that's
fine.  And the development team at DMND had a very, let's say, big task there
because we had to kind of take into consideration different fees for different
blocks and how we would account for them in the payment method.  So, we came up
with a payment method called SLICE.  And SLICE, basically what it is, is PPLNS
plus Job Declarator (JD).  So, in a nutshell, what it does is that it takes a
slice of all the different block templates, fees, inclusions or exclusions, and
then it does a calculation to that.  So, let's say if you have 100% of the fees,
then you will get paid 100% of the time or 100% of the fees that have been
included.  But if you have less, if you have subtracted transactions, then we
had to take that into consideration, and those miners at that point would make
less in that if that block is found.

It was an interesting challenge for us, but we figured it out.  And we have a
whole entire blog post about that, and we also have a paper that goes deep into
the math and the formulas.  So, I recommend to anyone listening that wants to
really delve deep into this to check out our website, dmnd.org, and click on
SLICE.  There, you'll be able to read the blog posts or get into the very
substantial paper that we wrote.  And it's open-source too.  So, we released
this as open-source tech.  We're open-source team believers, so this is for the
community as well.

**Mike Schmidt**: Alejandro, awesome.

**Alejandro de la Torre**: Thank you.

**Mike Schmidt**: Thank you for walking us through that.  If you wouldn't mind
just hanging on a second while your upload completes, and then you're free to
drop, or you can hang out with us if you want.

**Alejandro de la Torre**: Thank you.  Thanks, Mike, thanks, Murch.

_Bitcoin Core #31283_

**Mark Erhardt**: Actually, I was wondering, there's the PR #31283 and I thought
Alejandro might know a little thing about that.  Do you mind if I pull it up,
Mike?

**Mike Schmidt**: Go for it.

**Mark Erhardt**: OK, so in #31283, Bitcoin Core introduces a new waitNext()
method to the BlockTemplate interface.  And what it does is it essentially looks
whether the template has changed enough since the last time it was pulled, and
only replies with a new block template if either the fee has significantly
increased or the chain tip advanced.  And so, this is a change that aligns with
the Stratum v2 protocol specification, and my question in that context would be,
do you have an overview of how far Bitcoin Core is along with Stratum v2, and do
you have any thoughts or feedback on that one?

**Alejandro de la Torre**: Yeah, it would be very helpful if Bitcoin Core took a
little bit more time and effort.  I know that the Bitcoin Core development team
is very busy and has a lot on their table, to put it lightly.  But DMND is here
to grow, and every single node that a miner is using in their operations is
right now using a patched Bitcoin node.  So, if we continue to grow, there's
going to be a lot, a lot of nodes on Bitcoin that will be running a patched
Bitcoin node, which could become an issue for Bitcoin as a whole.  So, it's very
important that we try to get Stratum through so we don't have another very big
problem on our hands later down the line, because we're pushing very hard.  So,
this is quite important, I would say.  And to add to this actually, we've been
working on the mempool.  This is actually something that Bitcoin Core also
looked into, its cluster mempool.  I'm sure you guys are aware of that.

**Mark Erhardt**: Oh, yeah!

**Alejandro de la Torre**: Our mempool is a cluster mempool.  So, we have a
cluster mempool running in our pool.  Every other pool has just a normal
bitcoind mempool.  So, our cluster mempool is, in theory, better than the other
ones.  We've done some internal testing and things look good, but of course
internal testing is different from production, so we hope to see an increase.
Basically, what cluster mempool does is, it's a better algorithm to the normal
mempool.  So, it would equate to more transaction fees included into the block,
because of how the algorithm works, which then boils down, of course, like
that's kind of our working philosophy at DMND, to find technical upgrades, I
should call it, to give ultimately more money in the pocket for our miners.  So,
if this cluster mempool works as intended, we should see more transaction fees
for all our miners.  And since we're PPLNS pool, PPLNS+JD slice, then our miners
will be able to actually make that money aside from FPPS which just takes a
calculation.

**Mark Erhardt**: Two follow-up questions.  Question one, if you're running
cluster mempool already, is this off of the development branch in the Bitcoin
Core project, like Suhas and Pieter's branch, or have you done your own
implementation?

**Alejandro de la Torre**: I have to relay that onto the CTO, sorry, I don't
know.

**Mark Erhardt**: Okay, no worries.  Second question, do you happen to know, is
it sort of in a group setting where you run other nodes and the node with the
cluster mempool, and then you look what's the block template, and you just pick
the one with the higher fee; or is your intention to always go with the cluster
mempool?

**Alejandro de la Torre**: Our intention is to always go with the cluster
mempool.

**Mark Erhardt**: Yeah, cool, okay.  That's very exciting.  Yeah, it just missed
the 29 release, or just missed, it's not quite ready.  I think it'll be in the
30 release, is my understanding.  I've been following pretty closely.

**Alejandro de la Torre**: Yeah!

**Mark Erhardt**: Okay, cool.

**Mike Schmidt**: Are you capturing logs or are you interfacing at all with the
cluster mempool developers?  I have to assume that they would be curious about
the performance of cluster mempool in the wild, in the coming six months, if
indeed cluster mempool makes the next release, that your data could potentially
inform things?

**Alejandro de la Torre**: No, we're not in discussions with -- I mean, we're in
discussions with one Bitcoin Core developer, or just not discussions, but just
we've mentioned it to one Core developer.  But we're happy and more than willing
to provide that data to anyone that needs it, specifically Bitcoin Core.  So,
yeah, we're also very excited for this.  I think there's a lot of potential
here, a lot of fun things.

**Mark Erhardt**: Yeah, so just to temper the expectations a little bit, cluster
mempool will perform a little better if you have, for example, multiple children
that bump a parent.  It will discover that and appropriately include that in the
block template before the old implementation of mempool would notice, because
the old one would just go based on ancestor sets, so it would look into the
ancestry of a transaction and would only discover a single child that bumps, and
would queue it at the ancestor set feerate; whereas cluster mempool can find
groups of transactions that together would be worth including.  Most of the
time, I would expect that to only have small benefits, but it should help align
expectations about what gets confirmed a little more.  And in some cases, where
the ancestor set-based falls out of the top template and the cluster-based is in
the top template, it might increase the next block template a bit.  And I would
absolutely encourage you to reach out to Pieter and Suhas, they would be excited
to hear someone is running experiments with their project already.

**Alejandro de la Torre**: Sure, I will do.  So, we've internally seen an
increase in transaction fees being confirmed.  But basically, the whole entire
kind of premise here is that if we see a slight increase in the mempool, a
slight increase in our payment method, a slight increase because of less stale
shares, then that adds up, and we're a mining pool and our miners need to get
paid.  And if we have those slight increases along the way, then they will make
more money with us.  Now we've got to see, now we've got to test it out.

**Mark Erhardt**: Awesome.  Thank you for working on this.

**Alejandro de la Torre**: Thank you.

**Mike Schmidt**: Alejandro, I'm glad we had you on.  There's a few different
items that we could drill into there that I didn't expect.  So, thanks for
joining us.

**Alejandro de la Torre**: Thanks, Mike.  Thanks, Murch.

_Nunchuk launches Group Wallet_

**Mike Schmidt**: Nunchuk launches Group Wallet.  So, Nunchuk had multisignature
capabilities previously, but they've relaunched and revamped as Group Wallet for
this feature.  It supports multisignature signing, coin control, MuSig2,
taproot, and what I thought was interesting here is that they were actually
using the output descriptors for this multisignature wallet to generate secure
communication channels between the participants.  So, if you were thinking, "How
am I going to communicate with the other folks that are a part of this
multisignature scheme?" they're actually deriving keys using the BIP129 Bitcoin
Secure Multisig Setup (BSMS) file to fire up those communication channels so you
could send messages to each other and collaborate on whatever you're doing with
that particular wallet.  So, I thought that was interesting.

_FROSTR protocol announced_

FROSTR protocol announced.  So, we've talked about FROST previously.  FROST is
the threshold signature scheme.  So, instead of something like MuSig2 where you
have an n-of-n, so you have everybody signing, you would have a threshold.  So,
you would have a k-of-n, so 3-of-5 signing, but it would ultimately be one
signature onchain.  That research has progressed over the years and someone from
the Nostr community is adopting that same FROST technology for signing Nostr
messages in a k-of-n threshold way, and also doing some key management using the
FROST protocol, and this is all under this project called FROSTR.

_Bark launches on signet_

Bark launches on signet.  We talked about Bark previously.  This is the Ark
implementation we covered, I think, what newsletter was that?  That was in
Newsletter #325.  That's from the Second team.  There's a few teams working on
Ark implementation, so Bark is Second's implementation, and their implementation
is now available on signet.  And they've fired up their own signet faucet, so
you can get signet coins, and they also have a demonstration store for testing.
So, you can get the coins from the faucet, join Ark via the Bark implementation,
and also then spend those coins out at a demo store and test how this Ark thing
might work.

**Mark Erhardt**: Cool.  It's exciting to see people actually put in the elbow
grease to test out Ark at that level.  Originally, from what I understand, the
idea for Ark came out of, "How would I make a distributed or a non-custodial
Lightning wallet service?"  And with the combination now of statechains into it,
there's some of the scalability problems resolved or mitigated.  And yeah, I'm
curious.  I think it will take a lot of work, and having an Ark client might be
a little different, yet another set of trade-offs than other types of wallets,
but it could really help with diversifying the options people have to have
access to their Bitcoin.

_Cove Bitcoin wallet announced_

**Mike Schmidt**: Last software update this week, Cove Bitcoin Wallet is
announced.  Cove Wallet is an open-source mobile Bitcoin wallet that is built
using the Bitcoin Development Kit, BDK, and it supports good Bitcoin tech like
PSBTs, wallet labels, hardware signing devices, and more.  Nothing else notable
from them, it just seems like a good quality Bitcoin wallet that we should
elevate the discussion on, so check that out if you're looking for a
mobile-based wallet.  I believe it supports iOS, or it's on test flight right
now for folks who want to test it out.

**Mark Erhardt**: I'm just so excited to see wallet projects pop up in bigger
count, just because there's this whole toolbox of stuff that you can use now to
build better wallets more quickly.  There's several libraries, like BDK, where
you get all of the heavy lifting, the protocol integration, the transaction
building, the coin selection, and all that stuff out of one hand.  And then, you
can take that, just plug in an interface to the front, you use PSBTs to get
signing between multiple devices or even groups of people, you get output
descriptors for better backups or distributed coin stuff, like we saw in the
Nunchuk implementation earlier, wallet labels, and so forth.  And so, I'm hoping
between all of these things happening that it'll become easier to create more
good wallets.  We can distribute the protocol backend stuff and the frontend UX
stuff to the people that are better at each of them, and maybe also at some
point we can see better enterprise stuff.

_Bitcoin Core 29.0rc2_

**Mike Schmidt**: Releases and release candidates.  We have one this week,
Bitcoin Core 29.0rc2.  And we have on Jan.  Jan, you contributed, along with
several other developers, to the Bitcoin Core 29.0rc Testing Guide.  The Testing
Guide highlighted three testing areas of changes to Bitcoin Core in this
release, including P2P and network changes, mempool policy and mining changes,
updated RPCs, new RPCs, and updated REST APIs.  I saw the guide also links to
the release notes, or the pending release notes for 29.0, for all the details.
But before we do an overview of these changes in the Testing Guide, Jan, how did
you come to be a contributor in the Testing Guide?

**Jan B**: Well, we were asked as part of the BOSS program to write this Testing
Guide.  And as you may know, the Testing Guide is part of the release cycle.
So, Bitcoin Core releases every six months.  Before that release, there is an
RC1, 2, etc, depending on the bugs that are found in the RCs.  And part of the
RCs is to test them on several different environments and use cases to see if
there is regression.  And we have written a guide to help people do those kinds
of tests on their own machines.

**Mike Schmidt**: Well, thank you for volunteering for that effort and also
wanting to contribute to Bitcoin open source and going to the BOSS program.  I
think that's a really high-quality program that Jonas and the folks at Chaincode
have put together.  Murch, were you going to say something?  Okay.  So, Jan,
what's new in 29.0 and how do we test it?

**Jan B**: So, there are several changes.  I think many of them are behind the
scenes, but one of the more interesting things that has some need to test it, is
the point-to-point network changes.  So, there is some dropped support for UPnP,
and there is some added support for PCP and IPv6 pinholing.  This will drop
miniupnp dependency and will use an own implementation of PCP.  And this is
important because the developers would like to see a whole kind of range of
routers and what is supported if there are any problems with an RC and PCP or
IPv6 pinholing.  And also in the guide, there is a link to an issue where you
can report back on your findings, so report back what is your router and if it
was successful or not, and also if, for instance, PCP is enabled by default.

Another notable change is there are some updated RPC calls.  They have updated
or added nBits targets and target and some next block details.  Just use the
guide and you can just copy/paste some commands and your terminal will guide you
through it.  You will see the output that is expected.  And please report back
if there is any difference in what you see in the guide or what's on your
screen.

**Mike Schmidt**: For the first one, for the P2P changes, it seems like both of
those that are noted in the guide are related, the dropped UPnP and miniupnp
support.  I recall that there was at least one, maybe more CVEs tied to this
dependency over the years, which I guess even if there wasn't, you always want
to have less dependencies as opposed to more.  So, I can understand dropping
that.  Maybe you can talk about what miniupnp was doing, and then maybe that can
lead into what PCP and pinholing is, and what people who would be going through
the Testing Guide would be looking for to happen or not happen?

**Jan B**: Sure.  So, UPnP is a way for the bitcoind binary to talk with your
router, to open some ports on your router.  So, the Bitcoin node needs to
communicate with other Bitcoin nodes.  And if you started up without PNP
support, then you will need to manually port forward a port to your Bitcoin
node.  UPnP support will just automatically open a port on your router so that
your Bitcoin node can communicate with other Bitcoin nodes.  Of course, outbound
traffic is always possible, but it's for inbound traffic.  And like you said,
less dependencies to external libraries is better.  And they have created PCP
now and IPv6 pinholing, which are more modern variants of that functionality of
opening ports on routers.

**Mike Schmidt**: Anything to add there, Murch?

**Mark Erhardt**: Yeah, I looked a little bit at the release notes and the
release notes are a lot more under the surface this time around.  So, in this
release cycle, this is the first release that has the updated build system.  I
think we talked about this here with some of our guests, that Bitcoin Core will
start using CMake now.  And to anyone that is building Bitcoin Core from the
source code or has a patch that they built, they will notice that with this
release, they will start a different workflow for building the binaries from the
source code.  And we've also talked a bunch about ephemeral dust, which is
getting released in 29, and we know that the LN community is very excited about
it, because they intend to use it for their commitment transactions.  So, yeah.
And lastly, what I saw was that there were a bunch of updated RPCs.  So, if you
use bitcoind and have your own system integrated via RPCs, be sure to check the
release notes to see if any of your calls are affected.

**Mike Schmidt**: A shout out to at least one other PR that we talked about
previously, which was the update to when you have an orphan transaction, the
node now attempting to download missing parents from all peers who announced the
orphan, which has the trade-off of slightly more bandwidth, but the orphan
handling is more reliable.  And then we talked about, with Abubakar, I forget
which show it was, but the double reservation in the coinbase, which was eating
up extra weight units, and that's been eliminated.  In order to eliminate that,
there's also this flag for -blockreservedweight that can be used to preserve
more if that's what you need.

**Mark Erhardt**: Yeah, so if you're running and mining a block template
creating node, as we should say now, you will notice that it adds a few, well
actually, it's 0.1% more blockspace in the default configuration.  It was
double-counting the reserve for the coinbase.  The reserve space for the
coinbase is a little generous maybe for most coinbases still, so if you want to
eke out the most out of it, you could even reduce it a little more.  Just be
sure that you know how large your coinbases will be before you start playing
around with that.  But by default, it's stopped now reserving it twice instead
of just once as we need it.

**Mike Schmidt**: Marco, I know you're a Bitcoin Core contributor.  Is there
anything that you would highlight or call to action around 29 and the release
candidate and Testing Guide?

**Marco De Leon**: The Testing Guide looks great to me.  Yeah, I was checking
out the release notes and trying to see what new things were being added, and it
seems like the guide covers almost, or yeah, I'm pretty sure it covers every
added thing.  And then I guess as Murch just said, we have the transition from
Autotools to CMake, which I guess will sort of automatically be tested as people
try to run stuff.  So, I don't have anything specific.  But yeah, I mean it
looks good.  I think it is a matter of actually testing stuff, which I think
sometimes it goes by, or people just kind of think that the release is
automatically fine.  But if you don't test it, then you won't know.

**Mark Erhardt**: Yeah, let me jump in here one more time.  If you are using
Bitcoin Core in a downstream project as a source of truth and make heavy use of
the RPC, ZMQ or other interfacing with Bitcoin Core, we do appreciate a lot if
you take the time to run the RC in your testing environment before adopting it
in production, and please do report any issues you find.  We've had issues in
the last years occasionally where once the actual release was out, people
started upgrading to the new Bitcoin Core version in their architecture, and
sometimes they first discovered that there were problems when in production.
Please do test it in your testing environment.  If you don't have one, maybe
spin one up for further testing before you roll it out into your production.

**Mike Schmidt**: I think that we will probably have a link in the next
newsletter to the Testing Guide, but we didn't, I don't think, in this
newsletter.  So, Jan, if someone's listening and they say, "Okay, great, you
guys have been blabbering on about this for 20 minutes.  How do I jump in and
actually test this thing and find the guide?" where should folks go to most
easily access the Testing Guide?

**Jan B**: The Testing Guide is on the wiki of Bitcoin Core.  You can just go to
the Bitcoin Core GitHub repo, click on the wiki tab, and in the bar to the
right, you can find the 29.0 RC Testing Guide.

**Mike Schmidt**: Excellent, and yes, there's these five categories that we
mentioned, we dug into some of them, Murch gave some of the behind-the-scenes on
some of the release notes, that's great.  But also, you can just use the RC how
you normally would, and that's a good way of testing it as well.  Even if you
went through the guide, keep the RC running and use the node how you normally
would, and report anything that's abnormal to the team.  All right, Jan, thanks
for putting this together.  I know it wasn't all you.  I know there's a group
that was contributing, but you're here, so we're thanking you for your work on
it, and thanks for everybody else for their work on it as well.

**Jan B**: Yeah, thanks for having me.

**Mike Schmidt**: Yeah, you're welcome to stay on, or you're free to drop a few
other things to do.

**Mark Erhardt**: The same is true for Alejandro, of course, too.  Thank you for
coming on.

_Bitcoin Core #31649_

**Mike Schmidt**: Notable code and documentation changes.  Bitcoin Core #31649
removes all checkpoint logic.  Checkpoint logic?  Wow.  Okay, Marco, this is a
PR that you authored titled, "Consensus: Remove checkpoints (take 2)".  Okay,
there's a few scary things in there, but I'll let you set up the context for
listeners about what's going on here.

**Marco De Leon**: Yeah, so I guess the first thing to say is that, yeah, this
is just the very last PR of a long thread of PR since, I mean honestly, it seems
like, and yeah, Murch, tell me if I'm wrong or just correct me in places where I
may be off, but I think checkpoints were introduced in 2010 or 2011.  So, they
were there for a long time and I think at some point they were used to kind of
lock in the chain at certain points.  I think the last one that was in there was
block 295,000 which was in 2014.  So, yeah, at some point they were used to kind
of be like, "Okay, look, once you get here, that is the chain, this is what the
chain is".  And then I believe sipa kind of decoupled it a little bit from
consensus.  In around 2015, there was a PR, like PR #5927, where I think he kind
of made it such that it was less coupled to actual consensus, and more just I
think then, it was only used for basically if you wanted to skip script
validation, skip script checks, that that code would use the checkpoints.  And
then, of course, it was still used for the memory DoS, the potential attack, it
was CVE-2019-25220.  So, yeah, once he decoupled it from consensus, then it was
kind of only used for those two things.

Then I believe, once we did assume that valid on its own, that decoupled
checkpoints from script checks.  So, I think then we had the assumedvalid, and
that kind of did it its own thing.  And then, at that point, checkpoints were
only used to prevent the attack.  And so, that was kind of the last thing that
we needed checkpoints for.  And so then, Suhas added in, this is PR #25717,
added in the headers presync logic, which basically, we kind of sync the headers
twice.  One is a presync, where every few hundred headers, you commit to that
header's chain.  And then, so yeah, basically you're going to skip storing the
actual headers until you know it reaches the minimum amount of chain work, which
right now, for release 29, is block 880,000-something, I'm not quite sure.  But
each RC, it gets moved up.  So, the presync basically just stores the commitment
to the header up to that amount of work.  So, once we know that we have a chain
that has that amount of work, then we'll go back and we'll do the actual header
sync, where we'll actually download the headers.

So, that's the overall logic for preventing the memory DoS.  Because now,
basically with that logic, it makes it way more expensive now, because to create
a chain that has as much work as 880,000 blocks obviously would be quite the
amount of work and quite the cost.  So, that was the prevention for kind of the
last thing that checkpoints were there for, and then it was just a matter of
making sure that that logic worked well and that we had all of the tests for it
that we wanted to have.  And so, yeah, I'm pretty sure #25717 was that the
headers presync code was put in in like 2022, that got merged.  So, it has been
quite a while.  And then, take one, right, was right after that in 2022, and
that was kind of when people were like, "Well, wait, do we know if this is
well-tested or not?"  So, we had unit tests, we had functional tests, but we
wanted to add a fuzz test.  So, that was the holdup on take one.

So then, last year, we put in a fuzz harness for the presync code, that
essentially creates chains which have less than min chain work, and then it
basically goes through the presync code and is like, "Okay, if any of those
chains, I guess, get added to the block index, then we know there's a problem",
because if it has less work, then it shouldn't be added into the index.  So,
that's what the test does, and so we've had that running now for a few months,
and we'll continue to have it running.  So, yeah, and then one thing to clarify,
checkpoints being gone is not in 29.  So, it'll be in the next RC, which is
later this year.  So, it was just a matter of testing it more, and I guess now
that we're confident, there is no reason to have checkpoints in there.  And I
think there's maybe a couple conclusions, or some people might say, "Well, if
it's not that much code and it's not a huge deal, why not just keep them in
there to be safe?" which might be the case.  But I think if you think that way
for a ton of small things, then it adds up to being a ton of code bloat, maybe
potentially.  So, I think it is good to keep track of what code is actually
playing a role, and if it's not really playing a role in making sure that the
network works well, then why is it there?

So, yeah, and then, Murch, maybe we can touch more on this, but it is
interesting, I've seen some people kind of be like, "Well, once again, if having
these checkpoints in there isn't a huge deal, why not just keep them in there?"
because, yes, the history of the chain is set in stone, or this is what people
say, "It's set in stone, so just have the checkpoints there as an extra way to
make sure that there are no chains that go out of consensus when you try and
sync".  But I think trying to keep this aspect of decentralization is key, and
having it such that Bitcoin Core as a project aren't the ones being like, "Hey,
look, this is the canonical chain".  I just think that's an important thing to
keep in mind, even if it seems like checkpoints might be kind of a small thing
to keep, I think it's a good change to have to not have them in there.  And,
yeah, I think that's pretty much it.

So, I'm personally glad that we've made progress through all these years
because, yeah, I've just seen all these PRs about, "Okay, should we take them
out now?"  "Oh, no, they're here because of this".  "Okay, how about now?"
"No".  So, now it's actually cool to have them out, and hopefully we have the
presync logic there to make sure that the network is safe and secure.

**Mark Erhardt**: Yeah, there just used to be so many misunderstandings about
the exact role of checkpoints, and there was still the concern that someone
could produce a low-work, very long chain of headers and just feed that, and
that's exactly what the header presync gets rid of.  It doesn't store all the
block headers, it just processes them, keeps a fingerprint for sequences of
blocks, and then if it arrives at a header that has total work that is
sufficient to surpass the minimum chain work, then it goes back and resyncs the
same header chain, and then it uses these fingerprints to make sure that it is
still processing exactly the same header chain as it processed before.  If the
two diverge, it stops and finds a new chain to presync.  Yeah, so I think we
don't really need the belt-and-suspender approach here anymore.  I'm also happy
that the checkpoints are gone, or will be gone in the next release.  Thank you
for the in-depth overview of how we got there.

**Marco De Leon**: Yeah.  And yeah, to your first point, it was true, people
would often be confused and think that we had the checkpoints in there to say
what the correct chain was.  So, we had to constantly say, "No, it's there for
these other things".  So, now it's just, there will be no confusion for people
that maybe think that we were determining what the chain was through the use of
the checkpoints.  So, yeah.

**Mark Erhardt**: In a way, we could say you hard-forked Bitcoin.  How do you
feel about that?

**Marco De Leon**: Yeah, that was actually something that really hit.  No, I
think, because yeah, that was actually one of the first points I think I heard
got brought up, sort of as like a cheeky comment, I guess, because even though,
yes, it does hard-fork its previous clients, if there were a reorg all the way
to past the last checkpoint block, which was in 2014, then yes, the old clients
would say, "No, that's not the correct chain", while new clients would be like,
"Sure, that is the new chain".  But I believe that's very unlikely to happen.
But yeah, I guess that's it, or this is technically a hard fork, so we can add
it to all the forks and this will be there.  But yeah, it seems like hard forks
really only matter obviously at chain tip, right, not as much for if there
happens to be a reorg of, what would that be now, like 600,000 blocks?

**Mark Erhardt**: Yeah.

**Marco De Leon**: Pretty much we would have other problems.

**Mike Schmidt**: Yeah, we'd have bigger problems.

**Mark Erhardt**: Yeah, thank you for immediately identifying this as a cheeky
comment!  Well, you did change the rules that nodes enforce, but we're fine.  We
have 600,000 blocks' worth of PoW telling us what the best chain is.  And now,
new Bitcoin Core nodes will only require the genesis block, which is hard-coded
anyway, and then identify the chain tip exclusively by the most work, which they
in de facto had been doing ever since, but now there isn't even the crutch
anymore.

**Mike Schmidt**: Marco, that was great.  Thanks for jumping on and explaining
that to us.  You're welcome to stay on for the rest of these PRs, or you can
drop if you have other things to do.

_Bitcoin Core #31283_

Bitcoin Core #31283, Murch, is there anything else you wanted to say about this
PR?  Did you get it all out of your system?

**Mark Erhardt**: Yeah, I think we covered that one earlier.

_Eclair #3037_

**Mike Schmidt**: Okay, great.  Eclair #3037, "Contains two separate commits
that should have been done as part of #2976, but unfortunately were missed
because of insufficient testing".  #2976 was the PR from Eclair last week in
Newsletter #345, that added out-of-the-box offer functionality in Eclair without
the use of plugins.  So, that PR missed two items that this PR addresses.
First, "Listoffers RPC previously exposed raw TLV (Type-Length-Value) data and
omitted the createdAt and disabledAt information, which made it quite useless.
We now return all of the useful offer data which makes it easier for node
operators to manage their offers.  This is added in the first commit.  Second,
"If we previously registered the same offer twice, this would crash because we
weren't properly handling primary key constraints failures.  This is fixed in
the second commit".

_LND #9546_

LND #9546 changes the way LND handles macaroon access.  Macaroons, as a
reminder, are LND's permissioning system widgets.  Before this PR, LND could
restrict a macaroon to a specific single IP address, or you could provide
multiple single IP addresses, but after this PR, LND can now lock a macaroon to
a specific IP address range.  So, now you can provide an IP address range and
lock macaroons accordingly.

**Mark Erhardt**: Yeah, and in case you are wondering, macaroon, if you are
thinking about cookies on websites, macaroons are fancy cookies.

_LND #9458_

**Mike Schmidt**: LND #9458 adds functionality for LND to be able to allocate
restricted slots for certain of the LND's peers, and that is configured with
this --num-restricted-slots option.  This privileged access permissions in the
server for LND is based on peers' historical channel data, and so there's a few
different criteria.  One is if the peer has ever had a channel with the LND node
that has confirmed an onchain transaction, they'll be given protected access.
That's criteria one.  If the peer has a pending open channel, it'll be given
temporary status.  And otherwise, the peer will get a restricted status.  And
the PR also notes that in the future, LND can further fine-tune this criteria.

_BTCPay Server #6581_

BTCPay Server #6581.  This is improvements to fee bumping functionality for
specifically RBF.  So, the UI for BTCPay Server's transaction list, for example,
now shows a Bump Fee link for transactions eligible to be fee bumped, and that
could be using CPFP or RBF.  And then, if you hit that button, you get to a
screen where you're on the bump fee screen and you see a page where you can
either choose RBF or CPFP, and RBF is actually the default if it's available.
And that screen also shows the effective feerate, which takes into account the
descendants and ancestors of the unconfirmed transactions of the bumped
transaction.  And the PR has a bunch of screenshots describing the workflow that
I just verbally described.  And the first comment of this PR actually also has a
related video.  So, you can check out the details there if you're a BTCPay
Server user.

Also noted in the PR, "While it's possible to fee bump multiple transactions
with CPFP, it is not supported at this moment with RBF".  And we should also
note that this functionality that we outlined in this PR requires users to
update to NBXplorer to 2.5.22 or above.

**Mark Erhardt**: Do you think I should explain why you sometimes might not be
able to CPFP?

**Mike Schmidt**: Yeah, do it.

**Mark Erhardt**: So, CPFP, Child Pays For Parent, of course, means that you are
spending the child output or the output that is going back to yourself, or if
you're the recipient, the output that pays you, to create another transaction
that brings a higher fee, which then will incentivize the parent transaction and
this new transaction to be confirmed quickly.  And if you create a changeless
output, for example, by sweeping all of the funds in a wallet or by making a
payment for which you happen to have exactly the right UTXOs to fund the payment
without sending anything back to yourself, you would sometimes get into a
situation where you're stuck and you cannot accelerate a transaction because you
do not have this output to yourself that you can use to create a child
transaction.  So, with RBF, you can create a Replace-by-Fee transaction, a new
transaction, add another input in this case that brings more fees, maybe add a
change output to recollect the remainder, but you now are able to accelerate
your transaction even if you didn't have an output that paid you.

_BDK #1839_

**Mike Schmidt**: Last PR this week, BDK #1839, which helps fix an issue with
BDK where BDK, when initially seeing a pending transaction, would continue to
see that transaction as pending, even when another double spending transaction
confirms.  So, the PR adds the ability for BDK to detect and evict incoming
transactions that are double-spent or canceled.

That's it Murch, because I think we covered BOLTs #1233 earlier with Matt
Morehouse, so I think that we can wrap up.  Thank you to Marco, Jan, Alejandro,
Yong or YY, and Matt Morehouse for joining us as special guests this week, and
thank you to Murch as co-host this and for you all for listening.  Cheers.

**Mark Erhardt**: Thanks for your time.

{% include references.md %}
