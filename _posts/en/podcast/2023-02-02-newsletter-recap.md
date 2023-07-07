---
title: 'Bitcoin Optech Newsletter #236 Recap Podcast'
permalink: /en/podcast/2023/02/02/
reference: /en/newsletters/2023/02/01/
name: 2023-02-02-recap
slug: 2023-02-02-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Dan Gould and Bastien
Teinturier to discuss [Newsletter #236]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/72429902/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-5-21%2F5577af7c-38be-bc0f-c08b-e3af3215d130.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #236 Recap on
Twitter Spaces.  We'll do some introductions and then we'll just jump into the
newsletter.  I will post a few different tweets from the Optech account that are
relevant to this discussion so folks can follow along, but otherwise you can go
to bitcoinops.org and find the latest version of the newsletter, #236, which
we'll be going through today.  I'm Mike Schmidt, contributor at Optech and also
Executive Director at Brink where we fund Bitcoin open-source work.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs and contribute to
Bitcoin.

**Mike Schmidt**: T-bast?

**Bastien Teinturier**: Hi, I'm Bastien, I'm working on Lightning and especially
on Eclair and Phoenix.

**Mike Schmidt**: Excellent.  Dan, do you want to introduce yourself and give
some background on what you've been working on?  We'll jump into your news items
shortly, but maybe just a little bit of personal background, how you got here,
what kind of stuff you're doing.

**Dan Gould**: Sure.  I'm Dan, I work on the Bitcoin privacy problem.  Recently,
I'm focused on using payjoins to bring a base level of privacy to Bitcoin in
popular use, and I'm really excited to get to share the stage with Bastien,
Murch and Schmidty.  Thanks, guys.

**Mike Schmidt**: Yeah, thanks for joining us.  I think we can jump into your
proposal since it's the first item in the news section this week unless, Murch,
are there any announcements before we get started?

**Mark Erhardt**: No, not that I know.

_Serverless payjoin proposal_

**Mike Schmidt**: Okay, Dan.  Well, you had a post to the Bitcoin-Dev mailing
list in a proof of concept implementation around payjoin.  I think it's been a
bit since we discussed payjoins, if at all, in our Spaces, so maybe you can set
the stage a bit about what are payjoins and what's the current status of payjoin
adoption, and then you can get into your proposal a bit; does that sound fair?

**Dan Gould**: Yeah, that's great.  I think the newsletter did a great job of
summarizing what's going on.  When we start without payjoin, we have what I like
to call a naïve transaction, where you have some inputs and some outputs.
Inputs are outputs of previous transactions, and outputs are new outputs from
this transaction.

The way most people would create a Bitcoin transaction, or most software would
create a Bitcoin transaction, would mean that all of the inputs come from the
same party.  And because you can assume, or surveillance can assume, all the
inputs come from the same party, that can be used to track individuals or
entities and activities across time.  So, we can break this by using payjoin,
because payjoin allows both the person sending a transfer and the person
receiving a transfer to contribute to the same Bitcoin transaction with inputs,
breaking that first heuristic.

So, the payjoin concept, also known as pay to endpoint, where you pay to an
interactive server instead of a static Bitcoin address, was made popular around
2020, I want to say, and the first implementation of the BIP78 spec, which is
the most common spec, was done by Nicolas Dorier and Andrew Camilleri for
BTCPay.  So, people have thought of it mostly as a solution for merchants, even
though it really brings Bitcoin privacy, I think, to everyone, because in
addition to breaking this common input ownership heuristic, where all the inputs
of a transaction come from the same person, it's covert in that the transaction
doesn't look special when you make it or it doesn't have to, taking some
assumptions into account.  So, it makes all of the transactions that look like
they could be payjoins have a new interpretation where they might be
transactions where their inputs come from the same person or they might be
created by multiple participants.

This is all to say that adoption has been slow in my mind, in large part because
people think merchants are the ones who should enable payjoin.  You've needed to
have that public server open, so basically BTCPay Server is one of very few
pieces of software that allows people to receive this kind of transaction, and a
totally separate set of software is able to send the payjoins.  And I think
because software producers haven't been able to send and receive, they've been
reluctant to implement it.

So, the serverless payjoin spec, we're finally getting past the background here,
was to get rid of the requirement for you to run your own server endpoint,
replaced with leaning on a relay.  So, instead of running a secure server
endpoint where you know I'm talking to https://btcpayserver.com, you can use a
hub hosted at btcpayserver.com and the receiver can generate an ephemeral key, a
pre-shared key, in the URI that makes up the endpoint the sender pays to, which
they can encrypt their sender payload with and make sure the response from the
receiver is authenticated.  Because they do that, it's okay if there's a
middleman, it's okay if this payload gets relayed.  So, we can use something
called TURN to have the sender and receiver talk to each other directly, to have
their computers talk to each other directly.

I think there are a number of improvements we could still make, and I'm curious
to hear those, but that's the basic idea.  You have payjoin, which breaks the
common input ownership heuristic, brings privacy to everyone, even those who
don't necessarily payjoin themselves, and anyone who can connect to a relay
server can payjoin.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: All right.  Just wanted to jump in, maybe one more comment on
the background.  So, you mentioned how standard transactions allow users or
surveillance to assume that all inputs are owned by the same owner, and some of
our listeners might have heard of coinjoins before.  So, in a coinjoin
transaction, or generally a transaction with multiple creators, you usually have
a pattern in the outputs that makes it recognizable as being something
different.  The specialty, or the special thing about the payjoin here is, since
it's still predominantly a payment from one user to the other user, there's
still only two outputs, one to the recipient and a change output back to the
sender.  And by the recipient adding more inputs, the value is increased that
goes to the recipient, but the characteristic of the transaction still having
two outputs doesn't really change.

So, for a surveillant that is looking at the blockchain, it still looks like a
regular payment, indistinguishable from anything else, except that there might
be more inputs.  And now, some of the inputs are from one wallet and some of the
inputs are from the other wallet.  So, in a clustering approach where they
assume that all inputs to transactions are owned by the same entity, they will
mistakenly combine these two wallets now and think that it's only one entity
instead of two entities transacting, just to round off your explanation from
earlier.  So, my understanding is that your new proposal now just uses existing
BTCPay Servers as a coordination mechanism, but then communication is directly
between two wallets; is that right?

**Dan Gould**: The proposal doesn't explicitly say you're using a BTCPay Server
for coordination, but that is feasible, yeah.  Any sort of wallet developer
could run a relay that would let, like you said, any two wallets communicate and
do this.  And I see Michael listening.  This came really out of a need that he
brought up for BOLTs to payjoin, where if the receiver has to run all these
servers to get private withdrawal, or a withdrawal at least that has some
privacy between the BOLT exchange and the user, then it's just not going to be
widely adopted.

**Mike Schmidt**: T-bast, do you have a comment?

**Bastien Teinturier**: Yeah, thanks for explaining that, I think it's a really
cool proposal.  Who do you think will actually run the relay servers; wallet
vendors, potentially a few companies that work in Bitcoin; and how do you think
wallets will expose that?  Because you probably don't want wallet vendors to
force a lock-in to only use their relay server, especially if it becomes dust at
some point.  So you want the user to be able to pick from a list, I guess, but
how do you envision that?

**Dan Gould**: Yeah.  One awesome suggestion I got was to use a distributed hash
table (DHT), something like Holepunch or IPFS libp2p, because that relay network
is kind of already up and running, but it's a new concept for me so I'm not sure
if that's compatible with http or if there's a lot of networking required on top
of it.  When I chose to use TURN, that was because there was a basic library
support and you can Holepunch an http connection with someone relatively easily.
But the reason I came up with the proposal is because I think we already have
proprietary lock-in to some extent.  Samourai, I think it's called STONEWALL,
does something really similar to what I've proposed but without being specified.
It uses Tor and the two endpoints agree on a Tor relay to do exactly what the
TURN relay does in this proposal.  So, I think a DHT is probably the way to go,
but a list of authenticated relays from wallets might make more sense.

The other concern with open relay is that anyone could proxy their internet
traffic over it and people don't usually run public TURN relays because that's a
cost.  It's a tragedy of the commons where anyone can just come and relay
traffic over it.  It's hard to say this is only for payjoins, which is maybe
what using the public relay network that is a DHT could fix.

**Bastien Teinturier**: Yeah, I'd stay away from DHTs if I were you.  They have
a lot of issues and they don't really solve the issue because even with a DHT,
you need to have a first node, a first root node to connect to, to then create
with a DHT.  And these DHTs can always be kind of manipulated, so they create so
many issues that I'm not sure it would be the right choice here.  I think that
just a list of usual vendors that people are used to would make more sense, but
maybe I'm wrong.

**Dan Gould**: I think you could handle authentication that way.  Like, if your
wallet software has some authentication key that lets you use their servers,
that seems more sustainable to me than something that's totally open.  I'd
prefer everything be open, but I just don't know how that gets sustained.

**Mark Erhardt**: So generally, the coordination point that the user and the
merchant or counterparty use to create their initial connection, what do they
learn; they just see an IP address or a sender, or nothing at all?

**Dan Gould**: So, first the receiver would ask the relay to allocate them an
endpoint, so they would know the IP address of the relay and the relay would
know their IP address.  And then they would send that allocated endpoint on the
relay in the Bitcoin URI with the key information and the initial address to the
sender out of band.  The sender can then connect to the relay using that
information, and so the relay would learn their IP, but the sender and the
receiver would not necessarily know one another's IP addresses.  And the relay
could choose to run a hidden service so that if either the sender or the
receiver wanted more privacy, they could connect to them that way and not reveal
their IP address.

**Mark Erhardt**: Cool, thanks.

**Mike Schmidt**: Dan, I'm curious.  I know as of the publishing of this
newsletter and the authoring of it in the last few days, there hadn't been much
discussion yet on the mailing list.  How has feedback been either on the mailing
list or if folks have reached out to you out of band to provide feedback; maybe
you can comment on that so far?

**Dan Gould**: Yeah, I've gotten some feedback from reaching out directly to
people, and I think a lot of the problem with the Bitcoin privacy is people
don't see a way they can make money from it, so they don't have an incentive to
pursue it when it comes to actual wallets.  But I think a lot of the feedback
has been from like Nicolas Dorier who said, "You need to simplify and make sure
you use the http spec if you can", I think like Bastien was saying, "Don't rely
on DHTs, don't add complexity there".

The other thing has been to simplify the cryptography because we use noise to
model the encryption and authentication that's done for serverless payjoin, but
I think noise is still relatively unknown and people get overwhelmed by it.
Noise framework, for those who don't know, is a way to describe a cryptographic
protocol using a simple language for who has what keys when and what messages
get sent when.  And because everything is defined, you can do formal
verification on it.  And you can just pull one of these protocols off the shelf.

In the serverless payjoin case, that's NNpsk0, meaning neither the sender nor
the receiver have a long-term key and they pre-share a key in the first message.
But I think we could even get rid of the noise NNpsk0 if you just did a
Diffie-Hellman key exchange between the sender and the receiver.  So, you'd have
to wait until the key exchange was established and then the receiver could sign
the payload they send back to the sender, which is the payjoin PSBT, with the
key related to their initial address, to do authentication.  I'm a little off of
the original question, which was like, "How has feedback been?" but I think this
is where the feedback has concluded, to make it simpler.

So, if they could just use that Bitcoin address, the key related to that to make
a signature, then you could do the whole protocol without introducing the new
parameters in Simplify.  I'm not sure how to get the mailing list to get more
feedback, but I'm very interested in that because I want payjoin to be
implemented everywhere.  It's simple enough that it really should just work
everywhere.  And I just wrote a new thread today that goes into detail on how
this works, which is definitely worth checking out.

**Bastien Teinturier**: What would be interesting is that I think we could also
tunnel those over Lightning connections so that Lightning nodes could act as
relays for those.  And it could even be incentivized relays if you do that over
Hash Time Locked Contracts (HTLCs) or something like that.  Maybe there's
something that's interesting to explore there.

**Dan Gould**: Yeah, I think so.  I'm really thrilled to share the stage with
you because I see you working on the interactive tx protocol from time to time
too.  And I think of that as kind of next generation of payjoin.  Yeah, I
haven't really thought about incentivized relays on Lightning nodes.  Do you
have more of an idea of how that could work?

**Bastien Teinturier**: Oh, it's really just an idea right now.  I don't
know if there are issues, but we've talked about similar things for Vortex,
which is a project to make all your Lightning onchain interactions be coinjoins
and use interactive tx and Lightning nodes to do that, and they need a
coordinator, and we realized that in theory, every Lightning node could act as a
coordinator.  So, I'm thinking that maybe the same could apply here to run a
relay in your Lightning node so that the number of relays is big enough.  And
also, they are associated with reputation because a big node has a reputation,
has put some cost into running that big node.  So you know that when you are
using that node as a relay, you can expect a good quality of service.  And also
you can expect to have many other Lightning nodes available that would run the
same service.  So, it would fix the issue of not having any relays that you can
use.

How to incentivize them by paying them over Lightning, that's probably more
complicated, but that's something to potentially explore.  At least if you are
doing those Bitcoin transactions from a Lightning wallet, then it's probably
simple to do.  If you are doing it only from a pure Bitcoin onchain wallet, then
of course Lightning integration is going to be hard, but yeah, I'm not sure yet.
It's just a thought that may be worth exploring.

**Dan Gould**: The Lightning pairing sounds good.  Also because the receiver has
to sign and contribute inputs, and Lightning always has that reserve UTXO, at
least one, so you can always payjoin with that, and that seems like a good
match.

**Mark Erhardt**: I'm really excited to hear you two coming up with new ideas on
the fly.  I have a little bit of a curveball.  I've seen I think two or three
things that used signed messages tied to Bitcoin addresses lately.  Have any of
you got thoughts on BIP322, the generic signed message format; is that moving
forward in your mind?

**Bastien Teinturier**: To be honest, I haven't looked at it much.

**Dan Gould**: I haven't looked at it at all, so I'm opening it for the first
time, and this is probably the format to use.  What do you think of it, if
you've thought of it?

**Mark Erhardt**: It seems like a really good approach to make signing generally
described for the existing and maybe forthcoming output formats, but I think
that some people generally seem a little unhappy with message signing, or maybe
it's the money thing; how are you making money off of this?  Nobody really has
been pushing hard enough for it.  It's just been there, it looks pretty well
specced, but it's not finished.

**Mike Schmidt**: Anyone else have anything on this topic before we move along?

**Mark Erhardt**: I think we might be done.

**Mike Schmidt**: Well, I think there's a bit of kismet with our two guests
today, which is great to have some, as Murch says, on-the-fly brainstorming.
And hopefully this discussion that we're having here, as well as the fact that
this proposal is in the Optech Newsletter this week, hopefully, Dan, you can get
some additional feedback and exposure on this idea from a wider audience.  So,
thank you for coming on and describing this.  You're welcome to hang out and
comment on the rest of the newsletter, but yeah, thank you for joining us and
walking us through this.

**Dan Gould**: Thanks for having me, Mike.

_LN async proof of payment_

**Mike Schmidt**: All right.  Our second news item for this week harkens back to
last week's newsletter, where we had Val from Spiral on talking about async
proof of payment when using the LN, and we sort of started on the problem
statement.  It was her original mailing list post that started the discussion
and it was more of a solicitation for research into the issue.  I think by the
time that we had the Recap Twitter Spaces, AJ had already responded, but it was
fairly fresh.  We went through it just superficially, but in this newsletter we
cover it a little bit more in depth.  So, Bastien, I know that we did not bring
you on to discuss this item because you haven't taken the time to review AJ's
response.  Are you familiar with what Val was getting at with her solicitation
into this research problem, and what the problem is?

**Bastien Teinturier**: Yes, actually, I discussed it with Val and we discussed
it together before she sent the email.  This came out because we knew that for
asking payment, we had an issue, because ideally we want to make sure that the
senders and receivers have to come back online as few times as possible.  And
right now, we are losing some of the properties of Lightning payments, if we
want receivers to generally stay offline and senders to generally stay offline,
but we couldn't figure out how to fix it.  And we had a hint that potentially
with Point Time Locked Contracts (PTLCs), the design space gets bigger, so there
may be ways to fix it.  We are pretty sure that with HTLCs, there are no perfect
ways to fix that.

But we were actually too lazy to do the research ourselves, so that's why we
decided to send an email to a mailing list and see if someone came up with a
smart idea that we couldn't find ourselves.  So, I'm pretty happy to see that we
got a response that fast, and I still need to study it.  But the overall idea is
to be able to make sure that the recipient only has to come online when he
receives a payment, and doesn't have to come online a first time to create an
invoice before that invoice is actually paid.  So, this would be a much better
UX and would reduce the percentage of failed payments, so this would be very
desirable.  But the issue is, how do you ensure that the Lightning Service
Provider (LSP) cannot cheat and doesn't make the sender pay another invoice that
was already paid, doesn't steal funds, doesn't loan too much.  So, this is a can
of worms, and there are a lot of subtleties around that.  But it's good that we
have the beginning of a solution with AJ's proposal.

**Mike Schmidt**: Yeah, AJ mentioned two pieces of technology that we have
highlighted on the Optech Topics pages.  So, his solution involves PTLCs and
signature adapters.  Bastien, I know this is still an idea and work in progress,
but what are PTLCs; and how do we think of that versus an HTLC; and what can we
do with a PTLC that we can't do with an HTLC with regards to this proof of
payment?

**Bastien Teinturier**: Yeah, okay.  So right now, Lightning Payments use what
we call HTLCs, which means that the recipient has a preimage which is just 32
bytes.  From that, they just hash it with a SHA-256, which creates a hash of
that preimage, and the hash is what you find in the invoice.  And when you make
a payment, you actually pay to learn the preimage of that hash.  But the issue
with that is that the sender learns the preimage of the hash, but every node
that was inside the route also learns the preimage of the hash.  So, it's hard
after the fact to say that you were the payer for that invoice because anyone in
the route can claim the same thing.  So, we have a way to fix that with offers,
even with HTLCs, by adding a key that was generated by the payer that they can
use then to sign to show that they were the one paying the invoice.  But there's
still the issue that every node in the path learned that secret.

PTLCs are conceptually similar, but instead of using a preimage and the SHA-256
hash of it, they use a private key and an elliptic curve point.  And this is
interesting because hash functions destroy all potential arithmetic relations,
but elliptic curves are mathematical groups.  So, there are some operations that
you can do that are conserved with elliptic curve points.  So, that allows us to
make sure that we send payments where the intermediate nodes would not learn the
real secret, they would learn some kind of intermediate secret so that only the
sender learns the secret for an invoice.  And also, since we are now using
elliptic curves, there are potentially a lot of cool things we can do with
adaptor signatures, and it really opens up the design space for new ideas, for
things that are just not possible to do when we parse our data into a hash
function.

So, we don't know yet exactly all the things we can do, there's a lot of new
things we haven't explored, so that's why PTLCs are exciting because they will
unblock a new wave of innovation and what we can do with Lightning payments.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: I think that was the best explanation of PTLCs I've heard in
forever!  Yeah, I just wanted to say that mainly, but PTLCs of course come, or
have been in the works for quite a while.  They are based on the new schnorr
signature standard, the same that also is used in P2TR route.  And I think they
can even coexist in parallel to HTLCs, although if you make a PTLC payment, you
need to have it supported along every hop of the route.

**Mike Schmidt**: Bastien, as one of the prominent Lightning developers and
working on one of the Lightning implementations, what is your perspective on the
status of PTLCs and the feasibility of that coming to fruition and potential
timeframes; I know that's something that folks might be curious about?

**Bastien Teinturier**: It's going to be done in two weeks.  No, more seriously,
we know how to do it.  We currently have good designs on how to do a first
version of PTLCs that works and that doesn't require too many additional
trade-offs on the Lightning state machines.  So, we have that design somewhat
specced, but there are so many things that we are all working on right now that
it will take quite a while before we get there.  Also, one of the things we need
is that the first step before PTLCs is to change the funding outputs of
Lightning channels to use taproot and MuSig2, and for that we actually need
libsecp to ship a version, a final version, or at least a 1.0 version of MuSig2,
which is getting closer but is not available yet.  So, that is the first
dependency that we are blocked on.

Actually changing the funding of Lightning channels is really just the first
step and a simpler step than adding PTLCs, because even though PTLCs
conceptually use the same flow as HTLCs, they require changing all of our code
because the messages that we will exchange and the way we will do signatures
will change to use adaptor signatures.  So, it's really a huge change in every
implementation and in what we store in our DBs, so it's going to take a while to
be implemented, even though we know how to do it, but it's going to take a
while.  And for the Eclair side, we are first focusing on finishing dual
funding, liquidity ads and splicing, and offers as well, which are also very big
features.  So, we will only have dev time to work on PTLCs after that.  So I
would expect, yeah, maybe by the end of 2023, we would be starting to work on
it, but I don't know exactly when we'll be able to ship something.

**Mike Schmidt**: That's fair.  That's good insight to how you're thinking about
roadmaps in terms of features for Lightning.  Murch, I know the newsletter got
into some of the details of AJ's proposal.  I don't know that I or Bastian can
comment on some of the signature nonces and things like that.  Is that something
you feel comfortable commenting on, or should we defer listeners to read the
newsletter and jump into the original source material in AJ's posts?

**Mark Erhardt**: I think for those listeners that are interested in the exact
details, going to the post directly is probably better, otherwise we'll probably
get back to this when it gets implemented.  Generally I think the breakthrough
here is we sort of semi-trust the LSP to put out invoices in our name, but they
can't really do much shenanigans because the payment still has to be redeemed by
us; and we have now a way on the receiver side to distinguish whether an invoice
has been reused, in this case, via the nonce.  So, a few of the problems that
were stated in the writing prompt or in the research question seem to get
resolved with this proposal.  So, yeah, I think that it's still getting
evaluated by Val, and I guess t-bast, and other people that were asking for the
solution.  So, I'm sure it will be in one of the next few newsletters again when
the discussion progresses.

**Mike Schmidt**: Excellent, well I think we can wrap up that news item and move
on to Notable code and documentation changes, review some PRs; sound good?  All
right.

_Bitcoin Core #26471_

Well, the first one here for this week is Bitcoin Core #26471, which reduces the
default mempool capacity to 5 MB from 300 MB when a node operator is running in
-blocksonly mode.  Murch, why would I want such a small mempool capacity when
I'm running in -blocksonly mode?

**Mark Erhardt**: So, when you're running in -blocksonly mode, you're running
your node that does not participate in the transaction gossip.  It will only try
to receive the new blocks, so it will catch up to the chain state.  It will also
forward those blocks potentially to its peers, but it will not keep all the
unconfirmed transactions around.  So really, the mempool being the short-term
memory for unconfirmed transactions means that you don't really need it when
you're only participating in the block relay.  So, the author of this PR noticed
that essentially, -blocksonly nodes were still putting aside memory to keep a
mempool, but they didn't actually request any transactions from their peers.  So
instead, this memory is freed up and is, for example, available to be used
towards dbcache and improve the initial synchronization.  But yeah, we don't
really need a mempool if we don't keep unconfirmed transactions; that's the
point.

**Mike Schmidt**: Okay, so that makes sense.  And I guess the follow-up question
would be, if I'm in -blocksonly, then why do I need any memory allocated to the
mempool; what's the point of having the 5 MB versus something like zero?

**Mark Erhardt**: Well, you still can relay your own transactions.  So, when you
would try to send something, it would be bad for your privacy because if you're
in -blocksonly mode, but sending a transaction, then clearly either you have
white-listed the peer that you got it from, or it's your own.  But you could
theoretically send a transaction and then it has to go somewhere and it goes to
your mempool, so we do actually keep a mempool, it's just very, very small and
sparse.

The other situation where you might need a mempool is if there is a chain fork,
because two miners find a block at the same height, and you were on the block
that ended up being the stale chain tip, you would reorganize.  And when you
reorganize, actually transactions are put back into the mempool before the new
block is applied.  So in that case, you would not re-download everything from
peers, but you would stuff it into your mempool temporarily.  5 MB should be
enough for a block or two, so I think that might have been the motivation to
keep 5 MB.

**Mike Schmidt**: Okay, that makes sense, the most practical reason being you
need to submit your own transaction to the mempool, so that's why not to have
zero.  And then, the scenario you mentioned where there's a reorg and you don't
have to then re-download all those transactions, since the transactions from
that reorged block would be in your mempool to create a future block.  Okay,
that makes sense.

_Bitcoin Core #23395_

Next PR is another Bitcoin Core PR, #23395, adding a -shutdownnotify
configuration option to bitcoind, and what that allows is some customizability.
If you want to run some script or dump some data into a log file, or something
like that, when your bitcoind shuts down, you can provide the command that's to
be run during shutdown using this option.  And there's no guarantees that this
will run, especially during an unexpected shutdown, I guess, would be the
scenario where if this process is killed, then if bitcoind is killed, then you
wouldn't have the script run.  But during normal shutdown operations, that
command could be run to do log dumps or any such cleanup that you would need,
depending on what you're doing as a node operator.  Murch, any thoughts on
shutdown notify?

**Mark Erhardt**: Sounds useful!

_Eclair #2573_

_Eclair #2574_

**Mike Schmidt**: Great, and we have a trio of Eclair PRs here, and the author
of some of those is Bastien.  So, I think it would make sense for him to outline
exactly what's going on in these next three PRs.

**Bastien Teinturier**: Yeah, sure.  So, the first two are really small PRs
around keysend.  So, for people who don't know, keysend is a somewhat hacky way
of paying someone who didn't give you an invoice, by just generating the
preimage on the payer side.  It's a way to potentially accept donation without
having the receiver needing to generate anything.  But the issue with the
keysend is that it was not properly specified, so it was LND implemented it
first and then Core Lightning (CLN) reverse-engineered the code to kind of
figure out the specification.  And then at some point, the LDK team wrote a BLIP
to try to specify what the behavior that people relied on was.

But we didn't realize that even in that specification, there's nothing saying
that keysend doesn't work with another feature of Lightning that's called
payment secrets, and Eclair was actually using payment secrets with keysend.
And payment secrets is also something that we made mandatory in Eclair and is
mandatory in other implementations as well since a while, because it protects
against a specific fee-stealing attack from the next-to-last node in a route.
So, we didn't realize that Eclair's keysend support actually didn't work with
other implementations because of that, so we made a few changes to remove the
payment secrets from keysend usage and make it compatible again with LND and
CLN.  So, those are really small PRs.

**Mike Schmidt**: Bastien, I'm curious just as to how you think about the
standardization.  I think a lot of people are familiar with BOLTs, but maybe
less so with BLIPs.  So, how does one think about BOLTs versus BLIPs?

**Bastien Teinturier**: Okay, so BOLTs are Lightning features that everyone
should implement or that everyone needs to, at some point, implement for the
network to work correctly and not be fragmented too much, and for users to be
able to easily use Lightning.  Whereas, BLIPs are optional features that don't
need at all to be implemented by everyone, kind of plug-in features if you will,
but are still useful to document, to specify, so that if multiple
implementations or multiple wallets want to depend on it, they can be sure that
they are implementing the same thing and can easily be cross-compatible.  So
that's why we introduced BLIPs.

The issue with keysend is that soon after it was implemented, we realized that
it had a lot of limitations, and it's really not something we want to push
because it has a lot of cases where it just doesn't work well.  And Lightning
Labs' idea was to replace that by something they call AMP, and this one has a
pending PR on the BOLT, but I think it still has only been implemented by LND,
and it kind of conflicts with offers, and we're not sure if we need both, or if
both make sense, or if we want only one of them.  So, that's why keysend has
been semi-abandoned, but is still widely used, which makes it quite a weird
feature that is fully specified, widely used, but not very well tested across
implementations.

**Mark Erhardt**: So the payment secrets, it sounds to me like payment secrets
should be completely tangential to keysend, and especially useful in the context
of keysend.  How come that it actually breaks the other implementations when you
send one; it seems like the logical place for it to appear?

**Bastien Teinturier**: Really just because they have checks in their code where
they, on the sending side, they don't send a payment secret because payment
secrets are usually something that you find in the invoice.  So, when you're
making a keysend payment, you have no invoice, so you have to generate the
payment secret yourself.  Or what we did was reuse the preimage as a payment
secret, but the other implementations did not send one.  And I think it's okay,
because since there's no issues as long as you don't use keysend with multipath
payments (MPPs), but if you use keysend with MPPs, you have a ton of other
issues anyway, so we can ignore that.  So, that's why senders don't actually
need to use a payment secret.

But in Eclair, we had made it mandatory, so we rejected all payments that did
not contain a payment secret, even keysend payments, so that's what we relaxed.
It doesn't hurt to send a payment secret in a keysend payment, but we also
realized that LND and CLN actively reject, or maybe not both of them, but at
least one of them actively rejects the keysend payment if it contains a payment
secret, whereas they could just ignore it.  So, we decided to just drop all
payment secrets from anything that we do with keysend in Eclair so that we're
sure that we're compatible, even with older LND nodes out there.

**Mark Erhardt**: Cool, thanks for clarifying.

_Eclair #2540_

**Mike Schmidt**: I think that's good for the first two Eclair PRs; do you want
to jump into #2540?

**Bastien Teinturier**: Okay, yeah, this one is a big one.  So we started
working on splicing.  Splicing is a very interesting feature for Lightning
because right now, when you open a Lightning channel, it has a given capacity,
but you cannot increase nor decrease that capacity.  You have to close the
channel, which costs one onchain transaction, and then open another one.  And
the idea of splicing is to just combine these two.  Basically, once you have an
open channel, you can do a new transaction that will increase its capacity or
decrease its capacity, and this is done atomically, and this is done much more
efficiently than actually closing the channel and reopening it.  So, that's
something that's really desirable, but it's really a complex feature because
once you start doing that, once you have a splice transaction that has been
negotiated, has been published but is not confirmed yet, you actually have two
different versions of a channel's commitment with different capacities.  So, you
have some HTLCs that would be valid in both, but some HTLCs that would be valid
in only one of them, and you want to actually reject those because otherwise you
could have an issue if the one where it's not compatible confirms.

So, there is a big change in the data model in the state machine that you have
to implement for splicing to actually let the channel handle multiple virtual
channel states.  And that is quite a huge change, in that it potentially opens a
lot of issues when a channel can be force closed.  So, it requires a lot of
changes into the channel state machine, which is the most important part of a
Lightning implementation.  So, we started working on that early to make sure
that we find the right data model to be able to implement splicing and
potentially other features that look like splicing in the future, but it is
something that takes a while.

This first PR is us actually working on that data model.  We still have new
changes that we want to push, and what's important is that whenever we make a
change and whenever any Lightning implementation makes a change to its internal
channel data model, you have to migrate the data of existing channels, and
that's non-trivial and you still want all nodes to be able to easily upgrade.
So, you have to write those migrations and properly test them, so you want to
minimize them as much as possible; you don't want to have too many versions of
your data that you have to migrate.  So, we are trying to spend time finalizing
a good data model so that we only have to migrate the data once.

This creates quite a lot of headache, especially combined with zero-conf,
because combining splicing with zero-conf channels just opens a lot of potential
issues when an attacker may want to force close.  So, that's something that may
be interesting for other implementations when they start looking at splicing, is
that they want to think hard about the interactions with zero-confs, because
they are non-trivial and have quite a huge impact on your code, so make sure
that you correctly test all of these things.

**Mike Schmidt**: In the newsletter, we point to a draft pull request that would
add experimental splicing support.  Can you explain a bit about the process of
activating, if you will, splicing; is that something that all implementations
need in order for it to be production-ready, or are there just a couple
Lightning implementations that need to support splicing, or how does that look?

**Bastien Teinturier**: Ideally, we want all implementations to support it as
soon as possible, because it lets a node operator pay less onchain fees to
manage their liquidity, which is really important if you want to run a big LSP
or be an important node operator.  But in the short term, what we realized is
that we can actually start experimenting with Phoenix and start experimenting by
adding splicing to Phoenix.  Since Phoenix only connects to our node, it lets us
ship a first version of splicing before the spec is actually completely done.

There's also another simplification with using it in Phoenix is that all the
channels are private and some of the complexities of splicing also come from how
you deal with the announcements, how you deal with the fact that you are going
to tell the network that this channel, even though the output has been spent on
chain, has not been closed, it just has been changed, its capacity has been
changed, but you should still keep it in your graph for pathfinding.  So, by
starting and implementing it only for Phoenix and Eclair, this lets us start
with a simpler version of splicing, see how it behaves in the wild, find
potential issues in the specification, and the goal is to feed that back into
the specification process so that we eventually find a good splice specification
that everyone implements.

I know that CLN is also working on implementing splices, but they are directly
trying to implement the whole thing, and I don't think they have an easy way to
test it in the wild with mobile wallets like we do, so I think our
experimentation is going to be useful for everyone.  So, our goal is to be able
to ship this year a version of Phoenix that will have splicing built in, see
what issues arise, what things can be improved, feed that back into a
specification, and then converge on a final public specification and implement
that in both CLN, Eclair and hopefully LDK and LND.

**Mike Schmidt**: For folks that aren't familiar, the Phoenix wallet is a
Bitcoin wallet that's native Lightning support on mobile.  And so it sounds like
because that's powered by Eclair and because of the private unannounced
channels, that actually enables you to do some of the experimentation around
splicing, so that's pretty cool.  Murch, any thoughts on these Eclair PRs?

**Mark Erhardt**: No, man.  I don't really know much about Lightning, you know.

_LND #7231_

**Mike Schmidt**: Good thing we have the expert then!  All right, We can jump
into the next PR here from LND #7231.  I know earlier in the conversation, I
think we talked about BIP322 and message signing, and it looks like LND is doing
some message signing of its own.  So it looks like for P2PKH, the sign message
is compatible with the Bitcoin Core version of sign message, and then they've
also added capabilities to sign for native segwit as well as wrapped segwit
addresses; and then also have a little workaround for actually using P2TR
addresses and being able to sign and verify messages for all these different
address types.  Murch, have you dug into this?  Are they just going off and
implementing signed message outside of BIP322, or what are your thoughts on
what's going on here?

**Mark Erhardt**: Well, that was part of the prompt why I asked my question
earlier.  I think maybe because the work on BIP322 has lost momentum a little
bit, that now people are starting to come up with multiple schemes around
signing messages.  I know that there's others that have ways of signing messages
already.  Yeah, I'm not 100% sure how compatible this is with BIP322.  If they
use the same format as the old message signing, I think it is not.  So
eventually, maybe people need to have multiple ways of trying to interpret
message signatures, and that's kind of when there's five standards for
something, that's usually a little suboptimal.

**Mike Schmidt**: Obviously, there's some use cases and I think we discussed
this in the past about why you would need sign and verify message functionality.
I'm curious if there's a Lightning-specific use case which is causing LND to
move ahead with this; are you aware of the motivation for wanting to implement
this in LND?

**Mark Erhardt**: I mean, it's generally nice to be able to authenticate a
message as being signed by the recipient and not needing to establish another
identity.  So, if you can just have a signature that obviously is from the same
holder of the private key to an address as the address stated on an invoice,
that can be useful to just skip other ways of establishing identity and going
forth with, I don't know, another sender and receiver interaction, like moving
to a Lightning payment instead of an onchain payment or coordinating a payjoin,
things like that.  So, I see uses for signed messages, another big one of course
being proof of reserves.

But yeah, I guess it's big enough and complex enough that it would need some
push and maybe a group of people that are interested in getting it.  And I mean,
the BIP322 proposal is from 2018, I think, so five years old now; I guess it
just hasn't gotten the momentum.

_LDK #1878_

**Mike Schmidt**: Next two PRs from the newsletter are both from LDK project.
The first one is adding the ability to set a per-payment as opposed to global
min_final_cltv_expiry value.  Bastien, since we have you on here, I know LDK is
not a project that you're active on, but in terms of cltv_expiry, what is that
and what is the advantage of setting that on a per payment basis versus global?

**Bastien Teinturier**: Okay, so when you create an invoice, you specify how far
in the future you expect the HTLC you receive to be, because when you receive an
HTLC and you are the final node, if you want to fulfill it, you want to make
sure that the HTLC will not timeout too soon because otherwise, there's a
potential attack.  If, for example, you're sending me an HTLC that expires in
one block, I'm getting your HTLC, I have a preimage, so I'm giving you the
preimage.  But then, you are not acknowledging that message and you get the
preimage, so you can forward that back to the people who sent you the HTLC in
the first place, so that you get paid for that HTLC, but then you force close.
And since the HTLC expires in one block, maybe you're going to be able to also
claim that HTLC onchain from the commitment transaction.  So I gave you a
preimage, you got paid for it, but I did not get paid for it.

So, we want to avoid that by making sure that the HTLCs, when you are the final
recipient and you receive them, expire far away in the future, so that you're
sure that if there is a force close happening, you are going to be able to claim
that onchain.  So, you have to use something that's bigger than one block, so
you usually have a node setting that applies by default to all of your payments.
But for some payments, maybe for payments that are big enough, you want to use a
higher expiry because you have more funds at risk.  So, it makes sense to be
able to customize it if a user wants to customize it on a per-payment basis.
Does that make sense?

**Mike Schmidt**: Yeah, that does make sense.  And it's on a per-payment basis,
so I guess you gave the example of the size or the amount of the payment being a
factor, but I suppose also you could set these based on some other meatspace
trust that you may have in a counterparty; is that right as well?

**Bastien Teinturier**: Yeah, exactly.  Or if, for example, you are delivering a
physical good in exchange for that payment, you potentially need to check with
your warehouse and you potentially need more than ten minutes or even more than
an hour to check and make sure that you can claim that payment.  So in that
case, you really need to have an expiry that's far enough in the future to give
you time to do that.

**Mike Schmidt**: Murch, any comments?

**Mark Erhardt**: Nope.

_LDK #1860_

**Mike Schmidt**: All right.  One more LDK PR for this week, which is #1860,
adding support for channels using anchor outputs.  I guess, short but sweet
description.  T-bast is giving it 100%.  I guess I am not very up to date on
which Lightning libraries and implementations support what, but I think I was
under the impression that anchor outputs were already rolled out to all the
major libraries and implementations, but I guess not.  T-bast, can you comment
on that?

**Bastien Teinturier**: Yeah.  So actually, it's not as widely available as we'd
like.  It's been implemented and shipped in both LND and Eclair for I think more
than a year now, but with anchor outputs, there's actually a twist.  There are
two versions of anchor outputs and one of them is not safe and shouldn't be
used, but the issue is that the other one, the good one that you should use,
really requires you to be able to do some fee bumping with onchain wallet
inputs, and CLN still has not fit support for that version.  That means that
right now, only LND, Eclair and now LDK actually support the anchor outputs
version that we want people to use.

So, it's been taking a while to propagate across the network, so it's really
good to see that LDK has an initial version, and Rusty said that CLN should have
it by the next release or by the release after that.  So, even though it's
something that we've talked about for quite a long time, it's still not as
widely available as we'd like.  So, it's good to see any effort that goes into
that direction or making anchor outputs safer, because even when you have
initial support for anchor output, your fee bumping logic can potentially be far
from optimal and open to attacks, and the fee bumping logic that is associated
with anchor outputs is really annoying, really complex to get right, and really
hits the limit of what Bitcoin fee bumping can do.  So, there's still a lot of
work that can be done there to make it better.

**Mike Schmidt**: Thanks for that commentary, perfect.  Murch, any thoughts on
this final PR?  And if anybody wants to have a comment on that PR or anything
else we've talked about in this discussion, feel free to request speaker access
as well.

**Mark Erhardt**: Yeah, it's kind of funny to see how some topics are in
discussion for years and years, and then you actually realize that they're still
not deployed on the network.  And there's actually all these processes that go
on in the background, and eventually they lead to things that are landing in the
protocol, landing in the implementations.  Maybe in the last week or so, I've
seen a few comments on how we don't need to change anything about Bitcoin
anymore because it's already perfect.  And it's just funny to me, because
protocol development is sort of a two-decades thing.  You start with a very
small kernel that just works, and then you keep adding little features and over
a long time, you have to arrange all these things, these little parts, to fit
together to build up this big set of features to make everything work, and this
is just an example of that.

We know that there's issues around when the mempool gets, or block space gets
too sought-after with, with closing a lot of Lightning channels, and all these
discussions around mempool policies, anchor outputs, fee bumping, v3
transactions, ephemeral anchors, all these topics that we've had in the last few
months, they actually are all just mostly around just trying to resolve these
issues, and yet we don't even have the initial anchor outputs proposal landed in
all the implementation sets.  It's kind of an interesting divergence.

**Mike Schmidt**: We did actually have one question on Twitter, and it comes
from Johnny, who I think is in the Space now.  And his question is, "Is anyone
aware of other wallets which have already implemented some form of signed
message for P2TR addresses?"  So, I think that's referencing the PR from LND
that had the signed message for P2TR, even though it was a bit of a workaround.
Murch, are you aware of any other signed message?

**Mark Erhardt**: From the top of my head, no.

**Mike Schmidt**: Okay.  I don't see any other speaker requests at the moment,
so I think we could probably wrap up.  I want to thank t-bast and Dan for
joining us and discussing the news items this week.  Thank you guys for your
time.  I think it's great to get insights from the authors of these proposals
and authors of the PRs to describe the PRs, so it's super-valuable to have you
guys on.  Thank you for your time.  Oh, we do have one speaker request here,
let's see.  Sunfarms is back.  Sunfarms, did you have a question?

**Sunfarms**: Yeah.

**Mike Schmidt**: Go ahead.

**Sunfarms**: Yeah, thank you for the opportunity.  So, I'm still new to
Bitcoin, not really, but I have a question, I have a challenge.  I'm trying to
set up a Lightning node.  I don't know if this is a good forum to just ask my
question.  It's on Lightning, the Lightning side.

**Mike Schmidt**: Give it a shot.

**Sunfarms**: Okay, I've been able to successfully set up my Lightning or CLN, I
use CLN, and I want to -- okay, my first question is this.  I noticed on Bitcoin
v22, that's version 22, you can actually perform dumpprivkey, right?  When you
do dumpprivkey, you can see the private key of an address of a Bitcoin address.
But on higher versions, like v23, that function was removed.  So my question is,
how else can one get the private key of an address if that function has been
removed on v23?  Because I had to install v23 on this, because of I was unable
to get the private key of some addresses that I created on my own node, I had to
uninstall this.  Yeah, that's my question, first question.

**Mark Erhardt**: Yeah, I think from the style of question, that might be a
better fit for a Bitcoin Stack Exchange.  In this particular case, yes, the
dumpprivkey was removed and you can now dump a descriptor, but not single keys
anymore for the new styles of wallets.  I think in 23.0, wallets generally start
creating descriptive wallets instead of old-style wallets, so that's the issue
you are bumping in.  There are very few reasons why you would ever want to
dumpprivkey directly.  So yeah, anyway, I think maybe write us a question on
Bitcoin Stack Exchange, I'm sure somebody will pick it up.

**Mike Schmidt**: All right, well thank you everybody for joining us today.
Thanks again to our special guests.  Thanks to my co-host Murch, and thank you
all for joining and putting some of your time and attention towards Bitcoin and
Lightning developments.

**Bastien Teinturier**: Thanks for having us.

**Dan Gould**: Cheers.

**Mark Erhardt**: Cheers, see you next week.

**Dan Gould**: Thank you.

**Mike Schmidt**: Thanks Dan, cheers.

{% include references.md %}
