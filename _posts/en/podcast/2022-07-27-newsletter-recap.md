---
title: 'Bitcoin Optech Newsletter #210 Recap Podcast'
permalink: /en/podcast/2022/07/27/
reference: /en/newsletters/2022/07/27/
name: 2022-07-27-recap
slug: 2022-07-27-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Ruben Somsen to discuss [Newsletter #210]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-9-2/349466320-44100-2-84da4b27742f9.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Quick introductions.  Mike Schmidt, contributor to Optech for
the last few years, and also Executive Director at Brink, where we try to fund
open-source Bitcoin developers.  Murch, you want to give a quick intro?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.  I co-host New York
BitDevs.  I'm a moderator on Stack Exchange, and I try to chime in here and
there, also at Optech.

**Ruben Somsen**: Yeah, and I'm Ruben, I do a lot of layer 2 Bitcoin-related
stuff.  Currently my project is spacechains.  I'm currently sponsored by Spiral
and Superlunar, working on spacechains for Bitcoin.

**Mike Schmidt**: Excellent.  Well, this is the first time we've done something
like this.  I thought it would be useful for the community to be able to have a
discussion around the newsletter if there's things that folks have questions on
or comments on, engage the community, and also give some of us an excuse to dive
even deeper into some of this tech to be able to speak about it.  So, if it's
useful for people and we get good feedback, I'm happy to host these into the
future; and if not, it's a fun experiment regardless.  I guess we can just jump
in.  I'm sure we'll get detoured along the way, but if we just sort of walk
through Newsletter #210, and we can start at the beginning and take tangents
accordingly.  I did invite Ruben on to speak to one of these news items, which
is proof of micro-burn, because I saw he was contributing on the mailing list on
that discussion.  I also invited theStack, although I think he is intermittently
connected on a train right now, so he may not be able to contribute.  We'll just
jump in.

_Multiformat single-sig message signing_

Multiformat single-sig message signing.  So, what I'm thinking of when I'm
reading this is this whole generic message signing versus, well, what would be
the alternative to a generic message signing?  Well, specific message signing,
which I guess would be signing in regards to a transaction, which obviously
Bitcoin Core has the capability of doing.  But this generic message signing
would be something that would enable you to sign to prove that you have control
over a specific address.  Perhaps one use case for that could be proof of
reserves for an exchange.  Another use case mentioned in the mailing list by
Ryan Grant was something around decentralized identifiers and authentication
around there, which I'm less familiar with.  Ruben or Murch, are there other use
cases for generic message signing that you can think of?

**Mark Erhardt**: When I was working at a company, we were thinking about a use
case where if we could identify that the recipient of a transaction was also a
customer of the same company, we could prompt that the receiver sends a message
that provides a Lightning address instead, and then transfer the funds in
Lightning instead.  So generally, it can also be used to associate one identity
with another identity for the purpose of, for example, changing brands.

**Mike Schmidt**: Ruben, any of your creative mind share towards message
signing?

**Ruben Somsen**: No, this is not really something I've given a lot of thought,
so I have nothing to add.

**Mike Schmidt**: Okay, great.  Well, I think, I'm not totally sure on this, but
I know one of the early Satoshi clients supported message signing.  I don't know
if that was in the original release, but that only supported P2PKH, so I guess
that was in a future release, and since there's been no additional support for
other address types, which is essentially the motivation behind this mailing
list post, and also the motivation behind a different proposal, which is BIP322.

**Mark Erhardt**: Yeah, I think the general idea for BIP322, this is a proposal
by Kalle Alm, was that we were going to make basically vanity transactions that
just commit to a message and then instead of signing UTXOs that you're spending,
you would sign the address that you're trying to prove belongs to you, as well
as a message in the output.  Since we would be using the same paths as signing
for general transactions, it would require not that much modification for other
parties to verify whether or not this is a correct proof of address ownership.

**Mike Schmidt**: And so the thing being signed is not just some general message
like, "Hello world", but it's structured in the form of a transaction, is that
right?

**Mark Erhardt**: Yeah, it would be structured in the form of a transaction.
I'm not completely sure on the details.  I think that the address that you're
signing for would appear, or is committed to, and you can also have a custom
message.  So, for example, if you wanted to use this for proof of reserves, you
could state what company you are and what amount of funds you're trying to prove
ownership over.

**Mike Schmidt**: And it sounds like some in the industry have already started
supporting signing and verifying outside of just P2PKH addresses.  There was
some chiming-in of Coldcard saying that they're already doing some of this for
non-legacy addresses, and then Sparrow chimed in that they're also doing
something similar.  Murch, I know you kind of have a wiki in terms of support of
things like bech32 and bech32m support.  I don't think that you have anything or
any insight into support for any sort of message signing, is that right?

**Mark Erhardt**: No, I'm not super-involved in that unfortunately.  I had a
professional interest for a specific project a while back, but since then I
haven't really looked at it.

**Ruben Somsen**: There is maybe one interesting tangent that I can mention,
which is that Adam Gibson, he posted a proposal called RIDDLE, where he's
suggesting because we have taproot and the public key is now exposed, you can
make a ring signature over a bunch of outputs.  And so, it's not exactly proof
of ownership of one specific output, but it's proof of ownership of one of a set
of outputs, and this could be used for maybe private proof of reserves, things
like that.

**Mike Schmidt**: Okay, yeah, that's interesting.  I don't recall that proposal,
but yeah, that would definitely apply here.  I know BIP322, obviously it has a
BIP, it has a PR that's open, and it seems that both BIP322 and this proposal
are trying to tackle single-sig and not multisig at this time.  Although I think
some original ambitions for generic message signing did include
multisignature-type signing and verifying.  Any comments on the multisig, Murch?

**Mark Erhardt**: Maybe I misremembered, but I thought that BIP322, being
defined generically, essentially just makes everybody sign exactly how they
would sign for spending an output to that address, so it would be the same for
multisig or single-sig.  And if the vanity transaction had a valid signature
with whatever type of output it is signing for, it would be satisfactory.  So, I
honestly haven't looked too much into it, but I think that it should also work
for multisig.

**Mike Schmidt**: Yeah, I think you might be right on the BIP.  Now, I think
that the existing PR, this #24058 that's open now has a note that limitations or
missing features include, I guess, complete proof of fund support, as well as
multisig or other custom address types, and then timelocks as well, another
wrinkle to this whole thing.

**Mark Erhardt**: All right, that's quite possible.  Perhaps we move on to the
next one?

_Proof of micro-burn_

**Mike Schmidt**: Sure, yeah, we can talk micro-burn.  So, the second news item
in Newsletter #210 is Veleslav starting a thread on the mailing list.  And the
idea that I took away was, how can we have a scalable way to prove that you've
burned some bitcoins instead of a bunch of, I guess, individual one-off
transactions and outputs to prove that you've burned something.  For example,
ways to burn would be using OP_RETURN.  That would be, I guess, a provable way
to burn.  And there's also a 1BitcoinEaterAddressDontSend, which is literally
the name of the address, which is another burn destination, although I don't
know if that is provably burned.  That address actually has, I think, something
like 13 bitcoin in there currently.

So, this proposal is a way to say that you've burned some bitcoins for a variety
of potential purposes, and then trying to figure out a way to do that in a
scalable way.  And specifically, Veleslav has an interest in some of these
smaller micro-burn-type use cases.  I know in the past, proof-of-burn use cases
included things like, there's been proposals to use proof of burn as opposed to
proof of work, for example.  I know that some of the one-way peg chains used
this, and Ruben, you can speak to this a bit, but I think one of the oldest ones
was Counterparty using proof of burn in order to issue their Counterparty tokens
on launch, and then some of the hashcash-type solutions for anti-spam
mechanisms.  But Ruben, I know you've explored this space a bit with regard to
your spacechains and statechains.  Maybe you can give a more comprehensive
overview.

**Ruben Somsen**: Sure, I'll try and go through it.  So, yeah, I mean everything
you said was correct, so that's all, but I'll try to take a different angle and
talk a bit more about it.  But yeah, the basic idea is that you might want to,
just like the original hashcash idea from proof of work, where you could use it
as a potential way of avoiding spam in your email inbox, where whenever someone
wants to send you an email, first they have to do a bit of proof of work and
they attach that proof of work to the email and then your email clients will
say, "Okay, well this one had enough proof of work, so I'll show you the email".
And if they don't perform enough proof of work, then you just don't get the
email.  And then potentially, this could solve the spam problem, because then
you no longer have this issue where one person can create one email and send it
to billions of people at no cost, because every email now needs to have a bit of
proof of work attached to it.  And then maybe one thing specifically to point
out there is that you need the proof of work to be performed on top of the
purpose.  So, you can't just have them create some proof of work and then
generically attach it, no, the proof of work has to be performed on top of, for
instance, my email address.  So I know that this person was trying to send it to
me and so they can't reuse the proof a billion times.

So, this specific concept can basically be reapplied to Bitcoin and taking some
bitcoins, destroying them or burning them, as we call it, and then creating an
SPV proof.  At least, that will be sort of the simplest way of doing it for the
clients at least to check the proof of work.  So, you could have an SPV proof
that proves that a certain transaction was made that destroyed a certain amount
of coins.  And then this is, for instance, an OP_RETURN that points to the hash,
and then that hash, for instance, has the specific email address for the
intended recipient.  And then, so instead of the proof of work, you attach the
proof of bitcoins being burned, which can be quite succinct using SPV proofs,
which is basically some headers and a merkle proof.  And so, doing it that way,
you could sort of have the same thing without needing to perform the proof of
work yourself.

That can particularly be beneficial when you think about ASICs where all the
spammers, they might have ASICs and the regular users might not have ASICs, and
so now you're back to this problem where the spammers can spam and you cannot;
you sending an email is sort of expensive.  So, this is sort of an equalizer in
the sense that using bitcoin means that you're sort of outsourcing the proof of
work, right?  The creation of the bitcoins was what required proof of work, and
now it's just up to you to take that bitcoin and then destroy it again and
submit the proof.  So, that's the use case, right, that's what you can do with
it, or at least one kind of clear-cut use case.  And the problem with this is
that it's not very scalable if you want to send an email and even a dollar would
be a bit much for an email, but let's say you want to burn a dollar; okay, maybe
that's possible today, but you're already paying significant transaction fees as
opposed to the cost of a dollar.  And in the future, if fees go up, it
completely becomes unviable.

So, this thread was basically about, how do we do this in a way that scales
better?  And the basic idea that I had thought of before and after Veleslav
posted this, and he was definitely sort of thinking in the right direction but
he hadn't quite, I think, put everything together, and since I had thought about
it, I basically posted kind of how you can do it.  And essentially, what you can
do is instead of burning a single amount for a single purpose, you can burn a
single amount for multiple purposes.  And then you could have some aggregator
take these different use cases, put them in a merkle tree.  So, let's say I'm
the aggregator, and maybe Murch and Mike, they sent me a hash and they pay me a
little bit over the LN.  Let's say they pay me 100 sats each or something.  Then
I burn 200 satoshis to combine the two and I put a single hash there that is a
merkle hash that points to their two hashes.

That is sort of one way of doing it, but that's actually insufficient because
now, okay, so you have a proof and you have two hashes, but you don't really
know what amount corresponds to which hash, and you need to know that as well.
Because otherwise, both Murch's hash and Mike's hash could claim to have burned
199 Satoshis and just say, "Oh, the other one was just meant for 1 sat", or
something like that.  And because we're talking about a merkle proof, currently
we just have two hashes in there, but if it's a bigger tree, you don't want to
have to reveal every hash.  That would be one solution, to just reveal every
hash and within every hash, there's an amount, but that's not scalable.  That
sort of defeats the whole purpose of having a Merkle tree in the first place;
the whole purpose of the Merkle tree is you don't have to revel everything, but
you can still say something about what was included in the commitment.

So, the solution to this is a so-called merkle sum tree, which is basically like
a merkle tree, but it has amounts where basically as you go up the tree, you add
up all the leaves.  At the end, at the top of the tree, you come up with the
total amount.  Then your Merkle proofs basically also become a sum proof, a
proof that you have a specific allocation off the total, and your hash
corresponds to that specific allocation.  And so, with those two things
combined, you can basically have these methods of allowing aggregation of a burn
proof.  So, a single person could burn and put a merkle tree in there and it
could have 1,000 little, smaller burn intentions, and this can all be proven
with SPV proofs, because basically the SPV proof is a merkle proof, and then the
burn proof, it's also a merkle proof, and so it can still be quite efficient.
And so that's sort of one way of making this more efficient.

But what was also pointed out in the thread, and it's important to realize, is
that this is not a trustless exchange where the aggregator could potentially
take your sats over the Lightning Network and then not actually perform the
burn.  But then it was Peter Todd who said, "Well, we're talking about smaller
amounts here and the aggregator is not going to -- if it's a bigger amount, you
can just do the burn yourself maybe, but for smaller amounts, this kind of trust
requirement is really not very significant", and I'm inclined to agree with
that, where it's fine if you just have these sort of micropayments that are
being aggregated.

So that's really the bulk of the thread.  And then one thing to add to that,
that I think we shouldn't get into now, is that my spacechains proposal is
basically a way to take this burning mechanism entirely offchain and have a
secondary chain on which people can burn.  And so, that would sort of reduce the
scalability requirements even further, where you don't even need an aggregator
putting a transaction on the Bitcoin blockchain, but that transaction can take
place on a completely different chain.  And that different chain, in the case of
spacechains, actually has tokens that are literally derived from burned
bitcoins, so that is sort of what makes it possible.  I think that's a little
high level, but I think that's enough for this discussion.

**Mike Schmidt**: So, there's actually a data structure that is this merkle-sum
tree that conveniently would support not only attaching these hashes but
attaching values to each leaf in that merkle tree, which would then allow you to
prove not just the hash but the amount associated with that hash; is that right?

**Ruben Somsen**: Yeah, that is exactly correct.  And it's also something
that's, for instance, being used in RGB and Taro because they also sort of need
something similar.  I mean, that's a little too hard to go into, I guess, but
it's a similar structure.

**Mike Schmidt**: Is there anything that's not Lightning-based to do the
aggregation?  I mean, obviously Lightning is a good candidate since we would be
talking about smaller, as this mailing list post suggests, these sort of
micro-burns, but is there a way to do that outside of the Lightning Network,
some sort of coordinating and then putting it onchain like, I don't know,
coinjoin-esque type things?

**Ruben Somsen**: Yeah, well the problem with this is sort of that the
aggregation needs to take place somewhere else, because if you do it onchain,
you could save on outputs, but now you have a whole list of inputs, , so your
transaction size will still increase.  And it's sort of a middle ground, I
guess, where you could do it like that, but then everybody needs a change output
as well probably, so it gets messy like that.  So it kind of comes back to,
okay, we have a use case, and now we want to pay for the use case.  Well, how do
we pay for the use case?  Well, Bitcoin solves that problem, right?  So, it's
sort of like we get a chicken-and-the-egg thing going on there.  So, I think the
Lightning Network is particularly well suited for that, but look, it could also
be a PayPal transaction, it doesn't really matter, it doesn't really matter how
you pay the third party.  But yeah, that's sort of a separate issue, I would
say.  But doing it onchain, yeah, you go back to requiring block space.

**Mike Schmidt**: I know Veleslav brought up this idea, and I don't know if I
recall if it was clear what his use case was.  I understand the motivation, not
wanting to spam the chain any more than needed, and obviously having something
like an anchor transaction, if you will, with just one output is better than
having a ton of these in each block, but I don't really have an idea of how much
things like burning bitcoins is actually common onchain.  Murch, I know you do a
lot of analysis of output types and trends over time.  Does that even come on
your radar, these OP_RETURNs or burn-like transactions and outputs?

**Mark Erhardt**: Well, a couple of years ago, I think it's a couple of years
now, we had proof of proof by VeriBlock, and they actually were responsible for
more than half of all transactions at some point, with their OP_RETURNs that
were basically just the anchors for their alternative blockchain.  So, yeah,
OP_RETURNs are being used and I think just having already the scalability baked
in, that you can aggregate all of these and use merkle proofs to show that under
a single commitment there is many different proof of burns, would make it a lot
more viable.  I don't really think that currently it would be overwhelming and
if so, people would probably organize better just to avoid the cost of making a
lot of competing transactions that drive up the fees.

**Mike Schmidt**: Yes, I think the fee spike, sustained fee spike, whatever it
was, a year or so ago, drove them off the chain, at least it looked so at the
time.  I remember trying to reach out to them to do what they were doing in a
more blockchain, block-space-friendly way and never got back.  But I guess the
fees solved that.

**Mark Erhardt**: Yeah.

**Mike Schmidt**: Now, I don't exactly know how, I think OpenTimestamps works
similar, in that they're sort of a service that centralizes a bunch of timestamp
patches of documents or data and then anchors with a single transaction into the
chain.  Would that be analogous to what's being proposed here?

**Mark Erhardt**: It's similar, but they of course do not require that you
attach funds with the proof.  And so, this is not a centralized service, but
this is a specific service offering that just can update all throughout a block
and then make sure that there's only a single transaction per block being
included.  So, as far as I understand, they always RBF their transactions to add
more commitments throughout until the block is found and then they start over
with whatever was not included in the previous block for the next block.

**Ruben Somsen**: Yeah, and maybe one thing to add there is that with
OpenTimestamps, you don't have this double-spending problem.  Here, it has to be
clear which amount is for which hash in the merkle tree.  But with
OpenTimestamps, all that you care about is, okay, we have timestamp that at this
time, this hash was known, like this document was known.  But it doesn't
preclude that there's another document or another variant of that document, or
maybe in the past, someone else hashed one of those documents; all of that is
sort of out of scope.  So, that's not a big difference.

**Mike Schmidt**: Yeah, that makes sense.  Well, should we jump to the Stack
Exchange questions, or does anybody have anything more to say?

**Mark Erhardt**: One more comment, maybe.  I think this could perhaps be
somewhat interesting as a mechanism also to create cyber resistance for identity
creation.

**Ruben Somsen**: Yeah.

**Mark Erhardt**: So perhaps, I mean all of us hate and love GPG, I guess, and
perhaps in the future, if we ever get a better implementation of that, for
example via Sequoia-PGP, people could, for example, commit to their identities,
say their PGP keys in this matter, and then maybe even attach a more significant
sum and that would be used to make it expensive to spam the PGP space and make
it more difficult to sybil attack.

**Ruben Somsen**: Yeah, and to add to that, you basically allow for rate
limiting by increasing costs.  And so any mechanism where, I think particularly
for this kind of burn mechanism, mostly the use case at least I can think of is
where you have a server that wants to talk to anyone but doesn't want to be
overwhelmed.  And so, it needs some kind of something to say like, "Okay, well I
will talk to you because it costs you some effort".  Or maybe it could replace
the whole capture system that we have today, where instead of all these
captures, you just make a bunch of micro-burns, and then you reveal them instead
of doing the capture, and that could sort of solve that problem.

Then, I think for Murch's idea, where if you need some kind of global database,
then I think you sort of end up with a blockchain, because you don't just need
sort of rate limiting towards one person, but you need rate limiting for
everyone, right?  Like, everybody doesn't want to be overwhelmed with, I don't
know, the number of PGP keys that they receive, or something like that.  So
then, you need some kind of block size limits, I would say, and so then it turns
a little bit more into spacechains, stuff that I work on, basically.

**Mike Schmidt**: Murch, do you want to give a quick pitch on why folks should
pay attention to the Bitcoin Stack Exchange, other than our monthly segment that
we put some interesting questions into the newsletter?  I know you're very
active there as a moderator.

**Mark Erhardt**: That's true.  So, Bitcoin Stack Exchange is a resource that
we've built over the last decade that just tries to collect, well, all the
questions and answers about Bitcoin from a technical perspective and maybe also
from a perspective of users, what sort of problems they encounter and try to
solve.  So actually, I would love for all of you to add more questions and also
to respond to questions about your products and projects that you're keenly
interested in, especially for example, Lightning has not gotten as much
questions lately as I would have expected.  I think that a lot of other channels
collect them, these questions and topics, and it would be nice to have them in a
globally searchable database where other people can learn from those answers
instead of repeating them over and over again.  So, please write questions,
write answers, and up and download.  Downloading is super-important too because
it makes bad content disappear.

**Mike Schmidt**: Yeah, I think as the Optech contributor that puts the Stack
Exchange section together each month and going through at least the top few
pages of questions and answers, it's pretty high-quality stuff.  I mean, you
have people like Murch, you have people like Pieter Wuille answering seemingly,
in some cases, very basic questions with very interesting and nuanced answers
that even have bits of history in there.  So I found it valuable for myself.
So, yeah, everybody should check that out.  So, we have six questions here.  I
don't know if we need to go deep into each one of those, but I think at least a
quick overview would be useful.

_Why do invalid signatures in `OP_CHECKSIGADD` not push to the stack?_

So this first one here is, " Why do invalid signatures in OP_CHECKSIGADD not
push to the stack?"  And the thrust of the question here is, "If an invalid
signature is found, the interpreter fails execution rather than continuing.  And
Pieter Wuille, as the author of BIPs 340 to 342, chimes in on why that is the
design behavior, and he indicates that future support for batch validation of
schnorr signatures is the reason for that.  And then Andrew Chow also chimes in,
noting that there's certain malleability concerns that are also mitigated by
that, not allowing folks to just put in garbage signatures to malleate the
transaction.

**Mark Erhardt**: We have a speaker request.  Should I invite them up?

**Mike Schmidt**: Why not?

**Mark Erhardt**: Okay.  Well, I can say something while they get themselves
sorted.  The idea with batch validation is that you sum up all the signatures in
a block, and then you just find out whether or not all signatures were valid or
not.  And it doesn't really distinguish or find out which signature failed.  So,
if any single signature fails in the batch validation, you cannot use it.  So
the idea is, we should only have signatures that will pass in every transaction
so that a block can be basically summed up once and then validated once, and
that wouldn't work if we allowed for invalid signatures and failing on
signatures.  Sunfarms, if you want to say something, you're up.

**Mike Schmidt**: Maybe that was an errant speaker request.

**Sunfarms**: Yeah, thanks for bringing me on stage.  I just wanted to ask, how
often is this kind of Space being held, so I can plan towards it?  That's just
my question, thank you.

**Mike Schmidt**: This is so far the first one, so we'll see how it goes.  And
if folks are interested in attending and folks are interested in riffing with us
each week, maybe we'll do it more often.

**Sunfarms**: Oh, that's great.

**Mike Schmidt**: Murch, anything else on the CHECKSIGADD?  Does what you say
that applies block-wide also apply within a transaction, aggregating signatures
in a single transaction as well?

**Mark Erhardt**: I think this is just for -- I mean, it just generally doesn't…
Okay, if we allow any invalid data in the transaction, and that's the other
point that Andrew made there, is the problem is that we introduce a malleability
vector, because people can just malleate that part of the transaction and since
it doesn't matter, they would change the witness txid of the transaction, and
that sort of stuff could be annoying.  So not having invalid data and always
requiring signatures to pass makes it hard for third parties to change
transactions, and it makes sure that we can do batch validation.

_What are packages in Bitcoin Core and what is their use case?_

**Mike Schmidt**: Makes sense.  The next question here is about packages in
Bitcoin Core and what is their use case.  The idea with packages, the motivation
behind grouping transactions together into a package of transactions is that,
for example, let's say that I'm trying to get a parent transaction confirmed and
we're in a period of high fees, and thus the fee to even get into the mempool
and be considered into the mempool is high, but my transaction that I've already
broadcast has a lower fee than would be accepted into that mempool.  There's no
way that I can fee bump that transaction using CPFP, even if I paid a huge
$1,000 transaction fee, because there's no way for that parent transaction to
get into the mempool, even if the child transaction that's bumping the fee pays
an inordinate amount, just because each of the transactions is evaluated
independently.  And so, that parent transaction evaluated independently does not
make it into the mempool, therefore I can't fee bump it.

So, the idea with packages is you can send, let's say, the parent and the child
together and they're evaluated, their feerate is evaluated as a group, as a
package, as opposed to individually, and that helps with the reliability of
being able to manage fees and fee bumping.  So, that is my take on packages and
the motivation for them.  Murch, I don't know if you have additional thoughts on
that or you want to augment some of that.

**Mark Erhardt**: No, that sounds about right.  We have another question from
Sunfarms.

**Mike Schmidt**: Sunfarms, I think you're still a speaker, so you can go ahead.

**Mark Erhardt**: Yeah, or at least I interpreted the raised hand as a question.
Well, okay, let me just answer meanwhile.  Packages are any type of group of
transactions that we want to evaluate together.  And that can, for example, be
really interesting for closing transactions on Lightning, because one of the
issues is that currently, we always have to guess at what feerate a commitment
transaction would later be able to get included in a block, and we don't know
what the feerate half a year from now will be.  So currently, one of the
solutions for that is anchor outputs, which just basically creates garbage on
the blockchain for only the reason that we'll be able to bump transactions later
from both parties.  And if we were, for example, able to make commitment
transactions simply be zero-fee transactions, then the closing party could bump
that transaction by attaching a child transaction with a large enough feerate,
and those two transactions would propagate as a package.  That's a concrete
example.

_How much blockspace would it take to spend the complete UTXO set?_

**Mike Schmidt**: Cool.  This next question from the Stack Exchange, Murch, I
believe you asked it and answered it, I thought it was an interesting bit of
trivia.  I don't know if you want to dive in to the motivation?

**Mark Erhardt**: Yeah, sure, let me take it!  All right, so my thought was,
"Hey, so the UTXO set keeps growing and growing, and how much would it actually
cost, how much future debt in block space do we have to spend all those UTXOs
sometime in the future?"  That was my main question that motivated me.  So what
I did was, I used txstats.com to get a breakdown of all the different output
types that we have, and to calculate roughly how much block space it would take
to spend all the UTXOs that currently exist.  I was actually surprised how
little it is.  It's about 11,500 blocks, and that's about three months' worth of
block space to spend all the pieces of bitcoin that currently exist.  On the
other hand, of course, usually there would be other traffic for transactions, so
consolidating all the pieces of bitcoin that exist down would take significantly
longer because they'd have to compete with the natural traffic on the network.

**Mike Schmidt**: I like how you add all of the calculations and block space
breakdowns between the output types and very thorough with your answer to your
own question.

**Mark Erhardt**: Well, how would other people find out that I'm wrong if I
don't tell them what I did?!

_Does an uneconomical output need to be kept in the UTXO set?_

**Mike Schmidt**: Exactly.  Next question from the Stack Exchange was, "Does an
uneconomical output need to be kept in the UTXO set?"  And as a quick bit of
background, an uneconomical output is one in which the feerate is greater than
the value of the output itself, so it wouldn't really make sense to spend that
set of bitcoins from an economic perspective.  There could be other reasons that
you would want to move those coins, but it's uneconomic.  And the question is,
"Well, if someone's probably not going to spend that, then why do we need to
keep it in the UTXO set?  Why do we need to keep these pieces of bitcoin dust
around?"

Stickies-v notes that "Bitcoin Core, for provably unspendable UTXOs, like
OP_RETURN or scripts larger than the max script size, does remove those",
because there's no chance of those being able to be spent.  But if you remove
uneconomical outputs, you could cause issues because somebody, for whatever
reason, could decide to spend those coins even if it's uneconomical.  For
example, maybe there's a layer, a different layer over those, that particular
output, like counterparty, some token is imbued in there, or some such thing.
And if it does move, then you get a situation that Pieter Wuille points out,
which is that you could have a hard fork.

**Mark Erhardt**: Right, and so I was very surprised.  I implemented a new RPC
earlier this year which is sendall, basically a way to empty out a Bitcoin Core
wallet completely.  And asking around on Bitcoin Twitter what they expect the
behavior should be in a poll, I was pretty surprised that people were, "Well, if
I sendall, I want the wallet to be empty afterward, even if I spend UTXOs that
are uneconomic.  So I'd rather pay more fees than have any leftover UTXOs".  So
if we were removing UTXOs that are uneconomic, the sendall call, for example,
already would split the network because those nodes that are upgraded and remove
uneconomic outputs would not follow the blockchain at that point anymore.  We
have a new speaker up, which is Eddie.  Eddie, what did you want to ask about?

**EddieMBTC**: So, I am a developer and I'm interested in, hello guys, do you
hear me well?

**Mike Schmidt**: Yeah, we can hear you.

**EddieMBTC**: I was saying that I'm a developer and I'm interested in learning
enough to be able to help with Bitcoin Core and Lightning, but it has been a
little bit difficult to find the guidance about where to start.  I'm a
professional C++ programmer.

**Mark Erhardt**: Okay, I think we'll be able to provide some links in answer to
this Spaces later, and otherwise I can always encourage people to come to the
Bitcoin Core Review Club, which happens on Wednesdays, where one of the
developers or just people interested facilitates a review of one of the open or
recently closed Bitcoin Core PRs, and it's a great place to meet other people
that are just getting into Bitcoin Core development; and the IRC channel
associated with that is also frequently used to ask beginner questions or find
out more about the codebase, and things like that.  I'm not entirely sure what
the best resources for Lightning are, but Chaincode Labs has a program for new
developers to learn about Bitcoin and Lightning Protocol development.  So, all
of those resources are online too, so you could take a look at
learning.chaincode.com, for example, if you are looking for more material too.

**EddieMBTC**: Could you please repeat the last link, learning.what?

**Mark Erhardt**: Chaincode is my employer; Chaincode as in blockchain chain,
and code as in source code, so chaincode.com, and learning, like learning a new
idea.

**EddieMBTC**: Got it, I just got it, thank you very much.

**Mark Erhardt**: Okay, cool, super.  Thank you for your question.

**Mike Schmidt**: I would echo those resources.  The PR Review Club is a very
approachable way, if you want to participate or not.  You can just kind of sit
in and see what folks are talking about when they're actually reviewing changes
to Bitcoin.  And I think, over time, it peers into different pieces of the
codebase and gets you familiar with what's going on with Bitcoin.  One thing
that I would add is I think René on the Stack Exchange had a great answer in the
last month about Lightning resources.  So, check on the Stack Exchange and look
for a question about Lightning Resources, because there was a good response from
René about that.  Okay, where were we?

**Ruben Somsen**: Yeah, so maybe one thing to add about this.  So, we talked
about whether you could remove UTXOs that are too low to spend, right?  And so
one of the answers was, it would create a hard fork.  But it wouldn't create a
hard fork if you created a soft fork that would disallow those outputs from
being spent and everybody upgraded to that.  So theoretically, you could do it
as a soft fork, but one that will be somewhat controversial in terms of removing
things that people own, and not just those sats, but maybe like you said, Mike,
it might be something else that it represents that isn't actually the satoshi
itself.  And I think the second thing is that currently the UTXO set growth,
while it is something that we certainly should keep in mind, it hasn't really
grown to a degree where people are concerned about it, I would say.  So, it
seems a bit overkill to consider something like that.  There's not really a
problem that's being solved, at the moment at least.

**Mike Schmidt**: Yeah, that makes sense.

**Mark Erhardt**: Yeah, I think the Colored Coins argument is a very big point.
There are maybe quite a few very small pieces of bitcoin that actually represent
something else.  And, well there's only slightly over 83 million UTXOs, and we
just learned that we can spend them all in three months, so 11,500 blocks.  So I
think it's not growing over our head yet.

**Ruben Somsen**: Yeah, and we even have alternative solutions, possible
solutions.  I mean, they're not a guaranteed solution, but something like
utreexo could change how we look at UTXO set growth, so that's another factor
that is sort of hard to predict.  But once we run into that issue, it might not
even be that reducing UTXO set is what we want.  We might just change how we
process the data in its entirety.

_Is there code in libsecp256k1 that should be moved to the Bitcoin Core codebase?_

**Mike Schmidt**: Next Stack Exchange question was about libsecp, if there's
pieces of that code that should just move into Bitcoin Core, since Bitcoin Core
is using that?  And while the answer was fairly straightforward, which is
anything that involves operations on private or public keys is within scope of
libsecp and we're fans of modularization, part of the reason I put this question
in was that it gives us an opportunity to link to libbitcoinkernel as well as
the process separation projects, which I think is useful for folks to be aware
of, that there are efforts underway to further modularize the codebase and prune
things that may not be needed in Core into their own different processes or
projects.  Any comments on that, Murch or Ruben?

**Ruben Somsen**: It speaks for itself.

**Mark Erhardt**: Yeah, it pretty much speaks for itself.  I think libsecp is a
fairly targeted small package and it has an extremely high review standard.  It
doesn't change a lot either.  It's mostly just cryptographic stuff.  I think
it's very well that it is separated out of Bitcoin Core.

_Mining stale low-difficulty blocks as a DoS attack_

**Mike Schmidt**: The last question here about a potential attack, using
low-difficulty blocks that are hard to validate because they have a lot of
scripts, or they're intensive to validate from a computational perspective.  And
so the question is about how are those sorts of attacks mitigated if someone
creates a low-difficulty chain with a bunch of stuff that's hard to process?
And there's a couple of different ways that that has been mitigated over the
years.  My understanding is the most recent one is this nMinimumChainWork, which
is a parameter that you can either set via the RPC flag, or it's also coded into
the Bitcoin Core software as part of the release process, some recent block, and
the associated work is actually put into the code as sort of a check.  And so,
if you have somebody who's trying to forge a bunch of blocks with a bunch of
garbage in it, you can just check, does this have anywhere near the amount of
work that I am expecting the Bitcoin blockchain to have?  And if not, you can
not download the blocks associated with that particular spoofed chain.

**Mark Erhardt**: Yeah, so as you all know, Bitcoin uses proof of work and it
has done so to a really huge degree.  And in order to properly attack any node,
you would have to sort of sybil them off of the network so they don't hear about
the actual blockchain.  And then you would have to feed them a huge blockchain
of headers, at least, to even keep them interested.  Because a full node that
tries to catch up with the network, it doesn't actually load all the blocks at
all until it has verified the header chain.  So, it will get the whole header
chain up to the best chain tips that it has heard about, and just from the
headers, it can check whether they form a valid chain and whether they fulfill
the difficulty criteria.

So, the nMinimumChainWork is basically just a sanity check.  If whatever you
have perceived as the best chain tip falls short in the total work than the
nMinimumChainWork, which we set back a few months before the release, then you
don't even have to look at it, because it obviously must be fake, or you haven't
seen the best chain yet.

**Mike Schmidt**: I think under the release and release candidates, to me
there's nothing worth talking about.  I think keeping this Space to an hour
would make sense, which would give us six minutes more, and I don't think these
RCs are worthy of that at this time.

_Bitcoin Core #25351_

Bitcoin Core #25351 is a PR that's been merged that fixes a bug that in which
when you import a descriptor or an address or key, if it's watch-only or if it's
a private key or descriptor to a wallet, if there's transactions that are in the
mempool associated with those keys or addresses, they won't be found if they're
in the mempool at the time of importing.  The rescan only goes to the blocks,
which I actually did not know that.  So, this PR fixes that by not requiring you
to restart, to rescan; it'll look in the mempool as well.  Murch, I think you
did the writeup for this particular PR; is that directionally correct?

**Mark Erhardt**: Yeah, that's correct, both of them!

**Mike Schmidt**: Okay.  Anything you want to add there?  Any good tidbits you
found writing that up?

**Mark Erhardt**: Actually, I was surprised that this issue existed.  It's good
that it's fixed.  I'm still pondering whether or not it would fix itself once a
transaction gets included in the block.  But I think since a full node always
validates transactions when they first see them, I wonder whether it would just
miss that transaction even when it gets confirmed and corresponds to the wallet,
because it would have assumed that the check had been done earlier.  So if
somebody knows that, I'd be curious to learn more about that, actually.

**Mike Schmidt**: I don't know firsthand, but just having looked into that in
preparation for this chat, it did look like that it wouldn't be caught, and that
it actually did require this fix.  So I don't think being in a block triggered
anything that then credited you that amount, for example.  So, yeah, I would
agree.  I was like, "Oh, this is interesting that this still exists", and I
think that the original issue was from over two years ago as well.  So, glad we
got it fixed.

_Core Lightning #5370_

The next PR here is for Core Lightning (CLN) and it talks about moving the
commando plugin as a built-in part of CLN.  And commando is a feature that
allows a node to receive commands to be executed on that node from authorized
peers using Lightning messages.  So, I could have in theory two nodes, one that
has provided some authentication rune and is able to execute commands on the
other Lightning node, because there's certain permissions that can be given to
that rune, or that sort of macaroon rune, so that I can execute certain commands
on the remote node or however the use case is there.  I don't know if
Seardsalmon wants to talk about this particular PR, but I'll give you the
speaker option if you want to jump in and talk about that.  Murch, do you have
any thoughts on commando and the use cases that it enables?  I'm not
super-familiar with what this would enable, the motivation behind it.  I think
it's interesting, but I'm just not familiar enough with that space and other use
cases.

**Mark Erhardt**: I must admit I was super-into Lightning at the very beginning
of it, but it just grew over my head and I'm more focused on Bitcoin stuff than
Lightning stuff specifically.  I think that it might be interesting, if you run
multiple nodes, to have the ability to prompt a channel rebalancing or even to
have a thin client that is unable to send from a main client when it comes
online.  And since all the communication between the two nodes would run in
band, it would be maybe a convenient and private way to have this remote access
to your main Lightning node.  But honestly, somebody else can probably tell us
more.

**Mike Schmidt**: I don't know if we have anybody on the call for that.

**Ruben Somsen**: Yeah, I'm not a Lightning guy either, so it's hard to add
anything to this.

_BOLTs #1001_

**Mike Schmidt**: The last PR here is a fairly simple one, just changing the
BOLTs to put a timeout in change of policies to ten minutes.  So, if I change
some payment forwarding policy on my node, I will continue to accept payments
that violate that policy that were in line with the previous policy for ten
minutes while the changes in my policy propagate the network, which seems pretty
reasonable and straightforward to me.

Anybody have any questions about anything that we've talked about today, or
comments on the newsletter, content in general, or questions in general?  Great.

**Mark Erhardt**: One last thing, maybe.  I just posted the links that I
promised to Eddie, and you can find them on the original Optech tweet that
announced this Spaces, and we have, yeah, just as I said, a link to the resource
list that René posted, the learning.chaincode.com and Bitcoin Core Reviews.

**Mike Schmidt**: Yeah, and if you're interested in this sort of thing, the next
Bitcoin Core PR Review Club is actually happening one hour from now, so it's a
good opportunity to jump in and explore the Bitcoin codebase.

**Mark Erhardt**: Also, let us know whether you enjoyed this and whether we
should ever, ever do this again.  Maybe just respond to our tweet on that
announcement.

**Mike Schmidt**: Yeah, feedback would definitely be helpful and appreciated,
Twitter, email, wherever.  I see some hearts, so that's good feedback.  All
right guys, thanks for your time, thanks for your interest in Bitcoin
open-source work and Optech, and maybe we'll see you next week.  Cheers.

**Mark Erhardt**: Cheers.

**Ruben Somsen**: Bye guys.

**Mike Schmidt**: Thanks Ruben for joining, thanks Murch for joining and
supporting.

**Ruben Somsen**: No problem.

**Mike Schmidt**: Have a good day everybody.

**Mark Erhardt**: Bye.

{% include references.md %}
