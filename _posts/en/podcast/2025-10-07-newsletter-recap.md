---
title: 'Bitcoin Optech Newsletter #374 Recap Podcast'
permalink: /en/podcast/2025/10/07/
reference: /en/newsletters/2025/10/03/
name: 2025-10-07-recap
slug: 2025-10-07-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Gustavo Flores Echaiz to discuss [Newsletter #374]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-9-7/408836702-44100-2-7efee2f0dfaf6.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #374 recap.
Today we're going to talk about the Script Restoration BIPs, we're going to talk
about a BDK wallet release, and also Release candidates from Bitcoin Core and
LND; and then, we have our weekly Notable code segment as well.  Murch and I are
joined again this week by Gustavo, who's going to help us out with the Notable
code segment that he authors.  Gustavo, you want to say hi?

**Gustavo Flores Echaiz**: Hey, everyone.  Hey, Mike.  Hey, Murch.

_Draft BIPs for Script Restoration_

**Mike Schmidt**: We have no news items this week so we're going to skip over
that section and go to our monthly segment on Changing consensus.  There was one
item that we covered this month titled, Draft BIPs for Script Restoration".
Rusty Russell posted to the Bitcoin-Dev mailing list four BIPs around what he
previously called the Great Script Restoration, or GSR, if you've heard of that
or seen some of the videos.  I think it was from BTC++ where he presented that
idea initially.  And of these four BIPs, the restoration portion of this set of
proposals is in the BIP titled, "Restoration of disabled script functionality".
In it, Rusty proposes re-enabling the Bitcoin Script opcodes that were disabled
in 2010 by Satoshi.  Satoshi disabled 15 opcodes back then in response to some
vulnerabilities that had come to light around Bitcoin Script and allowing
potentially DoS attacks.  I think there were some CVEs (Common vulnerabilities &
exposures) published about these and the DoS related to them.  So, Satoshi
disabled a bunch of them that could also contribute to similar DoS attacks in
the future.  So, those were turned off, I think it was 0.3.something, a commit
titled, "Mischanges".  So, that includes things like OP_CAT, that you've seen
folks talk about recently, the multiply and divide opcodes, among others.

So, it's in this first BIP that Rusty proposes to essentially re-enable all of
them.  And they would be re-enabled in a tapscript v2, so they would not be
available in legacy, for example.  So, I think coming out of that first BIP to
re-enable those that were disabled for DoS reasons is, "How do you address the
DoS concerns that were originally part of why they were disabled?"  And that
leads to the second BIP.  I'll pause quickly.  Gustavo and Murch, do you have
anything to add on that first one?  We can also tie it all together at the end
too.

So, the second BIP addresses that DoS concerns.  It's the BIP titled, "Varops
budget for script runtime constraint".  And in that second BIP, Rusty introduces
this idea of a varops budget, or the idea of assigning some sort of a cost
metric for each script operation.

**Mark Erhardt**: Short timeout here.  In our write-up in the newsletter, the
first BIP is the varops budget and the second one is the restoration of the
disabled script.  So, you're going in a different order?

**Mike Schmidt**: Yeah, I switched those first two.  I thought it made logical
sense.

**Mark Erhardt**: Okay, let's be clear about that for people reading.

**Mike Schmidt**: Yeah, if you're listening along and it doesn't make any sense,
I swapped the first two.  I thought for clarity that made more sense.  So, we
have BIP1 that turns back on these opcodes in some similar way to how they
operated back then.  Now, we have to address the DoS concern with this varops
budget.  And there was this line from the motivation section of the varops BIP
that I thought was descriptive, "This BIP introduces a simple, systematic and
explicit cost framework for evaluating script operations based on stack data
interactions, using worst-case behavior as the limiting factor.  Even with these
pessimistic assumptions, large classes of scripts can be shown to be within
budget (for all possible inputs) by static analysis".  And I don't know if it
was in the email threads, but I think previously, Rusty had posted a bunch of
data and analysis he had done to inform this varops budget.  I believe our Brink
engineering call we had with Rusty, he went through some of that.  So, if you
look at the Brink YouTube, you can see his discussion on some of the data that
he put in around that.

Murch, there's comments here about varops being similar to sigops.  Maybe you
want to just let us know what sigops are and we can extrapolate to varops.

**Mark Erhardt**: So, sigops (signature operations) are a cost function for
cryptographic operations and other things that happen in the Bitcoin Script, so
that very expensive operations cannot be overrepresented in script.  For
example, bare multisig is 80 sigops, regular multisig is 20 sigops, and so
forth, and this ties into the weight metric.  So, actually, when you have a ton
of sigops, they become the dominating factor and the perceived weight of
transactions becomes higher.  This notably has happened or tripped up a miner a
couple of years ago, when they included a ton of stamps in their block and
created a block that was consensus-invalid.

My understanding here is sigops have been around forever.  They got slightly
amended or extended, I should say, with the introduction of segwit, and again
with the introduction of taproot.  So, in segwit the sigops in witness data are
discounted just like the bytes in witness data are discounted.  So, they behave
similarly as witness data versus non-witness data, sigops and witness data
versus sigops and non-witness data.  And then, in taproot, the sigops changed in
the sense that the sigops now had a budget per input rather than for the whole
block only.  And now, from a brief read, I haven't fully gone through these BIPs
yet, I don't know whether people coordinate it, but we got over ten new BIPs in
the last few weeks and I'm catching up still.  So, anyway, the varops budget is
similar to the sigops budget, but it seems to be per-transaction limited, not
limited per input anymore, but across the whole transaction.  And the difference
here is that you wouldn't be able to have multiple very expensive inputs
because, well, with sigops and taproot, you would be able to have whatever fits
into the budget.  With varops, you could have one very expensive input, but then
other inputs that are not expensive would help pay towards that.  That's how I
understand it so far.

So, it seems like, for example, hashing everything is 10 times the byte in
varops limit.  So, if you want to hash a 520-byte stack object and it costs 10
varops per byte, that would be the limit of 5200.  Yeah, I have to read it more
carefully still, but it seems like, for example, if you hash a stack element
multiple times, that would be over the budget.

**Mike Schmidt**: And I think, big picture, that really what this is doing is
it's assigning some sort of a cost to certain operations in script such that it
limits the DoSsiness of a script, while potentially being able to now re-enable
these opcodes that were worried about being DoS capable, if you put them in the
right order.  Okay, so now we have this old script re-enabled, we have this
varops budget for constraining that script.  Go ahead, Murch.

**Mark Erhardt**: Yeah, thinking more about this, I'd very much like people like
Antoine Poinsot to chime in on this one.  He's been doing a lot of research in
the context of the consensus cleanup, how expensive it is to validate script,
and what could be done to limit how bad blocks could be for validation time.  I
think that would be in his wheelhouse for commenting.  Again, I haven't fully
caught up on the discussion, but I think it's not really gotten a ton of review
yet, so I'm sure we'll learn more about what people think about it.

**Mike Schmidt**: Yeah, and maybe to clarify also, these are in sort of a draft
state, varying degrees of draft, some more than others, which we can now comment
on the third and fourth BIP, which I guess I'm saying are somewhat unrelated to
the first two.  I think the idea is that they could be done all together, but
some of these stand up on their own as well.  The third is a proposal to add an
OP_TX introspection opcode, and that would also be added as part of tapscript
v2.  And the idea would be here that you could use this OP_TX to get fields of
the spending transaction onto the script stack, where you can then compare or do
other operations on them.  And you can pull one field or many at once.  And the
dotted line then to end user functionality would be something similar to what
you could achieve with CTV (CHECKTEMPLATEVERIFY) or TEMPLATEHASH, including
things like covenants as well.  So, that's OP_TX.  Gustavo or Murch, anything to
add there?

**Mark Erhardt**: Yeah, I mean, OP_TEMPLATEHASH is also similar.  I mean,
someone made this joke on Twitter recently about a jigsaw puzzle, "Dear Bitcoin
protocol developer, you're in an unlocked room.  Here's a proposal for a
covenant.  I dare you to leave the room without reinventing the covenant
proposal".

**Mike Schmidt**: Right!

**Mark Erhardt**: I mean, this is basically, I think the, the Overton window has
been shifting towards people actually wanting to have another covenant proposal
or introspection of transactions.  I think over the years, people have gotten
much more comfortable with the idea, less worried about recursive covenants,
especially given that that essentially could already be done with multisig.  But
there's still this debate on what flavor exactly is what we need and most viable
and least risky, and maybe someday we'll have a good overview of how they all
differ and what the trade-offs are and which one we should activate.  I wish
Brandon, who wrote this section this week, would be able to join us today
because he'd probably have a lot of thoughts on it.

**Mike Schmidt**: Yeah, he's got a pretty good perspective of all the different
proposals and the application of them.  But he couldn't make it today,
unfortunately.  But we thank him for authoring this segment this week.  The last
BIP also involves new opcodes being added to tapscript v2.  This last BIP is
titled, "New Opcodes for Tapscript v2".  It's the least finished of the BIPs, as
noted by the author, and it proposes six additional opcodes.  Rusty, in his
email about this BIP, noted, "Now for the least polished BIP, which proposes a
scattering of new opcodes.  These need not be deployed at the same time, and
some may not ever qualify.  But as they might have interactions with other
proposals, I feel we are obligated to peer over this horizon a little".  And so,
the six opcodes that he proposes in this last BIP, some folks may be familiar
with.  We have OP_CHECKSIGFROMSTACK (CSFS), which checks the signature against
the hash on stack; we have OP_INTERNALKEY, which lets scripts access the taproot
internal key.  Those two folks may be familiar with, and then there's four that
are maybe less familiar/new.  One is OP_SEGMENT, which enables appending of two
scripts, allowing a transaction to ensure that some conditions are met, but also
allow arbitrary script conditions thereafter.

**Mark Erhardt**: Wait, but it combines two things?  Isn't that just OP_CAT?

**Mike Schmidt**: I'm out of my depth on being able to double-click into that.
You can check out his write-up.  It's essentially like an opcode separator kind
of thing.  There's a start of the script and then you can sort of...

**Mark Erhardt**: Oh, it separates it into two stack elements?

**Mike Schmidt**: Yes.

**Mark Erhardt**: Oh, okay.

**Mike Schmidt**: So, one can evaluate the success, for example, and then the
transaction doesn't necessarily succeed because you have this second set of
script as well.  So, yeah, I'm sure you'll do a more thorough review as your BIP
maintainer role.  The next one is OP_BYTEREV, or byte reversal, for constructing
ordered merkle trees, as specified in taproot.  Similarly, the next one,
OP_ECPOINTADD, is required for constructing taproot spends.  And then, the last
one is OP_MULTI, which modifies the subsequent opcode to operate on more than
just the standard number of stack elements.  And my understanding, the
motivation there is that it's simpler than introducing general iteration to
script, but allows you to do iteration-type things, OP_MULTI.  And I believe
that OP_SEGMENT and OP_MULTI were called out in the newsletter by Rearden as
ones that might require actually their own BIP as well.  That was it for my
notes on this item.  I don't know if we have any big-picture thoughts on this,
Gustavo, or Murch?

**Mark Erhardt**: Well, very big picture.  I think it was AJ that said he
doesn't understand the naming of this BIP.  Grand Script Renaissance was right
there.

**Mike Schmidt**: GSR?  Another GSR.

**Mark Erhardt**: So, this is an extremely ambitious BIP, which feels
interesting because we've been fighting about several so much smaller-scope BIPs
for, like, five years now, and there's been insufficient support for really
moving forward on them.  So, it's funny that here, the reaction seems to be when
we can't activate a much smaller, simpler BIP with more narrow scope, let's do
something more ambitious, because surely everybody can see that this will be
more useful, but then probably also much more controversial.  So, anyway, I'm
looking forward to see what commentary these four BIPs will elicit, and
obviously I'll go through it for editor feedback.  But yeah, also consensus
changes is not really my main topic.  So, I will continue to not have a
super-strong opinion on covenants.

**Mike Schmidt**: Go ahead, Gustavo.

**Gustavo Flores Echaiz**: Yeah, I just had a question, I don't know if you guys
are able to answer it.  But one main thing I asked myself is, what is the
difference between this proposal and the previous Great Script Restoration
proposal?  Is it just a change in the opcodes that are used?  Because I see that
in the previous one, in the Great Script Restoration, we already had the varops
safety mechanism, so that remains the same.  And I believe it was already built
for tapscript, so I guess this is an important question to address.

**Mark Erhardt**: Right.  So, this is the same proposal, just in more detail.
In the previous iteration, when Rusty announced that he was working on this, he,
for example, hadn't defined how varops would work at all yet.  He just said,
"We'll probably introduce something additionally that will limit the DoSsiness
of these new opcodes.  And now, it sounds like he has taken the time to actually
write out his ideas in a more formal and complete manner.  Previously, it was
more of an abstract idea and some parts of it a little more concrete and just
generally what he wanted to do.  Now, it seems to be getting more concrete as a
proposal.

**Gustavo Flores Echaiz**: Makes sense.

**Mike Schmidt**: Yeah, Murch, you touched on all these different covenant
proposals.  There's obviously very specific ones, like OP_VAULT, and then you
start getting more generalized, CTV, and then you have soft fork proposals that
are completely new languages, like bllsh and Simplicity, and then maybe this
one's sort of in the middle, in that it enables a bunch of low-level things like
multiply, divide, concatenate, but then puts like a cap around what you can do
with it, so you sort of have maybe Swiss Army knife of different tools that
could be enabled with script restoration, I guess it's no longer Great Script
Restoration, it's just script restoration, that maybe fits somewhere in the
middle of that stack of ideas.

_Bitcoin Core 30.0rc2_

All right, I think we can move to the Releases and release candidates section.
We have Bitcoin Core 30.0rc2.  We've covered this a few times.  Murch, I think
it was #372 that you did it on the show.  I think, Murch, you were also on Pete
Rizzo's podcast, Supply Shock, and you went through some of that.  I see that
Antoine was also on What Bitcoin did.  I haven't seen if they talked about v30
yet.  But if folks are looking for an overview of the features, I would point
them to #372 or that Supply Shock episode with Murch.  Are we going to get an
RC3, Murch, is that happening before?

**Mark Erhardt**: Yeah, I think it's tagged already, actually.  There's
definitely at least two more PRs that are getting into 30, like fixes and stuff.
So, RC3 is happening right now.  And then, depending on whether there's
additional things that need to be changed, that might be the final or there
might be an RC4.  If it is the final one, people are gonna do their Guix builds
and so forth, and then we might see it properly released in the next week or so.

**Mike Schmidt**: Yeah, I posted about this the other day, because I think
people saw that original October 3rd date for tagging the final release, and
then I think it was changed to October 10th.  But regardless of when it's
tagged, there's also, like Murch mentioned, there's processes that happen after
that to actually get the binaries ready, so that's not necessarily the day that
you can go on Twitter to the Bitcoin Core handle and see that it is announced.
But there's sort of processes in between, so you can stay tuned there.

**Mark Erhardt**: Yeah I guess it's a little nuanced what you consider the
actual release date.  So, when it's tagged as the final, you would be able to
already take the code and build it yourself and you'd have the final code
running on your node locally.  But if you're waiting for the binaries, the Guix
builders, which are not necessarily developers, just people that want to
contribute to authenticating that the code built from the repository has a
specific shape and form and sign off on it, so Guix builds can take a few days
depending on the software.  It's basically a way of bootstrapping a system and a
build toolchain from very small dependencies, and then to build a deterministic
build together.  And then, you can compare that the binary that is built that
way matches the binary of other people that did the Guix build.  And that's what
a number of people do for the releases of Bitcoin Core.  They attest to a
certain binary and then that binary gets signed by each of them.  And you can
basically pick and choose which Guix signers you want to trust for the signature
verification of the binary.

So, yes, it'll be tagged final, then it'll be Guix-built by a number of people.
The binaries will be uploaded to the website, and then at some point around
then, there will be an update of the website announcing the release, and a
mailing list post.  And then, a number of people who maintain packages in, like,
Debian repositories and other systems would upload their binary releases to
these package managers.  So, it's a little bit of a window in which all of the
release process happens.  So, the tag is one thing, the final release being done
is probably a week later.

**Mike Schmidt**: Previous Bitcoin Core versions haven't had quite so much
interest in the precise mechanics of the release process, but I'm happy to see
that interest as a side effect of all this discussion.

_bdk-wallet 2.2.0_

Next release, this is bdk-wallet 2.2.0, "Includes a new feature for returning
events upon applying an update to the Wallet.  It also includes new test
facilities for testing persistence, as well as documentation improvements".
I'll also call out that this release notes that the signer module in bdk-wallet
has been deprecated and is planned to be removed in a future release.  So, if
you're someone using bdk-wallet and use that signer module, take a look at that.
Otherwise, 2.2.0 is ready for consumption.

_LND v0.20.0-beta.rc1_

LND 0.20.0-beta.rc1.  We noted in the write-up several of the high-level items
in the release.  But instead of sort of stealing their thunder, I hoped that we
could get one of the LND developers to hopefully join us when this is officially
released, to go through all the changes in this release and some of what they've
been working on over in LND Lightning implementation land.  So, hopefully we can
get somebody on and get a more in-depth version of this in the future.

Notable code and documentation changes.  I'll turn the mic over to Gustavo,
who's going to walk us through.  We have some Bitcoin Core PRs, a bunch of LDK
PRs, LND, BDK, and one to the BIPs repo.  Hey, Gustavo.

_Bitcoin Core #33229_

**Gustavo Flores Echaiz**: Thank you, Mike.  So, we start with Bitcoin Core
#33229.  So, this one is about implementing automatic multiprocess selection
when you use inter-process communication (IPC).  So, for users or node operators
that want to use Bitcoin Core with an external Stratum v2 mining service, the
IPC was introduced.  And you had to also specify the startup option, -m, which
meant multiprocess.  But it was already implied that by using IPC, you wanted
this, right?  So, to abstract this and to just make it simpler for node
operators, this option is now assumed.  You just have to pass IPC arguments or
set IPC configurations, and you can skip specifying the -m startup option for
multiprocess selection.  So, maybe not a huge change, but something that
improves the experience of those that are aiming to work with this multi-binary
process introduced in Bitcoin Core for Stratum v2.  Any thoughts here, Mike,
Murch?

**Mark Erhardt**: Yeah, important here is this is not going to be merged only to
the main branch, it's also going to be backported to 30.  So, this is one of the
things that is going into the 30.0 release, where we're introducing this IPC
interface specifically for people to experiment with Stratum v2 support in
Bitcoin Core.  And so, this will be in the upcoming release in the next few
weeks.

_Bitcoin Core #33446_

**Gustavo Flores Echaiz**: Awesome, thank you Murch.  So, we move on.  Bitcoin
Core #33446.  This one, it fixes a bug that was introduced when the target field
was added to the responses of the getblock and getblockheader commands.  So, the
bug was that it was always returning the chain tip's target.  So, even if you
were specifying block 800, 800,000 or block 100, you were always getting the
same response, well, at that precise moment, you were always getting the chain
tip's target.  So, the block that you were targeting wasn't making any
difference.  So, now, this fixes it to return the proper requested block's
target.  And the target field was added.  We covered that in Newsletter #339.
It was added in the PR that updated a bunch of RPC commands, mostly for the
implementation of Stratum v2 as well.  So, this one, paired with the previous PR
that I just talked about, also part of the Stratum v2 project to improve that
experience.  This was just a minor fix.  Any extra comments here?  Cool, we move
on.

_LDK #3838_

LDK #3838.  This one's a pretty interesting one for those that want to use LDK
as an LSP (Lightning Service Provider) node.  This adds support for the
client_trusts_lsp model for just-in-time (JIT) channels, as specified in BLIP52.
So, LDK was already supporting the lsp_trusts_client model, which is the
opposite.  So, the difference between these two models is that when you use
lsp_trusts_client, the LSP will broadcast the onchain funding transaction,
before the receiver reveals the preimage and claims the HTLC (Hash Time Locked
Contract).  So, this previous model puts the LSP at risk of committing funds to
an onchain funding transaction without having the guarantee that the receiver
node will reveal the preimage and claim the HTLC.  So, in a scenario where the
receiver would just not do this later, then the LSP has committed funds and
doesn't get paid later.

The new model, client_trusts_lsp, it's completely the opposite.  The LSP won't
broadcast the onchain funding transaction until the receiver reveals the
preimage required to claim the HTLC.  And at that moment, the client is fully
trusting the LSP to then open the onchain funding transaction and deliver the
funds to him.  But considering there's already trust related to LSPs, this makes
it safe for an LSP to use LDK to offer JIT channel services.  Yes, Murch?

**Mark Erhardt**: Sorry, that was not for you.

**Gustavo Flores Echaiz**: All right.

**Mike Schmidt**: Maybe one thing to note here.  I think before these LSP
specifications were rolled into the BLIPs, we covered them when they were under
their LSPS tag, so Lightning Service Provider Specification.  This was LSPS2
that we've discussed previously, but I don't actually remember that it
designated those different trust models, which makes a lot of sense and thanks
for explaining that, Gustavo.

_LDK #4098_

**Gustavo Flores Echaiz**: Awesome.  Thank you, Mike.  We move on.  LDK #4098.
So, this one is an update in the implementation of the next_funding TLV
(Type-Length-Value) in the channel_reestablish flow for splicing transactions,
to align with the proposed specification in BOLTs #1289.  So, basically what
this is, is when two nodes are communicating during a splicing transaction,
communication can be lost and we have to consider retransmission of commitment
signatures on restart.  So, for example, if you disconnect in the middle of the
signing steps of the interactive transaction protocol, you must retransmit the
signatures on reconnection to complete the protocol.  So, the nodes first
exchange the commitment sign, followed by the transaction signatures, and once
they have both sent and received the commitment signed.

So, previously, the commitment sign was always retransmitted on restart without
re-signing it, because it was assumed that it was properly signed.  Now, nodes
that come back on reconnection make sure that they have properly exchanged
everything that is needed, else they will just re-sign it and re-transmit it.
So, LDK just implements the specific part of this flow to the next_funding TLV.
Not a major change, because previously covered in Newsletter #371, LDK had
already done work on this flow, but just an extra addition here to pair with the
proposed specification change.  Any thoughts here, Mike, Murch?

**Mike Schmidt**: Yeah, that BOLT proposed spec change is the BOLTs #1289 that
updates the, I think it's BOLT2, the peer protocol.  And yeah, it's an open PR
now.  I assume that's because they're waiting for multiple implementations to
have this rolled out, or at least code-ready for that.  So, it's an open PR to
that spec.

**Gustavo Flores Echaiz**: Yeah, just want to add that this BOLTs proposal
replaces a previous one, on #1214, which had proposed a similar flow, but the
previous #1214 has now been replaced by the newly proposed #1289.  So, it was
proposed just last month, so we haven't seen many responses from other teams
yet, but that's probably just imminent soon.

_LDK #4106_

We follow on with LDK #4106.  This one's an interesting race-condition fix that
relates to async payments.  So, in an async payment flow, when a receiver is
offline, the LSP will hold on to the HTLC on behalf of the recipient until the
recipient comes back online.  However, if the recipient comes back online too
fast, there can be a race condition where the LSP would fail to release the HTLC
because he wouldn't be able to locate the HTLC.  And this happens because the
LSP assumed, before this PR, that the HTLC would be in the
pending_intercepted_htlcs map.  However, to get to that map in that node's
storage, the HTLC's onion has to be decoded, and maybe that takes a couple
seconds or milliseconds.  But if the recipient came back online way too fast,
the LSP wouldn't have time to decode the HTLC and move it to the
pending_intercepted_htlcs map.

So, what LDK #4106 does is fix this race condition but making the LSP check for
the HTLC in both the pending_intercepted_htlcs map, but also in the place where
he keeps HTLCs before decoding their onion.  So, this allows the HTLC to be
found because the lookup is done in two different places, and it can then be
released to the async payment's recipient successfully.  Any extra comments
here?  No?  We move on.

_LDK #4096_

LDK #4096, this is a change in the limit of the gossip outbound queue per peer.
So, if you're a peer of an LDK node, you would be limited, previously to this
PR, to a 24-message queue limit.  So, if a node is already queuing gossip
outbound messages to you, there would be a limit at 24 messages.  If it exceeded
that limit, the new gossip forwards would be skipped until the queue drained.
However, this PR updates this from a 24-message limit to a 128 kB size limit.
So, now it's a size question instead of an amount of messages, and this makes
much more sense because messages vary in size.  You see an increase from around
24 to 80 messages on average.  So, this has significantly reduced the missed
forwards of the previous implementation, and allows for more successful
communication of these forwards and a better way to account for the resource
consumptions of a node.  The node doesn't really care about the number of
messages, it cares about the size of the messages.  So, this makes a lot of
sense.  Any extra comments here?  All good.

_LDN #10133_

We move on to LND #10133.  This one adds an experimental endpoint called
XFindBaseLocalChan alias, which what it does is returns a base short channel ID
(SCID) for a specified SCID alias.  So, on LND and other node implementations,
and I believe on the BOLT spec, a node can give a peer or another node an alias
for its SCID.  So, an LND node would have to set this in advance, would have to
set this alias with a different RPC.  And with this new experimental RPC
endpoint, if it has the alias, it can recover the base SCID.  The way it
succeeds at doing so is because this PR also extends the alias manager to
persist the reverse mapping when aliases are created, enabling the new endpoint.
So, the flow is you as a node, you've got a SCID of another node, and you use
another RPC command to give that alias.  At that moment, the alias manager will
persist the reverse mapping so that later on, you could use this experimental
RPC new endpoint, called XFindBaseLocalChanAlias, to return the base SCID for
the specified alias.  Any extra comments here?  All good.

_BDK #2029_

We move on with BDK #2029, which introduces a new struct, called CanonicalView.
So, what this will do is it will perform a one-time canonicalization of a
wallet's TxGraph at a given chain tip.  What is canonicalization?  It is to
resolve the conflicts of a wallet, so removing previously, let's say, we replace
transactions.  If a mempool has two transactions that conflict, that
canonicalization will resolve those conflicts and remove the transactions that
it shouldn't keep in its mempool anymore.  And that will do it one time at a
given chain tip, and the snapshot powers all subsequent queries, eliminating the
need for re-canonicalization at every call.  So, before this, every time you
would want that canonicalization feature, you would have to execute to redo it
at every call.  And this just makes it so that you can have a static snapshot,
and then you can power all your subsequent queries with that.

So, the methods that require canonicalization now have CanonicalView
equivalence, and TxGraph methods that took a fallible ChainOracle are removed.
So, previous methods are now removed.  Yes, Murch?

**Mark Erhardt**: Yeah, just for the context here, if a wallet uses a lot of
transactions over time, this would introduce a huge cost for these calls.  So,
if you maintain this CanonicalView, it's probably pretty cheap to make the
amendments when just one more block of data comes in.  So, this both makes the
overall cost smaller because you just have to update your CanonicalView, I'm
just guessing, I didn't study this in detail; but also, instead of reordering
your transactions every single call, you do it once per block.  So, it becomes a
per-call to per-block cost reduction.  And then, by having the CanonicalView in
the first place, it probably also becomes only a slight amendment rather than
redoing all of the work each time.

**Gustavo Flores Echaiz**: Yeah, that's exactly it.  So, the goal here is to
just increase the performance, right, to avoid repeating work and to provide a
static snapshot at every block, or at least the given chain tip you want.  We
covered work on canonicalization previously done on BDK in Newsletters #335 and
#346.  So, this is a follow-up to that previous work.

_BIPs #1911_

Finally, last PR, BIPs #1911 marks BIP21 as replaced by BIP321, and updates the
latter BIP121 status from draft to proposed.  So, BIP321 is a modern URI scheme
for describing Bitcoin payment instructions.  BIP21 was made in a moment where
Lightning didn't exist, where silent payments weren't a thing, or even other
types of payment instructions didn't exist.  So, BIP321, it modernizes and
extends the previous BIP, it keeps the legacy path-based address, but
standardizes the use of query parameters by making new payment methods
identifiable by their own parameters.  And one important thing is also that it
allows the address field to be left empty if at least one other instruction
appears in the query parameter.  Any extra notes here, Murch?

**Mark Erhardt**: Yeah, for a little more context, so BIP21 is an ancient
proposal from 2012, and it had long been used somewhat open-ended, because
clearly it didn't specify anything about segwit or taproot or all the things
that came after 2012.  I think even P2SH might have been after that, or maybe
not.  But anyway, people had sort of naturally extended the use of BIP21,
allowed other address types in the fields where it wasn't clearly specified
because they didn't exist in 2012, built in Lightning support, which didn't
exist in 2012, and so forth.  So, the original authors of BIP21 were Nils
Schneider and Matt Corallo.  And this last year, Matt took another stab at it
and wrote up all of the things people were already doing based on BIP 21, and
specified them in BIP321, and basically rolled good recommendations and an
overview of what has been happening in the last 13 years into the new rewrite.

BIP321 is now proposed.  I think it's pretty mature.  It might be already
implemented by some, but it should also be mostly backwards-compatible with what
were the best practices in wallets.  So, probably most wallet developers just
want to check whether they are spec-compliant with BIP321 and update their
information, what BIPs they implement from implementing BIP21 to BIP321 when
they do.  Yeah, so as always, we've been having a lot of new BIPs in the last
year and a lot of updates to BIPs.  If you're curious, you can find the stuff on
the BIPs repo.  There's also a couple websites that aggregate the information
and present it in a slightly more browsable fashioned in a repository, like
bips.xyz and bips.dev.  So, if you're following that, we talk about it on the
repo and on the mailing list.

**Gustavo Flores Echaiz**: Thank you, Murch.  That's awesome.  Yeah, so that
completes the whole Notable code and documentation changes for this week.

**Mike Schmidt**: Awesome.  Gustavo, thanks for authoring that and then jumping
on to walk us through.  That wraps it up.  We had no other guests this week, so,
Gustavo, thanks for joining us, Murch, thanks for co-hosting, and thank you all
for listening.

**Mark Erhardt**: Yeah, thanks, Gustavo, that was great.

{% include references.md %}
