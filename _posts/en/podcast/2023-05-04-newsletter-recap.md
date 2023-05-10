---
title: 'Bitcoin Optech Newsletter #249 Recap Podcast'
permalink: /en/podcast/2023/05/04/
reference: /en/newsletters/2023/05/03/
name: 2023-05-04-recap
slug: 2023-05-04-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Salvatore Ingala, James O’Beirne, Adam Gibson, and Steve Lee to discuss [Newsletter #249]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/70143061/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-4-10%2F6c5127d7-c34d-2932-4831-a4cc39ceba2c.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #249 Recap on
Twitter Spaces.  It's May 4, and we have a slew of interesting guests to talk
about their various proposals and mailing list posts.  We'll do quick
introductions and then we'll jump into it.  I'm Mike Schmidt, contributor at
Optech and also Executive Director at Brink, where we fund Bitcoin open-source
developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work on Bitcoin stuff, mostly education these
days on Bitcoin Core.  I'm also working on a BIP that is about bikeshedding!

**Mike Schmidt**: Steve?

**Steve Lee**: Hi, I'm Steve Lee, I lead Spiral, which is the open-source
Bitcoin initiative at Block, and we fund developers, similar to Chaincode and
Brink.

**Mike Schmidt**: James?

**James O'Beirne**: Hi guys, I'm James, I work on Bitcoin Core full time, mostly
assumeUTXO and OP_VAULT these days.

**Mike Schmidt**: Salvatore?

**Salvatore Ingala**: Hi, I'm Salvatore, I work on Bitcoin up at Ledger and I
also try to do some more Bitcoin stuff on my free time, which is why I'm here
today.

**Mike Schmidt**: We also have Adam Gibson here, Waxwing; we're working on
getting his audio working, so I'll work with him on that while we jump into the
newsletter.  In the interests of time, we're going to go a bit out of order, and
Steve Lee is going to cover his news item first, and then we'll jump into the
rest of the order of the newsletter.

_Job opportunity for project champions_

So, in the interests of time, we'll have him go first so we can make sure that
we talk about his job opportunity for Bitcoin wizards.  Steve, you want to give
us the lay of the land; what are you looking for?

**Steve Lee**: Well first of all, thanks for letting me go first.  I have a
6-year-old who has a birthday today, so I need to leave early.  Spiral is hiring
three what we're terming "Bitcoin wizards", but this is not for NFT work, this
is not NFT wizards; this is OG wizards.  So, if people are familiar with the
#bitcoin-wizards IRC channel, and there's wizard channels in a lot of other
forums, where hardcore Bitcoin, deep, technical, Bitcoin developers talk about
the really hard problems and how to solve them, and new innovations technically.
That's the kind of senior engineer that we're looking for.

I think it's unusual to post to the mailing list, or even get Optech covered on
job opportunities, so thank you for both of those forums.  In this case, it was
appropriate and it was allowed, because this is for Team Bitcoin, this is for
free, open-source software development.  There's no commercial work involved
with this role.  It's a full-time role on the team, where you'll be a full-time
employee, like the seven engineers who are on the Spiral team today.  Those
seven engineers all focus on Lightning Development Kit (LDK) exclusively.

This role, one way to think about it is, it's working on any in Bitcoin other
than LDK, so we don't want these new developers that we're hiring to work on LDK
because it's well taken care of, but there are a lot of other important projects
and layers of Bitcoin and new innovations that we'd like to bring to Bitcoin.
This role would be someone who's working with other Bitcoin developers in the
ecosystem to bring impactful changes to Bitcoin.

**Mike Schmidt**: So, Steve, I know that recently you, I guess in a personal
capacity, have been putting the feelers out for a Bitcoin PM, and that is
unrelated to this position.  Spiral also gives out grants, and that is not
exactly what you guys are doing here; this is actually full-time, highly
technical, Bitcoin developer for a full-time role with Spiral, that would be
either on site or remote, is that right?

**Steve Lee**: Yeah, all that is correct.  I think some people are maybe
confused, because I have been talking about Bitcoin Core PMing recently, and
yeah, so Spiral supports that concept and we are open to giving grants for that
type of role, but that is not this role.  This will be engineers.  You can go to
spiral.xyz, that's our website, and there you can find the job description.

One thing we mention in our post for job, we talk about people skills, and by
that we just mean we want people who are good stewards in this space, people who
can collaborate with their fellow peers and developers on their work.  Now, some
of these projects, maybe they impact like the LN protocol, so there'd need to be
consensus among LN protocol developers; maybe it's a project that it's a soft
fork to Bitcoin and it changes the Bitcoin consensus protocol, and as we all
know, that requires very broad consensus, but it typically starts with a small
set of developers, then a broader set of developers, and then the broader
Bitcoin ecosystem.  So, just someone who is good at listening to feedback, maybe
even having co-authors of a BIP or a proposal or just others that they're
working with.  I think that's generally a good attitude to have, so we're
looking for people like that.

But at the centre, we're definitely looking for people who can work on the hard,
technical problems in Bitcoin, and that can range from reviewing other people's
specs or designs and improving them; creating their own, new innovations; taking
some idea from the mailing list, maybe from like seven years ago, and
prototyping it; creating production code that's actually mergeable into Bitcoin
Core, whatever relevant project it would impact; a range of things.

One more thing to say is that we're not looking for the exact same profile of
person for all three hires, so they can range.  Like one person maybe has deep
zero-knowledge proof expertise and they would work on projects applying that
technology to different parts and aspects of Bitcoin; and maybe another person
is heavily focused on privacy or scaling, or some other aspect of Bitcoin.

**Mike Schmidt**: So, these three positions you have open, they could
potentially be working together, if it happens to work out that way, but this
doesn't have to be a team that is all working on the exact same thing?

**Steve Lee**: That's exactly right.  I think they'll be part of the core team
of Spiral, they'll be full-time team members, and like any team, we have some
camaraderie and we get together.  We are spread out around the world, so we do
get together three or four times a year in person.  These three people would
join that and be part of that.  But depending on the project they work on, their
"team mates" might be seven other developers who are otherwise affiliated with
Spiral.  But if two or three of these three are all working on the same project
and it makes sense to have that many people working on it, then that's fine too.

**Mike Schmidt**: Murch?

**Mark Erhardt**: I was trying to summarize it from what I understood.  So, it
sounds to me more like a project lead role, specifically focused on deeper
Bitcoin problems that improve scalability or privacy, or the long-term
over-arching problems that we are still chipping away at to make Bitcoin better.
So, maybe less of a team that works together, but more of everyone has their
focus area and tries to drive forward effort in that area, but has some peers to
chat with and pick their brains.

**Steve Lee**: Kind of.  I mean, I guess calling a "project lead", I'd say we're
definitely looking for someone senior who can lead, but certainly within the
decentralized spirit of Bitcoin, I think "collaborator" might be a better term.
We're not looking for Spiral, as an organisation, or the people we hire to start
dictating how things should be done.  But yeah, we're definitely looking for
someone who, in the right spirit, is a leader amongst us, one of many leaders.

I mean, a concrete example would be, there's been discussion -- so, in LN,
there's the gossip protocol, and there are some well-known privacy leaks within
how the current gossip protocol works.  Zero-knowledge proofs are one solution
to improving that, so one example project would be actually implement a
zero-knowledge proof library that's production-ready, Bitcoin-ready, LN-ready,
and then make the necessary changes to the gossip protocol, both at the spec
level and write the code to make that happen.  That potentially could be done by
a single person.  But even if the spec and the code is all done by one person,
they have to get consensus among the LN protocol developers across at least four
implementations, if not more broadly; it's like 30-plus people need to buy into,
"Yeah, we agree that's v2 of the gossip protocol".  So, that's really where the
collaboration would come in.

**Mark Erhardt**: Yeah, thanks for clarifying.  Project lead was maybe the wrong
term, but really someone that takes a focus on one of these problems and tries
to move forward, not necessarily alone or with some sort of authority, but just
as a focus and as someone that brings the expertise necessary to do so.

**Steve Lee**: Yes, yeah, I agree with that.

**James O'Beirne**: Steve, I just want to jump in and thank you and Spiral for
offering this, because Bitcoin development is really, really hard, and I think
one of the big challenges for contributors so far has been the process of
seeking grants; and just having more full-time slots where people can have some
amount of stability and be able to focus on the long term is sorely needed, so
thank you.

**Steve Lee**: Thanks for saying that, and it does differ from the grant
program.  I mean, the grant program I think has been fantastic and I think most
people who have gone to the grant program really valued it, but we give grants
for one year.  A lot of the grantees that we've given grants to, it's their
first-time funding for open-source Bitcoin, which is great because that was
intentional; we wanted to bring more people to Bitcoin development and we have
at least a dozen alumni now from the grant program who have gone on to full-time
job opportunities with Bitcoin, starting their own companies in Bitcoin, and
just even greater success beyond the grant program.

So, that's all great, but yeah, it is a 12-month grant.  We have renewed, so I
think that's given multi-year support to some developers, but it's not the same
kind of sustainability that a full-time job would bring.  But also with the
grant program, we are very, very hands off; we vet an application and the person
upfront; we make sure that we believe it's an impactful project and that we
think that they can get it done.  But once we give the grant, we really don't
influence at all.  I mean, I see John Atack's in the audience and I think he
would agree with that; Tankred's also in the audience, he would agree; and
Bitcoin Zavior.  So, we have several grantees in the audience.  We don't really
dictate or tell people what to do.

With the full-time role, there'll still be tremendous freedom, but there is a
little bit more; like the LDK developers, I think that they'd say that I don't
boss them around day-to-day what they do, but it's an expectation that they all
work on LDK.  For these new roles, the person we hire, definitely we'd look to
them to drive which projects they want to work on, but there'd need to be buy-in
from Spiral, as well as at least a contingent of the broader Bitcoin ecosystem
that, yeah, this is an impactful project and is viable to work on.

**Mike Schmidt**: I echo James' sentiment, that thank you guys for doing this
and putting your time and attention and money towards this.  If folks are
interested, there's a bit more detail on Steve's Bitcoin-Dev mailing list post,
which also includes a few example projects and ideas, and also instructions of
how to apply.  So, if you're interested, reference that.  Any final words,
Steve, before you go eat some birthday cake?

**Steve Lee**: Thanks again for having me on.  Looking forward to seeing a lot
of great applications and hopefully this has a big impact on Bitcoin.

**Mike Schmidt**: Thanks, Steve, you're welcome to hang, you're welcome to drop.
Thanks for joining us.

_MATT-based vaults_

Next item from the newsletter is MATT-based vaults, and this is a post from
Salvatore to the Bitcoin-Dev mailing list.  We had Salvatore on a few months ago
and we had coverage of his idea around MATT, which is Marklize All The Things,
and we covered that in Newsletter #266.  I think it would probably be a good
idea, since it's been a bit, to revisit what was the original idea there, and
then maybe build upon that original idea with your mailing list post that covers
some of the ways to achieve similar behaviour to the recent OP_VAULT proposal
from James, James who is here as well, who I know has some curiosity about what
you're working on, and maybe we can get a little bit of dialogue going after
we've laid the groundwork.  So, Salvatore, do you want to maybe provide a
high-level summary of what is MATT, and then some of your discussion around
recreating some of these similar OP_VAULT use cases?

**Salvatore Ingala**: Sure.  I can try to do a brief introduction as you're
suggesting, try to keep it maybe as short and quick as possible so then we can
have a more open discussion about it, than trying to talk about it and that's
it.  I hope my voice survives, because it's not doing great today.

So, to summarize what is the basic idea of MATT, so MATT stands for Merklize All
The Things, which is a name that kind of came from after I presented it the
first time at BTCAzores.  But the core idea of the proposal is actually pretty
simple.  The two core opcodes of the proposal are two opcodes that recently I'm
calling OP_CHECKINPUTCONTRACTVERIFY and OP_CHECKOUTPUTCONTRACTVERIFY.  They're
trying to do something which is very simple, which is you have some data which
you're manipulating in a script, like some data that you parse through the
witness, and you want to be able to constrain from the script what is both the
script of the next output, which is something similar to what something like
OP_CHECKTEMPLATEVERIFY (CTV) would be able to do.  But also, you want to be able
to attach some data to the next output.

In the proposal specifically, there is a specific way of how I attach this data,
which is I use some of the taproot magic where you can embed data directly
inside the public key.  But conceptually, you can just think of it as you are
attaching data to an output.  So there is a script and there is some data and
they are two conceptually independent things.  And so, there are these opcodes
that allow to both say what is the data and the script to attach to the next
output, and then once you've reached the next output, you want to be able to
access this data.  So, that's what OP_CHECKINPUTCONTRACTVERIFY does; it's a way
to get this data attached to a current UTXO that you're spending, and do
something with it inside a script.  So, those are the basic opcodes.

Then, in the original proposal, which is not fully formalized yet, I suggested
that you would want some other things, like you would want to constrain the
input or output amounts, and do some interesting things which are common to
other covenants or covenant proposals as well.  And, when I proposed the idea
initially, I made some fairly big claims in the sense that I claimed that you
can do very -- a general smart contract can do fully arbitrary smart contracts,
based only on these few primitives, but I didn't show any code for that.  So,
when I discussed more recently on Twitter, or in other places with many people,
I encountered a bit of scepticism, which I think is understandable and
justified, because if I'm claiming that those opcodes are simple and they're
going to be simple but I'm not showing any code, I can understand that people
are sceptical.  So, that was a bit of my goal, to be able to do that.

There is a reason I didn't show the code, which is I never tried to modify
Bitcoin Core before and starting with the Bitcoin script interpreter is probably
not the easiest, especially if you have a full-time job.  So, yeah, that was a
bit of my goal.  And so, when I saw James' proposal for OP_VAULT, I got very
interested because he did a great job in distilling what a good vault proposal
would be, just designing a vault and then implementing it in Bitcoin.  So, that
gave me an immediate goal and a challenge at the same time.

So the goal was, "Okay, how do I implement that using MATT?" and the challenge
was that in the initial proposal, I was mostly thinking of contracts where you
have one UTXO, you put some states inside the UTXO, and then maybe the state
changes, something happens, and at some point you settle the contract there are
some pay-outs, and that's it.  And this model doesn't fit very well for vaults
because in a vault, while the contract itself is very simple, you want to be
able to work with many UTXOs as part of the same contract, in a way, which is
something that in the initial proposal I said could be interesting, but it's
left for future work and future generalisation, but it's actually very necessary
for something like a vault.

Speaking about the vault, and maybe James can chime in if I don't say it in a
nice way, but the core idea of a vault, if you say it in this way that I'm
proposing now, I think it looks very similar to what MATT opcodes do, and this
is what a vault is.  You have some coins that are in this vault and instead of
spending like we do normally from a wallet, where you just satisfy the spending
conditions and that's it, you can spend, you want to decide to spend now but
then defer the actual spending to later.  So, you spend them to an intermediate
output where they have to sit for some time, and then later you can spend them
to the final destination.  But the final destination is decided on the first of
the two transactions.  This is why you need to have some transfer of information
from the first set of outputs that you are spending to the final transaction
where the spending is actually happening.

So, in the first email post, if there's time maybe we can also attach from the
other email post, which is on how to do rock-paper-scissors; but the first email
post that was the one that was covered by Optech was exactly about how we can do
that with MATT, and I wrote base implementation of the opcodes and with some
basic function of test, where I liberally copied from James' functional tests,
so thanks, James, for doing some work there!

I think the design of the vault, it's pretty close to the one that James is
proposing; the differences are really quite minimal.  One advantage, in my
opinion, of doing this with general opcodes is that basically, the exact design
of the vault doesn't end up as part of the script interpreter, but is something
that is fully encoded in the scripts, based on how people want to program the
vault.  This is something that of course needs to be judged in all possible
ways, because like OP_VAULT was, by design, minimal so that it doesn't have more
functionality, this is not what I'm trying to do with MATT.  I want to find the
most minimal opcodes that are, at the same time, very general.

**James O'Beirne**: So, Salvatore, maybe if I can try and just summarize the
implementation approach here, because I think with all of these general covenant
proposals, I think there's some difficulty in wrapping your head around how
things work, just because the mechanisms are so general.  So, maybe I can just
take a crack at describing how I think you're doing it, and then you can correct
me.  Congratulations, by the way, for getting some code together and I just
actually had the functional test open on my screen before this call.  I love
seeing some concrete artefacts around proposals like these, so awesome job.

But if I understand correctly, so basically there are two new opcodes here that
give you two new abilities.  The first, OP_CHECKINPUTCOVENANTVERIFY, is
basically a way to assert that some particular piece of data is attached to the
input, which I think is ultimately supplied off the witness stack.  And the way
<!-- skip-duplicate-words-test -->that that happens, as far as I can tell, is you're checking a tweak in the input
taproot.  And then the second mechanism is asserting that the structure of the
output taproot has some particular form.  Does that sound right?

<!-- skip-duplicate-words-test -->**Salvatore Ingala**: Yeah, that sounds right.  And I just want to add to that
that on a typical contract, what I can imagine is that people will want to have
the taproot of the next output have coded meaning.  You already know what the
program is, while the data that you attach to it is something that is
dynamically computed, based on the execution of the contract, so that will
depend on the witness data.

**James O'Beirne**: Yeah, that makes sense.  So, I guess maybe we could talk
through, you know, you can kind of decompose the life cycle of a vault into two
stages.  Once the coins are vaulted, there is the triggering process, where
you're actually declaring that you want to withdraw some value from the vault to
a particular target; and then, there's the actual withdrawal, which settles the
proposed transaction.  Can you just talk through how, in the MATT proposal, how
that first phase works?

**Salvatore Ingala**: The first phase is very much talking about when you're
spending a bunch of inputs that are part of your vault and you're putting them
in an intermediate UTXO, which is what you might call, I called, the unvaulting
phase.  So, in this phase, basically you're spending scripts that are bundled
with the original vault, and these scripts will have -- let me have the code in
front so I don't say stupid things; they would have one or maybe two spending
conditions.

What these spending conditions do is -- sorry, I added one spending condition,
which is the recover, which is send to a safe recovery path just to follow the
same design of OP_VAULT.  But the main spending condition is the trigger
spending condition, which is a taproot script, which checks one thing.  It
checks that the output of this UTXO is exactly a script of the second type of
transaction, which is what in the OP_VAULT proposal is called I think the
trigger transaction, or trigger UTXO, or maybe now it's recover,
OP_VAULTRECOVER, I think.  So, yeah, this is where you would parse the hash of
the final transaction.  This is where I also use CTV in exactly the same way
that it is used in OP_VAULT, because this is where you have to decide that some
transaction will happen in the future, unless it's blocked by the recovery path.

So, you're parsing the witness the CTV hash, and then what the script checks, by
using OP_CHECKOUTPUTCONTRACTVERIFY, is that this CTV hash is the data of the
next output where instead, the script of the next output is the script of the
unvaulting UTXO, which is the second phase of the contract.  So, that would be
the first phase of the contract.  And one thing that was a little of a
challenge, as I said before, is that I needed to find a way of making many UTXOs
that can be spent together as part of the same contract, and they all spend to
the same output; I need to have a nice way of doing this.  And in fact, one
thing I didn't implement in the core of the proposal, but I only commented on
possible solutions, is how do we take care of reserving the amount of all these
inputs, because you want the amount of the outputs to be greater than the recall
of the sum of all the inputs.

The way that will follow exactly what James is doing, OP_VAULT, will be to
basically make sure that if you are using OP_CHECKOUTPUTCONTRACTVERIFY, all the
inputs that have the same output as an output of OP_CHECKOUTPUTCONTRACTVERIFY,
you will want to sum whenever validating the script, you keep summing all these
amounts and then you do a deferred check at the end of the script interpreter,
so this is not an input check but is done at the end transaction-wide, when you
check that there was no violation on the amounts.

The reason I implemented this way is that this might not work for other types of
contracts, so I wanted to leave this open for further exploration, because the
alternative obvious approach would be to instead have direct introspection on
the output amounts, and then you could be able to do these things, but maybe it
becomes a little bit less efficient for the vault use case and might work better
for other contracts.  So, I wanted to leave this open to further exploration.
It would be nice to find a way that works for all kinds of contracts in a nice
way.

**James O'Beirne**: Yeah, so just to restate what you said very well, when
trying to come up with a solution for vaults per se, a lot of the difficulty is
how you take multiple inputs that are compatible across the same vault
parameters and make sure that you can aggregate their whole value into a single
trigger output, because that's where a lot of the batching efficiencies come
from.  And one of the things that motivated me to do a vault-specific opcode is
that doing that aggregation that's essentially a cross-input aggregation of
sorts, you'd have to do something similar in terms of these deferred checks if
you wanted to do cross-input signature aggregation, say.

But these deferred checks are a little bit specific to this particular use case,
and so one of the things I'll be curious about with the MATT approach is how we
bridge the specific vault use case into these more general opcodes, like
OP_CHECKOUTPUTCONTRACTVERIFY and OP_CHECKONPUTCONTRACTVERIFY.

**Salvatore Ingala**: Yeah, so this idea of the deferred checks could be
actually written to OP_CHECKINPUTCONTRACTVERIFY and OP_CHECKOUTPUTCONTRACTVERIFY
and then we would have something with exactly the same semantics, I think.  My
<!-- skip-duplicate-words-test -->only worry is that that might not work for other contracts.  For example, there
is Johan in the mailing list already thinking about some more advanced use
cases, like CoinPools, and on GitHub on the Bitcoin Contracting Primitives
Working Group, he was talking about applications to Hash Time Lock Contracts
(HTLC), where probably you would need some more fine-grain control on the
amounts of the outputs, and that's why I didn't want to settle on this very
proposal right now and leave this open.

But definitely, you could think of having exactly the same idea of a vault,
where all the inputs that declare that the next step is a specific step, which
could be vault, it could be something else, then they have to preserve the
amount.  As far as I can tell, that would give a very similar, or the same
properties as the vault that James is working on with OP_VAULT.

**James O'Beirne**: Yeah, so one of the other differences too that maybe it's
worth talking about is, in OP_VAULT, you have the ability to specify during the
trigger process an output that is what we call the revault output, and the idea
there is that if you're only withdrawing some partial balance out of a vault,
you might want to put the remaining balance right back into the vault so that
you can manage that value independently of the waiting period that's associated
with that first withdrawal.  So I know, I think you mentioned in the post, that
in the proposal that you've put forward here, that's not a part of the proposal.
Do you think, is there a way to build that kind of functionality in?

**Salvatore Ingala**: Yeah, indeed.  That's actually the only difference I can
think of between the OP_VAULT, in terms of functional behaviour; that's the only
difference I can think of.  And with the current idea that I had with deferred
checks, then I don't see an easy way of doing it actually.  One way that could
be done that again, would probably work for vaults, is that if you have multiple
OP_CHECKOUTPUTCONTRACTVERIFY opcodes, then you need to preserve the amounts in
aggregate.  But yeah, I will have to think a bit more if there is a semantic
which is clear and will work for this.  And the problem is also that again, I
want to come up with something that works for vault, but also for other things.
That's why I started exploring also with the other posts and more academic
examples, like other contracts.

So, yeah, this is definitely something that I don't have a clean, precise answer
yet, also because coming up with a restriction that then will still allow the
things, but then you have to do some trigger scripts and something like that,
would not be ideal.

**James O'Beirne**: Yeah.  Did you ever take a look at the example Burak put
together, which is using the elements introspection outcodes to implement
something OP_VAULT-like?  I thought that was a really interesting usage.  It's a
really good illustration of what this kind of functionality looks like when you
implement it in very primordial terms within script.  I mean, I found it very
illustrative, but also very like, I probably wouldn't want to do this because
the script is really, really hard to read and it's long.

**Salvatore Ingala**: Yeah, there was some discussion with Burak on Twitter,
where he was showing how to do something similar to this behaviour, the deferred
checks, by using explicit introspection on the amounts.  And the way he was
doing it was by adding one additional input to the transaction.  And the purpose
of this input was to inspect all the other inputs and make sure that the amount
matches what you're expecting.  So, it was something that worked.  It works, it
was actually not that inefficient, but that's exactly the problem.  Burak is a
Script Wizard, and ideally you will not need a Script Wizard to encode a
contract when you know that you want to embed some basic rules.

So, that's still open to come up with one way of doing these things that work
for all use cases.  There is always the option of allowing both behaviours,
something which is similar to OP_VAULT having deferred checks, and having split
input introspections for the amounts, so maybe something works better for some
contracts and something works better for other contracts.  But of course, this
makes the amount of changes needed in the proposal bigger, not that they are
particularly difficult changes, like adding 64-bits arithmetics, is probably not
a difficult change to audit, but then that becomes a bigger set of changes to
put together.

**James O'Beirne**: I thought his approach was genius and I really enjoyed
reading through it.  Maybe to play devil's advocate here against myself and
maybe you, one of the things that I keep thinking about is that one of the
things that's going to be paramount is the miniscript interface into whatever
opcodes wind up coming along to enable vaults.  So, maybe we get into a
situation where really, if you're a programmer interacting with Bitcoin at the
wallet implementation layer, maybe you're just hiding behind miniscript and
whatever gets spit out the other end is irrelevant.  I mean, I still think large
script sizes are troublesome from a chain footprint standpoint.  But maybe it's
like, "Oh, okay, well we don't really care what's going on underneath the hood
in terms of the raw Bitcoin script, as long as the miniscript interface is
expressive and good.

**Salvatore Ingala**: Yeah, large script size is something that I definitely
want to avoid, so this is one of the things.  It's often been said, in many
cases, that general covenant proposals lead to complicated and large scripts,
which kind of was the case for some of the biggest ones that were kind of
accidental covenants, like the ones built with OP_CAT plus OP_CHECKSIGFROMSTACK,
these kind of things.  But I want to challenge this assumption, because I think
this only comes from the fact that those proposals were not a covenant proposal,
they were a covenant more by accident, like someone found a way of making those
opcodes work like a covenant, but they were not opcodes designed to do these
kinds of contracts and implement things on top.

**James O'Beirne**: I know if Greg Sanders were here, he would say, "Bitcoin
script is horrible and I can't wait to nuke it and replace it with something
like Simplicity, or some kind of a Lisp-based thing".  I don't know, I found
that curmudgeonly, but I respect that opinion for sure.

**Mike Schmidt**: It's great to have both of you going back and forth.  If folks
are interested, there's the mailing list post that we highlighted, which also
includes a link to some commits that build on Bitcoin Inquisition, and there you
can see what James was referencing earlier in the conversation, which is some of
the optional tests and examples.  If you're curious about the proposal, you can
scroll through some of that code and see some real examples and test there, and
that may be a good place for folks to investigate further and jump off.

Obviously, feedback is something I'm sure Salvatore would be looking for, so if
this is in your wheelhouse, feel free to peruse through that code as well as the
mailing list post that we highlighted, and the ones from November as well, to
get some feedback here.  Anything else, Salvatore, that you'd like to highlight
before we move on?

**Salvatore Ingala**: Yeah, I will just add there is also the Bitcoin
Contracting Primitives Working Group repository that Antoine Riard is managing,
together with the other 1,000 things that Antoine Riard does; I don't know how
he finds the time.  But yeah, another thing, maybe people might be interested in
checking how to play rock-paper-scissors with MATT.  Probably there is no time
<!-- skip-duplicate-words-test -->to cover it now, but there are some other topics that spawn from that that are
also quite interesting for potential future ideas built on top of MATT.

**James O'Beirne**: And one interesting note that I'd like to leave here for the
conversation is, it seems like CTV is basically at the top of everybody's
prerequisite list when they start talking about implementing this higher order
of covenant functionality, so I just think that's kind of an interesting thing
to note.

**Mike Schmidt**: Yeah, James, both your proposal and Salvatore's proposal build
on CTV, which is interesting.

**James O'Beirne**: As well as some upcoming, mysterious proposals from certain
LND-slaying individuals.

**Mike Schmidt**: Interesting.  Well, thank you both for joining.  You're both
welcome to hang on and comment on the rest of the newsletter.  Or, feel free to
drop if you have other things that you'd like to do.

_Analysis of signature adaptor security_

Moving on to the next news item, analysis of signature adaptor security.  Adam,
you didn't get a chance to introduce yourself at the beginning of the call, so
why don't you do so now, and then we can jump into your mailing list post?

**Adam Gibson**: Hi, can you hear me?

**Mike Schmidt**: Yeah.

**Adam Gibson**: Okay, great.  Yeah, so I'm not quite sure what to say!  My name
is Waxwing on the internet and I work on stuff like JoinMarket and Bitcoin
privacy tech, and especially cryptography-related stuff as well.  So, it's a bit
vague really, I don't have a specific position to announce or anything like
that.  Yeah, so shall we get into it, or what do you think?

**Mike Schmidt**: Yeah, we can get into it.  Maybe it would be worth just
seeding the discussion at a high level to get everybody calibrated.  There's
this notion of multisignature protocols, like MuSig, which is a protocol for
aggregating public keys in signatures into a signal schnorr signature, and it
would look like a single signature onchain.  And then you have this notion of
adaptor signatures, which is the idea that with schnorr signatures, you can have
extra signature data that commits to some hidden value.  It sounds like you're
investigating the interplay between the two of those, and maybe you can correct
anything I've said, and maybe elaborate on what you've been thinking about.

**Adam Gibson**: Yeah, that's actually a very good introduction.  And in fact, I
was just reflecting earlier what would I even say, because obviously I don't
want to get too into the weeds, and it feels like it's almost more useful if I
explain the motivation of what I've been doing, rather than the concrete sort of
constructions in the paper; I think that's more interesting probably, and it
makes me think I should probably add a bit more explanatory, motivational thing
to the paper itself.

So, motivation, yeah, you're quite right.  The story really starts with MuSig.
Well, no, the story starts with schnorr, doesn't it?  Schnorr is a signature
scheme that has, let's say, a better security standing than ECDSA, and it has a
specific extra flexibility in that it has this kind of linearity property, and
so we're able to start doing clever things, such as MuSig, which is actually
like, if you reflect on it, it's a very ambitious project that says, not only do
we want to be able to have multiple parties co-signing things, but we want to be
able to do it in such a way that it's completely invisible to the external
observer, and specifically invisible to a verifier, like a verifier only sees a
single signature that looks the same as a signature would for a single key.

The reason that the whole story of MuSig is as complicated as it is, the way I
would put it, is precisely because of that very ambitious goal of not just
co-signing, but having a single key verifiable, just as a single key schnorr
signature is, and a single signature, of course.  That distinguishes it from
other constructions that were found, I don't know, 10 to 20 years back, over the
last 20 years, such as work by Bellare and Neven, where you can imagine
different scenarios where you just want lots of parties to be able to sign in a
secure way; and you can do that in a smart way, where everyone just provides the
key.  But of course, in MuSig, we don't all just provide the key.

So, we have this kind of ambitious goal of a multisignature scheme that
leverages schnorr's linearity and gets us to a state where literally 1,000
people could sign on a single key and it looks the same on the block chain as a
single person signing.  So, that's great, but it's difficult, and I would refer,
in a self-advertising way, I would refer people to a blog post I wrote in 2021
that I called The Soundness of MuSig, which by the way is a pun.  The Soundness
of MuSig is a blogpost that is rather long, I admit, but the reason it's long is
because it goes through the very striking story of how they started out trying
to create this scheme with the ambitious properties that I described, but they
encountered a very, very major road bump, when there was a flaw discovered in
the original scheme.

So, in future in the rest of this conversation, I'll refer to InsecureMuSig, as
they did, as the name of the original scheme.  And it's a very long and
complicated story, you can read that blogpost if you feel like it, it's
reyify.com/blog/the-soundness-of-musig, or just look it up on the blog there.
It's a very long and complicated story and the thing is that it comes from this
trickiness of, we've got to do all this interaction, all this interactivity,
we've got to have one key at the end, we've got to combine our nonces together
because, as I'm sure everyone here knows, a signature requires a nonce; we've
got to combine the nonces in a certain way, and so on.

Why am I talking so much about MuSig here?  Because what I want to do is I want
to motivate why I'm trying to write a document about adaptor security, and why
indeed other people have already written papers about this.  Yeah, so the thing
is that what was this insecurity, obviously I'm not going to go into the
mathematics, but what was this insecurity that they discovered?  I mean, don't
forget we're talking about some of the leading experts in the field here came up
with this original scheme.  How was it possible that they got it wrong?  The
thing is that you've got lots of people interacting, and you can use traditional
security arguments which I won't go into, but it's kind of a system of where you
isolate the adversary who you think can make a forgery and you kind of
manipulate that adversary in such a way so that they spit out a discreet log.

So, we think that people can't extract private keys from public keys, and that's
the fundamental assumption behind Bitcoin security in the first place.  And we
say that if somebody can forge, let's say, a schnorr signature, then they will
also be able to extract a private key from a public key, just any arbitrary
public key that we give them.  So, that's the kind of basic, that backwards
logic of, "Well, we think it's secure because if it wasn't secure, then nothing
is secure", kind of logic, is how we base all of these arguments.  We call these
things security reductions.  In other words, we reduce one problem to another
problem.

Then with MuSig, obviously they tried to do the same thing, because they kind of
have to, right, otherwise they can't assert it's secure without being able to
show some kind of similar argument.  So they did obviously do that, they didn't
just randomly just make up a MuSig algorithm and then just publish it.  They had
a very considerable and weighty security argument, actually based on -- did I
call it rewinding earlier?  So, rewinding, but rewinding twice, so actually
there's four different versions of the world in this proof.  So, it was quite
complicated, but it seemed to follow the normal logic.

What went wrong, in brief, what was wrong with that original argument was
something like the fact that it didn't consider just the surprisingly large
effect of what happens if there are lots of signing sessions going on at once.
Okay, so essentially, it came down to the fact that the system is very sensitive
to who's getting what information first.  Everyone's got to produce their part
of the nonce, and everyone's got to share their part of the nonce with everyone
else.  If that happens in a certain order, then clearly one -- put it this way;
the person who receives the information last always has an advantage in any such
collaborative game.

That in itself didn't look like a problem, but it turned out, with a combination
of something called Wagner's attack, that if there's lots and lots of different
nonces happening at the same time, then combining all of that information, the
person who receives all the information last gets enough of an advantage that it
is at least possible that they might be able to forge a signature.

So, you can see from how convoluted my explanation is there, and that is
obviously a very high-level explanation, that this was something very
non-obvious that went wrong in that definition and ended up being essentially
two solutions.  One solution was to add another round of communication to the
protocol so that you fix the nonces in advance.  That solves the whole, "Who
gets the information first?" problem, by just getting around it by adding
another round of interactivity with a commitment.  I kind of like that; that
makes the protocol much easier to understand.

The other solution was more sophisticated, and that's what we nowadays call
MuSig2, which gets around it a different way and has a more substantial -- in
fact, they went to the trouble of writing two distinct security proofs of
MuSig2.  Anyway, it's a very interesting story.  But this is the first part of
my motivation.  The first part of my motivation is, it turned out that because
of the interactivity of this protocol, there were non-obvious things that could
go wrong and originally did go wrong.

The second part of my motivation is kind of from a different angle, which is the
whole thing of adaptors.  So what is it, adaptors?  You've briefly mentioned,
you're sort of embedding a secret in a signature; that's correct.  By the way, I
tend to call them signature adaptors and not adaptor signatures, because I think
the term "adaptor" is functioning as an adjective in adaptor signature and it
shouldn't, which we will understand in a moment.  So, if I switch between those
two names, forgive me.

So, the thing about why this adaptor concept has grabbed people's attention,
pretty much immediately from when Andrew Poelstra originally proposed it; he
called it scripts at the time for reasons that historically make sense, but it
doesn't matter; why it grabbed people's attention is because it enables this
very important primitive of swapping a coin for a secret, which is the principle
behind the atomic swap, and it's also a principle that can function like what we
nowadays think of as HTLC.  So, you'll hear PTLC, Point Time Locked Contract,
which is essentially just using adaptor signatures to swap a coin for a secret,
or coins for a secret, so it could be embedded in LN and I'm sure that everyone
<!-- skip-duplicate-words-test -->intends that that will be the case, because it adds a lot of extra better
properties, which you can read elsewhere about how PTLCs are better than HTLCs.
So, adaptor signatures, or signature adaptors, are important for that reason.

But I, myself, about, I don't know, two years ago, I can't remember how long
ago, came up with a thought that this is actually very powerful, this construct,
and maybe it can be extended even further.  It's already quite complicated if
we're talking about a multisignature, just as we have now in LN, and then we're
adding in this signature adaptor inside the multisignature, and we're using that
to enable the routing of payments; that's already complicated.  But what if we
got even more complicated?  What if we said, you know what, we can make a system
where just as MuSig has this ambitious goal of 10 or 1,000 people can get
together and co-sign, how about if 10 or 1,000 people were swapping coins at
once?  You could think of it as shuffling coins rather than swapping coins.

So, I had the idea that maybe you could -- let's imagine some simple case of
three people, where each person, A, B and C, each person is going to receive a
coin and each person is going to spend a coin in three separate transactions,
but they're kind of jumbled up, so maybe A is going to pay B and B is going to
pay C and C is going to pay A, and I realized that at the mathematical level, it
makes perfect sense.  Actually, the same logic that says when Alice and Bob do a
swap, if Bob receives his signature, then Alice will receive her signature, and
it's ensured that either both people will get their money or neither will, that
idea of atomicity; that same atomicity can be achieved across a number larger
than two.  We can make it so that if there are three people, if any one of the
three people receives their coins, then the other two are guaranteed also to
receive their coins, by the same kind of logic where if a signature is published
on the block chain, that signature reveals a secret by means of the
pre-published adaptor signature.

Why would that work?  It's essentially because schnorr has this linearity
property, it means that even though there are three people and none of them
trust each other, Alice is not going to agree to a protocol like that where if
she's not sure that Bob isn't colluding with Carol, or A, B and C, so each
person, A, B and C needs to be sure that they have complete trustlessness, that
they're guaranteed to receive their money, even if they don't trust the other
parties.  But you can achieve that goal because of the linearity of schnorr,
effectively each person can treat the rest of the people as a single
counterparty, just like the idea is you add, very crudely, in multisig or MuSig,
specifically MuSig, you add signatures together and they act like a signature
still.  The same thing applies here, that you can add people's adaptor secrets
together, and they act like one adaptor secret.

So, I wrote this in a blogpost called The Multiparty S6 about, I don't know,
three years ago, I can't remember.  And, yeah, it was always in the back of my
mind, "That's a really interesting idea; could that actually work in general?"
Mathematically, it all looks completely correct.  But then I combine that in my
head with MuSig and I'm thinking a very complex collaborative protocol involving
these signatures, how sure are we that if you do something like that, for
example can't someone adversarially choose their adaptor secret in such a way
that it cancels someone else's adaptor secret?  How sure are we that if we
combine lots of people doing these swaps all at the same time, is there some way
<!-- skip-duplicate-words-test -->that that could leak information?

I know that was all rather complicated, but maybe it helps some listeners to
understand why I care.  Specifically, the MuSig situation is very, very
important and we now think we know what the problems were and we think we've
solved them.  So, let's make sure that we have similar security proofs and
security guarantees if we're doing these same MuSig protocols, but we're adding
in these adaptors.  So, what I wrote in that document, in that paper, is I tried
to lay out what are the basic properties of adaptors.  Some of them are not
maybe that obvious.  For example, in the central part of the paper, I talk about
algorithms that I call AdaptorForge and AdaptorForgeM.

What I'm describing there is how, even though in some of the papers,
specifically the Aumayr et al paper of 2020, they say, "Look, an adaptor is not
forgeable, and here's why", and they give a simple proof of that, that statement
is correct but it's only correct in a certain context, which is that if you're
given a specific point T, a curve point, then you can't forge an adaptor for it
without knowing the preimage.  But that statement is not correct if you think in
more general terms of, "Can I produce an adaptor for a given message and a given
public key?  Can I produce an adaptor on a point, let's say T, without knowing
its preimage?" and the answer is, "Yes, you can, but you don't get to define in
advance what that point is".

My point there is that there are these definitions you can make and observations
you can make about the core properties of them.  Another very trivial
observation that I make in the paper is that an adaptor has the honest verifier
zero-knowledge property, but it's kind of a trivial observation.  It's also true
of signatures in general, that they don't leak information about private keys;
that's the whole point of them, or at least one of the points of them.  So, I
make this list of basic observations.  And then at the end, what I'm trying to
do is to say, well look, if we insert these adaptor signatures into this MuSig
or MuSig2, but I focus on MuSig, assigning session, what sort of security claims
can we make about that?

The previous work which I referred to, it's very interesting, the work from 2020
and Lloyd Fournier's work as well, it was a little bit different, but it kind of
had the same basic game construct in it, was saying that, look, if there is an
adaptor, we can make a reasonable-like security proof that you can't forge a
signature, assuming the underlying signature scheme is secure, then just adding
this adaptor won't make the signature scheme somehow now forgeable, it won't
break the security just by adding in an adaptor.

So, the reason I'm writing an extra paper here is because I'm worried about,
well okay, that's true, but what if we have multiple adaptors at the same time;
what if we have multiple signing sessions; what if we have one person providing
an adaptor on lots of different signing sessions at the same time; what happens
if we have lots of people providing adaptors all on the same signing session at
the same time?  So, cases like that, cases where it's just a little bit more
complex, just by analogy to MuSig, do we also have a similar problem there?  I
think the answer's no, to be clear, and specifically just a few days ago, I
noticed there's actually a very much more recent paper by Wei Dai and Okamoto
and Yamamoto in December 2022, which ironically was exactly the time when I was
thinking to myself, "I should write a paper".

They wrote this paper and they actually addressed, at least partly, what it was
I was concerned about, because they add into the security game, they say, "Oh
yeah, actually what happens if somebody's allowed to get lots of adaptors at the
same time?"  They call this a stronger security definition in their paper than
the original definitions given by Aumayr et al.  I mean, I'm just reading it
again today because I've been on the road and it's all a bit difficult, but I
honestly think that they've done a pretty good job, at least from a superficial
reading, of really strengthening a bit the security definitions.

However, I still think there's more work to do myself, I mean it's just an
opinion, because I think we need to really flesh out, even for the most basic
case, which is the PTLC case; that's the thing that most people care about, they
don't care about my weird constructions!  They care about, look, in LN, we're
going to have PTLCs, there's going to be all this money in that, that's actually
really important.  So, we have two parties; are we sure we have the right
security model to assert that using PTLCs at scale is secure?  I think the
answer's yes, but I'd like to see it fleshed out more myself.

**Mike Schmidt**: That's a great, incredibly lucid walkthrough the thought
process.  I'm just going to summarize again.  There are lessons learned from the
development of the MuSig and MuSig2 involving large participants, and
potentially many different sessions happening at the same time, and the fact
<!-- skip-duplicate-words-test -->that that uncovered some potential security concerns gave rise to a similar
consideration with regards to signature adaptors, and that's the motivation for
your post and your work, in addition to some of these other folks' work, of how
can we address that potential concern regarding signature adaptors with the use
case similar to bitcoiners being familiar with being this move to PTLCs?

**Adam Gibson**: I don't want to be a pedant, but I would just correct you on
one thing: "potential" security concerns; they were not potential at all, they
were very actual.  Actually, just to flesh it out a little bit, because I'm sure
even if people did read it back in the day when it was published, they've
probably forgotten, but even the original discovery of the flaw, which was a
paper by Drijvers et al, I think it was very shortly after MuSig originally was
published, they realized that you were looking at even as little as 128 parallel
signing sessions could lead to a forgery essentially; somebody could forge a
signature on your key.

Now, 128 sounds like quite a lot, but think about things like hardware
scenarios, that you could imagine is possible.  But even worse, about a year or
two after that, there was another paper published, and it's called something
like ROS and I forget what it stands for, like Random Inhomogeneities and
Systems, but I can't remember, but it's called the ROS attack, and this was all
based on Wagner's attack.  And, Wagner's attack is basically saying that, yeah,
it's difficult to find a preimage for a hash function.  That's true, however it
had given a slightly altered version of that problem which is not find a
preimage for a hash function at output, so a specific target value, but find a
sum of hash values from multiple preimages which adds up to a specific target.
That's not just easier, it's ridiculously easier, to the extent that it's
actually very feasible, even with numbers as low as four.

So, Wagner's attack already, and that was what Drijvers et all were showing in
their paper, could attack a system like insecure MuSig with as little as 128
concurrent signing sessions.  But those numbers get even lower now with this
slightly souped-up, cleverer attack, which is based on the same kind of
principle.  I don't know the exact numbers with ROS, but it's even lower.  What
was remarkable about that whole story to me was that it was this incredibly
obtuse mistake in the security proof, where there was just a very slight and
subtle thing where they didn't notice that the ordering of events wasn't quite
correct in order to make the extraction work; incredibly obtuse thing, but
literally within a year, or I don't know if it was two years, maybe just one
year, somebody had found a practical attack.  It really struck home to me that
although all these cryptography analyses must seem incredibly academic to most
people, and they seem academic to me and I spend a lot of time reading them, but
it must seem incredibly academic and basically irrelevant to most people, but
they're really not actually.

So, yeah, basically I'm saying it wasn't just a potential weakness.  I guess you
could say it's potential in the sense that it never actually happened!  That's
fair, I don't think anyone actually got attacked, but that's because the system
wasn't deployed in production.

**Mike Schmidt**: It sounds like a call to action for folks in the community who
have the appropriate technical chops here would be to review the work that
you've put together in your research, and you've noted some areas that need
further analysis and some review on your own contributions.  And so, I guess if
folks listening, or who read this once we get the transcription up, that would
be what you're looking for in terms of next steps.

**Adam Gibson**: Yeah, the way I would look at it is that what I've written is
kind of a start towards a goal to proving that we can build arbitrary protocols,
maybe not arbitrary, that's the wrong word, but we can build protocols that use
adaptors in this kind of more parallel way, for example multiple adaptors at the
same time, or one adaptor in multiple different contexts.  I think we need to
really concretize and bed down what is and is not secure in that context, rather
than what's so far in the literature in my opinion, apart from maybe this Wei
<!-- skip-duplicate-words-test -->Dai paper, but so far in the literature, what it is is, "Here's an adaptor and
this is secure", which I think is not quite enough, is what I'm trying to get
at.

**Mike Schmidt**: Thank you, Waxwing, for creating a Twitter account just to
join us today and providing that walkthrough!  We appreciate that and I think
we'll move on to the rest of the newsletter, so you're free to stay on and
you're free to drop as well, so thank you for your time.

**Adam Gibson**: Thanks.

**Mike Schmidt**: Next section of the newsletter are the releases and release
candidates.  We have two this week.

_LND v0.16.2-beta_

The first is the LND v0.16.2-beta, which is a minor release and the release
notes note, "Performance regressions introduced in minor prior release", so
there are some performance considerations in the last release addressed by this
beta.  I didn't see anything else notable.  Murch, I'm not sure if you looked
into that particular release either?

**Mark Erhardt**: I was just looking at the release notes prior, and it's
apparently about the pool scanning locking during start-up.  So, if that's an
issue you were having when you restart your LND node on 0.16.1, and I think a
lot of people should have upgraded, because there were some important security
fixes in 0.16.1, then 0.16.2 will fix that for you.

_Core Lightning 23.05rc2_

**Mike Schmidt**: Core Lightning 23.05rc2, we did a little sneak preview spoiler
alert for this last week talking about blinded payments now being supported by
default, and some PSBT v2 support, so we won't spoil it any more than that, and
we'll note more when this is actually officially released, some more of the
details there.  Murch, any comments?

**Mark Erhardt**: Yeah, I was looking at this, and so there's a major release
and obviously there's a bunch of things that we have reported on in previous
newsletters, for example also this release has PSBT v2 support, and the
commando-blacklist and commando-listrunes.  So, when you have given people
permission, or other users permission to run stuff on your node, the
rune-handling that was recently merged is going to be in this release.

_Bitcoin Core #25158_

**Mike Schmidt**: First PR in the newsletter this week is Bitcoin Core #25158
that adds an abandoned field to a series of RPCs, that indicate which
transactions have been marked abandoned, and there's three RPCs that this new
field is added to: gettransaction, listtransactions, and listsinceblock.  Murch,
what does it mean to mark a transaction as abandoned?

**Mark Erhardt**: So, when you create a transaction from a Bitcoin Core wallet,
your wallet will occasionally rebroadcast that transaction if it has not gotten
mined yet.  This is because nodes do not rebroadcast transactions after the
first time they see it.  So, when a node, for the first time, learns about an
unconfirmed transaction, they offer it to all of their peers, but they will not
do that ever again for the same transaction, unless the transaction was dropped
and they learn about it afresh.  So, your wallet will occasionally rebroadcast
your transactions in order to make sure that they actually remain known to the
network and eventually get mined.

To abandon a transaction allows you to instruct your wallet to stop this
rebroadcasting, basically saying, "I'm not longer seeking for this transaction
to be confirmed".  And subsequently, the inputs that you used on that
transaction are also freed up so you can make a conflicting transaction to
permanently invalidate the prior original.

So, this was essentially, or was especially useful before RBF.  Now that most
people, well 70% of all transactions seem to be signalling replaceability, I
think one would mainly just RBF that transaction in that case.  But yeah, the
abandoned transaction RPC is for marking something as no longer sought to be
confirmed.

**Mike Schmidt**: I believe the original issue that spawned this PR was someone
posting about Specter software not being able to get the abandoned information
about particular transactions from the Bitcoin RPC, which was one of the
motivators for this particular PR.

_Bitcoin Core #26933_

Next PR is Bitcoin Core #26933, introducing the requirement that each
transaction meet the node's minimum relay fee in order to be accepted into the
mempool, even when being evaluated as a package.  So, this PR is part of the
Package Relay project, which right now you can use in regtest, and you can use
the submitpackage RPC to test out packages.

The motivation, as I understand it, I'll give a summary and then Murch can clean
up after me, but the goal is to avoid situations where the mempool has non-bump
transactions that are below the minrelaytxfee.  So when you submit a package,
you ensure that those transactions that are bumped at the time of the package
submission, that all those requirements are met, but it's not guaranteed that
the transactions will always be bumped.  So for example, in CPFP, a later
transaction could replace that fee-bumping child without bumping the parent, and
that means that if you've submitted those below the minimum relay feerate,
transactions would remain in the mempool and don't get removed as part of the
replacement.  The reason for that is there's not a DoS-resistant way of removing
them.

So, until there's a DoS-resistant way of removing those previously bumped, but
then umbumped transactions from the mempool, there's this limit that is being
introduced to prevent these below-minimum relay feerate transactions from
entering the mempool.

**Mark Erhardt**: I wanted to clarify a couple of things here.  So currently, we
only look at transactions doing relay as singular transactions, we do not relay
transactions in groups yet.  And therefore, any transaction that we accept to
our mempool by itself individually has to be above minrelaytxfee.  So, minimum
relay transaction feerate is by default set to 1.  It is a configurable setting,
but I don't think that's useful to change it, unless miners start to change it,
which I have seen no evidence for.

So, the idea here was that if we ensured that we can propagate transactions as a
package, we could perhaps have parents that pay zero fee, and that would for
example be useful in the context of LN commitment transactions, because if we
can set the feerate of a commitment transaction at the time that we closed the
channel, for example by CPFPing it the moment that we try to close the channel,
we are no longer relying on guesstimating correctly what feerate we might need
at some point to close an LN channel unilaterally.  And of course, these
commitment transactions are locked in at the last update of the channel and the
feerates might have changed significantly since the last payment went through
the channel, so we might just simply not be able to use the current feerate as
it is to close the channel because, I don't know, for some reason the mempool
produces blocks that are over 154 sats/vbyte in the last 24 hours.

Anyway, this was just a temporary exploration on the Package Relay branch, or
project, and we're not reintroducing a limit; this limit has never been removed
in production, it's just within the project it was noted that we have this
situation, as Mike described, where we can add transactions to the mempool, but
then remove the children that were making them minable, or attractive for
mining, and thus have these zero-fee transactions sticking around the mempool,
but that are not useful and cannot be mined by themselves, or are not valuable
to be mined by themselves.

_Bitcoin Core #25325_

**Mike Schmidt**: Bitcoin Core #25325, introducing pool based memory resource
for the UTXO cache.  So, if I'm understanding this correctly, it sounds like
before this change, every time you needed to track a new UTXO, you would be
allocating that memory and freeing that memory for that particular UTXO in a
<!-- skip-duplicate-words-test -->one-off basis, and this change changes that so that that in-memory UTXO cache is
now allocated in larger chunks, called a pool, and that can save up on
performance.  Murch, I know you did the writeup for this, so perhaps you can add
some color to that.

**Mark Erhardt**: So, especially during Initial Block Download (IBD), the most,
or many memory accesses come from us looking up whether a UTXO exists for the
transaction that we're trying to spend.  So, as you know, when you process the
block chain, you're applying all the transactions block by block, and each block
basically updates the UTXO set which has our current ledger.  So, the UTXO cache
is one of the central data structures in the Bitcoin node, especially heavily
used during the IBD.

The idea here is now instead of, as you said, doing the memory allocation for
every single data object, when we add a UTXO or remove a UTXO, or flush the
UTXOs to disk because we're running out of cache, we have basically specialized
memory management for the UTXO cash.  So, this specialized memory management
just takes a bigger chunk of memory and then divvies it up into slots of various
sizes, where it can store the information about UTXOs.  And whenever it removes
a UTXO from the cache, it just opens up the slot again, sort of like, I don't
know, if other kids watched their Windows computer do defragmenting on their
hard drives, it's pretty much like that.  All these little gaps that you have,
you just put new UTXOs in them if they fit; if not, occasionally you add stuff
to the back.

So, this gets rid of the need of making these memory allocations individually
and instead, we now have essentially an operator that manages it for the whole
UTXO cache.  And the cool thing about this is, it makes our node able to store
more UTXOs at the same time with the same memory, and it makes it much faster so
that benchmark tests have shown this to make about 20% speed improvements on
IBD.  So, this is a pretty awesome, big, well not a huge code change, but a
pretty cool optimization.

_Bitcoin Core #25939_

**Mike Schmidt**: Bitcoin Core #25939, it adds optional transaction index
capabilities usage from if you're using the utxoupdatepsbt RPC.  So, the base of
the utxoupdatepsbt is that searches the UTXO set and pulls in outputs being
spent by that particular PSBT.  And for various reasons, certain data needs to
be in there for signers.  So, this RPC call searches the UTXO set, finds that
data that is required for signers, and there is a bunch of nuance around what I
just outlined, and maybe, Murch, it's worth you elaborating on that.  Why do we
need certain data in certain scenarios in a PSBT for a signer?

**Mark Erhardt**: So, we use PSBT, Partially Signed Bitcoin Transactions, as a
transfer format when multiple parties, or one party with multiple devices, is
trying to create a transaction.  The idea here is not all users are able to sign
for everything, so we create just the skeleton of the transaction and fill in
the necessary signatures.

Some people discovered a couple of attacks on user transactions, where if you
made a hardware device, for example, sign first for one input then for another
input on the same transaction, but in both cases pretended that each of the
inputs were smaller by the same amount, while giving the other input the correct
amount, you might be able to trick the hardware signing device into thinking,
"This is totally fine", and the amount in the outputs is lower, so they overpay
on fees.  So basically, they pretend twice that the total input amount is the
same amount, but it's lower on the one input first, and then on the other input
later.

This works because hardware signing devices do not have memory, right.  They do
not remember that they just signed the same transaction before on the other
input.  They just blindly go by the instructions, "Hey, here's a half-signed
transaction, please sign for input 1 or input 2", and they check whether the
sums make sense and then sign for it.

As a response to that, a fix was to provide information about the UTXOs, and
especially to show that the amount on the output is actually -- maybe this is
not clear, but in the inputs we do not commit to the amount that the input has.
The amount is set by the prior transaction output, so the information is not
necessarily part of the transaction that we're currently signing, which is what
makes this attack work in the first place.

So, the first thing was to (a) segwit commits to the amounts of the inputs, so
some of that attack is prevented; and then (b) we provide the whole transactions
to the hardware signing device so that the transaction can be checked for the
txid, and thus our commitment in the input is specific enough that we cannot be
tricked about the amounts.  Anyway, to look up this information and to provide
it into the transfer for my PSBT, we use an RPC called utxoupdatepsbt, and this
RPC previously was only looking in the UTXO set or in memory for that
information.  But as we just established, the information on what the amount was
actually lives in the prior transaction output.  So, if the transaction no
longer is in the mempool, we might not even know the amount.

This PR now adds, if you have a txindex, which is optional, on your full node,
then you can also look up in the txindex those transactions, and thus be able to
provide this necessary information with the utxoupdatepsbt call.

**Mike Schmidt**: Murch, is this a performance improvement, or is this actually
adding a feature by being able to look through the txindex?  Does this fix
something, or is it just a performance improvement?

**Mark Erhardt**: Basically, if you didn't have the transaction on hand, you
were not able to get that information with utxopsbt, except through the UTXO
set, I guess, and I don't know exactly how you would scan from the UTXO set.
Maybe you would actually need to scan the chain state database, or the block
files, to find the transaction to get the whole transaction that way, because in
the UTXO set, we also don't start the entire transaction anymore.

So, I think it would be primarily a performance improvement, because looking up
<!-- skip-duplicate-words-test -->transactions without knowing exactly where your data is is way slower.  And with
the txindex, if it's present, you know exactly at what byte range the
transaction sits in the block files.  So, it would be faster and cheaper to look
it up, I think.

_LDK #2222_

**Mike Schmidt**: Next PR is to LDK, LDK #2222, and this involves LN Gossip
messages.  So, on the LN, there are a bunch of gossip messages that are parsed
between the different nodes, about what's going on with the LN topology.  And
originally, there was a concern about DoS of these gossip messages.  One way
<!-- skip-duplicate-words-test -->that that was mitigated is that the gossip messages are tied to a particular
UTXO, and that's one of the ways to stop a DoS attack.  But there are certain
scenarios in which LN nodes might not have the ability to look up or validate
the authenticity of those UTXOs and may default to using other DoS prevention
mitigations.

So, LDK is now no longer requiring authentication of messages against a
particular UTXO, so that these other nodes, maybe lightweight nodes, can use
different information to mitigate DoS attacks, without having to have UTXO data.
Murch, did you get a chance to look into LDK #2222?

**Mark Erhardt**: Yeah, I looked at the PR and the comments a little bit.  I
think you got it right.  So, the main point is, and maybe a little background
color to that.  We do not want people to be able to broadcast and gossip about
channels that actually don't have an onchain footprint, because that would make
it trivial to DoS other participants in the LN with irrelevant information.  So,
having a transaction onchain and proving that you can spend it and using those
two things to announce that there is a new channel that has joined the LN, or
that the information of that channel has been updated, is essential for the
network not to be drowned in junk data.

I've heard recently a couple of talks and thoughts about this push from last
year, I think, where people were starting to consider how you could have other
forms of proof, like just proving that you own a UTXO, rather than specifically
showing what the anchor UTXO is; or there is a token-based system, I think, that
actually Waxwing came up with at some point.  Anyway, we want to get away from
telling people exactly what the channel anchors are in the long run, because if
we can move to taproot-based channels, they look already like singlesig outputs.
If we no longer have to reveal exactly what UTXO creates the channel, then we
would be able to have a way more private LN in the long run.

So, I think this fits into the broader picture here, and yeah, so LDK seems to
be thinking forward already, "How can downstream users of the library that maybe
do not have access to the full UTXO set still work with channel announcements
and produce channel announcements".

_LDK #2208_

**Mike Schmidt**: And the last PR for this week is LD #2208, adding transaction
rebroadcasting and fee bumping.  So, to set the context here, so Bitcoin Core
currently does not rebroadcast transactions; that's the responsibility of each
wallet to ensure that the transactions of interest are in the mempools.  That
also includes LN implementations and also force close transactions, force close
channel transactions related to that LN implementation.  And so, we've seen this
the last month or so, LND and Core Lightning implementations adding
rebroadcasting features and fee-bumping features.

So, this is LDK's version of that, which is implementation of rebroadcasting of
transactions and also some fee-bumping logic into the node that is tracking
these force close channels, which helps mitigate certain types of pinning
attacks.  It also ensures that those transactions get confirmed.  Murch?

**Mark Erhardt**: Yeah, basically this is just about being sure that even
exclusive feerate environments, channels that are unilaterally closed get
cleaned up completely.  And if you had some sort of payment in flight on the
channel when you had to first close it, those might be stored in HTLCs, so
they're still time-sensitive because, as you know, either the funds flow in one
direction when someone reveals a secret, or they flow back to the sender if they
time out.

So, you need to not only broadcast your commitment transaction, but afterwards
also spend the HTLCs back into your wallet, or the counterparty needs to collect
them.  This seems to resolve some issues around when feerates wildly swing or
change.  As mentioned, that's sort of the thing we've been seeing since the end
of February.

**Mike Schmidt**: Well, thanks to all our special guests today, James,
Salvatore, Steve Lee and to my co-host, Murch.  Thank you all for your time and
we'll see you next week.

**Mark Erhardt**: Thanks, guys.

**Mike Schmidt**: Sorry, Waxwing, you too!  Thanks, Waxwing, for joining us.

{% include references.md %}
