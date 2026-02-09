---
title: 'Bitcoin Optech Newsletter #390 Recap Podcast'
permalink: /en/podcast/2026/02/03/
reference: /en/newsletters/2026/01/30/
name: 2026-02-03-recap
slug: 2026-02-03-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Gustavo Flores Echaiz are joined by Liam Eagen to discuss [Newsletter #390]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-1-4/417471955-44100-2-2e5373c39796b.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mark Erhardt**: Good morning.  This is the Bitcoin Optech Newsletter Recap for
Newsletter #390.  We are today not joined by Mike, so I get to do the honors of
leading us through the newsletter today.  But we are joined by a guest, which is
Liam.  We will be talking about the news item that is Argo.  And we also have an
update on LN-Symmetry, the regular segment of Selected Q &A from Bitcoin Stack
Exchange, a single Release, and a few Notable code and documentation changes.
I'm also joined by Gustavo.  Do you want to introduce yourselves, Liam?

**Liam Eagen**: Sure.  I'm Liam, I have recently published this Argo work with
Ying Tong Lai.  It's like a new garbling scheme.  It's in the sort of family of
BitVM-type protocols, if people are familiar, there's been this newer version of
BitVM that uses garbled circuits that reduces onchain costs a lot.  I had
previous work called Glock that was similar to this, but Argo is a new garbling
scheme that's even better.  So, that's what I've been working on lately.

_Argo: a garbled-circuits scheme with more efficient off-chain computation_

**Mark Erhardt**: Great.  Right, we're jumping right into the News section here.
The first item is Argo, which Liam is already starting to talk about.  We had
Liam on, I don't even remember, a few months ago to talk about Glock, which was
a garbled lock scheme that was about, I think, a thousand times more efficient
than other approaches to BitVM at that time, because it made use of applying the
assumptions to all parts of the setup.  But now, you're back and you have an
even better algorithm, or not algorithm, maybe scheme.

**Liam Eagen**: Yeah.

**Mark Erhardt**: Do you want to introduce it yourself or should I give my
high-level overview?

**Liam Eagen**: Go ahead.

**Mark Erhardt**: All right.  So, my understanding is that you discovered or
came up with a way of translating the algorithmic operations of an algorithmic
circuit to elliptic curves.  And now, you can do basically the encoding of an
algorithmic circuit with elliptic curve operations.  And this makes it very
efficient to encode on the wire and allows you to more efficiently calculate all
of the stuff that was happening in the garbled locks before.  And that's roughly
where I got, and the rest of it is all the moon math stuff that you can tell us
about now.

**Liam Eagen**: Yeah.  So, the basic primitive that we want in these kinds of
protocols is a conditional disclosure of secrets.  So, there's one party that we
call the operator, or the garbler in this case, who will provide a proof; and if
that proof, this is like a zero-knowledge proof, is invalid, then somebody else,
the evaluator, should learn his secret.  So, it's like conditionally revealing a
secret if a proof is invalid.  And there are several approaches to this that use
different variants of these garbled circuits protocols.  My previous work on
Glock had a special type of designated verifier SNARK.  There's also the work of
the BitVM Alliance to implement a Groth16 verifier using a garbling technique
called Yao.  And that had garbling table sizes of about 50 GB.  And with Argo,
we can also construct a garbled circuit for a Groth16 verifier, but our garbling
table is about 15.5 MB, so it's more than 2,000 times smaller.

**Mark Erhardt**: Okay.  So, just to recap, the basic idea is if the other party
cheats, you learn a secret and you can take their money or some sort of
collateral they put up.  So, pretty much similar to LN-Penalty in the LN.  But
the things that you can express are much more complicated.  You can express all
sorts of smart contracts or other conditional phrases.

**Liam Eagen**: Yeah, exactly, anything you can make a proof about.  So, one
application, like in the BitVM space, people are focused on making bridges.  So,
you'd have a bridge that verifies some L2 side system thing, and, yeah.

**Mark Erhardt**: Right, so you made the proof tables about 2,000 times smaller.
You can express roughly the same things and support the same things.  Are there
any downsides to this?  Is this way more computationally intensive, or something
like that, or is it just an improvement?

**Liam Eagen**: So, to the point about computational cost, it's actually much
cheaper.  I don't have the most recent Groth16 garbling times on hand, but I
think it's roughly this order of magnitude.  It's like 40 seconds to generate a
Groth16 Yao garbled circuit; and an Argo garbled circuit takes about, I think,
16 milliseconds.  So, it's also many orders of magnitude faster.

**Mark Erhardt**: Holy smokes.  That sounds like quite the breakthrough then.

**Liam Eagen**: Yeah, it's very exciting.  I think it uses some really cool
techniques, and it's very nice.  I've enjoyed working on it.  The only downside
is that the representation that you take the proof as input -- so, we're talking
about a garbled circuit.  This garbled circuit takes an input.  The input is a
proof.  In the Yao-based schemes, it's feasible to accept a proof with what we
will call compressed points.  In Argo, we don't know how to do that yet.  So,
the size of the proof has doubled.  And this translates to increased onchain
costs.  So, I don't know, I mean there's a bunch of other details, but basically
it's roughly double the amount of data onchain.

**Mark Erhardt**: Double the amount of data, but I believe the prior improvement
was that it was much smaller onchain.  That doesn't seem super-bad.  Wasn't it
something like you could now express it in 80 bytes?

**Liam Eagen**: So, the reduction from BitVM2 to garbled circuit schemes like
Glock or BitVM3 was, I think, about 500X less data.  And I guess, I probably
should have this, but I think that it's about 10 kB you'd put onchain,
thereabouts, maybe 20 kB, something like that to commit to a proof.

**Mark Erhardt**: So, this is not just when there is a penalty scenario or
someone cheating, but actually just using it always requires 10 kB, which means
it's pretty expensive.

**Liam Eagen**: So, this is one piece of larger protocols, and there are a lot
of degrees of freedom in how one designs these BitVM bridges.  It's possible to
design the bridges such that in the happy path, if nobody disputes the proof,
then you don't have to put the 10 kB onchain.  Although, you could design it in
such a way where you always put the 10 kB onchain.

**Mark Erhardt**: Right, I mean if you can avoid it, you'd probably want to,
although cheap block space is the topic of the time, I guess.  Right, okay, so
do you think you could give us a very short explanation of what the difference
between a binary circuit and an arithmetic circuit is?  Or is it maybe not that
important?  I don't know.

**Liam Eagen**: No, I think it's not too bad.  People might've heard of a binary
circuit.  You think of a circuit has gates and it has wires.  Each wire in a
binary circuit is either 0 or 1.  It can take on one of two values.  And each
gate is like a logical operation.  So, like taking the bitwise AND or bitwise
XOR, or something like that.  In an arithmetic circuit, you instead allow your
wires to take on a larger set of values.  So, you think like values in a finite
field like mod p.  Then you can have gates that operate on mod p values.  So,
you can add or multiply wires in a single gate.  The crucial trick that Argo
exploits is we actually -- so, you can go from binary to finite fields, but then
you can even go further and imagine that a wire takes on an elliptic curve
point.  And now, your gate might be adding two elliptic curve points.  And the
nice thing about these SNARK verifiers is that they're very algebraic.  So, all
of the operations, well, more or less all of the operations that the SNARK
verifier circuit does are things like add curve points or evaluate pairings over
curve points.  And so, by working with these arithmetic circuits, you have very
few operations.

**Mark Erhardt**: Right.  It sounds like expressing something in an algorithmic
circuit instead of a binary circuit would make you need a lot fewer gates,
because you can express more complex operations in each gate.  And then, being
able to translate it to elliptic curve points sounds like it would be much more
efficient to calculate on them.  So, that's sort of also what I got out of the
writeup.  But overall, that sounds like a huge breakthrough.  Does that mean,
when we talked last time, I think you said something that Glock would take
several more years until there would be anything coming out of it in terms of
production-ready products or schemes; does that mean that you made a big step
towards using this?

**Liam Eagen**: Yeah, I think so.  One really nice property that Argo enables
that other schemes don't is permissionless evaluation.  So, in the Glock scheme,
the garbler, the person who provides the proof, is fixed in advance, but so is
the person who is able to challenge an invalid proof.  This person is also fixed
in advance.  With Argo, we can remove the second constraint.  So, anybody can
challenge an invalid proof.

**Mark Erhardt**: That sounds very useful.

**Liam Eagen**: Yeah.  The obstruction to doing this in the past was the
extremely large amount of data that you'd need for all of these garbling tables.
So, by making them 2,000 times smaller, it's possible to design bridges that
support permissionless challenging, or at least get much closer to that.

**Mark Erhardt**: Well, 15.5 MB doesn't sound bad at all.  And yeah, anybody
being able to challenge it makes it a lot more approachable to systems with a
lot of users, I'd say.  So, my understanding is, I hope my listeners are not
going to burn me at the stake now, my understanding is that Citrea is using a
BitVM-style bridge.  Is this the sort of thing that would be at the end of your
research efforts, or what do you envision will this enable?

**Liam Eagen**: Yeah, Citrea is using BitVM2.  So, speaking for myself, the
motivation for working on these BitVM-style bridges is that with Bitcoin as it
is now, this is the closest we can get to a bridge that would verify Shielded
CSV.  And that's earlier work that I did with Robin Linus and Jonas Nick, and
that would allow for very efficient private payments on Bitcoin.  And so, that's
what I'm interested in doing.  But I guess to answer your question, yes, Argo
can be used to construct a better bridge than the BitVM2 bridge that Citrea
uses, just across essentially every dimension.  So, it'd just be cheaper and
more operators, more efficient, etc.

**Mark Erhardt**: Right.  And when you're talking about scalable, cheap private
payments, I know that Shielded CSV uses basically a nullifier.  So, it reminds
me a little bit of the scheme that shielded transactions in Zcash use.  I think
it's essentially an account-based model and you can move funds in this, well,
shielded account, or whatever, by making your Shielded CSV transaction, and
people just learn that whatever you did was valid.  So, do you have more insight
on how that all works?  We haven't had anyone talk about Shielded CSV in a
while.

**Liam Eagen**: Oh yeah, sure.  So, yeah, I think that's a fair, accurate
summary.  Shielded CSV is, well, CSV stands for Client-Side Validated.  So, it's
one of these client-side-validated-type protocols which have existed for a long
time in the Bitcoin space.  But it uses SNARKs to recursively compress the
transaction history.  And it's true, every transaction puts 64 bytes onchain.
It's a bit of a weird thing, but it's like a nullifier plus a signature
compressed into a single thing.  And from the nullifier, nobody learns anything.
They don't learn your identity, they don't learn the structure of your
transaction.  All of that's kept offchain and proved offchain.  And so, I think
these protocols are cool.  They're still kind of research-y.  I don't know that
they're ready for someone to seriously start productionizing.  There's still
some research-type questions in my mind.  But yeah, in comparison to, say, Zcash
or Monero, where the transactions are published into the mempool and then put
onchain, Shielded CSV reduces the onchain footprint by a lot.  I think an
Orchard transaction on Zcash is something like 5 kB and I don' know how big
Monero transactions are, but probably similar order of magnitude.

**Mark Erhardt**: That sounds pretty cool.  And I'm sure that there's at least a
bunch of people that would be excited to see more private payments on Bitcoin.
There's this lawsuit going on with the very private contract on Ethereum.  What
was it called?

**Liam Eagen**: Oh, Tornado Cash?

**Mark Erhardt**: Thank you.  Tornado Cash.  Sounds like a little bit like
Tornado Cash, right?  You put the funds in, you see it on the input side, and
then if it ever comes out of the Shielded CSV, client-side validation universe,
it would be completely disconnected.  Is that apt comparison?

**Liam Eagen**: Yeah, I think so.  I mean, there's a bunch of these things.
It's like, that's sort of how the shielded pool on Zcash works.  Similarly,
money moves in and money moves out.  But yeah, that's how it would work.

**Mark Erhardt**: Okay, well we got a little sidetracked here talking about
Argo.  You put your paper out, you said there's another paper coming soon.  Is
there anything else that you want to share about this work, or any call to
actions?

**Liam Eagen**: Yeah, so I'm working actually with Robin Linus and my co-author
on Argo, Ying Tong.  We have a company called Ideal Group, and we are looking to
build a bridge using Argo.  So, we've implemented Argo, or at least we haven't
audited it yet, but I think it's quite production-ready, or close to it.  And
then, we want to implement the bridge.  So, I guess if people are interested in
that, we'd like to chat, and we'd ultimately really like to see this get used
for Shielded CSV.  So, after we make the bridge, we want to make the Shielded
CSV part.

**Mark Erhardt**: Okay, that sounds good.  Maybe some of our listeners will
become aware of you that way.  Have you, well, this can get very philosophical,
so if you don't have an answer, please feel free to say so, but this sounds sort
of like it might move a bunch of transaction activity and blockspace consumption
towards these sidecar systems or sidechain systems.  Have you any opinion how
that might influence the dynamics of the blockspace market, or like Ethereum got
very top-heavy at some point, right?

**Liam Eagen**: What do you mean top-heavy?

**Mark Erhardt**: Like, more of the economic activity happened on second layers
than on the base layer, and it sort of caused security and finality issues in
some sense.  Ethereum got less valuable compared to all the tokens on top of it.
There can be some interesting dynamics there.  Have you guys looked into that in
the pursuit of your bridge?

**Liam Eagen**: Yeah, it's a good question.  I'm not an expert on these types of
things, but I do think some things I've heard while being involved in this BitVM
kind of work.  I think the case of Ethereum and the case of Bitcoin are somewhat
different in that the L2s for Ethereum don't, well, I don't know.  I mean, I
don't want to make too strong of a claim, but they don't really fundamentally
offer more expressivity, right?  On Ethereum, you can do anything that you can
express with a smart contract.  Whereas if you're adding something like private
payments or even DeFi stuff to Bitcoin that's not possible on the L1, you can
make the blockspace more valuable.  So, even if the L2s were just buying
blockspace, that could increase aggregate demand for blockspace.  I don't know
if you'd see the same effect that you're describing on Bitcoin.

**Mark Erhardt**: Yeah, I guess because Bitcoin doesn't actually permit all of
these things, the cannibalism wouldn't be the same way, where on Ethereum, just
the things that were happening on Ethereum before outright moved to the
sidechains and because it was cheaper or compressed in the terms of transaction
fees, or I guess, gas; and in Bitcoin the base layer is just, we prove that
something happened correctly.  So, we can't do a lot of the things.  Yeah, I
don't know.  Maybe we, we can find some other people that have spent more time
on focusing on that issue and they can weigh in on this.  All right.  I think
that's it from me about it.  Gustavo, do you have any questions or comments?

**Gustavo Flores Echaiz**: No, I think this was pretty clear.  Thank you so
much, Liam, for taking the time to explain this to us and good luck with the
Ideal Group, with your company.  I'm looking forward to seeing the next paper
you guys will publish that hopefully just closes the loop in towards making Argo
a viable bridge.  Thank you.

**Liam Eagen**: Thank you.

**Mark Erhardt**: Yeah, thanks for joining us and congratulations on becoming a
founder.  All right, you're free to hang on.  We do have actually later a
question about Shielded CSV and actually, if you want, I'll just pull it up
right now.

_Can one do a coinjoin in Shielded CSV?_

So, one of the Stack Exchange questions was, "Can one do a coinjoin in Shielded
CSV?" to which Jonas Nick pointed out that Shielded CSV basically updates
singular accounts, and therefore there would not be a huge improvement where you
would expect that Shielded CSV always takes 64 bytes, but that is because each
nullifier only updates one account.  So, if you have multiple participants in
order to create a multi-account setup, you'd have multiple onchain transactions
to set it up.  Do you think that Shielded CSV would be a viable way of mixing or
coinjoining, or what do you think about that?

**Liam Eagen**: I think what Jonas said sounds right to me, that when you have
multiple parties, you have multiple onchain transactions.  I think I would ask,
like taking a step back, what are we trying to do by doing a coinjoin with
Shielded CSV?  Because the protocol itself is already private.

**Mark Erhardt**: Right.  Essentially, everything going into and then coming out
of Shielded CSV is a ginormous coinjoin, isn't it?  Not necessarily the amounts
are equal, but yeah, it's just one black box that things go into and out of.
That's a fair point.  All right.  I have one more actually that, well actually,
I've got that one.  Thank you for joining us, thank you for your time.  If you
want to hang on, you're free to do so, but if you have other stuff to get to, we
understand.

_LN-Symmetry update_

All right, moving on, we have a second news item.  And unfortunately, Greg
Sanders was not able to join us today, but he made an update to his prior work
on LN-Symmetry.  We reported on that over 100 newsletters ago, in Newsletter
#284, so that's two years roughly.  Greg rebased his work, his initial proof of
concept for LN-Symmetry, and put out a new client or implementation for signet.
So, my understanding is that it's now good enough to test on Inquisition.  He
improved that anchor bumping works now.  You can make transactions, use P2A to
expedite them.  And he also was experimenting with LLM-supported development,
vibe-coding an implementation based on OP_TEMPLATEHASH, OP_CHECKSIGFROMSTACK
(CSFS), and OP_INTERNALKEY which is not quite ready yet and also can't be used
on Inquisition yet, because TEMPLATEHASH isn't live on Inquisition.  But yeah, I
haven't seen too much replies on that yet.  I was hoping to pick Greg's brain on
this, but he was unfortunately not able to join us.  So, that's all I have for
you on this topic.  Gustavo, did you take a better look at that?

**Gustavo Flores Echaiz**: I took a little bit of look.  Well, it's good to see
that at least he has updated his proof-of-concept work.  I think the last time
he did this was about two years ago, so LN and Bitcoin both have changed a lot
since then, so this just rebases it to the latest changes.  I just think the
next step would be to get OP_TEMPLATEHASH inside Bitcoin Inquisition, and that
way, the whole thing can be tested together.  So, that step seems to be missing.
I don't think Sanders has any control on that.  But besides that, this is a huge
advance compared to the previous state of the proof of concept from two years
ago.

**Mark Erhardt**: Well, I don't know about no control.  Greg is one of the
co-authors of OP_TEMPLATEHASH and Inquisition is pretty accessible to PRs adding
experimental soft forks.  So, I guess it might be work that still needs to
happen, but once someone gets to it, hopefully that would happen.  Well, maybe
just as a recap, we talked about this a little bit last week with René, but
LN-Symmetry, the big advantage would be, with LN-Penalty, the current channel
update mechanism, where the commitment transactions are asymmetric in order to
allow one side to punish the other side for publishing an outdated state,
LN-Symmetry uses symmetric commitment transactions, where every participant of a
channel has exactly the same commitment transaction.  And it updates to the
correct latest state by simply overwriting prior versions of the commitment
transaction.  So, if someone publishes an outdated state, any other channel
participant can just override it with the newest state and thereby enforce the
actual channel state.

The huge advantage of this is that it would allow multiple participants in a
Lightning channel, which with LN-Penalty would be very difficult, because the
asymmetry is not easy to break out into more parties, and it is very difficult
to assign blame when an old state is published, which party should lose their
funds, and how those funds are distributed to the other parties.  In a
two-participant scenario, it's always clear, there's a blamed party and it
defaults to giving all the funds to the other party.  In a multiparty channel,
who would get the money?  So, there are some other trade-offs and some people
are generally super-concerned about not having a penalty mechanism, what new
dynamic that might open up.  But if you assume that we haven't seen the penalty
used that much and it would still work without a penalty system, this could give
us channels with many different parties.  Of course, not too many, because setup
and updates to the channel would require all the parties to be online and to
participate.

But a Lightning channel that has five parties, for example, would satisfy money
allocation to all of those five parties among those five parties.  So, it would
be much more cost-efficient and liquidity-efficient because you don't have to
tie up funds for five times, what is it?  Five times, four times, is it five
faculty channels?  Anyway, 120 channels or so become a single five-party
channel, and you can just shift money between all of those five parties, which
sounds super-cool and much more efficient.  Any further thoughts on LN-Symmetry?

**Gustavo Flores Echaiz**: Yeah, isn't another benefit also the reduction in
required storage for LN nodes, which would allow eventually even maybe hardware
wallets to run like LN node software?  Because from what I understand, the
current LN storage growth is linear.  And however, for LN-Symmetry, it would
just be constant.  You simply replace the older state with new state, and you
can just use Lightning within simpler devices such as hardware walls.

**Mark Erhardt**: That's a really good point.  Yes, with LN-Penalty, you have to
hold on to every previous state of every channel.  And you would actually also
want to hold on to all of the HTLCs (Hash Time Locked Contracts) that were on
those prior states.  So, if an old commitment transaction with HTLCs were
broadcast, you would be able to execute the HTLCs on that too.  But with
LN-Symmetry, the problem of storing a backup becomes much simpler because having
an old, outdated state doesn't put you in the position that you might lose all
of the funds in the channel by accidentally broadcasting it.  So, it becomes
more secure or easier for backups.  And on the other hand, you only need to keep
the latest state, so storing the state of your channels is much easier.  And I
don't know if we've ever discussed this here on the show, but I just thought
this is maybe an under-discussed aspect of splicing.

When you splice an LN-Penalty channel, your backup is reduced to a fresh start,
because you have a new channel now, all of the prior history is sort of
finalized.  And I hadn't even ever considered that, but basically splicing-in
funds or splicing-out funds, once the splice is confirmed onchain means that
your backup state is reset and you can throw away the old backup, which is kind
of cool.

_What is stored in dbcache and with what priority?_

All right let's move on to the selected Q&A from Bitcoin Stack Exchange.  So,
the first question that we have here is, "What is stored in dbcache and with
what priority?"  The user that asked this question was talking about running
their node intermittently about 10% of the time, and they had a lot of memory,
64 GB, and wanted to be able to have the entire UTXO set in memory to make the
node behave as efficiently as possible.  But unfortunately, that's not how
Bitcoin Core does things.  The dbcache only stores the UTXOs that are necessary
to validate currently unconfirmed transactions.  So, any transactions a node
learns about and needs to check the inputs on, for those inputs, it will
retrieve the UTXOs from disk and put them into the dbcache.  And then, for any
blocks that are processed that create new transaction outputs, it will also put
those transaction outputs into the dbcache.

The UTXO set, I've said this quite a few times here on the show, but the UTXO
set is actually stored on disk by Bitcoin Core, and only the UTXOs that are
relevant to the transactions and blocks that we're currently processing will be
loaded.  Yeah, I think that was roughly that question.

_Can one do a coinjoin in Shielded CSV?_

Next question is, "Can one do a coinjoin in Shielded CSV?", which we already
discussed with Liam a little bit.  But basically, the idea here is we have a
client-side validated system where funds are flowing in a basically
account-based model.  And we only put proofs onchain that whoever spent money in
the client-side validated universe did so correctly and was authorized to do so.
And basically, the whole thing is a ginormous coinjoin itself, not same amounts,
but a black box.  Things go in and go out.  Also, this is currently a paper.  It
sounds like Ideal might be working on making this a real thing eventually.

_In Bitcoin Core, how to use Tor for broadcasting new transactions only?_

Okay, question number three, "In Bitcoin Core, how to use Tor for broadcasting
new transactions only?"  So, Vasil Dimov, the author of the private broadcast
feature that will be released in Bitcoin Core v31, responded to this old
question by pointing out that in Bitcoin Core v31, the private broadcast feature
will become available, which we discussed two weeks ago, that was Newsletter
#388, where we will make an ephemeral connection to a Tor node through the Tor
network, or to a clearnet node through the Tor network.  And we just basically
handshake with the node, hand it our transaction, and then disconnect.  And we
do this several times until we see the transaction come back to us organically
on the P2P network through the gossip.  And once we see our own transaction come
back to us, we forward it as if we had just learned about it.  So, yeah, this
old question got a new answer because the feature people were asking for is
finally coming out.

**Gustavo Flores Echaiz**: Yeah, it was published more than five years ago, and
it seems like the person asking the question exactly wanted this feature.  And
now, the feature is out and perfectly answers this question.

_Brassard-Høyer-Tapp (BHT) algorithm and Bitcoin (BIP360)_

**Mark Erhardt**: Right, and five years in Bitcoin time is almost a whole
lifetime.  So, they were just ahead of their time, I guess.  In question number
four, we have someone asking about the Brassard-Høyer-Tapp (BHT) algorithm,
which apparently is an algorithm to find hash collisions.  And they are
wondering whether this could be used to diminish the security of addresses in
Bitcoin.  And the user, bca-0353f40e, points out that existing addresses cannot
be attacked with this algorithm because the algorithm can only be used to create
colliding addresses, and both of the collision partners or colliding addresses
have to be rolled at the same time in order to make the algorithm work.  So,
existing addresses cannot be.

_Why does BitHash alternate sha256 and ripemd160?_

Final question from this Bitcoin Stack Exchange, "Why does BitHash alternate
sha256 and ripmed160?"  Sjors asked and answered this question, and he had this
question in the context of BitVM3, which has the BitHash function.  The takeaway
that I had from reading his answer is that there are very few functions, opcodes
on Bitcoin Script right now that can interact with 32-byte numbers.  And one of
them is SHA256 and the other one is RIPEMD.  But RIPEMD only returns a 20-byte
result.  So, by alternating these two, it enables the users or the creators of
BitVM3 to change.  I should have asked Liam about this now that I think about
it!  Either way, the alternating algorithms allow for a change to happen.  If
you fed single bytes into one algorithm always, it would return the same thing
apparently, and that's not useful.  One downside is that you lose 12 bytes,
because RIPEMD only returns 20 bytes.  But honestly, I'm a little out of depth
on that question.  That's all I have.

_Libsecp256k1 0.7.1_

All right.  This brings us to the Releases and release candidates segment.  This
week, we have for you only Libsecp256k1 0.7.1, which is a maintenance release
for the library.  I looked at the changelog.  It looks that predominantly there
are two things changed here.  There's a new unit test framework, and this unit
test framework allows the tests to be run selectively and in parallel, which
sounds very useful if you're working on libsecp.  And there was a performance
issue fix, which made it if there was a flag present on the compiler, I think,
then it would use a slower -- would default to a C Compiler or something.
Anyway, works faster now, and just maintenance release, no biggie.  Did you have
more on this one?

**Gustavo Flores Echaiz**: No, just I think it's a pretty minor release, minor
one for people that are using it.  There's an increase in the number of cases
where the library attempts to clear secrets from the stack.  I think this was
one of the major issues it had before.  And also, it's fully backwards
compatible with the previous version.

**Mark Erhardt**: Yeah.  Oh, talking about the ABI, I don't remember,
something-interface, it is backwards compatible.  There are no breaking changes
in the interface.  All right.  Over to you, Gustavo, Notable code and
documentation changes.

_Bitcoin Core #33822_

**Gustavo Flores Echaiz**: Perfect.  Thank you so much, Murch, for leading the
way.  This wasn't an easy newsletter, a lot of complex topics in hand.  So, now
we start the Notable code and documentation changes section with two PRs around
Bitcoin Core.  The first one, #33822, is an update to the libbitcoinkernel API
interface.  And for those of you who don't remember what libbitcoinkernel is,
It's an interface that allows external projects to work with Bitcoin Core's
block validation and chainstate logic via a reusable C library.  So, this allows
you to simply leverage Bitcoin Core's kernel, or central engine, around block
validation and chainstate logic and you don't have to deal with the remaining
parts of Bitcoin Core.  And this PR, specifically what it does is that it adds
block header support by adding not only a block header type, but a lot of
methods associated to creating headers from 80-byte serialized data, copying
block headers, destroying, and then also obtaining all the attributes of a block
header, such as the version, the timestamp, the previous blockhash, the
difficulty target, and so on.

The other important part of this PR is the header processing methods.  So, two
new methods are added which allow you to validate and process block headers
without requiring the full block.  And the second one returns the block tree
entry with the most cumulative PoW.  So, you basically get anything you need to
work around block headers with this improvement.  So, now, through the
libbitcoinkernel API interface, you can do pretty much anything that is required
for working with block headers.  Any extra thoughts here?  Perfect.

_Bitcoin Core #34269_

We move on with Bitcoin Core #34269.  This is an important PR because it follows
a bug that came up a three newsletters ago, where if you were migrating a legacy
wallet that was unnamed and the migration failed at the same time, you could see
your funds disappear.  So, this was a bug that was present in v30 and v30.1, and
specifically v30.2 fixed it.  I just want to reiterate that this was a very
low-likelihood issue that would only happen if your wallet wasn't name and
something went wrong during migration.  So, what this new PR does, #34269,
actually it's miswritten here, but the question is that this disallows creating
or restoring to unnamed wallets.  You can still restore old legacy unnamed
wallets, you can just not create new unnamed wallets or restore an old one and
keep it as unnamed.  So now, you're forced to name your new wallets when you're
using createwallet, restorewallet RPC commands, as well as the wallet's tool,
create and createfromdump commands.  The GUI, the graphical user interface
already enforced this restriction, but the RPCs and underlying functions did
not.  But just to make clear that you can always restore legacy unnamed wallet,
you can just not create new unnamed wallets through the RPC methods.  Yes,
Murch?

**Mark Erhardt**: Right, so we have been requiring wallets to be named for
several years now, and that is sort of becoming an assumption about wallets that
they do have a name.  So, basically, we move here to just disallowing the
creation of new wallets without a name.  And, yeah, Gustavo already mentioned
the context with the wallet bug.  Please, if you haven't heard it yet, do not
attempt to migrate your wallet with Bitcoin Core v30.0 or 30.1.  There was a
bug.  If you have a very old unnamed wallet, it might delete your wallet
directory if something fails during the migration and you have this unnamed
wallet situation.  So, if you update to v30.2, this problem has been mitigated.
Just as a reminder, please do not try to migrate wallets with v30 and 30.1.

_Core Lightning #8850_

**Gustavo Flores Echaiz**: Thank you, Murch.  We move on with Core Lightning
#8850.  This is just a PR that removes features that were previously deprecated.
These were, for the most part, very old features that had mostly been renamed or
some things had been changed on the specification so it had been given a new
name, which what are we talking about specifically?  The
option_anchors_zero_fee_htlc_tx was a previous version of the current anchor
outputs implementation.  So, I believe these were all deprecated on v23.  And
also, decodepay RPC is replaced by just decode.  Some fields called tx and txid
in the close command are replaced by txs and txids, so these are mostly naming
changes.  And finally, the last one, estimatefeesv1 was just an original
response format to return fee estimates in the bcli plugin, which is the plugin
from Core Lightning (CLN) that interfaces with Bitcoin Core.  So, this was the
last one, just simply an original response format that was later updated.  So,
here just a regular maintenance PR that removes several deprecated features that
had been deprecated for several versions already.

_LDK #4349_

We move on with LDK #4349.  Here, some validation code is added to ensure that
when LDK parses an offer, it will make sure that it follows all the bech32
padding rules, as specified by BIP173.  So, previously, LDK would accept offers
that had invalid bech32 patterns.  However, Eclair and Lightning-KMP, which are
other implementations, would correctly reject them.  So, the changes are that
when Rust LDK will receive an offer and will start parsing the offer, it will
call validate_segwit_padding() to ensure that the offer corresponds with the
correct padding.  And the correct padding is that the end of the offer or any
bech32 format, the last part must be either 4 bits or less or must be all zeros.
So, now LDK will properly validate the padding around offers.  And I believe
also, the PR was open in the BOLT specification, PR #1312, so that a test vector
is added on BOLT12 to check for invalid bech32 padding.  Perfect.

_Rust Bitcoin #5470_

We move on with two PRs from Rust Bitcoin.  So, over the past few weeks, we've
seen Rust Bitcoin add multiple PRs that simply enforce protocol rules for proper
validation of Bitcoin transactions.  For example, Rust Bitcoin #5470 in this
newsletter adds validation to the transaction decoder to reject transactions
with zero outputs now, because obviously valid Bitcoin transactions must have at
least one output.

_Rust Bitcoin #5443_

And the second one, Rust Bitcoin #5443, here validation is added to reject
transactions where the sum of the outputs exceed MAX_MONEY which is 21 million
bitcoin.  This check is related to the value overflow incident, which I believe
was one of the first bugs in Bitcoin, CVE-2010-5139, to be precise, which was
the historical vulnerability where an attacker figured out how to create
extremely large output values that surpass the amounts of possible bitcoins in
existence.  So, these are just maintenance features added to Rust Bitcoin.  Yes,
Murch?

**Mark Erhardt**: The sequence of all of these PRs introducing checks for
consensus rules makes me think that there is a new contributor to Rust Bitcoin,
just going through all the old CVEs and checking that they also are fixed in
Rust Bitcoin!

**Gustavo Flores Echaiz**: Yes, it could very well be because these are all done
by the same person, jrakibid.  He basically first opened an issue, he ran some
test vectors on Rust Bitcoin, and found all these issues, and now is going at
fixing one by one.

**Mark Erhardt**: Wow, cool.  That's good work.

_BDK #2037_

**Gustavo Flores Echaiz**: Perfect, thank you, Murch.  We move on with BDK
#2037, where a new method called median_time_past() is added to calculate the
median-time-past (MTP) for CheckPoint structures.  So, MTP is the median
timestamp of the previous 11 blocks, and is used to validate timelocks as
defined by BIP113.  So, in Newsletter #372, we covered how BDK refactored
several types and structures to be in preparation for enabling cash merkle
proofs, but also MTP.  So, a few newsletters later, now the method for
calculating MTP is added as a follow-up on that.  Any thoughts here, Murch?

**Mark Erhardt**: Do you know what the CheckPoint structure is in the context of
BDK, because Bitcoin Core recently removed the CheckPoints?  And there's other
things that use MTP in Bitcoin Core, but CheckPoints aren't even there anymore.

**Gustavo Flores Echaiz**: Right.  No, to be honest, I believe it's not related
to the checkpoints.

**Mark Erhardt**: Maybe that's just a data structure in BDK.  But anyway, MTP
is, for example, also used by locktime transactions.  There's two different ways
of doing CLTV (CHECKLOCKTIMEVERIFY).  One is height-based, one is MTP-based.
And the proposed consensus cleanup soft fork, BIP54, is also proposing an
MTP-based rule around the zeroth block or the first block of a new difficulty
period.  So, presumably anyone that is looking into these things might also want
to have MTP functionality.

**Gustavo Flores Echaiz**: Yeah, I found a description for it.  So, basically,
here is an issue in BDK that explains the CheckPoint design.  So, "At its core,
CheckPoint represents a sparse, singly-linked chain of block references used to
track which blocks we know about, detect reorgs by finding points of agreement
between local and remote chains, and anchor transactions to specific blocks, and
also calculate MTP time".

**Mark Erhardt**: Okay, so it just is a name for a construct in BDK and doesn't
have anything to do with the CheckPoint as we think of them, as points in the
blockchain.

_BIPs #2076_

**Gustavo Flores Echaiz**: Exactly, that's exactly right.  Thank you, Murch.
So, we finish off this newsletter and the code and documentation changes section
with two PRs merged in the BIPs repository.  The first one, BIPs #2076, adds
BIP434 to the BIP repository.  BIP434 defines the P2P feature message that
allows peers to announce and negotiate support for new features.  So, in about
four newsletters ago, in Newsletter #386, we covered that Anthony Towns had
posted to the Bitcoin-Dev mailing list about his proposal for this BIP, and now
it's merged.  So, what this proposal is, is that it's a generalization of the
P2P feature message.  As previously proposed in BIP339, instead of requiring a
new message type for each feature, this is a single reusable message format for
announcing and negotiating any multiple P2P upgrades.  So, this could benefit
the proposal we've talked about previously as well, which is peer block template
sharing, that mitigates problems with divergent mempool policies.  So, you can
check out #386 for more context on this.  Yes, Murch.

**Mark Erhardt**: This is notably a huge improvement over the current mechanism
of how we negotiate features, which is whenever there's a new feature on the P2P
layer, you update the version number of the protocol, the P2P protocol to be
clear, and you assume that anyone that has updated to a specific version number
of the P2P protocol will understand these messages, even if they don't have the
feature.  Instead, having the BIP434 P2P feature messages, you will now be able
to communicate with your peers; well, if it gets adopted, to be clear.  You can
communicate which features you support, and if there's multiple different modi
in which you can run those features, you can communicate about what version of
it you would like to use.  So, the idea is to make it much more flexible and to
be able to communicate about what features your node supports, and then
coordinate with your peer whether or not you will be using those features.

**Gustavo Flores Echaiz**: Is it correct to say that this is a proposal that
looks to, let's say, create a sort of layer between different implementations of
a Bitcoin node?  So, for example, if, let's say, we all use Bitcoin Core, then
we can know which features we support by Bitcoin Core version; but would it be
correct to say that this allows for different implementations of node software
to communicate on the support of features?

**Mark Erhardt**: Right.  This is going to be very helpful if there's more
different node implementations or if nodes have services or features that other
implementations do not have.  So, for example, in ancient times, I think it was
Bitcoin Unlimited, or something, had a P2P service where you could request UTXOs
from a node.  And there was another one.  Anyway, this would make it much more
flexible, or even just you could fork Bitcoin Core and add a feature to it and
then use this feature message to communicate with peers about it.

_BIPs #1500_

Thank you, Murch.  So, the last one in this list is the BIPs #1500, which adds
BIP346, which defines a new opcode, OP_TXHASH, that allows to create a covenant
and reduce interactivity in multiparty protocols.  This opcode generalizes
OP_CTV (CHECKTEMPLATEVERIFY), and when combined with OP_CSFS, can emulate
SIGHASH_ANYPREVOUT (APO).  Maybe, Murch, you want to give us a deeper dive into
what all this means.

**Mark Erhardt**: Yeah.  So, TXHASH had long been discussed as a more general
way of doing CTV, and the author finally came back and finished up the proposal.
So, I think this, this has been discussed for two or three years and it finally
was ready for publication.  So, it just came out last week, I think.  Anyway,
the general idea here is that you can use a flag array to indicate which
properties of the transaction that spends a UTXO have to have certain
characteristics, and then you can provide those characteristics.  So, where CTV
I think basically commits you to a very stringent template, the TXHASH opcode
would allow you to set what parts of the templates are being enforced for a UTXO
that's being spent with TXHASH.  Well, that's roughly all I have here.

Anyway, yeah, we got two new BIPs published recently.  There's a couple more
coming soon, I think.  It always helps when people read those BIP drafts and
leave their comments and thoughts.  Or once you're published, if you want to
keep abreast of what people are proposing, they are reasonably mature.  So,
these are pretty readable now, if you want to catch up.

**Gustavo Flores Echaiz**: Thank you, Murch.  Listeners can read the newsletter
or listen to the episodes #185 and #272 for previous reference on this opcode.
So, it was first introduced in #185 and in #272, we already had the draft BIP.
So, this BIP has been in proposed mode for at least almost three years,
two-and-a-half years, so it's great to finally see it being merged.  Thank you,
Murch, for your explanations and also for merging these BIP PRs.

**Mark Erhardt**: I only reviewed them.  The authors wrote them, so kudos to
them.  Thank you very much for joining us to this newsletter recap.  Thank you,
Liam, for explaining Argo to us and answering some of our other questions about
cryptography and wicked moon math schemes.  And thank you, Gustavo, for taking
care of the Notable code and documentation changes as usual.  We'll hear you
next week.

**Gustavo Flores Echaiz**: Thank you.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
