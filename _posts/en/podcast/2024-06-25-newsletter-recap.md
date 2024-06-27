---
title: 'Bitcoin Optech Newsletter #308 Recap Podcast'
permalink: /en/podcast/2024/06/25/
reference: /en/newsletters/2024/06/21/
name: 2024-06-25-recap
slug: 2024-06-25-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Jameson Lopp and
Valentine Wallace to discuss [Newsletter #308]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-5-25/381635816-44100-2-531e706e0e3da.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #308 Recap on
Twitter Spaces.  Today, we're going to talk about an LND vulnerability
disclosure; there's some more discussion about silent payments and PSBT; we have
nine interesting updates to wallet and service software; and then we have a
regular Releases and Notable code segments as well.  I'm Mike Schmidt,
contributor at Optech and Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I'm an engineer at Chaincode Labs.

**Mike Schmidt**: Val?

**Valentine Wallace**: Hey, I work at Spiral on the Lightning Dev Kit.

**Mike Schmidt**: We're going to start the newsletter in sequential order, but I
think we may jump to some of the Notable code items that Val is going to help us
out with, with LDK, maybe a little bit earlier than normal, due to some time
considerations.  So we'll start with the News segment now.

_Disclosure of vulnerability affecting old versions of LND_

Disclosure of vulnerability affecting old versions of LND.  And this was spurred
by a post and a disclosure from Matt Morehouse to Delving Bitcoin about a
disclosure he found with versions of LND v0.17 and earlier.

**Mark Erhardt**: I think v0.17 was fixed.  Before v0.17.

**Mike Schmidt**: Before v0.17, my apologies.  And I think he's titled this
vulnerability, Onion Bombs, LND Onion Bomb.  Murch, I know you looked into this,
I looked into it a bit.  Do you want to take a crack at summarizing?

**Mark Erhardt**: Sure.  So apparently, a long, long time ago when the onion
message variable format was introduced, there was a new limit introduced on
LND's side for how much memory could get allocated to unwrap the onion, whereas
the protocol then already specified that the message could not exceed 64 kvB.
For some reason, LND allowed to allocate up to 4 GB.  So, what would happen here
to affect the node would be that someone sends an onion message, the node
unwraps it and then the amount of memory that is supposed to be allocated is
misrepresented to be 4 GB instead of up to 64 kvB.  And then if the node doesn't
have enough memory, it might crash immediately, or if it has more memory, an
attacker could send multiple onion messages in parallel and make it explode at
the same time and then crash a node with even more memory than that.

So, from what I understand, the versions before v0.17 were vulnerable to that.
V0.17 came out about half a year ago, well, eight months ago really, in October
last year, and v0.18 has been out for about a month now, so it's been fixed.
And I thought that Matt Morehouse had an interesting recommendation at the
bottom of his blogpost which was, "Write fuzz tests for all APIs that consume
untrusted inputs".  When you consume an untrusted input on an API, obviously the
input could be anything, so this is something that is very easy to fuzz, and
fuzzing is very good at finding all the edge cases.  So, I thought that was an
interesting summary or takeaway.

Anyway, if you're on a version before v0.17, you really, really want to upgrade
if you haven't heard it yet, and yeah, because this is cheap and easy to execute
in production.

**Mike Schmidt**: So, Murch, if I'm understanding correctly, the encoding
mechanism for the payload size, there's a payload size and then there's actually
the payload, which is what's being passed around, and it looked like there was,
it sounds like there was no bounce checking on the payload size variable.  So,
you could say, "Hey I'm about to send you 4 GB", and it was at that point that
LND would allocate that memory.  And then it also sounds like regardless of the
actual payload size, LND would allocate that whatever you said you were going to
send in memory, which would obviously cause issues if one, or like you
mentioned, Murch, several of these were sequentially sent to the same node.  Did
I get that right?

**Mark Erhardt**: Yeah, that's my understanding too.  So, the untrusted input is
the size of the memory that's required to unpack the onion, and this could be
represented as being up to 4 GB and then would cause LND to allocate that much
memory, even though the messages were limited by the protocol to not exceed 64
kvB.  And the fix, I didn't mention the fix.  The fix was to just do this check
on the maximum size for the memory allocation and limit that to 64 kvb.

**Mike Schmidt**: You mentioned fuzz testing, and another thing interesting here
was that fuzz testing was the mechanism that discovered this vulnerability, and
Matt also noted that once he added that fuzz test, it found this vulnerability
in less than a minute of fuzz testing, which is pretty quick.  He notes in his
writeup, "The attack is cheap and easy to carry out and will keep the victim
offline for as long as it lasts.  The source of the attack is concealed via
onion routing.  The attacker does not even need to connect directly with the
victim".  So, those are a couple of quotes from his writeup.

One thing that I wanted to plug was that in a timely discussion, us at Brink
hosted Matt Morehouse last week where he presented fuzz testing the Lightning
Network.  And we didn't jump into this particular vulnerability at that time,
but we did sort of do an overview of the state of fuzzing in the Lightning
Network, including different implementations' level of fuzz testing on their
code base and how there needs to be more, and there's a bunch of calls to
action.  So, if you're curious, we just published that on the Brink blog,
brink.dev, and you can watch his presentation there where he goes through some
of the techniques that he uses in terms of fuzz testing, and then calls for all
of you to participate and potentially help fuzz some of these implementations to
prevent these sorts of vulnerabilities in the future.

_Continued discussion of PSBTs for silent payments_

Next news item, continued discussion of PSBTs for silent payments.  This
piggybacks on an initial discussion that we covered in Newsletter #304 and,
Murch, I think it was you and Dave that had Andrew on, I don't recall, on Pod
#304, and this is more discussion of that.  Some of this stuff got a little
complicated in the writeup, so I'm going to punt it to Murch, who has a better
grasp of it.  Murch, what's the latest on PSBTs for silent payments?

**Mark Erhardt**: We did have someone on, but it was not Andrew, it was
setavenger, Setor Blagogee, I think.  Anyway, the latest is that now Eva has
started chiming in on the PSBT design for silent payments.  Eva is, of course,
the author of the PSBT v0 and the PSBT v2 standard, and she basically had a
different take on how the fields should be constructed to incorporate the secret
information that is required to build the silent payments output.  So the
problem here is, of course, you can't calculate the appropriate output script
until all of the inputs are set, and you require all the private key information
for anyone that contributes an input.  However, of course, you (a) don't want to
share who you're paying, and (b) you cannot have anyone malleate their inputs
after they shared secret information that led to a silent payment output to be
created, otherwise the funds might be irrecoverable.  So, yeah, basically the
debate is still ongoing.  It looks to me like they are close to coming to an
agreement on how to design this.  And yeah, if this is the sort of thing that
you find interesting, I would recommend that you jump into the Delving Bitcoin
thread.

**Mike Schmidt**: Vandelay, I saw that you requested speaker access, which I've
granted.  I don't know if that was about the PSBT discussion or the LND
vulnerabilities.  Did you have a question or comment?  Okay.  Well, if you do,
I'll leave speaker access on and you can chime in.  As Murch mentioned, the
discussion is ongoing with regards to how silent payments will be handled in
PSBTs, so feel free to jump into that thread and opine if you're somebody who
would use either of those.  Anything else on that one, Murch?

**Mark Erhardt**: No, sorry, that's all I had.

**Mike Schmidt**: Okay, great.  We'll move on to our monthly segment,
highlighting Changes to services and client software.  And just in time, we have
Jameson.  And the first item here actually is Casa.  But Jameson, who are you
for everybody who might not know who you are?

**Jameson Lopp**: Oh, I'm just a long-time Bitcoin nerd.  I've been working on
self-custody for nearly a decade now.

_Casa adds descriptor support_

**Mike Schmidt**: Well, thanks for joining us.  We thought we'd maybe bring you
on to give your take on descriptors and the blogpost announcing Casa's support
for descriptors, and maybe jump into some of the details.

**Jameson Lopp**: Sure.  What we're really talking about with supporting
descriptors is making strides advancing interoperability between different
Bitcoin wallets in this space, and there are many, there are probably hundreds
of different Bitcoin wallets out there.  And we have a couple of new primary
motivations at Casa for why we want to to be more interoperable.  One of them is
that one of our primary focuses, when we're architecting the wallets and really
any functionality for Casa users, is that we don't want Casa as a company to be
a single point of failure.  So, it's very important that it's easy for our users
to be able to recover their funds and a variety of other software and hardware,
and basically be able to do that without ever having to touch or rely upon Casa
software and infrastructure.  And how do you do that?  Well, you need to provide
people with the appropriate information so that they can recreate their wallet.

I don't know how deep you want to get into it, but the short version is that one
of the common things I think that we've taught people in this space for a long
time is "not your keys, not your coins", and I think a lot of people may have
taken that a bit too far and oversimplified it to the point that it seems to be
a common assumption by people that as long as you have your seed phrase, you're
fine, and you can recreate your wallet and spend your funds.  But when you get
down into the nitty-gritty of how a wallet works and what is required in order
to be able to actually find which UTXOs belong to you and to be able to recreate
the appropriate spending conditions and redeem scripts and signatures and stuff
to be able to spend your money, you need to have other information.  You need to
know things like all of the public keys, if it's a multisig; you need to know
the derivation paths that are being used, so that you can actually find which of
the nearly infinite number of private keys that your seed phrase could generate
are the ones that are used to secure your funds.  And so, that has led us over
the years to create these fairly annoyingly complex and long guides and
documents for our users that are essentially like step-by-step processes, "If
you want to recreate your wallet and spend funds from Electrum, you have to do
these 20 things.  If you want to do it in Sparrow, you do these dozen steps",
and it's kind of fraught with peril.

So, the thing about wallet descriptors is, it takes all of the information that
you need to recreate and define and spend from your wallet, and it basically
puts it into one nice little blob.  And you can then encode that blob as, for
example, a QR code is one thing that we've done in our app.  And it just makes
it a lot more portable so that you can copy, paste, transfer that information
and import it into any other wallet that speaks this descriptor language.  So
basically, what we've done is we've made it very easy to export your wallet
descriptors out of Casa so that you can recreate either watch-only wallets
elsewhere, or even recreate the full wallet and spend from it in other wallets
that support descriptors.  So, that's where we are right now, that's kind of the
immediate benefit.

The point that I was really getting at in my longer, more detailed post is that
I believe that this is going to become more and more important as we see more
wallets start to take advantage of more complex spending conditions, doing
things like using miniscript, to leverage the more complex logical spending
paths that taproot and tapscript in particular have made available at the
protocol level.  I would say we're still kind of lagging behind on the software
wallet application side of things, but if we keep going forward in the way that
we've seen a lot of wallets going, where they're all kind of doing their own
thing, that's great for each individual wallet, but I think it's not great for
the ecosystem as a whole, because it kind of results in more fracturing of the
ecosystem if you can't just hop from one wallet to another fairly easily.

**Mike Schmidt**: You touched on this at the end of your description here, but
it sounds like adoption has been fairly weak, and I think you linked to
outputdescriptors.org, which tracks adoption of descriptors, and there's not a
large list there.  So, what do you attribute this lack of adoption to, with
regards to descriptors specifically?

**Jameson Lopp**: Yeah, I mean, you have to look at the incentives, right?  I
would think from any given wallet developer's perspectives, they don't
necessarily have a lot of incentives to make it easier for users to leave and
use other wallets.  So, it's not the greatest position to be in to try to
encourage adoption, because this is one of those kind of community-level
problems where you have to look at the problem at a much higher level, look at
the big picture, and don't think just about yourself and your own users.  So, I
don't have a great piece of advice or suggestion for how we improve descriptors,
other than I think going around and evangelizing them and talking about how
fracturing of the wallet ecosystem is just not good at a very high level.

**Mark Erhardt**: Yeah, I just wanted to jump in and reiterate.  Essentially,
output descriptors are an improved version of xpubs, where xpubs were only a way
of storing the master secret and the chain code, which is the derivation
instructions for one chain of subkeys.  And as Jameson said, we've seen the
problem a few times that people had two of their private keys in a 2-of-3
multisig, lost a third private key, didn't have a backup of the pubkey of the
third private key, and therefore weren't able to reconstruct the input script
that they required to spend their funds.  And this is a problem that just
outright goes away with output script descriptors because they have the entire
information that allows you to recreate the address space of a wallet as it was
defined.  And so, it's just a general upgrade, it's a better way of doing
essentially the same thing.  And with the antecedent of miniscript and taproot
getting used more, people thinking about inheritance or multisig wallets that
over time require fewer keys, if you're starting to build that sort of stuff and
you can encode it directly in the output script descriptor and every other
wallet can import that, that'll make it way more robust, because one of the
other big problems is if you come back ten years later, maybe the software that
you were using to create that wallet no longer exists, it's not maintained,
doesn't work with your operating system, you can't find the binary or things
like that.  But then if you can just import it to any other wallet, you're in a
much better position.

So really, yes, this is a community effort, there's a better way of doing
things.  I don't think it's way more complicated to implement, it's just people
that have already implemented something would need to put in more work or it
makes it easier for people to leave your service, right?

**Mike Schmidt**: Jameson gave a verbal summary of some of what was covered in
the blogpost, but we link to it in the newsletter.  And if you're curious about
what Jameson outlined and what we've talked about here, I would encourage you to
jump in and read that blogpost.  Jameson, any calls to action or parting words
for the audience on this item?  You're obviously welcome to opine on the rest of
the newsletter as well, but anything to wrap up Casa's descriptors?

**Jameson Lopp**: Yeah, I mean I think it's a long-term issue, right?
Especially, like Murchh said, one possible other reason we haven't seen a lot of
adoption is, last I checked, most people are still using fairly simple
single-signature wallets, very straightforward spending conditions that aren't
particularly difficult to recreate.  But if we believe that people are going to
continue to take advantage of some of the more complex spending conditions that
the protocol affords and that we know that a variety of teams are working on
bringing to the surface to make it easier for end users to actually take
advantage of, this is just the direction I think that the ecosystem is moving
in.  Also, if we believe the value of Bitcoin is going to keep going up and
there will be more and more people that are securing life-changing amounts, then
I'm looking out at what are the available security models for self-custody.  And
we can do so much better than just single-signature wallets.

For the past decade, the kind of top-of-the-line Bitcoin security has been
multisig, and that's been great, but I don't think that's the end game either.
We're continuing to explore with new security models and basically spreading out
key material and even having a multi-institution custody so that it's an even
greater level of robustness.  I think we're still basically on the cutting edge
of starting to explore this stuff.  So, if you fall in line, as I do, with the
belief that we're going to continue to improve the security models that are
available to Bitcoin users, then this is just the logical next step to help us
continue to evolve the complexity of what Bitcoin can afford to people.  And if
we don't make it easy, obviously that's going to hinder adoption.

**Mike Schmidt**: Big blockchain, did you have a question for Jameson?

**Big Blockchain**: Yeah, well it's more of a kind of comment and a question.
I've been a bitcoin holder since, I mean still trying to get my bitcoin back
from Mt. Gox, so learned the hard way not to hold on exchanges and all that
stuff, and I'm a big fan of Casa.  There's wallets like Casa multisig wallets
that you're going to use for multi-generational wealth storage and for the
bitcoin that you just kind of want locked away and not touched.  But I've
learned over time also, it's also okay to have a couple of other whatever
wallets and you might have the seed phrase, literally a snapshot of it on your
photos, or something like that, and in that wallet you only hold fractions of
bitcoin and those are the bitcoin you're going to use to spend.  And if, God
forbid, you do lose that wallet, you didn't lose like your main Casa wallet or
your main vault wallet, which is holding your generational wealth, and that one
you're not going to be snapshotting your seed phrase or doing anything like
that.  You're going to be doing some sort of multisig smart solution that even
continues as you pass on.

So, I wonder if you guys are, I mean Casa is trying to solve for all the new
spending regime on Bitcoin and all that stuff, but I wonder if there should be
-- and I think I'm an advanced user that way, because I'm okay holding a bunch
of different types of wallets.  And I wonder if the wallet that you're storing
generational wealth is not really a spending wallet, but more of a storage
wallet, and then when you need to take money out of your storage wallet and pass
it to your spending wallet, if that's not a better model.  And I think about it
in terms of everybody who I've tried to bring into Bitcoin, and I'm talking to
people that'll just barely buy the ETF.  Once you start talking about wallets,
they're just not interested.

Then, you also think about the unbanked in all these smaller countries, they're
not going to have the luxury of buying Casa and all this other stuff.  They're
just going to have a very simple wallet if they are going to adopt Bitcoin, and
not like a US stablecoin, like a dollar stablecoin wallet.

**Mike Schmidt**: I think we got the gist of your comment.  Jameson, do you want
to address sort of the underlying theme of like cold storage versus day-to-day
transacting, and hopefully we can keep it brief because we've got to jump to
Val's section shortly.

**Jameson Lopp**: Yeah, I mean the short version is that you don't have to get
locked into a single-security model, and it makes sense to have your super-duper
cold storage and then maybe some slightly less secure storage, and then even hot
wallets, and of course Lightning wallets, and so on and so forth.  Of course,
it's going to be a more advanced user that ends up having tiered storage like
this, and Casa does primarily focus on high net worth individuals and
organizations that have life-changing amounts of money that they're dealing
with.  But we try to even offer that within our own app, like it's possible to
have a 3-of-5 and a 2-of-3 and a single-signature all in Casa, and try to make
it easy for people to manage multiple tiers of security and spending conditions
all in one place.  But of course you could also go out and set up a dozen
different type of wallet softwares and make your life even more complex.

So, this is kind of what you were getting at, is it's always a balance between
security and convenience and complexity really.  Too much complexity can
actually become a security issue.  People get overwhelmed, lose things, lose
their money.  But yeah, this is a continuing evolving type of thing, and it even
goes forward, if you're looking at really long term, you start getting into the
whole question of, how many people are even going to be sovereign onchain versus
using some sort of other hybrid custody model that's more scalable.  And that's
also a very exciting part of the space to be watching evolve right now, as a
variety of different teams are out there experimenting with new models and new
technology.

**Mike Schmidt**: Thanks, Jameson.  You're welcome to hang on for the rest of
the newsletter.  We're going to jump down to the Notable code section of the
newsletter, and specifically, we saw that there were five LDK-related PRs this
week.  So, we brought on someone from the LDK team, Val, to walk us through
these different PRs.  I think she'd do a much better job than Murch or I.
Thanks for joining us, Val.

**Valentine Wallace**: Yeah, no problem.  Thank you for having me.

_LDK #3098_

**Mike Schmidt**: Yeah, do you want to just jump into it with LDK #3098?

**Valentine Wallace**: Sure.  So, we actually have Arik on this call, who's the
author, so he can correct me if I'm missing anything.  But for background, LDK
or the Spiral team has a thing called RGS (Rapid Gossip Sync), which is a way
for mobile clients, like if you have a phone app, you might not want to use all
your data to sync the whole network graph.  So, RGS will allow you to more
quickly sync a compressed version of the network graph and it'll be on the order
of kilobytes instead of megabytes or even gigabytes.  And that way, you can
still have the mobile app do its own pathfinding, which preserves privacy.  So,
this is something that Mutiny uses, but the issue with this is that RGS doesn't
contain all the same data because it's compressed, so it kind of strips out
"unnecessary" data.  And when Mutiny wanted to adopt BOLT12, part of BOLT12 is
that because onion messages are not supported widely across the network,
something that needs to happen is, if you need to fetch an invoice from
someone's offer, you might need to directly connect to them and that would use
their IP address or Tor address or whatever.  And this was information that is
in the LN graph, but it was information that RGS was stripping out.

So, this PR by Arik essentially adds that information back in, so now users like
Mutiny client-side pathfinding that uses RGS will now be able to use BOLT12.

**Mike Schmidt**: So, yeah.  Arik, how did she do?

**Arik Aleph**: Yeah, very well.  Thank you so much, by the way, Val, for taking
this on.  I guess one thing I would add is that, well, it might depend on your
specific Lightning implementation, but the thing about standard gossip is more
so than just it being more data.  The way or the manner in which you receive the
data is also haphazard because you have to reach out to a bunch of nodes, ask
for gossip, then you receive that gossip, and it's a bunch of individual
messages that you have to parse and you have to wait until you have a
sufficiently large representation of the graph.  You can't just say, "Hey, give
me everything in one easy, compact message, and I'll process it".  It's all a
bunch of separate messages.  It's a group of gossip data that are kind of
clustered.

With RGS, what we are doing is we generate these snapshots.  And when you're
requesting a snapshot from an RGS server, which by the way you can also run
yourself, the code is open source, you can also optionally indicate the
timestamp of the last snapshot you received such that the data can either be
absolute or incremental.  And the thing is, one of the optimizations that we had
in gossip v1, and continue to have in gossip v1, which remains available, is
that we didn't send node announcements.  We only inferred nodes implicitly by
simply communicating an array of public keys of the nodes, and then when we
serialized the channel announcements and channel updates, we would reference the
nodes by simply specifying the index of that specific pubkey within the array
that we sent a priori.

Now for gossip v2, for blinded paths, and for BOLT12 payments, we need to know
node features and we also need to know node socket addresses, such that you can
actually reach them across the net.  And in order to convey that data, we now
optionally, for nodes that have that data, serialize the array of socket
addresses and their node features.  And we have some cool optimizations there
too, such that if we see that a bunch of node features are reused commonly
between multiple nodes, we build a histogram in the background of the most
common ones, and then we just reference an entry in the histogram, if you are
one of the, say, top six most commonly used node feature combinations.

**Mike Schmidt**: Val, anything else to add there, or should we move to the next
PR?

**Valentine Wallace**: No, that was great.  Thanks for clarifying all that,
Arik.

**Arik Aleph**: Thanks.

_LDK #3078_

**Mike Schmidt**: LDK #3078, adding support for asynchronous payment of BOLT12
invoices.

**Valentine Wallace**: Right, so not to be confused with async payments, the
feature for paying off an offline mobile recipient.  Basically, so BOLT12 is an
improvement to Lightning's invoice protocol.  BOLT11 is the outdated version.
Now we have BOLT12, and how BOLT12 works differently is the recipient will
publish an offer, and then the payer will request an invoice from the offer,
receive the invoice, and then pay it.  So, this #3078 basically is how Fedimint
works.  My understanding is that the gateway will request the invoice on behalf
of the end user, who I think doesn't have a Lightning channel yet, and then it
will present the invoice to the end user for approval and then go ahead with
paying the invoice.

So, because of this, we needed a way to intercept these invoices, because prior
to this, LDK would just grab the invoice for you and then pay it for you
automatically.  So, this added an intermediate step, where the LDK user can
check the invoice before paying it.  So, yeah.

**Mike Schmidt**: Arik, anything to add there?

**Arik Aleph**: No, nothing.  Nothing to add from my end.

_LDK #3082_

**Mike Schmidt**: Another LDK-related BOLT12 PR, which is LDK #3082.

**Valentine Wallace**: Yeah, so this actually is for async payments, the feature
that allows mobile recipients to pay each other without being online at the same
time.  And the reason we needed this, static invoices, is because the recipient
may not be online to provide an invoice when the sender goes to pay them.  So,
like I said with BOLT12, you have to first request an invoice from the
recipient, and if the recipient is not online, that might be an issue, they
won't be able to provide one.  So, because of this, we added a new static
invoice encoding, and this would allow another node on the network to supply
invoices on the recipient's behalf.  And they don't have a payment hash, so they
use keysend payments, meaning the sender sets the preimage and this loses the
proof-of-payment property, but we're going to get it back when we add PTLCs
(Point Time Locked Contracts).  So, yeah I don't want to get too into the weeds
but that's the high level.

**Mike Schmidt**: Okay, that's interesting.  So, if somebody's offline, someone
else can generate an invoice on their behalf.

**Valentine Wallace**: Not generate, but the recipient would provide the invoice
to them ahead of time.  So, it would still be signed by their node identifier or
the identifier that they're using for the particular offer.  So, yeah, it still
maintains all the other properties, we just temporarily don't have the proof of
payment here.

_LDK #3103_

**Mike Schmidt**: Okay, that makes sense.  LDK #3103, using a performance score
and benchmarks.

**Valentine Wallace**: Yeah, this should be pretty quick, but basically in
Lightning, it's very important to score channels when you're finding a path.
Like you want to say, "Do I want to include this channel in my path?  We want to
have a sense of whether or not it will be likely to successfully relay the
payment".  So, all the major Lightning implementations have scoring for that.
And it's also very important to have benchmarks for these scores, which LDK does
to make sure that performance is good, because we want to be able to send a
payment in 100 milliseconds, or whatever.  So previously, LDK's benchmarks used
a synthetic score that was generated using a fake network graph, but this PR
just swaps it out to use a score-generated -- or, updated using the actual
network graph and actual probes on mainnet.  So, it should be a little more
accurate benchmarks.

**Mike Schmidt**: And how would you contrast that scoring versus other
implementations?

**Valentine Wallace**: I mean, I think we all try to converge on what a really
good strategy would be.  So, for example, LND has come out with some cool
blogposts about how they do their scoring, and we've always taken a look at
those and tried to incorporate the parts that made sense.  But I think most
implementations do basically try to estimate the channel capacity, so try to
estimate like, what is the likelihood that this is the amount on this side of
the channel, which means that's the amount that can be sent over it?  So it's
basically, scoring will get you -- the more you probe a channel, the more you
get narrower and narrower bounds for what the capacity could be, and that gives
you an idea of what amount is realistic to pay over that channel.  So, I think
that's a super-high level.

Then, you can also have historical data, which LDK added somewhat recently.  So,
it gets pretty complicated, but yeah.

**Mike Schmidt**: Jameson?

**Jameson Lopp**: Yeah, I was just wondering if Valentine could speak to whether
or not any of the scoring and pathfinding algorithms or experiments that you've
been doing, do they look at clearnet versus Tor?  I'm just wondering, what is
the state of Tor and Lightning?

**Valentine Wallace**: That is a good question.  I don't think Tor is factored
in at the moment, but maybe it should be, or maybe something about latency
should be factored in, which might be affected by Tor.  But for example, when
we're constructing blinded paths, I believe we do kind of -- unfortunately we
don't really prioritize Tor nodes at the moment because of potential latency
concerns.  So, yeah, I would have to look into that, but I don't think Tor is
factored in very much at the moment.

_LDK #3037_

**Mike Schmidt**: Last LDK PR, #3037,d begins force closing channels if their
feerate is stale and too low.  Take it, Val.

**Valentine Wallace**: All right.  So, in Lightning, there's two ways to close a
channel.  You can close cooperatively, where you both agree on the feerate and
you both mutually publish it and you're both online at the same time.  That's
the good case.  The not so good case is when one party just goes offline
completely, and the one who's online needs to be able to close with whatever
feerate was agreed on the last time their offline counterparty was online.  So,
obviously that feerate could be pretty outdated, which is not good for getting
the channel closed.  This is pretty much fixed with anchors, because you can add
exogenous fees, I think is the term, to bump up the commitment transaction.  But
in old pre-anchor channels, you couldn't do that, which could be an issue.

So, as a result of that, to fix this issue for pre-anchor channels, which we
hope people don't even really open anymore, basically LDK will monitor feerates
for those channels.  And if the channel's feerate is below the minimum that we
think would be able to confirm the commitment transaction, then we will, for a
certain amount of time, then we'll force close.  So, it's just a little bit more
proactive way of making sure channels can make it into a block.

**Mike Schmidt**: Arik, anything that you'd add to these last few LDK PRs we
discussed?

**Arik Aleph**: Yeah, I think the pre-anchor feerate detection is a really fun
one.  If anybody is curious, we only do that if we determine that for any of the
fee estimations that we have computed for the preceding day, aka the preceding
144 blocks, we notice that it is lower than every single one of those, let's
see, anything interesting there?  We don't store them outside of RAM, so it's
only upon startup.  If you restart your node every 24 hours or with an even
shorter cadence than that, then I guess your node will never actually take
advantage of the specific mechanism.  So, in that scenario, be sure to only ever
open anchor channels.  And I guess in general, be sure to only ever open anchor
channels anyway.

**Mike Schmidt**: Arik and Val, thanks for joining us.  I think we finished
right on time.  We appreciate your insights walking through these LDK PRs.

**Valentine Wallace**: Awesome, thanks for having us and discussing the LDK PRs.
I'm going to hop off, but thank you.

**Mike Schmidt**: Cheers.

**Valentine Wallace**: Cheers.

**Arik Aleph**: Thanks, bye.

_Specter-DIY v1.9.0 released_

**Mike Schmidt**: We're going to jump back up to the Changes to services and
client software section.  We covered Casa with Jameson a bit ago.  We're going
to move to Spectre-DIY, v1.9.0 being released, and that particular release adds
a BIP85 app, BIP85 being deterministic entropy from BIP32 keychains, and BIP85
derivation of new mnemonics and xprivs is what was added to Spectre-DIY in this
v1.9 release; and additionally, now supporting taproot miniscript as well.
Murch, any comments there?  Okay.

_Constant-time analysis tool cargo-checkct announced_

Next tool that we highlighted was a constant-time analysis tool called
cargo-checkct, and this is a tool from the Ledger team that they announced in a
blogpost.  It's a tool for Rust programs to defend against timing attacks.  And
the post has an interesting summary of timing attacks that I'll quote, "If
secret manipulating programs run faster for some values of the secret than for
some other values, then as an attacker, measuring that program's execution time
directly gives information about the secret".  So, in order to defend against
those sort of attacks, this tool helps identify the constant-time policy is
respected at the machine code level.  So, it runs some analysis on a Rust
program and ensures or helps confirm that those operations run in constant-time,
so that those timing attacks aren't possible.

Behind the scenes, this tool uses something called BINSEC, and BINSEC is an
open-source toolset that helps improve software security, and it does so at the
binary level.  And it uses a bunch of cutting-edge research and binary code
analysis and a bunch of program and security software engineering techniques to
evaluate a binary.  And so, this cargo-checkct tool is actually using BINSEC
behind the scenes.  The documentation for this tool notes a number of
limitations, so if you're planning to use this tool on your Rust cryptographic
library, be aware of those limitations, and there's also a few examples of usage
of the tool in the GitHub repository.  So if you're curious, you can jump in and
check that out.

_Jade adds miniscript support_

Jade adds miniscript support.  So, Jade is a hardware signing device from the
Blockstream folks.  But I think that that firmware actually runs on a variety of
different pieces of hardware.  So, this adds miniscript to all of those
different types of devices.  I didn't have anything else to add there.  Murch,
any thoughts?

**Mark Erhardt**: I'm just -- yeah, go ahead.

**Jameson Lopp**: Yeah, I would just say, this is the type of thing that we like
to see at Casa because in many different respects, we are blocked by what the
various hardware devices out there can do.  So, like I said, adding descriptor
support was one thing looking forward to being able to do more complex stuff.
One of the next in the sort of chain of dependencies for being able to actually
make use of advanced tapscript functionality is going to be miniscript.  That
just makes it easier for developers.  But once again, we need the rest of the
software and the hardware ecosystem to adopt it.

**Mark Erhardt**: Yeah, I had a similar point, which is the cool thing about
miniscript and tap miniscript is that it is a recipient-side upgrade, where we
get an effect similar to the wrapped segwit outputs.  Everybody will be able to
send to it already that can generally support the output type.  And so, as we
see more wallets now that MuSig2 is specced and out there, miniscript is specced
and out there, it's implemented in a bunch of libraries, I hope that we'll see
more recipients actually make use of these really cool new scripts that they can
build with miniscript and tap miniscript.  And then maybe, hopefully, we'll
finally see the big Bitcoin companies pull out send to P2TR support, which is
such a drag, and is dissuading people from investing into making really cool
scripts with these new features.

_Ark implementation announced_

**Mike Schmidt**: Ark implementation announced.  Ark Labs released their
open-source implementation of the Ark protocol.  And I try to stress "their",
because it may be confusing that they're called Ark Labs implementing Ark.  And
I do believe that there's a few different teams working on implementations,
various nuances of the Ark protocol.  So, this is from Ark Labs.  As a reminder,
Ark is a coinpool or joinpool type protocol for users to share a UTXO.  And the
mechanism is that there's a counterparty, known as an Ark service provider, that
cosigns the various transactions that go on within the Ark pool.  Ark Labs,
their implementation is built in Go and includes both the server, which is the
Ark service provider, the ASP, as well as a command-line wallet that interacts
with that ASP.  And then, they've also released a series of developer resources
on their arkdev.info website for technical documentation.

_Volt Wallet beta announced_

Next piece of software is Volt Wallet beta being announced.  Volt is a new
mobile wallet that has support for a variety of interesting Bitcoin tech:
descriptors; watch-only wallets; PSBTs; fee bumping using RBF; LN support,
including BOLT11 and LNURL; the ability to swap between onchain Bitcoin and
Lightning; and BIP21 URIs; and a bunch of other support as well.  The repository
does note, "Warning, Volt is still in beta, do not use it for large amounts of
bitcoin".

_Joinstr adds electrum support_

Next piece of software was Joinstr, Joinstr adding electrum support.  Joinstr is
a coinjoin tool that uses the Nostr protocol for coordination.  We initially
covered Joinstr implementation, I think the original announcement, in Newsletter
#214, and this week we covered Joinstr adding the ability to operate using an
electrum plug-in, so the Joinstr wallet would operate as a light client Bitcoin
wallet.

_Bitkit v1.0.1 released_

Bitkit v1.0.1 is officially released.  This is a self-custodial mobile Bitcoin
wallet and Lightning wallet.  This features coin control and fee bumping
features as well.  And I think the big thing here is that Bitkit is now in the
app stores, so you can download it on your Apple or Android devices.  I haven't
tried it out, but I've heard good things so far online.

_Civkit alpha announced_

Last piece of software here is Civkit announcing their alpha.  Civkit actually
has a few different tools, mostly to facilitate P2P trading.  So, there is a
PGP-based chat room for discussion.  There's also a tool for escrow that helps
facilitate trading using Lightning, and I think it's based on Core Lightning
(CLN).  And then there's a web-based front end for both that chat and the P2P
trading feature.  So, that's Alpha.  Check it out if you're curious about what
they're building over there.  That wraps up our Changes to the client and
service segment this month.  We'll move on to the Releases and release
candidates section.

_Bitcoin Core 26.2rc1_

Bitcoin Core 26.2rc1.  Murch, you're our resident Bitcoin Core dev.  Do you have
any particular notables or calls to action in this maintenance release?

**Mark Erhardt**: No, just the maintenance release.  That's the second or
probably the last release in the 26 major branch, and yeah, if you are still
stuck on 26 for some reason, you probably want to consider upgrading.  And
otherwise, developers always appreciate if you help with testing and read the
release notes to see if it's relevant to you.

**Mike Schmidt**: There was a couple PRs that I saw affiliated with this RC.  I
think #29899 included a bunch of backports and added draft release notes for
26.2rc1, and #30260, which includes some additional documentation, release
notes, translation updates, and a dependency update.  So, reference those PRs if
you're curious about some of what went in there.

_Bitcoin Core #29325_

Notable code and documentation changes.  Bitcoin Core #29325.  Murch?

**Mark Erhardt**: Yeah, so apparently there was a quirk in how Bitcoin Core
treated transaction versions for a long time.  And even though negative versions
never made sense, it was stored as a signed integer in Bitcoin Core's code base,
and then cast to unsigned integer basically every time it was used.  And while I
think BIP68 already required that they are treated as unsigned integers, there
was recently a vulnerability, I think it was btcd, or maybe I misremember, but
some other Bitcoin implementation had allowed negative versions on transactions,
and that could have caused a consensus failure.  So, yeah, Bitcoin Core is
updated and this is mostly a refactor, but it's sort of also a soft fork, I
guess, in that Bitcoin Core will now explicitly only treat the transaction
version as an unsigned integer, no more negative transaction versions.  And
yeah, this was a pretty involved PR, because it touches consensus code and
there's a lot of different variables that featured the name version.  So, yeah,
that's pretty much all.

**Mike Schmidt**: We covered that failure, which was in Newsletter #286, and it
was btcd that Niklas disclosed on delving Bitcoin.  So, check that out if you're
curious about what bit of history Murch just mentioned.  We have two more PRs.
If you have any questions for us, feel free to request speaker access.

_Eclair #2867_

Eclair #2867.  This allows Eclair to provide a new kind of node ID for use in
their blinded paths, that allow a wallet provider to know that the next node in
a hop is a mobile wallet.  I was secretly hoping that Val stayed on so that I
could ask her more details about that, but that's the summary of that one.
Murch, any thoughts on the Eclair PR?

**Mark Erhardt**: Sorry, I don't know more either.

_LND #8730_

**Mike Schmidt**: And last PR this week, to LND #8730, and this adds a new RPC.
It's called estimatefeerate, and it's part of the wallet RPC.  And that RPC call
takes a single parameter, which is the desired target confirmation for a Bitcoin
transaction in terms of number of blocks, and then what it returns is a feerate
estimate that LND thinks it'll take to achieve that particular target
confirmation.  I didn't look into the details of the algorithm or anything, but
it seems pretty straightforward.  Murch, anything there?

**Mark Erhardt**: No, sorry.

**Mike Schmidt**: All right.

**Mark Erhardt**: Or maybe one thing.  How does it do that?  Because LND can run
as a light client, so how would it have the information to do that?  Did you
catch that?

**Mike Schmidt**: I didn't see if there was a restriction, like if it needed to
have a certain backing or not, so I can't answer that, unfortunately.

**Mark Erhardt**: All right.  If someone knows, you can post it as a --

**Mike Schmidt**: I actually do see it here, "The source of the feerate depends
on the configuration and is either the onchain backend", so I guess that's if
you have like Bitcoin Core backing or btcd, "or alternatively, an external URL".
I don't see reference to what that URL might be, but perhaps a mempool.space or
some such thing.

**Mark Erhardt**: Evan, can you help us out here?

**Mike Schmidt**: He's given us thumbs up, so I guess we --

**Evan Kaloudis**: There's a fee URL you could pop in if you're using like a
neutrino client.

**Mark Erhardt**: So, you can configure where you would get your feerate from by
yourself as a backend?

**Evan Kaloudis**: Yeah, it's a field in the lnd.conf.

**Mark Erhardt**: Oh, cool.  Yeah, nice, thank you.

**Evan Kaloudis**: Thank you guys.

**Mike Schmidt**: Thanks for chiming in, Evan, and thanks for listening.  Murch,
we jumped around the newsletter a bit.  I think we got everything, right?

**Mark Erhardt**: Yeah, I think we covered all the topics.

**Mike Schmidt**: All right, well, thanks to our special guests, Jameson and
Val, as well as Arik and Evan for chiming in at the end, and thanks always to my
co-host, Murch, and to you all for listening.  So, we'll hear you next week.

**Mark Erhardt**: See you.

{% include references.md %}
