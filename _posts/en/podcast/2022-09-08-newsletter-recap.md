---
title: 'Bitcoin Optech Newsletter #216 Recap Podcast'
permalink: /en/podcast/2022/09/08/
reference: /en/newsletters/2022/09/07/
name: 2022-09-08-recap
slug: 2022-09-08-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Daniela Brozzoni to discuss [Newsletter #216]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-28/348926914-44100-2-27127daaba08d.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody, this is Bitcoin Optech Newsletter #216
Recap.  I've posted some relevant tweets in this Spaces for folks to calibrate
themselves on the newsletter and what we'll be talking about.  In terms of
introductions, I'm Mike Schmidt, contributor at Optech and Executive Director at
Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I am a co-host of BitDevs New York.  I work at
Chaincode Labs as an engineer, and I sometimes write for the Optech Newsletter
and do other stuff too.

**Mike Schmidt**: Daniela, do you want to introduce yourself?

**Daniela Brozzoni**: Yeah, sure.  Hi everyone, I'm Daniela.  I'm a developer,
and I'm currently working on Bitcoin Dev Kit (BDK) and we'll talk about that
later, I guess.

**Mike Schmidt**: Sure.  Maybe as part of your introduction, you can let folks
know how you got into the Bitcoin space and development, and maybe a little bit
about any projects you work on outside of BDK?

**Daniela Brozzoni**: Sure.  So basically, when I was about 14, I started
studying computer science in school, and at a certain point, I think it was
around 2017, I discovered Bitcoin because a friend showed me a book about it and
I thought it was cool, because it seemed to be all about math and computer
science, and in fact it is; there's much more to that, but I came to discover
that.  After a while, I was studying Bitcoin.  So, at around 2019, I basically
finished school and then I started working in different Bitcoin companies.  I've
worked on the Blockstream's Green Wallet, I've worked at Braiins, I've worked at
Revault.  And yeah, now I'm funded by Spiral and I have a grant to work
full-time on BDK.

**Mike Schmidt**: Excellent.  So you got started in computer science and Bitcoin
development pretty early then?

**Daniela Brozzoni**: Yeah.

**Mike Schmidt**: Well, let's jump into newsletter 216 then.  There was no
notable news this week for the news section.  And so, we could just jump into
Notable code changes instead.  And we have two Bitcoin Core PRs and two BDK PRs
to discuss.

_Bitcoin Core #25717_

This first Bitcoin Core PR is a fairly big one.  And, Murch, I know you were
doing some one-on-one notes review with Suhas, who's the author of this PR, and
maybe we can walk through maybe some history of checkpoints and Initial Block
Download (IBD) and then why these sorts of changes are an improvement on what we
have now.  So, maybe to set the stage a bit, when you fire up the Bitcoin Core
software, you go through a process known as IBD, and there's a variety of things
that could happen that are various attacks or various ways that your peers could
potentially prevent you from downloading the valid chain that you're trying to
download, or just slow you down in that process.  So, that sort of class of
attacks might be known as DoS attacks, and there were certain introductions of
checkpoints that were made in the past.  Maybe, Murch, you can get into that.
What's being done now before this sort of change was merged?  How do we prevent
a peer from giving us a bunch of low-difficulty headers that sort of screw us
up?

**Mark Erhardt**: Right.  So, when a new node enters the network, they obviously
know nothing about what the blockchain contains.  They only have the anchor,
which is the genesis block, that is hardcoded in the software.  And from there,
they're trying to find the best chain, right?  Best chain, the chain with the
most accumulated work, and sometimes not quite correctly called longest chain.
So, what an attacker could do at that point is, if they are the first peer that
gets connected to and ask for their best chain, they could just give the new
node a valid chain that is comprised of a ton of low- difficulty blocks that
does not actually belong to the best chain.  And so basically, the worry here is
that if a big number of the first peers that our node sees are collaborating
with this attacker, all of them can push data on us that is just these useless
chains, and fill up our memory and eventually DoS us to exhaust our memory and
crash the node.

**Mike Schmidt**: So, the attack is specifically low-difficulty blocks or
headers that maybe somebody just went off and made like a little mini chain off
of the genesis block, and it didn't have any reflection in what blocks were
actually being mined back then.  And then they feed us those low-difficulty
blocks because they can kind of spin that up at their will.  And whether that's
one peer, or as you alluded to, maybe more than one peer feeding us this
invalid, well, I guess valid, but not part of the current chain tip data.
That's the attack that we're trying to mitigate.

**Mark Erhardt**: Correct.  So, the first year of the Bitcoin blockchain
history, all the blocks are actually, until December, difficulty 1, right?  And
as we know today, mining is done with dedicated hardware, and difficulty 1 is
ridiculously easy, so it is trivial for an attacker, even with old machines, to
spin up tons of these low-difficulty chains.  And while block headers only have
80 bytes and that's very light, if you send somebody tons of these block
headers, you could exhaust their memory because the node keeps the header chain
in memory and, yeah, eventually you can exhaust it.

So actually, if you use the time warp bug, you can create a chain that advances
the timestamp only by one second every six blocks.  And if you create an
attacker chain from the genesis block to two hours from now, which is the
timeframe in which nodes will accept blocks, then you could actually send
somebody 2.5 billion headers, and that would be over 100 GB of data.  And that's
only from a single peer, so you could do this with a ton of peers at the same
time.  That's roughly the scenario.  Obviously, we're not seeing this attack
every day on the network yet, or anything like that, but this is actually also
not prevented by checkpoints, because a checkpoint is only respected when you
sync and you hit the checkpoint.  So, once somebody provides the checkpoint
header, a node will not accept forks below that header height.  But if you get a
chain that does not include the header, you would just accept that other
competing block.  Even with checkpoints, the problem isn't really prevented
because the lowest checkpoint is something like 11,000 blocks, I think, and you
could just spam 10,000 blocks over and over again, different ones, and still
exhaust the memory that way.

All right, so I think we've set the stage regarding the attack.  How about we
talk about the approach that is taken in this PR and what it changes about the
syncing?  So, instead of actually keeping all the headers that a peer gives us,
we instead create a set of commitments that commits to the chain of headers that
we've been shown.  We download what they hand us, we check that it forms a
chain, that the difficulty adjustments are reasonable, even though we don't
check whether they're correct, and we check that the difficulty is the same
across a period.  And then we only store 1-bit commitments, every roughly 600
blocks.

We do this until we hit an amount of work that is equal or greater than
nMinimumChainWork, which we set with every release of Bitcoin Core, and roughly
is a couple months back from the chain tip.  So, we will not accept a chain that
doesn't actually provide about as much work as we already know the best chain to
have at this time.  And we throw it away after that.  What this does is our
memory gets freed up again.  But of course, once we hit a minimum chain work, we
have to re-download all the headers, and now a nifty attacker might go like,
"Oh, I'll just give him crap the second time".  And to prevent that, we have
these commitments every 600 blocks, and we protect ourselves there, we do a
random offset where we start the commitments, and then we do salted commitments
so that the other party cannot guess what our commitments might be and lie to us
effectively.  And then we download the blocks again in 14,000-block chunks.  And
the commitments have to match up, those 1-bit commitments, every 600 blocks.

So, we get about 24 bits or 23 bits of security for 14,000 blocks, and it's
pretty hard to lie with an accuracy of 23-bit security by producing a header
chain.  So, we limit an attacker per peer to something like 600 kB of bullshit
data.  And, yeah, so it's pretty nifty.  Pieter and Suhas ran a bunch of
simulations to come up with the exact numbers that are optimal and limit the
attacker the most in memory they can waste.  And, yeah, how's that for a rough
overview?

**Mike Schmidt**: Yeah, I think it's great.  To dig into one of the pieces which
appears to be core at this approach, this nMinimumChainWork, which is something
that is actually part of the Bitcoin Core software release process, is to
generate what that number is and put it hardcoded into the software, such that
this sort of algorithm, anti-DOS measure can be built on top of that.  Is that
right?  If I don't trust that constant in the code, am I able to take the
benefit of this approach at all?

**Mark Erhardt**: Well, okay.  So, if you're running Bitcoin Core, let's be
honest, unless you've reviewed it yourself and built it from source and are
heavily involved in the creation process, you do trust the Bitcoin Core project
to a degree that they are not delivering malicious software to you.  And
nMinimumChainWork, that's just basically how much total work had the blockchain
about two or three months before the release.  And so, if you don't trust
Bitcoin Core to give an accurate number for how much work the chain should at
least have, then you should probably also not run Bitcoin Core in the first
place.  So, I think this is fine from a security standpoint.

This value actually has been around for a long time.  So, I think in 2012 we
introduced header-first sync.  Before that, every node would just collect all
the blocks that they've been given by peers and even if it doesn't know about
the parent yet, it puts them in the orphan pool, and those orphan blocks would
hang around for a while and get kicked out if too many of them accumulated.  And
it would only continue to sync eventually when it got the right next block, and
then built on that, whatever it had, and maybe get orphans again.  So, with
header first and getting the chain of headers in order first, we can now
download all the block data in parallel for, I think it does something like
2,000 blocks in advance.  It has sped up synchronization a bunch and allows us
to get data from multiple peers at the same time, effectively.  And even there
already, we only download the header chain until we hit nMinimumChainWork,
because otherwise we would open ourselves up to being spammed with fake block
data instead of just fake header data.  So, this is not a new part of this PR
#25717.

**Mike Schmidt**: Now, after this code is in a release and I'm running the
software with default settings, will I be using this anti-DoS header sync as
well as checkpoints, or what would the default then be?  Are both of those going
to be running in parallel before the checkpoints are phased out, or are you
familiar with that?

**Mark Erhardt**: Yes, checkpoints are still in the codebase, this PR does not
remove checkpoints.  It is a decent step towards removing checkpoints though,
because the only real protection that checkpoints currently offer is these
low-difficulty attacks at the start of the chain.  And even at that, they're not
particularly great anymore because I think the newest checkpoint is something
like 200,000 blocks.  And with today's ASIC capabilities, that is not really a
difficulty that is insurmountable by an attacker.  So, they could just start an
attack at block 200,001.  So, this is just a more comprehensive approach that
fixes an issue that currently is not protected against by checkpoints in the
first place, and also fixes a few other DoS attack vectors, and it's pretty
nifty altogether.

**Mike Schmidt**: There's been some work on assumeUTXO.  How does that fit in at
all with any of this, or is that just completely orthogonal?

**Mark Erhardt**: I'd say it's pretty orthogonal.  So, assumeUTXO, as far as I
understand it, would basically allow you to trust a dataset provided by a peer.
Like, you have a full node already, you want to bootstrap a second full node,
you create the assumeUTXO export data from the full node that you have already
synced and import it to the new node.  And then the new node would basically
say, "Okay, I know this is the UTXO set at height x, and from here, I can
continue to validate the chain because I have the complete UTXO set, and I trust
that I have the correct UTXO set".  And in the background, it can then do the
synchronization and verify that it had the correct UTXO set.

But until it gets to the height that the export was created at, it will trust
that it was informed correctly and can basically jumpstart using the wallet and
using most of the full node capability from that block on.  So, it's sort of a
shortcut to bootstrap a node to most of its functionality and moves some of the
synchronization process into the background to validate the UTXO set.  So, I
guess in the background, the synchronization of your node would still use these
improvements that we're talking about right now, but otherwise the change is
pretty orthogonal.

**Mike Schmidt**: One thing that was discussed in the comment section of this PR
was talking about slowing down initial headers sync as a result of this PR.  So,
there are some wins, but there's potentially some downsides as well.  Are you
familiar with the slowdown in initial headers sync as a result of this PR?  And
it sounds like there's a separate PR to help mitigate that; you want to talk
about that?

**Mark Erhardt**: Well, I'm not deeply familiar with it, but I think I have some
Cliff Notes.  So, yes, the headers currently weigh about 60 MB, so you download
60 MB twice if you see the best chain first, more of course if you see a fake
chain first.  And so, you might store up to 1 MB more per peer that you're
trying to sync from, in memory, and downloading the headers twice slows you down
a little bit.  But it's 60 MB added over the lifetime of the node, right?  Once
you've synced, you don't have to sync again.  So, I think within the context of
you just downloading and processing some I think it's roughly 500 GB of data
now, adding 60 GB to protect against DoS attacks doesn't really weigh that much,
and it doesn't slow you down that much either.

**Mike Schmidt**: Are there any other considerations or downsides to this
approach that is worthy of discussing here?

**Mark Erhardt**: Somebody had been complaining about it maybe using more
bandwidth, but if somebody is trying to -- so, this protects against a memory
exhaustion attack.  If somebody is trying to attack your bandwidth use and
trying to waste your bandwidth, then you could do it much more effectively.  You
could just do inventory spam, address messages, or pings, just ping a node again
and again until their bandwidth is used up.  You don't really have to do
something as complicated as creating fake header chains, and fake in the sense
that they're valid but not useful.  Yeah, I don't think that that is to be held
against this approach.

Maybe one more thing about checkpoints in general, why we don't really need
checkpoints and don't want checkpoints.  All right, checkpoints are I think a
little misunderstood.  So, they're not hardcoded, they only get applied upon
being seen.  They are way too low to really reasonably protect us against some
attacks because we haven't created a new one since 200,000.  And they don't
really protect against a lot of the things that they were made for in the first
place, like these fake low-difficulty header chains.  And so, for checkpoints to
be super-useful, we'd have to do something like Bcash and checkpoint at a height
a couple blocks from the chain tip.  And really, 10 blocks is already too far
away because a 10-block reorg can do a lot of damage.  And if it was close
enough to protect against reorg attacks, then it would significantly change our
consensus model and in general, how we find the ground truth in the network.
And I don't think we want a rolling checkpoint scheme or anything like that.  It
would make for a much, much poorer consensus model.

However, if the checkpoints are much lower, they don't really protect against
interesting attacks.  If there's a 1-block reorg, I think we're in trouble
already, and it doesn't matter that you can't do more than one, one day.  So, a
lot of people just sort of feel that checkpoints protect against a lot more than
they do and that they're a core component of the Bitcoin security model, and
neither of those two are true.  That was a little rambly.  I hope you got the
Cliff Notes.

**Mike Schmidt**: Yeah, I think we've pretty much exhausted this PR.  Daniela,
do you have anything to add?

**Daniela Brozzoni**: No, not really, actually.  I mean, I didn't know much
about this, so thank you, I guess.

_Bitcoin Core #25355_

**Mike Schmidt**: Excellent.  Well, I guess we can move on to Bitcoin Core
#25355, which adds support for transient one-time I2P addresses, only when
outbound connections are allowed.  So, Bitcoin Core can support multiple
networks, including anonymity networks, like Tor, and I2P is one of those.  And
with I2P, there's some nuance in how it works, that even if you are set to not
allow incoming, your outgoing connections also give an address out, and that
address can potentially leak some information.  And so, what this PR changes is
creating the notion of a transient address that you share when you're making an
outgoing connection, such that certain mitigations or attacks on privacy are
harder to do because you're giving out this one-time transient address, as
opposed to reusing one across multiple outbound connections.

**Mark Erhardt**: Right, so the invisible internet protocol, it creates a sort
of identifier when you make outbound connections because the recipient of an
outbound connection needs to learn where that came from so that they can talk
back.  And so, if you're a listening node on I2P, you do want to have a way for
people to contact you and you do kind of want this persistent identity so that
other people can propagate information about your address and discover you as a
peer.  However, if you're a non-listening node, you don't really want people to
be able to connect to you.  So, what this PR does is it basically rolls a new
random address that you pretend to be yours, or that you use for a single
connection that you make to an outbound peer.  And every time you connect to any
other outbound peer, or even the same outbound peer again, you create a new one.
And this prevents you from building up this persistent identity that could be
used to track your node on the I2P network, which still happens for a listening
node though.

**Mike Schmidt**: I see Lightlike is in here and I've invited him to speak if he
chooses to opine on this.  I know this is an area that he's maybe a bit more
familiar with than us.  But Daniela, did you have any insights or commentary on
this I2P change?

**Daniela Brozzoni**: Not really, actually, no.

**Mike Schmidt**: That's fair.  Murch, anything else you think we should discuss
on this PR?

**Mark Erhardt**: I don't have anything.

**Mike Schmidt**: Okay, great.  Well, if Lightlike wants to correct anything
that we've said or augment some of the discussion, he's welcome to do so.  I
didn't mean to just call him out, but I saw he was in this Space.  Well,
Daniela, I think the floor is yours.  Perhaps what might make sense is, given
your familiarity with BDK, we can go through these two remaining PRs in the
newsletter, but I think maybe giving an overview, a pitch, a pros and cons of
why someone would want to use BDK and what is the purpose of BDK, and then we
can jump into those PRs; is that fair?

**Daniela Brozzoni**: Sure, so BDK is a library written in Rust.  And BDK means
Bitcoin Dev Kit.  So, as the name suggests, it's a development kit for Bitcoin
devs.  So, the point is, if you want to build a wallet on Bitcoin, there is a
lot of stuff you need to take care of.  There are some libraries in Rust, like
Rust Bitcoin and Rust Miniscript, that can really help you if you want to create
a wallet, even if you want to create, not a single-sig wallet, some kind of
wallet that is a bit complicated, maybe with some complicated policies, Rust
Bitcoin and Rust Miniscript really can help, but you still have to know a little
bit about Bitcoin to use them.  So, the point of BDK is to abstract this
difficulty.

So, you use BDK, you can create a wallet, create transactions.  You still need
to know a little bit about policies, about descriptors, and all the Bitcoin
wallets kind of stuff, but there are some details that are quite abstracted to
you.  So, for example, you create a transaction, you say, "Hey, I want to fee
bump it", and we just create a transaction fee bumping it.  You don't have to
deal with all the, how do I add inputs; do I remove inputs?  Well, no, never
remove inputs, I guess.  What do I do?  Or for example, even an easier use case,
you want to create a transaction, we do the coin selection for you, which is
something which is not easy to do at all, as Murch knows, for sure!  So, yeah,
the point is abstracting some difficulties you might encounter.

Now, there are some cons, obviously.  The most obvious I can think of is you add
another dependency to your project, and that dependency has more dependencies.
So, for example, if I've spoken with some people that told me, "Hey, I don't
want to have a project which is full of dependencies" and they are super
minimalist; we're not that minimalist, so they wouldn't use BDK at the end of
the day.  So, it's about pros and cons.  Maybe some people want to exactly
define what's included in their project and they prefer not to use BDK.  I think
for most people that just want to create a wallet and not think too much about
it, BDK is a pretty good choice.

At the moment it's all written in Rust and we have some bindings, but bindings
are still in an initial state, let's say.  So, if you don't use Rust, but you
want to use, I don't know, React Native or Python or, I don't know, I'm not
working on bindings, there are still some methods.  There's still most of the
basic stuff, but if you want to do complicated stuff, you might not find exactly
the method you need, and you might need to actually write the code yourself,
because we're still working on that, simply put.  So, yeah, a lot of pros and
cons using it, and then everyone decides what's best, basically.

**Mike Schmidt**: How has adoption of BDK been in wallet providers or other end
client software?

**Daniela Brozzoni**: So, I don't know much about that because I'm not the one
speaking with actual clients or users, I'm more working on the library itself.
I think there's another wallet out there using it, if I remember correctly.  I
think Foundation Devices.  I've heard of other projects.  I'm not sure exactly
if I can name them because sometimes I know internally I've been told, "Hey,
that company might want to use it, that project uses it", but I don't know what
I can say and what I can't say.  So, yeah, actually I have no idea how it's
going!

**Mike Schmidt**: That's fair, yeah, you're privy to some information that may
be confidential.  I'm sure someone's keeping track of the usage.  We can look
that up later.  Anything else in general on BDK before we jump into these two
PRs?

**Daniela Brozzoni**: I didn't have anything more to say.  Yeah, just one thing.
If you're new to Rust or maybe if you really want to learn Rust and you are
trying to contribute to some projects, we'd love to have you contributing on
BDK.  So, you can just reach us out on our Discord and just tell us that you're
a newbie and you want to try to contribute.  We have a lot of good first issues
tagged on the main library.  So, yeah, if you're looking for some Rust to write,
just come say hi and we'll find something to do for you.

_BDK #689_

**Mike Schmidt**: Thanks, Daniela.  The first BDK PR here is add allow_dust
method to TxBuilder, and that's BDK #689.  Do you want to give us an overview of
the motivation for this PR and what it changes, and any other interesting
considerations around it?

**Daniela Brozzoni**: Sure.  So the point is, when you use BDK, you create a
wallet and then you use that wallet to create transactions.  So, we have this
TxBuilder.  You use it basically to define how you want your transaction, and
the most normal thing to do is just adding recipient to that transaction.  So,
normally, if you add the recipient, a certain address, and you say, "I want to
send 100 sats to that address", we just tell you, "No, that's not how it works,
because 100 satoshis is below the dust limit".  And by default, we don't allow
you to create transactions below the dust limit because most people simply don't
want to do that.  The dust limit is not really a consensus policy, it's more a
standardness policy.  What that means is that a transaction with an output which
is below dust limit can still be included in a block.  It's not an invalid
transaction.  It's just that nodes, by default, won't relay it.

So, if you create a transaction with an output below the dust limit, and you
give it directly to a miner, or you're a miner yourself, you can still include
that in a block, and the block isn't invalid.  But if you're a normal person,
and you try to broadcast that to the network, it just won't work.  Nodes will
just be like, "No, I'm not relaying this".  So, a user came to us and is like,
"Hey, I want to test my wallet and I really need to create outputs which are
below dust".  And we thought that that's fine, I guess, because we're not
creating an invalid transaction really.  And maybe in the future, if some miner
will ever use BDK, I don't know if that will ever happen, but if that happens,
they might want to do that for some weird reasons.  So, we thought a bit about
it, and then we were like, "Yeah, okay, it's fine.  We can have a method to just
allow these weird outputs to be created".

As the Optech pointed out, there's a special type of output, which is an
OP_RETURN, that can actually have below-dust value because it has to be zero,
but the rest of the outputs must be above the dust if you want the transactions
to be standard.  So, yeah, that's what this PR is changing.  And just to be sure
that everyone got it by default, we're still telling you, "Hey, you shouldn't do
that", if you try to create some below-dust outputs.  It's just, if you really
tell us, "Hey, please allow dust", we're just going to allow it, because it's
okay and you probably know what you're doing if you ask a transaction to be
created in that weird way.

**Mike Schmidt**: Daniela, you mentioned the motivation for this PR was someone
who wanted to do some testing, but I had also seen in the comments on this PR
that you mentioned something, a rare use case would be creating a notification
output to an address.  Would you explain that use case, what that is, what you
mean by that?

**Daniela Brozzoni**: Yeah, that's a weird use case.  So, I was thinking about
BIP47, which is a protocol to basically, I'd say, avoid address reuse.  But
still, I don't really know how to explain that, I'm sorry.

**Mark Erhardt**: Maybe I can jump in there.

**Daniela Brozzoni**: Okay, yeah.

**Mark Erhardt**: So, if I recall correctly, BIP47 is about stealth addresses,
and what you do is you provide an address out of band, and you commit as a new
user that wants to send to, say, a donation address.  You can basically create a
hierarchical deterministic chain of addresses from this public identity by
making an announcement, "Hey, I'm creating a new shared chain with you,
recipient, and where you will receive money from me if I paid you multiple
times.  All the addresses look unrelated, but to make you aware of what they are
constructed like, I need to make this notification output".  And you would
probably want to put very little money in that because I don't think it's
spendable.  Or maybe it is spendable, but yeah, it's spendable by the recipient
probably.  Anyway, I'm not super-familiar with that one either.

**Mike Schmidt**: I guess another dust limit use case might be some of the meta
protocols on top of Bitcoin, in which you can have other assets like
counterparty or whatever, but I'm not sure how popular any of that is anymore.

**Mark Erhardt**: I think they should mostly use OP_RETURN outputs, though.

**Mike Schmidt**: Is that right?

**Mark Erhardt**: OP_RETURN outputs are exempt from the standardness rule that
requires outputs to be greater than dust.  I think they're non-standard if
they're not zero though.

**Mike Schmidt**: The final one.  Oh, sorry.  Go ahead, Daniela.

**Daniela Brozzoni**: Oh, sorry.  Yeah, I don't think at the moment there are
many protocols actually using this below-dust limit.  It's just I didn't really
want to say, "No, we're not going to add it", because I don't think it hurts.
You're still creating a valid transaction, so why not?  And then, yeah, maybe in
the future we might see some weird protocols that basically only miners and
miners' friends can use.  At the moment, I'm not aware of any.

**Mark Erhardt**: I guess it just sort of makes sense.  Say you're building a
new wallet from scratch and you don't have another wallet that you want to use
and you want to test the capability of your wallet to deal with, say, a dusting
attack or a forced address reuse attack, you might want to be able to, at least
on testnet or something, create dust transactions in order to test how your
wallet behaves with that, that it correctly, say, freezes those UTXOs and
doesn't use them by default and things like that.  So, it might be convenient if
you're mostly working with BDK, that you can use BDK to generate those test
vectors.  Trying to steel man the case for this!

_BDK #682_

**Mike Schmidt**: All right, well, great.  I think that wraps up #689.  And now
we have BDK #682, which adds some capabilities for BDK around hardware signing
devices, and HWI, and using this rust-hwi library as well, and then also
including an emulator.  Daniella, do you want to break that down in a bit more
detail?

**Daniela Brozzoni**: Yeah, so basically, I think a couple of years ago, I
started building rust-hwi, and then I just left it there, and I just finished a
couple of months ago with a Summer of Bitcoin mentee.  And what that library
does , it's basically an interface to the Python HWI, but from Rust.  So,
internally we use Py03 and we just talk to Python.  So, the reason behind that
is that we didn't want to just rewrite all the code to talk to other wallets,
because that's really complicated.  I've been talking with another developer and
he was telling me that he actually wants to reimplement HWI from scratch in
Rust.  But yeah, I think that's a huge project, so I'm happy if he does.  But I
really didn't want to do that.  So, I basically built this little wrapper around
HWI so that you can use HWI from Rust.  And then, we recently integrated in BDK,
so that basically if you're on desktop and you have HWI, you can actually try it
out.  You can try building a transaction and then when it's time to sign it, you
tell BDK, "Actually, I have a hardware wallet, and you can use that one to sign
it".

So, I must point out that this is still pretty beta, I'd say.  I think we have a
tutorial on our website that explains how to use hardware wallets with BDK.  If
you have time, check it out, because it's pretty fun.  But it's possible that
you'll encounter bugs, that our documentation isn't really great, and that you
need some more help with installing all the necessary stuff, because not many
people try it out until now.  But, yeah, if you want to check it out, I'm
super-excited about this, and I'm really looking forward to people just testing
it and just telling us what they think, because we have tested it on our
devices, but every time you test something on your own device, it works, and
then users come and they tell you nothing works.

So, if you have some time, you don't have to use a physical hardware wallet.
Actually, I think you should use a simulator because it's just safer.  And I
mean, if you screw it up, it's still a simulator and it doesn't have any money
on it, so it's great.  But yeah, just try it out.

**Mike Schmidt**: Great.  And that emulator for Ledger was added as a way to
test some of this.  Is it envisioned that you would add other emulators, or is
that sort of just good for testing purposes just to have the one?

**Daniela Brozzoni**: So, basically, in the rust-hwi repo, the CI uses Ledger,
Trezor, and I think Coldcard as well, the three simulators we were able to find.
And we just picked the faster to run, which was Ledger, and we just said one is
enough for BDK, because every change we do to rust-hwi, it runs in the rust-hwi
CI, so why adding more and more emulator to the BDK CI?  Yeah, one problem with
that would be that we would have to wait quite a bit before the CI passes, and
that's not great.  Yeah, so we just pick one and we use that one.

**Mike Schmidt**: Great.  Murch, any questions or anything to add on this HWI PR
to BDK?

**Mark Erhardt**: No, sorry.

**Mike Schmidt**: All right.  Well, I guess since we've gone over the last few
recap discussions, it's okay that we end this one early.  Murch, anything you'd
like to announce or add before we sign off here?

**Mark Erhardt**: Well, have a nice September.  So, I hope that the people that
go to the Azores have a great time and make me really jealous, because I'm not
going.  I'll see you next week.

**Mike Schmidt**: Sounds good.  Daniela, thank you for joining us and your
insights to BDK, and especially on short notice.  We appreciate your time.

**Daniela Brozzoni**: Thanks for having me.

**Mike Schmidt**: All right.

**Mark Erhardt**: Yeah, thanks for coming.

**Mike Schmidt**: Thanks, everybody, for your time.  Thanks for listening, and
we'll see you next week.

**Mark Erhardt**: Cheers.

**Daniela Brozzoni**: Bye.

{% include references.md %}
