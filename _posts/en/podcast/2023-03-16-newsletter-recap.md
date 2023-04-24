---
title: 'Bitcoin Optech Newsletter #242 Recap Podcast'
permalink: /en/podcast/2023/03/16/
reference: /en/newsletters/2023/03/15/
name: 2023-03-16-recap
slug: 2023-03-16-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Calvin Kim, James O'Beirne,
and Greg Sanders to discuss [Newsletter #242]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/67082119/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-2-22%2Fb61c45ac-e3fa-5bfb-1d03-9a6341f5be48.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #242 Recap on
Google Meet.

**Mark Erhardt**: Yeah!

**Mike Schmidt**: Unfortunately, we had Twitter Spaces trouble and we were able
to jump on a Google Meet with our special guests, who will be introduced
shortly.  So, this will be broadcast via our podcast and unfortunately, we had
Twitter Spaces trouble, so we're not sure if we'll go back to that.  Quick
introductions, Mike Schmidt, contributor at Optech and also Executive Director
at Brink where we fund open-source Bitcoin development work.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode labs on Bitcoin stuff and
if you want us to be able to spend unconfirmed UTXOs properly, you should review
my pull request before the feature freeze!

**Mike Schmidt**: Nice, a Murch PR plug!  Calvin?

**Calvin Kim**: Yeah, I'm currently working off of a grant from BitMEX.  I work
on a project called Utreexo, which is merklizing the UTXO set.

**Mike Schmidt**: And, James, you probably don't need any introduction for this
audience, but we'll do it anyway.  Who are you, James?

**James O'Beirne**: I am James O'Beirne, I'm a Bitcoin developer.  I've been on
this show previously to talk about OP_VAULT, a project of mine, and today we
might talk a little bit about assumeUTXO, which is another project of mine
that's four years old as of, I think, yesterday or the day prior!

**Mark Erhardt**: Welcome back to this show.

**James O'Beirne**: Thank you.

**Mike Schmidt**: Well, thank you, Calvin and James, who are joining us and
thank you for getting through some of those audio difficulties.  We just have
one news item and one pull request, but they're both related to projects you
guys are working on, so it's great to have you guys on.

_Service bit for Utreexo_

The first news item is Service Bit for Utreexo.  Calvin, I think we probably
haven't covered Utreexo much lately, so I think it would be good maybe for you
to go through the motivation for that project and what it is at a high level
before we get to the discussion of the actual service bit in your post to the
mailing list.

**Calvin Kim**: Right.  So, Utreexo, like I mentioned before, it's just
merklizing the UTXO set.  So, it has some extra features and bells and whistles
versus a normal merkle tree, namely that you can add and delete to these sets
with just the merkle root.  So, my guess is if I talk about the progress a
little bit.  We've originally been working on -- well Tadge started working on
the accumulator in Go and --

**James O'Beirne**: Calvin, can I just stop you here.  Can you maybe just
contextualise a little bit about why that's a valuable thing and what it can do
for Bitcoin?

**Calvin Kim**: Yeah.  So, merklizing the UTXO set, what it allows us to do is
[that it] allows some nodes to only keep the merkle root, so it's a very compact
representation of the UTXO set.  So, at the moment, that's 4 GB to 5 GB; if we
just have the merkle roots, that's less than 1 kB.  So, obvious benefit is that
now you have nodes that are really tiny.  Some not so obvious benefits also
include, you can now do something cool, like you can put nodes where it couldn't
go in before because it's so small.  We've been talking about something like a
web browser extension; we've also been talking about having the node integrated
with the wallet and having it be fully validating, but not necessarily doing the
P2P stuff, so it would be like a client that does a full validation.  So, those
are stuff like that.

Some extra stuff is, you could do something cool like you could validate blocks
out of order and you have to go into detail a little bit, but basically if the
binary that you ship -- if the node software itself has the root sets at a
certain height, you could start verifying it from there, and so this allows us
to verify block 100,000 and simultaneously, also validate block 200,000 at the same
time.  So, this allows us to parallelize something like the initial block download
where you start from genesis and go to the tip, but instead of doing it
sequentially from 0, 1, 2, 3, 4, you can now do it out of order.  And so, that
is I guess the main benefits that really Utreexo brings to Bitcoin users.

**Mark Erhardt**: So, the difference would be that you still do full validation,
but instead of needing to keep the full UTXO set, you would have an accumulator
that stores only commitments to the UTXOs that you care about, but other people
can prove to you that UTXOs existed and continue to exist by showing you a proof
from this Utreexo?

**Calvin Kim**: Right.  It's a different representation of the UTXO set.  At the
moment, Bitcoin Core uses LevelDB, a key-value data store, but what we're doing
here is we're representing the UTXO set as a bunch of merkle trees.  This forces
us to have new data, so when we receive a block, we need to have a merkle proof
along with the block to prove the inputs that all the transactions are
referencing.  The same goes for when you're at the tip and you're receiving a
transaction, you need to receive proofs for the inputs of the transactions.  So,
that is extra bandwidth, but we do feel strongly that it's a really good
trade-off.

**Mark Erhardt**: That's super-interesting.  We had Benedikt Bünz with us at our
office this week and he gave a talk about how to do a SNARK from a NARK, like a
Succinct Non-interactive Argument of Knowledge without the succinctness, and I
think this sounds a lot like a sort of proof that you could put into that.  So
maybe someday, those two things combined will also allow us to prove that we
have validated the whole chain and it is correct and just jump ahead, and then
we can get rid of assumeUTXO at the same time!

I think everything meets together here right now, not get rid of assumeUTXO, but
we can actually prove that the UTXO set would be correct.

**Calvin Kim**: Yeah, to go back to the original question of what is the
progress on Utreexo like, a lot of my work in the past has also been
researching.  And so, when I first joined, it was a paper no one's published and
then a code that sort of implemented the paper.  The code itself wasn't
necessarily very production ready, there was a lot of other research stuff going
on, something like, "Is this the most efficient algorithm that we can use for
additions and deletions?"  So, we've been doing a lot of iterations on that and
a lot of work has also went into how to efficiently cache things, to lessen the
burden on bandwidth if users want to do so.  So, those things have been there
and so a lot of stuff has been going on behind the scenes with the actual
accumulator itself, and the research of the out-of-order block validation and
all that.

What we're trying to go for at the moment is we're trying to have something
ready for testnet and signet so users can start possibly running it and testing
it out, instead of it just being a blog post or just a paper; it's something
that users can actually use and then try out to see this is something that is
now possible with bitcoin.

**James O'Beirne**: So, Calvin does this live in Bitcoin Core, or is this a
separate program that you would run?

**Calvin Kim**: So, the original plan that Tadge had set out was that since the
accumulator is in Go, we’ll fork btcd, and it's an alternative client written in Go,
and so we'll have sort of a Utreexo of that going.  Separately from that, there
was a project by Niklas Gögge, and he's been working on a fork of Bitcoin Core
that also has Utreexo.  It's not being worked on at the moment, so when this
release happens in a few months, it will just be the Go version, but yes,
eventual goal is to have it into Core.

**Mike Schmidt**: And, Calvin, can you outline what software would users have
the ability to run?  There's this fork btcd node, but there's also this notion
of bridge nodes and maybe that would help folks understand the architecture a
bit, just outlining the different pieces of software.

**Calvin Kim**: Yeah, I had a Twitter discussion with AJ on this earlier today.
So, we talked about merklizing the UTXO set and I talked about the extra data
that you have to download when you get a block or when you get a transaction.
So, the proof has to come from somewhere, someone has to make the proof, because
it's not soft-forked in.  If it was soft-forked in, we could have the miners
commit the proof in the coinbase transaction or something, but the plan is not
to do that.  The plan is to have something called bridge nodes, which translate
the block and the transaction that doesn't have a Utreexo proof on and attaches
a Utreexo proof onto it.

These bridge nodes are nodes that are sort of like translators, so they take the
existing stuff from the existing current Bitcoin Network and it allows Utreexo
nodes to validate them.  So, these bridge nodes, they hold the full UTXO set as
Bitcoin nodes do now.  They have all the nodes of the merkle trees, and so they
do end up taking more data in their system.  So, they would also use up a little
more bandwidth, because they're serving that data, but once that proof has been
created, any Utreexo node can accept it, validate it, keep it and serve it to
other Utreexo nodes.  So, these are translators for the network.  Yeah, go
ahead, Mark.

**Mark Erhardt**: So, this is basically similar to client-side
compact block filters, where you would store, or you optionally can have the
filters and serve the filters to other nodes on the network.  So, you would
basically be storing an additional data resource and offering them per a network
service and someone would be able to acquire them from you.  And since it's a
stable piece of data per block, you only have to generate it once, and if you
have it you can serve it to people, right?

**Calvin Kim**: Yeah, that is the case and it'll be an option.  So, the plan was
to introduce bridge nodes into Bitcoin Core first, so you would have a flag and
you'd turn it on, and it would be something like compact block filters, where
it's optional to turn it on.  I want to make it clear that bridge node is not
associated with an archival node, so you can be a bridge node that is also a
pruned node; you can be an archival node that is also a bridge node, but that is
not a requirement.  So, a bridge node, the only responsibility is that you
translate blocks on tips.  So, once different nodes have the proof of the block,
you store it and just have it forever.

So, that is the current progress of Utreexo.  In a few months, something
included in Bitcoin Core will not be ready.  What will be ready is a bridge node
implementation as a fork of btcd and a very compact -- we call it compact state
nodes, a compact state node implementation in the fork of btcd, so those things
are coming in a few months.

With this, now we go to the service bits and reading the Bitcoin Core file on
the comments, it suggests that there are a certain range of bits, I think it's
24 to 31, that are specially assigned for testing new things.  So they're not
necessarily to be kept forever but they're just a temporary thing that you just
pick one and you just tell everybody on the mailing list, "I'm using this", so
you don't collide with others that may be using something.  So, I just happened
to pick 24 and was hoping that no one was using it.  Thankfully, no one used it.
I think the only other one is a full mempool RBF that's using service bit 26 at
the moment.  I'm not sure of any other experiments that are happening at the
moment.

So Utreexo, when it does ship, it will signal for Utreexo with that service bit
24 and you will be able to see, if you go to some website, like bitnodes.io,
you'll see that this node has service bit 24 turned on, and that means it's able
to understand the Utreexo protocol.

**Mike Schmidt**: And that means, if that node can communicate these compact
proofs with regards to the transaction with regards to the block; it does not
distinguish that it is a bridge node or a compact Utreexo client?

**Calvin Kim**: That is true.

**Mike Schmidt**: It's just, "I speak Utreexo, but I'm not necessarily a bridge
node or not", so it doesn't identify itself as a bridge node?

**Calvin Kim**: Yeah, that is true.  The service bit itself does not identify
whether it's a bridge node or a compact state node.  Really, those distinctions
don't matter inside the context of the Utreexo protocol, the wire protocol.

**Mark Erhardt**: You'd have to know whether the other party's a bridge node if
you are trying to request stuff, right?

**Calvin Kim**: You can request transactions from -- so, it's the same with
like a normal Bitcoin transaction back and forth where, "Do you have this?" and
if you have Utreexo bit turned on, then since -- if you're a Utreexo node and
you're talking to a Utreexo node and they ask, "Do you have this transaction?"
then when you receive that transaction, you should have the proof along with it.
So, the assumption is that you don't really care whether it's a bridge node or
not, you just care if the node that you ask for a certain transaction actually
has it.  And if they only have the transaction and not the proof, that means
they don't have it, because you need the full data.

**Mark Erhardt**: So, a compact state block would only hold its own transactions
though, so they would just say, "I don't have it" if you --

**Calvin Kim**: Oh, sorry, compact state nodes.

**Mark Erhardt**: Yes, would they signal?  So, who sets the 24 bit?  I thought
that it only is set by bridge nodes as in, "I can serve you these transactions
proofs, you can request them from me"; is that right?

**Calvin Kim**: Everybody sets signal bit 24.  So, as a compact state node, so
the very tiny node, not a bridge node, you can feed the transaction with the
proof when you receive them from another Utreexo node.  You don't necessarily
know that it's a bridge node or not, you just care that you received a proof
with the transaction.  So, since you're going to keep that proof with the
transaction, you could also propagate it to other Utreexo nodes.

**Mark Erhardt**: Right, okay.  So basically, the protocol is the same; someone
announces a transaction and if they signal Utreexo support and announce a
transaction, it means that they have the transaction and the proof.  And anyone
that is on the network can of course announce transactions, but the compact
state nodes would usually not announce transactions, because they only keep the
ones they care about.

**Calvin Kim**: Yes.

**Mark Erhardt**: Or, if they do participate and gossip, they would actually
have both of those pieces of data.  I think I've got it now.  Okay, cool.

**Calvin Kim**: Yes.

**James O'Beirne**: So, Calvin, if you've got a Utreexo node that's doing
initial block download with Utreexo, how does it find peers, how does it find
bridge nodes basically to serve it proofs for the historical blocks it's
validating?

**Calvin Kim**: So, when you are doing IBD, you don't need a bridge node to
serve you blocks and proofs.  You can be a compact state node and because this
compact state only refers to the UTXO set, you can be an archival compact state
node and choose to keep all the historical blocks and their proofs.  So, you
just need to connect to a Utreexo node that is also signalling the node network.
If the node has the signal bit known network and it has the signal bit Utreexo,
it means it's keeping all the blocks and it's also keeping all the proofs.  So,
nowhere in the protocol is a bridge node signalling that it's a bridge node, we
don't make that differentiation.

**Mike Schmidt**: You went through the fact that bridge nodes do the conversion
from a standard transaction into this Utreexo-friendly way of distributing the
transaction, which requires a proof to it.  If I'm running a compact state node
and I'm broadcasting my own transaction, is the onus on me to broadcast it on
both networks, or do I broadcast it and the bridge node sees it and then also
broadcasts it on the Bitcoin P2P Network.

**Calvin Kim**: That is a good question.  That is something that's being worked
out at the moment.  So, we'd ideally want nodes to connect to both Utreexo nodes
and normal nodes.  As a Utreexo node, if I want to talk to another Utreexo node,
I have to provide the proof with it.  So, I can have the TX, but not the proof.
So, if I have both, I should really be able to communicate with any nodes, so
that is something that we've not figured out yet that will be figured out soon,
but yeah, we are discussing that.

**Mark Erhardt**: So, you might get an announcement from other nodes, but then
choose not to get it because they can't give you the proof because you have only
one proof as a compact state node?

**Calvin Kim**: Yes.

**Mark Erhardt**: I was curious about how does block propagation work then,
because most nodes would not attach the proofs to each transaction in the block.
Is the block sufficient for you to update your proofs, so if you have a
transaction proof and get the newest block, can you update the proof, or is the
proof stateless to height?

**Calvin Kim**: You can always update the proof when you receive a new block.
That was hard to implement.  That was one of the things that was very difficult
to --

**Mark Erhardt**: Cool, so the proof is always according to a specific height,
because the proof would be invalidated if you spent the UTXO at a certain
height; you should not be able to prove that it still exists, right?

**Calvin Kim**: So, I should mention that a block proof is not specific to each
transaction.  So, you could do it that way, but when you receive a block -- so,
in a block, there's a bunch of transactions.  It's not organised in such a way
where you have a transaction and you have a proof of that transaction.  You have
all these transactions and you have one big proof proving everything, every one
of these transactions.

So the process goes, when a miner finds a new block, they don't really care
about Utreexo, but when they find a new block, a bridge node is going to receive
that block, because they're a normal fully validated node.  When they receive
that block, they will make a proof for it and then they will propagate it with
all the Utreexo nodes.  So, when the Utreexo nodes get the block, they first
validate it with the UTXO commitments that they have and if it is correct, then
they can also update the commitments and they can also update any sort of
transaction proof that they have.  So, per block, you do need to have these
states.

**Mike Schmidt**: What would happen in the case of a reorg or a fork, or
something like that; how would a compact state node be seeing that happen?

**Calvin Kim**: If there is a fork happening at like two blocks prior to the
tip, the assumption is that a bridge node will also be generating proofs for
them.  When it does fork out, actually what the Utreexo library supports is it
actually supports undoing individual transactions, like proofs, so you would go
back and then go forward, just like a normal node.

**James O'Beirne**: So, one thing I'm curious about, based on what you just
described about block validation happening on the basis of one big Utreexo proof
per block, for anybody listening who's not familiar with compact blocks, right
now typically when a new block is propagated, the entire block itself may not
necessarily need to be transmitted, because the idea is your node probably has
most of the new transactions in the block in the mempool already.  So, you can
reconstruct the block on your end without having to be transmitting the full
block.

So presumably, in Utreexo, you'll have the new contents of the block sitting
there in your mempool and you'll have the Utreexo proofs.  Will the existence of
some of those transactions in the new block, but not all of them, interfere with
-- does Utreexo kind of slot in the compact blocks in any way, or are you just
falling direct to that one big blob?

**Calvin Kim**: That's a really good question and that's also something that
we're figuring out at the moment.  At the current implementation that we have,
the currently held blocks are being downloaded.  If you go to the master branch
in the btcd fork that we have, that is how it's being done.  It's not taking
advantage of any sort of transaction proof that you already have in the mempool,
or that you already have cached.

What we are talking about is, when you do the inv and the sort of back and
forth, you would ask for specific merkle branches that you need.  So, as a
Utreexo node, I receive a block and then I scan through it and then I calculate
myself which of the merkle nodes that I actually need and which I already have
so I don't need to download anymore.  And so, I would ask them from my peer and
the peer would give them to me and then I would validate that.

So, there is something like a compact block Utreexo proof.  It's a little
confusing, but yeah, there is something like that in the pipelines and that is
something that we're currently figuring out.  So, we're trying to figure out,
"How would the back and forth look like, what would the inv messages look like,
that sort of thing.

**James O'Beirne**: Cool.

**Mike Schmidt**: Greg Sanders has joined us.  Greg, do you have any questions
or comments about the Utreexo topic?

**Greg Sanders**: I think James asked the one question I was going to ask about
compact blocks, so I think I'm covered.

**Calvin Kim**: I could mention that this would also fit in for transactions as
well at the moment.  So, what you can also do is send the entire proof over for
the transaction, but you may already have them cached in your node.  So, even
for transactions, you could do back and forth, where you only ask for the merkle
branches that you need so you could save on bandwidth with that.

**James O'Beirne**: Calvin, can you remind us roughly how big these proofs tend
to be?

**Calvin Kim**: So the worst case, for 2 MB blocks it's about -- I need to do
it, I need to look at it again.  For about 2 MB blocks, it was about 1.3 MB
proofs and these are sort of smooshed-together proofs, and so it is more compact
than individual proofs added together.  And when you're receiving transactions,
you can't really do that and so it is bigger.  The measured bandwidth that I did
last year was 400%, so for transactions, if you were spending 1 MB downloads,
you would be doing 4 MB downloads.  So, that is the worst case without any sort
of caching, the compact block that we talked about; that's the worst case.

**Mike Schmidt**: So, you'd add a little bit on bandwidth to get this feature.
In terms of privacy, you don't have to connect to a bridge node, you can just
connect to another node that will propagate that information along, right, so
there's not a privacy hit there.

**Calvin Kim**: Yes.

**Mike Schmidt**: And then, I guess there's something about somebody needs to be
running these bridge nodes, I guess would be the only other consideration.

**Calvin Kim**: AJ did have some questions about that.  I assured him that
bridge nodes are not expensive and he wanted me to prove it.  I will prove it
very soon.

**Mike Schmidt**: Are you running a bridge node?

**Calvin Kim**: I am running a group with signet, but with signet it's not that
intensive.

**Greg Sanders**: I tried to get AJ in here.  I sent him a link so, who knows,
he might pop in.

**Mike Schmidt**: He was in the Spaces.  That's a good idea.

**Calvin Kim**: He was very interested!

**Mike Schmidt**: You got lucky, Calvin!  Great.  Moving onto the Releases and
Release Candidates section of the newsletter this week, we have three.

_Core Lightning v23.02.2_

The first one is Core Lightning v23.02.2, which is a maintenance release for
Core Lightning, and it actually reverts a change that happened recently to the
pay RPC that caused a few different services to break compatibility.  I think in
Core Lightning, they've started enforcing requiring a full description and not
just the hash, which broke at least BTCPay Server and LNbits.  So, I think they
reverted that change.

**Mark Erhardt**: It was also deprecated for one year, but nobody reads release
notes and I'm actually a little shocked, because these are people putting out
other software that depends on full node software and they don't read the
release notes of the full node software; that's a little disappointing.  Did I
get that right, Greg?  I mean, you probably heard more about this recently.

**Greg Sanders**: This is the Core Lightning one, right?  Yeah, so the Core
Lightning deprecation is kind of the inverse, in a way, of the Bitcoin Core one.
So remind me.  The details, I am a little shaky on, but Bitcoin Core, things are
deprecated, so if you try to use it, it would default settings; it just yells at
you, right, so you have to flip the flag.

Core Lightning is a little different.  So, the idea is that normal users won't
run into it, but integrators and people building on top should be writing tests
where they turn the flag on, which means any deprecations get hit and it
complains.  So, for a user perspective, they won't get hit with deprecation, but
a packager, or whatever, would; that's the idea.  And apparently, people were
not doing that, so they were running with default configs while building on top
and hitting this deprecation after the fact, when things actually get removed.

**Mark Erhardt**: So, what you're saying is, there's a specific flag that
downstream developers should be using, which essentially makes deprecation cause
an error on your end instead of being silent; whereas, for user land, this would
be just silently deprecated and they were not using this flag, so probably they
weren't aware, or something, and now they are?

**Greg Sanders**: That's my assumption, yes.

**Mark Erhardt**: All right, yeah.  In Bitcoin Core, I think when something gets
deprecated, your node will immediately disallow you using it, unless you
configure your node to say, "Allow deprecated RPCs".

**Greg Sanders**: Yeah.

**Mark Erhardt**: Then, you should also disable that later again, after you fix
your stuff, otherwise you won't notice it next time.

**Greg Sanders**: Yeah, there's pros and cons to both ways.  With the Core
Lightning way, you can upgrade and downgrade cycle without messing with the
config within one release.  Bitcoin Core, you have to sometimes have
simultaneous configs that switch on and off when you do a deployment.

**Mark Erhardt**: Maybe it would be good to have it per RPC that you can disable
the warning.  Anyway, yeah, it broke LNbits and it broke BTCPay Server and maybe
other things and they were very disappointed and outraged.  The funny thing that
I read was, actually Core Lightning was the first implementation that became
spec compliant by doing this and they had given a one-year lead time on it and
now people are complaining that they're following the spec!

**Mike Schmidt**: Well I think there, you mentioned the disappointment in
reading the release notes, but there's also just some of these services that
depend on this should be running the release candidates in testing as well,
right, not just necessarily reading the release notes, but a step further than
that in actually testing the underlying software that they depend on.  So, maybe
this jars to action some of that; we'll see.

**Mark Erhardt**: I mean, sure, a bunch of these projects that have been hit by
this issue have a very small number of staff and/or volunteers and it's probably
hard to do all of this.  But yeah, companies that run into this issue, they
should be testing the release candidate before they install it in production.

_Libsecp256k1 0.3.0_

**Mike Schmidt**: The next release that we covered in the newsletter was
libsecp256k1 0.3.0, which includes a few different additions and changes.  It
breaks its ABI compatibility, because there is an API change.  So, if you're
using libsecp, take note of that, and that's what we noted in the newsletter.
There is an addition here that I thought was worth jumping into if somebody
could enlighten me.  I'm familiar with the autotools build, but they added in
this release experimental support for CMake.  Do any of you want to elaborate on
what is the value in having CMake builds and what are the benefits, and why that
would be something that they would want to add?

**James O'Beirne**: Yeah, I mean, I think the long and the short of it here is
that autotools is just about the most baroque, difficult build system in common
usage these days, and CMake is kind of its slightly more friendly successor that
plays much more nicely with various integrations, and the Bitcoin Core is going
through a similar process, where there's pretty broad consensus that we want to
migrate it off of autotools, because it's such a liability and it's kind of a
pain to work with.  There's a parallel configuration buildout going on for
CMake.

Libsecp is probably a great place to start, because it's a much simpler build
process than Bitcoin Core, and so I think they're just going through the same
process and they're further along.  It's worth noting that doesn't affect any of
the runtime of libsecp, it's really just build tooling for how the shared object
files wind up getting generated.

**Calvin Kim**: I could add that one of the main benefits that, as someone that
looks through this code, has with something like CMake is that it has much
better integration with ID-like tools.  So, if you want jumpto definition or
jumpto references, those are much harder to have with autotools projects, and
you need to have some other tool.  I'm currently using a tool called Bear.  It
generates the style and I have to take this file and translate it against this
file, and then I finally have something that is ID-compatible.

So, at the moment, I actually think VS Code doesn't automatically handle all the
jumpto definition stuff and it doesn't have all the ID stuff, and so sometimes
it errors out.  But something like CMake, if you open up a project, VS Code will
automatically recognize it and be able to give you all this tooling, like the
dev tooling that is very useful to have.

**Mark Erhardt**: Just to clarify earlier, Mike said that it breaks ABI
compatibility, and that stands for Application Binary Interfaces, just if
somebody misheard that as API; it's not the same thing.

**James O'Beirne**: It's roughly analogous though, as far as I understand it.
So, libsecp, when you run this build process that autotools or CMake handles, it
generates this object file that you then instal systemwide or in some part of
the path where a build process like Bitcoin Core can find it, and that object
file is a binary file that offers basically an API into the secp functionality.

**Mark Erhardt**: Okay, then I just revealed how little I know about this!

**James O'Beirne**: No, I mean they're different things, but I guess you could
say an ABI is an API in some sense.

**Mark Erhardt**: Thanks for clarifying.

**Mike Schmidt**: Yeah, thanks for explaining, James and Calvin.

_LND v0.16.0-beta.rc3_

The last release candidate that we had is LND v0.16.0-beta.rc3, and a few weeks
ago we had some folks on from the Core Lighting team to explain the upcoming
release, and I thought that was useful, as opposed to us trying to jump into
each of these release candidates and explain for ourselves.  I think, Murch, if
you agree, maybe this is something that we should bring in some LND folks next
week to explain this release, because I jumped in and it is a major release as
we noted, so it maybe is best to have them explain some of that, although I'm
sure we could, but we did the same for Core Lightning; maybe LND can do it as
well?

**Mark Erhardt**: Yeah, that would be great.

**Mike Schmidt**: Okay, well stay tuned for more information on that.  Is there
anything, Murch, that you wanted to note on this LND release before we bring in
the experts next week?

**Mark Erhardt**: I mean, I do talk about Lightning here occasionally, but
really I'm not much of a Lightning expert!

**Mike Schmidt**: Okay, well look forward to finding some people to join us on
our Not Spaces next week!

_Bitcoin Core #25740_

We had one notable code and documentation change, a notable PR to Bitcoin Core,
which is #25740, and this is around the assumeUTXO project, if you can call it
that, which is a series of pull requests that roll up to a larger effort.
Luckily, that's an effort that James is working on, and so I think it would be
best that James maybe give an overview of assumeUTXO; we haven't jumped into it
too much on the Spaces chats, and then we talk about this particular PR and how
it fits into that project and where the project's at as a whole.

**James O'Beirne**: Yeah, sure.  So, just to give a real quick overview of what
assumeUTXO is, I think everybody knows that IBD takes between a long time and a
very long time to complete, Initial Block Download.  I think what a lot of
people don't realize is that it even takes a pretty long time given the fact
that right now, we by default use a feature of Bitcoin Core called assumevalid,
which is a feature that actually skips signature checks for most of the chain
when you're doing the IBD.

The rationale there is that these blocks are buried so deeply and the signatures
have been checked so many times that in the source code, we feel confident
saying that by default, you don't need to validate these because just getting
the block content and verifying those and then verifying tens of thousands of
blocks on top of those is enough to basically have certainty that you're on a
valid chain.

So, the idea is that we can leverage this even further by simply creating a
serialised snapshot of the UTXO set as a whole, which is really what you're
trying to build up when you do initial block download, and we can, similar to
assumevalid, take a point in the chain some time before releases and say, "The
software recognises that if you load in this UTXO snapshot and it populates the
UTXO set and that UTXO set hashes to this value, then that's recognized as
valid".  And you can actually start to sync from that point and presumably get
to the network tip or get your node operable in a much, much shorter period of
time than having to wait for the full IBD process to complete.

Meanwhile in the background, you have this separate historical chain state doing
the regular initial block download process, and eventually it gets to the point
where you loaded the snapshot in the chain, and then it just compares the
contents of its UTXO set to the one that you loaded in and makes sure that
they're the same.

This has been an ongoing project for about four years now.  We've made a ton of
progress.  I'd estimate it's about 70% to 75% done.  There are some minor-ish
details, like how we deal with pruning and just some fixups we need to do to the
indexing system, but it's all been scoped out, its prototype of it, working
prototype of it, in a different pull request just called assumeUTXO, I can't
remember what the number is, and I've just been carving off changes from that
and slowly getting them merged in.

The most recent change that just got merged was the code for handling the
process where the historical background chain state actually completes and we
handle that checking process, and then the destruction of the old historical
chain state, which you don't need after you've done the validation.

**Mike Schmidt**: I have a question about that.  There was a note that while we
ultimately want to remove this background chain state, we don't do so until the
following initialisation process.  Does that mean restarting the node, or does
that mean something else; can you give me the tl;dr on why that would be?

**James O'Beirne**: Yeah, so there's this data structure in Bitcoin Core, called
the chain state, and that holds a few different pieces of data but basically it
just manages access to a given block chain and its UTXO set.  So, the idea is
that when we're doing the background validation, we have two of these things
running around, where previously in Bitcoin we had one.  But, once you complete
the validation of the snapshot, you no longer need that background historical
one.

So, in concept, you could actually delete that on the fly when you complete that
validation.  But for various implementation reasons, I think it's a little bit
safer to wait and not actually delete that, because you're doing things like
moving things around on the file system; it could be a time-intensive process
and you've got to acquire various locks to do it.  So, doing that kind of
shuffling around in the middle of runtime just struck me as a little bit risky.
It's definitely an optimization we could look at doing, but go ahead, Murch.

**Mark Erhardt**: Sorry, I was just confused.  Which one do you delete?  Do you
delete the snapshot that was loaded in from some package that you jumpstart it
with, or do you delete the one that you built yourself in the background
process?

**James O'Beirne**: You delete the one that you built yourself in the
background, because the idea is while that was building, you're syncing the one
that you created from the snapshot.  And once that historical chain state has
completed, then because we do some data sharing between the two chain states,
the snapshot chain state is equivalent to one that you just sync from scratch.

**Mark Erhardt**: I see, because the one that you jumpstart it with and then
continue to synchronise to the chain tip with is now basically a complete chain
state, and it has all of the information that you built in the historical one
with where in my data structure are the blocks and the transactions and what is
my current UTXO set.  So actually, once you have done the background check and
compared that your jumpstart was correct, you have a full set on the jumpstart
plus synchronised chain tip; and on the background, you only have up to the
jumpstart point, so you remove the second one and now you have a complete state.
I've got you.

**James O'Beirne**: Bingo.

**Mike Schmidt**: Go ahead, Calvin.

**Calvin Kim**: I have sort of two questions.  So, say you jumpstart it from
block 700,000, presumably that would sync to the tip.  If the background catches
up to the tip, do you compare it at that state?

**James O'Beirne**: No, so the background can never catch up to the tip.  The
background only goes as far as the base block of the snapshot.

**Calvin Kim**: Okay.  And the checking is done because you still kept the hash;
do you hash all the background -- the UTXO set that you generated from the
background, you calculate the hash of that and if it matches then you're good;
is that how it works?

**James O'Beirne**: Yes.  So, the hashes are hardcoded in chain params, like in
the source code, so we can always access the hash that we expect from there.
So, when the background chain state gets to the base block of the snapshot, we
then compute the hash of its UTXO set and just verify that it matches the one in
the source code.

**Calvin Kim**: Okay, thanks, got it.

**Mark Erhardt**: And maybe we should clarify again.  So, one of the things with
assumevalid that is often misunderstood, we do the following.  We get the hash
of a block, so basically the identifier of a block, and only if that block
appears in our header chain that we synchronise, we do the signature skipping up
to that point.  If we end up being on a chain that does not include assumevalid
block, we do a full verification instead.  So, the same is true for assumeUTXO.
Only if our header chain even catches up to the block that was hardcoded in our
jumpstart would we be happy, otherwise what happens; does it bork?

**James O'Beirne**: Are you asking if there's a massive reorg after you start
the historical validation process and the snapshot chain state is basically
reorged off?

**Mark Erhardt**: So, if you get a bad jumpstart and the block that it says that
it has is actually not part of the best chain.

**James O'Beirne**: Oh yeah, I see, okay.  So, we actually don't allow people to
specify valid assumeUTXO hashes through the command line, it's only in the
source code.  So, in order for that to happen, someone would have to have
modified the source code that built your binary, in which case you're cooked
anyway.  So, if there's a bad UTXO on a snapshot that you attempt to load, the
hash isn't going to match.

**Mark Erhardt**: Okay, so basically the assumption is because this is part of
the source code that you download, and you verify that the source code comes
from a trusted source and has been reproduced by other people, this is not a
scenario that you need to handle.

**James O'Beirne**: Right, because if your binary is modified in any way, then
you have to assume that someone could have modified the code that handles UTXO
set access and they could slip in a conditional that says, "Allow [whoever] to
spend thousands of Bitcoin", or whatever.

**Calvin Kim**: So, is the current behaviour just crash if it doesn't match?

**James O'Beirne**: There's actually a lot of logic around alerting the user
that there wasn't a match and shutting down.  So, it's not quite a crash, but
it's definitely a hard shutdown.

**Mark Erhardt**: Okay, so it does the header chain check anyway and it reaches
the point with the assumeUTXO very quickly, because processing the header chain
is fast.  And if that does not match, then you're in trouble and the node tells
you you've got a bad client or something.  Well, that sounds safe enough to me.

**Mike Schmidt**: James, is the assumevalid block the same block that's being
used for assumeUTXO?

**James O'Beirne**: It could be, it doesn't necessarily have to.

**Mike Schmidt**: It doesn't have to be?  Okay.

**James O'Beirne**: Yeah, so we haven't discussed that.  I mean, I think that
makes logical sense from a release standpoint, but it certainly doesn't have to
be.

**Mike Schmidt**: Yeah, because that's part of the release process that
assumevalid is already part of the steps that people go through to generate a
release, so I guess there might be advantages to having it be the same one.

**James O'Beirne**: Yeah.

**Mike Schmidt**: On that note, and what you're talking about binaries being
modified, etc, it does seem like it would be interesting if I was doing IBD and
I had a new node, and I saw that the assumeUTXO was quite far in the past
because there hadn't been a release, or something like that, I could see that
creating demand for non-authoritative sources of downloading binaries, because I
could save a bunch of bandwidth and time and be up to speed because someone put
an assumeUTXO from a week ago binary out; do you see?  I mean, that could
happen.  Whether or not it will, I mean obviously you'd need to change the code
and then someone needs to validate, but it does start drifting away then from
more authoritative binaries if there is demand for that.

**James O'Beirne**: Well, what's scary is there's that incentive today, and in
fact people, like I think for what BTCPay Server, some Nicolas Dorier project,
was providing GPG-signed datadirs where people could just download the datadir and
load that in and have a synced chain under full trust of Nicolas, or whoever's
maintaining it.  So, I think that kind of perverse incentive exists today and
maybe I guess you could argue assumeUTXO makes that even more appealing because
-- well, no, probably downloading a few hundred gigabytes is roughly on par with
syncing; I don't know.  I think that problem exists today.  People just have to
know not to download software from unauthoritative sources based on claims of
fortune and grandeur.

**Mark Erhardt**: To be fair, I think Nicolas is probably a better source than
many other sources people have been happy to download full nodes from.  But in
the context of people using BTCPay Server for their businesses, they should
really know better and sync their own node if they intend to manage a lot of
money with that node.

But yeah, I just wanted to point out a little earlier, jumping back here, that
even if assumevalid blocks and assumeUTXO blocks are the same one, the
difference would still be that you can set a manual assumevalid height, right.
If you want to speed up your sync and are happy to reduce your security in doing
so, you might set assumevalid to a week ago and only validate signatures on the
last week, so you're trusting essentially the network that they have been
building on a valid chain; and a week's worth of work is sufficient for
yourself on signatures.  If that's your choice, you could do that.  You can't do
that with assumeUTXO.

**Mike Schmidt**: That makes sense.

**Calvin Kim**: I just want to mention, Nicolas was doing that with BTCPay
Server, and one of the guys from the Specter team also has one.  It's
prunednode.today, they're like, "Download my datadir and you could have a pruned
node now"!  So, people are already doing that.

**James O'Beirne**: Yeah, I just think that's really scary.  Even if you trust
these guys individually, if their keys get compromised and they don't know it
and somebody uploads a bad datadir to their server, it could just be sitting
there, and it's a bad thing to do, I think.

**Mark Erhardt**: And it's not completely unheard of that someone that maintains
software's key gets compromised.

**James O'Beirne**: Absolutely.  Greg's shaking his head, "No, that never
happens"!

**Greg Sanders**: Never happen!

**Mark Erhardt**: They must have made that up some time in the last three
months.

**Mike Schmidt**: James, you mentioned 75% assumeUTXO progress.  I think it's
hard for folks, they see these ideas, they see things like Utreexo, they see
assumeUTXO and it's hard for people to understand is this going to happen, is
this going to be a thing.  The good news is, you guys are both here to address
those exact questions for those projects, and it does seem like assumeUTXO has
traction in the Bitcoin community and the Bitcoin developer community.  Is it
getting the review it needs; is this a thing that's going to happen?

**James O'Beirne**: Yeah, I think it is and there's been a big uptick in review
in the last few months, I want to say.  I think right now, I'm the bottleneck
with the OP_VAULT stuff.  I've been a little negligent about updating the very
latest assumeUTXO PR, which deals with the net processing side of things, like
the networking changes.  So that works, but there is some outstanding feedback
that I could probably address.

So, yeah, I think there's a lot of will to make this happen, and I think I'm
going to play somewhat of a game of brinksmanship because I'm frankly tired of
working on this project, and I think I'm going to propose that one last
monolithic PR, that maybe just enables the full assumeUTXO functionality for
regtest and testnet environments, gets merged so that we can basically just do
one big push and get this thing in there, because I tried to be really diligent
about breaking things up into small PRs, but I'm very cynical now and jaded
about that approach, just in terms of the amount of time it's cost.  So, I'm
hopeful, but definitely tired and weary and very thankful for everybody who's
been involved consistently in doing reviews.

**Mike Schmidt**: Excellent, well thanks for seeing it alone, James.

**Mark Erhardt**: Yeah, thank you.  Hearing how these things that, for example,
make it much, much easier to quickly bootstrap a full node and get up and
running with your project on the network have been in the works, I'm now talking
about both Utreexo and assumeUTXO, for four years and then I see prominent
members of the Bitcoin community propagate the position that Bitcoin Core devs
are an attack on Bitcoin, because the protocol is finished, there's nothing to
do anymore.  I just want to point out that if you think, for example, that it
should be easier to run a full node and more quickly be at the chain tip and
have a working project, then these two things maybe are in contrast.

**James O'Beirne**: Yeah.

**Mike Schmidt**: I mean, I'd love to have a conversation about that that's
probably not Optech-friendly, at some point.  James, Calvin, Greg, thanks for
joining us.  Greg, is there anything that you wanted to comment on?  It's cool
that you joined us.

**Greg Sanders**: No, just loving hearing about the two UTXO proofy projects and
stuff.

**Mike Schmidt**: All right, and thanks to my co-host, Murch, and I thank
everybody for listening on the podcasts, and likely we'll be doing this again in
Google Hangouts, because this is actually quite a bit smoother.

{% include references.md %}
