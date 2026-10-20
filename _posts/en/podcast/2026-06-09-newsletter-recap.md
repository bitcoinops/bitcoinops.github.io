---
title: 'Bitcoin Optech Newsletter #408 Recap Podcast'
permalink: /en/podcast/2026/06/09/
reference: /en/newsletters/2026/06/05/
name: 2026-06-09-recap
slug: 2026-06-09-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Pyth and Daniel Roberts (Ademan) to discuss [Newsletter #408]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-5-10/425882889-44100-2-4d68ab3e50765.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #408 Recap.  This
week, we have a couple of news items, one that is covering post-quantum
exploration for BIP324 encrypted transport, and we have a second one that is
talking about standardizing QR-based signing for miniscript wallets.  And then,
we have our monthly segment on Changing consensus, which is always a beefy one
recently.  This month, we have a CTV-only vault proof of concept; we have a
discussion on post-quantum Lightning; there is a post about quantum attack game
theory; and we have a discussion of BIP54 and 64-byte transactions.  We have the
Core Lightning (CLN) release that we'll get into, and then we have our Notable
code and documentation changes.  This week, Murch, Gustavo and I are joined by
two guests.  Pyth, you want to introduce yourself?

**Pyth**: Yeah, I'm Pyth, I'm working at Wizardsardine on Liana Wallet.

**Mike Schmidt**: Awesome.  And Ademan.

**Daniel Roberts**: Hi, I'm Ademan, or you can call me Dan, and I've been working
on a number of LNHANCE-related proof of concepts for Spiral and for OpenSats,
one of which is the vault today.

_Discussion of QR signing payloads for miniscript wallets_

**Mike Schmidt**: Awesome.  Thank you both for joining us.  We're going to go a
little bit out of order for listeners in deference to our guests' time.  So,
we'll take the Pyth News item, which is, "QR signing payloads for miniscript
wallets".  Pyth, you posted to Delving Bitcoin talking about a proposal for a
standard for the different data payloads that might be exchanged between wallet
coordinators when you're doing air-gapped signing over QR codes, specifically
when there are miniscript-based spend policies involved.  Maybe you want to get
a little bit into the motivation before we get into what you're actually
proposing here?  Why are the current QR code flows that listeners may be
familiar with insufficient in some situations?

**Pyth**: Yeah.  So, first, maybe for those that don't know what is miniscript,
it's a higher-level language that permits wallet developers to build complex
Bitcoin Scripts.  So, one thing that is introduced by miniscript is that we can
do custom scripts.  And so, when you do a custom script, you need to explain to
the signing device how to generate the script and the address.  Before
miniscript, you don't have to do that, because all the scripts were opcoded in
the signing device.  And now, because it is custom, you need to add some
communication.

**Mike Schmidt**: And then, what is the complication then on the QR or air-gapped
signing workflow as a result of that?

**Pyth**: The main issue is nobody not yet digging into this and everyone waiting
for someone else, I'd say, to do it.  So, right now on Liana, for instance, we
support some air-gapped signer, like Krux or COLDCARD, but only by SD card,
because there is not yet some standard and we do not yet want to implement
something before there is some kind of consensus.

**Mike Schmidt**: Okay, so no one started the standard yet.  So, this is the
first steps towards that, or do some of the vendors have some vendor-specific
ways of doing this?

**Pyth**: So, some have some vendor-specific way, but there is always something
missing to have a good UX.  And it works, but with edge case.  Like, for
instance, on COLDCARD, you can just send the bare descriptor, but you will be
able to register only one descriptor.  So, that means if, with the same signing
device you want to interact with two different wallets, you will have to remove
your descriptor every time, because there is also no way to say to the signing
device, when you send a PSBT, to which descriptor you need to use.  So, it will
just pick the first one.

**Mike Schmidt**: Maybe you can get a little bit into the payload types.  And I
guess you can maybe tie it into sort of a workflow and walk us through the
different chunks of data that you're describing and proposing?

**Pyth**: Yeah.  So, the first interaction you need to have is when you create
your wallet policy.  So, you need to parse xpubs between the signing device and
the wallet.  So, right now, I think maybe some device can send, but only one
xpub.  But it's pretty bad from a UX point of view, especially when you will
have multisig and when you need to select your account.  So, if you want to
select the account, the user needs to set in the signing device the account he
wants to send, and it's not something that is intuitive.  But if we add a new
payload for request, we can request a batch and we can show on the wallet and
let the user select one.  The next payload is for registering the descriptor on
the signing device.  So, we say registering, but it's more verifying your wallet
policy to verify the semantic, let's say.

**Mike Schmidt**: So, is it just strictly verification or is it storing that in
some capacity, in the way that you're thinking about?

**Pyth**: So, it will depend between devices.  So, right now, almost all devices
store, but Ledger.  Ledger is completely stateless.  And so, what Ledger do,
they generate a proof of registration.  But, let's say, they sign the descriptor
and the wallet needs to store this signature and you need to parse a proof every
time you need to sign a PSBT.

**Mike Schmidt**: Okay, so now we've retrieved some xpubs, we've registered our
descriptor, what's next?

**Pyth**: Next is signing.  So, as I was saying previously, for signing, you need
to say with which descriptor you want to sign.  But there can also be some future
case where you want to spend several inputs that belong to several wallets, but
that can be signed by the same signer.  So, in this case, we will need a way to
say, "You need to check with this descriptor and this descriptor", and you will
need to map.

**Mike Schmidt**: And then I think there was another one, right?  Was it
verifying addresses, I think?

**Pyth**: Yeah, there is another one for verifying addresses, and where you need
to parse also the descriptor and the index.  So, right now, I think Spectre
device accepts the index, but not the descriptor.  And yeah, I remember it does
not work well, or there is something.  And yeah, that's that for payload.

**Mike Schmidt**: And then what's feedback been so far?  I can imagine with
people, some folks already doing something like this, and everybody maybe having
their own vision for what it might look like.  Have you gotten in contact with
some of these other providers and gotten feedback?

**Pyth**: Yeah, not from many signing devices, mainly from Krux and Kern, because
it's the same developer working on those.  I got some feedback off wallet
developers, but not yet from other signing devices.

**Mike Schmidt**: Well, Murch has a question, but hopefully being on this show
and being in the newsletter, hopefully some of those other developers who
haven't provided feedback now will be interested by this and want to provide some
feedback.  Yeah, Murch?

**Mark Erhardt**: Yeah, Pyth, I seem to dimly remember that there was another
hardware wallet, I think, that introduced a multi-QR-code data exchange format.
I think it might have been COLDCARD or SeedSigner.

**Mike Schmidt**: BBQr?

**Mark Erhardt**: BBQr, yes, that was it.  Is that COLDCARD?

**Pyth**: Yeah, BBQr is COLDCARD.

**Mark Erhardt**: Right.  So, I was wondering, you also make use of multiple QR
codes.  Is this similar to BBQr or is this different?  If so, could you maybe
delineate a little bit?

**Pyth**: I'd say it's a different level.  BBQr, it's about the encoding of the
payload.  So, it's how you will encode and chunk in several QR codes.  What I am
interested to talk first is about what we put into the QR code.  Because right
now, there is two main, let's say, transports for QR codes, BBQr and UR.

**Mark Erhardt**: I see.  So, the BBQr scheme would be a way of encoding the
information after you decided what the payload is.  You are now talking about
what data needs to be transferred for different tasks that you want to achieve
between a signer and a wallet device for miniscript.  And you might then actually
use BBQr under the hood if you know that the hardware signer and the wallet
coordinator both support it.

**Pyth**: Yeah.  I think, let's say, the transport is almost already implemented
in most languages, so that's the easy part.  And this can be, like,
device-specific.  But we need to agree on what we put in the message.

**Mark Erhardt**: I see.  Thank you.

**Mike Schmidt**: Pyth, anything that we haven't covered here?

**Pyth**: I think we got everything.

**Mike Schmidt**: Okay.  So, I guess, listeners, if you work on anything even
tangentially related to this, check out the post by Pyth and provide some
feedback.  Otherwise, I assume it would move along as is.  So, feedback now is
cheaper than feedback later.  Any other calls to action, Pyth?

**Pyth**: Yeah, if you have some interest, feedback.

**Mike Schmidt**: Well, thanks for joining us.  I think we can wrap up that item.
You're free to drop, Pyth, and we appreciate your time.

**Pyth**: Thanks for having me.

_CTV-only vault proof of concept_

**Mike Schmidt**: We're going to jump to the Changing consensus segment, a little
bit out of order, going to, "CTV-only vault proof of concept".  This is pretty
cool.  Ademan, you announced the 0.1.0 release of MCCV, More Complicated CTV
Vault, which is a vault implementation using only CTV (CHECKTEMPLATEVERIFY).  And
I think we referenced in the newsletter, I think there was a simple vault, which
was maybe James, that we had covered previously.  Maybe just to take a step back,
how would you define a vault, and then we can get into why this proof of concept
is different from simple vault or the OP_VAULT opcode, etc.

**Daniel Roberts**: Sure.  So, I think the most important, like you said, there's
kind of multiple definitions floating around, but the most important attribute,
in my opinion, is that if you have your keys compromised and someone begins to
access your funds onchain, you have an ability to claw that back and to react to
that unauthorized access.  And so, really, all this was trying to do was expand
on the simple vault, and see how close to more of an OP_VAULT or a CCV
(CHECKCONTRACTVERIFY) vault we could get here without these much, much more
expressive opcodes.

**Mike Schmidt**: Okay.  Do you want to walk us through maybe an overview of the
construction or something that might be helpful for us to grab onto in terms of
how you approach this?

**Daniel Roberts**: Yeah, sure.  Do you think it's helpful to just refresh on
CTV?

**Mike Schmidt**: Please, yeah, good idea.

**Daniel Roberts**: New or intentionally hiding from the covenant discussions?

**Mike Schmidt**: Or both!

**Daniel Roberts**: Yeah.  But yeah, so CTV is an opcode that lets you specify in
script for your spending conditions a hash which commits to the shape of the
spending transaction.  So, that shape is essentially the entire transaction
without the prevouts.  And I don't actually know if the entire motivation is
because of this, but CTV cannot commit to those prevouts.  It's actually a little
bit of historical interest for me, like why that was done, whether it was only an
accident of implementation that it ended up this way.  But It doesn't commit to
the prevouts, but it does commit to the transaction version, locktime, number of
inputs, input sequences, input scriptSigs, all of the outputs.  And so, with
that, you can define basically what the transaction looks like that spends a
particular output.  And now that we have taproot, we have the ability to really
efficiently have many, many different optional spending conditions.  So, we can
say this output can be spent with this transaction or that transaction or
another, and it ends up being log base 2 onchain.

So, with that, you actually have a building block for kind of a state machine.
So, you have your UTXOs, which are your states, and your spending conditions and
the transactions that they commit to as transitions to different states.  So, to
really simplify the vault, this glosses over and flat-out ignores a bunch of
details.  If you imagine you have three states and this represents your vault,
you've got three outputs, or three potential outputs, I should say, because these
are potential states.  You have A, which has a single output of 1 bitcoin; you
have state B, which has 2 bitcoin; and you have state C, which has 3 bitcoin.
So, if you have an output of the correct type that fits that, you're in that
particular state.  So, if you create an output of state A with 1 bitcoin, you can
then transition to state B with 2 bitcoin in the vault.  And I realize now that
this is pretty tough without a visual.  But using CTV, you can ensure that the
next transaction has an output with 2 bitcoin in it.  And similarly, you can go
from B to C by spending the output from B and creating a new output which has a
3-bitcoin output.

Withdrawals work very similarly going the other way.  You just are using CTV to
enforce that the next transaction has a vault output and a withdrawal output.
And so, the vault output carries the balance, the remainder of what's in the
vault, and the withdrawal output is a timelocked withdrawal that can be spent
with a hotkey after a timelock.  And so, you can imagine the state machine, you
can go A to B to C to B to A or whatever, and you're just adding and removing
bitcoin from the vault and all that.

The wrinkle in all this is that you can't actually have cycles in CTV.  You can't
go from A to B back to A, because you need to be able to describe the outputs of
A completely in order to have a CTV hash of it.  So, what you actually have to do
to get around this is you basically duplicate the entire state machine multiple
times.  And so, instead of going from A to B back to A, you're going A0 to B1,
and then you go back to A by going to A2, which is a third copy of these states.
And that lets you get a finite but many vault operations, deposits, and
withdrawals.  You can kind of think of it like unrolling the loop, I guess,
manually.  Hopefully, that was coherent.

**Mike Schmidt**: You did mention that it would be nice to have a visual.  I know
in the repo here, in the LNHANCE-Expedition/mccv, there is this docs/diagrams,
and I see some visuals here that if people are curious, they can maybe track
there as well.  Although I must say, they all are also complicated diagrams.

**Daniel Roberts**: Sorry!

**Mike Schmidt**: I'm sorry if I interrupted, if you had more to outline.

**Daniel Roberts**: No, I think I covered the most important parts.

**Mike Schmidt**: Okay.  Maybe you could talk a little bit about, since there's
some folks working on OP_TEMPLATEHASH, how, if at all, does what you've done here
differ substantively from CTV to TEMPLATEHASH?

**Daniel Roberts**: Sure.  I mean, for the purposes of MCCV, CTV and French CTV,
you can swap them.  So, it's compatible with both of them.  The important
attribute is that it commits to the outputs and the number of inputs on the next
transaction, which both of them do.

**Mike Schmidt**: I think you flagged in your write-up something about the way
the proof of concept was designed.  There's a fee-paying consideration; the hot
wallet keys and the fee-paying keys are related.  Can you talk about that?

**Daniel Roberts**: Yeah.  So, just the way this first release was built, even
the cold keys, they're all derived from the same master xpriv.  And on top of
that, the hot wallet and the vault hotkeys are the same.  So, if you had your
hotkeys compromised, then an attacker could not only take or initiate a
withdrawal from your vault, but they could also spend all of your coins in your
hot wallet to prevent you from paying fees to stop them.  But that's just a quirk
of how I implemented it.  It was simpler to do it that way, but there's no reason
why you couldn't just import an existing descriptor wallet to you as your
fee-paying wallet, and that's actually what the watchtower version, that I'm
working on now, does.

**Mike Schmidt**: How many of these pre-computed transactions are we talking
about?

**Daniel Roberts**: Well, that's one of the pieces of feedback I want to know
from people is, how many operations do we really need?  Sorry, it's behind me,
but I considered like 1,000 operations to be pretty good.  And going from 1
million bitcoin to 1 bitcoin in million bitcoin increments to be a pretty
decent-sized vault for people like me, anyway.  So, with that, you are talking
about millions of states.  And it can take tens of minutes to compute this.  And
right now, the proof of concept doesn't cache that, but that is trivial to do.
So, it definitely is computationally-intensive.  And that was actually the
motivation for me actually implementing this, was to see, can we actually get
useful-sized vaults out of pre-computing every single state?  And I think we do.

**Mark Erhardt**: Okay, so it takes very long to compute all of it because you
have to enumerate all possible paths.  But then, you have this huge tree that you
can walk down in order to transition between the states.  So, the way I
understand it is you have a cold wallet, it has a set of keys that are managed
differently than your hot wallet.  And when you want to take funds out of your
vault, you move it out of the cold vault, a highly secure key setup, into a
staging ground that is controlled by the hot wallet, that can then split off some
funds to send them back somewhere else, whereas most of the funds go back to the
vault.  However, if something goes wrong at the hot wallet stage, the cold wallet
can reclaim the funds.  Am I, at a high level, getting that about right?

**Daniel Roberts**: Yeah, definitely.  The only thing I'd say is the cold keys
are not in 100% control.  You don't need them to move it into this staging area.
But they always have total control over the coins in the vault.  The internal key
is always one of the cold keys.

**Mark Erhardt**: Okay.  So, I think one of the pushbacks on vaults in general is
vaults turn a single key-management problem into two key-management problems.
So, could you motivate how this improves the security, this reactive security
that vaults provide?  Why is this a big improvement over the previous situation,
where you might just have a cold wallet and a spending wallet, and you also have
two key-management problems, but not the script overhead, the complication, the
pre-calculation of an enormous tree?

**Daniel Roberts**: Yeah, well, whether that trade-off makes sense is definitely
a valid question and something I want feedback on.  But I think it improves the
situation by letting you have access to your cold funds or at least colder funds.
So, you can have these funds that are controlled after a delay by your hotkeys
that, you know, they're more secure by virtue of the ability to reactively sweep
them to the cold keys only.  So, you're able to have some access to these funds
without -- you can have your cold keys even deeper cold, basically, than you would
normally, because that would be just impractical and painful if you ever needed
to access them.

**Mark Erhardt**: Okay, so specifically, I think now I can correct myself, you
would have access from your hot wallet to move funds into a staging area if they
remain there for a certain time.  You can distribute them with your hot wallet
keys.  If not, if you previously react with your vault keys, you can then move
them into a third wallet, which is the cold wallet instead.  Okay then.  So,
basically, you protect against your hot keys being breached, which might be your
mobile device or something.  And you trade off a delay in making larger spends
for having some time to react and having the ability to go maybe to a second set
of keys that is warm instead of hot, and use that to reclaim the funds and move
them to cold storage.  I think that's a better description.  Okay.  Sorry, did
you want to correct me?

**Daniel Roberts**: No, I was going to concur.  That was great.

**Mark Erhardt**: Okay, cool, awesome.  So, with the pre-computation of the
entire tree, you of course get a huge complexity blow-up, and you have only the
flexibility the designer considered in advance.  So, if you compare this, what is
your goal here with the MCCV?  Is this your baseline that you want to improve
upon?  Is this a product that you want to ship?  What are you intending with
this?

**Daniel Roberts**: Well, really, it just started life as an experiment, to be
perfectly honest.  I wanted to see how far we could push CTV, basically, towards
this direction of a useful vault for kind of the scenario you described.  So, I
don't have any productization plans, especially since the covenant wars rage on.
But there are a number of obvious, and I think a couple of interesting,
improvements that could make it maybe a more interesting trade-off.

**Mark Erhardt**: And with that, you mean additional opcodes that are added to
the package, or changes to the design of CTV/TEMPLATEHASH, or improvements in the
setup of the vault itself?

**Daniel Roberts**: Sure.  So, I guess I wouldn't make any assumptions about what
covenant proposals get activated or modified in any particular way.  So, really,
my goal is to just live within CTV or TEMPLATEHASH and CSFS (CHECKSIGFROMSTACK).
So, the modifications I'm describing are really to the MCCV, and their
quality-of-life stuff, like using CSFS to have a delegated recovery key, so like
a watchtower, you could give them a key that they can use to sweep funds without
the ability to also initiate withdrawals.  So, that way, the worst they can do is
grief you, and hopefully they're a reputable company.

**Mark Erhardt**: Okay, sorry, I distracted myself by clicking the wrong button.
So, your MCCV only uses CTV, right?

**Daniel Roberts**: Currently, yes.

**Mark Erhardt**: And TEMPLATEHASH is currently, well, there's a tentative start
of TEMPLATEHASH being proposed as part of a bundle called (Re)bindable
Transactions, which also includes CSFS.  CSFS notably lets you build a package
that you want to sign in script and then sign it in your script arguments, and
then execute that signature check on the stack.  So, with that, you could get
significantly more flexibility in your tree.  You said there would be some
obvious quality-of-life improvements.  Do you have an order of magnitude, or an
outlook for us how much better it would get, with a creative use of CSFS?

**Daniel Roberts**: Well, if you want to get really creative, one of the ideas
that I've been contemplating is, with CSFS, you can actually create cycles in
your state machine now, with some caveats that I think are important.  But so,
before I mentioned how you have to basically unroll all of the states multiple
times to be able to do multiple operations.  With CSFS, you could have state A,
B, C, and then using CTV and CSFS and a deleted key, you can then create a
transition from C back to B, withdrawing one coin, and never need to unroll this
loop.

**Mark Erhardt**: So, instead of enumerating all possible paths through your
state machine, you could have an actual state machine where you can transition
back and forth between the states like an automat?

**Daniel Roberts**: Yes, exactly.  And the caveats are, one, I really just don't
like deleted key covenants, I just don't.  I think that for people like me,
really trusting that you've actually deleted the key, it is tough.  And also, you
now have critical backup information that you have to have, otherwise it stops
functioning.  So, I'm not a big fan of that.  And the other thing is, all these
states are still going to have their hotkeys and all that baked into them.  So,
you're going to end up with key reuse as an inherent property of this design.
But I still think it's interesting because, man, you know, you take millions and
turn it into hundreds of states, that's awesome.  So, another trade-off worth
exploring.

**Mark Erhardt**: As you're referencing the very coldly ongoing covenant wars, I
wanted to also ask, OP_VAULT was retracted or withdrawn in favor of OP_CCV.  Now,
CCV has been designed very much with the vault use case in mind.  If you actually
got CCV instead of CTV, would that make your endeavor much easier?

**Daniel Roberts**: Yeah, in the sense that I'd probably scrap most of what I
have here.  In my opinion, CCV favors an entirely different design.  So, this,
like I said, was kind of designed to push the limits of what we can get without
more powerful covenants.

**Mark Erhardt**: Okay.  That's all I have at the moment.

**Mike Schmidt**: Ademan, calls to action for listeners.  What do you want people
to do?

**Daniel Roberts**: I would love for people to actually check it out, check out
the protocol document, and just try it out on whatever your test machine is, tell
me at what point you get angry at it for how long it's taking to enumerate all
the states, and try and break it as well.  But go easy on the code.  It is a
proof of concept, and there's a number of things that are on my list to fix
eventually.  But it was time for a release.

**Mike Schmidt**: All right, listeners, check it out, tinker, provide feedback if
you are vault-curious.  Ademan, thanks for joining us.

**Daniel Roberts**: Thanks for having me.

_A post-quantum path for BIP324_

**Mike Schmidt**: We're going to pop back up, for listeners, back to the News
section, and this will put us at three quantum items coming up in a row.  First
one from the News section, "A post-quantum path for BIP324".  Laolu, or
roasbeef, posted to the Bitcoin-Dev mailing list about potential upgrades that
could be made to BIP324.  That's the encrypted transport when nodes are
communicating with one another.  And the idea here is that it could be a toe in
the water for, "Bitcoin to have post-quantum cryptography at the BIP324
communication layer, which is not consensus.  Obviously, there's a whole genre of
discussion about consensus related changes for the Bitcoin protocol.  And so,
what's actually vulnerable in BIP324 is that there's an Elliptic Curve
Diffie-Hellman (ECDH) as the key exchange for both parties when they're
communicating; there's this initial handshake.  And at that point, if there's a
powerful enough quantum computer, that could break that, meaning they could
intercept and decrypt that handshake, have the shared secret, and then tamper or
monitor the communications between those nodes.

So, roasbeef is looking at why it might make sense to consider upgrading and how.
He has two different design questions before he wants to maybe author a formal
BIP.  One is which key encapsulation mechanism to use, which is the method for
two parties to agree on a secret key, which would essentially replace the
elliptic curve version.  And he talks about there's a hybrid approach using the
existing method, as well as with a new post quantum primitive, which is ML-KEM,
(Module-Lattice-based KEM).  Or he's also floated the idea of a pure
post-quantum approach.  So, it wouldn't be hybrid, it would just be that ML-KEM
alone.  And then, the second topic that he brings up before wanting to
potentially author a BIP is whether this handshake, this agreeing of the shared
secret, should still look like random bytes or not, which is indistinguishable
from random traffic now with BIP324's current design.

So, he outlines two approaches that could maintain that within post quantum.  One
is using that same BIP324 existing handshake to open up a classical channel and
then negotiate a post-quantum communication channel through it; and then, this
second method that he outlines, which is this Outer Encrypts Inner Nested
Combiner (OEINC).  And then, you wrap one of the KEMs inside of another, and
essentially does the post-quantum communication channel in a single step.

So, he's looking for feedback on these two specific points before he might
potentially, it sounds like, author a BIP.  Murch, Gustavo, any thoughts on that?

**Mark Erhardt**: Yeah, a little.  So, 324 encrypts the traffic between nodes.
So, this is stuff that doesn't happen on the blockchain.  This is only P2P
traffic.  As such, the challenges of moving this to post quantum are very
different.  We are not as space-constrained; we are more flexible, because we can
just introduce a new version of the P2P protocol, and whoever speaks it can
upgrade to that.  It doesn't require any consensus changes in the sense that
blockchain use requires consensus.  Of course, it's good that the P2P traffic is
compatible with each other, and you wouldn't recklessly just turn off the old P2P
traffic support once this gets introduced, but it's a very different beast than
the rest of the quantum debate that we've been talking a lot about here recently.

So, with that in mind, currently the v2 transport is encrypted, but it is not
authenticated.  So, the encryption is still man-in-the-middle-able by a man in
the middle attacker.  And I think that moving it to PQ would probably just
marginally increase the cost of someone trying to listen to this.  Presumably,
the network traffic is valuable enough that a passive observer might listen in
and try to glean off information, but I'm not sure that the network traffic is so
valuable that attackers would go around to try to hack the encryption of the
network traffic over just man-in-the-middling.  If they took an active stance in
trying to get the information, they should insert themselves in the connection
being created, rather than in trying to attack the encryption.

So both, I would say, it would be much easier to roll out support for a
post-quantum encryption on the P2P traffic, because it's more flexible and we are
not as space-constrained.  These keys can be bigger without much issue.  Yeah, it
shouldn't be an issue.  We can easily send more kilobytes or something on the net
versus writing them into the blockchain.  And then, overall, I'm not sure whether
this is the most pressing issue in the post-quantum debate, because I think
man-in-the-middling is much easier than decrypting.

_Post-quantum Lightning discussion_

**Mike Schmidt**: We'll jump down to the Changing consensus and pick up where we
left off, which is another post-quantum post and another one by roasbeef,
"Post-quantum Lightning, layer by layer".  This was a post to Delving Bitcoin
from roasbeef, and he gave a detailed breakdown of what a post-quantum LN might
look like, and he covers a few different layers or components that might need
work.  I guess his starting insight is basically that any BOLT that uses elliptic
curve cryptography needs changes, and that involves most of them.  Right now,
Lightning uses one key to essentially do many jobs.  So, that's like signing
invoices, setting up encrypted connections, signing gossip announcements, and
other things.  But in the post-quantum world, no single replacement solution is
available that can do all that.  And so, he's looking at what is the best
post-quantum cryptography for each of those.

We won't get into super-detail here, but for the transport encryption, he's again
recommending ML-KEM for the key exchange and then that transport.  And then, for
offchain signatures, which would include things like gossip or invoices, he's
identified ML-DSA as a solution.  And then, for onchain signatures or the channel
scripts, SLH-DSA.  So, that would mean that a node would actually need to
advertise multiple keys for these different capabilities, whereas right now, as I
mentioned, the single node key covers all of that.  There's some numbers here in
terms of how much bigger everything gets in terms of sizes.  I won't jump into
that.  Folks can look at that as sort of a homework assignment.

But there's also this interesting gossip bandwidth problem that is brought up,
and that is that SLH-DSA has this SLH-DSA-128-24 that has smaller signatures but
has this hard cap of 16 million signatures per key.  So, a routing node that has,
for example, 1,000 channels every 10 minutes, channel updates, they would exhaust
that limit in four months.  And so, I guess there's some considerations, and I
think we've talked with Jonas Nick about this with some of the post-quantum stuff
within the protocol, there's a consideration for reuse.  Now, that's a similar
constraint in Lightning in terms of how many times you can sign with a key
without degrading its security.

He talks about payment hashes.  So, RIPEMD moving to SHA256.  He talks about how
PLTs might not survive this transition.  And I think his overall conclusion was
running ECC in parallel with some of the post-quantum schemes as sort of a hybrid
and potentially pragmatic path to have both of those.  You have the classical
security as a fallback if any of these newer post-quantum schemes have issues,
and give them time to mature as well.  Murch, Gustavo, any feedback?  I'm glad
someone's looking at this.  I mean, there's a ton of discussion about protocol,
Bitcoin protocol, post-quantum and onchain work, and something will happen with
Lightning.  So, I'm glad he started this discussion.

_Quantum attack game theory_

And our final quantum item from our monthly segment is, "Quantum attack game
theory".  This is a Jameson Lopp post to Delving, which essentially just links to
his blog post talking about game theory of a quantum attack on Bitcoin.  I mean,
I think it's interesting for folks to read it in full.  Contrary to the rest of
our usual news items, it's not super-technical.  But I think his core point is
that a quantum attacker might behave different from other bitcoin holders, since
there's no proof-of-work investment and there's no capital at risk.  Obviously,
it's a little bit different in that there's obviously quantum computers involved,
but there's no real incentive to preserve the network's value.

So, he outlines, I think, five different rational self-interested attacks.  He
calls them the market dump, slow bleed, big short, short-range attacks, appeal to
legal authorities.  And then, he also outlines these irrational or malicious
attacks.  These are things like confirmation delay griefing, anyone-can-spend
chaos, mempool and block space chaos, screwing with second layers, 51% attacks.
And then, this idea of pretending that they're Satoshi, or the Satoshi Psyop, I
think he calls it.  And so, I think it's interesting.  It's not the genre of
thing we usually cover, but I do think it's sort of encapsulated or thinking
about the big picture as we zoom in and talk about the small picture of a lot of
this quantum stuff.

_BIP54 64-byte transactions and potential legitimate uses_

And we have, "BIP54: 64-byte transactions and potential legitimate uses".  This
is a Jeremy Rubin Bitcoin-Dev mailing list post, but there's some tangential
posts that seem to be related to it.  I see even some discussion this morning
that I'm looking at, "Prohibit merkle internal node preimages that encode minimal
64-byte transactions", on the mailing list.  And I think there was also a
call-to-action post that Jeremy posted, around how people are using SPV now for
different protocols or wallet tech.  And so, he's clearly thinking about these
things.  In this post that we covered, he's essentially making a few points.  One
is one that I think some of the BIP54 authors, I guess Antoine namely, agreed
with, which was that maybe some clarification in BIP54, throughout its text, that
BIP54 is a ban on transactions whose witness-stripped serialized size is 64
bytes, not their full size.  So, you could actually have a transaction that's
over a megabyte in total, but would still be banned if the non-witness portion is
64 bytes.  So, I think a clarification on BIP54 was sort of agreed to there.

**Mark Erhardt**: Should we maybe just explain stripped transaction size again in
the context of where it comes from?  Yeah?  Okay.  So, when segwit was
introduced, the witness data obviously was not known to existing nodes.  And
therefore, the new transaction format was introduced in a manner that it would
look invalid to existing nodes.  This specifically happens by the two fields in
the transaction header marker and flag, which appear in the position of the input
counter for the legacy format.  The input counter in Bitcoin transactions always
has to be at least 1 and the marker is 0.  So, a transaction with 0 inputs looks
invalid to existing transactions, and it'll throw away the transaction for being
invalid.  So, the segwit transactions will never be processed by non-segwit
nodes.  And in order for the non-segwit nodes to understand though what is going
on on the network, they needed a version of the transaction that they can
consume.  And in order to be able to consume the transaction, they needed to know
the outcome of the transaction and the inputs to the transaction, so the outcome,
which new UTXOs would get created.  So, the amounts and output scripts of the
outputs that a transaction creates, they are present in old and new transaction
alike.  And then, on the input side, at least which UTXOs are getting removed
from the UTXO set and are being spent.

Segwit works around the authentication for old nodes, so non-segwit nodes simply
don't know the witness stack, and they only look at the input script.  And as
many of you probably know, native segwit input scripts are empty, right?  They
are length 0, and all of the witness data, the proof that the sender is allowed
to spend the coin, comes in the witness stack, or in the witness structure, so
all the witness stacks of the inputs.  So, in order for the old nodes to be able
to stay on the network, the new nodes, the segwit nodes, would respond to the old
'give me a transaction' call by stripping out all the witness data from the
transaction, and basically giving this stripped transaction to non-segwit nodes.
And this stripped transaction is also the basis for txids and continues to be the
basis for txids, because if witness data suddenly contributed to txids that are
committed to in the merkle tree, that would be a breaking consensus change.

So, the stripped size of transactions appears here as the hash of all the legacy
transaction format data without the witness, and we, on top, introduce the
witness txid (wtxid) that is committed to in the witness commitment in an
OP_RETURN output on the coinbase transaction, so that nobody can malleate the
witnesses of transactions and the entire transaction is still committed to by the
block.  So, when we're talking about stripped transaction size, we're
specifically talking about a transaction from which all of the witness data has
been removed so that it can be consumed by non-segwit nodes, or that it can be
used to calculate the txid, which we commit to in the merkle root of the block
header, so that we know which transactions are present in the block.

Now, as I said, native segwit outputs have an input script that is empty and all
of the authentication or the authorization data comes into witness.  So, the
stripped size of a transaction is at least one input, which is of course the
prevout, the outpoint, pointing at the txid that created a transaction output
plus the output index, which is 32 plus 4 bytes, so 36 bytes right there; the
sequence in the input, now we're at 40 bytes; and then, the length indicator for
the input script, which is 1 byte and just says, "The input script is empty, so
it has a length of 0".  So, we have 41 bytes on the input.  Then in the header,
we have at least 10 bytes: there's the 4-byte version, the input counter of 1
byte; the output counter of 1 byte; the locktime of 4 bytes.  So, that's 10 bytes
for the transaction header.  The 2-byte marker and flag that only appear in
segwit transactions are stripped.  And then, the minimum output that we can have
on a transaction is the amount and an empty script.  So, an amount is 8 bytes and
an empty script is again an output script length indicator of 1 byte that just
says, "This script has a length of 0".

So, at a minimum, this is 9 bytes.  So, with 41 bytes from the input, 10 bytes
from the header, 9 bytes from the output, we arrive at 60 bytes being the
absolute minimum size for a stripped transaction.  Obviously, this transaction
could still have a lot more data in the witness stack or in the witness
structure.  Well, there's only one input, so witness stack in this case.  So, the
minimum transaction that we can create is 60 bytes.  But you might notice the
input script is empty.  Well, we can work around that with a witness stack.  But
the output script is also empty.  And the output script being empty means that
the funds or the output that we're creating is completely unencumbered and can be
spent by anyone, right?

So, now the question is what can we do with 64-byte stripped transactions?  We
can surely have a lot of input data in the witness and it will still be only 41
bytes.  Oh, I should maybe also say, as mentioned earlier, transactions have to
have at least 1 input and 1 output.  This is why I'm talking about a 1 input, 1
output transaction as the minimum.  But of course, they can have more inputs and
outputs.  But yeah, back to the output script.  So, we get 51 bytes from the
input and the header.  And now the question is, what are we doing with our output
script that is relevant for the outcome of the transaction?  And now, I think
this is maybe a good point to give it back to Mike, because he actually wanted to
talk about the content of the email, I guess!

**Mike Schmidt**: Sure, there's a few things that have come up That Jeremy brought
up.  First of all, thank you, Murch, that was a great deep dive on that to give
some context.  Current uses that Jeremy brought up, because I think there's some
nuance between what I think Murch was getting into in terms of anyone-can-spend,
and Jeremy's clarifying that you can actually have an anyone-can-spend that
donates essentially to a miner in the future using OP_CSV (CHECKSEQUENCEVERIFY),
which would mean it's not spendable immediately, but after some sort of delay.
He also brought up another current potential use as connector outputs, meant to
be claimed by a miner at a future specific time, which seems similar to the first
one to me.  And then, he mentions this way to shim a keyed anchor into a P2A
(Pay-to-Anchor) output after a certain delay, which I can say those words, but I
cannot elaborate on what that is.  Murch, I don't know if you're familiar?

**Mark Erhardt**: Yeah, let's steelman this a little bit.  So, one thing that has
been criticized about BIP54's mitigation of the merkle tree vulnerability, is
it's kind of ugly that we allow transactions of 60, 61, 62, and 63 bytes, then
forbid 64 bytes, and then allow again 65 bytes.  This is all stripped transaction
size, of course.  So, this is described as a seam in the consensus.  And it makes
this special case where a 64-byte transaction specifically, stripped size again,
is invalid and that is special casing that is ugly.  The second one is that we
currently do not have any 64-byte transactions that are regularly used on the
network, but we might have some of those in the future.  And then, forbidding the
length of 64 bytes would make it more complicated or detrimental for these use
cases, because these future use cases might want to use a 64-byte stripped
transaction size.

So, if I remember right, Jeremy described three things specifically.  One example
was a 512 CSV output.  So, this would be an output that locks funds to be
collected after the output has been confirmed for 512 blocks.  This would be
exactly 64 bytes if there's a single native segwit input, or another input with
an empty input script.  And this would happen because to express 512, you would
need an OP_PUSHBYTES 2 opcode, then push 2 bytes to express the 512, and then
you'd push OP_CSV.  This is in total 4 bytes.  With the length indicator, it
becomes 5 bytes.  With the amount, the output is 13 bytes.  As we discussed
earlier, 41+10+13=64 bytes, this transaction would be forbidden in the future.

The second one he describes is the P2A output.  The P2A output also has an output
script of 4 bytes, and with the length indicator, it would become a 64-byte
stripped transaction size if it has only one input and only that P2A output.  And
then, he also described how construction similar to the Ark connector output
could want to make use of 64 byte transactions in the future.  I think, Mike,
that was the examples.  Did you have more?

**Mike Schmidt**: Yeah, those were, I think you could say like, current potential
examples, and then there are future potential examples, one of which is, I
believe, Jeremy's idea, which is transaction sponsorship, which is this idea
where one transaction can sponsor the fees of another.  We covered that in the
newsletter a few years ago.

**Mark Erhardt**: I think much more importantly, it would allow any transaction
to sponsor any other transaction's fees, so not just a specific.  So, with CPFP,
for example, we have a specific child-parent relationship, where only a
transaction that spends the output can bump the parent.  This makes it a
one-to-one relationship with transaction sponsors.  And the idea would be that
any other transaction could just say, "I'm paying for that transaction".

**Mike Schmidt**: That's right.  The second one was a certain type of covenant
construction involving quines as inputs.  That would be a script that recreates
itself as part of a state machine.  I don't know if, Murch, you want to elaborate
on that one?

**Mark Erhardt**: No, that's correct.  A quine reproduces itself.

**Mike Schmidt**: And then, I think that the that the last example was a future
use for 64-byte transactions where we have these expensive post-quantum public
keys and there could be a way to potentially reuse those expensive keys by
posting them once and then subsequently referring to them by some sort of an
index, and that would involve creating a 64-byte transaction to reference them.
Those are the three that I pulled out as potential future uses for 64-byte
transactions.

**Mark Erhardt**: Okay.  Now, I think, would you say that we fairly steelmanned
the opposition, because I want to comment?

**Mike Schmidt**: Maybe one quick thing.  Well, why don't you go, because I have
AJ's response and then Jeremy's rebuttal.  But why don't you give your two cents?

**Mark Erhardt**: Yeah, I haven't seen -- well, maybe he replied today, but I
thought that especially AJ's point was important.  So, all these examples become
64 bytes because of the output script.  And there is always the potential to just
insert an OP_NOP, an op no operation, a 1-byte opcode that doesn't do anything.
And that would pad it to a 65-byte transaction.  And yes, that would be a little
ugly, but Jeremy got this response from AJ and I haven't seen a response to it
yet, unless it came today.  Do you have it?  Is there one today?  Because that
simply seems to largely mitigate all of these concerns, in my opinion.  We
currently have no use cases.  All of the use cases that are being described are
ways how funds are given away to anyone-can-spend outputs, whether they're
time-delayed or immediately collectible.  And if we wanted to use a construction
like that in some context or overlay it with additional meaning, we could always
just pad it by a single byte and it would become a 65-byte transaction.

So, this concern about 64-byte transactions being possible, us not having a use
for them yet at this time, but potentially coming up with one in the future, when
we come up with this use in the future, we can define the standard script to
include an OP_NOP to make it 65 bytes.  It'll make the stripped transaction size
1.5% bigger or something, and then it'll still work.  So, I'm not very convinced
by this not objection but observation, he clarified, especially, I think, for a
lot of these constructions, the idea that you have an input that is a native
segment input that just burns all of the funds and doesn't have a second output
to achieve something with this burn or this connector.  So, for example, in the
use case of P2A, the most common use case right now is to ensure that layer 2
settlement transactions are expedited to confirmation.  And obviously, the point
there is to have the P2A output so people can attach a child transaction to make
this transaction confirmed.  But the payload of the transaction are the other
outputs on the transaction, and the other outputs on the transaction make it
bigger.  If you have only the P2A output, it means that the funds are directly
flowing to the miner, or whoever bumps this transaction.  So, you can't tie
anything to the existence of this output because anyone can spend it.

So, if you built a tree of settlements that relied on this P2A output being
present so you could spend it in a follow-up transaction, that wouldn't work
because anyone could grab it and confirm the transaction, and therefore
invalidate your entire tree that relies on this transaction.  So, for example,
connector outputs, as far as I understand, are always keyed in order to ensure
that they are actually present for the connected transaction to connect to it and
not spent by someone else.  I find that these examples do not convince me.

**Mike Schmidt**: So, I think there's two points.  One that you brought up is just
say, "Just add the OP_NOP", and now you avoided the 64.  I am not going to try to
speak for Jeremy, but I do believe that I've heard him previously say something
along the lines of, in certain protocols, I'll say, the size of the transaction
is essentially undetermined, or you don't know until you do it, basically.  And
maybe this is a collaborative-type setup, and that you may end up with 65 or 66,
but you also just may, because it's not deterministic, end up with the 64, and
that you've done some collaborative work in front of all that, and now you have
to essentially invalidate that and then redo it again.  Now, I am way out of my
depth in trying to articulate his response to that, and I don't think it was in
the email thread.  That's something that I've seen separately.  So, we could just
put that as a highly speculative comment on my part.

With regards to the, "Hey, these are all just anyone-can-spends", so that was one
of AJ's responses, "These are effectively anyone-can-spend".  And Jeremy's
counter to that is that anyone-can-spend now and anyone-can-spend later are not
economically equivalent.  Now, I think there could be probably a whole discussion
about that, but that is at least where I think that the thread left off last I
saw it, and at least at the point that we covered it in a newsletter.
Unfortunately, we couldn't get Jeremy on to represent, so you have me with a
bunch of conjecture here.  But it does seem with three email threads going on
about this and it being associated with BIP54 and the energy around BIP54, I have
to think that this was maybe an ongoing type of discussion.

All right.  I think we can wrap up that item, and thus wrap up Changing consensus
and the News.  I believe we hit everything, even though we jumped out of order.
We can jump to Releases and release candidates, as well as the following Notable
code and documentation changes, both authored by our fellow co-host, Gustavo, who
will walk us through these.  Hey, Gustavo.

_Core Lightning 26.06_

**Gustavo Flores Echaiz**: Hey guys, thank you so much for that segment.  That was
very interesting, I learned a lot of things.  So, now we move forward with the
Release section.  This week, we have finally the release of Core Lightning 26.06.
So, this has followed two RCs that were covered in previous newsletters, and now
we get to the official release.  So, I'm going to go a little bit more into
detail now that it's no longer just an RC.

The main change of this release is the deprecation of a method or a plugin called
pay with the preference now of the plugin called xpay.  So, the difference
between pay and xpay, which are used to pay invoices, is that the pathfinding
mechanism or system behind it has now upgraded.  Xpay uses something called
askrene, which is based on minimum cost flow implementation of a pathfinding,
also known as Pickhardt Payments, based on the work of René Pickhardt.  So, in
Newsletter #330, we covered that CLN introduced the xpay plugin that used the
askrene plugin to construct optimal multipath payments.  And in Newsletter #316,
we covered the introduction of askrene which, like I said, was then a new
experimental plugin, but it's now becoming the basis of how CLN handles invoice
payments.  And yes, so you can check out those Newsletters, #330 and #316, if you
want additional details on how this xpay works.

But one of the main changes of this release is the deprecation of pay versus
xpay, and there's also some new additional commands that are added to CLN.  For
example, graceful is a command that prepares CLN for shutdown.  So, instead of
just jumping to shut it down and maybe enter into conflict with running
processes, graceful ensures that everything is shut down gracefully.  So, another
change that came with the prioritization now of the xpay infrastructure is the
addition of a new command called xkeysend.  So, this also uses xpay behind the
scenes to be able to do a keysend payment, which is a payment to a node that
didn't provide an invoice.  So, those are, let's say, the main changes.

Also, the next one is the new RPC command called createproof which, as we covered
in Newsletter #305, is an initial implementation of something called payer proofs
for BOLT12 offers.  So, this is an opened draft proposal in the BOLTs repository,
specifically PR #1295.  And this new release of CLN has the first implementation
of this, which basically allows a payer to prove that they paid an invoice, using
not only the payment preimage, but also the signature of the node that created
the invoice and the signature of the payer when they requested the invoice after
having received the offer.  So, all of these fields are used for a payer to prove
that he has paid successfully a BOLT12 invoice, and that the payment came from him
and that the invoice was generated by the specific payee.

So, those are a few of the changes that are introduced in this new version of
CLN.  But as always, there are release notes and there's also a changelog if you
want all the absolute details of all the PRs that were part of this release, or
the comments that were part of this release.  You can also find that as linked in
the news item that we have on the newsletter, or directly on GitHub on the
repository of CLN on GitHub.

_Bitcoin Core #35269_

So, that's the release of this week, and now we go to the Notable code and
documentation changes section.  This week we have a lighter week than previous
ones.  We have three items from the Bitcoin Core repository.  So, the first one
is an edge case where, when you are signing a PSBT for a MuSig2 wallet, probably
you're going to be signing cooperatively with other signers.  When you sign a
MuSig2 PSBT, there are two rounds of signing.  The first round, each signer has to
add the pub nonce that is specific to his input, so everyone adds their nonce.
And then on the second round, once all nonces are present, then signers can
proceed to each one sign their partial signatures.

So, what is this item about?  It's the moment you, as a signer, are adding your
nonce to the PSBT for the input that your key is supposed to sign.  Let's say you
have to run this command called walletprocesspsbt, and that will add the nonce to
the specific field before sharing it with other signers.  If you do that twice,
if you run walletprocesspsbt on the PSBT file that doesn't have the nonce, and you
did that twice, Bitcoin Core would effectively generate a new public nonce the
second time.  But it would fail because both internal session IDs, when adding the
nonce to the PSBT, both of them would collide.  And previously, Bitcoin Core
would assume that this would be a collision, to prevent nonce reuse, right?
Because you really want to avoid reusing nonces and Bitcoin Core would think that
you were reusing a nonce when doing this.  However, behind the background, even if
this was failing, a new public nonce was generated.

So, now, the session identifier includes a hash of the public nonce being
inserted so that when you are running walletprocesspsbt for a second time, there's
no collision between the session IDs, because now the session IDs include the
different public nonces.  So, now this specific edge case, where you run
walletprocesspsbt twice on the same nonce-less PSBT file, it will not fail anymore
because there will be no collision between these internal session IDs.  However,
the code remains that if you were to use the same nonce, there would be a failure
and a crash on Bitcoin Core, because Bitcoin Core wants to absolutely, at all
costs, avoid you from reusing the same public nonce to prevent a private key leak.
So, now, like I said, if you run walletprocesspsbt twice and you naturally let
Bitcoin Core generate a new public nonce, it will no longer fail.

**Mark Erhardt**: Did you understand whether the issue here was that there are two
signing sessions for the same PSBT, as in the same underlying transaction, or
there are two?  Yeah, is the signing session collision the problem, or is the
nonce collision the problem here?  I think both, but in different aspects?

**Gustavo Flores Echaiz**: So, this occurs when you run before the signing
session, so when you are inserting the public nonce to the PSBT.  And if you were
to call the command walletprocesspsbt to insert that public nonce twice on the
same nonce-less PSBT file, that's when the collision would occur, because that
retry would have the same session ID.  It would effectively have a different
nonce, but Bitcoin Core would think that there was a collision because of the same
session ID.

**Mark Erhardt**: Okay, so the session ID is derived from the PSBT, and because
both of them would be on empty PSBT files, they would ingest the same information
and therefore derive the same deterministic session ID.  And now, the random
nonce that is being rolled is incorporated in calculating the session ID.  So, if
you use different session IDs for the same PSBT, you would get different session
IDs and you no longer collide.

**Gustavo Flores Echaiz**: Exactly, that's exactly it.

**Mark Erhardt**: Cool, I see.

_Bitcoin Core #34644_

**Gustavo Flores Echaiz**: Thank you, Murch.  Okay, so the next item, as we've
discussed multiple times over the past weeks, there's always new additions to the
Mining interface IPC connection.  So, now we have a new method called submitBlock,
which is pretty much the same as the internal RPC command in Bitcoin Core called
submitblock.  So, the reason why this is useful is that previously, before
submitBlock was added to the Mining IPC interface, an external Stratum v2 client
would submit a fully assembled block through the submitSolution method.  However,
this could be insufficient if Bitcoin Core lacks the corresponding block template
object.  So, if this external Stratum v2 client would obtain the template from
another source than this Bitcoin Core node, then submitSolution couldn't be used,
because Bitcoin Core, like I said, has to have the block template object.  So,
now, a Stratum v2 client can use submitBlock to submit a fully complete block.
However, compared to submitSolution, and compared also to the submitblock RPC
command that is already present in Bitcoin Core, it's important for the IPC caller
to submit a complete block, including the coinbase witness, if a coinbase
commitment is present.

_Bitcoin Core #34198_

So, the next item, Bitcoin Core #34198, there's been multiple changes or
improvements to how legacy wallets migrate to a descriptor wallet because, if I
recall correctly, the first release of v30 and even v30.1 had some issues related
to migrating legacy wallets.  So, here, a new edge case is found when trying to
migrate a very old legacy wallet, so a wallet created before 2011, when wallet
best block records were added.  So, if you have a very old legacy wallet that
doesn't have a wallet best block record, the migration would simply fail.  And
now, this PR updates Bitcoin Core to allow the migration of a legacy wallet with
an empty best block locator.  However, full chain rescan would have to be
required.  And what is this wallet best block record or best block located record?
It basically indicates to the node that the wallet has already synced up to this
specific block height.  And it does that by not just specifying a block height,
but an assembly of multiple block hashes so that, for example, Bitcoin Core can
know that it is part of the same chain that it is on, right?

So, for example, if you were to have a best block record that indicates that the
wallet has synced up to block 800,000, well, Bitcoin Core would simply sync from
that block until the chain tip.  However, if a wallet has an empty best block
record, then a full chain rescan would be required to ensure to obtain all the
transaction data that that wallet cares about.

**Mark Erhardt**: So, basically, if you're running still a Bitcoin Core version
that is older than April 2011, if you now Import the same wallet into a modern
Bitcoin Core wallet, it would fail to migrate this legacy wallet to a descriptor
wallet because there is no best block locator, which indicates how far you had
scanned.  And that is fixed now.  So now, if you import a wallet that had only
been updated with Bitcoin Core software -- it wasn't even called Bitcoin Core then
-- with Bitcoin-Qt software from 2011, you might have bumped into this.  But to be
honest, if it then has to rescan from 2009 to 2011 in order to catch up, again,
that seems like very little scanning extra, because scanning from 2011 to 2026 is
going to be the brunt of the effort there.  Anyway, I am kind of amused by
envisioning what scenario led to this bug being discovered.  Someone must have
imported a wallet that was created with very old software and hadn't been synced
since 2011 to find this.  And it sounds like it's a pretty easy fix.  Just if the
best known block or the last block that the wallet had been synced to is not
known, you scan the whole blockchain.  Obviously, this is not a resync of the
actual blockchain state of the node.  It's just scanning the blocks for
transactions that are relevant to the wallet, which is a different process.  But
either way, that's some diamond hands right there.

_LND #10813_

**Gustavo Flores Echaiz**: Right.  Thank you for that extra context, Murch.  So,
that completes the Bitcoin Core items.  And now, we move forward with LND #10813.
So, this is an item that covers the removal of the LND being able to produce Tor
v2 onion services, which had been already set for removal in v20.  And also, Tor
v2 onion services have basically been obsolete since October 2021.  That's when
the Tor Network stopped supporting them.  So, this is a cleanup that shouldn't
have any real effects on the network.  Users should now use Tor v3.  However, one
important thing to note is that everything in the LND codebase removes being able
to produce this new service with Tor v2 addresses, like the option is also
removed.  However, if you would have an historical record of a peer announcement
that had included a Tor v2 address, well, that functionality is basically kept.
So, you can still verify and rebroadcast all peer announcements that had a Tor v2
address.  That is the only functionality that is kept, to ensure there's you can
re-verify and rebroadcast very old peer announcements that included those
addresses.

_Rust Bitcoin #6250_

The next item, Rust Bitcoin #6250, covers an edge case where a coinbase input
contains a 32-byte witness reserved value when there's no segwit transactions in
the block.  However, this item ensures that even if there's no other segwit
transactions or just no segwit transactions at all, but the block coinbase
transaction includes a witness commitment, then the coinbase input has to contain
the 32-bytes witness reserved value.  So, I believe BIP141 says that a block can
optionally have this witness commitment, even if it doesn't have segwit
transactions.  You say no, Murch?

**Mark Erhardt**: No.  I'm pretty sure that a block that doesn't have segwit
transactions is not allowed to have the witness commitment.  So, I think this
might be a bug.  Good that we report on it.  I will double-check, but I'm pretty
sure only blocks that contain segwit transactions are permitted to have the
witness commitment.

**Gustavo Flores Echaiz**: Okay.  Well, maybe here it's related to a transaction
that is not standard.  Basically, the code change here is that if the coinbase
transaction includes a witness commitment, then the coinbase input has to have a
32-byte witness reserved value, whether there's segwit transactions in the block.
That is what this item changes.

**Mark Erhardt**: Sorry, what is a witness reserved field in the first place?  So,
coinbase transactions are special in many different ways, the most obvious one
being that they have a coinbase field instead of an input.  And coinbase fields
have various restrictions on them.  And the input doesn't commit to a prevout.
So, coinbase transactions are just different, and they only appear once in every
block in a specific position in the block.  So, is witness reserved just a
different name for the witness commitment in an output?  Because the segwit
witness commitment for segwit blocks is written to an OP_RETURN output in the
outputs, not in the input.  So, I'm sorry to pounce on you.  I don't know what a
witness reserved thing is, but I was, until a few minutes ago, very sure that
you're not allowed to have a witness commitment if you don't have segwit
transactions.  I will double-check that while you continue, but if you know more,
please enlighten us.

**Gustavo Flores Echaiz**: Okay, so from what I understand, if you have the
witness reserved value in the input, right, you've got to have the witness
commitment that comes with it.  Is that correct understanding?

**Mark Erhardt**: Well, I don't know what a witness reserved value is, I've never
heard the term before.  So, I'm confused by this assertion.  But I might just not
know everything.  It happens occasionally.  I certainly don't know everything
about Bitcoin.

**Mike Schmidt**: Okay.  Well, we've still got a show to do and we all want to look
up the answer right now!

**Gustavo Flores Echaiz**: Okay.  So, for example, I have BIP141 opened right in
front of me.  And it says the witness reserved value is simply just a 32-byte
array of mostly just zeros that get added to the witness root hash before
committing to the witness commitment that then gets committed to the block merkle
root.

**Mark Erhardt**: Right, okay.  So, obviously, you can't have the output of the
coinbase transaction rely on a value that is relevant to the input of the coinbase
transaction.  That would be circular, and this loop would be problematic.  So, in
the witness commitment tree that commits to all of the wtxids of the transactions
that are present in the block, the coinbase transaction has a fixed value.  And
so, my understanding here is that the witness reserved value is this fixed value
that contributes to the wtxid merkle tree that is then committed to as the witness
commitment in the OP_RETURN output that is required for segwit blocks.  But if all
transactions in a block do not have witness data, the commitment is optional.  I
am wrong.  BIP141 specifies specifically the commitment is optional, so you're
allowed to have it, and I stand corrected.  I was very sure that you're not
allowed to have it if you don't have segwit transactions.  But okay, so I was
wrong.

**Gustavo Flores Echaiz**: Okay, so yeah, so there's this fixed value, right?
Basically, you've got to have this fixed value.

**Mark Erhardt**: So, basically, what probably happened here is someone built a
block that had no segwit transactions, but added the witness reserved value for
the coinbase transaction and built a merkle tree from it, and then added empty
witness commitments for all of the non segwit transactions, which I believe are
simply their txids, so for transactions.  Obviously, non-segwit transactions don't
have witness data, so the way they contribute to the witness commitment is by
their regular txids.  Happy to be corrected on that.  That's just from the top of
my head.  So, they basically built a whole other merkle tree for their OP_RETURN
output, and also spent the extra bytes on the OP_RETURN output in the coinbase
transaction to only commit to the witness reserved value for the coinbase.  And
Rust Bitcoin had a hiccup on that, because consensus is what is allowed on the
network and not what makes sense.

**Gustavo Flores Echaiz**: Right, that's it, that's my understanding too.  This is
an edge case that has no effective value, right?  There's nothing that really
changes in the block because you're doing this.

**Mark Erhardt**: In fact, it wastes space, yeah.  It makes the coinbase bigger
than necessary.  You could have put some fee-paying data into data -- as in
transaction data, before people get angry and hate-mail into our inbox -- 32 more
bytes that could be filled by transactions, yeah.

**Gustavo Flores Echaiz**: Exactly.  So, I just want to precis that the problem
was that Rust Bitcoin was accepting a block that had the witness commitment in the
Coinbase, but didn't have the fixed value.  So, that was what was being accepted.
So, this item ensures that if there's a coinbase witness commitment, you've got to
have the reserved value or the fixed value, even if you don't have segwit
transactions in the block.

**Mark Erhardt**: I see, thank you.  I think we've reached the bottom of this.

_BOLTs #1338_

**Gustavo Flores Echaiz**: Yes.  So, the final two items are updates in the BOLTs
repository.  The first one, very straightforward, #1338, updates BOLT2 to require
nodes to wait at least 100 blocks before sending a message that the channel is
ready for usage, if the channel funding transaction comes from a coinbase
transaction, right?  So, this is the rule that bitcoin that has been created from
a coinbase transaction that has been mined cannot be used before 100 blocks.  So,
now the BOLTs repository is updated to consider this maturity of this coinbase
output before allowing the channel to be ready.

**Mark Erhardt**: Man, there's just so many edge cases in Bitcoin.  Who would have
thought that someone uses coinbase transactions to create Lightning channels?
That's just friggin' insane because who wants to wait for 16 hours for their
channel to mature because someone mines directly into coinbase transaction outputs
as the Lightning channel anchors?

_BOLTs #1326_

**Gustavo Flores Echaiz**: Right.  And the next item, another specification
cleanup item in BOLTs, #1326, where BOLT4 is updated to allow final nodes, not
just forwarding nodes, to return errors related to the onion.  So, all
implementations by the way, had already been implementing this from what I read in
the peer discussion.  So, this is just a clean of the specification, where it was
marked that only a forwarding note could return this type of failure message, such
as invalid_onion_version, invalid_onion_hmac, or invalid_onion_key.  Now, final
nodes can also return it, not just forwarding nodes.  And also, there's another
change that basically clarifies that forwarding nodes must not handle already-paid
payment hashes.  So, if a forwarding node knows that he's forwarding a payment
that has a payment hash that he knows has already been paid, he must not react to
this, he must simply forward it.  And the final recipient, he must ensure that he
must handle that.  So, the text is updated to indicate that the forwarding nodes
don't have to react to this situation, they simply have to forward a payment.  And
that is the final item, and it completes the section and the whole newsletter.
Thank you.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.  Good newsletter this week, everyone.
We want to thank our guests, one of which who has hung on, Ademan, and also Pyth
for joining us.  This was an almost two-hour one.  We appreciate everybody for
hanging on.  Thanks for co-hosting, Gustavo and Murch, and thanks to everybody
for listening.  Cheers.

{% include references.md %}
