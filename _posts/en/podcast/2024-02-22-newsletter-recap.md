---
title: 'Bitcoin Optech Newsletter #290 Recap Podcast'
permalink: /en/podcast/2024/02/22/
reference: /en/newsletters/2024/02/21/
name: 2024-02-22-recap
slug: 2024-02-22-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao, callebtc, Chris
Stewart, Fabian Jahr, and Pierre Corbin to discuss [Newsletter #290]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-1-22/aa90925c-3b18-c697-cfa2-fea619b81143.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #290 Recap on
Twitter Spaces.  We've got a nice slew of news items this week to talk about: a
BIP for DNS payment instructions, a discussion about incentive compatibility and
mempools, Cashu and ecash systems, a draft BIP for OP_INOUT_AMOUNT, updates on
the ASMap project. and a few interesting updates to applications building on
Bitcoin.  Thank you all for joining us.  I'm Mike Schmidt, I'm a contributor at
Optech and also Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Hey, Gloria.

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core and I'm sponsored by
Brink.

**Mike Schmidt**: Calle?

**Callebtc**: Hey there, everyone, I'm Calle, how are you doing?

**Mike Schmidt**: What are you working on, Calle?

**Callebtc**: Oh, sorry.  I work on Cashu and other Bitcoin-related things,
mostly Lightning, but these days I focus a lot on Chaumian ecash and Cashu.

**Mike Schmidt**: Chris?

**Chris Stewart**: Hi, I'm Chris, I'm an independent Bitcoin developer and I've
been working on a project called Where Is The TLUV lately.

**Mike Schmidt**: Fabian?

**Fabian Jahr**: Hey, I'm Fabian, I work on Bitcoin Core as well, and I'm also
sponsored by Brink as well.

**Pierre Corbin**: Hi everyone, I'm Pierre Corbin, and I'm CEO and co-founder of
Flash, and we're building on the LN but using Nostr Wallet Connect, and yeah,
doing some cool stuff I'm excited to be talking about.

_DNS-based human-readable Bitcoin payment instructions_

**Mike Schmidt**: Well, thank you all for joining us.  For those following
along, Newsletter #290, we're going to go through the news items sequentially
here, starting with DNS-based human-readable Bitcoin payment instructions.  This
is similar to a topic we talked about in Newsletter #278 with Bastien, about
trying to encode payment instructions in DNS.  This week, we covered a post by
BlueMatt, posted to the Delving Bitcoin Forum, and his proposal is for mapping
something that looks like an email address into a list of payment instructions
for someone that may want to pay that person.  And the idea is that this
human-readable address would be converted through DNS records into a BIP21 URI.
Murch, maybe you can chime in here and give us a breakdown on what is BIP21 and
maybe how it fits into this idea.

**Mark Erhardt**: Yeah, so BIP21 specifies a form by which you can use a Unique
Resource Identifier (URI) to refer to a Bitcoin address or multiple different
ways of getting paid by Bitcoin.  It's a really old BIP that basically just
allows you to make, well, it's what our QR codes are based on, because the QR
codes encode this format with bitcoin: and then the Bitcoin address and the
diverse other types of addresses that we can have in there.

**Mike Schmidt**: So, it would be quite inconvenient to pass around a static URI
with this bitcoin: and then maybe a Bitcoin address and some other query
parameters, not to mention that you wouldn't then be able to update that giant
string.  So, it's inconvenient and it's something that you can't update.  So, it
sounds like Matt's proposal here is a way to use DNS to sort of look up a record
containing that BIP21 URI.  So, I guess the person who represents the payment
information could, in theory, be updating their payment information if their
address changes, etc.  Murch, yeah, go ahead.

**Mark Erhardt**: So, on the one hand, yes, it's very long, it's not
checksummed.  So, you'd have the issue, "Is what I see in my browser really what
the other person wanted me to see?", for example.  Whereas in DNS, I believe
that the DNSSEC information is actually signed.  I know nothing about this, I
only read the discussion, so if anybody knows more, they can chime in any time,
please.

**Mike Schmidt**: And so, there is some sort of signed record in DNS.  This is
the text record that contains the BIP21 URI.  Maybe we're a little bit unsure
about how that's signed and how you would authenticate that that text record
corresponds to that person.  I guess maybe they would put some sort of a key
somewhere to be able to validate that.  We have an example of what the BIP21 URI
might look like, including a bech32m address, a silent payments address could be
in there, and then there's also an example of a blinded path for an offer.
Along with the BIP that's been proposed, there's also a BOLT proposal from that,
which defines a mechanism for mapping human-readable names to LN authors.  And
then there's also a BLIP from that that proposes two new onion messages, related
to querying these DNSSEC-signed proofs that we talked about, of the text records
for a given domain.  So, it seems cool.  It seems like something we should have
had a while ago.  Maybe that's just hindsight, but it seems like a great idea to
me.  What do you think, Murch?

**Callebtc**: Oh, can I comment on this as well?

**Mike Schmidt**: Of course.

**Callebtc**: So, I also really like this proposal.  If I understood correctly,
it would also allow to host many different payment destinations on a single DNS.
So, you could build a system with many users, supporting many users basically,
each with their individual entry of how to actually send the payment.  However,
a little criticism towards this, and also since I kind of assume that this is
also motivated by the fact that we are using LNURL today, and where you will
need an HTTPS server to also be serving this payment information.  Here in this
case, you obviously don't have this HTTPS server.  However, one problem I can
see here is the propagation of DNS across the planet.

So, this is a process that is highly uncontrollable and not really predictable,
which part of the world will get the update at what time.  So, I can imagine
this can also cause a little bit of a conflict when you're updating these
records.  Say you're changing your payment information because your address is
unsafe now and you want to change your onchain destination address to a new one,
so how do you make sure that the person requesting that DNS information actually
has the most up-to-date record?  I can see some issues there.  I guess this is
just related to how DNS itself works.  But in general, this is, of course, a
great idea to follow up on.

**Mark Erhardt**: Yeah.  I hadn't even thought about what Calle just mentioned.
That makes sense to me.  I think the DNS information doesn't necessarily
propagate fast, so the suggestion that came up in the discussion thread, to
frequently update this with a new address, doesn't necessarily make a ton of
sense to me.  So, on the one hand, one of the areas that I see an issue is,
BIP21 requires you to have an onchain address in there, and essentially this
would mean, (a) anyone that can see your DNS record knows who exactly got paid,
and (b) it would encourage address reuse.  It makes a lot more sense for
reusable address codes to me, such as the silent payments information or a
BOLT12 invoice, so stuff that doesn't have to change, that you don't have to
update the use at a single time and then it just lives there, which is sort of a
little in conflict with the BIP21 spec so far, which requires that you have an
onchain address in there too.  But maybe we can just move on past that and only
put silent payments, BOLT12 stuff in there.

**Mike Schmidt**: Calle, is there anything applicable to some of the ecash
system work that you've done that would work or not work with BIP21 URIs?

**Callebtc**: To be honest, we don't have any identifiers right now in the whole
ecash ecosystem because the system works without identities basically.  But what
we have been doing these days mostly is sending ecash to npubs, so Nostr public
keys, because Nostr gives you identity and the network at the same time.  So,
many complicated solutions would be possible to reach someone and actually give
them a bearer token in the form of ecash.  But it turns out the most simple
thing,

and with the best user experience right now, is to just take ecash and encrypt
it and send it to a user over Nostr.  So, we are currently using Nostr and Nostr
public keys as identifiers, and not DNS-based identifiers.

_Thinking about mempool incentive compatibility_

**Mike Schmidt**: Next news item is titled, Thinking about mempool incentive
compatibility.  This item was motivated by Suhas' post to Delving Bitcoin about
how full nodes might think about accepting transactions into their mempools,
which transactions to relay to other nodes, and which to mine to maximize
revenue.  Gloria, I know you've done a lot of work in research about this topic,
so thank you for joining us.  Maybe to start, how would you define and think
about incentive compatibility, and then maybe we can discuss some of the
insights from Suhas' post?

**Gloria Zhao**: Sure, yeah.  I think actually, this is a good time to plug the
Waiting for Confirmation Series that Murch and I wrote last year, where I think
this is chapter 2 where we've kind of framed the purpose of mempool as this
cache that is useful for a miner for you to have this cache of unconfirmed
transactions that you can then use to build your blocks.  And of course, if
you're not mining, it's a cache for what might come in blocks.  And so when you
have a cache, one very important question then is how do you measure the utility
of each item in your cache?  And that's where incentive compatibility is, I
think, the best metric, where if you're a miner, you're interested in maximizing
the fees of the transactions that you include in your block.  So, of course, you
want high fee/high feerate transactions.

So, incentive compatibility, I think, often comes up when we're talking about
replacements, because if we have two inconsistent transactions, ie they spend
the same input, so they're double spends of each other, they cannot be consensus
valid in the same blockchain, we're only going to decide to keep one, and we're
going to try to keep the most incentive compatible one.  But that question is
very difficult to answer with very basic functions.  So for example, in the
post, Suhas talks about comparing based on feerate and talks about comparing
based on absolute fee.  And so, I think kind of some immediate problems that
come up are, when trying to answer this question, it also depends on what the
hashrate composition is; as in, if you are a very large miner and you can expect
to be able to mine with high probability the rest of the transactions in your
block, you might make a different decision from if you're a very small miner,
and if you leave anything in the mempool, you might not really expect to mine
that.  That's, I guess, kind of a subtle thing.

But the other thing that makes it hard is, it's like 2D knapsack.  It's this
bin-packing problem where if you have, I don't know, 100 MB worth of
transactions in your mempool, excluding metadata, etc, it's very difficult for
you to create this exact ordering.  But anyway, I think very early on in the
post, we go into what I think is a quite intuitive way of visualizing how you
might want to prioritize these transactions.  So, if you were to make a feerate
diagram, where on the x-axis you have size, and on the y-axis you have fees, and
you go through all the transactions in your mempool -- I'm trying to simplify
this as much as possible, so I'm leaving some things out.  But each time you
"add a transaction", you can find the point of the cumulative transactions
you've looked at and you find the total size and the total fees, and then you
can kind of draw this line that's going up and to the right of the fees that you
can get from everything in your mempool.  And from this kind of formulation,
this visualization of how incentive compatible are these transactions, you can
then start to compare different versions of your mempool.

Or, you can start to try to take chunks of the first 10 MB or the first 4 MB, or
whatever, of your feerate diagram, you say, "These are the best transactions",
or you take the end, and you're like, "These are the worst transactions".  Of
course, it's very back to this cache utility metric idea.  It's very useful to
be able to say, "These are the best transactions and these are the worst
transactions", so if we're going to evict things from our cache because it's
growing too large, we evict from the bottom, and when we're building a block,
we'll select from the top.  And so, yeah, I don't know if this helps provide
much context, but if you think of this as kind of a story as to how we can get
to cluster mempool, it's like, okay, you have this feerate diagram, you have
this intuitive idea, and hopefully this makes sense as a way for people to think
about incentive compatibility, how would you then implement that?

Then you start looking at design questions and you're like, "Oh, wait, hold on.
We don't actually need to build the feerate diagram for the entire mempool.  We
can just look at the connected components.  Why don't we call it a cluster?
Okay, let's look at the computational complexity of doing these kinds of --
building the feerate diagram or building the linearization.  Okay, we need to
limit that computation, therefore you need a cluster size".  So, I think this
post kind of helps in the narrative of all roads lead to cluster mempool,
essentially.  But that's kind of my take on it.  If, Murch, you want to add
anything, or I see Greg's here as well.

**Mark Erhardt**: I think you covered it almost entirely already, so I don't
have much to add.  I just see that with the three transactions, obviously, and
the proposals for cluster mempool, there's been quite a bit of discussions and
also some alternative proposals brought up.  And I think it's good to lay out
the whole landscape on what motivates us, what the reasoning should be that we
use to decide which of those proposals to move forward with and what the issues
with other proposals might be.  Yeah, so if you want to study up on the on the
context in which cluster mempool and replacements and v3 transactions and so
forth are to be considered, then this is a very good overview.

**Gloria Zhao**: Yeah… sorry.

**Greg Sanders**: Sorry, it was unclear to me.  I just wanted to comment on, I
thought the post was really interesting from the perspective of how context
matters when selecting these transactions from the mempool.  Suhas gives a great
example of context being how much hashrate the miner actually has on the network
for transaction selection.  So, is the thinking there then we would ship
different sorts of transaction selection algorithms depending upon the context
that you're mining under, or does anyone have thoughts or an answer to that
question?

**Gloria Zhao**: I think that's mentioned as one of the pieces, one of the types
of complexity that's largely ignored.  So, there are a few things that are
smoothed over in this modeling, in my opinion, including that where it's like,
let's not talk about the games that you play with the rest of the mempool after
you've made this block.  And then another piece is like, let's assume that the
bin packing that we're doing is such that the items we're putting into the bins
are significantly smaller than the bin itself, ie the maximum standard
transaction is quite a bit smaller than the block size, because as the ratio of
that gets closer to 1, this problem gets way more knapsack-y and intractable to
solve in this intuitive feerate diagram kind of way.  And I see, Murch, you have
your hand up.  But I think I just want to point out that there are a few items
that are like, yeah, this makes things way, way more complicated to think about,
but this is managing to be comprehensive-ish while kind of ignoring these, I
don't know, edge pieces of the complexity.

**Mark Erhardt**: I think that the example on miners potentially having
different motivations regarding two incomparable conflicting transactions, which
one they would prefer, I think this was mostly meant as a context for evaluating
proposals, and we should prefer a proposal in which we only accept, well, (a)
comparable transactions that are better to replace comparable transactions that
are worse, and (b) how some other proposals that have been made are sort of
failing to always replace the -- or only allow replacements in the right
situation.  So, when you make assumptions on what is better, that only match for
larger or smaller miners, you are going to hurt decentralization because, well
generally, if you are a larger miner, you can behave like a smaller miner, but
vice versa, that's not possible.  So, we always have the issue that there might
be something that serves a bigger miner better, and to avoid this sort of stuff
should be a central point in our replacement protocol.

**Mike Schmidt**: Hey, Greg.

**Greg Sanders**: I'm trying to decide if Murch answered everything.  I think he
came pretty close.  Part of it was this discussion about, I think it was brought
up, the discussion about how things farther in the mempool, like for example, I
think Gloria was mentioning the size; so, if something's outside of the next
block or it's timelocked or something, what are the incentives there?  And it's
just saying that we can't make all the decisions based on this local
information.  There's information outside of the system that would drive the
incentives, the overall incentives, and so we have to be aware of that.  And I
guess my next question would be, and maybe we intentionally don't want to
support this, but with the cluster mempool work, is there any concept of
bringing your own transaction selection algorithm and doing what's optimal for
your particular use case; or, is cluster mempool designed in such a way that
it's transaction selection algorithm specific, I guess, is maybe the best way to
put it?  Go ahead, Murch, I see you got your hand up.

**Mark Erhardt**: Oh, I did want you to finish your question first.  But the
idea is basically that with cluster mempool, since you have already an optimal
order inside of the cluster in which you create the chunks from, that you can
just pick the chunks into the block.  And this is going to be at least as good,
but probably in most cases better than ancestor-set-based mining, which we
currently use, because you can also collect chunks in which, for example, two
children bump one parent, and therefore you get a higher overall package feerate
for the set of transactions than either of the two ancestor sets of the children
would have had.  So, I think that cluster mempool will lend itself to a better
block building algorithm in itself just per its structure.

You could, of course, have something running where you keep conflicting
transactions out of your mempool and evaluate locally which one you would
prefer, due to criteria as we discussed with like, I'm a bigger miner and I'm
probably more likely to get the future block where I can include the other
transaction.  But for the most part, what we want to do is we want to ship a
block-building algorithm that is as good as possible so that miners do not have
to run custom software in order to maximize their profit, and therefore the
miners that have more know-how or more resources to optimize their block
building would not have a significant benefit over any miner that just turns on
their Bitcoin Core node.  So, the idea is to level the playing field as much as
possible.

**Greg Sanders**: Yeah, and I guess I think you mentioned optimal ordering in
what you just said there, and it sounds like the optimal ordering for a miner is
context specific, based on how much hashrate they have specifically.  So, I
guess I don't necessarily --

**Chris Stewart**: Sorry, that's for conflicts specifically.  If we're not
talking about RBFs at all, then the base algorithm should be optimal, assuming
you run the optimal sort.  Yeah, focus on the part with the conflicts; that's
where that part is elucidated.

**Greg Sanders**: Okay, I'll go read further on this and we can keep moving.

**Mike Schmidt**: Gloria.

**Gloria Zhao**: I just wanted to add a little bit to highlight something that
Suhas put in his post that actually wasn't one of the points in the Optech
coverage, which is, I kind of think of this post as the thing to silence all of
the whataboutisms on incentive compatibility, where essentially one of the
points where I think this came up, or maybe this is originally when feerate
diagram came up, was basically Suhas found these examples where miner score was
broken as an RBF incentive compatibility check.  So, we had been talking about
how individual feerate is not good enough, ancestor feerate or ancestor score is
not good enough, and then we came to miner score.  Even miner score, even if
we're able to compute it with cluster mempool, even that is not good enough
because there is a counterexample where you can find that, "Hey, actually it
doesn't really make sense to do this replacement, even though the miner score is
higher and the fee is, I think, either the same or a little bit higher".

So, that was for me what made this very, very nice to have a different
formulation.  And it amused me a lot to find that incentive compatibility, it
seems like it should be so intuitive, but all of the ways that we had been
thinking about it were not good enough until we looked at this feerate diagram.

**Mike Schmidt**: Gloria, one thing that I wanted to get your thoughts on before
we wrap up this news item was the last bullet from the insights from Suhas here,
Finding incentive-compatible behaviors that can't resist DoS attacks.  Maybe
just your two sats on that?

**Gloria Zhao**: I'm just reading it right now.  I guess, yeah, Greg do you want
to take this one?

**Greg Sanders**: Yeah, I think this is mostly talking about, I mean it could be
many things, but I'd say that it's mostly talking about pinning where the
anti-DoS protections are perhaps in conflict with incentive compatibility,
right?  So, with a feerate diagram check, well, with a limited version of a
feerate diagram check, you could check that a set of replacements is strictly
superior, up until the size of the replacing set, and it could be even much more
superior.  So, you could think the diagram dominates all the way up to the point
where it runs out of virtual bytes (vbytes).  But if it's trying to replace
something that is very large and low feerate, it might not suffice in the kind
of BIP125 rule 3 sense, where the ending diagram doesn't go up high enough at
the very end, even though it's just a lot of general bytes.

So, this might cause the incentives to be misaligned with the anti-DoS
protections, because in a sense pinning, kind of by definition, is a user or an
adversary trying to make sure that fees are not paid to a miner in a timely
fashion.  So, I think that's kind of what the inherent tension there is.  And so
basically, do these remaining anti-DoS protections incentivize people to connect
to miners; and if so, is there a way of generalizing this?  Otherwise, it could
be pretty harmful for decentralization.

**Mike Schmidt**: Murch, anything else before we wrap up?

**Mark Erhardt**: Yeah, I was going to try to rephrase what we just heard,
because I had a hard time sort of wrapping my head around it.  I think what you
were saying is, if our rules are too strict and we have such high standards for
allowing replacements that actually users could perhaps just give stuff to
miners out of band, and the miners would accept it because they would still deem
them better, that might be an issue.  Is that what you said?  Okay!

**Greg Sanders**: Yes, exactly.  There are a number of ways to look at this
problem, but pinning is one example.  Another could be, we reject a replacement
because it has lots of fees at the end of the mempool, but maybe the miner
doesn't care.  If it's a small miner, maybe they care more about fees higher up,
right, as we've discussed.

_Cashu and other ecash system design discussion_

**Mike Schmidt**: Great discussion.  We will move on with the newsletter.  Next
news item, Cashu and other ecash system design discussion.  User ThunderBiscuit
authored a post to Delving Bitcoin titled Building Intuition for the Cashu Blind
Signature Scheme, where he outlines the workflow of the ecash blind signature
scheme used in Cashu.  We have the original author of several projects around
Cashu, Calle here with us today.  Calle, Cashu has been around for a while now.
Why is Thunderbiscuit posting about the protocol design now, and what is he
getting at with this post?

**Callebtc**: Well, first of all, yeah, shout out to Thunderbiscuit.  He's the
reason that I'm here.  He would be here, but he has much more important things
to do, so shout out to Thunderbiscuit and congratulations if you hear me.  So,
this post by TB is an excellent, very mild introduction into the blind signature
scheme that we use in Cashu.  And maybe before I get into a bit, I'll try to get
everyone onto the same page.  So, Cashu is a Chaumian ecash system that we're
building for Bitcoin, and it works with Lightning, and it allows you to build
custodial applications, where the custodian gives ecash in return for an LN
payment.  And what the user gains is almost perfect privacy in exchanging these
tokens that can be exchanged as monetary units.

In order to build a Chaumian ecash system, you have to come up with something
called blind signatures.  And the most popular example, I'm just going to
shortly mention it, is this typical carbon paper example.  So, the definition of
a blind signature is that you can sign a document without actually seeing the
document.  And once someone presents you the document or the piece of data, then
you can recognize your signature.  So, basically, you can imagine it's someone
signing a contract with closed eyes.  And then next time someone presents them
the document with a signature, they can identify it.  And so this is the basic
principle, and with that, you can build a digital ecash system.  And that's what
TB explains in this document of how we do it in Cashu, based on secp256k1 the
standard elliptic-curve library that we also use in Bitcoin.

So, maybe a little bit of a background why this technique exists in the first
place.  So, ecash was invented by David Chaum in 1982, and the original
formulation of it is with RSA.  And RSA was under a patent for a very long time.
And David Wagner, who is also a very well-known cryptographer, then posted on
1996, I believe, is the post that is the basis for the crypto that we're using
Cashu today.  It's a post in the Cypherpunks mailing list where he says,
"Because of the patent on RSA, here is a version how you can do ecash with just
purely elliptic-curve math".  And funnily, I just looked it up, he also comments
on the patent on Diffie-Hellman, which is a technique that I'm going to talk
about in a bit.  So, RSA was on the patent, Diffie-Hellman was on the patent,
and we bitcoiners also know that schnorr was on the patent for a very long time,
which is why Satoshi probably started with ECDSA.  So, don't put a patent onto
your crypto scheme, please, if you're going to invent one in the future.  It's
just going to stifle innovation.  So, get back to the topic.

Wagner describes a way to make blind signatures using only elliptic-curve
cryptography on secp.  It's implementable on secp.  It's not described on secp
in the original post, but we can implement it on secp.  And the fundamental
basics of how this works is described in this beautiful post by TB.  And I must
admit, although I spend a lot of time looking at Cashu and thinking about Cashu,
I still could learn something in this post about the crypto that I didn't
realize before.  So, the way you can think of the signature scheme in Cashu, it
is called a blind Diffie-Hellman key exchange.  And TB explains in his post how
this key exchange is done.  So, when you remember how the normal Diffie-Hellman
key exchange works, it's, I have my private key and my public key, you have your
private key and your public key, and by combining my private key with your
public key, or vice versa, your private key with my public key, we can compute a
shared secret together that no one else knows.  And most of modern cryptography
end-to-end encryption is based on this principle.  So, this is the normal
Diffie-Hellman scheme.

What is interesting is here in this case, I want to compute a shared secret with
you, but I want to be able to prove that I don't know a private key to a certain
public key.  So, that sounds a little bit complicated, but if you remember how
you can generate a public key on an elliptic curve, usually you take a private
key and you multiply it with a generator point, and you end up with a public
key, and you can share the public key.  There is another way to get to a point
on the curve, which is called hash-to-curve.  This is something that you see all
around in cryptographic systems.  A hash-to-curve function is basically a
one-way function where you can put anything in, and what you'll get out of the
function is a random point on an elliptic curve.  So, it's very similar to a
normal hash function like SHA-256, where SHA-256 would give you just a random
32-byte array.  In hash-to-curve, you don't get a 32-byte array, but you get a
public key on the curve.

Here's the interesting bit that was also kind of a new "aha" moment for me,
which is if I give you a public key, so a point on the curve, and I tell you the
preimage to a hash-to-curve that produces that point, you can be sure that I
don't know the private key of that point.  So, again, there are two ways to end
up with a point.  One is with the private key and one is with the preimage to
the hash-to-curve.  And if I give you either one of those, so I give you either
the private key, then you can be sure that I don't know the preimage of the hash
to curve; or I give you the preimage to the hash to curve and you can be sure I
don't know the private key of that point.  And the cryptographic scheme in Cashu
makes use of this fact.  So, we produce a point, me and the mint can both
produce a point that is our shared secret, but the mint knows that I don't have
the private key to compute that point, and we can treat that as a signature.

So, he explains in his post how you can build an ecash system, we shouldn't call
it an ecash system, but rather an unblinded token system, from these very simple
and basic principles.  So, that will be a fully traceable cash system that
obviously isn't desirable, because the issuer, the mint, knows exactly which
token it gave out and collected back when it was redeemed.  But it helps to
understand how this Diffie-Hellman scheme can be used to make a cash system.

Now, the next step in this post, he outlines how you can blind this scheme,
because obviously you want to introduce privacy now into this scheme.  And the
privacy is, again, that the mint, when it produces the signature, will not be
able to tell, when you present the signature later, will not be able to tell
which event this was correlated to, which input it originally signed when you
redeem back the token.  And the way this is done is by slightly tweaking that
public key that the user shares with the mint.  So, the blinding scheme in Cashu
is a simple addition of another point onto your original point so that you kind
of tweak the message before you send it to the mint.  The mint then signs this
message and sends you back the signature, and you can tweak out the blinding
from the first step out of that signature.

What you get at the end of the day is a signature on a point that the mint has
never seen.  And with these two things, so the signature and the proof that you
can produce this point, so preimage to this hash-to-curve thing, you can take
these two objects as a coin, and this is an ecash token.  This is this 2-tuple
of these two objects, and you can then transfer it from a user to another user,
or back to the mint to then say, "Hey, mint, here is a signature that only you
could have produced, and you only produce these signatures whenever I pay you
Bitcoin on LN.  So, please take back your signature and pay me back the Bitcoin
on LN.  And that's how the withdrawal process in Cashu works.

So, again, if you're interested, might be interested in elliptic-curve
cryptography, I think it's a very good intro into learning what you can do with
elliptic curve in general and we'll tell you everything about what you need to
know in order to fully understand how the blinding and the signing scheme in
Cashu works, so a recommended read.

**Mike Schmidt**: Thanks for that overview, Calle.  And if you're interested,
obviously Calle made the callout to check out the post and some of the ecash and
underlying blind signature scheme technology.  And if you're interested, I
guess, in applicability of that more practically, you can check out Cashu, which
implements some of this technology, and play around with that as well if you're
less familiar with the cryptography but want to see kind of how this stuff
works.  Calle, thanks for joining us.

**Callebtc**: Thank you.  I just want to plug the website.  So, you can go to
cashu.space if you want to learn more and check out all the different libraries
and clients and everything that we have.  So, thank you.

_Continued discussion about 64-bit arithmetic and `OP_INOUT_AMOUNT` opcode_

**Mike Schmidt**: Next news item is titled Continued discussion about 64-bit
arithmetic and OP_INOUT_AMOUNT opcode.  Well, we had Chris on a few weeks ago
for Pod #285, and also highlighted his proposal in Newsletter #285, talking
about 64-bit arithmetic.  We can touch a little bit on that today, but also
refer back to that for a little bit more of a deep dive.  Chris, you also posted
recently a new discussion for a draft BIP for the opcode OP_INOUT_AMOUNT, which
is part of the original OP_TAPLEAF_UPDATE_VERIFY (TLUV), which you've begun
championing to a degree.  Why don't you set a little bit more context and we can
talk about the opcode and why it might be useful?

**Chris Stewart**: Yeah.  So, like you said, I really like this OP_TLUV.  I
think it's a huge leap forward in terms of usability or user experiences
possible with Bitcoin.  I think it really kills the communication complexity
that comes with coordinating a shared control of a UTXO.  With OP_TLUV, you can
now non-interactively join and leave a UTXO, so I really do think that's a leap
forward.  In terms of thinking about getting to OP_TLUV, the quote that comes to
mind is, "If you're going to eat an elephant, you've got to do it one bite at a
time".  So, when I talked a few weeks ago about 64-bit arithmetic opcodes,
that's kind of the first step in the TLUV journey, let's call it.

The second step is this OP_INOUT_AMOUNT.  So, in the TLUV post, when you're
having a user joining or leaving a shared UTXO, you want to make sure that they
take the correct amount of money with them.  So, if there's 1 bitcoin in a
shared TLUV UTXO, and maybe Greg has a 0.33 bitcoin in it, I have 0.33 bitcoin
in it, and Murch has 0.33 bitcoin in it, we want to make sure that they can only
withdraw the amount they contributed, or some sort of numeric calculation that
we all agree to in advance of how much money you can withdraw.  To get access to
that amount of money that's being withdrawn from a UTXO in the script
interpreter, you need an opcode available to push the funding amount of the UTXO
onto this stack in the amount that's being withdrawn, and that's exactly what
OP_INOUT_AMOUNT does.  It takes the amount that's funding this UTXO, so in our
case it'd be 1 bitcoin, onto the stack, and if I'm only allowed to withdraw 0.33
bitcoin, we need to have a check to make sure I'm not taking too much money out
of the UTXO.  If I could take, say, the entire 1 bitcoin out of the UTXO, well,
I'd be stealing Greg and Murch's money, so we don't want that.

The opcode itself is pretty simple in its current form.  It just pushes those
two values onto the stack so that you can then do numeric comparisons on those
values using the 64-bit arithmetic opcodes that I proposed a few weeks ago, and
have PRs out there on the Bitcoin repo for.  So, this is like a way of enacting
covenants in a slow way.  I don't know, going to my saying, "If you're going to
eat an elephant, do it one bite at a time", I do think this opcode is a little
less standalone than the 64-bit opcodes.  I'd be interested to hear from other
users, or other people thinking how OP_INOUT_AMOUNT can be used independent of
TLUV and if it'd be worth shipping it independently of a TLUV opcode.  I
definitely think it's worth shipping the 64-bit opcodes independent of the rest
of this stuff, and I have some thoughts on the 64-bit stuff that I just like to
drop in at the end here for the podcast listeners like myself, who listen to
these things after the fact of considerations that are going on in that 64-bit
world.  But I'll pause here in case anyone has questions about OP_INOUT_AMOUNT,
or thoughts on it.

**Mike Schmidt**: So, in the context of let's say a CoinPool or a joinpool,
you're sharing the UTXO, you are going to need a way to sort of keep track, I
guess, of balances to some degree.  And I guess that requires two things that
you are working on: one is the ability to push the amount onto the stack, and
that's OP_INOUT_AMOUNT; but also, that thing that you're pushing on the stack
also needs to be able to represent a bunch of satoshis, and thus we also need
64-bit values within Bitcoin Script.  Do I have that right?

**Chris Stewart**: That is exactly right, and that's kind of the motivation for
bumping up the limitations of the current opcodes we have in Bitcoin Script.
It's called OP_ADD, OP_SUB.  They all can take 32-bit arguments, if I remember
correctly.  And satoshi values can be up to, I guess, 51-bit values.  So, we end
up having some issues for larger UTXOs if we were to just have the current
arithmetic opcodes embedded in the script interpreter.

**Mike Schmidt**: Murch or Greg, do you have any commentary on 64-bit arithmetic
or this proposed opcode?  Two thumbs up.  All right.  Chris, did you want to
wrap up on -- oh, sorry, go ahead, Greg.

**Greg Sanders**: I guess this is cool to see an actual spec written up because
the old stuff wasn't thoroughly specced, which leaves a lot of interpretation
and room for that.

**Chris Stewart**: Absolutely, and I hope to get the ball rolling on this.  I'm
critical of people that are involved in the software deployment process in
Bitcoin.  I think it takes too long.  I hope if we divide these things up into
small pieces, we can get a good cadence going for deployment of enhancements to
Bitcoin, such as what I view as pretty uncontroversial things like 64-bit
arithmetic.  Just dovetailing on the 64-bit PR that I have out there, I want to
just put it on the record of what the design considerations are that are still
ongoing in that piece of work.

So, from feedback that I've got on Delving Bitcoin on the 64-bit PR, there's
still a choice to be made.  Do we want to support signed arithmetic or do
unsigned arithmetic?  And the most compelling thing that I've heard on that
front is, signed arithmetic can lead to undefined behavior in the C++ spec.  So,
unless we have a very good reason to support signed arithmetic, it's probably
safer to go the unsigned route.  So, if anyone has any use cases that would
require signed arithmetic, please let me know.

The other issue that's being discussed is encoding issues.  So, I'm an advocate
for switching to 8-byte encoding representations, or numbers in the script
interpreter.  That is not how things are implemented currently.  I would like to
see all of our numbers switch over to just static 8-byte numbers in the
interpreter.  I think it's simpler for new developers, especially to reason
about.  I think CScriptNum is just awful to work with.  My own personal opinion,
I believe CScriptNum comes from OpenSSL, funnily enough, as a wrapper around
OpenSSL numbers, I believe.  I would love to get confirmation on that.  That's
as far as I could get in the GitHub history.  I think it would just make numbers
nicer to work with forever.  I mean, there is a space trade-off there with not
having the ability to represent smaller than 8-byte numbers with smaller byte
values, so the blockchain size will grow slightly.  I think the numbers that I
ran is going to be like 20 basis points larger over the history of the
blockchain.

But anyway, so those are the two dimensions of design choices that still need to
be made on the 64-bit PR, is unsigned versus signed, and then encoding issues.
I'm definitely in the minority on the encoding side, so I might cave on that
front.  But unsigned versus signed is definitely something I'd like more
feedback on.  So thanks, Mike and Murch, for giving me the opportunity to talk.

**Mike Schmidt**: There's also an absolutely savage, for at least Bitcoin
Optech, newsletter content takedown of what assigned integers are and some folks
who may not be familiar with that in current events.  So, check out the
parenthetical for that dig.  Chris, thanks for joining us this week and thanks
for joining us a few weeks ago to explain what you're working on.

_Improved reproducible ASMap creation process_

Last news item this week, titled Improved reproducible ASMap creation process.
We have Fabian here, who posted to Delving Bitcoin about some progress that's
been made in being able to create an ASMap in a reproducible or potentially
reproducible manner.  I think maybe before we get into why we would need to be
able to reproduce that, maybe we can talk a little bit about what we're trying
to solve here, Fabian?

**Fabian Jahr**: Yeah, sure.  Thanks for having me.  So, a quick recap of what
really ASMap is and why we want to have it.  It's a feature that was merged into
Bitcoin Core something like four or five years ago by now.  But it's kind of an
underused feature probably because you need additional data and particularly you
need the actual ASMap data to use it.  And it is kind of a blocker because we
all know most people don't really change the defaults and, in addition to
changing the default, you also have to provide some data that you have to get
from somewhere, where it's not even that clear where you would get it from.
That's just not something that a lot of people will do, aside from really the
pros, I would say.  So, what's the issue that we're trying to solve with this
feature?

So, Bitcoin Core connects to 11 peers.  These are the outbound peers, and these
are really important to the node because you, as the node, decide who you
connect to.  So, these are really important for you to get the data that you
actually build the blockchain with, and your whole knowledge basically of the
whole network is really based on these peers.  And so, you really want to have a
diverse set of peers there to avoid potentially getting all the data from a very
similar source or even the same source, which has been researched and is named,
for example, eclipse attack.  You can look for that paper.  It's quite a
foundational paper on the Bitcoin Network.  So, what you really want to avoid is
then you can have peers that kind of look different or that have a different IP.
But the question is then what if all of these come still from the same source?
So, for example, if all of these nodes are hosted on AWS, and we know a lot of
nodes are hosted on AWS.  And so, if you are connected to 11 peers that kind of
look different because it's a different IP, but then all of these are hosted on
AWS, then AWS, if they decide to go rogue or if they are turned by the state, in
some way, that would be really bad for you, for your node.

That's why ASMap basically tries to go one level higher and tries to look at,
okay, what IPs are actually controlled by which entity?  And so, this is the
actual map part.  AS stands for Autonomous System.  That is basically a fancy
word for this entity, an entity that controls multiple IP addresses.  So, for
example, your ISP that you use at home for your internet is an AS and has an AS
number.  AWS is an AS, has an AS number.  And so, we try to use this map to
actually get the information of which AS controls which IPs.  And with that, we
can then try to get a more diverse set of peers by actually watching out that we
don't have all of these peers from the same AS.  Hopefully, even we have all of
them from different ASs, or at least we have multiple ASs in our peers.

The way this is solved currently by default in Bitcoin Core is just looking at
the IP addresses themselves.  The IP addresses in general, very roughly from
left to right, kind of become more specific in terms of the location where they
are or who controls them.  But this is really not that straightforward anymore
because these IP blocks have been traded around for a long time and there are
these huge entities that control really lots and lots of IPs, lots and lots of
IP blocks.  And so, that's why this heuristic isn't really that helpful anymore
to just look at the IPs.

**Mike Schmidt**: Fabian, if I'm to summarize, the ASMap is essentially a lookup
table for IP addresses.  So, I would essentially say, "Here's an IP address,
tell me who owns it", and it actually would give you, like, Amazon owns that IP,
and then I could look up a different IP address and it would tell me Google owns
that one, or this one's part of Comcast, or something like that.  Is that
essentially the function of that AS map?

**Fabian Jahr**: Exactly, yeah.

**Mike Schmidt**: Okay.  So now, we can at least have an idea, at least
according to the data providers for these, how the ASMap is assembled, which
corporate entities are managing those IP addresses so that we can choose ones
that are from different providers then.

**Fabian Jahr**: Right, yes.

**Mike Schmidt**: Okay.  Well, how do we build an ASMap?  Maybe we can get into
that.  Sorry, Murch, go ahead.

**Mark Erhardt**: Sorry, I was going to make a joke!

**Mike Schmidt**: Do it.

**Mark Erhardt**: So, as we all know, BlueMatt runs his own AS service.  So,
would that mean that he always manages to get a slot on every node he connects
to?

**Fabian Jahr**: Not necessarily.  I mean, just because he is an AS where a node
is running, he will have a good chance of getting many inbound connections.  And
maybe he changes the default of how many inbound connections he can have.  In a
world where all the nodes use an AS map, he will be a more desired node than a
node that is hosted on AWS.  But that doesn't mean that all the nodes will
connect to him.  Yeah, wasn't really a joke, I think.  Was a really good
question though!

**Mark Erhardt**: Okay!

**Mike Schmidt**: So, Fabian, maybe talk a little bit about how the data is
assembled, and why it may be challenging or not for you and I to query those
data sets and come up with something that looks like the same ASMap.

**Fabian Jahr**: Yeah, and this really has been a part of the research that I'm
doing for a while now.  So, how do all the different ASs that are on the
internet out there know how they reach the other ASs, basically?  This is really
how the internet works at its core.  And so, the ASs have routing tables
themselves, and these routing tables are built with BGP.  BGP is basically the
way that within the network of these ASs, they announce to each other, "Here,
I'm this AS, and I control this IP", or this IP block.  And you probably have
heard of BGP, even if you're not that interested in internet infrastructure, but
you probably heard about BGP leaks, BGP hijacks, and attacks coming from that.
There was a very famous one with YouTube taken down for a couple of hours.
There was also a very specific attack, I think, on MyEtherWallet a couple of
years ago that got very wide recognition.  And so, the reason why you hear of
these time and time again is because BGP doesn't have any security in its
protocol, and that's why it's also hard to trust it as a pure input source.  We
can just take any BGP dump from any participant of the network and use it as
this ASMap basically, or as the input source of this ASMap, but it's quite
problematic because of this lack of security.

Luckily, there are other sources that we can use.  The first one is RPKI, and
this is a really good callback to the first topic that we just talked about with
DNSSEC.  So basically, RPKI is very similar to DNSSEC in the sense that it is an
infrastructure to sign these BGP announcements.  And so, you also have a public
infrastructure there with trust anchors.  The trust anchors are the internet
resource providers, similar to how in TLS you have the root certificate and how
in DNSSEC you have the root certificate.  And so, you have a signature for the
BGP announcement, and with that you can verify that actually the entity that
controls the IP really is the one that made this announcement.  And so, this is
really good.  The only downside is that this is not rolled out 100% over the
internet.  So, recent numbers were like 75% to 80% in terms of coverage in the
space that we care about, so where actually there are Bitcoin nodes.  And so, we
need some additional sources for this data.

A secondary source that I propose to use is IRR.  It is basically a database
that is used for filtering.  So, it's basically the people that participate in
the BGP protocol, they can go to this IRR database and look at it and see, okay,
there's entries in there that say, "Okay, this is an announcement and it's
okay", and then they use this to filter this.  And then, we can backfill
basically the parts of the network that we cannot get from these two sources; we
can still fill with BGP announcements that we get from any source, basically.

So, what I've worked on over the last year is Kartograf, which is a library that
allows you to basically get the data from all of these three sources and then
joins them in order of priority, and that builds basically the raw input for
then generating the actual ASMap.  So before, it is already a map, but then to
actually use it in Bitcoin Core, we also have a further step where we run it
through a compression algorithm, and that actually makes it then a lot smaller
to handle.  So, we go from raw map 30 MB to compression under 2 MB.

**Mike Schmidt**: Awesome.  Yeah, thanks for walking us through that.  Okay, so
now I could potentially run this Kartograf software, and I assemble an ASMap.
And I could, I guess, load that in to Bitcoin Core and use my own, or if we're
looking to have this be a default, as you mentioned earlier people usually don't
change the defaults, then there needs to be some agreement by some individuals
that at least at this point in time, this ASMap was correct.  So, how do we get
there?  Can I look up using those data sources that you mentioned and using
Kartograf, say, on February 1, can I parse in February 1 there and get the ASMap
as it was then, or how do we do that based on timing?

**Fabian Jahr**: Yeah.  So, there was basically, a couple of weeks ago, the
status where Kartograf was working and you could use it to build your own map.
You can still do that if you just want to do it for yourself.  You can run it,
it takes three or four hours for the whole process, but then you have your very
own map that is very much up to date.  So, that is still possible.  But yeah,
for actually shipping a default with Core, that was quite a difficult question
because the data that we're pulling down there can change any second, and it
does change a lot.  This is really like the whole map of the internet.  You can
imagine that it changes quite a lot.  And so, if I build a map and then I tell
you, "Oh, just build a map, how about you also do it?" and then we see that it's
the same result, that's not going to work.

This was really very much an experiment, and I talked to people that work in
this area, actual internet infrastructure engineers, and they told me actually
this wouldn't work, but interestingly it does.  So basically, what we have now
in Kartograf is, you can give it a weight parameter with a specific timestamp,
and then it's going to launch at that specific timestamp.  And that means what
we can do in, for example, a GitHub issue is we can agree to all start tomorrow
at a very specific time, at a very specific timestamp, and then we just launch
our Kartograf and we can leave it alone, and it's going to just launch at the
exact same second on everyone's computers.  And that means we will not have a
perfect result with that, that everyone will have the same result, but what we
found over doing this several times with multiple participants is that there's a
very good chance that we will have a majority of people with the same result.
And that's already much better than I ever expected this would work.

So, that's basically the concrete process also that I'm suggesting now to arrive
at a map that is really not where we don't have to trust a single person or so.
I suggest that we regularly do a run of generating ASMap file, and a minimum
requirement would be that five people participate in this, and then that the
majority of people, so if it's five, then at least three people would need to
get the same result on their independent machines.  And that would be my
proposal of a result that can be trusted, that a majority of people got this
result.

Then basically, the really important part there is the input data.  So,
Kartograf starts out by downloading all of this data and then it processes later
to the result.  But really, the download step is the most critical one because
all of the rest is deterministic.  So, it's really important that this download
really starts at the same second everywhere.  Then the rest of the steps,
everyone else can also reproduce by getting this input data, this downloaded
data from somebody else.  There's also then something that we can do and we
could formalize it also a little bit more.  When there's something weird going
on, like somebody still thinks, "Okay, these three out of the five people, I've
never heard of these GitHub names.  All of them created their GitHub account
last week, maybe something's wrong", then you can still ask like, "Hey, can you
share the raw data with which you ended up at this result?" and then you can
reproduce it on your own computer as well, and you can inspect the raw input
data and make sure nothing fishy is going on there.

**Mike Schmidt**: Is there the notion of diffing?  Like, if I run it the next
day, let's say, can I diff against what the three people, let's say, exactly
agreed to and see that it's 99.9% similar, so I have a little bit more
confidence if I wasn't able to actually participate in the exact second that the
others were?

**Fabian Jahr**: Yes, you can do this, but the reason why I don't want to put
this as a standard procedure anywhere in the proposal is that this can be a very
dramatic difference.  So, that can be literally thousands, 10,000 lines that are
different.  And that doesn't mean that it's problematic or not.  It can just be
that AWS sells some IP blocks to Hetzner also, and then all of a sudden you have
a huge difference.  If you're just unlucky and that has been happening on that
exact same day, that is just going to look terrible.  And the bad thing is, you
cannot have some automated service or so that looks that up.  That would be then
really manual verification.  Really the only way to actually make sure that this
is really what has been going on probably would be to pick up the phone and call
AWS, and then it's really the question if they would actually give you that
information or not.  There's a chance that the diff is small and you would say,
"Okay, that's great", but even a small diff could also be problematic, could be
malicious.  But you could also have a very huge diff and that would require then
thousands of man hours and that's just not possible.

Basically, my suggestion there is if it doesn't work out, if something weird is
going on, we just discard it, basically like a PR where one or two people give
an ACK and they say like, "Here, I've a reason for suspicion," then it's just
discarded and then you start the process again.  And I think that's fine.  Like
I said, there's no guarantee that you get the same result for the majority of
participants.  And so, if I would take a guess now, it's one out of five times
we will not get the same result for the majority of people, and then you would
also just discard it and say, "Okay, let's start over".  It's just not a perfect
process, but that's, I think, the best we can do.  And as I said, it's already
surprising how good it works.

**Mike Schmidt**: I think it's an interesting topic.  Thanks for walking us
through this.  Anything else you'd like to add before we move on in the
newsletter?

**Fabian Jahr**: I mean, just basically the process then finishes with this
compression step.  The compression step also we have verified now that it's
reproducible as well.  So, there you would then, with basically the result that
you've gotten from the Kartograf process, you would open a PR where you say,
"Okay, here's the compressed result that I have", and then two or three other
people can also run the compression step and confirm that they also got the same
result as you, and then they give an ACK, and then basically this result can be
merged.  And then, for actually making the default and including it in release
in the future, the idea would be that basically, when we are coming close to the
release, then just one of the previously built ASMaps is picked from this
repository.  That doesn't have to be the latest one.  It could also be one that
has been there for a month and people have used it and say they saw no issues
with it.  That's obviously still up for discussion, but that's the way it would
work.

Then also what's possible, of course, then if the data is there, it's a lot
easier for people to just go there and download the latest AS map file and then
use it in their node.  Whereas before, there was just not really a source for
up-to-date ASMaps that people could just easily get and use and feel good about
it.

**Mike Schmidt**: Thanks for joining us today, Fabian.

**Fabian Jahr**: Thank you.

**Mike Schmidt**: Next section from the newsletter is our monthly segment on
Changes to services and client software.  We have four of these this week.

_Multiparty coordination protocol NWC announced_

The first one that we noted was titled Multiparty coordination protocol NWC
announced.  And, Pierre, thank you for holding on for us for an hour and 15
minutes.  Maybe you would be the best person to elaborate on what's going on
here and what is NWC and why do we need it?

**Pierre Corbin**: Yeah, of course.  So, NWC stands for Nostr Wallet Connect.
And so, I didn't create it myself, this you have to go reach out to the guys at
Alby, the Alby Wallet, but I'm using it and building an entire platform that is
a new payment gateway with it.  But essentially and kind of talking about this a
little bit at the beginning of how they're using Nostr for identification,
because of course you have the Nostr public keys and there's different NIPs that
were created, so a NIP is a Nostr Improvement.  It converts an LN address into a
public key as well as into an invoice, etc.

But what Alby created is this thing called NWC and essentially what it allows to
do is for LN wallets and providers that have a node, they can simply connect
their node to a relay, a Nostr relay, and they can map some of their node
functionality to Nostr events.  It allows, first of all, any wallet and node to
run whatever instance of LN that they choose, as long as they can have these
basic functionalities: create an invoice, pay the invoice, etc.  In the end,
each node is going to be sending to one another all this invoice and payment
information via Nostr events.  So, it allows to just fully standardize as this
communication layer using Nostr, which I think is very interesting.  And also,
just for app developers, it's game changing.  And the reason for that is because
if you want to develop on LN today, it's pretty complicated.  I mean, there's a
lot of steps that you need to take.  You need to be able to have your own LN
node, you need to have your own wallet, or if you don't have your own, well then
you're using software like the Breez API or what IBEX is proposing, allowing to
just very easily have all of this infrastructure.  But if you want to go more
custom, well then you have to take care of this yourself.  And it's difficult,
right?  So, running an LN node and making sure that you have the right
liquidity, all of this, I mean it's a business in and of itself.  And that's one
thing that LN wallets and providers need to do.

But on top of that, it doesn't end there.  They need to be able to add
functionalities.  So, they, of course, create their own software and their own
payment solutions, and whatever it is, and that's essentially how they can get a
competitive advantage over other wallets.  And essentially, what NWC allows is
to get rid of that part, because app developers can do all of this very easily.
So for example, with Flash, a user can log in with his Nostr keys and we're also
integrated with, I'll be creating that, it's called Bitcoin Connect.  And so,
it's a button and this pop-up appears, just like Wallet Connect works in the
crypto space, and you can choose the compatible wallets and you can connect to
an application.  Essentially you can add a wallet to your Flash account this
way, and the same thing can be used to connect into any other application.  And
NWC essentially is going to create this URL in which a user can choose a bunch
of stuff.  He can choose whether the app developer can use this URL to create
invoices or not, to pay invoices or not, to allow you the balance.

I mean, you can control everything as a user just with an interface.  I mean,
it's literally, check the boxes.  And it can even set a budget.  So, I think the
default on Alby is like 100,000 satoshis per month, and that's the amount that
you'll be able to spend using this NWC.  And users basically give this URL, they
give it to app developers, and app developers can do all of this stuff with user
wallets.  It's very easy to set up because the library is extremely simple, and
from that moment, you can do pretty crazy stuff that wasn't doable beforehand in
the LN space.  So, to give you an example, and that's some of the tools that we
have at Flash, we created the subscription plans, so recurring payments
essentially, because someone can just go on to Flash, fills in a simple form he
has connected his wallet prior to that.  And so, we have the possibility of
creating invoice for him.

Another user, so he creates a subscription, let's say, he adds it as a button on
his website, something like that.  And when another user comes and wants to
subscribe to it, well then he needs to log in.  He logs in through Flash, but
essentially, if you have Nostr private keys, then you already have a Flash
account, right?  There's an account that needs to be created.  And then they
connect their own wallet to it.  And with this, they give us the right to have
this limited control over their wallet.  And it means that we can pay invoices
for them.  So, if someone signs up, well then automatically we create an invoice
using the platform's wallet, NWC.  And then, using the same NWC that the user
just added, we pay that invoice and we save that information.  And so we say, if
the recurring payment is supposed to happen in a week, well then we're just
going to have a scheduler, it runs through it and we're going to do the same
thing.  Just one week later, automated payments and no one needs to do anything.
I mean, it's just there.

Of course the end user, I mean he can control his wallet connections directly
from his Flash account and he can delete them there.  But more importantly, he
controls this from his own wallet directly, so he can cut any kind of connection
there.  And I think it's, I mean first off, as I said, for app developers, it
changes, I think, everything.  It just makes it extremely easy.  But on top of
that, I think it has the opportunity of changing a lot of how the LN space
works, because I believe that there's two wallets that are fully integrated with
NWC; that's Alby and Mutiny Wallet.  But Umbrel is now compatible with NWC, so
is Start9.  So, there's more happening in the space and I know that a lot are
experimenting with it.  We can create new products that we couldn't before.

So, I think, little by little, all wallets are going to start integrating that
because a player like us, like Flash, we're not a new competitor for them.
Actually, we're quite the opposite.  We're bringing them more traffic, which is
pretty interesting.  It changes the landscape of how it looks like starting an
LN business today, because we're more joining wallets as partners.  And the
better they integrate with NWC, the better we can create tools that are
available for their users.  And we can just bring them more traffic and more
traffic for them means more fees and more revenue.  That's their business model,
essentially.

If I can add one more thing in my big rant, is the fact that I feel like I
forgot what I just wanted to say, actually.  Sorry!  But maybe you have some
questions.

**Mike Schmidt**: Well, I think you gave a good breakdown about LN features,
especially related to the Nostr ecosystem.  One other thing that we noted in the
newsletter is just, LN is just one interactive protocol, and I think it's the
first use case for this NWC, Nostr Wallet Connect.  But we're interested in also
things like joinpools, DLCs, or other multisig schemes that could eventually
benefit from similar coordination protocols.  So, I think it's interesting,
we'll keep an eye on it.  Thanks for joining us, Pierre.

_Mutiny Wallet v0.5.7 released_

Next piece of software that we highlighted this month was Mutiny Wallet v0.5.7
being released.  The applicable thing here for Optech listeners was that Mutiny
Wallet added payjoin support and we also talked about NWC in our previous item.
They had made improvements to their NWC feature set, as well as their LSP
features.  And I think we covered Payjoin Dev Kit (PDK) and Newsletter #260 and
that's actually what Mutiny Wallet is using here to achieve their payjoin
functionality, is PDK.  So, check out #260 if you're curious about that Rust
library.

_GroupHug transaction batching service_

Third piece of software this week is GroupHug, which is a transaction batching
service.  It's a bit of an older announcement.  This has been out for a couple
months now.  And essentially what GroupHug does is, it's a batching service
using PSBTs.  And every 12 hours is the interval for the batching, unless
there's, I guess, more than 30 participants, then they'll actually do the batch
sooner.  And these PSBTs are grouped in feerate ranges so that high-fee
transactions don't pay for low-fee transactions.  And so, based on this tiering,
this batching goes out and obviously money is then saved on transactions because
you're batching a bunch of payments into a single transaction.  But there are
some limitations and this isn't something that everybody would use, but I
thought it was an interesting use case for those who would.

The limits here are that each PSBT is a transaction that is paid out in full, so
there's no change address.  So, there's only one input and one output that are
accepted, and those inputs have to be signed with SINGLE|ANYONECANPAY signature
hash (sighash).  And the use case here is that it would work well for P2P trade
scenarios that have an escrow, which of course is exactly what Peach does, which
is the authors of this software and of its service provider, so it makes sense
for their P2P Bitcoin exchange service at Peach.  I thought it was an
interesting way to do batching, even if it's a quite limited use case.  Murch?

**Mark Erhardt**: Yeah, I hadn't seen that they were using SINGLE|ANYONECANPAY
from the newsletter, just to note that I am looking more at it.  So, one reason
why you would want to do a multiuser transaction, for me, usually would be that
you want to make a transaction that looks like it has multiple recipients,
multiple inputs, but doesn't reveal that it is sent by multiple parties.  So, I
was surprised that apparently here, the savings is just the transaction header,
because if we're making transactions that already are SIGHASH_
SINGLE|ANYONECANPAY, then you could just send the same transaction by yourself
and attach a header, and that would work as well.  So, yeah, I feel like that
changed a little bit the context in which I read this announcement.

_Boltz announces taproot swaps_

**Mike Schmidt**: Last piece of software we highlighted was Boltz announcing
taproot swaps.  Boltz, with a Z, is a swap service that allows you to swap
between onchain Bitcoin, Lightning, and the Liquid sidechain.  And I believe
things like AQUA Wallet, among others, use Boltz behind the scenes to facilitate
exchanges or swaps.  And in this announcement, they've updated their atomic swap
approach to use taproot schnorr signatures and MuSig2, which allows for less
fees for their service, as well as increased privacy.  And they also note, in
their write up about their service, that it'll be an easier upgrade path for
adding additional features for Boltz swaps by using taproot.

Then one other note from their writeup is, "Taproot's features also allowed us
to implement Immediate Cooperative Refunds".  There's a lot of detail in their
blog writeup, so I would invite people who are curious about how they're doing
this to check out the blog.  It's too much for us to get into today.  But Murch,
I don't know if you had any other takeaways before we move on?  All right.

_Core Lightning 24.02rc1_

Releases and release candidates.  We have one this week, Core Lightning
24.02rc1.  I saw Christian Decker posted on Twitter, "Plenty of small and large
fixes and improvements".  So, there wasn't too much detail there and I didn't
see the release notes, but we have covered a few Core Lightning (CLN) code
updates, particularly a flurry of them in Newsletter #288, so it's likely that
those merges are also in this release.  So, refer back to #288 if you're
curious.  As we move to Notable code and documentation changes, we'll give an
opportunity for anybody who has a question about this newsletter or anything
Bitcoin to raise your hand for speaker access or post in the thread.

_Bitcoin Core #27877_

Two PRs this week.  First one, Bitcoin Core #27877, titled Add CoinGrinder coin
selection algorithm.  And Murch is the author of this PR.  So, Murch, congrats
on getting this merged and you're probably best suited to explain this PR.

**Mark Erhardt**: Yeah.  So, in the summer, I was looking at the mempool and
noticed that we were seeing much higher feerates, like many others of you.  And
I've been looking at Bitcoin coin selection on and off for about ten years now.
And one of the things that the current coin selection algorithms, or before this
merge, don't do is they do not actually minimize the input set on transactions.
Now, when feerates go past 300 towards 600 satoshis per vbyte (sat/vB), I think
we really want to minimize the transaction you're building when you're trying to
make a payment.  So, I implemented this originally in July, and now it finally
got merged.

So, with the next release, we have another way of building input sets on Bitcoin
Core.  We have a multi-algorithm approach there already, so we use multiple
algorithms to generate input set candidates, and then pick from all the
generated input sets based on the waste metric.  And with the CoinGrinder, we
will build the minimal weight input set above 30 sat/vB.  So, when Bitcoin Core
is used as a wallet at high feerates, in the future it will be very thrifty at
high feerates.  Now, you might be wondering why only at high feerates.  If you
always minimize the input set, you might grind down the biggest pieces of
bitcoin in your wallet and end up with a ton of dust.  So, it's deliberately
only active at very high feerates, and otherwise we use the prior strategies.

**Mike Schmidt**: Murch, I think it was the Newsletter #283 that we covered your
Delving Bitcoin posts that touched on this topic, where you covered CoinGrinder
and some simulations that you ran.  Did you get any feedback from that, either
directly in there or private, that informed the final PR?

**Mark Erhardt**: Actually, I really had to fish for feedback on this one.  It
seemed really obvious for me that we should be working on this with the
explosion in the feerates in the last year.  But I finally got a few people
interested in the algorithmic aspect of my implementation.  Essentially,
CoinGrinder is a branch-and-bound algorithm that deterministically searches the
entire combination space of the UTXOs in your wallet, and then keeps the input
set with the smallest weight.  And on that end, I got some feedback and some
improvement suggestions, and even another optimization on how to more quickly
arrive at that result by skipping parts of the combination space that cannot
yield better results.  And I finally implemented a second.  So, this has two
first tests, where we basically tried to generate all possible inputs.

So, yeah, on the algorithm side of it, I got feedback.  I guess I got a bunch of
concept acts in the sense that people agreed that building the smallest possible
transaction is sensible at high feerates.  But other than that, the topic hasn't
really progressed much on delving.  I don't think I got a single response
actually.

_BOLTs #851_

**Mike Schmidt**: Well, congratulations on getting that merged.  We have one
more PR this week, to the BOLTs repository, #851, adding support for dual
funding to the LN spec.  So, I guess we could just do a quick overview of what
is dual funding and why this is exciting.  So, in v1 of channel opening that
probably most people are familiar with, only one side of an LN channel puts in
funds.  Whereas, with v2 channel opens, dual funding is possible, meaning that
essentially both sides of a channel can put funds into the channel, which is
exciting and enables a couple of things that I'll get into in a second here.
This PR to the BOLTs repository was originally opened in March of 20201, so a
three-year journey.  So, congrats to all who moved this along.  I believe Eclair
and CLN have support for dual funding in some capacity currently.  I'm not sure
about LDK or LND.  They may have support, I just didn't immediately see that.

One thing that I'll quote from our topic on dual funding is, "After dual funding
is available, it may be used in combination with new proposed node announcements
that could help buyers and sellers of inbound capacity find each other in a
decentralized fashion".  This is something known as liquidity ads, which we also
have a write up on our Topics wiki about, which is a way to sort of solicit
liquidity within the LN so that things can essentially rebalance channels using
dual funding and potentially then eventually splicing, which helps with
liquidity management concerns on the LN.  Murch, I know we've talked a bit about
dual funding, especially when we had t-bast on.  Obviously, this is something to
celebrate.  I don't know if you have anything to add.

**Mark Erhardt**: Not really.  The whole LN thing is more and more out of my
wheelhouse as we have so many people working on all of it.  I find that I am
drifting off more into the wallet section of Bitcoin Core again.

**Mike Schmidt**: Calle, did you have any thoughts on dual funding at a high
level or this particular PR to the spec repository?

**Callebtc**: Well, first of all, congrats that it's merged.  I am just
celebrating the fact that it took so long and it's finally there.  But generally
speaking, it's kind of a problem for people who run LN nodes to find appropriate
inbound liquidity.  There are centralized services for that and people organize,
and although that is much better than nothing, these are still centralized
services and they can kind of track who talks to whom and who finds whom.  So,
this enables, especially when combined with liquidity ads, enables this
decentralized way of finding each other.  And I think going forward, it would
possibly help the reliance of the LN by producing more balanced channels.

**Mike Schmidt**: That's it for this week.  Thanks to everybody for listening
and thanks to our special guests, Pierre, Fabian, Chris, Calle, Gloria, and as
always my co-host, Murch.  And we'll see you all next week.

**Mark Erhardt**: Cheers.

**Mike Schmidt**: Cheers.

{% include references.md %}
