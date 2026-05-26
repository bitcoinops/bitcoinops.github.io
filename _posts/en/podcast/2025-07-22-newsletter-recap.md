---
title: 'Bitcoin Optech Newsletter #363 Recap Podcast'
permalink: /en/podcast/2025/07/22/
reference: /en/newsletters/2025/07/18/
name: 2025-07-22-recap
slug: 2025-07-22-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Davidson Souza to discuss [Newsletter #363]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-6-22/404359539-44100-2-df272ca6989b2.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Bitcoin Optech Newsletter #363 Recap.  Today, we're
going to talk about the utreexo node, Floresta; we're going to talk about the
RGB v0.12 announcement; we're going to cover a FROST signing device, among other
ecosystem software updates; and we also have our usual Notable code and Release
segments.  Murch and I are joined this week by Davidson.  Davidson, do you want
to introduce yourself?

**Davidson Souza**: Yeah, hi, I'm Davidson, I am a grantee from Vinteum from
Brazil, and I'm working on Floresta, which we'll talk about in a short time.
So, yeah, thanks for having me.

_Floresta v0.8.0 released_

**Mike Schmidt**: Excellent, thanks for joining us this week.  We don't have any
news items this week, so we're going to move right to our monthly segment on
Changes to services and client software.  And first in the list is for you,
Davidson, Floresta v0.8.0 being released.  We gave a brief overview of the
release, but maybe, Davidson, you just want to remind folks what is Floresta and
probably also what is utreexo, just as an overview.

**Davidson Souza**: Okay, right.  So, Floresta is a project I've been working
for the last three years.  It started as a research project, but now it's
getting more traction and becoming an actual thing.  But we wanted to basically
answer the question, can we make better light clients that have better security
and privacy, but are still lightweight compared to a full node?  Because I
basically noticed that in Bitcoin, either you have the full node, Bitcoin Core,
running on your machine, then you have like an electro-indexer, have to install
a ton of software to get it running for connecting your wallet, which is not
very newbie-friendly and also requires extra hardware.  It's always cumbersome.
And as a result of that, last time I checked, the amount of full nodes we had,
both listening and not listening, is pretty much the same we had in 2017, so
about 100k nodes.  But on the other side, you have the light clients, but most
of the light clients, they are basically client server in weird performance.
And that's not great, that's not why Bitcoin exists.  We need Bitcoin because
you can validate everything, you can especially validate your own transactions.
You can do that locally, so you have better privacy.

So, I started working on this project to see what are the limits of light
clients.  And one of the key features, which is something I started working on,
like the start of my grant, that was what I was working with, which is utreexo.
So, in Bitcoin, the only context that you need, so the only previous information
you need to carry over to validate a block that's not in the block itself, are
the UTXO set and the chain of headers.  The chain of headers is super-small so
it doesn't matter.  The UTXO set is the big problem because you cannot prune it,
you cannot throw it away like you can with blocks.  And it's kind of big.  It's
not huge like the blockchain, but it has a problem that you are constantly
accessing the UTXO set in random ways.  And for lower-end SSDs or for HDs, this
is terrible.  If you ever try to run a Bitcoin node in an HD or a lower-end SSD,
you probably realize that it takes up to months to work, even with a beefy CPU.
And this is because of all these I/O operations from your node.

Utreexo makes a trade-off where instead of having the full UTXO set, you have
something we call an accumulator, a cryptographic accumulator.  Right now, the
accumulator is less than 1 kB, it's super-small, it fits like the CPU's cache.
And the trade-off is that whenever you are checking a transaction or a block,
you receive some extra information proving to you that this UTXO being spent
belongs to that accumulator, so it is inside the UTXO set.  And those proofs are
served to you by your peers.  We have already clients that can serve those.  The
idea is that in the future, Bitcoin Core could at least serve those proofs.
There is still some debates about whether Bitcoin Core should be utreexo, which
we call CSN, which is the lightweight version of utreexo.  But at least the
possibility of serving proofs to others, I think, there are no people against
it.  And then, you can just store super-small context.

For mainnet right now, I have one Floresta running here on the machine I'm
talking to, and it consumes like 178 MB of disk and 200 MB of RAM, so it's like
nothing.  And we've successfully experimented that on smartphones.  And even the
smallest device, we have the record right now from a friend of mine, and it's a
LicheeRV.  It's like a super-tiny RISC-V machine that has two cores.  I think
it's 200 MB RISC-V cores, 400 MB of RAM and 2 GB of SSD off an SD card.  And it
can run on anything, and we have different security models for how you can make,
for example, IBD (Initial Block Download).  We have three ways you can perform
this: we have the explicit way, which is just download every block and validate
them; we have something that's along the lines of assumeUTXO, but with one
difference that you don't need to download the huge assumeUTXO file that you
need to with Core, because the utreexo accumulator gains less than 1 kB.  So,
it's in the binary already.

There is one that I think is the first implementation of it.  It's an old
proposal by Ruben Somsen called Proof-of-Work (PoW) Fraud Proofs.  It can skip
IBD for a cost that's basically, like, the bandwidth that you use is almost the
same as a normal SPV.  But the trust assumption here is that you have at least
one honest peer, and at least some percent of the hashrate is honest, and this
percentage can be much smaller than the normal 51% that we have with SPVs.  It's
hard to pin a number because of variance, but the number of peers that need to
be attacking you to make you, like, accept an invalid block needs to be over
90%.  So, over 90% of the hashrate needs to be colluding to attack clients that
have this PoW Fraud Proof.  And this is only for IBD.  So, after your IBD, you
can check every single block.

**Mike Schmidt**: Davidson, what are the names of those nodes that are serving
up the proofs to these light clients?  I forget the name historically.

**Davidson Souza**: You can be like a utreexo archive node, which means that you
have proofs for every single block in history.  But right now, because wallets
still don't keep utreexo proofs for their own UTXOs, we have something called
the bridge nodes.  The bridge nodes have the entire UTXO set in a special
format, which is the whole forest, and they can generate proofs for everything.
You don't necessarily need to be a bridge node to serve proofs.  You can be a
utreexo archive node.  So, you have proof for blocks, but you don't have the
accumulator in those big states, like with all the UTXOs.  Ideally, we could in
the future, if utreexo gets traction, we could drop the bridge nodes, but that
will require some support from clients.

**Mike Schmidt**: So, maybe transitioning to one of the v0.8.0 items that I saw,
which is the encrypted transport BIP324, what communications are being encrypted
then from the light client to the bridge nodes, light client to the archival
nodes?

**Davidson Souza**: Yeah, Floresta works the exact same way that a normal node
would when it comes to P2P.  So, it appears as if other Bitcoin software, it can
connect with Bitcoin Core, it can connect with btcd, which utreexod, which you
guys already covered, which is the bridge node implementation we have now, it
connects with them, it can talk normal Bitcoin P2P protocol, you can ask for
blocks, transactions, compact block filters, anything that a node would, we can
ask for.  And we recently got this new improvement for P2P v2 and in this
context, the P2P v2 does exactly the same it does in Core or any other full node
implementation.

**Mike Schmidt**: Okay, that makes sense.  What else would you like to highlight
from this release specifically or utreexo and Floresta more broadly?

**Davidson Souza**: Yeah, so one thing we're trying to do and we have made some
progress in this release is allowing applications that already have some
infrastructure to integrate Floresta, because Floresta is also a library.  So,
we've built a BDK for a Hackathon I participated in.  Our team built a BDK-based
wallet, mobile wallet, so that we run on your phone.  And the idea is that any
mobile wallet could use Floresta, it's very simple, it's like four lines of code
that needs to change and you have Floresta running in your background.  This is
one thing that I've been trying to do since the beginning.  We have integrated
Electrum Server and watch-only wallet exactly for this reason.  So, we are now
implementing all the RPCs from Bitcoin Core and we are making integration tests
to make sure that Floresta and Core are talking the exact same protocol.
Because applications, for example, some people from like node-in-a-box
implementations told me that they would love to have a lightweight version of
their product, because they see, especially in the third world, people want to
have some node, but the hardware that needs to run their products is still very
expensive.  And living in Brazil, I know this.  So, a lighter version of their
hardware would be very nice.  But they need to have the same JSON RPC
implementation of Bitcoin Core, because this is the way that this software is
made to work.  Like, you can swap out the Bitcoin implementation, but you need
to implement the exact same RPC.

So, we've made progress on this and there is still a long way to go, but we are
making progress.  And testing, we are working a lot on testing to make sure that
nothing is broken, the consensus implementation is working.  We recently we have
a grantee from OpenSats that's working very hard on this question of testing or
implementation of Bitcoin.  He recently took a lot of test cases from Bitcoin
Core, and we're now using Bitcoin Core's own tests to make sure that our code
also works with this.  And we're working on this as well.  We've been making
some progress on the compact block filter integration.  It still has some
low-hanging fruits that I would like to address, but it's not the main priority
right now.  But we do support block filters for re-scanning your wallet after
you IBD.  You can add a descriptor or an export or an address, and tell Floresta
to go back and look for transactions related to that address or those addresses.
So, yeah, there's a lot on this release.

**Mike Schmidt**: One thing that we also highlighted in the quick newsletter
write-up was some additional features around monitoring and collecting metrics.
Do you want to talk about that?

**Davidson Souza**: All right, yeah.  We have Prometheus, which is like a
monitoring system that you can export some statistics about your running
software.  I think right now, we have one for the average time that takes to
validate blocks; some about P2P messaging, like how long does our peers take to
respond; what messages are we sending the most.  So, there is like a lot of
small statistics about your node that's running that you can export to
Prometheus and use something like Grafana to make a dashboard and see those
statistics rendered in a nice dashboard.

**Mike Schmidt**: Cool.  Go ahead, Murch.

**Mark Erhardt**: Yeah, so you said that Floresta would be able to support
especially light client wallets.  Do I understand right that it would
essentially be a plugin replacement for something like BDK, or is it another
layer?  What does it exactly replace, the backend blockchain,
bring-your-own-blockchain part, or is it more of a translation layer?

**Davidson Souza**: Yes, exactly, the bringing-the-blockchain part.  By the way,
we have a fellow from Intune that's working on integration for BDK and Floresta.
So, in the future, people using BDK will be able to use Floresta as the chain
source provider.  So, you'll be making all the validation that Floresta does and
all the local syncing, and all without changing anything.  You just instantiate
Floresta, parse it through your BDK wallet and everything will work under the
hood for you.

**Mark Erhardt**: Right.  So, if BDK integrates with Floresta and Floresta is
dependent on having the proofs, I assume that when you are asking for
transactions or UTXOs or blocks, it would get the proofs; and then, how would
the wallet know which proofs to retain?  That would be on BDK to tell the
Floresta layer, or how would that interaction work?

**Davidson Souza**: Well, right now the way we do this, the wallet doesn't
necessarily need to follow those proofs because they are only using consensus
parts, which is entirely in the side of Floresta.  But if you want to change
into the bridge-less network, which is the network I say that we don't need
bridge, we will need a way to tell Floresta that it needs to follow those proofs
and BDK would have this integrate, like some hook, something that it would call
to tell Floresta to follow them.  And possibly, we haven't thought about that
interface yet, but I've talked about this with Evan Lin, which is one of the
main developers of BDK, and he said that he absolutely thinks that BDK should
support utreexo.  And by the way, we have a Rust implementation of utreexo.
It's very fast, very well-tested.  So, it will be very easy to integrate this.

**Mark Erhardt**: In danger of repeating something from earlier, you said that
the on-disk footprint is much smaller, but I was wondering about the bandwidth
footprint.  I would assume that requiring the proofs and downloading more data,
this would probably only happen for the transactions that the wallet is
interested in.  But how does the bandwidth use compare?

**Davidson Souza**: Actually, when you download the block, you download all the
proofs, because you need to validate all the UTXOs.  The proof is interesting
because it can go as bad as 100% overhead.  So, if a block is 1 MB, then you
have 2 MB.  I don't think it can go worse than 100%, but this is something
that's in the paper and we are working now.  All UTXOs in Bitcoin, they follow a
very interesting pattern where they are more likely to be spent right after
being created.  And as they get older, the likelihood of them being spent goes
down in a Poisson distribution.  So, what we're doing is, even with a few
hundred MB of cache, you can save, like, 60% of bandwidth, because even though
your cache is tiny, it always rotates, so you are always recycling that cache.
And you keep, let's say, the last 100 blocks' worth of UTXOs, like UTXOs that
have been created in the last 100 blocks that will be spent within the next 100
blocks.  You keep those, you don't ask for those in the P2P.  And Calvin, who is
working more on this, he told me that you can go as low as like 40% or 30%
overhead.  So, a 1 MB block, 300 kB of proof.

So, I think it's an okay trade-off.  It's not huge in terms of a block, and it's
144 blocks every day, so a few hundred MB.

**Mike Schmidt**: Davison, you mentioned utreexod, and I think we covered a beta
release from them just a little over a year ago.  Do you have any visibility
into how that has been progressing?

**Davidson Souza**: Yeah, Calvin is working hard on this P2P optimization I
talked about, and he's doing more experiments.  And we'll probably sync up
releases, because we changed the way proofs are propagated in the network, and
both clients need to speak the same protocol.  So, we may sync the releases when
it comes out.  I think it's almost done, he had some very interesting results.
He told that the implementation is very sound, it's working, there are no
obvious bugs.  So, he's been working on that, and there are also some new
features upstream.  For example, recently, btcd merged P2P v2 as well, so the
next release will also be packed with some very nice stuff.  He's only holding
back on releasing something exactly because there is all this research going on
about P2P caching.  This is why you haven't heard any release from him, but he's
very active working on this, like profiling stuff, measuring.  He and Tadge came
up with a caching algorithm for optional caching, and it's now implemented and
working.  So, yeah, it's going great.  And I hear that in the next couple of
weeks or months, there will be BIPs as well.

**Mike Schmidt**: I can imagine some listeners wanting to play around with
Floresta, and maybe you can provide those listeners just, is there a one-stop
shop if somebody wants to start prototyping something using Floresta?  What's
the best place for them to go?

**Davidson Souza**: Yeah, we have excellent documentation.  You should go to
GitHub and go to the Floresta main crate.  You'll see lots of examples, and we
also have an mdBook explaining the internals if you wanted to get more about how
it works internally.  And because Floresta's broken down to multiple crates, and
one implements the chain part, one implements the P2P part, one implements the
compact block filters part, you can combine different crates together and
assemble what you want, and they are all well-documented there, the API.  I also
have some examples of using it for example as a backend for Core Lightning
(CLN), for using with Lightning.  So, you can find those either in the Vinteum
repository, which is where Floresta lives, or in my personal GitHub; it's just
my name, Davidson Souza.

**Mike Schmidt**: Seems like it would be a great project for people to fire up a
weekend proof of concept for something that they're working on.  So, yeah,
thanks project for people to that and, Davidson, thanks for your time joining us
today.  You're welcome to hang on for the rest of the newsletter or you're free
to drop.

**Davidson Souza**: Sure.  I'll hang on more.

_RGB v0.12 announced_

**Mike Schmidt**: RGB v0.12 announced, and this is an RGB blogpost that we
referenced in the write-up that officially announces the release of RGB's
consensus layer with RGB's client-side validated smart contracts available now
on testnet and mainnet.  So, they've solidified what they're calling consensus
for their client-side validation protocol.  In their blogpost, they outlined a
few categories of things that have been worked on over the last eight months
when they've been doing some protocol redesign, including being ready for
zero-knowledge proofs, greatly simplifying the protocol itself.  They noted,
"RGB has so far been notoriously infamous for the protocol complexity", but
v0.12 should simplify a lot of that.  And there's a bunch of details in the
blogpost that I'm glossing over here, as they're probably too in the weeds for
this discussion.

There's also a section on specifically payment improvements including invoicing,
multiple asset contracts, payment scripts, and also better support for chain
reorganizations.  There's also a whole category of performance.  They've really
focused on bringing their performance up to production level, and they get into
some of the optimizations that they've made there.  And then the final category
of things that they highlighted in this release was just broader test suite
coverage.  So, they have integration tests, not just happy paths, but also
attack scenarios that they've provided unit test coverage for.  Murch, I sort of
jumped right into it, but we didn't really talk about client-side validated
smart contracts.  I don't know if you have anything to add though.

**Mark Erhardt**: Oh, basically that means that you put on a set of colored
glasses and when you view the blockchain through those, and maybe also receive
some additional out-of-band information, activity on the blockchain can have
additional meaning in this colored world.  So, you sort of build an additional
layer on top to provide context for some of the activity.  So, my understanding
is that with the RGB v0.12 RC, this is, according to their blog post, a
consensus release, or de-consensus release.  And the worry was that with
client-side validation, if the consensus changes, it might break forward
compatibility of smart contracts.  So, after they have released their consensus,
it should no longer break smart contracts.  They were suggesting to any users
that any smart contracts that are already deployed should be redeployed for this
version.

They've also called for developers that want to integrate this release into
their products that they would be happy to support them, and were indicating
that the full release of v0.12 would follow after some developers have
integrated it into their products, probably to make sure that this ossifying
consensus release is tested by implementers and made sure that actually there
doesn't have to be any other change before it's fully released.  Did that cover
your question, Mike?

**Mike Schmidt**: Yeah, I think so.  I'd also point folks who are curious about
more, there's a client-side validation topic on the Optech wiki.  So, when Murch
is talking about those colored glasses that these protocols use, you can think
of RGB of having one color-tinted glass for their protocol.  There's also
taproot assets that sort of has a different set of glasses, and then we've
recently talked with Jonas Nick about Shielded CSV, which is another flavor of
glasses, to mix my metaphors.  And so, check out the topics for the general
category of client-side validated protocols, and you can also dig into some news
that we've had over those different protocols over the years.

_FROST signing device available_

**Mike Schmidt**: FROST signing device available.  We've talked a bit about
FROST and its ability to have threshold signature schemes that actually end up
as a single-signature on chain.  But now we have a signing device that supports
that threshold signing using the FROST protocol.  And it's called Frostsnap, and
I think we've had some folks from there on in the past, I think when they were
doing software-related FROST things, but now they have actual signing devices
that you can put together to do FROST thresholds signing.  Unfortunately, we
weren't able to get anyone from Frostsnap on the show, but I do have a few notes
offline that I received after I let them know that we're going to talk about
this.

So, the device is actually for early adopters, and they're calling this
Frostsnap Frontier.  The Frostsnap team thinks that they have a good working
product, but they want to start sharing that now with folks who are maybe more
bleeding-edge-type users to join them in their exploration of this space.  The
Frostsnap Frontier is focused on getting people to not store their wealth in a
single hardware device that's in their house, for example, and I think that they
are really wanting folks to buy more than one of these.  I think there's packs
of like three and five that you can use, and then you can set up your threshold
scheme accordingly.  And then, each of those devices has its own backup, which
is a Shamir share, and then a threshold of them restores the wallet without even
needing descriptor backups.

They noted that everything is open source, it's all in Rust, there is a user
interface, there's a wallet that's based on BDK, they can do PSBT signing as
well.  So, if you don't trust their wallet, you can use something like Sparrow
and coordinate via scanning PSBTs.  And I think all these Frostsnap Frontier
devices go through the phone that speaks to the various signing device
components, but I'm not totally sure on that.  Murch, did you get a chance to
double-click into Frostsnap?

**Mark Erhardt**: I saw a little bit of the coverage, I think last year, and I
think it's really cool that you just plug them into each other, and then as soon
as it notices that it has a sufficient quorum, it just creates the signature.
And it sounds like they've really thought about the UX, because even while you
might be working on a 3-of-5, or whatever, once three devices are there, even
without descriptor backups or anything like that, your three devices can sign
for the UTXOs.  So, just making this hardware and plugging the keys into each
other is kind of cyberpunk!

**Mike Schmidt**: Yeah, if you look at some of the videos that I've seen on
social media, the profile of the device is interesting.  It sort of looks like
the face of a watch almost.  And then, you can plug a series of these into each
other to do the threshold signing.  So, if you have a 3-of-5 or something, you
can plug three in and it'll sign for you if you lose the other two.  So, pretty
cool.  You end up with that single-signature on chain, but you're actually doing
threshold multisig behind.  So, I think that's pretty cool.  Folks are probably
familiar with MuSig, but in the MuSig case, you need to have all five, you know,
5-of-5, and you get that one signature on chain.  So, this is a cool way that I
think maybe older bitcoiners are familiar with doing the 3-of-5, and things like
that, so you can do that now with a lot less space used on chain.

_Gemini adds taproot support_

**Mike Schmidt**: Gemini adds taproot support.  This goes for both the Gemini
Exchange as well as the Gemini Custody service.  They both added support for
being able to send or withdraw, in the case of exchanges and custody, to taproot
addresses, so that's great.  I know, Murch, you were tracking that alongside us
with the whentaproot website.  You scooped us.

**Mark Erhardt**: I did, yes.  Someone working at Gemini reported that to us in
May, I think.  So, Gemini's had sending to P2TR output support since May.  I
thought it would also be fun to look a little bit at taproot adoption.  It's
been almost 200,000 blocks since taproot activated.  We're getting close to four
years, which will be in November.  So, while taproot is the most common type of
UTXO now in our network, clearly because various Colored Coin protocols use P2TR
outputs preferentially in the last couple of years, there's a very small amount
of bitcoin held in P2TR outputs.  It's only 156,000 bitcoin as of last week,
which is about 0.8% of the supply.

But this adoption has changed since the start of the year, especially when the
mempool emptied and people started doing some UTXO management and cleaning up
their wallets maybe a little bit after the fees have come down.  So, the UTXO
set peaked in December at about 187.2 million UTXOs.  Maybe it was .3, sorry.
And now it's about 166 million.  So, we're down 21 million UTXOs from the peak.
And UTXOs are slightly up, but mostly P2WPKH and P2PKH are down together 16
million UTXOs.  So, while some of the other parts were being discussed, I was
just looking up numbers from last year.  Last year in March, I believe, let me
double-check; yes, in March last year, there were only 60,000 bitcoin in taproot
addresses, so we're up almost 100,000 since then.  So, I think that maybe a few
more people are now rolling out taproot.

Unfortunately, some of the biggest businesses in Bitcoin still don't support
sending to taproot outputs, for example, crypto.com and Binance, who really
should think about getting into gear.  Yeah, anyway, that's maybe a little
update on whentaproot.

**Mike Schmidt**: And so, I suppose as taproot rolls out to more service
providers and there's more innovation, like Frostsnap and things like that,
taking advantage of schnorr signatures and taproot, as it percolates out,
perhaps those numbers continue to go up with adoption of service providers and
signing devices and features like that.

**Mark Erhardt**: I'm also still waiting for silent payments to be implemented
in Bitcoin Core.  It's out on a few other wallets, but that would make P2TR have
some unique functionality.  Of course, coming from the Quantum Summit last week,
if you subscribe to the threat of quantum computers, one downside is of course
that P2TR outputs directly reveal a public key which could be used for quantum
decryption to find the private key.  Personally, I felt that everything we heard
from researchers in the field and the general story, we still have quite a few
years until we really have to be afraid of quantum computers threatening quantum
decryption, but I think it's a good time to start talking a little bit about it.
So, in my opinion, we're still good to amp up the P2TR adoption.

**Mike Schmidt**: And isn't, related to quantum, Murch, one of the schemes, I
think it was BlueMatt, and I don't know if it has a fancy name or anything, but
sort of having an escape hatch in a taproot script path, so that if there is
this quantum breakthrough and you can reverse a public key into a private key,
in theory if it were a settled upon scheme to hide this in the taproot
scriptpath like that, the threat of quantum could actually increase people
adopting taproot for that reason, at least on that one access.  What are your
thoughts on that?

**Mark Erhardt**: Yeah, I think that in that context, it would be nice to start
putting scriptpath spending conditions on all of your taproot outputs so that if
we ever get into the position where the appearance of a
cryptographically-relevant quantum computer makes an appearance, we would
disable the keypath spending, or let's say there is proposals for disabling the
keypath spend in order to make it hard for quantum computer operators to
misappropriate coins, and then you'd have to fall back to some sort of other
proof.  These seem to be based either on the wallet derivation rules or on
scriptpaths.  BIP360, which is the BIP that tries to paint a path towards a
quantum-resistant output type, is also working in that regard.  They propose a
new output script type that has the scriptpath spending for taproot, but not the
keypath spending, which makes scriptpath spending a little cheaper in their
proposal.  But then of course, the cheapest variant, which is the keypath spend,
wouldn't be available anymore.

So, at the Quantum Summit also, I thought that the proposal that Tadge made was
directionally very interesting.  He talked about something he called LifeRaft,
and the idea there would be that you sort of can publish information to the
blockchain that proves that you are holding the private key or can derive
additional sibling keys, or whatever.  And then later, when you show the
transaction, you can only spend it in conjunction with the prior commitment,
which would mean you sort of have to know ahead of -- well, this would allow you
to spend by committing to what you'll reveal later and this is hash protected,
so it would be quantum-resistant.  And a very appealing property of this
proposal is that if the output scripts have scriptpaths or have the properties
we need for LifeRaft, we wouldn't need any additional complexity or output types
in order to have a way of quantum-resistant spending, should that ever happen.
Personally, I think we might be some decades away of that actually becoming a
threat, but it's good to talk about this stuff.

**Mike Schmidt**: Well, as we see with taproot adoption that we just talked
about, sometimes things can take longer than we think to roll out to the
community.  Although, I suppose if quantum is maybe a bit of a bigger flame
underneath people's butts to move, then maybe nice features of taproot might be.
But that all remains to be seen.  It's all speculative now in the quantum world.

_Electrum 4.6.0 released_

Our last piece of software that we highlighted this month was Electrum 4.6.0
being released.  And in addition to updates to their particular Lightning
implementation and some other things we called out, they're adding support for
submarine swaps, and they actually used Nostr to discover potential peers to do
these swaps with.  So, you can swap onchain bitcoin for Lightning channel
bitcoin, or vice versa, using submarine swaps and Electrum with this latest
release.

_LND v0.19.2-beta_

Releases and release candidates, LND v0.19.2-beta.  We covered 0.19.2-beta.rc2
last week, and looking at the release notes for the beta now, I think that our
coverage last week in Podcast #362 still stands in terms of highlighting the
features in this release.  You can refer back to that podcast for more, but a
couple of headline features were the database migration to speed up performance
and signet/testnet4 peer seed support and a bunch of bug fixes.  The release
also made a point to say 'important' bug fixes, so I wanted to reiterate that
word, 'important', for anyone who's running LND.

_Bitcoin Core #32604_

Notable code and documentation changes.  Bitcoin Core #32604, mitigating
disk-filling attacks.  Murch?

**Mark Erhardt**: Yeah, so I looked a little bit at this.  Apparently, this is
trying to deal with attacks where you would cause a node to just fill the disk
with excessive logging, and it introduces a limit of 1 MB per logging source per
hour.  And that way, if some activity starts that causes a node to excessively
log, it would just start omitting some of the logs and indicate in the log that
one of the sources is being suppressed by adding asterisks.  And the console
output or manual logging that have explicit arguments and things like that are
exempt.  So, the most important logs should always go through, and especially
logs that you specifically configured, from what I understand.  And yeah, just
making it more robust, I guess.

_Bitcoin Core #32618_

**Mike Schmidt**: Bitcoin Core #32618, removing watch-only wallet functionality.
Murch?

**Mark Erhardt**: Yeah, so in the legacy wallet, it was permitted to have both
spendable and derivation instructions next to watch-only derivation
instructions.  And that posed some interesting problems, like if you do coin
selection and you have some watch-only coins selected and some spendable coins
selected, how do you distinguish them?  How do you manage all of this mixed
state?  Then, you might only need to create a PSBT so you can get the additional
signatures from the signing device or second computer that has the actual keys,
and so forth.  The descriptive wallets that we've had for a few years now take a
radically different approach, where they do not permit the mixing of watch-only
and spendable coins.  So, a wallet is either watch-only or spendable directly by
this device.  And that simplifies a lot of these concerns where you either know
you're only creating a raw transaction that still needs to be signed later, or
you're creating a finalized transaction directly in your transaction building.

So, this PR, now that the legacy wallet has been removed recently, obviously
there is still a migration path, but just we do not create new legacy wallets,
and when we load them, we can only migrate them to a descriptive wallet at this
point.  Yeah, anyway, the descriptive wallets do not mix the functionality.
That makes a lot of things a lot simpler and this PR cleans up a lot of that
code that is no longer necessary to address the complexity of mixing.

_Bitcoin Core #31553_

**Mike Schmidt**: Bitcoin Core #31553, adding reorg functionality to cluster
mempool.

**Mark Erhardt**: Yeah, okay.  So, we've talked about cluster mempool a couple
of times before.  One of the new things that comes with cluster mempool is that
previously, we were limiting ancestors and descendants of transactions, but now
we limit transaction clusters because that is what sort of bounds the
computational complexity for finding out what we want to keep.  So, if you have
a reorg, a bunch of transactions might get pushed back into the mempool.  And
that could, for example, combine some clusters that were separated, like two
transactions spending from an ancestor transaction that were in separate
clusters would become part of one bigger cluster if the ancestor gets added back
into the mempool.  Whenever this would violate the cluster limit, we get a
little problem, because we don't want to have clusters bigger than the cluster
limit in our mempool, because it might get computationally expensive to find out
how to linearize that and what to include in blocks, etc.

So, what this PR does is whenever a bunch of transactions are added back to the
mempool, it looks at the candidate clusters and for any oversized candidate
clusters, it trims them down to the cluster limit.  It does this here by
linearizing each cluster individually and then sort of merge-sorting them by
picking the highest feerate chunk that does not have unmet dependencies into the
filtered cluster or trimmed cluster until a cluster limit is hit, and whenever a
transaction exceeds the limits, it is trimmed with all of its descendants.  So,
for example, with the prior example that I suggested where an ancestor was added
back and maybe we had two clusters that were full-sized before and now they
become one cluster, it would just use the linearizations of those two clusters
it had and start adding them back to one big cluster, and then drop whenever it
exceeds the limit from either one or the other cluster the lowest feerate
chunks.  This is of course consistent now with the order in which we will build
blocks, because the chunks with the lowest feerates are the ones that are going
to be the least interesting for building blocks until, well, they come back up
and everything before them has been mined.

Yeah, so cluster mempool is progressing.  I think there's still some work to be
done to fully integrate it with mempool, like a lot of the low-level stuff is
there now, but it's not yet fully integrated and replacing the old mempool
design.  So, as we're coming up to feature fees for the next release, it's
getting exciting of whether it's going to be in the next release or in the
second next release.

_Core Lightning #7725_

**Mike Schmidt**: I see, okay, so we're getting down to the wire here of cluster
mempools going to be in or not.  Core Lightning #7725.  This one's pretty
straightforward.  This PR adds a web page to the repository that can be used to
view and interact with log files from CLN.  It has some filter and search
capabilities, and maybe it's just a nice quality of life feature for our CLN
folks.  There's a little bit of back and forth on whether that should be in the
CLN repository or not, but they did merge it and there's a little video in the
description, if you click through, to see someone interacting with the log.

_Eclair #2716_

Eclair #2716 is a PR titled, "Endorse HTLC and local reputation".  The PR adds
three things and I'm going to enumerate them here and tap in Murch in a minute.
But the first one is, it implements the experimental endorsement signaling that
was specified in BLIP4, which is basically just a lightweight mechanism and it
can be reversed as well if it doesn't work, to assess various reputation
algorithms.  Maybe now I'll tap in Murch.  Murch, why do we need a reputation
metric on the LN?

**Mark Erhardt**: Yeah, this is for channel jamming mitigation.  So,
specifically, jamming could be used to find out exactly how the balances are
distributed on a channel, or to just reduce some nodes' capacity of forwarding
by locking up all of their funds.  The HTLC (Hash Time Locked Contract)
endorsements are specifically supposed to help with the slow jamming, where you
just hold a lot of funds on a channel until the HTLC times out in order to
reduce the capacity of the channel owner.  The fast jamming is mitigated by
upfront fees.  So, if you just do a lot of probing, a lot of back and forth
where you build up HTLCs but never spend anything, if you have to pay upfront
fees for building up HTLCs, that will introduce a cost and reduce the incentive
for that sort of behavior.  For the slow jamming, the idea is as you continue to
interact with another node, you learn which nodes send HTLCs and they get
quickly finalized and the funds are freed up again.  And as that happens, your
peers build up some reputation with you and you limit, I think it was half of
your capacity and half of your channels, sorry, HTLC slots only to peers that
have reputation.

If I remember correctly, the direction in which the endorsement was assigned
recently turned around to fix a bug.  Originally, nodes would endorse an HTLC to
their downstream peer.  As they forward it, they would say, "Hey, I think this
is coming from a good source, please treat it as a reputable HTLC".  And I think
that was turned around.  So, now when nodes receive an HTLC that has the
reputable marker, they check whether they considered the sender reputable and
then forward it as such or don't.  Anyway, the idea is that this should help
with mitigating slow jamming.

**Mike Schmidt**: Thanks for that sidebar, Murch.  So, the experimental
endorsement signaling was part one of this PR.  Part two was an implementation
of the local reputation system.  Basically, it's defined as how much the peer
node paid the local node in fees, divided by how much they should have paid the
Eclair node for the liquidity slots that they blocked.  And then, there's
scoring based on that, successful payment scoring 100, and anything other than
success scores some penalty weighting.  And there's also the confidence that the
HTLC will be fulfilled is also transmitted to the next node, and there are eight
different endorsement levels.  I think there's just 100 divided by 8 are the
different ranges.  And then, there's also a few different knobs in Eclair for
operators to customize some of the reputation scoring mechanisms, in terms of
the different aspects across the reputation score.  And so, that reputation
system is number two.

Then, number three, this PR adds a limit on the number of small HTLCs per
channel, "We allow just a very few small HTLCs per channel.  So, it's not
possible to block large HTLCs using only small HTLCs".  It should be emphasized
that this PR, the focus here is to collect data to improve the types of attacks,
or data to research against the type of attacks that Murch outlined, channel
jamming attacks, and does not yet implement any penalties.

_LDK #3628_

LDK #3628 further builds towards LDK's async payment capabilities that would
allow someone offline to receive LN payments.  In Newsletter and Podcast #361,
we actually covered LDK's client-side implementation of their static invoice
server protocol.  And that protocol basically allows coordination between
potentially offline receiver with an always-on server that would then serve
static invoices on the receiver's behalf.  So, in #361 we talked about the
client side of that.  And then this week, we're covering the server-side
component of that coordination, and this PR implements LDK static invoice server
flow protocol that we also talked about in Newsletter and Podcast #361.  So, now
you have the client side, you have the server side, so it looks like it's
getting closer.  If you want to see how close LDK's async payment capabilities
are, check out their tracking issue #2298 on the LDK repo.

_LDK #3890_

LDK #3890 changes the way LDK scores routes in its pathfinding algorithm.  So,
previously, LDK only considered the total cost in fees.  Now, it considers the
total cost divided by the channel amount limit, which is essentially the cost
per sat of usable capacity.  And this new approach will slightly bias
pathfinding towards higher-capacity routes, but it has the advantage of reducing
excessive multipath payment sharding and results in a higher payment success
rate.  On the flipside of that, the change now overly penalizes smaller
channels, but it was noted in the PR that the trade-off is preferable to the
previous excessive multipart payment sharding.  In the PR, it was noted,
"Several users have reported that we often attempt far too many MPP parts".  So,
based on that feedback that LDK devs heard, they tweaked their scoring in the
pathfinding algorithm.

_LND #10001_

Last PR this week, LND #10001, which allows LND's quiescence protocol to be used
in production/mainnet.  Quiescence, as a reminder, is essentially when you have
an LN channel, the two parties to that channel say, "Hey, we're going to pause
and we're going to do something fairly drastic to this channel and we don't want
any activity going through the channel during that time".  So, that pause is,
quiescence, essentially the way I think about it as sort of a pause in the
channel activity.  And one example that we have used in previous podcasts to
explain that is the need for pausing during a splice, so when someone's splicing
in or out of a channel.  There's also another reason that you might want to
pause the channel or quiesce the channel, which is dynamic commitments, also
referred to as channel commitment upgrades, which would allow LN to upgrade
channel types on the fly without having to close the channel and then reopen the
channel using a different commitment type.  So, for example, perhaps allowing a
move from existing legacy P2WSH format to a taproot-based channel without having
to close the channel out.

So, this PR also adds a configuration value for how long that timeout is.  So,
obviously you're pausing, you can't pause indefinitely.  It defaults to 60
seconds, but doesn't allow anything less than 30 seconds.  So, I guess if you're
pausing, it's going to be at least 30 seconds.  So, any dependent operations
like dynamic commitments or splicing have to finish their operations under this
timeout value.  Otherwise, I think the node will disconnect, is the behavior.
Yeah, Murch.

**Mark Erhardt**: I thought it was funny that you said 'legacy' to P2WSH.  So,
we've been waiting for a very long time for LN channels to switch to P2TR
channel, what was it, funding outputs?  Yes.  I think that's still in the works.
There's also a lot of discussion recently again how P2TR would be easier if some
of the introspection opcodes that people are talking about were present for PTLC
(Point Time Locked Contract) adoption and re-bindable signatures.  We talked
about that two weeks ago or so.  Anyway, it's hopefully happening at some point
that we do get P2TR channels, which would make it a lot easier for LN channels
to not stick out like a sore thumb on blockchain data, because in the happy
path, they just look like a P2TR single-sig.  But yeah, we'll report when that
happens.

**Mike Schmidt**: That's it for the newsletter this week.  Davidson, thanks for
joining us and hanging on for the newsletter.  We appreciated your time earlier.

**Davidson Souza**: Yeah, thanks for having me, guys.

**Mike Schmidt**: And, Murch, thanks for co-hosting and for all you for
listening.  We'll hear you next week.

**Mark Erhardt**: Hear you next week.

{% include references.md %}
