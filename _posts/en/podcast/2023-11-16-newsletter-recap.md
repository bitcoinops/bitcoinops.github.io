---
title: 'Bitcoin Optech Newsletter #277 Recap Podcast'
permalink: /en/podcast/2023/11/16/
reference: /en/newsletters/2023/11/15/
name: 2023-11-16-recap
slug: 2023-11-16-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by Gregory Sanders, Antoine Poinsot,
and Max Edwards to discuss [Newsletter #277]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-10-16/355890865-22050-1-aecd7a4ca31e8.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #277 Recap on
Twitter Spaces.  Today, we're going to be discussing malleability in ephemeral
anchor spends, a field report from Wizardsardine about miniscript, testing
Bitcoin Core 26.0 using a recently drafted Testing Guide, and more.  I'm Mike
Schmidt, I'm a contributor at Bitcoin Optech and Executive Director at Brink,
funding Bitcoin open-source developers.  We have Murch out this week and next,
so I'll be joined by co-host, Dave Harding, for this week and next.  Dave, do
you want to introduce yourself and maybe plug the book?  Otherwise I'll have to
plug it for you.

**Dave Harding**: I'm Dave Harding, I'm a co-author of the Optech Newsletter and
also co-author of the recently released Mastering Bitcoin 3rd edition.

**Mike Schmidt**: Thanks for joining us this week, Dave.  Greg?

**Greg Sanders**: Hi, I'm Greg, or instagibbs.  So, I'm at Spiral now as a
"Bitcoin wizard".  I've done work with Core Lightning CLN teams of the Lightning
development as well as Bitcoin Core development.  I'm focusing on mempool and
relay policy currently.

**Mike Schmidt**: Antoine?

**Antoine Poinsot**: Hey, I'm Antoine, co-founder of Wizardsardine.  We're a,
let's say, security company on Bitcoin.  We developed the wallet, Liana, and I'm
also contributing to other open-source projects such as Bitcoin Core and in the
past, Lightning.

**Mike Schmidt**: Max?

**Max Edwards**: Hi, I'm Max.  I'm pretty new to Bitcoin space, but for the last
couple of years, I was working with LN Capital on Lightning, but looking to get
more involved on Bitcoin.

_Eliminating malleability from ephemeral anchor spends_

**Mike Schmidt**: Excellent, well thanks everybody for joining us this week.
We'll go through the newsletter sequentially here, starting with our first and
only news item titled Eliminating malleability from ephemeral anchor spends.
So, Greg Sanders posted to the Delving Bitcoin Forum with a post titled Segwit
Ephemeral Anchors.  Greg, I think, at least in my mind, one way to progress on
this, and the way that I have it in my mind for this discussion and to get the
audience up to speed, would be maybe first recapping ephemeral anchors proposal
and then second, what CLEANSTACK is and how the lack of CLEANSTACK and legacy
script can cause malleability issues.  And then lastly, the discussion around
handling those malleability issues that can arise.  Does that, do you think that
makes sense?

**Greg Sanders**: Yeah, I can do that.  So, yeah, I'll start off with a bit of
history.  So, the term "anchor" was coined by someone in the LN space.  So, for
every LN transaction you make, commitment transaction, the new spec has what's
called anchor outputs, which are outputs that are spent by a single party, they
have to have a certain amount of satoshis in them, otherwise they're considered
dust, so 330 satoshis.  And then there's timelock on it as well, so if no one
spends it, then about 16 blocks later, anyone can grab it.  So, it's this idea
that if you can't negotiate the fees after the fact, when these transactions are
broadcast, you need to do a CPFP bump on them using these anchors.  So, that's
the idea of the anchor.

Ephemeral anchors basically are a way of dropping this, simplifying how an
anchor is built and how it's spent, and minimizing the size of it.  So, an
ephemeral anchor is in any valued output, so it can be zero, it could be 10, it
could be a bitcoin, any value output that matches a certain script format.  So,
the original proposal was a base just OP_TRUE, the scriptPubKey being OP_TRUE.
And this would mean that by relay policy only, you are required to spend it in
the mempool.  So, in order for this transaction to get in the mempool, it has to
also be spent.  And this can be used as a drop-in replacement for these other
anchor systems, as well as it's just simpler, and you can do things like drop
the base fee for a commitment transaction to zero, so you can remove some
complications in the LN spec today, and just make things a lot simpler.  So, I
got that far, then I forgot what the next thing I was going to say was.  The
malleability?

**Mike Schmidt**: Yeah, the origins of the malleability with regards to legacy
script.

**Greg Sanders**: Got it.  Right, so I initially designed this using OP_TRUE
because it's the smallest thing, right?  It's basically you have a scriptPubKey
of size 1, and then when you're spending, you have an empty scriptSig, because
you don't need any kind of legacy witness data, and also it's not a segwit
output.  So, there's no what we call segregated witness data, segwit witness
data, so it's quite efficient to spend.

The problem with legacy script is that when Satoshi originally designed this, he
kind of, as far as we know, Bitcoin Script was kind of a late addition to the
project when he was building it.  And you had funny things, like if I do an
OP_TRUE, which then gets pushed to the stack, that if the program ends, that's
considered true, and then the program succeeds.  But by consensus, you can also
add something to the scriptSig, so adding non-segregated witness, witness data,
like I can put another OP_TRUE there.  So, if I put another OP_TRUE in the
scriptSig, it also succeeds.  So, now there's two things on the stack at the
end, but the top thing is true, therefore it succeeds, right?

So, there's a standardness kind of mempool policy, that says if you're relaying
a transaction in the mempool, that the CLEANSTACK should apply, meaning there
should only be one thing on the stack in the end and it should be truth-y,
should be value to true.  But this is only a mempool policy thing, because if
consensus allowed, for example, somebody pre-signed a transaction of some kind,
they held it in their cold storage, a pre-signed transaction, and if we change
it to where we require this CLEANSTACK principle by consensus, then suddenly
we've confiscated their funds.  So, because the horses are out the barn, we
can't really by consensus make these things illegal.  Does that track?  So, in
the scriptSig, if something's in the scriptSig, it actually changes the
transaction ID, which is the whole malleability.  Original segwit thing was
saying, "Hey, let's make sure the scriptSig is empty so people can't malleate
it", right?

So, you might ask, "Why is it a problem if your fee-bumping transaction gets
txid-malleated, right?  Maybe that's fine".  I thought this as well.  It's a
little weird to think about, but an example that came to me by way of Lisa
Neigut, niftynei, she said, "It would be great if we could use an LN channel
splice to CPFP a different channel's commitment transaction".  So, let's say you
have a channel partner you really trust, you have legally binding contracts, or
whatever, you just really trust them, maybe it's your Lightning Service Provider
(LSP) or something, and you have another channel with another counterparty that
you want to go to chain with, but you don't have the funds sitting around and
UTXOs to bump it.  What if I could coordinate with my channel partner, my active
channel partner, to CPFP bump that.  That sounds great, except what if I
convince my party to do this and then a miner intentionally mines a
txid-malleated version of our splicing transaction?  Because our splice would
have -- we would not include any scriptSig data for this anchor bump, which is
great, that works; but the miner could insert another OP_TRUE, for example, or
just malleate it in some other way.

So then, when we're putting funds back in the smart contract, where a splice is
basically taking funds in or out and then moving the rest back into the new
funding output, this new funding output would now have a different reference
point, a different txid in the output pair.  And then suddenly, all these
transactions we'd pre-signed for unilateral closes are now invalid.  So, this is
kind of like the fundamental "oops" here, as I realized, "Wait, this is really a
problem if we want to use ephemeral anchors in a composable way without handing
people footguns, essentially".  I'll pause here.  Does that make sense?

**Mike Schmidt**: Yeah, I think that makes sense.  So, just to recap, you
yourself as the author of the ephemeral anchors proposal were aware of the
malleability potential, but there didn't seem to be any concern about that
because there weren't any use cases for it.

**Greg Sanders**: Yeah, so if you're using it with a basic wallet for bumps,
then it means a miner could change the transaction ID of the bump.  It's like,
"Okay, so what?"  It's not like they changed the -- they didn't steal any fees
from you, they just confirmed your transaction.  That's great, that's what you
wanted.  But the problem is if you have pre-signed transactions based off of
these new outputs, then suddenly the reference point is gone, or it's malleated.
So, this is where I became kind of unhappy with the proposal after that, whereas
it's not really composable, right?  So, if you start thinking about, I want to
compose ephemeral anchors with other protocols, suddenly it seems unsafe.

**Mike Schmidt**: So, how do we make it composable, or potentially opt-in
composable?

**Greg Sanders**: Right, so once I thought about this, the natural thing to do
is say, okay, how about let's say as an example, v0 witness, P2WSH, right?
Let's say we take P2WSH of the script OP_TRUE.  So, this is essentially the same
thing, but wrapping it in the P2WSH.  But obviously, the scriptPubKey is 33
bytes longer, virtual bytes (vbytes), and then you also have to reveal the
OP_TRUE on the other side, so it's another weight unit.  That's pretty
inefficient, and it seems less attractive than the original possibility.  That's
a pretty hard hit to take.

Then, just before that post, I had realized that the real problem is I want a
soft fork.  I want someone to soft fork an ephemeral anchor, so you can't do
scriptSig, a non-zero scriptSig.  And then I realized, wait a second, they
already did a soft fork.  It's called BIP141.  BIP141 defines witness outputs.
So, you have a version number push, and then you have a 2- to 40-byte push.  So,
for example, taproot is defined as the v1 followed by a push of 32 bytes
exactly.  The other v1 output, so v1 with a push of 2 or 3 or 4 or 40, so on and
so forth, those are actually undefined.  So, those are valid to make and valid
to spend and they require no witness data.  And that was kind of the "aha"
moment.  I thought the 2-byte push seems kind of useless for other reasons, like
you can't commit to a key there, it's too small, but you can use it to guarantee
the scriptSig doesn't change.  So, instead of OP_TRUE being the ephemeral anchor
output, why don't we just do OP_TRUE or OP_1, same thing, followed by a 2-byte
push.  So, that's 3 vbytes longer, but then we get the soft fork I actually
wanted.

**Mike Schmidt**: And what is in those 2 bytes then?

**Greg Sanders**: It's whatever we want to be.  So, I initially tried 00,
because that seemed natural.  And then I realized after tests started failing,
that would be a hard fork because if the last thing pushed on the stack is
zero-ish, that means it's false, which means the program ends as a failure, so
all the tests failed.  So, instead I made it 0xffff, or four Fs, but then it can
be whatever you want it to be, really.  AJ suggested the encoding, it's 0x4e73,
which would, in bech32, spell out fees.  So, I picked that, because that seems
like it has an address format, since it's a segwit output, a witness program,
and so I just decided to make it kind of visually distinctive.  It's very short,
which makes it kind of obvious, but short and having fees on stands out pretty
much.

**Mike Schmidt**: Dave, I've been monopolizing the questions.  Do you have
comments or clarifications or questions for instagibbs?

**Dave Harding**: I don't think I have any questions, but I have a few comments.
So, I think some interesting things here is that the miner can still mutate the
spending transaction even with the segwit version, but they can't change the
txid, so it's still safe to use in those multiparty protocols.

**Greg Sanders**: Yeah, so the attacker, so to speak, attacker, miner, could
stop the witness themselves and change the witness transaction ID if they wanted
to, but again, that's not breaking the reference between transactions, so that's
kind of like the protections we get in segwit.

**Dave Harding**: Yeah, so I think it's a very nice, clever solution, and I
think just as a general rule, back to Lisa's point, I don't think this attack
would ever happen because I don't think a counterparty in a channel would ever
accept a non-entirely witness transaction.  So, if you're going to do splicing,
they just would say, "No, that's insane, I would never do that because you could
invalidate my pre-signed states".  So, it's just a really good solution here.

**Greg Sanders**: Yeah, the splicing spec requires it, and it makes a lot of
sense.  You don't want to have some weird exceptions.  It's kind of weird to
have exceptions to this rule for these kinds of use cases.

**Dave Harding**: Now, I guess my question here is, do you think anybody will
actually use the non-segwit vision, now that you've got it down to such a small
additional size, you know, it's just 3 extra bytes in the scriptPubKey; do you
think anybody's going to actually use the non-segwit vision, or are they just
going to go safety all the time?

**Greg Sanders**: So, my current thought is to expand the standardness as small
as possible.  So, I'm thinking just doing the segwit version.  If somehow we had
tons of uptake and we had a large user base that doesn't care about
txid-malleability, we can reconsider it.  But remember that if we expand, let's
say we offer both at the same time, then if we discover something new, like,
"Oh, we should have thought about this beforehand", we can't actually apply it
to the next version.  So, I'm thinking start with the smallest version.  Maybe
we'll learn something, make a mistake, learn something and if that's the case,
we can apply it to the next expansion.  I mean, you could also, if it becomes
really popular, we could always propose that as a minor soft fork, like OP_TRUE
is a very narrow thing, right, and by definition I'm pretty sure it can't be
theft.  So, some very far-flung future soft fork could just throw that in there
and say, "Hey, this is really popular, we'd like to save 3 bytes per package",
we can do that.

But that's also something we'd have to discuss because actually, if we're doing
a soft fork to improve this, to save bytes, we might want to talk about doing
something like SIGHASH_GROUP, because it's essentially a version of that, a
non-consensus version of that.  But that's another discussion.

**Dave Harding**: I think maybe the other thing there is, I guess, thank
goodness we have bech32m, because the original bech32, we would have had to put
size constraints on the witness script to prevent people from accidentally
paying the wrong address.  So, you're able to use this with a v1 witness
program, because we have bech32m; otherwise, we would have had to do what we did
for BIP143, which is constrain it to either 20 bytes or 30 bytes, or in this
case for taproot, 32 bytes.

**Greg Sanders**: Yeah, the other note is we learned something when we did the
original segwit, right?  We defined, for v0, we said only size 20 and 32 are
good witness programs, which would have precluded us from using v0 with a 2-byte
push.  So we learned something, and in taproot, we only restricted the 32-size
push, which is nice.  So, it was just kind of sitting there neatly waiting for
us to use in another capacity.  It was nice.

**Dave Harding**: Well, sure, but I mean just as a comment there, thank goodness
we did restrict v0 to 20 or 32 bytes, or we would have had to.

**Greg Sanders**: Two wrongs make a right there, yeah.

**Dave Harding**: Okay, I'll hand it back to Mike.

**Mike Schmidt**: We talked about the motivation as this idea of splicing and
composability.  Does the way that the modifications that you've made here that
we're talking about, it helps with composability with regards to splicing, but
I'm curious, does that also, in your estimation, solve composability for
potentially other protocols that would be using ephemeral anchors?

**Dave Harding**: I mean, anything that wants to spend an ephemeral anchor but
also have a pre-signed transaction based off of it, which you might say that's
kind of obscure, but you'll be surprised what people end up doing or trying to
do.  So, I think it's better to aim at safe at the cost of 3 vbytes, and then
reconsider later once the field is more developed.

**Mike Schmidt**: What's an argument against ephemeral anchors in this
incarnation?

**Dave Harding**: You mean non-segwit versus segwit?

**Mike Schmidt**: Yeah, or just assume one or the other or both; what is the
argument for not doing this?

**Greg Sanders**: So, if you do have a wallet that doesn't have pre-signed
transactions and you're properly tracking your UTXOs and not counting on txids
being stable, then I think it's fine to use non-segwit.  But I say that with
hesitancy, of course.  You think it's okay until it's not, right?

**Dave Harding**: Just as a comment there, I mean, we're talking about 3 extra
bytes and this is for CPFP.  So, if you're doing CPFP, you're already, in
theory, wasting a huge ton of bytes onchain because you're creating a whole
second transaction to fee bump.  So for me, it doesn't seem like there's any
real extra cost here from the 3 extra bytes.

**Greg Sanders**: Yeah, I mean, the real comparison is if you look at the
Lightning BOLT spec, what the cost of creating these transactions are with
relation to these anchors.  So, I just did the calculations last night, and
basically with ephemeral anchors, you're saving just bundles compared to that.
So, you're comparing kind of the case where you're just doing CPFP and what we
have today.  And it's back down to very near the cost of what transactions cost
before they had anchors, which were also very insecure.  So, it's like a secure
version of that at nearly the same cost.

**Mike Schmidt**: Thanks, Greg, for joining us.  I think that was a great
discussion.  You're welcome to stay on and chat miniscript and the Testing Guide
for 26.0 if you want, otherwise you're free to drop.

**Greg Sanders**: Thanks for having me.

_Field Report: A Miniscript Journey_

**Mike Schmidt**: Next segment from the newsletter this week was a field report
about miniscript.  So, occasionally we have folks that are in industry doing
great work utilizing Bitcoin open-source projects for their projects or for
their business.  And in many cases, they're happy to share their lessons learned
for the Optech audience.  And this week is an example of that with respect to
miniscript.  So, not only is Wizardsardine utilizing miniscript for their
business, but they also have a history of contributing to the effort around
miniscript.  In our newsletter, we've been highlighting developments in
miniscript as well as adoption of clients and services using miniscript in their
project or services.  But in this post, Antoine, you give us sort of a
high-level perspective and journey on miniscript adoption starting as far back
as 2020.  Maybe talk a little bit about some of the challenges back then.

**Antoine Poinsot**: Well, the challenge was around using Bitcoin Script for
advanced applications.  So, back when we were starting working on Revault,
making sure, and that's not an easy task, but making sure that the scripts we
were using were safe and the semantic was the one we said it was, and even more
so trying to generalize the script, we came up with a fixed size set of
participants, generalizing it to more participants, and making sure that we're
not going to rek the semantics of the script.  And well, we had heard about
miniscript before, so it was an interesting research project.  But yeah, at this
point, we really saw the practicality of it.  And so, we started experimenting
with miniscript, and basically it enabled us to build Revault and today to build
Liana.

**Mike Schmidt**: Maybe you can talk a little bit, I think we had you on a
couple of weeks ago, about not only, you know, we've talked with businesses who
are implementing certain technology at a wide scale, but with Brandon Black, for
example, and BitGo actually contributing to the MuSig2 spec.  And I think you
personally, as well as Wizardsardine, has been involved with trying to further
miniscript in different pieces of software and hardware devices.  Maybe you can
speak a little bit to your involvement on that side of things.

**Antoine Poinsot**: Yeah, so in order to have a reasonable wallet, new wallet,
new application, you probably want to convince more than your own implementation
to make the switch to a new technology.  And that was our case, for instance,
for Revault, where it was a vault architecture, so it's supposed to increase the
security of the funds, so necessarily it had to support connection with signing
devices.  However, signing of devices needs to be able to reconstruct the script
used by your wallet in order to make sure that the inputs are coming from your
wallet and that the change output is actually going back to your wallet, so that
you can perform the security checks on your device.  So, that's not the case.
So, even though we had started integrating miniscripts in our software, you
wouldn't be able to use it in production.

So, there's that, and then there is also wider ecosystem adoption of descriptors
in general as a way of backing up your scripts, in addition to your mnemonics,
in order to be able to recover from a backup without having one specific
software to be available.  This has set a standout that is just more widely
available.  And so, yeah, we did that.  We annoyed the signing devices
manufacturer for a while, for three years actually, until they finally, well we
broke the chicken and egg because the signing devices manufacturer obviously
have a large backlog of features, actually requested by customers to implement
for the devices.  And so your new technology that your software might be using
in the future that may or may not bring customers to the same devices
manufacturer is probably not a short-term priority for them.

The cycle was broken by first Stepan Snigirev from Specter and then by Salvatore
Ingala from Ledger, and mainly by Salvatore because he really refactored the
entire Bitcoin application on the Ledger device, which is not a small thing to
do when you think about all the funds that it should, that it would be securing
at the moment in order make PSBTs, descriptors, and miniscripts first-class
citizens and supported on the signing device.  So, armed with that, we were able
to release Liana at the beginning of the year to be used by anybody with actual
bitcoins, not only testnet coins.

**Mike Schmidt**: Sort of trying to get the hardware signing device providers to
adopt this is sort of a little bit in the review mirror, but towards the end of
your writeup the future is bright with most signing devices either having
implemented or in the process of implementing miniscript support.  In addition
to some of those hardware signing device companies implementing miniscript and
getting with it, what do you see beyond that for miniscript?  What else can we
look forward to in the miniscript ecosystem?  I know we had you on talking about
mini tapscript and some other things; do you want to get into that and maybe
even more?

**Antoine Poinsot**: Yeah, for mini tapscript, maybe the field report.  Well,
I've read the field report before the mini tapscript PR was moved in Bitcoin
Core.  So during that, we now have support for miniscript, even for tapscript,
which is already good news for what we are doing with Liana, because right now
the entire script is going to end up onchain when you are using Liana.  Soon
it's not going to be the case anymore, which is going to make it, using Liana,
more private, well it depends how you use it obviously, but it removes one of
the obvious ways of exposing your usage of the Liana wallet, and it's going to
make it less costly as well.  So, yeah, it was one of the last big pieces that I
was looking forward to for miniscript.

In terms of descriptors, more generally, there has been recent progress towards
standardizing using PSBTs and descriptors with MuSig for aggregating public
keys.  That's not something that we're using ourselves, but something that other
people are going to use, so that's exciting as well.  And also, we start seeing
some more usage of miniscripts around.  So for instance, there were discussions
on the Lightning specification repository about trying to make part of the
scripts miniscript-compatible, so that if the miniscript-compatibles are going
to be descriptor-compatible and you'll be able to recover the scripts in any
wallet that supports descriptors.  So, yeah, that's exciting.  And it's kind of
the same discussions that we just had about wasting a couple more vbytes just to
make it extra safe.

In this case, there is some optimizations that you can have by having, how do
you say it, bespoke scripts that would not be miniscript-compatible; but at the
expense of a couple more witness units, not even vbytes, because in the witness
you can make your scripts miniscript-compatible and make them compatible with
all the stuff to others that supports miniscript descriptors.  And there is
probably more to come.  All new softwares are probably going to be supporting
miniscript descriptors, so probably a good idea to support them.

**Mike Schmidt**: A bit of a meta question here.  You mentioned at the end of
the writeup, "The funding of open-source tools and frameworks lower the barrier
to entry for innovative companies to compete and, more generally, projects to be
implemented".  Do you want to talk a little bit about what you had in mind there
and how you see that?

**Antoine Poinsot**: Yeah, absolutely.  So basically, Revault started with Kevin
and I developing a Python prototype of something that would eventually become
Revault, that was broken at the time, but we fixed eventually.  And the result
of that was Revault.  Then, we looked into actually moving forward with Revault,
with specifying the communication between the different software that would take
part in the Revault architecture, so between the watchtowers, coordinating
servers, different wallets, and into implementing all that.  Would not be
possible to implement all this without some funding because at the time we were
working, both of us, on our companies and we needed money to leave.  And so we
weren't able to just spend one or two years implementing Revault without
funding.

But in order to get funding, we need to give reasonable guarantees to venture
capitalists that we can get product to market.  Of course, they are taking a
risk, that's what venture capital is, but wouldn't be comfortable raising money
without even being sure that our scripts are not completely broken.  In this
case, if it was not for miniscript, we would have never been able to start
Revault and eventually to start working on Liana, and I'm sure it's going to be
the case for new companies as well.  So, in this case, the development of the
miniscript framework as an open-source project was really an enabler for a small
company, two guys in the garage, as I said in the article, to be able to bring a
product to market and compete with bigger companies, let's say.  So, yeah, and
it's something that is supported by grants and all this stuff as well, and we've
seen progress on the side.  There are more and more donations going to
developers and more and more people building frameworks in the open.

So, miniscript was one such example, but for instance, we can think of toolkits
of SDKs that are being built, such as BDK.  Let's say in one year from now, two
years from now, it's going to be way easier for a small company to bring a
product to market than it was, I don't know, in 2015 or 2017, because all the
tooling is there in the app and ready to be used.  So, I think it's a good
dynamic that was put in the last years.

**Mike Schmidt**: Dave or Greg, any comments or questions for Antoine?

**Dave Harding**: First I just want to really, really thank Antoine for all the
development you've done here.  You've talked about your work on Revault and
Lianna, but you've also done an amazing job of upstreaming a lot of your work
and contributing to Bitcoin Core and to miniscript itself.  You've made an
incredible number of contributions there that you didn't have to do.  And a lot
of companies, they take open-source software and they run with it and they never
give it back and they never give it back substantially.  You give it back
substantially.  So, I really want to just start by thanking you there.

I think miniscript is really exciting.  I think if you look at Ethereum, which
is for me, it's often the poster child of how to do things wrong, for every time
somebody comes up with a different script to do something clever, or they think
it's clever, they had to basically build a new application, a new wallet around
it.  And I think when we look at Bitcoin, we don't want that.  We want people to
have a single signing device or a set of signing devices that they can use for
everything.  It's really clear what their security setup is and how separate
that is from these things they want to do.  For example, you want to have an
onchain wallet, you want to have a Lightning wallet, you want to have a cold
wallet, you should be able to use just plug-in components like hardware devices
to do that.  And miniscript makes that possible.

If we have a lot of devices that are miniscript-compatible, they can work with
Lightning.  Currently, the protocol doesn't use miniscript-compatible scripts.
But like you said, for a few extra witness bytes, we can make these things
compatible, they can use Lightning, they can use Revault, they can use Liana;
they can use a whole bunch of other stuff that's using advanced scripts, that's
using better security or alternative security, and just use their common
wallets, their favorite wallet interface to do that.  So, I think this is an
amazing initiative.  I'm really thankful to you and everybody who's working on
this for really levelling up Bitcoin security in a way that I don't think we see
altcoins doing.  In altcoins, we just see people building new wallets for every
single thing, and each one of those wallets is just a desktop client or it's a
mobile client.  It doesn't really build the security into it.

So, I just rambled for a bit.  I did have a question.  I know, Antoine, you're
also involved in some research in covenants, and it dovetails with some of the
work that you're doing on Revault and Liana.  How do you see covenant proposals,
for example, CTV, OP_CAT, OP_CHECKSIGFROMSTACK; do you think those are going to
be compatible with miniscript, or do you think we're going to need a complete
redesign of the language for handling that kind of stuff?

**Antoine Poinsot**: I think that interesting covenants are more powerful than
just, for instance, what CTV enables; you could integrate CTV into miniscript,
Jeremy did it back in the days.  For more interesting stuff, you basically lose
a lot of the interesting properties of miniscripts, so I believe we would have
to use a different type of framework in order to work with covenants and
miniscripts.

**Greg Sanders**: Yeah, so I'll speak up a little bit too.  I think, yeah, I
concur with everything David said.  One big point as well, what's the problem
with having a wallet that doesn't interoperate?  The problem is that you have
those with vendor lock-in.  So, if you install the latest smart contract wallet
in Bitcoin, if you have like a 3-of-5 or a timelock or whatever, the problem is
as a user, you're locked into that ecosystem.  That software developer is almost
a custodian of your coins, in some ways.  And I always thought for the longest
time, we were never going to get away from the single-key setup, because at
least single-key setup, people have their seed phrase, they can get their money
back, they can switch hardware wallets, software wallets, whatever, and get
their money back.  But I think miniscript is really the key to unlocking more
general, non-vendor-locked-in wallets.  And so that's what makes me excited.  I
think it's a practical thing that people can opt into these better security
models without being locked in to their vendor.  So, that's what excites me.

**Mike Schmidt**: Antoine, any final words before we wrap up the field report
section?

**Antoine Poinsot**: I think all worth it, thank you.

**Mike Schmidt**: So, everyone go try Liana Wallet, all right?  Antoine, you're
welcome to stay on through the rest of the newsletter.  If you have things
you've got to do, we understand, and you can drop.

**Antoine Poinsot**: I'll stay, thank you.

**Mike Schmidt**: Moving on to the Releases and release candidates section.
This week, we have three.

_LND 0.17.1-beta_

The first one is LND 0.17.1-beta.  I think we talked about the RC for this beta
last week.  And in addition to some bug fixes in this release, there are two
items that I thought were interesting to maybe highlight for the audience.  This
release uses an updated BTC wallet dependency that improves the performance of
mempool scanning, particularly when the mempool is large as it has been lately.
And the second item I thought was interesting is that this release for LND has a
functional change to the way that LND handles local force closes.  Previously,
LND would force sweep when the CPFP requirement was met; whereas with this
release, that's changed and it's changed to attempt automatic CPFP only when
there's a relevant Hash Time Locked Contract (HTLC) to that node that is going
to timeout in the next 144 blocks.

Part of that second change that I just mentioned also involves anchor sweeping.
And as part of the sweeping, "When supplying a wallet UTXO to a force sweeping,
we'd always try the smallest UTXO first, which provides a chance to aggregate
the small wallet UTXOs and keep the larger UTXOs available for other purposes".
So, as part of their sweeping now, there's a bit of consolidation of smaller
UTXOs going on there as well now.  Dave, did you have any commentary on the LND
release?

**Dave Harding**: I had a couple of things.  First of all, just a fun note.  The
thing you were just talking about, the CPF logic, in their release notes, they
don't call that an enhancement, they call it an enchantment.  I don't know if
that's a typo or just an amusing play on words!  The other thing is the mempool
improvement that you talked about.  That actually comes back to the topic we
discussed in Optech Newsletter #274, the replacement cycling vulnerability.  So,
one of LND's mitigations for that was that they began scanning the mempool for
preimages.  And they've actually had quite a few releases now where they've had
to fine-tune that.  It actually was a simple idea, but when they actually went
to implement it, it took up a lot of CPU, they had a lot of problems, and they
keep refining it as they find new edge cases.  So, that's just a fun callback,
or maybe not fun, to Newsletter #274.

_Bitcoin Core 26.0rc2_

**Mike Schmidt**: Excellent.  Thanks, Dave.  Next release candidate, Bitcoin
Core 26.0rc2.  And we have on special guest, Max Edwards, who as part of the
effort to get this RC tested, has created a Testing Guide, which is now
available on a link from the newsletter.  Max, maybe you could talk a little bit
about the motivation for having a Testing Guide.  What is an outcome that the
community would seek to see from having such a guide?

**Max Edwards**: Sure, yeah.  So, I'd say it's to try and get as much scrutiny
as possible on the new RC.  So, one of the things that the guide does is it will
list a lot of high-level items that have changed between the last version, so it
will really guide someone when looking at the new RC where they should spend
their time.  And it's also, I'd say, a great place for someone looking to add
value.  They might not have a lot of experience working on Bitcoin Core, I
include myself in that group, and so this guide will really help take someone
from the start and show them where they can test.

**Mike Schmidt**: So, as someone who's testing, I don't need to have any
familiarity necessarily with the codebase itself.  I can be testing either using
the GUI or there's a lot of command line related tests that you sort of walk
through in the guide.  Is that the experience level that that would be required
as someone who can kind of fire up the command line and run some bitcoin-cli
commands?

**Max Edwards**: Yeah, it's exactly that.  I think for this guide, it's pretty
much all CLI.  I'm trying to think if there's much you could do -- there are
probably some bits you could do with the GUI.  But no, it has a preparation
section where it doesn't assume much knowledge.  So, it will get you up and
running, get you a CLI environment with a data directory and the right values in
your comp file, things like that, to guide you through and explain how to clean
and reset your environment in between each test.  I'd say if you have no Bitcoin
experience whatsoever, maybe some of the things might be a bit abstract, but you
definitely don't have to have any exposure to the code.  You should be able to
follow the guide and get the outcomes, test that it works for you.

**Mike Schmidt**: And what are some of those prerequisites for being able to run
through the guide, and maybe roughly go through what people could expect
following the document?

**Max Edwards**: Yeah, sure.  So, the prerequisites are essentially you need to
have Bitcoin downloaded.  So, you can either just grab the RC binary, or it
links off the guide so that you can compile it yourself on your own machine.
And then, the rest of it is just like a shell environment where you set up a few
commands and a few aliases.  So, yeah, having access to Bash or an equivalent
shell, those two things are basically -- I tried to keep the prerequisites as
minimal as possible.  So, for example, you don't even require to have jq
installed on your system.

I suppose another thing to note is whether you need a synced mainnet node.  It's
not essential, but it would be great if you did.  Some of the tests, if we can
test them on mainnet, is always better than testing on signet.  But I'm pretty
sure for the vast majority of the document, there's an option to do it on
regtest or on signet.  So, you can start without having to have a big hard disk
or a pruned node or something like that.

**Mike Schmidt**: So, what sort of changes in this release are you particularly
focusing on, in terms of testing the different topics or categories of things
that people should be looking at, that you guide them through?

**Max Edwards**: Sure, I can go through what's in there, and then I can also
explain how we came to that list.  So, we're covering two new RPCs.  One is
getprioritisedtransactions, and another one is importmempool.  We've got a test
around the v2 transport, which is something people are quite excited about.
We've got a test on tap miniscript, which is fantastic that we've had Antoine on
this Space, because he actually helped me write that test.  We have
ancestor-aware funding, outbound connection management, and then something for
MacOS users; we have a new zip package, so it would be great if people could
download that zip and see if the new way of packaging Bitcoin works for them.

So, how we came to this list, I mean first of all, I had a look, and I think
there's over 600 merged PRs between v25 and v26.  So, it's immediately quite
intimidating, especially if you haven't been following the development very
closely, like it's a bit intimidating to figure out what's worth testing.  But
something to note is that when a lot of the developers have something they
think's important for a user to know about or for a user to test, they will
often add it into the release notes.  So, that was kind of the first port of
call to try and figure out a set of candidates to go in this document.  Then we
had some chats on IRC in the main Bitcoin-Dev IRC channel, and some more topics
were proposed, things that maybe hadn't gone into the release notes just yet.

Then from that sort of bigger list, it was whittled down to things that are very
useful for a user to test, because it might be difficult in code to come up with
every possible scenario.  So, if it's something that involves user data or
something with a mempool, like the mempool day-to-day, it's always going to be a
different shape, isn't it?  So, if it's something to do with a mempool, that
might be a great thing to test, for example.  And things that were excluded were
where it's basically very, very easy to verify that something is working, and
there aren't many options.  So there was, for example, some wallet UI changes
where an option had been removed.  We don't really need people testing that,
because it's pretty obvious for a few people running the software that that
option is now no longer there in the UI, so we don't waste people's time with
that.

**Mike Schmidt**: What's the appropriate avenue for someone who's going through
the Testing Guide?  I guess there could be two scenarios, and maybe one, they
have trouble with the guide itself in getting something to work; and maybe a
second category of thing is that maybe they perhaps come across something that
isn't working appropriately and they'd like to surface that to somebody, without
necessarily posting to the Bitcoin-Dev mailing list something that may or may
not actually be a bug.  Where should the feedback go from people?

**Max Edwards**: I think I'll cover the second item first because that's kind of
the reason for making the document.  If some bug is found in one of these new
features or these changes, then we need to know about it as soon as possible,
and then potentially a fix needs to go in before the RC goes out.  So, I'd say
it's all the regular places.  Creating an issue ticket on the Bitcoin GitHub
would be an obvious first place.  If you wanted to discuss it, jumping into IRC
is probably a great place to bring it up, the main dev channel there.  As for
feedback on the guide itself, at the top and bottom of the guide is a link to a
tracking issue for feedback on the document itself, so that's probably the place
to put it now.

**Mike Schmidt**: Excellent.  What is the timing like for somebody who's maybe
thinking about, "Hey, this sounds like a fun project, I want to learn a little
bit more about Bitcoin Core and potentially help out with some of this testing.
Can I do it next week?"  What's the sort of timeframe, or maybe incentivizing
people to do it sooner than later based on timelines?

**Max Edwards**: Yeah, I mean, I'd say from now.  The document's up, it's been
through a few rounds of review.  Yesterday, we went through it in the PR Review
Club, so I think it's ready for people to jump on.  And in terms of how much
time you'd have to commit to it, I'd say if you're starting from complete fresh,
a couple of hours maybe, I can probably run through it now myself in about 20
minutes, but that's because I've been through it and through it and through it
so many times.  But I think if you are seeing these things for the first time
and setting up your environment for the first time, yeah, if you had an evening
or so, I think that should be enough.  But it's ready from now.  And I think the
sooner the better, really, because I think the RC, I don't think there's been
many problems found with the second RC.  So, I think it's getting closer and
closer to a release.

**Mike Schmidt**: Max, I know you spent a lot of your time recently working on
the Scaling Lightning initiative.  How did you come to decide you wanted to put
your time toward creating this Bitcoin Core Testing Guide?

**Max Edwards**: Yeah, it's a bit of a change from what I was working on only a
few weeks ago.  So, I think working on Bitcoin Core has always been a dream or
the ultimate goal, but maybe the confidence to get involved wasn't there or not
really knowing how you could contribute.  So, I was talking with a few people,
including yourself, thank you very much, and it was suggested that this might be
a great first thing to have a look at, and it really was.  It was absolutely
fantastic to do, because in order to write a guide on how to test something, you
have to figure out how it works in the first place.  So, it was really
enjoyable, and I learned a huge amount doing it.

**Mike Schmidt**: Well, thanks for putting that together, Max.  Dave, do you
have comments on the Testing Guide or anything Max has said?

**Dave Harding**: Oh, absolutely.  First, I want to add to you, thanks.  Thank
you, Max, for putting that together.  A couple of comments, just for people who
are testing.  One other thing you can test is just test your own thing.  However
you use Bitcoin Core, that's the first test I think you should run, is just get
it installed using the instructions of the Testing Guide, the RC, and just go
through and test whatever you do.  If you're using a really heavy production
setup and you're a sysadmin, you really need to dedicate a few hours to this.
These major releases come every six months so it's not that big of a deal, and
you really want to find out these bugs before they can affect you in production.

The second thing is that it's okay to go off script.  So, Max has a great
script, it's some great documentation here, and I say that as somebody who's
been writing documentation for 20 years.  But if you're playing around with this
and you just want to play around some more with one of these steps, or you see
something that just interests you, it's okay to go off script, it's okay to test
features from previous releases.  One thing you can do is, if you get to the end
of this document and you want more, go pull up the Testing Guide for the
previous releases and give them a test. New releases don't just have bugs in the
new features, they sometimes have bugs in the old features.  We hope that
doesn't happen of course, but it can, and just have fun with this testing.  It's
work, but it's also a great way to experiment with features with Bitcoin Core
that you probably wouldn't often use, like the new RPCs, or
getprioritisedtransactions, that's something that miners usually only play
around with.  So, this is a way to have some fun playing with weird parts of
Bitcoin Core.

**Max Edwards**: I would absolutely agree on the going off script, because the
more people who run through this, it is a very scripted guide.  It's not likely
that these things will break now because that path has been very well trodden.
But in a few places, I've tried to give a little hint on maybe something you
could try yourself or how you could take it a bit further.  But I wanted the
guide to be so that if you haven't got much experience, you can run through it.
But then, yeah, obviously it would be a lot, lot more valuable if you can then
take that forward and go your own way.

**Mike Schmidt**: Thanks for putting this together, Max, thanks for joining us
and walking us through that, and thanks for hosting the Review Club yesterday on
the topic.  If folks are interested in how that discussion went down and some of
the prep that went into that, check out the PR Review Club for November 15, and
you can see more.  Max, any parting words?

**Max Edwards**: No, thanks for having me.

_Core Lightning 23.11rc1_

**Mike Schmidt**: All right, thanks for joining us.  We have one more release
from the newsletter, which is Core Lightning 23.11rc1.  We covered the same RC
last week in our Space and in Podcast #276, so refer back to that for a brief
overview.  I don't have anything to add to that this week.  Dave, is there
anything that you think is noteworthy to talk about here?

**Dave Harding**: This is a big release for them, so there's a lot there.  And
again, the reason we put this in the newsletters is so that people can go out
and test them, especially if you're a user, again, especially extra if you're
using it in a major production setting, and a lot of people do use CLN that way.
I don't know of any really exciting changes in this release that come to mind.
I'm just skimming the release notes right now, but I should have prepared
better.  But if you use CLN, absolutely go check out the draft release notes.
They're in the project's main directory under the file name changelog.md.

**Mike Schmidt**: We've given this warning before, maybe it's an opportunity to
do it again with these different RC that we just covered, which is we obviously
want these RC to be tested, and as Max mentioned, sometimes there's advantages
to doing those on mainnet, since these things are going to be on mainnet, but
that doesn't necessarily mean upgrade all your production machines to these RC
and start running them, because there's risk to that.  There was an incident I
saw on Twitter that someone had updated to one of the Lightning implementation
RCs sort of trustingly and had a bunch of their channels all force closed for
some reason.  So, I guess tread that fine line of testing it and maybe doing it
with a small subset of your production, or in a testing capacity, not
necessarily just blindly going to the RC.

_Bitcoin Core #28207_

Moving on to Notable code and documentation changes, we have two this week.  The
first one's to Bitcoin Core #28207.  And Dave, you did the writeup for this and
we have your brilliant Bitcoin mind here, so I thought it would be great to have
you take the lead on this one.

**Dave Harding**: Okay, this is actually a pretty simple change.  So, what it
does is change the way just slightly the mempool is stored on disk.
Transactions can include arbitrary data.  You can easily put those in an
OP_RETURN, or there's other ways you can include arbitrary data in a
transaction.  And when that arbitrary data gets stored on disk, it gets stored
on disk currently in a predictable fashion.  And what this means is somebody can
put in an OP_RETURN a series of bytes that virus scanners recognize as the
signature for a virus.  And those virus scanners will then flag the file, the
mempool, when it gets stored on disk, which often happens when you shut down
your node.  So, the node shuts down, it saves the current mempool to disk, and
then it reads it back up when it starts up.

The virus scanner sees that virus signature in a transaction in the mempool on
disk, it flags the file, it quarantines it, the next time Bitcoin Core starts
up, it tries to read the mempool, that file's been quarantined, it can't load
it.  Generally in Bitcoin Core, the mempool is not an essential file, so I think
it just starts up without the saved mempool.  That's not ideal, but that's not a
huge problem.  What we can do, and what's done in this PR, is that we can just
shift the bits a bit.  There's a simple way of doing this.  It's an XOR, it's
really fast on CPU processors.  If you want to do a little bit of research, you
can look into a Vernum cipher, which this is actually the original version of
it.  It's not a one-time pad because we actually cycle the same bits over and
over with the XOR operation.  But each node generates its own short sequence of
random bytes, and it takes the whole mempool, and it bit-shifts each byte in the
mempool when it saves it to disk, by those random bytes and writes it to disk.
So, each node saves the mempool in a different sequence of bytes, even if they
had identical mempools.

What this means is that someone who wants to put a virus signature in an
OP_RETURN output can't predict how that's going to be stored on each individual
node, because each individual node is doing it differently; and virus scanners,
because they can't predict, the attacker can't predict how it's going to be
stored, they can't cause people to have their mempools not loaded.  We've
actually been doing this for several years now, five, six years, for the
blockchain itself, because again, people would send these OP_RETURN transactions
or use other ways to encode virus signatures in the blockchain data.  And it's a
lot more important to Bitcoin Core that it be able to read its blocks from disk
in order to share this to peers and handle re-orgs.

So, again, this is a really simple process.  And the one downside of it is that
anybody who has written third-party software, software outside of Bitcoin Core,
that reads the mempool data from disk, now they can't do that unless they also
perform the XOR operation themselves.  So, Bitcoin Core writes the key that it's
going to use for the XOR operation to its log file.  So, you can just grab that
out of the log file and perform the XOR operation yourself, which is very easy
programmatically.  But just to make sure, Bitcoin Core has introduced a
backward-compatibility configuration option, -persistmempoolv1.  If you start
Bitcoin Core with this, it will write the mempool to disk without the XOR
operation, so your software can read it in the format that it's used to.

The Bitcoin Core developers don't believe anybody is currently reading the
mempool from disk with third-party software, and the mempool data structure is
not a fixed data structure, so it changes from release to release.  So, anybody
who has written software is going to have to update it for every release anyway.
So, they can still expect people to read it.  So, they're planning to remove
this backward-compatibility option in a release or two, unless people complain.
So, if you use that kind of software, if you're using software that reads the
mempool, please let them know.  You can just open an issue in the Bitcoin Core
repository to let the developers know that you need this, or just go and
implement the XOR operation yourself.

**Mike Schmidt**: Dave, are you aware if this is a reactive change to something
that has happened, or a proactive change, just knowing that people have messed
around with that sort of thing before and just trying to be proactive about it?

**Dave Harding**: The PR author, Marco Falke, I got the strong implication from
his PR that this is a proactive change.  Now, back in the day when this was
implemented for the block files, that was a reactive change.  People had put
viruses in the blockchain and the antivirus software on Windows particularly was
flagging the blockchain as virus and preventing Bitcoin Core from loading it,
which caused a lot of problem for Bitcoin Core.  And so, that was a big issue
back in the day.  Now, for the blockchain files, the way Bitcoin Core works
right now is it only applies this defense, this XOR operation, on Windows.  I
don't think it applies on a Mac, because Windows is where everybody uses
antivirus software.  It does not apply it by default on Linux.  You can turn it
on if you want, and you can turn it off if you want.  If you're going to access
the blockchain programmatically, you're going to want to turn it off.

For the mempool, Marco Falke said that he doesn't believe anybody is using the
mempool files.  So, the long-term intention there is this not to be an option,
for it to be applied in all cases on all platforms.

**Mike Schmidt**: Thanks, Dave.  I'll take this opportunity, as we jump into the
last notable code change this week, if anybody has questions for any of our
special guests or anything that we've covered this week, feel free to comment in
the thread here or request speaker access, and we'll try to get to your question
after this last PR.

_LDK #2715_

LDK 2715, allowing LDK nodes to optionally accept a smaller value HTLC than is
supposed to be delivered.  I think we've touched on this a couple of times over
the last few months, but why would we want such a feature?  Well, there's
actually an open BLIP related to this LDK change, which I think explains the
motivation well.  As a reminder, BLIPs are Bitcoin Lightning Improvement
Proposals, not to be confused with BOLTs.  And the BLIP in question here is
BLIP25, and it's titled, Allow forwarding HTLCs that underpay the onion encoded
value.  And I thought Val, who is the author of this BLIP, did a good job of
summarizing it in a few sentences, so I'll quote her here, "For context, it is
expected that many Lightning users will be connected to the Lightning Network
via LSPs (Lightning Service Providers), who will be responsible for managing
channel liquidity on end users' behalf.  Often users are onboarded to these
services via a just-in-time inbound channel when they first receive a payment.
However, this channel open costs money, and so liquidity providers may want to
take an extra fee from the received payment so that end users can help bear the
cost of this initial onchain fee.  This BLIP outlines how they may take said
fee".

So, if you follow this LDK #2715 PR, you'll actually stumble upon a reference to
this particular BLIP, which is somewhat the motivation.  Dave, did you have
comments on just-in-time channels or this LDK change?

**Dave Harding**: Not really.  It's just the one downside of this, I guess,
worth noting is it's fundamental with just-in-time channels that even though
this allows the upstream peer to take a bite out of the HTLC size, the upstream
peer doesn't actually get paid unless the downstream peer accepts that HTLC.
It's possible for these transactions to go to chain, the upstream peer to have
to pay a fee, an onchain transaction fee, but the downstream peer not to pay
them by not accepting the HTLC.  If you're a large LSP, you can mitigate this to
a certain degree using a RBF, but this is a, you can call it semi-trusted
protocol here, where you're just kind of hoping the downstream peer is going to
accept the HTLC because that HTLC is paying them money.

So, I guess that's just I wanted to add some color there.  This isn't a perfect
protocol, but this is a good way for the upstream peer to get paid for providing
a value for service.

**Mike Schmidt**: I don't see any questions or requests for speaker access.  So,
Dave, I think we can wrap up this week.  Thanks to our special guests, Antoine,
Max, and Greg, and thanks to my co-host, Dave, this week and we'll see you all
next week.  Cheers!

**Antoine Poinsot**: Thanks for having us.  Goodbye.

{% include references.md %}
