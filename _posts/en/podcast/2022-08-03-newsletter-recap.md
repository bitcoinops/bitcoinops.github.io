---
title: 'Bitcoin Optech Newsletter #211 Recap Podcast'
permalink: /en/podcast/2022/08/03/
reference: /en/newsletters/2022/08/03/
name: 2022-08-03-recap
slug: 2022-08-03-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Andrew Chow and Rodolfo Novak to discuss [Newsletter #211]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-9-2/349456327-22050-1-e86d07236edf8.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: All right, well, let's do some quick introductions and jump
into Newsletter #211.  So, I'm Mike Schmidt, I'm a contributor at Optech, and I
also run Brink, which is a not-for-profit funding Bitcoin developers.  Murch, do
you want to introduce yourself real quick?

**Mark Erhardt**: Sure.  Hi, I'm Murch, I work at Chaincode Labs.  I co-host the
New York BitDevs, and I'm a moderator on Bitcoin Stack Exchange.  I try to
contribute to various projects in this space.

**Mike Schmidt**: Andrew, you want to give a little introduction for folks who
don't already know who you are?

**Andrew Chow**: Yeah, I'm Andrew, I am an engineer at Blockstream, and I work
on Bitcoin Core mostly in the wallet.

_Multiple derivation path descriptors_

**Mike Schmidt**: Excellent.  Well, the reason that we wanted to have Andrew on
this week was that our news item here is about a mailing list post and a
proposed BIP.  I'll take a quick crack at a high-level summary and then, Andrew,
I'd like you to expand on it, and then I have a couple of questions and a few
discussion items we can have about the BIP.  So, my understanding is the
proposed BIP is to add some functionality, essentially augmenting BIP380, which
specifies script descriptors, and allowing those script descriptors to -- you
can essentially specify multiple derivation paths in a single descriptor as
opposed to having multiple descriptors that largely duplicate the same
information.  I guess the canonical use case is a receive address or a set of
receive addresses and then a descriptor for change addresses.  So, this
simplifies that common use case as well as eliminating a lot of duplication.  Is
that directionally correct, Andrew; do you want to elaborate on that a bit?

**Andrew Chow**: Yeah, that's basically correct.  So, the problem is basically,
people were using descriptor wallets and they realized that in order to make a
backup of their wallet, if they're using a really simple one that just has one
set of keys and one script type, they would still have to have two descriptors,
one for receiving, one for change, and these descriptors would be identical
except for one derivation path element.  And so, someone a while back requested
a way to represent both of those in one descriptor, and so that's what this
proposed BIP does.  It's a new syntax in the descriptor derivation path thing
that allows you to specify any number of elements of path indexes that can go in
that space.  And it just expands into a bunch of descriptors of each one having
a different element in that space.

**Mike Schmidt**: What was the origin of that of that request?  I missed that
part that somebody had requested this feature.

**Andrew Chow**: This was requested probably a year-and-a-half or two years ago
or something.  And I believe it was from Craig Raw with Sparrow wallet.  I think
he was the first one that asked this, maybe someone else did, I don't remember.
But after that happened, I had opened a PR to Bitcoin Core to add it, and there
had been some discussion on the actual syntax to use, and Sparrow was the first
one to start using it long before the BIP existed.  So, there's been a PR open
at the core for like a year, and then only recently have I decided to finally
write a BIP for it.

**Mike Schmidt**: Gotcha.  And so, the BIP seems to specify more generally a
syntax for allowing multiple path descriptors, it's not just a receive and
change specification.  Is that right?  And I know there's some discussion on the
mailing list about that.  It seems like you're proposing something more
generalized, but also if there is a case of two path descriptors, that you sort
of treat it like receive and change, but there could potentially be three path
descriptors or four or five.

**Andrew Chow**: Yeah.  So, the original spec was just two for receive and
change, but some people have requested that it be a bit more general to allow
any number.  So, you could have three, four, five, however many you want.  And I
think the main thing now is just going to be that we interpret two as the first
is received, the second is changed, and then with any more than that, we're not
going to interpret what each descriptor should be used for until some future
specification that needs those extra descriptors comes along.  So, I think that
was Dimitri's suggestion, that we should only have two have a specific meaning;
anything else does not have any meaning, but can still be parsed, still becomes
a bunch of descriptors, just no specific use case yet.

**Mike Schmidt**: So, how do you think about that?  Because you could just
specify the BIP for the two, and this is how it should be treated; and then when
someone comes along for three, or whatever, I guess they could propose a BIP
that specifies how those should be handled in theory.  Although there could be
competing use cases for a different number of path derivations, I suppose.  But
I guess this is sort of two in one: one is the syntax to specify path
descriptors; and then a second portion of it is specifying how you should treat
two path descriptors.  I guess, how do you think about restricting it just to
the two versus allowing it to support many and unspecified behavior for those?

**Andrew Chow**: So, the general ethos with descriptors, I would say, is to be
really generic.  So, we can allow a lot of things to happen, we can allow the
user to do whatever they want.  And so under that ethos, it seems reasonable
that you should allow a descriptor to have a ton of multipath specifiers.  So,
the original idea was to be extremely generic where any of the path elements
could have a multipath specifier, but this is actually completely impractical
because it's a combinatorial explosion there, so then we limit it to just one.
And with just one, it's still reasonable to have any number of these in the
multipath specifier.  So, I went with being a bit more generic than restricting
to two and allowing however many because it only grows linearly instead of
exponentially.

The idea is that a descriptor allows you to watch and spend for the addresses
that it specifies.  So, even when there is no meaning assigned to more than two
multipath descriptors, even when there's no meaning assigned to those other
descriptors, a wallet today, if it implemented the spec, would still be able to
watch for all the coins sent to those addresses, would still be able to generate
those addresses, would still be able to spend them.  So, even if a meaning is
assigned in the future, it's not necessarily breaking anything.  Like, a future
meaning would kind of be a soft fork; it's restricting what you can use these
for, rather than saying, "Here's a new type of descriptor that we need to add".

**Mark Erhardt**: I think what's really interesting here is, it's a generic way
of being able to make everyone that implements the spec be able to recover all
the coins that were sent to all paths.  Even if they only understand the first
two to have a specific meaning, you will generally be able to recover your
coins, spend them, and then, yeah, as Andy said, it's sort of soft forking in
more meaning later, but starting very generic at first.  And maybe to just give
an example, so some services have started allowing their users to set one
specific derivation, or to hand over an extended public key, so that when they
withdraw they automatically always use a new address.  They still share this
information with the service of course, and the service will be able to derive
all the addresses in that chain, but nobody else learns because they don't reuse
addresses.  And by having the ability to have multiple descriptors in a wallet,
you can have your generic receive addresses, your change addresses, and then
such paths, extended public keys, that you use for specific services, for
example.

**Andrew Chow**: Right, that's the general idea around behind having more than
just two paths.

**Mike Schmidt**: So currently, this would be done just essentially copying and
pasting the original descriptor and changing the derivation path, so you'd have
duplication of a lot of that same information; for descriptor one, or descriptor
zero, which would be receive addresses, and copy and paste that again, and
change the derivation path for descriptor two, or the second descriptor, which
would be the change.  That doesn't sound so bad, Andrew.  So, what are some
other maybe reasons why this copying and pasting is bad, or this duplication of
these descriptors and just tweaking the derivation path is bad; are there
considerations for hardware devices, et cetera?

**Andrew Chow**: Well, I think there's two reasons.  One is for users.  So, when
a user exports their wallet or something and they get a descriptor back, they
may not realize that they actually need to get two descriptors back, not just
one, because if they don't get the change descriptor, then now they're missing
all their change funds and that's bad.  So, there's kind of a usability aspect
where it's confusing if the user gets two things back, when in their head they
think it should be one because users are often not aware of the whole change
thing.

The second part is that when you have more complicated descriptors, it can get
pretty unwieldy.  So, the simple example is just a multisig.  When you do
multisigs, you want all the participants to also be using the change and receive
paths.  So now, every single key in the multisig has to have this derivation
path changed, you have to make sure that each one is changed.  And then if
you're copying a multisig descriptor, they can go up to n of 20, 15, 20,
something like that. and those can be pretty big.  So, it's still not that
simple.  And with miniscript, because miniscript is just an extension of
descriptors, miniscript you have way more complicated policies with tons of
keys, and whatever.  And all of those, you might also want to have the change
and receive path.  And so, it can get even crazier when you add in miniscript to
this.

So, having the syntax just to do all of that in one descriptor is a lot easier
and a lot simpler when we account for all the other cool things that you can do
with descriptors.

**Mike Schmidt**: That makes sense.  Are there any strong, valid objections to
this?  Do you expect that there would be any sort of pushback here, or is this
going to be smooth sailing for adoption, since there actually is already
seemingly some adoption from some of the Sparrow folks?

**Andrew Chow**: I expect that it will be pretty smooth sailing.  It's still a
pretty small change, and I intentionally chose characters that were not being
used anywhere else in descriptors so that implementing it would be super-easy.
And yeah, I've spoken with all the people who work on miniscript, like Andrew
Poelstra, Pieter Wuille, and they all seem fine, or at least ambivalent towards
it, so I don't think there will be any blockers on this.

**Mike Schmidt**: When you're thinking about a change like this, or I guess an
enhancement to a spec in which potentially multiple software vendors and
organizations would want to buy in or opine on it, is the place to have that
discussion the Bitcoin-Dev mailing list, or do you also reach out in other group
chats or email lists, or individually to wallet developers to socialize these
sorts of ideas?

**Andrew Chow**: I think the Bitcoin-Dev mailing list is the primary place for
this kind of discussion.  And personally, I do reach out to some people.  So for
example, Ledger uses a slightly different syntax.  They invented their own
different syntax to do change and receiving, because they needed to have this
too.  So, I've reached out to the people at Ledger that implemented this and
told them about the spec and the proposed syntax so that they're aware of it,
and then they can start implementing it.  So, I mean for me it's Bitcoin-Dev
mailing list, and then also talking to specific people that I know who were
interested in this change.

**Mike Schmidt**: It sounds like, from what you mentioned, since some of the
motivation here was from the Sparrow wallet team, that they already have a
similar syntax.  Now, I saw Pavel from SatoshiLabs also saying that they've been
using this for quite some time in Trezor in production.  Do you have an idea;
are they using that same syntax that Sparrow's using that you've also proposed,
or are they using a separate syntax from what is in the BIP?

**Andrew Chow**: I think they're using the same one, because they're both based
on the PR to Core that I wrote a while back, and that uses the same syntax.  So,
I think they're all just using the same thing, which is great, because that
means they're already compatible.

**Mike Schmidt**: Would it have been, I don't know if this happened or not, but
you mentioned that there was a different syntax proposed by the Ledger folks and
that they're potentially using that in the wallet space; since there's so many
different softwares and vendors, should they have brought that to the mailing
list or should they have discussed on your previous PR their syntax or, I mean
obviously they have the full right to go ahead and write their software as they
wish, but it would seem like now they've sort of caused a bit of an issue for
themselves?  I'm just wondering if you would encourage folks working on some of
that spec-type stuff to surface those discussions a bit sooner.

**Andrew Chow**: Yeah, so I would say that people who are working on specs that
aren't fully complete to be a little cautious, and if they're adding something
new, they should probably propose it to the mailing list.  But I know that for
Ledger specifically, it's not really a problem for them, and this change is
simple enough that it is just a drop-in replacement and they can add some code
to deal with both ways of doing it.  So, it's not that much of a problem.  But
yeah, in general, I am of the opinion that adding spec changes or adding your
own changes to an existing specification should be something that goes on the
mailing list, especially when it's something that will be external, so when
other developers will see it or when users will see it.  But I also know that
several wallets don't do this, and even in Bitcoin Core, we kind of didn't do
it.  Descriptors was implemented in Core long before the BIPs were written.  So,
it's something that we should aspire to do.

**Mike Schmidt**: Speaking of wallet vendors and developers, Rodolfo, I see that
you've joined us.  I invited you to speak.  If you're not in the middle of
something, feel free to opine on some of this.  Murch, any other ways we could
explore this topic that you think would be valuable?

**Mark Erhardt**: I think that maybe it's important to point out that it's been
a very long use that you have these two paths and I think this is this is all
pretty straightforward and expected, and it just makes the backups more powerful
and as Andy said, it keeps everything in one place so you have a single item
that backs up the whole wallet.  So, I think we've mostly covered it.  I see
that Rodolfo is up here now.

**Rodolfo Novak**: Hey guys, I am driving in a location that may be bad cell
signal, so if I drop, I drop, but if I can contribute anything, let me know.

**Mike Schmidt**: What is a Coldcard's take on multiple-derivation-path
descriptors and the BIP?

**Rodolfo Novak**: Yeah, so I haven't looked too much into it but generally
speaking, if it's not something that breaks too much what we do and how we do
things, we tend to integrate them, especially if they become a BIP.  Unless it's
something we want to do, we tend to not integrate things that are not BIPs yet,
just because it's mostly about not doing things that we have to redo after,
because the install base is quite large now, so that can be a problem.  We don't
want to have to have users update the software if they don't have to.  But yeah,
I mean it will be nice.  I think even with the current version, people have
stopped having issues with recovery.  I'd say since we all moved to PSBTs and we
had the earlier versions of descriptors, although we don't find that most users
use descriptors at all, although it's been in Coldcard for quite some time now,
I think that a lot of the issues have greatly dismissed and we can see that on
support.  Hardly ever we get an issue where somebody doesn't have the paths.  I
think it's attributed to the fact that paths are now mostly standard between
wallets, and the biggest install base for desktop wallets seem to be Electrum
and Sparrow, and those two share the same defaults.  So, I think it's just how
the cards fell on the table, more than original design.

**Mike Schmidt**: Andrew, any comments on any of that?

**Andrew Chow**: No, not really.  Well, the derivation patterns is one thing,
but still the other thing that is important is the address types, which
descriptors covers but BIP39 doesn't and BIT32 doesn't.  So, descriptors does
fill in that gap, but also there are default types for certain derivation paths,
so it also doesn't matter.  And because everyone uses the same defaults, it's
not a huge problem currently.

**Rodolfo Novak**: Yeah, that's exactly what happened.  Since segwit native
became the default in all wallets, the support tickets or user requests or any
issues really completely disappeared.  We do not have users ever asking for help
with any of this stuff anymore.

**Mark Erhardt**: That's awesome, I'm glad to hear that.

**Mike Schmidt**: Yeah, I'm glad we're moving ahead as an industry.  I don't
envy a lot of the challenges that you folks on the wallet side run into, but it
sounds like things are coming together in the ecosystem naturally, so, that's
good.

**Mark Erhardt**: Also, maybe one more comment.  I think it's really nice that
we have multiple paths, because for one, I know that some enterprise businesses
use more than two derivation paths.  They have a single shared secret, and then
they add more paths for each output type.  And now with the standard, they'll be
able to represent their derivation paths in the same way as everybody else.  So,
it kind of ties back alternative standards into one big thing.

**Mike Schmidt**: Should we move on from the news, Murch?

**Mark Erhardt**: Yes.

_Core Lightning #5441_

**Mike Schmidt**: So, we're just going to continue through the Optech Newsletter
#211, and under Notable code and documentation changes, there is a Core
Lightning #5441, which updates hsmtool to make it easier to check a BIP39
passphrase against HD seed used by Core Lightning's (CLN's) internal wallet.
And that PR seems pretty straightforward.  It essentially gives the user a way
to check that the secret is the correct one, the one that you have.  I don't
have too much familiarity with that tool or that use case, but it seems pretty
straightforward.  Anybody have a comment on that?

**Mark Erhardt**: Maybe a little bit.  So, one of the problems with Lightning
is, of course, just backing up the regular key material.  But the other bigger
problem is updating the channel states for open Hash Time Locked Contracts
(HTLCs), and so this is strictly under, just make sure that we can check what
key we have, and the backup of a Lightning wallet is still a lot more complex
with the moving parts from the channel state.

_Eclair #2253_

**Mike Schmidt**: The next relevant PR here is Eclair #2253, which adds support
for relaying blinded payments, and that's specified in BOLTs #765.  And so,
Eclair previously had support for onion messages that was opt-in, and this was
about nine months ago, but they did not have support for route blinding, and so
this PR augments that support to add blinded payments, I think also commonly
referred to as rendez-vous routing, or at least previously was.  Murch, any
thoughts on blinded payments?

**Mark Erhardt**: Yeah, maybe just a small recap.  The idea here is, in
Lightning, the sender already has pretty good privacy.  They construct the
route, they package everything up in onions, and the receiver only gets the last
layer of the onion after all the other layers have been peeled back, and
obviously all the forwarders only see the one stage of the onion before
forwarding the remainder to the next hub.  This is specifically about receiver
privacy.  So, if you want to receive a payment on LN, you basically can
construct the last few hops on the innermost parts of the onion before you send
out your payment request, and then the sender will basically use this kernel of
the onion to put the other layers around, and they don't see the last few hops.
So, the receiver will still get paid, but the receiver decided the last few
hops, and the sender never knows what the last few hops were.  So, they don't
actually necessarily know who they paid and what node ID it was and what
channels got used.

**Mike Schmidt**: Yeah, that's a great explanation and great clarification.
Yeah, thank you, Murch.

_LDK #1519_

The next item here is LDK #1519, which is a change that the htlc_maximum_msat
field, during channel update messages, will be required, and it sounds like most
implementations are already doing that, even though it looks like the BOLTs that
specifies this, #996, is still -- there's a PR to BOLT7 which is BOLTs #996
which is still open, but it sounds like most implementations are already
including that field and that would just make it required.  My understanding is
that this just simplifies the message parsing on the client side by requiring
that field there.  Murch, I don't know if you have any other background on the
motivation for that.

**Mark Erhardt**: Yeah, I got to write the recap when we talked about that
recently, so I looked a little bit into what this field does.  What this field
does is it specifies how much money a single HTLC can lock up in the channel, so
it gives an upper bound on the individual payment that can be forwarded.  And
while that was an optional field before, I read in one of these PRs that
something like 99% of all channel updates already sent this update.  So, why LDK
especially is proposing to introduce this field as mandatory is, they want to
use it as a stand-in for the maximum channel capacity that can be used in either
way across multiple HTLCs.

So, the idea is if you don't allow the whole channel balance to be utilized at
the same time and locked up in HTLCs, it'll be hard for probing attacks to find
out where the capacity sits in the channel.  Specifically, if you make the
maximum capacity that can be locked up in HTLCs less than half of the channel
balance, they can only find out where the channel balance is sitting by probing
from both sides, and only if it's less than the maximum on one of those two
sides.  So, yeah, basically this is just an upper bound for a single payment,
but the idea is to get better privacy against probing attacks.

**Mike Schmidt**: Makes sense.  Rodolfo or Andrew, if you have any comments on
any of these PRs, feel free to jump in.  I know we were talking more about
wallets and descriptors before, but you don't have to stay silent if you got
something to say.

_Rust Bitcoin #994_

The last two PRs are both for Rust Bitcoin.  One is related to LockTime and one
is related to compact blocks.  So, the LockTime type being added to Rust Bitcoin
can be used with nLockTime as well as essentially BIP65 fields.  I'm not sure if
everybody is familiar with LockTime.  Maybe, Murch, you can give a bit of an
overview of the LockTime options, as well as what Rust Bitcoin is doing to add
LockTime, if you're familiar?

**Mark Erhardt**: Andy might be able to help out with this one too, but
generally LockTime allows you to encumber a transaction so that it only becomes
valid at some point in the future.  If you specify a LockTime that is below a
certain value, it refers to a height, and that means that at that height, the
transaction can be included in the block and it becomes valid to be relayed on
the network at one less height.  So, you cannot send it before -- well, if you
put it to 100, it can be included in block 100 and can be relayed after block 99
is found.

The other way of using the LockTime field specifies a Unix epoch time, and then
the number is interpreted as seconds after 1970, I believe, and I think it's a
few hours of window before that that you're allowed to relay and put it into a
block to account for bad timestamps on servers, and stuff like that.  Yeah, so
where this is used is, for example, in LN and so forth, we use LockTimes to --
actually, I don't know where I'm going with this.  But yeah, LockTimes are
useful to build cool smart contracts.

**Mike Schmidt**: Andrew anything to add on LockTimes?

**Andrew Chow**: No, I suspect this may be related to miniscript because I know
Rust miniscript uses Rust Bitcoin, and miniscript allows you to do LockTime
stuff, so this might be added because of that.

**Mike Schmidt**: Oh, it's sort of like a prerequisite to adding that to
miniscript, then?

**Andrew Chow**: Possibly.

**Mike Schmidt**: Okay.

**Andrew Chow**: I'm not sure, I haven't actually looked at it.  But I mean, I'm
surprised that Rust Bitcoin didn't have LockTime stuff in there but also, okay,
I mean the second sentence on the PR says, "For example usage in
rust-miniscript".  So, I'm guessing this is back-porting something out of
miniscript.

_Rust Bitcoin #1088_

**Mike Schmidt**: That makes sense, yeah.  The last PR here is Rust Bitcoin
#1088, which is essentially similar, adding capabilities for compact blocks.
So, the idea behind compact blocks is that instead of relaying a block full of
transactions that potentially your peer already knows, you can essentially send
that block without having complete copies of those transactions.  So, if your
peer already has those transactions in their mempool from being relayed
previously, you don't need to download those transactions again.  So, it
essentially makes block relay a lot faster to your peers and saves bandwidth and
it's all good.  And that's been around for a while now, and it sounds like this
is another PR to Rust Bitcoin in which they're adding at least some of the
initial structures to allow for compact blocks and the creation of a compact
block.

**Mark Erhardt**: Yeah, I guess maybe.  So, this was proposed in 2016 and the
idea is, as you said, to only relay transactions once.  And why only once?
Well, a full node already will gossip about unconfirmed transactions they hear
about and put them in their mempool, and of course miners then build the blocks
from their own mempools.  So, most nodes will have seen most of the unconfirmed
transactions before they're included in blocks.  And when they first see the
transaction, they need to verify already whether the transaction is valid to be
included in a block at that point, so they have done most of the verification
work.  The only step that misses is, they will have to check in the block itself
whether the block is composed of only transactions that are valid in
combination.

What the compact block does is, it basically gives you only the ingredient list
of the block with short txids and just a list of transactions.  There was an
extension proposed a long time ago that it would automatically also send the
last five or so transactions that the node that was learning about the block
itself didn't have yet, because it would assume that its peers might not have
heard about those transactions either yet.  But so far, I think that's never
been implemented in any of the whole node software that supports compact blocks.
So, yeah, by having verified already the transaction when they first got
gossiped, they can skip a lot of the transaction verification when they get the
compact block announcement because they already know that they validated the
transaction, and it actually reduces the amount of data that gets sent over the
wire to announce a new block by something like 90%, 95%, which makes block relay
a lot faster and cheaper.

**Mike Schmidt**: Great.  Well, thanks everybody for joining.  I think I marked
this space as recorded, so feel free to share that out if you thought it was
valuable and that other folks would be interested.  I think last week we had a
couple hundred listen live total, and then a couple hundred more listened to the
recordings, at least last I checked.  So, I'm glad some folks are getting value
out of this, and we'll do another one next week, and we'll see you all then.

**Mark Erhardt**: All right, thanks for joining.  Bye.

{% include references.md %}
