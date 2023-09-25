---
title: 'Bitcoin Optech Newsletter #268 Recap Podcast'
permalink: /en/podcast/2023/09/14/
reference: /en/newsletters/2023/09/13/
name: 2023-09-14-recap
slug: 2023-09-14-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Olaoluwa Osuntokun, Greg Sanders, and Pieter Wuille to
discuss [Newsletter #268]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-14/985bd89b-5b22-ccac-3dce-0511b2b80c4e.MP3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #268 Recap on
Twitter Spaces.  It's Thursday September 14, and today we're going to be talking
about taproot assets with roasbeef, Point Time Locked Contracts (PTLCs) and
Lightning with Greg Sanders and BIP324 encrypted transport with Pieter Wuille.
Introductions and then we'll jump into it.  Mike Schmidt, contributor at Optech
and executive director at Brink, where we fund Bitcoin open-source developers.
Murch?

**Mark Erhardt**: Hey, I'm Murch.  I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Roasbeef?

**Olaoluwa Osuntokun**: Oh, sorry, I missed the cue.  Hey, my name is Laolu, or
roasbeef.  I'm CTO of Lightning Labs, and I work on Bitcoin stuff, LND, BTCD,
other open-source projects like that.

**Mike Schmidt**: Greg?

**Greg Sanders**: I'm Greg, or instagibbs.  I'm at Spiral as a Bitcoin wizard,
and I do a variety of things, but some is mempool policy, and then also
ancillary stuff for Lightning.

_Specifications for taproot assets_

**Mike Schmidt**: Thank you both for joining us.  We're going to go through the
newsletter.  We'll start sequentially, and the first item from the newsletter is
specifications for taproot assets.  Roasbeef, in April of 2022, you posted a set
of draft BIPs to the mailing list specifying at the time the Taro protocol.
This is Newsletter #195 for listeners who want to follow along with that
reference.  And the protocol, "Allowed for issuing assets on the Bitcoin
blockchain that can be transferred over the Lightning Network".  And then last
week you posted to the mailing list, "After more than a year of tinkering,
iterating, simplifying, and implementing, I'm excited to officially publish and
request BIP numbers for Taproot Assets Protocol".  So maybe to start, what is
the Taproot Assets Protocol and what use cases do you see for the technology?

**Olaoluwa Osuntokun**: Cool, great, thanks for the intro.  Yeah, so we started
with the spec or so, maybe I guess a bit over a year ago, and then as people
know, once you have a spec, it's not really a thing until you have code, and in
my opinion, it's not really even a thing until you really have test vectors on
top of that as well, because we obviously want to get additional interop for
other individuals working on this stuff.  But a simple take on it, it's
basically like an observation around, we sort of have the structured commitment
for it basically, with the way the tapscript tree works.  So, if you would know,
taproot, basically you have this tree of these scripts basically, and the
scripts then have a particular root, use that root to generate another public
key.  And the cool thing about the way taproot works, you can basically have
either a signature for just that public key itself, or you can reveal one of the
script paths and then actually have that script path be used to unlock some
coins, right?  This is cool because, for example, you could do something like
unroll multisig and run different combinations.

So, we had the initial insight that led to the creation of the protocol, now we
have a less fun name than we had before, was that the elements in the script
tree don't actually need to be script, they can basically be anything.  So then
it was, okay, how can we leverage the structured commitment space to basically
create a protocol where people can then do additional things on top of Bitcoin,
like issue other assets?  For example, I think the other day or the last time
when we did initially, I did a collectible for the Git tag of some RC release in
the past itself.  That's kind of the broad view of it.

But in terms of going a little bit further, the way it works is basically like a
tree of trees.  Initially, you have the top level of Bitcoin script tree, which
is basically the tapscript tree; we have a special commitment there.  There's
actually a bit of a challenge doing this, especially because, as a lot of people
know, but the taproot script tree, it's actually sorted before you actually
create the merkle tree itself, which means you can't really guarantee ordering,
and every single time you go up a level, you basically have lost ordering
information.  And the reason why this is important, as we'll get into a little
bit later, is that you need to basically ensure that you have a unique
commitment in a given output, because otherwise, someone can basically just sort
of duplicate stuff, right?  And obviously, this is Bitcoin, you've got to run
the numbers, you've got to make sure that something like that isn't actually
possible, right?

So what we do, we do a thing where we basically have a series of sort of
inclusion and exclusion proofs, and you can basically view the entire protocol
as a series of inclusion and exclusion proofs.  And as I'll get into later, we
can use things like STARKs to actually express that down much further.  And the
first inclusion proof is basically that the commitment is either at the left or
the rightmost child in that top level tree, basically.  And the way we do this
is that we then force you to basically reveal, in the three different cases, but
one of the cases we basically force you to reveal the sibling preimage
basically, then we can verify if that's a branch or if that's another leaf.  And
then the way the commitment works, it basically has a special magic byte prefix,
so basically you delegate that.

Then, just summarizing the way the basic merkle works itself, is that it's very,
very Bitcoin-like, at least that's how I tried to make it Bitcoin-like, because
otherwise I think it's very easy to get caught up in just the very, very large
design space to make something that's unruly or maybe would never actually be
finished or ever actually be shipped.  And it uses a new data structure, a new,
what's called a Merkle-Sum Sparse Merkle Tree (SMT).  And what this is, people
probably know merkle-sum trees have been discussed and people have talked about
this in the past.  A merkle-sum tree is basically a regular merkle tree, but you
actually have, whenever you're combining branches, you also actually sum a
value, right?

So, let's say I was committing to a bunch of ones, maybe the roots of them would
actually be five, right?  That's not really useful in this case because that
lets you do things like approve the number of assets or some unit that you have
in a commitment, right?  And then the sparse merkle part comes in because,
earlier I mentioned that there's basically a series of inclusion and exclusion
proofs.  Sparse Merkle trees are like merkle trees, but they have very, very
efficient proofs of exclusion.  So, typically for a merkle tree, in order to do
a proof of exclusion, you would have to sort all of the leaves and then
basically show me that at a point of which something should exist, this actually
isn't there because it's sorted.  That works, but the issue with that is that
you basically have to continuously update the tree and it's not really
order-independent.

So, the nice thing about the SMT is that you have a very efficient proof of
non-inclusion because the proof of non-inclusion is basically that at this key,
there is an empty hash.  And the way sparse merkle trees work is basically, it's
like a realization, in that you can basically simulate a very, very large merkle
tree, because you know what an empty hash is basically, and at each level, you
know what the empty hash looks like.  So therefore, in this case, improving
non-inclusion basically means proving that something is in the tree that
shouldn't actually be there.  And probably, I think the other bit to point out
before we go into a little more is one of the challenges of developing like a
global asset ID, right?  Because on other chains, you basically have that built
into the protocol.  It's like something where there's a nonce, where you
basically do some hashing.  Obviously in Bitcoin, we don't necessarily have
that.  But we do have that globally unique or basically UTXOs, and also txids.

So the way this works, it basically relies on BIP34, which ended up sort of
committing to the block height in that correlation section, which actually fixed
a bug to ensure that outputs are always unique.  It uses that in order to derive
an asset ID based on the position all the way down into the tapscript commitment
itself.  And that's a very, very high level of the way it works.  I mentioned
also that it's very Bitcoin-friendly, because the way it works actually right
now is that rather than create an entirely new VM and get caught up in RISC-V
and all this other stuff, we just use the taproot VM again.

So, what this means is that whenever someone's sending an asset onchain, the
value that they send someone else, basically the pubkey, is actually just a
taproot output key itself.  So, you can then use that to basically send onchain
with the address from it that we'll get into a little bit later, and the initial
version basically gives you everything that taproot does.  So, you can do
multisig, you can do MuSig stuff, you can do any other script stuff.  And this
is also very critical to the way that it works on Lightning channels, which
we'll get to a little bit later as well.  But that's kind of an overview of the
entire system.

Then, as far as additional use cases, it's basically anything that people want
to do as far as issuing assets on Bitcoin.  And this only has been done for a
while.  People have done Counterparty,  Mastercoin, things like that.  This has
maybe come back a little bit more in the past year or so, but using a very, very
inefficient manner.  And I think people are even trying to get points by doing
the most inefficient thing as far as multisig and stuff like that itself.  But
this is different because actually, there's no additional overhead from the
chain perspective.  The overhead basically comes when it's actually offchain,
meaning that these transactions look like normal bitcoin transactions because
they're just all pure taproot transactions themselves.

Then, as far as what you can do, you can issue other types of assets.
Basically, there's two types.  One is a collectible, which is basically
something that is deemed to be indivisible or unique.  This can be Pokémon
cards.  For example, I've been starting to tag, make collectibles for my Git
tags for LND itself, which is cool because I can actually do a thing where I can
basically create a group of collectibles, and each of those collectibles is
always an individual Git tag, and you can then use that to actually verify the
signatures and things like that as well.

Then it also lets you issue normal assets and at least our interests on that
side, is basically allowing people to use other things, like stable coins at the
edges of Lightning.  And once again, this doesn't require you to actually modify
Lightning itself, because it's actually fully at the edges.  So assuming this
goes right, people don't need to update at all on the Lightning side, but they
actually see increased reduction of volume because people are able to do this up
at the edges.  And I think the main thing for me here is, I think it's
interesting because this gives people a sort of more gradual on-ramp onto
Bitcoin itself.  Eventually their wallet will basically be able to just move
back and forth between whatever local currency they have and Bitcoin itself.
This, I think, kind of makes the on- and off-ramps a little bit less steep
basically.  Because if you're already in this domain, then you can say, "Maybe
I'm 20/80 Bitcoin, maybe I'm 30/70", because not everyone goes from zero to
Bitcoin.  Maybe some people have in the past because they discovered it and it
changed their life.  But this is basically giving people a bit more of that
gradual on-ramp.

But that's hopefully an overview of how to understand the motivation, how it
works at a high level, and then also ways to make the functionality work.

**Mike Schmidt**: That's great.  Our transcriptionist is going to love this!
Okay, so you mentioned a couple of different use cases, like the NFT single
asset, unique asset use case, as well as being able to issue more than one
asset, like in the case of a stablecoin or something like that.  And you also
went through some of the mechanics and how taproot is used to facilitate this
protocol.  Maybe talk a little bit about -- okay, so it sounds like this can all
be done just in taproot and using bitcoin transactions, and I don't -- or
Vanilla bitcoin transactions, I guess, and bitcoin transactions that have this
protocol within it, but there's also this Lightning aspect and then that ties
into the simple taproot channels that I think LND has the RC for that we can get
to later.  But maybe talk a little bit about why that's a prerequisite, and
exactly how Lightning comes into play here.  Could we just use this without
Lightning?  Lightning just obviously has the advantages that we're aware of with
Bitcoin, or is Lightning required for any of this?

**Olaoluwa Osuntokun**: Really good question.  So, it is possible to use it
without Lightning itself, right?  And you can see the benefits that you have is
that you basically have sort of onchain batching.  For example, in one
transaction, because we're using basically these layers of merkle trees itself,
I can issue, let's say, I wanted to have a conference and everyone wanted some
sort of badge of attendance, or something like that.  I could basically issue
all those in one transaction onchain.  There's 10,000 and everything's fine.  So
this is where the efficiency comes in, because merkle is much more efficient
than other things that purposefully like to dump data onchain, for example.
Those would basically take 10,000 inputs and outputs, just do something like
that itself, which isn't very efficient at all.

One other thing that I think is important, for the protocol as well, is that
it's actually fully light-client-friendly.  Some of the other stuff that's been,
I guess, even since the dawn of time, things like Counterparty, the way they
work, you actually have to scan every single block in the Bitcoin chain to
basically update, you know, what is your state.  So it's sort of like using the
Bitcoin chain as just publishing space basically because they're publishing a
transaction, and then you're actually updating your state with that in concert.
That's very inefficient because you actually require a full node.  Maybe that's
good if you're running full nodes, but I think in order for this stuff to be
more usable, basically you need to support light clients.  And that's where one
of the BIPs around the proof format comes in.

The proof format is basically like, what do you need to give me to verify an
asset, right?  You basically need to run the numbers.  Say, in the Bitcoin
chain, you basically have a UTXO set.  If you give me a UTXO output, I can look
it up in that thing, that's fine.  Maybe in the future we'll have like a merkle
tree output, but today we don't.  So that's like the equivalent there that I can
always use a light client, like a Neutrino, because all you have is basically a
proof.  Let's say I had some new asset, basically it would be a block header, a
merkle proof inside that block header and then a series of inclusion and
exclusion proofs from the taproot output level downwards.

Then you also asked about the overlap with Lightning.  And so, where I think
this gets interesting with Lightning is basically the ability to move this stuff
offchain with very, very low fees and also have all the benefits of Lightning
itself.  And I think one other thing that I think this can do is, I think this
can also create a new input transaction source for Lightning itself.  As I
mentioned, in terms of the overlap of taproot channels and taproot assets to
Lightning itself, this would basically happen all at the edges.  As I mentioned
a little bit earlier, everything is basically based on P2TR.  For example, let's
say there's a transaction, one of the transaction outputs is maybe a witness key
hash.  We don't need to do anything in the protocol because we know in the
protocol that thing can't actually hold an asset, so we don't actually need to
include an inclusion proof for that thing itself.  So, it simplified the
protocol a little bit by just saying everything is fully in taproot and also the
wallet, that's integrated into the statement, is also all taproot as well, which
makes things pretty nice.

But as far as the overlap between taproot channels and then this as well, as I
mentioned, you basically need to actually have this using taproot, and this lets
you just send things offchain, which is pretty nice, right?  And rather than
actually force the entire network to be upgraded, and you have all these prices,
and there's all these updates, and things are upgrading very, very quickly, so
again, let's just simplify this and let's just have things at the edges; number
one, because Lightning took a while to bootstrap.  Initially, there wasn't that
many people on there.  I remember there was this graph of Justin Camarena from
Bitrefill of our three nodes on mainnet several years ago.

Up until now, now we have nearly 5,000 BTC, and that's not trivial to bootstrap,
so it didn't really make sense to make an entirely new network.  Instead, you're
able to leverage the existing culture of the Bitcoin backbone network of the
Lightning Network for these taproot asset channels, right?  And the advantage of
this basically is envisaging bitcoin as like the root currency, you can say,
right, everything is going to cross through the Bitcoin backbone of the network
itself before assuming something else on the other side.  And this is really
interesting, because now, this also adds another flywheel to Lightning itself.
In order to basically do more transactions at the edges, you need more capacity.
And as you add more capacity and more transaction volume, them to make more
money, this also gives them additional, you know, sources of revenue and income
they can do in terms of putting up their BTC on the work itself.

So, that's why we ended up requiring, or positioning the progression to also do
taproot channels.  First, obviously, taproot channels has a bunch of benefits,
and I think instagibbs is going to talk about a bunch of things around PTLCs and
things like that.  So, it's basically your first prerequisite step.  Because the
way it works is that from the point of view of you can say any external
protocol, let's say something like taproot channels, for example, now you're
actually going to have a MuSig2 output, which is a single key in the funding
output in this.  That's because you basically have a single signature of keys,
and it's super-cheap, and it looks like everything else as well.  But now in
this case, we say, okay, well, because it's a taproot asset, all it is is
basically an extra tapscript commitment.  You put this commitment in any
relevant area, basically.  We can talk about what exactly the commitment looks
like, and how the scripts look basically.  That's basically the overhead from
the point of view of the Lightning protocol itself.

So, if you have a statement, you say, "Hey, put this commitment into this tree
and don't worry about it", that's the minimal thing you need to do there.  I
think the interesting thing with the way we've tried to set up the actual
protocol is that it actually requires very minimal changes.  For example, let's
say I had some hypothetical thing, beefbucks, and Murch wants to pay me over his
Lightning channel.  He doesn't necessarily need to know what I'm even accepting,
nor even anything about the exchange rates.  The thing is because the invoice
itself will actually always just display bitcoin.  This is one of the cool parts
as well, because now this means that people can use it without upgrading at all.

One thing I always think about when I'm thinking about new systems or products
or systems or things like that is basically the distribution model.  How are
people going to update this thing?  If everyone has to update all at once, this
thing is never going to work because updates are slow.  As we've seen, we had
some big news the other day with Coinbase finally announcing their Lightning
integration, but that took several years, and definitely shoutout to a lot of
people in Lightning Labs who have been working with them over time to get that
achievement, and also Victor from their team as well.  But the cool thing about
this is that once you have that invoice, it basically looks like any other
invoice.

So, what happens is that at the edges, you basically have that sort of swap or
cross at the edge of the channel itself, where you're doing something internal
to the network, and there's something called an RFQ, or a Request For Quote
system, that happens basically between the receiver and that hop, or they're the
one sending their hop basically, to allow you to basically negotiate the rate
and then lock that, and then send funds along that as well.  It actually uses
something that we created a while back in Lightning, called the Short Channel
IDentifier (SCID) alias, which was used for light clients basically, to allow
you to obfuscate where that channel was onchain.

The big thing for that, at that point, the SCID, which is basically this short
integer basically that describes the location into the chain, basically impacts
the block height transaction index, of the taproot transaction output itself,
that doesn't actually need to be a real channel.  So what we do, we say, okay,
"Hey, I'm going to negotiate an invoice, basically.  Whenever I make the
invoice, I'm putting this special SCID in there, and that means that you should
send on this channel at this particular price", let's say it's 60k Bitcoin or
something like that, for a dollar, and that's how you actually lock things in.
So it's really cool, because we're able to leverage something that was already
in the protocol for privacy enhancement, for an unadvertised channel, basically.
So it's sort of like buying the invoice from that within things today.

So, it's really cool because, let's say we update in the future sometime, let's
say we're out here next year, I give you an invoice.  That invoice is going to
say bitcoin, but I could be receiving anything else on the side, which I think
is a pretty cool aspect.

**Mike Schmidt**: You mentioned one of the BIPs, the sparse merkle Tree.  There
are seven that you've proposed, and then you've also touched on the fact that
you're using Bitcoin you're using Lightning plumbing if you will, but there's
obviously some client-side data that needs to be transmitted, and I think you
talked about this proof file, but I don't think you used the word "universe"
yet.  Maybe talk about what universes are.  Is this essentially the data store
of the history that's required in order for a client to validate that they're
actually receiving one of these assets?

**Olaoluwa Osuntokun**: Yeah, really, really good question, right?  So you can
say today, Bitcoin is basically defined by the Genesis block, right?  If I give
you a header and I'm saying, "Okay, this is Bitcoin", number one, I'm going to
make sure it connects back to Genesis block, I have to worry about power and
validity and things like that as well, but you can basically say Bitcoin was
born at that Genesis block, right?  For something like the assets in the system,
we have something called a genesis output, or out point, and this is basically
where some sort of asset was basically created for the very first time.  As I
mentioned a little bit earlier, we use a very, very early soft fork that
guaranteed, you can say, uniqueness of out points in order to make sure that we
can actually generate a unique asset ID.

So, we basically take the first out point and the hash line of information,
we're basically able to have that itself.  And so where universes come in, the
question is like, "Okay, well, how do I bootstrap this for the first time?  It's
like a cross between like a Git server and a GPG, you know, key server as well
basically.  You can say this is like the equivalent of a Git clone or like an
ultra-trust, or whatever it is in GPG whenever you assign someone else's key.
So this is used for a few things.  Number one, it's basically used for asset
bootstrapping.  And one other quality of the SMT tree that is useful here is
actually, it has history independence, which means that if I insert three keys,
no matter which order I insert them in, I'm going to have that exact same root.

This is useful because now I can compare with you, and I can say, "Do we have
the exact same collectible LND Git tags, basically?  We can compare the root
hash and then say everything is fine.  But the universe itself is actually
another SMT, MS SMT, but with a slightly different structure.  So the earlier
one, basically you have two levels.  One level was the asset ID, and then you
basically get down to the script key, which is the equivalent of an output key
or a PK script or scriptPubKey in Bitcoin.  But the universe is slightly
different in that the top-level field is actually like an out point.  So what
this does, it basically lets you look up indexed information into the chain.
It's an authenticated data structure that lets you look up an output and then
see if there's any information related to that asset ID, or whatever else in
that output itself.  And the universe, you know, the leaves of the universe
itself are actually what I mentioned in that proof file format.  It's basically
like a single transition.

So let's say you wanted to verify that I had the initial the rare LND 1.0 Git
tag, or something like that.  You would basically exchange this root hash, we
see that doesn't match, you would then get an inclusion proof, basically, from
that root.  And one of the things, well, eventually, this would be committed
onchain, right?  So, for example, jumping ahead a little bit, it's also possible
in the system to sort of issue an asset in a way that you can issue other assets
that are sort of aggregated on top of that, right?  So you basically call it an
asset group, and there's something called an asset group key, and that has an
asset group witness, you can say, right?  And once again, the group key is
actually just another instance of a taproot app with public key.

This means that, for example, let's say I was working with developers in the
company and we wanted to make sure that I could unilaterally do this, for
example, similar to LND, we have a bunch of signatures for all the release
types.  I can actually have that group key be a MuSig output, basically, and
then ensure that we have a threshold signature into that itself; or I can even
reveal a script path into that group key, and then this basically lets me
authorize future issuance of an asset based on knowledge of this particular
witness.

But now getting back into universe stuff, this is basically used for
bootstrapping.  So, if people look at the BIP itself, there's some structures,
some APIs as well.  The very first thing you'll do is bootstrap with some
universe, and this basically, as you're downloading all the proofs, basically
you run the numbers.  And I mentioned a little bit earlier that Bitcoin's
genesis block basically defines what Bitcoin is in a sense.  In this case,
you're bootstrapping to basically get that genesis out point, which is what
actually created the asset in the first place.  So once you have that, now
you're like, okay, well, this is actually what beefbucks is.  Beefbucks is
defined by….  Because one of the important things, there is no uniqueness of
names, because we don't have any global namespace; all we have are hashes.  So
you basically actually use the name to drive the hash itself, and then once you
have that, that's how things work from there on.

You can say a universe is also similar to a block explorer, something like
mempool.space or maybe blockstream.info itself, in that you can use this,
because remember the top-level key is actually an out point, you can use this to
basically look up data on the chain itself to see what it looks like.  For
example, on many blocks where you can click the details thing, it shows you all
the witness script and things like that as well.  This is similar, but for these
assets as well.  An important thing around the order of independence is that we
can always make sure that we have the exact same value.  This is basically the
"remnant numbers".

Let's say we're auditing supply of some particular thing.  And one of the cool
things about the way this works is that there is an option to restrict the way
you can issue assets to have a linear commitment onchain.  What this means is
that I can watch a single output on chain, basically.  And then from there on,
if that thing is spent, I know an asset was issued because the protocol requires
you to have the assets emanate for that particular output.  So, this is
basically the run of numbers.  Everyone's light client can be watching a
particular output on chain, and when that gets spent, they know, "Oh, something
else happened.  Let me go and get that offchain data".  And so the universe tree
basically lets you organize and index and bootstrap that offchain data, and
there's a few different levels.

One is just the issuance, basically.  And you need the issuance proof in order
to actually verify an asset's provenance, because every asset that you can say
is beefbucks or something else must actually emanate from that thing that's
basically the Genesis block itself.  But then you can also use this to store
normal transactional data and also transmit proofs and things like that as well.
So, it's sort of like a cross between a block explorer, a Git server, you're
doing a Git clone, but then also bootstrapping, you can take "trust" or just
verification for these assets.  And the cool thing, like I mentioned a little
bit earlier, is that the tree actually has a root, you know, some commitment.
So if these values match those, we basically say, "Okay, we know everything
that's going on here.”  I think people are working on, like doing things like
making explorers and other stuff on top of this as well.  That's kind of like
what it is at a high level.

I guess the other thing as well is, anyone will be able to run this, similar to
how people can run Electrs or mempool.space; anyone could run one of these
things.  Now imagine, for example, companies like block explorers are also
running this themselves.  And also, if you're a major player in this ecosystem,
you're going to be running one as well.  One other nice thing about the tree
format, it also enables very easy reconciliation.  Because as I mentioned, let's
say we go to compare and we're tracking all of the out points that we think are
beefbucks  in the chain.  If the root hashes actually don't match up, we say,
okay, let's go to the left side of the tree and the right side of the tree.  You
can basically easily bisect down the tree to find out the divergence point.
Maybe I just send you an entire subtree or branch versus sending everything all
at once.  That's another cool thing about the way the tree structure works.

**Mike Schmidt**: Instagibbs, I don't know if you've looked into taproot assets
at all or if you have any interesting comments or questions.

**Greg Sanders**: I don't have any interesting to say, no.  This thing's covered
way more than I know.

**Mike Schmidt**: Roasbeef, maybe one more question for you.

**Olaoluwa Osuntokun**: Sure.

**Mike Schmidt**: We had Maxim from the RGB project on in Newsletter #247 and
podcast #247 talking about RGBs protocol maybe at the highest level possible.
Could you contrast RGBs protocol against taproot assets?

**Olaoluwa Osuntokun**: Yeah, good question.  I think one of my goals was, you
know, there's kind of a lot of text in the BIPs, but it's basically to make it
as simple and understandable as possible, and also not necessarily try to
reinvent the wheel, right?  For example, we already had tapscript, that's a
commitment format, I can reuse that.  We already have the taproot VM, that's
something that is flexible, and also is going to add additional types out in the
future, I can reuse that, right?  So it basically tries to sort of make things
as explicit and simple as possible.  For example, the proof format.  I can even
send the proof format itself, and with that, you can basically write some code
to verify an asset just there, because we're trying to make sure this thing's
also adopted within the ecosystem itself.

So, I guess that's what I would say at the highest level, is that taproot assets
tries to be as simple and as explicit as possible and basically reuse everything
we already have.  I think some of the other stuff, like maybe something like
RGB, it has a lot of other custom things it makes.  For example, to my
knowledge, it has a custom VM, it has this language, it has extensions for P2P
file share, all this other stuff as well, which seems cool.  But for me, it just
seemed to be just extra stuff that maybe wasn't necessarily needed, something
that could be added after the fact.  And I think one other thing we tried to do
with taproot assets, we tried to make sure we're moving forward with the spec in
concert with the code as well, in that we've been working on the spec; in the
past year or so, it was actually mainly the code itself.  The spec had, I think,
a bunch of clarification because it's always once you get down to that if
statement, you realize maybe something wasn't fully specified or something like
that.  So, we're basically making sure that things are as simple as possible.
It's basically very much aligned with Bitcoin.

The other interesting thing, as far as that, for example, we have this thing
that's called a virtual PSBT (vPSBT), which is basically the same as a normal
PSBT.  And because everything is just Bitcoin, for example, any wallet that can
do things like make a taproot script, that can sign schnorr signatures, that can
do MuSig2, whatever else, can also do all those things in this ecosystem, right?
Because at the very lowest level, what you're signing is actually a bitcoin
transaction, right?  We basically compile this sort of more conceptual
information, these like type-length-value (TLV) leaves basically, into a bitcoin
transaction, that's one input, one output, and that's what you sign and verify.

So, once again, something like, let's take a Coldcard, can actually adopt this
protocol because they already know how to sign and verify bitcoin transactions.
So that's, I think, the biggest thing with that one.  Obviously, that product
has been operating for many years, but we were trying to make sure things were a
lot more focused and succinct versus trying to get caught up in designing VM and
all this other stuff as well.

**Mike Schmidt**: Roasbeef, thanks for jumping on.  This week, we also created a
client-side validation topic on the Optech Topics page, that can serve as an
overview of this technique for listeners that are curious to read more.
Roasbeef, you're welcome to stay on.  We do talk about the rc2 LND release
later, and we'll talk about PTLCs in a bit.  But if you need to drop, we
understand as well.

**Olaoluwa Osuntokun**: Cool, no problem.  I'll hang around.  I'm definitely
interested in hearing about more PTLC stuff.

**Mike Schmidt**: Well, we may have to wait on PTLCs, Greg.  I hope you can hang
on.  Unfortunately, we only have Pieter for the next 29 minutes, so I thought we
would maybe jump a little bit out of order.

**Greg Sanders**: I think he's earned it.  I'll let him usurp!

**Mike Schmidt**: Okay.

**Pieter Wuille**: Great timing!

_Bitcoin Core PR Review Club_

_BIP324_

So we have a monthly segment in the newsletter, Bitcoin Core PR Review Club, and
this month we covered Bitcoin Core PR #28165, titled Transport Abstraction,
which is part of a PR that is related to the BIP324 project that allows for
encrypted P2P communication between Bitcoin nodes.  Luckily, we do have the PR's
author here, Pieter, sipa, to explain it.

**Pieter Wuille**: Hi, Mike.

**Mike Schmidt**: Hi, Pieter.  I know that the PR notes specifically, "Nothing
in this PR is BIP324-specific, and it contains a number of independently useful
improvements", but regardless of nothing specific to the 324, I think it's
probably advantageous to plug a quick overview of BIP324 and what the goals of
that project are for the listeners, and then maybe also introduce yourself
briefly first for folks who don't know who you are.

**Pieter Wuille**: Okay, So I'm Pieter, I've been working on Bitcoin for a
while.  Thanks for having me here, it's a really interesting project that we're
talking about.  So yeah, the transport abstraction PR is a preparation in
preparing for the BIP324 code.  BIP324, it's always probably the most
interesting to start talking about it.  It is a proposal for introducing a new
transport layer protocol between Bitcoin nodes.  It's been a long-running
project that has had many contributors over time, starting with Jonas Schnelli,
I think in 2017 or something, and later picked up by Dhruv Mehta and Tim Ruffing
and I.  And we're getting really close to the, I think, finish line for the
first milestone, namely having it enabled in Bitcoin Core.

What this new transport protocol features is opportunistic encryption.  That
means whenever two nodes both support a protocol, they'll negotiate an
encryption key and encrypt all the traffic between them.  So it's just on a P2P,
individual node to individual node, basis.  And the reason we want this is
really surveillance.  And it's good to be careful with statements about what
this achieves, because ultimately, we need to be aware that all data on the
Bitcoin network is public.  If you broadcast a transaction, you expect everyone
to see that transaction.  If a block gets broadcast, you very much hope that
everyone eventually sees that block.  So it's not like the data itself is
secret, but there are some aspects of, I guess what we could call metadata, that
are worth protecting.  For example, transaction origin information.

When the first node broadcasts a transaction, well, with a sufficiently powerful
observer on the network, they can see messages being sent between peers.  Well,
they can see which one sends it first, and that is likely the originator of the
transaction or close to it.  Yeah, and other things are, say, light client
wallets connecting to a trusted full node.  They would be okay with revealing
which transactions they are interested in; they wouldn't want to reveal that
just to any node, but they might want to reveal it to a specific one they trust,
and so forth.

So, BIP324 itself does not include any notion of peer authentication, and this
is deliberate, and I guess is a maybe unusual choice, because why are you
introducing an encryption protocol without any mechanism for verifying that
you're actually talking to who you want to be talking to?  And the reasoning
there is really that the Bitcoin protocol really consists of two different types
of connections.  One, the most common type, are just arbitrary connections where
your node it has a database of IP addresses, doesn't particularly trust them,
but any node is any node, it makes some connections and the hope is that at
least one of them is honest.  And alternatively, the second part is where you
make specific deliberate connections to peers.  You just know, for example, both
nodes that are your own or nodes of parties you have a business relation with,
or so forth.  In Bitcoin Core terms, the second type is the -addnodes or addnode
RPC, where you specifically select the node to connect to, and the other one is
just the automatic mechanism.

For the automatic mechanism, there is really no notion of an identity of a node.
Our identity is the IP address, but really, IP addresses can change.  It doesn't
really matter, because any node is just as good as any other, and we shouldn't
fall into a trap of trying to raid nodes because they've been behaving honestly
in the past and therefore we should assign them more trust in the future, or
anything like that.  Fundamentally, in Bitcoin, we in general do not trust our
peers.  So, why do you care who they are?  The question of who you are, whether
you're connected to the right person, is only a question that appears in the
second part.

So we wanted to keep the authentication aspect out because it's inherently
something that only applies to some connections, and there are many trade-offs
to be made and many privacy aspects that come into it.  And so we just wanted
to, as a first stage, build a protocol that would just do encryption everywhere,
even between nodes that don't know who they are.  Even that has advantages,
because our primary goal really is raising the costs of certain widespread
surveillance attacks; not a strong guarantee that things become impossible, it's
really just about raising costs.

One of the ways we do that is the BIT324 protocol on the wire looks like random
bytes.  To a third party, there should be, apart from timing information and
packet sizes, literally every byte is perfectly uniformly random.  That means
that things like a blacklist filter that tries to detect, "Oh, this is a Bitcoin
node", by matching for certain bytes, that doesn't work.  If you want to
intercept, you can still intercept, but you need to become a proper
man-in-the-middle that implements the full protocol to observe what's going on,
or spin up your own nodes.  And these things are significantly more expensive
than just matching for a couple bytes.  And so, yeah, I guess I'll let you ask
more questions because I've been rambling for a while.

**Mike Schmidt**: Great overview.  If folks are curious as to the progress of
BIP324 so far, there's a tracking issue on the repository #27634.  Murch knows
that I'm a sucker for tracking issues.  You can see the PR that we covered in
the Review Club there, as well as the progress on some other ones, as well as
for the folks who are curious, there are also PRs that are ready for review.  We
do have a speaker request and potentially a question from Derek.  Derek, do you
want to ask something?  Okay.  Well, Derek --

**Pieter Wuille**: You're on mute.

**Mike Schmidt**: Oh, there we go.  He's back.

**Pieter Wuille**: Oh, he disconnected.

**Mike Schmidt**: Okay, maybe we'll get back to Derek in a little bit.  Pieter,
maybe in terms of high-level what's going on in this particular PR, perhaps an
initial reaction when someone looks at this might say, "Hey, we have Tor and we
have I2P, alternate network types.  Isn't all the network code already
abstracted for those?  What's unique about V2 encrypted transport that
necessitates this change of converting and send messages, bytes?  Yeah, go
ahead.

**Pieter Wuille**: Great question.  So these are things that operate on a
different level.  We already have abstraction in the terms of network
connections.  We can make connections to IPv4, IPv6, over Tor, over I2P, even
CJDNS, but what these things give us is a byte stream.  And there is still a
question of, well, how do we get the messages encoded in the bytes we send on
the wire, whether that wire is a TCP/IP connection or a Tor connection, which
will independently apply some encryption.  And so, this abstraction layer sort
of sits on top of that, where we make it now possible to switch out the
mechanism for encoding and decoding Bitcoin P2P protocol messages to bytes on
the wire.

Maybe a related question that you have in mind is, why do we care about BIP324
when you already can do Tor?  And the answer to that is really we want something
pervasive, that can be deployed on literally every connection.  And it is just
not a good idea to have the entire Bitcoin network operate over Tor.  Tor is
essentially a centralized service that has regularly DoS issues, and things like
eclipse attacks are significantly easier on Tor-only peers.  You get privacy
advantages, but there are costs too.  And so we certainly wouldn't want to solve
the problems we want to address by having the entire Bitcoin network move to Tor
only.  And so that is why BIP324 does it at a higher network level.

It is true that there's probably little advantage to running BIP324 over Tor,
but on the other hand, due to a whole bunch of strange decisions in the V1
protocol as we refer to the old one, in particular, double SHA-256 hash of every
message that gets just truncated to 4 bytes on every message, on a lot of
hardware, the BIP324 V2 protocol is actually more efficient computationally and
in bandwidth slightly than the old one.  So, there should be very little reason
to not just replace everything, which makes it a lot easier to reason about.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: Another advantage, from what I understand, is that by
implementing a completely encrypted traffic between Bitcoin nodes, we would
essentially provide a plausible deniability for other protocols to hide in our
traffic.  So perhaps in the long run, for example, Tor or other protocols could
mimic the Bitcoin traffic and look like Bitcoin traffic.  Can you talk about
that?

**Pieter Wuille**: Yeah, absolutely.  Great question.  So it's true, we wanted
some form of obscurity, let's call it, which is hiding the fact that this is
specifically a Bitcoin protocol.  And there were some choices about how to do
that, like for example, we can try to mask our traffic as HTTPS.  Sadly, that
appears to be very hard to do that in a convincing matter in the sort of setting
we're talking.  So, the choice we made was making a protocol that on the wire
looks like just random bytes.  And the nice thing about random bytes is you can
have many different ways of building a protocol that looks like just random
bytes.  You can adopt completely different cryptography and yet end up with a
protocol that looks like random bytes.  It's sort of a lowest common denominator
that you can try to mimic.

In particular, there is one other protocol that already has this protocol.  It's
the obfs4 Tor pluggable transport, so not the default protocol that Tor speaks,
but there's sort of a plugin you can use for using a different protocol there.
And it also features uniformly random bytes.

**Mike Schmidt**: We have another speaker request from Chris.  Chris, do you
have a question about BIP324 or for Pieter?

**Chris Guida**: Yeah.  Hey, Pieter, just really quick.  So you mentioned that
the point of this BIP is to raise the cost of attack for sort of these large
dragnet surveillance adversaries.  Do you have any simulations that you've done,
like numbers that kind of indicate how much the cost is raised?  So like right
now, if you have an attacker with a botnet or something like that, that can spin
up a whole bunch of Bitcoin nodes, is it like 10 times more money to do this
attack now, or 100 times; do you have a ballpark for that?

**Pieter Wuille**: So, good question, but you have to realize that the bound on
how much we can make things more expensive is, run your own node.  Like, if the
attacker just spins up a whole bunch of nodes and manages to redirect the
traffic there, we cannot do anything about that because they're running a
Bitcoin node.  A Bitcoin node is a Bitcoin node, now they can see everything.
The costs we're trying to raise is that of say a passive firewall that we're not
talking about a few hundred connections that the attacker already knows are
Bitcoin connections.  I'm talking about a firewall that tries to detect at
nation level all the connections I can see pass through, which of them are
Bitcoin and try to intercept what's going on there.

What BIP324 accomplishes is that they basically need to implement the full
protocol, which involves maintaining the encryption state for every connection
to achieve that.  Does that answer your question?

**Chris Guida**: Yeah, I think so.

**Mike Schmidt**: In the writeup for this PR in the newsletter, we have a series
of questions and answers that folks went through who attended the PR Review
meeting.  I would encourage folks to jump into that if they're curious about the
technicals.  We won't go through that now in the interest of time, but Pieter,
I'm curious.  We may have some technically inclined folks who can review some of
these PRs, and if you feel like you are, obviously jump into that tracking issue
and see where you can contribute.  I suspect most people would be less
technically able to do that, but may be encouraged by the project and the
benefits that you've outlined here.  Is there anything folks can do before
there's a release candidate that has this feature in it and run it in the
meantime, or what could people do to help?

**Pieter Wuille**: Yes, so at this point, the PR that you mentioned is merged.
There's a follow-up PR that actually adds the BIP324 transport.  That one has
been merged too in the meantime.  So, the last one is the next one, which is one
that actually enables it for selected peers, where you choose to or where they
advertise support for it.  And so one thing people can do to help is build from
source from that PR.  I don't have the number right in front of me, but you can
find it on the tracking issue, it's called BIP324 Integration, and run that on
your node, of course with the usual caveats that this is not even fully
reviewed, far from tested and released code, but if you want to help, experiment
and see if you find any weird things, that would be very helpful.

**Mark Erhardt**: To be clear, run the BIP with a non-economic node, just like a
testing node; spin up another node for that!

**Pieter Wuille**: Yes, please!  No keys!

**Mike Schmidt**: And the number on that is #28331, which is the BIP324
integration, which has a default off flag for V2 transport.  So if you're
curious and tinkering around, I would encourage you to do that and provide any
feedback.  Pieter, I know you're short on time, I appreciate you joining.  Any
final words for the audience?

**Pieter Wuille**: In particular, it was great to be here.

**Mike Schmidt**: Thanks for your time, thanks for joining us, and thanks for
your work on BIP324.

**Pieter Wuille**: Thank you.

**Mike Schmidt**: Adding roasbeef back as a speaker.

**Olaoluwa Osuntokun**: Can I ask one question to Pieter?  I don't know, we're
running out of time.

**Pieter Wuille**: I'm still here.

**Olaoluwa Osuntokun**: Okay, cool.  Yeah, so my question was how BIP324 relates
to something I've been hearing about, called a countersign, which to my
knowledge is this new authentication protocol in terms of, I guess, the
sequence.  Will you be able to use that independent of BIP324; will it be
basically dependent and you'll first do the normal one and then authenticate; or
is it authenticate before connect?  And maybe, I guess, review of what
countersign is for people that haven't heard about it.  I heard about it a few
months ago in Chaincode and it's been on my mind since then.

**Pieter Wuille**: Yeah, the way this would fit in, to say countersign is a
research project that is not nearly as far as BIP324 is, which is why you won't
find too much about it online.  But the way I'd envision this works, and this is
how BIP324 has been designed, is BIP324 does negotiate a key without any
authentication involved, so now there's a shared secret between the two parties.
Afterwards, you can run a protocol.  Before the full Bitcoin P2P application
level stuff starts, we envision that you can negotiate an extension and say,
"Hey, I want to check who you are", and then you run the authentication
protocol.

So, this gives us a very modular approach, and this is very different from most
generic transport encryption protocols like, say, Noise or TLS, or whatever,
where  the authentication is really a primary feature.  We see it as an
extension because most connections won't need it.  The downside to this approach
is it will cost an extra round trip, but that may matter if you're a web
browser.  That does not matter if you're a Bitcoin P2P node that's going to have
a connection open for a week.  So, we felt that it was a nice approach to just
build the encryption part first and then optionally authenticate later.

What countersign is, that is the name of a research project for an
authentication protocol that would fit in this context; it's a way of basically
asking, "Hey, are you public key X?"  And you have a private key and you respond
to it, but you don't see who I'm asking about.  You don't see X.  And from your
response, I learn nothing at all except whether or not you are X.  So, it's a
very private way of interrogating the other party, "Hey, are you this person
that I think you are?" without anyone learning anything else.  And we think this
is particularly important in a context of a world where the connections consist
of a mix of random, unauthenticated connections and deliberate ones.  Because
the idea is that this authentication, you could even run with random nodes.  You
would just make up a random key and like, "Are you party X?" and, well, the
answer will be no.

But the nice thing is that a man-in-the-middle can tell, because even if the
other side can tell what you're asking about, certainly a man-in-the-middle
can't ask.  So now, they are forced to guess what you're asking about, a
legitimate question, and if it fails, will it get detected, or is just a random
thing that the requester is expecting to fail?  So through that, our belief is
that if universally adopted, it could actually convey some level of protection
to even the random peers, because a man-in-the-middle will be less inclined to
intercept them if they don't know if they're deliberate or not.  But again, this
is a research level project that is far away.

**Mike Schmidt**: Doesn't look like we have any other questions for Pieter.
Pieter, thank you for joining us.

**Pieter Wuille**: Cool, yeah.  Until next time.  Now I really need to go!  Bye.

_LN messaging changes for PTLCs_

**Mike Schmidt**: Okay, well, we'll get back in order with the newsletter by
jumping up to a second news item, which was LN messaging changes for PTLCs.
Greg, you posted to the Lightning-Dev mailing list, "Practical PTLCs, a little
more concretely", where you outline updates to LN messages that would need to be
made in order for Lightning to support PTLCs.  Could you maybe quickly provide a
summary of PTLCs for the audience to start us off and perhaps touch on why now
is a good time to give PTLCs attention?

**Greg Sanders**: Sure, I'll give it a shot.  So PTLCs are a buzzword, which is
a replacement for another buzzword called HTLCs, which I'm guessing most people
have heard of by now.  So that's Hash Time Locked Contract, where payments in
the Lightning Network can be routed atomically by going from Alice, Bob, Carol,
David and so forth.  And basically at each hop on the route, you say, "If you
show me the pre image or the secret for this hash, then you get paid", and
everyone along this route does this, so ideally either everyone gets paid or
doesn't get paid, right?  So the payment goes through and everyone can either
settle on or offchain and get their funds, or nobody does and it times out.  So
,if a payment times out, it gets stuck and it has to time out, that can take a
long time, but at least everyone will get their money back in the end.

PTLCs, instead of using hashes in the SHA-2 sense, uses hash in the sense of an
elliptic curve.  So basically, you're using adaptor signatures to hide a secret
in a signature.  So you basically promise, "If you give me a full signature for
this, as the others go, if you complete the signature, then you get the secret".
And basically the recipient completes the signature.  Well, there's actually a
few schemes here, but one scheme is the recipient completes the signature, which
exposes the secret, and then you can apply that secret backwards, so you can
receive the money you've been offered upstream, because it's like a stream of
payments happening all at once or not at all.

So, the interesting thing about this is that instead of hashes, where the hashes
on each hop have to be the same, the same cryptographic hash and preimage,
instead you can basically remix these.  So, the sender ends up giving blinding
steps to all these hops.  And so at each step, at each hop of the payment, the
value is just a random number, essentially.  So, you can imagine that if
someone's watching the network in many different places, it can make it a little
more difficult to track which payments are which across the network.  Obviously
there's timing attacks, etc, but it's again raising the bar to doing this kind
of analysis.  It also stops this thing called a wormhole attack, which there's
some debate about how much of a problem this is, but where basically if someone
is, let's say, there's Alice, Bob, Charlie, Carol, Dave, if both, like Alice and
Charlie are the same, or Carol, the same person, they can kind of cut you out of
the HTLC reveal, because once Carol knows about the preimage, they can pass it
directly to Alice and cut you out of the loop, cut Bob out of the loop.  So,
with the randomized version, that can't quite happen because every step of this
mixing has to be revealed to the previous person.

That's kind of the practical effects there.  So there's some privacy and
potential efficiency improvements as well as layering on top.  We can think
about doing more complicated schemes with, or more interesting schemes, with
split payments and what's called stuck with payments, where basically, initial
protocol on top where you can say, "I'm trying to route a payment", and let's
say it's a 1 Bitcoin payment across the Lightning Network, what you can do is
say, "Well, I have 1.5 Bitcoin in liquidity, split over a number of channels.
Let me try to push all of that liquidity through", and the receiver can only
claim up to 1 Bitcoin worth.  So basically, if they claim, depending on the
scheme, up to 1 Bitcoin worth, then that automatically reveals to the payer, the
original payer, this kind of proof of payment, and they get proof that they
paid.  And so there's all these kinds of things you can layer on top that PTLCs
are quite nice for.

It also, if I remember right, it can also help reduce the amount of state that
Lighting nodes have to store with some tricks.  So that's kind of the what and
why.  But I guess why now?  Basically, Taproot channel spec is getting close
from what I understand from the LND folks, roastbeef et al, and the LDK folks
have fairly advanced implementations and there's a spec being worked on.  So,
we're getting closer to the finish line here and PTLCs, at least any version I
know about, builds off of schnorr signatures only due to the simplicity of the
math.  And so basically, building off of the taproot spec itself means it's kind
of a logical stepping stone.  I mean, you could theoretically not use taproot
and add it on, but all the machinery that's being used for taproot is kind of a
prerequisite anyway, so it makes sense just to layer it on top.  So, does that
cover any kind of initial questions here?

**Mike Schmidt**: Yeah, that's a great overview.  You mentioned that messages
are maximally split up for understanding and to analyze around trips and
complexity.  This is not a concrete proposal for bits on the wire.  So you're
sort of getting the conversation started, but this isn't an optimized set of
messages per se, more to get people --

**Greg Sanders**: Well, yeah, so I'll give some color to this writeup here.
Basically, there's been like, I don't know, six, seven years of discussion about
this, at least five, and there's been a lot of ideas.  And really, I found a lot
of ideas at the beginning, they're kind of conceptual and drilling down and
seeing exactly what's being sent when is highly illuminating.  So basically, I
find the Lightning Network specs still kind of difficult to reason about unless
I'm very concrete about what's happening.  So, what I did here is on these kind
of message flow, SV diagrams, I basically said exactly kind of which parts are
being sent when, and then grouping them up in waves, essentially round trips.
So, this helps me think more concretely about the state machine involved, right,
when you're tracking how things are changing.  So I'm adding HTLC and fulfilling
it, or I'm canceling it, failing it, I'm removing it.  There's all these steps
in the state machine, and I want to see how that fits into kind of the current
state machine.

Then there's also just the complications, like when do we send nonces and things
like that.  I feel it's really important to write these out concretely,
otherwise these details can get lost.  So, summing up, so ignoring the
overpayment stuff, which I mentioned the layering on top, which I don't know if
I understand correctly, it's mostly orthogonal, not orthogonal exactly, but
pretty modular, I'm focusing more on kind of the change to the state machine as
is today.  Because little wrinkles, like if Alice and Bob are in a channel and
Alice wants to add an HTLC, Alice offers an HTLC to the other commitment
transaction.  So she adds it to Bob's commitment transactions first, and then
sends a signature for Bob's first.  And then what Bob does is Bob acts it, so
the revoking acts as, "Okay, I agree with adding that", and then he sends his
own signature eventually, right?  And this is done in an asynchronous manner,
and so this kind of ordering has implications for efficiency of a naïve
adaptation.

So basically it's things like, how far do we want to change the state machine to
make adaptor signatures faster or more efficient from a protocol perspective; or
do we want to keep things kind of the way they are and bolt on PTLCs for now?
There's been a lot of work, or a considerable amount of writing at least, about
how to -- so one concern is, for example, when Alice offers an HTLC to Bob or a
PTLC, how many round trips does it take to where Bob can be assured that Alice
is locked into this contract and can forward it to Carol, and Carol to Dave, and
so on and so forth?  So this, over high latency links, this can have lots of
waiting time.  Also, each of these round trips is also just another state you
have to track, right, because every step is another state.

So, do we want to do a huge overhaul?  Like at the very end, I mentioned the
fast forward commitment scheme where we kind of rewrite it where we can get very
quick forwards.  But there was some consensus a couple years back, when it was
last written about, where basically that's maybe too big of an overhaul, because
you have to rewrite how HTLCs are added and where, and it's kind of a slightly
more complex scheme.  Maybe it's a good idea to do in the future, I don't know,
but it was kind of parked as like a future work thing.  So rather than do a
complete overhaul, what are the smaller and medium type changes we can make?

I also kind of go through, so not just the message ordering, but the types of
adaptor signatures.  There's kind of two types available.  One is a single
signature adaptor meaning, like the one I mentioned here, is complete the
signature and it reveals a secret, right.  MuSig, so using a multi-signature
like MuSig, you can also do adaptor signatures the same way, but it kind of
changes when messages have to be sent, because for a MuSig, let's see, how does
this work?  The non-offerer has to send their partial signature first, which is
another complication on top, which is kind of there's extra arrows going back
and forth, which can complicate it.  But later on, I realized, rereading an old
t-bast, Bastien article, like a writeup, that with some light reordering of the
state machine, so what if instead Bob sends the signature first instead of Alice
when Alice offers, we can actually shave off some of this complexity too.  But
again, this is like a state machine rewrite, a smaller one, right.  But it's
still a rewrite.  And so, this is the space of things we have to consider.

There's also practical ones, right?  So, how does this interact with, for
example, current mempool policies?  Because from what I can understand from
writing things out, I think for today's mempool, MuSig adaptor signatures don't
really make a lot of sense, at least two-party MuSig.  You could do a silly
one-party if you want, but because the idea would be like Lightning taproot
channels where you can have a MuSig on the key spend path of taproot.  But for
PTLCs and HTLC type things, right now we need to have what I think is called a
companion signature, which means the claimant, the HTLC or PTLC success
claimant, can add on additional inputs and outputs as the inputs and change
outputs.  And to do that, you basically need another signature, and key spend
only works with one signature.  And this one signature, this PTLC signature, or
pre-signature has to be given ahead of time.  So you can't really commit to --
well, you could, but probably don't want to commit to the inputs and outputs
ahead of time, it doesn't make sense.  That's kind of the high level of it.
I'll just stop for questions, especially with roasbeef, please jump in roasbeef,
I would love to hear some thoughts.

**Mike Schmidt**: Exactly.  Yeah.

**Olaoluwa Osuntokun**: Cool.  Yeah, I mean first, definitely, really great job
investigating this stuff.  This has always been in our minds, like someday PTLC,
but obviously gets focused on the message flow.  Because one thing I think I
realized early on, when I was working on the taproot channel and stuff, which I
think you really fleshed out, is that initially, like you were saying, I tried
to also have the second-level HTLCs also be basically MuSig2 signature, but it
has to go with complexity because at that point, you basically have that other
signature to send, right?  Where today, you can basically update that HTLC and
then signature, but then you'd need another round to get that.  And I think
that's what you're talking about, with the round trips 3.5 versus 2.5.

**Greg Sanders**: Yeah, exactly.  But I think you can fix that, but it takes a
rework, right?  And so is that really worth it?  Because right now we have
asynchronous updates, which means both people can do it at the same time.  So
even though it's 1.5, it's not so bad.  But if, for example, we switch to
synchronous, let me look at the chart here, synchronous, MuSig-based, then
suddenly it's like 4.5, 3.5, 4.5 round trips.

**Olaoluwa Osuntokun**: By synchronous, you mean simplified commitment type of
stuff, where you basically go --

**Greg Sanders**: Exactly.  So simplified updates, simplified commitments with
MuSig adaptor signatures would result in 3.5 round trips, during which you can't
actually take turns, right, things are happening.  So there's this kind of
trade-off on if we want to keep the protocol simple, if you wanted to do
simplified commitments, how would you do it and without slowing down
turn-taking?  We still want turns to be fast.  We especially want turns to be
fast when we're blocking the other person, I guess is my point.  Yeah, if that
makes sense.

**Olaoluwa Osuntokun**: Yeah, and I think one data point that I think will be
useful would basically be how to utilize our channels across the network, like
really big nodes, right?  For example, I don't know if people know, but today
there's like an HTLC limit, which is 43 in both sides.  That can be lifted, but
for now it's there, right?  So, if theoretically, this thing was always being
full, then adding these additional round trips would sort of hamper throughput
in the network, basically.  But if it's the case that most channels are really
just idle most of the time, then maybe the extra round trips here with what we
get isn't really that big of a trade-off generally, right, because we're getting
a lot of other flexibility.  So that's like one thing that I could add.

**Greg Sanders**: So if that happened, then maybe something like simplified
updates with not changing things much would be okay, because it's like, okay,
things are quiet most of the time, we can take turns pretty fast.  But yeah, I
think this is going to need some data analysis here.  But I think the biggest
takeaway I can give you today is probably not MuSig because we don't actually
save anything.  Even if we reordered the messages and whatnot, like the last
example I have, you still pay the same amount of bytes because you still need
two signatures and a tap signature, like a tapscript reveal.  So, I think it
makes sense to not do MuSig for this.  You get rid of nonce questions, like when
do you send nonces?  Because remember, with PTLCs today, every time you send an
update, you have to refresh your pre-signature, you have to add more nonces each
time, and then there's a dynamic amount of pre-signatures every single time you
update, right?  And so it's like nonces just flying everywhere.  It's a bit of a
headache.

So, another interesting note, somewhere in the middle, I say, what if we had
ANYPREVOUT (APO) or something like it?  Of course, I'm putting asterisks here,
anything like ANYPREVOUT, then at least you can send your pre-signature during
the addition.  You say, "I'm offering this", you send a pre-signature, the
adaptor signature part, you can send that up front, and then it exists for the
lifetime of the PTLC.  So, in an interactive protocol like Lightning Network, I
think that's where APO-like things really shine, and obviously it could be
CHECKTEMPLATEVERIFY (CTV) plus CHECKSIGFROMSTACK, whatever.  I'm just using APO
as an example, because I've used it more.

Then obviously, just for fun, in one of the sections I said, LN-Symmetry, it's
like, here's the state machine, t you go.  Obviously, there's some drawbacks
here, but just seeing the whole gamut of what complexity looks like and what
kind of wins we can get with today's consensus and mempool policy, and then put
that forward for people to do more research, maybe.

**Olaoluwa Osuntokun**: Cool.  And then one thing I would mention, I guess, for
audiences, like one thing instagibbs mentioned was basically this whole
overpayment thing.  And I think something like that, I think René's done some
research on in the past, and we talked about it at the spec meeting earlier this
year.  And basically what this would let you do is that this would basically let
you spray and pray without a penalty.  Where today, if you overpay, potentially
the other party can sort of pull extra; let's say it's a 1 BTC payment, I send
1.5, because I had a bug, basically, they can pull all that itself.

So, what this is about is about adding this additional round trip after the
HTLCs have been extended, which then allows the sender to provide their own
preimage.  So, in a nutshell, we have basically now two preimages.  But one nice
thing, I think he mentioned that it's not necessarily dependent on PTLCs but
it's nice with, it because for PTLCs, the two preimages looks still like a
single key.  The internal network doesn't necessarily need to upgrade for
something like this, or rather be aware that there's two preimages.  So in
theory, this could potentially increase payment reliability, because now you can
sort of over sample, right?  And as long as X% actually gets there, then you're
fine.  Or, say you need to be pretty precise with what you're sending, and the
other thing I would say, we don't have any ACKs in the protocol, right?

So, I send an HTLC, and I'm like, "Hopefully it got there".  And then, I know it
got there because maybe it got canceled back or it got settled.  But with
something like this, I could get an ACK and that can also let me update my
payment routing plan, locate that 0.5 got there, I can split like this as well
now; that's like another interesting thing.  But I think like instagibbs was
saying, it's pretty distinct as far as employment.  Basically, we can do one,
look at the other one, and we're not super-required, but it's something that's
promising, I think, to simplify pathfinding generally.

**Greg Sanders**: Yeah, so I agree with everything there.  And I think one
important point is that a lot of these will probably use the onion messages
spec, which got merged, being able to send these messages back and forth in a
blinded manner.  I guess onion messages are a blinded path, right?  I forget the
spec, but yeah, it's good being able to parse messages back and forth.  Yeah,
blinded path.  So, with a blinded path spec, now you can send these ACKs back.
Now, basically the receiver would say something like, "I'm ready", and then once
you get that, you can send the secret.  Murch?

**Mark Erhardt**: Yeah, I wanted to get back to the question on when this will
be happening and why we're talking about it now.  So, from what I understand,
you would only recommend that PTLCs are used on taproot-based channels.  So
first, we need to figure out how funding channels with taproot outputs would
work.  Then you recommend it, or that was optional maybe, but you said it would
be much easier or cleaner if we already had LN-Symmetry.  So, this sounds like
PTLCs is at least two, three years down the road.  Can you put it into the
bigger frame?

**Greg Sanders**: So, no, I mean that's one option, but I think that's doubtful
because that's consensus and mempool.  There's dependencies, right?  I think for
smaller changes, I would say it's not too bad, actually.  So the single-sig
adaptor updates, there's probably a version of that that seems palatable for the
changes required, especially, as roasbeef mentions, especially if it enables,
well, if we can build on top and do overpayments, maybe we can paper over some
of this latency, right?  If you don't have to try 50 times at optimal pit speed,
but you can try once at some high percentage of optimal speed, then I think we
can probably work around a lot of this.

So, I think waiting on that's a mistake.  I wouldn't wait for mempool to get
fixed.  I think there's a lot of stuff that can get done in the more medium
term.  And so I think for me, building on top of taproot channels makes sense,
because we would have learned a lot of lessons from building the taproot
channels first, right?  You don't know how complex something is until you
actually build it, and they're very close, and they've learned a lot of lessons.
And I think carrying those lessons forward would be helpful, I think.  And
second is that, if we think everyone's going to migrate to taproot channels
eventually anyways, just keep the specs simpler and add PTLCs on top of those.
But maybe that's just my opinion.  People can disagree with that one.

**Olaoluwa Osuntokun**: Yeah, and one other thing I think is worth mentioning as
far as getting to PTLCs is that the taproot channels that we have today, they
can only be unadvertised, or private channels, meaning that it can only be used
at the edges, a mobile phone, a merchant, or something like that itself.  And
the reason for that is that today, in the protocol, it's sort of like an
authenticated structure, in that we basically have the other party prove that,
"Okay, well, you have that P2WSH output, these are the multisig keys", and so
forth, which you give someone that's doing gossip basically a P2TR output,
doesn't know what to do with that.

So, we're also planning this other update, I guess our codename now is Gossip
1.5, after it was expanded a little bit, which will number one, let you
advertise the taproot channels on the network itself.  Along the way, we sort of
like add some more flexibility to potentially allow you to gain a bit more
privacy when advertising the channels in the first place, in terms of having
hooks to allow them to be sort of arbitrary outputs anyway.  So, in terms of the
full progression of stuff, you can say, okay simple taproot channels right now,
unadvertise itself, the Gossip 1.5, which is basically being able to advertise
these new channels and maybe add stuff like Simple Payment Verification (SPV)
proofs in the future, and then the PTLCs.

But for what it's worth, the Gossip 1.5 thing is pretty independent in terms of
dependencies.  It's also something like, if an implementation isn't yet ready to
do full taproot channels, but reasonably their wallet needs updating, they can
just do the Gossip 1.5 stuff, assuming they can verify a MuSig2 signature or a
schnorr signature.  So then, at least that lets us deploy this a little bit more
concurrently.  People are doing channels at the edges, then we have the Gossip
to basically advertise the taproot channels, and then we do PTLC, so just in
terms of what that progression would actually look like.  And we're working as
well with some other people on the Gossip 1.5 stuff.  I think we'll ideally have
implementation through the end of the year, basically.  And then obviously,
you're just waiting on interop, and there's a lot of stuff going on, on the
protocol side.  So, definitely no shortage of things to be working on.

**Mark Erhardt**: Super-cool.

**Greg Sanders**: So, it may be the case that we end up not wanting to gate it
on necessarily taproot channels, per se.  But yeah, it's an evolving thing,
right?

**Mark Erhardt**: Yeah.  The other thing is, my understanding is that it is not
possible to mix HTLCs and PTLCs along a route.  So, especially if you're
thinking about this spray and pray mode, where you over-send and then have the
confirmation afterwards that limits the receiver from taking only as much as you
intended to send, you would need a really broad adoption of PTLCs at that point
for that to work, right?

**Olaoluwa Osuntokun**: Yeah, that's true, unless you do some hand waving ZKP
thing.  I think AJ did some demo a lot back before, so it's more mature.  But
yeah, so you can't necessarily combine them in a route, and I think the other
question as well, which is a question about upgrades, like how does the network
actually transition?  Because today, the invoices have a payment hash, right?
So maybe we'll have a future where you have a payment hash and a public key.
And then, the sender can pick as well.  And I would also imagine nodes will
advertise the PTLC, but still support doing HTLC.

For example, one thing that we did in the network a few years ago, we upgraded
the onion payload format, something a little more flexible, right?  And then I
think just this year, did we remove the old version?  So now, everything is
basically the new TLV payload.  So, I imagine we'll have something like that for
this.  But I think we're just right, like time will tell how long it takes that
switch over to happen basically.  But I think Murch is right.  Time will tell
how long it takes that switchover to happen, but I think my mental model is that
if the overpayment thing is really, really that great, that may be a very big
incentive just to improve the viability as a hope for people.  It sort of
updates as quickly as possible whenever it's ready.  So as always, distributed
system, decentralized system, there's no flag-day update, so we just have to
wait for people to upgrade and hopefully we're giving them compelling reasons to
do so.

**Mark Erhardt**: Yeah, that makes sense, thanks.

**Mike Schmidt**: Great conversation, great dialogue, guys.  Greg, thank you for
joining.  We have a couple more items left in the newsletter.  You're welcome to
stay on or if you need to go, drop off.

**Greg Sanders**: I've got to hop off, but thanks for the invite.  It's always a
great time.  Thanks, bye.

_LND v0.17.0-beta.rc2_

**Mike Schmidt**: Roasbeef, the next item in the newsletter is the LND
0.17.0-beta.rc2.  I think you all have released RC3 in the last day since we
published this.  Normally we don't want to be too much of a spoiler alert with
the newsletter, so over all the features, but I guess what would you call for
the audience to be aware of or do with regarding these RCs?

**Olaoluwa Osuntokun**: Good question.  I mean, so one thing that I guess isn't
a spoiler anymore is that we have the initial version of the taproot channels in
the RC, which is super-exciting.  And as I mentioned, this is basically for now
only unadvertised channels.  So this means mobile phones, things like that can
use it.  But I think one thing to call out is just people testing that on
testnet, basically.  This is a very new scheme we're doing.  I think it's one of
the first times that something like this has been done, as far as the MuSig2
level and some of these other aspects, particularly because people didn't really
have libraries for this stuff for a while, and obviously we're waiting for the
BIP to be finalized there.

But one thing to call out is just testing that stuff out.  We think we have
pretty good coverage.  People know things like SCB works with that.  And one
other thing to mention as well is that you need to add a flag, because it's
something that we're still pushing out there.  We're waiting to interop things
like that as well.  Then there'll basically be another specified channel type to
say, "Okay, I want to open taproot channels".  So, this means you basically have
to do that explicitly.

But other than that, there's definitely a bunch of really good bug fixes
generally across things, which is memory consumption, other weird wallet stuff.
Some of the SQLite push-grab stuff is getting a lot more mature now, as we're
starting to add additional capabilities there.  Watchtowers are pretty good.
Also, Neutrino nodes have some pretty nice speed-ups, in particular for rescans,
just as far as doing more things concurrently, fetching headers, fetching
filters concurrently as well.  Then there's definitely some other nice RPC level
changes there too.

Right now, we did RPC3 the other day, and maybe there'll be one more, as we're
trying to make sure things work with this remote signer thing, which is like a
dumb version of VLS, it just signs whatever, but gives you some separation.  But
that's some initial highlights there.

**Mike Schmidt**: Thanks for walking us through that.  Murch, we have one PR,
and I believe you are the author of it for this writeup.  Do you want to take
it?

_Bitcoin Core #26567_

**Mark Erhardt**: Yeah, of course.  I'm only the author of the writeup.  The PR
is by Antoine, darosior.  So, this is more of an under-the-hood change in the
wallet.  So, when we are trying to sign for an input and we have a descriptor
for that UTXO, for the script that we use in the UTXO, then we are not doing a
signing dry-run anymore to estimate the weight of the signed input, but rather
we can calculate it directly from the descriptor now.  And this is, on the one
hand, just cleaner because we can actually argue better about what should be
happening, rather than just trying out whether we could sign for it.  It also
works for a miniscript descriptor, where at least in some cases, the dry-run
signing approach did not work to give us the correct weight.  So, we used this
to estimate how much it would take for, for example, an external device to sign
an input in the maximum, and so we have enough fees for the transaction when we
broadcast it later.  And yeah, that's pretty much all there.

**Mike Schmidt**: Excellent.  Well, thanks, everybody, for joining us today.
Thanks to our special guests, roasbeef, sipa, and Greg Sanders, and thanks
always to my co-host, Murch.  Murch, any announcements before we wrap up?

**Mark Erhardt**: And thanks for the people that came on to ask questions.  I do
not have any announcements.  See you next week.

**Mike Schmidt**: Cheers.

**Olaoluwa Osuntokun**: Cool.  Thanks for joining, thanks for inviting me.

{% include references.md %}
