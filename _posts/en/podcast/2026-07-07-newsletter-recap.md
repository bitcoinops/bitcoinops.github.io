---
title: 'Bitcoin Optech Newsletter #412 Recap Podcast'
permalink: /en/podcast/2026/07/07/
reference: /en/newsletters/2026/07/03/
name: 2026-07-07-recap
slug: 2026-07-07-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Conduition and Jeremy Rubin
to discuss [Newsletter #412]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-6-8/427589415-44100-2-19af7fc20fc5f.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #412 Recap.  We
didn't have any significant News items this week, but the Changing consensus
monthly segment is pretty packed.  We have seven items, with most of them being
quantum-related, so there's a lot to get through.  Luckily, Murch and I this
week are joined by Conduition, who can help us through that segment.
Conduition, who are you?  What are you working on?

**Conduition**: Hey, Mike, thanks for letting me be here.  I am a cryptographic
security engineer working on various post-quant initiatives, the namely largest
one being SHRINCS.  And I'm also hoping to work on isogenies and commit/reveal
soon, and I'm funded by a grant from Brink.  I'm very glad to be here to
discuss some of this very cool stuff, because we've got a lot of really
interesting changes that are being proposed.

_Benchmarking SLH-DSA STARK aggregation_

**Mike Schmidt**: Well, thank you for joining us.  You did participate in many
of this week's Changing consensus discussions and authored one of the
proposals.  So, we'll take these quantum-related items first for listeners
while Conduition is with us, and then we'll finish with the remaining Changing
consensus item, starting with "Benchmarking SLH-DSA STARK aggregation".  I
think listeners are probably familiar with the challenge.  One of the
challenges with post-quantum signatures being they're enormous and a block full
of them barely fits.  One proposed workaround is potentially don't put the
signatures in the block at all.  Maybe you can have one compact cryptographic
proof that says, "I verified all these signatures and they check out".  That's
where we get into the STARKs and this week's Remix7531 post about some
benchmarks on the Bitcoin-Dev mailing list post.  This was based on an earlier
proposal from Ethan Heilman along these lines.  But Conduition, how would you
break down the idea, and then also the meat of this, which is the benchmarking
piece?

**Conduition**: Yeah.  So, for the uninitiated, SLH-DSA is a hash-based
signature algorithm.  It's the only one that's been standardized by NIST.  It's
known for being extremely performance-intensive for the signer, but for
verifiers it's actually quite cheap.  It's a lot cheaper than schnorr in terms
of cost per byte.  But like you said earlier, hash-based signatures are very,
very large.  And so, a common strategy that people have been looking into
recently is using STARK aggregation, where you have a list of signatures and
messages.  And kind of like CISA (cross-input signature aggregation) style, you
aggregate them all together into one single zero-knowledge proof that is
essentially a proof of the statement, "I verified this list of signatures on
these messages".  And this way, the verifier of a block wouldn't need to
actually have the signatures, they would only need to have the messages.  And
this would save a lot of blockspace.

The downside to this approach is that proving time is incredibly long, and it
scales linearly with the number of signatures.  And benchmarking this stuff is
a really useful and important metric to have in mind when we're researching
this kind of stuff.  So, I'm really glad to see people actually going and
building the code that actually runs this stuff.  I've seen two people
independently pursue this line of research, one of them being Remix here.  It
is unfortunately bad news, being that the number of signatures we'd be trying
to aggregate here would be in the hundreds or the thousands.  And so, we would
be looking at proving times, based on extrapolating from Remix's results here,
we'd be looking at proving times running into 30 minutes to an hour or more.

**Mike Schmidt**: How does that grow?  Like, for each additional signature, are
we growing linearly?

**Conduition**: Linearly for each signature.  However, the proof size grows, I
believe, logarithmically.  And so, the proof size would never really exceed 1
MB, even if you compiled in thousands and thousands of signatures to this one
proof.  The verification time likewise also grows logarithmically.  And I'm not
actually 100% sure, it might be polylogarithmic.  Anyway, it's much, much
faster to verify than it is to prove a STARK like this.

**Mike Schmidt**: Now, for the proving piece, what is your feeling or what have
you seen in terms of optimizations?  I know oftentimes these things, the first
iteration is slow, but then there's little discoveries and optimizations and
performance improvements that are made.  Is your feeling that there's meat on
that bone there?  Can we whittle it down?  Or is this roughly where this would
end up?

**Conduition**: Absolutely, we could.  It's a matter of what we're willing to
sacrifice to get there.  So, there's trade-offs.  One trade-off you could make
is to ask every signer who posts a Bitcoin transaction to do the proving of
their own transaction signature on their own message.  And then, when
aggregating, the miner, I would assume it would be the miner who would be doing
this, would aggregate together a bunch of STARK proofs recursively.  Now, I'm
not sure of the wisdom of doing this, because at that point you're depending
more on the security of the STARK scheme than on the signature scheme.  And so,
you might as well remove the signature scheme entirely and just have like a
STARK proof of knowledge of a hash preimage instead of using SLH-DSA.  But
another trade-off that you could make is using a more arithmetization-friendly
hash function, a more STARK-friendly hash function.

So, the way that STARKs in general work is that they turn any arbitrary
computation into an arithmetic circuit.  You can think of this as a directed
graph where you start with a whole bunch of input data, and then you parse that
data forwards through a series of multiplication, addition gates.  And
eventually, you come out with a final result.  And the STARK proof is a way of
formally showing to a verifier that you computed the circuit with some inputs
and got these outputs.  Now, the bigger the arithmetic circuit is, the slower
it is to prove.  And so, you can make proofs much more efficient by using
computations that are more arithmetically-friendly, so to say.  And
unfortunately, SHA256 is very unfriendly to arithmetization.  It uses a lot of
bitwise operators, and that makes it very hard to arithmetize.  There are other
hash functions that are easy to arithmetize, and I have seen some work from
someone else who's been doing work on Poseidon SLH-DSA.  And the Ethereum
Foundation, I know, is very interested in this subject.  I don't want to dox
him because I'm not sure if he's made his findings public yet, but it is
definitely an open avenue for research, and there's a lot more that could be
looked into.  But I'm not 100% sure that the Bitcoin community would like to
use something other than a NIST-approved hash function here, because it would
slow things down on the signer side and there would be other concerns with
security.

**Mike Schmidt**: Now, we're talking about SPHINCS in this benchmark, but does
SHRINCS or any of these other smaller optimized variants for Bitcoin change
roughly the conclusion here?

**Conduition**: I would say it changes it by a linear amount.  Verifying a
stateful SHRINCS signature is a certain factor cheaper.  I can't remember off
the top of my head exactly how much.  I think it's maybe around an order of
magnitude cheaper to verify.  So, just take the benchmark numbers in Remix's
post there and scale them down by a factor of 10 approximately.  Again, I'm not
exactly sure.  I can't remember off the top of my head what the compression
call numbers are for stateful SHRINCS versus stateless.  But it's not such a
huge speed-up that it would be game changing.

**Mike Schmidt**: Got it.  Murch, any questions from you or, Conduition,
anything else before we wrap up this item?

**Conduition**: No, not really.  I do think that the idea I mentioned earlier
about using STARKs to prove knowledge of a hash preimage, I think that has been
done before as a signature scheme, standalone.  So, that would be worth looking
into whether that can be aggregated, and whether it would provide more
efficient proving time than aggregating SLH-DSA with all of its 21 million hash
function invocations.

**Mark Erhardt**: Maybe what sort of new cryptographic assumptions would we
need to verify STARKs in Bitcoin?

**Conduition**: Actually, I don't think any.  The biggest drawback to STARKs in
terms of security is not the cryptographic assumptions.  Because they don't use
any new cryptographic assumptions that I'm aware of beyond hash function
security.  The drawback would be implementation complexity.  Definitely a far,
far greater scope of implementation would be needed for STARKs than for simple
hash-based signatures.  It's why I'm personally skeptical of them making their
way into consensus anytime soon.  But in the long term, anything could happen.

**Mark Erhardt**: Okay, so they're very complicated to implement and they're
very expensive, slow to prove.  So, this probably doesn't make for a great
signature scheme when we're trying to aggregate a few thousand payment
transactions per block?

**Conduition**: Well, not with current benchmarks, but you know, there's always
room for improvement.  I'm hopeful that this is an active area of research that
will find some value yield in the near future.

_Bird of Prey 2 (BoP-2) non-malleable schnorr and PQ signatures_

**Mike Schmidt**: Next item from Changing consensus, "Bird of Prey 2 (BoP-2)
non-malleable schnorr and PQ signatures".  This was motivated by a post from
Pieter Wuille to Delving Bitcoin about this 2026 paper from EuroCrypt on having
this hybrid scheme.  So, it's a hybrid scheme, it's a schnorr-like scheme, and
an arbitrary post-quantum signature scheme put together in a hybrid manner and
in a strongly unforgeable signature.  Maybe we can unpack some of those words,
Conduition.  Is it as simple as, you know, I know a lot of people have been
talking about, "Hey, just have the ability to have a schnorr signature and a
SHRINCS signature, and you can multisig that, or it can be 1-of-2, or
whatever".  What is being spoken about here?  This seems like something
different.

**Conduition**: Yes.  This is a really cool paper.  Okay, first of all, I
should back up and explain what 'strongly unforgeable' means, for anybody not
familiar.  Strong unforgeability is a notion that says if I've signed a
message, you should not be able to take that signature and turn it into a
different one on the same message and still verify that signature valid.  And
this used to be extremely important for Bitcoin.  In fact, ECDSA actually had
big issues, because it was not strongly unforgeable under the encoding schemes
that we used in Bitcoin.  And this led to, I believe it was BIP66.  Murch,
maybe you can correct me on this, but the DER encoding standard for ECDSA.

**Mark Erhardt**: 60-something, definitely.  I can look at it while you
continue talking.

**Conduition**: Anyway, the problem with ECDSA was that its signatures could be
malleated.  Given a signature, you could change the encoding of that signature
in a way that's still verified to a Bitcoin node.  But by doing that, because
the signature was in the script input field of the transaction, you would
change the txid, and that would complicate a lot of multiparty protocols,
especially ones like Lightning, which rely on having child transactions of
parent transactions that aren't in the mempool.  You need to watch out for
specific txids.  And if those txids change unpredictably, it's very hard to
handle the result.  So, strong unforgeability can be very useful, but nowadays
it might be a little less important because the signatures are in the witness,
which do not affect the txids anymore.  They only affect the witness txids.

Anyway, going back to the topic of discussion here, BoP-2, it is a way of
taking a strongly unforgeable post-quantum signature scheme, like for example
SLH-DSA or SHRINCS, and composing it with a schnorr signature scheme, like
BIP340.  And from it, you can construct a strongly unforgeable hybrid signature
scheme.  In other words, a schnorr-plus-PQ signature on a single message.  And
as a little added bonus, you also get a small savings in terms of the signature
size.  I think it's about 32 bytes, because you can actually reuse some of the
data.  You don't need to post it all together, because you can make use of a
common piece of data between the two signatures.  Now, the biggest advantage of
this is really, of course, the strong unforgeability property that you get from
the resulting hybrid scheme and the savings in size.

**Mike Schmidt**: So, I'm reading from our write up.  Maybe you can get into
the fact like, how is that strong unforgeableness attained here versus just
concatenating the two signatures?  Or maybe you got into that and I missed it.

**Mark Erhardt**: Yeah, maybe let me ask my question.  I seem to remember that
the schnorr signature would commit to the post-quantum signature, and because
then, of course, if the post-quantum signature changed in any byte, I think
that the post-quantum signatures tend to be more malleable because it's all,
well, actually hash trees, so maybe not.  Do I have a right intuition there?

**Conduition**: I'm sorry, I would have to go back and review.  I haven't
actually delved too deep into how BoP-2 works myself.  I was actually more
involved in Boris Nagaev's idea for how to do this.  And he had a similar idea
to BoP, but it was a little more involved because you can't treat the PQ scheme
as a black box in Boris's scheme; whereas with BoP-2, you can treat the PQ
scheme like a black box where you don't actually need to know how it works
internally.  We'll actually get to that subject a little later in the
newsletter, because it evolved into something very different and I think much
more useful.

**Mark Erhardt**: I see.  Well, either way, we would want these signatures to
be non-malleable, at least in the sense that whatever propagates to the
surface, the non-witness data should not affect the txids, because changing
txids are a problem for us.  So, I seem to have remembered that it was done by
the, well, I'm speculating.  Let's move on if there's not much more to say!

**Conduition**: Well, there is one other thing to say, which is we should also
set the expectation for what the default would be if we do not use something
like BoP-2, and Mike, you alluded to this earlier.  But the idea is if we add a
post-quantum signature scheme as a standalone scheme in the future, say
SHRINCS, then anybody who wants to use a hybrid scheme, first of all, they have
to make a choice if they want an AND scheme or an OR scheme.  In other words,
do you want to be able to spend your coins with a schnorr signature or a
SHRINCS signature?  Or do you want to be able to spend with a schnorr signature
and a SHRINCS signature?  If it's the former, if you want an OR hybrid, then
you can very easily do that today using P2TR or P2MR or some other script tree
construction.  But if you want to do an AND, then the default way to do that
would just be to have a hybrid script that contains two public keys and two
CHECKSIG operations.  Now, that actually is not a single-signature scheme, so
it's not fully correct to say this, but in a way, that construction is not
strongly unforgeable.  Because although both signature schemes independently
might be strongly unforgeable, when taken together, especially in the quantum
context, they are not unified strong unforgeable.  Because if you have a
quantum computer, that quantum computer could just break the elliptic curve key
and then change the signature to whatever it wants.  It can't change the
message, but it can change the signature.

The other consideration is in the classical setting, if you use those keys to
sign the same message multiple times, then you can mix and match signatures
from the different transactions you see.  I don't think any of this is of
severe consequence now that we have segwit, because they won't affect the
txids, no matter what you change the signatures to.  I still haven't heard any
good arguments for why it might be important if wtxids changed.  I think Pieter
Wuille referred to this briefly, but didn't give a concrete example.

**Mark Erhardt**: You can waste a bit of bandwidth, because in the P2P
messages, we identify transactions by wtxid to determine whether we have them
already.  Because you could theoretically have, for example, a P2TR input that
can be spent by a keypath and a scriptpath, where you first see a scriptpath
signature, and then later someone signs with a keypath signature that is
smaller, and thereby the transaction has a higher feerate, although the inputs
and outputs didn't change at all, just the witness structure was smaller and
thereby the feerate increased.  So, in order to be able to propagate different
transactions with different witness data, but otherwise the same, we propagate
them by wtxid.  So, if someone can malleate wtxids, we might see more than one
version of the transaction propagate.

**Conduition**: Okay, thank you.  I'm going to take a note for that and look
into that later, if that sounds interesting.

_Lattice-based signatures_

**Mike Schmidt**: I think we can move to the next item titled, "Lattice-based
signatures".  This was a post to both Delving and Bitcoin-Dev mailing lists
from Nikita Karetnikov, and it referenced a Blockstream blog post comparing
different post-quantum signature families, including Lattice-based schemes.
So, Conduition, we have hash-based, we have lattice-based, I know you're
looking into isogenies as well.  How are you thinking about lattice?  I think I
saw a clip of Dan Boneh encouraging or somehow speaking positively about
Bitcoin and lattice.  Maybe tl;dr on lattice and we can get into maybe some
pros and cons and how you're thinking about it.

**Conduition**: So, I don't know too much about lattice cryptography, and I
don't want to talk out of my butt on this one.  But from my research that I did
do a year or so ago onto lattices, I was a little let down and disappointed by
the lack of mathematical flexibility that they offered.  They're often pitched
as a more flexible and more potentially promising cryptographic family of
schemes.  But in reality, the constructions that we have available just aren't
that great.  What we have right now consists of a cobbling together of
different papers that have proposed various ways of doing things, like BIP32 or
multisignature or threshold signature on lattices, but they all require
changing the schemes.  For example, one that I know of, and the most efficient
re-randomization scheme that I know of, is called DilithiumRK.  And I can't
remember off the top of my head exactly how big they are, but they do increase
the size of Dilithium signatures, and I don't know of any multisignature
schemes.  I think there are some, but they do result in much bigger signatures,
and these kinds of trade-offs, it's not clear how you'd combine them.  Like,
how would you get a scheme that has both re-randomization so you can get BIP32
hierarchical deterministic wallets, and multisignatures so that you can do
multisignature things on Bitcoin.  And that's a gap that still needs to be
filled.

But there are other options, but I'm mostly skeptical of lattices for that
reason.  And don't get me wrong, it would be really cool to have those things,
and I think we should still pursue them as research avenues.  But well, it's my
opinion that we should engineer based on what we have and not what we think we
will have in the future.  So, that's why I'm personally working on hash-based
signatures first.

**Mike Schmidt**: While also pursuing some of the isogenies work, right?  And
that's maybe more of a longer-term thing.  So, maybe the lattice, the way
you're thinking about it is lattice is somewhere, I don't want to make it
linear, but somewhere in the middle of the two, where hash-based is kind of
this dumb quantum-resistance signature scheme, and maybe isogenies could get us
more towards the full feature signature schemes that we're used to today.  And
the lattice is kind of somewhere in the middle.  Is that how you're thinking
about it?  Yeah, yeah.  Isogenies are great for flexibility and there's a lot
of promise there.  There's actually just been a recent paper published proving
key re-randomization on isogenies secure, which is really great and exciting.
Threshold and multisignature on isogenies is still forthcoming.  But I think
the major problem with isogenies right now is verification time, and that's
something that I'm really hoping to work on in the future.

Hash-based, like you said, is kind of like the dumb brute of the post-quantum
signature families.  And they're very fast to verify, which is great.  So is
lattices.  Lattices are very fast to verify.  So, I think any scheme that we
want to integrate into Bitcoin is going to have to tick a few important boxes.
Unfortunately, we don't have one that ticks all of the boxes right now.  And
that's why there's so much debate going on between people on post-quantum
crypto schemes.

**Mark Erhardt**: Luckily, we need to check some of those boxes maybe at
different times in the future.  So, there had been some talk about a dual-front
approach, where we tried to have something rather quickly.  And I think the
hash-based signatures that don't require as much innovation in the
cryptography, and the dumb brute as you say, will fit that short-term horizon,
where we just maybe enable large cold-storage holdings to be post-quantum
secure, and we do have support for some post-quantum scheme.  And then, maybe
the isogenies and lattice-based signatures and future research-based topics are
more of an approach that becomes available when we look at the long-term
solution, if we want to migrate the entire system to post-quantum and we have a
little more time towards making a lasting solution.

**Conduition**: Totally agree.  And multiple things can be pursued at once and
that's why I think it's really cool that people are also looking into lattices
because, well, I mean it is what the whole rest of the Web 2 world is using
right now for post-quantum.  And it would be cool if we could make use of that
research and the activity going on in that domain.  And so, I'm really happy to
see Blockstream and Project 11 and other think tanks working on seeing if we
can make lattices work for Bitcoin because if we could, it would be really
cool.  Right now, I'm not convinced, but that's not to say that I can't be.

_Public key recovery for P2MR EC leaves_

**Mike Schmidt**: Next item, "Public key recovery for P2MR EC leaves".  And
this was a post to Delving Bitcoin from starius, and he outlines this trick of
a schnorr signature actually containing enough information to reconstruct the
public key that produced it.  So, why bother including the public key in the
transaction at all?  Maybe, Conduition, what is starius getting at here?  I
guess there's space savings by not having the public key and then it wouldn't
be sitting there for a quantum computer as well.  Maybe tie it together for us.

**Conduition**: Oh, I'm excited about this.  This is probably one of my
favorite ideas that I've seen in the past six months.  This is an idea that has
already been used before in other situations, like Ethereum uses public key
recovery from ECDSA, for example.  So, this is a known mathematical thing you
can do.  The key innovation here that Boris proposed is avoiding related key
attacks while also allowing public key recovery.  So, in order to understand
this, we need to go back to BIP340 and understand why the public key is
included in the schnorr challenge hash.  So, when you compute a schnorr
signature, you run a hash, and that hash determines something called a
challenge.  And the challenge is the thing that you actually sign.  Like, if
you look at the mathematics of how a schnorr signature works, it's basically
just your private key multiplied by the challenge plus some random number.
Now, the challenge, if that stays the same, then anything else outside it could
be mutated and the signature is still valid.  So, if you have a challenge hash
that is just the default, like a canonical schnorr signature challenge hash,
that would just be a hash of your nonce, R, and the message, M.  Now, if you
change the public key, and add some sort of additive tweak to it, then the
signature would still be valid on the same message but the key would have
changed.

This is a really, really bad thing for Bitcoin because we use BIP32 tweaks, we
use taproot tweaks, there's a lot of situations in which keys can be related by
these tweaks.  And so, we really, really don't want you to be able to rebind a
signature to a different public key that is related.  And that's why the public
key is included in the BIP340 challenge.  Now, if Boris's idea here had been
known about at the time of BIP340, it could have been possible that we could
have hashed the public key before putting it onchain.  Because what Boris
realized was that you don't actually need it to be the public key itself in the
challenge hash.  It can be a hash of the public key instead.  Or actually, it
could be any binding commitment to the public key.  And if you can do this, and
assuming you already have that commitment on the verifier, then the verifier
can actually recompute the public key point and then verify it against that
commitment.  And this lets you save the public key from going onchain in the
context of Bitcoin transactions, because what you can do is you can, say, post
a hash of the public key onchain, or in the case of P2MR, you post a merkle
root, which is a commitment to the public key.  And then, when the verifier
sees the signature, they can recompute the public key and then hash it, and
then check that against the commitment that's onchain.  And the challenge hash
is still fine.  You can still compute that just fine because you already have
the commitment, which is the part that actually goes into the challenge hash.
And you're safe against related key attacks.  It seems like it's a win-win-win
situation.

**Mike Schmidt**: Does this mean then we don't have the long exposure on these
address types?  Is that the main win, in addition to space savings?

**Conduition**: Well, we still have long exposure on existing UTXOs, but this
does free us up to implement something like P2TRH, which is just P2TR but with
a hash on the public key.  It would have the exact same witness size as P2TR
keyspends, it would also have script trees.  It would be secure against long
exposure attacks, but not short exposure attacks.  So, I think that's an
interesting potential compromise between the two sides of P2TR v2 and P2MR,
which is another debate that I'm sure we'll get into later in this podcast.

_Aligning privacy incentives in P2MR_

**Mike Schmidt**: "Aligning privacy incentives in P2MR".  Well, Conduition,
this is your post to the Bitcoin-Dev mailing list, so I'll let you frame it.

**Conduition**: Thank you.  Yes, this one got a little digressive, but
initially it was pointed out that P2MR admits a kind of perverse incentive in
some scenarios, where P2MR is essentially just the script tree element of P2TR,
but transplanted out of taproot and into its own output type.  So, you post a
merkle root onchain, and that merkle root's leaves are supposed to be scripts
and tapleaf versions.  And you can spend from that address by revealing one of
those scripts, a merkle path, and a script witness to authenticate it.  Now,
unfortunately, this would be a little bad for privacy in some situations,
because some people might want to have a merkle root with just one leaf,
because maybe they only need one script.  And maybe they don't care about
having a cooperative spend path and they just want to minimize the fees.  Well,
that allows for easier fingerprinting of such wallets or protocols, and that,
of course, decreases the anonymity set for everyone else.  And this is a
distinction from P2TR, where in P2TR, everybody has to pay the cost of the
default spend path.  Sorry, Murch?

**Mark Erhardt**: Yeah, I think beyond the privacy impact, the other issue is
we would want people to move to P2MR in order to achieve post-quantum security.
And if they were moving to a P2MR with a single script leaf that is motivated
by economic reasons, they would not have post-quantum security in that P2MR
output, because a single leaf, no keypath, no other leaf to fall back on with
the post-quantum security.  And so, we would see a bunch of P2MR outputs
potentially.  But they would be sort of a false signal in the sense that they
do not indicate people that have moved funds into post-quantum security.  The
other reason being also that any new output type will of course split the UTXO
set into further output types and adds fingerprints.

**Conduition**: That's very true.  We want the migration to proceed in a way
that everyone has a post-quantum leaf in every address.  And there might be
some edge cases where that doesn't happen, but by and large everyone will
because, well, here's maybe a good way to segue into my post.  My suggestion to
change BIP360 was to ban depth-zero trees.  And this fixes the perverse
incentives that we were just talking about, because now there's no way to have
a depth-zero tree at all.  Every P2MR tree must have at least two leaves.  And
because of the way script trees work, because leaves can be at any position in
the tree, you can never be sure as an observer if a particular script tree has
two leaves, or three leaves, or four leaves, or eight leaves.  At best, you can
get a lower bound for how many leaves there are.  And I actually got a great
suggestion from Ethan Heilman when I submitted this PR.  He suggested making
this change an ANYONECANSPEND success path instead of an outright ban.  I think
this is a really smart idea because it opens the door to potential upgrades to
P2MR in the future that might do stuff like isogeny-based key tweaking, or even
have a schnorr, what's it called?  Have P2TRH nested inside of a depth-zero
merkle tree, which actually might be worth talking about at some point here.

**Mark Erhardt**: Would that potentially allow for your P2TRH idea, basically?
Because isn't there a crossover maybe?

**Conduition**: There absolutely is.  I think this is actually one way that we
could potentially resolve the P2TR v2, P2MR debate, which is what this
discussion on the mailing list kind of devolved into.  Because I initially
proposed this on the mailing list and to seek feedback from Antoine and Pieter
and people who are critical of this privacy aspect of P2MR.  It ended up
devolving into a larger-scale debate about P2MR and P2TR v2.  But I think we
overall had consensus on the core idea of getting rid of depth-zero script
trees.  Now, what if we didn't, though?  What if we got rid of just the bad
case of depth-zero script trees, and instead made use of depth-zero script
trees for P2TRH?  Because then, you could get the same witness size as P2TR,
but still have the post-quantum security of P2MR.  Sorry, I didn't give you
guys any warning about this, but I literally just had this idea before this
podcast.  So, I don't want to go too deep into it.

**Mark Erhardt**: I guess I'm going to talk back at myself right away, because
if we go back to using the depth-zero leaf, then of course there wouldn't be a
post-quantum secure leaf there either.  So, if the idea is anyone that moves
into a P2MR is expected to have a post-quantum leaf, then that would be
undermined by making use of the depth-zero leaf.  If the idea is just to offer
a way of using the schnorr signatures and tapscript, without having the output
be long-range-attack vulnerable, then of course that might make more sense.

**Conduition**: Yeah, I think there's definitely some more discussion to be
had.  But I think the idea of depth-zero script trees is certainly a focal
point that we need to discuss more, because there's some options to consider
either way we go and different trade-offs for each of them.  So, fun
discussions to be had on the Delving.

_Triggering EC disabling with a NUMS point spend or hashrate majority_

**Mike Schmidt**: Sounds like you need to start another one now, Conduition.
We have one more quantum item from the Changing consensus segment titled,
"Triggering EC disabling with a NUMS point spend or hashrate majority".  And
Conduition, this also references P2MR and P2TR v2, which I know you referenced
was sort of a battle that sprung out of the last item that we were talking
about.  Can you articulate why Pieter posted this idea?  And then, that can tie
into potential downsides of P2TR v2?  And then, I think that will maybe frame
up the quasi battle that emerged in the last discussion that was in its own
item.

**Conduition**: Great prompt.  So, to summarize here, there are a couple of
competing post-quantum output type proposals.  One of them, probably the most
mature, is P2MR, which most people here have probably heard.  I described it
earlier.  It's basically just the script tree part of taproot taken out of
taproot.  P2TR v2 is much simpler.  It is just a one-for-one duplicate of P2TR.
The only distinction between it and P2TR is that it explicitly opts anyone who
uses it into a future disabling of the keyspend path.

**Mark Erhardt**: And of course, it would use a native segwit version that is
different from P2TR.  So, wallets and services and so on would have to probably
… well, the spec of segwit suggested that all future segwit versions should be
allowed to send to, but I think the past has shown that most services do not
permit that.  So, they'd probably have to make some minor tweaks to allow
sending to them.  But then, the implementation otherwise should be pretty
trivial for anyone that already supports accepting and sending from P2TR
outputs.

**Conduition**: That's right.  It would be a minor change.  However, it comes
encumbered with some technical debt, and that technical debt is that we must
find a way to reliably disable that keyspend path before a scalable quantum
computer tries to attack Bitcoin.  If we do not, then all of those supposedly
post-quantum outputs in P2TR v2 are not so post-quantum, they are completely
stealable.  The debate between P2TR v2 and P2MR mostly revolves around this
question of, can we reliably disable EC spending at a time that we should?  And
what time should we disable it?  So, this is the post that Pieter made, and
this is the subject matter that he is seeking to discuss and try to build some
technical solutions to.  And I really like that, because whether we do P2MR or
P2TR v2, it's actually a really good idea to disable EC spending on that new
output type eventually.  But the problem really boils down to timing in the
case of P2TR v2.  We really, really would want to have EC spending disabled at
exactly the right time.  We don't want to go too early, or people are going to
regress onto vulnerable addresses.  And we don't want to go too late, because
then the quantum computer can steal all the money that's on those addresses.

So, Pieter suggests a few ways of doing this.  One of them is a provably
certain tripwire, where you have a NUMS point (nothing-up-my-sleeve).  A NUMS
point is a point on the secp256k1 curve that you find by computing a hash
function.  In other words, you hash from some fixed input to a point on the
curve.  And this is provably unspendable classically, because if you're given
any point on an elliptic curve, you shouldn't be able to derive its discrete
logarithm.  That's the ECDLP in a nutshell.  So, if you can find the discrete
log of a NUMS point and sign with it, or even just disclose the discrete log
itself, well then you've provably beaten ECDLP.  So, that's an unquestionable
certainty that if somebody can spend a NUMS point, we should disable EC
spending, because the ECDLP is no longer secure.

Now, there's another method Pieter suggests, which is mining activation.  He
wasn't exactly clear about how this would work, but I would imagine it would
work a lot like most other soft forks in the past.  It would probably just have
a very long activation window so that we can activate it at any point in the
future, if and when a quantum computer appears suddenly.  Both of these options
come with some caveats.  For one, the NUMS point tripwire will only work if the
quantum computer that we are trying to defend ourselves against is cooperative
with us.  Because no quantum computer who wants to attack Bitcoin is going to
willingly disable its ability to attack Bitcoin.  And so, you really want a
quantum computer who isn't your adversary available to activate this tripwire.
The mining path is also somewhat problematic, in that you would need to find
some way of triggering the activation quickly in case of an emergency, but also
in a way that random solo miners can't just activate it willy nilly by mining a
specific block with a specific flag.  I'm not sure how exactly you'd do that.
I'm not too knowledgeable on software activation logic, but Murch, maybe you
can opine on that subject.

**Mark Erhardt**: I haven't been following too closely, but yeah, it seems to
me that one of the not just tripwires, but tripping points in the whole, "Oh,
we'll disable elliptic curves and the keypath on P2TR at a later date", is
determining when the correct time is.  Optimally, you would want to disable it
just before quantum computers become able of attacking Bitcoin.  But of course,
the industry has been extremely opaque in general.  There's a lot of
speculation around the capability and the timelines.  So, if you disable it too
late, you might still be vulnerable; if you disable it too early, you force
people into overspending on the post-quantum outputs, because they now have to
fall back away from the keypath spend, although that might have not been
necessary yet.  And yeah, there are some ideas, but that is one of the
interesting points about having a dedicated post-quantum scheme, is the people
that want to opt into that can opt in at any point.  They will have to then
spend the expensive post-quantum output if they want to access those funds, but
it makes it the individual decision, which of course people will probably also
procrastinate on.  So, there are so many different areas where there are still
dragons here that, yeah, it's no wonder that most of the discussions on the
mailing list are about post-quantum now.

**Conduition**: Yeah, the whole subject of when quantum computers will arrive
is a garbage dump discussion fire that nobody can really resolve until somebody
has a quantum computer.  So, my personal philosophy is we can't predict
technological revolutions with certainty, let's not try to.  So, let's just
prepare for when it happens and be ready for anything.

**Mark Erhardt**: Yeah, especially lately with the breakthroughs in AI and
LLMs, certain areas of research have just taken totally different trajectories.
Luckily, I think quantum computers still require a large amount of people doing
stuff in labs, which AI will probably not be able to do for them anytime soon.
But yeah, we live in interesting times.

**Mike Schmidt**: Conduition, it may be intuitive for people of why the EC
disabling would be a priority for P2TR v2.  It may be less obvious why that
would be necessary in P2MR world, where there's a post-quantum signature
scheme.  Maybe, can you comment on that?

**Conduition**: Yeah, absolutely.  This is actually a very key point in the
debate between P2TR v2 and P2MR.  So, whether we use P2MR or P2TR v2, there
will be some subset of coins that end up on that output type with exposed EC
public keys.  And this would come about through things like address reuse or
xpub sharing or watch-only wallets or multisignature.  And through all these
avenues, your EC public keys can be exposed to a quantum computer who would be
able to factor them and attack you.  Even if you're using P2MR, where
everything's hidden behind a hash, even if you've never reused an address, it
might come about just because your desktop wallet was sharing your xpub with a
server, like think of Samourai Wallet, for instance.  And these kinds of risks
would mean that there will be some subset of users using P2MR who will be
exposed to quantum computers.  And so, once we're sure that a quantum computer
is around, we want to disable EC spending for those addresses so that they can
be protected, and then they can start using their post-quantum signing leaves
instead of elliptic curves.

That's why it's useful to have EC disabling, even for P2MR, even though we
don't strictly need it in P2MR, because it would still be nice to have.  And
once we're sure that it's a thing, why not activate it?

**Mike Schmidt**: Conduition, anything else on this item before we move along?

**Conduition**: No, I think I'm all good.  I think that was a very good
summary.

**Mike Schmidt**: Well, Conduition, thanks for joining us and shepherding us
through the quantum items in this Changing consensus segment.  You're welcome
to hang on, and you're welcome to drop if you have other things to do.  We
understand.

**Conduition**: I'll hang around for a while.

**Mike Schmidt**: All right.  Well, we have another guest who's joined us.
Jeremy, how you doing?  You want to say hi to the folks?

**Jeremy Rubin**: Good, how are you?

**Mike Schmidt**: I'm doing good.  Who are you?  What are you working on?

**Jeremy Rubin**: Well, I am Jeremy Rubin, I am currently working on something
called Char Network, which is a layer 2 consensus system generally working on
kind of BitVM more scalable functionality layers on top of Bitcoin.  And so,
we're solving a problem of in between blocks, people still want to be able to
get confirmations of their transactions for lower latency.  And so, that's the
core of the problem that we're solving.  Today, I've worked on Bitcoin for a
long time, so I also work on a bunch of other things as well, including I guess
the topic that we're going to talk about today.

_Prohibit merkle internal node preimages that encode minimal 64-byte transactions_

**Mike Schmidt**: Yeah, today's topic is, "Prohibit merkle internal node
preimages that encode minimal 64-byte transactions".  This was a post that you
sent to the Bitcoin-Dev mailing list, related to a discussion that we had a few
weeks ago in Newsletter #408, where Murch and I tried to talk through your
previous post on the matter of valid 64-byte transaction use cases.  Maybe,
since you weren't here to represent that then, and it would also be helpful for
people to understand your perspective, maybe summarize those use cases and why
you're trying to protect 64-byte transactions in some cases?

**Jeremy Rubin**: Yeah, I think that the thing that I'm really trying to
protect is not really 64-byte transactions.  I kind of don't really care that
much about them, but what I care about is I care about transactions being
linear and discontinuities in consensus rules.  An example of a discontinuity
in a consensus rule would be, I'm going to make up an example, like let's say
that you can do a sequence lock of 10 blocks, 11 blocks, 15 blocks, 16 blocks,
and 17 blocks, so on and so forth.  And then, every now and then, there's just
a random gap and you're not allowed to do that.  And so, somebody later on
might be making a piece of tooling and then they might not know about these
discontinuities.  And then, that might lead to either a loss of funds or it
might lead to a bunch of excess complexity later on down the road, because they
now have to contend with some rule of, "This isn't allowed".

With transactions, transactions can be as small, I believe, as 60 bytes, is the
smallest possible valid transaction.  And that is a transaction that is one
input, one output.  And there is no script or scriptSig with that transaction.
That's the smallest transaction.  Part of what makes this issue particularly a
little bit thorny is that really, we're talking about the witness stripped
size.  So, in a lot of cases, you might have the actual transaction, like if
you read it from your disk, it might be 100 kB.  But if you're looking at the
difference between the segwit component and the onchain, you know, from the
legacy section of the block would be 60 bytes.  The issue that comes up is that
if you specifically target 64 bytes, which can be done, I think, by a couple
different combinations of bytes in the scriptSig or bytes in the scriptPubKey
of that one in, one out.  There's just a couple combinations because it's a
small, you know, you do three here and you do two there, or one there, so on
and so forth.

So, the problem that arises is that when transactions are hashed, that gives
you a 32-byte hash.  And when we put the transactions into the merkle root of
the block, we put two hashes side by side, and then you hash again.  And what
this can lead to is a confusion of, "Is the piece of data that I'm looking at,
is it a transaction or is it a higher-level node in that tree of 2
transactions' hashes?"  So, the merkle root in Bitcoin is kind of an
interesting one in and of itself, but that's the core problem that we're
dealing with.  And then, the concern that I have is not really about 64-byte
transactions in particular, though we can talk about the specific types of use
cases that might come up.  It's more around the discontinuity of it being valid
to have 60-byte transaction, a 61-byte, a 62-byte, a 63-byte, not a 64, a 65.
And so, the concern is less so from maybe somebody writing a library that does
something, and perhaps a little bit more oriented towards in the future, we
might have covenants or something, or we might have some other advanced use
cases.  And then, avoiding those automatically getting into situations where
64-byte transactions are omitted without having like lots of guardrails around
that might be problematic.  So, that's really the core of the problem.

The use cases, and I'll pull up my email just so I can give it, because it was
a while ago that I wrote that one.

**Mark Erhardt**: Well, if you just want to take a glance at that, I maybe
recap a little what you said.

**Jeremy Rubin**: I have it up.  But yeah, if you want to recap, go for it.

**Mark Erhardt**: I just wanted to confirm.  Yes, the smallest possible
stripped size of a transaction is indeed 60 bytes.  That is by having 41 bytes
for the input, 10 bytes for the transaction header, 8 bytes for the amount, and
then 1 byte for the length of the output script, which then is empty.  And the
41 bytes of the input are the 32 bytes of the txid, the 4 bytes of the output
position that you're spending, 4 bytes for sequence, and then again a length
indicator for the input script and an empty input script.  So, the problem
indeed exists that we would be allowed to have stripped transaction sizes of 60
to 63 bytes, not 64 bytes, and then 65-plus.  And that leads me to my first
question.  Would it then be preferable to you if just all sizes below 65 were
forbidden, rather than having the discontinuity?

**Jeremy Rubin**: I think that that's a little bit preferable.  But the problem
then is you have the issue that scripts can be, if you have more than one
input, then you can have two scripts that are of 0-byte, 1-byte, 2-byte,
3-byte, 4-byte length.  And so, now script length has a dependency on how many
outputs are in a transaction.  So, a fix that I would prefer would actually
probably be, if we're worried about these discontinuities, is that scripts have
to be at least 5 bytes.

**Mark Erhardt**: Sorry, I didn't understand what multiple inputs would be a
problem here.

**Jeremy Rubin**: So, the Bitcoin transactions work is bizarre in a lot of
ways.  So, if you're enforcing a 65-byte transactions or greater rule, this is
generally sort of also forbidding these small script sizes, if you are only
spending one output or only creating one output.

**Mark Erhardt**: Well, if you have one input and one output.  If you have two
inputs, obviously you're already over a 100-byte stripped size.

**Jeremy Rubin**: Yes.  And so, then you can have these 0-byte ones.  So, it
does still kind of create a discontinuity of like, let's say that you are
brokering a transaction with someone, and just imagine that you have a protocol
where you're going, "Okay, we're going to do this, we're going to do that".
Okay, and then now we're going to drop this other output".

**Mark Erhardt**: Oh, I see.  So, if you were doing the same use case and
sometimes you had one input or two inputs, if you did it with one input, you
would have to pad the transaction.  And then, if you use two inputs, you could
use them with empty scripts.  Well, you could pad them in both cases, but that
would waste blockspace.

**Jeremy Rubin**: Well, you can pad them depending on if you can pad them.
That's kind of the problem, is maybe you can't pad them for some reason.  And
so, I think that these types of rules are just really tricky.  And they're also
tricky in terms of, I think a really good example, because this is where we
talk about the current use cases, is let's just say that I had some segwit
output and then I want to turn it into an ephemeral anchor, P2A (Pay-to-Anchor)
under the current P2A protocol.  For some reason, that's all I want to do; and
then sometimes, I can have a change output where I send the other funds and
sometimes I don't, because I might say, "Oh, well, it's a dust amount anyways,
so I'm just going to turn this into an anchor with no other output", or
sometimes I do.  And so, what can happen in theory, let's say that you had this
being omitted from some sort of covenant system, which again, keep in mind, you
can have a huge covenant, 100 kB of script data that's all living in the segwit
space.  So, these aren't transactions with no functionality.  They're
transactions that the functionality is living in the segwit script space.  So,
you could have a situation where maybe the covenant gets into a state where it
is expecting, based on its rules to, in the case where it's dust, only omit one
output and then it gets stuck in that state because of this this discontinuity.

**Mark Erhardt**: Right.  But if you were relying on this transaction to
enforce a previous transaction existing, you would need to have some script
that exceeds 2 bytes, like an ephemeral anchor.

**Jeremy Rubin**: So, the script program from segwit can be however long you
want.  It's only the script output that we're talking about.

**Mark Erhardt**: Right, the output.  Ephemeral anchors, of course,
ANYONECANSPEND.

**Jeremy Rubin**: And this is where the current use cases come in, is there are
multiple ones that are interesting for different reasons, that are currently
used in various places.  One is transaction donating to a future miner, which I
guess there's a little bit of disagreement on whether that is really different
than just a present ANYONECANSPEND; there's using outputs as some kind of
connector; and then there's P2A, which is currently a 4-byte script.

**Mark Erhardt**: No, it's a push and then 2 bytes, right, so that's 3 bytes.

**Jeremy Rubin**: I think P2A is 64.

**Mark Erhardt**: Oh yeah, it's a diversion and then a push and 2 bytes, so 4
bytes.  You're correct.  So, a witness input with an empty input script and a
P2A output, ephemeral anchor, or P2A output, could be exactly 64 bytes.  Yes,
you're correct.

**Jeremy Rubin**: Yeah.  So, In any case, I guess It's not really particularly
that, and I think that this is where maybe there's a little bit of confusion,
but it's not really that in particular, 64-byte transactions are the most
important thing.  But it's like creating these really, really rough edges of
consensus, I think is, is very undesirable.  And so, I would prefer not to do
that.

**Mark Erhardt**: I think I'm sympathetic to that argument, but I would like to
push back a little bit on the listed use cases.  I think you yourself had
described them as somewhat esoteric, but I think generally, if you have an
ANYONECANSPEND output or a donation to future miners, the construction here was
in CHECKSEQUENCEVERIFY (CSV), and then a larger number of blocks than what you
can push in a single byte, so I think it was on the order of 500-plus blocks.
Lower would be fine, even much higher would be fine.  I don't see how they
would fulfill this role of an anchor or a connector output if there were only a
single output.  So, yes, of course, the input script can be more complicated,
but you're only proving that some output will exist.  Could, could you
elaborate on that?

**Jeremy Rubin**:  Yeah, so one example of this would be, let's say that I
create a 512 CSV, so it's claimable by a miner in 512 blocks, and then I use
that as a connector.  I can now sign or spend funds to other things that are
locked that I then also preauthorize transactions.  And then, I can use that
specific 512 OP_CSV as a mutex, or semaphore really, to say that only one of
these offered outcomes can be selected by that miner.

**Mark Erhardt**: Right.  But anyone can spend that output.

**Jeremy Rubin**: It can only be spent by the miner at block 512 from now.

**Mark Erhardt**: Why?

**Jeremy Rubin**: Because it has 512 CSV.

**Mark Erhardt**: Right.  So, it can be spent by anyone 512 blocks later, and a
miner could just claim it in a different transaction without fulfilling your
covenant.  So, it doesn't work as a connector output.  Can you stop
interrupting me?  I'm speaking right now.  It cannot work as a connector output
because anyone can spend it.  So, the claim that you could make connector
outputs with 3 bytes doesn't make sense to me.

**Jeremy Rubin**: Okay.  It is a connector because the connector that I am
using is I am making an offer to any person in the future, and I am saying any
person in the future may use this specific output to select from any of these,
let's say 30 offers that I've made.  As soon as they select using that output,
all of my other offers are canceled and this is reorg safe, correct?

**Mark Erhardt**: Right.  But they might just not select any and just take the
connector output.  So, usually connector outputs are tied to a public key in
order to make sure that they are consumable by the person that relies on the
connector output.

**Jeremy Rubin**: Yes, and that's fine because the condition that you are
talking about in this example, let's just imagine, if you choose to just spend
without exercising one of your options, let's just say it's a simple, you get
to claim one coin of your choice, in that case, this would be equivalent to you
claiming the coin and then sending it to an OP_TRUE.  So, it really doesn't
matter.  With the way that you're using this protocol, in a sense, is that
you're making the offer of the value to the person in the future.  Whether or
not they take it is fine.  It doesn't impact you negatively whether or not they
take it.  It's just that you are giving them this right to claim.

**Mark Erhardt**: Okay, so you're talking about a specific connector output
that is used to give away money, but not one that other parties need to rely on
being able to spend.

**Jeremy Rubin**: Generally, for connectors, they have like one party that is
in reliance on the connector.  One party creates the connectors and another
party relies on it of, "This is proof that I can claim some funds", but it
doesn't guarantee that those funds will be claimed.  In the case of Ark, for
example, you have the connectors, and it is a proof that the ASP (Ark Service
Provider) can claim the funds that have been revoked, but the ASP does not have
to claim the funds if they don't want to.

**Mark Erhardt**: Right.  But I believe they're keyed, right?

**Jeremy Rubin**: Doesn't particularly matter.  They can still not claim the
funds and then they will revert to the original sender or original holder if
they don't claim them.

**Mark Erhardt**: Right, but they can only claim the funds by also claiming the
connector output.

**Jeremy Rubin**: The original person does not need to.  Well, I guess it is
the connector that they're claiming.

**Mark Erhardt**: I'm just saying, I see what you say about the discontinuity
and, for example, the using one input and using two inputs, needing to use
different input scripts would, for example, suck or not being able to predict
whether you will hit a 64-byte transaction size.  I can see how those concerns
make sense at first glance.  But when we dig down into these claims, it seems
to me that all of the constructions that have been listed are not really useful
from today's perspective.  And I have also not heard a construction that
plausibly makes them useful in the future.

**Jeremy Rubin**: Okay, well, so I've only really mentioned so far, in
discussing this, we've only gone through the first two, or I guess three in
terms of current uses.  Then, these are things that are like currently possible
today with no future changes to Bitcoin.  Whether or not it's useful to pay
miners in the future, I think, is sort of a matter of taste and opinion.  All
that I'm really talking about is that technically, you can use this to give a
claim to a future participant and you can bind that to a specific block height
or time.  This can be used, for example, if we wanted to have some sort of
block fee smoothing.  You can use these types of things to do that.  You can
make claims by using combinations of connectors that have both time, relative
time, and relative height locks to enable redeeming of different Bitcoin
offers.  And those can be shared out of, for example, the coinbase that you
mine.  And this might be something that happens in a future where let's say we
say, "Oh, it's actually game-theoretically sound to lock additional funds up
for block 101".  That gives incentive for miners not to rewind and try to
change things.

So, again, it's an example of something that could come up and then the natural
way to do it happens to be for a 4-byte script.  In some of these cases, you
can for sure say, "Okay, well, we're going to just make sure that we know the
discontinuity", because what can happen with the current example that I've
given is that 512 CSV happens to be 4 bytes.  But if you wanted to do 100 CSV,
I think it's only 3 bytes.  And so, that's a discontinuity.  It's just like, as
you change the parameters on what script you might naturally use, you hit a
bump of, "This is magically invalid because you've selected a number that is in
the invalid range".  And then, once you get up to, let's say I think it's
probably at least at even 2,000.

**Mark Erhardt**: It's huge, it's much bigger.  It's like into
30,000-something.

**Jeremy Rubin**: 30,000?  So, wherever it is, it's a discontinuity.  For time
and height, it's different.  So, I don't know which one.  Because I know that
for time, it therefore has the flag set.  And so, are all times valid or small
times?  I'm not sure exactly how times work for a CSV.

**Mark Erhardt**: I think the times are all valid because they're very large
numbers.

**Jeremy Rubin**: And I think that this is maybe where some of the confusion or
disagreement is, is that I'm not really particularly trying to say that these
are incredibly highly desirable use cases.  What I'm trying to say is that
these are use cases that somebody might reasonably one day build something
that's like this.  And then, having the discontinuity is a very bad choice to
create more confusing consensus rules, where they're already actually pretty
confusing and hard to get correct.

**Mark Erhardt**: Although, of course, if you're just giving away money in 512
blocks, you can just add an OP_NOP and make sure that your output script is
always 5 bytes.  You're giving money away anyway.  So, if you're paying a few
sats ents more for the transaction, that probably doesn't concern you.

**Jeremy Rubin**: The problem would be is if you're deciding that omission via
a covenant, then you need to write your covenant in order to introspect the
script length, and then you have to add a condition into that logic as well to
ensure that you can never enter a condition where you're expected to omit a
4-byte script.

**Mark Erhardt**: Well, you could make sure that your output script is always
at least 5 bytes and you will never hit this condition.

**Jeremy Rubin**: Yeah, it's just one more thing to check.  And that's also not
even the correct condition.  I mean, you can use that one, which I think is
part of what I was talking about earlier, where I said maybe I would prefer a
rule that said scripts have to be at least 5 bytes, because that's probably the
better place to apply the rule.  Otherwise, you introduce a new discontinuity,
which is that transactions vary what script size is allowable based on how many
outputs are in it.  So, there's just some trade-offs and I strongly prefer not
to introduce discontinuities.

**Mark Erhardt**: Talking about trade-offs maybe we should talk about your
suggestion how to fix the 64-byte transactions differently than forbidding the
64-byte transactions.

**Jeremy Rubin**: Okay.  Well, I think that there's been maybe some commentary
that this is a proposal that I'm really attached to or advancing.  Really,
where this came up is I have been taking a survey of current SPV (Simplified
Payment Verification) users.  I think that's important context, is the reason
to patch this is not because it introduces any problem, at least as far as I'm
aware, into Bitcoin Core or Bitcoin Core consensus or Bitcoin consensus in
general.  Really, this is a problem only for kind of very esoteric SPV use
cases where this confusion can come up.  And so, the rule that has been
proposed is to just eliminate 64-byte transactions.  An alternative rule, which
can also help, is to forbid internal nodes, from Bitcoin Core's perspective, of
the tree from colliding onto a valid transaction shape.  This would require
these SPV users to also enforce this rule.  If they did enforce it, then it
would protect them from misusing the merkle roots.  It has some theoretical
differences.  So, technically, with the 64-byte transaction ban, you can still
have interior nodes that look like transactions.  It's not particularly likely
that they are, and there are things you can do to defeat it, such as checking
that the outputs actually exist.  But every time you introduce a new thing you
have to check, that's sort of defeating the point of the original proposal to
remove 64-byte transactions, which is to silently patch all current SPV users.

So, you can think of it as there are two rules, one which is a rule looking to
the bottom, and the other is a rule from the bottom looking up.  The rule
looking to the bottom is forbidding 64-byte transactions.  The rule looking
from the bottom up is preventing any interior node from being a valid
transaction.  They are in some senses complimentary.  But the main difference
for if we were to actually enact this rule is that there might be some
adversarial cases where this might harm legacy miners who are un-upgraded,
because there's a new check that they have to apply.  The check itself is
actually relatively trivial.  I haven't benchmarked it, but it's a couple of
x86 opcodes.  So, it's really a very quick structural check.  Compared to the
hashing, it's essentially free.  And I mean, I can validate that with an
experiment, but it's really a trivial amount of additional checking.

But if you were un-upgraded, then there are two outcomes that can happen.  One
is there's a negligible probability that you mine a block and of all honestly
generated transactions, then there's just a negligible, and maybe not in the
cryptographic sense of the word negligible, but in like maybe it would take
millions of blocks in order for you to have this problem come up naturally.
So, you'd have to both be un-upgraded and mine a block, and you'd have to mine
millions of blocks in order to really see this problem for un-upgraded users.

**Mark Erhardt**: The problem which you hadn't said is that naturally, an inner
node would actually match the layout of a transaction.

**Jeremy Rubin**: Yes.  So, the natural interior node ends up looking like a
transaction case, I think can basically safely be ignored, where it's just
unlikely.  And then, the more troublesome one is that somebody would explicitly
grind a transaction that satisfies the right-hand side rule, which I think is
like 251 grinding, and then that would result in an invalid block being mined.
That one's a little bit more problematic.  Conduition, hand raised?

**Conduition**: Yeah.  I just had a minor philosophical question regarding
discontinuities.  So, you said you're a bit opposed to having discontinuities
in the situation where we're banning 64-byte transactions outright.  But by
this alternative proposal that you have, it also introduces a discontinuity,
just in a different location.  You're now creating a discontinuity where there
are certain merkle nodes that just aren't valid.  How do you square that?

**Jeremy Rubin**: So, that is also a good question.  I think that the rule that
I've proposed, one, and this is an important point, is it is a right-hand side
and left-hand side rule.  And so, if you were to make an unlucky transaction
just by virtue of whatever on the right-hand side, then a miner can always take
that right-hand side and put it next to a left-hand side that doesn't violate.
So, I just want to underscore that it doesn't introduce a new discontinuity for
transaction creators, as long as transactions can move about with some degree
of freedom within a block.  It does create a new sort of discontinuity in the
merkle root itself.  I think that the reason why that is preferable is that it
impacts a different class of user.  Impacting the class of all users who are
creating transactions is different than impacting the class of users who are
professional, essentially miners.  And I think that when you change what's
happening at the transaction layer, you're also impacting what's happening for
the miners.  When you change just what's happening for the miners, you're not
impacting users, you're not impacting scripting, you're not impacting all these
other things.

The other reason, which is maybe more of a moral case for it, is that this
problem is purely a problem that is rooted in the merkle root being bad, like
that we didn't design the merkle root correctly.  And so, if there is a
punishment, then the punishment goes to the thing that's messed up.  We're not
going to punish another part of the system that really already has enough
complicated rules.  We should leave that alone.  If really what we're doing is
patching over something that was broken, we should apply the patch close to the
problem.

**Conduition**: That's a fair assessment.  I feel like I can understand that.
You're saying that it's essentially a don't-break-use-space philosophy of,
okay, developers and miners, they should be able to know to apply this patch
and check for this particular discontinuity.  But users and wallet developers
of Bitcoin might not have the same level of resources.  So, okay, I can see
that.  Thank you.

**Jeremy Rubin**: Yeah, that's a good question, and I like the framing of,
"Don't break user space".  I think that the other thing that I would add is
that with respect to general, like, why is this even being discussed, it's kind
of important because who is the user who's benefiting from this?  And it's
really SPV clients, of which there are a couple of relatively important
deployed systems that are actually using SPV proofs.  So, from what I can tell,
the most used SPV system is probably Rootstock.  And they actually use the rule
that is in this BIP; they use a very similar rule to protect their systems.
This would be enforcing what they are already doing.  And then, there are some
other systems like Citrea, which is launched, potentially Alpen, and then
there's Electrum wallets as well, which would be the other class of system.  I
think that that covers almost all.  And then, there's like some things like
tBTC.  I think that they use one variant of the rules, I'm not sure which one
they use.  But there's only a handful of these SPV systems that are really out
in the wild right now, as far as we know.

This is why I was saying this is not really my main proposal, it's just
something that came up, is that there is actually an alternative rule that's
out there in the wild actually being used by one of these systems and has a set
of trade-offs, but it's not necessarily a bad set of trade-offs.  If I were
doing it anyway, what I would probably be doing is adding a different merkle
root inside of, let's say, the coinbase, which there's another footnote there.
But I would maybe add another merkle root inside the coinbase.  And then, I
would structure that one as a sparse merkle tree, or set a sparse merkle tree
keyed on interesting pieces of data, such as which outputs are being spent or
which addresses are having funds sent to.  Because that sort of merkle tree is
actually much more useful for these SPV clients than the current merkle root.
So, if it's something that's being done in service of SPV users, we can maybe
give them something better in any case.

**Mark Erhardt**: Right.  You said that this would benefit SPV users, and the
idea would be that SPV users could rely on any 64-byte inner node in the branch
being invalid if it matches a transaction layout.  However, they would still
need to check the inner nodes for that.  And if someone gave them a shorter
branch, that would still be able to confuse them.  On the other hand, if they
had to check for 64-byte stripped transactions, that would just always apply to
any transaction that is 64 bytes.  So, from a perspective of an SPV system,
could you please elaborate how this is an improvement?

**Jeremy Rubin**: Are you asking how this current role is an improvement, or
what I was just mentioning?

**Mark Erhardt**: Well, this is directly juxtaposed to the proposal in BIP54,
just forbidding 64-byte stripped transaction sizes.  So, I'm curious, how does
forbidding the inner nodes to match each valid transaction template benefit SPV
more than just forbidding 64-byte transactions?  Because all SPV clients
already have to calculate txids.  So, they certainly can get the stripped
transaction and calculate txids.  Counting the bytes is not particularly hard.
Checking merkle branches is probably more complicated than that.

**Jeremy Rubin**: Yeah.  So, I think that what I would say is that the
foundational idea that we can do something to protect users of buggy software
is probably just a bad idea.  And there are deployed SPV systems out there that
have mitigations against this problem already.  And also, the main one that had
this vulnerability has also been patched.  And so, really what we're being
asked to do is to assist, theoretically, someone's side project where they
write a naïve SPV proof and then don't know about this issue.

**Mark Erhardt**: But your argument was that people wouldn't know about the
64-byte for discontinuity, which would be a bug, right?

**Jeremy Rubin**: Yeah, so I mean in theory, any consensus rule can lead to
un-upgraded clients accepting invalid blocks.  That's a problem.  But I think
that the point that I'm trying to make is that in any case, the answer to buggy
software is not to make a breaking consensus change.  If you have buggy
software and there's a solution, then you should probably just use a solution
to that.  And I think we've seen deployed by layer 2 systems, both in their
protocol not having 64-byte transactions be meaningful or acknowledged, which
is an acceptable solution; and we've also seen deployed the path-checking rule,
which is also acceptable.  And so, I think that the idea of consensus enforcing
it to me is generally suspect at all.  I wrote this up as, well, I think that
the way that the 64-byte transaction rule has been pitched has been like this
is a foregone conclusion and this is the only thing that can solve this and we
need to do this to protect these SPV users.  I'm actually not really strongly
in favor of that at all, I'm just not in favor of removing 64-byte
transactions.

I don't know if that makes sense.  And I'm proposing this as an alternative of
this seems to be, to me at least, a reasonable burden, not on miners, I agree
it could be unreasonable for miners, but it seems to be a reasonable burden to
place on SPV users to write the software correctly.  At a certain level, you
have to say, "Write the software correctly".  Really, the reason to introduce
any new rule is that the trade-offs on writing it correctly are a little bit
too high, where it's either, like for the case of how Rootstock is implemented,
there is a real risk of somebody grinding to hide a transaction from Rootstock.
So, this would prevent an attack on Rootstock, for example.  So, if we're in
the business of protecting SPV users, then it would make sense to do a rule
that protects Rootstock, because they're a deployed system with capital.  I
don't know if there's a particularly exploitable thing on hiding a transaction
from them, because I think that at most, you can lose your own money.  But
maybe somebody could attack a user by grinding to hide their deposit, which
would be bad.

So, I think that generally what I would prefer though, and this is what I was
saying, is I would prefer actually just introducing a more useful merkle proof
for these systems.  And that seems to me to be a much better pathway that also
solves the problem.  And if you are really have your heart set on using
Bitcoin's merkle root, that's sort of your problem if we give a better tool to
use in general.

**Mark Erhardt**: Right.  Although if we're heavily relying on the SPV clients
to fix it for themselves, they could also, like as Eric proposes, just look at
the height of the coinbase transaction and not accept anything that isn't at
the same height as a valid transaction.

**Jeremy Rubin**: Yeah, so actually, for that to be secure, I believe you also
need to ban 64-byte coinbase transactions.

**Mark Erhardt**: I think we got that covered, at least for segwit blocks.

**Jeremy Rubin**: Yeah, at least for segwit blocks, correct.  But it's not
guaranteed that you'll have a block that's segwit.

**Mark Erhardt**: Right.  All right, let's wrap this up.  Do you have anything
else that you would like to share with the audience at the end of this topic?

**Jeremy Rubin**: Yeah.  I mean I guess I'd say, I still have that
knowledge-gathering one open.  I'm planning on leaving that thread open for a
while before trying to summarize it, and then propose an alternative
merklization.  Generally, I think I agree with what Sjors is saying, which is
that it just seems like the benefit of anything right now is not that high.
So, probably we should just drop that rule from the slate of activation, and I
think that that seems fine.  If we are going to do something though, eventually
I think it ends up looking like, we know in the long run that we're going to
have to replace the block header in some shape or form.  And so, I think that
thinking about alternative merklizations, whether fully deployed in the format
of new headers, that might be a little bit extreme, although there are some
ways of doing it that are provably low impact to miners, which maybe is a topic
for another week.  But you can also just have it as a commitment in the
coinbase, that has a cost of your proofs getting at least twice as long,
because you have to go to the coinbase and then to your other proof, which
might be annoying.  However, it amortizes because any transaction in that block
would have the same one.  So, it might be a reasonable trade-off, especially, I
think, SPV proof size is, at the end of the day, not a huge deal, given that
for a lot of these systems, they're using zero-knowledge proofs anyways, which
can condense a lot of the data.

So, if we're going to do something, that would really be my favorite approach,
would be to deliver a more useful SPV proof that can both prove other
properties and also doesn't have rough edges.

**Mark Erhardt**: Yeah, maybe we could just put the height of the merkle tree
somewhere that is easily retrievable.

**Jeremy Rubin**: That is the coinbase, that's where you can retrieve it from.

**Mark Erhardt**: Yeah.  Well, thank you for joining us and sharing your
perspective.

**Jeremy Rubin**: Thanks guys, bye.

**Mike Schmidt**: Thanks, Jeremy.  Cheers.  We do not have Gustavo this week.
So, Murch and I are going to tag-team the Releases as well as the Notable code
segment, starting with a handful of Bitcoin Core RCs, Murch?

_Bitcoin Core 31.1rc1_

_Bitcoin Core 30.3rc1_

_Bitcoin Core 29.4rc1_

**Mark Erhardt**: Yeah, we got a whole batch of them in the past week.  So,
there is Bitcoin Core 31.1rc1, Bitcoin Core 30.3Rrc1, Bitcoin Core 29.4rc1.
And I'm treating them as a batch because, well, all of them are maintenance
releases.  They just backport fixes to the last few major branches.  I have
said as much before, but in Bitcoin Core, we have two major releases per year,
one early April and one early October.  The major releases bring the new
features, and then there are maintenance releases that bump the minor version
that are issued as needed.

In this case, 31.1 brings us the fix for the -privatebroadcast issue, where in
really only deliberately-created circumstances, a node that claims to support
v2 transport downgrades the transport on a -privatebroadcast handshake, and
then the peer would reconnect, ignoring their proxy, and thereby reveal what IP
address they had.  We talked about this a few weeks ago.  This was discovered
after the risk of this brand new feature, and will be fixed with 31.1 there are
some other fixes.  I think most notable is maybe the chainstate compaction fix.
So, in 31 or maybe 30, I think in v30, we changed from flushing the UTXO
database once per day at least to once every hour.  And when we flushed the
database, the LevelDB would be compacted.  So, if there had been any slack or
unused space, it would sort of be, well, if you're as old as me and have ever
watched your Windows computer defragment your disk, you can think of it as sort
of like that for LevelDB.  And that would now trigger every hour and recompact
the entire UTXO LevelDB under certain circumstances.  So, there's a fix in 31,
and this fix is also backported to 30.3 and 29.  And yeah, there are a few
other smaller fixes that are being backported.

If you are using any of these major branches, please take your time to review
the RC.  We would always love for downstream projects that rely on Bitcoin Core
to throw it into their development or testing framework and tell us if there's
any issues for them.  Read the release notes for all the details.  And other
than that, they should be out in a few weeks, probably a week or two.

_Core Lightning v26.06.2_

**Mike Schmidt**: We have some Lightning-related releases here.  Core Lightning
#26062, this is a maintenance release for Core Lightning (CLN).  And what we
pulled out to note was the cln-currencyrate plugin.  If you were using that on
a minimal operating system, or some sort of a minimal Docker setup and you did
not have TLS root certificates installed, you would have some failing related
to that when doing the lookup, because you couldn't actually reach out to that
currency rate site to get the information because you didn't have the root
certificate.  So, there's a fix for that pretty small one there.

_LND v0.20.2-beta.rc1_

Also have LND v0.20.2-beta.rc1 and LND v0.21.1-beta.  These two releases share
many of the same fixes, and I'll note where the 21.1 beta differs.  But there's
a fix for a DNS fallback issue that caused a panic in LND.  So, LND has this
fallback path that can look up a peer via a DNS SRV record.  But there were
some assumptions baked into that code, and it could result in an outright crash
when those certain casting happened internally.  So, that's fixed.  There is a
fix for the onchain forward-interceptor settlement bug.  This is part of LND's
API that lets external applications hold and decide about an HTLC (Hash Time
Locked Contract) parsing through a node.  The situation was if the incoming
channel force closed while that forward was being held, that settlement could
actually get, I guess you could say, stranded, and that held forward was
tracked as an offchain entry.  And there was no way for the onchain version of
that HTLC to replace it.  So, there was a fix for that.  Those were in both
versions.

_LND v0.21.1-beta_

Then, there is a Tor v3 fix in the 0.21.1 beta.  This is where you would start
a fresh LND node with the Tor active, Tor v3.  And that could actually fail to
create the onion service at all.  And the internal root cause there was that
LND was still resolving an older version of that Tor module.  And so, that's
been fixed.  And both releases also ship with a tightened-up final-hop HTLC
CLTV (OP_CHECKLOCKTIMEVERIFY) expiry.  And we'll get to that in the code
section below, since we dug into that in the Notable code segment.

_LDK v0.2.4_

Finally, we have LDK v0.2.4, which is a maintenance release and it's another
narrow fix here.  It fixes a regression in 0.2.3 that accidentally,
unintentionally raised the minimum supported Rust version for the Lightning
Crate.  And that matters because LDK commits to compiling with rustc 1.63, a
deliberately older compiler version, so that other projects can keep building
without being forced to upgrade their compiler.  And then 0.2.3 accidentally
broke that sort of promise unintentionally.  But v0.2.4 restores that
compatibility and allows you to use those older rustc versions.

Notable code and documentation changes.  We have a handful of Bitcoin Core and
BIPs ones that Mirch is going to walk us through, and then I'll wrap up with a
couple of Lightning PRs.

_Bitcoin Core #35266_

**Mark Erhardt**: All right, we're starting with Bitcoin Core PR #35266.  This
adds a load_wallet argument that defaults to true to the migratewallet RPC.
So, the migratewallet RPC will convert a legacy wallet to a descriptor wallet.
And the load_wallet argument is especially useful if you're trying to migrate a
legacy wallet on a pruned node who has already pruned the nodes below the
wallet's birthday, and loading would therefore require those blocks to be
present.  So, with load_wallet faults, you can migrate the wallet to a
descriptor wallet and not automatically load it at the end of the migration,
which then will succeed; whereas a migratewallet with a wallet of which the
birthday is already pruned would usually fail to load, and therefore not be
allowed to migrate.

_Bitcoin Core #35550_

We move on to the Bitcoin Core PR #35550.  This updates the compact block relay
negotiation.  And when you send the send this compact message, which tells your
peers that you accept compact blocks, you would usually expect a Boolean field
to only have the values 0 and 1, and this is also specced in that manner.  But
Bitcoin Core used to accept any value in this field, because it was just
treating it as a C++ Boolean.  So, other true C values, like any positive
value, would also be treated as one.  Now Bitcoin Core, in the upcoming
release, it will disallow any other value than 0 and 1.  So, it tightens up the
interpretation of the sendcmpct field in the feature negotiation during the
handshake.

_Bitcoin Core #35610_

Bitcoin Core PR #35610 adds a netmagic command to bitcoin-util.  Maybe if
you're not aware, bitcoin-util is a small, I think, library that is shipped
with Bitcoin if you do the full install, and allows you to sort of do stuff
with your Bitcoin nodes' data.  In this case, the netmagic command will print
the 4-byte network identifier, and that allows you to realize what network your
node is currently following.  So, the network magic is the 4 bytes that are
prefixed to any P2P messages, and this would, for example, point out if you're
on a custom signet or testnet or mainnet.  So, if you use the netmagic command,
this allows you to select the correct directory before starting bitcoind.

**Mike Schmidt**: Murch, quick question.  What's a rough heuristic as to what
gets in the bitcoin-utils versus elsewhere?

**Mark Erhardt**: Honestly, I'm not very familiar.

**Mike Schmidt**: Okay, I wasn't either.

**Mark Erhardt**: This is left as an exercise to the listener!

**Mike Schmidt**: All right, there you go.  Maybe a Stack Exchange question can
come up.

_BIPs #2196_

**Mark Erhardt**: Sure.  Maybe someone will research it and write an answer,
and that might not be me.  Okay, we've also got a few BIPs PRs for you.  The
BIPs PR #2196 adds BIP95.  And if you've been paying close attention, you might
remember that BIP94 is testnet44 or colloquially called 'forknet4'.  BIP95
proposes testnet5.  So, we do that thing where we create a new testnet that
developers might use to test new features on testnet, especially mining
features, which you can't test on signet.  And then, some people ruin this
common good, per the tragedy of the commons, by monetizing testnet coins and
mining blocks with the difficulty exception, and so on.  And then, we put out a
new testnet and I think testnets will continue until testnets are useful or we
give up fully on them.

But so, testnet5 tries yet another set of trade-offs compared to testnet4.  In
testnet4, we fixed block storm attacks by using the first block in a difficulty
period as basis for the difficulty adjustment, because the 0th block, I should
say, or 1st block, is exempt from the 20-minute exception, so it cannot be
mined at the minimum difficulty.  But it still had the difficulty exception,
which then caused people to just, as soon as a block was mined with the actual
timestamp and real PoW, mine six more blocks, spacing them 20 minutes into the
future, 40 minutes into the future, 60 minutes in the future, 80 minutes in the
future, 100 minutes in the future, and 120 minutes in the future, with minimum
difficulty.  And because so many people were doing that at the same time, we
would get a vast branching on every real PoW block in testnet4 and constant
reorgs.  So, in testnet5, we get rid of the difficulty exception altogether.

Testnet 5 is therefore more closely related to mainnet, in the sense that it
has only real PoW blocks and only allows blocks to be mined at the actual PoW,
although that will probably be lower than on mainnet.  Otherwise, that would
make very little sense to spend so much money on it.  The minimum difficulty is
also raised.  So, instead of starting at a minimum difficulty of 1, which
previous testnets used, which is almost trivial even on thin laptops or
something, it starts with a minimum difficulty of, I think, a little over a
million.  It is not 220.  But anyway, a little over a million, so a million
times more difficult than difficulty 1.  And it also enforces the BIP54
consensus cleanup rules from block 1.  So, the idea is that testnet5 will be
able to be used by miners to check whether they are compatible with BIP54,
should BIP54 get more momentum towards activation.

There is a new network magic, which we just talked about, which is derived from
the hexadecimal representation of the word 'five', and it has a new port.
Please see the details in the newsletter.  I'm not going to read them out to
you yet.

_BIPs #2165_

BIP's PR 2165 updates BIP52.  BIP52 was a hard fork proposal that changed
Bitcoin to an Optical Proof-of-Work system that was proposed, I think, about
five years ago.  So, I had been working a little bit on looking through old BIP
drafts, so BIPs that had been published in draft status, but haven't really
made significant progress since then.  BIP52 was one of the ones that I was
unable to get a hold of the authors.  I had reached out to them directly, and
then also on the mailing list, and it seems to be abandoned.  So, it was pushed
to closed.  And we're hopefully going to also look through a few more of the
open BIP drafts.  There are a few that just have been open forever and don't
seem to make progress.  The idea is that BIPs for which the specification is
essentially complete and the authors have finished all the planned work, and
they are still thinking about those BIPs potentially being adopted in the
future, those should probably be moved from draft to complete; whereas BIP
drafts that are abandoned should probably be closed, so readers of the
repository know that they don't have to pay too much attention to those BIPs.
So, BIP52 was the first one that we closed in this initiative, but hopefully
I'll get around to looking at a few more of those.

**Mike Schmidt**: More coming soon then?

**Mark Erhardt**: Well, this is maybe also something that prospective BIP
editor candidates, or anyone else that's interested in learning a little bit
about what BIPs exist, could help with.  You could look through the BIP drafts,
especially the ones that have been open for a while, and open a PR to propose
some to be moved to complete or closed, depending on your read of the
situation.  That doesn't have to be work that only BIP editors can do.

**Mike Schmidt**: Sounds good.

_BIPs #2201_

**Mark Erhardt**: All right.  We have a third BIPs PR, and that is #2201.  This
one advances BIP110, the Reduced Data Temporary Softfork proposal, from draft
status to complete status.  And I think that's high time, because obviously
they are trying to perform their mandatory signaling period next month.  So, it
might be good to actually show that their BIP is complete and no longer subject
to planned work.  Yeah, I think you have probably read as much or as little
about BIP110 on the social media platforms that are discussing it lately, so
let's just leave it at there were no changes to the specification.  This is
just moving the BIP to the complete status, as in signaling that the planned
work is finished.  It also linked test vectors and reference implementation,
which I think hadn't been linked before.

_LND #10900_

**Mike Schmidt**: Moving to our Lightning PRs, we have LND #10900, which adds
an RPC for submitting packages.  That's both in the RPC and lncli wallet.  This
allows users to submit a 1p1c (one-parent-one-child) transaction package to
LND's backend.  With LND, you can have a bitcoind backend, but you can have
other backends as well.  If you have a bitcoind backend, then LND will forward
that package to Bitcoin Core's submitpackage RPC, which obviously is
advantageous for Lightning to have these sorts of transactions, because you've
got to have a zero-fee v3 parent with an ephemeral anchor to be accepted
together with its fee-paying CPFP child.  The other backends, if you're not
using bitcoind, if you're using btcd, for example, these functions will return
something like unimplemented; and neutrino, if you have a neutrino backend,
will just broadcast the transactions individually, which may have varying
degrees of success, depending on the details.  So, good to see LND implementing
some of the 1p1c stuff.

_LND #10927_

Next PR, also to LND, this is LND #10927.  This fixes an issue where a sender
could potentially tie up a receiver's funds for much longer than the receiver
actually agreed to.  This is because with Lightning HTLCs, there is a CLTV
expiry, which is a block height sort of deadline after which the payment
attempt can actually be reclaimed, and the nodes can set different policies
limiting how far in the future those deadlines can be.  Because pending HTLCs
lock up liquidity, you want to make sure that you manage those expiries versus
your liquidity preferences.  But the issue was that those policy limits were
enforced in LND on forwarding hops, so hops along the path, but not actually on
the final hop would be the recipient.  So, the sender could actually construct
a payment, and then that final hop HTLC could have an expiry that was very far
in the future, for example, and that receiving node would accept it, and that
would end up locking the receiver's channel funds for much longer than what
their policy had articulated.

So, the fix is now that LND will reject those final HTLCs if the expiry falls
outside of the receiver's policy, and there'll be a failback message.  So,
essentially fixing, I guess, a bug, so good to see that that's fixed.  That was
also the item that was referenced in the two LND releases earlier that we
discussed in the newsletter.

_LDK #4748 and #4751_

And last PR/PRs, both to LDK.  This is #4748 and #4751, which we bundled
together in this Notable code item.  There are two fixes for splicing, I guess
you could say edge cases, where a message receives at a sort of awkward or
inopportune moment.  The #4748, this is a fix for a splice potentially getting
stuck.  So, when there is a completing splice, LDK actually waits for its own
internal bookkeeping to be safely written to disk before moving forward, which
makes sense.  But the bug was it was actually waiting on any pending
bookkeeping write, even ones that were totally unrelated to the splice.  So,
this could actually result in LDK blocking the splice from completing for no
good reason.  So, the fix in this #4748 is that now LDK will only wait when the
pending write is the one the splice actually depends on.

Then, the second fix, which is #4751, is related to a stale signature force
closing, and this is force closing a healthy channel.  So, the scenario here is
you're LDK, you start contributing funds to a splice, and then cancel your
contribution.  But the peer signature for the now canceled version was actually
already in flight and arrives after your cancellation.  But the bug is that LDK
would try to validate that signature against the splice version that no longer
exists, which would result in a failure and then potentially force close that
perfectly healthy-otherwise channel.  So, now LDK will check which funding
transaction the signature actually refers to, using one of the fields in the
message, and then it'll ignore signatures for stale or splice versions.

That wraps up the newsletter.  We want to thank Conduition and Jeremy Rubin for
joining us to talk through the Changing consensus monthly segment this week.
We also want to thank our co-host, Murch, and for you all for listening.  And
we look forward to having Gustavo back next week.  Cheers.

**Mark Erhardt**: Cheers.  Thanks for your time.

{% include references.md %}
