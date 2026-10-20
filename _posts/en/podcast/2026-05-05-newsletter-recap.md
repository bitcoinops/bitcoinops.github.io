---
title: 'Bitcoin Optech Newsletter #403 Recap Podcast'
permalink: /en/podcast/2026/05/05/
reference: /en/newsletters/2026/05/01/
name: 2026-05-05-recap
slug: 2026-05-05-recap
type: podcast
layout: podcast-episode
lang: en
---
Gustavo Flores Echaiz and Brandon Black are joined by Olaoluwa Osuntokun to discuss
[Newsletter #403]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-4-6/423576686-44100-2-707e33fa7625a.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Gustavo Flores Echaiz**: Hello everyone, we are live.  This is Bitcoin
Optech episode #403.  Today, I'm the host of the episode since Mike and
Murch cannot make it.  And I'm joined by Brandon Black, also known as
Rearden Code, and also roasbeef from the LND implementation.  Thank you
guys for joining me.  Would you like to say a few words to introduce
yourself?

**Brandon Black**: Sure.  Hi, I'm Brandon, I work on Bitcoin stuff and I
often write, or regularly now write, the Changing consensus segment of
Optech.  So, good thing that's the big part of the newsletter this week.

**Olaoluwa Osuntokun**: Hi, I'm roasbeef, also known as Laolu.  I work on
Bitcoin and Lightning and some other stuff.  I've worked as a developer
for maybe around ten years now.

_Post-quantum BIP86 recovery using zk-STARK proofs of BIP32 seeds_

**Gustavo Flores Echaiz**: Awesome, thank you guys.  Well, today we're
going to be talking about a few items, one related to a new proposal for
BIP158, also called compact block filters, which is a News section, and a
few items on Changing consensus.  But because we have roasbeef joining us
as a guest, we're going to start with his item, "Post-quantum BIP86
recovery using zk-STARK proofs of BIP32 seeds".  So, please, Brandon, if
you want to give an introduction to this and maybe start asking roasbeef
questions so he can give us all the details?

**Brandon Black**: Yeah, for sure.  So, this is great work from Laolu here
to bring into reality something that had been talked about for a long time,
a way to recover coins that might have been locked due to some change
pursuant to a break in secp256k1, possibly quantum.  That's what
everyone's talking about these days anyway.  So, if we were to have to
disable some secp signatures, is there a way to recover from other secret
data?  And one of the proposals is that that secret data you could recover
from is your BIP32 seed.  And that's been talked about and talked about, I
think Adam Back might have been the first one to talk about it, but I'm not
sure, but no one's ever done it for real.  And Laolu did the work here to
build real software that can make zero-knowledge proof of holding the BIP32
seed corresponding to some public key, to allow recovery in a post-quantum
or otherwise post-secp world.  Yeah.  And tell us more about it, roasbeef?

**Olaoluwa Osuntokun**: Yeah, I think it's a pretty good intro.  I mean,
so I did this a few weeks ago.  I think I was sitting around a weekend.
And maybe it was sometime last year, I was actually working on porting or
being able to use RISC Zero from Go.  So, for those that don't know,
basically RISC Zero is written in combination of C++ and also Rust.
There's a ton of code basically around it, but I wanted to be able to
actually reuse all the libraries that we have with the BTC suite, LND, and
the fact there are all these Go libraries that we've been using for several
years.  So, I was working on it last year, and then I think I just hit a
brick wall in terms of some of the things around RISC-V, because I
basically had to create a custom RISC-V binary in the Go tool chain to run
effectively on the RISC Zero platform.  Then eventually I was like, "Okay,
let me just take another stab at this".

I started to work on it.  I was like, "Okay, well, I need some cool demo
for this", and I was thinking at that point, people were just saying,
"Okay, well, if there's no plans for post-quantum stuff, blah, blah,
blah".  I was like, okay, well we've had all these ideas, no one had
implemented it basically, right?  So, I was like, okay, let me actually
take a stab at implementing this thing, right?  So, I implemented the
first version.  The first version I've mentioned is basically a proof that
a private key was derived via BIP32.  The reason why this is relevant is
that, for example, let's say you have a public key onchain, you have a
quantum computer physically, because you basically get the private key for
that public key, right?  What it can't necessarily do is invert a hash
function, right?  And even something like, you know, Grover, still there's
some debates around exactly how practical it is and the speedup, and so
forth.  That's sort of the key thing, basically.  So, you can say, okay,
well, it starts with a proof that you now pretty much have a hash function,
and then this actually goes all the way then to actually do the EC
operations within the circuit as well.

So, there's actually a number of optimizations.  For example, right now,
for the EC circuits, I could just use the normal sort of BTC suite, BTC EC
libraries basically.  But the RISC Zero platform actually has a number of
optimizations.  For example, there's actually an accelerated bigint sort
of opcode in RISC Zero.

**Brandon Black**: What is RISC Zero and why does it matter here?  What
are we even talking about?

**Olaoluwa Osuntokun**: Yes.  I mean, so RISC Zero is basically a platform
for sort of making zero-knowledge proofs, right?  So, one of the things I
remember back in the day, do you remember you had to have very specialized,
maybe hand-rolled circuits basically, right?  They literally look sort of
like a spreadsheet in a sense, basically, of all these rows, like these
constraints, basically.  Those constraints themselves can actually then
sort of express a circuit basically, because you can say zero goes up to
zero, and everything works.  So, RISC Zero is basically a take on that,
rather than doing something that's very, very specialized, it targets
RISC-V.  So, what they do, they basically have a circuit that's able to
verify a RISC-V CPU.  That means the registers, the opcodes, add,
multiplication, loads of sort of stuff like that.  And because they have
that universal proving system basically, now you can basically compile any
language into RISC-V and then run it with that itself, which is
super-powerful.  And then, that's how I was able to use something called
TinyGo, which actually supports compiling Go into RISC-V.  I think it's
maybe the 64-bit version.  And while RISC Zero uses basically a 32-bit
version, it has some additional changes as far as the way the binary is
set up and the ELF format, things like that as well.  So, that's the main
thing.

I think part of this demo showed that we actually have pretty good tools
for this stuff.  I think in the past, it was very much an abstract thing,
where maybe it was super, super-specialized, because you basically had to
hand-roll the circuits.  But now, anyone can basically, if you can compile
to RISC-V and you can basically get your agent to make a tool chain for
you, or something like that itself, you also can basically write these
zero-knowledge proofs as well.  So, I think that was also part of it, to
basically show people exactly how far things have come in terms of the
actual tool chain, and that it's relatively practical.

So, the initial version that I did was based on sort of, basically doing
the entire taproot proof chain.  So, you basically start with a seed.  You
can even give it like, "Are you doing BIP86?" meaning the taproot output
type that actually will commit to a nil or an empty script, basically.  You
can also even give it a particular path, like a BIP44 path.  So, I can go
all the way down, the second chain's address and the hardened key,
whatever else.  And those are basically what's being input into the system,
right?  And so, one thing to clarify, there's sort of the guest and the
host basically, right?  So, the guest program is the thing that's actually
compiled into RISC-V.  It's sort of the thing that's running the program
on inputs.  You can basically view it as reading private inputs of your
standard in, standard out, then it runs the code itself.  Then it commits
to basically what they call a claim, which is a hash commitment of the
final state of the system basically.  Then you have the host that actually
takes that program, it's going to load a binary.  It's going to run the
program and then basically execute the trace.  And the trace, you can view
it as a very big matrix, where you can view it sort of like you have all
the registers and every single register, you're doing adds and muls
basically.  And then, that actually compiles the final proof itself.

So, the initial version that I did was actually somewhat expensive because
it required doing asymmetric cryptographic operations inside the circuit,
because it's actually doing EC mul in the circuit itself.  So, that
resulted in it being relatively less.  I think the initial proof maybe was
1.6 or 1.8 MB, basically.  So, it's relatively large because it's doing a
lot of operations into there.  But at the same time, it still is relatively
fast to verify just because there's a lot of logarithmic scaling in terms
of verification, but it's linear basically in terms of proving.  And I
posted to the mailing list, and then some people were looking at it.  And
Conduition had some other ideas basically, that rather than actually doing
the entire taproot derivation from the seed, instead you can just actually
do one layer of the xpriv.  Because getting from the seed to the xpriv
still has a hash operation itself, and you can get that xpriv.  And once
you have the xpriv, then it's actually really interesting, because it's
actually much, much faster.  So, I think it got down to, so initial proof
after that was maybe around 600 kB basically, and then it's still
milliseconds to verify.

There's an actual step further where you can basically do what they call a
succinct receipt, which is a layer of recursion on top of the initial
proof itself.  So, I was able to take, for example, that 1.6 MB proof and
get it down to a 200 kB proof.  And the way it works, I won't get into it
too much, but you can basically have another special verifier that verifies
that there is a valid STARK proof.  And then, you take that proof and then
you can present that.  And you can even do that in sort of a quantum
manner.  So, this is something else that I implemented in the end to
basically show how this could be used on the potential Bitcoin chain with
your sort of aggregation, right?  You can basically view it as kind of a
Map Reduce.  You basically have a bunch of individual proof claims, and you
can combine these two proof claims into an aggregate claim and then do the
aggregate claim into another claim itself.  And you can actually do that
also in an incremental fashion.  So, let's say I'm hypothetically in the
future, I'm mining a block as a miner basically.  I'm aggregating these
proofs, another transaction comes along, I can then make a proof that this
existing aggregated proof and this new leaf can construct a new valid
proof, basically.

So, I also went ahead and did sort of a layer of recursive batch
aggregations, which is really important because, for example, you can
imagine in the future, let's say we have something that looks the witness
commitment, and rather than you committing to wtxids, we commit to this
claim value for every single relevant output in the block.  And then what
you do, you can basically have that single proof, and then people that want
to verify that the block was constructed properly, they can reconstruct the
claimed hashes, because in this case, it'll be known it's going to be the
xpub or the xpriv, or maybe the taproot output itself, and then reconstruct
that root and then verify, okay, well there's a proof from the root
basically.  And I can also do an inclusion proof from every single
transaction into that root itself.

**Brandon Black**: If we were to do this in Bitcoin and wanted it to be
succinct enough to enable many people to claim their coins this way, we
would need to have almost a utreexo-style situation, where the block itself
contains just the succinct summary proof, and then anybody who wants to
prove their coins were spent in that proof would have to have the public
data needed to verify and share it with their counterparties.  Is that
roughly correct?

**Olaoluwa Osuntokun**: Yeah, exactly.  And there's one trade off there
because there's two types of batches implemented.  One is sort of a
homogenous batch basically, where all of the leafs are actual just
individual proofs.  There's a heterogeneous batch where some of the leaves
may actually be other batch proofs.  And the one trade-off there with the
way it's implemented is that because it uses a merkle tree, every time you
add a new heterogeneous leaf, you sort of increase the proof depth of
everything else that was already aggregated.  So, I have a new leaf, and
then basically now I have to have a series of new layers on the proof.
And so, this is not something that gets implemented yet, but I have two
sketches of using either a Sparse Merkle Tree (SMT) or an MMR to keep the
proof a bit more fixed.  For example, if it was an SMT, because it sort of
simulates a complete binary tree of 2256 leaves, you basically know that
the height is always fixed.  And you can then compress that, and this is
what we use in Taproot Assets, and so forth.  Then there's also MMR, which
is based in sort of appending these peaks together, and it would look
relatively similar to utreexo as well, because they use a similar
technique of these Merkle Mountain Ranges, I think.  And that was another
area of it.

But I think it's super-cool, because I think the main thing to take away
from this is that if we wanted to do this, it could be practical.  And so,
I think there was some detractive mailings.  Okay, well obviously we don't
want to pull in the entire RISC Zero tool chain into consensus.  It's
millions of lines of code, C++, Rust, all this other stuff.  But the thing
is, if you look at particularly the simpler proof, the xpriv proof, I think
there's a way where it's basically primarily SHA512.  So, you could
actually have something very, very small and optimized for that particular
use case, and then just do that by itself.  Another thing that I ended up
implementing has got, like -- so, in the end, there were actually three
different areas in terms of the proof.  There was the full taproot proof,
so from seed to BIP32 to taproot output basically.  Then there was just
doing the xpub and just doing the xpriv.  This doesn't actually support a
batch that can prove any of those three different claims, basically.

So, I think some people are asking, "Okay, what if we have additional
claims in the future?  We saw this one version".  We could actually have
heterogeneous batches proving different statements that are related to this
private key recovery system, basically.  For example, Electrum actually has
its own seed format.  And I think they had the v2, they had another one
many years ago.  So, any seed format that ran through a hash function could
be protected under the engines as well.  You can even do something like a
MuSig2, because assuming the MuSig2 keys were actually derived via BIP32,
you could also do this as well.  So, it's generally a broad framework of
this type of rescue system.  And I'm not saying we must do this, but to me
it was sort of, okay, well we can have something in our back pocket in case
it pops off.  And then, by that point, maybe there'll be different
techniques, there'll be different proof systems, it'll be far more
efficient basically.  But this just showed, okay, if we needed an emergency
soft fork, people wouldn't be completely hosed.  I think it's relevant
because this would allow more Bitcoin in whatever case.  I don't think we
should confiscate, whatever else, we would allow people to actually regain
ownership of their private keys, basically.  And I think that's important
because that helps us basically protect the sovereignty of bitcoin users
and holders all around the world.

**Brandon Black**: How does this compare in cost to some of the other kind
of, let's say, more individual commit-reveal schemes?  I know Tadge Dryja
has been working on one, he's posted about it before, but there's new
iterations on it.  How does this compare to those kind of individualized
commit-reveal schemes, in terms of both proving costs and kind of
long-term onchain verification costs?

**Olaoluwa Osuntokun**: Yeah, good question.  I mean, to my knowledge, one
thing with the way the commit-reveal schemes work is that, it sort of
presupposes that you know exactly what algorithm you're going to use in the
future basically.  Because, for example, if I'm going to commit to a new
particular SLL, like SPHINCS+ signature type, I need to know which version
is going to be used.  I guess you can say I'll commit to all the different
keys.  Because one of the things with SPHINCS is that depending on the
parameter type, that actually affects the public key, because the public
key is basically a root hash of the tree and the parameters basically
affect the size of the tree in itself.  So, I think it's definitely
interesting because it's something that people could do today, they can
commit something today, but kind of presupposes us knowing exactly what's
going to happen in the future.

But I would say if you're looking at a lack of less complexity, it's
definitely way less complex, because for example, even though these proofs
are pretty fast, for example, the initial one maybe took, I think, 12 GB
of RAM on my laptop.  Once I finally got to sync one, it was basically 3
GB and could be proved in 2 seconds versus 60 seconds, and verification in
12 milliseconds.  And once again, this is the generalized version, because
it's running a RISC-V CPU.  For its execution, we could definitely get one
that's much faster.  But I would say the commit-reveal is definitely less
complex, and potentially is something that maybe will be a bit easier.
Either way, people would need to think about, okay, exactly how are you
going to implement this software?  So, for example, people would ideally
have some sort of offline laptop.  Maybe hardware wallet operators by that
point, they can actually hand approve this, or basically generate the proof
directly from your hardware wallet.

So, there's definitely a bit more concern in terms of certainly the
complexity, in terms of the full stack end-to-end in the case that we need
this in the future; while commit-reveal definitely is something that's a
bit simpler.  You can say maybe it requires more space onchain because you
do need to do the reveal onchain; and the commitment, exactly how big would
it be?  On this one, you can say, well, you would actually still have just
that 200 kB proof.  And one important thing is that right now, the proof
doesn't actually commit to a sighash or address.  It could in theory be
replayed, but that's something that you can add in.  You can basically
commit to the transaction that is authorized to spend, assuming the proof
is valid, and that will actually bind things even further.  And so, people
look at the repo, I left some additional follow-up to-dos if people want to
get their hands dirty and experiment with this stuff.  And the great thing
is, you can literally run it on your laptop, do it, get it, download it
all, do make install, do the make verify, and you can actually generate in
that zk proof on your laptop.

**Brandon Black**: Yeah, I mean this is another example of great things to
have in our back pockets.  As you know, I'm obviously a quantum skeptic,
everyone knows that at this point after the Bitcoin Conference, but it's
great to have these things in our back pocket, because there's always a
chance that even a classical break happens of secp.  And so, it's great to
know that we have options out there.  And so, anybody who's overly stressed
about what happens if there's a sudden break of secp, we now have not just
one, but I think at least two or three different reasonable proposals to
let people who have some kind of secret data about their addresses, even if
the public key is not secret, still recover their funds in the event of a
sudden break of secp.  So, thanks for this work and thanks for joining us,
roasbeef.  Awesome.

**Olaoluwa Osuntokun**: Yeah, thank you.  And the last thing I want to say
is, I think if you really know Tadge, you know great quotes.  I remember
it was at the Presidio Bitcoin Quantum Conference last year.  He was like,
"Well, I'm not worried about quantum computing, I'm worried about other
people being worried about them".  So, I think it's one of those things
where it's like, "Hey, all right, here you go, here's the escape hatch".
And then, I was working on some other things, I'll just shout it out.  I
posted some mailing-list posts basically talking about, I think it's more
what you can talk about in terms of agility, where you can do sort of
hybrid approaches.  For example, people know there's an encrypted protocol
on Bitcoin through BIP324 right now, that's basically on classical crypto.
So, if you wanted to, you could actually make that hybrid itself.  And
once again, it's one of those things where it's secure if the classical is
secure or the quantum is secure.  So, now you're hedging a bit more versus
putting all your eggs in one basket and just betting that this is the
thing, because maybe it's the other way around.  So, I think that's a nice
thing in terms of hedging and actually having a bit more conservative
approach to stuff.

**Brandon Black**: Yeah, and I love also people have talked recently about
how not every use of Bitcoin needs to be hedged in that way.  I've said on
that, small UTXOs, you're probably fine just sticking to the current secp,
because you can always move them and also the quantum computer will attack
yours last, so you can move later.  Huge custody UTXOs are probably
relatively safe because they roll over frequently.  So, they can move to
post-quantum crypto at the last minute because they roll those UTXOs over
on a regular basis.  And then there's kind of these in-between-sized UTXOs
that are individuals' cold storage.  Those are the ones those people are
going to want to move to a hybrid setup as soon as possible, because they
don't move frequently and they're large enough to be an attack vector.  So,
there's certain people have different incentives to move to this stuff.  We
should keep working on it.  And it's great to have escape hatches in case
we have a sudden break.  So, very good.

**Gustavo Flores Echaiz**: Thank you so much, Laolu, for joining us and
explaining all that.  That's been a very interesting proposal.  I just
have one question.  Where do you see this going?  Would you to turn this
into a BIP proposal?  Is that too early?  Where would you see this goes?

**Olaoluwa Osuntokun**: Yeah, I would say it's a bit too early to turn it
into something that's concrete, because I think it's something in the back
pocket.  I will say that I think this hopefully shows people that they can
actually be experimenting with STARK proofs and Bitcoin protocols today
basically.  Because for example, you could do something like prove that
some transaction was actually included in a block.  For example, on LN, you
could say, okay, well, here's a root that actually shows that this is the
root of all the valid bitcoin transactions.  So, I would hope that maybe it
spawns more innovations in terms of using this for offchain protocols.
Because for example, you don't actually necessarily need to modify the
chain if you're using an LN or maybe other P2P protocols around stuff.  So,
hopefully that gets people looking at this stuff and starting experimenting
with it as well, because if you have, like, a RISC Zero, RISC-V toolchain
that you can compile onto, you can basically do any program.  Obviously, it
depends on the size, and so forth.  You can just do some accelerators, but
I think that's part of the takeaway here.

**Brandon Black**: Then you guys, look back, there's been a proposal for an
OP_STARK_VERIFY to the general verification.  And in that discussion, we
got into the same stuff that roasbeef mentioned just now about how you bind
the STARK proof to the specific transaction it's attached to.  And just
verifying a generic STARK on Bitcoin wouldn't be super helpful, but
eventually we may want to have some kind of a STARK verification that does
bind the transactions onchain.  We'll see what the future holds.

**Gustavo Flores Echaiz**: Very interesting.  Thank you so much, Laolu.
You're free to hang out, but you're also free to drop as we continue the
episode.

**Olaoluwa Osuntokun**: Cool.

_Binary fuse filters as an alternative to BIP158's GCS_

**Gustavo Flores Echaiz**: Awesome, so now we're going to go back to the
start of the newsletter.  In the News section this week, we have an item
called, "Binary fuse filters as an alternative to BIP158's GCS".  So,
BIP158, also known as compact block filters, is a method that allows a
light client to obtain transaction data corresponding to its wallet without
compromising their privacy.  There is a process where the node that feeds
the data first has to build a set of filters using Golomb-Rice Coded Sets
(GCS).  And then, the light client downloads all these filters, compares
his list of addresses against these filters, and if there's a match on any
of these blocks, he will then proceed to download the full blocks
themselves.  And that's how he obtains all the transaction data.  There is
also a case for some false positives.  It's extremely unlikely, but yeah,
if there's a false positive, then the block is downloaded and the light
client finds out that an address doesn't match the block.  So, there's no
big downside except for bandwidth consumption and CPU time to the false
positives that are extremely unlikely.

Another important aspect to precis is that there's no presence of false
negatives, which is the most important aspect.  So, this item is done by a
developer named Csaba, or Csaba Purszki, who posted on Delving Bitcoin his
research on finding a better alternative to GCS, because GCS consumes a
lot of CPU time, particularly if the filters grow in size.  If you have
bigger blocks, you've got bigger filters, and GCS scales linearly in how
much CPU time it consumes.  So, if you have, for example, a mobile light
client, it could reach a certain degree of CPU power consumption that is
unmaintainable or unscalable for mobile clients.  So, Csaba asks himself
the question, how can he find a better alternative that there's no change
if you have a very small block or a very large block?  If you use another
system, which is the one he proposes here, binary fuse filters, then you
would have no issue at scaling the size of blocks, because then the work at
the mobile light client level would be the same.  So, according to
Purszki, the binary fuse filters are a suitable alternative, and the way
he's seen benchmarks improvements between 6x to 45x speed-up on ARM
architecture, and 9x to 80x speed-up on desktop, with a slight increase in
bandwidth cost that is between 0% to 3%.  So, a considerable speed up
improvement on CPU power time with a very slight trade-off when it comes
to bandwidth.

There are some reservations, for example, Kyoto developer, Robert Netzke,
points out that yes, there's a higher false positive rate when doing this.
It's about one out of 65,000 times of a false positive rate compared to
about one out of 200,000 times when using the traditional method.  The
developer, Csaba Purszki's, response is that even considering false
positives that are extremely unlikely, and in his tests he didn't run into
any, but theoretically there are some false positives, even considering
that, you still get a massive CPU time improvement.  Then, there's another
concern about how to handle these false positives.  And finally, I would
say the largest concern is about deterministic retries when it comes to
using binary fuse filters.  Basically, the question here is whether this
method allows for full deterministic retry so you get the same results
every time, or whether there could be some variances in different retries.
So, there's still some questions remain at play here.  You can check
Csaba's Delving post for more info on this topic, for a little explainer on
this, larger than the one we have in the newsletter, and for the
conversation that came with it.  But you can also go check on his website
to find the code and the methodology used to benchmark through this new
method that would be that would bring a huge performance improvement for
specifically mobile light clients that use compact block filters to obtain
transaction data in a private manner.  Anyone has any thoughts or questions
here?

**Olaoluwa Osuntokun**: Yeah, this is cool.  I saw this on Delving maybe
two weeks ago.  I didn't have a chance to comment or even read it, but I
was able to skim some of it now.  But yeah, it definitely does seem to be a
CPU sort of speed-up basically.  But I think based on experience with the
protocol for the past few years, I would say that I think the bigger win
would be reducing bandwidth.  Because I think what ends up having people
move away, I mean it's one of the things where I think most wallets stay,
but wallets actually end up using Esplora or Electrum basically, which is
basically a block server backend.  And the reason they do is even though
it's hardware privacy, basically you're just saving all your addresses into
the thing.  The one difficulty with GCS basically, and Bitcoin BIP158 at
times, the rescan catchup, because you need to download all the filters
since you were offline.  Then you also have the expectation of, depending
on the false positive rate, how many blocks you also download as well.
And that was something that was somewhat bandwidth heavy on some of these
mobile nodes.

So, I think interesting lines of research would actually be, can we reduce
the false positive rate while also minimizing the expected bandwidth of the
filters plus the actual blocks themselves?  And one cool thing that I saw
them get into a little bit later into the post, the question of higher
false positives.  Because right now you actually download one filter per
block.  What if you could download one filter for every 1,000 blocks?  If
that says no, then you know you're actually good.  So, I think, for
example, you can definitely do some optimization work looking at the sweet
spot in terms of the hierarchy itself, the false positive rate, and then
also the expected bandwidth that you're downloading as well.  And if that,
that would be great.  I'm kind of sad that most wallets end up using just
Esplora, basically, and it's horrible privacy, and they use it for the
Lightning nodes, and all this stuff everywhere else.  The other one was
meant to be kind of the solution to that basically.  It's one of those
things where when it comes down to it, people will go towards UX, and
that's just something that us developers need to accept, even though we
have all these cool privacy techniques in crypto, or whatever else.

Potentially, you can say maybe even some of the prior work around the STARK
proofs could help in this case, basically.  Because imagine you have a
STARK proof of something like utreexo basically, so it's able to obtain
those UTXOs directly.  Obviously, it is something where there's some
privacy implications there.  Maybe there's some sort of PIR move there.
But if we're able to sort of give them something more succinct and
authenticated, that would be ideal.  Because in the past, there was a
GETUTXO.  This is way back when people were using Bloom filters in BIP37
still, but that was completely unauthenticated.  Like, you would ask a node
for a UTXO, it would send you the UTXO, you'd be like, "Oh, cool, thanks.
I have 1,000 BTC", which obviously could be just fake.  But if you
actually had a proof to ground that itself, if you actually had a way to
privately obtain that proof, I think that's what a next-generation Bitcoin
wallet actually looks like in this case.

But either way, this is definitely really cool research.  I'll definitely
check out some of the work, particularly on the hierarchical filters,
because that's, I think, one area that's somewhat underexplored, to
actually reduce the total amount of bandwidth usage.  And if we can do
that, I think that'd be great, because then I'd be a little bit less sad
about all these wallets just using block explorers and sending all the data
over to them.

**Brandon Black**: Yeah, one thing I didn't quite understand from this was
what the migration would look like.  So, I mean it's not a consensus
change, but this would be kind of a new P2P BIP.  You support these new
filters, and then clients could query those filters if you support them.
So, there has to be a pretty big benefit to go through that work.  And I
think, as roasbeef said here, while the CPU usage is important, I'm not
sure how many marginal users that actually brings to using the filters
versus using public nodes.

**Olaoluwa Osuntokun**: Yeah, that's a really good point.  For what it's
worth, I'm not sure what that's really like, but there's a filter type for
each of the messages, basically.  So, feasibly, if we wanted to add this,
it could be added in.  But you're right, because then at that point, okay,
well you're going to actually double the space for node service, because we
need all the old filters and then also all the new filters as well.  But if
there is a way to basically do some clever thing with hierarchical filters
that can reduce the total bandwidth usage, I think that would be a huge
win.

**Brandon Black**: But that would make it worth the extra.

**Olaoluwa Osuntokun**: Exactly.  So, if there's a big bandwidth savings
thing, I think that's something I would definitely take a look at.  But
also, I think they were saying this paper wasn't out when we actually made
BIP158 few years ago, so maybe it's worth looking in the literature, or
see if there's any other similar papers that can actually give us smaller
filters and navigate some of the other trade-offs there.

**Gustavo Flores Echaiz**: Thank you guys for sharing those comments.
Yeah, I think this kind of opens a new discussion, how can we optimize with
all these new techniques, specifically compact block filters?  This is just
a first proposal that basically improves it at the filter size level.  So,
if you have a block with zero transactions or you have a block that is
super-full, there would be no difference, because the way the filters are
built makes no difference at the size of the block.  But you're now
discussing ideas, how can we create filters for not just one block but for
multiple blocks, and scale it across different levels?  And I think this is
just the beginning of a discussion or research that could lead to better
results.  And you're right, Brandon, it has to be proven that this has a
material improvement and not just a slight improvement, in order to be
adopted by the network.  The way I see it is, you simply just need a new
BIP with a new specification for filters, and nodes can freely implement
that or can use that library for filters, and clients can implement it as
well.

But yeah, interesting.  I invite listeners to go on Delving to share
feedback with Csaba, who unfortunately couldn't be here with us today.
But yeah, this is definitely a very interesting item to bring us closer to
improving the experience of specifically mobile light clients that use
compact block filters.  And yeah, I forgot, Laolu, that you were one of
the persons to work the most early on when it used to be called Neutrino in
LND.  So, it's great to have you comment on this, since you've obviously
thought about this a lot.

**Olaoluwa Osuntokun**: Yeah, definitely cool work.  And I definitely
encourage people to continue to improve light clients because right now,
they're still not that great, and I think they can definitely be a lot
better.

**Gustavo Flores Echaiz**: Perfect.  All right, so we move forward.  We
now go back to the changing consensus.  I'm going to give you, Brandon,
the floor here to lead us through this section.

_Post-quantum HD wallets with fallback SPHINCS keys_

**Brandon Black**: Awesome.  So, changing consensus, we already talked
about one thing, which was a post-quantum item.  We have three more quantum
things, and at least there's one that's not quantum.  It was almost all
quantum, but not a clean sweep.  So, the first item we have here in
Changing consensus is from Conduition about a way to do post-quantum
hierarchical deterministic wallets.  This goes right to what roasbeef
mentioned with hybrid type wallets.  So, this would be a way to make a
hybrid wallet that has both a secp256k1 key and a SPHINCS key in a single
derivation.

So, the basic structure is that you would have a new set of child key
derivation functions for HD wallets.  So, it's not the same as BIP32, but
it follows the same pattern.  And because the SPHINCS keys are hash-based,
they don't have the algebraic relationship that secp256k1 keys have that
allows us to do the non-hardened derivation using just the extended public
key.  As a result, all levels of the derivation tree below the last
hardened level use the same SPHINCS key.  And Conduition gets into some
talk about this, where you don't end up reusing an address because you
still have unique secp keys below that level, but you have the same SPHINCS
key once you get to the first non-hardened.  And that allows us to retain
the feature that, from an extended public key of this new type, public,
let's say, watch-only wallets can still derive the rest of the addresses,
and they do vary, but the SPHINCS key doesn't vary.

The reason this seems acceptable is that, of course, the SPHINCS key is a
fallback.  You're going to spend normally using the secp key, and only in
the event of a failure of secp would you use the SPHINCS key.  And in that
case, you'll probably be sweeping the whole wallet.  And so, it doesn't
matter that it's all the same key, you're sweeping the whole wallet at once
anyway.  So, that's kind of the summary of this.  This would be combined
with something like Pay-to-Merkle-Root (P2MR), BIP360, in order to provide
kind of a full post-quantum hybrid wallet type.  Again, for those cold
wallet users that need to be ready today, because they're going to leave
their funds cold for 10 years, 20 years, whatever, they can use something
this if we were to implement it to have reasonable privacy, be able to
spend those coins when they need to over the next 20 years.  But also, if
they stop moving it for a couple of years and then a quantum computer comes
along or another break in secp, their funds are still secure thanks to the
SPHINCS key that's also available there.  So, that's pretty much that
item.  Questions, comments?

**Olaoluwa Osuntokun**: Yeah, I think it's definitely cool.  I'm
definitely a fan of the hybrid techniques, just because it lets you hedge
in terms of putting and just betting everything on a particular thing, even
though we feel SPHINCS is pretty good just because it's just directly
hash-based.  But I think this makes a lot of sense.  There's probably the
one promise with maybe some of the last techniques in terms of giving us
more of that curve GAP functionality that we have with elliptic curves
today, because I think we'll definitely look back, assuming whatever comes
after EC.  EC is pretty nice.  It's super-small, super-elegant.  There's
all this structure in there, all these cool things that you can do.  So,
we're still catching up to the zoo that can enable there.  But maybe last
techniques in particular can actually get some stuff there.  But we can at
least do something more conservative first, and then maybe in the future,
see what those hold.

**Brandon Black**: Yeah, and that's what I like about this, is it keeps
leveraging those cool side benefits of secp essentially for as long as we
can, but it gives people the escape in case they need it.  All right, I
think we'll go right along.

**Gustavo Flores Echaiz**: Yeah, well, it's just really cool to see that
despite the limitations around hash-based signatures, we're still able to
maintain this same user experience users are used to and to build like
that.  So, really cool item.

_Discussion of a post-quantum output type_

**Brandon Black**: Yeah.  So, the next item is relating to what we would
put these hybrid signatures or hybrid addresses inside.  There's been
discussion of obviously, BIP360 is out there, which is P2MR as a plain
post-quantum output type, where it's a hash at the root.  There's also
been discussion in those conversations of, should we instead do a P2TR v2
that opts into eventually disabling the keypath, so we can keep that
benefit of the inexpensive key spend using secp, while also giving people
the information that that may be turned off in the future?  So, it's
really only appropriate for use with a hybrid wallet that also has some
kind of a post-quantum key below the keypath.  And I think the discussion
here was basically that we probably don't want to do that still
keypath-supporting or keyspend-supporting output type, we want to use a
pure post-quantum type.  Because as I've been saying throughout this
podcast today, there's different wallet use cases, and there doesn't really
exist a wallet for whom it would make sense to allow turning off the
keyspend, but they'd still need the keyspend today.  If you're a deep cold
storage wallet, you don't want to have the vulnerability of the keyspend
in the event of a quantum computer.  You're going to use the plain
post-quantum output type.  If you're an active user with small outputs,
you're just going to keep using taproot for the saving of fees.  You're
not even going to bother with the backup SPHINCS path, you'll just use
plain secp.  And there's just not this in-between user who's like, "No, I
need the backup, but I also need the keyspend.  I'm so cheap".  That's not
a user that exists.  So, that was basically the discussion here.

I think, to me, I kind of came down on that side as well, that a plain
post-quantum output type, like a hashed root of some scripts, probably
makes the most sense.  That gives us a kind of clean division of who's
doing what with their outputs.  It also lets us do things like track what
kinds of users are moving to post quantum, what size of outputs are using
the pure post-quantum one.  And it just doesn't have that confusion that
could arise, because obviously if someone were to use the P2TR v2 with a
keyspend, even though it technically opts into the disabling of that
keyspend, someone could still cry about it later.  So, by making it a pure
merkle root, everyone knows there's no keyspend because that's the way
it's built from the beginning, and that seems the way to go.  So, that's
that.  Questions, comments?

**Olaoluwa Osuntokun**: Yeah, I guess the one thing I'll say is like, I
think it's important people separate into sort of the proactive fork and
the reactive emergency fork basically.  So, I think we should definitely
have the proactive one basically and people opt into that, because then at
that point, people have however many years to upgrade.  It won't be a
final thing like, "Oh, shit, we need to all upgrade right now", and that
would be a disaster in terms of maybe block space and congestion, and so
forth.  So, yeah, I think it's important to always separate those two of
the proactive thing, then the reactive rescue stuff, which is the emergency
stuff.  Because then, that's something that we can obviously code now, but
it'll be a thing around the button basically, and people need to decide at
that particular point, while at least this one, you can just put it out
there.  Then, the sooner we get the corrective fork out there soon, the
sooner people can sort of stop talking about it.  In a sense, people have
been just saying, "Can you ship that thing?" and use it if you don't want
to use it or not basically, but then we can still have sort of the
emergency thing ready in the background.

_Proposal to embed post-quantum keys in tapscript without consensus changes_

**Brandon Black**: All right.  Come right along to our next item here,
which again, more quantum.  So, this also actually touches on something
that you mentioned earlier, roasbeef.  Daniel Buchner wrote to the mailing
list.  It didn't get a lot of discussion yet, but it is a proposal to
build a specific kind of set of key types that you can commit to now.  And
so, we'd be looking at, okay, well, there's SPHINCS and there's SHRINCS
and there's this and that and the other thing, different key types you
might commit to now.  Let's just write a BIP that defines all those key
types and prefixes for them that can be used with current OP_CHECKSIG,
because OPCHECKSIG already has undefined key types, you're allowed to use
them, they are spendable today.  They're non-standard but spendable today,
if you just put a non-empty signature with them.  That's the definition of
BIP342 unknown key types.  The point is, we already have CHECKSIG with
unknown key types.  So, if we were to just define prefixes for a bunch of
post-quantum key types today and say, "This is how they would be verified
if they ever get turned on", then people can start writing those into their
scripts in a taproot script today, and be able to spend their coins, even
if we someday disable all secp spends.

I don't have kind of a strong opinion about this myself, but I thought it's
nice to see things, like what roasbeef was talking about, written down
concretely, "Here's what it would look if we were to define a bunch of
specific post-quantum key types, based on the current state of the
research, and give them prefixes, give them lengths, and put them into
OP_CHECKSIG as potential keys that could be enabled with real checking
later if needed".  So, that's kind of the summary there.  I don't know if
it's a great idea because now, you're depending on a later consensus change
where the consensus change itself is not yet authored.  On the other hand,
committing it to a bunch of keys that have known structure to them, they
have a known tree of hash outputs in them, could enable spending coins in a
lot of different ways.  So, people that have done this have given
themselves potentially another hedge for being able to retain access to
their coins in the event of a break in secp later.  That's the summary
there, it's an interesting thing to think about.  Your thoughts?

**Olaoluwa Osuntokun**: Yeah.  I definitely think it's interesting.  One
thing around hedging, you can say perhaps people should maybe reconsider
making BIP86 wallets today.  For example, if someone had another BIP
that's slightly different, that's BIP86 but it's a scriptpath, that's
another level of hedge, because the actual penalty there isn't that large
because it's just going to be literally a pubkey OP_CHECKSIG script, so
maybe tens of bytes basically.  So, that's another way to hedge.  Maybe
someone could put that out there because then at that point, your hedging
gets sort of if keyspend's disabled.  But then, you could also add
something this along the side of it as well at the cost of maybe a 32-byte
control block, because you could sort of have all the advanced stuff on the
left side of the tree and then have your simple keyspend on the right.  So,
you basically have an unbalanced tree to optimize for that keyspend path.
So, it's sort of like, a poor man's keyspend and hedging right now, at
least fees are pretty cheap.  So, maybe you pay whatever in taproot for
vbytes, just have to be a few vbytes extra basically.

So, I think if people want to hedge that, I think that could make a lot of
sense, particularly for maybe people that have very, very large wallets
that maybe they're turning a lot, like some exchange, that doesn't work.
This could be a way to hedge because maybe at that point, you're already
making a ton of money and the extra fees maybe is a marginal call for that
extra security in the future.

**Brandon Black**: Yeah, just one thing I want to make sure is clear to
everyone, that disabling the keyspend today is not possible in the face of
a quantum adversary, because all taproot outputs are spendable by a quantum
computer.  Even though we may not know the secret key corresponding to that
taproot output, the quantum computer can create a secret key that
corresponds to it and spend using the keyspend, even if we think we've
disabled it with a NUMS key or something.  A lot of these things are best
combined with something like BIP360.  That's one of the reasons I'm a big
BIP360 supporter, is that with BIP360, people can realistically disable
keyspending today and get that kind of benefit Laolu was just mentioning,
of having a slightly, but really slightly more expensive keyspend today
with also meaningful hedges for the future.  So, do BIP360.

**Gustavo Flores Echaiz**: So, is my understanding correct that this could
either go with BIP360, where the keyspend path is disabled and you also
have this; but it could also just be in regular P2TR that in a hypothetical
future where there's a disabling of quantum-vulnerable spending, you could
also have this as a second hedging; so it's those two scenarios?

**Brandon Black**: Yeah, exactly.  Because we have out there, you know,
BIP361 has been authored and numbered now.  So, people are talking about
the potential for disabling secp exposed public key spends.  I do not
support that, but that's something that people are genuinely talking about.
And look, people are talking about it because some people might think it's
a good idea and we should be as ready as possible, again to Laolu's point,
to retain ownership for as many people as possible and as many future
scenarios as possible.  So, yes, it is exactly that.  You have two sides
to the hedge.  One is retaining ownership in the event of a disabling of
keyspends; and the other is, this is one way to potentially embed
futureproof into your P2MR BIP360 outputs.

**Gustavo Flores Echaiz**: Makes sense.  Thank you for explaining.

_BIP54 demonstration of slow blocks on signet_

**Brandon Black**: Cool.  And our last Changing consensus item, we finally
get to leave quantum behind for a moment.  People are working on BIP54 to
close up some old known bugs or warts, maybe not necessarily bugs, but
warts in Bitcoin's consensus rules.  In particular, the one that was being
studied here was the fact that old legacy outputs had the quadratic hashing
bug and a few other issues that could be exploited to create very
expensive-to-validate blocks.  And so, to demonstrate this and to show how
BIP54 would fix it, Antoine Poinsot and others worked together on a demo
on signet where they made some very slow-to-validate blocks.  They did not
go as far as they could on this, and yet we saw blocks taking over a minute
to validate on some systems and propagating very slowly through the signet
network as a result.  You can see the full results in the links provided.
But I think that was a valuable demonstration of why BIP54 is needed.

Just to, I guess, explain more since we're talking about it.  The reason
this hasn't been exploited to date is that miners are incentivized against
doing this.  Miners want their blocks to be fast to validate, because that
gets their blocks to as many other nodes as possible and reduces the chance
of their own block being orphaned.  So, a self-incentivized miner is not
going to make a slow block.  However, as we see mining becoming more
centralized, unfortunately, attacks like this make more sense potentially
for a miner who has a lot of hash power.  They could potentially delay
other miners from seeing their real blocks by publishing a slow block, as
well as creating a real block and then publishing it all later.  There are
various attacks that are possible in a somewhat centralized mining regime,
and BIP54 helps to close some of those attack vectors.  So, I think it's
getting more and more important in the world of large, centralized mining
pools.  And so, it's great to see a real demo here, because I've seen
people actually saying to me, like, "Why are we bothering with these
consensus bugs in BIP54?"  Well, this is why they did the demo.  So, the
demo is, "Here's why we have to do these improvements and protect the
network from slow blocks this".  And again, these were not the slowest they
could be.  These were one-minute blocks.  You can make, I think, up to
almost an hour to validate blocks using the worst-case scenarios of an
attack block.

**Olaoluwa Osuntokun**: Yeah, this is definitely cool as far as a real
world demo, because I think people don't realize that even though we fixed
a bunch of issues in new script, like taproot, and segwit, somewhere
there's a bunch of warts in the older script there.  And so, yeah, I mean
I think it'd be great if this gets in.  I guess I have two opinions.  One
is that hopefully, if this happens, then people feel like we actually have
some implications in terms of other potential soft forks, because maybe
we'll actually have one in the future with the quantum stuff.  But the
other hand is, well, if we have the coordination, should we do something
else?  It's always tempting like, "Okay, well, do we just add the other
thing?  Hey, if we're upgrading already, let's not do this whole thing
again in a few years".  So, I think it'd be interesting to see which
direction it goes.  And people would say, "Okay, we'll do this very, very
small narrow thing to show that we can actually fix bugs in the system to
make it more robust".  Or it's like, "Hey, we're this opportunity because
people already sort of have an appetite for making changes.  Maybe let's do
some other stuff".

Obviously, that's a whole other conversation.  There's going to be
conferences and blah blah blah.  But that's something that I can't help
but think about.

**Brandon Black**: Yeah, and that conversation comes up even around BIP54
itself.  BIP54, for those who don't know, concludes four separate changes.
There's the fix for slow blocks; there's a fix for a time warp attack,
which is another kind of similar protection against centralized mining
attack; then there's also a fix for the potential for a duplicate txid on
the coinbase transaction, which has been seen once before, I believe, in
Bitcoin's history; and also a fix for a risk to light clients or other
non-full nodes who are validating that transactions are included based on
headers by eliminating 64-byte transactions from consensus.  So, it is
already in that camp of, "Oh, we're going to get a change to fix these
really important things.  Let's do a couple of other consensus fixes at the
same time".  That's why it's called the great consensus cleanup.  And so,
the conversation already is, "Is this already too many things combined?" or,
as Laolu said, "Should we combine even more things into it?"  No one knows
the right answer, it's an ongoing conversation.

All right.  I think that's a wrap for Changing consensus.  What else do we
talk about, Gustavo?

**Gustavo Flores Echaiz**: Yes, so thank you, Brandon, that was great.
And thank you, roasbeef, for all those great comments, too.  So, now
we've got the two final sections of the newsletter, the Release and release
candidates, and then the Notable code and documentation changes.  These
are the parts that I've wrote and that I will present.

_Core Lightning 26.04.1_

So, first, we have a maintenance release in Core Lightning (CLN) version
26.04.01, which includes some fixes related to the gossip protocol, and
also some build system fixes for environments that experience problems
immediately after the last major release.  So, in the last newsletter, or
I believe maybe the one before, we covered the release of CLN 26.04, but
it had some issues.  What were those issues specifically?  Well, a CLN
node was incorrectly accepting channel announcement messages that were
invalidly ordered, and that was causing gossip data corruption issues.  So,
now, CLN correctly rejects invalidly-ordered channel announcement messages,
which prevents gossip store corruption and stress on gossip readers.

So, there's also other little, small fixes related to some format
specifiers in the splicing logs, and also the usage of _int128 in the
bookkeeper component.  Those were creating build issues, specifically on
32-bit ARM systems, and also when pushing to Docker Hub.  So, now these
problems have been fixed.  Users with 32-bit systems should no longer have
problems with this new version of CLN, and also there should be no more
gossip store corruption issues.

_BTCPay Server 2.3.8_

The next two releases are BTCPay Server 2.3.8 and 2.3.9.  So, 2.3.8 is a
minor release with a few improvements related to the subscription feature,
which we've discussed previously in this podcast, which basically allows a
BTCPay Server store manager to offer its subscription to its users where
they get, let's say, a monthly email telling them to pay this Bitcoin or
Lightning invoice to maintain access to a monthly recurring subscription
model.  So, there's been improvements on how to interface through the API
with the subscription feature.  One interesting improvement or feature from
this release is the support for LUD-21, also called LNURL-pay Verify.
This is an unauthenticated endpoint that allows, for example, a website
that is leveraging BTCPay Server for payments, it allows a service that
isn't authenticated to verify if a BOLT11 invoice that was created from
LNURL-pay has been settled.  Because this external service doesn't have
the preimage, it requires another manner to verify that the payment was
made.  So, this is one of the main features from this release, but there's
just a few other fixes and improvements related.

_BTCPay Server 2.3.9_

Then you also have 2.3.9, which is a follow-up, an immediate follow-up as
a maintenance release for the previous one, that addresses server recovery
after a plugin crash.  So, a plugin that would crash the server would then
create issues; the server was unable to recover.  And also, in 2.3.8,
accidentally xpubs became unparsable, so that's also been fixed.  Any
comments here or we're free to move forward?  Cool.

_Bitcoin Core #33671_

So, then now we are in the Notable code and documentation changes which we
have about eight items this week.  Four out of them are from the Bitcoin
Core repository.  So, the first one, Bitcoin Core #33671, adds a new field
called nonmempool to the getbalances RPC command.  The getbalances RPC
command was introduced a long time ago, I believe six years ago.  We
covered it in a very early newsletter, #46.  And getbalances allows you to
obtain all the balances that are for you to spend that the wallet can't
spend, also known as IsMine.  So, these are the balances that are yours,
but also the watch-only balances are also specified in this call.  So, a
common problem or something that was missing from this command was that if
your wallet spent a UTXO in a transaction that was neither confirmed and
neither in its mempool, so it was either un-broadcasted or it was a
completely un-standard transaction that was spent, even if it conflicted
with the mempool policy rules of its own node, or let's say it was evicted
from its own mempool, or a transaction that was part of a too long mempool
change so it got evicted as well, naturally this change of balance would
simply not reflect on this command.  So, for example, you had two UTXOs
in your wallet of 1 bitcoin each and you would spend one of those.
Getbalances would simply not reflect the fact that you spent that output
and it would still show 2 bitcoins as a balance.

So, what this change does, it adds a new field where, in the nonmempool
field, you can see the spending that occurred, but you also get it added
into the other fields, into the mine buckets.  So, for example, in the
mine buckets, you have a field called trusted that is for outputs that were
spent, either created by the wallet itself, or which have at least one
confirmation.  Or you have also untrusted, pending outputs that were paid
to you, but you don't necessarily trust them because they're unconfirmed,
so you don't want to necessarily spend them because there could be an issue
later.  So, now, if you spend 1 bitcoin, it gets added in your balance.
The fact that previously, it would be completely ignored, now it gets added
in one field and gets subtracted in the nonmempool field.  So, the overall
wallet's balance remains unchanged, however the mempool mismatch is now
explicit.  So, you can have all details around your transactions that are
not in the mempool and not confirmed either through this getbalances command
with this new nonmempool field.

**Brandon Black**: This is such an interesting change.  I've run into
problems like this in kind of a commercial capacity trying to help people
work through stuck wallets, where they have all of their ancestors in two
long chains and they're trying to get a CPFP through, or something, in
order to spend that last one.  But you can't see the balance, you can't see
the transaction because you can't broadcast it.  So, this is not a
super-common situation that people get into, but for those especially
running bigger wallets, using Core potentially as a backend, this will make
a big difference in being able to get the accounting right, and then get
those, whether they're non-standard or two long chains, or whatever, get
those confirmed via an accelerator or going straight to a miner, or
whatever, and then have the wallet kind of be in a predictable state while
you work on getting those things confirmed through other methods.

Another thing I wanted to say just for those listening, I don't think it's
talked about enough.  You might want to say, "Well, why don't you just
throw away the transaction and forget about it, if you can't get it
broadcast?  And then the balance would have been fine without this change".
But it's important that we all remember that once you've signed a Bitcoin
transaction, it's valid forever and you can't really make it invalid
without spending one of its inputs in another way.  And so, it's actually
very important that the wallet keep track of those transactions that have
been signed, as long as they have not been double-spent away to make them
completely invalid.  People have lost money because of situations where
they signed the transaction a long time ago, they broadcast it, it got
kicked out of the mempool, they thought that money was now unspent.  And
then, some months later, that transaction was rebroadcast from somewhere
else in the network, someone had saved a copy of it, and the money is then
spent, even though they had already kind of counted it as not spent.

So, it's good that the Core wallet here is holding onto those transactions,
even though it can't broadcast them today, because they've been signed and
they could come back at some point later.

**Gustavo Flores Echaiz**: Thank you for adding that context.  Yeah, I
completely agree with that.  It has never happened to me personally either,
but I do see how some people could run into this problem.  And so, this is
just a great addition to solve it.

_Bitcoin Core #34885_

So, next item, Bitcoin Core #34885.  Here, a new endpoint is added to the
libbitcoinkernel C API, which we've discussed many times already, and was
introduced in Newsletter #380 and the accompanying episode.  So, here, a
new method is added, called btck_block_tree_entry_get_ancestor(), that
allows a caller to retrieve the ancestor of a block at a specific height on
its chain branch.  So, previously, callers would have to walk backwards one
block at a time with repeated calls to get previous instead of get
ancestors.  So, let's say if you wanted your own height, 900,000, and you
want to get the block, 800,000, of that specific chain branch, you would
have to make 100,000 calls to get previous and do that repeatedly, and also
when you're trying to construct a block locator from a stale or forked tip.
Okay, so now you can directly request the ancestors at the needed height.
And also, what's important to precis is that this works not only on the
main chain, on the active chain, but on any chain.  So, if you were to have
multiple chains in parallel when you find yourself in a reorg scenario,
this also allows you to obtain the ancestor in the specific height but in
the specific chain branch of the specific block you're looking into.  So,
a bit of an improvement on the libbitcoinkernel API.  Over the past few
months, we've seen new improvements and this is just the latest one.

_Bitcoin Core #33920_

So, the next item, Bitcoin Core #33920, adds a new RPC command, called
exportasmap, which exports the node's ASMap, which is the map of autonomous
systems that is embedded at build time, to a file.  So, instead of just
having this embedded into the binary, you can now export it to a file,
inspect it, validate it, analyze it.  So, we covered initially in
newsletter #394 that this ASMap, autonomous systems map, could now be
optionally included in the Bitcoin Core binary, but there was no way to
extract it.  So, now, this allows someone to push it to a file to analyze
it and to verify it as well.  We've covered the autonomous system map in
previous newsletters as well.  The goal here is to improve the resistance
against eclipse attacks by ensuring that you're diversifying peer
connections across autonomous systems.  You don't want your node to find
itself only connected to peers that use the same autonomous systems, because
technically you could then suffer from an eclipse attack when your node is
isolated from all honest peers but remains connected to at least one
malicious peer.  So, this is now just an addition to this as we've covered
before.

I also want to say that ASMap into the Bitcoin Core binary was part of
Bitcoin Core v31.  And in previous newsletters, we've covered the release
of Bitcoin Core 31 and we've analyzed specifically this main, important
change that occurred in Bitcoin Core 31.

_Bitcoin Core #34911_

Next item, Bitcoin Core #34911, removes some duplicated fields related to
RBF (Replace By Fee).  These are removed from several mempool RPC
responses, but they can be explicitly requested using the deprecatedrpc
configuration option.  So, precisely the getmempoolinfo RPC no longer
returns the full RBF field by default, because fullrbf is now the default
behavior since Bitcoin Core 28, but you could still disable it in Bitcoin
Core 28.  And now, the option was completely removed in Bitcoin Core 29,
so you can no longer disable it in the newer versions.  So, now, you don't
even need to have the fullrbf field in the getmempoolinfo, because your
node simply assumes that all transactions are signaling fullrbf, because
that is your mempool by default in all Bitcoin Core nodes post v29.  You
will accept an RBF replacement of any transaction that is in your mempool.

So, other RPCs, such as getrawmempool, getmempoolentry, getmempoolancestors
and getmempooldescendants no longer return the field bip125-replaceable
which was the previous version, the opt-in RBF version, that predated
fullrbf that was introduced many years ago, about ten years ago.  So, now
that we are in this era where fullrbf is simply the default in modern
contemporary Bitcoin Core versions, we no longer need these fields in these
multiple mempool RPC commands.  However, you can re-enable them using the
deprecatedrpc configuration option.

**Brandon Black**: I'm so glad to see this.  It's great to see the Bitcoin
Core maintainers cleaning up cruft, so we don't have stuff sitting around
that's no longer relevant.  I know it's a hard job to do that.  And I
mean, any software maintainership is hard to really go back and clean up
cruft as it's crufty.  So, this is just a great example of them doing the
hard work to make Bitcoin Core long-term maintainable software.

_BIPs #1548_

**Gustavo Flores Echaiz**: Completely agree.  Next item.  So, as past
weeks' episodes, we've moved the BIPs (Bitcoin Improvement Proposal) items
higher so they're now on top, and all the other repositories that are not
Bitcoin Core or the BIPs repository come after.  So, in this newsletter,
we cover the item BIPs #1548 which adds BIP391, also called a specification
for Binary Output Descriptors (BOD), but adds it with a closed status and
lists BIP393 as a proposed replacement.  It also notes that BIP391, this
one that we're just talking about, was withdrawn after BIP393 was proposed
as an alternative method for handling wallet metadata, such as descriptor
annotations.  So, in Newsletter #400, we covered the BIP393 item, which
specifies an optional annotation syntax for output script descriptors,
which enable wallets to store specifically recovery hints, such as the
birthday height of the wallet, to speed up wallet scanning, of course.
And that has been also very impactful for silent payment scanning, because
silent payment scanning is way heavier.

So, there was this discussion in the BIPs repository that predated BIP393
in BIP391.  The BIP editor decided to merge BIP391 but give it a closed
status because the author had withdrawn his proposal after the new BIP393.
So, it remains there with a closed status, with a historical record.  But
BIP393 is the preferred specification for handling wallet metadata, such as
descriptor annotations.

**Brandon Black**: This is a great example of how the health of the BIP
repository kind of reflects in the health of the whole Bitcoin ecosystem,
and how it's now a much healthier place than it has been in years past.  I
know Murch, our regular co-host in the seat, does a ton of work to make
that happen.  And it's so important that these things happen, where even
BIPs that are now bad ideas that are withdrawn or closed or whatever, they
get published, because that's how we document the proposals.  It's not
Bitcoin Improvement Results, it's Bitcoin Improvement Proposals.  And it's
great to see these proposals being documented, so we know things that have
been considered, that they've been closed, and we know why, what replaced
them, all of that being documented.  The BIPs repository, being a live
place where we know that history and we know the path things are moving
towards, really opens up the ecosystem to improvement.  So, it's great to
see this.

**Gustavo Flores Echaiz**: I completely agree.  I read through the PR
discussion for this item and you can see that the author's proposal was
kind of superseded while it was in review.  However, it was still assigned
a BIP number and it was still added to the repository, just with a closed
status.  So, the trail remains that this author made this proposal, and
others can also see the work that was done to arrive to the final solution.
It doesn't just come up by itself, there's a whole process of discussion
and research to arrive to later solutions.

_HWI #831_

Okay, so the next item is on the Hardware Wallet Interface Repository.
This is a very small one, #831.  It adds support for the Ledger Nano Gen5
hardware signing device.  So, this is the latest model from the Ledger
company.  And Hardware Wallet Interface is a repository from the Bitcoin
Core project.  The Bitcoin Hardware Wallet Interface is a Python library
and command line tool for interacting with hardware wallets that not only
Bitcoin Core users but other wallets also depend on.  So, this allows them
for easier integration of new hardware wallet models.  In this newsletter,
we covered the addition for Ledger Nano Gen5 support for this hardware
signing device.

_BDK #2188_

So, the next two and final items are from the BDK repository.  So, the
first one, #2188, is actually an important fix.  When you have a wallet
that uses BDK and it depends on an Electrum server to obtain transaction
data from the Bitcoin Network, BDK would request a specific txid.  However,
the Electrum server could answer with a different transaction and BDK would
simply not verify that it was the same txid.  So, this was obviously
unsecure.  And now, BDK starts verifying that the transaction returned
matches the requested txid before caching or using it.  So, this seems
like a small item, but I think there's a few security implications here, so
important nonetheless.

_BDK #2115_

And the next and final item, BDK #2115, adds previous-block-hash awareness
to CheckPoint by extending the ToBlockHash trait with an optional
prev_blockhash() method.  So, this allows finally BDK to verify that
adjacent checkpoints connect between themselves when their payload contains
previous-block-hash information.  So, optionally, you can make it so that
one checkpoint has this specific previous-block-hash information, and then
you can match it to a previous hash by comparing the hashes.  So, this
also prevents a method called merge_chains() from a conflicting height-0
checkpoint as a normal reorg and replacing it, because the behavior at the
genesis block is very different from further blocks.  It's not just a
normal reorg, it's a completely different chain.  So, this also fixes that
issue.

We've covered, in Newsletter #372 and #390, previous work that was done in
the BDK repository, specifically for CheckPoint.  So, we can also check
those newsletters and the episodes if you want to follow the work that had
been done to arrive to this.  But now, if two checkpoint chains disagree on
genesis, the merging of these two chains will simply fail, because like I
said, it's not two blocks being merged from a potential reorg, but it's
just two separate chains that are completely different.  Any thoughts here?

**Brandon Black**: No, I mean, it's just nice to see this also moving
forward.  But I don't have any other comments.  BDK is awesome though.

**Gustavo Flores Echaiz**: Yes.  All right, perfect.  Well, this completes
the Notable code and documentation changes section, and also completes the
newsletter.  Thank you for listening.  Thank you, Brandon, for co-hosting,
and thank you to roasbeef for being here with us.  We'll see you all next
week.

**Brandon Black**: Thanks very much, Gustavo.  See you.

{% include references.md %}
