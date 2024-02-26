---
title: 'Bitcoin Optech Newsletter #270 Recap Podcast'
permalink: /en/podcast/2023/09/28/
reference: /en/newsletters/2023/09/27/
name: 2023-09-28-recap
slug: 2023-09-28-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Anthony Towns to
discuss [Newsletter #270]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-28/348933246-22050-1-1adbf67977b17.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #270, Recap on
Twitter Spaces.  Today, we're going to be talking about using covenants to
improve Lightning scalability with our special guest, AJ Towns; we have six
interesting questions from the Bitcoin Stack Exchange in our monthly segment on
those Q&A; and we have PRs to Bitcoin Core, the Bitcoin Core GUI, and all of the
major Lightning implementations.  Introductions, I'm Mike Schmidt, I'm a
contributor at Bitcoin Optech, and I'm also Executive Director at Brink, where
we fund open-source Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch.  I work at Chaincode Labs on Bitcoin-y stuff.

**Mike Schmidt**: AJ?

**Anthony Towns**: Hi, I'm AJ, I work on Bitcoin Core dev stuff, Lightning
research things.  I'm with DCI.

**Mike Schmidt**: AJ, is there a particular area of Bitcoin and Lightning that
you're putting your time towards lately that folks might be interested in
hearing about?

**Anthony Towns**: Lately, I've mostly been doing review stuff, which has been
awesome because stuff's actually been getting merged.  I've been getting the
signet Inquisition stuff back up to date with the latest Bitcoin Core releases.
So, hopefully that can get bulk merged and released and stuff soon, we'll see, I
don't know.

**Mike Schmidt**: Excellent.  Yeah, we had you on last year at some point, maybe
since then as well, but I remember signet was sort of just really an idea that
you had put out there and now it seems like it's somewhat the place for new
ideas to incubate.  So, congrats on having the foresight for that idea and then
sticking with it and keeping it up to date.

**Anthony Towns**: Yeah, well there's been a few covenant-y proposals that
hopefully we'll get to test in kind of fake, real-world situations with that.

_Using covenants to improve LN scalability_

**Mike Schmidt**: We'll jump into the newsletter, we'll just go sequentially
here.  We have one news item, which is using covenants to improve Lightning
scalability.  And this topic is based on a post from John Law to both the
Bitcoin-dev and Lightning-dev mailing lists.  And the post was titled, Scaling
Lightning With Simple Covenants.  And I won't break down the idea too deep
without AJ, but the idea involves using covenants-based protocol to create
Lightning channel factories that would have potentially better scaling
properties than previous channel factory proposals.  AJ, maybe a way to lead in
here is, I think bitcoiners would largely think of Lightning as the scaling
solution for Bitcoin.  But now we have John Law posting here that we need to
scale Lightning.  So, maybe you can talk a little bit to potential Lightning
scaling issues first, and then we can jump into John Law's proposed approach to
a potential solution.

**Anthony Towns**: Sure.  So, the way that Lightning on its own improves things
right now is, instead of having to do an onchain thing every time you transfer
money to someone, you can batch a lot of those up and only have an onchain thing
happen when you want to rearrange the balance of your Lightning channels, rather
than every time you make a payment over it.  So, at least the way I think of it
is that rather than going onchain for every coffee purchase, you're now just
going onchain every time you want to change banks or want to make a large
deposit or withdrawal.  And that's great as far as it goes, but you still don't
want to have people making onchain things every time that they make a big
withdrawal or go to their bank and decide to change from one bank to another, or
change the terms of their banking to have a better bank account or something.

So, the idea behind, I guess, channel factories is that instead of every single
relationship between the bank and a customer going onchain, instead you've got a
factory that combines a whole bunch of different people together, and every time
you go onchain, you can change the balances of every single member of that
factory all at once in aggregate.  So, that already has the benefits of
Lightning today, where you are collapsing a whole bunch of transactions into
just one.  But now you're not only doing that for the transactions, you're also
doing it for the users and collapsing a whole bunch of changes for many
different users into one.

But the problem with that approach is that the way we've always thought about
that with eltoo channel factories or with some of John Law's other ideas or
other approaches, is that we'd always have a multisig between every single
member of that factory, so that every single one of them has to sign off on
changes.  And in the in the sense of everyone like being self-custodial and
having control of their own funds and not being able to be ripped off by banks,
or whoever, that's a great idea because that way you have to sign off on every
change to a balance and no one can steal from you.  But the downside of it is
that if someone's not really paying attention, if they've not opened their app
for a few weeks, if they've forgotten their password, if their phone's broken,
if they're on holidays, then they're not going to be around to sign that update.
And that means that every single other member of its factory can't do an update,
and then that needs to get dropped onchain and you're back having everyone's
stuff appear onchain.

So, the idea here is that we split people into reliable and unreliable people,
online and not online, I forget the term that John uses for it.

**Mike Schmidt**: The casual Bitcoin users?

**Anthony Towns**: Yeah, the casual Bitcoin users and the dedicated ones, I
think, for the users.  So, you have the people with their data centers and their
banks and who are making money off Lightning, who are going to be there 24/7
responding in seconds, as the dedicated users; and then you have the casual
users who are going to come online once every month or once every couple of
months or once a week, or something like that, and make it so that the dedicated
users can do the updates all by themselves so that it doesn't matter how many
casual users disappear, but you restrict how they can do the updates in such a
way that they can't actually steal the money from the casual users, as long as
the casual users do come around every so often.

**Mike Schmidt**: AJ, you spoke a bit conceptually and almost philosophically at
the beginning of your description here.  Do you think it's fair to plug the
"Putting The B in BTC" blog that you posted, if folks are interested in your
high-level thoughts about scaling to billions of people; is that fair to plug
that here from a philosophical perspective?

**Anthony Towns**: Sure.

**Mike Schmidt**: Okay, I will probably put that as a link here in the comments
of this space.  Sorry, I didn't mean to interrupt.  Did you want to continue, or
was that sufficient?

**Anthony Towns**: Well, I'll bounce off that a little bit, I guess.  So I guess
the way I think about it is that the sort of Lightning we've got at the moment,
I don't know, maybe scales to tens of millions of self-custodial users, and then
however many custodial users you want on top of that.  And then, an approach
with factories expands that a little bit, but you have the constraint that
anyone who's going to be unreliable is really pretty much forced into a
custodial relationship, because nobody's going to want to open a channel with
them if they're not going to be around and going to effectively lock up the
funds.  So, this step here, if it works and has the covenant stuff available and
can be implemented and doesn't have bugs, and whatever other caveats you want to
add, then I think this gets you up to another ten times that or something.  But
that I still don't think gets you up to the billions of self-custodial users
that we'd still like to get.

So I mean, assuming it works the way that John pitches it, then it's a huge step
forward, but it doesn't get you 100% of the way.  So, if people are researching
this, they're still justified to have a day-job.

**Mike Schmidt**: Covenants are mentioned as a prerequisite to this idea.  AJ,
is it OP_CHECKTEMPLATEVERIFY (OP_CTV) or SIGHASH_ANYPREVOUT, or is it and, or
what are the options here to implement this?

**Anthony Towns**: So, I haven't worked out all the details for this, so I'm
going on a bit of intuition here, more than dedicated knowledge, so take it with
a grain of salt.  But I think the timeout tree stuff is all best done with
OP_CTV, because it's just committing to a particular set of outputs.  But on top
of that, the timeout tree is essentially saying that the dedicated node is going
to take a million, however many, casual users, put them in a tree structure.
So, on the left-hand side we have the first 500,000, on the right-hand side we
have the second 500,000, then we split those 500,000 into 250,000 and so on.
And we have transactions all the way down there, down through the tree, so that
you have 20 transactions between the original dedicated nodes, UTXO and any
single individual that wants to cash out independently.  And that timeout tree
is something that after the timeout, the dedicated user can just replace this
one unit if no one's decided that the dedicated user's been trying to cheat
them.  And so that's where the efficiency comes in.

But the safety side is that the dedicated user can only do that after the
timeout, and prior to the timeout they have to take this OP_CTV path that says
they have to have this specific tree of outputs that gets precisely to whoever
it needs to get to.  And the point of the covenant introspection, whatever you
want to call it, stuff there is that if you did pre-sign transactions or some
other existing way of doing that, you can't guarantee that the dedicated node
doesn't have access to the keys to completely redo that and cheat before the
timeout occurs.  But pretty much any sort of covenant stuff will work for that,
it's just a question of one being slightly more efficient than the other.

**Mike Schmidt**: You opined on the mailing list post talking about the
"thundering herd" problem, and we alluded to it maybe earlier in this
discussion, but do you want to bring up that objection and the potential
mitigation that it sounds like John Law is maybe working on?

**Anthony Towns**: So, I think we shouldn't call it the "thundering herd"
problem, I think we should go with the original LN Papers term, which I couldn't
think of when I was writing that email, so the "forced expiration spam", which
is basically just saying that if you've got all these offchain things happening,
it's possible that there's some sort of systemic problem that's going to affect
many of those channels, and they'll all need to go onchain at once.  And if that
happens, and you've got far more users doing stuff offchain than you have room
to do onchain, then they're each going to be competing with each other.  The
ones that lose that competition could have their money stolen by their
counterparties.  And because of the competition, the fee rates are going to
rise, and it's all a very uncomfortable, risky sort of proposition.

So, the thing I was thinking about was more along the lines of, this is a
problem we already have with Lightning, and putting millions of users behind a
single UTXO, such that if there's a problem just with that dedicated node,
that's going to affect that entire set of a million users.  And so, that's kind
of an easy way to get this problem, but there are still existing ways to get
this problem with Lightning as it stands, right?  But it's more that this
approach gives you kind of a trade-off, such that if you're worried about the
risk for your funds, then you just need to take action well before the timeout.
You need to start your pushing stuff on chain well before the timeout so that
you've got three weeks, six months, however long you feel comfortable that fees
will drop back down and you'll have room to get your stuff confirmed onchain.
And that moves it to kind of a trade-off between how much risk you're accepting
at this forced expiration span problem versus how much capital your counterparty
is going to have locked up for this extra-long timeout that you might not ever
actually need to have.  And then you can put numbers on it at that point to take
your risk versus the cost of capital.

It's not just we want to make as much space as possible so that this doesn't
happen, it's like an actual trade-off you can do numbers on.

**Mike Schmidt**: Am I understanding it correctly that a dedicated user, are
they the one who can roll over to a new factory without any of the casual users
being involved?  I know we noted that in the newsletter and it would seem like
you would just always want to be continuously rolling over to a new factory with
a longer expiry to avoid this issue, right, or are there downsides to that as
well?

**Anthony Towns**: Yeah, that's the ideal case when everything's working.  The
only time that doesn't happen is when the dedicated user disappears or refuses
to talk to the casual users, whose money they've got locked up in that UTXO.
And that's the point at which the timeout tree gets pushed onto onchain, and you
have all those million transactions that have to actually get processed.  As
long as the dedicated user -- so if a dedicated user tries to cheat, then that's
what happens, and they hopefully don't get any profit from it, so the idea is
they won't try to cheat.  But if they lose all their backup, say, and physically
can't sign an update, then that would be another reason why the timeout tree
would have to go onchain.

So, yeah, in the problem case, then you can handle it without people having to
pay fees, but otherwise not lose their funds.  But in the ideal case, you're
always going by the dedicated user just signing an update after the timeout,
everybody's funds get moved offchain to a different timeout tree well before the
timeout, and beyond that, the complicated detail stuff is putting at the leaves
of the timeout tree, you don't just have the dedicated user and the casual user,
you have some of these multisig factories, and you potentially have it between
the casual users and multiple dedicated users, so that even once the casual
users have moved on to another timeout tree, the funds can still be actively
used for routing between the multiple dedicated users.

**Mike Schmidt**: Something that I was curious about, I did a find in John Law's
paper looking for a coinpool or a joinpool.  And maybe, AJ, you can speak to how
those are similar or different to channel factories, how you think about that?

**Anthony Towns**: I kind of mostly think of them as much the same thing.  If
you have a coinjoin, then it's just multiple parties put funds in, then they
take them out and that's it.  And if you add to that the fact that they can
transfer between themselves offchain before they go onchain and take all the
money out, then you've just got a Lightning factory, as far as I'm concerned.
There's a bunch of details about how to best do those factories so that you can
have the best kind of performance and flexibility with your funds in there, and
I think John's previous proposals are some of the best ways to do that, the
factories that we've had so far.  But equally, I don't think anyone's even tried
to implement them yet, so it's still a really interesting paper.  It's something
that we can start writing BOLTs for and deploy soon.

**Mike Schmidt**: I'll make one more comment here, but before I do so, I'll
solicit the audience.  If folks have questions on this proposal or any of the
techniques that AJ has outlined in our discussion here, feel free to request
speaker access and you can have a dialogue.  One thing that I thought was
notable in the writeup was that this proposal is compatible with LN-Penalty as
well as LN-Symmetry.  Now obviously, it requires covenant capabilities, but it
seems like if we got to that point, that this proposal could be rolled out,
assuming no flaws are found on LN-Penalty, without having to wait for
LN-Symmetry to roll out; is that right, Anthony?

**Anthony Towns**: Yeah, I'm not sure that this would be like -- LN-Symmetry has
code, so it's in a more developed state.  So if we got covenant stuff in
Bitcoin, I think it would end up being first before this.  But the leaves of the
timeout tree here can be any sort of channel factory construct, I think.  So,
yeah, it can be pretty compatible with just about everything, I think.

**Mike Schmidt**: Murch, I don't see any questions from the audience.  Do you
have questions or comments for AJ, representing John Law's idea?

**Mark Erhardt**: I don't at this time.  Thank you though, AJ, for walking us
through this.

**Mike Schmidt**: AJ, anything that we didn't cover related to these topics that
you think the audience would be curious about?

**Anthony Towns**: I don't think there's anything that I can explain well that
you didn't cover, no.  There's a whole bunch of interesting stuff that I don't
fully understand from that paper, and then there's the follow-up stuff that was
also mentioned at the bottom, which we don't have much details on, but it's also
pretty interesting to think about.

**Mike Schmidt**: AJ, if you don't fully understand it, there's no hope for us!

**Anthony Towns**: Well, I mean to be fair, I haven't tried to fully understand
it.  So there is hope, there's always hope!

**Mike Schmidt**: Well, AJ, thank you for joining for this segment.  You're
welcome to stay on.  We have some interesting Q&A from the Stack Exchange, if
you don't need to be heading off to bed right away.  Otherwise, thank you for
joining us.

**Anthony Towns**: Yeah, I'll sit straight for a bit.

**Mike Schmidt**: Great.  Next section from the newsletter is our monthly
segment, which highlights questions and answers from the Bitcoin Stack Exchange.
We have six questions this week that we highlighted.

_How did peer discovery work in Bitcoin v0.1?_

The first one is, "How did peer discovery work in Bitcoin v0.1?" and I'll quote
from the answer here, "The first seed mechanism was IRC-based.  There was a
hardcoded IRC server and IRC channel, which was actually the #bitcoin on
Freenode, and the Bitcoin software would connect to the server, and join the
channel with a nickname that encoded the IP address of that particular node.
Through that, there would be these "JOIN" messages from other Bitcoin nodes also
joining the IRC channel.  And through that, that was the mechanism in which IPS
addresses of other nodes was discovered", which was pretty interesting.  I think
I had heard about that from a high level, but I didn't realize the exact
mechanics of it, which was interesting.

The answer from Pieter Wuille also goes on to describe some other evolutions of
the peer discovery being iterated on, which included adding hard-coded IP
addresses as a fallback, changing the IRC server that hosted the IRC channel,
adding DNS seeding, which was off by default, then adding 100 IRC channels
instead of just one, then enabling DNS seeding by default; and then finally, in
March of 2014, removing support for the IRC seeding mechanism entirely from the
codebase.  Murch or AJ, any thoughts on that?  I was a class of post-IRC-seeding
bitcoiners, so I wasn't aware of a lot of that.

**Mark Erhardt**: I think it's just really nifty to bootstrap a P2P Network over
IRC join messages.  I don't know, that's all.

**Anthony Towns**: I don't think the IRC admins cared for it quite a bit,
because it looked like bot traffic, which is often annoying for IRC things.  It
worked for a fair while, so that's impressive.

_Would a series of reorgs cause Bitcoin to break because of the 2-hour block time difference restriction?_

**Mike Schmidt**: Next question from the Stack Exchange was, "Would a series of
reorgs cause Bitcoin to break because of the 2-hour block time difference
restriction?"  I think to set the context on this question, we'll outline the
two restrictions on what a block's timestamp can be, and then we can jump into
the motivation for this question.

The first rule is that a block's timestamp can't be greater than the median time
passed.  And median time passed is the median time of a block and the ten blocks
preceding it, so it's a way to sort of enforce that time is moving forward to
some degree.  And the second rule -- go ahead.

**Mark Erhardt**: Just to clarify, sorry, I think you said it can't be greater.
It has to be greater than the median time past.  So, the median time past is
essentially the median timestamp of the last 11 blocks, so roughly an hour ago.

**Mike Schmidt**: That's right.  If I said it can't be, I meant it must be!
Sorry about that.  And then the second rule for the block's timestamp is that it
cannot be more than two hours into the future, according to the node's local
time.  So, given these two restrictions, fiatjaf asked on the Stack Exchange if
there's a scenario where miners, potentially in a scenario where they're fee
sniping each other's blocks and essentially remining previous blocks, that a
bunch of time would pass during this fee sniping and remining of blocks such
that the two hours would pass, and that that would essentially break Bitcoin.
And I think there was some confusion that I think fiatjaf was misinterpreting
the local node's two-hour-into-the-future block time timestamp restriction as
two hours into the future from the last block's timestamp, which could actually
cause issues if that were the rule.  Murch or AJ, do you have a take on this?

**Mark Erhardt**: Well, I think that was just a misunderstanding.  As the time
moves forward, your local node's time obviously goes forward too.  So, even if a
block were set far into the future and nothing else was mined at the same
height, eventually that block would become valid.  So, yeah, the issue that was
hypothetically there, that just can't happen because it's not how the two
restrictions work together.

**Anthony Towns**: Yeah, there's no constraint on how long there can be between
blocks, although I think the proposal for how to fix the year 2106 problem
proposes is probably going to introduce a constraint where blocks can't be more
than 50 or 100 years apart.

**Mark Erhardt**: Oh, dear.

**Mike Schmidt**: Is that a timestamp-overflowing issue?

**Anthony Towns**: Yeah, exactly.  So we have 32-bit timestamps, which will run
out in, I think, the year 2106.  And the idea is that we'll just store below 32
bits and say that if it goes backwards, then add on an extra bit in the high 32
bits, and that constrains it to being within 50 or 100 years, depending on quite
how you do it, I guess.

**Mark Erhardt**: I think that might work, you know.  Also, small trivia, we
have had blocks that were more than two hours apart, so if this problem actually
existed, we would have already triggered it right in the first week of Bitcoin
and then also a couple of times after.

**Mike Schmidt**: I guess that's a good point as well.  I didn't see that in the
answer.  You should add that if that's not in there.

_Is there a way to download blocks from scratch without downloading block headers first?_

Next question from the Stack Exchange is, "Is there a way to download blocks
from scratch without downloading block headers first?"  And the person asking
this question says, "I would like to know if there's a way to download a
blockchain without knowing block headers".  And sipa responded that it is
possible to download blocks without the headers, but he also points out that the
node who's downloading those blocks would not know if it's on the best chain
until after it has already downloaded and then processed all of the blocks that
it got from that peer.  So, headers-first sync was introduced, I don't remember
the year, but to mitigate that potential issue, so you should prefer that.  I
think sipa quasi recommends that in his answer.  Murch, can you think of a
reason that someone would want to download the Bitcoin blockchain without
knowing the block headers?

**Mark Erhardt**: I guess if you're writing your own node software and you might
not want to implement the whole logic to separately download the header chain
and verify that before you sync the blocks, but you just want this most simple
way of synchronizing with the network, you might be interested in just asking
for the blocks, yeah.

**Mike Schmidt**: AJ, any color to add?

**Anthony Towns**: One of the reasons, or one of the things that we're careful
about with the headers, is the risk of a hostile node giving us a false chain of
headers that's very long, uses up a lot of memory, wastes a lot of our
validation time, or something, and just doesn't have as much work as the real
chain.  So, that we do the headers first helps us avoid that sort of attack.  If
you're running a bitcoind node in between that's doing all that stuff and
protecting you, then that's fine, but then you could probably just use RPC to
get all the blocks into whatever software you're using as well, so I don't know.

_Where in the bitcoin source code is the 21 million hard cap stated?_

**Mike Schmidt**: Next question from the stack exchange is, "Where in the
Bitcoin source code is the 21 million hard cap stated?" and much to some folks
on Twitter's horror, there is, as Pieter Wuille responded, "Nowhere, because
there isn't actually a 21 million cap rule".  So instead, the maximum number of
Bitcoin that can exist is governed by the GetBlockSubsidy function, which limits
how many coins miners are rewarded in a block, and I see a lot of Bitcoin
subsidy emission schedule on Twitter on T-shirts.  But if you want to see the
code, it's in this GetBlockSubsidy function.  And Pieter also links to an
interesting Stack Exchange post, which has a bunch of discussion around
unspendable coins for various reasons, which I thought was also interesting.
Murch or AJ?

**Mark Erhardt**: Yeah, I think it's -- sorry, you go ahead.

**Anthony Towns**: So, the MAX_MONEY constant that's in there that is set to 21
million is actually used in consensus code in a couple of places, but that's
mostly just to say that an individual transaction can't spend more than that
amount.

**Mike Schmidt**: And that's really like a sanity check, right, that was put in
place as a fail-fail?

**Anthony Towns**: So, it is a sanity check, but it was also I think a bug fix
for, there was a transaction that overflowed, uint64 or something, and so it
ended up creating lots of money out of nowhere, and so that was a double check
to avoid that as well.

**Mike Schmidt**: Murch?

**Mark Erhardt**: Yeah, I was going to say pretty much the same.  The overflow
incident was in 2010, and somebody basically realized that they could have a
really, really large output if the two outputs together summed up to being
smaller than the input by overflowing.  So they just, I don't know, I don't even
remember exactly.  It was some absurd amount of Bitcoin that they created in
that transaction, that was obviously not intended, so it was reorganized out of
the blockchain.

**Mike Schmidt**: I think that there was a CVE for that.  I think it might be on
our Topics CVE page.  I don't have it immediately up in front of me.

**Mark Erhardt**: Yeah, there is a CVE, I think.  And there's also a Bitcoin
Wiki article which I just pulled up.  So, the user, or the attacker I should
say, created two addresses that each received 92 billion bitcoins and that
caused the overflow.  So that, yeah, it actually looked like it was smaller than
the input.

_Are blocks containing non-standard transactions relayed through the network or not as in the case of non-standard transactions?_

**Mike Schmidt**: Next question from the Stack Exchange is, "Are blocks
containing non-standard transactions relayed to the network or not, as in the
case of non-standard transactions?"  Murch, as the co-author of the policy
series that we featured a couple months back on the Optech Newsletters and its
separate blog posts aggregating all of those discussions, maybe you can explain
what is a non-standard transaction and why isn't it relayed by default, and then
why is it relayed in a block?

**Mark Erhardt**: Right.  So, the standardness rules are rules that apply to
unconfirmed transactions, and the name comes from a function in Bitcoin Core
called isStandard.  It encompasses transactions that send to some of the
standard output scripts that are smaller than 100,000 vbytes and there's some
other restrictions.  For example, they're not allowed to have more than one
OP_RETURN output, and an OP_RETURN output is not allowed to be bigger than 80
bytes.  So if a transaction passes this rule, it is considered standard by your
node, your node puts it in its mempool and forwards it to all of its peers.  If
it's not standard, or it doesn't pass the mempool configuration of your node,
your node will not put it in its mempool and it will not forward it to peers,
even though it might be valid per the consensus rules.

So, what's happening here is if a miner includes a non-standard transaction in
their block, which we've for example seen with the Taproot Wizard's block that
had a single transaction that was almost the entire block, or actually it was
the entire block, then the block is still validated according to the consensus
rules.  And since we have propagation guarantees for blocks, because everybody
needs to see every block in order to catch up with the network state, we do
propagate transactions that are part of a block, whether they're standard or
non-standard.  There, we only care about validity.

**Mike Schmidt**: And as one miner found out this week, there's also some
restrictions, even if you do have valid transactions in a block, on the ordering
of those transactions, such that if it's in the wrong order, you lose the block
subsidy.

**Mark Erhardt**: Well, more specifically, if you reorder transactions in a
block without checking that they are topologically valid.  So, to spend an
output, the output has to first exist, right, and if you're spending an output
from another transaction in that block, that means that the parent transaction
has to stand first in the block; the order is relevant.  So what happened here
was that, I believe it was Marathon, took a block template and then ordered it
by absolute fees and that caused the 6th transaction to stand before the 174th
transaction, but the 174th was a parent of the 6th transaction.  So, the block
was invalid and they lost the block reward.

**Mike Schmidt**: Murch, we have a question in the thread here, which is from DA
Sails asking, "Does the 0.5 bitcoin still exist from the value overflow incident
onchain?" and I do not know the answer.  I don't know what the 0.5 is either.

**Mark Erhardt**: I think we looked that up a while back and the input is still
unspent.  Yes, the input still exists, but obviously the transaction itself that
caused the overflow was re-orged out after the bug was fixed.  It was considered
invalid.

_When does Bitcoin Core allow you to Abandon transaction?_

**Mike Schmidt**: Last question from the Stack Exchange is, "When does Bitcoin
Core allow you to abandon a transaction?"  Murch, you answered this question, so
maybe you can take the lead here.  What does abandoning a transaction mean and
what are the criteria for abandoning a transaction?

**Mark Erhardt**: So, when a transaction gets stuck in the sense that it is not
high enough priority to get included in a block, it will time out after a while
out of other nodes' mempools, but on your own node, the Bitcoin Core wallet will
continuously rebroadcast its own transactions to its own node.  So, generally a
transaction will, even if it times out, out of your own mempool, get reinserted
by your own wallet into it.  So, if you want to make an attempt of creating a
conflicting transaction that supersedes the original transaction, you have to
somehow instruct your node to forget about that transaction.  What you do is you
use the abandontransaction RPC against your wallet and instruct it to no longer
pursue confirmation for that transaction.

But this RPC is only successful if it's actually not in your mempool.  So,
that's sometimes confusing.  Maybe it would be useful to have an option on that
RPC actually to instruct the mempool to also forget about that transaction when
you call abandon.  But either way, it doesn't mean of course that other nodes
forget about the transaction, even if you instruct your own node to drop it or
to supersede it.  So anyway, this question went into the finer points of when
you can call abandontransaction, and you can only do so if you haven't called it
on that transaction before, if the transaction hasn't confirmed yet, or a
conflicting transaction has confirmed and if it's not in your mempool.

**Mike Schmidt**: Is there a practical way to boot that transaction out of the
mempool aside from your suggestion that that can be added to the
abandontransaction RPC?

**Mark Erhardt**: Well, I guess you could maybe call prioritizetransaction with
a very large negative fee on it, and then if your mempool's full, it would get
kicked out.  Or, you could just turn off your node and delete the mempool.dat
file and start your node again to flush your entire mempool.  I'm not sure if
it's that simple, or if there's a -- I hope there's a simpler way that I'm
missing right now, but I can't think of it from the top of my head.  AJ, do you
have an idea?

**Anthony Towns**: I remember that abandontransaction thing not working being
one of the first things that confused me about using Bitcoin when I started.  I
don't think there's an easy way to get rid of it from the mempool, apart from
all the jiggery-pokery that you were suggesting.

**Mark Erhardt**: PRs welcome!

**Anthony Towns**: Yeah, I'll initial at least two.

_LND v0.17.0-beta.rc5_

**Mike Schmidt**: We have one release candidate from the newsletter, which is
LND v0.17.0-beta.rc5.  We note in the newsletter testing of simple taproot
channels, which is a feature of this release candidate, is a nice call to action
for folks.  And we also spoke with roasbeef, one of the leads on LND, in our
#268 Recap podcast.  So, if you're curious about this latest release and some
more details on what's in there, refer back to that episode.

_Bitcoin Core #28492_

Moving on to Notable code and documentation changes.  And as we go through
these, if anybody has questions, feel free to ask for speaker access or comment
on the thread and we'll try to get to those.  First PR, Bitcoin Core #28492, the
descriptorprocesspsbt now returns the complete serialized transaction if the
PSBT is in a complete state.  This is similar to last week, where we highlighted
a similar change to the descriptorprocesspsbt.  There was a similar one last
week that also had a -- oh, that was walletprocesspsbt from last week that had
the same feature, which essentially takes some RPC steps.  If the PSBT is ready
and complete, it'll return the serialized transaction hex at that point, as
opposed to going through all of the steps related to PSBT workflows.  Go ahead.

**Mark Erhardt**: Just a quality of life improvement.  If your processing of the
PSBT already finalizes it because you now have all the necessary signatures,
instead of to explicitly needing to call the finalized PSBT RPC, it'll just
return to you the complete set already.  It's pretty much a no-brainer that's
just strictly better.

**Mike Schmidt**: Yeah, a nice series of shortcuts.  Next two PRs are to the
Bitcoin Core GUI repository.  It's been a while, I think, since we've covered
the Bitcoin Core GUI, and we have two this week.

_Bitcoin Core GUI #119_

First one is PR #119, that makes a change so that the GUI's transaction list no
longer provides a special category for, "Payment to yourself" transactions.
Instead, now the GUI will show the transaction in both the spending and
receiving lists if that transaction has inputs and outputs that affect that
particular wallet.  And the use cases mentioned here would be multiparty
protocols, like payjoins or coinjoins.  And I also thought it was notable that
this PR originated and was opened in early 2019, and took quite a while to get
in for something that is seemingly fairly straightforward.  Murch or AJ, any
comments?

**Mark Erhardt**: Yeah, I was just staring at that.  That seems very reasonable.
I think it's 2020 though, unless you're seeing this somewhere else.

**Mike Schmidt**: Yeah, I think the original one was in the Bitcoin Core
repository and not the GUI repository.

**Mark Erhardt**: Oh, it got moved, yeah.  Yeah, so GUI for Bitcoin Core has its
separate repository now, and there's also a lot of work going into a completely
new GUI, which hopefully will eventually be deployed.  So, maybe we'll start
having a slightly nicer-looking GUI for people that use Bitcoin Core Wallet.

_Bitcoin Core GUI #738_

**Mike Schmidt**: Next PR, Bitcoin Core GUI #738.  Right now, there's RPCs that
can be used to migrate your wallet from a legacy wallet to a descriptor wallet,
and "GUI users need to be able to migrate wallets without going to the RPC
console".  So, this PR adds UI elements to the GUI to facilitate migrating from
a legacy wallet to a descriptor wallet.  Murch, should I prompt you to extol the
benefits of descriptor wallets, other than legacy wallets being deprecated?

**Mark Erhardt**: I think the biggest benefit is that we finally encode
specifically what type of output scripts you are tracking with each descriptor.
So, whereas we previously only defined the chain of keys that derive from a
single master secret with the BIP32 approach, with the descriptor, the
descriptor also says, "Okay, this is, for example, for P2TR outputs".  It makes
recoveries cheaper, it makes it cleaner to import and export wallets into other
wallets, because even if you're using different software, all the information
you need to know to exactly find your prior transactions and UTXOs is right
there.

_Bitcoin Core #28246_

**Mike Schmidt**: Next PR goes back to the Bitcoin Core repository, #28246,
updating how Bitcoin Core wallet internally determines what output script a
transaction should pay.  Murch, I thought this was a good one for you, so would
you take the lead on this one?

**Mark Erhardt**: Sure.  So, this is more of an internal change.  Basically,
when we build transactions we have a class that was or is CRecipient, which
encodes the recipient outputs.  So, that's just some representation of what
output script we're paying and the amount of money we are intending to assign to
that output.  And in this refactor, we change that from just storing the output
script in verbatim to the destination, and the destination here is basically
something that stores the address as well and/or can have different meaning.
And this is intended as a first step towards silent payments, where when the
sender is starting to build a transaction, they actually don't know the address
of the recipient yet, they only know the silent payment address.  And from this
static information, we derive an output script based on the inputs that get
used.  So, we wouldn't have the output script at the start of the transaction
building and we need to store other information, and that can more easily be put
into the destination class.  So, yeah, this is basically a preparatory step for
implementing silent payments more easily.

**Mike Schmidt**: Okay, so because Bitcoin Core has, at the wallet level,
decided to adopt silent payments, there's some internal plumbing that needs to
be done in order to support that.  And so, this PR lays the groundwork for that.

_Core Lightning #6311_

Next PR is to the Core Lightning Repository, #6311, removing the --developer
build option.  So previously, if you wanted to run a developer build with
additional options or experimental features outside of the normal Core Lightning
(CLN) release binaries, you needed to actually build with the --developer build
option.  But now, with this PR, CLN lets you use these additional or
experimental features using a runtime configuration option instead of having to
rebuild.  And that configuration option is also named --developer in order to
get those additional features.  Seems like it would be useful for developer
types experimenting around.  Murch, any thoughts?  Instagibbs is clapping.

_Core Lightning #6617_

All right.  Next PR, also to Core Lightning, #6617, adding a last_used field to
the showrunes RPC.  CLN uses authentication tokens, named runes, to allow
permissioned access to a CLN node, and now the RPC will show the last time that
that particular rune/authentication token was used.  So, that's somewhat useful
information for administrators.

_Core Lightning #6686_

One more Core Lightning PR, #6686.  So, back in Newsletter #262, we covered
CLN's new optional CLNRest service that provided REST endpoints that essentially
wrapped CLN's RPC commands.  And in this PR now, they've added a bunch of
security improvements to that REST service, so Cross-Origin-Resource-Sharing
(CORS) headers, Content-Security-Policy (CSP) headers, rune authentication if
you're using websockets.  And so, if you're using CLN's REST service and want to
make sure things are a bit more locked down, maybe take a look at this PR and
see the options available there.

_Eclair #2613_

Next PR is to the Eclair repository, #2613, allowing you to configure Eclair to
control and never expose the private keys of your Bitcoin Core wallet.
Essentially, Bitcoin Core would then be in a watch-only wallet mode.  And we
note in the writeup that, "This can be especially useful if Eclair is being run
in a more secure environment than Bitcoin Core".  And an example from the Eclair
PR was when, if you're in a scenario where maybe you're using Bitcoin Core in a
shared scenario, and Bitcoin Core is being shared among several different
services, that was given as an example use case for wanting to do this
segregation.

**Mark Erhardt**: So, when I saw this PR, I'm curious.  Does that imply that
Eclair was previously using Bitcoin Core as the signing device for Eclair, like
the key management and signing, or am I misinterpreting that; do you happen to
know?

**Mike Schmidt**: I don't feel comfortable answering that, no, but maybe.  Does
that concern you?

**Mark Erhardt**: No, I'm just curious.  I guess if you pass the raw
transactions directly to Core and Core has the keys, you should probably be able
to get it to sign for them, but it just seems like an interesting approach to
solve the issue.

_LND #7994_

**Mike Schmidt**: Continuing our tour of Lightning implementation PRs, we're
moving to LND #7994.  We noted in this discussion this week, and previous for
the last month and a half maybe, the LND release candidates adding this simple
taproot channel feature.  And with this PR, LND also adds support to the remote
signer RPC interface for opening up those taproot channels that we've been
talking about.  And that requires specifying a pubkey and the MuSig2 two-part
nonce in order to get that simple taproot channel via the RPC now.  Murch, any
thoughts on that one?  Seems pretty straightforward.

**Mark Erhardt**: No, let's move on.

_LDK #2547_

**Mike Schmidt**: Go MuSig2!  And moving on to LDK, we have LDK #2547.  Last
week we covered LDK #2176 which, in our discussion, increases the precision in
which LDK attempts to probabilistically guess the amount of liquidity available
in distant channels that it has attempted to route payments through.  So, that
increasing precision from last week is somewhat related to this #2547 this week.
This PR updates the probabilistic pathfinding code to assume that it's more
likely remote channels have most of their liquidity pushed to one side of the
channel.  Originally, this PR was based on the PR from last week, but that was
changed.  So, it seems that last week improved the precision of data used for
estimation, and this PR potentially then changes the pathfinding that uses that
data.  That's my intuition on it.  I don't know if, Murch, you got a chance to
look at it.

**Mark Erhardt**: I did not have a chance to look at this, but I think this is
interesting in the context of having talked about renepay and in general, the
flow mechanism that René Pickhardt had been working on.  And I was always
curious, I think that the expected value of channels there was always stated as
it's distributed linearly between the bounds that we know about, and this seems
to be exactly addressing this estimation.  Because, yeah, I don't know, it
always seemed odd that it would be linearly distributed.  Maybe if someone else
knows about this, this is the time to chime in.

_LDK #2534_

**Mike Schmidt**: Last PR is also to the LDK repository, #2534, adding a method
for probing payment paths before attempting to send a real payment.  There is an
Optech Wiki Topic on payment probes and I'll quote the first line from that to
give people context, "Payment probes are packets designed to discover
information about the LN channels they travel through, such as whether the
channel can currently handle a payment of a certain size or how many bitcoins
are allocated to each participant in the channel.  I have a question for AJ on
this.  AJ, is probing a "bad" activity on the LN?

**Anthony Towns**: It depends a bit on what you're probing for.  If you're just
probing to see if a payment you're about to make is going to go through, then
it's hard to say that's bad; but if you're spamming probes in order to try and
find out exactly what a channel's balance is and identify when that balance
changes, that's both a little bit bad for privacy and kind of pretty bad for
just spamming the network with traffic.  So, I mean, insofar as Lightning's
anonymous, then probing is just something that you've got to accept.  But the
intensive spamming stuff is kind of bad in a couple of ways, so hopefully we can
draw limits there.

**Mark Erhardt**: Yeah, I am reminded of something that I read early on when I
think that was Cash App was implementing their Lightning service.  They had the
idea, and I thought it was quite brilliant, or maybe it was LDK that implemented
it for them because Cash App used LDK, but basically, when you start putting in
a LN URL or a destination, or the invoice before you actually confirm that you
are sending it, in those few moments that the user had already interacted with,
what basically announced that there would very likely be a payment request very
soon, they would already start probing the routes to the recipient node.  And
then when the user actually confirmed the payment, they would only then
construct the actual payment route, but they had already more information along
the routes to the recipient and could therefore make a more informed attempt,
first attempt, and were highly more likely to succeed at routing the payment.

**Mike Schmidt**: That's it for the newsletter this week.  Thank you to AJ for
joining us and sprinkling wisdom throughout the newsletter and our discussion of
it.  Thanks always to my co-host, Murch, and thank you all for joining us this
week.

**Mark Erhardt**: Thanks, Mike, that was great.

**Anthony Towns**: Thanks for having us.

**Mike Schmidt**: Cheers.

{% include references.md %}
