---
title: 'Bitcoin Optech Newsletter #399 Recap Podcast'
permalink: /en/podcast/2026/04/07/
reference: /en/newsletters/2026/04/03/
name: 2026-04-07-recap
slug: 2026-04-07-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by Armin Sabouri, Pyth,
Conduition, and Jonas Nick to discuss [Newsletter #399]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-3-7/421605898-44100-2-81e3c3e7ca6a2.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Optech Recap #399.  Today, we're going to
be talking about a wallet fingerprinting series of risks that have been brought
up around payjoin and privacy; we also have a draft BIP around wallet backup
metadata formats; we're going to talk, in our Changing consensus monthly
segment, about Isogeny approach to post-quantum cryptography; we have the
SHRIMPS post-quantum signature construction that we're going to talk about; and
we have great or grand restoration BIPs that are getting their numbers as well.
This week, Murch, Gustavo and I are joined by four guests.  We'll have them
introduce themselves briefly and then we'll jump into the newsletter.  Armin?

**Armin Sabouri**: Hello, Armin here.  I've been in the Bitcoin space,
specifically self-custody, for a little bit over half a decade.  My focus right
now is on Bitcoin privacy, where I contribute to the Payjoin Dev Kit (PDK) and
just think about privacy in general.

**Mike Schmidt**: Thank you.  Pyth?

**Pyth**: Hi, guys, I'm Pyth, I'm working at Wizardsardine, mainly on Liana
Wallet.

**Mike Schmidt**: Conduition?

**Conduition**: Hi, I'm Conduition, I'm a freelance cryptographic engineer and
open-source researcher.  Recently, my focus has been on various forms of
post-quantum cryptography, namely hash-based and Isogeny-based.

**Mike Schmidt**: And Jonas.

**Jonas Nick**: Hey, everyone, I'm Director of Research at Blockstream.  We work
on programming languages for blockchains, like Simplicity, and we work on
cryptography for Bitcoin, focusing as well on classic cryptography that is not
secure against quantum computers, and cryptography that is secure against
quantum computers.

_SHRIMPS: 2.5 KB post-quantum signatures across multiple stateful devices_

**Mike Schmidt**: And that's what we'll pick up.  So, if you're listening, we're
going to actually jump to the Changing consensus segment, a little bit out of
order in deference to our guests.  We're going to jump to, "SHRIMPS: 2.5 kB
post-quantum signatures across multiple stateful devices", which was from
Jonas's post to Delving Bitcoin.  We had Jonas on in #391 to talk about SPHINCS+
SHRINCS, and now we have him back again to talk about SHRIMPS.  So, Jonas, how
does this constellation of things fit together, and then we can get into some
details on SHRIMPS?

**Jonas Nick**: Yeah, so SHRIMPS is a hash-based signature scheme, just like
SHRINCS and SLH-DSA and SPHINCS, if people have heard about that.  The advantage
is that it's smaller than at least standard SPHINCS+ and the standardized
SLH-DSA scheme.  How does it achieve that?  It assumes a wallet that is
stateful, and this is something that is shared with SHRINCS.  Now, SHRINCS is
more efficient than SHRIMPS, and that's why SHRIMPS is best understood when
first talking about SHRINCS.  So, just to remind everyone what SHRINCS is,
SHRINCS is a very efficient hash-based signature scheme, where the signatures
are about 350 bytes in certain situations.  So, the way this works is we are
exploiting the fact that in Bitcoin, we usually only do a few signatures for
every public key.  This is different to most other applications for signatures,
where we publish a public key and then we make arbitrary many signatures.  In
Bitcoin, we don't try to reuse addresses, and therefore we only make few
signatures per public key.  And that allows SHRINCS to make these very small
signatures.

As I said, this requires the wallet to be stateful, so essentially what the
wallet needs to do, it needs to remember an integer for every public key that it
generated, and this integer just represents how often did the device, the
signer, sign with this for this public key.  So, it's just an incrementing
integer.  If that is wrong, then the security of the system breaks down.  So,
this is a very big assumption.  And if the state is lost, then SHRINCS is set up
in a way where the signer can use a fallback signature scheme that is then
rather large.  Depending on the parameters, it would be between 4 kB and 8 kB,
seems to be the most realistic.  So, SHRINCS works then this way, like lifecycle
of a device, signing device.  I'm always imagining signing devices because
hardware wallets, they have the most credible way of storing state.  So, the
signing device generates a key, a seed, and then it can store the state, it gets
asked to sign something, then it updates the state, etc.  The user has a seed,
device breaks down, user imports seed into new device, and then the new device
knows, "Okay, I have been initialized with the seed, so I don't know the state.
So, I'm going to use the fallback", and the fallback is expensive.

Now, what SHRIMPS improves on is this fallback method, where you can say SHRIMPS
either reduces the size of the signature or it reduces the amount or the
probability that this full fallback would even be used.  So, how does this fit
together?  On the primary device, where you generated the key, you produce very
compact signatures, 350 bytes.  Now, if this device breaks down or you import it
into a different signing device, you produce 2,500-byte signatures.  And if
everything is breaking down, or whatever, you still have a fallback method where
you produce 8,000-byte signatures.

So, SHRIMPS is really this improvement.  Perhaps we have to use this worst
fallback method, 8000 bytes; much more rarely we can use 2.5 kB signatures.
This works by first assuming stateful devices, primary device and backup device,
all backup devices; second, we only create few signatures per public key; and
third, we only import a seed into a fresh signing device relatively rarely, or
at least we can bound it.  So, for the numbers I propose in the post, I would
say 1,000.  Like normal consumer wallets, probably you will never exceed 1,000
fresh devices with your seed during the lifetime of your wallet.

**Mark Erhardt**: So, how does that work?  Do you have sort of a part of the
seed that is device-based; or every time it's imported, it also reads out some
key from the signing device, and that allows it to produce different signatures
for the same public keys; or what are you doing there?

**Jonas Nick**: Okay, so the way this works is first, it's all based on SPHINCS+
and SPHINCS+ is a stateless signature scheme.  And SPHINCS+ has this property
that it sort of has this parameter that represents the maximum number of
signatures you can produce with the public key.  By default, or at least the
standardized SLH-DSA that is 264, enormous, you will not reach that.  If you
reduce it to, let's say, 210, 1,000, then the signature becomes much smaller,
2.5 kB.  So, what do we do then in SHRIMPS?  So, you could imagine that your
public key just consists of two components that are arranged in a merkle tree.
So, you have a public key with a compact SPHINCS+ instance, the one that only
allows 210 signatures, and one that is like your fallback method, 264
signatures.  And the hash of these two public keys concatenate together is your
overall public key for SHRIMPS.  And I'm excluding SHRINCS right now for the
moment.

All right, so you have these two ways now of signing the compact and the
fallback.  Now, whenever you initialize a new device, the new device will just,
for the first signature it produces, it will use the compact instance, and it
produces a signature.  If it's being asked to produce a second signature for the
same public key, it will use the fallback method.  So, the first signature is
very efficient, second signature is very inefficient.  And on the compact path,
we have a budget of 210, 1,000 signatures.  So, every device that I initialize,
that means I can have 1,000 devices that I initialize with that seed, each one
signing exactly once with that compact path, and that then the fallback.

**Mark Erhardt**: So, basically you remember as state how many devices you've
initialized?  Are you, are you basically telling the device, "Oh, you are the
second device with this key"?

**Jonas Nick**: No, you don't need to, because SPHINCS+ is a stateless signature
scheme, so you don't need to.  You only bound the number of times that you
initialize a device with the seed.  You don't need to remember or know the
state, the number of times you've initialized the device.  Each device will just
produce one signature with a compact path.  So, at most, if at most 1,000
devices are initialized, at most 1,000 signatures will be produced with the
compact path.  And that means that this entire scheme remains secure.

**Mark Erhardt**: Right, a single signature is a little adventurous.  If you,
for example, use too low of a feerate and you want to RBF, suddenly you're not
only increasing the feerate, but also increasing your signature size to an
enormous 8 kB, right?  So, would it be a way to make like three signature to a
device, or something?

**Jonas Nick**: Right, so if we say, okay, we have 1,000 devices at max that
we're going to initialize and each of the devices is allowed to do 16 signatures
with a compact path, let's say, then we use a compact SPHINCS+ instance with 24
times 210 signatures, so 214 allowed signatures.  And that, according to the
numbers that I provide in the post, still results, I think, in a signature that
is about 3 kB.  So, still much less than the SLH 8 kB.

**Mark Erhardt**: I saw that Conduition wanted to chime in, sorry.

**Conduition**: I just wanted to mention that the maximum number of signatures
on a SPHINCS key is actually a more flexible number than Jonas is making it out
to be.  It's more so a ceiling beyond which, once you go there, there be
dragons.  It's not so much an instant death, the floor is lava limit.  As soon
as you cross that, you're not instantly exposing your keypair, you're more so
making your keypair gradually less secure as you overuse it.  And actually, in
Jonas's post, I think he goes through some examples of how that signature
security degrades overuse.

**Jonas Nick**: Yeah, I think that's a good point.  So, for example, with the
parameters that I provide for 1,000 devices, if you accidentally initialize
2,000 devices or each device somehow signs twice instead of once, you still have
exactly the same security.  So, there is some budget there.  It goes down
relatively slowly, but it sort of depends very much on the parameters.  And this
is not the case with SHRINCS.  So, with the SHRINCS signatures, if you reuse the
state and mess up the state, you'd be really in trouble.

**Mike Schmidt**: Jonas, in the case of managing state, it seems like the
implication here is if my primary device is lost, that integer that you
mentioned that represents state is assumed to be lost as well, and then you go
to the fallback path, is that right?

**Jonas Nick**: Yeah.

**Mike Schmidt**: And if that is right, can't I just replicate that state in
some way on a new device; say if I knew that I am done with this signing device
and I'm intentionally stopping here, pull out the integer, move it to a new
device, and continue on?

**Jonas Nick**: So, this stateless assumption, I think, is a big change to the
philosophy that we have previously applied to Bitcoin cryptographic design,
where we try to be very careful about misuse resistance, making it very hard for
users to accidentally do anything wrong, use the cryptographic APIs incorrectly.
And with these stateful designs, we can't really do that anymore.  And that's
why when I try to explain these things, I try to explain them in a way where
they would be the most secure against user error.  What you're describing is
certainly possible and there are many variants of it.  But that always assumes
that the user does something correctly.  For example, let's say they put the
state on an SD card and they insert this SD card into the new hardware wallet,
and then they delete the SD card, or whatever.  That is fine.  But they
shouldn't make a copy of it, for example, before inserting it into the new
device and it getting deleted.  So, there are a lot of ways to perhaps improve
on this, where you make some additional assumptions on correct behavior of the
user.  But that's kind of more difficult to analyze, but certainly possible.

**Mike Schmidt**: Conduition or Murch, any additional feedback?  Murch has given
thumbs up.

**Conduition**: I could say, I really like the idea of adding a stateful option.
For the wallets that want to use it, the savings in terms of compactness are
huge compared to SPHINCS, which is stateless.  And it's an engineering hurdle.
Absolutely, it's a big problem.  But for the wallets that want to do it and that
want to take on the challenge, it could provide a very good option in the
doomsday scenario, where we do need to use stateful, or where we need to use any
hash-based signature algorithm as an everyday transaction signing tool.  Having
that option, I think, is a good thing.

**Mike Schmidt**: Jonas, how's feedback been so far?

**Jonas Nick**: Yeah, I'm surprisingly positive on these stateful signature
schemes, because I think they can be fragile and I don't like them, because I
have spent a lot of time trying to prevent user error as much as possible.  But
maybe this is an interesting point in this trade-off space.  If you say, okay,
there's a doomsday scenario, then everyone using SLH-DSA, these enormous
signatures, is a systemic risk for Bitcoin, because then the transactions per
second, everyone uses them, goes down to 0.3 transactions per second, right?
So, very, very small systemic risk to Bitcoin, I would say.  Whereas if we use a
stateful signature scheme, that sort of goes away.  We can still get like 4
transactions per second, a little bit higher than that, but now we have this
localized risk.  So, it moves the systemic risk to a more localized risk.  I
think people will probably mess this up because there is some probability and
there are enough Bitcoin users that someone will mess it up, but at least the
whole Bitcoin Network won't be messed up.

**Mark Erhardt**: I guess I have another follow-up question, and it sort of
maybe pounds the same path that I've previously explored, so stop me if it's
getting repetitive.  But I'm kind of confused by the choice of parameters.  I'd
say it would be much more interesting to be able to do a few signatures per
device versus I don't really see the point of being able to import your backup
1,000 times.  Surely, you would want to import a backup a few times, but it's
probably more on the order of 5 to 10 times, even the most crazy setups, unless
you're keeping your backup offline and importing it every time you create a
transaction.  But then, you'd have hopefully different output scripts for those
transactions and that problem wouldn't apply.  I just feel like it should be
rather the other way around, allow maybe 15 or 20 signatures per import, and
then only have 5 to 10 imports.  So, I was just wondering whether you could
expound on how you arrived at the parameters, or whether we can tickle this a
little more to come up with smaller signatures?

**Jonas Nick**: Yeah, so let's say we say, okay, the number of device
initialization we allow is 32, right, much smaller.  And then what?  As the
choosers of these parameters, like whatever, in Bitcoin consensus or in the
wallet, I guess that's up to debate how to exactly include it into the Bitcoin
protocol, let's say we fix it to 32.  But what happens if the user somehow
imports it more often, right?  So, really, this number needs to be a maximum,
because if the user imports it more often, then the security will go down
gradually.  So, we will need to find an upper bound that is a real upper bound
and that no one with very high likelihood will exceed.  And sure, you can tweak
the parameters.  But to me, when I started writing this post, it was just, 1,000
sounds large, it's not debatable, right?  Whereas if I had picked 32, then
people would say, "Oh, 32, that sounds very, very scary".

**Mike Schmidt**: What is the difference in size, I guess, would be maybe the
follow-up question, if you did 32 versus 1,000?

**Jonas Nick**: So, the difference in size is not enormous.  It would still be
probably just over 2 kB.

**Mark Erhardt**: Maybe 20% or so less, but okay.  Conduition, you wanted to say
something?

**Conduition**: I just wanted to note that the parameters of the protocol are
very flexible.  It's even debatable whether we could include flexible
parameterization in consensus, so that individual wallets would have the ability
to determine their parameter sets.  But then you get into questions of
fungibility, because different wallets would then have different fingerprints.
I think choosing an upper limit that works for most people is the better option
here, since we're using this mostly as a fallback anyway.  Ideally, nobody ever
has to use this.  Ideally, we come up with a better signature algorithm that has
the same compactness as schnorr, but that's a best-case scenario.  So, we want
to plan for the worst.

**Jonas Nick**: Yeah, the fungibility issue, I fully agree.

**Mike Schmidt**: Well, it seems like we've done this one pretty good.  Anything
that you'd leave for listeners, Jonas, other than reading your post?

**Jonas Nick**: Not right now.  I mean, on these stateless schemes in general,
I'd be interested to hear feedback from wallet developers, if they think this is
actually a worthwhile direction.  So, that would be one kind of feedback that
I'd be interested in.  And the other feedback would be, I think what has not
really been explored that much in the Bitcoin space is post-quantum hash-based
signatures, for example, and layer 2s.  Because if signatures get larger, and
they will get larger, even with SHRINCS, then there would be a higher incentive
to use L2s and more importance placed on using L2s.  So, I'd be interested in
what L2 devs think about these various post-quantum options that are on the
table.

**Mike Schmidt**: Conduition, one more comment?  I just had a response to Nick.
Jonas, you said you were interested in hearing about what wallets and their
developers think about stateful and statelessness.  I can't name names publicly,
but I can tell you that I have been speaking to some wallet developers and they
are very interested in the stateful option.  So, you should take that as a
positive, I think.

**Jonas Nick**: Okay, that's good to hear.

_Compact Isogeny PQC can replace HD wallets, key-tweaking, silent payments_

**Mike Schmidt**: Well, we'll stay on the topic of quantum, because we're going
to talk about another Changing consensus item here, "Compact isogeny,
post-quantum, and then also in the context of HD wallets, key tweaking, and
silent payments".  So, we've talked about hash-based signatures sort of losing
some of these nice features potentially, although I know there's research into
replicating some of these potentially.  But Conduition, you posted to Delving
about isogeny-based cryptography, IBC, and that I think is a something that's
new, at least on this show, in terms of our discussion on the newsletter
previously.  Why don't you give us an overview, knowing the context of folks
hearing about hash-based and maybe a touch of lattice, how does isogeny fit into
this?

**Conduition**: Absolutely.  I was researching hash-based signatures for a few
months late last year and I started looking into lattices shortly after that, as
I was curious about more compact and flexible schemes.  I always found the same
pattern with lattice-based schemes, which was if you want to add structure, you
need to compromise on compactness.  So, lattice-based public keys contain a
matrix of polynomials, and in order to generate that matrix, which is very
large, you typically include a seed in the public key, and that seed is
basically just a salt that you use to generate that full matrix.  And in order
to add structure, by which I mean adding enough mathematical flexibility to
derive child keys, to re-randomize, to aggregate signatures, that kind of stuff,
you need to include that full matrix most of the time, and that makes the public
key way larger.  And there are shortcuts around it. there have been lots of
papers published on it, but it's really not an avoidable compromise.  And you
also have to compromise on security.

So, after I realized that, I started looking into alternatives.  And the first
one that came to mind, when I looked up the different relative sizes of
signature schemes, was IBC.  So, if I'm going to draw analogs between classical
and IBC, let's just tl;dr it.  So, an isogeny is a function that maps points on
one curve to points on another curve, but preserves the structure between the
two curves.  Now, we all know what elliptic curves are more or less, but there
are a specific subclass of elliptic curves, and that specific subclass has a
bunch of nice cryptographic properties; these subclasses, called supersingular
elliptic curves.  And the properties of these curves, I'll shorten a lot of
research here, but basically they make for very nice public keys.  If you start
from a given supersingular elliptic curve, which is called the base curve, also
known as E0, you can create isogenies from E0 to other supersingular elliptic
curves.  And those isogenies become secret keys and the elliptic curves that
those isogenies map to, which is called the co-domain of the isogeny, those are
your public keys.

Now, the really cool property of this construction for me that I noticed, when
reading the SQIsign NIST document, was you can create isogenies from any
elliptic curve very easily.  And because of another mathematical result, you can
actually create a new isogeny between curves that you derive from a starting
curve.  So, let's say you start at E0 and you have an isogeny to E1.  If you
create a new isogeny from E1 to E2, well now you have a path from E0 all the way
through E1 to E2 and you can actually find a shorter path between E0 and E2.
And that effectively looks a lot like BIP32.  Think about it.  If you have a
public key, E1, and you can create a random isogeny from E1 to a new one, E2,
that looks like a new public key.  You don't need to know any secret information
to do that.  Now, if you do know the secret information, which is the isogeny,
from E0 to E1, now you can work out a new piece of equivalent secret information
for E2.  So, it kind of updates the secret relation, you might say, in
cryptographic terms, between E0 and E1 to a new relation between E0 and E2.  And
this is formally called key re-randomization, and this is the property that I
was really interested in and which I didn't see anybody else noticing its
applicability to Bitcoin.

So, that post that I made was really calling to attention that, "Hey, this is an
interesting subject that we should all be interested in, because it gives us all
the properties that we want in a post-quantum cryptosystem", well, maybe not all
of them, but certainly a good deal of them.

**Mark Erhardt**: So, this key re-randomization is PQ safe?  Is that what you're
saying?

**Conduition**: Yes.  There is no information that you reveal by generating a
new isogeny from a given curve.  Anybody can do it and it doesn't compromise
anything with the secret key, because it doesn't affect the base assumption of
isogeny cryptography.  By the way, that base assumption is called the
Supersingular Isogeny Path Problem.  It's essentially a challenge, where given
two supersingular curves, try to find an isogeny between them.  Turns out to be
very hard.  And generating new isogenies from a starting curve doesn't give you
any advantage if you're trying to connect to two fixed curves.  You can create
new isogenies but you don't know where you're going to land.

**Mark Erhardt**: So, basically you would have the order of the curves
predetermined, that would be sort of the equivalent of the index on the key
derivation, and then the owner of the private key would be able to create the
isogenies and would be able to find the re-derivations or the key
re-randomizations of those isogenies to step through the process; whereas it
sounds like the public key would enable people to find the public key on the new
curve.  So, you essentially get both an xpub sort of behavior and an xpriv sort
of behavior.  Would this also allow tweaking and signature aggregation?

**Conduition**: I'm just going to step back for a second to correct there.  The
curves themselves are actually the public keys.  The points on the curve are not
used for security purposes.  They're only used to communicate information about
isogenies and curves.  Now, the order of the curve is actually a constant fixed
by the scheme, because every supersingular elliptic curve actually has the same
number of points, interestingly.  Now, as for your other question, yes, it
allows for key tweaking.  In fact, it's almost perfectly analogous to taproot
and key tweaking done in Taproot.  The only distinction is what you use to
re-randomize a given curve.  So, the way that re-randomization would work is
very similar to the way that taproot or BIP32 works.  You essentially just take
a hash of the public key, which is an elliptic curve, along with a salt.  And
that salt can be played with to be whatever you want it to be, depending on
context.  In the case of taproot, that salt is a merkle root; in the case of
BIP32, it's a chain code and an index; in the case of silent payments, the salt
is a shared secret derived through ECDH.  But we don't have ECDH anymore in the
context of post-quantum, so it's not clear what that secret should be in the
post-quantum context.

**Mike Schmidt**: Armin?

**Armin Sabouri**: Yeah.  I saw in your post, your blog, that every isogeny also
has a dual isogeny, essentially the reverse mapping.  If this is true, isn't
this a problem, if one of your root or leaf isogenies gets leaked that you can
then derive the root isogeny?

**Conduition**: Well, first of all, any isogeny from your public key curve is
supposed to be publicly derivable only if you have the salt.  And in the case of
BIP32, for example, the salt is actually a secret key.  So, unless you already
know the parent's secret key, you can't walk back using duals, for instance.  It
is indeed a problem if the salt is a public value.  And this follows the same
semantics as BIP32's unhardened derivation works today.  If you know a secret
key and a parent xpub, you can walk back to get the parent xpriv.  And it's
functionally the same with this post-quantum isogeny-based idea.

**Armin Sabouri**: Got it.  That makes sense.  Thank you.

**Mike Schmidt**: Conduition, in your research, are there other folks doing
similar research for blockchains, for lack of a better word?  Obviously there's
some literature on these isogenies, but I'm wondering if people have gone down
this path with regards to something like Bitcoin.

**Conduition**: That's a great question.  I honestly don't see it yet.  I
certainly think I'm the first one to notice its applicability to BIP32 and
re-randomization.  I would not be surprised if some altcoin has tried to
integrate isogenies before, but if they have, I don't know about it.

**Mike Schmidt**: I don't know if you've touched on it already, but what do the
numbers look like, you know, signing, verification, sizes, these sorts of
things?

**Conduition**: Oh yes, I love talking about numbers.  So, for compactness, keys
are about 65 bytes, public keys are 65 bytes, secret keys are a bit larger.
Signatures are, for SQIsign, 148 bytes.  For PRISM, which is a competitor
alternative newer than SQIsign, signatures are slightly larger.  I think it was
around 160, 170 bytes, but those can be compressed a little more at the cost of
some speed.  For performance, signing now takes, I think, on the order of like 5
to 10 milliseconds on an average CPU, and verification takes around 1 or 2
milliseconds.

**Mike Schmidt**: It sounds impressive from those metrics.

**Mark Erhardt**: Where's the dirt?  Give us the dirt!

**Conduition**: The dirt is the verification speed, honestly.  1 millisecond is
actually not that great in the grand scheme of things.  It's about 50 times
slower than module lattice, otherwise known as Dilithium, and about the same
amount slower than schnorr.  So, it's much slower in the overall zoo of
post-quantum signatures.  That number is being worked on a lot and it's the
primary metric that most researchers seem to be optimizing for now.  Given they
already have a giant leap forward in compactness, they're now trying to get it
competitive on terms of verification speed.  Now, there's been a bunch of new
research since 2022, with the rediscovery of a theorem called Kőnig's lemma,
that has been to massively improve signing performance, but verification speed
wasn't affected that much.  So, that's, I think, now the dimension that they're
trying to meet.

**Mark Erhardt**: Yeah, I mean, signing performance is not quite as important as
verification.  Everybody has to verify; only one person has to sign.  So, it
being 50 times slower would, of course, be a bit of a problem.  Although, of
course, with the signatures also being 2.5 times bigger, there would be a few
fewer signatures per block, probably.  So, overall, that would significantly
slow down block validation of full blocks.  My understanding is that isogeny is
more new cryptography still, lots of new cryptographic assumptions.  Could you
maybe touch on how this compares to the assumptions we are currently making in
Bitcoin?

**Conduition**: Oh, yes, absolutely.  Now, the fundamental assumption of IBC, I
already defined it a little earlier.  Given two curves, find an isogeny between
them, specifically supersingular curves, because of the security properties of
how curves are connected on what's called the supersingular isogeny graph.  That
assumption is actually equivalent to another well-studied assumption, called the
endomorphism ring problem, which is given a supersingular curve, find this
mathematically-related object called an endomorphism ring.  And those two are
actually so equivalent that in SQIsign, the endomorphism ring is the secret key,
because you use it to create signatures.  The isogeny between E0 and your public
key can be used to derive the endomorphism ring and vice versa.

Now, the cool part about the assumptions of isogeny cryptography is they
actually rely on a lot of math that already has been studied.  So, elliptic
curves are in use in Bitcoin today all the time, constantly, and we use all the
same math that IBC uses, but it's just a different set of assumptions.  So, it's
still a very well-studied field, it's just a set of new hard problems that we
rely on.  These are still well-studied.  They're not as well-studied as the
ECDLP, but there's no denying that they are still new assumptions.  Now, those
aren't actually so worrying to me as other assumptions that specific schemes
have to make.  A key example here was SIDH.  SIDH relied on the Supersingular
Isogeny Path Problem, but it also relied on this assumption that the torsion
points, which are like pieces of data attached to the public key, that those
torsion points didn't leak information.  And that turned out to be very wrong,
which they proved in 2022 with the Castryck and Decru's attack on SIDH.

Now, that is the same genre of attack that I would be most worried about with
schemes like SQIsign and PRISM.  If you would allow me a moment to elaborate
here, I want to show you the distinction between these two and why their
security proofs are actually almost like invertedly related.  They're like
complementary, so that SQIsign relies on prime degree isogenies being easy to
simulate.  In the signatures for SQIsign, they include these prime degree
isogenies, which are essentially just, you know, what a degree of a polynomial
is.  Think of it the same thing for an isogeny.  It's the measurement of
complexity in the isogeny.  And in the signatures of SQIsign, you include a
prime degree isogeny, and in the security proof, you have to simulate that
somehow.  But it's not exactly obvious how to do that, and it turns out to be
such a hard problem to simulate prime degree isogenies that Andrea Basso and a
bunch of others, like de Feo and so on, came up with a new scheme based on that
assumption, that producing prime degree isogeny seems hard.  It's called PRISM.
I alluded to it earlier.

So, as a result, you now have two schemes where depending on whether this
problem is actually hard or not, one scheme or the other can be proven secure,
but not necessarily both.  So, it seems good to assume that either SQIsign or
PRISM are secure, but it seems not easy to prove both.

**Mike Schmidt**: I was just going to ask, Where are isogenies used currently?
What are the current applications of this in industry or otherwise?

**Conduition**: I haven't spoken with anyone who's using them in industry yet.
They seem still well in the realm of research, and I think that's mostly because
they haven't been standardized by NIST.

**Mark Erhardt**: Well, maybe we need to get some standardization by the Bitcoin
Institute of Standards, the BIST!  But no, I mean this sounds super-promising in
the sense of the blockspace use, the tentative compatibility with a lot of the
features that we have been using in wallets.  The speed sounds a little
concerning.  I imagine that blocks full of these signatures would significantly
slow down IBD (Initial Block Download) and, well, somehow we've been talking
about that already a lot in the last year.  So, yeah, go ahead.

**Conduition**: I have one idea for how to optimize for that.  So, it's a kind
of a blunt answer, but what about STARKs, right?  If you have a block that's
full of very difficult-to-validate signatures, one person can produce a
zero-knowledge proof that these signatures are all correct without validating
any of the other consensus rules, by the way, it's just signature validation
here that we're worried about.  You could actually do this over all blocks, and
this would significantly speed up IBD, although producing that proof would be
very onerous.

**Mark Erhardt**: Right, so that would sort of give nodes that are trying to
catch up to the blockchain a way out or a way to speed it up.  But one of the
big problems about block validation needing to be fast is, of course, that it
limits how quickly other miners can start working on the block.  So, once the
block comes in, if it's way slower to validate, that might in itself be a
problem already.

**Conduition**: Absolutely.  I think in order to assuage the risks associated
with a higher verification time, we should really be looking at ways to amortize
that cost.  And right now, there's no effective batch verification for SQIsign,
or at least nobody has looked into it as far as I'm aware.  I haven't read any
papers about it, there's nothing akin to CISA.  This is all open research that I
think would be well in need of funding and research by the Bitcoin community,
since they are primitives we often rely upon and would really desire in a
post-quantum scheme.

**Mike Schmidt**: Well, Conduition, thank you for joining us today.  I'll plug
very quickly that if you liked this discussion with Jonas Nick and Conduition
and myself, we will be joined by Taj on the open-source stage in Vegas and
talking about signature schemes.  I will be asking similarly naïve questions to
these smart people, who will give answers for us all to understand hopefully a
bit better about the different pieces of post-quantum crypto that they're
working on.  So, Conduition, thanks again for joining us.

**Conduition**: Thank you very much, Mike.  It's been a pleasure.

_Wallet fingerprinting risks for payjoin privacy_

**Mike Schmidt**: Cheers.  We're going to bounce back up to the news section.
We're going to talk about wallet fingerprinting risks for payjoin.  And we have
Armin on, who posted to Delving Bitcoin about how differences between the
different payjoin implementations can allow it to be possible that there's some
fingerprinting going on of the transactions.  And I'll let him get into the
different categories of fingerprinting.  But Armin, how would you frame your
research; why did you start looking at this; and then we can get into what you
found?

**Armin Sabouri**: Yeah, thank you.  This is something that we've been thinking
about as a team for quite a long time, specifically how differences in wallet
policy, bugs even, can be used to partition the inputs of the receiver and the
sender and their outputs as well in a payjoin.  And so, what this blog does, it
just sets up what this attack would look like and then applies it to three
transactions that I know are payjoins.  And what we attempt to do is exactly
that, partition the inputs and then recover the payment amount using some value
analysis.  But this is kind of like a teaser to a more general attack or a more
general heuristic that could be built, that takes into consideration
fingerprinting distributions.  After all, clusters are meant to be entities with
common owners, so it would only make sense that they share the same
fingerprints.  So, just kind of setting up the groundwork for some future
research.  I've used a lot of jargon and words already.  Let me take a step back
and just talk a little bit about payjoin and wallet fingerprints, and then maybe
we can go through some of the examples.

So, from a privacy preserving point of view, what payjoin attempts to do is to
add doubt into the common input heuristic.  This is a heuristic that chain
analysis uses very frequently and it's accurate as well.  Essentially, what this
heuristic says is if there is inputs, the inputs of a transaction belong to the
same person.  So, if you have a transaction, it's got five inputs, those belong
to Bob.  And we would cluster those outputs and put Bob on it.  And maybe using
some other information, we could find out who Bob is.  That's kind of its own
rabbit hole.  What payjoin does is it has the sender and the recipient interact,
so they can both collaborate and make the transaction together.  Concretely, the
sender sends the fully signed transaction to the recipient.  The recipient
contributes their own inputs and maybe outputs the transaction and sends it
back, sender signs it, broadcasts it.  Now you have a transaction with multiple
inputs that belong to different wallets.  And now, an analyst would apply a
common input heuristic and get false results, false positives.  But note that
this only works if the transaction is indistinguishable from a unilateral single
wallet transaction.

So, the analyst's job is then to find artifacts of collaboration, is there any
behavior that is inconsistent with a single wallet producing this transaction?
And there's been other work that's done similar things.  Simin Ghesmati has a
paper that looks at unnecessary inputs, is there any oddities in coin selection
that a single wallet just wouldn't do?  Is there like weird inputs added there
that are inexplicable?  And fingerprints kind of are another tool for a similar
job.

So, what are wallet fingerprints?  So, wallets construct transactions.  And when
they do that, they're making tons of small decisions about what this transaction
should look like, how the inputs are sorted, what coins to select, fee
estimation, signature encoding.  And the whole idea is that these manifest
onchain in the transaction themselves, and they can be used to identify the
wallet that actually created it.  So, I linked some previous work by Ishaana
Misra that did this comprehensive study.  She looked at a dozen wallets, a bunch
of fingerprints.  She found which wallets produced what fingerprints and then
attempted to attribute onchain transactions to the wallets that created them.

Now, we use wallet fingerprints a little bit differently in this kind of work.
For us, it's not important what wallet actually produced the transaction, but
just the fact that there are seemingly two different wallets collaborating.  So,
to recap, what we do is we detect artifacts of collaboration via wallet
fingerprints.  We partition the inputs and outputs by sender and recipient, and
then you could apply your normal heuristic to those sub-transactions.  Last
thing I'll add here is that there is kind of two ways to apply wallet
fingerprinting.  There is what I call intra-transaction fingerprints, which are
fingerprints that are available just in a single transaction.  So, think about a
transaction with some inputs that have nSequence sent to one number and then
other inputs are nSequence sent to another number.  A normal wallet wouldn't
really do this.  This is consensus-valid, but why would it do that?  So, with
high probability, we can say, "Hey, there's something going on here.  Maybe two
wallets are working together".  Whereas inter-wallet fingerprinting is looking
at the adjacent transactions.  So, do the outputs of this transaction get spent
into a transaction that looks really different from how the other outputs get
spent?  Is there a fingerprinting there?  And same thing for the inputs.  How do
the previous transactions look like?

So, with those two things in mind, you can kind of apply this framework to
payjoins and try to partition the inputs and recover the payment amount on top
of some value analysis.  And that's what I've done in these examples.  I'll stop
there and see if there's anything you guys want me to elaborate on.

**Mark Erhardt**: Very good overview.  So, actually, when I read our description
of your work, I was curious what sort of fingerprints you saw in the input
encoding.  Are you talking about the sighash flags and signature grinding, or is
there something else that might appear there?

**Armin Sabouri**: That's a good question.  So, yeah, in the two examples that I
have that look for --actually, I think all three of them have inconsistencies in
their inputs.  So, the first example is probably the weakest wallet
fingerprinting signal.  What you have is two inputs.  One of them is grinded
with a low-r, the other one is a high-r input.  And the only thing you can
really say about this transaction is that this wallet doesn't do low-r grinding.
What you would need to do is look at the adjacent transactions to say, "Does one
of these inputs come from a cluster with exclusively low-r values and now it's
getting spent in this high-r mix?  Okay, that is a signal that this wallet's now
behaving different.  Why?  Maybe there's another wallet in the mix".

The second example is a much more clear signal.  There is two P2TR keyspends.
One of them has an explicit SIGHASH_ALL byte, the other one omits it.  And under
taproot's consensus rules, you can omit it and by default it's SIGHASH_ALL.
There's really no reason a wallet should include that byte.  It's more of a bug
than a policy.  I think there was a Stack Overflow exchange question.  I was
like, "Who is producing these?"  I think it's just people who don't know about
that consensus rule.

**Mark Erhardt**: Yeah, I mean previously, SIGHASH_ALL had to be stated
explicitly.  It's only in P2TR that it is now implicit by default and you don't
have to state it.  So, people that didn't look too carefully at the spec might
have missed that they no longer have to state it explicitly.  So, yes, this is a
bug in the sense that you're paying for a weight unit that you don't have to
produce, and it's a fingerprint.  So, really nobody should be ever explicitly
stating SIGHASH_ALL.  We should have probably not allowed stating SIGHASH_ALL
because it's the implicit behavior that would have been maybe better.  I don't
know why.  Maybe some hardware wallets or signing devices by firmware didn't
have the option not to produce a sighash, and that was a backward-compatibility
thing.  But generally, it just seems like if you don't have to state it, we
should have not allowed stating it.  But again, I'm probably missing some
background here.

**Armin Sabouri**: I would love to know this piece of Bitcoin lore.  If anyone
knows, comment wherever, just tag me, I want to know what's up.  But in general,
optionality leads to reduced anonymity sets is something we just talked about
with this post-quantum conversation.  So, let's just reduce optionality where we
can.

**Mark Erhardt**: Funnily enough, it's exactly the same with the low-r grinding.
Everybody should be doing low-r grinding, because it's like literally a second
signature, on average, will give you the low-r signature if the first one
doesn't.  And again, it also saves a byte in the witness stack.  So, just paying
for data you don't have to pay for.

**Armin Sabouri**: I mean, this is an interesting point.  When it comes to
fixing wallet fingerprinting, there's kind of two schools of thought.  It's
like, let's spec everything.  Let's spec how we sort inputs, BIP69, low-r
grinding.  But the other school of thought that critiques this is, well, wallets
are never realistically all going to behave the same, so why don't we just
randomize everything?  Okay, do low-r grinding once in a while, but then just
throw a mix in there.  Set nLockTime to anti-fee sniping.  Maybe don't do it
there.  I don't have a great answer to this.  But the only thing I'll say is
that it does feel like there's a lack of data in this conversation.  I feel like
wallet developers generally don't have the data to back up their decisions.  I
see a lot of GitHub threads where people say, "This will fingerprint us".  But
you need to understand what your approximate transactions look like.
Fingerprinting is a dynamic problem.

**Mark Erhardt**: Yeah, actually, I think that for some of the discussed
fingerprints, there's an obvious better way and everybody should do it.  And for
other fingerprints, going random is the way to go.  For example, the order of
inputs is very hard to -- like, by spec'ing the order of inputs, you're actually
producing a fingerprint, which is hard to hide.  And for some applications, you
simply cannot fix the order.  So, I think in many cases, that is pretty obvious.
Maybe we do need to write up a little more about how not to fingerprint wallets.
I guess that could be an interesting project.

**Armin Sabouri**: I forget where I left off.  I think I was talking about the
examples.  Quickly on the last example, so this last one is actually a
production payjoin between Cake Wallet and Bull Bitcoin, where Cake Wallet is
the sender and Bull Bitcoin is the recipient.  The first thing that sticks out
in this transaction when you're looking at it is this nSequence = 0x01, and
that's consensus valid.  You can do a BIP68 locktime of one block, no reason not
to.  But I know this is a payjoin and the thing that was confusing to me is why
is Bull Bitcoin matching the nSequence value?  This seems odd that both of them
would have this relative timelock of one block.  It turns out in PDK, we
actually match the counterparty's nSequence.  If they send something to me, I'll
just match it and then we avoid the intra-transaction fingerprinting problem.
But if you go to this ASCII diagram I have on the blog, you'll see that this
doesn't help you at all.  If you just look at the previous spends, one of the
inputs was spent in a transaction that uses the opt-in RBF nSequence value,
0xfffffffd, the other one sticks to 0x01, and that's pretty clear indication
that one input belongs to one wallet, the other one belongs to another, and the
same thing for the subsequent transaction.

**Mark Erhardt**: And in this case, I think that might also actually tell you
who initiated, right?  Because if you match the initial value, you know which
one was the initiator, right?  And that tells you who the sender and receiver
are.

**Armin Sabouri**: Yes.

**Mark Erhardt**: So, this is actually even worse.

**Armin Sabouri**: Yes, this is correct.  Yes, correct.  It turns out the
nSequence = 0x01 value was kind of a bug.  It wasn't meant to be there.  I think
they were just trying to opt into RBF.

**Mark Erhardt**: Also, we don't have to do that anymore.  Since Bitcoin Core
v28, we accept replacements for transactions where the original did not opt into
RBF.  So, all of the signaling nSequence flag stuff could be more homogenous at
this point.

**Armin Sabouri**: Yes, however, one thing to keep in mind is that the very act
of RBFing is a fingerprint, if you're observing the mempool.  So, not all
wallets actually implement RBFing, let alone opt-in.  So, if you're observing
the mempool, you can still do this kind of intersection.

**Mark Erhardt**: Although that increases the data you have to collect a lot.
You can't get that from the blockchain, right?

**Armin Sabouri**: Correct, but you just have to observe.  So, it depends on
what your risk level is.  Yeah, go for it, Conduition?

**Conduition**: I just wanted to ask, to what extent are these problems
solvable, like in a high level view?

**Armin Sabouri**: Yeah, that is a good question.  So, there are some bugs, like
the nSequence bug, that are trivial to fix, right?  So, I mean the whole
takeaway from this blog is that you can't just add payjoin or other privacy,
like interactive privacy protocols on top of your wallet, and just expect the
magic box to give you privacy.  You kind of need to be aware of your
counterparty's fingerprint, and not only for the single transaction, but for the
whole subgraph.  I don't have a great answer to your question, like, can we
solve this?  It kind of goes back to what Murch and I were talking about.  It's
like, do we just spec this problem out of existence, or can we just randomize
everything?  I think we just need to collect more data and just understand how
bad the problem is today, like what do the fingerprinting clusters look like?
Are we all homogenous?  Is there a cluster that really sticks out?  Until we
have just more data, it's hard to say.

**Mark Erhardt**: Yeah, I think there's an awareness issue here.  I think that a
lot of wallet developers probably haven't really looked at it all yet.  So, if
there were a best practice, maybe a BIP or something that describes, "Hey, here
are recommended fingerprint behaviors", and people over time would migrate to
these.  A lot of them might just disappear over time.  Of course, the problem is
that we have no control over how long people continue to use old versions of
software.  Or if there's maybe businesses that have their own implementations of
things and just don't care, they might end up sticking out more because they do
not migrate to the homogenous defaults, the recommendations.  Beyond that, a lot
of them could be fairly easily mitigated just by, for example, not setting the
RBF flag anymore is the default behavior for people that never supported RBF.
And now, the wallets that did update and that continue to update might just stop
signaling RBF.  Signature grinding makes sense, also is irrelevant with P2TR,
because the signature sizes in P2TR are already fixed, and so forth.

So, I think we're moving slowly towards some of the fingerprints going away, but
there is an awareness and a momentum issue, where some people just cannot be
arsed to ever stop using the first wallet they downloaded in 2012 and stick out
like a sore thumb.

**Mike Schmidt**: Armin, anything else for listeners, and also next steps after
this research, if any?

**Armin Sabouri**: Yeah, so this blog was really meant to set the stage for a
larger-scale attack and survey of the chain.  So, what I'm really interested in
is how bad the problem is.  Like I mentioned before, what does the chain look
like in terms of wallet fingerprints?  And then, second, if you take the three
examples and the kind of attacks I've done on them, there's a more general
version of them, which is a different version of multi-input heuristic, one that
doesn't just blindly partition the inputs together, but looks at the clusters of
the inputs and their fingerprinting distributions and considers that first.
Because right now in the literature, we just look at transactions that look like
they're interactive and just ignore them.  So, if you see a coinjoin, which are
easily fingerprintable, you just ignore it and go cluster something else.  But
my argument here is that chain analysis is and can do better.  We can look at
fingerprints, we can look at other behavior onchain and use that to do smarter
partitioning.

Last thing I'll say is that fingerprints are not really a problem just for
collaborative privacy protocols.  They affect everyone's wallets.  So, for
example, if you have a wallet that produces very distinct transactions, I can
infer other things about your wallet and do smarter heuristics.  Like, maybe I
know your wallet and I know where it places the change.  Now I can do a much
smarter change classification heuristic.  There are so many rabbit holes to go
down with wallet fingerprinting, and they're all fun and interesting.  So, if
you want to work on this, I'm looking for more people to work on this with me.
So, just reach out.  And yeah, let's solve this problem.

**Mark Erhardt**: Yeah, I was wondering whether you had some input from previous
researchers that seem to be located in a similar area of the world.

**Armin Sabouri**: Yeah, so the tools that I used to do this research were
previously a Python version.  So, Ishaana built this and I already talked about
her report.  There's a link on it in my blog.  So, we didn't work closely
together, but I certainly used a lot of her existing tools to do this kind of
work.

**Mark Erhardt**: All right, yeah.  Thank you very much, Armin, this is fun.
Also, something that I personally find interesting.  So, maybe we'll chat
offline sometime.

**Armin Sabouri**: Cool, thank you very much.

**Mike Schmidt**: We appreciate your time, Armin.  Cheers.

**Armin Sabouri**: Thanks.

_Draft BIP for a wallet backup metadata format_

**Mike Schmidt**: And our last News item from this week, "Draft BIP for a wallet
backup metadata format".  Pyth, you posted to the Bitcoin-Dev mailing list about
a new proposal.  It is in the BIPs repository as #2130.  The idea here is
coordinating on some sort of a common structure for a wallet backup metadata
format.  Do you want to walk us through maybe your experiences in this space
that led to you wanting to standardize this?

**Pyth**: Yeah, so this started last year when we decided to implement a backup
or export format for Liana.  And so, at that time, I started looking to other
wallets and how they were doing.  So, I was looking at Core and there is not
really an export format, you can just copy the database.  And Sparrow does the
same, you can export the database.  And I looked to a few others.  Yeah, there
is no common interoperable way to pass your metadata from one wallet to another,
except just passing the descriptor.  But it's not enough in many cases.  So, I
do a post on Twitter and I think if you want a developer, and I just share my
draft of a spec before implementing in Liana.  And I just recently proposed a
BIP about this to try to get more feedback and to define also what we have done,
because we implemented last year and we're not yet open.

**Mark Erhardt**: Yeah, this seems to be a popular topic this year, or in the
past few months.  We've had a BIP proposed for the labels on transactions to
export those and import those for wallets; there's been two backup format
proposals; and there's been a way of adding metadata to descriptors recently
proposed.  So, this seems to be definitely coming at the right time.  There are
a bunch of people thinking about this.  I was wondering, how much are you
working with these other proposals?  Have you looked and read them?

**Pyth**: So, in fact, this BIP was on my to-do list since I implemented in
Liana.  And a few months ago, Salvatore posted on Delving an encryption scheme
for ENCRYPT.  At first, a descriptor, but everything in a way that want to be
easy to interact with signing device.  And because it was something we was
talking internally at Wizardsardine for many years, because we want a way for
backups of descriptor, but encrypted, because we want to send it by mail or
store it online but we want to encrypt it.  And so, after Salvatore draft this
specification, I started working on and implementation of this, and we get some
back and forth.  And after, I open a BIP for that.  And so, in this BIP, I first
author three types of payload we can encrypt.  The first one is just a bare
descriptor; the second one was just BIP329 labels; and the third one was this
specification.  And Sjors sheened the PR and told me, "Why you don't
just put any BIP number so we can encrypt anything that is defined by another
BIP number in the future?"  And so, I have this BIP draft open for many months
and I wait to undraft it, to have also this second BIP draft, so I can
cross-reference it.  So, that's it.

**Mike Schmidt**: Murch, I see you've commented, you were the first commenter on
this draft BIP.  Did you have anything you think would be applicable for the
audience on this?

**Mark Erhardt**: I must admit, I was on vacation last week and I did see it
come in, but I haven't fully read it yet.  So, I refrain from commenting too
heavily right now.  I just noticed that there are a bunch of different projects
going on right now that seem all topically related.  Yeah, so I think that
probably the other authors that are currently working on similar schemes will be
the best reviewers of this, but I'm looking forward to reading it fully and then
maybe making some suggestions myself.

**Mike Schmidt**: How has feedback been, Pyth?

**Pyth**: So, the first time I talked about it on Twitter last year, I got a few
feedback from two or three wallets that I integrated in, because I just
published a repo on GitHub and some open PR, some open issue, and we started
talking on it.  And I got a few reviews last week, and I think, yeah, people
started coming in.

**Mike Schmidt**: Yeah, Murch mentioned the flurry of similar, I guess,
activity.  I think we had Craig Raw on to talk about descriptor annotations, I
think it was a few weeks ago.  And so, yeah, I hope you all can keep your
communication lines open with each other and come up with something that is
useful for everyone.

**Pyth**: The proposal of Craig, I think it's for a different use case, because
it's only attaching few metadata to the descriptor and it's a backup you do only
once when you create your wallet or your descriptor.  While the format I offer,
it's more recurrent backup you will do for backup the state of your wallet,
because it will include your label, your coin.  And if you have a silent payment
wallet, you will have all the information around your coin that you need to
backup every time you got new coin or you spend coin.

**Mark Erhardt**: So, I mean, generally the idea to have a standard for how to
backup all the information, all the wallet state, it would be very useful there.
There are a ton of different wallets.  And if this proposal gets adopted
broadly, it would of course allow these different wallets to import their
backups which, for example, could be very useful when wallets stop being
supported or people want to import a backup five or ten years later.  If it
already used the standard, the standard would probably continue to be supported,
and they could just import their backup into a different device or different
software.  So, the underlying idea of having a standard for how wallets are
backed up is very useful.  I'm just curious, I haven't looked at it too deeply
yet, but with so many proposals that are sort of adjacent or overlapping, I hope
that we can find something that we don't have 13 standards in the end!

**Mike Schmidt**: Thanks for joining us and thanks for your work on this and
thanks for hanging on to get to this point in the show.  We appreciate your
time.

**Pyth**: Thanks for having me.

_Varops budget and tapscript leaf 0xc2 (aka Script Restoration) are BIPs 440 and 441_

**Mike Schmidt**: Cheers.  Okay, jumping back to the Changing consensus segment,
we had one more item that we didn't cover, that we don't have a guest for, at
least this week, titled, "Varops budget and tapscript leaf (aka 'Script
Restoration') are BIPs 440 and 441".  Since this was mostly talking about BIP
assignments and some references to previous newsletter posts, we didn't think it
was worth trying to rope in Rusty just yet to talk about it.  But we do have
Murch who I think has some news on each of these or some color commentary.

**Mark Erhardt**: Yeah, I spent some time reading these.  And basically, the
main idea is that it reintroduces most of the disabled opcodes.  I think it was
2010 or so when Satoshi decided that some of the opcodes were too risky.  One of
them was actually broken and there was a way for people to spend other people's
coins.  So, Satoshi just swept a bunch of opcodes away that either had DOS
potential or security vulnerability potential, and they were disabled.  And ever
since then, some protocol developers, or people that were more excited about
complex output scripts, had been griping that they would love to have back all
of these opcodes in order to build more complex smart contracts.  And smart
contract is not a dirty word.  It's simply a Pythian expression for saying that
there are conditions that can be evaluated to ensure that spending conditions
are met and outputs can be spent in more complex manners.  So, very
specifically, these proposals introduce a new cost scheme, the varops budget,
where they assign a cost for each of the opcodes based on how much data they
process.  This is a new limit that is backwards-compatible with the sigops
limit, and essentially ensures that there is no overt complexity in the
validation of these new scripts.  And then, of course, it also activates the
mentioned opcodes again.

There's a few arithmetic opcodes there and there are some bitwise operations,
and OP_CAT is in there, which has been discussed a lot last year or two years
ago.  Yeah, I don't have the list right in front of me.  There is, however, also
news.  This PR was merged this morning, so BIP440 and BIP441 were published this
morning.  They are now published in draft status to the BIPs repository.

**Mike Schmidt**: So, Murch, if I have it right, 440 is the budgeting mechanism,
the varops that we've talked about on previous shows, is that right?  And then,
441 is the actual, okay, these opcodes are now valid?

**Mark Erhardt**: Well, proposal to deploy it.  So, this is of course a soft
fork.  It would use a bunch of the OP_SUCCESS opcodes.  Maybe that isn't clear,
but the number of opcodes is of course limited to the bytes that were set aside
from when Bitcoin was defined.  And the same opcodes that were used originally
for these operations are still available, and they're now OP_SUCCESS in taproot.
So, the idea here is to introduce a second version of tapscript.  And so, these
opcodes would only be available in script leaves in P2TR outputs that use a new
version of tapscript in the leaf script.  So, it would be injected into P2TR, so
to speak.  I assume that it would also be compatible with P2MR
(pay-to-merkle-root) if BIP360 gets deployed.  So, now, of course, the bigger or
the surrounding conversation has to be, do we want all these opcodes?  Is the
varops budget proposal reasonable and satisfies all of our concerns around DoS
and computation and validation?  And then, you know, it can take a little while
to activate a soft fork.

**Mike Schmidt**: And we'll leave those questions, I guess, for listeners in the
Bitcoin community to evaluate.  I guess we'll talk a little bit more about this
as well next week, since that'll be in the Notable code section.

**Mark Erhardt**: Yeah, maybe one more mention.  Originally Rusty proposed four
documents.  So, there's only two of those written and published so far.  I am
not intimately familiar what the content of the other two would be, but there
might be more documents coming that would be part of a deployment that gets
proposed.  I think one of them was named OP_TX, which is, from what I recall, a
similar idea as OP_TXHASH or OP_CTV (CHECKTEMPLATEVERIFY), but slightly
different flavor.  And I don't remember what the fourth was.

**Mike Schmidt**: The fourth was OP_MULTI and OP_SEGMENT.

**Mark Erhardt**: Okay.  I cannot speak on either of those!  Anyway, I don't
know how far along this is towards a deployment or anything, but the first two
documents that had been proposed in the context of the Great Script Restoration
are now published.  And I think they, after a first hiccup, I read the BIP441
first and was like, "This is very confusing".  And then I read 440 and I was
like, "Oh, I should have read 440 first"!  So, I recommend reading them in the
order they're numbered.  But other than that, I now consider them very readable.
And now, it's just about what we want to do as a Bitcoin community, which soft
forks we should activate, you know, the usual.

I was recently reminded and had totally forgotten about that.  We actually have
multiple, not just one, but multiple soft fork proposals in flight right now
that we are supposedly signaling for.  I think we reported on that in Optech.
But I had totally forgotten about some of them, because there's literally no
public discussion of them.  So, I assume that none of these three activation
attempts currently will be successful, simply because there's not even a public
footprint of the discussions about them.  Well, one of them has a public
footprint, but I don't think it has broad support.  Anyway, it sounds like there
might be more soft fork proposals coming.  There's also, of course, a lot of
discussion about BIP54 recently and the consensus cleanup.  So, yeah, maybe this
is a new era of software proposals.

**Mike Schmidt**: If listeners are curious, those BIPs that Murch mentioned that
are part of Script Restoration, we talked about those in Newsletter and Podcast
#374, where we dug into Rusty Russell's proposed summary of four BIPs in various
stages of draft at the time.  Two of those are now assigned, which is what we
just talked about, and then the other two that Murch referenced are also in
there.  We talked about that in that show.  I think we can move on out of the
Changing consensus segment, out of the News segment, and onto Releases and
release candidates and Notable code and documentation changes with Gustavo.

_Bitcoin Core 31.0rc2_

**Gustavo Flores Echaiz**: Thank you, Mike, Murch and everyone.  That was a
great, interesting conversation.  Now we get to the Release section.  So, this
week we have two RCs, the first one from Bitcoin Core v31.  So, this is the
second RC of the series.  You can find a testing guide that will allow you to
test the different components.  But the core of the v31 is the release of
cluster mempool.  So, there's multiple ways you can test cluster mempool, either
through the new RPCs or different scenarios related to high-fee parents with
low-fee childs, or similar things like that.  Also, the private broadcast, which
was also introduced and will be part of the Bitcoin Core v31, is also part of
the testing guide and the embedded ASMap.  So, an autonomous system numbers map
is now embedded in Bitcoin Core, so that is also part of the test guide.  So,
you can find further information on that link directly on the newsletter.

**Mike Schmidt**: And we also had Sebastian, who authored the testing guide, we
had him on in #397 Recap, and he walked us through that.  So, if you're curious
about the testing guide, maybe some things have changed in this latest RC, but I
assume most of it's the same, so check out that podcast as well.

_Core Lightning 26.04rc2_

**Gustavo Flores Echaiz**: Thank you, Mike.  Yes, that's right.  #397 was when
we introduced the first RC.  And for the second release, Core Lightning 26.04,
this is also its second RC.  And its first release candidate was in #398.  So,
this one is mostly about splicing updates, now that splicing has been merged in
the BOLTs repository.  Core Lightning (CLN) improved their implementation, but
also added new commands related to splice-in and splice-out.  So, that is the
core of this release, with other bug fixes and additional improvements.

_BTCPay Server 2.3.7_

Finally, the third release is BTCPay Server v2.3.7.  So, this is a minor
release.  The main issue at hand here is the migration to .NET 10.  So, we've
also linked to a guide that the plugin developers should take a look at on how
to migrate from .NET 8 to .NET 10, since .NET 8 is reaching end of support later
this year in November 2026.  So, worth looking at those that upgrade to that new
version of BTCPay Server.  It has some additional features and bug fixes as
well, but this is the first release that uses .NET 10.  So, important to look at
that.

**Mark Erhardt**: Just curious, wouldn't migrating to a new programming language
version be more than a minor release?  It strikes me as potentially
compatibility-breaking, but anyway, it just jumped out at me that migrating to
.NET 10 feels like a potential major version or minor version.  Anyway, yeah.

**Gustavo Flores Echaiz**: Right, that's a good question.  But yeah, this is
actually a minor release.

**Mark Erhardt**: Sorry, actually 2.3.7 would be a patch release, right, .7?
And it's usually major, minor, patch.  So, anyway, sorry, please continue!

**Gustavo Flores Echaiz**: No worries, thank you for that comment.  Yes, so
those are the three releases of this week.  There's a possibility to expect
other RCs for Bitcoin Core and CLN, but for now the testing guides are there.
And BTCPay Server, well, this is just a new version for this migration, but with
other additional features.  For those that are more interested, you can take a
look at the release notes in BTCPay Server to find out all the information
related to it.  Any comments before we move on to the next section?  No,
perfect.

_Bitcoin Core #32297_

Okay, so this week, we have about seven new PRs that we present.  So, the first
two are from Bitcoin Core.  The first one, #32297.  This is a new option that is
being added to the bitcoin-cli command, called -ipcconnect.  So, when you use
bitcoin-cli with the -ipcconnect command, you're basically instructing it to
connect and control a Bitcoin node instance via inter-process communication
(IPC).  So, this is something that we've covered in multiple newsletters.  You
can find the link to Newsletter #320 or #369, where we talk about how Bitcoin
Core multiprocess separation project has basically built a separate binary for
different parts of Bitcoin Core, right?  So, you can have the Bitcoin node
binary be separate from, let's say, bitcoin-cli control a bitcoin-node instance
that are both separate.  And this is done through what's called IPC over a Unix
socket instead of the HTTP protocol, when the binary of Bitcoin Core has to be
built with ENABLE_IPC and started with -ipcbind, so that it can be controlled
through a separate bitcoin-cli instance, can control it through the IPC
connection.

So, this PR not only adds this option, but also makes it the default behavior.
So, even if you omit this option, your bitcoin-cli program will still try to
connect through IPC and try to find a bitcoin-node instance that has been built,
a binary that has been built with ENABLE_IPC, and it will fall back to HTTP if
it's unavailable, right?  So, you don't even need to specify this option.  It
will look for a bitcoin-node instance that can be connected through IPC.  So,
just to close on that, that this is part of the multiprocess separation project.
This has been a multi-year project that is doing some progress, but still a lot
of work remains to be done.

_Bitcoin Core #34379_

So, the next one is a fix in Bitcoin Core #34379.  This is a fix that applies to
the gethdkeys RPC, which is an RPC which returns each xpub used by the wallet,
and also each xpriv used by the wallet.  So, here, the bug is the same bug that
we covered in Newsletter #389 for the listdescriptors RPC.  So, basically what
happens is if in your wallet, not all of the keys have a private key, and you
try to obtain all the private keys with that command, it would fail because it
would find that some pubkeys didn't have the matching private key for them.  So,
similar to the other fix that we presented in #389, now this command will return
all the available private keys, even if some of the pubkeys don't have a private
key.  So, it won't fail if there's a missing private key, it will just return
what it has and let you know that it doesn't have some other ones, right?  But
however, if you call gethdkeys with the option private=true on a wallet that is
strictly watch-only, well then it has to fail, right?  So, that behavior is
preserved because if it doesn't have any private key, it has to fail.  But if it
has some and has some missing, then that is fixed and is now properly returned.

_Eclair #3269_

So, those are the two additions to Bitcoin Core and now we move forward with the
LN implementations.  So, on Eclair #3269, there's a new addition of something
called automatic liquidity reclamation from idle channels.  So, what happens if
you had channels that were absolutely never used, which you could then manually
claim back the liquidity?  But what if you could have a system that could allow
you to automatically claim back liquidity from channels that are not used at
all.  So, now what occurs is that this component from Eclair, called the
PeerScorer, when it detects that it has fallen below 5% of its capacity, it will
reduce relay fees down to the minimum gradually, right?  So, through multiple
iterations, it will reduce fees and try to see if that would change behavior, if
that channel gets used more by peers.  But if it doesn't, if the fees reach a
minimum and stay there for at least five days and the volume doesn't pick up,
then Eclair will proceed to close that channel, only if it has a redundant
channel with that peer.  So, it won't close the channel if it's the only channel
with the peer, but if it's the second channel with that peer and it's the least
one used.  And also, it will always prioritize keeping public channels and
closing private channels if it has that choice.

So, after those five days, that's when Eclair proceeds to close that channel if
it's a redundant channel.  And it will only also close it if it has at least 25%
of the funds held in the local balance.  So, if it's mostly a channel that you
control, that the balance is mostly on your side, or at least over 25%, then you
will close it.  If it's a channel where your balance isn't consumed, so it's not
so much of a risk for you to have that idly, then it will be kept.  So, that's
the Eclair update of the week.

_LDK #4486_

Finally, we have two for LDK and two for LND.  So, in LDK, there's an update to
something we have presented in Newsletter #397.  So, in #397, we had announced
that there was new support for RBFing, so fee bumping, splice funding
transaction.  Now, there's a rework in the mechanics of how that works.  So,
instead of calling the rbf-channel endpoint, that endpoint is now merged into
the splice-channel endpoint as a single entry, so that new splices and fee
bumping are all done through the same command.  It was a bit unnecessary and
redundant to have a separate command, because now when you call splice-channel
and, let's say, when you want to RBF a channel, when you want to feed bump it,
you simply have to call the splice-channel command and you will receive a
FundingTemplate with the prior contribution, which means the transaction will be
shown to you so that it's clear that this was a splice that was already in
flight; compared to the situation where you're trying to create a channel that
doesn't yet exist, you will simply be presented with a FundingTemplate that
doesn't have the prior contribution transaction and the details around the
splice that was already in flight.

So, this is just a unification of endpoints to simplify and to facilitate user
behavior.  But there's no difference in how it works behind the endpoint.  So,
you can look at Newsletter #397 if you want additional details on how RBFing a
splice works in LDK.  Any thoughts here?  Nope?  All right.

_LDK #4428_

So, the next one and the final one for LDK, LDK #4428, is the addition of
support for opening and accepting channels that have zero channel reserve.  So,
this has been an open issue on the LDK repository for a couple of years already.
And there was a few doubts about how to do this in a safe way.  So, we can see
that in October 25, 2022, more than about four years ago, someone had requested
this and it was started to be unsafe.  But now, this implements it in a safe way
with a new command as well, a new method, called
create_channel_to_trusted_peer_0reserve.  So, this is mostly implemented for LSP
experiences, where you are a user that is behind or being facilitated by an LSP,
and you as a user want to use your full onchain balance in that channel.
Because there's already a sort of trust mechanic or component to the LSP user
relationship, the LSP takes the risk of the user having no channel reserve.  So,
the user has technically more incentive to cheat, less of a penalty if he
cheats, because there's no reserve to put at risk.  But because this is an LSP
user scenario, or at least this is thought of to be used in those scenarios,
then it's a trust trade-off that the LSP can handle properly.

So, this is enabled for both channels with anchor outputs, and also zero-fee
commitment channels, which were added in LDK in a previous PR presented in
Newsletter #371.  So, that's the second from the LDK series.

_LND #9982, #10650, and #10693_

And now we get to LND, which the next item combines three different PRs from
LND, #9982, #10650, and #10693.  So, these three PRs, what they do is they
harden or they improve the MuSig2 nonce handling on the wire for taproot
channels.  So, what does that mean?  It means that when you use a simple taproot
channel or simply when you use a MuSig2 transaction, it works very differently
from ECDSA in the sense that nonces have to be generated for each transaction,
these nonces have to be exchanged, and then the partial signatures can be done,
and then there can be an aggregation of the partial signatures.  And every time
you make a transaction, you must generate, and each peer has to generate a new
nonce.  If you were to use the same nonce, which is something you should never
do, but if you were to do that, then your private key could be sort of
extracted.  So, it's very important for new nonces to be generated every time.

So, these three PRs basically build all the proper handling, or at least harden
it, for different use cases related to not only funding transactions, but also
splicing.  And you can see in the next item, we're going to be talking about
RBF.  So, this is about building the internal mechanics of how to build simple
taproot channels that properly generate new nonces for MuSig2 partial signatures
every time.

_LND #10063_

And then, the next PR, the LND #10063, and the last one from this newsletter, is
the extension of the RBF fee bumping cooperative close flow.  So, when you're
closing a simple taproot channel in a cooperative fashion and you want to RBF
that close transaction, this PR now enables you to do it properly.  And it is
partially helped by the work that I had just described previously in the
previous item, about MuSig nonce handling.  So, now, the wire messages required
for the RBF transaction of cooperatively closed simple taproot channel, the wire
messages now carry specific nonce and partial signature fields related to this
type of channel.  And also, the closing state machine also uses what some call
the just-in-time nonce pattern for MuSig2, because as I described, you need to
produce new nonces every time.  That is also properly implemented, so you can
now RBF a cooperative closed transaction for a simple taproot channel with this
PR.  And in Newsletter #347, we had covered the introduction of this close flow
that was added into LND, but that was for other types of channels.  And now,
this is brought into simple taproot channels.

I also want to point to Newsletter #393 on the last item, BOLTs #1289.  We had
announced and we had covered an update to the BOLTs repository of how commitment
signatures were retransmitted when nodes would reconnect during a splice or a
dual-funding transaction.  So, BOLTs #1289 updated that commitment signatures
when two nodes would reconnect, when two peers would reconnect.  Previously,
these commitment signatures would be retransmitted automatically.  Now, they're
no longer retransmitted automatically because simple taproot channels indicate
that a new nonce has to be generated every time, right?  So, you cannot simply
just retransmit signatures, you have to make sure that the peer didn't receive
it to retransmit it.  So, if you want to learn more about just how nonce
generation works for MuSig2 rounds, you can also take a look at that BOLTs
update in Newsletter #393.  So, it's a BIP related to these last two items we
covered in LND.  We're kind of seeing the implementation versus the spec that
had been covered in #393.  This is now the full implementation in LND of
handling all of that.  And that's the last item and that completes the
newsletter.  Yes, Mike?

**Mike Schmidt**: Awesome.  I was just going to say, good job, Gustavo.  We want
to thank our guests for today, Armin, Pyth, Conduition, and Jonas for joining us
earlier.  Good job on the Notable and Releases, Gustavo, and thanks for
co-hosting Murch.  And we'll hear you all next week.  Cheers.

**Mark Erhardt**: Cheers.

**Gustavo Flores Echaiz**: Thank you.

{% include references.md %}
