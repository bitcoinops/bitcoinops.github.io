---
title: 'Bitcoin Optech Newsletter #307 Recap Podcast'
permalink: /en/podcast/2024/06/18/
reference: /en/newsletters/2024/06/14/
name: 2024-06-18-recap
slug: 2024-06-18-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Hunter Beast and
TheCharlatan to discuss [Newsletter #307]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-5-19/381113747-44100-2-a548ec9d83d7f.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #307 Recap on
Twitter Spaces.  Today we're going to talk about a BIP around quantum safety in
Bitcoin; we have a PR Review Club around Bitcoin Core's indexes; there is a
major Core Lightning (CLN) release and a maintenance release for Bitcoin Core
that we're going to go over; and then, there's a slew of notable code changes as
well.  I'm Mike Schmidt, I'm a contributor at Bitcoin Optech and Executive
Director at Brink, where we fund Bitcoin open-source developers.  So, we'll go
to Hunter Beast.

**Hunter Beast**: Hello.

**Mike Schmidt**: Do you want to give folks a little bit of background on what
you do in the Bitcoin space, or have done and plan to do?

**Hunter Beast**: Yeah, sure.  So, I've been in the Bitcoin space since about,
well, specifically Bitcoin and not sincoins, I sometimes call them.  I've been
in the Bitcoin space since 2021.  Before that I was kind of in sincoinery.  I
worked on Filecoin and before that, various EVM projects.  But then I read The
Bitcoin Standard and it changed my perspective on a lot of things, and I got
really hard to work with at my sincoin job, and so I left about six months
later.  And I started getting into RGB, which is a smart contracts framework
that basically attaches to UTXO, like whenever a contract changes, the UTXO is
spent, and so then you know to get new contract data from your peer.  And after
that, or during that time also, I worked a little bit, just a little, on the
Ordinals project.  I made some contributions there, but I know people will
probably boo that, but I think I have good reasons for having contributed to it.
And also, nobody knew really, at least I had no idea how it would blow up and
result in a bunch of JSON just getting spammed onto the time chain.  It's kind
of silly, but you know, whatever.

Yeah, so right now, I'm turning my attention to like Bitcoin's quantum
resistance.  My favorite thing is to address Bitcoin FUD, and so it's kind of
what I've been doing my entire career in Bitcoin, at least to some degree, and
I'd like to continue doing that.

**Mike Schmidt**: Well, thanks for joining us.  Charlatan?

**TheCharlatan**: Yeah, I work on Bitcoin Core, and more specifically, I work on
the libbitcoinkernel project, which has the goal of eventually exposing and
shipping the validation parts of Bitcoin Core as a separate library.

**Mike Schmidt**: Amazing.  Thanks for joining us.  Murch, you want to say hi to
folks?

**Mark Erhardt**: Hey!  Yeah, I hope you can hear me now.  This is Murch, I work
at Chaincode Labs on the Bitcoin project in general, contributing to Bitcoin
Core and recently became a BIP editor.

_Draft BIP for quantum-safe address format_

**Mike Schmidt**: Jumping into the News section of Newsletter #307, we just have
one item, titled Draft BIP for quantum-safe address format.  Hunter Best, you
posted to Delving and the mailing list about a rough draft BIP for assigning v3
segwit addresses to a quantum-resistant signature algorithm.  Maybe to provide
some context for folks, what exactly are the concerns about quantum computing
with regards to the Bitcoin ecosystem, then we can go from there?

**Hunter Beast**: Yeah, so a common misconception is that Bitcoin is vulnerable
from, like, a mining standpoint, but it's not really because the algorithm that
-- I mean technically, yes, it is, but the algorithm that would be needed to
break Bitcoin mining, it scales differently than the algorithm that's used to
break signatures.  And so, the real low-hanging fruit for any quantum computing
activity, to be honest, is Shor's algorithm.  It was come up with during the
1990s, I think it was 1995, that Shor's algorithm was defined or specified, and
it essentially speeds up the factorization of primes, and large primes even.
Well, the size of the prime depends on how good your quantum computer is.  And
there's a variant of Shor's algorithm that can be used to break what's called
ECDLP, which is the Elliptic Curve Discrete Log Problem, and that's what
essentially makes it hard for classical computers to essentially break Bitcoin
in the same way that quantum computers could.  Yeah, is that a good explanation?

Well, essentially, signatures are the major concern here because in Bitcoin we
use secp256k1 and also, the keys that correspond to signatures are essentially
Bitcoin addresses.  And so, that's why my BIP focuses mostly on a specific kind
of address format.  Yes, Murch?

**Mark Erhardt**: Yeah, so just a short jump in.  Shor's algorithm is good at
finding large primes, I think, right?  So, a lot of our cryptography is based on
two extremely large primes being multiplied and creating a shared secret.  And
so, to factorize that, you have to find these very large primes, right?

**Hunter Beast**: Correct, it accelerates the factorization of large primes, but
it's slightly different when you're using it in elliptic curve cryptography.
But yes, essentially.  Large primes are generally used to secure RSA signatures,
whereas ECDSA signatures, they use kind of a different way of using prime
numbers.  But yeah, we focus on creating a new address format, called P2QRH.  It
kind of goes along with the other address types out there, like there's P2WPKH
or P2TR.  This one is Pay to Quantum-Resistant Hash, and I kind of proposed a
specific signature algorithm, but that was definitely challenged in a few
different discussions on the mailing list.  And so, this early on, I'm
definitely open what signature algorithm that should be used, and that's
definitely a topic for discussion, but there's definitely pros and cons for
using different algorithms.

Primarily, the primary consideration is signature size, although an additional
consideration is verification speed.  Signing and key generation aren't
necessarily as big a concern, because they aren't done by all the nodes on the
network.  But verification and signature size, signature size being an important
consideration, because Bitcoin charges based on how many bytes a transaction
uses.  Technically it's a bit more complicated than that, because of segwit, but
it's essentially like the Bitcoin fee model, which contrasts to sincoins out
there that use a gas fee model, which charges based on a unit of computation and
always drives me nuts when people confuse.  They call Bitcoin fees "gas fees".
I'm like, "No, that's not how Bitcoin works".  Anyway...

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: Yeah, I was going to ask, so you're basically trying to do
some foundational work to find or draw a line already into the future, where we
will want to have a quantum-safe address format and are laying the groundwork
for what that could look like.  So, what's your idea?  As soon as that is
defined, will some people start moving their funds there?

**Hunter Beast**: Well, of course, that depends on activation.  And so, I
specifically also included the term, QuBit in the soft fork, with a capital B.
So, qubit is a fundamental unit of quantum computing, but when it's used with a
capital B, a capital Q, that is a reference to a soft fork that I would propose
to activate P2QRH spending rules.  And it's up to the community whether we also
want to activate PTQRH ahead of PTQR, PTQR being a taproot-compatible version of
this integer algorithm, whereas PTQRH is really just scoped kind of similar to
P2WKH.  It's just not meant for the support for tapscript in a similar way.  And
the reason why I just wanted to do that was just to limit scope as much as
possible.  That's one thing I've learned as a software engineer.

But also, just even through discussions with people on Twitter and X, we've
learned lessons from how soft forks have rolled out before, or have been
proposed before, and sometimes they can be quite contentious.  And I just want
this to be a really straightforward, no-nonsense BIP, that basically upgrades
Bitcoin's quantum security and it doesn't really do anything else.  I don't want
to talk about, you know, if there is an increase in signature size, I really
don't want to talk about, say, increasing the segwit discount, for example,
which could be one way to make Bitcoin's transaction bandwidth to be the same.
That's not really quite as big a consideration in this BIP, just because even
though I did say I didn't want there to be a significant decrease in block
transaction density, regardless of that, that is much more secondary.  And if
there is a desire for that kind of thing, we just have to be aware of the
second- and third-order effects of that, of say increasing the segwit discount.
And that's like a separate soft fork.  That should be discussed separately, in
my opinion.

**Mike Schmidt**: It seems like discussions around quantum is that it is
definitely coming, but also, given your research into this topic, what does the
timeframe look like, in your opinion, because it seems like that opinion's very
wildly there and you've put some time into this, so I'm curious what you've
seen?

**Hunter Beast**: Well, the thing that really scared me was IBM had a Quantum
Summit, and actually I linked to this in my latest response to the thread on the
Bitcoin-Dev's mailing list.  There were two videos that I recommend people watch
that are linked in my latest post as a response to some feedback that was
received.  There was an IBM keynote, where they introduced IBM Quantum System
Two.  It is very slick and scary looking.  It looks almost like something out of
sci-fi, like HAL 9000-type stuff, and it looks very imposing and scary.

So, I looked into its specs and also Vlad Costea, I don't know how to pronounce
his name, but essentially he posted a PDF, like a link to a PDF, that was called
the Impact of Hardware Specifications on Reaching Quantum Advantage in the
Fault-Tolerant Regime.  And what that essentially means is that, well it
basically, in the abstract, it actually gave two numbers for how many qubits you
would need in order to break ECDLP using Shor's algorithm variant.  And the
concerning thing to me was, they estimated based on how long it would take to
snipe a transaction from the mempool, like say in an hour or a day; they thought
an hour or a day would be an adequate target.  But even if they could break an
address in a year, that would be significant, right, because then we'd know,
well okay, Bitcoin's top addresses are vulnerable.  Well, technically, I should
couch that in Bitcoin's top P2PK addresses, and also any addresses that are
reused from.  So any addresses that are reused, where you've spent it before and
then you receive money again, those two conditions, reused addresses and P2PK
addresses, those are both vulnerable to quantum attack.  Yes, Murch?

**Mark Erhardt**: Yeah, so generally the idea is that if someone succeeds at the
quantum attack, they would be able to recover the private key from the public
key.  And the public key is known for all the P2PK addresses, for all the P2TR
addresses, and also, of course, for any addresses that have been spent from
before where the pubkey was then revealed.  So, there's about, well, the
Deloitte paper you linked to said something like 25% of all coins in 2020, I
think that Pieter in a Stack Exchange post has an estimate of like 40% of all
coins, are vulnerable to this potential quantum attack.  So, how does your new
address scheme address this?  Do funds automatically get spendable with your new
address scheme?

**Hunter Beast**: No, because I believe that would require a hard fork for every
address, like say every P2WPKH address, which actually I mean the thing is, PKH
addresses are already quantum resistant.  So, what this would have to do
essentially, somehow people would need the keys to -- there would need to be a
way to generate keys that correspond to secp keys.  Vitalik has actually
proposed this, like there was some kind of zero-knowledge proof that he wanted
to do based on BIP32 seeds, I believe.  And because BIP32 generates addresses
from seeds, you could just go one secret up to the seed itself and then use that
as a zero-knowledge proof to prove that you own those funds.  And a
zero-knowledge proof would, of course, be quantum resistant, I believe.  Like,
BLS signatures, I think, are known for being quantum resistant, though maybe
Adam would correct me on that.

But yeah, this BIP is actually scoped more towards just making addresses, new
addresses, that are safe for people to move their funds to.  And that is,
without a doubt, a soft fork.  It's the same way that we created taproot
addresses.  And so, we can introduce a new signature algorithm, because we
introduced schnorr signatures with taproot and that proved that.  And then
similarly, we can introduce another entirely novel signature algorithm.  And in
fact, original Bitcoin even specified a few different signature algorithms
before they decided, "We'll just stick with secp256k1, which I think was very
smart, because that does raise the bar slightly at least to how fast a quantum
computer can actually decrypt an address, but only marginally so, because Shor's
algorithm scales exponentially, which is definitely a cause for concern.  Murch,
do you still have another question?

**Mark Erhardt**: Well, I was wondering, so I guess you wrote that this is the
first step, having an address type that is safe against quantum, but surely a
comprehensive response to a thread of quantum computing would need to address
that something like 25% to 40% of the supply will be up for grabs.  And probably
it doesn't matter that much if your coins are safe if 25% to 40% of the supply
is not, and therefore people can crash the market or just play games with the
exchange rate.  So, is that just a future work?  Have you thought about that
already?

**Hunter Beast**: Yeah, I deliberately excluded that kind of consideration from
the BIP because, and I probably should have gotten into this some more, just
because that kind of change would be, like for example, let's say we disabled
the capability to spend, like we made it a consensus rule, P2PK addresses can no
longer be spent from.  We're just going to assume that anybody using those has
already lost those keys and we're just going to permanently lock up that supply.
There's also like, okay, then do we do the same for reused addresses that might
not be as kosher, right?  Because you could come up with a reused address and
reuse the heck out of it even today in modern wallets, and that's just a thing.
And so, maybe just scoping into disabling P2PK could be a possibility.  But
then, you have to wonder, what if Satoshi is still around, what if he's just
laying low?  You never know.

So, I don't know if it's a good idea to open this up to that.  It's almost like
philosophical questions at that point.  It gets a bit more, I don't know, I
think it takes a lot more community discussion to arrive at, and I think that's
just out of scope for the BIP that I wanted to establish.  I wanted to keep this
super-uncontroversial, like straightforward, like we're not disabling spending
rules, we're not increasing the block size, we're just introducing a new
signature format and a new address format, and that's it.  Does that make sense,
Murch?

**Mark Erhardt**: Yeah, I think that's fair to keep that as a separate issue.
And actually, I think if we did have an output type that is thought to be
quantum resistant, as quantum attacks seem to move closer or become an imminent
threat, you could have some sort of switchover period where you say, "Look,
we're going to lock spending from P2PK or reused addresses after a year or so,
move your funds into quantum-resistant addresses in the next year.  Sure, that
would still have the possibility of confiscating coins from some people that are
unable to comply within that timeframe, but that would at least make it anywhere
palatable, I think.  Yeah, so anyway, how far have you gotten with your BIP?
What is it that you're looking for from our listeners, or the level of input?

**Hunter Beast**: Yeah, so it's still very early on.  I haven't even made a PR
to BIPs, though I actually wanted to wait until this call to ask, like, should
I, Murch, should I make a pull request?  Is it ready; is this time?  Right now,
I still would like a little bit more feedback on the mailing list, on the
arguments made.  Please read over the BIP and just in the back of your mind
think, am I missing something?  Is there something missing from the motivation
or just the rationale, the security assumptions, anything that I haven't
addressed fully, and there are definitely some things that I need to address
still, I'm making notes?  So, that's definitely what I want to know.  But maybe
in about a week or two, maybe we can make a PR.  Does that make sense, Murch?

**Mark Erhardt**: Yeah, I skimmed it a little.  I think that it still needs to
be filled in, in a few spots.  And I'm going to leave some review comments on
your PR.

**Hunter Beast**: Well, I haven't made a PR, but do you want me to make a PR?

**Mark Erhardt**: Sure.  Let's take this offline.

**Hunter Beast**: Okay, sounds good.

**Mike Schmidt**: Well, Hunter Beast, thank you for joining us today.  You're
welcome to stay on as we go through the rest of the newsletter, or if you have
other things to do, you're free to drop.

_Don't wipe indexes again when continuing a prior reindex_

Next section from the newsletter is our Bitcoin Core PR Review Club monthly
segment, where we highlight a PR Review Club discussion around a specific PR.
And this week, the PR is, Don't wipe indexes again when continuing a prior
index.  Charlatan, you opened up PR #30132 last month.  It was merged last week,
I believe.  Maybe as setting the stage for the details of this PR, maybe it
would make sense for you to explain the different types of indexes in Bitcoin
Core and which ones are optional, and then we can get into the PR details.

**TheCharlatan**: Yeah, sure, I'll start there.  So, Bitcoin Core has indexes
for blocks.  So, for every block, it maintains an entry in an internal database
that keeps track of some basic block header information.  And then, we have
another database that tracks the UTXO set, so the current set of spendable coins
in Bitcoin, and we also call this set the chain state.  And then, we have three
optional indexes.  These are the block filter index, which is used for light
clients; we have the txindex, which gives additional indexing information, for
example, for server software that's relevant for wallets, where we want to look
up txes faster; and we have the coinstats index, which gives statistics on
what's going on in the blockchain.  And this PR is about the latter three
indexes, which are all optional and can be activated by the user himself.

**Mike Schmidt**: And how are those optional indexes treated differently from
the required indexes in the context of a restart or interruption?

**TheCharlatan**: Actually, not that differently from the ones that are always
built in.  So, the main difference was something that we uncovered while
reviewing another PR.  Let's get into that actually, because I should give the
full context for this.  So, while working on the kernel project, a big part of
the work is getting rid of global states.  And some of that global state was
just a boolean value that tracked if a reindex was going on inside the node.
And a reindex is basically something that we do when something is wrong with the
database, and we hope we can recover it by basically wiping away the database
and rebuilding everything from the block files we have stored on disk.  And we
wipe all five databases that we have, so the three optional indexes, as well as
the block index and the chain state.

What we did notice while reviewing this, the globalization PR, was that in some
cases, we needlessly wipe the indexes again, even though we could build on the
prior data if a node was busy being restarted.  So, if you reindex the database,
meaning you wipe it away, and you restart during your reindex, then you can
continue from where you left off on the reindex and actually don't have to wipe
away everything again.  And we didn't do this prior to my PR for the three
optional indexes.  And then with the PR, we can now continue from where we left
off if we restart during a reindex.

**Mike Schmidt**: Am I right to understand that the two required indexes were
already being persisted during a restart, but the optional ones were not being
persisted, so that when you restarted, you'd have to essentially start all over
again for those optional indexes; is that right?

**TheCharlatan**: Yeah, exactly.  So, besides not being efficient, it was also
not consistent between the indexes.  And I feel like this is actually a nice
case, where it shows where we refactor some really ugly codes, and we notice
that there might be some inconsistencies with the logic handling it just because
it's probably too complicated to notice all the edge cases.

**Mike Schmidt**: Murch, do you have questions?  Murch gives a thumbs up.  All
right, great.  Yeah, I think a lot of people think that refactoring is just
maybe moving this around and that around, and it sounds like there's actually
advantages to somebody taking a fresh look at some of this, and it sounds like
you've uncovered maybe not something that would be classified as a bug, per se,
but definitely a performance improvement in the scenario.

**Mark Erhardt**: Actually, I have a question.  In the Review Club you had
planned question 4, which was, "What sort of risks might be happening or be
introduced if we do not flush the partial indexes when we restart the node?"
So, would it be possible that it sort of is unclean or incomplete, or if we
don't start from scratch on restart?

**TheCharlatan**: So, the indexes keep track of what their last view of the
chain was.  So, they basically keep track what the last block they've seen was.
And by doing that, they always know from which point on to continue.  Does that
answer your question much?

**Mark Erhardt**: So, it sounds like an outright win.  If you had a partial
reindex and your node was stopped in between, you simply start from where you
were and only have to do the remainder, instead of starting from scratch.  So,
clean win; does that sound right to you?

**TheCharlatan**: Sounds right to me.

**Mike Schmidt**: Charlatan, thank you for joining us.  You're welcome to stay
on and talk about some of these Bitcoin Core PRs if you're interested later in
the newsletter.  Otherwise, if you have other things to do, you're free to drop.

**TheCharlatan**: Sure, thanks.

_Core Lightning 24.05_

**Mike Schmidt**: Moving to the Releases and release candidates section this
week, we have two.  One is a major release for Core Lightning, 24.05.  There are
a few different improvements and fixes here that I'll run through.  There's
improvements to CLN for using a backing node in pruned mode; there is a new
feature that allows CLN plugins to use the check command to validate RPC
parameters; there's better reliability with a new chain lag offset when doing
HTLC (Hash Time Locked Contract) calculations; CLN also added some dynamic
adjustments to the feerate security margin multiplier to ensure that channel
transactions pay enough feerate that they will be confirmed; they've also added
more robust routing for offer-related invoice requests when CLN can't find a
path, by actually just opening up a direct TCP/IP connection to the requesting
node; CLN also fixed the overpayment issue that can happen when doing
cooperative channel closes; and there's also some more smaller fixes and
enhancements, so you should check out the release notes for this release.

I apologize to the CLN team for not reaching out to have somebody come on and
walk us through this sooner.  I only messaged a few folks this morning, so
apologies that that team wasn't able to relay this and celebrate this release
with us.  Murch, any comments on the CLN release?

**Mark Erhardt**: I thought there was also a couple interesting developer things
mentioned in the release notes.  One was that there is now a check endpoint that
you can use to validate config options before setting them, and a bunch of the
gRPC methods were backfilled and had documentation improvements, if I understand
that right.  But again, it might be nice if we had a member of their team walk
us through what excites them in their release.

_Bitcoin Core 27.1_

Bitcoin Core 27.1 is a maintenance release.  Murch, I'm not sure if there's
anything, being a Core developer yourself, that you'd like to outline here,
other than encouraging folks to upgrade?

**Mark Erhardt**: So, I think there is.  We've talked about this a few times,
but there's a good opportunity, as usual, to explain the release cycle of
Bitcoin Core.  So, Bitcoin Core aims to release a major version about every half
year.  There are additional minor releases once or twice, sometimes even zero
times, between these major releases where bugs are fixed.  These generally do
not introduce any new features.  And so, 27.1 is one of those minor maintenance
releases, which just fixes about a score of bugs in miniscript, RPCs, GUI
indexes, tests, and so forth.  Also, maybe in this context a reminder, multiple
Bitcoin Core contributors are working towards making disclosures about
vulnerabilities in old releases.  So, these minor releases do bug fixes.  If
you're concerned about bugs in major releases of the past, at least update to
the latest minor release because it will have some fixes.  But better yet, you
should be on one of the last two major releases in order to have a maintained
release, otherwise there might be bugs in it that are known but not fixed.

**Mike Schmidt**: Notable code and documentation changes.  If you have a
question about what we've covered in the newsletter so far, or if you think
you'll have a question about some of these Notable code changes, feel free to
request speaker access or post a comment in the thread here, and we'll try to
get to that at the end of the show.

_Bitcoin Core #29496_

Bitcoin Core #29496.  Murch, I think you were going to celebrate this one.

**Mark Erhardt**: Yeah, so in the upcoming major release, Bitcoin Core 28,
Bitcoin Core will implement BIP431.  BIP431 proposes a new mempool policy, which
treats transactions that set v3 as standard.  These are so-called topologically
restricted until confirmation transactions.  And the idea here is if you create
a transaction and make it v3, you're requesting from the network that it is
topologically restricted.  So, nodes that implement BIP431 will restrict the
number of children such a transaction can have and also the size of the parent
and child transaction.  So, TRUC (Topologically Restricted Until Confirmation)
transactions, we've talked a bunch about this here, will only be allowed to have
10,000 kvB, and if they have a parent transaction, they will only be allowed to
have 1,000 kvB.  And each TRUC transaction can only have one parent or one
child.  So, they only appear in packages of two transactions.  The idea here is,
of course, that it makes it a lot easier to consider potential pinning attacks
and, well, generally attack surface for pinning if the transactions are
topologically restricted.

So, this looks like it's going to roll out in Bitcoin Core 28.  We'll have to
see what other implementations are also interested in BIP431.  My money would be
on a bunch of Lightning implementations also implementing BIP431.

**Mike Schmidt**: And if folks are maybe not familiar with the TRUC acronym, and
maybe that's sounding like something new, we've talked a bunch over the last
year plus about v3 transaction relay.  So, this is just a different name for
that.  And Murch, I think, did you come up with the name Murch?

**Mark Erhardt**: I did not, I think, or I helped!

_Bitcoin Core #30047_

**Mike Schmidt**: Murch, I think you're going to take this one as well, Bitcoin
Core #28307.

**Mark Erhardt**: Yeah, so this deals with a consideration concerning bech32 and
bech32m.  Bech32 generally was designed to be safe to up to 90 characters. The
checksum guarantees detection of up to four errors.  And now recently, silent
payments was proposed, and silent payments will use two public keys in the
silent payment address, and this does not fit within 90 characters.  So, this is
establishing some of the groundwork by allowing the limit to be exceeded.  So,
for bech32, proper use of bech32, the limit is still 90, but essentially silent
payments will use a variant of bech32 that allows a longer character sequence.
This doesn't break the scheme, it just makes the guarantees softer.  So, I don't
know exactly, but I expect that it might only guarantee to discover two or three
errors instead of four.  But yeah, anyway, this is just a fairly low-level
change in how we handle bech32 addresses in Bitcoin Core.

_Bitcoin Core #28307_

**Mike Schmidt**: So, that was actually Bitcoin Core #30047, for those scrolling
along in the newsletter with us, was the bech32-related character limit.  And
then we also have Bitcoin Core #28307.  Murch?

**Mark Erhardt**: Sorry.

**Mike Schmidt**: The one before.

**Mark Erhardt**: Did you mix it up or did I mix it up?  Anyway, okay, yeah, the
one before.  Sorry!  Yeah, #28307 fixes a bug concerning redeem scripts.  Redeem
scripts appear in P2SH, and now apparently, the P2SH redeem script was limited
to 520 bytes in a bunch of the transaction-building functions, and that was
erroneous because that's not actually a consensus limit.  But Bitcoin Core sort
of made it difficult to create transactions that exceeded that limit anyway.
So, this bug was fixed, in that it would allow redeem scripts to be bigger than
that.  However, also Bitcoin Core still forbids you to create redeem scripts
that are bigger because it would constitute a downgrade in compatibility.  So
now, it just throws an unsupported operation error, rather than actually
allowing the larger redeem scripts.  Yeah, anyway, this is just a little
housecleaning.  Either way, this is hopefully soon fairly irrelevant because the
Bitcoin Core wallet work is moving towards descriptive wallets, and this would
be something affecting legacy wallets.

**Mike Schmidt**: Murch, can you explain what you mean by "downgrade in
compatibility"?

**Mark Erhardt**: Sure, so if you create a wallet and then try to use it with an
older version of Bitcoin Core, and you had created one of these redeem scripts
with more than 15 pubkeys, you would have the issue that the old Bitcoin Core
would not be able to handle this output and consider it invalid or failed during
transaction building.  So, if you happen to use the same wallet that you created
with a newer version in an older version of Bitcoin Core, you would have an
incompatibility.  And then to make it safe, you'd have to put in downgrade
warnings and restrictions.  So, I guess the implementer thought that since this
was not really a demanded feature, it would be easier to fix the bug, but still
restrict the use of it.

_Bitcoin Core #28979_

**Mike Schmidt**: Last Bitcoin Core PR this week, #28979, which is actually a
documentation PR for the sendall RPC.  Murch, do you want to get into that?

**Mark Erhardt**: Sure.  Actually, it's more than that.  It's, on the one hand,
a documentation improvement for the sendall RPC.  Sendall is an experimental RPC
on Bitcoin Core that allows you to sweep a wallet completely, or if you filter
the UTXOs by, for example, setting a number of minimum confirmations or maximum
amount in UTXOs and so forth, you can sweep just this filtered subsegment of
UTXOs.  The correction that is added in the documentation here is that sendall
actually does spend unconfirmed change outputs.  Previously, I think it was
stated that it does not spend any unconfirmed UTXOs, but that was referring to
foreign UTXOs only.  So, the correction is it does spend your own change even
while it's unconfirmed.

The behavior change that is also included in this PR is, if you are spending any
unconfirmed UTXOs with the sendall RPC, it will now apply ancestor-aware
funding, as in if there's a fee deficit because there are parent transactions
that pay a lower feerate, then the new transaction that you're trying to chain
off of them, this will now automatically also bump the parent transactions to
the feerate that is requested for the new transaction.  So, if you're trying to
build a sendall transaction with 20 satoshis per vbyte (sat/vB) and you have a
parent transaction that only paid 10, it'll automatically add fees to bump the
parent to 20 sat/vB as well.

_Eclair #2854 and LDK #3083_

**Mike Schmidt**: Thanks, Murch.  Next PR is actually a couple of different PRs
from two different implementations.  We have Eclair #2854 and LDK #3083.  Both
of those PRs implement BOLTs #1163, and BOLTs #1163 is an update to BOLT4, which
is the part of the LN spec that covers onion routing.  There is a channel_update
field and an onion failure message, and those channel_update fields, when
they're in an onion failure message, are a, "Massive, gaping, fingerprinting
vulnerability".  And so, by applying a channel_update received from a payment
attempt, you may essentially reveal that that you are the sender.  So, obviously
that is bad for privacy.  So, BOLTs #1163 was opened last month to the spec as
an update.  And in response to that, also in the last month, both Eclair and LDK
have now implemented that, and that's what's covered in this set of PRs this
week.

_LND #8491_

Next PR, LND #8491, which allows LND users using the cli to be able to specify
the min_final_cltv_expiry_data for the addinvoice and addholdinvoice RPC
commands.  The CLTV expiry delta, as a reminder, is the number of blocks that a
node has to settle a stalled payment before that node could potentially lose
money.  So, higher CLTV expiry delta values allow for more safety as they give
an LN node a bit more time to get an HTLC refund transaction confirmed onchain,
before that particular node is at risk of losing funds.  But on the flip side,
higher CLTV expiry delta values can also put a node at more risk regarding other
types of potential issues concerning channel jamming and other attacks.  So,
because there's sort of this balance there in this value and there's not an
agreed-upon default for CLTV expiry delta values, different implementations have
used different values and in the case of this PR to LND, they're even allowing
users to provide a custom CLTV expiry delta value.

_LDK #3080_

LDK #3080, that adds a create compact blinded path method, which allows someone
calling that to decide whether to use compact blinded paths or not.  So, what
are compact blinded paths?  Well, those are blinded paths that use short channel
IDs (SCIDs) instead of the full pubkeys for smaller serializations, which could
obviously be beneficial in a QR code that can't encode a ton of information.  So
for example, blinded paths are compact for short-lived offers and short-lived
refunds, and blinded paths are not compact for long-lived offers or long-lived
refunds.  And this is because compact blinded paths use that SCID, and that's
actually a reference to a funding transaction, and that ID may actually become
stale if the channel is closed or if something like a splice occurs.  And so,
there's sort of these two different ways to allow if you're using a compact
blinded path or not, and it sort of depends on, I guess, your use case if you
think it's going to be a longer- or shorter-term duration.  Any comments on LDK,
Murch?

**Mark Erhardt**: Sorry, I don't really know anything about this.

_BIPs #1551_

**Mike Schmidt**: Well, something you do know a lot about is the BIPs
repository.  So, we have BIPs #1551, and maybe you want to dive into that as a
BIPs maintainer.

**Mark Erhardt**: Sure.  So, we talked last week already with Matt, and if you
want to hear all the details about that, maybe just jump into the Recap #306.
But this is the corresponding BIP to the BLIP that we discussed last week.  So,
Matt wrote a BIP to describe how we could have DNS payment instructions, as in
sort of a BIP21 sort of payment instruction, that is permanently served from
your DNS records of your domain.  The big advantage of that, as I understand it,
would be that DNS records are cached at multiple different layers in the
internet.  And so, when you ask for DNS records, it might be served from
somewhere along the way, but the recipient would not learn your IP address
directly as they would, for example, if you ask an HTTP server to serve you some
well-known data from the website.

The other big advantage is that DNS records are signed, and therefore, even if
you get them served from someone else, it is hopefully clear that this is the
correct DNS record from the original domain.  Either way, the idea is that you
can basically just pack a text file into your DNS description and then anyone
could grab that and start sending you BOLT12 offers, or hopefully silent
payments, or a permanent onchain address that hopefully times out very quickly
and then is replaced.

**Mike Schmidt**: Yeah, very cool, given the increase in silent payment interest
and adoption as well as offers.  Am I right to understand that you could provide
those because it's going to be a BIP21 URI, so you could provide a silent
payment and offer and just kind of leave those there for people to generate
addresses or pay you via offers?

**Mark Erhardt**: Right, so silent payments and BOLT12 are static in the sense
that every time you interact with them, you create a new onchain address for
silent payments; or for BOLT12, it basically just tells you how to contact the
recipient node and ask for an invoice, and then you get an invoice via onion
messages.  So, they are permanently correct and nobody will be able to tell that
you continued to interact with the same recipient; whereas, if you also serve a
static address that is of the regular Bitcoin address type, that would of course
incur address reuse.  So the idea is, if you serve a regular address there, a
Bitcoin invoice address, so to speak, you should have a very short timeout on
your DNS record and refresh that address whenever you see a transaction paying
to that address, in order to curb address reuse.

But yeah, there is some ongoing discussion on whether or not BIP21 should be
updated in regard to silent payments and offers, as BIP21 was specified, I
think, 12 years ago and is final right now.  So, usually BIPs that are final are
beyond being updated, but in this case, that might make sense.  So, if people
have any strong feelings about that, there's a mailing list thread and an open
PR in the BIPs repository where we would love you to chime in.

**Mike Schmidt**: Very cool.  I don't see any requests for speaker access or
questions, so we can wrap up.  Thank you to Hunter Beast and The Charlatan for
both joining us and explaining their work today.  And thank you to Murch, my
co-host.  Good to be back.  And thank you all for listening.  See you next week.

**Mark Erhardt**: Cheers.

**Mike Schmidt**: Cheers.

{% include references.md %}
