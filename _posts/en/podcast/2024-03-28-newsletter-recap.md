---
title: 'Bitcoin Optech Newsletter #295 Recap Podcast'
permalink: /en/podcast/2024/03/28/
reference: /en/newsletters/2024/03/27/
name: 2024-03-28-recap
slug: 2024-03-28-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Dave Harding, Peter Todd,
Abubakar Sadiq Ismail, David Gumberg, and Jeffrey Czyz to discuss [Newsletter #295]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-2-28/7d37bc39-b17c-d625-7570-86ad540cb5c6.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #295 Recap on
Twitter Spaces.  Today we're going to talk about a bandwidth-wasting attack, a
discussion about transaction fee sponsorship, feerate estimation using the
mempool, five interesting questions from the Bitcoin Stack Exchange.  We're
going to go through the Bitcoin Core 27.0 Testing Guide, and then we have our
weekly Releases and release candidates as well as Notable code update sections
that we'll get into.  I'm Mike Schmidt.  I'm a contributor at Optech and
Executive Director at Brink, funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch.

**Mike Schmidt**: Hi, Murch.  Dave?

**Dave Harding**: I'm Dave Harding, I'm co-author of the Optech Newsletter and
of the third edition of Mastering Bitcoin.

**Mike Schmidt**: Peter?

**Peter Todd**: Yeah, I'm Peter.

**Mike Schmidt**: Hey, Peter.  Abubakar is not present yet.  David, do you want
to introduce yourself for the audience?

**David Gumberg**: Hi, I'm David Gumberg, I'm a new contributor to Bitcoin Core.

**Mike Schmidt**: Thanks for joining us everyone.  I think Jeff from the LDK
project will be joining us in a bit as well to help us go through some of these
interesting LDK PRs later, so he can introduce himself then.  We're going to go
through the newsletter sequentially here starting with the News section.

_Disclosure of free relay attack_

First news item is Disclosure of free relay attack.  Peter, you posted to the
mailing list an email titled A Free-Relay Attack Exploiting RBF Rule #Six.
Maybe to start, you can get into what is BIP125's rule #6 and in what way can it
be exploited?

**Peter Todd**: Well, I mean there isn't actually a BIP125 rule #6 because we
forgot to go and put it on the BIP, but basically what it is, it says that the
feerates of -- well, when there's a transaction replacement being considered,
the feerates of the replacements can't be less than the transactions that are
being directly replaced.  And this basically, what this does is it prevents
transaction replacements that don't make sense from a miner's point of view
because they're reducing the overall feerates of the mempool.  And the attack I
disclosed is just a variant of well-known attacks, where essentially you find
some kind of transaction that is likely to get mined but is less costly for you,
for some reason, if it does get mined, and then double spend it to some nodes
mempools, but not necessarily others, with a low feerate transaction that is not
that costly to get mined but is quite large, and I should say … I'm sorry, that
is unlikely to get mined because it has low feerates.  And you just
incrementally double spend it with more and more and more large transactions
using up a bunch of bandwidth.  And eventually the transaction that you did want
to get mined, or at least isn't very costly for you to get mined, does get mined
invalidating all of these replacements that used up a bunch of bandwidth.

There are many examples of these types of attacks.  I mean, one example would
be, for instance, timing something correctly with the coinjoin where you wanted
the coin join to go through, but while that transaction happens that's paying a
lot of fees and is likely to go through, you double spend it with a low feerate
transaction where that transaction isn't very interesting, but you can go and
just use a bunch of bandwidth getting these propagated.  So, the specific
variance here is just taking advantage of rule #6 directly but like I say,
there's other examples of this too.

**Mike Schmidt**: Now, I know there was some discussion and back and forth; I
think, Dave, you were you were part of that, maybe not directly on this
particular issue.  But Dave, are there thoughts that you have on this particular
bandwidth-wasting attack in in the way that was described by Peter?  It sounds
like this is a variant of a known attack.

**Dave Harding**: Well, Peter, in his email, he describes a very well-known way
to waste bandwidth, which is for an attacker to send a bunch of large
transactions, get them relayed across the network, then have a miner very
efficiently conflict those transactions, removing them from the mempool.  So,
you could have nodes relay literally gigabytes of data across the entire
network, terabytes even, and then for a rather small amount of block space use,
remove those from the mempools.  And that's another variant of free relay.  I
mean, Peter's absolutely right, there are ways to waste bandwidth.  This is a
new way to waste bandwidth, and that's one of the things we mean when we talk
about free relay, is we're just talking about wasting bandwidth.

**Mike Schmidt**: Now, free relay, I guess in this case, is that there's an
assumption that you're already transacting, and that that transaction, you'd be
happy to go through for some reason.  So because of that, there's no additional
cost to do this effect, but there is an assumption that you're doing one
transaction at least here, right, you eventually would want at least a
transaction to be confirmed; is that right?

**Peter Todd**: Sorry, my internet cut out for a few seconds there, so I might
be repeating something that was already said, but yeah, I mean free is on a
continuum.  Like you said, at one extent it could be arguably completely free.
It could also be very cheap.  There are of course other attacks where you just
broadcast nearly the same transactions with many different nodes at once and
they just waste bandwidth relaying all the different variants back and forth and
not coming to any useful conclusions.  In that case, that would be a cheap relay
attack arguably, but even then, depending on what you were intending to do at
the same time, even that could be what's arguably a free-relay attack, because
you're already needing to do some transaction anyway.  And I think the example I
tried to explain with coinjoin is an example of this kind of thing too.

**Mike Schmidt**: Peter, so what do we do about it?

**Peter Todd**: Well, I mean as I argued in my post, this particular variant, it
happens to be an example where Replace By Feerate (RBFr) improves the situation
there, because this particular variant of this type of class of attack happens
to be an example where the attack works because of economic irrationality.
Since the high feerate transaction is the one that got mined, and the one that
obviously would be likely to get mined no matter what, that was all those always
the one that nodes should have accepted into their mempools.  It does not make
sense to go and waste bandwidth on a low feerate transaction when a high feerate
replace exists, in most circumstances, because reality is a high feerate one is
the one that's going to get mined.  I've checked this on real-world monitoring
of the Bitcoin Network, and sure enough, something like maybe 65%, 70% of high
feerates, but low absolute fee replacements, do eventually get mined.  And if
you go fix this, well, that certain circumstance will happen a little less
often.

It still is probably fundamentally impossible to fully mitigate things like
people just broadcasting different versions of essentially the same
transactions, many different nodes at once.  That's probably an unfixable
problem in how Bitcoin fundamentally works.  But there's limits to how big of a
problem that can be and how much extra bandwidth it can use.  And of course,
that type of attack, it still has some cost, because at some point, you at least
needed to go and do transactions.  If you're just an arbitrary attacker who has
no need to do transactions, you're going to at least incur some cost with all
these things; you're going to have to do some transactions.  And fortunately for
us, the cost of bandwidth, in the sense that you can only use up so much
bandwidth for a given number of UTXOs mines, that cost is very high because
bandwidth normally is relatively cheap and Bitcoin fees are high enough that
these kind of ratios don't get you that much.

So, I'm not too worried about these kinds of things, but I think the better
argument is, it does mean we can go and do things like RBFr, which are very
advantageous for other reasons, because they don't actually change the status
quo.

**Mike Schmidt**: We talked about RBFr in Newsletter #288 and we weren't able to
have Peter on for that Spaces, but Dave walked us through that particular
proposal.  So, if you're curious about what Peters referencing, you can check
that out.  Murch or Dave, any further questions on this topic?  Thumbs up from
Dave, thumbs up from Murch.  Okay, great.  Peter, any calls to action for the
audience before we move on?

**Peter Todd**: I don't know, subscribe to the mailing list and follow the
discussion.

**Mike Schmidt**: Thanks for joining us, Peter.  You're welcome to stay on or if
you have other things to do, you're free to drop.

**Peter Todd**: Thank you.

_Transaction fee sponsorship improvements_

**Mike Schmidt**: Next news item is titled Transaction fee sponsorship
improvements, and this was a Bitcoin mailing list post from Martin Habovštiak,
who posted an email titled Anyone can boost - a more efficient alternative to
anchor outputs.  I reached out to Martin.  He wasn't able to join us today, but
I think we can represent his ideas as best we can.  This is an idea that's
similar to Jeremy Rubin's fee sponsorship idea from early 2020, that we covered
in newsletter #116.  We do have both Peter and Dave who responded to Martin's
post on the mailing list, so I'm glad they're here to comment.  Dave, you were
also contributing to some of the discussion going on on this topic on the
Delving Bitcoin forum as well.  Maybe you can summarize the original fee
sponsorship idea, and then also what's going on with these resurrected
discussions?

**Dave Harding**: Sure.  Jeremy's original fee sponsorship idea is that we can
add a commitment in a transaction.  Jeremy proposes putting it in a special
OP_RETURN-like output.  We can put a commitment in a transaction that commits to
another transaction, and creates a relationship to them that's pretty much
identical to CPFP relationships.  So, you receive an output and you spend it and
we can't include the spend until we include the original output, the transaction
containing the original output that you received.  And we use that for CPFP fee
bumping in Bitcoin Core.  It's the same mechanism used for ephemeral anchors,
which you've heard us talk about a lot in previous newsletters and podcasts.
But what it allows is any transaction to contribute fees towards another
transaction.  So, the sponsor transaction, the one that contains the commitment,
cannot be included into a block unless the boosted transaction, the transaction
it commits to, is also included in the same block.

This would be a very interesting mechanism for adding fees to a transaction.
One of the nice things about it is that you can kind of outsource who's paying
the fees.  You can also eliminate one input from a CPFP transaction because you
don't have to have that reference in a transaction.  So, like in ephemeral
anchors when we want to boost a parent transaction, we have to create a
transaction that has both the anchor spent in it, and also a fee contributing
input.  With sponsors, we can just create a transaction that directly sponsors
the transaction we want to boost.  And so, I think this is a really clever idea.
People were interested it when Jeremy posted about it, but there was concern
back then that ancestor fee relationships in the mempool are not very well
handled, and we really need to improve that part of the code before it could be
carefully considered.  And fee sponsorship hasn't been talked about a lot since
then.  We have a topic page and it looks like we only talked about it five times
in the last few years, and the last time we talked about it was in October 2022.
So, I don't think Martin simply had not heard about this idea, and he seems to
have independently reinvented it.  His idea has a difference.

Since Jeremy posted in 2020, we've activated taproot, and so Martin was able to
propose a version that makes the commitment in the transaction annex, the
witness annex.  That's part of the discounted segwit bytes.  So, for an
identical commitment to what Jeremy proposed, Jeremy proposed adding 32
bytes-ish plus some overhead to a transaction, so we can reduce that by 75% in
Martin's proposal.  It's actually a little bit better than that because Jeremy's
version used an output which has the overhead of an additional 8 plus 1 bytes
for the amount and the script size.  So, Martin's version is a lot smaller, it's
like 85% smaller than Jeremy's version.  It brings the cost of a sponsor down to
8 vbytes.  Jeremy's original proposal allowed multiple sponsors, although Jeremy
wanted the initial mempool policy to keep it simple to only allow sponsoring a
single version, so we would have to upgrade consensus for sponsors.  That would
be a soft fork, and we would initially start with a very restricted policy.  And
then, as we gained experience with it and as our tooling increased over time, we
could allow transactions to sponsor more than one.

That was where it becomes especially beneficial to begin outsourcing the
sponsorships.  So, I could pay Murch over LN and he could add a sponsorship to
my transaction.  Because there doesn't need to be any relationship between the
transactions, except the ones that are explicitly made by the sponsor, anybody
can boost my transaction.  That's how we get the title of Martin's post.  After
Martin's post reignited some discussion about this, I saw it and Jeremy nudged
me into posting on Delving something that he and I had discussed a few months
ago, which was increasing the efficiency of sponsors even more.  And for this,
the simple version, we can just use an implicit commitment.  If you create a
transaction that is clearly a sponsor, then you can just assume the transaction
appearing before it in a block is the transaction that's being boosted.  You can
have your signature commit to the txid of the transaction appearing before it in
the block, and that signature commitment doesn't need to go onchain; it's
something that nodes can derive for themselves and just don't need to be
explicitly in a transaction.

This brings the cost of a single boost from a sponsored transaction down to
zero, there's just no cost at all.  And that's just a huge advantage over almost
everything except for RBF.  RBF can, in most cases -- I see you want to talk but
I'll pause in a moment -- RBF, in the ideal case, it costs you zero also.  So,
this gives you kind of CPFP-like capabilities at the same cost that you would
pay for RBF.  I'll pause for a moment, Mike, so you can talk.

**Mike Schmidt**: Yeah, I was curious in that implicit relationship.  It seems
like the structure within the block, the order within the block is important.
How would that work in terms of relay for that particular idea?

**Dave Harding**: So, I think you would just use package relay the same way you
would use with ephemeral anchors.  So, in ephemeral anchors, the first
transaction may have zero fee, and the ephemeral anchor may also have no output
value.  So by itself, it's not something that we would relay because there's no
fee, there's no reason that we would ever mine it, and one of its outputs is
below dust so it violates one of our existing policies.  But ephemeral anchors,
we allow that, if it's relayed in a package with an additional transaction that
spends that anchor output and contributes the fee through CPFP.  So, we're
already working on upgrades to the P2P protocol to allow relaying packages of
transactions that have a defined order.  And so, we can just reuse that
mechanism for the transaction to be boosted, which is kind of like the parent,
and the sponsor transaction, which is kind of like a child.  Does that answer
your question?

**Mike Schmidt**: Yeah, that makes sense.  I apologize for derailing.  I know
you're on a groove here, so keep going if you can remember where you were.

**Dave Harding**: I can.  So, that mechanism, which is what I proposed to Jeremy
in January or February, that's really simple, again that gives us zero overhead
sponsorship and I think that's really cool.  Jeremy ran with it a bit farther.
Oh, go ahead, Peter.

**Peter Todd**: I just want to be clear.  I mean, when you say zero overhead
sponsorship, what you really mean is zero marginal overhead sponsorship,
assuming that there is a second transaction.  For an average person with a
wallet, they would not get zero overhead sponsorship without a third party who
can go create another transaction for them or already has another transaction
for them.

**Dave Harding**: That is correct, I should have said that.  As Peter explained,
if somebody is already creating a transaction or already has a transaction in
the mempool that they are willing to RBF, there's no additional overhead to make
that a sponsor.  However, if nobody's willing to do that for you, if you don't
already have a transaction in the mempool, a new transaction will need to be
created.  So you have, I think it's less than the cost of ephemeral anchors
there.  It's actually significantly less because again, you're not creating an
additional output and spending an additional output, but it's still a lot more
expensive than the ideal case for RBF, in fact pretty much any case for RBF.

So, running with the idea, Jeremy suggested several ways that we could allow
multiple boosts from a single sponsor using basically this mechanism.  We can't
just use transaction ordering to do that because of the existing requirements in
the mempool for transactions to be in ancestor dependency order, and also
because you can have multiple sponsor transactions that all sponsor the same
boosted transactions; and if it was a required ordering, those orderings would
conflict.  So, what we can do is add a single small item to the witness stack
that miners can use to indicate the order of the transactions in the block for
verifiers; and that when the transaction is being relayed over the network, it
can also be used to express the txids of the transactions to be boosted.

The summary there is that you can have an arbitrary number of boosted
transactions, and the cost there is 0.5 vbytes per boost, so half a virtual byte
per boost.  And in that case, when somebody is already creating a transaction
and is willing to add one or more sponsors to it, we have a very efficient
mechanism for, again, an unlimited number of sponsors in a block.  This has
still encountered concerns about the complexity of doing this in the mempool,
and there's been discussion about it.  I believe Suhas Daftuar is just very
concerned about creating additional dependencies in the mempool, and I can
understand that.  This is the same type of dependency that we have with CPFP and
ancestor feerate selection in mining, and that's the source of a lot of
complexity.  So, I can understand him not wanting to add more complexity.  But I
would hope that we can solve that problem at some point.  I think that's it.  Do
you guys have any questions?  Oh, I see Murch.

**Mark Erhardt**: Yeah, I wanted to jump in there a little bit.  So, I think
that I could see a case for sponsoring a single transaction.  And again, I would
agree with Peter.  You only have a marginal cost of zero if you already were
creating a transaction, which I don't think is necessarily a given.  And I'm
very concerned about the proposal to be able to sponsor multiple transactions
with a single sponsor because, for example, if you require that the transactions
that are being sponsored are all in the same block as the sponsor, how the
proposal originally starts, then just actually bumping one of the transactions
into a previous block makes the sponsor invalid and removes all of the
sponsorship for all the other transactions.  Or, if you can only have a single
sponsor for the transaction, the question is, how do the replacement mechanisms
work?

It all reminds me very much of all the issues we already have with CPFP and
packages, just in a different flavor.  I'm not that excited about this proposal
because I think that a lot of the things that we're trying to do with CPFP, or
package relay TRUC transactions, address exactly the same issue.  And if we do
not discount the cost of the additional transaction, it's only a cost reduction
of about a third or so in the worst case.  And yeah, it's a lot of new ideas and
changes for little cost savings.  I'm not sure it's as clear of an improvement.
Yes, Peter?

**Peter Todd**: I want to point out that this type of mechanism also enables
entirely new smart contracting mechanisms.  Ark, I think, is your best example
here, where it has this idea of connectors, and we might find that this type of
mechanism gets reused for something completely unrelated to fee sponsorship in
some kind of Ark connectors fashion.  Whether that's good or bad, I mean there's
a lot of complexity there, but I don't believe it was mentioned before and I
want to point that out, although I certainly do agree with you that there's a
lot of complexity these kinds of things add, because of the desire to make sure
that sponsorship only happens within the same block, rather than adding a sort
of generic UTXO-like mechanism, minus the fact that it's spendable.

**Mark Erhardt**: Yeah, Dave, go ahead.

**Dave Harding**: I mean, those are both excellent points.  I'm not that
concerned about reward safety.  I think that's something we have to discuss, and
I'm going to work on a separate post and a separate topic to Delving sometime in
the next few weeks about that, because I want to collect some data for the
network about how we're actually using transactions.  I think it excites me, the
idea of outsourcing this, which means that there's always going to be somebody
making transactions, there will always be somebody available to add a
sponsorship.  Now there is a problem here, it's discussed on the mailing list
and on the Delving post which is, there's no trustless way to outsource this, so
you can't pay over LN in a completely trust-free way for somebody else to
sponsor your transaction.

But I think thinking forward in time, we have second-layer protocols like LN
that people might want to use with an exogenous fees mechanism, like CPFP,
including a specific variance like ephemeral anchors, and that implies every
single user has to keep extra UTXOs around.  And as block space becomes a higher
premium and UTXOs, there's just not enough to go around, I think we have to look
at mechanisms where people want to use Bitcoin in a trust-minimized fashion, but
they don't want to keep around an excess number of UTXOs.  They want to be part
of, for example, a giant channel factory or some sort of covenant, like a
joinpool kind of thing, and they don't want to keep around a separate UTXO to
use for fee bumping these cases.  And a mechanism that is very easy to outsource
and very cheap to make that commitment, this enables that kind of behavior.  So,
I think just thinking forward, we're probably going to go to a direction where
people won't have UTXOs for fee bumping.  And in that case, we have to switch to
either endogenous fee mechanisms, like RBF, or some sort of outsourceable
exogenous fee mechanism, like fee sponsorship.  So, I think this might be a
problem we're going to run into anyway.  Anyway, go ahead, Murch.

**Mark Erhardt**: Yeah, I kind of wanted to address another post in that thread,
and that was that we're trying to save bytes here, but really what we're trying
to achieve is to make it easier to outsource the bumping of third-party
transactions, or rather to bump it to third parties to sponsor our transaction.
But we could do the same thing already with an ephemeral anchor that is
ANYONECANPAY.  And if we count the transaction that has to be created, or just
an input that has to be added to a transaction that is already to be created,
the byte savings would be 50 bytes.  Now, I kind of want to reject that we
currently have a huge block space crunch, because we saw last year how BRC-20
tokens at times took 50% of blocks and were not priced out.  So, I think
currently we're at least not yet where we're really -- and also, just the
adoption of taproot, for example, as a way more block-space-efficient output
type is not that fast, so clearly people are not desperate to save a few bytes.

So, if this mechanism at all were interesting, why is nobody opening up their
transactions to be sponsored by anyone by attaching ANYONECANSPEND outputs as
hooks for anchors for bumping?  I just don't really see people wanting that.  I
think Peter made this argument about his timestamping service at some point.
Yes, it's great if you make progress in some manner, but you, as an issue of
something, of some transaction, want to maintain some control over what is the
most attractive transaction to be included, so that not only you make progress,
but you sort of maintain agency on which progress you make.  And if anyone can
attach to any transaction, sure, maybe someone else pays for it and you still
make progress, but you have extra work with consolidating your processes.  So,
I'm just not super-convinced that we want everybody to be able to sponsor every
transaction.  I'm skeptical about the ability to sponsor multiple other
transactions in a single transaction, and I'm not sure if we overall even see
demand for the use case.

**Peter Todd**: I also wanted to point out where you mentioned that you can
always go and create ephemeral outputs.  With a little bit more improvements to
package relay, and so on, you can always go and have a protocol where you sign a
variance of the transaction you have with the ephemeral output, and if needed,
you just use RBF to get that transaction in...

**Mark Erhardt**: Sorry, I can't understand you.

**Peter Todd**: I was not able to get the quietest place.  But, basically, you
can always have a transaction with an ephemeral output as a backup, right,
because you'd always sign two versions of the same transaction, one with such an
output and one without.  So, if protocols have this need, well they can
obviously just do this as a backup.  And in the future, once we have package
replacements, this will be quite a reasonable way to go and get a transaction
bumped.  And in general, I agree with you, let's see how that plays out first,
rather than going immediately to consensus changes.

**Dave Harding**: I'll just say I'm also on, let's see how ephemeral anchors
plays out before we go to consensus changes, I do explicitly say that in the
thread.  I think this is a very interesting idea.  I'm a lot more excited about
it than Murch is, but I do agree that this is something for down the road, not
something that we should do next week.  I point out in the thread that I think
it really wants a new witness version, and I think it should be something
everybody has access to.  It should be like a taproot thing where anybody can do
it.  I realize there's some conflict with that perhaps, but so I think it's
something for whatever the next big protocol change is, something we can bundle
into there, rather than something that we're going to activate separately, like
a lot of covenant proposals and new opcode stuff.  It's something we might just
add a small thing to script.  This is a big thing that should be bundled with
other big things.

**Mike Schmidt**: It's an interesting set of technical topics that we covered,
but also kind of pulled on some threads of philosophical topics as well.  So,
I'm glad you all were here to riff off each other for that.  And, Dave, thank
you for representing Martin's post and some of the ideas you and Jeremy had on
transaction fee sponsorship improvements.  I think we can move on.

_Mempool-based feerate estimation_

Next news item titled Mempool-based fee estimation.  Abubakar, we recently also
had you on the show to talk about cluster fee estimation in Newsletter and
Podcast #283, and we also had you on in Newsletter and Podcast #276 to talk
about a PR Review Club around fee estimator updates, so you've done quite a bit
of work around fee estimation.  And this week you posted to Delving Bitcoin the
thread titled Mempool-based Fee Estimation on Bitcoin Core.  How would you
summarize your latest work here?  And maybe before you do that, you can
introduce yourself briefly for folks, since you missed the intro in the
beginning.

**Abubakar Ismail**: Thank you, Mike.  I'm Abubakar Sadiq Ismail, a Bitcoin Core
contributor being supported by the Btrust Builders.  Yeah, I've been working on
fee estimation on Bitcoin Core for quite some time, and it just happens that the
first issue that I worked on was on fee estimation.  Yeah, so last week, I made
a post about mempool-based fee estimation.  It's an issue that I've been working
with Will Clark to introduce a fee estimator that looks at the mempool
transaction data for making the estimate, because we have analyzed the fee
estimate that is being given by the current fee estimator we have on Bitcoin
Core, which is a similar policy estimator, and sometimes it overestimates and
underestimates.  And I made an analysis and discovered that there are quite some
times that transaction I've been stuck in the mempool because they use estimates
mostly.

So, we decided that we are going to run the block building algorithm on the
mempool and check the 50th percentile of the block template as the fee estimate
for the next block.  And when you create a transaction using that, there is
highlighting that if it were to be propagated into the network and miners are
going to pick it, there are some issues with the mempool-fee estimation, which
is what is in your mempool might not be the same with what miners have.  So,
there are some ideas because this is a main issue.  So, contributors have been
discussing about how to fix the CBlockPolicyEstimator that we have, and some
sanity checks are being proposed, which is to look at the previous blocks that
were mined to see if they are the same or, I would say, roughly the same with
what you expect.  So, you are going to check if maybe the past three blocks are
roughly in sync with your mempool, and also your high minings for transaction
are performing.  Then, it is likely that your mempool is roughly in sync with
miners and when you make an estimate with mempool, your mempool transaction is
going to be the same.

So, we implement the fee estimator and then we run some analysis.  We have up to
19,000 estimates to see how it compares with CBlockPolicyEstimator and the
expected block median feed rate.  And mostly, it's been much more closer to the
expected block target median feerate than CBlockPolicyEstimator, and that's the
progress so far.  And I have received feedback from David about an attack
vector, which is miners being able to manipulate the nodes mainly by having two
variants of transaction, but parsing the first one with high feerate and mining
the second variant, and then they can be able to basically manipulate what users
have.  And also David hints at research by Kalle Alm on mempool-based fee
estimation previously, which uses the mempool data to lower
CBlockPolicyEstimator estimates, and that is an improvement to the current
status quo and it's reduced the other estimations that we are having on
CBlockPolicyEstimator a lot.  But there is still an issue of under-estimation,
which you can RBF bump.

But the issue is that even if you decide to RBF bump and you call
estimatesmartfee, it is still going to give you low fee estimate.  So, I think
the solution that users currently do is to look at some service, like
mempool.space, to see the state of the mempool, and then RBF bump using a fee
estimate that mempool.space is giving you.  But that is even more risky, because
there is trust there and it's better to look at your node's mempool than to look
at mempool.space.

**Mike Schmidt**: Dave, I saw you chiming in in the thread.  Abubakar has
invoked a couple of your comments here about a particular attack in some
previous research from Kalle on the subject.  How would you augment or comment
on what Abubakar has outlined so far?

**Dave Harding**: I think this is great work.  I think we actually posted in a
previous newsletter that BTCPay moved away from Bitcoin Core's fee estimation
because they thought it was overpaying.  And it does have an issue where it's
just a trailing statistic, it's a very heavily trailing statistic, whereas a
full node would seem to have in its mempool a really good view of the current
network.  In an ideal world, every mempool and every node is basically the same,
including minor nodes.  That's an ideal world, not the real world, but if that
were true, full nodes would know exactly what miners are going to put into their
next block, assuming those miners are trying to maximize their revenue.  So,
this is really good work, and like Abubakar said, I really liked an idea of
Kalle's from back in the day, for at least starting on this project, which was
just use current information in the mempool to set a lower fee, but don't use it
to raise your fees, because if there's any attack out there, any motivated
attack, it's going to be for miners to try to raise their fees.  So, you can
just ignore a whole class of problems, a whole class of profit-motivated attacks
by using your mempool data to lower your fees, but not using it to raise your
fees.

I do think it's really great to see him research ways to also use mempool data
to raise your fees.  Like he said, underpaying is also a problem, especially if
you continue to underpay.  I don't think it's always a problem.  Anybody who can
RBF multiple times, which isn't everybody for sure, but anybody who can RBF
multiple times can just keep incrementing their feerate until their transaction
gets confirmed.  And they can do those increments relatively quickly and
relatively cheap.  The minimum increment is 1 satoshi per vbyte (1 sat/vB) and
there is no significant time delay between that; you can increment your
transaction 100 sats/vB in a single block very easily.  So, again, for people
who can use RBF, I think they would benefit from a kind of quick change to the
fee estimator, a new optional mode to the fee estimator, that use mempool data
to drop the feerate to what's being observed in the mempool right now if it's
lower than what the long-term block-based fee estimator is returning in Bitcoin
Core.  And then in the long-term, continued research on trying to find a way to
extract useful information for fees from the mempool and use that to choose an
appropriate feerate, especially for people who can't RBF.

**Abubakar Ismail**: Yeah, I just have a quick question.  So, when you're
talking RBF fee bumping, is it an automatic fee bump for you manually increment,
like 5 sat/vB continuously until your transaction will get confirmed; but even
if you like make a fee estimate again, it's still going to be that low fee
estimate because there is a threshold?

**Dave Harding**: Well, one of the requirements of RBF is that each time you fee
bump your transaction, it has to go up in feerate.  The reason for that is
simple, is that miners are not going to allow you to send them a new version of
a transaction that pays a lower feerate, or also lower absolute fees, unless
you're using Peter's, RBFr.  But it has to go up in feerate, miners are just not
going to accept anything.  So, if you just keep working at RBF, even if you have
no knowledge of what's in the mempool, even if you have no fee estimator, if
that's all just dead, you can start your lightweight client at 1 sat/vB, send
your transaction, wait a block.  If it's not confirmed, send it again at 2
sat/vB and just keep incrementing until your transaction eventually gets
confirmed.  So, again, if you can RBF, there's not a problem, not a necessary
problem with your fee estimator underestimating.  You will eventually, through
RBF alone, get to a feerate that's high enough to get the transaction confirmed
in the block.  That's not an ideal situation for a lot of people.  They want
accurate feerates because they want the transaction to confirm relatively soon.
They don't want to iterate through every possible feerate.  And it's also better
for the network to have accurate feerates so that people aren't using more RBFs
than necessary, which uses a lot of bandwidth on the network.

So, again, I absolutely agree, we need accurate feerates.  But I do think
there's no actual problem with underestimating feerates for people who can use
RBF in a non-time-sensitive manner.

**Mike Schmidt**: Murch, I wanted to give you an opportunity to ask any
questions or comments as well here.

**Mark Erhardt**: Yeah, I also find the idea of just lowering and making it
opt-in as a new experimental mode for how feerates are estimated by Bitcoin Core
maybe a very easy first step on how we could deploy something.  I agree with
Dave that the natural way of being thrifty with your fees is to risk
underestimating and bumping appropriately over time.  And in a way, the problem
is just inherent to bitcoin transactions because we don't know what the next
block interval will be.  There's always the estimated time of finding the next
block, it's always ten minutes, whether it's been ten minutes already, whether
it's been ten seconds, or whether it's been fifty minutes already.  So, we have
a first bidder auction, we estimate at the start where we submit our
transaction, and at least once per day we get a one-hour block where you will
just underestimate if you want to be in one of the next few blocks.  Every once
in a while, we get a series of five blocks in a minute, and you totally overpay
if you assume that you'll have to wait about 40 minutes for the next four
blocks.

So, there's just a lot of things that we don't know when we estimate the
feerate, so being more thrifty and being able to adjust later is, at least for
an active user that can work on their transaction, pretty safe.  And that way we
could at least recoup some of these fee savings quickly by lowering the initial
estimates.

**Mike Schmidt**: Abubakar, as we wrap up this news item, I want to give you an
opportunity to say anything else as we wrap up, but also give you an opportunity
to give a call to action to the audience if there's something that you think
would be valuable for them to look at or play with based on your research.  I
know it looks like you have a branch with some of this implemented as well as a
Google sheet with some data that people can play around with.  What would be
useful for you to get feedback on, on your research here?

**Abubakar Ismail**: Yes, so I have a branch with a working RPC, so you can
build a branch on mainnet and on the RPC and see how it works.  But I would like
feedback on the thread, just as we are discussing with David, on the way
forward.  And I think with this stage that it is currently is to have the
mempool-based fee estimator with the CBlockPolicyEstimateor threshold.  And
then, if you want to RBF bump later, if you estimate the fee and it's low
feerate, it's been stuck, then maybe you can

get the mempool states manually and then decide on that.  So, we are looking at
displaying the first quartile of the next block templates, 50th quartile and the
4th quartile, and also we are looking at seeing maybe we can incorporate the
inflow of mempool transactions in our decisions, we decide on which metric to
use.  Yeah, so it's still a work in progress and all feedbacks are welcome.

**Mike Schmidt**: Thanks for joining us, Abubakar.  You're welcome to stay on,
or we understand if you need to drop and do other things.

**Abubakar Ismail**: Thank you for having me.

**Mike Schmidt**: Next segment from the newsletter is our monthly selected
questions and answers from the Bitcoin Stack Exchange.  We have five of those
this month that we've highlighted.

_What are the risks of running a pre-SegWit node (0.12.1)?_

The first one is, "What are the risks of running a pre-segwit node?"  And the
example version here would be 0.12.1.  I believe I've seen some chatter on
Twitter about this particular version, and I guess the idea is folks who are
upset with inscriptions and BRC-20s and things like that are trying to feel
productive in taking a stance against that by potentially running a pre-segwit
node.  I think that may be part of the motivation behind this question or why
it's come up recently.  A few different people contributed answers to why there
might be risks associated with doing such a thing.  Murch, you are one such
person that provided some of the answers there.  We list a lot of the potential
downsides for an individual node operator, and then we also noted the potential
effects on the Bitcoin Network if a substantial percentage of the network
adopted such a version.  Murch, what do you think?  This is a bad idea, right?

**Mark Erhardt**: Well, yeah, thanks for taking my conclusion already.  I mean,
people that listen to this show know that I have not a ton of love for BRC-20
tokens or inscriptions.  I generally just don't find them very interesting.  But
I think it makes sense to look at the issue at hand and the solution just
analytically, and what exactly are we trying to achieve by running outdated
software?  If I'm running a pre-segwit node, currently 95% of all transactions
are segwit transactions, so your node will consider them non-standard, simply
not load them into the mempool, will not forward them, will not have seen them
when the block comes through.  Basically, they're no longer participating in
transaction relay.  Well, if the bandwidth savings that you have by doing that
are the goal, then just run -blocksonly mode.  It'll be 100% transactions that
you don't forward, you'll only see the blocks, you get all of the bandwidth
savings, but you're not running a version that's been released eight years ago
and has been end-of-life for seven years.

So, whatever security issues have been fixed since then that may have been
present in the codebase already, and the operating systems they're running in
that may have changed underneath of the software and have introduced new
compatibility issues, all of that you get by running eight-year-old software.
And I just don't see how the goals of -- or, maybe it would be easier to assess
what they're trying to do if they actually stated what exactly their goal is.
But the perceived goal of not forwarding inscription transactions throws out the
baby with the bathwater here, and in that, it also throws out all of the other
transactions that are on the network, so it just doesn't make any sense to me.

All of the downsides basically affect the node operator.  They will be peered
with less preferentially because they are never the ones that first forward
blocks, because when the block comes in, they first have to get all the
transactions.  So, they'll have more round trips, more data spikes at the times
when blocks are found.  I believe that most other nodes that still follow the
current version, they would just preferentially peer with each other, because we
protect the nodes that first give us a block, I think, for the last four blocks
or so; they're among the nodes that we will not disconnect.  And so, what will
happen is that the network basically segregates itself.  People that actually
broadcast transactions and get everything before the block comes through and can
participate in compact block relay, they will be the first ones to relay to each
other.  They will form some sort of backbone in the network, they will be not
really affected, especially miners are super well connected with each other.

One of the arguments from this group of people has been that it will slow down
blocks by people, or by miners that include inscriptions.  Yeah, it will slow
down your receiving of those blocks, but it doesn't really hurt anyone else that
is actually running up-to-date software.  So, I just am overall confused by what
people think this is supposed to do and whether they thought about how it
affects them.  And yeah, I just don't think that it's useful in any way.

_When is OP_RETURN cheaper than OP_FALSE OP_IF?_

**Mike Schmidt**: Next question from the Stack Exchange, speaking of embedding
data, "When is OP_RETURN cheaper than OP_FALSE OP_IF?"  And this was answered by
Vojtěch, who detailed some charts showing if you're going to embed data using
OP_RETURN versus OP_FALSE OP_IF, which is the way that inscriptions uses their
data envelope, this IF FALSE, and then embedding a bunch of data, so when is it
cheaper to do the inscription embedding versus OP_RETURN?  And his conclusion
was OP_RETURN is cheaper for data smaller than 143 bytes.

_Why does BIP-340 use secp256k1?_

Next question from the Stack Exchange, "Why does BIP340 use secp256k1?"  And a
great person to answer this is Pieter Wuille, who did, and he explained the
rationale of choosing secp256k1 versus the alternative which was inferred in the
post, which is this Ed25519 curve.  I think the person asking this question
implied that there was a more mature ecosystem around the non-ECDSA scheme.  I
think what Pieter addressed is that I guess that assumption is false, that a lot
of what's been built recently, that looks like it's part of that alternate
system, has actually been built over the last few years.  And then sipa also
notes some of the schemes predating BIP340, MuSig1, MuSig2, FROST, and also some
standardization efforts around BIP340.  And I guess the conclusion that sipa
gave for the choice is two reasons.  One, the reusability of existing key
derivation infrastructure within Bitcoin, and he notes including BIP32; as well
as not changing any of the security assumptions since Bitcoin

is already relying on similar security assumptions.  Murch or Dave, anything to
add or augment on that?  Great.

_What criteria does Bitcoin Core use to create block templates?_

Next question from Stack Exchange, "What criteria does Bitcoin Core use to
create block templates?"  Murch, you actually answered this question, so perhaps
you'd like to provide a summary of the answer, and then also perhaps, Abubakar,
I think you're still around, you might have something to say given some of your
work around fee estimation as well, if that's impactful here.  Murch?

**Mark Erhardt**: Yeah, sure.  So, we currently use an ancestor-set-based
approach.  So, when we look at transactions and their priority to get picked
into the block, we consider them in the context of all the transactions that
have to topologically go ahead of them in order for the transaction to be valid.
So, if you have a child transaction, the parent has to be in the block before
you, otherwise you're not valid to be included, right?  So, obviously, when you
look at a tree of transactions, transactions that are further down in the tree
will have overlapping ancestries with transactions that are higher up in the
tree.  So, the implementation in Bitcoin Core, what it does is it calculates the
ancestor set for every single transaction, then looks at the total size and the
total fee of this group of transactions and calculates an ancestor set feerate.
And at that feerate, we queue the transaction.

But that is probably not the final feerate that we use to evaluate the
transaction to go into the block, because when there is some transactions
further up in the tree that have a higher ancestor set feerate, they get picked
into the block first, and then the feerate of the remaining transactions in that
tree gets recalculated, because now the ancestry is pruned and there's less fees
left for, in average, more size.  Otherwise, that transaction would have been
picked with all of its ancestors before.  So, we basically re-evaluate the same
ancestor sets multiple times in bigger clusters, and that is a little
inefficient.  But yeah, so we look at transactions in the context of the
ancestor cell.

Also maybe noteworthy is that this is a greedy approach.  So, this is not a
perfect solution that gives you the optimal fees for the block, but rather it's
just a fast and quick best effort which is, take the transactions from the
highest feerate first, and then especially at the tail end of the block, where
we might have transactions that are bigger than the remainder of what's left for
the block template, we get a bit of a bin packing problem where we have to find
the best things that fit into the end for the optimal solution, which we do not
do.  We just exclude anything that doesn't fit in our greedy template so far and
then look at smaller transactions that might fill the hole.  So, what I'm trying
to say is we do not actually find the optimal blocks, we find just pretty decent
blocks.  It's maybe something like 0.7% that I've seen.  Clara and I wrote a
little paper, or not paper, but article on block templates a couple of years ago
about this, and we found, looking at historic data, that finding the optimal
block is just less than a percent of an improvement for the most part.

So, yeah, in this context of course cluster mempool is interesting, where we
would have more information about where we would put transactions into the
block, because we essentially create a total order of everything in the mempool.
We know exactly in what order we would pick everything into blocks.  So, we will
build slightly better blocks, still not optimal blocks.  And maybe also
interesting in this context is, the bin packing problem gets a lot harder when
transactions are bigger.  So, for the most part, the greedy approach works
decently because our transactions are so much smaller than the block size.  So
for example, today on Twitter, I saw some people discussing whether we should
raise the limits on standardness so we could have bigger transactions, and this
would make it harder to build a good block with a greedy approach, and basically
require us to do a lot more computation to find an optimal block, which would
favor bigger miners that can afford more computation more quickly.  And so,
yeah, maybe that's more than an overview.

**Mike Schmidt**: Amazing, thanks, Murch.  Dave or Abubakar, any questions or
anything to add on Murch's great elaboration?

**Abubakar Ismail**: Yeah, that was great.  So, I think we use the block
building algorithm to get the top block template, and we really notice that it
can be inefficient because of its algorithm currently.  So, what we do is we
cache the fee estimate that you get, so if you want, you can just get the cache
data.  So, I think we cash it after one minute, then we update.  So, when you
make an update and the cache is above one minute, then you get a fresh estimate.
But if you want, this is opt-in, you can get a latest estimate.  And also for us
to ensure that the mempool is roughly in sync with miners, immediately a new
block is confirmed, we have to build a block template and compare it with the
new block before we make the decision.  And if this were to be deployed and
everybody is using it, then that will slow propagation in the network a bit,
because after a new block has been mined, then everybody has to calculate block
template.

But I think with cluster mempool, it's going to be much more easier because we
have total ordering of the mempool and we just take the top block.

_How does the initialblockdownload field in the getblockchaininfo RPC work?_

**Mike Schmidt**: Thanks, Murch and Abubakar for elaborating there.  We have one
more question from the Stack Exchange, "How does the initialblockdownload field
in the getblockchaininfo RPC work?" which is seemingly the most uninteresting
question that could ever be surfaced on the newsletter.  But I always find when
sipa answers something, it just always seems much more interesting to me.  He
gives some insights that at least I wasn't aware of.  So, in the case of this
particular question, sipa answers that initialblockdownload, when you start your
node, is always true and then only goes to false when both of the following
conditions are true.  One is the current active chain has at least as much
cumulative proof of work as the hard-coded constant in the Bitcoin Core
software, which is updated each major release; that's the first condition that
needs to be true.  And then the second one is that the timestamp of the
currently active chain tip is no more than 24 hours in the past.

So, I thought that was interesting insight, if a bit in the weeds with a
particular RPC.  Murch, I know you had some comments on this with sipa.  I don't
know if you thought this was interesting, or you wanted to surface that
discussion at all?

**Mark Erhardt**: Yeah, I did think it was interesting.  So, I don't really want
to get into the comments that we had underneath that post, but I wanted to
provide a little context, because maybe people aren't aware what the context of
initialblockdownload is.  So, when the field initialblockdownload is true, our
node behaves differently for syncing purposes.  So, while we're in the
initialblockdownload mode, we first sync only the header chain up to the best
chain tip that our peers are providing to us, and then we sync only from a
single peer, I think with a fallback to a second peer if there's some delays.
And only once we've caught up to the last day or so of blocks that we're
missing, we resume our normal peering behavior where we invite all of our peers
to give us blocks and transactions.  During the initialblockdownload, we also do
not do transaction propagation, for example, right?

So, basically what we're looking at here is, if you don't start your node more
often than once per day or if you're currently in the initial sync, your node
behaves differently than when you're caught up to the chain tip.

**Mike Schmidt**: That wraps up our Stack Exchange questions for the month.
Next section, Releases and release candidates.

_Bitcoin Core 26.1rc2_

Bitcoin Core 26.1rc2.  We covered this in last week's discussion, so there's not
much that we got into there, but Murch, Dave, or David, do you have anything
that you'd like to note on this release candidate before we move on to 27.0?
Great, all right.

_Bitcoin Core 27.0rc1_

Bitcoin Core 27.0rc1.  David, you posted an initial Testing Guide for this
release last week.  Maybe you want to introduce yourself since I think you
missed the beginning.  Oh no, you did the intro.  But maybe you can give us some
background on how you came to author the guide, and then we can get into some of
the notable features to test.

**David Gumberg**: Yeah, so thank you very much for having me.  I co-authored
the guide with three other people, Chris Bergqvist, Marco, and Tom, and we
worked on this testing guide as a part of the Chaincode Labs onboarding to FOSS
program, which has been a really amazing program.  And we're really grateful to
all the people at Chaincode and all the contributors that have given so much of
their time to help new people find their bearings in this space.  So, that's
kind of the background of how all four of us came to work on this.

**Mike Schmidt**: Great.  Do you want to get into maybe some of the notable
features that you surface during this Testing Guide writeup?

**David Gumberg**: Sure, so I'll go through it in the same order as they appear
in the guide, and feel free to stop me.  The first issue we cover in the guide
is a change in the way that we store the mempool on disk.  So, previously the
mempool was stored in plain text and as we discussed earlier, people can encode
arbitrary sequences of data into bitcoin transactions, so this poses a problem.
Malicious people could encode data that would be detected by antivirus software
potentially.  So now, we obfuscate our mempool on disk the same way that we
already do with the chain state.  So, that's the first change, is that we are
now XORing the mempool.

The second, and a big one, is that v2 transport is going to be on by default in
v27.  So previously, in v26, v2 transport, that was described in BIP324 was
available, but it was behind a command line flag, and all of the RPCs that used
it, you had to enable it with a flag.  Now, in v27, it's enabled by default, so
all connections will automatically first try to be made over v2, and all of our
networking P2P RPCs will also attempt to connect over v2 first.  There's also
some early support for the v3 transaction policy behind a command line flag, and
in testnets Bitcoin Core now has some support for v3 transaction policy, and we
also covered this in the Testing Guide.

The other addition is a new coin selection algorithm, CoinGrinder, made by
Murch, and today this algorithm is only used in an extremely high-fee
environment, and it optimizes for using the smallest possible input set.  Go
ahead.

**Mark Erhardt**: No, sorry, I just wanted to note, it's above 30 sat/vB, which
I think currently is higher than what we're seeing in the mempool.  It went down
to 8 sat/vB recently, but it's not that extremely high.  The reason why we are
not running it at every feerate is, if you always pick the minimal input set by
weight, the problem that you get is that you grind your UTXO pool down, because
you will create very small change outputs and you will not consolidate ever.  So
the idea was, when do we really want to minimize the input rate?  Well, when the
feerates are somewhat high.  So, that's why it's only run at 30 sats-plus.
Please continue.

**David Gumberg**: Yeah, that makes sense, thank you.  And also, in the PR, it's
noted that that may be extended to other use cases in the future.  The other
change that we cover is a -netinfo compatibility.  So previously, if you had an
older version of bitcoind and you tried to talk to it with a bitcoin-cli client
that was v26 or higher, it would crash.  So, this release fixes a bug and that's
covered in the Testing Guide.  And lastly, while there aren't any major user
changing phases to the migratewallet RPC, as of v27, it's no longer
experimental.  The migratewallet RPC is important because as early as v29, we
might deprecate the legacy wallet or remove support for the legacy wallet
completely, except for the ability to migrate to the newer descriptor SQLite
wallets.  So, we also covered that in the Testing Guide.  And there are other
notable changes that we couldn't necessarily find a way to include in the
Testing Guide, but those are the ones that we thought would be helpful to test.

**Mike Schmidt**: David, thank you for putting that together.  I know there was
a PR Review Club on the guide.  Did you attend that; and if so, how do you think
it went?

**David Gumberg**: Yeah, I attended that.  It was hosted by Chris Bergqvist, one
of the co-authors of the Testing Guide.  It went really well, we had a lot of
people show up and a lot of people try out the guide.  It was very exciting.

**Mike Schmidt**: One thing I like about these guides is it's highly accessible
for people to play around with.  But on the flip side then, if you only strictly
follow the guide, maybe you're not fully exploring all the different things that
could potentially be tested.  Dave Harding, I believe you were on our show for
the 26.0 Testing Guide, and you had a particular emphasis in that discussion
that I see alluded to in the newsletter writeup this week, which is the phrasing
of "suggested testing topics".  Maybe you can comment on testers going beyond
the Testing Guide itself?

**Dave Harding**: I think my comment last time was that, go through the Testing
Guide, but also have fun just exploring stuff.  Run all the commands that you
typically run when using Bitcoin Core.  You're looking for things that
developers didn't expect, because if they expected it, it would be fixed, it
would be working correctly.  So, just have some fun, run some commands that you
normally wouldn't run, learn about them.  But I think testing should be part
fun, so just have some fun while you're testing.

**Mike Schmidt**: David, I assume your call to action for the audience would be
going through the Testing Guide and running it on whatever environment folks
have set up, and then also provide feedback on the guide.  I know there's #29685
which is for feedback to the guide.  Anything else you leave for listeners,
David?

**David Gumberg**: Yeah, just to kind of echo what Dave said, I think the
Testing Guide is a really, really amazing way for new contributors that are
looking for a way to learn more about Bitcoin Core, or looking for ways to
contribute value to the project, to explore and, like Dave said, have fun.  The
Testing Guide is really kind of just a recipe book for people to get started on
just having some ideas and things to explore, yeah.

**Mike Schmidt**: David, thanks for hanging on for us to go through this item,
we appreciate your time.  You're welcome to stay on as we go through the Notable
code changes.  But if you need a drop, we understand.  Thanks.

**David Gumberg**: Thank you very much.

**Mike Schmidt**: Notable code and documentation changes.  I'll take the
opportunity to solicit any questions from the audience.  Please feel free to
request speaker access or comment on the Twitter thread, and we'll try to get to
that at the end of the show.

_Bitcoin Core #28950_

First PR, Bitcoin Core #28950, updating the submitpackage RPC with arguments for
maxfeerate and maxburnamount.  Murch, I had seen that you were a reviewer on
this particular PR, and I thought maybe you would be suited to explain it to the
audience.

**Mark Erhardt**: Yeah, sure.  So, when you submit a package, you generally
have, especially in the context of TRUC transactions where we will only have two
transactions in the cluster, you generally have some child that is bumping the
parent, and that's the point why you're trying to submit it as a package in the
first place.  So, what this PR does is it adds two arguments to the
submitpackage RPC, and it allows the user to limit the maximum feerate and the
maximum burn amount in the package.  So if you, for example, aren't quite sure
what feerate you're submitting or you want to have some sanity checks there that
you don't accidentally overspend, you could have a custom maxfeerate set in your
integration where you receive packages and then once they're submitted, you run
this argument as a bound on how much you're going to pay.

The maxburnamount is in the context of, for example, OP_RETURN outputs or
generally unspendable outputs.  This is usually set to zero, but if you were,
for example, trying to assign a value to an OP_RETURN output, you could increase
it in order to allow your RPC to accept that transaction.

_LND #8418_

**Mike Schmidt**: Thanks, Murch.  Next PR this week is LND #8418, makes a change
to LND when LND was computing the minimum fee for a transaction.  LND will now
look at its Bitcoin peers' feefilter values in making a determination on LND's
feerates.  The feefilter values come from the P2P feefilter message, defined in
BIP133, that tells peers not to send transactions with fees below a certain
feerate.  And so, LND is now using a moving median calculation that is based on
all of its outbound peers' feefilter rates to help inform its feerate selection.
Murch, or Dave, anything to add there?

**Dave Harding**: Oh, go ahead, Murch.

**Mark Erhardt**: No, you go ahead.

**Dave Harding**: I think this is an interesting approach.  It's a little scary
to me.  Even your outbound peers, there's just no guarantees of service there.
This is only being used for a minimum fee.  Maybe it's okay.  I guess it's just
that it makes me feel a little bit uncomfortable.  But hopefully they've thought
through this more than I have in just writing up this quick summary of what they
do.  The concern I have here is that your node randomly picks peers.  So, when
it first connects to the network, it downloads a list of peers from a trusted
source, trusted in the technical sense, not necessarily that you trusted.  And
then it will connect to some of those peers, and then it will ask them for the
addresses of other peers, and it will build kind of an address book of peers in
the network.  And then when it starts up a new time, it will connect to some of
those peers that it randomly selects.

We've had attacks in the past where people have been able to pollute this
address book with bad peers.  I don't know that it's ever been exploited, but
it's been possible in the past.  So, it's just something that I think you want
to be careful about, is that these are just random people on the internet.
Would you go and just ask a bunch of random people on the street, how much you
should pay in transaction fees and trust that?  Especially, there might be an
incentive for, I guess this is a terrible analogy, but there might be an
incentive for somebody to replace them with fake people who always tell you to
pay a really lot in fees.  So, this is an approach.  I would urge anybody
thinking about replicating this to go look at what LND did and take a critical
look at it.

**Mike Schmidt**: Thanks for that commentary, Dave.  So, Murch, go ahead.

**Mark Erhardt**: Maybe the context of why they're doing this in the first place
is interesting.  So, the LN nodes usually run on a thin client backend and they
do not have the mempool, so they cannot actually see what's going on or do a
statistics-based feerate estimation on what they saw in their mempool and got
confirmed later.  So essentially, they're blind, and previously the approach has
basically -- I'm not sure if LND was using this approach, but I know some LN
nodes were using the approach to just, as soon as they see that the transaction
didn't get confirmed, they just rebroadcast it with a higher feerate until it at
some point gets confirmed, which is completely blind, right?  So, in a way, if
this is an additional source of information, that would be great.  If it's the
only source of information, yes, it's kind of scary in the context that they
could lie to you and make you pay a lot of fees that you don't have to pay.

_LDK #2756_

**Mike Schmidt**: Next three PRs that we highlighted are all to the LDK
repository.  Jeff, thank you for hanging on for an hour-and-a-half.  We've
crammed Optech content down your throat and made you wait, but the good news is
you have three interesting PRs here that we can celebrate getting into LDK, and
I'm excited for you to talk through some of these.  So, I guess I'll give you
the floor.  We can start with #2756.

**Jeffrey Czyz**: Great, just checking if you could hear me.

**Mike Schmidt**: Yeah, we can hear you.  And I don't think you were a part of
the intro, so say hi to folks and let them know what you're up to.

**Jeffrey Czyz**: Yeah, so my name is Jeff, I work at Spiral primarily on LDK,
which is the Lightning Development Kit.  For anyone that's unfamiliar, it's
essentially an SDK for Lightning.  We implement the Lightning protocol for you,
so you can just come straight on and build a new great wallet.  So, we have a
few PRs here that are kind of like prerequisites to some larger features we want
to get into LDK.  Those notably would be dual-funding, splicing, and
asynchronous payments.  Asynchronous payments are, it's still kind of early in
the spec stage, but the other two, that is dual-funding and splicing, are well
along.

So, to start off, we have LDK #2756, which adds a trampoline routing packets
basically to the onion payload.  And so for trampoline, this is a way for, for
example, mobile wallets that don't necessarily have the entire network graph in
memory to send payments to sort of like an intermediary node called the
trampoline, and that would then construct the path the rest of the way to the
recipient.  And so, this is particularly important for asynchronous payments
because in asynchronous payments, the sender or the receiver might be offline
during, I guess, the entire time or portions of the payment.  So, for instance,
the sender, they may want to just tell their LSP, "Here's the payment.  When the
receiver's online, can you forward it to them".  And since they're likely a
mobile node, having trampoline to, I guess, complete that payment is ideal.  So,
this adds basically support for constructing onions that include that routing
information.

_LDK #2935_

Next up on here is #2935, which is basically adding keysend support to blinded
paths.  And so, for those unfamiliar with blinded paths, that's part of the
offers spec, where invoices can have essentially a -- not just invoices, but I
guess any messages and invoices -- have a blinded portion of the hops.  Usually
it is the last few hops along that path.  And when you are sending a payment, it
adds basically privacy …

**Mark Erhardt**: I just lost Jeff, did you?

**Jeffrey Czyz**: Can you hear me now?

**Mike Schmidt**: Yeah, you're back.

**Jeffrey Czyz**: Yeah, I think it's when the screen turns off.  So, it adds
keysend support to blinded paths.  And this is also important for async
payments, because you may imagine that the recipient of the payments, this is
going to be the person that created the offer, they might not be online when you
request an invoice in the BOLT12 protocol.  And because of that, we may have to
return sort of a static invoice to them.  This would be like their LSP, who is
more online, typically the LSP.  And with that, since there isn't a payment hash
associated for one of these static invoices, we need to use keysend to allow the
recipient to claim the payment.  So, this adds that sort of support to blinded
paths.  And let's see, any questions on that before I go on to the next, which
is a little, I guess, a different topic?

**Mike Schmidt**: Doesn't look like it.  No, continue.

_LDK #2419_

**Jeffrey Czyz**: All right.  So, again, those are sort of like stepping stones
to asynchronous payments.  The next one, interactive transaction construction,
is basically a prerequisite to dual-funding splicing.  So, in those two
protocols, the construction of the funding transaction is not one-sided as it is
in normal Lightning interactions.  So, Lightning started where the funder of the
channel gave UTXOs for inputs, and that was used to construct the funding
transaction.  And I guess the drawback of that is that the initiator of this
channel has outbound liquidity, but doesn't have inbound liquidity.  And so,
that makes it tough to receive payments.  So, what dual-funding does is allow
both counterparties of the channel to add essentially their own UTXOs as inputs
and allowing them to have liquidity in both directions upon channel opening.

Splicing is sort of a, I guess, related protocol where you're able to add or
remove funds from the channel.  So, both of these require some sort of
interactivity between the counterparties to come together and construct a
funding transaction.  And this interactive transaction construction protocol is
basically a turn-based protocol, where each of the counterparties in the
construction of the channel add a turn to either add an input or add an output
to this funding transaction, and they basically go back and forth.  And one may
say, "Okay, I'm going to add this input".  The next person may say, "I have
nothing to add, so let's just say, 'Transaction complete'".  That brings it back
to the original party who can then continue to either add or remove inputs.  And
their counterparty, once they see that, can continue onwards as well to do that.
When they both give a transaction complete, then the channel is ready to be
funded.  So, that's when the dual-funding and the splicing layers on top …

**Mark Erhardt**: I think your screen turned off again.

**Jeffrey Czyz**: Sorry, I'm back on.

**Mike Schmidt**: That's a nice feature of Twitter!

**Jeffrey Czyz**: Yeah.  So anyhow, yeah, interactive transaction destruction is
sort of this prerequisite step to get dual-funding and splicing in, so we're
pretty excited about that.  Those are some features that a lot of our users
really want, particularly splicing.

**Mark Erhardt**: Very cool.

**Mike Schmidt**: Yeah, Jeff, thanks for coming on and walking us through that.
In terms of these PRs being rolled into the next version and timing there and
what you'd be looking for potentially from the audience, do you want to wrap up
with anything on those topics?

**Jeffrey Czyz**: Yeah, so next release, hopefully two weeks, and these will
definitely be in the next release.  But again, these are just prerequisites to
getting these larger protocols in.  So, it's going to be maybe another release
or so for splicing.  And async payments, again, is still sort of in the early
spec phase.  So, while we may have it as an experimental feature in the next few
releases, it might take time before other implementations catch up with us too.
So, we'll see how that goes.  Big shout out to Val and Arik, working on these
PRs, and then Jurvis and Wilmer on the third PR that I mentioned, and dunxen as
well, actually.  It was quite a lift.

**Mark Erhardt**: Yeah, I just wanted to jump in briefly.  What is the roadmap
plan here?  Is splicing going to be compatible between different
implementations?  I know that Phoenix, for example, has made the news with their
splicing implementation.  Would we be able to use splicing between different
implementations; how long is that going to take?

**Jeffrey Czyz**: Yeah, that is definitely the goal.  I'm not sure as far as
timeline, but the people on Eclair's side of things, ACINQ, they are definitely
supportive of that.

**Dave Harding**: Murch, I believe that Eclair is currently compatible with Core
Lightning's (CLN's) implementation of splicing.  I know that they were working
out some final compatibility issues, but I think that was already there.

**Jeffrey Czyz**: Yeah, I'm not as completely familiar, but my understanding is
the ACINQ side, Eclair/Phoenix, they were early in implementing this, so there
may have been some incompatibilities early on, but those are now hopefully being
addressed, or if not, have already been addressed.

**Dave Harding**: I also just wanted to thank you all for working on trampoline
routing.  I think that's somewhere that ACINQ started that out, they did a bunch
of work on it years ago, and I don't think any of the other implementations have
picked up work on that, but it does seem like a really useful feature, so thank
you all for working on that.

**Jeffrey Czyz**: Yeah, that's great, too.

**Mike Schmidt**: Thanks for joining us, Jeff.  We got a couple more PRs.
You're welcome to stay on as we go through those.

**Jeffrey Czyz**: Thanks.

_Rust Bitcoin #2549_

**Mike Schmidt**: Yeah, thanks for your time.  Rust Bitcoin #2549.  This PR
improves Rust Bitcoin's API around timelocks.  The author of this PR, in terms
of motivation, he ran into limitations in the current handling of locktimes in
the API, and so he made this PR which resolved three separate issues on the
repository: he added some constructors; and the PR also adds the ability to
convert relative timelocks into sequences; and then, there's also some
under-the-hood updates as well.  So, if you're doing timelock Rust Bitcoin
stuff, take a look at that.

_BTCPay Server #5852_

And last PR this week, BTCPay Server #5852, which adds support for BBQr PSBTs.
As a reminder, BBQr is a scheme to encode larger files into a series of QR
codes.  So, the series of QR codes is commonly referred to as like an animated
QR code, you may have seen these before.  And BBQr can be used with other file
types, but the main motivation for Bitcoin and the authors of the BBQ PR spec is
for encoding BIP174 PSBTs in these animated QRs.  So, the idea is that you could
use these animated QR images to parse partially signed Bitcoin transactions to
airgapped devices.  And now with this PR, BTCPay has support for scanning in
those animated BBQ QRs and parsing the resulting PSBT information.  Murch likes
it.  Anything to add, Murch or Dave?

**Mark Erhardt**: Yeah, I mean, maybe just for context, a lot of these really
small devices, they don't have awesome cameras, so putting more information in a
QR code would make the dots on the QR code so much smaller, and I think you
would at some point get resolution issues.  So, the idea is just to basically
instead give a sequence of smaller parts of the total information in the
animation, and that allows them to transfer all of the information that they
couldn't scan in a single QR code.  So, we've reported on this previously.  It
looks pretty cool.  Dave, you might have more sane stuff to say about this.

**Dave Harding**: Oh, I just think that standard QR codes, I believe the upper
limit there is like 8,100 bytes, and it's really easy to create a PSBT larger
than that, because one of the things that you often have to include in PSBTs is
copies of previous transactions, particularly for legacy transactions.  And a
lot of signers require them also for segwit v0 transactions because of an
interesting fee attack that's theoretically possible, pretty challenging to pull
off.  But yeah, because you have to include entire copies of previous
transactions into a PSBT in many cases, it's really easy for them to get up
beyond the maximum size that's possible with a static QR code.  So, these
animated codes are just moving past that byte size limitation.

**Mike Schmidt**: I don't see any requests for speaker access or questions,
other than a BitVM question for you, Murch, which I'll let you handle offline.
Thanks everybody for joining.  Thanks to Jeff for sticking around and talking
about LDK stuff.  David, thank you for hanging around as well and walking us
through the Testing Guide.  Thanks to Abubakar, Peter Todd and Dave Harding for
also chiming in on the News sections, and as always to my co-host, Murch, and
for you all for listening.  Cheers.

**Mark Erhardt**: Thanks.  Hear you next week.

{% include references.md %}
