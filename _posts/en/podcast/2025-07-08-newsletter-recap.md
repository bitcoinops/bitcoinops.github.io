---
title: 'Bitcoin Optech Newsletter #361 Recap Podcast'
permalink: /en/podcast/2025/07/08/
reference: /en/newsletters/2025/07/04/
name: 2025-07-08-recap
slug: 2025-07-08-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Sanket Kanjalkar, Jonas
Nick, Tadge Dryja, Steven Roose, and Brandon Black to discuss [Newsletter #361]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-6-10/403676003-44100-2-064497dec3d96.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Quick disclaimer this week, we recorded the podcast in two
different recording sessions.  And so, in one session, we had Sanket, Jonas
Nick, and Tadge; and in a separate recording, we had Rearden and Steven Roose.
And so, if you're wondering why certain guests aren't opining on certain items,
it's because we had two different sessions and we edited all together in a
little bit out-of-order way in order to accommodate the order of the newsletter.

Welcome everyone to Bitcoin Optech Newsletter #361 Recap.  Today, we're going to
talk about decoupling onion messages from the LN channel topology, and we have
our monthly segment on Changing consensus, where we have discussions about CTV
(CHECKTEMPLATEVERIFY) and CSFS (CHECKSIGFROMSTACK) with regards to PTLCs (Point
Time Locked Contracts); CTV+CSFS and BitVM; the CTV+CSFS open letter; the
TXSIGHASH proposal.  And we have two items on quantum resistance and also a
discussion on vault descriptors.  Murch and I are joined this week by a handful
of guests.  Sanket?

**Sanket Kanjalkar**: Hey, hello.

**Mike Schmidt**: You want to say a few words about yourself?

**Sanket Kanjalkar**: Yeah, sure.  Hi, my name is Sanket, avid bitcoiner.  I
used to work with Jonas at Blockstream Research for about three-and-a-half
years, working on mostly scripting side of things along with cryptography.  Now
I work at Block.

**Mike Schmidt**: Jonas?

**Jonas Nick**: Hey, I work in the Blockstream Research group and I'm mainly
focused on cryptographic problems.

**Mike Schmidt**: Rearden?

**Brandon Black**: Hi there.  Yeah, I'm Rearden and I try to do Bitcoin
education and self-custody research.  It's kind of my thing these days.

**Mike Schmidt**: Steven?

**Steven Roose**: Hi, Steven Roose, currently building Ark at Second.

**Mike Schmidt**: Tadge will be joining us shortly as well.  We'll have him
introduce himself when he gets here.

_Separating onion message relay from HTLC relay_

"Separating onion message relay from HTLC relay".  Roasbeef posted to Delving
Bitcoin a post titled, "Reimagining Onion Messages as an Overlay Layer".  In his
post, he proposes separating the connections and paths that onion messages can
take from the topology of Lightning channels in the LN.  So, right now when you
send an onion message, the message is being routed along channels just like a
payment would be routed.  And roasbeef sort of outlined some motivation for
wanting to separate those or some downsides for them being bolted together as
they are.  He noted some of those downsides include the coupling.  He noted,
"Bolting the onion message graph onto the channel graph, we force the onion
message graph to operate a graph of larger diameter than the solution
necessitates.  If onion messaging were instead on an overlay layer, a more
compact messaging graph would emerge".  So, what he's saying is, maybe you're
routing through five different paths along the way for a payment, but does an
onion message really require five hops?  And I think his conclusion is no, but
we'll get into that in a minute.

He uses the example of BOLT12 offers, where if a single node along the path
doesn't support the protocol, then the onion message can't be transmitted.  And
that means that the client needs to fall back to directly connecting to the
recipient to send their request messages, which he notes is bad for privacy as
well as bad for UX in the form of delays.  He also points out that currently,
onion messages can reuse identification keys of a channel peer indefinitely,
which doesn't allow for changing those keys, which degrades the privacy of onion
messages over time.  And he also points out that channel-related activity can
currently block the processing of onion messages, although in the Delving
thread, I believe that there was some pushback on that point in particular.  So,
to solve these issues, roasbeef's plan is to start a new onion message network
separate from any channels, that is built up from the existing gossip network.
And that alternate onion message network can actually run in parallel with the
existing onion message network and could allow for quicker experimentation and
innovation of some of these newer proposed LN features, because you'd
potentially have a tighter group of people who are more interested in keeping
that up to date.  And so, they would maybe be 1% the size of the existing LN,
was one of the numbers I saw thrown out.  And so, that maybe you can iterate
faster on some of this new tech.

So, that was the problem as he saw it and the solution as he saw it.  And I
think that the main objection, and we outlined this in the newsletter as well,
is that currently, coupling the channel and onion message together means that
onion messages benefit from the DoS resistance that's built into having a
channel and putting your funds at stake, opening the channel, all of that.
Whereas if you just allow any LN node to be messaging any other LN node, you
lose that DoS protection.  So, I think that was the main objection that we
noted, and that I also saw on the thread, and discussion seems to be ongoing.

_CTV+CSFS advantages for PTLCs_

"CTV+CSFS advantages for PTLCs".  This is actually an item that's a continuation
of a discussion that, Steven, you've started.  This was a few weeks ago.  It was
a Delving post titled, "CTV+CSFS: Can we reach consensus on a first step towards
covenants?"  You posted that to Delving, and we covered that in Newsletter #348
in its initial carnation.  I saw there's a ton of new responses there since.
But in your original post, you outlined benefits to DLCs, Vaults, BitVM, and
somewhat related to this week's item, LN-Symmetry.  In the recent discussion on
the thread, Greg Sanders actually pointed out that even if LN-Symmetry isn't
adopted, that having CTV+CSFS available could still accelerate a move towards
PTLCs.  He noted that PTLCs are possible today, but with re-bindable signatures,
it actually gets significantly simpler.  We could probably recap what PTLCs are,
but also, does anybody want to explain what re-bindable signatures are and how
that's related to PTLCs?

**Brandon Black**: I'll take the rebindable signatures part there.

**Mike Schmidt**: Thank goodness!

**Brandon Black**: So, in Bitcoin right now, all of the ways that we can sign a
transaction using OP_CHECKSIG, OP_CHECKMULTISIG, OP_CHECKSIGADD, all of those
and their variants require that some at least one previous output's txid and
outpoint, or and vout, are signed.  And so, that means that that signature is
bound to a specific output from the UTXO set.  Now with either APO
(SIGHASH_ANYPREVOUT) sighash mode, or with CSFS and CTV, we can then sign a
transaction in a way where none of the previous outpoints are signed.  Now, that
signature can be used with any output that has the matching script, essentially,
the matching required signature.  It doesn't have to have a specific output from
the UTXO set.  So, now it's re-bindable.  You could have two outputs in the UTXO
set, and either one could be spent with that signature.  That would be dangerous
in certain cases, but it's also super-advantageous in certain protocols,
especially LN and DLCs, and things like that, where you might need to have a
signature that can be used in different scenarios along the protocol with a
different output as the input to that transaction.

**Mark Erhardt**: Yeah, so I picked the quoted person's brain this morning to
try and figure out what they meant, and my understanding now is that the problem
with PTLCs would be that now, instead of just one party signing the commitment
transaction of the other party, each time an HTLC (Hash Time Locked Contract) is
added to the commitment transaction, it would have to of course be both sides,
because PTLCs are MuSig signatures and MuSig requires signatures from both
parties.  And it would require that these signatures are updated each time, I
think, when the transaction is updated.  So, instead of signing each new
commitment transaction once by the party, that Alice signs Bob's and Bob signs
Alice's, so the other parties commitment transaction is presigned, now both
parties would have to sign both commitment transactions on every update per
PTLC.

With the re-bindable signature, it would become a single re-bindable signature
for both sides for the lifetime of the PTLC.  So, you'd sign off on a PTLC once
when it's added and as long as that PTLC is on the transaction, that signature
would be fine, and that would make it a lot simpler to adopt PTLCs.  Please
correct me.  That's my very uneducated understanding.

**Brandon Black**: One nuance in there is that it's not just because it's
MuSig2.  Even if it's two single-signatures, the same property exists.  Because
it doesn't matter that it's a MuSig2 signature or it's a 2 single-signatures,
either way with PTLCs, you need to update the signatures if the underlying
commitment transaction changes, unless you have re-bindable signatures, and then
you don't have to update them.  So, it's not specific to MuSig2, it's because
it's a two-party thing with a specific point, or in the case of single-sig, two
separate specific points for the PTLC, because the PTLCs are bound to a point,
not a hash.

**Mark Erhardt**: Right, but I mean PTLCs only work because it is a point and
therefore a single-sig signature, right, or am I misunderstanding something?
Otherwise, you'd need a taproot branch, like a script tree leaf script, right?

**Brandon Black**: Yeah, correct.  You can do PTLCs with single-sig in a tapleaf
branch.  And basically, one signer is a plain signature, one signer is an
adaptor sig, on each side of the commitment tree.  So, you still use an adaptor
sig like you would in the MuSig variant, except instead of a two-party adaptor
sig that does the whole thing, it's a regular signature for one party and an
adaptor sig for the other party inside of a scriptpath.  So, it can work with or
without MuSig2 and with or without re-bindable signatures.  If you have MuSig2
and re-bindable signatures, it is definitely simpler in two dimensions.

**Mark Erhardt**: I see.  Thank you.

**Mike Schmidt**: Okay.  So, it is possible today, as Greg points out, but as
both of you have illustrated, I think that that would be even higher
interactivity and number of things that we're storing and going back and forth
with.  So, these improvements would cut down on that and keep it a simple
protocol.

**Brandon Black**: The one thing that I found really interesting in reviewing
this this morning is that there's this weird trade-off space in here of
simplicity of the transactions and scripts versus interactivity.  So, if you add
MuSig2, that adds a round trip.  In most cases, there are ways to mitigate that,
but in general, MuSig2 adds a round trip versus the two single-signatures.  But
of course, the two single-signatures have this weird thing with one party
signing a full sig, the other party doing adaptor sig and kind of swapping
those, but it's less interactive.  And then, adding re-bindable signatures just
reduces the interactivity.  So, we could say that re-bindable signatures are an
unmitigated benefit to PTLCs.  MuSig2 is a nuanced trade-off to it.

**Mark Erhardt**: So, the news item was largely about how tooling was missing
for that sort of PTLC work.  My understanding is that building such tooling
would be significantly easier also with the re-bindable signatures, because
you'd have less overhead, or is that wrong?  I see some skeptical looks.

**Brandon Black**: I think the main tooling that is missing is around the
adaptor sigs themselves.  And unfortunately, that's needed in either case.  I
think it is a little bit simpler because you don't have to have these two
different sets of adaptor signatures.  One set of adaptor signatures that are
re-bindable applies to both sides of the commitment transaction.  The thing
that's missing is there's not great tooling in, like, libsecp for adaptor
signatures.  That would be the big kind of tooling lift.

**Steven Roose**: Yeah, I wanted to say the same thing.

**Mike Schmidt**: And, Murch, I think we covered the MuSig module that went into
secp256k1, I think, in the last few weeks, and explicitly noted that that
adaptor signature support was dropped as part of that as well.  So, unfortunate
there, and I think AJ pointed out that even the more experimental secp ZKP
project, which has some other goodies in it, doesn't have adaptor signature
support either.  So, sad face there.  The only other thing that I pulled out
from the discussion was just Greg pointing to an artifact that he had created a
while ago, which was this idea of what LN message changes would be needed to
support PTLCs.  And so, he pointed to it just there.  I know he did a lot of
work on LN-Symmetry and he's sort of pointing to these artifacts that he's left
along the way, if people are revisiting them in the case you have with PTLCs.

**Brandon Black**: One thing worth noting in that, just fun, I know we've talked
before on this podcast about LN-Symmetry.  So, yeah, we can do PTLCs without
LN-Symmetry, or we can do them with.  Because LN-Symmetry doesn't have the two
sides of the commitment transaction chain that we have to sign for, you get
another layer of simplicity in your PTLCs if you have LN-Symmetry, because
you're only signing for the one update transaction, and both parties just have
to sign that one transaction, and you're done with your PTLC versus with the
current LN-Penalty, there's two sides of the channel that both have to get
signed with the PTLC.  So, it's kind of neat to see going through Greg's gist
here that he linked, "Oh, if you get re-bindable signatures, it gets this much
simpler.  And then if you get re-bindable signatures and LN-Symmetry, it's down
to basically just send the PTLC and we're done".

_Vault output script descriptor_

**Mike Schmidt**: Moving to, "Vault output script descriptor".  Sjors posted to
the Delving Bitcoin forum to discuss the idea of a CTV vault output descriptor.
He referenced James O'Beirne's simple-ctv-vault design that uses the CTV opcode
to create a vault implementation to store bitcoins that require multiple
transactions in order to be spent.  He noted, "For any vault construction to be
useful in wallets, it needs to either fit in the existing BIP380 output
descriptor paradigm or develop an alternative."  Sanket, you replied in the
thread and you also noted you were working on an alternate CTV vault
construction.  Maybe, can you help us understand why a vault descriptor would be
a hard thing?

**Sanket Kanjalkar**: Yeah, for listeners, I guess everyone is primarily aware,
but to recap, of Sjors' first statement, which was, "Why do we even need
descriptors?"  We have been having discussions about, "We need CAT, we need
VAULT", but when you actually try and implement one of these things, you slowly
come to realize that, we need standard tooling on top of this to make it work.
And as Sjors also commented in the same thread, it's been six years since
descriptors were started, like we started talking about them, but now they are
sort of in a good place in Bitcoin world.  So, if we want to use the newer
primitives, we want wallets to index the points, we want backups for those
things.  And descriptors just solve these problems and are nicely integrated in
all of the tooling that we have.  So, it's good to have them incorporated in
this language.

So far, how most descriptors work is you have a logical spending condition,
which is like, "Give me a multisig.  I need, if I have three of these keys, I
can spend from them".  Or importantly, the most important property that we have
is we can create the output address or output script from a descriptor, and that
allows us to make the same property which either apply for the newer
instructions, like CTV for example, because they rely on transaction structures
like previous output or sequence locktime, they don't necessarily fit in the
same language that we have currently.  We have to have some sort of additional
information we supply as a part of when we describe how to look for the outputs.
So, that's I guess the first part.  And to that end, Sjors initially commented
on the approach in which we can look up for funds in a descriptor, with
parameters for how we get the CTV transaction exactly.  It's stated assumptions
on how we want to look out for sequence locktimes, and how the nesting should
work in one particular construction.

That, and I think one alternate implementation, which is easier to implement,
can be instead of indexing the CTV funds itself, if we index the incoming
deposit, if we have like a mini-standard withdraw from vaults, you have a
staging area that you withdraw funds from.  Cold area goes to staging area, you
can cancel funds from there, and those funds go back up into hot area.  But to
simplify construction and implementation, if we add an additional constraint,
which is that funds don't directly go into the cold wallet, but instead go into
this staging area, and the wallet implementation themselves can manage how to do
the CTV, how to put in the exact amounts of CTV outputs, because if you put in
the incorrect amounts, funds may be at risk of theft.  So, the alternate design
would be for depositing funds, you also deposit them in the staging area and
have the special wallet instruction having them indexed by looking at previous
outpoint, which is like a standard descriptor, which can be any one of the
descriptors, and that always sends funds to CTV output.  So, yeah, any
questions?

**Mike Schmidt**: Yeah, so it sounds like based on the original James O'Beirne
simple CTV vault design, there was going to be cumbersome tooling around that
sort of a vault implementation.  And so, you've come up with an alternate vault
implementation that I don't fully understand the trade-offs, but it sounds like
the tooling around that sort of a vault would be a little bit better, and that
would include something like descriptor capabilities.  Do I have that right?

**Sanket Kanjalkar**: Yeah, the exact trade-off would be easy tooling, but you
cannot deposit directly into the vault.  You have to deposit into a vault
wallet, and then that switch additionally comes into the cold area.  It's not
the best of designs, but if you want something that works today, then you can
work with it.  It's really useful if you are slowly stacking funds, instead of
depositing a large chunk all at once.  So, if you want a working thing today
without dealing with all of the mess that integrating CTV, or like CTV inside
the descriptor language concept, you can work with it.

**Mike Schmidt**: Murch, do you have any questions for Sanket or comments?  No,
Jonas or Tadge?  So, Sanket, it sounds like there's a couple things here.  One
is, you have this additional prototype of vaulting that you've put out.  I don't
know if you're looking for feedback on that or just other ideas around tooling
or descriptors for some of these potential coming vaults, if CTV is something
that the community activates.  I guess I'm just looking for any sort of calls to
action you might have for listeners.

**Sanket Kanjalkar**: Yeah, it's a call to action for listeners.  And to me, I
think AJ has been quite an advocate at this point, as we have been discussing a
lot about future opcodes.  And assuming we have opcodes, then the next step that
comes up is like, how do you build wallets from those?  And how do you build
wallets that go beyond a simple prototype, which is like, how do you integrate
those into descriptor language?  How do backups work?  And you also need to
answer these types of questions if you have, yeah.  And the discussion's
implementation details quickly get hairy, so should also figure that out before
you make one strong decision.

_Continued discussion about CTV+CSFS advantages for BitVM_

**Mike Schmidt**: "Continued discussion about CTV+CSFS advantages for BitVM".
So, this item follows up on a different Delving thread that we covered
previously, "How CTV+CSFS improves BitVM bridges", and that was posted by Robin
Linus, and we covered that in Newsletter #354.  And actually, in Podcast #354,
we had on Robin, and he covered that original post and the ideas which involved
how CTV could help BitVM by increasing the number of operators without
downsides, I think he said reducing transaction sizes by something like 10x and
also allowing non-interactive pay gains to these bridges.  And it so happened
that in that podcast, we actually ended up covering much of this updated
discussion that we're covering this week in the newsletter.  Just due to timing,
a bunch of the discussion happened after the newsletter was published and before
we had the podcast.  So, Robin actually got us up to date on a lot of this
already, including AJ Towns finding a bug in the original proposed contract;
Jeremy Rubin coming up with a revised construction to work around that; Robin
pointing out another issue with the construction in that you need inputs from
two different transactions.

But something since that podcast was that Chris Stewart came up with a Python
prototype implementation of the original construction, and also some attempts at
also implementing some of the workaround suggestions that we just discussed.
For all of that, except for the Chris Stewart part, I would refer listeners back
to that Podcast #354, where we had Robin, sort of top of mind, fresh discussion
talking about these things.  I'll pause there if anybody has anything to add,
but then I want to loop in Steven real quick.  Okay, Steven, your OP_TXHASH
proposal was actually mentioned as a potential alternative to CTV here.  I
didn't see you comment in this specific Delving thread, but did you get a chance
to think about that?

**Steven Roose**: Yeah, I replied to the email that was sent out following the
CTV+CSFS openly-signed letter on the Bitcoin mailing list.  There was also some
discussion there on TXHASH and why not going all the way towards TXHASH.  I
think it's a question of stopping point, right, like where do we stop?  Like, if
we have TXHASH, we can also talk about CAT, we can also talk about a lot of
other things.  And I think just many of the things that go beyond CTV+CSFS just
haven't had the review, haven't had the actual compelling use cases worked out
on what this additional functionality actually gives in terms of additional
functionality, and also what are the risks, what are unfavorable results of
enabling this more logic?  So, I mean even though I'm obviously the author of
TXHASH and I obviously think it's a very useful and very powerful primitive, I
wouldn't want to make the statement that I think it's anywhere ready to be
included or to be put on the roadmap.  It definitely needs a lot of protocol
review, it needs a lot of people thinking about how it would be used and if it's
actually suitable for those use cases.  Because in general terms, you can think
about, "Oh, we can do this, we can do that".  But is it actually an ergonomic
opcode?  Is it actually doing the exact things that we need?

It's by nature a very opinionated opcode, so it definitely needs many people to
look at, because there's many different ways to implement the specifics.  And I
just think that we have very compelling reasons to have something like CTV+CSFS,
while the additional benefits of adding the additional complexity of TXHASH are
not that obvious.  So, I think we need to put a stopping point somewhere, and I
think it's just like TXHASH just doesn't make it in there.  That's what I also
argued on the mailing list.

**Brandon Black**: And so, you have two TXHASH fanboys here in the talk.  I've
been helping Steven with the BIP for TXHAS as well for quite a while.  I think
it's a great eventual.  And one of the other things that's really great about
working on TXHASH is that with TXHASH, we can expose all parts of the
transaction to use in script.  And then, we can start kind of prototyping
scripts, how would I use this part of the transaction in a script?  And then, so
there's two paths we go from there.  We might decide that, "Oh, there's these
three bits of the transaction that we keep using when we're implementing test
things with TXHASH".  We keep using the amounts or the prevouts, or whatever it
is, and then we can make opcodes for those.  Or we find that each time we go to
a new script with TXHASH, we use a different part of the transaction.  And then,
the right thing to do is to go to the full TXHASH, because we're finding that
all of those different specifiers is used in different scripts.

So, the having TXHASH out there as a thing to play with in scripts is super,
super-helpful, even if it actually maybe never comes into Bitcoin Scripting
itself.

_Open letter about CTV and CSFS_

**Mike Schmidt**: "Open letter about CTV and CSFS".  So, James O'Beirne posted
to the Bitcoin-Dev mailing list.  This was a letter signed by dozens of Bitcoin
developers that quote, "Asks Bitcoin Core contributors to prioritize the review
and integration of CTV and CSFS within the next six months".  And there's been a
bunch of replies, as you can imagine, to something like that.  But of the
replies to that initial email, we highlighted in the newsletter three categories
of responses.  The first set were technical highlights, and there were two
there, although there's some subpoints, but concerns about making CTV available
in legacy script, and also limitations of CTV-based vaults.  I'll pause there
for feedback before we get into some of the responses from Bitcoin Core
contributors.  What's the concern about having CTV in legacy script?

**Brandon Black**: I don't know if there's a concern so much as changing legacy
script always has implications.  NOPs are a very limited resource.  CTV and
legacy script would use up a legacy script NOP.  We can't, as Bitcoin protocol
developers, predict the full future of Bitcoin.  We're trying to build Bitcoin
to be a 1,000-year technology for money, and those NOPs are kind of a precious
resource.  Whereas tapscript OP_SUCCESS opcodes, there's tons of those.  We also
have script versions in tapscript, we can make more script versions and reuse
the same OP_SUCCESSes for different things.  So, I think there's a, "Is CTV
worth using one of these very scarce upgrade hooks, or is it something that we
should use only in the less scarce upgrade hooks?"  I can really make arguments
either way, I don't have personally a strong feeling on this.  I do have a
preference essentially to use the code as it is.  We've been playing with that
code for a long time, it's been active in test networks for a long time.  But I
think valid arguments exist to say that CTV is not worth a NOP in the
post-tapscript world.

**Mike Schmidt**: Okay, so go ahead, Steven.

**Steven Roose**: I think it goes beyond spending the NOP.  I think there's a
lot of people who are very wary or cautious of changing legacy script behavior,
because it's a very not so well understood part of the consensus engine.
There's a lot of DoS problems that have been solved over the years with going to
segwit and tapscript.  So, as a community, we shouldn't really encourage people
to use the legacy scripts because there's all kinds of things that could happen,
and we should be trying to kind of soft deprecate it a little bit.  I think it
has very different opcode limits or signature limits, and all that kind of
stuff.  So, we should have people use what is the latest, which is tapscript,
which has a lot better DoS protections.  And personally, I don't think the
reasons for having it in legacy script are very compelling.  The only really
compelling reason or interaction with legacy script is using Script6 to do all
kinds of weird stuff in the BitVM world.  I'm not sure if that's the latest
still.  But for real, not hacked applications, I don't think the legacy script
usage is meaningfully different than just using tapscript.  So, then the
argument is, why would we open up this box of changing legacy script that we
don't really understand and we don't really want people to use anymore?  I mean,
I think that's mostly part of the argument made by the opponents.

One of the main arguments that people use in favor of legacy script is using
bare CTV, which means that you can send directly to a CTV.  I'm personally not
convinced it's very useful.  The only real use case of that is congestion
control, which is also a very controversial use case.  I think every use case
that I've seen that uses CTV uses it combined with some kind of alternative
paths, where you have either just CTV or some kind of alternative path, and that
just doesn't work with bare CTV.  So, then you never really use this.  So, what
we're building with Ark and I think what people are building with LN-symmetry
and DLCs would always use CTV plus some kind of other alternative path, and then
you just can't use bare CTV.  So, I haven't seen a compelling reason to have
bare CTV or CTV.

**Brandon Black**: That's exactly the question is, are there use cases where
you're going to have a series of transactions where you want exactly one
possible spend path and that spend path is a CTV.  And it's a little bit thin.
Congestion control trees are the one thing that's been shown.  And then, is that
realistically a thing, that whether it be miners or exchanges or anybody is
going to use?  That's a little weak.

**Mark Erhardt**: In this context, there was the proposal of pay-to-CTV (P2CTV).
Does one of you have an overview of what's that about and wants to explain how
that would also save those 8 bytes that bare CTV would save?

**Steven Roose**: Yeah, I think P2CTV is just a rework of bare CTV without using
the legacy script context, so then we don't open this box, but we still keep the
functionality.  I think the same question is there, like is the use case
compelling for this, because then we would be using another segwit version?  I
think it's the same question without the dimension of, should we open the box;
but then only the dimension of, is it actually useful?

**Brandon Black**: One thing to just throw out there, a lot of the concerns with
legacy script are specifically around the legacy script sighash modes.  They
have the quadratic hashing problems, and a lot of the other DoS stuff comes in
specifically because of the sighash modes.  And of course, CTV uses segwit-style
hash components to build its hash, so it does not have those same problems.  So,
I think the argument that, "Oh, we're opening the box of legacy script that has
these DoS", is a little thin as well, which is why I fall on that.  I don't
care, put it in legacy, don't; it doesn't really matter.  We're really not
opening those danger boxes in legacy scripts to add this opcode.

**Mike Schmidt**: The second technical highlight from the newsletter was around
limitations of CTV-based vaults.  I think this was Jameson Lopp who pointed out
a few things: one, address reuse being bad, we all know, but specifically in
this vault setup; theft of staged funds; key deletion being not as hard as
people maybe outlined, and Gregory Maxwell noted a simple approach to that; and
also one of the advantages of CTV-based vault being static state, but there's
potentially other ways to achieve that without CTV.  We have bullets on each of
these from the newsletter, but I'll open it up for Steven and Rearden to comment
on the validity of those.  Any feedback on that?

**Steven Roose**: I mean, I think I can summarize whatever was written or
whatever has been argued before, is that it's very opinionated, right?  So, many
people have the opinion that any meaningful vault construction that's actually
adding real security is not possible with just CTV, and you would need something
else like a vault, or something like CCV (CHECKCONTRACTVERIFY) where you have
the ability to actually convey state from one UTXO to the next, which CTV
doesn't give you.  And so, then some people find it not really honest if people
use the vault arguments as a reason to activate CTV, because they say,
"Actually, you cannot really make vaults with CTV".  I haven't looked too deeply
into the construction that people have actually used.  I think it's mostly
presigned transaction-based vaults, and then just make them less interactive
with CTV.  But they have a lot of limitations and a lot of foot guns, but I
don't really know the latest on that.

**Brandon Black**: I can add a little bit more there.  The simple thing is
exactly what's been discussed here, is that CTV, all it does is it gives you the
exact same vault features as a presigned vault.  There's not a difference there,
except you don't have to create and delete key material and then save presigned
transactions to get that functionality.  So, is that a benefit worth pursuing
for this vaulting use case?  I'm not sure it is.  I think Jameson said, you
know, they talked about in the thread about we really want something like CCV or
OP_VAULT.  But then, I think we can also say some people in the world use
presigned transaction vaults.  It seems to be only people that are bespoke
writing their own software to do so that use presigned vaults, it's not a
commercially available product.  I think, I forget, someone made it and tried to
make a commercial product out of it.  It didn't go anywhere.  Would CTV move the
needle and bring maybe more people to using that same vault structure, just
without the creating ephemeral keys and deleting them?  I don't know.  But it is
an improvement in that status for vaults.  It's just not the point where we
could now make this a commercial, recommended practice.

**Mike Schmidt**: So, the next category of responses that we categorized for the
newsletter were responses from Bitcoin Core contributors.  So, the first two
items we talked about were more technical discussion-related.  These are a
little bit softer.  I summarized the summary quotes here.  We had Greg Sanders.
He was disagreeing about that the bar for changes or objections being only
egregious breaks.  He disagreed with that bar and thought that there could be
other objections.  And he also rejected a time-based ultimatum, but noted
CTV+CSFS are worth considering.

AJ Towns commented that he thinks the CTV discussion has missed important steps,
including steps he has advised CTV proponents to take, and that the letter is
creating incentive problems, not solving incentive problems.  And Antoine
Poinsot said that he sees the effect of the letter as a major setback in making
progress, and recommended someone do the work of addressing technical feedback
from the community and demonstrate use cases.  And finally, Sjors was saying
that vaults were the only interesting feature enabled by the soft fork that he
would personally work on, and that he doesn't oppose the soft fork and hasn't
seen an argument that it is harmful.

So, well, I don't know if there are other Bitcoin Core contributor responses,
but those are the ones that we highlighted this week in the newsletter.  Maybe
we can pause there.  Steven or Rearden or Murch, do you guys have comments on
that feedback?

**Steven Roose**: Well, Murch, you want to go?  Yeah, I wanted to say, I felt
that there was more drama created by that letter than should have been created
or that many of the writers intended to create.  There was a lot of talk about
threats or just intentions that were, for some reason, for some people,
interpreted in the letter that I think for many of the signers were not there.
I know for a fact that earlier versions of the letter included way more hard
wording about an actual ultimatum or an actual, yeah, an ultimatum, and that
those versions of the letter were NACKED by several of the signers, and then a
softer version was created.  I didn't personally feel like there was an
ultimatum, I didn't personally feel like it was an attack.  It was more like,
"Hey, we want people to look at this".

I think a bulk of the opinion or response or argumentation from Core against the
push of the letter is that several Core contributors have in the past
participated in the conversations around, and have highlighted some part of the
process that they feel is lacking.  And I think most of their critique is that
many of the letter signers are not actually trying to address the things that
Core contributors would want to see addressed, and they're just signing a letter
and not really doing the work.  I think both sides have had valid arguments.  I
don't think letter signers had bad intent or wanted to put ultimatum.  It's
possible that some of them might, but I think at least myself and the people
that I interact with that I know also signed the letter didn't have those
intentions.  I mean, I consider it a little bit of an unfortunate turn of
events, but yeah, that's my take.

**Mike Schmidt**: Rearden, did you have a comment?  Rearden, you're a signer as
well, yes?

**Brandon Black**: Yeah, I'm a signer as well.  I responded on the mailing list
with one of my takes, which is essentially, there's a few dimensions to this
that are going on at the same time.  So, I think that writing a letter like
this, and I think also the things that I've done, I've stirred the pot a bit at
times on X and elsewhere about consensus changes for Bitcoin.  And I think that
improvements to a complex, globally-distributed network with high software risks
and lots of money resting on it, that's maintained by a small group of dedicated
contributors, there's a lot of things that have to happen.  And one of the
things relates to essentially the social energy around something.  And so, a
letter like this is partially about saying, "Hey, here's some social energy
around this, see the energy".  And that then is meant to encourage a response to
the energy that's out there.

But then, as Steven pointed out, that energy can be interpreted in a way that
looks more like a threat than a positive energy.  And then, there's a lot of
dimensions to this, and there's many ways to look at it.  And we are living in a
global world of many.  There's not one Bitcoin community, I guess, is what I'm
trying to say here.  There's a bunch of different Bitcoin communities that are
having literally different experiences of the world, of this letter, of
everything going on.  And so, that's the world we're living in.  And the other
thing I want to say, just one last comment here, is the letter was, as Steven
said, deliberately rephrased to not include any kind of an ultimatum.  It was
trying to say, "Look, we think that one of the important tasks that Core should
be doing is reviewing consensus changes that are active, and essentially,
there's not some strict process".  So, Anthony likes to say they haven't done
the process that I suggested.  Well, not everyone wants to go through your
Inquisition process.  I love that you built Inquisition, that's a really cool
thing, but there isn't a written-down process for how to get changes into
Bitcoin.  So, maybe people want to do changes in a different way.

Sorry, I got off track for what I wanted to say.  The short thing I wanted to
say is that there's not an ultimatum in the letter.  And I think that's an
acknowledgement that if Core does not address the potential for needed consensus
changes, it will be necessarily the case that there will be an alternative
software implementation that does address the need for consensus changes.
That's not a threat.  We've seen that in other open-source projects over the
decades.  The Xorg fork comes to mind as a time when that has happened.  If a
project stops responding to the needs of that project, the project forks.  It
will happen.

**Mark Erhardt**: Let me jump in here briefly.  So, I would like to point out
that in the letter it very specifically says, "We respectfully ask Bitcoin Core
contributors to prioritize the review and integration of CTV … within the next
six months".  That is a very explicit request for a timeline and an action,
which I feel, just to the integration into the codebase, is a request to do
something within the timeframe.  Just responding to some looks here.

**Brandon Black**: I don't read the letter that way.

**Mark Erhardt**: It literally has that sentence in there, "Do this in the next
six months"!

**Brandon Black**: "Prioritize".

**Steven Roose**: "We would like you to prioritize doing this in the next six
months".

**Brandon Black**: Right, not 'do' it in the next six months, 'prioritize' it in
the next six months.

**Mark Erhardt**: Well, as we can see, there is already some disagreement on how
to read that sentence!  Anyway, this is the sentence that seems to surface this
controversy.  The other thing that I wanted to point out here is I feel that
obviously, the work on introspection opcodes and the integration thereof into
the Bitcoin Core codebase is something that only appeals to a subset of the
Bitcoin Core contributors.  And I believe that many of these contributors have
been around to talk about many of these proposals.  I'm thinking exactly of the
people that have been responding, but also others like Ava Chow is on the record
of being happy to help people work on a PR to propose this sort of work into
Bitcoin Core.  And I think there's not really an active pushback on working on
these things, but rather that it is competing for attention with other work
people are already doing.  And from my perspective, as well as others that have
stated here, I think there is also an onus on the proponents of this letter.

There's 60 signatories of this letter, and a subset of these are people that
have worked on the Bitcoin Core codebase before, that very much would be capable
of reviewing and demonstrating use cases of CTV that have not put in the time or
effort here.  This is true for many people to a lesser degree.  Many of the
signatories would perfectly be capable of writing up a blogpost how CTV would
change their product or their project, or something.  I know there's a lot of
discussions on Twitter or forums or chat groups, but I don't see most of these
signatories putting in any effort beyond signing this letter, where I would say,
"Oh, I see that you're putting your own effort for the effort that you're
demanding other people take out of their priorities".

**Brandon Black**: So, I'm curious.  I mean, I'm a signatory and I've been going
to Bitcoin conferences speaking, demonstrating use cases in talks for the last
three years.

**Mark Erhardt**: I'm not talking about you, definitely not.

**Brandon Black**: But what would it look like if people were doing this, when
many of the signatories are doing this, myself included?

**Mark Erhardt**: Well, I think it's a very small count of the signatories that
are doing this.  So, basically, what I'm saying is you were talking about social
energy earlier and we've had a few soft forks in the many past years, but only
very few.  And there's sort of a sense of the energy around a proposal.  Sort of
people are excited about it because something immediately generates a lot of
excitement, and people are excited because other people are excited.  And just,
there are some people that are excited, but not excited to the degree where they
actually drop other stuff and work on 'really this needs to happen' sort of
excited.  So, my argument is people are not that excited about CTV because
people are not that excited about CTV, which is weird, but that's sort of how it
often feels to me.  So, I'm in the camp that I haven't seen any strong arguments
against CTV, especially CTV+CSFS has had growing support in the last few months,
I've seen.  I think that the debate has been more productive lately, maybe also
instigated by this letter, even though many people were complaining, I think
mostly because all sides have good arguments in this conversation, I think.  And
just because there's so many people talking for one side here, I want to give a
broader picture here, right?

But I feel like this swelling excitement that begets more excitement threshold
just isn't present, and I think people could help grow that by being more
invested in their support for CTV, like actually going out there and saying,
"Look, I spent a couple of afternoons writing up in detail how this would change
my product, my project.  This is exciting, this is how it actually would make
stuff better", present company excluded, because I know that you two have been
very involved in this discussion.  So, please don't feel that I'm talking about
you, but I'm very much talking about, I think by count, the majority of the
signatories of that letter.

**Brandon Black**: I think this is such a great topic.  I want to respond to one
part of what you were saying, which is the energy there was for previous soft
forks.  Christian Decker made an amazing point when I met him for the first time
last year in Austin, and I just thought it was so important.  And it's something
that we overlook about the taproot soft fork process, which is that a lot of
what people were excited about with taproot didn't actually exist.  And a lot of
it, of a subset of that, wasn't even possible with the final choice of things
included in taproot.  So, there was excitement about taproot, partially because
people believed things that were not true about it.  And one of the things that
I think the CTV+CSFS proponents have done a very, very careful job with is not
letting that happen with this, not letting people get excited about something
that it won't actually offer, as you see in this vault conversation.

So, I think that that's part of why we don't see that groundswell from the
broader kind of less technical users is because unlike with taproot, those users
aren't getting excited about things that can't actually be happening.  We could
be out there saying, "Vaults are going to be amazing with CTV".  That would be a
lie, and we had that kind of thing with taproot.  So, I think it's a difficult
thing.

**Mark Erhardt**: I think that's a fair point.  I think you're especially
referring to cross input signature aggregation in this context, and MuSig being
of course still in the works as taproot was already being deployed.  But I think
that also, yes, you are correct that people have not been talking about vaults
as much in the context of CTV, but vaults, for a very long time, was the key
selling point for CTV.  So, in a way, yes, but in the past, that was exactly the
case.

**Brandon Black**: Anyway, so I guess the point there is just that it's
super-important, I think, for Bitcoin's future that we not do what happened with
taproot, we don't let that happen.  I think people like Steven, myself, and a
lot of the other CTV advocates have been doing something that is exactly what
Christian would recommend, which is not letting that vault, "Oh, vaults are
going to be amazing", not letting that be the driving thing that gets CTV in,
because that would be essentially an accidental technical lie to the community
again.  So, I'm glad of where things are.  As you said, there is growing support
right now.  I also think there's this difficult thing that goes on, where a lot
of work has been done that shows great use cases for CTV.  And people say, "But
I haven't seen it", because it's on this platform and not that platform; it was
in a talk, not a blogpost.  I don't know what to do about that.  As I said, we
have a bunch of different Bitcoin communities and we live each in our own little
Bitcoin community.

**Mike Schmidt**: Well, I mean that's an interesting point, that last point.

**Mark Erhardt**: I think, explain it like I'm 5 in Bitcoin Magazine that really
shares excitement of why we absolutely need to have CTV.  Then you've managed to
actually raise the excitement to the surface level of the Bitcoin community, the
broader superset of Bitcoin.

**Steven Roose**: I wanted to touch on some other dimension other than showing
excitement, showing use cases.  I think one other dimension that the letter kind
of implied for myself, and I don't know to what extent for other signers as
well, is that there's this argument and this notion that Bitcoin is a protocol,
Bitcoin is not an implementation.  Bitcoin Core is not Bitcoin, right, it's an
implementation of Bitcoin.  And the excitement-building and protocol-building
and proposal-building should happen first on the protocol level, right?  It
should happen in the broader Bitcoin technical community, everyone building
applications, building libraries, building tooling, building wallets, and stuff
like that.  And only when there's clear consensus on, "This is what we want", it
should move into implementations, and Bitcoin Core is just one of the
implementations.  But personally, I mean I feel there's only one real
implementation.  People talk about Knots, especially in the recent OP_RETURN
drama, but Bitcoin Core is basically the one implementation that Bitcoin has.

I think one of the messages that the letter conveyed is like, "Hey, we know that
there's broader Bitcoin protocol, Bitcoin, but we want you people, Core
contributors, to be included in this conversation", right?  Because many people
feel like, okay, the application-developer people, people building second
layers, they are excited about this, they want this.  I mean, they have for
themselves built a convincing case that this is good.  But I think many people
have this feeling like, okay, Core has been maybe purposefully, maybe not,
trying to not participate too much in this conversation.  Some of the
contributors have been, but I think many of them have just steered away from
participating in consensus in general.  And I think one of the messages in the
letter was like, "Hey, everyone, we want Core to drive this.  We don't want to
do an alternative client.  We want Core to be the primary driver, not Core, the
team, but Core implementation, of future consensus changes in general", right?
We don't want to do alternative client shenanigans, UASFs, and all that, without
having Core behind those decisions.

I think, I mean in my opinion, that's a positive thing.  I think being all
behind the same implementation is good.  Otherwise, it would become a lot of
fighting and potential fork drama, and all that.  And yeah, I thought that was
one of the positive aspects in this message.  It's like, "Hey, Core, we want to
include you in this conversation, we want your feedback.  We want to know from
you what needs to be done for you as a team, or as an implementation, to help
drive the next soft fork".

**Mike Schmidt**: Murch, I see your hand up.

**Mark Erhardt**: Yeah, I was still pondering how to phrase this.  I think this
leaves a little bit of a taste of, yes, it would be great for Core to comment
more on this, but one of the main critiques that came out of Core contributors'
responses was, "Well, we've been commenting on this for years and you're not
addressing our feedback".  So, I think there's sort of this standoff here, where
the application developers are saying, "We would like Core to have a bigger
share in this", but they're not saying exactly what they expect out of Core.
And it almost sounds like you're asking for a Core contributor to stand up and
start championing it, which is weird, because why would you ask someone else to
do the work for you if you can't convince yourself to invest the time to do it?
Whereas, on the other hand, Core feels like we've been addressing this, we've
been commenting on this, and our feedback is not being picked up.

So, clearly there's not really clear understanding from either side of what the
other side is looking for.  So, I think there is several signatories on that
letter of people that have familiarity with the Bitcoin Core codebase to the
degree that they at least would be able to, say, take up Ava's offer to get the
technical expertise on how to work on the PR, but to work on the PR themselves
with the support and review of Bitcoin Core contributors.  I just don't see
someone that is maybe interested to review it, to stand up and champion it for
the CTV proponents.  So, I think that that's sort of what's missing, someone
from the signatories that actually wants to be the prime author of the PR.
Whereas, yeah, I think it came across.

**Brandon Black**: I'm confused.  James has open PRs for both CTV and CSFS
against the Core repository.  So, what do you mean someone to do it?  James is
doing it, it's there, the PR's open for review.

**Mark Erhardt**: I don't want to get too much into the consistency of these
sorts of proposals, but it's sort of really ebb and flow.  Like, yes, there's a
lot of work for a few weeks and then some proposals are opened and then review
feedback sits, or they start doing other stuff again.  I think that just someone
needs to consistently work on it if they want to see it done, and I think it's
unlikely for someone that is not a direct proponent to pick up that mantle.
That's what I'm saying.

**Brandon Black**: Interesting, yeah.  I mean, I'm one of the people who's
opened these PRs and gotten feedback.  So, I can speak for myself as a signer of
the letter and someone who's done that.  The feedback that I got was, I think
there was one piece of feedback that I did not address that was about the code
itself, and the rest was not about the code itself, but about, "You should have
other applications already done".  Anthony Towns, of course, saying, "You should
have this in Inquisition first".  I didn't get feedback on the code, I didn't
get feedback on PR, I got feedback on, "There should be other applications", or,
"This should go in Inquisition first".  So, there's this very strange thing that
happens, "Oh, people are responding to the feedback, but the feedback isn't
actually about the PR I opened".  So, that's, I think, one of the things that is
reflected in why this letter came into existence, is that kind of loop that
people get stuck in.

Then the other thing worth mentioning, and this is why I called out that the
word was 'prioritize' in the letter, and you had a different reading than me,
which helps explain a lot of the drama around it.  So, that's good, thinking
about how English works.  It's kind of a terrible language.  But that, to me,
what I would love to see personally, as a signer of the letter, is that on the
list of Core's priorities, somewhere in that top ten priorities list, should be,
"Consensus improvements to Bitcoin".  And right now, "Consensus improvements to
Bitcoin", is not on Core's priority list at all.  That's what I meant when I
signed a letter saying, "We want Core to prioritize this in the next six
months".  Consensus changes should be one of the top priorities of Bitcoin
Core's overall project priority list, and it's not even on there.

**Mike Schmidt**: A couple of things that I wanted to highlight at the high
level here, and it touches on some things that Murch said and Rearden said,
including the prioritization list or not.  Obviously, that's really
individual-based, but the communication between what is now sort of two groups
that used to be one group, you would expect things like this.  I've sort of
joked to Murch over these last few years when we do these shows about, "Hey,
every other week there's another covenants proposal".  We would sort of joke
about it.  But behind that is like, how is Core supposed to prioritize that when
some of the authors of these proposals don't even know what the other proposals
are?  And I think one thing that comes out of this letter, to me, clarifies
that, "Oh, okay, this appears to be, the group of people who are most interested
in putting most time on protocol work, specifically around script, sort of agree
now".  Like, the thing that we were sort of joking about, that it would be great
if the protocol people agreed between themselves before anybody did anything, it
does seem with Rearden, who I believe said OP_CAT is getting activated, and
Steven, who has a competing TXHASH proposal, are saying, "CTV+CSFS".

So, it seems like what's come out of the protocol sphere is some consensus in
that group, which I think is an interesting question to have answered.  And I
think that's what the letter serves, at least in my interpretation.  And then, I
think that the second thing is, given now that there's these two groups, with
some overlap of course, what is the way that one group should communicate with
the other group?  And that is both ways, but I think the bigger concern is the
protocol folks communicating with Core, like, what are we supposed to say and
when?  And obviously, this letter maybe had pieces that were useful and not
according to that communication, but it's entirely predictable that this sort of
thing would happen, that there'd be a little bit of friction in the
communication, when it's not sure what should be said or when, because these
groups used to be one group and so the communication was maybe a little bit
tighter.  And so, just two things that I've seen high level on that.

**Mark Erhardt**: Yeah, I was going to ask, Steven, you seem to want to chime
in, but okay.  I have one more maybe instigating question.  It feels a little
bit that some of the signers don't actually want CTV.  It's just sort of maybe
the least common denominator, "Maybe that's something we could get now, so
better than nothing".  How would you say is the dynamic here?  Is CTV+CSFS sort
of what people want, or is it just at least better than nothing?  What's the
dynamic?

**Steven Roose**: I think definitely the direction of CTV+CSFS is what people
want.  I mean, that's at least a feeling I have, whether it's like, there's
implementation details, obviously, should we do tapscript only; should we do
bare; should we do like whatever; those kinds of things?  But I think what the
letter conveyed is just like Mike said, there used to be a lot of wildly
different proposals, like CCV, TXHASH, vaults, all that kind of stuff.  And what
this letter conveys is, okay, whatever else might be interesting in the long
term, what we think should be first, because it gives significant benefit for
the amount of work that it would require, is to do this first, something that is
related to templating and signing messages, right, something like that in the
broad sense.  Because the ideas are very old, like CSFS has been in Liquid for a
long time, CTV has been around for a long time, also the idea, so like this is
mature enough, it's not risky and the benefits that it gives are significant
enough.  And of course, obviously people will have ideas that, "Okay, we should
also do this, we should also do this", but maybe not now, because the time is
not right and we don't have enough use cases built up for those additional
things.  At least, that's the position I'm in and I believe many people are.

**Mark Erhardt**: Okay, slight curve ball.  TXHASH, we've talked a little bit
about already as a more general, broader take of CTV, I think.  And we've also
touched on CCV five times in the past.  So, I've recently merged CCV to the BIPs
repository.  I think that CCV has been making deliberate but good progress, and
is doing a good job of sort of explaining exactly what problem it is solving.
And so, for example, in the context of vaults earlier, people said that CCV
would allow to transport state from one UTXO to another, different from CTV.
So, I just wanted to pick both of your brains for if you could have CCV next
week or CTV+CSFS, or maybe CCV+CSFS, to make it fair, what would you think about
that, compared to CTV+CSFS?

**Brandon Black**: I'm a huge supporter of CCV.  I've been pushing whenever I
see him, Salvatore, to finish kind of the -- he's great.  He really was focused
on the Merklize All The Things (MATT) broader framework for Bitcoin contracting.
And I was like, "Come on, finish the CCV-based piece of that!"  Anyway, so I'm a
huge fan.  The thing that I will say is that CTV+CSFS have a lot less potential
for controversy around them than CCV.  And one of the things that I
demonstrated, just I did a while ago, OP_VAULT quines, is that any proposal that
has the ability to transport state, as Steven said, like CCV does, opens up a
new category of potential for MEV, or centralizing MEV, that is not present in
something like CTV+CSFS.  So, my opinion, and the reason I'm a signer on the
letter, is that CTV+CSFS are about the most we can do without doing a huge
amount of additional analysis on the risks of additional contract types.

That said, Jeremy Rubin would disagree with me, and so I want to represent his
position here as well, because I think it's important, as the author of CTV.
And he would say that because CTV+CSFS can let you unroll a contract, especially
with taproot, with arbitrary numbers of branches, and as deeply as you would
like, you can have millions of steps, there is less difference than people think
between CTV, CSFS, and CTV, CSFS, CCV.  So, there's that position as well.  I do
think the difference is material, and I think there's a lot of analysis that
needs to be done before we do something like CCV, that doesn't need to be done
for CTV+CSFS, and that's why I really support CTV+CSFS as a step right now.  It
improves a whole bunch of things, from PTLCs, DLCs, BitVMs, whatever we're
working on.  It's hard to find a protocol that CTV+CSFS doesn't offer some
improvement to.  And then, I think we should keep working towards CCV, doing
more analysis.  That seems similar to TXHASH, something that we want to kind of
go deeper on before we would act.

**Steven Roose**: I'd like to say two things, maybe three.  First, the question
was, "How does CTV+CSFS compare with only CCV and CSFS?"  I think, and please
correct me if I'm wrong, I think CCV itself doesn't really give any
introspection other than the contracts that is the actual state that it's trying
to convey.  So, you cannot fix other things, like outputs or inputs, and stuff
like that, that something like CTV gives you.  So, it's not really replaceable.
So, CCV makes sense on top of the other two, not really as a replacement of CTV.

The second thing I want to say is that CTV does two things.  The main thing it
does is it moves the state from one UTXO to the next using this contract hash
and the tweak using taproot, and that's certainly useful, and you can do a lot
of things with that, even though it's only 32 bytes of state.  You can build
trees and actually, it's very powerful to just move 32 bytes of state from one
place to the next.  But in order to make this ergonomic, to build stuff like
vaults or to build contracts, where not just state but also money, because it's
Bitcoin, moves around, is you also need to somehow look at the amounts of the
different inputs and outputs of a transaction.  So, CCV also has some semantics
around that, and I think it's a little bit opinionated in the way of how should
the amounts be handled.

There's been some feedback on the initial approach that Salvatore took, because
the semantics basically break out of the single input context, and then it
becomes a little bit of a technical discussion.  But usually, inputs are
verified as like a script that is on the output, and then the input provides
witnesses to the script, and then you do some validation.  And usually, the
context is only the input itself.  But to make meaningful vaults, where you can
use multiple inputs and then create multiple outputs, you need to look outside
of your input, like, what are other inputs in this transaction doing?  And
that's something we don't really do a lot, other than sighashes today.  And so,
the way that Salvatore did this was a little bit controversial, or at least
there was some feedback on.  Maybe we can do this in a cleaner way, that we
don't have to do this cross-transaction context execution.  And I'm not saying
the way he did it was wrong, I'm not saying the critique is justified, but I
think it's just more opinionated still, and there's some review that can be done
that just isn't the case with the concepts of CTV+CSFS, that are more
well-defined already.  And we're like, this is conceptually the way to do it
without that much opinion or bike shedding.  Yeah.

Oh, and then, yeah, I think I missed the third thing that I wanted to say.  I
think it was included in the second!

**Mike Schmidt**: Well, the third section of things that we highlighted in this
item were signers and clarifying their intentions.  But Steven and Rearden,
we've had you firsthand to clarify yours.  We also highlighted James and
Poelstra and Harsha's comments, but given we've sort of had a good discussion on
this item, is there anything else that you all would add, based on what they've
said, or anything else that we should say before we close out this item?

**Brandon Black**: I'm so glad we talked about this topic.  It's
super-important.  Thank you guys.

_OP_CAT enables Winternitz signatures_

**Mike Schmidt**: Next item, "OP_CAT enables Winternitz signatures".  User,
Conduition, posted to the Bitcoin-Dev mailing list about a prototype
implementation that he created using OP_CAT to allow Winternitz
quantum-resistant signatures.  Jonas, you've posted about some of your work on
Winternitz one-time signatures, or WOTS, I guess it's called.  I think you were
doing stuff with great script restoration (GSR) in the past.  AJ Towns had
something that he prototyped in Bullish for Winternitz.  Is Winternitz some sort
of quantum Schelling point at this point?

**Jonas Nick**: Yes, I think for context, the overall question is how do we make
Bitcoin spends post-quantum secure?  And one way to do that would be to have a
post-quantum signature verification in script.  And as far as we know with
today's Bitcoin script, that's not possible.  So, one possible approach would be
to introduce a new opcode, similar to CSV (CHECKSIGVERIFY) that just verifies a
post-quantum signature.  And another approach is to implement a post-quantum
signature verification algorithm within Bitcoin Script under the assumption that
some additional opcode has been added to Bitcoin Script.  And it has been shown
that you can actually implement such a verification scheme if just the OP_CAT
opcode was introduced to Bitcoin script.  And now, the more specific research
question is, how large would a Bitcoin Script, a witness be if you want to
implement a post-quantum verification on in Bitcoin Script.  And so far, there
was Jeremy Rubin who popularized the idea of implementing so-called Lamport
signatures in Bitcoin Script with OP_CAT.  And now, Conduition improved on that
by implementing so-called Winternitz signatures in Bitcoin Script.  And his
witness is about 8,000 bytes and Jeremy Rubin's was about 10,500 bytes.

My sort of implementation of this was not based on a CAT-enabled Bitcoin Script,
but rather on the GSR.  And interestingly, that witness was much, much larger.
It was about 24,000 bytes, so more than double the size of Jeremy Rubin's
approach.  And the reason is that I implemented a variant of Winternitz, which
has some different cryptographic assumptions, but I believe those assumptions
aren't really necessary for Bitcoin, at least right now.

**Mike Schmidt**: Is that the collision resistance?

**Jonas Nick**: Right, so let's maybe give a little bit more context then.  When
you have a signature scheme, you can base it on various cryptographic
assumptions, and the hash-based signature schemes, they can be based on, for
example, collision resistance, like the original Winternitz proposal, or, for
example, a stronger assumption, which is called preimage resistance.  And what
you want is ideally to not rely on those weaker assumptions, right, you want to
rely on stronger assumptions.

**Brandon Black**: Sorry, Jonas, just to be clear, the pr-image resistance is a
weaker assumption, right?

**Jonas Nick**: Oh, right, I should say, yeah.

**Brandon Black**: It's like weaker and stronger are sort of backwards in some
sense.

**Jonas Nick**: Right.  So, yeah, you want to base your cryptographic security
on weaker assumptions.  And so, Conduition's Winternitz implementation is based
on the stronger assumption, collision resistance, whereas my implementation was
based on the weaker assumption, preimage resistance.  But, if you look at
Bitcoin, we already very much rely on collision resistance of SHA256.  So, for
example, in the transaction merkle tree or in the blockchain itself, so if that
were broken, then we have chain splits and worse problems than just signature
verification.  So, I think this approach of basing it solely on collision
resistance, I guess there are also some variants of collision resistance that
might be worth looking into, but it seems like it's definitely a fine approach.

**Mike Schmidt**: You said that your implementation used GSR, but did you also
with it, because that also turns back on CAT, right, did you use CAT within
that?

**Jonas Nick**: Yes.  It uses CAT and it uses a couple of others.  So, most
importantly probably, it uses OP_XOR, it's not available in regular script, and
which simplifies things in my implementation.

**Mike Schmidt**: Tadge or Murch, any questions for Jonas?

**Tadge Dryja**: No, I think it sort of makes sense.  And yeah, I agree that if
you're really saying, "Okay, we only are going to base on preimage resistance",
there's a lot of changes.  I don't even know how you'd change Bitcoin to work
that way.

**Jonas Nick**: I think this approach, or at least Conduition showed to me, at
least, that this approach of doing post-quantum signature verification within
script is not too far-fetched, because the witness size is still only 8 kB.  I
would have expected it to be larger actually, also given my own experiments.
So, I think this is really interesting and so continuing on that work, the
question is, how optimal can we get?  There was a suggestion also from AJ Towns,
who I think mentioned some 10% improvement, or so.

**Mike Schmidt**: Now, I don't want to put you on the spot, Jonas, but if you
know, with BIP360, I think there's a variety of quantum signature schemes
proposed as part of that bundle.  How big are those, if you know off the top of
your head, or approximately how big?

**Jonas Nick**: So, first of all, I think BIP360 was changed significantly in
the last week.  So, I don't think those signature schemes are even part of
BIP360 anymore.  But anyway, so when talking about post-quantum signature
schemes, there's sort of different roles and different assumptions that these
are based.  And Winternitz Lamport signatures, they're also so-called hash-based
signature schemes and they are known to be large.  But the advantage of that is
that they are only based on assumptions that we already use in Bitcoin, kind of,
because we already rely on collision resistance of SHA256, as we said, so they
wouldn't add any new assumptions.  But there are other cryptographic assumptions
that you would potentially be able to introduce to Bitcoin which result in much
smaller signatures.  So, depending on the assumption, it's between maybe 200
bytes and 2,000 for the other class of signature schemes.

**Mike Schmidt**: Okay, yeah.

**Jonas Nick**: And just for comparison, the schnorr signature is 64 bytes, so
it's still the smallest.

**Mike Schmidt**: Great.  Jonas, I know sort of you're representing Conduition's
work here, but maybe in the bigger picture, is there a call to action for folks
who might be in the audience on this sort of topic?  It seems like maybe only a
few people understand this sort of thing, but I'll give you an opportunity
either way.

**Jonas Nick**: Well, yeah, as I said, how far can we go?  How small can the
script be?  Can we reduce it to, I don't know, 4,000?  I don't know.  It might
be an interesting question.  Perhaps not, but I think at least we can probably
reduce it by a little bit.  I think Conduition, he said that he's not a script
wizard, which I don't really believe him, otherwise he wouldn't have written his
script in the first place.

**Mike Schmidt**: All right, Jonas, thanks for joining us.  You're welcome to
hang on as we talk about the commit/reveal scheme from Tadge here.  Otherwise,
if you need to drop...

**Mark Erhardt**: Maybe just as a short insertion, I was pulling up BIP360 in
the background here and it was recently rewritten by Ethan Heilman, or not
rewritten, heavily edited I should say.  I think that the P2QRH
(pay-to-quantum-resistant-hash) output type -- this is a very brief
investigation -- but it says 135 vbytes for the witness of the proposed P2QRH
input.  So, that would be not that much bigger than P2TR.

**Jonas Nick**: If I understand correctly, the idea of the updated P2QRH is
essentially, put the taproot merkle tree in the output directly.  So, what is
missing from there is then an opcode or something, or OP_CAT, that actually does
the post-quantum signature verification, right?

**Tadge Dryja**: Yeah, I think that's sort of the overhead.  And then, the
signature size is in addition to that 100-something vbytes.

_Commit/reveal function for post-quantum recovery_

**Mike Schmidt**: Next item from the newsletter, "Commit/reveal function for
post-quantum recovery".  Taj, you posted to the Bitcoin-Dev mailing list an
email about a post-quantum scheme for spending bitcoins, even from
quantum-vulnerable addresses, using a commit/reveal scheme.  I'll let you lay
the land however you want, but I think we've talked about quantum signatures and
things like that, so folks may not be familiar with what a commit/reveal scheme
is more generally, but feel free to take this wherever you'd like.

**Tadge Dryja**: Sure, it's maybe counterintuitive, like on the one hand, I
think it's a cool idea.  It's also not really a good idea in that it's not like,
"Hey, this is great.  This is how Bitcoin should work".  It's more of a, "This
is a way we can survive", if a quantum computer shows up next month and we don't
really know what kind of signature scheme and there's tons of coins that are
just sort of out there.  This could work and it and it saves Bitcoin from dying
and it is usable; it's not great, though, there's a whole bunch of downsides.
But the idea is you can sort of keep using Bitcoin without any post-quantum
signature scheme with just using this sort of commit/reveal mechanism.  And
basically, that commit/reveal mechanism just uses OP_RETURN and hash functions.
And I guess, I think you're looking at the collision resistance of it.  I
actually think it might just be preimage resistance.

But yeah, basically what the dumbed-down version that doesn't really work well,
although does sort of work, is imagine if before you wanted to create a
transaction in Bitcoin, you first had to post an OP_RETURN of its txid.  And
right now, you don't, obviously.  You can just create a transaction, have the
input signed, have new outputs, throw it into the mempool, send it to people,
it'll eventually get to a miner, and it gets mined and it works great.  But you
could imagine a soft fork where all the current rules are still the same, but
you say, "No, anytime I see a transaction in the mempool or anytime I see a
transaction in a block, I first look up in a table of OP_RETURNs I've already
seen.  So, every OP_RETURN I see, I sort of add this to a map or a key value
store".  And I say, "Okay, now if I see a new transaction, I first look it up in
this map.  And if the txid is already there, great, valid.  If the txid is not
there, that's invalid.  I don't accept that transaction".  And that gives you
the idea.  So, the actual mechanism is a bit more complex.  There's sort of
three values instead of just the one txid.  But the txid gives a good intuition
of how it would work.

The part that's counterintuitive is your public key becomes your secret.  So,
this doesn't work if you've reused addresses, right?  If you've used an address
multiple times, everyone knows what the public key is.  And also, it works with
taproot, but it gets a lot more complex.  But if you just think of like P2PKH or
P2WPKH, you generate a pubkey, you hash it, that's your address, people send to
that hash.  And then, when you want to spend, you reveal not just your
signature, but you also reveal the pubkey for the first time.  And so, what
protects you is that the quantum attacker, you assume a quantum attacker that's
got a great quantum computer can immediately, as soon as it sees a public key,
can sort of snap of a finger generate the private key for that pubkey and then
forge a signature.  It's a totally valid signature at that point.  So, a slow
quantum attacker, people say, "Well, maybe the pubkey hash is enough security,
because if you post a transaction, it might take them a day to find your private
key from your public key, and then you can get your transaction confirmed and
then it's too late for them".  That might work, but this is a way to make this
timing such that even if the quantum attacker has immediate access to your
private key, it doesn't matter because the OP_RETURN happens first.

The idea is you construct your transaction, you know where you want to send the
money, you look at what that txid looks like, you then commit the txid in an
OP_RETURN.  And that txid doesn't really tell anyone anything.  Even if you have
a quantum computer and you look at the txid, even if you know everything about
what the, you know, you have a specific person you're trying to target and
you're saying, "Okay, I know that Murch is going to spend his UTXO here and he's
gonna send it to his other UTXO and I want to try to malleate that transaction
and send it to myself instead".  Just seeing the txid doesn't give you the
pubkey and doesn't give you any useful information.  And so, what it does is
once that txid is confirmed as an OP_RETURN, you now can't change where it's
going.  Once that transaction is posted, I can now try to create my own txid in
an OP_RETURN and front run that way.  And that's what the actual two hashes are
to make it so that you don't have that problem at all.

But this is the basic mechanism.  That's the good part.  The good part is if you
haven't reused addresses, and you have pubkey hash addresses or taproot with an
asterisk, the way you'd do it with taproot is you need an inner key as well.
Your inner key of your taproot output becomes sort of like the pubkey in a
pubkey hash system.  So, that's a little more complex.  But what would be nice
about this is that, okay, quantum computer shows up, you can still move your
coins and your coins are safe, even if a quantum computer shows up and we don't
have any new Winternitz or quantum-secure signature system.  The problem is
then, how do you get the OP_RETURN in?  And that's actually the biggest problem
is, okay, we need this commitment, but we don't have a way to make normal
signatures.  The only transactions right now that don't use signatures, that can
put OP_RETURNs, are coinbase transactions.  So basically, if this did happen and
we're unprepared, it would be like, "Okay, I need to get OP_RETURNs in.  I need
some out-of-band way to give this to miners", which is bad, but is less bad than
Bitcoin dying completely, in that you'd need to find a way to say, "Okay, I need
to get an OP_RETURN to a miner or really anyone else that can make a
transaction".

So, what you could do is say, "Hey, I will gather 100 OP_RETURNs, txids, from my
friends, and then put that in my transaction, and then give that txid to a
miner".  So, it doesn't have to be so bad as directly going to miners, you can
sort of give it to friends.  But it is this sort of out-of-band, you know, the
normal mempool broadcast mechanism is no longer enough.  It's semi-trusted in
that it's not trusted, but it's spammable, like how do you know that this
OP_RETURN is going to give you anything?  There's no fee attached to it because
it's not a transaction, and so on.  So, that's sort of the downside.  But it
seems survivable, you know, so maybe if this happens and then for a month,
Bitcoin is in this sort of degraded mode where mempool doesn't work as normal
and you need to get these OP_RETURN commitments out first.  But then, Bitcoin
still sort of works.

I can sort of finish up, I guess, before questions, of it actually can keep
working even after you have a quantum signature scheme.  So, one of the things I
want to write a little bit more about in this is imagine there's a Winternitz
scheme or something that's got, I don't know, 16-kB signatures.  You could say
you could imagine a wallet that says, "Okay, I'm going to keep one Winternitz
output.  And I'm also going to keep a bunch of UTXOs that are just regular
P2WPKH.  And when I want to spend, I'm going to have my one big signature, but I
can also move a larger amount of different UTXOs with the small, essentially
tiny signatures".  You can also get rid of signatures completely.  You could
have an output type that was just, "Here's a hash, and if you know the preimage,
it's spendable", and then you spend it, you know, commit to the spending
conditions with this OP_RETURN thing and then spend it that way.  And then your
signatures, in theory, could be 16 bytes, because you're only relying on
preimage resistance of SHA256.  So, you can have a 16-byte preimage and then you
get the 32 at hash, with a bunch of overhead, like the 32-byte OP_RETURN as well
as the amortized size of this quantum-secure signature, this Winternitz
signature.

But it could be useful even long term with a quantum signature, because it's so
much potentially smaller.  If we have a cool quantum signature system that's a
couple of hundred bytes and everyone just uses it, then probably that's fine.
But if we are in a system where we are constrained by witness bytes and the
quantum-resistant signatures are quite large on the order of kilobytes, then it
could make sense to keep using this as well.  It gets a little complex, but now
you have this very small signature scheme that's still usable alongside a
quantum-resistant signature scheme.  So, I don't know if you guys have questions
or if that makes sense, but yeah, I want to write more about it.  It's something
that I posted about a month ago and then people have responses, and I have this
whole thread of notes and I need to post again to the mailing list.

**Mike Schmidt**: Well, I have questions, but I would be remiss if I didn't let
Jonas ask something that maybe is on his mind.

**Jonas Nick**: I actually have a couple of questions.  I think this is a
really, really interesting scheme.  So, one thing I was wondering immediately
is, so you would introduce a new, very significant data structure to Bitcoin
implementations that stores this OP_RETURN data.  So, what sort of data
structure are you envisioning?  It should be append only, right, and past
lookups?

**Tadge Dryja**: Yeah.  So, that's the other.  The part I explained, which is
just commit to txid and OP_RETURN.  The actual thing I wrote has three hashes:
one is the txid; one is this commitment proving you know the public key that
helps protect against this front running attack that I mentioned, but didn't
explain very well; and then, the third is a hash of the pubkey that is with a
different hash function, whether it's keyed or some other thing, than the pubkey
hash we use in addresses.  And that becomes sort of the key for which you're
storing this key value store.  So, yeah, the data structure, if you just do
txids, it gets pretty bad, because now you've got this giant structure that you
need very quick access to, to verify any transaction.  What you'd have instead
is you'd commit to the hash of the pubkey being used, but again, a different
hash function, so it does not look like the address.  Imagine you prepend the
word 'post-quantum', or something, and then hash.  But what that lets nodes do
is they say, "Okay, that's my entry".  If it's a key value store, if you're just
using LevelDB again, that's your additional key.

So, you say, "Okay, here's the 64-byte commitment, and here's the 32 or probably
16 is fine, but let's say it's a 32-byte key, where I'm storing it in".  And
what's nice about that is once you learn the pubkey, you can delete that.  But
it is still a problem in that people can spam arbitrary data and then you're
going to have to store that.  I think it's bad, but I think that's sort of what
we're dealing with today, in that people can make fake pubkeys and you've got to
put that in your UTXO set and you're stuck with it.  But yeah, so the idea is
this additional hash of the pubkey keys it so that it's a very quick lookup, so
that it's like, once you see a public key in the transaction, you say, "Okay,
have I seen that public key in a commitment before?" and you can very quickly
look it up if you have or not.  And also, if there are attacks where people are
trying to collide and multiple people are making different commitments claiming
to have the same pubkey hash, you do need to store all those.

But once the reveal happens, if it ever does, you can delete them all.  And you
know that, okay, there were, you know, 20 conflicting commitments to different
transactions with this one pubkey, but once I see the pubkey, I can decrypt them
all essentially and know which one is valid and only store one of them.  Or, if
that one valid one that happened was the transaction itself revealing the
pubkey, then I can delete the whole thing.  Or, the thing is, if you delete the
whole thing, then you might have to store it again if someone makes it, so you
probably want to leave a little tombstone of that key so that if someone ever
tries to make another commitment with that key, you're like, "No, that key's
already been used and there's been a commit/reveal".

So, yeah, that part's a little ugly.  I don't think in terms of scalability,
it's any worse than the existing UTXO set.  But yeah, you would introduce this
new sort of key value store.  You'd probably shove it in the same LevelDB, make
it look a lot like the UTXO set, it's got very similar properties.  So, that's
the thing there; not great, but doable.

**Jonas Nick**: Yeah, that makes sense.  I think, so since we have we were on
the topic of collision resistance versus preimage resistance, I think it relies
on collision resistance because in general, the attacker has control over the
txid because we do sort of transactions collaboratively, right?  So, you can at
least select outputs, etc.  So, it would be possible for them to produce two
messages and then if they hash to the same value then ...

**Tadge Dryja**: Well, so multisig is a whole other story with this.  Multisig
sort of becomes 1-of-m with this scheme.  Like, if you have, say, a LN channel
and you have a 2-of-2 multisig, both parties know each other's public keys.
With this scheme, it essentially becomes one event, either party can try to grab
the whole thing, which is not great.  There are ways and you could create a
system where you'd have to change the output types in Lightning, which is
totally doable with today's script, where you use pubkey hashes instead of
pubkeys.  You could do it, but at that point, you're changing things enough that
why not just introduce an actual Winternitz scheme or hash-based Lamport scheme,
or something.  But you could do that so that, let's say you're using non-taproot
LN channels that are P2WSH, and within that witness script, there's two pubkeys.
What you'd have to do instead is have two pubkey hashes within that script.  And
then you can say, "Okay, I need a signature from both of these pubkey hashes".
The question is, is it worth it?  Since you're going to have to change all the
LN software, why not change it?  Like, let's just get an actual
quantum-resistant scheme.  But you could adapt it to that.

So, this saves most coins, because most coins are in single scheme.  Or if it is
multisig, a lot of times it's pretty cooperative multisig, where if it's an
exchange or something and they have three or four keys, well, even if the
security degrades to only needing one of those three or four keys, probably it's
still okay.  Because if the alternative is all these coins are destroyed or all
these coins are stolen by a quantum attacker, then, yeah, some security
degradation and loss of utility is okay.

**Jonas Nick**: Yeah, right.  That makes sense.  And a final question, you
mentioned in the beginning that you don't think it's a great idea.  So, what
specifically did you mean?

**Tadge Dryja**: Well, I guess it's like, I don't want to advertise it.  It's
like, "Oh, everything's solved.  We don't have to work on quantum-resistant
signatures".  Or like, "There, no problem".  Because if you use this, it's a
much worse user experience.  It's like, okay, how do I get the commitment?
Also, now your transactions have got multiple steps that are probably separated
by hours.  So, it's slower.  You know, it's worse.  So, in that sense, it's bad.
It's not like, "Oh, this is going to make Bitcoin better and easier".  I hope
quantum computers never show up and we never have to use this.  But if a quantum
computer does show up, this is vastly better than, you know, the coins are
destroyed or stolen.  It's like, even if you haven't thought about this, if you
have some old coins from ten years ago in a beta pubkey hash output that you've
never used, you can use this, and it's a soft fork, and we'll probably soft fork
something like this in.  And these decade old coins are now securely movable
years after the quantum computer shows up.

So, that part is great.  But for actual usability, it's like, no, we definitely
need other stuff as well.  So, I want it to be a backup plan, not a like, "Hey,
we don't need any BIP360 or other quantum stuff.  This is it".  So, that's what
I mean by it's bad.  It's actually good, but it's like, use this as a backup,
use this when other things are broken.

**Jonas Nick**: Okay, cool, next?

**Mike Schmidt**: It seems like this would eliminate this rush for everybody to
migrate to a quantum-safe address, right?

**Tadge Dryja**: Yeah.

**Mike Schmidt**: Yeah.  So, you lose that rush, although anybody who doesn't
have a scriptpath spend, it sounds like, or if they have an ancient P2PK
address, or something like that, those folks would need to rush before this soft
fork activates, because those would become unspendable or stealable, or
whatever.

**Tadge Dryja**: Yeah, so it would be like taproot with no scriptpath, or it
doesn't even have a scriptpath; inner key, I guess, would be a problem.  So,
you'd want to encourage wallets to say, okay, either have some kind of actual
P2QRH, or something, or just have taproot with some kind of inner key and some
kind of script spend, even if the script spend is just like a different pubkey,
right?  That's totally fine, and that would make it secure with this system.
Yeah.  And then, P2PK is old enough that I'm guessing most of those will be
either stolen or destroyed, and I have a very strong hypothesis of which will
happen of those.  But anyway, those are probably mostly lost keys and not a lot
will happen.

The big one is P2PKH and P2WPKH with reused addresses.  There's a lot of coins
there, and those are vulnerable.  So, the recommendation there is just move your
keys to non-reused, you know, single-use addresses and you're good.  You can do
that today, and that has been the recommendation since day one.

**Mark Erhardt**: Yeah, you should do that today.  Blockspace is basically free
right now.  Even, especially with the last few weeks, people being able to get
transactions below minimum relay transaction fee into blocks.  This is a great
time to consolidate funds that are in reused addresses or P2PK.

**Tadge Dryja**: Yeah, and so this is probably a motivation to do that, in that
this is a scheme which, I don't know, I think hopefully we don't have to use
this, or we may end up using something like this, hopefully have years before we
have to worry about it.  But it is a kind of thing where you can activate this
after the quantum computer shows up, after you've got proof that a quantum
computer exists, and we're like, "Hey, quantum computer has stolen a couple of
thousand coins".  And then, you can activate it and say, "Okay, well, those
couple of thousand coins, that sucks, but that's what happened".  And then, it's
locked in.  And then, all those people with reused addresses, it's too late.
Either you're going to get stolen or the coins are going to be frozen, depending
on how that how that works out.  Neither are good.  And so, it's sort of like,
yeah, you should move them now.  And there's a real risk if you're worried about
quantum computers happening.

I'm personally not so worried.  I'm thinking it's very unlikely it'll happen
anytime soon.  But it's like, hey, even if it's like a 1 in 1,000 chance, that's
something worth mitigating, and that's something worth looking at.  So, yeah, if
it's possible, people who have wallets that reuse addresses, or people who have
coins that have reused addresses, now's a great time to move them, and then
given this protocol, we're pretty sure that even if you have a quantum computer,
and you just have a P2WPKH address that hasn't been reused, you're pretty much
safe.  So, that's my recommendation.  Okay, go ahead, sorry.

**Mike Schmidt**: Tadge, what's your canary in the coal mine of where this would
be like, "Oh boy, we're going to have to think about turning something like this
on"?  Would it be coins mysteriously moving and people complaining about it on
Twitter?  Is it adjacent research on quantum, where people are able to break
things that are getting close to similar to…

**Tadge Dryja**: I mean, to me, we don't have to get too much into it, but like
run Shor's algorithm at all once on any number, I'm not an expert, but I have
written...  People say, "Oh, they factor the number 15", and yeah, kind of.  If
you read the paper, the circuit they used had the numbers three and five in the
circuit in the hardware.  So, it was really more of a verification than a
factoring.  And as far as I'm aware, Shor's algorithm with the quantum Fourier
transform (QFT) and the thing that would kill ECDSA or any secp stuff, has not
been run on a physical quantum computer.  So, if that were to happen, even for a
very small modulus, or whatever, then it would be like, "Oh, it's real".  Maybe
we're still years out, but that's significant progress.

But I also in the post wrote that you can have a sort of proof of quantum
computer, where basically you just look and if there's these two opcodes, which
I think it's OP_SHA256, OP_CHECKSIG, and if any transaction has that and is
valid, that means someone hashed something and then verified a signature with
that hashed output being the pubkey.  And as far as I know, that means that
either the hash function is broken or the elliptic curve thing is broken,
because you're interpreting this 32-byte hash output as the x coordinate of an
elliptic curve point and then verifying a signature from that.  And so, that
sort of means like, "Hey, quantum computers exist".  There may be better proof
of quantum computers, but I think that's a good way to activate these kinds of
things, because then you're sure like, "Hey, a quantum computer has proven
itself".

The downside there is, well, what if it's a bad guy and they don't want to prove
themselves and they just want to steal coins, right?  It doesn't work.  But it
might be a good guy, right?  It might be someone's like, "Hey, I got the first
quantum computer and I'm this big lab at this big university, and here's a cool
proof.  We're going to just hash some random thing, get a SHA256 output, and
then find the discrete log of that point that we just hashed, and prove we have
a quantum computer that way.  So, if we do have that, then it's sort of a nice,
easy, like, "Okay, quantum computer exists", and that's consensus verifiable.
You can put that into a transaction, and then everyone in Bitcoin sees it, and
every node auto enforces, given that.  But yeah, but hopefully that's also not
what happens, because we have enough time that we're pretty sure years ahead of
time.  But these are sort of the emergency options if it does come to that.

**Mike Schmidt**: Talk a little bit about multiple inputs.  If I understand
correctly, only the first pubkey in the transaction works with the scheme, do I
have that right?

**Tadge Dryja**: Yeah, you don't need more than one, so you can do multiple
inputs and only have one commitment and one pubkey reveal, and I just set it to
the be the first one.  But you could get more complicated than this.  I think
this is like a good stepping-off point.  If we actually start writing a BIP,
then you could probably get more complicated and say, "Okay, how do we deal with
multiple inputs?"  The thing is, it's pretty brittle, in that if you make one
commitment and you're like, "Oh no, wait, I want to change my transaction", like
there's no RBF, there's no things like that, because there aren't really fees.
So, it's pretty brittle, so I just stuck with whatever is simplest.  But yeah,
right now the idea is just the first input has the commitment and the other
inputs sort of are along for the ride.

**Mike Schmidt**: I'm curious about one thing that you dropped in there.  You
said you had a strong inclination, or I forget the word you used, on whether the
community's going to burn these coins or get them stolen.

**Tadge Dryja**: Yeah, to me, I can see how there's a moral debate, but I think
in practice that freeze or destroy, or whatever you want to call, is going to
win.  Because if you actually had a quantum computer and it was actually
grabbing people's coins, let's say there was deep disagreement and there was
people saying, "No, we can't just freeze and destroy all those coins.  That's
millions of coins that'll just be disappeared", and the other side says, "No, we
have to, they're just being stolen", that's a soft fork to disable elliptic
curve signatures at that point.  So, you could say, "We're disabling elliptic
curve signatures, other than with this commit/reveal scheme", right, to keep
backwards compatibility.  That would be a soft fork.  And if there were a deep
disagreement, you would have a chain split.  And if that chain split were to
happen, I would totally side with the fork that disables ECDSA, because on the
other side, you've got millions of coins being stolen and presumably liquidated.
And on the destroy side, you've got a bunch of coins being destroyed and the
total number of coins decreasing rapidly.  So, it's just like one will be worth
so much more than the other.  I don't see how the 'let the quantum attacker
steal coins' side could really maintain being a viable coin.  I don't know,
that's just my prediction of what would happen.

**Mike Schmidt**: Makes sense.  Jonas or Murch, any other?

**Mark Erhardt**: I just had a small comment and I've been searching in the
background.  My recollection is that there is actually the Binance cold wallet
which is heavily reused.  It's one of the most reused addresses, and I think it
was looking up for trying to find the number.  But if I recall it, there's at
least 100,000 coins in there, and if not millions.  So, in the case that a
post-quantum computer arrives, I don't think that there's been statements, "Oh,
all the 50 bitcoin P2PK outputs would sort of act as an early warning sign".
Well, if someone can break any key, I think the key that I would start breaking
is significantly more valuable than 50 bitcoins!

**Tadge Dryja**: Right, yeah.  So, the real thing is we've got to bug Binance,
"Don't reuse addresses", then they don't have this problem.  But yeah, because
that would be the first attack, right?  If you're a good guy, you say, "Hey, I'm
just going to prove that the quantum computer exists and that I can break
secp256k1, and then that's great.  Some nice person showed that this is a real
threat and we have to deal with it.  But if it's a bad guy saying, "No, I'm just
going to take Binance's reused address.  They've got 500,000 coins on one key".

**Mark Erhardt**: I mean, there'd be also the question whether there's a better
game theoretic approach, where you can steal coins that might not be as easily
verified to be stolen.

**Tadge Dryja**: Oh, that would be a big mess, right?  Because then if it's
identified very quickly, you could say, "Hey, all miners", and Binance probably
knows a bunch of miners, "Hey, miners, revert this transaction and do this other
transaction instead".  It could be messy.

**Mark Erhardt**: Oh, yeah, we remember that discussion happening after, who was
hacked?  Was it Binance?  Someone was hacked and several hundred bitcoins were
stolen and they were like, "Oh, we should roll back the chain", and they started
thinking about that a day later or so.  So, more than 100 blocks had passed, and
people were like, "No, man!"

**Tadge Dryja**: Yeah, this one's even more, because it's like, "Hey, this is a
fundamental assumption of Bitcoin from day one that has now been violated".  You
have a much stronger argument.  It's not just, "I screwed up", it's, "Bitcoin
itself is broken.  We should roll back".  So, I don't know.  Best case is, try
to avoid those scenarios from happening and get people to not reuse addresses.

**Mike Schmidt**: Well, I assume the Binance executives that listen to the
Optech podcast will digest this and adjust their scheme accordingly.

**Tadge Dryja**: Yeah, because it's very low cost, right?  There's no additional
fees.  The software complexity, it's not much harder with a hierarchical wallet
to just not reuse addresses.  So, it hopefully is a pretty easy change that
could potentially save their entire…

**Mark Erhardt**: 250,000, I just found it.

**Tadge Dryja**: That seems worth it, you know?

**Mark Erhardt**: Just $27 billion right now.

**Mike Schmidt**: All right.

**Tadge Dryja**: Yeah, I'll help.  I mean, give me a very small cut and I will
totally write the software.

_OP_TXHASH variant with support for transaction sponsorship_

**Mike Schmidt**: "OP_TXHASH variant with support for transaction sponsorship".
Steven, you posted to Delving Bitcoin JIT (just-in-time) fees with TXHASH,
comparing options for sponsoring and stacking.  In it, you compare managing
transaction fees using CPFP, transaction sponsors, and a new construction based
on TXHASH that you call TXSIGHASH.  What did you come up with?

**Steven Roose**: Yeah, so that's a totally different topic.  Yeah, so this has
been one of like, while designing TXHASH together with Rearden, going back and
forth on the different design ideas, there's some obvious things that you can do
with it.  But I had never put in the actual effort and time in seeing how would
the construction actually look and how would they compare with alternative
constructions, especially with how to pay fees for existing transactions, which
currently we do with CPFP.  So, we have these anchor outputs and then people pay
fees externally by making a transaction, spending a transaction.  And there's
been an alternative proposal, called Sponsors, where you can create a
transaction that says, "I want to also include this other transaction for my
transaction to be valid", so that you can effectively add fees also for that
transaction.  With TXHASH, you can do this in an entirely different way.  And I
wanted to basically look at the constructions, how do they compare when it comes
to bytes and when it comes to interactivity to actually create those
constructions.  And then, to touch a little bit on the TXSIGHASH, it was a name
I never used before.

So, what TXHASH does is it gives you a way to pick some parts of the transaction
that you want to put in a hash.  And we already do this in Bitcoin.  When you
sign a transaction, you sign what we call a sighash, and the sighash basically
takes your transaction, hashes it, and then you sign a message over that.  But
obviously, it doesn't sign the entire transaction.  Obviously, it cannot sign
the signature, for example.  So, the sighash only signs parts of the
transaction.  And currently, we have a little bit of flexibility of what part of
the transaction that we want, but we have very limited flexibility.  So, you
have SIGHASH_ALL, SIGHASH_SINGLE, SIGHASH_NONE, which kind of lets you pick the
outputs that you want to cover in your sighash.  And then, it also has this
feature called ANYONECANPAY, which gives you a little bit of flexibility on what
you want on the input side.  But the flexibility is very limited.  You only have
these two dimensions that you can do.  And then, you pick one and you hash this
and then you sign that hash and that's your signature.

So, with TXHASH, originally it's just in opcodes where you can create such a
hash, but with full flexibility, you can basically pick anything you want from
the transaction, "I want these fields, I want these outputs, I want these
inputs", etc.  And then, this hash gets put on the stack and you can do
basically two things with this hash on the stack.  You can either compare it
with some other hash that has been predefined beforehand, and that way you can
assert certain properties of the transaction, "These properties need to be
exactly this, because they need to be exactly the same as this hash that I
created beforehand".  Or you can make a signature over this hash using the
opcode CSFS.  But when we are doing signature over hashes, that's kind of
similar like a sighash.

So, the natural evolution of TXHASH would be to create a new sighash system,
where you directly use the transaction field selector, I call it, from TXHASH to
do a signature without having to do the opcode that puts it on the stack.  And
then, the other opcode that does the signature, you could basically make it a
native sighash so that you can do directly the signatures, and then you can use
it, for example, in taproot keyspends, where then you don't have to do
scriptpaths and you don't have to create the actual script but you can directly
create a keyspend signature, provide the tx field selector that you want to use
to create the hash, and then sign that hash.  And then, you can get full
flexibility in your sighash.  You can do stuff like ANYPREVOUT (APO), which is
another sighash mode that has been proposed before, where you can have more
flexibility over the input side.  But then, you can basically have full
flexibility, like everything you want.

So, I just dubbed this thing TXSIGHASH.  I think many people who are familiar
with these protocols and how Bitcoin works would kind of understand what it
means.  It's not exactly spec'd out byte for byte, but it's using the TXHASH
construction to build a sighash alternative so that you can do keyspends and you
can maybe also use it for the OP_CHECKSIG, or something like that, in the
scriptpaths.  So, that's the TXSIGHASH construction summarized.  And then, in
this post, I kind of use this construction, because it's a little bit more fair
than having to waste the bytes for doing tapscripts, and then compare how you
could use this construction to do things like paying fees, I call it JIT, for
your transaction.  To what level of detail should I go?  I'm not really sure.

But so, the fact that CPFP, it's very flexible, right, because you just have
this empty output and you can then do whatever you want with this output.  But
it also wastes a lot of bytes because you need to create a second transaction,
spending this input, creating an empty output.  An output costs a lot of bytes,
an input costs a lot of bytes.  And then, you need to create an additional input
to actually put money in the child.  So, it's a very flexible construction, but
it uses a lot of bytes.  Then, Sponsors would be a little bit better, because
you don't need these anchor outputs anymore.  You can just create any
transaction and then a Sponsor transaction below it that just somehow, in a very
efficient way, mentions the previous transaction and says, "This transaction
also needs to be there".  So, then you can already cut a lot of the bytes used
for CPFP, you don't need to output anymore, you don't need the additional input
anymore.

But with TXSIGHASH or TXHASH, you can actually be a little bit more efficient,
because the sponsor transaction, you can actually merge it into the same
transaction that is the actual transaction you're trying to pay for.  It cuts a
few more bytes compared with Sponsors, but it also does an additional thing
where it's very easy and flexible to sponsor multiple transactions at the same
time.  Sponsors also has something like that, but you need to spend a few bytes
per each transaction that you're sponsoring.  So, it grows linear, even though
it's not very fast linear, but it's still linear.  While with TXHASH, it's just
the same cost, there's no growth with more transactions that you're paying.  So,
with TXSIGHAS, you can create signatures that only cover your inputs and
outputs.  And then, someone else that also did that, your transaction can just
be stacked into this other transaction making a single transaction.  Because all
the signatures basically only cover the inputs and the outputs, it doesn't cover
the rest of the transaction.  So then, when multiple people do that, when for
example you want to pay for multiple of your transactions, let's say three, you
can just take the three transactions into a single transaction and then add one
more input and one more output.  And then, this one covers all of the previous
ones without additional bytes.

Then, another next step to do this, so this is already a very byte-efficient way
to do paying for fees after the fact, especially if the transactions are yours,
so then you can just create the signatures yourself.  But then, it also allows
for a scheme where a third party could pay the fees for all these people in a
way where the interactivity is manageable, right?  I mean, we can do it right
now, for example with coinjoins, coinjoin rounds.  People also constructively,
collaboratively make a big transaction, but it's super-interactive because
everyone needs to sign everything from everyone else.  While with the TXSIGHASH
construction, everyone can just create a fixed set of signatures once, and then
the coordinator who puts it all together and pays the fees can basically use the
building blocks that people have sent him, make the transaction at the fee.  And
that's, I think, a very powerful construction, especially since it's
non-interactive.  I see Murch wants to raise a point.

**Mark Erhardt**: I wanted to ask back whether I properly understand something.
So, with this TXSIGHASH commitment to other transactions being already confirmed
in a block before this transaction, do the owners or senders of the original
transaction get a way of signing off on that or not?  Can anyone do it?  It
sounded for me like you needed some signature from someone, but it sounds like
anyone can attach to any other transaction, is that right?

**Steven Roose**: Yes, if they're assigned using the TXSIGHASH semantics that
only cover their inputs and outputs.

**Brandon Black**: One slight clarification, just to make sure everyone is
clear, with TXSIGHASH, it's not actually separate transactions earlier in the
block.  That's the Sponsors method.  In the Sponsors method, there are actual
whole bitcoin transactions with the transaction header, and those are required
by the Sponsor transaction.  With the TXSIGHASH method, it's just one
transaction header, and there's groups of inputs and outputs that get stacked in
there.  And then, there's the last input and output from the sponsor equivalent,
which is the payer of the fees.  But it's all one transaction that goes into the
block, is one thing.

**Mark Erhardt**: Okay.  So, maybe let me ask differently.  So, one of the
biggest concerns with the Sponsors proposal was that it basically creates
unfettered pinning attacks.  Anyone can attach fees to anything, which allows
anyone to fuck with the order of transactions, and thus make it a headache to
find out what is going to go next.  Especially if you can sponsor multiple
transactions, it becomes very, very complicated to calculate what is the highest
priority item to include in blocks next.  And I think this is also true here in
this context.  Could you clarify?

**Steven Roose**: Yeah, so one of the caveats, obviously, of this proposal or of
this idea in construction is that it significantly changes the way we look at
the mempool.  Because transactions are no longer transactions that are kind of
immutable right now, transactions are kind of stable.  Like, if a transaction is
made, it's not easy to just fiddle with it and make a different transaction
that's equally valid.  And with this proposal, if people would be using like, "I
only sign my own input and my own outputs", constructions, people could mix and
match and people could make different constructions, and it would obviously be
more vulnerable to pinning attacks and all kinds of shenanigans.  So, it would
definitely require a lot of thinking on how do we structure the mempool in ways
that is more compatible with these kind of constructions.  If you're doing only
opt-in kind of things like, "Oh, we're doing this in some kind of construction
where, in the end, I will always have control over this in some other way", then
it's kind of fine.  Like, for example, if after the fact you have a hook where
you can say, "Okay, now I can say I only use this", then it would be kind of
safe.  Maybe in constructions where you know up front that you're going to use a
certain stacker, like an external party who's going to pay your fees, maybe
there's also ways to make it more safe if you already know that you're going to
do this.

But yeah, I mean it's a different box that we open.  It's like mempool policy
becomes a different beast.  It's no longer nodes of transactions, but nodes of
things.  But I've talked about this with some people who have deeper knowledge
of mempool policy, and I was pleasantly surprised that they wouldn't think it
would be that much more crazy.  I was like, "Doesn't it break everything?"  It
doesn't necessarily break everything, even though you can create a lot of the
transactions that are kind of similar.  They still would be in the same cluster.
So, when we would finally get cluster mempool, which is, I think, a super-great
improvement to mempool design in general, they would still all be in the same
cluster, right, because they share the same inputs and outputs.  So, then you're
not creating an explosion of different transactions, they would still be in the
same cluster.  And then, just the best version, based on whatever algorithm you
would use inside your cluster, would be picked.

**Mark Erhardt**: Sorry, but, but you could have multiple transactions that
tried to bump either competing or the same transactions.  And then, depending on
what goes into blocks, that would, for example, change how much fees seem to
push for other transactions that are still left.  Or if you have multiple
competing transactions that sponsor things in different clusters, they combine
clusters.  I just don't see how this is true.  I don't know who you've talked
to, but it seems to me that exactly the issues that raise concerns with sponsors
apply here.  So, I was thinking, how about if the sender of the original
transaction that is being sponsored in some way had to sign the new transaction?
Like, yes, you can create a transaction that doesn't need to change the prior
transaction, but the signers of the prior transaction have to get their
signature in, like the signature is added into the sponsoring transaction.  That
way, you get the opt-in at the second transaction's creation.  Then I could see
how it is not problematic.  But if anyone can just attach their transaction to
the confirmation of existing transactions in the mempool, I think it is going to
make mempool completely complicated, and it creates new dimensions of pinning.

**Steven Roose**: Well, I'm not incredibly familiar with the algorithms used in
cluster mempool in the current form and shape, so I cannot comment too much.
One thing that's definitely true is it definitely covers the same ground as
transaction sponsors, but it's way more efficient and way more powerful than
transaction sponsors is.  So, if we can work around those things in the context
of transaction sponsors, obviously this scheme could be considered as a better
or a more efficient proposal, or an alternative to transaction sponsors, given
the same category of problems that need to be solved.

**Mike Schmidt**: And Steven, it's not multiple transactions, it's one, right?

**Steven Roose**: I mean, yeah, but if you can make ABC plus Sponsor, you can
also make AB plus Sponsor, you can also make AC…

**Mike Schmidt**: Right, but I think Murch made the point that...

**Mark Erhardt**: And you can make A plus B apostrophe and C as a sponsor next
to ABC being sponsored, and so forth, and it could become a very
high-dimensional problem to solve.  I think it might also fuck with TRUC
(Topologically Restricted Until Confirmation) transactions.

**Steven Roose**: I'm not sure if TRUC would still be very relevant in this
case.  I think TRUC is mostly about CPFP.  I mean, yeah, you could combine them
in different ways.  I'm not sure.

**Mark Erhardt**: Right.  But for example, TRUC appears in the context of
sibling eviction, because TRUC transactions can only have one unconfirmed parent
or unconfirmed child.  So, if a new unconfirmed child is added to an unconfirmed
parent transaction, regardless of whether they're spending the same UTXOs, they
will evict each other under TRUC paradigm.  Now, add in sponsorship, this
definitely becomes more dimensional than just two transaction packages.  Anyway,
I think we're getting a little in the weeds here.  Either of you wanted to add
anything else?

**Brandon Black**: Yeah, I had a question for Steven that I've been meaning to
ask.  Actually, I have two, sorry.  First one, hopefully, is a simple one.  Did
you analyze CPFP imagining that we had the ability of a multi-parent TRUC, or
did you analyze it just with a one-to-one when you were doing the comparison?

**Steven Roose**: I think I did, yeah.  I did.  I have it in my table.  But I
mean, CPFP is just always really bad when it comes to bytes.  Because every
parent will have an output, which is like 30, 38, 40 bytes, well, how much is
it?

**Mark Erhardt**: Yeah, it's 11 bytes with P2A.

**Steven Roose**: Oh, with P2A, okay.  Yeah, that's true.  You have now P2A.

**Mark Erhardt**: And then, the input script isn't empty, but of course you
still have the outpoint and the sequence.  So, it's 41 bytes on the input side
and 11 on the output side.  So, 52 bytes in total.

**Steven Roose**: So, you still have 52 bytes per child or parent, I'm sorry,
which you wouldn't have with either Sponsors, or I think with Sponsors, you also
have a fixed amount of bytes.  I think it's something like, depending on, I was
looking at the different constructions, because the initial constructions for
Sponsors had 32 bytes per transaction, which is obviously not super-efficient.
I think right now it has some kind of efficient way to refer to relative indexes
above yourself, and then you can hash those together in some kind of sighash,
and then it was only a handful of bytes per transaction.  And with the TXSIGHASH
approach, you would have no bytes per transaction.

**Brandon Black**: Cool.  And then, my other question was, have you looked at a
way… I remember, I think in your post, you mentioned that to do this with
TXSIGHASH, the proposers of these bundles, these sub-transactions, would have to
sign them in many ways so they can be relocated relative to other inputs.  Did
you do much analysis on what would change in the TXHASH proposal to allow it to
be signed in just one way, and there's like some kind of a way to delineate my
inputs or my outputs that could be anywhere; did you look at that at all?

**Steven Roose**: No.  I mean, so I can detail what you talked about.  So,
because if all transactions would be just one input, one output, or two input,
two outputs, it would be very easy, because you can always just sign, "This is
my input and this is my output", and it's right next to me, right?  It's at the
same index.  If I'm input five, my output is also output five.  But because not
all transactions are like that, some transactions are two input, one output,
some random mismatch of data, to solve that and to allow an external party to
combine these bundles together, you basically sign for multiple possible
locations of your output relative to your input.  So, if you have three inputs
and one output, you basically sign 100 different offsets so you can say, "My
output is at the same output plus one, plus two, plus three", and you sign a
whole bunch of these.  It creates this kind of bundle that you can then send to
the coordinator who's going to pay your fees.  And he can then, for each of the
different bundles, pick the right one so that it fits into the place.

So, what Rearden was asking is, "Is it possible to extend or make the TXHASH
construction more flexible that you wouldn't have to have multiple signatures
and you can just have one, and then somehow, in some kind of place in the
witness, the coordinator provides the index and says, "Okay, actually this guy
signed for this output so you should look there'?"  No, I haven't.  I think it
might actually be possible, yeah.  So, the answer is, I didn't look into it.
But it's actually a very good idea, because it might actually be very simple.
It might actually just plug in the number and just the signature would work, and
that would be really cool.  I did note in my text that it was a very naïve, a
very simple, simplistic stacking proposal.  It was not really the core of the
idea that I wanted to convey in that post.  So, I didn't make it more efficient,
it's very inefficient, you need to provide hundreds of signatures and it's only
somehow flexible.  But it's definitely a design space that has a lot of
potential if TXSIGHASH would be a thing and if stacking would be a thing that
people want to do.

_Bitcoin Core #32540_

**Mike Schmidt**: Moving to the notable code and documentation changes this
week, we have Bitcoin Core #32540, which adds a REST endpoint, or function, to
fetch all of the spent transaction outputs in a given block.  So, software or
services that provide indexes on that sort of data, for example, they use that
data and they get that information from Bitcoin Core currently.  And there are
ways to get that data from Bitcoin Core currently from another REST endpoint.
But that REST endpoint, all of the data is converted to JSON, so the performance
is relatively slow.  So, one of the developers working on those indexing
services actually opened up this PR in which he added a new endpoint that
supports the data coming back not only in JSON, but also in binary and hex
formats as well.  And I think he did some data that he put into the PR and noted
that this new endpoint, in binary format, is about 70 times faster than the
existing REST endpoint that uses JSON.  The new endpoint is named spenttxouts,
and the existing endpoint that I was referencing is just the block endpoint.
And that, to my knowledge, still remains.

_Bitcoin Core #32638_

Bitcoin Core #32638.  This PR adds a check in Bitcoin Core that when Core is
reading blocks off of the disks, it actually requires that the block hash from
the disk matches the expected block hash.  So, you need to actually provide the
block hash yourself.  And now, there will be a check that when I read this off
the disk, it actually does match that block hash that you expected it to be,
which helps prevent failures caused by corrupted disk or data failures.  I don't
know if you have anything to add to that, Murch.

_Bitcoin Core #32819 and #32530_

Bitcoin Core #32819 and Bitcoin Core #32530.  The #32819 is actually just the
release note for #32530, and #32530 adds a hard limit to -maxmempool, and also
to -dbcache, those startup parameters.  Specifically on 32-bit operating
systems, there are two hard limits placed on them.  For -maxmempool, it's
limited to 500 MB on 32-bit systems, and -dbcache is limited to 1 GB on 32-bit
systems.  The risk here was that if a user was providing that startup option and
chose a limit that was too large, either of those values being too large could
potentially run into an out-of-memory error at some unknown point after starting
the node.  So, that's obviously undesirable, and some sort of limit would help
mitigate that.  Although it wasn't clear to me and I'm not sure, Murch, if
you're familiar with why these exact values were chosen.

**Mark Erhardt**: I'm not familiar with why these exact values were chosen.
With the 32-bit system being limited to using 4 GB of RAM, if you even set the
maximum of both of these, that would only amount to 1.5 GB and leaves enough for
operating system and some other processes to run.  So, I think that would make
sense as a limit.  I think, well, the mempool is usually limited to 300 MB, so
allowing up to 500 is a slight increase, but nothing too major.  And the
-dbcache is, of course, much more relevant to trying to catch up a node to the
chain tip.  The -dbcache is used to store the UTXO, so it needs to be read
quickly during synchronization.  So, having 1 GB there might be a significant
improvement over the default value of 500 MB, so allowing a bigger value there
makes more sense.  That's all I have.

_LDK #3618_

**Mike Schmidt**: Last PR this week, LDK #3618, which builds towards LDK's async
payment capabilities, implementing the recipient side of LDK's static invoice
server protocol.  So, sending bitcoin to someone offline isn't an issue, we all
do that; but with Lightning, sending to someone who is offline requires the
third party due to Lightning's interactivity requirements, thus the idea of
async payments in Lightning.  And with this particular PR, there was a note, "As
part of being an async recipient, we need to interactively build an offer and
static invoice with an always-online node that will serve static invoices on our
behalf in response to invoice requests from payers".  Later in the PR, they also
went on to say, "While users could build this invoice manually, the plan is for
LDK to automatically build it for them using onion messages.  Here", in this PR,
"we implement the client side of the linked protocol".  And the linked protocol
that was referenced in that description is actually a Google document outlining
LDK static invoice server flows.  So, they've documented this flow for how to
generate these static invoices and how to have a client-server interactivity for
that, and they're implementing the client side of that now.  All of this to roll
into their async payment capabilities, tracking issue #2298 on the LDK repo.

So, that's it, Murch, for this week.  I think we can wrap up.  We'll just thank
all of our guests this week, as we had many, and thank you for doing multiple
recording sessions with me, Murch, and for everyone for listening.  Cheers.

{% include references.md %}
