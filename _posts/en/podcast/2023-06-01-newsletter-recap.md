---
title: 'Bitcoin Optech Newsletter #253 Recap Podcast'
permalink: /en/podcast/2023/06/01/
reference: /en/newsletters/2023/05/31/
name: 2023-06-01-recap
slug: 2023-06-01-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao, Burak Keceli, Dave Harding,
and Joost Jager to discuss [Newsletter #253]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/71718216/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-5-6%2F3101e9c3-4032-d23b-659c-d297dde80d9d.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #253.  It is
Thursday, June 1st, and we are doing a Twitter Space to recap this newsletter.
We'll be talking about the Ark protocol, we'll also be talking about transaction
relay over Nostr, we'll be talking about bidding for block space in our series
about mempool inclusion and transaction selection, we have Q&A from the Stack
Exchange, we have Bitcoin Core 25.0 being released, and then we have a few
notable PRs that we also covered in the newsletter this week.  So let's jump
into it.  We'll do introductions.  I'm Mike Schmidt, I'm a contributor at
Bitcoin Optech and Executive Director at Brink, where we fund Bitcoin
open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on explaining Bitcoin
to people.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core and I'm sponsored by
Brink.

**Mike Schmidt**: Dave?

**Dave Harding**: I'm Dave, I'm primary author of the Optech Newsletter and
commented on a couple of the proposals this week.

**Mike Schmidt**: Burak?

**Burak Keceli**: Hey, guys, it's good to be here.  So my name is Burak, I don't
work anywhere.  I'm the creator of Ark, I made it public a few weeks ago.  I'm a
bit of a free bird, but I'm excited to be here and discuss further.

**Mike Schmidt**: Joost?

**Joost Jager**: Hey, all.  So I'm mostly a Lightning developer, I've been
working on LND a lot over the past years, and recently also gained more interest
for layer 1.

**Mike Schmidt**: Thank you all for joining us.  For those following along, this
is Newsletter #253.  You can look at the tweets shared in this Space, or bring
up the full newsletter on the bitcoinops.org website and we'll just go through
that in order.

_Proposal for a managed joinpool protocol_

The first item of news this week is a proposal for managed joinpool protocol and
we have Burak, who is the author of this mailing list post, and the idea for Ark
which I think was previously named or unnamed tbdxxx.  So, Burak, thank you for
joining us this week.  Maybe it would make sense for you to provide a high-level
overview of the protocol and how it works, and then I think we can get into some
Q&A.  I know Dave had some feedback on the mailing list and he was kind enough
to join us here to walk through some of that feedback, and potentially clarify
his thoughts and some of the technicals of the proposal.  So, Burak, you want
to...?

**Burak Keceli**: Yeah, sure, guys.  It's Burak again, I'm the creator of Ark.
I think I posted a mailing list, the idea, ten days ago.  It's an idea, right?
It's a new kind of layer 2, offchain, scaling solution layer/privacy tech idea,
and it's in the early protocol iteration phase.  I made it public on stage ten
days ago, same day I posted to the mailing list, had some feedback.  People are
excited, equally sceptical, which is great.  So, I think so far I did a terrible
job communicating the idea with the broader community, I think, but I'm not a
great communicator by any means.

But what I can tell, Ark, I think I'm very confident that it's a great piece of
tech and it can scale.  It does a better job in terms of privacy and scaling
compared to Lightning.  There are some trade-offs, obviously, we can come to
that.  But it's something I've been working on over the past say six months more
or less.  So I mean, if perhaps some of you know, I did some covenant research
and development on Liquid for about two years, and about a year ago I shifted my
focus to Bitcoin-only, Lightning space.  I wanted to explore Lightning and see
what I can do on Bitcoin based on my experience, covenant research and
development on Liquid.

On Liquid, it was me and a friend, we built an AMM on Liquid.  Obviously, on
Bitcoin, we don't have covenants, so we are restricted.  I mean, the script is a
primitive language, it's intentionally kept limited.  And about a year ago, I
just wanted to address these problems, Lightning pain points, right?  Lightning
has many pain points and has a huge entry barrier, right; the friction, end-user
friction and an entry barrier to onboarding people.  So the issue has always
been these two main concerns.  And I think I started working on a Lightning
wallet idea three months ago to address these frictions, and I tweeted about it,
it got some good reception.

Obviously, I mean the idea over time evolved into a new, distinct layer 2
protocol, but it's still Lightning; Ark is Lightning.  Ark started off as a
Lightning wallet idea, and it's still Lightning.  You can pay invoices, you can
get paid from invoices.  I like giving this subnet analogy: Ark is more like a
subnet of Lightning.  We can forward Hash Time Locked Contracts (HTLCs) to
broader Lightning, you can get paid from broader, but internally at the core,
it's a different kind of design.  I don't know what, it's not a state channel,
it's not a rollup, it's like a third category.  I don't know what the name for
this category should be.  Some people give a coinswap analogy, some people give,
I don't know, other stuff, but I'm not aware of these, coinswap and all that.

Again, I've been exploring the Lightning space for the last one year, more or
less, and so, I don't know, Ark is a different kind of thing, maybe.  But yeah,
it has similarities with other protocols.  I mean, it has similarities with
E-cash, it has similarities with Lightning, it has similarities with coinjoins,
it has similarities with two-way pegged sidechains; we can give a bunch of
analogies, yes.  Maybe to start, it has similarities with E-cash because it's
based on Virtual Transaction Outputs (VTXOs) so we have a virtual UTXO set, we
lift UTXOs off the chain, and just like how onchain funds flow, you destroy
coins, you create new coins.  And these coins are short-lived, we give each coin
a four-week expiry; unlike onchain, when you have a UTXO, you can go offline
forever, it will remain there unless you're losing your keys.  There is no
expiry for UTXOs.

Here, they expire at some point, which I don't think is a bad trade-off at all.
If something goes wrong, a boat accident or inheritance-related issues, you can
at least try to reach out to your service provider and claim for a refund.  But
besides that, we give a coin expiry for some good reason, to make the offchain
footprint minimal when we want to redeem them, when we close these -- VTXOs are
like channels.  I like giving this analogy too: Lightning is a 2-of-2; VTXO is
also a 2-of-2, but the main difference is, in a channel, it's in a 2-of-2, you
sign a bunch of channel state updates, thousands of state updates, and then you
can settle back onchain.  On Ark, it's also a 2-of-2, just like a channel, but
think of just signing one state update, just one from the 2-of-2.  That state
update gives the ownership -- it changes the ownership state, whether, "Does it
belong to me; or does it belong to the service provider; 1 or 0?"

So it's kind of like sending all channel funds into your channel partner in one.
And then you push your liquidity into the server, I mean we call the server our
service provider.  It's like an atomic single hub payment.  On Lightning, it's
like you can forward payments across multiple hubs; on Ark, it's a single hub,
it's like an atomic single hub.  Lightning is also great for inner-hub
settlements.  You can open a direct channel with a large hub, or can exchange to
exchange, transfer, and inner-hub stuff.  Ark cannot do it.  Ark is from one
party to the other and the hub in the middle.  So Ark is like a channel, but you
push all channel funds to the service provider, and service provider pushes
equivalent number of funds minus liquidity fees into the recipient end, just
like a single-hop Lightning payment.  But now you're pushing entire money or
entire funds to the service provider.

It has similarities with sidechains too.  I mean, I'm talking about trustless,
two-way pegged sidechains, hypothetical sidechains.  It's like you peg into the
protocol this piece of different software, protocol layer 2.  You peg in, and
peg in stands for lifting your UTXOs.  You can peg into this protocol with your
real, actual UTXOs, and then you get 1-on-1 virtual UTXO.  And this is what
pegging is for.  And when you peg in, you're in the system; and once you're in
the system, you have a VTXO, you're running a piece of wallet client software,
it does coin selection, and it joins a coinjoin session or coinswap session.
So, you join a session, the service provider is also the blinded coordinator.

So, the service provider is three things.  They are the blinded coordinator,
coinjoin coordinators; they are liquidity providers; and they're also Lightning
routers.  But their main job is to do the coordinated blinding, blinded coinjoin
route.  So, when you make a payment, your client coin selects, we take source
data or spending, you join the coinjoin session, the next coinjoin session of
your service provider, and you have a new session in every, say, five seconds.
Again, it's kind of an arbitrary number, it's subject to changes, in fact it's
custom config, and it can adjust the fee market conditions.

You join a coinjoin session, just like how a coinjoin works, like input
registration, output registration, assigning phase, three phases.  So you coin
select, you register for VTXOs under these different identities each, and then
you get blinded credentials minus liquidity fees, and then you join the output
registration, register for the payout VTXOs, but these VTXOs are also under a
shared VTXO.  And then in the signing phase, you anchor your VTXOs that you're
spending into this coinjoin pool transaction using Anchor Time Locked Contracts
(ATLCs), and the coinjoin transaction ends up onchain.

It's very minimal in size, footprint minimal; it's like 500 vbytes, one or more
inputs, three outputs.  I think we can lower this down to two outputs also.  And
then you have a new coinjoin, new onchain transaction every five seconds.  While
this may seem not footprint minimal at all, it is footprint minimal.  I consider
this footprint minimal because you can onboard a bunch of millions like shared
UTXOs, you can get millions of recipients for that particular coinjoin round,
perhaps even more, theoretically speaking.

So, upper bound limit, onchain upper bound limits, I mean the upper bound limit
is in theory infinite, but there are practical limits, such as bandwidth and
computation and all that.  So, there is some upper bound limit on this
obviously, but it scales a lot better, you can make a payment in a coinjoin.
Obviously, anonymity set is everyone who involves in this payment.  Unlike the
coinjoin, they're mostly used for dark market use.  I mean, that dark market use
case here, yeah, it can also be used for that, but there's nothing we can
prevent that.  Like, yeah, it's also payments.  Anonymity set is all -- I mean,
the anonymity set is as large as the payment volume, which is great.  And you
make a payjoin, so you make an offchain swap out, so to speak.  You make an
offchain to onchain swap out, and that swap out is an aggregate transaction by
itself.  It contains a bunch of other swap outs under a shared UTXO maybe;
that's a cool good one-liner.

Obviously, you have the privacy benefits because it's blinded coinjoin, the
service provider in the middle cannot tell who the sender and the recipient is.
Obviously, it's also footprint minimal, also it's convenient to use because we
don't have inbound liquidity here.  Because you're making a swap out every time
offchain to onchain swap out, you can receive without a second thought.  Maybe
we can come to trade-offs later or I can talk about trade-offs also.  Obviously,
there are some trade-offs.

There are two main trade-offs.  Main trade-off is, I mean Ark payments -- if
you're using Ark to accept payments, which you shouldn't in my opinion, if
you're a vendor if you're a merchant, Lightning is better suited for you.  You'd
better use Lightning, because if you're a vendor, you demand instant settlement,
right?  You don't want fraud, you don't want chargeback, you demand instant
settlement, I mean hypothetically speaking, in the hyperbitcoinised world.  And
you're always self-hosting your POS terminal, whatever.  So, you demand instant
settlement and your cash inflows are predictable, right?  You can acquire
liquidity, rent liquidity, according to your needs, and you can obviously run
this piece of specialized software, whether it's BTCPay Server or a Lightning
node in your POS terminal.  You can do it, it's okay, you're a merchant, right?

But for users, well, it's chaotic.  You cannot predict what you're receiving in
the first place.  We're humans, right, we don't know what we're receiving.
Sometimes I receive zaps, sometimes donations, sometimes remittances, sometimes
regular money transfers, sometimes a payroll from a payroll service.  It's
unpredictable what my cash inflows are going to be.  And it's also subject to
DoS.  If I am someone just got on board to Lightning, ie in a hyperbitcoinized
world, I'm worth a bitcoin, I got an orange pill, whatever.  I have to reach out
to someone, like a node on a protocol, to ask them, to beg them, to open a
channel to me, like inbound liquidity, because I can only control this channel.
But I can be a bot, I can just lie.  I mean, you can pay some fees up front, but
really I'm asking someone to open a channel to me, and these channel funds, I
mean, it's unpredictable how I'm receiving on this channel.

Talking at a large scale, it works today, yes, but it's large scale.  I can only
promise to utilize these channel funds, my inbound liquidity.  But probably not,
probably not.  I may not be 100% utilizing, but most likely it's not going to be
enough for me to receive because it's unpredictable what I'm receiving.  And
what happens is, when you don't have enough liquidity, you receive a submarine
swap, but submarine swaps are inherently unscalable.  Anything that touches the
chain is unscalable.  And I always think in terms of footprint, I always think
in terms of global, massive adoption.  Lightning may work today, yes, because we
don't have many users.  Block space can handle that perfectly for today.  You
can open channels, you can ask to open channels and you can open channels'
charge is great, Lightning is great, but at a large scale, I fail to see how
Lightning can scale at a large scale.

But I can see how Ark can do it, because Ark, we don't have channels, it's
non-state channels, you don't ask someone to open a channel to you, we don't
have inbound liquidity, you receive what the sender has, and liquidity provider
provides that equal number of liquidity to the coinjoin transaction.  So on
Lightning, service providers provide liquidity to channels.  On Ark, Ark service
providers, they provide liquidity to coinjoin transactions, so they're different
designs.  But one thing that Lightning and Ark have in common is they're both
liquidity protocols, they're both liquidity networks.  LSPs provide liquidity to
channels, they provide liquidity; Ark service providers, they also provide
liquidity.

The second trade-off is obviously, yes, Ark uses liquidity less efficiently
compared to Lightning, although liquidity is 100% utilized.  On Lightning, you
can't promise that.  You might open a channel to someone, liquidity is on your
own end, but you can't promise the other guy just promised that you're utilizing
these funds.  On Ark, they're entirely utilized.  If sender is sending money to
recipient, X sats, liquidity provides X sats, equal number of liquidity.  So
it's entirely utilized.  Also, Lightning is like a multi-hub payment sort of
stuff.  You draw payments across multiple hubs.  On Ark, because it's a single
hub, like single-hub payment, atomic single-hub payment schedule, you only have
one hub and liquidity is only deployed on that one hub.

So, I think, yes, it may seem that Ark, yes, its capital/liquidity requirements
are higher significantly, which is true.  It's I think 3X to 5X and maybe
perhaps 10X higher because you're locking up liquidity one way only, yes.  On
Lightning, you have a channel, you can move money in that channel forever, yes.
On Ark, you have to provide liquidity on an ongoing basis, and constantly
providing liquidity for four weeks because you're locking up every single time
your liquidity to be unlocked four weeks later.  And of course this four-week
timeframe is also a bit of an arbitrary number.  It is adjustable, it's manual
config, or it can adjust to liquidity capital conditions.  But just to keep
things simple, I just made up these numbers, four weeks and five seconds.

So yes, Ark, you're locking up liquidity for a long time for an obvious reason,
but the trade-off there is, yes, you're locking up liquidity; but because
liquidity is entirely utilized, 100% utilized, and because recipient is always
one hop away from the sender, I think Ark may use liquidity as efficiently as
Lightning.  Obviously, you have this convenience of inbound liquidity you
receive without having any setup.  You just download the software, an Ark wallet
and all you have is a Bitcoin address, just like how an onchain wallet UX works.
And Ark mimics the onchain UX, obviously.  You destroy UTXOs, you create new
ones, you have an address from which you can get paid.  It's a dedicated address
and it's going to be your npub.  So it's paid to npub, using style and payment
style tweaking.  So whenever you send a payment, you know the npub public key,
it's a selection of the public key of the recipient, and you add a tweak, add an
ephemeral value to it, and send this ephemeral value to recipient out of band.

**Mark Erhardt**: Can I jump in here?  So, you've given us a pretty broad
overview of your proposal, and I would like to try to summarize it a little bit.
What I took away from it is that you can have very fast offchain payments
between participants of the same ASP.  They have great privacy, even against the
ASP, because the payments are mixed at every hop.  It onboards users very easily
because you can receive without making an onchain payment first to open a
channel, or something like that, you can directly become a user of an ASP.  And
then on the downsides, I have a couple of questions.

So, you want to have a responsive design, or responsive UX, where payments
between participants on the ASP are going to be locked in pretty quickly.  And
for that, you propose that there's this pooled transaction every five seconds.
So, I see how this will work very well if you have a lot of users and it will
scale well, because then the cost of the pool transaction is, of course, shared
by all the participants that send a transaction within those five seconds.  But
really, what I don't see is how does an ASP jump from not having any users to
having enough users that they can pay for this every-five-second pool
transaction, or even if you make the interval a little longer?  You need at
least one or two payments within the timeframe, but if you only get one payment
and then try to be responsive, the payments will be fairly expensive at first in
order for the ASP to even breakeven on their cost.

So how does your proposal go from zero users to being sustainable cost-wise?  Is
it sort of like, you need a lot of investment at first to scale it up, and then
once it's big it'll carry itself; is that the idea?

**Burak Keceli**: Yeah, so the onchain fees, yeah.  So, who covers onchain fees?
Let's address that.  It's the users who covers them.  So, users pay two fee
tiers when they make a payment.  They pay the covered onchain fees for
themselves plus the liquidity fees their liquidity provider charges.  So,
liquidity providers are safe, liquidity providers are not paying the fees for
their own pool transactions.  They charge fees from their users.  And if there
is no pool, like if there are no users, there is no pool transaction, obviously
not.  If there are no coinjoin users, there is no coinjoin transaction.

But if there is at least one, one user who wants to make a payment and joins a
coinjoin session, there has to be this coinjoin transaction.  And because if
that coinjoin transaction is minimal, like 550, 560 vbytes in size, that user,
that single user pays fees for it, which is like paying a regular bitcoin
onchain transaction, which is not a bad deal.  Obviously, if you want to run an
ASP, you have to go on an uptime server with some onchain funds available to
you, like available onchain funds to provide liquidity further.  You have to
make sure you have enough funds to provide liquidity for the next, say, four
weeks on an ongoing basis.

But if you end up having no users, well, you're perfectly safe.  You're not
covering the onchain fees, users cover them for themselves.  And if there is no
usage, you just unlock your liquidity after four weeks.  There is no risk for
you.  And the initial onboarding, yes, if you have only one user, well, you're
not -- I mean, a few users, you're not making much of a profit.  Yes, same goes
for Lightning too.  But ASPs are perfectly safe.  To make that clear, onchain
fees are not paid by them, and obviously the more users we have, the cheaper the
fees become, onchain fees-wise, because the fees for that shared UTXO full
transaction are shared among other participants; ie, if onchain fees are like
$10 and we have like 100 participants, each pay $1.  If we have 1,000
participants, each user pays $0.10 for the bitcoin.

**Mark Erhardt**: No, I understand that, but what I don't understand is where
does the first user come from?  If you only have a single user within a
timeframe, the coinjoin is not going to mix anything and they have to pay the
whole fee.  So, you would want to have multiple users so the fees are shared, so
the coinjoin is useful.  But what's the incentive for the first person to start
using it, right?  So it's both more expensive and less beneficial at first while
there's few users, while it only becomes beneficial and cheap to use if there's
many users.  So I think it has a bootstrapping problem, you see what I mean?

**Burak Keceli**: Yeah, so actually I designed Ark as a Lightning wallet, right?
You can think of it as a Lightning wallet.  You're just a user, like one user,
who you're downloading a Lightning wallet, Ark wallet.  Yes, you deposit bitcoin
to it.  Well, you peg into it because when you onboard first, there are no VTXOs
in existence, so you peg in on your own.  Pegging in is as simple as funding an
onchain address.  And what you can do is just use Ark wallet to pay Lightning
invoices to like a Starbucks, an El Salvador, whatever; really, just pay
Lightning invoices.  You're not using, obviously, if you're the first user,
you're not using it for the coinjoin, mixing of coins or doing internal
transfers because there is no other user, you're using Ark solely to make
Lightning payments.

**Mark Erhardt**: Oh, that's cool.  Okay, that's what I was missing.  Sure, if
you start using it as a Lightning wallet, you have already an incentive to make
a payment every once in a while, which you can also use to double down as your
refreshment payment and get around the four-week timeout.  And then you do join
the pool transaction, you get the privacy benefits if there are more users.  It
will still be somewhat more expensive at first though, to be part of the
service, right, because currently we're not paying $1.50 or so for Lightning?

**Burak Keceli**: Yeah, so if you're the first user, you have to pay like a
regular onchain transaction, just like an onchain wallet pays.

**Mike Schmidt**: I want to take the opportunity to bring in Dave Harding, who
did the write-up for this item this week, and also had some interaction with
Burak on the mailing list.  Dave, obviously we've gone through some of the
overview here.  I want to give you an opportunity to (1) clarify anything for
the audience that you think would be valuable to clarify, and (2) ask any
questions of Burak that maybe you didn't get to in the mailing list so far.

**Dave Harding**: Sure, absolutely.  So, Burak, first of all, thank you for
making the proposal.  I always like reading about new stuff like this.  This is
a very interesting idea.  So, in a lot of your discussion about this, you
compare this to Lightning, and so I've kind of looked at it through that lens.
And you were going into this earlier, I think we may have got a little
sidetracked, but the downsides of this proposal.  And you were saying that
perhaps merchants shouldn't use this for receiving their own payments.  Is that,
when a payment is sent using Ark, it needs to be confirmed?  The payment that
the service provider makes, the Ark service provider makes, it goes onchain, it
starts out unconfirmed like any other transaction and it gets confirmed.  So,
it's security for a third party, someone who doesn't trust the service provider,
someone who doesn't trust the sender, the security of that payment depends on
onchain confirmation; is that correct?

**Burak Keceli**: Oh yeah, so by the way, that's correct.  The senders, by the
way, cannot double-spend it, unlike onchain payments.  Onchain payments can be
double-spent by the owner of the UTXOs via inputs.  But here, it can only be
double-spent by the service provider, because the coinjoin at his onchain has
one or few inputs, and is the single-sig owner of these inputs.  Apart from
that, yes, if you're a merchant, yes.  I mean, ideally, you're not trusting
anyone.  That includes the service provider you're using, I mean the sender
actually is using.  Ark, yes, you should not accept payments ideally in the
short term, unless we have this penalty mechanism I mentioned on the weekly
mailing list.  But we can come to that in a second.

But Lightning is again, yes, better suited for payments because you have instant
finality on Lightning.  Here, you don't.  In order to consider a payment
"final", you need to wait for onchain confirmations.  For vendors, yes, this is
a risk because vendors do not want chargeback, right?  But for end users, it
might make sense.  I mean, obviously, if you're an end user, you should wait
confirmations too.  But what you can do, I mean, ideally you receive payments
from friends and family anyway, but also you have, when you receive funds, like
from an end user standpoint, you receive funds from someone you don't know, it
doesn't really matter.  The funds are available to you right from there, like
how you can trade unconfirmed transactions in a mempool, you can hand over
VTXOs, you can hand over zero-conf UTXOs to friends and others, and you can in
fact pay Lightning invoices with them.

So I receive a VTXO in a coinjoin, it's not confirmed, it sits in mempool, it
can in theory be double-spent by the service provider, yes, and I don't consider
it final.  But the funds are available to me and I can pay Lightning invoices
with them through the same service provider.  The service providers again are
also LSPs, and the service provider is the only guy and the only party who can
double-spend my transaction, my incoming transaction, but the same guy, the same
party is also the Lightning route, and I route payments through the same party
with their cooperation.

But for vendors, yeah, I think you should not accept payments on Ark unless we
have a penalty mechanism.  Sorry, I should follow up with our convo on mailing
list on this.  So, if we have a hypothetical opcode called OP_XOR, the Bitwise
logic opcode, previously disabled, or OP_CAT concatenation opcode, like we can
constrain nonce in a signature.  This is a hypothetical future extension thing.
But I've made peace, I've made my peace with that.

I mean, I think Ark is great as it is, but if you are to bring a penalty
mechanism, we need these opcodes to constrain nonce.  And if you reuse your
nonce, the ASP reuses your nonce in a pull transaction, anyone can forge their
public key; but I can, as a user, redeem, like claim my previously spent VTXOs,
just like how an inbound liquidity works.  You can penalty the channel
liquidity; here, you can penalize your channel partner.  In this case, channel
partner is your liquidity provider, service provider.  I can forge signature
from the 2-of-2 because VTXO is a 2-of-2 with a timelock back to myself.  But
the shared UTXO also has a timelock back to the service provider for every
timelock.  And I can't forge signatures from the 2-of-2 to claim my funds.

The service provider cannot collaborate with the miner.  If the service provider
is a miner themselves, you're concerned mailing list doesn't work because the
timelock is not over yet, the four-week timelock is not over yet.  And within
this timeframe, four-week time frame, as a user, I'm the only guy, I'm the only
party who can forge signature from the 2-of-2, because the 2-of-2 collaborated
path in the VTXO gives him high precedence.

**Mike Schmidt**: Dave?

**Dave Harding**: I didn't quite catch all that.  I think we can probably save
that particular discussion for the mailing list.

**Mike Schmidt**: Yeah, sure, let's follow it up on the mailing list.

**Dave Harding**: Yeah.  So I guess I was just trying to think about this in
comparison to Lightning.  So your concern here, as I understand here, is a big
part of this is liquidity for everyday users, right?  That's your, that's a huge
part of your concern here is -- right.  And so, I'm just thinking through
Lightning, and I think we kind of already have the feature set there that you're
looking for here.

So, let's say we have two average everyday users.  We have Alice and Bob.  Alice
wants to send a payment to Bob, and they both use Lightning, but Bob doesn't
currently have enough liquidity to receive Alice's payment.  And so what Alice
can do is, she can open a new channel to Bob, and she can do a push payment, is
what I think they call it in Lightning, where the channel is opened in a state
where Bob receives all the funds.  So I just want to walk through this really
quick, how this works in Lightning, for the listeners, is that in Lightning a
funding transaction is just a 2-of-2 multisig; it's kind of like exactly what
Ark is, a 2-of-2 multisig.  And as long as Alice knows Bob's public key, she can
create that funding transaction without any interaction from Bob; she can just
create an output for a regular transaction.  As a regular bitcoin transaction,
Bob doesn't need to be online at the time that transaction can get confirmed
without Bob's input.

Then, the initial state of the channel, Alice can create that again offline
without Bob's participation and then send it to him through an async
communication method, like email, just an out-of-band communication again like
Ark.  She can send that initial state, which is just a signature, it's just some
data and it's Alice's signature saying, "Bob, here's 1 BTC in this initial
channel state".  And so for Bob to trust that, he has to wait for confirmations.
And so ignoring the scaling aspect, which I can come back to later, but ignoring
the scaling aspect, I think this looks very similar in user experience to Ark.
Bob can trustlessly receive money on LN by waiting for a certain number of
confirmations.  It doesn't require his interaction, and it can be done using
out-of-band communication.  What do you think, Burak?

**Burak Keceli**: Okay, so you're saying Alice is a user, Bob is a user, and Bob
I think doesn't have enough inbound liquidity, so Alice opened the channel to
Bob; is that correct?  Or, Alice is a service provider or something; or Alice is
just an end user?

**Dave Harding**: Alice is just an end user.  Alice and Bob are just everyday
users.

**Burak Keceli**: Great, but do you guys realize what kind of UX assumption is
this?  Alice is an end user and Alice is going to open a channel, a literal
channel to Bob.  Channel liquidity management is already a big problem, and yet
we are asking Alice to, this wallet software is opening channel to Bob and
assuming Alice has enough onchain funds.  I mean, opening channels and closing
channels, they don't only scale in terms of onchain footprint and not only in
terms of convenience, but literally like because of the inbound liquidity
problem, what you're describing is, yeah, one way to mitigate it.

Yes, it might work in theory, but in practice, a user opening a channel to other
user, it just doesn't work, and that's what literally Ark tries to solve;
offloading complexity from end users.  But end users should not deal with
anything, no complexity, no channel management, no nothing, no management, no
liquidity, no concern.  And let's offload this entire complexity to the service
provider in the middle who can take care of everything for you, yet as a user, I
retain my self-custody.  That's literally what Ark tries to solve, offloading
the complexity from end users.

**Dave Harding**: I guess I just don't understand where the complexity here is
because Alice, first of all she needs to have funds to pay Bob.  That's going to
be true any trustless protocol; she already has to have the money, and that
money can be for Alice, it can be onchain in her onchain wallet, or it can be
offchain with splicing, which is we're getting pretty close to splicing in at
least two or three implementations, two implementations of LN.  So, Alice needs
to have the money to pay Bob and if Bob doesn't have a channel, whether he's
using Ark or he's not using Ark, he's just using regular LN, he's going to have
to wait six confirmations, or however many confirmations he wants, to receive
that money.

So I think the UX here is exactly the same whether we're looking at Ark or we're
looking at Lightning.  It's not a liquidity management here, because Bob doesn't
need to have liquidity to receive an onchain transaction, and a channel funding
transaction is just an onchain transaction with some extra data sent out of band
for that initial state.

**Burak Keceli**: So what you described involves a loss of friction, the main
friction being assuming Alice has enough onchain funds to open a channel to Bob,
and that's a big, big UX assumption.  I think in an ideal world, everyone should
have one unified balance, an offchain balance, not onchain, because I mean it's
not convenient, also it doesn't scale; opening channels do not scale.  Also,
there's another thing.  From Alice opening a channel to Bob, obviously Bob needs
to wait for confirmations, yes, and that also goes to Ark.  But on the scheme
you're describing, for Bob to receive money, yes, he has to await confirmations,
and he has to await confirmations to forward that payment further.

On Ark, the user, end user, doesn't have to await confirmations to forward that
payment further, forwarding as in paying another invoice, paying or making
internal transfers, because Ark uses ATLCs instead of HTLCs.  A double-spend
attempt breaks the atomicity from there.  If there is a double-spend attempt,
the sender, in this case, Alice, gets a refund.  On Ark, Ark receives the refund
too.  But on Ark, if there is a double-spend attempt -- so on Ark, there is no
preimage, right?  We don't have HTLCs, we have ATLCs.

As an entity, in this case, like in the same example of Ark, Alice opens a
channel to Bob.  In this case, Alice is the service provider, not an entity.
That's one thing; there is no friction.  Again, a central hub takes care of it
for you, not an end user.  End user doesn't have to have any hassle, no nothing,
no friction.  A service provider takes care of it for you, that channel opening,
so to speak, and that's kind of how Ark works too, yes.  You have a coinjoin,
coinjoins, and you have a neat channel in a coinjoin, yes.  So, the end user is
not taking care of it.  And the channel, I'm receiving funds, I'm Bob, I'm
receiving some funds from Alice; Alice is then the service provider.  And I
don't have to wait for confirmations, I can literally pay a Lightning invoice
with them, just like how I described.

This doesn't work on Lightning, because on Lightning, someone opens a channel to
me, the channel is zero-conf.  If I'm not awaiting confirmations, I mean
obviously if I want to make payments, another payment with those funds, and I
don't want to wait for confirmations, obviously, because if I want to make a
payment, that channel liquidity has to be available on my end first for me to
make another payment.  And in order for this to work, I mean, I don't want to
wait.  If I'm not waiting, I have to reveal my preimage, reveal my preimage for
the payment.  But when I reveal my preimage, the sender, Alice in this case, can
double-spend my channel, the channel she opened to me, or it could be a service
provider, it doesn't matter, yet takes my money, yet the sender's money, because
I revealed my preimage.  So it's like a double-spend.

On Ark, it's not the case.  There is not only one entity like a central hub
taking care of it for you like the channel liquidity management.  Also, it's
convenient to use because you don't have to wait for confirmations to forward a
payment further.

**Mark Erhardt**: I'm not sure I follow this argument because if someone opens a
channel to you and they fund the channel and send you some of the initial
balance, and you make a payment through that channel opener, the only money and
the only counterparty that can lose money is the other side because you're going
to pay through them out.  So, they're basically giving you credit and you are
using that credit immediately.  But I think we are already 45 minutes in.  I
think we would want to wrap the discussion a little bit.  So, if you both have
some concluding thoughts on the debate or the conversation, maybe you could try
to move towards a final thought.

**Dave Harding**:** **Sure.  I think, again, I'm just going to say this is a
really interesting proposal.  I think it's going to be fun for the next few
weeks for us to explore the edges of it and see how it compares to the existing
solutions, and I'll try to post on one of the mailing lists my thought for how
Ark compares to channel funding, so that maybe Burak and I can go into more
detail later.  So, thank you, Burak, for this really interesting idea.

**Burak Keceli**: All right.  Cool, guys, thank you.  So, I'll follow up on our
previous convo from a week ago and we'll move from there, sure.

**Mark Erhardt**: Thank you, both.

**Mike Schmidt**: Yeah, thanks for joining us, Burak.  And folks who are
interested can go to arkpill.me for more information and also check out the
mailing list post.  And I know Burak is working on GitHub repository for some of
the documentation that people are interested in.  So, keep an eye out for all of
that and we will cover in the Optech Newsletter accordingly.

_Transaction relay over Nostr_

Next item from the newsletter is Transaction relay over Nostr.  And, Joost, you
posted to the Bitcoin-Dev mailing list some prototype that you had been working
on based on an idea from Ben Carman about using the Nostr protocol for relaying
transactions.  And I know folks most commonly may be familiar with Nostr as the
basis of decentralized social media platforms, but can also pass messages that
are not necessarily related to social media posts.  And in the context of this
discussion, it sounds like some of the messages that could be passed around are
bitcoin transactions or a group of transactions like packages.  So, Joost, do
you want to explain the idea a little bit more and the prototype that you have
going?

**Joost Jager**: Yeah, yeah, definitely.  So for backgrounds, the way you could
see this is that traditionally, bitcoin transactions are relayed across the
Bitcoin P2P Network to miners.  And apparently, but I'm not one of those people,
there are people that are friends with miners and they're able to send them
direct transactions directly by email for inclusion in a block.  And I thought,
wouldn't it be great to have also alternative means to reach those miners that
are accessible to anyone?  And then, the Carman, he came up with this Nostr
standard to relay bitcoin transactions.  And also to me, that looked like quite
like a suitable alternative transport mechanism.

But it doesn't need to be Nostr necessarily.  Yesterday, I started experimenting
with transaction relay over Twitter.  Like, why not?  Somebody also commented
there that maybe miners should be sort of scavengers, just scouring the
internet, trying to find anything that pays fees that allows them to build a
better block, and not restrict themselves to P2P and possibly email, but just
look wherever transactions show up.

But this Nostr idea I think is particularly interesting because in Nostr,
there's also ways in the protocol itself to do anti-DoS.  So there are Nostr
relays, for example, that require a fee to be paid if you want to post there;
and if you misbehave, I assume your key will be banned, something like that.  So
yeah, if you can reuse that functionality that already exists to make this
relatively safe to do, it seems like a good option.  But the main idea here is
just to explore alternative relay mechanisms for bitcoin transactions to not
only rely on the P2P Network.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Hi, yeah, I found this really interesting.  So, thanks for
working on this, and I just kind of had some clarification questions.  So, are
you thinking Nostr would be another decentralized network that would relay
transactions; or are you thinking just more methods for miners to receive or
have people submit transactions to them directly?

**Joost Jager**: Yeah, I think both actually.  So, like an alternative
decentralized network for transaction relay, but the main idea, as I mentioned,
just to provide alternatives, increase resiliency.  Let's say there is something
with the P2P Network that makes it so that transactions cannot be propagated,
for whatever reason.  Then there are fallback mechanisms in place that work in a
completely different way possibly.

**Gloria Zhao**: What kinds of kind of -- I'm imagining censorship vectors or
maybe just inefficiencies, like are there examples in particular that you're
thinking of?

**Joost Jager**: I'm now just going to make this up right now.  Just the main
idea here was just resiliency, it can't be bad, it seems to me.  But let's say
it's possible to block P2P traffic for Bitcoin nodes, or that there's like a
firewall instantiated somewhere; if the whole system, the connection between
users and miners, is also possible across different transport mechanisms, that
wouldn't be an instant problem, you can just fall back to any of the others.  Or
even better, anytime you want to broadcast a transaction, you just do it through
three different medium.  So you broadcast on P2P, you do it on Nostr, you do it
on Twitter, and smart miners will just look for everything because it increases
their chances of picking up the best transactions, even if one of those mediums
is blocked.

**Gloria Zhao**:** **Okay, and what did you mean by DoS concerns?

**Joost Jager**: Yeah, I know what you mean.  So, suppose a miner would just
open up an endpoint for anyone to submit transactions to their mempool.  Maybe
they are worried that they get so many transactions flowing in there that they
need to start managing that, or basically they are they are DoSd on their
endpoint; and with Nostr, this is what I imagine how this might play out in the
future.

You have these relays and they are already trying to specialize in DoS
protection.  They also do this for social media, I believe.  At some point,
there were a lot of free Nostr relays and they were spammed heavily and they
started experimenting with these Lightning fees.  So if you, as a miner, only
connect to Nostr relays that have some kind of protection in place, and I would
also say that if you connect to Twitter, you're basically relying on Twitter as
the anti-DoS mechanism.  If you want to use Twitter, you need to, I don't know
what you need to do, give your phone number or something like that.

So the idea is the same that they have another service that makes sure that the
flow is filtered and then you just subscribe to that.  So as a miner, you don't
need to worry so much about that.

**Gloria Zhao**: I see, so you're thinking of DoS mostly as computational
resources that could be exhausted through validating transactions?

**Joost Jager**: Yeah, yeah, that's what I was thinking.

**Gloria Zhao**: Okay, and network bandwidth, I suppose, would be kind of
included in that?

**Joost Jager**: Yes.

**Gloria Zhao**: Okay.

**Mike Schmidt**: Murch, you have your hand up?

**Mark Erhardt**: Yeah, I have two thoughts on this proposal that I thought I'd
put out there.  So, one is I think that you mentioned in the context of your
proposal that one of the concerns is, of course, if you have commitment
transactions that cannot be relayed on the network because their own feerate is
under the eviction feerate, and thus most mempools just don't even accept that
transaction into their mempool.  And, it's impossible to CPFP that transaction
because when the parent transaction doesn't make it into the mempool, currently
we will not accept the child transaction either.

So, clearly you're concerned about us being unable to relay packages, and that
being a detriment to Lightning nodes right now, especially with the feerates and
block space demand being all over the place.  So, I think I appreciate that
concern and, well, Gloria has been working on this for a couple years now to fix
in full on the mainnet.  But clearly, that's also still taking time and is not
quite where we want it to be.  So in a way I perceive this as a rallying call to
put more resources toward fixing package relays.

The concern that I have with this proposal is, I think for the Bitcoin Network
to remain as decentralized as possible and especially to maintain the
censorship-resistance properties that we like in the Bitcoin Network, we need to
make sure that all the juicy transactions and all the fees that are available in
the system are readily available to all participants.  So, if we want people to
be able to jump in and become miners because the existing miners are not
confirming the transactions we want, our response needs to be that we need to
make sure that everybody gets all the transactions, and new mining pool entrants
have access to all the fees that everybody else has.

In the past few weeks, we've seen proposals for basically private mempools and
new out-of-band mechanisms that would make it harder for miners to learn about
all transactions, and that might unfairly favor big mining entities because it
would be easier to just submit transactions to the biggest three or five.  So
I'm a little concerned on that aspect.  What do you think about that?

**Joost Jager**: Yeah, I understand what you mean, but I think for Lightning,
there's already a problem today.  With these high fees, people actually ran into
that issue that they couldn't get that commitment transaction confirmed.  So
basically there's funds at risk.  And if you then have to choose between just
letting that problem be versus having a temporary, alternative transfer
mechanism to get them to miners, even though it might indeed, as you say, not
provide the global access that the P2P Network might provide, I think it's still
better than having nothing.

Also, in the case where packages would relay over P2P, where all that work is
completed, I think there's still value in having redundancy, like having
alternative mechanisms, even if they are not as easily accessible as the P2P
Network, just in case as an insurance.  And finally, I don't think this is
something that you can stop because if miners are incentivized to pull
transactions from as many sources as possible, what can you do about that?  You
cannot talk about it, but it might happen in the event anyway.  And in fact,
it's already happening, isn't it, with miners reading emails containing
transactions and putting them into blocks.  So yeah, there's also so much you
can do in preventing that.

**Mike Schmidt**: Dave, I see you have your hand up.

**Dave Harding**: Yeah.  So when I read Joost's post, what I really thought of
as how it would work is that we would use the Nostr relay for exceptional cases,
and we would do our best to optimize traditional P2P relay for average cases.
If we saw a use case growing on Nostr, that would be a good sign that we should
be optimizing P2P relay for that case too.  It would be a feedback loop kind of
thing.  So that the Nostr relay, although they might end up using it, people
might end up using it for all their transactions, we would really want that
network, that sort of side network, for exceptional cases, people who wanted to
do weird stuff, or a situation where we don't have package relay yet in a
deployed node and people need it now, so they're turning to Nostr.

In my reply to the post to the mailing list, I tried to think of ways that we
could just solidify that, how to make that more realistic, by thinking about how
we could just have people, instead of sending individual transactions, just send
whole candidate blocks to miners and have them figure out, "Hey, this is a more
profitable little block I'm mining right now, maybe this is worth it".  So that
was just my thinking, was that we really want to keep P2P relay, we want to keep
that working really well, but it's good to have an alternative mechanism for
cases where P2P isn't working for people right now.

**Gloria Zhao**: Yeah, just could I add on to that, if that's okay?  I think
there's a lot in the P2P transaction relay that maybe people are not aware of,
that builds towards these design goals we have of censorship resistance and high
accessibility of being able to both join the network and broadcast your
transaction, or be one of the people who takes those transactions and produces
blocks.  And there's a lot of privacy stuff that's built into our transaction
relay, in addition to the kind of DoS and network bandwidth and cash usage
concerns that are maybe a bit easier to plug in to something like Nostr relay.

Yeah, and I agree fully with Harding that if there's a lot of adoption of
alternative mechanisms and of submitting out of band or privately, that we
should take as a sign to improve the P2P transaction relay network, so that we
eliminate these kinds of inefficiencies.  Ideally, package really just works,
but we're just not there yet.

**Mike Schmidt**: Joost, did you have any final thoughts or things that you'd
like folks who are listening now to experiment with or provide feedback on?

**Joost Jager**: Yeah, so the other thing I often bring up, we've been talking
about package relay and maybe getting package relay sooner by using a different
mechanism where it's easier to implement, at least temporarily.  But I think the
other thing is about these non-standard transactions, like we had some
discussion in the PRs about it as well.  And of course, there's aspects of
non-standardness that are good, just protecting the historical reasons, etc.

But there's also non-standard transactions that actually end up in a block.  For
example, these huge jpegs, or the other one is usage of the Annex.  And
something like the Annex, it's perfectly valid to use it in blocks, but it feels
like it's sort of gate-kept by the policy that nodes use.  And you could also
say it's sort of subjective whether this is a good thing or not.  And, yeah, I
can also imagine that miners just looking to maximize fees, they would be happy
to accept transactions that use the Annex, for example, but it's not possible
because the P2P Network doesn't relay it.  So I can also see some interesting
dynamics coming up if you use alternative relay mechanisms that do not have
these limitations as much.

**Mark Erhardt**: Can you provide an example of how the Annex is being used
right now, because that's news to me and probably a bit of an issue with future
updates?

**Joost Jager**: Yeah, I think it's not used.  Actually, I scanned the chain and
there are zero Annex transactions that have been done, if I didn't make any
mistake there.  But there are a lot of ways it can be used.  So for example,
these inscriptions, I think with the Annex, you don't need to do the commit
reveal scheme anymore, but you can just put your additional arbitrary data in a
single transaction.  You don't need two transactions anymore, so it makes things
more efficient on the chain.  And I think in various places, there's a whole
list of things that you could do with the Annex.

Indeed, as you say, you could say, "No, we cannot do that yet because we need to
think about what we want to do with it first".  But on the other end, the
consensus doesn't limit usage of the Annex.  So maybe if you want to do more
thinking, maybe it shouldn't have been introduced in the first place.

**Dave Harding**: I think one of the reasons we don't enable features like that
in P2P Relay that might be used in future soft forks is because a miner who is
accepting those transactions might create invalid blocks after a soft fork.  So,
if we start using the Annex, we start requiring it follow a particular format
and somebody tries to jump a jpeg in there, it might violate that format.  And
if the miner hasn't upgraded their software during a soft fork, they're going to
create invalid blocks and they're going to lose a lot of money.  So it's bad for
miners to generally ignore the sort of standard policy that's reserved for soft
forks.  So, that's the reason it's not done in Bitcoin Core.

Now, if somebody is dumping a lot of money there, and the miner wants to enable
it on an ad hoc basis, yeah, maybe that makes sense.  But as a policy, we want
to have a policy that removes as many foot guns as possible, and not allowing or
not encouraging miners to create blocks that have transactions that might
violate future soft forks is one of the ways we remove those foot guns.

**Joost Jager**: But for future soft fork, wouldn't this limitation then not
apply just from a certain block height onwards?

**Dave Harding**: It would, but if the miner hasn't upgraded their software,
they're going to continue to accept and continue to build blocks that include
transactions that now violate the new rule.

**Joost Jager**: Yeah, well, it's not that soft forks happen every other month
or so that you just don't see it coming, right?

**Gloria Zhao**: Yeah, but the idea here is we want a soft fork to be smooth and
that not everybody has to update on the same day, or you could have just like 5%
of people like taking a few extra weeks or a few extra months or something and
they would still be fine.

**Joost Jager**: Okay.  I don't really understand then why blocks with an Annex
weren't made invalid initially; why was that Annex introduced if you cannot do
anything with it?  But maybe I don't have enough layer 1 knowledge to really
understand that.

**Gloria Zhao**: Yeah, so there's a lot of protocol development where it's like,
"Oh, we're going to leave 32 bits to define 32 versions and we're just defining
version 1, because we want to leave room to define 31 more versions".  And for
now, these versions don't have any meaning, but we're giving ourselves room to
change things in the future.

**Mark Erhardt**: The issue with making it invalid right now would mean that
anybody that is not upgraded at the time of the soft fork activating would get
forked off the chain when we start using it, right?  So, anyone that hasn't
upgraded in a while would just become cut off from updates from the network.
And that's why we generally like to go from everything is allowed to a
restriction in our soft forks, where anybody that has old software still can
follow along, because the majority of the hashrate is just enforcing more rules
now.  While if we first disallow something and then allow it going forth, the
people that continue to enforce the disallowance, will just be forked off.

**Joost Jager**: Yeah, okay, I get that.  But still, you could say that the idea
that Annex should first be further defined before it can be used, it is
subjective in a way, right?  Not every Bitcoin user necessarily needs to agree
with that and not every miner needs to agree with that.

**Mark Erhardt**: That is generally correct, yes.  If a bunch of users and
miners started using the Annex, we would probably have to start making our rules
keep that in mind.  So, it would restrict the design space for future updates if
it gets much use now.

**Joost Jager**: Yeah.  So it does feel a little bit like a ticking timer,
because maybe it's just a matter of time for this to happen.  And hopefully
before that happens, the desired structure for the Annex is in place already.

**Mark Erhardt**: I would very much hope that anybody that starts using hooks
for future design upgrades would start talking about that on the mailing list
and with other protocol developers before making pushes on the network, with
using these deliberately left for future update things.  So, I think putting it
out there as, "Oh, this is free to use", is sort of a detriment for all of us in
the future.

**Mike Schmidt**: Joost, thank you for joining us.  You're welcome to stay on,
you may have some opinions on some of the other items we discussed in that
newsletter.  But thank you for joining us.

**Joost Jager**: All right, no problem.

_Waiting for confirmation #3: Bidding for block space_

**Mike Schmidt**: Next segment in the newsletter is related to our series on
transaction relay and mempool.  This is part three.  We spoke about in part one
about why we have a mempool at all; and in part two, we talked about how
transaction fees are an incentive mechanism for miners to include your
transaction in a block that is limited in terms of the amount of block space.
And now, in part three here, we're outlining strategies to get the most for
those transaction fees.  Murch, I know you're one of the authors of this week's
series.  How do you think about bidding for block space?

**Mark Erhardt**: Yeah, so as we know, the demand for block space has been a
little different in the past few months.  And I think that every time we see
these peaks of block space demand and the feerates shoot through the roof
accordingly, it drives people to adopt efficiency improvements that have been
outlined and available for a while.  So for example, in the 2017 run-up, we saw
that a lot of people started using wrapped segwit very quickly, and then later
also started transitioning to native segwit because the fees were so high, and
they just started moving to using a new address standard so at least the future
UTXOs that they were receiving would be cheaper to spend.

So, in our column this week, we outline a little bit the mechanics of building
transactions, which parts of the transactions we have the most leverage to
influence when we build our own transactions.  We also point out how using more
modern output types will save you money, especially when block space demand is
high, but generally the more modern output types take less block space, so
you'll pay less fees for them.  And we especially also talk about reprioritizing
of transactions.  So, there are two main mechanisms to do so with CPFP and RBF,
and we go a little bit into the trade-offs.  So that's just roughly the
overview.  I think I can dive into more details if you think that's useful.

**Mike Schmidt**: Yeah, I think it would be useful.  And also I want to make
sure that Gloria can chime in as well.  I know she was a co-author of this
segment.  Gloria, any thoughts so far?

**Gloria Zhao**: Well, Murch is the coin selection guy, so I think he's the
perfect person to talk about this.

**Mark Erhardt**: All right, let me go a little more into detail.  So, when we
build transactions, the header bytes of the transaction are basically always
required.  So they just change a little bit whether you're building a non-segwit
transaction or a segwit transaction.  And then the input counters and output
counters will get slightly bigger if you exceed the magical border of 252 inputs
or outputs, then you need a few more bytes on the input counter or output
counter.  But other than that, you can think of the transaction header bytes on
a transaction to be a fixed overhead that everyone that wants to build a
transaction has to pay.

Regarding the outputs, generally there are payload.  We want to make a payment
or multiple payments, so we know already which scriptPubKeys we need to pay, and
we know already what amounts we want to assign to them.  We can pick, of course,
what output type we use for our own change output, and we can try to avoid a
change output altogether if we pick our inputs in a smart way.  But generally,
the outputs are also very inflexible because those are the things that we aim to
create, and thus they're predetermined by the payments we want to make.

So finally, the inputs are actually where we have a lot of room for flexibility.
With the inputs, of course, we want to be thrifty, especially when the feerates
are high, we want to minimize the weight of the input set.  We can do that, for
example, by using modern output types.  If we use a P2TR input, that will cost
less than half in block weight than, for example, a non-segwit P2PKH input.  And
if we then are sensitive to the feerate and how we approach coin selection, we
would for example use as few as possible inputs at high feerates and as lightest
inputs as we can.  While at low feerates, we might want to be looking ahead and
say, if we have a super-fragmented wallet already use a few more inputs and the
heavier inputs like the old, formatted output types, we would want to prefer
using those at low feerates because we can then spend the more costly and higher
weight inputs and consolidate them into bigger chunks of modern output types to
save funds in the future when the feerates get high.

You could think that you would want to optimize on every single transaction to
build the smallest input set, but even back in 2016 when I wrote my master
thesis on coin selection, we saw that service providers and wallets that use
this strategy would just very brutally fragment their UTXO pool and set
themselves up for situations where later, when they wanted to create
transactions, especially at high feerates, they would suddenly have no option
other than picking a huge input set with dozens of inputs and pay a huge fee.
Especially when you have ground down all of your inputs to small pieces, and you
then want to make a big payment, you just have to include a bunch of smaller
pieces, where most of it just goes towards the fees of paying for that input,
and there's little benefit to actually funding the transaction, but you have no
other funds, and that's what you need to do.  So you want to sort of find a
middle path where you are very thrifty when the feerates are high, but then when
the feerates are low, you're looking ahead and already cleaning house a little
bit.

The other thing is, of course, I think that especially with the huge adoption of
P2TR now, I hope that more wallets are going to be able to send to P2TR outputs
and also use them for inputs.  I think for a multisig, there is the biggest
savings, obviously, because even with modern output types, you still have the
actual 2-of-3 multisig, for example, written out in an output and input, and it
takes more block space to do so.  But if you know that two keys are more often
used to make the spend, you can immediately make that your MuSig keypath spend,
and then have the same footprint as a single-sig.

So, I'm pretty happy to hear that, for example, services like BitGo already have
onchain support for MuSig and can, with their 2-of-3 multisig setup, make
payments that look like single-sig onchain.  And they'll essentially, even if
their user switches over from P2WSH, will save something like 40%, 43%, I think,
on each input at the same cost for the outputs.  So I would just say you have to
have both a long-term perspective in your UTXO use and a short-term perspective.
You want to switch over to more modern output types if you want to save money.

Then finally, the game of getting confirmed in the first place means that your
transaction has to bubble up to the top of the mempool.  Miners generally
include everything they see in the mempool from the top one block into their
block templates, and when they succeed, you get your confirmation.  So at some
point, your transaction has to be among the first block of transactions waiting.
But you basically have two strategies getting there.  One is, you just overpay
in the first shot, and then even if there's a slow block, you're pretty sure
that you get confirmed quickly.  The other way is to start with a conservative
bid and then to bump up the priority of your transaction if it takes longer than
you want.

For those, we have two mechanisms.  One is the sender or the receiver, anybody
that gets paid by a transaction can do a CPFP transaction.  And this is nice
because the txid of the original transaction doesn't get changed, it's open to
the receiver and it's fairly simple to implement, a lot of wallets have support
for it.  But it's kind of bad because you're in a situation where your original
transaction didn't get through because there was too much block space demand and
other people are outbidding you.  And now you have to add more transaction data
to this package in order to get the transaction through at a high feerate.  So,
you add a second transaction that you also have to pay for at the high feerate,
and you're basically already in a high-feerate scenario, right?

So more efficiently generally is, if you can, to use RBF to completely replace
the original transaction and make a conflict.  So, your replacement transaction
has to use at least one of the same inputs.  Generally, you would include the
same payments, maybe even batch two or three transactions together to combine
the payments into a single transaction, and then only pay for the payload once,
only have a small set of inputs to create all of those transaction outputs in
one transaction, and you outbid your own original transactions with a higher
feerate and a higher absolute fee in order to replace them.  I wish that more
wallets would generally build their transactions signaling replaceability and
have options to bump transactions directly, so users can make conservative
estimates first and then bump up as needed.

I think finally, what we also mentioned in the article was, of course,
especially if you have a high-volume wallet, you can build your transactions in
that manner in the first place by batching payments, multiple payments, into a
single transaction, because then you only pay this transaction overhead for the
header transactions once, and you might be able to get away with a single input
for many payments and a single change output for many payments, because every
time that you create a change output, of course, you incur a future cost as well
where you have to spend that UTXO later, too.

So if you split up many payments into separate transactions, every time you pay
for the transaction header and almost every time you'll pay for the change
output and have to spend the change output later, but if you make a batch
payment, you only get that, you share that overhead cost across all payments.
Yeah, sorry, I've been talking a lot.  I think I've covered most of what we
wrote in our article.  Did I miss anything; any questions, comments?

**Mike Schmidt**: My comment would be, really great job of convincing a ton of
Bitcoin tech and best practices that Optech has been recommending over the years
into one explanation, including batching, consolidation, selection of inputs,
using modern output types and some of the new tech like MuSig, all into one
verbal explanation, but also the write-up, so applause for you for that.
Gloria, anything to add before we move along?

**Gloria Zhao**: Yeah, great stuff.  Next week is on fee estimation, so feel
free to tweet any questions you have about fee estimation, we'll try to answer
them.

**Mike Schmidt**: Next section from the newsletter is Q&A from the Bitcoin Stack
Exchange.  And so, every month we take an opportunity to pick out some of the
most interesting questions and answers from the Stack Exchange and surface those
in the newsletter.  We have five for this week.

_Testing pruning logic with bitcoind_

The first one is testing pruning logic with bitcoind.  And the person asking
this question is attempting to do some testing around pruning and is wondering
essentially the best way to do that.  And conveniently, Lightlike points out the
debug-only, and I think the hidden option, fastprune configuration option that
uses smaller block files and a smaller minimum prune type specifically for
testing the pruning logic.  So, interesting configuration option that I hadn't
seen before that I thought might be interesting for folks.

_What's the governing motivation for the descendent size limit?_

Next question is a question that Dave asked, which is governing motivation for
the descendant size limit, and Suhas responded.  And Dave, maybe since you asked
the question and sort of had an angle here, maybe do you feel comfortable sort
of summarizing an answer here?

**Dave Harding**: Well, just the question was, I'm actually doing an update on
the book, Mastering Bitcoin, and one of the things we wanted to add to the new
edition of the book is stuff about CPFP fee bumping.  And to do that, I also
wanted to add a section about transaction pinning.  And so, I was looking at the
rules that end up with us having transaction pinning problems, and I was trying
to figure out why exactly we have these rules.  I'm sure it's documented
somewhere, but actually Suhas replied with some of the mailing list discussion
where it is documented.  But I was just sitting there trying to puzzle this out
in my head, and I said, "Hey, why not ask the question?" and I got an answer
from possibly the best person ever, especially with this subject.

So Suhas' answer was, like you summarized, that we have two algorithms that are
running simultaneously in Bitcoin, or not simultaneously, but two reasons that
we need to look at the amount of transactions that are related in the mempool at
the same time.  And the first one of those is pretty easy to understand.  It's
for helping miners find the best set of transactions to mine in a reasonable
amount of time.  And I think we discussed that quite a lot on, not we, but
Gloria and Murch on last week's Recap podcast and in last week's entry in the
mempool session.  So anyone who's interested, go look at that.

The other reason is eviction.  So, since I think Bitcoin 0.10, we've had a
constant-sized mempool or maximum-sized mempool.  So the mempool can get to be
300 MB in size, which is about 150 MB of transactions, which in olden times used
to be about one day worth of transactions, and we don't like to get any bigger
than that, so the computer running our node doesn't run out of memory.  Back in
the day, it could run out of memory, which was bad.  But if you're going to do
that, that means you've got to kick transactions out of the mempool every once
in a while.

So, Suhas explains that we have these two algorithms, and they're kind of the
inverse of each other.  We have an algorithm that tries to figure out which set
of related transactions will provide us the best fee; and then the reverse
algorithm, which says which ones provide us the lowest fee, which ones are not
worth keeping in the mempool, so we can kick those out and keep the most
profitable ones in the mempool.  And to do that in a reasonable amount of time,
we have to limit the number of operations.

As Suhas explains, those algorithms can be quadratic in scaling.  So, every time
you double the amount of transactions they consider, you quadruple the amount of
work.  So that's his answer, is that 25 is essentially more than 25.  But the
rules for 25 are reasonable limits within that quadratic scaling.  And if that
isn't a good answer, yeah, Gloria can maybe give more information if anybody's
curious.

**Mike Schmidt**: Anything to piggyback there, Gloria?

**Gloria Zhao**: Oh, no, I was just laughing because I go through the same thing
every time when someone asks me what the descendent limit is, and I say it's 25.
Well, it's 26 sometimes if you have carve-out, but 25; that's why I was
laughing.

_How does it contribute to the Bitcoin network when I run a node with a bigger than default mempool?_

**Mike Schmidt**: Next question from the Stack Exchange is around running a
bigger than default mempool.  Folks may see that the default mempool has
resulted in a full mempool lately with a lot of unconfirmed transactions out
there, and maybe an initial naïve response may be, "Hey, I'm going to help the
network.  I'm going to increase the size of my mempool to be larger than the
default so that I can accommodate all of these transactions that are
outstanding".  Murch, you asked and answered this question.  Why might that not
be a good idea?

**Mark Erhardt**: Yeah, I don't want to say that it's not a good idea in that
sense, but I think that people misunderstand when they think that it will
benefit the network.  So generally, our mempools are meant to make transactions
available to anyone that wants to be a miner, and we want to make sure that
especially all the juiciest transactions get to everyone.  However, we have a
bunch of other effects there that the mempool benefits with as well.

So for example, we will cache all the validation of transactions that we have in
our mempools and we will relay transactions only when we see them for the first
time.  So, every time a node learns about a new transaction, it will offer it to
its peers.  But if we have very different sizes in our mempools, people will
keep around transactions longer than everyone else.  So if they get rebroadcast,
they will, for example, not relay them again because they still have them,
right?  So if someone offers me a transaction to my mempool that I already have,
I will not request it for them, and I will also not announce it to all my peers
again because I already have it.

On the other hand, if people mine blocks with transactions that nobody knows
about anymore because everybody else dropped them from their mempools, then
these blocks will propagate more slowly because we use a scheme called compact
block relay, where we essentially only send the list of ingredients to a block,
and everybody just rebuilds the block from their mempools if they have all the
ingredients.  But if transactions are missing, we will have extra round trips
with asking back to the peer that sent us the block for those transactions.  So
we want our mempools to be as homogenous as possible.  While making available
all the best transactions to everyone, everybody should also drop the same
things and enable people that currently don't signal replaceability yet to make
replacements, and for those replacements to propagate smoothly.  Or, if stuff
needs to be rebroadcast because it fell out of most mempools, that it propagates
smoothly.

So it's sort of a misunderstanding when people think that running a bigger
mempool will benefit people.  They often think that their node will offer the
same transactions again to other peers when they become relevant, but that's not
the case.  We do not ever rebroadcast transactions another time unless we learn
about them afresh, or of course, if we include them into our block template,
become nominated to be the author of the block by winning the distributed
lottery, and then, of course, packaging them into our block, then we would sort
of rebroadcast them as part of the block.  Gloria, I probably missed something.
Do you have comments?

**Gloria Zhao**: Not particularly.  I think maybe if you're a miner and you're
interested in remembering transactions for longer, you wouldn't want to run your
getblocktemplate on a huge mempool node.  But yeah, I fully agree.  The biggest
thing was I think people thinking that they were going to rebroadcast the
transactions that they were still keeping, and therefore that running a bigger
one was better, but in fact you become a black hole when they do rebroadcast
because you won't redownload it and so you won't forward it again.  So yeah,
having a bigger mempool than average is not helping the network in any way.
Just feel free to just keep it 300 MB.

_What is the maximum number of inputs/outputs a transaction can have?_

**Mike Schmidt**: Next question from the Stack Exchange is, what is the maximum
number of inputs or outputs that a transaction can have?  And this is actually a
question that was asked in 2015 and the top answer currently is from Gavin
Andresen.  And Murch, you provided an updated answer, which includes different
calculations of inputs and outputs based on the segwit and taproot soft forks
being activated.  Folks can jump into your answer for the details there about
what would be the max number of inputs and what would be the max number of
outputs.  But I'm curious, how did you even come across this old question?

**Mark Erhardt**: Somebody asked on Twitter, because they were doing a podcast
or listening to a podcast where that question came up.  And I saw that we had
that question already on Stack Exchange, but since of course 2015 is a long time
ago and we've had since activated the segwit soft fork and the taproot soft
fork, there's a lot of new commonly used output types on the network that are
more block space efficient.

So, while the limits are backwards compatible, or I should say forwards
compatible to old nodes, that don't understand segwit, we are actually able to
have a lot more inputs and outputs on every transaction now, even though they
are still within the same or forward compatible standard limits.  So also the
original answer did not include actual numbers, so I calculated that if we limit
ourselves to commonly used payment types, so nothing fancy, like OP_TRUE P2WSH
inputs or OP_RETURN outputs or stuff like that, we want to have a standard
transaction that only uses either single-sig or multi-sig constructions, then we
would be able to have a transaction with slightly more than 3,000 P2WPKH
outputs, and we could fashion a transaction with a little more than 1,700
inputs.

I think a lot of people might be surprised how many inputs and outputs we can
have on transactions, and that's the context in which I think that is
interesting.  I don't think that we'll see a lot of transactions that actually
approach those limits.

**Mike Schmidt**: You just jinxed it!

_Can 2-of-3 multisig funds be recovered without one of the xpubs?_

Next question from the Stack Exchange is, can the funds that are locked in a
2-of-3 multisig be recovered without one of the xpubs?  And folks may be
familiar, if you use some tooling around software like Specter or Sparrow, that
part of the backup process is making sure that you have these output scripts in
addition to backing up the keys themselves, because both are required to spend
in the case of using, I guess, modern or common multisig outputs, which would
not include the bare multisig output.

Murch, I think you've answered almost all of the questions in the Stack Exchange
this week.  You recommended using an output script descriptor to back up the
condition script.  And you also noted, I think, that if there had been a
previous spend using that same set of script conditions, that you could actually
recover the funds, but otherwise that you would need a backup of all of the pub
keys; is that right?

**Mark Erhardt**: Yes, but I think that the misunderstanding or concern that is
the greatest in the context of multisig is, a lot of people misunderstand that
when, for example, you have a 2-of-3 multisig setup, you only need two of the
public keys and two of the private keys, or rather just two of the private keys
in order to spend your funds.  But the problem with that is, we use hash-based
locks on our outputs that you have to prove that you know the original input
script that the output creator had in mind, or rather the recipient had in mind,
when they requested the payment to that output.  So the thing is, if you only
have two private keys but don't know how the input script was constructed for
which you need all three public keys, you will be unable to spend your funds.

So, a multisig backup necessarily also has to keep all public keys.  So, the
optimal way of backing up a multisig, if you want to have it in distributed
locations, would be, in my opinion, to have a backup of the construction of the
input script that includes all of the necessary public keys, and then one
private key with each of the backups.  So, if you retain two of the backup
shares, I should say, you will have all of the necessary private keys, but you
also know how to construct the input script.  So, yeah, if you ever want to roll
your own multi-sig, I think that got a lot easier now that we have output script
descriptors, because the output script descriptor will include that information.
And just be sure that you keep an output script descriptor with your private key
backups, if you do multisig.

**Mike Schmidt**: Next section of the newsletter is Release and release
candidates.

_Bitcoin Core 25.0_

We have one this week, which we touched on briefly last week, which is Bitcoin
Core 25.0, which is a major release for Bitcoin Core.  Gloria, I think we
touched on last week, you mentioned the example of addressing the issue of a
Raspberry Pi becoming a fire hazard, and I think that was related to -- is that
related to the blocks-only configuration memory fix, or was that one of the
different fix unrelated to that?

**Mark Erhardt**: Oh, I don't know, Gloria seems to have stepped away maybe.
Maybe I can take this one.  So, I think that we saw an unprecedented amount of
transactions in the network recently and the transaction submissions were very
high.  And we found that there were a few performance inefficiencies on nodes,
and all three of the recent releases, the two-point releases, 23.2 and 24.1, as
well as the new major release, 25.0, include a few performance improvements
regarding just huge transaction loads.  I think that's what we were talking
about last week as well.

**Mike Schmidt**: Is there anything else that you'd like to highlight from the
release, Murch?

**Mark Erhardt**: Sorry, I don't have it in front of me right now.  I was trying
to pull it up, but I think that the main point is that miniscript support is
moving forward.  You can now assign miniscript transactions that use P2WSH-based
miniscripts.  I think in almost all cases, there's like a small, little thing
that might not work yet, but some people are using that already to make
more complex output script descriptors.  For example, look at the recent
announcement of Liana wallet from Miami, which I think sounds very cool if you
want to have built-in inheritance planning for all of your outputs while you're
using your wallet.  It's an open-source project, so I'm not getting paid to
shill this.

I think the other interesting thing was, there is a new use case for the compact
client-side block filters.  So if you have an index for those, you may also know
them as the LND implementation Neutrino nodes, you use these, you can now more
quickly scan for wallets that you import by looking at your compact client-side
block filters.  You can think of compact client-side block filters as basically
an index of what is included in every block.  So, by just having this table of
content, you can way more easily skim what blocks you have to look at in detail
in order to import a wallet, and that's implemented in this release now.  I
think that's the biggest, coolest new stuff.

**Mike Schmidt**: We'll move on to the Notable code and documentation changes
section of the newsletter, and at this point, I'll solicit anybody who has a
question or comment.  You can raise your hand and request speaker access and
we'll try to get to your comment or question before we wrap up the newsletter.

_Bitcoin Core #27469_

First PR this week is Bitcoin Core #27469, speeding up Initial Block Download
(IBD) when using a wallet.  And it sounds like there is a performance
optimization that was implemented with this PR, such that if you are using a
wallet that has a known birthdate, meaning there were no transactions applicable
to that wallet before that birthdate, that you can skip some scanning on blocks
before that birthdate.  Obviously, that would free up some resources to be doing
other things and not checking blocks that would clearly not have any information
about your wallet.  Murch, I had a question for you on this one.  Does this
impact re-scanning or is this just during IBD, if you're familiar?

**Mark Erhardt**: Yeah, I was just scrolling through that a little bit.  So, of
course, it specifies further down in the comments of that PR that it actually is
only during IBD.  So, the idea here is if you have a wallet loaded, then you not
only process the block in order to build your chain state and your transaction
index and what other indexes you have and catching up to the chain tip, you will
also look at every block's content to see whether it's relevant to your wallet.

However, with our wallet backups, or rather the wallet.dat file contains a
birthdate.  So if it, for example, specifies that it was created only in 2020,
there's absolutely no need to look at all the transactions before 2020, because
we would never have created an address before that and never received any funds
to the wallet if it's only been created in 2020.  So, my understanding from a
very rudimentary glance at it is, we are only skipping this extra lookup for
wallet context during the IBD up to the time that our wallet actually was
created because we don't have to look for stuff that we could have never
received anything in.

_Bitcoin Core #27626_

**Mike Schmidt**: Next PR is Bitcoin Core #27626, parallel compact block
downloads.  And it sounds like that when, if I'm running a node and I receive
notification of a new block in compact block format from a peer, I will then
attempt to download any transactions that I need that I don't have for that
<!-- skip-duplicate-words-test -->block from that same peer, but there's potential that that peer is slow for
whatever reason and not able to quickly reply.  So in that case, we can use
another node that has also already obtained the block and is more quickly able
to give us the transactions that we're missing.  Murch, did I get that right; do
you have anything to add?

**Mark Erhardt**: Yeah, so basically the idea is this.  When we use compact
block relay, we're only transferring the table of contents of the block and the
recipient will rebuild the block from the ingredients that they already have in
the mempool.  We touched upon this earlier today already.  And if you are
missing transactions, you still need to get those transactions.  So basically,
you will have a short txid that tells you, "Now include this transaction".  And
then you're like, "Wait, I don't have that in my mempool.  Hey, no data
announced a block to me, give me that transaction".

Now if, for example, a block was received by one node first and they push it out
to all of their 125 peers, "Hey, I have this new block", and everybody then asks
for all of the missing transactions because, I don't know, somebody put some
huge inscription into that block, then they might be bandwidth constrained at
that point to try to provide that data to all of their 125 peers; well, 124,
because they must have gotten the block from somewhere, right, but you know what
I mean.  So, this new patch allows us to -- then the second node that maybe was
the first one that got it from the first announcer, that also then announced
that they now have the block, they basically announced with that too that they
have all the transactions that are in that block.

So now, instead of just waiting for the first node that announced the block to
us and whose block header and compact block we accepted, to also give us the
transactions, we're going to go sideways and ask other nodes that also signaled
to us that they have the complete block, to provide us the missing information.
This should help, especially with block relay, when there's a lot of
transactions that are not readily available in everyone's mempools, to propagate
faster through the network.

_Bitcoin Core #25796_

**Mike Schmidt**: Bitcoin Core #25796, adding a new descriptorprocesspsbt RPC.
Murch, can you explain why we need another processing of PSBT RPC, and how it
interplays with some of the other RPC commands related to PSBTs?

**Mark Erhardt**: All right, so PSBT stands for Partially Signed Bitcoin
Transactions.  We basically use that in the context of creating multi-user
transactions, so for example, coinjoins, or if you have multiple devices that
need to sign off on stuff, or if you want to use UTXOs from multiple wallets
that you own yourself, or if you're trying to sell an inscription by using PSBTs
as the market announcement.  So, PSBTs are super-useful in making our
transaction building easier for multiple parties together.

The way I understand descriptorprocesspsbt is, if you get a PSBT, you might need
to fill in some of the blanks because you might not know about an input yet, or
the wallet that created the PSBT might know what UTXOs they want to spend, but
not have the whole UTXO set to fill in all the blanks.  So, a node that has all
that information might be asked to backfill the PSBT to provide all the relevant
information.  And with descriptorprocesspsbt, we can now express the missing
data from descriptors.  I'm bungling this a little bit, but basically it
improves how we backfill the missing information and where we can look up that
information to also include output descriptors, I think.

_Eclair #2668_

**Mike Schmidt**: Next PR is from Eclair, Eclair #2668, which adds an upper
bound on the fees paid during a force close operation.  And the background here
is that it doesn't really make sense to pay more fees than the amount that we
may personally have at risk during a force close.  So Eclair now computes the
amount of funds that are at risk and compares that to some feerate estimates and
then acts accordingly.  So, you don't want to pay more in fees than you would be
reclaiming, so there's a fix to optimize for that and do some heuristics in the
calculation so you don't do that anymore.

**Mark Erhardt**: Right.  So, this would happen in the context, for example,
when you are participating in a multi-hub payment and you accept it to create a
remote HTLC, as in you lock in funds to forward the multi-hub payment.  But then
the feerates on the mempool are going up immensely.  And now, when the payment
times out because the recipient doesn't pull it in, they're offline or
something, we would have to go onchain in order to settle our channel in order
not to lose those funds locked up in the HTLC.  But of course, if we created the
HTLC at a way lower feerate environment, the HTLC itself might not be worth
enough to go onchain for and force close and pay all this extra fee to process
if the risk, say, like 10 satoshi payment, is actually not worth it.

So, my understanding is that instead of force closing, they would just let that
HTLC ride longer now.  But yeah, hopefully then also they wouldn't create new
HTLCs at that high feerate that are that low value, but they wouldn't also go
into force closing when there's too little value riding on it.

_Eclair #2666_

**Mike Schmidt**: Next PR is also from Eclair, Eclair #2666, relaxing the
reserve requirements on HTLC receiver, and this is a mitigation for the stuck
funds problem.  And so in Lightning, there's BOLT 2, which part of BOLT 2
includes a channel reserver requirement, and that's recommended in the spec to
be 1% of the channel total as reserve.  And the idea is that each side of the
channel would maintain that reserve so that there's some funds to lose if either
party were to try to broadcast an old, revoked commitment transaction.  So, if
you didn't have this reserve, then there would be no risk of loss of funds by
broadcasting older transactions.  And obviously, when the channel is initially
open, that reserve may not be met, but the protocol attempts to work towards
meeting that reserve.

The interplay between the reserve requirement and the stuck funds problem is a
bit unclear to me.  So, Murch, perhaps you can elaborate if you're familiar,
otherwise we can try to see if Dave is still on.

**Mark Erhardt**: I am not super-familiar, but Dave raised his hand.

**Dave Harding**: Yeah, so the issue here is that in a channel, you often get
the case where most of the funds have moved to one side of the channel.  So you
have Alice and Bob, they have a channel together, and just through the natural
course of operations, Bob now has 99% of the funds, and there's just 1% left for
Alice.  Now in the protocol, it's required that the receiver of the HTLC be
responsible for paying its fees.  But if Alice only has 1% left, now she can't
receive any money from Bob.  Even if Bob wants to send her money, he can't
because Alice is responsible for paying the fees.  But the channel reserve
requirement, that 1%, says that she has no money to spend.

However, this doesn't actually make sense in this particular case, because if
Bob tries to send money to Alice, he tries to push money, well if it succeeds,
she's going to have the funds to pay the fees, and if it fails, well there's no
fee required.  So, this just removes a requirement that's not actually a
mitigation for any threat in this particular case, and there's also a related PR
to update the specification for this and for some other things that can lead to
funds stuck problems.

**Mike Schmidt**: Thanks for jumping in there, Dave.

_BTCPay Server 97e7e_

Next change is to BTCPay Server and this is commit 97e7e, which begins setting
the BIP78 minfeerate parameter.  So BTCPay Server implements BIP78 in terms of
payjoin features, so you can actually do payjoin features if you're running
BTCPay server.  However, this parameter, this minfeerate was not being set, and
the way that payjoin works is there is some interactivity between sender and
receiver, who both contribute some inputs to the transaction.  And if the second
party contributes an input while not also increasing the fee amount to this
minfeerate parameter, you could result in a transaction whose fee is below the
sender's minimum feerate amount.

So, if you're not communicating this parameter during that interactivity, you
could run into scenarios like this.  So, we noted a bug report that actually
came from a guest of ours who's working on payjoin, who's Dan Gould.  He was on
with us last week and he opened up this bug which motivated the change to be
more compliant with the spec.  Murch?  Thumbs up, all right.

_BIPs #1446_

And then the last PR for this week is to the BIPs repository.  It is #1446,
making a small change in a number of additions to BIP340 on schnorr signatures.
And we note that these changes don't affect how BIP340 is involved in consensus
and signatures for taproot and tapscript, but that it loosens the restriction
that schnorr signatures sign a message that is exactly 32 bytes.  And I don't
know the origin of the motivation for this relaxation of the signed message not
needing to be 32 anymore.  Murch, are you familiar with the motivation of why we
don't need to sign exactly 32 bytes?  I believe there was some discussion about
some requirements on the implementations needing to hash something in order to
<!-- skip-duplicate-words-test -->get to those 32 bytes, and that that was potentially an onerous thing, then
being able to sign a message of any size was the result of that, which resulted
in this change.

**Mark Erhardt**: I am not familiar, and this seems like a complex topic that I
don't want to hazard getting into by just glancing at it too much.

**Mike Schmidt**: Dave, do you have thoughts on that particular topic?  Why was
this particular change made?

**Dave Harding**: The justification was just like you said, some programs might
find it onerous to do this.  You can implement, I think, but I believe you can,
I don't know…  I'm going to stick with Murch's claim, which is this is a complex
topic.  I'm not qualified to talk about it, so I probably shouldn't, sorry!

**Mike Schmidt**: Okay, well, if you're involved with schnorr signatures and Bit
340, you may want to look at the spec to see if there's some changes that affect
you, or optimizations that you could make as a result of change in the spec, but
Bitcoin unaffected.  I don't see any requests for speaker access or comments on
our Twitter thread.

**Mark Erhardt**: Maybe let me take a very tentative stab at it.  It seems to be
that if your message that you're trying to sign is already shorter than 32 bits,
it would increase what you're signing, and that doesn't necessarily make sense.
So, if you want to sign shorter messages, it might be better to directly sign
the original instead of hashing it and blowing it up to 32 bytes.  But this is,
again, just a very tentative read and, yeah, maybe we'll some of the authors'
brains meanwhile and get back to this if it's important.

**Mike Schmidt**: All right.  We are just at the two-hour mark, which makes this
one of the longest, if not the longest, podcast that we've done.  I thank you
all for joining us, I think we had a great discussion.  Thanks to my co-host,
Murch, as always; thanks to Gloria for joining us, Dave Harding for joining us,
Joost for joining us and Burak for joining us, and providing their insights on
their proposals and prototypes of things that they're working on.  And we'll see
you all next week for Newsletter #254.  Cheers.

**Gloria Zhao**: Thank you.

**Mark Erhardt**: Cheers.

{% include references.md %}
