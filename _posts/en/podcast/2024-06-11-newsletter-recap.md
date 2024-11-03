---
title: 'Bitcoin Optech Newsletter #306 Recap Podcast'
permalink: /en/podcast/2024/06/11/
reference: /en/newsletters/2024/06/07/
name: 2024-06-11-recap
slug: 2024-06-11-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Dave Harding are joined by Fabian Jahr, Anthony Towns,
and Matt Corallo to discuss [Newsletter #306]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-5-11/380386232-44100-2-53b4f2655974b.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mark Erhardt**: Welcome, this is Bitcoin Optech Recap #306.  Today, we're
talking about a bunch of different news items and we will get started pretty
much immediately.  How about we introduce ourselves?  Dave?

**Dave Harding**: Hi, my name is Dave Harding, I'm co-author of the Optech
Newsletter and of the third edition of Mastering Bitcoin.

**Mark Erhardt**: Fabian?

**Fabian Jahr**: Hi, I'm Fabian, I work on open-source Bitcoin stuff, primarily
Bitcoin Core, and I'm sponsored by Brink and also have recently received an HRF
grant.

**Mark Erhardt**: And AJ, sorry, Anthony?

**Anthony Towns**: Hi, I'm AJ, I work on Bitcoin Core and sometimes Lightning
things with DCI.

**Mark Erhardt**: All right, and myself, I'm Murch, I work at Chaincode Labs on
Bitcoin stuff.  I recently became a BIP editor, and it's been a big part of my
work time lately.

_Upcoming disclosure of vulnerabilities affecting old versions of Bitcoin Core_

All right.  For our first news item, let's talk about vulnerability disclosures
affecting old Bitcoin Core versions.  So recently, some Bitcoin Core
contributors have been talking about doing a better job of disclosing what sort
of vulnerabilities existed in Bitcoin Core, especially prior versions, and
they've come up with a guideline on how they want to handle disclosures in the
future.  They especially separate vulnerabilities into four severity classes:
low, medium, high, and critical.  And the idea going forth is that low-severity
vulnerabilities will be disclosed two weeks after a version is released that
fixes or mitigates the vulnerability; medium- and high-severity vulnerabilities
would be disclosed as soon as the Bitcoin Core version, the latest Bitcoin Core
version that is vulnerable to it goes to end of life.  This happens generally
after three more versions are released.  Bitcoin Core maintains the latest two
major branches, and when a third one comes out, the first goes to maintenance
end.  Only critical vulnerabilities would be patched in that version still.  And
then after that, when another version comes out, the first one goes to end of
life, and the second one goes to maintenance end.  So currently, we are
maintaining v27 and 26.  V25 is in maintenance, and v24 is in end of life.

The idea is to start with disclosures up to Bitcoin Core v21, sorry, that is
v0.21 because the rename happened with v22.0, and the idea here is to correct
the public perception that there are no vulnerabilities and that there are bugs
that are being fixed; preservation of knowledge, like what was fixed in the
past, how it was fixed; and to prevent that vulnerabilities are reintroduced
later.  It's also the idea to make it more attractive for security researchers
to work with Bitcoin Core, by giving attribution and providing clarity on
timelines and disclosure policy.  And then lastly, but not least, the idea is to
roll it out over time to first start with the oldest versions, to give
businesses and individuals time to update and to prepare them for more
disclosures to come, so as nobody is surprised when disclosures are made in
versions that they're still running.  Hopefully, it gives everyone enough time
to update to versions that they feel are sufficiently safe for their use case.
So, does anyone have comments on this one?

**Dave Harding**: I'm really excited to learn about these old disclosures.  I
find the disclosure vulnerabilities to be very interesting reads.  It's very
interesting to think about Bitcoin adversarially.  The way some of these
vulnerabilities work is very subtle and it's just very interesting to think
about.  So, I'm really excited for this.  I'm very thankful to the people in the
project, like AJ here and several others, who have taken this initiative to
actually dig through the old security archives, security discussion archives,
and get this sort of information out there.  So, thank you to everybody who's
been working on this.

**Mark Erhardt**: Yeah, AJ, do you have some comments on what we've been talking
about?

**Anthony Towns**: I thought you covered it pretty well.  One of the things that
I think is worth mentioning is that our disclosure policy, even new one, is
going to be very, very slow, conservative long term compared to what is more
expected in other projects.  And one of the reasons for that is that unlike
pretty much any other sort of software, Bitcoin/blockchain consensus things
means that if any substantial proportion of people are vulnerable to a bug, then
that can affect everyone.  It's not just your computer stops working, it's a
price crash where you can't transact or some other problem like that.  And so,
it's not really great that we're taking 18 months to disclose vulnerabilities,
rather than 90 days or something more normal, but as far as we can tell, that's
the best sort of trade-off between keeping the network secure, avoiding giving
script keys an easy way to attack the network just for laughs, and still getting
the information out there.  So, I hope this is going to work out the best that
it can.

I think another thing to think about is that the disclosure policy is a work in
progress.  It's the best thing that we can think of now, but if we think of
better things or if people suggest better things, then that's certainly up for
improvement as we go on.

**Mark Erhardt**: Super.  Thank you for filling in the gaps here.  I realized
that I didn't mention what the disclosure policy for critical severity
vulnerabilities was.  The idea there is, whereas the other ones will be
disclosed on a scheduled timeline, critical vulnerabilities are the ones that
affect the network in general, so for example, bugs that could allow you to fork
the network or lead to a consensus split.  And the idea there is that the
security-responsible developers would get together and discuss, case by case,
what the best disclosure policy would be.  In some cases in the past, these have
been disclosed very quickly to get them mitigated fast.  In other cases, they
have been disclosed later.  But so far in general, disclosures were up to the
party that discovered and reported the bug, and it sometimes was a little
without preannouncement and perhaps if people were on such old vulnerable
versions, they got surprised by the disclosure.  So, the idea here is generally
to at least have a two-week lead notice to let people know, "There's a
disclosure coming if you're still on this version.  I hope you make an informed
decision to stay on it or upgrade".  All right.  Unless someone else had -- oh,
yeah, Fabian, go ahead.

**Fabian Jahr**: Yeah, I would just like to add I'm also excited to learn more
about the stuff that we don't know about yet.  And as AJ said, I agree that
we're quite conservative, and I didn't comment on it yet but I think that there
are some people that said that they find parts, at least, of the policy a big
aggressive.  But I would say that there's always also the chance or the risk
that the vulnerability becomes discovered by somebody else, by a second person,
or maybe that the person that originally disclosed it gets drunk at a bar and
brags about it there.  So, that's always a point that needs to be kept in mind,
and I think I didn't see that mentioned anywhere in the argument so far.

**Mark Erhardt**: Right, that's one additional point.  Also, that's a problem
with the announcing in two weeks, that you'll announce something, gives people
two weeks to brood over the change logs and see what there might be to find the
vulnerability.  But either way, so there is now this policy.  One other thing
that hasn't been mentioned yet is that this does affect, for example, also other
cryptocurrency networks that share a code or that are forked off from Bitcoin's
ancestry at some point.  And among others, for example, it seems to me that
Litecoin and Dogecoin would be affected.  So, if you're interested in these
cryptocurrencies, maybe you try to reach out to the developers and let them know
that they should perhaps inform themselves.  All right.  Unless anyone else?
Yeah, go ahead.

**Anthony Towns**: Most of those other blockchains, including the Bcash and
ecash, have already been at least made aware of this, or are already aware of it
too.

**Mark Erhardt**: Yeah.  My understanding is that the people working on the
disclosures have been trying to reach out, and some other projects have been
requested to add a disclosure policy so that there is a way to contact them.

_BIP and experimental implementation of testnet4_

All right.  Let's move on to the next news item, BIP and experimental
implementation of testnet4.  So, Fabian proposed that we -- well, there's been
some discussion for a while that testnet3 is being used or being sold, and that
it's time to nuke it and start over.  So, Fabian has been working on creating
the actual PR to switch to testnet4, in Bitcoin Core at least, and what exactly
the design parameters of that would be.  And one of the big discussion points
was how exactly to handle the 20-minute exception, where in testnet3 after 20
minutes, or rather if you mine a block that has a timestamp that is 20 minutes
past the previous block, you may use difficulty 1 to mine that block, which is
the minimum difficulty.  So, if it takes a while to mine a block, at some point
anyone can go and use even a laptop to mine a block, or if they immediately want
a block they can just fudge their timestamp to go ahead and mine a block.

This has, for example, led to the issue, or especially led to the issue, that if
you mine the last block in the difficulty period with difficulty 1, you actually
do reset the difficulty that is used to calculate the next difficulty period's
difficulty to 1.  So, this has led to the so-called block storms where people
have been producing hundreds to thousands of blocks per minute, and this causes
all sorts of problems.  For example, the testnet3 is already well past the tenth
halving, and the reward is minuscule.  So, Fabian, can you tell us a little more
about what design ideas came up with the block storms and how it is proposed to
be fixed in testnet4?

**Fabian Jahr**: All right, thank you.  So, first of all, I want to credit
Jameson Lopp for writing the initial blogpost, the mailing list post that really
motivated me to look into this further and kind of explore it, or see what I
would use as a fix for the 20-minute exception.  So, what's still in the PR
right now and what I came up with originally as well, is when we are at the end
of a difficulty adjustment period or when we are adjusting the difficulty at the
end of a period, then if we have the last block of the period be a difficulty 1
block, so that 20-minute rule has been used and so the difficulty is very low,
we don't use that difficulty right away, but instead we look back through the
whole period to all the 2016 blocks and try to find a block that has an actual
difficulty in it.

An alternative design that basically does almost the same thing, but is maybe a
bit easier to explain, is that the last block in the period would just be
prevented from using the 20-minute exception at all.  So, that would have
basically the same effect, just that we would never be able to use the 20-minute
exception on that particular block.  There were some other ideas as well.  One
idea from AJ is to persist the real difficulty in the version field.  This is
more robust in the sense that this even can transcend several periods.  And so,
that's quite a nice fix, I would say, the most complete fix, the most robust
fix.  But the downside of it is that it's quite intrusive.  So, right now, it's
I think in a PR, just five or six lines of code, and yeah, this would be more
intrusive.  Then I think there were quite a few discussions about increasing the
minimum difficulty on the whole chain.  This was dismissed as making it
completely impossible to mine with CPU miners.  There was also a conversation
about kicking out the 20-minute rule completely and just have the whole chain be
exactly like mainnet.  This was also dismissed for pretty much the same reason.

Additionally, what we've added right now in the PR is that we also prevent the
time warp attack.  But I'm not sure, maybe you want to still discuss the
20-minute rule a bit further, if there are questions?

**Mark Erhardt**: Yeah, I have a couple of points that I want to ask/inform
about.  So, in testnet3, every single block was eligible to be mined with the
20-minute exception.  So, whenever 20 minutes passed or you were able to set a
timestamp that was 20 minutes past the previous block, you could always mine a
block with difficulty 1.  Famously, this leads to the block storms.  So, in both
of the designs that fixed the block storms, either the first or the last block
in the difficulty period has to be mined at the actual difficulty.  Why can't
the difficulty, the nBits field, just remain at the actual difficulty and the
block can still be evaluated to allow a low difficulty if the timestamp is
higher?

**Fabian Jahr**: Sorry, can you repeat the end of the question?  I didn't hear
it.

**Mark Erhardt**: Would there be a way to allow every block to be mined at
difficulty 1 without causing block storms?

**Fabian Jahr**: Yeah, well that's basically the suggestion from AJ.  We would
need to preserve the actual difficulty in some other place than the real
difficulty right now, so that it persisted even if all of the blocks in a
particular period use the 20-minute rule, which is still theoretically possible.
There is some limit on it in terms of how much you can do at a time because of
the 2-hour rule of how many blocks, how much you can mine to the future.  But
the real only robust way would be to have it saved somewhere else, or we would
need to have other very, very intrusive changes in the code.  But right now, the
difficulty is basically calculated once in the first -- when we calculate how
much, what the new difficulty will be for the first block of the new period.
And then basically, that is the assumption that the difficulty is just carried
through all of the blocks in that period, and so the next first block of the
next period will look back on the last block of the previous period.  And so,
somewhere there we need to preserve it in a different place, otherwise it's not
possible.

**Mark Erhardt**: Right.  I especially wanted to get to the point that, so
blocks in themselves are also checked unilaterally, where the difficulty
statement from the header is used to validate the hash, the quality of the hash
that the block header calculates to.  So, it would be pretty intrusive to
decouple the nBits field from the actual difficulty of a block, is my
understanding.  I think AJ wanted to say something.

**Anthony Towns**: Yeah, I just wanted to say that the nBits difficulty thing is
gathered through is a validation code, so it would be a much more intrusive
change to do it that way.

**Mark Erhardt**: All right, and so the other thing that is getting fixed is the
time warp attack.  So, why is the time warp attack being fixed in testnet now?

**Fabian Jahr**: So, we have the 20-minute exception rule still in there.  I
just mentioned that you can mine at max 2 hours into the future at any point in
time and afterwards, the nodes will reject the blocks, at least for the time
being.  So, if you could still exploit the time warp bug, then you could still
do a lot more damage with that.  It would still not be as bad as the block
storms themselves, but yeah, this would be an additional way to kind of grease
the network a little bit more, if somebody who just has a CPU but is quite
motivated to annoy people on testnet or just get a hold of a lot of testnet
coins, then that would be possible.

**Mark Erhardt**: All right.  So, testnet3 has been around for, what, 10 years
or so, 11 maybe?

**Fabian Jahr**: 13.

**Mark Erhardt**: 13?  All right!  How do we bootstrap testnet4?  How does it
roll out to people?  How do people get coins again?  I guess this is maybe more
of a question to AJ, who's been running the signet faucet.

**Anthony Towns**: I thought for testnet4 the answer was simple.  You just let
people mine blocks.

**Fabian Jahr**: Yeah, I think so.  It's an orderly launch.  I'm not sure, we
can always still reset the Genesis block at any point before the next release.
But at some point, we just have to decide, okay, this is going to be actually
the Genesis block.  And then once that decision has been made, then people will
just mine on it.  That was a development that kind of surprised me also,
honestly.  I just opened this PR as a draft mode and just really thought we
would be having more theoretical discussions, but then a couple of actors, like
mempool.space, for example, took the PR and just started an instance with, yeah,
with a mempool.space showing the testnet4 coins, and so on.

So, yeah, there's already quite a few tools where you can at least, with their
master versions, you can also play with testnet4 there.  So, yeah, people are
actually, I think, at least some projects are looking forward to it and just get
started playing with it right away.  And so, yeah, I'm not sure if we're still
going to reset the Genesis block or not, but yeah, Matt would like to speak.

**Matt Corallo**: One of the really nice features of testnet3 was that very
early in its history, I mean the first few hundred blocks have a lot of really
great test cases, mostly in scripts, but also there's like a time warp exploit
and stuff, obviously wouldn't be useful here, but you know, just general test
cases of consensus.  And I think basically, Bitcoin Core's entire unit test
suite at the time was included.  And I know it's come up in a handful of places
that I'd suggested doing something similar with testnet4, maybe taking some of
the output of a fuzzer, of the script engine, or also the unit tests, and any
other interesting test cases we can come up with, and trying to put those in the
first few hundred blocks of testnet4.  I guess it's already too late with this
Genesis block, because people have already started mining it.  But what's the
thinking on ending and copying over that kind of test suite in testnet4?

**Fabian Jahr**: For me, it's a great idea.  I just personally haven't had the
time to get around to it.  And, yeah, there are a couple of issues with just
copying it over and getting all of these interesting scripts from all of the
different sources that are interesting, like the fuzzing results that we have,
also the taproot functional test, which has some random script generation
included in it, also has been named as an interesting source.  So, that's kind
of a project in and of itself.  I don't really have a strong opinion if this
needs to be within the first 100 blocks, or if we put it into the chain that has
been mined already and then we set a checkpoint afterwards.  As long as we have
it in the chain and we have a checkpoint afterwards, I think that's great.  And,
yeah, I would say if this sounds like an interesting task to any of the
listeners or any of the listeners of the podcast, feel free to contact me.  I'm
happy to work with you on this.  I hope I can get around to it also at some soon
point in time, but if somebody else is interested in this and this sounds like
an interesting project, I think it would be a cool thing to work on.

**Mark Erhardt**: All right.  So, if anyone wants to help put in all sorts of
weird transactions and test cases into the up-and-coming testnet4, please
contact Fabian.  Otherwise, it seems that testnet 4 is more or less organically
launching already just by some volunteers starting to mine on it, and it may or
may not be reset one more time.  And then hopefully, we can just get rid of the
mess that's testnet3 with its very high block height and block storms and people
trying to sell testnet coins.

One point on time warp, I think it's cool to have time warp fixed in testnet4
too, because it's being proposed as a fix in the Great Consensus Cleanup.  So,
if we can already do it on testnet4, we would be very confident that it works
fine on backporting it to mainnet eventually.  All right, let's move on, unless
someone else has a comment.

_Functional encryption covenants_

Let's move on to the next news item, which is Functional encryption covenants.
Dave, you wanted to take that one.

**Dave Harding**: I don't know that I wanted to take it, but I will.  So, Jeremy
posted to Delving Bitcoin about people using functional encryption to allow
pretty much any sort of covenant on Bitcoin.  Now, I'm not an expert in this,
but I'm going to try to explain how it works.  Briefly, the idea of functional
encryption is kind of what it sounds like.  It's a way of encrypting a function,
a computer program, turning a computer program into a black box.  So, I can have
a computer program on my computer, and I can tell it to do anything I want, and
then I can distribute it to everybody else, and they can't see the actual source
code of that computer program, but they can feed it inputs and deterministically
receive outputs from it.

So, what I think Jeremy is proposing here is to use this and to stuff into this
black box function a private key for which a particular public key is known.
And so, this function will operate on an unsigned or partially signed Bitcoin
transaction, and it will inspect that transaction, and if the transaction does
what the author of the program wants it to do, it will spit out a signature
corresponding to that public key which was distributed with it.  So, if you want
to have a covenant that only signs a transaction if its txid starts with a zero,
so it hasn't got a proof of work (PoW), let's say, just to use an arbitrary
example here, we can create a black box that does that, and that black box
contains a private key.  And it will only spit out a signature if the txid of
the transaction, so the data minus its segwit signature stuff, starts with a
zero.  So, we can do pretty much anything we want with covenants and all that
appears on the blockchain are signatures and public keys, so it's completely
oblivious to the world exactly what is happening, but we can have any sort of
covenant function.  So, I think that's basically what's happening here.  And
yeah, I think it's a really interesting idea.  I don't know if anybody has
questions or comments about it.

**Mark Erhardt**: I think I will -- yeah, Matt, go ahead.

**Matt Corallo**: I wanted to do one nitpick.  Functional encryption does not
provide what you described.  Function-hiding functional encryption provides what
you described.  Functional encryption does not guarantee that people can't see
the contents of the function, which in this case would break the scheme because
the contents of the function would basically include the private key that's
going to do this multisig.  Function-hiding functional encryption is a
marginally more difficult problem than existing standard functional encryption,
and provides what you described is needed for Jeremy's work.  So, it's either
function-hiding or multi-input functional encryption, which are equivalent but
slightly different ways to get the same result.

**Mark Erhardt**: So, my understanding from Dave's summary was that there are a
couple of problems here.  So, one is it doesn't require consensus change, which
is amazing, of course.  The downside is apparently, it relies on experimental
cryptography that is maybe not sufficiently well-researched to want to rely on
this yet, and that you do need to trust these third parties that run the
program, or I'm not entirely sure how the third parties get in here, I did not
read the part.  Yeah, Matt?

**Matt Corallo**: There's a function that's a trusted setup.  So, we think of a
lot of these SNARK systems, you have this trusted setup step, and you have to
trust that that trusted setup step was done correctly.  In theory, it could be
done across multiple parties, like many SNARK setup ceremonies have been done,
but you can also do it across a single party, but you have to trust them.  Once
it's set up, in theory, you don't need to trust anyone, but describing this as
just assuming novel cryptographic assumptions I think is overly simplistic.
This doesn't really exist, this cryptography.  It's not clear that the proposals
for functional encryption that exist, or multi-input functional encryption, are
able to do any kind of non-trivial functions.  And for Jeremy's scheme, we need
not only a non-trivial function, but we need to do a full ECDSA signature or
schnorr signature in it, which is very non-trivial.

So, yeah, it's just not clear that this exists in any meaningful sense.  But if
it were to exist, it would be cool.

**Mark Erhardt**: Yeah, so it sounds like it's more future work sort of related,
but it certainly fits the overall direction of discussions with this huge focus
on covenants lately.  AJ, this is sort of your topic.  Do you have any thoughts
on this?

**Anthony Towns**: Not really.  I mean, you've got cool cryptography stuff that
lets you do stuff offchain.  That's always better.  But the question for all of
this stuff is whether the cryptography actually works.

**Mark Erhardt**: All right, thanks.  I thought it reminded me a lot of what
Lloyd Fournier, LLFourn, was doing with DLCs and oracles, with being able to get
signatures from oracles on specific real-world matters, and then being able to
execute contracts based on that, which also was sort of putting a lot of the
logic in the contract out of band and not onchain.  But anyway, it's good to see
more research on this.  Thank you, Dave, for covering it.

_Updates to proposed soft fork for 64-bit arithmetic_

All right, moving on to the next topic.  The next topic is about 64-bit
arithmetic.  Chris Stewart updated his proposal to instead of adding new opcodes
that allow arithmetic with 64-bit numbers, to update the existing opcodes to
allow it.  And he went into the considerations of that, where that means, for
example, that other scripts that currently rely on these shorter inputs would
need to be updated.  For example, OP_CHECKLOCKTIMEVERIFY (CLTV), would then need
to take an 8-byte parameter instead of a 5-byte parameter.  There's still some
ongoing discussion about whether the results should return whether the operation
was successful, or there, for example, had been an overflow, or whether it
should just fail on an overflow, or there's different design ideas there still
that are being discussed.

My understanding is that AJ was also involved in this discussion, so if you have
something to add here, you could!

**Anthony Towns**: One thing I'm not getting from the writeups of these is that
this is all based on using a different tapscript version, right?

**Mark Erhardt**: That seems to be the case, yes?

**Anthony Towns**: Yeah, for any of this stuff that's doing significant changes
to script, that seems like the best idea to me.  That's effectively what
Elements has done with their implementation of tapscript that adds similar
features to this, and it just gives you a bit more flexibility, which is nice.

**Mark Erhardt**: All right.  Anyway, we've had Chris on I think a couple times
already, so if you want to look at Newsletters #285 and #290 and corresponding
Recaps, if you want to get into that topic, you can find more information there.

_`OP_CAT` script to validate proof of work_

All right, moving on to the next topic, and this is AJ's own.  You created an
OP_CAT script to validate proof of work.  So, the idea here is that if you want
to make an anyone-can-spend script that people can execute if they have done
enough PoW, you could for example create some caches of signet coins that people
could just collect at will, and you build a construction using OP_CAT to do so.
Do you want to tell us more about that?

**Anthony Towns**: Sure.  So, the background for this is that I've had obviously
a little web faucet for signet for ages.  And every now and then, people decide
that signet coins are awesome and they want to have all of them.  And so, we've
had to limit the web faucets in really annoying ways, so they'll only give you
like 0.01 of a signet bitcoin.  If you ask for more than 1, then you'll just get
silently rejected, and if you get too many from some IP, you'll get silently
rejected, and so on.  And recently, there's been the BabylonChain, who's testing
out their staking for altcoins on top of Bitcoin idea on top of signet, and so
they run a few testnets on top of signet for that.  And at one point they were
incentivizing people trying out the system by giving them real NFTs, whatever
that means, for participating, which then created high demand for signet coins
and people actually started really trying to get those coins from the faucet, to
the point where the faucet was lagging by days or weeks, was crashing because of
malformed things and whatever else.  And so, maintaining the faucet's been
getting really tedious.  There's been a bunch of questions from devs about how
they can get coins just for participating in this and so forth.  And so, it's
been a mild annoyance for a while now to see if we can come up with something
better.

So, once OP_CAT came in, I figured that PoW is just you get some data, you put
it together, you take a hash of it, some of the data has got to commit to
whatever thing you've been working on and the rest of the data can just be
random nonsense.  And that's really all that PoW is.  And once we've got OP_CAT
enabled, then that is really all that script needs to be able to do that.  And
so, the Delving post goes into a bit of detail explaining how it works, but the
basic idea is that you have the coin that's the giveaway that you just have to
do PoW in order to be able to claim.  You provide a public key and a signature,
any public key is fine, the script that I've got just uses the secret key one,
and then once you've got the signature that's spending it to yourself, then it
doesn't matter if someone reuses that signature because it's still committing
the funds to go to you.  And so, you can just do PoW on top of that, and then
the script can verify that you've done PoW on top of the signature and the
signature is valid, and you've got effectively the same philosophy of
distributing coins as the original Bitcoin has.

**Mark Erhardt**: So, this sounds like you've sort of put the onus back on the
collectors of the signet coins.  They have to do work in order to collect it,
but you can set it up completely independent from that, and hopefully wouldn't
get as inundated by requests and your faucet wouldn't get stomped by demand
anymore.  So, how complicated would it be to implement the collection of these
funds though, because that seems like another hurdle for actually making this
less work for you?

**Anthony Towns**: So, there's obviously two steps for it.  One is writing the
script, which is what's in the Delving post; and then to send coins to that
script, you've got to create the taproot address for it and just sendtoaddress.
So, I've got it fully running on screen somewhere that every time a block is
mined on signet, sends coins to three addresses with 0.125 signet bitcoins, 1
signet bitcoin and 2 signet bitcoins, so 3.125 in total, which matches the
mainnet reward at the moment.  And that's obviously really easy, because once
you've set up the addresses, you just reuse them every time.  And the difficulty
is claiming the coins, and that's why there's a Python script for that, which is
listed in the Delving post.  So, the Python script for that puts half the work
into Bitcoin, where it sets up a wallet to track all these PoW coins, and then
queries the wallet for whichever ones are the oldest essentially, the oldest
aren't spent obviously, and then picks that one and does PoW on it and sends it
to your address if the PoW succeeds.  So, it's just a matter, in theory, of
downloading, compiling Bitcoin and running the script, I think.

**Mark Erhardt**: Okay, so you've already done all the heavy lifting for
would-be collectors of the signet coins.  One thing that just jumped into my
mind when you described this, if multiple people want to collect coins at the
same time, wouldn't they potentially compete for collecting the next cache?

**Anthony Towns**: Absolutely.  So, at the moment, the difficulty is, I think,
20.  So, I've also got a thing that's running the script constantly with a
maximum difficulty of 24.  So, the equivalent of Bitcoin's difficulty 1 in this
is difficulty 32, so it's 2<sup>8</sup> times, 256 times easier than a
difficulty 1 block in Bitcoin or testnet, and I've got that just running on my
system once a minute or so just to keep the difficulty slightly non-trivial.
It's still pretty trivial.  If anyone wants to run the script, find the best one
available at the moment, it'll complete in about 10 seconds.  If they do that in
a loop trying to claim as many coins as they can until their CPU is overheating
or whatever, then the oldest coin will be taking 10 minutes to do PoW for, or 3
minutes or something, and then there will be conflict on those.  And the script
doesn't do anything special to make that work better or anything.

**Mark Erhardt**: Oh, that's very nifty.  So, basically, would-be signet
collectors can mine for signet coins just like they would be mining blocks on
Bitcoin, and the difficulty actually goes up if there's a lot of demand for it.
That really sounds like it would work as a deterrent for these
want-to-collect-everything sort of approaches.  This is pretty cool.

**Anthony Towns**: Yeah, so the other thing I've set it up is so that the string
that you're doing PoW on looks like a block hash.  So, there's 64 bytes of
signature in the space where the previous block hash and merkle root would go,
and you can pretty much just manipulate the other byte in that.  So, you could
essentially run a pool, I think, collecting signet coins if you really wanted
to.  Maybe that would be a fun strategy to do, I don't know.

**Mark Erhardt**: So, is this the first real signet OP_CAT application that you
know of?

**Anthony Towns**: Yes, I don't think I know of any others yet.

_Proposed update to BIP21_

**Mark Erhardt**: All right, so OP_CAT is being used on signet now, apparently!
All right, unless someone else has something, let's move on to the last news
item.  This is about an update to the BIP21.  So, hopefully many of you are
familiar with BIP21, which specifies a way of communicating Bitcoin URIs.  So,
whenever you scan a QR code to pay a wallet, that is specified by BIP21.  Or is
it?  Because it turns out that actually, the specification in BIP21 is not what
most wallets that use it have implemented.  Almost all implementations deviate
from the specification in the sense that, for example, BIP21 requires a legacy
address in the body field of the URI, and over time people have started putting
bech32 and bech32m addresses there as well, and most implementations of BIP21
interpret these as acceptable.  There's also been some query parameters added to
the general use of BIP21, which for example includes a Lightning query
parameter, and allows people to also encode a BOLT11 invoice in BIP2-style URIs.

So, my understanding is that this PR to update BIP21 is trying to achieve two
things.  On the one hand, it's trying to inform readers of BIP21 on the
differences of the original specification and the current implementation of
BIP21 in most wallets; and the other one is to add more information for
forward-looking design.  For example, we have silent payments coming up that
people are very excited about right now.  People are going to want to use
something like BIP21 for offers.  And the use of BOLT with the BIP21 is also not
specified, so Matt has been putting in some of that.  All right, so there's been
some back and forth on the BIP.  I've seen also some discussion with the authors
of silent payments on it.  What's the status of this, Matt?

**Matt Corallo**: Yeah, so there's some question about it.  So, the BIP process
has a few states, but ultimately BIPs receive this final state, right?  We're
sort of saying basically, this is actively in use across the network and we
can't really change it anymore because it's what people do, and if you change
the spec out from under people, that wouldn't make any damn sense.  So, BIP21
has been in final for quite some time, and it's not entirely clear what the
rules for that are.  So, can a final BIP be amended?  I think there's some
agreement that at least the first part of what this PR does that you described,
Mark, just kind of describing what exists today in the wild in practice and
updating the spec to describe that is probably fine.  And then there's some
debate over, is it okay to then say actually also for future uses of the BIP,
you should do it this way?  And specifically, that looking at things like silent
payments, BOLT12 offers, and really new address formats, the proposed PR
describes a way that basically all new address formats should be in query
parameters, as a way to provide seamless upgrades for people who want to use new
payment formats, and then be able to do that in a consistent way.

As you noted, Mark, there was some discussion specifically around silent
payments, as to what the format should look like exactly.  It was mostly
bike-shedding, but just discussion back and forth on the exact format.  There
were some initial ideas that I think eventually we came to agreement on, but
there were still some alternative proposals from Josie, I believe it was, who
was proposing things slightly differently, again not in a major way that impacts
things, but just a different format.  And my PR to the BIP21 change suggested a
concrete specific format for future payment instruction formats, for future
address formats.  So, the status of the BIP change is basically, we need to
figure out whether it's okay to do this to a final BIP.  Should there be kind of
forward-looking guidance added to a BIP that's already been marked final, or
does that need to be in a new BIP?  And yeah, I mean I think people haven't had
a super-strong opinion.  I don't know if people listening here or other speakers
here have a strong opinion about this, but that's kind of where it is.

It's kind of on hold because, yeah, should forward-looking guidance be added?
And then, Dave Harding had raised some questions around, does this give the
author of that original BIP some kind of privileged position to demand that
forward-looking guidance?  Then, does that give the author of that BIP some kind
of privileged position to suggest that this is the way it should be done and
only this way, and other people aren't allowed to do other ways, or to override
other people's views?  Again, there was some back and forth on the issue, and
you can read the issue if you want, but there was not really a strong conclusion
there either.

**Mark Erhardt**: All right, Dave, so since you were actively participating in
this debate, do you want to explain your thoughts on this?

**Dave Harding**: Well, I think Matt gave a very good summary.  I'm completely
in agreement of updating the BIP to reflect how people are using it and have
been using it for years.  I do worry that if there's any sort of debate or
difference of opinion, or even there could be any difference of opinion over how
to use a BIP in the future, if that BIP is already final, I think I would prefer
to see the proposal put into a new BIP, just because anybody who has already
implemented the BIP based on what it currently says, they may now be out of
specification if the BIP is updated to say, "This is how you should do it in the
future".  And I think we want people to say, "I implemented BIP21 and it was
final at the time that I implemented it, and I'm good to go".  But I don't have
a very strong opinion here and I don't want to hold up a useful change to the
BIP, just on this vague sense that I have that the best way here to do it is to
make sure that if we're giving advice to the future in a final BIP, that it
should be a separate BIP so that everybody has the opportunity to propose their
own different BIP.

But that was my only thought there.  I put it out there.  Matt and I had, I
think, a healthy discussion about it on the BIP PR, so anybody who's interested
in the details can go read that.  And like I said, however this goes, I'm not
going to be upset about it.

**Matt Corallo**: I think I would agree with you strongly, Dave, if it were the
case that the proposed change somehow changed implementations, that like you'd
implemented something, it was final at the time, and now your implementation is
no longer in line with the BIP.  I think the proposed changes here are really
only forward-looking guidance, because the BIP has already been used in this way
where new address formats are being added as query parameters, specifically
Lightning BOLT11, but I think there's also some discussion and maybe agreement
that this will be at least an option for people using silent payments.  Some
people might not want to have a standard onchain fallback, but some people
might, and those who do would use a query parameter.  And this is also being
used for BOLT12, at least in its current nascent state.  And so, the change here
is really only forward-looking guidance and wouldn't impact any existing
implementations, because there's no thing to implement there, it's just as a
suggestion for future additional Bitcoin payment instruction formats.

But yeah, I mean there's some question over, does this give BIP authors more
"power" to demand certain things be done in a certain way?  And yeah, as
mentioned, there's a bunch of back and forth on the BIP issue there.

**Mark Erhardt**: Yeah, as someone recently more involved in the BIP process, I
would also agree with the sentiment that actually final BIPs should no longer be
updated in the sense that you can check off listing the features of your
software, implement BIP21, and that should continue to be true in the future.
Basically, my principled stance would be that final BIPs, especially like BIP21
has been out for 12 years, in principle shouldn't be amended any further.  But
in this case, yeah, it seems to be backwards-compatible, in the sense that an
implementation that wants to use any new features that are now described as
future guidance, they would be able to do so, they probably do it in that way
anyway, and anyone that tries to then parse the URI would either succeed if
their wallet also has followed this guidance, or would just reject or ignore
parts of the URI or the whole URI if they cannot parse it.  Do you want to
follow up to that, Matt?  You're unmuted.

**Matt Corallo**: Was there a follow-up required there?

**Mark Erhardt**: Okay, no, I just saw that you weren't muted.  Anyway, okay.
Anyway, if you have strong opinions on whether or not BIPs should be prevented
from being updated after they're final, or in this specific case, whether an
exception is warranted for BIP21, I think there is a mailing list post about it
and there is also the PR.  And if there's probably nobody that has strong
feelings about that in the contrary, it will probably get merged eventually.
So, yeah, make up your mind.

Okay, this wraps up our lengthy news section this week.  We will be getting to
Releases and release candidates.  Thank you everyone for joining us for your
news items.  If you are busy and have to get to other things, we understand.
Thanks for taking your time anyway.  If you want to stick around, you're welcome
to.  There might be other stuff coming up in the rest of the newsletter that is
interesting to you.  For example, there's an LDK PR later.

_Core Lightning 24.05rc2_

So, we've got two Releases and release candidates.  There is Core Lightning
24.05 in RC2.  So, if you rely on Core Lightning (CLN), please be sure to read
the release notes.  Maybe if you have a big operation based on it, put it into
your testing environment and see that everything continues to work as you need,
and make sure to give feedback and report issues to the developers if you find
anything adverse in your testing.  I'm assuming that we will be talking more
about CLN when its actual final version is out.  And, oh, yeah, Dave?

**Dave Harding**: So, it looks like it was recently released since we published
the newsletter, so we will definitely be having some more details about that in
next week's newsletter and hopefully having some discussions on the next recap.

_Bitcoin Core 27.1rc1_

**Mark Erhardt**: Super, thank you.  I hadn't actually caught that it was out
now.  The same is actually true for Bitcoin Core 27.1.  In the time between the
newsletter coming out or being written and today, 27.1 was completely released.
This is a point release, or a minor release from the 27 branch, which is the
latest branch.  There's a bunch of bug fixes regarding build and P2P, RPC,
miniscript, and GUI, and a few other things.  Nothing really jumped out as a
major issue to me, but if you're on the 27.1 branch and had any sort of issue,
or generally want to be up to date, please consider the 27.1 release.

Right, all right, we're coming to Notable code and documentation changes.  Dave,
did you want to take the first one?

_Core Lightning #7252_

**Dave Harding**: I'll take the first three, actually.  So, the first one, and
we still have Matt here for this one, this is a change to CLN, but it actually
has some effect on LDK, or LDK has some effect on the reason, the motivation for
this change.  So, CLN has this setting called ignore_fee_limits and it's marked
in their documentation as a dangerous setting.  It's something that you should
only be using when you completely trust your counterparty.  And this setting,
what it does is it does what it says, it ignores the fee limits in the protocol.
It won't close channels because fees have gone out of the parameters, out of the
range that is acceptable to CLN.  And it will also, when a channel is being
cooperatively closed, it will tell its counterparty that it is willing to accept
any channel, any proposed fee on channel between the minimum number of sats
allowed in the protocol and the max channel size.

LDK previously had a change, it looks like that's LDK #1101, which, "Always
selects the highest allowed amount", when the counterparty proposes a
cooperative close.  So, the combination of these two settings, between CLN and
between LDK, is that LDK is always going to try to close the channel with the
max_channel_size.  It's going to say, "Hey, if you're willing to pay all of your
value to fees, well I'm happy to take that".  And we do have a note here that
that's contrary to the BOLT specification.  Matt can talk about this, although
I'm just going to say, I mean I think it kind of makes sense from LDK's
perspective, and maybe the specifications should probably be changed here to
reflect LDK's behavior.  Because if your counterparty says, "Hey, this is the
highest fee I'm willing to accept", you should probably always just accept that
fee.

So, what happens here is, if you use ignore_fee_limits with your CLN Node, and
you connect to LDK, and if you're the channel opener, which means you're
responsible for paying fees, you can end up paying an excessive amount of fees.
But again, I want to go back to the point that ignore_fee_limits is explicitly
marked in CLN's documentation as a dangerous setting that you should only be
using with counterparties that you trust.  So, I don't consider this to be a
really major bug here, even though it looks like you're massively overpaying,
but it is something that they wanted to fix.  And the way they're fixing it now
is that they're going to ignore ignore_fee_limits when it comes to cooperative
closes on the CLN side.  They're going to propose a fee range which they would
normally propose if the ignore_fee_limits setting was not set.  I don't know,
Matt, did you have any comments there?

**Matt Corallo**: Yeah, so sadly, what's happened in Lightning, because
Lightning requires this pseudo consensus between channel participants over the
Bitcoin Network fees, and because fee estimators in the Bitcoin Network are
obviously fairly diverse and have different takes on the current feerates and
what's reasonable and what's not, many Lightning nodes, and LND started this
trend, of just being willing to accept basically anything the peer sends as a
way to avoid force closures.  But also, the result being that you put your
channels at substantial risk of not being able to get the chain if you need to,
if someone's performing an attack, if there's a Hash Time Locked Contract (HTLC)
that's been held too long and you need to get the chain, you won't be able to.
But users complain a lot about force closures, and so a lot of users want to
never force close, even if their peer is setting a feerate that makes no sense
at all.

Again, LND pushed a lot of users in this direction.  I think LND does basically
this by default, not quite I think, but basically this.  So, CLN had to add this
option because their users were demanding it.  As a result, I think a
non-trivial number of CLN users probably do use this option.  Then, as you
noted, it had some potential side effects during co-op close, that maybe wasn't
really the thing that users were intending to do, but that resulted in this bad
incompatibility with LDK.  Ultimately, of course, the fix for this is this v3
co-op close that people are working on in Lightning, which fixes all these
issues and more, and just is an actually incentive-compatible co-op close,
unlike the current v2, and even more so than the old v1.  So, that's the real
fix for this, is an incentive-compatible co-op close that doesn't have these
weird incentive games.

**Dave Harding**: Go ahead, Murch.

**Mark Erhardt**: I just wanted to say, as we're in our Notable code and
documentation changes section, if you do have a question or a comment from the
audience, please raise your hand and we'll give you speaker access so you can
chime in.  Dave, back to you.

_LDK #2931_

**Dave Harding**: Okay, I mean I think that's it for Core Lightning #7252, so
we're going to move on to LDK #2931.  This is an enhancement to their logging.
Again, Matt, feel free to chime in at any point, but this is their logging
during pathfinding.  So, when you're trying to make a payment, LDK will do
pathfinding to try to find the optimal route based on various criteria, mainly
payment reliability and fees.  And this logs additional data because, as I
understand it, a lot of people tend to have questions about this, payments fail,
and this logs additional information that they can provide optionally to the
other key maintainers if they want to look into why a particular pathfinding
attempt failed.  Matt, did you have anything to add on that?

**Matt Corallo**: Yeah, I think this is a common problem we see across Lightning
implementations, where people try to send a payment, the pathfinder either picks
a route that really wasn't great, or says there's no route, and users complain
and the response is, "Well, I mean, Dijkstra’s didn't find a route".  So, these
issues are notoriously hard to debug across all the Lightning implementations,
and so we've been trying to, over time, we've tried to add a number of bits of
logging here and there to kind of try to give us as much context as possible
when we see a log to recreate a little bit of what happened.  It's not perfect
and it's far from what we would like it to be ideally, but short of actually
dumping the whole network graph into the user's log, which would be very
voluminous and isn't really super-practical, it's kind of the best we can do.

_Rust Bitcoin #2644_

**Dave Harding**: Sounds good.  So, moving on to the third PR we have here,
which is Rust Bitcoin #2644, and it adds a new function for HMAC (Hash-based
Message Authentication Code) extract-and-expand key derivation function to the
bitcoin_hashes component of Rust Bitcoin.  This is something that is required to
implement BIP324 v2 peer connections, that's encrypted peer connections for Rust
Bitcoin.  But I asked us to have a writeup here for this, because there's also a
mention on the PR that some of the payjoin contributors also want to use this
function for the next generation of payjoin coordination.  So, this is a
function that's useful outside of BIP324, and so I just wanted to make sure
there was a note here that it was available to anybody else who wanted to use
it.  Okay, Murch, I'm going to turn it back to you for these BIPs and BLIPs.

_BIPs #1541_

**Mark Erhardt**: Thank you, Dave.  So, the next item is BIPs #1541, and that
adds BIP431, which was recently assigned a number, and describes Topologically
Restricted Until Confirmation (TRUC) transactions, also formerly known as v3
transactions.  So, the BIP for v3 transactions is merged now.  What this BIP
describes is how Bitcoin Core intends to behave when it sees a transaction
labeled as v3 transaction.  So, clearly this is an implementation-specific
detail, but it is shared as a BIP because a number of other Bitcoin
implementations may be interested in creating v3 transactions, and would be sort
of requesting this special behavior from Bitcoin Core and any other
implementations that implement TRUC transactions.  So, TRUC transactions seems
to be progressing.  I hear that various Lightning implementations are looking
into whether they want to use those for their new commitment transactions,
because the intention is of course that any v3 transaction, or TRUC transaction,
would be limited to 10 kB in v size, and any children v3 transactions, of which
there can only be one, would be limited to 1 kB, and that would of course make
it much harder to create pinning attacks, which is the whole point of this
proposal.

So, that got merged recently.  And yeah, I think it will also likely be shipped
in Bitcoin Core 28.0.  So, if any other Bitcoin implementations are interested
in this behavior and want to request some of their transactions to be treated
that way, they should check out the BIP for the specifics.  Any comments,
questions on that one?

_BIPs #1556_

All right, moving on.  BIPs #1556 adds BIP337.  This BIP is about compressed
transactions, and this is really a new serialization format on how you can
express the entire Bitcoin transaction in the least amount of data.  This would,
for example, be useful in any sort of low-bandwidth transmission, such as
satellite transmission, HAM radio, or if you want to hide a transaction in an
image via steganography, or if you have a very big handwriting and want to send
it via pigeon carrier.  So, well, there's two new RPCs being proposed,
compressrawtransaction and decompressrawtransaction.  I think there was work on
a PR for Bitcoin Core at some point, but there's also, I think, a Rust
implementation now.  And there was a description of BIP337 in Newsletter #267,
if you want to read up more on it.

_BLIPs #32_

Finally, we're getting to yet another Matt Corallo project, and this is BLIPs
#32.  This is the sister BLIP to a BIP that I think also got merged recently, I
think; yeah, yesterday.  And this describes on how you can provide a payment
instruction in your DNS record.  So, how about you take it from here, Matt?
It's your baby.

**Matt Corallo**: Sure!  Yeah, so BIP353, I think it is now, was merged this
week or last week, or whatever, and describes a way to encode Bitcoin payment
instructions, specifically in the form of a BIP21 URI, because it's a great
general way to encode Bitcoin payment instructions with multiple options and
fallbacks and whatnot in DNS records, so in DNS text records, and then verify
them.  So, we've seen a strong product market fit for human-readable names in
the form of Lightning address.  People really love using them in general.  And
so, it seems like something that we should have kind of more broadly for
Bitcoin, but also something that we should have without the need to make these
http requests that reveal the sender's IP address to the recipient, and without
needing the whole complex machinery of http and certificate authorities and all
of this SSL nonsense.

DNS is a great way to do it.  It's a universal hierarchical namespace that also
has signatures.  So, with DNSSEC, you can statelessly validate a proof all the
way from the root keys all the way down to a domain, how you're trusting
obviously the DNS system, the root DNS key operators as well as whatever TLD
you're using.  But short of using Namecoin, or some other similar system, it's
kind of the best we could do.  So, anyway, so this BLIP that also got merged is
a way to query DNS text records and get these statelessly verifiable proofs from
Lightning nodes over Lightning Onion messages.

So, one of the goals with the human-readable names, like I mentioned, was to
avoid revealing the sender's IP address to the recipient, which is accomplished
by not using http.  But then also, you still need to somehow query this DNS
information.  And if you use your ISPs resolver, you're going to reveal which
ISP you use.  Many people use 8.8.8.8 or 1.1.1.1, or one of these other global
DNS proxies that you can use that are operated by various companies.  That's
also good, but then you're revealing who you're paying to Google or Cloudflare,
or what have you, which isn't great either.  So, onion messages for people who
are already running Lightning nodes are kind of great.  You can send a message
through the LN without revealing the sender.  So, the only thing that that
recipient learns is that someone is presumably trying to pay whoever it says in
the request, and then they respond back via onion messages and they don't know
who they sent the message to.

So, yeah, it just adds as the ability to query.  We're hoping to have an
implementation in LDK in not too long.  There's some changes that went into this
release that will make it more efficient.  So hopefully, we'll be able to merge
that upstream, and then people will be able to make these queries against LDK
nodes.  But also hopefully, other nodes do the same so that people can do
human-readable names with super-great privacy.

**Mark Erhardt**: Right.  So basically, the idea is that if you have any domain
or the operator of a domain provides the service, they can just add for even
multiple users a record in their DNS, and it will contain your payment
instructions.  The domain provider, or whatever your domain is resolved to,
provides the signature, so nobody along the way of this information being
relayed can fudge with it.  And then you get sort of a similar UX as the sender
that you could, for example, pay Matt at mattsdomain.com.  And when you pull
that up with your DNS resolver, it would result in BOLT12 invoice, or in a
silent payments address, or in a static, or, well hopefully, often-cycled legacy
address/ single-sig, whatever.

That sounds pretty cool.  And so, what do you see as the adoption path for this?
How difficult is this for people to use in the future?

**Matt Corallo**: So, because we really want people to not just blindly trust
their DNS resolver, we really want people to actually verify all the DNSSEC
signatures top to bottom, it does mean you need an RSA signature verifier and a
secp256r1 verifier, which most Bitcoin nodes do not have either of these, unless
they use OpenSSL or some other SSL library already.  So, I spent the time and
wrote kind an implementation that can verify these proofs, that can also build
these proofs, and in Rust, and got Poelstra to look at it, so hopefully it's not
completely broken.  And I'm working with a few wallets to get it integrated.
There's a few early adopter wallets that have already taken that Rust library
and integrated it, either in many cases through language bindings, it's got good
language binding support.  The UniFFI also supports building it for WASM and has
a JavaScript API.  So, we've got a few early adopter wallets starting to make
progress.  I'm hoping that as that starts to roll out, people will just see the
value here.

Again, because we saw such great product market fit with Lightning Address, I
anticipate that we'll see something similar here, as long as there's decent
wallet support for it.  Another really nice property is that hardware wallets
can verify these proofs.  So, a hardware wallet can actually display like, "Do
you want to send to matt@mattcorallo.com?" rather than needing to display this
arbitrary string of gobbledygook that no one can practically verify.  So, I'm
also working, or spoken to a number of hardware wallet vendors to get proof
verification incorporated in the hardware wallet.  Again, of course, you're
trusting the DNS system and both your TLD and the root name key operators for
that verification, but that also underpins the entire internet and every domain
out there.  So, hopefully it's not too crazy of a trust assumption, at least for
moderate value payments.

So, again, I think the UX wins here are really huge, and so I think the adoption
will come quick once we get a few early adopters out there and can kind of
demonstrate value.

**Mark Erhardt**: That sounds really amazing to me, being able to just pack it
on your domain information, and especially in the context of now both a standard
for Lightning and for onchain payments, where you can have a static address that
resolves to private payments every single time.  I think that the overall
privacy of where UX of Bitcoin is, is going to get a huge improvement this year
and next year.  So, thank you for working on this.

All right.  So, I think we've come to the end of our newsletter.  I don't see
any requests for questions or comments from the audience.  So, thank you very
much to our guests, Fabian Jahr, Matt Corallo and AJ Towns.  And of course, to
my co-host, Dave Harding, also for writing most of the newsletter again this
week.  Thank you for your time, dear listeners, and we'll hear you next week.

{% include references.md %}
