---
title: 'Bitcoin Optech Newsletter #401 Recap Podcast'
permalink: /en/podcast/2026/04/21/
reference: /en/newsletters/2026/04/17/
name: 2026-04-21-recap
slug: 2026-04-21-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by Remix7531 and Luis Schwab to discuss
[Newsletter #401]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-3-21/422553391-44100-2-00da219342443.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #401 Recap.
Today, we're going to talk about nested MuSig2 in Lightning, or
potentially using nested MuSig2 in Lightning; we're also going to talk
about formal verification, this time in secp in the modular scalar
multiplication; and we have, I think, five entries in our Changes to
services and client software and then we have our weekly segments on
Releases, release candidates and Notable code and documentation changes.
This week, Murch, Gustavo and I are joined by a couple of guests and
we'll have them introduce themselves.  Remix, you want to say hi and
talk about what you're working on?

**Remix7531**: Hi, I'm Remix, and I'm working with formal methods on
cryptography.

**Mike Schmidt**: Awesome.  Luis?

**Luis Schwab**: Hey, I'm Luis, I'm a grantee from Bitcoin Dev Kit, and
I'm currently working on wallet integrations with utreexo.

_Formal verification of secp256k1 modular scalar multiplication_

**Mike Schmidt**: Excellent.  We're going to go a little bit out of
order since we have our guests on.  We will jump to the second news
item titled, "Formal verification of secp256k1 modular scalar
multiplication".  Remix, you posted to the Bitcoin-Dev mailing list
about a project that you have apparently been working on for some time,
to formally verify parts of secp's implementation.  Maybe to start off,
how would you articulate for listeners what it means for something to
be formally verified?

**Remix7531**: Yes, so what it means to formally verify is basically,
you write a mathematical specification of what a program should do and
then you write a proof that the code that you're verifying matches the
proof, so that it actually computes what the proof says.  And then, you
use a proof assistant to mechanically check every step of the proof.
So, you don't have a teacher or professor checking your proof, but the
computer is actually doing that part.

**Mike Schmidt**: Okay.  I think it makes sense.  Maybe you can walk us
through the example, and maybe not an example, but the project that
you've worked on here in terms of C, and maybe that'll help.  Maybe you
can mention some of the tooling and how it works so we can connect that
explanation to something more tangible.

**Remix7531**: Yeah, so what I've been working on since the beginning of
the year is a proof of concept that it's part of my OpenSats grant.  I
am evaluating different toolchains to do this formal verification.  So,
formal verification is not a new concept, it has been done by different
people over the years.  And so, basically, I'm looking at the codebase
of secp and evaluating which tools I can use for doing that.  And the
first toolchain I used was the Verified Software Toolchain (VST).  It's
arguably the most well-studied or most used, oldest toolchain for doing
this kind of work on C.  It was originally developed at Princeton, and I
now think it's continued to be worked on at the University of Chicago.
And basically, what you can do with it is you have a program that
converts your C code into an abstract syntax tree that you can then
reason about inside a proof assistant.  And because all that is quite a
bit of work, I started with a single function of a signature generation
verification, and that is this modular scalar multiplication.

All that function really does is it multiplies a with b, and then does
mod n.  So, it's a small function, it has about 300 lines of code, and
the proof to check this function is along 6,000 lines of proof code.
But what you get from that is a guarantee that for any input, not just
specific unit tests of tests you're doing with fuzzing, for any possible
input, which is 2^512, it will always give you the correct result and it
will not have like a memory leak or an integer overflow, or any other
kind of undefined behavior.  Does that explain it a little?

**Mike Schmidt**: Yeah, I think that that makes sense.  I'm curious, you
mentioned some of the types of errors or behavior that would be avoided
by formally verifying.  What is that list; maybe the top items, or if
there's a smaller list, the list in entirety?

**Remix7531**: Yeah, so in general, it is the memory safety, then any
kind of integer overflows or division by zero.  Yeah, that's basically
the main things.  And the motivation for this is also because when you
look at crypto code, the cryptographers are very well at designing new
algorithms and primitives, so they go through rounds of review, they may
be going through standardization, but the actual bugs in crypto code are
implementation errors, and this is what we are preventing with this.

**Mike Schmidt**: I see.  On the Brink Engineering call, we had on
Russell O'Connor, who did some formal verification of safegcd in
libsecp, and he walked through some of his tools and approaches to that.
I'm not sure if you're familiar with his work and if you built on that
work, or is this like a different stack that you're using or a different
approach?

**Remix7531**: No, I am not 100% sure but I think he also used the VST.
He also acquired a license to use some parts that are not free, so I'm
pretty sure it's the same stack.

**Mike Schmidt**: Okay, yeah, interesting.  Maybe listeners would be
curious about the level of effort that went into this, because I think
folks hear these benefits and just, I think, initially would say, "Yeah,
let's do it all.  Have all the codebases formally verified".  So, maybe
you can articulate what you can and cannot formally verify, and also some
indication of how much work went into this.

**Remix7531**: Yeah, that is a usual answer to that.  Like, "Yeah, let's
just verify everything".  And that's where you have to stop them.  In
theory, you can formally verify any code, any C code, but it takes some
tremendous work.  So, for the VST, a general rule that I've seen in
other works and papers is that for a single line of C code, you have 20
lines of proof code.  And what does proof code mean?  It's basically
steps that you take, as they call tactics, that are used to convince the
proof assistant that you're basically the teacher, the checker, that
what you're actually doing is correct.  And in terms of time, this is
the first time I used the VST.  I've used other proof assistants for
other projects before, but it took me about, I would say, two to three
months to get used to Rocq and the VST, and then five weeks to do this
scalar multiplication.

**Mark Erhardt**: So, now that you know how to do it, obviously you
would be way faster for doing it for another one, right?

**Remix7531**: Of course, yeah.  And there is more advanced, so to say,
tactics, like steps convincing the proof assistant that I haven't really
touched or understood.  So, there is room for not just being better at
it myself, but also using more advanced tools as well.  But this 20-to-1
rule is kind of general.

**Mark Erhardt**: Right, so how does that proof code factor into it?
Is the proof code reflective of the work that the software stack then
has to plow through, or do you write it manually, the proof code?

**Remix7531**: Yeah, so the proof code you write manually, and maybe we
can talk about writing it with an AI later.  But yeah, you write the
proof code and it's an interactive process.  So, you have your current
goal and state accepted by the proof assistant, and then you basically
give them a tactic to form that rule or the goal or the current state
and you try to bring them together.  The state should, at end, be the
same as the goal.  Sometimes you run in the wrong direction doing your
proof.  Maybe business people are familiar with doing informal proofs
with pen and paper in undergraduate studies or something.  Sometimes you
go in the wrong direction and you have to start over.  It's basically
very similar to doing pen-and-paper proofs.

**Mark Erhardt**: Okay, cool.  So, what's your overall project?  You now
did a formal proof for a single function, from what I understand, right?

**Remix7531**: Yeah.

**Mark Erhardt**: Is the idea to have a full formal verification of the
libsecp library, or is this generally secp and can be used by any
implementer of it, or how does it work?

**Remix7531**: Yeah, so the overall goal, I think I also wrote it in the
blog post, is that of course you want to have a fully verified secp
library.  But right now, I'm still in the exploration phase, looking at
different proof assistants.  This was the first one.  And of course,
there's other tools that might have better automation or other workflows.
And once I know which tool to use, then of course the goal is to have an
end-to-end verified libsecp code.

**Mike Schmidt**: I know in some cases, testing requires some refactoring
to get things sort of appropriately modularized for the testing.  Is that
the same case here with formal verification?  And if so, I've heard that
secp is pretty modular, and so you can just jump in and start, you know,
picking off functions?  Or does there need to be work at the secp layer
to architect it for this sort of work?

**Remix7531**: Yes, so there's two things that the VST does not support.
And it's first returning a struct from a function that is used in
libsecp.  And the second one is assignment of struct.  So, you have to
assign every field of a struct manually.  That is a refactor you
definitely have to do.  And on the other side, which I also did for this
project, is the original code used macros very heavily for the
computation of, let's say, some results.  And I had to convert these to
inline functions.  So, instead of macros, you have, in C, inline
functions.  Because otherwise, you can't really use a divide-and-conquer
strategy.  So, you try to prove a single helper function.  Let's say it
just adds two numbers, and then you have another one that multiplies two
numbers, and then you kind of get to have a modular proof.  And if you
would have to have macros, it would have the entire big function and have
to do the proof all at once.  And it has to be seen if turning macros
into an inline function has any performance implications, but I think
with the modern compilers, it shouldn't really be a problem.

**Mike Schmidt**: Have you been following along, Remix, with some of the
discussion on the mailing list this past week about Hornet Node and the
attempts there to do formal verification on Bitcoin consensus rules?

**Remix7531**: I've read the mails but I haven't really looked into the
Hornet Node yet.  So, I understand that they implement a domain-specific
language for C++, but I don't think they're doing actual formal
verification of the consensus code.  I think the project is more about
formalizing the actual rules at this point, but I don't know.

**Mark Erhardt**: Yeah, that was my understanding too.  Toby Sharp was on
a while back and was talking about trying to, as a byproduct or as one of
the two products he's trying to develop while creating Hornet Node, he
wants to try to formally specify the Bitcoin protocol.  So, I think
that's related, but not quite exactly the same.  He has also been
implementing a lot of the cryptography around it, from what I understand.
He was implementing ECDSA signing and things like that.  So, maybe he
would be an interesting conversation partner in this regard.

**Remix7531**: Yeah.  As for the consensus code, it's all written in
C++, and formal verification of C++ is a very difficult thing.  I think
many people tried and failed, and so I don't know if that is possible
with current tooling.

**Mike Schmidt**: If there's listeners that are curious about this sort
of work and the details, obviously there's the post that you have up on
remix7531.com that they can go to.  What other resources would you point
people to who might be curious about tinkering with this sort of thing?
Are there, like, onboarding to formal verification resources out there,
or just check out your posts?

**Remix7531**: Yes, there's a very great book series.  It's named
Software Foundations.  It has multiple volumes and you can use it to
learn how to use Rocq, the proof assistant I'm using, and it's
interactive.  So, you shouldn't really read it as a PDF or in the
browser, you should be opening it in your editor, and then you can read
along and do the examples or the exercises.  And it's a really great way
to learn about formal verification.  And if you're interested in my
work, you can go on my website, and I'm a very big fan of just writing
somebody an email and, yeah, that's how you can get in touch with me.

**Mike Schmidt**: Okay, excellent.  Well, that's probably a good spot to
wrap up, Murch, unless you had any follow-up questions.  Okay.  Well,
Remix, thank you for your time.  Thank you for your work on this and for
joining us to explain it today.

_Utreexod 0.5 released_

We will move down now to the last two items in the Changes to services
and client software monthly segment.  First one is Utreexod 0.5 being
released.  Luis, I know you touch a bit of both this as well as
Floresta, and I was hoping if we had you on for one, you could help us
with the other.  Utreexod 0.5, do you want to talk a little bit about
why that is an important release and what's in there?

**Luis Schwab**: Yeah, so utreexo is basically, we are trying to compress
the UTXO set in a way that fits into lightweight devices like phones or a
router, whatever.  Currently with Bitcoin Core or anything that uses the
UTXO set, we can't really do that because the UTXO set size is huge, and
we need to do a lot of lookups on the LevelDB to validate stuff.  So,
that pretty much puts phones and anything lightweight out of the
question.  So, Tadge came up with utreexo back in 2019.  It introduces
two new types of nodes.  The first one is a bridge, which pretty much for
each new block, it creates a merkle proof for the block and creates a
forest of merkle trees to model the whole UTXO set.  So, each UTXO is a
leaf on that tree.  And then we also have CSNs, which are Compact State
Nodes, which rely on proofs generated by the bridge.  So, let's say you
mine a new block, the bridge will receive that.  It's going to add the
UTXOs for the block on the tree and remove the UTXOs that were spent.
And then, when a CSN receives a block, it doesn't have a UTXO set.  So,
we can't really validate the block without extra information.  So, it
asks for utreexo proofs from the bridge, which are just merkle inclusion
proofs, so they can verify that those UTXOs that are being spent are
actually in the UTXO set.

So, with these new batch releases, we are mainnet-compatible.  There's
three BIPs for utreexo, which are BIPs #181, #182, and #183, using the
P2P implementation that's defined there.  We also introduced SwiftSync.
So, we have a huge problem that when a CSN is doing IBD (Initial Block
Download), it needs to ask for a proof for each block, right?  Those
proofs represent almost 70% overhead.  So, it's a lot of data for you
to download.  So, with SwiftSync, you can cut that a lot, because we
only need proofs from the height SwiftSync ends.  And so, we cut back on
a lot of data.

_Floresta 0.9.0 released_

And for Floresta, we recently swapped the old libsecp
consensus for kernel, which is a lot better maintained and more
performant.  And we are doing a lot of work to get that production-ready.

**Mike Schmidt**: Maybe you can comment a little bit, you mentioned
bridge nodes, you mentioned the compact state nodes; we have utreexod,
we have Floresta.  Which of those projects implements which of those
types of nodes?  And maybe you can just kind of connect the architecture
that you outlined with these bridge and compact state nodes to these two
pieces of software.  Do they both implement both, or maybe explain that
a little bit?

**Luis Schwab**: Yeah, so utreexod is a fork of btcd with utreexo support
implemented.  And Floresta is made from scratch.  So, it's a composable
set of libraries that you can use to build nodes.  We have like the main
production node, which is florestad, which is built on top of those set
of crates, but other people can use those crates to build nodes that fit
their own application.  So, you can embed a node inside a wallet, you
can put it in a device, whatever you want.  I've managed to compile
Floresta to run on my router, so I have a node in my router.  That's
just one of the possibilities of this.

**Mike Schmidt**: And if I'm running a bridge node, am I running
utreexod, florestad, or I can run either, I can compose my own with the
modular Floresta libraries, or how does that work?

**Luis Schwab**: No, so the only implementation of a bridge you have
today is utreexod, and Floresta is an implementation of the CSN.  But
there's nothing stopping you from making a bridge with Floresta.  It's
just not a focus right now.

**Mark Erhardt**: Okay, just to recap.  So, the main idea with utreexo
is that we usually don't want to trust other nodes for the validity of
data.  We just take the data from them and then verify everything
ourselves on our nodes.  And with utreexo, we prove that the data is
correct and therefore we can just provide the proofs, or receive the
proofs, validate the proofs, and then update our UTXO set
representation, which is just a miniscule forest of merkle trees, to
prove that a UTXO exists, and then with the updates, whether it got
spent.  And so, we're talking about two pieces of software here that we
have both updates for in the newsletter.  One is utreexod, which I think
is the more comprehensive implementation so far, that implements a
so-called bridge node.  The bridge node sort of does the legacy
validation but then provides proofs.  And Floresta is currently only a
CSN that can process proofs and then update the representation, the
forest of merkle trees of the UTXO set on its end.  And that one is
running in your router, right?

**Luis Schwab**: Yeah, that's not exactly.  So, the bridge keeps a
forest of merkle trees representing each UTXO, and Floresta only keeps
the roots of those trees.  So, let's say Floresta receives a block.  It
validates all the scripts, all the transactions, like any of our other
nodes.  We use the same consensus engine as Bitcoin Core.  But it cannot
verify that those UTXOs are indeed present in the UTXO set.  So, it asks
for a proof to the bridge, like, "Prove to me that these UTXOs are in
the UTXO set".  So, with that inclusion proof, I can verify that the
root hash is the same that I had.

**Mark Erhardt**: Right.  That's basically a merkle branch to one
specific root in the forest.  And because you have the roots of the
merkle trees, you can now look at the right root attached to the merkle
branch.  And if that proof that was provided, all the hashing steps
compute, then obviously the UTXO must be present in the tree.

**Luis Schwab**: Exactly.  And the other point about wallet privacy data,
this is one of the biggest points of this, because pretty much any
wallet today just hits an API, like Explorer or Electrum, or whatever.
With Explorer, we don't have any guarantees about the data.  Electrum
can provide some inclusion proofs as well, but you're still not
verifying anything.  And what's huge about this is you can embed this
into any application.  So, let's say you have a mobile wallet.  You can
have a node running there, it's going to receive every block, it's going
to validate every block and let you be absolutely sure of the validity
of the information.

**Mark Erhardt**: Right.  Usually, thin clients can be lied to by
omission.  So, the server or other node that they're getting data from
can just tell them, "No, there's nothing interesting for you here",
while there is maybe a UTXO or transaction that is relevant to the thin
client.  This is not possible in the utreexo model, because you can
actually prove the existence of every UTXO.  And you can actually also
prove that something was spent by showing, if I remember -- I read the
BIP such a long while back, like half a year ago -- if I remember
correctly, all of the trees are sorted.  And therefore, if you show the
leaf that would be to the left of the one that you're looking for and
the leaf to the right of the one you're looking for, and obviously the
leaf for that UTXO is not present, you can even prove that a UTXO no
longer exists with this model.

**Luis Schwab**: Yeah, and without mentioning the privacy concerns.
Because when you're using Stratum or Electrum, you're hitting an API
endpoint, you're telling, "This is my address, and this is my IP".
With utreexo and Floresta, you remove that out of the equation
completely, because you just act like a normal Bitcoin node on the
network.  There's no honeypot indexing servers or anything like that.

**Mark Erhardt**: Right.  And then, every transaction you process has to
be translated by a bridge node, which then adds the merkle proofs for
the UTXOs to the forest of merkle trees that we have the roots of.  And
therefore, basically you trade off compute and bandwidth for less data
storage and more privacy.

**Luis Schwab**: Yes.  And it's super light, like takes 200 MB of RAM.
We don't keep any blocks, so we validate a block and throw it away.  So,
pretty much no storage as well.  Also implements compact block filters,
so we can do full scans backwards.  So, it's a pretty complete piece of
software.

**Mark Erhardt**: Yeah, that sounds pretty awesome.  Now, just to be
clear, you said earlier, the bandwidth overhead for blocks is roughly
70%.  So, while you're catching up your node for a full archive node,
you basically download 1.7 times as much data as the whole blockchain.
How much do you download with the CSN?  You must process the proofs in
some way, I assume.  Do you download all of that too?

**Luis Schwab**: So, you can choose to either download every block since
genesis and validate them, then you're going to have a huge bandwidth
usage.  But we can also do something called assumeutreexo, which is kind
of like assumeUTXO, where you can export a height, a set of roots.  You
can start at some height and you can skip IBD.  So, that's the default
on the binary.  Every release, we make a new checkpoint and it's going
to automatically jump to that height.  You can also sync from genesis.
It's going to take like just as much as Bitcoin Core takes.  And you can
also do something called backfill.  So, you skip IBD and then you
validate blocks backwards in the background.  So, the node is up and
running very fast.

**Mark Erhardt**: Cool, very nice.  How closely do you work with the BIP
authors?  I've been hoping to get an update on the BIPs.  They've been
open for quite a while.  They read very well in the last iteration
already, but it seems like the software is coming out before the BIPs
here.

**Luis Schwab**: Yeah.  I work with them very closely.  There's still a
lot of architectural decisions to be made, so we don't want to drop
anything too fast, you know, make it right.

**Mike Schmidt**: I think we covered both of those pieces of software
pretty well.  Luis, any calls to action for listeners in terms of
testing, using, contributing, feedback, anything like that?

**Luis Schwab**: At the moment, I'd say run a bridge.

**Mike Schmidt**: How many people are running bridges these days and how
do you quantify that being like a bottleneck?

**Luis Schwab**: I mean, right now, not a lot of people.  I think not a
lot of people know about this.  There's not really that much of a
bottleneck right now, because we don't have a lot of users, but it will
be interesting to have more people running bridges so we can decentralize
this kind of node running.

**Mark Erhardt**: That brings me to a follow-up question.  I don't know
if you already stated that, but can the CSNs forward the proofs for
blocks, or do the proofs always have to come from bridge nodes?  So,
would it be enough to have like a handful of bridge nodes and then the
proofs propagate around the CSNs?  Or do you actually need to have sort
of a one-to-one relationship from every CSN to bridge nodes?

**Luis Schwab**: That's in the plan, but not currently.  We still need
to implement proof-caching on the CSNs.  But yeah, in the future, we
only need like a few bridges for it to work.  Because the idea is, I
don't know, like a CSN wants to broadcast a transaction, it's going to
cache the proof for its UTXOs, and then it attaches that to the
transaction when it wants to broadcast, so nobody needs to ask a bridge
for those proofs.  But that's not implemented yet.

**Mark Erhardt**: Maybe my antagonistic mindset is going a little too
far, but how concerned would you be about the network splitting at the
points of the bridges?  If there's only a handful of bridges, and I
don't know, maybe a weird transaction causes them to fail, wouldn't that
split off the entire utreexo subset of nodes?  Have you guys been
discussing that?

**Luis Schwab**: No, that doesn't work, because CSNs can also talk to
normal Bitcoin Core nodes.  Like, most of the blocks will be fetched
from normal Bitcoin Core peers.  You only need the bridges for the
proofs.

**Mark Erhardt**: But a CSN without the proofs cannot update the forest
of merkle trees, right, because they don't actually have the UTXOs, so
they can't construct the update?  So, does it help them to get the
legacy format blocks?  Maybe I'm missing something here.

**Luis Schwab**: Yeah.  In a sense they will be stuck, but there will
not be a chain split.

**Mark Erhardt**: Oh, okay.  So, you're saying they would be aware that
a new block has come and they are aware that they haven't received the
content of the block yet.  And therefore, it would be hard to trick
them, or they would sort of be able to at least realize that they should
pause and wait -- okay, I see.

**Luis Schwab**: They're just going to work on the [inaudible] proofs.
They're not going to split to another chain, or anything like that.

**Mark Erhardt**: Right, okay.  Thank you.

**Mike Schmidt**: Luis, thanks for joining us.  We appreciate your time.
We appreciate your work on this novel light client work and you're free
to drop, we understand if you have other things to do.

**Luis Schwab**: All right.  Thank you guys.

_Discussion of using nested MuSig2 in the Lightning Network_

**Mike Schmidt**: Cheers.  We're going to jump back up to the News
section.  We have our first item, "Discussion of using nested MuSig2 in
the Lightning Network".  This was a post by ZmnSCPxj, and if you are a
listener of the show or reader of the newsletter, you know that his
proposals can get somewhat technical.  Unfortunately, he wasn't able to
join us today, so Murch and I are going to try to give an overview of
it, and maybe we can touch base with him at some point in the future on
this, when we have him on for other discussions.  But he posted to
Delving Bitcoin, "Towards a K-of-N Lightning Network node".  And in it,
he sort of poses this question, "Can we make a multisig self-custodial
wallet with Lightning Network integration?"  He puts forth the use case
of someone who owns bitcoin and maybe wants to use it to generate
routing fees on the LN, but somebody who owns bitcoin doesn't really
want to give away their bitcoin for someone to operate that.  And so, he
comes up with this idea, "Hey, can we make signing on the LN K-of-N so
that the owner can have some keys", maybe there's some other operator
that's doing the routing or some such thing, or even if they're just
doing it themselves, they can not have it all in one key.  And so, he's
building on this idea of nested MuSig2, which I think was a paper from
a couple of months ago.  He touches on FROST as well to be able to
achieve this.

But he brings up in this post that there is part of the BOLT
specification that might need to change in order to enable this.  And
this is part of the LN spec that has to do with the shachain, which is
how revocation keys are handled.  And maybe, Murch, you can bail me out
with this, but that needs to be modified to be optional.  So, I think
there's an optimization there, so you don't need to hold all the past
revocation keys.  And that optimization is sort of incompatible with
this k-of-n signature scheme that he's proposing.  So, he's proposing to
make that piece of the spec optional so that maybe there could be these
sorts of channels in the future.  There's more work to be done, but
that's what I took away from the post.

**Mark Erhardt**: Okay, maybe a couple comments first.  The idea here is
to make one of the two sides in the channel k-of-n.  The channel in
principle is already 2-of-2, but then one of the two out of the 2-of-2
would be a k-of-n under the hood.  And from reading this post, or rather
the news item here, my understanding is that the way that the state
progression in the channel is managed usually, you get a new sort of
step in a chain of secrets that depends on the previous.  And for some
reason, this is difficult to do when you don't have a single key but
multiple involved keys, because it's derived from key material.  So, if
the key material is distributed, I think you can't have this shachain,
and that's where that is coming from, is my understanding here.

So, the problem basically seems to be if you have a 2-of-3 onchain
wallet on the other end, you can't easily just plug the construction
into the Lightning channel on that side, because other things in how
the Lightning channel is managed depend on there being a single key and
being able to derive information from the private key material.

**Mike Schmidt**: Yeah, so a bunch of different pieces of technology.
So, there's part of the LN spec here; we're talking about MuSig2; he
mentions in order to get the k-of-n features, we're talking about FROST.
So, there's a lot of big-picture moving pieces here.  For folks who are
curious about the details, obviously jump into the Delving Bitcoin post,
because I'm sure we did not fully do this idea justice, and so you all
can explore maybe on your own some of the details.  Murch, anything
else you'd like to say about this item?

**Mark Erhardt**: Sorry, I wanted to add a little more.  So, generally,
I think ZmnSCPxj has been writing about several of these ideas before.
So, he has written about channel factories before.  He had another
proposal that proposed a sort of Lightning channel battery that was
shared between multiple large entities and was essentially a single,
much more slowly-updating shared channel between many parties.  So, the
idea was that these large holders might have channels crisscrossing
between each other, but then they would have one big UTXO that they have
shared control of that uses a different scheme than Lightning, that they
could reassign the payout from in order to rebalance their network of
channels among each other on a maybe once-per-day basis.  So, this at
least contextually fits with the other proposals that ZmnSCPxj has been
thinking about.  I think that all of these would still benefit from
ideas like TEMPLATEHASH or ANYPREVOUT (APO) as a predecessor to achieve
LN-Symmetry and/or other covenant proposals that would make them much
more interactive or more powerful.

I think ZmnSCPxj's background idea in this context is that he thinks
it's unlikely for such a covenant proposal to be adopted, and therefore
comes up with constructions that can work under the current existing
consensus rules.  But they tend to be a little more complicated,
involved, and highly interactive in order to work around the
non-existence of these covenant proposals.

_Coldcard 6.5.0 adds MuSig2 and miniscript_

**Mike Schmidt**: Back down to our monthly segment, we have Coldcard
6.5.0.  And this release has a few different things that we noted.  One
is the ability to sign MuSig2 UTXOs.  There is also a feature around
signed message, BIP322, for proof of reserves for miniscript and MuSig2
UTXOs.  There's also new support for miniscript and mini tapscript;
taproot spending, signing, multisig; tapscript up to 8 leaves.  BIP129,
which is the Bitcoin Secure Multisig Setup (BSMS) is also added in terms
of support.  And so, it feels like a larger-than-normal Coldcard release
and some good Bitcoin tech in there.

_Frigate 1.4.0 released_

Frigate 1.4.0 released.  We covered Frigate in a previous newsletter,
that was #389, and we've had Craig Raw on as well.  But Frigate is
essentially an Electrum server, which is basically a backend for silent
payment scanning.  And we talked with him a little bit about GPUs and
some of the performance that I think he squeezed out of that.  I don't
remember if we talked with him or if we talked about it, but we covered
that in the show previously.  But with 1.4.0, it sounds like Frigate is
now using this UltrafastSecp256k1 library in addition to the GPU
computation.  And I think it's like 14 times faster using that library.
So, I'm unsure the details of those optimizations.  I've seen this
library talked about in Delving, but I didn't dive into it, until this
is the first time I've seen someone using it.  So, that's interesting.
Murch, did you get a chance to look at this?

**Mark Erhardt**: A little bit.  So, I saw some discussion about this
library, and I sort of want to comment on the trade-offs here.
Basically, this is a reimplementation of libsecp with a ton of
LLM-assisted improvements and speedups, and so forth.  So, I would say
that from a level of review, it would obviously be much less trusted
than libsecp, which is extremely well vetted and has a lot of people
looking at it.  This is an almost completely new library that has some,
I don't know, tens of thousands of lines of code that were output by a
single developer with assistance of, well, according to himself, I
think, with the assistance of LLMs.  So, the goal of this one is to be
very, very fast.  And so, the trade-off, I think, that is attractive
here is when you're only doing validation work and not, for example,
signing transactions and sending funds, this library could be very
interesting in order to do the validation more quickly, which is what
Frigate is using it here for.  And in that case, maybe you're a little
less worried about bugs or correctness or unvetted code, because you're
only validating and you're reading data, not creating data.  So, maybe
in this context, this is a good fit.

I've also seen that Toby Sharp, the Hornet Node developer, was
interested in seeing how quickly Hornet Node would perform if it used
UltrafastSecp256k1 instead of libsecp.  So, yeah, this is, on the one
hand, a very interesting and useful effort to have such a fast library.
But on the other hand, it's probably not something that will get adopted
quickly on the wallet side of libsecp usage, where people might be much
more interested in it taking its time, but being secure, and not having
side channels, having constant time implementations, and so forth.

**Mike Schmidt**: Yeah, I know some of the Delving posts around this
library were seeking feedback, and I think one of the pieces of feedback
was, "Hey, this is tens of thousands of lines of cryptographic type
code, and it's going to be hard to get feedback on a huge chunk of
that".  Like you mentioned, maybe there's a use case for something
that's faster and isn't necessarily the wallet itself, and so maybe this
thing will evolve over time and get more eyeballs on it due to its
usage.

**Mark Erhardt**: I think one of the interesting things might be if you
have a highly vetted piece of software like libsecp, you might be able
to do some cross-implementation fuzzing that verifies that the results of
another implementation matches exactly.  So, I don't know, maybe the
implementer could look into some fuzz comparison throwing the same fuzz
inputs against libsecp and UltrafastSecp256k1, and seeing that it
matches in results all across.

**Mike Schmidt**: Yeah, I wonder if bitcoinfuzz, which I think is
differential fuzzing, could do something like that.  I'm not sure if
they're fuzzing libsecp currently.  But yeah, interesting idea to
piggyback on the correctness of one and use the speed of the other.
Cool.

_Bitcoin Backbone updates_

And our last piece of software in the monthly segment was Bitcoin
Backbone updates.  There were two posts to the Bitcoin-Dev mailing list
about updates to Bitcoin Backbone.  This is a piece of software we
covered a few months ago that is building a node on top of Bitcoin
Kernel.  And the developer posted to the mailing list about two updates.
One was around compact block support, another one around multiprocess
improvements, and a little bit of under-the-hood work.  But I thought
it was interesting.  Obviously, there's Kernel involved here, we're
talking about compact block support, and yeah, I think it's an
interesting proof of concept, interesting prototype that people might
want to poke at.

We can jump to the Releases and release candidates and can bring in
Gustavo who's authored this, as well as the Notable code segment.

_Bitcoin Core 31.0rc4_

**Mark Erhardt**: Bitcoin Core version 31 has been released on Sunday,
I think, the 19th.  So, we'll probably be reporting more deeply on the
content of the 31 release next week.  And then, Gustavo seems to be back
and we'll do Core Lightning.

_Core Lightning 26.04rc3_

**Gustavo Flores Echaiz**: Yeah, thank you, Murch.  Sorry for the
technical issues.  So, yeah, so this week we have two releases which are
two RCs from Bitcoin Core 31 and Core Lightning 26.04.  Both of these
have now been released fully, so in the next newsletter we'll cover
their full release.  I just want to point out, if someone's interested
in more details around the Bitcoin Core 31 and specifically the testing
guide for the RC, we did dig into that in the podcast related to
Newsletter #397; and Core Lightning 26.04 was at its third RC when we
wrote this past newsletter, but we first covered it in the Newsletter
and the Episode #398.  So, we do go into more detail in those episodes,
but we'll have more news for people on the next newsletter and the next
episode when we cover the full versions, not just the RCs.

I just want to say that the Core Lightning (CLN) release was very much
focused on splicing.  So, now that splicing has been merged in the BOLTs
repository, CLN has made many upgrades around its implementation, one
which we'll cover in the Notable code and documentation changes section.
Awesome.

_Bitcoin Core #34401_

So, we move forward with that section.  This week, we have two items for
Bitcoin Core.  The first one, #34401, is the extension in the
libbitcoinkernel API that we've covered multiple times, specifically in
Newsletters #380 and #390.  So, the support for obtaining block headers
through that API interface, which was added in Newsletter #390, is now
extended by adding a method that serializes a block header into its
standard byte encoding.  So, initially, after Newsletter #390, you could
have used this block header support, but you weren't able to obtain it
in a serialized format into its standard byte encoding.  So, you would
need external serialization code if your external program wanted to
store, transmit, or compare a serialized header.  Now, this is no longer
required, and you can just use this method to leverage that.  And why
would someone want to do that?  The practical example is that once you
serialize the header through the API, you could feed those bytes to
hash the header to obtain the blockhash.  So, you don't need an external
program that leverages the libbitcoinkernel API to have separate
serialization code; it can just simply use this API through its new
method to get the standard byte encoding of a block header and use it
for computing a blockhash, for example.

_Bitcoin Core #35032_

The next item, #35032, here there's work being done on a feature that
was introduced in Newsletter #388 called the privatebroadcast option,
which allows users to broadcast transactions through short-lived Tor or
I2P connections, or through the Tor proxy to IPv4 or IPv6 peers.  The
goal here is for Bitcoin Core to open a short-term connection, broadcast
a transaction, and then close that short-term connection.  However, the
issue was that potentially, when using the private broadcast through
those short-lived connections, some peer addresses learned could then be
added to Bitcoin Core's peer address manager.  So, what this new item
does is that it basically ensures that it will never store a network
address learned when using the privatebroadcast option, it will never
store it in the address manager, so that this feature not only hardens
the privacy of this feature, but now all the information learned through
these short-lived connections is isolated from the rest of your normal
usage.

**Mark Erhardt**: That was one of the things that I was curious about.
So, if we only do a version handshake, send our single transaction ping
and pong and then disconnect, I think what we're not doing is asking for
addresses from that peer.  And I was sort of wondering, from my
understanding, that we shouldn't be usually getting any addresses from
that peer in that period of time.  It would sort of be an unexpected
behavior of the counterparty, the peer that we're connecting to, that
they send us any addresses.  Or it might be referring to if this node
were in our unknown table and we connect and we find a peer there, we
would add it to the tried table so that it would be an update of the
specific peer that we actually connected to that gets updated.  But I
even just went over the PRs.  I couldn't really see where we should ever
expect to learn addresses.  So, if you know what I'm missing there,
please fill us in.  Otherwise, maybe our listeners can tell us on
Twitter, or somewhere.

**Gustavo Flores Echaiz**: Yeah, to be fully honest, I reached that
blocker too, so it wasn't clear to me either.  At first, I thought it
was the new short-lived identity that you gain would be added in the
address manager, but then the PR description basically makes you think
that it's about peer addresses that are learned through that connection.
So, yeah, I would then say that if someone's listening and knows the
answer, that'd be great because, yeah, it's not super-clear exactly.
It probably is just a fail-safe to make sure that it would never happen,
even if it's just not normal behavior.  At least, from the description
and the discussion in the PR, it seems to just be a preventive measure
that doesn't necessarily happen in a regular flow.  But yeah, if someone
knows the answer, we'd love to learn more about that.

_Core Lightning #9021_

Moving forward with CLN, two new items are from CLN this week.  The
first one is the enabling of splicing by default by removing it from the
experimental status.  So, when I was covering earlier the Release
section, I mentioned a few changes around splicing.  So, splicing is now
considered fully default and production-ready on CLN.  And if you want
to learn more about the merging of the splicing protocol into the BOLT
specification, or the work that CLN splicing implementation did at the
same time that the splicing protocol was merged in the BOLT
specification, Newsletter #398 and the accompanying podcast episode, we
invited Dusty from the CLN team to basically tell us about both the work
done in the splicing protocol LN specification and on CLN that was fully
attached to it.  So, that episode has more details around that.  But for
now, we can say that CLN, probably in preparation for this 26.04
release, now considers splicing a default feature and a
production-ready feature.

_Core Lightning #9046_

Next, Core Lightning #9046.  Here, there was some interoperability
issue between the keysend implementation between CLN and LDK, where LDK
was expecting a final_cltv_expiry value, or the CLTV expiry delta, for
the last hop to be 42 when receiving a keysend payment.  CLN, however,
was sending a 22 value when sending a keysend payment.  What would
happen is that LDK would simply refuse to receive a keysend payment sent
from a CLN sender, because CLN uses simply a different value than LDK.
And this value is the safety margin for the recipient on the last hop.
So, if something were to fail, it would still have enough time to claim
the HTLC (Hash Time Locked Contract) onchain if the upstream
counterparty became unresponsive and an onchain resolution was needed.
So, LDK was basically just telling CLN, "This is not enough time for me
as a receiver to handle this edge case".  So, now CLN raises this value
so it matches LDK's, and now keysend payments are fully interoperable
between these two implementations.

_LDK #4515_

The next two are from the LDK repository.  So, a pattern in this
newsletter is that there are multiple features that have switched from
experimental status to production feature status.  That was the case for
splicing in CLN, and is now also the case for zero-fee commitment
channels on LDK.  So, the feature bit is promoted from the experimental
to the production feature bit.  We covered in Newsletter #371 LDK's
initial implementation of zero-fee commitment channels, which replaced
the two anchor outputs from regular anchor channels with one shared P2A
output that has a zero-fee value, because we cannot predict the onchain
fees required in advance.  So, this makes it more flexible and modular
for future fee conditions.  So, LDK is the first implementation to not
only implement the zero-fee commitment channels feature, but also to
promote it to a production feature bit.  However, when other
implementations would be ready to move to that production feature bit,
they could be interoperable with LDK.

_LDK #4558_

The next one on LDK, #4558.  Here, something called a receiver-side
timeout that is present in multipath payments (MPPs) is now extended to
also cover keysend payments.  So, basically, when you send an MPP, if
one of the multiple parts fails to reach the destination, the receiver
can have a timeout where it will fail back all the different HTLC parts
back to the sender after it has reached a timeout, so that it can avoid
having HTLC slots tied up and consumed.  However, this wasn't properly
implemented in keysend payments, so an LDK node that would receive a
keysend payment that used the MPP method, if one of the multiple parts
was stuck, then the sender would have to wait until the final CLTV
expiry for those HTLC slots to be freed up again.  So, now the
receiver-side timeout, which was already present in other forms of
transactions that use MPPs but not keysend payments, is now extended to
cover keysend.  So, now a receiver can always fail back those HTLCs and
free up HTLC slots, instead of having to wait for a longer period until
the CLTV expiry timeout.

_LND #9985_

So, the next one, LND #9985, is also, like I said, part of the similar
pattern where things are getting promoted to production feature bits.
So, in this case, it's simple taproot channels, which are promoted to
the production feature bits with a distinct commitment type called
SIMPLE_TAPROOT_FINAL.  So, there is an optimization around the
tapscripts that are used for these types of channels, which will now use
OP_CHECKSIGVERIFY instead of a mix of OP_CHECKSIG and OP_DROP.  There's
also another improvement, something called map-based nonce handling,
that are keyed to the funding transaction IDs.  So, basically, as we've
discussed in previous episodes and newsletters, the simple taproot
channels that are funded through a MuSig2 wallet, they have to change
nonces every time they sign off a different funding transaction.
There's more interchange in the nonces being used on MuSig2 channels.
So, every nonce has to be properly mapped to a different funding txid as
groundwork for future splicing.

So, this promotion to production doesn't just come with a new feature
bit, it also comes with an optimization on the tapscript that is being
used; but also, just properly better mapping between the nonce handling
and the funding txid as groundwork for future splicing.  So, we can
probably expect splicing on simple taproot channels to be follow-up work
in LND from this.  But yeah, this basically is the third promotion to
production feature in this newsletter: splicing in CLN; zero-fee
commitment channels in LDK; and now, simple taproot channels in LND.

_BTCPay Server #7250_

The next one is an addition in BTCPay Server, PR #7250, where LUD-21,
LUD being the LNURL spec, so support for LUD-21 is added, which
basically means an unauthenticated endpoint, or an endpoint that doesn't
require authentication, named verify, that allows an external service to
verify whether a BOLT11 invoice created via LNURL-pay has been settled.
So, as a sender, I have the preimage after I've sent a payment, and I
can verify that I sent a payment.  However, if I'm, let's say, a website
that is feeding a BOLT11 invoice on behalf of a receiver, I might not
have full confirmation that the payment was settled.  I'm not the
sender, so I don't get the preimage.  So, this endpoint allows an
external service to get a confirmation from a Lightning node behind a
BTCPay Server instance, that a BOLT11 invoice created via LNURL-pay has
properly been settled, even if I'm not the sender or the receiver, I'm
just an external service working or providing invoices on behalf of the
receiver.

**Mark Erhardt**: This one's interesting because some of the very early
websites that used Lightning payments, I think there was a demo of a
forum-like construction or blogging website called htlc.me very early
on, 2017, 2018; and what they did was basically just, when the person
that was trying to read the article had paid the invoice, they would
show the proof of payment, the preimage that they received back from
settling the payment, and then forward that to the browser, and the
user would be able to see the content.  Of course, that meant that now,
also the website could basically prove that it had paid the invoice
because it also had the preimage.  And with this new approach, you sort
of get a different way.  You now trust the server to say, "Yeah, this
has been paid and you can serve the content", without having to forward
the preimage and giving the proof out of hand that you paid the invoice.
Although, of course, most of the time it just matters whether something
was paid or not, not that you can prove that you were the one that paid
it.  So, an interesting addition here.

**Gustavo Flores Echaiz**: Yeah, certainly.  I haven't seen it being
implemented in other instances.  I think BTCPay Server must be one of
the first to implement such a feature.  So, yeah, definitely
interesting.

_BIPs #2089_

So, the next and the final item is the PR #2089 in the BIPs repository,
which publishes BIP376, which defines new per-input fields on PSBTv2 to
carry BIP352 tweak data needed to sign and spend silent payment outputs.
So, this complements BIP375, which we had covered previously, I
believe, in Newsletter #337, that basically allowed or specified how to
create silent payment outputs using PSBTs.  So, BIP376 is a natural
follow-up and the completion to be able not only to create silent
payment outputs using PSBTs, but also to be able to sign for them and
spend them using PSBTs as well.  Murch?

**Mark Erhardt**: Yeah, so PSBTs, or Partially Signed Bitcoin
Transactions, are always employed when you either have multiple devices
involved in creating a transaction or even multiple senders
participating in creation of a transaction.  So, we already had a
specification for how to facilitate a multi-user transaction that pays
to silent payments, which is BIP375.  And now, we also have a
specification for how to implement spending silent payment inputs,
right?  So, obviously you need a bunch of data about the previous
transaction in order to be able to construct a silent payments input.
And then, to have the silent payments input exist next to other inputs
requires some additional information.  Yeah, this has been coming for a
while; finally out there.  If you're a wallet developer that is working
on payjoin and wants to support silent payments, I think now that sort
of stuff is ready.  So, maybe take a look.

**Gustavo Flores Echaiz**: And there's been so many different BIPs
related to silent payments, right?  The first one, BIP352, which defines
silent payments.  But then, BIP375, that basically defines how to send
silent payments or create outputs, is preceded by BIP374, which defines
how to create the discrete log equivalency proofs that are required for
that.  But then, there's also BIP392, which describes the descriptor
format, and now we have BIP376, which defines how to sign and spend
those outputs.  Would that be the complete full picture, or is anything
else needed to implement silent payments?

**Mark Erhardt**: I think it's pretty much the complete picture,
especially if we have additional software, like Frigate, that can allow
light clients to more easily catch up with the silent payments
information.  There are also, I think, four or five silent payments
implementations already in production use.  So, I assume that they are
not PSBT-compatible yet, and I haven't really got full information right
here what exactly they all support and whether they can, for example, do
multi-user transactions or anything like that in general, just not for
silent payments.  But I think that should be all of the necessary parts
to sort of get silent payments in, multi-user transaction silent payment
support for thin clients.  And basically, just I'm still excited to see
it also come out in Bitcoin Core.  Hopefully, that's going to be
something that happens this year or next year.  But anyway, yeah, I
think this is all, from the top of my head.

Also, maybe the sending to silent payment outputs is the more
complicated part.  So, BIP375 needed the proofs to make sure that the
other signers participated honestly, otherwise you could basically
accidentally create, or intentionally create, outputs that burn funds
instead of being spendable.  The using of inputs is not as complicated,
because only the party that owns the silent payments input has to do
special work there.  When you send to it, all of the inputs are involved
in the creation of the output.  So, there, you need participation of all
the input contributors.

**Gustavo Flores Echaiz**: Thank you, Murch.  Yes, and that completes
the newsletter.

**Mike Schmidt**: Thanks, Gustavo and Murch.  And we also want to thank
Luis for joining us earlier, as well as Remix, and for you all for
listening.  Thanks for your time.  Cheers.

{% include references.md %}
