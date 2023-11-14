---
title: 'Bitcoin Optech Newsletter #214 Recap Podcast'
permalink: /en/podcast/2022/08/25/
reference: /en/newsletters/2022/08/24/
name: 2022-08-25-recap
slug: 2022-08-25-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Antoine Riard and Rodolfo Novak to discuss [Newsletter #214]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-29/349059701-44100-2-7fc13f321d804.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Bitcoin Optech Newsletter #214 Recap.  We'll be
going over our latest newsletter from yesterday with a few different special
guests to hopefully chime in.  My name is Mike Schmidt, I'm a contributor at
Optech, and I also am the Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.  I write for Optech
Newsletter sometimes and usually review it, and I write about Bitcoin and
various avenues and work on different codebases.

**Mike Schmidt**: Rodolfo?

**Rodolfo Novak**: Hey, I'm Rodolfo, I co-founded Coinkite a long time ago.  We
make a lot of the stuff that you use, like the Coldcard and the Satscard and the
Opendimes, and all that stuff.

**Mike Schmidt**: And the BLOCKCLOCK that's behind everybody during their
YouTube interviews.

**Rodolfo Novak**: That's right, you're not a real Bitcoiner without that,
right?

**Mike Schmidt**: Well, I guess not.  I don't see one on the shelf behind me
right now, so maybe someday!

**Mark Erhardt**: I tend to fail almost all of the purity tests.  I guess I'm
not a bitcoiner!

**Mike Schmidt**: Well, but you have your own merchandise, so that's okay.  I
think that qualifies you if you have your own shirts.

**Mark Erhardt**: Yeah, well...!

**Mike Schmidt**: All right, well, let's jump into it.  If you all want to
follow along, just bring up the newsletter, bitcoinops.org, or your email that
you hopefully got, if you're an email subscriber.  I don't know if we want to
start with the channel jamming if we don't have Antoine on, and if he's able to
eventually get on, even though he's listening.

**Mark Erhardt**: Yeah, let's go to updated silent payments first and then see
what happens.

_Updated silent payments PR_

**Mike Schmidt**: OK, great.  So, silent payments, there's been an update to
silent payments PR, so we should probably overview what silent payments are.
And silent payments are a way to use a sort of reusable address instead of a
single address that's available onchain.  You provide this offchain address to
someone who wants to send bitcoins to you, and they use that, they tweak that
address to a unique receive address that you can use.  And the use case there
would be something like publishing a donation address.  You don't want to
publish a single donation address online and then get 400 donations that are all
somewhat linked to one another, so you can publish this silent address and then
folks can derive receive addresses for you from that, and therefore you have
unique payments for each one of those transactions, as opposed to having them
all in that same address.

One use case is donations and then there are other use cases, something like a
recurring payment, where you don't have to actually provide a new address each
time to the person sending you the funds.  You can derive future receive
addresses from that initial shared key.  Murch, do you want to correct or
augment any of that?

**Mark Erhardt**: I think maybe we could get a little bit into the mechanism of
how the recipient actually knows that they got paid, because you do not pay the
actual published key, and I think that that's interesting.  So, obviously, if
you reuse addresses, that's very bad for privacy, because any reuse of the same
scriptPubKey will make it immediately obvious that the same entity is involved
in a transaction.  However, if you publish a pubkey, somebody can use their
private key to generate a shared secret.  And essentially, some of you might
have heard of the Diffie-Hellman handshake, which is the observation that a
public key multiplied by a private key of the other party gets the same result
as a private key multiplied by the public key of the other party.  So, public
key and private key versus private key and public key of the corresponding
parties can derive a shared secret.

If I remember correctly in Ruben Somsen's proposal, you communicate the public
key that the recipient should derive the shared secret with by the change output
that you pay.  So, you pay to yourself using a specific public key, and you use
the corresponding private key and the public key that was published to establish
the silent payment address to derive the shared secret, and the recipient checks
for every transaction they see, whether the change output's public key with the
private key that belongs to the published silent payment address creates a
shared secret that they can use to spend the payment.  So, not only is it still
locked only to the recipient, but nobody but the sender can notice even that the
payment to a pre-established secret was made, and nobody can discover that the
same silent address was used ever before.  The overhead of course is that you
have to scan every single payment that fits the schema.

**Mike Schmidt**: So, how is this different than, let's say, BIP47?

**Mark Erhardt**: I believe in BIP47, the difference is that you have to publish
the secret onchain by making a special transaction that sort of establishes the
seed for all the -- sorry, no.  You publish your own key in either a registry or
on your website, and then whoever wants to pay you needs to make an announcement
transaction, where they basically establish a shared secret.  And these
announcements can be recognized as belonging together because they need to make
a small payment to the recipient's key, I think, and then the actual payment
later is secret.  So, there's onchain overhead, it's kind of awkward with the
announcement transaction, and the privacy is not as nice as with this new
proposal.  But yeah, if somebody here knows that I'm wrong, they should totally
let me know.

**Mike Schmidt**: Are there other use cases other than a donation address or the
idea of recurring payments, where you don't have to interact after that first
giving-out of that address that you can think of?

**Mark Erhardt**: Well, I think generally if you have an interaction, there
would be better ways.  You would just share a descriptor with the sender and you
could just generate a new descriptor for everyone that wants to send to you, and
you know that they'll only send to that and then you only have to track their
addresses from this descriptor with some gap limit.  So, if you have actually an
interaction, there are more efficient ways.  I think this is specifically for
cases where you don't have an interaction at all, or it's just one-directional
interaction, they visit your website for example, and then they can already pay
you.

**Mike Schmidt**: And so, specific to the newsletter this week was the PR was
updated, and there's some discussion around descriptors for silent payments, so
some proposal for an SP descriptor.  And it seems like there is some discussion
on the PR about that, which is part of the update this week.  I think there were
some other items in there as well.  But do you have thoughts on the descriptor
discussion around silent payments, or are you familiar with that, Murch?

**Mark Erhardt**: I am afraid I have not dived that deep into it.

**Mike Schmidt**: Okay.  Well, if anybody has questions on silent payments or
some comments to add, feel free to raise your hands and we can give you the mic.
But otherwise, I think we could probably move on to additional topics.  Since we
have Rodolfo, maybe it makes sense to move on to the monthly segment where we
cover Changes to services and client software.  So, this is one of the monthly
features that we have on the newsletter, which is relevant to Bitcoin technology
changes in the ecosystem.  And so, this is actually something that I put
together each month, and I have a list of a bunch of links in a Google Doc of
various services and software that I check on GitHub and other news locations,
and try to vet the most relevant ones for the newsletter.  So, we can go through
those pretty quickly.  There's four this month, but I think Rodolfo can also
augment some of that with some of the stuff he's been doing with the
Bitcoin.Review project.

_Purse.io adds Lightning support_

So, the first one here is Purse.io adding Lightning support.  So, I think it was
a month or so back, Purse announced a beta test for Lightning, and it sounds
like that went well because in a recent tweet, they also published that they
actually will be supporting the LN for deposits and withdrawals, which would be
receiving and sending, so you can go both ways on the LN with Purse now.  Purse
is a service that allows you to put in bitcoins and put in an offer, and someone
can essentially take your Amazon order and pay for it for you.  So, you can use
your bitcoin and Lightning to get a slight discount on your Amazon orders.  And
so they've added Lightning, which is great.  That seems like a win.

**Rodolfo Novak**: Yeah, the purse project is interesting because a lot of
people use this as a means of getting non-KYC dollars using their Amazon gift
cards.  There's like a whole economy of gift cards as a means of not doing bank
transactions for US-denominated dollars.

**Mike Schmidt**: Is that how the discount is achieved then, because I know you
can like request a discount?

**Rodolfo Novak**: Yeah, so essentially, for whatever reason, you got paid in
gift cards, you want to get rid of the gift cards because you don't need more
crap from Amazon, you can go there and sell your Amazon gift cards at a discount
to somebody else who wants Amazon gift cards and is willing to part with their
BTC for them at a discount on their Amazon purchase, right?  So, it's kind of
like a win-win for everybody.

**Mike Schmidt**: Yeah, it was nice to see them integrate that.  I know that
they have a variety of payment methods, some alternate altcoin funding over the
account.  So, it's nice to see Lightning there.  And by my recollection, they're
a fairly popular service, so it's nice to see them integrating Lightning.

_Proof of concept coinjoin implementation joinstr_

The next one on the list was a proof of concept implementation that is a
coinjoin implementation using this nostr protocol, which I had been seeing on
Twitter, but hadn't actually looked into until this project was released.  So,
this developer, I don't know, 1440000bytes, developed this joinstr.  This is a
proof of concept; this is not something that should be used, per their
recommendation.  It's a coinjoin implementation using this protocol.  So, this
protocol is a public key relay network and it doesn't have a central server.
And so, there's a link in the newsletter to this protocol for you to read more
about it.  I don't have an intimate knowledge of it other than it's a way to
relay information within the network in a censorship-resistant way that also has
some protections.  So, I thought that was cool.

I haven't used the software myself, Murch or Rodolfo, I'm not sure if you've
looked at that particular proof of concept or have any thoughts on it?

**Rodolfo Novak**: I just looked at it briefly.  It seems to just be a really
nice, very general-purpose protocol, and I think they use LN as a means to
prevent spamming and all that stuff.  It would be nice to have a decentralized
coordinator for coinjoin.  I think that would be a huge gain there.

**Mike Schmidt**: Murch, any comments?

**Mark Erhardt**: Conceptually, I think, yeah, what Rodolfo said.  The idea is a
good one and there have been a number of different proposals on how to get
multiple users to be able to create transactions together.  The idea of course
is to mix the transaction pedigree of the UTXOs that are spent in a transaction
together, because one of the most successful heuristics in analyzing chain
traffic is the common input heuristic.  If they're spent together, they're
likely held by the same entity.  But yeah, I have not looked at this
specifically.  Let's leave it at that!

_Coldcard firmware 5.0.6 released_

**Mike Schmidt**: Cool.  Well, Rodolfo, I'll let you take this next one since
it's Coldcard-related.  We're talking about 5.0.6.  The changes that we outlined
here are actually 5.0.5, but there was a --

**Rodolfo Novak**: Oh, hang on, I have to look, I think there was another one
after as well.

**Mike Schmidt**: Well, the reason I put the 5.0.6, I think it was a fix, and I
didn't want to put a 5.0.5 if there was some sort of issue with 5.0.5.  So, this
is the one.

**Rodolfo Novak**: Yeah, so let me just open here the release notes.  Let's see
if I get the right one.  So, yeah, so the 5, we found a bug that could have
unknown exploits.  So, we fixed that one quickly and highly recommended people
to upgrade.  And then, we had to skip the features because they were not ready
for that release.  The 5 has the features, the 6 was a security fix.  So, the 5,
now you can derive passwords using BIP85, so that was a nice little improvement
there, very useful.

**Mike Schmidt**: Can you talk a little bit about BIP85 and what is the use case
here exactly?

**Rodolfo Novak**: Yeah, so BIP85 just defines a way for you to derive new seeds
from an original seed deterministically, right?  So for example, you say index
one, and you're going to get a new seed from the original seed.  And you cannot
go backwards, right, so the original seed is safe, you're not exposing the
original seed, but you get a new one.  And the index, I think we support up to
1,000 indexes.  So, the nice thing about this is most people who work in
Bitcoin, in the wallet development, or any sort of development, need to create a
lot of wallets and a lot of seeds, and you have to keep track of all of that,
and it's an absolute nightmare.  And the other thing is, most people in this
space also have multiple wallets in phones, for example, with less balance, with
balances that are not too big.

So, the idea, at least for us, the way we see BIP85 is, it's just a means of
generating seeds for places where you have less value so that you don't have to
create more backups.  So, I go on my phone wallet, I input this derived seed as
the seed for that phone wallet, and if I lose the wallet, or whatever, I can
always just reconstitute that wallet somewhere else by putting that same seed.
And we figured we could also make passwords from this.  So, if you have a set of
secure passwords that you want, you can create those passwords from the original
seed as well.  This is not ideal for your email, for example.  But it's more
like, I don't know, the password that encrypts your SSH keys, for example, or
things that are more important that you would go check on that Coldcard.  So,
yeah, we found it to be super-useful.  The users seem to really, really use this
a lot, so we wanted to just expand on it.

**Mike Schmidt**: Cool.  And then I saw that there was additional OP_RETURN
support and additional multisig descriptor support.  You want to talk a little
bit about those at all?

**Rodolfo Novak**: Yeah, I mean we were failing because -- I guess a little bit
of background.  Coldcard doesn't just sign stuff, right?  It does checks, sanity
checks on transactions to make sure that everything looks kosher and somebody's
not trying to do some obscure attack on you.  So, we try to catch a lot of
things that don't look right.  And OP-RETURN, because it's not something that's
used a lot, it was sort of getting caught in our defences, so we decided to just
essentially make that into a proper described feature in our tests for
transactions, so now it correctly does that.  Yeah, and then the multisig
descriptors, people are now using them, of course, so we wanted to properly
support and document that.

**Mike Schmidt**: Excellent.

**Rodolfo Novak**: Yeah.  And then from that list, we now import the scripts as
well.  And now on the address explorer, you can show change as well, which is
kind of nice as a sanity check as well for when you're doing very large
transactions.  So, yeah, that's that on the Coldcard, the last feature update.

**Mike Schmidt**: All right, I'll go through this last one in the newsletter,
and then I want to hear a bit about some of the things you guys are talking
about at Bitcoin Review and some other software that maybe isn't Optech
Newsletter material but is important innovations in the space, so I'll finish up
with this last one and we can move on to that.

_Nunchuk adds taproot support_

So, Nunchuk adds taproot support.  So, I had come across this in their mobile
wallet for iOS.  I am not 100% sure if it applies to Android as well, but there
was support added in recent releases for single-signature taproot, signet
support, and then additional PSBT support were added.  So, those are the kind of
things that I think in 2022 we're seeing more and more of.  The taproot signet
seems to be catching on and being implemented in a variety of wallet software.
And then, PSBT is quite important, especially with a lot of the multisig
catching on.  So, it was good to see that from Nunchuk.  Rodolfo or Murch, I'm
not sure if you have any comments on that Nunchuk update.

**Mark Erhardt**: Yeah, my understanding was that Nunchuk, from the get-go, was
targeted towards multisig users.  And I think originally they also were
considering launching taproot only, which I think, just given how the sending
support for bech32m is still lagging a little bit, might not be the optimal
business choice for any wallets yet.  So, yeah, I think before PSBT, it was just
super-painful to exchange half-signed or unsigned transactions, because
basically everybody was just using their own non-standard format.  And with
PSBT, there's now basically a maybe not perfect standard, but a standard with
which everybody uses the same language to talk about not-finalized transactions,
and I think that we, with a broader adoption of PSBT and descriptors, we will
see much more powerful and versatile wallets in the medium run.  Maybe it'll
take a little bit for people to come out with cool stuff, but we'll see very
cool stuff in the next few years.

**Mike Schmidt**: Murch, why would I want to use a single-sig taproot wallet?

**Mark Erhardt**: In my opinion, it is still economically advantageous to use a
single-sig taproot wallet, because if you're using P2WPKH, the output is
slightly cheaper and the input is more expensive.  And altogether, P2WPKH in
total is like 1.5 vbytes smaller than P2TR.  But if you are receiving to a P2TR,
the sender pays for the output, so they're paying the 43 bytes, and you're
paying only for the input, and the output is 57.5 instead of 68 vbytes.  So, you
pay less.  So, in my opinion, you should always receive to P2TR, and especially
if you don't know how long you're going to sit on UTXOs and they might need to
be spent later at high feerates, you should HODL in P2TR and not in P2WPKH,
because it will be the cheapest to spend.  And if multisig adoption and general
adoption of P2TR goes forward in a way like we've seen with segwit, where after
five years more than half of all outputs are segwit, you will have a very good
anonymity set eventually when you spend them.

**Mike Schmidt**: Excellent.  So, Rodolfo, I think in a previous discussion, we
had you on and we mentioned the Bitcoin Review project that you're working on.
Do you want to talk a little bit about that, and then also get into some things
that you guys have talked about recently that maybe aren't on our list for this
month?

**Rodolfo Novak**: Sure.  So, Bitcoin.Review, the podcast of it was kind of born
out of the frustration that I had with all the outcoiners, shitcoiners, saying
that nothing gets built on Bitcoin.  That was sort of really annoying because
Bitcoin has a lot of stuff being built.  It's just that a lot of the stuff being
built on Bitcoin is not full of scams, so they have less marketing dollars and
they don't get as much exposure.  So, I figured I'd make a huge, huge list every
two, three weeks of all the stuff that people are working on that's not
necessarily Core, and sort of do the laundry list, right, go through their
software updates, go through projects that are maybe not yet launched but are
being worked on.  And we do discuss some, of course, updates or coming updates
that are more related to client software, or things we're just interested in.

It's not super-structured except for the list and the domain is Bitcoin.Review.
I try to put all the stuff on the actual post notes as well so people can review
it.  And we did go over some Optech stuff as well in, I think, the first three
episodes before you decided to have a competing voice solution for Optech!

**Mike Schmidt**: Are you talking about the client service updates section?

**Rodolfo Novak**: Yes.  No, I was just joking.

**Mike Schmidt**: To be fair, we've had it for like a year or two.  But yeah!

**Rodolfo Novak**: Yeah, I know!  So, yeah, it's just nice to have people
discuss Bitcoin projects.  We don't see a lot of that, except for people doing
that on Twitter.  And the mailing list was a little bit unusable for a while due
to many discussions related to fees and other things.  And people tend to not
bring up client software on the mailing list either, right?  So, there just
doesn't seem to be a lot of amplitude to release and talk about client software.

**Mike Schmidt**: Well, thanks for putting that together.  I know that this
go-around, not only is there a podcast, but you guys also have a writeup, a text
version, and I actually used that as one of my resources this week, so thank
you, in conjunction with the @nobsbitcoin Twitter handle that also covers news
and some software updates.  It's good to see that there's a burgeoning community
trying to surface these newer innovations.

**Rodolfo Novak**: So, there's quite a lot.  Yeah, go ahead.

**Mark Erhardt**: Sorry, I thought we were finished with the topic!

**Rodolfo Novak**: Yeah, I think we are.

_Overview of channel jamming attacks and mitigations_

**Mark Erhardt**: Okay, well I wanted to announce that we managed to get Antoine
up here, and I think we could now start looking at the channel jamming attacks
and mitigation news item.

**Antoine Riard**: Yeah, hi guys, you hear me well?

**Mike Schmidt**: Yeah, we can hear you.  Do you want to give the folks a quick
introduction to yourself and your work in Bitcoin, as well as the work you've
been doing with Gleb?

**Antoine Riard**: Yeah.  Really quickly, I'm a Bitcoin Core and LDK
contributor.  I've been active in this space since 2018 now, and I've worked
mostly on Lightning security work, a bit of Bitcoin Core architecture, and all
that kind of stuff.  And today, I think we're going to talk about channel
jamming research, which is one of the most high-impact and long-standing issue
affecting LN.

**Mike Schmidt**: Excellent.  Well, I think it would make sense, Antoine, to
maybe walk through what you guys have written up, as I think it's also a good
progression from, "Hey, what is this attack?" to what are the costs, to what our
incremental solutions, to what are bigger picture potential solutions?  So,
maybe you could kind of go in that order and the folks have your website/book
up, they can follow along with that; and if not, it'll be a nice progression
just to listen along anyways.  Does that make sense?

**Antoine Riard**: Sure.  So, to provide more context, channel jamming was
started to be discussed on the mailing list back in 2015 under the name "loop
attack".  And for the ones who are not familiar with that type of attack,
basically in LN, you have a payment path and you have a topology of LN channels.
And the idea of channel jamming is instead of releasing a preimage to settle the
payments, your last hop is going to resolve the payments until almost the
CHECKTIMELOCKVERIFY (CLTV) delta expiration time.  And by doing that, you
prevent people to use this liquidity for other payments, and you are just DoSing
the network.

So, let's say you do have Alice, Bob, Carol, and Dave.  That's a payment path
which has been drawn by Alice, and Alice, in collusion with Dave, is going to
try to abuse the liquidity between Bob and Carol by sending a Hash Time Locked
Contract (HTLC) to Dave and Dave not settling the HTLC at all.  You do have like
multiple variants and optimizations about this attack, like you can do looping,
you can do balancing, and you might be able to target multiple hops at the same
time.  Do people have more, like Murch, more suggestions, or more talks about
first describing jamming?

**Mark Erhardt**: No, I think it's pretty good.  So basically, you're just
making a payment, and then instead of routing it, you keep it open for as long
as possible, and you lock up liquidity?

**Antoine Riard**: Yes.  As a fundamental reminder, lagging is like being on top
of timelocks, like between scripts, timelocks.  And the one you're using in that
case is a CLTV one, which is based on absolute time or absolute block height.
And in LN right now, you want the CLTV to be a few blocks ahead and you want to
increase this CLTV at each -- so that's a bit like theoretical how to get there
the first time, but the CLTV is going to decrease along the path to give a
buffer of time for payment hops involved in the HTLC to be able to set up the
HTLC on chain in the worst-case scenario.  And a channel jamming attack is based
on abuse of this CLTV time.

So, the attack has been demonstrated on mainnet a few times by a few people.  I
think Joost Jager have done some, Gleb has done some.  And you are able to
target anyone in the LN, because we're an open network.  And you might also be
able to do worse harm, like cutting or partitioning the network in multiple
subsets, by targeting the main link on the network and beyond partitioning the
network, channel jamming can be also used as a building block in like probing
attacks to denominize people, or any kind of resource exhaustion attacks.  Let's
say you're going to exhaust your watchtower credits, or to destroy other
people's reputations by making their LN service unavailable.  And so you do have
like multiple harms which can be done with channel jamming; liquidity DoS is the
main one.

From that, in that research we have done with Gleb, we have tried to come up
with a cost.  You know, first step, how much it costs for an attacker.  And so,
Murch, you know really well the mempool, so could you have ideas of what are the
cost factors for chain jamming attack?

**Mark Erhardt**: Well, so for example, of course, you have to actually have
some channel liquidity, and you have to have created channels in order to lock
up funds of other users, and you have an opportunity cost.  You could be routing
payments instead, you could be, I don't know, trying to leverage your bitcoin
holdings in another way instead of jamming users.  So, I guess the cost would be
that.  I don't know if there's more cost than that.

**Antoine Riard**: Yeah, I think I should cover all of them.  So, the first is
one I think you had forgotten we did integrate in our model, is the onchain fees
to, I'm not sure if it was raised, but the onchain fees to be connected to the
network.  And the other thing, if you're a hacker, you do have an edge because
you can open channels in low-fee periods and then leverage them to attack people
during high-fee periods, when it's more annoying to modify your channel topology
to react to jamming.  So, we do have onchain fees, we do have opportunity costs,
because basic liquidity could be used to route, to do honest running of HTLC and
earn watching fees.  And you do have also a minimum liquidity, which might be a
function of which implementation you're using.  Implementations might have a
lower bar, in the sense I'm not able to open a 2,000-sats channel.

Once you do have all those features, you're able to determine how it would cost
for someone to get someone from the network, or like I said, do more
network-wide attacks.  So, to give you quick numbers, we found out in function
of your jamming strategy network-wide, we found out it would cost you right now
to DoS the network, with March 2022 network data, like 418,000 sats in terms of
pure sat spends, and 2,000,820 sats by mass in opportunity cost.

**Mark Erhardt**: To jam the whole network, just 400,000 sats?

**Antoine Riard**: So, you would jam 20% of the channels --

**Mark Erhardt**: Oh, okay.

**Antoine Riard**: -- and you would be able to partition the network in a way
that's unusable.

**Mark Erhardt**: That's a little too cheap for my comfort!

**Antoine Riard**: Yeah.  Well, you would be able only to send an HTLC in your
own partitions, but I mean your routing algorithm is going to be confused far
before.

**Mark Erhardt**: Okay, so we have a little bit of a description of what jamming
actually means.  We've covered how low the costs are for the attacker.  What
sort of design space do you have for solutions against this attack; how can we
defend ourselves; can you give some points?

**Antoine Riard**: So, I mean, there is a first step.  First step could be like,
could we find easy-to-deploy solutions, like node-by-node and not networkwide;
that is one of them, we did explore a few of them.  One could be like --
basically with jamming, there are two types of jamming.  There is slot-based
jamming and amount-based jamming.  And with slot-based jamming, your goal as an
attacker is only to occupy all the HTLC slots of your target channels.  And
right now, it's 483 by default, but I think most of the implementations are
running with lower defaults, or at least for the LDK, I think we are around 50,
because you got other applications with dust and all that kind of shit.

But, one incremental solution could be to say, "Hey, we are going to
demultiplexify the number of slots on the fly".  And that way, you will increase
the liquidity requirements from an attacker to occupy all your slots.

**Mark Erhardt**: I think it would also help to, for example, have a minimum
HTLC, right?  Because if you try to jam all the slots, the idea is that you have
a huge number of parallel payments on the channel, which then would exhaust this
483 or lower minimum.  And if you don't route small payments, of course, they
have to put up more funds to jam your slots.

**Antoine Riard**: Yeah.  So, that's the main intuition on which is based on
other incremental solution, which is HTLC slots.  And the idea is you're going
to devise your whole HTLC slot space in range, and you're going to request a
higher level of HTLC amounts, or higher bare partition HTLC minimum amounts, and
that way you're going to also increase like the liquidity cost.

**Mark Erhardt**: Oh, yeah, that's a good idea.  You just progressively increase
the amount that you require for another HTLC to be occupied on your channel.
And that way, dynamically, you raise the liquidity requirement to exhaust slots.
Yeah, cool.

**Antoine Riard**: And there's like working progression rotations by Eclair, but
can you think about one downside of this approach?

**Mark Erhardt**: Well, if there's natural small payments occurring, you'd
obviously lose ability to do more of them.  So, it might be a fine line to walk
to actually be able to process all the natural payments but still be resilient
to a jamming attack.

**Antoine Riard**: Yeah.  I mean, you might argue against these solutions, like
we might decrease the throughput of small value HTLC, rather than across the
network.  And I think in long term, with the increasing price of Bitcoin, it
means more and more real-world users are going to be annoyed by this slot idea.
But even beyond that, this downside, it's just increasing the liquidity
requirements for the attacker, it's not like hard breakers against attackers.

**Mike Schmidt**: It also doesn't really increase the cost, just the liquidity
requirement and the opportunity cost.  So, we have this one solution approach.
I see that there was this idea of introducing fees before a payment goes
through, so fees for attempting to route.  Is that part of your solution set?

**Antoine Riard**: So, there's the family of solutions, known as upfront fees,
where basically, with channel jamming, we are wasting people's liquidity time
value.  We are provoking you to use your capital in an inefficient way.  And to
compensate against this risk, there is this idea of introducing an upfront fee,
which would be paid to cover the risk of routing fees not being paid _a
posteriori_, you know, after the fact.  And this upfront fee would be paid by
the HTLC sender, and each hop in its turn should pay an upfront fee for the next
hop.  And there are a few variations of this idea.  One is to make this upfront
fee space in whole at the start.  One is to make it pay a tiny amount for the
tiny amount, and then at each block or at each minute, to require people to pay
more.

There is also the idea of, with an HTLC payment pass, who is responsible for
setting the HTLC in this case here, is it the sender; is it the receiver; is it
someone like anyone among the payment pass?  And the really hard thing is like,
it's hard to assign them in Lightning.  You might be like super-honest in all
your HTLC sends, but the receiver might be dishonest or might be buggy or might
be lazy.  And that can be the same with hops.

**Mark Erhardt**: So basically, one of the biggest problems with the upfront
fees is that sometimes payments don't go through on the first attempt anyway,
and it will just generally make trying multiple routes more expensive, and some
people might actually grief just by sometimes failing unnecessarily just to get
the upfront fees without actually locking up funds at all.  So, the game theory
of it all is non-trivial, I think.

**Antoine Riard**: Yeah, it's confused.  We might misalign the incentives
between HTLC standards and routing hops.  Like I say, we do have a risk of
upfront fees being informed by dishonest routing hops, but that could be
compensated by reputations, by like more fancy scarring algorithms, like seeing
that someone is deliberately failing HTLC.  But more fundamentally, we think
that with upfront fees, you're just closing down the economic openness of the
network.  And since now for whatever, like you said, payment path attempt, not
success, attempt, you are going to pay.  And a lot of people might see this as a
UX burden and as too high an economic burden for all the HTLC senders.

**Mark Erhardt**: So, between the three solutions that we sort of got into,
making just the liquidity requirement higher, charging upfront fees, and I think
we touched on reputation a little bit now, none of the solutions are
super-enticing.  But the problem itself is also maybe currently not enough of an
issue that we need to hit it with a hammer immediately.  So, it's sort of like
you have something like four things that you can suffer through and which is the
least bad, right?

**Antoine Riard**: What's your question exactly?

**Mark Erhardt**: I'm just recapping.  I think we also need to -- do you have
something else that you want to add?  I think we might want to take a few more
minutes for the last items.

**Antoine Riard**: For sure.  So, I think you're raising an interesting point,
seeing like right now we don't see this happening.  But on the other side, right
now, no one is making money on routing fees, or not real money, or not enough to
cover cost of exploitation.  And the day where routing fees start to be more a
market, it's going to increase incentives for people to DoS, like competitors,
because all the routing hops are in competition on the network, in theory.  But
there are at least two other trends which might change the game.  It's one, you
know currently we're seeing people like starting to specify Lightning Service
Provider (LSP) services, like instant channel, in-bound liquidity, and all that
kind of things, and offline receive.  And an LSP might attack each other.  They
might just try to economic outlaw the competitions with channel jamming.

In the really same way, we have seen like this trend in Minecraft Servers.  If
you're curious, Minecraft Server has been really competitive and has been like a
Wild West, where people are just trying to do P2P attacks or attack cloud
servers to turn down other people's services.

**Mark Erhardt**: Yeah, that's an interesting point to say, that as the market
or the service industry gets more involved and there's more money to be made,
that there's more incentive to attack.  And obviously we want to think about
that in advance and have ideas about what the game theory will be like.

**Antoine Riard**: And really quickly, there is like a real second trend, like
you know people might be familiar with Discreet Log Contracts (DLCs), or they
might be familiar with PeerSwap, or they might be familiar with fidelity bonds,
bets, HTLC or other invoices.  And all those LN use cases are using long, old
CLTV delta, or lengthy CLTV delta for the use case.  Let's say you're doing a
DLC and you're betting on the results of the next NBA game next month.  And to
do that, you might lock up liquidity for a month.  And from what your viewpoint
is, seeing as an honest user of the liquidity; from the viewpoint of the routing
hops, it's just going to be like a spontaneous chain, without any maliciousness
intentions, you know?

So, DLC people would like to deploy on top of LN, a lot of people would like to
deploy more advanced use cases on top of LN, and we might be at the point where
if we don't solve change handling, people are not going to use capital
efficiently on LN due to new use cases.  And those use cases are just going to
-- if DLC are not paying for the length of the CLTV data they're using, they're
just going to outlaw simple payments.

**Mark Erhardt**: Yeah, although I mean in your example, of course, if there's a
settlement time of more than a month, the routing hosts might have already a
maximum HTLC timeout that they accept.  Okay, thank you for joining us.  I think
we might go back to the Notable code and documentation changes and Releases.
What do you think, Mike?

**Mike Schmidt**: Yeah, that sounds good, as we have just a few minutes.
Antoine, thank you for joining us.  You're welcome to stay on and opine on some
of these LN updates as well, but it's very valuable to get these experts like
yourself opinion on these items.  And I applaud you and Gleb for putting
together this piece of research and also doing it in a way that's fairly
accessible to everybody.  So, thank you.

**Mark Erhardt**: Thanks.

**Antoine Riard**: Thanks.

_Bitcoin Core #25504_

**Mike Schmidt**: In terms of Notable code changes, the first one we have here
in the newsletter is Bitcoin Core #25504, and it's a change to a bunch of the
RPCs to include additional information in the RPC response.  And in this case,
it's adding the descriptor to the output.  So, right now, address information is
included in these RPCs, but the descriptor that was used to generate that output
is not included.  So, what this change does is it adds another field which
includes the descriptors of the associated address, or output, to that RPC so
that you can see which of the descriptors, the parent descriptor, was
responsible for that particular address.  Murch, anything to add there?

**Mark Erhardt**: Yeah, so this is mostly RPCs that list transactions or which
addresses or UTXOs got credited.  And the idea here is, of course, if you have
multiple different descriptors, which seems very likely to be more common in the
future, with watch-only descriptors and the hardware wallet interface, then
you'll still be able to figure out, "Oh, where does this UTXO actually belong
to?"

_Eclair #2234_

**Mike Schmidt**: Cool.  The next update was for Eclair #2234, and we've covered
this, I think, in a previous discussion, but support for adding a DNS name.  So,
I think when we covered this previously in BOLTs 911, that the motivation was
that, yes, there is some information being provided via the gossip, but one way
to sort of validate that would also be able to be looking some of these things
up via DNS to provide an additional check.  That's my understanding of these
sets of changes and Eclair has implemented that in this PR.  Antoine, I'm not
sure if you have a comment on this whole looking up via DNS.

**Antoine Riard**: No, not this one.

_LDK #1503_

**Mike Schmidt**: Okay, we can move along.  The next one here is LDK, which
maybe Antoine is a bit more familiar with, and that's support for onion
messages.  And onion messages is also sort of a prerequisite to supporting
offers.  So, Antoine, do you want to talk a little bit about onion messages and
offers?

**Antoine Riard**: For sure.  Onion messages, basically we did introduce onion
message in LN to route an HTLC in a privacy-preserving way, in the sense of
neither the receiver nor the payment hops should be able to guess who is the
sender.  And to do that, we just reinvented what Tor is doing somehow.  And at
some point, people were interested to send messages.  We started to see some
applications sending messages across the network with zero HTLC or 1-sat HTLC,
or failing HTLC.  And people at some point were interested to abstract this
onion message to carry on more lagging written information.  And one of them is
offers, which is an upgrade of invoice, and which is adding a bunch of new
features, like reasonable invoice, proof of payers, proof of payers' keys to
associate even from not the key, I guess, and a bunch of other features which
are available on the BOLT12.org website.

That will be like an overhaul on the way we're doing payments, requests, on the
LN today and move from a bunch of different standards towards something unified
across implementations.  And that is a work in progress in all implementations.

**Mark Erhardt**: If I may, so if you want to pay somebody on the LN, you
generally cannot just send them money, because it's not like onchain where it's
non-interactive, but you do have to have an invoice for the recipient so that
they'll actually know later --

**Antoine Riard**: You do a keysend.

**Mark Erhardt**: Yes, I was going to get to that.  So, so far, you do it by
keysend, where you basically just encode all the information that the recipient
needs to cash in the payment in the last hop.  And when the receiver peels that
last onion back, they learn the secret with which they can execute the payment
so that the money gets pulled in.  The problem with that is that the sender
already knows the secret that the recipient is going to use to initiate the
payment cascade, and that is usually the proof that the payment has happened.
So, in a keysend payment, there is no proof of payment.

With an offer, you basically have now an in-network way of asking a receiver,
"Hey, could you give me an invoice?"  They send back an invoice, then you make a
regular payment, and now you have an invoice and a proof of payment.  And the
sender can initiate the payment still.

**Mike Schmidt**: And so, the onion messages are the mechanism by which a
communication outside of just payments is coordinated on the LN to facilitate
things like offers, but also potentially other types of non-payment messages.

**Mark Erhardt**: Exactly.

_LND #6596_

**Mike Schmidt**: Cool.  Next item here is LND #6596, which is just a new RPC
that lists wallet addresses and current balances.  I think that is more of a
convenience thing than anything for folks using LND, to just use LND and not
have to use LND for some things, and then a node RPC to get additional
information; that seems to be the motivation there.  I don't know if anybody has
comments on that; fairly straightforward.

**Mark Erhardt**: Let's move on.

_BOLTs #1004_

**Mike Schmidt**: Great.  The last one is a BOLTs update, BOLTs 1004,
recommending that nodes maintain information about channels at least 12 blocks
after a channel is closed, and this is in support for detecting of splices, when
a channel isn't actually closed but there maybe are funds being added or removed
from that channel in an onchain transaction.  So, this is maybe another
opportunity to have Antoine talk a little bit about maybe not just this BOLT and
the 12-block wait, but also what's going on with the splice.

**Antoine Riard**: So, really quickly, the splicing and the idea of you like to
add liquidity capacity in a channel, or exit liquidity capacity because you're
not using the full rate of it.  And what you're going to do is you're going to
have like a transactions, either spending the funding outputs and splitting the
funds in two outputs, one to carry on the channel operations, and the other ones
to exit funds; and you might have an output and that's splice-out, or you might
have a splice-in where you're going to spend a funding output and you're going
to spend another UTXO that you want the value to be added to your channel, and
that's splicing.  And with both those cases, we would like the channel
reputations to be carried on across the splice for the routing algorithms.

Right now, the routing algorithms, we are going to use a scriptPubKey to
identify the channel.  And if your channel is behaving well, you can assume that
a splice channel is still going to behave well and you would like to keep the
score high.  And to do that, I think that's the idea of BOLTs 1004, where you
have to wait 12 blocks before getting the information about it.  And during
those 12 blocks, you should expect a new channel announcement or updates about
the splice.  I think that it might not be correct because it's still work in
progress.

**Mike Schmidt**: Excellent.  Yeah, thank you for the color there, Antoine.
Murch, anything to add on splicing?

**Mark Erhardt**: Yeah, maybe I'll try to recap for people that are not familiar
with it.  So, when you close a channel, usually the funds go to the two channel
participants, but what if you have most of your funds locked up in channels and
you do want to do an onchain payment, then you might want to do a splice-out.
So, instead of closing a channel, waiting for your funds to be spendable, then
creating an onchain transaction to pay someone, and then after that opening a
new channel, potentially even with the same channel partner, you basically use a
shortcut; and one of the two outputs of the closing transaction directly creates
a new channel, the other one pays the splice-out recipient.  So, you save on
blockchain data, you save on fees, and you immediately reconstitute your
channel.

With a splice in, it's similar, except that you use funds to add to the balance
of the channel.  Although I guess in that case, you could also just open a
second channel with the same participant, although not all implementations
support that.

**Mike Schmidt**: Well summarized.  Murch, anything else to add for this week?

**Mark Erhardt**: No, I think we're through, right?  Also, yeah, no, that's it.

**Mike Schmidt**: All right.  Well, Antoine, thank you for creating what appears
to be a burner Twitter account to be able to join us today.  Rodolfo, likewise,
thank you for joining us.  Murch, as always, thank you for co-hosting.  And look
forward to having you all join us for #215 next week.

{% include references.md %}
