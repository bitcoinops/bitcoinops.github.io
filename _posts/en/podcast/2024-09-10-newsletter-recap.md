---
title: 'Bitcoin Optech Newsletter #319 Recap Podcast'
permalink: /en/podcast/2024/09/10/
reference: /en/newsletters/2024/09/06/
name: 2024-09-10-recap
slug: 2024-09-10-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Filippo Merli, Lorenzo
Bonazzi, Matt Corallo, Eric Voskuil, and rkrux to discuss [Newsletter #319]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-8-10/386126849-44100-2-e735f18b5a6f.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #319 Recap on
Twitter Spaces.  Today, we're going to talk about a Stratum v2 extension, we're
going to talk about the $1 million fund for OP_CAT research, a consensus
discussion around the consensus cleanup soft fork, we have rkrux here to discuss
Bitcoin Core 28.0 RC1 and the Testing Guide, and we have our regular segments on
notable code changes and releases.  I'm Mike Schmidt, I'm a contributor at
Optech and Executive Director at Brink, funding Bitcoin open-source developers.
Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin.

**Mike Schmidt**: Rkrux?

**Rkrux**: Hey, I have recently started contributing to Bitcoin Core.

**Mike Schmidt**: Filippo, you're on mute.

**Filippo Merli**: Okay, I'm Filippo Merli, I'm the CTO of DEMAND, and I
developed SRI, that is the Stratum reference implementation.

**Mike Schmidt**: Excellent, Lorenzo?

**Lorenzo Bonazzi**: I work for SRI with two grants, and now I'm going to work
for a month and really start with the paper we are talking about.

**Mike Schmidt**: Eric?

**Eric Voskuil**: Hi, Eric Voskuil, a long-time maintainer of Libbitcoin.

**Mike Schmidt**: And Matt?

**Matt Corallo**: Hey, I'm Matt, I work on LDK and I've worked on various
Bitcoin stuff for more than a decade.

**Mike Schmidt**: Well, thank you all for joining us.  For those listening
along, bring up Bitcoin Optech Newsletter #319.  We're going to try to go
through in sequential order here, starting with the News section.

_Stratum v2 extension for fee revenue sharing_

First News item, "Stratum v2 extension for fee revenue sharing".  Filippo, you
posted to Delving Bitcoin a post titled, "PPLNS with job declaration", and in
that post you outlined an extension to Stratum v2 that allows miners to verify
pool payouts when miners are the ones selecting transactions.  Can you maybe
help set the context here?  How are things today versus how could they be with
this extension?  And I know we have Lorenzo and BlueMatt that can opine as well,
but maybe Filippo, you can provide an overview for us to start?

**Filippo Merli**: Sure.  First thing, I want to say thank you to Lorenzo that
worked on this in August when everyone was on the beach, and I mean I wouldn't
have been able to deliver it without his help.  So, to go back on the argument,
the proposal is composed by three things.  One is this payment schema that is
based on PPLNS and taking into account also fees.  The other thing is the way
that miners can use to minimize trust in pool on regard of the payment.  And the
third thing is the Sv2 extension, the specification of the Sv2 extension, that
allows to implement these two things that I said now.

So right now, the miner cannot select the transactions, so all the miners in a
pool mine the same jobs, so it's okay how it works, in the sense that we look at
the hash power provided by the miner and based on that, we pay the miners.  With
Sv2, the miner can select the transaction and where is the main issue here?  The
main issue is that the pool wants to be agnostic on the transaction that the
miner selects.  So, if a miner wants to mine empty blocks, it can do it.  But it
also wants to be fair.  So, that means that if I'm mining the block that
maximizes the fee, I should be paid more than the miner that mines empty blocks.
And to do that, you have to take into account the job's fees that the miner is
mining.

The most simple thing is to just have something that proportionally pays the
minor based on their fee.  This has issues, in my opinion, because for example
fees between a block and another block, the maximum mempool acceptable fee, grow
monotonically.  So, it could be convenient for miners to join after pool
opening, so start mining, join the pool later on the mining round.  And this can
introduce a lot of things that are very hard to understand.  So, we decided to
go with another solution, and the solution is to create slices.  In a slice, you
can say that miners deduct maximum mempool acceptable fee.  It's the same for
everyone, so you do the proportional thing inside the slice.

I think that for the payment schema, that's all.  I don't know if you want to
know more about the other things.

**Mark Erhardt**: Could you explain the slice a little better?  So, the miner
would create its own template, and it would prove to the mining pool, in some
fashion, how much fees it would be collecting with its template.  And the payout
is proportional to the total block subsidy plus fees that it collects.  But how
does this slice come in play here?

**Filippo Merli**: So, the miner doesn't need to prove anything because you have
to declare the job to the pool.  So, in the job, there are the transactions that
the miner is mining, so the pool already knows how many fees a job has.  And so,
which was the question?  Sorry, I forgot!

**Mark Erhardt**: So, a share is when a miner succeeds at mining a block at a
much easier difficulty, right?

**Filippo Merli**: Exactly, that's a shared pool.

**Mark Erhardt**: And when a miner starts, they tell the pool, "Okay, I'm mining
with this set of transactions.  This is sort of my prototype for the block
template that I'm mining with".  And that way, they communicate the fees.  So,
what's a slice?  Is it all the work on that one block template or…?

**Filippo Merli**: Okay, what is a slice?  So, a slice is defined by the pool.
And to make it simple, it's something like that.  The pool receives the job
declared by all the miners.  And let's say that the job declared for that slice
has a fee that pays 10.  As soon a miner declares a job with 10+δ, that can be 1
for example, as soon as it's 11, the fee of the declared job, the pool creates
another slice.  And every share that is received between the slice that I create
now and the next slice will go in the slice that I just create.  So, it's a
group of shares, the slice.

**Mark Erhardt**: Right, a group of shares based on the total revenue that the
mining pool would expect from collecting from a certain template.

**Filippo Merli**: Yes, and this total revenue is calculated based on the
declared job.

**Mike Schmidt**: Okay, Murch, I saw a thumbs down, but now thumbs up.  Okay.
Filippo, anything else that you'd expand on?  We can move to Lorenzo, or maybe
Matt has some commentary as well.

**Filippo Merli**: Yeah, there is also another thing in this proposal, and it's
the transparency thing.  So, there is a way for the miner to verify that the
pool is not inflating the total hashrate of the pool.  This is very useful
because that means that the pool cannot cheat.  And if you want to know
something more, I don't know if we can go with Lorenz or Matt.

**Mike Schmidt**: Matt, have you been following this extension discussion?

**Matt Corallo**: I haven't substantially.  I did have a question.  How flexible
is the extension?  Because various pools are going to have various ways that
they calculate fees, ways that they verify shares; are they verifying all the
shares; are they capping payouts to some median?  How much flexibility does the
pool have in terms of how it does payouts in this scheme or in this extension,
or is it super-fixed and they have to do exactly the payouts that the extension
defines and that DEMAND does?

**Filippo Merli**: So, how to do the payouts is defined in the extension.  There
are certain things that can be changed, for example how big you want to do the
slices, or I don't remember the other thing, but this is a big thing that you
can change.  And, yes, I mean you can change the window dimension, how big is
the N in PPLNS, and the other things are fixed because it's how PPLNS is
defined.  I don't know if this answered your question.

**Matt Corallo**: I think it did, but I am curious if you imagine pools doing
various, slightly different schemes on how they calculate payouts.  So,
certainly this is one scheme, but there are other ways people might do it.  Are
you imagining this extension is kind of a proprietary extension for DEMAND users
where DEMAND users can use this to verify their payouts, or are you imagining
this extension applies to other pools and then other pools will necessarily then
copy DEMAND's payout structure?

**Filippo Merli**: So, it's not proprietary, it's open source and the very young
implementation that I did is open source, so everyone can use it.  And you can
for sure adapt it.  You have to do PPLNS and you have to calculate fees, how
it's defined in the extension in a certain way; you can change the open-source
implementation, to calculate things in another way; you have a set of messages
that you have to reuse.  So, I mean, you have some liberty in what you can
change.  But I would say that for sure, you have to do PPLNS.

**Mike Schmidt**: Matt, maybe a question for you.  Are extensions in Stratum v2
some formal mechanism that there's extension points, or is this something like a
modified Stratum v2 code?

**Matt Corallo**: No, there are extension points, and Stratum v2 contemplated a
number of reasons why people might want extensions ranging from open source to
proprietary, for example monitoring the device, like device-level monitoring,
that might be specific to the firmware or manufacturer that the device software
is running, stuff like that.  So, there's formal hooks for extensions.  I don't
know exactly how this one's implemented, but it's definitely a protocol that
imagines people using various extensions for various reasons, and there's
already been other ones proposed.  This is talking about a payout monitoring,
there's also just auditing, so has an extension to do more, enable miners to
have an auditing role so they might actually be their auditor, like a public
company auditor.  Or, it might be just some role within the company where they
can't control anything about the miner, but they see all the shares and they can
do their own verification, kind of out-of-band, beside the miner.

So, there's various reasons why people might want extensions.  There's various
extensions that have already been proposed and probably there will be more.

**Mike Schmidt**: Filippo, what's feedback been so far, both maybe on Delving,
but if you've gotten feedback elsewhere?

**Filippo Merli**: Yeah, I'm pretty happy with the feedback so far, because we
had a lot of answers on the Delving thread.  Of course, this is a proposal so
there will be things to change, to modify.  We will have a call to review the
proposal in two days, I think.  By the way, if you go on the SRI Discord, it's
there, the information for that call.  And maybe I will add it also to the
Delving Bitcoin thread so everyone can see it.  By the way, I'm pretty happy
right now with the feedback and everything.

**Mike Schmidt**: Great, anything else you'd give for the audience as a call to
action as we wrap up this news item?

**Filippo Merli**: Any review would be fantastic.  So, that's it.

**Mike Schmidt**: Great.  Thanks for joining us, Filippo and Lorenzo.

**Filippo Merli**: Thank you very much.

**Mike Schmidt**: You guys are welcome to stay on as we go through the rest of
the newsletter, but if you have other things to do, we understand.

**Lorenzo Bonazzi**: Perhaps one thing --

**Mike Schmidt**: Sure.

**Lorenzo Bonazzi**: -- that's worth remarking, is the ground idea behind this
is that you divide the window of the shares in some slices and reserve to that
slice a part of the block subsidies, so the call base output plus the fees.  So,
once you do that, it's easy to score the shares in a slice in a way that is
already done for the difficulty without job declaration.  And this is known, for
example, in a Rosenfeld article about a pool payouts mechanism.  And so, you
score based on the actual contribution that you do with your share, and within a
single slice for the fees, and this, you do that on top of the usual scoring for
the coinbase output.  Because if you have to redistribute the coinbase output,
you don't have to take into consideration about fees.  So, it's the normal
scoring that we already use for PPLNS and I think also uses for TIDES.  You take
in consideration only difficulty.  But within slice for that scoring, you apply
a second layer of scoring that is based on the fees.  And you use that scoring
for dividing, therefore for distributing the fees collected in the block, the
part of the fees collected in the block reserved for the slice.  This is kind of
the ground idea.

**Mike Schmidt**: Murch, any follow up or questions?  All right, Murch is good.
Thanks again, Filippo and Lorenzo.

**Filippo Merli**: Thank you.

_OP_CAT research fund_

**Mike Schmidt**: We're going to move on with the newsletter.  The second News
item this week is titled, "OP_CAT research fund".  Victor Kolobov posted to the
Bitcoin-Dev mailing list an email titled, "OP_CAT Research Fund, sponsored by
StarkWare".  And Victor works at StarkWare, and they've created a pool of funds,
$1 million, that folks can apply to receive a portion of if their submission is
approved by the OP_CAT Research Fund Committee, which includes a bunch of
different Bitcoin and Lightning and other ecosystem participants.  Victor noted
that they're looking for, "Compelling arguments either in favor of or against
the activation of OP_CAT".  If you look at their application page, some topics
that the initiative is interested in include the security implications of OP_CAT
in Bitcoin, economic implications of OP_CAT in Bitcoin, OP_CAT-based script
logic, applications and protocol using OP_CAT in Bitcoin, and then there's this
general comment of general research related to OP_CAT.  The submission deadline
for proposals is January 1, 2025.  And BlueMatt, I was going to quote you here,
but you're here, so you can maybe provide your thoughts on such efforts
historically.

**Matt Corallo**: Yeah, I think I posed a response there, but basically just
bounties have a mixed success rate generally.  The thing you need to do is
motivate people who are busy and are busy with lots of projects that they have,
that they want to focus on, to contribute to your thing and think hard about
your thing and spend a lot of time thinking about your thing.  And bounties
don't generally accomplish that.  There are some people certainly who are very
mercenary and respond to a little bit more cash, but most people who are busy
and smart and have jobs do not.

That said, I'm of course happy they're doing this, it's better than nothing.
Maybe it will generate some good feedback and some good research, but I'm just
not holding my breath.

**Mike Schmidt**: I think CTV had sort of a bug bounty for CTV at the time,
which I guess would fall under one of these interested initiatives, which is the
security implications.  I guess that would be trying to find a bug, but they
also have applications and economic implication analysis as well.  So, curious
to see how these applications get divided up between these different types of
buckets, security versus economic versus new protocols, etc.  Murch, I see Bob's
joined us.  Bob, do you have a comment on OP_CAT Research Fund and/or some of
the Stratum v2 discussion?

**Mark Erhardt**: You're unmuted, but I can't hear you.

**Mike Schmidt**: Same.  Bob, do you want to try to rejoin and see if your audio
works then?

**Mark Erhardt**: Let me chime in on the OP_CAT research fund briefly.  So, I
think the questions being asked are good, and I think we need some more input on
those questions.  Yeah, I would hope also that just generally, I've said this a
couple times already, but there is a lot of discussion ongoing, or some at least
that I know of, more of that should be surfaced in areas where they can easily
be re-read or responded to by broader audiences, such as the mailing list and
forums.  So far, I feel like OP_CAT could definitely do better on the
motivation.  I mean, the code change itself is pretty small and easy to review,
but the biggest open questions are, how much does it really get us if we just
get OP_CAT, and what about the MEV concerns?

**Mike Schmidt**: Eric, do you have thoughts on this OP_CAT Research Fund, or
OP_CAT more generally, that you'd like to share?

**Eric Voskuil**: No, I don't really follow it.

**Mike Schmidt**: Okay.  Well, if we get Bob back in here, we can get his
thoughts on either Stratum v2 or the Research Fund.  Anything, Murch, that you'd
add on the Research Fund before we move along?  All right.

_Mitigating merkle tree vulnerabilities_

Our third and final News item this week titled, Mitigating merkle tree
vulnerabilities".  Eric, you posted to Delving Bitcoin a response to a forum
discussion on the great consensus cleanup revival.  We had Antoine Poinsot on in
Podcast #296 to talk about his work in reviving that old proposal.  So, for
higher-level context listeners should check out that #296 discussion.  Eric,
your Delving response referenced a Bitcoin mailing list thread on the topic that
didn't seem to have any activity since mid-July.  You were sort of following up
on Delving here.  Maybe you can get listeners up to speed with some context on
which part of the consensus cleanup discussion you had feedback on, and then we
can kind of go from there?

**Eric Voskuil**: Sure.  Antoine posted a note to the Bitcoin dev mailing list.
I wasn't using Delving at the time, I don't think, and just for a little
background, I work on Libbitcoin, which is a full node implementation, and I was
mostly curious with his comments regarding maximum validation time transactions,
which the specifics on that were withheld for good reason, and so I contacted
him and he put me on the private list and I looked over that stuff.  But while I
was doing it, I noticed that one of the issues that seemed to have general
agreement was invalidation of 64-byte transactions in order to resolve a merkle
tree Bitcoin implementation issue.  And I had recently, coincidentally, been
working in Libbitcoin in that specific area, so I took an interest in it.  And
so, I posted a question actually I think to the mailing list, and then that
discussion I think came to a conclusion.  There were no more responses, but it
wasn't followed up on Delving, which is kind of where the main thread was.  So,
I pointed out that this discussion had occurred and appeared to have resolved
some questions.  I pointed that out on Delving and the discussion got started
again there.

So, in terms of the specifics, there were a number of reasons given for this
desire to invalidate all Bitcoin 64-byte transactions.  That's 64-byte, what
they call stripped size, which is the byte size absent witness, or before segwit
serialization.  And in the Bitcoin-Dev discussion, I think all of the issues
that were raised in favor of that invalidation were discussed, except for the
specific issue of an SPV wallet or client weakness, or I don't know what you
call it.  You can't really call it a vulnerability.  It's more trying to maybe
simplify or optimize an implementation.  So, setting that aside, what I thought
was most interesting about it was that there was a pretty good list of reasons
given that seemed to have fairly broad agreement.  Setting aside the SPV issue,
and from my perspective, none of them were valid.

This sometimes happens, I mean not commonly, but sometimes happens because
Libbitcoin is a very different implementation than Bitcoin Core.  Most other
implementations are either language ports, which follow the same architecture as
Bitcoin Core -- well, I can say that's mostly what they are.  In general,
Libbitcoin has never been a fork of Bitcoin Core, it doesn't follow the same
architecture.  So, we tend to see things differently, which is I think one of
the reasons why Antoine brought me in on the conversation.  So, I don't know if
you have any questions about that, or you want to go into the specifics.  The
SPV discussion, I would call that still an open discussion.  I believe all of
the other points are closed and no longer support the argument for invalidating
64-byte transactions.  The SPV discussion, it's a trade-off, but it's not as
clear a trade-off as people might have believed.

**Mark Erhardt**: Maybe I missed it, but could you repeat what you see as the
problem with the 64-byte invalidation?

**Eric Voskuil**: Well, it's a consensus change.  That's inherently a problem,
right?  You don't do it unless it's necessary.  So, I don't have to list the
reasons why it shouldn't be done; somebody has to come up with the reasons why
it should be done.  I can point out there have been unintended consequences from
seemingly very simple consensus changes in the past.  Making a change is not,
even if it's -- what seems to be happening here is that because this is
described as a roll-up of consensus changes, the fact that it's a consensus
change is kind of presented sometimes as not significant, right, because getting
it activated is one of the big hurdles in any soft fork, for example.  And this
is proposed as a soft fork, just rejecting 64-byte transactions.

So, I think that that really shouldn't be a consideration.  If we're talking
about a consensus change, we're talking about a consensus change.  Essentially,
you're adding a new rule to Bitcoin.  Everything that validates has to validate
the rule, and the rule could potentially have side effects that people -- I
mean, this is pretty simple, right, the idea of if it's 64 bytes, it's not
valid.  Simple to implement but again, it has to be that any soft fork, any
fork, any additional rule in Bitcoin has to achieve a pretty high bar in order
to be justified.  I've seen in Bitcoin consensus new consensus rules, what
people call changes and everything, but every so-called change is actually just
a new rule.  I've seen these rules added just to make implementation easier in
Bitcoin Core, where they actually made implementation harder in other
implementations, right?

So, I tend to be skeptical of certain arguments that revolve around
implementation.  And some of the arguments that were being made on 64-byte
transaction validation, not including the SPV issue, but the others had to do
specifically with Bitcoin Core implementation details, which after a fairly
lengthy discussion on Bitcoin-Dev, I believe it was accepted.  At least one of
the issues was accepted explicitly, but I believe the other issues were accepted
as correct, the issues that I was raising, that these were not only not
consensus-related, they were implementation-related, but they were actually not
more optimal as implemented in Bitcoin Core, they were actually suboptimal, for
example the practice of caching block hashes for blocks that are invalid but
still hashable.  It's certainly possible you could have a block message, you
can't obtain a block hash from it, but there's this kind of slice of block
that's come in as invalid, and they obtain a hash and store the hash so they
don't have to do the invalidation again.  I pointed out that that's not a
rational implementation, which is a fairly central aspect of Bitcoin Core, but
it doesn't mean it makes sense, and we had a lengthy discussion on why it just
doesn't make sense.

So anyway, to me, the SPV issue is a legitimate consideration.  It's not a
security issue, there's no security flaw in SPV implementations implemented
properly today.  It's not a security issue in Bitcoin.  There's no Bitcoin
vulnerabilities today as implemented.  So, these are about performance
optimizations.  And when you make choices about consensus changes to optimize
performance, you have to actually analyze what are the trade-offs, and that's
basically what we've been doing.  And it's come down to a very narrow slice of
legitimate consideration.  And there's been some numbers posted to Delving on
what we're talking about in terms of the actual trade-off for SPV, but it's
pretty small, right, an average download size of 500 bytes, on the order of 500
bytes per block to anchor any transaction in the block to the block's merkle
root.  So, 500 bytes amortized over all of the potentially thousands of
transactions in a block is really inconsequential in my opinion and not worth a
consensus change.  But that's where the discussion currently rests.  I don't
think there's any other open issues.

**Mike Schmidt**: You mentioned, and I'll quote from the discussion thread, "The
proposed invalidation of 64-byte transactions does not in any way represent a
fix to a vulnerability".  Would you say that discussion participants agree with
that at this point, or does the fact that there's this additional SPV bandwidth
consideration still have people arguing that there is a vulnerability?  I'm
trying to wrap my head around that.

**Eric Voskuil**: Yeah, so if current implementations are not properly
implemented, there will be vulnerabilities, as will always be the case, okay?
So, some of the comments in this area around vulnerability have been based on
some pretty heavy assumptions.  In other words, the term I think was used was a
footgun, right?  Like, it's not intuitive that somebody would have to check the
merkle tree depth before using a merkle tree validation.  Well, there's an awful
lot in Bitcoin that's not intuitive, but I don't think you could argue that it's
intuitive that 64-byte transactions and not below or above would be invalid
either, right, but you still have to check it if this becomes a consensus rule.

So, those are the types of arguments that have implied it's a security
vulnerability.  In other words, it would be a vulnerability if people didn't
implement properly.  And in the fairly lengthy discussion on Bitcoin-Dev, I
pointed out that the proposed implementation is actually more complex and more
performance-costly than what is doable without the consensus change.  So, that
led us back to the SPV wallet issue, where basically I can describe it in kind
of high-level technical terms.  When an SPV wallet or client, which has
presumably downloaded the strongest header chain that it can find, when it wants
to prove that a transaction is confirmed in one of those blocks and against one
of those headers, it does that by obtaining a merkle path from, let's say, a
full node.  And it uses this merkle path to, it's basically a linear path
through the merkle tree, kind of a consolidated path through the merkle tree to
the merkle root, which is in the block header.  So, using this transaction, you
hash, hash, hash your way to the top of the merkle path and you obtain the
merkle root, and therefore the transaction is provably in the block.

The problem comes where there's an ambiguity in the way Bitcoin processes merkle
trees, in that a 64-byte transaction can be made with some fairly modest
computational power, like hashing, right?  It can be made to match a pattern of
two 32-byte hashes, which are leaves in the tree.  And Sergio Lerner wrote a
fairly good paper on this a while back and proposed various solutions to this.
and so it's been known for a very long time.  And anybody that's implemented an
SPV wallet client has an insecure implementation if they haven't validated the
depth of the merkle tree.  So, the way presently an SPV wallet would be secure,
to the extent that SPV is secure, is that it needs to know provably the depth of
the merkle tree.  All transactions in a merkle tree are leaf nodes at the same
depth, including the coinbase or any transaction you want to validate.  So, if
you know the depth, you can preclude the possibility of this ambiguity causing a
problem.  In other words, knowing the depth, if you retreat, if you obtain a
merkle path from an untrusted server, and it's not at that depth, you know that
it's not valid.  But the trick is just knowing the merkle tree depth.

One of the things that was proposed in that original paper was to just provide
the merkle depth, essentially have the block header commit to the merkle depth,
which people then validate.  There were different ways proposed that it could be
stored, but that's not the important issue.  But the merkle tree depth can be
provably obtained by simply requesting from the same, say, untrusted server the
merkle proof for the coinbase transaction.  So, obtain the coinbase and the
path.  And by hashing that up to the merkle root, you know the depth.  Now, it's
a possibility that the coinbase could be one of these ambiguous transactions as
well.  However, a coinbase necessarily contains a 32-byte, call it a point hash,
it's a null point, right, where it's 32 bytes of 0s and 4 bytes of 1s.  And if
it doesn't contain that, it's not a valid coinbase.  If it does contain that,
it's computationally infeasible to manufacture one of these ambiguous
transactions.

So, that's the solution that servers can use to not need any change to
consensus.  They already have to validate that the coinbase has a null point.
And that's actually, when you actually look at it, it is the very first thing
after validating the header that a node can do, because there's like 4 bytes and
then you're right there at the point.  So, it's actually the earliest thing you
can validate after the header in a block.  So, it's very convenient if you're
trying to discard invalid blocks for this reason.  But on the SPV side, it makes
it trivial basically to verify the depth of the merkle tree.  And once you have
that depth as an SPV wallet, you can just store it, it's 4 bytes.  You store it
somewhere and you use it every time you validate a path in that block.  The
biggest depth that could feasibly be stored, that a transaction could be stored
at in a Bitcoin block is something like 16; it's beyond reasonable.  So, that's
just the logarithm of the maximum number of transactions in the block, right?
Log base 2.

So, that's it, right?  And so, validating the depth of a coinbase transaction is
the same code as validating the merkle tree connection to any other transaction.
It's not additional code, it's just an additional condition; get the merkle tree
depth for the coinbase transaction.  And once you have that depth, all you have
to do is check the depth against any other path.  And that is basically being
weighed against checking that the size of any transaction is not 64 bytes.  So,
there's a check that has to be done either way, and neither check is intuitive.
So, the discussion has come down to the complexity of those checks.  I think it
was agreed, at least I think AJ Towns said in the Delving discussion, that the
complexity was more significant than the size.  The size is really pretty
trivial, right, the amount of data.

So, I did a scan of the entire chain and it's written up on Delving, correct me
if I get my own numbers wrong, but it was something like, in the post-segwit
era, the average coinbase size is 260 bytes, right?  So, if you add up the
merkle path to validate the coinbase, you're looking at 500-something bytes
average for the entire post-segwit period.  I also looked up at worst case, the
largest coinbase that's ever been seen is about 30,000 bytes.  Now
theoretically, the largest is 1 MB.  So, there's been discussion on, does the
theoretically largest matter?  It never happened, right, the average is actually
just 260 bytes.  And the average is what matters when it comes to performance
over the network, which I think has been accepted.  And worst case, absolute
worst case, somebody makes a 1 MB coinbase, it's really not going to shut down
any SPV nodes, right?  So, it's amortized over the entire chain and you're
looking at basically a nanosecond of download time.  It's almost nothing, right?

**Mark Erhardt**: An important point here would be if they make a coinbase
that's 1 MB, they'll also have very few transactions that people want to
validate.

**Eric Voskuil**: That's why it's never happened, I would presume, right?  And
it's also why, in the pre-segwit era, there were larger coinbases than in the
post-segwit era.  It's an arbitrary line, it's not about segwit, it's about kind
of fuller blocks, right?  So, pre-segwit, when you go down to like block 1, you
get a lot of empty blocks.  And full blocks are three orders of magnitude larger
than empty blocks.  So, if you've got nothing but empty blocks being pumped,
somebody can make a large coinbase for nothing.  And the largest ever made, well
I think it's in the post, but it's somewhere around 30,000 bytes.  The largest
in the post-segwit era I think is around 6,000 bytes.  So, that shows you that
over time, what has happened is just what you're saying, as the space becomes
more valuable, there's much less incentive to waste it.  But it is possible, and
the point is that it's capped at 1MB, it can't get bigger than that.  The
average is 260 bytes, and that's what you're going to see over time, which if
you think about every time you text a photo, that's a megabyte, right?  We're
talking about to validate any transaction in a block, you're talking about
500-ish bytes to be able to do that, which is really trivial.

So, it's not about security, it's about, it's been reduced to this one narrow
slice.  Now there's a way, sorry, if I'm talking too much and anybody wants to
jump in…

**Mark Erhardt**: Yeah, actually, let me try to -- I think we got a little bit
into all the details.  So, let me try to sum up what I understood so far.  So,
from what I understand, the question is about whether it makes sense to forbid
64-byte transactions on the network.  The argument was that it would make it
simpler to protect against these merkle tree weaknesses.  And you observed that
this is a soft fork, and a soft fork should have a proper motivation, and you
poked some holes into the motivation as stated.  And your argument is, so if we
just outright forbid 64-byte transactions, everybody would just have to look at
the transaction and check that it's not 64 bytes in this part where they want to
protect against this vulnerability.  But you said we already have all the things
that we need in order to protect against these weaknesses by checking the depth
of the current base transaction, since every single transaction in the block
will have the same depth in the merkle tree.  We can just do that once per
block, store in our data structure what the depth for each block was when we
have validated it ourselves, and then whenever we want to verify any other
merkle proofs for any transaction in that block, we just pull up that number and
check that the merkle proof has that number of hashing partners.  So, you think
that we can adequately protect against these weaknesses without a consensus
change and therefore argue against the consensus change.

One question that maybe was a little short so far and that kept popping up for
me was, just getting the transaction itself and checking whether the stripped
size is 64 bytes or not seems to be something that is inherently trivial to do
before you even get into block validation and coinbases, and so forth.  So,
there would be maybe some bandwidth savings there, which we've talked about
already.  But also, to me it seems like a simpler check.  I also just checked,
there seemed to have been only five transactions ever, that all five have an
OP_RETURN output that were 64 bytes.  So, to me this rule seemed reasonable, but
do you want to respond to this again?

**Eric Voskuil**: Yeah, absolutely.  We were focusing on the SPV issue, but I
believe that the reason people saw this as a straightforward consensus change is
that there was a fairly long list of issues that this was supposedly going to
resolve and make better.  I find it a little hard to believe that this would be
raised as a consensus rule if it had been understood that those were not issues
from the beginning.  So to me, that speaks in part to the motivation.  Like,
there were legitimate concerns that people had.  I just don't think they fully
understood.  And it's not that the alternative approach in these cases is more
complex or more difficult or more performance costly, it's just the opposite.
It's actually easier, it's simpler, and it's more efficient.  So, those issues
have all gone away and we're left with the SPV wallet issue, which is not an
issue that pertains to a node and it's not an issue that pertains to consensus
and it's not an issue of security, of course an implementation has to be
implemented properly.  I think you accurately described the kind of high level
what has to be done, right?

People who don't implement these things don't really know, but checking the size
of a transaction in a block requires you to parse the entire transaction.
Transactions don't show up with a number that says what size they are, and even
if they did, you couldn't trust it, right?  So, you have to parse the entire
block to know the sizes of all the transactions, right?  The alternative
approach --

**Mark Erhardt**: Sorry, let me jump in here quickly.  If you're only interested
in a single transaction, you do not have to check every single transaction in
the entire block, you have to just check that one transaction.  So, I'm not
quite sure how you got from that one transaction to the whole block.  Could you
elaborate?

**Eric Voskuil**: I'm talking about node implementation, which is what this
affects, right?  We're talking about consensus change.  So, the node
implementation --

**Mark Erhardt**: Yeah, sure, but if you're validating whether a block is valid,
then you have to look at every transaction anyway, so you will parse every
transaction and you will check whether they're 64-bytes long just by looking at
all of their bytes.  So, I'm not sure, is that the argument you're making?

**Eric Voskuil**: Okay, that's just not the case, right?  The way nodes are
protected against this issue now is by simply validating the coinbase.  That's
all you need to do.  You don't need to check the sizes of all the transactions.
The sizes of transactions in a block are accumulated to obtain the block size
and enforce the block size limit, so it is done.  But in order to do it, you
have to parse every single transaction.  Again, this is node processing.  If you
want to be safe against this issue, that's what you have to do.  That is a much,
much later stage part of validating a block than validating the immediate bytes
right after the header, which are the first coin, the coin base, right?  If that
is not a coinbase pattern, which it must be, then the block is invalid.  If it
is a coinbase pattern, the block cannot have a malleated merkle tree, and that's
explained in Sergio's paper.

So, my point was that solving this issue on the server side appeared to be
simpler and easier, but it's actually adding a consensus check that if you were
to do it for this reason, requires you to parse the entire block, right?

**Mark Erhardt**: I don't follow this argument at all.  In order to validate a
block, clearly you have to look at every transaction.  So, it makes no
difference whether you can check the coinbase to rule out a malleated block or
whether you have to -- you could still have a non-malleated block that is
invalid.

**Eric Voskuil**: You've got to listen to what I actually said, okay?  I'm not
talking about if you are intending to validate an entire block.  I'm saying if
you set aside this issue and you say, "I want to know if this block has a
malleated hash, or I want to prove that it doesn't", that's all you're doing.
You have to parse the entire block, get the sizes of every transaction to know
that, in the one case.  In the other case, you have to skip the header, which is
a fixed 80 bytes, skip 4 more bytes, and validate that 36 bytes match a fixed
pattern.  That's it, okay.  So, if you're trying to throw out blocks early
because they're malleated, it's much faster and much simpler to do it the way it
can already be done.

So, the argument that this would make block invalidation, faster, easier, and
earlier were all incorrect, okay?  If you're validating...

**Mark Erhardt**: Sorry, may I have a follow-up question here?  Are you arguing
that if I'm checking that the one transaction I'm interested in plus the
coinbase transaction are not malleated against each other, then I would agree
you only have to check back into the coinbase.  But if you're ruling out whether
the block is malleated at all, you would have to look at all other transactions
as well, in order to check that their height isn't different from the coinbase.
So, I do not follow your logic here.  And I think BlueMatt wanted to say
something.  Matt?

**Matt Corallo**: I was just going to say that we're getting into the weeds here
quite a bit and probably can move on.  But I think both sides are interesting.
I think the suggestion that -- I think I might have been an early proponent of
this change, so I certainly don't, yeah.  But it is the case that invalidating
64-byte transactions might cause some issues for some people.  We'll get into
why in a minute, in fact.  But at the same time, I think there is a lot of
deployed SPV software out there, a lot, a lot, a lot of different protocols, a
lot of different software.  And today, much of it is broken.  And doing a
consensus change, if we believe that it has limited impact on anyone, or very
minimal impact on anyone in order to fix a lot of deployed software, seems worth
it to me.  But it's very much a value judgment, and I don't think we're going to
solve that value judgment on this basis.

**Mike Schmidt**: Bob, you've been incredibly patient!  Do you have a comment?

**Bob McElrath**: I have one very, very minor comment.  Eric mentioned that the
coinbase sizes are quite small now.  The historical reason why coinbases were
larger was because the existence of P2Pool and Elegius Pool, which paid miners
directly in the coinbase, and both of those died in the 2017 timeframe.  Ocean
is a reboot of the Elegius Pool and does pay miners in the coinbase.  We are
working on Braidpool.  We are still considering whether we're going to pay
miners in the coinbase; we may.  The point is that I think in the future, to the
extent we are successful in creating centralized mining pools, we will have
larger coinbases in the future, to the extent that that matters for that
conversation.

**Mark Erhardt**: Eric did you have something else to add?

**Eric Voskuil**: Well, I mean it sounds like you want to move on, so I'll just
point out that in the immediately preceding discussion, I was talking about
validating blocks, not SPV.  And so, that appears to be why you kept disagreeing
with what I was saying because you were talking about SPV.

**Mark Erhardt**: I see, that would explain it.  Well, I guess we'll follow the
Delving conversations since it was still ongoing, and there seems to be loads to
talk about still.  Thank you for taking your time to explain this to us.

**Eric Voskuil**: Sure.

**Mike Schmidt**: Thanks, Eric.  You're welcome to stay on or if you have other
things to do, we understand.

**Eric Voskuil**: Sure.

_Core Lightning 24.08_

**Mike Schmidt**: Moving to the Releases and release candidates section of the
newsletter this week.  First one, Core Lightning 24.08 is the latest major
release of Core Lightning (CLN).  There is a blogpost on the Blockstream blog
with the title, "Core Lightning v24.08 Steel Backed-Up Channels, and that
provides sort of a high-level overview of the release.  That blogpost was
authored by Shahana from the CLN team, who unfortunately was unable to make it
today, but summarized the release in a note to me via email, which I'll provide
here for the audience, "The primary focus of this release was improving payment
success rates.  We have upgraded BOLT12 offers to be compatible with the current
specification and to support blinded paths.  The pay plugin now includes
pre-flight checks, which will eventually be saved for future payments.
Additionally, the renepay plugin's probability cost function has been redefined
to disable channels with a higher likelihood of payment failures.  We have also
introduced a new plugin, named askrene, which splits payments into two parts,
querying routing solutions and executing payments.  The plugin also utilizes
renepay's minimum cost flow computation to generate optimal payment routes, by
balancing success probability and fees".

So, I think that she provided a good high-level overview there.  I had a couple
of additional notes here.  There's a few things around offers that were
referenced; can now pay BOLT12 invoices; if entry to blinded hop is specified as
a short channel ID, offers can now self-fetch and self-pay BOLT12 offers and
invoices; offers automatically add blinded paths from a peer, if there's no
public channels with that CLN node; supports setting a blinded path for invoice
requests, if this CLN node is an unannounced node.  Then there's also a note
here that recurring offers had incompatible changes.  So, recurring offers will
not work against older versions, so note if you're using that feature.

Then we talked about the askrene and renepay plugin updates; onion messages are
now supported by default; the reckless plugin manager now supports installing
Rust plugins; and you can now also issue commands to the reckless plugin manager
via RPC.  And there's a bunch more if you're running CLN.  Check out the release
notes.  Anything to add, Murch?

_LDK 0.0.124_

Next release, LDBK 0.0.124.  And we have Matt here, who can talk us through this
release.  What's new, Matt?

**Matt Corallo**: Yeah, a bunch of medium-sized stuff.  Kind of all of our big
projects that we have going, splicing, dual funding, async payments, all kinds
of stuff, are making good progress but weren't in this release.  But we did have
a bunch of stuff.  We had a bunch of users contributing, downstream developers
who use LDK contributing small features to medium-sized features that they
wanted, which we love to see and which we tend to try to merge pretty quick.  We
also improved the ability of downstream nodes to be robust against feerate
disagreements.  Obviously, Lightning's security model means that if you disagree
on your feerate with your peer, you have to foreclose or you have to trust your
peer blindly, which is what some other implementations do.  We certainly don't
take a stance on whether you should trust your peer, but we have improved the
ability to use different feerate estimates from your feerate estimator to
decrease the chance that we've entered a disagreement state.  So, you can look
at one estimator when seeing whether you think your peer is too high, and you
can look at a different estimator when you're trying to decide what theory you
want to use.  We already have, I think, seven or eight different categories of
feerates.  We added one more, but this should reduce the chance of foreclosures.
So, people are going to be happy about that.

We also have a pile of performance improvements, including a 20% to 30% faster
route finding, which is exciting, without any changes in the actual algorithm,
just faster code; and we have a handful of BOLT12 improvements, so good to hear
that CLN is compatible now with the latest spec, which brings it up to LDK and
CLN and Phoenix are all getting fairly robust and compatible with each other all
at the same time.  We added a handful of privacy fixes in this release, as well
as some changes to make it so that BOLT12 actually works when you're building
private test networks.  We had some decision logic that didn't make sense for
small test networks that made things hard to test.  But other than that, yeah,
it was a fairly long release with a ton of fixes, but no huge top-line features
that people are super-excited about.

The one other thing that was actually relevant to the previous discussion,
that's worth getting into here, is we had this bug which wasn't super-important
in the context of LDK, but it's interesting, where we actually were generating
transactions that were 63 bytes and were non-standard.  So, Bitcoin Core, when
there was initial discussion to ban 64 bytes in the original great consensus
cleanup, Bitcoin Core added a policy rule to ban all transactions smaller than
65 bytes, so that's 64 bytes, as well as 63 and 62; I think the smallest
transaction you can possibly build that is consensus -valid is 62 bytes, but
don't quote me on that, it's 61 or 63, I don't know.  Anyway, we were generating
transactions that were actually non-standard because they were smaller than 64
bytes.  And yeah, I mean I think that's interesting.  We were trying to spend
anchor outputs, so we had this output on a transaction we needed to do a CPFP
fee bump, and we didn't have a change output.  So, we just wanted to burn all of
the money that we brought in to fees.  And this caused us to add an OP_RETURN, a
small dummy OP_RETURN output just to burn everything else to fees.  And this
transaction was too small and it was non-standard and wouldn't relay.

So this was, again, not super-critical for us.  We just will keep trying to bump
the feerate of these transactions via RBF and do another round of coin
selection, and we would eventually find a coin selection that does have a change
output.  So, it wouldn't have caused too many issues, but it did delay
commitment transaction confirmation for a block or two, which is problematic.
And you could imagine people building similar schemes that don't do aggressive
fee bumping every block that would have actually had a pretty severe bug here.
So, it is just interesting to note that it is in fact totally possible that a
ban of 64-byte transactions is an interesting corner case that people might not
consider and might in fact break some things.

**Mike Schmidt**: Matt, you may have mentioned it and I missed it, but I think I
saw that there was a new format for Rapid Gossip Sync Data.  Is that interesting
or just sort of under-the-hood stuff?

**Matt Corallo**: Yeah, relevant for some users.  Yeah, I mean we have all kinds
of features and changes that are relevant for a subset of our users, but not
super-broad.  That is a feature.  We added a number of additional fields in RGS
data so that RGS clients can see the addresses, the IP addresses of nodes in the
graph, as well as we added some other fields, I don't remember which ones now,
but we need the IP addresses for BOLT12s fallback.  So, in BOLT12, because onion
messages aren't yet super-broadly supported on the network, many nodes, or I
think all BOLT12 speaking nodes might try to find a path, but if they don't,
they will just try to directly connect to the introduction node.  This trades
off some privacy for robustness.  We hope to add the privacy back later as more
nodes in the network start to support BOLT onion messages, but in the meantime
we have to do something to make things work.  And if you want to do a direct
connection, you have to know where to connect.  And if you are using RGS and you
did not have the IP address of the node previously, you would have no idea where
to connect, which is obviously problematic.  So, this is a feature for nodes
that are syncing using RGS, so they're mobile nodes or whatever that want to do
BOLT12 and want to use this direct connect feature, a fallback feature, they
need the new version of RGS.  This also has some other improvements just in
terms of extensibility, but it isn't otherwise interesting, I would say.

**Mark Erhardt**: I was briefly looking over the release notes, and one thing
that jumped out to me was HTLCs (Hash Time Locked Contracts) will now be
forwarded over any channel with a peer instead of the requested channel.  Would
that affect users in a noticeable matter?

**Matt Corallo**: Oh yeah, that's something that we should have done a long time
ago, but we never got around to.  And in fact, a patch was contributed by one of
our downstream developers, not something we got around to, sadly.  This effect
is only interesting for routing nodes, and it's only interesting where you have
multiple channels with the same peer, which isn't super-common, but does exist.
In that case, a node tells you to forward over one channel, but you can also
just forward over the other channel.  I think all the other Lightning nodes
already do this, and we just never got around to it.  So, it is useful.  It's
important if you're a large routing node.  C= I believe are actually the ones
who wrote this patch, because they are in fact a large routing node running on
LDK and wanted it.  But with splicing, it will become a little less important,
because hopefully you'll much less often have multiple channels with the same
peer, you'll just splice some more money into the same channel.

**Mark Erhardt**: Cool, thank you.  Also, I believe I know that a transaction
can be 61 bytes, and I'm wondering whether it could be 60 bytes by having an
empty output script.  But 61 is definitely possible.

**Mike Schmidt**: All right.  Thanks, Matt, for walking us through that LDK
release.  Is there any story to the "Papercutting Feature Requests" code name
for that release?

**Matt Corallo**: It's just a reference to we fixed a handful of papercuts
across the API, but also in BOLT12, and implemented a bunch of feature requests.
That was really the focus for that release.

**Mike Schmidt**: Excellent.  Well, I know we're over an hour in already, but
there is an LDK PR.  If you are bored or don't need to go to lunch, you can hang
out.  Otherwise, thanks for joining us so far.

_LND v0.18.3-beta.rc2_

Next release, LND v0.18.3-beta.rc2.  And I noticed that as of yesterday, we also
have LND v0.18.3-beta.rc3.  Similar to how we had Matt on here, it would be
great to have someone from LND when this release is final to walk us through
that.  So, I'm going to punt on that for now.  Murch, I assume you're good with
that?  All right.

_BDK 1.0.0-beta.2_

And BDK 1.0.0-beta.2.  We discussed some of the changes from beta.1 to beta.2, I
think it was last week or maybe it was the week before.  Matt, I don't know how
much interaction you have with the BDK team, if there's any calls to action
you'd have other than folks testing their implementation with the latest RC?

**Matt Corallo**: Yeah, I don't have any specific requests from them that I'm
aware of, but yeah, certainly test the latest BDK.  New BDK is great, working
towards that 1.0.  They're really excited, we're really excited.  Yeah.

**Mike Schmidt**: Excellent.  I think we'll probably have Steve on when that's
final.

**Mark Erhardt**: Sounds good.

_Bitcoin Core 28.0rc1_

**Mike Schmidt**: Last release this week, release candidate for Bitcoin Core
28.0.  This is rc1.  We have a Testing Guide that came out in the past week or
so, and the author, or one of the authors, I'm not sure, of that Testing Guide
is rkrux.  And thank you, rkrux, for staying on for an hour and 15 minutes to
get to your segment.  If you didn't already fall asleep, we'd be very inclined
to hear more about the Testing Guide, highlights from the release, etc.

**Rkrux**: Yeah, I can go through a few of the features that I've tested in the
guide.  I can list and enumerate them and then I can go into the specifics as
needed.  So firstly, I covered the testnet4 support in the guide.  So, the 28
version has the ability to connect to testnet4 unlike the previous versions.
And secondly, I have also tested v3 transactions extensively since they have
become a standard on all networks.  And related to that, I have also tested a
few features specifically for Topologically Restricted Until Confirmation (TRUC)
transactions that are signaled by the version.  So, v3 transactions signal for
those.  So, in this I have tested for sibling eviction, and then I have tested
for the unconfirmed ancestor limits as well that go along with it.  And after
that, I had tested for the cluster size to package RBF feature.  So, if there
are any conflicting transactions within clusters, within packages of size two,
then we are able to RBF, we can do RBF in those, so I've tested for that.  And
after that, there is a point related to spending from pay-to-anchor (P2A)
scripts.  So, the creation of P2A outputs was the standard earlier as well, but
spending from these scripts have become standard now, so I have tested for that.
And then lastly, I also tested for mempoolfullrbf, which is enabled by default
in v28.  So, yeah, I've tested for that as well.

**Mike Schmidt**: Excellent.  I know we have a lot of technically-inclined folks
that listen to the podcast, and so I would encourage folks to find that link in
the newsletter this week for the Testing Guide.  And it's fairly robust
scrolling through here.  I haven't gone through myself, but there's the seven
different overview items that you touched on several of those.  Obviously, also
reference the Release Notes separate from the Testing Guide.  And as we
encourage folks to test this RC, also a reminder, it's great to run through the
guide as written, but also sort of improv and tweak things according to your
curiosity or maybe the way that you use the Bitcoin Core software, so that not
only the same sort of paths are tested, but there's some variance there, and
potentially you can unearth something in your particular setup or the way you
use Bitcoin Core that wouldn't otherwise be surfaced by someone
vanilla-following the guide.  Murch, what would you add or augment about either
the Testing Guide or the release itself?

**Mark Erhardt**: Yeah, I mean, I think we haven't covered the content of
Bitcoin Core as a summary.  I think we obviously talked about a ton of the PRs
that have contributed to this upcoming release.  But my highlights are TRUC
transactions and package RBF, testnet4 of course, and also assumeUTXO ships in
this upcoming release.  I think the one that has had a lot of discussion is
mempoolfullrbf.  So, this is a very small change.  Bitcoin Core will now change
the mempoolfullrbf startup option to true by default.  As we have noticed that
the hashrate seems to have adopted this almost completely, Bitcoin Core will now
match what is expected to be in the blocks and therefore propagate transactions
that RBF, even if the original transaction didn't opt into replaceability.
Yeah, so I don't know, did we want to jump into all the content of the release
or are we doing that when it is released?

**Mike Schmidt**: I was thinking as we were going through this just now, it
might be good to maybe have Gloria and Fabian and some folks on, whether that's
an RC, or when the official release is out, we can kind of jump into that.  What
do you think?

**Mark Erhardt**: That would be fun.

**Mike Schmidt**: Also, since we're kind of running long on the show today.

**Mark Erhardt**: Sure, then let's talk about all the features in detail at
another point.  Rkrux, what's your favorite feature?  Which one are you really
looking forward to, or have you played around with most?

**Rkrux**: The TRUC transactions.  So, I think there are enough test cases that
can be covered over those and I'm new to v3 transactions as well.  So, I have
spent some time on those and I will be spending some more time testing this.

**Mike Schmidt**: Excellent.  And obviously, if folks are going through the
Testing Guide and have feedback on the guide itself, I think you should be able
to provide that.  And that'll get to rkrux to improve that guide or augment that
guide in some way if you get some feedback going through it yourself.

**Mark Erhardt**: Yeah, I think there's an open issue to provide feedback on the
Testing Guide.

**Mike Schmidt**: Oh, great.  Rkrux, anything else you'd leave for the audience
before we move along?

**Rkrux**: I have just a couple of things.  So, this was a good exercise for me
to become more comfortable with bitcoin-cli.  And secondly, I also wanted to
give a shout out to Gloria.  She has been helpful in giving me feedback and
regarding how the guide should be, and also what features could be covered.
Yeah, so thank you to her.

**Mike Schmidt**: Excellent.  Rkrux, thanks for joining us this week.  You're
welcome to stay on to the rest of the newsletter, drop if you have things to do.

**Rkrux**: Thank you.

**Mike Schmidt**: Notable code and documentation changes.  As we go through this
last segment and these last PRs here, if you have a question or comment, feel
free to request speaker access or put a comment in the chat and we'll try to get
to that at the end of the show.

_Bitcoin Core #30454 and #30664_

Bitcoin Core #30454 and #30664, which respectively add CMake and remove
autotools as the build system for Bitcoin Core.  We had Hennadii, or hhebasto,
on in Newsletter #316 Recap, and he walked us through a lot of the motivation
and benefits of CMake and some of the drawbacks of the existing build system
using autotools.  So, big picture, refer back to #316 for that discussion.
There is a huge list of PRs and follow-up PRs here.  I wanted to kick it over to
Murch to maybe summarize your thoughts on the CMake build system and this
collection of PRs broadly.

**Mark Erhardt**: Yeah, I think that we're making a huge improvement in
maintainability and just compatibility here.  This is happening right at the
beginning of the new release cycle, so this is not for the 28 release; this is
for the 29 release.  This is on the master branch, so while we're working on the
release branch for 28, this is now in the main branch where we are working
towards 29 already.  So, as you can see in the news item, there's something like
20 follow-up PRs already because there's all these little things that need to be
ironed out.  I have meanwhile tried building with CMake and it's roughly the
same speed, but I'm so excited to have out-of-tree builds.  I don't know if many
of you have played around with Bitcoin Core builds before, but for example I
contribute to the QA assets where we fuzz.  We create corpora for a bunch of
fuzz harnesses to test when changes are rolled out that none of the features
break, and I always had to have separate work trees in order to have a fuzz
build at the ready.  And, if you wanted to test fuzz harnesses on a release
branch, you'd often have two directories, one for running the tests or making
changes to the code itself, and one for the fuzz harnesses.

With CMake, finally we can have just multiple builds in one directory and just
build whatever we need.  So, this is just a quality-of-life feature for the
developers, and I'm really glad this is finally coming.

_Bitcoin Core #22838_

**Mike Schmidt**: Bitcoin Core 22838, implementing multiple derivation path
descriptors.  Murch, correct me if I'm wrong, but I think this BIP389, we talked
about recently, and so it sounds like now Bitcoin Core is implementing that
recently merged BIP.  Did I get that right?

**Mark Erhardt**: Yeah, that's correct, that was just merged recently.  And the
main point is a lot of wallets follow the paradigm that there is a separate
derivation path or a separate chain of keys for the change outputs.  And the
idea here is that you're able to, for example, put the xpub or descriptor on a
server in order to derive new addresses, like just a pubkey, right, so the
server can generate all the recipient addresses, for example used in, I don't
know, BTCPay Server or other infrastructure for receiving payments.  But the
change addresses are generated only at transaction creation time, and therefore
it is unnecessary to share this information with the server.  So, even if the
server were breached and you were able to generate all of the recipient
addresses of the service, you would never learn their change addresses out of
that.  Well, you could make educated guesses, of course, but for example, if the
service makes batch payments or something like that, it might be difficult to
guess which one is the change output.

So, to facilitate these two separate chains of addresses that a lot of wallets
use, BIP389 specifies a descriptor that sort of, in one go, specifies the
recipient chain and the change chain.  And yeah, Bitcoin Core implements that.
I think there's other wallets that already have implemented BIP389 or pre-empted
BIP389 by having some sort of implementation for that.  Yeah, so this is coming
in Bitcoin Core now too.  Unfortunately, only in 29, not 28.

_Eclair #2865_

**Mike Schmidt**: Eclair #2865, which is a PR titled, "Wake up wallet nodes
before relaying messages or payments".  It's a new feature in Eclair that when
Eclair is relaying either a payment or a message to a mobile peer who's
disconnected, Eclair will actually try to wake up the peer using a mobile
notification system, or attempt connecting to the last known address of that
peer.  We note in the writeup that this is particularly useful in the context of
async payments that are made when a receiver is offline, and those payments are
then held until they come back online.  So, that's obviously a use case that's
bolstered by being able to sort of wake up or connect to that disconnected node.
I didn't have anything else there.  Murch?

**Mark Erhardt**: Yeah, it's just fascinating how energy efficiency is such a
struggle for wallet developers on mobile clients, because you don't want the app
to run all the time, you don't want it to consume your battery.  People have
been joking about having a pocket warmer when some Lightning wallets were just
running all the time on their phones.  But on the other hand, in order to have a
receiver that is not passive -- so onchain payments, of course, the receiver is
passive and they'll just learn about the transaction whenever they parse the
blockchain and they don't have to be interactive at all.  But in Lightning, of
course, the receiver has to sign off on the change of the channel state.  So,
this ability to wake an app and get a tiny slice of computing time, it's kind of
fascinating how that is maybe enough or also just a struggle to get enough
compute time there.

_LND #9009_

**Mike Schmidt**: LND #9009, this is a PR to implement banning for invalid
channel announcements in LND.  So, after this PR, LND will ignore channel
announcements from banned peers.  There's sort of two categories here.  There's
non-channel peers, and if someone's providing invalid channel announcements and
they're not a channel peer, LND will disconnect if their ban score reaches some
ban threshold; and then for channel peers, LND will not disconnect, but when the
ban threshold is reached, LND will ignore that peer's announcements.  It looks
like the banning lasts 48 hours.  And then in this PR description, there's also
a list of future improvements to the banning logic that are being considered as
well, if you're curious about more.

**Mark Erhardt**: I'm wondering what the story here was to make this PR come to
pass.  Have people been announcing a lot of invalid channels?  Matt, do you know
anything about this?

**Matt Corallo**: Not particularly.  I'm not sure if there's been an increase.
I mean, certainly there are reasons why a node might announce an invalid
channel.  Mostly it's not doing gossip verification, but yeah, I'm not sure why
they needed this now.

**Mark Erhardt**: Okay, well maybe if we find it out, we'll talk about it
another time.

**Mike Schmidt**: It does reference a motivating issue titled, "GossipSyncer
should remove unreliable Peers from syncing the ChannelGraph".  But in a cursory
review of that issue, it didn't get anything that I thought was interesting, but
there's probably something in there motivationally.

**Mark Erhardt**: Oh, yeah, I should have asked you!

_LDK #3268_

**Mike Schmidt**: All right, Matt, LDK #3268.

**Matt Corallo**: You're going to have to tell me which!

**Mike Schmidt**: Heading, "Adding ConfirmationTarget::MaximumFeeEstimate for a
more conservative fee estimation method for dust calculations, splitting
ConfirmationTarget::OnChainSweep into UrgentOnChainSweep and
NonUrgentOnChainSweep".

**Matt Corallo**: Right.  Yeah, so I mentioned in the release that we improved
our logic around when we...

**Mark Erhardt**: Matt, we can't hear you anymore.  I think your connection just
took a turn for the worse.

**Matt Corallo**: Can you hear me now?

**Mike Schmidt**: Yeah.

**Matt Corallo**: Yeah, so there's two halves to this.  So, part of having it
was that we improved the forced close avoidance.  So, we no longer force close
if there's a moderate feerate disagreement.  We now allow people to use a
different feerate estimator to decide when their peer's feerate is too high
versus the feerate they use for other channel usage.  And then separately, we
are going to allow our users to use a lower feerate when they're claiming a
commitment transaction when there's no HTLC.  So, there's no urgency to claim
that commitment transaction to get those funds onchain.  We allow users to use a
lower feerate there versus historically, we would use the same feerate whether
there's urgency with that commitment transaction or not.  So, just a little more
flexibility for our users so that they can use different fee estimators in
different contexts.  And we give them all the information they need when they're
selecting the fees.

**Mike Schmidt**: Matt, I don't know if this is the first time, but I'll call it
out here.  You got a hat-trick in this newsletter.  You have the LDK PR, the LDK
release that was by you, we covered the consensus cleanup soft fork, which was
originally your proposal and Stratum v2 as well.  So, kudos for all the work
you're doing on these important projects.

**Mark Erhardt**: I also wanted to ask Matt actually, in the context of talking
about 1P1C opportunistic package relay and TRUC transactions and now this
MaximumFeeEstimate and OnChainSweep change, what do you think would be a
reasonable timeline to expect that the use of TRUC transactions and
zero-fee-commitment transactions with P2A, and all that stuff, might make it
into Lightning transactions?  Would it be unreasonable to expect a year or half
a year?

**Matt Corallo**: That's a very long way away.  Lightning needs a change to the
commitment transaction format, which means all nodes need to upgrade, they need
to start doing it, support TRUC, and I don't think there's kind of a ton of
urgency right now from people.  So, I think it's quite a ways away.

**Mark Erhardt**: That's unfortunate, but thank you for giving your assessment.

_HWI #742_

**Mike Schmidt**: HWI #742, pretty straightforward.  If you're using HWI,
there's now support for the Trezor Safe 5 hardware signing device.

_BIPs #1657_

And last PR this week, BIPs #1657.  I don't know who should take this, Murch or
BlueMatt.  I guess I even forgot we had this one; it's another.

**Mark Erhardt**: Well, too late, Matt just dropped off!

**Mike Schmidt**: Okay, all right!  Go for it, Murch.  What is BIPs #1657?

**Mark Erhardt**: Okay, so this one is just a follow-up to the new BIP353, which
is also by BlueMatt.  And this one is about putting BOLT12 and other address
information into a DNS field on a domain.  And the interesting thing compared to
an HTTP server is you do not actually have to hit the DNS, like the domain
itself, to get DNS information, because DNS is propagated, gossiped around the
internet.  So, what this specific BIP change does is it adds a new field to
BIP174, which is PSBT, and allows you to put the information into a PSBT, where
to get this DNSSEC proof for BIP353.  So, if there is an airgapped or hardware
signing device, or anything like that, you can provide it the proof, and the
hardware device can check that the proof was signed validly.  Yeah, I think that
was roughly what it is.  I was hoping that Matt would have more details, but I
guess you'll have to do with this and read the change yourself.  It's not that
big if you want all the details.

**Mike Schmidt**: I didn't see any questions or comments, so I think we can wrap
up, Murch.  Thanks to all our special guests this week, Matt, Eric, Lorenzo,
Filippo, and rkrux, and of course for you all for listening, and to you, Murch,
for always being the co-host.  Hear you next week.

**Mark Erhardt**: Yeah, thanks.  See you soon.

{% include references.md %}
