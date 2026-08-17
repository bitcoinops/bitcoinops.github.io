---
title: 'Bitcoin Optech Newsletter #417 Recap Podcast'
permalink: /en/podcast/2026/08/11/
reference: /en/newsletters/2026/08/07/
name: 2026-08-11-recap
slug: 2026-08-11-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Conduition, Ram, and Fabian Jahr to discuss [Newsletter #417]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-7-12/429714993-44100-2-9d93712e397bd.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #417.  Today,
we're going to talk about a draft BIP for stale tip relay.  We have our
monthly segment on Changing Consensus which, as usual lately, is pretty beefy.
We're going to talk about cross-input signature aggregation (CISA); we have a
handful post-quantum-related Changing consensus discussions as well; and then
we'll move to Releases, we have the secp release.  And then, we have a bunch
of Notable code and documentation changes.  Murch, Gustavo and I are joined by
some guests this week.  We'll have them introduce themselves briefly.
Conduition, who are you?

**Conduition**: Hey, Mike.  Hi, I'm Conduition, I'm a freelance and
open-source engineer and researcher, now focused primarily on post-quantum
stuff and funded by Brink.

**Mike Schmidt**: Ram?

**Ram**: Hey, my name is Ram, I also go by pseudoramdom on the internet.  I'm
an open-source contributor/researcher at Localhost Research, primarily working
on Bitcoin Core.  Thanks for having me here.

**Mike Schmidt**: Fabian?

**Fabian Jahr**: Hey, I'm Fabian, I'm a Bitcoin open-source contributor and
I'm supported by Brink.

_PQC output type discussion_

**Mike Schmidt**: Thanks for joining us, we appreciate your time.  We're going
to rearrange, for listeners who are following along.  We'll go a little bit
out of order in deference to our guests.  So, we're going to jump to Changing
consensus.  We have a few items that Conduition is going to help us get
through on the quantum front, that I saw that he was engaged with on Delving.
The first one, "PQC output type discussion".  So, conduition, nearly everyone
in these discussions agrees that Bitcoin may eventually need and should put
some time toward researching post-quantum and maybe a new address type that
can survive quantum computers.  Maybe the problem, or maybe not a problem, but
one consideration here is that there's about a half dozen of these different
designs, each being debated in their own threads, some on the mailing list,
some on Twitter, some on Delving.  And so, Pieter Wuille opened up a thread to
sort of put them all in one table and then compare them head-to-head.  Maybe
I'll just leave that as the intro.  Maybe you can talk a little bit about what
aspects things are being compared on and maybe what some of the important
candidates or distinctions are between the different candidates?

**Conduition**: Yeah, absolutely.  Thank you.  Pieter's post here does a great
job at summarizing it, so I'll try not to regurgitate too much.  I would
highly recommend you read it first.  But the major salient trade-offs of any
post-quantum output type in a quantitative sense is its efficiency, how cheap
it is to spend.  But also, there's qualitative properties like, is it secure
against a quantum computer without follow up?  And that's one of the main
debate points between the different output types that are under consideration.
And there's even some subtlety there in that question, because there's one
output type called Pay-to-Taproot-Hash (P2TRH), which is secure until you
spend from it.  So, there's a lot of different subtleties, and Pieter does a
great job at summarizing them all.  He separates his posts.  The first one is
purely factual, unopinionated, and it goes over the different trade-offs in a
very unbiased way, I really appreciate that.  And then, he separates out his
own stance and what he would into his second post.  And his recommendation was
to deploy Pay-to-Taproot v2 (P2TRv2) and Pay-to-Merkle-Root (P2MR), which are
two different output types, in tandem or perhaps in a staggered release
fashion.  And these two address types will do very different things for
different people.

**Mike Schmidt**: So, Pieter recommended both, because I know I've seen you
and him going back and forth on P2MR vs P2TRv2.  He's saying do both?

**Conduition**: Yeah, yeah.  There's two different perspectives generally in
this debate.  There's the absolute security perspective, which is that if we
want a post-quantum output type, it should be post quantum.  We shouldn't have
to do some sort of follow-up fork to close up a security hole later.  But then
there's the migrationist perspective, which is that we want to maximize the
incentive for everyone to migrate as soon as possible so that we don't have to
deal with things like rescue protocols; or at least if we do, the fallout of
instituting rescue protocols will be much less and will be less worrisome.
And both have their merits and both have their trade-offs.  But deploying both
output types, as Pieter is saying, will appease both camps.

**Mark Erhardt**: Sorry, could you explain which of the two is only
post-quantum, because I thought that P2MR would also have ECDSA signatures in
the output, in the scriptpath, and P2TRv2 would not be only post-quantum
either, so I don't really understand?

**Conduition**: Great question.  So, there's a lot of subtlety here in which
signature types are available on which outputs, and there's different options.
P2MR, as it's currently defined, will support both classical and post-quantum
signatures.  So, it's theoretically possible to use P2MR in a quantum-secure
way, as long as you never expose your elliptic curve public keys to a quantum
attacker.  And the point that Pieter makes and that Antoine has made before in
the mailing list debates is that that's a big ask.  And there is an option to
deploy P2MR without classical elliptic curves.  That's what sipa calls P2QR,
Pay-to-Quantum-Resistant.  This one, I don't know of anybody actively pursuing
this path, primarily because, well, if you were wanting to deploy P2QR, you
would want to deploy a different output type alongside it, because otherwise
nobody would migrate to P2QR before Q-Day.  And then, we would still run into
the problem of having to rescue a whole bunch of coins, a lot of people might
get hacked.  So, it doesn't seem like a desirable option for most people.

**Mark Erhardt**: Right, because of course spending from P2QR would incur huge
scripts due to the quantum-resistant signature scheme.

**Conduition**: Exactly, unless there were some massive witness discount or
SNARK verification, which we can talk about in a bit.  But as to your
question, yes, there's P2MR, P2TRv2.  They both support classical and
post-quantum signatures.  The difference is in whether the public keys that
you validate against are hidden by the hash or not.  To be clear, in the case
of P2MR, everything is hidden behind hashes; and in the case of P2TRv2, we
post a bare public key on chain, just as in P2TR.

**Mark Erhardt**: Right.  So, P2MR, the argument would just be that it's
resistant to long-range attacks because the public key material is not visible
until it's reused or a transaction is in the mempool, okay.  I thought you
meant quantum-resistant as in with quantum-resistant signature scheme and only
that as it's only spending option.  But as you clarified, that is now referred
to as P2QR.

**Conduition**: Yeah, exactly.  I think it's good to distinguish, because it
avoids confusion as to what exact spending conditions are available.  I think
P2QR could be viable, but it would require a lot of other technologies, like
SNARK signature aggregation, to be economically viable.

**Mike Schmidt**: Maybe that's a good segue to one of my follow-up questions.
You, Conduition, pointed and encouraged listeners to read the source material
on what Pieter put together.  Unfortunately, Pieter couldn't join us, so we
will encourage people to go read that firsthand.  But since we do have you and
you added some contributions to that thread, there's two pieces that I pulled
out at least.  There's the potential, you were talking about Fabian, who's
here, his CISA proposal for signature aggregation, and then there's also
block-wide PQ-SNARK aggregation.  So, maybe you want to double-click on both
of those?

**Conduition**: Yeah, absolutely.  So, there's some great interplay between
many different proposals, like Fabian's, and post-quantum migration.  And I
hadn't thought about this until recently.  So, it's kind of been changing my
mind a little bit on this post-quantum output-type debate and making me
rethink what's going on and what the best options are.  So, maybe we should do
a little brief thing on CISA before we talk about how CISA affects post
quantum.  Maybe I'm not the best person to talk about this, since we have the
author of CISA in the room here.

**Mike Schmidt**: Fabian, do you want to spoiler-alert your other item by sort
of summarizing it briefly here, and then we can dig in maybe a little bit
deeper later?

**Fabian Jahr**: I think for the purpose of this question, maybe we can just
remind people that CISA means that a transaction that has multiple inputs,
which typically corresponds to multiple signatures, with CISA those could be
aggregated into a single signature, which is smaller.  And there are two
different types, one which roughly halves it and the other one makes it a
constant size.  I think it creates a lot of space-savings on the chain in
terms of the signatures.  I think that's enough for now for this conversation.

**Conduition**: Yes, and the fact that CISA exists is really awesome because
Fabian's proposal introduces a new output type by necessity.  In order to
institute and deploy CISA, you need a new output type, because the validation
rules are changed, and that would be a hard fork if you just introduced it on
P2TR.  And this new output type that CISA proposes could exactly be P2TRv2.
All you need to do is introduce a new leaf version that supports post-quantum
signatures.  I say, 'all you need to do', I mean there's a lot of work that
goes into that, of course, but this means that the CISA output type and the
P2TRv2 output type could just be the same thing.  And that provides a really
cool incentive, because CISA has asymptotic efficiency, like as the number of
inputs grows, of just about 1 or 2 bytes per input.  And you only need a
single signature for all the inputs in a given transaction, in the best case.
But that is contingent on using schnorr signatures.  And this is all based on
discrete log, which is broken by quantum computers.  And so, while CISA does
incentivize people to migrate, and then everyone will be on addresses with
post-quantum cryptography, we won't be able to use CISA after Q-Day, if Q-Day
happens.

**Mike Schmidt**: Conduition, maybe you can elaborate on where you left off
there, because I'm with you that you can't aggregate post-quantum signatures,
and so there's not a magic bullet, which I've always hoped for in years past,
where you just, "Oh, these signatures are large, but you can aggregate them,
right?"  So, we can't do that.  So, what you're saying is we have a P2TRv2
that is CISA-enabled, which would help with what, even if it's not helping
with post-quantum?

**Conduition**: Sorry, I should clarify.  Because CISA is so efficient, people
who may not care at all about quantum cryptography could migrate to it and
would have incentive to migrate to it to save money.  And that would put more
people onto addresses and wallets that use a hidden post-quantum fallback leaf
in their P2TRv2 script tree.  And so, if the soft fork that disables
keyspending is deployed in time, then all those people who migrated will be
safe almost by accident, because they may not have even intended to secure
their funds against quantum computers, but just by following incentives, they
did so.  Now, Murch, I think you had your hand there?

**Mark Erhardt**: Yeah, so one of the ideas behind P2TRv2 was because it
doesn't give a financial incentive, the idea would be that people only switch
over once they also add a post-quantum-resistant leaf in their script tree.
If we now give a financial incentive to switch to P2TRv2, wouldn't we expect
that more people switch to P2TRv2 due to the financial incentive, without
actually going the extra step and adding the post-quantum leaf?  So, wouldn't
we set ourselves up to those people rugging themselves per this foot gun?

**Conduition**: That is possible.  However, every description of P2TRv2 that
I've seen, and in this case that's what we're talking about, has included a
contract, a sort of social agreement implicit in its use, where if you want to
use this output type, you need to have a post-quantum fallback.  If you don't,
you are submitting your coins for confiscation, because the part of P2TRv2
that everybody debates about so much is that eventually we have to disable the
keyspend path.  Otherwise, all the coins can be stolen by a quantum computer.
And if you opt yourself out of that, any user can destroy their coins if they
really want to, and this would be exactly that.

**Mark Erhardt**: Right.  I think that Pieter mentioned in this context that
the tripwire plays an important part in the social contract, simply because
you don't necessarily have to negotiate the soft fork to disable the EC
spending, if you build it into the output type from the very beginning, to be
triggered by any participant that can show the proof that an output without a
keypath spend has been spent.  And so, if you construct a P2TR output, you can
use something called a NUMS point (nothing-up-my-sleeve).  And the idea would
be that there would be some such NUMS points used to create output.  And if
someone can prove that they used a NUMS point and their output was still spent
with a keypath spend, then that would be proof that a quantum computer was
used to derive the key that underlies the NUMS point, which the user of the
NUMS point couldn't have known.  And thereby, quantum computers are real and
the EC path is disabled.

So, having the tripwire in from the very beginning means that anyone with this
proof can disable the EC path, and thereby people would be forced to have a
post-quantum fallback, or they would set themselves up to be disenfranchised
of their coins, even without a soft fork being negotiated to remove the EC
signing.

**Conduition**: That's exactly right.  I highly recommend any interested
listeners check out the mailing list thread, I believe it was called, "Giving
teeth to EC disabling", started by Pieter as well.  And I think as I learn
more about CISA and how it interplays with post quantum, I start to realize
that this problem is really the core dependency that many other problems rely
on solving, but nobody has yet fully solved it, and it's a worthwhile debate
to be to be discussing.

**Mike Schmidt**: Should we also talk about your contribution to the thread in
terms of post-quantum SNARK aggregation?

**Conduition**: Yes, I'm sorry, I left off on that.  So, there is a technology
called Succinct Non-interactive Arguments of Knowledge (SNARK), which let you
prove that you executed a certain computation on certain inputs without
necessarily forcing the person verifying your proof to have all of those
inputs.  And one thing that you can do with a SNARK is you can take a whole
bunch of, say, large hash-based post-quantum signatures, verify them all
against a bunch of pubkeys on a bunch of different messages, and then produce
a succinct proof that you executed that verification correctly.  And this
scales logarithmically with the number of signatures.  So, as you get more
signatures, the size of the proof kind of caps off around a few hundred
kilobytes.  And I'm talking strictly about post-quantum SNARKs here.  There
are more succinct SNARKs, but they are not strictly post-quantum.  There's
also different assumptions that you can use to make the proofs smaller or
faster, but I'm talking specifically about hash-based SNARKs here.  And if you
were to use, say, a hash-based SNARK to aggregate a whole bunch of hash-based
signatures into a single proof and then attach that to a block, well now the
size of any specific signature is asymptotically almost zero, which is almost
the same behavior as CISA.  It's just that we have to add this big block-wide
proof, which is where most of the difficulty and complexity of this approach
comes from.

This isn't new, this has been talked about before.  I think Ethan Heilman
proposed this, titling it BitZip, a year or two back.  And this trick, I
think, might be a potential way to incentivize people to migrate to
post-quantum cryptography in the same manner that CISA does, but without the
caveat that it becomes useless after Q-Day.  It would persist after Q-Day, but
still provide incentive for people to migrate, although there is a lot of
complexity that comes with using SNARKs.  You have to design your circuits
correctly, you have to make sure your verifier is sound.  There are countless
examples of SNARK proving and verification systems having soundness bugs, like
for example the recent Zcash infinite money glitch that was patched.  And we
don't know if anybody actually exploited it or not.  We think not, but how do
we know?  And If we were to have that same soundness in Bitcoin using this
SNARK signature aggregation system, it would mean that anyone who knows about
this bug could, in theory, spend the coins of any other user, as long as
they're able to produce a valid proof.

**Mike Schmidt**: Is there something about this proposal that requires it to
be block-wide and not transaction-wide?

**Conduition**: Good question.  The main constraint is the size.  Unlike CISA,
which has aggregated signatures of about 64 bytes, you need hundreds of
kilobytes.

**Mike Schmidt**: They're coming for you, Conduition!

**Mark Erhardt**: Sounds like New York singing you the song of its people!

**Conduition**: Yeah!  You need proof sizes, and because the proof sizes are
so big, if you aggregated these signatures on a per-transaction basis, you
could only fit maybe, at most, 8 to 10 of these signatures.  I say,
'signatures', they would actually be aggregated proofs, into a block.  And
this is the real rub is that in order to deploy this, you need some mechanism
for miners to either produce these proofs themselves in a reasonable amount of
time before they start mining on a block template because remember, this is
essentially a witness which means it needs to be included in the witness
commitment in the coinbase transaction, which means that the miners have to
produce it before they start mining.  And then, every time they want to change
their block template, they change the different set of transactions that are
in the block, they have to redo this whole proof.  And creating a proof like
this is expensive.

_Layered quantum recovery of hashed addresses_

**Mike Schmidt**: Seems like we'll probably be talking about these kind of
ideas further into the future as well, but I appreciate you sort of going on a
tangent with us in this particular discussion.  I think maybe in the interest
of time, we can move to the next quantum-related item, Conduition, that you
participated in titled, "Layered quantum recovery of hashed addresses".  And
this was a post, I think, on the mailing list and also Delving by Shinobi.
And maybe, Conduition, I'll let you frame this one up for the audience.
What's Shinobi getting at here?  What's the story?

**Conduition**: Yeah, so this is a post about recovery protocols.  So, for
those not familiar, a recovery protocol is a way of rescuing legacy
pre-quantum coins after Q-Day without any action from the user.  This has a
few caveats.  This isn't possible for every UTXO.  Only certain UTXOs can do
this, and it relies on what I call knowledge asymmetries.  The idea of a
knowledge asymmetry is that in the toolchain of Bitcoin, there's many
different ways of deriving addresses.  For example, you might have a public
key that you hash; or you might have a script that you hash; you might use
BIP32 to derive your secret key, which then turns into a public key which you
hash.  There's a lot of different computational pipelines that all end up in a
Bitcoin output.  And some of those are actually quantum-hard relations.  By
which I mean If you give the quantum adversary your address, they might not
necessarily be able to invert your address into a witness to that relation.

So, for example, a hashed address is a very simple example of a knowledge
asymmetry.  Provided that you've never exposed your public key, the quantum
computer can't invert a hash function and find your public key.  However, if
you'd exposed your public key before, there still are potential knowledge
asymmetries, because that key was most likely derived via BIP32.
Specifically, BIP32-hardened derivation is a quantum-hard relation, because
even if you're given the public key and the quantum computer inverts it to get
the secret key, you can't invert the hash function used by BIP32 to derive
that secret key.  And rescue protocols make use of these knowledge
asymmetries.  And what Shinobi is saying is that by layering different
knowledge asymmetries, we can get more complete coverage of the UTXO set after
Q-Day, because most likely, when Q-Day rolls around, not everyone will have
migrated to P2MR or P2TRv2, or whatever new output type is deployed.  And so,
in order to prevent either mass theft or mass confiscation, we can deploy
rescue protocols, which would let people rescue their coins using these
knowledge asymmetries that are kind of baked into the UTXO set, not via
consensus, but just via the toolchains that have been standardized around
Bitcoin.

My response to his initial post was that he had some claims that weren't
exactly correct.  He claimed that P2TR was not rescuable.  It is.  There is a
neat little thing in taproot, where every output is supposed to commit to a
script or an empty script tree, even if it doesn't have any script spending
conditions.  And this actually constitutes a knowledge asymmetry, which you
can use to rescue any taproot output.  He also said that you can cover 100% of
coins.  And that's also not true because there are always going to be coins
that don't have knowledge asymmetries, case in point being P2PK coins; JBOK
(Just-a-Bunch-of-Keys) wallets, which were the standard before BIP32 existed;
and those, if they are on an address with an exposed public key, those are
also not rescuable.  I tend to call these recoverable or unrecoverable coins,
depending on whether they do or don't have a knowledge asymmetry.

**Mike Schmidt**: Now, so the idea from Shinobi is to take some of these, and
I guess we've covered some of these before, so like the BIP32 proofs, I think
roasbeef had something, I know Tadge has done commit-reveal-related work.  And
so, the idea is to sort of stitch these together in what he calls this layered
approach.  Is that the idea that he's come up with, or does he have additional
proofs that he's adding to this?

**Conduition**: No, that's the gist of this post.  He's saying that by
layering multiple knowledge asymmetries or multiple rescue protocols together,
perhaps in combination with pre-registration, which is a different thing, we
can achieve 100% coverage of the UTXO set, rescuing them all after Q-Day.  I
don't think that's true, because there are going to be coins that don't move
in time, don't have knowledge asymmetries, and don't pre-register.  And I had
a reply that I actually sent a week ago, but I sent it without hitting, "Reply
all", so I just posted a further reply just earlier today saying exactly this.
There's always going to be some coin that you can't rescue.

**Mike Schmidt**: Conduition, you were breaking up for me.  I don't know if
it's for others as well.  We may have slightly lost Conduition.  There's an
interesting sort of parallel, I'd say, with some of the stuff that's gone on
with COLDCARD the last few weeks.  I know some folks were trying to also
determine what sort of knowledge asymmetry, or hardware asymmetry, there may
be between somebody who's cracked another user's keys due to the bad entropy,
and the person who actually had the device that generated the seed and the
keys.  Obviously, totally different when we're talking about post-quantum, but
I know some folks have been working on that as well in the background with the
COLDCARD thing.

**Conduition**: Yes.  I sent a reply to Shinobi a week ago, but I forgot to
hit, "Reply all".  I just resent it this morning.

**Mike Schmidt**: What's the gist of that?

**Conduition**: I was saying basically exactly the same thing that I said a
minute ago, that you can't have 100% coverage.  We're going to get the UTXO
set that we're going to get, not the one we want, on Q-Day, and we have to
work with what we have.  And when that comes around, we'll have to decide what
rescue protocols we want to deploy and how, because some rescue protocols will
confiscate coins and others won't.  And that choice will be probably a very
contentious one when the time comes.

**Mike Schmidt**: Indeed.  Anything else on this item, Conduition?

**Conduition**: No, I think that's most of it.

**Mike Schmidt**: All right, well, thank you for joining for these two.
You're welcome to hang on.  We've got a bunch of other things we're going to
be talking about, but we understand if you have other things you're working on
and need to drop.

**Conduition**: Thanks.  Yes, I've actually got some stuff I've got to do
today.  But it's been a pleasure, and thank you all, guys.

**Mike Schmidt**: Thanks, Conduition.  Cheers.

**Conduition**: Bye.

_Draft BIP for stale tip relay_

**Mike Schmidt**: We're going to jump up to the News item.  We had one item
this week, and Ram has joined us to discuss this, titled, "Draft BIP for stale
tip relay".  Maybe we can start with the basics.  Ram, what is a stale tip and
why would we want to be relaying them?

**Ram**: Sure.  I'll probably start with that maybe what a stale block is.
Maybe from there, we can probably understand why we're relaying only the tip.
Yeah, a stale block is basically a valid block that is no longer part of the
active chain.  So, because block propagation is not instantaneous, two miners
can potentially find blocks at roughly the same time for the same block
height.  And different parts of the network may see different blocks first.
So, there's essentially two valid blocks at the same height.  And miners can
only pick one to mine on top of, and the other block, which the miners didn't
get to pick, effectively becomes stale.  And just to clarify, this is not to
be confused with an orphan block or an invalid block.  And that's what a stale
block is.  Currently we see around, like, 1 stale block every 1,000, 1,500
blocks.  And the idea of this proposal is not new.  It's come up in earlier
community discussions, including comments from Greg Maxwell, Antoine Poinsot,
when they were discussing selfish mining and correlation to stale rates.  Why
release stale blocks?  Was that the follow up question?

**Mike Schmidt**: Yes.

**Ram**: Yeah.  So, at a high level, yeah, this proposal basically introduces
an opt-in P2P message for relaying recent stale chain tips.  When I say tips,
a stale branch can contain more than one block.  So, for more pedantic
reasons, it's called tips, because we are relaying only the tips and not the
entire block.  And we relay headers and stuff instead of the full block.
Coming back to the point, "Why relay?" the main reason is observability.
Stale rate has direct correlation to block propagation.  As a community, we've
done enormous efforts in reducing the block propagation time with efforts like
compact block relay, FIBRE, and the main reason block propagation needs to be
short is it keeps mining more decentralized, it keeps mining more like a
lottery and less like a race; and increase in block propagation can lead to
more miner centralization naturally.

So, stale rate is mostly like a proxy to measure block propagation time, and
the frequency and the shape of the stale branches can tell us something about
the health of the network.  For example, increase could point in slower block
propagation times, or there are any validation bottlenecks or any regressions
that we introduced in the software.  It could also indicate if the network
healed from a partition, or if miners are doing any adversarial mining
strategies like selfish mining.  Famously or infamously, there are certain
mining pools who are trending near the threshold to actually successfully
perform selfish mining.  So, it's purely for observability.  Measuring stale
rate actually does not detect that such an activity is being performed, but it
can help us investigate what's going on in the network.  An added side benefit
is -- sorry, Murch, you had a question?

**Mark Erhardt**: No, just tell us about your added side benefit first.

**Ram**: Yeah, I was about to get to that.  The added side benefit is if the
chain undergoes a reorg, your stale block is already downloaded.  So, it's
just the reorg can be done faster.  You have the block already downloaded and
validated.  So, if the stale block happens to become an active part of the
active chain, the reorg can be done faster as well.  So, that's an added side
benefit.

**Mark Erhardt**: Sorry, could you clarify?  You said that only the tip is
relayed and you talked about headers being relayed, but now you're saying that
the block is already downloaded.  So, do you mean that the entire block is
propagated or just the header?

**Ram**: The staletip message contains a known fork point that the receiver
knows already and the headers leading up to the tip.  So, when the receiver
gets that, they would try to construct the branch, and using the headers, they
would request for the entire block details.

**Mark Erhardt**: I see.  So, I was wondering, one of the concerns maybe with
propagating more data is that there is a DoS vulnerability.  Would you like to
get into why propagating block headers of valid blocks is not a DoS
vulnerability?

**Ram**: Yeah, on mainnet, creating a valid header near the tip requires real
PoW to be done, so that prevents spam.  A malicious actor or malicious peer
may not give you invalid stale tips.  Hopefully, that answers your question.
But one thing it does not prevent is, like, an attacker repeatedly sending
invalid or replayed messages.  In such an event, I think the implementation
has to apply peer-specific limits or global rate limits.

**Mark Erhardt**: Well, we already have protections against invalid messages.
I think we disconnect peers that send us invalid messages.

**Mike Schmidt**: So, Ram, there is some slight behavior change beyond just
relaying this message, right?  You mentioned the side benefit, actually having
that block and doing some behavior, the node is changed other than some
relaying of that observability, okay.

**Ram**: Yeah.  Fabian?

**Fabian Jahr**: Yeah.  I was curious about your choice for using BIP434 for
signaling this, because I think since this is an opt-in feature for
monitoring, basically, I would expect that not a lot of nodes enable this.
So, it would be interesting probably for the nodes to discover each other and
connect, because if a node has a stable block, but then it doesn't have any
other peers that have this feature enabled, then maybe they cannot relay it.
I was just curious about your rationale for this.

**Ram**: Are you suggesting using something where it's discoverable in the
gossip network that a node is capable of this feature before connecting?

**Fabian Jahr**: Yes, exactly.

**Ram**: I think since this was an optional feature, we decided to use 434
mainly because this is an optional feature and it's not something of that
interest.  So, maybe that's something we can follow up in the discussion
actually, yeah.

**Mark Erhardt**: Yeah, it might make sense to explore whether it should be a
service BIP.

**Ram**: Yeah, that was considered.  But I believe because 434 is a good way
to actually negotiate optional features, I think that's what it was
intentioned for, this seemed like a perfect fit for 434.  But if the community
feels there's more interest in getting to know about nodes that advertise
stale tips, we can potentially move to a service BIP.

**Mark Erhardt**: Yeah, I think we can follow up offline.

**Ram**: That's a good question, Fabian, thanks.  I'll keep an eye on it.

**Mike Schmidt**: Ram, what has reception been to the idea?

**Ram**: It's been fairly quiet, mainly sort of coincided just before the
COLDCARD incident, so the community has been distracted since then.  But I've
gotten one-off direct feedback from a couple of developers that they're happy
to see this effort being taken on.  And one thing I should preface this was a
collaborative effort between like AJ Towns, me, and another developer, called
w0xlt.  Feedback has been good so far.

**Mike Schmidt**: I would assume that the BNOC folks, who do a lot of the
monitoring, would be having a strong opinion on wanting to have this
information to be able to analyze the network.

**Ram**: Absolutely, yeah.  I think getting stale tip information has required
special monitoring infrastructure, and there's not many that do it.  0xB10C
has a monitor that's a fork monitor by BitMEX.  So, I know folks who are
interested in P2P monitoring, I think they'll be specifically interested in
this.

**Mike Schmidt**: All right, Ram, anything else before we wrap up this item?

**Ram**: No, that's all I have.  Thank you so much for having me.

**Mike Schmidt**: If listeners are curious, obviously check out the draft and
comment accordingly.  Ram, we appreciate your time.  Thanks for joining us.

**Ram**: Thanks so much.

_CISA for taproot keypath spends (BIP460)_

**Mike Schmidt**: We'll jump back to the Changing consensus segment for, "CISA
for taproot keypath spends (BIP460)".  Fabian, we had you on a few weeks back
to talk about BIP459.  Now, we've got 460.  I think back in 459, you were
careful to say that signature aggregation is separate from the actual
consensus change, right, how you might do the aggregation?  And so, maybe as a
way to introduce 460, we can maybe just quickly summarize 459, and I don't
remember the BIP that came out last year for halfagg.  But maybe you can sort
of tie it all together and distinguish CISA from the other two components?

**Fabian Jahr**: Yeah, the BIP editor has been nice enough to reserve numbers
so we have consecutive numbers.  It's 458, 459, and 460.  So, good to
remember.  So, the signature-aggregation algorithms that we have are
distinctive in the sense that 458, we use half aggregation, which is done on
existing schnorr signatures, so BIP340 signatures.  And these are aggregated
in a process where the result is roughly half the size of the list of the
signatures.  And this process is non-interactive.  And then, in contrast to
that with 459, it's an interactive process where a fully-aggregated signature
is created, which has constant size of 64 bytes, so the same size of a single
signature, independent of how many participants are in that process and how
many signatures would have existed, or how many messages are being signed.
So, the key distinction that I also didn't make clear enough in the BIP
initially, but that we improved on now, is that for the 459, there's no BIP340
signatures existing beforehand.  They never exist.  They basically could exist
in theory, but this aggregate signatures is created in this interactive
process.  And so, these are the two choices that basically are available with
BIP460.

**Mike Schmidt**: You mentioned those two choices, and then there's an
explicit opt-out, right?  So, if you use the new witness version, you could
also choose to not use either aggregation scheme?

**Fabian Jahr**: Right, there's an explicit opt-out that's primarily because
of adaptor signatures, which is basically a way to hide information within a
signature.  And there are a couple of protocols that were built on top of
that, where adoption doesn't seem to be huge, but it's not clear.  I mean,
it's a nice privacy feature, so maybe we don't know about the usage patterns.
And so, yeah, this is definitely a feature that people would like to preserve.
If it's not being used now heavily, maybe potentially in the future it's going
to be used more.  And so, yeah, that's why we want to have a way to opt out to
make sure that on consensus level, a certain signature can be preserved if we
want to.

**Mark Erhardt**: Could you maybe mention how the opt-out works?

**Fabian Jahr**: Yeah, so there's a marker byte, and that basically tells you
explicitly what the inputs are using.  So, for half aggregation, for full
aggregation, and for opt-out, there's a specific marker byte that marks each
of these cases.

**Mark Erhardt**: Isn't that a privacy leak then, indicating which inputs are
using adaptor signatures potentially?

**Fabian Jahr**: Sure, this is one issue with the proposal, I would say, or
I'm not sure if it's really an issue.  If you were to construct very unique
ways of constructing a transaction with a combination, for example, of half
aggregation, full aggregation, and opted-out inputs, then yeah, this looks
very unique and would be a very easy fingerprint to do.  And so, yeah, the
question is, is that really a problem?  Does that prevent potential future
uses of protocols in that way?  I'm not sure.  I think for the DLC use case,
for example, that's I think the biggest use case that I'm aware of for this
kind of protocol.  The information is usually out there anyway, what the
signature is.  I'm not an expert on it, but at least as far as I know.  So,
that potentially would be an example of an adaptor signature where it's fine
that people know that it's an adaptor signature.

**Mike Schmidt**: I think we kind of jumped into some of the mechanics here,
and maybe, given some of the discussions we've had over the years, it's
obvious to people.  But maybe, Fabian, you can articulate for the audience why
this is valuable, and what are the benefits to Bitcoin and Bitcoin users of
doing these types of aggregation?

**Fabian Jahr**: Yeah, so the types of transactions that really profit from
this are transactions that have a lot of inputs.  And with each input so far,
we typically associate a signature.  And when we can reduce the size of the
signatures and aggregate them together, then we can save space.  And space on
the blockchain translates to costs, so we can save a lot of fees with this as
well.  And so, the first kind of transaction that really comes to mind, where
there's a lot of inputs, would be maybe a consolidation transaction from big
businesses.  So, these are a very easy win.  They can save a lot of money when
they consolidate their UTXOs and incentivize further that the UTXO set
shrinks.  But I think the use case that more listeners of the podcast probably
will get excited about is that this also incentivizes usage of coinjoins and
payjoins.  These types of transactions also usually have a quite high number
of inputs.  Best practice, of course, you want to have a high anonymity set.
And so then, these kinds of transactions can be cheaper than they are
currently.  And when you use it correctly, when there's wide adoption, they
can potentially even be cheaper than just doing your own transactions in the
usual way.  So, this is kind of the blockbuster feature, that it makes
privacy-preserving usage of the Bitcoin protocol a lot cheaper.

**Mike Schmidt**: Maybe we could talk to some of the feedback that you've
received.  Can you comment on Adam Gibson's (waxwing), I guess, questioning of
the single-group-per-scheme limit and how you're thinking about that?

**Fabian Jahr**: Yeah.  I think this is probably the most interesting question
about the BIP right now for me, because it's the big question where I'm
flexible to change my mind based on feedback from reviewers.  So, right now,
what the BIP prescribes is basically you can have one half-aggregation group,
so one bucket basically where signatures are put into it and then aggregated
into one half-aggregated signature; you can have one full-aggregation bucket,
where a bunch of potential signatures are aggregated into one full-aggregated
signature; and you can have as many as you want of these opt-outs.  But you
cannot have two full-aggregated signatures, for example, two full-aggregated
groups.  And so, waxwing's question was, "Why not have this as well?"  And my
answer to it is basically that I don't really see a good use case for it.  For
half aggregation, it doesn't make sense anyway, because since it's
non-interactive; you could just do it anyway.  There's no reason not to do it,
basically.  Two buckets really don't make any sense.  But with full
aggregation, it could maybe make sense, but I don't think anyone really has
come up with a good use case for this.  Murch, do you have a comment?

**Mark Erhardt**: Yeah, I mean if you're building a transaction with multiple
users, so maybe the idea would be that you have two groups of people that want
to build a transaction together, and each of the groups wants to aggregate
their transactions together and then add them to one transaction.  So, a
second signature versus just one signature is just 64 bytes' difference.  If
there's a lot of inputs for both of these, they could just make their own
transactions in the first place.  And otherwise, they're already collaborating
to create a PSBT, sending that around, adding the signatures, finalizing
together.  So, why wouldn't they be able to also aggregate the signatures
together into a single group?  So, I think I haven't thought that deeply about
it, but I'm not sure I see why having two groups would make more sense, if
you're already collaborating to create a transaction together.

**Fabian Jahr**: Yeah.  The only fun part about it, we were musing about this
a bit on the mailing list, is that if you would have multiple fully-aggregated
groups, then you could half aggregate the signatures of these again, probably;
there's no proof for that.  But yeah, I think we want to keep complexity, of
course, low.  This is already a complicated enough proposal.  So, unless
somebody has a really good idea of how this could be used, then we should
probably rather leave it at that.  But going away from complexity, there's
basically the other side that I want to talk about as well, which wasn't on
the mailing list, I think, but I received this feedback in another venue as
well.  So, there's also a potential idea to step in the other direction and go
simpler than the proposal is currently.  And that would be to say, "Okay, we
can only either have a full aggregation of the full transaction of all the
inputs that are here; or we can have one half aggregation of all of the
signatures or inputs that are in here; or nothing, basically, full-opt out,
basically", and that would allow us to save these markers.  But we would then
basically have no flexibility.

So, in this case, early on when I had the first draft of this BIP, I asked
around for some feedback on the value of this kind of flexibility.  And people
generally said that they would like to have this flexibility for potential
more interesting use cases.  However, if people strongly advocate for the even
simpler version, then I would be very happy to consider it, because for the
blockbuster use cases that are just laid out for these consolidation
transactions and for payjoin, coinjoin, at least in the plain way that you can
imagine, these work as well.

**Mike Schmidt**: Fabian, I think when people hear, "Draft BIP", they're
thinking of reading the text on the PR, but there's other work that you've
done as part of the PR.  Can you talk about secp256k1 lab and what's in there,
and maybe also what other development has been going on around this proposal?

**Fabian Jahr**: Yeah, I mean personally, I just always feel a lot more secure
to look at code than to look at prose text.  That just gives me security to
see that actually works, what I'm thinking about.  So, pretty early on, I
started to implement stuff.  There was already a half-aggregation PR to secp
ZKP pretty early on, which was built by somebody working for Blockstream
temporarily.  And I ported this to secp and I maintain this PR.  There's a
full-aggregation PR to the secp repository, which I have built, which is
implementing the DahLIAS protocol.  And then, I don't think I've actually
opened the PR yet, but there's a draft branch for the implementation of the
CISA transaction-wide proposal in Bitcoin Core.  And you mentioned secp lab.
So, I haven't really done anything directly within secp lab, but I've used
secp lab basically as the dependency to then build on top of the reference
implementations in Python, within each of the BIPs.  So, that's a nice way to
make it simpler, kind of has turned out to be the standard of similar BIPs in
the recent past.  And so, I had the initial Python implementations standalone,
but then basically put all of them on top of that.  And the CISA
transaction-wide implementation then pulls in each of these implementations
and then builds on top of that.

**Mike Schmidt**: Excellent.  Yeah, I wanted to bring that up because I think
listeners may be interested in the BIP text, but there's also functioning code
that potentially listeners would want to play with or do something different
with.  And so, yeah, I guess call to action for people to jump into that as
well.  Fabian, anything else you'd say as we wrap up this item?

**Fabian Jahr**: No.  Just very happy to receive further feedback.  I know
other things have been on people's minds in the last two weeks, but I'm also
very happy.  It already came up here earlier in the call.  I initially
actually thought that when I finally go out and talk about this more publicly,
that post-quantum people would but just tell me that I'm an idiot to still
work on this obsolete technology.  But actually, as Conduition has also said,
there's potentially even ways to potentially have them work together and
actually make each other stronger, which is very interesting.  And I
personally haven't really spent that much time on post-quantum stuff, I just
followed it from the sidelines, but that wasn't fully possible all the time.
But yeah, I'm going to look into this further in the future and explore as
well the ideas that we discussed already.

**Mark Erhardt**: I think there is an interesting synergy there with
potentially creating a financial incentive for post-quantum adoption.  And
since the scriptpath is already excluded from the aggregation anyway, it
doesn't really matter much if there's post-quantum leaves or EC leaves in the
script tree.  So, yeah, I hadn't considered that, but that's actually an
interesting, nice little synergy.

**Fabian Jahr**: Yeah, I agree.

**Mike Schmidt**: Fabian, thanks for your time, thanks for your work on these
proposals.  If you have other things you're working on, you're free to drop,
but we appreciate your time.

**Fabian Jahr**: Thanks for having me.

_Segwit commitment to post-quantum witness data_

**Mike Schmidt**: Cheers.  Next item from our Changing consensus segment
titled, "Segwit commitment to post-quantum witness data".  This was, I
believe, a Pieter Wuille post as well, and maybe we'll set the stage here.  We
don't have a guest for this one, but we talked about how post-quantum
signatures are of larger size, even though there's been a lot of research to
decrease those.  And if Bitcoin were to adopt those signatures, they'll need
to live somewhere inside the transactions.  And I guess maybe the obvious
answer might be to put on a second witness area, the way that segwit added the
first one many years ago.  But there's some overhead that Pieter brought up in
terms of costs to the community, in terms of being able to deploy that.  And I
think it really focuses around potentially having a third transaction
identifier.  So, we have txids, segwit, then you have witness, your wtxids,
you have new coinbase commitments, all kinds of things that change in the
mining software, P2P logic.  And so, juggling a third ID then for every
transaction I think is, in Pieter's mind, a little bit prohibitive or a
challenge that should be worth putting some time towards eliminating.  Maybe
I'll pause there.  Murch?

**Mark Erhardt**: Yeah, it would just be a lot of extra work.  And so, from my
superficial understanding of this proposal, just adding the commitment to the
witness data instead of committing at the non-witness level to the quantum
section, would allow the wtxid to cover the additional data.  And that way, we
wouldn't need all of that overhead.  We could still continue to do P2P
transaction traffic based on wtxids, the witness commitment would still
suffice.  So, we would still have a new section for the quantum data, but it
would be committed to in the witness data.  And that way, it would be easier
and maybe less work to roll out.  I didn't anticipate it, because Pieter had
been saying for a few years that he was going to let other people have their
turn with proposing protocol changes and working on it, but I'm pretty happy
that Pieter has recently picked up an interest on the whole quantum topic,
because he brings a lot of experience to the design of such proposals.

**Mike Schmidt**: Well, I think he just said it was a shower thought or
something.  So, yeah, he's still not involved, he's just having a shower
thought, that's all.  Maybe to elaborate slightly, I think what he's talking
about here, instead of having this new txid, he's having this idea of styles
where style 0 would be today's segwit, and then style 1 in this brainstorm
would be post-quantum data; and then, in theory, you would have more styles,
values 2 and above, for future usage.  And then there was a note that nodes
that don't understand a certain style could be shown the valid style 0
commitment instead, so un-upgraded nodes can continue to keep working.  There
was some feedback here from AJ Towns comparing the different styles to
distinct authorization weight formulas.  And then he also suggested
annex-based commitments potentially as well and some potential advantages
there.

**Mark Erhardt**: Yeah, so one of the points is that if we had humongous
quantum signatures, we might be interested in having a different discount for
the quantum section.  Because let's face it, currently our signatures take 64
bytes, but they only weigh 16 vbytes.  And if we moved to a scheme that had
maybe 3,000 bytes of signatures and 2,000 bytes of public keys or similar,
with 5,000 bytes per input, we would drastically reduce the throughput on the
Bitcoin Network.  Now, currently, blockspace is a little under-demanded maybe,
with feerates being around a 0.25 sat/vB (satoshis per vbyte).  But if the
quantum data were that expensive and quantum inputs introduced such large
outputs, I think we might overshoot, and blockspace demand would go through
the roof, or feerates would go through the roof as the blockspace market would
be much more competitive.

**Mike Schmidt**: Yeah, so I think, yeah, maybe to wrap up and riff off of
what Murch just said, so what Pieter's saying, this idea of a style and the
approach to doing this is still going to require a soft fork.  And you're
still going to have the storage question, like Murch mentioned.  You're still
going to have P2P upgrades as part of something like this.  But the win that
he is getting at is to avoid this new transaction identifier, which has the
invasive parts that we mentioned earlier in the discussion.  Anything else on
this one, Murch or Gustavo?  Okay.

_Input-triggered transaction expiry_

**Mike Schmidt**: "Input triggered transaction expiry".  Murch, you have a bit
of a lead.

**Mark Erhardt**: Well, so my understanding is that the problem that leads to
this proposal is if you have transactions that expire, you could use this
expiration to freely relay data across the network.  And then, before the
transaction actually is eligible or interesting to include in blocks, it would
expire and not be allowed; or it would be a free relay vector.  So, this
proposal is trying to introduce an expiration for transactions that is based
on when the parent transaction confirmed, so there would always be some cost
to the user of this transaction.  And that was roughly what I took out of it.

**Mike Schmidt**: Murch, the cost being the parent transaction confirming, and
thus the fees paid, as opposed to just relaying transactions that don't have a
related parent that is confirmed?  Is that the idea?

**Mark Erhardt**: Yeah, maybe.  Honestly, I struggled a bit with this item.
Generally, there was a lot of pushback against expire opcodes because of (a)
the free relay problem, and (b) it could introduce some hard-to-analyze game
theory around juicy transactions being about to expire, and people maybe
reorging in order to mine a block that could include a transaction that just
expired.  Generally, the only form of expiration we have so far is by creating
a conflicting transaction that spends one of the inputs, which makes the
expiring transaction invalid instead.  And yeah, I stared at this one a bit,
but this is the best I have for explaining what's going on here.

**Mike Schmidt**: I don't have the newsletter number or podcast number handy,
but we did have similar proposals, absolute expiry proposals, like Peter
Todd's OP_EXPIRE, that would make a valid transaction later invalid.  You
still have the cheap relay of potentially spam, unless policy demands were
nearing next block fees.  There was some consideration around that when we
spoke about that one.  Murch, why do we want to have a transaction that
expires again, at all?  Why are these efforts being put forth at all?  What's
the use case?

**Mark Erhardt**: I guess you kind of want to have the option of things only
becoming invalid after some time in order to do transactions that have options
such as HTLCs (Hash Time Locked Contracts), where as long as a hash is
provided, you can spend it immediately, but after some time, there's a
fallback.  If the payment on the LN, or otherwise, doesn't go through,
eventually the sender gets back their money, right?  So, similarly with
escrows or channel opens or other UTXO-sharing mechanisms, you want to be able
to have a transaction where you commit to something happening, but have a way
to back out if the other person just drops off the face of the earth.  And an
expire construction could sort of bring the other side of this, where you
explicitly say, "I'm happy to do this, but only to that point.  Once that
block passes, I'm no longer in on this.  You have until then to decide", or
something like that, maybe to give a limited time option for something.  But
we sort of can, in a roundabout way, do these things already by having the
backout transaction be an explicit thing that conflicts and eliminates the
first option.  There are just some weird dynamics around having the expiration
with free relay and potentially weird game theory.

_Segregated Data (SegData) BIP draft_

**Mike Schmidt**: I think we can wrap up that item.  We'll move to the last
Changing consensus item this week/month, "Segregated data (SegData) BIP
draft".  Obviously, we've talked a lot as a Bitcoin community over the last
few years about people stuffing arbitrary data into the Bitcoin blockchain
using a variety of mechanisms, OP_RETURN, witness data, it's sort of a
perennial controversy.  This item was from MrHash, who I believe posted to
Delving Bitcoin, a soft fork draft, and he took a different angle on this.  He
says instead of fighting the data we give it, I think people have talked in
the past about it, dedicated garbage can being OP_RETURN.  Maybe this is a
dedicated attic to put this arbitrary data in.  So, this would be a separate
and prunable part of a block designated for data.  And the confusion on my
side is what the incentive is to keep it if you're able to prune it.  Murch, I
know you brought up some questions on this.

**Mark Erhardt**: Yeah, let me try to steelman it a little more first.  So,
the general idea is we know that people will always be able to insert data,
because Bitcoin transactions are based on script.  Programming languages
always have nooks and crannies where you can stuff data in.  So, the idea
would be if we explicitly create the space where people can put data, they
don't have to play games with it, they just put the data there.  And the
adoption incentive would be that it would be slightly cheaper than
currently-established mechanisms, such as witness data stuffing.  So, with the
inscription envelope, of course, you have to have the output that commits to
the data in the first place.  Then, you have an input that fulfills the output
commitment and then has an inscription envelope, for example, where it has the
data.  So, you have the overhead of the additional output and input, and that
is slightly inefficient.  And then, the inscription data itself is, I think,
cut into pieces with OP_PUSHes.  So, by having just an OP_DATA_OUTPUT, or
whatever it would be called exactly, you would be able to directly write to
witness data, or to a section of data that is discounted exactly like witness
data by a factor 4.  But you would lose the overhead of having an output that
commits to it and an input that publishes it, but would just directly commit
with an output to, "Here's a SegData section and you can write whatever data
there".

Now, the way to limit it would be that the SegData counts towards the block
weight limit, but on the other hand is not evaluated, because it's just a
blob, so there's no signatures in it, there's no validation beyond just a hash
that the blob hashes to a specific commitment in the output.  But it would
count towards the weight limit, which means that these people would pay fees
for the blob and would compete for block space for the blob, and thereby be
limited in how much data blob they can insert into blocks.  The initial
construction was proposing that for 100 or 1,000 blocks from the chain tip,
every node is required to have the blob data and serve it.  And then, once the
block falls out of the window at the chain tip, peers or nodes catching up
with IBD (Initial Block Download) wouldn't need to have the blob data, and
thereby it would become automatically prunable after that depth.  I don't
remember if it was 100 or 1,000 blocks.

Some of the people that responded to this idea pointed out that if eventually
it is not required by consensus, it is de facto not required by consensus,
because implementers could just choose to ignore it from the get-go.  And the
proposal was then amended to make the data optional in the first place.  So,
it would still count towards weight and the nodes that implement this optional
data check would check that the data is not too big, or otherwise not accept
the transactions.  But yeah, so I think the main doubt of reviewers here was
if the data is optional, and generally data-embedding doesn't seem to be
super-popular among the Bitcoin ecosystem, except in some NFT-pushing
subsegment, would there even be enough nodes that serve this data?  Otherwise,
why wouldn't the people that want to embed data into the blockchain just embed
it in the witness for a tiny extra cost, and then get full data availability?

Yeah, that's, I think, roughly where people are hung up on.  It's like, sure,
it's just a tiny, little bit cheaper and it's sort of the blessed harm
reduction.  But if the data is not available and it doesn't actually fulfill
the want of the data-embedders, then why would they ever decide to use it?
And is that then worth the effort of making a soft fork?  Yeah.  Any more
questions, comments?  Or I think otherwise, I think that's pretty much where
the discussion was left off.

**Mike Schmidt**: Yeah, I think listeners can jump into the thread.  I think
there was quite a bit of back and forth.  I think Murch summarized the
takeaways from that back and forth nicely.  But if folks are curious about the
proposal, jump into that Delving thread and check the back and forth on the
comments.  That wraps up our Changing consensus segment.  We'll move to
Releases and release candidates.  We have one this week.  I already somewhat
spoiled it, but I won't spoil it further.  What do we have, Gustavo?

**Gustavo Flores Echaiz**: Can you guys hear me well?

**Mike Schmidt**: Yeah.

_Libsecp256k1 0.8.0_

**Gustavo Flores Echaiz**: Perfect.  Yes, this week we have one release,
libsecp256k1 0.8.0.  So, here, we add the new model for silent payments that
we discussed, I believe, two episodes ago.  That is the main component of this
release.  But also, a few newsletters ago, precisely in Newsletter #396, we
talked about a new API function that allows a user to supply a custom SHA256
compression function at runtime.  So, that is also part of this release.  And
additional optimizations, 64-bit field arithmetic that is improved, that
produces signature verification speedups of up to 11% in some builds.

So, also, what I wanted to point at is that we didn't include it in
newsletter, but an important maintenance release from BTCPay Server was
announced the day we drafted this newsletter.  So, users of BTCPay Server are
advised to update to 2.42, particularly if you use LND, because the
vulnerability affects LND users within BTCPay Server.  So, if anybody's
listening that uses BTCPay Server, please update immediately, particularly if
you use LND.  Also, I believe that if upgrading is not sufficient, you should
also be reviewing your macaroon files, which are the credentials for accessing
your LND node, since that vulnerability was around an attacker being able to
obtain those credentials in an unauthenticated and unauthorized way.  So, you
should also consider swapping those credentials in case they were ever
obtained by an attacker.  Yes, Mike?

**Mike Schmidt**: I'm giving you the thumbs up.

**Gustavo Flores Echaiz**: So, we move forward with the next section, Notable
code and documentation changes.  We've got a lot of bug fixes this week.  It
seems to be that we're going to have a few weeks like that, considering all
the new vulnerabilities that are being exposed.

_Bitcoin Core #35501_

The first one, Bitcoin Core #35501, isn't a bug fix.  This is a new feature
that basically allows the Bitcoin Core wallet to store multiple variants of
the same transaction that have the same txid but have different wtxids.  So,
here, previously the wallet would simply ignore any transaction that had the
same txid as one that was already stored, even if it had a different wtxid.
The main goal here is to be able to have multiple variants of the same
transaction in order to compare them related to if we were going to replace a
transaction through, like, a fee bump through RBF, we could look at all the
variants of the transaction and choose the one that would have the lowest
weight, and that would be the one to get fee bumped.  That was one of the
motivations.  But, Murch, please jump here?

**Mark Erhardt**: Yeah.  How could you ever have a fee bump with a transaction
where the txid doesn't change?  I wanted to dig a little bit here.  So,
imagine you had multiple different ways of spending a P2TR output.  For
example, you could have a scriptpath output that is a 2-of-3 multisig, which
is maybe a little more sizable.  But then, after the two participants that can
sign for the 2-of-3 multisig sign for that transaction input, the third party
comes online and you manage to instead make a keypath spend that uses the
MuSig that is stored in the keypath of all three signers.  And now, you only
have to pay for a keypath input instead of a scriptpath input.  And you could
do that without changing the txid, just changing the witness data to the
single-signature instead of revealing in the input where that script leaf was,
the script leaf script, and the 2-of-3 multisig construction and their
signatures; you would replace all that with a single MuSig signature.  So now,
the transaction would have the same txid, the same inputs and outputs, the
same fee paid, but the witness data would be smaller and thus the transaction
might have sufficiently higher feerate to replace the original.

If that happened previously, I'm not entirely sure, I think that we did
propagate transactions with different wtxids and they could replace others.
But honestly, don't nail me down on that.  But now, your wallet would be able
to store more than one of those in Bitcoin Core.

**Gustavo Flores Echaiz**: Very interesting.  Thank you, Murch, for that extra
detail.  Well, I was wondering if there are other cases where this happens.
For example, if you were to use a high-S signature versus a low-S signature,
would that also produce a similar situation where the txid is the same, but
the wtxid is different?

**Mark Erhardt**: Correct.  The wtxid is malleable.  I think that high-S are
not consensus-valid though in segwit.  But I'm happy to be corrected in the
comments below!

**Gustavo Flores Echaiz**: Yeah, I'm pretty sure that's the case for taproot
specifically; and in segwit, they're non-standard but they're still
consensus-valid.  So, yeah, the goal of this item is now for the wallet to
store all the variants.  There's still one that is chosen as canonical.  It is
often the one that is confirmed.  But if none is confirmed, then it's the one
that contains witness data.  And if multiple transactions contain witness
data, then it's the one with the lowest weight.  Now, this is also exposed to
several RPC commands, gettransaction, listtransactions, and listsinceblock.
Those RPC commands now report these variants in a new field called
alternate_wtxids.

_Core Lightning #9298_

So, that's for the Bitcoin Core repo, and the next items are from Core
Lightning (CLN), Eclair, LND, and Rust Bitcoin and BTCPay Server.  We begin
with Core Lightning #9298.  This item is about the advancement to migrating to
a new system called bwatch.  So, bwatch is an experimental blockchain-watching
plugin that moves the block polling and the transaction filtering logic out of
lightningd.  So, the intention here of bwatch is to move away from an
implementation in lightningd that was storing unnecessarily a lot of the
blockchain data that was already present in the blockchain node we connect to.
Lightningd was simply replicating a lot of that data, storing unnecessarily
data.  Now instead, lightningd simply tells bwatch, "Can you watch these
transactions for me, the scriptPubKeys, and also track these UTXOs, and bwatch
will connect to the Bitcoin node and will let the lightningd know when a
transaction is found that matches its requirements".  And also, this allows
eventually another system could be integrated, since this is now abstracted.
Bwatch is simply the first implementation of an external system that is
monitoring the blockchain, but the surface could allow for another plugin to
play that role instead of bwatch.

So, this PR specifically moves the wallet transaction and the UTXO tracking to
this new system, by introducing new tables in bwatch, specifically our_outputs
and our_txs.  However, these are temporarily mirrored still to lightningd, to
the legacy tables.  So, for example, if you were to use bwatch and you would
like to downgrade back to the previous implementation, you could easily still
go back and forth, since all this data is still mirrored to the previous
tables.  So, this is an experimental feature that requires activation with a
specific flag called -experimental-bwatch.

_Core Lightning #9353_

Next item, still from the CLN repo, #9353.  Here, this is a bug fix where
previously, sendpay, which is a CLN RPC command for sending a payment, it now
returns an RPC error when the combined payload of each hop doesn't fit the
limit that is defined by BOLT4, which basically says that the combined per-hop
payload cannot exceed 1,300 bytes.  So, previous, it would simply return a
null result, and it would later cause the daemon to crash.  So now, this is
just an error-handling that avoids a potential crash when the combined per-hop
payload exceeds the limit that is defined by BOLT4.  So, just a simple fix to
ensure that the node doesn't crash.

_Eclair #3336_

The next item, Eclair #3336.  Here, there was an issue where if a peer or a
component within the Eclair node duplicated an HTLC settlement message, and
that message was added multiple times to the proposed remote commitment
changes, then when exchanging commit signature messages with the peer and
receiving a signature that didn't match the remote commitment change state
that we had stored that had duplicate messages, then that could lead Eclair to
a potential force close of that channel, when it would basically see that
there was a mismatch between the signature that it received from its peer and
what it stored as remote commitment changes.  So now, Eclair simply prevents
that duplicate message from updating the state that it has for the remote
commitment changes.  So, later on, when it exchanges signatures with the peer,
there's no mismatch that was caused from that duplicate message, and then
there's also no force close of that channel.  So, here, once again, a small
technicality that would lead to an issue.  And now, that is fixed to avoid
Eclair unnecessarily force closing a channel.

_LND #10942_

The next item, LND #10942.  Here, this is a new feature that LND didn't have,
which is when forwarding an HTLC on specifically a blinded payment path, the
encrypted recipient data can identify the next hop using its node ID or its
SCID.  When forwarding an HTLC on a blind payment path, LND was always
expecting that the recipient data would identify the next hop through the
SCID.  However, CLN uses the next_node_id format, which basically would let a
node know, "Hey, this is the node ID", and the node, LND for example, has to
choose a specific channel to forward the HTLC from.  So, this is simply an
update in the LND implementation to now accept next_node_id on top of
short_channel_id.  And this enables LND to be interoperable with CLN when
forwarding an HTLC on a blinded payment path.

I would also like to specify that LND has implemented blinded paths for a
while, but only for BOLT11 payments, and the BOLT12 implementation is right
now being built.  However, it's not finalized.  But this is a fix that would
require once LND ships BOLT12 payments, then it will be interoperable with
CLN.

_LND #10992_

The next item, LND #10992.  Here, there's a new limit that is added when an
LND node is just syncing with the chain and sends a message called
query_channel_range.  This request message is sent to a peer to obtain the
channel announcements and synchronize with the state of the LN.  However,
previously, the bound of the memory used when synchronizing these channel
announcement messages was extremely big, which could cause an attacker to send
to LND a huge amount of fake channel announcements that could potentially
cause an LND node to run out of memory and potentially even crash.  So, the
attack and the issue wasn't necessarily identified.  This is more a
theoretical analysis, at least it seems so from what has been disclosed so
far.  But now, there's a new limit, and LND now simply accepts a maximum of
100,000 SCIDs per message, or in aggregate for a single query; it's the same
limit as well.

The reason why this amount of 100,000 was chosen is because currently, the LN
has an amount of channels that is lower than that.  I believe, when I last
checked, it was closer to 60,000 channels.  Although it has gone higher in the
past, it has never surpassed 100,000.  So, it is expected from the discussion
in the PR that the LND maintainers would update this limit if it ever came
that the LN would have a higher amount of channels than the one it is limited
at now.  So now, your LND node would simply not even accept a message that has
more than a 100 SCIDs in a single.

_Rust Bitcoin #6364_

Next item, now we get to the Rust Bitcoin repo.  So, the first item, #6364,
this is a new feature that is added to Rust Bitcoin, where support for
encoding and decoding BIP434 messages is now implemented.  So, BIP434, as
we've discussed in Newsletter #386 and #390, is a protocol that defines a
specific P2P message, called feature, that allows peers to announce and
negotiate supports for new features.  So, Rust Bitcoin simply implements the
basic message infrastructure, the wiring required for implementing BIP434.
Compared to Bitcoin Core's implementation, this is simply the first phase of
that implementation.  Bitcoin Core also implemented the negotiation mechanism,
where feature has to be sent between version and verack.  So, however, in the
Rust Bitcoin case, only the encoding and decoding support for this type of
message is implemented.  And I believe because Rust Bitcoin is simply a
library and not specifically a node implementation, that is also part of the
reasoning why it has only implemented this level of support.

_Rust Bitcoin #6642_

Next item, still on the Rust Bitcoin repo, #6642.  Here, another bug fix.  So,
Rust Bitcoin has a specific limit to each transaction witness element, and it
caps that limit at 4 MB.  That limit, of course, is derived from the fact that
a Bitcoin block can never be bigger than 4 MB if it had a
four-million-weight-unit block limit.  However, Rust Bitcoin will, of course,
never accept in the end the witness element that is 4 MB, because there are
other rules that cap the transaction size and even the witness element size.
But when receiving a transaction from a peer or from an external source, Rust
Bitcoin will first run a check that each witness element cannot be bigger than
4 MB.  However, when decoding a transaction, the bug was that the limit was
only applied for the first witness element. and further witness elements would
reset to a default larger limit of 32 MiB.  But the point is that the second
and the third, and so on, witness elements would have a larger limit and, for
example, they could pass higher than 4 MB.  And this was still bound to the
P2P message limit of 5 MB.  So, it was impossible for a witness element to be
higher than 5 MB because of the P2P message limit.  However, the second
witness element could be between 4 and almost 5 MB in size.

The problem was that if an attacker sent us a transaction with a witness
element that was between 4 and 5 MB, not the first one, but the ulterior ones,
they were not properly caught.  And then, it would lead to an inconsistent
state that could cause a panic, because some code would simply count the
witness element amount, so it would say there's four witness elements here.
But because they were bursting through the expected limit of 4 MB, they were
not properly rendered after being decoded.  So, that could lead to a panic,
and specifically it was noted that it would happen in the case of a taproot
spend.  So now, Rust Bitcoin simply makes sure that this 4-MB size limit is
now applied at each witness element.  It never gets dropped after the first
element, so that later on after decoding, because it would be accepted during
decoding, it wouldn't lead to the inconsistent state that would then cause the
panic.  So now, during decoding, we just catch those witness elements that are
higher than the limit and simply reject them before going deeper down in the
process.

_BTCPay Server #7491_

So, now we get to the two final items of this newsletter, both from the BTCPay
Server repository.  So, the first one is a bug fix in the authentication
system of the Greenfield API.  So, it was observed that an attacker could
potentially bypass the 2FA when in the authentication handler of the API, if
you had set up specifically time-based one-time passwords (TOTP) for FIDO2
2FA, which is also known and referred to as passkey authentication.  That was
properly handled.  However, an attacker could bypass the TOTP 2FA.  There's
another item that I didn't put here, but now also, basic authentication is now
disabled for the first five minutes of the user account creation.  So, this is
in combination with this.  This is item #7492, but it comes together with
#7491, where #7491, like I explained, fixes the issue that you could bypass
the TOTP for 2FA.  But #7492 comes together with it, because it also disables
basic authentication, which means email and password, by default five minutes
after account creation.

_BTCPay Server #7488_

And the final item from the BTCPay Server repo and the final item of this list
is #7488, which improves signing compatibility with the latest version of the
Blockstream Jade, when used with newer HWI versions.  Here, the fix is simply
to add witness UTXO fields to segwit inputs when the PSBT already contains the
corresponding previous transaction in non_witness_utxo.  So, this resolves an
issue with the Blockstream Jade specifically.  And also, there's another fix
where in the user interface, a multisig transaction would appear as pending,
even though it had already been properly signed and finalized by all, the
signing had been finalized by all parties.  So now, the fix makes it so that
the signing status doesn't become stale and properly updates when it has been
properly signed.  It will display as so instead of remaining pending forever.
So, that's the last item of this list and that completes the Newsletter and
the episode.

**Mike Schmidt**: Thanks Gustavo for walking us through that and also for
co-hosting, and thank you, Murch, also for co-hosting.  And we want to thank
Conduition, Fabian and Ram for joining us on this episode and for you all for
listening.  Cheers.

{% include references.md %}
