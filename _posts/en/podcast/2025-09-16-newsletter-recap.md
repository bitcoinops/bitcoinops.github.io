---
title: 'Bitcoin Optech Newsletter #371 Recap Podcast'
permalink: /en/podcast/2025/09/16/
reference: /en/newsletters/2025/09/12/
name: 2025-09-16-recap
slug: 2025-09-16-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Jonas Nick and Bastien
Teinturier to discuss [Newsletter #371]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-8-16/407600787-44100-2-853167a259869.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Optech 371 Recap. We're going to talk about a
workbook for learning cryptography, the Eclair 0.13 release, the release
candidate for Bitcoin Core 30, and our Notable code segment, including a bunch
of Eclair PRs that t-bast is going to walk us through, amongst some other
things.  Murch and I are joined this week by two guests.  First, Jonas.  Jonas,
you want to say hi?

**Jonas Nick**: Hello everyone, I'm Jonas, I work at Blockstream's research
group, and mainly focused on cryptography.

**Mike Schmidt**: And then, we're also joined by Bastien, or t-bast.

**Bastien Teinturier**: Hi, I'm Bastien, I'm working on Lightning at ACINQ on
the spec and implementations.

_Provable Cryptography Workbook_

**Mike Schmidt**: Well, thank you both for joining us.  We're going to jump into
the News segment.  One news item, this week, "Provable Cryptography Workbook."
Jonas, you posted to Delving Bitcoin, and you provided a summary of the goals
and contents of a workbook that you released on GitHub, that focuses on teaching
developers the basics of provable cryptography.  What did you set out to do with
this workbook, and also the Crypto Camp event?

**Jonas Nick**: Yeah, so this workbook was actually developed for this Crypto
Camp event that you mentioned.  It was an interactive, in-person workshop, and
the workbook was kind of the basis for that.  The workbook itself is something
that cannot only be used for this workshop, but also for self-study, or maybe
even in groups, after this event.  The workbook contains mathematical
definitions, propositions, lemmas, theorems and exercises, and there's also a
solutionbook with solutions to these exercises.  And the workbook, it covers
selected topics in Bitcoin cryptography.  I think that's also one of the
advantages of this workbook over a standard cryptography textbook, which of
course also exists and people can work through those as well.  But for example,
what we cover in the workbook is very focused on Bitcoin, onchain consensus
mainly, and for example, there's, I believe, almost no mention of encryption,
which is usually a fundamental part of cryptography textbooks.  So, we skipped
that part, because in the Bitcoin consensus protocol, we don't make use of that.

When we wrote this workbook, we had two primary goals.  One was once someone
would have worked through the workbook, they would have sufficient understanding
for reading state-of-the-art papers in the cryptography space, mainly around
signatures, multiparty signatures like DahLIAS Interactive Aggregate Signature
Scheme, MuSig, FROST, etc, and not only read the introduction, but also be able
to understand the meat of these papers, like the security definitions and the
proofs.  And the second goal was to learn the skills that are necessary to
formalize security notions for various cryptographic primitives.  and I think
this skill is helpful when designing, proposing cryptographic protocols, and
also when reviewing that, because then you can really precisely define what you
mean when you say, "The scheme is secure", or, "I need this primitive with
fulfilling this property XYZ.

**Mike Schmidt**: What is the mechanics of the workbook?  It's not one of these
Python notebooks that I've seen, is it?  Is it something different?

**Jonas Nick**: No, the workbook is a PDF, which looks a little bit like your
cryptographic paper.  And the notation is also very similar to what we're using,
for example, in MuSig2 and DahLIAS.

**Mike Schmidt**: So, this is a pipeline, Jonas, you want more review on your
work, so you're getting a pipeline of cryptographers to be educated on how to
read these materials and provide review, huh?

**Jonas Nick**: Yes, I think, as I said, it's helpful for reviewing BIPs,
writing BIPs, and things like that.  Because if someone were to propose, let's
say, using interactive signature creation for Bitcoin, then if you had worked
through the workbook, you would understand why the scheme is secure and what it
means to be secure and under what conditions it is secure.  And I think that's
helpful knowledge in the Bitcoin space overall.  And the way this is set up is,
it starts with kind of trying to develop an intuition for what it means for a
thing to be secure.  What do we mean by security?  And perhaps a lot of people
have some background in cryptography, at least on the practical side, but
they've often not seen how to properly mathematically formalize it.  But we need
to formalize it if we want to write proofs, right?  So, the first section is
about that, and there are some things that seem to be weird.  For example, under
the definitions that we give in this first section, SHA256, for example, is not
secure and it's not even a hash function.

**Mike Schmidt**: I think you're going to have to elaborate on that one.

**Jonas Nick**: Yeah, so I would refer to the workbook for that.

**Mike Schmidt**: Oh, I see.

**Jonas Nick**: It appears in the very first section.  The prerequisites,
perhaps that's also important to mention, is that some basic understanding of
probability theory you would need, like conditional probabilities, sometimes you
need to apply what we call the union bound, and other than that, modular
arithmetic that we've seen, if you add some numbers and you take the modulus
after that, and that gives you a new number.  And the kind of approach that
we're trying to take is that cryptography is, in some sense, really close to
programming, because all you're doing in cryptography is writing algorithms and
analyzing algorithms.  That's where the probability theory comes in, because you
need to analyze what is the probability that this algorithm will give the
correct result; also, what is its runtime?  And programmers, they already have a
good understanding for how to write code, because that's what they're doing.

**Mike Schmidt**: Now, you mentioned that the focus is cryptography primitives
related to onchain.  Would you say that folks working on LN would still benefit
from understanding that sort of base level understanding of the cryptography?
And obviously, there's things then that are maybe in addition in the LN world.

**Jonas Nick**: Yeah, I think there are some things that definitely also appear
in the LN world, like chapter 3 is about commitments that is also a basic thing
in the LN world.  And also, on a higher level, if you look at cryptographic
papers in this field of LN, then there are proofs that would look similar to
what we're doing in the workbook overall.  So, this would definitely also help
you understanding these kinds of papers.

**Mike Schmidt**: Is there anything you learned from putting on the Crypto Camp
that influenced the current iteration of the workbook, or did that basically go
well and this is the material that you used for it?

**Jonas Nick**: I think, so what I learned when doing the workbook was I think I
did a lot of basic stuff again that I had forgotten about.  If you really think
through the foundations of why this all works, I think this is really
interesting and very beautiful even, I would say, at its core, so that was just
really fun to work on.  The one other thing I learned was that LLMs these days,
the AI, they're really good.  So, if you want to work through the workbook and
you're getting stuck, you can take a picture of the page with the exercise and
ask the LLM to give you hints.  Most of the time, it will give you very sensible
hints.  So, I think that's a good idea to work through.  If you want to work
through the workbook and don't find a group, I think that's a good way to get
unstuck.  As for future learnings, this is currently a project on GitHub, it's
all open source, it's licensed under CC0.  So, if there are any mistakes or
anything, I accept PRs.  There's also a branch for an additional section that
I'm not sure we're going to merge, but it's like sort of work in progress.  And
yeah, this only covers the basics.  Maybe someone wants to do a second edition
of this as well.

**Mike Schmidt**: Murch, did you have any questions or comments?

**Mark Erhardt**: Sounds great.

**Mike Schmidt**: All right.  Well, Jonas, thanks for joining us.  You're
welcome to stay on if you want to hear about the rest of the items from the
newsletter.  Otherwise, we appreciate your time and your work on putting this
out to the community.

**Jonas Nick**: Yeah, great.  Thanks.

**Mike Schmidt**: There was no PR Review Club, which would have been our normal
segment this month to cover.  I don't think there were any meetings for the Peer
Review Club since we last did it, for whatever reason.  So, that, if you're
looking for it, is not present this week.  So, we'll move to the Releases and
release candidates segment.

_Bitcoin Core 29.1_

We have Bitcoin Core 29.1, which is the maintenance release that we had actually
spoken about last week, that includes changes to the default min_relay_fee_rate
as well as safety caps on resources, on 32-bit systems, and obviously all of
that is in addition to bug fixes that are in there as well.  Murch, did you have
anything else you wanted to add on that this week?

**Mark Erhardt**: No, we covered that last week already, right?

_Eclair v0.13.0_

**Mike Schmidt**: Yeah.  Eclair v0.13.0.  We have t-bast on to walk us through
this one.  Talk to us about v0.13.

**Bastien Teinturier**: Okay, so this new release doesn't ship so many features,
but it prepares shipping many new ones basically, because we are at a stage in
LN where a lot of the things we had been discussing for the past three to four
years are nearing completion, and most features, we have them implemented in one
implementation and are waiting for other implementations to also finalize their
implementation so that we can officially ship them.  But most of the things are
already there.  And interesting, for example, splicing is something that we
shipped two years ago in Phoenix and we're just waiting for another
implementation to finalize their work.  And CLN (Core Lightning) and LDK are
actually quite close to that.  So, I hope that by the next release or the
release after that, we're going to be able to ship a splicing implementation
that works across the network.  Same thing for dual-funding, same thing for
eventually liquidity ads.  So, there's a lot of things that have been
progressing quite well.

But the things that we would like to really focus on and that will matter a lot
for most node operators today is upgrading the transactions we create for LN
channels, and benefiting from, first of all, taproot, for example, and this is
something that LND had started working on a long time ago and we have started
working on as well.  And so, in that release, we are almost complete on taproot.
We're just not activating it yet because there are small incompatibilities with
LND that we need to resolve, and the spec is lacking on some of those
incompatibilities.  But we had to do a lot of basically refactoring to make sure
that we were able to support all the channel types, the type of channel
transactions that we support today, plus the one for taproot, and then more
importantly, the next ones that are going to use v3 transactions without taproot
and v3 transactions with taproot, the end goal being preparing our codebase and
our end nodes to gradually evolve towards using v3 taproot transactions, which
is going to be the final form, at least for the next year of LN channels.  You
had a question, Murch?

**Mark Erhardt**: Yeah, I wanted to jump in quickly.  I was aware that Lightning
Labs had been working on a concept called simple taproot channels, then there
were several iterations, I think something called taproot channels 1.5 and 1.75.
Can you walk us through what the final version of the taproot channels that
you're rolling out will be now?

**Bastien Teinturier**: Okay, so those 1.5 and 1.75 were mostly for the gossip,
for what we announce, what we change in the gossip, especially to fix one big
privacy issue we have on LN, which is that we gossip.  One of the interests of
using taproot and MuSig2 for the channels is that the channel output is just
going to be a standard P2TR output that is spent by single-signature, and people
don't have to know that it is actually using MuSig 2 and is an LN channel.  But
then, so when we start using that in LN, it looks like we are gaining privacy,
but then we are losing everything by just revealing to the world in the LN
gossip network, "Hey, by the way, this is my channel.  Please route payments
over this".

So, the first step is to change the structure of the LN transactions to actually
use taproot and use MuSig2, and this is what is in the simple taproot BOLT.
It's just changing the transactions used in LN channels to use MuSig2 for the
funding output.  And then we said, "Yeah, but this is not enough.  We need to
fix the privacy leak in the gossip network".  And so, for updating the gossip,
there are several proposals: 1.5, which doesn't fix anything related to privacy,
but changes the format so that we're more flexible in the future and we can
improve more things in the future; then 1.75, I don't even remember exactly what
we changed in that one; and 2.0 is the eventual end goal, where we don't reveal
the outpoints of the channel, the UTXOs of the channel, but instead some kind of
zero-knowledge proof that we have a channel somewhere among a set of UTXOs that
has maybe some capacity, and it should allow us to advertise virtual channels
basically.

But what we've been working on so far mainly is only the simple taproot thing,
which is only updating the LN transactions, and first only supports private
channels, unannounced channels so far.  And what has been implemented in LND and
Eclair doesn't support announcing those channels yet, and this will come in a
second phase.  It's only working on the transaction layer so that we have better
usage of our transactions and better fee management, and then gossip will come
afterwards.

**Mark Erhardt**: Could you remind me, the channels that the Eclair node makes
with the Phoenix customers, are those private channels or are those public
channels?

**Bastien Teinturier**: Yeah, those are private channels.  So, that's why we
have started working on taproot because we're going to be able to ship quickly
because those are channels that we don't announce to the network.  So, as soon
as we have compatibility with LND on these taproot transactions, we're going to
be able to immediately roll it out to Phoenix users and opportunistically
update, upgrade their existing channels whenever there's a splice.  So,
basically, whenever there's a splice on the Phoenix channel, that was previously
using just anchor outputs, we're going to take this opportunity of making an
onchain transaction to actually move it to a MuSig2 output.  So, slowly we will
be able to upgrade Phoenix users to use MuSig2 as their funding output.

**Mark Erhardt**: Very cool, very cool.

**Bastien Teinturier**: And then the end goal in that big refactoring, we also,
in that release, announced that we are going to stop supporting channels that do
not use anchor outputs and use previous versions of LN channels, so what was
called static remote key and the even older just plain legacy channel.  The
issues with those type of channels is that since they didn't use anchor outputs,
they didn't have any way to do CPFP and we had to just predict the feerate and
update regularly the feerate of a commitment transaction.  So, it's been at
least two years, I think, that every implementation has shipped support for
anchor outputs.  But some people have channels that are older than that.

So, I spent the past year encouraging people to take the opportunity of an empty
mempool to close all those legacy channels and open new ones that use anchor
outputs.  And this release of Eclair is going to be the last one where we
support these old channels.  We're going to remove the code for those in the
next release.  So, people have to close them now if they want to be able to
upgrade to the 0.14 release later.  So far, all node operators have told me that
they had already closed those channels a long time ago and only have anchor
outputs channels.  But there are still channels on the network that are not
using anchor outputs.  So, people should really update because before adding
even more transaction types, when we start using v3 as well, we need to be able
to clean up some technical debt and to clean up some old code so that we can
manage the complexity and still get a good coverage of everything.

**Mark Erhardt**: Cool.  So, there's basically two migrations going on at the
same time, just getting people into anchor output channels, which is ancient
history already; and now also, with TRUC (Topologically Restricted Until
Confirmation) and ephemeral anchors, the idea of having zero-fee commitment
transactions finally is here, or the idea was here for a long time, the
implementation is here now too.  Maybe just to recap it quickly again, the big
problem with the LN channels is that whenever you update the channel, so for
example, when you fold an HTLC (Hash Time Locked Contract) back into the channel
or create an HTLC or splice, you predicted in the past the feerate at which the
transaction would confirm.  And that, of course, you have no information when
you'll actually want to do a unilateral close, you have no idea what the
feerates then might be.  So, these had to be fairly conservative and tended to
overshoot a lot.  And then, with anchor outputs, this got better because now the
fee only had to predict correctly the minimum of the mempool so that the
transaction could propagate.  So, it had to be high enough to be above the
dynamic minimum of mempools, so it would get into mempools, and then it would be
bumped by the anchor output.

But now, with TRUC transactions, we're getting to a point where the parent
transaction can have a fee of zero, have an ephemeral anchor, and then the fee
is determined by the child that you create at the moment where you want to do a
unilateral close.  This means that all of the balance in the channel, as defined
per the commitment transaction, is available for the channel.  There is no
channel reserve because you don't have to spend from the channel directly to pay
the fees, and you bring the fees at the moment that you make a unilateral close.

**Bastien Teinturier**: Since v3 restricts the packages that are used and has
less pinning issues than v2 transactions, we can also relax some outputs where
we previously had CSV-1 (CHECKSEQUENCEVERIFY), which means that we can actually
use some funds that are inside the channel, inside the commitment transaction to
pay the fees, which is really nice and is the endgame, to be able to actually
pay the onchain fees just based on money that is already inside the channel,
instead of having to use another external UTXO to bump the fees, especially for
mobile wallet users who usually don't have UTXOs available to do some fee
bumping.  So, once we use TRUC transactions, since mobile wallet users have a
smaller attack surface than routing nodes, because they don't route payments,
there are ways to make sure that they have a way to pay the onchain fees by
using the outputs of the actual LN channel.  And this is something I started
discussing on Delving Bitcoin a while ago, and we have a protocol that we think
is going to work well enough and we are going to actually implement it once we
move to TRUC transactions.

**Mark Erhardt**: Sorry, could you explain that a little more?  So, usually the
commitment transaction outputs are of course fixed.  How would the funds come
out of the commitment transaction and become available for fees?

**Bastien Teinturier**: It's just that when you spend the ephemeral anchor, you
would also spend, for example, your main output of a channel, so that you have
funds coming from the main output of a channel, and you can just decrease your
change output to consume those funds to pay the fees, basically.  And if you
also have HTLCs that are pending, you can do the same thing.  And also, all the
dust HTLCs that are currently pending on the channel are going to be
automatically added to the onchain fees.  So, there are multiple ways you can
actually pay some of the onchain fees using funds that are actually inside the
channel.

**Mark Erhardt**: Cool, thank you.

**Mike Schmidt**: T-bast, it sounds like you share some of BlueMatt's
enthusiasm.  I think I heard him on a podcast earlier this year saying
optimistic things about LN, which he doesn't always do.  It sounds like you're
optimistic as well.  I know you guys have had some ability, given the
architecture of Phoenix, to roll some of these things out sooner, but it sounds
like you're excited for it to be more broadly disseminated, some of this
technology.

**Bastien Teinturier**: Yeah, definitely, because I've had to write the annoying
code that is imperfect and has to walk around the fact that we are unable to
correctly predict the feerate, that there are cases where if we don't use TRUC
or we don't use package relay, there were cases where we knew that potentially
we were at risk of not being able to get a commitment transaction confirmed in
time.  So, I'm really happy to see that now, I'm able to remove that code.  It
removes a lot of code from the codebase, so a smaller attack surface as well on
the codebase, which is really nice.  And the protocol becomes simpler than what
we had before.  So, basically, what we see is that as we roll out those things,
the LN protocol actually becomes simpler, which is a very good thing as well.
So, the end goal is to be able to have channel transactions that are easier to
understand, that have less edge cases or less weirdness that is here just to fix
some nasty attack scenarios, and make it more accessible to everyone basically,
and more efficient onchain as well.

**Mike Schmidt**: Anything else that you'd like to say about v0.13?

**Bastien Teinturier**: No, just update your node if you have an Eclair node
that isn't updated yet, because it's just going to get better.

_Bitcoin Core 30.0rc1_

**Mike Schmidt**: All right.  T-bast, thanks for walking us through that
release.  There's a few Eclair PRs later that hopefully we can get to in short
order.  But we'll wrap up the Releases section first with Bitcoin Core 30.0rc1.
Release notes are currently under draft for this RC in this release.  Murch, how
deep do you want to get today on 30?

**Mark Erhardt**: I think that we might not want to get too deep yet.  The
release notes, it's just RC1, the testing is starting.  This is already pretty
long, but I'm sure there'll be a few amendments still and improvements.  I don't
know.  Did you want to jump into what's in there?  I think a lot of the policy
changes, for example, are already in the public eye.

**Mike Schmidt**: Maybe what we can do is we can just do a quick, as if this
were a movie, we can give sort of the trailer release.  And if folks are looking
for the details and the work in progress of the release notes draft, that's on
GitHub.  It's in the Bitcoin-Dev wiki right now.  So, you can look at sort of
what I have up on my screen that I'm looking at, along with a bunch of other
details.  Murch sort of gave away the punchline, which I think everybody knows
about these policy changes in terms of, well, one that we've talked about on the
show, and I'm simply going in order of the policy segment here, but limiting
legacy sigops in a single transaction to 2,500 from a standardness perspective.
Everyone's been talking about data carrier size default changing to 100,000 by
default, but there's also the multi-data carrier, multiple outputs in a
transaction as well, which is sort of part of that change, but conceptually
different.  There's also the minimum block feerate that we talked about a couple
weeks ago, that PR on the show, and then the minrelaytxfee and
-incrementalRelayFee default changes, based on a lot of the sub-satoshi summer
that we've seen and a lot of those transactions confirming, and we referenced
0xB10C's research on this showing compact block reconstruction, the cells in his
chart turning red, which is bad for compact block reconstruction.  Go ahead,
Murch.

**Mark Erhardt**: Yeah, I wanted to point out that the minimum relay feerate
change already shipped also in 29.1, as we mentioned last week.  So, what we saw
was that something like 80% of all blocks had a lot of transactions on the order
of 800 kB of data that we would download from our peers when a new block got
announced, and we just found that this delays the block propagation quite a bit.
So, the change is that the minimum relay fee is adjusted to what some miners
include, and since then some miners have adjusted their minimums a little bit,
but currently we see transactions quite often confirming at 0.26 sats/vB
(satoshis per vbyte), so I think this seems to be here to stay.

**Mike Schmidt**: There are some changes to the P2P network, improvements to
1p1c (one-parent-one-child) package relay, some changes in the orphanage.  We
can get into those maybe in a future show, once these release notes get a little
bit more solidified.  We talked about the new Bitcoin command at some point,
which is related to these separate binaries that will be available if you choose
to run them separately.  And thus, we also talked about the IPC, the
Inter-Process Communication, I believe, interface between those binaries,
including the mining interface, which is sort of the catalyst for pulling the
trigger on these multiple binaries actually being released.

One thing that I didn't see in here, which I think is pretty funny, and I
mentioned it to you, Murch, is there doesn't seem to be reference to the
speed-up in IBD (Initial Block Download).  Maybe that's in here.  I looked for
IBD.  I looked for the word 'download' and I didn't see it, which is kind of
funny that that's kind of a major benefit, but didn't make it in just yet.  So,
for listeners that are curious, I did see something from Lawrence, I think, on
Twitter that showed something like 17% to 20% or more improvement in IBD, based
on a slew of PRs that were made to Bitcoin Core, that made subtle and good
improvements that resulted in this aggregate speed-up in IBD, which is good to
see.  I think that should be in the release notes somewhere.

The other things, the RPCs, we can get into a little bit more and maybe, as in
the past, we've had folks who did a testing guide based on the release so that
folks can walk through a testing guide.  Maybe we'll have somebody from that
team who drafts that come on and we can get a little bit deeper into this.  But,
Murch, is there anything else that you want to highlight in our trailer edition?

**Mark Erhardt**: Maybe just there's a bunch of changes all over.  Also, for
example, TRUC support in the wallet and the removal of the legacy wallet.  The
release cycle for the prior release was a little short because we went on a
fixed schedule, and now this one is a little longer again.  And I think some of
the things that got bumped out of the last release are now additionally in this
release.  So, yeah, I think we'll have a pretty long conversation about this
next time.

_Bitcoin Core #30469_

**Mike Schmidt**: Moving to Notable code and documentation changes, Bitcoin Core
#30469 is a PR titled, "Fix coinstats overflow".  Murch, what's going on here?

**Mark Erhardt**: So, apparently someone discovered that the coinstats index on
signet had an overflow because, well, the values that got summed up could go out
of bound of the type of integer that was being used to represent them.  So, it
was fixed on signet and mainnet.  Of course, it's not broken on mainnet, only on
signet.  So, it's more like a no-op for you right now.  When you start up
Bitcoin Core the first time after this patch, it will rebuild the coinstats
index and keep a copy of the old one next to the new one.  Start using the new
one going forward, but the old one is there in case you decide to downgrade to
an older version.  Other than that, yeah, that's pretty much it.

**Mike Schmidt**: And so, how does this manifest itself if there was an overflow
on signet?  Is that just an error; is that a note in a log; is that a crash, do
we know?

**Mark Erhardt**: I don't, sorry.

_Eclair #3163_

**Mike Schmidt**: Okay, I don't either.  Okay, onto our Eclair PR parade.  We
have Eclair #3163 PR titled, "Add high-S signature BOLT11 test vector".  That
sounds not super interesting to have t-bast explain, but we have him here to
explain it anyways.  So, what's going on with that one?

**Bastien Teinturier**: It is actually interesting, because it is somewhat
related to the fact that we discussed cryptography earlier about the crypto
book.  There's something slightly weird that everyone usually gets surprised by.
There's this concept of high-S and low-S signatures for ECDSA, and there's one
thing that's interesting.  So, basically, Bitcoin Core uses low-s signatures
everywhere.  But there's something interesting in the secp256k1 API, is that
when there are two ways to basically consume an ECDSA signature, if you have the
public key and the signature, you can verify that this was a signature made with
that public key.  And in that case, the secp256k1 API will only accept it if the
signature is actually using low-s not high-s.  But if you don't have the public
key and you only have a signature, there's one thing you can do with ECDSA that
you cannot do with schnorr, but you can do with ECDSA, is that based on the
signature, you can recover the public key if the signature was valid for that
public key.  But this will work in both cases where the signature is low-s and
high-s.

So, you could start with a signature that you use the pubkey recovery API on it.
It's going to tell you, "Perfect, this is a valid signature for that public
key".  And then if you call the verify signature API with that public key and
the signature, it's going to say, "Oh, this is not a valid signature".  So, this
is a bit weird, but this is also because using pubkey recovery is a bit weird.
And the only reason we do that is because it saves space in the invoice.  You
basically just include the signature and not the node ID.  So, you save 33
bytes, which is interesting in the QR codes.  And we didn't think about it much
when we wrote BOLT11.  So, we didn't think about whether we should accept or not
accept high-S signatures for when doing pubkey recovery.  So, since it wasn't
specified, there's just a divergence here and some implementations accept it and
some don't.  And what we decided is to just do the same thing as what secp256k1
does.  And if you are also providing the node ID, then we only accept low-S
signatures.  And if you are using a public key recovery, we accept everything
because we want to make sure that we don't break backwards compatibility.  But
this is something that we should specify better.

Now, we won't have this issue because we are using schnorr sigs everywhere.  But
if we had to do it over, we should have specified it better.

**Mark Erhardt**: Wouldn't you be able to just convert the S-value and then use
the regular approach?  Maybe we can ask our present cryptographer if he knows.

**Jonas Nick**: Well, the problem with these signatures is that you don't have
the corresponding public key, right?  You get the signature, then you call the
recover function to recover the public key.  And then, you don't know if the
signature had low-S or high-S.  So, what you can do would be to what we call
normalize the signature.  There's a function for that in libsecp.  And then, you
can give it to ECDSA verify to verify it again and actually check if it had low-
or high-S.  But that seems to be overkill.

So, first of all, I want to say this wasn't properly documented in libsecp.  So,
there's a PR that I just reviewed today that improves the documentation on that.
But the guarantee that you have is that if this recovery succeeds, then the
signature is valid for this public key.  But that doesn't mean that ECDSA verify
passes in libsecp.  It only passes after you've normalized it.  But usually,
that shouldn't matter and you shouldn't need to additionally verify anything.
You can just call recover, signature is valid.  If you care about malleability,
well then it's an issue.  If there is a use case where you care about
malleability in recovery, then we should add it to libsecp to provide a recovery
function that actually checks whether the signature is low-s or high-s, and
rejects high-s signatures same way as ECDSA verify.

**Mark Erhardt**: Sorry to double-down, but ECDSA signatures are an R value and
an S value.  Both of them can be high and low, which just means whether they're
in the upper half or lower half of the available values.  So, wouldn't you be
able to just look at the signature and immediately see whether it's high-S?

**Jonas Nick**: Yeah, I guess that should work.

**Mark Erhardt**: Okay, all right.

**Jonas Nick**: But we don't have a function right now in the libsecp to do
that.

**Mark Erhardt**: All right.

**Jonas Nick**: I think it's perhaps easier just to encapsulate all the
functionality in one function, recover low-S, or something.

**Mark Erhardt**: Right, but so you say you could normalize it and then the
verification would pass.  So, you will apparently get the same public key
whether you do it from the high-S or the low-S to recover, right?

**Jonas Nick**: Yeah.

**Mark Erhardt**: So, if you first normalize, you could just... right.  Okay.
No, I think I get it.  Cool.  So, basically, just check whether it's high-S and
then use the low-S function and it should all work?

**Jonas Nick**: I think the fix that Bastien was talking about just accepts
high-S and low-S, because that's backwards compatible.

**Bastien Teinturier**: Yeah, because if there's an implementation out there
that produces high-S signatures for BOLT11 invoices in a wallet that people
actually use, we don't want to start rejecting them, because there's just no
reason to reject them.  We don't care about malleability issues here.  And the
only thing is that you cannot just change them automatically because there's a
checksum in the BOLT11 invoices, so you would break that checksum, but it just
doesn't matter.  There's no reason to reject the high-S one.

**Mark Erhardt**: Right.  Of course, you wouldn't want to break the checksum,
but for the check for the public key, you can totally just use the low-S.
Anyway, I think we've dived in quite enough here.

**Mike Schmidt**: Well, it's kind of funny.  I thought this was going to be the
boring one, but I guess when you have a bunch of smart guests and a smart
co-host, that even the test vector for BOLT11 high-S signatures can be
interesting.  All right.

_Eclair #2308_

Eclair #2308, "Use balance estimates from past payments in path-finding".

**Bastien Teinturier**: Oh, yeah, so this is something that has been discussed
for basically years among LN implementations, is that you could, whenever you
are choosing a path in the network to send your payment, basically you know the
balances of the channels that you have, but you don't know the balances of the
channels that other people have.  So, maybe you are trying to send a payment,
but there's not going to be enough balance in the direction you want in one of
the remote channels that you're using.  So, basically, every LN implementation
uses a lot of heuristics to score each channel, each pair of nodes, to try to
evaluate whether they are likely to be able to relay that payment or not.  And
it's been years that we realized and we knew that we just had to write the code
to record data from past payments, because based on past payments, you can see
that if a payment was rejected somewhere along a path with an error that tells
you that this was rejected because there's not enough balance, you know that at
some point there was not enough balance in that channel.  And you also know that
there was enough balance on the channels before that one, because it got to that
node.  So, all the channels before that had enough balance for that payment.

So, based on that, you can start to record data about some places where you know
that at some point in time, there was enough balance or not enough balance for
that size of payments.  And you could use that to score the channels that you
use in your pathfinding algorithm.  And I think that all implementations right
now have some implementation for that with divergences, basically, on how they
make the data they collected expire.  Because at some point, if you knew that
two days ago a payment was able to go through that channel, the balance could
have changed entirely since then, so maybe that data is stale.  But in Eclair,
we had, I think, yeah, we shipped the first version of that two years ago, but
we just didn't activate it by default, because we wanted to just use it in
shadow mode on our node to verify that it seemed to work well or not.  And so,
now, we are introducing that flag because it seems to be working well.  So, we
don't turn it on by default, but probably we're going to turn it on by default
in the next release, but people can start experimenting with that and see if it
affects their pathfinding and if they get better success rates than before.

**Mark Erhardt**: Right.  I just wanted to highlight again, when you make a
payment attempt, you basically learn how many of the hops succeeded at that
attempt.  Most of the LN payments are multi-attempt, or maybe more of them are a
single attempt now, but they used to be quite a few tries.  So, basically, on
every hop that forwarded the multi-hop contract, you learn a lower bound on what
it has at least, and then the one that rejects it due to insufficient balance,
you learn an upper bound of how much it has at most.  So, if you remember that,
you can use that information for future pathfinding, especially future attempts
in the same payment.  You wouldn't want to try the same channel over and over
again when you already know it doesn't have enough money.

**Bastien Teinturier**: Yeah, exactly.  So, this saves on latency because you
can avoid paths that you know most likely don't have enough balance throughout
the payments.  And this becomes especially useful when you are running an LSP or
wallet providers, because you will, in most cases, use something like Trampoline
to compute paths for all of your users.  So, you are actually converting way
more paths than just for a single user.  So, you are constantly trying to send
out payments, so you are constantly learning data about channels.  And this is
something that all of your mobile wallet users benefit from, because the
payments from other people improve the reliability of your payments.

**Mike Schmidt**: T-bast, do you have metrics on this, on improved latency or
improved success rates using or not using this?

**Bastien Teinturier**: Not yet, because to get those, we needed to actually
turn it on by default, because before that we were only shadowing it and
comparing the results, but not actually using it to select the paths.  But now,
we have deployed on our node, using it for I think 20% of payments are going to
use this, so we'll be able to collect data on actually really using that saves
that much compared to payments that don't use it and use the other heuristics
instead.

_Eclair #3021_

**Mike Schmidt**: Cool.  Thanks, t-bast.  Eclair #3021, "Allow non-initiator RBF
for dual-funding".

**Bastien Teinturier**: Okay, so this one is actually quite trivial.  It really
just looks like this is something we had kind of missed in the initial
dual-funding specification.  So, when we introduced dual-funding, basically the
two nodes in the channel are able to contribute to the funding transaction by
adding inputs and outputs.  And another benefit of dual-funding is that if the
transaction doesn't confirm, you are able to RBF it.  You just restart creating
that transaction and you change some of the inputs and outputs.  But before
that, I think that the specification explicitly said that only the initial
opener was allowed to initiate RBF, but it actually doesn't make sense, because
if the other guy also decides to contribute to the transaction and it doesn't
confirm, maybe they're fine with doing RBF on their side and putting more fees
in that channel because it matters to them.  So, we just allow them to also
initiate RBF.  Basically, both sides are able to initiate RBF whenever they want
to.

The only small details in that case is that since we have also implemented
liquidity purchases, liquidity advertisement, when one side can open a channel
to another side and say, "Please, I want you to put that amount on your side so
that I can receive payments, and I'm willing to pay you for this liquidity that
you are going to allocate to me", in that case, it can only be the node that
starts the protocol that purchases this liquidity, because I am initiating a
liquidity purchase.  So, if I RBF, then there's no issue.  I can RBF and
renegotiate that liquidity purchase or potentially even remove it.  But if you
initiate RBF, then you won't know.  Basically, we change who initiates the
protocol, so there's no way to handle that liquidity purchase.  So, this is just
one small edge case where in that case, if someone is opening a channel to you
and they are willing to pay you to allocate funds, then you're going to let them
RBF because they have more at stake basically in that channel than you do.

So, yeah, it's basically just an edge case that you have to handle.  But apart
from that, everything just made sense.  You just need to make sure that people
don't try to cheat you by saying, "Okay, I want to open a channel to you and I'm
gonna pay you for the liquidity", and then if you don't pay attention and you
RBF, you're going to offer that liquidity without getting paid for it.  So,
basically you would be screwed.  So, it's just an implementation culture.

_Eclair #3142_

**Mike Schmidt**: And Eclair #3142, PR titled, "Allow overriding
max-closing-feerate with forceclose API".

**Bastien Teinturier**: Okay, so this one is also linked to RBF, because
whenever a channel gets forced closed, there are some transactions that you
really have to get confirmed quickly, because HTLCs, for example, or if this is
a revoke commit, there's a race between both channel participants to get the
funds back.  So, for those, Eclair will automatically use a feerate that ensures
that these get confirmed before the other side can steal money from you.  But
there are also transactions where the other side cannot steal anything from you,
and you are not potentially in a rush to get those funds back.  And so, what
we've done is that we've given more knobs here so that people can say, "I'm not
in a rush to get those non-urgent transactions back to me.  I'd rather wait more
and save on fees".  And so, this is basically what this allows you to do, to
decide on a per-channel basis, especially for example in that case, when we
decide to close a lot of channels that we have with people who have just
disappeared and stayed offline for one year, and we know we will never see them
again, then we save a lot on fees by deciding to just be patient and make sure
that we cap the feerate and disable automatic RBF.  And we're basically just
able to wait to get our funds back, instead of paying more fees.

Otherwise, without this parameter, Eclair would automatically try to RBF
regularly to get your funds back, which can potentially become expensive.  So,
here you just configure your max-closing-feerate according to what you want to
pay at most, and Eclair will RBF up to that feerate and then otherwise it's just
going to stop.  And if you want to get those funds back because this is not
confirming and now you actually need the funds, then you can just call the API
again to change the value for the max feerate.

**Mike Schmidt**: That wraps up the Eclair PRs.  We have two other LN PRs, both
to LDK, one of which, well, probably both of which, t-bast, maybe you can help
narrate as well, even though that's not the implementation you work on.

_LDK #4053_

LDK 4053 is a PR titled, "Create a single P2A on commitment transactions and 0FC
Channels".  We at Optech also sometimes refer to these as v3 Commitments.  This
is part of LDK's zero-fee commitments project with the tracking issue #3789, if
you're curious about the broader effort in LDK, that allows LN commitment
transactions to use TRUC, P2A outputs, ephemeral dust, sibling replacement
techniques together to allow for zero fees in the commitment transaction.  I
think we kind of touched on this earlier, t-bast, but obviously you don't know
the implementation details.

**Bastien Teinturier**: I do, don't worry.  This is based on the spec PR I wrote
for that commitment format.  And I'm working closely with the LDK team on that
one and also on the next one.  So, basically, it is the v3 commitment format,
the one that doesn't use taproot.  So, yeah, we had, I think six months ago, LDK
and Eclair prototyped an implementation of that.  But we put it on hold because
we needed bitcoind 29 to be out to support relaying those ephemeral anchors.
And now that bitcoind 29 has enough nodes on the network, it's a good time to
resume that effort.  Because we cannot ship that thing if those commitments
don't relay to the miners.  So, we had to wait for enough of a network to
upgrade the Bitcoin node.  And now, we are at the point where I know that the
LDK team wants to move fast on this commitment format, which I love, because
this means that we'll be able to get cross compatibility quickly and we'll be
able to get the specification PR merged as well.

So, on Eclair, I basically need to rebase my implementation and we'll be able to
test those things.  So, it's what we discussed earlier, as you said, where a
commitment transaction uses zero fees, we use a single anchor, it removes some
burdens on the other outputs that don't need a CSV-1 anymore.  And HTLC
transactions are also going to use v3, and this protects against pinning and
makes it easier to set the right feerate for your package, basically.  So, this
is really important.  Whenever this is available, people should upgrade and
should start using that type of channel on their nodes.

**Mike Schmidt**: You mentioned the importance of waiting for adoption and then
the relay of these transactions.  I saw something online that someone was
pointing out, that potentially the default settings in Knots and potentially the
latest Bitcoin Knots version will filter transactions that maybe don't have zero
fee, but have something above zero fee.  Obviously, if that is the case, that
would hurt propagation of those transactions.  But also, if someone is an LN
user and using their Knots node, there's concerns there as well.  Murch, did you
have a comment?

**Mark Erhardt**: Yeah, I wanted to point out not just propagation, but if you
run an LN node yourself and your own mempool doesn't accept it, it will not go
out to the network.  So, my understanding is that by default, Knots 29.1 will
only relay ephemeral dust with zero amounts, not non-zero amounts, and it will
also not enforce TRUC rules.  So, this is going to be an issue for LN.  So, if
you do that, this is going to be an issue for the next type of LN channels we're
going to use.  So, I hope this gets changed in the future, because this is
payment, so this is what we want.  We want to make sure that Bitcoin is used for
payments, so we should definitely relay those transactions.  Otherwise, we're
going to prevent people from making LN payments.

**Mark Erhardt**: Just to be clear, I've been looking at the code a little bit,
I believe the defaults are that it does accept v3 transactions and will relay
them, it just doesn't enforce the restrictions on topology that v3 introduces or
the TRUC rules; it treats them like any other transaction.  And for the
ephemeral dust or the anchors, it only accepts zero amounts, if I understand it
correctly.  So, specifically, if you have a non-zero amount, which I'm not sure,
why do you need non-zero amounts in this potentially?

**Bastien Teinturier**: We do need non-zero amounts, because when there are
pending HTLCs in the channel that are below dust, we need to put their amount
somewhere.  So, what we do, if I remember correctly -- I need to check.  If I
remember correctly, what we do is that we put them inside the ephemeral anchor
until it reaches 240 sats, and once it reaches 240 sats we instead let them go
to minor fees and we fix the ephemeral anchor at 240 sats.  And I remember it
was instagibbs who proposed this capping mechanism and there was a good reason
for it.  I don't remember it, but it is written down in my spec PR somewhere.

**Mark Erhardt**: I'd be curious, because just dropping it to minor fees would
make more sense for the smaller amount rather than the bigger amount.  So, it
kind of feels surprising to me that the smaller amount gets put into the
ephemeral anchor and the bigger amount gets dropped to the fees.  So, anyway.

**Bastien Teinturier**: I think it was related to standardless rules somehow.

**Mark Erhardt**: I mean, I think you wouldn't want the ephemeral anchor to be
too big, because then it would encourage the transaction to ...

**Bastien Teinturier**: Yeah, even if it is too big, everything will be consumed
by miners, basically.  So, if you end up with an ephemeral anchor output that is
like 50,000 sats and you try to only consume part of that with your TRUC
transaction, rational miners will just replace your TRUC transaction by one that
consumes everything, because …

**Mark Erhardt**: Oh, right, yes.

**Bastien Teinturier**: … it doesn't need a signature, so it will be replaced.
So, it doesn't make sense to let the amount of the ephemeral anchor become large
because anyone can steal it.  So, that's why we cap it.  But I don't remember
why we have to gradually go from 0 to 240 sats.

**Mark Erhardt**: Yeah.  Also, we don't want a fee on the parent transaction
because we don't want the parent transaction to be mined without the child that
spends the dust output, right?  Anyway, maybe we'll have to have you back or
someone else that can explain that to us.  We'll figure it out until next time
and double-click on that.

**Bastien Teinturier**: This was detailed, discussed in a Delving post, so I can
find it and I can tweet it in response for people who are interested.

**Mark Erhardt**: Thank you, that would be lovely.

_LDK #3886_

**Mike Schmidt**: Thank you.  Last PR this week, LDK #3886 titled, "Update
channel_reestablish for splicing".  "The splicing spec extends the
channel_reestablish meshes with two more TLVs, indicating which funding txid the
sender has sent/received.  This also allows peers to detect if a splice_locked
was lost during disconnection and must be retransmitted".  T-bast, you probably
have some familiarity with this.  What is LDK changing here?

**Bastien Teinturier**: Yeah, so basically, we've been working a lot on the
channel_reestablish requirements for splicing, because basically some of the
things we've done in violating protocol, regarding what we retransmit when we
reconnect, were somewhat hacky.  And we realized that for splicing, we had to
have more cases where we retransmit some stuff on reconnection.  And it was a
good opportunity to do it in a less hacky way.  And we had a first version that
I had written down, and then Jeff pointed out that it was a bit misleading in
many ways and could be improved.  So, thanks to Jeff's suggestion, we've been
able to basically simplify the spec and simplify the protocol, by just changing
what we put in when we reconnect which data we need from the other side.  So,
this PR is just basically implementing the latest changes we made to the
specification.  And I think that with this PR, LDK and Eclair should have the
same implementation of splicing.  And I think, once this is merged, we're going
to be able to start cross-compat tests for splicing between Eclair and LDK,
which is really, really nice.

**Mike Schmidt**: That's awesome.  Great to hear.  And folks who are curious
about the link that t-bast mentioned, look for some response in some of the
Optech Twitter handle, and you can find it there.  That wraps up the newsletter
this week.  T-bast, thanks for hanging on for the whole thing and walking us
through a bunch of segments.  It was mostly the t-bast show, which is kind of
fun.  It's been a while.  We had Jonas on earlier talking about cryptography, we
thank him for his time.  And, Murch, thank you for co-hosting and for everybody
for listening.  Cheers.

**Bastien Teinturier**: Thanks for having me.  Bye.

**Mark Erhardt**: Thanks.  Good to have you.  It's nice to get so many details
on LN.  We were definitely missing that.

**Bastien Teinturier**: I'm happy to join anytime.  Thanks.

{% include references.md %}
