---
title: 'Bitcoin Optech Newsletter #296 Recap Podcast'
permalink: /en/podcast/2024/04/04/
reference: /en/newsletters/2024/04/03/
name: 2024-04-04-recap
slug: 2024-04-04-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Antoine Poinsot to discuss [Newsletter #296]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-3-4/85713be7-790f-83ee-82b2-ac970adb1d8c.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #296 Recap on
Twitter Spaces.  Today, we're going to talk about the great consensus cleanup
soft fork, we're going to talk about a call for new BIP editors, and our usual
coverage of releases, release candidates and notable code changes.  I'm Mike
Schmidt, I'm a contributor at Optech and Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.  I currently look a
lot at package relay and other wallets, Bitcoin Core stuff and outreach stuff.

**Mike Schmidt**: Antoine?

**Antoine Poinsot**: Yeah, I'm Antoine Poinsot.  I'm the co-founder of
Wizardsardine, working mostly on the Liana wallet, and I've been working on
Bitcoin Core for the past years as well.

_Revisiting consensus cleanup_

**Mike Schmidt**: Thanks for joining us today, Antoine.  The first news item
that we're covering is related to your post to Delving.  We titled it Revisiting
consensus cleanup on the newsletter, and you posted to Delving that you've been
revisiting BlueMatt's Great Consensus Cleanup soft fork proposal from, I think, 2019.
Maybe you can help frame for the audience what is the Great Consensus
Cleanup, and how bad are the bugs that the proposal attempts to address?

**Antoine Poinsot**: Yeah.  So, the Great Consensus Cleanup is a proposal from
Matt Corallo from five years ago now, which was about closing a number of
vulnerabilities in the Bitcoin protocol, which necessitates a soft fork.  So, I
started looking into it with the objective of determining how bad the bugs that
it intends to fix actually are, how much the mitigations that it proposes
actually improve the worst case or improve the situation in general, given that
it's been five years already, if there is anything else that we could have come
up with that would be worth fixing, and if there is a better way of fixing the
bugs in the original problem.  So, maybe I can go over the bugs quickly.

So, the first one that I detailed is the timewarp bug.  I think this one is
always a bit underestimated.  It's been discussed forever in Bitcoin, and since
it seems that it can only be exploited, or at least that there is only an
incentive to exploit it for a 51% attacker, it's been overlooked.  So, yeah,
what it is first.  The timewarp vulnerability allows a majority hashrate
attacker to reduce the difficulty at which to mine blocks in order to mine
blocks faster.  And as the attacker mines the blocks faster, he will be able to
further decrease the difficulty.  So, that's really the big thing with timewarp.

In Bitcoin, you can always hold back the timestamps, right?  So, there are rules
to constrain the miners, how the miners set the timestamps, which is that a
timestamp may not be more than two hours in the future at the time the node
receives the block.  And the timestamp of the block must be higher, strictly
higher than the median of the past 11 blocks.  So, that's the only things that
constrain the timestamp of the blocks.  And so miners can always try to hold
back the timestamps in between blocks.  But they're not going to achieve much.
They're going to take the time in the past so they won't be able to enable
future timelocks before.  And if they start trying to reduce the difficulty, as
soon as they try to do it, the difficulty is going to moon back up immediately.

It's not the case with timewarp.  With timewarp, as the attacker reduces the
difficulty, he will be able to reduce it even faster and faster and faster up
until he gets back to a difficulty 1, at which point he can basically kill the
chain.  It obviously creates issues with timelocks because then with a 51%
attacker, which exploits the timelock vulnerability, you can expire all the
timelocks in Bitcoin, so obviously all the protocol's relaying and timelocks
will be broken.  Also, it creates new vectors for spam because the only limit on
the size of the UTXO set, the growth of the UTXO set, is the block size.  And
so, if you increase the block rate by especially that much, you can spam the
UTXO set very, very badly.  And I would argue what's been missed a lot in these
discussions is that in Bitcoin, you can't have temporarily 51% attackers.  They
can cancel transactions, but they're always going to be challenged.  They're
always going to be challenged by anyone able to have a hashrate anywhere in the
world.  And so, they have to constantly be wasting energy to maintain the
censorship.  With timewarp, in 40 days, they can take over the network or take
down the network rather.  So, I think it really changes the security model of
the 51% attacks.  So, I think it would be good to fix it.

In terms of mitigation, the fix is obvious.  The bug comes from the fact that
there is an off by one in the retarget periods for the difficulty adjustment.
And the proposal from Matt from five years ago has taken into consideration the
software that is already deployed by ASICs out there and just make it so these
retarget periods actually overlap with trying to minimize the probability of a
miner creating an invalid block, which is always what we're trying to do when
we're designing a soft fork, avoiding that stakeholders in the ecosystem lose
money.

Okay, next.  Just cut me, Mike, if I'm speaking too much.

**Mark Erhardt**: Maybe before we go into the other issues, I'd like to add one
little thing to the timewarp attack.  So, one of the issues is when the
difficulty goes down, the interval between the blocks obviously shrinks.  And at
some point, a single miner can so quickly create blocks that other miners are
hampered significantly by the latency of receiving those blocks.  And at that
point, the network might actually start to diverge and no longer converge on a
single best chain, just because the frequency at which new blocks are turned out
becomes so high that others no longer receive them before the next one comes in,
and therefore cannot contribute mining power.  And at that point, we might
actually not have a single best chain, but many authors pushing out their own
best chain because they never see the more-work chain of other miners before
they find their own.  And yeah, it's a pretty bad catastrophe.

**Antoine Poinsot**: Yeah, so it is, and something I forgot to mention as well
is the political implications of exploiting the timewarp.  As someone said, it
didn't come from me, but when I presented it, someone, this person told me,
actually the miner would not take down the network, they have no incentive to do
that.  Rather, they would exploit the timewarp to increase the block rate by
like 10%, 20%.  When they start doing that, the miners have obviously an
incentive to do that.  They can send more block space more rapidly; they can
take more subsidy at the expense of future miners; and also, a lot of the users
have short-term incentives to enable the miners to do so, because they would pay
less fees.  But it's actually long term, well, it benefits everyone short term,
but it does not benefit everyone, it hurts everyone long-term, because if miners
start exploiting the timewarp at, let's say, a 10% or 20% increase in the block
rate, then we are always on the brink of this cartel of miners being able to
take down the network.  So, that's pretty bad as well.  And as the subsidy
exponentially decreases as well, the incentive for miners to try to use such
techniques to increase their revenues gets more likely.  So, we would do good to
address these issues before it gets messy politically to fix.

Next bug, worst-case block validation time.  So, this one is actually being
discussed in non-public channels; well, just the details of this are being
discussed.  So, I'm not going to expand too much, but basically I could come up
with a block -- so, it's well known that we had blocks which took a long time in
2015 to validate.  It was in 2015 that took a couple minutes to validate on
low-end machines or even mid-range machines.  Nowadays, it takes about a second
to validate.  So, I could come up with a block which today takes at least three
minutes to validate with all the optimizations and the shredding on my fairly
modern laptop, and which takes an hour-and-a-half to validate on a Raspberry Pi,
and on a Raspberry Pi, not the low-end Raspberry Pi, on the latest Raspberry Pi
with the SHA256-specific instructions, the ARMv8 crypto settings for anyone who
is interested.  So, that's not great.

So, there is a few games that could be played by using large validation times.
Obviously, large validation times are bad because we want to make validation
accessible, but in addition, large validation times can be exploited, for
instance, by miners to get a head start in mining the next block over other
miners.  So, again, it's another vector for mining centralization, but it can
also be played by lower miners.  Miners can attack each other using this attack,
but you can also attack nodes.  It's not clear how, for instance, if you have an
LN node running on top of your Bitcoin Node, if your Bitcoin Node is going to
take ten minutes to validate a block and that they are expensive, is the LN node
going to bail out?  If it bails out, are your channels still going to be
watched?  And maybe there are other games that we don't know of.  So, just for
these reasons, the details are not being discussed publicly.  But obviously, it
would be nice to reduce the worst-case validation times.  There is always a
trade-off between how much you want to reduce the worst case and the
confiscations that you want to impose and use those for legacy transactions.
So, yeah, there is a balance to strike and it's being discussed.  And once
people are happy with one way of doing things, probably we're going to post it
on the public thread.

Then, there is the infamous 64-byte transactions.  How the Merkle tree is
computed in Bitcoin is absolutely broken, it's been broken in multiple ways and
new ways have been found over time.  The last two attacks on the merkle tree of
Bitcoin blocks allow to fake the confirmation of a transaction, fake the
inclusion of a payment in the Bitcoin blockchain to an SPV verifier, or to fork
a Bitcoin node which does not have some mitigations in place.  So, it works by
either faking that a 64-byte transaction was included in a block, so that you
can give a merkle proof down to this transaction; or, it works by having the
concatenation of two transactions which actually corresponds to a valid
serialization of a Bitcoin transaction.  In this case, you tell a node, "Here is
a Bitcoin block, here is the merkle tree for it", but it's not actually the
right merkle tree.  It's a merkle tree with some of the transactions in the
block pruned, and the node is going to deserialize that, the merkle tree is
going to be valid, the merkle proof is going to be valid, it's going to
deserialize the transaction.  Obviously the transaction is going to be invaded,
and then it's going to discard the block.

If the node, in order to not get dust, just catches that this block is invaded
by the time that it is going to receive the actual valid block with the same
merkle tree and the same merkle proof but a different set of transactions and
these transactions actually are valid, then this node will already have cached
the failure and therefore will discard the valid block and you've got a net
split in this case.  So, in order to avoid this, Bitcoin Core does not cache the
failure up until a certain point in the validation of the block.  But it would
be nice if we could remove this foot gun and if we could cache these failures
actually.  And for the SPV attack, it requires some brute force to execute this
attack.  However, as the difficulty increased in the chain, in the main Bitcoin
chain, this attack looks more and more cheaper compared to other SPV attacks
that you can make on SPV verifiers.  And keep in mind that it's not only legacy
SPV wallets out there that are verifying SPV proofs, it's for instance
sidechains and, I don't know, whatever software could be verifying an SPV proof;
it's very common.

So, there is also a simple mitigation in this case, which is, well, I'm not
going to detail the mitigation, but there is a simple mitigation in both cases,
both to fork off the network, so there is a simple mitigation, just don't cache
failures; hey, it's not great, but at least you can do that.  And for SPV
attacks, you have a simple mitigation as well.  Yes, it would be good if we can
make 64-byte transactions invalid by consensus so we don't have to deal with
these foot guns anymore in the future, and in case we find new attacks related
to the merkle tree.

Finally, I think we could afford including a fix to make coinbase transactions
actually unique.  So, it was found by Russell O'Connor back in, was it 2011?
Yeah, 2011, I think, that in Bitcoin, two coinbase transactions could be
completely identical and therefore have the same txid.  And then, since the
outputs of a transaction, which represent the coin which exists in the system,
are referenced by txid, this gets issues, right?  So, with BIP34, it was
required that new coinbase transactions include the block height for the blocks
that are included in the script sig in order to make them unique.  So, new
coinbase transactions are unique.  However, there were plenty of coinbase
transactions before BIP34 activated which could be duplicated in the future in
theory.  It's very theoretical, but it would be after around block 2 million,
the block height 2 million.  So, it's still far away, but still it would make
sense that we make Bitcoin transactions unique.  Yeah, I guess that's it.

**Mark Erhardt**: I have a question that sort of comes up with this.  When you
duplicate a coinbase transaction from the past, obviously you have to replicate
all the outputs on that coinbase transaction as well, in particular, the
coinbase for block 1,900,300-whatever.  It pays out something like 100 bitcoins
to a given set of recipients of that coinbase.  Assuming that in 15 to 20 years,
Bitcoin is still around and potentially given the limited supply is very, very
valuable, what could an attacker achieve by duplicating this coinbase
transaction while paying money to the same people that mined the block like ten
years ago?

**Antoine Poinsot**: Yeah, it should be costly to do that.  Also, it's possible
that it's not even duplicable because, well, then what you can do is to spend a
transaction with the same transaction as the original coinbase transaction was
spent at, and you can, I forget what the attack in Russell's post was, but I
think it has to deal with how Bitcoin Core would update its UTXO set upon reorgs
that if there is a reorg, we would reapply the new coinbase and not the original
coinbase, or something like that.  I don't remember exactly.

**Mark Erhardt**: Right, and so the fix for that would be to either require that
coinbase transaction in the future to also put the height in the locktime, which
previously no transactions, no coinbase transactions that have height strings in
them, they had all zero, I think, in the timelock; or, the alternative is to
require that they do a witness commitment, aka that these specific blocks must
be segwit blocks?

**Antoine Poinsot**: Yeah, both work.  Originally, I was more in favor of making
it mandatory to have a witness commitment in the output of the transaction, of
the coinbase transaction, because it's already something that miners do, and it
seems like the most backward-compatible change, compared to having to update to
new templates, which would put the block height in the nLockTime.  But it's also
at block height 2 million, so it's the whole lifetime of Bitcoin again in the
future.  So, I feel like we could just do the obvious thing and require that the
block height be put in the nLockTime and call it a day.  I think the
backward-compatibility concern is lesser given the time before it would be
activated.

**Mark Erhardt**: Yeah, the advantage here would be of course that whether or
not someone mines an empty block or doesn't include any segwit transactions, or
anything like that, the locktime is already a field on the coinbase transaction
that has previously not been used.  So, requiring that the coinbase transaction
commit to the height in the locktime would be probably the least restriction
that obviously breaks with the past transactions.

**Mike Schmidt**: Antoine, you started a wishlist on Delving and you got into
that with the BIP30, BIP34 discussion here.  Have there been other wishlist
items that you've considered or that others have considered adding?

**Antoine Poinsot**: I've not, well, nobody suggested anything that I would
consider relevant yet.

**Mike Schmidt**: Isn't there like the year-2106 timestamp issue?  Maybe that's
not soft-fork solvable?

**Antoine Poinsot**: Yeah, I didn't consider it because it's so far in the
future.  I could look into it.  I honestly didn't even consider it at all.

**Mike Schmidt**: What's feedback been on both the Delving post, or any feedback
that you've gotten outside of Delving on reviving this?

**Antoine Poinsot**: I think I know it sniped a couple of people into figuring
out what's the worst block validation time, so I think that's good feedback.
And in general, I think a few people think it's valuable to have not insane
block validation times, unique coinbases, fixing timewarp, so I did not receive
any bad feedback on the concept, let's say.

**Mike Schmidt**: Maybe to follow up on that comment, so what stopped this from
moving along previously?

**Antoine Poinsot**: I don't know, someone picking it up?

**Mike Schmidt**: All right, well good thing that we have you now.

**Antoine Poinsot**: Yeah, let's see how well the research is going before
proposing anything.

**Mike Schmidt**: Maybe a meta question, how did you find yourself working on
this particular issue or curiosity?  I know we've had you on talking about a
bunch of different things previously, so I'm wondering how you found yourself
here.

**Antoine Poinsot**: I don't know.  I just figured it was an invaluable thing
that nobody was working on and it was worth investigating.

**Mark Erhardt**: Yeah, we absolutely should work on this.  As Antoine already
said earlier, the timewarp attack is actually pretty horrible.  We would see
that it starts to happen by just a huge number of miners backdating their
blocks, and then we would only have something like four weeks as a community to
react with a soft fork that fixes the issue.  I think just the short timeline
that we would be forced into, and seeing how -- nice segue here -- how other
processes for which we don't really have any good decision mechanisms take, I
don't think that wanting to deploy a soft fork to fix an impending doom in four
weeks is a particularly nice prospect.

**Antoine Poinsot**: Yeah, and also, where do you draw the line between
deploying a soft in four weeks and users coordinating to decide which chain is
the valid one?  So, I think this is also something that people have been saying,
yeah, "Timewarp will be obvious if it's exploited.  We can just…", who is "we"?
And I'm not sure.  So, I think if Bitcoin users need to coordinate to choose the
valid chain, it loses a lot of its value proposition.  So, yeah, we should fix
it in advance.

**Mike Schmidt**: Really excited to see you working on this, Antoine.  Any final
words for the audience before we move on?

**Antoine Poinsot**: Yeah, apply for my wallet, try Lianna Wallet, I just
released v5. And I guess that's it.  Keep yourself informed with the Great
Consensus Cleanup.  I'll keep you guys updated on the public posts with new
advancements.

**Mike Schmidt**: Thanks for joining us, Antoine.  Go ahead, Murch.

**Mark Erhardt**: Sorry, I was just saying, very sneaky ad here, I almost didn't
notice it.  Yeah, Mike, go ahead.

**Mike Schmidt**: Antoine, you're welcome to hang out with us.  If you have
other things to do, we understand.  Thanks for opining.

_Choosing new BIP editors_

Next news item, titled Choosing new BIP editors.  Now, Murch, we covered your
follow-up in the thread about adding new BIP editors on the mailing list.  Maybe
for a quick recap, for the last six weeks or so, there's been discussion on the
mailing list about adding new BIP editors.  Some of the back story there is that
Kalle and Luke were editors for the last several years, and recently folks have
expressed some frustration with the BIP process.  And somewhat around that
timeframe, Kalle stepped down as a BIP editor, leaving Luke as the only BIP
editor.  And then recently, Luke posted on Twitter about 133 PRs open to the
BIPs repository and looking for volunteers to help, and then there was a mailing
list post that sort of kicked off the discussion.  There's been a lot of
discussion on that email thread on the mailing list with a bunch of proposed
candidates and how to think about endorsing a candidate.  I'll pause there.
Murch, I know you followed up in the thread sort of trying to move the process
along a little bit and trying to make a decision or a few decisions by I guess
tomorrow.  What's the status of that?

**Mark Erhardt**: Yeah, so a couple of people had concerns about the timeline.
Apparently, ten days is not enough time and there's a Core developer meeting
coming up, so people wanted to space it away from that a bit so that the
decision would definitely be made in public.  That's all fine.  As you already
said, there had been a bit of a frustration with the BIP process for a while.  I
would perceive the timeline slightly different.  It's been a high-friction
process for a very, very long time, to the point that the Trezor people made
their SLIPs in a separate process.  The Lightning BOLTs, which could have been
BIPs, have their own specification process and repository.  Three months ago,
finally, AJ opened the BINANA repository to basically offer a parallel
institution where you can publish documents for public consumption and
discussion.

So, yeah, I mean it was a high-friction process three years ago, which was why
Kalle was added as another editor in the first place.  So, it's just been almost
forever that it's been like that.  My intent here was now, given the friction
and also just the broad agreement between people consuming the BIP repository,
people writing for the BIP repository, or contributing to it, and the current
BIP editor all saying that it would be great to have more help, and then the
discussion on the mailing list just fizzling out, it seemed like it needed to be
restarted.  So, I guess I made a shot from the hip and said, "How about we just
try to set an end date for this discussion and see what happens until then, and
then we can try something else?" sort of inspired by the way we tried to deploy
taproot, a speedy trial, just try something for a while so we are better
informed to potentially try something else.

Anyway, what happened is basically the same thing that happens in open source
when there's no clear authority on a matter and no clear decision process, or
process in general, we do not have a process on how the BIP editors are
selected, so everybody has an opinion, nobody wants to make any decisions or can
make any decisions.  So, I hope that maybe by the end of the month, we can just
interpret what all has been said on the mailing list, and then maybe agree on
how it is interpreted and make a decision.  Or, yeah, well, rough consensus is
hard when you're all in a room, but it's even harder on a mailing list or in a
diffused community situation.  So, my hope would generally be, it would just be
good to be able to have the central place where we can publish ideas and
proposals for how we want to work on the Bitcoin protocol.

I think it's more important that we can actually have access, like the proof of
work is already in the documents themselves.  The documents have to be formatted
correctly, have to be comprehensive, they have to fill out a bunch of different
sections, like backwards compatibility, and otherwise they're not going to merge
just for formal reasons.  I don't think that we have to make it much harder than
that to prevent spam.  And maybe as a separate discussion, and it should be two
separate discussions, one being whether or not we add editors and who those
editors are going to be, and the second discussion being whether the BIP process
in itself might need some reform; but in my opinion, it might be better to be a
little more progress-focused and merging stuff a little quicker, and then in the
consumption of the documents, assess them rather than trying to gatekeep
proposals that some people might think are a bad idea or are not clearly a great
move forward.  Yeah, it might be just nice to take the personal assessment of
the editors out of that a little bit.

**Mike Schmidt**: There's been a bunch of people who have been nominated by
others and there's some folks who have also self-nominated to be BIP editors.  I
don't know, Murch.  It sounds like I want to be a BINANA maintainer, I want to
be a BINANA editor, because you just see if it's spam and then you merge it,
right?

**Mark Erhardt**: Absolutely.

**Mike Schmidt**: So, I'm self-nominating BINANA editor.  AJ, I see you in here,
let's make it happen.  Murch, do you think it's worth informing people, maybe at
a high level, of what the editor responsibilities are?  I think maybe some
people can over or underestimate what that is stated to be responsibilities, or
do you think that's getting too much in the weeds?

**Mark Erhardt**: I've recently consumed BIP2 again, which sets out the BIP
process, and I find that it is a little vague and leaves a lot of ambiguity in
certain parts.  For example, it requires that BIPs are about Bitcoin and stick
to the general philosophy of Bitcoin; and who assesses whether or not an idea is
in adherence with the philosophy of Bitcoin?  I feel that is a very difficult
point to assess because basically there's as many opinions on what exactly
Bitcoin is as there's users.  And, yeah, the other one is that it has to be
technically sound and a good idea, but then the process document also states
that even if it might not get accepted or be considered broadly a good idea, it
should still get merged.  So, there's just a few points there that could be a
little clearer.

What the BIP authors do is they are asked to assess PRs to the repository and
ensure that everything is formatted correctly and complete.  And then, I guess
BIP2 also requires them to make some sort of technical assessment and
philosophical assessment of the proposed idea.  And I think this, as well as the
number assignment, has been a little bit of a bottleneck.

**Mike Schmidt**: If you're curious about this, jump into the Bitcoin-Dev
mailing list and you can view also the archives on the Google group.  Fairly
active discussion, a lot of people have opinions on that.  I think we can
probably wrap that up.  Oh, Murch, you have an opinion, go ahead.

**Mark Erhardt**: Yeah, I wanted to jump in on something else that you had
touched on that I forgot to mention just now, which was there's been a few
people that have been nominated and a few people that have self-nominated.  I
think that it is generally not a job that a lot of people want to do because
there's 138 open PRs, probably a lot of work in the next half year or so at
least to go through that and merge and clean out and try to get in touch with a
bunch of people that haven't contributed to Bitcoin in a decade and…  So, I
don't know if in a way, it's already a bit of a red flag if people want to do
the job, but yeah, it would be great if we maybe added another three to five
people to this job so we could make progress.

_Bitcoin Core 26.1_

**Mike Schmidt**: Next section from the newsletter, Releases and release
candidates.  We have three.  First one, Bitcoin Core 26.1 being released.  And
we linked to the release notes that I have up in front of me, but I don't know
if it makes sense to go through these; there's a lot of minutiae here.  Murch,
do you maybe have a tl;dr on fixes in here, other than encouraging folks to
upgrade?

**Mark Erhardt**: I think we've talked about 26.1 two or three times already,
and once we went into the details, and then after that we've referred to the
previous ones.  It's just a couple of bug fixes.  For example, there's this
issue with SFFO.  It's stuff that doesn't get hit very often.  There's things
that are more concerning, maybe that a cookie file is not generated, and so
forth.  But if you really care and you're deploying back-end software that has
to work, that you have to be compatible with your integration with, and you
depend on all your money in a business context, I think yes, you should go
through the release notes and in detail understand the changes.  But for most
people, they will probably not notice a difference.  It's just a few bug fixes.

**Mike Schmidt**: And perhaps for our audience, we linked to the release notes,
and there are PR numbers categorized by type of changes.  So, you may just be
technically curious about what are some of these changes that went into 26.1, so
click through and into those to satisfy your curiosity there.

_Bitcoin Core 27.0rc1_

Bitcoin Core 27.0rc1.  This is basically a duplicate of our entry from last
week, and we went through the Testing Guide in more detail last week, so I would
refer listeners back to that to get a bit more detail and a guide for them to go
through 27.0 if they want to poke around.  Anything to add there, Murch?

**Mark Erhardt**: No, I think we dove deep into that one last week.

_HWI 3.0.0-rc1_

**Mike Schmidt**: Last release candidate is HWI 3.0.0-rc1.  I pinged achow
before this spaces kicked off, and she noted that this was really just changing
the default behavior to not detect emulators, and thus the version bump is
required because semantic versioning says to do that for breaking changes.  So,
that's all I'm aware of for this particular release candidate.  I don't know if
you knew more, Murch?

**Mark Erhardt**: No, I've just looked at the commits since 2.4, which we talked
about I think a month ago or so, roughly.  And, yeah, it sounds like people that
are working with the HWI as a development tool will notice a difference.  And
yes, breaking changes require the bump on the major version, so this is 3.0 for
the emulator.

**Mike Schmidt**: As we move to notable code changes, I'll take the opportunity
-- I see Antoine is still here.  If you're curious about some of the consensus
cleanup work that he talked about, feel free to chime in and request speaker
access; similar for these release candidates or the BIP editors news item
earlier.

_Bitcoin Core #27307_

Bitcoin Core #27307 begins tracking txids of transactions in the mempool that
conflict with a transaction belonging to the built-in wallet.  Murch, I saw that
you were one of the reviewers on this particular PR.  Maybe it would make sense
for you to explain the motivation for tracking these things.

**Mark Erhardt**: Yeah, I guess we were previously not super-explicitly keeping
track of what exactly the problem was with a conflicted transaction.  So, a
conflicted transaction in the first place is a transaction that spends the same
inputs as another transaction.  And if we have one of those in our wallet, for
example, because we RBFed something or, yeah, well let's say we have two
instances of the same wallet, which you should never do, and the other wallet
RBFed something, then we might see this as a conflict on our wallet.  And now
with this explicit tracking of the mempoolconflicts, we previously didn't
distinguish whether it was a conflict with something that was still unconfirmed
in the mempool, or confirmed in the blockchain as cleanly, and now this is all
sussed out.  So, for example, when you make a gettransaction call for a wallet
transaction, you will see which transaction exactly something conflicts with and
it'll properly count any other inputs that are no longer spent, because the
transaction is being conflicted already, as spendable and counts them towards
the balance.

So, it's maybe removing a bunch of the quirks for people that have used RBF
before with multiple input transactions, and cleans up basically stuff in the
back end about tracking conflicting transactions.

**Mike Schmidt**: And right now as a user, I would see this field if I'm calling
the gettransaction RPC, but there's nothing in the GUI at this time, is that
right?

**Mark Erhardt**: Yeah, I think it's not shown in the GUI.  It would only show
on the RPC and it would be empty of course for most transactions because there's
no conflict in the mempool.  But specifically, if you had a transaction that got
pushed out of the mempool by a conflict, for example if someone else paid you
and then RBFd their transaction to instead pay the money back to themselves,
then you would see it in your wallet because your wallet had picked up the first
one as a recipient; you would see now that this transaction got redirected and
there's a conflict, and you would learn the txid.  So, yeah.

_Bitcoin Core #29242_

**Mike Schmidt**: Next PR, Bitcoin Core #29242, which adds RBF diagram checks
for single chunks against clusters of size two.  Maybe to begin, what is a
diagram check, Murch?

**Mark Erhardt**: Okay, so you all have probably heard about cluster mempool at
this point.  The general idea there is that we do not track transactions only in
the context of their ancestries when we assess what should be in the mempool and
what should be picked into blocks, but we rather track transactions in the
clusters they form, where a cluster is all the transactions that are connected
via child and parent relationships transitively.  So, it could be you start with
a transaction, and then the parent of that, the child of that, the parent of the
new child, and so forth, everything that is connected in any way forms one
cluster.

The big advantage of this new approach is that we can sort the mining order
inside of the cluster fairly easily.  We can definitely do this optimally for
clusters of up to 20 transactions, and we can do it greedily for clusters with
up to 100 transactions.  And then, by basically just comparing the orders in all
of the clusters, we get something akin to a total order in the mempool, and that
allows us to remove transactions when we're purging, for example, because the
mempool overflows in exactly the opposite order in which we're mining.  So, we
pick from the front of these clusters to mine, and when we discard transactions
due to the mempool running full, we discard from the end of the clusters in the
order that we would mine them last.

So, how do we sort stuff in the mempool?  Well, we sort of make the optimal
feerate diagram in a cluster.  We sort transactions in the cluster such that the
front of the cluster has the most fees and the end of the cluster has the least
fees added, and of course we respect topology.  And it turns out that when we
use these feerate diagrams, which really is just fee over weight of
transactions, we can compare different clusters with each other.  And if one of
the feerate diagrams is always the same or higher than the other feerate
diagram, it is just obviously better than that feerate diagram.  So, we can use
this as a cleaner assessment of whether or not a replacement should be accepted
or not than the BIP125 rules, which are a little harder to assess and can
sometimes lead to cases in which we accept transactions that make the mempool
worse, at least in some dimensions.  So, in the context of a cluster mempool
proposal, we use the feerate diagram as a new mechanism of assessing mempool
incentive compatibility.  That was a mouthful.

Okay, so this PR basically adds utility functions to allow us to compare two
different clusters with the feerate diagram checks, and then specifically it
adds another utility function that allows us to check whether a replacement that
would replace up to two transactions is better than the original content of the
mempool.  And if that's the case, hopefully soon when another follow-up PR will
be merged, we will start applying this for the assessment of clusters with two
transactions, which will allow us to opportunistically relay transactions in the
context, like one child and one parent packages, via stashing something in the
orphanage so you would see the child first, see, "Oh, I don't know the parent",
stuff it in the orphanage, and when you then ask the peer that gave you the
child transaction, "Hey, can you give me the parent, too?" you would, instead of
assessing the parent only as a singular transaction and potentially fail it
because individually it doesn't have a high enough feerate, you would be able to
assess it as a package with the child from the orphanage and the newly arrived
parent.  And you would even be allowed to RBF, because we now have comparison
rules that allow us to assess whether the replacement has a better mempool
incentive compatibility, and then we accept it.  Okay, did you catch all that?

**Mike Schmidt**: Mempool's wild, huh?

**Mark Erhardt**: It's the hard piece of how everything ties together in the
Bitcoin Core client and it has pretty complicated logic.  There's sort of a lot
of assumptions that are not explicitly stated in there.  And honestly, it
actually gets a lot cleaner and more well-defined with cluster mempools.  So,
yeah, pretty excited about the work there.

**Mike Schmidt**: In the write-up for this PR, we linked to Suhas's post on
Mempool Incentive Compatibility, which is on Delving, which also has some
example feerate diagrams that we talked about.  And there's a visual way to see
some of what we're talking about here, and that may help listeners sort of put a
visual to it.  And then maybe, I don't know if we've talked about this, maybe
just briefly, but Murch, what is a TRUC transaction?

**Mark Erhardt**: Okay, so we've heard about v3 transactions before, and v3
transactions is sort of naming the concept after an implementation detail.  So,
yes, these transactions will be labeled with v3 and they will opt into a
topological restriction.  So, a v3 transaction will only be able to have one
child or one parent; and if it has a parent, it can only have 1,000 vbytes in
size.  So basically, it forces clusters to be only a size of two.  You cannot
make v3 transactions or insert v3 transactions in bigger clusters, and that
makes a lot of the complexity of package relay and package RBF manageable.  For
example, in the context of the PR we just discussed, we have already all the
tools to assess the comparison of two clusters of transaction size two.

So, TRUC transactions is the concept-based name, Topologically Restricted Until
Confirmation.  When you label a transaction with v3, you opt in that it is
restricted to this two-transaction cluster topology, and in exchange for that
you cannot be pinned as easily, and therefore it will be much easier for you to
reprioritize your transaction.  We assume that this will be, for example, useful
in LN, where a commitment transaction is time-sensitive and we need to be able
to close channels in a timely fashion, and then a transaction that, for example,
spends an anchor output would be fairly small, and we would only allow a single
child.  And then we talked about sibling eviction I think last week or two weeks
ago, so in the context of a commitment transaction with one anchor, two anchors
or ephemeral anchors, or whatever, if someone else makes a second child to this
v3 transaction parent, we would allow the more mempool-incentive compatible
child to be persisted, even if it's not actually spending exactly the same
input.

So generally, this is basically the start of us having actual package relay, the
start of package relay on mainnet.  And just to be clear, this is not for the 27
release; this is going to come in the 28 release hopefully, which is
six-and-a-half-months away.

_Core Lightning #7094_

**Mike Schmidt**: Thanks, Murch.  Core Lightning #7094, which removes multiple
features previously deprecated.  And we made reference to the deprecation scheme
that we talked about in Newsletter #288, which was Core Lightning #6936, and
that was the PR that introduced a deprecations markdown file for keeping track
of deprecations.  And it also introduced this funny named option in Core
Lightning (CLN), which is i-promise-to-fix-broken-api-user, and it's an option
that allows folks if they forgot, or didn't see that certain features that they
were using were deprecated and that feature was then removed.  There's one
version, sort of grace period in CLN, where you could use that i-promise flag
and provide a feature name, and that feature will be turned on for that release.
So, that was in response to users of CLN maybe not paying attention to
deprecation, or not addressing that deprecation, and then all of a sudden that
feature being gone.  So, there's sort of this one release grace period, and that
was #6936 that introduced that scheme.

This CLN PR this week actually removes a bunch of features that have been going
through that pre-release deprecation scheme for CLN.  I saw that there was about
4,100 lines of code removed with this PR, so I bet that feels good for the CLN
team to remove all of that old code.

_BDK #1351_

And last PR this week, BDK #1351, which formally defines that project's stop_gap
variable as, "The maximum number of consecutive unused addresses".  And so, not
only did they define that gap definition, but they also then made related code
changes across the repository to reflect that definition.  So, that gap variable
is used in BDK when their full_scan function is called.  And in this PR's case,
that scan function is going against Esplora to find transactions related to that
user's wallet.  So, if there's no transactions related to addresses for stop_gap
number of addresses, then it'll stop that scan.  So essentially, if you're
running a web shop, you're using BDK, potentially users will generate a payment
address and you'll use a unique address for every checkout on your site, say.
And if a bunch of people abandon their carts after you've generated addresses,
potentially you could hit that gap limit, depending on what that is, it could be
hundreds, it could be thousands.  And it's essentially just a scheme, because in
theory you could generate indefinite, maybe near infinite number of addresses,
so you don't want to just keep churning through, scanning for those.  So, the
gap limit is sort of a limit to that, that BDK has put in place.  They actually
had that in place already, but they've redefined what that means.

As part of the writeup for this PR this week, we've also included a gap limit
topic on the Optech Wiki as well.  Murch, did you get a chance to jump into that
BDK PR?  Do you have any further comments on gap limit conceptually or more
generally?

**Mark Erhardt**: I did not look at the PR directly.  I think generally, you
should use probably gaps of at least greater than 100, maybe 1,000, and then
most of the problems that people have had headaches about for gaps will just go
away for you.

**Mike Schmidt**: I didn't see any other questions.  Antoine, I saw you had some
follow-up in the thread.  I don't know if you want to comment on that.

**Antoine Poinsot**: Yeah, maybe.  Am I unmuted?  Can you hear me?

**Mike Schmidt**: You were speaking and then muted, now you're back.

**Antoine Poinsot**: Okay, yeah, because I don't see it on the UI.  Okay, yeah,
maybe that's interesting to people.  So, I refreshed my memory about the
original attack, and I also realized that it was not the question that Murch was
asking.  So, Murch asked, "If there is going to be a duplicate of a coinbase
transaction in the future, what would happen?"  So, what would happen is that
the block would be invaded because if we don't do anything else, Bitcoin Core is
going to perform still the BIP30 validation, which is a little bit expensive.
It requires to go through the whole list of transactions in the block before
processing it and verifying that none of these transactions already exist as in
the UTXO set.  It means that you can have a duplicate if all of its outputs have
been spent in the past.  So, the rule for BIP30 is that there exists no unspent
transaction with the same txid.

Then, just to add a little bit of history, maybe I can talk about the original
attack described by Russell O'Connor in his Overheating Economy post, which was
actually in 2012.  I was wrong again on this one, not in 2011.  And so, the
original attack is that if you can override a coinbase transaction in the past,
you can override the height, the confirmation height of the UTXO.  So, coinbase
transactions cannot be spent before 100 blocks, but you can overwrite the txid
of the transaction which spends the coinbase transaction as well.  So, let's say
you have a transaction A, which was confirmed 200,000 blocks ago, so you can
think it's pretty reliable.  This transaction is itself spent by thousands of
future transactions in future blocks, well, which are past blocks from now, but
later blocks.  And what you can do by rewriting the coinbase transaction, and
therefore this transaction, is just to recreate the UTXO and the UTXO set, but
with the new confirmation height.  And then, if you manage to reorg, to do a
one-block reorg, and unconfirm this transaction or replace it with a conflicting
transaction, you've effectively invalidated this transaction, which had hundreds
of thousands of confirmations and all the transactions that's dependent on it.

As Russell notes in his post, there's not really an incentive for the attacker
to do that.  It's just, yeah, nobody, even if there is no incentive for it,
nobody should be able to and confirm your transaction.

**Mark Erhardt**: So basically, by first remining the same coinbase transaction,
then reorging out the block, you could delete the people's ability to spend the
outputs from the original transaction in case -- wait, no, if there had been any
left, BIP30 would have blocked it, so you only remove the old transaction only
on the people that saw the reorg.  So, it might be a net split?

**Antoine Poinsot**: No, no, you can't do anything anymore.  With BIP30, you
can't exploit this attack anymore.  This attack was closed with BIP30, and then
people realized, "Well, maybe instead of performing this expensive BIP30
validation, what if we made coinbase transactions unique?"  And then, they
created BIP34 to make the coinbase transactions unique.  But then, actually, you
can still duplicate coinbase transactions from before BIP34 activated.

**Mark Erhardt**: Right, so this attack seems altogether fairly theoretical, but
it's just some sort of shit-fuckery that we shouldn't want to have in our chain.
And therefore, it's pretty reasonable that we should, at some point in the next
15 years, fix that?

**Antoine Poinsot**: Yes, and well, at least, if I were to propose any soft
fork, I wouldn't include it on the ground that it's just nicer.  It also allows
to reduce the expense, well to avoid the expensive BIP30 validations that we
have to do for every single block after block height 1,900,000, which is the
case on testnet.  On testnet, we went back to performing full BIP30 validation;
and on mainnet, we still have the optimizations that there is no coinbase
duplicate visible before block 2 million, basically.  So, we still do not
perform the BIP30 validation.  But in 15 years, we are going to have to go back
to performing full BIP30 validation if we don't make coinbase unique before
then.

**Mark Erhardt**: Yeah, sounds reasonable to instead require locktimes or
something.

**Mike Schmidt**: Shit-fuckery.  Now we're going to get the explicit tag on our
podcast!  Thanks, Murch.

**Mark Erhardt**: Hey, that'll only increase our listeners.

**Mike Schmidt**: It might.  People will just be curious, "Why is the Optech
Recap explicit?"  All right, I didn't see any other questions.  Antoine, thank
you for being our special guest and sticking around.  Murch, thanks always to
co-hosting with me and thank you all for listening.

**Antoine Poinsot**: Thanks for having me.  Goodbye.

**Mark Erhardt**: Hear you next week.

{% include references.md %}
