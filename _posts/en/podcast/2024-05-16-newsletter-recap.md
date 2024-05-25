---
title: 'Bitcoin Optech Newsletter #302 Recap Podcast'
permalink: /en/podcast/2024/05/16/
reference: /en/newsletters/2024/05/15/
name: 2024-05-16-recap
slug: 2024-05-16-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Dave Harding are joined by Calvin Kim to discuss
[Newsletter #302]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-4-16/70c8b87c-9646-fdff-aabb-7fe02f821e40.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Good morning, this is the Bitcoin Optech Newsletter Recap
#302.  As you can hear, I'm not Mike, this is Murch.  Today I'm going to be the
main host.  I'm joined by Dave today.

**Dave Harding**: I am Dave Harding, I'm co-author of the Optech Newsletter and
co-author of the third edition of Mastering Bitcoin.

**Mark Erhardt**: And by Calvin.

**Calvin Kim**: Yeah, hello.

**Mark Erhardt**: Yeah.  Well, we'll jump into your topic anyway soon, Calvin,
but if you want, you can start by introducing yourself a little bit.

**Calvin Kim**: Yeah, sorry, my mic wasn't unmuted.  So, yeah, I'm Calvin, I
work on a project called utreexo, and we just did a beta release of it, so
excited to share that with you guys. #

_Release of utreexod beta_

**Mark Erhardt**: Awesome, thanks for joining us.  So, yeah, we're jumping into
the newsletter and the first news item is exactly that, the release of the
utreexod beta.  And you post it to the Bitcoin-Dev mailing list to announce it
and you have full node support working with utreexo.  So, as we've discussed
here before a few times, utreexo is a different way of storing the UTXO set, in
the form of commitments.  So, you actually prove that a UTXO exists in order to
validate transactions.  Is that right?  Do you want to tell us a little more
about the recent changes?

**Calvin Kim**: Yeah, that's right.  So, utreexo is just a set of merkle trees.
And so, what we do is we take the UTXO set and we represent that as merkle
trees.  So, the full node implementation that has this implemented is the one
that we just released; it's called utreexod, and it has support for the full
node, as in fully validating everything with the utreexo accumulators.  And it
also has support for what we call bridge nodes, which attaches proofs, like the
accumulator proofs, to new blocks and new transactions.  So, yeah, so we were
trying to get it stable enough to have a beta release for a while now, and it's
working well enough that I feel confident that people can try it out.  So, yeah,
please do try.

**Mark Erhardt**: Yeah, very cool.  So, you were talking about bridge nodes.  So
naturally, we could dive a little into why we need bridge nodes.  In the
regular, or in the existing Bitcoin Network, people send around transactions,
everybody has the entire UTXO set, or all the full nodes do, so they have all
the information necessary to determine on their own whether a transaction is
complete and valid.  With utreexo, you only have this set of merkle trees that
commits to all the existing UTXOs, but you don't actually store the entire UTXO
set, from what I understand.  So, what the bridge nodes do is they add the
proofs that UTXOs exist, or where to find them in the merkle tree; or, how does
the bridging work?

**Calvin Kim**: Right, and so normally, the normal expectation for a full node
right now is that everyone has the entire UTXO set.  And so, whenever you
receive a new block, the block has UTXOs that it's pointing to that it's trying
to spend, like the transactions.  And so normally, that's expected to be kept
with you, you're expected to store it.  But with the utreexo model, you're not
expected to store it.  So, you receive that data along with the block, and to
prove that the data that you received was indeed correct, you have the merkle
proofs for those.  And once you verify that the data that you received is indeed
committed into the utreexo accumulator, then you can validate the block as
normal.

**Mark Erhardt**: Very cool.  Yeah, so that sounds like -- you go ahead, sorry.

**Calvin Kim**: Yeah, sorry.  I was going to say that we need these bridge nodes
to avoid having a soft fork.  So, one of the ways that we can provide these
proofs is something like where we force the miners to have the utreexo proofs in
the coinbase, and that can be a way we could do things.  But just having these
bridge nodes in the network is a way to avoid soft forks.  So, that's why we
could just announce it and release it instead of having to go through the entire
consensus for a soft fork.

**Mark Erhardt**: Right, so the bridge nodes essentially are a translation layer
that adds the proofs that anchor the information about the UTXOs to the trees
that the lightweight node has already.  And now utreexod allows people to run an
extremely lightweight node, and I assume the idea would be to integrate that,
for example, into light clients, or what do you see as the target audience?

**Calvin Kim**: Yeah, and utreexod supports both the bridge node capability as
well as the really tiny node capabilities.  And so, with the really tiny node,
at the moment we're seeing this just as a UX improvement, and we're trying to
target wallets so they could pre-integrate the utreexo into their wallets.  And
so, if you download a wallet, you were previously dependent on a third-party
server, but with this, it would be feasible for you to self-validate and not
have to fetch for the blockchain data.

**Mark Erhardt**: So, it's a security improvement while keeping it extremely
lightweight still, but you need these bridge nodes.  So, what you're asking is
for some people to get interested in the beta and to create some sort of first
set of bridge nodes?

**Calvin Kim**: Yes, so at the moment there's not that many.  We actually are
trying to spin up a few extra so that folks can connect to them.  But yeah, so
there's not that many bridge nodes and there's also not that many archival nodes
as well.  So, either would be very good to have.  I should mention that bridge
nodes are only responsible for attaching the proofs for new blocks and
transactions.  Everything else works the same as before, where an archival node
will store the entirety of the blockchain and the utreexo proof, if you're a
utreexo or archival node.

**Mark Erhardt**: So, when you synchronize, do you just jump ahead to the end;
or do you actually have to go through all the blocks with the proofs?

**Calvin Kim**: Oh, yes.  So, that is another feature that utreexod has.  And
so, some of you folks might be aware of the assumeUTXO project, where the whole
idea is that we have a hash of the UTXO set committed into the binary that you
download.  And when you download the binary, you have the committed hash, and
you download the entire UTXO set and compare the hash with the one that you
received with your binary.  And if that's correct, then great, then you can
start off from some block that's close to the tip.  We do the same exact thing,
but it's assumeutreexo, where we don't just give you the hash commitment of the
UTXO set, we give you the entire representation of the UTXO set.  So, with
assumeUTXO, you still have to download, now it's about 12 GB of the UTXO set
before you can get started, but with this you can immediately get started from
wherever the utreexo routes will provide it at.  So, that is a feature of
utreexod.

Another thing that you can do is you could turn that off, so you're removing
that trust element from the developer, and you can sync from genesis and check
every single block and every single utreexo proof as normal.  So, you could do
both.

**Mark Erhardt**: So, would that be per the regular synchronization mechanism
from btcd, or would that also use a special mechanism from utreexo?  Yeah, so it
includes both the regular synchronization from btcd as well as extra codes for
utreexo.  So, everything else, like script validation, like checking how much,
the amounts and stuff, that's all correct, like the proof-of-work headers.
Everything else is correct, but except for fetching the UTXOs.  Now you would,
for the btcd code, you would still expect to fetch that from your local
database; with utreexo, you expect to receive that from your peers.

**Mark Erhardt**: Awesome.  Okay, Dave, do you have any more questions or
comments?

**Dave Harding**: Sure, I have a few questions.  But first of all, thanks,
Calvin, for working on this.  Obviously, it's been a long-term project, both for
the community and of yours in particular, so thank you so much for sticking with
it and getting to this beta version, I'm very appreciative of that.  One of my
questions is, for communicating the proofs, I assume you need extensions to the
P2P protocol.  Can you talk about what those are; how significant are they; are
they big changes; are they little changes?  And is that something you're going
to get to a specification point, you know, open a BIP and just standardize?

**Mark Erhardt**: Your microphone is off, I think.

**Calvin Kim**: Oh, it's weird.  On some places, I can hear Dave, but from my
speaker, I can't hear Dave.

**Mark Erhardt**: Oh, wild.  So, Dave asked what P2P changes would be necessary
to make utreexod work, and whether you are going to standardize that, for
example for a BIP, if I gathered that correctly?

**Calvin Kim**: Oh, yes.  So, the P2P changes required are, it's basically a new
message for a block and a new message for a transaction.  So, the current
message is that you only receive the Bitcoin block, but then we also want to
receive the utreexo proof with it, and that utreexo proof that you receive has
to be in a specific format for the verification to work.  And so, there's that.
And then, there's also the transaction parts where you ask when you receive a
transaction, when you receive an inferred transaction, you also ask for what
information do you need to verify that transaction, whether that transaction
exists in the UTXO set or not.  And so, those are the two main changes needed to
the P2P protocol.  And at the moment, myself and Davidson, who is the author of
another implementation called Floresta, is writing that up at the moment in
Bangkok on BOB Spaces.

**Mark Erhardt**: Awesome.  I'm looking forward to reviewing your BIP.  We have
a question from the audience.  Mike, you're on.

**Michael Tidwell**: Hey, Calvin, a couple of questions.  One is, do you foresee
any sort of, I guess you could say, political downside or people pushing back
hard against this?  I know I've heard Tadge talk about this a bunch.

**Calvin Kim**: Is it just me that can't hear anything, or is it others as well?

**Mark Erhardt**: I can hear it fine, unfortunately.

**Michael Tidwell**: Oh, no.  Okay, well maybe, Murch, you can just repeat my
question for Calvin.  The tl;dr is, does he foresee any pushback on this?  And
what would those potential conversations be?  So, that's sort of general.  And
then the second question is, what use is --

**Mark Erhardt**: One at a time!

**Michael Tidwell**: Okay, yeah, do that one first.

**Mark Erhardt**: Calvin, I'm going to translate the question.  So, Mike is
interested whether you foresee any sort of political skepticism with this new
model of node, and what sort of conversations you anticipate to have in the
community.

**Calvin Kim**: I think the most, well, really the best part of how we're
approaching this to adoption with new users is that it's 100% optional.  So, if
you don't want it, just ignore it and nothing changes for you.  If you want it,
then yes, participate in it.  And you're not forcing anyone to do any upgrades
that they don't want to.  And so, in that sense, I really don't think this
should be controversial at all.  But of course, I haven't heard all of the
opinions out there.  And so, I would actually be interested in hearing different
opinions and if there are people that are against this, why they would be
against this.

**Mark Erhardt**: Thanks.  Mike?

**Michael Tidwell**: And then the second one is, what use cases and what does
this enable that he's really excited about?  So, for instance, does this relate
to something with Lightning, does this relate to something with something else,
like light clients?  What kind of use case is he super-excited about that this
will help enable, besides maybe the obvious scaling, easy kind of stuff?

**Mark Erhardt**: All right, Calvin, the second question is, what use cases are
you most excited about that get enabled or improved by this option?

**Calvin Kim**: Oh, really the thing that we're trying to go for at the moment
is we're not trying to convert the existing node runners, we're trying to
convert the people that are not running nodes because it's not a good UX to do
so, and it's difficult for people to do so.  And so, for these people, what we
want to do is, it doesn't even have to be that they're aware of their running a
node.  It's like, "Okay, if I pick this wallet software, I know that it's fully
validating everything.  And because of that, I choose to run this software".  I
think that's a really good thing to target at.  And so, even though some people
might be skeptical because this is a different consensus code versus Bitcoin
Core's, but now you're going from like a light client or to SPV type of security
to full node security, even though it might be different implementations.  So,
that's what I'm really excited about for this release.

**Mark Erhardt**: All right.  So, your argument is, the target market is
improving the security of light clients that have a reduced security right now
to what they would have under a utreexo model.  Would that be applicable to
Lightning wallets, for example?

**Calvin Kim**: At the moment, it is not.  There is a work around around this,
but if you want to do it properly, the Lightning channel announcements need to
be changed, because when you do a channel announcement, you just point to a
UTXO, an outpoint.  But if you're a utreexo node, you don't know if that exists
because there is no utreexo proof attached to it.  And so, we also need to
change the Lightning Network protocol in order for Lightning nodes to be able to
use this properly.  So, that's something that we want to do down the line, but
not at the moment.  We have that planned.

**Mark Erhardt**: So, I see, you would need to add the utreexo proof to the
announcement of the channel in an extra P2P message, or something like a variant
of the existing?

**Calvin Kim**: That is my knowledge, yes.

**Mark Erhardt**: Dave, did you have another comment or question?

**Dave Harding**: A quick comment is that I think in next week's newsletter,
we're going to cover an idea for Lightning announcements to be based on a ring
signature, which I think would be kind of fundamentally incompatible with
utreexo.  That's just a point.  And my question for Calvin, my last question
would be, what are his goals for the next year or so in utreexo?  Obviously,
he's going to accept feedback from this and iterate, but where does he see the
project going in the next year?

**Mark Erhardt**: All right, Calvin, could you hear that?

**Calvin Kim**: Well, I didn't hear everything.  Could you repeat the last parts
that Dave said?

**Mark Erhardt**: Okay, so he mentioned that in the next newsletter, we're
probably going to cover a proposal to announce Lightning funding outputs via
ring signatures, and he was wondering whether that's fundamentally incompatible
with utreexo.  And the other thing was, what your plan is in the next year or
two, where you want to take the project.

**Calvin Kim**: Yeah.  So, this is kind of funny because I literally just talked
about this with Tadge an hour ago, and yeah, it would be fundamentally
incompatible.  Maybe it would be compatible, but still we're thinking about how
to implement things.  So, yeah, that's to be determined.  For myself, next year
or two down the road, at the moment what I want to do is I want to get things
more stable.  I want to spec things out so that it could be peer-reviewed and we
could have other people, have other developers, integrate utreexo into their
projects and get adoption in that way.  And beyond that, I guess the next thing
would be to get some sort of an implementation going for Bitcoin Core, but at
the moment I don't have that in my mind.  I'm just thinking for the next year,
and for the next year, just more stability and spec and peer review.

**Mark Erhardt**: Awesome.  What sort of help or input or activities from the
audience would you wish for?  So, run a node, obviously; anything else?

**Calvin Kim**: Yeah, at the moment, do please try out the software.  To my best
ability, it is stable and working.  Try out the wallets that are integrated, try
out the BDK wallet, try out the Electrum wallet that is integrated with it, try
the assumeutreexo, try fully syncing.  It would be nice to have more eyes on it
so that if there are bugs, then we can catch them.  And, yeah, for other fellow
developers out there, we're currently writing up BIPs.  We'll have that out
very, very soon, so some eyes on that would be very helpful as well.

**Mark Erhardt**: Excellent.  Thank you so much for joining us.  You're welcome
to stick around.  Maybe reconnect if you can't hear all of us, if you want to
stick around.  If you have other things to do, we understand, but thank you very
much for joining us.

**Calvin Kim**: Yeah, thank you for having me.

_BIP119 extensions for smaller hashes and arbitrary data commitments_

**Mark Erhardt**: Cool.  We are getting to the second news item this week.  We
will talk about BIP119, which is OP_CTV or OP_CHECKTEMPLATEVERIFY.  There is a
new BIP that Jeremy proposed, which extends CTV in two aspects.  And one of
those aspects is, instead of making a hash that is 32 bytes to commit to the
whatever properties you are looking for in the future transactions, there is now
a proposal to use a hash with 160 bits, so 20 bytes.  The idea here is in a
single-signer scenario, this can probably be secure enough, but it would make
the commitment 12 bytes smaller, which would be cheaper, cost less block space.
The other one would be to be able to commit to witness stack items.  Originally,
there was an idea that you could commit to OP_RETURN outputs to have some data.
And with the witness commitment, you could actually store data more cheaply, as
we have learned in the last year.  Dave, you probably looked a lot more at this.
What am I missing?

**Dave Harding**: I don't think you're missing anything at all.  So, BIP119 is
actually designed to be extendable.  So, as written, it expects a 32-byte object
to be on the stack.  If it's not exactly 32 bytes, it will unconditionally
succeed, so it's upgradable.  So, we can add, either as part of the initial soft
fork, if it gets soft-forked in, or as a later soft fork, we can add the ability
to take different size objects on the stack.  So, what Jeremy has proposed here
is that we can take three additional sizes here.  We can take a 20-byte object,
which will give you that support for the RIPEMD-160 hashes, which like Murch
said, those are secure in a single-party setting, and they can be secure in a
multiparty setting if you take a little extra care in generating that hash, but
it's something you've got to be careful about.  And that's why I think it wasn't
in the base proposal, was that to be absolutely safe, we would prefer to use the
strongest hash available in Bitcoin, which is a 32-byte hash.

Or we can put on the stack a 21-byte object, which is -- I'm sorry, not 21 byte,
sorry, I'm getting this messed up.  It is a 21-byte.  You can put on 21-byte
objects.  The extra byte is a flag that tells it to consume an extra argument
from the stack, and that's the additional data you want to commit to with the
20-byte hash, or you can put a 33 byte hash on the stack, and the extra byte,
again, tells you to consume an extra element from the stack with the data that
you want to commit to when the thing gets spent.  The purpose, the imagined
purpose for both of these things is something like Greg Sanders designed for
eltoo, which is an upgrade to LN's channel management layer, that allows the
person signing the transaction to commit to extra data to put that on the stack,
that helps them recover from the channel if they lose their state.

So, eltoo is designed so that penalties, it doesn't require penalties, you can
just put whatever your current state is on the stack, but you also need a way to
recover part of that state if you've lost it.  And so, I don't remember exactly
how Greg's things work, but he commits to extra data to make recovery easier and
safer for eltoo channels if you've lost your state along the way.  So, this just
simplifies that and allows that usage and makes it a little bit cheaper by
allowing you to use a 20-byte hash rather than a 32-byte hash.

**Mark Erhardt**: Awesome, that sounds pretty cool.  So far, I've seen that
there wasn't much discussion about this on the mailing list, so if this is
interesting to you, maybe check it out.  All right, that was the news section.

_LDK v0.0.123_

We're getting to Releases and release candidates.  We have two of those this
week.  There is the LDK release, the latest, it's v0.0.123.  And the two
features that seem to stick out the most are a lot of improvements to BOLT12, to
the offer process.  And we've talked a bunch about this in the last few Optech
Recaps, trimmed HTLCs (Hash Time Locked Contracts).  When an HTLC is not
valuable enough to actually write to the chain, some Lightning implementations
have now more logical or rational behavior, in the sense that they might drop an
HTLC that costs more to write to the chain than it is worth.  So, there seem to
be new configuration options in this LDK release in that regard.  Okay, cool.

_LND v0.18.0-beta.rc2_

And the second release, or RC actually, we've talked about or not talked about
already a couple of times!  LND v0.18-beta has a second RC now.  This is, of
course, the most popular node software on the LN.  I assume that lots of
listeners are running one version of LND or another.  If you rely on the
software, you should really look at RCs.  Check out the release notes, test it
in your test infrastructure to make sure that it doesn't have any
incompatibilities.  We had some of those in the last release, I believe, where
we found, or rather Bitcoin Core amended some limits and that caused an
inconsistency with how LND was interacting with some RPCs.  So, if you're
dependent on LND, please also test this, just like with the utreexod client.  If
you have time in cycles, all of this open-source work only works when people
take a look and chime in.

We're still hoping that we'll get someone on the show to talk us through all of
the new features of LND.  Once it is released, we'll probably have one of their
engineers on.  Cool.  Anything else, David, there or should we move on?  All
right, cool.

So, in the last section, we talk about notable code and documentation changes.
We look at a bunch of open-source projects and the BIPs repository and BOLTs and
Inquisition and BINANAs, and so forth.  We have a bunch of those.  If you have a
question or a comment from the audience, now is a good time to find the "request
speaker access" button, and we'll try to get you in here.

_Bitcoin Core #29845_

So, the first code change is from Bitcoin Core #29845.  We have a change here to
multiple RPCs, where previous the warnings field on the return, or on the
response from an RPC call was a single string.  And now instead, the warnings
field can take an array of strings.  So, if there was multiple warnings, you
could return all of them.  Dave, you wrote up all of these.

**Dave Harding**: Well, yeah.  So, this is just, it's actually possible for
multiple things to be going wrong with your node at the same time, or multiple
things to be going wrong with the network at the same time.  So, it's nice to
have an array of strings so each one of those can have its own unique message,
rather than us trying to cram them all together in one string, or just dropping
some.  So, this is just a nice update.  We like to put in the newsletter API
changes that might affect people.  And if you are running a node in a production
setting and you're pulling these RPCs to check the warnings field, you need to
know that the string is going to be updated to an array.

_Core Lightning #7111_

**Mark Erhardt**: Yeah, exactly.  Wonderful!  Our next change is to Core
Lightning (CLN), it's PR #7111, and it makes the check RPC command more
powerful.  So, apparently they have had for a long time already a command that
allows you to sort of dry-run another RPC command, and now a bunch of those
commands or checks would always succeed instead of actually checking what you
parsed them.  And this PR seems to improve a number of those and actually make
CLN check the input and return a proper response, instead of just trivially
always saying it worked.  Back to you, Dave.

**Dave Harding**: Yeah, that's correct.  So, the check RPC, like you said, you
want to run another RPC, one of the regular RPCs, and you just parse it with all
the parameters you want to use to the check RPC, and it will tell you if it's
malformed.  And the problem here was that CLN is built on a very extensible
architecture, it's very plugin-based.  But for plugins, for commands that were
not core commands to CLN, commands that were provided by a plugin, the check RPC
would always succeed.  It would go to the plugins, and it would say, "Oh, that's
a plugin", and just always succeed.  So now, plugins can specify the stuff
necessary for the RPCs to be checked with the check RPC command.

**Mark Erhardt**: I find it funny how similar this is to the OP_SUCCESS soft
fork hook.  We have a bunch of opcodes in tapscript, which always succeed.  As
soon as they appear in a script, they will make the node say, "Oh, this is a
valid transaction", or valid input, I should say.  And that allows us, of
course, in a future change to restrict when it succeeds, and that's, for
example, the upgrade hook that is proposed for OP_CAT that BIP that we recently
merged.  Anyway, that's fairly far out there.

_Libsecp256k1 #1518_

So, back to our news items.  Another code change that we're talking about is to
Libsecp256k1.  This is a cryptography library that is used by Bitcoin Core and
maybe other projects.  It is in C and does all of the heavy crypto lifting.  It
is heavily optimized.  Every once in a while, we have a news item here where
some signature operation gets a little faster and it turns out that it makes IBD
5% faster, and things like that.  That's the library we're talking about.  So,
they added recently a new function which sorts the pubkeys, a set of pubkeys,
lexicographically.  And this is, for example, useful for MuSig2 and for silent
payments, I believe.  Yeah, for silent payments, I think it's about having
multiple payments in a single transaction.  Yeah, anyway, Dave, do you have more
on this one?

**Dave Harding**: Yeah, so in Bitcoin for a long time, we've had people
implementing, I think it's BIP67, which is descriptor sortedmulti(), which will
put a set of keys into lexicographical order, and so that function, BIP67, is
for keys that appear in a script onchain.  But for MuSig2 and for silent
payments, we're going to be using keys that are not going to appear onchain.
And this is just a nice low-level function in secp that will allow you to sort
the keys.  And by sorting keys, everybody sorts them the same way.  You can
perform order-dependent operations on that sort.  Everybody does it the same, so
everybody gets the same outcome.  So, it's a feature that you could do at a
higher level, but doing it at a lower level just ensures everybody's doing it
exactly the same and there's no mismatches.  And if you have mismatches, I know
for silent payments, you're just going to miss transactions.  And for MuSig 2,
you might have a failure to be able to sign something to create a valid
signature.  So, it's just a nice function here.

_Rust Bitcoin #2707_

**Mark Erhardt**: Awesome.  Sorry to spring this on you, but may I punt the Rust
Bitcoin update to you directly?

**Dave Harding**: Sure.  So, Rust Bitcoin, well first of all, a historic problem
in Bitcoin, or not I'm going to call it a problem but a historic confusion in
Bitcoin, is that we display hashes for certain things in Bitcoin backwards to
the way they appear in actual serialized blocks and transactions.  And this has
to do with how Satoshi implemented proof of work in Bitcoin.  There's no
technical reason for it, it's just that he reversed things in order to be able
to compare proof of work as a numeric value.  And when the RPC interface was
added later, it took the resulting data and displayed it backwards.  And so,
this is very confusing to programmers, it doesn't really affect anybody.  But
when you see a block that starts with a block hash, it starts with 00000, the
way it appears in an actual serialized block, those zeros are at the end.

The Rust Bitcoin developers, of course they have to implement this for stuff,
but they don't want any additional hashes to be displayed backwards.  So, hashes
for new parts of Bitcoin that are being added because of taproot and other
things, they're going to try to get everybody to display them in the natural
order that comes out of that hash function.  So, this change here is a
backwards-incompatible change in their code with the way they were doing hashes
for taproot, but now they're going to display them in the way, I guess, that the
output of the hash function naturally is displayed.  Some people call this
endianness.  I've had other people yell at me because the output of the hash
function outside of proof-of-work context is not a number.  So, we call this
display order and internal byte order here.

Like I said, this is just a really low-level detail, but because if you've
already implemented taproot support using Rust Bitcoin, you might have to change
your code.  So, we put this right up in the newsletter, just so you are aware of
this and you can start testing out your code now.

**Mark Erhardt**: Well, thank you for adding all this color and I learned
something.  And also, this whole display order versus hashing order, output
order, it's a huge pain in the neck and it confuses a lot of people to no end.

_BIPs #1389_

So, next item is a PR to the BIPs repository.  BIPs #1389 adds BIP388, which
describes wallet policies for descriptor wallets.  Dave, would you happen to be
able to jump in meanwhile?

**Dave Harding**: I can certainly give it a try.  So, this is, I think of it as
a reduced set of features from output descriptors.  Output descriptors are
great, I think everybody loves them, but they are very broad because we want to
capture a lot of the flexibility of script itself, not the complete set of
flexibility, but as much of it as we can in a way that's easy to analyze by a
computer program.  But that brings its own challenges to people who are
implementing very secure wallets and wallets on limited devices, such as your
typical hardware wallet today.  All that flexibility, it can be just complicated
for the wallets to implement, so you want to simplify that set.  But a main
problem there is the user interface surrounding adding a wallet policy to your
hardware wallet.  So, how much data do we want users to type into their wallet
when they want to add a descriptor?  They want to be part of a multisig, or they
want to set up a support for Lightning on their hardware signing device, so they
want to do other things.  How much do we want them to type, and how much do we
want them to carefully verify?

In some cases, we're dealing with not very experienced users, so you want to
limit the amount of data here.  So, what BIP388 does is, it slightly reduces the
scope of the descriptor language, and it also fixes some of the data used in
there.  So, instead of allowing you to use any public key, you don't have to use
BIP32, you can use any path in BIP32 you want, you can use all this flexibility,
we're going to limit to certain paths in BIP32.  And we just have a few changes
like this that allow us to not display that information to users or display it
in a very compact form.  So, instead of displaying the entire BIP32 path for
verification, we just won't display the path at all because we're going to use
the standard path in every case where we're using a multisig object.

So, like I said, it's a reduced set of output script descriptors that hopefully
makes using a hardware wallet or another constrained computing and constrained
display device a lot easier for everyday users.

**Mark Erhardt**: Right, thank you, Dave.  So, BIP388 specifies a bunch of
templates on how to set up an output descriptor so it is especially
hardware-signer compatible.  And I think another part that was in BIP388 is for
stateless devices, obviously they wouldn't be able to store this policy that
gets added to the hardware signer.  Instead of needing to convince your hardware
signer every time that it should be aware of some sort of wallet policy, you can
register an output script descriptor policy with the hardware signer, and you
get a proof that the hardware signer itself registered it and it is its policy.
So, when you parse something to sign you, you just add that proof to it and the
hardware signer would know, "Oh, this is my own policy that I've agreed to
before", and would be able to display it in this more user-friendly manner.
Cool.

**Dave Harding**: I have to confess, Murch, I didn't actually know about that
bit there, that it could sign its own policy and then you could load it in
later.  That's a really nice feature.

**Mark Erhardt**: Yes, it's really cool.  Honestly, I actually reviewed this
last week because I was the one to merge this BIP.  Thank you for bridging over!
All right, we have two more.

_BIPs #1567_

One is another PR to the BIPs repository, this BIPs #1567.  It adds the BIP387.
I don't know why we have so many BIPs lately, it's really a lot of work, you
know.  This is about the multi_a() and sortedmulti_a() descriptors.  As some
people probably remember, when we introduced tapscript, we got rid of the
OP_CHECKMULTISIG opcode in tapscript, because it's not compatible with batch
verification.  Instead, we have a way of doing multisig based on OP_CHECKSIGADD
and OP_CHECKSIG, yes, I think that's right, OP_CHECKSIGADD.  And what it does is
it basically counts up the number of pubkeys and checks whether signatures are
there for everyone.  So, it's a different way of doing a multisig.  So, this BIP
specifies descriptors for this new way of doing multisig in tapscript.  We've
had that in a few newsletters already.  It's also been discussed on the mailing
list probably, but if you're doing multisig stuff with taproot-enabled wallets,
you're probably familiar with this BIP.

**Dave Harding**: Yes, and the only thing I would add is that we've had support
for this in Bitcoin Core for, I think, two releases now.  So, this is already
out there.  We're just getting, for some reason, these BIPs are just getting
merged all of a sudden; I don't know about that!

_BIPs #1525_

**Mark Erhardt**: Yeah, I don't know what happened there!  So, finally, there's
another BIP repository PR.  BIP347 got merged, which proposes a new opcode
called OP_CAT.  CAT is computer scientist lingo for "concatenate", which just
means combine two items by removing the space between them.  And OP_CAT would
basically allow you to combine the top two items on the stack to a single stack
item.  It would be enabled only in tapscript if it would be activated in a soft
fork.  So, you've probably seen a little bit of discussion about OP_CAT lately,
especially people that have been involved in the introspection and covenant
debate.  But also, for example, the BitVM proposal would benefit from being able
to combine stack items.  For example, this would allow you to create a merkle
proof in a transaction, or to check whether something was included in the
blockchain.  It is still probably extremely block-space intensive to use OP_CAT
to build more complex stuff, but it would also make a lot of things people are
already looking into way more efficient.

So, if this sort of development interests you, OP_CAT has been merged now.  It
is not BIP420, as you might have read on social media, It is BIP347.

**Dave Harding**: I don't have anything to add there.  We've talked about OP_CAT
a lot in the newsletter.  I just checked and gone all the way back to 2019.  So,
if you want to know more about it, you can read more about it in the newsletter,
or of course you can go read the BIP.

_Newsletter publication date changes_

**Mark Erhardt**: Yeah, so that would be all.  I don't see any speaker requests
right now.  We have one announcement attached to our newsletter at the bottom,
which is we are looking to experiment with the publication date of the
newsletter.  Dave, do you want to talk about this a little bit?

**Dave Harding**: Sure.  When I started writing the newsletter back in 2018, I
was only planning to do a couple of hours a week on it, and just to make sure I
was able to do it, I scheduled it on the weekend.  So, we kind of built the
newsletter around the idea that I would be writing it on the weekend.  But here
we are, six years later, and sometimes it takes more than a couple of hours to
write.  And so, I want my weekends back.  And so, we are playing around with the
publication date.  We're going to try to find a date that's good for me and is
good for all of our readers too.  And so, we're going to be sending the
newsletter out on different days and maybe doing some A/B testing, where we send
the newsletter to half of our subscribers on one day and half on a different
day, and to see how many of them open up the newsletter.

So, it's just a little experimenting.  Don't be surprised if you receive the
newsletter on a different day than you expect.  Don't be surprised if you hear
that other people have been reading it, but you haven't received it yet.  This
will only be a really short period of testing for us to figure out what the best
date is.  And again, we apologize for any inconvenience there.  Hopefully, in a
week or two, we'll publish another announcement saying we've permanently
switched to a different day for publication.  And thanks for reading, guys.

**Mark Erhardt**: Thank you so much, Dave, for writing the newsletter so
consistently, so long.  So, thank you very much for coming to listen to our
show.  Thank you to Calvin to be our guest, and my co-host, Dave, and for
writing the newsletter.  All right, hear you soon.

{% include references.md %}
