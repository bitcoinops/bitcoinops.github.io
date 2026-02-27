---
title: 'Bitcoin Optech Newsletter #391 Recap Podcast'
permalink: /en/podcast/2026/02/10/
reference: /en/newsletters/2026/02/06/
name: 2026-02-10-recap
slug: 2026-02-10-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by Toby
Sharp, Chris Hyunhum Cho, Jonas Nick, and Antoine Poinsot to discuss [Newsletter #391]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-1-11/417919424-44100-2-7b0015d5bbdff.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone this is Bitcoin Optech Newsletter #391 Recap.
Today, we're going to talk about a constant-time parallelized UTXO database and
workaround there; we have a higher-level language for writing Bitcoin Script
that we're going to get into; there's an idea to mitigate dust attacks on the
network; and then we have our monthly Changing consensus segment, which this
month includes BIP54 changing consensus, it also has a few different
post-quantum signature discussions around SHRINCS, Falcon, and SLH-DSA
verification performance.  In order to help us through some of these items, we
have a handful of guests.  Murch, Gustavo and I are joined by Toby.  Toby, you
want to introduce yourself real quick?

**Toby Sharp**: Hi, I'm Toby and I'm a software developer.

**Mike Schmidt**: Chris has joined us as well.

**Chris Hyunhum Cho**: Hi, I'm Chris, I'm PhD student at Korea University.

**Mike Schmidt**: Jonas?

**Jonas Nick**: Hello everyone, I'm doing cryptographic research at Blockstream.

**Mike Schmidt**: Awesome.  And we will have one more guest later in the
program.  And if you're following along in the newsletter, we're going to go a
bit out of order.  We have some scheduling constraints and we have our guests
here.  So, apologies for that.

_SHRINCS: 324-byte stateful post-quantum signatures with static backups_

But we're going to jump down actually to the Changing consensus segment, and
we're going to talk about SHRINCS, which is a 324-byte stateful post quantum
signature scheme with static backups.  Jonas, we covered and we had on Mike to
discuss your and his hash-based signature schemes for Bitcoin.  That was in
Newsletter and Podcast #386.  And now, we have you on this month to talk about
SHRINCS.  Maybe quickly summarize the previous discussion for context, and then
how does SHRINCS fit into that broader discussion?

**Jonas Nick**: Yes, all right.  So, I guess last time, Mike talked about these
various approaches to post-quantum signatures.  One of those approaches is based
on assumptions around hashes.  Those signatures are not known to be very compact
and there are also several degrees of freedom on how to design them.  For
example, there are two different categories.  There are stateful schemes and
stateless schemes.  Stateful schemes require some sort of state, usually an
index, for example, that is going to be incremented every time you make a
signature.  That is different to the state that we, for example, know from
protocols like MuSig or FROST, where you only have state for a single signing
session.  Here, you have state for the entire lifetime of your public-private
key pair.  Now, the problem is also that if you were to not properly manage that
state, for example, by not incrementing the index, forgetting what the index is,
or resetting it to some other number, an older number let's say, then you reduce
your security tremendously; or more directly, it would allow actual forgeries of
signatures and therefore people stealing your coins.

**Mark Erhardt**: I thought it more or less directly leaks the private key.  So,
does it allow signature forgeries or does it leak the key, or does the
distinction even matter?

**Jonas Nick**: The distinction here does not really matter, no.  Maybe let's
say it like this.  What you're revealing when you produce two different
signatures with the same state, you reveal part of the secret key and with that
part, you can forge alternative messages.  So, you cannot produce a signature
for any message, but rather for some subset.  So, depending on how these two
signatures for the same state look like and what message they sign, you might be
able to forge a signature for any message or just for a small subset where only
one bit is different.  But we generally consider it broken, so let's not reuse
state at all.

**Mike Schmidt**: Right, so is a stateful scheme bad then?  Why do we want a
stateful scheme?

**Jonas Nick**: The reason why we want a stateful scheme is that we can create
very, very compact post-quantum signatures that way, more compact than, let's
say, lattice-based signatures and more compact than stateless signatures, for
some specific applications, such as Bitcoin wallets I should say.  And the
reason is that in Bitcoin, we usually do very few signatures for a single public
key, at least on layer 1, because we try to avoid address reuse.  So usually, we
receive some coins on a fresh address, and then we create a transaction, sign
and send it somewhere else, and then we should typically never reuse the public
key unless something goes wrong, we need to bump a fee, etc, then maybe we do
two signatures or three or something like that.

So, to understand why these signatures can be very compact, I would need to
introduce this concept of one-time signature.  So, one-time signature scheme is
a signature scheme where you can only sign once per public key.  So, only one
single message per public key pair.  Don't sign twice, because that would allow
forgeries.  How do you produce a many-time signature scheme from that?  Well,
you take a single public key from the one-time signature scheme and you put it
in the merkle tree.  Or you take many one-time signature schemes' public key,
put it in the merkle tree, and then you have this large tree.  You start on the
leftmost leaf, first signature you do with that public key.  You store the
state, you remember, "I've already signed with this one", so for the next
signature, you go to the next one, and so on.  So, part of your signature is the
signature for the one-time signature scheme plus the merkle proof that proves
that this public key is actually contained in your overall many-time public key.
I should probably say this.  So, the public key for this many-time scheme would
be just the root of this large merkle tree of one-time signature scheme public
keys.

So far, that doesn't give us any benefits.  What gives us benefits is that we
don't have to use a balanced tree.  We can use an extremely unbalanced tree,
which essentially it looks like just a diagonal.  So, the first one-time public
key is on layer 1, and the second one on layer 2 of the tree, third one on layer
3, etc.  So, that means for the first signature. your signature only consists of
the one-time signature and the sibling in the merkle tree, in order to produce
the merkle proof.  So, the signature for this one-time signature scheme is very
small, I think it's 256 bytes, and then 32- or 16-byte sibling, so you arrive at
this very short signature.  This is short, this is stateful, but one of the big
problems is that this statefulness means that every time, that you cannot really
have static backups, which is something that we're used to in Bitcoin, right?
In Bitcoin we have a single seed phrase, or whatever, backed up, and from that
we can restore our wallet.  And it doesn't really work with stateful signatures
anymore, because every time we make a signature, we have to remember, "Okay,
we've made a signature with that public key", so we would have to update our
backup such that when we restore our backup on a new device, we know which
public keys we've already used for signing.

**Mark Erhardt**: To chime in briefly, one advantage at least of this would be
that address reuse finally gets very, very expensive.

**Jonas Nick**: Yes, that is true.  But sometimes, we want to sign multiple
times with a single public key, for example to increase the fee or things like
that.  So, we can't have static backups.  And SHRINCS is a solution to that,
because essentially it combines the stateful idea, that produces very compact
signatures, with a stateless scheme.  So, essentially your public key is a hash
of a stateful signature scheme public key and a stateless signature public key.
So, we've talked about the merkle tree of one-time signatures for the stateful
scheme.  So, we take that public key and we just add another sibling to that
public key, which is a public key for the stateless signature scheme, and that
gives us a new merkle root for the entire scheme, where the two children of the
merkle root are one public key for the stateful scheme, one for the stateless
scheme.

So, what does that mean?  It means that, so the example that is probably the
best application for this is when you have some sort of dedicated signing device
that is able to keep state securely, which in my mind is something different
than a Bitcoin Core desktop wallet, where users have access to the wallet.dat so
they could back it up, restore it.  And that's bad, because it will lead to
state reuse, etc, signature forgery.  So, we have a dedicated signing device,
you generate the key on the device, this device is able to keep state securely,
so you can use this very efficient stateful scheme to produce signatures.  But
you also have a static backup.  A static backup is your whatever secret key.
What is important is anytime you import this backup on a new device, the new
device will recognize, "Okay, this has been an imported seed, so now I have to
use the stateless path because now I don't know the state anymore".  Or if the
signing device would, for whatever reason, lose the state, it becomes corrupted,
something like that, then it would just choose to sign with the stateless path.
Stateless path, much less compact, so we want to avoid that.  It's like between
3 kB and 8 kB for hash-based signatures depending on which exact parameters you
choose.

So, on the device where you initialized your wallet on that, created the seed,
signatures will be very compact.  If you have to restore your seed on a
different device, you probably want to use the stateless path to sweep to a new
wallet that uses this, that is able to re-initialize, create new states, and
then use another stateful path for this new public key for this new wallet that
you created.

**Mark Erhardt**: Right, so this sounds like something that could be used in
enterprise HSMs or with a new generation of hardware wallets, hardware signers.
But otherwise, the trade-offs seem very dangerous.  It seems fairly easy to
accidentally leak your private key under misuse.  And it's still, well, at least
it's only about five times more expensive than current schnorr signatures.

**Jonas Nick**: Right.  I mean, that is one of the open questions how to deal
with the state.  And I'd like to hear some feedback from wallet developers,
especially if they build their own devices.  As I said, on a desktop wallet, I'm
not so sure in the thread on Delving Bitcoin, I tried to experiment a little bit
with using the trusted platform module to store some data that cannot be easily
backed up.  In principle, it doesn't even need to do that.  It could be a
server, but then you trust the server to not replace state.  And if they do,
they can create a forgery, so that sounds terrible.  And I suppose the same is
potentially true for mobile wallets, because mobile wallets you now need to make
sure that they don't back up the wallet in the cloud.  Maybe they can use the
secure element to store state there securely, but that is an open question.

**Mike Schmidt**: Jonas, what is the maturity of these different pieces, you
said these two pieces you sort of put together; what is the maturity of each and
then how do you think about the novelty of combining them together?

**Jonas Nick**: I think that this idea is relatively straightforward.  So,
really, the one-time signatures that you build from hash-based signatures is
relatively easy to do.  Building this merkle tree for the stateful path is
pretty easy to do.  The stateless side, again, there are some degrees of freedom
in the design space, where we could go for full SPHINCS+, which would be 8 kB,
or use some variant where you would only be allowed to produce 2<sup>20</sup>
signatures, say, then it would result in 3-kB signatures.  So, there's some
design space.  If we would just use SPHINCS+, we could essentially do that very
quickly because the specification exists.  Right now, at Blockstream, we're
experimenting with variants of this and trying to write specifications for
various variants and see, learn something about the implementation as well, and
play around with these parameters.

**Mark Erhardt**: Does anyone else want to chime in, maybe Toby or Chris?

**Toby Sharp**: Sure.  About these states that you have to track for these new
types of wallet, would that be something that can be reconstituted from the
history of the blockchain, or do you have to store it independently and it can't
be known outside of that?

**Jonas Nick**: Yes, so that is a good question.  Let's say, no, the problem
essentially is that the signing device, desktop or whatever, does not know
whether their signature makes it to the chain or not, right?  So, let's say
every signature makes it to the chain, because the reason why you produce
multiple signatures is simply address reuse, for one reason or another, right?
As a receiver, you cannot really prevent address reuse.  You give out an
address, maybe a sender sends multiple times to it, and then you need to produce
multiple signatures with the same public key in order to spend all those coins.
Okay, so you do that, and as long as you don't produce any more signatures than
that, then yes, you could try to recover your state from looking at the
blockchain.  You need to somehow ensure that you have the latest blockchain,
because otherwise you don't see your latest state, and that also seems to be
rather dangerous.  It at least would be a new security model.

But potentially, the bigger problem here is that you don't know whether every
signature you made makes it to the chain.  And in the particular case of trying
to bump the fee, it is unlikely that your first signature makes it to the chain.

**Toby Sharp**: So, another thought that I had is rather than just sort of
incrementing your state, if you used a large random number as that local state
instead, would that enable you to achieve a similar thing, in terms of hashing
it into a new form?

**Jonas Nick**: This is basically the idea behind stateless signature schemes,
where you use a really large tree and then you just select a one-time signature
scheme at one of those leaves at random, and then the probability that you
select the same one twice or multiple times is low enough that we can call it
negligible and ignore it.  But that requires a large merkle tree.  And for the
stateful scheme, our advantage that we have by using that is being able to use a
relatively small tree and optimize where the first one is really the first leaf
at layer 1, second one is at layer 2, etc, such that the merkle trees are really
small.

**Toby Sharp**: Okay, got it.  Thanks.

**Mike Schmidt**: Jonas, I think we have a call to action already that you threw
out, for wallet developers or hardware signing device devs to take a look at
this and provide their feedback to you.  Obviously, there's the discussion also
on Delving that people can chime in on if they want to take a look, regardless
of their position in the industry.  Anything else before we wrap up that item?

**Jonas Nick**: No, I think the discussion was about a little bit around how to
actually do that in Bitcoin.  Would we want to have one opcode for the stateless
path and one opcode for the stateful path, and then just use taproot to combine
them?  You would also be able to do that.  That would maybe be more modular.  Or
would we just have one single opcode that just does SHRINCSVERIFY and does
everything under the hood?  And they both have their pros and cons.  Probably
right now, not the best time to decide on this yet.

_Falcon post-quantum signature scheme proposal_

**Mike Schmidt**: We have a couple more quantum-related things, Jonas.  I know
you need to drop, but we'll jump into them.  And as long as we can pick your
brain, we will before you have to head out.  The second one from Changing
consensus was titled, "Falcon post-quantum signature scheme proposal".  And this
was based on a post by Giulio Golinelli, who posted to the mailing list talking
about enabling Falcon signature verification in Bitcoin.  If you reference back
to that podcast we had with Mike, we talked about lattice-based versus
hash-based.  Falcon is a lattice-base proposal, and I believe it's pursuing
standardization under FIPS, which is the Federal Information Processing
Standards standardization.  Jonas, how do you think about lattice-based schemes,
and are you familiar with Falcon?  Do you have two cents to add on it?

**Jonas Nick**: I mean, lattice-based signature schemes are certainly a viable
approach that we should explore, because they allow for more of the fancy
cryptography that we can't do with hash-based signatures, such as compact
multisignatures, threshold signatures, aggregate signatures, potentially
taproot, silent payments, etc.  So, I think that's why they are attractive.  And
Falcon in particular is interesting because it's very small, much smaller than
the already standardized lattice-based signature scheme.  Someone told me it's
666 bytes per signature.  I think that's actually incorrect, but it's at least
easy to remember.  Though much smaller than other lattice-based signatures, it's
kind of famous for being hard to implement, because it uses some floating point
operations and that is especially hard to do in constant time.  But I haven't
looked very deeply into this.  But it's certainly a fine approach to look into
Falcon as well for lattice-based signatures.  And there are other lattice-based
signatures as well.

**Mark Erhardt**: So, I think I briefly looked at this Delving post earlier and
I saw that the signature is, I think, 900 bytes and the pubkey is 600 bytes, or
whatever.  So, together, it's somewhere around 1500 bytes, according to the
numbers provided there, which of course would be bigger than your stateful
scheme.  And my understanding is that the implementation of lattice-based
signatures is way more complex, and it's based on additional cryptographic
assumptions that we currently don't use in Bitcoin.  But they're super-fast to
verify.

**Jonas Nick**: Yeah, exactly.  So, that is also something that makes them
attractive.  And you're right to point out, of course, public key size is just
as important as signature size.

**Mike Schmidt**: And Conduition did reply in this thread saying something
similar to what you both have mentioned, which is the difficulty around
implementing in the signing process anyways in constant time.

_SLH-DSA verification can compete with ECC_

**Mark Erhardt**: You also have the SLH-DSA thing on your radar, right?  That
sounds like a Jonas topic.

**Mike Schmidt**: Yeah, hopefully.  Yeah, "SLH-DSA verification can compete with
ECC".  This is also from Conduition.  He has one of his blogposts, which I think
are excellent.  I didn't get a chance to look at this one, but I saw the
discussion of the post on the mailing list.  He was benchmarking his
post-quantum SLH-DSA verification against secp, showing that verification can
compete with schnorr verification in common cases.  Did you get a chance to look
at that one, Jonas?

**Jonas Nick**: Much less than I should have looked at it because this is really
interesting research.  Because hash-based signatures, they have a reputation of
being rather slow to verify, not super-slow.  So, per byte of signature, it's
about the same verification time as schnorr signatures.  But since the
signatures are much larger, the overall time to verify is usually considered
slower.  So, Conduition uses this Vulkan-based implementation that makes use of
a lot of parallelism, and therefore gets the verification speed to be as fast as
verifying a single schnorr signature using libsecp in a single thread.  As far
as I understand, multi-threaded libsecp verification is still quite a bit
faster, I suppose, depending on how many cores you have.  But I think this is
already showing that SLH-DSA, if implemented correctly, can verify signatures
very, very quickly.

**Mike Schmidt**: Anything else to add from our other guests?  No?  Doesn't look
like it.  All right, Jonas, I think we made it in time for you.  We appreciate
you joining us and walking us through some of this quantum stuff that you're
much closer to than we are.  So, thank you for your time.

**Jonas Nick**: Perfect.  Thank you very much.  Bye.

**Mark Erhardt**: Cheers.

_A constant-time parallelized UTXO database_

**Mike Schmidt**: For those following along, we're jumping back up to the News
section, and we're going to jump into the, "Constant time parallelized UTXO
database".  Toby, you posted to Delving Bitcoin about Hornet UTXO(1), a custom,
highly-parallelized UTXO database.  You're touting in the post the work you've
done with constant-time queries.  And I also want to understand, and maybe you
can lead in with this, what is Hornet Node?  How does this Hornet UTXO(1) fit
into Hornet Node?  What's some of the work you've been doing on specification of
the Bitcoin protocol?  Maybe give us the way that you're thinking about these
different components, even if we're just going to zoom in on one today.

**Toby Sharp**: Sure.  And thanks for the invite, Mike, I appreciate it.  So,
Hornet Node is a completely new alternative Bitcoin client that's built from
scratch, and it's built around a pure formal specification of the consensus
rules.  And Hornet UTXO(1), as I call it, is the UTXO database that's the latest
component of Hornet Node that's required for doing validation.  So, maybe I can
talk a little bit about that database work, and then we can zoom out back to the
bigger picture if you like.

**Mike Schmidt**: Sounds good.

**Toby Sharp**: So, the headline in this in the newsletter I guess is that I was
able to validate the whole of mainnet in 15 minutes on a high-performance
machine, not including signatures, and compared to 2 hours, 47 minutes with
Bitcoin Core v30, like for like.  And that was enabled by this new low-level,
high-performance database that I've written specifically designed for the
Bitcoin workload.  So, if listeners aren't familiar with what the UTXO database
is for, when we're validating each block, we need to join the transaction inputs
together with their matching previous outputs, somewhere in the history of the
chain, in order to validate their existence and their spendability in the
current block.

So, the question is -- and there are like 180 million unspent transaction
outputs in total.  So, that's why you need a database and you need good
performance.  So, there are maybe three things that I use to be able to get this
running very fast, and the first key is concurrency.  So, rather than locking
the database for every operation, this database, the operations are concurrent
and lock free.  So, that means there's no mutex required to synchronize
serialized access to the database.  And this allows me to have a concurrent
validation engine, where I have a pool of threads and I can have many concurrent
blocks in that pipeline with pools of worker threads, and the worker threads are
each doing something different.  For example, one thread could be parsing the
inputs for block 64, another one is appending the outputs for block 63, another
one is querying inputs at block 62.  And all of these could be happening in
parallel.

**Mark Erhardt**: Well, the obvious question that you beg right now is, how
would it work if you are still adding outputs that are created by prior blocks
while you're looking for the inputs that might not be present yet?

**Toby Sharp**: Yes, I thought that was going to be the first question.  So, a
couple of different ways.  So, firstly, in terms of the queries, queries specify
an effective height parameter.  So, each query effectively sees its own block's
view onto the data.  And then that leads me to the second key here, which is
out-of-order execution with automatic dependency resolution.  So, this goes to
your question, Murch, about data dependencies.  So, traditionally, this would be
done in a sequential way.  But the key to notice is that even with missing data,
there's a lot of processing that can be done, processing inputs that depend on
pre-existing database entries.  So, if let's say block 95 arrives, but block 94
is still missing, well, there's a lot of work we can do on block 95 already.  We
can parse the inputs, we can query those that are present, most of which are
going to be much earlier in the chain, not many of which are gonna be on the
immediately prior block, and we could do partial query and partial fetch of that
data.  And then, when there's no more work to be done on that block, we can put
it into a stalled state and start work on another block.

So, the way this works is that there's an automatic dependency resolution of the
data flow, so that when the missing block arrives, then you perform the residual
query that you need to do, the residual data updates and query, and that means
that everything can be kept in the correct state.

**Mark Erhardt**: Okay, so you basically partially process the block up to the
point where you have all the data, then you put it back on the queue and
presumably fetch it back when everything before that block height has been
processed.  And that limits how many things you need to have on the backlog, and
allows you to do all of the work lazily when it's possible to do it quickly.

**Toby Sharp**: Correct.  And the machine that I was running up this on has 32
cores.  And so, like you could specify a maximum number of blocks that you could
allow in your pipeline concurrently.  But it's actually not difficult to keep
all 32 cores fully occupied, because there's a lot of scope for parallelism
here.  So, yes, because we can parallelize across blocks, across the operations
that are required within a block, across transactions, and we can keep all the
latency hidden behind that concurrency.  And so, that's really, I think,
essential for high-performance Initial Block Download (IBD) and validation.

**Mark Erhardt**: So, maybe I misunderstood.  I thought that you kept a database
of all the transaction outputs, rather than just UTXOs, and you therefore kept a
much larger database than just the 164 million UTXOs that we currently have.
Did I understand that right?

**Toby Sharp**: Okay, that's a good and a detailed question.  Let's see.  So,
there's a couple of different choices here that could be made.  The choice that
I've made so far is that all of the outputs are appended to an append-only table
that's stored on disk.  But all of the index for that table is only the unspent
outputs.  So, that means that the structure that you need to keep lean and fast,
the index, is as lean as it can be, while the structure that you want fast
access to, the table, can remain lock-free and appendable in parallel.  But if
you didn't like the idea of that extra data being in the table, then when you
reach the point of, let's say, finishing the IBD, you could recreate that table
without the unspent outputs if you wanted to.  That could be like a user
operation to compactify.

**Mark Erhardt**: Right.  So, basically, during the IBD, you would optimize for
speed and allow a higher disk usage to have the transaction outputs all in the
database.  And then, once you finish the IBD and get into a state where you need
to process data a lot less quickly, just one block every 10 minutes roughly, you
would just throw away the spent transaction outputs from that database, which
would compact it down just to the UTXO set.  So, the UTXO set goes to some 170
GB, or something, I think?

**Toby Sharp**: Oh, I'd have to check, but that sounds about right.

**Mark Erhardt**: I seem to remember that you wrote something like that!

**Toby Sharp**: Okay.  Yeah, I remember I checked this, but I don't remember
what the number was now.  I take your word for it.  So, maybe the third thing I
could mention about this, we've talked about concurrency, we've talked about
out-of-order execution.  The other thing might be just to say the low-level
structure.  So, yeah, we've started to talk about how the data is stored on disk
and I mentioned that the index is only the UTXOs.  It's an LSM-style
age-stratified index.  And I tag each entry with height.  So, that's quite nice.
It means that naturally, you end up searching the more recent data first.  And
it also means that you can rewind the database to a previous state, for example
for a reorg, without having to store separate undo data.  So, it's literally
just like, you truncate the data and now you've rewound it to the fork point,
then you can play it forward through the new fork.  So, that's quite nice as
well.  I don't use any hash maps.  Everything is done with doubly-sorted runs
and directories, which optimize the amount of memory for cache coherency.  A
copy-on-write strategy keeps everything lock free.  And for the disk access, I
use high queue depth async IO reads, which should be optimal for NVMe
performance.

So, the last thing I would just say to wrap up on that is how this fits into
Hornet Node.  And one of the key points about Hornet Node is its modularity and
its strict layering.  So, the way this has been designed is that the consensus
code doesn't depend on the database code.  There is just a pure interface, and
the pure interface says, for each input in the block, give me the corresponding
previous outputs.  And so, that's all that the consensus code knows about UTXO
databases.  It's just a very pure view.  And then, all of the database
implementation lives separately in another layer.

**Mark Erhardt**: So, maybe a less Hornet-Node-related question.  Your software
is also written in C++ like Bitcoin Core.  I assume that you might have taken a
look at Bitcoin Core, how it uses its UTXO database.  Would it be possible to
use your approach also in Bitcoin Core, or what would your thoughts be on that?

**Toby Sharp**: Yeah, I mean it's just code, so we can do anything in theory.  I
think it would be absolutely possible, but I think one of the challenges with
Bitcoin Core is that refactors are large work investments, right, and the code
tends to be quite intertwined.  And so, there isn't maybe the same separation,
strong separation of interfaces, components, and concerns that would make that
refactoring straightforward.  So, that's one of the reasons why I thought it'd
be an interesting project to kind of reimagine what the consensus code would
look like if it was written today, like on a fresh piece of paper.

**Mark Erhardt**: Talking about the consensus code being re-implemented, so my
understanding is that you're doing both a formal specification of what exactly
the consensus code is and you're re-implementing it.  I was wondering, have you
cross-compared with Bitcoin kernel to validate how close you are to fully
implementing the consensus code?

**Toby Sharp**: Yeah, and I think the Bitcoin kernel is a great project and
something that would be very positive for Bitcoin Core.  And I've had a
conversation with TheCharlatan about these different things, and I think we've
got a lot of shared values in this, so that's all good.  I think the Hornet Node
implementation is not fully complete yet, because there's one major piece still
missing.  But in terms of what's already been implemented, I think it's
accurate.  And I'll be increasing the test surface over time.  The specification
and consensus code that I've written in C++ is written in a declarative style,
so it doesn't have any side effects or mutable state.  This makes it much easier
to test and audit and answer questions about.  But there's also a
domain-specific language that I'm using for specifying the consensus rules at a
more pure mathematical level.  And that could eventually have a path to formal
verification, which would be the strongest guarantees of all.

**Mark Erhardt**: That sounds super exciting.

**Toby Sharp**: Thank you, Murch.

**Mark Erhardt**: Does anyone else have questions?  Mike, did you have more
prepared here?

**Mike Schmidt**: I mean, the one is maybe, and I know it was somewhat addressed
in the thread, but maybe what comes to mind, Toby, when talking about this sort
of architecture and IBD and performance is Libbitcoin.  Do you want to just
maybe briefly compare and contrast the approaches and performance?

**Toby Sharp**: Yeah, I would say I'm not an expert on Libbitcoin.  So, I know a
little bit about it, but not a great deal.  And I think in the Delving Bitcoin
thread, somebody asked, "Oh, have you compared with Libbitcoin, because that'd
be a great comparison?"  And I agree, it would be a great comparison.  The thing
is, I don't know it well enough to know exactly what would be the like-for-like
comparison with that library.  So, if anybody maybe who's listening has more
knowledge of Libbitcoin, we could perhaps team up and do a comparison test that
would be accurate like-for-like.  I think Libbitcoin also has a good strategy
of, from what I understand, having an append-only during IBD, which makes it
very fast for writing that transaction output to disk, similar to what Hornet
does on that side.  But I don't think it has the concurrency, which is the main
winner here.

**Mike Schmidt**: Well, maybe we can ping Eric Voskuil.  I'm sure he would love
to get in a speed race on IBD.  He loves to do those things.

**Toby Sharp**: That would be great.

**Mike Schmidt**: Ping him and see.  Toby, anything else?  A call to action for
listeners, other than checking out the Delving posts areas where you think it
would be valuable to have Bitcoin fans poke around?

**Toby Sharp**: Yeah, I guess at this point, I mean Hornet Node is 23,000 lines
of code.  It's pretty lean.  It's very modern C++.  I have not publicly
announced the code yet, and that's partly for immigration reasons, of all
things, because I live in the USA on a work visa, so I can only work for my
employer.  But I think I would like to get to a point where I can work on Hornet
full time, rather than just in my weekends.  And so, I think anyone who's
interested could take a look at the website, read the overview, read the paper I
published in September, and reach out with either encouragement or suggestions,
questions, or funding.  All of these things would be appreciated.

**Mike Schmidt**: For those who are listening and don't have the newsletter up,
it's hornetnode.org, and you can find some of the materials there, and then
obviously revisit the newsletter for the Delving post link.

**Toby Sharp**: That's great, thank you.  Thanks, Murch.

**Mike Schmidt**: Toby, thanks for joining us.  You're welcome to hang on and
hang with us or if you have other things to do, I understand, you're free to
drop.

**Toby Sharp**: Okay.  Thank you very much.  Thanks everyone.

_Bithoven: A formally verified, imperative language for Bitcoin Script_

**Mike Schmidt**: Cheers.  "Bithoven, a formally verified imperative language
for Bitcoin Script".  Chris, you posted to Delving Bitcoin about your work on, I
think I'm saying it right, Bithoven, which is sort of an alternative to
miniscript.  Maybe talk about why you created such a thing, and then we can
compare and contrast with miniscript and see what kind of good things you have
in Bithoven.

**Chris Hyunhum Cho**: Yeah, thanks for having me.  And it's right, it's
Bithoven.  And the motivation for building this smart contract is actually, I
must tell the problem that I encountered when I first learned about the Bitcoin
system and the Bitcoin Script and the miniscript.  I just personally feel that
Bitcoin secret system and the miniscript is honestly too difficult.  And I guess
anyone who don't have an expertise in Bitcoin system would feel very difficult
to write the code in Bitcoin Script or miniscript, because you need to
understand a lot of semantics of assembly-like opcodes, and you also need to
have some basic knowledge cryptography, distributed systems, those kinds of
things.  And also, I feel the motivation because while Bitcoin has a lot of
advantage over Ethereum, the developer ecosystem of Ethereum is more huge.  I
personally just feel that this is because it doesn't provide the easy,
high-level smart contract language.

So, what I feel the difficulty in miniscript or Bitcoin Script is that first, is
about the type system.  The type system is very obscure.  For example, Bitcoin
Script only accepts the byte as an operand for the operation.  For example, when
the type of bytes are interpreted upon the context, for example, if the byte
comes before OP_ADD, which is arithmetic opcode, byte becomes number; and, for
example, if OP_CHECKSIG is either public key or signature, and otherwise it's
just bytes mostly.  And also, the type of result of these operations are also
various open context.  And there are some other security concerns, for example,
you need to push minimal integer, especially in legacy script.  For example, if
you want to push the integer 1, then you should use opcode OP_1 instead of
OP_PUSHBYTES 1.  And it also has a negative zero, which in standard computer
science, integer usually uses two's complement, but in Bitcoin Script number, it
uses like sign-magnitude integer.

So, there are like a lot of things we need to check to mitigate the security
concerns.  Like for example, if you omit OP_CHECKSIG code in your output script,
it will make your money loss, because anyone can spend without proving the
ownership.  And also, the stack management are very tricky.  Like some opcodes
consume one stack item, some do two, some do three, or some do nothing.  And
some opcodes push the return onto the stack, some don't.  So, I just think that
I need to build a program language that can handle these problems with better
usability for developers.  Yeah, that was the problem that I've seen.

**Mark Erhardt**: So, you talked a lot about your motivation.  Bithoven, as I
understand it, is a programming language that uses a style that is similar to C,
that allows you to define a smart contract.  And then, you've created a compiler
that compiles it to the script.  Would you like to tell us a little more about
that?

**Chris Hyunhum Cho**: Yeah.  So, if you see the Bithoven program, if you see,
for example, the first line and the second line, it's the sentence starts with
pragma, which is similar to C.  And it's a compiler directive.  The first
statement states the compiler version that you are going to use, and the second
one is the target.  And you can pick target either legacy, segwit, or taproot.
These naming just are defined by me, and I just use these to adapt to continuous
consensus change, like how script works for legacy script, and segwit3.0 and
segwit3.1 are different.  So, I just make the developer to set the target.  And
then, there comes stack input definitions, which looks like function parameters,
like the argument name and the type.  You can define the stack item list that
you are going to use as an input stack items.  For example, if you are going to
provide the signature, you can name the stack item as sig_alice, and then you
can set the type as signature.  If you are going to provide the preimage, you
can just name the item as preimage and set the type string.

These types and the order of stack items are later used in the static analyzer
to check the type consistency and check whether there are stack items that are
in mislocation, like you need to spend the first item, top stack item, and then
second item.  But if you spend second-to-top stack item before the top stack
item, then the compiler throws the error.  And then, after that, you can finally
code your program, which compiles down to output script.  There are two
components.  One is statement and the other is expression.  In the statement is
a C-like statement.  You can use the if/else block like C, and you can use older
and after statement, which are just inspired by miniscript and have the same
semantics.  And the others are verify and return statement.  Verify statement
and return statement both receive the expression.  And expressions are the
components which are evaluated to the value, and it pushes the value onto the
stack.

So, expression includes most of the opcodes that Bitcoin supports, except the
manual stack management opcode, like OP_SWAP or OP_PICK as it's high-level
language.  For example, you can do math, add, subtract, like A plus B, A minus
B, and max, min, and, or, and compare operation, create operation, those kind of
things.  So, verify statement just push the OP_VERIFY code at the end to verify
the final expression value pushed onto the stack.  And the return statement is
just the final statement of program to push the final item onto the stack, which
is required for script to parse in Bitcoin.  And if you look at my compiler
code, there are four components.  One is parser.  Parser is defined using R1
parser.  It's kind of, if you define former grammar and the regular expression
for the syntax, then the automated parser is generated.  And with the design of
abstract syntax tree, it's kind of like intermediate language.  We can generate
this AST output to process further, and then it goes to static analyzer.  In
this stage, it checks the type, like wrong use of stale item, and checks some
non-security bugs, like for example, if it doesn't require any signature, it
throws the error.  And for example, if the public key, the program state is
string return, but we check that is this public key actually on elliptic curve
or not?  Those kind of checks are done in this stage.

Then finally, we just compile to Bitcoin opcodes and handle all the tricky jobs
like stack management.  We use like OP_SWAP and the Ark stack.  And then, the
final step is the optimization.  For example, If OP_VERIFY is next to OP_EQUAL,
just replace two outputs with OP_EQUALVERIFY.  So, I guess the biggest advantage
of my Bithoven language is very developer-friendly and very easy to write.  But
I try my best guarantee to secure the code.  Yeah, that's Bithoven.

**Mark Erhardt**: All right, that sounds pretty exciting.  I know that
locktimes, for example, are a challenge and I'm actually not 100% sure how much
of it is now supported by miniscript.  How does Bithoven deal with these sort of
constraints?  Does it support it?

**Chris Hyunhum Cho**: Yeah, actually the locktime part is pretty similar to
miniscript.  Miniscript supports both absolute locktime and relative locktime
with order and after syntax, and they are just quite similar.  What miniscript
doesn't provide is actually a lot of expressions, like A plus B or A is greater
than B, or those kind of nested expressions; and in Bithoven, it supports it.

**Mark Erhardt**: Okay, cool.  Antoine joined us meanwhile, and he has worked a
bunch on miniscript.  So, I was wondering whether Antoine might have any
comments or questions.

**Mike Schmidt**: Yeah, I want to frame it up a little spicier.  Antoine
authored a field report for Optech titled, "Field Report: A Miniscript Journey".
And towards the end, he notes, "The future is bright.  Contracting on Bitcoin
with safe primitives is more accessible than ever".  But now we have Chris here
saying that maybe we need to improve our tooling and maybe it's not as bright as
we thought it was those two years ago.  So, that's my spicy frame-up for you,
Antoine.

**Antoine Poinsot**: Yeah, hi everyone.  I'm not sure I see the added value of a
new language other than the one that is already supported and widely vouched and
reviewed.  I don't think that support for additions in expressions is a
sufficient reason, but I personally think that it's one of your first projects
in the Bitcoin space, and I think that working and playing with all the weird
script edge cases is a very good introduction to the Bitcoin space, which was
also my introduction.  So, I hope to see more from you.

**Mike Schmidt**: Go ahead, Chris.

**Chris Hyunhum Cho**: I just think miniscript is safer obviously, and it
prioritizes the safety first.  And my first target is not to make the user to
lose the money.  But Bithoven's main purpose is more like while sacrificing,
maybe not that restricted, but it just emphasizes on the expressiveness of the
language.  So, yeah, and just manuscript, while it's a very good language, for
example, for general software engineers who don't have expertise in Bitcoin,
just find it just a bit difficult to write about.  So, before they, for example,
learn about the miniscript to write the perfect and safe Bitcoin smart contract,
they can just learn Bithoven first and to understand continuously.  Yeah.

**Antoine Poinsot**: Yeah, so I understand and that also helps to clarify maybe
my criticism, which is not on your implementation because I did not look too
much into it so I cannot give a criticism of it.  I think it's more on the goal.
I think Bitcoin Script is about expressing conditions under which funds are
about to be released.  So, I don't think it should be a goal to have expressions
in this comparing to regular programming languages.  It is not a goal to have
regular primitives.  I think a goal of the language should be, what useful
primitives do we have for expressing who can unlock the money?  And I think that
miniscript covers all those useful primitives.  If we were to add more, such as
some covenant-type things, we might want to extend the miniscript language.  But
yeah, I think it's more of a 'where do we want to go' disagreement.

**Mark Erhardt**: I want to chime in briefly.  So, there's other people that
seem to disagree with this approach.  There's someone working on a BIP that
wants to extend the arithmetic operators to larger numbers in Bitcoin.  There's
the great script restoration, which also seems to be more in the direction of
Chris's programming language.  And if, Chris, you say that your intent is to
mostly make experimentation easier and provide a different UX to programmers
that maybe is a bit of a difference to miniscript, where miniscript is
compatible with output script descriptors and much more tuned towards
expressing, well, maybe creating wallet patterns, so that's my breaking a lance
for this new project.  Chris, did you have another reply to Antoine?

**Chris Hyunhum Cho**: Well, I guess while manuscript is perfect for the
existing usage, but we have seen a lot of innovation so far in Bitcoin, like as
you mentioned, the covenants.  So, just my personal thought is that it's just
better to make it more expressive.  If Bitcoin has the expressive feature in its
Bitcoin Script that can be abstracted away by using the parser or compiler, then
there might be in the world some software engineers who have the creativity to
use this expressiveness to make something wonderful.  Then, yeah, in that
purpose.  And also, Bithoven is providing static analyzers.  So, it tries to
prevent money loss bugs, as miniscript does, so where I should refine more and
more to be competent enough to compete with miniscript.  But, yeah, that's my
thoughts on my Bithoven and miniscript.

**Mike Schmidt**: A couple things came to my mind, and maybe the guests or Murch
can comment on this, but maybe introducing the idea or the policy language,
which I think was supposed to be a high-level way to represent some of this, but
also the Minsk high-level language, which I think can go from Minsk to policy to
miniscript to script.  How would we think about those in comparisons to
Bithoven?

**Chris Hyunhum Cho**: Well, I don't know much about Minsk.  I once used the
Minsk IDE but I don't know how much they extend from the miniscript, so could
anyone explain?

**Pieter Wuille**: So, I think that if your goal is to represent conditions
under which a UTXO may be unlocked, you can't do much more approachable than the
manuscript policy language, because it's literally saying either this key or
this key after 42 blocks.  Minsk is a way of representing the miniscript policy
language in language that is more approachable to an existing mainstream
language programmer, which is instead of having functions of, or this path, or
this path, you have variables, but it's still an alternative to the manuscript
policy language, which is still targeting expressing the conditions under which
the money is released.  I don't think it aims to integrate arbitrary computation
like Chris's project.

**Chris Hyunhum Cho**: I just remembered how the syntax was in Minsk.  And yes,
I guess Minsk is just inheriting the features of miniscript with more
user-friendly syntax.  So, it basically doesn't support various expressions like
addition or comparison.  And also, for example, in mainstream language, as
Antoine mentioned, like OR, and then you just define the conditional path, first
path and second path, as the parameter of OR.  But, you know, in program
language, we usually use an if/else block.  So, if you see Bithoven, it supports
just the if/else block, but it just compiles down to what OR compiles down to in
miniscript.  So, as the overhead is not generated, so with zero overhead, it
supports more friendly syntax than miniscript, I guess.

**Mike Schmidt**: I think we did a pretty good dive on that, had a little bit of
debate.  Chris, I want to thank you for joining us.  It sounds like the call to
action here, and correct me if I'm wrong, would be for people to play with this
and check out the work that you've posted; well, I guess the paper that you've
posted in addition to the Delving post.  Anything else that you'd want listeners
to look into?

**Mark Erhardt**: So, in Bitcoin, we have the Bitcoin Improvement Proposal
process, where people present these sort of ideas.  And I was wondering whether
that is perhaps something that you are considering.

**Chris Hyunhum Cho**: Well, honestly, because the reason I just built this
Bithoven to adapt to continuous consensus change is because it's so hard for me
to change the consensus or change the impact on the Bitcoin Core itself.  So, if
Bithoven gets a lot of popularity, then I will consider.  But I will rather
follow up what you guys do on the Bitcoin Core so that Bithoven is helpful
enough.  And my call for action is, I'm just researching in programming language
and blockchain.  I'm just a PhD student.  The reason I just published this open
source is I just want to get feedback to improve the usability or performance,
or catch the bug that I haven't found and increase the accuracy.  So, if you
just search Bithoven in GitHub or Google, you will find my repository.  And I
also provide the web IDE.  So, just feel free to code with Bithoven and feel
free to leave any feedback in GitHub or Delving Bitcoin.  Thank you.

**Mark Erhardt**: Bithoven is of course also linked in the Newsletter #391 that
we're discussing.

**Mike Schmidt**: Chris thanks for your time thanks for joining us.  You're
welcome to hang on or you're free to drop.

**Chris Hyunhum Cho**: Thank you, everyone.

_Addressing remaining points on BIP54_

**Mike Schmidt**: We're going to jump back into the Changing consensus segment
to talk with Antoine about the item titled, "Addressing remaining points on
BIP54".  Antoine, maybe you want to make sure that the listeners know what BIP54
is, and then what are the remaining points of discussion?

**Antoine Poinsot**: Yes, BIP54 is a Bitcoin soft fork proposal named,
"Consensus cleanup", and which aims to fixing a number of vulnerabilities in the
Bitcoin consensus protocol.  Should I give the updates from the email?

**Mike Schmidt**: Yeah, so what's the latest?  Maybe where's the project, and
then what are these remaining points of the discussion from the mailing list?

**Antoine Poinsot**: Oh right, so the latest is that it just got merged into
Inquisition.  But the remaining point of discussions were actually from the end
of December or beginning of January, so I will jump back to those and come back
to Inquisition after.  Well, I keep being told that the proposal is
uncontroversial.  Of course, it's not a very nice thing to say when you are
championing the proposal, but it seems that there's not a lot of pushback
against the proposal.  There are two exceptions to this, which are, first of
all, Luke Dashjr, on the one item of the proposal, mandates that miners would
set the nLockTime in the coinbase transactions to a specific value, the specific
value being the block height in which the transaction is included, minus 1.  And
currently, this field is just set to a dummy value, it's just set to 000.  So,
it's not something that miners are giving up some space in their block, or
whatnot.  Yeah, Murch?

**Mark Erhardt**: To be clear, there's opposition to using the field, right?
So, he opposes that rather than mandates it?

**Antoine Poinsot**: Yes, I was going to explain it.  So, this item in the
proposal mandates that this field is being used for this purpose.  And Luke
Dashjr explained, well, explain is a big word because he doesn't want to explain
it, mentions that the nLockTime is the perfect place for an extraNonce.  So, in
order to decipher what Luke said, it's important to remember that the nLockTime
is the last field serialized in a Bitcoin transaction.  So, you would expect
that it would be some sort of headers of the transaction, like the version of
the transaction, the locktime of the transaction, the inputs and then the
outputs.  It's not.  For some reason, it's first the version, then the inputs,
then the outputs, and then the nLockTime at the very end of the transaction.
Because it's at the very end of the coinbase transaction, it can be used by
miners to reuse a midstate of the coinbase transaction, because it's not on the
first word used by the SHA256 algorithm.

**Mark Erhardt**: Yeah, so the hashing consumes 32-byte chunks and adds them to
the previous outputs to make it 64 bytes of input.  So, even the header will be
multiple chunks with its 80.  And the nLockTime being the last field that is
consumed from the header means that it is the last thing in the last round that
is being hashed.  So, if you only had to change that and kept all of the rest of
the block the same, you would be able to use the hash product of the previous
hash step and just update this tiny, little bit.  That's roughly how I
understand it.

**Antoine Poinsot**: Yes, so say you have a massive coinbase transaction, it can
actually save some hash cycles if you do that.  If you're paying out all your
hashers in the coinbase outputs directly on the transaction, then you don't have
to rehash, let's say, 8 kB or 20 kB of transactions.  You just rehash the last
32 bytes and then you compress.  So, that's indeed savings, but it's also a
question of what are we trying to save here.  Sometimes it doesn't make sense to
just benchmark some things in isolation and just try to improve the thing in
isolation, because maybe the thing is not the bottleneck when you actually take
a step back and consider how things work in real life.  So, for instance, what
example could I give?  Maybe the serialization of Bitcoin transactions is not
the bottleneck in Bitcoin Core for IBD, and maybe it's looking up the UTXOs in
the database, or it's verifying signatures that is going to be the bottleneck.
So, you might optimize all your serialization all you want, you're never going
to improve IBD time.  So, it is we should not be looking at optimization with
zooming in on some micro-optimization and look in the big pictures how they fit.
Yes, Murch?

**Mark Erhardt**: Sorry.  So, very specifically in this case, any byte changed
in the header will lead to a new result for the header's hash, which then of
course would be checked against whether it is sufficiently low to parse the
difficulty and be a valid block, right?  So, if the nLockTime gets to have a
mandated value, this hack that is very similar to ASICBoost, where you can keep
the midstate of hashing and only change nLockTime, would become unavailable to
everyone.  And if it remains open, I don't know why nobody ever has been using
it before because it is right there and it would have been available for
everyone, then it would be open to anyone and anyone could use it and it would
still be sort of an equal playing field.  So, whether or not it gets mandated
doesn't really actually affect whether or not mining is an equal playing field.
It becomes either more difficult for everyone, or now that this has been
discussed, everybody should be using it and it would become easier for everyone.

So, overall, it just feels like a no-op to reserve this for an extraNonce,
because either it's easier for everyone or it's harder for everyone.  You could
still use the version field to do some version rolling, you can still use the
timestamp to do some rolling.  Yeah, sorry for jumping in.

**Antoine Poinsot**: Yeah, I think it's a very important point to say that
either way, mining keeps being an equal playing field.  But I think also, we
need to make it clear that it's not an extraNonce for mining, it's not really an
optimization for the ASICs.  So, in the same way that it's using internal
structure in what eventually becomes the merkle root, like covered ASICBoost,
but covert ASICBoost enabled to paralyze the operations in the chips.  So, it
was an optimization for mining, and that's why I was making my point on the
bottleneck.  This is an optimization for the mining controllers that are sending
jobs to the ASICs, which is currently not a bottleneck at all.  Which is if your
stupid boards on top of your ASIC is not able to hash fast enough, just buy a
Raspberry Pi and that's done, that's the end.  So, this is not an extraNonce for
billion-dollar operations.  It's an extraNonce for the mining controllers.  I
don't know how to state that in more accessible terms but it's essentially not a
bottleneck today and it's very hard to think about scenarios where it would
become a bottleneck.

So, that's what I was asking Luke to clarify when he initially made the
comments.  I think the very first time he made the comment was in a private
message to me on the BIPs repository in the PR.  So, on the BIPs repository, I
really tried to challenge him to explain it.  Then, I mentioned it on the
Delving Bitcoin forum, where he does not want to interact.  Fair enough.  So, I
sent it to the Bitcoin-Mining mailing list, a call to miners to update the
nLockTime.  He came back about the same point, giving no details and trying to,
I think in my opinion, cast some doubt with reusing the extraNonce word to try
to imply that somehow it's a mining optimization, whereas it's not.  So, I was
trying to explain.

**Mark Erhardt**: Wait a minute, I don't follow that argument though.  So, what
miners do is they go through a bunch of block headers in order to see whether a
block header would surpass the difficulty.  And the block header has a bunch of
different fields, most of which actually are open to being sources of entropy.
So, there's some version rolling.  The merkle root cannot be changed, that's 32
bytes that are locked.  And I'm confused.  The previous blockhash cannot be
changed.  The merkle root can be changed, the version can be changed, and the
locktime can be changed.  The embits are locked, obviously, and the nonce is
also entropy.  So, I don't see how it's not usable at the ASIC level, because
you could just count up the nLockTimes and get a new header every time.

**Antoine Poinsot**: It's usable on the controller of the ASIC, where you're
going to send a header inside the ASIC and the controller is going to change the
extraNonce and is going to send multiple jobs inside the ASIC machine and the
ASIC is going to roll the nNonce, it's going to roll the timestamp and it's
going to roll maybe sometimes the timestamp and the version.

**Mark Erhardt**: Okay, I'm glad I asked.  I thought you meant the controller of
the ASICs, like the job allocator rather than the controller in the ASIC.  So,
now I follow your argument.

**Antoine Poinsot**: Yeah, okay, maybe just to explain that to the audience as
well.  So, the way you have the mining farm is that you have the job controller
and then you have multiple ASICs.  And on top of each ASIC, you have a board
that is controlling this specific ASIC, because inside the ASIC, it's just
circuits that are specialized to be hashing headers and rolling the fields in
the headers.  And the controller, I think at this point, is going to only get a
merkle root, but you would have to check that with someone who knows mining
more.  But they just get a merkle root and change the coinbase transaction,
which changes the merkle root in the header, and send a new header inside the
ASIC, who then in turn rolls the nNonce, the nVersion and sometimes the
timestamp.

**Mark Erhardt**: So, basically, to make it maybe a little simpler, the
bottleneck in the ASIC is the hashing, not the producing new headers.  And this
being able to roll the nLockTime just allows you to create headers more quickly,
but that does not seem to be the bottleneck of the ASIC machine itself.  So, in
your opinion, reserving the nLockTime to be able to use it as another source of
entropy solves a problem that is none right now, because we can already produce
enough headers to keep an ASIC busy.

**Antoine Poinsot**: Exactly, thank you.  You have a gift to explain things
cleanly.  That's exactly what I meant.  And it's also looking forward in the
future, because it might be a non-issue today but might become in the future,
and we don't want to prevent ourselves from extending usage of Bitcoin because
we could just use a different fix for BIP54 than this one.  And so, that's what
Luke was pointing.  It could be useful.  Obviously, it's not being used today
because controllers just prefer to be rolling the scriptSig of a coinbase
transaction, which is bytes at the very beginning of the serialization of the
transaction, because it's in the inputs.  And so, they rehash the whole coinbase
before sending the jobs inside the ASIC.  Obviously, there is a revealed
preference for miners that they don't care about rolling the nLockTime, but it's
also very hard to think through a situation where they would care about rolling
the nLockTime, and that's what I've been trying to get Luke to explain, but he's
never explained because I don't think there is any such realistic scenario.

**Mark Erhardt**: All right, so basically, we neither have a bottleneck right
now for producing the headers that need to be hashed, nor do we anticipate that
that will ever be the case, because rolling the extraNonce in the coinbase is
something that ASICs have to do only every four billion hashes anyway, because
the nonce field will allow you to generate 4 billion headers already.  And then,
there's version rolling and timestamp rolling on top of that.  So, in each ASIC,
you can already create billions of headers without even rolling the coinbase, so
we anticipate that that will not be a problem in the future either.  How about
we get to the other point, there was something about the 64-byte stripped
transactions that there was more on.

**Antoine Poinsot**: Sure, we can move on to this topic.  I just want to finish
with maybe some more positive notes, because it might sound like, "This is
controversial, why don't you just use a separate field and be done with it".
The reason is that there are very good reasons for using the nLockTime to store
the block height.  First of all, well, Luke's the first one to be saying that we
should use Bitcoin as it's designed for, and locktime is used to store block
height, so it's a very natural place to store it.  Furthermore, the same
midstate optimization can be used, once we have the block height in the
coinbase, to have proofs of a height of a block directly compressed with a
midstate.  So, the same argument works for the mining optimization and for the
use case.  And because we have timelock enabled on Coinbase transactions, this
enables a simplification in software, where past a BIP54 activation, when we
know that miners must set the locktime in the coinbase properly, because
timelock is being validated for coinbase, we know that there has never been a
coinbase in the past with the same locktime.  Therefore, it must mean that this
coinbase is unique.  Therefore, if we ever bury the BIP54 activation, we don't
need to make BIP30 validation conditionals on the chain.

So, it's like there is upsides to be using this field for this purpose.  It's
not only not giving up against Luke's argument.  So, I think that he's not
convinced me to change, to not get all these upsides for something that is
highly theoretical.  And that's what I explained in the email.

**Mark Erhardt**: I'm sorry, I also have to follow up.  I realize that I
confused myself.  So, we're talking about two different levels of where entropy
for the hashing comes from, and I didn't properly distinguish that earlier.  So,
in the block header, we have the version, the previous block header, the merkle
root, the timestamp, the embits and the nonce, but the locktime is in the
coinbase transaction.  So, in order to get the entropy out of the locktime to be
relevant for the header at all, it would be a change to the merkle root and not
in the header, as I implied earlier, which is incorrect, right?  So, the point
is, if we're changing the coinbase transaction currently, we would be changing
the extraNonce.  And before we ever change the coinbase transaction, there are
several fields in the block header that we would be changing.  We can version
roll, we can change the timestamp, and there is the actual nonce in the block
header, which allows us up to 4 billion values.

So, I think I didn't properly explain that earlier.  I was mixing the locktime
from the coinbase transaction into the header data, which is not where it is.
This is about data that is in the coinbase.

**Antoine Poinsot**: Yes, and that's the reason why it only matters for the
controllers.  So, that's the reasons to use these fields.  There was arguments
against.  I was not convinced by the arguments, and the reason I'm not are
available on the mailing list post in detail.  There were also others that
reacted to my post saying that worst case, if miners really want to have an
extraNonce in for their controllers, they can always add another return output
at the end of their coinbase transactions.  So, there seems to be, besides Luke
chiming in with this counter argument, there seems to be a wide argument among
others that it's a fine place to put the block height.

**Mark Erhardt**: Please continue.

**Antoine Poinsot**: Okay, so the other pushback was on the other item from the
BIP54 proposal, which relates to 64-byte transactions without witness data.
Annoyingly, I've seen this argument, so it's an argument from Jeremy Rubin.
It's a different argument from the previous pushback I had from Eric Voskuil on
Delving for invalidating 64-byte transactions.  This one is more of an argument
for, what if we need 64-byte transactions in the future?  And then, suggesting
that instead of invalidating the 64-byte transactions themselves, we change the
merkle tree algorithm in order to be compatible with any size of transactions.
So, these arguments were laid down in a podcast by Jeremy Rubin.  I think it was
on the Blockspace podcast.  And there are two, I think, as far as I remember,
two parts to the argument.  The first part is, what if with covenants, we have
some structures where inside a covenant, we need to use a 64-byte transaction in
the future?  And of course, it cannot make sense if you don't change the current
Bitcoin protocol, because whether you are inside a covenant or not, as long as
you are going to transmit funds, you need an output that is at least 20 bytes,
well, 28 with the value.  So, the transaction is always going to be more than 64
bytes in any case, whether you're inside some weird covenant logic.

I tried to substantiate the theoretical case in which it could matter.  Jeremy
said that maybe we might want some separate structure to transactions in the
future, in the same way as we had for segwit with the witness, but for the
outputs.  If we do this, then the output of a transaction as hashed today could
be nil and empty essentially, because the locking information would be in an
extension of the transaction format.  So, in my opinion that's pretty
far-fetched.  At this point, you might as well just make a hard fork, because
the existing users on the chain would just have no information how all the coins
are even being spent.  So, yeah I just think that it's far-fetched and in any
ways that is remotely comparable to how Bitcoin works today, 64-byte
transactions cannot be secure and cannot be attached any value.  So, I don't
find this argument convincing at all.

So, the alternative suggestions that Jeremy was giving during his podcast was
instead of making the 64-byte transactions invalid, you could build a separate
merkle tree, let's say in a coinbase transaction output, in the same way that
you have today the witness merkle tree in a coinbase OP_RETURN.  You could have
the future merkle tree in coinbase OP_RETURN, and the only transaction that you
have in your block in the ancient merkle tree is the coinbase transaction.  Same
reason, it's like I don't know if people remember the evil soft fork discussions
back I think it was a decade ago.  It's like at this point, you're creating a
soft fork where everybody is forced to migrate to this new block data structure.
Otherwise, you do not see any content of the blocks, you are not able to
validate the 21-million limit, you are not able to validate any basic consensus
rules, and you are not able to make any transaction whatsoever anymore, or
seeing their confirmations.  So, essentially it's a forced upgrade.

So, I don't think it's very fair to call that a soft fork, because there is
usually a connotation that a soft fork is soft.  Because what his proposal would
be is essentially break all existing users of the Bitcoin protocol, force them
to upgrade to a new version of the consensus rules, just to avoid making these
insecure 64-byte transactions invalid.  So, in my opinion, the trade-off, it's
not worth it.  In my opinion, if you weigh -- because it's also, there is always
the third way of we just keep the 64-byte transactions in secure transactions in
consensus valid, as they are today.  There's always this option.  In my opinion,
just making them invalid is superior to this.  And it's also superior to just
breaking all existing usage of the Bitcoin protocol to move everybody to a new
merkle tree.

**Mike Schmidt**: So, in both situations, it seems like he's thinking very
greenfield kind of soft forks.  One is a whole new merkle tree that everyone
would have to move to.  And then the other one, it's sort of, if there were a
new segwit-like data structure, that were added, then you could have reasonable
transactions that would be potentially the 64 bytes.  And then, because we've
outlawed those, you'd have to have additional logic in there to make sure it's
either 63 or 65, or some such thing.  Or, I guess it would be a hard fork to
make the 64 valid again, right?  So, yeah, I think I saw some of his talk on
that.  I wish we had him on to defend his position, but what are other people
saying about 64-byte transactions in Jeremy's argument?

**Antoine Poinsot**: I have not heard any public comments about his alternative
merkle tree idea.  Essentially, it's an extension block.  There have been
comments in the past about doing extension blocks, so maybe people can look into
those.  And there has been opposition, not really, like pushbacks on the
desirability of invalidating 64-byte transactions being worth it, but that's all
I've seen.  I don't think there has been comments.  There has been comments on
the mailing thread, with regard to Luke's objections for nLockTime, but I have
not read any on the part that was on Jeremy's alternative merkle tree ideas.

**Mike Schmidt**: Maybe we can talk briefly about Inquisition, which you
mentioned, which I think happened after this newsletter was published.  There's
a few different things that are activated on Inquisition, which is basically a
test network, signet.  Now, when there's something like CTV
(CHECKTEMPLATEVERIFY) activated, people can jump on and play around with a new
cool new feature.  What does that look like for BIP54?  Obviously there's not a
feature for them to play around with, but are there ways to test some of these
vulnerabilities are fixed; like, what can people do?  Are there some scripts
they can run or things they can do to verify it works?

**Antoine Poinsot**: Sure.  So, as you say, Inquisition is more interesting as a
testbed for consensus changes when the consensus changes offer more capability
of valid things, whereas this soft fork is essentially really making existing
things invalid, like any soft forks, but does not offer new features.  And
therefore, yeah, it makes less sense to be testing on a public test network.  I
guess there is always, with Inquisition, the ability to make private signet
networks and create maybe semi-private bad blocks and tests that they are indeed
rejected by the network.  But yeah, that's pretty limited.  I think that the
reason I wanted to get it on Inquisition was more to have my implementation meet
a certain bar, a certain threshold that is lower than the threshold to get stuff
merged into Bitcoin Core; and to get some early feedback from Bitcoin Core
contributors, because that would be the set of people that are having a look
into Inquisition.  I didn't have feedback from all contributors that would
happen if I make a request to Bitcoin Core, but that was a good smaller
threshold for me to reach, with review from people, I don't know, who just have
more experience with C++ than I do, or maybe have feedback on the way I
organized the test vectors, which was one big thing that was improved during the
review process for Inquisition.

**Mike Schmidt**: Excellent.  Anything else that you'd point people to on BIP54
as it sort of progresses along?  What should people know?  What should they be
looking out for?

**Antoine Poinsot**: Well, I think I want to let things bake for a little bit.
I've collected the feedback I got on Inquisition during the review of
Inquisition to improve the BIP.  So, I will be improving the BIP.  Maybe I can
help participate in some private testing with some custom signet private network
if people are into this.  Well, one thing, one big blocker is to get miners to
be forward-compatible with the proposal, because currently they all set the
nLockTime to various values, mostly to 0 to a dummy value, and we need them to
be setting it to the block height minus 1, not in order to activate the soft
fork, but in order for them to be producing valid blocks whether the soft fork
is activated or not.  Because currently, they only produce valid blocks if the
soft fork is not activated.  So, in order to make it safe to activate the soft
fork, we need them to have forward-compatible blocks.

So, that is my main non-technical task at the moment, reaching out to miners and
explaining and trying to explain that I'm not asking them to vouch for the south
fork, just to be compatible whether or not it happens.  And yeah, for
information, I know that Optech is going to have a new summary for the consensus
cleanup topic.  Also, there is a bunch of links there.  And I think somebody is
working on a website for the BIP, so that might be something to look out for.

**Mike Schmidt**: All right, we'll look forward to that.  Yeah, and Murch, thank
you for that open PR to the Optech topic.  We'll be refreshing that hopefully in
the next couple of days here.  So, Antoine, thanks for joining us, thanks for
participating in a few of these discussions.  Murch, do you have anything else
for Antoine?  I know you bowed out there for a second.

**Mark Erhardt**: Yeah, sorry, I might have missed it.  But I think the buy-in
from miners or the awareness of miners would also be drastically improved as the
project moves forward in parallel in other venues.  So, I think it coming out on
Inquisition will help, and hopefully it also coming out on Bitcoin Core
eventually might help, so let's just keep the ball moving.

**Antoine Poinsot**: Yeah.  Okay, thanks for having me.

_Discussion of dust attack mitigations_

**Mike Schmidt**: Thanks for joining us, Antoine, cheers.  And our final jumping
around here, we're going back up to the News section to discuss the last news
item titled, "Discussion of dust attack mitigations".  This was a Delving post
by Bubb1es, who wasn't able to join us on the show.

**Mark Erhardt**: So, basically, we describe as a dusting attack when someone
reuses addresses that existed or had been used before, in order to reduce the
privacy of the users by just sending minuscule amounts of satoshis to, well,
previously used addresses.  And there are various ways how people try to
mitigate this loss of privacy.  So, the attackers' agenda here is that the
victim might combine these UTXOs with other UTXOs in their wallet, and thereby
reveal more information about the existing previously-used address in the
context of the wallet of the victim.  So, by using the tiny amounts together
with new UTXOs, it would tie them together in the shared input heuristic, where
the base assumption is that all of the inputs in a transaction belong to the
same wallet.

So, the way I understand the proposal of Bubb1es is now that the minimum fee
rate has been dropped by a factor of 10, and it only costs a few satoshis to
spend UTXOs, so for example, P2TR keypath inputs can be had for a mere 6 sats
and P2WPKH costs only 7 sats, and even a P2PKH output, legacy output, would only
be 15 sats now, so it becomes drastically cheaper to scrounge up these dust
UTXOs.  And the underlying worry Bubb1es has is that even when previously your
wallet might ignore these UTXOs because they were so small, it would pick them
up now because the minimum amount for inputs to make them viable to pay for
themselves is so much lower.

So, the idea is instead of leaving them floating in your wallet, you actively
burn them by spending them to a zero amount OP_RETURN output.  And there was
then just a discussion about the viability of this approach.  The idea is to
spend every single UTXO separately in order to make it not leak any more
information about the wallet.  But some other disputants in the conversation
proposed that you could use a, I think it was ANYONECANPAY?  Yeah,
ANYONECANPAY|ALL sighash and that would allow other people to add their dust
inputs and reuse the same output.  So, ANYONECANPAY|ALL means your input commits
to all of the outputs, which is that single zero amount OP_RETURN output, for
which the proposed content would be ash, as in ashes to ashes.  And with the
ANYONECANPAY other inputs, you do not commit to other inputs.  So, therefore,
other people can expand your transaction by adding more inputs to it that also
all get burned to the same OP_RETURN output.  And because the amount is zero,
all of the amount of the inputs gets turned into transaction fees.  So, the more
people add their inputs to the transaction, the more space-efficient it becomes
to burn these transactions and it all gets turned into fees, which hopefully
makes a miner pick up the burned transaction.

Now, of course, these inputs get combined, but they actually subvert the common
input heuristic by incorrectly making the surveillant think that these inputs
belong together, but actually they come from different wallets.  So, it models
wallet clusters.  There was a previous work ten years ago by Peter Todd, who
proposed dust-b-gone as a very similar approach.  He was using the none, instead
of ANYONECANPAY|NONE.  And the way I understood it, that would have additionally
allowed anyone to use that input for its value to their own transactions.
Basically, you just make the input available to pack into any transaction at
all.  So, other people could use your UTXO after seeing the transaction, and
rebind it to their transaction and grab the funds for themselves, also
incorrectly associating the dust UTXO with their wallet instead of the victim's
wallet.  So, this is basically the idea.

The hope would be, if these transactions float around the network, when other
people want to do this, they might keep track of those transactions and add
their own UTXOs to it, which would make it more efficient and support
surveillance.

**Mike Schmidt**: So, the two tools here, the recently proposed one that we're
talking about in this Delving post is ddust, and then the one that Murch
referenced, that was Peter Todd's tool from ten years ago, was called
dust-be-gone.  So, if you're curious how people are proposing you can handle
this or have handled this in decades past, check out those tools in addition to
the Delving thread.  Anything else on that one, Murch?  All right.  I'm glad we
were able to get through those two segments in two hours.  And we can move to
the Releases and release candidates segment, as well as Notable code and
documentation changes, both authored by our very own Gustavo, who's here to walk
us through them.

_LDK 0.1.9 and 0.2.1_

**Gustavo Flores Echaiz**: Thank you, Mike, thank you, Murch, and this was a
very interesting conversation.  But I'm glad we get to this part.  So, this
week, we have two releases of LDK, 0.19 and 0.21.  These are both maintenance
releases which fix a critical issue related to the ElectrumSyncClient structure.
So, basically, what was happening here is that unconfirmed transactions were
treated as confirmed transactions when syncing a wallet.  So, for example, if
you had an unconfirmed transaction such as a channel opening transaction, the
ElectrumSyncClient would try to obtain the merkle proof for that transaction.
However, since it was unconfirmed, that wouldn't work and it would kind of get
stuck until the transaction would confirm, and then it would be able to obtain
the merkle proof; or the transaction would drop out of the mempool if it was
replaced, or something like that happened.  So, the fix here makes it that the
unconfirmed transactions are treated as such so that LDK doesn't try to fetch
for its merkle proof.  And this fix applies to both versions.

However, the second version, 0.2.1, this has some additional fixes that apply to
things that were added after v0.2, which are specifically the AttributionData
structure related to the attributable failures proposal.  This is now public as
a structure, which allows it to construct messages elsewhere in the software
before the permissions that allow to build.  Previously, it was preventing the
construction of some messages.  And also, splicing.  When a peer doesn't support
splicing, it will now properly fail immediately when trying to splice a channel
with a peer, instead of not failing immediately.  So, those are the two releases
of the week, maintenance releases related to LDK.  They're not all as official
releases in the LDK repository, you have to click on the tags section to find
them.  But yeah, there they are.  Any extra thoughts here, questions?  Perfect.

_Bitcoin Core #33604_

We move forward with the Notable code and documentation changes.  This week we
have two Bitcoin Core PRs, as well as many related to the Lightning
implementations, and finally one for Rust Bitcoin.  So, first of all, on Bitcoin
Core, we have a correction of a behavior related to the assumeUTXO
implementation.  So, basically, when a node that uses assumeUTXO, it will first
get a snapshot block, it will sync towards the latest chain tip, and it will
download blocks previous to that snapshot block in the background.  When the
node is downloading those blocks in the background, it will skip peers that
don't have that snapshot block, because it wants to make sure that it's only
downloading blocks from peers that have that same snapshot block, because it's
unable to handle a potential reorg.  However, once the node has fully synced and
is no longer doing background validation, this restriction about peers would
still apply unnecessarily.

So, what this PR does is that it removes that restriction after background
validation has been done, so that Bitcoin Core isn't necessarily filtering peers
out, or at least is not applying that specific restriction for peers that don't
have that snapshot block.  Obviously, most peers will still have that snapshot
block, because most peers are still synced to the same best chain.  But this was
just an unnecessary restriction that was kept, even after background validation
was done.

_Bitcoin Core #34358_

We move forward with #34538.  In this second PR related to Bitcoin Core, a bug
occurred when trying to remove transactions via the removeprunedfunds.  So, this
is actually an underlying issue with a util related to removing transactions.
So, it's not at the API endpoint level of removeprunedfunds, but it's the
underlying util that had the issue.  So, when you were removing a specific
transaction using the removeprunedfunds RPC, it would mark all of its inputs
spendable again.  But what if you also had another competing transaction that
was spending those same inputs. The bug was that it would make those UTXOs,
those inputs, spendable again, even if you had another transaction that was
spending them.  So, then, your wallet could construct a conflicting transaction
with those UTXOs.  So, now the bug ensures that the inputs are marked as
spendable again, only if another transaction doesn't also spend.  Any extra
thoughts, comments here?  Perfect.

_Core Lightning #8824_

We move forward with Core Lightning #8824.  This is a fairly simple one, where
basically a new layer is added to the askrene plugin, which is called
auto.include_fees.  And this means that when you use askrene, which is a plugin
specifically for pathfinding that was based on a previous plugin called renepay,
which is an implementation of Pickhardt Payments related to René Pickhardt,
basically what this new feature does is that it will deduct the routing fees
from the payment amount, effectively making the receiver pay for the fees.  So,
this is just an extra feature added to the askrene plugin, quite simple to
understand.  And the way askrene works is through layers.  So, this is just an
extra layer that is added to indicate that the routing fee has to be deducted
from the payment amount.

**Mark Erhardt**: If any of the Core Lightning (CLN) people are listening, I can
only recommend not to do this in case they have similar issues with that as we
do, because subtract_fee_from_outputs as a feature on the Bitcoin Core wallet
has been an endless source of bugs and pain.  So, unless you are very confident
that turning around the whole paradigm of how fees and the sending amount fit
together, that has at least been a terrible idea on Bitcoin Core.

**Gustavo Flores Echaiz**: Thank you for that comment, Murch.  Yeah, that's
important to point out.  The PR is now merged, but I think that the CLN team
still appreciates your feedback on that.

_Eclair #3244_

We follow up with Eclair #3244.  Here, two events are added when making
payments.  The first one, PaymentNotRelayed, is emitted when you couldn't relay
a payment to the next node.  So, specifically, I believe when you're making the
payment yourself and you're trying to make the payment and it fails, this is
when this is emitted.  And the second event, which is called
OutgoingHtlcNotAdded, this is emitted when you couldn't add an HTLC (Hash Time
Locked Contract) to a specific channel and, from what I understand, this means
that you were relaying a payment from someone else.  So, the first event would
be when you're trying to make a payment, and the second event is when you're
relaying an HTLC, so someone's trying to use your node as a routing node to make
a payment.  Usually, these events indicate that there's insufficient liquidity,
so it should maybe help you build an heuristic for liquidity allocation.

However, the PR notes that it's important to consider that a single event isn't
enough proof to indicate that you're missing liquidity.  So, it's better to wait
for multiple failure events before adding more liquidity, because a malicious
sender could try to game these events to get you to allocate liquidity for free.
So, important to consider this as a heuristics for liquidity allocation instead
of triggering allocation just by one single event.

_LDK #4263_

We move forward with two PRs related to LDK.  The first one, LDK #4263, adds a
new optional parameter to the pay_for_bolt11_invoice API, which allows a caller
to embed arbitrary metadata.  This optional parameter is called custom TLVs
(Type-Length-Values).  And basically here, the difference, let's say, between
using a payment description and using a TLV is that you don't have to handle the
payment hash or the preimage.  You can directly embed metadata on the payment
onion.  And this is specifically used for programmatic uses of data embedding
and then data parsing, so for example, when making a payment, if I want to
basically say that this payment should be considered for a specific programmatic
use case, such as an order ID or an authentication token, or any other
structured data that the receiving node or application needs to process the
payment programmatically.  There's an important note added that this is specific
to BOLT11 and not to BOLT12.  And also, very important to note that this is
something that was already present in a low-level endpoint called send_payment.
So, this is just an addition to a higher-level endpoint that is more commonly
used, so that a caller doesn't have to go through the lower-level endpoints.
Any comments here?  Perfect.

_LDK #4300_

We move forward with three final PRs, the next one on LDK, #4300.  Here, support
for generic HTLC interception is added, which is built on a mechanism that was
introduced when async payments were added in the last few weeks to LDK and
expands its prior capabilities.  So, in Newsletter #230, we covered that LDK
added functionality for intercepting HTLCs that had fake short-channel IDs
(SCIDs).  So, this PR expands that use case to be able to intercept specifically
SCIDs that are calling for interception.  But the main goal is for offline
private channels that are useful for LSPs to wake up sleeping clients.  So, in
Newsletter #365, we covered the implementation of LDK of BLIPs #55, also known
as LSPS5, which defines how clients can register for webhooks to receive push
notifications from the LSP to be woken up when receiving a payment.  That
newsletter covered the client-side implementation.

This PR that I'm discussing right now basically builds the foundation for
building the LSP or server-side implementation of LSPS5.  And it all would also
enable additional LSP use cases, but this is the focus of this PR, is enabling
LSPS5, which allows LSPs to wake up clients that have signed up for webhooks
when receiving a payment when offline.  Any questions, comments?  Perfect.

_LND #10473_

We're very close to the end.  We now have LND #10473.  So, in Newsletter #386, I
discussed the introduction of an experimental gRPC subsystem called switchrpc,
which had the BuildOnion, the SendOnion, and the TrackOnion RPCs.  And
basically, this subsystem was introduced so that external controller software
could handle pathfinding and simply use LND for HTLC delivery.  So, one problem
that was remarked at that moment is that the SendOnion RPC wasn't fully
idempotent, which means that it wasn't necessarily safe to dispatch multiple
attempts of the same payment, because you could find yourself making twice the
same payment and thus losing funds.  So, bringing back to the PR of this week,
LND #10473 basically completes the previous work and makes SendOnion fully
idempotent, which enables clients to safely retry requests after network
failures without risking duplicate payments.

The way it does this is by every time the SendOnion RPC is called, LND will give
it an attempt_id before making the dispatch of the HTLC.  That registration
allows for this behavior.  So, if the external controller then tries to make a
second payment, LND will recognize that the same attempt_id was used, and thus
identify correctly that this was a duplicate and not dispatch the payment.  So,
yeah, if a request has already been processed, the DUPLICATE_HTLC error will be
returned.  Yes, Murch?

**Mark Erhardt**: Brief question.  So, the attempt_id, is it created on the side
of the caller or on the side of the processor?  And if it's created on the side
of the processor, it must be created deterministically from the input or
something, otherwise how would the duplicate be found?  Did you happen to say
that in the description?

**Gustavo Flores Echaiz**: Yes, that's a very good question.  So, I just read
the description before describing this and I cannot find information
specifically about who determines what is the attempt_id.  If I quote what is
written, basically the first step is the registration, and the handler's first
action is to call InitAttempt, and this write-ahead style approach creates a
durable record of intent to dispatch that serves as the idempotence anchor.

**Mark Erhardt**: So, it sounds like the receiver side is parsing and creating
the attempt_id and checking whether it's a duplicate.  So, it is not something
that the caller has to keep track of.

**Gustavo Flores Echaiz**: Yeah, exactly.  From what I understand, that's
exactly right.  This is something that is handled by LND and not by the external
control.  Perfect.

_Rust Bitcoin #5493_

We finish with Rust Bitcoin #5493, where the ability to use hardware-optimized
SHA256 operations on ARM architectures is added.  So, this is something that was
done on x86 architectures, covered in Newsletter #265, so about two-and-a-half
years ago, but it was missing implementation on ARM architectures.  So, this
hardware-optimized algorithm is added to make faster SHA256 operations.  And
benchmarks show that hashing is approximately five times faster with using this
hardware acceleration algorithm on these operations, specifically when you're
processing large blocks.  So, yeah, this was the final PR and this completes the
section and the whole newsletter, unless, Murch, please, if you have any
questions.

**Mark Erhardt**: I think that might have trailed a little bit because there
might have not been a SHA instruction on ARM until recently.  So, this is
something that becomes available on the chip instruction set.  And I seem to
recall that this is a fairly recent development that SHA256 is part of the
instruction set on some chips.  I don't recall exactly whether it was just added
to ARM, but that might be part of the explanation here.

**Gustavo Flores Echaiz**: That would make a lot of sense.  Thank you, Murch,
for adding that.  The PR description doesn't specifically point to that.  From
what I can see, it just says that this was missing, and so the author had to add
it.  But yeah, that would make a lot of sense.  Thank you, Murch.  And yes, this
completes the newsletter.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.

**Mark Erhardt**: Yeah, thanks.

**Mike Schmidt**: Thank you also, Murch, for co-hosting.  And we want to thank
our guests, Jonas Nick, Antoine, Chris, and Toby for joining us.  Always an
interesting and long one when we do that Changing consensus segment.  So, we
appreciate you all also for listening.  We'll hear you next week.  Cheers.

**Mark Erhardt**: Cheers.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
