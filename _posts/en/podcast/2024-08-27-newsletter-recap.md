---
title: 'Bitcoin Optech Newsletter #317 Recap Podcast'
permalink: /en/podcast/2024/08/27/
reference: /en/newsletters/2024/08/23/
name: 2024-08-27-recap
slug: 2024-08-27-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Bob McElrath and moonsettler to discuss [Newsletter #317]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-7-27/385409292-44100-2-60d9a07ccd15f.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #317 Recap on
Twitter spaces.  Today, we're going to be talking about a simple
anti-exfiltration protocol, we have eight interesting software updates that we
highlighted from the Bitcoin ecosystem, and then we have our weekly release and
notable code segments as well.  I'm Mike Schmidt, I'm one contributor at Optech
and also Executive Director at Brink, funding Bitcoin open-source developers.
Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs explaining Bitcoin.

**Mike Schmidt**: Bob?  Put Bob on the spot.  Moonsettler?

**Moonsettler**: Hello everyone, I'm Moonsettler, I like to play with
cryptography.

**Mike Schmidt**: Well, thanks for joining us.  If you're following along, this
is Newsletter #317.  We're going to go through the newsletter in sequential
order, starting with the News.

_Simple (but imperfect) anti-exfiltration protocol_

We have one News item this week titled, "Simple (but imperfect)
anti-exfiltration protocol".  Moonsettler, you posted to Delving Bitcoin a post
titled, "Non interactive anti-exfil (airgap compatible)", which is an anti-exfil
approach for airgapped signing devices using PSBT.  In Newsletter and Podcast
#315, we covered the Dark Skippy seed exfiltration attack.  Perhaps some of this
recent discussion motivated your post, or were you already working on this,
Moonsettler?

**Moonsettler**: Yeah, I actually started working on it sometime in 2023,
December.  I think I made the first still bad version of the gist in December 8.
And by December 11, I realized I have to incorporate extra entropy, the nonce
extra.  So looking back, it's an interesting history of tinkering with it.  But
as it turns out, the idea is not super-new.  So, these nonce exfiltration
attacks have been known for a very long time, and a lot of people thought about
them and talked about them along the years.  And it turns out that this version
of the anti-exfiltration protocol is very, very similar to something that Greg
Maxwell proposed in 2014.  And also, it turned out that the low-bandwidth
exfiltration is not as impractical as I thought.  So, Pieter Wuille has pointed
out that it's actually more economic and more practical than most people think,
using these forward error correction codes, also on the same Delving thread.

So, I also included later an anti-exfil protection level classification
proposal, let's say, where level 0 is of course no protection.  That's the
default if your device or your software does not implement RFC6979.  That means
that you can't really tell, looking at the signature, if it's leaking your
private key immediately.  People need to understand that if the attacker knows
the nonce, or knows the basis of the nonce somehow, and it is tweaked with
something derived from the transaction characteristics or anything that he can
observe onchain, then it's perfectly solvable for him and he will immediately
learn the private key.  And most people actually use HD wallets, and the way HD
wallets generate the private keys is if the attacker also has knowledge of the
master public key, then he can generate all the private keys, the master private
key as well, if he learns any of the private keys on a non-hardened wallet.
That means basically, if there is no protection whatsoever and the device is
malicious, then it can immediately leak the secret.

What Dark Skippy did, because most people think that this is not so bad because
it would create a race condition, if the attacker learns the private key, then
he has to try to double spend and try to steal the funds that way.  That's when
people actually look at the transaction and the mempool when they are spending,
so they are more alert.  And if this happens to anyone, people will talk about
it, they would figure it out that something went wrong with the signing, other
people would immediately stop using that signing device and probably the attack
would be pretty contained in the amount that they can steal, if they tried that
way.  Dark Skippy introduces a way to actually leak the seed phrase.  So,
instead of leaking that private key with a chosen nonce, it leaks the seed
phrase and can do it with a single signature.  And the issue with RFC6979 is
nobody's actually checking that nonce generation each and every time they sign a
transaction.  So, this is good for factory acceptance test and user acceptance
test, you can test them.

In theory, an attacker can choose to attack with a low probability.  So, that
means they can generate the correct signature 99 times out of 100, and then
randomly, or maybe even using the certain transaction fields to determine what
is the time in the future of the attack in the future.  So, it's not a perfect
protection.  It's something, it enables some testing, it makes the attacks not
likely to be always on.  And so, I classified it as protection level 1, if you
use a deterministic nonce, like RFC6979.  And level 2 would be when there is a
verifiable nonce tweak with externally provided entropy, that a cosigner, or
more likely a companion of an open-source software wallet.  Can you hear me or
my app crashed?

**Mark Erhardt**: Yeah, we can hear you.

**Moonsettler**: All right, so verifiable nonce is level 2, and this anti-exfil
proposal is actually level 2; in retrospect, I would classify it as level 2.
So, the problem with this is it provides less protection against evil maid
firmware attacks than I previously thought.  Like I said, these low-bandwidth
leaks are actually more practical than I first thought.  And nevertheless, it
stops if either the software or the signer is not malicious.  So, that's the
condition for it to work.  It will stop immediate catastrophic leaks of the
master private key or the seed phrase.  And it still allows for some
low-bandwidth leaks via chosen R, unless the generation of Q, which is the inner
nonce, is actually verified from time to time.  And if someone has an AirGap
signer that they use very infrequently and they actually update the firmware
from time to time, maybe each and every time before they use it or every second
time they update the firmware and/or verify the generation of the nonce, a bit
of test seed, in that case it could be pretty good.

The level 3 is the negotiated nonce, which pretty much closes the exfil channel,
with the caveat that you can still do a one-bit nonce exfiltration in theory
with negotiated nonce; but for that, the signer would have to fail every second
transaction.  It would probably fail 50% of the signings.  And I think people
would notice that.  So, people would notice if the signer is very unreliable and
doesn't want to sign.  So, I would say level 3, we can say that it fully closes
the exfiltration channel.  However, it requires multiple rounds of
communication.  Yes?

**Mark Erhardt**: Right, so level 3 is what BitBox does right now?

**Moonsettler**: I believe so, and I think -- what is the Blockstream signer?
Jade as well, right?

**Mark Erhardt**: Yeah, that might be true, I don't remember.

**Moonsettler**: Yeah, so the problem was, people have been saying that everyone
should do level 3 anti-exfil, but others pointed out that some people insist and
like the idea of airgapped signing.  And so, level 3 is not really compatible
with airgapped signing, and that means this level 2 protection level, verifiable
nonce tweak, might actually serve a purpose, like have enough utility for people
to implement, because it does not make the UX worse and it offers better
protection than simple deterministic nonce.

**Mark Erhardt**: Right, so it would be combinable with the regular one-trip
signing currently employed, and it would not add another round-trip, so you only
would have to go to your AirGap device a single time; whereas with multiple
round-trips, that would be, of course, pretty annoying.  You have to export it
on your hot device, import it on your AirGap, do one step, export it again,
import it on the hot device again, go back to the AirGap device a second time,
which makes it a lot more painful to have an AirGap device.

**Moonsettler**: Yes, this would not make the user experience worse.  And it
also makes, because the attack becomes low bandwidth, the theoretical attack
that is open becomes low bandwidth, it makes it very likely that it will be
always on.  And if it's always on, it's pretty simple to catch them.  Like I
mentioned with the test seed, with the test private key, known by any
open-source software, one can actually catch an evil device or an evil firmware
that is trying to exfiltrate the seed this way.  So, I believe it is an
improvement, but it is true that it does not theoretically completely close the
channel.  However, it's a very low-hanging fruit because it does not make the UX
worse.

**Mark Erhardt**: Cool.  Do you want to get a little bit into what mechanism it
is that you use, or do you want to keep it high-level?

**Moonsettler**: We can get a very little bit into it.  So, the idea is that you
would require some extra entropy from someone that will verify the generation of
the signature, or at least the generation of the nonce, in a way that you do not
actually have control over what the R point will be in the signature, because
you have to incorporate this external data.  And for example, the way that the
internal, let's say I call it Q, that's basically the internal nonce, the
internal deterministic nonce, the way that is generated since we started to play
a little bit with implementation, some demo implementation with, let me --
scgbckbone, who works at Coinkite.  I'm very excited that they actually want to
demo this out and make a proof of concept this early without a formal
specification.  It really actually helps.  So, as we started trying to make a
working code for it, we figured out that probably the generation of Q could be
exactly the same as BIP340 nonce generation.

BIP340 nonce generation can incorporate external entropy, and that part is
pretty much equivalent to what is described in the gist for generation of Q.
The problem is that right now, the internal signing in libsecp256k1 is very
coupled with this nonce generation function.  And one can hack through it but
it's not really that helpful, because at that point, one can't really say that
they use the library to generate a signature.  So, that library probably needs
to be extended for this to work in a standard way.  And for that, this is going
to need a formal specification.  But what I'm trying to say here is that –

**Mark Erhardt**: So -- sorry, go ahead.

**Moonsettler**: Okay, you can ask a question maybe.

**Mark Erhardt**: Yeah, let me quickly try to sum up the understanding.  So, the
idea would be that, for example, the hot wallet provides a seed for the entropy
for R, or a commitment maybe, and the hardware signer or the AirGap device would
have to incorporate provably this additional entropy in order to create the
signature.  This has already been provisioned in BIP340, which is the schnorr
signatures deployed with taproot.  And therefore, it would be easy to do in
combination with P2TR spending, but it's not currently supported properly in
libsecp, right?

**Moonsettler**: It's not easy in the context that it is very coupled right now.
So, right now you have in this proposal an internal nonce, which is Q, and an
external nonce, which is K, and K is actually Q tweaked with a commitment to the
public key, the message, and this nonce extra that is provided by the software.
And the software can very easily verify this.  In fact, what would happen is
that the signing device would not return a valid signature in this proposal.  It
would return a signature that is incorrect by the standard, and the software
wallet would make it correct by calculating the proper R by tweaking Q, capital
Q, tweaking with the value of the message and the nonce extra that is provided;
the software wallet knows all of that.  And basically, it would calculate the
larger S signature on the software side, but the signing device has to use K.
It has to know K internally and only the signing device can know K.  So, nobody
else can know K.  And the relationship, the working current relationship between
the internal nonce and this external nonce is what gets verified, and that
ensures that the high bandwidth, you can choose any R basically, because it will
be very simple mod to choose really any R.

**Mark Erhardt**: Right, so because the final signature is actually combined on
the hot device, there is both the entropy from the AirGap device and there is
the entropy that was committed to by the requester of the signature?

**Moonsettler**: The software would expect that extra entropy is incorporated.
But if it would be malicious, the signature is constructed in such a way that it
is not weaker than the previously constructed signature.  So, it still
incorporates the message, it still incorporates the private key, so it's not
like the software can attack the signing device this way.

**Mark Erhardt**: Oh, interesting.  Yeah, I was wondering how you would prevent
that the airgapped signer cancels out the commitment, but if the hot device is
actually the one that combines everything, that makes sense.  And now I was
wondering about the other direction.  So, if it's impossible for the hot device
to attack the AirGap device as well, that sounds pretty good.  I also saw that
Rearden joined us as a speaker, maybe he wants to jump in.

**Moonsettler**: Yeah, maybe you can explain it better.

**Brandon Black**: I just wanted to clarify one specific thing, Murch, which is
that this is not directly compatible with the BIP340 signing as defined.  The
extra nonce data that's accepted in BIP340 cannot be this data that comes for
Moonsettler's Protocol here.  Other than that, I think the explanation's been
good.  Did you guys talk about how this has some similarities to the way that
MuSig2 nonce commitments are done?

**Moonsettler**: Not yet.

**Mark Erhardt**: We have not.

**Brandon Black**: When I was reviewing this proposal from Moonsettler, I
noticed that the combination of the two nonces here has echoes of the MuSig2
nonce combination.  And so at first, I talked to Moonsettler back and forth, and
can we just use MuSig2 nonce commitments? And one of the things that we figured
out here is that the proposal that Moonsettler has here is compatible with both
ECDSA and the schnorr signing, because the signing device ends up knowing the
combined K, and that is required for ECDSA; whereas for schnorr signing, the
signing device can successfully make the signature without ever knowing the full
K, which is how MuSig2 works because of the linearity of schnorr signatures.  So
we could, if we were only trying to solve nonce exfiltration for BIP340 schnorr
signatures, we could actually use MuSig2 nonce sharing and use a kind of already
specified protocol for this.  But because we want to do nonce exfiltration
protection for both ECDSA and schnorr, Moonsettler's protocol has echoes of the
MuSig style, but it works for both.

**Mark Erhardt**: Cool, thank you for those clarifications.  Back to
Moonsettler, maybe.

**Moonsettler**: Okay, so what I wanted to say, actually the generation of Q, we
have looked at it more closely.  The generation of Q is something where you
could use the BIP340 nonce gen exactly.  You could just take that code and
generate Q with it, with the caveat that you would never use the part where the
zero mask is used because the first hash of N is precomputed because it's not
provided.  In this protocol, we always provide a nonce extra, so that part would
not be used, but you could use the exact same nonce gen function if you wanted
to define that way in formal specification, and I think that is very likely.
People would probably gain reassurance from that you are using in the internal
nonce, which is very, very important, because no matter what you are tweaking it
with, if the internal nonce is solid, and it is not knowable to the outside
world, then you know that your scheme is cryptographically secure.

So, the tweaking is actually something that the external world can know.
Normally, only the software wallet, the companion wallet would know, but of
course this is like a weak assurance and we would not rely on it for the
security of funds.  What actually secures the funds is the generation of Q and I
think it's reasonable, as you suggested before, to actually use BIP340 nonce gen
for that.  But the final key computation is not possible.  Right now, the way it
is coupled inside in a secp256k1 library, it's over-coupled and it needs to be a
little bit decoupled for this to work.  But things are actually very similar
already and almost snap-enabled.

**Mark Erhardt**: Cool.  Thank you for that explanation of your proposal.  Mike
or Rearden, did you have anything else?

**Mike Schmidt**: Not from me.

**Mark Erhardt**: Well the suspicious silence seems to indicate that Rearden
doesn't either.  All right.  Is there anything else to add or I guess, yeah, go
ahead.

**Mike Schmidt**: Maybe Moonsettler, if there's any call to action for the
audience, things you'd like folks to look into or comment on or consider as we
wrap up?

**Moonsettler**: Yeah, I'm really looking forward to feedback from especially
the more cryptographer-inclined people on the proposal.  And also, formal
specification and probably a BIP is going to be needed for this to be standard,
and if it's standard then signing devices can incorporate it.  Like I said,
Coinkite seems pretty eager to do so, but they can't do it without having a
formal specification, because there is literally no point in it.  So, I'm not
sure if anyone could do anything to help it aside from participating in said
work, like participating in a BIP proposal and participating in a discussion on
Delving.

**Mike Schmidt**: Great.  Moonsettler, you're welcome to stay on.  We have the
rest of the newsletter to go through if you want to hang out.  Otherwise, if you
have other things to do, you're free to drop.  Thanks for joining us.

**Moonsettler**: Thank you.

**Mike Schmidt**: Next segment from the newsletter is our monthly segment on
Changes to services and client software, where we highlight some interesting
updates to wallets and services and software in the ecosystem.

_Proton Wallet announced_

We have a handful this month, starting with Proton Wallet announced.  So, folks
may be familiar with the Proton email service, a privacy-centric email service
provider.  They announced that they now have an open-source Proton Bitcoin
wallet, and their wallet has support for a few different pieces of Bitcoin
technology, not everything, despite Twitter's criticisms, but it seems like
they're moving in the right direction.  They have support for multiple wallets,
bech32 addresses, batch sending, mnemonics, and due to the fact that they also
have an email provider service, there's some integrations of the wallet with
that specific Proton Mail as well.  Murch, have you seen any of the chatter
about Proton Wallet; do you have any thoughts?

**Mark Erhardt**: I haven't dived into this too deeply, but it's interesting to
see to be revealed to be a long-time Bitcoin user and have their own unique take
on what it takes to build a Bitcoin wallet and what features should it have.  So
I saw, for example, that they integrated with the email service, so you can send
Bitcoin by email, which sort of harkens back to when Coinbase did the same thing
a long time ago.  But here, it would of course be a self-custodial wallet.  So,
yeah, I don't know.  It's exciting that more people are giving their variant of
a Bitcoin wallet, so I hope that it's tenable and people find that it's useful
to them and that it's convincing in other regards.  I haven't verified that
myself yet.

**Mike Schmidt**: I think last I saw that they were doing a beta or sort of a
wait list, so I'm not sure if everybody can jump in and do that, but I think
that they did have some sort of preference for bitcoiners to test it out and
provide feedback.  So, check that out.

_CPUNet testnet announced_

Next piece of software, CPUNet.  And we have Bob on.  And Bob, I think you
joined us last week or the week before, and I think you dropped that this was
coming, so why don't you take the lead on explaining it.

**Bob McElrath**: Sure, can you hear me?

**Mike Schmidt**: Yeah.

**Bob McElrath**: All right, so this is a new testnet for Bitcoin.  The
characteristic that's unique about it is that I don't want it to be mined by
ASIC hardware.  As many of you probably know, the standard testnets on Bitcoin
are subject to hash storms.  The hashrate can vary by many, many orders of
magnitude, depending on whether somebody has a modern mining device connected or
not.  This causes the block rate to be wildly variable, and this is a problem
for us as far as developing Braidpool.  So, this testnet is intended for
developing Braidpool.  So, what I did is I modified the PoW function.  I simply
appended the string, "CPUNet" to the end of the header when you hash it.  This
causes the PoW hash to be slightly different than standard Bitcoin ones.  And
hopefully, this means that you will not be able to point standard Bitcoin ASICs
at it.  What we want here is a standard Bitcoin block rate with a wide
distribution of geographic nodes for development in the short term.  In the
longer term, we may set up a faucet and use this more widely, but right now
we're just using it for development.

I don't plan to merge this into Bitcoin, primarily because the change to the PoW
header is very difficult to incorporate in a general way.  It's very difficult
to get the parameters of the chain into the header so that you can switch the
PoW function.  Anybody has any ideas about that, I'd like to hear? In the
absence of that, I'm not going to try to merge it into Bitcoin.  Also, I'm not
going to try to merge it into Bitcoin unless I see other people using it for
other purposes.  Right now, this is just for development of Braidpool.  If
anybody has a Bitcoin server somewhere and would like to set up a node, we would
very much appreciate adding some geographic distribution here.  Mining Script
currently uses one core, so it's not terribly resource intensive, and of course
there are no transactions, so this is a very low bandwidth.  We'd appreciate
getting a couple more nodes added.

**Mark Erhardt**: One quick question.  So, if you are testing it for Braidpool,
I assume that it is intended to get sort of a pre-consensus on what should be
included in blocks, so eventually you're looking at having some transactions on
there to get that pre-consensus, right?

**Bob McElrath**: That's correct, that's not going to be carried on the testnet.
So, this is the bitcoin side of things.  Separate from that, there will be a
Braidpool consensus, which is a direct acyclic graph, as well as transactions,
bitcoin transactions carried on Braidpool, and Braidpool will have its own P2P
Network.  But all of this is completely separate from Bitcoin, none of that will
be on Bitcoin itself.  What we need from Bitcoin is just basically a standard
block rate.  We will have shares for Braidpool, we produce at a much, much
faster rate than Bitcoin, probably up to a thousand times faster, so we're
looking at a couple of shares per second.  And as a consequence, we don't need a
fast block rate, which some developers want for their purposes.  We don't need a
fast block rate for this.

**Mike Schmidt**: Bob, maybe while we have you, it would make sense to maybe
explain for the audience, who may not be familiar with Braidpool and what you
all are trying to do with that.

**Bob McElrath**: Certainly.  So, Braidpool is a new decentralized mining pool.
If you've been following Stratum v2 or Ocean or the DEMAND Pool, it's in kind of
the same vein there; we want to decentralize mining.  The flaw in Stratum and
Ocean and DEMAND Pool is that there still is custody by the pool.  And as long
as somebody is holding your funds hostage and paying you out, they can be
co-opted by governments, they can be forced by law enforcement to not pay you,
and there is nothing you can do about this.  The Braidpool is essentially a
reboot of P2Pool, if anybody is familiar with that, where the system itself pays
out directly to the miners.  There is no single party that has custody of the
miners' funds.  It is a consensus protocol that decides how many shares you
submitted and how those get paid out.  The consensus protocol is inspired by
Nakamoto Consensus, it uses the heaviest PoW chain to do so.  However, it
organizes everything into a direct acyclic graph instead of a chain, and that
allows us to achieve a much faster block rate, because what we really need here
is to sample the hashrate from an individual miner at a much faster rate than
Bitcoin blocks.

So, that's basically the project.  We are in the process of building it now.  We
hope to have a working version in the next few months.  And please see our
GitHub for more details if you want to contribute.

**Mark Erhardt**: Let me ask another follow-up question.  So, when you say
you're building a directed acyclic graph instead of a chain, would that be
reminiscent of uncle blocks in Ethereum, like everybody builds multiple blocks
and they all get aggregated in order to count their shares?

**Bob McElrath**: That is correct.  In spirit, it's similar to uncle blocks.
The thing it is most similar to is the Kaspa blockchain, which is also a direct
acyclic graph.  The algorithm used in Kaspa for its consensus is probably
equivalent to the Braid that I came up with, because I believe there is only one
correct way to organize a directed acyclic graph such that you're satisfying the
heaviest PoW requirement.  But yes, there's a series of papers, including the
uncle blocks which got used in Ethereum.  There are several papers after that,
including the DAGKnight proposal, by the same authors.  So, the DAGKnight
proposal is the one that's used in Kaspa.  It is a direct acyclic graph that is
PoW.  That is what I claim is most likely equivalent to Braid's.  I have not
proven that but I would like to in the course of this project.

**Mark Erhardt**: And so, you get consensus on the shares, but how does
Braidpool pick which transactions are included in the actual block that
eventually gets found?

**Bob McElrath**: That has yet to be decided.  So, in the very first version,
we're just going to take whatever bitcoind gives us and we're going to be
parsing full blocks around.  Now, this will not scale well if we're parsing
actual 4 MB blocks around.  Each share is a full valid Bitcoin block.  So, we
need to validate a full valid Bitcoin block on order of once per second.  So,
this is much, much faster than Bitcoin.  One of the proposals I have out there,
and again all of this is subject to debate if anybody wants to weigh in on this,
one of the proposals I have out there is to include bitcoin transactions in the
shares.  Now, these are not mined into blocks yet, but they're included in the
shares.  And so, the set of bitcoin transactions that are included in shares
becomes a de facto mempool that is committed.  So, you have consensus on what's
in the mempool.  And this is one of the problems with a lot of the conversations
about the mempool on Bitcoin, is that everyone has their own view on the
mempool.  Two nodes will not agree on the mempool.  And so, you can't place any
requirements about transactions you must or cannot include from the mempool,
because two nodes do not have the same view.

With this commitment in the share chain of the transactions, we will have a
committed set.  And one of the things I want to do here is then apply any
deterministic algorithm to that set to create the set of transactions in a
block.  Does that answer your question?

**Mark Erhardt**: Yeah, that's very cool.  Would that be compatible with
replacements? So, if a newer version with a higher feerate comes up, you would
want Braidpool to pick it up and replace a prior version in order to collect the
higher fees.  Would that be possible at all?

**Bob McElrath**: That's a really great question.  You would have to essentially
take a transaction that was already mined into the share chain and replace it
with another.  That seems possible.  That's further down the roadmap for us, I
think, to consider, but that's a great idea.

**Mark Erhardt**: Cool.  Thank you for coming by and explaining it.

**Mike Schmidt**: Bob, I have a follow-up question as well.  You mentioned
Ocean, and I know that they prided themselves on doing payouts as well from the
coinbase, but I think that there's a certain threshold at which they would be
holding funds until a particular miner hits a particular threshold for, I guess
the concern would be the payout versus the fees it would take to actually pay
that reward would be disproportionate.  How do you think about that with regard
to Braidpool?

**Bob McElrath**: So, the way Ocean works is that they are paying directly in
the coinbase.  One of the consequences of this is they are using Pay Per Last N
Share, or PPLNS.  One of the consequences of this is that you get paid multiple
times for the same share.  The way the PPLNS on Ocean works, it's an algorithm
they call TIDES.  Miners will get paid on average eight times for each share.
Now, this causes a lot of extra UTOs and UXTOs, and your miner payouts are
competing in blockspace with fee-paying transactions.  So, this is the same
disadvantage that P2Pool had back in the day.  We are not going to pay out in
coinbase the same way that Ocean does.

Now, Ocean is able to pay out faster and they reduce the amount of custody they
have to have.  But still, if you're a smaller miner, they are still holding your
funds in custody and they have to hold it because you can't make very, very
small UTXOs.  So, if you're a small miner, no matter what system you use, you
can't make tiny UTXOs to pay miners.  So, with Braidpool, by having a block rate
that is roughly 1,000 times faster than Bitcoin, we will be able to pay out
miners that are roughly 1,000 times smaller than what is a really practical solo
mine on Bitcoin.  For miners that are even smaller than that, we have a proposal
to create what are called sub-pools, which is another copy of Braidpool
essentially, where the payouts from the parent Braidpool become payouts in the
child pool, and this will allow us to get to smaller miners.  We are going to
have to have a threshold there because again, we cannot pay tiny amounts, and
there's not really much we can do about that.

We continue to have discussions about whether we can do Lightning payouts, but
the way Lightning works right now, it really is custodial.  You have a
counterparty on the other end of that channel and they're paying you.  We
envision service providers to come along and provide that service.  So, a
centralized pool service provider can run on top of Braidpool and provide
Lightning payouts, and so that's where we envision that to come in for very
small miners.

**Mark Erhardt**: So basically, Braidpool would be a form of a sidechain with
its own blockchain, and you can have UTXOs on the Braidpool chain that you can
then pay out into a real Bitcoin UTXO.  So, it's sort of custodial to the
Braidpool, but not custodial to the Braidpool operator, or anyone really,
because it's a, well, DAO basically?

**Bob McElrath**: Sort of.  I mean, so it is a merge mine sidechain, that is a
correct description.  It is its own blockchain that's using the same PoW as
Bitcoin.  So, every Bitcoin block is a node in the direct acyclic graph of the
share chain.  What was the second part of your question there?

**Mark Erhardt**: How do they get their money out of Braidpool chain into the
Bitcoin blockchain eventually, when it's enough?

**Bob McElrath**: Yeah.  So, what Ocean and P2Pool did is by paying out directly
in a coinbase, there isn't a need for custody, right, because the funds go out
immediately.  And this is a good idea in general, one that we continue to think
about whether we can leverage.  What Braidpool will do instead is have a very,
very long window.  So, in other words, PPLNS is Pay Per Last N shares.  N for
the Ocean pool is around 8, right, so you're averaging over 8 blocks.  The
variance on your payout with an average of only 8 blocks is still quite large.
We are going to average over an entire difficulty adjustment window, which is
2,016 blocks.  And so, at the end of the difficulty adjustment window, the
system will pay everybody out.  And so we do need to custody the fund, the mined
funds over that 2,016 block window.  And the way that is going to work is using
a federation of miners who have previously won blocks using a giant FROST
signature.

So, one of the gating technologies that really made this possible was the
existence of FROST, the FROST setting protocol, because we can now make large
dynamic federations, and entry into the federation happens because you mined the
block, and exit from the federation can happen if you haven't mined a block in a
while.  So, we can keep this federation to custody to those funds.  The rules
around how and who to pay are the consensus rules of the share chain.

**Mark Erhardt**: Cool, sounds very ambitious!

**Mike Schmidt**: Yeah, thanks for drilling into that with us, Bob.

**Bob McElrath**: Sure, no problem.

_Lightning.Pub launches_

**Mike Schmidt**: Next piece of software that we highlighted this month was
Lightning.Pub launching.  Lightning.Pub is a node management software for use
with your LND node, and what it enables is for you to share access to that LND
node as well as coordinating on channel liquidity for that node.  And I think
the use case here is if you're a more technical person in your family or group
and you want to share those resources, this LND resource, with some of those
less technical family members, you can use Lightning.Pub.  And it also uses
Nostr for two things, one for encrypted communications between these parties,
and also the Nostr pubkey is also your identity within that Lightning node.

_Taproot Assets v0.4.0-alpha released_

Taproot Assets v0.4.0-alpha is released.  The most notable thing here is that
the Taproot Assets protocol is now available on mainnet, and so that allows a
few different things.  You can issue non-bitcoin assets onchain; you can also do
atomic swaps using PSBTs; and I think what folks are most familiar with is then
the routing of those issued assets through the LN.  I think that the folks at
Lightning Labs are focusing initially on assets in the form of stable coins on
Lightning and going after that use case, but obviously this is a protocol where
you can issue your own assets.  So, interested to see how that plays out.  Any
thoughts there, Murch?

**Mark Erhardt**: Well, I don't know.  We're talking a lot about other assets on
Bitcoin lately, and on the one hand, we've been saying for a decade that
anything good that happens to other cryptocurrencies will eventually come back
to Bitcoin and we'll have our own take on it and probably do it better.  I think
that it's a lot better than a lot of other protocols we've seen.  On the other
hand, I still have a little bit of a wrench in my gut with assets on Bitcoin and
how other chains have become very top-heavy in that way, like potentially
inviting all of DeFi to Bitcoin would certainly lead to more activity, but I'm
kind of worried that we might lose our digital cash eventually.  So, I don't
know.  I have very mixed feelings about all of this!

_Stratum v2 benchmarking tool released_

**Mike Schmidt**: Stratum v2 benchmarking tool released.  So, there is a 0.1.0
release of the Stratum v2 benchmarking tool.  And the idea behind this tool is
separate from Stratum v2, you can do benchmarking.  So, there's testing,
reporting, and I guess maybe most importantly is the comparison of performance
of your mining setup using Stratum v1 versus a Stratum v2 protocol.  And so, you
can kind of see the performance improvements or not, depending on your setup.
So, hopefully that results in miners doing some of these simulations and seeing
that Stratum v2 is potentially faster for them to implement for a variety of
reasons, and adopting at least some of those Stratum v2 protocol features.
Murch, any thoughts?

**Mark Erhardt**: Yeah, I think so Stratum v2 can be encrypted or is always
encrypted, and I think it is also more bandwidth-efficient.  So, I would hope
that these simulations and benchmarks show that even if they do not use the
block-building delegation, that Stratum v2 would be a lot better for them and
then hopefully opens the door to them later letting their mining pool
contributors build block templates.

_STARK verification PoC on signet_

**Mike Schmidt**: Next piece of software we highlighted was STARK verification
Proof of Concept (PoC) on signet.  A bit of background here.  OP_CAT has
previously been activated on signet via Bitcoin Inquisition.  We covered that
previously in also some discussions of Bitcoin Inquisition with AJ Towns.
StarkWare is a company working on STARK proofs.  STARKs are a sort of
zero-knowledge proof where one party can prove to another party that something
is true without revealing any other information.  StarkWare also has or is
contributing to this Circle STARK verifier in Bitcoin Script.  And so with all
that background, there are now these CAT-based covenants in Bitcoin Script on
signet, and the STARK verifier is splitting a STARK verification script across
10 bitcoin transactions, and then gradually validating the proof by aggregating
the information across those different transactions.  And so, you have a ZKP
proof verifier in Bitcoin on signet.  Murch, have you followed any of the ZKP
talk, OP_CAT or otherwise?

**Mark Erhardt**: Yeah, I've been trying to engage a little bit with OP_CAT last
week and I was asking people to tell me about the interesting things that are
being built with OP_CAT.  So, I think it's easy to see that you can build stuff
with OP_CAT.  I know that some people have assured me that they have really
deeply thought about what cannot be built with OP_CAT as well.  One of the
things that I feel is hard to decide is would, for example, OP_CAT by itself be
worth the effort of a soft fork and worth the review?  So, in the context of
this STARK verification, my understanding is that this takes a total of 3.1
million weight units, so almost a whole Bitcoin block.  So, if you want to
verify, say, a STARK proof per day, that would take almost a whole block per
day.  So, paying for a block worth of blockspace would of course cost quite a
bit of fees, especially if the feerates go up from the current very low
feerates.  And I think it would probably make sense if whatever you're verifying
is generating some several $10,000 worth of revenue or fees inside of the
system, like maybe a rollup or some sort of sidechain mechanism.

But overall, I think what I'm still a little on the fence about is all of the
constructions that are built with OP_CAT seem very roundabout so far.  So, I
think if anything, it would make a lot more sense to be bundled with more other
script changes in order to motivate a soft fork.  But, well, I'm not convinced
yet that we have sufficient momentum for that yet.  Anyway, I'm kind of starting
to look a little bit at what is being proposed, but there's also still a bunch
of different proposals floating out there.  There's, of course, the great script
restoration, which does OP_CAT and a bunch of other opcodes; there's some other
proposals that combine OP_CAT with a variety of OP_CHECKSIGFROMSTACK,
OP_INTERNALKEY, OP_CTV, I think OP_TXHASH is in there, I don't know if OP_TLUV
is still in the running.  But yeah, the conversation has advanced a bunch in the
past few years, but it's not obvious to me yet what exactly the path forward
should be.  I'm sure some listeners here have very strong opinions on that!

**Mike Schmidt**: I saw some of the Stack Exchange questions this month, since
I'm working on the writeup for the next newsletter.  I saw quite a few
OP_CAT-related ones.  So, now it makes sense that you were sort of trying to
tease out some content there as well.

**Mark Erhardt**: Yeah, so we had a topic week, which got all the people,
including Brandon and me, to participate.  So, Brandon wrote a bunch of answers.
We got another writeup from Matthew Black recently, who's explained to us how
you could build a zero-conf-like construction just on basis of OP_CAT.  Yeah,
again, I see how you can build stuff, but for example, with the zero conf, it's
hard for me to see how this is 10X better than other solutions.  Yeah, so I
would love for more people to ask questions so we can all better understand it.
Stack Exchange is a great place to surface questions in a way that they are
indexable, archivable, and searchable.  I know there is a lot of discussion in
private groups and on Twitter threads, where it's just really hard to actually
summarize and aggregate the information later, because you have to keep track of
all these separate conversations.

So, if you're interested in covenants and this topic, I would encourage you to
maybe seed some questions and answers to Stack Exchange, or participate in
delving on discussions about this.

_SeedSigner 0.8.0 released_

**Mike Schmidt**: SeedSigner 0.8.0 is released.  I don't think we've talked
about SeedSigner previously, but it is a sort of build-your-own Bitcoin signing
device, and I think they're using a Raspberry Pi.  I'm unsure exactly which
Raspberry Pi version, but you essentially build a hardware signing device from a
Raspberry Pi.  And 0.8.0 included a couple of interesting bits of Bitcoin
technology.  They added some support for older address types, P2PKH and P2SH
multisig; they also have additional PSBT support; and they've had taproot
support for a while and have added that as default in the 0.8.0 release.  Murch,
any thoughts?

**Mark Erhardt**: I had a to-do here to look up what exactly they added to their
PSBT support, but I didn't get around to it.  And also, so the signing features
for P2PKH and P2SH multisig, is that just transactions or is this about message
signing? I kind of wish someone would pick up the message signing BIP again and
bring it across the goal line, but I also know that some people are really
concerned about it getting misused for surveillance.  So, everything is so
complicated these days!

**Mike Schmidt**: Yeah, we can't even get a sign message feature.  I do believe
that those are transaction signing, legacy signing.

_Floresta 0.6.0 released_

And our last piece of software this month, Floresta 0.6.0.  We've covered
Floresta a couple of times in this segment.  So, if you're curious about what it
is, refer back to those entries and our podcast discussion of those entries
where we get into it.  But essentially, Floresta is an implementation of
utreexo.  And with this latest release, they added support for compact block
filters, fraud proofs, PoW fraud proofs on signet, and this florestad, which is
a daemon, which is something that you can run florestad alongside your existing
wallet or client application, and that daemon will run in the background and do
the utreexo stuff for you, so it's sort of like a nice drop-in.  There's a blog
post, and there's also the release notes that we link to.  You should check that
out if you're curious about utreexo and wanting to sort of have an easy-ish
drop-in integration.

**Mark Erhardt**: The compact block support piqued my interest, so I looked at
their release notes to be specific.  The support is for downloading and storing
compact blocks in order to look up transactions without parsing the whole
blockchain.

_Core Lightning 24.08rc2_

**Mike Schmidt**: Releases and release candidates.  Core Lightning 24.08rc2,
it's the next major version for Core Lightning (CLN).  I am withholding any
spoilering of this release for the time being.  Murch, I don't know if there's
any comments you want to say about this RC, or if we should wait until we get
somebody on from CLN.

**Mark Erhardt**: We should wait to get into details, but I saw that there was a
lot of onion messaging support.  It's clear they're working on BOLT12 support,
so yeah, lots of that.

**Mike Schmidt**: Yes, and I'm sure folks can conclude, based on some of the
recently merged Notable PRs that we cover, what may or may not be in there.

_LND v0.18.3-beta.rc1_

Next release was the LND v0.18.3 release.  Similarly, there's a bunch of stuff
in their release notes for us to look up, including about a dozen bug fixes, a
few new features and improvements and some technical architecture updates.  But
perhaps we wait on that one as well.  And of course, we always have BDK in the
background, so Steve will come on when the time is right.

Notable code and documentation changes.  If you have a question for Murch or I
on the newsletter so far, or a general Bitcoin question, feel free to drop that
in the Twitter thread or request speaker access.

_Bitcoin Core #28553_

Bitcoin Core #28553 adds a snapshot to Bitcoin Core to be used by assumeUTXO.
And the snapshot is at block height 840,000.  Oh, Murch, already!

**Mark Erhardt**: Sorry, I wanted to be very specific here.  What Bitcoin Core
adds is a commitment to a snapshot file.  The snapshot file itself is not
shipped with Bitcoin Core.  So, assumeUTXO will have a snapshot at height
840,000, which is of course the halving block, and it'll allow you to basically
sync only from, what is it, 21 April this year up to the current chain tip first
before doing all of the background processing of the full history of the
blockchain.  You do have to acquire the snapshot file out of band still, and the
snapshot file would, for example, come from BitTorrent at this time.  And then,
importing it will get checked against the snapshot commitment that gets shipped
in Bitcoin Core.  This is going to come out in v28.  So, the feature branch just
got forked off on Monday, yesterday, and so feature freeze was a few weeks ago.
We're now going to have an RC very soon, and we'll do some testing, some more
bug fixes.  I think the release is supposed to be early October.

**Mike Schmidt**: Thanks, Murch.  Yeah, I think there's been just about 19,000
to 20,000 blocks since that snapshot, so about four months of blocks.  There's
also a script in the Bitcoin Core repository, a shell script that you can use to
verify that this snapshot is correct, and compare that against the hash
provided.  And the only other thing I had here was, Murch, any idea of what the
approximate time to sync the chain using this assumeUTXO snapshot versus full
IBD (Initial Block Download), if I were to fire that up today; what would the
differences be, do we have an idea of that?

**Mark Erhardt**: I do not have one from the top of my day, but let's say the
release date is 30 September, you immediately try to sync a new node with the
assumeUTXO snapshot, that would be about six months' worth of blockchain that
you have to go through.  So hopefully, maybe an eighth or so of the full
synchronization time, because at first blocks weren't that big and over time --
well, on the other hand, we've had a bigger portion of not just signature data
in the block.  So, maybe actually the last half year is a little faster.  So, my
guess would be somewhere around the order of a tenth to a fifth of the full
blockchain sync.

_Bitcoin Core #30246_

**Mike Schmidt**: Bitcoin Core #30246, which adds a feature to compare to
ASMaps.  ASMaps represent a mapping of IP addresses to network operators or
owners of those IP addresses.  So, that would be something like an ISP.  So, for
example, "This ISP owns this range of IP addresses", is sort of what an ASMap
would contain.  Obviously, IP address ownership changes quite often, and there
also isn't one solid provider of this sort of who owns these IP-address-type
data.  So, it's sort of hard to have this canonical set of IP address mappings
to work from.  But maybe the question is, why does Bitcoin Core care about
mappings of IP addresses to entities that own them?  Well, you can see that a
Bitcoin node operator would want to have P2P connections to a variety of diverse
entities to avoid being eclipse attacked, when that would be the case when one
entity controls all of your peers and can do various attacks like double spends
against you, or you just may not be aware of the latest state of the blockchain.

So, in the interest of having a diverse set of peers, Murch could probably dig
into this more, but currently, Bitcoin Core does some IP address bucketing based
on certain characteristics of the IP address.  You get put into certain buckets
and you want to have a diverse set of buckets.  But another way to do that is to
use this giant map of what entities own IP address blocks and try to get a
variety of connections, so that you're not being totally connected to, for
example, Amazon's cloud service IP address.  And so, by prioritizing diversity
across different owners of IP addresses, you can be more resistant to these
eclipse attacks.  I'll pause there.  Murch?

**Mark Erhardt**: Excellent explanation.  Yeah basically, Bitcoin Core keeps
track of sort of the IP ranges that constitute different entities in the
autonomous system map.  And it's, for example, really easy to spin up 1,000
nodes on Amazon or on Hetzner.  And now, if your node has a bunch of connections
from these already, it will prefer IPs or nodes that have connections that are
located in different IP regions and that will, yeah, as you said, help against
eclipse attacks.

**Mike Schmidt**: And so, this PR adds this sort of utility to compare two of
these maps.  So, it could be one that I generate this morning, a giant mapping,
and then one that I generate this afternoon.  I can use this diff tool to see
how different my original map was from the later map.  And the idea here that we
mentioned in the newsletter is that you can quantify how the map that you have
has been degrading over time.  And the reason you might want to care about that
is if eventually a map is shipped with Bitcoin Core, you'd want to have an idea
of how quickly that's degrading and potentially have the ability to also provide
a new mapping for that as well.

**Mark Erhardt**: Yeah, I think we already allow loading of ASMaps, but exactly
as you said, it's hard to tell how relevant a map from half a year ago is still.
So right now, if you deploy the new Bitcoin Core 27 node that was cut half a
year ago, probably the ASMap is even a few weeks older, somewhere in the end of
the release time, but before all the RCs have been iterated through.  So, yeah,
if it degrades really quickly and it's not useful after a few months, people
might work on having more tools to disseminate new ASMaps.  Or if it's actually
still somewhat useful after half a year, you just keep it around.  So, the idea
is if you can actually measure how good old ASMaps are, it'll inform the further
steps.

**Mike Schmidt**: Yeah, Fabian has been doing some work on this, and it's quite
interesting.  I think he's got a lot of tooling around this, the ability to run
scripts against a variety of these AS resources to generate the file to begin
with.  And yeah, there's just some interesting challenges.  I think some of the
folks in the networking space sort of thought what he was doing was not even
possible, the fact that you could sort of run these tools at the same time to
generate approximately, or exactly the same mapping files, so that we could
actually have the hope of including a canonical map in Bitcoin Core.  They
didn't think it was possible, but Fabian's done some great work to put that
together.  So, if you're interested about networking stuff, P2P stuff, being
able to generate one of these mappings yourself, dig into some of that work.

**Mark Erhardt**: Chapeau to Fabian, by the way, this is his release.  The
testnet 4 is coming out; assumeUTXO is having its first snapshot parameters; and
now also ASMap updates.

_Bitcoin Core GUI #824_

**Mike Schmidt**: Bitcoin Core GUI #824, which allows a user to migrate any
legacy wallet in their wallet directory to a modern wallet.  So, I guess there's
a restriction here.  And so, currently the Migrate Wallet menu item in the GUI
really only is allowed to migrate the currently loaded wallet into the GUI.  So,
you can imagine in a coming future, when legacy wallets can no longer be loaded
at all because they're not supported, you wouldn't be able to migrate your
wallet because you couldn't load it.  So, this adds a feature for you to be able
to migrate any legacy wallet in the wallet directory, not just the one that you
happen to have loaded at that time.  Murch?

**Mark Erhardt**: Yeah, a little more background here.  So, as some people
hopefully already know, but I'll repeat it again, the old wallet standard was
based on Berkeley DB.  Berkeley DB is very outdated and unmaintained.  So,
Bitcoin Core has transitioned away from that and is using a different database.
What is it?  It's on the back of my tongue.

**Mike Schmidt**: LevelDB?

**Mark Erhardt**: No, LevelDB is used for the UTXO database.  But anyway, the
migration happened a while back already.  We are using this new database for
descriptor wallets, and now we would like to remove Berkeley DB as a dependency
altogether.  So, in the recent past, the Bitcoin Core master branch got a
read-only Berkeley DB implementation, our own implementation.  It only has the
features that we need to read old Bitcoin Core wallets.  So, the idea would be
that we now can migrate Bitcoin Core wallets forever.  You will always be able
to access your old legacy wallet, but it will be converted to the new format and
the new format will be the only one that is directly supported for loading and
using in Bitcoin Core.

_Core Lightning #7540_

**Mike Schmidt**: Core Lightning #7540, which adds a base probability parameter
specifically to the renepay plugin.  We talked a little bit about renepay and
its successors last week.  This parameter represents the probability for a
channel in the network chosen at random to be able to forward at least 1 msat,
which is really I guess just a way of saying that the channel is alive and not
totally depleted on one side.  And CLN is, for the moment, assuming that that
probability is 0.98, and they're using that 0.98 variable as this base
probability default.  And it also looks to me like this is a user-configurable
parameter, and one commenter on this PR says, "I've seen great improvements in
the reliability of payments after adding this".  Murch, I don't know if you have
any thoughts?  Great.

_Core Lightning #7403_

This next CLN PR is also related to the renepay plugin, Core Lightning #7403.
It adds the ability to filter channels to not be used by renepay.  The PR
disables channels that have low max_htlc settings, but sets the precedent or the
ability to be able to filter channels in the future as well.  It can be extended
for other properties in the future.  There's also this exclude command line
option, where you can manually provide a list of short channel identifiers for
manual exclusion.  If you're curious about any of the details here, please jump
into these PRs because I think there's a lot more detail for the pathfinding
nerds out there to see what's going on in CLN.

_LND #8943_

LND #8943 adds an Alloy model for LND for their Linear Fee Function fee bumping
mechanism.  We may have talked about Alloy before, but it's a modeling language
that uses a collection of constraints that describe a set of structures.  So,
one example that the Alloy site gives would be the example of modeling all
possible topologies in a switching network.  So, for example, in like a
telephone switching system.  So, you can imagine how something like that might
be useful for modeling various things in the LN as well.  Well, LND thought so.
They're modeling this Linear Fee Function fee bumping mechanism as their first
model.  And, "This model was inspired by a bug fix, due to an off-by-one error
in the original code".  And as I mentioned, this is the first Alloy model in
LND.  They're indicating that there'll be future models planned in the future.
Murch, I forget, did we talk about Alloy before?  And are you familiar with such
a modeling language?

**Mark Erhardt**: No and no!  I don't remember, sorry.

_BDK #1478_

**Mike Schmidt**: Okay.  BDK #1478 is a breaking change to BDK's FullScanRequest
and SyncRequest functions.  Those functions have a few different changes.  One,
it takes an optional chain tip parameter.  There's a bunch of changes internally
to the operation of those functions, including performance improvement when
you're using Esplora, that result in, "A better API".  If you're using these
APIs, I recommend you drill into the PR for more details.  There was a bunch
there that I didn't think was germane to our newsletter coverage, but if you're
using those, it's probably germane to your operation.

_BDK #1533_

BDK #1533 enables support, or I should say re-enables support for single
descriptor wallets.  Murch, what is a single descriptor wallet, first of all?

**Mark Erhardt**: I think this is in context of descriptors that have separate
descriptions of a receive address chain and a change address chain.  And that
was a standard recently described in a BIP on how you can fully describe a
wallet that has a separate change chain.  Yeah, I don't know exactly what the
rest of the context here is.

**Mike Schmidt**: Yeah, you're right on I guess the main "normal" use case would
be you'd have this change descriptor separately, and there was a change to BDK
previously that made an update that their wallet structure required a change
descriptor.  And the reason for that change was there's some privacy
implications for users specifically relying on Electrum or Esplora servers.  So,
there's a privacy consideration there, so they required both of the descriptors.
But it turns out there's some users that prefer, or for their use case, have
this single descriptor wallet, and so this sort of reverts that previous update
to allow that single descriptor again.  Yeah, Murch?

**Mark Erhardt**: Basically, the main concern with using Electrum, or I guess
also Esplora, is you essentially leak all of your light client's addresses to
the server.  Some of these servers are operated by known entities, some of these
are just random nodes on the network.  There've been some privacy issues before.
I think there were some concerns that a lot of these may be run by chain
surveillance companies.  So, you're essentially telling some random participant
in the network what exactly the whole body of your addresses are, like your
whole wallet's address body.  And even if you just give the snapshot once, or if
you give a descriptor, not only are you telling them about your current address
body, but also your entire future address body.  So, that's really the biggest
downside of having an Electrum- or Esplora-based light client.

There is, of course, the compact block filters, which you can use client-side to
find out whether there is something in a block that's relevant to you, but that
comes at a much higher implementation complexity and at more bandwidth cost.
So, yeah, it's sort of a standard way of running a light client, is to just
depend on some Electrum or Esplora node that gives you data.  I think the more
benign variant is to use one that you know who the other party is, so you at
least know who you trust with your privacy, or to run your own.  But then, of
course, if you're running a full node already, you get the benefit of being able
to have the light client with you for maybe a spending wallet.  But you now have
the overhead of having to maintain multiple different pieces of software and
running always on server software.

_BOLTs #1182_

**Mike Schmidt**: Next PR is to the BOLTs repository, BOLTs #1182.  It's a PR
titled, "Clarify onions part 2: a bit deeper rework".  And this PR makes several
updates to BOLT4, and that is the BOLT that deals with onion routing and onion
messages.  I'll enumerate the changes that we highlighted in the newsletter.
This PR, "Moves the route blinding section up one level to emphasize its
applicability to payments, provides more concrete details on the blinded_path
type and its requirements, expands the description of the writer’s
responsibility, splits the reader section into separate parts for the
blinded_path and encrypted_recipient_data, improves the explanation of the
blinded_path concept, adds a recommendation to use a dummy hop, and renames the
onionmsg_hop to blinded_path_hop", and there's some other clarifying changes in
there as well.  If you're doing BOLT4 onion routing blinded path stuff, check it
out.

_BLIPs #39_

Last PR this week is to the BLIPs repository, BLIPs #39, which adds BLIP39,
which is an optional field in BOLT11 invoices to communicate a blinded path for
paying the receivers node for BOLT11 invoices.  We spoke about this in
Newsletter #315 as well.  I think while blinded paths are more commonly
discussed in the BOLT12 offers protocol, LND is also adding blinded paths to
BOLT11 invoices in the form of a BLIP; this is not a BOLT.  To quote from the
document, it says, "This document proposes a carve-out to the existing BOLT11
invoice format, so that testing of blinded paths can be done in implementations
that have not yet implemented the full offers specification".  Anything to add
there, Murch?

**Mark Erhardt**: We had a really interesting discussion with Elle a few weeks
ago.  I don't remember exactly which newsletter, but if you want to hear more
about the idea of adding blinded paths to BOLT11, you can check out that
previous newsletter.  Do you happen to have it on hand?

**Mike Schmidt**: I just pulled it up.  I think we had Elle on in Recap #310.
So, yeah, we dove into this topic a bit there.  I don't see any request for
speaker access or questions, so I think we can wrap up.  Thank you to Bob for
joining us sort of impromptu and also for Moonsettler to help explain his
Delving post in the news section.  Thanks always to you, Murch, as my co-host
and for you all for listening.

**Mark Erhardt**: And thank you for Rearden for jumping in and helping with
topics a little bit.

**Mike Schmidt**: Oh, yes.  Thanks Rearden.  See you next week, cheers.

{% include references.md %}
