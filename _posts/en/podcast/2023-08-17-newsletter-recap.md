---
title: 'Bitcoin Optech Newsletter #264 Recap Podcast'
permalink: /en/podcast/2023/08/17/
reference: /en/newsletters/2023/08/16/
name: 2023-08-17-recap
slug: 2023-08-17-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Brandon Black and Dan Gould to discuss [Newsletter
#264]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-7-17/343435606-44100-2-1c3571adddb61.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #264, Recap on
Twitter Spaces.  It's Thursday, August 17, and we'll be talking about silent
payments, payjoin, some MuSig2, and more with some special guests that we have.
We have Dan Gould and Brandon Black.  We'll do some introductions and we'll jump
into the newsletter.  Mike Schmidt, contributor at Optech and Executive Director
at Brink, funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch.

**Mike Schmidt**: Hi, Murch.  Dan?

**Dan Gould**: Hi, I'm Dan, I work on payjoin.  My work's funded by OpenSats and
Human Rights Foundation (HRF).

**Mike Schmidt**: Brandon?

**Brandon Black**: Hi, I'm Brandon.  Until recently, I worked at BitGo, now
working somewhere else that I won't reveal.

**Mike Schmidt**: Oh, mysterious.  Well, let's jump into the newsletter.

_Adding expiration metadata to silent payment addresses_

Our first item is adding expiration metadata to silent payment addresses.  Peter
Todd posted this to the Bitcoin-Dev mailing list.  We actually had Peter Todd on
last week and we also had Josie on last week, Peter Todd talking about some
policy improvements that he's looking to get through and Josie talking about the
PR Review Club.  So, Murch and I are going to leave them be for this podcast,
and we're going to take this adding expiration metadata news item ourselves.

So, to give some background, silent payments is a protocol for static payment
addresses.  It lets the sender make a payment to a unique onchain address for
each payment, even if the receiver only provides the sender with one reusable
address.  So, one example usage here, the one that at least that I think of
most, is a donation address.  So you've probably seen a static onchain Bitcoin
donation address before.  All of the donations made to that same onchain address
cause some bad privacy.  Anyone can see the number of transactional donations,
the amounts, where the donated Bitcoins maybe came from on the blockchain.  And
so that's not great for privacy.

So instead, if the person wanting to collect this donation online wanted to post
a silent payment off-chain address for donations, then each donation transaction
would go to a different onchain Bitcoin address, which is much better for
privacy.  And better yet, there's no interactivity required for the person
sending the transaction and the person receiving the transaction.  There's no
need for the sender to, for example, request a new payment address every time
they wanted to send a new payment.

A little bit behind the scenes of how that works is, the recipient generates a
static silent payment address and shares that silent payment address with
potential senders and that can be something posted publicly or you could also
send that silent payment address privately as well.  And then the silent payment
address is not an onchain Bitcoin address.  It's not like a segwit v0 address
that starts bc1q or a taproot address that would start with bc1p, but silent
payment addresses do use the same bech32m encoding.  So, you might see a silent
payment address that would have an sp1 prefix, for example.  I think the initial
silent payments address version would be sp1q.  And then there's additional
versioning that we talked about with Josie last week.

So, if you have that silent payment address, now the sender has this sp1q
address that they can use, which encodes a bunch of information required for the
sender to derive unique onchain addresses for each payment.  So obviously, you
then get all the privacy benefits and it's much better than using a static
donation address.  So, to get to Peter Todd's mailing list post to the
Bitcoin-Dev mailing list, he's talking about adding expiration metadata to the
silent payment addresses.  And my understanding of the idea, Murch, is that
since the sender is already looking at the recipient's silent payment address
before sending an onchain payment, that potentially we could add in some
expiration field to the silent payment address so that a sender would see if the
expiration has passed, and then potentially the sender's wallet software would
no longer generate a new onchain address from that silent payment address or
provide some sort of warning or something.  Did I get that right, Murch?

**Mark Erhardt**: Yeah, that's how I understand the proposal by Peter.  So, the
problem would, for example, come to pass here if you created a silent payment
address, then posted it somewhere on an account that you then later stopped
using, and it would sit there and you lose eventually access to the underlying
private key material that belongs to the silent payment address.  And then
someone down the road five years later finds that silent payment address on this
disused account, still likes the content, wants to donate, and then sends funds
to this silent payment address and the receiver never even notices because they
lost access to their key material.

To curb this, the suggestion is that the silent payment addresses should always
come with an expiration date.  There were various arguments made in that regard.
There was a response by Josie saying why he doesn't think it should be at the
silent payment layer, but rather a general proposal for Bitcoin addresses.  He
said that he thinks that the problem generally exists for all Bitcoin addresses.
Anyway, there was a bit of back and forth, a few design suggestions how that
field could be introduced into the silent payment address.  Alternatively,
people also discussed that there should perhaps be a revocation system built on
top of silent payment addresses, where silent payment addresses are just the
building block, and then wallets would have other ways of exchanging silent
payment addresses and perhaps exchanging information about when a silent payment
address shouldn't be used anymore.  I saw that Brandon also participated in that
conversation.  Did you want to add something?

**Brandon Black**: No, just to say that, well, the overall idea of addresses
expiring I think is an important one for Bitcoin, whether it's done at the
individual address format or at the exchange layer.  I think the Prime Trust
incident may have been partially caused by addresses not having expirations on
them.

**Mike Schmidt**: Yeah, I think I read something similar that it sounded like
Prime Trust had retired their old wallet system and fired up a new one, except
for, I guess, nobody had access to the old wallet system and there was
potentially still deposits or whatnot being made to the old system, and that
resulted in loss of funds, it sounds like.  Is that your understanding, Brandon?

**Brandon Black**: Yeah, and we don't know if it was that people were using the
old addresses or if they deliberately started using it without realizing they'd
lost the keys, but something happened where an old address was reused for
significant deposits.

**Mark Erhardt**: Generally, it seems completely bonkers to me why anyone would
ever remove the key material, even if they retire a wallet system.  I think
that's one of the big problems with Bitcoin wallets is that you basically need
to keep access to any wallet you ever generate, just in case you receive
payments to that address or wallet again.  But yeah, you got that right, Mike.
Essentially, they received funds to expired addresses and then didn't have
access to them anymore.  So, yeah, I'm a little on the fence on the expiration
date for the silent payments.  I do follow the argument that Josie's making,
that it persists generally across the space and isn't inherent to silent
payments.

I think it's more strongly so for silent payments a problem, because you're
going to post that publicly as a static payment code for people to generate new
temporary addresses to you.  So, there's absolutely no reason for you to ever
need to remember where you posted it or to go back and update it.  So, even if
you broadly disseminate your silent payment address and then actually stop using
accounts, you may never realize that your old account still occasionally prompts
donations.  So, I think actually Peter Todd and the others that weighed in have
a good point there that perhaps silent payment addresses should be getting an
expiration date.  But anyway, I think that more conversation will probably be
had on the discussion list.

**Mike Schmidt**: We had a comment from Larry about silent payment addresses
just augmenting on this sp bech32 prefix and noting that silent payment
addresses are about twice as long as a normal, let's say, taproot address, just
due to the amount of information that's encoded in that address.  Go ahead,
Murch.

**Mark Erhardt**: That's correct, because it encodes both the public scan key
and the public spend key.  And so, yeah, it's roughly 117 characters, I think,
instead of the 60, or I think it's 64 for P2TR.  I forgot one more thing, and
now you distracted me and I forgot it again.  But, oh yeah, right.  The problem
with having an expiration date on silent payments that I think is the most
significant is, scanning for multiple silent payment addresses essentially
doubles the cost.  Sure, the information that you need about every transaction
in order to check whether it is a silent payment to you, that remains the same
for checking on multiple, but the calculations and ECDSA operations, the
Diffie-Hellman and so forth, you would have to repeat for every separate silent
payment address that you make.  So having a number of silent payment addresses
that you have posted, which would be the case if you have an expiration date on
any of them, would mean that you significantly increase the cost for scanning
for them.

**Brandon Black**: I don't think you have to necessarily change the keys
involved.  You can make a new version of the address that has an updated
expiration without changing the keys, and then wallets could use the latest
expiration.  Yeah, so I don't think that's a major problem.  You could even also
reuse the scan key, but not reuse the spend key.  So, I think the changing of
addresses and increasing the scan cost is not a major concern, I think.

**Mark Erhardt**: Well, if you reuse the scan key, then of course, people would
be able to still tie these two silent payment addresses together, which may be
one of the reasons why you wouldn't want to do that, because then you leak meta
information about yourself.  Otherwise, that would be essentially the same as
having another label for the silent payment address; if you've read the BIP,
that's fairly at the bottom.

**Brandon Black**: Yeah.  The other thing I wanted to throw in, it was
interesting, the early discussion on this BIP, how they originally, I think it
was Ruben who originally posted it, and he had talked about using optional scan
and key separation, but that got complicated in specification, so they went with
always having both keys, so that's what makes the address always be a very large
address.

**Mike Schmidt**: The details of the silent payments protocol are in BIP352 in
the BIPs repository, if you're curious.  And the silent payments team also has
some PRs to the Bitcoin Core repository to add silent payments to Bitcoin Core
and Bitcoin Core's wallet, and we spoke about this a bit with Josie last week in
the Bitcoin Core PR Review Club section, so check out Newsletter #263 for more
details if you're interested in integrating that with your wallet or service.  I
know they're looking for adoption.  Go ahead, Murch.

**Mark Erhardt**: One small correction, BIP352 has a number but has not been
merged yet.  So if you're just looking for the BIP, you might not find it
immediately.  It's a pull request.

**Mike Schmidt**: Dan, as a contributor to a privacy project, payjoin, I'm
curious as to your thoughts on silent payments.

**Dan Gould**: Silent payments are great.  I think it's awesome to be able to
have a static code to receive things without having that correlation happening
or having to run a server.  One thing I wanted to add about the expiration was
I've actually posted to the list, and one way you could solve the problem would
be by putting that expiration just in your URI because then it'd be backwards
compatible for all sorts of addresses if we wanted to do that.  You just put an
expiration field, and if the QR scanner doesn't recognize it, it can either be
ignored or you can force it to be enforced by prefixing it with the req as a
required field.  Yeah, I didn't get any comments, so I don't know if it's just a
bad idea.

**Mark Erhardt**: You mean for BIP21?

**Dan Gould**: So, you could apply an expiration date on any kind of address by
creating a new field that is inside the BIP21.  So, you can specify an amount,
you can specify a memo, you could also specify an expiration date.  And then you
wouldn't need to have every software that parses addresses figure out what the
expiration is, you could just update it in the request in the BIP21 libraries.

_Serverless payjoin_

**Mike Schmidt**: Thumbs up from Murch.  I think we can wrap up the expiration
and silent payments news item and move on to the next item of the newsletter,
which is also privacy related.  It's about payjoin, serverless payjoin to be
exact.  Dan, you joined us back in Newsletter #236 and also you were a guest on
podcast #236 on our Spaces.  Back then, you had posted to the mailing list a
"Proof of concept implementation" for serverless payjoin, and now it looks like
you have a draft BIP on the topic.  Maybe to calibrate the audience a bit, can
you give a couple-sentence summary on payjoin as it is in BIP78 currently, and
then we can go on to your draft BIP?

**Dan Gould**: Yeah, I always like to introduce payjoin with some words from the
whitepaper, the Bitcoin whitepaper, where Satoshi said that, "Transactions
necessarily had some linking between inputs and outputs because the inputs
necessarily came from the same person".  And there are a number of ways to break
that assumption, but a very common one is with payjoin.  So with payjoin, you
can have two people contribute inputs instead of just one, and by breaking that
assumption it makes it more difficult for someone trying to track your activity
on chain.  So, that is coordinated with the BIP78 standard, and the BIP78
standard uses HTTP.  So, the receiver hosts the server, the sender sends a
message to them, and they send PSBTs back and forth to produce one of these
transactions that have inputs from more than one person.

There's more stuff than just privacy you can get from that.  It's also because
you can coordinate without using the chain itself to coordinate, you can get
kind of transaction overhead reduced.  You can have some fee savings because you
can combine transactions in a batch in ways you couldn't if just one person were
coordinating a batch, as is done in exchanges today.  So, the serverless payjoin
changes that requirement where the receiver has to run a server.  Instead, a
third party can run an untrusted server that can have many receivers allocate
resources on demand to make it a lot easier to run in mobile environments, or
even for just wallets that don't run all the time and people that don't want to
manage, always on service, get a TLS certificate, secure it.  It's just a big
burden with BIP78.

So, the new BIP proposes that standard and specifies a store and forward
protocol to make it asynchronous, and the cryptography and metadata protections
around that to make sure that that third-party service is untrusted.  And the
feedback has been great so far; there's been lots.

**Mike Schmidt**: So what information -- I don't want to run my HTTP server, but
I want to do some payjoin.  So, what information do I need to provide this
server that's sort of doing the coordination on my behalf?  What do they know,
or what do I need to give them?

**Dan Gould**: So in the idealized, most advanced version of what we've come to,
the server should really only know that someone is doing a payjoin at a given
time with someone else.  We should be able to keep that server from knowing the
contents of the message, the size of the message and the IP addresses associated
with the message, as long as we're using a sound modern cryptosystem and
something called Oblivious HTTP, which is like Tor if it was a minimum viable
product, but well-supported across the internet and web standard, not some
custom binary you have to ship in all of your wallet projects separately.

**Mark Erhardt**: So, okay, maybe I just was spacing out a little bit, but you
have this server that provides the meta information about your payjoin
opportunity to a sender, but how in the first place do sender and receiver find
each other and know that this opportunity exists in the first place?

**Dan Gould**: Okay, yeah, this is a good point, which is that the requests are
made in the Bitcoin URIs, the BIP21s that we were talking about earlier.  So,
the protocol takes basically three steps.  The first one is sharing that BIP21;
the second one is the sender contacting the receiver and sending them a
proposal, a Fallback PSBT; and the third step is the receiver's response to the
sender of a payjoin PSBT that's updated that proposal.  So, there are really
more steps in between because before that request, before the URI can even be
produced, the receiver needs to talk to the relay in the middle and let them
know they plan on payjoining and to have them allocate some space.  That is
defined in the protocol as just a message asking.

I think there are DoS considerations that haven't been completely addressed yet.
In the BIP, I just say you can put some sort of authentication token here, but
in practice, we may see that change.  The reality is also that servers are
relatively cheap and all these wallet providers run some services for their
clients anyway, and one of these services could be used across many wallets.
So, you have that allocation, and then once that allocation exists on the relay,
the relay can return the receiver an endpoint that describes that relay.  The
endpoint is identified by the receiver's public key, so that the sender can
encrypt messages there and know that only the receiver will be able to decrypt
them and modify them.  And the protocol proceeds from there.  The sender shares
their key and the receiver is able to encrypt messages to give them back to the
sender without the relay being able to see those contents, being able to steal
funds, or even being able to unwrap the payjoin, so to speak, itself.  The
payjoin relay doesn't get any privileged information about the transaction
structure that would break down privacy.

**Mark Erhardt**: Okay, one follow-up question.  So, at what point would the
receiver establish the relay for the payjoin?  I assume that it couldn't be
initiated by the sender, as otherwise the sender might be able to sort of
initiate a lot of payments to the receiver and thus get to know the receiver's
UTXO pool.  So, I assume that it is established by the receiver generating an
invoice or having a payment request in the first place for the sender, and then
immediately establishing the allocation on the relay and the endpoint, and
putting that into the invoice for the sender.  Is that how it works, how it
starts?

**Dan Gould**: Yes, that's right.  To prevent that attack where the sender would
probe the receiver for their inputs, the receiver doesn't provide any response
until it gets a valid fallback transaction from the sender.  So, in the worst
case, the receiver can always spend the money from the sender without those
privacy protections for that sender.  So, the sender provides something of value
first, and it's in both the sender and the receiver's benefit to cooperate.  But
if they don't cooperate, they will not reveal the insides of their wallet.

**Mark Erhardt**: Oh, okay, so the sender basically is providing some initial
trust by giving the receiver a self-send, which would of course cost the sender
at least a transaction fee.

**Dan Gould**: It's not even a self-send.  It's actually, I call it the Fallback
PSBT, but it's a transaction that would pay the requested amount, but in a naïve
way; so, just having the sender's inputs, a receiver output and change, and then
the receiver gets that and adds their input and augments their own output to
turn it into a payjoin.  But that first Fallback PSBT is just a regular
transaction that's kind of held as a fallback in case things go wrong.
Typically it's not broadcast, but if for some reason the sender goes offline
because they're trying to probe, or they just disappear, it's an automated
system that will get broadcast; but if you know it's your friend next to you
trying to make a payment, you don't have to broadcast in that situation.

**Brandon Black**: Why use a PSBT for that fallback transaction versus just a
fully signed network transaction?

**Dan Gould**: So it is fully signed.  The reason it's a PSBT is because you
want to modify it and you want to have some UTXO information in order to -- what
do you need the UTXO information for?  You need the UTXO information in order to
calculate the fees and know the size.  So, the receiver benefits from having
that information.  And if you just have your raw transaction, then you need to
also have the complete UTXO set so you can look up the UTXOs and create these.
So, if they're just in the PSBT, it's a lot easier to deal with.  And I propose
we update to PSBT v2 because the first version of PSBTs isn't meant to have the
input and output maps updated once the transaction is built.  You either create
a new PSBT with new inputs and outputs, or you don't change things at all.  And
of course, in the payjoin protocol, we move these things around, so it's a lot
easier to use the new format.

**Mark Erhardt**: So, the PSBT would serve both as the schema for the recipient
to add their own input and increase the recipient amount, and also as the
fallback mechanism with which it can just make sure that it does get paid.  That
was, by the way, the part that I was missing.  Thanks for elaborating that.

**Mike Schmidt**: Dan, you mentioned feedback was good to the mailing list post
in the draft BIP so far.  Maybe you can comment on what we highlighted in the
newsletter here, Adam Gibson warning about the encryption key within the BIP21
URI; you want to just comment on that quickly?

**Dan Gould**: Sure thing.  Yeah, the first version of this and the first
version of the BIP that I posted didn't use public key cryptography, they used a
secret that was also shared in the BIP21.  And Adam said, "This might not be
safe", and I figured out that it's really not safe to use a secret in the BIP21
URI for two reasons.  One is that users don't keep those secret.  People will
post a Bitcoin address in unencrypted chat.  They don't expect that they'll lose
funds when that happens.  It's best for privacy to keep those things secure, but
they don't expect to lose funds.  But if the secret is in the URI, not only
could a relay figure out that secret if it was leaked, say, in a group chat, and
find the contents of the message to break privacy, but could actually also steal
funds during the protocol if they knew the key, because that payjoined PSBT can
update the outputs, including the address; and if the update were to an address
that's not the receiver, then funds would be stolen.

So, this is relatively easy to fix with public key cryptography.  And we've kind
of been able to move on to some metadata leaks.  Adam brought up the fact that
the size of the message and the timing and payjoins that come onchain within a
certain window create an intersection of things that can be used to de-anonymize
the payjoin transactions, so we need to be very careful with how we handle
those.  Some other interesting feedback was about encoding pubkeys in URIs,
which I didn't know about before, but there's a Blockchain Commons scheme,
called UR, that reduces the size of QR codes if you encode that way.  And there
have been a few proposals using Nostr, which suffer from some of the metadata
problems as the original proposal of this.  So, it's evolving and if there's
more feedback, I'm definitely interested in hearing it.

**Mike Schmidt**: Dan, we also covered a Payjoin Development Kit back in
Newsletter #260 in our monthly segment on Client and service software
highlights.  You were not on for that one, so maybe you want to plug that effort
before we hop off?

**Dan Gould**: Sure, yeah, and I think this gives the opportunity to kind of
paint a broad stroke about what I'm trying to do to address Bitcoin privacy and
what I feel would be the best thing for the community.  So to start with,
Payjoin Dev Kit, the privacy solutions in the Bitcoin space have largely relied
upon specific applications before.  So, you have to use this app to coinjoin,
you have to use this one to coin swap, you have to use this one for statechains,
and it creates a very fragmented Bitcoin userbase about both what the best
practices are, and then the actual number of transactions that look like one
another, that have the property that you can't tell them apart.

So, because payjoin is steganographic, we call it, you can't tell it apart from
other typical transaction activity, I started focusing on that.  And in order to
get it in all these wallets that aren't siloed into one application, I started
to follow the Bitcoin Dev Kit, Lightning Dev Kit direction that we've seen the
space have a lot of success with so far.  So, writing the systems code in Rust,
that way it can be tested for correctness and be high performance.  It also
allows us to bind it in a number of other languages, so we can build the library
one time and run it from JavaScript and run it from C# and run it from Python.

Lastly, and I think most importantly, we can combine our efforts as engineers on
one codebase that gets reviewed very well, then gets tested very well.  And this
relates back to the bigger project of deploying serverless payjoin.  Because HRF
put a bounty out early this month, I think there is naturally competition,
people want to get that.  And at the same time, it's very important for Bitcoin
that the protocol that comes out of this has some idea of consensus around its
deployment, because it only really works if as many people as possible deploy
it, if everyone supports it.

In the past, we've had payjoin, and some of the barriers to adoption have not
only been technical, a lot of them have been political, unfortunately, driven,
in my view, by some zero-sum competition.  And the benefit we have by having
this project funded by OpenSats and not having to chase a profit motive is we
can do the research and take our time, to some extent.  Time is of the essence,
unfortunately Bitcoin does have enemies, but we can take our time to create a
secure protocol that addresses all of the needs of the industry players and the
wallets and delivers a good product to the users.

So, my focus right now is on getting that unity and that's why I'm going through
the BIP process for the first time, collecting this feedback and hoping and
knowing we will come to rough consensus to deliver this; because if we don't,
then the bounties will dry up.  I think if the resources don't end up paying for
a successful outcome, if they create some short-term, "Deliver this DM spec",
that nobody ends up using, then it's just not going to happen again.  So yeah, I
think unity is really important.  And if you're interested in contributing to
any of this kind of stuff, payjoindevkit.org is where the blog started, some
documentation is, there is a link to the Discord, and then of course the BIP
will continue to be developed on the mailing list and in those forums.  So yeah,
I'm very hopeful, and thanks to Optech for giving me a platform to share today.

**Mike Schmidt**: Murch, any questions or comments before we move on?  All
right.  Well, Dan, you're welcome, thank you for joining us.  You're welcome to
stay on.  We've got a pretty cool field report about MuSig2 that we're going to
jump into now.  Otherwise, if you have other things to do, you're free to drop.

_Field Report: Implementing MuSig2_

Next section of the newsletter is a field report about MuSig2.  So periodically,
we have projects and companies that are implementing interesting Bitcoin tech,
author guest post, that we call a field report for the Optech blog, outlining
best practices and lessons learned to share with the broader community.  A few
weeks ago, we highlighted BitGo's announcement of using MuSig2 on their
platform, and we were lucky enough that BitGo engineer, Brandon Black, who was
instrumental in BitGo's MuSig2 rollout, happened to be on our Twitter Space and
opined on it.  So, I asked him after the podcast if he was up for writing a
field report for Optech, and I think it was just a day or two later, he had a
great draft that you guys see now ready to go.

So, Brandon, from some Twitter feedback I've seen, the community really loved
your writeup, so thank you for that.  Do you want to walk through some of the
highlights of the report?  And I'll also maybe solicit any questions from the
audience for Brandon, if there are any, as he walks through the writeup.

**Brandon Black**: Yeah, sure.  Yeah, thanks a lot for inviting me to write
this.  I was able to turn it around fast because I'd just recently written the
blogpost at BitGo for it as well, so I'd kind of the right the right context to
write it up pretty quickly.  I think really I'm going to in some ways jump to
the end with my biggest highlight from it, which is as companies being involved
in the Bitcoin process is so important, that I think it ties into what Dan was
talking about, kind of getting unity and getting the right people involved to
make protocols actually get into the real world.  So BitGo, we were interested
in MuSig from the very beginning of taproot, and so we got in touch directly
with Jonas Nick, who was working on the spec, and talked with him about how we
wanted to use it early on so that he could make sure that our use case was well
covered and got even one specific aspect added to the spec that helped us
implement.  So, that's really the biggest highlight that I thought was really
important to talk about for all of us that work in the corporate Bitcoin space.

Getting into it a bit more, the other things we cover in the field report here,
it's been really interesting looking at the trade-offs of using taproot outputs
versus other previous types.  Obviously, Murch has the great blogpost he wrote
years ago about the trade-offs of input sizes with different ways of doing
multisig on taproot, which plays into how you use MuSig2 as well in taproot.
So, we went through a bunch of the trade-off analyses there in designing our
implementation.  And the other thing that was, I think, worth highlighting is
the simplicity of MuSig2.  As I mentioned in the writeup, it can be implemented
in 461 lines of Python.  I've implemented it twice now, once in JavaScript and
once in C,  and both implementations are very easy to reason about, very easy to
understand.  And it is very easy with an implementation of MuSig2 to reference
it back to the great spec that Jonas and Tim and Elliott wrote, and verify that
the implementation is correct.  So, if you hire a firm to analyze the
correctness of your implementation back to the spec, it's very easy to do with
MuSig because the spec is so well-written and so simple, you can be very
confident in your deployment of MuSig2.  So we were very, very happy about that.

I think really worth highlighting is nonces in general.  I think this is going
to be the greatest challenge of MuSig2 getting rolled out more broadly early on
in -- actually, I shouldn't even say early on.  One of the most common attacks
on Bitcoin wallets is badly generated nonces.  I just saw a tweet yesterday
about some wallet that was using half the message and half the pubkey or
something as the nonce.  And for plain ECDSA or for plain BIP340 schnorr
signatures, we have a very well-defined deterministic nonce mechanism which
protects users from all those nonce pitfalls.  And with MuSig2, unfortunately
you can't use those off-the-shelf deterministic nonce protocols.  Jonas and team
did a great job of specifying how to produce a good nonce for MuSig2, but it's
then left to the implementers to manage those nonces, to not store the secret
nonces and let them be reused potentially.

So, you have to think about in what cases could an attacker halt the protocol
while you have a secret nonce, and then restart it in a way that causes you to
reuse the secret nonce.  All those kinds of problems that we avoid with
deterministic nonces in one-signer protocols now rear their heads in
multi-signer protocols.  So, just something to really pay attention to as we
roll this out more into the community when we're auditing wallet
implementations, check on how they manage the secret nonces.  Yeah, I think
that's the highlights.

**Mike Schmidt**: Murch, what do you think, BitGo rolling out MuSig2 and some of
choice of scripts here in the nonce discussion?

**Mark Erhardt**: Yeah, I'm really happy that you guys came through on that and
added taproot support the weekend after taproot activated.  And then, well, I
guess you did have to come up with another address type because the first one
wasn't compatible with the final MuSig spec, but that's really continuing the
tradition.  We rolled out segwit two weeks after segwit activated.  Well,
wrapped segwit, to be honest.  But yeah, anyway, I'm pretty happy that you all
managed to do that.

**Brandon Black**: Yeah, we had to follow your footsteps, man.  Yeah, and the
good thing about the fact that we couldn't use the original address type, or we
couldn't reuse it for MuSig2, is that we did make a more compact script tree in
the second address type.  So now, we have one address type that's focused on
your very cold offline where everything is a script, and then a separate address
type that's focused on your very fee-sensitive hot wallets that pay a lot of
transaction fees.  So, I think it's a good disjunction, actually.

**Mike Schmidt**: It's a great example, this field report, and what you guys did
to contribute to the spec.  I didn't have any idea until we spoke how involved
the BitGo team was with reviewing and contributing to this work.  We sort of
know that the folks like Jonas Nick, and some of the Blockstreamers were doing
some research on this, but it's nice to see, especially as part of Optech's
mission is to sort of bridge the gap between what's being worked on, sort of in
the open-source realm, with what's going on in industry, and this is like a
perfect example of that.  So, applause to you guys for your involvement.  Murch
or Dan, any other questions or comments on the field report?

**Mark Erhardt**: Maybe one more comment.  I think people that have an
enterprise in the Bitcoin space and are looking at whether to implement ECDSA
MPC in order to have single-sig and save costs, while under the hood they may
have multiple signers, just as they could have with on-script multisig and then
have the additional cost of having a bigger script and a reduced privacy for
obviously standing out among mostly single-sig transactions, I think that using
P2TR is by far the best approach to achieving both of those goals; a smaller
output type that has a lower onchain cost, as well as blending in with the
single-sig.  So, I hope that this example is followed by other wallets that use
multisig for the security benefits but don't want to have it at the cost of
having larger output types.

**Brandon Black**: I think even to put that farther, by Bitcoin adding taproot,
it enabled this with this simple protocol versus other coins out there that
don't have onchain multisig and don't have taproot, force companies to do harder
things to achieve that fee savings, whether that's using these complex MPC
protocols or other ways of avoiding those fees.  So Bitcoin, people tease about
Bitcoin Core developers not doing what the industry needs, or whatever, but
taproot's a great example.  It may not have been accessible immediately on
taproot's launch, but it's exactly what the industry needs to be able to provide
the security without a cost increase.

**Mark Erhardt**: Oh yeah, one more comment.  So, one of the reasons why we
pushed so hard back in 2017 to roll out segwit support at BitGo was that, that
year was one of the first that saw a lot of higher feerates.  We've had periods
of higher feerates before, but in 2017 they became a lot more frequent and a lot
more explosive, in that people were almost always still trying to be in the next
block, so they would overbid each other drastically.  And in the winter of 2017,
we saw feerates over 1,200 sats/vbyte.  So, if you at that point can reduce the
input size of your standard transactions, especially on a high-volume wallet
like an exchange, that probably receives in the hundreds of UTXOs per day in
deposits and probably makes hundreds of transactions and withdrawals, then
taking it from 2-of-3 multisig, even with P2WSH that has 104.5 vbytes per input,
to 57.5 vbytes per input is like 43% cost reduction on your inputs.  And you
will feel that, especially when the feerates go up, as we saw in March again
with the BRC-20 nonsense.

So, yeah, I think that for companies, especially high-volume users, this is
awesome.  And it also has an effect on the overall ecosystem because if the high
volume users switch to these more block-space-efficient output types, it also
reduces the block space demand that others have to compete with.

**Brandon Black**: We were wishing we could have launched this sooner during
those high feerates early this year, but we just were not ready.

**Mike Schmidt**: I saw some commentary on Twitter, folks asking for more field
reports.  I do see a miniscript maximalist in the Twitter Space, and maybe we
would need to tap on him to get a miniscript field report at some point.  But
it's good to hear that the community got a lot of value of your writeup,
Brandon, so thanks again for doing that.

_Core Lightning 23.08rc2_

All right, next section from the newsletter is Releases and release candidates.
We have one this week, which is Core Lightning 23.08rc2, a release code named
Satoshi's Successor.  We don't like to spoil new releases too much in their
release candidate stage, but I'll call to action anyone using Core Lightning
(CLN) as their backend to check out a bunch of new RPCs and RPC improvements:
the renepay plug-in we spoke about last week with Eduardo; and also, the new
REST API service that I think we spoke about with Lisa previously.  So, if
you're interested in any of that and you're using CLN as your backend, maybe you
want to test some of that out for these folks for the release candidate.  Murch,
any comments on that release?

**Mark Erhardt**: I have not looked at it at all yet.

**Mike Schmidt**: Notable code and documentation changes.  I'll take this
opportunity to solicit any questions from the audience.  If you want to request
speaker access or leave a question or comment on the thread in this Twitter
Space, we'll try to get to that by the end of the show.

_Bitcoin Core #27213_

First PR is Bitcoin Core #27213.  This PR attempts to open a connection to at
least one peer on each reachable network, including Clearnet or CJDNS, for
example, and then will also prevent any sole peer on any network from being
automatically evicted.  And the result of that is that it could reduce the risk
of eclipse attacks of a particular node, and also prevent accidental network
partitions where a network of nodes, say on CJDNS, all get cut off from the
other networks.  Murch, I know you have some familiarity with this topic.  What
would you add to that?

**Mark Erhardt**: So, if you run a Bitcoin Core node on your machine and you
already have Tor configured on your machine, it will automatically connect to
the Tor network.  I don't know if many of you are familiar with that or didn't
know that fact.  So, if you just run it on a regular box, of course, you'll only
make Clearnet connections, but any other networks that are already configured on
your box, your node will automatically make connections to.  And generally, of
course, I guess there would be way more Clearnet nodes than any of the other
networks.  I think that we have a quite substantial number of Tor nodes, I think
mostly because it's one of the easiest ways to pierce through NATs.

If you have a network or your internet provider doesn't make it easy to open up
ports on the Clearnet and you cannot turn your node into a listening node where
you serve light clients and get inbound connections in general, then enabling
Tor is an easy way to get more peers on the Bitcoin Network.  So, a lot of
people, especially node-in-the-box setups, automatically have or come with Tor
support in order to make use of that.  But you wouldn't want to drop all
connections to one network.

Even when you have way more Clearnet nodes, they shouldn't displace the last one
to the other networks, and that's what this PR does; it just ensures that you
always at least have one connection to any of the networks and that way, it
helps against eclipse attacks, which are actually easier on Tor than on
Clearnet, because on Clearnet we can already look at the region of an IP address
and make sure that we diversify that.  And then it's way harder for an attacker
to try and push out all of our existing connections.  Whereas on Tor, it all
looks like a single region essentially, and someone spinning up thousands of Tor
nodes to hammer our inbound requests would have a way easier time to try and
take over our connection space in Tor.

So anyway, having diverse connections will make it easier for you to have at
least one honest peer in order to stay on the best chain.

**Mike Schmidt**: Murch, is there any consideration about how that peer on that
one network that you may be holding on to from automatic eviction, it doesn't
matter how good or how poorly it's performing, it still will be retained as a
peer regardless, I guess, as long as it's not doing anything malicious, but if
it's just slow, for example; would it get evicted or it just will keep it for
this contingency reason?

**Mark Erhardt**: The last one is generally protected.  We will not evict it
before we have another connection in the same network.  I know that there are
various ways how we cycle out peers.  Generally, we will keep all peers that
we're connected to unless we get a new peer that supersedes one, so if we have
reason to have less preference for a peer, for example if they were slow and
haven't sent us a block or a transaction as the first one in a long time, or I
think there's also some other patterns that we set a peer to be the designated
disconnect on the next request.  But yeah, so if we wanted to get rid of our
last Tor node, for example, Tor peer, we would make first another connection on
the Tor network before we drop it.

_Bitcoin Core #28008_

**Mike Schmidt**: Next PR that we covered in the newsletter is Bitcoin Core
#28008, which adds encryption and decryption routines planned to be used for the
implementation of v2 transport protocol, which is specified in BIP324.  So, this
is the essentially opportunistic encryption between nodes.  If you click on the
#28008 PR that we had in the newsletter here, you'll see a reference to the
parent or tracking issue for BIP324, which is #27634.  I'm such a sucker for
these tracking issues because it lets you see a high-level perspective of
projects in which a bunch of PRs are independently in the repo kind of stitched
together with these tracking issues.  So, you'll see a checklist of all the
planned tasks to bring BIP324 to Bitcoin Core.  It gives you a great overview of
the progress made and the planned future work for the initiatives.

We noted in the newsletter writeup this week the different ciphers and classes
that were added, although I can't speak to the details of any of them.  Murch,
do you have comments on these ciphers or BIP324 in general?

**Mark Erhardt**: Well, so probably a lot of you have heard that we've been
working on a v2 protocol, a new protocol for how nodes communicate with each
other.  The regular old v1 P2P protocol is unencrypted, so for example, your ISP
will be able to immediately determine that you're running a Bitcoin node, will
even see what blocks and transactions you're forwarding and receiving from other
peers.  With the v2 protocol in general, all traffic between Bitcoin nodes would
be fully encrypted, and this would just make it harder for a passive attacker to
listen in on the network traffic.

So obviously, a lot of the stuff that full nodes converse about is completely
public knowledge, so that isn't super-scary that it is visible to, for example,
the ISP.  But one of the benefits that we would achieve with this is that, for
example, other traffic can hide by mimicking the P2P traffic of Bitcoin nodes
and look like Bitcoin node traffic to the passive observer.  So, for example, I
don't know, a data transfer protocol could mimic the traffic of a Bitcoin node
and then not stick out, or a messaging protocol that provides encrypted
messaging might look like Bitcoin traffic and hide within the network's traffic.
And then there's other ideas on what we can build on top of that.  Like, yeah,
let's get into that when it's more public.

But anyway, the V2 protocol has been first proposed, I think, in 2015.  So, this
has come a long way since, and yeah, it's starting to look pretty close to
getting done.

**Mike Schmidt**: This is a great newsletter to see the progress of Bitcoin
tech.  We have innovations that have been in progress for a while, like silent
payments in BIP324, getting PRs to Bitcoin Core; we have existing tech like
payjoin getting improved with the work that Dan is doing, as well as efforts to
bring that tech to market using the Payjoin Development Kit library; we have the
MuSig2 rollout from BitGo, seeing some of the techs from years past getting
rolled out to industry and to a wide variety of users; we have this Bitcoin Core
#27213 from a security and eclipse attack perspective getting merged.  It's one
of those newsletters where you can kind of feel the innovation moving forward
and some of the older projects getting adoption and newer projects getting
traction.  So great to see this #28008 PR.

_LDK #2308_

We have one more PR this week, which is LDK #2308, which adds support for
sending and receiving custom TLV records, TLV standing for Tag-Length-Value
records within a payment.  That allows users to send extra application-specific
data along with a payment, assuming that you have a compatible receiver who can
extract that custom metadata from the payment.  Murch, any thoughts on this LDK
PR?

**Mark Erhardt**: I just noticed a typo.  I think TLV actually stands for
Type-Length-Value!  But anyway, yeah, it sounds like a good idea to be able to
attach additional information to invoices that are transferred out of band
anyway, mostly.  Maybe after BOLT12, we'll see some in onion messages as well,
but just a few bytes here and there wouldn't really be much of a burden, and it
might sponsor some new or inspire some new use cases, so pretty cool.  Also, I
think this was probably the most privacy-heavy newsletter we've done in a long
time, so maybe that's why we're having so much fun here.

**Mike Schmidt**: Well, thank you to Dan and Brandon for joining us and talking
us through the great work you've been doing, thanks always to my co-host Murch,
and thank you all for taking the time out of your day to hear about Bitcoin
tech.  We'll see you all next week.  Cheers.

**Mark Erhardt**: Cheers.  Hear you soon.

{% include references.md %}
