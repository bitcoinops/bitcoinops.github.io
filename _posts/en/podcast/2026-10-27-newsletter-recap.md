---
title: 'Bitcoin Optech Newsletter #428 Recap Podcast'
permalink: /en/podcast/2026/10/27/
reference: /en/newsletters/2026/10/23/
name: 2026-10-27-recap
slug: 2026-10-27-recap
type: podcast
layout: podcast-episode
lang: en
---
Gustavo Flores Echaiz and Brandon Black are joined by Adam Gibson, Vincenzo
Palazzo, and João Dias to discuss [Newsletter #428]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-9-28/435245576-44100-2-b715396c9dad5.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Gustavo Flores Echaiz**: Hello, everyone, and welcome to another episode of
the Bitcoin Optech show.  Today I'm going to be the main host and I'm also
joined by Rearden Code as co-host, Vincenzo, waxwing and João Dias, who are
going to present all on different items.  So, Brandon, would you like to say a
few words, and then we can go one by one to introduce ourselves?

**Brandon Black**: Absolutely.  Yes, I'm Brandon Black, or Rearden Code,
currently working on the rbitcoin project, which we'll also cover in this
newsletter, and I'll help go through the other news and software items.

**Gustavo Flores Echaiz**: Great, waxwing?

**Adam Gibson**: Hi, yeah, I'm waxwing, I do sort of various privacy and
cryptography research projects in Bitcoin.

**Gustavo Flores Echaiz**: Thank you, Vincenzo?

**Vincenzo Palazzo**: Yeah, I'm Vincent, I'm mostly working on the LN
protocol.  Currently, I'm focusing on BOLT12 and trying to improve the payment
UX of Lightning.

**Gustavo Flores Echaiz**: That's amazing.  And finally, João?

**João Dias**: Hey, so I am a software engineer at ZBD.  I also just joined
Blockstream to work with Core Lightning (CLN), and I'm also a developer
advocate at Vinteum, a project based in Brazil.  And I guess I'm also a vibe
coder, just like everyone else.

**Gustavo Flores Echaiz**: Thank you so much, everyone.  Brandon, the floor is
yours.

_Trust-minimized exits from a single-issuer layer 2_

**Brandon Black**: All right.  Yeah, let's get into the news.  So, waxwing has
been hard at work, as usual, on new privacy and scaling protocols for Bitcoin.
And we talked last week about his LN-GAP work and improving Lightning
directly.  This week, we have his new Lichen protocol, which is, if I
understand it correctly, and I'm sure he'll give us more details here, is a
Lightning-like layer 2 protocol in terms of it has things locked in 2-of-2
outputs like Lightning.  There's unilateral exit like Lightning, there's
inbound liquidity needs like Lightning, all that is very similar to Lightning.
However, it's a full second-layer protocol where the layer can implement any
rules it wants for how those tokens that are minted out of these 2-of-2
outputs are transferred within the second layer.  So, that gives it kind of a
different feel to it, although it could also potentially interoperate with
Lightning.  And then, I think the innovation about this is it's a unilateral
exit as opposed to kind of a committee-based exit, using BitVM to validate
those unilateral exits.  Yeah, Adam, what else you want to add about that?

**Adam Gibson**: Yeah, so, I think this proposal, I'm personally very
enthusiastic about it, and I don't say that very often about things, because I
often come up with weird ideas that I know are somewhat interesting, but maybe
don't really matter that much.  But I think this one's actually very
interesting.  I'll try and justify that.  So, yeah, you described at a high
level, I think, pretty well the main idea.  But I think perhaps coming at it
from a different angle, if you look at the recent couple of years of research
into L2s that are trustless, so, you mentioned BitVM, and it goes all the way
through BitVM2, BitVM3, Glock, now we've got PIPEs v2, we've got BABE, and so
on; and there's BitVMX, which I also actually used in this.  There's a lot of
different ways of approaching it, where the idea is that sort of fully
leveraging the power of cryptography and specifically the power of
zero-knowledge proofs (ZKPs), and even more specifically the succinctness of
proving systems that can take a very complicated set of conditions and boil it
down into verifying a very short string basically, sort of leveraging that in
the context of Bitcoin and all of these ideas, the various BitVMs and
satellite ideas, they do something very powerful.

But I think, in many cases, when you look at the proposed use cases for them,
a good example of this is the paper, BABE, that was released earlier this
year, they describe how their sort of canonical use case is collateral for a
loan.  And many of them will talk about that.  They'll say, "Oh, this is
really cool", because you could basically bridge your Bitcoin onto, let's say,
Aave or some other Ethereum-type thing, and then you can lend out your money,
and it can all be trustless, where you know you will get your Bitcoin back as
long as the rules are followed, and you don't need to trust an operator, so to
speak, because the idea is that there is some UTXO that is yours.  And you
sort of deposit it, and it just sits there, and you will be able to
trustlessly exit it using this clever zero-knowledge proving tech, as long as
you followed the rules on the other system.  And that's cool and everything,
but that's not what really sort of excites my interest.  My interest is more
the general L2 concept, the idea going back to the sidechains paper, of we can
take our Bitcoin, move it onto another system which has other properties, do
payments with it, do all kinds of weird stuff on there, faster payments, more
private payments, smart contract payments, whatever.  And then, when we want
to get the money back, we just take it back.

The problem is those two kinds of models don't fit together very well.  If you
want to deposit into a UTXO with these BitVM variants, what you're going to
have to do is to have something called covenant emulation.  So, because we
don't have covenants, and in particular we'd need very general covenants for
this, I think, you'd want to be able to say, "Well, I'll put my money into the
deposit", but there'll be a certain set of rules under which it can come out.
But as we know, without covenants on Bitcoin, it's just a binary lock; either
you can spend the money or you can't.  So, we have to do this kind of setup
committee thing where we imagine, oh, there's 1,000 people in a committee, and
as long as one of them is honest, then the effective covenant emulation will
work.  So, that's one big restriction with those models.  Another big
restriction with them is that it just deals with a fixed-size UTXO.  So,
that's why I think they liked that collateral example, because it doesn't
really cause a problem there.  But in a typical L2 usage scenario, you'd
deposit, like, 10 million sats on the L2, and then after six months, you'd be
spending and receiving, and you'd end up with 7 million at the end.  And you
want to withdraw 7 million, not 10 million.  And so, that creates a very nasty
friction point with these ideas as well.

So, what my idea was here in Lichen, and I called it Lichen, silly piece of
background on it, it means L2s In CHannels ENforced on bitcoin.  But let's
just call it Lichen and stick with that.  So, my idea here was that well, if
you think about it in a way, what is Lightning, if not a covenant emulation.
It's just that calling it a covenant emulation is silly because there's only
two parties in the contract, so there's only one sort of counterparty you're
dealing with.  But it's just natural that you can enforce that certain things
happen in that sort of Lightning setup.  And so, what I'm doing here is
mapping the existing work.  Actually, I've sort of moved on.  I was originally
using BitVMX, I'm now using BABE, but that doesn't matter.  The exact ZKP
technology is not really the point here.  The point here is that because it's
that two party contract, it means that you don't have that problem of covenant
emulation, and you can even resolve the problem of having a fixed withdrawal
output amount as well.  That is also resolved, because what you can do is you
can bit decompose the amount that you're withdrawing, and you can include that
as part of the statement that you're proving.  In other words, "I'm going to
prove in the ZKP system that I'm entitled to withdraw 7 million sats exactly.
And you will not be able to stop me doing that because if you try to, you will
fail because the ZKP is actually valid".  And that comes out in the form of
actually multiple outputs of different denominations.  But effectively, within
reasonable tolerance, let's say 1,000 sat is the minimum unit, you'll be able
to withdraw any arbitrary amount using that approach.

Perhaps I should stop there.  Now I've started to talk about it, I realize
this is a very long and complicated explanation.  So, I'll stop.  Just ask me
or whatever, and I'll move on from whatever you say.

**Brandon Black**: Yeah.  So, I think one thing that's interesting to kind of
dive into a little bit more here is the benefit specifically compared to the
kind of BitVM, let's say, pooled sidechain proposals where everyone's funds go
in together, versus here, any given entity operating on this L2 has their own
output, and that's why we can get this unique property of the unilateral
withdrawals without that committee being involved.  So, maybe focus in on
that.

**Adam Gibson**: Yeah, exactly.  And the thing is, it's a weird mental model
at first, which is why when I wrote the paper, I wrote the introduction as
like an FAQ, because I thought there are obvious things that you're going to
think this doesn't make sense, but they're really trade-offs that I think
really do make sense and it really works well together.  So, you have one hub
entity, and the way I would ask people to think about that is think of it a
bit like an LSP, like a Phoenix or something, right?  You're imagining one
central coordinating entity, and obviously there's negatives with that.  But
it has the benefit that it basically means that everyone is trading on the L2
redeemable tokens of that entity.  And redeemable in the strictest sense is
that even if they die, you can go on the blockchain and get back exactly the
amount of money you're owed, even if they disappear.  Rather like, in fact,
today, I mean, the reason I like Phoenix and I often mention it to people,
"Use Phoenix for your LN", is because I do actually have self-custody, I own
my coins on that.  I have a seed phrase, and so on, even though I get all of
the sort of luxurious benefits of not having to worry about my node and
whether I've got the uptime and stuff.  Well, I mean, theoretically, I kind of
do.

But that's another thing where this is better than Lightning, is that when
everyone takes their tokens onto this L2, it's not only that you can get all
kinds of different functionality, but also, the receiver doesn't have to be
live.  In fact, you can kind of forget about Bitcoin's blockchain, because
what you can do is you can say, "Right, I'm going to set this contract with
the hub for six months".  That's a long time, but it could easily work like
that for six months.  And during that six months, at least until close to the
end of that six months, I don't have to actually pay any attention to anything
at all, because I can just receive and pay without, like, as in Lightning, you
have to check if the contract state has been breached.  You don't have to do
that, because the only obligation on the user side that you have is to come
back online before the end of the contract.

Now, on the hub side, it's different.  The hub actually has to stay online all
the time.  And why?  Because anytime, the user could send out a fraudulent
request and say, "I deserve to be paid 10 million", whereas actually they only
have 6 million.  So, there's a lot of requirements on the hub, it's very heavy
on the hub in that regard.  It would be quite an expensive thing to run.  I
also want to say this now before I forget, but the description in the
newsletter, it's not that it's wrong, it's more that it's out of date.  It
says that, "Oh, well, we completely trust the sequencer".  Well, no, that's
not actually true with what I've got right now because now, the updates to the
state of the L2 are all proved valid in the ZKP.  So, just like the standard
idea of rollups in Ethereum, you have a validity rollup, what they call, so
it's constantly maintained in that sense.  And also, if the hub/sequencer goes
online, because actually, if you think about it, they're kind of the same
entity, if they go offline there is now a mechanism whereby you can withdraw
anyway.  In other words, they can't censor you.  But maybe, that's too much
detail.

**Brandon Black**: On that note, the link to the paper is also out of date;
the paper link is to the old paper that's not there anymore, that had that old
information in it.  So, yeah, we do need to update both of those.

**Adam Gibson**: Yeah.  No, it's fine.  I mean, I'm going so fast, guess why
I'm going so fast?  Obviously, I'm coding it all myself, right?

**Brandon Black**: No one's using the LLMs in this.  We don't do that, right?
Another thing I think is interesting to talk about with this, and it's been an
interesting kind of discovery over the course of recent years in Bitcoin L2
research, is there's no free lunches in terms of liquidity.  So, in Ark, the
ASP has to put up liquidity for this to work.  In Lichen here, the hub has to
put up liquidity for this to work.  In Lightning, an LSP has to put up
liquidity.  We're finding, as we build layer 2s in Bitcoin, there's always
some kind of a liquidity requirement on some party in order for the thing to
work, beyond the raw balances of all the users.  How would Lichen compare to
something like Ark or Lightning, or some of the other L2s, in terms of the
liquidity requirements on the hub and the sequencer?

**Adam Gibson**: Yeah.  First of all, I'm going to withhold comment on Ark
because my knowledge of it is really weak; I hardly understand it at all.  But
on Lightning, I'm going to say this, that I think it's a very heavy
requirement on the hub actually.  Because I have figures in my current version
of my paper where I claim, using BABE and not BitVMX, which is a bit too
heavy, but BABE works really well for this, I think I can get to like 10 to
50,000 users concurrently being supported by a single hub.  But that number is
based on me analyzing the problem of mass exit.  Because I think the biggest
weakness with this system is what happens if the hub does go offline and
everyone wants to get out at the same time.  So, they all have to broadcast
their sort of enforcement transactions on Bitcoin.  And that's why I switched
from BitVMX to BABE, because it makes it so that the size of those
transactions is nowhere near as big.  And so, that's that.

But if I start to claim things like, "Oh, yeah, you can have a hub with 10 to
50,000 users", well, hang on a minute, inbound liquidity for all of them?  I
mean, obviously, you're always going to have the users that don't really need
inbound liquidity, because they're just spending, just like in Lightning.  You
could be just a consumer on Lightning, you don't need inbound liquidity.  But
in general, obviously, some of the users need inbound liquidity, otherwise
how's anybody going to receive any money, right?  So, it's exactly the same as
running an LSP, I think.  And I think, I don't know how many users typical
LSPs have now, and I don't know how much liquidity they reserve, but it is a
market problem.  The way I see it is, it's solvable because it's a market
problem.  If the hub finds that it can support its operations with a certain
amount of payments from users, then that's fine.  That's the price they can
agree on, right?

**Brandon Black**: Yeah, and I think that's what we're seeing in all the other
areas.  So, one thing that I think is maybe nice about Lichen versus some of
the other current protocols, Ark and BitVM, where there's pooled liquidity, is
that it seems like with Lichen, the hub could negotiate with individual users
to kind of flex their liquidity up and down over time in a way that is
difficult in something like Ark, where they have to kind of roll users over in
large batches between rounds.  So, there is maybe a benefit here in the fact
that these are individual 2-of-2s, like Lightning, as opposed to a large pool
with everyone in one pool, like Ark.  Now, does that mean though that, well, I
guess you said that these things can last for a long time.  So, unlike in Ark,
where pools have to be kind of short-lived to facilitate liquidity management,
these 2-of-2s can be long-lived in Lichen, so that's kind of a trade-off.
There's still a time limit, unlike a Lightning channel, but the time limit is
much longer than an Ark pool.  Is that accurate?

**Adam Gibson**: I don't, as I said before, I don't actually understand Ark
very well.

**Brandon Black**: Sorry.

**Adam Gibson**: No, not at all, it's necessary to make these comparisons.  I
can only speak from the point of view of what I've built so far, and it seems
very clear to me that you would use a long timeout.  So, concretely imagine
you're a user, you want to deposit 10 million sats, and you want to, just for
argument's sake, you want to also have 10 million sats inbound, just for
symmetry's sake.  It depends, is that useful to you?  If that's useful to you
for six months, you may as well just have a six-month contract.  There's no
reason to have a shorter one, I think.  And as I said before, if the hub, or
let's call it the operator, if the operator goes offline, well, you just have
the material necessary to get your money back onchain.  So, you just relax
until you hit like, after the fifth month, you realize that, "Okay, I can't go
up to the last day", because if something goes wrong on the last day, the
timeouts are naturally -- oh, by the way, the period of withdrawal, I think,
with BABE is going to be typically like one day in a dispute.  Obviously, most
of the time, there would be no dispute, because there's no point going
backwards and forwards when you already know that the ZKP is valid.  That's
the general argument.  The only reason you have to worry about that is if
there's an attack, if somebody's trying to do a mass exit attack, etc.  But
basically, I don't see any reason for it to be a short time, it should be a
long time.

**Brandon Black**: Yeah, good.  So, yeah, so that manages the traffic onchain
for supporting many users in this.  All right, very cool.  Anything else you
want to add?  Any other questions from the other folks on the call before we
go on to the next item?  All right, moving along.

**Adam Gibson**: Thank you.

_Descriptor syntax for hash preimages_

**Brandon Black**: Jaonoctus, you proposed, "Descriptor syntax for hash
preimages".  Just for everyone's context, in miniscript descriptors today, we
have nice ways to express private keys when needed, so that they can be
imported from a private descriptor into a wallet, and that works fine for
private keys.  Their equivalent public descriptors can then be shared, people
can pay them, you can recover using the public one, all that kind of stuff.
But we don't have an equivalent for secret hash preimages, and that's
something that is a challenge for users who are trying to use certain kinds of
offchain protocols, or in your case, you mentioned using it in the puzzle for
TABConf.  There's a need here that there is other secret data than just secret
keys.  There are the symmetric secrets of preimages, and you might need to
specify those in order to use a descriptor effectively.  And you have a
proposal here that's kind of in draft phase, it looks like, for how we might
specify those in descriptors, and kind of get them into the language so that
wallets can share these and export them and they can be managed appropriately,
similarly to how we manage private keys in descriptors.  So, tell us more.

**João Dias**: Yeah, exactly.  So, I ran into this while solving the TABConf
CTB puzzle two years ago, where I expected to have the same feature or
functionality of the pk descriptor, the public key, while creating the wallet
and using the bitcoin-cli, because I am familiar with the cli, and then I was
expecting to do the createwallet and then importdescriptors, and do the
SHA256, or whatever hash it is.  And then, there is no way to describe the
wallet, like the private information, or in this case, the preimage.  And that
makes sense, because when you are using the pk, you can either specify the
public key, or there is a specific format for the private information, which
would be the WIF (Wallet Import Format), or the xpriv, and they vary on sizes,
right, which is different from the digest because right now, the way that the
descriptors for any hash works is that they do enforce the size.  And then, it
wouldn't look different if I tell the preimage or the digest because they have
the same size.

So, I got frustrated two years ago.  I remember even tweeting about it.  Ava
Chow, she saw it, and I know that they were discussing about it in IRC, and
they were like, "Oh, we never thought about it".  So, yeah.  The thing that
I'm proposing is that it's basically a marker to the descriptors that you can
say, "This is the preimage for this hash", because as I just mentioned, there
is no specific format for differentiating preimages from digest, so that we
would have to use a specific descriptor for it.

**Brandon Black**: Yeah.  So, just again, for the user's context, when you're
using hashes in verification scripts in Bitcoin or other crypto systems, the
preimage is kind of the secret key and the digest is the public key.  So, in
your locking script, you would specify the digest, and then anybody who can
bring the preimage, that's the secret part, can hash it to the digest and
validate it in your locking script.  So, that's why we need to have this
differentiation, is in the public side of the descriptor, you specify the
digest, and in the private side, you specify the preimage, and that's how you
can spend.  And only the person who has the secret can spend, of course,
unlike with secret keys, once you do the spend, the secret becomes public.
So, in some ways, there's like an extra level of secrecy you have to deal with
with preimages, because once they're used, they become public.  Anyway, so
there's all that kind of going into considerations of how to build these to
help users effectively retain their spend conditions' secrecy as needed.

**João Dias**: Yeah, because right now, again in the bitcoin-cli, you can do
the createwallet, and then by default, the argument disable_private_keys is
disabled.  So, you can import a private key, even if you specify like the
public key and then private key inside of it, your wallet is going to store
that into the file and use that while signing transactions, right?  The hash
is different because, again, it is going to have the same size of the preimage
and it's going to be converted to the script OP_SIZE 32 OP_EQUALVERIFY so that
it verifies the size first, and then do the &lt;HASHOP>, whatever it is, and
then the &lt;digest> OP_EQUAL.  So, it verifies if the hash you're using
matches what you previously committed to the address.  I was expecting to have
some similar feature for it.

**Brandon Black**: Yeah, or Bitcoin Core won't show preimage by default, would
be awfully nice.

**João Dias**: Yeah, it would read as the digest always.

**Brandon Black**: Yeah.  So, what's the status of the proposal?  What
feedback have you gotten so far?

**João Dias**: Very few, actually.  Like, I wrote this article in Delving, and
I talked with Poelstra at TABConf this year, and also there are a few
questions still open.  My first idea is just to have this preimage marker, and
this would be the simplest way to build this feature.  But at the same time,
should I create a new BIP for it, or should I edit the existing descriptor
one, BIP379, I think?  And there is other stuff that we can also do in the
future, like add new RPC or complementary RPC calls into Bitcoin Core.  Should
we leave this for software wallets only or should hardware wallets implement
this?  And I know that for some other protocols, like Lightning
implementations, they do have preimages, but they handle this in a
deterministic way.  So, we could extend this, but the simplest way would be
just have this preimage marker.

**Brandon Black**: Or, you could have a syntax for derived preimages as well,
potentially, in the descriptor?

**João Dias**: Yeah.

**Brandon Black**: Interesting.  Well, I hope maybe this podcast will get some
more attention on it and move the proposal forward, because I do think it's
something valuable for folks to have, especially when people are working
towards various kind of offchain-sequenced protocols and things like that.
These are important features to have in the Bitcoin Core wallet.

**João Dias**: I think the next steps would be just I write a draft, like a
BIP draft, and then see what people talk about it.

**Brandon Black**: Cool.  Well, look forward to seeing it.  Any other
questions, Gustavo or Vincent, before we move on?  All right.  Well, thanks a
lot, João.  Feel free to stay on or drop at your discretion.  We're going to
move on to the Services and client software section, where we have three
vibe-coded or agentically-engineered projects to talk about that had releases
recently.

_Ibis Wallet v5.0-beta released_

First up, we have the Ibis Wallet v5.0-beta.  Note, there is already a
5.1-beta that fixes an important bug, so the newsletter item is slightly out
of date, although the features talked about here are still the relevant
features.  So, this new release adds Ark support built on Bark, unilateral
exits from the Spark statechain, and receiving to silent payment addresses.
We've talked about Ibis before in the newsletter and on the podcast, but just
kind of to briefly summarize, it's a fully vibe-coded wallet by a friend of
the show, aeon, who was one of the early people to start saying, "No, we can
build vibe-coded Bitcoin software and it'll actually be more secure done this
way".  I didn't believe him when he started.  Of course, now I do, but that
changed later.  So, I think this project has been going for quite a while now,
I think over a year-and-a-half or more, and he's really made huge progress in
building a wallet that is vibe-coded, that is to all kind of outside auditing
appearances very secure, and has a lot of feature functionality built in
because of the capabilities of LLMs.  So, kind of an early example that's
continuing to make great progress towards getting less reckless over time,
let's say, using vibe-coded, agentically-engineered software.  Questions or
comments about Ibis?

**Gustavo Flores Echaiz**: Yeah, I just want to say that it's only available
on Android.  So, I wanted to test it out, but I wasn't able to because I don't
have an Android.  But yeah, if listeners would like to try it out, it's only
available on Android for now.

**Brandon Black**: Yeah, and I've talked to him about that actually.  And he
said that because it's agentically-engineered, he proposes that someone
basically just point their agent at it and copy it to iPhone, and that's the
best way to do it.  In the modern world, it doesn't make sense to try and
support both in a single codebase, because you're going to end up having this
kind of unnecessary branching for the two platforms.  And it's better to have
just a copy that's focused on being the best iPhone version and the agents can
effectively translate.  It's one of the things they're really good at.  So,
that's why it's only one platform; it's intentional.  Cool.  Anything else
about that, otherwise, we'll move on to Landfall.  Cool.

_Landfall wallet for Lightning mining payouts_

All right.  So, Landfall is Vincent's project here, also
agentically-engineered.  And this is in the proof-of-concept state, it is not
as far along, at this moment, as Ibis is.  But it's a proposal for a
lightweight Lightning wallet that you can run in kind of a low maintenance way
to receive mining payouts to Lightning, and not have to kind of manage your
own home infrastructure and separate keys, and all this kind of stuff, really
simplifying your ability to be paid out quickly and at a low cost from, for
the moment, OCEAN mining, but hopefully in the future, other mining pools also
over Lightning.  So, tell us more about it, Vincent.

**Vincenzo Palazzo**: Yeah.  So, Landfall started from this frustration where,
I work also for OCEAN for the Lightning payouts, so I had to do the support
and every time that I had to explain people how to do the setup of OCEAN, that
from an address, we connect the address to the offer, and then the user need
to sign, with the onchain private key, the message that OCEAN provide to him,
just to prove that the owner of the address want really to be paid on
Lightning.  So, it's just a way of us to bind the offer with the onchain
address.  And if you go on the documentation, you have to switch at least
three wallets.  So, you have your Trezor, and then you need to move your key
to another wallet, and then sign the message with the Lightning wallet with
the offer created inside the Lightning wallet.  So, if you are lucky, you have
at least two wallets involved; if you are unlucky, you may have three wallets
involved.

**Brandon Black**: And depending on what wallet your key is in, you might have
a third wallet involved, right?

**Vincenzo Palazzo**: Yeah, because you usually don't mine on the Lightning
wallet onchain address, you usually mine on, I don't know, on a Trezor or, I
don't know, onchain wallet, or something.  And then, after a while, you say,
"Okay, let's try it out this Lightning stuff".  And at this point, the OCEAN
payout is permissionless.  So, the only thing that matters to OCEAN is the
onchain address, so you cannot, I don't know, move the proof of work that you
did till that point to another address.  So, the thing that we really need is
a better UX to do this signing message.  And this is not an OCEAN procedure,
it's also Relai, a European exchange, required you to do a withdrawal on an
onchain address, and required you to sign this BIP322 message.  And if you go
around, you probably find one or two wallets that are able to do that.  And
when I collected this information, I say, "Okay, it's so difficult to make
one", and I started two years ago with a command line and said, "Okay, I can
hook up all the wallets, right?  You can use the hardware wallet interface,
you can connect all the wallets", but at some point, everything became too
complicated.

At the same time, I was following this Lexe project, that is a Lightning
wallet that is running on a TEE (Trusted Execution Environment), so you don't
have the key on the phone, but basically the keys are inside this TEE.  And
while I was talking with the team in Viareggio or somewhere else, they said to
me that I could import the mnemonic.  I could create the wallet with a
mnemonic on the device and ask the Lexe server to create a wallet.  Now, I
think it's the default.  Before, it was not the default operation, so I didn't
have the private key to send a message.  And at that point, I just went to
Claude Design, I figured out a nice design for that.  And I created an app
that is able to do this step guidance, focused on the OCEAN setup, but no one
is stopping you to say, okay, now the message is another message that is
required by Relai, or some other platform.  And with four steps, I was able to
be up and running, and I had a Lightning node with a channel, and I created an
offer, and I was mining on OCEAN with a Bitaxe.  And then, you can go really
way crazy, you can buy in your Bitaxe, you can connect the, I don't know, API
with a miner, you can go really in production with really big thing.

I released it not as a proof of concept, but as a showcase.  The proof of
concept is you should not run this.  The showcase is, "Hey, this is the way
how you should deploy this kind of stuff".  And a couple of miners from OCEAN,
they saw my tweet and said, "Oh, this is cool.  I will test it".  And they are
running now the software.  So, probably it's not a showcase anymore, but
anyway, for now it's a showcase.

**Brandon Black**: I was going to ask, what's the future here?  Is this going
to be kind of long-term maintained stable software for people to use with
OCEAN?

**Vincenzo Palazzo**: Well, if OCEAN will decide to pick it up as a project,
probably yes.  If there are a lot of users that are using the software, I will
decide at some point to do the maintenance of it, or just the packaging and
the release of the software.  And I feel that this is a needed project,
because there are some miners that are sometimes not able to set up a
Lightning offer, they're just trying to figure out how to build with Grok AI
the app to be able to use it.  So, at the moment, there is no clear filter for
that outside of the showcase.  And this depends on if OCEAN decides to pick it
up as an internal project, or I will have enough users that are asking me to
maintain it.  So, yeah.

**Brandon Black**: Cool.  Definitely, I think, a needed project, because
you're right, there are quite a few places in the world where people have the
challenge of linking an onchain address, for various reasons, to a Lightning
offer.  And Lightning is intentionally somewhat private.  And so, you have to
intentionally make that link, which is a good feature.  But sometimes you have
to make that link.  So, very cool.

**Vincenzo Palazzo**: Yeah.  And this is not for onchain payout, if you think
about the privacy that BOLT12 is giving you, right?  I'll opine around this,
and then I will close in two seconds.  But one thing that a lot of people
think that OCEAN is doing Lightning payout for is for small miners, right, for
people that are not able to enter inside the threshold.  But if you think
about how much privacy you gain with BOLT12, you should use Lightning also if
you care about privacy, if you are one of these miners that is receiving the
payout in a wallet, and then you use Bitcoin as a miner, because then, at this
point, you are saying to everyone, "Hey, I mined on this address, and now
these are my payouts with the other UTXO".  So, essentially, if you are a
miner that uses Bitcoin as a payment and not to sell to pay the bills, but if
you use Bitcoin as a payment, you should use Lightning, and for this privacy
guarantee that we put inside BOLT12.  And with BOLT11, you still leak some
information, but with BOLT12, you can really be underground and no one knows
you.  And if you think about this use case, exchange withdrawal will be
really, really nice with BOLT12, and then you need to link the onchain address
or the account with some BOLT12 offer.

So, you made a great point that sometimes, Lightning is used in a broken way,
say, for small payouts; now, Lightning is used for privacy, if you care about
it.  But yeah.

**Brandon Black**: Yeah, I think there was the joke some months ago, Super
Testnet overplayed it a little bit, but he was talking about how Lightning is
the greatest privacy coin ever made.  And there's some truth to that actually,
that because of the level of traffic that Lightning attracts and because of
the privacy of individual payments within the LN, in many cases, your best way
to use money privately is the Lightning Network, not one of the other coins
and not Bitcoin onchain.  So, it's awesome to see privacy being pushed forward
here as well.

**Vincenzo Palazzo**: Yeah, even more if you are telling the onchain address
to everyone, right?

**Brandon Black**: Yeah, for sure.  Awesome.  Any questions, Gustavo,
otherwise, we'll get on to rbitcoin?

**Gustavo Flores Echaiz**: No, really cool stuff.  Thank you.

_rbitcoin 0.8.0 released_

**Brandon Black**: All right.  Our last software release, also
agentically-engineered, of course, because that's the theme of the year, let's
say, is mine, rbitcoin.  So, a couple of weeks ago, I released rbitcoin 0.8.0.
This is now somewhat out of date, as you might expect in a fast moving,
agentically-engineered project.  But in summary, rbitcoin is a Bitcoin full
node from the ground up in Rust using rust-bitcoin.  Notably, it intentionally
does not use any of Bitcoin Core's consensus logic internally.  It is
validated against Bitcoin Core's consensus logic using a lot of automation,
but it is a from-scratch consensus implementation based on rust-bitcoin.  The
project overall, I built it for myself because I run a Bitcoin node that I use
to back my wallets, and I wanted something to exist that made that easier.
So, I didn't have to run Bitcoin Core and Electrs or Esplora, or any of the
other kind of sidecar indexers.  So, I built this.  And I think since this
newsletter was written actually, it has somewhat become important, I would
say.  Because in building it, I came up with a variant of the Esplora API that
allows for stable views of wallets.

I didn't realize when I built that, that it was a universal pain point of
everyone building wallets based on Esplora and Electrum.  I was just like,
"This is the way it should be for me when I'm building my wallet on this".
And it turned out that everyone had problems with Esplora and Electrum
providing an unstable view when viewing wallet contents.  So, rbitcoin has a
variant of those APIs that make stable wallet sync possible.  And people seem
to really like that about it.  So, I hope that rbitcoin maybe is a guidepost
for how Esplora-based wallets can be better in the future.  And yeah, it's
also a modern Bitcoin node.  But it turns out that being a Bitcoin node is a
secondary feature to most people who are very interested in it.  It's
important to me.  I wanted one thing to run, but you can also run rbitcoin, on
master at least, against your Bitcoin Core node and use it primarily as a
wallet service against your Bitcoin Core node.  So, that's rbitcoin.  Any
questions, guys?

**Gustavo Flores Echaiz**: Super-cool stuff.  Thank you for sharing.

**Vincenzo Palazzo**: Can you explain really briefly what the pain point of
Esplora and Electrum Server that you fixed?  What is the use case that you're
going to fix?

**Brandon Black**: Yeah.  So, the problem with syncing a wallet against the
Esplora is if you make two queries, let's say you query the balance and then
the UTXOs, you have no way of knowing if you got those from the same block.
You might get, especially if there was a reorg in that time, you might get the
balance from a block on chain A, but then the UTXOs from the block on chain B,
and there's no way to tell that you got that.  So, you kind of just have to
keep querying until you're pretty sure you got a stable answer.  So, rbitcoin
does two things.  One, in the headers of an Esplora response, it always puts
the blockhash you got the response from.  So, you can at least tell for sure
whether you got a stable view or not.  But then, it also has an extra query
parameter you can pass, asof.  And you can say, "I want my next query to be
asof this blockhash".  And it'll either give you an error, "That blockhash is
no longer on the best tip", or it'll give you the stable view at that
blockhash in your next response.

So, either way you use it, whether you just query kind of naively and then
look at the headers, or you ask in your next query for a specific stable view
to keep going with your future queries, the result is that you can now be
confident you didn't miss a shift in the UTXO set because of a reorg in
between your queries.

**Vincenzo Palazzo**: Okay.  Makes sense.  Thanks.

**Brandon Black**: Obviously, it's a low-probability thing, but because
Esplora provides no way to know for sure, wallets are always like, "Well, I
sure hope I got a stable view and I'm not lying to my user".  And especially
in Lightning, what if you missed someone getting a force-close in the chain,
and then it's not in the different view.  It matters, and so you have to work
around it.  And with rbitcoin, it's kind of provided for you that you can tell
for sure whether you got a stable view or not.

**Vincenzo Palazzo**: Okay, makes sense.  Thanks.

**Brandon Black**: Cool.  Well, that's it for the Changes to services and
client software.  So, back over to you, Gustavo, for the Releases, release
candidates, and whatnot.

_Eclair 0.14.4 and 0.14.5_

**Gustavo Flores Echaiz**: Awesome.  Thanks so much, Brandon, that helps a
lot.  So, we're now going to go through the Releases and release candidates.
So, the first item, both new releases from Eclair that came up one after the
other, versions 0.14.4 and 0.14.5.  So, the first one fixes several issues we
covered in Newsletter #427.  I think most of the Notable code changes we
covered in #427 were around Eclair, multiple issues related to HTLC (Hash Time
Locked Contract) settlement, splicing, on-the-fly funding, many potential fund
theft cases where you would fail an incoming HTLC but an outgoing HTLC would
still be claimable by an upstream peer.  So, all of those fixes are now
included in this first release, and listeners can refer back to Newsletter
#427 and the episode that came with it if you want further details on all
those and everything that was included.  Also, that same version includes a
fix we covered in Newsletter #423, which basically Eclair now rejects API
requests containing an Origin header to prevent cross-site request forgery.
It basically means a browser-based frontend can now no longer call Eclair
directly and it needs its own backend instead to call Eclair.  So, that fix is
also included in the first version.

Then, the second version that came quite a few days later, version 0.14.5,
this one includes some fixes we're going to describe in the section below,
specifically around trampoline routing and taproot splicing vulnerabilities.
Also, in Newsletter #427, we covered specifically a bug around the HMAC
construction and validation.  That is also included in this second release.
Users are recommended to upgrade since these are security releases, so if you
run an Eclair node, use it as part of your infrastructure, please take notice
of that.

_BDK chain 0.23.4_

The next release is BDK chain 0.23.4.  So, previously, BDK used to make
releases under the BDK name.  Now, it has basically split the BDK repo into
wallet and chain releases, chain being the main one.  So, we're now covering
this maintenance release, and interestingly so it has multiple fixes around
its connection with Electrum.  So, not exactly the same thing you discussed
with Esplora, although we do have a BDK item talking about Esplora below.  But
this release includes multiple fixes when using an Electrum server to connect
to a Bitcoin node around txid verification, confirmation detection for
transactions with an OP_RETURN as a first output, and also confirmation
tracking after reorgs.  That's something we covered last week, where if a
transaction got reorged, BDK might not notice that it would get reconfirmed in
a new block.  A cache of the BDK system might still think it's linked to the
block that was reorged.  And that's for BDK.  It also has some other fixes
related to Bitcoin Core RPC synchronization after reorgs.

_LND v0.21.5-beta.rc1 and v0.20.6-beta.rc1_

Finally, we cover two RCs, LND v0.21.5 and v0.20.6.  Both are still in the RC
level, so I just verified on the releases in LND, and no official release has
come out yet.  So, users that would like to test these RCs are invited to do
so.  They both include some fixes we covered in Newsletter #418, a small one
related to how update_fee is handled in LND to match BOLT12, BOLT2's
replaceable state model, and thus preventing redundant uncommitted fee updates
from growing the update log.  So, it's mostly about handling the size of the
update log, along with fixes for commitment fee rates, excessive memory
allocation, and SQL database deadlocks.  The v21 maintenance release also
includes auxiliary HTLC signature validation that we covered in the past
newsletter.  So, that was around the fact that LND sometimes could produce
some HTLCs without the auxiliary signing signatures, which meant that a
receiver of that HTLC, if the channel was later force-closed, the missing
signatures could prevent the affected underlying assets, for example, the
Taproot Assets, from being resolved onchain.  The fix is obvious: LND now
verifies that all auxiliary signatures are present before signing, so that is
also included in this RC.  Any comments, questions about the releases?

**Brandon Black**: Taproot Assets is still LND only, right?  There's not a
cross-implementation of that?

**Gustavo Flores Echaiz**: That's correct.  I just got an email that actually
a new version of Eclair just released, 0.14.6.  So, while we're online, if
you're listening and you run Eclair, maybe worth looking into that too.

**Brandon Black**: Every day is zero day.  Update your software.

**Gustavo Flores Echaiz**: Yeah, every day, it's the new way.  We jump into
the Notable code and documentation changes section.  This week, once again, we
have multiple Lightning security items; we have some from the BTCPay Server
repo, as well from BDK; and finally, we have two BOLT specification changes,
which I don't know if, Brandon, if you had time to look at the last item, but
that one seems a bit over my head.  So, if you can take a quick look at it
before I get there, that'd be good.  Finally, we get to the section.

_Eclair #3409_

So, we start with two Eclair items. #3409, this one is about fixing a
vulnerability that allows a malicious payer to steal funds from a node
forwarding trampoline payments.  So, the problem here is that if pathfinding
failed when Eclair is forwarding trampoline payments, Eclair would retry with
relaxed limits on route length and expiry, but that would allow a payer to
provide routing hints or blinded paths with excessive expiry deltas.  And as
we know, you really got to be careful to never have a CLTV
(CHECKLOCKTIMEVERIFY) expiry delta that an outgoing HTLC expires before an
incoming HTLC, because that could lead to a loss of funds for the routing
node.  But this is exactly what happened.  When pathfinding failed, Eclair
would retry, and those relaxed limits would allow a payer to provide routing
hints or blinded paths with excessive expiry deltas.  The problem is then that
the payer could then reclaim the incoming HTLC, because it had an excessive
expiry delta, after it expired.  But the receiver could still claim the
outgoing HTLC, so it's really important for the outgoing HTLC CLTV to expire
before the incoming HTLC, which was the main issue of this item.

So, the fix is clear, Eclair now only relaxes the route length limit, it
doesn't allow a payer to provide routing hints or blinded paths with excessive
expiry deltas; that is never relaxed.  That's the first item.

_Eclair #3411_

The second one, another vulnerability in Eclair, #3411.  This one is about a
vulnerability that could allow a malicious channel peer to steal funds by
making Eclair sign an invalid splice transaction.  So, this is specifically
when you're splicing a simple taproot channel, a peer could provide the amount
and script of an input's previous output instead of the full transaction.  So,
Eclair was previously trusting these values without verifying them.  So, if a
peer was providing, yes, a valid UTXO, but was maybe providing a different
amount or a different script for that UTXO for the splice-in of this
transaction, Eclair was simply trusting.  It was not going to its Bitcoin
backend and actually verifying that the claimed outputs, the amounts and the
script match.  So, Eclair would sign these transactions, but because taproot
signatures commit to the actual amounts and script of the spent inputs, these
signatures would be invalid.  So, the splice-in transaction could never
confirm on the Bitcoin blockchain.  However, Eclair would still treat this
invalid splice as ongoing and valid and at its latest channel funding state.
So, then, if the peer would publish previously signed commitment transaction
that spent the previous funding output, Eclair would not be able to react,
because Eclair was simply thinking the new splice transaction that would never
confirm onchain was the latest funding state, which meant that the peer could
then claim an outgoing HTLC after Eclair's corresponding incoming HTLC had
timed out.

So, once again, this is the classic fund theft scenario, or vulnerability
scenario in Lightning, is that the incoming HTLC gets refunded and the user
can still claim the outgoing HTLC.  So, you are refunding to the downstream
peer while the upstream peer can still claim the HTLC and thus the routing
node, Eclair in this case, loses money.  So, now Eclair will obviously verify
that the claimed outputs from a peer for a splice-in transaction actually
correspond to a valid Bitcoin transaction, and it will verify that against its
own Bitcoin backend.

_LDK #5126_

So, now we move on to LDK.  LDK fixes a bug where BOLT12 payments using
one-hop blinded paths could be rejected because their HTLC expiry was too
short.  So, this was an edge case where, because in a blinded path, if there's
only one hop, then the introduction node is also the receiver.  So, LDK would
overlook that fact and consequently, payments only met the receiver's minimum
requirement, when LDK's random CLTV offset was large enough.  So, in some
scenarios, LDK would provide a random CLTV that was large enough; in other
scenarios, it wouldn't.  So, sometimes it would work, sometimes it would fail.
This was causing intermittent payment failures when testing against CLN,
because CLN had a minimum requirement of the HTLC expiry that LDK was simply
not meeting.  So, now the fix is also clear, which is LDK now includes the
advertised delta when constructing the route and checking its maximum
permitted total CLTV delta.

_LND #10919_

The next item is from the LND repo, #10919.  This is actually not a bug fix,
but an actual new feature.  So, in Newsletter #377, we covered channel jamming
mitigation, simulation, results and updates.  But in part, we have covered how
what was previously called HTLC endorsement, which was a reputation system
proposed for LN to mitigate channel jamming attacks, was renamed to, or was
reinvented, as HTLC accountability.  And in Newsletter #377, like I said, we
covered a lot of the channel-jamming research.  And in Newsletter #387, we
covered how Eclair and LND both started the implementation of HTLC
accountability, and that is based on a specific PR in the BOLTs repository,
#1280, which is still open.  So, we still haven't covered how this was merged
in the BOLTs repo, because it hasn't.  But Eclair and LND both took initial
steps towards implementing it.  And now we get to this LND item, #10919, which
implements at least the local reputation system that is defined in the HTLC
accountability scheme in the BOLTs repo.

So, the system scores outgoing channels based on past forwarding activity and
the node's advertised fees, penalizing accountable HTLCs that take too long to
resolve.  So, the LND node is constantly monitoring outgoing channels when
forwarding HTLCs, how fast do these HTLCs resolve; do they eventually fail or
always succeed?  And it basically tracks how much revenue it's supposed to
make versus actually how much revenue it's making.  If, for example, it's
always forwarding via a channel to a peer that is always failing the HTLCs, so
it's never actually working, but it is supposed to make quite some revenue
from that channel and that peer, then that penalizes that peer.  That's a sort
of simple explanation of how that system works.  So, the system is enabled by
default and it logs all this information, but it doesn't yet affect forwarding
decisions, okay?  That is very important to be precise.  Same thing for the
Eclair implementation that we covered in Newsletter #387.  This is simply
monitoring, collecting data, but it's not taking any forwarding decisions yet;
that could come in further phases.  However, in LND's implementation,
reputation resets on restart, so this is not persisted on disk and storage.

The next two items are from the BTCPay Server repo.  Maybe I'm going to take a
little stop here.  Brandon, Vincent, anything you guys want to add now that
we've sort of covered the Lightning section?

**Brandon Black**: Man, I don't know.  This is showing the complexity of the
Lightning protocol and the kind of difficulty of maintaining security in this
kind of multi-implementation routed network, where you have many different
permutations of channel peers all working together, and there can be kind of
nuances, like the CLTV expiry delta, where one implementation thinks that's
not an important parameter but the other does.  And it's actually quite
difficult to get every single nuance of that specified in the BOLTs so that
everyone can implement it in the same way.  Yeah, it's tough stuff.

**Gustavo Flores Echaiz**: Right.  And I think also, now that we don't just
have one type of channels, but we also now have simple taproot channels, and
we also have zero-fee commitment channels, BOLT12 payments, splicing as well.
The amount of different types of channels and also the negotiations behind all
these protocols have sort of raised the complexity of the system.  So, I think
that's what we're seeing a lot over the past few weeks, but thankfully we've
got really good teams working on those different implementations, making the
required fixes and shipping the new security releases.  Great.

_BTCPay Server #7679_

Now let's jump into the BTCPay Server section.  So, we've got #7679, which is
a bug that could lead to duplicate Lightning payouts.  So, it's not like
BTCPay Server was making duplicate Lightning payouts, but the problem was that
if a payout was initiated and a lookup returned no results, BTCPay Server
would cancel the payout and discard its payment hash.  But as we know,
Lightning payments sometimes can take longer than a few seconds to resolve.
And BTCPay Server was simply considering that a payment lookup that returned
no results, or specifically a null response, was the same as a payment that
had failed.  And this meant that an operator could interpret the canceled
payout as, "I need to make the payout again".  However, the payout could still
have completed.  And that's the risk here.  It's not that BTCPay Server made
two payouts, it's that an operator could interpret that the first payout had
failed and thus make the second payout.

So, the fix is also quite simple.  BTCPay Server doesn't interpret no results
or no response as if the payment had failed.  It now retains those payouts in
progress and it retains their payment hashes as well for subsequent checks and
doesn't consider them as failed directly.

_BTCPay Server #7684_

The next item, #7684, this is actually a very important security vulnerability
in BTCPay Server.  This is a privilege-escalation vulnerability in the
Greenfield API key authorization.  So, there's two bugs here.  The first one
is that an API key that was restricted to a particular store could exercise
server-wide or account-wide permissions despite its limited scope.  So, it's
not clear to me yet if it happened in all cases or under all users, but
definitely there's a risk for privilege escalation in that sense.  The second
one is also very, very potentially risky, which is that a key authorized to
create API keys for other users could grant permissions broader than its own.
So, this is a classic API key-authorization vulnerability that we've seen in
other systems, where by being able to create API keys, you could create API
keys with larger permissions than your own, which doesn't make sense, of
course.  So, now the fix is for BTCPay Server to enforce permission scopes
when authorizing requests so that a key that is restricted to a particular
store could not exercise server-wide or account-wide permissions.  And also,
an API key that can create other API keys obviously shouldn't be able to grant
permissions they do not possess.  Of course, if you have an unrestricted key,
it retains its intended capabilities.

_BDK #2325 and #2360_

The next item combines two different PRs from the BDK repository, #2325 and
#2360.  So, this is about fixing two bugs that could cause the wallet to
report successful synchronization without retrieving the requested transaction
data.  And I don't know, Brandon, if this is related to your Esplora work, but
maybe I'll go through the item and maybe you can tell me if you've seen this
issue before yourself as well.  So, the first one is that BDK will simply
ignore all error responses when fetching a transaction, specifically with
Electrum.  And it meant that if the request timed out, BDK would interpret it
as no transactions to scan.  So, for example, that could cause a spent output
to remain classified as unspent, even though it had been spent, because BDK
would simply interpret a timeout response from Electrum as if there was
nothing to record.  So, now the fix is for BDK to ignore, yes, Electrum
protocol errors, but propagate other failures, such as timeouts or connection
failures.

The second PR fixes specifically the sync and full_scan methods for the
Electrum and Esplora clients respectively, previously setting batch_size to
zero when using an Electrum backend, or parallel_requests to zero when using
an Esplora backend.  That could make the connection silently skip requested
scans or transaction fetches while reporting success.  So, the fix is to treat
a zero as one for these parameters, so you never get an empty response that
looks successful, but that is obviously just an empty response.  Brandon,
anything to comment here?

**Brandon Black**: The thing I would say is that I'm interested in why they
chose to set zero as one versus treating it as an error to make a call with
zero, because very small batch sizes with Electrum can exacerbate the issue we
talked about that rbitcoin fixes, where you're making many requests to sync
the same wallet, and the view of the blockchain underneath can change over
those many requests, so you don't get a consistent view of the wallet's actual
contents.  So, I'm not saying it's the wrong choice, it's just I'm curious why
they chose to make zero equal one instead of making zero an error.

**Gustavo Flores Echaiz**: Yeah, to be honest, I wouldn't have the specific
answer for it.  But yeah, that's a very good question.  Yeah, I do see,
however, in the file's change, that it does say a batch_size of zero is
treated as one, but there's no comment on it that explains why.

_BOLTs #1357_

**Brandon Black**: And I can talk about the next two because we actually
talked about BOLTs #1357, well, the underlying issue that led to it, at
TABConf when I was there.  So, this was an interesting situation where the
BOLT specification had flexibility that was unnecessary, but it was there
because people thought it might be useful, which was it allowed for invoices
to have multiple payment hashes.  And I don't know exactly why that was there,
I don't know what the thought was.  But the problem with that is that the
invoice is paid when any of those payment hashes has been received.  But an
attacker, if they can manipulate your software into using one of the payment
hashes in one case and the other in another case, which is what happened to
the LNP2PBot, they could trick you into thinking an invoice was not paid and
pay it again with one of the other payment hashes to achieve a double payout.
And that was exploited.  They, of course, made the fix before the BOLTs change
here, which was just to always use the first one in both of their pieces of
software.  But now there's an official BOLTs update to say that it should be
rejected if there's more than one payment hash, because the most likely
reason, since no one's found a real use for multiple payment hashes, is that
it's an attack if someone has multiple payment hashes in there.

It is likely that that exploit was found by an AI looking for ways to exploit
Lightning and it saw this opportunity where there were two pieces of software
that parsed the multiple payment hashes, and chose different ones as an
exploitable opportunity.  So, that's now closed both in the live software and
in the BOLT specification.

**Gustavo Flores Echaiz**: Right.  And if I might just add here that actually,
it did say that the writer of the Lightning invoice must include exactly one p
field.  But on the reader, it left some ambiguity when it said 'should' use
the first p field as the payment hash, right, and not 'must' use or must fail
the payment unless exactly one p field is present.  So, those are the phrases
that are added now with this item.  But yeah, that ambiguity allowed this
vulnerability to be exploited.  And I think the LNP2PBot case was the
specifically flagrant one, I don't know if you had time to look into that
case.

**Brandon Black**: I mean I talked about it with a guy at TABConf, and yeah,
the specific thing was that they had two different pieces of software that
both parsed it, and they parsed it and picked a different payment hash.  And
it just had to do with the frontend versus the backend parsing within the same
software stack.

**Gustavo Flores Echaiz**: Right.  Unfortunate.  Please carry on.

_BOLTs #1352_

**Brandon Black**: Right, the last item is BOLTs #1352.  So, this one is a
weird situation and I think demonstrates the challenges in both having a
specification for software and having the software be the specification.  So,
in this case, I read through the PR as you were talking earlier, and what
happened here is that there are two implementations out there, maybe even
more, but at least two were referenced here, of the simple taproot channels.
And the software in both agreed, but neither piece of software actually did
what the spec said, because the spec was wrong.  And it was wrong in not
critical, dangerous ways, but in kind of subtle, insufficiently specified
ways.  And so, someone pointed a clanker at the implementations and at the
spec and said, "What's the differences?" basically, and came up with, I think
it's 13 or something differences between the implementations and the spec,
where again, it would be basically impossible to implement the spec as
written, because it would violate other BIPs.  But it's still important to
have the spec match what the actual software has to do to implement these
simple taproot channels correctly.

So, that's what this PR fixes.  It goes back and goes bit by bit through the
spec.  And what the prompter had the clanker do is take every bit of the spec
and implement it again and make sure that once it was re-implemented from the
spec precisely, it also matched exactly what the two real implementations were
doing.  So, it's clearly now possible to go from spec to implementation and
have it match what others are already doing and match the other BIPs.  And so,
there were several things in here.  Some of the more interesting ones were,
for example, that the generation of MuSig nonces was not fully specified.  And
so, there was the potential for an implementer to create an insecure MuSig
nonce due to the loose specification.  And then, another one was that you
could get unsignable transactions, or potentially insecure transactions, it
was unclear to me from a brief reading which was possible, because of the use
of SIGHASH_SINGLE in the commitment signatures.  SIGHASH_SINGLE, you have to
be very careful that your transactions are constructed with the SIGHASH_SINGLE
input on the same place as the SIGHASH_SINGLE or corresponding output.  And
that wasn't fully specified in the BOLT before.

Anyway, so that's kind of that.  Again, the software was already correct in
this case.  The BOLTs were just not matching the software.

**Gustavo Flores Echaiz**: That's awesome.  Thank you so much, Brandon, for
covering that.  And thank you for co-hosting with me this newsletter and
everyone, including you, Vincent, for being present.  We thank listeners as
well and we'll see you all next week.  Thank you.

**Brandon Black**: Thanks so much, Gustavo.  See you soon.

{% include references.md %}
