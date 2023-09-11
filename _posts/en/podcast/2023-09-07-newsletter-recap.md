---
title: 'Bitcoin Optech Newsletter #267 Recap Podcast'
permalink: /en/podcast/2023/09/07/
reference: /en/newsletters/2023/09/06/
name: 2023-09-07-recap
slug: 2023-09-07-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Tom Briar and Nick Farrow to
discuss [Newsletter #267]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-7/346112830-44100-2-93f3057f30783.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #267 Recap on
Twitter spaces.  It's Thursday, September 7, and we'll be talking about a
proposed specification for Bitcoin transaction compression, privacy enhanced
co-signing, and the FROST scriptless threshold signature scheme, and more with
our special guests today, Tom Briar and Nick Farrow.  I'm Mike Schmidt, I'm a
contributor at Optech and Executive Director at Brink, where we fund Bitcoin
open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch.  I work at Chaincode Labs on Bitcoin things and
I'm currently at TABConf.

**Mike Schmidt**: Tom?

**Tom Briar**: Yeah, I am a Bitcoin Core basically apprentice developer and I've
been working on this Bitcoin transaction compression scheme.

**Mike Schmidt**: Nick?

**Nick Farrow**: Hey, I'm Nick, I just got back from Baltic Honeybadger, which
is a lot of fun, and I'm working on next generation multisig with Frostnap using
FROST cryptography.

**Mike Schmidt**: Well, thank you both for joining us.  For those following
along, this is Newsletter #267, and we're just going to go in order here.

_Bitcoin transaction compression_

The first news item this week is Bitcoin transaction compression.  Tom, you've
collaborated with Andrew Poelstra on a scheme for compressing Bitcoin
transactions into smaller sizes.  Just to clarify, this isn't a proposal for
parsing compressed transactions around on the Bitcoin P2P network, right?  Maybe
you can get into the motivation of this proposal and maybe some of its intended
uses, and we can go from there.

**Tom Briar**: Yeah, so it is not currently supposed to be used for P2P
communication, mostly because it relies on the blockchain data to do a
percentage of its compression.  That said, there is still room for compression
for the P2P transactions, but not nearly as much as the schema that we've
devised.  The intended uses for it right now are mostly like steganography uses.
So, I had originally planned on building a steganography application, and then I
realized that, or we realized that we would like to have a smaller transaction
compression or serialization because that would significantly increase the
security of steganography applications.  A couple of other side-effect uses
though are other low bandwidth channels like satellite broadcasting or radio
broadcasting and the like.

**Mike Schmidt**: Tom, maybe elaborate a bit on why a smaller transaction size
would be more secure for a Bitcoin transaction in a steganography context?

**Tom Briar**: Yeah, so the steganography schema we're working with is one that
requires you to encrypt the data that you're trying to parse along, so in this
case, a Bitcoin transaction.  And then once we encrypt it, we run a bit of an
algorithm to make it look random.  And then we try and insert that
random-looking data into random parts of an image.  Traditionally, steganography
is you have some sort of key that describes where you put the data in the image,
but it's not put in the image in any way that's supposed to be secret, so to
speak.  In this schema, we're basically taking the random parts of the image and
just replacing it with the random-looking data we have, and essentially
broadcasting where the data is going to be.  But even if you have access to the
key, you can't find the data unless you can decrypt it.

So, the main application for the compression side of things is that when we try
to encrypt it, the less data that we have to encrypt, the less data we have to
encode, the less chances there are for us to screw up and change something that
isn't perfectly random, and then would let people know that there is something
encoded in the image.

**Mike Schmidt**: Tom, is there a name for this project that you're doing the
steganography work for?

**Tom Briar**: Not really, not any fancy name.  It's basically just
steganography for sending Bitcoin transactions.

**Mike Schmidt**: We can get into a couple of the big wins you have in terms of
size savings and the techniques you use, but first I wanted to maybe give the
audience an idea of what sort of size savings can users of this compressed
transaction scheme expect for common types of transactions?

**Tom Briar**: So, it really depends on the type of transaction, and I'm still
making changes to the schema in order to get exact data, based on the historical
transactions in the blockchain.  But with me just randomly creating transactions
with a bunch of random data and then compressing them, I get about 35%
compression.  And that does not include a subset of transactions that we intend
to use for steganography.  In that case, I expect to get 60% or more compression
based on this subset of transactions that are going to be widely used in the
steganography project.

**Mike Schmidt**: Along with the writeup of the approach, you also have a draft
implementation for Bitcoin Core.  It looks like in that draft implementation,
the main way of interacting with compressed transactions is via a new
compressrawtransaction RPC, that takes a transaction in hex format as an input
and returns a compressed version of that transaction using your scheme, and it
returns that also in hex format.  Is that right?

**Tom Briar**: Yeah.

**Mike Schmidt**: Maybe we could jump into a couple of the technicals here.  You
mentioned in some of your write-up the that, "The bulk of our size savings come
from replacing the prevout of each input by a block height and index".  Maybe
you want to just elaborate briefly on that?

**Tom Briar**: Yeah, so what we're doing here is, the txid for the specified
input is 32 bytes and the vout is 4 bytes.  And so, by taking the fact that the
txid is indexed in the blockchain and assuming both the compressor and the
decompressor have access to a full blockchain, we can encode just the block
height and then the index of the block that the txid is contained in.  And then,
I can get a few more bits of savings by going in and indexing through the vouts
as well as the transactions themselves, but that saves me roughly 7 bytes or so
from just a traditional VarInt.

**Mike Schmidt**: And we mentioned this in the writeup, but if you're using
block height, it sounds like the recommendation is to only use that for a
transaction that has at least 100 confirmations.  Is that right, due to a reorg
concern?

**Tom Briar**: Right, yeah.

**Mike Schmidt**: There's a couple of other pieces we noted about the proposal.
We just talked about one of them there.  Do you want to highlight any of the
other two that we put in the newsletter, or any other of the discussion that
happened around other potential approaches?

**Tom Briar**: Yeah, so I got a lot of feedback on the txid and vout
compression, and one of the proposals was that we might encode the block height
of the input that is the furthest back.  So, if you have an input from block
100,000 and a block from 200,000, we'll just encode the number 100,000; and then
the index for the second input will be 100,000 plus whatever its actual index
is.  And it's a little more complicated than that in order to save a couple of
bits, but that was one of the high-level things.  The main spot that we get
compression from is the txid encoding, although for legacy inputs, such as
pretty much anything except taproot, I can basically replicate the taproot
compression that was introduced for taproot signings by basically doing the same
thing, public key recovery as well as the compressed transaction or compressed
signature schema that is already in existence.

**Mike Schmidt**: Nick, I see you have a question.

**Nick Farrow**: Yeah, I was just wanting to understand this reorg risk a little
bit more.  So, you say if there's an input to the transaction that is less than
100 confirmations, you just encrypt the entire txid.  What is the risk here?  If
I want to encrypt a transaction to someone and one of the inputs gets reorgd and
it no longer exists, like what's the actual risk there?  Wouldn't it just be
like gibberish to the person who decrypts it?

**Tom Briar**: Pretty much, yeah.  If you have a reorg and you've got the block
height and block index of the txid that you're trying to get, the reorg is going
to put it at pretty much anywhere within those 100 blocks, I believe, and that
would cause problems.

**Nick Farrow**: But are the problems, like, is there any financial risk or is
it just that the scheme is not really going to make sense any more, that the
person who decodes this transaction is going to get something that is useless to
them?

**Tom Briar**: Yeah, there's no financial risk because the transaction,
worst-case scenario, just doesn't get broadcast.  So, the steganography scheme
would be like, you create this transaction, you put it in the image, and you
send the image to somebody.  And then, if they can't get the transaction out,
then you just couldn't send your money that time, and you just retry.

**Nick Farrow**: Cool, thanks.

**Mike Schmidt**: Tom, we alluded to it briefly in this discussion, but maybe
talk about the downsides of this proposal in terms of CPU memory, etc.

**Tom Briar**: Yeah, so for most transactions that you're going to compress,
you're going to be using taproot hopefully in the future.  And so that means the
main savings you're going to get is from the compressed txid.  And so, when I
have to go through the txid, I have to index to the block height, and then
inside the block, I have to go through all the transactions and all the vouts up
to the index of the vout that I'm looking for.  And so that isn't entirely, how
would I say it, intensive as far as CPU or memory usage, but it does require
some usage.  For the legacy inputs though, if you are using those, you are going
to have a bit more CPU usage, because you have to recover the public key and
then decompress the signature.

Oh, and there's one other thing.  If you have a locktime, instead of encoding
the entire 4-byte locktime, we'll just encode the 2 least significant bytes and
then grind through the locktime, meaning that we try locktime plus 1, plus 2,
plus 3.  And every time we do that, we have to regrind the signature to see if
it works, and that can get pretty CPU intensive as well, although I don't
suppose many transactions for steganography are going to require a locktime.

**Mike Schmidt**: You mentioned in your writeup somewhere, "That means
high-bandwidth connections will likely continue to use the regular transaction
format, and only low-bandwidth transmission will use compressed transactions",
so I guess that's a natural consequence of some of the intense CPU potential
that you mentioned here?

**Tom Briar**: Right.  So, for historical transactions like I was talking about,
or like you were talking about the P2P compression, grinding the public key
recovery is not a very efficient way if you have to do that for every
transaction at every block.  If it's a one-off use case, you can get away with
quite a bit of this stuff and you can use this compression schema for regular
transactions.  The only downside is it's an extra step and it saves you like 30%
on your size.  And if you have a high-bandwidth channel, it's probably not worth
the extra bit of complication.

**Mike Schmidt**: Is there any other feedback on the proposal or implementation
that you think would be notable for the audience?

**Tom Briar**: Yeah, so for the ideal transaction that we would like to see sent
through the compression, it's pretty simple.  The scheme is just less than four
inputs and less than four outputs, and then don't have a unique hash type, a
unique output script, a unique signing script.  Pretty much keep it pretty
generic, and we can get you up to 60% to 65% or more, I'm not sure on that yet,
of compression, even for regular transactions that you'd like to send.

**Mike Schmidt**: Murch or Nick, any other comments or questions before we move
on in the newsletter?

**Mark Erhardt**: That sounds really cool.  I was just wondering, so you said
that it would be, of course, for low bandwidth.  What would that be?  So
satellite, yes, I see that.  Is this for, say, transferring transactions via SMS
in areas that don't have internet connections, or putting -- well, yeah?

**Tom Briar**: So, as long as they have a full blockchain, they can get away
with the compression schema and get significant compression out of it.  If you
don't have access to a blockchain or the ability to grind through the signature,
which requires the Bitcoin Core secp256k1 library, you're not going to be able
to use the compression schema.  But yeah, there are places where if you have
both of those but you just can't transmit it over the internet, places that have
capital control or places that want to tax remittances or something and you want
to just securely send off a transaction, then this schema is perfect.

**Mike Schmidt**: Tom, thanks for joining us and explaining your proposal.
You're welcome to stay on, but if you have to drop, we understand.  Thanks for
joining us.

**Tom Briar**: Thank you for having me.

_Privacy enhanced co-signing_

**Mike Schmidt**: Next item from the newsletter is privacy enhanced co-signing.
And we have the author of this mailing list post, Nick, here to talk about this.
Nick, you posted on the Bitcoin-Dev mailing list about how FROST can improve the
privacy of users that use collaborative custody services, which in the writeup
we referred to as co-signing services.  Maybe to frame the discussion a bit, can
you provide a description of a co-signing/collaborative custody service and how
privacy is bad currently for users using such a service?

**Nick Farrow**: Yeah, sure.  So, I'll try to be careful not to name any
specific services, but so the co-signing services as they're used today in
Bitcoin, the idea is that you have a multisig, so maybe you have a 2-of-3
multisig, and you keep two keys and you give the third key to a third party.
What this means is that in your day-to-day Bitcoin operations, whenever you want
to spend bitcoin, you can sign on your two keys that you have, but if you were
to ever lose one of those two keys, you could reach out to this third-party
co-signer and ask them to help you sign.  So, you produce one signature and they
produce the other signature and then you're able to spend your funds, even
though you've lost one key.  So, it's commonly most used as sort of a backup
service, that you can give a third party a key and if you actually lose one, you
can get their help with signing things.

Maybe one thing to add is, so commonly at the moment, this is done through
script multisig.  And so script multisig, the way I like to think of it is you
have sort of like n smaller locks comprising a bigger lock that you need to
unlock some threshold of these smaller locks, say 3-of-5 or 2-of-3, in order to
spend the bitcoin.  And because there are these sort of n public keys in the
Bitcoin script that you have to publish onchain, this has a lot of follow on
effects for privacy.  And so, one of the things we're working on is FROST.
FROST is a cryptographic signing scheme that allows you to do a multisig through
mathematics as opposed to Bitcoin script.  So, the threshold nature comes from
something called interpolation as opposed to codified conditions in Bitcoin
script.  And the really cool thing about FROST is that you have a single public
key to represent the multisig, and you can have the private key to this single
public key sort of shared amongst multiple people or multiple devices.

So, with FROST, this is still a very open and new area of research, but we
believe it to be possible that you can create a FROST key and you can give a
third party a secret share to this FROST key.  And in doing, you may be able to
do this in a way that they do not learn the public key of the FROST key.  So,
maybe I'll backtrack a little bit here.  The problem with script multisig
co-signers at the moment is that you give them xpubs and public keys to your
wallet.  And using these xpubs, they can easily see all your behavior and
activity onchain.  So, even if you don't need their help to sign anything, they
can very easily monitor the Bitcoin blockchain and see what transactions you're
making, who you're paying, what your balances are, and things like this.  But
with FROST, we believe it to be possible that you can give a third party a
secret share and they do not actually have to know the public key or your wallet
and your transactions, your balances.  And yeah, so that's the general idea.

**Mike Schmidt**: And I think you may have touched on this, but I wanted to make
sure that this was brought up as a privacy risk as well, as if you're using
these co-signing or collaborative custody services, they could also, I guess,
depending on what they're signing for, because they can kind of see the details
of what they're signing for, they could decide that based on past onchain
behaviors, like a coinjoin or the enforcement of blacklists for UTXOs or
addresses, they could also just refuse to sign them, right?

**Nick Farrow**: Right, exactly.  So, this is sort of a second concern, is that
in the event that you do need help from the co-signer to sign a Bitcoin
transaction, like you've lost one of your keys and you reach out to them and you
say, "Hey, can you please help me sign this transaction?" in the existing
co-signer services, you need to present this transaction to them so that they
can sign it.  And yeah, as you say, this sort of presents this possible
challenge that the state or the company itself could enforce rules such as,
"We're no longer going to sign any transactions that have been involved in
coinjoins", or, "We're not going to sign any transactions that aren't KYCd
UTXOs", or anything like this.  So, this is an additional concern.

We think with FROST and something called blind signatures, it may be possible
that, in the event you do need to reach out to this co-signer to sign your
transaction, you can disguise or hide the message, the transaction you're asking
them to sign, they sign it and then you receive this blinded signature back and
you can unblind it and you have a valid signature on this transaction, but they
never learnt what they actually signed.  So, this could be quite powerful if
your co-signer service was being subject to heavy regulation or enforcement of
onchain analysis, and things like this.

**Mike Schmidt**: So currently, co-signing services can see all my activity,
regardless of their participation in co-signing, and they can also then see what
they're signing, and there's privacy and potentially censorship that falls out
of that.  Your proposal, I guess, solves both of those problems.  The first one,
they don't see your transaction history; and the second one, they don't see
exactly what they're signing, so they don't know what the transaction is either.
And this is all achieved using some of this new FROST signature threshold
technology in addition to, I guess, some additional blinding techniques that
you've talked about in the proposal.

**Nick Farrow**: Yeah, exactly.  I would like to state that I don't know if I
was the first person to come up with this idea.  I think maybe Steve Myers and
Lloyd Fournier might have put it up in the air at some stage and I've just been
the one to write it down.  And yes, exactly like you say, so with FROST, this
allows you to give a third party a secret share to the multisignature without
them learning of your wallets and your balances and your transactions.  And then
with blind schnorr signatures, or some modification of blind schnorr signatures
that makes them compatible with FROST, this allows you to ask this co-signing
service to sign something without them learning of actually the transaction
they're signing.

**Mike Schmidt**: And I guess in theory, you could ask them to sign something
and see if they sign it, but you don't even need to necessarily broadcast what
they sign; it's like a way to see if they would sign it or to maybe obfuscate
any information they have on you about when you ask for signatures and timing
attacks, or something like that?

**Nick Farrow**: Very true.  That's a really cool idea, actually.  And actually,
there's one other thing I haven't thought so much about, that maybe these
co-signing services as they exist today, if say you lose a key and you ask,
"Hey, can you please help me sign this transaction?" and maybe this transaction
is millions of dollars of bitcoin, maybe they could sort of blackmail you and
say, "We're not going to sign this unless you add a 10 bitcoin output to us".
They can sort of hold you hostage in a situation like this, because they know
that you've lost a key and they've got a sort of advantage on you.  But if it's
blind, then they would not be able to know what the transaction is.  Or maybe,
like you say, you might not even actually need to make this transaction at this
point in time.  You might just be doing it, like you say, to check that the
service is running or to hide the fact that in the future, maybe when you do use
this service, they won't be able to tell which signature request you actually
used down the track.

**Mike Schmidt**: Nick, it sounds too good to be true, it sounds magical.  Maybe
you can get into some of the known potential issues or downsides of this, and
then maybe also some of the things that maybe we don't know yet that people need
to opine on.  I know you mentioned that with the blind schnorr signature scheme,
there's potential attack vectors with multiple concurrent signing requests.  And
I see Murch has his hand up.  Maybe Murch wants to jump in here.

**Mark Erhardt**: Yeah, I just want to -- maybe you go first, Nick.

**Nick Farrow**: Yeah, I was just going to say, so yeah, this is all very sort
of rough cryptography schemes and I'm not a trained cryptographer, so I do need
people to look at this who are more knowledgeable about this stuff than I am.
And yes, blind schnorr signatures, they do have this problem that if you have
many signing requests in parallel, so if you have like 5 or maybe 50 signature
requests happening in parallel, it could be possible for the blind signing
server to create a 51st signature, so one more signature than you requested,
which allows for a forgery.  And there is a trick that you can use to prevent
this from happening.  And one approach that I was thinking of is just to
disallow parallel signing requests.  So, for each input on a Bitcoin transaction
that you need signed from this co-signing service, you could enforce that they
only happen one at a time and you don't respond to old requests or with old
blinded nonces, and things like this.  But yeah, Murch, you had a question?

**Mark Erhardt**: Yeah, more of a comment.  You mentioned early on that your
scheme that you're thinking of involves the user having two keys and generally
signing their own transactions by themselves, and then only falling back to the
third key as a backup.  And I wanted to point out that I think most 2-of-3
multisig signatures or transactions these days are rather the other way around,
where the scheme is often that the user has one or two keys and they usually
co-sign with an active service provider.  So, the two keys would be from the
user and from the service provider, and the service provider would run checks on
the transactions to make sure that the user authenticated, that not too much
money is flowing out at the same time, to protect against breaches; and the user
would fall back to the third key themselves, either when they get censored or
when they want to make a large payment and want to authenticate with both of
their keys.  So, I was wondering how your approach is compatible with that sort
of business setup.

**Nick Farrow**: Yeah, that's a really good point.  So, yeah, there's this other
aspect of collaborative custody or co-signing that you're using them to enact a
spending policy on your Bitcoin transactions.  So like you say, you might have
some spending limit per day.  And exactly, with a blind co-signing service like
this, I haven't thought of any way that you would possibly be able to enact
policies like this.  So from my perspective, it was much more from the backup
and sort of emergency scenario that you can distribute some keys to people and
you only really ask them to sign if you have to.  And I think, I'm not sure, but
I think one of the major co-signing services used today is focused as this sort
of backup service; and I think the other one is more like, yeah, this frequent
co-signing, and use it more of like a policy setup.  Yeah, really good question.
Yeah, I don't think it's quite compatible, that you can't really enact policies.

You can enact things like user authentication or things outside of the Bitcoin
transaction.  One idea I had was that maybe you could have to have some number
of the multisig parties to authenticate, and only then would the co-signing
service agree to sign something, things like this.  But yeah, you can't sort of
enforce, "Oh, this transaction has to spend less than 1 bitcoin", or things like
this.

**Mark Erhardt**: I was just thinking about it.  Maybe you could have a range
proof that allows for something like that, like you proved that the outputs are
within a certain range, but that would get hairy if, for example, more goes back
to the change.  But anyway, thank you for elaborating your scheme and your
thoughts.

**Nick Farrow**: No, thanks, it's a really important question.  Because yeah,
from my perspective, I've learned this more and more that a lot of people use
these co-signing services as sort of a helping hand with Bitcoin.  They have
sort of backup things for you, and they can check that you're not spending too
much or spending money to a scam, or things like this, and these things are
completely separate to a private co-signing service.

**Mark Erhardt**: Sorry, Mike.

**Mike Schmidt**: Yeah, I was just going to say without passing any value
judgments, I think it might add a bit of clarity to provide a couple of
examples.  At least, they come to my mind like something like Green wallet; I
believe everything needs to be co-signed by the second external key.  So, your
day-to-day is being signed by a third-party service.  I believe that it maybe
does SMS authentication, or something like that, and the default is to use the
third-party service for normal transacting.  That may be the case also with
something like BitGo, which you have the other end of collaborative custody,
which is more, I think, what Nick was getting to with this use case of something
like Casa or Unchained, where the assumption is that that key is not going to be
used unless there's some sort of an emergency or loss of information, which
while at a technical level some of these things are similar, the use cases, one
relies heavily on that additional signer, third-party signer, and one relies on
a third-party signer as sort of a fallback case.

**Mark Erhardt**: Yeah, well said.

**Mike Schmidt**: I know we didn't want to name names, and I don't like naming
names, but I think that's --

**Mark Erhardt**: Yeah, it makes sense there, yeah.

**Mike Schmidt**: So we know in the newsletter that the idea received some
discussion on the mailing list and other locations.  Nick, maybe as a call to
action to listeners and readers of the newsletter and podcast, who would you be
looking for to provide what sort of feedback, ideally?

**Nick Farrow**: Oh, that's a tough question, that's a very tough question.  I'm
not sure actually.  It definitely needs a more rigorous academic look.  I know a
lot of papers that are on these blind schnorr signature schemes and the security
of them, but I can't quite recall the authors off the top of my head.  Yeah, it
definitely needs quite a thorough look, because it is quite a sensitive area of
cryptography that has had flaws found in the past.  But I would really like for
someone to say, "Oh, this doesn't work, but maybe here's how it could work", or,
"It doesn't work, and it's going to be impossible to make it work, and here's
why", or maybe for a long shot, "It works as is".  But yeah, it just definitely
needs some eyes to look at it and some really close attention to the security
aspect of it.

**Mike Schmidt**: Nick, before we move on in the newsletter, I wanted to talk a
little bit about Frostsnap; I believe you're involved with the effort.  We
covered the announcement of Frostsnap in the newsletter a couple of weeks ago,
in Newsletter #265.  I don't think we had anyone from your team on, so maybe you
can take a minute and tell folks what that team is working on, as I think it's
also relevant to this news item.

**Nick Farrow**: Yeah, exactly.  So at Frostsnap, we are building hardware and
software to sort of a next generation of Bitcoin self-custody, and we're
building it with multisignature at the core of the experience, so at these
devices.  You can look at our website, frostsnap.com.  Our hardware wallets,
they plug into each other in like a seamless daisy chain, and we think we can
make the multisignature experience with FROST really, really accessible to the
everyday person.  I'm sure many listeners here at the moment have looked at
multisig themselves, and if you're like me, trying it with these software
wallets and hardware wallets that we have today, it's pretty scary.  And then
down the track you learn, "Oh, you can't lose track of any of the extended
public keys, because you need these to create the redeem scripts, to spend your
bitcoin from a script multisig".

We believe the experience with FROST can be much, much nicer and it comes with a
whole bunch of benefits like privacy, you save on fees.  There's another open
area of research where we think you can add or remove signers to a multisig
after you've created the key and you don't have to sweep the funds, like you do
with script multisig today.  So there's a whole bunch of things.  It's a very
exciting area of research for us and we look forward to getting our hardware and
software out to you guys soon.

**Mike Schmidt**: Nick, is that a for-profit startup that you guys are putting
together, or is that sort of a loose affiliation of individuals contributing to
just this?

**Nick Farrow**: It will be for-profit, yes.

**Mike Schmidt**: Okay.  Thanks for elaborating on that.  We covered it without
you a few weeks ago, and I thought it was an interesting effort and very cutting
edge in the Bitcoin world.  So, thanks for explaining that.  I think we can move
on in the newsletter.  Nick, you're welcome to hang on and opine out any of
these items, or you can drop.  Thanks for joining us, though.

**Nick Farrow**: Thank you, thanks for having me.  Really enjoyed it.  Thanks.

_Libsecp256k1 0.4.0_

**Mike Schmidt**: Next section of the newsletter covers two releases.  The first
one is to the libsecp repository.  It is the 0.4.0 release, and there's a couple
of things that I think are worth highlighting here.  First is that this release
adds a new module to libsecp, called ellswift, which implements ElligatorSwift,
and that's in libsecp.  This will be used for encoding public keys and x-only
Diffie-Hellman key exchange for them.  And ElligatorSwift allows representing
libsecp256k1 pubkeys as 64-byte arrays, which cannot be distinguished from
uniformly random data.  And this technology is part of what BIP324 is using, as
part of the P2P encrypted transport protocol project that's currently in
progress in Bitcoin Core.

There's another piece to this release, and this is something that we've touched
on in the newsletter and our Optech podcast chats previously, "We now also test
the library with unreleased development snapshots of GCC and Clang.  This gives
us an early chance to catch miscompilations and constant-time issues introduced
by the compiler (such as those that led to the previous two release issues)".
This is around some of the constant-time issues we talked about previously that
could lead to potential side channel attacks.  So, those are the two big pieces
I saw of this release.

_LND v0.17.0-beta.rc2_

Next release is LND v0.17.0-beta.rc2.  And in the release notes, "This marks the
first release that includes the new MuSig2-based taproot channel type.  As a new
protocol feature hasn't been finalized, users must enable taproot channels with
a flag".  So with this release of LND, you can use these simple taproot channel
types.  And part of the reason we highlight release candidates in the newsletter
and we discuss them here is to encourage users of the software to test the
release candidate and provide feedback.  But as a reminder, it is a release
candidate and there could be issues, so perhaps not best to upgrade a mainnet
production node with a large number of channels or a large amount of bitcoin on
it.  I say this as I saw some Twitter chatter about someone upgrading to this
release candidate and having a bunch of unwanted force closed channels as a
result.

So, please test and provide feedback on these, especially if it's an
implementation that you're using, but please use caution as these are for
purposes of testing.

_Bitcoin Core #28354_

Bitcoin Core #28354 changes the default value of the -acceptnonstdtxn to 0 on
testnet.  So non-standard transactions are now disabled by default on testnet
for relay and mempool acceptance.  It essentially changes that configuration
option to false for the testnet network.  And in Bitcoin Core 0.19.0.1, a
similar change was made for the regtest to default to also not accepting
non-standard transactions.  And so now this is being applied to the testnet.
Murch?

**Mark Erhardt**: And just to clarify on that, this happens now.  This will, of
course, be part of the next release that's hopefully coming out in November.

**Mike Schmidt**: An interesting issue was referenced in this pr.  The issue was
from October 2022 from a Rootstock sidechain developer, who noted that the
multisig script that held the funds for the Rootstock sidechain peg, "This
script work on testnet because it lacks the standard checks performed in
mainnet".  So, that particular standardness rule was related to the sigops
count, the number of signature check operations.  But it sounds like there's at
least one case of folks getting bit by using testnet, which did not by default
have nonstandard transactions.  So, maybe that's part of the motivation here.

_LDK #2468_

Our next and last PR for this week is LDK 2468.  This is part of LDK's
implementation of BOLT12, which is the offers bolt.  And in BOLT12, part of the
process is that you send an invoice request to someone that you want to pay, and
they respond with an invoice that you can then pay.  This PR to LDK allows users
of LDK to provide a "payment_id", which is supposed to be unique, and that's
encrypted and sent in the invoice request that you send to the person that you
want to pay, and then when the subsequent invoice comes back from that invoice
request, LDK then checks that for that payment_id.  And (1) it makes sure that
it recognizes that payment_id; and (2) it makes sure that LDK has not already
paid another invoice for that same payment_id.

We also link to a tracking issue for LDK's work towards implementing BOLT12.
I'm a sucker for tracking issues, so I always try to put those in, in any of the
writeups I do, because I think it's good for people to see the bigger picture
context of where some of these PRs fit in to the broader discussions that we've
had about BOLT more generally.  So, check out that tracking issue if you're
curious of LDK's work towards BOLT12.

**Mike Schmidt**: Murch, anything you'd like to comment on before we wrap up?

**Mark Erhardt**: Oh, I'm just staring at this tracking issue right now, and it
has 20 of 45 tasks done.  I'm just always marveling at how big and long these
sort of projects are in development.  Like, an effort as implementing BOLT12 is
45 times someone working on something between weeks and months, and then others
reviewing that and reiterating on it, and so forth.  So, yeah, just thinking
about how long it's been taking me to get one of my recent projects in Bitcoin
Core; doing that 45 times sounds like a lot of work!

**Mike Schmidt**: Well, thank you all for joining us.  Thanks to our special
guests, Nick and Tom, for explaining the work that they've been doing.  And
thanks always to my co-host, Murch, and for you all for taking your time to
learn about Bitcoin technology.  Cheers.

{% include references.md %}
