---
title: 'Bitcoin Optech Newsletter #256 Recap Podcast'
permalink: /en/podcast/2023/06/22/
reference: /en/newsletters/2023/06/21/
name: 2023-06-22-recap
slug: 2023-06-22-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Thomas Voegtlin to discuss [Newsletter #256]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/72827593/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-5-30%2F7eec49a9-2434-de27-39f0-8d802b80f852.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody, Bitcoin Optech Newsletter #256, Recap on
Twitter Spaces.  It's Thursday, June 22nd, and we're going to be talking about
BOLT11 invoices and submarine swaps and Just-in-Time channels.  We're going to
talk a little bit about mempool and policy.  We have a slew of interesting
changes to clients and service software that is implementing cool Bitcoin
technology.  We have an Eclair release and a few LDK PRs to get into today.
Introductions, I'm Mike Schmidt, I'm a contributor at Optech and also Executive
Director at Brink, where we're funding Bitcoin open source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Thomas?

**Thomas Voegtlin**: Hi, this is Thomas.  Well, I'm the founder of Electrum and
also the author of this proposal regarding BOLT11 invoices.

_Proposal to extend BOLT11 invoices to request two payments_

**Mike Schmidt**: I think we can jump right into it.  Thomas, thanks for joining
us.  The first and only news item we have this week is the proposal to extend
BOLT11 invoices to request two payments.  So, Thomas, we have BOLT11, which is
an invoice protocol for requesting payments over Lightning, and right now, the
use is one invoice and one payment.  So, I guess if you wanted to do two
payments, you would have two invoices.  But maybe you can explain why there
might be reasons that we would want two payments from one invoice, and feel free
to provide any context or background to kind of work your way into your proposal
here.

**Thomas Voegtlin** Yeah, okay.  Well, I'm going to try to do this from memory
because I don't have my computer screen in front of me at the moment.  But yeah,
the idea is, I call it bundled payments.  The idea is that you have some
Lightning Service Providers (LSPs) that will accept a whole invoice and then
they will pay you either in a submarine swap or by creating a channel.  They are
going to do an onchain payment or a Lightning payment in a Just-in-Time (JIT)
channel with the Hash Time Locked Contract (HTLC) that you send them.  And then,
since we want the transaction to be atomic, the preimage is going to be revealed
by the user and this is what settles the transaction.  In both sides of the
swap, if it's a swap or if it's a JIT channel, then the service providers
actually create a channel with an HTLC, and then the user settles this HTLC.

So, in both situations, the service provider takes a risk, which is they send a
transaction onchain, and if the user in the end does not show up and doesn't
reveal the preimage, they will have to get refunded onchain.  So, there are some
costs that are onchain for which they take the risk, or they don't want to take
the risk actually.  So, the way it currently works with a submarine swap
provider, such as Lightning Loop, is that Lightning Loop internally is going to
send two invoices, I suppose, or that's also what Boltz can do if you don't use
their website, because on the website it's a bit awkward to show two invoices;
but there is an invoice that is for the prepayment of the mining fee, and then
there is another invoice that is the invoice for which the provider does not
have the payment.  So, am I still on?

**Mike Schmidt**: Yeah, you're doing great.

**Thomas Voegtlin**: Okay.  So, yeah, the general idea is that with the
prepayment is that the prepayment has a different preimage and the service
provider has this preimage, and then the main payment is the payment for the
whole invoice.  So, the two payments are bundled in the sense that very often
because the fee payment is small, it's possible to find a path to pay the fee,
but you will not necessarily find a path for the main payment, which is much
larger.  So, what the service provider should do is they should not settle the
prepayment until the main payment has arrived.  So, this is why you cannot
really just consider those as two payments.  It's like a big multipath payment
(MPP) from the service provider's perspective, because they should wait until
both payments have arrived before they settle the prepayment and then they go
onchain.

In order to do that currently, you need the software that can handle this.  So
this is why we have specialized software in the wallet, that's the case in
Electrum.  We support submarine swaps in Electrum with our own server, and it's
also the same with Lightning Loop.  So Lightning Loop, if you go to their
website, you see that they call this a "no show penalty", but that means the
same.  It means that if you don't reveal the preimage onchain, they are going to
charge you something anyway.  So, I have not reverse-engineered how it works,
but I guess it works in the same way with two invoices.  And actually, yeah,
when I say I have not reverse-engineered, I also want to mention that the server
side of the Loop is not open source.  So, they don't want to open source this
because it's the core of their business.

Now, if I talk about the JIT channel service, we have this, for example, in
Phoenix.  Phoenix has a channel that is opened to you by the server, and it's a
similar situation because they do not open source that part of Eclair.  I mean,
Eclair is open source, but not the additional logic that is used in this
particular service, so it's not possible for me to tell exactly what they are
doing.  But my suspicion, and in the mailing list I was kind of asking whether
Phoenix is sending the preimage before the onchain transaction or after, and I
noticed that Sebastian carefully avoided to answer that, and they also do not
open source this part of Eclair, so we don't know.  But my guess is that Phoenix
actually sends the preimage before, so that the server doesn't take any risk of
a griefing attack.  And then once they have received the preimage, it means that
they can be paid, so then they open a channel.

So, this is how I believe it would work, although in the mailing list, Bastien
suggested that there are two ways to do this that are not trustless, and then
the third way is what I propose with a prepayment, with two bundled payments.

**Mark Erhardt**: I'd like to recap the situation so far.  So, there are a
number of use cases in which there are two payments that need to be flowing into
a node before one payment flows out.  And there is currently no good way of
combining that both of those preconditions for the forwarding, as well as
receiving the other payment, have happened at the same time already before the
other payment is forwarded.

**Thomas Voegtlin**: Well, there is a good way to do it, but you need to
distribute specialized software.  So you need to have a user base that has your
software.  It's the case, if you have -- I mean, if you are Lightning Labs and
people install loopd, the local client for Loop on their computer, then the
software handles this.  And it's the same with Phoenix.  I mean, Phoenix handles
this with a private protocol with Eclair.

But my proposal, the goal of my proposal is to open this up to possible
competitors by not making the requirement that the payment comes from a wallet
that is aware of this logic.  The onchain payment has to be handled with a
specialized logic, because there is either some channel being open or some swap
that is going to be swapped onchain, so there has to be this logic onchain.  But
my idea is that the offchain payment could be achieved by any wallet.

So for example, you could do a submarine swap where you don't use the same
wallet to send and to receive, and this is very important.  If you have ever
used the Boltz website, this is exactly the situation they are in.  The website
handles the onchain logic, the JavaScript on their webpage, but they do show you
a Lightning invoice.  So they don't provide a wallet, they expect you to pay
with your wallet.  And because they cannot show anything else than a BOLT11
invoice, they will not have this prepayment on their website, so they are
vulnerable to this attack.

**Mark Erhardt**: All right, I think I get the big picture now.  So, could you
get a little more into what you're proposing with the multiple invoices, or
multiple payments in one invoice?

**Thomas Voegtlin**: Yeah.  Well, my proposal was to do this in BOLT11, because
I believe it would be deployed faster because it's very simple to do it in
BOLT11, and because it does not require any more messages to be exchanged.  And
actually, Dave Harding, I don't know if he's online here, but he even proposed
to simply by doing a keysend, so we don't even need to include the preimage hash
for the prepayment in the invoice.  So, the only thing that we need to add is an
amount.

So yeah, my proposal is to extend the invoice by a field, and I think it could
be done in BOLT11, but then the feedback I received is that it should be done in
BOLT12.  I am not convinced, but I'm happy if it's done in BOLT12 anyway.  I
think I do see that BOLT12 is superior to BOLT11, of course, but my concern is
that it's going to take a lot more time to have the ecosystem support BOLT12,
whereas it could be deployed much faster if it was adopted in BOLT11.  But yeah,
anyway, in that case it will also need to be done in BOLT12 I guess, because in
the end we want this to be supported in the long run.

So yeah, my proposal is just to have an invoice that is telling you that there
is a prepayment that is either optional or required.  So if it's optional, then
it means that the service takes the risk to have a user who pays only with a
single payment hash; and if it's required, then the user needs to send the
prepayment on a different payment hash.  So, in the case if it's required, the
prepayment would be subtracted from the main amount so that it remains
compatible for the clients who do not understand.

**Mike Schmidt**: You mentioned some of the feedback, so from Matt Corallo, who
mentioned that there's certain things in BOLT11 that still aren't implemented
that aren't even new, and potentially adding this proposal to BOLT11 might not
be a great idea; and you mentioned t-bast's comments suggesting adding it to
offers instead.  There was additional discussion around splicing out being a
similar proposal and why not modify the protocol you're talking about to -- or,
what is the relation to splice outs versus submarine swaps?  If we get splice
outs, does that help this protocol or the use case that it enables in any way?

**Thomas Voegtlin**: I'm not sure.  I mean, first, splicing is probably not
going to be there for a long time, but it's also not achieving the same thing,
because when you splice out, you just lower the capacity of your channel.  So,
submarine swaps are useful for merchants who want to have incoming capacity and
that they cannot achieve that with a splice, I suppose.

**Mark Erhardt**: Even a splice in would only add capacity to your side, so it
wouldn't increase the amount of money that you can receive; that's what you
mean, right?

**Thomas Voegtlin**: Right, but we are talking about splicing out.  I mean, we
are talking, yeah, but even in the other direction, right.

**Mike Schmidt**: There was also another piece of feedback from Roasbeef that I
think you touched on a bit already under the header in our writeup of,
"Dedicated logic required for submarine swaps".

**Thomas Voegtlin**: Yeah.

**Mike Schmidt**: Maybe you could speak to that.

**Thomas Voegtlin**: Well, it's the same.  The dedicated logic has to be with
the onchain part because you need, like I said, you need to sweep funds onchain,
so there has to be some code that does that.  My proposal is not about removing
that, it's impossible to remove.  Indeed, you need to have some client that is
able to do that.  But this doesn't have to be the same as the client that is
doing the onchain payment, and it also doesn't have to be the same entity, it
doesn't have to be the same person.  So, this is why I was mentioning that it
would enable competition.

For example, you can understand that if Lightning Loops had a client that shows
an invoice, then instead of paying directly with the local LND, they could
actually show a Lightning invoice, and this invoice could be paid by any wallet,
so they could have more users.  They could also, of course, lose users because
some LND users could decide to use a different service than Lightning Loop more
easily, because apparently the situation is that a service that is trying to
compete with them, such as Boltz, is exposing itself to this risk of the
griefing attack, because they have to pay the onchain fee first.  So my
proposal, the goal is just to make competition possible in a way that is
trustless.

**Mike Schmidt**: Murch, what else should we be asking about?

**Mark Erhardt**: Honestly, this is a little bit out of my area of expertise, so
I think my questions are answered.

**Thomas Voegtlin**: Yeah, okay.  My feeling is that I'm not sure whether, okay,
I don't want to sound pessimistic, but I'm not sure whether my proposal is
really understood well by everybody.  But I do see that both these companies who
are designing the protocol, Lighting Labs and Async, they have this business
model either with the submarine swap service or with the JIT channels, and they
do not open source their service.  So, I'm wondering whether there is a conflict
of interest here, because the fact that they don't open source it means that
they are probably not willing to play the game of competition there.  So, yeah,
it's a bit...

**Mark Erhardt**: Well, I'm not sure if that's fair to say, given that they
built their business model around it and they have tooling for it now, so I
wouldn't call it unfair if they say, "Well, we don't need this because we have
it already".

**Thomas Voegtlin**: It's perfectly fine not to open source their services, I
totally accept that.  What I'm saying is that I'm not sure if it's a good thing
that they do design the protocol and they might not be incentivized to -- I mean
they might not see the interest of this proposal, because it doesn't favour
them.

**Mark Erhardt**: Yeah, I can agree with that, I think that is a slightly
different nuance.  But yeah, so for them, it's maybe not as important to solve
this problem anymore because they have solutions in place already.  And given
that they are contributors to the protocol discussion, they should consider to
prioritize it like you have to.

**Mark Erhardt**: Yeah, they have solutions and they are in a dominant position.

**Mike Schmidt**: So, Thomas, I guess the call to action for the audience is if
they're curious on the technicals, obviously read the mailing list discussion
that's going on.  If they are in the business of providing these sorts of
services or considering providing these sorts of services, namely the submarine
swaps and the JIT channels, potentially LSPs, etc, to maybe weigh in on this
discussion to make sure that businesses and users and library developers are
being heard in this discussion.  Would you have any other call to action for the
listeners?

**Thomas Voegtlin**: Well, I mean if they don't really understand how it works,
maybe they should just play with submarine swaps with the different providers
that exist, that they would better grasp exactly what I'm talking about, like
how it is different to use Lightning Loops and to use Boltz.  Okay, I cannot
really say that Boltz is a satisfying alternative because it's using JavaScript.
So, it's also not completely trustless, but at least you would understand that
they show an invoice and you can pay that invoice with any wallet basically, so
it's very different.

Initially when I -- okay, now what I want to do in Electrum is to have this
adjusting time channel service implemented.  But initially, we also considered
to use submarine swaps as a way to receive onchain when you do not have any
channels; instead of having the service open channel to you, they would just do
a submarine swap to you.  But it's the same story.  I mean, so the sender and
the receiver are different entities and the sender needs to send a prepayment,
unless the service takes the risk of the griefing attack.

**Mike Schmidt**: Well, Thomas, thank you.  Yeah, thanks for providing an
overview of your proposal and some of the context here.  If folks are
interested, I would encourage them to jump on the mailing list to opine per
Thomas seeking feedback and potentially some additional voices compared to who's
opined so far.  Thomas, you're welcome to stay on.  Thanks for joining us for
this newsletter, but if you need to jump, we understand.

**Thomas Voegtlin**: Thank you.  And yeah, I just wanted to add that we are
going to also help design this in BOLT12.  I mean, I'm not religious about
BOLT11, I just want this to happen as quickly as possible because I think it's
important for the general ecosystem.  Okay, thanks for having me.

**Mike Schmidt**: Thanks, Thomas.

_Waiting for confirmation #6: Policy Consistency_

Next segment of the newsletter is related to our weekly series we've been doing
for the last few weeks about waiting for confirmation.  This is Waiting for
confirmation #6, titled Policy Consistency.  And Murch, last week we talked
about policy rules, which are these additional set of rules around transaction
validation that are applied in addition to Bitcoin consensus rules.  And since
these policy rules aren't consensus, someone operating a node has a large degree
of subjectivity about which policies to enforce and to what degree.  Murch,
maybe you can opine a bit.  What do you think listeners should be thinking about
when considering their policy, specifically relative to the rest of the network?

**Mark Erhardt**: Yeah, it's funny that you're starting off like that because we
originally had titled this section as, "Policy as an Emerging Construct from
Individual Choices".  But the more we looked into all the settings that we
provide in Bitcoin Core, and thinking about the use cases in which people might
want to change them, we found that actually we expose very little of the policy
rules to user configuration.  And we have not come up with a ton of choices that
users can make right now that make sense to us.  So, mostly the things that I've
brought along as ones that can be changed easily are how quickly transactions
expire from your mempool, and how big your mempool is.  And those, I think, are
mostly relevant if you're doing some sort of data analysis or if you have a
reason to keep transactions around longer than usual.

Other than that, it actually seems to me that we have been fairly conservative
in providing options to change policy, and I want to get a little more into why
that is the case.  So I think this was a little touched-upon before in the other
posts that we have made, but really overall our goal is that every mempool has
the same transactions, because when we have the same content in our mempools,
all of us can estimate better the feerates, we can better anticipate what will
be in the next block, and we can relay blocks more quickly using compact block
relay.

But of course, the transactions, unconfirmed transactions, are not protected by
proof of work.  They are just, anyone can write them, anyone can write multiple
versions that spend the same UTXOs.  So, they're a DoS vector that is much more
accessible to users than, for example, blocks, because blocks have to be
substantiated with proof of work, and therefore it's really expensive to create
any meaningful amount of data to propagate blocks with.  So, while our goal
would be to have homogenous mempools across the network, we actually only
forward transactions at best effort across the network.

So, we are trying to get every transaction to everyone, but we can't guarantee
it.  And especially in a dynamic environment where nodes come online and go
offline at will, they might just not be around when a transaction is relayed to
them, or when a transaction is first submitted to the network and relayed among
peers, and it doesn't make sense to go back and continuously rebroadcast all
transactions, as that will just increase the bandwidth use.  For the most part,
the nodes that do absolutely need to get all transactions, they tend to be
online all the time anyway.  So, yeah, does that make sense so far?

**Mike Schmidt**: Yeah, yeah, that's great.  Keep going.

**Mark Erhardt**: Okay, so one point that has come up a little bit also in the
context of increasing your mempool size and your expiration times is that it
changes what interactions you can have with fee bumping and CPFPing
transactions.  So for example, if your parent transaction has too low of a
feerate and the feerate gets enforced individually on every transaction right
now because we don't have package relay yet, then you wouldn't be able to submit
the parent transaction to your own mempool anymore if it's below the mempool's
dynamic minimum feerate.

So, if you have a bigger mempool, of course, you can still submit the parent
transaction and then submit the child transaction with the high fee to have a
package feerate across the two of them that is sufficient to get mined.  But
you're sort of lying to yourself a little bit if none of your peers have
similarly big mempools, and therefore none of your peers accept the parent
transaction.  And therefore, you see your package in your mempool, but it still
doesn't get to the miners because none of your peers actually accept it to their
mempools, and so it doesn't get relayed across the network.

Similarly with RBF, if your mempool is smaller, you might drop transactions
earlier than other people, and then would be able to submit a new transaction
that spends to the same inputs, that gets accepted to your mempool, because your
mempool no longer has the original that was in conflict.  And you don't have to
consider the RBF rules in that case because the original is already gone from
your mempool, so you don't have to exceed the absolute fee, you don't have to
exceed the feerate by a certain margin, you just can submit a new transaction.
But again, if nobody else has the small mempool as you, they might still have
the original and they will apply the RBF rules if your transaction hasn't
signaled replaceability; or even if it has signaled replaceability, you need to
overshoot by a certain margin for the replacement to overwrite the original.

So, whenever your mempool size differs from that of your peers, you might be
able to have interactions with your mempool that are not replicated across the
network, and therefore might not have the effect that you intend across the
network and especially in the miners mempools.  And what I'm basically saying
is, if we all generally run with the same values for our mempools, we will
experience the best outcome because our mempools will behave similarly.  When
you can submit new transactions to your mempool, you can expect them to also be
submitted to other people's mempools, you can expect them to arrive at the
miners.  And yeah, in a way, I'm hoping that it illustrates why we should all be
converging on similar policies.

Right now, I actually don't see a ton of policies where people should have
vastly diverging opinions unless they have specific use cases.  Like for
example, mempool.space certainly wants to run with a bigger mempool in order to
show all the transactions that are still waiting that most nodes have dropped
already, or yeah, that might also make sense for a miner.  But yeah, that's
pretty much the gist of our post this week.

**Mike Schmidt**: Do you feel that lately, these last six months, since there's
been a bunch of interesting protocols using the Bitcoin blockchain, that there
is a pressure to change any of these policy rules?  So for example, we've had
Joost on and there's other individuals and projects that are doing things like
relaying certain transactions through Nostr; and we have people submitting
non-standard transactions directly to miners to get 4 MB transactions approved;
or for whatever reason, routing transactions to mempool spaces, new transaction
accelerator, etc.  Are those in your mind pressures to loosen the policy in any
way at the Bitcoin Core level?

**Mark Erhardt**: I think it's certainly a prompt to look at whether all of our
standardness rules and policy settings still make sense.  And there was also a
very good write up by Instagibbs recently that we want to actually get into a
little bit next week, that looks at all the policies and the reasons why we have
those.  So if you can wait a little, we'll have something on that next week,
hopefully.

So, while Bitcoin is a system that is stupid at the protocol level and the
intelligence mostly sits on the edge of the network where people can craft more
complicated contracts, but on the chain we only see the predicates, some sort of
logical prompt that is proven to be afforded or that has been fulfilled by some
witness, that's the system that we have.  We don't want to run the smart
contracts where everybody has to run the smart contract on their own machine in
order to see what the outcome was.  We want to have the smart contracts where
people prove that they have fulfilled the conditions of the contract and you
never need to learn what the conditions were.

So, when I think about what I want to see in the Bitcoin Network and what my
focus is, it's bitcoin, the currency, and that's my focus.  Honestly, I see
people doing inscriptions, for example, and while that's all fine and dandy and
they can use the blockchain as a very inefficient medium for publishing data, I
don't think that's what we're interested in developing and building.  So, if
they have a bit of a hype for a few months and increased demand for blog space,
that's fine and it seems to be tapering off now, and that's more than fine as
well.

But other than that, I have not really seen big pressures or good, well-funded,
or well-founded reasons for revisiting standardness.  There was a proposal to
drop all standardness rules, which I don't think showed any good evidence that
this is the right way to go.  There is, of course, the use case that we don't
have package relay yet, which was an issue for LN implementations around the
peak feerates, where they ran into the issue where they couldn't submit parent
transactions anymore in order to CPFP them.  And maybe that's a good makeshift
solution until we do get package relay on the network, to have a way to get
parents with their children to miners; or maybe miners should have a way to
allow you to submit that directly to them intermittently.  But in the long run,
we want that to be fixed at the protocol level, where people are able to submit
the most worthy transactions to be mined in a way that it propagates on the
network proper.

So, yeah, I have not seen a lot of evidence that our standardness rules are
completely wrong.  I don't think that inscriptions offer whatsoever any reason
to change standardness.  And yeah, we're working on the one for Lightning.  Did
I miss any?

**Mike Schmidt**: I don't think so.  No, that was a good response.  Thanks for
giving your opinion on that.  You alluded to the topic of next week's entry in
this series, which is what policies have been adopted in order to fit the
network's interest as a whole, and so I guess we'll look forward to that next
week.  Anything else you'd say in wrapping up?

**Mark Erhardt**: No.  I'm curious myself what I'll write for next week, so
let's leave it at that!

**Mike Schmidt**: Awesome!

_Greenlight libraries open sourced_

Next section of the newsletter is our monthly segment in which we feature
interesting updates to Bitcoin wallets and services.  And we have six of those
this week.  The first one is Greenlight, open sourcing some of their libraries.
And so we had covered Greenlight in a previous Changes to the services and
client software segment, in which they announced their service which is
essentially Core Lightning (CLN) nodes in the cloud, in which you separate the
node operation, which in this case the provider is Blockstream, from the control
of the funds held by the node, which would be the user.  So, you get an LN node,
but you still control the funds and you don't have to worry about the node's
operation as much as that's outsourced to a service provider.

So, this bit of news was the announcement of open sourcing a bunch of libraries
related to that Greenlight node in the cloud service.  And so, Greenlight
exposes a bunch of services to users and developers over gRPC, which allow
applications to integrate and also users then to manage and control their node
running the Blockstream infrastructure behind the scenes.  And there's also a
large number of different language bindings for easier integration, etc.  And I
believe that Greenlight already has a few partners that are running on this
infrastructure currently.  Murch, thumbs up?  All right.

_Tapscript debugger Tapsim_

The next piece of software that we noted was Tapsim, and this had actually come
up in a previous newsletter.  We were talking with Johan in the discussion of
MATT in Newsletter #254, but I thought it was worth noting again here.  Tapsim
is a script execution, debugging, and visualization tool for tapscript, and it's
specifically built for using btcd, so the Go implementation for Bitcoin, and
it's inspired by a similar tool, btcdeb, which is written by Kalle Alm.  And
Tapsim lets you hook into the btcd's script execution engine, and then you can
actually interact with that as you progress through the state of every step of
the script execution.  So, you can actually use your keyboard, left and right
arrows, to step through script execution, and then there's some visuals that go
along with that, including visualizations for what does the script look like,
the stack, the alt stack and the witness stack.

So that was a pretty cool tool.  Murch, I'm not sure if you got a chance to use
that, or if your familiarity is just the discussion we had previously?

**Mark Erhardt**: I'm not more familiar about this; it sounds fun.  It sort of
seems to fit a similar niche as a miniscript and miniscript policy, where you
try to abstract away the actual tapscript from what the user needs to know and
define.  So, I'm wondering if when someone has looked more at this, whether they
are complementary or whether they're alternatives to each other more.

_Bitcoin Keeper 1.0.4 announced_

**Mike Schmidt**: Next piece of software is Bitcoin Keeper.  So, Bitcoin Keeper
is a mobile wallet that supports multisig and different hardware signing
devices.  And as of this 1.0.4 release, it also supports coinjoin via the
Whirlpool protocol.  And I think it's the first iOS Whirlpool coinjoin wallet,
but I think it actually might also be the first coinjoin wallet on iOS; I'm not
100% sure on that, but I thought that was notable to discuss, as iOS users may
have not had coinjoin options previously.  Murch, any thoughts on Bitcoin
Keeper?

**Mark Erhardt**: I have also not looked at that one yet.

_Lightning wallet EttaWallet announced_

**Mike Schmidt**: Next piece of software is EttaWallet, I think I'm pronouncing
that right, and that's a new Bitcoin mobile and Lightning wallet that is
currently in testnet only.  So, it's in development, maybe even in the
proof-of-concept realm right now, and it uses LDK behind the scenes for
providing Lightning features in the wallet, as well as some different libraries
from Synonym that built on top of LDK specifically for using in mobile apps.

One thing that was interesting about this wallet is that it was inspired from a
design and usability perspective from the Bitcoin Design Community's reference
design for a "daily spending wallet".  So, the Bitcoin Design Community puts out
these open source reference designs, based on their knowledge of usability and
perhaps some research, of what would be a good user flow for different
scenarios.  And so, they came up with a collection of those different scenarios
and put them into this daily spending wallet reference design.  And the author
of the software used that design and built a working wallet on top of that.

So, I thought that was interesting that these designs that had been put out open
source were picked up and used in a wallet.

_zkSNARK-based block header sync PoC announced_

Next piece of software is BTC Warp.  BTC Warp is actually a proof of concept as
well, and it uses zkSNARKs to prove the validity of the longest valid
proof-of-work chain.  And so, for this initial proof-of-concept release, it's
initially syncing for light clients, and as a quick tl;dr on zkSNARKs, zkSNARKs
allow you to generate a proof that some computation has some particular output
in such a way that the proof can be verified extremely quickly, even if the
underlying computation takes very long to run.  That is me reading Vitalik's
quote on zkSNARKs.

The blog post that we noted pointed out that even light clients still need to
store over 60 MB of data, and they know that they think that this is infeasible
for some users, I guess depending on the device or connectivity, and their
proposal using zkSNARKs, these succinct proofs, BTC Warp would then allow these
light clients to instantly verify proof-of-work chain with a bunch of less
storage, in fact only 30 kB, as opposed to 60 MB.  And their goal is to be able
to SNARK the full Bitcoin blockchain for full nodes, but they're starting with
light nodes as a first step.

**Mark Erhardt**: That's kind of interesting because we just had talked about
ZeroSync a couple of weeks ago, and ZeroSync is, from what I understand, doing
exactly the same thing or trying to achieve the same thing, where they have a
SNARK-based, not zkSNARK, but SNARK-based proof of the header chain in the works
right now.  And I think they're also at the proof-of-concept stage.

**Mike Schmidt**: Yeah, I think ZeroSync was mentioned towards the end of the
write-up that these folks did who drafted the BTC Warp proof of concept, and
their blogpost is fairly in-depth if you're into zk or SNARK stuff, take a look
at that; they wrote up a lot about their design choices, and things like that.
And we've noted the application to Bitcoin light clients here, but I think they
have some other cross-chain ideas for how this could be used as well.  So, I
figured we'd highlight the Bitcoin portion and we'll leave it to anybody who's
interested to figure out what they're doing with some of the cross-chain stuff.

**Mark Erhardt**: Short correction: ZeroSync uses STARKs, and they here use
zkSNARKs.

_lnprototest v0.0.4 released_

**Mike Schmidt**: Last entry for this segment is lnrototest v0.0.4 being
released.  There wasn't anything particular about this release that I wanted to
highlight, but I don't think that we had highlighted this project previously.
So lnprototest is a project that is a test suite for Lightning, including, "A
set of test helpers written in Python3, designed to make it easy to write new
tests when you propose changes to the lightning network protocol, as well as
testing existing implementations".  And I chatted with Vincenzo earlier, and
there is potential work done on other implementations, but right now CLN is the
one that is best supported for that.  Murch?

**Mark Erhardt**: Yeah, I saw that Vincenzo is here.  I invited him in case he
wanted to say something about it.

**Mike Schmidt**: Well, if he joins, he can opine and augment on that project.
I know it's something that Rusty originally came up with, and I think Vincenzo
is leading now from a maintainer perspective.

**Mark Erhardt**: Yeah, I knew that Christian Decker, a long, long time ago, had
some sort of integration test suite that tried to run all of the basic functions
in the LN against all of the major clients, and he was occasionally posting
updates about what parts of it were compatible by now and what still needed
work.  So I assume that this is the spiritual descendant of that project, but
yeah, I don't follow Lightning that closely, so I'm a little out of the loop on
that.

_Eclair v0.9.0_

**Mike Schmidt**: Moving on to Releases and release candidates, we have Eclair
v0.9.0, which is a new release for Eclair, and it adds support for dual-funding,
splicing, and BOLT12 offers.  In digging into some of the release notes here,
it's noted that these features are fully implemented in Eclair, but they're
waiting on the specification work to be finalized and other implementations to
be ready for cross-compatibility tests, so somewhat hearkening back to what we
just mentioned with lnprototest is this notion of compatibility between the
different implementations.

So, these features are supported and they're implemented, but they're
experimental for now.  And with regards to the splicing implementation, the
implementation that Eclair has in this release is a prototype that differs from
the current splicing proposal.  They've noted that they found multiple
improvements that will be added to the specification.  And also regarding offer
support, the release notes say, "To be able to receive payments for offers, you
will need to use a plugin".  So there's a plugin that supports offers, the
splicing is a little bit different than the spec, and all of these features are
currently experimental, which I guess is what you'd expect at this point in some
of the early stages of some of this being rolled out.

The only other thing to note about this release, and I don't think we put this
in the newsletter, but I saw it in the release notes, is that this release also
makes plugins more powerful.  It also introduces mitigations of various types of
DoS and improves performance in a bunch of different areas of the code base.
Murch, did you have anything else to say on Eclair?

**Mark Erhardt**: Not really Eclair specifically, but it's interesting how,
although Lightning does not have a consensus system and therefore basically all
the clients would be able to iterate more quickly in whatever directions they
want, it takes so long for these proposals, like dual-funding, splicing, offers
to get evened out and ruled out to the whole network.  It's been, I don't
remember how long, splicing is probably three, four, five years old at this
point as a concept.  Dual-funding, it was in the original Lightning white paper,
I think, mentioned as the way that you could fund channels, and it's only really
rolling out in full now.  So, it's kind of fascinating to see how large projects
like this, what sort of release cycles you can have on certain things and other
things.

**Mike Schmidt**: That harkens back a little bit to what Thomas was saying
earlier, talking about extending BOLT11 versus extending offers.  So, yeah, it's
a common theme.  We have two PRs that we wanted to cover this week.  Before we
jump into those, which are both LBK PRs, I wanted to open the floor to any
questions or comments that people have.  Feel free to request speaker access as
we go through these PRs, or you can also comment on this Twitter Space and we'll
try to read that for the audience as well.

_LDK #2294_

First PR this week is LDK #2294, adding support for replying to onion messages
and bringing LDK closer to full support for offers.  The PR noted, "Adding
support for handling BOLT12 offer messages and more generally replying to onion
messages", so to maybe set the context here for listeners, onion messages allow
a Lightning node to send a message to another node in a way that minimizes the
amount of overhead, compared to sending HTLC-based messages or payments.  And
so, it's a way to send messages outside of actually parsing HTLCs around.  So,
these onion messages are used by offers to allow one node to offer to pay
another node, allowing the receiving node to return the detailed invoice or any
other necessary information.  And so LDK needed to support replying to onion
messages in order to support offers, and so not only are onion messages replies
supported, but working towards the BOLT12 offers as well.  Murch?  Thumbs up.

**Mark Erhardt**: Yeah.  Well, I guess the question that you kind of begged a
little bit there is, why would we put a messaging system into a payment network?
And I think the point that one can make here is, you can't really stop people
from using the payment mechanism to send messages, you can just have a multi-hub
payment request that you forward that locks up some funds.  And then in the end,
instead of providing sufficient information to actually create a contract, it
delivers a message to the recipient, so people would be able to build a very
inefficient messaging system that would be indistinguishable from just failed
payment attempts.  And so, to put in onion messaging directly is just a way of
accepting the truth or this fact, and making it such that it doesn't have a big
footprint and lots of funds unnecessarily.

**Mike Schmidt**: Yeah, I think there were some services, I don't know if
they're still around, or software that actually was using HTLCs to send
messages, which is basically, I guess, obsoleted by this more efficient version.

_LDK #2156_

Next PR that we highlighted this week was LDK #2156.  And digging into this one
a bit, some of the quotes from this particular PR is, so first it's adding --
they've already had support in LDK for keysend payments, and they've already had
support for simplified multipath payments; so, those were both supported, but
you couldn't use them in conjunction with each other.

So, as part of the implementation to use both of these together, it was noted
that there's no great way to tell when a node supports this, so they leave it up
to the user to decide when they want to route or send multipath keysends.  And
since multipath payments keysends requires a payment secret, which previously
was not included in the LDK API structure, there could be some issues with
breaking the serialization, so there's a bunch of flags and configuration
options that we noted in the newsletter so that folks know what they're doing
there.

The note about payment secrets is that it's specified by the recipient and it's
a 256-bit secret that is in place to prevent forwarding nodes from probing the
payment recipient.  So, that's the reason for the payment secret, which is the
reason for the compatibility potential break, and so now LDK can support keysend
payments with MPP.  Murch, any thoughts on that LDK PR?

**Mark Erhardt**: Honestly, I'd need a reminder, but I think keysend is the one
where you include the spending secret for the multi in the last hop of the
onion, so that the sender -- isn't it that you basically can make donations by
telling the recipient what secret to use to pull in the payment?  So, if not,
that's the level of understanding that I have of Lightning these days.

**Mike Schmidt**: Yeah, and I think it was also named, at some point,
spontaneous payments as well.  Yeah, the person sending the payment chooses the
hash preimage.

**Mark Erhardt**: Mike, I think we need to get a co-host that understands
Lightning!

**Mike Schmidt**: I've spoken with a few experts, but they are also, as you can
imagine, due to our Lightning coverage each week, very busy doing the creating
of this and not so much the covering of the creating of it.  Vincenzo commented
<!-- skip-duplicate-words-test -->the thread saying he's on web so he can't talk.  So, maybe we can have him in in
the future to talk about a future update to lnprototest.

**Mark Erhardt**: Then maybe we should just wrap here, then I can go to lunch!

**Mike Schmidt**: Well, we're right at the hour mark, so perfect.  Thanks
everybody for joining.  Thanks to Thomas for coming in and thanks to my co-host,
Murch, and we'll see you next week everybody.

Cheers.

**Mark Erhardt**: Thanks for another great episode.

**Thomas Voegtlin**: Thank you.

{% include references.md %}
