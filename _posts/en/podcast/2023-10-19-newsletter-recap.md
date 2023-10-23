---
title: 'Bitcoin Optech Newsletter #273 Recap Podcast'
permalink: /en/podcast/2023/10/19/
reference: /en/newsletters/2023/10/18/
name: 2023-10-19-recap
slug: 2023-10-19-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Robin Linus and Antoine Poinsot to discuss [Newsletter #273]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-9-19/351859211-22050-1-22dd919f68fac.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #273 Recap on
Twitter Spaces.  Today we're going to be discussing a security disclosure
affecting Lightning implementations, a paper about BitVM and how arbitrary
programs' execution outcomes can control the flow of bitcoins, a proposed BIP
for adding MuSig2 fields to PSBTs, six interesting updates to ecosystem
software, and we specifically highlight a Bitcoin Core PR for mini tapscript and
more.  I'm Mike Schmidt, I'm a contributor at Optech and also Executive Director
at Brink, where we fund Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.

**Mike Schmidt**: Robin?

**Robin Linus**: Hi, I'm Robin, I work on ZeroSync and I created BitVM.

**Mike Schmidt**: Antoine?

**Antoine Poinsot**: Hey, I'm Antoine Poinsot, I work at Wizardsardine and I
contribute to Bitcoin Core.

**Mike Schmidt**: Thank you both for joining us this week.  We have a few news
items we'll cover in sequential order.

_Security disclosure of issue affecting LN_

The first one is a security disclosure affecting LN implementations.  The
mailing list post title included the nickname, "All your mempool are belong to
us".  This was actually a disclosure that happened late in the newsletter
publication process, so we only gave sort of a high level overview and link to
the specific issue that Antoine Riard posted on the Bitcoin-Dev and Lightning
mailing list.  We plan to have a bit more detail in next week's newsletter, but
there were a few items that I saw in the post that I thought were interesting.

Antoine writes, "Amid technical discussions on eltoo payment channels and
incentives compatibility of the mempool anti-DoS rules, a new transaction-relay
jamming attack affecting lightning channels was discovered.  This attack is
practical and immediately exposed Lightning routing hops carrying HTLC (Hash
Time Locked Contract) traffic to loss of potential funds security risks".  And I
believe that Antoine is referring to this class of attacks as replacement
cycling attacks.  And as of now, since the security vulnerability was
responsibly disclosed, Core Lightning (CLN), Eclair, LDK, and LND all contain
mitigations that make the attack less practical.  Murch, that's the level of
depth that I went into with this one, since we alluded to covering it more in
next week's newsletter.  I'm not sure if you have any insights on this?

**Mark Erhardt**: I glanced at it, and it seems to me that basically, the attack
would require two participants along a multi-hop payment to coordinate against
the user between them, and it would essentially involve forcing the forwarder to
go onchain with, well, an outdated penalty transaction that has a very low
feerate while that is either not going to confirm or not even going to get into
the mempool, because the feerate on the penalty transaction is pre-negotiated so
they cannot bump the penalty transaction.  And then the two attackers would take
first back the funds by also going onchain with the HTLC, or by letting it
timeout and then also redeeming the HTLC because the penalty transaction
couldn't go through due to the low feerates.  That's what I understood briefly.
Glancing at it, if someone has better information, please correct me.

**Antoine Poinsot**: I don't think it's related to the penalty transaction.  The
success rate is to the commitment transaction and going to chain through the
HTLC success on one side, and preventing the honest node from being able to
claim the HTLC using the HTLC success on the other side.

**Mark Erhardt**: Yeah, correct.  It's not the penalty transaction, just the
commitment transaction with the HTLC and two different variants.  Thanks.

**Greg Sanders**: I can speak a little bit about this if that's all right?  Can
you hear me?

**Mike Schmidt**: Do it.

**Greg Sanders**: Yeah, so this is about the HTLC transaction.  So essentially,
as a router, you want to make sure HTLC routing is atomic for you.  So, if
someone has offered HTLC to you, and you've offered it to someone else
downstream, that if the person downstream claims it, that you get the preimage,
and then you can claim the incoming, the upstream one.  And so, this is
essentially a game that people could play where let's say you don't get the HTLC
preimage, right?  Intentionally, they withhold it, so you put the timeout in the
mempool.  Then the attacker sees the timeout in the mempool, immediately RBFs it
with their success, and then RBFs their own success with another transaction,
right?  So basically the preimage will never hit the chain.  So, they keep doing
this essentially so you never see onchain the HTLC preimage, and thusly you can
never pull it in, so then the incoming will then timeout and then the downstream
will then take it.

So, essentially it's just violating the ethnicity there, if that makes sense.
This is assuming a pretty strong network level attacker where they can see a lot
of things in various mempools, connect to lots of miners, but it's something to
be engineered to defend against.

**Mike Schmidt**: Instagibbs, are you familiar with the mitigations to this
issue that help, but only make it less powerful?

**Greg Sanders**: Yeah, I mean so I have my own opinions, but yeah, I can just
describe the mitigations.  So, some do things like looking at the mempool.  So,
if you see the HTCL see timeout get double spent by their other person's success
and then that gets RBFd as well, that means you can immediately replay
essentially your transaction.  You actually do need to tweak the witness txid to
get your node to gossip again, but you can, for example, resend the transaction,
rebroadcast it again with the different nonce, so that basically every time they
cycle it out, you put it back in.  And remember that every time they cycle it
out, they're paying fees every single time they do this.

So, imagine within a block, you do this ten times, that means they're paying ten
times the going rate in fees to cycle this out, if you can understand that.  So
basically, that's one.  So you can look at the mempool and rebroadcast, or you
can just blindly rebroadcast.  So I know from more familiarity that CLN simply
just rebroadcasts at a certain interval, right?  So it'll try again.  So, two
minutes later, it just rebroadcasts again, grinds it, new nonce, and
rebroadcasts it, such that again, the attacker would have to, let's say if it's
every two minutes and every block is about ten minutes each, that the attacker
has to pay basically five transaction fees to stop you from getting your
transaction in that block.

Then you can imagine, another mitigation is extending your expiry delta, meaning
how long you have to get this into the mempool is your security parameter.  So
if you increase this, let's say you double the security parameter, now it's
twice as expensive on top for the attacker, right?  So essentially multiplying
the cost and then trying to reduce the success rate of the attacker
simultaneously, reducing their expected value.

**Mike Schmidt**: Okay, that makes sense.

**Greg Sanders**: And I guess you can go over it more in-depth next week too.

**Mike Schmidt**: Yeah, I threw a Hail Mary to Antoine Riard this morning,
seeing if he was able to join us, but he wasn't.  So, maybe we'll have him
explain some of the background and how he came across this next week.

_Payments contingent on arbitrary computation_

I think we can move on in the newsletter to the second news item, which we
titled Payments contingent on arbitrary computation.  You may also have seen
this over Bitcoin Twitter the last week by its name, BitVM, and we have the
author, Robin, here to explain the paper and introduce the idea and what the
feedback's been from the community.  Robin, I'll let you have the floor here.

**Robin Linus**: Okay, thanks.  So BitVM is a computing paradigm to express
Turing-complete smart contracts on Bitcoin.  What it essentially does is it
mimics an optimistic rollup on Bitcoin.  That means you have two rolls, you have
a prover and a verifier.  The prover simply makes a claim that some function
returned for some particular inputs, some particular output.  And if the claim
is correct, then everybody is happy and people can just proceed bilaterally.
But if the prover lied, then the verifier can disprove them succinctly.  And
this way, we can essentially compute any function on Bitcoin.

**Mike Schmidt**: Robin, maybe give a 101.  What's the most basic example that
you found people can understand for doing something like this?

**Robin Linus**: Yeah, something very simple would be that you could play games,
like tic-tac-toe or chess, or something like that.

**Mike Schmidt**: And so, maybe walk through the process.  What would need to
happen from the conceptual idea that folks understand of tic-tac-toe, how does
that translate into being able to do anything related to onchain?

**Robin Linus**: Yeah, well, in the case of tic-tac-toe, or in general, in the
case of games, you have two phases.  The first one is the inputs, which is the
player making the moves.  And the second phase is to evaluate how the game ended
and who won the game.  And yeah, the moves, they will be quite simple, because
people just commit to particular inputs, they just simply reveal hashes to
commit to inputs.  And once they come to a stage in the game where one of the
players won, then you can simply execute a circuit and that circuit just
evaluates the game rules of the game, given that particular state that the
user's inputs led to.

**Mike Schmidt**: And maybe you can get into how the rules of the game in this
example are encoded, and how taproot comes into that?

**Robin Linus**: Yes, of course.  So, the scripting capabilities of Bitcoin
Script are quite limited.  We cannot do many high-level things.  For example,
the arithmetics, the most complex arithmetic that we can do is addition or
subtraction, we cannot even do multiplication or division or something like
that.  So, the expressiveness of this language is very limited.  But what it can
do is it can express boolean expressions.  You can do AND, OR, NOT, NAND, XOR,
and stuff like that.  And since we can represent any function as a boolean
circuit, we can essentially represent any function.  And that allows us to
express the tic-tac-toe game rules in the form of boolean circuits in Bitcoin.

Also, we are limited by the script size limit.  The script size limit is
currently 4 MB.  Essentially, you could have a single transaction with a huge
script of 4 MB.  But yeah, it's not very practical.  In practice, we want it to
be as compact as possible.  So, what we can do is we split up that big circuit
into small chunks, and then the verifier can essentially perform something like
a binary search over the claim of the prover, and find that particular part of
the circuit where the prover made an inconsistent claim, or where he lied,
essentially, about some execution.  And this way, we can disprove even very
complex circuits that would be way too large to execute them onchain.  We can
disprove them very succinctly within just a couple of rounds of a game of like
query and response.

So, the verifier asks for a particular gate or for a particular subset of the
circuit, and then the prover has to provide the inputs and outputs to that
particular subset of the circuit.  And if they ever equivocate and give
conflicting inputs, then the verifier can take the prover's money.

**Mike Schmidt**: We have a question from the audience.  Moth, do you have a
question or comment for Robin?

**Moth**: Yes, I do.  Thank you.  I just wanted to ask, is there a correlation
between a bit, the concept of a bit, to a satoshi, or is it more correlated to a
UTXO, or you can have a few so-and-so bits for every UTXO?

**Robin Linus**: You can have multiple bit commitments per UTXO.  So, it's
essentially like having variables, and you can have some variable, let's call it
A.  And in one script, you give it the value, I don't know, 42; and then, if you
give that same variable a different value in a different script, then you
automatically reveal a fraud proof that the verifier can use to take your money.

**Mike Schmidt**: What are the limitations?  You mentioned the example of,
"Well, we can't put this all in a single transaction", so you kind of hid the
programming or the gates within taproot scriptpath, if I'm understanding
correctly, but there's some limitations there as well.  Is there a limitation to
the programmability of the type of arbitrary program execution you're talking
about, and if so, maybe get into that?

**Robin Linus**: I would say, in terms of how large of a computation we can
express, we are almost unlimited for basically any practical purpose.  So, we
can express very large circuits since we can do that binary search, which is
quite efficient.  So, even if the circuit becomes like billions of gates, we can
find the incorrect gates within, I don't know, 30 queries or something.
However, there is a fundamental limitation in the sense that this entire BitVM
works in the prover-verifier setting, so you have two parties.  You have a
prover making claims and a verifier verifying these claims.  And that is very
different than what we are used to from other smart contracting platforms.
Because usually, every user can permissionlessly interact with every contract
without having to sign up or without having to participate in some set-up
ceremony or something.  And BitVM is very limited in that sense.

The best we can do so far is that we can have one prover and multiple verifiers,
for example, one prover and 100 verifiers.  And if a single of these verifiers
is honest, then they can hold the prover accountable.  And that can give us, for
example, bridges or two-way pegs that are similar to federated two-way pegs, but
they are better than federated two-way pegs in the sense that you require only a
single honest party for the peg to be secure.  And the more people participate,
the better this assumption is.  One in 100 is not as good as one in 1,000 or one
in 10,000.

**Greg Sanders**: Can I ask a question real quick?

**Robin Linus**: Yes, please.

**Greg Sanders**: Yeah, so I had a question.  So, you've got the verifier and
the prover.  How many steps can the verifier force?  Because you said, okay, say
there's a billion gates.  Could the verifier sloppily select challenges to just
lock up UTXOs for a billion steps; or, is there a way of forcing their hand to
do something smarter?  Does that make sense?

**Robin Linus**: Yeah, the verifier, what you're saying is, how do we deal with
a malicious verifier that doesn't want to disclose?

**Greg Sanders**: Exactly, yeah, they don't actually want the funds to get
unlocked.  They want to delay it as long as possible.

**Robin Linus**: Yeah, that is definitely possible.  A verifier can essentially
waste their queries because the number of queries has to be limited, because
another case is that a malicious verifier makes a baseless dispute, they claim
that the prover's claim was incorrect, even though it was correct.  Then,
challenging the prover should end at some point; at some point, the prover
should win and it should be enough of disputing him if he's correct.  So, the
number of total queries has to be limited, but it has to be exactly as many
queries as you need to disprove any statement that is incorrect.  So, if you
have a billion gates and you can perfectly binary search them, then it would
have these 30 queries or something.  And yeah, of course, the circuit has to be
designed in a way that you can always disprove the incorrect prover.

Also, the other thing is, I think you were aiming at the multi-verifier setting,
where you have like 100 verifiers and a single prover.

**Greg Sanders**: My question was just about the first one, but you can
continue.

**Robin Linus**: Yeah, in the multi-verifier setting, it's important that you
can run these challenges in parallel.  So, if one of these verifiers is
dishonest and just wastes their queries, then that doesn't matter, because as
long as there is a single honest verifier, they can run in parallel the correct
challenge, and then they will win.

**Greg Sanders**: Makes a lot of sense, thanks.

**Mark Erhardt**: I think I heard that you said you could implement a two-way
peg that is based on fraud proofs, essentially, with this mechanism.  How
complex would a circuit have to be to replicate something like the Liquid peg,
for example?

**Robin Linus**: Great question.  So, there are essentially two ways to approach
this.  Either you build a circuit that is specifically crafted for this
particular use case, and I would not really recommend that.  I think it's better
to create a virtual machine, somewhat like an abstract virtual machine, and then
you have state commitments of that virtual machine, essentially like a merkle
tree over its memory, containing both the data and the program, and the program
counter.  And then you can have just commitments to state transitions,
essentially one hash to the next hash, like hash of state A to hash of state B.
That would be a claim for the machine translated from state A to state B.  And
then we can have a huge list of these state commitments.  Let's say state A to
state B, state B to state C, state C to state D, and so on.  And then the
verifier can perform binary search over those state commitments, and then he
will quickly find the first incorrect state transition of the VM, and then they
can use specifically crafted circuits to disprove that one state transition of
the VM.

If we have that, then we can reduce the complexity for developers a lot, because
then we can have some kind of high-level language that compiles down to that
virtual machine, and that will make it much easier to implement high-level
applications such as a peg similar to Liquid, for example.  It would also be
better to audit it, because all auditors could focus on the same circuit.
Everybody would just verify the circuit of that single VM, and not every
developer would have to craft their own circuits and essentially start from
scratch.

**Mark Erhardt**: So, two weeks?!

**Robin Linus**: At most!  I mean, it's very hard to say.  We are in a very
early day.  That idea is only not even two weeks old.  I just wanted to publish
it to get more people involved and get more eyes on the idea.  And now, we are
trying to implement concrete things as soon as possible.  And hopefully we will
have some kind of VM by the end of this month, hopefully, some hacky version
that is just for experimental purposes, hopefully.

**Mark Erhardt**: So, basically what you're saying is you'd have a virtual
machine in which you can run some programs; a program that increases and
decreases the funds under management of a peg would, for example, be such a
program.  And if you can sufficiently simply express that in the VM, someone
paying someone else in the sidechain wouldn't necessarily require an onchain
transaction, but maybe someone depositing or withdrawing from the sidechain
would then cause a state transition in conjunction with the payment onchain, and
that could be verified basically by exclusion principle, "We couldn't find a
fault with this".

**Robin Linus**: Yeah, essentially that, yes.

**Mike Schmidt**: One thing that I don't think we've emphasized here is the fact
that there are no consensus changes required to use this technology, and so you
can actually start working on this right now, like Robin mentioned.  So it's
very interesting.  In fact, later in the newsletter, there's a little
proof-of-concept demonstration using BitVM for a certain type of circuit that
someone put together.  We can get into that a little bit later.  We noted in the
newsletter that there needs to be a potential large amount of data or processing
that goes in before setting up these gates.  And that's obviously "downside".
But maybe, Robin, based on this idea being out all of two weeks, have you gotten
feedback on other potential downsides to this approach, or improvements to the
way that the whitepaper was originally drafted?

**Robin Linus**: Yeah, I think the main downsides are definitely that it's not
permissionless.  You have to have this setup of multiple verifiers and a single
prover, and you have to trust that at least one of these verifiers is honest.
That is by far the biggest downside.  The second downside, of course, as you
just mentioned, is the setup cost.  And in general, I think, yeah, people would
expect something like the EVM, where everybody can easily interact with it, and
I suspect that this won't be the case.  It will be more like having the BitVM
facilitating some kind of peg.  And the good thing there is, even though if that
peg is super-slow and super-cumbersome to use, it is sufficient to peg Bitcoin
to some other chain.  And once you have some kind of very trust-minimized,
two-way peg, then that asset on the sidechain does have value, or is pegged to
Bitcoin's value; and as soon as you have that, then you can have atomic swaps
between the sidechain and the mainchain.  And normal users would just use those
atomic swaps to quickly swap between one chain and the other.

The other peg, like the real two-way peg, only something like Liquidity
providers would use it, as it is very slow and maybe also expensive to use and
expensive to set up and stuff.  But yeah, the main point is once it exists, then
we can have BTC on sidechains.  And then on that sidechain, we can do
essentially everything that we are used to from other chains, and we can have
essentially every feature that we would like to have.

**Mike Schmidt**: It sounds like a very interesting and promising idea, and I
think the community is really excited about it.  So, thanks for putting your
time towards it, Robin, and thanks for joining us and explaining it.

**Robin Linus**: Thanks a lot for having me.

**Mike Schmidt**: Like I mentioned, we do talk about tapleaf circuits a bit
later, you're welcome to stay on for that.  Otherwise, if you're busy, you're
free to drop as well.

**Robin Linus**: I'll stay.

_Proposed BIP for MuSig2 fields in PSBTs_

**Mike Schmidt**: Final news item for this week is proposed BIP for MuSig2
fields in PSBTs.  As a recap, PSBTs are a structured data format for the
exchange of information about a Bitcoin transaction that includes a bunch of
information, including the signature data.  The initial version was PSBTv0 in
BIP174.  And then PSBTv2 came along and allowed additional inputs or outputs to
be added to a PSBT.  And now, this proposed BIP adds MuSig2 BIP327
multisignature data to PSBTs.  So, these new fields apply to both PSBTv0 and v2,
and thus this doesn't appear to be a PSBTv3 proposal.  It just adds fields to
the previous PSBT versions.

The MuSig2-related fields that are in the proposal apply to inputs and outputs.
So for inputs, the proposed fields are participant public keys, the MuSig2
public nonce, participant partial signatures; and for outputs, it's just the
participant public keys.  So, that's what's being proposed here by Andrew Chow
on the Bitcoin-Dev mailing list with his draft BIP.  Murch and guests, I don't
know if anybody has a comment or addition to that summary.

**Mark Erhardt**: I think that's pretty much it.  If you want to construct a
MuSig payment with multiple participants and you don't have a completely signed
transaction yet, you need a way to transfer that partial state.  Yeah, this
seems to be an approach on how to transfer that intermediate state.

**Mike Schmidt**: We noted in the newsletter that AJ Towns was asking about
adapter-signature-related fields, if they would also be added as part of this
BIP, and it sounded like that would potentially be a future separate BIP as it
wasn't part of the consideration for the original proposal.  Next section from
the newsletter is our client and services section that we do monthly.

_BIP-329 Python library released_

The first item of six is BIP329 Python library being released.  So, back in
Newsletter #215, we covered the proposed BIP to standardize the wallet label
format.  We also discussed that with the BIP author, Craig Raw, in Podcast #215.
So, if you're curious about what this wallet label stuff is, refer back to that.
That proposal later became BIP329, which includes the ability to label different
pieces of Bitcoin-related data, including addresses, transactions, pubkeys,
inputs, outputs, and xpubs, and so you can attach some arbitrary label if you
want to say where it's from or what it's for or some note about it; the label
ability gives you to do that.  And this library that we covered this week is a
set of Python code to read, write, encrypt, and decrypt any BIP329-compliant
wallet label files.  So, it's an ability to interact with that file format using
Python.

_LN testing tool Doppler announced_

Next item we covered was LN testing tool Doppler being announced.  So, Doppler
is a DSL, which is a Domain-Specific Language, which is a way to write something
for a particular business use case, in this case Lightning and Bitcoin nodes and
transactions, in an abbreviated way.  So, it's a special language for
constructing topologies of Bitcoin and Lightning nodes and how they are
interacting with one another, so the relations between those nodes, and then
also the ability then to have onchain and offchain payments designated in that
DSL.  And the purpose of this tool is for Lightning testing, and there's been a
few related projects recently.  This sort of idea may ring a bell.

We spoke in Newsletter #269 and Podcast #269 about the SimLN tool, which
generates realistic Lightning payment activity, which is not quite the same, but
you can kind of feel the same energy towards wanting to create testing data,
testing infrastructure around Lightning.  And then also, in Newsletter #265 and
Podcast #265, we talked about the Scaling Lightning testing toolkit, and we
spoke about that with Henrik from Torq and what their goals are there as well.
So, if you're curious about those alternative, or I guess they're not
necessarily in competition, but different types of Lightning testing tools out
there.

_Coldcard Mk4 v5.2.0 released_

Next piece of software was Coldcard, the firmware v5.2.0 being released, which
added version 2 PSBT support, per our discussion earlier about PSBTs.  Also adds
a feature to allow for multiple seeds on the same hardware device, and then also
adds additional BIP39 features, particularly around BIP39 passphrases in various
usages within that firmware as well.

_Tapleaf circuits: a BitVM demo_

Next piece of software was one I alluded to earlier, which is Tapleaf circuits,
which is a demonstration of BitVM, and it's using these Bristol circuits within
the BitVM approach that we spoke about earlier.  I am not familiar with Bristol
circuits, and I think this is an interesting demonstration, but I'm not sure if,
Robin, you have any insights on what was put together with this demonstration?

**Robin Linus**: Yeah, Bristol circuits are just a format to express binary
circuits.  You probably have seen it before.  I didn't know the name either, but
when I saw an example of a Bristol circuit, I remember that I had seen that
before.  Yeah, and what Super Testnet did there was, he implemented a couple of
simple circuits, like addition or I think also the tic-tac-toe circuit and a
couple other circuits.  And what's cool about it is that there are already some
high-level tools that allow you to compile more or less high-level language,
like Python, something like that, down to Bristol circuits.  And then Bristol
circuits, you can easily compile to Bitcoin Script.

**Mike Schmidt**: Pretty cool that before we could even cover BitVM in the
newsletter, that there was already a proof of concept from somebody who's not
even affiliated with the proposal, to my knowledge, and already applied some of
that research.  So, it's pretty cool to see how quickly things can move.

**Robin Linus**: He's somewhat affiliated.  I mentioned him in the paper as
well, like he's in the acknowledgments.  He was in that group.  We had a
Telegram group called Hacker ZKP Verifier to Bitcoin, and he was part of that
group, and he definitely inspired a lot of things about BitVM.

_Samourai Wallet 0.99.98i released_

**Mike Schmidt**: Next piece of software that we highlighted was the Samourai
Wallet 0.99.98i being released.  It added additional support for PSBTs in the
form of animated QR code scanning, some additional labeling with regards to
UTXOs, "You can mark any associated change UTXOs from your broadcasted
transaction as Do Not Spend to aid with UTXO management", and some additional
batch-sending features.  Batch-sending was already possible, but now you can do
that in a more programmatic way via JSON instead of just in the GUI, and also
there's some QR code format around the import feature as well.

_Krux: signing device firmware_

Final piece of software is some signing device firmware, named Krux.  It's,
"Open-source firmware that enables anyone to build their own Bitcoin signing
device via off-the-shelf parts".  And so, the firmware then converts those
devices into airgapped devices that can sign transactions for multisignature or
single-signature wallets.  And there was a note in the README for this project,
"This software has not been audited by a third party.  Use at your own risk".
And in this latest version of the firmware, v23.09.0, the release notes did
state that new features are finally coming out of beta and making their way into
this stable release.  So, pretty cool there.  I haven't played with it, but it
sounds interesting.

_Bitcoin Core 24.2rc2 and Bitcoin Core 25.1rc1_

Moving on to the Releases and release candidates section, we've grouped two
Bitcoin Core related release candidates into a single item here, Bitcoin Core
24.2rc2 and Bitcoin Core 25.1rc1.  Murch, I think you have some commentary on
these release candidates.

**Mark Erhardt**: Yeah, so 25.1 is actually released now.  I think 24.2 is on
the second release candidate.  Generally, the point releases are only for
backporting bug fixes; we do not release new features in point releases usually.
So here, one of the things that stood out to me on both of these is that fee
estimation, there was a fix backported to avoid serving still fee estimates.  I
believe that was related to the node being offline for a few hours, but coming
online before the history of the transactions and their mempool had completely
timed out, and then it would happily serve up fee estimates from a few hours
ago.  And there was a fix for that.  And then there just seemed to be a bunch of
other smaller fixes, something about Bech32 address handling.

So, if you are someone that depends on Bitcoin Core software in production use
and is interested in not upgrading to the new version directly, but maybe
upgrading to a point release of a prior version, you might want to start playing
around with this in your testing environment and let us know if you find any
issues.

**Mike Schmidt**: As we move to the Notable code and documentation changes
section, I'll take the opportunity to solicit any questions, either at request
speaker access or comment on the thread associated with this Twitter Space, and
we'll try to get to your question by the end of the podcast here.

_Bitcoin Core #27255_

Normally, we don't bring on special guests just for a PR, but I think this one
was interesting enough to bring in Antoine to talk about Bitcoin Core #27255
which, "Ports miniscript to tapscript".  Antoine, what does that mean?

**Antoine Poinsot**: Yeah, so miniscript, as probably most of the listeners
already know, is a framework for safely using Bitcoin Script, as in you'll be
able to use more features available already today in Bitcoin Script.  However,
it was designed for P2WSH for segwit v0, and with taproot and tapscript, which
specifies the scripts in the first leaf versions for taproot, some of the
properties changed for the script.  So miniscript, the framework, had to be
adapted with small tweaks in order to be able to use miniscripts with tapscripts
as well, so using miniscripts for taproot.

**Mike Schmidt**: And we noted -- oh, go ahead, Murch.

**Mark Erhardt**: Yeah, I just wanted to jump in to give a little more
background on miniscript in the first place.  So, what comes together here is
output script descriptors and miniscript.  So, probably a lot of you have heard
about output descriptors in the past few years.  They are sort of a better or
newer take on a concept called extended pubkey (xpub).  So an output script
descriptor allows you to describe a whole set of output scripts that all follow
as the same recipient.  And other than an xpub, where you only encode a public
key and a chain of public keys that derive from it, with an output script
descriptor you can have more complex scripts.

One way with which you can describe these output scripts in your range
descriptor is with miniscript, which is a higher level description language that
is human-readable and describes what outcome you're trying to achieve, and then
can be used to compile down to a script primitive in the actual Bitcoin
transactions.  Antoine, if I'm butchering that, please jump in and correct me.
But what this generally allows is that we can have way more complex output
scripts, but back them up in a similar fashion to how we used to back up xpubs.
So you can, for example, have a set of outputs that after a certain timeout,
become spendable by a smaller quorum of keys, and you can define that in a
single output script descriptor, and another wallet that also implements support
for output script descriptors and miniscript can import that and also recover
and spend those funds.

So, there are a handful of wallets that are already working on support; of
course, Bitcoin Core.  I also know that there's Rob Hamilton has a wallet that
works a lot with miniscript, and Antoine himself works on Liana Wallet, which
also is heavily integrated with miniscript.  So, basically we are in the bigger
picture establishing a standard on how we can have more complex output scripts
easily backupable.

**Mike Schmidt**: Anything that you would add there Antoine?

**Antoine Poinsot**: No, it was a pretty good description.  Also, maybe trying
to raise your awareness that even if you're only using a single key, you could
always rely on implicit information, such as the absence of the corresponding
output descriptors, just to assume that you always ever use this key in single
key scripts.  But as the number of single key scripts augments, the number of
types of scripts that you have to bring forth to recover backup increases, and
it's also still always relying on an implicit information.  So, I would advise
always having an output descriptor even for non-complex scripting.

**Mark Erhardt**: Yeah, I guess that wasn't completely clear.  The xpub doesn't
tell you what type of output script it associates with.  So, even if you find an
xpub, you might need to try all types of outputs in order to find your funds,
and maybe a bunch of different derivation paths, because different wallets over
years have used different derivation paths, even for a single-sig.  And with an
output script descriptor, it would be very explicit on what keys are exactly
being derived and what output scripts they're being used for.

**Mike Schmidt**: Antoine, question for you in relation to Liana wallet and some
of the other work you guys are working on at Wizardsardine, do you plan to use
mini tapscripts in Liana?

**Antoine Poinsot**: Yeah, absolutely.  For now, we are still waiting on signing
devices support for taproot.  So, pretty much like we waited for miniscripts, we
need now designers to also support mini tapscript, but it's much smaller of an
upgrade.  But yes, we do definitely plan on using taproot.  Basically, if we
could, we would have done taproot-only since the beginning, because right now,
in using Liana, you are having multiple spanning paths.  So, you have one path
that is immediately available, and you have one to n additional paths that are
timelocks for recovery.  You probably don't want to have the recovery path hit
the chain before you actually need them, and that's what taproot enables.

For privacy reasons, for cost reasons, you probably don't want people to know
what are your timelocks, you don't want to be sticking out because you're using
special timelocks that nobody else is using.  So yeah, it would definitely be a
great improvement to Liana and we are definitely going to make use of it.

**Mike Schmidt**: It's great to see Bitcoin businesses involved with innovating
the technology and contributing to the technology, and in this instance,
Wizardsardine, Liana, and the work that you've done here.  We've highlighted in
the past as well the work that Brandon Black, Rearden Code, did at BitGo with
regards to their work on MuSig.  And so obviously, this is all a voluntary space
and you have the right to sit back and wait for things to come, but there's also
folks in there getting in there and making the changes that would help Bitcoin,
help their piece of software and their business.  So, applaud Wizardsardine and
company for stepping in and putting effort towards this.

_Eclair #2703_

Next PR we have is to the Eclair Repository, #2703.  This is a change that I
have a couple of quotes that I'll pull from the release notes and the PR itself,
"Some channels only have a few sats available to send but are not currently
disabled, leading other peers to try to use them and fail.  We now lower the
maximum HTLC amount when the balance goes below a configurable threshold.  This
should reduce the number of failed payment attempts and benefit the network".
And another interesting point from the release notes was, Eclair used to disable
a channel when there was no liquidity on the Eclair side so that other nodes
would stop trying to use it, but other Lightning implementations use disabled
channels as a sign that the peer is offline.  So in order to be consistent with
other implementations, Eclair now disables channels when the peer is offline and
signal that a channel has very low balance by setting the htlc_maximum_msat
value to a low value.

_LND #7267_

LND #7267 makes it possible to create routes to blinded paths within LND.  In
Newsletter #269, we covered LND's ability to support sending payments to blinded
paths and allowing receiving payments to paths where a single hop was hidden or
blinded.  And so now, you can actually create those routes to blinded paths, and
this brings LND closer to full support for being able to make blinded payments,
so that's good to see.

_BDK #1041_

The last PR for this week is to the BDK repository, #1041, "Add bitcoind_rpc
chain source module".  So essentially in BDK, there's the ability to have
different sources of blockchain data.  I believe they support Electrum and
Esplora as already baked-in chain sources, and now the Bitcoin Core blockchain
data is an option to the bitcoind_rpc as of the merge of this PR.  Murch, Robin,
instagibbs, Antoine, anything before we wrap up?

**Mark Erhardt**: I maybe have a question for instagibbs.  Sorry, I was looking
at something else for a moment when you brought up the Eclair thing.  I thought
that when you update the maximum HTLC amount, that triggers a channel
rebroadcast, and you can only do one of those every hour or so.  So, how
effective is that as a mechanism to signal that a smaller payment can be routed
through a channel, if you use the HTLC max amount as the cap to signal that your
channel is lopsided; and isn't that also a privacy leak?

**Greg Sanders**: Yeah, I mean I think you know as much as I do.  I haven't
touched the gossip really.  So, I mean it sounds reasonable what you're saying.

**Mark Erhardt**: Okay, sorry for the late reply, Mike.

**Mike Schmidt**: Yeah, there was a couple of things noted in that PR of ways to
signal the low liquidity, either a very large htlc_minimum_msat or a very low
htlc_maximum_msat, or just really high relay fees.  I can't answer your question
directly, but there was some discussion about the different ways to signal this.
I don't see any other questions, so we can wrap up.  Antoine, did you have
something to say?

**Antoine Poinsot**: No, I'm good.  Thanks for having me, and if anybody has any
questions, I'm also happy to answer them now or after in comments to the
podcast, whatever.  I'm more into the weeds of the implementation of mini
tapscript if anybody is curious, I guess.

**Mike Schmidt**: We do have a question, let's see.  Perhaps unrelated question,
"What is the UX importing a descriptor wallet BSMS file?

**Antoine Poinsot**: So right now, in Liana, what we use is just a text input,
so you would copy/paste a string of text to import the descriptor, to import the
wallet.

**Mike Schmidt**: Looks like that's it for questions.  Thanks to Antoine for
joining us, and Robin as our special guest, and instagibbs as our omnipresent
expert who can chime in, and as always to Murch, my co-host, and thank you all
for joining.  We'll see you next week.  Cheers.

**Greg Sanders**: Bye.

**Mark Erhardt**: Cheers.  Enjoy your lunch.

{% include references.md %}
