---
title: 'Bitcoin Optech Newsletter #303 Recap Podcast'
permalink: /en/podcast/2024/05/21/
reference: /en/newsletters/2024/05/17/
name: 2024-05-21-recap
slug: 2024-05-21-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Adam Gibson to discuss
[Newsletter #303]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-4-21/378330152-44100-2-30a0fab7bad26.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #303 Recap on
Twitter Spaces.  Today, we're going to talk about an idea of anonymous usage
tokens, BIP39 seed phrase splitting using paper computation, BitVMX white paper,
discussion around improvements to the BIP process, and our regular Releases and
Notable code segments.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.  I've become recently
a BIP editor, which is consuming lots of my day.

**Mike Schmidt**: Waxwing?

**Adam Gibson**: Oh, hi, yeah.  So, I'm Waxwing.  Adam Gibson is my real name.
I do various things, coinjoin stuff, cryptography stuff, related to Bitcoin and
so on.

**Mike Schmidt**: Thank you for joining us this week, Adam.  As some of you may
notice, it's Tuesday and not Thursday.  We're messing around with the
publication schedule a little bit to ensure that all contributors to the
newsletter have an optimal week setup.  So, we're looking at potentially
publishing on Fridays moving forward, which would mean that we would adjust the
podcast or the Twitter Space time also.  This is the first week that we're doing
it with a new schedule.  I'm not sure we'll do Tuesday, Murch and I will talk.
We may end up doing Monday, but I could not do it yesterday.  So, for this week
at least, we're doing Tuesday.  Thanks for bearing with us as we move things
around a little bit.  Murch, anything to say on that before we jump in?

**Mark Erhardt**: Well, no.  I'm fine with a different day because there's a
regular event on Thursdays that I would like to avoid!

_Anonymous usage tokens_

**Mike Schmidt**: Jumping into the newsletter, we have the News section first.
First news item, Anonymous usage tokens.  Adam, you posted to Delving Bitcoin
about some research you've been working on for some time, it looks like, around
the best way to have a private proof of pubkey ownership.  Maybe, Adam, you
could talk a little bit about that research in relation to the JoinMarket
project, and then maybe we can get into other applications of this idea.

**Adam Gibson**: Sure, thanks.  Yeah, so what's the condensed history here?
Basically, since the early day of the JoinMarket, which is a coinjoin protocol
where there isn't a central server, so there isn't a natural way to block out
bad actors in the form of trying to swamp the system with too many requests, or
bad actors in the form of using such swamping the system to sort of de-anonymize
coinjoins or find out information.  Yes, so we have to try to find ways to
address that.

One of the earliest ways we did was called PoDLE, which was more commonly known
as a Discrete Log Equivalence proof, or at least it was using that construct.
To give the sort of non-mathematical description there, what we were doing was
taking somebody who had a UTXO and blinding that UTXO with a cryptographic
mechanism, and then publishing that blinded form, and that's a mechanism.
Although it was quite weak, it had the value of making it difficult for people
to spam the system with millions of requests, because UTXOs are a somewhat
scarce resource, and we'll come back to that point.  Then later on, we were
thinking about, well, how can we make it so that somebody can't very easily
swamp the system with lots of what we call makers, so that they could be most of
the participants in each coinjoin.  Again, this is a problem that all similar
coinjoin protocols have, and we came up with Fidelity Bonds.  That was Chris
Belcher's specific invention, or let's say he developed it.  That was effective
in a way, but it had a big negative.  Well, it had a couple of negatives, but
the biggest negative was the fact that the UTXOs had to be published, had to be
announced, and this is very analogous to what you see in LN channel
announcement, where you have to publish the actual real UTXO that you're using
for a channel to announce the channel, which is poor for privacy.  I'm going to
stop a minute.  Just let me know how you want me to continue, because I can talk
about this for about seven hours, but we don't have seven hours.

**Mike Schmidt**: No, so far so good, keep going.

**Adam Gibson**: Okay.  Well, okay, so the next sort of part of the story is
around 2022, I published a blog that I called RIDDLE, which just stands for Ring
signature-based Identities using Discrete Log Equivalence.  And so, it was like
an extension of those earlier ideas, where I said if we have a set of public
keys, whether it be 100 or 1,000, we could form a ring signature using them,
attach a linking tag, very similar or indeed almost identical to what Monero
does.  And by doing that, you have a situation where you could, at least for
some kinds of systems where there's a service being offered and you want to
avoid being swamped with millions of requests, but at the same time you don't
want to de-anonymize your user, a ring signature might be a good solution to
that because they could publish a ring signature over, let's say, taproot UTXOs,
where the public key is exposed on-chain; and they could say, "Look, I own one
of these UTXOs, but I'm not telling you which one".  So, that was the idea.

I investigated that idea for quite a long time, looking at various different
constructs, the original Yu Wei Wong paper; there was a paper by Jens Groth in
2014, where he proposed a more compact version of these proofs; there's all the
work done by the Monero Research Lab, they've done a lot of things.  And one of
the things they did was extend Jens Groth's 2014 paper into something they
called Triptych.  I eventually landed on that as the best version of a ring
signature solution to this problem.  So, it's a long story and I've already gone
about it too long, but basically all of that research was interesting and
valuable, but it tripped up on the fact that if I wanted to extend the anonymity
set to much larger sizes, which I think are probably practically necessary,
which we'll get into in a minute, these ring signatures don't quite cut it.  And
the reason they don't quite cut it is because all of them by nature have this
problem that the verifier -- so remember in these cryptographic protocols you
have a proof, you generate a proof, you publish a proof, and then somebody, a
service provider or something, is going to verify whether that proof is real or
not.

When you verify a ring signature proof, the problem is that you have to kind of
unroll the contents of the ring signature, and to put it crudely, the verifier
has to examine a set of objects which is the same size as the original ring.
So, even if you're clever about how you publish the proof and you get it down
to, let's say, I don't know, a few hundred bytes or a kilobyte for a ring
signature of size 1,000, that's great, but it doesn't help if the verifier then
has to spend multiple seconds -- or let's say if the verification time is linear
in the size of the ring, which is essentially the problem I've had with all of
those constructions.  And that, by the way, I can't speak to it exactly because
I'm not a developer in that field, but that is probably why Monero has limited
anonymity sets.  It started off with three or four and it moved up to seven,
ten, fifteen, I don't exactly know where it is today, but they're now
researching, just as I have, a more advanced idea.

So, the problem there is, okay, if the verification of this, let's say, call it
a zero-knowledge proof that I own one key out of a set of keys, if that
verification is linear in the size of the set, we might be able to do an
anonymity set of 1,000, but we can't do an anonymity set of 1 million, it's just
not going to be practical.  So, the new idea here is curve trees, which was
published in 2022.  And basically, I'm going to explain some of it, but I don't
want to explain too much because I'll run out of time.  Basically, there's a
structure there that allows you to make the verification of the proof that you
own one of a set of public keys be sublinear.  And more specifically, it's
logarithmic, more or less, with some caveats, so extra dangling terms, let's
say.  It's basically logarithmic in the size of the set, so it means that I can
make a proof that I own one of 250,000 taproot public keys on mainnet, which can
be verified in a very short time, like approximately 50 milliseconds of that
order.  So, that's kind of the start of the story, but let me stop again there
and please ask questions.

**Mark Erhardt**: Yeah, I have a question.  So, that sounds really cool, the
sublinear set.  My understanding is that the main point that you're trying to
achieve with this is that you can make the proof non-reusable.  So, if you prove
that you have a UTXO, you can only make a single use of it without people
noticing, "Oh, they used the same UTXO for something else already", is that
right?

**Adam Gibson**: That is exactly correct.  And that part of it is like, that's
the only part that I added into it, because basically I'm using a library that
was generated by the paper authors, and I'm sort of actually using it in a
concrete use case.  But I had to add in that specific feature that you just
mentioned.  So, to go back momentarily to ring signatures, if you think about
how Monero works, they publish a ring signature over a set of unspent coins, but
they have to attach what they call a key image, sometimes known as a linking
tag, and that is a natural part of what's called the LSAG, the Linkable
Spontaneous Anonymous Group signature, of which the Monero thing is an example
of.  And so, you publish the proof, but then you publish this extra 32-byte tag.
It's actually a curve point in reality.  And if that person wanted to make
another ring signature, equally private as before, where it wasn't giving away
which of the UTXOs was theirs, they would unfortunately have to provide the same
linking tag, so that the system would reject that as a double spend, even though
it doesn't know which coin was attempting to be double spent, if you see what I
mean.

So, the same principle applies here, of course.  So, if I want to prove that I
own one public key out of 250,000 taproot UTXOs, great.  But if I want to
enforce scarcity, and there may be some applications where you don't need
scarcity; but if I'm thinking, for example, of channel announcement in LN, then
there's no point in trying -- if I want to enforce any scarcity, if I want to
prevent people just making an announcement a billion times with the same UTXO, I
have to do the same thing.  And so, what I added to what the curve trees paper
already had, I added a little sort of linked zero-knowledge proof that the
blinded key which they're asserting is part of the set, it has not been used
before because it has a linking tag which would always be the same every time
you used it.

**Mark Erhardt**: Awesome.  I seem to remember dimly that Zcash scheme proof,
that you hadn't used a UTXO twice, was also based on trees, merkle trees, I
think.  Is it related to that at all?

**Adam Gibson**: It's definitely based on an accumulator, but I'm a little bit
out of my depth there.  I know that it's part of that set of zero-knowledge
proving systems, which I think Groth16 was the kind of precursor of all of them,
but the basic idea is that you're using bilinear pairings and you're using
what's called a trusted setup.  So, there's obviously some negatives there.
Even worse, I think the original version of that scheme had the problem that you
had to have a trusted setup per circuit, so to speak.  So, you have some
complicated logic you want to enforce in a circuit in zero knowledge, but you
have to have a set up ceremony, as they called it, to make it so that those
proofs would be valid.  And the point of the ceremony is to get rid of what they
call the toxic waste.  So, you have to get rid of essentially the private key
material and make sure that nobody knows it, which is obviously a very awkward
thing to do, which kind of ties into another point about this.

So, curve trees, a little bit of technical information about it is, think of a
merkle tree.  I think everyone here is going to be familiar, at least aware, of
what a merkle tree is.  And you have a proof that a certain thing is inside a
merkle tree, and that's logarithmic in size, and that's the source of the trick.
That's the trick that allows us to get a logarithmic verification time in the
system.  But the difference is that we're not using an actual merkle tree as
normally understood.  What we're doing is we're using something called Pedersen
hashing.  So, think of a Pedersen commitment to, you've got your private key,
you've got the corresponding public key, you blind it, and then that creates a
new curve point, and we could call that a Pedersen commitment.  You can also
think of that as a kind of Pedersen hashing, in the sense that the input would
be your private key and the output is a curve point.

We build a tree, which I've sort of crudely called in the past, algebraic
version of a merkle tree, because basically you're able to take multiple curve
points, add them together and create an output, and that output can then be used
as if it were an input to another Pedersen hash.  And this is the most
technically sort of weird and difficult point, is that normally when you do SHA2
hashing, you input in some data.  And as we know, the input space is huge, but
let's say it could be 64 bytes or 32 bytes.  And then you could take the output
of that being 32 bytes and hash together, concatenate together two hash outputs,
and then use that as input to another hash, right?  And that's how merkle trees,
at least in Bitcoin, work, the binary tree structure.  You can't do that
directly with curve points with a Pedersen hash, because the input is coming
from the scalar field.  I mean, think of the scalar field as a set of private
keys, and the output is the set of curve points, and those are two different
objects.  So, you can't use the output from one such Pedersen hash as the input
to another Pedersen hash.

But the really brilliant trick that has been come up with by various
investigations over the years is that we can use what are called cycles of curve
trees.  And in particular, with Bitcoin secp256k1, we can use a two cycle, a
cycle of two curves.  So, we can alternate between secp256k1 and secq256k1.  And
what secq256k1 is, it's very simply the same equation, so y<sup>2</sup> =
x<sup>3</sup> + 7, but it's modulo a different prime.  And the curious fact is
secq, the order of the scalar field of secq, is equal to the order of what's
called the finite field of secp.  In other words, to put it in non-mathematical
language, the size of the set of possible private keys of secp256k1, the scalar
field, is equal to the size of the set of possible coordinates of secq256k1, and
vice versa.  What that means is, if we think of a Pedersen hash for secp and a
Pedersen hash for secq, it has the property that the input space of one is the
output space of the other and vice versa, and that allows us to build a kind of
tower of hashes in the same way as we do with a traditional merkle tree using
SHA2.

Now, the purpose of all of that in itself wouldn't be that interesting.  Okay,
you could build a new kind of tree using Pedersen hashes instead of SHA2, but
the value of it is that because they're curve points and the scalars on these
fields, we can build bulletproofs-style, or we can build arithmetic circuits and
prove in zero-knowledge using bulletproofs that a member of the set is included
in the tree represented by the root that you're given.  Is this making sense at
all?

**Mark Erhardt**: Mostly, yes.  I'm not sure I've understood all the details,
but I think I get the rough gist.  So, you get around not being able to use the
output of your hash function by inserting it into a different curve, which is
the sister curve, so to speak, of secp.

**Adam Gibson**: Yes.

**Mark Erhardt**: And that makes it return a curve point again on the -- well,
it sort of alternates, yes.  And that gives you a mechanism like the
concatenation in the merkle tree.  So, maybe let me go back to a more abstract
level.  So, one is you have found a way to prevent reusing the proof by having a
commitment to the public key, which means if someone else used the same public
key again, they would show up as a double user.

**Adam Gibson**: Yeah, especially 32-byte tag, which would be the same, yeah,
which you would see it.

**Mark Erhardt**: So, this also prevents address reuse for commitments, which I
think is very nice!

**Adam Gibson**: Yeah, it makes address reuse -- well, I think most of us in the
more theoretical side of things just ignore address reuse, right, we just say
that's not --

**Mark Erhardt**: Yeah, but here's an actual incentive not to address reuse,
which is cool.

**Adam Gibson**: Yeah, it's a pretty minor one, but yes.

**Mark Erhardt**: Okay, so the other big question is, especially with LN
channels, obviously you have to prove that the output exists.  How do you ensure
that the output continues to exist?  Is that just by the virtue of it being
co-owned by your channel partner?

**Adam Gibson**: No, I think you've hit there upon a very important point and
possibly a limitation of this approach, which is that obviously you can't do
that.  I mean, you can go in a completely different direction and start thinking
about locked UTXOs, but that's a different direction.  No, I mean, it's one of
the reasons why I wouldn't jump to the conclusion that this, although it's very
powerful in terms of its ability to create large anonymity sets, it doesn't
solve every problem directly where sibling is an issue.  So, there are things
you can do.  Let's think practically about how I might use this to create a
proof that I own one of the current, actually, 160 million-plus taproot UTXOs,
by the way.  But if you look at where they all sit, most of them of course are
very dusty and they're related to let's say non-monetary use cases.

So, the first thing you think about, well, I'm only obviously I'm interested in
UTXOs above a certain threshold of value, right?  For example, you might say,
like I did on my little -- I made a little proof-of-concept website, called it
Hodlboard, where you can only sign up if you've got a proof like this.  But I
said it has to be 500,000 sats minimum.  And by setting up a filter like that,
you might end up with a number like, well, in total, there's 250,000; well, it
was around that number, 250,000 UTXOs of that size or larger, which are of
taproot type.  And then of course, that's not the only limit you could enforce.
You could also enforce an age limit, which I think is very interesting for
anti-sybil property.  So, you could say the UTXO has to be at least, for
example, I don't know, four days old, or however many blocks that is, 1,000
blocks, I don't know, some number.  That way, what that gives you is that gives
you an ability to help restrict a very fast attack.  I think I use the phrase,
"burst attacks" in some places to describe what this is particularly good for
avoiding.

Now what it's less good for avoiding, I don't really know exactly, is sort of a
more slow, long-term thing, because a person who is generating UTXOs sure incurs
the cost of a transaction fee, but that's very small and it can be even
ameliorated in some cases depending on their use case, right?  So, I don't know,
I see it as a way of preventing large-scale types of burst-type attacks.  It may
still have a use in the case where, for example, Fidelity bonds in JoinMarket
are generally quite large-size UTXOs that are held for very long periods.  Maybe
you can alter the value of such an anonymous usage token by varying it with both
the amount and the age.  That's something I've thought about.  But yeah, if your
concern is that, "Oh, I'm announcing an LN channel", but I can then create a new
UTXO, so announce another LN channel, then I agree, it doesn't really completely
solve that problem, at least not in itself.

**Mark Erhardt**: Right, so if two people together announce a channel, obviously
the counterparty wouldn't proceed with a channel announcement for a UTXO that
doesn't exist.  And moving coins would mean that channel announcements, or
rebroadcasts, would stop because the counterparty isn't there anymore.  However,
if you are both sides of the channel, or just own a UTXO, you could continue to
move your UTXO around and announce a new channel every four days.  So, you could
stuff the tree, but only with UTXOs where either the counterparty is
collaborating or you are both sides of the channel.  So, that seems pretty
benign, at least a big improvement over previous.  Back to you.

**Mike Schmidt**: Anything more to say there, Waxwing?  I put you on mute while
Murch was talking, there was some feedback.

**Adam Gibson**: Sorry, my bad.  Yeah, I was just trying to interrupt, and then
I thought, "Oh, am I being rude?"!  Yeah, I see.  So, I wanted to say that
there's an interesting thing about the Optech Newsletter description that I only
noticed this morning when I read it more carefully, which is that it's
emphasizing this sort of anti-sybil mechanism, but actually my motivation here
is much more on the privacy side, because I feel like one of the biggest
weaknesses of LN's current design, and a lot of people were commenting about it
in the early days, was, "Oh, but I have to announce my UTXO, right?"  And I feel
like that's, yes, there is an anti-sybil property here that we obviously are
going to need if we can make the announcement anonymous, but the ability to make
the announcement anonymous at all is really, really important to me.  It's like
the other side of the coin, right, the deep problem, how do you have people
joining services or joining P2P networks purely anonymously without massive
problems of sybil attacks?

So, yeah, it might not be the perfect solution to that, but I think with some
inventiveness it could be a good one.  The point is that on the other side of
that difficult dichotomy, the privacy side of it, it really beats everything
else out of the water, I think, or at least it could, because it has that
property that, not quite like the Zcash level of literally any coin I could be
spending, but here I could be referring to basically any coin within a
reasonable range.  So, I'm sort of emphasizing that side of it, but I admit that
the fact that, and I kind of addressed this a little bit when I described the
RIDDLE mechanism a couple of years ago in that blog which was, I might ask, "Is
this really providing much scarcity if somebody can create the UTXO and then
immediately spend it and then create another UTXO?"  And I think the devil's in
the details.

**Mark Erhardt**: Yeah, so there's a devil in the details here, but also it
would significantly change the channel opening mechanism if your UTXO had to be
at least four days old before you could announce the channel.  Maybe that would
be not that much of a problem in combination with swap-in-potentiam, where
people just gratuitously receive to a shared pubkey with their LSP, and then
only splice in in the case that they have temporary channels until the timeout.
Sorry, I'm getting a feedback again from you.  You jump in, though, any time.

**Adam Gibson**: Sorry, that was me, I'll turn off next time.  My bad.  Sorry,
yeah, I just wanted to say that, yeah, some of the things you were saying there
about swap-in-potentiam, I don't actually know the details of all that stuff,
but I just did want to mention something that really occurred to me last night
when I was mulling over how I was going to explain this.  I just suddenly
realized that this is yet another example where I can sit here in my ivory tower
and tell you all about the one million anonymity set and everyone's like,
"Wow!", you know.  But let's actually talk about the reality, which would be
very interesting building a little proof-of-concept website, because it showed
me some of the practical problems here.  Here's the practical problems.

If somebody wants to sign up for my forum by proving that they hold, what is it,
500,000 sats, they can't just click a button on their wallet to state the
obvious, right?  I mean, first of all, how many of us have wallets which have
taproot enabled?  It turned out when I looked at it, I could only realistically
see two, which are Bitcoin Core, obviously, and Sparrow, and that's the first
problem.  And then the second problem was, well, in order to create this
zero-knowledge proof, I have to input the private key.  Well, then I need the
private key of one of the UTXOs in my wallet.  And then I discovered that
basically all wallets, even like other wallets, not Sparrow or Core, basically
all of them have gone down the road of completely preventing users from
accessing private keys directly, which from a security point of view, is a very
logical thing to do.  But it means that if you read the instructions on my
website on how to create the proof, it's absurdly complicated.  Even on core,
you have to go through four different steps.  Sparrow's a bit easier, but that
illustrates the point that if you say this has an anonymity set of X
theoretically, the practical reality depends on how plausible or even possible
it is for anyone else to have done what you've just done.

So, if it was the case, for example, here's a concrete realistic scenario.  LN
node developers implement this system.  When you start up a new LN node, you're
going to gossip your channel using one of these zero-knowledge proofs, which
means you're going to need a UTXO.  But unless you can import a taproot wallet
from outside, then it'll be pretty obvious that the UTXO that you've just
created, because you just created an LN node, and so you probably just created
the onchain wallet, you probably just funded it, and then you created the
zero-knowledge proof with that specific UTXO which you just created, and then
you publish the proof, so it doesn't take a genius to figure out, "Oh, that
proof is probably one of the more recent UTXOs and not one of the very old
ones".  Sorry, I've blethered a bit, but maybe that's an interesting thought.

**Mark Erhardt**: Yeah, so there are 48 million P2TR outputs now, but a ton of
them are super-small because they were created by inscriptions, or holding
inscriptions or ordinals, or whatever.  So, they're actually not of a size that
would help any of the LN channels to hide amongst.  And if you announce it
immediately the moment you open a new LN channel, I think that at least LND also
has taproot already, I guess because they're working on taproot assets, and so,
yeah, it would have to be used broadly for it to actually have any sort of
anonymizing effect among the UTXOs, because you'd have to have many of them
being opened in the recent time.  Or you delay your announcement of a new
channel randomly by something like a day, so up to a day in the range of two
days, so you at least hide among all the large P2TR outputs in the last couple
of days.  Something like that might help, but that would of course make it a
much less satisfactory UX.

**Adam Gibson**: Can I just ask, you said 48 million; about two months ago, I
recorded 160 million and then I recorded again like 180 million P2TR outputs,
and I recorded about 250,000 taproot outputs above 500,000 sats.

**Mark Erhardt**: Oh, I didn't look at the amounts, but there's about 182
million UTXOs in total and 48 million P2TR UTXOs.  A ton of them are tiny
though.

**Adam Gibson**: Oh, sorry, yes.

**Mark Erhardt**: Yeah, the overall value is stored in P2TR outputs is only like
5,200 bitcoins -- I'm sorry, no, I misread that; 68,000 bitcoin only.  So,
people need to start using P2TR for their own wallets too, not only for the
frigging inscriptions.

**Adam Gibson**: Yeah, sorry, my apologies, it's just totally an error.  I just
completely forgot.  180 million was the total and I was seeing about 39 million.
Now, as you say, it's even more.  But the important point is how many exist
above a reasonable threshold, and that is of the order of a few hundred thousand
above 100,000 to 300,000 sats; in other words, some meaningful amount of money,
let's say.  My point is that there is still a reasonably large anonymity set.
It's not like a few thousand people, right, it's hundreds of thousands at least.
So, my point is that it is possible to create a very significant anonymity set
in theory, but my other point is that in practice, because of difficulties of
using wallets today, even then, it's probably we have to be quite careful, like
you say, have delays and so on.

**Mike Schmidt**: It sounds like for the audience, there's maybe two different
things for them to potentially jump into if they're curious about this one.
Waxwing published some code that covers what we talked about today.  If you're
technically-minded and curious about that, jump into the code, obviously.  And
although it's not as straightforward as it may sound, as Adam mentioned, there
is this proof-of-concept forum that requires a signup, where you need to prove
that you have control over 500,000 sats.  That could be a fun exercise as well,
although maybe not as easy as it sounds per the discussion we just had about how
difficult those proofs may be to generate.  But that could be a fun exercise for
the audience.

**Adam Gibson**: Sorry, I didn't mean to imply it's impossible or something.
There are written instructions and it can actually be just like two or three
steps, but I certainly don't require that anyone decides to do that.  If you
want to do it, please have at it.

**Mike Schmidt**: Thanks for joining us to talk about this Adam.  You're welcome
to stay on as we move through the newsletter, but if you have other things to
do, we understand.

**Adam Gibson**: Yeah, I'll stay, but I'll just listen.  Thank you very much.

_BIP39 seed phrase splitting_

**Mike Schmidt**: Next news item, titled BIP39 seed phrase splitting, was
related to this Rama Gan post on the mailing list titled, Penlock, a
paper-computer for secret-splitting BIP39 seed phrases.  This is a similar idea
to codex32, which we've covered previously and we actually have a topic entry
about as well.  But codex32 operates on BIP32 wallets, BIP32 seeds, and Penlock
operates on BIP39 seed phrases.  I think we had Andrew Poelstra on actually, or,
no, it was Russell O'Connor in Podcast #239 talking about codex32, and we also
covered codex32 in Newsletter #239.  There's actually an interesting website for
Penlock that Rama Gan had published.  It's beta.penlock.io and it has a bunch of
beta tools for doing these sort of pen-and-paper operations.  Depending on what
kind of operation you'll be doing, so for example, you may be generating a seed
phrase, you can split a seed phrase, you may potentially need a printer,
scissors, pencil, eraser, I think they mentioned craft knife as well, and a
wallet.  I thought that the website was kind of useful.  It had a bunch of
instructions, but also some indication about how long each operation would take.
For example, if you wanted to use this mechanism to generate a seed phrase, it
would be 30 minutes.  If you want to split a seed phrase, that could be two or
three hours.

In the post, or maybe it was in an accompanying writeup, the author noted that,
"There is a Satoshi Labs improvement proposal, SLIP39, which is intended to be a
replacement for BIP39.  It also uses secret splitting, using Shamir's Secret
Sharing, but that's in order to split a BIP32 HD wallet, and it's not compatible
with BIP39".  So, the author noted, "We still lack a wallet-agnostic secret
splitting standard".  Murch, I'll pause there.  I have a couple more things, but
maybe you want to augment or clarify any of that.

**Mark Erhardt**: Yeah, so I haven't looked too carefully at Penlock yet.  I did
participate in a codex32 workshop a couple of years ago, and that is fun, but I
think I got like a quarter through in the first hour and I had to correct for
mistakes once or twice.  It's very significant focused work to get it right.  I
did see in this Penlock worksheet as well that it works with checksums and this
would be super-important because I think it's hard to not make a mistake when
you're adding up numbers for several hours.  So, I'm curious to hear people
trying this out and what they find out.  I think it's not on the menu for myself
for this weekend, but yeah, let us know.

**Mike Schmidt**: If you're curious about some of the details, Andrew Poelstra,
one of the authors of codex32 and the author of this Penlock proposal, we're
going back and forth on the mailing list with some of the trade-offs and
technical details.  So, if you're interested, check out the rest of that thread
that we link to the start of in the newsletter.  Murch, anything else to add?

**Mark Erhardt**: Yeah, I think it's a cool idea and it's cool that you can do
this by hand, but the practicality of sitting down for several hours of focused
work to create your own seed and then not having the peace of mind of actually
checking it in a computer to see whether you can generate the addresses that you
meant to, like, how do you field test whether everything worked?  So, I think my
recommendation will remain to create a multisig wallet based on an output script
descriptor, test it a few times to keep it in an offline computer, and then to
store the keys in separate backups with the output script descriptor.  Yeah, we
had, or someone asked that on Stack Exchange again.

So, apparently it is still a surprise to some people that have been looking at
multisig for a while that you need all public keys and the subset of private
keys to restore.  And the all-public-key part seems to fall off the radar
sometimes.  And the point there is you have to be able to recreate the script
that you're signing for in order to spend your money, and that's why, yeah.
Sorry, I'm rambling at this point.  But all of that is a science, and don't make
it even harder on yourself before you are sure you have mastered the easier
forms.

**Mike Schmidt**: It's interesting and I thought codex32 was interesting when it
came out as well, but that being said, other than covering it here in the
newsletter and digging into some of the initial posts, it's not something that
I've jumped into committing to, but it's cool.  Let us know if you all try it.

**Mark Erhardt**: Yeah, let me rephrase that.  I think I've heard the story that
people lost access to their own coins dozens of times, and I've heard the story
of people losing their backup and someone stealing their backups once or twice.
So, I'm personally still correcting for the biggest threat being I'm going to
lose access myself, rather than someone else is stealing all of my split
backups.

_Alternative to BitVM_

**Mike Schmidt**: Next news item is Alternative to BitVM.  Sergio Lerner, from
the Rootstock Project, posted to the mailing list a post titled BitVMX: a
Virtual CPU to optimistically execute arbitrary programs on Bitcoin.  And the
post links to a BitVMX white paper that Lerner co-authored with four other
contributors.  And this is an idea that was also recently presented as part of
the BTC++ conference, I believe.  And as you can tell, it's based on the BitVM
proposal that we have discussed previously.  We spoke with Robin Linus about
BitVM in Podcast #273 and Podcast #278, so if you want to brush up on your
BitVM, check those out.  Similar to the other BitVM versions, BitVMX is a way to
create a virtual CPU that can be verified using Bitcoin Script.  Like BitVM,
there are no consensus changes required.  Sergio and team put out a bitvmx.org
website with a bunch of information, and there weren't any mailing list post
responses to this, I don't think, the last time I checked.  If you look at the
bitvmx.org website, there is a quick summary of the proposal.  I'll read from
there.

"BitVMX represents a new form of covenant that does not require a soft or hard
fork to Bitcoin. Funds can be locked in a UTXO with a spend condition that
depends on the result of the execution of a program".  There's a bunch more
information on that website.  Murch, I don't know if you got a chance to look
into this variant of BitVM, BitVMX?

**Mark Erhardt**: Only very briefly.  My rough understanding was that it has a
different set of trade-offs, it's more efficient in the proof, but it requires a
trusted verifier; whereas BitVM, I think, could be verified by any of the
participants.  So, that was my rough understanding, I don't have any more than
that.

**Mike Schmidt**: A trusted verifier seems like a step in the wrong direction,
or maybe because this is part of Rootstock that's already in the cards?  I don't
know.

**Mark Erhardt**: Yeah, I don't know either.  It seems like someone that knows
more about it should tell us at some point.

_Continued discussion about updating BIP2_

**Mike Schmidt**: I was hoping Sergio would join us today but alas, he did not
get my message.  Last news item, Continued discussion about updating BIP2.
Murch, this is your discussion, so have at it.

**Mark Erhardt**: Yeah, so as some of you remember, we added a few BIP editors a
few weeks ago, and we've made some pretty decent progress at going through the
open PRs in the repository.  I believe we're down to something like 40 open PRs,
some of which are fresh, and we started at 152, so that's pretty decent.  We've
merged a few things, we've announced some numbers for a few things, but there's
a few PRs that are stuck, and they're stuck on process.  Some are related to
people having open PRs to set some long-time open BIP drafts to reject it,
because they haven't made progress in many years.  That has, in some instances,
caused the original authors of those drafts to say that they are still open and
they still think it's a good idea and they shouldn't be rejected.  So, I think
that's one of the points that an improved process document should address.

Another thing is that many of the previous people in that thread mentioned that
there are too many judgment calls by the editors.  It would be nice if BIPs were
even more just a clerical task and had some objective criteria by which they
could be merged.  Anyway, I went through the thread.  I collected all of the
comments that people had made, and I've started trying to put together an
improved process document that I'd like to propose eventually, which hopefully
takes more of the judgment calls out.  And some of the things that I'm really
noodling on still is, so what should the scope of the BIP process actually be
exactly?  Should we just merge everything that is related to the Bitcoin
ecosystem, or is there another criteria, like it has to have to do with the
bitcoin, the currency, and the supporting technologies?

Anyway, there's a few ways how this could be proposed, and I asked for people to
provide input.  And let me temper that a little bit.  I'm not looking for
everybody to just spout off opinions.  We get that on Twitter plenty.  If you're
writing to the mailing list, please actually read BIP2 first.  Maybe also check
out the mailing list thread on the topic before you add to it, because we don't
need something like the discussion on the ordinals BIP, where 120 out of the 125
comments have nothing to do at all with the actual content of the BIP draft.
Yeah, anyway, so if you have good input how we could make the BIP process
better, or if you actually want to co-author a proposal, my email address is
known.

**Mike Schmidt**: How has feedback to your post and ideas been so far?

**Mark Erhardt**: Zero responses.

_LND v0.18.0-beta.rc2_

**Mike Schmidt**: I'm sure everyone's just thinking very thoughtfully about it
before responding.  Moving on to Releases and release candidates.  We have old
trustee LND v0.18.0-beta.rc2, which we've punted on and will continue to punt on
until it's officially out of RC status.  Moving to Notable code and
documentation changes.  We have five this week, and I'll take the opportunity to
solicit any comments or questions that you have.  You can request speaker access
or comment on this space with a question, and we'll try to get to that.

_Core Lightning #7190_

Core Lightning #7190, a PR titled, Use the network height as current height.
The PR author noted, "We used to use the sync height, ie the height of the last
block that we processed, as the offset for all calculations in Core Lightning
(CLN).  This can result in CHECKLOCKTIMEVERIFYs (CLTVs) that are too close to
the current height while synchronizing with the blockchain".  So, this PR has to
do with either initial sync, or if you're coming back online after being out of
sync.  And the PR author noted that the limitations with CLTV is too close to
the current height, and then the PR itself, the #7190, adds the networkheight to
the waitblockheight in CLN, so that CLN can retrieve the current height of the
block that the Bitcoin backend behind CLN has seen, which means that CLTV
calculations are correct as long as the backend is in sync, and as long as the
peer is in sync with that backend.  Anything to augment or add or correct there,
Murch?

**Mark Erhardt**: That seems like a good change, mostly like a bug fix.  And I
hope that it also corrects for peers lying to you about their best block.  But I
assume that that is not that much of a problem, if at least the difficulty check
has been checked already.  Anyway, sounds fine to me.

_LDK #2973_

**Mike Schmidt**: LDK #2973, which adds support for intercepting onion messages
for offline peers, and this partially resolves a motivating issue on the LDK
GitHub, titled Onion Message Mailbox, that specified a want to support this
thing called an Onion Message Mailbox feature, quote, "Ie, we want to be able to
store onion message forwards on behalf of offline next-hop peer, and forward
them later when the peer comes back online".  This is part of LDK's work towards
async payments implementation.  I didn't see anything else too notable about
this PR, but Murch, did you?

**Mark Erhardt**: Not too much, but I think that sounds like a way more sane
approach than hodl invoices.  So, from what I understand, it would work by, say
if an online node wants to pay a mobile wallet client, it would send this
reminder message to the liquidity service provider of the mobile client.  And
then, when the mobile client comes online, the liquidity service provider would
forward the message, and then the mobile client would be reminded to get an
invoice from the payer.  So, instead of sending a payment and having it stuck at
the second-to-last hop, or stuck at the first hop to be picked up later, the
thing that is stuck is just the request that this invoice be retrieved later.
That sounds like a lot less stuck funds, but also I'm not really in touch with
all of the development here, so that's just my very uninformed take on this now.

_LDK #2907_

**Mike Schmidt**: Yeah, that's a great point, and thank you for contrasting
those two approaches.  LDK #2907 is more onion message work in LDK.  This one is
titled, Introduce ResponseInstructions for OnionMessage Handling.  Right now,
LDK's handle_message function can generate a response for an onion message, but
it does not have the reply path for asynchronous responses.  So, this PR adds
response instructions that expose the reply path as well as the response, and
allows for more complex response mechanisms similar to what we mentioned
earlier, async payments being the example there.

_BDK #1403_

We have a BDK PR, BDK #1403.  This is a PR to simplify the API of BDK's Electrum
chain-source.  #1403 improves the performance of wallets using BDK's Electrum
backend, and also includes new TxOut, which was motivated by an issue regarding
fee calculation.  The issue says, "BDK does not store the transaction fee in a
separate field.  It needs to be calculated from the difference between the
previous outputs and the outputs created.  For transactions that are received
from an external wallet, we would not have the previous TxOut data by default.
It'll be handy to have an option to get previous TxOuts for these transactions".
So, not only are there performance improvements if you have an Electrum backend,
but also these TxOuts are included, which can help with fee calculations.

**Mark Erhardt**: I want to riff a little bit on how often people are surprised
that you can't actually calculate the fee or feerate from a transaction by
itself.  The problem here is, the inputs on a transaction only reference
specifically which UTXOs are spent.  But if you don't have those UTXOs on hand,
you don't actually know how much money is being introduced into the transaction.
And since the transaction fee is only specified via the difference of the input
amounts and the output amounts, as in the difference of what's going out of the
transaction into new outputs that are being created versus what came into the
transaction, that's the transaction fee.  So, you need to know the amounts,
rather than just which UTXOs were spent in order to calculate the transaction
fee and feerate.

_BIPs #1458_

**Mike Schmidt**: Thanks for that add, Murch.  And this last PR is right up your
alley as well.  This is BIPs #1458.  Murch, you're not only our resident Bitcoin
Core dev now, but you're also our resident BIP Editor.  So, maybe tell us about
#1458.

**Mark Erhardt**: Yeah, I think I merged them.  And the BIP in question is
BIP352, which is silent payments.  So, silent payments, we've talked about this
before, but it is essentially actually reusable addresses.  And I want to
contrast that with what we use addresses for in the real world and in general,
and unfortunately in Bitcoin.  So, addresses usually refer to something that is
a permanent way of finding someone.  And in Bitcoin, what we usually call
addresses should really be called an invoice identifier, because everybody is,
in business settings especially, using an output script hash, or the invoice
identifier, as uniquely identifying who paid you for what purpose.  If I want to
get money for someone buying from my website, or whatever, I would give them a
distinct new address in order to know who paid me and who am I going to send
stuff to when the money arrives.

So, there's a very bad pattern that many people engage in, which is reusing
these invoice identifiers in a so-called address reuse, or forced address reuse
when dusting is involved, and that's really bad for privacy because it means
that when you spend UTXOs that have the same output script, you always identify
that the same entity received and spent money.  So, what silent payments does is
it provides an actual address, something that you can use to generate any amount
of output scripts from that are always unique.  And how it does that is by
looking at the inputs of the transaction you're creating and doing a
Diffie-Hellman key exchange, sorry, it creates a shared secret between the
sender and the receiver, by using the public keys used in the inputs and the
silent payment address to generate a new output script that the recipient will
be able to discover as their own and spend from.  And that's really cool.

So, we actually have a form of static address now that is reusable, that doesn't
pollute blockchain with notification transaction, that looks exactly like any
other P2TR output.  I'm super-excited that silent payments are coming pretty
close.  Note again, this is just a BIP getting merged.  There's still work in
Bitcoin Core to get it in.  There is, however, recently a beta, I think, in Cake
Wallet, which has already implemented silent payments.  I know of multiple other
wallets that are also working on implementing support.  So, if you're waiting
for this one thing that you can post on your Twitter profile or your Stack
Exchange profile for all the contributions you've made to the knowledge space in
Bitcoin, this is going to be silent payments.  You can just post that somewhere
and every payment you receive will not reuse the same output script.

**Mike Schmidt**: It's really great to see the traction that silent payments are
getting.  You mentioned Cake Wallet.  I think I've seen some others showing
interest in silent payments implementation as well, and I see a lot of chatter
on Twitter about silent payments, at least more so even these last few weeks, so
we love to see it.

**Mark Erhardt**: Yeah, this is the thing, if you were waiting to get your
address tattooed, this is the one that you want!

**Mike Schmidt**: All right, I don't see any requests for speaker access.  So,
thank you all for joining us.  Thank you, Waxwing, for being our guest this week
and to my co-host, Murch, as always.  See you all next week, TBD when, but
thanks for bearing with us.

**Mark Erhardt**: Cheers.

{% include references.md %}
